create or replace package body csf_own.pk_limpa_open_interf is
--
-----------------------------------------------------------------
--| FUNÇÃO QUE VALIDA PARÂMETROS DE ENTRADA DO PROCESSO |--
-----------------------------------------------------------------
function fkb_validar return boolean
   is
   --
   vn_fase        number;
   vn_multorg     number;
   --
begin
   --
   vn_fase := 1;
   --
   if gn_multorg_id is not null then
      --
      vn_fase := 1.1;
      --
      begin
         --
         select mo.cd
           into gv_cod_mult_org
           from mult_org mo
          where mo.id = gn_multorg_id;
         --
      exception
         when no_data_found then
            --
            raise_application_error(-20001, 'Mult-org informado não existe (ID = '||gn_multorg_id||').');
            --
         when others then
            --
            raise_application_error(-20001, 'Problemas ao identificar o mult-org informado (ID = '||gn_multorg_id||'). Erro: '||SQLerrm);
            --
      end;
      --
   else
      --
      raise_application_error(-20001, 'Mult-Org informado não pode ser nulo.');
      --
   end if;
   --
   vn_fase := 2;
   --
   if gn_objintegr_id is not null then
      --
      vn_fase := 3;
      --
      begin
         --
         select oi.cd, oi.descr
           into gv_cd_objintegr, gv_desc_objintegr
           from obj_integr oi
          where oi.id = gn_objintegr_id;
         --
      exception
         when no_data_found then
            --
            raise_application_error(-20001, 'Objeto de Integração informado não existe (ID = '||gn_objintegr_id||').');
            --
         when others then
            --
            raise_application_error(-20001, 'Problemas ao identificar o objeto de integração (ID = '||gn_objintegr_id||'). Erro: '||SQLerrm);
            --
      end;
      --
   else
      --
      raise_application_error(-20001, 'Objeto de Integração informado não pode ser nulo.');
      --
   end if;
   --
   vn_fase := 4;
   --
   if gn_usuario_id is not null then
      --
      vn_fase := 5;
      --
      begin
         --
         select nu.nome, nu.multorg_id
           into gv_nome_usuario, vn_multorg
           from neo_usuario nu
          where nu.id = gn_usuario_id;
         --
      exception
         when no_data_found then
            --
            raise_application_error(-20001, 'Usuário informado não existe (ID = '||gn_usuario_id||').');
            --
         when others then
            --
            raise_application_error(-20001, 'Problemas na identificação do usuário (ID = '||gn_usuario_id||'). Erro: '||SQLerrm);
            --
      end;
      --
      vn_fase := 6;
      --
      if gn_multorg_id <> vn_multorg then
         --
         raise_application_error(-20001, 'Usuário: ('||gv_nome_usuario||'), não está relacionado com o Mult-org de código ('||gv_cod_mult_org||').');
         --
      end if;
      --
   else
      --
      raise_application_error(-20001, 'Usuário informado não pode ser nulo.');
      --
   end if;
   --
   vn_fase := 7;
   --
   if gd_dt_ini is null then
      --
      if gd_dt_fin is not null then
         --
         raise_application_error(-20001, 'Data inicial esta nula. Data final também deve ser nula.');
         --
      end if;
      --
   end if;
   --
   vn_fase := 8;
   --
   if gd_dt_fin is null then
      --
      if gd_dt_ini is not null then
         --
         raise_application_error(-20001, 'Data final esta nula. Data inicial também deve ser nula.');
         --
      end if;
      --
   end if;
   --
   vn_fase := 9;
   --
   if gd_dt_ini is not null and gd_dt_fin is not null then
      --
      if gd_dt_ini > gd_dt_fin then
         --
         raise_application_error(-20001, 'Data inicial não pode ser maior que a data final.');
         --
      end if;
      --
   end if;
   --
   vn_fase := 8;
   --
   begin
      --
      select pg.valor
        into gv_tipo_sistema
        from param_global_csf pg
       where pg.cd = 'SISTEMA_EM_NUVEM';
      --
   exception
      when others then
         --
         gv_tipo_sistema := null;
         --
   end;
   --
   return true;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.fkb_validar fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end fkb_validar;

----------------------------------------------------------------
--|REGISTRA A INFORMAÇÃO NA LOG GENERICO|--
----------------------------------------------------------------
procedure pkb_reg_info
   is
   --
   vn_fase  number := 0;
   vv_texto log_generico.mensagem%type;
   --
begin
   --
   vn_fase := 1;
   --
   vv_texto := 'Usuário '||gv_nome_usuario||', solicitou a limpeza de integração referente ao objeto que integra '
               ||gv_desc_objintegr||', na data: '||nvl(gd_dt_ini, sysdate)||' até : '||nvl(gd_dt_fin, sysdate)
               ||'. CNPJ/CPF: '||gv_cnpj
               ||' Empresa: '||pk_csf.fkg_nome_empresa(en_empresa_id => gn_empresa_id)||'.';
   --
   vn_fase := 2;
   --
   insert into log_generico ( id
                            , processo_id
                            , dt_hr_log
                            , referencia_id
                            , obj_referencia
                            , resumo
                            , dm_impressa
                            , dm_env_email
                            , csftipolog_id
                            , empresa_id
                            , mensagem
                            )
                     values ( loggenerico_seq.nextval
                            , 0
                            , sysdate
                            , gn_empresa_id
                            , 'LIMPA_OPEN_INTERF'
                            , vv_texto
                            , 0
                            , 0
                            , (select id from csf_tipo_log where cd = 'INFORMACAO')
                            , gn_empresa_id
                            , vv_texto
                            );
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_reg_info fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_reg_info;
--
----------------------------------------------------------------
--|PROCESSO QUE LIMPA INTEGRAÇÃO DE CADASTRO = 1|--
----------------------------------------------------------------
/*Leiaute_Views_Integracao_Cadastro_V2_9*/
procedure pkb_limpa_cad ( en_multorg_id   in mult_org.id%type
                        , en_empresa_id   in empresa.id%type

                         )
   is
   --
   vn_fase       number := 0;
   --
   -- Cursores das views FF(Flex Field) criadas para integração da MULT_ORG
   -- =====================================================================
   --
   -- cadastro de pessoas/participantes
   cursor c_csf_pessoa_ff is
      select distinct vc.cod_part
        from vw_csf_pessoa_ff vc
       where vc.atributo = 'COD_MULT_ORG'
         and vc.valor    = gv_cod_mult_org;
   --
   -- cadastro de unidades de medidas
   cursor c_csf_unidade_ff is
      select distinct vc.sigla_unid
        from vw_csf_unidade_ff vc
       where vc.atributo = 'COD_MULT_ORG'
         and vc.valor    = gv_cod_mult_org;
   --
   -- produtos e/ou serviços
   cursor c_csf_item_ff is
      select distinct vc.cpf_cnpj
        from vw_csf_item_ff vc
       where vc.atributo = 'COD_MULT_ORG'
         and vc.valor    = gv_cod_mult_org;
   --
   -- unidade
   cursor c_csf_conv_unid_ff is
      select distinct vc.cpf_cnpj
        from vw_csf_conv_unid_ff vc
       where vc.atributo = 'COD_MULT_ORG'
         and vc.valor    = gv_cod_mult_org;
   --
   -- grupos de patrimônio
   cursor c_csf_grupo_pat_ff is
      select distinct vc.cd
        from vw_csf_grupo_pat_ff vc
       where vc.atributo = 'COD_MULT_ORG'
         and vc.valor    = gv_cod_mult_org
       order by 1 asc;
   --
   -- Bens do ativo imobiliario
   cursor c_csf_bem_ativo_imob_ff is
      select distinct vc.cpf_cnpj
        from vw_csf_bem_ativo_imob_ff vc
      where vc.atributo = 'COD_MULT_ORG'
        and vc.valor    = gv_cod_mult_org;
   --
   -- Natureza da operação/prestação
   cursor c_csf_nat_oper_ff is
      select distinct vc.cod_nat
        from vw_csf_nat_oper_ff vc
       where vc.atributo = 'COD_MULT_ORG'
         and vc.valor    = gv_cod_mult_org;
   --
   -- Complementar do documento fiscal
   cursor c_csf_inforcomp_dctofiscal_ff is
      select distinct vc.cod_infor
        from vw_csf_inforcomp_dctofiscal_ff vc
       where vc.atributo = 'COD_MULT_ORG'
         and vc.valor    = gv_cod_mult_org;
   --
   -- Observação do lançamento fiscal
   cursor c_csf_obs_lancto_fiscal_ff is
      select distinct vc.cod_obs
        from vw_csf_obs_lancto_fiscal_ff vc
       where vc.atributo = 'COD_MULT_ORG'
         and vc.valor    = gv_cod_mult_org;
   --
   -- Plano de conta
   cursor c_csf_plano_conta_ff is
     select distinct vc.cpf_cnpj
       from vw_csf_plano_conta_ff vc
      where vc.atributo = 'COD_MULT_ORG'
        and vc.valor    = gv_cod_mult_org;
   -- Centro de Custo
   cursor c_csf_centro_custo_ff is
      select distinct vc.cpf_cnpj
        from vw_csf_centro_custo_ff vc
       where vc.atributo = 'COD_MULT_ORG'
         and vc.valor    = gv_cod_mult_org;
   --
   -- Plano de conta por empresa
   cursor c_csf_plano_conta_ff_emp is
     select distinct vc.cpf_cnpj
       from vw_csf_plano_conta_ff vc, pessoa p , empresa e where 1=1
        and e.pessoa_id = p.id
        and vc.cpf_cnpj = p.cod_part
        and vc.atributo = 'COD_MULT_ORG'
        and e.id = gn_empresa_id;
   --
   -- Centro de Custo por empresa
   cursor c_csf_centro_custo_ff_emp is
      select distinct vc.cpf_cnpj
        from vw_csf_centro_custo_ff vc, pessoa p , empresa e where 1=1
        and e.pessoa_id = p.id
        and vc.cpf_cnpj = p.cod_part
        and vc.atributo = 'COD_MULT_ORG'
        and e.id = gn_empresa_id;
   --
   -- Histórico Padrão
   cursor c_csf_hist_padrao_ff is
      select vc.cpf_cnpj
        from vw_csf_hist_padrao_ff vc
       where vc.atributo = 'COD_MULT_ORG'
         and vc.valor    = gv_cod_mult_org;
   --
   -- Cálculo de ICMS-ST
   cursor c_csf_item_param_icmsst_ff is
      select vc.cpf_cnpj
        from vw_csf_item_param_icmsst_ff vc
       where vc.atributo = 'COD_MULT_ORG'
         and vc.valor    = gv_cod_mult_org;
   --
   -- Processos administrativos e Judiciais da EFD REINF Flex-Field
   cursor c_csf_proc_adm_efd_reinf_ff is
     select vc.cpf_cnpj
       from vw_csf_proc_adm_efd_reinf_ff vc
      where vc.atributo = 'COD_MULT_ORG'
        and vc.valor    = gv_cod_mult_org;
   --
   -- Informações complementares do plano de contas referencial
   cursor c_csf_pc_referen_ff is
     select vc.cpf_cnpj
       from vw_csf_pc_referen_ff vc
      where vc.atributo = 'COD_MULT_ORG'
        and vc.valor    = gv_cod_mult_org;
   --
   -- Informações complementares do plano de contas referencial por empresa
    cursor c_csf_pc_referen_ff_emp is
      select vc.cpf_cnpj
       from vw_csf_pc_referen_ff vc, pessoa p , empresa e where 1=1
        and e.pessoa_id = p.id
        and vc.cpf_cnpj = p.cod_part
        and vc.atributo = 'COD_MULT_ORG'
        and e.id = gn_empresa_id;
   --
   -- Parametros da Tabela de DIPAM por estado
   cursor c_csf_param_dipamgia_ff is
     select vc.cpf_cnpj
       from vw_csf_param_dipamgia_ff vc
      where vc.atributo = 'COD_MULT_ORG'
        and vc.valor    = gv_cod_mult_org;
   --
   -- Informações complementares do subgrupo de patrimônio
   cursor c_csf_subgrupo_pat_ff is
     select vc.cd_grupopat
          , vc.cd_subgrupopat
       from vw_csf_subgrupo_pat_ff vc
      where vc.atributo = 'COD_MULT_ORG'
        and vc.valor    = gv_cod_mult_org;
   --
   -- Informações complementares do subgrupo de patrimônio
   cursor c_csf_rec_imp_subgrupo_pat_ff is
     select vc.cd_grupopat
          , vc.cd_subgrupopat
          , vc.cd_tipo_imp
       from vw_csf_rec_imp_subgrupo_pat_ff vc
      where vc.atributo = 'COD_MULT_ORG'
        and vc.valor    = gv_cod_mult_org;
   --
   cursor c_csf_infor_util_bem_ff is
      select cpf_cnpj
           , cod_ind_bem
           , cod_ccus
        from vw_csf_infor_util_bem_ff vc
      where vc.atributo = 'COD_MULT_ORG'
        and vc.valor    = gv_cod_mult_org;
   --
   cursor c_csf_bem_ativo_imob_compl_ff is
      select cpf_cnpj
	   , cod_ind_bem
        from vw_csf_bem_ativo_imob_compl_ff vc
       where vc.atributo = 'COD_MULT_ORG'
         and vc.valor    = gv_cod_mult_org;
   --
   cursor c_csf_recimp_bemativo_imob_ff is
      select cpf_cnpj
           , cod_ind_bem
           , cd_tipo_imp
        from vw_csf_recimp_bemativo_imob_ff vc
       where vc.atributo = 'COD_MULT_ORG'
         and vc.valor    = gv_cod_mult_org;
   --
   cursor c_csf_nf_bem_ativo_imob_ff is
      select cpf_cnpj
           , cod_ind_bem
           , dm_ind_emit
           , cod_part
           , cod_mod
           , serie
           , num_doc
        from vw_csf_nf_bem_ativo_imob_ff vc
       where vc.atributo = 'COD_MULT_ORG'
         and vc.valor    = gv_cod_mult_org;
   --
   cursor c_csf_itnf_bem_ativo_imob_ff is
      select cpf_cnpj
           , cod_ind_bem
           , dm_ind_emit
           , cod_part
           , cod_mod
           , serie
           , num_doc
           , num_item
        from vw_csf_itnf_bem_ativo_imob_ff vc
       where vc.atributo = 'COD_MULT_ORG'
         and vc.valor    = gv_cod_mult_org;
   --
begin
   --
   vn_fase  := 1;
   --allan
   --gv_tipo_sistema := 'SIM';
   --
   if nvl(gv_tipo_sistema, 'NAO') = 'SIM' then  -- Verifica se o cliente trabalha em nuvem.
      --
      -- Exclusão das views que NÃO possuem FF que tratam do COD_MULT_ORG
      -- ================================================================
      vn_fase := 2;
      --
      delete from vw_csf_abertura_fci vc where vc.cnpj_empr = gv_cnpj;
      --
      vn_fase := 3;
      --
      delete from vw_csf_retorno_fci vc where vc.cnpj_empr = gv_cnpj;
      --
      vn_fase := 4;
      --
      delete from vw_csf_pc_referen_period vc where vc.cpf_cnpj = gv_cnpj;
      --
      vn_fase := 5;
      --
      delete from vw_csf_pc_aglut_contabil vc where vc.cpf_cnpj_emit = gv_cnpj;
      --
      vn_fase := 6;
      --
      delete from vw_csf_aglut_contabil vc where vc.cpf_cnpj_emit = gv_cnpj;
      --
      vn_fase := 7;
      --
      delete from vw_csf_nat_oper_serv vc where vc.cpf_cnpj_emit = gv_cnpj;
      --
      vn_fase := 8;
      --
      delete from vw_csf_param_imp_nat_oper_serv vc where vc.cpf_cnpj_emit = gv_cnpj;
      --
      vn_fase := 9;
      --
      delete from vw_csf_nat_oper_tipoimp vc where vc.cd_mult_org = gv_cod_mult_org;
      --
      vn_fase := 10;
      --
      delete from vw_csf_param_item_entr vc where vc.cpf_cnpj_emit = gv_cnpj;
      --
      vn_fase := 11;
      --
      delete from vw_csf_param_oper_fiscal_entr vc where vc.cpf_cnpj_emit = gv_cnpj;
      --
      -- Exclusão com base nas FF que tratam do COD_MULT_ORG
      -- ================================================================
      --
      vn_fase := 20;
      --
      for rec in c_csf_pessoa_ff loop
         exit when c_csf_pessoa_ff%notfound or (c_csf_pessoa_ff%notfound) is null;
         --
         vn_fase := 20.1;
         --
         delete from vw_csf_pessoa vc where vc.cod_part = rec.cod_part;
         --
         vn_fase := 20.2;
         --
         delete from vw_csf_pessoa_tipo_param vc where vc.cod_part = rec.cod_part;
         --
         vn_fase := 20.3;
         --
         delete from vw_csf_pessoa_info_pir vc where vc.cod_part = rec.cod_part;
         --
         vn_fase := 20.4;
         --
         delete from vw_csf_pessoa_ff vc where vc.cod_part = rec.cod_part;
         --
         commit;
         --
      end loop;
      --
      vn_fase := 21;
      --
      for rec in c_csf_unidade_ff loop
         exit when c_csf_unidade_ff%notfound or (c_csf_unidade_ff%notfound) is null;
         --
         delete from vw_csf_unidade vc where vc.sigla_unid = rec.sigla_unid;
         --
         vn_fase := 21.1;
         --
         delete from vw_csf_unidade_ff vc where vc.sigla_unid = rec.sigla_unid;
         --
         commit;
         --
      end loop;
      --
      vn_fase := 22;
      --
      for rec in c_csf_item_ff loop
         exit when c_csf_item_ff%notfound or (c_csf_item_ff%notfound) is null;
         --
         vn_fase := 22.1;
         --
         delete from vw_csf_item vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         vn_fase := 22.2;
         --
         delete from vw_csf_item_marca_comerc vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         vn_fase := 22.3;
         --
         delete from vw_csf_item_compl vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         vn_fase := 22.4;
         --
         delete from vw_csf_item_ff vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         commit;
         --
      end loop;
      --
      vn_fase := 23;
      --
      for rec in c_csf_conv_unid_ff loop
         exit when c_csf_conv_unid_ff%notfound or (c_csf_conv_unid_ff%notfound) is null;
         --
         vn_fase := 23.1;
         --
         delete from vw_csf_conv_unid vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         vn_fase := 23.2;
         --
         delete from vw_csf_conv_unid_ff vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
      end loop;
      --
      vn_fase := 24;
      --
      for rec in c_csf_grupo_pat_ff loop
         exit when c_csf_grupo_pat_ff%notfound or (c_csf_grupo_pat_ff%notfound) is null;
         --
         delete from vw_csf_grupo_pat vc where vc.cd = rec.cd;
         --
         vn_fase := 24.1;
         --
         delete from vw_csf_grupo_pat_ff vc where vc.cd = rec.cd;
         --
         commit;
         --
      end loop;
      --
      vn_fase := 25;
      --
      for rec in c_csf_subgrupo_pat_ff loop
         exit when c_csf_subgrupo_pat_ff%notfound or (c_csf_subgrupo_pat_ff%notfound) is null;
         --
         vn_fase := 25.1;
         --
         delete from vw_csf_subgrupo_pat vc where vc.cd_grupopat = rec.cd_grupopat and vc.cd_subgrupopat = rec.cd_subgrupopat;
         --
         vn_fase := 25.2;
         --
         delete from vw_csf_subgrupo_pat_ff vc where vc.cd_grupopat = rec.cd_grupopat and vc.cd_subgrupopat = rec.cd_subgrupopat;
         --
         commit;
         --
      end loop;
      --
      vn_fase := 26;
      --
      for rec in c_csf_rec_imp_subgrupo_pat_ff loop
         exit when c_csf_rec_imp_subgrupo_pat_ff%notfound or (c_csf_rec_imp_subgrupo_pat_ff%notfound) is null;
         --
         vn_fase := 26.1;
         --
         delete from vw_csf_rec_imp_subgrupo_pat vc
          where vc.cd_grupopat    = rec.cd_grupopat
            and vc.cd_subgrupopat = rec.cd_subgrupopat
            and vc.cd_tipo_imp    = rec.cd_tipo_imp;
         --
         vn_fase := 26.2;
         --
         delete from vw_csf_rec_imp_subgrupo_pat_ff vc
          where vc.cd_grupopat    = rec.cd_grupopat
            and vc.cd_subgrupopat = rec.cd_subgrupopat
            and vc.cd_tipo_imp    = rec.cd_tipo_imp;
         --
         commit;
         --
      end loop;
      --
      vn_fase := 27;
      --
      for rec in c_csf_bem_ativo_imob_ff loop
         exit when c_csf_bem_ativo_imob_ff%notfound or (c_csf_bem_ativo_imob_ff%notfound) is null;
         --
         vn_fase := 27.1;
         --
         delete from vw_csf_bem_ativo_imob vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         vn_fase := 27.2;
         --
         delete from vw_csf_bem_ativo_imob_ff vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         commit;
         --
      end loop;
      --
      vn_fase := 28;
      --
      for rec in c_csf_infor_util_bem_ff loop
         exit when c_csf_infor_util_bem_ff%notfound or (c_csf_infor_util_bem_ff%notfound) is null;
         --
         vn_fase := 28.1;
         --
         delete from vw_csf_infor_util_bem vc where vc.cpf_cnpj = rec.cpf_cnpj and vc.cod_ind_bem = rec.cod_ind_bem and vc.cod_ccus = rec.cod_ccus;
         --
         vn_fase := 28.2;
         --
         delete from vw_csf_infor_util_bem_ff vc where vc.cpf_cnpj = rec.cpf_cnpj and vc.cod_ind_bem = rec.cod_ind_bem and vc.cod_ccus = rec.cod_ccus;
         --
         commit;
         --
      end loop;
      --
      vn_fase := 29;
      --
      for rec in c_csf_bem_ativo_imob_compl_ff loop
         exit when c_csf_bem_ativo_imob_compl_ff%notfound or (c_csf_bem_ativo_imob_compl_ff%notfound) is null;
         --
         vn_fase := 29.1;
         --
         delete from vw_csf_bem_ativo_imob_compl vc where vc.cpf_cnpj = rec.cpf_cnpj and vc.cod_ind_bem = rec.cod_ind_bem;
         --
         vn_fase := 29.2;
         --
         delete from vw_csf_bem_ativo_imob_compl_ff vc where vc.cpf_cnpj = rec.cpf_cnpj and vc.cod_ind_bem = rec.cod_ind_bem;
         --
         commit;
         --
      end loop;
      --
      vn_fase := 30;
      --

      for rec in c_csf_recimp_bemativo_imob_ff loop
         exit when c_csf_recimp_bemativo_imob_ff%notfound or (c_csf_recimp_bemativo_imob_ff%notfound) is null;
         --
         vn_fase := 30.1;
         --
         delete from vw_csf_rec_imp_bem_ativo_imob vc where vc.cpf_cnpj = rec.cpf_cnpj and vc.cod_ind_bem = rec.cod_ind_bem and vc.cd_tipo_imp = rec.cd_tipo_imp;
         --
         vn_fase := 30.2;
         --
         delete from vw_csf_recimp_bemativo_imob_ff vc where vc.cpf_cnpj = rec.cpf_cnpj and vc.cod_ind_bem = rec.cod_ind_bem and vc.cd_tipo_imp = rec.cd_tipo_imp;
         --
      end loop;
      --
      vn_fase := 31;
      --

      for rec in c_csf_nf_bem_ativo_imob_ff loop
         exit when c_csf_nf_bem_ativo_imob_ff%notfound or (c_csf_nf_bem_ativo_imob_ff%notfound) is null;
         --
         vn_fase := 31.1;
         --
         delete from vw_csf_nf_bem_ativo_imob vc
               where vc.cpf_cnpj    = rec.cpf_cnpj
                 and vc.cod_ind_bem = rec.cod_ind_bem
                 and vc.dm_ind_emit = rec.dm_ind_emit
                 and vc.cod_part    = rec.cod_part
                 and vc.cod_mod     = rec.cod_mod
                 and vc.serie       = rec.serie
                 and vc.num_doc     = rec.num_doc;
         --
         vn_fase := 31.2;
         --
         delete from vw_csf_nf_bem_ativo_imob_ff vc
               where vc.cpf_cnpj    = rec.cpf_cnpj
                 and vc.cod_ind_bem = rec.cod_ind_bem
                 and vc.dm_ind_emit = rec.dm_ind_emit
                 and vc.cod_part    = rec.cod_part
                 and vc.cod_mod     = rec.cod_mod
                 and vc.serie       = rec.serie
                 and vc.num_doc     = rec.num_doc;
         --
      end loop;
      --
      vn_fase := 32;
      --

      for rec in c_csf_itnf_bem_ativo_imob_ff loop
         exit when c_csf_itnf_bem_ativo_imob_ff%notfound or (c_csf_itnf_bem_ativo_imob_ff%notfound) is null;
         --
         vn_fase := 32.1;
         --
         delete from vw_csf_itnf_bem_ativo_imob vc
               where vc.cpf_cnpj    = rec.cpf_cnpj
                 and vc.cod_ind_bem = rec.cod_ind_bem
                 and vc.dm_ind_emit = rec.dm_ind_emit
                 and vc.cod_part    = rec.cod_part
                 and vc.cod_mod     = rec.cod_mod
                 and vc.serie       = rec.serie
                 and vc.num_doc     = rec.num_doc
                 and vc.num_item    = rec.num_item;
         --
         vn_fase := 32.2;
         --
         delete from vw_csf_itnf_bem_ativo_imob_ff vc
               where vc.cpf_cnpj    = rec.cpf_cnpj
                 and vc.cod_ind_bem = rec.cod_ind_bem
                 and vc.dm_ind_emit = rec.dm_ind_emit
                 and vc.cod_part    = rec.cod_part
                 and vc.cod_mod     = rec.cod_mod
                 and vc.serie       = rec.serie
                 and vc.num_doc     = rec.num_doc
                 and vc.num_item    = rec.num_item;
         --
         commit;
         --
      end loop;
      --
      vn_fase := 33;
      --
      for rec in c_csf_nat_oper_ff loop
         exit when c_csf_nat_oper_ff%notfound or (c_csf_nat_oper_ff%notfound) is null;
         --
         delete from vw_csf_nat_oper vc where vc.cod_nat = rec.cod_nat;
         --
         vn_fase := 33.1;
         --
         delete from vw_csf_nat_oper_ff vc where vc.cod_nat = rec.cod_nat;
         --
         commit;
         --
      end loop;
      --
      vn_fase := 34;
      --
      for rec in c_csf_inforcomp_dctofiscal_ff loop
         exit when c_csf_inforcomp_dctofiscal_ff%notfound or (c_csf_inforcomp_dctofiscal_ff%notfound) is null;
         --
         delete from vw_csf_infor_comp_dcto_fiscal vc where vc.cod_infor = rec.cod_infor;
         --
         vn_fase := 34.1;
         --
         delete from vw_csf_inforcomp_dctofiscal_ff vc where vc.cod_infor = rec.cod_infor;
         --
         commit;
         --
      end loop;
      --
      vn_fase := 35;
      --
      for rec in c_csf_obs_lancto_fiscal_ff loop
         exit when c_csf_obs_lancto_fiscal_ff%notfound or (c_csf_obs_lancto_fiscal_ff%notfound) is null;
         --
         delete from vw_csf_obs_lancto_fiscal vc where vc.cod_obs = rec.cod_obs;
         --
         vn_fase := 35.1;
         --
         delete from vw_csf_obs_lancto_fiscal_ff vc where vc.cod_obs = rec.cod_obs;
         --
         commit;
         --
      end loop;
      --
      vn_fase := 36;
      --
      if (en_multorg_id > 0 ) then
      for rec in c_csf_plano_conta_ff loop
         exit when c_csf_plano_conta_ff%notfound or (c_csf_plano_conta_ff%notfound) is null;
         --
         delete from vw_csf_plano_conta vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         vn_fase := 36.1;
         --
         delete from vw_csf_plano_conta_ff vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         commit;
         --
      end loop;
      --
      vn_fase := 37;
      --
      for rec in c_csf_centro_custo_ff loop
         exit when c_csf_centro_custo_ff%notfound or (c_csf_centro_custo_ff%notfound) is null;
         --
         delete from vw_csf_centro_custo vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         vn_fase := 37.1;
         --
         delete from vw_csf_centro_custo_ff vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         commit;
         --
      end loop;
      --
     for rec in c_csf_pc_referen_ff loop
         exit when c_csf_pc_referen_ff%notfound or (c_csf_pc_referen_ff%notfound) is null;
         --
         vn_fase := 41.1;
         --
         delete from vw_csf_pc_referen vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         vn_fase := 41.2;
         --
         delete from vw_csf_pc_referen_ff vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         commit;
         --
      end loop;
      --
      else
          for rec in c_csf_plano_conta_ff_emp loop
         exit when c_csf_plano_conta_ff_emp%notfound or (c_csf_plano_conta_ff_emp%notfound) is null;
         --
         delete from vw_csf_plano_conta vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         vn_fase := 36.1;
         --
         delete from vw_csf_plano_conta_ff vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         commit;
         --
      end loop;
      --
      vn_fase := 37;
      --
      for rec in c_csf_centro_custo_ff_emp loop
         exit when c_csf_centro_custo_ff_emp%notfound or (c_csf_centro_custo_ff_emp%notfound) is null;
         --
         delete from vw_csf_centro_custo vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         vn_fase := 37.1;
         --
         delete from vw_csf_centro_custo_ff vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         commit;
         --
      end loop;
      --
      end if;

      vn_fase := 38;
      --
      for rec in c_csf_hist_padrao_ff loop
         exit when c_csf_hist_padrao_ff%notfound or (c_csf_hist_padrao_ff%notfound) is null;
         --
         delete from vw_csf_hist_padrao vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         vn_fase := 38.1;
         --
         delete from vw_csf_hist_padrao_ff vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         commit;
         --
      end loop;
      --
      vn_fase := 39;
      --
      for rec in c_csf_item_param_icmsst_ff loop
         exit when c_csf_item_param_icmsst_ff%notfound or (c_csf_item_param_icmsst_ff%notfound) is null;
         --
         delete from vw_csf_item_param_icmsst vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         vn_fase := 39.1;
         --
         delete from vw_csf_item_param_icmsst_ff vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         commit;
         --
      end loop;
      --
      vn_fase := 40;
      --
      for rec in c_csf_proc_adm_efd_reinf_ff loop
       exit when c_csf_proc_adm_efd_reinf_ff%notfound or (c_csf_proc_adm_efd_reinf_ff%notfound) is null;
         --
         vn_fase := 40.1;
         --
         delete from vw_csf_procadmefdreinfinftrib vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         vn_fase := 40.2;
         --
         delete from vw_csf_proc_adm_efd_reinf vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         vn_fase := 40.3;
         --
         delete from vw_csf_proc_adm_efd_reinf_ff vc where vc.cpf_cnpj = gv_cnpj;
         --
         commit;
         --
      end loop;
      --
      vn_fase := 41;
      --
      for rec in c_csf_pc_referen_ff_emp loop
         exit when c_csf_pc_referen_ff_emp%notfound or (c_csf_pc_referen_ff_emp%notfound) is null;
         --
         vn_fase := 41.1;
         --
         delete from vw_csf_pc_referen vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         vn_fase := 41.2;
         --
         delete from vw_csf_pc_referen_ff vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         commit;
         --
      end loop;
      --
      vn_fase := 42;
      --
      for rec in c_csf_param_dipamgia_ff loop
         exit when c_csf_param_dipamgia_ff%notfound or (c_csf_param_dipamgia_ff%notfound) is null;
         --
         vn_fase := 42.1;
         --
         delete from vw_csf_param_dipamgia vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         vn_fase := 42.2;
         --
         delete from vw_csf_param_dipamgia_ff vc where vc.cpf_cnpj = rec.cpf_cnpj;
         --
         commit;
         --
      end loop;
      --
   -- Cliente não trabalha com a nuvem.
   -- =================================
   else
      --
      vn_fase := 50;
      --
      begin
         delete from vw_csf_pessoa_ff;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 51;
      --
      begin
         delete from vw_csf_pessoa;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 52;
      --
      begin
         delete from vw_csf_pessoa_tipo_param;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 53;
      --
      begin
         delete from vw_csf_pessoa_info_pir;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 54;
      --
      begin
         delete from vw_csf_unidade_ff;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 55;
      --
      begin
         delete from vw_csf_unidade;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 56;
      --
      begin
         delete from vw_csf_item_ff;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 57;
      --
      begin
        delete from vw_csf_item;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 58;
      --
      begin
         delete from vw_csf_conv_unid_ff;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 59;
      --
      begin
         delete from vw_csf_conv_unid;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 60;
      --
      begin
         delete from vw_csf_item_marca_comerc;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 61;
      --
      begin
         delete from vw_csf_item_compl;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 62;
      --
      begin
         delete from vw_csf_grupo_pat_ff;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 63;
      --
      begin
         delete from vw_csf_grupo_pat;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 64;
      --
      begin
         delete from vw_csf_subgrupo_pat_ff;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 65;
      --
      begin
         delete from vw_csf_subgrupo_pat;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 66;
      --
      begin
         delete from vw_csf_rec_imp_subgrupo_pat_ff;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 67;
      --
      begin
         delete from vw_csf_rec_imp_subgrupo_pat;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 68;
      --
      begin
         delete from vw_csf_bem_ativo_imob_ff;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 69;
      --
      begin
         delete from vw_csf_bem_ativo_imob;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 70;
      --
      begin
         delete from vw_csf_infor_util_bem_ff;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 71;
      --
      begin
         delete from vw_csf_infor_util_bem;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 72;
      --
      begin
         delete from vw_csf_bem_ativo_imob_compl_ff;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 73;
      --
      begin
         delete from vw_csf_bem_ativo_imob_compl;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 74;
      --
      begin
         delete from vw_csf_rec_imp_bem_ativo_imob;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 75;
      --
      begin
         delete from vw_csf_nf_bem_ativo_imob_ff;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 76;
      --
      begin
         delete from vw_csf_nf_bem_ativo_imob;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 77;
      --
      begin
         delete from vw_csf_itnf_bem_ativo_imob;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 78;
      --
      begin
         delete from vw_csf_nat_oper;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 79;
      --
      begin
         delete from vw_csf_nat_oper_serv;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 80;
      --
      begin
         delete from vw_csf_param_imp_nat_oper_serv;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 81;
      --
      begin
         delete from vw_csf_nat_oper_tipoimp;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 82;
      --
      begin
         delete from vw_csf_infor_comp_dcto_fiscal;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 83;
      --
      begin
         delete from vw_csf_obs_lancto_fiscal;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 84;
      --
      begin
         delete from vw_csf_plano_conta;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 85;
      --
      begin
         delete from vw_csf_pc_referen;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 86;
      --
      begin
         delete from vw_csf_pc_referen_period;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 87;
      --
      begin
         delete from vw_csf_pc_aglut_contabil;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 88;
      --
      begin
         delete from vw_csf_aglut_contabil;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 89;
      --
      begin
         delete from vw_csf_centro_custo;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 90;
      --
      begin
         delete from vw_csf_hist_padrao;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 91;
      --
      begin
         delete from vw_csf_item_param_icmsst;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 92;
      --
      begin
         delete from vw_csf_abertura_fci;
      exception
         when others then
            null;
      end;
      --
      vn_fase:= 93;
      --
      begin
         delete from vw_csf_param_item_entr;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 94;
      --
      begin
         delete from vw_csf_param_oper_fiscal_entr;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 95;
      --
      begin
         delete from vw_csf_recimp_bemativo_imob_ff;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 96;
      --
      begin
         delete from vw_csf_retorno_fci;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 97;
      --
      begin
         delete from vw_csf_param_dipamgia_ff;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 98;
      --
      begin
         delete from vw_csf_param_dipamgia;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 99;
      --
      begin
         delete from vw_csf_proc_adm_efd_reinf;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 100;
      --
      begin
         delete from vw_csf_procadmefdreinfinftrib;
      exception
         when others then
            null;
      end;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_cad fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_cad;
--
----------------------------------------------------------------------------------------------------
--
-- Rotina que Limpar as Views do Sped ECF
procedure pkb_limpa_secf is
   --
   vn_fase number := 0;
   --
   cursor c_lvtd is
      select vc.cpf_cnpj
           , vc.dt_ini
           , vc.dt_fim
        from vw_csf_lanc_vlr_tab_din vc -- VW_CSF_LANC_VLR_TAB_DIN
       where vc.cpf_cnpj = gv_cnpj
         and vc.dt_ini >= nvl(gd_dt_ini,vc.dt_ini)
         and vc.dt_fim <= nvl(gd_dt_fin,vc.dt_fim);
   --
   cursor c_dmc is
    select vc.cpf_cnpj
         , vc.dt_demon
         , vc.num_doc
        from vw_csf_dem_livro_caixa vc -- VW_CSF_DEM_LIVRO_CAIXA
       where vc.cpf_cnpj = gv_cnpj
         and vc.dt_demon between nvl(gd_dt_ini,vc.dt_demon) and nvl(gd_dt_fin,vc.dt_demon);
   --
   cursor c_aiie is
    select vw.cpf_cnpj
         , vw.dm_ind_ativ
         , vw.dm_ind_proj
         , vw.dt_vig_ini
         , vw.dt_vig_fim
      from vw_csf_ativ_incen_ie_ecf vw -- VW_CSF_ATIV_INCEN_IE_ECF
     where vw.cpf_cnpj = gv_cnpj
       and vw.dt_vig_ini >= nvl(gd_dt_ini,vw.dt_vig_ini)
       and vw.dt_vig_fim <= nvl(gd_dt_fin,vw.dt_vig_fim);
   --
   cursor c_oeeie is
    select vw.cpf_cnpj
         , vw.ano_ref
         , vw.num_ordem
        from vw_csf_oper_extexportacaoie vw --  VW_CSF_OPER_EXTEXPORTACAOIE
       where vw.cpf_cnpj = gv_cnpj
         and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   cursor c_oeiie is
   select vw.cpf_cnpj
         , vw.ano_ref
         , vw.num_ordem
        from vw_csf_oper_extimportacaoie vw --  VW_CSF_OPER_EXTIMPORTACAOIE
       where vw.cpf_cnpj = gv_cnpj
         and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   -- VW_CSF_IDENT_PART_EXT_IE
   cursor c_ipeie is
   select vw.cpf_cnpj
        , vw.ano_ref
        , vw.cod_part
        , vw.nif
        from vw_csf_ident_part_ext_ie vw
       where vw.cpf_cnpj = gv_cnpj
         and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   -- VW_CSF_COM_ELET_INF_IE
   cursor c_ceiie is
   select vw.cpf_cnpj
        , vw.ano_ref
        , vw.sigla_pais
     from vw_csf_com_elet_inf_ie vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   -- VW_CSF_ROY_RP_BENF_IE
   cursor c_rrbie is
   select vw.cpf_cnpj
        , vw.ano_ref
        , vw.sigla_pais
     from vw_csf_roy_rp_benf_ie vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   -- VW_CSF_REND_REL_RECEB_IE
   cursor c_rrrie is
   select vw.cpf_cnpj
        , vw.ano_ref
        , vw.sigla_pais
     from vw_csf_rend_rel_receb_ie vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   -- VW_CSF_PAG_REL_EXT_IE
   cursor c_preie is
   select vw.cpf_cnpj
        , vw.ano_ref
        , vw.sigla_pais
     from vw_csf_pag_rel_ext_ie vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   -- VW_CSF_PR_EXT_NRESID_IG
   cursor c_penig is
   select vw.cpf_cnpj
        , vw.ano_ref
        , vw.sigla_pais
     from vw_csf_pr_ext_nresid_ig vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   -- VW_CSF_DESCRRECESTABCNAEIG
   cursor c_drecig is
   select vw.cpf_cnpj
        , vw.ano_ref
        , vw.CPF_CNPJ_ESTAB
     from vw_csf_descrrecestabcnaeig vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   --  VW_CSF_VEND_COM_FIM_EXP_IG
   cursor c_vcfeig is
   select vw.cpf_cnpj
        , vw.ano_ref
        , vw.cod_part
     from vw_csf_vend_com_fim_exp_ig vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   -- VW_CSF_DET_EXP_COM_IG
   cursor c_decig is
   select vw.cpf_cnpj
        , vw.ano_ref
        /*, vw.cpf_cnpj_estab*/
        ,vw.cod_part
     from vw_csf_det_exp_com_ig vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   -- VW_CSF_DEM_IR_CSLL_RF_IG
   cursor c_dicrig is
   select vw.cpf_cnpj
        , vw.ano_ref
        , vw.cod_part
     from vw_csf_dem_ir_csll_rf_ig vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   -- VW_CSF_DOAC_CAMP_ELEIT_IG
   cursor c_dceig is
   select vw.cpf_cnpj
        , vw.ano_ref
        , vw.cod_part
     from vw_csf_doac_camp_eleit_ig vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   -- VW_CSF_ATIVO_EXTERIOR_IG
   cursor c_aeig is
   select vw.cpf_cnpj
        , vw.ano_ref
        , vw.CD_TP_ATV_ECF
     from vw_csf_ativo_exterior_ig vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   -- VW_CSF_IDENT_SOCIO_IG
   cursor c_isig is
   select vw.cpf_cnpj
        , vw.cod_part
        , vw.dt_alt_soc
     from vw_csf_ident_socio_ig vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.dt_alt_soc between nvl(gd_dt_ini,vw.dt_alt_soc) and nvl(gd_dt_fin,vw.dt_alt_soc);
   --
   -- VW_CSF_REND_DIRIG_II_IG
   cursor c_rdiiig  is
   select vw.cpf_cnpj
        , vw.ano_ref
        , vw.cod_part
     from vw_csf_rend_dirig_ii_ig vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   -- VW_CSF_PARTAVAMETEQPATRIG
   cursor c_pameqpig  is
   select vw.cpf_cnpj
        , vw.ano_ref
        , vw.cod_part
     from vw_csf_partavameteqpatrig vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   --  VW_CSF_FUNDO_INVEST_IG
   cursor c_fiig  is
   select vw.cpf_cnpj
        , vw.ano_ref
        , vw.cod_part
     from vw_csf_fundo_invest_ig vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   --   VW_CSF_PART_CONS_EMPR_IG
   cursor c_pceig is
   select vw.cpf_cnpj
        , vw.ano_ref
        , vw.cod_part
     from vw_csf_part_cons_empr_ig vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   --  VW_CSF_DADO_SUCESSORA_IG
   cursor c_dsig  is
   select vw.cpf_cnpj
        , vw.ano_ref
        , vw.cod_part
     from vw_csf_dado_sucessora_ig vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   --  VW_CSF_DEM_DIF_AD_INI_IG
   cursor c_ddaiig is
   select vw.cpf_cnpj
        , vw.ano_ref
        , vw.cod_cta
     from vw_csf_dem_dif_ad_ini_ig vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   -- VW_CSF_OUTRA_INF_LR_IG
   cursor c_oilrig is
   select vw.cpf_cnpj
        , vw.ano_ref
     from vw_csf_outra_inf_lr_ig vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   -- VW_CSF_OUTRA_INF_LP_LA_IG
   cursor c_oillig is
   select vw.cpf_cnpj
        , vw.ano_ref
     from vw_csf_outra_inf_lp_la_ig vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   -- VW_CSF_INFO_OPT_PAES_IG
   cursor c_iopig is
   select vw.cpf_cnpj
        , vw.dt_ini
        , vw.dt_fin
     from vw_csf_info_opt_paes_ig vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.dt_ini  >= nvl(gd_dt_ini,vw.dt_ini)
      and vw.dt_fin  <= nvl(gd_dt_fin,vw.dt_fin);
   --
   -- VW_CSF_INF_PER_ANT_IG
   cursor c_ipaig is
   select vw.cpf_cnpj
        , vw.ano_ref
     from vw_csf_inf_per_ant_ig vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   -- VW_CSF_INF_MULT_DECL_PAIS
   cursor c_imdp is
   select vw.cpf_cnpj
        , vw.ano_ref
     from vw_csf_inf_mult_decl_pais vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.ano_ref = nvl(to_char(gd_dt_ini,'yyyy'),vw.ano_ref);
   --
   -- VW_CSF_DECLPAISAPAISOBSADIC
   cursor c_dpapoa is
   select vw.cpf_cnpj
        , vw.dt_ref
     from vw_csf_declpaisapaisobsadic vw
    where vw.cpf_cnpj = gv_cnpj
      and vw.dt_ref between gd_dt_ini and gd_dt_fin;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_lvtd loop
    exit when c_lvtd%notfound or (c_lvtd%notfound) is null;
      --
      vn_fase := 2;
      --
      delete from vw_csf_lanc_vlr_tab_din_ff
       where cpf_cnpj = rec.cpf_cnpj
         and dt_ini   = rec.dt_ini
         and dt_fin   = rec.dt_fim;
      --
      vn_fase := 3;
      --
      delete from vw_csf_conta_part_b
       where cpf_cnpj = rec.cpf_cnpj
         and dt_ini   = rec.dt_ini
         and dt_fin   = rec.dt_fim;
      --
      vn_fase := 4;
      --
      delete from vw_csf_ccr_lanc_part
       where cpf_cnpj = rec.cpf_cnpj
         and dt_ini   = rec.dt_ini
         and dt_fin   = rec.dt_fim;
      --
      vn_fase := 5;
      --
      delete from vw_csf_lcto_part_a_lacs_lalur
       where cpf_cnpj = rec.cpf_cnpj
         and dt_ini   = rec.dt_ini
         and dt_fin   = rec.dt_fim;
      --
      vn_fase := 5;
      --
      delete from vw_csf_lcto_part_a_lacs_lalur
       where cpf_cnpj = rec.cpf_cnpj
         and dt_ini   = rec.dt_ini
         and dt_fin   = rec.dt_fim;
      --
      vn_fase := 5.1;
      --
      delete from vw_csf_lanc_vlr_tab_din
       where cpf_cnpj = rec.cpf_cnpj
         and dt_ini   = rec.dt_ini
         and dt_fim   = rec.dt_fim;
      --
   end loop;
   --
   vn_fase := 6;
   --
   for rec in c_dmc loop
    exit when c_dmc%notfound or (c_dmc%notfound) is null;
      --
      vn_fase := 7;
      --
      delete from vw_csf_dem_livro_caixa
       where cpf_cnpj = rec.cpf_cnpj
         and trunc(dt_demon) = trunc(rec.dt_demon);
      --
      vn_fase := 8;
      --
      delete from vw_csf_dem_livro_caixa_ff
       where cpf_cnpj = rec.cpf_cnpj
         and trunc(dt_demon) = trunc(rec.dt_demon);
      --
   end loop;
   --
   vn_fase := 9;
   --
   for rec in c_aiie loop
    exit when c_aiie%notfound or (c_aiie%notfound) is null;
      --
      vn_fase := 10;
      --
      delete from vw_csf_ativ_incen_ie_ecf
       where cpf_cnpj    = rec.cpf_cnpj
         and dm_ind_ativ = rec.dm_ind_ativ
         and dm_ind_proj = rec.dm_ind_proj
         and trunc(dt_vig_ini)  = trunc(rec.dt_vig_ini)
         and trunc(dt_vig_fim)  = trunc(rec.dt_vig_fim);
      --
      vn_fase := 11;
      --
      delete from vw_csf_ativ_incen_ie_ecf_ff
       where cpf_cnpj    = rec.cpf_cnpj
         and dm_ind_ativ = rec.dm_ind_ativ
         and dm_ind_proj = rec.dm_ind_proj
         and trunc(dt_vig_ini)  = trunc(rec.dt_vig_ini)
         and trunc(dt_vig_fim)  = trunc(rec.dt_vig_fim);
      --
   end loop;
   --
   vn_fase := 12;
   --
   for rec in c_oeeie loop
    exit when c_oeeie%notfound or (c_oeeie%notfound) is null;
      --
      vn_fase := 13;
      --
      delete from vw_csf_oper_extexportacaoie
       where cpf_cnpj   = rec.cpf_cnpj
         and ano_ref    = rec.ano_ref
         and num_ordem  = rec.num_ordem;
      --
      vn_fase := 14;
      --
      delete from vw_csf_oper_extexportacaoie_ff
       where cpf_cnpj   = rec.cpf_cnpj
         and ano_ref    = rec.ano_ref
         and num_ordem  = rec.num_ordem;
      --
      vn_fase := 15;
      --
      delete from vw_csf_oper_ext_contr_exp_ie
       where cpf_cnpj   = rec.cpf_cnpj
         and ano_ref    = rec.ano_ref
         and num_ordem  = rec.num_ordem;
      --
   end loop;
   --
   vn_fase := 16;
   --
   for rec in c_oeiie loop
    exit when c_oeiie%notfound or (c_oeiie%notfound) is null;
      --
      vn_fase := 17;
      --
      delete from vw_csf_oper_extimportacaoie
       where cpf_cnpj   = rec.cpf_cnpj
         and ano_ref    = rec.ano_ref
         and num_ordem  = rec.num_ordem;
      --
      vn_fase := 18;
      --
      delete from vw_csf_oper_extimportacaoie_ff
       where cpf_cnpj   = rec.cpf_cnpj
         and ano_ref    = rec.ano_ref
         and num_ordem  = rec.num_ordem;
      --
      vn_fase := 19;
      --
      delete from vw_csf_oper_ext_contr_imp_ie
       where cpf_cnpj   = rec.cpf_cnpj
         and ano_ref    = rec.ano_ref
         and num_ordem  = rec.num_ordem;
      --
   end loop;
   --
   vn_fase := 20;
   --
   for rec in c_ipeie loop
    exit when c_ipeie%notfound or (c_ipeie%notfound) is null;
      --
      vn_fase := 21;
      --
      delete from vw_csf_ident_part_ext_ie
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part
         and nif      = rec.nif;
      --
      vn_fase := 22;
      --
      delete from vw_csf_ident_part_ext_ie_ff
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part
         and nif      = rec.nif;
      --
      vn_fase := 23;
      --
      delete from vw_csf_part_ext_resul_apur_ie
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part
         and nif      = rec.nif;
      --
      vn_fase := 24;
      --
      delete from vw_csf_dem_resul_imp_ext_ie
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part
         and nif      = rec.nif;
      --
      vn_fase := 25;
      --
      delete from vw_csf_dem_re_ex_auf_col_rc_ie
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part
         and nif      = rec.nif;
      --
      vn_fase := 26;
      --
      delete from vw_csf_dem_cons_ext_contr_ie
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part
         and nif      = rec.nif;
      --
      vn_fase := 27;
      --
      delete from vw_csf_dem_pre_acm_ext_cont_ie
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part
         and nif      = rec.nif;
      --
      vn_fase := 28;
      --
      delete from vw_csf_demrendapextcontrie
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part
         and nif      = rec.nif;
      --
      vn_fase := 29;
      --
      delete from vw_csf_dem_est_soc_ext_cont_ie
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part
         and nif      = rec.nif;
      --
   end loop;
   --
   vn_fase := 30;
   --
   for rec in c_ceiie loop
    exit when c_ceiie%notfound or (c_ceiie%notfound) is null;
      --
      vn_fase := 31;
      --
      delete from vw_csf_com_elet_inf_ie
       where cpf_cnpj   = rec.cpf_cnpj
         and ano_ref    = rec.ano_ref
         and sigla_pais = rec.sigla_pais;
      --
      vn_fase := 32;
      --
      delete from vw_csf_com_elet_inf_ie_ff
       where cpf_cnpj   = rec.cpf_cnpj
         and ano_ref    = rec.ano_ref
         and sigla_pais = rec.sigla_pais;
      --
   end loop;
   --
   vn_fase := 33;
   --
   for rec in c_rrbie loop
    exit when c_rrbie%notfound or (c_rrbie%notfound) is null;
      --
      vn_fase := 34;
      --
      delete from vw_csf_roy_rp_benf_ie
       where cpf_cnpj   = rec.cpf_cnpj
         and ano_ref    = rec.ano_ref
         and sigla_pais = rec.sigla_pais;
      --
      vn_fase := 35;
      --
      delete from vw_csf_roy_rp_benf_ie_ff
       where cpf_cnpj   = rec.cpf_cnpj
         and ano_ref    = rec.ano_ref
         and sigla_pais = rec.sigla_pais;
      --
   end loop;
   --
   vn_fase := 36;
   --
   for rec in c_rrrie loop
    exit when c_rrrie%notfound or (c_rrrie%notfound) is null;
      --
      vn_fase := 37;
      --
      delete from vw_csf_rend_rel_receb_ie
       where cpf_cnpj   = rec.cpf_cnpj
         and ano_ref    = rec.ano_ref
         and sigla_pais = rec.sigla_pais;
      --
      vn_fase := 38;
      --
      delete from vw_csf_rend_rel_receb_ie_ff
       where cpf_cnpj   = rec.cpf_cnpj
         and ano_ref    = rec.ano_ref
         and sigla_pais = rec.sigla_pais;
      --
   end loop;
   --
   vn_fase := 40;
   --
   for rec in c_preie loop
    exit when c_preie%notfound or (c_preie%notfound) is null;
      --
      vn_fase := 41;
      --
      delete from vw_csf_pag_rel_ext_ie
       where cpf_cnpj   = rec.cpf_cnpj
         and ano_ref    = rec.ano_ref
         and sigla_pais = rec.sigla_pais;
      --
      vn_fase := 42;
      --
      delete from vw_csf_pag_rel_ext_ie_ff
       where cpf_cnpj   = rec.cpf_cnpj
         and ano_ref    = rec.ano_ref
         and sigla_pais = rec.sigla_pais;
      --
   end loop;
   --
   vn_fase := 43;
   --
   for rec in c_penig loop
    exit when c_penig%notfound or (c_penig%notfound) is null;
      --
      vn_fase := 44;
      --
      delete from vw_csf_pr_ext_nresid_ig
       where cpf_cnpj   = rec.cpf_cnpj
         and ano_ref    = rec.ano_ref
         and sigla_pais = rec.sigla_pais;
      --
      vn_fase := 42;
      --
      delete from vw_csf_pr_ext_nresid_ig_ff
       where cpf_cnpj   = rec.cpf_cnpj
         and ano_ref    = rec.ano_ref
         and sigla_pais = rec.sigla_pais;
      --
   end loop;
   --
   vn_fase := 43;
   --
   for rec in c_drecig loop
    exit when c_drecig%notfound or (c_drecig%notfound) is null;
      --
      vn_fase := 44;
      --
      delete from vw_csf_descrrecestabcnaeig
       where cpf_cnpj        = rec.cpf_cnpj
         and ano_ref         = rec.ano_ref
         and cpf_cnpj_estab  = rec.cpf_cnpj_estab;
      --
      vn_fase := 45;
      --
      delete from vw_csf_descrrecestabcnaeig_ff
       where cpf_cnpj        = rec.cpf_cnpj
         and ano_ref         = rec.ano_ref
         and cpf_cnpj_estab  = rec.cpf_cnpj_estab;
      --
   end loop;
   --
   vn_fase := 46;
   --
   for rec in c_vcfeig loop
    exit when c_vcfeig%notfound or (c_vcfeig%notfound) is null;
      --
      vn_fase := 47;
      --
      delete from vw_csf_vend_com_fim_exp_ig
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part;
      --
      vn_fase := 48;
      --
      delete from vw_csf_vend_com_fim_exp_ig_ff
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part;
      --
   end loop;
   --
   vn_fase := 49;
   --
   for rec in c_decig loop
    exit when c_decig%notfound or (c_decig%notfound) is null;
      --
      vn_fase := 50;
      --
      delete from vw_csf_det_exp_com_ig
       where cpf_cnpj       = rec.cpf_cnpj
         and ano_ref        = rec.ano_ref
         /*and cpf_cnpj_estab = rec.cpf_cnpj_estab*/
         and cod_part       = rec.cod_part;
      --
      vn_fase := 51;
      --
      delete from vw_csf_det_exp_com_ig_ff
       where cpf_cnpj       = rec.cpf_cnpj
         and ano_ref        = rec.ano_ref
         /*and cpf_cnpj_estab = rec.cpf_cnpj_estab*/
         and cod_part       = rec.cod_part;
      --
   end loop;
   --
   vn_fase := 52;
   --
   for rec in c_dicrig loop
    exit when c_dicrig%notfound or (c_dicrig%notfound) is null;
      --
      vn_fase := 53;
      --
      delete from vw_csf_dem_ir_csll_rf_ig
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part;
      --
      vn_fase := 54;
      --
      delete from vw_csf_dem_ir_csll_rf_ig_ff
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part;
      --
   end loop;
   --
   vn_fase := 55;
   --
   for rec in c_dceig loop
    exit when c_dceig%notfound or (c_dceig%notfound) is null;
      --
      vn_fase := 56;
      --
      delete from vw_csf_doac_camp_eleit_ig
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part;
      --
      vn_fase := 57;
      --
      delete from vw_csf_doac_camp_eleit_ig_ff
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part;
      --
   end loop;
   --
   vn_fase := 58;
   --
   for rec in c_aeig loop
    exit when c_aeig%notfound or (c_aeig%notfound) is null;
      --
      vn_fase := 59;
      --
      delete from vw_csf_ativo_exterior_ig
       where cpf_cnpj      = rec.cpf_cnpj
         and ano_ref       = rec.ano_ref
         and cd_tp_atv_ecf = rec.cd_tp_atv_ecf;
      --
      vn_fase := 60;
      --
      delete from vw_csf_ativo_exterior_ig_ff
       where cpf_cnpj      = rec.cpf_cnpj
         and ano_ref       = rec.ano_ref
         and cd_tp_atv_ecf = rec.cd_tp_atv_ecf;
      --
   end loop;
   --
   vn_fase := 61;
   --
   for rec in c_isig loop
    exit when c_isig%notfound or (c_isig%notfound) is null;
      --
      vn_fase := 62;
      --
      delete from vw_csf_ident_socio_ig
       where cpf_cnpj   = rec.cpf_cnpj
         and cod_part = rec.cod_part
         and dt_alt_soc = rec.dt_alt_soc;
      --
      vn_fase := 63;
      --
      delete from vw_csf_ident_socio_ig_ff
       where cpf_cnpj   = rec.cpf_cnpj
         and cod_part   = rec.cod_part
         and dt_alt_soc = rec.dt_alt_soc;
      --
   end loop;
   --
   vn_fase := 64;
   --
   for rec in c_rdiiig loop
    exit when c_rdiiig%notfound or (c_rdiiig%notfound) is null;
      --
      vn_fase := 65;
      --
      delete from vw_csf_rend_dirig_ii_ig
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part;
      --
      vn_fase := 65;
      --
      delete from vw_csf_rend_dirig_ii_ig_ff
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part;
      --
   end loop;
   --
   vn_fase := 66;
   --
   for rec in c_pameqpig loop
    exit when c_pameqpig%notfound or (c_pameqpig%notfound) is null;
      --
      vn_fase := 67;
      --
      delete from vw_csf_partavameteqpatrig
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part;
      --
      vn_fase := 68;
      --
      delete from vw_csf_partavameteqpatrig_ff
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part;
      --
   end loop;
   --
   vn_fase := 69;
   --
   for rec in c_fiig loop
    exit when c_fiig%notfound or (c_fiig%notfound) is null;
      --
      vn_fase := 70;
      --
      delete from vw_csf_fundo_invest_ig
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part;
      --
      vn_fase := 71;
      --
      delete from vw_csf_fundo_invest_ig_ff
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part;
      --
   end loop;
   --
   vn_fase := 72;
   --
   for rec in c_pceig loop
    exit when c_pceig%notfound or (c_pceig%notfound) is null;
      --
      vn_fase := 70;
      --
      delete from vw_csf_part_cons_empr_ig
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part;
      --
      vn_fase := 71;
      --
      delete from vw_csf_part_cons_empr_ig_ff
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part;
      --
      vn_fase := 71.2;
      --
      delete from vw_csf_det_part_cons_empr_ig
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part;
      --
   end loop;
   --
   vn_fase := 72;
   --
   for rec in c_dsig loop
    exit when c_dsig%notfound or (c_dsig%notfound) is null;
      --
      vn_fase := 73;
      --
      delete from vw_csf_dado_sucessora_ig
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part;
      --
      vn_fase := 74;
      --
      delete from vw_csf_dado_sucessora_ig_ff
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_part = rec.cod_part;
      --
   end loop;
   --
   vn_fase := 75;
   --
   for rec in c_ddaiig loop
    exit when c_ddaiig%notfound or (c_ddaiig%notfound) is null;
      --
      vn_fase := 76;
      --
      delete from vw_csf_dem_dif_ad_ini_ig
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_cta  = rec.cod_cta;
      --
      vn_fase := 77;
      --
      delete from vw_csf_dem_dif_ad_ini_ig_ff
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref
         and cod_cta = rec.cod_cta;
      --
   end loop;
   --
   vn_fase := 78;
   --
   for rec in c_oilrig loop
    exit when c_oilrig%notfound or (c_oilrig%notfound) is null;
      --
      vn_fase := 79;
      --
      delete from vw_csf_outra_inf_lr_ig
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref;
      --
      vn_fase := 80;
      --
      delete from vw_csf_outra_inf_lr_ig_ff
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref;
      --
   end loop;
   --
   vn_fase := 84;
   --
   for rec in c_oillig loop
    exit when c_oillig%notfound or (c_oillig%notfound) is null;
      --
      vn_fase := 84.1;
      --
      delete from vw_csf_outra_inf_lp_la_ig      --VW_CSF_OUTRA_INF_LP_LA_IG
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref;
      --
      vn_fase := 84.2;
      --
      delete from vw_csf_outra_inf_lp_la_ig_ff
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref;
      --
   end loop;
   --
   for rec in c_iopig loop
    exit when c_iopig%notfound or (c_iopig%notfound) is null;
      --
      vn_fase := 85;
      --
      delete from vw_csf_info_opt_paes_ig
       where cpf_cnpj = rec.cpf_cnpj
         and dt_ini   = rec.dt_ini
         and dt_fin   = rec.dt_fin;
      --
      vn_fase := 86;
      --
      delete from vw_csf_info_opt_paes_ig_ff
       where cpf_cnpj = rec.cpf_cnpj
         and dt_ini   = rec.dt_ini
         and dt_fin   = rec.dt_fin;
      --
   end loop;
   --
   vn_fase := 87;
   --
   for rec in c_ipaig loop
    exit when c_ipaig%notfound or (c_ipaig%notfound) is null;
      --
      vn_fase := 88;
      --
      delete from vw_csf_inf_per_ant_ig
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref;
      --
      vn_fase := 89;
      --
      delete from vw_csf_inf_per_ant_ig_ff
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref;
      --
   end loop;
   --
   vn_fase := 90;
   --
   for rec in c_imdp loop
    exit when c_imdp%notfound or (c_imdp%notfound) is null;
      --
      vn_fase := 91;
      --
      delete from vw_csf_inf_mult_decl_pais
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref;
      --
      vn_fase := 92;
      --
      delete from vw_csf_inf_mult_decl_pais_ff
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref;
      --
      vn_fase := 93;
      --
      delete from vw_csf_decl_pais_a_pais
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref;
      --
      vn_fase := 94;
      --
      delete from vw_csf_decl_pais_pais_ent_int
       where cpf_cnpj = rec.cpf_cnpj
         and ano_ref  = rec.ano_ref;
      --
   end loop;
   --
   vn_fase := 95;
   --
   for rec in c_dpapoa loop
    exit when c_dpapoa%notfound or (c_dpapoa%notfound) is null;
      --
      vn_fase := 96;
      --
      delete from vw_csf_declpaisapaisobsadic
       where cpf_cnpj = rec.cpf_cnpj
         and dt_ref   = rec.dt_ref;
      --
   end loop;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_secf fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_secf;


----------------------------------------------------------------
--|PROCESSO QUE LIMPA A INTEGRAÇÃO DE INVENTARIO = 2|--
----------------------------------------------------------------
/*Leiaute_Views_Integracao_Inventario_V1_6*/
procedure pkb_limpa_inventario is
   --
   vn_fase number := 0;
   --
   cursor c_inv is
      select vc.cpf_cnpj
           , vc.cod_item
           , vc.dt_inventario
        from vw_csf_inventario vc
       where vc.cpf_cnpj = gv_cnpj
         --and vc.dt_ref between nvl(gd_dt_ini, vc.dt_ref) and nvl(gd_dt_fin, vc.dt_ref) --#75492
         ;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_inv loop
      exit when c_inv%notfound or (c_inv%notfound) is null;
      --
      delete
        from vw_csf_inventario_ff vc
       where vc.cpf_cnpj      = rec.cpf_cnpj
         and vc.cod_item      = rec.cod_item
         and vc.dt_inventario = rec.dt_inventario;
      --
      vn_fase := 3;
      --
      delete
        from vw_csf_invent_cst vc
       where vc.cpf_cnpj      = rec.cpf_cnpj
         and vc.cod_item      = rec.cod_item
         and vc.dt_inventario = rec.dt_inventario;
      --
      vn_fase := 4;
      --
      --#75492
      delete 
        from vw_csf_invent_inf_comp_merc_st vc
       where vc.cpf_cnpj      = rec.cpf_cnpj
         and vc.cod_item      = rec.cod_item
         and vc.dt_inventario = rec.dt_inventario;
      --
   end loop;
   --
   delete
     from vw_csf_inventario vc
    where vc.cpf_cnpj = gv_cnpj
     -- and vc.dt_ref between nvl(gd_dt_ini, vc.dt_ref) and nvl(gd_dt_fin, vc.dt_ref) --#75492
      ;
   --
   vn_fase := 5;
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_inventario fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_inventario;

----------------------------------------------------------------
--|PROCESSO QUE LIMPA INTEGRAÇÃO DE CUPOM FISCAL = 3|--
----------------------------------------------------------------
/*Leiaute_Views_Integracao_Cupom_Fiscal_V1_4*/
procedure pkb_limpa_cupom_fiscal is
   --
   vn_fase number := 0;
   --
   cursor c_dados is
      select vc.*
        from vw_csf_equip_ecf vc
       where vc.cpf_cnpj_emit = gv_cnpj;
   --
   cursor c_red_z( ev_cpf_cnpj_emit in varchar2
                 , ev_cod_mod       in varchar2
                 , ev_ecf_mod       in varchar2
                 , ev_ecf_fab       in varchar2
                 , en_ecf_cx        in number )
     is
     select vc.cpf_cnpj_emit
          , vc.cod_mod
          , vc.ecf_mod
          , vc.ecf_fab
          , vc.ecf_cx
          , vc.dt_doc
       from vw_csf_reducao_z_ecf vc
      where vc.cpf_cnpj_emit = ev_cpf_cnpj_emit
        and vc.cod_mod       = ev_cod_mod
        and vc.ecf_mod       = ev_ecf_mod
        and vc.ecf_fab       = ev_ecf_fab
        and vc.ecf_cx        = en_ecf_cx
        and vc.dt_doc between nvl(gd_dt_ini, vc.dt_doc) and nvl(gd_dt_fin, vc.dt_doc);
   --
   cursor c_tot_parc( ev_cpf_cnpj_emit in varchar2
                    , ev_cod_mod       in varchar2
                    , ev_ecf_mod       in varchar2
                    , ev_ecf_fab       in varchar2
                    , en_ecf_cx        in number
                    , ed_dt_doc        in date )
      is
      select vc.cpf_cnpj_emit
           , vc.cod_mod
           , vc.ecf_mod
           , vc.ecf_fab
           , vc.ecf_cx
           , vc.dt_doc
           , vc.cod_tot
        from vw_csf_tot_parc_red_z_ecf vc
       where vc.cpf_cnpj_emit = ev_cpf_cnpj_emit
         and vc.cod_mod       = ev_cod_mod
         and vc.ecf_mod       = ev_ecf_mod
         and vc.ecf_fab       = ev_ecf_fab
         and vc.ecf_cx        = en_ecf_cx
         and vc.dt_doc        = ed_dt_doc;
   --
   cursor c_doc_fiscal( ev_cpf_cnpj_emit in varchar2
                      , ev_cod_mod       in varchar2
                      , ev_ecf_mod       in varchar2
                      , ev_ecf_fab       in varchar2
                      , en_ecf_cx        in number
                      , ed_dt_doc        in date )
      is
      select vc.cpf_cnpj_emit
           , vc.cod_mod
           , vc.ecf_mod
           , vc.ecf_fab
           , vc.ecf_cx
           , vc.dt_doc
           , vc.num_doc
        from vw_csf_doc_fiscal_emit_ecf vc
       where vc.cpf_cnpj_emit = ev_cpf_cnpj_emit
         and vc.cod_mod       = ev_cod_mod
         and vc.ecf_mod       = ev_ecf_mod
         and vc.ecf_fab       = ev_ecf_fab
         and vc.ecf_cx        = en_ecf_cx
         and vc.dt_doc        = ed_dt_doc;
   --
   cursor c_res_dia( ev_cpf_cnpj_emit in varchar2
                   , ev_cod_mod       in varchar2
                   , ev_ecf_mod       in varchar2
                   , ev_ecf_fab       in varchar2
                   , en_ecf_cx        in number
                   , ed_dt_doc        in date )
      is
      select vc.cpf_cnpj_emit
           , vc.cod_mod
           , vc.ecf_mod
           , vc.ecf_fab
           , vc.ecf_cx
           , vc.dt_doc
           , vc.cst_pis
           , vc.cod_item
        from vw_csf_res_dia_doc_ecf_pis vc
       where vc.cpf_cnpj_emit = ev_cpf_cnpj_emit
         and vc.cod_mod       = ev_cod_mod
         and vc.ecf_mod       = ev_ecf_mod
         and vc.ecf_fab       = ev_ecf_fab
         and vc.ecf_cx        = en_ecf_cx
         and vc.dt_doc        = ed_dt_doc;
   --
   cursor c_res_dia_doc( ev_cpf_cnpj_emit in varchar2
                       , ev_cod_mod       in varchar2
                       , ev_ecf_mod       in varchar2
                       , ev_ecf_fab       in varchar2
                       , en_ecf_cx        in number
                       , ed_dt_doc        in date )
      is
      select vc.cpf_cnpj_emit
           , vc.cod_mod
           , vc.ecf_mod
           , vc.ecf_fab
           , vc.ecf_cx
           , vc.dt_doc
           , vc.cst_cofins
           , vc.cod_item
        from vw_csf_res_dia_doc_ecf_cofins vc
       where vc.cpf_cnpj_emit = ev_cpf_cnpj_emit
         and vc.cod_mod       = ev_cod_mod
         and vc.ecf_mod       = ev_ecf_mod
         and vc.ecf_fab       = ev_ecf_fab
         and vc.ecf_cx        = en_ecf_cx
         and vc.dt_doc        = ed_dt_doc;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      delete
        from vw_csf_equipecf_ff vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.cod_mod       = rec.cod_mod
         and vc.ecf_mod       = rec.ecf_mod
         and vc.ecf_fab       = rec.ecf_fab
         and vc.ecf_cx        = rec.ecf_cx;
      --
      vn_fase := 2;
      --
      for rec2 in c_red_z(rec.cpf_cnpj_emit, rec.cod_mod, rec.ecf_mod, rec.ecf_fab, rec.ecf_cx) loop
         exit when c_red_z%notfound or (c_red_z%notfound) is null;
         --
         for rec3 in c_tot_parc(rec2.cpf_cnpj_emit, rec2.cod_mod, rec2.ecf_mod, rec2.ecf_fab, rec2.ecf_cx, rec2.dt_doc) loop
            exit when c_tot_parc%notfound or (c_tot_parc%notfound) is null;
            --
            delete
              from vw_csf_tot_parc_red_z_ecf_comp vc
             where vc.cpf_cnpj_emit = rec3.cpf_cnpj_emit
               and vc.cod_mod       = rec3.cod_mod
               and vc.ecf_mod       = rec3.ecf_mod
               and vc.ecf_fab       = rec3.ecf_fab
               and vc.ecf_cx        = rec3.ecf_cx
               and vc.dt_doc        = rec3.dt_doc
               and vc.cod_tot       = rec3.cod_tot;
            --
            vn_fase := 3;
            --
            delete
              from vw_csf_res_it_mov_dia_ecf vc
             where vc.cpf_cnpj_emit = rec3.cpf_cnpj_emit
               and vc.cod_mod       = rec3.cod_mod
               and vc.ecf_mod       = rec3.ecf_mod
               and vc.ecf_fab       = rec3.ecf_fab
               and vc.ecf_cx        = rec3.ecf_cx
               and vc.dt_doc        = rec3.dt_doc
               and vc.cod_tot       = rec3.cod_tot;
            --
         end loop;
         --
         vn_fase := 4;
         --
         delete
           from vw_csf_tot_parc_red_z_ecf vc
          where vc.cpf_cnpj_emit = rec2.cpf_cnpj_emit
            and vc.cod_mod       = rec2.cod_mod
            and vc.ecf_mod       = rec2.ecf_mod
            and vc.ecf_fab       = rec2.ecf_fab
            and vc.ecf_cx        = rec2.ecf_cx
            and vc.dt_doc        = rec2.dt_doc;
         --
         vn_fase := 5;
         --
         for rec4 in c_doc_fiscal(rec2.cpf_cnpj_emit, rec2.cod_mod, rec2.ecf_mod, rec2.ecf_fab, rec2.ecf_cx, rec2.dt_doc) loop
            exit when c_doc_fiscal%notfound or (c_doc_fiscal%notfound) is null;
            --
            vn_fase := 6;
            --
            delete
              from vw_csf_it_doc_fiscal_emit_ecf vc
             where vc.cpf_cnpj_emit = rec4.cpf_cnpj_emit
               and vc.cod_mod       = rec4.cod_mod
               and vc.ecf_mod       = rec4.ecf_mod
               and vc.ecf_fab       = rec4.ecf_fab
               and vc.ecf_cx        = rec4.ecf_cx
               and vc.dt_doc        = rec4.dt_doc
               and vc.num_doc       = rec4.num_doc;
            --
            vn_fase := 7;
            --
         end loop;
         --
         vn_fase := 8;
         --
         delete
           from vw_csf_doc_fiscal_emit_ecf vc
          where vc.cpf_cnpj_emit = rec2.cpf_cnpj_emit
            and vc.cod_mod       = rec2.cod_mod
            and vc.ecf_mod       = rec2.ecf_mod
            and vc.ecf_fab       = rec2.ecf_fab
            and vc.ecf_cx        = rec2.ecf_cx
            and vc.dt_doc        = rec2.dt_doc;
         --
         vn_fase := 9;
         --
         for rec5 in c_res_dia(rec2.cpf_cnpj_emit, rec2.cod_mod, rec2.ecf_mod, rec2.ecf_fab, rec2.ecf_cx, rec2.dt_doc) loop
            exit when c_res_dia%notfound or (c_res_dia%notfound) is null;
            --
            delete
              from vw_csf_resdiadocecfpis_ff vc
             where vc.cpf_cnpj_emit = rec5.cpf_cnpj_emit
               and vc.cod_mod       = rec5.cod_mod
               and vc.ecf_mod       = rec5.ecf_mod
               and vc.ecf_fab       = rec5.ecf_fab
               and vc.ecf_cx        = rec5.ecf_cx
               and vc.dt_doc        = rec5.dt_doc
               and vc.cst_pis       = rec5.cst_pis
               and nvl(vc.cod_item,' ') = nvl(rec5.cod_item,' ');
            --
            vn_fase := 10;
            --
         end loop;
         --
         delete
           from vw_csf_res_dia_doc_ecf_pis vc
          where vc.cpf_cnpj_emit = rec2.cpf_cnpj_emit
            and vc.cod_mod       = rec2.cod_mod
            and vc.ecf_mod       = rec2.ecf_mod
            and vc.ecf_fab       = rec2.ecf_fab
            and vc.ecf_cx        = rec2.ecf_cx
            and vc.dt_doc        = rec2.dt_doc;
         --
         vn_fase := 11;
         --
         for rec6 in c_res_dia_doc(rec2.cpf_cnpj_emit, rec2.cod_mod, rec2.ecf_mod, rec2.ecf_fab, rec2.ecf_cx, rec2.dt_doc) loop
            exit when c_res_dia_doc%notfound or (c_res_dia_doc%notfound) is null;
            --
            delete
              from vw_csf_resdiadocecfcofins_ff vc
             where vc.cpf_cnpj_emit     = rec6.cpf_cnpj_emit
               and vc.cod_mod           = rec6.cod_mod
               and vc.ecf_mod           = rec6.ecf_mod
               and vc.ecf_fab           = rec6.ecf_fab
               and vc.ecf_cx            = rec6.ecf_cx
               and vc.dt_doc            = rec6.dt_doc
               and vc.cst_cofins        = rec6.cst_cofins
               and nvl(vc.cod_item,' ') = nvl(rec6.cod_item,' ');
            --
            vn_fase := 12;
            --
         end loop;
         --
         delete
           from vw_csf_res_dia_doc_ecf_cofins vc
          where vc.cpf_cnpj_emit = rec2.cpf_cnpj_emit
            and vc.cod_mod       = rec2.cod_mod
            and vc.ecf_mod       = rec2.ecf_mod
            and vc.ecf_fab       = rec2.ecf_fab
            and vc.ecf_cx        = rec2.ecf_cx
            and vc.dt_doc        = rec2.dt_doc;
         --
         vn_fase := 13;
         --
      end loop;
      --
      delete
        from vw_csf_reducao_z_ecf vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.cod_mod       = rec.cod_mod
         and vc.ecf_mod       = rec.ecf_mod
         and vc.ecf_fab       = rec.ecf_fab
         and vc.ecf_cx        = rec.ecf_cx;
      --
      vn_fase := 14;
      --
      delete
        from vw_csf_equip_ecf_proc_ref vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.cod_mod       = rec.cod_mod
         and vc.ecf_mod       = rec.ecf_mod
         and vc.ecf_fab       = rec.ecf_fab
         and vc.ecf_cx        = rec.ecf_cx;
      --
      vn_fase := 15;
      --
   end loop;
   --
   vn_fase := 16;
   --
   delete
     from vw_csf_equip_ecf vc
    where vc.cpf_cnpj_emit = gv_cnpj;
   --
   vn_fase := 17;
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_cupom_fiscal fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_cupom_fiscal;

---------------------------------------------------------------------
--|PROCESSO QUE LIMPA INTEGRAÇÃO DE CONHECIMENTO DE TRASNPORTE = 4|--
---------------------------------------------------------------------
/*Leiaute_Views_Integracao_Conhec_Transp_V1_14*/
procedure pkb_limpa_conhec_transp is
   --
   vn_fase number := 0;
   --
   cursor c_ct_efd is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.subserie
           , vc.nro_nf
        from vw_csf_conhec_transp_efd vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and ( ( vc.dm_ind_emit = 0 and trunc(vc.dt_emiss) between nvl(gd_dt_ini, vc.dt_emiss) and nvl(gd_dt_fin, vc.dt_emiss) )
                or
               ( vc.dm_ind_emit = 1 and trunc(nvl(vc.dt_sai_ent, vc.dt_emiss))
                                       between nvl(nvl(gd_dt_ini, vc.dt_sai_ent), vc.dt_emiss)
                                           and nvl(nvl(gd_dt_fin, vc.dt_sai_ent), vc.dt_emiss) ) )
      order by 1 asc;
   --
   cursor c_reg_conhe( ev_cpf_cnpj_emit in varchar2
                     , en_dm_ind_emit   in number
                     , en_dm_ind_oper   in number
                     , ev_cod_part      in varchar2
                     , ev_cod_mod       in varchar2
                     , ev_serie         in varchar2
                     , en_subserie      in number
                     , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.subserie
           , vc.nro_nf
           , vc.cst_icms
           , vc.dm_orig_merc
           , vc.cfop
           , vc.aliq_icms
        from vw_csf_reg_conhec_transp_efd vc
       where vc.cpf_cnpj_emit  = ev_cpf_cnpj_emit
         and vc.dm_ind_emit    = en_dm_ind_emit
         and vc.dm_ind_oper    = en_dm_ind_oper
         and vc.cod_part       = ev_cod_part
         and vc.cod_mod        = ev_cod_mod
         and vc.serie          = ev_serie
         and nvl(vc.subserie,0)= nvl(en_subserie,0)
         and vc.nro_nf         = en_nro_nf
      order by 1 asc;
   --
   cursor c_ct_comp( ev_cpf_cnpj_emit in varchar2
                   , en_dm_ind_emit   in number
                   , en_dm_ind_oper   in number
                   , ev_cod_part      in varchar2
                   , ev_cod_mod       in varchar2
                   , ev_serie         in varchar2
                   , en_subserie      in number
                   , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.subserie
           , vc.nro_nf
           , vc.cst_pis
        from vw_csf_ct_comp_doc_pis_efd vc
       where vc.cpf_cnpj_emit   = ev_cpf_cnpj_emit
         and vc.dm_ind_emit     = en_dm_ind_emit
         and vc.dm_ind_oper     = en_dm_ind_oper
         and vc.cod_part        = ev_cod_part
         and vc.cod_mod         = ev_cod_mod
         and vc.serie           = ev_serie
         and nvl(vc.subserie,0) = nvl(en_subserie,0)
         and vc.nro_nf          = en_nro_nf
   order by 1 asc;
   --
   cursor c_ctinfor( ev_cpf_cnpj_emit in varchar2
                   , en_dm_ind_emit   in number
                   , en_dm_ind_oper   in number
                   , ev_cod_part      in varchar2
                   , ev_cod_mod       in varchar2
                   , ev_serie         in varchar2
                   , en_subserie      in number
                   , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.subserie
           , vc.nro_nf
           , vc.cod_obs
        from vw_csf_ctinfor_fiscal_efd vc
       where vc.cpf_cnpj_emit   = ev_cpf_cnpj_emit
         and vc.dm_ind_emit     = en_dm_ind_emit
         and vc.dm_ind_oper     = en_dm_ind_oper
         and vc.cod_part        = ev_cod_part
         and vc.cod_mod         = ev_cod_mod
         and vc.serie           = ev_serie
         and nvl(vc.subserie,0) = nvl(en_subserie,0)
         and vc.nro_nf          = en_nro_nf
      order by 1 asc;
   --
   cursor c_comp_doc( ev_cpf_cnpj_emit in varchar2
                    , en_dm_ind_emit   in number
                    , en_dm_ind_oper   in number
                    , ev_cod_part      in varchar2
                    , ev_cod_mod       in varchar2
                    , ev_serie         in varchar2
                    , en_subserie      in number
                    , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.subserie
           , vc.nro_nf
           , vc.cst_cofins
        from vw_csf_ct_comp_doc_cofins_efd vc
       where vc.cpf_cnpj_emit   = ev_cpf_cnpj_emit
         and vc.dm_ind_emit     = en_dm_ind_emit
         and vc.dm_ind_oper     = en_dm_ind_oper
         and vc.cod_part        = ev_cod_part
         and vc.cod_mod         = ev_cod_mod
         and vc.serie           = ev_serie
         and nvl(vc.subserie,0) = nvl(en_subserie,0)
         and vc.nro_nf          = en_nro_nf
      order by 1 asc;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_ct_efd loop
      exit when c_ct_efd%notfound or (c_ct_efd%notfound) is null;
      --
      delete
        from vw_csf_conhec_transp_efd_ff vc
       where vc.cpf_cnpj_emit   = rec.cpf_cnpj_emit
         and vc.dm_ind_emit     = rec.dm_ind_emit
         and vc.dm_ind_oper     = rec.dm_ind_oper
         and vc.cod_part        = rec.cod_part
         and vc.cod_mod         = rec.cod_mod
         and vc.serie           = rec.serie
         and nvl(vc.subserie,0) = nvl(rec.subserie,0)
         and vc.nro_nf          = rec.nro_nf;
      --
      vn_fase := 2;
      --
      for rec2 in c_reg_conhe( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod, rec.serie
                             , rec.subserie,  rec.nro_nf ) loop
         exit when c_reg_conhe%notfound or (c_reg_conhe%notfound) is null;
         --
         delete
           from vw_csf_regconhectransp_efd_ff vc
          where vc.cpf_cnpj_emit        = rec2.cpf_cnpj_emit
            and vc.dm_ind_emit          = rec2.dm_ind_emit
            and vc.dm_ind_oper          = rec2.dm_ind_oper
            and vc.cod_part             = rec2.cod_part
            and vc.cod_mod              = rec2.cod_mod
            and vc.serie                = rec2.serie
            and nvl(vc.subserie,0)      = nvl(rec2.subserie,0)
            and vc.nro_nf               = rec2.nro_nf
            and nvl(vc.cst_icms,' ')    = nvl(rec2.cst_icms,' ')
            and nvl(vc.dm_orig_merc,-1) = nvl(rec2.dm_orig_merc,-1)
            and nvl(vc.cfop,-1)         = nvl(rec2.cfop,-1)
            and nvl(vc.aliq_icms,0)     = nvl(rec2.aliq_icms,0);
         --
         vn_fase := 3;
         --
      end loop;
      --
      vn_fase := 3.1;
      --
      delete
        from vw_csf_reg_conhec_transp_efd vc
       where vc.cpf_cnpj_emit   = rec.cpf_cnpj_emit
         and vc.dm_ind_emit     = rec.dm_ind_emit
         and vc.dm_ind_oper     = rec.dm_ind_oper
         and vc.cod_part        = rec.cod_part
         and vc.cod_mod         = rec.cod_mod
         and vc.serie           = rec.serie
         and nvl(vc.subserie,0) = nvl(rec.subserie,0)
         and vc.nro_nf          = rec.nro_nf;
      --
      vn_fase := 4;
      --
      delete
        from vw_csf_ct_proc_ref_efd vc
       where vc.cpf_cnpj_emit   = rec.cpf_cnpj_emit
         and vc.dm_ind_emit     = rec.dm_ind_emit
         and vc.dm_ind_oper     = rec.dm_ind_oper
         and vc.cod_part        = rec.cod_part
         and vc.cod_mod         = rec.cod_mod
         and vc.serie           = rec.serie
         and nvl(vc.subserie,0) = nvl(rec.subserie,0)
         and vc.nro_nf          = rec.nro_nf;
      --
      vn_fase := 5;
      --
      for rec3 in c_ct_comp( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                           , rec.serie, rec.subserie, rec.nro_nf ) loop
         exit when c_ct_comp%notfound or (c_ct_comp%notfound) is null;
         --
         delete
           from vw_csf_ctcompdocpis_efd_ff vc
          where vc.cpf_cnpj_emit    = rec3.cpf_cnpj_emit
            and vc.dm_ind_emit      = rec3.dm_ind_emit
            and vc.dm_ind_oper      = rec3.dm_ind_oper
            and vc.cod_part         = rec3.cod_part
            and vc.cod_mod          = rec3.cod_mod
            and vc.serie            = rec3.serie
            and nvl(vc.subserie,0)  = nvl(rec3.subserie,0)
            and vc.nro_nf           = rec3.nro_nf
            and nvl(vc.cst_pis,' ') = nvl(rec3.cst_pis,' ');
         --
         vn_fase := 6;
         --
      end loop;
      --
      delete
        from vw_csf_ct_comp_doc_pis_efd vc
       where vc.cpf_cnpj_emit   = rec.cpf_cnpj_emit
         and vc.dm_ind_emit     = rec.dm_ind_emit
         and vc.dm_ind_oper     = rec.dm_ind_oper
         and vc.cod_part        = rec.cod_part
         and vc.cod_mod         = rec.cod_mod
         and vc.serie           = rec.serie
         and nvl(vc.subserie,0) = nvl(rec.subserie,0)
         and vc.nro_nf          = rec.nro_nf;
      --
      vn_fase := 7;
      --
      for rec4 in c_ctinfor( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod, rec.serie
                           , rec.subserie,  rec.nro_nf ) loop
         exit when c_ctinfor%notfound or(c_ctinfor%notfound) is null;
         --
         delete
           from vw_csf_ct_inf_prov_efd vc
          where vc.cpf_cnpj_emit   = rec4.cpf_cnpj_emit
            and vc.dm_ind_emit     = rec4.dm_ind_emit
            and vc.dm_ind_oper     = rec4.dm_ind_oper
            and vc.cod_part        = rec4.cod_part
            and vc.cod_mod         = rec4.cod_mod
            and vc.serie           = rec4.serie
            and nvl(vc.subserie,0) = nvl(rec4.subserie,0)
            and vc.nro_nf          = rec4.nro_nf
            and vc.cod_obs         = rec4.cod_obs;
         --
         vn_fase := 6;
         --
      end loop;
      --
      vn_fase := 7;
      --
      delete
        from vw_csf_ctinfor_fiscal_efd vc
       where vc.cpf_cnpj_emit   = rec.cpf_cnpj_emit
         and vc.dm_ind_emit     = rec.dm_ind_emit
         and vc.dm_ind_oper     = rec.dm_ind_oper
         and vc.cod_part        = rec.cod_part
         and vc.cod_mod         = rec.cod_mod
         and vc.serie           = rec.serie
         and nvl(vc.subserie,0) = nvl(rec.subserie,0)
         and vc.nro_nf          = rec.nro_nf;
      --
      vn_fase := 8;
      --
      for rec5 in c_comp_doc( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                            , rec.serie, rec.subserie, rec.nro_nf ) loop
         exit when c_comp_doc%notfound or (c_comp_doc%notfound) is null;
         --
         delete
           from vw_csf_ctcompdoccofins_efd_ff vc
          where vc.cpf_cnpj_emit       = rec5.cpf_cnpj_emit
            and vc.dm_ind_emit         = rec5.dm_ind_emit
            and vc.dm_ind_oper         = rec5.dm_ind_oper
            and vc.cod_part            = rec5.cod_part
            and vc.cod_mod             = rec5.cod_mod
            and vc.serie               = rec5.serie
            and nvl(vc.subserie,0)     = nvl(rec5.subserie,0)
            and vc.nro_nf              = rec5.nro_nf
            and nvl(vc.cst_cofins,' ') = nvl(rec5.cst_cofins,' ');
         --
         vn_fase := 12;
         --
      end loop;
      --
      vn_fase := 13;
      --
      delete
        from vw_csf_ct_comp_doc_cofins_efd vc
       where vc.cpf_cnpj_emit   = rec.cpf_cnpj_emit
         and vc.dm_ind_emit     = rec.dm_ind_emit
         and vc.dm_ind_oper     = rec.dm_ind_oper
         and vc.cod_part        = rec.cod_part
         and vc.cod_mod         = rec.cod_mod
         and vc.serie           = rec.serie
         and nvl(vc.subserie,0) = nvl(rec.subserie,0)
         and vc.nro_nf          = rec.nro_nf;
      --
      vn_fase := 14;
      --
   end loop;
   --
   delete
     from vw_csf_conhec_transp_efd vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and ( (vc.dm_ind_emit = 0 and vc.dt_emiss between nvl(gd_dt_ini, vc.dt_emiss) and nvl(gd_dt_fin, vc.dt_emiss))
             or
            (vc.dm_ind_emit = 1 and nvl(vc.dt_sai_ent, vc.dt_emiss)
                                    between nvl(nvl(gd_dt_ini, vc.dt_sai_ent), vc.dt_emiss)
                                        and nvl(nvl(gd_dt_fin, vc.dt_sai_ent), vc.dt_emiss)) );
   --
   vn_fase := 15;
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_conhec_transp fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_conhec_transp;

--#72357 criacao procedure
--------------------------------------------------------------------------------------
--|PROCESSO QUE LIMPA INTEGRAÇÃO DE CONHECIMENTO DE TRASNPORTE = 4 |-- EMISSAO PROPRIA
--------------------------------------------------------------------------------------
/* efetua o processo de limpeza de views de integracao de cte de emissao propria */
procedure pkb_limpa_conhec_transp_ep is
   --
   vn_fase     number := 0;
   gv_sql      varchar2(4000) := null;
   gv_aspas    char(1) := null;
   --
   -- recupera o CT-e
   cursor c_ct is
   select vc.nro_chave_cte
           , vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_ct
        from csf_int.vw_csf_conhec_transp vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and ( trunc(nvl(vc.dt_sai_ent, vc.dt_hr_emissao))  between nvl(nvl(gd_dt_ini, vc.dt_sai_ent), vc.dt_hr_emissao)
                                                                and nvl(nvl(gd_dt_fin, vc.dt_sai_ent), vc.dt_hr_emissao)
              )
      order by 1 asc;
   --
   -- recupera as views de CT-e que deveram ser limpas
   cursor c_tabelas_cte is
     select a.table_name  tabela
       from all_tab_columns a
      where upper(a.owner)       =    upper('CSF_INT')
        and upper(a.table_name)  <>   upper('VW_CSF_CONHEC_TRANSP')
        and upper(a.table_name)  like upper('VW_CSF_%')
        and upper(a.column_name) in ( upper('CPF_CNPJ_EMIT' )
                                    , upper('DM_IND_EMIT' )
                                    , upper('DM_IND_OPER' )
                                    , upper('COD_MOD')
                                    , upper('SERIE')
                                    , upper('NRO_CT')
                                     )
      group by a.table_name
     having count(a.column_name) = 6
      order by a.table_name;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_ct loop
      exit when c_ct%notfound or (c_ct%notfound) is null;
      --
      vn_fase := 2;
      --
      gv_sql := null;
      --
      for rec_limpa in c_tabelas_cte loop
         exit when c_tabelas_cte%notfound or (c_tabelas_cte%notfound) is null;
         --
         vn_fase := 3;
         --
         --  inicia montagem da query
         gv_sql := 'delete from ';
         gv_sql := gv_sql || rec_limpa.tabela ;
         gv_sql := gv_sql || ' where ' || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || rec.cpf_cnpj_emit || '''';
         gv_sql := gv_sql || '   and ' || GV_ASPAS || 'DM_IND_EMIT'   || GV_ASPAS || ' = ' ||         rec.dm_ind_emit          ;
         gv_sql := gv_sql || '   and ' || GV_ASPAS || 'DM_IND_OPER'   || GV_ASPAS || ' = ' ||         rec.dm_ind_oper          ;
         gv_sql := gv_sql || '   and ' || GV_ASPAS || 'COD_MOD'       || GV_ASPAS || ' = ' || '''' || rec.cod_mod       || '''';
         gv_sql := gv_sql || '   and ' || GV_ASPAS || 'SERIE'         || GV_ASPAS || ' = ' || '''' || rec.serie         || '''';
         gv_sql := gv_sql || '   and ' || GV_ASPAS || 'NRO_CT'        || GV_ASPAS || ' = ' ||         rec.nro_ct               ;
         --
         vn_fase := 4;
         --
         -- executa comando limpeza
         begin
            execute immediate gv_sql ;
            commit;
         exception
           when others then
              null;
         end;
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 5;
   --
    delete
      from csf_int.vw_csf_conhec_transp vc
     where vc.cpf_cnpj_emit = gv_cnpj
       and ( trunc(nvl(vc.dt_sai_ent, vc.dt_hr_emissao))  between nvl(nvl(gd_dt_ini, vc.dt_sai_ent), vc.dt_hr_emissao)
                                                              and nvl(nvl(gd_dt_fin, vc.dt_sai_ent), vc.dt_hr_emissao)
            ) ;
   --
   vn_fase := 6;
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_conhec_transp_ep fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_conhec_transp_ep;

------------------------------------------------------------------------------------------------
--|PROCESSO QUE LIMPA INTEGRAÇÃO DE NOTAS FISCAIS DE SERVIÇOS CONTÍNUOS (ÁGUA, LUZ, ETC.) = 5|--
------------------------------------------------------------------------------------------------
/*Leiaute_Views_Integracao_Serv_Cont_V2_2*/
procedure pkb_limpa_nfs_cont is
   --
   vn_fase number := 0;
   --
   cursor c_nfs_cont is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.subserie
           , vc.nro_nf
        from vw_csf_nf_serv_cont vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and ( (vc.dm_ind_emit = 0 and vc.dt_emiss between nvl(gd_dt_ini, vc.dt_emiss) and nvl(gd_dt_fin, vc.dt_emiss))
                or
               (vc.dm_ind_emit = 1 and nvl(vc.dt_sai_ent, vc.dt_emiss)
                                       between nvl(nvl(gd_dt_ini, vc.dt_sai_ent), vc.dt_emiss)
                                           and nvl(nvl(gd_dt_fin, vc.dt_sai_ent), vc.dt_emiss)) )
      order by 1 asc;
   --
   cursor c_reg_nf( ev_cpf_cnpj_emit in varchar2
                  , en_dm_ind_emit   in number
                  , en_dm_ind_oper   in number
                  , ev_cod_part      in varchar2
                  , ev_cod_mod       in varchar2
                  , ev_serie         in varchar2
                  , en_subserie      in number
                  , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.subserie
           , vc.nro_nf
           , vc.cst_icms
           , vc.dm_orig_merc
           , vc.cfop
           , vc.aliq_icms
        from vw_csf_reg_nf_serv_cont vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and nvl(vc.subserie,0)   = nvl(en_subserie,0)
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_compl_oper( ev_cpf_cnpj_emit in varchar2
                      , en_dm_ind_emit   in number
                      , en_dm_ind_oper   in number
                      , ev_cod_part      in varchar2
                      , ev_cod_mod       in varchar2
                      , ev_serie         in varchar2
                      , en_subserie      in number
                      , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.subserie
           , vc.nro_nf
           , vc.cst_pis
        from vw_csf_nf_compl_oper_pis vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and nvl(vc.subserie,0)   = nvl(en_subserie,0)
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_nf_comp_cofins( ev_cpf_cnpj_emit in varchar2
                          , en_dm_ind_emit   in number
                          , en_dm_ind_oper   in number
                          , ev_cod_part      in varchar2
                          , ev_cod_mod       in varchar2
                          , ev_serie         in varchar2
                          , en_subserie      in number
                          , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.subserie
           , vc.nro_nf
           , vc.cst_cofins
        from vw_csf_nf_compl_oper_cofins vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and nvl(vc.subserie,0)   = nvl(en_subserie,0)
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_nfcobr( ev_cpf_cnpj_emit in varchar2
                  , en_dm_ind_emit   in number
                  , en_dm_ind_oper   in number
                  , ev_cod_part      in varchar2
                  , ev_cod_mod       in varchar2
                  , ev_serie         in varchar2
                  , en_subserie      in number
                  , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.subserie
           , vc.nro_nf
           , vc.nro_fat
        from vw_csf_nfcobr_sc vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and nvl(vc.subserie,0)   = nvl(en_subserie,0)
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_itemnf( ev_cpf_cnpj_emit in varchar2
                  , en_dm_ind_emit   in number
                  , en_dm_ind_oper   in number
                  , ev_cod_part      in varchar2
                  , ev_cod_mod       in varchar2
                  , ev_serie         in varchar2
                  , en_subserie      in number
                  , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.subserie
           , vc.nro_nf
           , vc.nro_item
           , vc.cod_item
        from vw_csf_itemnf_sc vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and nvl(vc.subserie,0)   = nvl(en_subserie,0)
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   --|Viwes de cancelamento|--
   cursor c_canc_nf is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.subserie
           , vc.nro_nf
        from vw_csf_nf_canc_sc vc
       where vc.cpf_cnpj_emit = gv_cnpj
      order by 1 asc;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_nfs_cont loop
      exit when c_nfs_cont%notfound or (c_nfs_cont%notfound) is null;
      --
      delete
        from vw_csf_nf_serv_cont_ff vc
       where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec.dm_ind_emit
         and vc.dm_ind_oper       = rec.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
         and vc.cod_mod           = rec.cod_mod
         and vc.serie             = rec.serie
         and nvl(vc.subserie,0)   = nvl(rec.subserie,0)
         and vc.nro_nf            = rec.nro_nf;
      --
      vn_fase := 2;
      --
      for rec2 in c_reg_nf( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper
                          , rec.cod_part, rec.cod_mod, rec.serie,rec.subserie, rec.nro_nf ) loop
        exit when c_reg_nf%notfound or (c_reg_nf%notfound) is null;
        --
        delete
          from vw_csf_reg_nf_serv_cont_ff vc
         where vc.cpf_cnpj_emit     = rec2.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec2.dm_ind_emit
           and vc.dm_ind_oper       = rec2.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec2.cod_part,' ')
           and vc.cod_mod           = rec2.cod_mod
           and vc.serie             = rec2.serie
           and nvl(vc.subserie,0)   = nvl(rec2.subserie,0)
           and vc.nro_nf            = rec2.nro_nf
           and vc.cst_icms          = rec2.cst_icms
           and vc.dm_orig_merc      = rec2.dm_orig_merc
           and vc.cfop              = rec2.cfop
           and nvl(vc.aliq_icms,0)  = nvl(rec2.aliq_icms,0);
        --
        vn_fase := 3;
        --
        delete
          from vw_csf_reg_nf_serv_cont_difal vc
         where vc.cpf_cnpj_emit     = rec2.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec2.dm_ind_emit
           and vc.dm_ind_oper       = rec2.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec2.cod_part,' ')
           and vc.cod_mod           = rec2.cod_mod
           and vc.serie             = rec2.serie
           and nvl(vc.subserie,0)   = nvl(rec2.subserie,0)
           and vc.nro_nf            = rec2.nro_nf
           and vc.cst_icms          = rec2.cst_icms
           and vc.dm_orig_merc      = rec2.dm_orig_merc
           and vc.cfop              = rec2.cfop
           and nvl(vc.aliq_icms,0)  = nvl(rec2.aliq_icms,0);
        --
        vn_fase := 4;
        --
      end loop;
      --
      delete
        from vw_csf_reg_nf_serv_cont vc
       where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec.dm_ind_emit
         and vc.dm_ind_oper       = rec.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
         and vc.cod_mod           = rec.cod_mod
         and vc.serie             = rec.serie
         and nvl(vc.subserie,0)   = nvl(rec.subserie,0)
         and vc.nro_nf            = rec.nro_nf;
      --
      vn_fase := 5;
      --
      for rec3 in c_compl_oper( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper
                          , rec.cod_part, rec.cod_mod, rec.serie,rec.subserie, rec.nro_nf ) loop
         exit when c_compl_oper%notfound or (c_compl_oper%notfound) is null;
         --
         delete
           from vw_csf_nfcomploperpis_ff vc
          where vc.cpf_cnpj_emit     = rec3.cpf_cnpj_emit
            and vc.dm_ind_emit       = rec3.dm_ind_emit
            and vc.dm_ind_oper       = rec3.dm_ind_oper
            and nvl(vc.cod_part,' ') = nvl(rec3.cod_part,' ')
            and vc.cod_mod           = rec3.cod_mod
            and vc.serie             = rec3.serie
            and nvl(vc.subserie,0)   = nvl(rec3.subserie,0)
            and vc.nro_nf            = rec3.nro_nf
            and vc.cst_pis           = rec3.cst_pis;
         --
         vn_fase := 6;
         --
      end loop;
      --
      delete
        from vw_csf_nf_compl_oper_pis vc
       where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec.dm_ind_emit
         and vc.dm_ind_oper       = rec.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
         and vc.cod_mod           = rec.cod_mod
         and vc.serie             = rec.serie
         and nvl(vc.subserie,0)   = nvl(rec.subserie,0)
         and vc.nro_nf            = rec.nro_nf;
      --
      vn_fase := 7;
      --
      for rec4 in c_nf_comp_cofins( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper
                          , rec.cod_part, rec.cod_mod, rec.serie,rec.subserie, rec.nro_nf ) loop
         exit when c_nf_comp_cofins%notfound or (c_nf_comp_cofins%notfound) is null;
         --
         delete
           from vw_csf_nfcomplopercofins_ff vc
          where vc.cpf_cnpj_emit     = rec4.cpf_cnpj_emit
            and vc.dm_ind_emit       = rec4.dm_ind_emit
            and vc.dm_ind_oper       = rec4.dm_ind_oper
            and nvl(vc.cod_part,' ') = nvl(rec4.cod_part,' ')
            and vc.cod_mod           = rec4.cod_mod
            and vc.serie             = rec4.serie
            and nvl(vc.subserie,0)   = nvl(rec4.subserie,0)
            and vc.nro_nf            = rec4.nro_nf
            and vc.cst_cofins        = rec4.cst_cofins;
         --
         vn_fase := 8;
         --
      end loop;
      --
      vn_fase := 9;
      --
      delete
        from vw_csf_nf_compl_oper_cofins vc
       where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec.dm_ind_emit
         and vc.dm_ind_oper       = rec.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
         and vc.cod_mod           = rec.cod_mod
         and vc.serie             = rec.serie
         and nvl(vc.subserie,0)   = nvl(rec.subserie,0)
         and vc.nro_nf            = rec.nro_nf;
      --
      vn_fase := 10;
      --
      delete
        from vw_csf_nf_proc_ref vc
       where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec.dm_ind_emit
         and vc.dm_ind_oper       = rec.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
         and vc.cod_mod           = rec.cod_mod
         and vc.serie             = rec.serie
         and nvl(vc.subserie,0)   = nvl(rec.subserie,0)
         and vc.nro_nf            = rec.nro_nf;
      --
      vn_fase := 11;
      --
      delete
        from vw_csf_nf_compl_sc vc
       where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec.dm_ind_emit
         and vc.dm_ind_oper       = rec.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
         and vc.cod_mod           = rec.cod_mod
         and vc.serie             = rec.serie
         and nvl(vc.subserie,0)   = nvl(rec.subserie,0)
         and vc.nro_nf            = rec.nro_nf;
      --
      vn_fase := 12;
      --
      delete
        from vw_csf_nf_dest_sc vc
       where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec.dm_ind_emit
         and vc.dm_ind_oper       = rec.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
         and vc.cod_mod           = rec.cod_mod
         and vc.serie             = rec.serie
         and nvl(vc.subserie,0)   = nvl(rec.subserie,0)
         and vc.nro_nf            = rec.nro_nf;
      --
      vn_fase := 13;
      --
      delete
        from vw_csf_nf_term_fat_sc vc
       where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec.dm_ind_emit
         and vc.dm_ind_oper       = rec.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
         and vc.cod_mod           = rec.cod_mod
         and vc.serie             = rec.serie
         and nvl(vc.subserie,0)   = nvl(rec.subserie,0)
         and vc.nro_nf            = rec.nro_nf;
      --
      vn_fase := 14;
      --
      for rec5 in c_nfcobr( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper
                          , rec.cod_part, rec.cod_mod, rec.serie,rec.subserie, rec.nro_nf ) loop
         exit when c_nfcobr%notfound or (c_nfcobr%notfound) is null;
         --
         delete
           from vw_csf_nfcobr_dup_sc vc
          where vc.cpf_cnpj_emit     = rec5.cpf_cnpj_emit
            and vc.dm_ind_emit       = rec5.dm_ind_emit
            and vc.dm_ind_oper       = rec5.dm_ind_oper
            and nvl(vc.cod_part,' ') = nvl(rec5.cod_part,' ')
            and vc.cod_mod           = rec5.cod_mod
            and vc.serie             = rec5.serie
            and nvl(vc.subserie,0)   = nvl(rec5.subserie,0)
            and vc.nro_nf            = rec5.nro_nf
            and vc.nro_fat           = rec5.nro_fat;
         --
         vn_fase := 15;
         --
      end loop;
      --
      vn_fase := 16;
      --
      delete
        from vw_csf_nfcobr_sc vc
       where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec.dm_ind_emit
         and vc.dm_ind_oper       = rec.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
         and vc.cod_mod           = rec.cod_mod
         and vc.serie             = rec.serie
         and nvl(vc.subserie,0)   = nvl(rec.subserie,0)
         and vc.nro_nf            = rec.nro_nf;
      --
      vn_fase := 17;
      --
      delete
        from vw_csf_nfinfor_adic_sc vc
       where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec.dm_ind_emit
         and vc.dm_ind_oper       = rec.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
         and vc.cod_mod           = rec.cod_mod
         and vc.serie             = rec.serie
         and nvl(vc.subserie,0)   = nvl(rec.subserie,0)
         and vc.nro_nf            = rec.nro_nf;
      --
      vn_fase := 18;
      --
      for rec6 in c_itemnf( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper
                          , rec.cod_part, rec.cod_mod, rec.serie,rec.subserie, rec.nro_nf ) loop
         exit when c_itemnf%notfound or (c_itemnf%notfound) is null;
         --
         delete
           from vw_csf_imp_itemnf_sc vc
          where vc.cpf_cnpj_emit     = rec6.cpf_cnpj_emit
            and vc.dm_ind_emit       = rec6.dm_ind_emit
            and vc.dm_ind_oper       = rec6.dm_ind_oper
            and nvl(vc.cod_part,' ') = nvl(rec6.cod_part,' ')
            and vc.cod_mod           = rec6.cod_mod
            and vc.serie             = rec6.serie
            and nvl(vc.subserie,0)   = nvl(rec6.subserie,0)
            and vc.nro_nf            = rec6.nro_nf
            and vc.nro_item          = rec6.nro_item;
         --
         vn_fase := 19;
         --
      end loop;
      --
      vn_fase := 20;
      --
      delete
        from vw_csf_itemnf_sc vc
       where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec.dm_ind_emit
         and vc.dm_ind_oper       = rec.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
         and vc.cod_mod           = rec.cod_mod
         and vc.serie             = rec.serie
         and nvl(vc.subserie,0)   = nvl(rec.subserie,0)
         and vc.nro_nf            = rec.nro_nf;
      --
   end loop;
   --
   vn_fase := 21;
   --
   delete
     from vw_csf_nf_serv_cont vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and ( (vc.dm_ind_emit = 0 and vc.dt_emiss between nvl(gd_dt_ini, vc.dt_emiss) and nvl(gd_dt_fin, vc.dt_emiss))
             or
            (vc.dm_ind_emit = 1 and nvl(vc.dt_sai_ent, vc.dt_emiss)
                                    between nvl(nvl(gd_dt_ini, vc.dt_sai_ent), vc.dt_emiss)
                                        and nvl(nvl(gd_dt_fin, vc.dt_sai_ent), vc.dt_emiss)) );
   --
   vn_fase := 22;
   --
   --|Limpando as viwes de cancelamento|--
   for rec in c_canc_nf loop
      exit when c_canc_nf%notfound or (c_canc_nf%notfound) is null;
      --
      delete
        from vw_csf_nf_canc_sc_ff vc
       where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec.dm_ind_emit
         and vc.dm_ind_oper       = rec.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
         and vc.cod_mod           = rec.cod_mod
         and vc.serie             = rec.serie
         and nvl(vc.subserie,0)   = nvl(rec.subserie,0)
         and vc.nro_nf            = rec.nro_nf;
      --
      vn_fase := 23;
      --
   end loop;
   --
   vn_fase := 24;
   --
   delete
     from vw_csf_nf_canc_sc vc
    where vc.cpf_cnpj_emit = gv_cnpj;
   --
   vn_fase := 25;
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_nfs_cont fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_nfs_cont;

------------------------------------------------------------------
--|PROCESSO QUE LIMPA INTEGRAÇÃO DE NOTAS FISCAIS MERCANTIS = 6|--
------------------------------------------------------------------
/*Leiaute_Views_Integracao_Fiscal_v2_16*/
procedure pkb_limpa_nf_mercantis is
   --
   vn_fase number := 0;
   --
   cursor c_nf is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
        from vw_csf_nota_fiscal vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and vc.cod_mod = '55' --#70990
        /* and ( (vc.dm_ind_emit = 0 and vc.dt_emiss between nvl(gd_dt_ini, vc.dt_emiss) and nvl(gd_dt_fin, vc.dt_emiss))
                or
               (vc.dm_ind_emit = 1 and nvl(vc.dt_sai_ent, vc.dt_emiss)
                                       between nvl(nvl(gd_dt_ini, vc.dt_sai_ent), vc.dt_emiss)
                                           and nvl(nvl(gd_dt_fin, vc.dt_sai_ent), vc.dt_emiss)) )*/--nao existe parametro de data na tela, esta sendo passado null pra package
      order by 1 asc;
   --
   cursor c_nf_emit( ev_cpf_cnpj_emit in varchar2
                   , en_dm_ind_emit   in number
                   , en_dm_ind_oper   in number
                   , ev_cod_part      in varchar2
                   , ev_cod_mod       in varchar2
                   , ev_serie         in varchar2
                   , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
         from vw_csf_nota_fiscal_emit vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_nf_dest( ev_cpf_cnpj_emit in varchar2
                   , en_dm_ind_emit   in number
                   , en_dm_ind_oper   in number
                   , ev_cod_part      in varchar2
                   , ev_cod_mod       in varchar2
                   , ev_serie         in varchar2
                   , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
        from vw_csf_nota_fiscal_dest vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_nf_total( ev_cpf_cnpj_emit in varchar2
                    , en_dm_ind_emit   in number
                    , en_dm_ind_oper   in number
                    , ev_cod_part      in varchar2
                    , ev_cod_mod       in varchar2
                    , ev_serie         in varchar2
                    , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
        from vw_csf_nota_fiscal_total vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_nf_referen( ev_cpf_cnpj_emit in varchar2
                      , en_dm_ind_emit   in number
                      , en_dm_ind_oper   in number
                      , ev_cod_part      in varchar2
                      , ev_cod_mod       in varchar2
                      , ev_serie         in varchar2
                      , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
        from vw_csf_nota_fiscal_referen vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_nf_cobr( ev_cpf_cnpj_emit in varchar2
                   , en_dm_ind_emit   in number
                   , en_dm_ind_oper   in number
                   , ev_cod_part      in varchar2
                   , ev_cod_mod       in varchar2
                   , ev_serie         in varchar2
                   , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
           , vc.nro_fat
        from vw_csf_nota_fiscal_cobr vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_nf_transp( ev_cpf_cnpj_emit in varchar2
                     , en_dm_ind_emit   in number
                     , en_dm_ind_oper   in number
                     , ev_cod_part      in varchar2
                     , ev_cod_mod       in varchar2
                     , ev_serie         in varchar2
                     , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
        from vw_csf_nota_fiscal_transp vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_nftransp_vol( ev_cpf_cnpj_emit in varchar2
                        , en_dm_ind_emit   in number
                        , en_dm_ind_oper   in number
                        , ev_cod_part      in varchar2
                        , ev_cod_mod       in varchar2
                        , ev_serie         in varchar2
                        , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
           , vc.nro_vol
       from vw_csf_nftransp_vol vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_item_nf( ev_cpf_cnpj_emit in varchar2
                   , en_dm_ind_emit   in number
                   , en_dm_ind_oper   in number
                   , ev_cod_part      in varchar2
                   , ev_cod_mod       in varchar2
                   , ev_serie         in varchar2
                   , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
          ,  vc.dm_ind_emit
          ,  vc.dm_ind_oper
          ,  vc.cod_part
          ,  vc.cod_mod
          ,  vc.serie
          ,  vc.nro_nf
          ,  vc.nro_item
          ,  vc.cod_item
        from vw_csf_item_nota_fiscal vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_imp_itemnf( ev_cpf_cnpj_emit in varchar2
                      , en_dm_ind_emit   in number
                      , en_dm_ind_oper   in number
                      , ev_cod_part      in varchar2
                      , ev_cod_mod       in varchar2
                      , ev_serie         in varchar2
                      , en_nro_nf        in number
                      , en_nro_item      in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
           , vc.nro_item
           , vc.cod_imposto
        from vw_csf_imp_itemnf vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
         and vc.nro_item          = en_nro_item
      order by 1 asc;
   --
   cursor c_itemnf_comb( ev_cpf_cnpj_emit in varchar2
                       , en_dm_ind_emit   in number
                       , en_dm_ind_oper   in number
                       , ev_cod_part      in varchar2
                       , ev_cod_mod       in varchar2
                       , ev_serie         in varchar2
                       , en_nro_nf        in number
                       , en_nro_item      in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
           , vc.nro_item
        from vw_csf_itemnf_comb vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
         and vc.nro_item          = en_nro_item
      order by 1 asc;
   --
   cursor c_itemnf_decimpr( ev_cpf_cnpj_emit in varchar2
                          , en_dm_ind_emit   in number
                          , en_dm_ind_oper   in number
                          , ev_cod_part      in varchar2
                          , ev_cod_mod       in varchar2
                          , ev_serie         in varchar2
                          , en_nro_nf        in number
                          , en_nro_item      in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
           , vc.nro_item
           , vc.nro_di
      from vw_csf_itemnf_dec_impor vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
         and nvl(vc.nro_item,0)   = nvl(en_nro_item,0)
      order by 1 asc;
   --
   cursor c_itemnf_adic( ev_cpf_cnpj_emit in varchar2
                       , en_dm_ind_emit   in number
                       , en_dm_ind_oper   in number
                       , ev_cod_part      in varchar2
                       , ev_cod_mod       in varchar2
                       , ev_serie         in varchar2
                       , en_nro_nf        in number
                       , en_nro_item      in number
                       , ev_nro_di        in varchar2 )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
           , vc.nro_item
           , vc.nro_di
           , vc.nro_adicao
           , vc.nro_seq_adic
        from vw_csf_itemnfdi_adic vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
         and nvl(vc.nro_item,0)   = nvl(en_nro_item,0)
         and vc.nro_di            = ev_nro_di
      order by 1 asc;
   --
   cursor c_nf_cana( ev_cpf_cnpj_emit in varchar2
                   , en_dm_ind_emit   in number
                   , en_dm_ind_oper   in number
                   , ev_cod_part      in varchar2
                   , ev_cod_mod       in varchar2
                   , ev_serie         in varchar2
                   , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
           , vc.safra
           , vc.mes_ano_ref
        from vw_csf_nf_aquis_cana vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_nfinfor_fiscal( ev_cpf_cnpj_emit in varchar2
                          , en_dm_ind_emit   in number
                          , en_dm_ind_oper   in number
                          , ev_cod_part      in varchar2
                          , ev_cod_mod       in varchar2
                          , ev_serie         in varchar2
                          , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
        from vw_csf_nfinfor_fiscal vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_nf_agend_trans( ev_cpf_cnpj_emit in varchar2
                          , en_dm_ind_emit   in number
                          , en_dm_ind_oper   in number
                          , ev_cod_part      in varchar2
                          , ev_cod_mod       in varchar2
                          , ev_serie         in varchar2
                          , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
        from vw_csf_nf_agend_transp vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_nf_forma_pgto( ev_cpf_cnpj_emit in varchar2
                         , en_dm_ind_emit   in number
                         , en_dm_ind_oper   in number
                         , ev_cod_part      in varchar2
                         , ev_cod_mod       in varchar2
                         , ev_serie         in varchar2
                         , en_nro_nf        in number )
      is
      select vc.*
        from vw_csf_nf_forma_pgto vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   --|Viwes de cancelamento|--
   cursor c_nf_canc is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
        from vw_csf_nota_fiscal_canc vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and vc.cod_mod = '55' --#70990
      order by 1 asc;
   --
   --|Viwes de inutilização|--
   cursor c_inutiliza_nf is
      select vc.cpf_cnpj_emit
           , vc.ano
           , vc.serie
           , vc.nro_ini
           , vc.nro_fim
        from vw_csf_inutiliza_nota_fiscal vc
       where vc.cpf_cnpj_emit = gv_cnpj
      order by 1 asc;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_nf loop
     exit when c_nf%notfound or (c_nf%notfound) is null;
     --
     delete
       from vw_csf_nota_fiscal_ff vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 2;
     --
     delete
       from vw_csf_nota_fiscal_compl vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 3;
     --
     for rec_emit in c_nf_emit( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                          , rec.serie, rec.nro_nf ) loop
        exit when c_nf_emit%notfound or (c_nf_emit%notfound) is null;
        --
        delete
          from vw_csf_nota_fiscal_emit_ff vc
         where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec.dm_ind_emit
           and vc.dm_ind_oper       = rec.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
           and vc.cod_mod           = rec.cod_mod
           and vc.serie             = rec.serie
           and vc.nro_nf            = rec.nro_nf;
        --
        vn_fase := 3.2;
        --
     end loop;
     --
     vn_fase := 3.3;
     --
     delete
       from vw_csf_nota_fiscal_emit vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 4;
     --
     for rec2 in c_nf_dest( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                          , rec.serie, rec.nro_nf ) loop
        exit when c_nf_dest%notfound or (c_nf_dest%notfound) is null;
        --
        delete
          from vw_csf_nota_fiscal_dest_ff vc
         where vc.cpf_cnpj_emit     = rec2.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec2.dm_ind_emit
           and vc.dm_ind_oper       = rec2.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec2.cod_part,' ')
           and vc.cod_mod           = rec2.cod_mod
           and vc.serie             = rec2.serie
           and vc.nro_nf            = rec2.nro_nf;
        --
        vn_fase := 5;
        --
     end loop;
     --
     vn_fase := 6;
     --
     delete
       from vw_csf_nota_fiscal_dest vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 7;
     --
     delete
       from vw_csf_nfdest_email vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 8;
     --
     for rec3 in c_nf_total( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                          , rec.serie, rec.nro_nf ) loop
        exit when c_nf_total%notfound or (c_nf_total%notfound) is null;
        --
        delete
          from vw_csf_nota_fiscal_total_ff vc
        where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
          and vc.dm_ind_emit       = rec.dm_ind_emit
          and vc.dm_ind_oper       = rec.dm_ind_oper
          and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
          and vc.cod_mod           = rec.cod_mod
          and vc.serie             = rec.serie
          and vc.nro_nf            = rec.nro_nf;
        --
        vn_fase := 9;
        --
     end loop;
     --
     vn_fase := 10;
     --
     delete
       from vw_csf_nota_fiscal_total vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 11;
     --
     for rec4 in c_nf_referen( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                             , rec.serie, rec.nro_nf ) loop
        exit when c_nf_referen%notfound or (c_nf_referen%notfound) is null;
        --
        delete
          from vw_csf_nota_fiscal_referen_ff vc
         where vc.cpf_cnpj_emit     = rec4.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec4.dm_ind_emit
           and vc.dm_ind_oper       = rec4.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec4.cod_part,' ')
           and vc.cod_mod           = rec4.cod_mod
           and vc.serie             = rec4.serie
           and vc.nro_nf            = rec4.nro_nf;
        --
        vn_fase := 12;
        --
     end loop;
     --
     vn_fase := 13;
     --
     delete
       from vw_csf_nota_fiscal_referen vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 14;
     --
     delete
       from vw_csf_cupom_fiscal_ref vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 14.2;
     --
     delete
       from vw_csf_cfe_ref vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 15;
     --
     delete
       from vw_csf_nfinfor_adic vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 16;
     --
     for rec5 in c_nf_cobr( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                             , rec.serie, rec.nro_nf ) loop
        exit when c_nf_cobr%notfound or (c_nf_cobr%notfound) is null;
        --
        delete
          from vw_csf_nf_cobr_dup vc
         where vc.cpf_cnpj_emit    = rec5.cpf_cnpj_emit
          and vc.dm_ind_emit       = rec5.dm_ind_emit
          and vc.dm_ind_oper       = rec5.dm_ind_oper
          and nvl(vc.cod_part,' ') = nvl(rec5.cod_part,' ')
          and vc.cod_mod           = rec5.cod_mod
          and vc.serie             = rec5.serie
          and vc.nro_nf            = rec5.nro_nf
          and vc.nro_fat           = rec5.nro_fat;
        --
        vn_fase := 17;
        --
     end loop;
     --
     delete
       from vw_csf_nota_fiscal_cobr vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 18;
     --
     delete
      from vw_csf_nota_fiscal_local vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 18.1;
     --
     delete
      from vw_csf_nota_fiscal_local_ff vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 19;
     --
     for rec6 in c_nf_transp( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                             , rec.serie, rec.nro_nf ) loop
        exit when c_nf_transp%notfound or (c_nf_transp%notfound) is null;
        --
        delete
          from vw_csf_nftransp_veic vc
         where vc.cpf_cnpj_emit     = rec6.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec6.dm_ind_emit
           and vc.dm_ind_oper       = rec6.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec6.cod_part,' ')
           and vc.cod_mod           = rec6.cod_mod
           and vc.serie             = rec6.serie
           and vc.nro_nf            = rec.nro_nf;
        --
        vn_fase := 20;
        --
        for rec7 in c_nftransp_vol( rec6.cpf_cnpj_emit, rec6.dm_ind_emit, rec6.dm_ind_oper, rec6.cod_part, rec6.cod_mod
                             , rec6.serie, rec6.nro_nf ) loop
           exit when c_nftransp_vol%notfound or (c_nftransp_vol%notfound) is null;
           --
           delete
             from VW_csf_nftranspvol_lacre vc
            where vc.cpf_cnpj_emit     = rec7.cpf_cnpj_emit
              and vc.dm_ind_emit       = rec7.dm_ind_emit
              and vc.dm_ind_oper       = rec7.dm_ind_oper
              and nvl(vc.cod_part,' ') = nvl(rec7.cod_part,' ')
              and vc.cod_mod           = rec7.cod_mod
              and vc.serie             = rec7.serie
              and vc.nro_nf            = rec7.nro_nf
              and vc.nro_vol           = rec7.nro_vol;
           --
           vn_fase := 21;
           --
        end loop;
        --
        vn_fase := 22;
        --
        delete
          from vw_csf_nftransp_vol vc
         where vc.cpf_cnpj_emit     = rec6.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec6.dm_ind_emit
           and vc.dm_ind_oper       = rec6.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec6.cod_part,' ')
           and vc.cod_mod           = rec6.cod_mod
           and vc.serie             = rec6.serie
           and vc.nro_nf            = rec6.nro_nf;
        --
        vn_fase := 23;
        --
     end loop;
     --
     vn_fase := 24;
     --
     delete
       from vw_csf_nota_fiscal_transp vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 25;
     --
     for rec8 in c_item_nf( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                             , rec.serie, rec.nro_nf ) loop
        exit when c_item_nf%notfound or (c_item_nf%notfound) is null;
        --
        delete
          from vw_csf_item_nota_fiscal_ff vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item
           and vc.cod_item          = rec8.cod_item;
        --
        vn_fase := 26;
        --
        delete
          from vw_csf_itemnf_compl vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 27;
        --
        delete
          from vw_csf_itemnf_dif_aliq vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 28;
        --
        for rec9 in c_imp_itemnf( rec8.cpf_cnpj_emit, rec8.dm_ind_emit, rec8.dm_ind_oper, rec8.cod_part, rec8.cod_mod
                             , rec8.serie, rec8.nro_nf, rec8.nro_item ) loop
           exit when c_imp_itemnf%notfound or (c_imp_itemnf%notfound) is null;
           --
           delete
             from vw_csf_imp_itemnf_ff vc
             where vc.cpf_cnpj_emit     = rec9.cpf_cnpj_emit
               and vc.dm_ind_emit       = rec9.dm_ind_emit
               and vc.dm_ind_oper       = rec9.dm_ind_oper
               and nvl(vc.cod_part,' ') = nvl(rec9.cod_part,' ')
               and vc.cod_mod           = rec9.cod_mod
               and vc.serie             = rec9.serie
               and vc.nro_nf            = rec9.nro_nf
               and vc.nro_item          = rec9.nro_item
               and vc.cod_imposto       = rec9.cod_imposto;
           --
           vn_fase := 29;
           --
           delete
             from vw_csf_imp_itemnf_icms_dest vc
             where vc.cpf_cnpj_emit     = rec9.cpf_cnpj_emit
               and vc.dm_ind_emit       = rec9.dm_ind_emit
               and vc.dm_ind_oper       = rec9.dm_ind_oper
               and nvl(vc.cod_part,' ') = nvl(rec9.cod_part,' ')
               and vc.cod_mod           = rec9.cod_mod
               and vc.serie             = rec9.serie
               and vc.nro_nf            = rec9.nro_nf
               and vc.nro_item          = rec9.nro_item
               and vc.cod_imposto       = rec9.cod_imposto;
           --
           vn_fase := 30;
           --
        end loop;
        --
        vn_fase := 31;
        --
        delete
          from vw_csf_imp_itemnf vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 32;
        --
        for rec10 in c_itemnf_comb( rec8.cpf_cnpj_emit, rec8.dm_ind_emit, rec8.dm_ind_oper, rec8.cod_part, rec8.cod_mod
                             , rec8.serie, rec8.nro_nf, rec8.nro_item ) loop
           exit when c_itemnf_comb%notfound or (c_itemnf_comb%notfound) is null;
           --
           delete
             from vw_csf_itemnf_comb_ff vc
            where vc.cpf_cnpj_emit     = rec10.cpf_cnpj_emit
              and vc.dm_ind_emit       = rec10.dm_ind_emit
              and vc.dm_ind_oper       = rec10.dm_ind_oper
              and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
              and vc.cod_mod           = rec10.cod_mod
              and vc.serie             = rec10.serie
              and vc.nro_nf            = rec10.nro_nf
              and vc.nro_item          = rec10.nro_item;
           --
           vn_fase := 33;
           --
        end loop;
        --
        vn_fase := 34;
        --
        delete
          from vw_csf_itemnf_comb vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 35;
        --
        delete
          from vw_csf_itemnf_veic vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 36;
        --
        delete
          from vw_csf_itemnf_med vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 37;
        --
        delete
          from vw_csf_itemnf_arma vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 38;
        --
        for rec11 in c_itemnf_decimpr( rec8.cpf_cnpj_emit, rec8.dm_ind_emit, rec8.dm_ind_oper, rec8.cod_part, rec8.cod_mod
                             , rec8.serie, rec8.nro_nf, rec8.nro_item ) loop
           exit when c_itemnf_decimpr%notfound or (c_itemnf_decimpr%notfound) is null;
           --
           delete
             from vw_csf_itemnf_dec_impor_ff vc
            where vc.cpf_cnpj_emit     = rec11.cpf_cnpj_emit
              and vc.dm_ind_emit       = rec11.dm_ind_emit
              and vc.dm_ind_oper       = rec11.dm_ind_oper
              and nvl(vc.cod_part,' ') = nvl(rec11.cod_part,' ')
              and vc.cod_mod           = rec11.cod_mod
              and vc.serie             = rec11.serie
              and vc.nro_nf            = rec11.nro_nf
              and nvl(vc.nro_item,0)   = nvl(rec11.nro_item,0)
              and vc.nro_di            = rec11.nro_di;
           --
           vn_fase := 39;
           --
           for rec12 in c_itemnf_adic( rec11.cpf_cnpj_emit, rec11.dm_ind_emit, rec11.dm_ind_oper, rec11.cod_part, rec11.cod_mod
                             , rec11.serie, rec11.nro_nf, rec11.nro_item, rec11.nro_di ) loop
              exit when c_itemnf_adic%notfound or (c_itemnf_adic%notfound) is null;
              --
              delete
                from vw_csf_itemnfdi_adic_ff vc
              where vc.cpf_cnpj_emit     = rec12.cpf_cnpj_emit
                and vc.dm_ind_emit       = rec12.dm_ind_emit
                and vc.dm_ind_oper       = rec12.dm_ind_oper
                and nvl(vc.cod_part,' ') = nvl(rec12.cod_part,' ')
                and vc.cod_mod           = rec12.cod_mod
                and vc.serie             = rec12.serie
                and vc.nro_nf            = rec12.nro_nf
                and nvl(vc.nro_item,0)   = nvl(rec12.nro_item,0)
                and vc.nro_di            = rec12.nro_di
                and vc.nro_adicao        = rec12.nro_adicao;
              --
              vn_fase := 40;
              --
           end loop;
           --
           vn_fase := 41;
           --
           delete
             from vw_csf_itemnfdi_adic vc
            where vc.cpf_cnpj_emit     = rec11.cpf_cnpj_emit
              and vc.dm_ind_emit       = rec11.dm_ind_emit
              and vc.dm_ind_oper       = rec11.dm_ind_oper
              and nvl(vc.cod_part,' ') = nvl(rec11.cod_part,' ')
              and vc.cod_mod           = rec11.cod_mod
              and vc.serie             = rec11.serie
              and vc.nro_nf            = rec11.nro_nf
              and nvl(vc.nro_item,0)   = nvl(rec11.nro_item,0)
              and vc.nro_di            = rec11.nro_di;
           --
           vn_fase := 42;
           --
        end loop;
        --
        vn_fase := 43;
        --
        delete
          from vw_csf_itemnf_dec_impor vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 44;
        --
        delete
          from vw_csf_itemnf_compl_transp vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 45;
        --
        delete
          from vw_csf_itemnf_export vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 46;
        --
        delete
          from vw_csf_itemnf_nve vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 47;
        --
        delete
          from vw_csf_itemnfe_compl_serv vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 48;
        --
        delete
          from vw_csf_itemnf_rastreab vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 49;
        --
        delete
          from vw_csf_itemnf_res_icms_st vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        --#75492
        vn_fase := 49.1;
        --
        delete
          from vw_csf_nf_inf_compl_op_ent_st vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        --#75492
        vn_fase := 49.2;
        --
        delete
          from vw_csf_nf_inf_compl_op_sai_st vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
     end loop;
     --
     vn_fase := 50;
     --
     delete
       from vw_csf_item_nota_fiscal vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 51;
     --
     for rec13 in c_nf_cana( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                          , rec.serie, rec.nro_nf ) loop
        exit when c_nf_cana%notfound or (c_nf_cana%notfound) is null;
        --
        delete
          from vw_csf_nf_aquis_cana_dia vc
         where vc.cpf_cnpj_emit     = rec13.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec13.dm_ind_emit
           and vc.dm_ind_oper       = rec13.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec13.cod_part,' ')
           and vc.cod_mod           = rec13.cod_mod
           and vc.serie             = rec13.serie
           and vc.nro_nf            = rec13.nro_nf
           and vc.safra             = rec13.safra
           and vc.mes_ano_ref       = rec13.mes_ano_ref;
        --
        vn_fase := 52;
        --
        delete
          from vw_csf_nf_aquis_cana_ded vc
         where vc.cpf_cnpj_emit     = rec13.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec13.dm_ind_emit
           and vc.dm_ind_oper       = rec13.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec13.cod_part,' ')
           and vc.cod_mod           = rec13.cod_mod
           and vc.serie             = rec13.serie
           and vc.nro_nf            = rec13.nro_nf
           and vc.safra             = rec13.safra
           and vc.mes_ano_ref       = rec13.mes_ano_ref;
        --
        vn_fase := 53;
        --
     end loop;
     --
     vn_fase := 54;
     --
     delete
       from vw_csf_nf_aquis_cana vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 55;
     --
     delete
       from vw_csf_inf_nf_romaneio vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 56;
     --
     for rec14 in c_nfinfor_fiscal( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                          , rec.serie, rec.nro_nf ) loop
        exit when c_nfinfor_fiscal%notfound or (c_nfinfor_fiscal%notfound) is null;
        --
        delete
          from vw_csf_inf_prov_docto_fiscal vc
         where vc.cpf_cnpj_emit     = rec14.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec14.dm_ind_emit
           and vc.dm_ind_oper       = rec14.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec14.cod_part,' ')
           and vc.cod_mod           = rec14.cod_mod
           and vc.serie             = rec14.serie
           and vc.nro_nf            = rec14.nro_nf;
        --
        vn_fase := 57;
        --
     end loop;
     --
     vn_fase := 58;
     --
     delete
       from vw_csf_nfinfor_fiscal vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 59;
     --
     for rec15 in c_nf_agend_trans( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                          , rec.serie, rec.nro_nf ) loop
        exit when c_nf_agend_trans%notfound or (c_nf_agend_trans%notfound) is null;
        --
        delete
          from vw_csf_nf_obs_agend_transp vc
         where vc.cpf_cnpj_emit     = rec15.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec15.dm_ind_emit
           and vc.dm_ind_oper       = rec15.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec15.cod_part,' ')
           and vc.cod_mod           = rec15.cod_mod
           and vc.serie             = rec15.serie
           and vc.nro_nf            = rec15.nro_nf;
        --
        vn_fase := 60;
        --
     end loop;
     --
     vn_fase := 61;
     --
     delete
       from vw_csf_nf_agend_transp vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 62;
     --
     delete
       from vw_csf_nf_aut_xml vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 63;
     --
     for rec16 in c_nf_forma_pgto( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                          , rec.serie, rec.nro_nf ) loop
        exit when c_nf_forma_pgto%notfound or (c_nf_forma_pgto%notfound) is null;
        --
        delete
          from vw_csf_nf_forma_pgto_ff vc
         where vc.cpf_cnpj_emit     = rec16.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec16.dm_ind_emit
           and vc.dm_ind_oper       = rec16.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec16.cod_part,' ')
           and vc.cod_mod           = rec16.cod_mod
           and vc.serie             = rec16.serie
           and vc.nro_nf            = rec16.nro_nf
           and nvl(vc.dm_tp_pag,0)  = nvl(rec16.dm_tp_pag,0)
           and vc.vl_pgto           = rec16.vl_pgto
           and nvl(vc.cnpj,' ')     = nvl(rec16.cnpj,' ')
           and nvl(vc.dm_tp_band,0) = nvl(rec16.dm_tp_band,0)
           and nvl(vc.nro_aut,' ')  = nvl(rec16.nro_aut,' ');
        --
        vn_fase := 64;
        --
     end loop;
     --
     vn_fase := 65;
     --
     delete
       from vw_csf_nf_forma_pgto vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 66;
     --
   end loop;
   --
   vn_fase := 67;
   --
   delete
     from vw_csf_nota_fiscal vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and vc.cod_mod = '55'
    /*  and ( (vc.dm_ind_emit = 0 and vc.dt_emiss between nvl(gd_dt_ini, vc.dt_emiss) and nvl(gd_dt_fin, vc.dt_emiss))
             or
            (vc.dm_ind_emit = 1 and nvl(vc.dt_sai_ent, vc.dt_emiss)
                                    between nvl(nvl(gd_dt_ini, vc.dt_sai_ent), vc.dt_emiss)
                                        and nvl(nvl(gd_dt_fin, vc.dt_sai_ent), vc.dt_emiss)) )*/
     ;
   --
   vn_fase := 68;
   --
   --|Limpando viwes de cancelamento|--
   for rec_canc in c_nf_canc loop
      exit when c_nf_canc%notfound or (c_nf_canc%notfound) is null;
      --
      delete
        from vw_csf_nota_fiscal_canc_ff vc
       where vc.cpf_cnpj_emit     = rec_canc.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec_canc.dm_ind_emit
         and vc.dm_ind_oper       = rec_canc.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec_canc.cod_part,' ')
         and vc.cod_mod           = rec_canc.cod_mod
         and vc.serie             = rec_canc.serie
         and vc.nro_nf            = rec_canc.nro_nf;
      --
      vn_fase := 69;
      --
   end loop;
   --
   vn_fase := 70;
   --
   delete
     from vw_csf_nota_fiscal_canc vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and vc.cod_mod = '55'
    ;
   --
   vn_fase := 71;
   --
   --|Limpando views de inutilização de notas|--
   for rec_inu in c_inutiliza_nf loop
      exit when c_inutiliza_nf%notfound or (c_inutiliza_nf%notfound) is null;
      --
      delete
        from vw_csf_inutiliza_notafiscal_ff vc
       where vc.cpf_cnpj_emit = rec_inu.cpf_cnpj_emit
         and vc.ano           = rec_inu.ano
         and vc.serie         = rec_inu.serie
         and vc.nro_ini       = rec_inu.nro_ini
         and vc.nro_fim       = rec_inu.nro_fim;
      --
      vn_fase := 72;
      --
   end loop;
   --
   vn_fase := 73;
   --
   delete
     from vw_csf_inutiliza_nota_fiscal vc
    where vc.cpf_cnpj_emit = gv_cnpj;
   --
   vn_fase := 74;
   --
   delete
     from vw_csf_nota_fiscal_cce vc
    where vc.cpf_cnpj_emit = gv_cnpj;
   --
   vn_fase := 75;
   --
   delete
     from vw_csf_cons_chave_nfe vc
    where vc.cpf_cnpj_emit = gv_cnpj;
   --
   vn_fase := 76;
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_nf_mercantis fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_nf_mercantis;

-------------------------------------------------------------------
--|PROCESSO QUE LIMPA INTEGRAÇÃO DE NOTAS FISCAIS MERCANTIS = 65|--
-------------------------------------------------------------------
/*#70990 criacao procedure*/
procedure pkb_limpa_nf_mercantis_nfce is
   --
   vn_fase number := 0;
   --
   cursor c_nf is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
        from vw_csf_nota_fiscal vc
       where vc.cpf_cnpj_emit = gv_cnpj
          and vc.cod_mod = '65' --#70990
         /*and ( (vc.dm_ind_emit = 0 and vc.dt_emiss between nvl(gd_dt_ini, vc.dt_emiss) and nvl(gd_dt_fin, vc.dt_emiss))
                or
               (vc.dm_ind_emit = 1 and nvl(vc.dt_sai_ent, vc.dt_emiss)
                                       between nvl(nvl(gd_dt_ini, vc.dt_sai_ent), vc.dt_emiss)
                                           and nvl(nvl(gd_dt_fin, vc.dt_sai_ent), vc.dt_emiss)) )*/ --nao existe parametro de data na tela
      order by 1 asc;
   --
   cursor c_nf_emit( ev_cpf_cnpj_emit in varchar2
                   , en_dm_ind_emit   in number
                   , en_dm_ind_oper   in number
                   , ev_cod_part      in varchar2
                   , ev_cod_mod       in varchar2
                   , ev_serie         in varchar2
                   , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
         from vw_csf_nota_fiscal_emit vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_nf_dest( ev_cpf_cnpj_emit in varchar2
                   , en_dm_ind_emit   in number
                   , en_dm_ind_oper   in number
                   , ev_cod_part      in varchar2
                   , ev_cod_mod       in varchar2
                   , ev_serie         in varchar2
                   , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
        from vw_csf_nota_fiscal_dest vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_nf_total( ev_cpf_cnpj_emit in varchar2
                    , en_dm_ind_emit   in number
                    , en_dm_ind_oper   in number
                    , ev_cod_part      in varchar2
                    , ev_cod_mod       in varchar2
                    , ev_serie         in varchar2
                    , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
        from vw_csf_nota_fiscal_total vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_nf_referen( ev_cpf_cnpj_emit in varchar2
                      , en_dm_ind_emit   in number
                      , en_dm_ind_oper   in number
                      , ev_cod_part      in varchar2
                      , ev_cod_mod       in varchar2
                      , ev_serie         in varchar2
                      , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
        from vw_csf_nota_fiscal_referen vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_nf_cobr( ev_cpf_cnpj_emit in varchar2
                   , en_dm_ind_emit   in number
                   , en_dm_ind_oper   in number
                   , ev_cod_part      in varchar2
                   , ev_cod_mod       in varchar2
                   , ev_serie         in varchar2
                   , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
           , vc.nro_fat
        from vw_csf_nota_fiscal_cobr vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_nf_transp( ev_cpf_cnpj_emit in varchar2
                     , en_dm_ind_emit   in number
                     , en_dm_ind_oper   in number
                     , ev_cod_part      in varchar2
                     , ev_cod_mod       in varchar2
                     , ev_serie         in varchar2
                     , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
        from vw_csf_nota_fiscal_transp vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_nftransp_vol( ev_cpf_cnpj_emit in varchar2
                        , en_dm_ind_emit   in number
                        , en_dm_ind_oper   in number
                        , ev_cod_part      in varchar2
                        , ev_cod_mod       in varchar2
                        , ev_serie         in varchar2
                        , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
           , vc.nro_vol
       from vw_csf_nftransp_vol vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_item_nf( ev_cpf_cnpj_emit in varchar2
                   , en_dm_ind_emit   in number
                   , en_dm_ind_oper   in number
                   , ev_cod_part      in varchar2
                   , ev_cod_mod       in varchar2
                   , ev_serie         in varchar2
                   , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
          ,  vc.dm_ind_emit
          ,  vc.dm_ind_oper
          ,  vc.cod_part
          ,  vc.cod_mod
          ,  vc.serie
          ,  vc.nro_nf
          ,  vc.nro_item
          ,  vc.cod_item
        from vw_csf_item_nota_fiscal vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_imp_itemnf( ev_cpf_cnpj_emit in varchar2
                      , en_dm_ind_emit   in number
                      , en_dm_ind_oper   in number
                      , ev_cod_part      in varchar2
                      , ev_cod_mod       in varchar2
                      , ev_serie         in varchar2
                      , en_nro_nf        in number
                      , en_nro_item      in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
           , vc.nro_item
           , vc.cod_imposto
        from vw_csf_imp_itemnf vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
         and vc.nro_item          = en_nro_item
      order by 1 asc;
   --
   cursor c_itemnf_comb( ev_cpf_cnpj_emit in varchar2
                       , en_dm_ind_emit   in number
                       , en_dm_ind_oper   in number
                       , ev_cod_part      in varchar2
                       , ev_cod_mod       in varchar2
                       , ev_serie         in varchar2
                       , en_nro_nf        in number
                       , en_nro_item      in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
           , vc.nro_item
        from vw_csf_itemnf_comb vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
         and vc.nro_item          = en_nro_item
      order by 1 asc;
   --
   cursor c_itemnf_decimpr( ev_cpf_cnpj_emit in varchar2
                          , en_dm_ind_emit   in number
                          , en_dm_ind_oper   in number
                          , ev_cod_part      in varchar2
                          , ev_cod_mod       in varchar2
                          , ev_serie         in varchar2
                          , en_nro_nf        in number
                          , en_nro_item      in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
           , vc.nro_item
           , vc.nro_di
      from vw_csf_itemnf_dec_impor vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
         and nvl(vc.nro_item,0)   = nvl(en_nro_item,0)
      order by 1 asc;
   --
   cursor c_itemnf_adic( ev_cpf_cnpj_emit in varchar2
                       , en_dm_ind_emit   in number
                       , en_dm_ind_oper   in number
                       , ev_cod_part      in varchar2
                       , ev_cod_mod       in varchar2
                       , ev_serie         in varchar2
                       , en_nro_nf        in number
                       , en_nro_item      in number
                       , ev_nro_di        in varchar2 )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
           , vc.nro_item
           , vc.nro_di
           , vc.nro_adicao
           , vc.nro_seq_adic
        from vw_csf_itemnfdi_adic vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
         and nvl(vc.nro_item,0)   = nvl(en_nro_item,0)
         and vc.nro_di            = ev_nro_di
      order by 1 asc;
   --
   cursor c_nf_cana( ev_cpf_cnpj_emit in varchar2
                   , en_dm_ind_emit   in number
                   , en_dm_ind_oper   in number
                   , ev_cod_part      in varchar2
                   , ev_cod_mod       in varchar2
                   , ev_serie         in varchar2
                   , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
           , vc.safra
           , vc.mes_ano_ref
        from vw_csf_nf_aquis_cana vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_nfinfor_fiscal( ev_cpf_cnpj_emit in varchar2
                          , en_dm_ind_emit   in number
                          , en_dm_ind_oper   in number
                          , ev_cod_part      in varchar2
                          , ev_cod_mod       in varchar2
                          , ev_serie         in varchar2
                          , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
        from vw_csf_nfinfor_fiscal vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_nf_agend_trans( ev_cpf_cnpj_emit in varchar2
                          , en_dm_ind_emit   in number
                          , en_dm_ind_oper   in number
                          , ev_cod_part      in varchar2
                          , ev_cod_mod       in varchar2
                          , ev_serie         in varchar2
                          , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
        from vw_csf_nf_agend_transp vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_nf_forma_pgto( ev_cpf_cnpj_emit in varchar2
                         , en_dm_ind_emit   in number
                         , en_dm_ind_oper   in number
                         , ev_cod_part      in varchar2
                         , ev_cod_mod       in varchar2
                         , ev_serie         in varchar2
                         , en_nro_nf        in number )
      is
      select vc.*
        from vw_csf_nf_forma_pgto vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.cod_mod           = ev_cod_mod
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   --|Viwes de cancelamento|--
   cursor c_nf_canc is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.nro_nf
        from vw_csf_nota_fiscal_canc vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and vc.cod_mod = '65' --#70990
      order by 1 asc;
   --
   --|Viwes de inutilização|--
   cursor c_inutiliza_nf is
      select vc.cpf_cnpj_emit
           , vc.ano
           , vc.serie
           , vc.nro_ini
           , vc.nro_fim
        from vw_csf_inutiliza_nota_fiscal vc
       where vc.cpf_cnpj_emit = gv_cnpj
      order by 1 asc;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_nf loop
     exit when c_nf%notfound or (c_nf%notfound) is null;
     --
     delete
       from vw_csf_nota_fiscal_ff vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 2;
     --
     delete
       from vw_csf_nota_fiscal_compl vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 3;
     --
     for rec_emit in c_nf_emit( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                          , rec.serie, rec.nro_nf ) loop
        exit when c_nf_emit%notfound or (c_nf_emit%notfound) is null;
        --
        delete
          from vw_csf_nota_fiscal_emit_ff vc
         where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec.dm_ind_emit
           and vc.dm_ind_oper       = rec.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
           and vc.cod_mod           = rec.cod_mod
           and vc.serie             = rec.serie
           and vc.nro_nf            = rec.nro_nf;
        --
        vn_fase := 3.2;
        --
     end loop;
     --
     vn_fase := 3.3;
     --
     delete
       from vw_csf_nota_fiscal_emit vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 4;
     --
     for rec2 in c_nf_dest( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                          , rec.serie, rec.nro_nf ) loop
        exit when c_nf_dest%notfound or (c_nf_dest%notfound) is null;
        --
        delete
          from vw_csf_nota_fiscal_dest_ff vc
         where vc.cpf_cnpj_emit     = rec2.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec2.dm_ind_emit
           and vc.dm_ind_oper       = rec2.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec2.cod_part,' ')
           and vc.cod_mod           = rec2.cod_mod
           and vc.serie             = rec2.serie
           and vc.nro_nf            = rec2.nro_nf;
        --
        vn_fase := 5;
        --
     end loop;
     --
     vn_fase := 6;
     --
     delete
       from vw_csf_nota_fiscal_dest vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 7;
     --
     delete
       from vw_csf_nfdest_email vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 8;
     --
     for rec3 in c_nf_total( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                          , rec.serie, rec.nro_nf ) loop
        exit when c_nf_total%notfound or (c_nf_total%notfound) is null;
        --
        delete
          from vw_csf_nota_fiscal_total_ff vc
        where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
          and vc.dm_ind_emit       = rec.dm_ind_emit
          and vc.dm_ind_oper       = rec.dm_ind_oper
          and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
          and vc.cod_mod           = rec.cod_mod
          and vc.serie             = rec.serie
          and vc.nro_nf            = rec.nro_nf;
        --
        vn_fase := 9;
        --
     end loop;
     --
     vn_fase := 10;
     --
     delete
       from vw_csf_nota_fiscal_total vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 11;
     --
     for rec4 in c_nf_referen( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                             , rec.serie, rec.nro_nf ) loop
        exit when c_nf_referen%notfound or (c_nf_referen%notfound) is null;
        --
        delete
          from vw_csf_nota_fiscal_referen_ff vc
         where vc.cpf_cnpj_emit     = rec4.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec4.dm_ind_emit
           and vc.dm_ind_oper       = rec4.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec4.cod_part,' ')
           and vc.cod_mod           = rec4.cod_mod
           and vc.serie             = rec4.serie
           and vc.nro_nf            = rec4.nro_nf;
        --
        vn_fase := 12;
        --
     end loop;
     --
     vn_fase := 13;
     --
     delete
       from vw_csf_nota_fiscal_referen vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 14;
     --
     delete
       from vw_csf_cupom_fiscal_ref vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 14.2;
     --
     delete
       from vw_csf_cfe_ref vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 15;
     --
     delete
       from vw_csf_nfinfor_adic vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 16;
     --
     for rec5 in c_nf_cobr( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                             , rec.serie, rec.nro_nf ) loop
        exit when c_nf_cobr%notfound or (c_nf_cobr%notfound) is null;
        --
        delete
          from vw_csf_nf_cobr_dup vc
         where vc.cpf_cnpj_emit    = rec5.cpf_cnpj_emit
          and vc.dm_ind_emit       = rec5.dm_ind_emit
          and vc.dm_ind_oper       = rec5.dm_ind_oper
          and nvl(vc.cod_part,' ') = nvl(rec5.cod_part,' ')
          and vc.cod_mod           = rec5.cod_mod
          and vc.serie             = rec5.serie
          and vc.nro_nf            = rec5.nro_nf
          and vc.nro_fat           = rec5.nro_fat;
        --
        vn_fase := 17;
        --
     end loop;
     --
     delete
       from vw_csf_nota_fiscal_cobr vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 18;
     --
     delete
      from vw_csf_nota_fiscal_local vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 18.1;
     --
     delete
      from vw_csf_nota_fiscal_local_ff vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 19;
     --
     for rec6 in c_nf_transp( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                             , rec.serie, rec.nro_nf ) loop
        exit when c_nf_transp%notfound or (c_nf_transp%notfound) is null;
        --
        delete
          from vw_csf_nftransp_veic vc
         where vc.cpf_cnpj_emit     = rec6.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec6.dm_ind_emit
           and vc.dm_ind_oper       = rec6.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec6.cod_part,' ')
           and vc.cod_mod           = rec6.cod_mod
           and vc.serie             = rec6.serie
           and vc.nro_nf            = rec.nro_nf;
        --
        vn_fase := 20;
        --
        for rec7 in c_nftransp_vol( rec6.cpf_cnpj_emit, rec6.dm_ind_emit, rec6.dm_ind_oper, rec6.cod_part, rec6.cod_mod
                             , rec6.serie, rec6.nro_nf ) loop
           exit when c_nftransp_vol%notfound or (c_nftransp_vol%notfound) is null;
           --
           delete
             from VW_csf_nftranspvol_lacre vc
            where vc.cpf_cnpj_emit     = rec7.cpf_cnpj_emit
              and vc.dm_ind_emit       = rec7.dm_ind_emit
              and vc.dm_ind_oper       = rec7.dm_ind_oper
              and nvl(vc.cod_part,' ') = nvl(rec7.cod_part,' ')
              and vc.cod_mod           = rec7.cod_mod
              and vc.serie             = rec7.serie
              and vc.nro_nf            = rec7.nro_nf
              and vc.nro_vol           = rec7.nro_vol;
           --
           vn_fase := 21;
           --
        end loop;
        --
        vn_fase := 22;
        --
        delete
          from vw_csf_nftransp_vol vc
         where vc.cpf_cnpj_emit     = rec6.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec6.dm_ind_emit
           and vc.dm_ind_oper       = rec6.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec6.cod_part,' ')
           and vc.cod_mod           = rec6.cod_mod
           and vc.serie             = rec6.serie
           and vc.nro_nf            = rec6.nro_nf;
        --
        vn_fase := 23;
        --
     end loop;
     --
     vn_fase := 24;
     --
     delete
       from vw_csf_nota_fiscal_transp vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 25;
     --
     for rec8 in c_item_nf( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                             , rec.serie, rec.nro_nf ) loop
        exit when c_item_nf%notfound or (c_item_nf%notfound) is null;
        --
        delete
          from vw_csf_item_nota_fiscal_ff vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item
           and vc.cod_item          = rec8.cod_item;
        --
        vn_fase := 26;
        --
        delete
          from vw_csf_itemnf_compl vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 27;
        --
        delete
          from vw_csf_itemnf_dif_aliq vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 28;
        --
        for rec9 in c_imp_itemnf( rec8.cpf_cnpj_emit, rec8.dm_ind_emit, rec8.dm_ind_oper, rec8.cod_part, rec8.cod_mod
                             , rec8.serie, rec8.nro_nf, rec8.nro_item ) loop
           exit when c_imp_itemnf%notfound or (c_imp_itemnf%notfound) is null;
           --
           delete
             from vw_csf_imp_itemnf_ff vc
             where vc.cpf_cnpj_emit     = rec9.cpf_cnpj_emit
               and vc.dm_ind_emit       = rec9.dm_ind_emit
               and vc.dm_ind_oper       = rec9.dm_ind_oper
               and nvl(vc.cod_part,' ') = nvl(rec9.cod_part,' ')
               and vc.cod_mod           = rec9.cod_mod
               and vc.serie             = rec9.serie
               and vc.nro_nf            = rec9.nro_nf
               and vc.nro_item          = rec9.nro_item
               and vc.cod_imposto       = rec9.cod_imposto;
           --
           vn_fase := 29;
           --
           delete
             from vw_csf_imp_itemnf_icms_dest vc
             where vc.cpf_cnpj_emit     = rec9.cpf_cnpj_emit
               and vc.dm_ind_emit       = rec9.dm_ind_emit
               and vc.dm_ind_oper       = rec9.dm_ind_oper
               and nvl(vc.cod_part,' ') = nvl(rec9.cod_part,' ')
               and vc.cod_mod           = rec9.cod_mod
               and vc.serie             = rec9.serie
               and vc.nro_nf            = rec9.nro_nf
               and vc.nro_item          = rec9.nro_item
               and vc.cod_imposto       = rec9.cod_imposto;
           --
           vn_fase := 30;
           --
        end loop;
        --
        vn_fase := 31;
        --
        delete
          from vw_csf_imp_itemnf vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 32;
        --
        for rec10 in c_itemnf_comb( rec8.cpf_cnpj_emit, rec8.dm_ind_emit, rec8.dm_ind_oper, rec8.cod_part, rec8.cod_mod
                             , rec8.serie, rec8.nro_nf, rec8.nro_item ) loop
           exit when c_itemnf_comb%notfound or (c_itemnf_comb%notfound) is null;
           --
           delete
             from vw_csf_itemnf_comb_ff vc
            where vc.cpf_cnpj_emit     = rec10.cpf_cnpj_emit
              and vc.dm_ind_emit       = rec10.dm_ind_emit
              and vc.dm_ind_oper       = rec10.dm_ind_oper
              and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
              and vc.cod_mod           = rec10.cod_mod
              and vc.serie             = rec10.serie
              and vc.nro_nf            = rec10.nro_nf
              and vc.nro_item          = rec10.nro_item;
           --
           vn_fase := 33;
           --
        end loop;
        --
        vn_fase := 34;
        --
        delete
          from vw_csf_itemnf_comb vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 35;
        --
        delete
          from vw_csf_itemnf_veic vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 36;
        --
        delete
          from vw_csf_itemnf_med vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 37;
        --
        delete
          from vw_csf_itemnf_arma vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 38;
        --
        for rec11 in c_itemnf_decimpr( rec8.cpf_cnpj_emit, rec8.dm_ind_emit, rec8.dm_ind_oper, rec8.cod_part, rec8.cod_mod
                             , rec8.serie, rec8.nro_nf, rec8.nro_item ) loop
           exit when c_itemnf_decimpr%notfound or (c_itemnf_decimpr%notfound) is null;
           --
           delete
             from vw_csf_itemnf_dec_impor_ff vc
            where vc.cpf_cnpj_emit     = rec11.cpf_cnpj_emit
              and vc.dm_ind_emit       = rec11.dm_ind_emit
              and vc.dm_ind_oper       = rec11.dm_ind_oper
              and nvl(vc.cod_part,' ') = nvl(rec11.cod_part,' ')
              and vc.cod_mod           = rec11.cod_mod
              and vc.serie             = rec11.serie
              and vc.nro_nf            = rec11.nro_nf
              and nvl(vc.nro_item,0)   = nvl(rec11.nro_item,0)
              and vc.nro_di            = rec11.nro_di;
           --
           vn_fase := 39;
           --
           for rec12 in c_itemnf_adic( rec11.cpf_cnpj_emit, rec11.dm_ind_emit, rec11.dm_ind_oper, rec11.cod_part, rec11.cod_mod
                             , rec11.serie, rec11.nro_nf, rec11.nro_item, rec11.nro_di ) loop
              exit when c_itemnf_adic%notfound or (c_itemnf_adic%notfound) is null;
              --
              delete
                from vw_csf_itemnfdi_adic_ff vc
              where vc.cpf_cnpj_emit     = rec12.cpf_cnpj_emit
                and vc.dm_ind_emit       = rec12.dm_ind_emit
                and vc.dm_ind_oper       = rec12.dm_ind_oper
                and nvl(vc.cod_part,' ') = nvl(rec12.cod_part,' ')
                and vc.cod_mod           = rec12.cod_mod
                and vc.serie             = rec12.serie
                and vc.nro_nf            = rec12.nro_nf
                and nvl(vc.nro_item,0)   = nvl(rec12.nro_item,0)
                and vc.nro_di            = rec12.nro_di
                and vc.nro_adicao        = rec12.nro_adicao;
              --
              vn_fase := 40;
              --
           end loop;
           --
           vn_fase := 41;
           --
           delete
             from vw_csf_itemnfdi_adic vc
            where vc.cpf_cnpj_emit     = rec11.cpf_cnpj_emit
              and vc.dm_ind_emit       = rec11.dm_ind_emit
              and vc.dm_ind_oper       = rec11.dm_ind_oper
              and nvl(vc.cod_part,' ') = nvl(rec11.cod_part,' ')
              and vc.cod_mod           = rec11.cod_mod
              and vc.serie             = rec11.serie
              and vc.nro_nf            = rec11.nro_nf
              and nvl(vc.nro_item,0)   = nvl(rec11.nro_item,0)
              and vc.nro_di            = rec11.nro_di;
           --
           vn_fase := 42;
           --
        end loop;
        --
        vn_fase := 43;
        --
        delete
          from vw_csf_itemnf_dec_impor vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 44;
        --
        delete
          from vw_csf_itemnf_compl_transp vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 45;
        --
        delete
          from vw_csf_itemnf_export vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 46;
        --
        delete
          from vw_csf_itemnf_nve vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 47;
        --
        delete
          from vw_csf_itemnfe_compl_serv vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 48;
        --
        delete
          from vw_csf_itemnf_rastreab vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
        vn_fase := 49;
        --
        delete
          from vw_csf_itemnf_res_icms_st vc
         where vc.cpf_cnpj_emit     = rec8.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec8.dm_ind_emit
           and vc.dm_ind_oper       = rec8.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec8.cod_part,' ')
           and vc.cod_mod           = rec8.cod_mod
           and vc.serie             = rec8.serie
           and vc.nro_nf            = rec8.nro_nf
           and vc.nro_item          = rec8.nro_item;
        --
     end loop;
     --
     vn_fase := 50;
     --
     delete
       from vw_csf_item_nota_fiscal vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 51;
     --
     for rec13 in c_nf_cana( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                          , rec.serie, rec.nro_nf ) loop
        exit when c_nf_cana%notfound or (c_nf_cana%notfound) is null;
        --
        delete
          from vw_csf_nf_aquis_cana_dia vc
         where vc.cpf_cnpj_emit     = rec13.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec13.dm_ind_emit
           and vc.dm_ind_oper       = rec13.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec13.cod_part,' ')
           and vc.cod_mod           = rec13.cod_mod
           and vc.serie             = rec13.serie
           and vc.nro_nf            = rec13.nro_nf
           and vc.safra             = rec13.safra
           and vc.mes_ano_ref       = rec13.mes_ano_ref;
        --
        vn_fase := 52;
        --
        delete
          from vw_csf_nf_aquis_cana_ded vc
         where vc.cpf_cnpj_emit     = rec13.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec13.dm_ind_emit
           and vc.dm_ind_oper       = rec13.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec13.cod_part,' ')
           and vc.cod_mod           = rec13.cod_mod
           and vc.serie             = rec13.serie
           and vc.nro_nf            = rec13.nro_nf
           and vc.safra             = rec13.safra
           and vc.mes_ano_ref       = rec13.mes_ano_ref;
        --
        vn_fase := 53;
        --
     end loop;
     --
     vn_fase := 54;
     --
     delete
       from vw_csf_nf_aquis_cana vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 55;
     --
     delete
       from vw_csf_inf_nf_romaneio vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 56;
     --
     for rec14 in c_nfinfor_fiscal( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                          , rec.serie, rec.nro_nf ) loop
        exit when c_nfinfor_fiscal%notfound or (c_nfinfor_fiscal%notfound) is null;
        --
        delete
          from vw_csf_inf_prov_docto_fiscal vc
         where vc.cpf_cnpj_emit     = rec14.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec14.dm_ind_emit
           and vc.dm_ind_oper       = rec14.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec14.cod_part,' ')
           and vc.cod_mod           = rec14.cod_mod
           and vc.serie             = rec14.serie
           and vc.nro_nf            = rec14.nro_nf;
        --
        vn_fase := 57;
        --
     end loop;
     --
     vn_fase := 58;
     --
     delete
       from vw_csf_nfinfor_fiscal vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 59;
     --
     for rec15 in c_nf_agend_trans( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                          , rec.serie, rec.nro_nf ) loop
        exit when c_nf_agend_trans%notfound or (c_nf_agend_trans%notfound) is null;
        --
        delete
          from vw_csf_nf_obs_agend_transp vc
         where vc.cpf_cnpj_emit     = rec15.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec15.dm_ind_emit
           and vc.dm_ind_oper       = rec15.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec15.cod_part,' ')
           and vc.cod_mod           = rec15.cod_mod
           and vc.serie             = rec15.serie
           and vc.nro_nf            = rec15.nro_nf;
        --
        vn_fase := 60;
        --
     end loop;
     --
     vn_fase := 61;
     --
     delete
       from vw_csf_nf_agend_transp vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 62;
     --
     delete
       from vw_csf_nf_aut_xml vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 63;
     --
     for rec16 in c_nf_forma_pgto( rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.cod_mod
                          , rec.serie, rec.nro_nf ) loop
        exit when c_nf_forma_pgto%notfound or (c_nf_forma_pgto%notfound) is null;
        --
        delete
          from vw_csf_nf_forma_pgto_ff vc
         where vc.cpf_cnpj_emit     = rec16.cpf_cnpj_emit
           and vc.dm_ind_emit       = rec16.dm_ind_emit
           and vc.dm_ind_oper       = rec16.dm_ind_oper
           and nvl(vc.cod_part,' ') = nvl(rec16.cod_part,' ')
           and vc.cod_mod           = rec16.cod_mod
           and vc.serie             = rec16.serie
           and vc.nro_nf            = rec16.nro_nf
           and nvl(vc.dm_tp_pag,0)  = nvl(rec16.dm_tp_pag,0)
           and vc.vl_pgto           = rec16.vl_pgto
           and nvl(vc.cnpj,' ')     = nvl(rec16.cnpj,' ')
           and nvl(vc.dm_tp_band,0) = nvl(rec16.dm_tp_band,0)
           and nvl(vc.nro_aut,' ')  = nvl(rec16.nro_aut,' ');
        --
        vn_fase := 64;
        --
     end loop;
     --
     vn_fase := 65;
     --
     delete
       from vw_csf_nf_forma_pgto vc
      where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
        and vc.dm_ind_emit       = rec.dm_ind_emit
        and vc.dm_ind_oper       = rec.dm_ind_oper
        and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
        and vc.cod_mod           = rec.cod_mod
        and vc.serie             = rec.serie
        and vc.nro_nf            = rec.nro_nf;
     --
     vn_fase := 66;
     --
   end loop;
   --
   vn_fase := 67;
   --
   delete
     from vw_csf_nota_fiscal vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and vc.cod_mod = '65'
    /*  and ( (vc.dm_ind_emit = 0 and vc.dt_emiss between nvl(gd_dt_ini, vc.dt_emiss) and nvl(gd_dt_fin, vc.dt_emiss))
             or
            (vc.dm_ind_emit = 1 and nvl(vc.dt_sai_ent, vc.dt_emiss)
                                    between nvl(nvl(gd_dt_ini, vc.dt_sai_ent), vc.dt_emiss)
                                        and nvl(nvl(gd_dt_fin, vc.dt_sai_ent), vc.dt_emiss)) )*/
     ;
   --
   vn_fase := 68;
   --
   --|Limpando viwes de cancelamento|--
   for rec_canc in c_nf_canc loop
      exit when c_nf_canc%notfound or (c_nf_canc%notfound) is null;
      --
      delete
        from vw_csf_nota_fiscal_canc_ff vc
       where vc.cpf_cnpj_emit     = rec_canc.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec_canc.dm_ind_emit
         and vc.dm_ind_oper       = rec_canc.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec_canc.cod_part,' ')
         and vc.cod_mod           = rec_canc.cod_mod
         and vc.serie             = rec_canc.serie
         and vc.nro_nf            = rec_canc.nro_nf;
      --
      vn_fase := 69;
      --
   end loop;
   --
   vn_fase := 70;
   --
   delete
     from vw_csf_nota_fiscal_canc vc
    where vc.cpf_cnpj_emit = gv_cnpj
    and vc.cod_mod = '65'
    ;
   --
   vn_fase := 71;
   --
   --|Limpando views de inutilização de notas|--
   for rec_inu in c_inutiliza_nf loop
      exit when c_inutiliza_nf%notfound or (c_inutiliza_nf%notfound) is null;
      --
      delete
        from vw_csf_inutiliza_notafiscal_ff vc
       where vc.cpf_cnpj_emit = rec_inu.cpf_cnpj_emit
         and vc.ano           = rec_inu.ano
         and vc.serie         = rec_inu.serie
         and vc.nro_ini       = rec_inu.nro_ini
         and vc.nro_fim       = rec_inu.nro_fim;
      --
      vn_fase := 72;
      --
   end loop;
   --
   vn_fase := 73;
   --
   delete
     from vw_csf_inutiliza_nota_fiscal vc
    where vc.cpf_cnpj_emit = gv_cnpj;
   --
   vn_fase := 74;
   --
   delete
     from vw_csf_nota_fiscal_cce vc
    where vc.cpf_cnpj_emit = gv_cnpj;
   --
   vn_fase := 75;
   --
   delete
     from vw_csf_cons_chave_nfe vc
    where vc.cpf_cnpj_emit = gv_cnpj;
   --
   vn_fase := 76;
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_nf_mercantis_nfce fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_nf_mercantis_nfce;

-------------------------------------------------------------------------
--|PROCESSO QUE LIMPA INTEGRAÇÃO DE NOTAS FISCAIS DE SERVIÇOS EFD = 7|--
-------------------------------------------------------------------------
/*Leiaute_Views_Integracao_Fiscal_Servico_V2.13*/
procedure pkb_limpa_notas_serv
 is
   --
   vn_fase number := 0;
   --
   cursor c_nf_serv is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.serie
           , vc.nro_nf
        from vw_csf_nota_fiscal_serv vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and ( (vc.dm_ind_emit = 0 and trunc(vc.dt_emiss) between nvl(gd_dt_ini, vc.dt_emiss) and nvl(gd_dt_fin, vc.dt_emiss))
                or
               (vc.dm_ind_emit = 1 and trunc(nvl(vc.dt_sai_ent, vc.dt_emiss))
                                       between nvl(nvl(gd_dt_ini, vc.dt_sai_ent), vc.dt_emiss)
                                           and nvl(nvl(gd_dt_fin, vc.dt_sai_ent), vc.dt_emiss)) )
      order by 1 asc;
   --
   cursor c_compl_serv( ev_cpf_cnpj_emit in varchar2
                      , en_dm_ind_emit   in number
                      , en_dm_ind_oper   in number
                      , ev_cod_part      in varchar2
                      , ev_serie         in varchar2
                      , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.serie
           , vc.nro_nf
        from vw_csf_itemnf_compl_serv vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   cursor c_itemnf_serv( ev_cpf_cnpj_emit in varchar2
                       , en_dm_ind_emit   in number
                       , en_dm_ind_oper   in number
                       , ev_cod_part      in varchar2
                       , ev_serie         in varchar2
                       , en_nro_nf        in number )
      is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.serie
           , vc.nro_nf
           , vc.nro_item
           , vc.cod_imposto
           , vc.dm_tipo
        from vw_csf_imp_itemnf_serv vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_emit       = en_dm_ind_emit
         and vc.dm_ind_oper       = en_dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(ev_cod_part,' ')
         and vc.serie             = ev_serie
         and vc.nro_nf            = en_nro_nf
      order by 1 asc;
   --
   --| Limpeza das views de cancelamento|--
   cursor c_nf_canc is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_emit
           , vc.dm_ind_oper
           , vc.cod_part
           , vc.serie
           , vc.nro_nf
        from vw_csf_nf_canc_serv vc
       where vc.cpf_cnpj_emit = gv_cnpj;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_nf_serv loop
      exit when c_nf_serv%notfound or (c_nf_serv%notfound) is null;
      --
      delete
        from vw_csf_nota_fiscal_serv_ff vc
       where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec.dm_ind_emit
         and vc.dm_ind_oper       = rec.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
         and vc.serie             = rec.serie
         and vc.nro_nf            = rec.nro_nf;
      --
      vn_fase := 2;
      --
      for rec2 in c_compl_serv(rec.cpf_cnpj_emit, rec.dm_ind_emit, rec.dm_ind_oper, rec.cod_part, rec.serie, rec.nro_nf) loop
         exit when c_compl_serv%notfound or (c_compl_serv%notfound) is null;
         --
         delete
           from vw_csf_itemnf_compl_serv_ff vc
          where vc.cpf_cnpj_emit     = rec2.cpf_cnpj_emit
            and vc.dm_ind_emit       = rec2.dm_ind_emit
            and vc.dm_ind_oper       = rec2.dm_ind_oper
            and nvl(vc.cod_part,' ') = nvl(rec2.cod_part,' ')
            and vc.serie             = rec2.serie
            and vc.nro_nf            = rec2.nro_nf;
         --
         vn_fase := 3;
         --
         for rec3 in c_itemnf_serv(rec2.cpf_cnpj_emit, rec2.dm_ind_emit, rec2.dm_ind_oper, rec2.cod_part, rec2.serie, rec2.nro_nf) loop
            exit when c_itemnf_serv%notfound or (c_itemnf_serv%notfound) is null;
            --
            delete
              from vw_csf_imp_itemnf_serv_ff vc
             where vc.cpf_cnpj_emit     = rec3.cpf_cnpj_emit
               and vc.dm_ind_emit       = rec3.dm_ind_emit
               and vc.dm_ind_oper       = rec3.dm_ind_oper
               and nvl(vc.cod_part,' ') = nvl(rec3.cod_part,' ')
               and vc.serie             = rec3.serie
               and vc.nro_nf            = rec3.nro_nf
               and vc.nro_item          = rec3.nro_item
               and vc.cod_imposto       = rec3.cod_imposto
               and vc.dm_tipo           = rec3.dm_tipo;
            --
            vn_fase := 4;
            --
         end loop;
         --
         vn_fase := 5;
         --
         delete
           from vw_csf_imp_itemnf_serv vc
          where vc.cpf_cnpj_emit     = rec2.cpf_cnpj_emit
            and vc.dm_ind_emit       = rec2.dm_ind_emit
            and vc.dm_ind_oper       = rec2.dm_ind_oper
            and nvl(vc.cod_part,' ') = nvl(rec2.cod_part,' ')
            and vc.serie             = rec2.serie
            and vc.nro_nf            = rec2.nro_nf;
         --
         vn_fase := 6;
         --
      end loop;
      --
      vn_fase := 7;
      --
      delete
        from vw_csf_itemnf_compl_serv vc
       where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec.dm_ind_emit
         and vc.dm_ind_oper       = rec.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
         and vc.serie             = rec.serie
         and vc.nro_nf            = rec.nro_nf;
      --
      vn_fase := 8;
      --
      delete
        from vw_csf_nfinfor_adic_serv vc
       where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec.dm_ind_emit
         and vc.dm_ind_oper       = rec.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
         and vc.serie             = rec.serie
         and vc.nro_nf            = rec.nro_nf;
      --
      vn_fase := 9;
      --
      delete
        from vw_csf_nf_dest_serv vc
       where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec.dm_ind_emit
         and vc.dm_ind_oper       = rec.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
         and vc.serie             = rec.serie
         and vc.nro_nf            = rec.nro_nf;
      --
      vn_fase := 10;
      --
      delete
        from vw_csf_nf_inter_serv vc
       where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec.dm_ind_emit
         and vc.dm_ind_oper       = rec.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
         and vc.serie             = rec.serie
         and vc.nro_nf            = rec.nro_nf;
      --
      vn_fase := 11;
      --
      delete
        from vw_csf_nfs_det_constr_civil vc
       where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec.dm_ind_emit
         and vc.dm_ind_oper       = rec.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
         and vc.serie             = rec.serie
         and vc.nro_nf            = rec.nro_nf;
      --
      vn_fase := 12;
      --
      delete
        from vw_csf_nf_cobr_dup_serv vc
       where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec.dm_ind_emit
         and vc.dm_ind_oper       = rec.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
         and vc.serie             = rec.serie
         and vc.nro_nf            = rec.nro_nf;
      --
      vn_fase := 13;
      --
      delete
        from vw_csf_nota_fiscal_compl_serv vc
       where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec.dm_ind_emit
         and vc.dm_ind_oper       = rec.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
         and vc.serie             = rec.serie
         and vc.nro_nf            = rec.nro_nf;
      --
      vn_fase := 14;
      --
      delete
        from vw_csf_nf_proc_reinf vc
       where vc.cpf_cnpj_emit     = rec.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec.dm_ind_emit
         and vc.dm_ind_oper       = rec.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec.cod_part,' ')
         and vc.serie             = rec.serie
         and vc.nro_nf            = rec.nro_nf;
      --
      vn_fase := 15;
   end loop;
   --
   delete
     from vw_csf_nota_fiscal_serv vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and ( (vc.dm_ind_emit = 0 and trunc(vc.dt_emiss) between nvl(gd_dt_ini, vc.dt_emiss) and nvl(gd_dt_fin, vc.dt_emiss))
             or
            (vc.dm_ind_emit = 1 and trunc(nvl(vc.dt_sai_ent, vc.dt_emiss))
                                    between nvl(nvl(gd_dt_ini, vc.dt_sai_ent), vc.dt_emiss)
                                        and nvl(nvl(gd_dt_fin, vc.dt_sai_ent), vc.dt_emiss)) );
   --
   vn_fase := 20;
   --
   --| Limpeza dos viwes de cancelamento|--
   for rec_canc in c_nf_canc loop
      exit when c_nf_canc%notfound or(c_nf_canc%notfound) is null;
      --
      delete
        from vw_csf_nf_canc_serv_ff vc
       where vc.cpf_cnpj_emit     = rec_canc.cpf_cnpj_emit
         and vc.dm_ind_emit       = rec_canc.dm_ind_emit
         and vc.dm_ind_oper       = rec_canc.dm_ind_oper
         and nvl(vc.cod_part,' ') = nvl(rec_canc.cod_part,' ')
         and vc.serie             = rec_canc.serie
         and vc.nro_nf            = rec_canc.nro_nf;
      --
      vn_fase := 21;
      --
   end loop;
   --
   vn_fase := 22;
   --
   delete
     from vw_csf_nf_canc_serv vc
    where vc.cpf_cnpj_emit = gv_cnpj;
   --
   vn_fase := 23;
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_notas_serv fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_notas_serv;

----------------------------------------------------------------
--|PROCESSO QUE LIMPA INTEGRAÇÃO DE CIAP = 8|--
----------------------------------------------------------------
/*Leiaute_Views_Integracao_CIAP_V1_4*/
procedure pkb_limpa_ciap is
   --
   vn_fase number := 0;
   --
   cursor c_ciap is
      select vc.cpf_cnpj_emit
           , vc.dt_ini
           , vc.dt_fin
        from vw_csf_icms_atperm_ciap vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and vc.dt_ini >= nvl(gd_dt_ini, vc.dt_ini)
         and vc.dt_fin <= nvl(gd_dt_fin, vc.dt_fin)
      order by 1 asc;
   --
   cursor c_mov( en_cpf_cnpj_emit in varchar2
               , ed_dt_ini        in date
               , ed_dt_fin        in date )
      is
      select vc.cpf_cnpj_emit
           , vc.dt_ini
           , vc.dt_fin
           , vc.cod_ind_bem
           , vc.dm_tipo_mov
        from vw_csf_mov_atperm vc
       where vc.cpf_cnpj_emit = en_cpf_cnpj_emit
         and vc.dt_ini        = ed_dt_ini
         and vc.dt_fin        = ed_dt_fin
      order by 1 asc;
   --
   cursor c_mov_atperm( en_cpf_cnpj_emit in varchar2
                      , ed_dt_ini        in date
                      , ed_dt_fin        in date
                      , ev_cod_ind_bem   in varchar2
                      , ev_dm_tipo_mov   in varchar2 )
      is
      select vc.cpf_cnpj_emit
           , vc.dt_ini
           , vc.dt_fin
           , vc.cod_ind_bem
           , vc.dm_tipo_mov
           , vc.dm_ind_emit
           , vc.cod_part
           , vc.cod_mod
           , vc.serie
           , vc.num_doc
           , vc.chv_nfe_cte
        from vw_csf_mov_atperm_doc_fiscal vc
       where vc.cpf_cnpj_emit = en_cpf_cnpj_emit
         and vc.dt_ini        = ed_dt_ini
         and vc.dt_fin        = ed_dt_fin
         and vc.cod_ind_bem   = ev_cod_ind_bem
         and vc.dm_tipo_mov   = ev_dm_tipo_mov
      order by 1 asc;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_ciap loop
     exit when c_ciap%notfound or(c_ciap%notfound) is null;
     --
     delete
       from vw_csf_icms_atperm_ciap_ff vc
      where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
        and vc.dt_ini        = rec.dt_ini
        and vc.dt_fin        = rec.dt_fin;
     --
     vn_fase := 2;
     --
     for rec2 in c_mov(rec.cpf_cnpj_emit, rec.dt_ini, rec.dt_fin) loop
        exit when c_mov%notfound or (c_mov%notfound) is null;
        --
        delete
          from vw_csf_outro_cred_ciap vc
         where vc.cpf_cnpj_emit = rec2.cpf_cnpj_emit
           and vc.dt_ini        = rec2.dt_ini
           and vc.dt_fin        = rec2.dt_fin
           and vc.cod_ind_bem   = rec2.cod_ind_bem
           and vc.dm_tipo_mov   = rec2.dm_tipo_mov;
        --
        vn_fase := 3;
        --
        for rec3 in c_mov_atperm(rec2.cpf_cnpj_emit, rec2.dt_ini, rec2.dt_fin, rec2.cod_ind_bem, rec2.dm_tipo_mov) loop
           exit when c_mov_atperm%notfound or (c_mov_atperm%notfound) is null;
           --
           delete
             from vw_csf_movatpermdocfiscal_item vc
            where vc.cpf_cnpj_emit         = rec3.cpf_cnpj_emit
              and vc.dt_ini                = rec3.dt_ini
              and vc.dt_fin                = rec3.dt_fin
              and vc.cod_ind_bem           = rec3.cod_ind_bem
              and vc.dm_tipo_mov           = rec3.dm_tipo_mov
              and vc.dm_ind_emit           = rec3.dm_ind_emit
              and vc.cod_part              = rec3.cod_part
              and vc.cod_mod               = rec3.cod_mod
              and vc.serie                 = rec3.serie
              and vc.num_doc               = rec3.num_doc
              and nvl(vc.chv_nfe_cte, ' ') = nvl(rec3.chv_nfe_cte, ' ');
           --
           vn_fase := 4;
           --
        end loop;
        --
        vn_fase := 5;
        --
        delete
          from vw_csf_mov_atperm_doc_fiscal vc
         where vc.cpf_cnpj_emit = rec2.cpf_cnpj_emit
           and vc.dt_ini        = rec2.dt_ini
           and vc.dt_fin        = rec2.dt_fin
           and vc.cod_ind_bem   = rec2.cod_ind_bem
           and vc.dm_tipo_mov   = rec2.dm_tipo_mov;
        --
        vn_fase := 6;
        --
      end loop;
      --
      vn_fase := 7;
      --
      delete
        from vw_csf_mov_atperm vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.dt_ini        = rec.dt_ini
         and vc.dt_fin        = rec.dt_fin;
      --
      vn_fase := 8;
      --
   end loop;
   --
   vn_fase := 9;
   --
   delete
     from vw_csf_icms_atperm_ciap vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and vc.dt_ini >= nvl(gd_dt_ini, vc.dt_ini)
      and vc.dt_fin <= nvl(gd_dt_fin, vc.dt_fin);
   --
   vn_fase := 10;
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_ciap fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_ciap;

----------------------------------------------------------------
--|PROCESSO QUE LIMPA CRÉDITO ACUMULADO ICMS SP (ECREDAC) = 9|--
----------------------------------------------------------------
/*Leiaute_Integracao_Ecredac_v2.1*/
procedure pkb_limpa_ecredac is
   --
   vn_fase number := 0;
   --
   cursor c_ecredac is
      select vc.cnpj_emit
           , vc.nro_op
        from vw_csf_op_cab vc
       where vc.cnpj_emit = gv_cnpj
         and vc.dt_refer between nvl(gd_dt_ini, vc.dt_refer) and nvl(gd_dt_fin, vc.dt_refer)
      order by 1 asc;
   --
   cursor c_mov is
      select vc.cnpj_emit
           , vc.nro_doc
        from vw_csf_mov_transf vc
       where vc.cnpj_emit = gv_cnpj
         and vc.dt_refer between nvl(gd_dt_ini, vc.dt_refer) and nvl(gd_dt_fin, vc.dt_refer)
      order by 1 asc;
   --
   cursor c_dados is
      select vc.cod_legal
        from vw_csf_enq_leg_cred_acmicmssp vc
       where vc.dt_refer between nvl(gd_dt_ini, vc.dt_refer) and nvl(gd_dt_fin, vc.dt_refer)
      order by 1 asc;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_ecredac loop
      exit when c_ecredac%notfound or (c_ecredac%notfound) is null;
      --
      delete
        from vw_csf_op_cab_ff vc
       where vc.cnpj_emit = rec.cnpj_emit
         and vc.nro_op    = rec.nro_op;
      --
      vn_fase := 1.2;
      --
   end loop;
   --
   vn_fase := 2;
   --
   delete
     from vw_csf_op_cab vc
    where vc.cnpj_emit = gv_cnpj
         and vc.dt_refer between nvl(gd_dt_ini, vc.dt_refer) and nvl(gd_dt_fin, vc.dt_refer);
   --
   vn_fase := 3;
   --
   delete
     from vw_csf_mov_op vc
    where vc.cnpj_emit = gv_cnpj
      and vc.dt_refer between nvl(gd_dt_ini, vc.dt_refer) and nvl(gd_dt_fin, vc.dt_refer);
   --
   vn_fase := 4;
   --
   delete
     from vw_csf_movop_itemnf vc
    where vc.cnpj_emit = gv_cnpj
      and vc.dt_refer between nvl(gd_dt_ini, vc.dt_refer) and nvl(gd_dt_fin, vc.dt_refer);
   --
   vn_fase := 5;
   --
   delete
     from vw_csf_prod_op vc
    where vc.cnpj_emit = gv_cnpj
      and vc.dt_refer between nvl(gd_dt_ini, vc.dt_refer) and nvl(gd_dt_fin, vc.dt_refer);
   --
   vn_fase := 6;
   --
   delete
     from vw_csf_prodop_detalhe vc
    where vc.cnpj_emit = gv_cnpj
      and vc.dt_refer between nvl(gd_dt_ini, vc.dt_refer) and nvl(gd_dt_fin, vc.dt_refer);
   --
   vn_fase := 7;
   --
   delete
    from vw_csf_prodop_movop vc
    where vc.cnpj_emit_prodop = gv_cnpj
      and vc.dt_refer between nvl(gd_dt_ini, vc.dt_refer) and nvl(gd_dt_fin, vc.dt_refer);
   --
   vn_fase := 8;
   --
   delete
     from vw_csf_frete_itemnf vc
    where vc.cnpj_emit_frete = gv_cnpj
      and vc.dt_refer between nvl(gd_dt_ini, vc.dt_refer) and nvl(gd_dt_fin, vc.dt_refer);
   --
   vn_fase := 9;
   --
   for rec in c_mov loop
      exit when c_mov%notfound or (c_mov%notfound) is null;
      --
      delete
        from vw_csf_mov_transf_ff vc
       where vc.cnpj_emit = rec.cnpj_emit
         and vc.nro_doc   = rec.nro_doc;
      --
      vn_fase := 10;
      --
   end loop;
   --
   vn_fase := 11;
   --
   delete
     from vw_csf_mov_transf vc
    where vc.cnpj_emit = gv_cnpj
      and vc.dt_refer between nvl(gd_dt_ini, vc.dt_refer) and nvl(gd_dt_fin, vc.dt_refer);
   --
   vn_fase := 12;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      delete
        from vw_csf_enqlegcred_acmicmssp_ff vc
       where vc.cod_legal = rec.cod_legal;
      --
      vn_fase := 13;
      --
   end loop;
   --
   vn_fase := 14;
   --
   delete
     from vw_csf_enq_leg_cred_acmicmssp vc
    where vc.dt_refer between nvl(gd_dt_ini, vc.dt_refer) and nvl(gd_dt_fin, vc.dt_refer);
   --
   vn_fase := 15;
   --
   delete
     from vw_csf_itemnf_cod_legal vc
    where vc.cnpj_emit = gv_cnpj
      and vc.dt_refer between nvl(gd_dt_ini, vc.dt_refer) and nvl(gd_dt_fin, vc.dt_refer);
   --
   vn_fase := 16;
   --
   delete
     from vw_csf_itemnf_nao_gera_est vc
    where vc.cnpj_emit = gv_cnpj
      and vc.dt_refer between nvl(gd_dt_ini, vc.dt_refer) and nvl(gd_dt_fin, vc.dt_refer);
   --
   vn_fase := 17;
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_ecredac fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_ecredac;

----------------------------------------------------------------
--|PROCESSO QUE LIMA INTEGRAÇÃO DE USUÁRIO = 19|--
----------------------------------------------------------------
/*Leiaute_Views_Integracao_Usuario_V1_3*/
procedure pkb_limpa_usuario is
   --
   vn_fase number := 0;
   --
   cursor c_dados is
      select vc.login
        from vw_csf_usuario_ff vc
       where vc.atributo = 'COD_MULT_ORG'
         and vc.valor    = gn_multorg_id;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      delete
        from vw_csf_usuario vc
       where vc.login = rec.login;
      --
      vn_fase := 2;
      --
      delete
        from vw_csf_usuario_papel vc
       where vc.login = rec.login;
      --
      vn_fase := 3;
      --
      delete
        from vw_csf_usuario_empresa vc
       where vc.login = rec.login;
      --
      vn_fase := 4;
      --
      delete
        from vw_csf_usuempr_unidorg vc
      where vc.login = rec.login;
      --
      vn_fase := 5;
      --
   end loop;
   --
   vn_fase := 6;
   --
   delete
     from vw_csf_usuario_ff vc
    where vc.atributo = 'COD_MULT_ORG'
      and vc.valor    = gn_multorg_id;
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_usuario fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_usuario;

----------------------------------------------------------------
--|PROCESSO QUE LIMPA INTEGRAÇÃO DE DADOS CONTABEIS = 32|--
----------------------------------------------------------------
/*Leiaute_Views_Integracao_ECD_V1_3*/
procedure pkb_limpa_dados_contabeis is
   --
   vn_fase number := 0;
   --
   cursor c_dados is
      select vc.cpf_cnpj
           , vc.dt_ini
           , vc.dt_fim
           , vc.cod_cta
           , vc.cod_ccus
        from vw_csf_int_det_saldo_periodo vc
       where vc.cpf_cnpj = gv_cnpj
         and vc.dt_ini >= nvl(gd_dt_ini, vc.dt_ini)
         and vc.dt_fim <= nvl(gd_dt_fin, vc.dt_fim)
      order by 1 asc;
   --
   cursor c_lcto_cont is
      select vc.cpf_cnpj
           , vc.num_lcto
        from vw_csf_int_lcto_contabil vc
       where vc.cpf_cnpj = gv_cnpj
         and vc.dt_lcto between nvl(gd_dt_ini, vc.dt_lcto) and nvl(gd_dt_fin, vc.dt_lcto)
      order by 1 asc;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      delete
        from vw_csf_int_det_saldoperiodo_ff vc
       where vc.cpf_cnpj           = rec.cpf_cnpj
         and vc.dt_ini             = rec.dt_ini
         and vc.dt_fim             = rec.dt_fim
         and vc.cod_cta            = rec.cod_cta
         and nvl(vc.cod_ccus, '0') = nvl(rec.cod_ccus, '0');
      --
   end loop;
   --
   vn_fase := 2;
   --
   delete
     from vw_csf_int_det_saldo_periodo vc
    where vc.cpf_cnpj = gv_cnpj
      and vc.dt_ini >= nvl(gd_dt_ini, vc.dt_ini)
      and vc.dt_fim <= nvl(gd_dt_fin, vc.dt_fim);
   --
   vn_fase := 3;
   --
   delete
     from vw_csf_int_trans_sdo_cont_ant vc
    where vc.cpf_cnpj = gv_cnpj
      and vc.dt_ini >= nvl(gd_dt_ini, vc.dt_ini)
      and vc.dt_fim <= nvl(gd_dt_fin, vc.dt_fim);
   --
   vn_fase := 4;
   --
   for rec in c_lcto_cont loop
      exit when c_lcto_cont%notfound or (c_lcto_cont%notfound) is null;
      --
      delete
        from vw_csf_int_lcto_contabil_ff vc
       where vc.cpf_cnpj = rec.cpf_cnpj
         and vc.num_lcto = rec.num_lcto;
      --
      vn_fase := 5;
      --
      delete
        from vw_csf_int_partida_lcto vc
       where vc.cpf_cnpj = rec.cpf_cnpj
         and vc.num_lcto = rec.num_lcto;
      --
      vn_fase := 6;
      --
   end loop;
   --
   vn_fase := 7;
   --
   delete
     from vw_csf_int_lcto_contabil vc
    where vc.cpf_cnpj = gv_cnpj
      and vc.dt_lcto between nvl(gd_dt_ini, vc.dt_lcto) and nvl(gd_dt_fin, vc.dt_lcto);
   --
   vn_fase := 8;
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_dados_contabeis fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_dados_contabeis;

-------------------------------------------------------------------
--|PROCESSO QUE LIMPA INTEGRAÇÃO DE PRODUÇÃO DIÁRIA DE USINA = 33|-
-------------------------------------------------------------------
/*Leiaute_View_Integr_Prod_Dia_Usina_V1_1*/
procedure pkb_limpa_diaria_usina is
   --
   vn_fase number := 0;
   --
   cursor c_dados is
      select vc.cpf_cnpj_emit
           , vc.dm_cod_prod
           , vc.dt_prod
        from vw_csf_prod_dia_usina vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and vc.dt_prod between nvl(gd_dt_ini, vc.dt_prod) and nvl(gd_dt_fin, vc.dt_prod)
      order by 1 asc;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      delete
        from vw_csf_prod_dia_usina_ff vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.dm_cod_prod   = rec.dm_cod_prod
         and vc.dt_prod       = rec.dt_prod;
      --
      vn_fase := 2;
      --
   end loop;
   --
   delete
     from vw_csf_prod_dia_usina vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and vc.dt_prod between nvl(gd_dt_ini, vc.dt_prod) and nvl(gd_dt_fin, vc.dt_prod);
   --
   vn_fase := 3;
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_diaria_usina fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_diaria_usina;

----------------------------------------------------------------------------
--|PROCESSO QUE LIMPA INTEGRAÇÃO DE INFORMAÇÕES DE VALORES AGREGADOS = 36|--
----------------------------------------------------------------------------
/*Leiaute_View_Integr_Inf_Valor_Agreg_V1_1*/
procedure pkb_limpa_info_vl_agreg is
   --
   vn_fase number := 0;
   --
   cursor c_dados is
      select vc.cpf_cnpj_emit
           , vc.ano
           , vc.mes
           , vc.cod_item
           , vc.ibge_cidade
        from vw_csf_inf_valor_agreg vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and (gd_dt_ini is null or vc.mes >= to_char(gd_dt_ini, 'mm') and vc.ano >= to_char(gd_dt_ini, 'rrrr'))
         and (gd_dt_fin is null or vc.mes <= to_char(gd_dt_fin, 'mm') and vc.ano <= to_char(gd_dt_fin, 'rrrr'))
      order by 1 asc;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      delete
        from vw_csf_inf_valor_agreg_ff vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.ano           = rec.ano
         and vc.mes           = rec.mes
         and vc.cod_item      = rec.cod_item
         and vc.ibge_cidade   = rec.ibge_cidade;
      --
   end loop;
   --
   delete
     from vw_csf_inf_valor_agreg vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and (gd_dt_ini is null or vc.mes >= to_char(gd_dt_ini, 'mm') and vc.ano >= to_char(gd_dt_ini, 'rrrr'))
      and (gd_dt_fin is null or vc.mes <= to_char(gd_dt_fin, 'mm') and vc.ano <= to_char(gd_dt_fin, 'rrrr'));
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_info_vl_agreg fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_info_vl_agreg;

-----------------------------------------------------------------------------
--|PROCESSO QUE LIMPA INTEGRAÇÃO CONTROLE DE CRÉDITOS FISCAIS DE ICMS = 39|--
-----------------------------------------------------------------------------
/*Leiaute_View_Integr_Contr_Cred_Fiscal_Icms_V1_1*/
procedure pkb_limpa_ccf_icms is
   --
   vn_fase number := 0;
   --
   cursor c_dados is
      select vc.cpf_cnpj_emit
           , vc.ano
           , vc.mes
           , vc.cod_aj_apur
        from vw_csf_contr_cred_fiscal_icms vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and (gd_dt_ini is null or vc.mes >= to_char(gd_dt_ini, 'mm') and vc.ano >= to_char(gd_dt_ini, 'rrrr'))
         and (gd_dt_fin is null or vc.mes <= to_char(gd_dt_fin, 'mm') and vc.ano <= to_char(gd_dt_fin, 'rrrr'))
      order by 1 asc;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      delete
        from vw_csf_contrcred_fiscalicms_ff vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.ano           = rec.ano
         and vc.mes           = rec.mes
         and vc.cod_aj_apur   = rec.cod_aj_apur;
      --
      vn_fase := 2;
      --
      delete
        from vw_csf_util_cred_fiscal_icms vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.ano           = rec.ano
         and vc.mes           = rec.mes
         and vc.cod_aj_apur   = rec.cod_aj_apur;
      --
   end loop;
   --
   vn_fase := 3;
   --
   delete
     from vw_csf_contr_cred_fiscal_icms vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and (gd_dt_ini is null or vc.mes >= to_char(gd_dt_ini, 'mm') and vc.ano >= to_char(gd_dt_ini, 'rrrr'))
      and (gd_dt_fin is null or vc.mes <= to_char(gd_dt_fin, 'mm') and vc.ano <= to_char(gd_dt_fin, 'rrrr'));
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_ccf_icms fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_ccf_icms;

-----------------------------------------------------------------
--|PROCESSO QUE LIMPA INTEGRAÇÃO DE OPERAÇÕES COM CARTÕES = 42|--
-----------------------------------------------------------------
/*Leiaute_View_Integr_Total_Oper_Cartao_V1_1*/
procedure pkb_limpa_op_cartao is
   --
   vn_fase number := 0;
   --
   cursor c_dados is
      select vc.cpf_cnpj_emit
           , vc.cod_part
           , vc.ano
           , vc.mes
        from vw_csf_total_oper_cartao vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and (gd_dt_ini is null or vc.mes >= to_char(gd_dt_ini, 'mm') and vc.ano >= to_char(gd_dt_ini, 'rrrr'))
         and (gd_dt_fin is null or vc.mes <= to_char(gd_dt_fin, 'mm') and vc.ano <= to_char(gd_dt_fin, 'rrrr'))
      order by 1 asc;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      delete
        from vw_csf_total_oper_cartao_ff vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.cod_part      = rec.cod_part
         and vc.ano           = rec.ano
         and vc.mes           = rec.mes;
      --
   end loop;
   --
   vn_fase := 2;
   --
   delete
     from vw_csf_total_oper_cartao vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and (gd_dt_ini is null or vc.mes >= to_char(gd_dt_ini, 'mm') and vc.ano >= to_char(gd_dt_ini, 'rrrr'))
      and (gd_dt_fin is null or vc.mes <= to_char(gd_dt_fin, 'mm') and vc.ano <= to_char(gd_dt_fin, 'rrrr'));
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_op_cartao fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_op_cartao;
-----------------------------------------------------------------------------

------------------------------------------------------------------------------
--|PROCESSO QUE LIMPA INTEGRAÇÃO DE INFORMAÇÕES DE FOLHA DE PAGAMENTOS = 45|--
------------------------------------------------------------------------------
/*Leiaute_Views_Integracao_Manad_V1_3*/
procedure pkb_limpa_folha_pgto is
   --
   vn_fase number := 0;
   --
   cursor c_trab is
      select vc.cpf_cnpj_emit
           , vc.cod_reg_trab
        from vw_csf_trabalhador vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and vc.dt_inc_alt between nvl(gd_dt_ini, vc.dt_inc_alt) and nvl(gd_dt_fin, vc.dt_inc_alt)
      order by 1 asc;
   --
   cursor c_lotacao_folha is
      select vc.cpf_cnpj_emit
           , vc.cod_ltc
        from vw_csf_lotacao_folha vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and vc.dt_inc_alt between nvl(gd_dt_ini, vc.dt_inc_alt) and nvl(gd_dt_fin, vc.dt_inc_alt)
      order by 1 asc;
   --
   cursor c_rubrica_folha is
      select vc.cpf_cnpj_emit
           , vc.cod_rubrica
        from vw_csf_rubrica_folha vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and vc.dt_inc_alt between nvl(gd_dt_ini, vc.dt_inc_alt) and nvl(gd_dt_fin, vc.dt_inc_alt)
      order by 1 asc;
   --
   cursor c_cont_folha_pgto( ev_cpf_cnpj_emit in varchar2
                           , ev_cod_rubrica   in varchar2 )
      is
      select vc.*
        from vw_csf_cont_folha_pgto vc
       where vc.cpf_cnpj_emit = ev_cpf_cnpj_emit
         and vc.cod_rubrica   = ev_cod_rubrica
      order by 1 asc;
   --
   cursor c_mestre_folha is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_fl
           , vc.cod_ltc
           , vc.cod_reg_trab
           , vc.dt_comp
        from vw_csf_mestre_folha_pgto vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and vc.dt_comp between nvl(gd_dt_ini, vc.dt_comp) and nvl(gd_dt_fin, vc.dt_comp)
      order by 1 asc;
   --
   cursor c_inf_folha_pgto is
      select vc.cpf_cnpj_emit
           , vc.ano
           , vc.mes
        from vw_csf_inf_folha_pgto vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and vc.mes between nvl(to_char(gd_dt_ini, 'mm'), vc.mes) and nvl(to_char(gd_dt_fin, 'mm'), vc.mes)
         and vc.ano between nvl(to_char(gd_dt_ini, 'rrrr'), vc.ano) and nvl(to_char(gd_dt_fin, 'rrrr'), vc.ano)
      order by 1 asc;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_trab loop
      exit when c_trab%notfound or (c_trab%notfound) is null;
      --
      delete
        from vw_csf_trabalhador_ff vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.cod_reg_trab  = rec.cod_reg_trab;
      --
      vn_fase := 2;
      --
   end loop;
   --
   delete
     from vw_csf_trabalhador vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and vc.dt_inc_alt between nvl(gd_dt_ini, vc.dt_inc_alt) and nvl(gd_dt_fin, vc.dt_inc_alt);
   --
   vn_fase := 3;
   --
   for rec in c_lotacao_folha loop
      exit when c_lotacao_folha%notfound or (c_lotacao_folha%notfound) is null;
      --
      delete
        from vw_csf_lotacao_folha_ff vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.cod_ltc       = rec.cod_ltc;
      --
      vn_fase := 4;
      --
   end loop;
   --
   vn_fase := 5;
   --
   delete
     from vw_csf_lotacao_folha vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and vc.dt_inc_alt between nvl(gd_dt_ini, vc.dt_inc_alt) and nvl(gd_dt_fin, vc.dt_inc_alt);
   --
   vn_fase := 6;
   --
   for rec in c_rubrica_folha loop
      exit when c_rubrica_folha%notfound or (c_rubrica_folha%notfound) is null;
      --
      delete
        from vw_csf_rubrica_folha_ff vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.cod_rubrica   = rec.cod_rubrica;
      --
      vn_fase := 7;
      --
      for rec2 in c_cont_folha_pgto(rec.cpf_cnpj_emit, rec.cod_rubrica) loop
         exit when c_cont_folha_pgto%notfound or (c_cont_folha_pgto%notfound) is null;
         --
         delete
           from vw_csf_cont_folha_pgto_ff vc
          where vc.cpf_cnpj_emit     = rec2.cpf_cnpj_emit
            and vc.cod_rubrica       = rec2.cod_rubrica
            and vc.dt_cont           = rec2.dt_cont
            and nvl(vc.cod_ltc,' ')  = nvl(rec2.cod_ltc,' ')
            and vc.cod_cta           = rec2.cod_cta
            and nvl(vc.cod_ccus,' ') = nvl(rec2.cod_ccus,' ');
         --
         vn_fase := 8;
         --
      end loop;
      --
      vn_fase := 9;
      --
      delete
        from vw_csf_cont_folha_pgto vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.cod_rubrica   = rec.cod_rubrica;
      --
      vn_fase := 10;
      --
   end loop;
   --
   vn_fase := 11;
   --
   delete
     from vw_csf_rubrica_folha vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and vc.dt_inc_alt between nvl(gd_dt_ini, vc.dt_inc_alt) and nvl(gd_dt_fin, vc.dt_inc_alt);
   --
   vn_fase := 12;
   --
   for rec in c_mestre_folha loop
      exit when c_mestre_folha%notfound or (c_mestre_folha%notfound) is null;
      --
      delete
        from vw_csf_mestre_folha_pgto_ff vc
       where vc.cpf_cnpj_emit    = rec.cpf_cnpj_emit
         and vc.dm_ind_fl        = rec.dm_ind_fl
         and nvl(vc.cod_ltc,' ') = nvl(rec.cod_ltc,' ')
         and vc.cod_reg_trab     = rec.cod_reg_trab
         and vc.dt_comp          = rec.dt_comp;
      --
      vn_fase := 13;
      --
      delete
        from vw_csf_item_folha_pgto vc
       where vc.cpf_cnpj_emit    = rec.cpf_cnpj_emit
         and vc.dm_ind_fl        = rec.dm_ind_fl
         and nvl(vc.cod_ltc,' ') = nvl(rec.cod_ltc,' ')
         and vc.cod_reg_trab     = rec.cod_reg_trab
         and vc.dt_comp          = rec.dt_comp;
      --
      vn_fase := 14;
      --
   end loop;
   --
   vn_fase := 15;
   --
   delete
     from vw_csf_mestre_folha_pgto vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and vc.dt_comp between nvl(gd_dt_ini, vc.dt_comp) and nvl(gd_dt_fin, vc.dt_comp);
   --
   vn_fase := 16;
   --
   for rec in c_inf_folha_pgto loop
      exit when c_inf_folha_pgto%notfound or (c_inf_folha_pgto%notfound) is null;
      --
      delete
        from vw_csf_inf_folha_pgto_ff vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.ano           = rec.ano
         and vc.mes           = rec.mes;
      --
      vn_fase := 17;
      --
   end loop;
   --
   vn_fase := 18;
   --
   delete
     from vw_csf_inf_folha_pgto vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and vc.mes between nvl(to_char(gd_dt_ini, 'mm'), vc.mes) and nvl(to_char(gd_dt_fin, 'mm'), vc.mes)
      and vc.ano between nvl(to_char(gd_dt_ini, 'rrrr'), vc.ano) and nvl(to_char(gd_dt_fin, 'rrrr'), vc.ano);
   --
   vn_fase := 19;
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_folha_pgto fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_folha_pgto;

---------------------------------------------------------------------------
--|PROCESSO QUE LIMPA A INTEGRAÇÃO DE PAGAMENTOS DE IMPOSTOS PADRÃO = 46|--
---------------------------------------------------------------------------
/*Leiaute_View_Integr_Pgto_Ret_imp_V1_5*/
procedure pkb_limpa_pgto_imp is
   --
   vn_fase number := 0;
   --
   cursor c_pgtoimp is
     select vc.cpf_cnpj_emit
          , vc.cod_part
          , vc.nro_doc
          , vc.dt_vcto
          , vc.dt_pgto
          , vc.cod_imposto
          , vc.cd_tipo_ret_imp
       from vw_csf_pgto_imp_ret vc
      where vc.cpf_cnpj_emit = gv_cnpj
        and nvl(vc.dt_docto, vc.dt_pgto) between nvl(gd_dt_ini, vc.dt_docto) and nvl(gd_dt_fin, vc.dt_docto)
     order by 1 asc;
   --
   cursor c_impret is
      select vc.cpf_cnpj_emit
           , vc.cnpj
           , vc.cod_part
           , vc.dt_ret
           , vc.ident_rec
        from vw_csf_imp_ret_rec_pc vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and vc.dt_ret between nvl(gd_dt_ini, vc.dt_ret) and nvl(gd_dt_fin, vc.dt_ret)
     order by 1 asc;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_pgtoimp loop
      exit when c_pgtoimp%notfound or (c_pgtoimp%notfound) is null;
      --
      delete
        from vw_csf_pgto_imp_ret_ff vc
       where vc.cpf_cnpj_emit   = rec.cpf_cnpj_emit
         and vc.cod_part        = rec.cod_part
         and vc.nro_doc         = rec.nro_doc
         and vc.dt_vcto         = rec.dt_vcto
         and vc.dt_pgto         = rec.dt_pgto
         and vc.cod_imposto     = rec.cod_imposto
         and vc.cd_tipo_ret_imp = rec.cd_tipo_ret_imp;
      --
      vn_fase := 2.1;
      --
      delete
        from vw_csf_pir_det_ded vc
       where vc.cpf_cnpj_emit   = rec.cpf_cnpj_emit
         and vc.cod_part        = rec.cod_part
         and vc.nro_doc         = rec.nro_doc
         and vc.dt_vcto         = rec.dt_vcto
         and vc.dt_pgto         = rec.dt_pgto
         and vc.cod_imposto     = rec.cod_imposto
         and vc.cd_tipo_ret_imp = rec.cd_tipo_ret_imp;
      --
      vn_fase := 2.2;
      --
      delete
        from vw_csf_pir_rend_isento vc
       where vc.cpf_cnpj_emit   = rec.cpf_cnpj_emit
         and vc.cod_part        = rec.cod_part
         and vc.nro_doc         = rec.nro_doc
         and vc.dt_vcto         = rec.dt_vcto
         and vc.dt_pgto         = rec.dt_pgto
         and vc.cod_imposto     = rec.cod_imposto
         and vc.cd_tipo_ret_imp = rec.cd_tipo_ret_imp;
      --
      vn_fase := 2.3;
      --
      delete
        from vw_csf_pir_det_comp vc
       where vc.cpf_cnpj_emit   = rec.cpf_cnpj_emit
         and vc.cod_part        = rec.cod_part
         and vc.nro_doc         = rec.nro_doc
         and vc.dt_vcto         = rec.dt_vcto
         and vc.dt_pgto         = rec.dt_pgto
         and vc.cod_imposto     = rec.cod_imposto
         and vc.cd_tipo_ret_imp = rec.cd_tipo_ret_imp;
      --
      vn_fase := 2.4;
      --
      delete
        from vw_csf_pir_comp_jud vc
       where vc.cpf_cnpj_emit   = rec.cpf_cnpj_emit
         and vc.cod_part        = rec.cod_part
         and vc.nro_doc         = rec.nro_doc
         and vc.dt_vcto         = rec.dt_vcto
         and vc.dt_pgto         = rec.dt_pgto
         and vc.cod_imposto     = rec.cod_imposto
         and vc.cd_tipo_ret_imp = rec.cd_tipo_ret_imp;
      --
      vn_fase := 2.5;
      --
      delete
        from vw_csf_pir_inf_rra vc
       where vc.cpf_cnpj_emit   = rec.cpf_cnpj_emit
         and vc.cod_part        = rec.cod_part
         and vc.nro_doc         = rec.nro_doc
         and vc.dt_vcto         = rec.dt_vcto
         and vc.dt_pgto         = rec.dt_pgto
         and vc.cod_imposto     = rec.cod_imposto
         and vc.cd_tipo_ret_imp = rec.cd_tipo_ret_imp;
      --
      vn_fase := 2.6;
      --
      delete
        from vw_csf_pir_inf_rra_desp vc
       where vc.cpf_cnpj_emit   = rec.cpf_cnpj_emit
         and vc.cod_part        = rec.cod_part
         and vc.nro_doc         = rec.nro_doc
         and vc.dt_vcto         = rec.dt_vcto
         and vc.dt_pgto         = rec.dt_pgto
         and vc.cod_imposto     = rec.cod_imposto
         and vc.cd_tipo_ret_imp = rec.cd_tipo_ret_imp;
      --
      vn_fase := 2.7;
      --
      delete
        from vw_csf_pir_inf_rra_desp_adv vc
       where vc.cpf_cnpj_emit   = rec.cpf_cnpj_emit
         and vc.cod_part        = rec.cod_part
         and vc.nro_doc         = rec.nro_doc
         and vc.dt_vcto         = rec.dt_vcto
         and vc.dt_pgto         = rec.dt_pgto
         and vc.cod_imposto     = rec.cod_imposto
         and vc.cd_tipo_ret_imp = rec.cd_tipo_ret_imp;
      --
      vn_fase := 2.8;
      --
      delete
        from vw_csf_pir_proc_reinf vc
       where vc.cpf_cnpj_emit   = rec.cpf_cnpj_emit
         and vc.cod_part        = rec.cod_part
         and vc.nro_doc         = rec.nro_doc
         and vc.dt_vcto         = rec.dt_vcto
         and vc.dt_pgto         = rec.dt_pgto
         and vc.cod_imposto     = rec.cod_imposto
         and vc.cd_tipo_ret_imp = rec.cd_tipo_ret_imp;
      --
      vn_fase := 2.9;
      --
      delete
        from vw_csf_pir_proc_reinf_desp vc
       where vc.cpf_cnpj_emit   = rec.cpf_cnpj_emit
         and vc.cod_part        = rec.cod_part
         and vc.nro_doc         = rec.nro_doc
         and vc.dt_vcto         = rec.dt_vcto
         and vc.dt_pgto         = rec.dt_pgto
         and vc.cod_imposto     = rec.cod_imposto
         and vc.cd_tipo_ret_imp = rec.cd_tipo_ret_imp;
      --
      vn_fase := 2.10;
      --
      delete
        from vw_csf_pir_proc_reinf_desp_adv vc
       where vc.cpf_cnpj_emit   = rec.cpf_cnpj_emit
         and vc.cod_part        = rec.cod_part
         and vc.nro_doc         = rec.nro_doc
         and vc.dt_vcto         = rec.dt_vcto
         and vc.dt_pgto         = rec.dt_pgto
         and vc.cod_imposto     = rec.cod_imposto
         and vc.cd_tipo_ret_imp = rec.cd_tipo_ret_imp;
       --
       vn_fase := 2.11;
       --
       delete
        from vw_csf_pir_proc_reinf_orig_rec vc
       where vc.cpf_cnpj_emit   = rec.cpf_cnpj_emit
         and vc.cod_part        = rec.cod_part
         and vc.nro_doc         = rec.nro_doc
         and vc.dt_vcto         = rec.dt_vcto
         and vc.dt_pgto         = rec.dt_pgto
         and vc.cod_imposto     = rec.cod_imposto
         and vc.cd_tipo_ret_imp = rec.cd_tipo_ret_imp;
       --
       vn_fase := 2.12;
       --
       delete
        from vw_csf_pir_info_ext vc
       where vc.cpf_cnpj_emit   = rec.cpf_cnpj_emit
         and vc.cod_part        = rec.cod_part
         and vc.nro_doc         = rec.nro_doc
         and vc.dt_vcto         = rec.dt_vcto
         and vc.dt_pgto         = rec.dt_pgto
         and vc.cod_imposto     = rec.cod_imposto
         and vc.cd_tipo_ret_imp = rec.cd_tipo_ret_imp;
       --
   end loop;
   --
   vn_fase := 3;
   --
   delete
     from vw_csf_pgto_imp_ret vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and nvl(vc.dt_docto, vc.dt_pgto) between nvl(gd_dt_ini, vc.dt_docto) and nvl(gd_dt_fin, vc.dt_docto);
      --and vc.dt_docto between nvl(gd_dt_ini, vc.dt_docto) and nvl(gd_dt_fin, vc.dt_docto);
   --
   vn_fase := 4;
   --
   for rec in c_impret loop
      exit when c_impret%notfound or (c_impret%notfound) is null;
      --
      delete
        from vw_csf_imp_ret_rec_pc_ff vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.cnpj          = rec.cnpj
         and vc.cod_part      = rec.cod_part
         and vc.dt_ret        = rec.dt_ret
         and vc.ident_rec     = rec.ident_rec;
      --
      vn_fase := 5;
      --
      delete
        from vw_csf_imp_ret_rec_pc_nf vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.cnpj          = rec.cnpj
         and vc.cod_part      = rec.cod_part
         and vc.dt_ret        = rec.dt_ret
         and vc.ident_rec     = rec.ident_rec;
      --
   end loop;
   --
   vn_fase := 6;
   --
   delete
     from vw_csf_imp_ret_rec_pc vc
     where vc.cpf_cnpj_emit = gv_cnpj
       and vc.dt_ret between nvl(gd_dt_ini, vc.dt_ret) and nvl(gd_dt_fin, vc.dt_ret);
   --
   vn_fase := 7;
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_pgto_imp fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_pgto_imp;

----------------------------------------------------------------
--|PROCESSO QUE LIMPA INTEGRAÇÃO DIRF = 47|--
----------------------------------------------------------------
/*Leiaute_Views_Integracao_Table_View_Dirf_1_4*/
procedure pkb_limpa_dirf is
   --
   vn_fase number := 0;
   --
   cursor c_inf_dirf is
      select vc.cpf_cnpj_emit
           , vc.cod_part
           , vc.ano_ref
           , vc.cod_ret_imp
           , vc.dm_origem
        from vw_csf_inf_rend_dirf vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and vc.ano_ref between nvl(to_char(gd_dt_ini,'rrrr'), vc.ano_ref) and nvl(to_char(gd_dt_fin,'rrrr'), vc.ano_ref)
      order by 1 asc;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_inf_dirf loop
      exit when c_inf_dirf%notfound or (c_inf_dirf%notfound) is null;
      --
      delete
        from vw_csf_inf_rend_dirf_ff vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.cod_part      = rec.cod_part
         and vc.ano_ref       = rec.ano_ref
         and vc.cod_ret_imp   = rec.cod_ret_imp
         and vc.dm_origem     = rec.dm_origem;
      --
      vn_fase := 2;
      --
      delete
        from vw_csf_inf_rend_dirf_mensal vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.cod_part      = rec.cod_part
         and vc.ano_ref       = rec.ano_ref
         and vc.cod_ret_imp   = rec.cod_ret_imp
         and vc.dm_origem     = rec.dm_origem;
      --
      vn_fase := 3;
      --
      delete
        from vw_csf_inf_rend_dirf_anual vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.cod_part      = rec.cod_part
         and vc.ano_ref       = rec.ano_ref
         and vc.cod_ret_imp   = rec.cod_ret_imp
         and vc.dm_origem     = rec.dm_origem;
      --
      vn_fase := 4;
      --
      delete
        from vw_csf_inf_rend_dirf_pse vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.cod_part      = rec.cod_part
         and vc.ano_ref       = rec.ano_ref
         and vc.cod_ret_imp   = rec.cod_ret_imp
         and vc.dm_origem     = rec.dm_origem;
      --
      vn_fase := 5;
      --
      delete
        from vw_csf_inf_rend_dirf_rpde vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.cod_part      = rec.cod_part
         and vc.ano_ref       = rec.ano_ref
         and vc.cod_ret_imp   = rec.cod_ret_imp
         and vc.dm_origem     = rec.dm_origem;
      --
   end loop;
   --
   vn_fase := 6;
   --
   delete
     from vw_csf_inf_rend_dirf vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and vc.ano_ref between nvl(to_char(gd_dt_ini,'rrrr'), vc.ano_ref) and nvl(to_char(gd_dt_fin,'rrrr'), vc.ano_ref);
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_dirf fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_dirf;

-----------------------------------------------------------------------------
--|PROCESSO QUE LIMPA A INTEGRAÇÃO DE CONTROLE DE PRODUÇÃO DE ESTOQUE = 48|--
-----------------------------------------------------------------------------
/*Leiaute_Views_Integracao_Sped_Fiscal_Bloco_K_V1_2*/
procedure pkb_limpa_ctrl_prod_estoque is
   --
   vn_fase number := 0;
   --
   cursor c_prod_estoq is
      select vc.*
        from vw_csf_per_contr_prod_estq vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and nvl(vc.dt_ini, trunc(sysdate)) >= nvl(gd_dt_ini, nvl(vc.dt_ini, trunc(sysdate)))
         and nvl(vc.dt_fin, trunc(sysdate)) <= nvl(gd_dt_fin, nvl(vc.dt_fin, trunc(sysdate)))
      order by 1 asc;
   --
   cursor c_item_produz( ev_cpf_cnpj_emit in varchar2
                       , ed_dt_ini        in date
                       , ed_dt_fin        in date )
      is
      select vc.cpf_cnpj_emit
           , vc.dt_ini_op
           , vc.dt_fin_op
           , vc.cod_doc_op
           , vc.cod_item
        from vw_csf_item_produz vc
       where vc.cpf_cnpj_emit = ev_cpf_cnpj_emit
         and nvl(vc.dt_ini_op, trunc(sysdate))     = nvl(ed_dt_ini, nvl(vc.dt_ini_op, trunc(sysdate)))
         and nvl(vc.dt_fin_op, trunc(sysdate))     = nvl(ed_dt_fin, nvl(vc.dt_fin_op, trunc(sysdate)))
      order by 1 asc;
   --
   cursor c_ind_por_terc( ev_cpf_cnpj_emit in varchar2
                        , ed_dt_ini        in date
                        , ed_dt_fin        in date )
      is
      select vc.cpf_cnpj_emit
           , vc.dt_prod
           , vc.cod_item
        from vw_csf_industr_por_terc vc
       where vc.cpf_cnpj_emit = ev_cpf_cnpj_emit
         and nvl(vc.dt_prod, trunc(sysdate)) between nvl(ed_dt_ini, nvl(vc.dt_prod, trunc(sysdate))) and nvl(ed_dt_fin, nvl(vc.dt_prod, trunc(sysdate)))
      order by 1 asc;
   --
   cursor c_desmon_orig ( ev_cpf_cnpj_emit in varchar2  --vw_csf_desmon_merc_item_orig
                        , ed_dt_ini        in date
                        , ed_dt_fin        in date )
      is
      select cpf_cnpj_emit
           , dt_ini_os
           , dt_fin_os
           , cod_doc_os
           , cod_item_ori
        from vw_csf_desmon_merc_item_orig vc
       where vc.cpf_cnpj_emit = ev_cpf_cnpj_emit
         and nvl(vc.dt_ini_os, trunc(sysdate))     = nvl(ed_dt_ini, nvl(vc.dt_ini_os, trunc(sysdate)))
         and nvl(vc.dt_fin_os, trunc(sysdate))     = nvl(ed_dt_fin, nvl(vc.dt_fin_os, trunc(sysdate)));
   --
   cursor c_prod_ins (ev_cpf_cnpj_emit in varchar2)  --vw_csf_repr_repa_prod_ins
      is
      select cpf_cnpj_emit
           , cod_op_os
           , cod_item_rep
           , dt_saida
        from vw_csf_repr_repa_prod_ins vc
       where vc.cpf_cnpj_emit = ev_cpf_cnpj_emit;
   --
   cursor c_apont_reg ( ev_cpf_cnpj_emit in varchar2
                      , ed_dt_ini        in date
                      , ed_dt_fin        in date )
      is
      select cpf_cnpj_emit
           , dt_ini_ap
           , dt_fin_ap
           , cod_op_os
           , cod_item_corr
       from vw_csf_corr_apont_reg vc
       where vc.cpf_cnpj_emit = ev_cpf_cnpj_emit
         and nvl(vc.dt_ini_ap, trunc(sysdate))     = nvl(ed_dt_ini, nvl(vc.dt_ini_ap, trunc(sysdate)))
         and nvl(vc.dt_fin_ap, trunc(sysdate))     = nvl(ed_dt_fin, nvl(vc.dt_fin_ap, trunc(sysdate)));
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_prod_estoq loop
      exit when c_prod_estoq%notfound or (c_prod_estoq%notfound) is null;
      --
      vn_fase := 2;
      --
      delete
        from vw_csf_per_contr_prod_estq_ff vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.dt_ini        = rec.dt_ini
         and vc.dt_fin        = rec.dt_fin;
      --
      vn_fase:= 3;
      --
      for rec_desmon in c_desmon_orig(rec.cpf_cnpj_emit, null, null) loop
         exit when c_desmon_orig%notfound or (c_desmon_orig%notfound) is null;
         --
         vn_fase:= 3.1;
         --
         delete
           from vw_csf_desmon_merc_item_dest vc
          where vc.cpf_cnpj_emit                  = rec_desmon.cpf_cnpj_emit
            and nvl(vc.dt_ini_os, trunc(sysdate)) = nvl(rec_desmon.dt_ini_os, trunc(sysdate))
            and nvl(vc.dt_fin_os, trunc(sysdate)) = nvl(rec_desmon.dt_fin_os, trunc(sysdate))
            and nvl(vc.cod_doc_os, '0')           = nvl(rec_desmon.cod_doc_os, '0')
            and vc.cod_item_ori                   = rec_desmon.cod_item_ori;
         --
         vn_fase:= 3.2;
         --
         delete
           from vw_csf_desmon_merc_item_orig vc
          where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
            and nvl(vc.dt_ini_os, trunc(sysdate)) = nvl(rec_desmon.dt_ini_os, trunc(sysdate))
            and nvl(vc.dt_fin_os, trunc(sysdate)) = nvl(rec_desmon.dt_fin_os, trunc(sysdate))
            and nvl(vc.cod_doc_os, '0')           = nvl(rec_desmon.cod_doc_os, '0')
            and vc.cod_item_ori                   = rec_desmon.cod_item_ori;
         --
      end loop;
      --
      vn_fase := 4;
      --
      for rec_prod in c_prod_ins(rec.cpf_cnpj_emit) loop
         exit when c_prod_ins%notfound or (c_prod_ins%notfound) is null;
         --
         vn_fase := 4.1;
         --
         delete
           from vw_csf_repr_repa_merc_cons_ret vc
          where vc.cpf_cnpj_emit       = rec_prod.cpf_cnpj_emit
            and nvl(vc.cod_op_os, '0') = nvl(rec_prod.cod_op_os, '0')
            and vc.cod_item_rep        = rec_prod.cod_item_rep
            and vc.dt_saida            = rec_prod.dt_saida;
         --
      end loop;
      --
      vn_fase := 5;
      --
      for rec_apont_reg in c_apont_reg(rec.cpf_cnpj_emit, null, null) loop
         exit when c_apont_reg%notfound or (c_apont_reg%notfound) is null;
         --
         vn_fase := 5.1;
         --
         delete
           from vw_csf_corr_apont_ret_ins vc
          where vc.cpf_cnpj_emit                  = rec_apont_reg.cpf_cnpj_emit
            and nvl(vc.dt_ini_ap, trunc(sysdate)) = nvl(rec_apont_reg.dt_ini_ap, trunc(sysdate))
            and nvl(vc.dt_fin_ap, trunc(sysdate)) = nvl(rec_apont_reg.dt_fin_ap, trunc(sysdate))
            and nvl(vc.cod_op_os, '0')            = nvl(rec_apont_reg.cod_op_os, '0')
            and vc.cod_item_corr                  = rec_apont_reg.cod_item_corr;
         --
         vn_fase := 5.2;
         --
         delete
           from vw_csf_corr_apont_reg  vc
          where vc.cpf_cnpj_emit = rec_apont_reg.cpf_cnpj_emit
            and vc.dt_ini_ap     = rec_apont_reg.dt_ini_ap
            and vc.dt_fin_ap     = rec_apont_reg.dt_fin_ap;
         --
      end loop;
      --
      vn_fase := 6;
      --
      delete
        from vw_csf_outrmovto_intermerc_ff vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.dt_mov between rec.dt_ini and rec.dt_fin;
      --
      vn_fase := 7;
      --
      delete
        from vw_csf_outr_movto_inter_merc vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.dt_mov between rec.dt_ini and rec.dt_fin;
      --
      vn_fase := 8;
      --
      for rec2 in c_item_produz(rec.cpf_cnpj_emit, null, null) loop
         exit when c_item_produz%notfound or (c_item_produz%notfound) is null;
         --
         vn_fase := 8.1;
         --
         delete
           from vw_csf_insumo_cons vc
          where vc.cpf_cnpj_emit                  = rec2.cpf_cnpj_emit
            and nvl(vc.dt_ini_op, trunc(sysdate)) = nvl(rec2.dt_ini_op, trunc(sysdate))
            and nvl(vc.dt_fin_op, trunc(sysdate)) = nvl(rec2.dt_fin_op, trunc(sysdate))
            and nvl(vc.cod_doc_op,0)              = nvl(rec2.cod_doc_op,0)
            and vc.cod_item                       = rec2.cod_item;
         --
         vn_fase := 8.2;
         --
         delete
           from vw_csf_item_produz vc
          where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
            and nvl(vc.dt_ini_op, trunc(sysdate)) = nvl(rec2.dt_ini_op, trunc(sysdate))
            and nvl(vc.dt_fin_op, trunc(sysdate)) = nvl(rec2.dt_fin_op, trunc(sysdate))
            and nvl(vc.cod_doc_op,0)              = nvl(rec2.cod_doc_op,0)
            and vc.cod_item                       = rec2.cod_item;
         --
      end loop;
      --
      vn_fase := 9;
      --
      for rec3 in c_ind_por_terc(rec.cpf_cnpj_emit, rec.dt_ini, rec.dt_fin) loop
         exit when c_ind_por_terc%notfound or (c_ind_por_terc%notfound) is null;
         --
         vn_fase := 9.1;
         --
         delete
           from vw_csf_industr_em_terc vc
          where vc.cpf_cnpj_emit = rec3.cpf_cnpj_emit
            and nvl(vc.dt_cons, trunc(sysdate)) between nvl(rec.dt_ini, trunc(sysdate))
                                                    and nvl(rec.dt_fin, trunc(sysdate));
         --
      end loop;
      --
      vn_fase := 10;
      --
      delete
        from vw_csf_industr_por_terc vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.dt_prod between rec.dt_ini and rec.dt_fin;
      --
      vn_fase := 11;
      --
      delete
       from vw_csf_corr_apont_est vc
       where vc.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and vc.dt_est between rec.dt_ini and rec.dt_fin;
      --
      vn_fase := 12;
      --
      delete
      from VW_CSF_PROD_CJTA_ORDPROD co
       where co.cpf_cnpj_emit = rec.cpf_cnpj_emit
         and nvl(co.dt_ini_op, trunc(sysdate))     = nvl(rec.dt_ini, nvl(co.dt_ini_op, trunc(sysdate)))
         and nvl(co.dt_fin_op, trunc(sysdate))     = nvl(rec.dt_fin, nvl(co.dt_fin_op, trunc(sysdate)));
      --
      vn_fase := 13;
      --
      delete
      from VW_CSF_PROD_CJTA_ITEMPROD ip
      where ip.cpf_cnpj_emit = rec.cpf_cnpj_emit
        and nvl(ip.dt_ini_op, trunc(sysdate))     = nvl(rec.dt_ini, nvl(ip.dt_ini_op, trunc(sysdate)))
        and nvl(ip.dt_fin_op, trunc(sysdate))     = nvl(rec.dt_fin, nvl(ip.dt_fin_op, trunc(sysdate)));
      --
      vn_fase := 14;
      --
      delete
      from VW_CSF_PROD_CJTA_INSCONS ic
      where ic.cpf_cnpj_emit = rec.cpf_cnpj_emit
        and nvl(ic.dt_ini_op, trunc(sysdate))     = nvl(rec.dt_ini, nvl(ic.dt_ini_op, trunc(sysdate)))
        and nvl(ic.dt_fin_op, trunc(sysdate))     = nvl(rec.dt_fin, nvl(ic.dt_fin_op, trunc(sysdate)));
      --
      vn_fase := 15;
      --
      delete
      from VW_CSF_PROD_CJTA_INDTERC it
      where it.cpf_cnpj_emit = rec.cpf_cnpj_emit
      and nvl(it.dt_prod, trunc(sysdate)) between nvl(rec.dt_ini, nvl(it.dt_prod, trunc(sysdate))) and nvl(rec.dt_fin, nvl(it.dt_prod, trunc(sysdate)));
      --
      vn_fase := 16;
      --
      delete
      from VW_CSF_PROD_CJTA_INDTERC_IP ii
      where ii.cpf_cnpj_emit = rec.cpf_cnpj_emit
      and nvl(ii.dt_prod, trunc(sysdate)) between nvl(rec.dt_ini, nvl(ii.dt_prod, trunc(sysdate))) and nvl(rec.dt_fin, nvl(ii.dt_prod, trunc(sysdate)));
      --
      vn_fase := 17;
      --
      delete
      from VW_CSF_PROD_CJTA_INDTERC_IC ic
      where ic.cpf_cnpj_emit = rec.cpf_cnpj_emit
      and nvl(ic.dt_prod, trunc(sysdate)) between nvl(rec.dt_ini, nvl(ic.dt_prod, trunc(sysdate))) and nvl(rec.dt_fin, nvl(rec.dt_fin, trunc(sysdate)));
      --
   end loop;
   --
   vn_fase := 18;
   --
   delete
     from vw_csf_repr_repa_prod_ins  vc
    where vc.cpf_cnpj_emit = gv_cnpj;
   --
   vn_fase := 19;
   --
   delete
     from vw_csf_estq_escrit vc
    where vc.cpf_cnpj_emit = gv_cnpj;
   --
   vn_fase := 20;
   --
   delete
     from vw_csf_per_contr_prod_estq vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and vc.dt_ini >= nvl(gd_dt_ini, vc.dt_ini)
      and vc.dt_fin <= nvl(gd_dt_fin, vc.dt_fin);
   --
   vn_fase := 21;
   --
   delete vw_csf_item_insumo xx
   where xx.cpf_cnpj_emit = gv_cnpj;
   --
   vn_fase := 22;
   --
   commit;
   --
exception
   when others then
      --
      rollback;
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_ctrl_prod_estoque fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_ctrl_prod_estoque;

-------------------------------------------------------------------------------
--|PROCESSO QUE LIMPA INTEGRAÇÃO DE SOLICITAÇÃO DE CONTROLE DE CADASTRO = 49|--
-------------------------------------------------------------------------------
/*Leiaute de Consulta Cadastral na SEFAZ_v1.1*/
procedure pkb_limpa_sol_ctrl_cadastro is
   --
   vn_fase number := 0;
   --
   cursor c_dados is
      select vc.id_integr
        from vw_csf_solic_cons_cad vc
       where vc.cnpj = gv_cnpj
         and trunc(vc.dt_hr_solic) between nvl(gd_dt_ini, trunc(vc.dt_hr_solic)) and nvl(gd_dt_fin, trunc(vc.dt_hr_solic))
      order by 1 asc;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      delete
        from vw_csf_solic_cons_cad_ff vc
       where vc.id_integr = rec.id_integr;
      --
      vn_fase := 2;
      --
   end loop;
   --
   delete
     from vw_csf_solic_cons_cad vc
    where vc.cnpj = gv_cnpj
      and trunc(vc.dt_hr_solic) between nvl(gd_dt_ini, trunc(vc.dt_hr_solic)) and nvl(gd_dt_fin, trunc(vc.dt_hr_solic));
   --
   vn_fase := 3;
   --
   delete
     from vw_csf_ret_inf_cad_cons vc
    where vc.cnpj = gv_cnpj;
   --
   vn_fase := 4;
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_sol_ctrl_cadastro fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_sol_ctrl_cadastro;

----------------------------------------------------------------
--|PROCESSO QUE LIMPA INTEGRAÇÃO DO BLOCO F = 50|--
----------------------------------------------------------------
/*Leiaute_de_Integração_Bloco_F_V1*/
procedure pkb_limpa_bloco_f is
   --
   vn_fase number := 0;
   --
   cursor c_oper_ger_cc is
      select vc.cnpj_empr
           , vc.cod_part
           , vc.cod_item
           , vc.cod_st_pis
           , vc.cod_st_cofins
           , vc.cd_basecalcredpc
           , vc.dm_st_proc
        from vw_csf_dem_doc_oper_ger_cc vc
       where vc.cnpj_empr = gv_cnpj
         and vc.dt_oper between nvl(gd_dt_ini, vc.dt_oper) and nvl(gd_dt_fin, vc.dt_oper)
      order by 1 asc;
   --
   cursor c_operced_pc is
      select vc.cnpj_empr
           , vc.ano_ref
           , vc.mes_ref
           , vc.dm_tipo_oper
           , vc.cd_basecalccredpc
           , vc.cod_st_pis
           , vc.cod_st_cofins
           , vc.cod_cta
           , vc.cod_ccus
           , vc.dm_st_proc
        from vw_csf_bemativimob_opercred_pc vc
       where vc.cnpj_empr = gv_cnpj
         and vc.mes_ref between nvl(to_char(gd_dt_ini, 'mm'), vc.mes_ref) and nvl(to_char(gd_dt_fin, 'mm'), vc.mes_ref)
         and vc.ano_ref between nvl(to_char(gd_dt_ini, 'rrrr'), vc.ano_ref) and nvl(to_char(gd_dt_fin, 'rrrr'), vc.ano_ref)
      order by 1 asc;
   --
   cursor c_imob_vend is
      select vc.cnpj_empr
           , vc.dm_st_proc
           , vc.dm_ind_oper
           , vc.dm_unid_imob
           , vc.dm_ind_nat_emp
        from vw_csf_oper_ativ_imob_vend vc
       where vc.cnpj_empr = gv_cnpj
         and vc.dt_oper between nvl(gd_dt_ini, vc.dt_oper) and nvl(gd_dt_fin, vc.dt_oper)
      order by 1 asc;
   --
   cursor c_oper_ins_pcrc is
      select vc.cnpj_empr
           , vc.dt_ref
           , vc.cod_st_pis
           , vc.aliq_pis
           , vc.cod_st_cofins
           , vc.aliq_cofins
        from vw_csf_cons_oper_ins_pc_rc vc
       where vc.cnpj_empr = gv_cnpj
         and vc.dt_ref between nvl(gd_dt_ini, vc.dt_ref) and nvl(gd_dt_fin, vc.dt_ref)
      order by 1 asc;
   --
   cursor c_ins_pcrc_aum is
      select vc.cnpj_empr
           , vc.dt_ref
           , vc.cod_st_pis
           , vc.vl_aliq_pis
           , vc.cod_st_cofins
           , vc.vl_aliq_cofins
        from vw_csf_cons_oper_ins_pc_rc_aum vc
       where vc.cnpj_empr = gv_cnpj
         and vc.dt_ref between nvl(gd_dt_ini, vc.dt_ref) and nvl(gd_dt_fin, vc.dt_ref)
      order by 1 asc;
   --
   cursor c_inspc_rcomp is
      select vc.cnpj_empr
           , vc.dt_ref
           , vc.cod_st_pis
           , vc.aliq_pis
           , vc.cod_st_cofins
           , vc.aliq_cofins
        from vw_csf_cons_oper_ins_pc_rcomp vc
       where vc.cnpj_empr = gv_cnpj
         and dt_ref between nvl(gd_dt_ini, vc.dt_ref) and nvl(gd_dt_fin, vc.dt_ref)
      order by 1 asc;
   --
   cursor c_pcrcomp_aum is
      select vc.cnpj_empr
           , vc.dt_ref
           , vc.cod_st_pis
           , vc.vl_aliq_pis
           , vc.cod_st_cofins
           , vc.vl_aliq_cofins
        from vw_csf_cons_op_ins_pcrcomp_aum vc
       where vc.cnpj_empr = gv_cnpj
         and dt_ref between nvl(gd_dt_ini, vc.dt_ref) and nvl(gd_dt_fin, vc.dt_ref)
      order by 1 asc;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_oper_ger_cc loop
      exit when c_oper_ger_cc%notfound or (c_oper_ger_cc%notfound) is null;
      --
      delete
        from vw_csf_pr_dem_doc_oper_ger_cc vc
       where vc.cnpj_empr                 = rec.cnpj_empr
         and nvl(vc.cod_part,' ')         = nvl(rec.cod_part,' ')
         and nvl(vc.cod_item,' ')         = nvl(rec.cod_item,' ')
         and vc.cod_st_pis                = rec.cod_st_pis
         and vc.cod_st_cofins             = rec.cod_st_cofins
         and nvl(vc.cd_basecalcredpc,' ') = nvl(rec.cd_basecalcredpc,' ')
         and vc.dm_st_proc                = rec.dm_st_proc;
      --
      vn_fase := 2;
      --
   end loop;
   --
   vn_fase := 3;
   --
   delete
     from vw_csf_dem_doc_oper_ger_cc vc
    where vc.cnpj_empr = gv_cnpj
      and vc.dt_oper between nvl(gd_dt_ini, vc.dt_oper) and nvl(gd_dt_fin, vc.dt_oper);
   --
   vn_fase := 4;
   --
   for rec in c_operced_pc loop
      exit when c_operced_pc%notfound or (c_operced_pc%notfound) is null;
      --
      delete
        from vw_csf_pr_bai_oper_cred_pc vc
       where vc.cnpj_empr                  = rec.cnpj_empr
         and vc.ano_ref                    = rec.ano_ref
         and vc.mes_ref                    = rec.mes_ref
         and vc.dm_tipo_oper               = rec.dm_tipo_oper
         and nvl(vc.cd_basecalccredpc,' ') = nvl(rec.cd_basecalccredpc,' ')
         and vc.cod_st_pis                 = rec.cod_st_pis
         and vc.cod_st_cofins              = rec.cod_st_cofins
         and nvl(vc.cod_cta,' ')           = nvl(rec.cod_cta,' ')
         and nvl(vc.cod_ccus,' ')          = nvl(rec.cod_ccus,' ')
         and vc.dm_st_proc                 = rec.dm_st_proc;
      --
      vn_fase := 5;
      --
   end loop;
   --
   vn_fase := 6;
   --
   delete
     from vw_csf_bemativimob_opercred_pc vc
    where vc.cnpj_empr = gv_cnpj
      and vc.mes_ref between nvl(to_char(gd_dt_ini, 'mm'), vc.mes_ref) and nvl(to_char(gd_dt_fin, 'mm'), vc.mes_ref)
      and vc.ano_ref between nvl(to_char(gd_dt_ini, 'rrrr'), vc.ano_ref) and nvl(to_char(gd_dt_fin, 'rrrr'), vc.ano_ref);
   --
   vn_fase := 7;
   --
   delete
     from vw_csf_cred_pres_est_abert_pc vc
    where vc.cnpj_empr = gv_cnpj
      and vc.mes_ref between nvl(to_char(gd_dt_ini, 'mm'), vc.mes_ref) and nvl(to_char(gd_dt_fin, 'mm'), vc.mes_ref)
      and vc.ano_ref between nvl(to_char(gd_dt_ini, 'rrrr'), vc.ano_ref) and nvl(to_char(gd_dt_fin, 'rrrr'), vc.ano_ref);
   --
   vn_fase := 8;
   --
   for rec in c_imob_vend loop
      exit when c_imob_vend%notfound or (c_imob_vend%notfound) is null;
      --
      delete
        from vw_csf_oper_ativ_imob_cus_inc vc
       where vc.cnpj_empr              = rec.cnpj_empr
         and vc.dm_st_proc             = rec.dm_st_proc
         and vc.dm_ind_oper            = rec.dm_ind_oper
         and vc.dm_unid_imob           = rec.dm_unid_imob
         and nvl(vc.dm_ind_nat_emp, 0) = nvl(rec.dm_ind_nat_emp, 0);
      --
      vn_fase := 9;
      --
      delete
        from vw_csf_oper_ativ_imob_cus_orc vc
       where vc.cnpj_empr              = rec.cnpj_empr
         and vc.dm_st_proc             = rec.dm_st_proc
         and vc.dm_ind_oper            = rec.dm_ind_oper
         and vc.dm_unid_imob           = rec.dm_unid_imob
         and nvl(vc.dm_ind_nat_emp, 0) = nvl(rec.dm_ind_nat_emp, 0);
      --
      vn_fase := 10;
      --
      delete
        from vw_csf_oper_ativ_imob_proc_ref vc
       where vc.cnpj_empr              = rec.cnpj_empr
         and vc.dm_st_proc             = rec.dm_st_proc
         and vc.dm_ind_oper            = rec.dm_ind_oper
         and vc.dm_unid_imob           = rec.dm_unid_imob
         and nvl(vc.dm_ind_nat_emp, 0) = nvl(rec.dm_ind_nat_emp, 0);
      --
      vn_fase := 11;
      --
   end loop;
   --
   vn_fase := 12;
   --
   delete
     from vw_csf_oper_ativ_imob_vend vc
    where vc.cnpj_empr = gv_cnpj
      and vc.dt_oper between nvl(gd_dt_ini, vc.dt_oper) and nvl(gd_dt_fin, vc.dt_oper);
   --
   vn_fase := 13;
   --
   for rec in c_oper_ins_pcrc loop
      exit when c_oper_ins_pcrc%notfound or (c_oper_ins_pcrc%notfound) is null;
      --
      delete
        from vw_csf_pr_cons_oper_ins_pc_rc vc
       where vc.cnpj_empr          = rec.cnpj_empr
         and vc.dt_ref             = rec.dt_ref
         and vc.cod_st_pis         = rec.cod_st_pis
         and nvl(vc.aliq_pis,0)    = nvl(rec.aliq_pis,0)
         and vc.cod_st_cofins      = rec.cod_st_cofins
         and nvl(vc.aliq_cofins,0) = nvl(rec.aliq_cofins,0);
      --
      vn_fase := 14;
      --
   end loop;
   --
   vn_fase := 15;
   --
   delete
     from vw_csf_cons_oper_ins_pc_rc vc
    where vc.cnpj_empr = gv_cnpj
      and vc.dt_ref between nvl(gd_dt_ini, vc.dt_ref) and nvl(gd_dt_fin, vc.dt_ref);
   --
   vn_fase := 16;
   --
   for rec in c_ins_pcrc_aum loop
      exit when c_ins_pcrc_aum%notfound or (c_ins_pcrc_aum%notfound) is null;
      --
      delete
        from vw_csf_pr_cons_op_ins_pcrc_aum vc
       where vc.cnpj_empr             = rec.cnpj_empr
         and vc.dt_ref                = rec.dt_ref
         and vc.cod_st_pis            = rec.cod_st_pis
         and nvl(vc.vl_aliq_pis,0)    = nvl(rec.vl_aliq_pis,0)
         and vc.cod_st_cofins         = rec.cod_st_cofins
         and nvl(vc.vl_aliq_cofins,0) = nvl(rec.vl_aliq_cofins,0);
      --
      vn_fase := 17;
      --
   end loop;
   --
   vn_fase := 18;
   --
   delete
     from vw_csf_cons_oper_ins_pc_rc_aum vc
    where vc.cnpj_empr = gv_cnpj
      and vc.dt_ref between nvl(gd_dt_ini, vc.dt_ref) and nvl(gd_dt_fin, vc.dt_ref);
   --
   vn_fase := 19;
   --
   delete
     from vw_csf_comp_rec_det_rc vc
    where vc.cnpj_empr = gv_cnpj
      and vc.dt_ref between nvl(gd_dt_ini, vc.dt_ref) and nvl(gd_dt_fin, vc.dt_ref);
   --
   vn_fase := 20;
   --
   for rec in c_inspc_rcomp loop
      exit when c_inspc_rcomp%notfound or (c_inspc_rcomp%notfound) is null;
      --
      delete
        from vw_csf_pr_cons_op_ins_pc_rcomp vc
       where vc.cnpj_empr          = rec.cnpj_empr
         and vc.dt_ref             = rec.dt_ref
         and vc.cod_st_pis         = rec.cod_st_pis
         and nvl(vc.aliq_pis,0)    = nvl(rec.aliq_pis,0)
         and vc.cod_st_cofins      = rec.cod_st_cofins
         and nvl(vc.aliq_cofins,0) = nvl(rec.aliq_cofins,0);
      --
      vn_fase := 21;
      --
   end loop;
   --
   vn_fase := 22;
   --
   delete
     from vw_csf_cons_oper_ins_pc_rcomp vc
    where vc.cnpj_empr = gv_cnpj
      and dt_ref between nvl(gd_dt_ini, vc.dt_ref) and nvl(gd_dt_fin, vc.dt_ref);
   --
   vn_fase := 23;
   --
   for rec in c_pcrcomp_aum loop
      exit when c_pcrcomp_aum%notfound or (c_pcrcomp_aum%notfound) is null;
      --
      delete
        from vw_csf_pr_cons_op_ins_pcrcoaum vc
       where vc.cnpj_empr             = rec.cnpj_empr
         and vc.dt_ref                = rec.dt_ref
         and vc.cod_st_pis            = rec.cod_st_pis
         and nvl(vc.vl_aliq_pis,0)    = nvl(rec.vl_aliq_pis,0)
         and vc.cod_st_cofins         = rec.cod_st_cofins
         and nvl(vc.vl_aliq_cofins,0) = nvl(rec.vl_aliq_cofins,0);
      --
      vn_fase := 24;
      --
   end loop;
   --
   vn_fase := 25;
   --
   delete
     from vw_csf_cons_op_ins_pcrcomp_aum vc
    where vc.cnpj_empr = gv_cnpj
      and dt_ref between nvl(gd_dt_ini, vc.dt_ref) and nvl(gd_dt_fin, vc.dt_ref);
   --
   vn_fase := 26;
   --
   delete
     from vw_csf_contr_ret_fonte_pc vc
    where vc.cnpj_empr = gv_cnpj
      and dt_ret between nvl(gd_dt_ini, vc.dt_ret) and nvl(gd_dt_fin, vc.dt_ret);
   --
   vn_fase := 27;
   --
   delete
     from vw_csf_deducao_diversa_pc vc
    where vc.cnpj_empr = gv_cnpj
      and vc.mes_ref between nvl(to_char(gd_dt_ini, 'mm'), vc.mes_ref) and nvl(to_char(gd_dt_fin, 'mm'), vc.mes_ref)
      and vc.ano_ref between nvl(to_char(gd_dt_ini, 'rrrr'), vc.ano_ref) and nvl(to_char(gd_dt_fin, 'rrrr'), vc.ano_ref);
   --
   vn_fase := 28;
   --
   delete
     from vw_csf_cred_decor_evento_pc vc
    where vc.cnpj_empr = gv_cnpj
      and vc.dt_evento between nvl(gd_dt_ini, vc.dt_evento) and nvl(gd_dt_fin, vc.dt_evento);
   --
   vn_fase := 29;
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_bloco_f fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_bloco_f;

----------------------------------------------------------------
--|PROCESSO QUE LIMPA INTEGRAÇÃO DO BLOCO I = 51|--
----------------------------------------------------------------
/*Leiaute_Views_Integracao_Inf_Bloco_I_PC_V1_1*/
procedure pkb_limpa_bloco_i is
   --
   vn_fase number := 0;
   --
   cursor c_bloco_ipc is
      select vc.cpf_cnpj_emit
           , vc.ano_ref
           , vc.dm_mes_ref
           , vc.dm_ind_ativ
           , vc.cst_pis
           , vc.aliq_pis
           , vc.cst_cofins
           , vc.aliq_cofins
           , vc.info_compl
        from vw_csf_inf_bloco_i_pc vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and vc.dm_mes_ref between nvl(to_char(gd_dt_ini, 'mm'), vc.dm_mes_ref) and nvl(to_char(gd_dt_fin, 'mm'), vc.dm_mes_ref)
         and vc.ano_ref between nvl(to_char(gd_dt_ini, 'rrrr'), vc.ano_ref) and nvl(to_char(gd_dt_fin, 'rrrr'), vc.ano_ref)
      order by 1 asc;
   --
   cursor c_det_bloco_ipc( ev_cpf_cnpj_emit in varchar2
                         , en_ano_ref       in number
                         , ev_dm_mes_ref    in varchar2
                         , ev_dm_ind_ativ   in varchar2
                         , ev_cst_pis       in varchar2
                         , en_aliq_pis      in number
                         , ev_cst_cofins    in varchar2
                         , en_aliq_cofins   in number
                         , ev_info_compl    in varchar2 )
      is
      select vc.cpf_cnpj_emit
           , vc.ano_ref
           , vc.dm_mes_ref
           , vc.dm_ind_ativ
           , vc.cst_pis
           , vc.aliq_pis
           , vc.cst_cofins
           , vc.aliq_cofins
           , vc.info_compl
           , vc.dm_tipo
           , vc.cod_comp
        from vw_csf_det_inf_bloco_i_pc vc
       where vc.cpf_cnpj_emit       = ev_cpf_cnpj_emit
         and vc.ano_ref             = en_ano_ref
         and vc.dm_mes_ref          = ev_dm_mes_ref
         and vc.dm_ind_ativ         = ev_dm_ind_ativ
         and vc.cst_pis             = ev_cst_pis
         and vc.aliq_pis            = en_aliq_pis
         and vc.cst_cofins          = ev_cst_cofins
         and vc.aliq_cofins         = en_aliq_cofins
         and nvl(vc.info_compl,' ') = nvl(ev_info_compl,' ')
      order by 1 asc;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_bloco_ipc loop
      exit when c_bloco_ipc%notfound or (c_bloco_ipc%notfound) is null;
      --
      delete
        from vw_csf_inf_bloco_i_pc_ff vc
       where vc.cpf_cnpj_emit       = rec.cpf_cnpj_emit
         and vc.ano_ref             = rec.ano_ref
         and vc.dm_mes_ref          = rec.dm_mes_ref
         and vc.dm_ind_ativ         = rec.dm_ind_ativ
         and vc.cst_pis             = rec.cst_pis
         and vc.aliq_pis            = rec.aliq_pis
         and vc.cst_cofins          = rec.cst_cofins
         and vc.aliq_cofins         = rec.aliq_cofins
         and nvl(vc.info_compl,' ') = nvl(rec.info_compl,' ');
      --
      vn_fase := 2;
      --
      for rec2 in c_det_bloco_ipc( rec.cpf_cnpj_emit , rec.ano_ref, rec.dm_mes_ref, rec.dm_ind_ativ
                                 , rec.cst_pis, rec.aliq_pis, rec.cst_cofins, rec.aliq_cofins, rec.info_compl ) loop
         exit when c_det_bloco_ipc%notfound or (c_det_bloco_ipc%notfound) is null;
         --
         delete
           from vw_csf_proc_ref_inf_bloco_i_pc vc
          where vc.cpf_cnpj_emit       = rec2.cpf_cnpj_emit
            and vc.ano_ref             = rec2.ano_ref
            and vc.dm_mes_ref          = rec2.dm_mes_ref
            and vc.dm_ind_ativ         = rec2.dm_ind_ativ
            and vc.cst_pis             = rec2.cst_pis
            and vc.aliq_pis            = rec2.aliq_pis
            and vc.cst_cofins          = rec2.cst_cofins
            and vc.aliq_cofins         = rec2.aliq_cofins
            and nvl(vc.info_compl,' ') = nvl(rec2.info_compl,' ')
            and vc.dm_tipo             = rec2.dm_tipo
            and vc.cod_comp            = rec2.cod_comp;
         --
         vn_fase := 3;
         --
      end loop;
      --
      vn_fase := 4;
      --
      delete
        from vw_csf_det_inf_bloco_i_pc vc
       where vc.cpf_cnpj_emit       = rec.cpf_cnpj_emit
         and vc.ano_ref             = rec.ano_ref
         and vc.dm_mes_ref          = rec.dm_mes_ref
         and vc.dm_ind_ativ         = rec.dm_ind_ativ
         and vc.cst_pis             = rec.cst_pis
         and vc.aliq_pis            = rec.aliq_pis
         and vc.cst_cofins          = rec.cst_cofins
         and vc.aliq_cofins         = rec.aliq_cofins
         and nvl(vc.info_compl,' ') = nvl(rec.info_compl,' ');
      --
      vn_fase := 5;
      --
   end loop;
   --
   vn_fase := 6;
   --
   delete
     from vw_csf_inf_bloco_i_pc vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and vc.dm_mes_ref between nvl(to_char(gd_dt_ini, 'mm'), vc.dm_mes_ref) and nvl(to_char(gd_dt_fin, 'mm'), vc.dm_mes_ref)
      and vc.ano_ref between nvl(to_char(gd_dt_ini, 'rrrr'), vc.ano_ref) and nvl(to_char(gd_dt_fin, 'rrrr'), vc.ano_ref);
   --
   vn_fase := 7;
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_bloco_i fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_bloco_i;

----------------------------------------------------------------
--|PROCESSO QUE LIMPA INTEGRAÇÃO EFD-REINF = 55|--
----------------------------------------------------------------
procedure pkb_limpa_reinf is
   --
   vn_fase number := 0;
   --
   cursor c_rreceb is
    select vc.cpf_cnpj
         , vc.dt_ref
         , vc.cod_part_orig
      from vw_csf_rec_receb_ass_desp vc
     where vc.cpf_cnpj = gv_cnpj
         and vc.dt_ref between nvl(gd_dt_ini,vc.dt_ref) and nvl(gd_dt_fin,vc.dt_ref)
      order by 1 asc;
   --
   cursor c_rrep is
    select vc.cpf_cnpj
         , vc.dt_ref
         , vc.cod_part_desp
      from vw_csf_rec_rep_ass_desp vc
     where vc.cpf_cnpj = gv_cnpj
         and vc.dt_ref between nvl(gd_dt_ini,vc.dt_ref) and nvl(gd_dt_fin,vc.dt_ref)
      order by 1 asc;
   --
   cursor c_comer is
   select vc.cpf_cnpj
        , vc.dt_ref
     from vw_csf_comer_prod_rural_pj_agr vc
    where vc.cpf_cnpj = gv_cnpj
      and vc.dt_ref between nvl(gd_dt_ini,vc.dt_ref) and nvl(gd_dt_fin,vc.dt_ref)
    order by 1 asc;
   --
   cursor c_esp is
   select vc.cpf_cnpj
        , vc.dt_ref
        , vc.NRO_BOLETIM
     from vw_csf_rec_esp_desport vc
    where vc.cpf_cnpj = gv_cnpj
      and vc.dt_ref between nvl(gd_dt_ini,vc.dt_ref) and nvl(gd_dt_fin,vc.dt_ref)
    order by 1 asc;
   --
   cursor c_empr is
   select vc.cpf_cnpj
        , vc.cod_item
        , vc.cod_lst
        , vc.cd_tp_serv_reinf
     from vw_csf_empr_item_tpservreinf vc
    where vc.cpf_cnpj = gv_cnpj
    order by 1 asc;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_rreceb loop
      exit when c_rreceb%notfound or (c_rreceb%notfound) is null;
      --
      vn_fase := 2;
      --
      delete from vw_csf_rec_receb_ass_desp_ff vc
       where vc.cpf_cnpj = rec.cpf_cnpj
         and vc.dt_ref   = rec.dt_ref
         and vc.cod_part_orig = rec.cod_part_orig;
      --
      vn_fase := 3;
      --
      delete from VW_CSF_INF_REC_RECEB_ASS_DESP vc
       where vc.cpf_cnpj = rec.cpf_cnpj
         and vc.dt_ref   = rec.dt_ref
         and vc.cod_part_orig = rec.cod_part_orig;
      --
      vn_fase := 4;
      --
      delete from VW_CSF_INF_PROC_ADM_REC_RECEB vc
       where vc.cpf_cnpj = rec.cpf_cnpj
         and vc.dt_ref   = rec.dt_ref
         and vc.cod_part_orig = rec.cod_part_orig;
      --
   end loop;
   --
   vn_fase := 5;
   --
   delete from vw_csf_rec_receb_ass_desp vc
    where vc.cpf_cnpj = gv_cnpj
      and vc.dt_ref between nvl(gd_dt_ini,vc.dt_ref) and nvl(gd_dt_fin,vc.dt_ref);
   --
   for rec in c_rrep loop
     exit when c_rrep%notfound or (c_rrep%notfound) is null;
     --
     vn_fase := 6;
     --
     delete from VW_CSF_REC_REP_ASS_DESP_FF vc
      where vc.cpf_cnpj = rec.cpf_cnpj
        and vc.dt_ref   = rec.dt_ref
        and vc.cod_part_desp = rec.cod_part_desp;
     --
     vn_fase := 7;
     --
     delete from VW_CSF_INF_REC_REP_ASS_DESP vc
      where vc.cpf_cnpj = rec.cpf_cnpj
        and vc.dt_ref   = rec.dt_ref
        and vc.cod_part_desp = rec.cod_part_desp;
     --
     vn_fase := 8;
     --
     delete from VW_CSF_INF_PROC_ADM_REC_REP vc
      where vc.cpf_cnpj = rec.cpf_cnpj
        and vc.dt_ref   = rec.dt_ref
        and vc.cod_part_desp = rec.cod_part_desp;
     --
   end loop;
   --
   vn_fase := 9;
   --
   delete from vw_csf_rec_rep_ass_desp vc
    where vc.cpf_cnpj = gv_cnpj
      and vc.dt_ref between nvl(gd_dt_ini,vc.dt_ref) and nvl(gd_dt_fin,vc.dt_ref);
   --
   vn_fase := 10;
   --
   for rec in c_comer loop
    exit when c_comer%notfound or (c_comer%notfound) is null;
      --
      vn_fase := 11;
      --
      delete from vw_csf_comerprodruralpjagr_ff vc
      where vc.cpf_cnpj = rec.cpf_cnpj
        and vc.dt_ref   = rec.dt_ref;
      --
      vn_fase := 12;
      --
      delete from vw_csf_tipo_comer_prod_rural vc
      where vc.cpf_cnpj = rec.cpf_cnpj
        and vc.dt_ref   = rec.dt_ref;
      --
      vn_fase := 13;
      --
      delete from vw_csf_tipo_comer_pr_rural_nf vc
      where vc.cpf_cnpj = rec.cpf_cnpj
        and vc.dt_ref   = rec.dt_ref;
      --
      vn_fase := 14;
      --
      delete from VW_CSF_COMER_PROD_INF_PROC_ADM vc
      where vc.cpf_cnpj = rec.cpf_cnpj
        and vc.dt_ref   = rec.dt_ref;
      --
   end loop;
   --
   vn_fase := 15;
   --
   delete from vw_csf_comer_prod_rural_pj_agr vc
    where vc.cpf_cnpj = gv_cnpj
      and vc.dt_ref between nvl(gd_dt_ini,vc.dt_ref) and nvl(gd_dt_fin,vc.dt_ref);
   --
   vn_fase := 16;
   --
   for rec in c_esp loop
    exit when c_esp%notfound or (c_esp%notfound) is null;
      --
      vn_fase := 17;
      --
      delete from vw_csf_rec_esp_desport_ff vc
       where vc.cpf_cnpj = rec.cpf_cnpj
         and vc.dt_ref   = rec.dt_ref
         and vc.nro_boletim = rec.nro_boletim;
      --
      vn_fase := 18;
      --
      delete from VW_CSF_REC_ESP_DESPORT_INGR vc
       where vc.cpf_cnpj = rec.cpf_cnpj
         and vc.dt_ref   = rec.dt_ref
         and vc.nro_boletim = rec.nro_boletim;
      --
      vn_fase := 19;
      --
      delete from VW_CSF_REC_ESP_DESPORT_OUTR vc
       where vc.cpf_cnpj = rec.cpf_cnpj
         and vc.dt_ref   = rec.dt_ref
         and vc.nro_boletim = rec.nro_boletim;
      --
      vn_fase := 20;
      --
      delete from VW_CSF_REC_ESP_DESPORT_TOTAL vc
       where vc.cpf_cnpj = rec.cpf_cnpj
         and vc.dt_ref   = rec.dt_ref
         and vc.nro_boletim = rec.nro_boletim;
      --
      vn_fase := 21;
      --
      delete from VW_CSF_INF_PROC_ADM_REC_ESP vc
       where vc.cpf_cnpj = rec.cpf_cnpj
         and vc.dt_ref   = rec.dt_ref
         and vc.nro_boletim = rec.nro_boletim;
      --
   end loop;
   --
   vn_fase := 22;
   --
   delete from vw_csf_rec_esp_desport vc
    where vc.cpf_cnpj = gv_cnpj
      and vc.dt_ref between nvl(gd_dt_ini,vc.dt_ref) and nvl(gd_dt_fin,vc.dt_ref);
   --
   for rec in c_empr loop
    exit when c_esp%notfound or (c_esp%notfound) is null;
      --
      vn_fase := 23;
      --
      delete from vw_csf_empritemtpservreinf_ff vc
       where vc.cpf_cnpj         = rec.cpf_cnpj
         and vc.cod_item         = rec.cod_item
         and vc.cod_lst          = rec.cod_lst
         and vc.cd_tp_serv_reinf = rec.cpf_cnpj;
      --
   end loop;
   --
   vn_fase := 24;
   --
   delete from vw_csf_empritemtpservreinf_ff vc
    where vc.cpf_cnpj         = gv_cnpj;
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_reinf fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_reinf;
----------------------------------------------------------------
--|PROCESSO QUE LIMPA INTEGRAÇÃO DIMOB = 52|--
----------------------------------------------------------------
/*Leiaute_de_TableViews_para_integração_de_Serviços_DIMOB_V_1_1*/
procedure pkb_limpa_dimob is
   --
   vn_fase number := 0;
   --
   cursor c_loc is
      select vc.cpf_cnpj_emit
           , vc.ano_ref
           , vc.seq_locacao
           , vc.cod_part_locador
           , vc.cod_part_locatario
           , vc.num_contrato
        from vw_csf_locacao vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and vc.ano_ref between nvl(to_char(gd_dt_ini, 'rrrr'), vc.ano_ref) and nvl(to_char(gd_dt_fin, 'rrrr'), vc.ano_ref)
      order by 1 asc;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_loc loop
      exit when c_loc%notfound or (c_loc%notfound) is null;
      --
      delete
        from vw_csf_det_valor_locacao vc
       where vc.cpf_cnpj_emit      = rec.cpf_cnpj_emit
         and vc.ano_ref            = rec.ano_ref
         and vc.seq_locacao        = rec.seq_locacao
         and vc.cod_part_locador   = rec.cod_part_locador
         and vc.cod_part_locatario = rec.cod_part_locatario
         and vc.num_contrato       = rec.num_contrato;
      --
      vn_fase := 2;
      --
   end loop;
   --
   vn_fase := 3;
   --
   delete
     from vw_csf_locacao vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and vc.ano_ref between nvl(to_char(gd_dt_ini, 'rrrr'), vc.ano_ref) and nvl(to_char(gd_dt_fin, 'rrrr'), vc.ano_ref);
   --
   vn_fase := 4;
   --
   delete
     from vw_csf_ficha_incorp_constr vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and vc.ano_ref between nvl(to_char(gd_dt_ini, 'rrrr'), vc.ano_ref) and nvl(to_char(gd_dt_fin, 'rrrr'), vc.ano_ref);
   --
   vn_fase := 5;
   --
   delete
     from vw_csf_ficha_interm_venda vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and vc.ano_ref between nvl(to_char(gd_dt_ini, 'rrrr'), vc.ano_ref) and nvl(to_char(gd_dt_fin, 'rrrr'), vc.ano_ref);
   --
   vn_fase := 6;
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_dimob fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_dimob;
--
--------------------------------------------------------------------
--|PROCESSO QUE LIMPA INTEGRAÇÃO INFORMAÇÃO SOBRE EXPORTAÇÃO = 53|--
--------------------------------------------------------------------
/*Leiaute_Integr_OI_53_Info_Expor_V1_2*/
--
procedure pkb_limpa_infexp is
   --
   vn_fase number := 0;
   --
   -- Chave da vw_csf_infor_exportacao
   -- cpf_cnpj_emit / dm_ind_doc / nro_de / dt_de / nro_re / chc_emb
   --
   cursor c_infexp is
      select vc.cpf_cnpj_emit
           , vc.dm_ind_doc
           , vc.nro_de
           , vc.dt_de
           , vc.nro_re
           , vc.chc_emb
        from vw_csf_infor_exportacao vc
       where vc.cpf_cnpj_emit = gv_cnpj
         and vc.dt_avb        between nvl(gd_dt_ini,vc.dt_avb) and nvl(gd_dt_fin,vc.dt_avb)
         --and vc.dt_de   between nvl(gd_dt_ini,vc.dt_de) and nvl(gd_dt_fin,vc.dt_de)
      order by 1 asc;
   --
   -- Chave da vw_csf_infor_export_nf
   -- cpf_cnpj_emit     / dm_ind_doc      / nro_de          / dt_de      / nro_re              / chc_emb /
   -- cpf_cnpj_emit_nfe / dm_ind_emit_nfe / dm_ind_oper_nfe
   -- cod_part_nfe      / cod_mod_nfe     / serie_nfe       / nro_nf_nfe / dm_arm_nfe_terc_nfe / cod_item  / nro_item
   --
   cursor c_infexpnf( ev_cpf_cnpj_emit in varchar2
                    , en_dm_ind_doc    in number
                    , en_nro_de        in number
                    , ed_dt_de         in date
                    , en_nro_re        in number
                    , ev_chc_emb       in varchar2 ) is
      --
      select vc.cpf_cnpj_emit
           , vc.dm_ind_doc
           , vc.nro_de
           , vc.dt_de
           , vc.nro_re
           , vc.chc_emb
           , vc.cpf_cnpj_emit_nfe
           , vc.dm_ind_emit_nfe
           , vc.dm_ind_oper_nfe
           , vc.cod_part_nfe
           , vc.cod_mod_nfe
           , vc.serie_nfe
           , vc.nro_nf_nfe
           , vc.dm_arm_nfe_terc_nfe
           , vc.cod_item
           , vc.nro_item
        from vw_csf_infor_export_nf vc
       where vc.cpf_cnpj_emit     = ev_cpf_cnpj_emit
         and vc.dm_ind_doc        = en_dm_ind_doc
         and vc.nro_de            = en_nro_de
         and vc.dt_de             = ed_dt_de
         and nvl(vc.nro_re,0)     = nvl(en_nro_re,0)
         and nvl(vc.chc_emb,0)    = nvl(ev_chc_emb,0);
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_infexp
   loop
      --
      exit when c_infexp%notfound or (c_infexp%notfound) is null;
      --
      vn_fase := 2;
      --
      for recnf in c_infexpnf( ev_cpf_cnpj_emit => rec.cpf_cnpj_emit
                             , en_dm_ind_doc    => rec.dm_ind_doc
                             , en_nro_de        => rec.nro_de
                             , ed_dt_de         => rec.dt_de
                             , en_nro_re        => rec.nro_re
                             , ev_chc_emb       => rec.chc_emb )
      loop
         --
         exit when c_infexpnf%notfound or (c_infexpnf%notfound) is null;
         --
         vn_fase := 3;
         --
         -- Table/View de Operações de Exportação Indireta de Produtos.
         -- Chave da vw_csf_oper_export_ind_nf
         -- cpf_cnpj_emit    / dm_ind_doc       / nro_de        / dt_de        / nro_re              / chc_emb
         -- cpf_cnpj_emit_nfe / dm_ind_emit_nfe      / dm_ind_oper_nfe
         -- cod_part_nfe     / cod_mod_nfe      / serie_nfe     / nro_nf_nfe   / dm_arm_nfe_terc_nfe / cod_item          / nro_item             / cpf_cnpj_emit_oper
         -- dm_ind_emit_oper / dm_ind_oper_oper / cod_part_oper / cod_mod_oper / serie_oper          / nro_nf_oper       / dm_arm_nfe_terc_oper /
         --
         delete
           from vw_csf_oper_export_ind_nf vc
          where vc.cpf_cnpj_emit       = recnf.cpf_cnpj_emit
            and vc.dm_ind_doc          = recnf.dm_ind_doc
            and vc.nro_de              = recnf.nro_de
            and vc.dt_de               = recnf.dt_de
            and nvl(vc.nro_re,0)       = nvl(recnf.nro_re,0)
            and nvl(vc.chc_emb, 0)     = nvl(recnf.chc_emb, 0)
            and vc.cpf_cnpj_emit_nfe   = recnf.cpf_cnpj_emit_nfe
            and vc.dm_ind_emit_nfe     = recnf.dm_ind_emit_nfe
            and vc.dm_ind_oper_nfe     = recnf.dm_ind_oper_nfe
            and nvl(vc.cod_part_nfe,0) = nvl(recnf.cod_part_nfe,0)
            and vc.cod_mod_nfe         = recnf.cod_mod_nfe
            and vc.serie_nfe           = recnf.serie_nfe
            and vc.nro_nf_nfe          = recnf.nro_nf_nfe
            and vc.dm_arm_nfe_terc_nfe = recnf.dm_arm_nfe_terc_nfe
            and vc.cod_item            = recnf.cod_item
            and vc.nro_item            = recnf.nro_item;
         --
      end loop; -- final do cursor c_infexpnf
      --
      vn_fase := 4;
      -- Table/View de Documentos Fiscais de Exportação.
      delete
        from vw_csf_infor_export_nf vc
       where vc.cpf_cnpj_emit  = rec.cpf_cnpj_emit
         and vc.dm_ind_doc     = rec.dm_ind_doc
         and vc.nro_de         = rec.nro_de
         and vc.dt_de          = rec.dt_de
         and nvl(vc.nro_re,0)  = nvl(rec.nro_re,0)
         and nvl(vc.chc_emb,0) = nvl(rec.chc_emb,0);
      --
      vn_fase := 5;
      -- Tabela de integração de campos flex field referente ao Registro de Informacões sobre exportacão.
      delete
        from vw_csf_infor_exportacao_ff vc
       where vc.cpf_cnpj_emit  = rec.cpf_cnpj_emit
         and vc.dm_ind_doc     = rec.dm_ind_doc
         and vc.nro_de         = rec.nro_de
         and vc.dt_de          = rec.dt_de
         and nvl(vc.nro_re,0)  = nvl(rec.nro_re,0)
         and nvl(vc.chc_emb,0) = nvl(rec.chc_emb,0);
      --
   end loop;
   --
   vn_fase := 6;
   -- Table/View de Registro de Informacões sobre exportacão.
   delete
     from vw_csf_infor_exportacao vc
    where vc.cpf_cnpj_emit = gv_cnpj
      and vc.dt_avb        between nvl(gd_dt_ini,vc.dt_avb) and nvl(gd_dt_fin,vc.dt_avb);
      --and vc.dt_de   between nvl(gd_dt_ini,vc.dt_de) and nvl(gd_dt_fin,vc.dt_de);
   --
   vn_fase := 7;
   --
   commit;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpa_infexp fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpa_infexp;

----------------------------------------------------------------
--| PROCESSO QUE INICIA A LIMPEZA, PROCESSO PUBLICO |--
----------------------------------------------------------------
procedure pkb_limpar ( en_multorg_id   in mult_org.id%type
                     , en_objintegr_id in obj_integr.id%type
                     , en_usuario_id   in neo_usuario.id%type
                     , ed_dt_ini       in date default null
                     , ed_dt_fin       in date default null
                     )

   is
   --
   vn_fase         number := 0;
   --
   cursor c_empresa is
      select em.*
        from empresa em
       where em.multorg_id = gn_multorg_id
      order by 1 asc;
   --
begin
   --
   vn_fase := 1;
   --
   gn_multorg_id   := en_multorg_id;
   gn_objintegr_id := en_objintegr_id;
   gn_usuario_id   := en_usuario_id;
   gd_dt_ini       := ed_dt_ini;
   gd_dt_fin       := ed_dt_fin;
   --
   vn_fase := 2;
   --
   if fkb_validar then
      --
      vn_fase := 3;
      --
      for rec in c_empresa loop
         exit when c_empresa%notfound or (c_empresa%notfound) is null;
         --
         gn_empresa_id := rec.id;
         --
         vn_fase := 3.1;
         --
         gv_cnpj := pk_csf.fkg_cnpj_ou_cpf_empresa(en_empresa_id => gn_empresa_id);
         --
         vn_fase := 4;
         --
         pkb_reg_info; --|GRAVA INFORMAÇÃO DE DELEÇÃO DOS REGISTROS DE INTEGRAÇÃO|--
         --
         if gv_cd_objintegr = '1' then    --|CADASTROS GERAIS|--
            --
            vn_fase := 5;
            --
            pkb_limpa_cad(en_multorg_id,0);
            --
         elsif gv_cd_objintegr = '2' then --|INVENTARIO DE ESTOQUE DE PRODUTOS|--
            --
            vn_fase := 6;
            --
            pkb_limpa_inventario;
            --
         elsif gv_cd_objintegr = '3' then --|CUPOM FISCAL|--
            --
            vn_fase := 7;
            --
            pkb_limpa_cupom_fiscal;
            --
         elsif gv_cd_objintegr = '4' then --|CONHECIMENTO DE TRANSPORTE|--
            --
            vn_fase := 8;
            --
            pkb_limpa_conhec_transp;
            --
            --#72357 incluida nova procedure que limpa cte emissoa propria
            pkb_limpa_conhec_transp_ep;
            --
         elsif gv_cd_objintegr = '5' then --|NOTAS FISCAIS DE SERVIÇO CONTINUO(AGUA, LUZ, ETC)|--
            --
            vn_fase := 9;
            --
            pkb_limpa_nfs_cont;
            --
         elsif gv_cd_objintegr = '6' then --|NOTAS FISCAIS MERCANTIS|-- modelo 55
            --
            vn_fase := 10;
            --
            pkb_limpa_nf_mercantis;
            --
         elsif gv_cd_objintegr = '7' then --|NOTAS FISCAIS DE SERVIÇO|--
            --
            vn_fase := 11;
            --
            pkb_limpa_notas_serv;
            --
         elsif gv_cd_objintegr = '8' then --|CIAP|--
            --
            vn_fase := 12;
            --
            pkb_limpa_ciap;
            --
         elsif gv_cd_objintegr = '9' then --|CRÉDITO ACUMULADO ICMS SP|--
            --
            vn_fase := 13;
            --
            pkb_limpa_ecredac;
            --
         elsif gv_cd_objintegr = '13' then --|NOTAS FISCAIS MERCANTIS|-- modelo 65
            --
            vn_fase := 10;
            --
            pkb_limpa_nf_mercantis_nfce;
            --
         elsif gv_cd_objintegr = '19' then --|USUÁRIO|--
            --
            vn_fase := 14;
            --
            pkb_limpa_usuario;
            --
         elsif gv_cd_objintegr = '27' then --| Escrituração Contábil Fiscal - SPED ECF |--
            --
            vn_fase := 14;
            --
            pkb_limpa_secf;
            --
         elsif gv_cd_objintegr = '32' then --|DADOS CONTABEIS|--
            --
            vn_fase := 15;
            --
            pkb_limpa_dados_contabeis;
            --
         elsif gv_cd_objintegr = '33' then --|PRODUÇÃO DIARIA DE USINA|--
            --
            vn_fase := 16;
            --
            pkb_limpa_diaria_usina;
            --
         elsif gv_cd_objintegr = '36' then --|INFORMAÇÕES DE VALORES AGREGADOS|--
            --
            vn_fase := 17;
            --
            pkb_limpa_info_vl_agreg;
            --
         elsif gv_cd_objintegr = '39' then --|CONTROLE DE CRÉDITOS FISCAIS DE ICMS|--
            --
            vn_fase := 18;
            --
            pkb_limpa_ccf_icms;
            --
         elsif gv_cd_objintegr = '42' then --|TOTAL DE OPERAÇÕES COM CARTÃO|--
            --
            vn_fase := 19;
            --
            pkb_limpa_op_cartao;
            --
         elsif gv_cd_objintegr = '45' then --|INFORMAÇÕES DA FOLHA DE PAGAMENTOS|--
            --
            vn_fase := 20;
            --
            pkb_limpa_folha_pgto;
            --
         elsif gv_cd_objintegr = '46' then --|PAGAMENTO DE IMPOSTOS NO PADRÃO DCTF|--
            --
            vn_fase := 21;
            --
            pkb_limpa_pgto_imp;
            --
         elsif gv_cd_objintegr = '47' then  --|INFORMAÇÕES DIRF|--
            --
            vn_fase := 22;
            --
            pkb_limpa_dirf;
            --
         elsif gv_cd_objintegr = '48' then --|CONTROLE DE PRODUÇÃO DE ESTOQUE|--
            --
            vn_fase := 23;
            --
            pkb_limpa_ctrl_prod_estoque;
            --
         elsif gv_cd_objintegr = '49' then --|SOLICITAÇÃO DE CONTROLE DE CADASTROS|--
            --
            vn_fase := 24;
            --
            pkb_limpa_sol_ctrl_cadastro;
            --
         elsif gv_cd_objintegr = '50' then --|BLOCO F|--
            --
            vn_fase := 25;
            --
            pkb_limpa_bloco_f;
            --
         elsif gv_cd_objintegr = '51' then --|BLOCO I|--
            --
            vn_fase := 26;
            --
            pkb_limpa_bloco_i;
            --
         elsif gv_cd_objintegr = '52' then --|DIMOB|--
            --
            vn_fase := 27;
            --
            pkb_limpa_dimob;
            --
         elsif gv_cd_objintegr = '53' then --|Informação sobre Exportação|--
            --
            vn_fase := 28;
            --
            pkb_limpa_infexp;
            --
         elsif gv_cd_objintegr = '55' then --|REINF|--
            --
            vn_fase := 29;
            --
            pkb_limpa_reinf;
            --
         end if;
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpar fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpar;
--
-------------------------------------------------------------------
--| PROCESSO QUE INICIA A LIMPEZA POR EMPRESA, PROCESSO PUBLICO |--
-------------------------------------------------------------------
procedure pkb_limpar_empr ( en_empresa_id   in empresa.id%type
                           , en_objintegr_id in obj_integr.id%type
                           , en_usuario_id   in neo_usuario.id%type
                           , ed_dt_ini       in date default null
                           , ed_dt_fin       in date default null
                           )

   is
   --
   vn_fase         number := 0;
   --
begin
  --
  vn_fase := 1;
  --
  gn_objintegr_id := en_objintegr_id;
  gn_usuario_id   := en_usuario_id;
  gd_dt_ini       := ed_dt_ini;
  gd_dt_fin       := ed_dt_fin;
  gn_empresa_id   := en_empresa_id;
  --
    begin
      --
      select pg.valor
        into gv_tipo_sistema
        from param_global_csf pg
       where pg.cd = 'SISTEMA_EM_NUVEM';
      --
   exception
      when others then
         --
         gv_tipo_sistema := null;
         --
   end;
  --
  vn_fase := 2;
  --
  if gn_objintegr_id is not null then
    --
    vn_fase := 2.1;
    --
    gv_cd_objintegr  :=null;
    gv_desc_objintegr:=null;
    --
    begin
       --
       select oi.cd, oi.descr
         into gv_cd_objintegr, gv_desc_objintegr
         from obj_integr oi
        where oi.id = gn_objintegr_id;
       --
    exception
       when no_data_found then
          --
          raise_application_error(-20001, 'Objeto de Integração informado não existe (ID = '||gn_objintegr_id||').');
          --
       when others then
          --
          raise_application_error(-20001, 'Problemas ao identificar o objeto de integração (ID = '||gn_objintegr_id||'). Erro: '||SQLerrm);
          --
    end;
    --
  end if;
  --
  vn_fase := 3;
  --
  gv_cnpj := pk_csf.fkg_cnpj_ou_cpf_empresa(en_empresa_id => gn_empresa_id);
  --
  vn_fase := 4;
  --
  pkb_reg_info; --|GRAVA INFORMAÇÃO DE DELEÇÃO DOS REGISTROS DE INTEGRAÇÃO|--
  --
  if gv_cd_objintegr = '1' then    --|CADASTROS GERAIS|--
    --
    vn_fase := 5;
    --
    pkb_limpa_cad(0,en_empresa_id);
    --
  elsif gv_cd_objintegr = '2' then --|INVENTARIO DE ESTOQUE DE PRODUTOS|--
    --
    vn_fase := 6;
    --
    pkb_limpa_inventario;
    --
  elsif gv_cd_objintegr = '3' then --|CUPOM FISCAL|--
    --
    vn_fase := 7;
    --
    pkb_limpa_cupom_fiscal;
    --
  elsif gv_cd_objintegr = '4' then --|CONHECIMENTO DE TRANSPORTE|--
    --
    vn_fase := 8;
    --
    pkb_limpa_conhec_transp;
    --
    --#72357 incluida nova procedure que limpa cte emissoa propria
    pkb_limpa_conhec_transp_ep;
    --
    --
  elsif gv_cd_objintegr = '5' then --|NOTAS FISCAIS DE SERVIÇO CONTINUO(AGUA, LUZ, ETC)|--
    --
    vn_fase := 9;
    --
    pkb_limpa_nfs_cont;
    --
  elsif gv_cd_objintegr = '6' then --|NOTAS FISCAIS MERCANTIS|-- modelo 55
    --
    vn_fase := 10;
    --
    pkb_limpa_nf_mercantis;
    --
  elsif gv_cd_objintegr = '7' then --|NOTAS FISCAIS DE SERVIÇO|--
    --
    vn_fase := 11;
    --
    pkb_limpa_notas_serv;
    --
  elsif gv_cd_objintegr = '8' then --|CIAP|--
    --
    vn_fase := 12;
    --
    pkb_limpa_ciap;
    --
  elsif gv_cd_objintegr = '9' then --|CRÉDITO ACUMULADO ICMS SP|--
    --
    vn_fase := 13;
    --
    pkb_limpa_ecredac;
    --
  elsif gv_cd_objintegr = '13' then --|NOTAS FISCAIS MERCANTIS|-- modelo 65
    --
    vn_fase := 10;
    --
    pkb_limpa_nf_mercantis_nfce;
    --
  elsif gv_cd_objintegr = '19' then --|USUÁRIO|--
    --
    vn_fase := 14;
    --
    pkb_limpa_usuario;
    --
  elsif gv_cd_objintegr = '27' then --| Escrituração Contábil Fiscal - SPED ECF |--
    --
    vn_fase := 14;
    --
    pkb_limpa_secf;
    --
  elsif gv_cd_objintegr = '32' then --|DADOS CONTABEIS|--
    --
    vn_fase := 15;
    --
    pkb_limpa_dados_contabeis;
    --
  elsif gv_cd_objintegr = '33' then --|PRODUÇÃO DIARIA DE USINA|--
    --
    vn_fase := 16;
    --
    pkb_limpa_diaria_usina;
    --
  elsif gv_cd_objintegr = '36' then --|INFORMAÇÕES DE VALORES AGREGADOS|--
    --
    vn_fase := 17;
    --
    pkb_limpa_info_vl_agreg;
    --
  elsif gv_cd_objintegr = '39' then --|CONTROLE DE CRÉDITOS FISCAIS DE ICMS|--
    --
    vn_fase := 18;
    --
    pkb_limpa_ccf_icms;
    --
  elsif gv_cd_objintegr = '42' then --|TOTAL DE OPERAÇÕES COM CARTÃO|--
    --
    vn_fase := 19;
    --
    pkb_limpa_op_cartao;
    --
  elsif gv_cd_objintegr = '45' then --|INFORMAÇÕES DA FOLHA DE PAGAMENTOS|--
    --
    vn_fase := 20;
    --
    pkb_limpa_folha_pgto;
    --
  elsif gv_cd_objintegr = '46' then --|PAGAMENTO DE IMPOSTOS NO PADRÃO DCTF|--
    --
    vn_fase := 21;
    --
    pkb_limpa_pgto_imp;
    --
  elsif gv_cd_objintegr = '47' then  --|INFORMAÇÕES DIRF|--
    --
    vn_fase := 22;
    --
    pkb_limpa_dirf;
    --
  elsif gv_cd_objintegr = '48' then --|CONTROLE DE PRODUÇÃO DE ESTOQUE|--
    --
    vn_fase := 23;
    --
    pkb_limpa_ctrl_prod_estoque;
    --
  elsif gv_cd_objintegr = '49' then --|SOLICITAÇÃO DE CONTROLE DE CADASTROS|--
    --
    vn_fase := 24;
    --
    pkb_limpa_sol_ctrl_cadastro;
    --
  elsif gv_cd_objintegr = '50' then --|BLOCO F|--
    --
    vn_fase := 25;
    --
    pkb_limpa_bloco_f;
    --
  elsif gv_cd_objintegr = '51' then --|BLOCO I|--
    --
    vn_fase := 26;
    --
    pkb_limpa_bloco_i;
    --
  elsif gv_cd_objintegr = '52' then --|DIMOB|--
    --
    vn_fase := 27;
    --
    pkb_limpa_dimob;
    --
  elsif gv_cd_objintegr = '53' then --|Informação sobre Exportação|--
    --
    vn_fase := 28;
    --
    pkb_limpa_infexp;
    --
  elsif gv_cd_objintegr = '55' then --|REINF|--
    --
    vn_fase := 29;
    --
    pkb_limpa_reinf;
    --
  end if;
  --
   --
exception
   when others then
      --
      raise_application_error(-20001, 'Erro na pk_limpa_open_interf.pkb_limpar fase ('||vn_fase||'). Erro: '||SQLerrm);
      --
end pkb_limpar_empr;
--
end pk_limpa_open_interf;
/
