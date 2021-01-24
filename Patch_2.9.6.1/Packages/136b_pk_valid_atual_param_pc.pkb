CREATE OR REPLACE PACKAGE BODY CSF_OWN.PK_VALID_ATUAL_PARAM_PC IS

----------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--| Procedimento para Validar/Atualizar os documentos fiscais - centros de custos
----------------------------------------------------------------------------------
PROCEDURE PKB_VAL_ATU_CC IS
   --
   vn_fase                  number := 0;
   vv_resumo_log            log_generico.resumo%type := null;
   vn_loggenerico_id        log_generico.id%type := null;
   vn_qtde                  number := 0;
   vn_ncm_id                ncm.id%type;
   vn_tpservico_id          tipo_servico.id%type;
   vn_centrocusto_id_pis    centro_custo.id%type;
   vn_centrocusto_id_cofins centro_custo.id%type;
   --
   --| Recuperar a empresa e suas filiais
   cursor c_empresa is
      select ep.id empresa_id
           , ep.dm_dt_escr_dfepoe
        from empresa em
           , empresa ep
       where em.id = gt_row_valid_atual_param_pc.empresa_id
         and (( gt_row_valid_atual_param_pc.dm_consol = 0 and ep.id = em.id ) -- 0-não, considerar a empresa conectada/logada
                or
              ( gt_row_valid_atual_param_pc.dm_consol = 1 and nvl(ep.ar_empresa_id, ep.id) = nvl(em.ar_empresa_id, em.id) )) -- 1-sim, considerar empresa conectada/logada e suas filiais
       order by 1;
   --
   -- Centro de Custo - Notas Fiscais de Serviço - PIS e/ou COFINS
   --
   cursor c_a170_ct( en_empresa_id        in empresa.id%type
                   , en_dm_dt_escr_dfepoe in empresa.dm_dt_escr_dfepoe%type ) is
   select 'A100/A170' reg_bloco
        , 'NOTA_FISCAL' obj_referencia
        , nf.id registro_id
        , ('Nota fiscal de Serviço - Item da Nota Fiscal. Número NF: '||nf.nro_nf||', série: '||nf.serie||', data de emissão: '||nf.dt_emiss||
           ', modelo fiscal: '||mf.cod_mod||'.') inform
        , nf.dm_ind_emit
        , nf.dm_ind_oper
        , nf.modfiscal_id
        , nf.pessoa_id
        , it.cfop_id
        , it.item_id
        , it.cod_ncm
        , it.cd_lista_serv
        , ic.itemnf_id
        , cs.cod_st
     from nota_fiscal       nf
        , mod_fiscal        mf
        , item_nota_fiscal  it
        , itemnf_compl_serv ic
        , imp_itemnf        im
        , cod_st            cs
        , tipo_imposto      ti
    where nf.empresa_id      = en_empresa_id
      and nf.dm_st_proc      in (4,7,8) -- 4-Autorizada, 7-Cancelada, 8-Inutilizada
      and nf.dm_arm_nfe_terc = 0 -- 0-não, 1-sim
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final)))
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod         in ('99', 'ND') -- Serviços / Nota de Débito
      --and mf.cod_mod       = '99' -- somente serviços
      and it.notafiscal_id   = nf.id
      and ic.itemnf_id       = it.id
      and ic.centrocusto_id is null
      and im.itemnf_id       = it.id
      and im.dm_tipo         = 0 -- 0-imposto, 1-retenção
      and cs.id              = im.codst_id
      and ti.id              = im.tipoimp_id
      and ti.cd              in (4,5)
   order by nf.id;
   --
   -- Centros de Custos - Controle de Créditos Fiscais de PIS - Apuração de Crédito Extemporâneo
   --
   cursor c_1101_ctpis(en_empresa_id in empresa.id%type) is
   select '1100/1101' reg_bloco
        , 'CONTR_CRED_FISCAL_PIS' obj_referencia
        , cc.id registro_id
        , ('Controle de Créditos Fiscais de PIS - Apuração de Crédito Extemporâneo. Mês/Ano: '||lpad(cc.mes,2,'0')||'/'||lpad(cc.ano,4,'0')||', Código do '||
          'Tipo de Crédito: '||tc.cd||'-'||tc.descr||', Data da Operação: '||to_char(ac.dt_oper,'dd/mm/rrrr')||', CFOP: '||cf.cd||'-'||cf.descr||'.') inform
        , ac.cfop_id
        , ac.id apurcredextpis_id
     from contr_cred_fiscal_pis cc
        , apur_cred_ext_pis     ac
        , tipo_cred_pc          tc
        , cfop                  cf
    where cc.empresa_id           = en_empresa_id
      and cc.dm_situacao          = 3 -- processada
      and to_date((cc.mes||'/'||cc.ano),'mm/rrrr') between gt_row_valid_atual_param_pc.dt_ini and gt_row_valid_atual_param_pc.dt_final
      and ac.contrcredfiscalpis_id = cc.id
      and ac.centrocusto_id       is null
      and tc.id                    = cc.tipocredpc_id
      and cf.id                    = ac.cfop_id
    order by cc.id;
   --
   -- Centros de Custos - Controle de Créditos Fiscais de COFINS - Apuração de Crédito Extemporâneo
   --
   cursor c_1501_ctcof(en_empresa_id in empresa.id%type) is
   select '1500/1501' reg_bloco
        , 'CONTR_CRED_FISCAL_COFINS' obj_referencia
        , cc.id registro_id
        , ('Controle de Créditos Fiscais de COFINS - Apuração de Crédito Extemporâneo. Mês/Ano: '||
          lpad(cc.mes,2,'0')||'/'||lpad(cc.ano,4,'0')||', Código do Tipo de Crédito: '||tc.cd||'-'||tc.descr||', data da operação: '||
          to_char(ac.dt_oper,'dd/mm/rrrr')||', CFOP: '||cf.cd||'-'||cf.descr||'.') inform
        , ac.cfop_id
        , ac.id apurcredextcofins_id
     from contr_cred_fiscal_cofins cc
        , apur_cred_ext_cofins     ac
        , tipo_cred_pc             tc
        , cfop                     cf
    where cc.empresa_id               = en_empresa_id
      and cc.dm_situacao              = 3 -- processada
      and to_date((cc.mes||'/'||cc.ano),'mm/rrrr') between gt_row_valid_atual_param_pc.dt_ini and gt_row_valid_atual_param_pc.dt_final
      and ac.contrcredfiscalcofins_id = cc.id
      and ac.centrocusto_id          is null
      and tc.id                       = cc.tipocredpc_id
      and cf.id                       = ac.cfop_id
    order by cc.id;
   --
   -- Centros de Custos - Demais Documentos e Operações Geradoras de Contribuição e Créditos - F100 - PIS e/ou COFINS
   --
   cursor c_f100_ct(en_empresa_id in empresa.id%type) is
   select 'F100' reg_bloco
        , 'DEM_DOC_OPER_GER_CC' obj_referencia
        , dd.id registro_id
        , ('Demais Documentos e Operações Geradoras de Contribuição e Créditos - F100. Data da Operação: '||dd.dt_oper||', Valor da Operação: '||
           trim(to_char(dd.vl_oper,'999G999G999G990D00'))||'.') inform
        , dd.pessoa_id
        , dd.item_id
        , dd.id demdocopergercc_id
     from dem_doc_oper_ger_cc dd
    where dd.empresa_id      = en_empresa_id
      and trunc(dd.dt_oper)  between gt_row_valid_atual_param_pc.dt_ini and gt_row_valid_atual_param_pc.dt_final
      and dd.dm_st_proc      = 1 -- validado
      and dd.centrocusto_id  is null
    order by dd.id;
   --
   -- Centros de Custos - Bens do Ativo Imobilizado operações gerados de crédito PIS/COFINS - Depreciação/Amortização - F120. Não temos parâmetros para essa atualização - Utilizar a tela/portal para correção.
   -- Centros de Custos - Bens do Ativo Imobilizado operações gerados de crédito Pis/Cofins - Aquisição/Contribuição - F130. Não temos parâmetros para essa atualização - Utilizar a tela/portal para correção.
   --
BEGIN
   --
   vn_fase := 1;
   -- Empresa solicitada e suas filiais - consolidando
   for r_empresa in c_empresa
   loop
      --
      exit when c_empresa%notfound or (c_empresa%notfound);
      --
      vn_fase := 2;
      vn_qtde := 0;
      --
      -- Centro de Custo - Notas Fiscais de Serviço - PIS e/ou COFINS
      for r_a170_custo in c_a170_ct( en_empresa_id        => r_empresa.empresa_id
                                   , en_dm_dt_escr_dfepoe => r_empresa.dm_dt_escr_dfepoe )
      loop
         --
         exit when c_a170_ct%notfound or (c_a170_ct%notfound);
         --
         vn_fase := 2.1;
         --
         vn_qtde := nvl(vn_qtde,0) + 1;
         vn_ncm_id := pk_csf.fkg_ncm_id(ev_cod_ncm => r_a170_custo.cod_ncm);
         vn_tpservico_id := pk_csf.fkg_tipo_servico_id(ev_cod_lst => r_a170_custo.cd_lista_serv);
         --
         vn_fase := 2.2;
         -- Função para retornar o centro de custo para PIS
         vn_centrocusto_id_pis := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_id
                                                                      , en_dm_ind_emit  => r_a170_custo.dm_ind_emit
                                                                      , en_dm_ind_oper  => r_a170_custo.dm_ind_oper
                                                                      , en_modfiscal_id => r_a170_custo.modfiscal_id
                                                                      , en_pessoa_id    => r_a170_custo.pessoa_id
                                                                      , en_cfop_id      => r_a170_custo.cfop_id
                                                                      , en_item_id      => r_a170_custo.item_id
                                                                      , en_ncm_id       => vn_ncm_id
                                                                      , en_tpservico_id => vn_tpservico_id
                                                                      , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                      , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                      , en_cod_st_piscofins => r_a170_custo.cod_st
                                                                      , ev_ret          => 'CCTO_PIS' );
         --
         vn_fase := 2.3;
         --
         if nvl(vn_centrocusto_id_pis,0) <> 0 then
            --
            vn_fase := 2.4;
            --
            begin
               update itemnf_compl_serv ic
                  set ic.centrocusto_id = vn_centrocusto_id_pis
                where ic.itemnf_id = r_a170_custo.itemnf_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar o Complemento do Item da Nota Fiscal de Serviço - Centro de Custo. Identificador do Item = '||
                                   r_a170_custo.itemnf_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 2.5;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_a170_custo.reg_bloco -- reg_bloco
                                                     , r_a170_custo.obj_referencia -- obj_referencia
                                                     , r_a170_custo.registro_id -- registro_id / itemnf_id
                                                     , r_a170_custo.inform||' Centro de Custo: '||pk_csf.fkg_cd_centro_custo(vn_centrocusto_id_pis)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Complemento do Item da Nota Fiscal de Serviço - Centro de Custo. '||
                                   'Identificador do item = '||r_a170_custo.itemnf_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 2.6;
            --
            commit;
            --
         else -- nvl(vn_centrocusto_id_pis,0) = 0
            --
            vn_fase := 2.7;
            -- Função para retornar o centro de custo para COFINS
            vn_centrocusto_id_cofins := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_id
                                                                            , en_dm_ind_emit  => r_a170_custo.dm_ind_emit
                                                                            , en_dm_ind_oper  => r_a170_custo.dm_ind_oper
                                                                            , en_modfiscal_id => r_a170_custo.modfiscal_id
                                                                            , en_pessoa_id    => r_a170_custo.pessoa_id
                                                                            , en_cfop_id      => r_a170_custo.cfop_id
                                                                            , en_item_id      => r_a170_custo.item_id
                                                                            , en_ncm_id       => vn_ncm_id
                                                                            , en_tpservico_id => vn_tpservico_id
                                                                            , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                            , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                            , en_cod_st_piscofins => r_a170_custo.cod_st
                                                                            , ev_ret          => 'CCTO_COF' );
            --
            vn_fase := 2.8;
            --
            if nvl(vn_centrocusto_id_cofins,0) <> 0 then
               --
               vn_fase := 2.9;
               --
               begin
                  update itemnf_compl_serv ic
                     set ic.centrocusto_id = vn_centrocusto_id_cofins
                   where ic.itemnf_id = r_a170_custo.itemnf_id;
               exception
                  when others then
                     gv_resumo_log := 'Problemas ao alterar o Complemento do Item da Nota Fiscal de Serviço - Centro de Custo. Identificador do Item = '||
                                      r_a170_custo.itemnf_id||'. Erro = '||sqlerrm;
                     pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                      , ev_mensagem       => gv_mensagem_log
                                                      , ev_resumo         => gv_resumo_log
                                                      , en_tipo_log       => erro_de_sistema
                                                      , en_referencia_id  => gn_referencia_id
                                                      , ev_obj_referencia => gv_obj_referencia
                                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               end;
               --
               vn_fase := 2.10;
               --
               begin
                  insert into validatualparampc_regbloco( id
                                                        , validatualparampc_id
                                                        , reg_bloco
                                                        , obj_referencia
                                                        , registro_id
                                                        , inform )
                                                  values( validatualparampcregbloco_seq.nextval -- id
                                                        , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                        , r_a170_custo.reg_bloco -- reg_bloco
                                                        , r_a170_custo.obj_referencia -- obj_referencia
                                                        , r_a170_custo.registro_id -- registro_id / itemnf_id
                                                        , r_a170_custo.inform||' Centro de Custo: '||pk_csf.fkg_cd_centro_custo(vn_centrocusto_id_cofins)||'.' ); -- inform
               exception
                  when others then
                     gv_resumo_log := 'Problemas ao incluir registro atualizado - Complemento do Item da Nota Fiscal de Serviço - Centro de Custo. Identificador do '||
                                      'item = '||r_a170_custo.itemnf_id||'. Erro = '||sqlerrm;
                     pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                      , ev_mensagem       => gv_mensagem_log
                                                      , ev_resumo         => gv_resumo_log
                                                      , en_tipo_log       => erro_de_sistema
                                                      , en_referencia_id  => gn_referencia_id
                                                      , ev_obj_referencia => gv_obj_referencia
                                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               end;
               --
               vn_fase := 2.11;
               --
               commit;
               --
            else -- nvl(vn_centrocusto_id_cofins,0) = 0
               --
               vn_fase := 2.12;
               --
               vv_resumo_log := 'Não foi encontrado Centro de Custo - PIS e/ou COFINS. '||r_a170_custo.inform||' Parâmetros utilizados: '||
                                'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||
                                '), Indicador de emitente = '||pk_csf.fkg_dominio(ev_dominio => 'NOTA_FISCAL.DM_IND_EMIT', ev_vl => r_a170_custo.dm_ind_emit)||
                                ' (en_dm_ind_emit = '||r_a170_custo.dm_ind_emit||', Indicador da Operação = '||pk_csf.fkg_dominio(ev_dominio =>
                                'NOTA_FISCAL.DM_IND_OPER', ev_vl => r_a170_custo.dm_ind_oper)||' (en_dm_ind_oper = '||r_a170_custo.dm_ind_oper||
                                '), Modelo Fiscal = '||pk_csf.fkg_cod_mod_id(en_modfiscal_id => r_a170_custo.modfiscal_id)||' (en_modfiscal_id = '||
                                r_a170_custo.modfiscal_id||'), Participante = '||pk_csf.fkg_pessoa_cod_part(en_pessoa_id => r_a170_custo.pessoa_id)||'-'||
                                pk_csf.fkg_nome_pessoa_id(en_pessoa_id => r_a170_custo.pessoa_id)||' (en_pessoa_id = '||r_a170_custo.pessoa_id||'), CFOP = '||
                                pk_csf.fkg_cfop_cd(en_cfop_id => r_a170_custo.cfop_id)||' (en_cfop_id = '||r_a170_custo.cfop_id||'), Item = '||
                                pk_csf.fkg_item_cod(en_item_id => r_a170_custo.item_id)||' (en_item_id = '||r_a170_custo.item_id||'), NCM = '||
                                r_a170_custo.cod_ncm||', Código da Lista de Serviço = '||r_a170_custo.cd_lista_serv||', Data Inicial = '||
                                gt_row_valid_atual_param_pc.dt_ini||', Data Final = '||gt_row_valid_atual_param_pc.dt_final||'. Identificador do item (ID) = '||
                                r_a170_custo.itemnf_id||'.';
               pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                , ev_mensagem       => gv_mensagem_log
                                                , ev_resumo         => vv_resumo_log
                                                , en_tipo_log       => erro_inform_geral
                                                , en_referencia_id  => gn_referencia_id
                                                , ev_obj_referencia => gv_obj_referencia
                                                , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               --
            end if; -- nvl(vn_centrocusto_id_cofins,0) <> 0
            --
         end if; -- nvl(vn_centrocusto_id_pis,0) <> 0
         --
      end loop; -- Centro de Custo - Notas Fiscais de Serviço - PIS e/ou COFINS
      --
      vn_fase := 2.13;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Notas Fiscais de Serviço - Complemento do Item da Nota Fiscal - Centro de Custo = '||vn_qtde||
                       '. Essa quantidade não indica que todos os registros foram atualizados, para isso, verifique os logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
      vn_fase := 3;
      vn_qtde := 0;
      --
      -- Centros de Custos - Controle de Créditos Fiscais de PIS - Apuração de Crédito Extemporâneo
      for r_1101_custo in c_1101_ctpis( en_empresa_id => r_empresa.empresa_id )
      loop
         --
         exit when c_1101_ctpis%notfound or (c_1101_ctpis%notfound);
         --
         vn_fase := 3.1;
         vn_qtde := nvl(vn_qtde,0) + 1;
         -- Função para retornar o centro de custo para PIS
         vn_centrocusto_id_pis := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_id
                                                                      , en_dm_ind_emit  => null -- dm_ind_emit
                                                                      , en_dm_ind_oper  => null -- dm_ind_oper
                                                                      , en_modfiscal_id => null -- modfiscal_id
                                                                      , en_pessoa_id    => null -- pessoa_id
                                                                      , en_cfop_id      => r_1101_custo.cfop_id
                                                                      , en_item_id      => null -- item_id
                                                                      , en_ncm_id       => null -- ncm_id
                                                                      , en_tpservico_id => null -- tpservico_id
                                                                      , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                      , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                      , en_cod_st_piscofins => null -- cod_st
                                                                      , ev_ret          => 'CCTO_PIS' );
         --
         vn_fase := 3.2;
         --
         if nvl(vn_centrocusto_id_pis,0) <> 0 then
            --
            vn_fase := 3.3;
            --
            begin
               update apur_cred_ext_pis ac
                  set ac.centrocusto_id = vn_centrocusto_id_pis
                where ac.id = r_1101_custo.apurcredextpis_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Controle de Créditos Fiscais de PIS - Apuração de Crédito Extemporâneo - Centro de Custo. '||
                                   'Identificador da Apuração = '||r_1101_custo.apurcredextpis_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 3.4;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_1101_custo.reg_bloco -- reg_bloco
                                                     , r_1101_custo.obj_referencia -- obj_referencia
                                                     , r_1101_custo.registro_id -- registro_id / nfcomploperpis_id
                                                     , r_1101_custo.inform||' Centro de Custo: '||pk_csf.fkg_cd_centro_custo(vn_centrocusto_id_pis)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Controle de Créditos Fiscais de PIS - Apuração de Crédito Extemporâneo - Centro '||
                                   'de Custo. Identificador da Apuração = '||r_1101_custo.apurcredextpis_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 3.5;
            --
            commit;
            --
         else -- nvl(vn_centrocusto_id_pis,0) = 0
            --
            vn_fase := 3.6;
            --
            vv_resumo_log := 'Não foi encontrado Centro de Custo - PIS. '||r_1101_custo.inform||' Parâmetros utilizados: Empresa = '||
                             pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||'), CFOP = '||
                             pk_csf.fkg_cfop_cd(en_cfop_id => r_1101_custo.cfop_id)||' (en_cfop_id = '||r_1101_custo.cfop_id||'), Data Inicial = '||
                             gt_row_valid_atual_param_pc.dt_ini||', Data Final = '||gt_row_valid_atual_param_pc.dt_final||'. Identificador da Apuração de '||
                             'PIS (ID) = '||r_1101_custo.apurcredextpis_id||'.';
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                             , ev_mensagem       => gv_mensagem_log
                                             , ev_resumo         => vv_resumo_log
                                             , en_tipo_log       => erro_inform_geral
                                             , en_referencia_id  => gn_referencia_id
                                             , ev_obj_referencia => gv_obj_referencia
                                             , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            --
         end if;
         --
      end loop; -- Centros de Custos - Controle de Créditos Fiscais de PIS - Apuração de Crédito Extemporâneo
      --
      vn_fase := 3.7;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Controle de Créditos Fiscais de PIS - Apuração de Crédito Extemporâneo - Centros de Custos = '||vn_qtde||
                       '. Essa quantidade não indica que todos os registros foram atualizados, para isso, verifique os logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
      vn_fase := 4;
      vn_qtde := 0;
      --
      -- Centros de Custos - Controle de Créditos Fiscais de COFINS - Apuração de Crédito Extemporâneo
      for r_1501_custo in c_1501_ctcof( en_empresa_id => r_empresa.empresa_id )
      loop
         --
         exit when c_1501_ctcof%notfound or (c_1501_ctcof%notfound);
         --
         vn_fase := 4.1;
         vn_qtde := nvl(vn_qtde,0) + 1;
         -- Função para retornar o centro de custo para COFINS
         vn_centrocusto_id_cofins := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_id
                                                                         , en_dm_ind_emit  => null -- dm_ind_emit
                                                                         , en_dm_ind_oper  => null -- dm_ind_oper
                                                                         , en_modfiscal_id => null -- modfiscal_id
                                                                         , en_pessoa_id    => null -- pessoa_id
                                                                         , en_cfop_id      => r_1501_custo.cfop_id
                                                                         , en_item_id      => null -- item_id
                                                                         , en_ncm_id       => null -- ncm_id
                                                                         , en_tpservico_id => null -- tpservico_id
                                                                         , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                         , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                         , en_cod_st_piscofins => null -- cod_st 
                                                                         , ev_ret          => 'CCTO_COF' );
         --
         vn_fase := 4.2;
         --
         if nvl(vn_centrocusto_id_cofins,0) <> 0 then
            --
            vn_fase := 4.3;
            --
            begin
               update apur_cred_ext_cofins ac
                  set ac.centrocusto_id = vn_centrocusto_id_cofins
                where ac.id = r_1501_custo.apurcredextcofins_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Controle de Créditos Fiscais de COFINS - Apuração de Crédito Extemporâneo - Centro de Custo. '||
                                   'Identificador da Apuração = '||r_1501_custo.apurcredextcofins_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 4.4;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_1501_custo.reg_bloco -- reg_bloco
                                                     , r_1501_custo.obj_referencia -- obj_referencia
                                                     , r_1501_custo.registro_id -- registro_id / nfcomplopercofins_id
                                                     , r_1501_custo.inform||' Centro de Custo: '||pk_csf.fkg_cd_centro_custo(vn_centrocusto_id_cofins)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Controle de Créditos Fiscais de COFINS - Apuração de Crédito Extemporâneo - '||
                                   'Centro de Custo. Identificador da Apuração = '||r_1501_custo.apurcredextcofins_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 4.5;
            --
            commit;
            --
         else -- nvl(vn_centrocusto_id_cofins,0) = 0
            --
            vn_fase := 4.6;
            --
            vv_resumo_log := 'Não foi encontrado Centro de Custo - COFINS. '||r_1501_custo.inform||' Parâmetros utilizados: Empresa = '||
                             pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||'), CFOP = '||
                             pk_csf.fkg_cfop_cd(en_cfop_id => r_1501_custo.cfop_id)||' (en_cfop_id = '||r_1501_custo.cfop_id||'), Data Inicial = '||
                             gt_row_valid_atual_param_pc.dt_ini||', Data Final = '||gt_row_valid_atual_param_pc.dt_final||'. Identificador da Apuração de '||
                             'COFINS (ID) = '||r_1501_custo.apurcredextcofins_id||'.';
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                             , ev_mensagem       => gv_mensagem_log
                                             , ev_resumo         => vv_resumo_log
                                             , en_tipo_log       => erro_inform_geral
                                             , en_referencia_id  => gn_referencia_id
                                             , ev_obj_referencia => gv_obj_referencia
                                             , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            --
         end if;
         --
      end loop; -- Centros de Custos - Controle de Créditos Fiscais de COFINS - Apuração de Crédito Extemporâneo
      --
      vn_fase := 4.7;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Controle de Créditos Fiscais de COFINS - Apuração de Crédito Extemporâneo - Centros de Custos = '||vn_qtde||
                       '. Essa quantidade não indica que todos os registros foram atualizados, para isso, verifique os logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
      vn_fase := 5;
      vn_qtde := 0;
      --
      -- Centros de Custos - Demais Documentos e Operações Geradoras de Contribuição e Créditos - F100 - PIS e/ou COFINS
      for r_f100_custo in c_f100_ct( en_empresa_id => r_empresa.empresa_id )
      loop
         --
         exit when c_f100_ct%notfound or (c_f100_ct%notfound);
         --
         vn_fase := 5.1;
         vn_qtde := nvl(vn_qtde,0) + 1;
         -- Função para retornar o centro de custo para PIS
         vn_centrocusto_id_pis := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_id
                                                                      , en_dm_ind_emit  => null -- dm_ind_emit
                                                                      , en_dm_ind_oper  => null -- dm_ind_oper
                                                                      , en_modfiscal_id => null -- modfiscal_id
                                                                      , en_pessoa_id    => r_f100_custo.pessoa_id
                                                                      , en_cfop_id      => null -- cfop_id
                                                                      , en_item_id      => r_f100_custo.item_id
                                                                      , en_ncm_id       => null -- ncm_id
                                                                      , en_tpservico_id => null -- tpservico_id
                                                                      , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                      , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                      , en_cod_st_piscofins => null -- cod_st 
                                                                      , ev_ret          => 'CCTO_PIS' );
         --
         vn_fase := 5.2;
         --
         if nvl(vn_centrocusto_id_pis,0) <> 0 then
            --
            vn_fase := 5.3;
            --
            begin
               update dem_doc_oper_ger_cc dd
                  set dd.centrocusto_id = vn_centrocusto_id_pis
                where dd.id = r_f100_custo.demdocopergercc_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Demais Documentos e Operações Geradoras de Contribuição e Créditos - F100 - Centro de Custo. '||
                                   'Identificador do F100 = '||r_f100_custo.demdocopergercc_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 5.4;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_f100_custo.reg_bloco -- reg_bloco
                                                     , r_f100_custo.obj_referencia -- obj_referencia
                                                     , r_f100_custo.registro_id -- registro_id / itemnf_id
                                                     , r_f100_custo.inform||' Centro de Custo: '||pk_csf.fkg_cd_centro_custo(vn_centrocusto_id_pis)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Demais Documentos e Operações Geradoras de Contribuição e Créditos - F100 - '||
                                   'Centro de Custo. Identificador do F100 = '||r_f100_custo.demdocopergercc_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 5.5;
            --
            commit;
            --
         else -- nvl(vn_centrocusto_id_pis,0) = 0
            --
            vn_fase := 5.6;
            -- Função para retornar o centro de custo para COFINS
            vn_centrocusto_id_cofins := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_id
                                                                            , en_dm_ind_emit  => null -- dm_ind_emit
                                                                            , en_dm_ind_oper  => null -- dm_ind_oper
                                                                            , en_modfiscal_id => null -- modfiscal_id
                                                                            , en_pessoa_id    => r_f100_custo.pessoa_id
                                                                            , en_cfop_id      => null -- cfop_id
                                                                            , en_item_id      => r_f100_custo.item_id
                                                                            , en_ncm_id       => null -- ncm_id
                                                                            , en_tpservico_id => null -- tpservico_id
                                                                            , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                            , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                            , en_cod_st_piscofins => null -- cod_st 
                                                                            , ev_ret          => 'CCTO_COF' );
            --
            vn_fase := 5.7;
            --
            if nvl(vn_centrocusto_id_cofins,0) <> 0 then
               --
               vn_fase := 5.8;
               --
               begin
                  update dem_doc_oper_ger_cc dd
                     set dd.centrocusto_id = vn_centrocusto_id_cofins
                   where dd.id = r_f100_custo.demdocopergercc_id;
               exception
                  when others then
                     gv_resumo_log := 'Problemas ao alterar Demais Documentos e Operações Geradoras de Contribuição e Créditos - F100 - Centro de Custo. '||
                                      'Identificador do F100 = '||r_f100_custo.demdocopergercc_id||'. Erro = '||sqlerrm;
                     pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                      , ev_mensagem       => gv_mensagem_log
                                                      , ev_resumo         => gv_resumo_log
                                                      , en_tipo_log       => erro_de_sistema
                                                      , en_referencia_id  => gn_referencia_id
                                                      , ev_obj_referencia => gv_obj_referencia
                                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               end;
               --
               vn_fase := 5.9;
               --
               begin
                  insert into validatualparampc_regbloco( id
                                                        , validatualparampc_id
                                                        , reg_bloco
                                                        , obj_referencia
                                                        , registro_id
                                                        , inform )
                                                  values( validatualparampcregbloco_seq.nextval -- id
                                                        , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                        , r_f100_custo.reg_bloco -- reg_bloco
                                                        , r_f100_custo.obj_referencia -- obj_referencia
                                                        , r_f100_custo.registro_id -- registro_id / itemnf_id
                                                        , r_f100_custo.inform||' Centro de Custo: '||pk_csf.fkg_cd_centro_custo(vn_centrocusto_id_cofins)||'.' ); -- inform
               exception
                  when others then
                     gv_resumo_log := 'Problemas ao incluir registro atualizado - Demais Documentos e Operações Geradoras de Contribuição e Créditos - F100 - '||
                                      'Centro de Custo. Identificador do F100 = '||r_f100_custo.demdocopergercc_id||'. Erro = '||sqlerrm;
                     pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                      , ev_mensagem       => gv_mensagem_log
                                                      , ev_resumo         => gv_resumo_log
                                                      , en_tipo_log       => erro_de_sistema
                                                      , en_referencia_id  => gn_referencia_id
                                                      , ev_obj_referencia => gv_obj_referencia
                                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               end;
               --
               vn_fase := 5.10;
               --
               commit;
               --
            else -- nvl(vn_centrocusto_id_cofins,0) = 0
               --
               vn_fase := 5.11;
               --
               vv_resumo_log := 'Não foi encontrado Centro de Custo - PIS e/ou COFINS. '||r_f100_custo.inform||' Parâmetros utilizados: Empresa = '||
                                pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||
                                '), Participante = '||pk_csf.fkg_pessoa_cod_part(en_pessoa_id => r_f100_custo.pessoa_id)||'-'||
                                pk_csf.fkg_nome_pessoa_id(en_pessoa_id => r_f100_custo.pessoa_id)||' (en_pessoa_id = '||r_f100_custo.pessoa_id||'), Item = '||
                                pk_csf.fkg_item_cod(en_item_id => r_f100_custo.item_id)||' (en_item_id = '||r_f100_custo.item_id||'), Data Inicial = '||
                                gt_row_valid_atual_param_pc.dt_ini||', Data Final = '||gt_row_valid_atual_param_pc.dt_final||'. Identificador do F100 (ID) = '||
                                r_f100_custo.demdocopergercc_id||'.';
               pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                , ev_mensagem       => gv_mensagem_log
                                                , ev_resumo         => vv_resumo_log
                                                , en_tipo_log       => erro_inform_geral
                                                , en_referencia_id  => gn_referencia_id
                                                , ev_obj_referencia => gv_obj_referencia
                                                , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               --
            end if; -- nvl(vn_centrocusto_id_cofins,0) <> 0
            --
         end if; -- nvl(vn_centrocusto_id_pis,0) <> 0
         --
      end loop; -- Centros de Custos - Demais Documentos e Operações Geradoras de Contribuição e Créditos - F100 - PIS e/ou COFINS
      --
      vn_fase := 5.12;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Demais Documentos e Operações Geradoras de Contribuição e Créditos - F100 - Centros de Custos = '||vn_qtde||
                       '. Essa quantidade não indica que todos os registros foram atualizados, para isso, verifique os logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
   end loop; -- Empresa solicitada e suas filiais - consolidando
   --
EXCEPTION
   when others then
      raise_application_error (-20101, 'Problemas em pk_valid_atual_param_pc.pkb_val_atu_cc - Validar/Atualizar os documentos fiscais - centros de custos. '||
                                       'Fase = '||vn_fase||'. Erro = '||sqlerrm);
END PKB_VAL_ATU_CC;

---------------------------------------------------------------------------------
--| Procedimento para Validar/Atualizar os documentos fiscais - planos de contas
---------------------------------------------------------------------------------
PROCEDURE PKB_VAL_ATU_PC IS
   --
   vn_fase                 number := 0;
   vv_resumo_log           log_generico.resumo%type := null;
   vn_loggenerico_id       log_generico.id%type := null;
   vn_qtde                 number := 0;
   vn_ncm_id               ncm.id%type;
   vn_tpservico_id         tipo_servico.id%type;
   vn_planoconta_id_pis    plano_conta.id%type;
   vn_planoconta_id_cofins plano_conta.id%type;
   --
   --| Recuperar a empresa e suas filiais
   cursor c_empresa is
      select ep.id empresa_id
           , ep.dm_dt_escr_dfepoe
           , case when ep.ar_empresa_id is null then ep.id
             else ep.ar_empresa_id
             end empresa_matriz_id  --#74522
        from empresa em
           , empresa ep
       where em.id = gt_row_valid_atual_param_pc.empresa_id
         and (( gt_row_valid_atual_param_pc.dm_consol = 0 and ep.id = em.id ) -- 0-não, considerar a empresa conectada/logada
                or
              ( gt_row_valid_atual_param_pc.dm_consol = 1 and nvl(ep.ar_empresa_id, ep.id) = nvl(em.ar_empresa_id, em.id) )) -- 1-sim, considerar empresa conectada/logada e suas filiais
       order by 1;
   --
   -- Planos de Contas - Notas Fiscais de Serviço Contínuo - PIS
   --
   cursor c_c501_plpis( en_empresa_id        in empresa.id%type
                      , en_dm_dt_escr_dfepoe in empresa.dm_dt_escr_dfepoe%type ) is
   select 'C500/C501' reg_bloco
        , 'NOTA_FISCAL' obj_referencia
        , nf.id registro_id
        , ('Nota fiscal de serviço contínuo - Imposto PIS - Complemento de PIS. Número NF: '||nf.nro_nf||', série: '||nf.serie||
           ', data de emissão: '||nf.dt_emiss||', modelo fiscal: '||mf.cod_mod||'.') inform
        , nf.dm_ind_emit
        , nf.dm_ind_oper
        , nf.modfiscal_id
        , nf.pessoa_id
        , decode(nvl(it.cfop_id,0), 0, ra.cfop_id, it.cfop_id) cfop_id
        , it.item_id
        , it.cod_ncm
        , it.cd_lista_serv
        , np.id nfcomploperpis_id
        , cs.cod_st
     from nota_fiscal       nf
        , mod_fiscal        mf
        , nf_compl_oper_pis np
        , cod_st            cs
        , item_nota_fiscal  it
        , nfregist_analit   ra
    where nf.empresa_id       = en_empresa_id
      and nf.dm_st_proc      in (4,7,8) -- 4-Autorizada, 7-Cancelada, 8-Inutilizada
      and nf.dm_arm_nfe_terc  = 0 -- 0-não, 1-sim
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final)))
      and mf.id               = nf.modfiscal_id
      and mf.cod_mod         in ('06', '28', '29')
      and np.notafiscal_id    = nf.id
      and np.planoconta_id   is null
      and cs.id               = np.codst_id
      and cs.cod_st      not in ('70','71','72','73','74','75') -- valores isentos de créditos
      and it.notafiscal_id(+) = nf.id
      and ra.notafiscal_id    = nf.id
    order by nf.id;
   --
   -- Planos de Contas - Notas Fiscais de Serviço Contínuo - COFINS
   --
   cursor c_c505_plcof( en_empresa_id        in empresa.id%type
                      , en_dm_dt_escr_dfepoe in empresa.dm_dt_escr_dfepoe%type ) is
   select 'C500/C505' reg_bloco
        , 'NOTA_FISCAL' obj_referencia
        , nf.id registro_id
        , ('Nota fiscal de serviço contínuo - Imposto COFINS - Complemento de COFINS. Número NF: '||nf.nro_nf||', série: '||nf.serie||
           ', data de emissão: '||nf.dt_emiss||', modelo fiscal: '||mf.cod_mod||'.') inform
        , nf.dm_ind_emit
        , nf.dm_ind_oper
        , nf.modfiscal_id
        , nf.pessoa_id
        , decode(nvl(it.cfop_id,0), 0, ra.cfop_id, it.cfop_id) cfop_id
        , it.item_id
        , it.cod_ncm
        , it.cd_lista_serv
        , nc.id nfcomplopercofins_id
        , cs.cod_st
     from nota_fiscal          nf
        , mod_fiscal           mf
        , nf_compl_oper_cofins nc
        , cod_st               cs
        , item_nota_fiscal     it
        , nfregist_analit      ra
    where nf.empresa_id       = en_empresa_id
      and nf.dm_st_proc      in (4,7,8) -- 4-Autorizada, 7-Cancelada, 8-Inutilizada
      and nf.dm_arm_nfe_terc  = 0 -- 0-não, 1-sim
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final)))
      and mf.id               = nf.modfiscal_id
      and mf.cod_mod         in ('06', '28', '29')
      and nc.notafiscal_id    = nf.id
      and nc.planoconta_id   is null
      and cs.id               = nc.codst_id
      and cs.cod_st      not in ('70','71','72','73','74','75') -- valores isentos de créditos
      and it.notafiscal_id(+) = nf.id
      and ra.notafiscal_id    = nf.id
    order by nf.id;
   --
   -- Planos de Contas - Notas Fiscais de Serviço de Transporte e Comunicação - PIS
   --
   cursor c_d501_plpis( en_empresa_id        in empresa.id%type
                      , en_dm_dt_escr_dfepoe in empresa.dm_dt_escr_dfepoe%type ) is
   select 'D500/D501' reg_bloco
        , 'NOTA_FISCAL' obj_referencia
        , nf.id registro_id
        , ('Nota fiscal de serviço de transporte e comunicação - Imposto PIS - Complemento de PIS. Número NF: '||nf.nro_nf||', série: '||nf.serie||
           ', data de emissão: '||nf.dt_emiss||', modelo fiscal: '||mf.cod_mod||'.') inform
        , nf.dm_ind_emit
        , nf.dm_ind_oper
        , nf.modfiscal_id
        , nf.pessoa_id
        , decode(nvl(it.cfop_id,0), 0, ra.cfop_id, it.cfop_id) cfop_id
        , it.item_id
        , it.cod_ncm
        , it.cd_lista_serv
        , np.id nfcomploperpis_id
        , cs.cod_st
     from nota_fiscal       nf
        , mod_fiscal        mf
        , nf_compl_oper_pis np
        , cod_st            cs
        , item_nota_fiscal  it
        , nfregist_analit   ra
    where nf.empresa_id       = en_empresa_id
      and nf.dm_st_proc      in (4,7,8) -- 4-Autorizada, 7-Cancelada, 8-Inutilizada
      and nf.dm_arm_nfe_terc  = 0 -- 0-não, 1-sim
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final)))
      and mf.id               = nf.modfiscal_id
      and mf.cod_mod         in ('21', '22')
      and np.notafiscal_id    = nf.id
      and np.planoconta_id   is null
      and cs.id               = np.codst_id
      and cs.cod_st      not in ('70','71','72','73','74','75') -- valores isentos de créditos
      and it.notafiscal_id(+) = nf.id
      and ra.notafiscal_id    = nf.id
    order by nf.id;
   --
   -- Planos de Contas - Notas Fiscais de Serviço de Transporte e Comunicação - COFINS
   --
   cursor c_d505_plcof( en_empresa_id        in empresa.id%type
                      , en_dm_dt_escr_dfepoe in empresa.dm_dt_escr_dfepoe%type ) is
   select 'D500/D505' reg_bloco
        , 'NOTA_FISCAL' obj_referencia
        , nf.id registro_id
        , ('Nota fiscal de serviço de transporte e comunicação - Imposto COFINS - Complemento de COFINS. Número NF: '||nf.nro_nf||', série: '||nf.serie||
           ', data de emissão: '||nf.dt_emiss||', modelo fiscal: '||mf.cod_mod||'.') inform
        , nf.dm_ind_emit
        , nf.dm_ind_oper
        , nf.modfiscal_id
        , nf.pessoa_id
        , decode(nvl(it.cfop_id,0), 0, ra.cfop_id, it.cfop_id) cfop_id
        , it.item_id
        , it.cod_ncm
        , it.cd_lista_serv
        , nc.id nfcomplopercofins_id
        , cs.cod_st
     from nota_fiscal          nf
        , mod_fiscal           mf
        , nf_compl_oper_cofins nc
        , cod_st               cs
        , item_nota_fiscal     it
        , nfregist_analit      ra
    where nf.empresa_id       = en_empresa_id
      and nf.dm_st_proc      in (4,7,8) -- 4-Autorizada, 7-Cancelada, 8-Inutilizada
      and nf.dm_arm_nfe_terc  = 0 -- 0-não, 1-sim
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final)))
      and mf.id               = nf.modfiscal_id
      and mf.cod_mod         in ('21', '22')
      and nc.notafiscal_id    = nf.id
      and nc.planoconta_id   is null
      and cs.id               = nc.codst_id
      and cs.cod_st      not in ('70','71','72','73','74','75') -- valores isentos de créditos
      and it.notafiscal_id(+) = nf.id
      and ra.notafiscal_id    = nf.id
    order by nf.id;
   --
   -- Planos de Contas - Notas Fiscais de Mercadoria - PIS e/ou COFINS
   --
   cursor c_c170_pl( en_empresa_id        in empresa.id%type
                   , en_dm_dt_escr_dfepoe in empresa.dm_dt_escr_dfepoe%type ) is
   select 'C100/C170' reg_bloco
        , 'NOTA_FISCAL' obj_referencia
        , nf.id registro_id
        , ('Nota fiscal Mercadoria - Item da Nota Fiscal. Número NF: '||nf.nro_nf||', série: '||nf.serie||', data de emissão: '||nf.dt_emiss||', modelo fiscal: '||mf.cod_mod||'.') inform
        , nf.dm_ind_emit
        , nf.dm_ind_oper
        , nf.modfiscal_id
        , nf.pessoa_id
        , it.cfop_id
        , it.item_id
        , it.cod_ncm
        , it.cd_lista_serv
        , it.id itemnf_id
     from nota_fiscal      nf
        , mod_fiscal       mf
        , item_nota_fiscal it
    where nf.empresa_id      = en_empresa_id
      and nf.dm_st_proc     in (4,7,8) -- 4-Autorizada, 7-Cancelada, 8-Inutilizada
      and nf.dm_arm_nfe_terc = 0 -- 0-não, 1-sim
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final)))
      and mf.id       = nf.modfiscal_id
      and mf.cod_mod in ('01', '1B', '04', '55', '65')
      and it.notafiscal_id = nf.id
      and it.cod_cta is null
      and exists (select 1
                    from imp_itemnf imp
                       --, cod_st cst
                       , tipo_imposto ti
                   where imp.itemnf_id   = it.id
                     --and cst.id          = imp.codst_id
                     --and cst.cod_st not in ('70','71','72','73','74','75') -- valores isentos de créditos
                     and ti.id           = imp.tipoimp_id
                     and ti.cd          in (4,5))
    order by nf.id;
   --
   -- Planos de Contas - Notas Fiscais de Serviço - PIS e/ou COFINS
   --
   cursor c_a170_pl( en_empresa_id        in empresa.id%type
                   , en_dm_dt_escr_dfepoe in empresa.dm_dt_escr_dfepoe%type ) is
   select 'A100/A170' reg_bloco
        , 'NOTA_FISCAL' obj_referencia
        , nf.id registro_id
        , ('Nota fiscal de Serviço - Item da Nota Fiscal. Número NF: '||nf.nro_nf||', série: '||nf.serie||', data de emissão: '||nf.dt_emiss||', modelo fiscal: '||mf.cod_mod||'.') inform
        , nf.dm_ind_emit
        , nf.dm_ind_oper
        , nf.modfiscal_id
        , nf.pessoa_id
        , it.cfop_id
        , it.item_id
        , it.cod_ncm
        , it.cd_lista_serv
        , it.id itemnf_id
        , cs.cod_st
     from nota_fiscal       nf
        , mod_fiscal        mf
        , item_nota_fiscal  it
        , itemnf_compl_serv ic
        , imp_itemnf        im
        , cod_st            cs
        , tipo_imposto      ti
    where nf.empresa_id       = en_empresa_id
      and nf.dm_st_proc      in (4,7,8) -- 4-Autorizada, 7-Cancelada, 8-Inutilizada
      and nf.dm_arm_nfe_terc  = 0 -- 0-não, 1-sim
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final)))
      and mf.id            = nf.modfiscal_id
      and mf.cod_mod       in ('99', 'ND') -- Serviços / Nota de Débito
      --and mf.cod_mod       = '99' -- somente serviços
      and it.notafiscal_id = nf.id
      and it.cod_cta      is null
      and ic.itemnf_id     = it.id
      and im.itemnf_id     = it.id
      and im.dm_tipo       = 0 -- 0-imposto, 1-retenção
      and cs.id            = im.codst_id
      and ti.id            = im.tipoimp_id
      and ti.cd           in (4,5)
   order by nf.id;
   --
   -- Planos de Contas - Notas Fiscais de Venda a Consumidor - PIS e/ou COFINS
   --
   cursor c_c380_pl( en_empresa_id in empresa.id%type ) is
   select 'C380' reg_bloco
        , 'RES_DIA_NF_VENDA_CONS' obj_referencia
        , rd.id registro_id
        , ('Nota fiscal de Venda a Consumidor. Número inicial: '||rd.num_doc_ini||', número final: '||rd.num_doc_fin||', série: '||rd.serie||', subserie: '||
           rd.subserie||', data docto: '||rd.dt_doc||', modelo fiscal: '||mf.cod_mod||'.') inform
        , rd.modfiscal_id
        , ra.cfop_id
        , rd.id resdianfvendacons_id
     from res_dia_nf_venda_cons        rd
        , mod_fiscal                   mf
        , reg_an_res_dia_nf_venda_cons ra
    where rd.empresa_id           = en_empresa_id
      and trunc(rd.dt_doc)  between gt_row_valid_atual_param_pc.dt_ini and gt_row_valid_atual_param_pc.dt_final
      and rd.dm_st_proc           = 1 -- Validada
      and rd.cod_cta             is null
      and mf.id                   = rd.modfiscal_id
      and mf.cod_mod              = '02' -- Nota Fiscal de Venda a Consumidor
      and ra.resdianfvendacons_id = rd.id
    order by rd.id;
   --
   -- Planos de Contas - Equipamento/Redução Z - Resumo Diário de Documentos Emitidos por ECF – PIS
   --
   cursor c_c481_plpis( en_empresa_id in empresa.id%type ) is
   select distinct 'C400/C481' reg_bloco
        , 'REDUCAO_Z_ECF' obj_referencia
        , rz.id registro_id
        , ('Equipamento/Redução Z - Resumo Diário de Documentos Emitidos por ECF - Imposto PIS. Equipamento - Modelo: '||ee.ecf_mod||', fabricante: '||
           ee.ecf_fab||', caixa: '||ee.ecf_cx||', modelo fiscal: '||mf.cod_mod||', data docto: '||rz.dt_doc||', CRO: '||rz.cro||', CRZ: '||rz.crz||
           ', Nro Contador de ordem de Produção: '||rz.num_coo_fin||'.') inform
        , ee.modfiscal_id
        , ie.cfop_id
        , rp.item_id
        , rp.id resdiadocecfpis_id
     from equip_ecf              ee
        , mod_fiscal             mf
        , reducao_z_ecf          rz
        , doc_fiscal_emit_ecf    de
        , it_doc_fiscal_emit_ecf ie
        , res_dia_doc_ecf_pis    rp
    where ee.empresa_id          = en_empresa_id
      and mf.id                  = ee.modfiscal_id
      and mf.cod_mod            in ('02', '2D')  -- Nota Fiscal de Venda a Consumidor e Cupom Fiscal
      and rz.equipecf_id         = ee.id
      and trunc(rz.dt_doc) between gt_row_valid_atual_param_pc.dt_ini and gt_row_valid_atual_param_pc.dt_final
      and rz.dm_st_proc          = 1 -- Validada
      and nvl(rz.vl_brt,0)       > 0
      and de.reducaozecf_id      = rz.id
      and ie.docfiscalemitecf_id = de.id
      and rp.reducaozecf_id      = rz.id
      and rp.planoconta_id      is null
    order by rz.id;
   --
   -- Planos de Contas - Equipamento/Redução Z - Resumo Diário de Documentos Emitidos por ECF – COFINS
   --
   cursor c_c485_plcof( en_empresa_id in empresa.id%type ) is
   select distinct 'C400/C485' reg_bloco
        , 'REDUCAO_Z_ECF' obj_referencia
        , rz.id registro_id
        , ('Equipamento/Redução Z - Resumo Diário de Documentos Emitidos por ECF - Imposto COFINS. Equipamento - Modelo: '||ee.ecf_mod||', fabricante: '||
           ee.ecf_fab||', caixa: '||ee.ecf_cx||', modelo fiscal: '||mf.cod_mod||', data docto: '||rz.dt_doc||', CRO: '||rz.cro||', CRZ: '||rz.crz||
           ', Nro Contador de ordem de Produção: '||rz.num_coo_fin||'.') inform
        , ee.modfiscal_id
        , ie.cfop_id
        , rc.item_id
        , rc.id resdiadocecfcofins_id
     from equip_ecf              ee
        , mod_fiscal             mf
        , reducao_z_ecf          rz
        , doc_fiscal_emit_ecf    de
        , it_doc_fiscal_emit_ecf ie
        , res_dia_doc_ecf_cofins rc
    where ee.empresa_id          = en_empresa_id
      and mf.id                  = ee.modfiscal_id
      and mf.cod_mod            in ('02', '2D')  -- Nota Fiscal de Venda a Consumidor e Cupom Fiscal
      and rz.equipecf_id         = ee.id
      and trunc(rz.dt_doc) between gt_row_valid_atual_param_pc.dt_ini and gt_row_valid_atual_param_pc.dt_final
      and rz.dm_st_proc          = 1 -- Validada
      and nvl(rz.vl_brt,0)       > 0
      and de.reducaozecf_id      = rz.id
      and ie.docfiscalemitecf_id = de.id
      and rc.reducaozecf_id      = rz.id
      and rc.planoconta_id      is null
    order by rz.id;
   --
   -- Planos de Contas - Conhecimento de Transporte – PIS
   --
   cursor c_d101_plpis( en_empresa_id        in empresa.id%type
                      , en_dm_dt_escr_dfepoe in empresa.dm_dt_escr_dfepoe%type ) is
   select 'D100/D101' reg_bloco
        , 'CONHEC_TRANSP' obj_referencia
        , ct.id registro_id
        , ('Conhecimento de Transporte - Imposto PIS - Complemento de PIS. do Conhecimento: '||ct.nro_ct||', série: '||ct.serie||', subserie: '||ct.subserie||
           ', modelo fiscal: '||mf.cod_mod||', data emissão: '||ct.dt_hr_emissao||'.') inform
        , ct.dm_ind_emit
        , ct.dm_ind_oper
        , ct.modfiscal_id
        , ct.pessoa_id
        , ct.cfop_id
        , cp.id ctcompdocpis_id
        , cs.cod_st
     from conhec_transp   ct
        , mod_fiscal      mf
        , ct_comp_doc_pis cp
        , cod_st          cs
    where ct.empresa_id       = en_empresa_id
      and ct.dm_st_proc       = 4 -- autorizado
      and ct.dm_arm_cte_terc  = 0
      and ((ct.dm_ind_emit = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 1 and trunc(ct.dt_hr_emissao) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 0 and trunc(ct.dt_hr_emissao) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final)))
      and mf.id              = ct.modfiscal_id
      and mf.cod_mod        in ('07', '08', '8B', '09', '10', '11', '26', '27', '57')
      and cp.conhectransp_id = ct.id
      and cp.planoconta_id  is null
      and cs.id              = cp.codst_id
      and cs.cod_st     not in ('70','71','72','73','74','75') -- valores isentos de créditos
    order by ct.id;
   --
   -- Planos de Contas - Conhecimento de Transporte – COFINS
   --
   cursor c_d105_plcof( en_empresa_id        in empresa.id%type
                      , en_dm_dt_escr_dfepoe in empresa.dm_dt_escr_dfepoe%type ) is
   select 'D100/D105' reg_bloco
        , 'CONHEC_TRANSP' obj_referencia
        , ct.id registro_id
        , ('Conhecimento de Transporte - Imposto COFINS - Complemento de COFINS. do Conhecimento: '||ct.nro_ct||', série: '||ct.serie||', subserie: '||
           ct.subserie||', modelo fiscal: '||mf.cod_mod||', data emissão: '||ct.dt_hr_emissao||'.') inform
        , ct.dm_ind_emit
        , ct.dm_ind_oper
        , ct.modfiscal_id
        , ct.pessoa_id
        , ct.cfop_id
        , cc.id ctcompdoccofins_id
        , co.cod_st
     from conhec_transp      ct
        , mod_fiscal         mf
        , ct_comp_doc_cofins cc
        , cod_st             co
    where ct.empresa_id      = en_empresa_id
      and ct.dm_st_proc      = 4 -- autorizado
      and ct.dm_arm_cte_terc = 0
      and ((ct.dm_ind_emit = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 1 and trunc(ct.dt_hr_emissao) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 0 and trunc(ct.dt_hr_emissao) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final))
            or
           (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_valid_atual_param_pc.dt_ini) and trunc(gt_row_valid_atual_param_pc.dt_final)))
      and mf.id              = ct.modfiscal_id
      and mf.cod_mod        in ('07', '08', '8B', '09', '10', '11', '26', '27', '57')
      and cc.conhectransp_id = ct.id
      and cc.planoconta_id  is null
      and co.id              = cc.codst_id
      and co.cod_st     not in ('70','71','72','73','74','75') -- valores isentos de créditos
    order by ct.id;
   --
   -- Planos de Contas - I100/I200 - Composição das receitas, deduções e/ou exclusões do período. Não temos parâmetros para essa atualização - Utilizar a tela/portal para correção.
   -- Planos de Contas - I100/I300 - Complemento das operações - Detalhamento das receitas, deduções e/ou exclusões do período. Não temos parâmetros para essa atualização - Utilizar a tela/portal para correção.
   --
   -- Planos de Contas - Controle de Créditos Fiscais de PIS - Apuração de Crédito Extemporâneo
   --
   cursor c_1101_plpis(en_empresa_id in empresa.id%type) is
   select '1100/1101' reg_bloco
        , 'CONTR_CRED_FISCAL_PIS' obj_referencia
        , cc.id registro_id
        , ('Controle de Créditos Fiscais de PIS - Apuração de Crédito Extemporâneo. Mês/Ano: '||lpad(cc.mes,2,'0')||'/'||lpad(cc.ano,4,'0')||', Código do '||
          'Tipo de Crédito: '||tc.cd||'-'||tc.descr||', Data da Operação: '||to_char(ac.dt_oper,'dd/mm/rrrr')||', CFOP: '||cf.cd||'-'||cf.descr||'.') inform
        , ac.cfop_id
        , ac.id apurcredextpis_id
     from contr_cred_fiscal_pis cc
        , apur_cred_ext_pis     ac
        , tipo_cred_pc          tc
        , cfop                  cf
    where cc.empresa_id           = en_empresa_id
      and cc.dm_situacao          = 3 -- processada
      and to_date((cc.mes||'/'||cc.ano),'mm/rrrr') between gt_row_valid_atual_param_pc.dt_ini and gt_row_valid_atual_param_pc.dt_final
      and ac.contrcredfiscalpis_id = cc.id
      and ac.planoconta_id        is null
      and tc.id                    = cc.tipocredpc_id
      and cf.id                    = ac.cfop_id
    order by cc.id;
   --
   -- Planos de Contas - Controle de Créditos Fiscais de COFINS - Apuração de Crédito Extemporâneo
   --
   cursor c_1501_plcof(en_empresa_id in empresa.id%type) is
   select '1500/1501' reg_bloco
        , 'CONTR_CRED_FISCAL_COFINS' obj_referencia
        , cc.id registro_id
        , ('Controle de Créditos Fiscais de COFINS - Apuração de Crédito Extemporâneo. Mês/Ano: '||
          lpad(cc.mes,2,'0')||'/'||lpad(cc.ano,4,'0')||', Código do Tipo de Crédito: '||tc.cd||'-'||tc.descr||', data da operação: '||
          to_char(ac.dt_oper,'dd/mm/rrrr')||', CFOP: '||cf.cd||'-'||cf.descr||'.') inform
        , ac.cfop_id
        , ac.id apurcredextcofins_id
     from contr_cred_fiscal_cofins cc
        , apur_cred_ext_cofins     ac
        , tipo_cred_pc             tc
        , cfop                     cf
    where cc.empresa_id               = en_empresa_id
      and cc.dm_situacao              = 3 -- processada
      and to_date((cc.mes||'/'||cc.ano),'mm/rrrr') between gt_row_valid_atual_param_pc.dt_ini and gt_row_valid_atual_param_pc.dt_final
      and ac.contrcredfiscalcofins_id = cc.id
      and ac.planoconta_id           is null
      and tc.id                       = cc.tipocredpc_id
      and cf.id                       = ac.cfop_id
    order by cc.id;
   --
   -- Planos de Contas - Demais Documentos e Operações Geradoras de Contribuição e Créditos - F100 - PIS e/ou COFINS
   --
   cursor c_f100_ct(en_empresa_id in empresa.id%type) is
   select 'F100' reg_bloco
        , 'DEM_DOC_OPER_GER_CC' obj_referencia
        , dd.id registro_id
        , ('Demais Documentos e Operações Geradoras de Contribuição e Créditos - F100. Data da Operação: '||dd.dt_oper||', Valor da Operação: '||
           trim(to_char(dd.vl_oper,'999G999G999G990D00'))||'.') inform
        , dd.pessoa_id
        , dd.item_id
        , dd.id demdocopergercc_id
     from dem_doc_oper_ger_cc dd
    where dd.empresa_id      = en_empresa_id
      and trunc(dd.dt_oper)  between gt_row_valid_atual_param_pc.dt_ini and gt_row_valid_atual_param_pc.dt_final
      and dd.dm_st_proc      = 1 -- validado
      and dd.planoconta_id   is null
    order by dd.id;
   --
   -- Planos de Contas - Bens do Ativo Imobilizado operações gerados de crédito PIS/COFINS - Depreciação/Amortização - F120. Não temos parâmetros para essa atualização - Utilizar a tela/portal para correção.
   -- Planos de Contas - Bens do Ativo Imobilizado operações gerados de crédito Pis/Cofins - Aquisição/Contribuição - F130. Não temos parâmetros para essa atualização - Utilizar a tela/portal para correção.
   -- Planos de Contas - Crédito Presumido sobre Estoque de Abertura - F150. Não temos parâmetros para essa atualização - Utilizar a tela/portal para correção.
   --
   -- Planos de Contas - Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência do PIS/COFINS
   -- pelo regime de caixa - F500 - PIS e/ou COFINS
   --
   cursor c_f500_pl(en_empresa_id in empresa.id%type) is
   select 'F500' reg_bloco
        , 'CONS_OPER_INS_PC_RC' obj_referencia
        , co.id registro_id
        , ('Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência do PIS/COFINS pelo '||
           'regime de caixa - F500. Data de Referência: '||to_char(co.dt_ref,'dd/mm/rrrr')||'.') inform
        , co.modfiscal_id
        , co.cfop_id
        , co.id consoperinspcrc_id
     from cons_oper_ins_pc_rc co
    where co.empresa_id      = en_empresa_id
      and co.dt_ref    between gt_row_valid_atual_param_pc.dt_ini and gt_row_valid_atual_param_pc.dt_final
      and co.dm_st_proc      = 1 -- validado
      and co.planoconta_id  is null
    order by co.id;
   --
   -- Planos de Contas - Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência do
   -- PIS/COFINS pelo regime de caixa (Apuração da contribuição por unidade de medida de produto, alíquota em reais) - F510 - PIS e/ou COFINS
   --
   cursor c_f510_pl(en_empresa_id in empresa.id%type) is
   select 'F510' reg_bloco
        , 'CONS_OPER_INS_PC_RC_AUM' obj_referencia
        , co.id registro_id
        , ('Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência do PIS/COFINS pelo '||
           'regime de caixa (Apuração da contribuição por unidade de medida de produto, alíquota em reais) - F510. Data de Referência: '||
           to_char(co.dt_ref,'dd/mm/rrrr')||'.') inform
        , co.modfiscal_id
        , co.cfop_id
        , co.id consoperinspcrcaum_id
     from cons_oper_ins_pc_rc_aum co
    where co.empresa_id      = en_empresa_id
      and co.dt_ref    between gt_row_valid_atual_param_pc.dt_ini and gt_row_valid_atual_param_pc.dt_final
      and co.dm_st_proc      = 1 -- validado
      and co.planoconta_id  is null
    order by co.id;
   --
   -- Planos de Contas - Composição da Receita Escriturada no período - Detalhamento da Receita Recebida pelo Regime de Caixa - F525 - PIS e/ou COFINS
   --
   cursor c_f525_pl(en_empresa_id in empresa.id%type) is
   select 'F525' reg_bloco
        , 'COMP_REC_DET_RC' obj_referencia
        , cr.id registro_id
        , ('Composição da Receita Escriturada no período - Detalhamento da Receita Recebida pelo Regime de Caixa - F525. Data de Referência: '||
           to_char(cr.dt_ref,'dd/mm/rrrr')||'.') inform
        , cr.pessoa_id
        , cr.item_id
        , cr.id comprecdetrc_id
     from comp_rec_det_rc cr
    where cr.empresa_id     = en_empresa_id
      and cr.dt_ref   between gt_row_valid_atual_param_pc.dt_ini and gt_row_valid_atual_param_pc.dt_final
      and cr.dm_st_proc     = 1 -- validado
      and cr.planoconta_id is null
    order by cr.id;
   --
   -- Planos de Contas - Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência do PIS/COFINS 
   -- pelo regime de Competência - F550 - PIS e/ou COFINS
   --
   cursor c_f550_pl(en_empresa_id in empresa.id%type) is
   select 'F550' reg_bloco
        , 'CONS_OPER_INS_PC_RCOMP' obj_referencia
        , co.id registro_id
        , ('Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência do PIS/COFINS pelo '||
           'regime de Competência - F550. Data de Referência: '||to_char(co.dt_ref,'dd/mm/rrrr')||'.') inform
        , co.modfiscal_id
        , co.cfop_id
        , co.id consoperinspcrcomp_id
     from cons_oper_ins_pc_rcomp co
    where co.empresa_id     = en_empresa_id
      and co.dt_ref   between gt_row_valid_atual_param_pc.dt_ini and gt_row_valid_atual_param_pc.dt_final
      and co.dm_st_proc     = 1 -- validado
      and co.planoconta_id is null
    order by co.id;
   --
   -- Planos de Contas - Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência do PIS/COFINS 
   -- pelo regime de competência (Apuração da contribuição por unidade de medida de produto, alíquota em reais) - F560 - PIS e/ou COFINS
   --
   cursor c_f560_pl(en_empresa_id in empresa.id%type) is
   select 'F560' reg_bloco
        , 'CONS_OPER_INS_PC_RC_AUM' obj_referencia
        , co.id registro_id
        , ('Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência do PIS/COFINS pelo '||
           'regime de competência (Apuração da contribuição por unidade de medida de produto, alíquota em reais) - F560. Data de Referência: '||
           to_char(co.dt_ref,'dd/mm/rrrr')||'.') inform
        , co.modfiscal_id
        , co.cfop_id
        , co.id consopinspcrcompaum_id
     from cons_op_ins_pcrcomp_aum co
    where co.empresa_id     = en_empresa_id
      and co.dt_ref   between gt_row_valid_atual_param_pc.dt_ini and gt_row_valid_atual_param_pc.dt_final
      and co.dm_st_proc     = 1 -- validado
      and co.planoconta_id is null
    order by co.id;
   --
   -- Planos de Contas - Cupom Fiscal SAT
   -- THIAGO alterou AQUI --69583
   cursor c_c870_pl(en_empresa_id in empresa.id%type) is
   select 'C860/C870' reg_bloco
        , 'CUPOM_FISCAL' obj_referencia
        , cf.id registro_id
        , ('Cupom Fiscal SAT - Item do Cupom Fiscal. Número CF: '||cf.nro_cfe||', série: '||cf.nro_serie_sat||', data de emissão: '||cf.dt_emissao||', modelo fiscal: '||mf.cod_mod||', número item: '||it.nro_item||'.') inform
        , cf.modfiscal_id
        , it.cfop_id
        , it.item_id
        , it.ncm_id
        , it.cd_lista_serv
        , it.id itemcf_id
     from cupom_fiscal       cf
        , mod_fiscal         mf
        , item_cupom_fiscal  it
    where cf.id         = it.cupomfiscal_id
      and cf.empresa_id = en_empresa_id
      and cf.dt_emissao between gt_row_valid_atual_param_pc.dt_ini and gt_row_valid_atual_param_pc.dt_final
      and cf.dm_st_proc in (4) -- 4-Autorizado
      and mf.id         = cf.modfiscal_id
      and mf.cod_mod    = '59' -- Cupom Fiscal Eletrônico
      and it.cod_cta is null
      and exists (select 1
                    from imp_itemcf imp
                       , tipo_imposto ti
                   where imp.itemcupomfiscal_id   = it.id
                     and ti.id           = imp.tipoimp_id
                     and ti.cd          in (4,5))
    order by cf.id;
   --THIAGO FINALIZOU AQUI --69583
BEGIN
   --
   vn_fase := 1;
   -- Empresa solicitada e suas filiais - consolidando
   for r_empresa in c_empresa
   loop
      --
      exit when c_empresa%notfound or (c_empresa%notfound);
      --
      vn_fase := 2;
      vn_qtde := 0;
      --
      -- Planos de Contas - Notas Fiscais de Serviço Contínuo - PIS
      for r_c501_plano in c_c501_plpis( en_empresa_id        => r_empresa.empresa_id
                                      , en_dm_dt_escr_dfepoe => r_empresa.dm_dt_escr_dfepoe )
      loop
         --
         exit when c_c501_plpis%notfound or (c_c501_plpis%notfound);
         --
         vn_fase := 2.1;
         --
         vn_qtde := nvl(vn_qtde,0) + 1;
         vn_ncm_id := pk_csf.fkg_ncm_id(ev_cod_ncm => r_c501_plano.cod_ncm);
         vn_tpservico_id := pk_csf.fkg_tipo_servico_id(ev_cod_lst => r_c501_plano.cd_lista_serv);
         --
         vn_fase := 2.2;
         -- Função para retornar o plano de conta para PIS
         vn_planoconta_id_pis := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                     , en_dm_ind_emit  => r_c501_plano.dm_ind_emit
                                                                     , en_dm_ind_oper  => r_c501_plano.dm_ind_oper
                                                                     , en_modfiscal_id => r_c501_plano.modfiscal_id
                                                                     , en_pessoa_id    => r_c501_plano.pessoa_id
                                                                     , en_cfop_id      => r_c501_plano.cfop_id
                                                                     , en_item_id      => r_c501_plano.item_id
                                                                     , en_ncm_id       => vn_ncm_id
                                                                     , en_tpservico_id => vn_tpservico_id
                                                                     , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                     , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                     , en_cod_st_piscofins => r_c501_plano.cod_st   
                                                                     , ev_ret          => 'PCTA_PIS' );
         --
         vn_fase := 2.3;
         --
         if nvl(vn_planoconta_id_pis,0) <> 0 then
            --
            vn_fase := 2.4;
            --
            begin
               update nf_compl_oper_pis nc
                  set nc.planoconta_id = vn_planoconta_id_pis
                where nc.id = r_c501_plano.nfcomploperpis_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Complemento da Nota Fiscal de Serviço Contínuo - Plano de Conta - PIS. Identificador do Complemento = '||
                                   r_c501_plano.nfcomploperpis_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 2.5;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_c501_plano.reg_bloco -- reg_bloco
                                                     , r_c501_plano.obj_referencia -- obj_referencia
                                                     , r_c501_plano.registro_id -- registro_id / nfcomploperpis_id
                                                     , r_c501_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_pis)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Complemento da Nota Fiscal de Serviço Contínuo - Plano de Conta - PIS. '||
                                   'Identificador do complemento = '||r_c501_plano.nfcomploperpis_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 2.6;
            --
            commit;
            --
         else -- nvl(vn_planoconta_id_pis,0) = 0
            --
            vn_fase := 2.7;
            --
            vv_resumo_log := 'Não foi encontrado Plano de Conta - PIS. '||r_c501_plano.inform||' Parâmetros utilizados: '||
                             'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||
                             '), Indicador de emitente = '||pk_csf.fkg_dominio(ev_dominio => 'NOTA_FISCAL.DM_IND_EMIT', ev_vl => r_c501_plano.dm_ind_emit)||
                             ' (en_dm_ind_emit = '||r_c501_plano.dm_ind_emit||', Indicador da Operação = '||pk_csf.fkg_dominio(ev_dominio =>
                             'NOTA_FISCAL.DM_IND_OPER', ev_vl => r_c501_plano.dm_ind_oper)||' (en_dm_ind_oper = '||r_c501_plano.dm_ind_oper||
                             '), Modelo Fiscal = '||pk_csf.fkg_cod_mod_id(en_modfiscal_id => r_c501_plano.modfiscal_id)||' (en_modfiscal_id = '||
                             r_c501_plano.modfiscal_id||'), Participante = '||pk_csf.fkg_pessoa_cod_part(en_pessoa_id => r_c501_plano.pessoa_id)||'-'||
                             pk_csf.fkg_nome_pessoa_id(en_pessoa_id => r_c501_plano.pessoa_id)||' (en_pessoa_id = '||r_c501_plano.pessoa_id||'), CFOP = '||
                             pk_csf.fkg_cfop_cd(en_cfop_id => r_c501_plano.cfop_id)||' (en_cfop_id = '||r_c501_plano.cfop_id||'), Item = '||
                             pk_csf.fkg_item_cod(en_item_id => r_c501_plano.item_id)||' (en_item_id = '||r_c501_plano.item_id||'), NCM = '||r_c501_plano.cod_ncm||
                             ', Código da Lista de Serviço = '||r_c501_plano.cd_lista_serv||', Data Inicial = '||gt_row_valid_atual_param_pc.dt_ini||
                             ', Data Final = '||gt_row_valid_atual_param_pc.dt_final||'. Identificador do complemento de PIS (ID) = '||r_c501_plano.nfcomploperpis_id||'.';
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                             , ev_mensagem       => gv_mensagem_log
                                             , ev_resumo         => vv_resumo_log
                                             , en_tipo_log       => erro_inform_geral
                                             , en_referencia_id  => gn_referencia_id
                                             , ev_obj_referencia => gv_obj_referencia
                                             , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            --
         end if;
         --
      end loop; -- Planos de Contas - Notas Fiscais de Serviço Contínuo - PIS
      --
      vn_fase := 2.8;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Notas Fiscais de Serviço Contínuo - Complemento de PIS - Plano de Contas = '||vn_qtde||
                       '. Essa quantidade não indica que todos os registros foram atualizados, para isso, verifique os logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
      vn_fase := 3;
      vn_qtde := 0;
      --
      -- Planos de Contas - Notas Fiscais de Serviço Contínuo - COFINS
      for r_c505_plano in c_c505_plcof( en_empresa_id        => r_empresa.empresa_id
                                      , en_dm_dt_escr_dfepoe => r_empresa.dm_dt_escr_dfepoe )
      loop
         --
         exit when c_c505_plcof%notfound or (c_c505_plcof%notfound);
         --
         vn_fase := 3.1;
         --
         vn_qtde := nvl(vn_qtde,0) + 1;
         vn_ncm_id := pk_csf.fkg_ncm_id(ev_cod_ncm => r_c505_plano.cod_ncm);
         vn_tpservico_id := pk_csf.fkg_tipo_servico_id(ev_cod_lst => r_c505_plano.cd_lista_serv);
         --
         vn_fase := 3.2;
         -- Função para retornar o plano de conta para COFINS
         vn_planoconta_id_cofins := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                        , en_dm_ind_emit  => r_c505_plano.dm_ind_emit
                                                                        , en_dm_ind_oper  => r_c505_plano.dm_ind_oper
                                                                        , en_modfiscal_id => r_c505_plano.modfiscal_id
                                                                        , en_pessoa_id    => r_c505_plano.pessoa_id
                                                                        , en_cfop_id      => r_c505_plano.cfop_id
                                                                        , en_item_id      => r_c505_plano.item_id
                                                                        , en_ncm_id       => vn_ncm_id
                                                                        , en_tpservico_id => vn_tpservico_id
                                                                        , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                        , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                        , en_cod_st_piscofins => r_c505_plano.cod_st  
                                                                        , ev_ret          => 'PCTA_COF' );
         --
         vn_fase := 3.3;
         --
         if nvl(vn_planoconta_id_cofins,0) <> 0 then
            --
            vn_fase := 3.4;
            --
            begin
               update nf_compl_oper_cofins nc
                  set nc.planoconta_id = vn_planoconta_id_cofins
                where nc.id = r_c505_plano.nfcomplopercofins_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Complemento da Nota Fiscal de Serviço Contínuo - Plano de Conta - COFINS. Identificador do '||
                                   'Complemento = '||r_c505_plano.nfcomplopercofins_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 3.5;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_c505_plano.reg_bloco -- reg_bloco
                                                     , r_c505_plano.obj_referencia -- obj_referencia
                                                     , r_c505_plano.registro_id -- registro_id / nfcomplopercofins_id
                                                     , r_c505_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_cofins)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Complemento da Nota Fiscal de Serviço Contínuo - Plano de Conta - COFINS. '||
                                   'Identificador do complemento = '||r_c505_plano.nfcomplopercofins_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 3.6;
            --
            commit;
            --
         else -- nvl(vn_planoconta_id_cofins,0) = 0
            --
            vn_fase := 3.7;
            --
            vv_resumo_log := 'Não foi encontrado Plano de Conta - COFINS. '||r_c505_plano.inform||' Parâmetros utilizados: '||
                             'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||
                             '), Indicador de emitente = '||pk_csf.fkg_dominio(ev_dominio => 'NOTA_FISCAL.DM_IND_EMIT', ev_vl => r_c505_plano.dm_ind_emit)||
                             ' (en_dm_ind_emit = '||r_c505_plano.dm_ind_emit||', Indicador da Operação = '||pk_csf.fkg_dominio(ev_dominio =>
                             'NOTA_FISCAL.DM_IND_OPER', ev_vl => r_c505_plano.dm_ind_oper)||' (en_dm_ind_oper = '||r_c505_plano.dm_ind_oper||
                             '), Modelo Fiscal = '||pk_csf.fkg_cod_mod_id(en_modfiscal_id => r_c505_plano.modfiscal_id)||' (en_modfiscal_id = '||
                             r_c505_plano.modfiscal_id||'), Participante = '||pk_csf.fkg_pessoa_cod_part(en_pessoa_id => r_c505_plano.pessoa_id)||'-'||
                             pk_csf.fkg_nome_pessoa_id(en_pessoa_id => r_c505_plano.pessoa_id)||' (en_pessoa_id = '||r_c505_plano.pessoa_id||'), CFOP = '||
                             pk_csf.fkg_cfop_cd(en_cfop_id => r_c505_plano.cfop_id)||' (en_cfop_id = '||r_c505_plano.cfop_id||'), Item = '||
                             pk_csf.fkg_item_cod(en_item_id => r_c505_plano.item_id)||' (en_item_id = '||r_c505_plano.item_id||'), NCM = '||r_c505_plano.cod_ncm||
                             ', Código da Lista de Serviço = '||r_c505_plano.cd_lista_serv||', Data Inicial = '||gt_row_valid_atual_param_pc.dt_ini||
                             ', Data Final = '||gt_row_valid_atual_param_pc.dt_final||'. Identificador do complemento de COFINS (ID) = '||
                             r_c505_plano.nfcomplopercofins_id||'.';
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                             , ev_mensagem       => gv_mensagem_log
                                             , ev_resumo         => vv_resumo_log
                                             , en_tipo_log       => erro_inform_geral
                                             , en_referencia_id  => gn_referencia_id
                                             , ev_obj_referencia => gv_obj_referencia
                                             , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            --
         end if;
         --
      end loop; -- Planos de Contas - Notas Fiscais de Serviço Contínuo - COFINS
      --
      vn_fase := 3.8;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Notas Fiscais de Serviço Contínuo - Complemento de COFINS - Plano de Contas = '||vn_qtde||
                       '. Essa quantidade não indica que todos os registros foram atualizados, para isso, verifique os logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
      vn_fase := 4;
      vn_qtde := 0;
      --
      -- Planos de Contas - Notas Fiscais de Serviço de Transporte e Comunicação - PIS
      for r_d501_plano in c_d501_plpis( en_empresa_id        => r_empresa.empresa_id
                                      , en_dm_dt_escr_dfepoe => r_empresa.dm_dt_escr_dfepoe )
      loop
         --
         exit when c_d501_plpis%notfound or (c_d501_plpis%notfound);
         --
         vn_fase := 4.1;
         --
         vn_qtde := nvl(vn_qtde,0) + 1;
         vn_ncm_id := pk_csf.fkg_ncm_id(ev_cod_ncm => r_d501_plano.cod_ncm);
         vn_tpservico_id := pk_csf.fkg_tipo_servico_id(ev_cod_lst => r_d501_plano.cd_lista_serv);
         --
         vn_fase := 4.2;
         -- Função para retornar o plano de conta para PIS
         vn_planoconta_id_pis := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                     , en_dm_ind_emit  => r_d501_plano.dm_ind_emit
                                                                     , en_dm_ind_oper  => r_d501_plano.dm_ind_oper
                                                                     , en_modfiscal_id => r_d501_plano.modfiscal_id
                                                                     , en_pessoa_id    => r_d501_plano.pessoa_id
                                                                     , en_cfop_id      => r_d501_plano.cfop_id
                                                                     , en_item_id      => r_d501_plano.item_id
                                                                     , en_ncm_id       => vn_ncm_id
                                                                     , en_tpservico_id => vn_tpservico_id
                                                                     , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                     , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                     , en_cod_st_piscofins => r_d501_plano.cod_st     
                                                                     , ev_ret          => 'PCTA_PIS' );
         --
         vn_fase := 4.3;
         --
         if nvl(vn_planoconta_id_pis,0) <> 0 then
            --
            vn_fase := 4.4;
            --
            begin
               update nf_compl_oper_pis nc
                  set nc.planoconta_id = vn_planoconta_id_pis
                where nc.id = r_d501_plano.nfcomploperpis_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Complemento da Nota Fiscal de Serviço de Transporte e Comunicação - Plano de Conta - PIS. '||
                                   'Identificador do Complemento = '||r_d501_plano.nfcomploperpis_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 4.5;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_d501_plano.reg_bloco -- reg_bloco
                                                     , r_d501_plano.obj_referencia -- obj_referencia
                                                     , r_d501_plano.registro_id -- registro_id / nfcomploperpis_id
                                                     , r_d501_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_pis)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Complemento da Nota Fiscal de Serviço de Transporte e Comunicação - Plano de '||
                                   'Conta - PIS. Identificador do complemento = '||r_d501_plano.nfcomploperpis_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 4.6;
            --
            commit;
            --
         else -- nvl(vn_planoconta_id_pis,0) = 0
            --
            vn_fase := 4.7;
            --
            vv_resumo_log := 'Não foi encontrado Plano de Conta - PIS. '||r_d501_plano.inform||' Parâmetros utilizados: '||
                             'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||
                             '), Indicador de emitente = '||pk_csf.fkg_dominio(ev_dominio => 'NOTA_FISCAL.DM_IND_EMIT', ev_vl => r_d501_plano.dm_ind_emit)||
                             ' (en_dm_ind_emit = '||r_d501_plano.dm_ind_emit||', Indicador da Operação = '||pk_csf.fkg_dominio(ev_dominio =>
                             'NOTA_FISCAL.DM_IND_OPER', ev_vl => r_d501_plano.dm_ind_oper)||' (en_dm_ind_oper = '||r_d501_plano.dm_ind_oper||
                             '), Modelo Fiscal = '||pk_csf.fkg_cod_mod_id(en_modfiscal_id => r_d501_plano.modfiscal_id)||' (en_modfiscal_id = '||
                             r_d501_plano.modfiscal_id||'), Participante = '||pk_csf.fkg_pessoa_cod_part(en_pessoa_id => r_d501_plano.pessoa_id)||'-'||
                             pk_csf.fkg_nome_pessoa_id(en_pessoa_id => r_d501_plano.pessoa_id)||' (en_pessoa_id = '||r_d501_plano.pessoa_id||'), CFOP = '||
                             pk_csf.fkg_cfop_cd(en_cfop_id => r_d501_plano.cfop_id)||' (en_cfop_id = '||r_d501_plano.cfop_id||'), Item = '||
                             pk_csf.fkg_item_cod(en_item_id => r_d501_plano.item_id)||' (en_item_id = '||r_d501_plano.item_id||'), NCM = '||r_d501_plano.cod_ncm||
                             ', Código da Lista de Serviço = '||r_d501_plano.cd_lista_serv||', Data Inicial = '||gt_row_valid_atual_param_pc.dt_ini||
                             ', Data Final = '||gt_row_valid_atual_param_pc.dt_final||'. Identificador do complemento de PIS (ID) = '||r_d501_plano.nfcomploperpis_id||'.';
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                             , ev_mensagem       => gv_mensagem_log
                                             , ev_resumo         => vv_resumo_log
                                             , en_tipo_log       => erro_inform_geral
                                             , en_referencia_id  => gn_referencia_id
                                             , ev_obj_referencia => gv_obj_referencia
                                             , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            --
         end if;
         --
      end loop; -- Planos de Contas - Notas Fiscais de Serviço Contínuo - PIS
      --
      vn_fase := 4.8;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Notas Fiscais de Serviço de Transporte e Comunicação - Complemento de PIS - Plano de Contas = '||vn_qtde||
                       '. Essa quantidade não indica que todos os registros foram atualizados, para isso, verifique os logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
      vn_fase := 5;
      vn_qtde := 0;
      --
      -- Planos de Contas - Notas Fiscais de Serviço de Transporte e Comunicação - COFINS
      for r_d505_plano in c_d505_plcof( en_empresa_id        => r_empresa.empresa_id
                                      , en_dm_dt_escr_dfepoe => r_empresa.dm_dt_escr_dfepoe )
      loop
         --
         exit when c_d505_plcof%notfound or (c_d505_plcof%notfound);
         --
         vn_fase := 5.1;
         --
         vn_qtde := nvl(vn_qtde,0) + 1;
         vn_ncm_id := pk_csf.fkg_ncm_id(ev_cod_ncm => r_d505_plano.cod_ncm);
         vn_tpservico_id := pk_csf.fkg_tipo_servico_id(ev_cod_lst => r_d505_plano.cd_lista_serv);
         --
         vn_fase := 5.2;
         -- Função para retornar o plano de conta para COFINS
         vn_planoconta_id_cofins := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                        , en_dm_ind_emit  => r_d505_plano.dm_ind_emit
                                                                        , en_dm_ind_oper  => r_d505_plano.dm_ind_oper
                                                                        , en_modfiscal_id => r_d505_plano.modfiscal_id
                                                                        , en_pessoa_id    => r_d505_plano.pessoa_id
                                                                        , en_cfop_id      => r_d505_plano.cfop_id
                                                                        , en_item_id      => r_d505_plano.item_id
                                                                        , en_ncm_id       => vn_ncm_id
                                                                        , en_tpservico_id => vn_tpservico_id
                                                                        , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                        , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                        , en_cod_st_piscofins => r_d505_plano.cod_st 
                                                                        , ev_ret          => 'PCTA_COF' );
         --
         vn_fase := 5.3;
         --
         if nvl(vn_planoconta_id_cofins,0) <> 0 then
            --
            vn_fase := 5.4;
            --
            begin
               update nf_compl_oper_cofins nc
                  set nc.planoconta_id = vn_planoconta_id_cofins
                where nc.id = r_d505_plano.nfcomplopercofins_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Complemento da Nota Fiscal de Serviço de Transporte e Comunicação - Plano de Conta - COFINS. '||
                                   'Identificador do Complemento = '||r_d505_plano.nfcomplopercofins_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 5.5;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_d505_plano.reg_bloco -- reg_bloco
                                                     , r_d505_plano.obj_referencia -- obj_referencia
                                                     , r_d505_plano.registro_id -- registro_id / nfcomplopercofins_id
                                                     , r_d505_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_cofins)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Complemento da Nota Fiscal de Serviço de Transporte e Comunicação - Plano de '||
                                   'Conta - COFINS. Identificador do complemento = '||r_d505_plano.nfcomplopercofins_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 5.6;
            --
            commit;
            --
         else -- nvl(vn_planoconta_id_cofins,0) = 0
            --
            vn_fase := 5.7;
            --
            vv_resumo_log := 'Não foi encontrado Plano de Conta - COFINS. '||r_d505_plano.inform||' Parâmetros utilizados: '||
                             'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||
                             '), Indicador de emitente = '||pk_csf.fkg_dominio(ev_dominio => 'NOTA_FISCAL.DM_IND_EMIT', ev_vl => r_d505_plano.dm_ind_emit)||
                             ' (en_dm_ind_emit = '||r_d505_plano.dm_ind_emit||', Indicador da Operação = '||pk_csf.fkg_dominio(ev_dominio =>
                             'NOTA_FISCAL.DM_IND_OPER', ev_vl => r_d505_plano.dm_ind_oper)||' (en_dm_ind_oper = '||r_d505_plano.dm_ind_oper||
                             '), Modelo Fiscal = '||pk_csf.fkg_cod_mod_id(en_modfiscal_id => r_d505_plano.modfiscal_id)||' (en_modfiscal_id = '||
                             r_d505_plano.modfiscal_id||'), Participante = '||pk_csf.fkg_pessoa_cod_part(en_pessoa_id => r_d505_plano.pessoa_id)||'-'||
                             pk_csf.fkg_nome_pessoa_id(en_pessoa_id => r_d505_plano.pessoa_id)||' (en_pessoa_id = '||r_d505_plano.pessoa_id||'), CFOP = '||
                             pk_csf.fkg_cfop_cd(en_cfop_id => r_d505_plano.cfop_id)||' (en_cfop_id = '||r_d505_plano.cfop_id||'), Item = '||
                             pk_csf.fkg_item_cod(en_item_id => r_d505_plano.item_id)||' (en_item_id = '||r_d505_plano.item_id||'), NCM = '||r_d505_plano.cod_ncm||
                             ', Código da Lista de Serviço = '||r_d505_plano.cd_lista_serv||', Data Inicial = '||gt_row_valid_atual_param_pc.dt_ini||
                             ', Data Final = '||gt_row_valid_atual_param_pc.dt_final||'. Identificador do complemento de COFINS (ID) = '||
                             r_d505_plano.nfcomplopercofins_id||'.';
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                             , ev_mensagem       => gv_mensagem_log
                                             , ev_resumo         => vv_resumo_log
                                             , en_tipo_log       => erro_inform_geral
                                             , en_referencia_id  => gn_referencia_id
                                             , ev_obj_referencia => gv_obj_referencia
                                             , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            --
         end if;
         --
      end loop; -- Planos de Contas - Notas Fiscais de Serviço Contínuo - COFINS
      --
      vn_fase := 5.8;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Notas Fiscais de Serviço de Transporte e Comunicação - Complemento de COFINS - Plano de Contas = '||vn_qtde||
                       '. Essa quantidade não indica que todos os registros foram atualizados, para isso, verifique os logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
      vn_fase := 6;
      vn_qtde := 0;
      --
      -- Planos de Contas - Notas Fiscais de Mercadorias - PIS e/ou COFINS
      for r_c170_plano in c_c170_pl( en_empresa_id        => r_empresa.empresa_id
                                   , en_dm_dt_escr_dfepoe => r_empresa.dm_dt_escr_dfepoe )
      loop
         --
         exit when c_c170_pl%notfound or (c_c170_pl%notfound);
         --
         vn_fase := 6.1;
         --
         vn_qtde := nvl(vn_qtde,0) + 1;
         vn_ncm_id := pk_csf.fkg_ncm_id(ev_cod_ncm => r_c170_plano.cod_ncm);
         vn_tpservico_id := pk_csf.fkg_tipo_servico_id(ev_cod_lst => r_c170_plano.cd_lista_serv);
         --
         vn_fase := 6.2;
         -- Função para retornar o plano de conta para PIS
         vn_planoconta_id_pis := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                     , en_dm_ind_emit  => r_c170_plano.dm_ind_emit
                                                                     , en_dm_ind_oper  => r_c170_plano.dm_ind_oper
                                                                     , en_modfiscal_id => r_c170_plano.modfiscal_id
                                                                     , en_pessoa_id    => r_c170_plano.pessoa_id
                                                                     , en_cfop_id      => r_c170_plano.cfop_id
                                                                     , en_item_id      => r_c170_plano.item_id
                                                                     , en_ncm_id       => vn_ncm_id
                                                                     , en_tpservico_id => vn_tpservico_id
                                                                     , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                     , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                     , en_cod_st_piscofins => null -- cod_st 
                                                                     , ev_ret          => 'PCTA_PIS' );
         --
         vn_fase := 6.3;
         --
         if nvl(vn_planoconta_id_pis,0) <> 0 then
            --
            vn_fase := 6.4;
            --
            begin
               update item_nota_fiscal it
                  set it.cod_cta = pk_csf.fkg_cd_plano_conta(vn_planoconta_id_pis)
                where it.id = r_c170_plano.itemnf_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Item da Nota Fiscal de Mercadoria - Plano de Conta. Identificador do Item = '||
                                   r_c170_plano.itemnf_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 6.5;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_c170_plano.reg_bloco -- reg_bloco
                                                     , r_c170_plano.obj_referencia -- obj_referencia
                                                     , r_c170_plano.registro_id -- registro_id / itemnf_id
                                                     , r_c170_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_pis)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Item da Nota Fiscal de Mercadoria - Plano de Conta. '||
                                   'Identificador do item = '||r_c170_plano.itemnf_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 6.6;
            --
            commit;
            --
         else -- nvl(vn_planoconta_id_pis,0) = 0
            --
            vn_fase := 6.7;
            -- Função para retornar o plano de conta para COFINS
            vn_planoconta_id_cofins := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                           , en_dm_ind_emit  => r_c170_plano.dm_ind_emit
                                                                           , en_dm_ind_oper  => r_c170_plano.dm_ind_oper
                                                                           , en_modfiscal_id => r_c170_plano.modfiscal_id
                                                                           , en_pessoa_id    => r_c170_plano.pessoa_id
                                                                           , en_cfop_id      => r_c170_plano.cfop_id
                                                                           , en_item_id      => r_c170_plano.item_id
                                                                           , en_ncm_id       => vn_ncm_id
                                                                           , en_tpservico_id => vn_tpservico_id
                                                                           , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                           , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                           , en_cod_st_piscofins => null -- cod_st 
                                                                           , ev_ret          => 'PCTA_COF' );
            --
            vn_fase := 6.8;
            --
            if nvl(vn_planoconta_id_cofins,0) <> 0 then
               --
               vn_fase := 6.9;
               --
               begin
                  update item_nota_fiscal it
                     set it.cod_cta = pk_csf.fkg_cd_plano_conta(vn_planoconta_id_cofins)
                   where it.id = r_c170_plano.itemnf_id;
               exception
                  when others then
                     gv_resumo_log := 'Problemas ao alterar Item da Nota Fiscal de Mercadoria - Plano de Conta. Identificador do Item = '||
                                      r_c170_plano.itemnf_id||'. Erro = '||sqlerrm;
                     pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                      , ev_mensagem       => gv_mensagem_log
                                                      , ev_resumo         => gv_resumo_log
                                                      , en_tipo_log       => erro_de_sistema
                                                      , en_referencia_id  => gn_referencia_id
                                                      , ev_obj_referencia => gv_obj_referencia
                                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               end;
               --
               vn_fase := 6.10;
               --
               begin
                  insert into validatualparampc_regbloco( id
                                                        , validatualparampc_id
                                                        , reg_bloco
                                                        , obj_referencia
                                                        , registro_id
                                                        , inform )
                                                  values( validatualparampcregbloco_seq.nextval -- id
                                                        , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                        , r_c170_plano.reg_bloco -- reg_bloco
                                                        , r_c170_plano.obj_referencia -- obj_referencia
                                                        , r_c170_plano.registro_id -- registro_id / itemnf_id
                                                        , r_c170_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_cofins)||'.' ); -- inform
               exception
                  when others then
                     gv_resumo_log := 'Problemas ao incluir registro atualizado - Item da Nota Fiscal de Mercadoria - Plano de Conta. Identificador do '||
                                      'item = '||r_c170_plano.itemnf_id||'. Erro = '||sqlerrm;
                     pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                      , ev_mensagem       => gv_mensagem_log
                                                      , ev_resumo         => gv_resumo_log
                                                      , en_tipo_log       => erro_de_sistema
                                                      , en_referencia_id  => gn_referencia_id
                                                      , ev_obj_referencia => gv_obj_referencia
                                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               end;
               --
               vn_fase := 6.11;
               --
               commit;
               --
            else -- nvl(vn_planoconta_id_cofins,0) = 0
               --
               vn_fase := 6.12;
               --
               vv_resumo_log := 'Não foi encontrado Plano de Conta - PIS e/ou COFINS. '||r_c170_plano.inform||' Parâmetros utilizados: '||
                                'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||
                                '), Indicador de emitente = '||pk_csf.fkg_dominio(ev_dominio => 'NOTA_FISCAL.DM_IND_EMIT', ev_vl => r_c170_plano.dm_ind_emit)||
                                ' (en_dm_ind_emit = '||r_c170_plano.dm_ind_emit||', Indicador da Operação = '||pk_csf.fkg_dominio(ev_dominio =>
                                'NOTA_FISCAL.DM_IND_OPER', ev_vl => r_c170_plano.dm_ind_oper)||' (en_dm_ind_oper = '||r_c170_plano.dm_ind_oper||
                                '), Modelo Fiscal = '||pk_csf.fkg_cod_mod_id(en_modfiscal_id => r_c170_plano.modfiscal_id)||' (en_modfiscal_id = '||
                                r_c170_plano.modfiscal_id||'), Participante = '||pk_csf.fkg_pessoa_cod_part(en_pessoa_id => r_c170_plano.pessoa_id)||'-'||
                                pk_csf.fkg_nome_pessoa_id(en_pessoa_id => r_c170_plano.pessoa_id)||' (en_pessoa_id = '||r_c170_plano.pessoa_id||'), CFOP = '||
                                pk_csf.fkg_cfop_cd(en_cfop_id => r_c170_plano.cfop_id)||' (en_cfop_id = '||r_c170_plano.cfop_id||'), Item = '||
                                pk_csf.fkg_item_cod(en_item_id => r_c170_plano.item_id)||' (en_item_id = '||r_c170_plano.item_id||'), NCM = '||
                                r_c170_plano.cod_ncm||', Código da Lista de Serviço = '||r_c170_plano.cd_lista_serv||', Data Inicial = '||
                                gt_row_valid_atual_param_pc.dt_ini||', Data Final = '||gt_row_valid_atual_param_pc.dt_final||'. Identificador do item (ID) = '||
                                r_c170_plano.itemnf_id||'.';
               pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                , ev_mensagem       => gv_mensagem_log
                                                , ev_resumo         => vv_resumo_log
                                                , en_tipo_log       => erro_inform_geral
                                                , en_referencia_id  => gn_referencia_id
                                                , ev_obj_referencia => gv_obj_referencia
                                                , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               --
            end if; -- nvl(vn_planoconta_id_cofins,0) <> 0
            --
         end if; -- nvl(vn_planoconta_id_pis,0) <> 0
         --
      end loop; -- Planos de Contas - Notas Fiscais de Mercadoria - PIS e/ou COFINS
      --
      vn_fase := 6.13;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Notas Fiscais de Mercadoria - Item da Nota Fiscal - Plano de Contas = '||vn_qtde||
                       '. Essa quantidade não indica que todos os registros foram atualizados, para isso, verifique os logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
      vn_fase := 7;
      vn_qtde := 0;
      --
      -- Planos de Contas - Notas Fiscais de Serviço - PIS e/ou COFINS
      for r_a170_plano in c_a170_pl( en_empresa_id        => r_empresa.empresa_id
                                   , en_dm_dt_escr_dfepoe => r_empresa.dm_dt_escr_dfepoe )
      loop
         --
         exit when c_a170_pl%notfound or (c_a170_pl%notfound);
         --
         vn_fase := 7.1;
         --
         vn_qtde := nvl(vn_qtde,0) + 1;
         vn_ncm_id := pk_csf.fkg_ncm_id(ev_cod_ncm => r_a170_plano.cod_ncm);
         vn_tpservico_id := pk_csf.fkg_tipo_servico_id(ev_cod_lst => r_a170_plano.cd_lista_serv);
         --
         vn_fase := 7.2;
         -- Função para retornar o plano de conta para PIS
         vn_planoconta_id_pis := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                     , en_dm_ind_emit  => r_a170_plano.dm_ind_emit
                                                                     , en_dm_ind_oper  => r_a170_plano.dm_ind_oper
                                                                     , en_modfiscal_id => r_a170_plano.modfiscal_id
                                                                     , en_pessoa_id    => r_a170_plano.pessoa_id
                                                                     , en_cfop_id      => r_a170_plano.cfop_id
                                                                     , en_item_id      => r_a170_plano.item_id
                                                                     , en_ncm_id       => vn_ncm_id
                                                                     , en_tpservico_id => vn_tpservico_id
                                                                     , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                     , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                     , en_cod_st_piscofins => r_a170_plano.cod_st  
                                                                     , ev_ret          => 'PCTA_PIS' );
         --
         vn_fase := 7.3;
         --
         if nvl(vn_planoconta_id_pis,0) <> 0 then
            --
            vn_fase := 7.4;
            --
            begin
               update item_nota_fiscal it
                  set it.cod_cta = pk_csf.fkg_cd_plano_conta(vn_planoconta_id_pis)
                where it.id = r_a170_plano.itemnf_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Item da Nota Fiscal de Serviço - Plano de Conta. Identificador do Item = '||
                                   r_a170_plano.itemnf_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 7.5;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_a170_plano.reg_bloco -- reg_bloco
                                                     , r_a170_plano.obj_referencia -- obj_referencia
                                                     , r_a170_plano.registro_id -- registro_id / itemnf_id
                                                     , r_a170_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_pis)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Item da Nota Fiscal de Serviço - Plano de Conta. '||
                                   'Identificador do item = '||r_a170_plano.itemnf_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 7.6;
            --
            commit;
            --
         else -- nvl(vn_planoconta_id_pis,0) = 0
            --
            vn_fase := 7.7;
            -- Função para retornar o plano de conta para COFINS
            vn_planoconta_id_cofins := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                           , en_dm_ind_emit  => r_a170_plano.dm_ind_emit
                                                                           , en_dm_ind_oper  => r_a170_plano.dm_ind_oper
                                                                           , en_modfiscal_id => r_a170_plano.modfiscal_id
                                                                           , en_pessoa_id    => r_a170_plano.pessoa_id
                                                                           , en_cfop_id      => r_a170_plano.cfop_id
                                                                           , en_item_id      => r_a170_plano.item_id
                                                                           , en_ncm_id       => vn_ncm_id
                                                                           , en_tpservico_id => vn_tpservico_id
                                                                           , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                           , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                           , en_cod_st_piscofins => r_a170_plano.cod_st  
                                                                           , ev_ret          => 'PCTA_COF' );
            --
            vn_fase := 7.8;
            --
            if nvl(vn_planoconta_id_cofins,0) <> 0 then
               --
               vn_fase := 7.9;
               --
               begin
                  update item_nota_fiscal it
                     set it.cod_cta = pk_csf.fkg_cd_plano_conta(vn_planoconta_id_cofins)
                   where it.id = r_a170_plano.itemnf_id;
               exception
                  when others then
                     gv_resumo_log := 'Problemas ao alterar Item da Nota Fiscal de Serviço - Plano de Conta. Identificador do Item = '||
                                      r_a170_plano.itemnf_id||'. Erro = '||sqlerrm;
                     pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                      , ev_mensagem       => gv_mensagem_log
                                                      , ev_resumo         => gv_resumo_log
                                                      , en_tipo_log       => erro_de_sistema
                                                      , en_referencia_id  => gn_referencia_id
                                                      , ev_obj_referencia => gv_obj_referencia
                                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               end;
               --
               vn_fase := 7.10;
               --
               begin
                  insert into validatualparampc_regbloco( id
                                                        , validatualparampc_id
                                                        , reg_bloco
                                                        , obj_referencia
                                                        , registro_id
                                                        , inform )
                                                  values( validatualparampcregbloco_seq.nextval -- id
                                                        , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                        , r_a170_plano.reg_bloco -- reg_bloco
                                                        , r_a170_plano.obj_referencia -- obj_referencia
                                                        , r_a170_plano.registro_id -- registro_id / itemnf_id
                                                        , r_a170_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_cofins)||'.' ); -- inform
               exception
                  when others then
                     gv_resumo_log := 'Problemas ao incluir registro atualizado - Item da Nota Fiscal de Serviço - Plano de Conta. Identificador do '||
                                      'item = '||r_a170_plano.itemnf_id||'. Erro = '||sqlerrm;
                     pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                      , ev_mensagem       => gv_mensagem_log
                                                      , ev_resumo         => gv_resumo_log
                                                      , en_tipo_log       => erro_de_sistema
                                                      , en_referencia_id  => gn_referencia_id
                                                      , ev_obj_referencia => gv_obj_referencia
                                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               end;
               --
               vn_fase := 7.11;
               --
               commit;
               --
            else -- nvl(vn_planoconta_id_cofins,0) = 0
               --
               vn_fase := 7.12;
               --
               vv_resumo_log := 'Não foi encontrado Plano de Conta - PIS e/ou COFINS. '||r_a170_plano.inform||' Parâmetros utilizados: '||
                                'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||
                                '), Indicador de emitente = '||pk_csf.fkg_dominio(ev_dominio => 'NOTA_FISCAL.DM_IND_EMIT', ev_vl => r_a170_plano.dm_ind_emit)||
                                ' (en_dm_ind_emit = '||r_a170_plano.dm_ind_emit||', Indicador da Operação = '||pk_csf.fkg_dominio(ev_dominio =>
                                'NOTA_FISCAL.DM_IND_OPER', ev_vl => r_a170_plano.dm_ind_oper)||' (en_dm_ind_oper = '||r_a170_plano.dm_ind_oper||
                                '), Modelo Fiscal = '||pk_csf.fkg_cod_mod_id(en_modfiscal_id => r_a170_plano.modfiscal_id)||' (en_modfiscal_id = '||
                                r_a170_plano.modfiscal_id||'), Participante = '||pk_csf.fkg_pessoa_cod_part(en_pessoa_id => r_a170_plano.pessoa_id)||'-'||
                                pk_csf.fkg_nome_pessoa_id(en_pessoa_id => r_a170_plano.pessoa_id)||' (en_pessoa_id = '||r_a170_plano.pessoa_id||'), CFOP = '||
                                pk_csf.fkg_cfop_cd(en_cfop_id => r_a170_plano.cfop_id)||' (en_cfop_id = '||r_a170_plano.cfop_id||'), Item = '||
                                pk_csf.fkg_item_cod(en_item_id => r_a170_plano.item_id)||' (en_item_id = '||r_a170_plano.item_id||'), NCM = '||
                                r_a170_plano.cod_ncm||', Código da Lista de Serviço = '||r_a170_plano.cd_lista_serv||', Data Inicial = '||
                                gt_row_valid_atual_param_pc.dt_ini||', Data Final = '||gt_row_valid_atual_param_pc.dt_final||'. Identificador do item (ID) = '||
                                r_a170_plano.itemnf_id||'.';
               pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                , ev_mensagem       => gv_mensagem_log
                                                , ev_resumo         => vv_resumo_log
                                                , en_tipo_log       => erro_inform_geral
                                                , en_referencia_id  => gn_referencia_id
                                                , ev_obj_referencia => gv_obj_referencia
                                                , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               --
            end if; -- nvl(vn_planoconta_id_cofins,0) <> 0
            --
         end if; -- nvl(vn_planoconta_id_pis,0) <> 0
         --
      end loop; -- Planos de Contas - Notas Fiscais de Serviço - PIS e/ou COFINS
      --
      vn_fase := 7.13;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Notas Fiscais de Serviço - Item da Nota Fiscal - Plano de Contas = '||vn_qtde||
                       '. Essa quantidade não indica que todos os registros foram atualizados, para isso, verifique os logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
      vn_fase := 8;
      vn_qtde := 0;
      --
      -- Planos de Contas - Notas Fiscais de Venda a Consumidor - PIS e/ou COFINS
      for r_c380_plano in c_c380_pl( en_empresa_id => r_empresa.empresa_id )
      loop
         --
         exit when c_c380_pl%notfound or (c_c380_pl%notfound);
         --
         vn_fase := 8.1;
         vn_qtde := nvl(vn_qtde,0) + 1;
         -- Função para retornar o plano de conta para PIS
         vn_planoconta_id_pis := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                     , en_dm_ind_emit  => null -- dm_ind_emit
                                                                     , en_dm_ind_oper  => null -- dm_ind_oper
                                                                     , en_modfiscal_id => r_c380_plano.modfiscal_id
                                                                     , en_pessoa_id    => null -- pessoa_id
                                                                     , en_cfop_id      => r_c380_plano.cfop_id
                                                                     , en_item_id      => null -- item_id
                                                                     , en_ncm_id       => null -- ncm_id
                                                                     , en_tpservico_id => null -- tpservico_id
                                                                     , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                     , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                     , en_cod_st_piscofins => null -- cod_st 
                                                                     , ev_ret          => 'PCTA_PIS' );
         --
         vn_fase := 8.2;
         --
         if nvl(vn_planoconta_id_pis,0) <> 0 then
            --
            vn_fase := 8.3;
            --
            begin
               update res_dia_nf_venda_cons rd
                  set rd.cod_cta = pk_csf.fkg_cd_plano_conta(vn_planoconta_id_pis)
                where rd.id = r_c380_plano.resdianfvendacons_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Nota Fiscal de Venda a Consumidor - Plano de Conta. Identificador da nota = '||
                                   r_c380_plano.resdianfvendacons_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 8.4;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_c380_plano.reg_bloco -- reg_bloco
                                                     , r_c380_plano.obj_referencia -- obj_referencia
                                                     , r_c380_plano.registro_id -- registro_id / itemnf_id
                                                     , r_c380_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_pis)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Nota Fiscal de Venda a Consumidor - Plano de Conta. '||
                                   'Identificador do nota = '||r_c380_plano.resdianfvendacons_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 8.5;
            --
            commit;
            --
         else -- nvl(vn_planoconta_id_pis,0) = 0
            --
            vn_fase := 8.6;
            -- Função para retornar o plano de conta para COFINS
            vn_planoconta_id_cofins := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                           , en_dm_ind_emit  => null -- dm_ind_emit
                                                                           , en_dm_ind_oper  => null -- dm_ind_oper
                                                                           , en_modfiscal_id => r_c380_plano.modfiscal_id
                                                                           , en_pessoa_id    => null -- pessoa_id
                                                                           , en_cfop_id      => r_c380_plano.cfop_id
                                                                           , en_item_id      => null -- item_id
                                                                           , en_ncm_id       => null -- ncm_id
                                                                           , en_tpservico_id => null -- tpservico_id
                                                                           , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                           , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                           , en_cod_st_piscofins => null -- cod_st 
                                                                           , ev_ret          => 'PCTA_COF' );
            --
            vn_fase := 8.7;
            --
            if nvl(vn_planoconta_id_cofins,0) <> 0 then
               --
               vn_fase := 8.8;
               --
               begin
                  update res_dia_nf_venda_cons rd
                     set rd.cod_cta = pk_csf.fkg_cd_plano_conta(vn_planoconta_id_cofins)
                   where rd.id = r_c380_plano.resdianfvendacons_id;
               exception
                  when others then
                     gv_resumo_log := 'Problemas ao alterar Nota Fiscal de Venda a Consumidor - Plano de Conta. Identificador da nota = '||
                                      r_c380_plano.resdianfvendacons_id||'. Erro = '||sqlerrm;
                     pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                      , ev_mensagem       => gv_mensagem_log
                                                      , ev_resumo         => gv_resumo_log
                                                      , en_tipo_log       => erro_de_sistema
                                                      , en_referencia_id  => gn_referencia_id
                                                      , ev_obj_referencia => gv_obj_referencia
                                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               end;
               --
               vn_fase := 8.9;
               --
               begin
                  insert into validatualparampc_regbloco( id
                                                        , validatualparampc_id
                                                        , reg_bloco
                                                        , obj_referencia
                                                        , registro_id
                                                        , inform )
                                                  values( validatualparampcregbloco_seq.nextval -- id
                                                        , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                        , r_c380_plano.reg_bloco -- reg_bloco
                                                        , r_c380_plano.obj_referencia -- obj_referencia
                                                        , r_c380_plano.registro_id -- registro_id / itemnf_id
                                                        , r_c380_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_cofins)||'.' ); -- inform
               exception
                  when others then
                     gv_resumo_log := 'Problemas ao incluir registro atualizado - Nota Fiscal de Venda a Consumidor - Plano de Conta. Identificador da '||
                                      'nota = '||r_c380_plano.resdianfvendacons_id||'. Erro = '||sqlerrm;
                     pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                      , ev_mensagem       => gv_mensagem_log
                                                      , ev_resumo         => gv_resumo_log
                                                      , en_tipo_log       => erro_de_sistema
                                                      , en_referencia_id  => gn_referencia_id
                                                      , ev_obj_referencia => gv_obj_referencia
                                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               end;
               --
               vn_fase := 8.10;
               --
               commit;
               --
            else -- nvl(vn_planoconta_id_cofins,0) = 0
               --
               vn_fase := 8.11;
               --
               vv_resumo_log := 'Não foi encontrado Plano de Conta - PIS e/ou COFINS. '||r_c380_plano.inform||' Parâmetros utilizados: '||
                                'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||
                                '), Modelo Fiscal = '||pk_csf.fkg_cod_mod_id(en_modfiscal_id => r_c380_plano.modfiscal_id)||' (en_modfiscal_id = '||
                                r_c380_plano.modfiscal_id||'), CFOP = '||pk_csf.fkg_cfop_cd(en_cfop_id => r_c380_plano.cfop_id)||' (en_cfop_id = '||
                                r_c380_plano.cfop_id||'), Data Inicial = '||gt_row_valid_atual_param_pc.dt_ini||', Data Final = '||
                                gt_row_valid_atual_param_pc.dt_final||'. Identificador da nota (ID) = '||r_c380_plano.resdianfvendacons_id||'.';
               pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                , ev_mensagem       => gv_mensagem_log
                                                , ev_resumo         => vv_resumo_log
                                                , en_tipo_log       => erro_inform_geral
                                                , en_referencia_id  => gn_referencia_id
                                                , ev_obj_referencia => gv_obj_referencia
                                                , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               --
            end if; -- nvl(vn_planoconta_id_cofins,0) <> 0
            --
         end if; -- nvl(vn_planoconta_id_pis,0) <> 0
         --
      end loop; -- Planos de Contas - Notas Fiscais de Venda a Consumidor - PIS e/ou COFINS
      --
      vn_fase := 8.12;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Notas Fiscais de Venda a Consumidor - Plano de Contas = '||vn_qtde||
                       '. Essa quantidade não indica que todos os registros foram atualizados, para isso, verifique os logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
      vn_fase := 9;
      --
      -- Planos de Contas - Equipamento/Redução Z - Resumo Diário de Documentos Emitidos por ECF - PIS
      for r_c481_plano in c_c481_plpis( en_empresa_id => r_empresa.empresa_id )
      loop
         --
         exit when c_c481_plpis%notfound or (c_c481_plpis%notfound);
         --
         vn_fase := 9.1;
         vn_qtde := nvl(vn_qtde,0) + 1;
         -- Função para retornar o plano de conta para PIS
         vn_planoconta_id_pis := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                     , en_dm_ind_emit  => null -- dm_ind_emit
                                                                     , en_dm_ind_oper  => null -- dm_ind_oper
                                                                     , en_modfiscal_id => r_c481_plano.modfiscal_id
                                                                     , en_pessoa_id    => null -- pessoa_id
                                                                     , en_cfop_id      => r_c481_plano.cfop_id
                                                                     , en_item_id      => r_c481_plano.item_id
                                                                     , en_ncm_id       => null -- ncm_id
                                                                     , en_tpservico_id => null -- tpservico_id
                                                                     , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                     , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                     , en_cod_st_piscofins => null -- cod_st 
                                                                     , ev_ret          => 'PCTA_PIS' );
         --
         vn_fase := 9.2;
         --
         if nvl(vn_planoconta_id_pis,0) <> 0 then
            --
            vn_fase := 9.3;
            --
            begin
               update res_dia_doc_ecf_pis rd
                  set rd.planoconta_id = vn_planoconta_id_pis
                where rd.id = r_c481_plano.resdiadocecfpis_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Equipamento/Redução Z - Resumo Diário de Documentos Emitidos por ECF - Plano de Conta - PIS. '||
                                   'Identificador do Resumo = '||r_c481_plano.resdiadocecfpis_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 9.4;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_c481_plano.reg_bloco -- reg_bloco
                                                     , r_c481_plano.obj_referencia -- obj_referencia
                                                     , r_c481_plano.registro_id -- registro_id / nfcomploperpis_id
                                                     , r_c481_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_pis)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Equipamento/Redução Z - Resumo Diário de Documentos Emitidos por ECF - Plano '||
                                   'de Conta - PIS. Identificador do resumo = '||r_c481_plano.resdiadocecfpis_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 9.5;
            --
            commit;
            --
         else -- nvl(vn_planoconta_id_pis,0) = 0
            --
            vn_fase := 9.6;
            --
            vv_resumo_log := 'Não foi encontrado Plano de Conta - PIS. '||r_c481_plano.inform||' Parâmetros utilizados: '||
                             'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||
                             '), Modelo Fiscal = '||pk_csf.fkg_cod_mod_id(en_modfiscal_id => r_c481_plano.modfiscal_id)||' (en_modfiscal_id = '||
                             r_c481_plano.modfiscal_id||'), CFOP = '||pk_csf.fkg_cfop_cd(en_cfop_id => r_c481_plano.cfop_id)||' (en_cfop_id = '||
                             r_c481_plano.cfop_id||'), Item = '||pk_csf.fkg_item_cod(en_item_id => r_c481_plano.item_id)||' (en_item_id = '||
                             r_c481_plano.item_id||'), Data Inicial = '||gt_row_valid_atual_param_pc.dt_ini||', Data Final = '||
                             gt_row_valid_atual_param_pc.dt_final||'. Identificador do resumo de PIS (ID) = '||r_c481_plano.resdiadocecfpis_id||'.';
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                             , ev_mensagem       => gv_mensagem_log
                                             , ev_resumo         => vv_resumo_log
                                             , en_tipo_log       => erro_inform_geral
                                             , en_referencia_id  => gn_referencia_id
                                             , ev_obj_referencia => gv_obj_referencia
                                             , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            --
         end if;
         --
      end loop; -- Planos de Contas - Equipamento/Redução Z - Resumo Diário de Documentos Emitidos por ECF - PIS
      --
      vn_fase := 9.7;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Equipamento/Redução Z - Resumo Diário de Documentos Emitidos por ECF - PIS - Plano de Contas = '||vn_qtde||
                       '. Essa quantidade não indica que todos os registros foram atualizados, para isso, verifique os logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
      vn_fase := 10;
      vn_qtde := 0;
      --
      -- Planos de Contas - Equipamento/Redução Z - Resumo Diário de Documentos Emitidos por ECF - COFINS
      for r_c485_plano in c_c485_plcof( en_empresa_id => r_empresa.empresa_id )
      loop
         --
         exit when c_c485_plcof%notfound or (c_c485_plcof%notfound);
         --
         vn_fase := 10.1;
         vn_qtde := nvl(vn_qtde,0) + 1;
         -- Função para retornar o plano de conta para COFINS
         vn_planoconta_id_cofins := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                        , en_dm_ind_emit  => null -- dm_ind_emit
                                                                        , en_dm_ind_oper  => null -- dm_ind_oper
                                                                        , en_modfiscal_id => r_c485_plano.modfiscal_id
                                                                        , en_pessoa_id    => null -- pessoa_id
                                                                        , en_cfop_id      => r_c485_plano.cfop_id
                                                                        , en_item_id      => r_c485_plano.item_id
                                                                        , en_ncm_id       => null -- ncm_id
                                                                        , en_tpservico_id => null -- tpservico_id
                                                                        , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                        , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                        , en_cod_st_piscofins => null -- cod_st 
                                                                        , ev_ret          => 'PCTA_COF' );
         --
         vn_fase := 10.2;
         --
         if nvl(vn_planoconta_id_cofins,0) <> 0 then
            --
            vn_fase := 10.3;
            --
            begin
               update res_dia_doc_ecf_cofins rd
                  set rd.planoconta_id = vn_planoconta_id_cofins
                where rd.id = r_c485_plano.resdiadocecfcofins_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Equipamento/Redução Z - Resumo Diário de Documentos Emitidos por ECF - Plano de Conta - COFINS. '||
                                   'Identificador do resumo = '||r_c485_plano.resdiadocecfcofins_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 10.4;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_c485_plano.reg_bloco -- reg_bloco
                                                     , r_c485_plano.obj_referencia -- obj_referencia
                                                     , r_c485_plano.registro_id -- registro_id / nfcomplopercofins_id
                                                     , r_c485_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_cofins)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Equipamento/Redução Z - Resumo Diário de Documentos Emitidos por ECF - Plano '||
                                   'de Conta - COFINS. Identificador do resumo = '||r_c485_plano.resdiadocecfcofins_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 10.5;
            --
            commit;
            --
         else -- nvl(vn_planoconta_id_cofins,0) = 0
            --
            vn_fase := 10.6;
            --
            vv_resumo_log := 'Não foi encontrado Plano de Conta - COFINS. '||r_c485_plano.inform||' Parâmetros utilizados: '||
                             'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||
                             '), Modelo Fiscal = '||pk_csf.fkg_cod_mod_id(en_modfiscal_id => r_c485_plano.modfiscal_id)||' (en_modfiscal_id = '||
                             r_c485_plano.modfiscal_id||'), CFOP = '||pk_csf.fkg_cfop_cd(en_cfop_id => r_c485_plano.cfop_id)||' (en_cfop_id = '||
                             r_c485_plano.cfop_id||'), Item = '||pk_csf.fkg_item_cod(en_item_id => r_c485_plano.item_id)||' (en_item_id = '||
                             r_c485_plano.item_id||'), Data Inicial = '||gt_row_valid_atual_param_pc.dt_ini||', Data Final = '||
                             gt_row_valid_atual_param_pc.dt_final||'. Identificador do resumo de COFINS (ID) = '||r_c485_plano.resdiadocecfcofins_id||'.';
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                             , ev_mensagem       => gv_mensagem_log
                                             , ev_resumo         => vv_resumo_log
                                             , en_tipo_log       => erro_inform_geral
                                             , en_referencia_id  => gn_referencia_id
                                             , ev_obj_referencia => gv_obj_referencia
                                             , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            --
         end if;
         --
      end loop; -- Planos de Contas - Equipamento/Redução Z - Resumo Diário de Documentos Emitidos por ECF - COFINS
      --
      vn_fase := 10.7;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Equipamento/Redução Z - Resumo Diário de Documentos Emitidos por ECF - COFINS - Plano de Contas = '||vn_qtde||
                       '. Essa quantidade não indica que todos os registros foram atualizados, para isso, verifique os logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
      vn_fase := 11;
      vn_qtde := 0;
      --
      -- Planos de Contas - Conhecimento de Transporte - PIS
      for r_d101_plano in c_d101_plpis( en_empresa_id        => r_empresa.empresa_id
                                      , en_dm_dt_escr_dfepoe => r_empresa.dm_dt_escr_dfepoe )
      loop
         --
         exit when c_d101_plpis%notfound or (c_d101_plpis%notfound);
         --
         vn_fase := 11.1;
         vn_qtde := nvl(vn_qtde,0) + 1;
         -- Função para retornar o plano de conta para PIS
         vn_planoconta_id_pis := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                     , en_dm_ind_emit  => r_d101_plano.dm_ind_emit
                                                                     , en_dm_ind_oper  => r_d101_plano.dm_ind_oper
                                                                     , en_modfiscal_id => r_d101_plano.modfiscal_id
                                                                     , en_pessoa_id    => r_d101_plano.pessoa_id
                                                                     , en_cfop_id      => r_d101_plano.cfop_id
                                                                     , en_item_id      => null -- item_id
                                                                     , en_ncm_id       => null -- ncm_id
                                                                     , en_tpservico_id => null -- tpservico_id
                                                                     , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                     , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                     , en_cod_st_piscofins => r_d101_plano.cod_st  
                                                                     , ev_ret          => 'PCTA_PIS' );
         --
         vn_fase := 11.2;
         --
         if nvl(vn_planoconta_id_pis,0) <> 0 then
            --
            vn_fase := 11.3;
            --
            begin
               update ct_comp_doc_pis cp
                  set cp.planoconta_id = vn_planoconta_id_pis
                where cp.id = r_d101_plano.ctcompdocpis_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Complemento do Conhecimento de Transporte - Plano de Conta - PIS. Identificador do Complemento = '||
                                   r_d101_plano.ctcompdocpis_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 11.4;
            --
            begin
               update conhec_transp ct
                  set ct.cod_cta = pk_csf.fkg_cd_plano_conta ( vn_planoconta_id_pis ) -- en_planoconta_id
                where ct.id = r_d101_plano.registro_id; -- conhectransp_id
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar o Conhecimento de Transporte - Plano de Conta - PIS. Identificador do Complemento = '||
                                   r_d101_plano.ctcompdocpis_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 11.5;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_d101_plano.reg_bloco -- reg_bloco
                                                     , r_d101_plano.obj_referencia -- obj_referencia
                                                     , r_d101_plano.registro_id -- registro_id / conhectransp_id
                                                     , r_d101_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_pis)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Complemento do Conhecimento de Transporte - Plano de Conta - PIS. '||
                                   'Identificador do complemento = '||r_d101_plano.ctcompdocpis_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 11.6;
            --
            commit;
            --
         else -- nvl(vn_planoconta_id_pis,0) = 0
            --
            vn_fase := 11.7;
            --
            vv_resumo_log := 'Não foi encontrado Plano de Conta - PIS. '||r_d101_plano.inform||' Parâmetros utilizados: '||
                             'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||
                             '), Indicador de emitente = '||pk_csf.fkg_dominio(ev_dominio => 'CONHEC_TRANSP.DM_IND_EMIT', ev_vl => r_d101_plano.dm_ind_emit)||
                             ' (en_dm_ind_emit = '||r_d101_plano.dm_ind_emit||', Indicador da Operação = '||pk_csf.fkg_dominio(ev_dominio =>
                             'CONHEC_TRANSP.DM_IND_OPER', ev_vl => r_d101_plano.dm_ind_oper)||' (en_dm_ind_oper = '||r_d101_plano.dm_ind_oper||
                             '), Modelo Fiscal = '||pk_csf.fkg_cod_mod_id(en_modfiscal_id => r_d101_plano.modfiscal_id)||' (en_modfiscal_id = '||
                             r_d101_plano.modfiscal_id||'), Participante = '||pk_csf.fkg_pessoa_cod_part(en_pessoa_id => r_d101_plano.pessoa_id)||'-'||
                             pk_csf.fkg_nome_pessoa_id(en_pessoa_id => r_d101_plano.pessoa_id)||' (en_pessoa_id = '||r_d101_plano.pessoa_id||'), CFOP = '||
                             pk_csf.fkg_cfop_cd(en_cfop_id => r_d101_plano.cfop_id)||' (en_cfop_id = '||r_d101_plano.cfop_id||'), Data Inicial = '||
                             gt_row_valid_atual_param_pc.dt_ini||', Data Final = '||gt_row_valid_atual_param_pc.dt_final||'. Identificador do complemento '||
                             'de PIS (ID) = '||r_d101_plano.ctcompdocpis_id||'.';
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                             , ev_mensagem       => gv_mensagem_log
                                             , ev_resumo         => vv_resumo_log
                                             , en_tipo_log       => erro_inform_geral
                                             , en_referencia_id  => gn_referencia_id
                                             , ev_obj_referencia => gv_obj_referencia
                                             , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            --
         end if;
         --
      end loop; -- Planos de Contas - Conhecimento de Transporte - PIS
      --
      vn_fase := 11.8;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Conhecimento de Transporte - Complemento de PIS - Plano de Contas = '||vn_qtde||
                       '. Essa quantidade não indica que todos os registros foram atualizados, para isso, verifique os logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
      vn_fase := 12;
      vn_qtde := 0;
      --
      -- Planos de Contas - Conhecimento de Transporte - COFINS
      for r_d105_plano in c_d105_plcof( en_empresa_id        => r_empresa.empresa_id
                                      , en_dm_dt_escr_dfepoe => r_empresa.dm_dt_escr_dfepoe )
      loop
         --
         exit when c_d105_plcof%notfound or (c_d105_plcof%notfound);
         --
         vn_fase := 12.1;
         vn_qtde := nvl(vn_qtde,0) + 1;
         -- Função para retornar o plano de conta para COFINS
         vn_planoconta_id_cofins := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                        , en_dm_ind_emit  => r_d105_plano.dm_ind_emit
                                                                        , en_dm_ind_oper  => r_d105_plano.dm_ind_oper
                                                                        , en_modfiscal_id => r_d105_plano.modfiscal_id
                                                                        , en_pessoa_id    => r_d105_plano.pessoa_id
                                                                        , en_cfop_id      => r_d105_plano.cfop_id
                                                                        , en_item_id      => null -- item_id
                                                                        , en_ncm_id       => null -- ncm_id
                                                                        , en_tpservico_id => null -- tpservico_id
                                                                        , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                        , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                        , en_cod_st_piscofins => r_d105_plano.cod_st   
                                                                        , ev_ret          => 'PCTA_COF' );
         --
         vn_fase := 12.2;
         --
         if nvl(vn_planoconta_id_cofins,0) <> 0 then
            --
            vn_fase := 12.3;
            --
            begin
               update ct_comp_doc_cofins cc
                  set cc.planoconta_id = vn_planoconta_id_cofins
                where cc.id = r_d105_plano.ctcompdoccofins_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Complemento do Conhecimento de Transporte - Plano de Conta - COFINS. Identificador do '||
                                   'Complemento = '||r_d105_plano.ctcompdoccofins_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 12.4;
            --
            begin
               update conhec_transp ct
                  set ct.cod_cta = pk_csf.fkg_cd_plano_conta ( vn_planoconta_id_cofins ) -- en_planoconta_id
                where ct.id       = r_d105_plano.registro_id -- conhectransp_id
                  and ct.cod_cta is null; -- pode ter sido alterado no processo de atualização de PIS
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar o Conhecimento de Transporte - Plano de Conta - COFINS. Identificador do Complemento = '||
                                   r_d105_plano.ctcompdoccofins_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 12.5;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_d105_plano.reg_bloco -- reg_bloco
                                                     , r_d105_plano.obj_referencia -- obj_referencia
                                                     , r_d105_plano.registro_id -- registro_id / nfcomplopercofins_id
                                                     , r_d105_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_cofins)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Complemento do Conhecimento de Transporte - Plano de Conta - COFINS. '||
                                   'Identificador do complemento = '||r_d105_plano.ctcompdoccofins_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 12.6;
            --
            commit;
            --
         else -- nvl(vn_planoconta_id_cofins,0) = 0
            --
            vn_fase := 12.7;
            --
            vv_resumo_log := 'Não foi encontrado Plano de Conta - COFINS. '||r_d105_plano.inform||' Parâmetros utilizados: '||
                             'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||
                             '), Indicador de emitente = '||pk_csf.fkg_dominio(ev_dominio => 'CONHEC_TRANSP.DM_IND_EMIT', ev_vl => r_d105_plano.dm_ind_emit)||
                             ' (en_dm_ind_emit = '||r_d105_plano.dm_ind_emit||', Indicador da Operação = '||pk_csf.fkg_dominio(ev_dominio =>
                             'CONHEC_TRANSP.DM_IND_OPER', ev_vl => r_d105_plano.dm_ind_oper)||' (en_dm_ind_oper = '||r_d105_plano.dm_ind_oper||
                             '), Modelo Fiscal = '||pk_csf.fkg_cod_mod_id(en_modfiscal_id => r_d105_plano.modfiscal_id)||' (en_modfiscal_id = '||
                             r_d105_plano.modfiscal_id||'), Participante = '||pk_csf.fkg_pessoa_cod_part(en_pessoa_id => r_d105_plano.pessoa_id)||'-'||
                             pk_csf.fkg_nome_pessoa_id(en_pessoa_id => r_d105_plano.pessoa_id)||' (en_pessoa_id = '||r_d105_plano.pessoa_id||'), CFOP = '||
                             pk_csf.fkg_cfop_cd(en_cfop_id => r_d105_plano.cfop_id)||' (en_cfop_id = '||r_d105_plano.cfop_id||'), Data Inicial = '||
                             gt_row_valid_atual_param_pc.dt_ini||', Data Final = '||gt_row_valid_atual_param_pc.dt_final||'. Identificador do complemento '||
                             'de COFINS (ID) = '||r_d105_plano.ctcompdoccofins_id||'.';
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                             , ev_mensagem       => gv_mensagem_log
                                             , ev_resumo         => vv_resumo_log
                                             , en_tipo_log       => erro_inform_geral
                                             , en_referencia_id  => gn_referencia_id
                                             , ev_obj_referencia => gv_obj_referencia
                                             , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            --
         end if;
         --
      end loop; -- Planos de Contas - Conhecimento de Transporte - COFINS
      --
      vn_fase := 12.8;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Conhecimento de Transporte - Complemento de COFINS - Plano de Contas = '||vn_qtde||
                       '. Essa quantidade não indica que todos os registros foram atualizados, para isso, verifique os logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
      -- I100/I200 - Composição das receitas, deduções e/ou exclusões do período. Não temos parâmetros para essa atualização - Utilizar a tela/portal para correção.
      -- I100/I300 - Complemento das operações - Detalhamento das receitas, deduções e/ou exclusões do período. Não temos parâmetros para essa atualização - Utilizar a tela/portal para correção.
      --
      vn_fase := 13;
      vn_qtde := 0;
      --
      -- Planos de Contas - Controle de Créditos Fiscais de PIS - Apuração de Crédito Extemporâneo
      for r_1101_plano in c_1101_plpis( en_empresa_id => r_empresa.empresa_id )
      loop
         --
         exit when c_1101_plpis%notfound or (c_1101_plpis%notfound);
         --
         vn_fase := 13.1;
         vn_qtde := nvl(vn_qtde,0) + 1;
         -- Função para retornar o plano de conta para PIS
         vn_planoconta_id_pis := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                     , en_dm_ind_emit  => null -- dm_ind_emit
                                                                     , en_dm_ind_oper  => null -- dm_ind_oper
                                                                     , en_modfiscal_id => null -- modfiscal_id
                                                                     , en_pessoa_id    => null -- pessoa_id
                                                                     , en_cfop_id      => r_1101_plano.cfop_id
                                                                     , en_item_id      => null -- item_id
                                                                     , en_ncm_id       => null -- ncm_id
                                                                     , en_tpservico_id => null -- tpservico_id
                                                                     , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                     , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                     , en_cod_st_piscofins => null -- cod_st 
                                                                     , ev_ret          => 'PCTA_PIS' );
         --
         vn_fase := 13.2;
         --
         if nvl(vn_planoconta_id_pis,0) <> 0 then
            --
            vn_fase := 13.3;
            --
            begin
               update apur_cred_ext_pis ac
                  set ac.planoconta_id = vn_planoconta_id_pis
                where ac.id = r_1101_plano.apurcredextpis_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Controle de Créditos Fiscais de PIS - Apuração de Crédito Extemporâneo - Plano de Conta. '||
                                   'Identificador da Apuração = '||r_1101_plano.apurcredextpis_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 13.4;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_1101_plano.reg_bloco -- reg_bloco
                                                     , r_1101_plano.obj_referencia -- obj_referencia
                                                     , r_1101_plano.registro_id -- registro_id / nfcomploperpis_id
                                                     , r_1101_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_pis)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Controle de Créditos Fiscais de PIS - Apuração de Crédito Extemporâneo - Plano '||
                                   'de Conta. Identificador da Apuração = '||r_1101_plano.apurcredextpis_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 13.5;
            --
            commit;
            --
         else -- nvl(vn_planoconta_id_pis,0) = 0
            --
            vn_fase := 13.6;
            --
            vv_resumo_log := 'Não foi encontrado Plano de Conta - PIS. '||r_1101_plano.inform||' Parâmetros utilizados: Empresa = '||
                             pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||'), CFOP = '||
                             pk_csf.fkg_cfop_cd(en_cfop_id => r_1101_plano.cfop_id)||' (en_cfop_id = '||r_1101_plano.cfop_id||'), Data Inicial = '||
                             gt_row_valid_atual_param_pc.dt_ini||', Data Final = '||gt_row_valid_atual_param_pc.dt_final||'. Identificador da Apuração de '||
                             'PIS (ID) = '||r_1101_plano.apurcredextpis_id||'.';
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                             , ev_mensagem       => gv_mensagem_log
                                             , ev_resumo         => vv_resumo_log
                                             , en_tipo_log       => erro_inform_geral
                                             , en_referencia_id  => gn_referencia_id
                                             , ev_obj_referencia => gv_obj_referencia
                                             , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            --
         end if;
         --
      end loop; -- Planos de Contas - Controle de Créditos Fiscais de PIS - Apuração de Crédito Extemporâneo
      --
      vn_fase := 13.7;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Controle de Créditos Fiscais de PIS - Apuração de Crédito Extemporâneo - Plano de Contas = '||vn_qtde||
                       '. Essa quantidade não indica que todos os registros foram atualizados, para isso, verifique os logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
      vn_fase := 14;
      vn_qtde := 0;
      --
      -- Planos de Contas - Controle de Créditos Fiscais de COFINS - Apuração de Crédito Extemporâneo
      for r_1501_plano in c_1501_plcof( en_empresa_id => r_empresa.empresa_id )
      loop
         --
         exit when c_1501_plcof%notfound or (c_1501_plcof%notfound);
         --
         vn_fase := 14.1;
         vn_qtde := nvl(vn_qtde,0) + 1;
         -- Função para retornar o plano de conta para COFINS
         vn_planoconta_id_cofins := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                        , en_dm_ind_emit  => null -- dm_ind_emit
                                                                        , en_dm_ind_oper  => null -- dm_ind_oper
                                                                        , en_modfiscal_id => null -- modfiscal_id
                                                                        , en_pessoa_id    => null -- pessoa_id
                                                                        , en_cfop_id      => r_1501_plano.cfop_id
                                                                        , en_item_id      => null -- item_id
                                                                        , en_ncm_id       => null -- ncm_id
                                                                        , en_tpservico_id => null -- tpservico_id
                                                                        , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                        , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                        , en_cod_st_piscofins => null -- cod_st 
                                                                        , ev_ret          => 'PCTA_COF' );
         --
         vn_fase := 14.2;
         --
         if nvl(vn_planoconta_id_cofins,0) <> 0 then
            --
            vn_fase := 14.3;
            --
            begin
               update apur_cred_ext_cofins ac
                  set ac.planoconta_id = vn_planoconta_id_cofins
                where ac.id = r_1501_plano.apurcredextcofins_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Controle de Créditos Fiscais de COFINS - Apuração de Crédito Extemporâneo - Plano de Conta. '||
                                   'Identificador da Apuração = '||r_1501_plano.apurcredextcofins_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 14.4;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_1501_plano.reg_bloco -- reg_bloco
                                                     , r_1501_plano.obj_referencia -- obj_referencia
                                                     , r_1501_plano.registro_id -- registro_id / nfcomplopercofins_id
                                                     , r_1501_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_cofins)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Controle de Créditos Fiscais de COFINS - Apuração de Crédito Extemporâneo - '||
                                   'Plano de Conta. Identificador da Apuração = '||r_1501_plano.apurcredextcofins_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 14.5;
            --
            commit;
            --
         else -- nvl(vn_planoconta_id_cofins,0) = 0
            --
            vn_fase := 14.6;
            --
            vv_resumo_log := 'Não foi encontrado Plano de Conta - COFINS. '||r_1501_plano.inform||' Parâmetros utilizados: Empresa = '||
                             pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||'), CFOP = '||
                             pk_csf.fkg_cfop_cd(en_cfop_id => r_1501_plano.cfop_id)||' (en_cfop_id = '||r_1501_plano.cfop_id||'), Data Inicial = '||
                             gt_row_valid_atual_param_pc.dt_ini||', Data Final = '||gt_row_valid_atual_param_pc.dt_final||'. Identificador da Apuração de '||
                             'COFINS (ID) = '||r_1501_plano.apurcredextcofins_id||'.';
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                             , ev_mensagem       => gv_mensagem_log
                                             , ev_resumo         => vv_resumo_log
                                             , en_tipo_log       => erro_inform_geral
                                             , en_referencia_id  => gn_referencia_id
                                             , ev_obj_referencia => gv_obj_referencia
                                             , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            --
         end if;
         --
      end loop; -- Planos de Contas - Controle de Créditos Fiscais de COFINS - Apuração de Crédito Extemporâneo
      --
      vn_fase := 14.7;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Controle de Créditos Fiscais de COFINS - Apuração de Crédito Extemporâneo - Plano de Contas = '||vn_qtde||
                       '. Essa quantidade não indica que todos os registros foram atualizados, para isso, verifique os logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
      vn_fase := 15;
      vn_qtde := 0;
      --
      -- Planos de Contas - Demais Documentos e Operações Geradoras de Contribuição e Créditos - F100 - PIS e/ou COFINS
      for r_f100_plano in c_f100_ct( en_empresa_id => r_empresa.empresa_id )
      loop
         --
         exit when c_f100_ct%notfound or (c_f100_ct%notfound);
         --
         vn_fase := 15.1;
         vn_qtde := nvl(vn_qtde,0) + 1;
         -- Função para retornar o plano de conta para PIS
         vn_planoconta_id_pis := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                     , en_dm_ind_emit  => null -- dm_ind_emit
                                                                     , en_dm_ind_oper  => null -- dm_ind_oper
                                                                     , en_modfiscal_id => null -- modfiscal_id
                                                                     , en_pessoa_id    => r_f100_plano.pessoa_id
                                                                     , en_cfop_id      => null -- cfop_id
                                                                     , en_item_id      => r_f100_plano.item_id
                                                                     , en_ncm_id       => null -- ncm_id
                                                                     , en_tpservico_id => null -- tpservico_id
                                                                     , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                     , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                     , en_cod_st_piscofins => null -- cod_st 
                                                                     , ev_ret          => 'PCTA_PIS' );
         --
         vn_fase := 15.2;
         --
         if nvl(vn_planoconta_id_pis,0) <> 0 then
            --
            vn_fase := 15.3;
            --
            begin
               update dem_doc_oper_ger_cc dd
                  set dd.planoconta_id = vn_planoconta_id_pis
                where dd.id = r_f100_plano.demdocopergercc_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Demais Documentos e Operações Geradoras de Contribuição e Créditos - F100 - Plano de Conta. '||
                                   'Identificador do F100 = '||r_f100_plano.demdocopergercc_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 15.4;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_f100_plano.reg_bloco -- reg_bloco
                                                     , r_f100_plano.obj_referencia -- obj_referencia
                                                     , r_f100_plano.registro_id -- registro_id / itemnf_id
                                                     , r_f100_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_pis)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Demais Documentos e Operações Geradoras de Contribuição e Créditos - F100 - '||
                                   'Plano de Conta. Identificador do F100 = '||r_f100_plano.demdocopergercc_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 15.5;
            --
            commit;
            --
         else -- nvl(vn_planoconta_id_pis,0) = 0
            --
            vn_fase := 15.6;
            -- Função para retornar o plano de conta para COFINS
            vn_planoconta_id_cofins := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                           , en_dm_ind_emit  => null -- dm_ind_emit
                                                                           , en_dm_ind_oper  => null -- dm_ind_oper
                                                                           , en_modfiscal_id => null -- modfiscal_id
                                                                           , en_pessoa_id    => r_f100_plano.pessoa_id
                                                                           , en_cfop_id      => null -- cfop_id
                                                                           , en_item_id      => r_f100_plano.item_id
                                                                           , en_ncm_id       => null -- ncm_id
                                                                           , en_tpservico_id => null -- tpservico_id
                                                                           , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                           , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                           , en_cod_st_piscofins => null -- cod_st 
                                                                           , ev_ret          => 'PCTA_COF' );
            --
            vn_fase := 15.7;
            --
            if nvl(vn_planoconta_id_cofins,0) <> 0 then
               --
               vn_fase := 15.8;
               --
               begin
                  update dem_doc_oper_ger_cc dd
                     set dd.planoconta_id = vn_planoconta_id_cofins
                   where dd.id = r_f100_plano.demdocopergercc_id;
               exception
                  when others then
                     gv_resumo_log := 'Problemas ao alterar Demais Documentos e Operações Geradoras de Contribuição e Créditos - F100 - Plano de Conta. '||
                                      'Identificador do F100 = '||r_f100_plano.demdocopergercc_id||'. Erro = '||sqlerrm;
                     pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                      , ev_mensagem       => gv_mensagem_log
                                                      , ev_resumo         => gv_resumo_log
                                                      , en_tipo_log       => erro_de_sistema
                                                      , en_referencia_id  => gn_referencia_id
                                                      , ev_obj_referencia => gv_obj_referencia
                                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               end;
               --
               vn_fase := 15.9;
               --
               begin
                  insert into validatualparampc_regbloco( id
                                                        , validatualparampc_id
                                                        , reg_bloco
                                                        , obj_referencia
                                                        , registro_id
                                                        , inform )
                                                  values( validatualparampcregbloco_seq.nextval -- id
                                                        , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                        , r_f100_plano.reg_bloco -- reg_bloco
                                                        , r_f100_plano.obj_referencia -- obj_referencia
                                                        , r_f100_plano.registro_id -- registro_id / itemnf_id
                                                        , r_f100_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_cofins)||'.' ); -- inform
               exception
                  when others then
                     gv_resumo_log := 'Problemas ao incluir registro atualizado - Demais Documentos e Operações Geradoras de Contribuição e Créditos - F100 - '||
                                      'Plano de Conta. Identificador do F100 = '||r_f100_plano.demdocopergercc_id||'. Erro = '||sqlerrm;
                     pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                      , ev_mensagem       => gv_mensagem_log
                                                      , ev_resumo         => gv_resumo_log
                                                      , en_tipo_log       => erro_de_sistema
                                                      , en_referencia_id  => gn_referencia_id
                                                      , ev_obj_referencia => gv_obj_referencia
                                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               end;
               --
               vn_fase := 15.10;
               --
               commit;
               --
            else -- nvl(vn_planoconta_id_cofins,0) = 0
               --
               vn_fase := 15.11;
               --
               vv_resumo_log := 'Não foi encontrado Plano de Conta - PIS e/ou COFINS. '||r_f100_plano.inform||' Parâmetros utilizados: Empresa = '||
                                pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||
                                '), Participante = '||pk_csf.fkg_pessoa_cod_part(en_pessoa_id => r_f100_plano.pessoa_id)||'-'||
                                pk_csf.fkg_nome_pessoa_id(en_pessoa_id => r_f100_plano.pessoa_id)||' (en_pessoa_id = '||r_f100_plano.pessoa_id||'), Item = '||
                                pk_csf.fkg_item_cod(en_item_id => r_f100_plano.item_id)||' (en_item_id = '||r_f100_plano.item_id||'), Data Inicial = '||
                                gt_row_valid_atual_param_pc.dt_ini||', Data Final = '||gt_row_valid_atual_param_pc.dt_final||'. Identificador do F100 (ID) = '||
                                r_f100_plano.demdocopergercc_id||'.';
               pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                , ev_mensagem       => gv_mensagem_log
                                                , ev_resumo         => vv_resumo_log
                                                , en_tipo_log       => erro_inform_geral
                                                , en_referencia_id  => gn_referencia_id
                                                , ev_obj_referencia => gv_obj_referencia
                                                , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               --
            end if; -- nvl(vn_planoconta_id_cofins,0) <> 0
            --
         end if; -- nvl(vn_planoconta_id_pis,0) <> 0
         --
      end loop; -- Planos de Contas - Demais Documentos e Operações Geradoras de Contribuição e Créditos - F100 - PIS e/ou COFINS
      --
      vn_fase := 15.12;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Demais Documentos e Operações Geradoras de Contribuição e Créditos - F100 - Plano de Contas = '||vn_qtde||
                       '. Essa quantidade não indica que todos os registros foram atualizados, para isso, verifique os logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
      vn_fase := 16;
      vn_qtde := 0;
      --
      -- Planos de Contas - Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência do
      -- PIS/COFINS pelo regime de caixa - F500 - PIS e/ou COFINS
      for r_f500_plano in c_f500_pl( en_empresa_id => r_empresa.empresa_id )
      loop
         --
         exit when c_f500_pl%notfound or (c_f500_pl%notfound);
         --
         vn_fase := 16.1;
         vn_qtde := nvl(vn_qtde,0) + 1;
         -- Função para retornar o plano de conta para PIS
         vn_planoconta_id_pis := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                     , en_dm_ind_emit  => null -- dm_ind_emit
                                                                     , en_dm_ind_oper  => null -- dm_ind_oper
                                                                     , en_modfiscal_id => r_f500_plano.modfiscal_id
                                                                     , en_pessoa_id    => null -- pessoa_id
                                                                     , en_cfop_id      => r_f500_plano.cfop_id
                                                                     , en_item_id      => null -- item_id
                                                                     , en_ncm_id       => null -- ncm_id
                                                                     , en_tpservico_id => null -- tpservico_id
                                                                     , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                     , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                     , en_cod_st_piscofins => null -- cod_st 
                                                                     , ev_ret          => 'PCTA_PIS' );
         --
         vn_fase := 16.2;
         --
         if nvl(vn_planoconta_id_pis,0) <> 0 then
            --
            vn_fase := 16.3;
            --
            begin
               update cons_oper_ins_pc_rc co
                  set co.planoconta_id = vn_planoconta_id_pis
                where co.id = r_f500_plano.consoperinspcrc_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro '||
                                   'Presumido - Incidência do PIS/COFINS pelo regime de caixa - F500 - Plano de Conta. '||
                                   'Identificador do F500 = '||r_f500_plano.consoperinspcrc_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 16.4;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_f500_plano.reg_bloco -- reg_bloco
                                                     , r_f500_plano.obj_referencia -- obj_referencia
                                                     , r_f500_plano.registro_id -- registro_id / itemnf_id
                                                     , r_f500_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_pis)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de '||
                                   'Tributação com Base no Lucro Presumido - Incidência do - PIS/COFINS pelo regime de caixa - F500 - '||
                                   'Plano de Conta. Identificador do F500 = '||r_f500_plano.consoperinspcrc_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 16.5;
            --
            commit;
            --
         else -- nvl(vn_planoconta_id_pis,0) = 0
            --
            vn_fase := 16.6;
            -- Função para retornar o plano de conta para COFINS
            vn_planoconta_id_cofins := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                           , en_dm_ind_emit  => null -- dm_ind_emit
                                                                           , en_dm_ind_oper  => null -- dm_ind_oper
                                                                           , en_modfiscal_id => r_f500_plano.modfiscal_id
                                                                           , en_pessoa_id    => null -- pessoa_id
                                                                           , en_cfop_id      => r_f500_plano.cfop_id
                                                                           , en_item_id      => null -- item_id
                                                                           , en_ncm_id       => null -- ncm_id
                                                                           , en_tpservico_id => null -- tpservico_id
                                                                           , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                           , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                           , en_cod_st_piscofins => null -- cod_st 
                                                                           , ev_ret          => 'PCTA_COF' );
            --
            vn_fase := 16.7;
            --
            if nvl(vn_planoconta_id_cofins,0) <> 0 then
               --
               vn_fase := 16.8;
               --
               begin
                  update cons_oper_ins_pc_rc co
                     set co.planoconta_id = vn_planoconta_id_cofins
                   where co.id = r_f500_plano.consoperinspcrc_id;
               exception
                  when others then
                     gv_resumo_log := 'Problemas ao alterar Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro '||
                                      'Presumido - Incidência do - PIS/COFINS pelo regime de caixa - F500 - Plano de Conta. '||
                                      'Identificador do F500 = '||r_f500_plano.consoperinspcrc_id||'. Erro = '||sqlerrm;
                     pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                      , ev_mensagem       => gv_mensagem_log
                                                      , ev_resumo         => gv_resumo_log
                                                      , en_tipo_log       => erro_de_sistema
                                                      , en_referencia_id  => gn_referencia_id
                                                      , ev_obj_referencia => gv_obj_referencia
                                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               end;
               --
               vn_fase := 16.9;
               --
               begin
                  insert into validatualparampc_regbloco( id
                                                        , validatualparampc_id
                                                        , reg_bloco
                                                        , obj_referencia
                                                        , registro_id
                                                        , inform )
                                                  values( validatualparampcregbloco_seq.nextval -- id
                                                        , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                        , r_f500_plano.reg_bloco -- reg_bloco
                                                        , r_f500_plano.obj_referencia -- obj_referencia
                                                        , r_f500_plano.registro_id -- registro_id / itemnf_id
                                                        , r_f500_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_cofins)||'.' ); -- inform
               exception
                  when others then
                     gv_resumo_log := 'Problemas ao incluir registro atualizado - Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de '||
                                      'Tributação com Base no Lucro Presumido - Incidência do - PIS/COFINS pelo regime de caixa - F500 - '||
                                      'Plano de Conta. Identificador do F500 = '||r_f500_plano.consoperinspcrc_id||'. Erro = '||sqlerrm;
                     pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                      , ev_mensagem       => gv_mensagem_log
                                                      , ev_resumo         => gv_resumo_log
                                                      , en_tipo_log       => erro_de_sistema
                                                      , en_referencia_id  => gn_referencia_id
                                                      , ev_obj_referencia => gv_obj_referencia
                                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               end;
               --
               vn_fase := 16.10;
               --
               commit;
               --
            else -- nvl(vn_planoconta_id_cofins,0) = 0
               --
               vn_fase := 16.11;
               --
               vv_resumo_log := 'Não foi encontrado Plano de Conta - PIS. '||r_f500_plano.inform||' Parâmetros utilizados: Empresa = '||
                                pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||
                                '), Modelo Fiscal = '||pk_csf.fkg_cod_mod_id(en_modfiscal_id => r_f500_plano.modfiscal_id)||' (en_modfiscal_id = '||
                                r_f500_plano.modfiscal_id||'), CFOP = '||pk_csf.fkg_cfop_cd(en_cfop_id => r_f500_plano.cfop_id)||' (en_cfop_id = '||
                                r_f500_plano.cfop_id||'), Data Inicial = '||gt_row_valid_atual_param_pc.dt_ini||', Data Final = '||
                                gt_row_valid_atual_param_pc.dt_final||'. Identificador do F500 (ID) = '||r_f500_plano.consoperinspcrc_id||'.';
               pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                , ev_mensagem       => gv_mensagem_log
                                                , ev_resumo         => vv_resumo_log
                                                , en_tipo_log       => erro_inform_geral
                                                , en_referencia_id  => gn_referencia_id
                                                , ev_obj_referencia => gv_obj_referencia
                                                , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               --
            end if; -- nvl(vn_planoconta_id_cofins,0) <> 0
            --
         end if; -- nvl(vn_planoconta_id_pis,0) <> 0
         --
      end loop; -- Planos de Contas - Demais Documentos e Operações Geradoras de Contribuição e Créditos - F100 - PIS e/ou COFINS
      --
      vn_fase := 16.12;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - '||
                       'Incidência do - PIS/COFINS pelo regime de caixa - F500 - Plano de Contas = '||vn_qtde||'. Essa quantidade não indica que todos os '||
                       'registros foram atualizados, para isso, verifique os logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
      vn_fase := 17;
      vn_qtde := 0;
      --
      -- Planos de Contas - Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência do
      -- PIS/COFINS pelo regime de caixa (Apuração da contribuição por unidade de medida de produto, alíquota em reais) - F510 - PIS e/ou COFINS
      for r_f510_plano in c_f510_pl( en_empresa_id => r_empresa.empresa_id )
      loop
         --
         exit when c_f510_pl%notfound or (c_f510_pl%notfound);
         --
         vn_fase := 17.1;
         vn_qtde := nvl(vn_qtde,0) + 1;
         -- Função para retornar o plano de conta para PIS
         vn_planoconta_id_pis := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                     , en_dm_ind_emit  => null -- dm_ind_emit
                                                                     , en_dm_ind_oper  => null -- dm_ind_oper
                                                                     , en_modfiscal_id => r_f510_plano.modfiscal_id
                                                                     , en_pessoa_id    => null -- pessoa_id
                                                                     , en_cfop_id      => r_f510_plano.cfop_id
                                                                     , en_item_id      => null -- item_id
                                                                     , en_ncm_id       => null -- ncm_id
                                                                     , en_tpservico_id => null -- tpservico_id
                                                                     , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                     , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                     , en_cod_st_piscofins => null -- cod_st 
                                                                     , ev_ret          => 'PCTA_PIS' );
         --
         vn_fase := 17.2;
         --
         if nvl(vn_planoconta_id_pis,0) <> 0 then
            --
            vn_fase := 17.3;
            --
            begin
               update cons_oper_ins_pc_rc_aum co
                  set co.planoconta_id = vn_planoconta_id_pis
                where co.id = r_f510_plano.consoperinspcrcaum_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro '||
                                   'Presumido - Incidência do PIS/COFINS pelo regime de caixa (Apuração da contribuição por unidade de medida de produto, '||
                                   'alíquota em reais) - F510 - Plano de Conta. Identificador do F510 = '||r_f510_plano.consoperinspcrcaum_id||
                                   '. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 17.4;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_f510_plano.reg_bloco -- reg_bloco
                                                     , r_f510_plano.obj_referencia -- obj_referencia
                                                     , r_f510_plano.registro_id -- registro_id / itemnf_id
                                                     , r_f510_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_pis)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de '||
                                   'Tributação com Base no Lucro Presumido - Incidência do PIS/COFINS pelo regime de caixa (Apuração da contribuição por '||
                                   'unidade de medida de produto, alíquota em reais) - F510 - Plano de Conta. Identificador do F510 = '||
                                   r_f510_plano.consoperinspcrcaum_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 17.5;
            --
            commit;
            --
         else -- nvl(vn_planoconta_id_pis,0) = 0
            --
            vn_fase := 17.6;
            -- Função para retornar o plano de conta para COFINS
            vn_planoconta_id_cofins := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                           , en_dm_ind_emit  => null -- dm_ind_emit
                                                                           , en_dm_ind_oper  => null -- dm_ind_oper
                                                                           , en_modfiscal_id => r_f510_plano.modfiscal_id
                                                                           , en_pessoa_id    => null -- pessoa_id
                                                                           , en_cfop_id      => r_f510_plano.cfop_id
                                                                           , en_item_id      => null -- item_id
                                                                           , en_ncm_id       => null -- ncm_id
                                                                           , en_tpservico_id => null -- tpservico_id
                                                                           , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                           , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                           , en_cod_st_piscofins => null -- cod_st 
                                                                           , ev_ret          => 'PCTA_COF' );
            --
            vn_fase := 17.7;
            --
            if nvl(vn_planoconta_id_cofins,0) <> 0 then
               --
               vn_fase := 17.8;
               --
               begin
                  update cons_oper_ins_pc_rc_aum co
                     set co.planoconta_id = vn_planoconta_id_cofins
                   where co.id = r_f510_plano.consoperinspcrcaum_id;
               exception
                  when others then
                     gv_resumo_log := 'Problemas ao alterar Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no '||
                                      'Lucro Presumido - Incidência do PIS/COFINS pelo regime de caixa (Apuração da contribuição por unidade de medida de '||
                                      'produto, alíquota em reais) - F510 - Plano de Conta. Identificador do F510 = '||r_f510_plano.consoperinspcrcaum_id||
                                      '. Erro = '||sqlerrm;
                     pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                      , ev_mensagem       => gv_mensagem_log
                                                      , ev_resumo         => gv_resumo_log
                                                      , en_tipo_log       => erro_de_sistema
                                                      , en_referencia_id  => gn_referencia_id
                                                      , ev_obj_referencia => gv_obj_referencia
                                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               end;
               --
               vn_fase := 17.9;
               --
               begin
                  insert into validatualparampc_regbloco( id
                                                        , validatualparampc_id
                                                        , reg_bloco
                                                        , obj_referencia
                                                        , registro_id
                                                        , inform )
                                                  values( validatualparampcregbloco_seq.nextval -- id
                                                        , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                        , r_f510_plano.reg_bloco -- reg_bloco
                                                        , r_f510_plano.obj_referencia -- obj_referencia
                                                        , r_f510_plano.registro_id -- registro_id / itemnf_id
                                                        , r_f510_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_cofins)||'.' ); -- inform
               exception
                  when others then
                     gv_resumo_log := 'Problemas ao incluir registro atualizado - Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de '||
                                      'Tributação com Base no Lucro Presumido - Incidência do PIS/COFINS pelo regime de caixa (Apuração da contribuição por '||
                                      'unidade de medida de produto, alíquota em reais) - F510 - Plano de Conta. Identificador do F510 = '||
                                      r_f510_plano.consoperinspcrcaum_id||'. Erro = '||sqlerrm;
                     pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                      , ev_mensagem       => gv_mensagem_log
                                                      , ev_resumo         => gv_resumo_log
                                                      , en_tipo_log       => erro_de_sistema
                                                      , en_referencia_id  => gn_referencia_id
                                                      , ev_obj_referencia => gv_obj_referencia
                                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               end;
               --
               vn_fase := 17.10;
               --
               commit;
               --
            else -- nvl(vn_planoconta_id_cofins,0) = 0
               --
               vn_fase := 17.11;
               --
               vv_resumo_log := 'Não foi encontrado Plano de Conta - PIS. '||r_f510_plano.inform||' Parâmetros utilizados: Empresa = '||
                                pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||
                                '), Modelo Fiscal = '||pk_csf.fkg_cod_mod_id(en_modfiscal_id => r_f510_plano.modfiscal_id)||' (en_modfiscal_id = '||
                                r_f510_plano.modfiscal_id||'), CFOP = '||pk_csf.fkg_cfop_cd(en_cfop_id => r_f510_plano.cfop_id)||' (en_cfop_id = '||
                                r_f510_plano.cfop_id||'), Data Inicial = '||gt_row_valid_atual_param_pc.dt_ini||', Data Final = '||
                                gt_row_valid_atual_param_pc.dt_final||'. Identificador do F510 (ID) = '||r_f510_plano.consoperinspcrcaum_id||'.';
               pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                , ev_mensagem       => gv_mensagem_log
                                                , ev_resumo         => vv_resumo_log
                                                , en_tipo_log       => erro_inform_geral
                                                , en_referencia_id  => gn_referencia_id
                                                , ev_obj_referencia => gv_obj_referencia
                                                , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               --
            end if; -- nvl(vn_planoconta_id_cofins,0) <> 0
            --
         end if; -- nvl(vn_planoconta_id_pis,0) <> 0
         --
      end loop; -- Planos de Contas - Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência
                -- do PIS/COFINS pelo regime de caixa (Apuração da contribuição por unidade de medida de produto, alíquota em reais) - F510 - PIS e/ou COFINS
      --
      vn_fase := 17.12;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - '||
                       'Incidência do PIS/COFINS pelo regime de caixa (Apuração da contribuição por unidade de medida de produto, alíquota em reais) - F510 - '||
                       'Plano de Contas = '||vn_qtde||'. Essa quantidade não indica que todos os registros foram atualizados, para isso, verifique os '||
                       'logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
      vn_fase := 18;
      vn_qtde := 0;
      --
      -- Planos de Contas - Composição da Receita Escriturada no período - Detalhamento da Receita Recebida pelo Regime de Caixa - F525 - PIS e/ou COFINS
      for r_f525_plano in c_f525_pl(en_empresa_id => r_empresa.empresa_id)
      loop
         --
         exit when c_f525_pl%notfound or (c_f525_pl%notfound);
         --
         vn_fase := 18.1;
         vn_qtde := nvl(vn_qtde,0) + 1;
         -- Função para retornar o plano de conta para PIS
         vn_planoconta_id_pis := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                     , en_dm_ind_emit  => null -- dm_ind_emit
                                                                     , en_dm_ind_oper  => null -- dm_ind_oper
                                                                     , en_modfiscal_id => null -- modfiscal_id
                                                                     , en_pessoa_id    => r_f525_plano.pessoa_id
                                                                     , en_cfop_id      => null -- cfop_id
                                                                     , en_item_id      => r_f525_plano.item_id
                                                                     , en_ncm_id       => null -- ncm_id
                                                                     , en_tpservico_id => null -- tpservico_id
                                                                     , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                     , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                     , en_cod_st_piscofins => null -- cod_st 
                                                                     , ev_ret          => 'PCTA_PIS' );
         --
         vn_fase := 18.2;
         --
         if nvl(vn_planoconta_id_pis,0) <> 0 then
            --
            vn_fase := 18.3;
            --
            begin
               update comp_rec_det_rc cr
                  set cr.planoconta_id = vn_planoconta_id_pis
                where cr.id = r_f525_plano.comprecdetrc_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Composição da Receita Escriturada no período - Detalhamento da Receita Recebida pelo Regime de '||
                                   'Caixa - F525 - Plano de Conta - PIS. Identificador do F525 (ID) = '||r_f525_plano.comprecdetrc_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 18.4;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_f525_plano.reg_bloco -- reg_bloco
                                                     , r_f525_plano.obj_referencia -- obj_referencia
                                                     , r_f525_plano.registro_id -- registro_id / nfcomploperpis_id
                                                     , r_f525_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_pis)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Composição da Receita Escriturada no período - Detalhamento da Receita '||
                                   'Recebida pelo Regime de Caixa - F525 - Plano de Conta - PIS. Identificador do F525 (ID) = '||
                                   r_f525_plano.comprecdetrc_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 18.5;
            --
            commit;
            --
         else -- nvl(vn_planoconta_id_pis,0) = 0
            --
            vn_fase := 18.6;
            --
            vv_resumo_log := 'Não foi encontrado Plano de Conta - PIS. '||r_f525_plano.inform||' Parâmetros utilizados: Empresa = '||
                             pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||                             '), Participante = '||pk_csf.fkg_pessoa_cod_part(en_pessoa_id => r_f525_plano.pessoa_id)||'-'||
                             pk_csf.fkg_nome_pessoa_id(en_pessoa_id => r_f525_plano.pessoa_id)||' (en_pessoa_id = '||r_f525_plano.pessoa_id||'), Item = '||
                             pk_csf.fkg_item_cod(en_item_id => r_f525_plano.item_id)||' (en_item_id = '||r_f525_plano.item_id||'), Data Inicial = '||
                             gt_row_valid_atual_param_pc.dt_ini||', Data Final = '||gt_row_valid_atual_param_pc.dt_final||'. Identificador do F525 (ID) = '||
                             r_f525_plano.comprecdetrc_id||'.';
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                             , ev_mensagem       => gv_mensagem_log
                                             , ev_resumo         => vv_resumo_log
                                             , en_tipo_log       => erro_inform_geral
                                             , en_referencia_id  => gn_referencia_id
                                             , ev_obj_referencia => gv_obj_referencia
                                             , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            --
         end if;
         --
      end loop; -- Planos de Contas - Composição da Receita Escriturada no período - Detalhamento da Receita Recebida pelo Regime de Caixa - F525 - PIS e/ou COFINS
      --
      vn_fase := 18.7;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Composição da Receita Escriturada no período - Detalhamento da Receita Recebida pelo Regime de Caixa - F525 - Plano '||
                       'de Contas = '||vn_qtde||'. Essa quantidade não indica que todos os registros foram atualizados, para isso, verifique os logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
      --
      vn_fase := 19;
      vn_qtde := 0;
      --
      -- Planos de Contas - Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência do
      -- PIS/COFINS pelo regime de Competência - F550 - PIS e/ou COFINS
      for r_f550_plano in c_f550_pl( en_empresa_id => r_empresa.empresa_id )
      loop
         --
         exit when c_f550_pl%notfound or (c_f550_pl%notfound);
         --
         vn_fase := 19.1;
         vn_qtde := nvl(vn_qtde,0) + 1;
         -- Função para retornar o plano de conta para PIS
         vn_planoconta_id_pis := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                     , en_dm_ind_emit  => null -- dm_ind_emit
                                                                     , en_dm_ind_oper  => null -- dm_ind_oper
                                                                     , en_modfiscal_id => r_f550_plano.modfiscal_id
                                                                     , en_pessoa_id    => null -- pessoa_id
                                                                     , en_cfop_id      => r_f550_plano.cfop_id
                                                                     , en_item_id      => null -- item_id
                                                                     , en_ncm_id       => null -- ncm_id
                                                                     , en_tpservico_id => null -- tpservico_id
                                                                     , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                     , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                     , en_cod_st_piscofins => null -- cod_st 
                                                                     , ev_ret          => 'PCTA_PIS' );
         --
         vn_fase := 19.2;
         --
         if nvl(vn_planoconta_id_pis,0) <> 0 then
            --
            vn_fase := 19.3;
            --
            begin
               update cons_oper_ins_pc_rcomp co
                  set co.planoconta_id = vn_planoconta_id_pis
                where co.id = r_f550_plano.consoperinspcrcomp_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro '||
                                   'Presumido - Incidência do PIS/COFINS pelo regime de Competência - F550 - Plano de Conta. Identificador do F550 = '||
                                   r_f550_plano.consoperinspcrcomp_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 19.4;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_f550_plano.reg_bloco -- reg_bloco
                                                     , r_f550_plano.obj_referencia -- obj_referencia
                                                     , r_f550_plano.registro_id -- registro_id / itemnf_id
                                                     , r_f550_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_pis)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação '||
                                   'com Base no Lucro Presumido - Incidência do PIS/COFINS pelo regime de Competência - F550 - Plano de Conta. Identificador do '||
                                   'F550 = '||r_f550_plano.consoperinspcrcomp_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 19.5;
            --
            commit;
            --
         else -- nvl(vn_planoconta_id_pis,0) = 0
            --
            vn_fase := 19.6;
            -- Função para retornar o plano de conta para COFINS
            vn_planoconta_id_cofins := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                           , en_dm_ind_emit  => null -- dm_ind_emit
                                                                           , en_dm_ind_oper  => null -- dm_ind_oper
                                                                           , en_modfiscal_id => r_f550_plano.modfiscal_id
                                                                           , en_pessoa_id    => null -- pessoa_id
                                                                           , en_cfop_id      => r_f550_plano.cfop_id
                                                                           , en_item_id      => null -- item_id
                                                                           , en_ncm_id       => null -- ncm_id
                                                                           , en_tpservico_id => null -- tpservico_id
                                                                           , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                           , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                           , en_cod_st_piscofins => null -- cod_st 
                                                                           , ev_ret          => 'PCTA_COF' );
            --
            vn_fase := 19.7;
            --
            if nvl(vn_planoconta_id_cofins,0) <> 0 then
               --
               vn_fase := 19.8;
               --
               begin
                  update cons_oper_ins_pc_rcomp co
                     set co.planoconta_id = vn_planoconta_id_cofins
                   where co.id = r_f550_plano.consoperinspcrcomp_id;
               exception
                  when others then
                     gv_resumo_log := 'Problemas ao alterar Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro '||
                                      'Presumido - Incidência do PIS/COFINS pelo regime de Competência - F550 - Plano de Conta. Identificador do F550 = '||
                                      r_f550_plano.consoperinspcrcomp_id||'. Erro = '||sqlerrm;
                     pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                      , ev_mensagem       => gv_mensagem_log
                                                      , ev_resumo         => gv_resumo_log
                                                      , en_tipo_log       => erro_de_sistema
                                                      , en_referencia_id  => gn_referencia_id
                                                      , ev_obj_referencia => gv_obj_referencia
                                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               end;
               --
               vn_fase := 19.9;
               --
               begin
                  insert into validatualparampc_regbloco( id
                                                        , validatualparampc_id
                                                        , reg_bloco
                                                        , obj_referencia
                                                        , registro_id
                                                        , inform )
                                                  values( validatualparampcregbloco_seq.nextval -- id
                                                        , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                        , r_f550_plano.reg_bloco -- reg_bloco
                                                        , r_f550_plano.obj_referencia -- obj_referencia
                                                        , r_f550_plano.registro_id -- registro_id / itemnf_id
                                                        , r_f550_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_cofins)||'.' ); -- inform
               exception
                  when others then
                     gv_resumo_log := 'Problemas ao incluir registro atualizado - Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de '||
                                      'Tributação com Base no Lucro Presumido - Incidência do PIS/COFINS pelo regime de Competência - F550 - Plano de Conta. '||
                                      'Identificador do F550 = '||r_f550_plano.consoperinspcrcomp_id||'. Erro = '||sqlerrm;
                     pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                      , ev_mensagem       => gv_mensagem_log
                                                      , ev_resumo         => gv_resumo_log
                                                      , en_tipo_log       => erro_de_sistema
                                                      , en_referencia_id  => gn_referencia_id
                                                      , ev_obj_referencia => gv_obj_referencia
                                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               end;
               --
               vn_fase := 19.10;
               --
               commit;
               --
            else -- nvl(vn_planoconta_id_cofins,0) = 0
               --
               vn_fase := 19.11;
               --
               vv_resumo_log := 'Não foi encontrado Plano de Conta - PIS. '||r_f550_plano.inform||' Parâmetros utilizados: Empresa = '||
                                pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||
                                '), Modelo Fiscal = '||pk_csf.fkg_cod_mod_id(en_modfiscal_id => r_f550_plano.modfiscal_id)||' (en_modfiscal_id = '||
                                r_f550_plano.modfiscal_id||'), CFOP = '||pk_csf.fkg_cfop_cd(en_cfop_id => r_f550_plano.cfop_id)||' (en_cfop_id = '||
                                r_f550_plano.cfop_id||'), Data Inicial = '||gt_row_valid_atual_param_pc.dt_ini||', Data Final = '||
                                gt_row_valid_atual_param_pc.dt_final||'. Identificador do F550 (ID) = '||r_f550_plano.consoperinspcrcomp_id||'.';
               pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                , ev_mensagem       => gv_mensagem_log
                                                , ev_resumo         => vv_resumo_log
                                                , en_tipo_log       => erro_inform_geral
                                                , en_referencia_id  => gn_referencia_id
                                                , ev_obj_referencia => gv_obj_referencia
                                                , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               --
            end if; -- nvl(vn_planoconta_id_cofins,0) <> 0
            --
         end if; -- nvl(vn_planoconta_id_pis,0) <> 0
         --
      end loop; -- Planos de Contas - Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência do
                -- PIS/COFINS pelo regime de Competência - F550 - PIS e/ou COFINS
      --
      vn_fase := 19.12;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - '||
                       'Incidência do PIS/COFINS pelo regime de Competência - F550 - Plano de Contas = '||vn_qtde||'. Essa quantidade não indica que todos '||
                       'os registros foram atualizados, para isso, verifique os logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
      --
      vn_fase := 20;
      vn_qtde := 0;
      --
      -- Planos de Contas - Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência do 
      -- PIS/COFINS pelo regime de competência (Apuração da contribuição por unidade de medida de produto, alíquota em reais) - F560 - PIS e/ou COFINS
      for r_f560_plano in c_f560_pl( en_empresa_id => r_empresa.empresa_id )
      loop
         --
         exit when c_f560_pl%notfound or (c_f560_pl%notfound);
         --
         vn_fase := 20.1;
         vn_qtde := nvl(vn_qtde,0) + 1;
         -- Função para retornar o plano de conta para PIS
         vn_planoconta_id_pis := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                     , en_dm_ind_emit  => null -- dm_ind_emit
                                                                     , en_dm_ind_oper  => null -- dm_ind_oper
                                                                     , en_modfiscal_id => r_f560_plano.modfiscal_id
                                                                     , en_pessoa_id    => null -- pessoa_id
                                                                     , en_cfop_id      => r_f560_plano.cfop_id
                                                                     , en_item_id      => null -- item_id
                                                                     , en_ncm_id       => null -- ncm_id
                                                                     , en_tpservico_id => null -- tpservico_id
                                                                     , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                     , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                     , en_cod_st_piscofins => null -- cod_st 
                                                                     , ev_ret          => 'PCTA_PIS' );
         --
         vn_fase := 20.2;
         --
         if nvl(vn_planoconta_id_pis,0) <> 0 then
            --
            vn_fase := 20.3;
            --
            begin
               update cons_op_ins_pcrcomp_aum co
                  set co.planoconta_id = vn_planoconta_id_pis
                where co.id = r_f560_plano.consopinspcrcompaum_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro '||
                                   'Presumido - Incidência do PIS/COFINS pelo regime de competência (Apuração da contribuição por unidade de medida de '||
                                   'produto, alíquota em reais) - F560 - Plano de Conta. Identificador do F560 = '||r_f560_plano.consopinspcrcompaum_id||
                                   '. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 20.4;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_f560_plano.reg_bloco -- reg_bloco
                                                     , r_f560_plano.obj_referencia -- obj_referencia
                                                     , r_f560_plano.registro_id -- registro_id / itemnf_id
                                                     , r_f560_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_pis)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação '||
                                   'com Base no Lucro Presumido - Incidência do PIS/COFINS pelo regime de competência (Apuração da contribuição por unidade de '||
                                   'medida de produto, alíquota em reais) - F560 - Plano de Conta. Identificador do F560 = '||
                                   r_f560_plano.consopinspcrcompaum_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 20.5;
            --
            commit;
            --
         else -- nvl(vn_planoconta_id_pis,0) = 0
            --
            vn_fase := 20.6;
            -- Função para retornar o plano de conta para COFINS
            vn_planoconta_id_cofins := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                           , en_dm_ind_emit  => null -- dm_ind_emit
                                                                           , en_dm_ind_oper  => null -- dm_ind_oper
                                                                           , en_modfiscal_id => r_f560_plano.modfiscal_id
                                                                           , en_pessoa_id    => null -- pessoa_id
                                                                           , en_cfop_id      => r_f560_plano.cfop_id
                                                                           , en_item_id      => null -- item_id
                                                                           , en_ncm_id       => null -- ncm_id
                                                                           , en_tpservico_id => null -- tpservico_id
                                                                           , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                           , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                           , en_cod_st_piscofins => null -- cod_st 
                                                                           , ev_ret          => 'PCTA_COF' );
            --
            vn_fase := 20.7;
            --
            if nvl(vn_planoconta_id_cofins,0) <> 0 then
               --
               vn_fase := 20.8;
               --
               begin
                  update cons_op_ins_pcrcomp_aum co
                     set co.planoconta_id = vn_planoconta_id_cofins
                   where co.id = r_f560_plano.consopinspcrcompaum_id;
               exception
                  when others then
                     gv_resumo_log := 'Problemas ao alterar Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro '||
                                      'Presumido - Incidência do PIS/COFINS pelo regime de competência (Apuração da contribuição por unidade de medida de '||
                                      'produto, alíquota em reais) - F560 - Plano de Conta. Identificador do F560 = '||r_f560_plano.consopinspcrcompaum_id||
                                      '. Erro = '||sqlerrm;
                     pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                      , ev_mensagem       => gv_mensagem_log
                                                      , ev_resumo         => gv_resumo_log
                                                      , en_tipo_log       => erro_de_sistema
                                                      , en_referencia_id  => gn_referencia_id
                                                      , ev_obj_referencia => gv_obj_referencia
                                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               end;
               --
               vn_fase := 20.9;
               --
               begin
                  insert into validatualparampc_regbloco( id
                                                        , validatualparampc_id
                                                        , reg_bloco
                                                        , obj_referencia
                                                        , registro_id
                                                        , inform )
                                                  values( validatualparampcregbloco_seq.nextval -- id
                                                        , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                        , r_f560_plano.reg_bloco -- reg_bloco
                                                        , r_f560_plano.obj_referencia -- obj_referencia
                                                        , r_f560_plano.registro_id -- registro_id / itemnf_id
                                                        , r_f560_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_cofins)||'.' ); -- inform
               exception
                  when others then
                     gv_resumo_log := 'Problemas ao incluir registro atualizado - Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de '||
                                      'Tributação com Base no Lucro Presumido - Incidência do PIS/COFINS pelo regime de competência (Apuração da contribuição '||
                                      'por unidade de medida de produto, alíquota em reais) - F560 - Plano de Conta. Identificador do F560 = '||
                                      r_f560_plano.consopinspcrcompaum_id||'. Erro = '||sqlerrm;
                     pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                      , ev_mensagem       => gv_mensagem_log
                                                      , ev_resumo         => gv_resumo_log
                                                      , en_tipo_log       => erro_de_sistema
                                                      , en_referencia_id  => gn_referencia_id
                                                      , ev_obj_referencia => gv_obj_referencia
                                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               end;
               --
               vn_fase := 20.10;
               --
               commit;
               --
            else -- nvl(vn_planoconta_id_cofins,0) = 0
               --
               vn_fase := 20.11;
               --
               vv_resumo_log := 'Não foi encontrado Plano de Conta - PIS. '||r_f560_plano.inform||' Parâmetros utilizados: Empresa = '||
                                pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||
                                '), Modelo Fiscal = '||pk_csf.fkg_cod_mod_id(en_modfiscal_id => r_f560_plano.modfiscal_id)||' (en_modfiscal_id = '||
                                r_f560_plano.modfiscal_id||'), CFOP = '||pk_csf.fkg_cfop_cd(en_cfop_id => r_f560_plano.cfop_id)||' (en_cfop_id = '||
                                r_f560_plano.cfop_id||'), Data Inicial = '||gt_row_valid_atual_param_pc.dt_ini||', Data Final = '||
                                gt_row_valid_atual_param_pc.dt_final||'. Identificador do F560 (ID) = '||r_f560_plano.consopinspcrcompaum_id||'.';
               pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                , ev_mensagem       => gv_mensagem_log
                                                , ev_resumo         => vv_resumo_log
                                                , en_tipo_log       => erro_inform_geral
                                                , en_referencia_id  => gn_referencia_id
                                                , ev_obj_referencia => gv_obj_referencia
                                                , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               --
            end if; -- nvl(vn_planoconta_id_cofins,0) <> 0
            --
         end if; -- nvl(vn_planoconta_id_pis,0) <> 0
         --
      end loop; -- Planos de Contas - Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência
                -- do PIS/COFINS pelo regime de competência (Apuração da contribuição por unidade de medida de produto, alíquota em reais) - F560 - PIS e/ou 
                -- COFINS
      --
      -- THIAGO ALTEROU AQUI --69583
      for r_c870_plano in c_c870_pl( en_empresa_id => r_empresa.empresa_id)
      loop
         --
         exit when c_c870_pl%notfound or (c_c870_pl%notfound);
         --
         vn_fase := 6.1;
         --
         vn_qtde := nvl(vn_qtde,0) + 1;
         vn_tpservico_id := pk_csf.fkg_tipo_servico_id(ev_cod_lst => r_c870_plano.cd_lista_serv);
         --
         vn_fase := 6.2;
         -- Função para retornar o plano de conta para PIS
         vn_planoconta_id_pis := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                     , en_dm_ind_emit  => null
                                                                     , en_dm_ind_oper  => null
                                                                     , en_modfiscal_id => r_c870_plano.modfiscal_id
                                                                     , en_pessoa_id    => null
                                                                     , en_cfop_id      => r_c870_plano.cfop_id
                                                                     , en_item_id      => r_c870_plano.item_id
                                                                     , en_ncm_id       => r_c870_plano.ncm_id
                                                                     , en_tpservico_id => vn_tpservico_id
                                                                     , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                     , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                     , en_cod_st_piscofins => null -- cod_st 
                                                                     , ev_ret          => 'PCTA_PIS' );
         --
         vn_fase := 6.3;
         --
         if nvl(vn_planoconta_id_pis,0) <> 0 then
            --
            vn_fase := 6.4;
            --
            begin
               update item_cupom_fiscal it
                  set it.cod_cta = pk_csf.fkg_cd_plano_conta(vn_planoconta_id_pis)
                where it.id = r_c870_plano.itemcf_id;
            exception
               when others then
                  gv_resumo_log := 'Problemas ao alterar Item do Cupom Fiscal SAT - Plano de Conta. Identificador do Item = '||
                                   r_c870_plano.itemcf_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 6.5;
            --
            begin
               insert into validatualparampc_regbloco( id
                                                     , validatualparampc_id
                                                     , reg_bloco
                                                     , obj_referencia
                                                     , registro_id
                                                     , inform )
                                               values( validatualparampcregbloco_seq.nextval -- id
                                                     , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                     , r_c870_plano.reg_bloco -- reg_bloco
                                                     , r_c870_plano.obj_referencia -- obj_referencia
                                                     , r_c870_plano.registro_id -- registro_id / cupomfiscal_id
                                                     , r_c870_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_pis)||'.' ); -- inform
            exception
               when others then
                  gv_resumo_log := 'Problemas ao incluir registro atualizado - Item do Cupom Fiscal SAT - Plano de Conta. '||
                                   'Identificador do item = '||r_c870_plano.itemcf_id||'. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 6.6;
            --
            commit;
            --
         else -- nvl(vn_planoconta_id_pis,0) = 0
            --
            vn_fase := 6.7;
            -- Função para retornar o plano de conta para COFINS
            vn_planoconta_id_cofins := pk_csf_efd_pc.fkb_recup_pcta_ccto_pc( en_empresa_id   => r_empresa.empresa_matriz_id --#74522
                                                                           , en_dm_ind_emit  => null
                                                                           , en_dm_ind_oper  => null
                                                                           , en_modfiscal_id => r_c870_plano.modfiscal_id
                                                                           , en_pessoa_id    => null
                                                                           , en_cfop_id      => r_c870_plano.cfop_id
                                                                           , en_item_id      => r_c870_plano.item_id
                                                                           , en_ncm_id       => r_c870_plano.ncm_id
                                                                           , en_tpservico_id => vn_tpservico_id
                                                                           , ed_dt_ini       => gt_row_valid_atual_param_pc.dt_ini
                                                                           , ed_dt_final     => gt_row_valid_atual_param_pc.dt_final
                                                                           , en_cod_st_piscofins => null -- cod_st 
                                                                           , ev_ret          => 'PCTA_COF' );
            --
            vn_fase := 6.8;
            --
            if nvl(vn_planoconta_id_cofins,0) <> 0 then
               --
               vn_fase := 6.9;
               --
               begin
                  update item_cupom_fiscal it
                     set it.cod_cta = pk_csf.fkg_cd_plano_conta(vn_planoconta_id_cofins)
                   where it.id = r_c870_plano.itemcf_id;
               exception
                  when others then
                     gv_resumo_log := 'Problemas ao alterar Item da Nota Fiscal de Mercadoria - Plano de Conta. Identificador do Item = '||
                                      r_c870_plano.itemcf_id||'. Erro = '||sqlerrm;
                     pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                      , ev_mensagem       => gv_mensagem_log
                                                      , ev_resumo         => gv_resumo_log
                                                      , en_tipo_log       => erro_de_sistema
                                                      , en_referencia_id  => gn_referencia_id
                                                      , ev_obj_referencia => gv_obj_referencia
                                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               end;
               --
               vn_fase := 6.10;
               --
               begin
                  insert into validatualparampc_regbloco( id
                                                        , validatualparampc_id
                                                        , reg_bloco
                                                        , obj_referencia
                                                        , registro_id
                                                        , inform )
                                                  values( validatualparampcregbloco_seq.nextval -- id
                                                        , gt_row_valid_atual_param_pc.id -- validatualparampc_id
                                                        , r_c870_plano.reg_bloco -- reg_bloco
                                                        , r_c870_plano.obj_referencia -- obj_referencia
                                                        , r_c870_plano.registro_id -- registro_id / cupomfiscal_id
                                                        , r_c870_plano.inform||' Plano de Conta: '||pk_csf.fkg_cd_plano_conta(vn_planoconta_id_cofins)||'.' ); -- inform
               exception
                  when others then
                     gv_resumo_log := 'Problemas ao incluir registro atualizado - Item do Cupom Fiscal SAT - Plano de Conta. Identificador do '||
                                      'item = '||r_c870_plano.itemcf_id||'. Erro = '||sqlerrm;
                     pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                      , ev_mensagem       => gv_mensagem_log
                                                      , ev_resumo         => gv_resumo_log
                                                      , en_tipo_log       => erro_de_sistema
                                                      , en_referencia_id  => gn_referencia_id
                                                      , ev_obj_referencia => gv_obj_referencia
                                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               end;
               --
               vn_fase := 6.11;
               --
               commit;
               --
            else -- nvl(vn_planoconta_id_cofins,0) = 0
               --
               vn_fase := 6.12;
               --
               vv_resumo_log := 'Não foi encontrado Plano de Conta - PIS e/ou COFINS. '||r_c870_plano.inform||' Parâmetros utilizados: '||
                                'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||' (en_empresa_id = '||r_empresa.empresa_id||
                                '), Modelo Fiscal = '||pk_csf.fkg_cod_mod_id(en_modfiscal_id => r_c870_plano.modfiscal_id)||' (en_modfiscal_id = '||
                                r_c870_plano.modfiscal_id||'), CFOP = '||pk_csf.fkg_cfop_cd(en_cfop_id => r_c870_plano.cfop_id)||
                                ' (en_cfop_id = '||r_c870_plano.cfop_id||'), Item = '||pk_csf.fkg_item_cod(en_item_id => r_c870_plano.item_id)||
                                ' (en_item_id = '||r_c870_plano.item_id||'), NCM = '||pk_csf.fkg_cod_ncm_id(en_ncm_id => r_c870_plano.ncm_id)||
                                ', Código da Lista de Serviço = '||r_c870_plano.cd_lista_serv||', Data Inicial = '||gt_row_valid_atual_param_pc.dt_ini||
                                ', Data Final = '||gt_row_valid_atual_param_pc.dt_final||'. Identificador do item (ID) = '||r_c870_plano.itemcf_id||'.';
               pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                , ev_mensagem       => gv_mensagem_log
                                                , ev_resumo         => vv_resumo_log
                                                , en_tipo_log       => erro_inform_geral
                                                , en_referencia_id  => gn_referencia_id
                                                , ev_obj_referencia => gv_obj_referencia
                                                , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               --
            end if; -- nvl(vn_planoconta_id_cofins,0) <> 0
            --
         end if; -- nvl(vn_planoconta_id_pis,0) <> 0
         --
      end loop; -- Planos de Contas - Cupom Fiscal SAT - PIS e/ou COFINS
      -- THIAGO FINALIZOU AQUI --69583
      --
      vn_fase := 20.12;
      --
      vv_resumo_log := 'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_empresa.empresa_id)||'. Quantidade de registros recuperados '||
                       'relacionados com Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - '||
                       'Incidência do PIS/COFINS pelo regime de competência (Apuração da contribuição por unidade de medida de produto, alíquota em reais) - '||
                       'F560 - Plano de Contas = '||vn_qtde||'. Essa quantidade não indica que todos os registros foram atualizados, para isso, verifique os '||
                       'logs/mensagens.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => vv_resumo_log
                                       , en_tipo_log       => erro_inform_geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
   end loop; -- Empresa solicitada e suas filiais - consolidando
   --
EXCEPTION
   when others then
      raise_application_error (-20101, 'Problemas em pk_valid_atual_param_pc.pkb_val_atu_pc - Validar/Atualizar os documentos fiscais - planos de contas. '||
                                       'Fase = '||vn_fase||'. Erro = '||sqlerrm);
END PKB_VAL_ATU_PC;

---------------------------------------------------------------------------------------------
--| Procedimento para Validar os parâmetros cadastrados com relação as datas inicial e final
--| Não é permitido incluir períodos sendo que o anterior está sem data de finalização
---------------------------------------------------------------------------------------------
PROCEDURE PKB_VAL_PER IS
   --
   vn_fase           number := 0;
   vn_qtde           number := 0;
   vn_loggenerico_id log_generico.id%type := null;
   --
   cursor c_dtfin_sem_valor is
   select pe.empresa_id
        , pe.dm_ind_emit
        , pe.dm_ind_oper
        , pe.modfiscal_id
        , pe.pessoa_id
        , pe.cfop_id
        , pe.item_id
        , pe.ncm_id
        , pe.tpservico_id
        , count(*) qtde
     from param_efd_contr_geral pe
    where pe.empresa_id in (select ep.id
                              from empresa em
                                 , empresa ep
                             where em.id = gt_row_valid_atual_param_pc.empresa_id
                               and ((gt_row_valid_atual_param_pc.dm_consol = 0 and ep.id = em.id) -- 0-não, considerar a empresa conectada/logada
                                     or
                                    (gt_row_valid_atual_param_pc.dm_consol = 1 and nvl(ep.ar_empresa_id, ep.id) = nvl(em.ar_empresa_id, em.id)))) -- 1-sim, considerar empresa conectada/logada e suas filiais
      and pe.dt_final is null
    group by pe.empresa_id
        , pe.dm_ind_emit
        , pe.dm_ind_oper
        , pe.modfiscal_id
        , pe.pessoa_id
        , pe.cfop_id
        , pe.item_id
        , pe.ncm_id
        , pe.tpservico_id
   having count(*) > 1
    order by pe.empresa_id
        , pe.dm_ind_emit
        , pe.dm_ind_oper
        , pe.modfiscal_id
        , pe.pessoa_id
        , pe.cfop_id
        , pe.item_id
        , pe.ncm_id
        , pe.tpservico_id;
   --
   cursor c_dtini_dtfin is
   select pe.empresa_id
        , pe.dm_ind_emit
        , pe.dm_ind_oper
        , pe.modfiscal_id
        , pe.pessoa_id
        , pe.cfop_id
        , pe.item_id
        , pe.ncm_id
        , pe.tpservico_id
     from param_efd_contr_geral pe
    where pe.empresa_id in (select ep.id
                              from empresa em
                                 , empresa ep
                             where em.id = gt_row_valid_atual_param_pc.empresa_id
                               and ((gt_row_valid_atual_param_pc.dm_consol = 0 and ep.id = em.id) -- 0-não, considerar a empresa conectada/logada
                                     or
                                    (gt_row_valid_atual_param_pc.dm_consol = 1 and nvl(ep.ar_empresa_id, ep.id) = nvl(em.ar_empresa_id, em.id)))) -- 1-sim, considerar empresa conectada/logada e suas filiais
      and pe.dt_ini > nvl(pe.dt_final,pe.dt_ini)
    order by pe.empresa_id
        , pe.dm_ind_emit
        , pe.dm_ind_oper
        , pe.modfiscal_id
        , pe.pessoa_id
        , pe.cfop_id
        , pe.item_id
        , pe.ncm_id
        , pe.tpservico_id;
   --
   cursor c_param is
   select pe.empresa_id
        , pe.dm_ind_emit
        , pe.dm_ind_oper
        , pe.modfiscal_id
        , pe.pessoa_id
        , pe.cfop_id
        , pe.item_id
        , pe.ncm_id
        , pe.tpservico_id
        , count(*) qtde
     from param_efd_contr_geral pe
    where pe.empresa_id in (select ep.id
                              from empresa em
                                 , empresa ep
                             where em.id = gt_row_valid_atual_param_pc.empresa_id
                               and ((gt_row_valid_atual_param_pc.dm_consol = 0 and ep.id = em.id) -- 0-não, considerar a empresa conectada/logada
                                     or
                                    (gt_row_valid_atual_param_pc.dm_consol = 1 and nvl(ep.ar_empresa_id, ep.id) = nvl(em.ar_empresa_id, em.id)))) -- 1-sim, considerar empresa conectada/logada e suas filiais
    group by pe.empresa_id
        , pe.dm_ind_emit
        , pe.dm_ind_oper
        , pe.modfiscal_id
        , pe.pessoa_id
        , pe.cfop_id
        , pe.item_id
        , pe.ncm_id
        , pe.tpservico_id
   having count(*) > 1
    order by pe.empresa_id
        , pe.dm_ind_emit
        , pe.dm_ind_oper
        , pe.modfiscal_id
        , pe.pessoa_id
        , pe.cfop_id
        , pe.item_id
        , pe.ncm_id
        , pe.tpservico_id;
   --
   cursor c_acerta( en_empresa_id   in number
                  , en_dm_ind_emit  in number
                  , en_dm_ind_oper  in number
                  , en_modfiscal_id in number
                  , en_pessoa_id    in number
                  , en_cfop_id      in number
                  , en_item_id      in number
                  , en_ncm_id       in number
                  , en_tpservico_id in number ) is
   select pe.id
        , pe.empresa_id
        , pe.dt_ini
        , pe.dt_final
        , pe.dm_ind_emit
        , pe.dm_ind_oper
        , pe.modfiscal_id
        , pe.pessoa_id
        , pe.cfop_id
        , pe.item_id
        , pe.ncm_id
        , pe.tpservico_id
     from param_efd_contr_geral pe
    where pe.empresa_id                   = en_empresa_id
      and nvl(pe.dm_ind_emit,9)           = nvl(en_dm_ind_emit,9)
      and nvl(pe.dm_ind_oper,9)           = nvl(en_dm_ind_oper,9)
      and nvl(pe.modfiscal_id,9999999999) = nvl(en_modfiscal_id,9999999999)
      and nvl(pe.pessoa_id,9999999999)    = nvl(en_pessoa_id,9999999999)
      and nvl(pe.cfop_id,9999999999)      = nvl(en_cfop_id,9999999999)
      and nvl(pe.item_id,9999999999)      = nvl(en_item_id,9999999999)
      and nvl(pe.ncm_id,9999999999)       = nvl(en_ncm_id,9999999999)
      and nvl(pe.tpservico_id,9999999999) = nvl(en_tpservico_id,9999999999)
    order by pe.dt_ini desc;
   --
BEGIN
   --
   vn_fase := 1;
   --
   for r_reg in c_dtfin_sem_valor
   loop
      --
      exit when c_dtfin_sem_valor%notfound or (c_dtfin_sem_valor%notfound);
      --
      vn_fase := 2;
      --
      gv_resumo_log := 'Verificar os parâmetros com data final não preenchida, e que estão repetidos. Parâmetros utilizados: Empresa = '||
                       pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_reg.empresa_id)||', Indicador de emitente = '||
                       pk_csf.fkg_dominio(ev_dominio => 'PARAM_EFD_CONTR_GERAL.DM_IND_EMIT', ev_vl => r_reg.dm_ind_emit)||', Indicador da Operação = '||
                       pk_csf.fkg_dominio(ev_dominio => 'PARAM_EFD_CONTR_GERAL.DM_IND_OPER', ev_vl => r_reg.dm_ind_oper)||', Modelo Fiscal = '||
                       pk_csf.fkg_cod_mod_id(en_modfiscal_id => r_reg.modfiscal_id)||', Participante = '||
                       pk_csf.fkg_pessoa_cod_part(en_pessoa_id => r_reg.pessoa_id)||'-'||pk_csf.fkg_nome_pessoa_id(en_pessoa_id => r_reg.pessoa_id)||
                       ', CFOP = '||pk_csf.fkg_cfop_cd(en_cfop_id => r_reg.cfop_id)||', Item = '||pk_csf.fkg_item_cod(en_item_id => r_reg.item_id)||
                       ', NCM = '||pk_csf.fkg_cod_ncm_id(en_ncm_id => r_reg.ncm_id)||', Código da Lista de Serviço = '||
                       pk_csf.fkg_tipo_servico_cod(en_tpservico_id => r_reg.tpservico_id)||'.';
      pk_log_generico.pkb_log_generico( sn_loggenerico_id => vn_loggenerico_id
                                      , ev_mensagem       => gv_mensagem_log
                                      , ev_resumo         => gv_resumo_log
                                      , en_tipo_log       => erro_de_validacao
                                      , en_referencia_id  => gn_referencia_id
                                      , ev_obj_referencia => gv_obj_referencia
                                      , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
   end loop;
   --
   vn_fase := 3;
   --
   if gv_resumo_log is null then
      --
      vn_fase := 4;
      --
      for r_reg in c_dtini_dtfin
      loop
         --
         exit when c_dtini_dtfin%notfound or (c_dtini_dtfin%notfound);
         --
         vn_fase := 5;
         --
         gv_resumo_log := 'Verificar os parâmetros com data inicial maior que a data final. Parâmetros utilizados: Empresa = '||
                          pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_reg.empresa_id)||', Indicador de emitente = '||
                          pk_csf.fkg_dominio(ev_dominio => 'PARAM_EFD_CONTR_GERAL.DM_IND_EMIT', ev_vl => r_reg.dm_ind_emit)||', Indicador da Operação = '||
                          pk_csf.fkg_dominio(ev_dominio => 'PARAM_EFD_CONTR_GERAL.DM_IND_OPER', ev_vl => r_reg.dm_ind_oper)||', Modelo Fiscal = '||
                          pk_csf.fkg_cod_mod_id(en_modfiscal_id => r_reg.modfiscal_id)||', Participante = '||
                          pk_csf.fkg_pessoa_cod_part(en_pessoa_id => r_reg.pessoa_id)||'-'||pk_csf.fkg_nome_pessoa_id(en_pessoa_id => r_reg.pessoa_id)||
                          ', CFOP = '||pk_csf.fkg_cfop_cd(en_cfop_id => r_reg.cfop_id)||', Item = '||pk_csf.fkg_item_cod(en_item_id => r_reg.item_id)||
                          ', NCM = '||pk_csf.fkg_cod_ncm_id(en_ncm_id => r_reg.ncm_id)||', Código da Lista de Serviço = '||
                          pk_csf.fkg_tipo_servico_cod(en_tpservico_id => r_reg.tpservico_id)||'.';
         pk_log_generico.pkb_log_generico( sn_loggenerico_id => vn_loggenerico_id
                                         , ev_mensagem       => gv_mensagem_log
                                         , ev_resumo         => gv_resumo_log
                                         , en_tipo_log       => erro_de_validacao
                                         , en_referencia_id  => gn_referencia_id
                                         , ev_obj_referencia => gv_obj_referencia
                                         , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
         --
      end loop;
      --
   end if;
   --
   vn_fase := 6;
   --
   if gv_resumo_log is null then
      --
      vn_fase := 7;
      -- Registros repetidos, verificar intervalo
      for r_param in c_param
      loop
         --
         exit when c_param%notfound or (c_param%notfound);
         --
         vn_fase := 8;
         --
         for r_acerta in c_acerta( en_empresa_id   => r_param.empresa_id
                                 , en_dm_ind_emit  => r_param.dm_ind_emit
                                 , en_dm_ind_oper  => r_param.dm_ind_oper
                                 , en_modfiscal_id => r_param.modfiscal_id
                                 , en_pessoa_id    => r_param.pessoa_id
                                 , en_cfop_id      => r_param.cfop_id
                                 , en_item_id      => r_param.item_id
                                 , en_ncm_id       => r_param.ncm_id
                                 , en_tpservico_id => r_param.tpservico_id )
         loop
            --
            exit when c_acerta%notfound or (c_acerta%notfound);
            --
            vn_fase := 9;
            --
            begin
               select count(*)
                 into vn_qtde
                 from param_efd_contr_geral pe
                where pe.id                          <> r_acerta.id
                  and pe.empresa_id                   = r_acerta.empresa_id
                  and nvl(pe.dm_ind_emit,9)           = nvl(r_acerta.dm_ind_emit,9)
                  and nvl(pe.dm_ind_oper,9)           = nvl(r_acerta.dm_ind_oper,9)
                  and nvl(pe.modfiscal_id,9999999999) = nvl(r_acerta.modfiscal_id,9999999999)
                  and nvl(pe.pessoa_id,9999999999)    = nvl(r_acerta.pessoa_id,9999999999)
                  and nvl(pe.cfop_id,9999999999)      = nvl(r_acerta.cfop_id,9999999999)
                  and nvl(pe.item_id,9999999999)      = nvl(r_acerta.item_id,9999999999)
                  and nvl(pe.ncm_id,9999999999)       = nvl(r_acerta.ncm_id,9999999999)
                  and nvl(pe.tpservico_id,9999999999) = nvl(r_acerta.tpservico_id,9999999999)
                  and nvl(r_acerta.dt_final,r_acerta.dt_ini) between pe.dt_ini and nvl(pe.dt_final,pe.dt_ini);
            exception
               when others then
                  gv_resumo_log := 'Problemas ao verificar intervalo de parâmetros. Erro = '||sqlerrm;
                  pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                                   , ev_mensagem       => gv_mensagem_log
                                                   , ev_resumo         => gv_resumo_log
                                                   , en_tipo_log       => erro_de_sistema
                                                   , en_referencia_id  => gn_referencia_id
                                                   , ev_obj_referencia => gv_obj_referencia
                                                   , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            end;
            --
            vn_fase := 10;
            --
            if nvl(vn_qtde,0) > 1 then
               --
               vn_fase := 11;
               --
               gv_resumo_log := 'Verificar os parâmetros com períodos de validade intercalados de acordo com data inicial e final. Parâmetros utilizados: '||
                                'Empresa = '||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => r_acerta.empresa_id)||', Indicador de emitente = '||
                                pk_csf.fkg_dominio(ev_dominio => 'PARAM_EFD_CONTR_GERAL.DM_IND_EMIT', ev_vl => r_acerta.dm_ind_emit)||', Indicador da Operação = '||
                                pk_csf.fkg_dominio(ev_dominio => 'PARAM_EFD_CONTR_GERAL.DM_IND_OPER', ev_vl => r_acerta.dm_ind_oper)||', Modelo Fiscal = '||
                                pk_csf.fkg_cod_mod_id(en_modfiscal_id => r_acerta.modfiscal_id)||', Participante = '||
                                pk_csf.fkg_pessoa_cod_part(en_pessoa_id => r_acerta.pessoa_id)||'-'||pk_csf.fkg_nome_pessoa_id(en_pessoa_id => r_acerta.pessoa_id)||
                                ', CFOP = '||pk_csf.fkg_cfop_cd(en_cfop_id => r_acerta.cfop_id)||', Item = '||pk_csf.fkg_item_cod(en_item_id => r_acerta.item_id)||
                                ', NCM = '||pk_csf.fkg_cod_ncm_id(en_ncm_id => r_acerta.ncm_id)||', Código da Lista de Serviço = '||
                                pk_csf.fkg_tipo_servico_cod(en_tpservico_id => r_acerta.tpservico_id)||'.';
               pk_log_generico.pkb_log_generico( sn_loggenerico_id => vn_loggenerico_id
                                               , ev_mensagem       => gv_mensagem_log
                                               , ev_resumo         => gv_resumo_log
                                               , en_tipo_log       => erro_de_validacao
                                               , en_referencia_id  => gn_referencia_id
                                               , ev_obj_referencia => gv_obj_referencia
                                               , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
               --
            end if;
            --
         end loop;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      raise_application_error (-20101, 'Problemas em pk_valid_atual_param_pc.pkb_val_per - Validar os parâmetros cadastrados com relação as datas inicial e '||
                                       'final. Fase = '||vn_fase||'. Erro = '||sqlerrm);
END PKB_VAL_PER;

---------------------------------------------------------------------
--| Procedimento para excluir os registros de inconsistências - logs
---------------------------------------------------------------------
PROCEDURE PKB_EXCLUIR_LOG( EN_REFERENCIA_ID  IN LOG_GENERICO.REFERENCIA_ID%TYPE
                         , EV_OBJ_REFERENCIA IN LOG_GENERICO.OBJ_REFERENCIA%TYPE ) IS
BEGIN
   --
   delete from log_generico lg
    where lg.referencia_id  = en_referencia_id
      and lg.obj_referencia = ev_obj_referencia;
   --
   commit;
   --
EXCEPTION
   when others then
      raise_application_error (-20101, 'Problemas em pk_valid_atual_param_pc.pkb_excluir_log - excluir log/inconsistência (referencia_id = '||en_referencia_id||
                                       ' objeto = '||ev_obj_referencia||').');
END PKB_EXCLUIR_LOG;

---------------------------------------------------------------------------------------------------------------------------------------------------
-- Processo para validar nos documentos relacionados aos blocos  A, C, D, F e I, a ausência e atualização dos planos de contas e centros de custos
-- Rotina a ser executada através da tela/portal/menu: Sped/PIS-COFINS/Validação e Atualização dos Registros
-- Parâmetros de entrada:
-- en_validatualparampc_id: tabela valid_atual_param_pc, coluna id.
-- en_empresa_id: tabela valid_atual_param_pc, coluna empresa_id.
-- ed_dt_ini: tabela valid_atual_param_pc, coluna dt_ini.
-- ed_dt_final: tabela valid_atual_param_pc, coluna dt_final.
-- en_dm_consol: tabela valid_atual_param_pc, coluna dm_consol.
---------------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE PKB_VALIDAR_ATUALIZAR( EN_VALIDATUALPARAMPC_ID IN VALID_ATUAL_PARAM_PC.ID%TYPE ) IS
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico.id%type := null;
   --
   cursor c_valid is
      select va.*
        from valid_atual_param_pc va
       where va.id = en_validatualparampc_id;
   --
BEGIN
   --
   vn_fase := 1;
   --
   pkb_excluir_log( en_referencia_id  => en_validatualparampc_id
                  , ev_obj_referencia => 'VALID_ATUAL_PARAM_PC' );
   --
   vn_fase := 2;
   --
   gv_obj_referencia := 'VALID_ATUAL_PARAM_PC';
   gn_referencia_id  := en_validatualparampc_id;
   gv_mensagem_log   := 'Validação nos documentos relacionados aos blocos  A, C, D, F e I: ausência e atualização dos planos de contas e centros de custos.';
   --
   if nvl(en_validatualparampc_id,0) = 0 then
      --
      vn_fase := 3;
      --
      gv_resumo_log := 'O identificador para validar os documentos relacionados aos blocos  A, C, D, F e I, deve ser informado para que a validação seja efetuada.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => gv_resumo_log
                                       , en_tipo_log       => erro_de_validacao
                                       , en_referencia_id  => null
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => null );
      --
   else -- nvl(en_validatualparampc_id,0) <> 0
      --
      vn_fase := 4;
      --
      gt_row_valid_atual_param_pc := null;
      open c_valid;
      fetch c_valid into gt_row_valid_atual_param_pc;
      close c_valid;
      --
      vn_fase := 5;
      --
      gv_resumo_log := 'Início do processo (identificador = '||en_validatualparampc_id||').';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => gv_resumo_log
                                       , en_tipo_log       => erro_inform_geral -- 35-Informação Geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
      gv_resumo_log := null;
      vn_fase := 6;
      --
      if nvl(gt_row_valid_atual_param_pc.id,0) = 0 then
         --
         vn_fase := 7;
         --
         gv_resumo_log := 'O identificador para validar os documentos relacionados aos blocos  A, C, D, F e I, não foi encontrado (ID = '||
                          en_validatualparampc_id||'). Para que a validação seja efetuada, verifique as informações.';
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                          , ev_mensagem       => gv_mensagem_log
                                          , ev_resumo         => gv_resumo_log
                                          , en_tipo_log       => erro_de_validacao
                                          , en_referencia_id  => null
                                          , ev_obj_referencia => gv_obj_referencia
                                          , en_empresa_id     => null );
         --
      else
         --
         vn_fase := 8;
         --
         if gt_row_valid_atual_param_pc.dt_exec is not null then
            --
            vn_fase := 9;
            --
            gv_resumo_log := 'O período informado para validação e atualização dos registros já foi executado. Favor criar um novo período. Data de execução: '||
                             to_char(gt_row_valid_atual_param_pc.dt_exec,'dd/mm/rrrr')||'.';
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                             , ev_mensagem       => gv_mensagem_log
                                             , ev_resumo         => gv_resumo_log
                                             , en_tipo_log       => erro_de_validacao
                                             , en_referencia_id  => gn_referencia_id
                                             , ev_obj_referencia => gv_obj_referencia
                                             , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
            --
         else -- gt_row_valid_atual_param_pc.dt_exec is null
            --
            vn_fase := 10;
            -- Validar os parâmetros cadastrados com relação as datas inicial e final 
            -- Não é permitido incluir períodos sendo que o anterior está sem data de finalização
            pkb_val_per;
            --
            vn_fase := 11;
            --
            if gv_resumo_log is null then
               --
               vn_fase := 12;
               -- Validar/Atualizar os documentos fiscais - planos de contas
               pkb_val_atu_pc;
               --
               vn_fase := 13;
               -- Validar/Atualizar os documentos fiscais - centros de custos
               pkb_val_atu_cc;
               --
            end if;
            --
         end if;
         --
      end if; -- gt_row_valid_atual_param_pc.id = 0
      --
   end if; -- nvl(en_validatualparampc_id,0) = 0
   --
   vn_fase := 14;
   --
   if gv_resumo_log is null then
      --
      vn_fase := 15;
      --
      begin
         update valid_atual_param_pc va
            set va.dt_exec = sysdate
          where va.id = gt_row_valid_atual_param_pc.id;
      exception
         when others then
            gv_resumo_log := 'Problemas ao alterar a data de execução do identificador = '||gt_row_valid_atual_param_pc.id||'. Erro = '||sqlerrm;
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                             , ev_mensagem       => gv_mensagem_log
                                             , ev_resumo         => gv_resumo_log
                                             , en_tipo_log       => erro_de_sistema
                                             , en_referencia_id  => gn_referencia_id
                                             , ev_obj_referencia => gv_obj_referencia
                                             , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      end;
      --
   else -- gv_resumo_log is not null
      --
      gv_resumo_log := 'Processo (identificador = '||en_validatualparampc_id||'), não finalizado devido aos logs/inconsistências encontradas. Verifique.';
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => gv_resumo_log
                                       , en_tipo_log       => erro_inform_geral -- 35-Informação Geral
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia
                                       , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
      --
   end if; -- gv_resumo_log is null
   --
   vn_fase := 16;
   --
   gv_resumo_log := 'Término do processo (identificador = '||en_validatualparampc_id||').';
   pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                    , ev_mensagem       => gv_mensagem_log
                                    , ev_resumo         => gv_resumo_log
                                    , en_tipo_log       => erro_inform_geral -- 35-Informação Geral
                                    , en_referencia_id  => gn_referencia_id
                                    , ev_obj_referencia => gv_obj_referencia
                                    , en_empresa_id     => gt_row_valid_atual_param_pc.empresa_id );
   --
   vn_fase := 17;
   --
   commit;
   --
EXCEPTION
   when others then
      --
      gv_resumo_log := 'Erro na pk_valid_atual_param_pc.pkb_validar_atualizar fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                          , ev_mensagem       => gv_mensagem_log
                                          , ev_resumo         => gv_resumo_log
                                          , en_tipo_log       => erro_de_sistema
                                          , en_referencia_id  => en_validatualparampc_id
                                          , ev_obj_referencia => 'VALID_ATUAL_PARAM_PC'
                                          , en_empresa_id     => null );
      exception
         when others then
            null;
      end;
      --
END PKB_VALIDAR_ATUALIZAR;

----------------------------------------------------------------------------------------------------------------------------------------------------------

END PK_VALID_ATUAL_PARAM_PC;
/
