create or replace package body csf_own.pk_arq_nfs_cidade is
--
---------------------------------------------------------------------------------------------------------------------
--| Especificação da package de Geração de Arquivo de Nota Fiscal de Serviços por cidade 
---------------------------------------------------------------------------------------------------------------------
--
-- Procedimento grava as informações do arquivo
procedure pkb_grava_estrarqnfscidade is
   --
   vn_fase  number := 0;
   pragma   autonomous_transaction;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(vt_estr_arq_nfs_cidade.count,0) > 0 then
      --
      vn_fase := 2;
      --
      forAll i in 1 .. vt_estr_arq_nfs_cidade.count
         insert into estr_arq_nfs_cidade values vt_estr_arq_nfs_cidade(i);
      --
      vn_fase := 3;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_grava_estrarqnfscidade ('||vn_fase||'): '||sqlerrm);
end pkb_grava_estrarqnfscidade;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento que armazena a estrutura do arquivo
procedure pkb_armaz_estrarqnfscidade ( el_conteudo  in estr_arq_nfs_cidade.conteudo%type
                                     )
is
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if el_conteudo is not null then
      --
      vn_fase := 2;
      --
      i := nvl(vt_estr_arq_nfs_cidade.count,0) + 1;
      --
      vn_fase := 3;
      --
      select estrarqnfscidade_seq.nextval
        into vt_estr_arq_nfs_cidade(i).id
        from dual;
      --
      vn_fase := 4;
      --
      vt_estr_arq_nfs_cidade(i).empresa_id  := gn_empresa_id;
      vt_estr_arq_nfs_cidade(i).usuario_id  := gn_usuario_id;
      vt_estr_arq_nfs_cidade(i).sequencia   := nvl(vt_estr_arq_nfs_cidade.count,0) + 1;
      vt_estr_arq_nfs_cidade(i).conteudo    := el_conteudo || FINAL_DE_LINHA;
      --
   end if;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_armaz_estrarqnfscidade ('||vn_fase||'): '||sqlerrm);
end pkb_armaz_estrarqnfscidade;

---------------------------------------------------------------------------------------------------------------------
-- Função para Buscar o código SIAFI apartir do código IBGE cidade
function fkg_ibge_cid_tipo_cod_arq ( en_ibge_cidade in cidade.ibge_cidade%type
                                   , en_cd_tipo_cod_arq in tipo_cod_arq.cd%type
                                   ) return cidade_tipo_cod_arq.cd%type is
   --
   vn_fase                          number := null;
   vn_cidade_id                     cidade.id%type;
   vn_tipocodarq_id                 tipo_cod_arq.id%type;
   vv_cidadetipocodarq_cd           cidade_tipo_cod_arq.cd%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_ibge_cidade,0) <> 0 and nvl(en_cd_tipo_cod_arq,0) <> 0 then
      --
      vn_fase := 2;
      --
      select c.id
        into vn_cidade_id
        from cidade c
       where c.ibge_cidade = en_ibge_cidade;
      --
      vn_fase := 3;
      --
      select t.id
        into vn_tipocodarq_id
        from tipo_cod_arq t
       where t.cd = en_cd_tipo_cod_arq;
      --
      vn_fase := 4;
      --
      if nvl(vn_cidade_id,0) <> 0 and nvl(vn_tipocodarq_id,0) <> 0 then
         --
         vn_fase := 5;
         --
         vv_cidadetipocodarq_cd := pk_csf.fkg_cd_cidade_tipo_cod_arq( en_cidade_id => vn_cidade_id
                                                                    , en_tipocodarq_id => vn_tipocodarq_id );
         --
         vn_fase := 6;
         --
         return vv_cidadetipocodarq_cd;
         --
      end if;
      --
   end if;
   --
   return null;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.fkg_ibge_cid_tipo_cod_arq fase ('||vn_fase||'): '||sqlerrm);
end fkg_ibge_cid_tipo_cod_arq;

---------------------------------------------------------------------------------------------------------------------
-- Função para validar valores globais
function fkg_valida_param ( en_empresa_id  in estr_arq_nfs_cidade.empresa_id%type
                          , en_usuario_id  in estr_arq_nfs_cidade.usuario_id%type
                          , en_cidade_id   in cidade.id%type
                          , en_dm_ind_emit in nota_fiscal.dm_ind_emit%type
                          )
         return number is
   --
   vn_fase          number := 0;
   vn_dummy         number := 0;
   vv_usuario_nome  neo_usuario.nome%type;
   --
begin
   --
   vn_fase := 1;
   -- empresa válida
   if pk_csf.fkg_empresa_id_valido ( en_empresa_id ) then
      gn_empresa_id := en_empresa_id;
   else
      vn_dummy := 1;
   end if;
   --
   vn_fase := 2;
   -- valida usuário
   vv_usuario_nome := pk_csf.fkg_usuario_nome ( en_usuario_id => en_usuario_id );
   --
   vn_fase := 3;
   --
   if trim(vv_usuario_nome) is not null then
      gn_usuario_id := en_usuario_id;
   else
      vn_dummy := 1;
   end if;
   --
   vn_fase := 4;
   --
   gv_ibge_cidade := pk_csf.fkg_ibge_cidade_id ( en_cidade_id => en_cidade_id );
   --
   vn_fase := 5;
   --
   if trim(gv_ibge_cidade) is null then
      vn_dummy := 1;
   else
      gn_cidade_id   := en_cidade_id;
   end if;
   --
   vn_fase := 6;
   --
   if nvl(en_dm_ind_emit,-1) in (0, 1) then
      gn_dm_ind_emit := en_dm_ind_emit;
   else
      vn_dummy := 1;
   end if;
   --
   vn_fase := 7;
   -- recupera a data de escrituação para recuperação dos documentos fiscais
   gn_dm_dt_escr_dfepoe := pk_csf.fkg_dmdtescrdfepoe_empresa( en_empresa_id => en_empresa_id );
   --
   vn_fase := 8;
   --
   return vn_dummy;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.fkg_valida_param fase ('||vn_fase||'): '||sqlerrm);
end fkg_valida_param;

---------------------------------------------------------------------------------------------------------------------
-- Função para fazer a combinação da NF com a tabela 2 do layout de Remessa (GissOnline)
function fkg_combinacao_indicador ( en_notafiscal_id  in  nota_fiscal.id%type ) return number is
--
   vn_tipo_layout      number;
--
begin
   --
   begin
      select 1 
        into vn_tipo_layout
        from nota_fiscal nf
           , fisica f
       where nf.id           = en_notafiscal_id
         and nf.pessoa_id    = f.pessoa_id;
   exception
      when others then
         null;
   end;
   -- 
   begin
      select distinct(2)
        into vn_tipo_layout
        from nota_fiscal     nf
           , item_nota_fiscal  inf
           , itemnf_compl_serv ics
       where nf.id               = en_notafiscal_id
         and nf.id               = inf.notafiscal_id
         and ics.itemnf_id       = inf.id
         and ics.dm_loc_exe_serv = 1; -- Executado no Exterior
   exception
      when others then
         null;
   end;
   --
   begin
      select 3
        into vn_tipo_layout
        from nota_fiscal nf
           , juridica    j
       where nf.id          = en_notafiscal_id
         and nf.pessoa_id   = j.pessoa_id;
   exception
      when others then
         null;
   end;
   --
   return vn_tipo_layout;
   --
EXCEPTION
 when others then
    raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.fkg_combinacao_indicador '||sqlerrm); 
end;

---------------------------------------------------------------------------------------------------------------------
-- Função para fazer a conversão conforme solicitado para a cidade de Belo Horizonte / MG
function fkg_conversao_serie ( ev_serie in nota_fiscal.serie%type  ) return number is
 --
begin
     --
     if ev_serie = 'A' then
     --
       return 2;                           
     --
     elsif ev_serie = 'AA' then
     --
       return 3;
     --
     elsif ev_serie = 'B' then
     --
       return 4;
     --
     elsif ev_serie = 'C' then
     --
       return 5;
     --
     elsif ev_serie = 'D' then
     --
       return 6;
     --
     elsif ev_serie = 'E' then
     --
       return 7;
     --
     elsif ev_serie = 'F' then
     --
       return 8;
     --
     elsif ev_serie = 'G' then
     --
       return 9;
     --
     elsif ev_serie = 'H' then
     --
       return 10;
     --
     elsif ev_serie = 'I' then
     --
       return 11;
     --
     elsif ev_serie = 'J' then
     --
       return 12;
     --
     elsif ev_serie = 'K' then
     --
       return 13;
     --
     elsif ev_serie = 'L' then
     --
       return 14;
     --     
     elsif ev_serie = 'M' then
     --
       return 15;
     --
     elsif ev_serie = 'N' then
     --
       return 16;
     --
     elsif ev_serie = 'O' then
     --
       return 17;
     --
     elsif ev_serie = 'P' then
     --
       return 18;
     --
     elsif ev_serie = 'Q' then
     --
       return 19;
     --
     elsif ev_serie = 'R' then
     --
       return 20;
     --
     elsif ev_serie = 'S' then
     --
       return 21;
     --
     elsif ev_serie = 'T' then
     --
       return 22;
     --
     elsif ev_serie = 'U' then
     --
       return 23;
     --
     elsif ev_serie = 'V' then
     --
       return 24;
     --
     elsif ev_serie = 'W' then
     --
       return 25;
     --
     elsif ev_serie = 'X' then
     --
       return 26;
     --
     elsif ev_serie = 'Y' then
     --
       return 27;
     --
     elsif ev_serie = 'Z' then
     --
       return 28;
     --
     else
     --
     --| verifica se a seria é numerica
     if pk_csf.fkg_is_numerico( ev_serie ) then
        --
        if to_number(ev_serie) = 0 then
        --
           return 0;
        --
        elsif to_number(ev_serie) >= 29 and to_number(ev_serie) <= 999 then
        --
           return to_number(ev_serie) + 28;
        --
        else
           return 1;
        end if;
        --
     else
        return 1;
     end if;
     --
     end if;
 --
EXCEPTION
 when others then
    raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.fkg_conversao_serie "'||ev_serie||'"'||sqlerrm);
end fkg_conversao_serie;
--
-- ================================================================================================================== --
-- Função para retornar a data de vencimento da primeira parcela de cobrança da nota fiscal
--
function fkg_dt_vencto_nf ( en_notafiscal_id in nota_fiscal.id%type ) return date is
--
   vv_nro_parc  nfcobr_dup.nro_parc%type;
   vd_dt_vencto nfcobr_dup.dt_vencto%type;
--
begin
   --
   begin
      select min(nd.nro_parc)
           , nd.dt_vencto
       into vv_nro_parc
          , vd_dt_vencto
       from nota_fiscal_cobr nc
          , nfcobr_dup       nd
      where nd.nfcobr_id     = nc.id
        and nc.notafiscal_id = en_notafiscal_id
     group by nd.dt_vencto;
   exception
      when others then
         vv_nro_parc  := null;
         vd_dt_vencto := null;
   end;
   --
   return vd_dt_vencto;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.fkg_dt_vencto_nf '||sqlerrm);
end fkg_dt_vencto_nf;
--
-- ================================================================================================================== --
--
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Contagem / MG
procedure pkb_gera_arq_cid_3118601 is
   --
   vn_fase                 number := 0;
   --
   vv_cpf_cnpj_cont        varchar2(14);
   vv_cnpj_tomador         varchar2(14);
   vv_nome                 pessoa.nome%type;
   vv_descr_cid            cidade.descr%type;
   vv_sg_estado            estado.sigla_estado%type;
   vn_vl_aliq              imp_itemnf.aliq_apli%type;
   vn_vl_base_calc         imp_itemnf.vl_base_calc%type;
   vn_vl_iss_ret           imp_itemnf.vl_imp_trib%type;
   vv_simpl_nac            valor_tipo_param.cd%type := null;
   vn_cont_n               number := 0;
   vn_cont_e               number := 0;
   vn_total_bruto          number := 0;
   --
   vn_sum_vl_item_bruto    item_nota_fiscal.vl_item_bruto%type;
   vn_sum_vl_iss_ret       imp_itemnf.vl_imp_trib%type;
   vn_sum_vl_aliq          imp_itemnf.aliq_apli%type;
   vn_pessoa_id            pessoa.id%type;
   vv_chave_aut_prest_nfs  empresa.chave_aut_prest_nfs%type;
   vv_im                   juridica.im%type;
   --
   cursor c_nfs is
   select nf.id         notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss) dt_emiss
        , nf.pessoa_id
        , nf.empresa_id
        , ncs.dm_nat_oper
        , sum(inf.vl_item_bruto)  vl_item_bruto
        , inf.cd_lista_serv
        , nft.vl_total_nf
        , nft.vl_ret_iss
        , ics.cidade_id
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , nf_compl_serv  ncs
        , item_nota_fiscal inf
        , itemnf_compl_serv ics
        , nota_fiscal_total nft
        , nota_fiscal_cobr nfc
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4 
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id
      and nf.id              = ncs.notafiscal_id (+)
      and nf.id              = inf.notafiscal_id
      and inf.id             = ics.itemnf_id (+)
      and nft.notafiscal_id  = nf.id
      and nfc.notafiscal_id  = nf.id
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
 group by nf.id
        , nf.nro_nf
        , nf.serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss)
        , nf.pessoa_id
        , nf.empresa_id
        , ncs.dm_nat_oper
        , inf.cd_lista_serv
        , inf.descr_item
        , nft.vl_total_nf
        , nft.vl_ret_iss
        , nfc.nro_fat
        , ics.cidade_id;
   --
begin
   --
   vn_fase := 1;
   --
   --Registro H
   --
   gl_conteudo := null;
   gl_conteudo := ''''||3||'''' || ',' ; --Versão do leiaute do arquivo
   gl_conteudo := gl_conteudo || ''''||'H'||'''' || ','; --Identificação do Registro do arquivo
   gl_conteudo := gl_conteudo || ''''||pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => gn_empresa_id )||'''' || ','; --CNPJ do declarante
   gl_conteudo := gl_conteudo || to_char(sysdate, 'yyyy') || ','; --Ano da referência
   gl_conteudo := gl_conteudo || to_char(sysdate, 'mm') || ',';  --Mês da referência
   gl_conteudo := gl_conteudo || 0 || ','; --Indicação se a declaração é original/inicial (zero) ou complementar (de 1 a 49)
   --
   vn_fase := 1.1;
   --
   begin
      --
      select c.pessoa_id
           , e.chave_aut_prest_nfs
           , j.im
        into vn_pessoa_id
           , vv_chave_aut_prest_nfs
           , vv_im
        from empresa e
           , contador c
           , contador_empresa ce
           , juridica j
       where e.id = gn_empresa_id
         and ce.contador_id = c.id
         and sysdate between nvl(ce.dt_ini,sysdate) and nvl(ce.dt_fin,sysdate)
         and e.id = ce.empresa_id
         and e.pessoa_id = j.pessoa_id;
      --
   exception
    when others then
     vn_pessoa_id           := null;
     vv_chave_aut_prest_nfs := null;
     vv_im                  := null;
   end;
   --
   gl_conteudo := gl_conteudo || vv_chave_aut_prest_nfs || ','; --Código de acesso ao sistema
   gl_conteudo := gl_conteudo || ''''||pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => vn_pessoa_id )||'''' || ',';
   gl_conteudo := gl_conteudo || vv_im;
   --
   vn_fase := 2;
   --
   begin
      --
      select ( rpad(f.num_cpf, 9, ' ') || rpad(f.dig_cpf, 2, ' ') )
        into vv_cpf_cnpj_cont
        from contador_empresa ce
           , contador         c
           , pessoa           p
           , fisica           f
       where ce.empresa_id  = gn_empresa_id --rec.empresa_id
         and ce.dm_situacao = 1 -- 0-inativo, 1-ativo
         and c.id           = ce.contador_id
         and p.id           = c.pessoa_id
         and f.pessoa_id    = p.id;
   exception
      when others then
         --
         vv_cpf_cnpj_cont  := null;
         --
   end;
   --
   vn_fase := 3;
   --
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_fase := 4;
   --
   for rec in c_nfs loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_fase := 5;
      --
      begin
         select p.nome
              , c.descr
              , e.sigla_estado
           into vv_nome
              , vv_descr_cid
              , vv_sg_estado
           from pessoa p
              , fisica f
              , juridica j
              , cidade c
              , estado e
          where p.id           = rec.pessoa_id
            and f.pessoa_id(+) = p.id
            and j.pessoa_id(+) = p.id
            and p.cidade_id    = c.id
            and c.estado_id    = e.id;
      exception
         when others then
            vv_nome       := null;
            vv_descr_cid  := null;
            vv_sg_estado  := null;

      end;
      --
      vn_fase := 6;
      --
      vv_cnpj_tomador := pk_csf.fkg_cnpjcpf_pessoa_id( en_pessoa_id => rec.pessoa_id );
      --
      vn_fase := 7;
      --
      vn_cont_n := vn_cont_n + 1;
      --
      vn_total_bruto := rec.vl_item_bruto + vn_total_bruto;
      --
      --Registro R
      gl_conteudo := null;
      gl_conteudo := ''''||3||'''' || ',';
      gl_conteudo := gl_conteudo || ''''||'N'||'''' ||',';
      gl_conteudo := gl_conteudo || ''''||rec.serie||'''' || ',';
      gl_conteudo := gl_conteudo || ''''||'R'||'''' || ',';
      gl_conteudo := gl_conteudo || ''''||'N'||'''' || ',';
      gl_conteudo := gl_conteudo || rec.nro_nf || ',';
      gl_conteudo := gl_conteudo || to_char(rec.dt_emiss,'dd/mm/yyyy') || ',';
      gl_conteudo := gl_conteudo || ''''||vv_cnpj_tomador||'''' || ',';
      gl_conteudo := gl_conteudo || pk_csf.fkg_formata_num(nvl(rec.vl_item_bruto, 0), '9999999999999.99') || ',';
      --
      vn_fase := 8;
      --
      if nvl(rec.dm_nat_oper,0) = 1 then
         --
         gl_conteudo := gl_conteudo || ''''|| 'S' ||'''' || ',';
         --
      elsif nvl(rec.dm_nat_oper,0) = 2 then
         --
         gl_conteudo := gl_conteudo || ''''|| 'F' ||'''' || ',';
         --
      elsif nvl(rec.dm_nat_oper,0) in (3,4,5,6,8) then
         --
         gl_conteudo := gl_conteudo || ''''|| 'I' ||'''' || ',';
         --
      elsif nvl(rec.dm_nat_oper,0) = 7 then
         --
         gl_conteudo := gl_conteudo || ''''|| 'P' ||'''' || ',';
         --
      else
         --
         gl_conteudo := gl_conteudo || '''' || '''' || ',';
         --
      end if;
      --
      vn_fase := 9;
      --
      gl_conteudo := gl_conteudo || ''''||vv_nome||'''' || ',';
      gl_conteudo := gl_conteudo || ''''||vv_descr_cid||'''' || ',';
      gl_conteudo := gl_conteudo || ''''||vv_sg_estado||'''';
      --
      vn_sum_vl_item_bruto := nvl(vn_sum_vl_item_bruto,0) + nvl(rec.vl_item_bruto,0);
      -- Armazena a estrutura do arquivo.
      --
      vn_fase := 8;
      --
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
      vn_fase := 9;
      --
      --Registro I
      --
      begin
         --
         select ii.aliq_apli
              , sum(ii.vl_base_calc)
              , sum(ii.vl_imp_trib)
           into vn_vl_aliq
              , vn_vl_base_calc
              , vn_vl_iss_ret
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and ii.itemnf_id      = inf.id
            and ii.dm_tipo        = 1 -- Retenção
            and ti.id             = ii.tipoimp_id
            and ti.cd             = '6'
          group by ii.aliq_apli; -- ISS
      exception
         when others then
            vn_vl_aliq       := null;
            vn_vl_base_calc  := null;
            vn_vl_iss_ret    := null;
      end;
      --
      vn_fase := 10;
      --
      gl_conteudo := ''''||3||'''' || ',';
      gl_conteudo := gl_conteudo || ''''||'I'||'''' || ',';
      gl_conteudo := gl_conteudo || nvl(rec.cd_lista_serv, 0) || ',';
      gl_conteudo := gl_conteudo || pk_csf.fkg_formata_num(nvl(vn_vl_base_calc, 0), '9999999999999.99') || ',';
      gl_conteudo := gl_conteudo || pk_csf.fkg_formata_num(nvl(vv_simpl_nac, 0), '99.9999') || ','; -- Enquadramento no Simples Nacional do Tomador de Serviços
      gl_conteudo := gl_conteudo || pk_csf.fkg_formata_num(nvl(vn_vl_aliq, 0), '99.9999') || ',';
      gl_conteudo := gl_conteudo || pk_csf.fkg_formata_num(nvl(vn_vl_iss_ret, 0), '9999999999999.99');
      --
      vn_sum_vl_iss_ret := nvl(vn_sum_vl_iss_ret,0) + nvl(vn_vl_iss_ret,0);
      --
      vn_sum_vl_aliq    := nvl(vn_sum_vl_aliq,0) + nvl(vn_vl_aliq,0);
      --
      -- Armazena a estrutura do arquivo.
      --
      vn_fase := 11;
      --
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
      vn_fase := 12;
      --
   end loop;
   --
   --Registro T
   --
   gl_conteudo := ''''||3||'''' || ',';
   gl_conteudo := gl_conteudo || ''''||'T'||'''' || ',';
   gl_conteudo := gl_conteudo || nvl(vn_cont_n, 0) || ',';
   gl_conteudo := gl_conteudo || nvl(null, 0) || ',';
   gl_conteudo := gl_conteudo || pk_csf.fkg_formata_num(nvl(vn_sum_vl_item_bruto, 0), '9999999999999.99') || ',';
   gl_conteudo := gl_conteudo || pk_csf.fkg_formata_num(nvl(vn_sum_vl_iss_ret, 0), '9999999999999.99') || ',';
   gl_conteudo := gl_conteudo || pk_csf.fkg_formata_num(nvl(vn_sum_vl_aliq, 0), '9999999999999.99') || ',';
   gl_conteudo := gl_conteudo || nvl(vn_cont_n, 0) || ',';
   gl_conteudo := gl_conteudo || pk_csf.fkg_formata_num(nvl(vn_sum_vl_item_bruto, 0), '9999999999999.99') || ',';
   gl_conteudo := gl_conteudo || pk_csf.fkg_formata_num(nvl(vn_sum_vl_aliq, 0), '9999999999999.99');
   --
   -- Armazena a estrutura do arquivo.
   --
   vn_fase := 13;
   --
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
exception
   when others then
      --
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_3118601 fase ('||vn_fase||'): '||sqlerrm);
      --
end pkb_gera_arq_cid_3118601;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Cabedelo / PB
procedure pkb_gera_arq_cid_2503209 is
   --
   vn_fase                 number := 0;
   --
   vn_cont                 number := 0;
   vn_cont_toma            number := 0;
   vn_cont_doc             number := 0;
   --
   vv_nome                 pessoa.nome%type;
   vv_rg                   fisica.rg%type;
   vn_cep                  pessoa.cep%type;
   vv_lograd               pessoa.lograd%type;
   vv_nro                  pessoa.nro%type;
   vv_compl                pessoa.compl%type;
   vv_bairro               pessoa.bairro%type;
   vv_cidade               cidade.descr%type;
   vv_estado               estado.sigla_estado%type;
   vn_pais                 pais.cod_siscomex%type;
   vv_email                pessoa.email%type;
   vv_fone                 pessoa.fone%type;
   vv_fax                  pessoa.fone%type;
   vv_fantasia             pessoa.fantasia%type;
   vn_nat_jur              number(2) := null;
   vv_pass                 varchar2(20) := null;
   vv_org_rg               varchar2(6) := null;
   vv_est_exp              varchar2(2) := null;
   vv_sit_trib             varchar2(3) := null;
   vn_ibge                 cidade.ibge_cidade%type;
   vn_estado               estado.ibge_estado%type;
   vn_vl_aliq              imp_itemnf.aliq_apli%type;
   vn_vl_base_calc         imp_itemnf.vl_base_calc%type;
   vn_vl_iss_ret           imp_itemnf.vl_imp_trib%type;
   vn_base_legal           number(5) := null;
   vn_cont_1               number(5) := null;
   vn_cont_2               number(5) := null;
   vn_cont_3               number(5) := null;
   vn_cont_4               number(5) := null;
   vn_cont_5               number(5) := null;
   vn_cont_6               number(5) := null;
   vn_cont_7               number(5) := null;
   vn_cont_8               number(5) := null;
   vn_cont_9               number(5) := null;
   vn_cont_10              number(5) := null;
   --
   vb_achou                boolean;
   vn_ind                 number;
   --
   type tab_reg_tomador is record ( tpcod      number
                                  , tpnome     varchar2(105)
                                  , tpcpfcnpj  varchar2(14)
                                  , tpIncMun   number(7)
                                  , tpPass     varchar2(20)
                                  , tpRgNu     number(15)
                                  , tpRgOr     varchar2(6)
                                  , tpRgEs     varchar2(2)
                                  , tpCep      varchar2(9)
                                  , tpLogr     varchar2(105)
                                  , tpNume     varchar2(6)
                                  , tpComp     varchar2(45)
                                  , tpBair     varchar2(45)
                                  , tpMuni     varchar2(45)
                                  , tpEsta     varchar2(2)
                                  , tpPais     number(3)
                                  , tpMail     varchar2(60)
                                  , tpTReD     number(2)
                                  , tpTReN     number(8)
                                  , tpTCeD     number(2)
                                  , tpTCeN     number(8)
                                  , tpTCoD     number(2)
                                  , tpTCoN     number(8)
                                  , tpTFaD     number(2)
                                  , tpTFaN     number(8)
                                  , tpNFan     varchar2(105)
                                  , tpInEs     number(20)
                                  , tpNaJu     number(2)
                                  , tpSiTr     varchar2(3)
                                  );
   --
   type t_tab_reg_tomador is table of tab_reg_tomador index by binary_integer;
   vt_tab_reg_tomador   t_tab_reg_tomador;
   --
   type tab_reg_nfse is record ( drcod      number
                               , drPres     number
                               , drTpDo     varchar2(1)
                               , drSeri     varchar2(2)
                               , drSub      varchar2(3)
                               , drNume     number(14)
                               , drData     number(8)
                               , drCSer     number(5)
                               , drVSer     number(11)
                               , drReti     varchar2(1)
                               , drBasC     number(11)
                               , drAliq     number(4)
                               , drVIss     number(11)
                               , drLoEs     number(2)
                               , drLoMu     number(5)
                               );
   --
   type t_tab_reg_nfse is table of tab_reg_nfse index by binary_integer;
   vt_tab_reg_nfse   t_tab_reg_nfse;
   --
   cursor c_nfs is
   select nf.id         notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nf.sub_serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss) dt_emiss
        , nf.pessoa_id
        , nf.empresa_id
        , ncs.dm_nat_oper
        , sum(inf.vl_item_bruto)  vl_item_bruto
        , inf.cd_lista_serv
        , inf.cidade_ibge
        , nft.vl_total_nf
        , nft.vl_ret_iss
        , ics.cidade_id
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , nf_compl_serv  ncs
        , item_nota_fiscal inf
        , itemnf_compl_serv ics
        , nota_fiscal_total nft
        , nota_fiscal_cobr nfc
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id
      and nf.id              = ncs.notafiscal_id (+)
      and nf.id              = inf.notafiscal_id
      and inf.id             = ics.itemnf_id (+)
      and nft.notafiscal_id  = nf.id
      and nfc.notafiscal_id  = nf.id
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
 group by nf.id
        , nf.nro_nf
        , nf.serie
        , nf.sub_serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss)
        , nf.pessoa_id
        , nf.empresa_id
        , ncs.dm_nat_oper
        , inf.cd_lista_serv
        , inf.cidade_ibge
        , inf.descr_item
        , nft.vl_total_nf
        , nft.vl_ret_iss
        , nfc.nro_fat
        , ics.cidade_id;
   --
   cursor c_tom ( en_pessoa_id in pessoa.id%type ) is
   select pe.nome
        , pe.cep
        , pe.lograd
        , pe.nro
        , pe.compl
        , pe.bairro
        , ci.descr  cid_descr
        , es.sigla_estado
        , pa.cod_siscomex
        , pe.email_forn
        , pe.fone
        , pe.fax
        , pe.email
        , ju.ie
        , ju.im
        , pe.fantasia
     from pessoa   pe
        , cidade   ci
        , estado   es
        , juridica ju
        , pais     pa
    where pe.id        = en_pessoa_id
      and ci.id        = pe.cidade_id
      and es.id        = ci.estado_id
      and ju.pessoa_id = pe.id
      and pa.id        = pe.pais_id;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_nfs loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_cont := vn_cont + 1;
      --
      --Registro Tomador
      vn_fase := 2;
      --
      begin
         --
         select fi.rg
           into vv_rg
           from fisica fi
          where fi.pessoa_id = rec.pessoa_id;
         --
      exception
         when others then
            vv_rg := null;
      end;
      --
      vn_fase := 3;
      --
      for rec_tom in c_tom ( rec.pessoa_id ) loop
       exit when c_tom%notfound or (c_tom%notfound) is null;
         --
         vn_fase := 3.1;
         --
         begin
            vb_achou := vt_tab_reg_tomador.exists(rec.pessoa_id);
         exception
          when others then
            vb_achou := false;
         end;
         --
         if not vb_achou then
            --
            vn_fase := 3.2;
            --
            vn_cont_toma := vn_cont_toma + 1;
            --
            begin
               --
               select fi.rg
                 into vt_tab_reg_tomador(rec.pessoa_id).tpRgNu
                 from fisica fi
                where fi.pessoa_id = rec.pessoa_id;
               --
            exception
               when others then
                  vt_tab_reg_tomador(rec.pessoa_id).tpRgNu := null;               --gl_conteudo := gl_conteudo || '<tpRgNu>' || vv_rg || '</tpRgNu>';
            end;
            --
            vn_fase := 3.3;
            --
            vt_tab_reg_tomador(rec.pessoa_id).tpcod     := rec.pessoa_id;
            vt_tab_reg_tomador(rec.pessoa_id).tpnome    := rec_tom.nome;
            vt_tab_reg_tomador(rec.pessoa_id).tpIncMun  := substr(rec_tom.im,1, 7);
            vt_tab_reg_tomador(rec.pessoa_id).tpCep     := substr(rec_tom.cep, 1, 5)||'-'||substr(rec_tom.cep, 6, 8);
            vt_tab_reg_tomador(rec.pessoa_id).tpLogr    := rec_tom.lograd;
            vt_tab_reg_tomador(rec.pessoa_id).tpNume    := substr(rec_tom.nro, 1, 6);
            vt_tab_reg_tomador(rec.pessoa_id).tpComp    := substr(rec_tom.compl, 1, 45);
            vt_tab_reg_tomador(rec.pessoa_id).tpBair    := substr(rec_tom.bairro, 1, 45);
            vt_tab_reg_tomador(rec.pessoa_id).tpMuni    := substr(rec_tom.cid_descr, 1, 45);
            vt_tab_reg_tomador(rec.pessoa_id).tpEsta    := rec_tom.sigla_estado;
            --
            vn_fase := 3.4;
            --
            if rec_tom.cod_siscomex not in ('1058') then
               vt_tab_reg_tomador(rec.pessoa_id).tpPais    := substr(rec_tom.cod_siscomex, 1, 3);
            end if;
            --
            vn_fase := 3.5;
            --
            vt_tab_reg_tomador(rec.pessoa_id).tpMail    := rec_tom.email;
            vt_tab_reg_tomador(rec.pessoa_id).tpTCoN    := substr(rec_tom.fone,length(rec_tom.fone)-7,8);
            vt_tab_reg_tomador(rec.pessoa_id).tpTFaN    := substr(rec_tom.fax,length(rec_tom.fax)-7,8);
            vt_tab_reg_tomador(rec.pessoa_id).tpNFan    := rec_tom.fantasia;
            vt_tab_reg_tomador(rec.pessoa_id).tpInEs    := rec_tom.ie;
            --
            vn_fase := 3.6;
            --
            if nvl(pk_csf.fkg_pessoa_valortipoparam_cd (9, rec.pessoa_id), 0) = 3 then --Normal
               vt_tab_reg_tomador(rec.pessoa_id).tpSiTr := 'NO';
            elsif nvl(pk_csf.fkg_pessoa_valortipoparam_cd (1, rec.pessoa_id), 0) = 1 then --Simples Nacional (0-Não e 1-Sim)
               vt_tab_reg_tomador(rec.pessoa_id).tpSiTr := 'SN';
            elsif nvl(pk_csf.fkg_pessoa_valortipoparam_cd (2, rec.pessoa_id), 0) = 5 then --Microempresário Individual (MEI)
               vt_tab_reg_tomador(rec.pessoa_id).tpSiTr := 'MEI';
            else
               vt_tab_reg_tomador(rec.pessoa_id).tpSiTr := null;
            end if;
            --
            vn_fase := 3.7;
            --
         end if;
         --
      end loop;
      --
      vn_fase := 4;
      --
      --Registro Documento Recebido
      --
      vn_fase := 5;
      --
      begin
         --
        select cid.ibge_cidade
             , es.ibge_estado
          into vn_ibge
             , vn_estado
          from cidade cid
             , pessoa pe
             , estado es
         where cid.id  = pe.cidade_id
           and es.id   = cid.estado_id
           and pe.id   = rec.pessoa_id;
         --
      exception
         when others then
            --
            vn_ibge := null;
            vn_estado := null;
            --
      end;
      --
      vn_fase := 6;
      --
      begin
         --
         select ii.aliq_apli
              , sum(ii.vl_base_calc)
              , sum(ii.vl_imp_trib)
           into vn_vl_aliq
              , vn_vl_base_calc
              , vn_vl_iss_ret
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and ii.itemnf_id      = inf.id
            and ii.dm_tipo        = 1 -- Retenção
            and ti.id             = ii.tipoimp_id
            and ti.cd             = '6'; -- ISS
      exception
         when others then
            vn_vl_aliq       := null;
            vn_vl_base_calc  := null;
            vn_vl_iss_ret    := null;
      end;
      --
      vn_fase := 7;
      --
      begin
         vb_achou := vt_tab_reg_nfse.exists(rec.pessoa_id);
      exception
       when others then
         vb_achou := false;
      end;
      --
      vn_fase := 8;
      --
      if not vb_achou then
         --
         vn_fase := 8.1;
         --
         vt_tab_reg_nfse(rec.notafiscal_id).drCod      := rec.notafiscal_id;
         vt_tab_reg_nfse(rec.notafiscal_id).drPres     := rec.pessoa_id;
         vt_tab_reg_nfse(rec.notafiscal_id).drSeri     := substr(rec.serie, 1, 2);
         vt_tab_reg_nfse(rec.notafiscal_id).drSub      := rec.sub_serie;
         vt_tab_reg_nfse(rec.notafiscal_id).drNume     := rec.nro_nf;
         vt_tab_reg_nfse(rec.notafiscal_id).drData     := to_number(to_char(rec.dt_emiss,'ddmmyyyy'));
         vt_tab_reg_nfse(rec.notafiscal_id).drCSer     := replace(rec.cd_lista_serv,'.','@');
         vt_tab_reg_nfse(rec.notafiscal_id).drVSer     := rec.vl_item_bruto;
         --
         vn_fase := 8.2;
         --
         begin
            --
            select sum(ii.vl_base_calc)
                 , ii.aliq_apli
                 , sum(ii.vl_imp_trib)
              into vt_tab_reg_nfse(rec.notafiscal_id).drBasC
                 , vt_tab_reg_nfse(rec.notafiscal_id).drAliq
                 , vt_tab_reg_nfse(rec.notafiscal_id).drVIss
              from imp_itemnf ii
                 , item_nota_fiscal inf
                 , tipo_imposto     ti
           where inf.notafiscal_id = rec.notafiscal_id
             and ii.itemnf_id      = inf.id
             and ti.id             = ii.tipoimp_id
             and ti.cd             = 6 -- ISS
             and ii.dm_tipo        = 1
           group by ii.aliq_apli; -- Retido
            --
         exception
          when no_data_found then
           vt_tab_reg_nfse(rec.notafiscal_id).drBasC := null;
           vt_tab_reg_nfse(rec.notafiscal_id).drAliq := null;
           vt_tab_reg_nfse(rec.notafiscal_id).drVIss := null;
         end;
         --
         vn_fase := 8.3;
         --
         vt_tab_reg_nfse(rec.notafiscal_id).drLoEs := substr(rec.cidade_ibge, 1, 2);
         vt_tab_reg_nfse(rec.notafiscal_id).drLoMu := substr(rec.cidade_ibge, 3, 7);
         --
      end if;
      --
   end loop;
   --
   vn_fase := 1;
   --
   gl_conteudo := '<?xml version="1.0" encoding="ISO-8859-1" ?>';
   gl_conteudo := gl_conteudo || '<declaracao>';
   --
   vn_fase := 2;
   --
   --Header
   gl_conteudo := gl_conteudo || '<header>';
   gl_conteudo := gl_conteudo || '<heInsc>' || pk_csf.fkg_inscr_mun_empresa ( en_empresa_id => gn_empresa_id ) || '</heInsc>';
   gl_conteudo := gl_conteudo || '<heComp>' || to_char(sysdate,'yyyymm') || '</heComp>';
   gl_conteudo := gl_conteudo || '<heGeDt>' || to_char(sysdate,'ddmmyyyy') || '</heGeDt>';
   gl_conteudo := gl_conteudo || '<heGeHo>' || to_char(sysdate,'hhmmss') || '</heGeHo>';
   gl_conteudo := gl_conteudo || '<heVers>2000</heVers>';
   gl_conteudo := gl_conteudo || '<hePref>CBD</hePref>';
   gl_conteudo := gl_conteudo || '</header>';
   --
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_fase := 3;
   --
   vn_ind := nvl(vt_tab_reg_tomador.first,0);
   --
   vn_fase := 2;
   --
   loop
      --
      vn_fase := 3;
      --
      if nvl(vn_ind,0) = 0 then
         exit;
      end if;
      --
      gl_conteudo := '<tompre>';
      --
      gl_conteudo := gl_conteudo || '<tpCod>' || vt_tab_reg_tomador(vn_ind).tpcod ||'</tpCod>';
      gl_conteudo := gl_conteudo || '<tpNome>'|| vt_tab_reg_tomador(vn_ind).tpnome ||'</tpNome>';
      gl_conteudo := gl_conteudo || '<tpInMu>'|| vt_tab_reg_tomador(vn_ind).tpIncMun ||'</tpInMu>';
      gl_conteudo := gl_conteudo || '<tpRgNu>'|| vt_tab_reg_tomador(vn_ind).tpRgNu ||'</tpRgNu>';
      gl_conteudo := gl_conteudo || '<tpRgOr>'||'</tpRgOr>';
      gl_conteudo := gl_conteudo || '<tpRgEs>'||'</tpRgEs>';
      gl_conteudo := gl_conteudo || '<tpCep>' || vt_tab_reg_tomador(vn_ind).tpCep ||'</tpCep>';
      gl_conteudo := gl_conteudo || '<tpLogr>'|| vt_tab_reg_tomador(vn_ind).tpLogr ||'</tpLogr>';
      --
      if vt_tab_reg_tomador(vn_ind).tpNume is null then
         gl_conteudo := gl_conteudo || '<tpNume>'|| 'S/N' ||'</tpNume>';
      else
         gl_conteudo := gl_conteudo || '<tpNume>'|| vt_tab_reg_tomador(vn_ind).tpNume ||'</tpNume>';
      end if;
      --
      gl_conteudo := gl_conteudo || '<tpComp>'|| vt_tab_reg_tomador(vn_ind).tpComp ||'</tpComp>';
      gl_conteudo := gl_conteudo || '<tpBair>'|| vt_tab_reg_tomador(vn_ind).tpBair ||'</tpBair>';
      gl_conteudo := gl_conteudo || '<tpMuni>'|| vt_tab_reg_tomador(vn_ind).tpMuni ||'</tpMuni>';
      gl_conteudo := gl_conteudo || '<tpEsta>'|| vt_tab_reg_tomador(vn_ind).tpEsta ||'</tpEsta>';
      gl_conteudo := gl_conteudo || '<tpPais>'|| vt_tab_reg_tomador(vn_ind).tpPais ||'</tpPais>';
      gl_conteudo := gl_conteudo || '<tpMail>'|| vt_tab_reg_tomador(vn_ind).tpMail ||'</tpMail>';
      
      gl_conteudo := gl_conteudo || '<tpTReD>'||'</tpTReD>';
      gl_conteudo := gl_conteudo || '<tpTReN>'|| vt_tab_reg_tomador(vn_ind).tpTReN ||'</tpTReN>';
      gl_conteudo := gl_conteudo || '<tpTCeD>'||'</tpTCeD>';
      gl_conteudo := gl_conteudo || '<tpTCeN>'||'</tpTCeN>';
      gl_conteudo := gl_conteudo || '<tpTCoD>'||'</tpTCoD>';
      gl_conteudo := gl_conteudo || '<tpTCoN>'|| vt_tab_reg_tomador(vn_ind).tpTCoN ||'</tpTCoN>';
      gl_conteudo := gl_conteudo || '<tpTFaD>'||'</tpTFaD>';
      gl_conteudo := gl_conteudo || '<tpTFaN>'|| vt_tab_reg_tomador(vn_ind).tpTFaN ||'</tpTFaN>';
      gl_conteudo := gl_conteudo || '<tpNFan>'|| vt_tab_reg_tomador(vn_ind).tpNFan ||'</tpNFan>';
      gl_conteudo := gl_conteudo || '<tpInEs>'|| vt_tab_reg_tomador(vn_ind).tpInEs ||'</tpInEs>';
      gl_conteudo := gl_conteudo || '<tpNaJu>'||'</tpNaJu>';
      gl_conteudo := gl_conteudo || '<tpSiTr>'|| vt_tab_reg_tomador(vn_ind).tpSiTr ||'</tpSiTr>';
      --
      gl_conteudo := gl_conteudo || '</tompre>';
      --
      vn_fase := 6;
      --
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
      vn_fase := 7;
      --
      if vn_ind = vt_tab_reg_tomador.last then
         exit;
      else
         vn_ind := vt_tab_reg_tomador.next(vn_ind);
      end if;
      --
   end loop;
   --
   vn_fase := 7;
   --
   vn_ind := null;
   --
   vn_ind := nvl(vt_tab_reg_nfse.first,0);
   --
   loop
      --
      vn_fase := 3;
      --
      if nvl(vn_ind,0) = 0 then
         exit;
      end if;
      --
      gl_conteudo := '<docrec>';
      --
      gl_conteudo := gl_conteudo || '<drCod>'|| vt_tab_reg_nfse(vn_ind).drCod ||'</drCod>';
      gl_conteudo := gl_conteudo || '<drPres>'|| vt_tab_reg_nfse(vn_ind).drPres ||'</drPres>';
      --
      vn_fase := 11;
      --
      if vt_tab_reg_nfse(vn_ind).drLoMu = '2503209' then
         gl_conteudo := gl_conteudo || '<drTpDo>N</drTpDo>';
      else
         gl_conteudo := gl_conteudo || '<drTpDo>E</drTpDo>';
      end if;
      --
      vn_fase := 12;
      --
      gl_conteudo := gl_conteudo || '<drSeri>' || vt_tab_reg_nfse(vn_ind).drSeri || '</drSeri>';
      gl_conteudo := gl_conteudo || '<drSub>'  || vt_tab_reg_nfse(vn_ind).drSub  || '</drSub>';
      gl_conteudo := gl_conteudo || '<drNume>' || vt_tab_reg_nfse(vn_ind).drNume || '</drNume>';
      gl_conteudo := gl_conteudo || '<drData>' || vt_tab_reg_nfse(vn_ind).drData || '</drData>';
      gl_conteudo := gl_conteudo || '<drCSer>' || vt_tab_reg_nfse(vn_ind).drCSer || '</drCSer>';
      gl_conteudo := gl_conteudo || '<drVSer>' || vt_tab_reg_nfse(vn_ind).drVSer || '</drVSer>';
      --
      if vt_tab_reg_nfse(vn_ind).drVIss > 0 then
         gl_conteudo := gl_conteudo || '<drReti>S</drReti>';
      else
         gl_conteudo := gl_conteudo || '<drReti>N</drReti>';
      end if;
      --
      gl_conteudo := gl_conteudo || '<drBasC>' || vt_tab_reg_nfse(vn_ind).drBasC || '</drBasC>';
      gl_conteudo := gl_conteudo || '<drAliq>' || vt_tab_reg_nfse(vn_ind).drAliq || '</drAliq>';
      gl_conteudo := gl_conteudo || '<drVIss>' || vt_tab_reg_nfse(vn_ind).drVIss || '</drVIss>';
      gl_conteudo := gl_conteudo || '<drBaLe>' || '</drBaLe>';
      gl_conteudo := gl_conteudo || '<drLoEs>' || vt_tab_reg_nfse(vn_ind).drLoEs || '</drLoEs>';
      gl_conteudo := gl_conteudo || '<drLoMu>' || vt_tab_reg_nfse(vn_ind).drLoMu || '</drLoMu>';
      gl_conteudo := gl_conteudo || '</docrec>';
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
      vn_fase := 76;
      --
      if vn_ind = vt_tab_reg_nfse.last then
         exit;
      else
         vn_ind := vt_tab_reg_nfse.next(vn_ind);
      end if;
      --
   end loop;
   --
   vn_fase := 7;
   --
   --Registro Trailer
   --
   vn_cont := vn_cont + 1;
   --
   gl_conteudo := '<trailler>';
   gl_conteudo := gl_conteudo || '<qtRegA>' || (vt_tab_reg_tomador.count + vt_tab_reg_nfse.count) || '</qtRegA>';
   gl_conteudo := gl_conteudo || '<qtToPr>' || vt_tab_reg_tomador.count || '</qtToPr>';
   gl_conteudo := gl_conteudo || '<qtBaLe>' || vn_cont_1 || '</qtBaLe>';
   gl_conteudo := gl_conteudo || '<qtPlCo>' || vn_cont_2 || '</qtPlCo>';
   gl_conteudo := gl_conteudo || '<qtTurm>' || vn_cont_3 || '</qtTurm>';
   gl_conteudo := gl_conteudo || '<qtDoEm>' || vn_cont_4 || '</qtDoEm>';
   gl_conteudo := gl_conteudo || '<qtNoAv>' || vn_cont_5 || '</qtNoAv>';
   gl_conteudo := gl_conteudo || '<qtDoRe>' || vt_tab_reg_nfse.count || '</qtDoRe>';
   gl_conteudo := gl_conteudo || '<qtDedu>' || vn_cont_6 || '</qtDedu>';
   gl_conteudo := gl_conteudo || '<qtSeAu>' || vn_cont_7 || '</qtSeAu>';
   gl_conteudo := gl_conteudo || '<qtInFi>' || vn_cont_8 || '</qtInFi>';
   gl_conteudo := gl_conteudo || '<qtTuDe>' || vn_cont_9 || '</qtTuDe>';
   gl_conteudo := gl_conteudo || '<qtDesM>' || vn_cont_10 || '</qtDesM>';
   gl_conteudo := gl_conteudo || '</trailler>';
   --
   gl_conteudo := gl_conteudo || '</declaracao>';
   --
   vn_fase := 15;
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
exception
   When others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_2503209 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_2503209;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Nova Santa Rita / RS
procedure pkb_gera_arq_cid_4313375
is
   --
   vn_fase             number;
   --
   type tab_reg_h is record ( cnpj_empr            varchar2(14)
                            , ano_ref             number(4)
                            , mes_ref             number(2)
                            , chave_aut_prest_nfs varchar2(255)
                            , cpf_cnpj_contad     varchar2(14)
                            , ie_empresa          varchar2(14)
                            );
   --
   vt_tab_reg_h   tab_reg_h;
   --
    type tab_reg_r is record ( serie          varchar2(3)
                             , nro_nf         number(9)
                             , dt_emiss       date
                             , cpf_cnpj_part  varchar2(14)
                             , vl_item_bruto  number(15,2)
                             , dm_nat_oper    varchar2(1)
                             , razao_soc_part varchar2(70)
                             , cidade_part    varchar2(60)
                             , estado_part    varchar2(60)
                             );
   --
   type t_tab_reg_r is table of tab_reg_r index by binary_integer;
   vt_tab_reg_r   t_tab_reg_r;
   --
   type tab_reg_i is record ( cd_lista_serv  number(5)
                            , vl_base_calc   number(15,2)
                            , aliq_aplic     number(8,4)
                            , vl_imp_trib    number(15,2)
                            );
   --
   type t_tab_reg_i is table of tab_reg_i index by binary_integer;
   vt_tab_reg_i   t_tab_reg_i;
   --
   type tab_reg_t is record ( qtde_tot_reg_n         number(5)
                            , qtde_nfs_rec           number(5)
                            , som_vl_item_bruto_rec  number(15,2)
                            , som_vl_imp_trib_rec    number(15,2)
                            , som_vl_aliq_aplic      number(15,2)
                            );
   --
   vt_tab_reg_t   tab_reg_t;
   --
   vn_ind                   number;
   vb_achou                 boolean;
   --
   cursor c_nfs is
   select nf.id         notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss) dt_emiss
        , nf.pessoa_id
        , nf.empresa_id
        , ncs.dm_nat_oper
        , inf.id  itemnf_id
        , inf.vl_item_bruto
        , inf.cd_lista_serv
        , inf.descr_item
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , nf_compl_serv  ncs
        , item_nota_fiscal inf
        , itemnf_compl_serv ics
        , nota_fiscal_total nft
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id
      and nf.id              = ncs.notafiscal_id (+)
      and nf.id              = inf.notafiscal_id
      and inf.id             = ics.itemnf_id (+)
      and nft.notafiscal_id  = nf.id
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
    order by nf.id;
   --
begin
   --
   vn_fase := 1;
   --
   vt_tab_reg_h := null;
   vt_tab_reg_r.delete;
   vt_tab_reg_i.delete;
   vt_tab_reg_t := null;
   --
   for rec in c_nfs loop
    exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_fase := 2;
      --
      vt_tab_reg_h.cnpj_empr := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => rec.empresa_id );
      vt_tab_reg_h.ano_ref   := to_number(to_char(sysdate,'yyyy'));
      vt_tab_reg_h.mes_ref   := to_number(to_char(sysdate,'mm'));
      --
      begin
         --
         select chave_aut_prest_nfs
           into vt_tab_reg_h.chave_aut_prest_nfs
           from empresa
          where id = rec.empresa_id;
         --
      exception
       when no_data_found then
          vt_tab_reg_h.chave_aut_prest_nfs := null;
      end;
      vn_fase := 2.2;
      --
      vt_tab_reg_t.qtde_tot_reg_n := nvl(vt_tab_reg_t.qtde_tot_reg_n,0) + 1;
      vt_tab_reg_t.qtde_nfs_rec   := nvl(vt_tab_reg_t.qtde_nfs_rec,0) + 1;
      --
      vn_fase := 2.3;
      --
      begin
         --
         select max(pk_csf.fkg_cnpjcpf_pessoa_id (co.pessoa_id ))
           into vt_tab_reg_h.cpf_cnpj_contad
           from contador_empresa ce
              , contador         co
          where ce.empresa_id = rec.empresa_id
            and ce.contador_id = co.id
            and sysdate between nvl(ce.dt_ini,sysdate - 1) and nvl(ce.dt_fin,sysdate + 1);
         --
      exception
       when no_data_found then
          --
          begin
             select max(pk_csf.fkg_cnpjcpf_pessoa_id (co.pessoa_id ))
               into vt_tab_reg_h.cpf_cnpj_contad
               from contador_empresa ce
                  , contador         co
              where ce.empresa_id = rec.empresa_id
                and ce.contador_id = co.id;
          exception
           when others then
              null;
          end;
          --
      end;
      --
      vn_fase := 2.2;
      --
      vt_tab_reg_h.ie_empresa := pk_csf.fkg_inscr_mun_empresa ( en_empresa_id => rec.empresa_id );
      --
      -- Registro R
      vn_fase := 3;
      --
      vt_tab_reg_r(rec.notafiscal_id).serie         := rec.serie;
      vt_tab_reg_r(rec.notafiscal_id).nro_nf        := rec.nro_nf;
      vt_tab_reg_r(rec.notafiscal_id).dt_emiss      := rec.dt_emiss;
      vt_tab_reg_r(rec.notafiscal_id).cpf_cnpj_part := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec.pessoa_id );
      --
      vn_fase := 3.1;
      --
      begin
         --
         select sum(vl_item_bruto)
           into vt_tab_reg_r(rec.notafiscal_id).vl_item_bruto
           from item_nota_fiscal
          where notafiscal_id = rec.notafiscal_id;
         --
      exception
       when no_data_found then
         vt_tab_reg_r(rec.notafiscal_id).vl_item_bruto := null;
      end;
      --
      vt_tab_reg_t.som_vl_item_bruto_rec := nvl(vt_tab_reg_t.som_vl_item_bruto_rec,0) + nvl(vt_tab_reg_r(rec.notafiscal_id).vl_item_bruto,0);
      --
      vn_fase := 3.2;
      --
      vt_tab_reg_r(rec.notafiscal_id).razao_soc_part := substr(pk_csf.fkg_nome_pessoa_id ( rec.pessoa_id ),1,70);
      vt_tab_reg_r(rec.notafiscal_id).estado_part    := pk_csf.fkg_siglaestado_pessoaid ( rec.pessoa_id );
      --
      begin
          --
          select c.descr
            into vt_tab_reg_r(rec.notafiscal_id).cidade_part
            from pessoa p
               , cidade c
            where p.id =  rec.pessoa_id
              and p.cidade_id = c.id;
          --
      exception
       when no_data_found then
         vt_tab_reg_r(rec.notafiscal_id).cidade_part := null;
      end;
      --
      vn_fase := 3.5;
      --
      vt_tab_reg_i(rec.notafiscal_id).cd_lista_serv := rec.cd_lista_serv;
      --
      begin
         --
         select ii.vl_base_calc
              , ii.aliq_apli
              , ii.vl_imp_trib
           into vt_tab_reg_i(rec.notafiscal_id).vl_base_calc
              , vt_tab_reg_i(rec.notafiscal_id).aliq_aplic
              , vt_tab_reg_i(rec.notafiscal_id).vl_imp_trib
           from imp_itemnf ii
              , item_nota_fiscal inf
              , tipo_imposto     ti
          where inf.notafiscal_id = rec.notafiscal_id
            and ii.itemnf_id      = inf.id
            and ti.id             = ii.tipoimp_id
            and ti.cd             = 6 -- ISS
            and ii.dm_tipo        = 1; -- Retido
         --
      exception
       when no_data_found then
         vt_tab_reg_i(rec.notafiscal_id).vl_base_calc := null;
         vt_tab_reg_i(rec.notafiscal_id).aliq_aplic   := null;
         vt_tab_reg_i(rec.notafiscal_id).vl_imp_trib  := null;
      end;
      --
      vt_tab_reg_t.som_vl_imp_trib_rec := nvl(vt_tab_reg_t.som_vl_imp_trib_rec,0) + nvl(vt_tab_reg_i(rec.notafiscal_id).vl_imp_trib,0);
      --
      vt_tab_reg_t.som_vl_aliq_aplic := nvl(vt_tab_reg_t.som_vl_aliq_aplic,0) + nvl(vt_tab_reg_i(rec.notafiscal_id).aliq_aplic,0);
      --
      vn_fase := 3.6;
      --
      if nvl(rec.dm_nat_oper,0) = 1 then
         --
         vt_tab_reg_r(rec.notafiscal_id).dm_nat_oper := 'S';
         --
      elsif nvl(rec.dm_nat_oper,0) = 2 then
         --
         vt_tab_reg_r(rec.notafiscal_id).dm_nat_oper := 'F';
         --
      elsif nvl(rec.dm_nat_oper,0) in (3,4,5,6,8) then
         --
         vt_tab_reg_r(rec.notafiscal_id).dm_nat_oper := 'I';
         --
      elsif nvl(rec.dm_nat_oper,0) = 7 then
         --
         vt_tab_reg_r(rec.notafiscal_id).dm_nat_oper := 'P';
         --
      end if;
      --
   end loop;
   --
   vn_fase := 4;
   --
   gl_conteudo := '''3''' ||',';
   gl_conteudo := gl_conteudo || '''H''' ||',''';
   gl_conteudo := gl_conteudo || vt_tab_reg_h.cnpj_empr ||''',';
   gl_conteudo := gl_conteudo || vt_tab_reg_h.ano_ref ||',';
   gl_conteudo := gl_conteudo || vt_tab_reg_h.mes_ref ||',';
   gl_conteudo := gl_conteudo || '0' ||',';
   gl_conteudo := gl_conteudo || vt_tab_reg_h.chave_aut_prest_nfs ||','''; -- Analisar para criar parâmetro na Empresa
   gl_conteudo := gl_conteudo || vt_tab_reg_h.cpf_cnpj_contad ||''',';
   gl_conteudo := gl_conteudo || vt_tab_reg_h.ie_empresa;
   --
   vn_fase := 4.3;
   --
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_fase := 4.4;
   --
   vn_ind := vt_tab_reg_r.first;
   -- Armazenar
   loop
      --
      vn_fase := 4.1;
      --
      if nvl(vn_ind,0) = 0 then -- índice
         exit;
      end if;
      --
      vn_fase := 4.2;
      --
      gl_conteudo := '''3''' ||',';
      gl_conteudo := gl_conteudo || '''N'''                             ||',''';
      gl_conteudo := gl_conteudo || vt_tab_reg_r(vn_ind).serie          ||''',';
      gl_conteudo := gl_conteudo || '''R'''                             ||',';
      gl_conteudo := gl_conteudo || '''N'''                             ||',';
      gl_conteudo := gl_conteudo || vt_tab_reg_r(vn_ind).nro_nf         ||',';
      gl_conteudo := gl_conteudo || vt_tab_reg_r(vn_ind).dt_emiss       ||',''';
      gl_conteudo := gl_conteudo || vt_tab_reg_r(vn_ind).cpf_cnpj_part  ||''',';
      gl_conteudo := gl_conteudo || trim(replace(nvl(to_char(vt_tab_reg_r(vn_ind).vl_item_bruto, 0), '9999999999990D00'), ',', '.'))||',''';
      gl_conteudo := gl_conteudo || vt_tab_reg_r(vn_ind).dm_nat_oper    ||''',''';
      gl_conteudo := gl_conteudo || vt_tab_reg_r(vn_ind).razao_soc_part ||''',''';
      gl_conteudo := gl_conteudo || vt_tab_reg_r(vn_ind).cidade_part    ||''',''';
      gl_conteudo := gl_conteudo || vt_tab_reg_r(vn_ind).estado_part || '''';
      --
      vn_fase := 4.3;
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
      vb_achou := false;
      --
      begin
         vb_achou := vt_tab_reg_i.exists(vn_ind);
      exception
       when others then
         vb_achou := false;
      end;
      --
      vn_fase := 4.4;
      --
      if vb_achou then
         --
         vn_fase := 4.5;
         --
         gl_conteudo := '''3'''||',';
         gl_conteudo := gl_conteudo || '''I''' ||',';
         gl_conteudo := gl_conteudo || vt_tab_reg_i(vn_ind).cd_lista_serv ||',';
         gl_conteudo := gl_conteudo || trim(replace(to_char(nvl(vt_tab_reg_i(vn_ind).vl_base_calc, 0), '9999999999990D00'), ',', '.'))||',';
         gl_conteudo := gl_conteudo || '0' ||',';
         gl_conteudo := gl_conteudo || trim(replace(to_char(nvl(vt_tab_reg_i(vn_ind).aliq_aplic, 0), '9999999999990D00'), ',', '.'))||',';
         gl_conteudo := gl_conteudo || trim(replace(to_char(nvl(vt_tab_reg_i(vn_ind).vl_imp_trib, 0), '9999999999990D00'), ',', '.'));
         --
      end if;
      --
      vn_fase := 4.6;
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
      if vn_ind = vt_tab_reg_r.last then
         exit;
      else
         vn_ind := vt_tab_reg_r.next(vn_ind);
      end if;
      --
   end loop;
   --
   vn_fase := 5;
   --
   gl_conteudo := '''3''';
   gl_conteudo := gl_conteudo || '''T''' ||',';
   gl_conteudo := gl_conteudo || vt_tab_reg_t.qtde_tot_reg_n ||',';
   gl_conteudo := gl_conteudo || 0 || ',';
   gl_conteudo := gl_conteudo || trim(replace(to_char(nvl(vt_tab_reg_t.som_vl_item_bruto_rec, 0), '9999999999990D00'), ',', '.')) || ',';
   gl_conteudo := gl_conteudo || trim(replace(to_char(nvl(vt_tab_reg_t.som_vl_imp_trib_rec, 0), '9999999999990D00'), ',', '.')) || ',';
   gl_conteudo := gl_conteudo || trim(replace(to_char(nvl(vt_tab_reg_t.som_vl_aliq_aplic, 0), '9999999999990D00'), ',', '.')) || ',';
   gl_conteudo := gl_conteudo || vt_tab_reg_t.qtde_nfs_rec ||',';
   gl_conteudo := gl_conteudo || trim(replace(to_char(nvl(vt_tab_reg_t.som_vl_item_bruto_rec, 0), '9999999999990D00'), ',', '.')) ||',';
   gl_conteudo := gl_conteudo || trim(replace(to_char(nvl(vt_tab_reg_t.som_vl_imp_trib_rec, 0), '9999999999990D00'), ',', '.'));
   --
   vn_fase := 5.1;
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
exception
   when others then
     raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_4313375 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_4313375;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Vitória / ES
procedure pkb_gera_arq_cid_3205309
is
   --
   vn_fase number;
   vn_ind  number;
   vv_cnpj_cpf varchar2(14) := null;
   vn_cod_siscomex  pais.cod_siscomex%type;
   --
   type tab_reg_01 is record ( sigla_decl       varchar2(3)
                             , im               varchar2(14)
                             , mes              varchar2(2)
                             , ano              varchar2(4)
                             , qtde_item_decl   number(15,2)
                             , vl_decl          number(15,2)
                             , vl_iss_ret       number(15,2)
                             , cod_mun          varchar2(5)
                             );
   --
   vt_tab_reg_01 tab_reg_01;
   --
   type tab_reg_02 is record ( nro_doc          number(9)
                             , mod_doc_fisc     varchar2(2)
                             , serie            varchar2(3)
                             , tipo_doc_fisc    varchar2(20)
                             , nro_contr        varchar2(20)
                             , dt_emiss         varchar2(10)
                             , dt_pgto          varchar2(10)
                             , sit_docto        varchar2(20)
                             , aliq_imp         number(5,2)
                             , vl_doc           number(15,2)
                             , vl_glosa         number(15,2)
                             , vl_material      number(15,2)
                             , vl_subempreitada number(15,2)
                             , vl_iss_ret       number(15,2)
                             , cnpj_prest       varchar2(14)
                             , cpf_prest        varchar2(11)
                             );
   --
   type t_tab_reg_02 is table of tab_reg_02 index by binary_integer;
   vt_tab_reg_02   t_tab_reg_02;
   --
   cursor c_nfs is
   select nf.id         notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nvl2(ncs.dt_exe_serv, nf.dt_sai_ent, nf.dt_emiss) dt_emiss
        , nf.pessoa_id
        , nf.empresa_id
        , ncs.dm_nat_oper
        , p.pais_id
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , nf_compl_serv  ncs
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod in ('99', '55')
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id
      and nf.id              = ncs.notafiscal_id (+)
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
      and exists (
                 select 1 
                   from item_nota_fiscal inf
                      , itemnf_compl_serv ics
                      , imp_itemnf ii
                  where 1 = 1
                    and inf.notafiscal_id = nf.id
                    and inf.cd_lista_serv is not null
                    and ics.itemnf_id (+) = inf.id
                    and ii.itemnf_id = inf.id
                    and ii.dm_tipo = 1 -- retido
                    and ii.vl_imp_trib > 0
                    and ii.tipoimp_id in (select id from tipo_imposto where cd = '6')
                 )
    order by nf.id;
   --
   -- Função que retorna o CNPJ do Pais
   function fkg_cnpj_pais ( en_cod_siscomex  pais.cod_siscomex%type )
            return varchar2
   is
      --
      vv_cnpj_pais varchar2(14);
      --
   begin
      --
      if en_cod_siscomex = 230 then
         --
         vv_cnpj_pais := '99999999003107'; -- Alemanha
         --
      elsif en_cod_siscomex = 531 then
         --
         vv_cnpj_pais := '99999999005584'; -- Arábia Saudita
         --
      elsif en_cod_siscomex = 639 then
         --
         vv_cnpj_pais := '99999999000191'; -- Argentina
         --
      elsif en_cod_siscomex = 698 then
         --
         vv_cnpj_pais := '99999999004774'; -- Austrália
         --
      elsif en_cod_siscomex = 728 then
         --
         vv_cnpj_pais := '99999999004340'; -- Áustria
         --
      elsif en_cod_siscomex = 779 then
         --
         vv_cnpj_pais := '99999999002216'; -- Bahamas
         --
      elsif en_cod_siscomex = 876 then
         --
         vv_cnpj_pais := '99999999003298'; -- Bélgica
         --
      elsif en_cod_siscomex = 884 then
         --
         vv_cnpj_pais := '99999999001597'; -- Belize
         --
      elsif en_cod_siscomex = 973 then
         --
         vv_cnpj_pais := '99999999000434'; -- Bolívia
         --
      elsif en_cod_siscomex = 1490 then
         --
         vv_cnpj_pais := '99999999002488'; -- Canada
         --
      elsif en_cod_siscomex = 1589 then
         --
         vv_cnpj_pais := '99999999000787'; -- Chile
         --
      elsif en_cod_siscomex = 1600 then
         --
         vv_cnpj_pais := '99999999004502'; -- China
         --
      elsif en_cod_siscomex = 1694 then
         --
         vv_cnpj_pais := '99999999000515'; -- Colômbia
         --
      elsif en_cod_siscomex = 1872 then
         --
         vv_cnpj_pais := '99999999004936'; -- Coréia do Sul
         --
      elsif en_cod_siscomex = 1961 then
         --
         vv_cnpj_pais := '99999999001325'; -- Costa Rica
         --
      elsif en_cod_siscomex = 1996 then
         --
         vv_cnpj_pais := '99999999001910'; -- Cuba
         --
      elsif en_cod_siscomex = 2321 then
         --
         vv_cnpj_pais := '99999999003700'; -- Dinamarca
         --
      elsif en_cod_siscomex = 2399 then
         --
         vv_cnpj_pais := '99999999000868'; -- Equador
         --
      elsif en_cod_siscomex = 2453 then
         --
         vv_cnpj_pais := '99999999002720'; -- Espanha
         --
      elsif en_cod_siscomex = 2496 then
         --
         vv_cnpj_pais := '99999999002569'; -- EUA
         --
      elsif en_cod_siscomex = 2712 then
         --
         vv_cnpj_pais := '99999999003964'; -- Finlândia
         --
      elsif en_cod_siscomex = 2755 then
         --
         vv_cnpj_pais := '99999999002801'; -- França
         --
      elsif en_cod_siscomex = 6289 then
         --
         vv_cnpj_pais := '99999999003450'; -- Grã Bretanha
         --
      elsif en_cod_siscomex = 3174 then
         --
         vv_cnpj_pais := '99999999001678'; -- Guatemala
         --
      elsif en_cod_siscomex = 3379 then
         --
         vv_cnpj_pais := '99999999000949'; -- Guiana
         --
      elsif en_cod_siscomex = 3255 then
         --
         vv_cnpj_pais := '99999999001163'; -- Guiana Francesa
         --
      elsif en_cod_siscomex = 3417 then
         --
         vv_cnpj_pais := '99999999002054'; -- Haiti
         --
      elsif en_cod_siscomex = 5738 then
         --
         vv_cnpj_pais := '99999999003379'; -- Holanda
         --
      elsif en_cod_siscomex = 3450 then
         --
         vv_cnpj_pais := '99999999001759'; -- Honduras
         --
      elsif en_cod_siscomex = 3557 then
         --
         vv_cnpj_pais := '99999999004260'; -- Hungria
         --
      elsif en_cod_siscomex = 3654 then
         --
         vv_cnpj_pais := '99999999005150'; -- Indonésia
         --
      elsif en_cod_siscomex = 3751 then
         --
         vv_cnpj_pais := '99999999003530'; -- Irlanda
         --
      elsif en_cod_siscomex = 3832 then
         --
         vv_cnpj_pais := '99999999005665'; -- Israel
         --
      elsif en_cod_siscomex = 3867 then
         --
         vv_cnpj_pais := '99999999003026'; -- Itália
         --
      elsif en_cod_siscomex = 3913 then
         --
         vv_cnpj_pais := '99999999001830'; -- Jamaica
         --
      elsif en_cod_siscomex = 3999 then
         --
         vv_cnpj_pais := '99999999004421'; -- Japão
         --
      elsif en_cod_siscomex = 1546 then
         --
         vv_cnpj_pais := '99999999005401'; -- Kwait
         --
      elsif en_cod_siscomex = 4553 then
         --
         vv_cnpj_pais := '99999999005070'; -- Malásia
         --
      elsif en_cod_siscomex = 4936 then
         --
         vv_cnpj_pais := '99999999002305'; -- México
         --
      elsif en_cod_siscomex = 5215 then
         --
         vv_cnpj_pais := '99999999001406'; -- Nicarágua
         --
      elsif en_cod_siscomex = 5380 then
         --
         vv_cnpj_pais := '99999999003611'; -- Noruega
         --
      elsif en_cod_siscomex = 5487 then
         --
         vv_cnpj_pais := '99999999005231'; -- Nova Zelândia
         --
      elsif en_cod_siscomex = 5800 then
         --
         vv_cnpj_pais := '99999999001244'; -- Panamá
         --
      elsif en_cod_siscomex = 5860 then
         --
         vv_cnpj_pais := '99999999000272'; -- Paraguai
         --
      elsif en_cod_siscomex = 6033 then
         --
         vv_cnpj_pais := '99999999004006'; -- Polônia
         --
      elsif en_cod_siscomex = 6076 then
         --
         vv_cnpj_pais := '99999999002640'; -- Portugal
         --
      elsif en_cod_siscomex = 6475 then
         --
         vv_cnpj_pais := '99999999002135'; -- República Dominicana
         --
      elsif en_cod_siscomex = 6769 then
         --
         vv_cnpj_pais := '99999999004189'; -- Rússia
         --
      elsif en_cod_siscomex = 7412 then
         --
         vv_cnpj_pais := '99999999005312'; -- Singapura
         --
      elsif en_cod_siscomex = 7641 then
         --
         vv_cnpj_pais := '99999999003883'; -- Suécia
         --
      elsif en_cod_siscomex = 7676 then
         --
         vv_cnpj_pais := '99999999002992'; -- Suíça
         --
      elsif en_cod_siscomex = 7706 then
         --
         vv_cnpj_pais := '99999999001082'; -- Suriname
         --
      elsif en_cod_siscomex = 3514 then
         --
         vv_cnpj_pais := '99999999004693'; -- Taiwan
         --
      elsif en_cod_siscomex = 8451 then
         --
         vv_cnpj_pais := '99999999000353'; -- Uruguai
         --
      elsif en_cod_siscomex = 8508 then
         --
         vv_cnpj_pais := '99999999000604'; -- Venezuela
         --
      elsif en_cod_siscomex = 8583 then
         --
         vv_cnpj_pais := '99999999004855'; -- Vietnam
         --
      else
         --
         vv_cnpj_pais := '99999999999962'; -- Outros
         --
      end if;
      --
      return vv_cnpj_pais;
      --
   end fkg_cnpj_pais;
   --
begin
   --
   vn_fase := 1;
   --
   vt_tab_reg_01 := null;
   vt_tab_reg_02.delete;
   --
   vn_fase := 1.1;
   --
   vt_tab_reg_01.sigla_decl       := 'DST';
   vt_tab_reg_01.im               := pk_csf.fkg_inscr_mun_empresa ( en_empresa_id => gn_empresa_id );
   vt_tab_reg_01.mes              := to_char(gd_dt_ini, 'MM');
   vt_tab_reg_01.ano              := to_char(gd_dt_ini, 'RRRR');
   --
   vn_fase := 1.2;
   --
   vt_tab_reg_01.qtde_item_decl   := 0;
   vt_tab_reg_01.vl_decl          := 0;
   vt_tab_reg_01.vl_iss_ret       := 0;
   vt_tab_reg_01.cod_mun          := '05309';
   --
   vn_fase := 1.3;
   --
   for rec in c_nfs loop
    exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_fase := 2; 
      --
      vt_tab_reg_02(rec.notafiscal_id).nro_doc          := rec.nro_nf;
      vt_tab_reg_02(rec.notafiscal_id).mod_doc_fisc     := null;
      vt_tab_reg_02(rec.notafiscal_id).serie            := rec.serie;
      vt_tab_reg_02(rec.notafiscal_id).tipo_doc_fisc    := 'Nota Fiscal';
      vt_tab_reg_02(rec.notafiscal_id).nro_contr        := null;
      vt_tab_reg_02(rec.notafiscal_id).dt_emiss         := to_char(rec.dt_emiss, 'dd/mm/rrrr');
      vt_tab_reg_02(rec.notafiscal_id).dt_pgto          := to_char(rec.dt_emiss, 'dd/mm/rrrr');
      vt_tab_reg_02(rec.notafiscal_id).sit_docto        := 'Normal';
      --
      vn_fase := 2.1;
      --
      vt_tab_reg_02(rec.notafiscal_id).vl_glosa         := 0;
      vt_tab_reg_02(rec.notafiscal_id).vl_material      := 0;
      vt_tab_reg_02(rec.notafiscal_id).vl_subempreitada := 0;
      --
      vn_fase := 2.2;
      --
      begin
         --
         select ii.aliq_apli
              , sum(ii.vl_imp_trib)
              , sum(inf.vl_item_bruto)
           into vt_tab_reg_02(rec.notafiscal_id).aliq_imp
              , vt_tab_reg_02(rec.notafiscal_id).vl_doc
              , vt_tab_reg_02(rec.notafiscal_id).vl_iss_ret
           from item_nota_fiscal inf
              , imp_itemnf ii
          where 1 = 1
            and inf.notafiscal_id = rec.notafiscal_id
            and inf.cd_lista_serv is not null
            and ii.itemnf_id = inf.id
            and ii.dm_tipo = 1 -- retido
            and ii.vl_imp_trib > 0
            and ii.tipoimp_id in (select id from tipo_imposto where cd = '6')
          group by ii.aliq_apli;
         --
      exception
         when others then
            --
            vt_tab_reg_02(rec.notafiscal_id).aliq_imp         := 0;
            vt_tab_reg_02(rec.notafiscal_id).vl_doc           := 0;
            vt_tab_reg_02(rec.notafiscal_id).vl_iss_ret       := 0;
            --
      end;
      --
      vn_fase := 2.3;
      --
      vv_cnpj_cpf := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec.pessoa_id );
      --
      vn_fase := 2.4;
      --
      vn_cod_siscomex := pk_csf.fkg_cod_siscomex_pais_id ( en_pais_id => rec.pais_id );
      --
      vn_fase := 2.5;
      --
      if nvl(vn_cod_siscomex,0) = 1058
         or nvl(vn_cod_siscomex,0) = 0
         then
         --
         if length(vv_cnpj_cpf) = 14 then
            vt_tab_reg_02(rec.notafiscal_id).cnpj_prest       := vv_cnpj_cpf;
            vt_tab_reg_02(rec.notafiscal_id).cpf_prest        := null;
         else
            vt_tab_reg_02(rec.notafiscal_id).cnpj_prest       := null;
            vt_tab_reg_02(rec.notafiscal_id).cpf_prest        := vv_cnpj_cpf;
         end if;
         --
      else
         -- CNPJ do Pais Estrangerio
         vt_tab_reg_02(rec.notafiscal_id).cnpj_prest       := fkg_cnpj_pais ( en_cod_siscomex => vn_cod_siscomex );
         vt_tab_reg_02(rec.notafiscal_id).cpf_prest        := null;
         --
      end if;
      --
      vn_fase := 3;
      --
      vt_tab_reg_01.qtde_item_decl := nvl(vt_tab_reg_01.qtde_item_decl,0) + 1;
      vt_tab_reg_01.vl_decl := nvl(vt_tab_reg_01.vl_decl,0) + nvl(vt_tab_reg_02(rec.notafiscal_id).vl_doc,0);
      vt_tab_reg_01.vl_iss_ret := nvl(vt_tab_reg_01.vl_iss_ret,0) + nvl(vt_tab_reg_02(rec.notafiscal_id).vl_iss_ret,0);
      --
   end loop;
   --
   vn_fase := 3;
   --
   gl_conteudo := vt_tab_reg_01.sigla_decl
                             || '|' || vt_tab_reg_01.im
                             || '|' || vt_tab_reg_01.mes
                             || '|' || vt_tab_reg_01.ano
                             || '|' || vt_tab_reg_01.qtde_item_decl
                             || '|' || trim(replace(to_char(vt_tab_reg_01.vl_decl, '9999999999990D00'), '.', ','))
                             || '|' || trim(replace(to_char(vt_tab_reg_01.vl_iss_ret, '9999999999990D00'), '.', ','))
                             || '|' || vt_tab_reg_01.cod_mun || '|';
   --
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_fase := 4;
   --
   vn_ind := vt_tab_reg_02.first;
   -- Armazenar
   loop
      --
      vn_fase := 3;
      --
      if nvl(vn_ind,0) = 0 then -- índice
         exit;
      end if;
      --
      gl_conteudo := vt_tab_reg_02(vn_ind).nro_doc                         || '|';
      gl_conteudo := gl_conteudo || vt_tab_reg_02(vn_ind).mod_doc_fisc     || '|';
      gl_conteudo := gl_conteudo || vt_tab_reg_02(vn_ind).serie            || '|';
      gl_conteudo := gl_conteudo || vt_tab_reg_02(vn_ind).tipo_doc_fisc    || '|';
      gl_conteudo := gl_conteudo || vt_tab_reg_02(vn_ind).nro_contr        || '|';
      gl_conteudo := gl_conteudo || vt_tab_reg_02(vn_ind).dt_emiss         || '|';
      gl_conteudo := gl_conteudo || vt_tab_reg_02(vn_ind).dt_pgto          || '|';
      gl_conteudo := gl_conteudo || vt_tab_reg_02(vn_ind).sit_docto        || '|';
      gl_conteudo := gl_conteudo || trim(replace(to_char(vt_tab_reg_02(vn_ind).aliq_imp, '990D00'), '.', ','))         || '|';
      gl_conteudo := gl_conteudo || trim(replace(to_char(vt_tab_reg_02(vn_ind).vl_doc, '9999999999990D00'), '.', ','))           || '|';
      gl_conteudo := gl_conteudo || trim(replace(to_char(vt_tab_reg_02(vn_ind).vl_glosa, '9999999999990D00'), '.', ','))         || '|';
      gl_conteudo := gl_conteudo || trim(replace(to_char(vt_tab_reg_02(vn_ind).vl_material, '9999999999990D00'), '.', ','))      || '|';
      gl_conteudo := gl_conteudo || trim(replace(to_char(vt_tab_reg_02(vn_ind).vl_subempreitada, '9999999999990D00'), '.', ',')) || '|';
      gl_conteudo := gl_conteudo || trim(replace(to_char(vt_tab_reg_02(vn_ind).vl_iss_ret, '9999999999990D00'), '.', ','))       || '|';
      gl_conteudo := gl_conteudo || vt_tab_reg_02(vn_ind).cnpj_prest       || '|';
      gl_conteudo := gl_conteudo || vt_tab_reg_02(vn_ind).cpf_prest        || '|';
      --
      vn_fase := 99;
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
      if vn_ind = vt_tab_reg_02.last then
         exit;
      else
         vn_ind := vt_tab_reg_02.next(vn_ind);
      end if;
      --
   end loop;
   --
exception
   when others then
     raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_3205309 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_3205309;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Juazeiro / BA
procedure pkb_gera_arq_cid_2918407 is
   --
   type tab_reg_nfs is record ( cnpj_prest       varchar2(14)
                              , nome_prest       varchar2(40)
                              , nro_doc          varchar2(12)
                              , dt_serv          varchar2(8)
                              , vl_total         number(15)
                              , vl_deducoes      number(15)
                              , aliq             number(4)
                              , cd_lista_serv    varchar2(4)
                              , descr            varchar2(50)
                              );
   --
   type t_tab_reg_nfs is table of tab_reg_nfs index by binary_integer;
   vt_tab_reg_nfs   t_tab_reg_nfs;
   --
   cursor c_nfs is
   select nf.id         notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss) dt_emiss
        , nf.pessoa_id
        , nf.empresa_id
        , ncs.dm_nat_oper
        , inf.id  itemnf_id
        , inf.vl_item_bruto
        , inf.cd_lista_serv
        , inf.descr_item
        , nft.vl_total_item
        , nft.vl_ret_iss
        , nft.vl_desconto
        , nft.vl_ret_pis
        , nft.vl_ret_cofins
        , nft.vl_ret_csll
        , nft.vl_ret_irrf
        , nft.vl_ret_prev
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , nf_compl_serv  ncs
        , item_nota_fiscal inf
        , itemnf_compl_serv ics
        , nota_fiscal_total nft
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id
      and nf.id              = ncs.notafiscal_id (+)
      and nf.id              = inf.notafiscal_id
      and inf.id             = ics.itemnf_id (+)
      and nft.notafiscal_id  = nf.id
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
    order by nf.id;
   --
   vn_fase number;
   vn_ind  number;
   --
begin
   --
   vn_fase := 1;
   --
   vt_tab_reg_nfs.delete;
   --
   for rec in c_nfs loop
    exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_fase := 2; 
      --
      vt_tab_reg_nfs(rec.notafiscal_id).cnpj_prest  := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec.pessoa_id );
      vt_tab_reg_nfs(rec.notafiscal_id).nome_prest  := substr(pk_csf.fkg_nome_pessoa_id ( en_pessoa_id => rec.pessoa_id ),1,40);
      vt_tab_reg_nfs(rec.notafiscal_id).nro_doc     := rec.nro_nf;
      vt_tab_reg_nfs(rec.notafiscal_id).dt_serv     := to_char(rec.dt_emiss,'ddmmyyyy');
      vt_tab_reg_nfs(rec.notafiscal_id).vl_total    := nvl(rec.vl_total_item,0) * 100;
      vt_tab_reg_nfs(rec.notafiscal_id).vl_deducoes := ( nvl(rec.vl_desconto,0) + nvl(rec.vl_ret_iss,0) + nvl(rec.vl_ret_pis,0) + nvl(rec.vl_ret_cofins,0) + nvl(rec.vl_ret_csll,0) +
                                                       nvl(rec.vl_ret_irrf,0) + nvl(rec.vl_ret_prev,0) ) * 100;
      --
      vn_fase := 2.1;
      --
      vt_tab_reg_nfs(rec.notafiscal_id).cd_lista_serv := substr(rec.cd_lista_serv,1,4);
      vt_tab_reg_nfs(rec.notafiscal_id).descr         := substr(rec.descr_item,1,50);
      --
      begin
         --
         select nvl(ii.aliq_apli,0) * 100
           into vt_tab_reg_nfs(rec.notafiscal_id).aliq
           from imp_itemnf ii
              , tipo_imposto ti
          where ii.itemnf_id  = rec.itemnf_id
            and ii.tipoimp_id = ti.id
            and ti.cd         = 6 -- ISS
            and ii.dm_tipo    = 1; -- Retido
         --
      exception
       when no_data_found then
          vt_tab_reg_nfs(rec.notafiscal_id).aliq := null;
      end;
      --
      vn_fase := 2.3;
      --
   end loop;
   --
   vn_fase := 3;
   --
   vn_ind := vt_tab_reg_nfs.first;
   -- Armazenar
   loop
      --
      vn_fase := 3;
      --
      if nvl(vn_ind,0) = 0 then -- índice
         exit;
      end if;
      --
      gl_conteudo := lpad(vt_tab_reg_nfs(vn_ind).cnpj_prest,14,'0');
      gl_conteudo := gl_conteudo || rpad(vt_tab_reg_nfs(vn_ind).nome_prest,40);
      gl_conteudo := gl_conteudo || lpad(vt_tab_reg_nfs(vn_ind).nro_doc,12,'0');
      gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_nfs(vn_ind).dt_serv,0),8,'0');
      gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_nfs(vn_ind).vl_total,0),15,'0');
      gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_nfs(vn_ind).vl_deducoes,0),15,'0');
      gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_nfs(vn_ind).aliq,0),4,'0');
      gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_nfs(vn_ind).cd_lista_serv,0),4,'0');
      gl_conteudo := gl_conteudo || rpad(nvl(vt_tab_reg_nfs(vn_ind).descr,' '),50);
      --
      vn_fase := 99;
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
      if vn_ind = vt_tab_reg_nfs.last then
         exit;
      else
         vn_ind := vt_tab_reg_nfs.next(vn_ind);
      end if;
      --
   end loop;
   --
exception
   when others then
     raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_2918407 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_2918407;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Maraba / PA   
procedure pkb_gera_arq_cid_1504208 is
   --
   type tab_reg_nfs is record ( tp_reg           number
                              , doc_tom          varchar2(12)
                              , mes_ref          varchar2(6)
                              , cd_servico       number(9)
                              , inscr_mun        varchar2(15)
                              , doc_prest        varchar2(18)
                              , razao_soc_prest  varchar2(100)
                              , sit_prest        number(1)
                              , form_trib        number(2)
                              , tip_doc          number(2)
                              , nro_nf           number(9)
                              , dt_emiss         varchar2(8)
                              , vl_contabil      number(12)
                              , vl_trib          number(12)
                              , obs              varchar2(255)
                              );
   --
   type t_tab_reg_nfs is table of tab_reg_nfs index by binary_integer;
   vt_tab_reg_nfs   t_tab_reg_nfs;
   --
   cursor c_nfs is
   select nf.id         notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss) dt_emiss
        , nf.pessoa_id
        , nf.empresa_id
        , ncs.dm_nat_oper
        , inf.vl_item_bruto
        , inf.cd_lista_serv
        , inf.descr_item
        , nft.vl_total_nf
        , nft.vl_ret_iss
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , nf_compl_serv  ncs
        , item_nota_fiscal inf
        , itemnf_compl_serv ics
        , nota_fiscal_total nft
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id
      and nf.id              = ncs.notafiscal_id (+)
      and nf.id              = inf.notafiscal_id
      and inf.id             = ics.itemnf_id (+)
      and nft.notafiscal_id  = nf.id
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
    order by nf.id;
   --
   vn_fase                   number;
   vn_ind                    number;
   vn_ibge_cidade_part       cidade.ibge_cidade%type;
   --
begin
   --
   vn_fase := 1;
   --
   vt_tab_reg_nfs.delete;
   --
   for rec in c_nfs loop
    exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_fase := 2;
      --
      vt_tab_reg_nfs(rec.notafiscal_id).tp_reg           := 2;
      vt_tab_reg_nfs(rec.notafiscal_id).doc_tom          := trim(rec.serie) || '-' || trim(rec.nro_nf);
      vt_tab_reg_nfs(rec.notafiscal_id).mes_ref          := to_char(rec.dt_emiss,'yyyymm');
      vt_tab_reg_nfs(rec.notafiscal_id).cd_servico       := rec.cd_lista_serv;
      vt_tab_reg_nfs(rec.notafiscal_id).inscr_mun        := pk_csf.fkg_inscr_mun_pessoa ( en_pessoa_id => rec.pessoa_id);
      vt_tab_reg_nfs(rec.notafiscal_id).doc_prest        := trim(rec.serie) || '-' || trim(rec.nro_nf);
      vt_tab_reg_nfs(rec.notafiscal_id).razao_soc_prest  := pk_csf.fkg_nome_pessoa_id ( en_pessoa_id => rec.pessoa_id );
      --
      vn_fase := 2.1;
      --
      vn_ibge_cidade_part := null;
      --
      -- Identificar se o participante é de outro municipio                                            
      begin
         --
         select c.ibge_cidade
           into vn_ibge_cidade_part
           from pessoa p
              , cidade c
          where p.id  = rec.pessoa_id
            and c.id  = p.cidade_id;
         --
      exception
         when no_data_found then
            vn_ibge_cidade_part := null;
      end;
      --
      if trim(vn_ibge_cidade_part) = '1504208' then -- Maraba-PA
         vt_tab_reg_nfs(rec.notafiscal_id).sit_prest := 0;
      elsif nvl(rec.dm_nat_oper,-1) = 7 then           -- Exportação
         vt_tab_reg_nfs(rec.notafiscal_id).sit_prest := 2;
      else
         vt_tab_reg_nfs(rec.notafiscal_id).sit_prest := 1;
      end if;
      --
      vn_fase := 2.2;
      --
      if rec.dm_nat_oper = 1 then
         --
         vt_tab_reg_nfs(rec.notafiscal_id).form_trib := 1; -- Normal
         --
      elsif rec.dm_nat_oper in (3,8) then
         --
         vt_tab_reg_nfs(rec.notafiscal_id).form_trib := 3; -- Isenção
         --
      elsif rec.dm_nat_oper = 4 then
         --
         vt_tab_reg_nfs(rec.notafiscal_id).form_trib := 4; -- Imune
         --
      elsif rec.dm_nat_oper = 2 then
         --
         vt_tab_reg_nfs(rec.notafiscal_id).form_trib := 5; -- Outro Mun.
         --
      elsif rec.dm_nat_oper in (5,6) then
         --
         vt_tab_reg_nfs(rec.notafiscal_id).form_trib := 6; -- Extraviado
         --
      end if;
      --
      vn_fase := 2.3;
      --
      vt_tab_reg_nfs(rec.notafiscal_id).tip_doc       := 0;
      vt_tab_reg_nfs(rec.notafiscal_id).nro_nf        := trim(rec.nro_nf);
      vt_tab_reg_nfs(rec.notafiscal_id).dt_emiss      := to_char(rec.dt_emiss,'yyyymmdd');   
      vt_tab_reg_nfs(rec.notafiscal_id).vl_contabil   := nvl(rec.vl_total_nf,0) * 100;
      vt_tab_reg_nfs(rec.notafiscal_id).vl_trib       := nvl(rec.vl_ret_iss,0) * 100;
      vt_tab_reg_nfs(rec.notafiscal_id).obs           := trim(rec.descr_item);
      --
   end loop;
   --
   vn_fase := 3;
   --
   vn_ind := vt_tab_reg_nfs.first;
   -- Armazenar
   loop
      --
      vn_fase := 3;
      --
      if nvl(vn_ind,0) = 0 then -- índice = conscontrpis_id
         exit;
      end if;
      --
      gl_conteudo := vt_tab_reg_nfs(vn_ind).tp_reg;
      gl_conteudo := gl_conteudo || rpad(nvl(vt_tab_reg_nfs(vn_ind).doc_tom,' '),18);
      gl_conteudo := gl_conteudo || vt_tab_reg_nfs(vn_ind).mes_ref;
      gl_conteudo := gl_conteudo || lpad(vt_tab_reg_nfs(vn_ind).cd_servico,9,'0');
      gl_conteudo := gl_conteudo || rpad(nvl(vt_tab_reg_nfs(vn_ind).inscr_mun,' '),15);
      gl_conteudo := gl_conteudo || rpad(nvl(vt_tab_reg_nfs(vn_ind).doc_prest,' '), 18);
      gl_conteudo := gl_conteudo || rpad(nvl(vt_tab_reg_nfs(vn_ind).razao_soc_prest,' '),100);
      gl_conteudo := gl_conteudo || vt_tab_reg_nfs(vn_ind).sit_prest;
      gl_conteudo := gl_conteudo || lpad(vt_tab_reg_nfs(vn_ind).form_trib,2,'0');
      gl_conteudo := gl_conteudo || lpad(vt_tab_reg_nfs(vn_ind).tip_doc,2,'0');
      gl_conteudo := gl_conteudo || lpad(vt_tab_reg_nfs(vn_ind).nro_nf,9,'0');
      gl_conteudo := gl_conteudo || vt_tab_reg_nfs(vn_ind).dt_emiss;
      gl_conteudo := gl_conteudo || lpad(vt_tab_reg_nfs(vn_ind).vl_contabil,12,'0');
      gl_conteudo := gl_conteudo || lpad(vt_tab_reg_nfs(vn_ind).vl_trib,12,'0');
      gl_conteudo := gl_conteudo || rpad(nvl(vt_tab_reg_nfs(vn_ind).obs,' '),255);
      --
      vn_fase := 99;
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
      if vn_ind = vt_tab_reg_nfs.last then
         exit;
      else
         vn_ind := vt_tab_reg_nfs.next(vn_ind);
      end if;
      --
   end loop;
   --
exception
   when others then
     raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_1504208 fase ('||vn_fase||'): '||sqlerrm);
   --
end pkb_gera_arq_cid_1504208;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Jaboatão dos Guararapes / PE
procedure pkb_gera_arq_cid_2607901 is
   --
   type tab_reg_tompre is record ( cod           number
                                 , nome          varchar2(60)
                                 , cpf_cnpj      varchar2(14)
                                 , inscr_mun     varchar2(7)
                                 , cep           varchar2(9)
                                 , logr          varchar2(60)
                                 , nro           varchar2(6)
                                 , bairro        varchar2(45)
                                 , descr_cidade  varchar2(45)
                                 , uf            varchar2(2)
                                 );
   --
   type t_tab_reg_tompre is table of tab_reg_tompre index by binary_integer;   -- pessoa_id
   vt_tab_reg_tompre   t_tab_reg_tompre;
   --
   -- Registro do Plano Conta
   type tab_reg_plconta is record ( cod     number
                                  , NuCo    varchar2(10)
                                  , DeCo    varchar2(60)
                                  , Cosif   varchar2(10)
                                  , CSer    varchar2(5)
                                  );
   --
   type t_tab_reg_plconta is table of tab_reg_plconta index by binary_integer;  -- planoconta_id
   vt_tab_reg_plconta   t_tab_reg_plconta;
   --
   -- Registro de documento Recebido
   type tab_reg_docrec is record ( cod           number
                                 , pres         number
                                 , tpdo        varchar2(1)
                                 , seri      varchar2(3)
                                 , sub        number
                                 , nume          varchar2(14)
                                 , data          varchar2(8)
                                 , cser         number
                                 , vser         varchar2(12)
                                 , reti         varchar2(1)
                                 , basc         varchar2(12)
                                 , aliq         varchar2(6)
                                 , viss         varchar2(12)
                                 );
   --
   type t_tab_reg_docrec is table of tab_reg_docrec index by binary_integer;      -- notafiscal_id
   vt_tab_reg_docrec   t_tab_reg_docrec;
   --
   cursor c_nfs is
   select nf.id         notafiscal_id
        , nf.nro_nf
        , decode(nf.serie,'1','A','O') serie
        , nf.sub_serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss) dt_emiss
        , nf.pessoa_id
        , ncs.cidademodfiscal_id
        , ncs.dt_exe_serv
        , nf.empresa_id
        , ncs.dm_nat_oper
        , inf.vl_item_bruto
        , inf.cd_lista_serv
        , inf.descr_item
        , inf.cod_cta
        , ics.codtribmunicipio_id
        , ics.cidadebeneficfiscal_id
        , ics.cnae
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , nf_compl_serv  ncs
        , item_nota_fiscal inf
        , itemnf_compl_serv ics
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id
      and nf.id              = ncs.notafiscal_id (+)
      and nf.id              = inf.notafiscal_id
      and inf.id             = ics.itemnf_id (+)
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
    order by nf.id;
   --
   vn_fase                         number := null;
   vn_count                        number := null;
   vn_count_docrec                  number := null;
   vb_achou                        boolean;
   --
   vn_planoconta_id                plano_conta.id%type;
   vn_ind                          number;
   vn_count_tompre                 number := null;
   vn_count_cta                number := null;
   --
   vv_teste                       varchar2(1000);
   --
begin
   --
   vn_fase := 1;
   --
   gl_conteudo := '<?xml version="1.0" encoding="ISO-8859-1" ?>';
   gl_conteudo := gl_conteudo || '<declaracao>';
   --
   vn_fase := 2;
   --
   gl_conteudo := gl_conteudo || '<head>';
   --
   gl_conteudo := gl_conteudo || '<heInsc>'|| pk_csf.fkg_inscr_mun_empresa ( en_empresa_id => gn_empresa_id ) ||'</heInsc>'; -- LEMBRAR DE VERIFICAR COM O LEANDRO
   gl_conteudo := gl_conteudo || '<heComp>'|| to_char(sysdate,'yyyymm') ||'</heComp>';
   gl_conteudo := gl_conteudo || '<heGeDt>'|| to_char(sysdate,'ddmmyyyy') ||'</heGeDt>';
   gl_conteudo := gl_conteudo || '<heGeHo>'|| to_char(sysdate,'hhmmss') ||'</heGeHo>';
   gl_conteudo := gl_conteudo || '<heVers>2000</heVers>';
   gl_conteudo := gl_conteudo || '<hePref>JABO</hePref>';
   --
   gl_conteudo := gl_conteudo || '</head>';
   --
   vn_fase := 3;
   --
   vt_tab_reg_tompre.delete;
   vt_tab_reg_docrec.delete;
   vt_tab_reg_plconta.delete;
   vn_count           := null;
   vn_count_cta       := null;
   vn_count_docrec     := null;
   --
   for rec in c_nfs loop
    exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vb_achou := null;
      --
      begin
         vb_achou := vt_tab_reg_tompre.exists(rec.pessoa_id);
      exception
       when others then
         vb_achou := false;
      end;
      --
      if not vb_achou then
         --
         vn_count := nvl(vn_count,0) + 1;
         vt_tab_reg_tompre(rec.pessoa_id).cod := vn_count;
         --
         vt_tab_reg_tompre(rec.pessoa_id).nome := pk_csf.fkg_nome_pessoa_id ( en_pessoa_id => rec.pessoa_id);
         vt_tab_reg_tompre(rec.pessoa_id).cpf_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec.pessoa_id );
         vt_tab_reg_tompre(rec.pessoa_id).inscr_mun := pk_csf.fkg_inscr_mun_pessoa ( en_pessoa_id => rec.pessoa_id );
         --
         begin
            --
            select p.cep
                 , p.lograd
                 , p.nro
                 , p.bairro
                 , c.descr
                 , e.sigla_estado
              into vt_tab_reg_tompre(rec.pessoa_id).cep
                 , vt_tab_reg_tompre(rec.pessoa_id).logr
                 , vt_tab_reg_tompre(rec.pessoa_id).nro
                 , vt_tab_reg_tompre(rec.pessoa_id).bairro
                 , vt_tab_reg_tompre(rec.pessoa_id).descr_cidade
                 , vt_tab_reg_tompre(rec.pessoa_id).uf
              from pessoa p
                 , cidade c
                 , estado e
             where p.id        = rec.pessoa_id
               and p.cidade_id    = c.id
               and c.estado_id = e.id;
            --
         exception
           when no_data_found then
              --
              vt_tab_reg_tompre(rec.pessoa_id).cep := null;
              vt_tab_reg_tompre(rec.pessoa_id).logr := null;
              vt_tab_reg_tompre(rec.pessoa_id).nro := null;
              vt_tab_reg_tompre(rec.pessoa_id).bairro := null;
              vt_tab_reg_tompre(rec.pessoa_id).descr_cidade := null;
              vt_tab_reg_tompre(rec.pessoa_id).uf := null;
              --
         end;
         --
      end if;
      --
      -- Recuperar o Plano de Conta
      vn_planoconta_id := null;
      --
      vn_planoconta_id := pk_csf.fkg_Plano_Conta_id ( ev_cod_cta    => rec.cod_cta
                                                    , en_empresa_id => rec.empresa_id );
      --
      if nvl(vn_planoconta_id,0) > 0 then
         --
         vb_achou := null;
         --
         begin
            vb_achou := vt_tab_reg_plconta.exists(vn_planoconta_id);
         exception
          when others then
            vb_achou := false;
         end;
         --
         if not vb_achou then
            --
            vn_count_cta := nvl(vn_count_cta,0) + 1;
            vt_tab_reg_plconta(vn_planoconta_id).cod := vn_count_cta;
            --
            -- Recuperar o código do plano de conta referencial ao ECD 
            -- que esteja dentro do periodo de referencia com base na data de Emissão.
            begin
               --
               select distinct pc.cod_cta
                    , pc.descr_cta
                    , replace(pce.cod_cta_ref,'.','')
                 into vt_tab_reg_plconta(vn_planoconta_id).NuCo
                    , vt_tab_reg_plconta(vn_planoconta_id).DeCo
                    , vt_tab_reg_plconta(vn_planoconta_id).Cosif
                 from plano_conta pc
                    , pc_referen pcr
                    , plano_conta_ref_ecd pce
                where pc.id        = vn_planoconta_id
                  and pcr.planoconta_id = pc.id
                  and pcr.planocontarefecd_id = pce.id
                  and rec.dt_emiss between nvl(pcr.dt_ini,rec.dt_emiss) and nvl(pcr.dt_fin,rec.dt_emiss);
               --
            exception
              when no_data_found then
                 vt_tab_reg_plconta(vn_planoconta_id).NuCo := null;
                 vt_tab_reg_plconta(vn_planoconta_id).DeCo := null;
                 vt_tab_reg_plconta(vn_planoconta_id).Cosif := null;
            end;
            --
         end if;
         --
         vt_tab_reg_plconta(vn_planoconta_id).cser := rec.cd_lista_serv;
         vt_tab_reg_docrec(rec.notafiscal_id).cser := vt_tab_reg_plconta(vn_planoconta_id).cser;
         --
      end if;
      --
      vn_count_docrec := nvl(vn_count_docrec,0) + 1;
      -- Recuperar os dados do "Documento Recebidos"
      vt_tab_reg_docrec(rec.notafiscal_id).cod := vn_count_docrec;
      vt_tab_reg_docrec(rec.notafiscal_id).pres := vt_tab_reg_tompre(rec.pessoa_id).cod;
      vt_tab_reg_docrec(rec.notafiscal_id).tpdo := rec.serie;
      vt_tab_reg_docrec(rec.notafiscal_id).sub := rec.sub_serie;
      vt_tab_reg_docrec(rec.notafiscal_id).nume := rec.nro_nf;
      vt_tab_reg_docrec(rec.notafiscal_id).data   := to_char(sysdate,'ddmmyyyy');
      --
      begin
         --
         select replace(to_char(sum(ii.vl_base_calc),'0000000D00'),',','.')
           into vt_tab_reg_docrec(rec.notafiscal_id).basc
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto   ti
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.tipoimp_id     = ti.id
            and ti.cd             = 6; -- ISS
         --
      exception
       when no_data_found then
          vt_tab_reg_docrec(rec.notafiscal_id).basc := null;
      end;
      --
      begin
         --
         select distinct replace(to_char(ii.aliq_apli,'00D00'),',','.')
              , replace(to_char(ii.vl_imp_trib,'0000000D00'),',','.')
              , replace(to_char(inf.vl_item_bruto,'0000000D00'),',','.')
              , decode(ii.dm_tipo,0,'N','S')
           into vt_tab_reg_docrec(rec.notafiscal_id).aliq
              , vt_tab_reg_docrec(rec.notafiscal_id).viss
              , vt_tab_reg_docrec(rec.notafiscal_id).vser
              , vt_tab_reg_docrec(rec.notafiscal_id).reti
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id  = rec.notafiscal_id
            and inf.id             = ii.itemnf_id
            and ii.tipoimp_id      = ti.id
            and ti.cd              = 6 -- ISS
            and inf.cd_lista_serv is not null;
         --
      exception
       when no_data_found then
          --
          vt_tab_reg_docrec(rec.notafiscal_id).aliq := null;
          vt_tab_reg_docrec(rec.notafiscal_id).viss := null;
          vt_tab_reg_docrec(rec.notafiscal_id).vser  := null;
          vt_tab_reg_docrec(rec.notafiscal_id).reti := 'S';   
          --
      end;
      --
   end loop;
   --
   vn_ind := nvl(vt_tab_reg_tompre.first,0);
   --
   -- Tomador/Prestador
   loop
      --
      vn_fase := 3;
      --
      if nvl(vn_ind,0) = 0 then -- índice = conscontrpis_id
         exit;
      end if;
      --
      gl_conteudo := gl_conteudo || '<tompre>';
      --
      gl_conteudo := gl_conteudo || '<tpCod>' || vt_tab_reg_tompre(vn_ind).cod ||'</tpCod>';
      gl_conteudo := gl_conteudo || '<tpNome>'|| vt_tab_reg_tompre(vn_ind).nome ||'</tpNome>';
      gl_conteudo := gl_conteudo || '<tpDocu>'|| vt_tab_reg_tompre(vn_ind).cpf_cnpj ||'</tpDocu>';
      --
      if trim(vt_tab_reg_tompre(vn_ind).inscr_mun) is not null then
         gl_conteudo := gl_conteudo || '<tpInMu>'|| vt_tab_reg_tompre(vn_ind).inscr_mun ||'</tpInMu>';
      end if;
      --
      gl_conteudo := gl_conteudo || '<tpCep>' || vt_tab_reg_tompre(vn_ind).cep ||'</tpCep>';
      gl_conteudo := gl_conteudo || '<tpLogr>'|| vt_tab_reg_tompre(vn_ind).logr ||'</tpLogr>';
      gl_conteudo := gl_conteudo || '<tpNume>'|| vt_tab_reg_tompre(vn_ind).nro ||'</tpNume>';
      gl_conteudo := gl_conteudo || '<tpBair>'|| vt_tab_reg_tompre(vn_ind).bairro ||'</tpBair>';
      gl_conteudo := gl_conteudo || '<tpMuni>'|| vt_tab_reg_tompre(vn_ind).descr_cidade ||'</tpMuni>';
      gl_conteudo := gl_conteudo || '<tpEsta>'|| vt_tab_reg_tompre(vn_ind).uf ||'</tpEsta>';
      --
      gl_conteudo := gl_conteudo || '</tompre>';
      --
      vn_fase := 6;
      --
      if vn_ind = vt_tab_reg_tompre.last then
         exit;
      else
         vn_ind := vt_tab_reg_tompre.next(vn_ind);
      end if;
      --
   end loop;
   --
   vn_ind := null;
   -- Plano Conta
   vn_ind := nvl(vt_tab_reg_plconta.first,0);
   --
   loop
      --
      vn_fase := 3;
      --
      if nvl(vn_ind,0) = 0 then -- índice = conscontrpis_id
         exit;
      end if;
      --
      gl_conteudo := gl_conteudo || '<placon>';
      --
      gl_conteudo := gl_conteudo || '<plCod>'  || vt_tab_reg_plconta(vn_ind).cod   || '<plCod>';
      gl_conteudo := gl_conteudo || '<plNuCo>' || vt_tab_reg_plconta(vn_ind).NuCo  ||'<plNuCo>';
      gl_conteudo := gl_conteudo || '<plDeCo>' || vt_tab_reg_plconta(vn_ind).DeCo  ||'<plDeCo>';
      gl_conteudo := gl_conteudo || '<plCosi>' || vt_tab_reg_plconta(vn_ind).Cosif ||'<plCosi>';
      gl_conteudo := gl_conteudo || '<plCSer>' || vt_tab_reg_plconta(vn_ind).CSer  ||'<plCSer>';

      --
      gl_conteudo := gl_conteudo || '</placon>';
      --
      if vn_ind = vt_tab_reg_plconta.last then
         exit;
      else
         vn_ind := vt_tab_reg_plconta.next(vn_ind);
      end if;
      --
   end loop;
   --
   -- Documento Recebidos
   vn_ind := null;
   vn_ind := nvl(vt_tab_reg_docrec.first,0);
   vn_count_docrec := null;
   --
   loop
      --
      vn_fase := 3;
      --
      if nvl(vn_ind,0) = 0 then -- índice = conscontrpis_id
         exit;
      end if;
      --
      gl_conteudo := gl_conteudo || '<docrec>';
      --
      gl_conteudo := gl_conteudo || '<drCod>' || vt_tab_reg_docrec(vn_ind).cod  || '</drCod>';
      gl_conteudo := gl_conteudo || '<drPres>'|| vt_tab_reg_docrec(vn_ind).pres || '</drPres>';
      gl_conteudo := gl_conteudo || '<drTpDo>'|| vt_tab_reg_docrec(vn_ind).tpdo || '</drTpDo>';
      gl_conteudo := gl_conteudo || '<drNume>'|| vt_tab_reg_docrec(vn_ind).nume || '</drNume>';
      gl_conteudo := gl_conteudo || '<drData>'|| vt_tab_reg_docrec(vn_ind).data || '</drData>';
      gl_conteudo := gl_conteudo || '<drCSer>'|| vt_tab_reg_docrec(vn_ind).CSer || '</drCSer>';
      gl_conteudo := gl_conteudo || '<drVSer>'|| trim(ltrim(vt_tab_reg_docrec(vn_ind).vser,0)) || '</drVSer>';     --11
      gl_conteudo := gl_conteudo || '<drReti>'|| vt_tab_reg_docrec(vn_ind).reti || '</drReti>';
      gl_conteudo := gl_conteudo || '<drBasC>'|| trim(ltrim(vt_tab_reg_docrec(vn_ind).basc,0)) || '</drBasC>';     --11
      gl_conteudo := gl_conteudo || '<drAliq>'|| trim(ltrim(vt_tab_reg_docrec(vn_ind).aliq,0)) || '</drAliq>';     --4
      gl_conteudo := gl_conteudo || '<drVIss>'|| trim(ltrim(vt_tab_reg_docrec(vn_ind).viss,0)) || '</drVIss>';     --11
      --
      gl_conteudo := gl_conteudo || '</docrec>';
      --
      if vn_ind = vt_tab_reg_docrec.last then
         exit;
      else
         vn_ind := vt_tab_reg_docrec.next(vn_ind);
      end if;
      --
   end loop;
   --
   gl_conteudo := gl_conteudo || '<trailler>';
   --
   gl_conteudo := gl_conteudo ||'<qtToPr>'|| nvl(vt_tab_reg_tompre.count,0) ||'</qtToPr>';
   gl_conteudo := gl_conteudo ||'<qtPlCo>'|| nvl(vt_tab_reg_plconta.count,0) ||'</qtPlCo>';
   gl_conteudo := gl_conteudo ||'<qtDoRe>'|| nvl(vt_tab_reg_docrec.count,0) ||'</qtDoRe>';
   --
   gl_conteudo := gl_conteudo || '</trailler>';
   --
   gl_conteudo := gl_conteudo || '</declaracao>';
   --
   vn_fase := 99;
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
exception
   when others then
     raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_2607901 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_2607901;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Joinville / SC
procedure pkb_gera_arq_cid_4209102 is
   --
   vn_fase                         number;
   vn_count                        number;
   vv_cidade                       cidade.descr%type;
   vv_uf                           estado.sigla_estado%type;
   vn_pessoa_id                    pessoa.id%type;
   --
   vn_vl_base_calc                 imp_itemnf.vl_base_calc%type;
   vn_aliq_aplic                   imp_itemnf.aliq_apli%type;
   vn_vl_imp_trib                  imp_itemnf.vl_imp_trib%type;
   vv_simpl_nacional               valor_tipo_param.cd%type;
   --
   cursor c_nfs is
   select nf.id         notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss) dt_emiss
        , nf.pessoa_id
        , ncs.cidademodfiscal_id
        , ncs.dt_exe_serv
        , ncs.dm_nat_oper
        , inf.vl_item_bruto
        , inf.cd_lista_serv
        , inf.descr_item
        , ics.codtribmunicipio_id
        , ics.cidadebeneficfiscal_id
        , ics.cnae
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , nf_compl_serv  ncs
        , item_nota_fiscal inf
        , itemnf_compl_serv ics
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id
      and nf.id              = ncs.notafiscal_id (+)
      and nf.id              = inf.notafiscal_id
      and inf.id             = ics.itemnf_id (+)
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
    order by nf.id;
   --
begin
   --
   vn_fase := 1;
   --
   gl_conteudo := '<?xml version="1.0" encoding="UTF-8"?>';
   gl_conteudo := gl_conteudo ||'<lote xmlns="https://nfem.joinville.sc.gov.br"';
   gl_conteudo := gl_conteudo ||' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"';
   gl_conteudo := gl_conteudo ||' xsi:schemaLocation="https://nfem.joinville.sc.gov.br rps_1.0.xsd">';
   gl_conteudo := gl_conteudo ||'<versao>1.0</versao>';
   --
   vn_fase := 2;
   --
   vn_count := 0;
   --
   for rec in c_nfs loop
    exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_count := vn_count + 1;
      vn_fase := 3;
      --
      if nvl(vn_count,0) > 1 then
         --
         gl_conteudo := gl_conteudo || '<dir>';
         --
      end if;
      --
      gl_conteudo := gl_conteudo ||'<numero>'|| vn_count ||'</numero>';
      --
      if nvl(vn_count,0) = 1 then
         --
         gl_conteudo := gl_conteudo ||'<tipo>'|| 2 ||'</tipo>';
         gl_conteudo := gl_conteudo ||'<tomador>';
         --
         gl_conteudo := gl_conteudo ||'<documento>'|| lpad(nvl(pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => gn_empresa_id ), '0'), 14, '0') ||'</documento>';
         gl_conteudo := gl_conteudo ||'<razao_social>'||trim(rpad(pk_csf.fkg_nome_empresa ( en_empresa_id => gn_empresa_id ),60,' '))||'</razao_social>';
         --
         gl_conteudo := gl_conteudo ||'</tomador>';
         --
      end if;
      --
      vn_fase := 4;
      --
      if nvl(vn_count,0) = 1 then
         --
         gl_conteudo := gl_conteudo || '<dir>';
         --
      end if;
      --
      gl_conteudo := gl_conteudo ||'<numero>'|| rec.nro_nf ||'</numero>';
      gl_conteudo := gl_conteudo ||'<serie>'|| rec.serie ||'</serie>';
      gl_conteudo := gl_conteudo ||'<data_emissao>'|| to_char(rec.dt_emiss,'yyyy-mm-dd') ||'</data_emissao>';
      gl_conteudo := gl_conteudo ||'<prestador>';
      --
      vn_fase := 5;
      --
      gl_conteudo := gl_conteudo || '<documento>'|| pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => gn_empresa_id ) ||'</documento>';
      gl_conteudo := gl_conteudo || '<nome>'|| pk_csf.fkg_nome_empresa ( en_empresa_id => gn_empresa_id )||'</nome>';
      --
      vv_cidade := null;
      vv_uf := null;
      --
      begin
         --
         select c.descr
              , es.sigla_estado
              , vn_pessoa_id
           into vv_cidade
              , vv_uf
              , vn_pessoa_id
           from empresa e
              , pessoa p
              , cidade c
              , estado es
          where e.id = gn_empresa_id
            and e.pessoa_id = p.id
            and p.cidade_id = c.id
            and c.estado_id = es.id;
         --
      exception
       when no_data_found then
          vv_cidade := null;
          vv_uf     := null;
      end;
      --
      gl_conteudo := gl_conteudo || '<cidade>'|| vv_cidade ||'</cidade>';
      gl_conteudo := gl_conteudo || '<estado>'|| vv_uf ||'</estado>';
--      gl_conteudo := gl_conteudo || '<internacional>'|| ||'</internacional>';
      --
      vv_simpl_nacional := pk_csf.fkg_pessoa_valortipoparam_cd ( ev_tipoparam_cd => 1 -- Simples Nacional
                                                               , en_pessoa_id    => vn_pessoa_id );
      --
      if trim(vv_simpl_nacional) is not null then
         --
         gl_conteudo := gl_conteudo || '<simples_nacional>'|| trim(vv_simpl_nacional) || '</simples_nacional>';  -- 0 Não e 1 - Sim
         --
      end if;
      --
      gl_conteudo := gl_conteudo ||'</prestador>';
      --
      vn_fase := 6;
      --
      vn_vl_base_calc := null;
      --
      begin
         select nvl(sum(ii.vl_base_calc),0)
           into vn_vl_base_calc
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto   ti
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.tipoimp_id     = ti.id
            and ti.cd             = 6; -- ISS
      exception
         when others then
           vn_vl_base_calc := 0;
      end;
      --
      vn_fase := 7;
      --
      vn_aliq_aplic := 0;
      vn_vl_imp_trib := 0;
      --
      begin
         select distinct(ii.aliq_apli)
              , ii.vl_imp_trib
           into vn_aliq_aplic
              , vn_vl_imp_trib
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id  = rec.notafiscal_id
            and inf.id             = ii.itemnf_id
            and ii.dm_tipo         = 0 -- Normal
            and ii.tipoimp_id      = ti.id
            and ti.cd              = 6 -- ISS
            and inf.cd_lista_serv is not null;
      exception
         when others then
            vn_aliq_aplic := 0;
            vn_vl_imp_trib := 0;
      end;
      --
      gl_conteudo := gl_conteudo ||'<valor_total>'|| rec.vl_item_bruto ||'</valor_total>';
      gl_conteudo := gl_conteudo ||'<valor_base_calculo>'|| nvl(vn_vl_base_calc,0) ||'</valor_base_calculo>';
      gl_conteudo := gl_conteudo ||'<servico>'|| rec.cd_lista_serv ||'</servico>';
      gl_conteudo := gl_conteudo ||'<valor_iss>'|| vn_vl_imp_trib ||'</valor_iss>';
      gl_conteudo := gl_conteudo ||'<aliquota_iss>'|| vn_aliq_aplic ||'</aliquota_iss>';
      --
      gl_conteudo := gl_conteudo ||'</dir>';
      --
   end loop;
   --
   gl_conteudo := gl_conteudo ||'</lote>';
   --
   vn_fase := 99;
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_4209102 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_4209102;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Manaus / AM
procedure pkb_gera_arq_cid_1302603 is
   --
   vn_fase              number := 0;
   vn_qtde_linhas       number := 0;
   vv_cpf_cnpj          varchar2(14);
   vd_dt_canc           date;
   vv_nome              pessoa.nome%type := null;
   vv_lograd            pessoa.nome%type := null;
   vv_nro               pessoa.nro%type := null;
   vv_compl             pessoa.compl%type := null;
   vv_bairro            pessoa.bairro%type := null;
   vv_cidade            cidade.descr%type := null;
   vv_uf                estado.sigla_estado%type := null;
   vn_cep               pessoa.cep%type := null;
   vv_email             pessoa.email_forn%type := null;
   vv_iest              juridica.iest%type := null;
   vn_vl_deducao        number := 0;
   vn_aliq              number := 0;
   vn_vl_imp_trib       number := 0;
   vn_vl_imp_iss_ret    number := 0;
   vn_vl_tot_serv       number := 0;
   vn_vl_tot_deducao    number := 0;
   vn_vl_tot_iss        number := 0;
   vn_vl_tot_cred       number := 0;
   vn_vl_tot_ret_cofins number := 0;
   vn_vl_tot_ret_csll   number := 0;
   vn_vl_tot_ret_prev   number := 0;
   vn_vl_tot_ret_irrf   number := 0;
   vn_vl_tot_ret_pis    number := 0;
   --
   cursor c_nfs is
   select nf.id  notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss) dt_emiss
        , nf.pessoa_id
        , nf.dm_st_proc
        , pe.id pessoa_id_empresa
        , nc.dm_nat_oper
        , nc.cod_verif_nfs
        , nc.nro_aut_nfs
        , nc.dt_emiss_nfs
        , it.descr_item
        , it.cd_lista_serv
        , nvl(sum(nvl(it.vl_item_bruto,0)),0) vl_item_bruto
        , nvl(sum(nvl(nt.vl_ret_cofins,0)),0) vl_ret_cofins
        , nvl(sum(nvl(nt.vl_ret_csll,0)),0) vl_ret_csll
        , nvl(sum(nvl(nt.vl_ret_prev,0)),0) vl_ret_prev
        , nvl(sum(nvl(nt.vl_ret_irrf,0)),0) vl_ret_irrf
        , nvl(sum(nvl(nt.vl_ret_pis,0)),0) vl_ret_pis
     from nota_fiscal       nf
        , mod_fiscal        mf
        , empresa           em
        , pessoa            pe
        , nf_compl_serv     nc
        , item_nota_fiscal  it
        , nota_fiscal_total nt
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4 -- 4-autorizada, 7-cancelada, 8-inutilizada
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id                = nf.modfiscal_id
      and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and it.cd_lista_serv is not null))
      and em.id               = nf.empresa_id
      and pe.id               = em.pessoa_id
      and pe.cidade_id        = gn_cidade_id
      and nc.notafiscal_id(+) = nf.id
      and it.notafiscal_id    = nf.id
      and nt.notafiscal_id    = nf.id
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
    group by nf.id
        , nf.nro_nf
        , nf.serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss)
        , nf.pessoa_id
        , nf.dm_st_proc
        , pe.id
        , nc.dm_nat_oper
        , nc.cod_verif_nfs
        , nc.nro_aut_nfs
        , nc.dt_emiss_nfs
        , it.descr_item
        , it.cd_lista_serv
    order by nf.id;
   --
begin
   --
   vn_fase := 1;
   -- Registro Tipo 1 – Cabeçalho
   gl_conteudo := '1'; -- Tipo de registro
   gl_conteudo := gl_conteudo || '002'; -- Versão do Arquivo
   gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_inscr_mun_empresa ( en_empresa_id => gn_empresa_id ), '0'), 15, '0'); -- Inscrição Municipal do Contribuinte
   gl_conteudo := gl_conteudo || to_char(gd_dt_ini,'RRRRMMDD'); -- Data inicial
   gl_conteudo := gl_conteudo || to_char(gd_dt_fin,'RRRRMMDD'); -- Data final
   --
   vn_fase := 2;
   --
   vn_qtde_linhas := 0;
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_fase := 3;
   -- Registro Tipo 2 – Detalhes - Notas NFS-e inclusive RPS-C
   for rec in c_nfs
   loop
      --
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_fase := 4;
      --
      gl_conteudo := '2'; -- Tipo de registro
      --
      gl_conteudo := gl_conteudo || lpad(nvl(rec.nro_aut_nfs,0), 15, '0'); -- Número da NFS-e
      gl_conteudo := gl_conteudo || to_char(nvl(rec.dt_emiss_nfs,rec.dt_emiss), 'RRRRMMDDHHMISS'); -- Data/hora de emissão da NFS-e no formato AAAAMMDDHHmiSS
      gl_conteudo := gl_conteudo || rpad(substr(nvl(rec.cod_verif_nfs,' '),1,8), 8, ' '); -- Código de Verificação da NFS-e
      gl_conteudo := gl_conteudo || rpad('0', 1, ' '); -- Tipo do RPS: 0–Recibo Provis.Serv(RPS); 1–Recibo Provis.Serv.NFConjugada/Mista(RPS-M); 2–Recibo Provis.Serv.Cupom Fiscal(RPS-C).
      gl_conteudo := gl_conteudo || rpad(nvl(rec.serie,' '), 5, ' '); -- Série do RPS
      gl_conteudo := gl_conteudo || rpad(nvl(rec.nro_nf,0), 15, ' '); -- Número do RPS
      gl_conteudo := gl_conteudo || to_char(rec.dt_emiss, 'RRRRMMDD'); -- Data de Emissão do RPS no formato AAAAMMDD
      --
      vn_fase := 5;
      -- Dados do Prestador
      begin
         select pe.nome
              , pe.lograd
              , pe.nro
              , pe.compl
              , pe.bairro
              , ci.descr
              , es.sigla_estado
              , pe.cep
              , pe.email_forn
           into vv_nome
              , vv_lograd
              , vv_nro
              , vv_compl
              , vv_bairro
              , vv_cidade
              , vv_uf
              , vn_cep
              , vv_email
           from pessoa pe
              , cidade ci
              , estado es
          where pe.id = rec.pessoa_id
            and ci.id = pe.cidade_id
            and es.id = ci.estado_id;
      exception
         when others then
            vv_nome   := null;
            vv_lograd := null;
            vv_nro    := null;
            vv_compl  := null;
            vv_bairro := null;
            vv_cidade := null;
            vv_uf     := null;
            vn_cep    := null;
            vv_email  := null;
      end;
      --
      vn_fase := 6;
      --
      gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_inscr_mun_pessoa ( en_pessoa_id => rec.pessoa_id ), '0'), 15, '0'); -- Inscrição Municipal
      --
      vv_cpf_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => rec.pessoa_id);
      if length(vv_cpf_cnpj) = 11 then
         gl_conteudo := gl_conteudo || '1'; -- (1) Indicador de CPF/CNPJ
      elsif length(vv_cpf_cnpj) = 14 then
         gl_conteudo := gl_conteudo || '2'; -- (2) Indicador de CPF/CNPJ
      else
         gl_conteudo := gl_conteudo || '1'; -- ATENÇÃO!  Em caso de prestador do exterior, preencha o campo com 1.
      end if;
      gl_conteudo := gl_conteudo || lpad(nvl(vv_cpf_cnpj,'0'), 14, '0'); -- CPF ou CNPJ
      gl_conteudo := gl_conteudo || rpad(nvl(vv_nome,' '), 115, ' '); -- Razão Social
      gl_conteudo := gl_conteudo || rpad('Rua', 3, ' '); -- Tipo do Endereço (Rua, Av, ...)
      gl_conteudo := gl_conteudo || rpad(nvl(vv_lograd,' '), 100, ' '); -- Endereço
      gl_conteudo := gl_conteudo || rpad(nvl(vv_nro,' '), 10, ' '); -- Número do Endereço
      gl_conteudo := gl_conteudo || rpad(nvl(vv_compl,' '), 60, ' '); -- Complemento do Endereço
      gl_conteudo := gl_conteudo || rpad(nvl(vv_bairro,' '), 72, ' '); -- Bairro
      gl_conteudo := gl_conteudo || rpad(nvl(vv_cidade,' '), 50, ' '); -- Cidade
      gl_conteudo := gl_conteudo || rpad(nvl(vv_uf,' '), 2, ' '); -- UF
      gl_conteudo := gl_conteudo || lpad(nvl(vn_cep,0), 8, '0'); -- CEP
      gl_conteudo := gl_conteudo || rpad(nvl(vv_email,' '), 80, ' '); -- E-mail
      --
      vn_fase := 7;
      gl_conteudo := gl_conteudo || nvl(pk_csf.fkg_pessoa_valortipoparam_cd('1', rec.pessoa_id), '0'); -- Opção pelo Simples: 0-Não, 1-Sim
      --
      vn_fase := 8;
      -- Situação da Nota Fiscal: T-Oper.Normal, I-Oper.Isenta ou Não-Trib exec.no munic., F–Oper.Isenta ou Não-Tributável exec.outro Munic., C-Canc., J–ISS Suspenso por Decisão Judicial
      if rec.dm_st_proc in (7,8) then
         gl_conteudo := gl_conteudo || 'C'; -- Cancelada ou Inutilizada
      elsif rec.dm_nat_oper = 1 then
            gl_conteudo := gl_conteudo || 'T'; -- Tributação no Município
      elsif rec.dm_nat_oper = 2 then
            gl_conteudo := gl_conteudo || 'F'; -- Tributação Fora do Município
      elsif rec.dm_nat_oper in (3,4,8) then
            gl_conteudo := gl_conteudo || 'I'; -- 3-Isenta, 4-Imune
      elsif rec.dm_nat_oper in (5, 6) then
            gl_conteudo := gl_conteudo || 'J'; -- Operação Suspensa por Decisão Judicial
      else
         gl_conteudo := gl_conteudo || 'T'; -- Tributação no Município
      end if;
      --
      vn_fase := 9;
      --
      if rec.dm_st_proc = 7 then -- cancelamento
         --
         begin
            select a.dt_canc
              into vd_dt_canc
              from nota_fiscal_canc a
             where a.notafiscal_id = rec.notafiscal_id;
         exception
            when others then
               vd_dt_canc := null;
         end;
         --
         gl_conteudo := gl_conteudo || to_char(nvl(vd_dt_canc,' '),'RRRRMMDD'); -- Data de Cancelamento no formato AAAAMMDD
         --
      else
         --
         gl_conteudo := gl_conteudo || rpad(' ', 8, ' '); -- Data de Cancelamento no formato AAAAMMDD
         --
      end if;
      --
      vn_fase := 10;
      --
      gl_conteudo := gl_conteudo || lpad('0', 15, '0'); -- Número da Guia vinculada a NFS-e
      gl_conteudo := gl_conteudo || rpad(' ', 8, ' '); -- Data de quitação da guia vinculada a NFS-e
      --
      gl_conteudo := gl_conteudo || lpad((nvl(rec.vl_item_bruto,0)*100),15,'0'); -- Valor dos Serviços
      vn_vl_tot_serv := nvl(vn_vl_tot_serv,0) + nvl(rec.vl_item_bruto,0);
      --
      vn_fase := 11;
      --
      begin
         select nvl(sum(nvl(ii.vl_imp_trib,0)),0)
           into vn_vl_deducao
           from item_nota_fiscal it
              , imp_itemnf       ii
              , tipo_imposto     ti
          where it.notafiscal_id = rec.notafiscal_id
            and ii.itemnf_id     = it.id
            and ii.dm_tipo       = 1 -- Retenção
            and ti.id            = ii.tipoimp_id
            and ti.cd           <> '6'; -- Diferente de ISS
      exception
         when others then
            vn_vl_deducao := 0;
      end;
      --
      gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_deducao,0)*100),15,'0'); -- Valor das Deduções
      vn_vl_tot_deducao := nvl(vn_vl_tot_deducao,0) + nvl(vn_vl_deducao,0);
      --
      vn_fase := 12;
      --
      gl_conteudo := gl_conteudo || rpad(nvl(replace(nvl(rec.cd_lista_serv,0), '.', ''), ' '), 8); -- Código do Serviço Federal
      --
      vn_fase := 13;
      --
      begin
         select nvl(ii.aliq_apli,0)
              , nvl(sum(nvl(ii.vl_imp_trib,0)),0)
           into vn_aliq
              , vn_vl_imp_trib
           from item_nota_fiscal it
              , imp_itemnf       ii
              , tipo_imposto     ti
          where it.notafiscal_id = rec.notafiscal_id
            and ii.itemnf_id     = it.id
            and ii.dm_tipo       = 0 -- Imposto
            and ti.id            = ii.tipoimp_id
            and ti.cd            = '6'; -- ISS
      exception
         when others then
            vn_aliq        := 0;
            vn_vl_imp_trib := 0;
      end;
      --
      gl_conteudo := gl_conteudo || lpad((nvl(vn_aliq,0)*100),5,'0'); -- Alíquota
      gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_imp_trib,0)*100),15,'0'); -- Valor do ISS
      gl_conteudo := gl_conteudo || lpad((nvl(rec.vl_item_bruto,0)*100),15,'0'); -- Valor do Crédito
      --
      vn_vl_tot_iss  := nvl(vn_vl_tot_iss,0) + nvl(vn_vl_imp_trib,0);
      vn_vl_tot_cred := nvl(vn_vl_tot_cred,0) + nvl(rec.vl_item_bruto,0);
      --
      vn_fase := 14;
      --
      begin
         select nvl(sum(ii.vl_imp_trib),0)
           into vn_vl_imp_iss_ret
           from item_nota_fiscal it
              , imp_itemnf       ii
              , tipo_imposto     ti
          where it.notafiscal_id = rec.notafiscal_id
            and ii.itemnf_id     = it.id
            and ii.dm_tipo       = 1 -- Imposto
            and ti.id            = ii.tipoimp_id
            and ti.cd            = '6'; -- ISS
      exception
         when others then
            vn_vl_imp_iss_ret := 0;
      end;
      --
      if nvl(vn_vl_imp_iss_ret,0) > 0 then
         gl_conteudo := gl_conteudo || '1'; -- ISS Retido: 0-Não, 1-Sim
      else
         gl_conteudo := gl_conteudo || '0'; -- ISS Retido: 0-Não, 1-Sim
      end if;
      --
      vn_fase := 15;
      -- Dados do Tomador
      begin
         select pe.nome
              , pe.lograd
              , pe.nro
              , pe.compl
              , pe.bairro
              , ci.descr
              , es.sigla_estado
              , pe.cep
              , pe.email_forn
              , ju.iest
           into vv_nome
              , vv_lograd
              , vv_nro
              , vv_compl
              , vv_bairro
              , vv_cidade
              , vv_uf
              , vn_cep
              , vv_email
              , vv_iest
           from pessoa   pe
              , cidade   ci
              , estado   es
              , juridica ju
          where pe.id        = rec.pessoa_id_empresa
            and ci.id        = pe.cidade_id
            and es.id        = ci.estado_id
            and ju.pessoa_id = pe.id;
      exception
         when others then
            vv_nome   := null;
            vv_lograd := null;
            vv_nro    := null;
            vv_compl  := null;
            vv_bairro := null;
            vv_cidade := null;
            vv_uf     := null;
            vn_cep    := null;
            vv_email  := null;
            vv_iest   := null;
      end;
      --
      vn_fase := 16;
      --
      vv_cpf_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => rec.pessoa_id_empresa);
      if length(vv_cpf_cnpj) = 11 then
         gl_conteudo := gl_conteudo || '1'; -- (1) Indicador de CPF/CNPJ
      elsif length(vv_cpf_cnpj) = 14 then
         gl_conteudo := gl_conteudo || '2'; -- (2) Indicador de CPF/CNPJ
      else
         gl_conteudo := gl_conteudo || '3'; -- (3) Indicador para CPF não-informado
      end if;
      --
      gl_conteudo := gl_conteudo || lpad(nvl(vv_cpf_cnpj,'0'), 14, '0'); -- CPF ou CNPJ
      gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_inscr_mun_pessoa ( en_pessoa_id => rec.pessoa_id_empresa ), '0'), 15, '0'); -- Inscrição Municipal
      gl_conteudo := gl_conteudo || lpad(nvl(vv_iest,' '), 15, '0'); -- Inscrição Estadual
      gl_conteudo := gl_conteudo || rpad(nvl(vv_nome,' '), 115, ' '); -- Razão Social
      gl_conteudo := gl_conteudo || rpad('Rua', 3, ' '); -- Tipo do Endereço (Rua, Av, ...)
      gl_conteudo := gl_conteudo || rpad(nvl(vv_lograd,' '), 100, ' '); -- Endereço
      gl_conteudo := gl_conteudo || rpad(nvl(vv_nro,' '), 10, ' '); -- Número do Endereço
      gl_conteudo := gl_conteudo || rpad(nvl(vv_compl,' '), 60, ' '); -- Complemento do Endereço
      gl_conteudo := gl_conteudo || rpad(nvl(vv_bairro,' '), 72, ' '); -- Bairro
      gl_conteudo := gl_conteudo || rpad(nvl(vv_cidade,' '), 50, ' '); -- Cidade
      gl_conteudo := gl_conteudo || rpad(nvl(vv_uf,' '), 2, ' '); -- UF
      gl_conteudo := gl_conteudo || lpad(nvl(vn_cep,'0'), 8, '0'); -- CEP
      gl_conteudo := gl_conteudo || rpad(nvl(vv_email,' '), 80, ' '); -- E-mail
      --
      vn_fase := 17;
      --
      gl_conteudo := gl_conteudo || lpad((nvl(rec.vl_ret_cofins,0)*100),15,'0'); -- Valor COFINS
      gl_conteudo := gl_conteudo || lpad((nvl(rec.vl_ret_csll,0)*100),15,'0'); -- Valor CSLL
      gl_conteudo := gl_conteudo || lpad((nvl(rec.vl_ret_prev,0)*100),15,'0'); -- Valor INSS
      gl_conteudo := gl_conteudo || lpad((nvl(rec.vl_ret_irrf,0)*100),15,'0'); -- Valor IRPJ
      gl_conteudo := gl_conteudo || lpad((nvl(rec.vl_ret_pis,0)*100),15,'0'); -- Valor PIS
      --
      vn_vl_tot_ret_cofins := nvl(vn_vl_tot_ret_cofins,0) + nvl(rec.vl_ret_cofins,0); -- Valor COFINS
      vn_vl_tot_ret_csll   := nvl(vn_vl_tot_ret_csll,0)   + nvl(rec.vl_ret_csll,0); -- Valor CSLL
      vn_vl_tot_ret_prev   := nvl(vn_vl_tot_ret_prev,0)   + nvl(rec.vl_ret_prev,0); -- Valor INSS
      vn_vl_tot_ret_irrf   := nvl(vn_vl_tot_ret_irrf,0)   + nvl(rec.vl_ret_irrf,0); -- Valor IRPJ
      vn_vl_tot_ret_pis    := nvl(vn_vl_tot_ret_pis,0)    + nvl(rec.vl_ret_pis,0); -- Valor PIS
      --
      vn_fase := 18;
      --
      gl_conteudo := gl_conteudo || substr(pk_csf.fkg_converte(rec.descr_item),1,1000); -- Discriminação dos Serviços
      --
      vn_fase := 19;
      --
      vn_qtde_linhas := nvl(vn_qtde_linhas,0) + 1;
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
   end loop;
   --
   vn_fase := 20;
   -- Registro Tipo 9 – Rodapé
   gl_conteudo := '9'; --  Tipo de registro
   gl_conteudo := gl_conteudo || lpad(vn_qtde_linhas, 7, '0'); -- Número de linhas de detalhes
   gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_tot_serv,0)*100),15,'0'); -- Valor total dos serviços contido no arquivo
   gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_tot_deducao,0)*100),15,'0'); -- Valor total das deduções contidas no arquivo
   gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_tot_iss,0)*100),15,'0'); -- Valor total do ISS
   gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_tot_cred,0)*100),15,'0'); -- Valor total dos créditos
   gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_tot_ret_cofins,0)*100),15,'0'); -- Valor total das retenções de COFINS
   gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_tot_ret_csll,0)*100),15,'0'); -- Valor total das retenções de CSLL
   gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_tot_ret_prev,0)*100),15,'0'); -- Valor total das retenções de INSS
   gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_tot_ret_irrf,0)*100),15,'0'); -- Valor total das retenções de IRPJ
   gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_tot_ret_pis,0)*100),15,'0'); -- Valor total das retenções de PIS
   --
   vn_fase := 21;
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_1302603 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_1302603;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Recife / PE
procedure pkb_gera_arq_cid_2611606 is
   --
   vn_fase            number := 0;
   vn_qtde_linhas     number := 0;
   vn_vl_total_serv   number := 0;
   vn_vl_total_dedu   number := 0;
   vv_cpf_cnpj        varchar2(14);
   vv_nome            pessoa.nome%type;
   vv_lograd          pessoa.lograd%type;
   vv_nro             pessoa.nro%type;
   vv_compl           pessoa.compl%type;
   vv_bairo           pessoa.bairro%type;
   vn_cep             pessoa.cep%type;
   vv_fone            pessoa.fone%type;
   vv_email           pessoa.email%type;
   vv_uf              estado.sigla_estado%type;
   vv_cidade          cidade.descr%type;
   vn_aliq            number := 0;
   vn_vl_imp_trib     number := 0;
   vn_vl_deducao      number := 0;
   vn_vl_imp_iss_ret  number := 0;
   --
   cursor c_nfs is
   select nf.id         notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss) dt_emiss
        , nf.pessoa_id
        , ncs.cidademodfiscal_id
        , ncs.dt_exe_serv
        , ncs.dm_nat_oper
        , inf.vl_item_bruto
        , inf.cd_lista_serv
        , inf.descr_item
        , ics.codtribmunicipio_id
        , ics.cidadebeneficfiscal_id
        , ics.cnae
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , nf_compl_serv  ncs
        , item_nota_fiscal inf
        , itemnf_compl_serv ics
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id
      and nf.id              = ncs.notafiscal_id (+)
      and nf.id              = inf.notafiscal_id
      and inf.id             = ics.itemnf_id (+)
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
    order by nf.id;
   --
begin
   --
   vn_fase := 1;
   --
   -- Registro Tipo 10 – Cabeçalho
   --
   gl_conteudo := '10'; -- Tipo de registro
   gl_conteudo := gl_conteudo || '003'; -- Versão do Arquivo
   gl_conteudo := gl_conteudo || '2'; -- CNPJ
   gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => gn_empresa_id ), '0'), 14, '0'); -- CPF ou CNPJ do Contribuinte
   gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_inscr_mun_empresa ( en_empresa_id => gn_empresa_id ), '0'), 15, '0'); -- Inscrição Municipal do Contribuinte
   gl_conteudo := gl_conteudo || to_char(gd_dt_ini,'RRRRMMDD'); -- Data inicial
   gl_conteudo := gl_conteudo || to_char(gd_dt_fin,'RRRRMMDD'); -- Data final
   --
   vn_fase := 1.1;
   --
   vn_qtde_linhas := 0;
   --
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   -- Registro Tipo 40 – Declaração de Notas Convencionais Recebidas
   --
   for rec in c_nfs loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      gl_conteudo := '40'; -- Tipo de registro
      --
      gl_conteudo := gl_conteudo || '01'; -- Tipo de Documento - Nota Fiscal
      gl_conteudo := gl_conteudo || rpad(rec.serie, 5, ' '); -- Série da Nota Convencional
      gl_conteudo := gl_conteudo || lpad(rec.nro_nf, 15, '0'); -- Número da Nota Convencional
      gl_conteudo := gl_conteudo || to_char(rec.dt_emiss, 'RRRRMMDD'); -- Data de Emissão da Nota Convencional
      gl_conteudo := gl_conteudo || '1'; -- Status da Nota Convencional - Normal
      --
      -- Recupera os dados do Participante
      --
      begin
         --
         select p.nome
              , p.lograd
              , p.nro
              , p.compl
              , p.bairro
              , p.cep
              , p.fone
              , p.email_forn
              , c.descr
              , e.sigla_estado
           into vv_nome
              , vv_lograd
              , vv_nro
              , vv_compl
              , vv_bairo
              , vn_cep
              , vv_fone
              , vv_email
              , vv_cidade
              , vv_uf
           from pessoa p
              , cidade c
              , estado e
          where p.id = rec.pessoa_id
            and p.cidade_id = c.id
            and c.estado_id = e.id;
         --
      exception
         when others then
         --
         vv_nome            := null;
         vv_uf              := null;
         vv_cidade          := null;
         --
      end;
      --
      vn_fase := 2.2;
      --
      vv_cpf_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec.pessoa_id );
      --
      vn_fase := 2.3;
      --
      if length(vv_cpf_cnpj) = 11 then
         gl_conteudo := gl_conteudo || '1'; -- (1) CPF
         gl_conteudo := gl_conteudo || lpad(nvl(vv_cpf_cnpj,'0'), 14, '0'); -- CPF ou CNPJ do Prestador
      elsif length(vv_cpf_cnpj) = 14 then
         gl_conteudo := gl_conteudo || '2'; -- (2) CNPJ
         gl_conteudo := gl_conteudo || lpad(nvl(vv_cpf_cnpj,'0'), 14, '0'); -- CPF ou CNPJ do Prestador
      else
         gl_conteudo := gl_conteudo || '1'; -- ATENÇÃO!  Em caso de prestador do exterior, preencha o campo com 1.
         gl_conteudo := gl_conteudo || '999.999.990-50'; -- CPF ou CNPJ do Prestador
      end if;
      --
      gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_inscr_mun_pessoa ( en_pessoa_id => rec.pessoa_id ), '0'), 15, '0'); -- Inscrição Municipal do Prestador
      gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_ie_pessoa_id ( en_pessoa_id => rec.pessoa_id ), '0'), 15, '0'); -- Inscrição Estadual do Prestador
      gl_conteudo := gl_conteudo || rpad(nvl(vv_nome, ' '), 115); -- Nome ou Razão Social do Prestador
      gl_conteudo := gl_conteudo || 'Rua'; -- Tipo do Endereço do Prestador (Rua, Av, ...)
      gl_conteudo := gl_conteudo || rpad(nvl(vv_lograd, ' '), 125); -- Endereço do Prestador
      gl_conteudo := gl_conteudo || rpad(nvl(substr(vv_nro,1,10), ' '), 10); -- Número do endereço do Prestador
      gl_conteudo := gl_conteudo || rpad(nvl(vv_compl, ' '), 60); -- Complemento do Endereço do Prestador
      gl_conteudo := gl_conteudo || rpad(nvl(vv_bairo, ' '), 72); -- Bairro do Prestador
      gl_conteudo := gl_conteudo || rpad(nvl(vv_cidade, ' '), 50); -- Cidade do Prestador
      gl_conteudo := gl_conteudo || rpad(nvl(vv_uf, ' '), 2); -- UF do Prestador
      gl_conteudo := gl_conteudo || lpad(nvl(vn_cep, '0'), 8, '0'); -- CEP do Prestador
      gl_conteudo := gl_conteudo || rpad(nvl(substr(vv_fone,1,11), ' '), 11); -- Telefone de contato do Prestador
      gl_conteudo := gl_conteudo || rpad(nvl(substr(vv_email,1,80), ' '), 80); -- Email do Prestador
      --
      -- Tipo de Tributação Serviços
      if rec.dm_nat_oper = 1 then
         gl_conteudo := gl_conteudo || '01'; -- Tributação no Município
      elsif rec.dm_nat_oper = 2 then
         gl_conteudo := gl_conteudo || '02'; -- Tributação Fora do Município
      elsif rec.dm_nat_oper in (3,8) then
         gl_conteudo := gl_conteudo || '03'; -- Isenta
      elsif rec.dm_nat_oper = 4 then
         gl_conteudo := gl_conteudo || '04'; -- Imune
      elsif rec.dm_nat_oper in (5, 6) then
         gl_conteudo := gl_conteudo || '05'; -- Operação Suspensa por Decisão Judicial
      else
         gl_conteudo := gl_conteudo || '01'; -- Tributação no Município
      end if;
      --
      gl_conteudo := gl_conteudo || rpad(' ', 54); -- Reservado
      gl_conteudo := gl_conteudo || nvl(pk_csf.fkg_pessoa_valortipoparam_cd('1', rec.pessoa_id), '0'); -- Opção Pelo Simples (0) Não (1) Sim
      gl_conteudo := gl_conteudo || rpad(nvl(replace(rec.cd_lista_serv, '.', ''), ' '), 4); -- Código do Serviço Federal
      gl_conteudo := gl_conteudo || lpad(nvl(trim(rec.cnae), '0'), 20, '0');
      --
      begin
         --
         select nvl(sum(ii.aliq_apli),0)
              , nvl(sum(ii.vl_imp_trib),0)
           into vn_aliq
              , vn_vl_imp_trib
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.dm_tipo        = 0 -- Imposto
            and ti.id             = ii.tipoimp_id
            and ti.cd = '6'; -- ISS
         --
      exception
         when others then
            vn_aliq := 0;
            vn_vl_imp_trib := 0;
      end;
      --
      gl_conteudo := gl_conteudo || lpad((nvl(vn_aliq,0)*100),5,'0'); -- Alíquota
      gl_conteudo := gl_conteudo || lpad((nvl(rec.vl_item_bruto,0)*100),15,'0'); -- Valor dos Serviços
      --
      vn_vl_total_serv := nvl(vn_vl_total_serv,0) + nvl(rec.vl_item_bruto,0);
      --
      --
      begin
         --
         select nvl(sum(ii.vl_imp_trib),0)
           into vn_vl_deducao
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.dm_tipo        = 1 -- Retenção
            and ti.id             = ii.tipoimp_id
            and ti.cd <> '6'; -- ISS
         --
      exception
         when others then
         --
         vn_vl_deducao := 0;
         --
      end;
      --
      gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_deducao,0)*100),15,'0'); -- Valor das Deduções
      --
      vn_vl_total_dedu := nvl(vn_vl_total_dedu,0) + nvl(vn_vl_deducao,0);
      --
      gl_conteudo := gl_conteudo || rpad(' ', 30); -- Reservado
      gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_imp_trib,0)*100),15,'0'); -- Valor do ISS
      --
      begin
         --
         select nvl(sum(ii.vl_imp_trib),0)
           into vn_vl_imp_iss_ret
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.dm_tipo        = 1 -- Imposto
            and ti.id             = ii.tipoimp_id
            and ti.cd = '6'; -- ISS
         --
      exception
         when others then
            vn_vl_imp_iss_ret := 0;
      end;
      --
      if nvl(vn_vl_imp_iss_ret,0) > 0 then
         --
         gl_conteudo := gl_conteudo || '1';
         --
      else
         --
         gl_conteudo := gl_conteudo || '0';
         --
      end if;
      --
      gl_conteudo := gl_conteudo || to_char(rec.dt_exe_serv, 'RRRRMMDD'); -- Data de Competência
      gl_conteudo := gl_conteudo || rpad(' ', 30); -- Reservado
      gl_conteudo := gl_conteudo || rpad(' ', 15); -- Código da Obra
      gl_conteudo := gl_conteudo || rpad(' ', 15); -- Anotação de Responsabilidade Técnica
      gl_conteudo := gl_conteudo || rec.descr_item; -- Discriminação dos Serviços
      --
      vn_qtde_linhas := vn_qtde_linhas + 1;
      --
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
   end loop;
   --
   -- Registro Tipo 90 – Rodapé
   --
   --vn_qtde_linhas := vn_qtde_linhas + 1;
   --
   gl_conteudo := '90'; --  Tipo de registro
   gl_conteudo := gl_conteudo || lpad(vn_qtde_linhas, 8, '0'); -- Número de linhas de detalhe do arquivo
   gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_total_serv,0)*100),15,'0'); -- Valor total dos serviços contido no arquivo
   gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_total_dedu,0)*100),15,'0'); -- Valor total das deduções  contidas no arquivo
   gl_conteudo := gl_conteudo || lpad('0', 15, '0'); -- Valor total dos descontos condicionados contidos no arquivo
   gl_conteudo := gl_conteudo || lpad('0', 15, '0'); -- Valor total dos descontos incondicionadocontidos no arquivo
   --
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_2611606 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_2611606;

---------------------------------------------------------------------------------------------------------------------
-- Processo de Exportação de Notas Fiscais de Serviços Tomados para Itatiba / SP
procedure pkb_gera_arq_cid_3523404 is
   --
   vn_fase                      number;
   vv_cd_lista_serv             varchar2(10);
   vv_cd_serv_prest             varchar2(5);
   vv_cnpj_tomador              varchar2(14);
   vv_cfop                      varchar2(12);
   --    
   vv_nome                      pessoa.nome%type;
   vv_im                        juridica.im%type;
   vv_ie_rg                     varchar2(15);
   vn_aliq_aplic                imp_itemnf.aliq_apli%type;
   vn_retido                    number;
   --
   vv_lograd                    pessoa.lograd%type;
   vv_nro                       pessoa.nro%type;
   vv_compl                     pessoa.compl%type;
   vv_bairro                    pessoa.bairro%type;
   vv_ibge_cidade               cidade.ibge_cidade%type;
   vv_descr_cid                 cidade.descr%type;
   vv_sg_estado                 estado.sigla_estado%type;
   vv_cep                       varchar2(8);
   --
   vv_email                     pessoa.email%type;
   vv_end_cobr                  varchar2(35);
   vn_count                     number;
   vn_total_vl_serv             number;
   vn_total_vl_deducao          number;
   vn_total_impostos            number;
   vv_cfps                      varchar2(3);
   --
    cursor c_nfs is
     select nf.id          notafiscal_id
          , nf.nro_nf
          , nf.serie
          , nf.dt_emiss
          , ncs.dm_nat_oper
          , nft.vl_total_nf
          , nft.vl_imp_trib_iss
          , nft.vl_ret_iss -- iss_retido
          , nft.vl_ret_irrf
          , nft.vl_ret_pis
          , nft.vl_ret_cofins
          , nft.vl_ret_csll
          , nft.vl_ret_prev
          , nf.pessoa_id
          , nft.vl_deducao
          , mf.cod_mod
          , inf.descr_item
          , inf.cd_lista_serv
       from nota_fiscal nf
          , mod_fiscal mf
          , empresa e
          , pessoa p
          , nf_compl_serv  ncs
          , item_nota_fiscal inf
          , itemnf_compl_serv ics
          , nota_fiscal_total nft
      where nf.empresa_id      = gn_empresa_id
        and nf.dm_ind_emit     = gn_dm_ind_emit
        and nf.dm_st_proc      = 4
        and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
        and mf.id              = nf.modfiscal_id
        and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
        and e.id               = nf.empresa_id
        and nf.id              = nft.notafiscal_id
        and p.id               = e.pessoa_id
        and p.cidade_id        = gn_cidade_id
        and nf.id              = ncs.notafiscal_id (+)
        and nf.id              = inf.notafiscal_id
        and inf.id             = ics.itemnf_id (+)
        and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
      order by nf.id;
   --
begin
   --
   vn_fase := 1;
   vn_count := 0;
   vn_total_vl_serv := 0;
   vn_total_vl_deducao := 0;
   vn_total_impostos := 0;
   --
   -- Cabeçalho do Arquivo.
   --
   gl_conteudo := '0'; -- Tipo Registro
   gl_conteudo := gl_conteudo || 'T'; -- TipodeDeclaracao
   gl_conteudo := gl_conteudo || '1'; -- TpIdentificacao 1-CNPJ
   gl_conteudo := gl_conteudo || pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => gn_empresa_id );
   gl_conteudo := gl_conteudo || to_char(gd_dt_ini, 'mm'); -- MesReferencia
   gl_conteudo := gl_conteudo || to_char(gd_dt_ini, 'rrrr'); -- AnoReferencia
   gl_conteudo := gl_conteudo || to_char(sysdate, 'yyyymmdd'); -- DtLancamento
   gl_conteudo := gl_conteudo || 'N'; -- TpReferencia
   gl_conteudo := gl_conteudo || '02'; -- VersaoLayout
   gl_conteudo := gl_conteudo || rpad(' ', 66, ' '); -- filler
   --
   -- Armazena a estrutura do arquivo.
   --
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_fase := 2;
   --
   for rec in c_nfs loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      gl_conteudo := '1'; -- Tipo de registro
      --
      vn_fase := 3;
      --
      vv_cnpj_tomador := pk_csf.fkg_cnpjcpf_pessoa_id( en_pessoa_id => rec.pessoa_id );
      -- TpIdentificacao
      if length(vv_cnpj_tomador) = '11' then -- CPF
         gl_conteudo := gl_conteudo || '2';
      elsif length(vv_cnpj_tomador) = '14' then -- CNPJ
         gl_conteudo := gl_conteudo || '1';
      else
         gl_conteudo := gl_conteudo || '1';
      end if;
      --
      gl_conteudo := gl_conteudo || rpad(vv_cnpj_tomador, 14, '0');
      --
      vn_fase := 3.1;
      --
      vv_nome       := null;
      vv_im         := null;
      vv_ie_rg      := null;
      vv_lograd     := null;
      vv_nro        := null;
      vv_compl      := null;
      vv_bairro     := null;
      vv_descr_cid  := null;
      vv_sg_estado  := null;
      vv_ibge_cidade:= null;
      vv_cep        := null;
      vv_email      := null;
      vv_end_cobr   := null;
      --
      begin
         select p.nome
              , j.im
              , nvl(j.ie,f.rg)
              , p.lograd
              , p.nro
              , p.compl
              , p.bairro
              , c.descr
              , e.sigla_estado
              , c.ibge_cidade
              , p.cep
              , p.email
              , trim(substr(p.lograd||' '||p.nro, 1, 35))
           into vv_nome
              , vv_im
              , vv_ie_rg
              , vv_lograd
              , vv_nro
              , vv_compl
              , vv_bairro
              , vv_descr_cid
              , vv_sg_estado
              , vv_ibge_cidade
              , vv_cep
              , vv_email
              , vv_end_cobr
           from pessoa p
              , fisica f
              , juridica j
              , cidade c
              , estado e
          where p.id           = rec.pessoa_id
            and f.pessoa_id(+) = p.id 
            and j.pessoa_id(+) = p.id
            and p.cidade_id    = c.id
            and c.estado_id    = e.id;
      exception
         when others then
            vv_nome       := null;
            vv_im         := null;
            vv_ie_rg      := null;
            vv_lograd     := null;
            vv_nro        := null;
            vv_compl      := null;
            vv_bairro     := null;
            vv_descr_cid  := null;
            vv_sg_estado  := null;
            vv_ibge_cidade:= null;
            vv_cep        := null;
            vv_email      := null;
            vv_end_cobr   := null;
      end;
      --
      vn_fase := 3.1;
      --
      gl_conteudo := gl_conteudo || rpad(nvl(trim(vv_nome), ' '),100, ' '); -- Nome da Empresa
      gl_conteudo := gl_conteudo || rpad(nvl(trim(vv_descr_cid), ' '),60, ' '); -- Cidade da Empresa
      gl_conteudo := gl_conteudo || rpad(nvl(trim(vv_sg_estado), ' '),2, ' '); -- Estado da Empresa
      gl_conteudo := gl_conteudo || lpad(rec.nro_nf,8,'0'); -- Número do Documento
      gl_conteudo := gl_conteudo || to_char(rec.dt_emiss, 'ddmmrrrr'); -- Data da prestação dos serviços
      gl_conteudo := gl_conteudo || lpad(trim(nvl(rec.vl_total_nf,0)*100),14,0); -- Valor Total de Serviço
      gl_conteudo := gl_conteudo || lpad(nvl(rec.vl_deducao,0) * 100,14,0); -- Valor Dedução Base
      --
      vn_fase := 4;
      --
      vn_aliq_aplic := null;
      vn_retido := null;
      --
      begin
         select distinct(ii.aliq_apli)
           into vn_aliq_aplic
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id  = rec.notafiscal_id
            and inf.id             = ii.itemnf_id
            and ii.dm_tipo         = 1 -- Retido
            and ii.tipoimp_id      = ti.id
            and ti.cd              = 6 -- ISS
            and inf.cd_lista_serv is not null;
      exception
         when others then
            vn_aliq_aplic := 0;
      end;
      --
      vn_fase := 4.1;
      --
      if nvl(vn_aliq_aplic,0) <= 0 then
         --
         begin
            select distinct(ii.aliq_apli)
              into vn_aliq_aplic
              from item_nota_fiscal inf
                 , imp_itemnf ii
                 , tipo_imposto ti
             where inf.notafiscal_id  = rec.notafiscal_id
               and inf.id             = ii.itemnf_id
               and ii.dm_tipo         = 0 -- Normal
               and ii.tipoimp_id      = ti.id
               and ti.cd              = 6 -- ISS
               and inf.cd_lista_serv is not null;
         exception
            when others then
               vn_aliq_aplic := 0;
         end;
         --
         vn_retido := 2; -- NFTS sem ISS Retido
         --
      else
         --
         vn_retido := 1; -- ISS Retido.
         --
      end if;
      --
      vn_fase := 4.2;
      --
      if vn_retido = 1 then -- ISS Retido
         --
         gl_conteudo := gl_conteudo || lpad(nvl(vn_aliq_aplic,0)*100,5,0);
         gl_conteudo := gl_conteudo || lpad(nvl(rec.vl_ret_iss,0) * 100,14,0);
         gl_conteudo := gl_conteudo || 'S';
         --
         vn_total_impostos := nvl(vn_total_impostos,0) + (nvl(rec.vl_ret_iss,0) * 100);
         --
      else
         --
         gl_conteudo := gl_conteudo || lpad(nvl(vn_aliq_aplic,0)*100,5,0);
         gl_conteudo := gl_conteudo || lpad(nvl(rec.vl_imp_trib_iss,0) * 100,14,0);
         gl_conteudo := gl_conteudo || 'N';
         --
         vn_total_impostos := nvl(vn_total_impostos,0) + (nvl(rec.vl_imp_trib_iss,0) * 100);
         --
      end if;
      --
      vn_fase := 5;
      --
      gl_conteudo := gl_conteudo || '1'; -- Situação da Nota Fiscal
      --
      -- CodAtividade
      gl_conteudo := gl_conteudo || lpad(nvl(trim(rec.cd_lista_serv), 0), 6, '0');
      --
      --
      vn_fase := 6;
      -- Cfps
      if rec.dm_nat_oper = 1 then -- Tributação no município
         --
         -- UNIDADE DESCRIÇÃO DO DESTINO DO SERVIÇO PRESTADO
         vv_cfps := '5'; --  PRESTAÇÃO DE SERVIÇO NO MUNICÍPIO SEDE;
         --
         -- UNIDADE DESCRIÇÃO DA FORMA DE TRIBUTAÇÃO
         vv_cfps := vv_cfps || '9'; -- OUTRAS OPERAÇÕES
         --
         -- UNIDADE DESCRIÇÃO DO LOCAL ONDE O ISSQN É DEVIDO
         if vn_retido = 1 then -- ISS Retido
            vv_cfps := vv_cfps || '2'; -- ISSQN DEVIDO NA ORIGEM (com retenção na fonte);
         else
            vv_cfps := vv_cfps || '1'; -- ISSQN DEVIDO NA ORIGEM (sem retenção na fonte);
         end if;
         --
      elsif rec.dm_nat_oper = 2 then -- Tributação fora do município
         --
         -- UNIDADE DESCRIÇÃO DO DESTINO DO SERVIÇO PRESTADO
         vv_cfps := '6'; -- PRESTAÇÃO DE SERVIÇO EM OUTRO MUNICÍPIO DA FEDERAÇÃO
         --
         -- UNIDADE DESCRIÇÃO DA FORMA DE TRIBUTAÇÃO
         vv_cfps := vv_cfps || '9'; -- OUTRAS OPERAÇÕES
         --
         -- UNIDADE DESCRIÇÃO DO LOCAL ONDE O ISSQN É DEVIDO
         if vn_retido = 1 then -- ISS Retido
            vv_cfps := vv_cfps || '3'; --  ISSQN DEVIDO NO DESTINO (com retenção na fonte);
         else
            vv_cfps := vv_cfps || '4'; --  ISSQN DEVIDO NO DESTINO (sem a retenção na fonte);
         end if;
         --
      elsif rec.dm_nat_oper = 7 then -- Exportação
         --
         -- UNIDADE DESCRIÇÃO DO DESTINO DO SERVIÇO PRESTADO
         vv_cfps := '7'; --  PRESTAÇÃO DE SERVIÇO PARA O EXTERIOR
         --
         -- UNIDADE DESCRIÇÃO DA FORMA DE TRIBUTAÇÃO
         vv_cfps := vv_cfps || '9'; -- OUTRAS OPERAÇÕES
         --
         -- UNIDADE DESCRIÇÃO DO LOCAL ONDE O ISSQN É DEVIDO
         if vn_retido = 1 then -- ISS Retido
            vv_cfps := vv_cfps || '2'; -- ISSQN DEVIDO NA ORIGEM (com retenção na fonte);
         else
            vv_cfps := vv_cfps || '1'; -- ISSQN DEVIDO NA ORIGEM (sem retenção na fonte);
         end if;
         --
      else
         --
         -- UNIDADE DESCRIÇÃO DO DESTINO DO SERVIÇO PRESTADO
         vv_cfps := '5'; --  PRESTAÇÃO DE SERVIÇO NO MUNICÍPIO SEDE;
         --
         -- UNIDADE DESCRIÇÃO DA FORMA DE TRIBUTAÇÃO
         if rec.dm_nat_oper in (3,8) then -- ISenção
            --
            vv_cfps := vv_cfps || '3'; --  ISENTO
            --
            -- UNIDADE DESCRIÇÃO DO LOCAL ONDE O ISSQN É DEVIDO
            vv_cfps := vv_cfps || '9'; -- NT­ SERVIÇO NÃO CONSTANTE DA LS/ ISENTO/IMUNE.
            --
         elsif rec.dm_nat_oper = 4 then -- Imune
            --
            vv_cfps := vv_cfps || '4'; -- IMUNE
            --
            -- UNIDADE DESCRIÇÃO DO LOCAL ONDE O ISSQN É DEVIDO
            vv_cfps := vv_cfps || '9'; -- NT­ SERVIÇO NÃO CONSTANTE DA LS/ ISENTO/IMUNE.
            --
         else
            --
            vv_cfps := vv_cfps || '9'; -- OUTRAS OPERAÇÕES
            --
            -- UNIDADE DESCRIÇÃO DO LOCAL ONDE O ISSQN É DEVIDO
            vv_cfps := vv_cfps || '1'; -- ISSQN DEVIDO NA ORIGEM (sem retenção na fonte)
            --
         end if;
         --
      end if;
      --
      gl_conteudo := gl_conteudo || lpad(vv_cfps, 3, '0');
      --
      vn_fase := 7;
      --
      gl_conteudo := gl_conteudo || '17'; -- Serie
      gl_conteudo := gl_conteudo || rpad(' ', 96, ' '); -- filler
      --
      vn_total_vl_serv := nvl(vn_total_vl_serv,0) + (nvl(rec.vl_total_nf,0)*100);
      vn_total_vl_deducao := nvl(vn_total_vl_deducao,0) + (nvl(rec.vl_deducao,0) * 100);
      --
      vn_fase := 8;
      --
      -- Armazena a estrutura do arquivo.
      --
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
      vn_count := vn_count + 1;
      --
   end loop;
   --
   -- Linha de Rodapé
   vn_fase := 9;
   --
   gl_conteudo := '9'; -- Tipo de Registro
   gl_conteudo := gl_conteudo || lpad(nvl(vn_count,0),4,0); --  Número de linhas de detalhe do arquivo
   gl_conteudo := gl_conteudo || lpad(nvl(vn_total_vl_serv,0),14,0);
   gl_conteudo := gl_conteudo || lpad(nvl(vn_total_vl_deducao,0),14,0);
   gl_conteudo := gl_conteudo || lpad(nvl(vn_total_impostos,0),14,0);
   gl_conteudo := gl_conteudo ||rpad(' ', 53, ' '); -- filler
   --
   -- Armazena a estrutura do arquivo
   --
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_fase := 10;
   --
EXCEPTION
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_3523404 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_3523404;

---------------------------------------------------------------------------------------------------------------------
-- Processo de Exportação de Notas Fiscais de Serviços Tomados para São Paulo / SP
procedure pkb_gera_arq_cid_3550308 is
  --
  vn_fase             number;
  vv_cd_lista_serv    varchar2(10);
  vv_cd_serv_prest    varchar2(5);
  vv_cnpj_tomador     varchar2(14);
  vv_cfop             varchar2(12);
  --
  vv_nome             pessoa.nome%type;
  vv_im               juridica.im%type;
  vv_ie_rg            varchar2(15);
  vn_aliq_aplic       imp_itemnf.aliq_apli%type;
  vn_retido           number;
  --
  vv_lograd           pessoa.lograd%type;
  vv_nro              pessoa.nro%type;
  vv_compl            pessoa.compl%type;
  vv_bairro           pessoa.bairro%type;
  vv_ibge_cidade      cidade.ibge_cidade%type;
  vv_descr_cid        cidade.descr%type;
  vv_sg_estado        estado.sigla_estado%type;
  vv_cep              varchar2(8);
  --
  vv_email            pessoa.email%type;
  vv_end_cobr         varchar2(35);
  vn_count            number;
  vn_total_vl_serv    number;
  vn_total_vl_deducao number;
  vv_tp_serv_descr    tipo_servico.descr%type;
  --
  vv_reg_trib                    varchar2(1);
  vv_valor_tipo_param_cd_regtrib valor_tipo_param.cd%type;
  vv_valor_tipo_param_cd_sn      valor_tipo_param.cd%type;
  vd_dt_ini_abert                date;
  --
  cursor c_nfs is
    select distinct nf.id notafiscal_id,
                    nf.nro_nf,
                    nf.serie,
                    case
                      when nf.dm_ind_emit = 1 then
                       nf.dt_sai_ent
                      when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 then
                       nf.dt_emiss
                      when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and
                           gn_dm_dt_escr_dfepoe = 0 then
                       nf.dt_emiss
                      when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 then
                       nvl(nf.dt_sai_ent, nf.dt_emiss)
                    end dt_emiss,
                    nf.dt_sai_ent,
                    ncs.dm_nat_oper,
                    ncs.dt_exe_serv,
                    nft.vl_total_nf,
                    nft.vl_ret_iss, -- iss_retido
                    nft.vl_ret_irrf,
                    nft.vl_ret_pis,
                    nft.vl_ret_cofins,
                    nft.vl_ret_csll,
                    nft.vl_ret_prev,
                    nf.pessoa_id,
                    nft.vl_deducao,
                    mf.cod_mod,
                    inf.cd_lista_serv,
                    ics.codtribmunicipio_id,
                    nft.vl_total_serv
      from nota_fiscal       nf,
           mod_fiscal        mf,
           empresa           e,
           pessoa            p,
           nf_compl_serv     ncs,
           item_nota_fiscal  inf,
           itemnf_compl_serv ics,
           nota_fiscal_total nft
     where nf.empresa_id  = gn_empresa_id
       and nf.dm_ind_emit = gn_dm_ind_emit
       and nf.dm_st_proc  = 4
       and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between gd_dt_ini and gd_dt_fin) or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
       and mf.id = nf.modfiscal_id
       and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and trim(inf.cd_lista_serv) is not null))
       and e.id        = nf.empresa_id
       and nf.id       = nft.notafiscal_id
       and p.id        = e.pessoa_id
       and p.cidade_id = gn_cidade_id
       and nf.id       = ncs.notafiscal_id(+)
       and nf.id       = inf.notafiscal_id
       and inf.id      = ics.itemnf_id(+)
       and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
     order by nf.id;
  --
begin
  --
  vn_fase             := 1;
  vn_count            := 0;
  vn_total_vl_serv    := 0;
  vn_total_vl_deducao := 0;
  --
  vd_dt_ini_abert := null;
  --
  begin
    --
    select min(nvl(ncs.dt_exe_serv,
                   nvl(nf.dt_sai_ent,
                       case
                         when nf.dm_ind_emit = 1 then
                          nf.dt_sai_ent
                         when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 then
                          nf.dt_emiss
                         when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and 1 = 0 then
                          nf.dt_emiss
                         when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and 1 = 1 then
                          nvl(nf.dt_sai_ent, nf.dt_emiss)
                       end))) /*min(nf.dt_sai_ent)*/
      into vd_dt_ini_abert
      from nota_fiscal       nf,
           mod_fiscal        mf,
           empresa           e,
           pessoa            p,
           nf_compl_serv     ncs,
           item_nota_fiscal  inf,
           itemnf_compl_serv ics,
           nota_fiscal_total nft,
           pessoa            p1
     where nf.empresa_id  = gn_empresa_id
       and nf.dm_ind_emit = gn_dm_ind_emit
       and nf.dm_st_proc  = 4
       and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between gd_dt_ini and gd_dt_fin) or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
       and mf.id = nf.modfiscal_id
       and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and trim(inf.cd_lista_serv) is not null))
       and e.id         = nf.empresa_id
       and nf.id        = nft.notafiscal_id
       and p.id         = e.pessoa_id
       and p.cidade_id  = gn_cidade_id
       and nf.id        = ncs.notafiscal_id(+)
       and nf.id        = inf.notafiscal_id
       and inf.id       = ics.itemnf_id(+)
       and nf.pessoa_id = p1.id
       and p1.cidade_id <> gn_cidade_id
       and nvl(nf.dm_arm_nfe_terc, 0) = 0; -- #73514
    /*order by nf.id;*/
    --
  exception
    when others then
      vd_dt_ini_abert := null;
  end;
  --
  vn_fase := 2;
  --
  -- Cabeçalho do Arquivo.
  --
  gl_conteudo := '1'; -- Tipo Registro
  gl_conteudo := gl_conteudo || '001'; -- Versão
  gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_inscr_mun_empresa(en_empresa_id => gn_empresa_id), '0'), 8, '0'); --I.M. do Contribuinte
  gl_conteudo := gl_conteudo || to_char(nvl(vd_dt_ini_abert, gd_dt_ini), 'yyyymmdd'); -- Data inicial
  gl_conteudo := gl_conteudo || to_char(gd_dt_fin, 'yyyymmdd'); -- Data final
  --
  -- Armazena a estrutura do arquivo.
  --
  pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
  --
  vn_fase := 2;
  --
  for rec in c_nfs loop
    exit when c_nfs%notfound or(c_nfs%notfound) is null;
    --
    vn_fase := 2.1;
    --
    --
    vv_nome        := null;
    vv_im          := null;
    vv_ie_rg       := null;
    vv_lograd      := null;
    vv_nro         := null;
    vv_compl       := null;
    vv_bairro      := null;
    vv_descr_cid   := null;
    vv_sg_estado   := null;
    vv_ibge_cidade := null;
    vv_cep         := null;
    vv_email       := null;
    vv_end_cobr    := null;
    --
    begin
      select p.nome,
             j.im,
             nvl(j.ie, f.rg),
             p.lograd,
             p.nro,
             p.compl,
             p.bairro,
             c.descr,
             e.sigla_estado,
             c.ibge_cidade,
             p.cep,
             p.email,
             trim(substr(p.lograd || ' ' || p.nro, 1, 35))
        into vv_nome,
             vv_im,
             vv_ie_rg,
             vv_lograd,
             vv_nro,
             vv_compl,
             vv_bairro,
             vv_descr_cid,
             vv_sg_estado,
             vv_ibge_cidade,
             vv_cep,
             vv_email,
             vv_end_cobr
        from pessoa p, 
             fisica f, 
             juridica j, 
             cidade c, 
             estado e
       where p.id           = rec.pessoa_id
         and f.pessoa_id(+) = p.id
         and j.pessoa_id(+) = p.id
         and p.cidade_id    = c.id
         and c.estado_id    = e.id;
    exception
      when others then
        vv_nome        := null;
        vv_im          := null;
        vv_ie_rg       := null;
        vv_lograd      := null;
        vv_nro         := null;
        vv_compl       := null;
        vv_bairro      := null;
        vv_descr_cid   := null;
        vv_sg_estado   := null;
        vv_ibge_cidade := null;
        vv_cep         := null;
        vv_email       := null;
        vv_end_cobr    := null;
    end;
    --
    if vv_ibge_cidade = '3550308' then
      goto proximo;
    end if;
    --
    vn_fase := 2.2;
    --
    gl_conteudo := '4'; -- Tipo de registro
    gl_conteudo := gl_conteudo || '02'; --  Tipo do documento - 02 - Com emissão de documento fiscal autorizado pelo município
    gl_conteudo := gl_conteudo || rpad(rec.serie, 5, ' '); -- Serie
    gl_conteudo := gl_conteudo || lpad(rec.nro_nf, 12, '0'); -- Número do Documento
    gl_conteudo := gl_conteudo || to_char(nvl(rec.dt_exe_serv, nvl(rec.dt_sai_ent, rec.dt_emiss)), 'yyyymmdd'); -- Data da prestação dos serviços
    gl_conteudo := gl_conteudo || 'N'; -- Situação da NFTS - N – Normal
    -- Tributação do Serviço
    if rec.dm_nat_oper in (1, 2, 7) then
      gl_conteudo := gl_conteudo || 'T'; -- T - Operação normal
    elsif rec.dm_nat_oper in (3, 4, 8) then
      gl_conteudo := gl_conteudo || 'I'; -- I - Imune
    elsif rec.dm_nat_oper in (5, 6) then
      gl_conteudo := gl_conteudo || 'J'; -- J - ISS Suspenso por Decisão Judicial
    else
      gl_conteudo := gl_conteudo || 'T'; -- T - Operação normal
    end if;
    --
    --gl_conteudo := gl_conteudo || lpad(trim(nvl(rec.vl_total_nf,0)*100),15,0); -- Valor Total de Serviço
    gl_conteudo := gl_conteudo || lpad(trim(nvl(rec.vl_total_serv, 0) * 100), 15, 0); -- Valor Total de Serviço
    gl_conteudo := gl_conteudo || lpad(nvl(rec.vl_deducao, 0) * 100, 15, 0); -- Valor Dedução Base
    --
    --vn_total_vl_serv    := nvl(vn_total_vl_serv, 0) + (nvl(rec.vl_total_nf, 0) * 100);
    vn_total_vl_serv    := nvl(vn_total_vl_serv, 0) + (nvl(rec.vl_total_serv, 0) * 100);
    vn_total_vl_deducao := nvl(vn_total_vl_deducao, 0) + (nvl(rec.vl_deducao, 0) * 100);
    --
    vn_fase := 3.3;
    --
    /*
    begin
       select distinct(inf.cd_lista_serv)
         into vv_cd_lista_serv
         from item_nota_fiscal inf
        where inf.notafiscal_id   = rec.notafiscal_id
          and rownum = 1;
    exception
       when others then
          vv_cd_lista_serv := null;
    end;*/
    begin
      --
      select max(descr)
        into vv_tp_serv_descr
        from tipo_servico
       where to_number(replace(cod_lst, '.', '')) = rec.cd_lista_serv;
      --
    exception
      when others then
        vv_tp_serv_descr := null;
    end;
    --
    vv_cd_lista_serv := lpad(rec.cd_lista_serv, 4, '0'); -- trim(vv_cd_lista_serv);
    --
    if trim(vv_cd_lista_serv) is null then
      vv_cd_lista_serv := '0';
    end if;
    --
    vv_cd_lista_serv := lpad(vv_cd_lista_serv, 4, '0');
    --
    vn_fase := 2.3;
    /*
    -- Còdigo do Serviço Prestado
    if vv_cd_lista_serv in ('0702', '0704', '0705', '0717', '1413') then
       vv_cd_serv_prest := '01112';
    elsif vv_cd_lista_serv in ('0701', '0706', '0707', '0708', '0709', '0710', '0711', '0713', '0718') then
       vv_cd_serv_prest := '01503';
    elsif vv_cd_lista_serv in ('0703', '0712', '0716', '0719', '0720', '0721', '0722', '1402', '1703', '1717', '3001', '3101', '3601', '3801') then
       vv_cd_serv_prest := '02232';
    elsif vv_cd_lista_serv in ('1601', '2601') then
       vv_cd_serv_prest := '02488';
    elsif vv_cd_lista_serv in ('1706', '2301') then
       vv_cd_serv_prest := '02542';
    elsif vv_cd_lista_serv in ('0104', '0105', '0201') then
       vv_cd_serv_prest := '02836';
    elsif vv_cd_lista_serv in ('0107') then
       vv_cd_serv_prest := '02918';
    elsif vv_cd_lista_serv in ('1702') then
       vv_cd_serv_prest := '03131';
    elsif vv_cd_lista_serv in ('0101', '0102', '0103', '0106', '0108', '1701', '1712', '1715', '1718', '1720', '1721', '1723', '1724', '2901') then
       vv_cd_serv_prest := '03980';
    elsif vv_cd_lista_serv in ('0403', '0404', '0407', '0410', '0415', '0417', '0418', '0419', '0420', '0421', '0422', '0423', '0502', '0503', '0504', '0505', '0506', '0507', '0509') then
       vv_cd_serv_prest := '05541';
    elsif vv_cd_lista_serv in ('1704', '1708', '1722', '2501', '2502', '2503', '2504') then
       vv_cd_serv_prest := '06653';
    elsif vv_cd_lista_serv in ('1213', '1302', '1303', '1304', '2401') then
       vv_cd_serv_prest := '06971';
    elsif vv_cd_lista_serv in ('0901', '1217', '1711') then
       vv_cd_serv_prest := '07234';
    elsif vv_cd_lista_serv in ('1401', '1403', '1404', '1405', '1409', '1411', '1412') then
       vv_cd_serv_prest := '07684';
    elsif vv_cd_lista_serv in ('0302', '0303', '0304', '0305', '1101', '1104', '2001', '2002', '2003') then
       vv_cd_serv_prest := '08036';
    elsif vv_cd_lista_serv in ('0302', '0303', '0304', '0305', '1101', '1104', '2001', '2002', '2003') then
       vv_cd_serv_prest := '08044';
    elsif vv_cd_lista_serv in ('1201', '1203', '1205', '1207') then
       vv_cd_serv_prest := '08045';
    elsif vv_cd_lista_serv in ('0601', '0602', '0603', '0605') then
       vv_cd_serv_prest := '08575';
    elsif vv_cd_lista_serv in ('3401', '3901', '4001') then
       vv_cd_serv_prest := '08899';
    else
       vv_cd_serv_prest := '00000';
    end if; */
    --
    --
    if nvl(rec.codtribmunicipio_id, 0) > 0 then
      vv_cd_serv_prest := pk_csf.fkg_codtribmunicipio_cd(en_codtribmunicipio_id => rec.codtribmunicipio_id);
    else
      vv_cd_serv_prest := '00000';
    end if;
    --
    --
    vn_fase := 2.4;
    --
    gl_conteudo := gl_conteudo || vv_cd_serv_prest;
    gl_conteudo := gl_conteudo || vv_cd_lista_serv;
    --
    vn_aliq_aplic := null;
    vn_retido     := null;
    --
    begin
      select distinct (ii.aliq_apli)
        into vn_aliq_aplic
        from item_nota_fiscal inf, 
             imp_itemnf ii, 
             tipo_imposto ti
       where inf.notafiscal_id = rec.notafiscal_id
         and inf.id            = ii.itemnf_id
         and ii.dm_tipo        = 1 -- Retido
         and ii.tipoimp_id     = ti.id
         and ti.cd             = 6 -- ISS
         and inf.cd_lista_serv is not null;
    exception
      when others then
        vn_aliq_aplic := 0;
    end;
    --
    vn_fase := 3;
    --
    if nvl(vn_aliq_aplic, 0) <= 0 then
      --
      begin
        select distinct (ii.aliq_apli)
          into vn_aliq_aplic
          from item_nota_fiscal inf, 
               imp_itemnf ii, 
               tipo_imposto ti
         where inf.notafiscal_id = rec.notafiscal_id
           and inf.id            = ii.itemnf_id
           and ii.dm_tipo        = 0 -- Normal
           and ii.tipoimp_id     = ti.id
           and ti.cd             = 6 -- ISS
           and inf.cd_lista_serv is not null;
      exception
        when others then
          vn_aliq_aplic := 0;
      end;
      --
      vn_retido := 2; -- NFTS sem ISS Retido
      --
    else
      --
      vn_retido := 1; -- ISS Retido.
      --
    end if;
    --
    gl_conteudo := gl_conteudo || lpad(nvl(vn_aliq_aplic, 0) * 100, 4, 0); -- aliq ISS de outro municipio
    gl_conteudo := gl_conteudo || vn_retido;
    --
    vn_fase := 4;
    --
    vv_cnpj_tomador := pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => rec.pessoa_id);
    --
    if length(vv_cnpj_tomador) = 11 then
      -- CPF
      gl_conteudo := gl_conteudo || 1; --  Indicador de CPF/CNPJ do Prestador
      gl_conteudo := gl_conteudo || lpad(vv_cnpj_tomador, 14, '0');
    elsif length(vv_cnpj_tomador) = 14 then
      -- CNPJ
      gl_conteudo := gl_conteudo || 2; --  Indicador de CPF/CNPJ do Prestador
      gl_conteudo := gl_conteudo || lpad(vv_cnpj_tomador, 14, '0');
    else
      gl_conteudo := gl_conteudo || 3; --  Indicador de CPF/CNPJ do Prestador
      gl_conteudo := gl_conteudo || rpad('0', 14, '0');
    end if;
    --
    vn_fase := 5;
    --
    --
    --| Registro de Prestado de Serviço
    --
    vv_im := trim(vv_im);
    --
    if upper(vv_im) like '%ISENT%' then
      vv_im := null;
    end if;
    --
    vn_fase := 5.1;
    -- Inscrição Municipal do Prestador
    if vv_ibge_cidade = '3550308' then
      -- ATENÇÃO!!! Este campo só deverá ser preenchido para prestadores estabelecidos no município de São Paulo (CCM).
      gl_conteudo := gl_conteudo || rpad(nvl(trim(vv_im), 0), 8, '0'); -- Inscrição Municipal
    else
      gl_conteudo := gl_conteudo || rpad(0, 8, '0'); -- Inscrição Municipal
    end if;
    --
    vn_fase := 5.2;
    --
    gl_conteudo := gl_conteudo || rpad(nvl(trim(vv_nome), ' '), 75, ' '); -- Nome Tomador
    gl_conteudo := gl_conteudo || 'Rua';
    gl_conteudo := gl_conteudo || rpad(nvl(trim(vv_lograd), ' '), 50, ' '); -- Endereço
    gl_conteudo := gl_conteudo || rpad(nvl(trim(vv_nro), ' '), 10, ' '); -- Numero
    gl_conteudo := gl_conteudo || rpad(nvl(trim(vv_compl), ' '), 30, ' '); -- Complemento do Endereço do Prestador
    gl_conteudo := gl_conteudo || rpad(nvl(trim(vv_bairro), ' '), 30, ' '); --  Bairro do Prestador
    gl_conteudo := gl_conteudo || rpad(nvl(vv_descr_cid, ' '), 50, ' '); -- Município
    gl_conteudo := gl_conteudo || rpad(nvl(vv_sg_estado, ' '), 2, ' '); -- UF
    gl_conteudo := gl_conteudo || rpad(nvl(trim(vv_cep), 0), 8, '0'); -- CEP
    gl_conteudo := gl_conteudo || rpad(nvl(trim(vv_email), ' '), 75, ' '); -- E-mail do Tomador
    --
    gl_conteudo := gl_conteudo || '1'; --  Tipo de NFTS
    --
    vv_valor_tipo_param_cd_sn := pk_csf.fkg_pessoa_valortipoparam_cd(ev_tipoparam_cd => '1', -- Simples Nacional
                                                                     en_pessoa_id    => rec.pessoa_id);
    -- Se não tem parâmetro de Simples Nacional, checa no parâmetro de "Regime de Tributação Especial"
    if trim(vv_valor_tipo_param_cd_sn) is null or
       trim(vv_valor_tipo_param_cd_sn) = '0' then
      --
      vv_valor_tipo_param_cd_regtrib := pk_csf.fkg_pessoa_valortipoparam_cd(ev_tipoparam_cd => '2', -- Regime de Tributação Especial
                                                                            en_pessoa_id    => rec.pessoa_id);
      --
      if trim(vv_valor_tipo_param_cd_regtrib) is null then
        vv_reg_trib := '0';
      elsif trim(vv_valor_tipo_param_cd_regtrib) in ('2', '3', '4', '6') then
        vv_reg_trib := '0';
      else
        --
        if trim(vv_valor_tipo_param_cd_regtrib) = '5' then
          -- MEI
          --
          vv_reg_trib := '5';
          --
        else
          vv_reg_trib := '0';
        end if;
        --
      end if;
      --
    else
      --
      -- Prestado do Serviço é Simples Nacional
      vv_reg_trib := '4';
      --
    end if;
    --
    -- Se não existir nada, atribui como 0-Normal
    if trim(vv_reg_trib) is null then
      vv_reg_trib := '0';
    end if;
    --
    gl_conteudo := gl_conteudo || vv_reg_trib; --   Regime de Tributação
  
    gl_conteudo := gl_conteudo || rpad(' ', 8, ' '); --  Data de Pagamento da Nota
    gl_conteudo := gl_conteudo || replace(replace(trim(substr(vv_tp_serv_descr, 1, 250)), chr(10), '|'), chr(13), '|'); -- Discriminação dos Serviços
    --
    vn_fase := 5.3;
    -- Armazena a estrutura do arquivo.
    --
    pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
    --
    vn_count := vn_count + 1;
    --
    <<proximo>>
  --
    vn_fase := 7;
    --
  end loop;
  --
  -- Linha de Rodapé
  --
  gl_conteudo := '9'; -- Tipo de Registro
  gl_conteudo := gl_conteudo || lpad(nvl(vn_count, 0), 7, 0); --  Número de linhas de detalhe do arquivo
  gl_conteudo := gl_conteudo || lpad(nvl(vn_total_vl_serv, 0), 15, 0);
  gl_conteudo := gl_conteudo || lpad(nvl(vn_total_vl_deducao, 0), 15, 0);
  --
  -- Armazena a estrutura do arquivo
  --
  pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
  --
  vn_fase := 10;
  --
EXCEPTION
  when others then
    raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_3550308 fase (' || vn_fase || '): ' || sqlerrm);
end pkb_gera_arq_cid_3550308;

---------------------------------------------------------------------------------------------------------------------
-- Processo de Exportação de Notas Fiscais Emitidas e Recebidas para DFMS Belem / PA
procedure pkb_gera_arq_cid_1501402 is
   --
   vn_fase                      number := null;
   vn_count                     number := null;
   vv_tp_recolhimento           varchar2(1) := null;
   vn_aliq_iss                  imp_itemnf.aliq_apli%type;
   --
   vn_cnpj_tomador              nota_fiscal_dest.cnpj%type;
   vn_cpf_tomador               nota_fiscal_dest.cpf%type;
   vv_nome_tomador              nota_fiscal_dest.nome%type;
   vn_cid_ibge_tomador          nota_fiscal_dest.cidade_ibge%type;
   --
   vv_cod_siafi                 cidade_tipo_cod_arq.cd%type;
   vv_simpl_nac                 valor_tipo_param.cd%type := null;
   vn_cd_cidbeneficafiscal      cidade_befic_fiscal.cd%type;
   vn_vl_imp_trib_iss           imp_itemnf.vl_imp_trib%type;
   --
   vn_vl_aliq_aplic_ret         imp_itemnf.aliq_apli%type;
   vv_cpf_cnpj			varchar2(14);
   vn_prest_cidade_id		cidade.id%type;
   vn_empr_cidade_id		cidade.id%type;	
   --
   cursor c_nfs is -- Tipo E
   select nf.id          notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nf.dt_emiss
        , ics.codtribmunicipio_id
        , inf.id     itemnf_id
        , ics.cnae
        , ics.cidade_id
        , ics.cidadebeneficfiscal_id
        , decode(nf.dm_st_proc,4,'N','C')  dm_st_proc
        , decode(ncs.dm_nat_oper,1,1,2,2,7,5,1) dm_nat_oper
        , inf.vl_item_bruto
        , nf.pessoa_id
        , nft.vl_deducao
        , mf.cod_mod
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , nf_compl_serv  ncs
        , item_nota_fiscal inf
        , itemnf_compl_serv ics
        , nota_fiscal_total nft
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      in (4,7) -- Autorizadas / Canceladas
      and nf.dm_ind_oper     = 1 -- saida
      and nf.dm_ind_emit     = 0 -- Emissão Propria.
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
          or
          (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
           or
          (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
           or
          (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and e.id               = nf.empresa_id
      and nf.id              = nft.notafiscal_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id
      and nf.id              = ncs.notafiscal_id (+)
      and nf.id              = inf.notafiscal_id
      and inf.id             = ics.itemnf_id (+)
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
    order by nf.id;
    --
    cursor c_nfs_sai is
   select nf.id          notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nf.dt_emiss
        , nf.dt_sai_ent
        , inf.cd_lista_serv
        , inf.vl_item_bruto
        , inf.id     itemnf_id
        , ics.cidadebeneficfiscal_id
        , ics.codtribmunicipio_id
        , ics.cidade_id
        , inf.cidade_ibge
        , nf.dm_st_proc
        , nf.pessoa_id
        , nft.vl_deducao
        , mf.cod_mod
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , nf_compl_serv  ncs
        , item_nota_fiscal inf
        , itemnf_compl_serv ics
        , nota_fiscal_total nft
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      in (4,7) -- Autorizadas / Canceladas
      and not exists( select 1
                        from nota_fiscal nfe
                       where nfe.id   = nf.id 
                         and nfe.dm_ind_oper = 1
                         and nfe.dm_ind_emit = 0 )  -- permitidas notas ficais de saida, entrada só quando for terceiros
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
          or
          (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
           or
          (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
           or
          (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and e.id               = nf.empresa_id
      and nf.id              = nft.notafiscal_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id
      and nf.id              = ncs.notafiscal_id (+)
      and nf.id              = inf.notafiscal_id
      and inf.id             = ics.itemnf_id (+)
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
    order by nf.id;
begin
   --
   vn_fase := 1;
   --
   vn_count := 0;
   --
   -- REGISTRO HEADER - 'H'
   --
   vn_count := nvl(vn_count,0) + 1;
   --
   gl_conteudo := null;
   gl_conteudo := 'H';
   gl_conteudo := gl_conteudo || rpad(nvl(to_char(pk_csf.fkg_inscr_mun_empresa(en_empresa_id => gn_empresa_id)), ' '),11,' '); -- Inscricao Municipal
   gl_conteudo := gl_conteudo || lpad('400',3,0);
   --
   vn_fase := 2;
   --
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_fase := 3;
   --
   -- REGISTROS - 'E'
   --
   for rec in c_nfs loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_count := nvl(vn_count,0) + 1;
      --
      gl_conteudo := null;
      --
      vn_fase := 4;
      --
      gl_conteudo := 'E';
      gl_conteudo := gl_conteudo || to_char(rec.dt_emiss,'dd/mm/yyyy');
      gl_conteudo := gl_conteudo || rpad(rec.serie,2,' '); -- Serie
      gl_conteudo := gl_conteudo || rpad(' ',1,' '); -- Modelo da nota
      gl_conteudo := gl_conteudo || rpad(nvl(to_char(rec.codtribmunicipio_id),' '),1,' '); -- tributação nota fiscal
      gl_conteudo := gl_conteudo || lpad(nvl(rec.nro_nf,0),9,0); -- Numero da nota fiscal
      gl_conteudo := gl_conteudo || trim(replace(to_char(rec.vl_item_bruto,'000000000000D00'), ',', '.')); -- valor bruto da nota fiscal
      gl_conteudo := gl_conteudo || trim(replace(to_char(rec.vl_item_bruto,'000000000000D00'), ',', '.'));
      --
      vn_fase := 5;
      --
      begin
         --
         vv_tp_recolhimento := null;
         --
         select decode(nvl(ii.dm_tipo,-1),0,'A','R')
           into vv_tp_recolhimento
           from imp_itemnf ii
              , item_nota_fiscal inf  
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and ii.itemnf_id = inf.id 
            and ti.id        = ii.tipoimp_id
            and ti.cd        = 6;  --ISS
      exception
        when others then
         vv_tp_recolhimento := null;
      end;
      --
      vn_fase := 6;
      --
      begin
         --
         vn_aliq_iss := null;
         --
         select ii.aliq_apli
           into vn_aliq_iss
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and ii.itemnf_id      = inf.id
            and ii.dm_tipo        = 1 -- Retenção
            and ti.id             = ii.tipoimp_id
            and ti.cd             = '6'; -- ISS
      exception
         when others then
            vn_aliq_iss := null;
      end;
      --
      vn_fase := 7;
      --
      if nvl(vn_aliq_iss,0) = 0 then -- Verificar primeiro se existe imposto do tipo 1-Retido, se não existir recuperar do tipo 0-Imposto
         --
         begin
            --
            select ii.aliq_apli
              into vn_aliq_iss
              from item_nota_fiscal inf
                 , imp_itemnf ii
                 , tipo_imposto ti
             where inf.notafiscal_id = rec.notafiscal_id
               and ii.itemnf_id      = inf.id --14134021
               and ii.dm_tipo        = 0 -- Imposto
               and ti.id             = ii.tipoimp_id
               and ti.cd             = '6'; -- ISS
         exception
            when others then
               vn_aliq_iss := null;
         end;
         --
      end if;
      --
      vn_fase := 8;
      --
      begin
         --
         vn_cnpj_tomador     := null;
         vn_cpf_tomador      := null;
         vv_nome_tomador     := null;
         vn_cid_ibge_tomador := null;
         --
         select nfd.cnpj
              , nfd.cpf
              , nfd.nome
              , nfd.cidade_ibge
           into vn_cnpj_tomador
              , vn_cpf_tomador                                                   
              , vv_nome_tomador                                                  
              , vn_cid_ibge_tomador
           from nota_fiscal_dest nfd
          where notafiscal_id = rec.notafiscal_id;
         --
      exception
         when others then
           vn_cnpj_tomador     := null;
           vn_cpf_tomador      := null;
           vv_nome_tomador     := null;
           vn_cid_ibge_tomador := null;
      end;
      --
      vn_fase := 9;
      --
      gl_conteudo := gl_conteudo || rpad(nvl(vv_tp_recolhimento,' '),1,' ');
      gl_conteudo := gl_conteudo || trim(replace(to_char(nvl(vn_aliq_iss,0),'00D00'), ',', '.'));
      gl_conteudo := gl_conteudo || lpad(nvl(vn_cnpj_tomador,0),14,0);
      gl_conteudo := gl_conteudo || lpad(nvl(vn_cpf_tomador,0),11,0);
      gl_conteudo := gl_conteudo || rpad(trim(nvl(vv_nome_tomador, ' ')),40,' ');
      --
      vv_cod_siafi := null;
      --
      -- Código SIAFI do município do tomador de serviços
      vv_cod_siafi := fkg_ibge_cid_tipo_cod_arq( en_ibge_cidade    => vn_cid_ibge_tomador
                                               , en_cd_tipo_cod_arq => 5 ); -- SIAFI
      --
      vn_fase := 10;
      --
      gl_conteudo := gl_conteudo || rpad(nvl(vv_cod_siafi,0),10,' '); -- Código SIAFI do município do tomador de serviços
      gl_conteudo := gl_conteudo || rpad(nvl(rec.cnae, ' '),10,' ');
      --
      -- Código SIAFI do município do Local da Prestação do Serviço
      vv_cod_siafi := null;
      --
      vv_cod_siafi := pk_csf.fkg_cd_cidade_tipo_cod_arq ( en_cidade_id     => rec.cidade_id
                                                        , en_tipocodarq_id => pk_csf.fkg_tipocodarq_id ( ev_cd => 5)); -- SIAFI
      --
      vn_fase := 11;
      --
      gl_conteudo := gl_conteudo || rpad(nvl(vv_cod_siafi,' '),10,' '); -- Código SIAFI do município do Local da Prestação do Serviço
      gl_conteudo := gl_conteudo || lpad(0,9,0); -- Número final do intervalo
      gl_conteudo := gl_conteudo || rpad(nvl(to_char(rec.dm_st_proc),' '),1,' '); -- Situação da nota fiscal
      --
      vn_fase := 12;
      --
      vv_simpl_nac := null;
      --
      vv_simpl_nac := pk_csf.fkg_pessoa_valortipoparam_cd( ev_tipoparam_cd => 1 -- Simples Nacional
                                                         , en_pessoa_id    => rec.pessoa_id );
      --
      vn_fase := 13;
      --
      if nvl(vv_simpl_nac,'0') = '1'then
         --
         gl_conteudo := gl_conteudo || rpad('S',1,' '); -- Enquadramento no Simples Nacional do Tomador de Serviços
         --
      else
         --
         gl_conteudo := gl_conteudo || rpad('N',1,' ');
         --
      end if;
      --
      vn_fase := 14;
      --
      vn_cd_cidbeneficafiscal := null;
      --
      begin
         --
         select cb.cd
          into vn_cd_cidbeneficafiscal
          from cidade_befic_fiscal cb
         where cb.id = rec.cidadebeneficfiscal_id;
         --
      exception
         when others then
           vn_cd_cidbeneficafiscal := null;
      end;
      --
      vn_fase := 15;
      --
      gl_conteudo := gl_conteudo || rpad(nvl(vn_cd_cidbeneficafiscal,' '),1,' ');
      --
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
   end loop;
   --
   vn_fase := 16;
   --  
   -- REGISTROS - R
   --
   for rec2 in c_nfs_sai loop
      exit when c_nfs_sai%notfound or (c_nfs_sai%notfound) is null;
      --
      vn_fase := 17;
      --
      vn_count := nvl(vn_count,0) + 1;
      --
      gl_conteudo := 'R';
      --
      if rec2.dt_sai_ent is not null then
         --
         gl_conteudo := gl_conteudo || to_date(rec2.dt_sai_ent, 'dd/mm/yyyy'); -- Data de retenção do ISS
         --
      else
         --
         gl_conteudo := gl_conteudo || to_date(rec2.dt_emiss, 'dd/mm/yyyy');
         --
      end if;
      --
      vn_fase := 18;
      --
      gl_conteudo := gl_conteudo || to_date(rec2.dt_emiss, 'dd/mm/yyyy'); -- Data da emissão da nota
      gl_conteudo := gl_conteudo || rpad(rec2.serie,2,' '); -- Serie
      gl_conteudo := gl_conteudo || rpad(' ',1,' '); -- Modelo da nota
      --
      vn_fase := 19;
      --
      vn_vl_imp_trib_iss := null;
      --
      begin
         --
         select ii.vl_imp_trib
           into vn_vl_imp_trib_iss
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec2.notafiscal_id
            and ii.itemnf_id      = inf.id
            and ti.id             = ii.tipoimp_id
            and ii.dm_tipo        = 1 -- Retido
            and ti.cd             = '6'; -- ISS
         --
      exception
         when others then
           vn_vl_imp_trib_iss := null;
      end;
      --
      vn_fase := 20;
      --
      if nvl(vn_vl_imp_trib_iss,0) > 0 then
         --
         gl_conteudo := gl_conteudo || 'T';
         --
      else
         --
         gl_conteudo := gl_conteudo || 'B';
         --
      end if;
      --
      vn_fase := 21;
      --
      gl_conteudo := gl_conteudo || lpad(nvl(rec2.nro_nf,0),9,0);
      gl_conteudo := gl_conteudo || trim(replace(to_char(rec2.vl_item_bruto,'000000000000D00'), ',', '.')); -- Valor bruto da nota fiscal
      gl_conteudo := gl_conteudo || trim(replace(to_char(rec2.vl_item_bruto,'000000000000D00'), ',', '.')); -- Valor do serv. lançado na nota fiscal recebida
      --
      vn_fase := 22;
      --
      begin
         --
         select ii.aliq_apli
           into vn_vl_aliq_aplic_ret
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec2.notafiscal_id
            and ii.itemnf_id      = inf.id
            and ti.id             = ii.tipoimp_id
            and ii.dm_tipo        = 1 -- Retido
            and ti.cd             = '6';
         --
      exception
         when others then
            vn_vl_aliq_aplic_ret := null;
      end;
      --
      vn_fase := 23;
      --
      gl_conteudo := gl_conteudo || trim(replace(to_char(nvl(vn_vl_aliq_aplic_ret,0),'00D00'), ',', '.'));
      gl_conteudo := gl_conteudo || lpad(0,6,0); -- Numero da parcela de pagamento da NF
      gl_conteudo := gl_conteudo || lpad(0,6,0); -- Quantidade de parcelas de pagamento da NF
      gl_conteudo := gl_conteudo || rpad(' ',30,' '); -- Motivo da não retenção
      --
      vv_cpf_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec2.pessoa_id);
      --
      vn_fase := 24;
      --
      if length(vv_cpf_cnpj) = 14 then
         --
         vn_fase := 25;
         --
         gl_conteudo := gl_conteudo || lpad(vv_cpf_cnpj,14,0); -- CNPJ do prestador de serviços
         gl_conteudo := gl_conteudo || lpad('0',11,'0');
         --
      else
         --
         vn_fase := 26;
         --
         gl_conteudo := gl_conteudo || lpad('0',14,'0');
         gl_conteudo := gl_conteudo || lpad(nvl(vv_cpf_cnpj,0),11,0);
         --
      end if;
      --
      vn_fase := 27;
      --
      gl_conteudo := gl_conteudo || rpad(nvl(pk_csf.fkg_nome_pessoa_id ( en_pessoa_id => rec2.pessoa_id ), ' '),40,' '); -- Nome do prestador de serviço.
      --
      -- Recuperar Código SIAFI
      vn_prest_cidade_id := null;
      vv_cod_siafi       := null;
      --
      begin
         --
         select p.cidade_id
           into vn_prest_cidade_id
           from pessoa p
          where p.id = rec2.pessoa_id;
         --
      exception
         when others then
            vn_prest_cidade_id := null;
      end;
      --
      vn_fase := 28;
      --
      vv_cod_siafi := pk_csf.fkg_cd_cidade_tipo_cod_arq ( en_cidade_id     => vn_prest_cidade_id
                                                        , en_tipocodarq_id => pk_csf.fkg_tipocodarq_id ( ev_cd => 5)); -- SIAFI
      --
      gl_conteudo := gl_conteudo || rpad(nvl(vv_cod_siafi,' '),10,' '); -- Cód. SIAFI do município do prestador de serviços.
      --
      vn_fase := 29;
      --
      vv_simpl_nac := null;
      --
      vv_simpl_nac := pk_csf.fkg_pessoa_valortipoparam_cd( ev_tipoparam_cd => 1 -- Simples Nacional
                                                         , en_pessoa_id    => rec2.pessoa_id );
      --
      vn_fase := 30;
      --
      if nvl(vv_simpl_nac,'0') = '1' then
         --
         gl_conteudo := gl_conteudo || rpad('S',1,' '); -- Enquadramento no Simples Nacional do Tomador de Serviços
         --
      else
         --
         gl_conteudo := gl_conteudo || rpad('N',1,' ');
         --
      end if;
      --
      vn_fase := 31;
      --
      begin
        select p.cidade_id
          into vn_empr_cidade_id
          from empresa e
             , pessoa p
         where e.id        = gn_empresa_id
           and e.pessoa_id = p.id;
      exception
         when others then
            vn_empr_cidade_id := null;
      end;
      --
      -- Verificar se o prestador é de outro municipio
      if nvl(vn_prest_cidade_id,0) <> nvl(vn_empr_cidade_id,0) then
         --
         gl_conteudo := gl_conteudo || rpad(nvl(to_char(rec2.cd_lista_serv),' '),10,' ');
         --
      else
         --
         gl_conteudo := gl_conteudo || rpad(' ',10,' ');
         --
      end if;
      --
      vn_fase := 32;
      --
      -- Código SIAFI do município do Local da Prestação do Serviço
      vv_cod_siafi := null;
      --
      if nvl(rec2.cidade_id,0) <> 0 then -- cidade do complemento do item da nota
         --
         vv_cod_siafi := pk_csf.fkg_cd_cidade_tipo_cod_arq ( en_cidade_id     => rec2.cidade_id
                                                           , en_tipocodarq_id => pk_csf.fkg_tipocodarq_id ( ev_cd => 5)); -- SIAFI
         --
      else -- cidade do item da nota
         --
         vv_cod_siafi := pk_csf.fkg_cd_cidade_tipo_cod_arq ( en_cidade_id     => pk_csf.fkg_Cidade_ibge_id(rec2.cidade_ibge) -- recupera o ID da cidade
                                                           , en_tipocodarq_id => pk_csf.fkg_tipocodarq_id ( ev_cd => 5)); -- SIAFI
         --
      end if;
      --
      gl_conteudo := gl_conteudo || rpad(nvl(vv_cod_siafi,' '),10,' ');
      --
      vn_fase := 33;
      --
      vn_cd_cidbeneficafiscal := null;
      --
      begin
         --
         select cb.cd
          into vn_cd_cidbeneficafiscal
          from cidade_befic_fiscal cb
         where cb.id = rec2.cidadebeneficfiscal_id;
         --
      exception
         when others then
           vn_cd_cidbeneficafiscal := null;
      end;
      --
      vn_fase := 15;
      --
      gl_conteudo := gl_conteudo || rpad(nvl(to_char(vn_cd_cidbeneficafiscal),' '),1,' ');
      --
      vn_fase := 16;
      --
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_1501402 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_1501402;

---------------------------------------------------------------------------------------------------------------------
-- Processo de Exportação de Notas Fiscais de Serviços Tomados para Santana de Parnaiba / SP
procedure pkb_gera_arq_cid_3547304 is
   --
   vn_fase                      number;
   vv_cd_lista_serv             varchar2(10);
   vv_cnpj_tomador              varchar2(14);
   vv_cfop                      varchar2(12);
   --    
   vv_nome                      pessoa.nome%type;
   vv_im                        juridica.im%type;
   vv_ie_rg                     varchar2(15);
   vn_aliq_aplic                imp_itemnf.aliq_apli%type;
   --      
   vv_lograd                    pessoa.lograd%type;
   vv_descr_cid                 cidade.descr%type;
   vv_sg_estado                 estado.sigla_estado%type;
   vv_cep                       varchar2(8);
   --
   vv_email                     pessoa.email%type;
   vv_end_cobr                  varchar2(35);
   vn_count                     number;
   vv_email_pess                pessoa.email%type;
   --
    cursor c_nfs is
     select nf.id          notafiscal_id
          , nf.nro_nf
          , nf.serie
          , nf.dt_emiss
          , decode(ncs.dm_nat_oper,1,1,2,2,7,5,1) dm_nat_oper
          , nft.vl_total_nf
          , nft.vl_ret_iss -- iss_retido
          , nft.vl_ret_irrf
          , nft.vl_ret_pis
          , nft.vl_ret_cofins
          , nft.vl_ret_csll
          , nft.vl_ret_prev
          , nf.pessoa_id
          , nft.vl_deducao
          , mf.cod_mod
       from nota_fiscal nf
          , mod_fiscal mf
          , empresa e
          , pessoa p
          , nf_compl_serv  ncs
          , item_nota_fiscal inf
          , itemnf_compl_serv ics
          , nota_fiscal_total nft
      where nf.empresa_id      = gn_empresa_id
        and nf.dm_ind_emit     = gn_dm_ind_emit
        and nf.dm_st_proc      = 4
        and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
        and mf.id              = nf.modfiscal_id
        and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
        and e.id               = nf.empresa_id
        and nf.id              = nft.notafiscal_id
        and p.id               = e.pessoa_id
        and p.cidade_id        = gn_cidade_id
        and nf.id              = ncs.notafiscal_id (+)
        and nf.id              = inf.notafiscal_id
        and inf.id             = ics.itemnf_id (+)
        and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
      order by nf.id;
--
     cursor c_itens ( en_notafiscal_id   nota_fiscal.id%type) is
         select inf.qtde_comerc
              , inf.unid_com
              , inf.descr_item
              , inf.vl_item_bruto
           from item_nota_fiscal inf
          where inf.notafiscal_id = en_notafiscal_id;
begin
   --
   vn_fase := 1;
   vn_count := 0;
   --
   -- Cabeçalho do Arquivo.
   --
   gl_conteudo := '1'; -- Tipo Registro
   gl_conteudo := gl_conteudo || '001'; -- Versão
   gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_inscr_mun_empresa ( en_empresa_id => gn_empresa_id ), '0'), 8, '0'); --I.M. do Contribuinte
   gl_conteudo := gl_conteudo || to_char(gd_dt_ini, 'yyyymmdd'); -- Data inicial
   gl_conteudo := gl_conteudo || to_char(gd_dt_fin, 'yyyymmdd'); -- Data final
   --
   -- Armazena a estrutura do arquivo.
   --
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_fase := 2;
   --
   for rec in c_nfs
   loop
      --
      gl_conteudo := '2'; -- Tipo de registro
      gl_conteudo := gl_conteudo || rpad(rec.serie||rec.nro_nf,12,' '); -- Referencia
      gl_conteudo := gl_conteudo || to_char(rec.dt_emiss, 'yyyymmdd'); -- Data Emissao
      gl_conteudo := gl_conteudo || lpad(rec.dm_nat_oper,1,0); -- Local prestação de serviço
      gl_conteudo := gl_conteudo || lpad(trim(rec.vl_total_nf*100),15,0); -- Valor Total de Serviço
      --
      vn_fase := 3;
      --
      --begin
      --   select distinct(inf.cd_lista_serv)
      --     into vv_cd_lista_serv
      --     from item_nota_fiscal inf
      --    where inf.notafiscal_id   = rec.notafiscal_id;
      --exception
      --  when others then
      --      vv_cd_lista_serv := null;
      --end;
      --
      vv_cd_lista_serv := null;
      --
      begin
         --
         select max(ct.cod_trib_municipio)
           into vv_cd_lista_serv
           from item_nota_fiscal inf
              , itemnf_compl_serv ic
              , cod_trib_municipio ct
          where inf.notafiscal_id    = rec.notafiscal_id
            and ic.itemnf_id         = inf.id
            and ic.codtribmunicipio_id = ct.id;
         --
      exception
        when others then
         vv_cd_lista_serv := null;
      end;
      --
      vn_fase := 3.1;
      --
      begin
         select distinct(ii.aliq_apli)
           into vn_aliq_aplic
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
              , nota_fiscal nf
              , empresa     e
              , pessoa      p
              , cidade      c
          where nf.id              = rec.notafiscal_id
            and inf.notafiscal_id  = nf.id
            and inf.id             = ii.itemnf_id
            and nf.empresa_id      = e.id
            and e.pessoa_id        = p.id
            and p.cidade_id        = c.id
            and inf.cidade_ibge    <> c.ibge_cidade
            and ii.tipoimp_id      = ti.id
            and ti.cd              = 6 -- ISS
            and inf.cd_lista_serv is not null;
      exception
         when others then
            vn_aliq_aplic := null;
      end;
      --
      vn_fase := 3.2;
      --
      gl_conteudo := gl_conteudo || rpad(nvl(vv_cd_lista_serv, ' '),5,' '); -- Código Serviço
      gl_conteudo := gl_conteudo || lpad(nvl(vn_aliq_aplic*100,0),4,0); -- aliq ISS de outro municipio
      gl_conteudo := gl_conteudo || lpad(nvl(rec.vl_ret_iss*100,0),15,0); -- Valor ISS Retido
      gl_conteudo := gl_conteudo || lpad(nvl(rec.vl_ret_irrf*100,0),15,0); -- Valor IRRF Retido
      gl_conteudo := gl_conteudo || lpad(nvl(rec.vl_ret_pis*100,0),15,0); -- Valor Pis Retido
      gl_conteudo := gl_conteudo || lpad(nvl(rec.vl_ret_cofins*100,0),15,0); -- Valor Cofins Retido
      gl_conteudo := gl_conteudo || lpad(nvl(rec.vl_ret_csll*100,0),15,0); -- Valor CSLL retida
      gl_conteudo := gl_conteudo || lpad(nvl(rec.vl_ret_prev*100,0),15,0); -- Valor INSS Retida
      --
      vn_fase := 4;
      --
      vv_cnpj_tomador := pk_csf.fkg_cnpjcpf_pessoa_id( en_pessoa_id => rec.pessoa_id );
      --
      if vv_cnpj_tomador is null then
         vv_cnpj_tomador := 'SEM';
      end if;
      --
      vn_fase := 4.1;
      --
      gl_conteudo := gl_conteudo || rpad(vv_cnpj_tomador, 14, ' '); -- CNPJ Tomador
      gl_conteudo := gl_conteudo || rpad(' ',8,' '); -- Data Vencimento Fatura
      gl_conteudo := gl_conteudo || rpad(' ',255,' '); -- Instruções de Pagamento
      gl_conteudo := gl_conteudo || lpad(nvl(rec.vl_deducao,0),15,0); -- Valor Dedução Base
      gl_conteudo := gl_conteudo || '001'; -- Código de Vencimento
      --
      vn_fase := 5;
      --
      if rec.cod_mod = '55' then
        --
        begin
          select distinct(inf.cfop)
            into vv_cfop
            from item_nota_fiscal inf
           where inf.notafiscal_id = rec.notafiscal_id;
         exception
            when others then
               vv_cfop := null;
         end;
         --
         gl_conteudo := gl_conteudo || rpad(nvl(vv_cfop, ' '),12,' ');-- CFOP
         --
         vn_fase := 5.1;
         --
      else
         gl_conteudo := gl_conteudo || rpad(' ',12,' ');
      end if;
      --
      -- Armazena a estrutura do arquivo.
      --
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
      vn_count := vn_count + 1;
      --
      vn_fase := 6;
      --
      for rec2 in c_itens(rec.notafiscal_id)
      loop
         --
         gl_conteudo := '3'; -- Tipo do Registro
         gl_conteudo := gl_conteudo || rpad(rec.serie||rec.nro_nf,12,' '); -- Referência NF
         gl_conteudo := gl_conteudo || lpad(nvl(rec2.qtde_comerc,0)*10000,15,0); -- Quantidade
         gl_conteudo := gl_conteudo || rpad(nvl(nvl(rec2.unid_com,'UM'),' '),5,' '); -- Unidade
         gl_conteudo := gl_conteudo || rpad(nvl(rec2.descr_item,' '),255,' '); -- Descrição
         gl_conteudo := gl_conteudo || lpad(nvl(rec2.vl_item_bruto*10000,0),15,0); -- Valor Unitário
         --
         -- Armazena a estrutura do arquivo.
         --
         pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
         --
         vn_count := vn_count + 1;
         --
         vn_fase := 7;
         --
      end loop;
      --
      begin
         select p.nome
              , j.im
              , nvl(j.ie,f.rg)
              , p.lograd
              , c.descr
              , e.sigla_estado
              , p.cep
              , p.email
              , trim(substr(p.lograd||' '||p.nro, 1, 35))
           into vv_nome
              , vv_im
              , vv_ie_rg
              , vv_lograd
              , vv_descr_cid
              , vv_sg_estado
              , vv_cep
              , vv_email_pess
              , vv_end_cobr
           from pessoa p
              , fisica f
              , juridica j
              , cidade c
              , estado e
          where p.id           = rec.pessoa_id
            and f.pessoa_id(+) = p.id 
            and j.pessoa_id(+) = p.id 
            and p.cidade_id    = c.id
            and c.estado_id    = e.id;
      exception
         when others then
            vv_nome       := null;
            vv_im         := null;
            vv_ie_rg      := null;
            vv_lograd     := null;
            vv_descr_cid  := null;
            vv_sg_estado  := null;
            vv_cep        := null;
            vv_email_pess := null;
            vv_end_cobr   := null;
      end;
      --
      vn_fase := 8;
      --
      vv_email := null;
      --
      begin
         --
         select email
           into vv_email
           from nota_fiscal_dest nfd
          where nfd.notafiscal_id = rec.notafiscal_id;
         --
      exception
       when others then
          vv_email := null;
      end;
      --
      -- Registro de Tomador de Serviço
      --
      gl_conteudo := '4'; -- Tipo de Registro
      gl_conteudo := gl_conteudo || rpad(nvl(pk_csf.fkg_cnpjcpf_pessoa_id( en_pessoa_id => rec.pessoa_id ),' '),14,' '); -- CNPJ/CPF
      gl_conteudo := gl_conteudo || rpad(nvl(rec.serie||rec.nro_nf,' '),12,' '); -- Referência NF
      gl_conteudo := gl_conteudo || rpad(nvl(vv_nome,' '),50,' '); -- Nome Tomador
      gl_conteudo := gl_conteudo || rpad(nvl(vv_im,' '),20,' '); -- Inscrição Municipal
      gl_conteudo := gl_conteudo || rpad(nvl(vv_ie_rg,' '),20,' '); -- Inscrição Estadual ou RG
      gl_conteudo := gl_conteudo || rpad(nvl(vv_lograd,' '),50,' '); -- Endereço
      gl_conteudo := gl_conteudo || rpad(nvl(vv_descr_cid,' '),50,' '); -- Município
      gl_conteudo := gl_conteudo || rpad(nvl(vv_sg_estado,' '),2,' '); -- UF
      gl_conteudo := gl_conteudo || rpad(nvl(vv_cep,' '),8,' '); -- CEP
      gl_conteudo := gl_conteudo || rpad(nvl(vv_email,vv_email_pess),50,' '); -- E-mail do Tomador
      gl_conteudo := gl_conteudo || rpad(nvl(vv_end_cobr,' '),50,' '); -- Endereço de Cobrança
      --
      -- Armazena a estrutura do arquivo
      --
      vn_count := vn_count + 1;
      --
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
      vn_fase := 9;
      --
   end loop;
   --
   -- Linha de Rodapé
   --
   gl_conteudo := '9'; -- Tipo de Registro 
   gl_conteudo := gl_conteudo || lpad(nvl(vn_count,0),7,0); -- Numeros de Registros
   --
   -- Armazena a estrutura do arquivo
   --
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_fase := 10;
   --
EXCEPTION
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_3547304 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_3547304;

/*
Melhoria no processo de recuperação dos dados e agrupamento de valores referente ao
Redmine #37834 - Geração do arquivo de Serviços Tomados de ISS para Gissonline.
---------------------------------------------------------------------------------------------------------------------
-- Implementação de processo de Exportação de Notas Fiscais de Serviços Tomados para GissOnline
procedure pkb_gera_arq_cid_dm_ginfes is
   --
   vn_iss_retido                  number;
   vn_vl_item_bruto               item_nota_fiscal.vl_item_bruto%type;
   vn_vl_aliq_aplic               imp_itemnf.aliq_apli%type;
   vn_cd_lista_serv               item_nota_fiscal.cd_lista_serv%type;
   --
   vn_dm_loc_exe_serv             itemnf_compl_serv.dm_loc_exe_serv%type;
   vv_cpf_cnpj                    varchar2(14);
   vn_dm_tipo_pessoa              pessoa.dm_tipo_pessoa%type;
   vv_lograd                      pessoa.lograd%type;
   --
   vv_compl                       pessoa.compl%type;
   vv_nro                         pessoa.nro%type;
   vn_cep                         pessoa.cep%type;
   vv_bairro                      pessoa.bairro%type;
   --
   vv_sigla_estado                estado.sigla_estado%type;
   vv_descr_cidade                cidade.descr%type;
   vv_sigla_pais                  pais.sigla_pais%type;
   vv_nome                        pessoa.nome%type;
   --
   vn_tomador_cidade_id           cidade.id%type;
   vn_empr_cidade_id              cidade.id%type;
   vv_inscr_mun                   juridica.im%type;
   vv_inscr_est                   juridica.ie%type;
   vn_vl_base_calc                imp_itemnf.vl_base_calc%type;
   --
   vv_simples                     valor_tipo_param.cd%type;
   vn_fase                        number;
   vv_empr_ibge_cidade            cidade.ibge_cidade%type;
   vv_item_ibge_cidade            cidade.ibge_cidade%type;
   vn_pessoaPais_id               pais.id%type;
   vn_count_part_ext              number;
   --
   cursor c_nfs is
     select nf.id           notafiscal_id
          , nf.dt_emiss
          , nf.nro_nf
          , nf.serie
          , nf.pessoa_id
          , nf.empresa_id
          , ics.codtribmunicipio_id
       from nota_fiscal nf
          , mod_fiscal mf
          , empresa e
          , pessoa p
          , nf_compl_serv  ncs
          , item_nota_fiscal inf
          , itemnf_compl_serv ics
          , cidade c
          , cidade_nfse       cn
      where nf.empresa_id      = gn_empresa_id
        and nf.dm_ind_emit     = gn_dm_ind_emit
        and nf.dm_st_proc      = 4
        and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
        and mf.id              = nf.modfiscal_id
        and ((mf.cod_mod = '99') or (mf.cod_mod = '55'))
        --and inf.cd_lista_serv is not null
        and e.id               = nf.empresa_id
        and p.id               = e.pessoa_id
        and p.cidade_id        = c.id
        and c.id               = cn.cidade_id
        and cn.dm_padrao       = 2 -- GINFES
        and p.cidade_id        = gn_cidade_id
        and nf.id              = ncs.notafiscal_id (+)
        and nf.id              = inf.notafiscal_id
        and inf.id             = ics.itemnf_id (+)
        and ((inf.cd_lista_serv is not null)
              or
             (ics.codtribmunicipio_id is not null))
      order by nf.id;
begin
   --
   vn_fase := 1;
   --
   vn_count_part_ext := null;
   --
   begin
      --
      select count(1)
        into vn_count_part_ext
        from pessoa p1
           , cidade c
           , estado e
           , pais   pa
       where p1.cidade_id = c.id
         and c.estado_id  = e.id
         and e.pais_id    = pa.id
         and pa.cod_siscomex  <> '1058'
         and p1.id in ( select nf.pessoa_id
                          from nota_fiscal nf
                             , mod_fiscal mf
                             , empresa e
                             , pessoa p
                             , nf_compl_serv  ncs
                             , item_nota_fiscal inf
                             , itemnf_compl_serv ics
                             , cidade c
                             , cidade_nfse       cn
                         where nf.empresa_id      = gn_empresa_id
                           and nf.dm_ind_emit     = gn_dm_ind_emit
                           and nf.dm_st_proc        = 4
                           and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
                           or
                           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
                           or
                           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
                           or
                           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
                           and mf.id              = nf.modfiscal_id
                           and ((mf.cod_mod = '99') or (mf.cod_mod = '55'))
                           and inf.cd_lista_serv is not null
                           and e.id               = nf.empresa_id
                           and p.id               = e.pessoa_id
                           and p.cidade_id        = c.id
                           and c.id               = cn.cidade_id
                           and cn.dm_padrao       = 2 -- GINFES
                           and p.cidade_id        = gn_cidade_id
                           and nf.id              = ncs.notafiscal_id (+)
                           and nf.id              = inf.notafiscal_id
                           and inf.id             = ics.itemnf_id (+));
      --
   exception
    when others then
       vn_count_part_ext := null;
   end;
   --
   vn_fase := 1.2;
   --
   -- Cabeçalho
   --
   gl_conteudo := 'CD_INDICADOR';
   gl_conteudo := gl_conteudo ||'||'|| 'NR_LAYOUT';
   gl_conteudo := gl_conteudo ||'||'|| 'DT_EMISSAO_NF';
   gl_conteudo := gl_conteudo ||'||'|| 'NR_DOC_NF_INICIAL';
   gl_conteudo := gl_conteudo ||'||'|| 'NR_DOC_NF_SERIE';
   gl_conteudo := gl_conteudo ||'||'|| 'NR_DOC_NF_FINAL';
   gl_conteudo := gl_conteudo ||'||'|| 'TP_DOC_NF';
   gl_conteudo := gl_conteudo ||'||'|| 'VL_DOC_NF';
   gl_conteudo := gl_conteudo ||'||'|| 'VL_BASE_CALCULO';
   gl_conteudo := gl_conteudo ||'||'|| 'CD_ATIVIDADE';
   gl_conteudo := gl_conteudo ||'||'|| 'CD_PREST_TOM_ESTABELECIDO';
   gl_conteudo := gl_conteudo ||'||'|| 'CD_LOCAL_PRESTACAO';
   gl_conteudo := gl_conteudo ||'||'|| 'NM_RAZAO_SOCIAL';
   gl_conteudo := gl_conteudo ||'||'|| 'NR_CNPJ_CPF';
   gl_conteudo := gl_conteudo ||'||'|| 'CD_TIPO_CADASTRO';
   gl_conteudo := gl_conteudo ||'||'|| 'NR_INSCRICAO_MUNICIPAL';
   gl_conteudo := gl_conteudo ||'||'|| 'NM_INSCRICAO_MUNICIPAL_DV';
   gl_conteudo := gl_conteudo ||'||'|| 'NR_INSCRICAO_ESTADUAL';
   gl_conteudo := gl_conteudo ||'||'|| 'NM_TIPO_LOGRADOURO';
   gl_conteudo := gl_conteudo ||'||'|| 'NM_TITULO_LOGRADOURO';
   gl_conteudo := gl_conteudo ||'||'|| 'NM_LOGRADOURO';
   gl_conteudo := gl_conteudo ||'||'|| 'NM_COMPL_LOGRADOURO';
   gl_conteudo := gl_conteudo ||'||'|| 'NR_LOGRADOURO';
   gl_conteudo := gl_conteudo ||'||'|| 'CD_CEP';
   gl_conteudo := gl_conteudo ||'||'|| 'NM_BAIRRO';
   gl_conteudo := gl_conteudo ||'||'|| 'CD_ESTADO';
   gl_conteudo := gl_conteudo ||'||'|| 'NM_CIDADE';
   gl_conteudo := gl_conteudo ||'||'|| 'CD_PAIS';
   gl_conteudo := gl_conteudo ||'||'|| 'NM_OBSERVACAO';
   gl_conteudo := gl_conteudo ||'||'|| 'CD_PLANO_CONTA';
   gl_conteudo := gl_conteudo ||'||'|| 'CD_ALVARA';
   gl_conteudo := gl_conteudo ||'||'|| 'IC_ORIGEM_DADOS';
   gl_conteudo := gl_conteudo ||'||'|| 'IC_ENQUADRAMENTO';
   gl_conteudo := gl_conteudo ||'||'|| 'CD_PLANO_CONTA_PAI';
   gl_conteudo := gl_conteudo ||'||'|| 'IC_RECOLHE_IMPOSTO';
   gl_conteudo := gl_conteudo ||'||'|| 'VL_ALIQUOTA';
   gl_conteudo := gl_conteudo ||'||'|| 'FL_ISENTO';
   gl_conteudo := gl_conteudo ||'||'|| 'FL_SIMPLES';
   --
   vn_fase := 1.3;
   --
   if nvl(vn_count_part_ext,0) > 0 then
      gl_conteudo := gl_conteudo ||'||'|| 'CD_PAIS';
      gl_conteudo := gl_conteudo ||'||'|| 'NM_OBSERVACAO';
   end if;
   --
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_fase := 2;
   --
   for rec in c_nfs
   loop
      --
      vn_pessoaPais_id := null;
      vv_sigla_pais    := null;
      --
      begin
         --
         select pa.id
              , substr(pa.sigla_pais,1,2)
           into vn_pessoaPais_id
              , vv_sigla_pais
           from pessoa p
              , cidade c
              , estado e
              , pais   pa
          where p.id         = rec.pessoa_id
            and p.cidade_id  = c.id
            and c.estado_id  = e.id
            and e.pais_id    = pa.id;
         --
      exception
       when others then
         vn_pessoaPais_id := null;
         vv_sigla_pais    := null;
      end;
      --
      if pk_csf.fkg_cod_siscomex_pais_id ( en_pais_id => vn_pessoaPais_id ) = '1058' then  -- Brasil
         gl_conteudo := 'T' ||'||'|| 1; -- Serv. Tomado de Prestador Residente no pais com Nota Fiscal
      else
         gl_conteudo := 'F' ||'||'|| 4; -- Serv. Tomado de Prestador Residente Fora do Pais com Nota Fiscal
      end if;
      --
      --gl_conteudo := gl_conteudo ||'||'|| fkg_combinacao_indicador(rec.empresa_id ); -- Tipo de Layout
      gl_conteudo := gl_conteudo ||'||'|| to_date(rec.dt_emiss,'dd/mm/yyyy'); -- Data de Emissão
      gl_conteudo := gl_conteudo ||'||'|| rec.nro_nf; -- Nro Nota Fiscal Inicial
      gl_conteudo := gl_conteudo ||'||'|| rec.serie; -- Serie da Nota
      gl_conteudo := gl_conteudo ||'||'|| rec.nro_nf; -- Nro Nota Fiscal Final
      --
      vn_fase := 2.1;
      --
      vn_iss_retido := null;
      --
      begin
         select distinct(5)
           into vn_iss_retido
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id  = rec.notafiscal_id
            and inf.id             = ii.itemnf_id
            and ii.tipoimp_id      = ti.id
            and ti.cd              = 6 -- ISS
            and ii.dm_tipo         = 1 -- Retenção
            and inf.cd_lista_serv is not null;
      exception
         when others then
            vn_iss_retido  := 1;
      end;
      --
      vn_fase := 3;
      --
      vn_vl_item_bruto := null;
      --
      begin
         select nvl(sum(inf.vl_item_bruto),0)
           into vn_vl_item_bruto
           from item_nota_fiscal inf
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.cd_lista_serv is not null;
      exception
         when others then
            vn_vl_item_bruto  := 0;
      end;
      --
      vn_fase := 4;
      --
      vn_vl_aliq_aplic := null;
      vn_vl_base_calc  := null;
      --
      begin
         select nvl(sum(ii.ALIQ_APLI),0)
              , nvl(sum(ii.vl_base_calc),0)
           into vn_vl_aliq_aplic
              , vn_vl_base_calc
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto   ti
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.tipoimp_id     = ti.id
            and ti.cd             = 6 -- ISS
            and ii.dm_tipo        = 1; -- Retido 
      exception
         when others then
           vn_vl_aliq_aplic := 0;
           vn_vl_base_calc  := 0;
      end;
      --
      vn_fase := 5;
      --
      vn_cd_lista_serv := null;
      --
      begin
         select max(inf.cd_lista_serv)
           into vn_cd_lista_serv
           from item_nota_fiscal inf
          where inf.notafiscal_id  = rec.notafiscal_id;
      exception
          when others then
            vn_cd_lista_serv := null;
      end;
      --
      vn_fase := 6;
      --
      gl_conteudo := gl_conteudo ||'||'|| vn_iss_retido; -- ISS Retido
      gl_conteudo := gl_conteudo ||'||'|| trim(vn_vl_item_bruto * 100); -- Valor do Documento.
      gl_conteudo := gl_conteudo ||'||'|| trim(vn_vl_base_calc * 100); -- Aliq. Aplicada
      --
      if nvl(rec.codtribmunicipio_id, 0) > 0 then
         gl_conteudo := gl_conteudo ||'||'|| trim(pk_csf.fkg_codtribmunicipio_cd ( en_codtribmunicipio_id => rec.codtribmunicipio_id )); -- Atividade ou Serviço Prestado.
      else
         gl_conteudo := gl_conteudo ||'||'|| trim( substr(vn_cd_lista_serv, 1, case when length(vn_cd_lista_serv) = 4 then 2 else 1 end) || '.' || substr(vn_cd_lista_serv, -2) ); -- Atividade ou Serviço Prestado.
      end if;
      --
      vn_fase := 6.1;
      --
      begin
      select distinct c.ibge_cidade
        into vv_empr_ibge_cidade
        from nota_fiscal nf
           , empresa e
           , pessoa  p
           , cidade c
       where nf.id          = rec.notafiscal_id
         and nf.empresa_id  = e.id
         and e.pessoa_id    = p.id
         and p.cidade_id    = c.id;
      exception
        when others then
           vv_empr_ibge_cidade     := null;
      end;
      --
      begin
        select distinct inf.cidade_ibge
          into vv_item_ibge_cidade
          from nota_fiscal nf
             , item_nota_fiscal inf
          where nf.id             = rec.notafiscal_id
            and inf.notafiscal_id = nf.id;
      exception
         when others then
            vv_item_ibge_cidade    := null;
      end;
      --
      vn_fase := 7;
      --
      vn_empr_cidade_id := pk_csf.fkg_cidade_id_nf_id (en_notafiscal_id =>  rec.notafiscal_id);
      --
      begin
         select p.cidade_id
           into vn_tomador_cidade_id
           from pessoa p
          where p.id = rec.pessoa_id;
      exception
         when others then
          vn_tomador_cidade_id := null;
      end;
      --
      vn_fase := 8;
      --
      if nvl(vn_empr_cidade_id,0) <> nvl(vn_tomador_cidade_id,0) then
         gl_conteudo := gl_conteudo ||'||'|| 'N'; -- Prestador/Tomador estabelecido no município:
      else
         gl_conteudo := gl_conteudo ||'||'|| 'S';
      end if;
      --
      if vv_item_ibge_cidade is null or vv_item_ibge_cidade <> vv_empr_ibge_cidade then
         --
         gl_conteudo := gl_conteudo ||'||'|| 'F'; -- Local da prestação e Serviço
         --
      else
         --
         gl_conteudo := gl_conteudo ||'||'|| 'D'; -- Local da prestação e Serviço
         --
      end if;
      vv_cpf_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec.pessoa_id );
      --
      vn_fase := 9;
      begin
         select p.nome
              , decode(p.dm_tipo_pessoa,0,1,1,2)
              --, pk_csf.fkg_inscr_mun_pessoa ( p.id )
              -- tipo lougr
              -- titulo lougr
              , p.lograd
              , p.compl
              , p.nro
              , p.cep
              , p.bairro
              , e.sigla_estado
              , c.descr
              , pa.sigla_pais
           into vv_nome
              , vn_dm_tipo_pessoa
              --, vv_inscr_mun
              , vv_lograd
              , vv_compl
              , vv_nro
              , vn_cep
              , vv_bairro
              , vv_sigla_estado
              , vv_descr_cidade
              , vv_sigla_pais
           from pessoa p
              , cidade c
              , estado e
              , pais pa
           where p.id        = rec.pessoa_id
             and p.cidade_id = c.id
             and e.id        = c.estado_id
             and e.pais_id   = pa.id;
      exception
         when others then
            vv_nome           := null;
            vn_dm_tipo_pessoa := null;
            vv_lograd         := null;
            vv_compl          := null;
            vv_nro            := null;
            vn_cep            := null;
            vv_bairro         := null;
            vv_sigla_estado   := null;
            vv_descr_cidade   := null;
            vv_sigla_pais     := null;
      end;
      --
      vn_fase := 10;
      --
      vv_inscr_mun := pk_csf.fkg_inscr_mun_pessoa ( en_pessoa_id => rec.pessoa_id );
      --
      vv_inscr_est := pk_csf.fkg_ie_pessoa_id ( en_pessoa_id => rec.pessoa_id );
      --
      gl_conteudo := gl_conteudo ||'||'|| vv_nome ;
      gl_conteudo := gl_conteudo ||'||'|| vv_cpf_cnpj;
      gl_conteudo := gl_conteudo ||'||'|| vn_dm_tipo_pessoa;
      gl_conteudo := gl_conteudo ||'||'|| replace(replace(replace(vv_inscr_mun,'-',''),'.',''),'/',''); -- vv_inscr_mun
      gl_conteudo := gl_conteudo ||'||'; -- NM_INSCRICAO_MUNICIPAL_DV
      gl_conteudo := gl_conteudo ||'||'|| replace(replace(replace(vv_inscr_est,'-',''),'.',''),'/',''); -- vv_inscr_est
      gl_conteudo := gl_conteudo ||'||Rua'; -- NM_TIPO_LOGRADOURO
      gl_conteudo := gl_conteudo ||'||Dr'; -- NM_TITULO_LOGRADOURO
      gl_conteudo := gl_conteudo ||'||'|| vv_lograd;
      gl_conteudo := gl_conteudo ||'||'|| vv_compl;
      gl_conteudo := gl_conteudo ||'||'|| vv_nro;
      gl_conteudo := gl_conteudo ||'||'|| vn_cep;
      gl_conteudo := gl_conteudo ||'||'|| vv_bairro;
      gl_conteudo := gl_conteudo ||'||'|| vv_sigla_estado;
      gl_conteudo := gl_conteudo ||'||'|| vv_descr_cidade;
      gl_conteudo := gl_conteudo ||'||'|| vv_sigla_pais;
      --
      vn_fase := 11;
      --
      -- Informações em Branco
      --
      gl_conteudo := gl_conteudo ||'||'; -- Informações gerais sobre a empresa
      gl_conteudo := gl_conteudo ||'||'; -- Código do item do plano de contas
      gl_conteudo := gl_conteudo ||'||'; -- cd_alvara
      --
      gl_conteudo := gl_conteudo ||'||'||'R'; -- IC_ORIGEM_DADOS
      --
      gl_conteudo := gl_conteudo ||'||'; -- tabela de enquadramento
      gl_conteudo := gl_conteudo ||'||'; -- Código da conta mestre
      gl_conteudo := gl_conteudo ||'||'|| '0'; -- Recolhe imposto  1- sim 0- não
      --
      if nvl(vn_vl_aliq_aplic,0) = 0 then
         gl_conteudo := gl_conteudo ||'||'; -- não deverá ser informado 0(zero)
      else
         gl_conteudo := gl_conteudo ||'||'|| lpad(trim(to_char(trunc(vn_vl_aliq_aplic, 2), '999g999g999g999g990d00', 'nls_numeric_characters=.,')),5,0);
      end if;
      --
      vv_simples := pk_csf.fkg_pessoa_valortipoparam_cd ( ev_tipoparam_cd => 1 -- Simples nacional
                                                        , en_pessoa_id => rec.pessoa_id);
      --
      vn_fase := 12;
      --
      if vv_inscr_est is null then
         gl_conteudo := gl_conteudo ||'||'|| 'S'; -- Isenção de Inscrição Estadual
      else
         gl_conteudo := gl_conteudo ||'||'|| 'N';
      end if;
      --
      vn_fase := 13;
      --
      if nvl(vv_simples,1) = 0 then
         gl_conteudo := gl_conteudo ||'||'||'S'; -- Prestador optante pelo simples nacional.
      else
         gl_conteudo := gl_conteudo ||'||'||'N';
      end if;
      --
      vn_fase := 13.2;
      --
      if nvl(vn_count_part_ext,0) > 0 then
         gl_conteudo := gl_conteudo || '||' || vv_sigla_pais ||'||';
      end if;
      --
      vn_fase :=13.3;
      --
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
      vn_fase := 14;
      --
   end loop;
 --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_dm_ginfes fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_dm_ginfes;
*/

---------------------------------------------------------------------------------------------------------------------
-- Melhoria no processo de recuperação dos dados e agrupamento de valores referente ao
-- Redmine #37834 - Geração do arquivo de Serviços Tomados de ISS para Gissonline.
-- Implementação de processo de Exportação de Notas Fiscais de Serviços Tomados para GissOnline
procedure pkb_gera_arq_cid_dm_ginfes is
   --
   vn_iss_retido                  number;
   vn_vl_aliq_aplic               imp_itemnf.aliq_apli%type;
   --
   vn_dm_loc_exe_serv             itemnf_compl_serv.dm_loc_exe_serv%type;
   vv_cpf_cnpj                    varchar2(14);
   vn_dm_tipo_pessoa              pessoa.dm_tipo_pessoa%type;
   vv_lograd                      pessoa.lograd%type;
   --
   vv_compl                       pessoa.compl%type;
   vv_nro                         pessoa.nro%type;
   vn_cep                         pessoa.cep%type;
   vv_bairro                      pessoa.bairro%type;
   --
   vv_sigla_estado                estado.sigla_estado%type;
   vv_descr_cidade                cidade.descr%type;
   vv_sigla_pais                  pais.sigla_pais%type;
   vv_nome                        pessoa.nome%type;
   --
   vn_tomador_cidade_id           cidade.id%type;
   vv_inscr_mun                   juridica.im%type;
   vv_inscr_est                   juridica.ie%type;
   vn_vl_base_calc                imp_itemnf.vl_base_calc%type;
   --
   vv_simples                     valor_tipo_param.cd%type;
   vn_fase                        number;
   vn_pessoapais_id               pais.id%type;
   vn_count_part_ext              number;
   --
   cursor c_nfs is
     select nf.id           notafiscal_id
          , nf.dt_emiss
          , nf.nro_nf
          , nf.serie
          , nf.pessoa_id
          , nf.empresa_id
          , ics.codtribmunicipio_id
          , inf.cd_lista_serv
          , inf.cidade_ibge
          , c.id cidade_id_empr
          , c.ibge_cidade empr_ibge_cidade
          , nvl(sum(inf.vl_item_bruto),0) vl_item_bruto
          , nd.cod_obra -- Código da Obra
       from nota_fiscal       nf
          , mod_fiscal        mf
          , empresa           e
          , pessoa            p
          , nf_compl_serv     ncs
          , item_nota_fiscal  inf
          , itemnf_compl_serv ics
          , cidade            c
          , cidade_nfse       cn
          , nfs_det_constr_civil nd
      where nf.empresa_id      = gn_empresa_id
        and nf.dm_ind_emit     = gn_dm_ind_emit
        and nf.dm_st_proc      = 4
        and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
        and mf.id              = nf.modfiscal_id
        and ((mf.cod_mod = '99') or (mf.cod_mod = '55'))
        and e.id               = nf.empresa_id
        and p.id               = e.pessoa_id
        and p.cidade_id        = c.id
        and c.id               = cn.cidade_id
        and cn.dm_padrao       = 2 -- GINFES
        and p.cidade_id        = gn_cidade_id
        and nf.id              = ncs.notafiscal_id (+)
        and nf.id              = nd.notafiscal_id(+)
        and nf.id              = inf.notafiscal_id
        and inf.id             = ics.itemnf_id (+)
        and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
        and ((inf.cd_lista_serv is not null)
              or
             (ics.codtribmunicipio_id is not null))
      group by nf.id
          , nf.dt_emiss
          , nf.nro_nf
          , nf.serie
          , nf.pessoa_id
          , nf.empresa_id
          , ics.codtribmunicipio_id
          , inf.cd_lista_serv
          , inf.cidade_ibge
          , c.id
          , c.ibge_cidade
          , nd.cod_obra
      order by nf.id;
   --
begin
   --
   vn_fase := 1;
   --
   vn_count_part_ext := null;
   --
   begin
      --
      select count(1)
        into vn_count_part_ext
        from pessoa p1
           , cidade c
           , estado e
           , pais   pa
       where p1.cidade_id = c.id
         and c.estado_id  = e.id
         and e.pais_id    = pa.id
         and pa.cod_siscomex  <> '1058'
         and p1.id in ( select nf.pessoa_id
                          from nota_fiscal nf
                             , mod_fiscal mf
                             , empresa e
                             , pessoa p
                             , nf_compl_serv  ncs
                             , item_nota_fiscal inf
                             , itemnf_compl_serv ics
                             , cidade c
                             , cidade_nfse       cn
                         where nf.empresa_id      = gn_empresa_id
                           and nf.dm_ind_emit     = gn_dm_ind_emit
                           and nf.dm_st_proc        = 4
                           and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
                           or
                           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
                           or
                           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
                           or
                           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
                           and mf.id              = nf.modfiscal_id
                           and ((mf.cod_mod = '99') or (mf.cod_mod = '55'))
                           and inf.cd_lista_serv is not null
                           and e.id               = nf.empresa_id
                           and p.id               = e.pessoa_id
                           and p.cidade_id        = c.id
                           and c.id               = cn.cidade_id
                           and cn.dm_padrao       = 2 -- GINFES
                           and p.cidade_id        = gn_cidade_id
                           and nf.id              = ncs.notafiscal_id (+)
                           and nf.id              = inf.notafiscal_id
                           and inf.id             = ics.itemnf_id (+)
                           and nvl(nf.dm_arm_nfe_terc, 0) = 0); -- #73514
      --
   exception
      when others then
         vn_count_part_ext := null;
   end;
   --
   vn_fase := 1.2;
   --
   -- Cabeçalho
   --
   gl_conteudo := 'CD_INDICADOR';
   gl_conteudo := gl_conteudo ||'||'|| 'NR_LAYOUT';
   gl_conteudo := gl_conteudo ||'||'|| 'DT_EMISSAO_NF';
   gl_conteudo := gl_conteudo ||'||'|| 'NR_DOC_NF_INICIAL';
   gl_conteudo := gl_conteudo ||'||'|| 'NR_DOC_NF_SERIE';
   gl_conteudo := gl_conteudo ||'||'|| 'NR_DOC_NF_FINAL';
   gl_conteudo := gl_conteudo ||'||'|| 'TP_DOC_NF';
   gl_conteudo := gl_conteudo ||'||'|| 'VL_DOC_NF';
   gl_conteudo := gl_conteudo ||'||'|| 'VL_BASE_CALCULO';
   gl_conteudo := gl_conteudo ||'||'|| 'CD_ATIVIDADE';
   gl_conteudo := gl_conteudo ||'||'|| 'CD_PREST_TOM_ESTABELECIDO';
   gl_conteudo := gl_conteudo ||'||'|| 'CD_LOCAL_PRESTACAO';
   gl_conteudo := gl_conteudo ||'||'|| 'NM_RAZAO_SOCIAL';
   gl_conteudo := gl_conteudo ||'||'|| 'NR_CNPJ_CPF';
   gl_conteudo := gl_conteudo ||'||'|| 'CD_TIPO_CADASTRO';
   gl_conteudo := gl_conteudo ||'||'|| 'NR_INSCRICAO_MUNICIPAL';
   gl_conteudo := gl_conteudo ||'||'|| 'NM_INSCRICAO_MUNICIPAL_DV';
   gl_conteudo := gl_conteudo ||'||'|| 'NR_INSCRICAO_ESTADUAL';
   gl_conteudo := gl_conteudo ||'||'|| 'NM_TIPO_LOGRADOURO';
   gl_conteudo := gl_conteudo ||'||'|| 'NM_TITULO_LOGRADOURO';
   gl_conteudo := gl_conteudo ||'||'|| 'NM_LOGRADOURO';
   gl_conteudo := gl_conteudo ||'||'|| 'NM_COMPL_LOGRADOURO';
   gl_conteudo := gl_conteudo ||'||'|| 'NR_LOGRADOURO';
   gl_conteudo := gl_conteudo ||'||'|| 'CD_CEP';
   gl_conteudo := gl_conteudo ||'||'|| 'NM_BAIRRO';
   gl_conteudo := gl_conteudo ||'||'|| 'CD_ESTADO';
   gl_conteudo := gl_conteudo ||'||'|| 'NM_CIDADE';
   gl_conteudo := gl_conteudo ||'||'|| 'CD_PAIS';
   gl_conteudo := gl_conteudo ||'||'|| 'NM_OBSERVACAO';
   gl_conteudo := gl_conteudo ||'||'|| 'CD_PLANO_CONTA';
   gl_conteudo := gl_conteudo ||'||'|| 'CD_ALVARA';
   gl_conteudo := gl_conteudo ||'||'|| 'IC_ORIGEM_DADOS';
   gl_conteudo := gl_conteudo ||'||'|| 'IC_ENQUADRAMENTO';
   gl_conteudo := gl_conteudo ||'||'|| 'CD_PLANO_CONTA_PAI';
   gl_conteudo := gl_conteudo ||'||'|| 'IC_RECOLHE_IMPOSTO';
   gl_conteudo := gl_conteudo ||'||'|| 'VL_ALIQUOTA';
   gl_conteudo := gl_conteudo ||'||'|| 'FL_ISENTO';
   gl_conteudo := gl_conteudo ||'||'|| 'FL_SIMPLES';
   --
   vn_fase := 1.3;
   --
   if nvl(vn_count_part_ext,0) > 0 then
      gl_conteudo := gl_conteudo ||'||'|| 'CD_PAIS';
      gl_conteudo := gl_conteudo ||'||'|| 'NM_OBSERVACAO';
   end if;
   --
   vn_fase := 1.4;
   --
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_fase := 2;
   --
   for rec in c_nfs
   loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_fase := 3;
      --
      vn_tomador_cidade_id := null;
      vn_pessoapais_id     := null;
      vv_sigla_pais        := null;
      vv_nome              := null;
      vn_dm_tipo_pessoa    := null;
      vv_lograd            := null;
      vv_compl             := null;
      vv_nro               := null;
      vn_cep               := null;
      vv_bairro            := null;
      vv_sigla_estado      := null;
      vv_descr_cidade      := null;
      --
      begin
         select p.cidade_id
              , pa.id
              , substr(pa.sigla_pais,1,2)
              , p.nome
              , decode(p.dm_tipo_pessoa,0,1,1,2)
              , p.lograd
              , p.compl
              , p.nro
              , p.cep
              , p.bairro
              , e.sigla_estado
              , c.descr
           into vn_tomador_cidade_id
              , vn_pessoapais_id
              , vv_sigla_pais
              , vv_nome
              , vn_dm_tipo_pessoa
              , vv_lograd
              , vv_compl
              , vv_nro
              , vn_cep
              , vv_bairro
              , vv_sigla_estado
              , vv_descr_cidade
           from pessoa p
              , cidade c
              , estado e
              , pais pa
           where p.id  = rec.pessoa_id
             and c.id  = p.cidade_id
             and e.id  = c.estado_id
             and pa.id = e.pais_id;
      exception
         when others then
            vn_tomador_cidade_id := null;
            vn_pessoapais_id     := null;
            vv_sigla_pais        := null;
            vv_nome              := null;
            vn_dm_tipo_pessoa    := null;
            vv_lograd            := null;
            vv_compl             := null;
            vv_nro               := null;
            vn_cep               := null;
            vv_bairro            := null;
            vv_sigla_estado      := null;
            vv_descr_cidade      := null;
      end;
      --
      vn_fase := 3.1;
      --
      if nvl(rec.cidade_id_empr,0) = nvl(vn_tomador_cidade_id,0) then
         --
         vn_fase := 3.2;
         --
         goto proxima_nf;
         --
      end if;
      --
      vn_fase := 4;
      --
      if pk_csf.fkg_cod_siscomex_pais_id ( en_pais_id => vn_pessoapais_id ) = '1058' then  -- Brasil
        if rec.cod_obra is not null then 
         gl_conteudo := 'H' ||'||'|| 6; -- NFSe tomada com obra
        else
         gl_conteudo := 'T' ||'||'|| 1; -- Serv. Tomado de Prestador Residente no pais com Nota Fiscal
         end if;
      else
         gl_conteudo := 'F' ||'||'|| 4; -- Serv. Tomado de Prestador Residente Fora do Pais com Nota Fiscal
      end if;
      --
      vn_fase := 5;
      --
      gl_conteudo := gl_conteudo ||'||'|| to_date(rec.dt_emiss,'dd/mm/yyyy'); -- Data de Emissão
      gl_conteudo := gl_conteudo ||'||'|| rec.nro_nf; -- Nro Nota Fiscal Inicial
      gl_conteudo := gl_conteudo ||'||'|| rec.serie; -- Serie da Nota
      gl_conteudo := gl_conteudo ||'||'|| rec.nro_nf; -- Nro Nota Fiscal Final
      --
      vn_fase := 6;
      --
      vn_iss_retido := null;
      --
      begin
         select distinct(5)
           into vn_iss_retido
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
              , itemnf_compl_serv ics
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.tipoimp_id     = ti.id
            and ti.cd             = 6 -- ISS
            and ii.dm_tipo        = 1 -- Retenção
            and ii.vl_imp_trib    > 0
            and ics.itemnf_id(+)  = inf.id
            and nvl(inf.cd_lista_serv,0) = nvl(rec.cd_lista_serv,0)
            and nvl(ics.codtribmunicipio_id,0) = nvl(rec.codtribmunicipio_id,0);
      exception
         when others then
            -- Para os Municípios de Santos, Nova Iguaçu, São José dos Campos e São Bernardo do Campo utilizar a particularidade dos códigos de retenção
            if rec.empr_ibge_cidade in (3548500, 3303500, /*3549904,*/ 3548708) then
               begin
                 select case nvl(ncs.dm_nat_oper, 2)
                          when 1 then
                           1 -- Tributação no município (Não Retida)
                          when 2 then
                           6 -- Tributação fora do município (Pgto. pelo prestador)
                          when 3 then
                           4 -- Isenta
                          when 4 then
                           7 -- Imune
                          when 5 then
                           8 -- Exigibilidade suspensa por decisão judicial 
                        end natureza_operacao
                   into vn_iss_retido
                   from item_nota_fiscal  inf,
                        imp_itemnf        ii,
                        tipo_imposto      ti,
                        itemnf_compl_serv ics,
                        nf_compl_serv     ncs
                  where ii.itemnf_id         = inf.id
                    and ti.id                = ii.tipoimp_id
                    and ics.itemnf_id(+)     = inf.id
                    and ncs.notafiscal_id(+) = inf.notafiscal_id
                    --
                    and ti.cd                = 6 -- ISS
                    and ii.dm_tipo           = 0 -- Não Retido
                    --and ii.vl_imp_trib                 > 0
                    and inf.notafiscal_id               = rec.notafiscal_id
                    and nvl(inf.cd_lista_serv, 0)       = nvl(rec.cd_lista_serv, 0)
                    and nvl(ics.codtribmunicipio_id, 0) = nvl(rec.codtribmunicipio_id, 0);
               exception
                 when others then
                   vn_iss_retido := 1;
               end;
            else
               vn_iss_retido := 4;
            end if;   
      end;
      --
      vn_fase := 7;
      --
      vn_vl_aliq_aplic := null;
      vn_vl_base_calc  := null;
      --
      begin
         select max(nvl(ii.aliq_apli,0))
              , nvl(sum(ii.vl_base_calc),0)
           into vn_vl_aliq_aplic
              , vn_vl_base_calc
           from item_nota_fiscal  inf
              , imp_itemnf        ii
              , tipo_imposto      ti
              , itemnf_compl_serv ics
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.tipoimp_id     = ti.id
            and ti.cd             = 6 -- ISS
            and ii.dm_tipo        = 1 -- Retenção
            and ii.vl_imp_trib    > 0
            and ics.itemnf_id(+)  = inf.id
            and nvl(inf.cd_lista_serv,0) = nvl(rec.cd_lista_serv,0)
            and nvl(ics.codtribmunicipio_id,0) = nvl(rec.codtribmunicipio_id,0);
      exception
         when others then
            vn_vl_aliq_aplic := 0;
            vn_vl_base_calc  := 0;
      end;
      --
      vn_fase := 8;
      --
      gl_conteudo := gl_conteudo ||'||'|| vn_iss_retido; -- ISS Retido
      gl_conteudo := gl_conteudo ||'||'|| trim(rec.vl_item_bruto * 100); -- Valor do Documento.
      gl_conteudo := gl_conteudo ||'||'|| trim(vn_vl_base_calc * 100); -- Aliq. Aplicada
      --
      vn_fase := 9;
      --
      if nvl(rec.codtribmunicipio_id, 0) > 0 then
         gl_conteudo := gl_conteudo ||'||'|| trim(pk_csf.fkg_codtribmunicipio_cd ( en_codtribmunicipio_id => rec.codtribmunicipio_id )); -- Atividade ou Serviço Prestado.
      else
         gl_conteudo := gl_conteudo ||'||'|| trim( substr(rec.cd_lista_serv, 1, case when length(rec.cd_lista_serv) = 4 then 2 else 1 end) || '.' || substr(rec.cd_lista_serv, -2) ); -- Atividade ou Serviço Prestado.
      end if;
      --
      vn_fase := 10;
      --
      if nvl(rec.cidade_id_empr,0) <> nvl(vn_tomador_cidade_id,0) then
         gl_conteudo := gl_conteudo ||'||'|| 'N'; -- Prestador/Tomador estabelecido no município:
      else
         gl_conteudo := gl_conteudo ||'||'|| 'S';
      end if;
      --
      vn_fase := 11;
      --
      if rec.cidade_ibge is null or rec.cidade_ibge <> rec.empr_ibge_cidade then
         gl_conteudo := gl_conteudo ||'||'|| 'F'; -- Local da prestação e Serviço
      else
         gl_conteudo := gl_conteudo ||'||'|| 'D'; -- Local da prestação e Serviço
      end if;
      --
      vn_fase := 12;
      --
      vv_cpf_cnpj  := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec.pessoa_id );
      vv_inscr_mun := pk_csf.fkg_inscr_mun_pessoa ( en_pessoa_id => rec.pessoa_id );
      vv_inscr_est := pk_csf.fkg_ie_pessoa_id ( en_pessoa_id => rec.pessoa_id );
      --
      vn_fase := 13;
      --
      gl_conteudo := gl_conteudo ||'||'|| vv_nome ;
      gl_conteudo := gl_conteudo ||'||'|| vv_cpf_cnpj;
      gl_conteudo := gl_conteudo ||'||'|| vn_dm_tipo_pessoa;
      gl_conteudo := gl_conteudo ||'||'|| replace(replace(replace(vv_inscr_mun,'-',''),'.',''),'/',''); -- vv_inscr_mun
      gl_conteudo := gl_conteudo ||'||'; -- NM_INSCRICAO_MUNICIPAL_DV  
      --
      if trim(vv_inscr_est) is not null and
         upper(trim(vv_inscr_est)) <> upper(trim('ISENTO')) then
         gl_conteudo := gl_conteudo ||'||'|| replace(replace(replace(vv_inscr_est,'-',''),'.',''),'/',''); -- vv_inscr_est
      else
         gl_conteudo := gl_conteudo ||'||'; -- vv_inscr_est
      end if;
      --
      gl_conteudo := gl_conteudo ||'|| '; -- NM_TIPO_LOGRADOURO
      gl_conteudo := gl_conteudo ||'|| '; -- NM_TITULO_LOGRADOURO
      gl_conteudo := gl_conteudo ||'||'|| trim(substr(vv_lograd, 1, 50));
      gl_conteudo := gl_conteudo ||'||'|| trim(substr(vv_compl, 1, 40));
      gl_conteudo := gl_conteudo ||'||'|| vv_nro;
      gl_conteudo := gl_conteudo ||'||'|| vn_cep;
      gl_conteudo := gl_conteudo ||'||'|| vv_bairro;
      gl_conteudo := gl_conteudo ||'||'|| vv_sigla_estado;
      gl_conteudo := gl_conteudo ||'||'|| vv_descr_cidade;
      gl_conteudo := gl_conteudo ||'||'|| vv_sigla_pais;
      --
      vn_fase := 14;
      --
      -- Informações em Branco
      --
      gl_conteudo := gl_conteudo ||'||'; -- Informações gerais sobre a empresa
      gl_conteudo := gl_conteudo ||'||'; -- Código do item do plano de contas
      gl_conteudo := gl_conteudo ||'||'|| rec.cod_obra; -- cd_alvara
      --
      gl_conteudo := gl_conteudo ||'||'||'R'; -- IC_ORIGEM_DADOS
      --
      gl_conteudo := gl_conteudo ||'||'; -- tabela de enquadramento
      gl_conteudo := gl_conteudo ||'||'; -- Código da conta mestre
      gl_conteudo := gl_conteudo ||'||'|| '0'; -- Recolhe imposto  1- sim 0- não
      --
      vn_fase := 15;
      --
      if nvl(vn_vl_aliq_aplic,0) = 0 then
         gl_conteudo := gl_conteudo ||'||'; -- não deverá ser informado 0(zero)
      else
         gl_conteudo := gl_conteudo ||'||'|| lpad(trim(to_char(trunc(vn_vl_aliq_aplic, 2), '999g999g999g999g990d00', 'nls_numeric_characters=.,')),5,0);
      end if;
      --
      vn_fase := 16;
      --
      vv_simples := null;
      --
      vv_simples := pk_csf.fkg_pessoa_valortipoparam_cd ( ev_tipoparam_cd => 1 -- Simples nacional
                                                        , en_pessoa_id    => rec.pessoa_id);
      --
      vn_fase := 17;
      --
      if vv_inscr_est is null then
         gl_conteudo := gl_conteudo ||'||'|| 'S'; -- Isenção de Inscrição Estadual
      else
         gl_conteudo := gl_conteudo ||'||'|| 'N';
      end if;
      --
      vn_fase := 18;
      --
      if trim(nvl(vv_simples,'0')) = '0' then  --  0-Não e 1-Sim
         gl_conteudo := gl_conteudo ||'||'||'N'; -- Prestador optante pelo simples nacional.
      else
         gl_conteudo := gl_conteudo ||'||'||'S';
      end if;
      --
      vn_fase := 19;
      --
      if nvl(vn_count_part_ext,0) > 0 then
         gl_conteudo := gl_conteudo || '||' || vv_sigla_pais ||'||';
      end if;
      --
      vn_fase := 20;
      --
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
      <<proxima_nf>>
      --
      vn_fase := 99;
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_dm_ginfes fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_dm_ginfes;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração de arquivo de Nota Fiscal de Serviço de Camaçari / BA
procedure pkb_gera_arq_cid_2905701 is
    --
    vn_fase                        number;
    vn_vl_item_bruto               item_nota_fiscal.vl_item_bruto%type;
    vn_qtd_itens                   number;
    vn_qtde_linhas                 number;
    --
    vn_vl_base_calc                imp_itemnf.vl_base_calc%type;
    vn_vl_imp_trib                 imp_itemnf.vl_imp_trib%type;
    vn_sit_documento               number;
    vv_im_prest                    juridica.im%type;
    --
    vn_tipo_entidade               number(1);
    vv_inscr_cpf_cnpj              varchar(15);
    vv_nome_entidade               pessoa.nome%type;
    vn_tipo_tributacao             imp_itemnf.dm_tipo%type;
    --
    vv_descr_item                  item_nota_fiscal.descr_item%type;
    vn_qtde_doc                    number;
    vn_aliq_apli                   imp_itemnf.aliq_apli%type;
    vn_vl_imp_trib_sum             imp_itemnf.vl_imp_trib%type;
    --
    cursor c_nfs is
     select nf.id           notafiscal_id
          , nf.nro_nf
          , nf.dt_emiss
          , nf.pessoa_id
          , nf.dm_ind_emit
          , ncs.dt_exe_serv
       from nota_fiscal nf
          , mod_fiscal mf
          , empresa e
          , pessoa p
          , nf_compl_serv  ncs
          , item_nota_fiscal inf
          , itemnf_compl_serv ics
      where nf.empresa_id      = gn_empresa_id
        and nf.dm_ind_emit     = gn_dm_ind_emit
        and nf.dm_st_proc      = 4
        and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
        and mf.id              = nf.modfiscal_id
        and ((mf.cod_mod = '99') or (mf.cod_mod = '55'))
        and inf.cd_lista_serv is not null
        and e.id               = nf.empresa_id
        and p.id               = e.pessoa_id
        and p.cidade_id        = gn_cidade_id
        and nf.id              = ncs.notafiscal_id (+)
        and nf.id              = inf.notafiscal_id
        and inf.id             = ics.itemnf_id (+)
        and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
      order by nf.id;
      --
    cursor c_inf(en_notafiscal_id number) is
      select inf.cd_lista_serv
           , sum(inf.vl_item_bruto) vl_item_bruto_sum
        from item_nota_fiscal inf
           , imp_itemnf       ii
           , tipo_imposto     ti
       where inf.notafiscal_id = en_notafiscal_id
         and ii.itemnf_id  (+) = inf.id
         and ti.id         (+) = ii.tipoimp_id
         and inf.cd_lista_serv    is not null
    group by inf.cd_lista_serv;
      --
begin
   --
   vn_fase := 1;
   vn_qtde_linhas := 1;
   --
   vv_im_prest := pk_csf.fkg_inscr_mun_empresa(en_empresa_id => gn_empresa_id);
   --
   begin
   --
      select count(nvl(nf.id,0))
        into vn_qtde_doc
        from nota_fiscal nf
           , mod_fiscal mf
           , empresa e
           , pessoa p
           , item_nota_fiscal inf
       where nf.empresa_id      = gn_empresa_id
         and nf.dm_ind_emit     = gn_dm_ind_emit
         and nf.dm_st_proc      = 4
         and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
             or
             (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
             or
             (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
             or
             (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
         and mf.id              = nf.modfiscal_id
         and ((mf.cod_mod = '99') or (mf.cod_mod = '55'))
         and inf.cd_lista_serv is not null
         and e.id               = nf.empresa_id
         and p.id               = e.pessoa_id
         and p.cidade_id        = gn_cidade_id
         and nf.id              = inf.notafiscal_id
         and nvl(nf.dm_arm_nfe_terc, 0) = 0; -- #73514
   --
   exception
      when others then
         vn_qtde_doc := 0;
   end;
   --   
   gl_conteudo := '1'; -- tipo de registro
   gl_conteudo := gl_conteudo || lpad(gn_dm_ind_emit,1,0); -- papel do declarente
   gl_conteudo := gl_conteudo || to_char(gd_dt_fin, 'yyyyMM'); -- competencia da escrituração
   gl_conteudo := gl_conteudo || lpad(nvl(substr(vv_im_prest,0,10),0),10,0); -- inscrição municipal do prestador
   gl_conteudo := gl_conteudo || 'V01.1'; -- versao do arquivo
   gl_conteudo := gl_conteudo || lpad(vn_qtde_doc,6,0); -- quantidade de documento fiscais
   gl_conteudo := gl_conteudo || lpad(' ',696,' ');
   gl_conteudo := gl_conteudo || lpad(vn_qtde_linhas,6,0); -- sequencia de registros
   --
   -- Armazena a estrutura do arquivo
   --
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_fase := 2;
   --
   for rec in c_nfs 
   loop
      --
      gl_conteudo := 2; -- Tipo do Registro
      gl_conteudo := gl_conteudo || '01'; -- Especie
      --
      vn_fase := 2.1;
      --
      begin
      --
         select distinct(03) -- Cancelado
           into vn_sit_documento
           from nota_fiscal_canc nfc
          where nfc.notafiscal_id = rec.notafiscal_id;
      --
      exception
         when no_data_found then
           vn_sit_documento := 01; -- Emitida
      end;
      --
      vn_fase := 3;
      --
      gl_conteudo := gl_conteudo || lpad(vn_sit_documento,2,0); -- Situação do Documento.
      gl_conteudo := gl_conteudo || rpad('A',20,' '); -- Nome da serie
      --         
      begin
          select decode(j.im,null,9,2) -- Inscrição municipal
            into vn_tipo_entidade
            from juridica j
           where j.pessoa_id = rec.pessoa_id;
      exception
           when others then
              vn_tipo_entidade := 0;
      end;
      -- 
      if vn_tipo_entidade = 0 then
      --
         begin
           select 8 -- Fisica
             into vn_tipo_entidade
             from fisica f
            where f.pessoa_id = rec.pessoa_id;
         exception
             when others then
               vn_tipo_entidade := 0;
         end;      
      --
      end if;
      --
      vn_fase := 4;
      --
      begin
      --
         if vn_tipo_entidade = 2 then
            vv_inscr_cpf_cnpj := pk_csf.fkg_inscr_mun_pessoa(en_pessoa_id =>  rec.pessoa_id ); 
         else
            vv_inscr_cpf_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec.pessoa_id );
         end if;
      -- 
      exception
        when others then
          vv_inscr_cpf_cnpj := null;
      end;
      --
      vn_fase := 5;
      --
      vv_nome_entidade := pk_csf.fkg_nome_pessoa_id ( en_pessoa_id => rec.pessoa_id );
      --
      gl_conteudo := gl_conteudo || lpad(nvl(vn_tipo_entidade,0),1,0); -- tipo entidade
      gl_conteudo := gl_conteudo || lpad(nvl(vv_inscr_cpf_cnpj,0),14,0); -- Inscrição Municipal, CPF ou CNPJ
      gl_conteudo := gl_conteudo || rpad(vv_nome_entidade,100,' '); -- Nome ou Razão social da Entidade
      gl_conteudo := gl_conteudo || lpad(rec.nro_nf, 10, 0); -- Numero inicial
      gl_conteudo := gl_conteudo || lpad(rec.nro_nf, 10, 0); -- Numero final
      gl_conteudo := gl_conteudo || to_char(rec.dt_emiss, 'yyyyMMdd'); -- Data de Emissao
      gl_conteudo := gl_conteudo || to_char(rec.dt_exe_serv, 'yyyyMMdd'); -- Data do Fato Gerador
      --
      vn_fase := 6;
      begin
      --
         select sum(nvl(inf.vl_item_bruto,0))
           into vn_vl_item_bruto
           from item_nota_fiscal inf
          where inf.notafiscal_id = rec.notafiscal_id;
      --
      exception
         when others then
           vn_vl_item_bruto := null; 
      end;
      --
      vn_fase := 7;
      --
      begin
      --
         select sum(nvl(ii.vl_base_calc,0))
           into vn_vl_base_calc
           from item_nota_fiscal inf 
              , imp_itemnf       ii
              , tipo_imposto     ti
          where inf.notafiscal_id = rec.notafiscal_id 
            and ii.itemnf_id      = inf.id 
            and ti.id             = ii.tipoimp_id
            and ti.cd             = 6; -- ISS
      --
      exception
        when others then
          vn_vl_base_calc  := null;
      end;
      --  
      vn_fase := 8;
      --
      begin
      --
         select sum(nvl(ii.vl_imp_trib,0))
           into vn_vl_imp_trib
           from item_nota_fiscal inf 
              , imp_itemnf       ii
              , tipo_imposto     ti
          where inf.notafiscal_id = rec.notafiscal_id 
            and ii.itemnf_id      = inf.id 
            and ti.id             = ii.tipoimp_id
            and ti.cd             = 6; -- ISS
      --
      exception
        when others then  
         vn_vl_imp_trib  := null;
      end;
      --
      vn_fase := 9;
      --
      gl_conteudo := gl_conteudo || lpad(nvl(trim(vn_vl_item_bruto),0)*100,15,0); -- Valor total do documento replace('1,24',',','.')
      gl_conteudo := gl_conteudo || lpad(nvl(trim(vn_vl_base_calc),0)*100,15,0); -- valor base de Calculo
      gl_conteudo := gl_conteudo || lpad(nvl(trim(vn_vl_imp_trib),0)*100,15,0); -- Valor ISS do Serviço
      --
      -- Verificar se existe imposto retido, caso não tenha verificar do tipo imposto.
      --
      begin
      --
         select distinct(ii.dm_tipo)
           into vn_tipo_tributacao
           from item_nota_fiscal inf
              , imp_itemnf       ii
              , tipo_imposto     ti
          where inf.id              = ii.itemnf_id
            and ii.tipoimp_id       = ti.id
            and ti.cd               = 6 -- ISS
            and inf.notafiscal_id   = rec.notafiscal_id;
      --
      exception
         when no_data_found then
         --
            vn_tipo_tributacao := 2;
      end;
      --
      vn_fase := 10;
      --
      begin
      --
         select max(inf.descr_item)
           into vv_descr_item
           from item_nota_fiscal inf 
          where inf.notafiscal_id = rec.notafiscal_id;
      --
      exception
         when others then
            vv_descr_item := null;
      end;
      --
      vn_fase := 11;
      --
      begin
      --
         select count(inf.id)
           into vn_qtd_itens
           from item_nota_fiscal inf
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.cd_lista_serv is not null;
      --
      exception
        when others then
          vn_qtd_itens := null;
      end;
      --
      vn_qtde_linhas := vn_qtde_linhas + 1;
      --
      gl_conteudo := gl_conteudo || lpad(nvl(vn_tipo_tributacao,0),1,0); -- Tipo de Tributação
      gl_conteudo := gl_conteudo || rpad(vv_descr_item, 500, ' '); -- Observaçao
      gl_conteudo := gl_conteudo || lpad(nvl(vn_qtd_itens,0), 3, 0); -- Quantidade de itens de serviços
      gl_conteudo := gl_conteudo || lpad(nvl(vn_qtde_linhas,0),6,0); -- Sequencia de Registro
      --
      -- Armazena a estrutura do arquivo
      --
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
      vn_fase := 12;
      --
      for rec2 in c_inf(rec.notafiscal_id)
      loop 
          --
          --  Detalhe 2 - Itens do Serviço              
          --
          vn_qtde_linhas := vn_qtde_linhas + 1;
          --
          begin
             select sum(ii.vl_imp_trib) vl_imp_trib_sum
                  , ii.aliq_apli
               into vn_vl_imp_trib_sum
                  , vn_aliq_apli
               from item_nota_fiscal inf
                  , imp_itemnf       ii
                  , tipo_imposto     ti
              where inf.notafiscal_id = 69475
                and ii.itemnf_id  = inf.id
                and ti.id         = ii.tipoimp_id
                and ti.cd         = 6 --ISSS
                and inf.cd_lista_serv    is not null
           group by ii.aliq_apli;
          exception
             when no_data_found then
                vn_vl_imp_trib      := null;
          end;
          --
          gl_conteudo := '3'; -- Tipo do Registro
          gl_conteudo := gl_conteudo || lpad(nvl(rec2.cd_lista_serv,0),6,0); -- Código do Serviço
          gl_conteudo := gl_conteudo || lpad(nvl(trim(rec2.vl_item_bruto_sum),0)*100,15,0); -- Valor do Serviço
          gl_conteudo := gl_conteudo || lpad(nvl(trim(vn_vl_imp_trib_sum),0)*100,15,0); -- Valor ISS do Serviço
          gl_conteudo := gl_conteudo || lpad(nvl(trim(vn_aliq_apli),0)*100, 5,0); -- Aliquota Verificar 
          gl_conteudo := gl_conteudo || lpad(' ',683,' '); -- Branco
          gl_conteudo := gl_conteudo || lpad(vn_qtde_linhas,6,0); -- Sequencia de Registros
          --
          -- Armazena a estrutura do arquivo
          --
          pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
          --
          vn_fase := 13;
          --
      end loop;
      --
   end loop;
   --       Trailer
   --
   vn_qtde_linhas := vn_qtde_linhas + 1;
   --
   gl_conteudo := '4';
   gl_conteudo := gl_conteudo || lpad(' ',724,' '); -- Branco
   gl_conteudo := gl_conteudo || lpad(vn_qtde_linhas,6,0);
   --
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_fase := 14;
   --
exception
   when others then
   raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_2905701 fase ('||vn_fase||'): '||sqlerrm);
   --
end pkb_gera_arq_cid_2905701;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Belo Horizonte / MG
procedure pkb_gera_arq_cid_3106200 is
   --
   vn_fase                         number := 0;
   vn_iss_retido                   number := 0; -- Caso existir ISS retido, 1 sim 2 nao
   vn_aliq_apli                    imp_itemnf.aliq_apli%type;
   vv_incr_mun                     juridica.im%type;
   vv_serie                        varchar2(15);
   --
   vv_cpnj                         varchar2(15);
   vv_cpf                          varchar2(11);
   vv_nome                         pessoa.nome%type;
   vn_simp_nacional                valor_tipo_param.cd%type;
   --
   vv_lograd                       pessoa.lograd%type;
   vn_nro                          pessoa.nro%type;
   vv_compl                        pessoa.compl%type;
   vv_bairro                       pessoa.bairro%type;
   vv_ibge_cidade                  cidade.ibge_cidade%type;
   --
   vv_cep                          pessoa.cep%type;
   vv_fone                         pessoa.fone%type;
   vv_email                        pessoa.email%type;
   vn_cod_siscomex                 pais.cod_siscomex%type;
   vn_vl_bruto                     item_nota_fiscal.vl_item_bruto%type;
   --
   vn_vl_bruto_serv                item_nota_fiscal.vl_item_bruto%type;
   vv_ibge_cidade_incid            cidade.ibge_cidade%type;
   vv_ibge_cidade_prest            cidade.ibge_cidade%type;
   vn_cod_siscomex_prest           pais.cod_siscomex%type;
   vv_cod_mod                      mod_fiscal.cod_mod%type;
   --
   vn_aliq_apli_ret                    imp_itemnf.aliq_apli%type; -- aliquota do imposto retido.
   --
   cursor c_nfs is
     select nf.id         notafiscal_id
          , nf.nro_nf
          , nf.serie
          , decode(mf.cod_mod,'99','1','55','14') cod_mod
          , nf.sub_serie
          , nf.dt_sai_ent
          , nf.dt_emiss
          , to_number(to_char(nf.dt_emiss,'yyyy')||nf.nro_nf ) nro_doc
          , nf.pessoa_id
          , ics.pais_id
          , ics.cidade_id
          , ncs.dt_exe_serv
       from nota_fiscal nf
          , mod_fiscal mf
          , empresa e
          , pessoa p
          , nf_compl_serv  ncs
          , item_nota_fiscal inf
          , itemnf_compl_serv ics
      where nf.empresa_id      = gn_empresa_id
        and nf.dm_ind_emit     = gn_dm_ind_emit
        and nf.dm_st_proc      = 4
        and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin
--        and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
--            or
--            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
--             or
--            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
--             or
--            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
        and mf.id              = nf.modfiscal_id
        and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
        and e.id               = nf.empresa_id
        and p.id               = e.pessoa_id
        and p.cidade_id        = gn_cidade_id
        and nf.id              = ncs.notafiscal_id (+)
        and nf.id              = inf.notafiscal_id
        and inf.id             = ics.itemnf_id (+)
        and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
      order by nf.id;
      --
BEGIN
     --
     vn_fase := 1;
     --
     gl_conteudo := 'H';
     gl_conteudo := gl_conteudo ||'|'|| lpad(nvl(pk_csf.fkg_inscr_mun_empresa ( en_empresa_id => gn_empresa_id ), '0'), 11, '0'); -- Inscrição Municipal do Contribuinte
     gl_conteudo := gl_conteudo ||'|'|| lpad(nvl(pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => gn_empresa_id ), '0'), 14, '0'); -- CPF ou CNPJ do Contribuinte
     gl_conteudo := gl_conteudo ||'|'|| 'VERSÃO300';
     --
     -- Armazena a estrutura do arquivo
     --
     pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
     --
     -- Registro Tipo 40 – Declaração de Notas Convencionais Recebidas
     --
     vn_fase := 1.1;
     --
     for rec in c_nfs loop
         exit when c_nfs%notfound or (c_nfs%notfound) is null;
         --
         vn_fase := 2;
         --
         vv_serie := fkg_conversao_serie ( ev_serie => trim(rec.serie) );     
         --
         if trim(rec.serie) not in ('A','B','C','D','E','UN')
          and trim(rec.cod_mod) in ('1') then    -- Quando for nfs-e mod. 99 e serie diferente do teste o validador
                                                 -- não considera outra serie que não seja 0 com modelo 5 convertido. 
            --
            vv_cod_mod := 5;
            vv_serie := '0';
            --
         else
            --
            vv_cod_mod := trim(rec.cod_mod);
            --
         end if;
         --
         vn_fase := 2.1;
         --
         gl_conteudo := 'R'; -- Tipo de Registro
         --
         if nvl(to_char(rec.dt_sai_ent,'yyyy'),0) = 0 then
         gl_conteudo := gl_conteudo ||'|'|| to_char(rec.dt_emiss, 'DDMMRRRR'); -- Data de Emissão da Nota Convencional
         else
         gl_conteudo := gl_conteudo ||'|'|| to_char(rec.dt_sai_ent, 'DDMMRRRR'); -- Data de Emissão da Nota Convencional
         end if;
         --
         gl_conteudo := gl_conteudo ||'|'|| to_char(rec.dt_emiss, 'DDMMRRRR');
         gl_conteudo := gl_conteudo ||'|'|| trim(vv_cod_mod);--nvl(rec.cod_mod, '');
         gl_conteudo := gl_conteudo ||'|'|| nvl(vv_serie,'');
         gl_conteudo := gl_conteudo ||'|'|| nvl(rec.sub_serie,'');
         gl_conteudo := gl_conteudo ||'|'|| '1'; -- Situação Especial de Responsabilidade
         -- gl_conteudo := gl_conteudo ||'|'|| '1'; -- Motivo de não Retenção
         --
         vn_fase  := 2.2;
         --
         begin
         --
            select distinct(inf.cidade_ibge)
              into vv_ibge_cidade_incid
              from item_nota_fiscal inf
             where inf.notafiscal_id = rec.notafiscal_id; 
         --
         exception
          when others then
            vv_ibge_cidade_incid := null;
         end;
         --
         vn_fase := 3;
         --
         begin
         --
         -- Valor bruto do Documento
         --
           select sum(nvl(inf.vl_item_bruto,0))  
             into vn_vl_bruto
             from item_nota_fiscal inf
            where inf.notafiscal_id  = rec.notafiscal_id;
         --
         exception
          when others then
             vn_vl_bruto := 0;
         end;
         --
         vn_fase := 4;
         --
         begin
         --
         -- Valor bruto do Servico
         --
           select sum(nvl(inf.vl_item_bruto,0))
             into vn_vl_bruto_serv
             from item_nota_fiscal inf
            where inf.notafiscal_id = rec.notafiscal_id
              and inf.cd_lista_serv is not null;
         --
         exception
          when others then
             vn_vl_bruto_serv := 0;
         end;
         --
         vn_fase := 5;
         --
         begin
         --
         -- Recuperar Tipo de recolhimento do ISSQN
         --
            select distinct(1)
                 , (ii.aliq_apli)
              into vn_iss_retido
                 , vn_aliq_apli_ret
              from item_nota_fiscal inf
                 , imp_itemnf       ii
                 , tipo_imposto     ti
             where inf.id              = ii.itemnf_id
               and ii.tipoimp_id       = ti.id
               and ii.dm_tipo          = 1 -- Retido
               and ti.cd               = 6 -- ISS
               and inf.notafiscal_id   = rec.notafiscal_id;
          exception
             when others then
                vn_iss_retido := 2; -- Não existe ISS retido. 
         --
         end;
         --
         vn_fase := 6;
         --
         begin
         --
            select distinct(ii.aliq_apli)
              into vn_aliq_apli
              from item_nota_fiscal inf
                 , imp_itemnf       ii
                 , tipo_imposto     ti
             where inf.id              = ii.itemnf_id
               and ii.tipoimp_id       = ti.id
               and ii.dm_tipo          = 0 -- Imposto
               and ti.cd               = 6 -- ISS
               and inf.notafiscal_id   =  rec.notafiscal_id;
         --
         exception
           when others then
              vn_aliq_apli  := null;
         --
         end;
         --
         vn_fase := 6.1;
         --
         begin
         --
            select decode(vtp.cd,0,2,vtp.cd)
              into vn_simp_nacional
              from valor_tipo_param vtp
                 , tipo_param       tp
                 , pessoa_tipo_param ptp
             where ptp.pessoa_id         = rec.pessoa_id
               and vtp.tipoparam_id      = tp.id
               and tp.cd                 = 1
               and ptp.tipoparam_id      = tp.id
               and ptp.valortipoparam_id = vtp.id;
         --
         exception
            when others then
              vn_simp_nacional := '2';
         end;
         --
         vn_fase := 7;
         --
         begin
         --
            select to_char(lpad(j.num_cnpj,8,0)||lpad(j.num_filial,4,0)||lpad(j.dig_cnpj,2,0)) cnpj
                 , to_char(f.num_cpf||f.dig_cpf) cpf
                 , p.nome
                 , p.lograd
                 , p.nro
                 , p.compl
                 , p.bairro
                 , c.ibge_cidade
                 , pa.cod_siscomex
                 , p.cep
                 , p.fone
                 , p.email
              into vv_cpnj
                 , vv_cpf
                 , vv_nome
                 , vv_lograd
                 , vn_nro
                 , vv_compl
                 , vv_bairro
                 , vv_ibge_cidade
                 , vn_cod_siscomex
                 , vv_cep
                 , vv_fone
                 , vv_email
              from pessoa p
                 , pais pa
                 , juridica j
                 , fisica f
                 , cidade c
                 , estado e
             where p.id          = rec.pessoa_id
               and p.cidade_id   = c.id
               and p.id          = j.pessoa_id (+)
               and p.id          = f.pessoa_id (+)
               and p.pais_id     = pa.id
               and c.estado_id   = e.id;
         --
         exception
            when others then
                 vv_cpnj             := null;
                 vv_cpf              := null;
                 vv_nome             := null;
                 vv_lograd           := null;
                 vn_nro              := null;
                 vv_compl            := null;
                 vv_bairro           := null;
                 vv_ibge_cidade      := null;
                 vv_cep              := null;
                 vv_fone             := null;
                 vv_email            := null;
                 vn_cod_siscomex     := null;
         end;
         --
         vn_fase := 8;
         -- Informar inscrição municipal somente para cidade de Belo Horizonte
         if vv_ibge_cidade = gv_ibge_cidade then -- 3106200
            vv_incr_mun := pk_csf.fkg_inscr_mun_pessoa ( en_pessoa_id => rec.pessoa_id );
         else
            vv_incr_mun := null;
         end if;
         --
         vn_fase := 9;
         --
         if nvl(vn_iss_retido,2) = 2 then
            --
            gl_conteudo := gl_conteudo ||'|'|| '1'; -- Motivo de não Retenção
            --
         elsif nvl(vn_iss_retido,2) = 1 then
            --
            gl_conteudo := gl_conteudo ||'|'|| '16'; -- Motivo de não Retenção
            --
         end if;
         --
         gl_conteudo := gl_conteudo ||'|'|| nvl(vv_ibge_cidade_incid,'');
         gl_conteudo := gl_conteudo ||'|'|| nvl(vn_iss_retido,2);
         gl_conteudo := gl_conteudo ||'|'|| to_char(rec.dt_emiss,'YYYY')||rec.nro_nf;
         gl_conteudo := gl_conteudo ||'|'|| trim(to_char(nvl(vn_vl_bruto,0),'9999990.99'));
         gl_conteudo := gl_conteudo ||'|'|| trim(to_char(nvl(vn_vl_bruto_serv,0),'9999990.99'));
         --
         if nvl(vn_iss_retido,2) = 2 then
            --
            gl_conteudo := gl_conteudo ||'|'|| trim(to_char(nvl(vn_aliq_apli,0),'90.99'));
            --
         elsif nvl(vn_iss_retido,2) = 1 then
            --
            gl_conteudo := gl_conteudo ||'|'|| trim(to_char(nvl(vn_aliq_apli_ret,0),'90.99'));
            --
         end if;
         --
         gl_conteudo := gl_conteudo ||'|'|| nvl(vn_simp_nacional,'');
         gl_conteudo := gl_conteudo ||'|'|| nvl(vv_incr_mun,'');
         --
         vn_fase := 10;
         --
         gl_conteudo := gl_conteudo ||'|'|| nvl(vv_cpnj,'');
         gl_conteudo := gl_conteudo ||'|'|| nvl(vv_cpf,'');
         gl_conteudo := gl_conteudo ||'|'|| nvl(vv_nome,'');
         gl_conteudo := gl_conteudo ||'|'|| nvl(vv_lograd,'');
         gl_conteudo := gl_conteudo ||'|'|| nvl(vn_nro,'');
         gl_conteudo := gl_conteudo ||'|'|| nvl(vv_compl,'');
         gl_conteudo := gl_conteudo ||'|'|| nvl(vv_bairro,'');
         gl_conteudo := gl_conteudo ||'|'|| nvl(vv_ibge_cidade,'');
         gl_conteudo := gl_conteudo ||'|'|| nvl(vn_cod_siscomex,'');
         --
         if vn_cod_siscomex = 1058 then -- dentro do país
            gl_conteudo := gl_conteudo ||'|'|| lpad(nvl(vv_cep,''),8,'0');
         else -- fora do país deixar em branco
            gl_conteudo := gl_conteudo ||'|'|| lpad(' ',8,' ');
         end if;
         --
         gl_conteudo := gl_conteudo ||'|'|| nvl(vv_fone,'');
         gl_conteudo := gl_conteudo ||'|'|| nvl(vv_email,'');
         --
         -- Campos não informados
         --
         gl_conteudo := gl_conteudo ||'|'; -- Inscrição Municipal do tomador
         gl_conteudo := gl_conteudo ||'|'; -- CNPJ do tomador
         gl_conteudo := gl_conteudo ||'|'; -- CPF do tomador
         gl_conteudo := gl_conteudo ||'|'; -- Nome do tomador
         gl_conteudo := gl_conteudo ||'|'; -- Logradouro do tomador
         gl_conteudo := gl_conteudo ||'|'; -- Número do imóvel do tomador
         gl_conteudo := gl_conteudo ||'|'; -- Complemento do tomador
         gl_conteudo := gl_conteudo ||'|'; -- Bairro do tomador
         gl_conteudo := gl_conteudo ||'|'; -- Cidade do tomador
         gl_conteudo := gl_conteudo ||'|'; -- País do tomador
         gl_conteudo := gl_conteudo ||'|'; -- CEP do tomador
         gl_conteudo := gl_conteudo ||'|'; -- Telefone do tomador
         gl_conteudo := gl_conteudo ||'|'; -- E-mail do tomador
         --
         vn_fase := 11;
         --
         vv_ibge_cidade_prest  := pk_csf.fkg_ibge_cidade_id ( en_cidade_id => rec.cidade_id);
         vn_cod_siscomex_prest := pk_csf.fkg_cod_siscomex_pais_id ( en_pais_id => rec.pais_id);
         --
         vn_fase := 12;
         gl_conteudo := gl_conteudo ||'|'|| nvl(vv_ibge_cidade_prest,'');
         gl_conteudo := gl_conteudo ||'|'|| nvl(vn_cod_siscomex_prest,'');
         --
         gl_conteudo := gl_conteudo ||'|'; -- Descrição do evento
         gl_conteudo := gl_conteudo ||'|'; -- Data do evento
         --
         pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
         --
     end loop;
         --
EXCEPTION
  when others then
    raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_3106200 fase ('||vn_fase||'): '||sqlerrm);
    --
END pkb_gera_arq_cid_3106200;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Porto Alegre / RS
procedure pkb_gera_arq_cid_4314902 is
   --
   vn_fase          number := 0;
   vv_im            juridica.im%type;
   vn_vl_deducao    number := 0;
   vn_aliq          number := 0;
   vn_vl_imp_trib   number := 0;
   --
   cursor c_nfs is
   select nf.id         notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss) dt_emiss
        , nft.vl_total_nf
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , item_nota_fiscal inf
        , nota_fiscal_total nft
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id
      and nf.id              = inf.notafiscal_id
      and nf.id              = nft.notafiscal_id (+)
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
    order by nf.id;
   --
begin
   --
   vn_fase := 1;
   --
   -- RELAÇÃO DE SERVIÇOS TOMADOS
   --
   vv_im := pk_csf.fkg_inscr_mun_empresa ( en_empresa_id => gn_empresa_id );
   --
   for rec in c_nfs loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      gl_conteudo := lpad(vv_im, 8, '0') || '<'; -- Inscrição municipal
      gl_conteudo := gl_conteudo || to_char(gd_dt_fin, 'rrrrmm') || '<'; -- Competência
      gl_conteudo := gl_conteudo || '12' || '<'; -- Tipo de escrituração
      gl_conteudo := gl_conteudo || lpad('0', 9, '0') || '<'; -- Número seqüencial da obra
      gl_conteudo := gl_conteudo || 'N' || '<'; -- Tipo de lançamento
      gl_conteudo := gl_conteudo || to_char(rec.dt_emiss, 'rrrrmmdd') || '<'; -- Data do documento
      gl_conteudo := gl_conteudo || lpad('0', 8, '0') || '<';  -- Data de pagamento
      gl_conteudo := gl_conteudo || '01' || '<'; -- Tipo (espécie) de documento
      gl_conteudo := gl_conteudo || rpad(rec.serie, 5, ' ') || '<'; -- Série do documento
      gl_conteudo := gl_conteudo || lpad(rec.nro_nf, 6, '0') || '<'; -- Número do documento
      gl_conteudo := gl_conteudo || '01' || '<'; -- Tipo de serviço
      gl_conteudo := gl_conteudo || lpad(nvl(rec.vl_total_nf,0), 14, '0') || '<';  -- Valor total do documento
      --
      begin
         --
         select nvl(sum(ii.vl_imp_trib),0)
           into vn_vl_deducao
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.dm_tipo        = 1 -- Retenção
            and ti.id             = ii.tipoimp_id
            and ti.cd <> '6'; -- ISS
         --
      exception
         when others then
         --
         vn_vl_deducao := 0;
         --
      end;
      --
      gl_conteudo := gl_conteudo || lpad(vn_vl_deducao, 14, '0') || '<'; -- Valor dedutível
      --
      begin
         --
         select nvl(sum(ii.aliq_apli),0)
              , nvl(sum(vl_imp_trib ),0)
           into vn_aliq
              , vn_vl_imp_trib
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.dm_tipo        = 1 -- Retenção
            and ti.id             = ii.tipoimp_id
            and ti.cd = '6'; -- ISS
         --
      exception
         when others then
            vn_aliq := 0;
            vn_vl_imp_trib := 0;
      end;
      --
      gl_conteudo := gl_conteudo || lpad(round(vn_aliq,1), 3, '0') || '<'; -- Alíquota da substituição tributária
      gl_conteudo := gl_conteudo || lpad(vn_vl_imp_trib, 14, '0') || '<'; -- Imposto retido por substituição tributária
      gl_conteudo := gl_conteudo || lpad('0', 14, '0') || '<'; -- Imposto retido por responsabilidade solidária
      gl_conteudo := gl_conteudo || lpad('0', 12, '0') || '<'; -- Inscrição Municipal do substituído/prestador
      gl_conteudo := gl_conteudo || lpad('0', 14, '0') || '<'; -- CNPJ do substituído/prestador
      gl_conteudo := gl_conteudo || 'CC' || '<'; -- Digitar a sigla "CC"
      gl_conteudo := gl_conteudo || lpad('0', 8, '0') || '<'; -- Matricula da obra no caso de construção civil
      gl_conteudo := gl_conteudo || lpad('0', 3, '0') || '<'; -- Percentual de redução de base de calculo
      gl_conteudo := gl_conteudo || lpad('0', 14, '0') || '<'; -- Valor de materiais utilizado pela subempreitada
      gl_conteudo := gl_conteudo || lpad('0', 14, '0') || '<'; -- Valor terceirizado pela subempreitada
      gl_conteudo := gl_conteudo || lpad('0', 14, '0') || '<'; -- Imposto pago pelas terceirizadas
      gl_conteudo := gl_conteudo || lpad('0', 14, '0') || '<'; -- Imposto retido por falta de cadastro no CPOM
      gl_conteudo := gl_conteudo || lpad('0', 3, '0') || '<'; -- Alíquota de imposto retido por falta de cadastramento no CPOM
      --
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_4314902 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_4314902;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Rio de Janeiro / RJ
---------------------------------------------------------------------------------------------------------------------
procedure pkb_gera_arq_cid_3304557 is
  --
  vn_fase                number := 0;
  vn_qtde_linhas         number := 0;
  vn_vl_total_serv       number := 0;
  vn_vl_total_dedu       number := 0;
  vv_cpf_cnpj            varchar2(14);
  vv_nome                pessoa.nome%type;
  vv_lograd              pessoa.lograd%type;
  vv_nro                 pessoa.nro%type;
  vv_compl               pessoa.compl%type;
  vv_bairo               pessoa.bairro%type;
  vn_cep                 pessoa.cep%type;
  vv_fone                pessoa.fone%type;
  vv_email               pessoa.email%type;
  vv_uf                  estado.sigla_estado%type;
  vv_cidade              cidade.descr%type;
  vn_aliq                number := 0;
  vn_vl_imp_trib         number := 0;
  vn_vl_deducao          number := 0;
  vn_vl_imp_iss_ret      number := 0;
  vn_aliq_iss_ret        number := 0;
  vv_cidademodfiscal_cd  cidade_mod_fiscal.cd%type;
  vv_codtribmunicipio_cd cod_trib_municipio.cod_trib_municipio%type;
  vd_dt_vencto_dupl      nfcobr_dup.dt_vencto%type;
  vv_ibge_cidade         cidade.ibge_cidade%type;
  MODULO_SISTEMA         constant number := pk_csf.fkg_ret_id_modulo_sistema('SERVICO_TOMADO');
  GRUPO_SISTEMA          constant number := pk_csf.fkg_ret_id_grupo_sistema(MODULO_SISTEMA, 'SERV_TOM_3304557');
  --
  cursor c_nfs is
    select nf.id notafiscal_id,
           nf.nro_nf,
           nf.serie,
           nf.dt_emiss,
           nf.dt_sai_ent,
           nf.pessoa_id,
           ncs.cidademodfiscal_id,
           ncs.dt_exe_serv,
           ncs.dm_nat_oper,
           inf.vl_item_bruto,
           inf.cd_lista_serv,
           inf.descr_item,
           ics.codtribmunicipio_id,
           ics.cidadebeneficfiscal_id
      from nota_fiscal       nf,
           mod_fiscal        mf,
           empresa           e,
           pessoa            p,
           nf_compl_serv     ncs,
           item_nota_fiscal  inf,
           itemnf_compl_serv ics
     where nf.empresa_id  = gn_empresa_id
       and nf.dm_ind_emit = gn_dm_ind_emit
       and nf.dm_st_proc  = 4
       and ((nf.dm_ind_emit = 1 and nvl(gv_vlr_param, 'DT_ENTRADA') = 'DT_ENTRADA' and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 1 and nvl(gv_vlr_param, 'DT_ENTRADA') = 'DT_VENC_FATURA' and trunc(nvl(fkg_dt_vencto_nf(nf.id), trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)))) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
       and mf.id          = nf.modfiscal_id
       and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
       and e.id           = nf.empresa_id
       and p.id           = e.pessoa_id
       and p.cidade_id    = gn_cidade_id
       and nf.id          = ncs.notafiscal_id(+)
       and nf.id          = inf.notafiscal_id
       and inf.id         = ics.itemnf_id(+)
       and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
     order by nf.id;
  --
begin
  --
  vn_fase := 1;
  --
  -- Registro Tipo 10 - Cabeçalho
  gl_conteudo := '10'; -- Tipo de registro
  gl_conteudo := gl_conteudo || '003'; -- Versão do Arquivo
  gl_conteudo := gl_conteudo || '2'; -- CNPJ
  gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_cnpj_ou_cpf_empresa(en_empresa_id => gn_empresa_id), '0'), 14, '0'); -- CPF ou CNPJ do Contribuinte
  gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_inscr_mun_empresa(en_empresa_id => gn_empresa_id), '0'), 15, '0'); -- Inscrição Municipal do Contribuinte
  gl_conteudo := gl_conteudo || to_char(gd_dt_ini, 'RRRRMMDD'); -- Data inicial
  gl_conteudo := gl_conteudo || to_char(gd_dt_fin, 'RRRRMMDD'); -- Data final
  --
  vn_fase := 1.1;
  --
  vn_qtde_linhas := 0;
  --
  -- Armazena a estrutura do arquivo
  pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
  --
  vn_fase := 2;
  --
  -- Recupera o parâmetro do FATO GERADOR para ser usado como parâmetro no cursor c_nfs
  begin
    --
    vn_fase := 2.1;
    --
    gv_erro := '';
    --
    if not pk_csf.fkg_ret_vl_param_geral_sistema(en_multorg_id => pk_csf.fkg_multorg_id_empresa(en_empresa_id => gn_empresa_id),
                                                 en_empresa_id => gn_empresa_id,
                                                 en_modulo_id  => MODULO_SISTEMA,
                                                 en_grupo_id   => GRUPO_SISTEMA,
                                                 ev_param_name => 'FATO_GERADOR',
                                                 sv_vlr_param  => gv_vlr_param,
                                                 sv_erro       => gv_erro) then
      --
      gv_vlr_param := null;
      --
    end if;
    --
  exception
    when others then
      gv_vlr_param := null;
  end;
  --
  for rec in c_nfs loop
    exit when c_nfs%notfound or(c_nfs%notfound) is null;
    --
    vn_fase := 2.2;
    --
    -- Recupera os dados do Participante
    begin
      select p.nome,
             p.lograd,
             p.nro,
             p.compl,
             p.bairro,
             p.cep,
             p.fone,
             p.email_forn,
             c.descr,
             e.sigla_estado,
             c.ibge_cidade
        into vv_nome,
             vv_lograd,
             vv_nro,
             vv_compl,
             vv_bairo,
             vn_cep,
             vv_fone,
             vv_email,
             vv_cidade,
             vv_uf,
             vv_ibge_cidade
        from pessoa p, 
             cidade c, 
             estado e
       where p.id = rec.pessoa_id
         and c.id = p.cidade_id
         and e.id = c.estado_id;
    exception
      when others then
        vv_nome        := null;
        vv_uf          := null;
        vv_cidade      := null;
        vv_ibge_cidade := null;
    end;
    --
    vn_fase := 2.3;
    --
    -- Informar notas fiscais que não sejam do munícipio do Rio de Janeiro  
    if nvl(vv_ibge_cidade, '3304557') <> '3304557' then
      --
      vn_fase := 2.4;
      --
      -- Registro Tipo 40 - Declaração de Notas Convencionais Recebidas
      gl_conteudo := '40'; -- Tipo de registro
      --
      vv_cidademodfiscal_cd := pk_csf_nfs.fkg_cidademodfiscal_cd(en_cidademodfiscal_id => rec.cidademodfiscal_id);
      --
      if trim(vv_cidademodfiscal_cd) is null then
        vv_cidademodfiscal_cd := '01'; -- Se não informado na NFSe, atribui 01-Nota Fiscal de Serviço
      else
        vv_cidademodfiscal_cd := lpad(vv_cidademodfiscal_cd, 2, '0');
      end if;
      --
      gl_conteudo := gl_conteudo || vv_cidademodfiscal_cd; -- Tipo da Nota Convencional
      gl_conteudo := gl_conteudo || rpad(rec.serie, 5, ' '); -- Série da Nota Convencional
      gl_conteudo := gl_conteudo || lpad(rec.nro_nf, 15, '0'); -- Número da Nota Convencional
      gl_conteudo := gl_conteudo || to_char(rec.dt_emiss, 'RRRRMMDD'); -- Data de Emissão da Nota Convencional
      gl_conteudo := gl_conteudo || '1'; -- Status da Nota Convencional - Normal
      --
      vn_fase := 2.5;
      --
      vv_cpf_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => rec.pessoa_id);
      --
      vn_fase := 2.6;
      --
      if length(vv_cpf_cnpj) = 11 then
        gl_conteudo := gl_conteudo || '1'; -- (1) CPF
      elsif length(vv_cpf_cnpj) = 14 then
        gl_conteudo := gl_conteudo || '2'; -- (2) CNPJ
      else
        gl_conteudo := gl_conteudo || '3'; -- (3) Não informado
      end if;
      --
      vn_fase := 2.7;
      --
      gl_conteudo := gl_conteudo || lpad(nvl(vv_cpf_cnpj, '0'), 14, '0'); -- CPF ou CNPJ do Prestador
      --gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_inscr_mun_pessoa ( en_pessoa_id => rec.pessoa_id ), '0'), 15, '0'); -- Inscrição Municipal do Prestador
      --
      if vv_ibge_cidade = '3304557' then
        gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_inscr_mun_pessoa(en_pessoa_id => rec.pessoa_id), '0'), 15, '0'); -- Inscrição Municipal do Prestador
      else
        gl_conteudo := gl_conteudo || lpad('0', 15, '0');
      end if;
      --
      gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_ie_pessoa_id(en_pessoa_id => rec.pessoa_id), '0'), 15, '0'); -- Inscrição Estadual do Prestador
      gl_conteudo := gl_conteudo || rpad(nvl(vv_nome, ' '), 115); -- Nome ou Razão Social do Prestador
      gl_conteudo := gl_conteudo || 'Rua'; -- Tipo do Endereço do Prestador (Rua, Av, ...)
      gl_conteudo := gl_conteudo || rpad(nvl(vv_lograd, ' '), 125); -- Endereço do Prestador
      gl_conteudo := gl_conteudo || rpad(nvl(substr(vv_nro, 1, 10), ' '), 10); -- Número do endereço do Prestador
      gl_conteudo := gl_conteudo || rpad(nvl(vv_compl, ' '), 60); -- Complemento do Endereço do Prestador
      gl_conteudo := gl_conteudo || rpad(nvl(vv_bairo, ' '), 72); -- Bairro do Prestador
      gl_conteudo := gl_conteudo || rpad(nvl(vv_cidade, ' '), 50); -- Cidade do Prestador
      gl_conteudo := gl_conteudo || rpad(nvl(vv_uf, ' '), 2); -- UF do Prestador
      gl_conteudo := gl_conteudo || lpad(nvl(vn_cep, '0'), 8, '0'); -- CEP do Prestador
      gl_conteudo := gl_conteudo || rpad(nvl(substr(vv_fone, 1, 11), ' '), 11); -- Telefone de contato do Prestador
      gl_conteudo := gl_conteudo || rpad(nvl(substr(vv_email, 1, 80), ' '), 80); -- Email do Prestador
      --
      vn_fase := 2.8;
      --
      -- Tipo de Tributação de Serviços (DM_NAT_OPER)
      if rec.dm_nat_oper is null then
        gl_conteudo := gl_conteudo || '01'; -- Não Existindo, atribui 01 - Tributação no Município;
      elsif rec.dm_nat_oper in (1, 7) then
        gl_conteudo := gl_conteudo || '01';
      else
        gl_conteudo := gl_conteudo || lpad(rec.dm_nat_oper, 2, '0');
      end if;
      --
      gl_conteudo := gl_conteudo || rpad(' ', 54); -- Reservado
      gl_conteudo := gl_conteudo || nvl(pk_csf.fkg_pessoa_valortipoparam_cd('1',
                                                                            rec.pessoa_id), '0'); -- Opção Pelo Simples (0) Não (1) Sim
      gl_conteudo := gl_conteudo || rpad(nvl(replace(rec.cd_lista_serv, '.', ''), ' '), 4); -- Código do Serviço Federal
      gl_conteudo := gl_conteudo || rpad(' ', 11); -- Reservado
      gl_conteudo := gl_conteudo || lpad(nvl(pk_csf_nfs.fkg_cidadebeficfiscal_cd(en_cidadebeficfiscal_id => rec.cidadebeneficfiscal_id), '0'), 3, '0'); -- Código do Benefício
      --
      vn_fase := 2.9;
      --
      vv_codtribmunicipio_cd := trim(pk_csf.fkg_codtribmunicipio_cd(en_codtribmunicipio_id => rec.codtribmunicipio_id));
      --
      if trim(vv_codtribmunicipio_cd) is null then
        vv_codtribmunicipio_cd := '0';
      end if;
      --
      gl_conteudo := gl_conteudo || rpad(nvl(vv_codtribmunicipio_cd, '0'), 6); -- Código do Serviço Municipal
      --
      vn_fase := 2.10;
      --
      begin
        select nvl(sum(ii.aliq_apli), 0), 
               nvl(sum(ii.vl_imp_trib), 0)
          into vn_aliq, 
               vn_vl_imp_trib
          from item_nota_fiscal inf, 
               imp_itemnf ii, 
               tipo_imposto ti
         where inf.notafiscal_id = rec.notafiscal_id
           and inf.id            = ii.itemnf_id
           and ii.dm_tipo        = 0 -- Imposto
           and ti.id             = ii.tipoimp_id
           and ti.cd             = '6'; -- ISS
      exception
        when others then
          vn_aliq        := 0;
          vn_vl_imp_trib := 0;
      end;
      --
      vn_fase := 2.11;
      --
      begin
        select nvl(sum(ii.vl_imp_trib), 0), 
               nvl(sum(ii.aliq_apli), 0)
          into vn_vl_imp_iss_ret, 
               vn_aliq_iss_ret
          from item_nota_fiscal inf, 
               imp_itemnf ii, 
               tipo_imposto ti
         where inf.notafiscal_id = rec.notafiscal_id
           and inf.id            = ii.itemnf_id
           and ii.dm_tipo        = 1 -- Retenção
           and ti.id             = ii.tipoimp_id
           and ti.cd             = '6'; -- ISS
      exception
        when others then
          vn_vl_imp_iss_ret := 0;
          vn_aliq_iss_ret   := 0;
      end;
      --
      vn_fase := 2.12;
      --
      if nvl(vn_aliq_iss_ret, 0) > 0 then
        gl_conteudo := gl_conteudo || lpad((nvl(vn_aliq_iss_ret, 0) * 100), 5, '0'); -- Alíquota
      else
        gl_conteudo := gl_conteudo || lpad((nvl(vn_aliq, 0) * 100), 5, '0'); -- Alíquota
      end if;
      --
      gl_conteudo := gl_conteudo || lpad((nvl(rec.vl_item_bruto, 0) * 100), 15, '0'); -- Valor dos Serviços
      --
      vn_vl_total_serv := nvl(vn_vl_total_serv, 0) + nvl(rec.vl_item_bruto, 0);
      --
      vn_fase := 2.13;
      --
      gl_conteudo := gl_conteudo || lpad((nvl(0, 0) * 100), 15, '0'); -- Valor das Deduções
      --
      vn_fase := 2.14;
      --
      vn_vl_total_dedu := nvl(vn_vl_total_dedu, 0) + nvl( /*vn_vl_deducao*/ 0, 0);
      --
      vn_fase := 2.15;
      --
      gl_conteudo := gl_conteudo || rpad(' ', 30); -- Reservado
      --gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_imp_trib, 0) * 100), 15, '0'); -- Valor do ISS
      --
      vn_fase := 2.16;
      --
      -- ISS Retido
      -- Data de Competência (Utilize a data de emissão da NFS em caso de ISS não retido e a data para pagamento em caso de ISS retido)
      if nvl(vn_vl_imp_iss_ret, 0) > 0 then
        --
        -- Se houver linha de imposto do Tipo ISS e o mesmo for do tipo "1-Retenção", mandar a DT_VENCTO da tabela NFCOBR_DUP
        vn_fase := 2.17;
        --
        vd_dt_vencto_dupl := null;
        --
        begin
          select max(nfd.dt_vencto)
            into vd_dt_vencto_dupl
            from nota_fiscal_cobr nfc, 
                 nfcobr_dup nfd
           where nfc.notafiscal_id = rec.notafiscal_id
             and nfc.id            = nfd.nfcobr_id;
        exception
          when no_data_found then
            vd_dt_vencto_dupl := null;
        end;
        --
        vn_fase := 2.18;
        --
        gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_imp_iss_ret, 0) * 100), 15, '0'); -- Valor do ISS
        gl_conteudo := gl_conteudo || '1'; -- Retencao
        gl_conteudo := gl_conteudo || to_char(vd_dt_vencto_dupl, 'RRRRMMDD');
        --
      else
        --
        -- Se houver linha de imposto do Tipo ISS e o mesmo for do tipo "0-Imposto", mandar a DT_EMISS do documento fiscal
        vn_fase := 2.19;
        --
        gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_imp_trib, 0) * 100), 15, '0'); -- Valor do ISS
        gl_conteudo := gl_conteudo || '0'; -- Imposto Normal
        gl_conteudo := gl_conteudo || to_char(rec.dt_emiss, 'RRRRMMDD');
        --
      end if;
      --
      vn_fase := 2.20;
      --
      gl_conteudo := gl_conteudo || rpad(' ', 15); -- Código da Obra
      gl_conteudo := gl_conteudo || rpad(' ', 15); -- Anotação de Responsabilidade Técnica
      gl_conteudo := gl_conteudo || rec.descr_item; -- Discriminação dos Serviços
      --
      vn_fase := 2.21;
      --
      vn_qtde_linhas := vn_qtde_linhas + 1;
      --
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
      --
    end if; -- nota fiscal do munícipio do Rio de Janeiro não deve ser informada
  --
  end loop;
  --
  vn_fase := 3;
  --
  -- Registro Tipo 90 - Rodapé
  gl_conteudo := '90'; --  Tipo de registro
  gl_conteudo := gl_conteudo || lpad(vn_qtde_linhas, 8, '0'); -- Número de linhas de detalhe do arquivo
  gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_total_serv, 0) * 100), 15, '0'); -- Valor total dos serviços contido no arquivo
  gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_total_dedu, 0) * 100), 15, '0'); -- Valor total das deduções  contidas no arquivo
  gl_conteudo := gl_conteudo || lpad('0', 15, '0'); -- Valor total dos descontos condicionados contidos no arquivo
  gl_conteudo := gl_conteudo || lpad('0', 15, '0'); -- Valor total dos descontos incondicionadocontidos no arquivo
  --
  vn_fase := 4;
  --
  -- Armazena a estrutura do arquivo
  pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
  --
exception
  when others then
    raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_3304557 fase (' || vn_fase || '): ' || sqlerrm);
end pkb_gera_arq_cid_3304557;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Itapevi / SP
procedure pkb_gera_arq_cid_3522505 is
   --
   vn_fase          number := 0;
   vv_nome          pessoa.nome%type;
   vv_cpf_cnpj      varchar2(14);
   vv_uf            estado.sigla_estado%type;
   vv_cidade        cidade.descr%type;
   vn_vl_deducao    number := 0;
   vn_aliq          number := 0;
   vn_vl_imp_trib   number := 0;
   vn_total_reg_1   number := 0;
   vn_total_serv    number := 0;
   vn_total_dedu    number := 0;
   vn_total_imp     number := 0;
   --
   cursor c_nfs is
   select nf.id         notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss) dt_emiss
        , nf.pessoa_id
        , inf.vl_item_bruto
        , inf.cd_lista_serv
        , ics.codtribmunicipio_id
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , item_nota_fiscal inf
        , itemnf_compl_serv ics
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id
      and inf.notafiscal_id  = nf.id
      and inf.id             = ics.itemnf_id (+)
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
    order by nf.id;
   --
begin
   --
   vn_fase := 1;
   --
   -- Registro HEADER (0)
   --
   gl_conteudo := '0';
   gl_conteudo := gl_conteudo || 'T'; -- (T) Tomador (P) Prestador
   gl_conteudo := gl_conteudo || '1'; -- (1) CNPJ (2) CPF
   gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => gn_empresa_id ),'0'), 14, '0'); -- Identificação da empresa
   gl_conteudo := gl_conteudo || to_char(gd_dt_fin,'MM'); -- Mês da declaração
   gl_conteudo := gl_conteudo || to_char(gd_dt_fin,'RRRR'); -- Ano da declaração
   gl_conteudo := gl_conteudo || to_char(sysdate,'DDMMRRRR'); -- Data do lançamento
   gl_conteudo := gl_conteudo || 'N'; -- (N) Normal (C) Complementar
   gl_conteudo := gl_conteudo || '02'; -- Versão do Layout utilizado
   gl_conteudo := gl_conteudo || lpad(' ', 66); -- Livre para futuras informações
   --
   vn_fase := 1.1;
   --
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_fase := 2;
   --
   -- Registro de Detalhe da Nota Fiscal
   --
   for rec in c_nfs loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_fase := 2.1;
      --
      gl_conteudo := '1';
      --
      -- Recupera os dados do Participante
      --
      begin
         --
         select p.nome
              , e.sigla_estado
              , c.descr
           into vv_nome
              , vv_uf
              , vv_cidade
           from pessoa p
              , cidade c
              , estado e
          where p.id = rec.pessoa_id
            and p.cidade_id = c.id
            and c.estado_id = e.id;
         --
      exception
         when others then
         --
         vv_nome            := null;
         vv_uf              := null;
         vv_cidade          := null;
         --
      end;
      --
      vn_fase := 2.2;
      --
      vv_cpf_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec.pessoa_id );
      --
      vn_fase := 2.3;
      --
      if length(vv_cpf_cnpj) = 14 then
          gl_conteudo := gl_conteudo || '1'; -- (1) CNPJ
      else
          gl_conteudo := gl_conteudo || '2'; -- (2) CPF
      end if;
      --
      gl_conteudo := gl_conteudo || lpad(nvl(vv_cpf_cnpj,'0'), 14, '0'); -- Identificação da Empresa (Participante)
      gl_conteudo := gl_conteudo || rpad(nvl(vv_nome,' '), 100); -- Nome da Empresa (Participante)
      gl_conteudo := gl_conteudo || rpad(nvl(substr(vv_cidade,1,60),' '), 60); -- Cidade da Empresa (Participante)
      gl_conteudo := gl_conteudo || rpad(nvl(vv_uf,' '), 2); -- Estado da Empresa (Participante)
      gl_conteudo := gl_conteudo || lpad(nvl(to_char(rec.nro_nf),'0'), 8, '0'); -- Número da Nota Fiscal
      gl_conteudo := gl_conteudo || to_char(rec.dt_emiss,'DDMMRRRR'); -- Data Emissão da Nota Fiscal
      gl_conteudo := gl_conteudo || lpad((nvl(rec.vl_item_bruto,0)*100),14,0); -- Valor dos Serviços Prestados
      --
      vn_total_serv := nvl(vn_total_serv,0) + rec.vl_item_bruto; -- Calcula a quantidade total do valor dos serviços
      --
      vn_fase := 2.4;
      --
      begin
         --
         select nvl(sum(ii.vl_imp_trib),0)
           into vn_vl_deducao
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.dm_tipo        = 1 -- Retenção
            and ti.id             = ii.tipoimp_id
            and ti.cd <> '6'; -- ISS
         --
      exception
         when others then
         --
         vn_vl_deducao := 0;
         --
      end;
      --
      vn_fase := 2.5;
      --
      gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_deducao,0)*100),14,0); -- Valor das Deduções
      --
      vn_total_dedu := nvl(vn_total_dedu,0) + vn_vl_deducao; -- Calcula a quantidade total do valor das deduções
      --
      begin
         --
         select nvl(sum(ii.aliq_apli),0)
              , nvl(sum(ii.vl_imp_trib),0)
           into vn_aliq
              , vn_vl_imp_trib
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.dm_tipo        = 1 -- Retenção
            and ti.id             = ii.tipoimp_id
            and ti.cd = '6'; -- ISS
         --
      exception
         when others then
         --
         vn_aliq := 0;
         vn_vl_imp_trib := 0;
         --
      end;
      --
      vn_fase := 2.6;
      --
      gl_conteudo := gl_conteudo || lpad((nvl(vn_aliq,0)*100),5,0); -- Alíquota para cálculo do imposto
      gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_imp_trib,0)*100),14,0); -- Valor do Imposto Calculado
      --
      vn_total_imp := nvl(vn_total_imp,0) + vn_vl_imp_trib; -- Calcula a quantidade total do valor do Imposto calculado
      --
      if nvl(vn_vl_imp_trib,0) > 0 then
         gl_conteudo := gl_conteudo || 'S'; -- (S) Imposto Retido
      else
         gl_conteudo := gl_conteudo || 'N'; -- (N) Imposto Não Retido
      end if;
      --
      vn_fase := 2.7;
      --
      gl_conteudo := gl_conteudo || '1'; -- Situação da Nota Fiscal: (1) Normal (2) Cancelada
      gl_conteudo := gl_conteudo || lpad(nvl(to_char(rec.cd_lista_serv),'0'), 6, '0');
      gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_codtribmunicipio_cd ( en_codtribmunicipio_id => rec.codtribmunicipio_id ),'0'), 3, '0');
      gl_conteudo := gl_conteudo || lpad(nvl(rec.serie,'0'),2,'0');
      gl_conteudo := gl_conteudo || lpad(' ',96);
      --
      vn_fase := 2.8;
      --
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
      vn_total_reg_1 := nvl(vn_total_reg_1,0) + 1; -- Calcula a quantidade de registros do tipo 1 - Detalhe da Nota Fiscal.
      --
   end loop;
   --
   vn_fase :=  3;
   --
   -- Registro Trailer
   --
   gl_conteudo := '9';
   gl_conteudo := gl_conteudo || lpad(nvl(to_char(vn_total_reg_1),'0'), 4, '0');
   gl_conteudo := gl_conteudo || lpad((nvl(vn_total_serv,0)*100),14,0);
   gl_conteudo := gl_conteudo || lpad((nvl(vn_total_dedu,0)*100),14,0);
   gl_conteudo := gl_conteudo || lpad((nvl(vn_total_imp,0)*100),14,0);
   gl_conteudo := gl_conteudo || lpad(' ',53);
   --
   vn_fase :=  3.1;
   --
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_3522505 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_3522505;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Barueri / SP
procedure pkb_gera_arq_cid_3505708 is
   --
   vn_fase                     number := 0;
   vv_nome                     pessoa.nome%type;
   vv_cpf_cnpj                 varchar2(14);
   vv_uf                       estado.sigla_estado%type;
   vv_cidade                   cidade.descr%type;
   vv_estrangeiro              varchar2(1); -- 1 - Sim; 2 - Não.
   vn_qtde_linhas              number := 0;
   vn_vl_total_serv            number := 0;
   vn_vl_total_serv_nao_trib   number := 0;
   --
   cursor c_nfs is
   select nf.id         notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss) dt_emiss
        , nf.pessoa_id
        , case
             when mf.cod_mod = '99' then 
                '002' 
             else 
                '005'
          end cod_mod
        , inf.cd_lista_serv
        , nft.vl_total_nf
        , nft.vl_serv_nao_trib
        , nft.vl_ret_iss
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , item_nota_fiscal inf
        , nota_fiscal_total nft
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id
      and inf.notafiscal_id  = nf.id
      and nft.notafiscal_id  = nf.id
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
    order by nf.id;
   --
begin
   --
   vn_fase := 1;
   --
   -- Cabeçalho - Registro Tipo 0 - Segmento 00 - Identificação do Contribuinte, da Competência e do Arquivo
   --
   gl_conteudo := '000'; -- Tipo do registro
   gl_conteudo := gl_conteudo || rpad(nvl(pk_csf.fkg_inscr_mun_empresa ( en_empresa_id => gn_empresa_id ), ' '), 7); -- Inscrição do Contribuinte
   gl_conteudo := gl_conteudo || to_char(gd_dt_fin,'RRRR'); -- Ano competência
   gl_conteudo := gl_conteudo || to_char(gd_dt_fin,'MM'); -- Mes competência
   gl_conteudo := gl_conteudo || to_char(sysdate,'RR') || to_char(sysdate,'MM') || to_char(sysdate,'DD') || to_char(sysdate,'HH24SS') || 'X'; -- Identificação da remessa do contribuinte
   gl_conteudo := gl_conteudo || 'V100';
   --
   vn_fase := 1.1;
   --
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_qtde_linhas := 1;
   --
   vn_fase := 2;
   --
   -- Detalhe - Registro Tipo 2 - Segmento 01 - Informações de Serviços Tomados
   --
   --
   for rec in c_nfs loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_fase := 2.1;
      --
      gl_conteudo := '201'; -- Tipo de registro
      gl_conteudo := gl_conteudo || '1'; -- Tipo de Operação
      gl_conteudo := gl_conteudo || rec.cod_mod; -- Código do Tipo de Documento
      gl_conteudo := gl_conteudo || rpad(nvl(rec.serie,' '), 10); -- Série do Documento
      gl_conteudo := gl_conteudo || rpad(nvl(to_char(rec.nro_nf),' '), 9); -- Número do Documento
      gl_conteudo := gl_conteudo || to_char(rec.dt_emiss,'DD'); -- Dia da Emissão Documento
      gl_conteudo := gl_conteudo || '0'; -- Reservado
      --
      vn_fase := 2.2;
      --
      -- Recupera dados do prestador de serviço
      --
      begin
         --
         select p.nome
              , e.sigla_estado
              , c.descr
           into vv_nome
              , vv_uf
              , vv_cidade
           from pessoa p
              , cidade c
              , estado e
          where p.id = rec.pessoa_id
            and p.cidade_id = c.id
            and c.estado_id = e.id;
         --
      exception
         when others then
         --
         vv_nome            := null;
         vv_uf              := null;
         vv_cidade          := null;
         --
      end;
      --
      vv_cpf_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec.pessoa_id );
      --
      vn_fase := 2.3;
      --
      if vv_uf = 'EX' then
         vv_estrangeiro := '1'; -- Prestador do Serviço Estrangeiro
      else
         vv_estrangeiro := '2'; -- Não é Prestador do Serviço Estrangeiro
      end if;
      --
      gl_conteudo := gl_conteudo || vv_estrangeiro;
      --
      vn_fase := 2.4;
      --
      if length(vv_cpf_cnpj) = 11 then
         --
         gl_conteudo := gl_conteudo || '1'; -- Indica que é CPF
         --
      elsif length(vv_cpf_cnpj) = 14 then
         --
         gl_conteudo := gl_conteudo || '2'; -- Indica que é CNPJ
         --
      else
         --
         gl_conteudo := gl_conteudo || ' '; -- Indica que é Estrangeiro
         --
      end if;
      --
      vn_fase := 2.5;
      --
      gl_conteudo := gl_conteudo || rpad(nvl(vv_cpf_cnpj,' '), 14); -- CPF/CNPJ Prestador do Serviço
      gl_conteudo := gl_conteudo || rpad(nvl(vv_nome,' '), 100); -- Razão Social/Nome Prestador
      gl_conteudo := gl_conteudo || rpad(nvl(vv_uf,' '), 2); -- UF Logradouro Prestador
      gl_conteudo := gl_conteudo || rpad(nvl(substr(vv_cidade,1,40),' '), 40); -- Cidade Logradouro Prestador
      gl_conteudo := gl_conteudo || rpad(nvl(to_char(rec.cd_lista_serv),' '), 9); -- Código do Serviço Tomado
      gl_conteudo := gl_conteudo || vv_estrangeiro; -- Importação 1 - Sim; 2 - Não.
      gl_conteudo := gl_conteudo || lpad((nvl(rec.vl_total_nf,0)*100),15,0); -- Valor do Documento (Serviço)
      gl_conteudo := gl_conteudo || lpad((nvl(rec.vl_serv_nao_trib,0)*100),15,0); -- Valor Não Incluso na Base de Cálculo
      --
      vn_vl_total_serv := nvl(vn_vl_total_serv,0) + nvl(rec.vl_total_nf,0);
      vn_vl_total_serv_nao_trib := nvl(vn_vl_total_serv_nao_trib,0) + nvl(rec.vl_serv_nao_trib,0);
      --
      vn_fase := 2.6;
      --
      if nvl(rec.vl_ret_iss,0) > 0 then
         gl_conteudo := gl_conteudo || '1'; -- Imposto Retido
      else
         gl_conteudo := gl_conteudo || '2'; -- Não tem Imposto Retido
      end if;
      --
      vn_fase := 2.7;
      --
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
      vn_qtde_linhas := vn_qtde_linhas + 1;
      --
   end loop;
   --
   vn_fase := 3;
   --
   -- Rodapé - Registro Tipo 2 - Segmento 99 - Totalização Declaração de Serviços Tomados
   --
   gl_conteudo := '299'; -- Tipo do Registro
   gl_conteudo := gl_conteudo || lpad('0',15,0); -- Valor Total dos Serviços Tomados contido nos Registros Tipo 2 - Segmento 03 (Não implementado).
   gl_conteudo := gl_conteudo || lpad('0',15,0); -- Total dos Valores Não Incluso na Base de Cálculo contido nos Registros Tipo 2 - Segmento 03 (Não implementado).
   --
   vn_fase := 3.1;
   --
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_qtde_linhas := vn_qtde_linhas + 1;
   --
   vn_fase := 4;
   --
   -- Rodapé - Registro Tipo 9 - Segmento 00 - Encerramento do Arquivo
   --
   vn_qtde_linhas := vn_qtde_linhas + 1;
   --
   gl_conteudo := '900'; -- Tipo do Registro
   gl_conteudo := gl_conteudo || rpad(vn_qtde_linhas, 7); -- Número Total de Linhas do Arquivo
   gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_total_serv,0)*100),15,0); -- Valor Total dos Serviços contidos no Arquivo
   gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_total_serv_nao_trib,0)*100),15,0); -- Valor Total dos Valores Não Incluso na Base de Cálculo contidos no Arquivo
   --
   vn_fase := 4.1;
   --
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_3505708 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_3505708;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Curitiba / PR
procedure pkb_gera_arq_cid_4106902 is
  --
  vn_fase            number := 0;
  --
  vn_aliq_iss        imp_itemnf.aliq_apli%type := null;
  vn_cont_geral      number := 0;
  vn_cont_reg_c      number := 0;
  vn_cont_reg_e      number := 0; 
  vn_cont_reg_r      number := 0;
  vv_ibge_cidade     cidade.ibge_cidade%type;
  vv_exibe_im        varchar2(10);
  --
  vn_dt_canc         nota_fiscal_canc.dt_canc%type := null;
  vn_im              juridica.im%type := null;
  vn_lograd          pessoa.lograd%type := null;
  vn_nro             pessoa.nro%type := null;
  vn_compl           pessoa.compl%type := null;
  vn_bairro          pessoa.bairro%type := null;
  vn_cep             pessoa.cep%type := null;
  vv_cidade          cidade.descr%type := null;
  vn_uf              estado.sigla_estado%type := null;
  vn_vl_total_item_e nota_fiscal_total.vl_total_item%type := null;
  vn_vl_desconto_e   nota_fiscal_total.vl_desconto%type := null;
  vn_vl_total_item_r nota_fiscal_total.vl_total_item%type := null;
  vn_vl_desconto_r   nota_fiscal_total.vl_desconto%type := null;
  vv_cpf_cnpj        varchar2(14);
  --
  cursor c_nf is
    select nf.id notafiscal_id,
           nf.empresa_id,
           nf.dm_ind_emit,
           nf.nro_nf,
           nvl(nf.dt_sai_ent, nf.dt_emiss) dt_comp,
           nf.pessoa_id pessoa_id_nf,
           nf.dt_emiss,
           nf.dt_sai_ent,
           nft.vl_total_item,
           nft.vl_total_nf,
           nf.dm_st_proc,
           nf.dm_ind_oper,
           nf.serie,
           nf.sub_serie,
           nft.vl_desconto,
           nf.dm_tp_amb,
           nf.dt_st_proc,
           e.pessoa_id pessoa_id_emp,
           cm.cd cid_cd
      from nota_fiscal       nf,
           mod_fiscal        mf,
           empresa           e,
           pessoa            p,
           nota_fiscal_total nft,
           nf_compl_serv     nc,
           cidade_mod_fiscal cm
     where nf.empresa_id     = gn_empresa_id
       and nf.dm_ind_emit    = decode(nvl(gn_dm_ind_emit, 0), 0, 0, 1, 1, nf.dm_ind_emit)
       and nf.dm_st_proc     in (4, 7)
       and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_emiss, nf.dt_sai_ent)) between gd_dt_ini and gd_dt_fin)
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
       and mf.id             = nf.modfiscal_id
       and mf.cod_mod        = '99' -- Serviços
       and e.id              = nf.empresa_id
       and p.id              = e.pessoa_id
       and p.cidade_id       = gn_cidade_id
       and nft.notafiscal_id = nf.id
       and nf.id             = nc.notafiscal_id
	   --and (cm.cd = 3 or cm.cd is null) -- adicinada condição para retorna quando o cm.cd for igual ao 3 ou nulo
	   -- Retirado a condição acima pois não estavam saindo notas de serviços tipo 1 - Nota Fiscal e o tratamento de 
	   -- RPA deve ser no momento de gerar o arquivo.
       and cm.id(+)          = nc.cidademodfiscal_id
       and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
     order by nf.id;
  --
  cursor c_inf(en_notafiscal_id nota_fiscal.id%type) is
    select inf.id itemnf_id,
           inf.item_id,
           inf.vl_item_bruto,
           inf.vl_desc,
           inf.cd_lista_serv
      from item_nota_fiscal inf
     where inf.notafiscal_id = en_notafiscal_id
     order by inf.id;
  --
begin
  --
  vn_fase := 1;
  --
  -- REGISTRO HEADER - 'H'
  --
  vn_cont_geral := nvl(vn_cont_geral, 0) + 1;
  --
  gl_conteudo := null;
  gl_conteudo := 'H';
  gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_inscr_mun_empresa(en_empresa_id => gn_empresa_id), 0), 10, 0); -- Inscricao Municipal
  gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_cnpj_ou_cpf_empresa(en_empresa_id => gn_empresa_id), 0), 14, 0); -- CNPJ
  gl_conteudo := gl_conteudo || lpad(' ', 11, ' '); -- CPF Declarante (branco)
  gl_conteudo := gl_conteudo || rpad(pk_csf.fkg_nome_empresa(en_empresa_id => gn_empresa_id), 100, ' '); -- Nome Empresa
  gl_conteudo := gl_conteudo || 'N';
  gl_conteudo := gl_conteudo || rpad(to_char(gd_dt_ini, 'MM'), 2, ' '); -- Mes referencia
  gl_conteudo := gl_conteudo || rpad(to_char(gd_dt_ini, 'RRRR'), 4, ' '); -- Ano referencia
  gl_conteudo := gl_conteudo || lpad(' ', 252, ' '); -- Brancos Reservados para futuro
  gl_conteudo := gl_conteudo || '.'; -- Ponto Final
  --
  vn_fase := 2;
  --
  -- Armazena a estrutura do arquivo
  pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
  --
  vn_fase := 3;
  --
  for rec_nf in c_nf loop
    --
    exit when c_nf%notfound or(c_nf%notfound) is null;
    --
    -- REGISTRO DOCUMENTOS EMITIDOS CANCELADOS - 'C'
    --
    vn_fase := 4;
    --
    begin
      select a.lograd,
             a.nro,
             a.compl,
             a.bairro,
             a.cep,
             b.descr,
             b.ibge_cidade,
             c.sigla_estado
        into vn_lograd,
             vn_nro,
             vn_compl,
             vn_bairro,
             vn_cep,
             vv_cidade,
             vv_ibge_cidade,
             vn_uf
        from pessoa a,
             cidade b,
             estado c
       where a.id = rec_nf.pessoa_id_nf
         and b.id = a.cidade_id
         and c.id = b.estado_id;
    exception
      when no_data_found then
        vn_lograd      := null;
        vn_nro         := null;
        vn_compl       := null;
        vv_ibge_cidade := null;
        vn_bairro      := null;
        vn_cep         := null;
    end;
    --
    vn_fase := 5;
    --
    /*if trim(vv_ibge_cidade) = '4106902' then
      --
      goto proximo;
      --
    end if;
	*/
    --
begin
  SELECT PGS.VLR_PARAM
    into vv_exibe_im
    FROM MODULO_SISTEMA MS, GRUPO_SISTEMA GS, PARAM_GERAL_SISTEMA PGS
   WHERE 1 = 1
     AND MS.ID = GS.MODULO_ID
     AND MS.ID = PGS.MODULO_ID
     AND GS.ID = PGS.GRUPO_ID
     AND PGS.MULTORG_ID = pk_csf.fkg_multorg_id_empresa(REC_NF.EMPRESA_ID)
     AND MS.COD_MODULO = 'SERVICO_TOMADO' --'ISS'
     AND GS.COD_GRUPO = 'SERV_TOM_4106902' --'NAO_EXIBIR_CAMPO'
     AND PGS.PARAM_NAME = 'INSC_MUNICIPAL';
exception
  when no_data_found then
    vv_exibe_im := null;
end;
    --
    if UPPER(NVL(vv_exibe_im,'N')) = 'N' then
      begin
        select substr(a.im, 1, 10)
          into vn_im
          from juridica a
         where a.pessoa_id = rec_nf.pessoa_id_nf;
      exception
        when no_data_found then
          vn_im := null;
      end;
    ELSE
      vn_im := NULL;
    end if;
    --
    --
    vn_fase := 6;
    --
    if (rec_nf.dm_ind_emit = 0) and (rec_nf.dm_st_proc = 7) then
      -- Emissao propria e Cancelado
      --
      vn_fase := 6.1;
      --
      begin
        select a.dt_canc
          into vn_dt_canc
          from nota_fiscal_canc a
         where a.notafiscal_id = rec_nf.notafiscal_id;
      exception
        when no_data_found then
          vn_dt_canc := null;
      end;
      --
      vn_fase := 6.2;
      --
      vn_cont_reg_c := nvl(vn_cont_reg_c, 0) + 1;
      vn_cont_geral := nvl(vn_cont_geral, 0) + 1;
      --
      gl_conteudo := null;
      gl_conteudo := 'C';
      gl_conteudo := gl_conteudo || rpad(to_char(vn_dt_canc, 'DDMMRRRR'), 8, ' ');
      gl_conteudo := gl_conteudo || lpad(nvl(rec_nf.Nro_Nf, 0), 8, 0); -- Nro Nota Fiscal Inicial
      gl_conteudo := gl_conteudo || lpad(nvl(rec_nf.Nro_Nf, 0), 8, 0); -- Nro Nota Fiscal Final
      gl_conteudo := gl_conteudo || rpad(nvl(rec_nf.serie, ' '), 3, ' '); -- Serie Nota Fiscal
      gl_conteudo := gl_conteudo || rpad(' ', 361, ' '); -- Reservado para futuro
      gl_conteudo := gl_conteudo || lpad(nvl(vn_cont_reg_c, 0), 6, 0); -- Sequencial
      gl_conteudo := gl_conteudo || '.'; -- Ponto Final
      --
      vn_fase := 6.3;
      --
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
      --
    end if;
    --
    vn_fase := 7;
    --
    -- REGISTRO DOCUMENTOS EMITIDOS DECLARADOS - 'E'
    --
    if (rec_nf.dm_ind_emit = 0) and (rec_nf.dm_st_proc = 4) then
      -- Emissao propria e situacao processada
      --
      vn_fase := 7.1;
      --
      vn_cont_reg_e := nvl(vn_cont_reg_e, 0) + 1;
      vn_cont_geral := nvl(vn_cont_geral, 0) + 1;
      --
      gl_conteudo := null;
      gl_conteudo := 'E';
      gl_conteudo := gl_conteudo || rpad(to_char(rec_nf.dt_emiss, 'DDMMRRRR'), 8, ' '); -- Data Emissao
      gl_conteudo := gl_conteudo || lpad(nvl(rec_nf.nro_nf, 0), 8, 0); -- Nro Nota Fiscal Inicio
      gl_conteudo := gl_conteudo || lpad(nvl(rec_nf.nro_nf, 0), 8, 0); -- Nro Nota Fiscal Final
      gl_conteudo := gl_conteudo || '1'; -- Identificacao do Tipo de Documento
      gl_conteudo := gl_conteudo || rpad(rec_nf.serie, 3, ' '); -- Serie
      gl_conteudo := gl_conteudo || 'N'; -- Identificação do Serviço Prestado: N - Doc.Fiscal Normal
      --
      vn_fase := 7.2;
      --
      -- Local de Prestaçãodo Serviço
      if rec_nf.pessoa_id_nf <> rec_nf.pessoa_id_emp then
        --
        gl_conteudo := gl_conteudo || 'F'; -- Fora do Município
        --
      else
        --
        gl_conteudo := gl_conteudo || 'D'; -- Dentro do Município
        --
      end if;
      --
      vn_fase := 8;
      --
      for rec_inf in c_inf(rec_nf.notafiscal_id) loop
        --
        exit when c_inf%notfound or(c_inf%notfound) is null;
        --
        vn_fase := 8.1;
        --
        gl_conteudo := gl_conteudo || lpad(substr(nvl(rec_inf.cd_lista_serv, 0), 1, 2), 2, 0); -- Item Lista de Servicos
        gl_conteudo := gl_conteudo || rpad(' ', 2, ' '); -- Sub-item da Lista de Serviços (nulo)
        gl_conteudo := gl_conteudo || lpad((nvl(rec_nf.vl_total_item, 0) * 100), 15, 0); -- Valor do documento
        gl_conteudo := gl_conteudo || lpad((nvl(rec_nf.vl_desconto, 0) * 100), 15, 0); -- Valor do Desconto
        --
        vn_fase := 8.2;
        --
        -- Totaliza valores
        vn_vl_total_item_e := nvl(vn_vl_total_item_e, 0) + (nvl(rec_nf.vl_total_item, 0));
        vn_vl_desconto_e   := nvl(vn_vl_desconto_e, 0) + (nvl(rec_nf.vl_desconto, 0));
        --
        gl_conteudo := gl_conteudo || rpad(nvl(vn_im, ' '), 10, ' '); -- Inscrição Municipal
        --
        vv_cpf_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => rec_nf.pessoa_id_nf);
        --
        if length(vv_cpf_cnpj) = 14 then
          --
          gl_conteudo := gl_conteudo || vv_cpf_cnpj; -- CNPJ
          gl_conteudo := gl_conteudo || lpad('0', 11, '0'); -- CPF
          --
        else
          --
          gl_conteudo := gl_conteudo || lpad('0', 14, '0'); -- CNPJ
          gl_conteudo := gl_conteudo || lpad(nvl(vv_cpf_cnpj, 0), 11, 0); -- CPF
          --
        end if;
        --
        gl_conteudo := gl_conteudo || rpad(nvl(pk_csf.fkg_nome_pessoa_id(en_pessoa_id => rec_nf.pessoa_id_nf), ' '), 100, ' '); -- nome
        gl_conteudo := gl_conteudo || rpad('R', 5, ' '); -- Identificação do Tipo do Logradouro
        --
        vn_fase := 8.3;
        --
        gl_conteudo := gl_conteudo || rpad(substr(nvl(vn_lograd, ' '), 1, 50), 50, ' '); -- Logradouro do endereco
        gl_conteudo := gl_conteudo || rpad(substr(nvl(vn_nro, ' '), 1, 6), 6, ' '); -- Numero do endereco
        gl_conteudo := gl_conteudo || rpad(substr(nvl(vn_compl, ' '), 1, 20), 20, ' '); -- Complemento do endereco
        gl_conteudo := gl_conteudo || rpad(substr(nvl(vn_bairro, ' '), 1, 50), 50, ' '); -- Bairro do endereco
        gl_conteudo := gl_conteudo || rpad(substr(nvl(vv_cidade, ' '), 1, 44), 44, ' '); -- Cidade do endereco
        gl_conteudo := gl_conteudo || rpad(nvl(vn_uf, ' '), 2, ' '); -- Estado do endereco
        gl_conteudo := gl_conteudo || lpad(nvl(vn_cep, 0), 8, 0); -- Cep do endereco
        --
        vn_fase := 8.4;
        --
        gl_conteudo := gl_conteudo || lpad(nvl(vn_cont_reg_e, 0), 6, 0); -- Sequencial do registro
        --
        vn_fase := 8.5;
        --
        -- Valor alíquota ISS
        begin
          select imp.aliq_apli
            into vn_aliq_iss
            from imp_itemnf imp,
                 tipo_imposto ti
           where imp.itemnf_id = rec_inf.itemnf_id
             and imp.dm_tipo   = 1 -- Retenção
             and ti.id         = imp.tipoimp_id
             and ti.cd         = 6; -- ISS
        exception
          when others then
            vn_aliq_iss := 0;
        end;
        --
        vn_fase := 8.6;
        --
        gl_conteudo := gl_conteudo || lpad((nvl(vn_aliq_iss, 0) * 100), 4, 0); -- Valor percentual da Alíquota
        gl_conteudo := gl_conteudo || '.'; -- Final
        --
        vn_fase := 8.7;
        --
        -- Armazena a estrutura do arquivo
        pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
        --
      end loop;
      --
    end if;
    --
    vn_fase := 9;
    --
    -- REGISTRO DOCUMENTOS RECEBIDOS DECLARADOS - 'R'
    --
    if (rec_nf.dm_ind_emit = 1) and (rec_nf.dm_st_proc = 4) then
      -- Emissao Terceiros e situacao autorizada
      --
      vn_fase := 9.1;
      --
      vn_cont_reg_r := nvl(vn_cont_reg_r, 0) + 1;
      vn_cont_geral := nvl(vn_cont_geral, 0) + 1;
      --
      gl_conteudo := null;
      gl_conteudo := 'R';
      gl_conteudo := gl_conteudo || rpad(to_char(rec_nf.dt_emiss, 'DDMMRRRR'), 8, ' '); -- Data Emissão
      gl_conteudo := gl_conteudo || lpad(nvl(rec_nf.nro_nf, 0), 8, 0); -- Nota fiscal
      gl_conteudo := gl_conteudo || rpad(' ', 8, ' '); -- Brancos para futuro
	  -- Tratamento do CD da CID para se vier em branco colocar 1- Nota Fiscal e retirado do cursor que estava 
	  -- fixo tipo 3-RPA ou sem nenhum tipo e desta forma não estava saindo tipo 1 de Nota Fiscal.
      gl_conteudo := gl_conteudo || lpad(nvl(rec_nf.cid_cd, 1), 1, 1); -- Identificacao do Tipo de Documento
      --gl_conteudo := gl_conteudo || 1; -- Tipo de Documento
      gl_conteudo := gl_conteudo || rpad(nvl(rec_nf.serie, ' '), 3); -- Série
      gl_conteudo := gl_conteudo || 'N'; -- Identificação do Serviço
      --
      vn_fase := 9.2;
      --
      -- Local de Prestação do Serviço
      if rec_nf.pessoa_id_nf <> rec_nf.pessoa_id_emp then
        --
        gl_conteudo := gl_conteudo || 'F'; -- Fora do Municipio
        --
      else
        --
        gl_conteudo := gl_conteudo || 'D'; -- Dentro do Municipio
        --
      end if;
      --
      vn_fase := 10;
      --
      for rec_inf in c_inf(rec_nf.notafiscal_id) loop
        --
        exit when c_inf%notfound or(c_inf%notfound) is null;
        --
        vn_fase := 10.1;
        --
        gl_conteudo := gl_conteudo || lpad(substr(nvl(rec_inf.cd_lista_serv, 0), 1, 2), 2, 0); -- Item Lista de Servicos
        gl_conteudo := gl_conteudo || rpad(' ', 2, ' '); -- Sub-item da Lista de Serviços (nulo)
        gl_conteudo := gl_conteudo || lpad((nvl(rec_nf.vl_total_item, 0) * 100), 15, 0); -- Valor do documento
        gl_conteudo := gl_conteudo || lpad((nvl(rec_nf.vl_desconto, 0) * 100), 15, 0); -- Valor do Desconto
        --
        vn_fase := 10.2;
        --
        -- Totaliza valores
        vn_vl_total_item_r := nvl(vn_vl_total_item_r, 0) + nvl(rec_nf.vl_total_item, 0);
        vn_vl_desconto_r   := nvl(vn_vl_desconto_r, 0) + nvl(rec_nf.vl_desconto, 0);
        --
        vn_fase := 10.3;
        --
        gl_conteudo := gl_conteudo || lpad(nvl(vn_im, '0'), 10, '0'); -- Inscrição Municipal
        --
        vv_cpf_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => rec_nf.pessoa_id_nf);
        --
        if length(vv_cpf_cnpj) = 14 then
          --
          gl_conteudo := gl_conteudo || vv_cpf_cnpj; -- CNPJ
          gl_conteudo := gl_conteudo || lpad('0', 11, '0'); -- CPF
          --
        else
          --
          gl_conteudo := gl_conteudo || lpad('0', 14, '0'); -- CNPJ
          gl_conteudo := gl_conteudo || lpad(nvl(vv_cpf_cnpj, 0), 11, 0); -- CPF
          --
        end if;
        --
        gl_conteudo := gl_conteudo || rpad(nvl(pk_csf.fkg_nome_pessoa_id(en_pessoa_id => rec_nf.pessoa_id_nf), ' '), 100, ' '); -- nome
        gl_conteudo := gl_conteudo || rpad('R', 5, ' '); -- Identificação do Tipo do Logradouro
        --
        vn_fase := 10.4;
        --
        gl_conteudo := gl_conteudo || rpad(substr(nvl(vn_lograd, ' '), 1, 50), 50, ' '); -- Logradouro do endereco
        gl_conteudo := gl_conteudo || rpad(substr(nvl(vn_nro, ' '), 1, 6), 6, ' '); -- Numero do endereco
        gl_conteudo := gl_conteudo || rpad(substr(nvl(vn_compl, ' '), 1, 20), 20, ' '); -- Complemento do endereco
        gl_conteudo := gl_conteudo || rpad(substr(nvl(vn_bairro, ' '), 1, 50), 50, ' '); -- Bairro do endereco
        gl_conteudo := gl_conteudo || rpad(substr(nvl(vv_cidade, ' '), 1, 44), 44, ' '); -- Cidade do endereco
        gl_conteudo := gl_conteudo || rpad(nvl(vn_uf, ' '), 2, ' '); -- Estado do endereco
        gl_conteudo := gl_conteudo || lpad(nvl(vn_cep, 0), 8, 0); -- Cep do endereco
        --
        vn_fase := 10.5;
        --
        gl_conteudo := gl_conteudo || lpad(nvl(vn_cont_reg_r, 0), 6, 0); -- Sequencial do registro
        --
        vn_fase := 10.6;
        --
        -- Valor alíquota ISS
        begin
          select imp.aliq_apli
            into vn_aliq_iss
            from imp_itemnf imp,
                 tipo_imposto ti
           where imp.itemnf_id = rec_inf.itemnf_id
             and imp.dm_tipo   = 1 -- Retenção
             and ti.id         = imp.tipoimp_id
             and ti.cd         = 6; -- ISS
        exception
          when others then
            vn_aliq_iss := 0;
        end;
        --
        vn_fase := 10.7;
        --
        gl_conteudo := gl_conteudo || lpad(nvl(vn_aliq_iss, 0) * 100, 4, 0); -- Valor percentual da Alíquota
        gl_conteudo := gl_conteudo || '.'; -- Final
        --
        vn_fase := 10.8;
        --
        -- Armazena a estrutura do arquivo
        pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
        --
      end loop;
      --
    end if;
    --
    <<proximo>>
  --
    null;
    --
  end loop;
  --
  vn_fase := 11;
  --
  -- REGISTRO TRAILLER - 'T'
  --
  vn_cont_geral := nvl(vn_cont_geral, 0) + 1;
  --
  gl_conteudo := null;
  gl_conteudo := 'T';
  gl_conteudo := gl_conteudo || lpad(nvl(vn_cont_geral, 0), 8, 0); -- Total de registros do arquivo, incluindo o header(H) e trailler (T)
  gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_total_item_e, 0) * 100), 15, 0); -- Valor Total dos Documentos emitidos (E11)
  gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_desconto_e, 0) * 100), 15, 0); -- Valor Total das Deduções emitidas (E12)
  gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_total_item_r, 0) * 100), 15, 0); -- Valor Total dos Documentos recebidos (R11)
  gl_conteudo := gl_conteudo || lpad((nvl(vn_vl_desconto_r, 0) * 100), 15, 0); -- Valor Total das Deduções recebidas(R12)
  gl_conteudo := gl_conteudo || rpad(' ', 326, ' '); -- Brancos Reservado para futuro
  gl_conteudo := gl_conteudo || '.'; -- Final
  --
  vn_fase := 12;
  --
  -- Armazena a estrutura do arquivo
  pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
  --
exception
  when others then
    raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_4106902 fase (' || vn_fase || '): ' || sqlerrm);
end pkb_gera_arq_cid_4106902;

---------------------------------------------------------------------------------------------------------------------
-- Função que recupera os dados da pessoa

function fkg_recupera_dados_pessoa ( en_pessoa_id in pessoa.id%type )
         return pessoa%rowtype is
   --
   vt_row_pessoa pessoa%rowtype := null;
   --
begin
   --
   if nvl(en_pessoa_id, 0) > 0 then
      --
      begin
         --
         select nome
              , fantasia
              , lograd
              , nro
              , compl
              , bairro
              , cep
              , fone
              , email
           into vt_row_pessoa.nome
              , vt_row_pessoa.fantasia
              , vt_row_pessoa.lograd
              , vt_row_pessoa.nro
              , vt_row_pessoa.compl
              , vt_row_pessoa.bairro
              , vt_row_pessoa.cep
              , vt_row_pessoa.fone
              , vt_row_pessoa.email
           from pessoa
          where id = en_pessoa_id;
         --
      exception
         when others then
         --
         vt_row_pessoa.nome   := null;
         vt_row_pessoa.fantasia  := null;
         vt_row_pessoa.lograd := null;
         vt_row_pessoa.nro    := null;
         vt_row_pessoa.compl  := null;
         vt_row_pessoa.bairro := null;
         vt_row_pessoa.cep    := null;
         vt_row_pessoa.fone   := null;
         vt_row_pessoa.email  := null;
         --
      end;
      --
   else
      --
      vt_row_pessoa.nome   := null;
      vt_row_pessoa.fantasia  := null;
      vt_row_pessoa.lograd := null;
      vt_row_pessoa.nro    := null;
      vt_row_pessoa.compl  := null;
      vt_row_pessoa.bairro := null;
      vt_row_pessoa.cep    := null;
      vt_row_pessoa.fone   := null;
      vt_row_pessoa.email  := null;
      --
   end if;
   --
   return vt_row_pessoa;
   --
exception
   when others then
   --
   return null;
   --
end;
---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Embu / SP
procedure pkb_gera_arq_cid_3515004 is
   --
   vn_fase                number         := 0;
   vn_vl_iss              number         := 0;
   vn_vl_base_calc        number         := 0;
   vn_vl_aliquota         number         := 0;
   vn_vl_outras           number         := 0;
   vv_cpf_cnpj_prestador  varchar2(14)   := null;
   vn_tipo_cpf_cnpj       number         := 0;
   vt_row_pessoa          pessoa%rowtype := null;
   vn_pessoa_id           number         := 0;
   vn_empresa_id          number         := 0;
   vn_nat_oper            number         := 1;
   vv_cd_lista_serv       varchar2(10)   := '0000000000';
   vn_vl_deducao          number         := 0;
   vn_dm_trib_mun_prest   number         := -1;
   vn_pessoa_id_trib      number         := 0; -- ID da pessoa em que o municipio será tributado o imposto
   vv_ibge_cidade         cidade.ibge_cidade%type := null;
   vv_sigla_estado        estado.sigla_estado%type := null;
   vn_iss_tributavel      number         := 0; -- 1 - ISS tributável na nota; 2 - ISS não tributável
   --
   cursor c_nf is
   select nf.id         notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nf.dt_emiss
        , nf.pessoa_id
        , inf.id        itemnf_id
        , inf.cd_lista_serv
        , inf.qtde_comerc
        , inf.vl_unit_comerc
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , item_nota_fiscal inf
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod         = '99' -- Serviços
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id
      and inf.notafiscal_id  = nf.id
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
 order by nf.id;
   --
begin
   --
   vn_fase := 1;
   --
   -- MONTA O CABEÇALHO
   gl_conteudo := '1';
   gl_conteudo := gl_conteudo || '|' || pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => gn_empresa_id ); -- CNPJ do tomador
   gl_conteudo := gl_conteudo || '|' || pk_csf.fkg_inscr_mun_empresa ( en_empresa_id => gn_empresa_id ); -- Inscrição municipal do tomador
   gl_conteudo := gl_conteudo || '|A'; -- Aquisição de serviços
   gl_conteudo := gl_conteudo || '|' || pk_csf.fkg_ibge_cidade_empresa ( en_empresa_id => gn_empresa_id ); -- Código do IBGE do municipio do tomador
   --
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   -- MONTA O CORPO DO ARQUIVO
   for rec in c_nf loop
      exit when c_nf%notfound or (c_nf%notfound) is null;
      --
      gl_conteudo := '2';
      --
      -- Dados do documento fiscal
      gl_conteudo := gl_conteudo || '|' || rec.nro_nf;
      gl_conteudo := gl_conteudo || '|' || rec.serie;
      gl_conteudo := gl_conteudo || '|1'; -- Tipo de documento => 1 - Nota Fiscal
      gl_conteudo := gl_conteudo || '|' || rec.dt_emiss;
      --
      -- Recupera o Código da Natureza da Operação
      begin
         --
         select nvl(dm_nat_oper,1)
           into vn_nat_oper
           from nf_compl_serv
          where notafiscal_id = rec.notafiscal_id;
         --
      exception
         when others then
         --
         vn_nat_oper := 1;
         --
      end;
      --
      gl_conteudo := gl_conteudo || '|' || vn_nat_oper; -- Código da Natureza da Operação
      gl_conteudo := gl_conteudo || '|1'; -- Código de identificação do Regime Especial de Tributação => 1 - Microempresa Municipal
      gl_conteudo := gl_conteudo || '|2'; -- Opção por Simples Nacional => 2 - Não
      gl_conteudo := gl_conteudo || '|1'; -- Status da Nota Fiscal => 1 - Ativa
      gl_conteudo := gl_conteudo || '|'; -- Outras informações
      --
      -- Código de especificação da Atividade
      if rec.cd_lista_serv is not null then
         --
         vv_cd_lista_serv := rec.cd_lista_serv;
         --
      else
         --
         begin
            --
            select ts.cod_lst
              into vv_cd_lista_serv
              from item_nota_fiscal inf
                 , item i
                 , tipo_servico ts
             where inf.id = rec.itemnf_id
               and inf.item_id = i.id
               and i.tpservico_id = ts.id;
            --
         exception
            when others then
            --
            vv_cd_lista_serv := null;
            --
         end;
         --
      end if;
      --
      gl_conteudo := gl_conteudo || '|' || vv_cd_lista_serv;
      gl_conteudo := gl_conteudo || '|' || trim(to_char(trunc(rec.qtde_comerc*rec.vl_unit_comerc, 2), '999g999g999g999g990d00', 'nls_numeric_characters=.,')); -- Valor total do serviço
      --
      begin
         --
         select nvl(sum(ii.vl_imp_trib),0)
           into vn_vl_deducao
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.id            = rec.itemnf_id
            and inf.id            = ii.itemnf_id
            and ii.dm_tipo        = 1 -- Retenção
            and ti.id             = ii.tipoimp_id
            and ti.cd  in ('4', '5', '11', '12', '13');
         --
      exception
         when others then
         --
         vn_vl_deducao := 0;
         --
      end;
      --
      gl_conteudo := gl_conteudo || '|' || trim(to_char(trunc(vn_vl_deducao, 2), '999g999g999g999g990d00', 'nls_numeric_characters=.,')); -- Valor de dedução
      --
      -- Retenção na fonte
      begin
         --
         select dm_trib_mun_prest
           into vn_dm_trib_mun_prest
           from itemnf_compl_serv
          where itemnf_id = rec.itemnf_id;
         --
      exception
         when others then
         --
         vn_dm_trib_mun_prest := -1;
         --
      end;
      --
      if vn_dm_trib_mun_prest = 0 then
         --
         gl_conteudo := gl_conteudo || '|' || 1; -- Tomador pagará
         --
      elsif vn_dm_trib_mun_prest = 1 then
         --
         gl_conteudo := gl_conteudo || '|' ||  2; -- Prestador pagará
         --
      else
         --
         gl_conteudo := gl_conteudo || '|';
         --
      end if;
      --
      begin
         -- Recupera: Valor do ISS - Imposto
         --           Valor da Aliquota do serviço
         --           Valor da base de cálculo
         select nvl(sum(nvl(imp.vl_imp_trib,0)),0)
              , nvl(sum(nvl(imp.aliq_apli,0)),0)
              , nvl(sum(nvl(imp.vl_base_calc,0)),0)
           into vn_vl_iss
              , vn_vl_aliquota
              , vn_vl_base_calc
           from item_nota_fiscal inf
              , imp_itemnf imp
              , tipo_imposto ti
          where inf.id = rec.itemnf_id
            and imp.itemnf_id = inf.id
            and imp.dm_tipo = 0 -- Imposto
            and ti.id = imp.tipoimp_id
            and ti.cd = 6; -- ISS
         --
      exception
          when others then
            vn_vl_iss       := 0;
            vn_vl_aliquota  := 0;
            vn_vl_base_calc := 0;
      end;
      --
      gl_conteudo := gl_conteudo || '|' ||  trim(to_char(trunc(vn_vl_iss,2), '999g999g999g999g990d00', 'nls_numeric_characters=.,'));
      gl_conteudo := gl_conteudo || '|'; -- Valor do ISS retido
      --
      begin
         --
         select nvl(sum(nvl(imp.vl_imp_trib,0)),0)
           into vn_vl_outras
           from item_nota_fiscal inf
              , imp_itemnf imp
              , tipo_imposto ti
          where inf.id = rec.itemnf_id
            and imp.itemnf_id = inf.id
            and imp.dm_tipo = 1 -- Retenção
            and ti.id = imp.tipoimp_id
            and ti.cd <> 6; -- ISS
         --
      exception
         when others then
         --
         vn_vl_outras := 0;
         --
      end;
      --
      gl_conteudo := gl_conteudo || '|' || trim(to_char(trunc(vn_vl_outras,2), '999g999g999g999g990d00', 'nls_numeric_characters=.,'));  -- Valor de outras retenções
      gl_conteudo := gl_conteudo || '|' || trim(to_char(trunc(vn_vl_base_calc,2), '999g999g999g999g990d00', 'nls_numeric_characters=.,')); -- Valor da base de cálculo
      gl_conteudo := gl_conteudo || '|' || trim(to_char(trunc(vn_vl_aliquota,2), '999g999g999g999g990d00', 'nls_numeric_characters=.,')); -- Valor da alíquota do serviço
      --
      -- Dados do prestador do serviço
      if gn_dm_ind_emit = 0 then -- emissão própria
         --
         begin
            --
            select p.id
              into vn_pessoa_id
              from pessoa p
                 , empresa e
             where e.id = gn_empresa_id
               and e.pessoa_id = p.id;
            --
         exception
            when others then
            --
            vn_pessoa_id := 0;
            --
         end;
         --
         vv_cpf_cnpj_prestador  := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => gn_empresa_id );
         vn_empresa_id := gn_empresa_id;
         --
      else
         --
         vn_pessoa_id := rec.pessoa_id;
         vv_cpf_cnpj_prestador  := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec.pessoa_id );
         --
         begin
            --
            select e.id
              into vn_empresa_id
              from empresa e
                 , pessoa p
             where p.id = rec.pessoa_id
               and e.pessoa_id = p.id;
            --
         exception
            when others then
            --
            vn_empresa_id := 0;
            --
         end;
         --
      end if;
      --
      if nvl(length(vv_cpf_cnpj_prestador),0) = 11 then
         --
         vn_tipo_cpf_cnpj := 1;
         --
      elsif nvl(length(vv_cpf_cnpj_prestador),0) = 14 then
         --
         vn_tipo_cpf_cnpj := 2;
         --
      else
         --
         vn_tipo_cpf_cnpj := 3;
         --
      end if;
      --
      gl_conteudo := gl_conteudo || '|' || vn_tipo_cpf_cnpj; -- 1– CPF, 2– CNPJ, 3 - Exterior.
      gl_conteudo := gl_conteudo || '|' || vv_cpf_cnpj_prestador;
      --

      --
      vt_row_pessoa := fkg_recupera_dados_pessoa ( en_pessoa_id => vn_pessoa_id );
      --
      gl_conteudo := gl_conteudo || '|' || pk_csf.fkg_inscr_mun_empresa ( en_empresa_id => vn_empresa_id ); -- Inscrição Municipal do Prestador
      gl_conteudo := gl_conteudo || '|' || vt_row_pessoa.nome;
      gl_conteudo := gl_conteudo || '|' || vt_row_pessoa.lograd;
      gl_conteudo := gl_conteudo || '|' || vt_row_pessoa.nro;
      gl_conteudo := gl_conteudo || '|' || vt_row_pessoa.compl;
      gl_conteudo := gl_conteudo || '|' || vt_row_pessoa.bairro;
      gl_conteudo := gl_conteudo || '|' || pk_csf.fkg_siglaestado_pessoaid ( en_pessoa_id => vn_pessoa_id );
      gl_conteudo := gl_conteudo || '|' || vt_row_pessoa.cep;
      gl_conteudo := gl_conteudo || '|' || pk_csf.fkg_ibge_cidade_empresa ( en_empresa_id => vn_empresa_id );
      gl_conteudo := gl_conteudo || '|' || vt_row_pessoa.fone;
      gl_conteudo := gl_conteudo || '|' || vt_row_pessoa.email;
      --
      if (gn_dm_ind_emit = 0 and  vn_dm_trib_mun_prest = 0)    -- Tomador é a pessoa da nota e tomador paga o imposto
         or (gn_dm_ind_emit = 1 and  vn_dm_trib_mun_prest = 1) -- Prestador é a pessoa da nota e prestador paga o imposto
         then
         --
         vn_pessoa_id_trib := rec.pessoa_id;
         --
      elsif (gn_dm_ind_emit = 0 and  vn_dm_trib_mun_prest = 1) -- Prestador é a empresa da nota e prestador paga o imposto
         or (gn_dm_ind_emit = 1 and  vn_dm_trib_mun_prest = 0) -- Tomador é a empresa da nota e tomador paga o imposto
         then
         --
         begin
            --
            select p.id
              into vn_pessoa_id_trib
              from pessoa p
                 , empresa e
             where e.id = gn_empresa_id
               and e.pessoa_id = p.id;
            --
         exception
            when others then
            --
            vn_pessoa_id_trib := 0;
            --
         end;
         --
      end if;
      --
      begin
         --
         select c.ibge_cidade
              , e.sigla_estado
           into vv_ibge_cidade
              , vv_sigla_estado
           from cidade c
              , estado e
              , pessoa p
          where p.id = vn_pessoa_id_trib
            and c.id = p.cidade_id
            and e.id = c.estado_id;
         --
      exception
         when others then
         --
         vv_ibge_cidade := null;
         vv_sigla_estado := null;
         --
      end;
      --
      gl_conteudo := gl_conteudo || '|' || vv_ibge_cidade;  -- IBGE da cidade em que o imposto será tributado
      gl_conteudo := gl_conteudo || '|' || vv_sigla_estado; -- UF do estado em que o imposto será tributado
      --
      begin
         --
         select 1
           into vn_iss_tributavel
           from imp_itemnf ii
              , tipo_imposto ti
          where ii.itemnf_id = rec.itemnf_id
            and ii.dm_tipo = 0
            and ii.vl_imp_trib > 0
            and ti.id = ii.tipoimp_id
            and ti.cd = '6';
         --
      exception
         when no_data_found then
         --
         vn_iss_tributavel := 2;
         --
         when others then
         --
         vn_iss_tributavel := 0;
         --
      end;
      --
      gl_conteudo := gl_conteudo || '|' || vn_iss_tributavel;
      --
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_3515004 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_3515004;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Pinhais / PR
procedure pkb_gera_arq_cid_4119152 is
   --
   vn_fase                 number := 0;
   vv_simplesnacional      valor_tipo_param.cd%type := null;
   vv_cpf_cnpj_prestador   varchar2(14) := null;
   vv_cpf_cnpj_tomador     varchar2(14) := null;
   vv_conteudo             nfinfor_adic.conteudo%type := null;
   --
   vn_aliq_iss             imp_itemnf.aliq_apli%type := null;
   vn_vl_retido            imp_itemnf.vl_imp_trib%type := null;
   vn_codigo_tom           cidade.codigotom%type := null;
   --
   vv_nome                 pessoa.nome%type;
   vv_lograd               pessoa.lograd%type;
   vv_nro                  pessoa.nro%type;
   vv_compl                pessoa.compl%type;
   vv_bairro               pessoa.bairro%type;
   vv_cidade_descr         cidade.descr%type;
   vv_sigla_estado         estado.sigla_estado%type;
   vn_cep                  pessoa.cep%type;
   vv_fone                 pessoa.fone%type;
   vv_fax                  pessoa.fax%type;
   --
   cursor c_nf is
   select nf.id         notafiscal_id
        , nf.empresa_id
        , nf.dm_ind_emit
        , nf.nro_nf
        , nvl(nf.dt_sai_ent, nf.dt_emiss) dt_comp
        , nf.pessoa_id
        , nf.dt_emiss
        , nft.vl_total_item
        , nft.vl_total_nf
        , nf.dm_st_proc
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , nota_fiscal_total nft
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod         = '99' -- Serviços
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id
      and nft.notafiscal_id  = nf.id
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
    order by nf.id;
   --
   cursor c_inf (en_notafiscal_id nota_fiscal.id%type) is
   select inf.id itemnf_id
        , inf.item_id
        , it.tpservico_id
        , inf.vl_item_bruto
        , inf.vl_desc
        , cs.dm_trib_mun_prest
     from item_nota_fiscal inf
        , item it
        , itemnf_compl_serv  cs
    where inf.notafiscal_id  = en_notafiscal_id
      and it.id              = inf.item_id
      and cs.itemnf_id       = inf.id
    order by inf.id;
   --
begin
   --
   vn_fase := 1;
   --
   for rec_nf in c_nf loop
      exit when c_nf%notfound or (c_nf%notfound) is null;
      --
      vn_fase := 2;
      -- Layout do Registro Tipo 10 - Identificação do Documento Fiscal
      gl_conteudo := null;
      gl_conteudo := '10';
      gl_conteudo := gl_conteudo || ';' || case when rec_nf.dm_ind_emit = 0 then 1 else 2 end; -- Tipo do serviço
      gl_conteudo := gl_conteudo || ';' || '07'; -- Tipo do Documento
      gl_conteudo := gl_conteudo || ';' || rpad(rec_nf.nro_nf, 15, ' '); -- Número do documento
      gl_conteudo := gl_conteudo || ';' || to_char(rec_nf.dt_comp, 'mm/rrrr'); -- Competência
      --
      vn_fase := 3;
      --
      if rec_nf.dm_ind_emit = 0 then -- emissão própria
         --
         vn_fase := 3.1;
         --
         vv_cpf_cnpj_prestador  := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => rec_nf.empresa_id );
         --
         vn_fase := 3.2;
         --
         vv_cpf_cnpj_tomador    := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec_nf.pessoa_id );
         --
      else
         --
         vn_fase := 3.3;
         --
         vv_cpf_cnpj_prestador  := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec_nf.pessoa_id );
         --
         vn_fase := 3.4;
         --
         vv_cpf_cnpj_tomador    := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => rec_nf.empresa_id );
         --
      end if;
      --
      vn_fase := 4;
      --
      -- Tipo da pessoa (prestador)
      if length(vv_cpf_cnpj_prestador) = 14 then
         --
         gl_conteudo := gl_conteudo || ';' || 'J';
         --
      else
         --
         gl_conteudo := gl_conteudo || ';' || 'F';
         --
      end if;
      --
      gl_conteudo := gl_conteudo || ';' || lpad(vv_cpf_cnpj_prestador, 14, '0'); -- CPF / CNPJ do prestador do serviço
      --
      vn_fase := 5;
      -- Tipo da pessoa (tomador)
      if length(vv_cpf_cnpj_tomador) = 14 then
         --
         gl_conteudo := gl_conteudo || ';' || 'J';
         --
      else
         --
         gl_conteudo := gl_conteudo || ';' || 'F';
         --
      end if;
      --
      gl_conteudo := gl_conteudo || ';' || lpad(vv_cpf_cnpj_tomador, 14, '0'); -- CPF / CNPJ do tomador do serviço
      --
      vn_fase := 6;
      --
      gl_conteudo := gl_conteudo || ';' || to_char(rec_nf.dt_emiss, 'dd/mm/rrrr'); -- Data de emissão do documento
      gl_conteudo := gl_conteudo || ';' || trim(replace(to_char(rec_nf.vl_total_item, '000000000000000D00'), ',', '.')); -- Valor contábil do documento
      -- Situação de utilização do documento
      gl_conteudo := gl_conteudo || ';' || case when rec_nf.dm_st_proc = 4 then 'E'
                                                when rec_nf.dm_st_proc = 7 then 'C'
                                                else 'N'
                                           end;
      --
      vn_fase := 7;
      -- busca a informação do contribuinte
      begin
         --
         select i.conteudo
           into vv_conteudo
           from nfinfor_adic i
          where i.notafiscal_id = rec_nf.notafiscal_id
            and i.dm_tipo = 0 -- Contribuinte
            and i.campo is null;
         --
      exception
         when others then
            vv_conteudo := null;
      end;
      --
      if trim(vv_conteudo) is null then
         vv_conteudo := ' ';
      end if;
      --
      gl_conteudo := gl_conteudo || ';' || rpad( substr(pk_csf.fkg_converte(vv_conteudo), 1, 100) , 100, ' ');
      --
      vn_fase := 8;
      -- busca a informação de simples nacional
      vv_simplesnacional := pk_csf.fkg_pessoa_valortipoparam_cd ( ev_tipoparam_cd => '1'
                                                                , en_pessoa_id    => rec_nf.pessoa_id );
      --
      if vv_simplesnacional = '1' then -- Sim
         --
         gl_conteudo := gl_conteudo || ';' || 'S';
         --
      else
         --
         gl_conteudo := gl_conteudo || ';' || 'N';
         --
      end if;
      --
      vn_fase := 8.1;
      --
      gl_conteudo := gl_conteudo || ';';
      --
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
      vn_fase := 9;
      --
      --| Layout do Registro Tipo 20 - Identificação dos serviços relacionados ao Documentos Fiscal
      for rec_inf in c_inf(rec_nf.notafiscal_id) loop
         exit when c_inf%notfound or (c_inf%notfound) is null;
         --
         vn_fase := 10;
         --
         gl_conteudo := null;
         gl_conteudo := '20';
         gl_conteudo := gl_conteudo || ';' || case when rec_nf.dm_ind_emit = 0 then 1 else 2 end; -- Tipo do serviço
         gl_conteudo := gl_conteudo || ';' || '07'; -- Tipo do Documento
         gl_conteudo := gl_conteudo || ';' || rpad(rec_nf.nro_nf, 15, ' '); -- Número do documento
         gl_conteudo := gl_conteudo || ';' || to_char(rec_nf.dt_comp, 'mm/rrrr'); -- Competência
         --
         vn_fase := 11;
         --
         if rec_nf.dm_ind_emit = 0 then -- emissão própria
            --
            vn_fase := 11.1;
            --
            vv_cpf_cnpj_prestador  := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => rec_nf.empresa_id );
            --
            vn_fase := 11.2;
            --
            vv_cpf_cnpj_tomador    := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec_nf.pessoa_id );
            --
         else
            --
            vn_fase := 11.3;
            --
            vv_cpf_cnpj_prestador  := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec_nf.pessoa_id );
            --
            vn_fase := 11.4;
            --
            vv_cpf_cnpj_tomador    := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => rec_nf.empresa_id );
            --
         end if;
         --
         vn_fase := 12;
         --
         -- Tipo da pessoa (prestador)
         if length(vv_cpf_cnpj_prestador) = 14 then
            --
            gl_conteudo := gl_conteudo || ';' || 'J';
            --
         else
            --
            gl_conteudo := gl_conteudo || ';' || 'F';
            --
         end if;
         --
         gl_conteudo := gl_conteudo || ';' || lpad(vv_cpf_cnpj_prestador, 14, '0'); -- CPF / CNPJ do prestador do serviço
         --
         vn_fase := 13;
         -- Tipo da pessoa (tomador)
         if length(vv_cpf_cnpj_tomador) = 14 then
            --
            gl_conteudo := gl_conteudo || ';' || 'J';
            --
         else
            --
            gl_conteudo := gl_conteudo || ';' || 'F';
            --
         end if;
         --
         gl_conteudo := gl_conteudo || ';' || lpad(vv_cpf_cnpj_tomador, 14, '0'); -- CPF / CNPJ do tomador do serviço
         --
         vn_fase := 14;
         -- Código do ítem da lista de serviços da lei complementar 116.
         gl_conteudo := gl_conteudo || ';' || lpad(replace(nvl(pk_csf.fkg_Tipo_Servico_cod ( en_tpservico_id => rec_inf.tpservico_id ),'0'), '.', ''), 7, '0');
         --
         vn_fase := 15;
         --
         begin
            --
            select imp.aliq_apli
              into vn_aliq_iss
              from imp_itemnf imp
                 , tipo_imposto ti
             where imp.itemnf_id = rec_inf.itemnf_id
               and imp.dm_tipo = 0 -- Imposto
               and ti.id = imp.tipoimp_id
               and ti.cd = 6; -- ISS
            --
         exception
            when others then
               vn_aliq_iss := 0;
         end;
         --
         vn_fase := 15.1;
         -- Alíquota referente ao ítem da lista de serviços
         gl_conteudo := gl_conteudo || ';' || trim(replace(to_char(vn_aliq_iss, '0000D00'), ',', '.'));
         --
         vn_fase := 16;
         -- Valor tributável (Base de cálculo da prestação de serviços).
         gl_conteudo := gl_conteudo || ';' || trim(replace(to_char(rec_inf.vl_item_bruto, '0000000000000000D00'), ',', '.'));
         --
         vn_fase := 17;
         -- Dedução
         gl_conteudo := gl_conteudo || ';' || trim(replace(to_char(rec_inf.vl_desc, '0000000000000000D00'), ',', '.'));
         --
         vn_fase := 18;
         -- Valor retido
         begin
            --
            select imp.vl_imp_trib
              into vn_vl_retido
              from imp_itemnf imp
                 , tipo_imposto ti
             where imp.itemnf_id = rec_inf.itemnf_id
               and imp.dm_tipo = 1 -- Retenção
               and ti.id = imp.tipoimp_id
               and ti.cd = 6; -- ISS
            --
         exception
            when others then
               vn_vl_retido := 0;
         end;
         --
         vn_fase := 18.1;
         --
         gl_conteudo := gl_conteudo || ';' || trim(replace(to_char(vn_vl_retido, '0000000000000000D00'), ',', '.'));
         --
         vn_fase := 19;
         -- Local da prestação do serviço
         if rec_inf.dm_trib_mun_prest = 0 then -- Não
            --
            begin
               --
               select cid.codigotom
                 into vn_codigo_tom
                 from empresa  e
                    , pessoa   p
                    , cidade   cid
                where e.id     = rec_nf.empresa_id
                  and p.id     = e.pessoa_id
                  and cid.id   = p.cidade_id;
               --
            exception
               when others then
                  vn_codigo_tom := null;
            end;
            --
         else
            --
            begin
               --
               select cid.codigotom
                 into vn_codigo_tom
                 from pessoa   p
                    , cidade   cid
                where p.id     = rec_nf.pessoa_id
                  and cid.id   = p.cidade_id;
               --
            exception
               when others then
                  vn_codigo_tom := null;
            end;
            --
         end if;
         --
         vn_fase := 19.1;
         --
         gl_conteudo := gl_conteudo || ';' || trim(to_char(nvl( substr(vn_codigo_tom, 1, length(vn_codigo_tom) -1) ,0), '0000000'));
         --
         vn_fase := 19.2;
         -- Código da situação tributária da declaração do serviço.
         if nvl(vn_aliq_iss,0) > 0 then
            --
            gl_conteudo := gl_conteudo || ';' || '00'; -- tributada integralmente
            --
         else
            --
            gl_conteudo := gl_conteudo || ';' || '14'; -- Não tributada
            --
         end if;
         --
         vn_fase := 20;
         -- Tributa o ISS para o município do prestador do serviço (S - Sim; N - Não)
         if nvl(vn_aliq_iss,0) > 0 then
               --
            if rec_inf.dm_trib_mun_prest = 0 then
               --
               gl_conteudo := gl_conteudo || ';' || 'N';
               --
            else
               --
               gl_conteudo := gl_conteudo || ';' || 'S';
               --
            end if;
            --
         end if;
         --
         vn_fase := 21;
         --
         gl_conteudo := gl_conteudo || ';';
         --
         pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
         --
      end loop;
      --
      vn_fase := 22;
      -- Layout do Registro Tipo 30 - Identificação da pessoa relacionada ao Documento Fiscal
      begin
         --
         select p.nome
              , p.lograd
              , p.nro
              , p.compl
              , p.bairro
              , cid.descr
              , est.sigla_estado
              , p.cep
              , p.fone
              , p.fax
           into vv_nome
              , vv_lograd
              , vv_nro
              , vv_compl
              , vv_bairro
              , vv_cidade_descr
              , vv_sigla_estado
              , vn_cep
              , vv_fone
              , vv_fax
           from pessoa p
              , cidade cid
              , estado est
          where p.id = rec_nf.pessoa_id
            and cid.id = p.cidade_id
            and est.id = cid.estado_id;
         --
      exception
         when others then
            vv_nome          := null;
            vv_lograd        := null;
            vv_nro           := null;
            vv_compl         := null;
            vv_bairro        := null;
            vv_cidade_descr  := null;
            vv_sigla_estado  := null;
            vn_cep           := null;
            vv_fone          := null;
            vv_fax           := null;
      end;
      --
      vn_fase := 23;
      --
      gl_conteudo := null;
      gl_conteudo := '30';
      --
      if rec_nf.dm_ind_emit = 0 then -- emissão própria
         --
         -- Tipo da pessoa
         if length(vv_cpf_cnpj_tomador) = 14 then
            --
            gl_conteudo := gl_conteudo || ';' || 'J';
            --
         else
            --
            gl_conteudo := gl_conteudo || ';' || 'F';
            --
         end if;
         --
         gl_conteudo := gl_conteudo || ';' || lpad(vv_cpf_cnpj_tomador, 14, '0');
         --
      else
         --
         -- Tipo da pessoa
         if length(vv_cpf_cnpj_prestador) = 14 then
            --
            gl_conteudo := gl_conteudo || ';' || 'J';
            --
         else
            --
            gl_conteudo := gl_conteudo || ';' || 'F';
            --
         end if;
         --
         gl_conteudo := gl_conteudo || ';' || lpad(vv_cpf_cnpj_prestador, 14, '0');
         --
      end if;
      --
      vn_fase := 24;
      --
      gl_conteudo := gl_conteudo || ';' || rpad( substr(nvl(vv_nome, ' '), 1, 40), 40, ' ');
      gl_conteudo := gl_conteudo || ';' || rpad( substr(nvl(vv_lograd, ' '), 1, 40), 40, ' ');
      gl_conteudo := gl_conteudo || ';' || rpad( substr(nvl(vv_nro, ' '), 1, 6), 6, ' ');
      gl_conteudo := gl_conteudo || ';' || rpad( substr(nvl(vv_compl, ' '), 1, 20), 20, ' ');
      gl_conteudo := gl_conteudo || ';' || rpad( substr(nvl(vv_bairro, ' '), 1, 20), 20, ' ');
      gl_conteudo := gl_conteudo || ';' || rpad( substr(nvl(vv_cidade_descr, ' '), 1, 30), 30, ' ');
      gl_conteudo := gl_conteudo || ';' || vv_sigla_estado;
      gl_conteudo := gl_conteudo || ';' || lpad(nvl(vn_cep, 0), 8, '0');
      gl_conteudo := gl_conteudo || ';' || rpad(nvl(vv_fone, ' '), 12, ' ');
      gl_conteudo := gl_conteudo || ';' || rpad(nvl(vv_fax, ' '), 12, ' ');
      gl_conteudo := gl_conteudo || ';';
      --
      vn_fase := 25;
      --
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
   end loop;
   --
exception
   when others then
   
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_4119152 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_4119152;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de São Luís / MA
procedure pkb_gera_arq_cid_2111300 is
   --
   vn_fase                     number := 0;
   --Registro tipo H - Identificação
   vv_ident_reg_h              varchar2(1) := 'H';
   vv_ident_emp                juridica.im%type;
   vn_vers_arq                 number(3) := 100;
   --Registro tipo R - Notas fiscais recebidas
   vv_ident_reg_r              varchar2(1) := 'R';
   vd_dt_ret_iss               nota_fiscal.dt_emiss%type;
   vd_dt_emi_nf                nota_fiscal.dt_emiss%type;
   vv_serie_nf                 nota_fiscal.serie%type;
   vv_modelo                   varchar2(1) := 'U';
   vv_mot_ret                  varchar2(1);
   vn_nro_nf                   nota_fiscal.nro_nf%type;
   vn_vl_bruto_nf              item_nota_fiscal.vl_item_bruto%type;
   vn_vl_serv_lan_nfr          item_nota_fiscal.vl_item_bruto%type;
   vn_aliq_iss                 imp_itemnf.aliq_apli%type;
   vn_nro_fat                  nota_fiscal_cobr.nro_fat%type;
   vn_quant_parc               number(6);
   vv_mot_nao_ret              varchar2(30);
   vv_cnpj_prest               varchar2(14) := null;
   vv_cpf_prest                varchar2(14) := null;
   vv_nome_prest               pessoa.nome%type;
   vn_cd_siafi                 tipo_cod_arq.cd%type;
   vv_simpl_nac                valor_tipo_param.cd%type;
   vn_cd_serv_pret             item_nota_fiscal.cd_lista_serv%type;
   vn_cd_siafi_mun_prest       tipo_cod_arq.cd%type;
   vv_oper_nf_rec              varchar2(1);

   --
   cursor c_nfs is
   select nf.id         notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss) dt_emiss
        , nf.pessoa_id
        , nf.empresa_id
        , ncs.dm_nat_oper
        , inf.vl_item_bruto
        , inf.cd_lista_serv
        , inf.descr_item
        , nft.vl_total_nf
        , nft.vl_ret_iss
        , nfc.nro_fat
        , ics.cidade_id
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , nf_compl_serv  ncs
        , item_nota_fiscal inf
        , itemnf_compl_serv ics
        , nota_fiscal_total nft
        , nota_fiscal_cobr nfc
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id
      and nf.id              = ncs.notafiscal_id (+)
      and nf.id              = inf.notafiscal_id
      and inf.id             = ics.itemnf_id (+)
      and nft.notafiscal_id  = nf.id
      and nfc.notafiscal_id  = nf.id
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
 order by nf.id;

   --
begin
   --
   vn_fase := 1;
   --
   -- Registro H
   gl_conteudo := null;
   gl_conteudo := vv_ident_reg_h;
   gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_inscr_mun_empresa(en_empresa_id => gn_empresa_id), 0),  11, 0); -- Inscricao Municipal
   gl_conteudo := gl_conteudo || vn_vers_arq;
   --
   vn_fase := 2;
   --
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_fase := 3;
   --
   for rec in c_nfs loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      gl_conteudo := null;
      gl_conteudo := vv_ident_reg_r;
      gl_conteudo := gl_conteudo || to_char(rec.dt_emiss,'dd/mm/yyyy'); --Data de retenção do ISS
      gl_conteudo := gl_conteudo || to_char(rec.dt_emiss,'dd/mm/yyyy'); --Data de emissão da nota fiscal
      gl_conteudo := gl_conteudo || rpad(rec.serie,2,' '); -- Serie
      gl_conteudo := gl_conteudo || vv_modelo; -- Modelo da nota
      gl_conteudo := gl_conteudo || rpad(nvl(vv_mot_ret,' '),1, ' '); --Motivo da Retenção / Não Retenção
      gl_conteudo := gl_conteudo || lpad(nvl(rec.nro_nf,0),9,0); -- Numero da nota fiscal
      gl_conteudo := gl_conteudo || trim(replace(to_char(rec.vl_item_bruto,'000000000000D00'), ',', '.')); -- valor bruto da nota fiscal
      gl_conteudo := gl_conteudo || trim(replace(to_char(rec.vl_item_bruto,'000000000000D00'), ',', '.')); -- Valor do serviço lançado na nota fiscal recebida
      --
      vn_fase := 4;
      --
      begin
         --
         vn_aliq_iss := null;
         --
         select ii.aliq_apli
           into vn_aliq_iss
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and ii.itemnf_id      = inf.id
            and ii.dm_tipo        = 1 -- Retenção
            and ti.id             = ii.tipoimp_id
            and ti.cd             = '6'; -- ISS
      exception
         when others then
            vn_aliq_iss := null;
      end;
      --
      vn_fase := 5;
      --
      vn_nro_fat := null;
      --
      if rec.nro_fat is null then
         vn_nro_fat := 0;
      else
         vn_nro_fat := rec.nro_fat;
      --
      end if;
      --
      vn_fase := 6;
      --
      begin
         --
         select count(nfd.id)
           into vn_quant_parc
           from nfcobr_dup nfd
              , nota_fiscal_cobr nfc
          where nfc.id            = nfd.nfcobr_id
            and nfc.notafiscal_id = rec.notafiscal_id;
         --
      exception
         when others then
         --
         vn_quant_parc := null;
         --
      end;
      --
      vn_fase := 7;
      --
      if vn_aliq_iss > 0 then
      gl_conteudo := gl_conteudo || trim(replace(to_char(vn_aliq_iss,'00D00'), ',', '.')); -- recuperar do Imposto ISS com o Tipo 1-Retido
      else
      gl_conteudo := gl_conteudo || '00.00';
      end if;
      --
      gl_conteudo := gl_conteudo || lpad(nvl(vn_nro_fat,0),6,0);
      gl_conteudo := gl_conteudo || lpad(nvl(vn_quant_parc,0),6,0);
      gl_conteudo := gl_conteudo || rpad(nvl(vv_mot_nao_ret,' '),30, ' ');
      --
      vn_fase := 8;
      --
      vv_cnpj_prest := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec.pessoa_id );
      --
      vn_fase := 9;
      --
      vv_cpf_prest  := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec.pessoa_id );
      --
      vn_fase := 10;
      --
      vv_nome_prest := pk_csf.fkg_nome_empresa ( en_empresa_id => rec.empresa_id);
      --
      vn_fase := 11;
      --
      vn_cd_siafi := pk_csf.fkg_cd_cidade_tipo_cod_arq ( en_cidade_id     => gn_cidade_id
                                                       , en_tipocodarq_id => pk_csf.fkg_tipocodarq_id ( ev_cd => 5)); -- SIAFI
      --
      vn_fase := 12;
      --
      if nvl(trim(length(vv_cpf_prest)),0) > 11 then
         --
         gl_conteudo := gl_conteudo || lpad(nvl(vv_cnpj_prest,'0'),14,0);
         gl_conteudo := gl_conteudo || '00000000000';
         --
      else
         --
         gl_conteudo := gl_conteudo || '00000000000000';
         gl_conteudo := gl_conteudo || lpad(nvl(vv_cnpj_prest,'0'),11,0);
         --
      end if;
      --
      --gl_conteudo := gl_conteudo || vv_cnpj_prest;
      --gl_conteudo := gl_conteudo || vv_cpf_prest;
      gl_conteudo := gl_conteudo || substr(vv_nome_prest,1,40);
      gl_conteudo := gl_conteudo || rpad(vn_cd_siafi,10,' ');
      --
      vn_fase := 13;
      --
      vv_simpl_nac := pk_csf.fkg_pessoa_valortipoparam_cd( ev_tipoparam_cd => 1 -- Simples Nacional
                                                         , en_pessoa_id    => rec.pessoa_id );
      --
      vn_fase := 14;
      --
      if nvl(vv_simpl_nac,'0') = '1' then
         --
         gl_conteudo := gl_conteudo || rpad('S',1,' '); -- Enquadramento no Simples Nacional do Tomador de Serviços
         --
      else
         --
         gl_conteudo := gl_conteudo || rpad('N',1,' ');
         --
      end if;
      --
      vn_fase := 15;
      --
      begin
         --
         select distinct(inf.cd_lista_serv)
           into vn_cd_serv_pret
           from item_nota_fiscal inf
          where inf.notafiscal_id   = rec.notafiscal_id;
         --
      exception
        when others then
            vn_cd_serv_pret := null;
      end;
      --
      vn_fase := 16;
      --
      vn_cd_siafi_mun_prest := pk_csf.fkg_cd_cidade_tipo_cod_arq ( en_cidade_id     => rec.cidade_id
                                                                 , en_tipocodarq_id => pk_csf.fkg_tipocodarq_id ( ev_cd => 5)); -- SIAFI
      --
      vn_fase := 17;
      --
      if rec.dm_nat_oper in (1, 2, 7) then
         vv_oper_nf_rec := 'B';
      elsif rec.dm_nat_oper in (3, 4, 5, 6) then
         vv_oper_nf_rec := 'C';
      elsif rec.dm_nat_oper not in (1, 2, 3, 4, 5, 6, 7, 8) then
         vv_oper_nf_rec := null;
      end if;
      --
      vn_fase := 18;
      --
      gl_conteudo := gl_conteudo || rpad(nvl(to_char(vn_cd_serv_pret),' '),10,' ');
      gl_conteudo := gl_conteudo || rpad(nvl(vn_cd_siafi_mun_prest,' '),10,' ');
      gl_conteudo := gl_conteudo || vv_oper_nf_rec;
      --
      vn_fase := 19;
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
  end loop;
      --
exception
   When others then
      --
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_2111300 fase ('||vn_fase||'): '||sqlerrm);
      --
end pkb_gera_arq_cid_2111300;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Natal / RN
procedure pkb_gera_arq_cid_2408102 is
   --
   vn_fase                  number := 0;
   vn_cont_geral            number := 0;
   vn_cont_c                number := 0;
   vn_cont_e                number := 0;
   vn_cont_o                number := 0;
   vn_cont_z                number := 0;
   --Registro Header
   vv_tipo                  varchar2(1) := 'A';
   vv_ident_emp             juridica.im%type;
   vn_tipo_dds              number;
   vn_versao                number(4) := 1000;
   vv_cod_pref              varchar2(4) := 'NATA';
   vv_esp_dds               varchar2(2) := 'EM';
   vn_ind_mov               number;
   --Contribuinte
   vv_reg_c                 varchar2(1) := 'C';
   vv_nome                  pessoa.nome%type;
   vv_lograd                pessoa.lograd%type;
   vv_nro                   pessoa.nro%type;
   vv_compl                 pessoa.compl%type;
   vv_bairro                pessoa.bairro%type;
   vn_cep                   pessoa.cep%type;
   vv_cnpj                  varchar2(14);
   vv_ddd_fone              pessoa.fone%type;
   vv_fone                  pessoa.fone%type;
   vv_ddd_fax               pessoa.fax%type;
   vv_fax                   pessoa.fax%type;
   --dados contador
   vv_nome_contador         varchar2(55);
   vv_cpf_cnpj_cont         varchar2(14);
   vv_email_cont            varchar2(35);
   vv_crc_cont              varchar2(7);
   --
   vn_tp_serv               number(1) := 1;
   --Tomador
   vv_reg_e                 varchar2(1) := 'E';
   vv_cnpj_tom              varchar2(20);
   vn_insc_mun              juridica.im%type;
   vv_nome_tom              pessoa.nome%type;
   vv_lograd_tom            pessoa.lograd%type;
   vv_nro_tom               pessoa.nro%type;
   vv_compl_tom             pessoa.compl%type;
   vv_bairro_tom            pessoa.bairro%type;
   vv_cidade_tom            cidade.descr%type;
   vv_estado_tom            estado.sigla_estado%type;
   vn_cep_tom               pessoa.cep%type;
   vv_ddd_tom               pessoa.fone%type;
   vv_fone_tom              pessoa.fone%type;
   vv_ddd_fax_tom           pessoa.fone%type;
   vv_fax_tom               pessoa.fone%type;
   vv_email_tom             pessoa.email%type;
   vn_estrangeiro           pessoa.dm_tipo_pessoa%type;
   --Registro Documento Recebido
   vv_tipo_o                varchar2(1) := 'O';
   vv_tp_doc                varchar2(1) := 'N';
   vn_vl_aliq               imp_itemnf.aliq_apli%type;
   vn_vl_base_calc          imp_itemnf.vl_base_calc%type;
   vn_vl_iss_ret            imp_itemnf.vl_imp_trib%type;
   vd_dt_vencto             date;
   vn_seq_rec               number(6) := 000000;
   vv_cod_base_legal        varchar2(5);
   --Registro Trailer
   vv_tipo_z                varchar2(1) := 'Z';
   vn_qtde_bs_legal         number(5);
   vn_qtde_turmas           number(5);
   vn_qtde_ser_inst_fin     number(5);
   vn_qtde_notas_emi        number(5);
   vn_qtde_notas_avu        number(5);
   vn_qtde_dedu             number(5);
   vn_qtde_aut_esp          number(5);
   vn_qtde_inst_fin         number(5);
   vn_qtde_tur_dec          number(5);
   vn_qtde_desp             number(5);
   --
   cursor c_nfs is
   select nf.id         notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nf.sub_serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss) dt_emiss
        , nf.pessoa_id
        , nf.empresa_id
        , ncs.dm_nat_oper
        , sum(inf.vl_item_bruto)  vl_item_bruto
        , inf.cd_lista_serv
        , inf.descr_item
        , nft.vl_total_nf
        , nft.vl_ret_iss
        , ics.cidade_id
        , cid.ibge_cidade
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , nf_compl_serv  ncs
        , cidade cid
        , item_nota_fiscal inf
        , itemnf_compl_serv ics
        , nota_fiscal_total nft
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and p.cidade_id        =  gn_cidade_id
      and cid.id             = p.cidade_id
      and nf.id              = ncs.notafiscal_id (+)
      and nf.id              = inf.notafiscal_id
      and nf.id              = nft.notafiscal_id (+)
      and inf.id             = ics.itemnf_id (+)
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
 group by nf.id
        , nf.nro_nf
        , nf.serie, nf.sub_serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss)
        , nf.pessoa_id
        , nf.empresa_id
        , ncs.dm_nat_oper
        , inf.cd_lista_serv
        , inf.descr_item
        , nft.vl_total_nf
        , nft.vl_ret_iss
        , ics.cidade_id
        , cid.ibge_cidade;
   --
begin
   --
   vn_fase := 1;
   --
   select count(nvl(nf.id,0))
     into vn_ind_mov
     from nota_fiscal nf
         , mod_fiscal mf
         , empresa e
         , pessoa p
         , item_nota_fiscal inf
     where nf.empresa_id      = gn_empresa_id
       and nf.dm_ind_emit     = gn_dm_ind_emit
       and nf.dm_st_proc      = 4
       and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
           or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
           or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
           or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
       and mf.id              = nf.modfiscal_id
       and ((mf.cod_mod = '99') or (mf.cod_mod = '55'))
       and inf.cd_lista_serv is not null
       and e.id               = nf.empresa_id
       and p.id               = e.pessoa_id
       and p.cidade_id        = gn_cidade_id
       and nf.id              = inf.notafiscal_id
       and nvl(nf.dm_arm_nfe_terc, 0) = 0; -- #73514
   --
   --Registro Header
   --
   vn_cont_geral := vn_cont_geral + 1;
   --
   gl_conteudo := null;
   gl_conteudo := vv_tipo;
   gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_inscr_mun_empresa(en_empresa_id => gn_empresa_id), 0),  7, 0); -- Inscricao Municipal
   gl_conteudo := gl_conteudo || to_char(sysdate,'yyyymm');

   if gn_en_tipo = 0 then
   gl_conteudo := gl_conteudo || 'N';
   elsif gn_en_tipo = 1 then
   gl_conteudo := gl_conteudo || 'R';
   end if;

   gl_conteudo := gl_conteudo || to_char(sysdate, 'ddmmyyyy');
   gl_conteudo := gl_conteudo || to_char(sysdate, 'hh24miss');
   gl_conteudo := gl_conteudo || vn_versao;
   gl_conteudo := gl_conteudo || vv_cod_pref;
   gl_conteudo := gl_conteudo || vv_esp_dds;
   --
   if vn_ind_mov > 0 then
      gl_conteudo := gl_conteudo || 'C';
   else
      gl_conteudo := gl_conteudo || 'S';
   end if;
   --
   vn_fase := 2;
   --
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_fase := 3;
   --
   for rec in c_nfs loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      --Contribuinte
      --
      begin
         --
         select p.nome
              , p.lograd
              , p.nro
              , p.compl
              , p.bairro
              , p.cep
              , p.fone
              , p.fax
           into vv_nome
              , vv_lograd
              , vv_nro
              , vv_compl
              , vv_bairro
              , vn_cep
              , vv_fone
              , vv_fax
           from pessoa p
              , empresa e
          where e.id = rec.empresa_id
            and p.id = e.pessoa_id;
         --
      exception
         when no_data_found then
            --
            vv_nome    := null;
            vv_lograd  := null;
            vv_nro     := null;
            vv_compl   := null;
            vv_bairro  := null;
            vn_cep     := null;
            vv_fone    := null;
            vv_fax     := null;
            --
      end;
      --
      vn_fase := 4;
      --
      vv_nome_contador := null;
      vv_cpf_cnpj_cont := null;
      vv_crc_cont      := null;
      vv_email_cont    := null;
      --
      begin
         --
         select rpad(p.nome, 55, ' ')
              , lpad(pk_csf.fkg_cnpjcpf_pessoa_id(p.id),14,0)
              , rpad(c.crc, 7, ' ')
              , rpad(p.email, 35, ' ')
           into vv_nome_contador
              , vv_cpf_cnpj_cont
              , vv_crc_cont
              , vv_email_cont
           from contador_empresa ce
              , contador         c
              , pessoa           p
          where ce.empresa_id  = rec.empresa_id
            and ce.dm_situacao = 1 -- 0-inativo, 1-ativo
            and c.id           = ce.contador_id
            and p.id           = c.pessoa_id;
      exception
         when others then
            --
            vv_nome_contador  := null;
            vv_cpf_cnpj_cont  := null;
            vv_crc_cont       := null;
            vv_email_cont     := null;
      end;
      --
      vn_fase := 5;
      --
      vn_cont_c     := vn_cont_c + 1;
      vn_cont_geral := vn_cont_geral + 1;
      --
      vv_cnpj := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => gn_empresa_id );
      --
      gl_conteudo := null;
      gl_conteudo := vv_reg_c;
      gl_conteudo := gl_conteudo || rpad(nvl(vv_nome,' '), 55, ' '); -- Razão Social
      gl_conteudo := gl_conteudo || rpad(nvl(vv_lograd,' '), 35, ' '); -- Endereço
      gl_conteudo := gl_conteudo || rpad(nvl(vv_nro,' '), 5, ' '); -- Número do Endereço
      gl_conteudo := gl_conteudo || rpad(nvl(vv_compl,' '), 12, ' '); -- Complemento do Endereço
      gl_conteudo := gl_conteudo || rpad(nvl(vv_bairro,' '), 19, ' '); -- Bairro
      gl_conteudo := gl_conteudo || substr( vn_cep , 1 , 5 ) || '-' || substr( vn_cep , 6 , 8);  -- cep
      gl_conteudo := gl_conteudo || lpad(nvl(vv_cnpj,'0'),14,'0'); --cnpj
      gl_conteudo := gl_conteudo || substr(vv_fone, 1, 2); -- ddd
      gl_conteudo := gl_conteudo || rpad(nvl(substr(vv_fone,3,8),' '), 8, ' '); -- fone
      gl_conteudo := gl_conteudo || rpad(substr(nvl(vv_fax,' '), 1, 2),2, ' '); -- ddd fax
      gl_conteudo := gl_conteudo || rpad(nvl(vv_fax,' '), 8, ' '); -- fax
      gl_conteudo := gl_conteudo || rpad(nvl(vv_nome_contador,' '),55 ,' ');
      gl_conteudo := gl_conteudo || rpad(nvl(vv_cpf_cnpj_cont,' '),14 ,' ');
      gl_conteudo := gl_conteudo || rpad(nvl(vv_email_cont,' '),35 ,' ');
      gl_conteudo := gl_conteudo || rpad(nvl(vv_crc_cont,' '),7,' ');
      gl_conteudo := gl_conteudo || vn_tp_serv;
      --
      vn_fase := 6;
      --
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
      vn_fase := 7;
      --
      --Registro Tomador
      --
      vn_cont_e     := vn_cont_e + 1;
      vn_cont_geral := vn_cont_geral + 1;
      --
      vn_fase := 8;
      --
      vv_cnpj_tom := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec.pessoa_id );
      --
      if vv_cnpj_tom is null then
         --
         begin
            --
            select es.id_estrangeiro
              into vv_cnpj_tom
              from estrang es
             where es.pessoa_id = rec.pessoa_id;
            --
         exception
            when others then
               vv_cnpj_tom := null;
         end;
         --
      end if;
      --
      vn_insc_mun := pk_csf.fkg_inscr_mun_pessoa ( en_pessoa_id => rec.pessoa_id );
      --
      if vn_insc_mun is null then
         --
         vn_insc_mun := 9999999;
         --
      end if;
      --
      vn_fase := 9;
      --
      begin
         --
         select pe.nome
              , pe.lograd
              , pe.nro
              , pe.compl
              , pe.bairro
              , ci.descr
              , es.sigla_estado
              , pe.cep
              , pe.fone
              , pe.fax
              , pe.email_forn
           into vv_nome_tom
              , vv_lograd_tom
              , vv_nro_tom
              , vv_compl_tom
              , vv_bairro_tom
              , vv_cidade_tom
              , vv_estado_tom
              , vn_cep_tom
              , vv_fone_tom
              , vv_fax_tom
              , vv_email_tom
           from pessoa   pe
              , cidade   ci
              , estado   es
              , juridica ju
          where pe.id        = rec.pessoa_id
            and ci.id        = pe.cidade_id
            and es.id        = ci.estado_id
            and ju.pessoa_id = pe.id;
      exception
         when others then
            vv_nome_tom     := null;
            vv_lograd_tom   := null;
            vv_nro_tom      := null;
            vv_compl_tom    := null;
            vv_bairro_tom   := null;
            vv_cidade_tom   := null;
            vv_estado_tom   := null;
            vn_cep_tom      := null;
            vv_fone_tom     := null;
            vv_fax_tom      := null;
            vv_email_tom    := null;
      end;
      --
      begin
         --
         select p.dm_tipo_pessoa
           into vn_estrangeiro
           from pessoa p
          where p.id = rec.pessoa_id;
         --
      exception
         when others then
            vn_estrangeiro := null;
      end;
      --
      vn_fase := 10;
      --
      gl_conteudo := null;
      gl_conteudo := vv_reg_e;
      gl_conteudo := gl_conteudo || rpad(vv_cnpj_tom, 20, ' ');
      --
      if rec.ibge_cidade = 2408102 then 
         --
         gl_conteudo := gl_conteudo || vn_insc_mun;
         --
      end if;
      --
      gl_conteudo := gl_conteudo || rpad(nvl(vv_nome_tom,' '), 55, ' '); -- Razão Social
      gl_conteudo := gl_conteudo || rpad(nvl(vv_lograd_tom,' '), 35, ' '); -- Endereço
      gl_conteudo := gl_conteudo || rpad(nvl(vv_nro_tom,' '), 5, ' '); -- Número do Endereço
      gl_conteudo := gl_conteudo || rpad(nvl(vv_compl_tom,' '), 12, ' '); -- Complemento do Endereço
      gl_conteudo := gl_conteudo || rpad(nvl(vv_bairro_tom,' '), 19, ' '); -- Bairro
      gl_conteudo := gl_conteudo || rpad(nvl(vv_cidade_tom, ' '), 25, ' '); --cidade
      gl_conteudo := gl_conteudo || vv_estado_tom;
      gl_conteudo := gl_conteudo || substr(vn_cep_tom , 1 , 5 ) || '-' || substr( vn_cep_tom , 6 , 8);  -- cep
      gl_conteudo := gl_conteudo || rpad(substr(nvl(vv_fone_tom,' '), 1, 2), 2,' '); -- ddd
      gl_conteudo := gl_conteudo || rpad(nvl(vv_fone_tom,' '), 8, ' '); -- fone
      gl_conteudo := gl_conteudo || rpad(substr(nvl(vv_fax_tom,' '), 1, 2),2, ' '); -- ddd fax
      gl_conteudo := gl_conteudo || rpad(nvl(vv_fax_tom,' '), 8, ' '); -- fax
      gl_conteudo := gl_conteudo || rpad(nvl(vv_email_tom, ' '), 35, ' '); --email
      --
      if vn_estrangeiro in (3) then
         --
         gl_conteudo := gl_conteudo || 'S';
         --
      else
         --
         gl_conteudo := gl_conteudo || 'N';
         --
      end if;
      --
      vn_fase := 11;
      --
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
      vn_fase := 12;
      --
      --Registro Documento Recebido
      --
      vn_cont_o     := vn_cont_o + 1;
      vn_cont_geral := vn_cont_geral + 1;
      --
      vn_fase := 13;
      --
      begin
         --
         vn_vl_aliq       := null;
         vn_vl_base_calc  := null;
         vn_vl_iss_ret    := null;
         --
         select ii.aliq_apli
              , sum(ii.vl_base_calc)
              , sum(ii.vl_imp_trib)
           into vn_vl_aliq
              , vn_vl_base_calc
              , vn_vl_iss_ret
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and ii.itemnf_id      = inf.id
            and ii.dm_tipo        = 1 -- Retenção
            and ti.id             = ii.tipoimp_id
            and ti.cd             = '6'
          group by ii.aliq_apli; -- ISS
      exception
         when others then
            vn_vl_aliq       := null;
            vn_vl_base_calc  := null;
            vn_vl_iss_ret    := null;
      end;
      --
      vn_fase := 14;
      --
      gl_conteudo := null;
      gl_conteudo := vv_tipo_o;
      gl_conteudo := gl_conteudo || lpad(nvl(vn_cont_o,0),6,0); -- Sequencial
      gl_conteudo := gl_conteudo || rpad(nvl(vv_nome_tom,' '), 55, ' '); -- Razão Social
      gl_conteudo := gl_conteudo || rpad(nvl(vv_lograd_tom,' '), 35, ' '); -- Endereço
      gl_conteudo := gl_conteudo || rpad(nvl(vv_nro_tom,' '), 5, ' '); -- Número do Endereço
      gl_conteudo := gl_conteudo || rpad(nvl(vv_compl_tom,' '), 12, ' '); -- Complemento do Endereço
      gl_conteudo := gl_conteudo || rpad(nvl(vv_bairro_tom,' '), 19, ' '); -- Bairro
      gl_conteudo := gl_conteudo || rpad(nvl(vv_cidade_tom, ' '), 25, ' '); --cidade
      gl_conteudo := gl_conteudo || vv_estado_tom;
      gl_conteudo := gl_conteudo || substr( vn_cep_tom , 1 , 5 ) || '-' || substr( vn_cep_tom , 6 , 8);  -- cep
      gl_conteudo := gl_conteudo || rpad(vv_cnpj_tom, 20, ' ');
      gl_conteudo := gl_conteudo || vv_tp_doc;
      --
      vn_fase := 14;
      --
      gl_conteudo := gl_conteudo || rpad(nvl(rec.serie,' '), 2,' '); -- Serie
      --
      vn_fase := 14.1;
      --
      gl_conteudo := gl_conteudo || rpad(nvl(to_char(to_char(rec.sub_serie)),' '), 3, ' '); --Sub_serie
      --
      vn_fase := 14.2;
      --
      gl_conteudo := gl_conteudo || rpad(rec.nro_nf, 14, ' '); -- número nota fiscal
      gl_conteudo := gl_conteudo || to_char(rec.dt_emiss,'ddmmyyyy');
      --
      vd_dt_vencto := null;
      --
      begin
         --
         select max(nfd.dt_vencto)
          into vd_dt_vencto
          from nota_fiscal_cobr nfc
             , nfcobr_dup nfd
         where nfc.notafiscal_id = rec.notafiscal_id
           and nfc.id = nfd.nfcobr_id;
         --
      exception
       when no_data_found then
          vd_dt_vencto := null;
      end;
      --
      gl_conteudo := gl_conteudo || to_char(vd_dt_vencto, 'ddmmyyyy');
      --
      vn_fase := 14.3;
      --
      --
      vn_fase := 15;
      --
      if rec.ibge_cidade = 2408102 then
         --
         gl_conteudo := gl_conteudo || vn_insc_mun;
         --
      end if;
      --
      gl_conteudo := gl_conteudo || lpad(nvl(rec.vl_item_bruto,0)*100, 11, 0);
      gl_conteudo := gl_conteudo || lpad(nvl(nvl(vn_vl_aliq,0)*100,0), 4, 0);
      gl_conteudo := gl_conteudo || lpad(nvl(nvl(vn_vl_base_calc,0)*100,0), 11, 0);
      gl_conteudo := gl_conteudo || lpad(nvl(nvl(vn_vl_iss_ret,0)*100,0), 11, 0);
      --
      vn_fase := 16;
      --
      if nvl(vn_vl_iss_ret,0) > 0 then
         gl_conteudo := gl_conteudo || 'S'; -- ISS Retido
      else
         gl_conteudo := gl_conteudo || 'N'; -- ISS Retido
      end if;
      --
      vn_fase := 17;
      --
      gl_conteudo := gl_conteudo || lpad(nvl(vn_seq_rec,0), 6, 0); --sequencial
      gl_conteudo := gl_conteudo || lpad(nvl(vv_cod_base_legal,' '), 5,' '); --código base legal
      --
      vn_fase := 18;
      --
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
   end loop;
   --
   vn_fase := 19;
   --
   -- Registro Trailer
   --
   vn_cont_z     := vn_cont_z + 1;
   vn_cont_geral := vn_cont_geral + 1;
   --
   gl_conteudo := null;
   gl_conteudo := vv_tipo_z;
   gl_conteudo := gl_conteudo || lpad(nvl(vn_cont_geral,0),5, 0);
   gl_conteudo := gl_conteudo || lpad(nvl(vn_cont_c,0),5, 0);
   gl_conteudo := gl_conteudo || lpad(nvl(vn_cont_e,0),5, 0);
   gl_conteudo := gl_conteudo || lpad(nvl(null,0),5, 0); -- QUANTIDADE DE BASES LEGAIS (B)
   gl_conteudo := gl_conteudo || lpad(nvl(vn_qtde_turmas,0),5, 0);
   gl_conteudo := gl_conteudo || lpad(nvl(vn_qtde_ser_inst_fin,0),5, 0);
   gl_conteudo := gl_conteudo || lpad(nvl(vn_qtde_notas_emi,0),5, 0);
   gl_conteudo := gl_conteudo || lpad(nvl(vn_qtde_notas_avu,0),5, 0);

   gl_conteudo := gl_conteudo || lpad(nvl(vn_cont_o,0),5, 0);
   gl_conteudo := gl_conteudo || lpad(nvl(vn_qtde_dedu,0),5, 0);
   gl_conteudo := gl_conteudo || lpad(nvl(vn_qtde_aut_esp,0),5, 0);
   gl_conteudo := gl_conteudo || lpad(nvl(vn_qtde_inst_fin,0),5, 0);
   gl_conteudo := gl_conteudo || lpad(nvl(vn_qtde_tur_dec,0),5, 0);
   gl_conteudo := gl_conteudo || lpad(nvl(vn_qtde_desp,0),5, 0);
   --
   vn_fase := 20;
   -- Armazena a estrutura do arquivo 
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
exception
   when others then
      --
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_2408102 fase ('||vn_fase||'): '||sqlerrm);
      --
end pkb_gera_arq_cid_2408102;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Sorocaba / SP
procedure pkb_gera_arq_cid_3552205 is
   --
   vn_fase               number := 0;
   --
   vv_mot_ret            varchar2(1);
   vn_aliq_iss           imp_itemnf.aliq_apli%type;
   vn_nro_fat            nota_fiscal_cobr.nro_fat%type;
   vn_quant_parc         number(6);
   vv_mot_n_ret          varchar2(30);
   vn_cid_ibge_tomador   nota_fiscal_dest.cidade_ibge%type;
   vv_cod_siafi          cidade_tipo_cod_arq.cd%type;
   vv_simpl_nac          valor_tipo_param.cd%type := null;
   vv_cod_siafi_local    cidade_tipo_cod_arq.cd%type;
   vn_cliente            number(14) := null;
   vv_cod                varchar2(10) := null;
   --
   cursor c_nfs is
   select nf.id         notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss) dt_emiss
        , nf.pessoa_id
        , nf.empresa_id
        , ncs.dm_nat_oper
        , sum(inf.vl_item_bruto)  vl_item_bruto
        , inf.cd_lista_serv
        , inf.descr_item
        , nft.vl_total_nf
        , nft.vl_ret_iss
        , nfc.nro_fat
        , ics.cidade_id
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , nf_compl_serv  ncs
        , item_nota_fiscal inf
        , itemnf_compl_serv ics
        , nota_fiscal_total nft
        , nota_fiscal_cobr nfc
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id
      and nf.id              = ncs.notafiscal_id (+)
      and nf.id              = inf.notafiscal_id
      and inf.id             = ics.itemnf_id (+)
      and nft.notafiscal_id  = nf.id
      and nfc.notafiscal_id  = nf.id
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
 group by nf.id
        , nf.nro_nf
        , nf.serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss)
        , nf.pessoa_id
        , nf.empresa_id
        , ncs.dm_nat_oper
        , inf.cd_lista_serv
        , inf.descr_item
        , nft.vl_total_nf
        , nft.vl_ret_iss
        , nfc.nro_fat
        , ics.cidade_id;
   --
begin
   --
   vn_fase := 1;
   --
   -- Header
   --
   gl_conteudo := null;
   gl_conteudo := 'H';
   gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_inscr_mun_empresa(en_empresa_id => gn_empresa_id), 0),  11, 0); -- Inscricao Municipal
   gl_conteudo := gl_conteudo || 300; --Versão do Sistema DMS
   --
   vn_fase := 2;
   --
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_fase := 3;
   --
   for rec in c_nfs loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_fase := 4;
      --
      --Registro do tipo R
      --
      gl_conteudo := null;
      gl_conteudo := 'R';
      gl_conteudo := gl_conteudo || to_char(rec.dt_emiss,'dd/mm/yyyy'); --Data de retenção do ISS.
      gl_conteudo := gl_conteudo || to_char(rec.dt_emiss,'dd/mm/yyyy'); --Data de emissão da nota fiscal.
      gl_conteudo := gl_conteudo || rpad(rec.serie,2,' '); --Série da nota fiscal
      gl_conteudo := gl_conteudo || 'U'; --Modelo da nota fiscal
      --
      vn_fase := 5;
      --
      if rec.dm_nat_oper in (1, 2, 7) then
         vv_mot_ret := 'T';
      elsif rec.dm_nat_oper in (5, 6) then
         vv_mot_ret := 'A';
      elsif rec.dm_nat_oper = 4 then
         vv_mot_ret := 'D';
      elsif rec.dm_nat_oper = 3 then
         vv_mot_ret := 'E';
      end if;
      --
      gl_conteudo := gl_conteudo || rpad(nvl(vv_mot_ret, ' '), 1,' '); --Motivo da Retenção / Não Retenção
      gl_conteudo := gl_conteudo || lpad(nvl(rec.nro_nf, 0), 9, 0); --Número de identificação da nota fiscal
      gl_conteudo := gl_conteudo || trim(replace(to_char(rec.vl_item_bruto,'000000000000D00'), ',', '.')); --Valor bruto da nota fiscal
      gl_conteudo := gl_conteudo || trim(replace(to_char(rec.vl_item_bruto,'000000000000D00'), ',', '.')); --Valor do serviço lançado na nota fiscal recebida
      --
      vn_fase := 6;
      --
      begin
         --
         vn_aliq_iss := null;
         --
         select ii.aliq_apli
           into vn_aliq_iss
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and ii.itemnf_id      = inf.id
            and ii.dm_tipo        = 1 -- Retenção
            and ti.id             = ii.tipoimp_id
            and ti.cd             = '6'; -- ISS
      exception
         when others then
            vn_aliq_iss := null;
      end;
      --
      vn_fase := 7;
      --
      if vn_aliq_iss > 0 then
      gl_conteudo := gl_conteudo || pk_csf.fkg_formata_num(vn_aliq_iss, '99D99'); --Alíquota de ISS
      else
      gl_conteudo := gl_conteudo || '00.00';
      end if;
      --
      vn_fase := 8;
      --
      if rec.nro_fat is null then
         vn_nro_fat := 0;
      else
         vn_nro_fat := rec.nro_fat;
      --
      end if;
      --
      vn_fase := 9;
      --
      gl_conteudo := gl_conteudo || lpad(vn_nro_fat, 6, 0); --Número da parcela de pagamento da NF
      --
      vn_fase := 10;
      --
      begin
         --
         select count(nfd.id)
           into vn_quant_parc
           from nfcobr_dup nfd
              , nota_fiscal_cobr nfc
          where nfc.id            = nfd.nfcobr_id
            and nfc.notafiscal_id = rec.notafiscal_id;
         --
      exception
         when others then
         --
         vn_quant_parc := null;
         --
      end;
      --
      vn_fase := 11;               
      --
      gl_conteudo := gl_conteudo || lpad(nvl(vn_quant_parc, 0), 6, 0); --Quantidade de parcelas de pagamento da NF
      gl_conteudo := gl_conteudo || rpad(nvl(vv_mot_n_ret,' '), 30,' '); --Motivo da não retenção
      --
      vn_fase := 11.2;
      --
      if length(pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec.pessoa_id )) > 11 then
         --
         gl_conteudo := gl_conteudo || lpad(pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec.pessoa_id ), 14, 0); --CNPJ do prestador de serviços
         gl_conteudo := gl_conteudo || lpad(nvl(null, 0),11,0);
         --
      else
         --
         gl_conteudo := gl_conteudo || lpad(nvl(null, 0),14,0);
         gl_conteudo := gl_conteudo || lpad(pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec.pessoa_id ), 11, 0); --CNPJ do prestador de serviços
         --
      end if;
      --
      vn_fase := 11.3;
      --
      gl_conteudo := gl_conteudo || rpad(pk_csf.fkg_nome_pessoa_id ( en_pessoa_id => rec.pessoa_id ), 40, ' '); --Nome do prestador de serviços
      --
      vn_fase := 12;
      --
      begin
         --
         vn_cid_ibge_tomador := null;
         --
         select nfd.cidade_ibge
           into vn_cid_ibge_tomador
           from nota_fiscal_dest nfd
          where notafiscal_id = rec.notafiscal_id;
         --
      exception
         when others then
            vn_cid_ibge_tomador := null;
      end;
      --
      vn_fase := 13;
      -- Código SIAFI do município do tomador de serviços
      vv_cod_siafi := fkg_ibge_cid_tipo_cod_arq( en_ibge_cidade    => vn_cid_ibge_tomador
                                               , en_cd_tipo_cod_arq => 5 ); -- SIAFI
      --
      vn_fase := 14;
      --
      gl_conteudo := gl_conteudo || rpad(nvl(vv_cod_siafi, ' '), 10, ' ');
      --
      vn_fase := 15;
      --
      vv_simpl_nac := pk_csf.fkg_pessoa_valortipoparam_cd( ev_tipoparam_cd => 1 -- Simples Nacional
                                                         , en_pessoa_id    => rec.pessoa_id );
      --
      vn_fase := 16;
      --
      if nvl(vv_simpl_nac,'0') = '1' then
         --
         gl_conteudo := gl_conteudo || rpad('S',1,' '); -- Enquadramento no Simples Nacional do Tomador de Serviços
         --
      else
         --
         gl_conteudo := gl_conteudo || rpad('N',1,' ');
         --
      end if;
      --
      vn_fase := 17;
      --
      if vn_cid_ibge_tomador = 3552205 then
      gl_conteudo := gl_conteudo || rpad(nvl(vv_cod, ' '), 10, ' ');
      else
      gl_conteudo := gl_conteudo || lpad(nvl(rec.cd_lista_serv, 0), 10, 0);
      end if;
      --
      vv_cod_siafi_local := pk_csf.fkg_cd_cidade_tipo_cod_arq ( en_cidade_id     => rec.cidade_id
                                                              , en_tipocodarq_id => pk_csf.fkg_tipocodarq_id ( ev_cd => 5)); -- SIAFI
      --
      vn_fase := 18;
      --
      gl_conteudo := gl_conteudo || rpad(nvl(vv_cod_siafi_local, ' '), 10, ' ');
      gl_conteudo := gl_conteudo || 'A';
      gl_conteudo := gl_conteudo || lpad(nvl(vn_cliente,0),14, 0);
      --
      vn_fase := 19;
      --
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
   end loop;
exception
   when others then
      --
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_3552205 fase ('||vn_fase||'): '||sqlerrm); 
      --
end pkb_gera_arq_cid_3552205;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Campinas / SP
procedure pkb_gera_arq_cid_3509502 is
  --
  vn_fase number := 0;
  --
  vn_ibge            cidade.ibge_cidade%type;
  vv_motivo          varchar2(1) := null;
  vn_aliq_iss        imp_itemnf.aliq_apli%type;
  vn_parcela         number(6) := 0;
  vn_qtd_par         number(6) := 0;
  vv_motivo_nao      varchar2(30);
  vv_cpf_cnpj        varchar2(14);
  vv_siafi           cidade_tipo_cod_arq.cd%type;
  vn_estrangeiro     pessoa.dm_tipo_pessoa%type;
  vv_simpl_nac       valor_tipo_param.cd%type := null;
  vv_inscrito        varchar2(1) := null;
  vv_cod_siafi_local cidade_tipo_cod_arq.cd%type;
  vn_dm_tipo         imp_itemnf.tipoimp_id%type;
  --
  cursor c_nfs is
    select nf.id notafiscal_id,
           nf.nro_nf,
           nf.serie,
           nf.dt_emiss,
           nf.pessoa_id,
           nf.empresa_id,
           ncs.dm_nat_oper,
           sum(inf.vl_item_bruto) vl_item_bruto,
           inf.cd_lista_serv,
           inf.descr_item,
           nft.vl_total_nf,
           nft.vl_ret_iss,
           --, nfc.nro_fat
           ics.cidade_id, 
           nf.dm_ind_emit
      from nota_fiscal       nf,
           mod_fiscal        mf,
           empresa           e,
           pessoa            p,
           nf_compl_serv     ncs,
           item_nota_fiscal  inf,
           itemnf_compl_serv ics,
           nota_fiscal_total nft
    --, nota_fiscal_cobr nfc
     where nf.empresa_id     = gn_empresa_id
       and nf.dm_ind_emit    = gn_dm_ind_emit
       and nf.dm_st_proc     = 4
       and ((nf.dm_ind_emit  = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between gd_dt_ini and gd_dt_fin) or
           (nf.dm_ind_emit   = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) or
           (nf.dm_ind_emit   = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) or
           (nf.dm_ind_emit   = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
       and mf.id             = nf.modfiscal_id
       and ((mf.cod_mod      = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
       and e.id              = nf.empresa_id
       and p.id              = e.pessoa_id
       and p.cidade_id       = gn_cidade_id
       and nf.id             = ncs.notafiscal_id(+)
       and nf.id             = inf.notafiscal_id
       and inf.id            = ics.itemnf_id(+)
       and nft.notafiscal_id = nf.id
       and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
       and nf.pessoa_id  in  (select  p.id   from pessoa p   where p.id in (nf.pessoa_id )  and p.cidade_id <> gn_cidade_id) --Municicpio do Prestador diferente do Municipio do Tomador
 
    --and nfc.notafiscal_id  = nf.id
     group by nf.id,
              nf.nro_nf,
              nf.serie,
              nf.dt_emiss,
              nf.pessoa_id,
              nf.empresa_id,
              ncs.dm_nat_oper,
              inf.cd_lista_serv,
              inf.descr_item,
              nft.vl_total_nf,
              nft.vl_ret_iss,
              --, nfc.nro_fat
              ics.cidade_id,
              nf.dm_ind_emit;
  --
begin
  --
  vn_fase := 1;
  --
  --Registro H
  --
  gl_conteudo := null;
  gl_conteudo := 'H';
  gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_inscr_mun_empresa(en_empresa_id => gn_empresa_id), 0), 11, 0);
  gl_conteudo := gl_conteudo || 100;
  --
  -- Armazena a estrutura do arquivo
  pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
  --
  vn_fase := 2;
  --
  for rec in c_nfs loop
    exit when c_nfs%notfound or(c_nfs%notfound) is null;
    --
    vn_fase := 3;
    --
    begin
      --
      select cid.ibge_cidade
        into vn_ibge
        from cidade cid,  
             pessoa pe
       where cid.id = pe.cidade_id
         and pe.id  = rec.pessoa_id;
      --
    exception
      when others then
        --
        vn_ibge := null;
        --
    end;
    --
    vn_fase := 4;
    --
    begin
      --
      vn_aliq_iss := null;
      --
      select ii.aliq_apli, 
             ii.dm_tipo
        into vn_aliq_iss, 
             vn_dm_tipo
        from item_nota_fiscal inf, 
             imp_itemnf ii, 
             tipo_imposto ti
       where inf.notafiscal_id = rec.notafiscal_id
         and ii.itemnf_id      = inf.id
         and ii.dm_tipo        = 1 -- Retenção
         and ti.id             = ii.tipoimp_id
         and ti.cd             = '6'; -- ISS
    exception
      when others then
        vn_aliq_iss := null;
        vn_dm_tipo  := 0;
    end;
    --
    vn_fase := 5;
    --
    begin
      --
      select p.dm_tipo_pessoa
        into vn_estrangeiro
        from pessoa p
       where p.id = rec.pessoa_id;
      --
    exception
      when others then
        vn_estrangeiro := null;
    end;
    --
    vn_fase := 6;
    --
    vv_cpf_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => rec.pessoa_id);
    --
    vv_siafi := fkg_ibge_cid_tipo_cod_arq(en_ibge_cidade     => vn_ibge,
                                          en_cd_tipo_cod_arq => 5); -- SIAFI
    --
    vv_simpl_nac := pk_csf.fkg_pessoa_valortipoparam_cd(ev_tipoparam_cd => 1, -- Simples Nacional
                                                        en_pessoa_id    => rec.pessoa_id);
    --
    vn_fase := 6.1;
    --
    -- Se a nota fiscal for de terceiro (1) e o imposto for do tipo normal (0)
    -- o campo SIAFI deve ser referente ao município do participante da nota fiscal
    if rec.dm_ind_emit = 1 and nvl(vn_dm_tipo, 0) = 0 then
     --
     vv_cod_siafi_local := fkg_ibge_cid_tipo_cod_arq(en_ibge_cidade     => vn_ibge,
                                                     en_cd_tipo_cod_arq => 5); -- SIAFI
     --
    else
     -- 
     vv_cod_siafi_local := pk_csf.fkg_cd_cidade_tipo_cod_arq(en_cidade_id     => rec.cidade_id,
                                                             en_tipocodarq_id => pk_csf.fkg_tipocodarq_id(ev_cd => 5)); -- SIAFI
     --
    end if;
    --
    vn_fase := 7;
    --
    --Registro R
    gl_conteudo := 'R'; --Identificação do registro
    gl_conteudo := gl_conteudo || to_char(rec.dt_emiss, 'dd/mm/yyyy'); -- Data de retenção do ISS
    gl_conteudo := gl_conteudo || to_char(rec.dt_emiss, 'dd/mm/yyyy'); -- Data de emissão da nota fiscal.
    --
    vn_fase := 8;
    --
    if vn_ibge = '3509502' then
      gl_conteudo := gl_conteudo || 'OT'; --Documento da nota fiscal
    else
      gl_conteudo := gl_conteudo || 'OM';
    end if;
    --
    gl_conteudo := gl_conteudo || 'R'; -- Série / Modelo da nota fiscal
    gl_conteudo := gl_conteudo || rpad(nvl(vv_motivo, ' '), 1, ' '); -- Motivo da Não Retenção
    gl_conteudo := gl_conteudo || lpad(nvl(rec.nro_nf, 0), 9, 0); --Número de identificação da nota fiscal
    gl_conteudo := gl_conteudo || trim(replace(to_char(rec.vl_item_bruto, '000000000000D00'), ',', '.')); -- Valor bruto da nota fiscal
    gl_conteudo := gl_conteudo || trim(replace(to_char(rec.vl_item_bruto, '000000000000D00'), ',', '.')); -- Valor do serviço lançado na nota fiscal recebida
    gl_conteudo := gl_conteudo || replace(lpad(nvl(pk_csf.fkg_formata_num(vn_aliq_iss, '99D99'), 0), 5, 0), ',', '.'); -- Alíquota de ISS
    gl_conteudo := gl_conteudo || lpad(nvl(null, 0), 6, 0); -- Número da parcela de pagamento da NF
    gl_conteudo := gl_conteudo || lpad(nvl(null, 0), 6, 0); -- Quantidade de parcelas de pagamento da NF
    gl_conteudo := gl_conteudo || rpad(nvl(vv_motivo_nao, ' '), 30, ' '); -- Descrição do Motivo da não retenção
    --
    vn_fase := 9;
    --
    if vn_estrangeiro = 1 then
      gl_conteudo := gl_conteudo || vv_cpf_cnpj; --CNPJ do prestador de serviços
    else
      gl_conteudo := gl_conteudo || 00000000000000;
    end if;
    --
    vn_fase := 10;
    --
    if vn_estrangeiro = 0 then
      gl_conteudo := gl_conteudo || vv_cpf_cnpj; --CPF do prestador de serviços.
    else
      gl_conteudo := gl_conteudo || lpad(nvl(null, 0), 11, 0);
    end if;
    --
    vn_fase := 11;
    --
    gl_conteudo := gl_conteudo || rpad(pk_csf.fkg_nome_pessoa_id(en_pessoa_id => rec.pessoa_id), 40, ' '); --Nome do prestador de serviços
    --
    vn_fase := 12;
    --
    if vn_estrangeiro = 2 then
      gl_conteudo := gl_conteudo || 9999; --
    else
      gl_conteudo := gl_conteudo || rpad(vv_siafi, 10, ' '); --Código SIAFI do município do prestador de serviços
    end if;
    --
    vn_fase := 13;
    --
    if nvl(vv_simpl_nac, '0') = '1' then
      gl_conteudo := gl_conteudo || rpad('S', 1, ' '); -- Enquadramento no Simples Nacional do Tomador de Serviços
    else
      gl_conteudo := gl_conteudo || rpad('N', 1, ' ');
    end if;
    --
    vn_fase := 14;
    --
    if vn_ibge = '3509502' then
      gl_conteudo := gl_conteudo || rpad(nvl(pk_csf.fkg_inscr_mun_pessoa(en_pessoa_id => rec.pessoa_id), ' '), 1, ' ');
    else
      gl_conteudo := gl_conteudo || rpad(nvl(null, ' '), 1, ' '); --Inscrito no município do prestador.
    end if;
    --
    vn_fase := 15;
    --
    gl_conteudo := gl_conteudo || lpad(nvl(rec.cd_lista_serv, 0), 10, 0); --Código do serviço prestado
    gl_conteudo := gl_conteudo || rpad(nvl(vv_cod_siafi_local, ' '), 10, ' '); --Código SIAFI do município do Local da Prestação do Serviço.
    --
    if vn_ibge = '3509502' then
      gl_conteudo := gl_conteudo || 'A'; -- Operação da nota fiscal recebida
    else
      gl_conteudo := gl_conteudo || 'I'; -- Operação da nota fiscal recebida
    end if;
    --
    vn_fase := 16;
    --
    pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
    --
  end loop;
  --
exception
  when others then
    --
    raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_3509502 fase (' || vn_fase || '): ' || sqlerrm);
    --
end pkb_gera_arq_cid_3509502;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço de Campo Grande - MS
procedure pkb_gera_arq_cid_5002704 is
  --
  vn_fase number := 0;
  --
  vn_ibge            cidade.ibge_cidade%type;
  vv_motivo          varchar2(1) := null;
  vn_aliq_iss        imp_itemnf.aliq_apli%type;
  vn_parcela         number(6) := 0;
  vn_qtd_par         number(6) := 0;
  vv_motivo_nao      varchar2(30);
  vv_cpf_cnpj        varchar2(14);
  vv_siafi           cidade_tipo_cod_arq.cd%type;
  vn_estrangeiro     pessoa.dm_tipo_pessoa%type;
  vv_simpl_nac       valor_tipo_param.cd%type := null;
  vv_inscrito        varchar2(1) := null;
  vv_cod_siafi_local cidade_tipo_cod_arq.cd%type;
  vn_dm_tipo         imp_itemnf.tipoimp_id%type;
  --
  cursor c_nfs is
    select nf.id notafiscal_id,
           nf.nro_nf,
           nf.serie,
           nf.dt_emiss,
           nf.pessoa_id,
           nf.empresa_id,
           ncs.dm_nat_oper,
           sum(inf.vl_item_bruto) vl_item_bruto,
           inf.cd_lista_serv,
           inf.descr_item,
           nft.vl_total_nf,
           nft.vl_ret_iss,
           ics.cidade_id,
           nf.dm_ind_emit
      from nota_fiscal       nf,
           mod_fiscal        mf,
           empresa           e,
           pessoa            p,
           nf_compl_serv     ncs,
           item_nota_fiscal  inf,
           itemnf_compl_serv ics,
           nota_fiscal_total nft
     where nf.empresa_id    = gn_empresa_id
       and nf.dm_ind_emit   = gn_dm_ind_emit
       and nf.dm_st_proc    = 4
       and ((nf.dm_ind_emit = 1 and to_date(nvl(nf.dt_sai_ent, nf.dt_emiss), 'dd/mm/rrrr') between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and to_date(nf.dt_emiss, 'dd/mm/rrrr') between gd_dt_ini and gd_dt_fin) 
             or 
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_date(nf.dt_emiss, 'dd/mm/rrrr') between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and to_date(nvl(nf.dt_sai_ent, nf.dt_emiss), 'dd/mm/rrrr') between gd_dt_ini and gd_dt_fin))
       and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
       and mf.id             = nf.modfiscal_id
       and e.id              = nf.empresa_id
       and p.id              = e.pessoa_id
       and p.cidade_id       = gn_cidade_id
       and nf.id             = ncs.notafiscal_id(+)
       and nf.id             = inf.notafiscal_id
       and inf.id            = ics.itemnf_id(+)
       and nft.notafiscal_id = nf.id
       and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
       and nf.pessoa_id in (select p.id
                              from pessoa p
                             where p.id in (nf.pessoa_id)
                               and p.cidade_id <> gn_cidade_id) --Municícpio do Prestador diferente do Município do Tomador
     group by nf.id,
              nf.nro_nf,
              nf.serie,
              nf.dt_emiss,
              nf.pessoa_id,
              nf.empresa_id,
              ncs.dm_nat_oper,
              inf.cd_lista_serv,
              inf.descr_item,
              nft.vl_total_nf,
              nft.vl_ret_iss,
              ics.cidade_id,
              nf.dm_ind_emit;
  --
begin
  --
  vn_fase := 1;
  --
  -- Registro H
  gl_conteudo := null;
  gl_conteudo := 'H';
  gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_inscr_mun_empresa(en_empresa_id => gn_empresa_id), 0), 11, 0);
  gl_conteudo := gl_conteudo || 500;
  --
  -- Armazena a estrutura do arquivo
  pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
  --
  vn_fase := 2;
  --
  for rec in c_nfs loop
    exit when c_nfs%notfound or(c_nfs%notfound) is null;
    --
    vn_fase := 3;
    --
    begin
      select cid.ibge_cidade
        into vn_ibge
        from cidade cid, 
             pessoa pe
       where cid.id = pe.cidade_id
         and pe.id  = rec.pessoa_id;
    exception
      when others then
        vn_ibge := null;
    end;
    --
    vn_fase := 4;
    --
    begin
      --
      vn_aliq_iss := null;
      --
      select ii.aliq_apli, 
             ii.dm_tipo
        into vn_aliq_iss, 
             vn_dm_tipo
        from item_nota_fiscal inf, 
             imp_itemnf ii, 
             tipo_imposto ti
       where inf.notafiscal_id = rec.notafiscal_id
         and ii.itemnf_id      = inf.id
         and ii.dm_tipo        = 1 -- Retenção
         and ti.id             = ii.tipoimp_id
         and ti.cd             = '6'; -- ISS
    exception
      when others then
        vn_aliq_iss := null;
        vn_dm_tipo  := 0;
    end;
    --
    vn_fase := 5;
    --
    begin
      select p.dm_tipo_pessoa
        into vn_estrangeiro
        from pessoa p
       where p.id = rec.pessoa_id;
    exception
      when others then
        vn_estrangeiro := null;
    end;
    --
    vn_fase := 6;
    --
    vv_cpf_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => rec.pessoa_id);
    --
    vv_siafi := fkg_ibge_cid_tipo_cod_arq(en_ibge_cidade     => vn_ibge,
                                          en_cd_tipo_cod_arq => 5); -- SIAFI
    --
    vv_simpl_nac := pk_csf.fkg_pessoa_valortipoparam_cd(ev_tipoparam_cd => 1, -- Simples Nacional
                                                        en_pessoa_id    => rec.pessoa_id);
    --
    vn_fase := 6.1;
    --
    -- Se a nota fiscal for de terceiro (1) e o imposto for do tipo normal (0)
    -- o campo SIAFI deve ser referente ao município do participante da nota fiscal
    if rec.dm_ind_emit = 1 and nvl(vn_dm_tipo, 0) = 0 then
      --
      vv_cod_siafi_local := fkg_ibge_cid_tipo_cod_arq(en_ibge_cidade     => vn_ibge,
                                                      en_cd_tipo_cod_arq => 5); -- SIAFI
      --
    else
      --
      vv_cod_siafi_local := pk_csf.fkg_cd_cidade_tipo_cod_arq(en_cidade_id     => rec.cidade_id,
                                                              en_tipocodarq_id => pk_csf.fkg_tipocodarq_id(ev_cd => 5)); -- SIAFI
      --
    end if;
    --
    vn_fase := 7;
    --
    -- Registro R
    gl_conteudo := 'R'; -- Identificação do registro
    gl_conteudo := gl_conteudo || to_char(rec.dt_emiss, 'dd/mm/yyyy'); -- Data de retenção do ISS
    gl_conteudo := gl_conteudo || to_char(rec.dt_emiss, 'dd/mm/yyyy'); -- Data de emissão da nota fiscal.
    --
    vn_fase := 8;
    --
    if vn_ibge = '3509502' then
      gl_conteudo := gl_conteudo || 'OT'; -- Documento da nota fiscal
    else
      gl_conteudo := gl_conteudo || 'OM';
    end if;
    --
    gl_conteudo := gl_conteudo || 'R'; -- Série / Modelo da nota fiscal
    gl_conteudo := gl_conteudo || rpad(nvl(vv_motivo, ' '), 1, ' '); -- Motivo da Não Retenção
    gl_conteudo := gl_conteudo || lpad(nvl(rec.nro_nf, 0), 9, 0); -- Número de identificação da nota fiscal
    gl_conteudo := gl_conteudo || trim(replace(to_char(rec.vl_item_bruto, '000000000000D00'), ',', '.')); -- Valor bruto da nota fiscal
    gl_conteudo := gl_conteudo || trim(replace(to_char(rec.vl_item_bruto, '000000000000D00'), ',', '.')); -- Valor do serviço lançado na nota fiscal recebida
    gl_conteudo := gl_conteudo || replace(lpad(nvl(pk_csf.fkg_formata_num(vn_aliq_iss, '99D99'), 0), 5, 0), ',', '.'); -- Alíquota de ISS
    gl_conteudo := gl_conteudo || lpad(nvl(null, 0), 6, 0); -- Número da parcela de pagamento da NF
    gl_conteudo := gl_conteudo || lpad(nvl(null, 0), 6, 0); -- Quantidade de parcelas de pagamento da NF
    gl_conteudo := gl_conteudo || rpad(nvl(vv_motivo_nao, ' '), 30, ' '); -- Descrição do Motivo da não retenção
    --
    vn_fase := 9;
    --
    if vn_estrangeiro = 1 then
      gl_conteudo := gl_conteudo || vv_cpf_cnpj; --CNPJ do prestador de serviços
    else
      gl_conteudo := gl_conteudo || 00000000000000;
    end if;
    --
    vn_fase := 10;
    --
    if vn_estrangeiro = 0 then
      gl_conteudo := gl_conteudo || vv_cpf_cnpj; --CPF do prestador de serviços.
    else
      gl_conteudo := gl_conteudo || lpad(nvl(null, 0), 11, 0);
    end if;
    --
    vn_fase := 11;
    --
    gl_conteudo := gl_conteudo || rpad(pk_csf.fkg_nome_pessoa_id(en_pessoa_id => rec.pessoa_id), 40, ' '); --Nome do prestador de serviços
    --
    vn_fase := 12;
    --
    if vn_estrangeiro = 2 then
      gl_conteudo := gl_conteudo || 9999; --
    else
      gl_conteudo := gl_conteudo || rpad(vv_siafi, 10, ' '); -- Código SIAFI do município do prestador de serviços
    end if;
    --
    vn_fase := 13;
    --
    if nvl(vv_simpl_nac, '0') = '1' then
      gl_conteudo := gl_conteudo || rpad('S', 1, ' '); -- Enquadramento no Simples Nacional do Tomador de Serviços
    else
      gl_conteudo := gl_conteudo || rpad('N', 1, ' ');
    end if;
    --
    vn_fase := 14;
    --
    if vn_ibge = '3509502' then
      gl_conteudo := gl_conteudo || rpad(nvl(pk_csf.fkg_inscr_mun_pessoa(en_pessoa_id => rec.pessoa_id), ' '), 1, ' ');
    else
      gl_conteudo := gl_conteudo || rpad(nvl(null, ' '), 1, ' '); -- Inscrito no município do prestador.
    end if;
    --
    vn_fase := 15;
    --
    gl_conteudo := gl_conteudo || lpad(nvl(rec.cd_lista_serv, 0), 10, 0); -- Código do serviço prestado
    gl_conteudo := gl_conteudo || rpad(nvl(vv_cod_siafi_local, ' '), 10, ' '); -- Código SIAFI do município do Local da Prestação do Serviço.
    --
    if vn_ibge = '3509502' then
      gl_conteudo := gl_conteudo || 'A'; -- Operação da nota fiscal recebida
    else
      gl_conteudo := gl_conteudo || 'I'; -- Operação da nota fiscal recebida
    end if;
    --
    vn_fase := 16;
    --
    pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
    --
  end loop;
  --
exception
  when others then
    --
    raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_5002704 fase (' || vn_fase || '): ' || sqlerrm);
    --
end pkb_gera_arq_cid_5002704;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de São José / SC
procedure pkb_gera_arq_cid_4216602 is
   --
   vn_fase             number := 0;
   --
   vn_estrangeiro      pessoa.dm_tipo_pessoa%type;
   vn_ibge             cidade.ibge_cidade%type;
   vv_simpl_nac        valor_tipo_param.cd%type := null;
   vv_motivo           varchar2(512) := null;
   vn_aliq_iss         imp_itemnf.aliq_apli%type;
   --
   cursor c_nfs is
   select nf.id         notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss) dt_emiss
        , nf.pessoa_id
        , nf.empresa_id
        , ncs.dm_nat_oper
        , sum(inf.vl_item_bruto)  vl_item_bruto
        , inf.cd_lista_serv
        , inf.descr_item
        , inf.cidade_ibge
        , nft.vl_total_nf
        , nft.vl_ret_iss
        , nfc.nro_fat
        , ics.cidade_id
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , nf_compl_serv  ncs
        , item_nota_fiscal inf
        , itemnf_compl_serv ics
        , nota_fiscal_total nft
        , nota_fiscal_cobr nfc
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id
      and nf.id              = ncs.notafiscal_id (+)
      and nf.id              = inf.notafiscal_id
      and inf.id             = ics.itemnf_id (+)
      and nft.notafiscal_id  = nf.id
      and nfc.notafiscal_id  = nf.id
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
 group by nf.id         
        , nf.nro_nf
        , nf.serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss) 
        , nf.pessoa_id
        , nf.empresa_id
        , ncs.dm_nat_oper
        , inf.cd_lista_serv
        , inf.descr_item
        , inf.cidade_ibge
        , nft.vl_total_nf
        , nft.vl_ret_iss
        , nfc.nro_fat
        , ics.cidade_id;
   --
begin
   --
   vn_fase := 1;
   --
   --Declaração
   --
   gl_conteudo := null;
   gl_conteudo := 1;
   gl_conteudo := gl_conteudo || 'T';
   gl_conteudo := gl_conteudo || 1; --IBGE
   gl_conteudo := gl_conteudo || rpad(nvl(substr(pk_csf.fkg_cnpj_ou_cpf_empresa(en_empresa_id => gn_empresa_id), 1, 14), ' '), 14, ' ');
   gl_conteudo := gl_conteudo || rpad(nvl(substr(pk_csf.fkg_nome_empresa(en_empresa_id => gn_empresa_id), 1, 50), ' '), 50, ' ');
   gl_conteudo := gl_conteudo || to_char(sysdate, 'ddmmyyyy');
   gl_conteudo := gl_conteudo || to_char(sysdate, 'ddmmyyyy');
   --
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_fase := 2;
   --
   for rec in c_nfs loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_fase := 3;
      --
      begin
         --
         select p.dm_tipo_pessoa
           into vn_estrangeiro
           from pessoa p
          where p.id = rec.pessoa_id;
         --
      exception
         when others then
            vn_estrangeiro := null;
      end;
      --
      vn_fase := 4;
      --
       begin
         --
        select to_number(cid.ibge_cidade)
          into vn_ibge
          from cidade cid
             , pessoa pe
         where cid.id  = pe.cidade_id
           and pe.id   = rec.pessoa_id;
         --
      exception
         when others then
            --
            vn_ibge := null;
            --
      end;
      --
      vv_simpl_nac := pk_csf.fkg_pessoa_valortipoparam_cd( ev_tipoparam_cd => 1 -- Simples Nacional
                                                         , en_pessoa_id    => rec.pessoa_id );
      --
      vn_fase := 5;
      --
      --Registro tipo 2 - Documentos
      --
      gl_conteudo := 2;                       
      gl_conteudo := gl_conteudo || rpad(nvl(substr(pk_csf.fkg_cnpj_ou_cpf_empresa(en_empresa_id => gn_empresa_id), 1, 14), ' '), 14, ' ');
      gl_conteudo := gl_conteudo || rpad(nvl(substr(pk_csf.fkg_nome_pessoa_id(en_pessoa_id => rec.pessoa_id), 1, 50), ' '), 50, ' ');
      gl_conteudo := gl_conteudo || rpad(nvl(rec.serie, ' '), 6, ' ');
      gl_conteudo := gl_conteudo || lpad(nvl(rec.nro_nf, 0), 9, 0); --Número de identificação da nota fiscal
      gl_conteudo := gl_conteudo || lpad(nvl(rec.nro_nf, 0), 9, 0); --Número de identificação da nota fiscal
      gl_conteudo := gl_conteudo || to_char(rec.dt_emiss,'ddmmyyyy');
      gl_conteudo := gl_conteudo || 'N';
      gl_conteudo := gl_conteudo || 'N';
      gl_conteudo := gl_conteudo || lpad(nvl(rec.vl_item_bruto * 100, 0), 15, 0);
      --
      vn_fase := 6;
      --
      if vn_ibge = 4216602 then
         gl_conteudo := gl_conteudo || 'D';
      elsif vn_ibge <> 4216602 then
         gl_conteudo := gl_conteudo || 'F';
      elsif vn_estrangeiro = 2 then
         gl_conteudo := gl_conteudo || 'E';
      end if;
      --
      vn_fase := 7;
      --
      if vn_estrangeiro = 2 then
         gl_conteudo := gl_conteudo || rpad(' ', 7, ' ');
      else
         gl_conteudo := gl_conteudo || rpad(nvl(vn_ibge, 0), 7, 0);
      end if;
      --
      vn_fase := 8;
      --
      if nvl(vv_simpl_nac,'0') = '1' then
         gl_conteudo := gl_conteudo || rpad('S',1,' '); -- Enquadramento no Simples Nacional do Tomador de Serviços
      else
         gl_conteudo := gl_conteudo || rpad('N',1,' ');
      end if;
      --
      vn_fase := 9;
      --
      gl_conteudo := gl_conteudo || rpad(nvl(vv_motivo, ' '), 512, ' ');
      --
      vn_fase := 10;
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
      vn_fase := 11;
      --
      begin
         --
         vn_aliq_iss := null;
         --
         select ii.aliq_apli
           into vn_aliq_iss
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and ii.itemnf_id      = inf.id
            and ii.dm_tipo        = 1 -- Retenção
            and ti.id             = ii.tipoimp_id
            and ti.cd             = '6'; -- ISS
      exception
         when others then
            vn_aliq_iss := null;
      end;
      --
      vn_fase := 12;
      --
      --Registro tipo 3 - serviços
      --
      gl_conteudo := 3;
      gl_conteudo := gl_conteudo || lpad(nvl(rec.cd_lista_serv, 0), 7, 0); --Código do serviço prestado
      gl_conteudo := gl_conteudo || lpad(nvl(rec.vl_item_bruto * 100, 0), 15, 0);
      --
      vn_fase := 13;
      --
      if vn_ibge is null then
         gl_conteudo := gl_conteudo || lpad(' ', 7, ' ');
      else
         gl_conteudo := gl_conteudo || lpad(vn_ibge, 7, 0);
      end if;
      --
      vn_fase := 14;
      --
      if vn_aliq_iss is null then
         gl_conteudo := gl_conteudo || lpad(' ', 5, ' ');-- Alíquota de ISS
      else
         gl_conteudo := gl_conteudo || lpad(replace(pk_csf.fkg_formata_num(vn_aliq_iss, '99D99'), ',', '.'), 5, 0);-- Alíquota de ISS
      end if;
      --
      vn_fase := 15;
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
   --
   end loop;
   --
exception
   when others then
      --
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_4216602 fase ('||vn_fase||'): '||sqlerrm);
      --
end pkb_gera_arq_cid_4216602;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Louveira / SP
procedure pkb_gera_arq_cid_3527306 is
   --
   vn_fase             number := 0;
   --
   vv_indicador        varchar2(1) := null;
   vn_estrangeiro      pessoa.dm_tipo_pessoa%type;
   vn_ibge             cidade.ibge_cidade%type;
   vv_nome             pessoa.nome%type;
   vn_cep              pessoa.cep%type;
   vv_lograd           pessoa.lograd%type;
   vv_compl            pessoa.compl%type;
   vv_nro              pessoa.nro%type;
   vv_bairro           pessoa.bairro%type;
   vv_descr_cid        cidade.descr%type;
   vv_sg_estado        estado.sigla_estado%type;
   vv_im               juridica.im%type;
   vv_ie               juridica.ie%type;
   vv_tipo_log         varchar2(5) := null;
   vv_titulo_log       varchar2(5) := null;
   vv_local_prest      varchar2(1) := null;
   vv_aliq             varchar2(5) := null;
   --
   cursor c_nfs is
   select nf.id         notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss) dt_emiss
        , nf.pessoa_id
        , nf.empresa_id
        , ncs.dm_nat_oper
        , sum(inf.vl_item_bruto)  vl_item_bruto
        , inf.cd_lista_serv
        , inf.descr_item
        , inf.cidade_ibge
        , nft.vl_total_nf
        , nft.vl_ret_iss
        , nfc.nro_fat
        , ics.cidade_id
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , nf_compl_serv  ncs
        , item_nota_fiscal inf
        , itemnf_compl_serv ics
        , nota_fiscal_total nft
        , nota_fiscal_cobr nfc
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id
      and nf.id              = ncs.notafiscal_id (+)
      and nf.id              = inf.notafiscal_id
      and inf.id             = ics.itemnf_id (+)
      and nft.notafiscal_id  = nf.id
      and nfc.notafiscal_id  = nf.id
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
 group by nf.id         
        , nf.nro_nf
        , nf.serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss) 
        , nf.pessoa_id
        , nf.empresa_id
        , ncs.dm_nat_oper
        , inf.cd_lista_serv
        , inf.descr_item
        , inf.cidade_ibge
        , nft.vl_total_nf
        , nft.vl_ret_iss
        , nfc.nro_fat
        , ics.cidade_id;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_nfs loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_fase := 2;
      --
      begin
         --
         select p.dm_tipo_pessoa
           into vn_estrangeiro
           from pessoa p
          where p.id = rec.pessoa_id;
         --
      exception
         when others then
            vn_estrangeiro := null;
      end;
      --
      vn_fase := 3;
      --
       begin
         --
        select cid.ibge_cidade
          into vn_ibge
          from cidade cid
             , pessoa pe
         where cid.id  = pe.cidade_id
           and pe.id   = rec.pessoa_id;
         --
      exception
         when others then
            --
            vn_ibge := null;
            --
      end;
      --
      vn_fase := 4;
      --
      begin
         select p.nome
              , p.cep
              , p.lograd
              , p.compl
              , p.nro
              , p.bairro
              , c.descr
              , e.sigla_estado
           into vv_nome
              , vn_cep
              , vv_lograd
              , vv_compl
              , vv_nro
              , vv_bairro
              , vv_descr_cid
              , vv_sg_estado
           from pessoa p
              , fisica f
              , juridica j
              , cidade c
              , estado e
          where p.id           = rec.pessoa_id
            and f.pessoa_id(+) = p.id 
            and j.pessoa_id(+) = p.id 
            and p.cidade_id    = c.id
            and c.estado_id    = e.id;
      exception
         when others then
            vv_nome       := null;
            vn_cep        := null;
            vv_lograd     := null;
            vv_compl      := null;
            vv_nro        := null;
            vv_bairro     := null;
            vv_descr_cid  := null;
            vv_sg_estado  := null;

      end;
      --
      vn_fase := 5;
      --
      vv_im := pk_csf.fkg_inscr_mun_pessoa ( en_pessoa_id => rec.pessoa_id );
      --
      vn_fase := 6;
      --
      vv_ie := pk_csf.fkg_ie_pessoa_id ( en_pessoa_id => rec.pessoa_id );
      --
      vn_fase := 7;
      --
      gl_conteudo := rpad(nvl(vv_indicador, ' '), 1, ' ');
      gl_conteudo := gl_conteudo || lpad(nvl(rec.nro_nf, 0), 10, 0); --Número de identificação da nota fiscal
      gl_conteudo := gl_conteudo || rpad(nvl(rec.serie, ' '), 10, ' ');
      gl_conteudo := gl_conteudo || to_char(rec.dt_emiss,'dd/mm/yyyy');
      gl_conteudo := gl_conteudo || 1;
      gl_conteudo := gl_conteudo || lpad(to_char(nvl(rec.vl_item_bruto,0) * 100), 12, 0);
      --
      if rec.cd_lista_serv is not null then  --Código do serviço prestado
         gl_conteudo := gl_conteudo || lpad(rec.cd_lista_serv, 10, 0);
      else
         gl_conteudo := gl_conteudo || lpad(' ', 10, ' ');
      end if;
      --
      vn_fase := 8;
      --
      if vn_estrangeiro = 0 then
         gl_conteudo := gl_conteudo || 1;
      elsif vn_estrangeiro = 1 then 
         gl_conteudo := gl_conteudo || 2;
      end if;
      --
      vn_fase := 9;
      --
      if vn_ibge = 3527306 then
         gl_conteudo := gl_conteudo || 'S';
      else
         gl_conteudo := gl_conteudo || 'N';
      end if;
      --
      vn_fase := 10;
      --
      gl_conteudo := gl_conteudo || rpad(nvl(vv_nome, ' '), 100, ' ');
      gl_conteudo := gl_conteudo || lpad(nvl(substr(vv_im, 1, 10),0), 10, 0);
      gl_conteudo := gl_conteudo || lpad(nvl(substr(vv_im, 11, 2),0), 2, 0);
      gl_conteudo := gl_conteudo || lpad(pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => rec.pessoa_id), 14, 0);
      --
      vn_fase := 11;
      --
      if vv_ie = 'ISENTO' then
         gl_conteudo := gl_conteudo || 'S';
      else
         gl_conteudo := gl_conteudo || 'N';
      end if;
      --
      vn_fase := 12;
      --
      gl_conteudo := gl_conteudo || lpad(nvl(vv_ie, '0'), 15, '0');
      gl_conteudo := gl_conteudo || lpad(nvl(vn_cep, 0), 8, 0);
      gl_conteudo := gl_conteudo || rpad(nvl(vv_tipo_log, ' '), 5, ' ');
      gl_conteudo := gl_conteudo || rpad(nvl(vv_titulo_log, ' '), 5, ' ');
      gl_conteudo := gl_conteudo || rpad(nvl(vv_lograd, ' '), 50, ' ');
      gl_conteudo := gl_conteudo || rpad(nvl(vv_compl, ' '), 40, ' ');
      gl_conteudo := gl_conteudo || rpad(nvl(vv_nro, ' '), 10, ' ');
      gl_conteudo := gl_conteudo || rpad(nvl(vv_bairro, ' '), 50, ' ');
      gl_conteudo := gl_conteudo || rpad(nvl(vv_sg_estado, ' '), 2, ' ');
      gl_conteudo := gl_conteudo || rpad(nvl(vv_descr_cid, ' '), 50, ' ');
      gl_conteudo := gl_conteudo || rpad(nvl(vv_local_prest, ' '), 1, ' ');
      gl_conteudo := gl_conteudo || 'N';
      gl_conteudo := gl_conteudo || lpad(replace(pk_csf.fkg_formata_num(nvl(vv_aliq, 0), '99D99'), ',', '.'), 5, 0);
      --
      --
      vn_fase := 13;
      --
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
   end loop;
   --
exception
   when others then
      --
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_3527306 fase ('||vn_fase||'): '||sqlerrm);
      --
end pkb_gera_arq_cid_3527306;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Nova Lima / MG
procedure pkb_gera_arq_cid_3144805 is
   -- Variables
   vn_fase        number;
   vv_branco_005  varchar2(5)   := lpad(' ',   5, ' ');
   vv_branco_006  varchar2(6)   := lpad(' ',   6, ' ');
   vv_branco_050  varchar2(50)  := lpad(' ',  50, ' ');
   vv_branco_151  varchar2(151) := lpad(' ', 151, ' ');
   vv_branco_174  varchar2(174) := lpad(' ', 174, ' ');
   vv_branco_294  varchar2(294) := lpad(' ', 294, ' ');
   vn_zero_04     varchar2(4)   := lpad('0',   4, '0');
   vn_sequencial  number        := 0;
   vn_vl_retido   imp_itemnf.vl_imp_trib%type;
   vv_tipo_lancto varchar2(1);
   --

   -- Cursors
   cursor c_nfs is
   select nf.id                                             notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nvl2(ncs.dt_exe_serv, nf.dt_sai_ent, nf.dt_emiss) dt_emiss
        , nf.pessoa_id                                      tomador_pessoa_id
        , nf.empresa_id
        , ncs.dm_nat_oper
        , (select sum(inf.vl_item_bruto) 
              from item_nota_fiscal inf 
           where inf.notafiscal_id = nf.id)                 vl_item_bruto
     from nota_fiscal     nf
        , mod_fiscal      mf
        , empresa          e
        , pessoa           p
        , nf_compl_serv  ncs
    where mf.id                 = nf.modfiscal_id
      and e.id                  = nf.empresa_id
      and nf.empresa_id         = gn_empresa_id
      and p.id                  = e.pessoa_id
      and ncs.notafiscal_id (+) = nf.id
      --
      and nf.dm_ind_emit        = gn_dm_ind_emit
      and p.cidade_id           = gn_cidade_id
      and nf.dm_st_proc         = 4
      and mf.cod_mod            in ('99', '55') -- Servicos
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
      and (
            (nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)                                             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)                                         or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)            or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
          )      
   order by nf.id;
   --
begin
   --
   vn_fase := 1;
   --
   -- Header do Arquivo --------------------------------------------------
   gl_conteudo := '0';
   gl_conteudo := gl_conteudo || to_char(sysdate,'ddmmyyyy');
   gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_inscr_mun_empresa ( en_empresa_id => gn_empresa_id ), '0'), 10, '0'); -- Inscrição Municipal do Contribuinte
   gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => gn_empresa_id ), 0), 14, 0);   -- CNPJ/CPF do Contribuinte 
   gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_nome_empresa(gn_empresa_id), ' '), 58, ' ');                          -- Nome do Contribuinte
   gl_conteudo := gl_conteudo || '00001';                                                                                  -- Sequencial de Arquivo
   gl_conteudo := gl_conteudo || '0202';                                                                                   -- Versão do Arquivo
   gl_conteudo := gl_conteudo || 'T';                                                                                      -- Produção: se ‘T’ indica que o arquivo é apenas para teste
   gl_conteudo := gl_conteudo || '          ISSDigital';                                                                   -- Nome do Sistema
   gl_conteudo := gl_conteudo || vv_branco_174;                                                                            -- Brancos
   gl_conteudo := gl_conteudo || '00001';                                                                                  -- Sequencial de registro
   --   
   vn_sequencial := vn_sequencial + 1;
   --
   --
   vn_fase := 2;
   --  
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   --
   vn_fase := 3;
   --  
   -- Cursor Principal - Notas Fiscais de Serviços Tomados
   for rec in c_nfs loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_sequencial := vn_sequencial + 1;
      --
      vn_fase := 4;
      --      
      -- Tipo de Lançamento - T = Tributada / R = Retida / I = Isenta / N = Não Retida / C = Cancelada / A = Anulada / O = Recolhida em outro município 
      vv_tipo_lancto := ' ';
      if rec.dm_nat_oper = 1 then
         vv_tipo_lancto := 'T';
      elsif rec.dm_nat_oper = 2 then
         vv_tipo_lancto := 'O';
      elsif rec.dm_nat_oper in (3,8) then
         vv_tipo_lancto := 'I';
      elsif rec.dm_nat_oper = 4 then
         vv_tipo_lancto := 'C';
      elsif rec.dm_nat_oper in (5, 6) then
         vv_tipo_lancto := 'A';
      else
         vv_tipo_lancto := 'T';
      end if;
 
      --
      vn_fase := 5;
      -- 
      -- Checa se tem valor Retido para setar o tipo de lançamento
      begin
         vn_vl_retido := 0;
         select nvl(sum(ii.vl_imp_trib),0)
           into vn_vl_retido
           from item_nota_fiscal it
              , imp_itemnf       ii
              , tipo_imposto     ti
          where it.notafiscal_id = rec.notafiscal_id
            and ii.itemnf_id     = it.id
            and ii.dm_tipo       = 1 -- Imposto Retido
            and ti.id            = ii.tipoimp_id
            and ti.cd            = '6'; -- ISS
      exception
         when others then
            vn_vl_retido := 0;
      end;
      --
      if nvl(vn_vl_retido, 0) > 0 then
         vv_tipo_lancto := 'R';
      end if;  
      --
      vn_fase := 6;
      --  
      -- Detalhe do Arquivo --------------------------------------------------
      gl_conteudo := '1';                                                                                                          -- Identificador de Detalhe
      gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_inscr_mun_pessoa(en_pessoa_id => rec.tomador_pessoa_id ), '0'), 10, '0');  -- Inscrição Municipal do Prestador/Tomador
      gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => rec.tomador_pessoa_id ), 0), 14, 0);     -- CNPJ/CPF do Prestador/Tomador 
      gl_conteudo := gl_conteudo || 'P';                                                                                           -- Enquadramento do Contribuinte P = Prestador / T = Tomador
      gl_conteudo := gl_conteudo || to_char(rec.dt_emiss, 'yyyymm');                                                               -- Competência
      gl_conteudo := gl_conteudo || lpad(nvl(rec.nro_nf, 0), 8, 0);                                                                -- Nota Fiscal Inicial
      gl_conteudo := gl_conteudo || lpad(nvl(rec.serie, ' '), 5, ' ');                                                             -- Série
      gl_conteudo := gl_conteudo || lpad(nvl(rec.nro_nf, 0), 8, 0);                                                                -- Nota Fiscal Final
      gl_conteudo := gl_conteudo || to_char(rec.dt_emiss, 'dd');                                                                   -- Dia
      gl_conteudo := gl_conteudo || vv_tipo_lancto;                                                                                -- Tipo de Lançamento
      gl_conteudo := gl_conteudo || lpad(nvl(rec.vl_item_bruto, 0), 12, 0);                                                        -- Valor da Nota Fiscal
      gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkb_retorna_cnae(gn_empresa_id), 0), 9, 0);                                    -- Atividade Cadastrada na Prefeitura
      gl_conteudo := gl_conteudo || vv_branco_005;                                                                                 -- Código da Obra
      gl_conteudo := gl_conteudo || 'N';                                                                                           -- Tipo de Escrituração
      gl_conteudo := gl_conteudo || 'A';                                                                                           -- Status Retorno
      gl_conteudo := gl_conteudo || vv_branco_050;                                                                                 -- Mensagem Retorno
      gl_conteudo := gl_conteudo || vv_branco_006;                                                                                 -- Numero da Guia Avulsa
      gl_conteudo := gl_conteudo || vn_zero_04;                                                                                    -- Alíquota ref. ao Super Simples quando for Optante
      gl_conteudo := gl_conteudo || vv_branco_151;                                                                                 -- Brancos
      gl_conteudo := gl_conteudo || lpad(vn_sequencial, 5, '0');                                                                   -- Sequencial do Registro 
      --
      --
      vn_fase := 7;
      --  
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
   end loop;   
   --
   -- Trailer do Arquivo --------------------------------------------------
   --
   vn_sequencial := vn_sequencial + 1;
   --
   --
   vn_fase := 8;
   --  
   gl_conteudo := '9';                                                                                      -- Identificador do Trailer
   gl_conteudo := gl_conteudo || vv_branco_294;                                                                            -- Brancos
   gl_conteudo := gl_conteudo || lpad(to_char(vn_sequencial), 5, '0');                                                     -- Sequencial de registro
   --
   --
   vn_fase := 9;
   --  
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
exception
   when others then
      --
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_3144805 fase ('||vn_fase||'): '||sqlerrm);
      --
end pkb_gera_arq_cid_3144805;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço Tomados de Cuiabá / MT
procedure pkb_gera_arq_cid_5103403 is
--
--
   --
   vn_fase                     number := 0;
   vn_qtde_linhas              number := 0;
   --
   vv_cpf_cnpj                 varchar2(14);
   vv_nome                     pessoa.nome%type;
   vn_cep                      pessoa.cep%type;
   vv_endereco                 pessoa.lograd%type;
   vn_numero                   pessoa.nro%type;
   vv_bairro                   pessoa.bairro%type;
   vv_cidade                   cidade.descr%type;
   vv_estado                   estado.sigla_estado%type;
   vn_cod_area                 pessoa.fone%type;
   --
   -- Dados da pessoa_id
   cursor c_pessoa (en_pessoa_id pessoa.id%type) is
      select pe.nome
           , pe.lograd
           , pe.nro
           , pe.compl
           , pe.bairro
           , ci.ibge_cidade
           , ci.descr
           , es.sigla_estado
           , pe.cep
           , pe.email
           , pe.fone
        from pessoa   pe
           , cidade   ci
           , estado   es
       where pe.id = en_pessoa_id
         and ci.id = pe.cidade_id
         and es.id = ci.estado_id;
   --
   cursor c_nfs is
      select nf.id,
             mf.cod_mod, -- Modelo
             nf.nro_nf, -- Número Documento
             sum(ii.vl_base_calc) as vl_base_calc, -- Valor Tributável
             nft.vl_total_serv, -- Valor do documento
             ii.aliq_apli, -- Alíquota
             nf.dt_emiss, -- Data de Emissão
             nf.dt_sai_ent, -- Data de Pagamento
             nf.pessoa_id pessoa_id_prest, -- id da pessoa do prestador será tratado o retorno dos dados no loop
             ii.dm_tipo, -- Imposto Retido
             -- ic.dm_trib_mun_prest, -- Tributado no município                   
             ncs.dm_nat_oper, -- Tributado no município
             nf.empresa_id  empresa_id_toma, -- tomador
             cd_lista_serv, -- Código referente ao serviço contratado
             ti.cd, -- Código do tipo de imposto
             cp.ibge_cidade cidade_ibge_emit -- Código cidade IBGE do Prestador
        from nota_fiscal       nf,
             empresa           e,
             pessoa            pt, -- pt = Pessoa Tomador
             pessoa            pp, -- pp = Pessoa Prestador
             cidade            ct, -- ct = Cidade Tomador
             cidade            cp, -- cp = Cidade Prestador
             item_nota_fiscal  inf,
             imp_itemnf        ii,
             tipo_imposto      ti,
             mod_fiscal        mf,
             nota_fiscal_total nft,
             itemnf_compl_serv ic,
             nf_compl_serv     ncs
       where e.id              = nf.empresa_id
         and pt.id             = decode(gn_dm_ind_emit, 0, nf.pessoa_id, e.pessoa_id) -- tomador
         and pp.id             = decode(gn_dm_ind_emit, 0, e.pessoa_id, nf.pessoa_id) -- prestador
         and ct.id             = pt.cidade_id
         and cp.id             = pp.cidade_id
         and inf.notafiscal_id = nf.id
         and ii.itemnf_id      = inf.id
         and ti.id             = ii.tipoimp_id
         and mf.id             = nf.modfiscal_id
         and nft.notafiscal_id = nf.id
         and ic.itemnf_id      = inf.id
         and ncs.notafiscal_id = nf.id
         --
         and nf.empresa_id     = gn_empresa_id
         and nf.dm_ind_emit    = gn_dm_ind_emit -- 0 -- Emissão Própria / 1 -- Terceiro
         and pt.cidade_id      = gn_cidade_id -- Cidade do Tomador = Cuiabá
         -- 
         and ((nf.dm_ind_emit  = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
              (nf.dm_ind_emit  = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
              (nf.dm_ind_emit  = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
              (nf.dm_ind_emit  = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
         --
         and nf.dm_st_proc       = 4               -- Autorizada         
         and ti.cd               = '6'             -- ISS
         and pp.cidade_id        <> pt.cidade_id   -- Municícpio do Prestador diferente do Município do Tomador
         and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null)) -- Notas de Serviço ou Conjugada
         and nvl(nf.dm_arm_nfe_terc, 0) = 0 
         --
       group by nf.id,
                mf.cod_mod,
                nf.nro_nf,
                nft.vl_total_serv,
                ii.aliq_apli,
                nf.dt_emiss,
                nf.dt_sai_ent,
                nf.pessoa_id,
                ii.dm_tipo,
                --ic.dm_trib_mun_prest,
                ncs.dm_nat_oper,
                nf.empresa_id,
                cd_lista_serv,
                ti.cd,
                cp.ibge_cidade
       order by nf.id;

      --
begin
   --
   vn_fase := 1;
   --
   -- Cabeçalho
   -- =========
   -- Inscrição Municipal;
   -- Mês da competência;
   -- Ano da competência;
   -- Hora da geração, data da geração e nome / razão social do tomador de serviços;
   -- Código referente ao serviço contratado;
   -- A última informação do cabeçalho condiz à frase: "EXPORTACAO DECLARACAO ELETRONICA-ONLINE-NOTA CONTROL" (é necessário que seja escrito exatamente desta forma).
   --
   gl_conteudo := null;
   --
   gl_conteudo := rtrim(rpad(pk_csf.fkg_inscr_mun_empresa ( en_empresa_id => gn_empresa_id ), 7));    -- Inscrição Municipal
   gl_conteudo := gl_conteudo ||';'|| substr(to_char(gd_dt_fin,'MM'),1,2);                            -- Mês da competência
   gl_conteudo := gl_conteudo ||';'|| substr(to_char(gd_dt_fin,'RRRR'),1,4);                          -- Ano da competência
   -- Hora da geração, data da geração e nome / razão social do tomador de serviços
   gl_conteudo := gl_conteudo ||';'|| to_char(sysdate,'HH:MI') || ' ' ||to_char(sysdate,'DD/MM/RRRR')||rtrim(nvl(pk_csf.fkg_nome_empresa(gn_empresa_id),' '));
   gl_conteudo := gl_conteudo ||';'|| '1';                                                            -- Código referente ao serviço contratado
   --
   gl_conteudo := gl_conteudo ||';'|| 'EXPORTACAO DECLARACAO ELETRONICA-ONLINE-NOTA CONTROL' ||';';
   --
   vn_qtde_linhas := 0;
   --
   vn_fase := 2;
   --
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_fase := 3;
   --
   for rec_nfs in c_nfs loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_fase := 4;
      --
      -- Busca dados da pessoa_id do prestador
      for rec_pessoa in c_pessoa(rec_nfs.pessoa_id_prest) loop
         exit when c_pessoa%notfound or (c_pessoa%notfound) is null;
         --
         vv_nome     := rec_pessoa.nome;         -- Nome
         vn_cep      := rec_pessoa.cep;          -- Cep
         vv_endereco := rec_pessoa.lograd;       -- Endereço
         vn_numero   := rec_pessoa.nro;          -- Número
         vv_bairro   := rec_pessoa.bairro;       -- Bairro
         vv_cidade   := rec_pessoa.descr;        -- Cidade
         vv_estado   := rec_pessoa.sigla_estado; -- Estado
         vn_cod_area := rec_pessoa.fone;         -- Código de Área
         --
         vv_cpf_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec_nfs.pessoa_id_prest );
         --
      end loop;
      --
      vn_fase := 5;
      --
      -- Detalhe
      -- =======
      --
      vn_qtde_linhas := nvl(vn_qtde_linhas,0) + 1;
      --
      -- De-Para com tabela do Governo
      if nvl(rec_nfs.cod_mod,0) = '99' then
         gl_conteudo := '4'; -- Modelo Governo: NFS-e - Nota Fiscal de Serviço Eletrônica 
      else
         gl_conteudo := '12'; -- Modelo Governo: NFE Especial (conjugada)
      end if;
      --
      gl_conteudo := gl_conteudo ||';'|| substr(rec_nfs.nro_nf,1,20);                                    -- Número Documento
      gl_conteudo := gl_conteudo ||';'|| pk_csf.fkg_formata_num(rec_nfs.vl_base_calc, '9999999.99');     -- Valor Tributável
      gl_conteudo := gl_conteudo ||';'|| pk_csf.fkg_formata_num(rec_nfs.vl_total_serv, '9999999.99');    -- Valor do documento
      gl_conteudo := gl_conteudo ||';'|| nvl(rec_nfs.aliq_apli, 0);                                      -- Alíquota
      gl_conteudo := gl_conteudo ||';'|| substr(to_char(rec_nfs.dt_emiss,'ddmmrrrr'),1,8);               -- Data de Emissão
      gl_conteudo := gl_conteudo ||';'; -- || substr(to_char(rec_nfs.dt_sai_ent,'ddmmrrrr'),1,8);        -- Data de Pagamento
      --
      gl_conteudo := gl_conteudo ||';'|| substr(vv_cpf_cnpj,1,14);                                       -- CPF / CNPJ
      gl_conteudo := gl_conteudo ||';'|| substr(vv_nome,1,150);                                          -- Razão Social
      --
      --
      vn_fase := 6;
      --
      -- Inscrição Municipal do Prestador
      -- Regra: Se o Prestador não for de Cuiabá, não deve ser fornecido a inscrição Municipal
      if rec_nfs.cidade_ibge_emit = '5103403' then
         --
         gl_conteudo := gl_conteudo ||';'|| rtrim(rpad(pk_csf.fkg_inscr_mun_pessoa ( en_pessoa_id  => rec_nfs.pessoa_id_prest ), 7));
         --
      else
         --    
         gl_conteudo := gl_conteudo ||';';
         --
      end if;   
      --
      vn_fase := 7;
      --
      -- Se o campo COD_IMPOSTO = 6 e DM_TIPO = 1 - retornar "1" = SIM. Caso contrario retornar "0" = NÃO.
      if nvl(rec_nfs.cd,0) = 6 and rec_nfs.dm_tipo = 1 then
         gl_conteudo := gl_conteudo ||';'|| '1'; -- SIM - Imposto Retido
      else
         gl_conteudo := gl_conteudo ||';'|| '0'; -- NÃO - Imposto Retido
      end if;
      --
      vn_fase := 8;
      --
      gl_conteudo := gl_conteudo ||';'|| substr(vn_cep,1,8);        -- Cep
      gl_conteudo := gl_conteudo ||';'|| substr(vv_endereco,1,200); -- Endereço
      gl_conteudo := gl_conteudo ||';'|| substr(vn_numero,1,6);     -- Número
      gl_conteudo := gl_conteudo ||';'|| substr(vv_bairro,1,50);    -- Bairro
      gl_conteudo := gl_conteudo ||';'|| substr(vv_cidade,1,50);    -- Cidade
      gl_conteudo := gl_conteudo ||';'|| substr(vv_estado,1,2);     -- Estado
      gl_conteudo := gl_conteudo ||';'|| substr(vn_cod_area,1,2);   -- Código de Área
      --
      vn_fase := 9;
      --
      -- Tributado no município
      --if nvl(rec_nfs.dm_trib_mun_prest,0) = 1 then
      if nvl(rec_nfs.dm_nat_oper, 0) = 1 then
         gl_conteudo := gl_conteudo ||';'|| 1 ||';'; -- 1 - SIM
      else
         gl_conteudo := gl_conteudo ||';'|| 0 ||';'; -- 0 - NÃO
      end if;
      --
      vn_fase := 10;
      --
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_5103403 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_5103403;

--------------------------------------------------------------------------------------------------------------------- 
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço Tomados de Fortaleza / CE
procedure pkb_gera_arq_cid_2304400 is
--
--

  vn_fase        number := 0;
  vn_qtde_linhas number := 0;
  --
  vv_cpf_cnpj  varchar2(14);
  vv_nome      pessoa.nome%type;
  vn_cep       pessoa.cep%type;
  vv_endereco  pessoa.lograd%type;
  vv_compl     pessoa.compl%type;
  vv_fone      pessoa.fone%type;
  vv_email     pessoa.email%type;
  vn_numero    pessoa.nro%type;
  vv_bairro    pessoa.bairro%type;
  vv_cidade    cidade.descr%type;
  vv_estado    estado.sigla_estado%type;
  vn_cod_area  pessoa.fone%type;
  vv_im        juridica.im%type;
  vv_im_sc     juridica.im%type;
  vn_siscomex  pais.cod_siscomex%type;
  vv_sigla     estado.sigla_estado%type;
  vv_ibge      cidade.ibge_cidade%type;
  vv_cnae      juridica.cnae%type;
  vn_tp_pessoa pessoa.dm_tipo_pessoa%type;
  vv_aliq_apli varchar2(6);
  --  
  --
  cursor c_nfs is
    select nf.id,
           mf.cod_mod, -- Modelo
           nf.nro_nf, -- Número do Documento
           nf.serie, -- Série Número do Documento
           sum(ii.vl_base_calc) as vl_base_calc, -- Valor Tributável
           nft.vl_total_nf, -- Valor do documento
           ii.aliq_apli, -- Alíquota
           nf.dt_emiss, -- Data de Emissão
           nf.dt_sai_ent, -- Data de Pagamento
           nf.pessoa_id pessoa_id_prest, -- id da pessoa do prestador será tratado o retorno dos dados no loop
           ii.dm_tipo, -- Imposto Retido
           ic.dm_trib_mun_prest, -- Tributado no município
           nf.empresa_id empresa_id_toma, -- tomador
           cd_lista_serv, -- Código referente ao serviço contratado
           ti.cd,
           nf.modfiscal_id, -- Tipo de documento digitado
           decode(nf.dm_st_proc, 4, 1, 7, 2, nf.dm_st_proc) dm_st_proc, -- Situação do documento
           nf.inforcompdctofiscal_id,
           inf.descr_item,
           ic.dm_loc_exe_serv dm_loc_exe_serv, -- Código do país de prestação do serviço
           es.sigla_estado sigla_estado_nf, -- Sigla do estado de prestação do serviço
           inf.cidade_ibge cidade_ibge_nf, -- Código da cidade de prestação do serviço
           nc.dm_nat_oper, -- Código da natureza da operação
           nd.nro_art, -- Código ART
           --nd.nro_cno, -- Código da Obra
           nd.cod_obra, -- Código da Obra
           nft.vl_total_serv, -- Valor do serviço prestado
           nft.vl_deducao, -- Valor das deduções
           nft.vl_desc_incond, -- Descontos incondicionados
           nft.vl_desc_cond, -- Descontos condicionados
           nft.vl_outras_ret, -- Outras retenções
           nft.vl_ret_irrf, -- Valor IR
           nft.vl_ret_pis, -- Valor PIS
           nft.vl_ret_cofins, -- Valor COFINS
           nft.vl_ret_csll, -- Valor CSLL
           nft.vl_ret_prev, -- Valor INSS
           ju.im, -- Inscrição Municipal da empresa logada
           '' empenho,
           case
             when ii.dm_tipo = 0 and ii.tipoimp_id = 6 then
              0
             when ii.dm_tipo = 1 and ii.tipoimp_id = 6 then
              1
           end dm_tipo_tipoimp_id,
           '' tipo_tributacao,
           '' valor_bruto,
           '' data_pagamento,
           ic.codtribmunicipio_id
      from nota_fiscal          nf,
           empresa              e,
           pessoa               pt, -- pt = Pessoa Tomador
           pessoa               pp, -- pp = Pessoa Prestador
           pessoa               pe, -- pe = Pessoa empresa logada
           item_nota_fiscal     inf,
           imp_itemnf           ii,
           tipo_imposto         ti,
           mod_fiscal           mf,
           nota_fiscal_total    nft,
           itemnf_compl_serv    ic,
           nf_compl_serv        nc,
           nfs_det_constr_civil nd,
           cidade               c,
           estado               es,
           juridica             ju
     where e.id              = nf.empresa_id
       and pt.id               = decode(gn_dm_ind_emit, 0, nf.pessoa_id, e.pessoa_id)   -- tomador
       and pp.id               = decode(gn_dm_ind_emit, 0, e.pessoa_id, nf.pessoa_id)   -- prestador
       and inf.notafiscal_id = nf.id
       and ii.itemnf_id      = inf.id
       and ti.id             = ii.tipoimp_id
       and mf.id             = nf.modfiscal_id
       and nft.notafiscal_id = nf.id
       and ic.itemnf_id      = inf.id
       and nf.id             = nc.notafiscal_id
       and nf.id             = nd.notafiscal_id(+)
       and c.ibge_cidade     = inf.cidade_ibge
       and es.id             = c.estado_id
       --
       and nf.empresa_id     = gn_empresa_id
       and nf.dm_ind_emit    = gn_dm_ind_emit  /*0 -- Emissão Própria / 1 -- Terceiro*/
       and pt.cidade_id      = gn_cidade_id
       and ((nf.dm_ind_emit  = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
          or
            (nf.dm_ind_emit  = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
          or
            (nf.dm_ind_emit  = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
          or
            (nf.dm_ind_emit  = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
       --
       and nf.dm_st_proc     = 4 -- Autorizada         
       and ti.cd             = '6' -- ISS
       and pp.cidade_id <> pt.cidade_id -- Municícpio do Prestador diferente do Município do Tomador
       and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null)) -- Notas de Serviço ou Conjugada
       and nvl(nf.dm_arm_nfe_terc, 0) = 0
       and pe.id = e.pessoa_id
       and ju.pessoa_id = pe.id
    --
     group by nf.id,
              mf.cod_mod,
              nf.nro_nf,
              nf.serie,
              nft.vl_total_nf,
              ii.aliq_apli,
              nf.dt_emiss,
              nf.dt_sai_ent,
              nf.pessoa_id,
              ii.dm_tipo,
              ic.dm_trib_mun_prest,
              nf.empresa_id,
              cd_lista_serv,
              ti.cd,
              nf.modfiscal_id,
              nf.dm_st_proc,
              nf.inforcompdctofiscal_id,
              inf.descr_item,
              ic.dm_loc_exe_serv,
              es.sigla_estado,
              inf.cidade_ibge,
              nc.dm_nat_oper,
              nd.nro_art,
              --nd.nro_cno,
              nd.cod_obra,
              nft.vl_total_serv,
              nft.vl_deducao,
              nft.vl_desc_incond,
              nft.vl_desc_cond,
              nft.vl_outras_ret,
              nft.vl_ret_irrf,
              nft.vl_ret_pis,
              nft.vl_ret_cofins,
              nft.vl_ret_csll,
              nft.vl_ret_prev,
              ju.im,
              ii.dm_tipo,
              ii.tipoimp_id,
              ic.codtribmunicipio_id
     order by nf.id;
  --
  -- Dados da pessoa_id
  cursor c_pessoa(en_pessoa_id pessoa.id%type) is
    select decode(pe.dm_tipo_pessoa, 0, 1, 1, 2, 2, 3, pe.dm_tipo_pessoa) dm_tipo_pessoa,
           pe.nome,
           pe.lograd,
           pe.nro,
           pe.compl,
           pe.bairro,
           ci.ibge_cidade,
           ci.descr,
           es.sigla_estado,
           pe.cep,
           pe.email,
           pe.fone,
           ju.im,
           pa.cod_siscomex,
           ju.cnae
      from pessoa pe, 
           cidade ci, 
           estado es, 
           juridica ju, 
           pais pa
     where pe.id        = en_pessoa_id
       and ci.id        = pe.cidade_id
       and es.id        = ci.estado_id
       and ju.pessoa_id = pe.id
       and es.pais_id   = pa.id;
  --
begin
  --
  vn_fase := 1;
  --
  -- Cabeçalho
  -- =========
  -- Inscrição Municipal;
  -- Mês da competência;
  -- Ano da competência;
  -- Hora da geração, data da geração e nome / razão social do tomador de serviços;
  -- Código referente ao serviço contratado;
  -- A última informação do cabeçalho condiz à frase: "EXPORTACAO DECLARACAO ELETRONICA-ONLINE-NOTA CONTROL" (é necessário que seja escrito exatamente desta forma).
  --
  gl_conteudo := null;
  --
  vn_qtde_linhas := 0;
  --
  vn_fase := 2;
  --
  -- Armazena a estrutura do arquivo
  --pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
  --
  vn_fase := 3;
  --
  for rec_nfs in c_nfs loop
    exit when c_nfs%notfound or(c_nfs%notfound) is null;
    --
    vn_fase := 4;
    --
    -- Busca dados da pessoa_id do prestador
    for rec_pessoa in c_pessoa(rec_nfs.pessoa_id_prest) loop
      exit when c_pessoa%notfound or(c_pessoa%notfound) is null;
      --
      vn_tp_pessoa := rec_pessoa.dm_tipo_pessoa; -- Tipo de Pessoa (1-Pessoa Física, 2-Pessoa Jurídica, 3-Estrangeiro)
      vv_nome      := rec_pessoa.nome; -- Nome
      vn_cep       := rec_pessoa.cep; -- Cep
      vv_endereco  := rec_pessoa.lograd; -- Endereço
      vv_compl     := rec_pessoa.compl; -- Complemento do endereço
      vn_numero    := rec_pessoa.nro; -- Número
      vv_bairro    := rec_pessoa.bairro; -- Bairro
      vv_fone      := rec_pessoa.fone; -- Telefone do prestador
      vv_email     := replace(rec_pessoa.email, ';', ' '); -- E-mail do prestador
      vv_cidade    := rec_pessoa.descr; -- Cidade
      vv_estado    := rec_pessoa.sigla_estado; -- Estado
      vn_cod_area  := rec_pessoa.fone; -- Código de Área
      vv_im        := rec_pessoa.im; -- Inscrição municipal
      vn_siscomex  := rec_pessoa.cod_siscomex; -- Código do país do prestador
      vv_sigla     := rec_pessoa.sigla_estado; -- Sigla do estado
      vv_ibge      := rec_pessoa.ibge_cidade; -- IBGE da cidade
      vv_cnae      := rec_pessoa.cnae; -- Código da Classificação Nacional de Atividades
      vv_im_sc     := replace(replace(replace(rec_nfs.im, '.'), '/'), '-'); -- Inscrição municipal (Sem caracteres)
      --
      vv_cpf_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => rec_nfs.pessoa_id_prest);
      --
    end loop;
    --
    vn_fase := 5;
    --
    vv_aliq_apli := ltrim(rtrim(to_char((trunc(rec_nfs.aliq_apli*100)),'999000'))); -- aliquota formatada "000"
    --
    vn_qtde_linhas := nvl(vn_qtde_linhas, 0) + 1;
    --
    --
    gl_conteudo := '2.0';
    gl_conteudo := gl_conteudo || ';' || 2;
    gl_conteudo := gl_conteudo || ';' || vn_tp_pessoa;
    gl_conteudo := gl_conteudo || ';' || vv_cpf_cnpj;
    gl_conteudo := gl_conteudo || ';' || vv_nome;
    if vv_ibge = '2304400' then
      gl_conteudo := gl_conteudo || ';' || vv_im;
    else
      gl_conteudo := gl_conteudo || ';';
    end if;
    gl_conteudo := gl_conteudo || ';' || vn_siscomex;
    gl_conteudo := gl_conteudo || ';' || vv_sigla;
    gl_conteudo := gl_conteudo || ';' || vv_ibge;
    gl_conteudo := gl_conteudo || ';' || vn_cep;
    gl_conteudo := gl_conteudo || ';' || vv_endereco;
    gl_conteudo := gl_conteudo || ';' || vn_numero;
    gl_conteudo := gl_conteudo || ';' || vv_compl;
    gl_conteudo := gl_conteudo || ';' || vv_bairro;
    gl_conteudo := gl_conteudo || ';' || vv_fone;
    gl_conteudo := gl_conteudo || ';' || vv_email;
    if vv_ibge = '2304400' and rec_nfs.cod_mod = '99' then
      gl_conteudo := gl_conteudo || ';' || 12;
    elsif vv_ibge <> '2304400' and rec_nfs.cod_mod = '99' then
      gl_conteudo := gl_conteudo || ';' || 7;
    elsif vv_ibge = '2304400' and rec_nfs.cod_mod = 'ND' then
      gl_conteudo := gl_conteudo || ';' || 4;
    elsif vv_ibge <> '2304400' and rec_nfs.cod_mod = 'ND' then
      gl_conteudo := gl_conteudo || ';' || 10;
    end if;
    gl_conteudo := gl_conteudo || ';' || substr(rec_nfs.nro_nf, 1, 20);
    gl_conteudo := gl_conteudo || ';' || rec_nfs.serie;
    gl_conteudo := gl_conteudo || ';' || to_char(rec_nfs.dt_emiss, 'DD/MM/RRRR');
    gl_conteudo := gl_conteudo || ';' || rec_nfs.dm_st_proc;
    gl_conteudo := gl_conteudo || ';' || to_char(rec_nfs.dt_emiss, 'MM');
    gl_conteudo := gl_conteudo || ';' || to_char(rec_nfs.dt_emiss, 'RRRR');
    --gl_conteudo := gl_conteudo || ';' || vv_cnae;
    gl_conteudo := gl_conteudo || ';' || replace(replace(replace(replace(replace(pk_csf.fkg_codtribmunicipio_cd(rec_nfs.codtribmunicipio_id), '-',''),'.',''),'/',''),'\',''),'_','');
    gl_conteudo := gl_conteudo || ';' || vv_aliq_apli;
    gl_conteudo := gl_conteudo || ';' || rec_nfs.descr_item;
    if rec_nfs.dm_loc_exe_serv = 0 then
      gl_conteudo := gl_conteudo || ';' || 1058;
    else
      gl_conteudo := gl_conteudo || ';' || vn_siscomex;
    end if;
    gl_conteudo := gl_conteudo || ';' || rec_nfs.sigla_estado_nf;
    gl_conteudo := gl_conteudo || ';' || rec_nfs.cidade_ibge_nf;
    gl_conteudo := gl_conteudo || ';' || rec_nfs.dm_nat_oper;
    gl_conteudo := gl_conteudo || ';' || rec_nfs.nro_art;
    --gl_conteudo := gl_conteudo || ';' || rec_nfs.nro_cno;
    gl_conteudo := gl_conteudo || ';' || rec_nfs.cod_obra;
    gl_conteudo := gl_conteudo || ';' || replace(pk_csf.fkg_formata_num(en_num => rec_nfs.vl_total_serv, ev_mascara => '999999999.99'), '.');
    gl_conteudo := gl_conteudo || ';' || replace(pk_csf.fkg_formata_num(en_num => rec_nfs.vl_deducao, ev_mascara => '999999999.99'), '.');
    gl_conteudo := gl_conteudo || ';' || replace(pk_csf.fkg_formata_num(en_num => rec_nfs.vl_desc_incond, ev_mascara => '999999999.99'), '.');
    gl_conteudo := gl_conteudo || ';' || replace(pk_csf.fkg_formata_num(en_num => rec_nfs.vl_desc_cond, ev_mascara => '999999999.99'), '.');
    gl_conteudo := gl_conteudo || ';' || replace(pk_csf.fkg_formata_num(en_num => rec_nfs.vl_outras_ret, ev_mascara => '999999999.99'), '.');
    gl_conteudo := gl_conteudo || ';' || replace(pk_csf.fkg_formata_num(en_num => rec_nfs.vl_ret_irrf, ev_mascara => '999999999.99'), '.');
    gl_conteudo := gl_conteudo || ';' || replace(pk_csf.fkg_formata_num(en_num => rec_nfs.vl_ret_pis, ev_mascara => '999999999.99'), '.');
    gl_conteudo := gl_conteudo || ';' || replace(pk_csf.fkg_formata_num(en_num => rec_nfs.vl_ret_cofins, ev_mascara => '999999999.99'), '.');
    gl_conteudo := gl_conteudo || ';' || replace(pk_csf.fkg_formata_num(en_num => rec_nfs.vl_ret_csll, ev_mascara => '999999999.99'), '.');
    gl_conteudo := gl_conteudo || ';' || replace(pk_csf.fkg_formata_num(en_num => rec_nfs.vl_ret_prev, ev_mascara => '999999999.99'), '.');
    gl_conteudo := gl_conteudo || ';' || rec_nfs.empenho;    
    gl_conteudo := gl_conteudo || ';' || rec_nfs.dm_tipo_tipoimp_id;
    gl_conteudo := gl_conteudo || ';' || rec_nfs.tipo_tributacao;
    gl_conteudo := gl_conteudo || ';' || vv_im_sc;
    -- os campos somente devem ser preenchidos por contribuintes do Regime de Caixa
    --gl_conteudo := gl_conteudo || ';' || rec_nfs.valor_bruto;
    --gl_conteudo := gl_conteudo || ';' || rec_nfs.data_pagamento;
    --
    vn_fase := 6;
      --
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
      --
   end loop;
  --
exception
  when others then
    raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_2304400 fase (' || vn_fase || '): ' || sqlerrm);
end pkb_gera_arq_cid_2304400;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço Tomados de Londrina / PR
procedure pkb_gera_arq_cid_4113700 is
--
--
  vn_fase                     number := 0;
  vn_qtde_linhas              number := 0;
  --
  vv_cpf_cnpj                 varchar2(14);
  --
  cursor c_nfs is
    select nf.nro_nf, -- Número do Documento
           nf.serie, -- Série Número do Documento 
           '' sub,
           to_char(nf.dt_sai_ent, 'DD') dt_sai_ent, -- Dia de Emissão (Data de Pagamento)
           inf.cd_lista_serv, -- Código do serviço
           decode(nc.dm_nat_oper,
                  1, 'tt',
                  2, 'nt',
                  3, 'is',
                  4, 'im',
                  nc.dm_nat_oper) dm_nat_oper, -- Situação da Nota
           inf.vl_item_bruto, -- Valor do Serviço
           (select j.im 
              from juridica j 
             where j.pessoa_id = pt.id) IM, -- CMC do Tomador de Serviços
           case
             when mf.cod_mod = '55' then
              'T'
             when mf.cod_mod = '99' then
              'E'
             when mf.cod_mod = 'ND' then
              nvl('R', 'O')
           end modfiscal_id, -- Tipo Nota Fiscal
           case
             when tp.cd = '1' and vtp.cd = '1' and ti.cd = 6 then
              ii.aliq_apli
           end aliquota, -- Aliquota Super-Simples
           'C' lancamento, -- Lançamento Concluído
           '' centro_custo,
           '' cmc,
           sum(ii.vl_base_calc) vl_base_calc,
           nf.pessoa_id pessoa_id_prest
      from nota_fiscal       nf,
           item_nota_fiscal  inf,
           nf_compl_serv     nc,
           itemnf_compl_serv ic,
           imp_itemnf        ii,
           tipo_imposto      ti,
           mod_fiscal        mf,
           pessoa            pt, -- Pessoa Tomador
           pessoa            pp, -- Pessoa Prestador
           empresa           e,
           tipo_param        tp,
           valor_tipo_param  vtp,
           pessoa_tipo_param ptp
     where nf.id             = inf.notafiscal_id
       and nf.id             = nc.notafiscal_id
       and ic.itemnf_id      = inf.id
       and pt.id             = nf.pessoa_id -- Tomador
       and pp.id             = e.pessoa_id -- Prestador 
       and e.id              = nf.empresa_id
       and mf.id             = nf.modfiscal_id
       and ii.itemnf_id      = inf.id
       and ii.tipoimp_id     = ti.id
       and pp.id             = ptp.pessoa_id
       and tp.id             = ptp.tipoparam_id
       and tp.id             = vtp.tipoparam_id
       and vtp.cd            = '1'
       --
       and nf.empresa_id     = gn_empresa_id
       and nf.dm_ind_emit    = gn_dm_ind_emit  /*0 -- Emissão Própria / 1 -- Terceiro*/
       and pp.cidade_id      = gn_cidade_id    -- fecha na cidade do prestador
       and ((nf.dm_ind_emit  = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
          or
            (nf.dm_ind_emit  = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
          or
            (nf.dm_ind_emit  = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
          or
            (nf.dm_ind_emit  = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
       --
       and nf.dm_st_proc     = 4 -- Autorizada         
       and ti.cd             = '6' -- ISS
       and pp.cidade_id <> pt.cidade_id -- Municícpio do Prestador diferente do Município do Tomador
       and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null)) -- Notas de Serviço ou Conjugada
       and nvl(nf.dm_arm_nfe_terc, 0) = 0
     group by nf.nro_nf,
              nf.serie,
              nf.dt_sai_ent,
              inf.cd_lista_serv,
              nc.dm_nat_oper,
              inf.vl_item_bruto,
              pt.id,
              mf.cod_mod,
              nf.pessoa_id,
              tp.cd,
              vtp.cd,
              ti.cd,
              ii.aliq_apli;

begin

  vn_fase := 1;
  --
  -- Cabeçalho
  -- =========
  -- Inscrição Municipal;
  -- Mês da competência;
  -- Ano da competência;
  -- Hora da geração, data da geração e nome / razão social do tomador de serviços;
  -- Código referente ao serviço contratado;
  -- A última informação do cabeçalho condiz à frase: "EXPORTACAO DECLARACAO ELETRONICA-ONLINE-NOTA CONTROL" (é necessário que seja escrito exatamente desta forma).
  --
  gl_conteudo := null;
  
  vn_qtde_linhas := 0;
  
  vn_fase := 2;
   
  for rec_nfs in c_nfs loop
    exit when c_nfs%notfound or(c_nfs%notfound) is null;
    
    vn_fase     := 3; 
    
    vv_cpf_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => rec_nfs.pessoa_id_prest);
    
    gl_conteudo := vv_cpf_cnpj;
    gl_conteudo := gl_conteudo || ';' || rec_nfs.nro_nf;
    gl_conteudo := gl_conteudo || ';' || rec_nfs.serie;
    gl_conteudo := gl_conteudo || ';' || rec_nfs.sub;
    gl_conteudo := gl_conteudo || ';' || rec_nfs.dt_sai_ent;
    gl_conteudo := gl_conteudo || ';' || rec_nfs.cd_lista_serv;
    gl_conteudo := gl_conteudo || ';' || rec_nfs.dm_nat_oper;
    gl_conteudo := gl_conteudo || ';' || rec_nfs.vl_item_bruto;
    gl_conteudo := gl_conteudo || ';' || rec_nfs.im;
    gl_conteudo := gl_conteudo || ';' || rec_nfs.modfiscal_id;
    gl_conteudo := gl_conteudo || ';' || rec_nfs.aliquota;
    gl_conteudo := gl_conteudo || ';' || rec_nfs.lancamento;
    gl_conteudo := gl_conteudo || ';' || rec_nfs.vl_base_calc;
    gl_conteudo := gl_conteudo || ';' || rec_nfs.centro_custo;
    gl_conteudo := gl_conteudo || ';' || rec_nfs.cmc;
  
    vn_qtde_linhas := nvl(vn_qtde_linhas, 0) + 1;
  
    vn_fase := 4;
    
    -- Armazena a estrutura do arquivo
    pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
    
  end loop;
  
  vn_fase := 5;
  
exception
  when others then
    raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_4113700 fase (' || vn_fase || '): ' || sqlerrm);
end pkb_gera_arq_cid_4113700;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço Tomados de Maracanaú / CE
procedure pkb_gera_arq_cid_2307650 is
--
--
   vn_fase                     number := 0;
   vn_qtde_linhas              number := 0;
   --
   vv_cpf_cnpj                 varchar2(14);
   vv_nome                     pessoa.nome%type;
   vn_cep                      pessoa.cep%type;
   vv_endereco                 pessoa.lograd%type;
   vn_numero                   pessoa.nro%type;
   vv_bairro                   pessoa.bairro%type;
   vv_cidade                   cidade.descr%type;
   vv_estado                   estado.sigla_estado%type;
   vn_fone                     pessoa.fone%type;
   vv_email                    pessoa.email%type;
   vv_compl                    pessoa.compl%type;
   vv_pais                     pais.descr%type;
   vv_ie                       juridica.ie%type;
   vn_tpprest                  number(1);
   --
   -- Dados da pessoa_id
   cursor c_pessoa (en_pessoa_id pessoa.id%type) is
      select pe.nome
           , pe.lograd
           , pe.nro
           , pe.compl
           , pe.bairro
           , ci.descr
           , es.sigla_estado
           , pe.cep
           , pe.email
           , pe.fone
           , pa.descr pais_descr
           , ju.ie
           , pe.dm_tipo_pessoa
           , ci.ibge_cidade
        from pessoa   pe
           , cidade   ci
           , estado   es
           , pais     pa
           , juridica ju
       where pe.id        = en_pessoa_id
         and ci.id        = pe.cidade_id
         and es.id        = ci.estado_id
         and pa.id        = pe.pais_id
         and ju.pessoa_id = pe.id;
   --
   -- Dados do tipo de prestador
   cursor c_tpprest (en_pessoa_id pessoa.id%type) is
      select tp.cd cd_tpparam
           , vt.cd cd_vlrtpparam
        from pessoa_tipo_param pt
           , tipo_param        tp
           , valor_tipo_param  vt
       where pt.pessoa_id         = en_pessoa_id
         and tp.id                = pt.tipoparam_id
         and vt.tipoparam_id      = tp.id
         and pt.valortipoparam_id = vt.id;
   --
   cursor c_nfs is
      select mf.cod_mod
           , nf.nro_nf
           , nf.serie
           , nft.vl_base_calc_iss
           , nft.vl_total_nf
           , ii.aliq_apli
           , nf.dt_emiss
           , nf.dt_sai_ent
           , nf.pessoa_id  pessoa_id_prest
           , ii.dm_tipo
           , ic.dm_trib_mun_prest
           , nf.empresa_id empresa_id_toma
           , nf.nat_oper
           , ti.cd
           , inf.cd_lista_serv
           , inf.vl_item_bruto
           , ic.vl_deducao
           , ic.vl_desc_incondicionado
           , inf.cidade_ibge
           , nd.cod_obra -- Código da Obra
        from nota_fiscal       nf
           , empresa           em
           , pessoa            pe
           , item_nota_fiscal  inf
           , imp_itemnf        ii
           , tipo_imposto      ti
           , mod_fiscal        mf
           , nota_fiscal_total nft
           , itemnf_compl_serv ic
           , pessoa            pn
           , nfs_det_constr_civil nd
       where nf.empresa_id     = gn_empresa_id
         and nf.dm_ind_emit    = gn_dm_ind_emit
         and nf.dm_st_proc     = 4 -- Autorizada
         and ((nf.dm_ind_emit  = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
              (nf.dm_ind_emit  = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
              (nf.dm_ind_emit  = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
              (nf.dm_ind_emit  = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
         and em.id             = nf.empresa_id
         and pe.id             = em.pessoa_id -- prestador
         and pe.cidade_id      = gn_cidade_id -- fecha na cidade do prestador
         and inf.notafiscal_id = nf.id
         and ii.itemnf_id      = inf.id
         -- and ii.dm_tipo        = 1 -- Retenção
         and ti.id             = ii.tipoimp_id
         and ti.cd             = '6' -- ISS
         and ic.itemnf_id      = inf.id
         and nf.id             = nd.notafiscal_id(+)
         and mf.id             = nf.modfiscal_id
         and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
         and nft.notafiscal_id = nf.id
         and pn.id             = nf.pessoa_id
         and pn.cidade_id     <> pe.cidade_id -- Municicpio do Prestador diferente do Municipio do Tomador
         and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
      order by nf.id;
      --
begin
   --
   vn_fase := 1;
   --
   gl_conteudo := null;
   --
   -- Cabeçalho
   -- =========
   gl_conteudo := '<?xml version="1.0" encoding="UTF-8"?>';
   gl_conteudo := gl_conteudo || '<Declaracao>';
   gl_conteudo := gl_conteudo || '<Notas>';
   --
   vn_qtde_linhas := 0;
   --
   vn_fase := 2;
   --
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_fase := 3;
   --
   for rec_nfs in c_nfs loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_fase := 4;
      --
      -- Busca dados da pessoa_id do prestador
      for rec_pessoa in c_pessoa(rec_nfs.pessoa_id_prest) loop
         exit when c_pessoa%notfound or (c_pessoa%notfound) is null;
         --
         vv_nome     := rec_pessoa.nome;         -- Nome
         vn_cep      := rec_pessoa.cep;          -- Cep
         vv_endereco := rec_pessoa.lograd;       -- Endereço
         vn_numero   := rec_pessoa.nro;          -- Número
         vv_bairro   := rec_pessoa.bairro;       -- Bairro
         vv_cidade   := rec_pessoa.ibge_cidade;  -- Cidade
         vv_estado   := rec_pessoa.sigla_estado; -- Estado
         vn_fone     := rec_pessoa.fone;         -- Fone
         vv_email    := rec_pessoa.email;        -- email
         vv_pais     := rec_pessoa.pais_descr;   -- País
         vv_compl    := rec_pessoa.compl;        -- Compl
         vv_ie       := rec_pessoa.ie;           -- Inscr. Estadual
         --
         vv_cpf_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec_nfs.pessoa_id_prest );
         --
         -- Busca dados do tipo de prestador
         for rec_tpprest in c_tpprest (rec_nfs.pessoa_id_prest) loop
            exit when c_tpprest%notfound or (c_tpprest%notfound) is null;
            --
            vn_tpprest := null;
            --
            if    rec_tpprest.cd_tpparam = 9 and rec_tpprest.cd_vlrtpparam = 3 then -- Retornar  1-Normal, quando CD.TIPOPARAM = 9 e CD.VALORTIPOPARAM  = 3
               vn_tpprest := 1;
            elsif rec_tpprest.cd_tpparam in (1,9) and rec_tpprest.cd_vlrtpparam = 1 then -- Retornar 2-Simples, quando CD.TIPOPARAM = 1 ou 9 e CD.VALORTIPOPARAM  = 1.
               vn_tpprest := 2;
            elsif rec_tpprest.cd_tpparam = 2 and rec_tpprest.cd_vlrtpparam = 5 then-- Retornar 3-MEI, quando CD.TIPOPARAM = 2 e CD.VALORTIPOPARAM = 5.
               vn_tpprest := 3;
            elsif rec_pessoa.dm_tipo_pessoa = 2 then -- Retornar 4-ESTRANGEIRO, quando o campo DM_TIPO_PESSOA for igual = 2
               vn_tpprest := 4;
            elsif rec_pessoa.dm_tipo_pessoa = 0 then -- Retornar 5-PESSOA FISICA COM NOTA, quando o campo DM_TIPO_PESSOA for igual = 0
               vn_tpprest := 5;
            end if;
            --
         end loop;
         --
      end loop;
      --
      vn_fase := 5;
      --
      -- Detalhe
      -- =======
      --
      vn_qtde_linhas := nvl(vn_qtde_linhas,0) + 1;
      --
      gl_conteudo := '<Nota>';
      --
      gl_conteudo := gl_conteudo ||'<DataEmissao>'   || rtrim(substr(to_char(rec_nfs.dt_emiss,'YYYY-MM-DD'),1,10))||'</DataEmissao>';  -- DataEmissao
      gl_conteudo := gl_conteudo ||'<NumeroNota>'    || rtrim(substr(rec_nfs.nro_nf,1,15))                        ||'</NumeroNota>';   -- Numero
      gl_conteudo := gl_conteudo ||'<Serie>'         || rtrim(substr(rec_nfs.serie,1,3))                          ||'</Serie>';        -- Serie
      gl_conteudo := gl_conteudo ||'<TipoPrestador>' || rtrim(substr(vn_tpprest,1,1))                             ||'</TipoPrestador>';-- TipoPrestador
      --
      vn_fase := 6;
      --
      gl_conteudo := gl_conteudo || '<Prestador>';
      gl_conteudo := gl_conteudo || '<Documento>'         || rtrim(substr(vv_cpf_cnpj,1,14))        || '</Documento>';      -- Documento
      gl_conteudo := gl_conteudo || '<RazaoSocial>'       || rtrim(substr(vv_nome,1,150))           || '</RazaoSocial>';    -- Razão Social
      gl_conteudo := gl_conteudo || '<Email>'             || rtrim(vv_email)                        || '</Email>';          -- Email
      gl_conteudo := gl_conteudo || '<Telefone>'          || rtrim(vn_fone)                         || '</Telefone>';       -- Telefone
      gl_conteudo := gl_conteudo || '<InscricaoMunicipal>'|| rtrim(rpad(pk_csf.fkg_inscr_mun_pessoa ( en_pessoa_id  => rec_nfs.pessoa_id_prest ), 7)) || '</InscricaoMunicipal>';             -- InscricaoMunicipal
      gl_conteudo := gl_conteudo || '<Cep>'               || rtrim(substr(vn_cep,1,8))              || '</Cep>';            -- Cep
      gl_conteudo := gl_conteudo || '<TipoLogradouro>'    || 'Rua'                                  || '</TipoLogradouro>'; -- TipoLogradouro
      gl_conteudo := gl_conteudo || '<Logradouro>'        || rtrim(substr(vv_endereco,1,200))       || '</Logradouro>';     -- Logradouro
      gl_conteudo := gl_conteudo || '<Numero>'            || rtrim(substr(nvl(vn_numero,'SN'),1,6)) || '</Numero>';         -- Número
      gl_conteudo := gl_conteudo || '<Complemento>'       || rtrim(substr(vv_compl,1,60))           || '</Complemento>';    -- Complemento
      gl_conteudo := gl_conteudo || '<Bairro>'            || rtrim(substr(vv_bairro,1,50))          || '</Bairro>';         -- Bairro
      gl_conteudo := gl_conteudo || '<Cidade>'            || rtrim(substr(vv_cidade,1,50))          || '</Cidade>';         -- Cidade
      gl_conteudo := gl_conteudo || '<InscricaoEstadual>' || rtrim(rpad(pk_csf.fkg_ie_pessoa_id (en_pessoa_id => rec_nfs.pessoa_id_prest),20)) || '</InscricaoEstadual>'; -- InscricaoEstadual
      gl_conteudo := gl_conteudo || '<Pais>'              || rtrim(substr(vv_pais,1,30))            || '</Pais>';           -- Pais
      --
      gl_conteudo := gl_conteudo || '</Prestador>';
      --
      vn_fase := 7;
      --
      gl_conteudo := gl_conteudo || '<LocalPrestacao>'    || rtrim(substr(rec_nfs.cidade_ibge,1,7))                                  || '</LocalPrestacao>'; -- LocalPrestacao
      gl_conteudo := gl_conteudo || '<Servico>'           || rtrim(substr(rec_nfs.cd_lista_serv,1,4))                                || '</Servico>';        -- Servico
      --
      gl_conteudo := gl_conteudo || '<Valor>'             || rtrim(pk_csf.fkg_formata_num(rec_nfs.vl_item_bruto, '9999999.99'))      || '</Valor>';          -- Valor
      gl_conteudo := gl_conteudo || '<Aliquota>'          || rtrim(pk_csf.fkg_formata_num(nvl(rec_nfs.aliq_apli, 0),'9999999.9'))    || '</Aliquota>';
      gl_conteudo := gl_conteudo || '<ValorDeducao>'      || rtrim(pk_csf.fkg_formata_num(rec_nfs.vl_deducao, '9999999.99'))         || '</ValorDeducao>';   -- ValorDeducao
      gl_conteudo := gl_conteudo || '<ValorDescontoIncondicionado>'|| rtrim(pk_csf.fkg_formata_num(rec_nfs.vl_desc_incondicionado, '9999999.99')) || '</ValorDescontoIncondicionado>';-- ValorDescontoIncondicionado
      --
      gl_conteudo := gl_conteudo || '<CodigoDaObra>'  ||   rec_nfs.cod_obra  || '</CodigoDaObra>';  -- CodigoDaObra                                                            
      --
      gl_conteudo := gl_conteudo || '</Nota>';
      --
      vn_fase := 8;
      --
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
   end loop;
   --
   vn_fase := 9;
   --
   gl_conteudo := '</Notas>';
   gl_conteudo := gl_conteudo || '</Declaracao>';
   --
   vn_qtde_linhas := 0;
   --
   vn_fase := 10;
   --
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_2307650 fase ('||vn_fase||'): '||sqlerrm);

end pkb_gera_arq_cid_2307650;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço Tomados de Tiangua / CE
procedure pkb_gera_arq_cid_2313401 is
--
--
   vn_fase                     number := 0;
   vn_qtde_linhas              number := 0;
   --
   vv_cpf_cnpj                 varchar2(14);
   vv_nome                     pessoa.nome%type;
   vn_cep                      pessoa.cep%type;
   vv_endereco                 pessoa.lograd%type;
   vn_numero                   pessoa.nro%type;
   vv_bairro                   pessoa.bairro%type;
   vv_cidade                   cidade.descr%type;
   vv_estado                   estado.sigla_estado%type;
   vn_fone                     pessoa.fone%type;
   vv_email                    pessoa.email%type;
   vv_compl                    pessoa.compl%type;
   vv_pais                     pais.descr%type;
   vv_ie                       juridica.ie%type;
   vn_tpprest                  number(1);
   --
   -- Dados da pessoa_id
   cursor c_pessoa (en_pessoa_id pessoa.id%type) is
      select pe.nome
           , pe.lograd
           , pe.nro
           , pe.compl
           , pe.bairro
           , ci.descr
           , es.sigla_estado
           , pe.cep
           , pe.email
           , pe.fone
           , pa.descr pais_descr
           , ju.ie
           , pe.dm_tipo_pessoa
           , ci.ibge_cidade
        from pessoa   pe
           , cidade   ci
           , estado   es
           , pais     pa
           , juridica ju
       where pe.id        = en_pessoa_id
         and ci.id        = pe.cidade_id
         and es.id        = ci.estado_id
         and pa.id        = pe.pais_id
         and ju.pessoa_id = pe.id;
   --
   -- Dados do tipo de prestador
   cursor c_tpprest (en_pessoa_id pessoa.id%type) is
      select tp.cd cd_tpparam
           , vt.cd cd_vlrtpparam
        from pessoa_tipo_param pt
           , tipo_param        tp
           , valor_tipo_param  vt
       where pt.pessoa_id         = en_pessoa_id
         and tp.id                = pt.tipoparam_id
         and vt.tipoparam_id      = tp.id
         and pt.valortipoparam_id = vt.id;
   --   
   cursor c_nfs is
      select mf.cod_mod
           , nf.nro_nf
           , nf.serie
           , nft.vl_base_calc_iss
           , nft.vl_total_nf
           , ii.aliq_apli
           , nf.dt_emiss
           , nf.dt_sai_ent
           , nf.pessoa_id  pessoa_id_prest
           , ii.dm_tipo
           , ic.dm_trib_mun_prest
           , nf.empresa_id empresa_id_toma
           , nf.nat_oper
           , ti.cd
           , inf.cd_lista_serv
           , inf.vl_item_bruto
           , ic.vl_deducao
           , ic.vl_desc_incondicionado
           , inf.cidade_ibge
        from nota_fiscal       nf
           , pessoa            pe
           , item_nota_fiscal  inf
           , imp_itemnf        ii
           , tipo_imposto      ti
           , mod_fiscal        mf
           , nota_fiscal_total nft
           , itemnf_compl_serv ic
       where nf.empresa_id     = gn_empresa_id
         and nf.dm_ind_emit    = 1 -- Terceiro
         and nf.dm_st_proc     = 4 -- Autorizada
         and ((nf.dm_ind_emit  = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
              (nf.dm_ind_emit  = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
              (nf.dm_ind_emit  = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
              (nf.dm_ind_emit  = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
         and pe.id               = nf.pessoa_id -- prestador
         and pe.cidade_id        = gn_cidade_id -- fecha na cidade do prestador
         and inf.notafiscal_id   = nf.id
         and ii.itemnf_id        = inf.id
         and ti.id               = ii.tipoimp_id
         and ic.itemnf_id        = inf.id
         and mf.id               = nf.modfiscal_id
         and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
         and nft.notafiscal_id   = nf.id
         and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
      order by nf.id;
      --
begin
   --
   vn_fase := 1;
   --
   gl_conteudo := null;
   --
   -- Cabeçalho
   -- =========
   gl_conteudo := '<?xml version="1.0" encoding="UTF-8"?>';
   gl_conteudo := gl_conteudo || '<Declaracao>';
   gl_conteudo := gl_conteudo || '<Notas>';
   --
   vn_qtde_linhas := 0;
   --
   vn_fase := 2;
   --
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_fase := 3;
   --
   for rec_nfs in c_nfs loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_fase := 4;
      --
      -- Busca dados da pessoa_id do prestador
      for rec_pessoa in c_pessoa(rec_nfs.pessoa_id_prest) loop
         exit when c_pessoa%notfound or (c_pessoa%notfound) is null;
         --
         vv_nome     := rec_pessoa.nome;         -- Nome
         vn_cep      := rec_pessoa.cep;          -- Cep
         vv_endereco := rec_pessoa.lograd;       -- Endereço
         vn_numero   := rec_pessoa.nro;          -- Número
         vv_bairro   := rec_pessoa.bairro;       -- Bairro
         vv_cidade   := rec_pessoa.ibge_cidade;  -- Cidade
         vv_estado   := rec_pessoa.sigla_estado; -- Estado
         vn_fone     := rec_pessoa.fone;         -- Fone
         vv_email    := rec_pessoa.email;        -- email
         vv_pais     := rec_pessoa.pais_descr;   -- País
         vv_compl    := rec_pessoa.compl;        -- Compl
         vv_ie       := rec_pessoa.ie;           -- Inscr. Estadual
         --
         vv_cpf_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec_nfs.pessoa_id_prest );
         --
         -- Busca dados do tipo de prestador
         for rec_tpprest in c_tpprest (rec_nfs.pessoa_id_prest) loop
            exit when c_tpprest%notfound or (c_tpprest%notfound) is null;
            --
            vn_tpprest := null;
            --
            if    rec_tpprest.cd_tpparam = 1 and rec_tpprest.cd_vlrtpparam = 9 then -- Retornar  1-Normal, quando CD.TIPOPARAM = 9 e CD.VALORTIPOPARAM  = 3
               vn_tpprest := 1;
            elsif rec_tpprest.cd_tpparam in (1,9) and rec_tpprest.cd_vlrtpparam = 1 then -- Retornar 2-Simples, quando CD.TIPOPARAM = 1 ou 9 e CD.VALORTIPOPARAM  = 1.
               vn_tpprest := 2;
            elsif rec_tpprest.cd_tpparam = 2 and rec_tpprest.cd_vlrtpparam = 5 then-- Retornar 3-MEI, quando CD.TIPOPARAM = 2 e CD.VALORTIPOPARAM = 5.
               vn_tpprest := 3;
            elsif rec_pessoa.dm_tipo_pessoa = 1 then -- Retornar 4-ESTRANGEIRO, quando o campo DM_TIPO_PESSOA for igual = 1
               vn_tpprest := 4;
            elsif rec_pessoa.dm_tipo_pessoa = 0 then -- Retornar 5-PESSOA FISICA COM NOTA, quando o campo DM_TIPO_PESSOA for igual = 0
               vn_tpprest := 5;
            end if;
            --
         end loop;
         --
      end loop;
      --
      vn_fase := 5;
      --
      -- Detalhe
      -- =======
      --
      vn_qtde_linhas := nvl(vn_qtde_linhas,0) + 1;
      --
      gl_conteudo := '<Nota>';
      --
      vn_fase := 6;
      --
      gl_conteudo := gl_conteudo ||'<DataEmissao>'   || rtrim(substr(to_char(rec_nfs.dt_sai_ent,'YYYY-MM-DD'),1,10))||'</DataEmissao>';  -- DataEmissao
      gl_conteudo := gl_conteudo ||'<NumeroNota>'    || rtrim(substr(rec_nfs.nro_nf,1,15))                          ||'</NumeroNota>';   -- Numero
      gl_conteudo := gl_conteudo ||'<Serie>'         || rtrim(substr(rec_nfs.serie,1,3))                            ||'</Serie>';        -- Serie
      gl_conteudo := gl_conteudo ||'<TipoPrestador>' || rtrim(substr(vn_tpprest,1,1))                               ||'</TipoPrestador>';-- TipoPrestador
      --
      vn_fase := 7;
      --
      gl_conteudo := gl_conteudo || '<Prestador>';
      --
      gl_conteudo := gl_conteudo || '<Documento>'         || rtrim(substr(vv_cpf_cnpj,1,14))        || '</Documento>';      -- Documento
      gl_conteudo := gl_conteudo || '<RazaoSocial>'       || rtrim(substr(vv_nome,1,150))           || '</RazaoSocial>';    -- Razão Social
      gl_conteudo := gl_conteudo || '<Email>'             || rtrim(vv_email)                        || '</Email>';          -- Email
      gl_conteudo := gl_conteudo || '<Telefone>'          || rtrim(vn_fone)                         || '</Telefone>';       -- Telefone
      gl_conteudo := gl_conteudo || '<InscricaoMunicipal>'|| rtrim(rpad(pk_csf.fkg_inscr_mun_pessoa ( en_pessoa_id  => rec_nfs.pessoa_id_prest ), 7)) || '</InscricaoMunicipal>';             -- InscricaoMunicipal
      gl_conteudo := gl_conteudo || '<Cep>'               || rtrim(substr(vn_cep,1,8))              || '</Cep>';            -- Cep
      gl_conteudo := gl_conteudo || '<TipoLogradouro>'    || 'Rua'                                  || '</TipoLogradouro>'; -- TipoLogradouro
      gl_conteudo := gl_conteudo || '<Logradouro>'        || rtrim(substr(vv_endereco,1,125))       || '</Logradouro>';     -- Logradouro
      gl_conteudo := gl_conteudo || '<Numero>'            || rtrim(substr(nvl(vn_numero,'SN'),1,6)) || '</Numero>';         -- Número
      gl_conteudo := gl_conteudo || '<Complemento>'       || rtrim(substr(vv_compl,1,60))           || '</Complemento>';    -- Complemento
      gl_conteudo := gl_conteudo || '<Bairro>'            || rtrim(substr(vv_bairro,1,60))          || '</Bairro>';         -- Bairro
      gl_conteudo := gl_conteudo || '<Cidade>'            || rtrim(substr(vv_cidade,1,7))           || '</Cidade>';         -- Cidade
      gl_conteudo := gl_conteudo || '<InscricaoEstadual>' || rtrim(rpad(pk_csf.fkg_ie_pessoa_id (en_pessoa_id => rec_nfs.pessoa_id_prest),20)) || '</InscricaoEstadual>'; -- InscricaoEstadual
      gl_conteudo := gl_conteudo || '<Pais>'              || rtrim(substr(vv_pais,1,30))            || '</Pais>';           -- Pais
      --
      gl_conteudo := gl_conteudo || '</Prestador>';
      --
      vn_fase := 8;
      --
      gl_conteudo := gl_conteudo || '<LocalPrestacao>'    || rtrim(substr(rec_nfs.cidade_ibge,1,7))                              || '</LocalPrestacao>'; -- LocalPrestacao
      gl_conteudo := gl_conteudo || '<Servico>'           || rtrim(substr(rec_nfs.cd_lista_serv,1,4))                            || '</Servico>';        -- Servico
      --
      gl_conteudo := gl_conteudo || '<Valor>'             || rtrim(pk_csf.fkg_formata_num(rec_nfs.vl_item_bruto, '9999999.99'))  || '</Valor>';          -- Valor
      gl_conteudo := gl_conteudo || '<Aliquota>'          || rtrim(pk_csf.fkg_formata_num(nvl(rec_nfs.aliq_apli, 0),'9999999.9'))|| '</Aliquota>';
      gl_conteudo := gl_conteudo || '<ValorDeducao>'      || rtrim(pk_csf.fkg_formata_num(rec_nfs.vl_deducao, '9999999.99'))     || '</ValorDeducao>';   -- ValorDeducao
      gl_conteudo := gl_conteudo || '<ValorDescontoIncondicionado>'|| rtrim(pk_csf.fkg_formata_num(rec_nfs.vl_desc_incondicionado, '9999999.99')) || '</ValorDescontoIncondicionado>';-- ValorDescontoIncondicionado
      --
      gl_conteudo := gl_conteudo || '<CodigoDaObra>'                                                                             || '</CodigoDaObra>';   -- CodigoDaObra
      --
      gl_conteudo := gl_conteudo || '</Nota>';
      --
      vn_fase := 9;
      --
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
   end loop;
   --
   vn_fase := 10;
   --
   gl_conteudo := '</Notas>';
   gl_conteudo := gl_conteudo || '</Declaracao>';
   --
   vn_qtde_linhas := 0;
   --
   vn_fase := 11;
   --
   -- Armazena a estrutura do arquivo
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_2313401 fase ('||vn_fase||'): '||sqlerrm);

end pkb_gera_arq_cid_2313401;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço Tomados de Gravataí / RS
procedure pkb_gera_arq_cid_4309209 is
  --
  --
   vn_fase        number := 0;
   vn_tp_serv     nota_fiscal.dm_ind_emit%type;
   vc_tp_doc      mod_fiscal.cod_mod%type;
   vc_tp_prest    char(1);
   vc_tp_toma     char(1);
   v_tp_pessoa    pessoa.dm_tipo_pessoa%type;
   vc_cnpj_prest  varchar2(30);
   vc_cnpj_toma   varchar2(30);
   vc_cpf_prest   varchar2(30);
   vc_cont_adic   varchar2(100);
   vc_cd_tparam   tipo_param.cd%type;
   vc_cd_vlr_tp   valor_tipo_param.cd%type;
   vc_op_simples  char(1);
   vn_aliq_srv    varchar2(10)/*number(2,2)*/;
   vc_st_dserv    char(2);
   vn_vlr_ret     imp_itemnf.vl_imp_trib%type;
   vn_trib_iss    char(1);
   vn_tem_trib    number(2);
  --
  cursor c_nfs is
      select nf.DM_IND_EMIT                             -- Tipo do serviço
           , mf.cod_mod                                 -- Modelo
           , nf.nro_nf                                  -- Número Documento
           , trunc(nf.dt_emiss) as dt_emiss             -- Dta emissao
           , nf.pessoa_id as id_prestador               -- ID do prestador
           , e.pessoa_id as id_tomador                  -- ID do tomador
           , p.dm_tipo_pessoa as tp_tomador             -- tipo pessoa tomador
           , nft.vl_total_nf                            -- Valor contábil do documento. 
           , nf.id as id_nota
           , ncs.DM_NAT_OPER                            -- Código da situação tributária da declaração do serviço
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , item_nota_fiscal inf
        , nf_compl_serv  ncs        
        , nota_fiscal_total nft
    where nf.empresa_id    = /*125*/ gn_empresa_id
      and nf.dm_ind_emit   = gn_dm_ind_emit
      and nf.dm_st_proc    = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id --5011
      and nf.id              = inf.notafiscal_id
      and nf.id              = ncs.notafiscal_id (+)
      and nf.id              = nft.notafiscal_id
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514      
  group by nf.DM_IND_EMIT, mf.cod_mod , nf.nro_nf , trunc(nf.dt_emiss) , nf.pessoa_id ,
           e.pessoa_id, p.dm_tipo_pessoa , nf.id , ncs.DM_NAT_OPER, nft.vl_total_nf 
  order by nf.id;
  ----------------
  cursor c_item (en_nf_id nota_fiscal.id%type) is
  select
       inf.id
       , inf.cd_lista_serv               -- Código do item da lista de serviços da lei complementar 116.
       , inf.VL_ITEM_BRUTO               --Valor tributável (Base de cálculo da prestação de serviços).
       , ics.vl_deducao                  --Dedução.
       , inf.cidade_ibge            --Local da prestação do serviço.
  from item_nota_fiscal inf
     , itemnf_compl_serv ics
  where inf.notafiscal_id  = en_nf_id
    and inf.id             = ics.itemnf_id (+)
    order by inf.id;
  ----------------
  cursor c_prest (en_pessoa_id pessoa.id%type) is
  select p.NOME,
         p.LOGRAD,
         p.NRO,
         p.COMPL,
         p.BAIRRO,
         c.DESCR as Nome_cidade/*IBGE_CIDADE*/,
         e.SIGLA_ESTADO,
         p.cep,
         p.FONE,
         p.FAX
  from pessoa p,CIDADE c, ESTADO e
  where p.cidade_id = c.id
    and c.estado_id = e.id
    and p.id        = en_pessoa_id;
   ----------------
   function fkg_retorna_nfinfor (en_id_nota nfinfor_adic.notafiscal_id%type) return varchar2 is
    vc_cont_adic varchar2(30);
    begin
      ---
      select substr(na.conteudo,1,100) into vc_cont_adic  from NFINFOR_ADIC na
      where na.notafiscal_id = en_id_nota  ;
      return vc_cont_adic;
      ---
    exception
       when others then
       return null;
    end;
   ----------------

    function fkg_retorna_aliq (en_cod_serv item_nota_fiscal.cd_lista_serv%type ) return varchar2
    is
    vc_aliq varchar2(10);
    begin
     case
       when en_cod_serv in ('0','301','714','715','1301','1707','4520') then vc_aliq:='0.00';
       when en_cod_serv = '1601'                                        then vc_aliq:='1.00';
       when en_cod_serv = '801'                                         then vc_aliq:='2.00';
       when en_cod_serv in ('702','704','705','719')                    then vc_aliq:='4.00';
       when en_cod_serv in ('1001','1002','1003','1004','1005','1201','1202','1203','1204','1205','1206',
            '1207','1208','1209','1210','1211','1212','1213','1214','1215','1216','1217',
            '1501','1502','1503','1504','1505','1506','1507','1508','1509','1510','1511',
            '1512','1513','1514','1515','1516','1517','1518','1705','1723','1901','2001',
            '2002','2101','2201')                                       then vc_aliq:='5.00';
        when en_cod_serv
          in('101','102','103','104','105','106','107','108','109','201','302','303',
             '304','305','401','402','403','404','405','406','407','408','409','410',
             '411','412','413','414','415','416','417','418','419','420','421','422',
             '423','501','502','503','504','505','506','507','508','509','601','602',
             '603','604','605','606','701','703','706','707','708','709','710','711',
             '712','713','716','717','718','720','721','722','802','901','902','903',
             '1006','1007','1008','1009','1010','1101','1102','1103','1104','1302',
             '1303','1304','1305','1401','1402','1403','1404','1405','1406','1407',
             '1408','1409','1410','1411','1412','1413','1414','1602','1701','1702',
             '1704','1706','1708','1709','1710','1711','1712','1713','1714','1715',
             '1716','1717','1718','1719','1720','1721','1722','1724','1725','1801',
             '2003','2301','2401','2501','2502','2503','2504','2505','2601','2701',
             '2801','2901','3001','3101','3201','3301','3401','3501','3601','3701',
             '3801','3901','4001')                                      then  vc_aliq:='3.50';
      end case ;
      return vc_aliq;
    end;
   ----------------
   function fkg_retorna_vlrret (en_id_item item_nota_fiscal.id %type) return number is
       vn_vlrret number;
    begin
      vn_vlrret:=0;
      select ii.vl_imp_trib into vn_vlrret
        from imp_itemnf ii, tipo_imposto     ti
       where ii.itemnf_id      = en_id_item/*rec_item.id*/
         and ti.id             = ii.tipoimp_id
         and ti.cd             = 6 -- ISS
         and ii.dm_tipo        = 1;
         return vn_vlrret;
    exception
      when others then
        vn_vlrret:=0;
        return vn_vlrret;
    end;
   ----------------
   function fkg_retorna_temiss (en_id_item item_nota_fiscal.id %type) return number is
       vn_trib number;
    begin
      vn_trib:=0;
      select count(1) into vn_trib
        from imp_itemnf ii, tipo_imposto     ti
       where ii.itemnf_id      = en_id_item/*rec_item.id*/
         and ti.id             = ii.tipoimp_id
         and ti.cd             = 6 -- ISS
         and ii.dm_tipo        = 1;
         return vn_trib;
    exception
      when others then
        vn_trib:=0;
        return vn_trib;
    end;
   ----------------
begin
   gl_conteudo := null;
   vn_fase     :=1;
   --------------
   for rec_nfs in c_nfs loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      /*Layout do Registro Tipo 10 – Identificação do Documento Fiscal */
      vn_fase      := 1.1;
      gl_conteudo  := null;
      gl_conteudo  := '10';                                                         --Descrição do registro (10).
      ----
      if rec_nfs.DM_IND_EMIT= 1 then vn_tp_serv:=2; else vn_tp_serv:= rec_nfs.DM_IND_EMIT; end if;
      gl_conteudo := gl_conteudo||';'||vn_tp_serv;                                 --Tipo do serviço (1 - Serviço prestado; 2 - Serviço tomado).
      ----
      if rec_nfs.cod_mod='99' then vc_tp_doc:= '7'; else vc_tp_doc:= rec_nfs.cod_mod; end if;
      gl_conteudo := gl_conteudo||';'||lpad(vc_tp_doc,2,'0');                      --Tipo do Documento
      ----
      gl_conteudo := gl_conteudo||';'||lpad(rec_nfs.nro_nf,15,'0');                --Número do documento.
      gl_conteudo := gl_conteudo||';'||to_char(rec_nfs.dt_emiss,'mm/rrrr');        --Competência
      ----
      vn_fase      := 1.2;
      begin
        select pp.dm_tipo_pessoa into v_tp_pessoa
        from pessoa pp where pp.id = rec_nfs.id_prestador;
        --
        if v_tp_pessoa ='0' then vc_tp_prest:='F'; elsif v_tp_pessoa ='1' then vc_tp_prest:='J'; end if;
      end;
      gl_conteudo  := gl_conteudo||';'||vc_tp_prest;                                 --Tipo da pessoa do prestador
      ----
      vn_fase      := 1.3;
      vc_cnpj_prest := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec_nfs.id_prestador );--CNPJ/CPF do prestador do serviço.
      gl_conteudo  := gl_conteudo||';'||lpad(vc_cnpj_prest,14,'0');
      ----
      vn_fase      := 1.4;
      if rec_nfs.tp_tomador ='0' then vc_tp_toma:='F'; elsif rec_nfs.tp_tomador ='1' then vc_tp_toma:='J'; end if;
      gl_conteudo  := gl_conteudo||';'||vc_tp_toma;                                          --Tipo da pessoa do tomador
      ----
      vn_fase      := 1.5;
      vc_cnpj_toma := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec_nfs.id_tomador );   --CPF / CNPJ do tomador
      gl_conteudo  := gl_conteudo||';'||lpad(vc_cnpj_toma,14,'0');
      ----
      gl_conteudo  := gl_conteudo||';'||to_char(rec_nfs.dt_emiss,'dd/mm/rrrr');                 -- Data de emissão do documento DD/MM/AAAA;
      gl_conteudo  := gl_conteudo||';'||trim(replace(to_char(nvl(rec_nfs.vl_total_nf,0.00),'000000000000000D00'), ',', '.'));      -- Valor contábil do documento.
      gl_conteudo  := gl_conteudo||';'||'E';                                                     -- Situação de utilização do documento
      ----
      vn_fase      := 1.6;
      vc_cont_adic := fkg_retorna_nfinfor(rec_nfs.id_nota);
      gl_conteudo  := gl_conteudo||';'||rpad(nvl(vc_cont_adic,' '),100,' ');                   -- Observações para o documento.
      ----
      vc_cd_tparam:=null;
      vc_cd_vlr_tp:=null;
      vn_fase     := 1.7;
      begin
        select distinct tp.cd , vtp.cd
            into  vc_cd_tparam,vc_cd_vlr_tp
            from valor_tipo_param vtp
               , tipo_param       tp
               , pessoa_tipo_param ptp
           where ptp.pessoa_id         = rec_nfs.id_prestador
             and vtp.tipoparam_id      = tp.id
             and ptp.tipoparam_id      = tp.id
             and ptp.valortipoparam_id = vtp.id;
      exception
        when others then
          vc_cd_tparam:=null;
          vc_cd_vlr_tp:=null;
      end;
      --
      if vc_cd_tparam=1 and vc_cd_vlr_tp=1 then
        vc_op_simples:='S';
      else
        vc_op_simples:='N';
      end if;
      gl_conteudo  := gl_conteudo||';'||vc_op_simples||';';                                  -- Documento fiscal proveniente de optantes do Simples Naciona
      ----
      vn_fase     := 1.8;
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --------------------------------
      vn_fase     :=2;
      /*Layout do Registro Tipo 20 – Identificação dos serviços relacionados ao Documentos Fiscal*/
       for rec_item in c_item(rec_nfs.id_nota) loop
          exit when c_item%notfound or (c_item%notfound) is null;
          gl_conteudo := null;
          gl_conteudo := '20';                                                                    --Descrição do registro (20).
          vn_fase     := 2.1;
          ----
          gl_conteudo := gl_conteudo||';'||vn_tp_serv;                                           --Tipo do serviço (1 - Serviço prestado; 2 - Serviço tomado).
          gl_conteudo := gl_conteudo||';'||lpad(vc_tp_doc,2,'0');                                --Tipo do Documento
          gl_conteudo := gl_conteudo||';'||lpad(rec_nfs.nro_nf,15,'0');                          --Número do documento.
          gl_conteudo := gl_conteudo||';'||to_char(rec_nfs.dt_emiss,'mm/rrrr');                  --Competência
          gl_conteudo := gl_conteudo||';'||vc_tp_prest;                                          --Tipo da pessoa do prestador
          gl_conteudo := gl_conteudo||';'||lpad(vc_cnpj_prest,14,'0');                           --CNPJ/CPF do prestador do serviço.
          gl_conteudo := gl_conteudo||';'||vc_tp_toma;                                           --Tipo da pessoa do tomador
          gl_conteudo := gl_conteudo||';'||lpad(vc_cnpj_toma,14,'0');                            --CPF / CNPJ do tomador
          gl_conteudo := gl_conteudo||';'||lpad(rec_item.cd_lista_serv,7,'0');                   --Código do item da lista de serviços da lei complementar 116.
          ----
          vn_fase     := 2.2;
          vn_aliq_srv := fkg_retorna_aliq(rec_item.cd_lista_serv);
          ----
          gl_conteudo := gl_conteudo||';'||lpad(vn_aliq_srv,6,'0');                               --Alíquota referente ao item da lista de serviços.
          gl_conteudo := gl_conteudo||';'||trim(replace(to_char(nvl(rec_item.VL_ITEM_BRUTO,0.00),'000000000000000D00'), ',', '.'));                      --Valor tributável (Base de cálculo da prestação de serviços).
          gl_conteudo := gl_conteudo||';'||trim(replace(to_char(nvl(rec_item.vl_deducao,0.00),'000000000000000D00'), ',', '.'));                         --Dedução
          ----
          --Valor retido.
          vn_fase     := 2.3;
          vn_vlr_ret  := fkg_retorna_vlrret(rec_item.id);
          gl_conteudo := gl_conteudo||';'||trim(replace(to_char(nvl(vn_vlr_ret,0.00),'000000000000000D00'), ',', '.'));    --Valor retido.
          ----
          gl_conteudo := gl_conteudo||';'||lpad(rec_item.cidade_ibge,7,'0');               --Local da prestação do serviço.          
          ----
          --Código da situação tributária da declaração do serviço.
          vn_fase     := 2.4;
          vn_tem_trib:= 0;
          vn_tem_trib:= fkg_retorna_temiss(rec_item.id);
          ----
          vn_fase     := 2.5;
          if vn_tem_trib> 0 then
            vc_st_dserv:='01';-- Tributada Integralmente com imposto sobre serviços retido na fonte
          else
            case rec_nfs.DM_NAT_OPER
              when '1' then vc_st_dserv:='00'; --Tributada Integralmente
              when '2' then vc_st_dserv:='13'; --Não Tributada - Recolhimento efetuado pelo prestador de fora do Município
              when '3' then vc_st_dserv:='06'; --Isenção
              when '4' then vc_st_dserv:='07'; --Imune
            end case;
          end if;
          gl_conteudo := gl_conteudo||';'||vc_st_dserv;
          ----
          vn_fase     := 2.6;
          --Tributa o ISS para o município do prestador do serviço (S - Sim; N - Não).
          if rec_nfs.DM_NAT_OPER ='2' then
            vn_trib_iss:='S';
          else
            vn_trib_iss:='N';
          end if;
          gl_conteudo := gl_conteudo||';'||vn_trib_iss;
          ----
          gl_conteudo := gl_conteudo||';'||rpad(' ',10)||';'; --Redução de ISS por obras - CEI
          ----
          vn_fase     := 2.7;
          pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      end loop;
      --------------------------------
      /*Layout do Registro Tipo 30 – Identificação da pessoa relacionada ao Documento Fiscal*/
      --------------------------------
     vn_fase     := 3;
     for rec_prest in c_prest(rec_nfs.id_prestador) loop
        exit when c_prest%notfound or (c_prest%notfound) is null;
        gl_conteudo := null;
        gl_conteudo := '30';                                                                  --Descrição do registro (30).
        gl_conteudo := gl_conteudo||';'||vc_tp_prest;                                         --Tipo da pessoa do prestador
        gl_conteudo := gl_conteudo||';'||lpad(nvl(vc_cnpj_prest,' '),14,' ');                              --CNPJ do prestador do serviço.
        gl_conteudo := gl_conteudo||';'||rpad(nvl(rec_prest.NOME,' '),40,' ');                             --Nome / Razão Social.
        gl_conteudo := gl_conteudo||';'||rpad(nvl(rec_prest.LOGRAD,' '),40,' ');                           --Descrição do logradouro.
        gl_conteudo := gl_conteudo||';'||rpad(nvl(rec_prest.NRO,' '),6,' ');                               --Nro. Residência / Estabelecimento.
        gl_conteudo := gl_conteudo||';'||rpad(nvl(rec_prest.COMPL,' '),20,' ');                            --Complemento do endereço.
        gl_conteudo := gl_conteudo||';'||rpad(nvl(rec_prest.BAIRRO,' '),20,' ');                           --Descrição do bairro.
        gl_conteudo := gl_conteudo||';'||rpad(nvl(rec_prest.Nome_cidade,' '),30,' ');                      --Nome da cidade.
        gl_conteudo := gl_conteudo||';'||rpad(nvl(rec_prest.SIGLA_ESTADO,' '),2,' ');                      --Estado (Unidade da Federação).
        gl_conteudo := gl_conteudo||';'||lpad(nvl(rec_prest.cep,0),8,'0');                         --Código de endereçamento postal.        
        gl_conteudo := gl_conteudo||';'||rpad(nvl(rec_prest.FONE,' '),12,' ');                             --Fone comercial (99 9999-9999).
        gl_conteudo := gl_conteudo||';'||rpad(nvl(rec_prest.FAX,' '),12,' ')||';';                              --Fax (99 9999-9999).
        ----
        vn_fase     := 3.1;
        pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
     end loop;
   end loop;
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_4309209 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_4309209;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço Tomados de Gravataí / RS
procedure pkb_gera_arq_cid_4125506 is
  --
  --
   vn_fase          number :=0;  
   vn_tp_pessoa     number :=0;
   vc_estab_prest   char(1);
   vc_cnpj_prest    varchar2(30);
   vc_loc_prest     char(1);
   vc_simples       char(1);
   vn_aliq          imp_itemnf.aliq_apli%type;
  --
  cursor c_nfs is
   select nf.id         notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nvl(nf.dt_sai_ent, nf.dt_emiss) dt_emiss
        , ncs.dm_nat_oper
        , nft.VL_TOTAL_NF
        , inf.CD_LISTA_SERV
        , inf.CIDADE_IBGE
        , nf.pessoa_id 
        , inf.id as id_item        
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , nf_compl_serv  ncs
        , item_nota_fiscal inf
        , nota_fiscal_total nft
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id
      and nf.id              = ncs.notafiscal_id (+)
      and nf.id              = inf.notafiscal_id
      and nf.id              = nft.notafiscal_id
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
    order by nf.id; 
    
cursor c_pes ( en_pessoa_id   pessoa.id%type) is
    select p.DM_TIPO_PESSOA
          ,c.ibge_cidade
          ,p.nome
          ,j.id          
          ,decode(upper(j.ie),'ISENTO','S','N') prest_isento
          ,j.ie
          ,j.im
          ,p.cep
          ,p.lograd
          ,p.compl
          ,p.nro
          ,p.bairro
          ,e.sigla_estado
          ,c.descr nome_cid
    from pessoa p, cidade c, juridica j, estado e
    where p.id        = en_pessoa_id
      and p.cidade_id = c.id
      and p.id        = j.pessoa_id
      and c.estado_id = e.id;        
begin
   gl_conteudo := null;
   vn_fase     :=1;
   --------------
   for rec_nfs in c_nfs loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      gl_conteudo := null;
      gl_conteudo := 'T';                                                              --Indicador de Registro
      gl_conteudo := gl_conteudo||lpad(rec_nfs.nro_nf,10,'0');                         --Número da Nota Fiscal inicial
      gl_conteudo := gl_conteudo||lpad(nvl(rec_nfs.serie,' '),10);                     --Série da Nota Fiscal
      gl_conteudo := gl_conteudo||to_char(rec_nfs.dt_emiss,'dd/mm/rrrr');              --Data da emissão da Nota Fiscal
      gl_conteudo := gl_conteudo||rec_nfs.dm_nat_oper;                                 --Tipo da Nota Fiscal
      gl_conteudo := gl_conteudo||lpad(trim(nvl(rec_nfs.VL_TOTAL_NF,0.00)*100),12,0);  --Valor da Nota Fiscal
      gl_conteudo := gl_conteudo||lpad(rec_nfs.cd_lista_serv,10,' ');                  --Atividade ou serviço prestado
      --------------
      vn_fase     :=2;
      for rec_pes in c_pes(rec_nfs.pessoa_id) loop
         exit when c_pes%notfound or (c_pes%notfound) is null;
         ---------         
         vn_tp_pessoa:=0;
         if rec_pes.dm_tipo_pessoa =0 then   --Fisica
           vn_tp_pessoa:=1; --1-Física
         elsif rec_pes.dm_tipo_pessoa =1 then --Juridica
           vn_tp_pessoa:=2;--2-Jurídica
         end if;         
         gl_conteudo := gl_conteudo||vn_tp_pessoa;                                       --Prestador
         ---------
         vc_estab_prest:=null;
         if rec_pes.ibge_cidade = 4125506 then
            vc_estab_prest:='S';
         else
            vc_estab_prest:='N';
         end if;
         gl_conteudo := gl_conteudo||vc_estab_prest;                                     --Prestador estabelecido no Município
         ---------  
         gl_conteudo := gl_conteudo||lpad(rec_pes.nome,100,' ');                         --Razão Social do prestador
         gl_conteudo := gl_conteudo||lpad(substr(nvl(rec_pes.im,' '),1,10),10,' ');               --Inscrição municipal do prestador
         gl_conteudo := gl_conteudo||lpad(nvl(substr(rec_pes.im,11,2),' '),2,' ');                --Dígito da inscrição Municipal
         ---------   
         vn_fase     := 2.1;
         vc_cnpj_prest:= pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec_nfs.pessoa_id );--CNPJ ou CPF do prestador
         gl_conteudo  := gl_conteudo||lpad(vc_cnpj_prest,14,' '); 
         ---------   
         gl_conteudo  := gl_conteudo||rec_pes.prest_isento; --S – Isento / N - Não Isento : JURIDICA.IE - Prestador isento de inscrição estadual
         gl_conteudo  := gl_conteudo||lpad(rec_pes.ie,15,' ');                              --Inscrição estadual do prestador
         gl_conteudo  := gl_conteudo||lpad(rec_pes.cep,8,' ');                              --CEP referente ao logradouro do prestador
         gl_conteudo  := gl_conteudo||rpad('Rua',5,' ');                                    --Tipo de logradouro do prestador
         gl_conteudo  := gl_conteudo||rpad(' ',5,' ');                                      --Título do logradouro do prestador
         gl_conteudo  := gl_conteudo||rpad(nvl(rec_pes.lograd,' '),50,' ');                 --Logradouro do prestador
         gl_conteudo  := gl_conteudo||rpad(nvl(rec_pes.compl,' '),40,' ');                  --Complemento do logradouro do prestador
         gl_conteudo  := gl_conteudo||rpad(nvl(rec_pes.nro,' '),10,' ');                    --Número do logradouro do prestador
         gl_conteudo  := gl_conteudo||rpad(nvl(rec_pes.bairro,' '),50,' ');                 --Bairro referente ao logradouro do prestador
         gl_conteudo  := gl_conteudo||rpad(nvl(rec_pes.sigla_estado,' '),2,' ');            --Estado(UF) referente ao logradouro do prestador
         gl_conteudo  := gl_conteudo||rpad(nvl(rec_pes.nome_cid,' '),50,' ');               --Cidade referente ao logradouro do prestador
         -------------
         vc_loc_prest := null;
         if rec_pes.ibge_cidade = 4125506 then
            vc_loc_prest:='D';
         else
            vc_loc_prest:='F';
         end if;    
         gl_conteudo  := gl_conteudo||vc_loc_prest;                                         --Local de prestação do serviço
         -------------         
      end loop; 
      -------------      
      vn_fase    := 2.2;
      vc_simples := null;
      vc_simples := pk_csf.fkg_pessoa_valortipoparam_cd ( ev_tipoparam_cd => 1 -- Simples nacional
                                                        , en_pessoa_id    => rec_nfs.pessoa_id) ; -- Prestador optante pelo simples nacional.
      if trim(nvl(vc_simples,'0')) = '0' then  --  0-Não e 1-Sim          
         gl_conteudo := gl_conteudo ||'N';                                                   
      else
         gl_conteudo := gl_conteudo ||'S';
      end if;                                                                 
      -------------- 
      vn_fase    := 2.3;  
      begin
         select nvl(ii.aliq_apli,0)                                            -- Aliquota do Simples Nacional    
           into vn_aliq              
           from imp_itemnf       ii
              , tipo_imposto     ti
          where ii.itemnf_id     = rec_nfs.id_item
            and ii.dm_tipo       = 0 -- Imposto
            and ti.id            = ii.tipoimp_id
            and ti.cd            = '6'; -- ISS
      exception
         when others then
            vn_aliq        := 0;            
      end;      
      if trim(nvl(vc_simples,'0')) = '0' then  --  0-Não e 1-Sim
         gl_conteudo := gl_conteudo || trim(replace(to_char(nvl(vn_aliq,0.00),'00D00'), ',', '.')); 
      else
         gl_conteudo := gl_conteudo ||00.00;
      end if;  
      --------------
   end loop;
   --------------   
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --------------      
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_4125506 fase ('||vn_fase||'): '||sqlerrm);  
end pkb_gera_arq_cid_4125506;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço Tomados de Palhoca / RS
procedure pkb_gera_arq_cid_4211900 is
  --
  --
   vn_fase        number := 0;
   vn_tp_serv     nota_fiscal.dm_ind_emit%type;
   vc_tp_doc      mod_fiscal.cod_mod%type;
   vc_tp_prest    char(1);
   vc_tp_toma     char(1);
   v_tp_pessoa    pessoa.dm_tipo_pessoa%type;
   vc_cnpj_prest  varchar2(30);
   vc_cnpj_emp    varchar2(30);
   vc_cnpj_toma   varchar2(30);
   vc_cpf_prest   varchar2(30);
   vc_cont_adic   varchar2(100);
   vc_cd_tparam   tipo_param.cd%type;
   vc_cd_vlr_tp   valor_tipo_param.cd%type;
   vc_op_simples  char(1);
   vn_aliq_srv    varchar2(10)/*number(2,2)*/;
   vc_st_dserv    char(2);
   vn_vlr_ret     imp_itemnf.vl_imp_trib%type;
   vn_trib_iss    char(1);
   vn_tem_trib    number(2);
  --
 cursor c_nfs is
      select nf.DM_IND_EMIT                             -- Tipo do serviço
           , mf.cod_mod                                 -- Modelo
           , nf.nro_nf                                  -- Número Documento
           , trunc(nf.dt_emiss) as dt_emiss             -- Dta emissao
           , nf.pessoa_id as id_prestador               -- ID do prestador
           , e.pessoa_id as id_tomador                  -- ID do tomador
           , p.dm_tipo_pessoa as tp_tomador             -- tipo pessoa tomador
           , nft.vl_total_nf                            -- Valor contábil do documento. 
           , nf.id as id_nota
           , ncs.DM_NAT_OPER                            -- Código da situação tributária da declaração do serviço
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , item_nota_fiscal inf
        , nf_compl_serv  ncs        
        , nota_fiscal_total nft
    where nf.empresa_id    = gn_empresa_id
      and nf.dm_ind_emit   = gn_dm_ind_emit
      and nf.dm_st_proc    = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and p.cidade_id        = gn_cidade_id --4549
       and nf.pessoa_id  in  (select  p.id   from pessoa p   where p.id in (nf.pessoa_id )  and p.cidade_id <> gn_cidade_id) --Municícpio do Prestador diferente do Município do Tomador
      and nf.id              = inf.notafiscal_id
      and nf.id              = ncs.notafiscal_id (+)
      and nf.id              = nft.notafiscal_id
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514      
  group by nf.DM_IND_EMIT, mf.cod_mod , nf.nro_nf , trunc(nf.dt_emiss) , nf.pessoa_id ,
           e.pessoa_id, p.dm_tipo_pessoa , nf.id , ncs.DM_NAT_OPER, nft.vl_total_nf 
  order by nf.id;
  ----------------     
  cursor c_item (en_nf_id nota_fiscal.id%type) is
  select
       inf.id
       , inf.cd_lista_serv               -- Código do item da lista de serviços da lei complementar 116.
       , inf.VL_ITEM_BRUTO               --Valor tributável (Base de cálculo da prestação de serviços).
       , ics.vl_deducao                  --Dedução.
       , inf.cidade_ibge            --Local da prestação do serviço.
  from item_nota_fiscal inf
     , itemnf_compl_serv ics
  where inf.notafiscal_id  = en_nf_id
    and inf.id             = ics.itemnf_id (+)
    order by inf.id;
  ----------------
  cursor c_prest (en_pessoa_id pessoa.id%type) is
  select p.NOME,
         p.LOGRAD,
         p.NRO,
         p.COMPL,
         p.BAIRRO,
         c.DESCR as Nome_cidade/*IBGE_CIDADE*/,
         e.SIGLA_ESTADO,
         p.cep,
         p.FONE,
         p.FAX
  from pessoa p,CIDADE c, ESTADO e
  where p.cidade_id = c.id
    and c.estado_id = e.id
    and p.id        = en_pessoa_id;  
   ----------------
   function fkg_retorna_nfinfor (en_id_nota nfinfor_adic.notafiscal_id%type) return varchar2 is
    vc_cont_adic varchar2(30);
    begin
      ---
      select substr(na.conteudo,1,100) into vc_cont_adic  from NFINFOR_ADIC na
      where na.notafiscal_id = en_id_nota  ;
      return vc_cont_adic;
      ---
    exception
       when others then
       return null;
    end;
   ----------------

    function fkg_retorna_aliq (en_cod_serv item_nota_fiscal.cd_lista_serv%type ) return varchar2
    is
    vc_aliq varchar2(10);
    begin
     case
       when en_cod_serv  in ('0','201','301','304','709','712','714','715','718',
                            '721','1001','1006','1103','1104','1214','1301','1501',
                            '1502','1503','1504','1505','1506','1507','1508','1509',
                            '1510','1511','1512','1513','1514','1515','1516','1517',
                            '1518','1601','1602','1707','1712','1713','1801','2001',
                            '2002','2003','2201','2601','9999') 
                            then vc_aliq:='5.00';
                            
       when en_cod_serv in ('1201','1202','1203','1204','1205','1206','1207','1208',
                            '1209','1210','1211','1212','1215','1216','1217','1901',
                            '3401','3701')                    
                            then vc_aliq:='4.00';
       
       when en_cod_serv in ('303','305','405','408','409','412','415','416','422',
                            '423','501','502','503','504','508','509','601','602',
                            '603','604','701','702','703','704','705','706','707',
                            '708','711','716','717','719','720','722','901','1005',
                            '1007','1008','1009','1010','1101','1102','1213','1302',
                            '1303','1304','1305','1401','1402','1403','1404','1405',
                            '1406','1407','1408','1411','1412','1413','1414','1702',
                            '1704','1705','1710','1711','1714','1720','2101','2401',
                            '2501','2502','2503','2504','2701','2801','2901','3001',
                            '3201','3301','3501','3601','3901','4001')  
                            then vc_aliq:='3.00';
      
       when en_cod_serv in ('101','102','103','104','105','106','107','108','109',
                            '302','401','402','403','404','406','407','410','411',
                            '413','414','417','419','420','421','505','506','507',
                            '605','606','710','713','801','802','902','903','1002',
                            '1003','1004','1409','1410','1701','1703','1706','1708',
                            '1709','1715','1716','1717','1718','1719','1721','1722',
                            '1723','1724','1725','2301','2505','3101','3801') 
                            then  vc_aliq:='2.00';                                     
      end case ;
      return vc_aliq;
    end;
   ----------------
   function fkg_retorna_vlrret (en_id_item item_nota_fiscal.id %type) return number is
       vn_vlrret number;
    begin
      vn_vlrret:=0;
      select ii.vl_imp_trib into vn_vlrret
        from imp_itemnf ii, tipo_imposto     ti
       where ii.itemnf_id      = en_id_item/*rec_item.id*/
         and ti.id             = ii.tipoimp_id
         and ti.cd             = 6 -- ISS
         and ii.dm_tipo        = 1;
         return vn_vlrret;
    exception
      when others then
        vn_vlrret:=0;
        return vn_vlrret;
    end;
   ----------------
   function fkg_retorna_temiss (en_id_item item_nota_fiscal.id %type) return number is
       vn_trib number;
    begin
      vn_trib:=0;
      select count(1) into vn_trib
        from imp_itemnf ii, tipo_imposto     ti
       where ii.itemnf_id      = en_id_item/*rec_item.id*/
         and ti.id             = ii.tipoimp_id
         and ti.cd             = 6 -- ISS
         and ii.dm_tipo        = 1;
         return vn_trib;
    exception
      when others then
        vn_trib:=0;
        return vn_trib;
    end;
   ----------------
begin
   gl_conteudo := null;
   vn_fase     :=1;
   --------------
   gl_conteudo  := '01'; 
    for rec_nfs in c_nfs loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      /*Layout do Registro Tipo 10 – Identificação do Documento Fiscal */
      vn_fase      := 1.1;
      gl_conteudo  := null;
      gl_conteudo  := '10';                                                         --Descrição do registro (10).
      ----
      if rec_nfs.DM_IND_EMIT= 1 then vn_tp_serv:=2; else vn_tp_serv:= rec_nfs.DM_IND_EMIT; end if;
      gl_conteudo := gl_conteudo||';'||vn_tp_serv;                                 --Tipo do serviço (1 - Serviço prestado; 2 - Serviço tomado).
      ----
      if rec_nfs.cod_mod='99' then vc_tp_doc:= '7'; else vc_tp_doc:= rec_nfs.cod_mod; end if;
      gl_conteudo := gl_conteudo||';'||lpad(vc_tp_doc,2,'0');                      --Tipo do Documento
      ----
      gl_conteudo := gl_conteudo||';'||lpad(rec_nfs.nro_nf,15,'0');                --Número do documento.
      gl_conteudo := gl_conteudo||';'||to_char(rec_nfs.dt_emiss,'mm/rrrr');        --Competência
      ----
      vn_fase      := 1.2;
      begin
        select pp.dm_tipo_pessoa into v_tp_pessoa
        from pessoa pp where pp.id = rec_nfs.id_prestador;
        --
        if v_tp_pessoa ='0' then vc_tp_prest:='F'; elsif v_tp_pessoa ='1' then vc_tp_prest:='J'; end if;
      end;
      gl_conteudo  := gl_conteudo||';'||vc_tp_prest;                                 --Tipo da pessoa do prestador
      ----
      vn_fase      := 1.3;
      vc_cnpj_prest := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec_nfs.id_prestador );--CNPJ/CPF do prestador do serviço.
      gl_conteudo  := gl_conteudo||';'||lpad(vc_cnpj_prest,14,'0');
      ----
      vn_fase      := 1.4;
      if rec_nfs.tp_tomador ='0' then vc_tp_toma:='F'; elsif rec_nfs.tp_tomador ='1' then vc_tp_toma:='J'; end if;
      gl_conteudo  := gl_conteudo||';'||vc_tp_toma;                                          --Tipo da pessoa do tomador
      ----
      vn_fase      := 1.5;
      vc_cnpj_toma := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec_nfs.id_tomador );   --CPF / CNPJ do tomador
      gl_conteudo  := gl_conteudo||';'||lpad(vc_cnpj_toma,14,'0');
      ----
      gl_conteudo  := gl_conteudo||';'||to_char(rec_nfs.dt_emiss,'dd/mm/rrrr');                 -- Data de emissão do documento DD/MM/AAAA;
      gl_conteudo  := gl_conteudo||';'||trim(replace(to_char(nvl(rec_nfs.vl_total_nf,0.00),'000000000000000D00'), ',', '.'));      -- Valor contábil do documento.
      gl_conteudo  := gl_conteudo||';'||'E';                                                     -- Situação de utilização do documento
      ----
      vn_fase      := 1.6;
      vc_cont_adic := fkg_retorna_nfinfor(rec_nfs.id_nota);
      gl_conteudo  := gl_conteudo||';'||rpad(nvl(vc_cont_adic,' '),100,' ');                   -- Observações para o documento.
      ----
      vc_cd_tparam:=null;
      vc_cd_vlr_tp:=null;
      vn_fase     := 1.7;
      begin
        select distinct tp.cd , vtp.cd
            into  vc_cd_tparam,vc_cd_vlr_tp
            from valor_tipo_param vtp
               , tipo_param       tp
               , pessoa_tipo_param ptp
           where ptp.pessoa_id         = rec_nfs.id_prestador
             and vtp.tipoparam_id      = tp.id
             and ptp.tipoparam_id      = tp.id
             and ptp.valortipoparam_id = vtp.id;
      exception
        when others then
          vc_cd_tparam:=null;
          vc_cd_vlr_tp:=null;
      end;
      --
      if vc_cd_tparam=1 and vc_cd_vlr_tp=1 then
        vc_op_simples:='S';
      else
        vc_op_simples:='N';
      end if;
      gl_conteudo  := gl_conteudo||';'||vc_op_simples||';';                                  -- Documento fiscal proveniente de optantes do Simples Naciona
      ----
      vn_fase     := 1.8;
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --------------------------------
      vn_fase     :=2;
      /*Layout do Registro Tipo 20 – Identificação dos serviços relacionados ao Documentos Fiscal*/
       for rec_item in c_item(rec_nfs.id_nota) loop
          exit when c_item%notfound or (c_item%notfound) is null;
          gl_conteudo := null;
          gl_conteudo := '20';                                                                    --Descrição do registro (20).
          vn_fase     := 2.1;
          ----
          gl_conteudo := gl_conteudo||';'||vn_tp_serv;                                           --Tipo do serviço (1 - Serviço prestado; 2 - Serviço tomado).
          gl_conteudo := gl_conteudo||';'||lpad(vc_tp_doc,2,'0');                                --Tipo do Documento
          gl_conteudo := gl_conteudo||';'||lpad(rec_nfs.nro_nf,15,'0');                          --Número do documento.
          gl_conteudo := gl_conteudo||';'||to_char(rec_nfs.dt_emiss,'mm/rrrr');                  --Competência
          gl_conteudo := gl_conteudo||';'||vc_tp_prest;                                          --Tipo da pessoa do prestador
          gl_conteudo := gl_conteudo||';'||lpad(vc_cnpj_prest,14,'0');                           --CNPJ/CPF do prestador do serviço.
          gl_conteudo := gl_conteudo||';'||vc_tp_toma;                                           --Tipo da pessoa do tomador
          gl_conteudo := gl_conteudo||';'||lpad(vc_cnpj_toma,14,'0');                            --CPF / CNPJ do tomador
          gl_conteudo := gl_conteudo||';'||lpad(rec_item.cd_lista_serv,7,'0');                   --Código do item da lista de serviços da lei complementar 116.
          ----
          vn_fase     := 2.2;
          vn_aliq_srv := fkg_retorna_aliq(rec_item.cd_lista_serv);
          ----
          gl_conteudo := gl_conteudo||';'||lpad(vn_aliq_srv,6,'0');                               --Alíquota referente ao item da lista de serviços.
          gl_conteudo := gl_conteudo||';'||trim(replace(to_char(nvl(rec_item.VL_ITEM_BRUTO,0.00),'000000000000000D00'), ',', '.'));                      --Valor tributável (Base de cálculo da prestação de serviços).
          gl_conteudo := gl_conteudo||';'||trim(replace(to_char(nvl(rec_item.vl_deducao,0.00),'000000000000000D00'), ',', '.'));                         --Dedução
          ----
          --Valor retido.
          vn_fase     := 2.3;
          vn_vlr_ret  := fkg_retorna_vlrret(rec_item.id);
          gl_conteudo := gl_conteudo||';'||trim(replace(to_char(nvl(vn_vlr_ret,0.00),'000000000000000D00'), ',', '.'));    --Valor retido.
          ----
          gl_conteudo := gl_conteudo||';'||lpad(rec_item.cidade_ibge,7,'0');               --Local da prestação do serviço.          
          ----
          --Código da situação tributária da declaração do serviço.
          vn_fase     := 2.4;
          vn_tem_trib:= 0;
          vn_tem_trib:= fkg_retorna_temiss(rec_item.id);
          ----
          vn_fase     := 2.5;
          if vn_tem_trib> 0 then
            vc_st_dserv:='01';-- Tributada Integralmente com imposto sobre serviços retido na fonte
          else
            case rec_nfs.DM_NAT_OPER
              when '1' then vc_st_dserv:='00'; --Tributada Integralmente
              when '2' then vc_st_dserv:='13'; --Não Tributada - Recolhimento efetuado pelo prestador de fora do Município
              when '3' then vc_st_dserv:='06'; --Isenção
              when '4' then vc_st_dserv:='07'; --Imune
            end case;
          end if;
          gl_conteudo := gl_conteudo||';'||vc_st_dserv;
          ----
          vn_fase     := 2.6;
          --Tributa o ISS para o município do prestador do serviço (S - Sim; N - Não).
          if rec_nfs.DM_NAT_OPER ='2' then
            vn_trib_iss:='S';
          else
            vn_trib_iss:='N';
          end if;
          gl_conteudo := gl_conteudo||';'||vn_trib_iss;
          ----
          gl_conteudo := gl_conteudo||';'||rpad(' ',10)||';'; --Redução de ISS por obras - CEI
          ----
          vn_fase     := 2.7;
          pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      end loop;
      --------------------------------
      /*Layout do Registro Tipo 30 – Identificação da pessoa relacionada ao Documento Fiscal*/
      --------------------------------
     vn_fase     := 3;
     for rec_prest in c_prest(rec_nfs.id_prestador) loop
        exit when c_prest%notfound or (c_prest%notfound) is null;
        gl_conteudo := null;
        gl_conteudo := '30';                                                                  --Descrição do registro (30).
        gl_conteudo := gl_conteudo||';'||vc_tp_prest;                                         --Tipo da pessoa do prestador
        gl_conteudo := gl_conteudo||';'||lpad(nvl(vc_cnpj_prest,' '),14,' ');                              --CNPJ do prestador do serviço.
        gl_conteudo := gl_conteudo||';'||rpad(nvl(rec_prest.NOME,' '),40,' ');                             --Nome / Razão Social.
        gl_conteudo := gl_conteudo||';'||rpad(nvl(rec_prest.LOGRAD,' '),40,' ');                           --Descrição do logradouro.
        gl_conteudo := gl_conteudo||';'||rpad(nvl(rec_prest.NRO,' '),6,' ');                               --Nro. Residência / Estabelecimento.
        gl_conteudo := gl_conteudo||';'||rpad(nvl(rec_prest.COMPL,' '),20,' ');                            --Complemento do endereço.
        gl_conteudo := gl_conteudo||';'||rpad(nvl(rec_prest.BAIRRO,' '),20,' ');                           --Descrição do bairro.
        gl_conteudo := gl_conteudo||';'||rpad(nvl(rec_prest.Nome_cidade,' '),30,' ');                      --Nome da cidade.
        gl_conteudo := gl_conteudo||';'||rpad(nvl(rec_prest.SIGLA_ESTADO,' '),2,' ');                      --Estado (Unidade da Federação).
        gl_conteudo := gl_conteudo||';'||lpad(nvl(rec_prest.cep,0),8,'0');                         --Código de endereçamento postal.        
        gl_conteudo := gl_conteudo||';'||rpad(nvl(rec_prest.FONE,' '),12,' ');                             --Fone comercial (99 9999-9999).
        gl_conteudo := gl_conteudo||';'||rpad(nvl(rec_prest.FAX,' '),12,' ')||';';                              --Fax (99 9999-9999).
        ----
        vn_fase     := 3.1;
        pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
     end loop;
           --------------------------------
      /*Layout do Registro Tipo 40 – Informações sobre o plano de contas de empresa*/
      --Atende do Suporte Técnico informou que o registro 40 só é obrigatório para empresas cujo o segmento é financeiro.
      --------------------------------  
   
   end loop;
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_4211900 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_4211900;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade de Araras / SP
procedure pkb_gera_arq_cid_3503307 is
   --
   vn_fase                number         := 0;
   vn_vl_iss              number         := 0;
   vn_vl_base_calc        number         := 0;
   vn_vl_aliquota         number         := 0;
   vt_row_pessoa          pessoa%rowtype := null;
   vn_pessoa_id           number         := 0;
   vv_cd_lista_serv       varchar2(10)   := '0000000000';
   vn_vl_deducao          number         := 0;
   vn_dm_trib_mun_prest   number         := 0;
   vv_dm_trib_mun_prest   varchar2(2)    := null;
   vv_descr_cidade_t      cidade.descr%type := null;
   vv_descr_cidade_p      cidade.descr%type := null;
   vv_sigla_estado        estado.sigla_estado%type := null;
   vv_descr_pais           pais.descr%type := null;
   vv_im_tomador          varchar2(20)          := 0;
   vv_im_prestador        varchar2(20)          := 0;
   vn_count               number         := 0;
   vn_movimento           number         := 1;
   vn_emp_id          empresa.id%type := null;
   --

   
   cursor c_nf is
 select nf.id         notafiscal_id
   , nf.nro_nf
        , nf.serie
        , nf.dt_emiss
        , to_char(nf.dt_emiss,'yyyy-mm-dd') as dt_emiss2
        , nf.pessoa_id
        ,       CASE
                     WHEN length(inf.cd_lista_serv) > 3 THEN
                      substr(inf.cd_lista_serv, 1, 2) || '.' || substr(inf.cd_lista_serv, 3, 2)
                     WHEN length(inf.cd_lista_serv) = 3 THEN
                      substr(inf.cd_lista_serv, 1, 1) || '.' || substr(inf.cd_lista_serv, 2, 2)
                   END cd_lista_serv
        , nvl(sum(inf.qtde_comerc),0) qtde_comerc
        , nvl(sum(inf.qtde_comerc*inf.vl_unit_comerc),0)  vl_item_bruto
        , p.dm_tipo_pessoa
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , item_nota_fiscal inf
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and inf.cfop           in (1933,2933)
      and mf.cod_mod         in ('55','99') -- Serviços
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and nf.pessoa_id  in  (select  p.id   from pessoa p   where p.id in (nf.pessoa_id )  and p.cidade_id <> gn_cidade_id) --Municícpio do Prestador diferente do Município do Tomador
      and p.cidade_id        = gn_cidade_id--
      and inf.notafiscal_id  = nf.id
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
      group by nf.empresa_id ,nf.id        , nf.nro_nf     , nf.serie        , nf.dt_emiss         , nf.dt_emiss
             , nf.pessoa_id , cd_lista_serv , inf.qtde_comerc, p.dm_tipo_pessoa
      order by dt_emiss2, nro_nf;
   --
begin
   --
         begin
         --
         select e.pessoa_id, j.im, c.descr
           into vn_pessoa_id, vv_im_tomador, vv_descr_cidade_t
           from empresa e
              , pessoa p
              , juridica j
              , cidade c
          where e.id = gn_empresa_id
            and e.pessoa_id = p.id
            and p.id = j.pessoa_id
            and c.id = p.cidade_id;
         --
      exception
       when no_data_found then
          null;
      end;
  --


   --
   vn_fase := 1;
   --
   gl_conteudo := null;
   --
   -- MONTA O CABEÇALHO
   -- Campo 1
  gl_conteudo := '0SIGISS';
   -- Campo 2
   gl_conteudo := gl_conteudo || rpad('PREFEITURA MUNICIPAL DE ARARAS',50,' ');
   -- Campo 3
   gl_conteudo := gl_conteudo || TO_CHAR(sysdate,'DDMMYYYY');
   -- Campo 4
   gl_conteudo := gl_conteudo || '44215846000114';
   -- Campo 5
   gl_conteudo := gl_conteudo || 'Compliance';-- Soluções Fiscais';
   -- Campo 6
   gl_conteudo := gl_conteudo || '4         ';
   -- Campo 7
     if gn_en_tipo = 0 then
         gl_conteudo := gl_conteudo || ' ';
       elsif gn_en_tipo = 1 then
         gl_conteudo := gl_conteudo || '1';
     end if;
   --
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
     vt_row_pessoa := fkg_recupera_dados_pessoa ( en_pessoa_id => vn_pessoa_id );
   --
   -- Campo 8
   gl_conteudo :=  '1';
   -- Campo 9
   gl_conteudo := gl_conteudo ||   rpad(NVL(vt_row_pessoa.nome,' '),100,' ');
   -- Campo 10
   gl_conteudo := gl_conteudo ||   rpad(NVL(vt_row_pessoa.fantasia,' '),80,' ');
   -- Campo 11
   gl_conteudo := gl_conteudo ||   rpad(NVL(vt_row_pessoa.lograd,' '),60,' ');
   -- Campo 12
   gl_conteudo := gl_conteudo ||  rpad(NVL(vt_row_pessoa.nro,' '),10,' ');
   -- Campo 13
   gl_conteudo := gl_conteudo ||  rpad(NVL(vt_row_pessoa.compl,' '),40,' ');
   -- Campo 14
   gl_conteudo := gl_conteudo ||   rpad(NVL(vt_row_pessoa.bairro,' '),100,' ');
   -- Campo 15
   gl_conteudo := gl_conteudo ||  rpad(NVL(vv_descr_cidade_t,' '),100,' ');--
   -- Campo 16
   gl_conteudo := gl_conteudo ||  rpad(NVL(pk_csf.fkg_siglaestado_pessoaid ( en_pessoa_id => vn_pessoa_id ),' '),2,' ');
   -- Campo 17
   gl_conteudo := gl_conteudo ||  lpad(vt_row_pessoa.cep,8,'0');     --Código de endereçamento postal.
   -- Campo 18
   gl_conteudo := gl_conteudo || rpad(NVL(pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => gn_empresa_id ),' '),14,' ');
   -- Campo 19
   gl_conteudo := gl_conteudo ||  rpad(NVL(vv_im_tomador,' '),15,' ');
   -- Campo 20
   gl_conteudo := gl_conteudo || rpad(NVL(pk_csf.fkg_inscr_est_empresa( en_empresa_id => gn_empresa_id ),' '),15,' ');
   -- Campo 21
   gl_conteudo := gl_conteudo ||  rpad(NVL(vt_row_pessoa.fone,' '),44,' ');
   -- Campo 22
   gl_conteudo := gl_conteudo ||  rpad(NVL(vt_row_pessoa.email,' '),120,' ');
   -- Campo 23
   gl_conteudo := gl_conteudo || TO_CHAR(sysdate,'DDMMYYYY');
   -- Campo 24
   gl_conteudo := gl_conteudo || TO_CHAR(gd_dt_ini,'MM');
   -- Campo 25
   gl_conteudo := gl_conteudo || TO_CHAR(gd_dt_ini,'YYYY');
   --
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   -- Campo 26
   gl_conteudo :=   '2';
   -- Campo 27
   gl_conteudo := gl_conteudo ||   rpad(NVL(vt_row_pessoa.nome,' '),100,' ');
   -- Campo 28
   gl_conteudo := gl_conteudo ||   rpad(NVL(vt_row_pessoa.Fantasia,' '),80,' ');
   -- Campo 29
   gl_conteudo := gl_conteudo ||   rpad(NVL(vt_row_pessoa.lograd,' '),60,' ');
   -- Campo 30
   gl_conteudo := gl_conteudo ||  rpad(NVL(vt_row_pessoa.nro,' '),10,' ');
   -- Campo 31
   gl_conteudo := gl_conteudo ||  rpad(NVL(vt_row_pessoa.compl,' '),40,' ');
   -- Campo 32
   gl_conteudo := gl_conteudo ||   rpad(NVL(vt_row_pessoa.bairro,' '),100,' ');
   -- Campo 33
   gl_conteudo := gl_conteudo ||  rpad(NVL(vv_descr_cidade_t,' '),100,' ');
   -- Campo 34
   gl_conteudo := gl_conteudo ||  rpad(NVL(pk_csf.fkg_siglaestado_pessoaid ( en_pessoa_id => vn_pessoa_id),' '),2,' ');
   -- Campo 35
   gl_conteudo := gl_conteudo ||  lpad(vt_row_pessoa.cep,8,'0');     --Código de endereçamento postal.
   -- Campo 36
   gl_conteudo := gl_conteudo || rpad(NVL(pk_csf.fkg_cnpj_ou_cpf_empresa(en_empresa_id => gn_empresa_id),' '),14,' ');
   -- Campo 37
   gl_conteudo := gl_conteudo ||  rpad(NVL(vv_im_tomador,' '),15,' ');
   -- Campo 38
   gl_conteudo := gl_conteudo || rpad(NVL(pk_csf.fkg_inscr_est_empresa(en_empresa_id => gn_empresa_id),' '),15,' ');
   -- Campo 39
   gl_conteudo := gl_conteudo ||  rpad(NVL(vt_row_pessoa.fone,' '),44,' ');
   -- Campo 40
   gl_conteudo := gl_conteudo ||  rpad(NVL(vt_row_pessoa.email,' '),120,' ');
   -- Campo 41
   gl_conteudo := gl_conteudo || 'T'; 
   -- Campo 42
   gl_conteudo := gl_conteudo || 'O'; 
   -- Campo 43
  for rec in c_nf loop
   exit when c_nf%notfound or (c_nf%notfound) is null;
   vn_movimento := 2;
  end loop;
   if vn_movimento <> 1 then
     gl_conteudo := gl_conteudo || 'S';
     else
       gl_conteudo := gl_conteudo || 'N';
    end if;
   --
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   --
      for rec in c_nf loop
      exit when c_nf%notfound or (c_nf%notfound) is null;
   --
      begin
        select j.im,
               c.descr,
               e.sigla_estado,
               pa.descr,
               (select e.id from empresa e where e.pessoa_id = rec.pessoa_id) emp
          into vv_im_prestador,
               vv_descr_cidade_p,
               vv_sigla_estado,
               vv_descr_pais,
               vn_emp_id
          from pessoa p, 
               juridica j, 
               cidade c, 
               estado e, 
               pais pa
         where p.id           = rec.pessoa_id
           and j.pessoa_id(+) = p.id
           and p.cidade_id    = c.id
           and e.id           = c.estado_id
           and pa.id          = e.pais_id;
      exception
        when others then
          null;
      end;
      --

         begin
         --
         select distinct cast(nvl(sum(ii.vl_deducao),0) as decimal(15,2))
           into vn_vl_deducao
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.dm_tipo        = 1 -- Retenção
            and ti.id             = ii.tipoimp_id
            and ti.cd  in ('4', '5', '11', '12', '13');
         --
      exception
         when others then
         --
         vn_vl_deducao := 0;
         --
      end;
      --
        begin
         -- Recupera: Valor da Aliquota do serviço
         --           Valor do ISS - Imposto
         select 
                cast(nvl(imp.aliq_apli,0) as decimal(15,2))
              , cast(nvl(sum(imp.vl_imp_trib),0) as decimal(15,2))
           into vn_vl_aliquota
              , vn_vl_base_calc
           from item_nota_fiscal inf
              , imp_itemnf imp
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and imp.itemnf_id = inf.id
            and imp.dm_tipo = 1 -- Imposto
            and ti.id = imp.tipoimp_id
            and ti.cd = 6
            group by imp.aliq_apli; -- ISS
         --
      exception
          when others then  
            vn_vl_aliquota  := '0,00';
            vn_vl_base_calc := '0,00';
      end;
      --
              if rec.cd_lista_serv is not null then
         --
         vv_cd_lista_serv := rec.cd_lista_serv;
         --
      else
         --
         begin
            --
         select distinct CASE
                  WHEN TS.COD_LST LIKE ('%.%') THEN
                   TS.COD_LST
                  ELSE
                   CASE
                     WHEN length(ts.cod_lst) > 3 THEN
                      substr(ts.cod_lst, 1, 2) || '.' || substr(ts.cod_lst, 3, 2)
                     WHEN length(ts.cod_lst) = 3 THEN
                      substr(ts.cod_lst, 1, 1) || '.' || substr(ts.cod_lst, 2, 2)
                   END
                END
           into vv_cd_lista_serv
           from item_nota_fiscal inf, item i, tipo_servico ts
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.item_id = i.id
            and i.tpservico_id = ts.id;
            --
         exception
            when others then
            --
            vv_cd_lista_serv := null;
            --
         end;
         --
      end if;
      --
            -- Retenção na fonte
      begin
         --
      select distinct imp.dm_tipo
        into vn_dm_trib_mun_prest
        from imp_itemnf imp, item_nota_fiscal inf, nota_fiscal nf
       where imp.itemnf_id = inf.id
         and nf.id = inf.notafiscal_id
         and imp.tipoimp_id = 6
         and nf.id = rec.notafiscal_id;
         --
      exception
        when too_many_rows then
          --
          vn_dm_trib_mun_prest := '1';
          --
         when no_data_found then
         --
         vn_dm_trib_mun_prest := '0';
         --
        end;
      --
      if vn_dm_trib_mun_prest = 0 then
        vv_dm_trib_mun_prest := 'N';
      end if;
      if vn_dm_trib_mun_prest = 1 then
        vv_dm_trib_mun_prest := 'S';
      end if;



      vt_row_pessoa := fkg_recupera_dados_pessoa ( en_pessoa_id => rec.pessoa_id );
   --
  -- Campo 44
   gl_conteudo := '3' ;
   -- Campo 45
   gl_conteudo := gl_conteudo || rpad(NVL(vv_im_tomador,' '),15,' ');--5632
   -- Campo 46
   gl_conteudo := gl_conteudo || rpad(nvl(to_char(rec.nro_nf),' '),10,' ');
   -- Campo 47
   gl_conteudo := gl_conteudo || rpad(NVL(rec.serie,' '),3,' ');
   -- Campo 48
   gl_conteudo := gl_conteudo || rpad(nvl(TO_CHAR(rec.dt_emiss,'DDMMYYYY'),' '),8,' ');
   -- Campo 49
   gl_conteudo := gl_conteudo ||  rpad(NVL(vt_row_pessoa.nome,' '),100,' ');
   -- Campo 50
   if vn_emp_id is not null then
   gl_conteudo := gl_conteudo ||  rpad(NVL(pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => vn_emp_id),' '),14,' ');
   else
   gl_conteudo := gl_conteudo ||  rpad(NVL(pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec.pessoa_id),' '),14,' ');
   end if;
   -- Campo 51
   gl_conteudo := gl_conteudo ||  rpad(NVL(TO_CHAR(vv_im_prestador),' '),15,' ');
   -- Campo 52
   gl_conteudo := gl_conteudo ||  rpad(NVL(TO_CHAR(pk_csf.fkg_inscr_est_empresa( en_empresa_id => vn_emp_id),' '),' '),15,' ');
   -- Campo 53
     gl_conteudo := gl_conteudo ||  rpad(NVL(vt_row_pessoa.lograd,' '),60,' ');
   -- Campo 54
   gl_conteudo := gl_conteudo ||  rpad(NVL(vt_row_pessoa.nro,' '),10,' ');
   -- Campo 55
   gl_conteudo := gl_conteudo ||  rpad(NVL(vt_row_pessoa.compl,' '),40,' ');
   -- Campo 56
   gl_conteudo := gl_conteudo ||  rpad(NVL(vt_row_pessoa.bairro,' '),100,' ');
   -- Campo 57
   gl_conteudo := gl_conteudo ||  rpad(NVL(vv_descr_cidade_p,' '),100,' ');
   -- Campo 58
   gl_conteudo := gl_conteudo ||  rpad(NVL(pk_csf.fkg_siglaestado_pessoaid ( en_pessoa_id => rec.pessoa_id),' '),2,' ');
   -- Campo 59
   gl_conteudo := gl_conteudo ||  lpad(vt_row_pessoa.cep,8,'0');     --Código de endereçamento postal.
   -- Campo 60
   gl_conteudo := gl_conteudo ||  rpad(NVL(vt_row_pessoa.fone,' '),64,' ');
   -- Campo 61
   gl_conteudo := gl_conteudo ||  rpad(NVL(vt_row_pessoa.email,' '),120,' ');
   -- Campo 62
     if rec.dm_tipo_pessoa = 1 then
         gl_conteudo := gl_conteudo || 'N';
       elsif rec.dm_tipo_pessoa = 2 then
         gl_conteudo := gl_conteudo || 'S';
     end if;-- tipo pessoa
   -- Campo 63
   gl_conteudo := gl_conteudo ||  rpad(NVL(vv_descr_pais,' '),40,' ');
   -- Campo 64
gl_conteudo := gl_conteudo ||  rpad(trim(to_char(trunc(nvl(rec.vl_item_bruto,0), 2), '999999999999990D00', 'nls_numeric_characters=,.')),15,' '); -- Valor total do serviço
   -- Campo 65
   gl_conteudo := gl_conteudo ||  rpad(trim(to_char(trunc(nvl(vn_vl_deducao,0), 2), '999999999999990D00', 'nls_numeric_characters=,.')),15,' '); -- Valor de dedução
   -- Campo 66
   gl_conteudo := gl_conteudo ||  rpad(trim(to_char(trunc((nvl(rec.vl_item_bruto,0)-nvl(vn_vl_deducao,0)), 2), '999999999999990D00', 'nls_numeric_characters=,.')),15,' '); -- Valor total do serviço
   -- Campo 67
    gl_conteudo := gl_conteudo ||  rpad(trim(to_char(trunc(nvl(vn_vl_aliquota,0), 2), '999999999999990D00', 'nls_numeric_characters=,.')),12,' '); -- Valor total do
   -- Campo 68
   gl_conteudo := gl_conteudo ||  rpad(trim(to_char(trunc(nvl(vn_vl_base_calc,0), 2), '999999999999990D00', 'nls_numeric_characters=,.')),15,' '); -- Valor total do
   -- Campo 69
    gl_conteudo := gl_conteudo || rpad(NVL(vv_dm_trib_mun_prest,' '),1,' ');
    -- Campo 70
   gl_conteudo := gl_conteudo ||  'N';
   -- Campo 71
   gl_conteudo := gl_conteudo || rpad(NVL(vv_cd_lista_serv,' '),7,' ');
   --
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   vn_count := vn_count + 1;
   --

 --

   end loop;
   -- Campo 72
   gl_conteudo :=  '9';
   -- Campo 73
   gl_conteudo := gl_conteudo ||  vn_count;
   --
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --

exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_3503307 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_3503307;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço Tomados de Rio Quente / GO
procedure pkb_gera_arq_cid_5218789 is
  --
  vn_fase        number := 0;
  vn_qtde_linhas number := 0;
  --
  vv_cpf_cnpj        varchar2(14);
  vv_nome            pessoa.nome%type;
  vn_cep             pessoa.cep%type;
  vv_endereco        pessoa.lograd%type;
  vn_numero          pessoa.nro%type;
  vv_bairro          pessoa.bairro%type;
  vv_cidade          cidade.descr%type;
  vv_estado          estado.sigla_estado%type;
  vn_fone            pessoa.fone%type;
  vv_email           pessoa.email%type;
  vv_compl           pessoa.compl%type;
  vv_fantasia        pessoa.fantasia%type;
  vn_pais            pais.cod_siscomex%type;
  vv_ie              juridica.ie%type;
  vn_regesptrib      number := 0;
  vn_optantesim      number := 0;
  vn_empresa_id      empresa.id%type;
  vn_pessoa_id_prest pessoa.id%type;
  --
  vn_count number := 0;
  --
  vn_aliq_apli          imp_itemnf.aliq_apli%type := 0;
  vn_aliq_apli4         imp_itemnf.aliq_apli%type := 0;
  vn_aliq_apli5         imp_itemnf.aliq_apli%type := 0;
  vn_aliq_apli6         imp_itemnf.aliq_apli%type := 0;
  vn_aliq_apli11        imp_itemnf.aliq_apli%type := 0;
  vn_aliq_apli12        imp_itemnf.aliq_apli%type := 0;
  vn_aliq_apli13        imp_itemnf.aliq_apli%type := 0;
  vn_ret_iss            nota_fiscal_total.vl_ret_iss%type;
  vn_cod_trib_municipio cod_trib_municipio.cod_trib_municipio%type;
  vn_vl_desc_cond       nota_fiscal_total.vl_desc_cond%type;
  vn_vl_desc_incond     nota_fiscal_total.vl_desc_incond%type;
  vv_rg                 fisica.rg%type;
  --
  -- Dados da pessoa_id
  cursor c_pessoa(en_pessoa_id pessoa.id%type) is
    select pe.nome,
           pe.lograd,
           pe.nro,
           pe.compl,
           pe.bairro,
           ci.descr,
           es.sigla_estado,
           pe.cep,
           pe.email,
           pe.fone,
           pa.descr pais_descr,
           ju.ie,
           pe.dm_tipo_pessoa,
           ci.ibge_cidade,
           pa.cod_siscomex,
           pe.fantasia
      from pessoa pe, 
           cidade ci, 
           estado es, 
           pais pa, 
           juridica ju
     where pe.id = en_pessoa_id
       and ci.id = pe.cidade_id
       and es.id = ci.estado_id
       and pa.id = pe.pais_id
       and pe.id = ju.pessoa_id;
  --
  -- Dados do tipo de prestador
  cursor c_tpprest(en_pessoa_id pessoa.id%type) is
    select vt.cd cd_vlrtpparam
      from pessoa_tipo_param pt, 
           tipo_param tp, 
           valor_tipo_param vt
     where pt.pessoa_id         = en_pessoa_id
       and pt.tipoparam_id      = tp.id
       and vt.tipoparam_id      = tp.id
       and pt.valortipoparam_id = vt.id;
  --
  -- Dados das NF
  cursor c_nfs is
    select distinct nf.id notafiscal_id,
                    nf.nro_nf,
                    nf.serie,
                    nf.dt_emiss,
                    to_char(nf.dt_emiss, 'YYYY-MM-DD"T"HH:MM:SS') dt_emiss2,
                    --nf.pessoa_id pessoa_id_prest,
                    p.id pessoa_id_prest,
                    nf.empresa_id empresa_id_toma,
                    case
                      when length(inf.cd_lista_serv) > 3 then
                       substr(inf.cd_lista_serv, 1, 2) || '.' || substr(inf.cd_lista_serv, 3, 2)
                      when length(inf.cd_lista_serv) = 3 then
                       substr(inf.cd_lista_serv, 1, 1) || '.' || substr(inf.cd_lista_serv, 2, 2)
                    end cd_lista_serv,
                    sum(inf.qtde_comerc) qtde_comerc,
                    sum(inf.qtde_comerc * inf.vl_unit_comerc) vl_item_bruto,
                    p.cidade_id,
                    inf.id itemnf_id
      from nota_fiscal      nf,
           mod_fiscal       mf,
           empresa          e,
           pessoa           p,
           item_nota_fiscal inf
     where nf.empresa_id  = gn_empresa_id
       and nf.dm_ind_emit = gn_dm_ind_emit
       and nf.dm_st_proc  = 4
       and ((nf.dm_ind_emit = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
       and mf.id          = nf.modfiscal_id
       and inf.cfop       in (1933, 2933)
       -- and mf.cod_mod  = '99' -- Serviços
       and e.id           = nf.empresa_id
       and p.id           = e.pessoa_id
       --  and nf.pessoa_id  in  (select  p.id   from pessoa p   where p.id in (nf.pessoa_id )  and p.cidade_id <> gn_cidade_id) --Municícpio do Prestador diferente do Município do Tomador
       and p.cidade_id    = gn_cidade_id
       and nf.id          = inf.notafiscal_id
       and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
     group by nf.empresa_id,
              nf.id,
              nf.nro_nf,
              nf.serie,
              nf.dt_emiss, 
              --nf.pessoa_id,
              p.id,
              nf.empresa_id,
              cd_lista_serv,
              inf.qtde_comerc,
              p.cidade_id,
              inf.id
     order by dt_emiss, nro_nf;
  --
  cursor c_itens(en_notafiscal_id nota_fiscal.id%type) is
    select inf.qtde_comerc,
           inf.vl_unit_comerc,
           inf.unid_com,
           inf.descr_item,
           inf.vl_item_bruto
      from item_nota_fiscal inf
     where inf.notafiscal_id = en_notafiscal_id;
  --
  cursor c_imp_itemnf(en_itemnf_id item_nota_fiscal.id%type) is
    select imp.aliq_apli, imp.tipoimp_id
      from imp_itemnf imp
     where imp.itemnf_id = en_itemnf_id
       and imp.dm_tipo   = 1 -- Retido
     group by imp.aliq_apli, 
              imp.tipoimp_id;
  --
begin
  --
  vn_fase := 1;
  --
  begin
    select distinct p.id pessoa_id_prest
      into vn_pessoa_id_prest
      from nota_fiscal      nf,
           mod_fiscal       mf,
           empresa          e,
           pessoa           p,
           item_nota_fiscal inf
     where nf.empresa_id  = gn_empresa_id
       and nf.dm_ind_emit = gn_dm_ind_emit
       and nf.dm_st_proc  = 4
       and ((nf.dm_ind_emit = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
       and mf.id         = nf.modfiscal_id
       and inf.cfop      in (1933, 2933)
       and e.id          = nf.empresa_id
       and p.id          = e.pessoa_id
       and p.cidade_id   = gn_cidade_id
       and nf.id         = inf.notafiscal_id
       and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
       and rownum        = 1;
  exception
    when others then
      vn_pessoa_id_prest := null;
  end;

  --
  gl_conteudo := null;
  --
  -- Cabeçalho
  -- ====================
  gl_conteudo := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>';
  gl_conteudo := gl_conteudo || '<Declaracao>';
  gl_conteudo := gl_conteudo || '<Tomador>';
  gl_conteudo := gl_conteudo || '<CodEmpresa>1</CodEmpresa>';
  gl_conteudo := gl_conteudo || '<CpfCnpj>';
  gl_conteudo := gl_conteudo || '<Cnpj>' || lpad(nvl(pk_csf.fkg_cnpj_ou_cpf_empresa(en_empresa_id => gn_empresa_id), '0'), 14, '0') || '</Cnpj>';
  gl_conteudo := gl_conteudo || '</CpfCnpj>';
  gl_conteudo := gl_conteudo || '<InscricaoMunicipal>' || lpad(replace(replace(rtrim(pk_csf.fkg_inscr_mun_pessoa(en_pessoa_id => vn_pessoa_id_prest)), '-', ''), '.', ''), 15, 0) || '</InscricaoMunicipal>'; -- InscricaoMunicipal
  gl_conteudo := gl_conteudo || '</Tomador>';
  --
  gl_conteudo := gl_conteudo || '<Referencia>' || rtrim(substr(to_char(gd_dt_ini, 'MM/YYYY'), 1, 10)) || '</Referencia>'; 
  --
  vn_qtde_linhas := 0;
  --
  vn_fase := 2;
  --
  -- Armazena a estrutura do arquivo
  --pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
  --
  vn_fase := 3;
  --
  gl_conteudo := gl_conteudo || '<LoteNotaFiscalTomador>';
  --
  for rec_nfs in c_nfs loop
    exit when c_nfs%notfound or(c_nfs%notfound) is null;
    --
    vn_fase := 4;
    --
    -- Busca dados da pessoa_id do prestador
    for rec_pessoa in c_pessoa(rec_nfs.pessoa_id_prest) loop
      exit when c_pessoa%notfound or(c_pessoa%notfound) is null;
      --
      vv_nome     := rec_pessoa.nome; -- Nome
      vn_cep      := rec_pessoa.cep; -- Cep
      vv_endereco := rec_pessoa.lograd; -- Endereço
      vn_numero   := rec_pessoa.nro; -- Número
      vv_bairro   := rec_pessoa.bairro; -- Bairro
      vv_cidade   := rec_pessoa.ibge_cidade; -- Cidade
      vv_estado   := rec_pessoa.sigla_estado; -- Estado
      vn_fone     := rec_pessoa.fone; -- Fone
      vv_email    := rec_pessoa.email; -- email
      vn_pais     := rec_pessoa.cod_siscomex; -- País
      vv_compl    := rec_pessoa.compl; -- Compl
      vv_ie       := rec_pessoa.ie; -- Inscr. Estadual
      vv_fantasia := rec_pessoa.fantasia; -- Nome Fantasia
      --
      vv_cpf_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => rec_nfs.pessoa_id_prest);
      --
      -- Busca dados do tipo de prestador
      for rec_tpprest in c_tpprest(rec_nfs.pessoa_id_prest) loop
        exit when c_tpprest%notfound or(c_tpprest%notfound) is null;
        --
        --
        if rec_tpprest.cd_vlrtpparam = 2 then
          --
          vn_regesptrib := 2;
          --
        elsif rec_tpprest.cd_vlrtpparam = 1 then
          --
          vn_optantesim := 1;
          --
        else
          --
          vn_regesptrib := 0;
          vn_optantesim := 2;
          --
        end if;
        --
      end loop;
      --
    end loop;
    --
    -- Recupera as informações das alíquotas
    for rec_imp_itemnf in c_imp_itemnf(rec_nfs.itemnf_id) loop
      exit when c_imp_itemnf%notfound or(c_imp_itemnf%notfound) is null;
      --
      if rec_imp_itemnf.tipoimp_id = 4 then -- PIS
        --
        vn_aliq_apli4 := nvl(rec_imp_itemnf.aliq_apli, 0);
        --  
      elsif rec_imp_itemnf.tipoimp_id = 5 then -- COFINS
        --
        vn_aliq_apli5 := nvl(rec_imp_itemnf.aliq_apli, 0); 
        -- 
      elsif rec_imp_itemnf.tipoimp_id = 6 then -- ISS
        --
        vn_aliq_apli6 := nvl(rec_imp_itemnf.aliq_apli, 0);
        --  
      elsif rec_imp_itemnf.tipoimp_id = 11 then -- CSLL
        --
        vn_aliq_apli11 := nvl(rec_imp_itemnf.aliq_apli, 0);
        --  
      elsif rec_imp_itemnf.tipoimp_id = 12 then -- IRRF
        --
        vn_aliq_apli12 := nvl(rec_imp_itemnf.aliq_apli, 0);
        -- 
      elsif rec_imp_itemnf.tipoimp_id = 13  then -- INSS
        --
        vn_aliq_apli13 := nvl(rec_imp_itemnf.aliq_apli, 0);
        --   
      end if;
      --
    end loop;
    --
    vn_fase := 5;
    --
    -- Detalhes
    -- ====================
    --
    vn_qtde_linhas := nvl(vn_qtde_linhas, 0) + 1;
    --
    --gl_conteudo := gl_conteudo || '<LoteNotaFiscalTomador>';
    --
    gl_conteudo := gl_conteudo || '<NotaFiscalTomador>';
    gl_conteudo := gl_conteudo || '<InfDeclaracaoPrestacaoServicoTomador>';
    --
    gl_conteudo := gl_conteudo || '<DadosNotaFiscal>';
    gl_conteudo := gl_conteudo || '<IdentificacaoNotaFiscal>';
    gl_conteudo := gl_conteudo || '<Numero>' || rtrim(substr(rec_nfs.nro_nf, 1, 15)) || '</Numero>';
    gl_conteudo := gl_conteudo || '<Especie>1</Especie>';
    gl_conteudo := gl_conteudo || '<Serie>' || rtrim(substr(rec_nfs.serie, 1, 3)) || '</Serie>'; 
    gl_conteudo := gl_conteudo || '</IdentificacaoNotaFiscal>';
    gl_conteudo := gl_conteudo || '<DataEmissao>' || rec_nfs.dt_emiss2 || '</DataEmissao>'; 
    gl_conteudo := gl_conteudo || '</DadosNotaFiscal>';
    --
    gl_conteudo := gl_conteudo || '<Servico>';
    gl_conteudo := gl_conteudo || '<Aliquotas>';
    gl_conteudo := gl_conteudo || '<Aliquota>' || vn_aliq_apli6 || '</Aliquota>';
    --
    if nvl(vn_aliq_apli5, 0) > 0 then
      --
      gl_conteudo := gl_conteudo || '<AliquotaCofins>' || vn_aliq_apli5 || '</AliquotaCofins>';
      --
    end if;
    --
    if nvl(vn_aliq_apli11, 0) > 0 then
      --
      gl_conteudo := gl_conteudo || '<AliquotaCsll>' || vn_aliq_apli11 || '</AliquotaCsll>';
      --
    end if;
    --
    if nvl(vn_aliq_apli13, 0) > 0 then
      --
      gl_conteudo := gl_conteudo || '<AliquotaInss>' || vn_aliq_apli13 || '</AliquotaInss>';
      --
    end if;
    --
    if nvl(vn_aliq_apli12, 0) > 0 then
      --
      gl_conteudo := gl_conteudo || '<AliquotaIr>' || vn_aliq_apli12 || '</AliquotaIr>';
      --
    end if;
    --
    if nvl(vn_aliq_apli4, 0) > 0 then
      --
      gl_conteudo := gl_conteudo || '<AliquotaPis>' || vn_aliq_apli4 || '</AliquotaPis>';
      --
    end if;
    --
    gl_conteudo := gl_conteudo || '</Aliquotas>';
    --
    vn_fase := 7;
    --
    vn_aliq_apli := 0;
    --
    -- Recupera o valor retido de ISS
    begin
      select nft.vl_ret_iss
        into vn_ret_iss
        from nota_fiscal_total nft
       where nft.notafiscal_id = rec_nfs.notafiscal_id;
    exception
      when others then
        vn_ret_iss := 0;
    end;
    --
    if nvl(vn_ret_iss, 0) > 0 then
      --
      gl_conteudo := gl_conteudo || '<IssRetido>1</IssRetido>'; -- Imposto Retido
      --
    else
      --
      gl_conteudo := gl_conteudo || '<IssRetido>2</IssRetido>'; -- Não tem Imposto Retido
      --
    end if;
    --
    if vv_cidade is not null then
      --
      gl_conteudo := gl_conteudo || '<CodigoMunicipio>' || vv_cidade || '</CodigoMunicipio>';
      --
    end if;
    --
    if vn_pais is not null then
      --
      gl_conteudo := gl_conteudo || '<CodigoPais>' || vn_pais || '</CodigoPais>';
      --
    end if;
    --
    vn_fase := 8;
    --
    --
    gl_conteudo := gl_conteudo || '<CodAtividade>' || lpad(replace(replace(rec_nfs.cd_lista_serv, '-', ''), '.', ''), 6, 0) || '</CodAtividade>';
    --
    gl_conteudo := gl_conteudo || '<CodAtividadeDesdobro>0000004</CodAtividadeDesdobro>';
    gl_conteudo := gl_conteudo || '</Servico>';
    --
    gl_conteudo := gl_conteudo || '<Prestador>';
    gl_conteudo := gl_conteudo || '<IdentificacaoPrestador>';
    gl_conteudo := gl_conteudo || '<CodEmpresa>' || 1 || '</CodEmpresa>';
    gl_conteudo := gl_conteudo || '<CpfCnpj>';
    gl_conteudo := gl_conteudo || '<Cnpj>' || rtrim(substr(vv_cpf_cnpj, 1, 14)) || '</Cnpj>';
    gl_conteudo := gl_conteudo || '</CpfCnpj>';
    --
    if pk_csf.fkg_inscr_mun_pessoa(en_pessoa_id => rec_nfs.pessoa_id_prest) is not null then
      gl_conteudo := gl_conteudo || '<InscricaoMunicipal>' || rtrim(rpad(pk_csf.fkg_inscr_mun_pessoa(en_pessoa_id => rec_nfs.pessoa_id_prest), 7)) || '</InscricaoMunicipal>'; -- VERIFICAR
    end if;
    --
    gl_conteudo := gl_conteudo || '</IdentificacaoPrestador>';
    gl_conteudo := gl_conteudo || '<RazaoSocial>' || trim(rpad(pk_csf.fkg_nome_empresa(en_empresa_id => gn_empresa_id), 60, ' ')) || '</RazaoSocial>';
    --
    vn_fase := 9;
    --
    begin
      select fi.rg
        into vv_rg
        from fisica fi
       where fi.pessoa_id = rec_nfs.pessoa_id_prest;
    exception
      when others then
        vv_rg := null;
    end;
    --
    if vv_fantasia is not null then
      gl_conteudo := gl_conteudo || '<NomeFantasia>' || vv_fantasia || '</NomeFantasia>';
    end if;
    if vv_rg is not null then
      gl_conteudo := gl_conteudo || '<RgInscre>' || vv_rg || '</RgInscre>';
    end if;
    --
    gl_conteudo := gl_conteudo || '<Endereco>';
    --
    if vv_endereco is not null then
      gl_conteudo := gl_conteudo || '<Endereco>' || rtrim(substr(vv_endereco, 1, 200)) || '</Endereco>';
    end if;
    --
    if vn_numero is not null then
      gl_conteudo := gl_conteudo || '<Numero>' || rtrim(substr(nvl(vn_numero, 'SN'), 1, 6)) || '</Numero>';
    end if;
    --
    if vv_compl is not null then
      gl_conteudo := gl_conteudo || '<Complemento>' || rtrim(substr(vv_compl, 1, 60)) || '</Complemento>';
    end if;
    --
    if vv_bairro is not null then
      gl_conteudo := gl_conteudo || '<Bairro>' || rtrim(substr(vv_bairro, 1, 50)) || '</Bairro>';
    end if;
    --
    gl_conteudo := gl_conteudo || '<CodigoMunicipio>' || rtrim(substr(vv_cidade, 1, 50)) || '</CodigoMunicipio>';
    --
    if vv_estado is not null then
      gl_conteudo := gl_conteudo || '<Uf>' || vv_estado || '</Uf>';
    end if;
    --
    if vn_pais is not null then
      gl_conteudo := gl_conteudo || '<CodigoPais>' || rtrim(substr(vn_pais, 1, 30)) || '</CodigoPais>';
    end if;
    --
    if vn_cep is not null then
      gl_conteudo := gl_conteudo || '<Cep>' || rtrim(substr(vn_cep, 1, 8)) || '</Cep>';
    end if;
    --
    gl_conteudo := gl_conteudo || '</Endereco>';
    --
    gl_conteudo := gl_conteudo || '<Contato>';
    --
    if vn_fone is not null then
      gl_conteudo := gl_conteudo || '<Telefone>' || rtrim(vn_fone) || '</Telefone>';
    end if;
    --
    if vv_email is not null then
      gl_conteudo := gl_conteudo || '<Email>' || rtrim(vv_email) || '</Email>';
    end if;
    gl_conteudo := gl_conteudo || '</Contato>';
    --
    vn_fase := 10;
    --
    gl_conteudo := gl_conteudo || '<ExigibilidadeISS>1</ExigibilidadeISS>'; 
    --gl_conteudo := gl_conteudo || '<NumeroProcesso></NumeroProcesso>'; -- Não será enviado
    gl_conteudo := gl_conteudo || '<RegimeEspecialTributacao>' || vn_regesptrib || '</RegimeEspecialTributacao>';
    gl_conteudo := gl_conteudo || '<OptanteSimplesNacional>' || vn_optantesim || '</OptanteSimplesNacional>';
    gl_conteudo := gl_conteudo || '<IncentivoFiscal>1</IncentivoFiscal>';
    gl_conteudo := gl_conteudo || '</Prestador>';
    --
    vn_fase := 11;
    --
    begin
      select nft.vl_desc_cond, 
             nft.vl_desc_incond
        into vn_vl_desc_cond, 
             vn_vl_desc_incond
        from nota_fiscal_total nft
       where nft.notafiscal_id = rec_nfs.notafiscal_id;
    exception
      when others then
        null;
    end;
    --
    gl_conteudo := gl_conteudo || '<ItensNotas>';
    --
    for rec2 in c_itens(rec_nfs.notafiscal_id) loop
      --
      gl_conteudo := gl_conteudo || '<item>';
      gl_conteudo := gl_conteudo || '<DescriNfi>' || rec2.descr_item || '</DescriNfi>';
      gl_conteudo := gl_conteudo || '<MedidaNfi>' || rec2.unid_com || '</MedidaNfi>';
      gl_conteudo := gl_conteudo || '<QuantidadeNfi>' || rec2.qtde_comerc || '</QuantidadeNfi>';
      gl_conteudo := gl_conteudo || '<VlrUnitarioNfi>' || rec2.vl_unit_comerc || '</VlrUnitarioNfi>';
      --
      if nvl(vn_vl_desc_cond, 0) > 0 then
        gl_conteudo := gl_conteudo || '<DesccondicionalNfi>' || vn_vl_desc_cond || '</DesccondicionalNfi>';
      end if;
      --
      if nvl(vn_vl_desc_incond, 0) > 0 then
        gl_conteudo := gl_conteudo || '<DescincondicionalNfi>' || vn_vl_desc_incond || '</DescincondicionalNfi>';
      end if;
      --if  then
      --gl_conteudo := gl_conteudo || '<DeducaobaseNfi></DeducaobaseNfi>'; -- AGUARDANDO INFORMAÇÕES
      --end if;
      gl_conteudo := gl_conteudo || '</item>';
      --
    end loop;
    --
    gl_conteudo := gl_conteudo || '</ItensNotas>';
    gl_conteudo := gl_conteudo || '</InfDeclaracaoPrestacaoServicoTomador>';
    gl_conteudo := gl_conteudo || '</NotaFiscalTomador>';
    --
    vn_fase := 12;
    --
    -- Armazena a estrutura do arquivo
    --pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
    --
    vn_count := vn_count + 1;
  end loop;
  --
  vn_fase := 13;
  --
  -- Rodapé
  -- ====================
  --
  gl_conteudo := gl_conteudo || '</LoteNotaFiscalTomador>';
  gl_conteudo := gl_conteudo || '<QuantidadeNotas>' || vn_count || '</QuantidadeNotas>';
  gl_conteudo := gl_conteudo || '</Declaracao>';
  --
  vn_qtde_linhas := 0;
  --
  vn_fase := 14;
  --
  -- Armazena a estrutura do arquivo
  pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
  --
exception
  when others then
    raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_5218789 fase (' || vn_fase || '): ' || sqlerrm);
  
end pkb_gera_arq_cid_5218789;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade Mata de São João / BA
procedure pkb_gera_arq_cid_2921005 is
  --
  vn_fase           number;
  vn_pessoa_id      pessoa.id%type;
  vv_nome_tomador   pessoa.nome%type;
  vv_nome_prestador pessoa.nome%type;
  vn_tot_itens      number := 0;
  vn_tot_iss        number := 0; 
  --
  cursor c_nfs is
    select nf.id notafiscal_id,
           nf.nro_nf,
           nf.serie,
           nf.dt_emiss,
           pt.id tomador,
           pp.id prestador,
           --nf.pessoa_id prestador,
           nf.dm_ind_emit,
           ncs.dt_exe_serv,
           sum(nft.vl_total_serv) vl_total_nf,
           sum(ii.vl_base_calc) vl_base_calc_iss,
           sum(ii.vl_imp_trib) vl_iss,
           ii.aliq_apli aliq_iss,
           replace(replace(inf.cd_lista_serv, '.',''),',','') cod_serv,
           decode(nvl(pk_csf.fkg_pessoa_valortipoparam_cd('1', nf.pessoa_id), 0), 
                  0, 'N',
                  'S') simples_nacional
      from nota_fiscal       nf,
           mod_fiscal        mf,
           empresa           e,
           pessoa            pt, -- Tomador
           pessoa            pp, -- Prestador
           nf_compl_serv     ncs,
           item_nota_fiscal  inf,
           imp_itemnf        ii,
           tipo_imposto      ti,
           itemnf_compl_serv ics,
           nota_fiscal_total nft
     where nf.empresa_id    = gn_empresa_id
       and nf.dm_ind_emit   = gn_dm_ind_emit
       and nf.dm_st_proc    = 4
       and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
       and mf.id            = nf.modfiscal_id
       and mf.cod_mod       in ('99', '55')
       and inf.cd_lista_serv is not null
       and e.id             = nf.empresa_id
       and pt.id            = e.pessoa_id
       and pt.cidade_id     = gn_cidade_id
       and nf.id            = ncs.notafiscal_id(+)
       and nf.id            = inf.notafiscal_id
       and inf.id           = ics.itemnf_id(+)
       and nf.id            = nft.notafiscal_id
       and ii.itemnf_id     = inf.id
       and ti.id            = ii.tipoimp_id
       and ti.cd            = '6' -- ISS
       and ii.dm_tipo       = 1 -- Retenção
       and pp.id            = nf.pessoa_id
       and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
       and nf.pessoa_id     in (select p.id 
                                  from pessoa p   
                                 where p.id in (nf.pessoa_id )  
                                   and p.cidade_id <> gn_cidade_id) 
     group by nf.id,
              nf.nro_nf,
              nf.serie,
              nf.dt_emiss,
              pt.id,
              pp.id,
              nf.pessoa_id,
              nf.dm_ind_emit,
              ncs.dt_exe_serv,
              ii.aliq_apli,
              inf.cd_lista_serv 
     order by nf.id;
  --
begin
  --
  vn_fase := 1;
  --
  begin
    select p.id
      into vn_pessoa_id
      from empresa e, 
           pessoa p
     where e.id = gn_empresa_id
       and p.id = e.pessoa_id;
  exception
    when others then
      vn_pessoa_id := 0;
  end;
  --
  vn_fase := 2;
  --
  -- Caso encontre a pessoa, gera o arquivo
  if vn_pessoa_id > 0 then
    --
    vn_fase := 2.1;
    --
    vv_nome_tomador := pk_csf.fkg_nome_pessoa_id(en_pessoa_id => vn_pessoa_id);
    --
    vn_fase := 2.2;
    --
    gl_conteudo := 'A'; -- Identificação do registro (Header)
    gl_conteudo := gl_conteudo || '001'; -- Versão do leiaute do arquivo
    gl_conteudo := gl_conteudo || to_char(sysdate, 'DDMMYYYY'); -- Data da geração do arquivo
    gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => vn_pessoa_id), 0), 14, 0); -- CPF ou CNPJ do tomador
    gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_inscr_mun_pessoa(en_pessoa_id => vn_pessoa_id), 0), 20, ' '); -- Inscrição Municipal
    gl_conteudo := gl_conteudo || rpad(vv_nome_tomador, 70, ' '); -- Razão Social ou Nome Completo do tomador dos serviços
    gl_conteudo := gl_conteudo || to_char(gd_dt_fin,'MMYYYY'); -- Competência
    --
    vn_fase := 2.3;
    --
    -- Armazena a estrutura do arquivo
    pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
    --
    vn_fase := 2.4;
    --
    for rec in c_nfs loop
      --
      vn_fase := 2.5;
      --
      vv_nome_prestador := pk_csf.fkg_nome_pessoa_id(en_pessoa_id => rec.prestador);
      --
      gl_conteudo := 'B'; -- Identificação do registro (Detalhe)
      gl_conteudo := gl_conteudo || lpad(nvl(pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => rec.prestador), 0), 14, 0); -- CPF ou CNPJ do prestador
      gl_conteudo := gl_conteudo || rpad(vv_nome_prestador, 70, ' '); -- Razão Social ou Nome Completo do tomador dos serviços
      gl_conteudo := gl_conteudo || lpad(nvl(rec.nro_nf, 0), 20, ' '); -- Número do documento fiscal
      gl_conteudo := gl_conteudo || lpad(nvl(rec.serie, 0), 5, ' '); -- Série do documento fiscal
      gl_conteudo := gl_conteudo || lpad(to_char(rec.dt_emiss, 'DDMMYYYY'), 8, 0); -- Data de emissão do documento fiscal
      gl_conteudo := gl_conteudo || lpad('00000000', 8, 0); -- Data da quitação do documento fiscal
      gl_conteudo := gl_conteudo || lpad((nvl(rec.vl_total_nf, 0) * 100), 12, '0'); -- Valor do documento fiscal
      gl_conteudo := gl_conteudo || lpad((nvl(rec.vl_base_calc_iss, 0) * 100), 12, '0'); -- Valor da base de cálculo do ISS
      gl_conteudo := gl_conteudo || lpad((nvl(rec.aliq_iss, 0) * 100), 4, '0'); -- Alíquota do ISS
      gl_conteudo := gl_conteudo || lpad((nvl(rec.vl_iss, 0) * 100), 12, '0'); -- Valor do ISS
      gl_conteudo := gl_conteudo || lpad(nvl(rec.simples_nacional, 0), 1, 0); -- Optante Simples Nacional
      gl_conteudo := gl_conteudo || lpad(nvl(rec.cod_serv, 0), 4, 0); -- Código do serviço
      --
      vn_fase := 2.6;
      --
      -- Gera totalizadores para o registro "C"
      vn_tot_itens := vn_tot_itens + 1;
      vn_tot_iss   := vn_tot_iss + nvl(rec.vl_iss, 0);
      --
      vn_fase := 2.7;
      --
      -- Armazena a estrutura do arquivo
      pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
      --
      vn_fase := 2.8;
      --
    end loop;
    --
    vn_fase := 2.9;
    --
    gl_conteudo := 'C'; -- Identificação do registro (Footer)
    gl_conteudo := gl_conteudo || lpad(nvl(vn_tot_itens, 0), 9, 0); -- Quantidade de registros do tipo "B" (Detalhe) 
    gl_conteudo := gl_conteudo || lpad((nvl(vn_tot_iss, 0) * 100), 12, '0'); -- Total de ISS 
    --
    vn_fase := 2.10;
    --
    -- Armazena a estrutura do arquivo
    pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
    --
    vn_fase := 2.11;
    --
  end if;
  --
  vn_fase := 3;
  --
exception
  when others then
    raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_2921005 fase (' || vn_fase || '): ' || sqlerrm);
end pkb_gera_arq_cid_2921005;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Cidade Florianópolis / SC
---------------------------------------------------------------------------------------------------------------------
procedure pkb_gera_arq_cid_4205407 is
  --
  vn_fase number;
  --
  cursor c_cont is
    select replace(replace(nvl(jc.im, ' '), '.', ''), '-', '') CMCdoContribuinte,
           nvl(pk_csf.fkg_cnpj_ou_cpf_empresa(en_empresa_id => e.id), ' ') CNPJdoContribuinte,
           nvl(pc.nome, ' ') RazaoContribuinte,
           nvl(pc.fantasia, ' ') NomeContribuinte,
           nvl(jc.ie, ' ') InscricaoEstadualContribuinte,
           nvl(jc.nire, 0) JuntaComercial,
           nvl(pc.lograd, ' ') EnderecoContribuinte,
           nvl(pc.nro, ' ') NumeroContribuinte,
           nvl(pc.compl, ' ') ComplementoContribuinte,
           nvl(pc.bairro, ' ') BairroContribuinte,
           nvl(c.descr, ' ') CidadeContribuinte,
           nvl(es.sigla_estado, ' ') UFContribuinte,
           nvl(pc.cep, 0) CEPContribuinte,
           nvl(substr(pc.fone, 1, 2), ' ') DDDContribuinte,
           nvl(substr(pc.fone, 3, 8), ' ') FoneContribuinte,
           nvl(pc.fax, ' ') FaxContribuinte,
           nvl(pc.email, ' ') EmailContribuinte
      from nota_fiscal nf,
           empresa     e,
           pessoa      pc,
           juridica    jc,
           cidade      c,
           estado      es
     where nf.empresa_id   = gn_empresa_id
       and nf.dm_ind_emit  = gn_dm_ind_emit
       and nf.dm_st_proc   = 4 -- Autorizada
       and ((nf.dm_ind_emit = 1 and to_date(nvl(nf.dt_sai_ent, nf.dt_emiss), 'dd/mm/rrrr') between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and to_date(nf.dt_emiss, 'dd/mm/rrrr') between gd_dt_ini and gd_dt_fin) 
             or 
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_date(nf.dt_emiss, 'dd/mm/rrrr') between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and to_date(nvl(nf.dt_sai_ent, nf.dt_emiss), 'dd/mm/rrrr') between gd_dt_ini and gd_dt_fin))
       and nf.empresa_id   = e.id
       and e.pessoa_id     = pc.id
       and jc.pessoa_id    = pc.id
       and pc.cidade_id    = c.id
       and c.estado_id     = es.id
       and pc.cidade_id    = gn_cidade_id
       and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
     group by jc.im,
              jc.num_cnpj,
              pc.fantasia,
              pc.nome,
              jc.ie,
              jc.nire,
              pc.lograd,
              pc.nro,
              pc.compl,
              pc.bairro,
              c.descr,
              es.sigla_estado,
              pc.cep,
              pc.fone,
              pc.fax,
              pc.email,
              e.id;

  cursor c_prest is
    select case
             when pp.cidade_id = (select c.id from cidade c where c.ibge_cidade = 4205407) then
              replace(replace(nvl(jp.im, ' '), '.', ''), '-', '')
             else
              ' '
           end CMCdoPrestador,
           nvl(pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => pp.id), ' ') CNPJdoPrestador,
           nvl(pp.nome, ' ') RazaoPrestador,
           nvl(pp.fantasia, ' ') NomePrestador,
           nvl(jp.ie, ' ') InscricaoEstadualPrestador,
           nvl(pp.lograd, ' ') EnderecoPrestador,
           nvl(pp.nro, ' ') NumeroPrestador,
           nvl(pp.compl, ' ') ComplementoPrestador,
           nvl(pp.bairro, ' ') BairroPrestador,
           nvl(pp.cep, 0) CEPPrestador,
           nvl(c.descr, ' ') CidadePrestador,
           nvl(es.sigla_estado, ' ') UFPrestador,
           nvl(substr(pp.fone, 1, 2), ' ') DDDPrestador,
           nvl(substr(pp.fone, 3, 8), ' ') FonePrestador,
           0 GraficaPrestador -- Não é gráfica 
      from nota_fiscal nf, 
           pessoa pp, 
           juridica jp, 
           cidade c, 
           estado es
     where nf.empresa_id  = gn_empresa_id
       and nf.dm_ind_emit = gn_dm_ind_emit
       and nf.dm_st_proc  = 4
       and ((nf.dm_ind_emit = 1 and to_date(nvl(nf.dt_sai_ent, nf.dt_emiss), 'dd/mm/rrrr') between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and to_date(nf.dt_emiss, 'dd/mm/rrrr') between gd_dt_ini and gd_dt_fin) 
             or 
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_date(nf.dt_emiss, 'dd/mm/rrrr') between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and to_date(nvl(nf.dt_sai_ent, nf.dt_emiss), 'dd/mm/rrrr') between gd_dt_ini and gd_dt_fin))
       and nf.pessoa_id   = pp.id
       and jp.pessoa_id   = pp.id
       and pp.cidade_id   = c.id
       and c.estado_id    = es.id
       and pp.cidade_id   = gn_cidade_id
       and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
     group by pp.cidade_id,
              jp.im,
              pp.fantasia,
              pp.id,
              pp.nome,
              jp.ie,
              pp.lograd,
              pp.nro,
              pp.compl,
              pp.bairro,
              pp.cep,
              c.descr,
              es.sigla_estado,
              pp.fone;

  cursor c_nfs is
    select nvl(pk_csf.fkg_cnpj_ou_cpf_empresa(en_empresa_id => e.id), ' ') CNPJdoContribuinte,
           replace(replace(nvl(jc.im, ' '), '.', ''), '-', '') CMCdoContribuinte,
           case
             when pp.cidade_id =
                  (select c.id from cidade c where c.ibge_cidade = 4205407) then
              replace(replace(nvl(jp.im, ' '), '.', ''), '-', '')
             else
              ' '
           end CMCdoPrestador,
           nvl(pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => nf.pessoa_id), ' ') CNPJdoPrestador,
           nvl(nf.nro_nf, 0) NotaFiscal,
           nvl(nf.serie, ' ') Serie,
           nvl(ics.cnae, 0) CNAE,
           to_char(nf.dt_emiss, 'ddmmyyyy') DataEmissao,
           max(nvl(nft.vl_total_nf, 0)) ValorContabil,
           sum(nvl(ii.vl_base_calc, 0)) BasedeCalculo,
           nvl(na.conteudo, ' ') Obs,
           nvl(ct.cod_trib_municipio, 0) CFPS,
           nvl(ncs.dm_nat_oper, 0) CST,
           nvl(ii.aliq_apli, 0) Aliquota,
           sum(nvl(ii.vl_imp_trib, 0)) ValordoISS
      from nota_fiscal        nf,
           item_nota_fiscal   inf,
           imp_itemnf         ii,
           tipo_imposto       ti,
           itemnf_compl_serv  ics,
           nfinfor_adic       na,
           nf_compl_serv      ncs,
           nota_fiscal_total  nft,
           mod_fiscal         mf,
           empresa            e,
           pessoa             pc,
           juridica           jc,
           pessoa             pp,
           juridica           jp,
           cod_trib_municipio ct
     where nf.empresa_id        = gn_empresa_id
       and nf.dm_ind_emit       = gn_dm_ind_emit
       and nf.dm_st_proc        = 4 -- Autorizada
       and ((nf.dm_ind_emit = 1 and to_date(nvl(nf.dt_sai_ent, nf.dt_emiss), 'dd/mm/rrrr') between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and to_date(nf.dt_emiss, 'dd/mm/rrrr') between gd_dt_ini and gd_dt_fin) 
             or 
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_date(nf.dt_emiss, 'dd/mm/rrrr') between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and to_date(nvl(nf.dt_sai_ent, nf.dt_emiss), 'dd/mm/rrrr') between gd_dt_ini and gd_dt_fin))
       and nf.id                = inf.notafiscal_id
       and inf.id               = ii.itemnf_id
       and ti.id                = ii.tipoimp_id
       and ti.cd                = '6' -- ISS
       and ((mf.cod_mod = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
       and na.notafiscal_id(+)  = nf.id
       and ncs.notafiscal_id(+) = nf.id
       and nft.notafiscal_id(+) = nf.id
       and e.id                 = nf.empresa_id
       and pc.id                = e.pessoa_id
       and jc.pessoa_id         = pc.id
       and pp.id                = nf.pessoa_id
       and jp.pessoa_id         = pp.id
       and ics.itemnf_id        = inf.id
       and ct.id(+)             = ics.codtribmunicipio_id
       and pp.cidade_id         = gn_cidade_id
       and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
     group by jc.im,
              pp.cidade_id,
              jp.im,
              nf.pessoa_id,
              nf.nro_nf,
              nf.serie,
              ics.cnae,
              to_char(nf.dt_emiss, 'ddmmyyyy'),
              na.conteudo,
              ct.cod_trib_municipio,
              ncs.dm_nat_oper,
              ii.aliq_apli,
              e.id;
  --
begin
  --
  vn_fase := 1;
  --
  -- Header ou Cabeçalho
  gl_conteudo := 'H'; -- Tipo do Registro
  --
  -- Armazena a estrutura do arquivo
  pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
  --
  vn_fase := 2;
  --
  -- Contribuinte
  for rec in c_cont loop
    exit when c_cont%notfound or(c_cont%notfound) is null;
    --
    vn_fase := 2.1;
    --
    gl_conteudo := 'C'; -- Tipo do Registro
    gl_conteudo := gl_conteudo || lpad(rec.CMCdoContribuinte, 7, 0); -- CMC 
    gl_conteudo := gl_conteudo || lpad(rec.CNPJdoContribuinte, 14, 0); -- CNPJ 
    gl_conteudo := gl_conteudo || lpad(rec.RazaoContribuinte, 80, ' '); -- Razão
    gl_conteudo := gl_conteudo || rpad(rec.NomeContribuinte, 50, ' '); -- Nome 
    gl_conteudo := gl_conteudo || lpad(rec.InscricaoEstadualContribuinte, 20, ' '); -- Inscrição Estadual 
    gl_conteudo := gl_conteudo || rpad(rec.JuntaComercial, 20, ' '); -- Junta Comercial
    gl_conteudo := gl_conteudo || lpad(rec.EnderecoContribuinte, 80, ' '); -- Endereço
    gl_conteudo := gl_conteudo || lpad(rec.NumeroContribuinte, 10, ' '); -- Número
    gl_conteudo := gl_conteudo || lpad(rec.ComplementoContribuinte, 30, ' '); -- Complemento 
    gl_conteudo := gl_conteudo || lpad(rec.BairroContribuinte, 50, ' '); -- Bairro
    gl_conteudo := gl_conteudo || lpad(rec.CidadeContribuinte, 50, ' '); -- Cidade
    gl_conteudo := gl_conteudo || lpad(rec.UFContribuinte, 2, ' '); -- UF
    gl_conteudo := gl_conteudo || lpad(rec.CEPContribuinte, 8, ' '); -- CEP
    gl_conteudo := gl_conteudo || lpad(rec.DDDContribuinte, 2, ' '); -- DDD
    gl_conteudo := gl_conteudo || lpad(rec.FoneContribuinte, 8, ' '); -- Fone
    gl_conteudo := gl_conteudo || lpad(rec.FaxContribuinte, 8, ' '); -- Fax
    gl_conteudo := gl_conteudo || lpad(rec.EmailContribuinte, 80, ' '); -- Email
    --
    vn_fase := 2.2;
    --
    -- Armazena a estrutura do arquivo
    pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
    --
    vn_fase := 2.3;
    --
  end loop; -- c_cont
  --
  vn_fase := 3;
  --
  -- Prestadores, Tomadores de Servico, e Grafica que emite o Talonario do Contribuinte.
  for rec in c_prest loop
    exit when c_prest%notfound or(c_prest%notfound) is null;
    --
    vn_fase := 3.1;
    --
    gl_conteudo := 'P'; -- Tipo do Registro
    gl_conteudo := gl_conteudo || lpad(rec.CMCdoPrestador, 7, 0); -- CMC 
    gl_conteudo := gl_conteudo || lpad(rec.CNPJdoPrestador, 14, ' '); -- CNPJ 
    gl_conteudo := gl_conteudo || lpad(rec.RazaoPrestador, 80, ' '); -- Razão
    gl_conteudo := gl_conteudo || rpad(rec.NomePrestador, 50, ' '); -- Nome 
    gl_conteudo := gl_conteudo || lpad(rec.EnderecoPrestador, 80, ' '); -- Endereço
    gl_conteudo := gl_conteudo || lpad(rec.NumeroPrestador, 10, ' '); -- Número
    gl_conteudo := gl_conteudo || lpad(rec.ComplementoPrestador, 30, ' '); -- Complemento 
    gl_conteudo := gl_conteudo || lpad(rec.BairroPrestador, 50, ' '); -- Bairro
    gl_conteudo := gl_conteudo || lpad(rec.CEPPrestador, 8, 0); -- CEP
    gl_conteudo := gl_conteudo || lpad(rec.CidadePrestador, 50, ' '); -- Cidade
    gl_conteudo := gl_conteudo || lpad(rec.UFPrestador, 2, ' '); -- UF
    gl_conteudo := gl_conteudo || lpad(substr(rec.DDDPrestador, 1, 2), 2, ' '); -- DDD
    gl_conteudo := gl_conteudo || lpad(substr(rec.FonePrestador, 3, 8), 8, ' '); -- Fone
    gl_conteudo := gl_conteudo || lpad(rec.GraficaPrestador, 8, ' '); -- Gráfica
    --
    vn_fase := 3.2;
    --
    -- Armazena a estrutura do arquivo
    pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
    --
    vn_fase := 3.3;
    --
  end loop; -- c_prest
  --
  vn_fase := 4;
  --
  -- Nota Fiscal Recebida
  for rec in c_nfs loop
    exit when c_nfs%notfound or(c_nfs%notfound) is null;
    --
    vn_fase := 4.1;
    --   
    gl_conteudo := 'R'; -- Tipo do Registro
    gl_conteudo := gl_conteudo || lpad(rec.CMCdoContribuinte, 7, 0); -- CMC do contribuinte
    gl_conteudo := gl_conteudo || lpad(rec.CNPJdoContribuinte, 14, 0); -- CNPJ do Contribuinte
    gl_conteudo := gl_conteudo || lpad(rec.CMCdoPrestador, 7, 0); -- CMC do prestador
    gl_conteudo := gl_conteudo || rpad(rec.CNPJdoPrestador, 14, ' '); -- CNPJ do Prestador
    gl_conteudo := gl_conteudo || lpad(rec.NotaFiscal, 15, 0); -- Número da Nota Fiscal
    gl_conteudo := gl_conteudo || rpad(rec.Serie, 10, ' '); -- Série
    gl_conteudo := gl_conteudo || lpad(nvl(rec.CNAE, 0), 11, 0); -- CNAE
    gl_conteudo := gl_conteudo || lpad(rec.DataEmissao, 8, 0); -- Data Emissão Nota Fiscal
    gl_conteudo := gl_conteudo || lpad((nvl(rec.ValorContabil, 0) * 100), 18, 0); -- Valor Contábil
    gl_conteudo := gl_conteudo || lpad((nvl(rec.BasedeCalculo, 0) * 100), 18, 0); -- Base de Cálculo
    gl_conteudo := gl_conteudo || rpad(rec.Obs, 100, ' '); -- Obs
    gl_conteudo := gl_conteudo || lpad(nvl(rec.CFPS, 0), 4, 0); -- CFPS
    gl_conteudo := gl_conteudo || lpad(nvl(rec.CST, 0), 3, 0); -- CST
    gl_conteudo := gl_conteudo || lpad((nvl(rec.Aliquota, 0) * 100), 18, 0); -- Alíquota
    gl_conteudo := gl_conteudo || lpad((nvl(rec.ValordoISS, 0) * 100), 18, 0); -- Valor do ISS
    --
    vn_fase := 4.2;
    --
    -- Armazena a estrutura do arquivo
    pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
    --
    vn_fase := 4.3;
    --
  end loop; -- c_nfs
  --
  vn_fase := 5;
  --
  -- Trailer ou fim de arquivo
  gl_conteudo := 'L'; -- Tipo do Registro
  --
  -- Armazena a estrutura do arquivo
  pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
  -- 
  vn_fase := 6;
  --
exception
  when others then
    raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_4205407 fase (' || vn_fase || '): ' || sqlerrm);
end pkb_gera_arq_cid_4205407;

---------------------------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço da Volta Redonda / RJ
procedure pkb_gera_arq_cid_3306305 is
   --
   vn_fase                number         := 0;
   vn_vl_iss              number         := 0;
   vn_vl_base_calc        number         := 0;
   vn_vl_aliquota         number         := 0;
   vn_vl_outras           number         := 0;
   vv_cpf_cnpj_prestador  varchar2(14)   := null;
   vn_tipo_cpf_cnpj       number         := 0;
   vt_row_pessoa          pessoa%rowtype := null;
   vn_pessoa_id           number         := 0;
   vn_empresa_id          number         := 0;
   vn_nat_oper            number         := 1;
   vv_cd_lista_serv       varchar2(10)   := '0000000000';
   vn_vl_deducao          number         := 0;
   vn_dm_trib_mun_prest   number         := -1;
   vn_pessoa_id_trib      number         := 0; -- ID da pessoa em que o municipio será tributado o imposto
   vv_ibge_cidade         cidade.ibge_cidade%type := null;
   vv_sigla_estado        estado.sigla_estado%type := null;
   vv_im                  number         := 0;
   vv_ibge_cidade_p       number         := 0;
   vn_iss_tributavel      number         := 0; -- 1 - ISS tributável na nota; 2 - ISS não tributável
   vv_simpl_nac       valor_tipo_param.cd%type := null;
   --
   cursor c_nf is
   select nf.id         notafiscal_id
   , nf.nro_nf
        , nf.serie
        , nf.dt_emiss
        , to_char(nf.dt_emiss,'yyyy-mm-dd') as dt_emiss2
        , nf.pessoa_id
        ,       CASE
                     WHEN length(inf.cd_lista_serv) > 3 THEN
                      substr(inf.cd_lista_serv, 1, 2) || '.' || substr(inf.cd_lista_serv, 3, 2)
                     WHEN length(inf.cd_lista_serv) = 3 THEN
                      substr(inf.cd_lista_serv, 1, 1) || '.' || substr(inf.cd_lista_serv, 2, 2)
                   END cd_lista_serv
        , sum(inf.qtde_comerc) qtde_comerc    
        , sum(inf.qtde_comerc*inf.vl_unit_comerc) vl_item_bruto  
        , nf.dm_st_proc
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , item_nota_fiscal inf
    where nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and mf.id              = nf.modfiscal_id
      and inf.cfop           in (1933,2933)
      --and mf.cod_mod         = '99' -- Serviços
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id
      and nf.pessoa_id  in  (select  p.id   from pessoa p   where p.id in (nf.pessoa_id )  and p.cidade_id <> gn_cidade_id) --Municícpio do Prestador diferente do Município do Tomador
      and p.cidade_id        = gn_cidade_id
      and inf.notafiscal_id  = nf.id
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
      group by nf.empresa_id ,nf.id        , nf.nro_nf     , nf.serie        , nf.dt_emiss         , nf.dt_emiss  
             , nf.pessoa_id , cd_lista_serv , inf.qtde_comerc , nf.dm_st_proc
      order by dt_emiss2, nro_nf;
   --
begin
   --
   vn_fase := 1;
   --
   -- MONTA O CABEÇALHO
   gl_conteudo := '1';
   gl_conteudo := gl_conteudo || '|' || pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => gn_empresa_id ); -- CNPJ do tomador
   gl_conteudo := gl_conteudo || '|' || pk_csf.fkg_inscr_mun_empresa ( en_empresa_id => gn_empresa_id ); -- Inscrição municipal do tomador
   gl_conteudo := gl_conteudo || '|A'; -- Aquisição de serviços
   gl_conteudo := gl_conteudo || '|' || pk_csf.fkg_ibge_cidade_empresa ( en_empresa_id => gn_empresa_id ); -- Código do IBGE do municipio do tomador
   gl_conteudo := gl_conteudo || '|';
   --
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   -- MONTA O CORPO DO ARQUIVO
   for rec in c_nf loop
      exit when c_nf%notfound or (c_nf%notfound) is null;
      --
      vv_simpl_nac := pk_csf.fkg_pessoa_valortipoparam_cd( ev_tipoparam_cd => 1 -- Simples Nacional
                                                         , en_pessoa_id    => rec.pessoa_id );
      gl_conteudo := '2';
      --
      -- Dados do documento fiscal
      -- Campo 1
      gl_conteudo := gl_conteudo || '|' || rec.nro_nf;
      -- Campo 2
      gl_conteudo := gl_conteudo || '|' || rec.serie;
      -- Campo 3
      gl_conteudo := gl_conteudo || '|1'; -- Tipo de documento => 1 - Nota Fiscal
      -- Campo 4
      gl_conteudo := gl_conteudo || '|' || rec.dt_emiss2;
      -- Recupera o Código da Natureza da Operação
      begin
         --
         select nvl(dm_nat_oper,1)
           into vn_nat_oper
           from nf_compl_serv
          where notafiscal_id = rec.notafiscal_id;
         --
      exception
         when others then
         --
         vn_nat_oper := 1;
         --
      end;
      -- Campo 5
      gl_conteudo := gl_conteudo || '|' || vn_nat_oper; -- Código da Natureza da Operação
      --
      if nvl(vv_simpl_nac, '0') = '1' then
      -- Campo 6
      gl_conteudo := gl_conteudo || '|6'; -- Código de identificação do Regime Especial de Tributação = > 6 – Microempresário e Empresa de Pequeno Porte (ME EPP)
    else
      gl_conteudo := gl_conteudo || '|7';-- Código de identificação do Regime Especial de Tributação = > 7 – Tributação por Faturamento (Variável)
    end if;
      --
      if nvl(vv_simpl_nac, '0') = '1' then
      -- Campo 7
      gl_conteudo := gl_conteudo || '|1'; -- Enquadramento no Simples Nacional do Tomador de Serviços
    else
      gl_conteudo := gl_conteudo || '|2';
    end if;
      -- Campo 8
      gl_conteudo := gl_conteudo || '|' || rec.dm_st_proc; -- Status da Nota Fiscal => 1 - Ativa
      -- Campo 9
      gl_conteudo := gl_conteudo || '|'; -- Outras informações
      -- Código de especificação da Atividade
      if rec.cd_lista_serv is not null then
         --
         vv_cd_lista_serv := rec.cd_lista_serv;
         --
      else
         --
         begin
            --
         select distinct CASE
                  WHEN TS.COD_LST LIKE ('%.%') THEN
                   TS.COD_LST
                  ELSE
                   CASE
                     WHEN length(ts.cod_lst) > 3 THEN
                      substr(ts.cod_lst, 1, 2) || '.' || substr(ts.cod_lst, 3, 2)
                     WHEN length(ts.cod_lst) = 3 THEN
                      substr(ts.cod_lst, 1, 1) || '.' || substr(ts.cod_lst, 2, 2)
                   END
                END
           into vv_cd_lista_serv
           from item_nota_fiscal inf, item i, tipo_servico ts
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.item_id = i.id
            and i.tpservico_id = ts.id;
            --
         exception
            when others then
            --
            vv_cd_lista_serv := null;
            --
         end;
         --
      end if;
      -- Campo 10
      gl_conteudo := gl_conteudo || '|' || vv_cd_lista_serv;
      -- Campo 11
      gl_conteudo := gl_conteudo || '|' || trim(to_char(trunc(rec.vl_item_bruto, 2), '999999999999990d00', 'nls_numeric_characters=.,')); -- Valor total do serviço
       --
      begin
         --
         select distinct nvl(sum(ii.vl_deducao),0)
           into vn_vl_deducao
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.dm_tipo        = 1 -- Retenção
            and ti.id             = ii.tipoimp_id
            and ti.cd  in ('4', '5', '11', '12', '13');
         --
      exception
         when others then
         --
         vn_vl_deducao := 0; 
         --
      end;
      -- Campo 12
      gl_conteudo := gl_conteudo || '|' || trim(to_char(trunc(vn_vl_deducao, 2), '999999999999990d00', 'nls_numeric_characters=.,')); -- Valor de dedução
      --
      -- Retenção na fonte
      begin
         --
      select distinct imp.dm_tipo  
        into vn_dm_trib_mun_prest
        from imp_itemnf imp, item_nota_fiscal inf, nota_fiscal nf
       where imp.itemnf_id = inf.id
         and nf.id = inf.notafiscal_id
         and imp.tipoimp_id = 6
         and nf.id = rec.notafiscal_id;
         --
      exception
        when too_many_rows then
          --
          vn_dm_trib_mun_prest := 1;
          --      
         when no_data_found then
         --
         vn_dm_trib_mun_prest := 2;
         --
        end;
      --
      if vn_dm_trib_mun_prest = 0 then
        vn_dm_trib_mun_prest := 2;
      end if;
      -- Campo 13
         gl_conteudo := gl_conteudo || '|' || vn_dm_trib_mun_prest; -- sn_iss_retido
         --
         --
      begin
         -- Recupera: Valor do ISS - Imposto
         --           Valor da Aliquota do serviço
         --           Valor da base de cálculo
         select nvl(sum(nvl(imp.vl_imp_trib,0)),0)
              , nvl(imp.aliq_apli,0)
              , nvl(sum(nvl(imp.vl_base_calc,0)),0)
           into vn_vl_iss
              , vn_vl_aliquota
              , vn_vl_base_calc
           from item_nota_fiscal inf
              , imp_itemnf imp
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and imp.itemnf_id = inf.id
            and imp.dm_tipo = 1 -- Imposto
            and ti.id = imp.tipoimp_id
            and ti.cd = 6
            group by imp.aliq_apli; -- ISS
         --
      exception
          when others then
            vn_vl_iss       := 0;
            vn_vl_aliquota  := 0;
            vn_vl_base_calc := 0;
      end;
      -- Campo 14
      gl_conteudo := gl_conteudo || '|' ||   trim(to_char(trunc(vn_vl_iss,2), '999999999999990d00', 'nls_numeric_characters=.,'));
      -- Campo 15
      gl_conteudo := gl_conteudo || '|' ||   trim(to_char(trunc(vn_vl_iss,2), '999999999999990d00', 'nls_numeric_characters=.,'));-- Valor do ISS retido
      --
      begin
         --
         select nvl(sum(nvl(imp.vl_imp_trib,0)),0)
           into vn_vl_outras
           from item_nota_fiscal inf
              , imp_itemnf imp
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and imp.itemnf_id = inf.id
            and imp.dm_tipo = 1 -- Retenção
            and ti.id = imp.tipoimp_id
            and ti.cd <> 6; -- ISS
         --
      exception
         when others then
         --
         vn_vl_outras := 0;
         --
      end;
      --
      if (vn_vl_base_calc is null or vn_vl_base_calc = 0)
        then vn_vl_base_calc := rec.vl_item_bruto;
          end if;
      -- Campo 16
      gl_conteudo := gl_conteudo || '|' || trim(to_char(trunc(vn_vl_outras,2), '999999999999990d00', 'nls_numeric_characters=.,'));  -- Valor de outras retenções
      -- Campo 17
      gl_conteudo := gl_conteudo || '|' || trim(to_char(trunc(nvl(vn_vl_base_calc,0),2), '999999999999990d00', 'nls_numeric_characters=.,')); -- Valor da base de cálculo
      -- Campo 18
      gl_conteudo := gl_conteudo || '|' || trim(to_char(trunc(nvl(vn_vl_aliquota,0),2), '999999999999990d0000', 'nls_numeric_characters=.,')); -- Valor da alíquota do serviço
      -- Dados do prestador do serviço
      if gn_dm_ind_emit = 0 then -- emissão própria
         --
         begin
            --
            select p.id
              into vn_pessoa_id
              from pessoa p
                 , empresa e
             where e.id = gn_empresa_id
               and e.pessoa_id = p.id;
            --
         exception
            when others then
            --
            vn_pessoa_id := 0;
            --
         end;
         --
         vv_cpf_cnpj_prestador  := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => gn_empresa_id );
         vn_empresa_id := gn_empresa_id;
         --
      else
         --
         vn_pessoa_id := rec.pessoa_id;
         vv_cpf_cnpj_prestador  := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => rec.pessoa_id );
         --
         begin
            --
            select e.id
              into vn_empresa_id
              from empresa e
                 , pessoa p
             where p.id = rec.pessoa_id
               and e.pessoa_id = p.id;
            --
         exception
            when others then
            --
            vn_empresa_id := 0;
            --
         end;
         --
      end if;
      --
      if nvl(length(vv_cpf_cnpj_prestador),0) = 11 then
         --
         vn_tipo_cpf_cnpj := 1;
         --
      elsif nvl(length(vv_cpf_cnpj_prestador),0) = 14 then
         --
         vn_tipo_cpf_cnpj := 2;
         --
      else
         --
         vn_tipo_cpf_cnpj := 3;
         --
      end if;
      -- Campo 19
      gl_conteudo := gl_conteudo || '|' || vn_tipo_cpf_cnpj; -- 1– CPF, 2– CNPJ, 3 - Exterior.
      gl_conteudo := gl_conteudo || '|' || vv_cpf_cnpj_prestador;
      -- Campo 20
      begin
       select j.im, c.ibge_cidade
          into vv_im, vv_ibge_cidade_p
        from pessoa   p
           , Juridica  j
           , cidade c
       where p.id         = rec.pessoa_id
         and j.pessoa_id  = p.id
         and p.cidade_id = c.id; 
        --
        exception
           when others then
        --
            vv_im := null;
            vv_ibge_cidade_p := null;
        --
         end;   
      --
      vt_row_pessoa := fkg_recupera_dados_pessoa ( en_pessoa_id => vn_pessoa_id );
      --
      -- Campo 21
      gl_conteudo := gl_conteudo || '|' || vv_im;
      -- Campo 22
      gl_conteudo := gl_conteudo || '|' || vt_row_pessoa.nome;
      -- Campo 23
      gl_conteudo := gl_conteudo || '|' || vt_row_pessoa.lograd;
      -- Campo 24
      gl_conteudo := gl_conteudo || '|' || vt_row_pessoa.nro;
      -- Campo 25
      gl_conteudo := gl_conteudo || '|' || vt_row_pessoa.compl;
      -- Campo 26
      gl_conteudo := gl_conteudo || '|' || vt_row_pessoa.bairro;
      -- Campo 27
      gl_conteudo := gl_conteudo || '|' || pk_csf.fkg_siglaestado_pessoaid ( en_pessoa_id => vn_pessoa_id );
      -- Campo 28
      gl_conteudo := gl_conteudo || '|' || lpad(nvl(vt_row_pessoa.cep,0),8,'0');     --Código de endereçamento postal.  
      -- Campo 29
      gl_conteudo := gl_conteudo || '|' || vv_ibge_cidade_p;
      -- Campo 30
      gl_conteudo := gl_conteudo || '|' || vt_row_pessoa.fone;
      -- Campo 31
      gl_conteudo := gl_conteudo || '|' || vt_row_pessoa.email;
      --
      if (gn_dm_ind_emit = 0 and  vn_dm_trib_mun_prest = 0)    -- Tomador é a pessoa da nota e tomador paga o imposto
         or (gn_dm_ind_emit = 1 and  vn_dm_trib_mun_prest = 1) -- Prestador é a pessoa da nota e prestador paga o imposto
         then
         --
         vn_pessoa_id_trib := rec.pessoa_id;
         --
      elsif (gn_dm_ind_emit = 0 and  vn_dm_trib_mun_prest = 1) -- Prestador é a empresa da nota e prestador paga o imposto
         or (gn_dm_ind_emit = 1 and  vn_dm_trib_mun_prest = 0) -- Tomador é a empresa da nota e tomador paga o imposto
         then
         --
         begin
            --
            select p.id
              into vn_pessoa_id_trib
              from pessoa p
                 , empresa e
             where e.id = gn_empresa_id
               and e.pessoa_id = p.id;
            --
         exception
            when others then
            --
            vn_pessoa_id_trib := 0;
            --
         end;
         --
      end if;
      --
      begin
         --
select distinct ci.ibge_cidade
     , es.sigla_estado
  into vv_ibge_cidade
     , vv_sigla_estado
  from nota_fiscal       nf,
       item_nota_fiscal  inf,
       itemnf_compl_serv ics,
       cidade            ci,
       estado            es
 where nf.id = inf.notafiscal_id
   and inf.id = ics.itemnf_id
   and ics.cidade_id = ci.id
   and nf.id = rec.notafiscal_id
   and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
   and es.id = ci.estado_id;
         --
      exception
         when others then
         --
         vv_ibge_cidade := null;
         vv_sigla_estado := null;
         --
      end;
      --
      begin
        --
        select nf.dm_nat_oper
          into vn_iss_tributavel
          from NF_COMPL_SERV nf
         where nf.notafiscal_id = rec.notafiscal_id;
        --
      exception
        when no_data_found then
          --
          vn_iss_tributavel := null;
          --
        when others then
          --
          vn_iss_tributavel := null;
          --
      end;
      -- Campo 32
      gl_conteudo := gl_conteudo || '|' || vv_ibge_cidade;  -- IBGE da cidade em que o imposto será tributado
      -- Campo 33
      gl_conteudo := gl_conteudo || '|' || vv_sigla_estado; -- UF do estado em que o imposto será tributado
      -- Campo 34
      gl_conteudo := gl_conteudo || '|' || vn_iss_tributavel;
      gl_conteudo := gl_conteudo || '|';
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_3306305 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_3306305;
---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço de São José dos Campos / SP
procedure pkb_gera_arq_cid_3549904 is
   --
   vn_fase                number         := 0;
   vn_vl_iss              number         := 0;
   vn_vl_base_calc        number         := 0;
   vn_vl_aliquota         number         := 0;
   vv_cpf_cnpj_prestador  varchar2(14)   := null;
   vv_cd_lista_serv       varchar2(10)   := '0000000000';
   vn_vl_deducao          number         := 0;
   vn_im                  number         := 0;
   vn_ibge_cidade_p       number         := 0;
   vv_simpl_nac           valor_tipo_param.cd%type := null;
   --
   vn_vl_pis              number         := 0;
   vn_vl_cofins           number         := 0;
   vn_vl_inss             number         := 0;
   vn_vl_ir               number         := 0;
   vn_vl_csll             number         := 0;
   vn_valor_regtrib       number         := 0;
   --
   vc_sigla_estado        varchar(2)     ;
   vn_dm_tipo             number         := 0;
   vc_espace              varchar(2)     ;
   --
   vn_dm_tipo_pessoa      pessoa.dm_tipo_pessoa%type := null;
   vc_nome                pessoa.nome%type := null;
   vn_cep                 pessoa.cep%type := null;  
   vc_lograd              pessoa.lograd%type := null;  
   vn_nro                 pessoa.nro%type := null;  
   vc_compl               pessoa.compl%type := null;  
   vc_bairro              pessoa.bairro%type := null;
   vc_descr_cidade        cidade.descr%type := null;
   vc_descr_estado        estado.descr%type := null;
   vn_cod_siscomex        pais.cod_siscomex%type := null;
   --
   cursor c_nf is
   select nf.id         notafiscal_id
        , nf.nro_nf
        , nf.serie
        , cmf.cd
        , to_char(nf.dt_emiss,'dd/mm/yyyy') as dt_emiss
        , nf.pessoa_id
        ,       CASE
                     WHEN length(inf.cd_lista_serv) > 3 THEN
                      substr(inf.cd_lista_serv, 1, 2) || '.' || substr(inf.cd_lista_serv, 3, 2)
                     WHEN length(inf.cd_lista_serv) = 3 THEN
                      substr(inf.cd_lista_serv, 1, 1) || '.' || substr(inf.cd_lista_serv, 2, 2)
                   END cd_lista_serv
        , (select ts.descr from tipo_servico ts where ts.cod_lst =  to_char(inf.cd_lista_serv))  descr_lista_serv
        , to_char(nf.dt_sai_ent  ,'mm/yyyy') as dt_emiss2        
        , sum(inf.qtde_comerc) qtde_comerc    
        , sum(inf.qtde_comerc*inf.vl_unit_comerc) vl_item_bruto  
        , nf.dm_st_proc
        , (select pe.DM_TIPO_PESSOA from pessoa pe where pe.id = NF.PESSOA_ID  ) DM_TIPO_PESSOA ---Correcao
        , (select pa.cod_siscomex from pessoa pe, pais pa where pe.id = NF.PESSOA_ID and pa.id = pe.pais_id  ) PAIS_PESSOA ---Correcao
        , c.ibge_cidade            
        , ics.cnae
        , nfa.conteudo
        , ics.vl_outra_ret
        , ics.vl_desc_incondicionado
        , ics.vl_desc_condicionado
        , (select x.cod_siscomex from pais x , pessoa p where x.id = p.pais_id  and p.id = NF.PESSOA_ID )     cod_siscomex
        , (select y.IBGE_CIDADE from cidade y , pessoa p where y.id = p.cidade_id  and p.id = NF.PESSOA_ID )  CIDADE_IBGE 
        , ndc.cod_obra
        , c.descr as cidade
        , es.descr as estado 
        , nfc.DM_NAT_OPER  
        , mf.cod_mod 
        , ics.DM_LOC_EXE_SERV   
        ,  (select y.ibge_cidade from cidade y where y.id = ics.cidade_id)    cidade_ibge_serv 
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , cidade c
        , estado es
        , pais    pa
        , item_nota_fiscal inf
        , itemnf_compl_serv ics
        , NFINFOR_ADIC      nfa    
        , NFS_DET_CONSTR_CIVIL ndc  
        , NF_COMPL_SERV     nfc  
        , cidade_mod_fiscal cmf
    where 1=1      
      and p.cidade_id = c.id
      and ics.itemnf_id (+)  = inf.id  
      and ndc.notafiscal_id (+) = nf.id 
      and nfc.notafiscal_id (+)  = nf.id  
      and nfc.cidademodfiscal_id = cmf.id (+)
      and mf.id              = nf.modfiscal_id 
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id  
      and inf.notafiscal_id  = nf.id
      and c.estado_id        = es.id
      and es.pais_id         = pa.id
      and nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and p.cidade_id        = gn_cidade_id 
      and nfa.notafiscal_id(+)  = nf.id 
      and ((nf.dm_ind_emit = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and nf.pessoa_id  in  (select  p.id   from pessoa p   where p.id in (nf.pessoa_id )  and p.cidade_id <> gn_cidade_id) --Municícpio do Prestador diferente do Município do Tomador
      and nf.dm_st_proc      = 4
    --  and inf.cfop           in (1933,2933)
      and mf.cod_mod         = '99' -- Servicos 
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514     
      group by nf.empresa_id , nf.id         , nf.nro_nf        , nf.serie,cmf.cd            , nf.dt_emiss ,cd_lista_serv
             , nf.pessoa_id  , cd_lista_serv , inf.qtde_comerc  , nf.dm_st_proc              , p.DM_TIPO_PESSOA         , c.ibge_cidade
             , ics.cnae      , nfa.conteudo  , ics.vl_outra_ret , ics.vl_desc_incondicionado , ics.vl_desc_condicionado , pa.cod_siscomex
             , inf.CIDADE_IBGE  , ndc.cod_obra  , nf.dt_sai_ent ,nfc.DM_NAT_OPER  , c.descr , es.descr  , mf.cod_mod, ics.DM_LOC_EXE_SERV,   ics.cidade_id
     order by nf.dt_emiss , nf.nro_nf;
   --
begin
   --
   vn_fase := 1;
   --
    for rec in c_nf loop
      exit when c_nf%notfound or (c_nf%notfound) is null;
         begin
       select j.im, c.ibge_cidade
          into vn_im, vn_ibge_cidade_p
        from pessoa   p
           , empresa e
           , Juridica  j
           , cidade c
       where e.id        = gn_empresa_id
         and p.id        = e.pessoa_id
         and j.pessoa_id = p.id
         and p.cidade_id = c.id; 
        --
        exception
           when others then
        --
            vn_im := null;
            vn_ibge_cidade_p := null;
        --
         end;   
      --
   end loop;
   --
   -- MONTA O CABEÇALHO
   gl_conteudo := 'H';
   --
   gl_conteudo := gl_conteudo || '|' || vn_im|| '|'; -- Inscrição para indicar empresa
   --
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   -- MONTA O CORPO DO ARQUIVO
   for rec in c_nf loop
      exit when c_nf%notfound or (c_nf%notfound) is null;
      --      
      vv_simpl_nac := pk_csf.fkg_pessoa_valortipoparam_cd( ev_tipoparam_cd => 1 -- Simples Nacional
                                                         , en_pessoa_id    => rec.pessoa_id );
      --
      vn_fase := 2;
            -- Código de especificação da Atividade
      if rec.cd_lista_serv is not null then
      --
         vv_cd_lista_serv := rec.cd_lista_serv;
         --
      else
         --
         begin
            --
         select distinct CASE
                  WHEN TS.COD_LST LIKE ('%.%') THEN
                   TS.COD_LST
                  ELSE
                   CASE
                     WHEN length(ts.cod_lst) > 3 THEN
                      substr(ts.cod_lst, 1, 2) || '.' || substr(ts.cod_lst, 3, 2)
                     WHEN length(ts.cod_lst) = 3 THEN
                      substr(ts.cod_lst, 1, 1) || '.' || substr(ts.cod_lst, 2, 2)
                   END
                END
           into vv_cd_lista_serv
           from item_nota_fiscal inf, item i, tipo_servico ts
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.item_id = i.id
            and i.tpservico_id = ts.id;
            --
         exception
            when others then
            --
            vv_cd_lista_serv := null;
            --
         end;
      --
      end if;
      --  
      vn_fase := 3;  
      --
      begin
         -- Recupera: Valor do ISS - Imposto
         --           Valor da Aliquota do serviço
         --           Valor da base de cálculo
         select nvl(sum(nvl(imp.vl_imp_trib,0)),0)
              , nvl(imp.aliq_apli,0)
              , nvl(sum(nvl(imp.vl_base_calc,0)),0)
           into vn_vl_iss
              , vn_vl_aliquota
              , vn_vl_base_calc
           from item_nota_fiscal inf
              , imp_itemnf imp
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and imp.itemnf_id = inf.id
            and imp.dm_tipo = 1 -- Imposto
            and ti.id = imp.tipoimp_id
            and ti.cd = 6
            group by imp.aliq_apli; -- ISS
         --
      exception
          when others then
            vn_vl_iss       := 0;
            vn_vl_aliquota  := 0;
            vn_vl_base_calc := 0;
      end;
      --   
      vn_fase := 4;
         begin
         --
         select distinct nvl(sum(ii.vl_imp_trib),0)
           into vn_vl_pis
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.dm_tipo        = 1 -- Retenção
            and ti.id             = ii.tipoimp_id
            and ti.cd  in ('4');
         --
      exception
         when others then
         --
         vn_vl_pis := 0; 
         --
      end;
      --
      vn_fase := 5;
      --
      begin
         --
         select distinct nvl(sum(ii.vl_imp_trib),0)
           into vn_vl_cofins
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.dm_tipo        = 1 -- Retenção
            and ti.id             = ii.tipoimp_id
            and ti.cd  in ( '5');
         --
      exception
         when others then
         --
         vn_vl_cofins := 0; 
         --
      end;
      --
      vn_fase := 6;
      --
      begin
         --
         select distinct nvl(sum(ii.vl_imp_trib),0)
           into vn_vl_inss
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.dm_tipo        = 1 -- Retenção
            and ti.id             = ii.tipoimp_id
            and ti.cd  in ('13');
         --
      exception
         when others then
         --
         vn_vl_inss := 0; 
         --
      end;
      --
      vn_fase := 7;
      --
      begin
         --
         select distinct nvl(sum(ii.vl_imp_trib),0)
           into vn_vl_ir
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.dm_tipo        = 1 -- Retenção
            and ti.id             = ii.tipoimp_id
            and ti.cd  in ('12');
         --
      exception
         when others then
         --
         vn_vl_ir := 0; 
         --
      end;
     --
     vn_fase := 8;
     --
      begin
         --
         select distinct nvl(sum(ii.vl_imp_trib),0)
           into vn_vl_csll
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.dm_tipo        = 1 -- Retenção
            and ti.id             = ii.tipoimp_id
            and ti.cd  in ( '11');
         --
      exception
         when others then
         --
         vn_vl_csll := 0; 
         --
      end;
      --
      vn_fase := 9;
     --  
      begin
         --
         select distinct nvl(sum(ii.vl_imp_trib),0)
           into vn_vl_deducao
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.dm_tipo        = 1 -- Retenção
            and ti.id             = ii.tipoimp_id
            and ti.cd  in ('4', '5', '11', '12', '13');
         --
      exception
         when others then
         --
         vn_vl_deducao := 0; 
         --
      end;  
      -- 
      vn_fase := 10;
     --     
      begin
         --
         select distinct ii.DM_TIPO
           into vn_dm_tipo
           from item_nota_fiscal inf
              , imp_itemnf ii
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.TIPOIMP_ID = 6;
         --
      exception
         when others then
         --
         vn_dm_tipo := 0; 
         --
      end; 
      --
      vn_fase := 11;
     --
      begin
      --
      select es.sigla_estado
         into vc_sigla_estado
         from cidade ci, estado es
       where ibge_cidade in (vn_ibge_cidade_p)
         and ci.estado_id = es.id;
         --
      exception
         when others then
         --
          vc_sigla_estado := null; 
         --
      end; 
      --
      vn_fase := 12;
     -- 
       vn_valor_regtrib := pk_csf.fkg_pessoa_valortipoparam_cd(ev_tipoparam_cd => '2', -- Regime de Tributação Especial
                                                                            en_pessoa_id    => rec.pessoa_id);
      --
      vn_fase := 13;
     --
      begin
      --
      select p.DM_TIPO_PESSOA,
             p.nome,
             p.cep,
             p.lograd,
             p.nro,
             p.compl,
             p.bairro,
             c.descr,
             e.descr,
             pa.cod_siscomex           
        into vn_dm_tipo_pessoa,
             vc_nome,
             vn_cep,
             vc_lograd,
             vn_nro,
             vc_compl,
             vc_bairro,
             vc_descr_cidade,
             vc_descr_estado,
             vn_cod_siscomex             
        from pessoa p,
             cidade c,
             estado e,
             pais   pa
       where p.id = rec.pessoa_id
         and p.cidade_id = c.id
         and c.estado_id = e.id
         and e.pais_id   = pa.id;
               --
      exception
         when others then
         --
          vn_dm_tipo_pessoa := null; 
          vc_nome := null;  
          vn_cep := null;  
          vc_lograd := null;  
          vn_nro := null;  
          vc_compl := null;  
          vc_bairro := null; 
          vc_descr_cidade := null;
          vc_descr_estado := null;
          vn_cod_siscomex  := null;
         --
      end;  
      --
      vn_fase := 14;
     --
      
      --1
      gl_conteudo := 'T';
      --2
      gl_conteudo := gl_conteudo || '|' || rec.dt_emiss;
      --3
      gl_conteudo := gl_conteudo || '|' || rec.dt_emiss2;
      --4 
      gl_conteudo := gl_conteudo || '|' || lpad(nvl(rec.nro_nf,0),15,'0'); 
      --5
            --
      vn_fase := 14.1;
     --
       gl_conteudo := gl_conteudo || '|' || rpad(nvl(rec.serie,0),5,' '); 
      --6
      vn_fase := 14.11;
      --
      if  rec.cd is null then
        --
        gl_conteudo := gl_conteudo || '| A'; -- Tipo de documento => Nota Fiscal
        --        
      else
        gl_conteudo := gl_conteudo || '| ' || rec.cd; 
      end if;  
      vn_fase := 14.12; 
     --7
       if nvl(rec.dm_tipo_pessoa,1) in (0,1) then
        --
        gl_conteudo := gl_conteudo || '|1'  ;
        --        
      else
        gl_conteudo := gl_conteudo || '|2'  ;
      end if; 
      --
      vn_fase := 14.13; 
      --8
       vv_cpf_cnpj_prestador  := rpad(nvl(pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => rec.pessoa_id),0),14,' '); 
      --      
      if rec.dm_tipo_pessoa in (0,1) then
        --
         gl_conteudo := gl_conteudo || '|' || rpad(nvl(vv_cpf_cnpj_prestador,0),14,' '); 
        --        
      else
        gl_conteudo := gl_conteudo || '|' || '00000000000000' ;
      end if;  
            --
      vn_fase := 14.2;
     --
      --9
      if rec.dm_tipo_pessoa in (2) then
        --
        if nvl(vv_cpf_cnpj_prestador,0) > 0 then
          --
          gl_conteudo := gl_conteudo || '|' || rpad(nvl(vv_cpf_cnpj_prestador,0),20,' '); 
          --        
           else
             gl_conteudo := gl_conteudo || '|' || '00000000000000000000' ;
        end if;
       else
          gl_conteudo := gl_conteudo || '|' || '                    ' ;
       end if;
      --10
      gl_conteudo := gl_conteudo || '|' ||  rpad(nvl(vc_nome,' '),150,' '); 
      --11  
            --
      vn_fase := 15;
     --    
      if rec.dm_tipo_pessoa in (0,1) then
        --
        gl_conteudo := gl_conteudo || '|' || rpad(nvl(rec.ibge_cidade,0),7,' '); 
        --        
      else
       gl_conteudo := gl_conteudo || '|' || '9999999' ;
      end if;   
      --12
      if nvl(vv_simpl_nac, '0') = '1' then
      -- 
        gl_conteudo := gl_conteudo || '|S'; -- Enquadramento no Simples Nacional do Tomador de Serviços
      else
        gl_conteudo := gl_conteudo || '|N';
      end if;
      --13
      if nvl(vn_valor_regtrib,'0') = '5' then
      -- 
        gl_conteudo := gl_conteudo || '|S'; -- Enquadramento no Simples Nacional do Tomador de Serviços
      else
        gl_conteudo := gl_conteudo || '|N';
      end if;
      --14
      if nvl(rec.cidade_ibge, '0') = '3549904' then
      -- 
        gl_conteudo := gl_conteudo || '|S'; -- O prestador é São José dos Campos S - Sim,
      else
        gl_conteudo := gl_conteudo || '|N';
      end if;
      --15
      gl_conteudo := gl_conteudo || '|' || rpad(nvl(vn_cep,0),8,'0');     --Código de endereçamento postal. 
      --16
      gl_conteudo := gl_conteudo || '|' ||  rpad('Rua',25,' '); 
      --17
      gl_conteudo := gl_conteudo || '|' || rpad(nvl(vc_lograd,' '),50,' '); 
      --18
      gl_conteudo := gl_conteudo || '|' || rpad(nvl(vn_nro,' '),10,' ');      
      --19
      gl_conteudo := gl_conteudo || '|' || rpad(nvl(vc_compl,' '),60,' ');   
            --
      vn_fase := 16;
     --
      --20
      gl_conteudo := gl_conteudo || '|' || rpad(nvl(vc_bairro,' '),60,' ');
      --21
      gl_conteudo := gl_conteudo || '|' || rpad(pk_csf.fkg_siglaestado_pessoaid ( en_pessoa_id => rec.pessoa_id),2,' ');
      --22
      gl_conteudo := gl_conteudo || '|' || rpad(rec.cod_siscomex,4,' ');
      --23
      gl_conteudo := gl_conteudo || '|' || rpad(nvl(vc_descr_cidade,' '),50,' ');
      --24
      gl_conteudo := gl_conteudo || '|' || rpad(nvl(vv_cd_lista_serv,' '),5,' ');    
      --25
      gl_conteudo := gl_conteudo || '|' || rpad(nvl(rec.cnae,' '),9,' ');
      --26
      gl_conteudo := gl_conteudo || '|' || rpad(nvl(rec.cod_obra,' '),15,' ');     
      --     
      if rec.DM_LOC_EXE_SERV = 0  then
        --27
        gl_conteudo := gl_conteudo || '|' || 'LOC';
        --28
        gl_conteudo := gl_conteudo || '|' || rpad(rec.cidade_ibge_serv,7,' ');
        --29
        gl_conteudo := gl_conteudo || '|' || rpad(nvl(vc_sigla_estado,' '),2,' ');  
              --
      vn_fase := 17;
     --
        --30
        gl_conteudo := gl_conteudo || '|' || rpad(vc_espace,50,' ');  
        --31
        gl_conteudo := gl_conteudo || '|' || rpad(vc_espace,50,' '); 
        --32
        gl_conteudo := gl_conteudo || '|' || rpad(vc_espace,4,' '); 
        --33
        gl_conteudo := gl_conteudo || '|' || 'BRA - Brasil' ;
        --34
        gl_conteudo := gl_conteudo || '|' || rpad(rec.cidade_ibge_serv,7,' ');
        --35
        gl_conteudo := gl_conteudo || '|' || rpad(nvl(vc_sigla_estado,' '),2,' ');
        --36
        gl_conteudo := gl_conteudo || '|' || rpad(vc_espace,50,' ');  
        --37
        gl_conteudo := gl_conteudo || '|' || rpad(vc_espace,50,' ');  
        --38
        gl_conteudo := gl_conteudo || '|' || rpad(vc_espace,4,' ');  
        --      
      else
        --27
        gl_conteudo := gl_conteudo || '|' || 'EXT' ;
        --28
        gl_conteudo := gl_conteudo || '|' || '9999999';
        --29
        gl_conteudo := gl_conteudo || '|' || rpad(vc_espace,2,' '); 
        --30
        gl_conteudo := gl_conteudo || '|' || rpad(nvl(vc_descr_cidade,' '),50,' ');  
        --31
        gl_conteudo := gl_conteudo || '|' || rpad(nvl(vc_descr_estado,' '),50,' ');  
        --32
        gl_conteudo := gl_conteudo || '|' || rpad(vn_cod_siscomex,40,' ');  
        --33
        gl_conteudo := gl_conteudo || '|' || 'EXT - Exterior' ;
        --34
        gl_conteudo := gl_conteudo || '|' || '9999999';
        --35
        gl_conteudo := gl_conteudo || '|' || rpad(vc_espace,2,' ');  
        --36
        gl_conteudo := gl_conteudo || '|' || rpad(nvl(vc_descr_cidade,' '),50,' ');  
        --37
        gl_conteudo := gl_conteudo || '|' || rpad(nvl(vc_descr_estado,' '),50,' ');  
        --38
        gl_conteudo := gl_conteudo || '|' || rpad(vn_cod_siscomex,4,' ');  
      --  
      end if;    
      -- 
      --39
      gl_conteudo := gl_conteudo || '|' || rpad(vc_espace,1,' ');  
            --
      vn_fase := 18;
     --
      --40
      gl_conteudo := gl_conteudo || '|' || rpad(rec.DM_NAT_OPER,1,' ');  
      --41
      if nvl(vn_dm_tipo, '0') = 0 then
        gl_conteudo := gl_conteudo || '|RPP'; 
      else
        gl_conteudo := gl_conteudo || '|RNF';
      end if;
      --42
      gl_conteudo := gl_conteudo || '|' || rpad(vn_vl_aliquota,5,' ');  
      --43
      if nvl(rec.vl_item_bruto,0) > 0  then
        --
        gl_conteudo := gl_conteudo || '|' || trim(to_char(trunc(rec.vl_item_bruto, 2), '999999999990d00', 'nls_numeric_characters=.,')); -- Valor total do serviço
        --        
      else
        gl_conteudo := gl_conteudo || '|' || '000000000000000' ;
      end if;      
      
      --44
      if nvl(vn_vl_deducao,0) > 0  then
        --
        gl_conteudo := gl_conteudo || '|' || rpad(vn_vl_deducao,15,' '); 
        --        
      else
        gl_conteudo := gl_conteudo || '|' || '000000000000000' ;
      end if;   
      --45
      if nvl(rec.vl_desc_incondicionado,0) > 0  then
        --
        gl_conteudo := gl_conteudo || '|' || rpad(rec.vl_desc_incondicionado,15,' ');  
        --        
      else
        gl_conteudo := gl_conteudo || '|' || '000000000000000' ;
      end if;   
      --46
      if nvl(rec.vl_desc_condicionado,0) > 0  then
        --
        gl_conteudo := gl_conteudo || '|' || rpad(rec.vl_desc_condicionado,15,' ');  
        --        
      else
        gl_conteudo := gl_conteudo || '|' || '000000000000000' ;
      end if; 
      --47
      gl_conteudo := gl_conteudo || '|' || rpad(trim(to_char(trunc(vn_vl_base_calc,2), '999999999990d00', 'nls_numeric_characters=.,')),15,' ');-- Valor Base calculo
      --48
      if nvl(vn_vl_pis,0) > 0  then
        --
        gl_conteudo := gl_conteudo || '|' || rpad(trim(to_char(trunc(vn_vl_pis,2), '999999999990d00', 'nls_numeric_characters=.,')),15,' ');-- Valor PIS
        --        
      else
        gl_conteudo := gl_conteudo || '|' || '000000000000000' ;
      end if; 
      --49
      if nvl(vn_vl_cofins,0) > 0  then
        --
        gl_conteudo := gl_conteudo || '|' ||  rpad(trim(to_char(trunc(vn_vl_cofins ,2), '999999999990d00', 'nls_numeric_characters=.,')),15,' ');-- Valor COFINS
        --        
      else
        gl_conteudo := gl_conteudo || '|' || '000000000000000' ;
      end if; 
            --
      vn_fase := 19;
     --
      --50
        if nvl(vn_vl_inss,0) > 0  then
        --
        gl_conteudo := gl_conteudo || '|' ||  rpad(trim(to_char(trunc(vn_vl_inss,2), '999999999990d00', 'nls_numeric_characters=.,')),15,' ');-- Valor INSS
        --        
      else
        gl_conteudo := gl_conteudo || '|' || '000000000000000' ;
      end if; 
      --51
      if nvl(vn_vl_ir,0) > 0  then
        --
        gl_conteudo := gl_conteudo || '|' ||  rpad(trim(to_char(trunc(vn_vl_ir,2), '999999999990d00', 'nls_numeric_characters=.,')),15,' ');-- Valor IR
        --        
      else
        gl_conteudo := gl_conteudo || '|' || '000000000000000' ;
      end if; 
      --52
      if nvl(vn_vl_csll,0) > 0  then
        --
      gl_conteudo := gl_conteudo || '|' ||  rpad(trim(to_char(trunc(vn_vl_csll,2), '999999999990d00', 'nls_numeric_characters=.,')),15,' ');-- Valor CSLL
        --        
      else
        gl_conteudo := gl_conteudo || '|' || '000000000000000' ;
      end if; 
      --53
      if nvl(rec.vl_outra_ret,0) > 0  then
        --
      gl_conteudo := gl_conteudo || '|' ||  rpad(trim(to_char(trunc(rec.vl_outra_ret,2), '999999999990d00', 'nls_numeric_characters=.,')),15,' ');-- Valor outras
        --        
      else
        gl_conteudo := gl_conteudo || '|' || '000000000000000' ;
      end if; 
      --54
      gl_conteudo := gl_conteudo || '|' ||  rpad(trim(to_char(trunc(vn_vl_iss,2), '999999999990d00', 'nls_numeric_characters=.,')),15,' ');-- Valor do ISS retido
      --55
      gl_conteudo := gl_conteudo || '|' || rpad(nvl(rec.descr_lista_serv,' '),2000,' ');  
   --  
   pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
   --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_3549904 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_3549904;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço de Mirassol / SP
procedure pkb_gera_arq_cid_3530300 is
   --
   vn_fase                number         := 0;
   vn_count_n             number         := 0;
   vn_count_e             number         := 0;
   vn_count_r             number         := 0;
   vn_vl_iss              number         := 0;
   vn_vl_base_calc        number         := 0;
   vn_vl_aliquota         number         := 0;
   vv_cpf_cnpj_prestador  varchar2(14)   := null;
   vv_cd_lista_serv       varchar2(10)   := '0000000000';
   vn_vl_deducao          number         := 0;
   vn_im                  number         := 0;
   vn_ibge_cidade_p       number         := 0;
   vv_simpl_nac           valor_tipo_param.cd%type := null;
   -- 
   vn_imp_devido          number         := 0;
   --
   vc_sigla_estado        varchar(2)     ;
   vn_dm_tipo             number         := 0;
   vc_espace              varchar(2)     ;
   --
   vn_dm_tipo_pessoa      pessoa.dm_tipo_pessoa%type := null;
   vc_nome                pessoa.nome%type := null;
   vn_cep                 pessoa.cep%type := null;  
   vc_lograd              pessoa.lograd%type := null;  
   vn_nro                 pessoa.nro%type := null;  
   vc_compl               pessoa.compl%type := null;  
   vc_bairro              pessoa.bairro%type := null;
   vc_descr_cidade        cidade.descr%type := null;
   vc_descr_estado        estado.descr%type := null;
   vn_cod_siscomex        pais.cod_siscomex%type := null;
   --
   vn_tot_item_bruto      number         := 0;
   vn_tot_vl_aliquota     number         := 0;
   vn_tot_imp_devido      number         := 0;
   vn_cont_pessoa_id      number         := 0;
   --
   i                      pls_integer    := 0;
   --
   cursor c_nf is
   select nf.id         notafiscal_id
        , nf.nro_nf
        , nf.serie
        , to_char(nf.dt_emiss,'dd/mm/yyyy') as dt_emiss
        , nf.pessoa_id
        ,       CASE
                     WHEN length(inf.cd_lista_serv) > 3 THEN
                      substr(inf.cd_lista_serv, 1, 2) || '.' || substr(inf.cd_lista_serv, 3, 2)
                     WHEN length(inf.cd_lista_serv) = 3 THEN
                      substr(inf.cd_lista_serv, 1, 1) || '.' || substr(inf.cd_lista_serv, 2, 2)
                   END cd_lista_serv
        , to_char(nf.dt_sai_ent  ,'mm/yyyy') as dt_emiss2  
        ,  to_char(nf.dt_emiss  ,'yyyy') as ano_referencia
        ,  to_char(nf.dt_emiss  ,'mm') as mes_referencia    
        , sum(inf.qtde_comerc) qtde_comerc    
        , sum(inf.vl_item_bruto - inf.vl_desc) vl_item_bruto  
        , nf.dm_st_proc
        , (select pe.DM_TIPO_PESSOA from pessoa pe where pe.id = NF.PESSOA_ID  ) DM_TIPO_PESSOA ---Correcao
        , (select pe.pais_id from pessoa pe where pe.id = NF.PESSOA_ID  ) PAIS_PESSOA ---Correcao
        , c.ibge_cidade        
        , ics.cnae
        , nfa.conteudo
        , ics.vl_outra_ret
        , ics.vl_desc_incondicionado
        , ics.vl_desc_condicionado
        , (select x.cod_siscomex from pais x , pessoa p where x.id = p.pais_id  and p.id = NF.PESSOA_ID )     cod_siscomex
        , inf.CIDADE_IBGE 
        , ndc.cod_obra
        , c.descr as cidade
        , es.descr as estado 
        , nfc.DM_NAT_OPER  
        , mf.cod_mod 
        , ics.DM_LOC_EXE_SERV   
        , nf.dm_ind_emit 
        , cm.cd
         ,case nvl(nfc.dm_nat_oper, 2)
                          when 1 then
                           'P' -- Tributação no município (Não Retida)
                          when 2 then
                           'F' -- Tributação fora do município (Pgto. pelo prestador)
                          when 3 then
                           'I' -- Isenta
                          when 4 then
                           'I' -- Imune
                          when 5 then
                           'C' -- Exigibilidade suspensa por decisão judicial 
                          when 6 then
                           'C' -- Exigibilidade suspensa por decisão judicial 
                          when 7 then
                           'F' -- Recolhimento forab
                        end natureza_operacao
     from nota_fiscal nf
        , mod_fiscal mf
        , empresa e
        , pessoa p
        , cidade c
        , estado es
        , pais    pa
        , item_nota_fiscal inf
        , itemnf_compl_serv ics
        , NFINFOR_ADIC      nfa    
        , NFS_DET_CONSTR_CIVIL ndc  
        , NF_COMPL_SERV     nfc  
        , cidade_mod_fiscal cm
    where 1=1      
      and cm.id(+)          = nfc.cidademodfiscal_id
      and p.cidade_id = c.id
      and ics.itemnf_id (+)  = inf.id  
      and ndc.notafiscal_id (+) = nf.id 
      and nfc.notafiscal_id (+)  = nf.id  
      and mf.id              = nf.modfiscal_id 
      and e.id               = nf.empresa_id
      and p.id               = e.pessoa_id  
      and inf.notafiscal_id  = nf.id
      and c.estado_id        = es.id
      and es.pais_id         = pa.id
      and nf.empresa_id      = gn_empresa_id
      and nf.dm_ind_emit     = gn_dm_ind_emit
      and p.cidade_id        = gn_cidade_id 
      and nfa.notafiscal_id(+)  = nf.id 
      and ((nf.dm_ind_emit = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin)
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
      and nf.pessoa_id  in  (select  p.id   from pessoa p   where p.id in (nf.pessoa_id )  and p.cidade_id <> gn_cidade_id) --Municícpio do Prestador diferente do Município do Tomador
      and nf.dm_st_proc      = 4
    --  and inf.cfop           in (1933,2933)
      and mf.cod_mod         = '99' -- Servicos
      and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514      
      group by nf.empresa_id , nf.id         , nf.nro_nf        , nf.serie                   , nf.dt_emiss 
             , nf.pessoa_id  , cd_lista_serv , inf.qtde_comerc  , nf.dm_st_proc              , p.DM_TIPO_PESSOA         , c.ibge_cidade
             , ics.cnae      , nfa.conteudo  , ics.vl_outra_ret , ics.vl_desc_incondicionado , ics.vl_desc_condicionado , pa.cod_siscomex
             , inf.CIDADE_IBGE  , ndc.cod_obra  , nf.dt_sai_ent ,nfc.DM_NAT_OPER  , c.descr , es.descr  , mf.cod_mod, ics.DM_LOC_EXE_SERV            
             , nf.dm_ind_emit  , cm.cd
     order by nf.dt_emiss , nf.nro_nf;
   --
begin
   --
   vn_fase := 1;
   --
    begin
         -- Recupera: contador
         select CO.PESSOA_ID
           into vn_cont_pessoa_id
           from contador_empresa ce, contador co 
        where  empresa_id = gn_empresa_id
         and ce.dm_situacao = 1 
         and ce.contador_id = co.id
         and rownum <= 1;  
         --
      exception
          when others then
            vn_cont_pessoa_id       := 0; 
      end;
   --    
   --
    for rec in c_nf loop
      exit when c_nf%notfound or (c_nf%notfound) is null;
         begin
       select j.im, c.ibge_cidade
          into vn_im, vn_ibge_cidade_p
        from pessoa   p
           , empresa e
           , Juridica  j
           , cidade c
       where e.id        = gn_empresa_id
         and p.id        = e.pessoa_id
         and j.pessoa_id = p.id
         and p.cidade_id = c.id; 
        --
        exception
           when others then
        --
            vn_im := null;
            vn_ibge_cidade_p := null;
        --
         end;   
      --
   end loop;
   --

   --
   -- MONTA O CORPO DO ARQUIVO
   for rec in c_nf loop
      exit when c_nf%notfound or (c_nf%notfound) is null;
      --      
      vv_simpl_nac := pk_csf.fkg_pessoa_valortipoparam_cd( ev_tipoparam_cd => 1 -- Simples Nacional
                                                         , en_pessoa_id    => rec.pessoa_id );
      --
            -- Código de especificação da Atividade
      if rec.cd_lista_serv is not null then
      --
         vv_cd_lista_serv := rec.cd_lista_serv;
         --
      else
         --
         begin
            --
         select distinct CASE
                  WHEN TS.COD_LST LIKE ('%.%') THEN
                   TS.COD_LST
                  ELSE
                   CASE
                     WHEN length(ts.cod_lst) > 3 THEN
                      substr(ts.cod_lst, 1, 2) || '.' || substr(ts.cod_lst, 3, 2)
                     WHEN length(ts.cod_lst) = 3 THEN
                      substr(ts.cod_lst, 1, 1) || '.' || substr(ts.cod_lst, 2, 2)
                   END
                END
           into vv_cd_lista_serv
           from item_nota_fiscal inf, item i, tipo_servico ts
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.item_id = i.id
            and i.tpservico_id = ts.id;
            --
         exception
            when others then
            --
            vv_cd_lista_serv := null;
            --
         end;
      --
      end if;
      --  
      begin
         -- Recupera: Valor do ISS - Imposto
         --           Valor da Aliquota do serviço
         --           Valor da base de cálculo
         select nvl(sum(nvl(imp.vl_imp_trib,0)),0)
              , nvl(imp.aliq_apli,0)
              , nvl(sum(nvl(imp.vl_base_calc,0)),0)
           into vn_vl_iss
              , vn_vl_aliquota
              , vn_vl_base_calc
           from item_nota_fiscal inf
              , imp_itemnf imp
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and imp.itemnf_id = inf.id
            and imp.dm_tipo = 0 -- Imposto
            and ti.id = imp.tipoimp_id
            and ti.cd = 6
            group by imp.aliq_apli; -- ISS
         --
      exception
          when others then
            vn_vl_iss       := 0;
            vn_vl_aliquota  := 0;
            vn_vl_base_calc := 0;
      end;
      --   
      vn_imp_devido := vn_vl_base_calc * (vn_vl_aliquota/100);
      --
      --  
      begin
         --
         select distinct nvl(sum(ii.vl_imp_trib),0)
           into vn_vl_deducao
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.dm_tipo        = 1 -- Retenção
            and ti.id             = ii.tipoimp_id
            and ti.cd  in ('4', '5', '11', '12', '13');
         --
      exception
         when others then
         --
         vn_vl_deducao := 0; 
         --
      end;  
      --      
      begin
         --
         select distinct ii.DM_TIPO
           into vn_dm_tipo
           from item_nota_fiscal inf
              , imp_itemnf ii
          where inf.notafiscal_id = rec.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.TIPOIMP_ID = 6;
         --
      exception
         when others then
         --
         vn_dm_tipo := 0; 
         --
      end; 
      --
      begin
      --
      select es.sigla_estado
         into vc_sigla_estado
         from cidade ci, estado es
       where ibge_cidade in (vn_ibge_cidade_p)
         and ci.estado_id = es.id;
         --
      exception
         when others then
         --
          vc_sigla_estado := null; 
         --
      end;  
      --
      begin
      --
      select p.DM_TIPO_PESSOA,
             p.nome,
             p.cep,
             p.lograd,
             p.nro,
             p.compl,
             p.bairro,
             c.descr,
             e.descr,
             pa.cod_siscomex           
        into vn_dm_tipo_pessoa,
             vc_nome,
             vn_cep,
             vc_lograd,
             vn_nro,
             vc_compl,
             vc_bairro,
             vc_descr_cidade,
             vc_descr_estado,
             vn_cod_siscomex             
        from pessoa p,
             cidade c,
             estado e,
             pais   pa
       where p.id = rec.pessoa_id
         and p.cidade_id = c.id
         and c.estado_id = e.id
         and e.pais_id   = pa.id;
               --
      exception
         when others then
         --
          vn_dm_tipo_pessoa := null; 
          vc_nome := null;  
          vn_cep := null;  
          vc_lograd := null;  
          vn_nro := null;  
          vc_compl := null;  
          vc_bairro := null; 
          vc_descr_cidade := null;
          vc_descr_estado := null;
          vn_cod_siscomex  := null;
         --
      end; 
     --
     --H 
     --
     if i = 0 then
     --
     i := i + 1;
     --
     gl_conteudo := null;
     --
     gl_conteudo := gl_conteudo || '''' || 3 || '''' || ',';
     --
     gl_conteudo := gl_conteudo || '''' || 'H' || '''' || ',';
     --
     gl_conteudo := gl_conteudo || '''' || pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => gn_empresa_id) || '''' || ','; 
     --
     gl_conteudo := gl_conteudo || rec.ano_referencia || ',' ;
     --
     gl_conteudo := gl_conteudo || rec.mes_referencia || ',' ;
     --
     gl_conteudo := gl_conteudo || '0' || ',' ;
     --7
     gl_conteudo := gl_conteudo || '0' || ','; 
     --
     gl_conteudo := gl_conteudo || '''' || nvl(pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => vn_cont_pessoa_id),0) || '''' || ','; 
     --
     gl_conteudo := gl_conteudo || vn_im ; -- Inscrição para indicar empresa
     --
     pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
     --
     end if;  
     --
     gl_conteudo := null;
     --
     --N
     -- 
     gl_conteudo := gl_conteudo || '''' || 3 || '''' || ',';
     --
     gl_conteudo := gl_conteudo || '''' || 'N' || '''' || ','; 
     --
      if  rec.cd  = 'R' then
        --
         gl_conteudo := gl_conteudo || '''RPA''' || ',';  --=>  Recibo
        --        
      else
         gl_conteudo := gl_conteudo || rec.serie || ',';   
      end if; 
      --  
      if rec.dm_ind_emit  = '1' then
        --
         gl_conteudo := gl_conteudo || '''R''' || ',';  --=>  Nota de Terceiro
        --        
      else
         gl_conteudo := gl_conteudo || '''E''' || ',';  --=>  Emissão Própria
      end if; 
      --  
      if  rec.cd  = 'R' then
        --
         gl_conteudo := gl_conteudo || '''R''' || ',';  --=>  Recibo
        --        
      else
         gl_conteudo := gl_conteudo || '''N''' || ',';  --=>  Nota Fiscal   
      end if;    
      --
      gl_conteudo := gl_conteudo ||  rec.nro_nf  || ','; 
      --
      gl_conteudo := gl_conteudo || rec.dt_emiss || ',' ;
      --8
      vv_cpf_cnpj_prestador  := nvl(pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => rec.pessoa_id),0); 
      --
      gl_conteudo := gl_conteudo || '''' || vv_cpf_cnpj_prestador || '''' || ','; 
      --
      gl_conteudo := gl_conteudo || to_char(trunc(nvl(rec.vl_item_bruto,0), 2), '999999999999990D00', 'nls_numeric_characters=.,') || ',';
      --10       
      gl_conteudo := gl_conteudo || rec.natureza_operacao || ',';
      
      
      
      --
      gl_conteudo := gl_conteudo || '''' ||   vc_nome  || '''' || ','; 
      --
      gl_conteudo := gl_conteudo || '''' ||  vc_descr_cidade  || '''' || ','; 
      --
      gl_conteudo := gl_conteudo || '''' || pk_csf.fkg_siglaestado_pessoaid ( en_pessoa_id => rec.pessoa_id)|| '''';      
      --
      pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
      --
      --I
      --
      gl_conteudo := null;
      --
      gl_conteudo := gl_conteudo || '''' || 3 || '''' || ',';
      --
      gl_conteudo := gl_conteudo || '''' || 'I' || '''' || ',';    
      --
      gl_conteudo := gl_conteudo || nvl(vv_cd_lista_serv,0)  || ','; 
      --
      gl_conteudo := gl_conteudo || to_char(trunc(nvl(vn_vl_base_calc,0), 2), '999999999999990D00', 'nls_numeric_characters=.,')   || ','; 
      --
      if nvl(vv_simpl_nac, '0') = '1' then
      -- 
      gl_conteudo := gl_conteudo || to_char(trunc(nvl(vn_vl_iss,0), 2), '999999999999990D00', 'nls_numeric_characters=.,')  || ','; 
      --
      else
      gl_conteudo := gl_conteudo || 0.0000 || ','; 
      --
      end if;
      --
      gl_conteudo := gl_conteudo || to_char(trunc(nvl(vn_vl_aliquota,0), 2), '999999999999990D00', 'nls_numeric_characters=.,')   || ','; 
      --
      --
      gl_conteudo := gl_conteudo || to_char(trunc(nvl(vn_imp_devido,0), 2), '999999999999990D00', 'nls_numeric_characters=.,') ;
      --   
      --
      pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
      --
      --D não obrigatório
    /*  
      gl_conteudo := gl_conteudo || 3 || ','; 
      --
      gl_conteudo := gl_conteudo || '''' || 'D' || '''' || ',';    
      --
      gl_conteudo := gl_conteudo || '''' || 'E' || '''' || ',';    
      --
      gl_conteudo := gl_conteudo || '''' || rpad(nvl(rec.serie,0),10,' ')|| '''' || ','; 
      --
      gl_conteudo := gl_conteudo || lpad(nvl(rec.nro_nf,0),14,' ') || ','; 
      --
      gl_conteudo := gl_conteudo || lpad(nvl(rec.nro_nf,0),14,' ') || ','; 
      --
      gl_conteudo := gl_conteudo || '''' || rpad(nvl(rec.serie,0),10,' ')|| '''' || ','; 
      --
      gl_conteudo := gl_conteudo || rec.dt_emiss || ',' ;
      --
      gl_conteudo := gl_conteudo ||   ;      
    
      --
      --F não é obrigatório
      --
      gl_conteudo := null;
      --
      gl_conteudo := gl_conteudo || '''' || 3 || '''' || ',';
      --
      gl_conteudo := gl_conteudo || '''' || 'F' || '''' || ',';    
      --
      gl_conteudo := gl_conteudo || '''' || 'C' || '''' || ',';    
      --
      gl_conteudo := gl_conteudo ||  '''' || 'O' || '''' || ',';       
      --
      gl_conteudo := gl_conteudo || '0.00'; 
      --
      pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
      --
        */--
      --
      vn_count_n := vn_count_n + 1; 
      --
      if rec.dm_ind_emit  = '0' then
      --
        vn_count_e := vn_count_e + 1; 
        vn_tot_imp_devido := vn_tot_imp_devido + vn_imp_devido; 
      --
      end if;
      --
      if  rec.dm_ind_emit  = '1' then
      --
        vn_count_r := vn_count_r + 1; 
      --
      end if;
      --
      vn_tot_item_bruto := vn_tot_item_bruto + rec.vl_item_bruto; 
      --
      vn_tot_vl_aliquota := vn_tot_vl_aliquota + vn_vl_aliquota;
      --
          
      --
      --
 end loop;
      --
      --T
      --
      gl_conteudo := null;
      --1
      gl_conteudo := gl_conteudo || '''' || 3 || '''' || ',';
      --2
      gl_conteudo := gl_conteudo || '''' || 'T' || '''' || ',';    
      --3
      gl_conteudo := gl_conteudo || vn_count_n || ',';    
      --4
      gl_conteudo := gl_conteudo || vn_count_e || ',';
      --5
      gl_conteudo := gl_conteudo || 0 || ',';  
      --6
      gl_conteudo := gl_conteudo || vn_tot_imp_devido || ',';  
      --7
      gl_conteudo := gl_conteudo || 0  || ',';  
      --8 terc
      gl_conteudo := gl_conteudo || vn_count_r || ',';  
      --9
      gl_conteudo := gl_conteudo || to_char(trunc(nvl(vn_tot_item_bruto,0), 2), '999999999999990D00', 'nls_numeric_characters=.,')   || ',';  
      --10
      gl_conteudo := gl_conteudo || to_char(trunc(nvl(vn_tot_vl_aliquota,0), 2), '999999999999990D00', 'nls_numeric_characters=.,')   ;    
      ---- to_char(trunc(nvl(vn_tot_item_bruto,0), 2), '999999999999990D00', 'nls_numeric_characters=.,')  
      pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
      -- 
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_3530300 fase ('||vn_fase||'): '||sqlerrm);
end pkb_gera_arq_cid_3530300;
  

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço de Castilho / SP
procedure pkb_gera_arq_cid_3511003 is
  --
  vn_fase        number := 0;
  vn_qtde_linhas number := 0;
  --
  vv_cpf_cnpj        varchar2(14);
  vv_nome            pessoa.nome%type;
  vn_cep             pessoa.cep%type;
  vv_endereco        pessoa.lograd%type;
  vn_numero          pessoa.nro%type;
  vv_bairro          pessoa.bairro%type;
  vv_cidade          cidade.descr%type;
  vv_estado          estado.sigla_estado%type;
  vn_fone            pessoa.fone%type;
  vv_email           pessoa.email%type;
  vv_compl           pessoa.compl%type;
  vv_fantasia        pessoa.fantasia%type;
  vn_pais            pais.cod_siscomex%type;
  vv_ie              juridica.ie%type;
  vn_regesptrib      number := 0;
  vn_optantesim      number := 0;
  vn_empresa_id      empresa.id%type;
  vn_pessoa_id_prest pessoa.id%type;
  vv_rg              fisica.rg%type;
  --
    --
  vv_cpf_cnpj2        varchar2(14);
  vv_nome2            pessoa.nome%type;
  vn_cep2             pessoa.cep%type;
  vv_endereco2        pessoa.lograd%type;
  vn_numero2          pessoa.nro%type;
  vv_bairro2          pessoa.bairro%type;
  vv_cidade2          cidade.descr%type;
  vv_estado2          estado.sigla_estado%type;
  vn_fone2            pessoa.fone%type;
  vv_email2           pessoa.email%type;
  vv_compl2           pessoa.compl%type;
  vv_fantasia2        pessoa.fantasia%type;
  vn_pais2            pais.cod_siscomex%type;
  vv_ie2              juridica.ie%type;
  vn_regesptrib2      number := 0;
  vn_optantesim2      number := 0;
  vn_empresa_id2      empresa.id%type;
  vn_pessoa_id_prest2 pessoa.id%type;
  vv_rg2               fisica.rg%type;
  --
  vn_count number := 0;
  --
  vn_aliq_apli          imp_itemnf.aliq_apli%type := 0;
  vn_aliq_apli4         imp_itemnf.aliq_apli%type := 0;
  vn_aliq_apli5         imp_itemnf.aliq_apli%type := 0;
  vn_aliq_apli6         imp_itemnf.aliq_apli%type := 0;
  vn_aliq_apli11        imp_itemnf.aliq_apli%type := 0;
  vn_aliq_apli12        imp_itemnf.aliq_apli%type := 0;
  vn_aliq_apli13        imp_itemnf.aliq_apli%type := 0;
  vn_ret_iss            nota_fiscal_total.vl_ret_iss%type;
  vn_cod_trib_municipio cod_trib_municipio.cod_trib_municipio%type;
  vn_vl_desc_cond       nota_fiscal_total.vl_desc_cond%type;
  vn_vl_desc_incond     nota_fiscal_total.vl_desc_incond%type;
  --
  -- Dados da pessoa_id
  cursor c_pessoa(en_pessoa_id pessoa.id%type) is
    select pe.nome,
           pe.lograd,
           pe.nro,
           pe.compl,
           pe.bairro,
           ci.descr,
           es.sigla_estado,
           pe.cep,
           pe.email,
           pe.fone,
           pa.descr pais_descr,
           ju.ie,
           pe.dm_tipo_pessoa,
           ci.ibge_cidade,
           pa.cod_siscomex,
           pe.fantasia
      from pessoa pe, 
           cidade ci, 
           estado es, 
           pais pa, 
           juridica ju
     where pe.id = en_pessoa_id
       and ci.id = pe.cidade_id
       and es.id = ci.estado_id
       and pa.id = pe.pais_id
       and pe.id = ju.pessoa_id(+);
  --
  -- Dados do tipo de prestador
  cursor c_tpprest(en_pessoa_id pessoa.id%type) is
    select vt.cd cd_vlrtpparam
      from pessoa_tipo_param pt, 
           tipo_param tp, 
           valor_tipo_param vt
     where pt.pessoa_id         = en_pessoa_id
       and pt.tipoparam_id      = tp.id
       and vt.tipoparam_id      = tp.id
       and pt.valortipoparam_id = vt.id;
  --
  -- Dados das NF
  cursor c_nfs is
    select distinct nf.id notafiscal_id,
                    nf.nro_nf,
                    nf.serie,
                    nf.dt_emiss,
                    nf.pessoa_id,
                    to_char(nf.dt_emiss, 'YYYY-MM-DD"T"HH:MM:SS') dt_emiss2,
                    --nf.pessoa_id pessoa_id_prest,
                    p.id pessoa_id_prest,
                    nf.empresa_id empresa_id_toma,
                    case
                      when length(inf.cd_lista_serv) > 3 then
                       substr(inf.cd_lista_serv, 1, 2) || '.' || substr(inf.cd_lista_serv, 3, 2)
                      when length(inf.cd_lista_serv) = 3 then
                       substr(inf.cd_lista_serv, 1, 1) || '.' || substr(inf.cd_lista_serv, 2, 2)
                    end cd_lista_serv,
                    sum(inf.qtde_comerc) qtde_comerc,
                    sum(inf.qtde_comerc * inf.vl_unit_comerc) vl_item_bruto,
                    p.cidade_id,
                    inf.id itemnf_id
      from nota_fiscal      nf,
           mod_fiscal       mf,
           empresa          e,
           pessoa           p,
           item_nota_fiscal inf
     where nf.empresa_id  = gn_empresa_id
       and nf.dm_ind_emit = gn_dm_ind_emit
       and nf.dm_st_proc  = 4
       and ((nf.dm_ind_emit = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
       and mf.id          = nf.modfiscal_id
       --and inf.cfop       in (1933, 2933)
       -- and mf.cod_mod  = '99' -- Serviços
       and e.id           = nf.empresa_id
       and p.id           = e.pessoa_id
       --  and nf.pessoa_id  in  (select  p.id   from pessoa p   where p.id in (nf.pessoa_id )  and p.cidade_id <> gn_cidade_id) --Municícpio do Prestador diferente do Município do Tomador
       and p.cidade_id    = gn_cidade_id
       and nf.id          = inf.notafiscal_id
     group by nf.empresa_id,
              nf.id,
              nf.nro_nf,
              nf.serie,
              nf.dt_emiss, 
              nf.pessoa_id,
              p.id,
              nf.empresa_id,
              cd_lista_serv,
              inf.qtde_comerc,
              p.cidade_id,
              inf.id
     order by dt_emiss, nro_nf;
  --
  cursor c_itens(en_notafiscal_id nota_fiscal.id%type) is
    select inf.qtde_comerc,
           inf.vl_unit_comerc,
           inf.unid_com,
           inf.descr_item,
           inf.vl_item_bruto
      from item_nota_fiscal inf
     where inf.notafiscal_id = en_notafiscal_id;
  --
  cursor c_imp_itemnf(en_itemnf_id item_nota_fiscal.id%type) is
    select imp.aliq_apli, imp.tipoimp_id  
      from imp_itemnf imp
     where imp.itemnf_id = en_itemnf_id
       and imp.dm_tipo   = 1 -- Retido
     group by imp.aliq_apli, 
              imp.tipoimp_id;
  --
begin
  --
  vn_fase := 1;
  --
  begin
    select distinct p.id pessoa_id_prest
      into vn_pessoa_id_prest
      from nota_fiscal      nf,
           mod_fiscal       mf,
           empresa          e,
           pessoa           p,
           item_nota_fiscal inf
     where nf.empresa_id  = gn_empresa_id
       and nf.dm_ind_emit = gn_dm_ind_emit
       and nf.dm_st_proc  = 4
       and ((nf.dm_ind_emit = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
       and mf.id         = nf.modfiscal_id
       and inf.cfop      in (1933, 2933)
       and e.id          = nf.empresa_id
       and p.id          = e.pessoa_id
       and p.cidade_id   = gn_cidade_id
       and nf.id         = inf.notafiscal_id
       and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
       and rownum        = 1;
  exception
    when others then
      vn_pessoa_id_prest := null;
  end;

  --
  gl_conteudo := null;
  --
  -- Cabeçalho
  -- ====================
  gl_conteudo := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>';
  gl_conteudo := gl_conteudo || '<Declaracao>';
  gl_conteudo := gl_conteudo || '<Tomador>';
  gl_conteudo := gl_conteudo || '<CodEmpresa>1</CodEmpresa>';
  gl_conteudo := gl_conteudo || '<CpfCnpj>';
  gl_conteudo := gl_conteudo || '<Cnpj>' || lpad(nvl(pk_csf.fkg_cnpj_ou_cpf_empresa(en_empresa_id => gn_empresa_id), '0'), 14, '0') || '</Cnpj>';
  gl_conteudo := gl_conteudo || '</CpfCnpj>';
  gl_conteudo := gl_conteudo || '<InscricaoMunicipal>' ||  replace(replace(rtrim(pk_csf.fkg_inscr_mun_pessoa(en_pessoa_id => vn_pessoa_id_prest)), '-', ''), '.', '')  || '</InscricaoMunicipal>'; -- InscricaoMunicipal
  gl_conteudo := gl_conteudo || '</Tomador>';
  --
  gl_conteudo := gl_conteudo || '<Referencia>' || rtrim(substr(to_char(gd_dt_ini, 'MM/YYYY'), 1, 10)) || '</Referencia>'; 
  --
  vn_qtde_linhas := 0;
  --
  vn_fase := 2;
  --
  -- Armazena a estrutura do arquivo
  --pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
  --
  vn_fase := 3;
  --
  gl_conteudo := gl_conteudo || '<LoteNotaFiscalTomador>';
  --
  for rec_nfs in c_nfs loop
    exit when c_nfs%notfound or(c_nfs%notfound) is null;
    --
    vn_fase := 4;
    --
    -- Busca dados da pessoa_id do prestador
    for rec_pessoa in c_pessoa(rec_nfs.pessoa_id_prest) loop
      exit when c_pessoa%notfound or(c_pessoa%notfound) is null;
      --
      vv_nome     := rec_pessoa.nome; -- Nome
      vn_cep      := rec_pessoa.cep; -- Cep
      vv_endereco := rec_pessoa.lograd; -- Endereço
      vn_numero   := rec_pessoa.nro; -- Número
      vv_bairro   := rec_pessoa.bairro; -- Bairro
      vv_cidade   := rec_pessoa.ibge_cidade; -- Cidade
      vv_estado   := rec_pessoa.sigla_estado; -- Estado
      vn_fone     := rec_pessoa.fone; -- Fone
      vv_email    := rec_pessoa.email; -- email
      vn_pais     := rec_pessoa.cod_siscomex; -- País
      vv_compl    := rec_pessoa.compl; -- Compl
      vv_ie       := rec_pessoa.ie; -- Inscr. Estadual
      vv_fantasia := rec_pessoa.fantasia; -- Nome Fantasia
      --
      vv_cpf_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => rec_nfs.pessoa_id_prest);
      --
      -- Busca dados do tipo de prestador
      for rec_tpprest in c_tpprest(rec_nfs.pessoa_id_prest) loop
        exit when c_tpprest%notfound or(c_tpprest%notfound) is null;
        --
        --
        if rec_tpprest.cd_vlrtpparam = 2 then
          --
          vn_regesptrib := 2;
          --
        elsif rec_tpprest.cd_vlrtpparam = 1 then
          --
          vn_optantesim := 1;
          --
        else
          --
          vn_regesptrib := 0;
          vn_optantesim := 2;
          --
        end if;
        --
      end loop;
      --
    end loop;
    --
     -- Busca dados da pessoa_id do prestador
    for rec_pessoa2 in c_pessoa(rec_nfs.pessoa_id) loop
      exit when c_pessoa%notfound or(c_pessoa%notfound) is null;
      --
      vv_nome2     := rec_pessoa2.nome; -- Nome
      vn_cep2      := rec_pessoa2.cep; -- Cep
      vv_endereco2 := rec_pessoa2.lograd; -- Endereço
      vn_numero2   := rec_pessoa2.nro; -- Número
      vv_bairro2   := rec_pessoa2.bairro; -- Bairro
      vv_cidade2   := rec_pessoa2.ibge_cidade; -- Cidade
      vv_estado2   := rec_pessoa2.sigla_estado; -- Estado
      vn_fone2     := rec_pessoa2.fone; -- Fone
      vv_email2    := rec_pessoa2.email; -- email
      vn_pais2     := rec_pessoa2.cod_siscomex; -- País
      vv_compl2    := rec_pessoa2.compl; -- Compl
      vv_ie2       := rec_pessoa2.ie; -- Inscr. Estadual
      vv_fantasia2 := rec_pessoa2.fantasia; -- Nome Fantasia
      --
      vv_cpf_cnpj2 := pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => rec_nfs.pessoa_id);
      --
           -- Busca dados do tipo de prestador
      for rec_tpprest2 in c_tpprest(rec_nfs.pessoa_id) loop
        exit when c_tpprest%notfound or(c_tpprest%notfound) is null;
        --
        --
        if rec_tpprest2.cd_vlrtpparam = 2 then
          --
          vn_regesptrib2 := 2;
          --
        elsif rec_tpprest2.cd_vlrtpparam = 1 then
          --
          vn_optantesim2 := 1;
          --
        else
          --
          vn_regesptrib2 := 0;
          vn_optantesim2 := 2;
          --
        end if;
        --
      end loop;
      --
    end loop;
    --
    vn_aliq_apli4:= null;
    vn_aliq_apli5:= null;
    vn_aliq_apli6:= null;
    vn_aliq_apli11:= null;
    vn_aliq_apli12:= null;
    vn_aliq_apli13:= null;
    --
    begin
      select imp.aliq_apli
        into vn_aliq_apli6
        from imp_itemnf imp
       where imp.itemnf_id = rec_nfs.itemnf_id
         and imp.dm_tipo = 0 -- Retido
         and imp.tipoimp_id = 6
       group by imp.aliq_apli;
    exception
      when others then
        vn_aliq_apli6 := null;
    end;
    -- Recupera as informações das alíquotas
    for rec_imp_itemnf in c_imp_itemnf(rec_nfs.itemnf_id) loop
      exit when c_imp_itemnf%notfound or(c_imp_itemnf%notfound) is null;
      --
      --
      if rec_imp_itemnf.tipoimp_id = 4 then -- PIS
        --
        vn_aliq_apli4 := nvl(rec_imp_itemnf.aliq_apli, 0);
        --  
      elsif rec_imp_itemnf.tipoimp_id = 5 then -- COFINS
        --
        vn_aliq_apli5 := nvl(rec_imp_itemnf.aliq_apli, 0); 
        --
     elsif rec_imp_itemnf.tipoimp_id = 6 then -- Iss
        --
        vn_aliq_apli6 := nvl(rec_imp_itemnf.aliq_apli, 0); 
        --   
      elsif rec_imp_itemnf.tipoimp_id = 11  then -- CSLL
        --
        vn_aliq_apli11 := nvl(rec_imp_itemnf.aliq_apli, 0);
        --  
      elsif rec_imp_itemnf.tipoimp_id = 12 then -- IRRF
        --
        vn_aliq_apli12 := nvl(rec_imp_itemnf.aliq_apli, 0);
        -- 
      elsif rec_imp_itemnf.tipoimp_id = 13 then -- INSS
        --
        vn_aliq_apli13 := nvl(rec_imp_itemnf.aliq_apli, 0);
        --   
      end if;
      --
    end loop;
    --
    vn_fase := 5;
    --
    -- Detalhes
    -- ====================
    --
    vn_qtde_linhas := nvl(vn_qtde_linhas, 0) + 1;
    --
    --gl_conteudo := gl_conteudo || '<LoteNotaFiscalTomador>';
    --
    gl_conteudo := gl_conteudo || '<NotaFiscalTomador>';
    gl_conteudo := gl_conteudo || '<InfDeclaracaoPrestacaoServicoTomador>';
    --
    gl_conteudo := gl_conteudo || '<DadosNotaFiscal>';
    gl_conteudo := gl_conteudo || '<IdentificacaoNotaFiscal>';
    gl_conteudo := gl_conteudo || '<Numero>' || rtrim(substr(rec_nfs.nro_nf, 1, 15)) || '</Numero>';
    gl_conteudo := gl_conteudo || '<Especie>1</Especie>';
    gl_conteudo := gl_conteudo || '<Serie>' || rtrim(substr(rec_nfs.serie, 1, 3)) || '</Serie>'; 
    gl_conteudo := gl_conteudo || '</IdentificacaoNotaFiscal>';
    gl_conteudo := gl_conteudo || '<DataEmissao>' || rec_nfs.dt_emiss2 || '</DataEmissao>'; 
    gl_conteudo := gl_conteudo || '</DadosNotaFiscal>';
    --
    gl_conteudo := gl_conteudo || '<Servico>';
    gl_conteudo := gl_conteudo || '<Aliquotas>';
    gl_conteudo := gl_conteudo || '<Aliquota>' || vn_aliq_apli6 || '</Aliquota>';
    --
    if nvl(vn_aliq_apli5, 0) > 0 then
      --
      gl_conteudo := gl_conteudo || '<AliquotaCofins>' || trim(to_char(trunc(vn_aliq_apli5, 2), '999999999990d00', 'nls_numeric_characters=.,')) || '</AliquotaCofins>';
      -- 
    end if;
    --
    if nvl(vn_aliq_apli11, 0) > 0 then
      --
      gl_conteudo := gl_conteudo || '<AliquotaCsll>' || trim(to_char(trunc(vn_aliq_apli11, 2), '999999999990d00', 'nls_numeric_characters=.,')) || '</AliquotaCsll>';
      --
    end if;
    --
    if nvl(vn_aliq_apli13, 0) > 0 then
      --
      gl_conteudo := gl_conteudo || '<AliquotaInss>' || trim(to_char(trunc(vn_aliq_apli13, 2), '999999999990d00', 'nls_numeric_characters=.,')) || '</AliquotaInss>';
      --
    end if;
    --
    if nvl(vn_aliq_apli12, 0) > 0 then
      --
      gl_conteudo := gl_conteudo || '<AliquotaIr>' || trim(to_char(trunc(vn_aliq_apli12, 2), '999999999990d00', 'nls_numeric_characters=.,')) || '</AliquotaIr>';
      --
    end if;
    --
    if nvl(vn_aliq_apli4, 0) > 0 then
      --
      gl_conteudo := gl_conteudo || '<AliquotaPis>' || trim(to_char(trunc(vn_aliq_apli4, 2), '999999999990d00', 'nls_numeric_characters=.,')) || '</AliquotaPis>';
      --
    end if;
    --
    gl_conteudo := gl_conteudo || '</Aliquotas>';
    --
    vn_fase := 7;
    --
    vn_aliq_apli := 0;
    --
    -- Recupera o valor retido de ISS
    begin
      select nft.vl_ret_iss
        into vn_ret_iss
        from nota_fiscal_total nft
       where nft.notafiscal_id = rec_nfs.notafiscal_id;
    exception
      when others then
        vn_ret_iss := 0;
    end;
    --
    if nvl(vn_ret_iss, 0) > 0 then
      --
      gl_conteudo := gl_conteudo || '<IssRetido>1</IssRetido>'; -- Imposto Retido
      --
    else
      --
      gl_conteudo := gl_conteudo || '<IssRetido>2</IssRetido>'; -- Não tem Imposto Retido
      --
    end if;
    --
    if vv_cidade is not null then
      --
      gl_conteudo := gl_conteudo || '<CodigoMunicipio>' || vv_cidade || '</CodigoMunicipio>';
      --
    end if;
    --
    if vn_pais is not null then
      --
      gl_conteudo := gl_conteudo || '<CodigoPais>' || vn_pais || '</CodigoPais>';
      --
    end if;
    --
    vn_fase := 8;
    --
    --
    gl_conteudo := gl_conteudo || '<CodAtividade>' || lpad(replace(replace(rec_nfs.cd_lista_serv, '-', ''), '.', ''), 6, 0) || '</CodAtividade>';
    --
    gl_conteudo := gl_conteudo || '<CodAtividadeDesdobro>0000004</CodAtividadeDesdobro>';
    gl_conteudo := gl_conteudo || '</Servico>';
    --
    gl_conteudo := gl_conteudo || '<Prestador>';
    gl_conteudo := gl_conteudo || '<IdentificacaoPrestador>';
    gl_conteudo := gl_conteudo || '<CodEmpresa>' || 1 || '</CodEmpresa>';
    --
    if gn_dm_ind_emit = 0 then
    --
    gl_conteudo := gl_conteudo || '<CpfCnpj>';
    gl_conteudo := gl_conteudo || '<Cnpj>' || rtrim(substr(vv_cpf_cnpj, 1, 14)) || '</Cnpj>';
    gl_conteudo := gl_conteudo || '</CpfCnpj>';
    --
    if pk_csf.fkg_inscr_mun_pessoa(en_pessoa_id => rec_nfs.pessoa_id_prest) is not null then
      gl_conteudo := gl_conteudo || '<InscricaoMunicipal>' || rtrim(rpad(pk_csf.fkg_inscr_mun_pessoa(en_pessoa_id => rec_nfs.pessoa_id_prest), 7)) || '</InscricaoMunicipal>'; -- VERIFICAR
    end if;
    --
    gl_conteudo := gl_conteudo || '</IdentificacaoPrestador>';
    gl_conteudo := gl_conteudo || '<RazaoSocial>' || trim(rpad(pk_csf.fkg_nome_empresa(en_empresa_id => gn_empresa_id), 60, ' ')) || '</RazaoSocial>';
    --
    vn_fase := 9;
    --
    begin
      select fi.rg
        into vv_rg
        from fisica fi
       where fi.pessoa_id = rec_nfs.pessoa_id_prest;
    exception
      when others then
        vv_rg := null;
    end;
    --
    if vv_fantasia is not null then
      gl_conteudo := gl_conteudo || '<NomeFantasia>' || vv_fantasia || '</NomeFantasia>';
    end if;
    if vv_rg is not null then
      gl_conteudo := gl_conteudo || '<RgInscre>' || vv_rg || '</RgInscre>';
    end if;
    --
    gl_conteudo := gl_conteudo || '<Endereco>';
    --
    if vv_endereco is not null then
      gl_conteudo := gl_conteudo || '<Endereco>' || rtrim(substr(vv_endereco, 1, 200)) || '</Endereco>';
    end if;
    --
    if vn_numero is not null then
      gl_conteudo := gl_conteudo || '<Numero>' || rtrim(substr(nvl(vn_numero, 'SN'), 1, 6)) || '</Numero>';
    end if;
    --
    if vv_compl is not null then
      gl_conteudo := gl_conteudo || '<Complemento>' || rtrim(substr(vv_compl, 1, 60)) || '</Complemento>';
    end if;
    --
    if vv_bairro is not null then
      gl_conteudo := gl_conteudo || '<Bairro>' || rtrim(substr(vv_bairro, 1, 50)) || '</Bairro>';
    end if;
    --
    gl_conteudo := gl_conteudo || '<CodigoMunicipio>' || rtrim(substr(vv_cidade, 1, 50)) || '</CodigoMunicipio>';
    --
    if vv_estado is not null then
      gl_conteudo := gl_conteudo || '<Uf>' || vv_estado || '</Uf>';
    end if;
    --
    if vn_pais is not null then
      gl_conteudo := gl_conteudo || '<CodigoPais>' || rtrim(substr(vn_pais, 1, 30)) || '</CodigoPais>';
    end if;
    --
    if vn_cep is not null then
      gl_conteudo := gl_conteudo || '<Cep>' || rtrim(substr(vn_cep, 1, 8)) || '</Cep>';
    end if;
    --
    gl_conteudo := gl_conteudo || '</Endereco>';
    --
    gl_conteudo := gl_conteudo || '<Contato>';
    --
    if vn_fone is not null then
      gl_conteudo := gl_conteudo || '<Telefone>' || rtrim(vn_fone) || '</Telefone>';
    end if;
    --
    if vv_email is not null then
      gl_conteudo := gl_conteudo || '<Email>' || rtrim(vv_email) || '</Email>';
    end if;
    gl_conteudo := gl_conteudo || '</Contato>';
    --
    vn_fase := 10;
    --
    gl_conteudo := gl_conteudo || '<ExigibilidadeISS>1</ExigibilidadeISS>'; 
    --gl_conteudo := gl_conteudo || '<NumeroProcesso></NumeroProcesso>'; -- Não será enviado
    gl_conteudo := gl_conteudo || '<RegimeEspecialTributacao>' || vn_regesptrib || '</RegimeEspecialTributacao>';
    gl_conteudo := gl_conteudo || '<OptanteSimplesNacional>' || vn_optantesim || '</OptanteSimplesNacional>';
    --
    --
    else
    --
    gl_conteudo := gl_conteudo || '<CpfCnpj>';
    gl_conteudo := gl_conteudo || '<Cnpj>' || rtrim(substr(vv_cpf_cnpj2, 1, 14)) || '</Cnpj>';
    gl_conteudo := gl_conteudo || '</CpfCnpj>';
    --
    if pk_csf.fkg_inscr_mun_pessoa(en_pessoa_id => rec_nfs.pessoa_id) is not null then
      gl_conteudo := gl_conteudo || '<InscricaoMunicipal>' || rtrim(rpad(pk_csf.fkg_inscr_mun_pessoa(en_pessoa_id => rec_nfs.pessoa_id), 7)) || '</InscricaoMunicipal>'; -- VERIFICAR
    end if;
    --
    gl_conteudo := gl_conteudo || '</IdentificacaoPrestador>';
    gl_conteudo := gl_conteudo || '<RazaoSocial>' || trim(rpad(vv_nome2, 60, ' ')) || '</RazaoSocial>';
    --
    vn_fase := 9;
    --
    begin
      select fi.rg
        into vv_rg2
        from fisica fi
       where fi.pessoa_id = rec_nfs.pessoa_id;
    exception
      when others then
        vv_rg := null;
    end;
    --
    if vv_fantasia2 is not null then
      gl_conteudo := gl_conteudo || '<NomeFantasia>' || vv_fantasia2 || '</NomeFantasia>';
    end if;
    if vv_rg2 is not null then
      gl_conteudo := gl_conteudo || '<RgInscre>' || vv_rg2 || '</RgInscre>';
    end if;
    --
    gl_conteudo := gl_conteudo || '<Endereco>';
    --
    if vv_endereco2 is not null then
      gl_conteudo := gl_conteudo || '<Endereco>' || rtrim(substr(vv_endereco2, 1, 200)) || '</Endereco>';
    end if;
    --
    if vn_numero2 is not null then
      gl_conteudo := gl_conteudo || '<Numero>' || rtrim(substr(nvl(vn_numero2, 'SN'), 1, 6)) || '</Numero>';
    end if;
    --
    if vv_compl2 is not null then
      gl_conteudo := gl_conteudo || '<Complemento>' || rtrim(substr(vv_compl2, 1, 60)) || '</Complemento>';
    end if;
    --
    if vv_bairro2 is not null then
      gl_conteudo := gl_conteudo || '<Bairro>' || rtrim(substr(vv_bairro2, 1, 50)) || '</Bairro>';
    end if;
    --
    gl_conteudo := gl_conteudo || '<CodigoMunicipio>' || rtrim(substr(vv_cidade2, 1, 50)) || '</CodigoMunicipio>';
    --
    if vv_estado2 is not null then
      gl_conteudo := gl_conteudo || '<Uf>' || vv_estado2 || '</Uf>';
    end if;
    --
    if vn_pais2 is not null then
      gl_conteudo := gl_conteudo || '<CodigoPais>' || rtrim(substr(vn_pais2, 1, 30)) || '</CodigoPais>';
    end if;
    --
    if vn_cep2 is not null then
      gl_conteudo := gl_conteudo || '<Cep>' || rtrim(substr(vn_cep2, 1, 8)) || '</Cep>';
    end if;
    --
    gl_conteudo := gl_conteudo || '</Endereco>';
    --
    gl_conteudo := gl_conteudo || '<Contato>';
    --
    if vn_fone2 is not null then
      gl_conteudo := gl_conteudo || '<Telefone>' || rtrim(vn_fone2) || '</Telefone>';
    end if;
    --
    if vv_email2 is not null then
      gl_conteudo := gl_conteudo || '<Email>' || rtrim(vv_email2) || '</Email>';
    end if;
    gl_conteudo := gl_conteudo || '</Contato>';
    --
    vn_fase := 10;
    --
    gl_conteudo := gl_conteudo || '<ExigibilidadeISS>1</ExigibilidadeISS>'; 
    --gl_conteudo := gl_conteudo || '<NumeroProcesso></NumeroProcesso>'; -- Não será enviado
    gl_conteudo := gl_conteudo || '<RegimeEspecialTributacao>' || vn_regesptrib2 || '</RegimeEspecialTributacao>';
    gl_conteudo := gl_conteudo || '<OptanteSimplesNacional>' || vn_optantesim2 || '</OptanteSimplesNacional>';
    --
    end if;
    --
    gl_conteudo := gl_conteudo || '<IncentivoFiscal>1</IncentivoFiscal>';
    gl_conteudo := gl_conteudo || '</Prestador>';
    --
    vn_fase := 11;
    --
    begin
      select nft.vl_desc_cond, 
             nft.vl_desc_incond
        into vn_vl_desc_cond, 
             vn_vl_desc_incond
        from nota_fiscal_total nft
       where nft.notafiscal_id = rec_nfs.notafiscal_id;
    exception
      when others then
        null;
    end;
    --
    gl_conteudo := gl_conteudo || '<ItensNotas>';
    --
    for rec2 in c_itens(rec_nfs.notafiscal_id) loop
      --
      gl_conteudo := gl_conteudo || '<item>';
      gl_conteudo := gl_conteudo || '<DescriNfi>' || rec2.descr_item || '</DescriNfi>';
      gl_conteudo := gl_conteudo || '<MedidaNfi>' || rec2.unid_com || '</MedidaNfi>';
      gl_conteudo := gl_conteudo || '<QuantidadeNfi>' || rec2.qtde_comerc || '</QuantidadeNfi>';
      gl_conteudo := gl_conteudo || '<VlrUnitarioNfi>' || rec2.vl_unit_comerc || '</VlrUnitarioNfi>';
      --
      if nvl(vn_vl_desc_cond, 0) > 0 then
        gl_conteudo := gl_conteudo || '<DesccondicionalNfi>' || vn_vl_desc_cond || '</DesccondicionalNfi>';
      end if;
      --
      if nvl(vn_vl_desc_incond, 0) > 0 then
        gl_conteudo := gl_conteudo || '<DescincondicionalNfi>' || vn_vl_desc_incond || '</DescincondicionalNfi>';
      end if;
      --if  then
      --gl_conteudo := gl_conteudo || '<DeducaobaseNfi></DeducaobaseNfi>'; -- AGUARDANDO INFORMAÇÕES
      --end if;
      gl_conteudo := gl_conteudo || '</item>';
      --
    end loop;
    --
    gl_conteudo := gl_conteudo || '</ItensNotas>';
    gl_conteudo := gl_conteudo || '</InfDeclaracaoPrestacaoServicoTomador>';
    gl_conteudo := gl_conteudo || '</NotaFiscalTomador>';
    --
    vn_fase := 12;
    --
    -- Armazena a estrutura do arquivo
    --pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
    --
    vn_count := vn_count + 1;
  end loop;
  --
  vn_fase := 13;
  --
  -- Rodapé
  -- ====================
  --
  gl_conteudo := gl_conteudo || '</LoteNotaFiscalTomador>';
  gl_conteudo := gl_conteudo || '<QuantidadeNotas>' || vn_count || '</QuantidadeNotas>';
  gl_conteudo := gl_conteudo || '</Declaracao>';
  --
  vn_qtde_linhas := 0;
  --
  vn_fase := 14;
  --
  -- Armazena a estrutura do arquivo
  pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
  --
exception
  when others then
    raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_3511003 fase (' || vn_fase || '): ' || sqlerrm);
  
end pkb_gera_arq_cid_3511003;
---------------------------------------------------------------------------------------------------------------------
-- Procedimento para geração do arquivo de Nota Fiscal de Serviço de Arapiraca / AL

procedure pkb_gera_arq_cid_2700300 is
  --
  vn_fase        number := 0;
  vn_qtde_linhas number := 0;
  --
  vv_cpf_cnpj        varchar2(14);
  vv_cpf_cnpj_terc   varchar2(14);
  vv_nome            pessoa.nome%type;
  vn_cep             pessoa.cep%type;
  vv_endereco        pessoa.lograd%type;
  vn_numero          pessoa.nro%type;
  vv_bairro          pessoa.bairro%type;
  vv_cidade          cidade.descr%type;
  vv_estado          estado.sigla_estado%type;
  vn_fone            pessoa.fone%type;
  vv_email           pessoa.email%type;
  vv_compl           pessoa.compl%type;
  vv_fantasia        pessoa.fantasia%type;
  vv_inscr_mun_pessoa juridica.im%type;
  vn_pais            pais.cod_siscomex%type;
  vv_ie              juridica.ie%type;
  vn_regesptrib      number := 0;
  vn_optantesim      number := 0;
  vn_empresa_id      empresa.id%type;
  vn_pessoa_id_prest pessoa.id%type;
  vn_count           number := 0;
  --
  vn_vl_deducao      number := 0;
  vn_nf_liquido      number := 0;
  vn_aliq_apli6         imp_itemnf.aliq_apli%type := 0; 
  vn_ret_iss            nota_fiscal_total.vl_ret_iss%type;
  vn_vl_iss             imp_itemnf.vl_imp_trib%type;
  vn_aliq_iss           nota_fiscal_total.vl_imp_trib_iss%type;
  vn_cod_trib_municipio cod_trib_municipio.cod_trib_municipio%type;
  vn_vl_desc_cond       nota_fiscal_total.vl_desc_cond%type;
  vn_vl_desc_incond     nota_fiscal_total.vl_desc_incond%type;
  vv_rg                 fisica.rg%type;
  vn_vl_base_calc_iss   nota_fiscal_total.vl_base_calc_iss%type := 0;
  --
  i                     pls_integer    := 0;
  --
  -- Dados da pessoa_id
  cursor c_pessoa(en_pessoa_id pessoa.id%type) is
    select pe.nome,
           pe.lograd,
           pe.nro,
           pe.compl,
           pe.bairro,
           ci.descr,
           es.sigla_estado,
           pe.cep,
           pe.email,
           pe.fone,
           pa.descr pais_descr,
           ju.ie,
           pe.dm_tipo_pessoa,
           ci.ibge_cidade,
           pa.cod_siscomex,
           pe.fantasia
      from pessoa pe, 
           cidade ci, 
           estado es, 
           pais pa, 
           juridica ju
     where pe.id = en_pessoa_id
       and ci.id = pe.cidade_id
       and es.id = ci.estado_id
       and pa.id = pe.pais_id
       and pe.id = ju.pessoa_id;
  --
  -- Dados do tipo de prestador
  cursor c_tpprest(en_pessoa_id pessoa.id%type) is
    select vt.cd cd_vlrtpparam
      from pessoa_tipo_param pt, 
           tipo_param tp, 
           valor_tipo_param vt
     where pt.pessoa_id         = en_pessoa_id
       and pt.tipoparam_id      = tp.id
       and vt.tipoparam_id      = tp.id
       and pt.valortipoparam_id = vt.id;
  --
  -- Dados das NF
  
  -- ibge_cidade 
    
  cursor c_nfs is
    select distinct nf.id notafiscal_id,
                    nf.nro_nf,
                    nf.serie,
                    nf.dt_emiss,
                    to_char(nf.dt_emiss, 'YYYY-MM-DD"T"HH:MM:SS') dt_emiss2,
                    --nf.pessoa_id pessoa_id_prest,
                    p.id pessoa_id_prest,
                    nf.empresa_id empresa_id_toma,
                    case
                      when length(inf.cd_lista_serv) > 3 then
                       substr(inf.cd_lista_serv, 1, 2) || '.' || substr(inf.cd_lista_serv, 3, 2)
                      when length(inf.cd_lista_serv) = 3 then
                       substr(inf.cd_lista_serv, 1, 1) || '.' || substr(inf.cd_lista_serv, 2, 2)
                    end cd_lista_serv,
                    sum(inf.qtde_comerc) qtde_comerc,
                    sum(inf.qtde_comerc * inf.vl_unit_comerc) vl_item_bruto,
                    p.cidade_id,
                    inf.id itemnf_id,
                   (select ts.descr from tipo_servico ts where ts.cod_lst =  to_char(inf.cd_lista_serv))  descr_lista_serv
                   , (select cod_nat from nat_oper no where no.id =  nf.NATOPER_ID) cod_nat_oper
                   , to_char(nf.dt_emiss,'YYYY-MM-DD') as competencia
                   , (select p.id from empresa e, pessoa p where e.id = nf.empresa_id and e.pessoa_id = p.id) as en_pessoa_id      
                   , cm.cd
                   , inf.descr_item
                   , nf.pessoa_id
                   , (select pe.email from pessoa pe where pe.id = nf.pessoa_id) email
                   , (select pe.nome from pessoa pe where pe.id = nf.pessoa_id) fantasia 
                   , (select ci.ibge_cidade from pessoa pe, cidade ci where pe.cidade_id = ci.id and pe.id = nf.pessoa_id) ibge_cidade
                   ,case nvl(nfc.dm_nat_oper, 2)
                          when 1 then
                           14 -- Tributação no município (Não Retida)
                          when 2 then
                           28 -- Tributação fora do município (Pgto. pelo prestador)
                          when 3 then
                           12 -- Isenta
                          when 4 then
                           12 -- Imune
                          when 5 then
                           111 -- Exigibilidade suspensa por decisão judicial 
                          when 6 then
                           111 -- Exigibilidade suspensa por decisão judicial 
                          when 7 then
                           28 -- Recolhimento forab
                 end natureza_operacao  
      from nota_fiscal      nf,
           mod_fiscal       mf,
           empresa          e,
           pessoa           p,
           item_nota_fiscal inf,
           NF_COMPL_SERV     nfc,  
           cidade            ci,
           cidade_mod_fiscal cm
     where nf.empresa_id  = gn_empresa_id
       and nf.dm_ind_emit = gn_dm_ind_emit
       and nf.dm_st_proc  = 4
       and ((nf.dm_ind_emit = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
       and mf.id          = nf.modfiscal_id
       and nfc.notafiscal_id (+)  = nf.id  
       and cm.id(+)          = nfc.cidademodfiscal_id 
       and mf.cod_mod  = '99' -- Serviços
       and e.id           = nf.empresa_id
       and p.id           = e.pessoa_id
       and ci.id          = p.cidade_id
       --  and nf.pessoa_id  in  (select  p.id   from pessoa p   where p.id in (nf.pessoa_id )  and p.cidade_id <> gn_cidade_id) --Municícpio do Prestador diferente do Município do Tomador
       and p.cidade_id    = gn_cidade_id
       and nf.id          = inf.notafiscal_id
       and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
     group by nf.empresa_id,
              nf.id,
              nf.nro_nf,
              nf.serie,
              nf.dt_emiss, 
              --nf.pessoa_id,
              p.id,
              nf.empresa_id,
              cd_lista_serv,
              inf.qtde_comerc,
              p.cidade_id,
              nf.NATOPER_ID,
              inf.id,
              cm.cd,
              inf.descr_item,
              nf.pessoa_id,
              nfc.dm_nat_oper,
              p.email,   
              ci.ibge_cidade, 
              p.fantasia
     order by dt_emiss, nro_nf;
  --
  cursor c_imp_itemnf(en_itemnf_id item_nota_fiscal.id%type) is
    select imp.aliq_apli, imp.tipoimp_id
      from imp_itemnf imp
     where imp.itemnf_id = en_itemnf_id
       and imp.dm_tipo   = 1 -- Retido
     group by imp.aliq_apli, 
              imp.tipoimp_id;
  --
begin
  --
  vn_fase := 1;
  --
  begin
    select distinct p.id pessoa_id_prest
      into vn_pessoa_id_prest
      from nota_fiscal      nf,
           mod_fiscal       mf,
           empresa          e,
           pessoa           p,
           item_nota_fiscal inf
     where nf.empresa_id  = gn_empresa_id
       and nf.dm_ind_emit = gn_dm_ind_emit
       and nf.dm_st_proc  = 4
       and ((nf.dm_ind_emit = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
       and mf.id         = nf.modfiscal_id      
       and e.id          = nf.empresa_id
       and p.id          = e.pessoa_id
       and p.cidade_id   = gn_cidade_id
       and nf.id         = inf.notafiscal_id
       and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
       and rownum        = 1;
  exception
    when others then
      vn_pessoa_id_prest := null;
  end;
  --
      begin
      select count(*)  
        into vn_count 
      from nota_fiscal      nf,
           mod_fiscal       mf,
           empresa          e,
           pessoa           p,
           item_nota_fiscal inf
     where nf.empresa_id  = gn_empresa_id
       and nf.dm_ind_emit = gn_dm_ind_emit
       and nf.dm_st_proc  = 4
       and ((nf.dm_ind_emit = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between gd_dt_ini and gd_dt_fin) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between gd_dt_ini and gd_dt_fin))
       and mf.id          = nf.modfiscal_id
       and mf.cod_mod  = '99' -- Serviços
       and e.id           = nf.empresa_id
       and p.id           = e.pessoa_id
       and p.cidade_id    = gn_cidade_id
       and nvl(nf.dm_arm_nfe_terc, 0) = 0 -- #73514
       and nf.id          = inf.notafiscal_id;
     exception
      when others then
        vn_count  := null;
    end;
  --
  gl_conteudo := null;
  -- 
  --
  vn_qtde_linhas := 0;
  --
  vn_fase := 2;
  --
  -- Armazena a estrutura do arquivo
  --pkb_armaz_estrarqnfscidade ( el_conteudo => gl_conteudo );
  --
  vn_fase := 3;
  --
  --
  for rec_nfs in c_nfs loop
    exit when c_nfs%notfound or(c_nfs%notfound) is null;
    --
    vn_fase := 4;
    --
    vv_cpf_cnpj_terc := pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => rec_nfs.pessoa_id);
    
    vv_inscr_mun_pessoa := pk_csf.fkg_inscr_mun_pessoa(en_pessoa_id => rec_nfs.en_pessoa_id);
    --
    -- Busca dados da pessoa_id do prestador
    for rec_pessoa in c_pessoa(rec_nfs.pessoa_id_prest) loop
      exit when c_pessoa%notfound or(c_pessoa%notfound) is null;
      --
      vv_nome     := rec_pessoa.nome; -- Nome
      vn_cep      := rec_pessoa.cep; -- Cep
      vv_endereco := rec_pessoa.lograd; -- Endereço
      vn_numero   := rec_pessoa.nro; -- Número
      vv_bairro   := rec_pessoa.bairro; -- Bairro
      vv_cidade   := rec_pessoa.ibge_cidade; -- Cidade
      vv_estado   := rec_pessoa.sigla_estado; -- Estado
      vn_fone     := rec_pessoa.fone; -- Fone
      vv_email    := rec_pessoa.email; -- email
      vn_pais     := rec_pessoa.cod_siscomex; -- País
      vv_compl    := rec_pessoa.compl; -- Compl
      vv_ie       := rec_pessoa.ie; -- Inscr. Estadual
      vv_fantasia := rec_pessoa.fantasia; -- Nome Fantasia
      --
      vv_cpf_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => rec_nfs.pessoa_id_prest);
      --
      -- Busca dados do tipo de prestador
      for rec_tpprest in c_tpprest(rec_nfs.pessoa_id_prest) loop
        exit when c_tpprest%notfound or(c_tpprest%notfound) is null;
        --
        --
        if rec_tpprest.cd_vlrtpparam = 2 then
          --
          vn_regesptrib := 2;
          --
        elsif rec_tpprest.cd_vlrtpparam = 1 then
          --
          vn_optantesim := 1;
          --
        else
          --
          vn_regesptrib := 0;
          vn_optantesim := 2;
          --
        end if;
        --
      end loop;
      --
    end loop;
    --
    -- Recupera as informações das alíquotas
    for rec_imp_itemnf in c_imp_itemnf(rec_nfs.itemnf_id) loop
      exit when c_imp_itemnf%notfound or(c_imp_itemnf%notfound) is null;
      --
      if  rec_imp_itemnf.tipoimp_id = 6 then -- ISS
        --
        vn_aliq_apli6 := rec_imp_itemnf.aliq_apli;
 
        --   
      end if;
      -- 
    -- Recupera o valor retido de ISS
    begin
      select nft.vl_ret_iss,  nft.vl_base_calc_iss, vl_imp_trib_iss
        into vn_ret_iss, vn_vl_base_calc_iss, vn_aliq_iss
        from nota_fiscal_total nft
       where nft.notafiscal_id = rec_nfs.notafiscal_id;
    exception
      when others then
        vn_ret_iss := null;
        vn_vl_base_calc_iss  := null;
        vn_aliq_iss   := null;
    end;
    --     
    end loop;
    --
    vn_fase := 5;
    --
    --
      begin
        --
        select distinct nvl(sum(ii.vl_imp_trib),0)
           into vn_vl_iss
           from item_nota_fiscal inf
              , imp_itemnf ii
              , tipo_imposto ti
          where inf.notafiscal_id = rec_nfs.notafiscal_id
            and inf.id            = ii.itemnf_id
            and ii.dm_tipo        = 0 --  
            and ti.id             = ii.tipoimp_id
            and ti.cd  in ('6');
         exception
          when others then
           vn_vl_iss := null; 
      end;   
    --
            begin
        --
        select nvl(sum(a.vl_deducao),0)
           into vn_vl_deducao
           from itemnf_compl_serv a, item_nota_fiscal b
          where a.itemnf_id = b.id
          and b.notafiscal_id =  rec_nfs.notafiscal_id;
         exception
          when others then
           vn_vl_deducao := null; 
         end;
    --    
    vn_nf_liquido := rec_nfs.vl_item_bruto - vn_vl_deducao;
    --
    --    
    if i = 0 then
     --
     i := i + 1;
     --
    gl_conteudo := gl_conteudo || '<?xml version="1.0" encoding="utf-8"?>';
    gl_conteudo := gl_conteudo || '<Cnpj>'|| pk_csf.fkg_cnpj_ou_cpf_empresa(en_empresa_id => gn_empresa_id) ||'</Cnpj>';
    if vv_inscr_mun_pessoa is not null then
    gl_conteudo := gl_conteudo || '<InscricaoMunicipal>'|| vv_inscr_mun_pessoa ||'</InscricaoMunicipal>';
    end if;
    gl_conteudo := gl_conteudo || '<QuantidadeNfs>'|| vn_count ||'</QuantidadeNfs>';
    --
    gl_conteudo := gl_conteudo || '<ListaNfse>';
    --
    end if;
    --
    gl_conteudo := gl_conteudo || '<Nfse>';
    
    gl_conteudo := gl_conteudo || '<InfNfse id="'||rec_nfs.nro_nf||'">';
    gl_conteudo := gl_conteudo || '<Numero>'|| rec_nfs.nro_nf ||'</Numero>';
    gl_conteudo := gl_conteudo || '<Serie>'|| rec_nfs.serie ||'</Serie>';
    --
    if  rec_nfs.cd  is null then
     gl_conteudo := gl_conteudo || '<Tipo>'|| 3 ||'</Tipo>';    --=>  Nota Fiscal  
     else
     gl_conteudo := gl_conteudo || '<Tipo>'|| rec_nfs.cd ||'</Tipo>';         
     end if;   
    --
    gl_conteudo := gl_conteudo || '<DataEmissao>'|| rec_nfs.dt_emiss2 ||'</DataEmissao>';
    gl_conteudo := gl_conteudo || '<NaturezaOperacao>'|| rec_nfs.natureza_operacao ||'</NaturezaOperacao>';
    gl_conteudo := gl_conteudo || '<Competencia>'|| rec_nfs.competencia ||'</Competencia>';
    --
    --
    gl_conteudo := gl_conteudo || '<Servico>';
    gl_conteudo := gl_conteudo || '<Valores>';
    gl_conteudo := gl_conteudo || '<ValorServicos>'||  to_char(trunc(nvl(rec_nfs.vl_item_bruto,0), 2), '999999999999990D00', 'nls_numeric_characters=.,') ||'</ValorServicos>';
   if nvl(vn_vl_deducao,0) > 0 then
   gl_conteudo := gl_conteudo || '<ValorDeducoes>'|| vn_vl_deducao ||'</ValorDeducoes>';
   end if;
    --
    if nvl(vn_ret_iss, 0) > 0 then
      gl_conteudo := gl_conteudo || '<IssRetido>1</IssRetido>'; -- Imposto Retido
      if vn_vl_iss is not null then
      gl_conteudo := gl_conteudo || '<ValorIss>'||  to_char(trunc(nvl(vn_vl_iss,0), 2), '999999999999990D00', 'nls_numeric_characters=.,') ||'</ValorIss>';
      end if;
      if nvl(vn_vl_deducao,0) > 0 then
      gl_conteudo := gl_conteudo || '<ValorIssRetido>' || to_char(trunc(nvl(vn_vl_deducao,0), 2), '999999999999990D00', 'nls_numeric_characters=.,') ||  '</ValorIssRetido>';
      end if;
    else  
      gl_conteudo := gl_conteudo || '<IssRetido>2</IssRetido>'; -- Não tem Imposto Retido
      if vn_vl_iss is not null then
       gl_conteudo := gl_conteudo || '<ValorIss>'|| to_char(trunc(nvl(vn_vl_iss,0), 2), '999999999999990D00', 'nls_numeric_characters=.,') ||'</ValorIss>';
       end if;
    end if;
    --    
    --
    if nvl(vn_vl_base_calc_iss,0) > 0 then
    gl_conteudo := gl_conteudo || '<BaseCalculo>' || to_char(trunc(nvl(vn_vl_base_calc_iss,0), 2), '999999999999990D00', 'nls_numeric_characters=.,')  || '</BaseCalculo>';
    end if;
    if nvl(vn_aliq_iss,0) > 0 then
    gl_conteudo := gl_conteudo || '<Aliquota>'|| to_char(trunc(nvl(vn_aliq_iss,0), 2), '999999999999990D00', 'nls_numeric_characters=.,') || '</Aliquota>';
    end if;
    if nvl(vn_nf_liquido,0) > 0 then
    gl_conteudo := gl_conteudo || '<ValorLiquidoNfse>'|| to_char(trunc(nvl(vn_nf_liquido,0), 2), '999999999999990D00', 'nls_numeric_characters=.,')  || '</ValorLiquidoNfse>';
    end if;
    gl_conteudo := gl_conteudo || '</Valores>';
    gl_conteudo := gl_conteudo || '<ItemListaServico>' || rec_nfs.cd_lista_serv || '</ItemListaServico>';
    gl_conteudo := gl_conteudo || '<Discriminacao>' || rec_nfs.descr_item || '</Discriminacao>';
    gl_conteudo := gl_conteudo || '</Servico>';
    --
    --
    gl_conteudo := gl_conteudo || '<PrestadorServico>';
    gl_conteudo := gl_conteudo || '<IdentificacaoPrestador>';
    if gn_dm_ind_emit = 0 then  
      if vv_cpf_cnpj is null then
       gl_conteudo := gl_conteudo || '<Cnpj>00000000000000</Cnpj>'; 
      else
    gl_conteudo := gl_conteudo || '<Cnpj>' || vv_cpf_cnpj || '</Cnpj>';
    end if;
    gl_conteudo := gl_conteudo || '</IdentificacaoPrestador>';
    gl_conteudo := gl_conteudo || '<RazaoSocial>' || vv_fantasia || '</RazaoSocial>';
    gl_conteudo := gl_conteudo || '<Endereco>';
    gl_conteudo := gl_conteudo || '<CodigoMunicipio>' || vv_cidade || '</CodigoMunicipio>';
    gl_conteudo := gl_conteudo || '</Endereco>';
    gl_conteudo := gl_conteudo || '<Contato>';
    if vv_email is not null then
    gl_conteudo := gl_conteudo || '<Email>' || vv_email || '</Email>';
    end if;
    else
      if vv_cpf_cnpj_terc is null then
       gl_conteudo := gl_conteudo || '<Cnpj>00000000000000</Cnpj>'; 
      else
     gl_conteudo := gl_conteudo || '<Cnpj>'|| vv_cpf_cnpj_terc || '</Cnpj>';
     end if;
     gl_conteudo := gl_conteudo || '</IdentificacaoPrestador>';
     gl_conteudo := gl_conteudo || '<RazaoSocial>' || rec_nfs.fantasia || '</RazaoSocial>';
     gl_conteudo := gl_conteudo || '<Endereco>';
     gl_conteudo := gl_conteudo || '<CodigoMunicipio>' || rec_nfs.ibge_cidade || '</CodigoMunicipio>';
     gl_conteudo := gl_conteudo || '</Endereco>';
     gl_conteudo := gl_conteudo || '<Contato>';
     if rec_nfs.email is not null then
     gl_conteudo := gl_conteudo || '<Email>' || rec_nfs.email || '</Email>';
     end if;
    end if;

    gl_conteudo := gl_conteudo || '</Contato>';
    gl_conteudo := gl_conteudo || '</PrestadorServico>';
    --      
    gl_conteudo := gl_conteudo || '<TomadorServico>';
    gl_conteudo := gl_conteudo || '<IdentificacaoTomador>';
    gl_conteudo := gl_conteudo || '<CpfCnpj>';
    gl_conteudo := gl_conteudo || '<Cnpj>' || pk_csf.fkg_cnpj_ou_cpf_empresa(en_empresa_id => gn_empresa_id) || '</Cnpj>';
    gl_conteudo := gl_conteudo || '</CpfCnpj>';
    if vv_inscr_mun_pessoa is not null then
    gl_conteudo := gl_conteudo || '<InscricaoMunicipal>'|| vv_inscr_mun_pessoa ||'</InscricaoMunicipal>';
    end if;
    gl_conteudo := gl_conteudo || '</IdentificacaoTomador>';
    gl_conteudo := gl_conteudo || '</TomadorServico>';
    --
    gl_conteudo := gl_conteudo || '</InfNfse>';
    gl_conteudo := gl_conteudo || '</Nfse>';
    --
    --
    --
    end loop;
    --
    if  gl_conteudo is not null then
    gl_conteudo := gl_conteudo || '</ListaNfse>';
    end if;
  -- 
  --
  vn_fase := 14;
  --
  -- Armazena a estrutura do arquivo
  pkb_armaz_estrarqnfscidade(el_conteudo => gl_conteudo);
  --
exception
  when others then
    raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arq_cid_2700300 fase (' || vn_fase || '): ' || sqlerrm);
  
end pkb_gera_arq_cid_2700300;


---------------------------------------------------------------------------------------------------------------------
-- Procedimento de geração do arquivo
procedure pkb_gera_arquivo(en_empresa_id  in estr_arq_nfs_cidade.empresa_id%type,
                           en_usuario_id  in estr_arq_nfs_cidade.usuario_id%type,
                           en_dm_ind_emit in nota_fiscal.dm_ind_emit%type,
                           en_cidade_id   in cidade.id%type,
                           ed_dt_ini      in date,
                           ed_dt_fin      in date,
                           en_tipo        in number) is
  --
  vn_fase number := 0;
  --
begin
  --
  vn_fase := 1;
  --
  if fkg_valida_param(en_empresa_id, en_usuario_id, en_cidade_id, en_dm_ind_emit) = 0 then
    --
    -- Os dados sendo válidos, inicia geração do arquivo
    --
    vn_fase := 2;
    --
    vt_estr_arq_nfs_cidade.delete;
    --
    gd_dt_ini  := ed_dt_ini;
    gd_dt_fin  := ed_dt_fin;
    gn_en_tipo := en_tipo;
    --
    delete 
      from estr_arq_nfs_cidade 
     where empresa_id = gn_empresa_id;
    --
    commit;
    --
    vn_fase := 3;
    --
    -- verifica para qual cidade vai gerar o arquivo
    if gv_ibge_cidade = '4119152' then -- Pinhais / PR
      --
      vn_fase := 3.1;
      --
      pkb_gera_arq_cid_4119152;
      --
    elsif gv_ibge_cidade = '3515004' then -- Embu / SP
      --
      vn_fase := 3.2;
      --
      pkb_gera_arq_cid_3515004;
      --
    elsif gv_ibge_cidade = '4106902' then -- Curitiba / PR
      --
      vn_fase := 3.3;
      --
      pkb_gera_arq_cid_4106902;
      --
    elsif gv_ibge_cidade = '3505708' then -- Barueri / SP
      --
      vn_fase := 3.4;
      --
      pkb_gera_arq_cid_3505708;
      --
    elsif gv_ibge_cidade = '3522505' then -- Itapevi / SP
      --
      vn_fase := 3.5;
      --
      pkb_gera_arq_cid_3522505;
      --
    elsif gv_ibge_cidade = '3304557' then -- Rio de Janeiro / RJ
      --
      vn_fase := 3.6;
      --
      pkb_gera_arq_cid_3304557;
      --
    elsif gv_ibge_cidade = '4314902' then -- Porto Alegre / RS
      --
      vn_fase := 3.7;
      --
      pkb_gera_arq_cid_4314902;
      --
    elsif gv_ibge_cidade = '3106200' then -- Belo Horizonte / MG
      --
      vn_fase := 3.8;
      --
      pkb_gera_arq_cid_3106200;
      --
    elsif gv_ibge_cidade = '2905701' then -- Camacari / BA
      --
      vn_fase := 3.9;
      --
      pkb_gera_arq_cid_2905701;
      --
    elsif gv_ibge_cidade = '3547304' then -- Santana do Parnaiba / SP
      --
      vn_fase := 3.10;
      --
      pkb_gera_arq_cid_3547304;
      --
    elsif gv_ibge_cidade = '1501402' then -- Belém / PA
      --
      vn_fase := 3.11;
      --
      pkb_gera_arq_cid_1501402;
      --
    elsif gv_ibge_cidade = '3550308' then -- São Paulo / SP
      --
      vn_fase := 3.12;
      --
      pkb_gera_arq_cid_3550308;
      --
    elsif gv_ibge_cidade = '3523404' then -- Itatiba / SP
      --
      vn_fase := 3.13;
      --
      pkb_gera_arq_cid_3523404;
      --
    elsif gv_ibge_cidade = '2611606' then -- Recife / PE
      --
      vn_fase := 3.14;
      --
      pkb_gera_arq_cid_2611606;
      --
    elsif gv_ibge_cidade = '1302603' then -- Manaus / AM
      --
      vn_fase := 3.15;
      --
      pkb_gera_arq_cid_1302603;
      --
    elsif gv_ibge_cidade = '4209102' then -- Joinville / SC
      --
      vn_fase := 3.16;
      --
      pkb_gera_arq_cid_4209102;
      --
    elsif gv_ibge_cidade = '2607901' then -- Jaboatão dos Guararapes / PE
      --
      vn_fase := 3.17;
      --
      pkb_gera_arq_cid_2607901;
      --
    elsif gv_ibge_cidade = '1504208' then -- Marabá / PA
      --
      vn_fase := 3.18;
      --
      pkb_gera_arq_cid_1504208;
      --
    elsif gv_ibge_cidade = '2918407' then -- Juazeiro / BA
      --
      vn_fase := 3.19;
      --
      pkb_gera_arq_cid_2918407;
      --
    elsif gv_ibge_cidade = '3205309' then -- Vitória / ES
      --
      vn_fase := 3.20;
      --
      pkb_gera_arq_cid_3205309;
      --
    elsif gv_ibge_cidade = '2111300' then -- São Luís / MA
      --
      vn_fase := 3.21;
      --
      pkb_gera_arq_cid_2111300;
      --
    elsif gv_ibge_cidade = '2408102' then -- Natal / RN
      --
      vn_fase := 3.22;
      --
      pkb_gera_arq_cid_2408102;
      --
    elsif gv_ibge_cidade = '3552205' then -- Sorocaba / SP
      --
      vn_fase := 3.23;
      --
      pkb_gera_arq_cid_3552205;
      --
    elsif gv_ibge_cidade = '3509502' then -- Campinas / SP
      --
      vn_fase := 3.24;
      --
      pkb_gera_arq_cid_3509502;
      --
    elsif gv_ibge_cidade = '4216602' then -- São José / SC
      --
      vn_fase := 3.25;
      --
      pkb_gera_arq_cid_4216602;
      --
    elsif gv_ibge_cidade = '3527306' then -- Louveira / SP
      --
      vn_fase := 3.26;
      --
      pkb_gera_arq_cid_3527306;
      --
    elsif gv_ibge_cidade = '4313375' then -- Nova Santa Rita / RS
      --
      vn_fase := 3.27;
      --
      pkb_gera_arq_cid_4313375;
      --
    elsif gv_ibge_cidade = '2503209' then -- Cabedelo / PB
      --
      vn_fase := 3.28;
      --
      pkb_gera_arq_cid_2503209;
      --
    elsif gv_ibge_cidade = '3118601' then -- Contagem / MG
      --
      vn_fase := 3.29;
      --
      pkb_gera_arq_cid_3118601;
      --
    elsif gv_ibge_cidade = '3144805' then -- Nova Lima / MG
      --
      vn_fase := 3.30;
      --
      pkb_gera_arq_cid_3144805;
      --
    elsif gv_ibge_cidade = '5103403' then -- Cuiabá / MT
      --
      vn_fase := 3.31;
      --
      pkb_gera_arq_cid_5103403;
      --
    elsif gv_ibge_cidade = '2304400' then -- Fortaleza / CE
      --
      vn_fase := 3.32;
      --
      pkb_gera_arq_cid_2304400;
      --
    elsif gv_ibge_cidade = '4113700' then -- Londrina / PR
      --
      vn_fase := 3.33;
      --
      pkb_gera_arq_cid_4113700;
      --
    elsif gv_ibge_cidade = '2307650' then -- Maracanaú / CE
      --
      vn_fase := 3.34;
      --
      pkb_gera_arq_cid_2307650;
      --
    elsif gv_ibge_cidade = '2313401' then -- Tianguá / CE
      --
      vn_fase := 3.35;
      --
      pkb_gera_arq_cid_2313401;
      --
    elsif gv_ibge_cidade = '4309209' then -- Gravataí / RS
      --
      vn_fase := 3.36;
      --
      pkb_gera_arq_cid_4309209;
      --
    elsif gv_ibge_cidade = '4125506' then -- São José dos Pinhais / PR
      --
      vn_fase := 3.37;
      --
      pkb_gera_arq_cid_4125506;
      --
    elsif gv_ibge_cidade = '4211900' then -- Palhoça / SC
      --
      vn_fase := 3.38;
      --
      pkb_gera_arq_cid_4211900;
      --   
    elsif gv_ibge_cidade = '3503307' then -- Araras / SP
      --
      vn_fase := 3.39;
      --
      pkb_gera_arq_cid_3503307;
      --   
    elsif gv_ibge_cidade = '5218789' then -- Rio Quente / GO
      --
      vn_fase := 3.39;
      --
      pkb_gera_arq_cid_5218789;
      --  
    elsif gv_ibge_cidade = '2921005' then -- Mata de São João / BA
      --
      vn_fase := 3.40;
      --
      pkb_gera_arq_cid_2921005;
      --     
    elsif gv_ibge_cidade = '4205407' then -- Florianópolis / SC
      --
      vn_fase := 3.41;
      --
      pkb_gera_arq_cid_4205407;
      --   
    elsif gv_ibge_cidade = '3306305' then -- Volta Redonda / RJ
      --
      vn_fase := 3.42;
      --
      pkb_gera_arq_cid_3306305;
      --        
    elsif gv_ibge_cidade = '5002704' then -- Campo Grande / MS
      --
      vn_fase := 3.43;
      --
      pkb_gera_arq_cid_5002704;
      -- 
    elsif gv_ibge_cidade = '3549904' then -- São José dos Campos / SP
      --
      vn_fase := 3.43;
      --
      pkb_gera_arq_cid_3549904;
      --
    elsif gv_ibge_cidade = '3530300' then -- Mirassol / SP
      --
      vn_fase := 3.44;
      --
      pkb_gera_arq_cid_3530300; 
      --  
    elsif gv_ibge_cidade = '3511003' then -- Castilho / SP
      --
      vn_fase := 3.45;
      --
      pkb_gera_arq_cid_3511003; 
      --    
    elsif gv_ibge_cidade = '2700300' then -- Arapiraca / AL
      --
      vn_fase := 3.46;
      -- 
      pkb_gera_arq_cid_2700300;
      --                
    else
      vn_fase := 3.99;
      --
      pkb_gera_arq_cid_dm_ginfes; -- Caso a cidade tenha vinculo com GINFES
      --
    end if;
    --
    vn_fase := 99;
    --
    -- Grava os dados
    pkb_grava_estrarqnfscidade;
    --
  end if;
  --
exception
  when others then
    raise_application_error(-20101, 'Erro na pk_arq_nfs_cidade.pkb_gera_arquivo fase (' || vn_fase || '): ' || sqlerrm);
end pkb_gera_arquivo;

---------------------------------------------------------------------------------------------------------------------
end pk_arq_nfs_cidade;
/
