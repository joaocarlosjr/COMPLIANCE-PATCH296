create or replace package body csf_own.pk_apur_icms_st is

-------------------------------------------------------------------------------------------------------
--| Corpo do pacote de procedimentos de Geração da Apuração de ICMS-ST
-------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------
-- Função retorna o Valor Total da Base de Cálculo do ICMS retido por Substituição Tributária p/ reg. D697
function fkg_soma_bc_retencao_st_d697
         return reg_an_cons_prest_serv.vl_bc_icms_st%type
is
   --
   vn_vl_bc_icms_st reg_an_cons_prest_serv.vl_bc_icms_st%type := 0;
   --
begin
   --
   select sum(i.vl_bc_icms_st) vl_bc_icms_st
     into vn_vl_bc_icms_st
     from cons_nf_prest_serv         cnfps
        , reg_an_cons_nf_prest_serv  r
        , cfop                       c
        , reg_an_cons_nf_ps_st_uf    i
    where cnfps.empresa_id           = gt_row_per_apur_icms_st.empresa_id
      and ( trunc(cnfps.dt_doc_ini) >= trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(cnfps.dt_doc_fin) <= trunc(gt_row_per_apur_icms_st.dt_fim) )
      and r.consnfprestserv_id       = cnfps.id
      and c.id                       = r.cfop_id
      and substr(c.cd, 1, 1)        in ('5', '6')
      and i.reganconsnfprestserv_id  = r.id
      and i.estado_id                = gt_row_apuracao_icms_st.estado_id;
   --
   return vn_vl_bc_icms_st;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_bc_retencao_st_d697:' || sqlerrm);
end fkg_soma_bc_retencao_st_d697;

-----------------------------------------------------------------------------------------------------------
-- Função retorna o Valor Total da Base de Cálculo do ICMS retido por Substituição Tributária p/ reg. D690
function fkg_soma_bc_retencao_st_d690
         return reg_an_cons_prest_serv.vl_bc_icms_st%type
is
   --
   vn_vl_bc_icms_st reg_an_cons_prest_serv.vl_bc_icms_st%type := 0;
   --
begin
   --
   select sum(r.vl_bc_icms_st) vl_bc_icms_st
     into vn_vl_bc_icms_st
     from cons_prest_serv         cps
        , cidade                  cid
        , reg_an_cons_prest_serv  r
        , cfop                    c
    where cps.empresa_id          = gt_row_per_apur_icms_st.empresa_id
      and trunc(cps.dt_doc) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
      and cid.ibge_cidade         = cps.cod_mun_ibge
      and cid.estado_id           = gt_row_apuracao_icms_st.estado_id
      and r.consprestserv_id      = cps.id
      and c.id                    = r.cfop_id
      and substr(c.cd, 1, 1)     in ('5', '6');
   --
   return vn_vl_bc_icms_st;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_bc_retencao_st_d690:' || sqlerrm);
end fkg_soma_bc_retencao_st_d690;

-----------------------------------------------------------------------------------------------------------
-- Função retorna o Valor Total da Base de Cálculo do ICMS retido por Substituição Tributária p/ reg. C791
function fkg_soma_bc_retencao_st_c791
         return inf_consnfviaun_icmsst_uf.vl_bc_icms_st%type
is
   --
   vn_vl_bc_icms_st inf_consnfviaun_icmsst_uf.vl_bc_icms_st%type := 0;
   --
begin
   --
   select sum(i.vl_bc_icms_st) vl_bc_icms_st
     into vn_vl_bc_icms_st
     from cons_nf_via_unica           cnf
        , reg_anal_cons_nf_via_unica  r
        , cfop                        c
        , inf_consnfviaun_icmsst_uf   i
    where cnf.empresa_id             = gt_row_per_apur_icms_st.empresa_id
      and ( trunc(cnf.dt_doc_ini)   >= trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(cnf.dt_doc_fin) <= trunc(gt_row_per_apur_icms_st.dt_fim) )
      and r.consnfviaunica_id        = cnf.id
      and c.id                       = r.cfop_id
      and substr(c.cd, 1, 1)        in ('5', '6')
      and i.reganalconsnfviaunica_id = r.id
      and i.estado_id                = gt_row_apuracao_icms_st.estado_id;
   --
   return vn_vl_bc_icms_st;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_bc_retencao_st_c791:' || sqlerrm);
end fkg_soma_bc_retencao_st_c791;

-----------------------------------------------------------------------------------------------------------
-- Função retorna o Valor Total da Base de Cálculo do ICMS retido por Substituição Tributária p/ reg. C690
function fkg_soma_bc_retencao_st_c690
         return reg_anal_cons_nota_fiscal.vl_bc_icms_st%type
is
   --
   vn_vl_bc_icms_st reg_anal_cons_nota_fiscal.vl_bc_icms_st%type := 0;
   --
begin
   --
   select sum(r.vl_bc_icms_st) vl_bc_icms_st
     into vn_vl_bc_icms_st
     from cons_nota_fiscal           cnf
        , cidade                     cid
        , reg_anal_cons_nota_fiscal  r
        , cfop                       c
    where cnf.empresa_id          = gt_row_per_apur_icms_st.empresa_id
      and trunc(cnf.dt_doc) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
      and cid.id                  = cnf.cidade_id
      and cid.estado_id           = gt_row_apuracao_icms_st.estado_id
      and r.consnotafiscal_id     = cnf.id
      and c.id                    = r.cfop_id
      and substr(c.cd, 1, 1)     in ('5', '6');
   --
   return vn_vl_bc_icms_st;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_bc_retencao_st_c690:' || sqlerrm);
end fkg_soma_bc_retencao_st_c690;

-----------------------------------------------------------------------------------------------------------
-- Função retorna o Valor Total da Base de Cálculo do ICMS retido por Substituição Tributária p/ reg. C190
-- Antigo nome do cursor era: c_soma_retencao_st_c190_cd590
function fkg_soma_bc_ret_st_c190_cd590
         return nfregist_analit.vl_bc_icms_st%type
is
   --
   vn_vl_bc_icms_st nfregist_analit.vl_bc_icms_st%type := 0;
   --
begin
   --
   select sum(r.vl_bc_icms_st) vl_bc_icms_st
     into vn_vl_bc_icms_st
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nfregist_analit  r
        , cfop             c
        , nota_fiscal_dest nfd
    where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
      and sd.id              = nf.sitdocto_id
      and sd.cd         not in ('02', '03') -- nada de cancelado
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id              = nfd.notafiscal_id
      and nfd.uf             = gv_apur_sigla_estado
      and r.notafiscal_id    = nf.id
      and c.id               = r.cfop_id
      and substr(c.cd,1,1)  in ('5', '6');
   --
   return vn_vl_bc_icms_st;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_bc_ret_st_c190_cd590:' || sqlerrm);
end fkg_soma_bc_ret_st_c190_cd590;

-------------------------------------------------------------------------------------------------------
-- Função retorna o saldo anterior
function fkg_saldo_credor_ant_st
         return apuracao_icms_st.vl_saldo_cred_ant_st%type
is
   --
   vn_vl_saldo_cred_ant_st apuracao_icms_st.vl_saldo_cred_ant_st%type := 0;
   --
begin
   --
   select vl_saldo_cred_st_transp
     into vn_vl_saldo_cred_ant_st
     from per_apur_icms_st p
        , apuracao_icms_st a
    where p.empresa_id                   = gt_row_per_apur_icms_st.empresa_id
      and to_char(p.dt_inicio, 'rrrrmm') = to_char(add_months(gt_row_per_apur_icms_st.dt_inicio, -1), 'rrrrmm')
      and p.dm_tipo                      = gt_row_per_apur_icms_st.dm_tipo
      and a.perapuricmsst_id             = p.id
      and a.estado_id                    = gt_row_apuracao_icms_st.estado_id
      and a.dm_situacao                  = 3; -- Processada
   --
   return nvl(vn_vl_saldo_cred_ant_st,0);
   --
exception
   when others then
      return 0;
end fkg_saldo_credor_ant_st;

-------------------------------------------------------------------------------------------------------
-- Função retorna o Valor total do ICMS ST de devolução de mercadorias
function fkg_soma_devol_st
         return nfregist_analit.vl_icms_st%type
is
   --
   vn_vl_icms_st  nfregist_analit.vl_icms_st%type := 0;
   vn_vl_icms_st1 nfregist_analit.vl_icms_st%type := 0;
   vn_vl_icms_st2 nfregist_analit.vl_icms_st%type := 0;
   vn_vl_fcp_st1  imp_itemnf.vl_fcp%type := 0;
   vn_vl_fcp_st2  imp_itemnf.vl_fcp%type := 0;
   --
begin
   --
   select sum(nvl(r.vl_icms_st,0)) vl_icms_st
     into vn_vl_icms_st1
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nfregist_analit  r
        , cfop             c
        , nota_fiscal_dest nfd
    where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_ind_emit     = 0
      and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('00', '06', '08')
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id              = nfd.notafiscal_id
      and nfd.uf             = gv_apur_sigla_estado
      and r.notafiscal_id    = nf.id
      and c.id               = r.cfop_id
      and c.cd in (1410, 1411, 1414, 1415, 1660, 1661, 1662, 2410, 2411, 2414, 2415, 2660, 2661, 2662);
   --
   select sum(nvl(r.vl_icms_st,0)) vl_icms_st
     into vn_vl_icms_st2
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nfregist_analit  r
        , cfop             c
        , nota_fiscal_emit nfe
    where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_ind_emit     = 1
      and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('00', '06', '08')
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id              = nfe.notafiscal_id
      and nfe.uf             = gv_apur_sigla_estado
      and r.notafiscal_id    = nf.id
      and c.id               = r.cfop_id
      and c.cd in (1410, 1411, 1414, 1415, 1660, 1661, 1662, 2410, 2411, 2414, 2415, 2660, 2661, 2662);
   --
   -- Recuperar os valores de FCP do Imposto ICMS do Item da Nota Fiscal
   --
   select sum(nvl(ii.vl_fcp,0))
     into vn_vl_fcp_st1
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nota_fiscal_dest nfd
        , item_nota_fiscal it
        , imp_itemnf       ii
        , tipo_imposto     ti
    where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_ind_emit     = 0
      and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('00', '06', '08')
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id              = nfd.notafiscal_id
      and nfd.uf             = gv_apur_sigla_estado
      and it.notafiscal_id   = nf.id
      and it.cfop           in (1410, 1411, 1414, 1415, 1660, 1661, 1662, 2410, 2411, 2414, 2415, 2660, 2661, 2662)
      and ii.itemnf_id       = it.id
      and ii.dm_tipo         = 0 -- imposto
      and ti.id              = ii.tipoimp_id
      and ti.cd              = 2; -- ICMS-ST
   --
   select sum(nvl(ii.vl_fcp,0))
     into vn_vl_fcp_st2
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nota_fiscal_emit nfe
        , item_nota_fiscal it
        , imp_itemnf       ii
        , tipo_imposto     ti
    where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_ind_emit     = 1
      and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('00', '06', '08')
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id              = nfe.notafiscal_id
      and nfe.uf             = gv_apur_sigla_estado
      and it.notafiscal_id   = nf.id
      and it.cfop           in (1410, 1411, 1414, 1415, 1660, 1661, 1662, 2410, 2411, 2414, 2415, 2660, 2661, 2662)
      and ii.itemnf_id       = it.id
      and ii.dm_tipo         = 0 -- imposto
      and ti.id              = ii.tipoimp_id
      and ti.cd              = 2; -- ICMS-ST
   --
   vn_vl_icms_st := nvl(vn_vl_icms_st1,0) + nvl(vn_vl_icms_st2,0) + nvl(vn_vl_fcp_st1,0) + nvl(vn_vl_fcp_st2,0);
   --
   return vn_vl_icms_st;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_devol_st:' || sqlerrm);
end fkg_soma_devol_st;

-------------------------------------------------------------------------------------------------------
-- Função retorna o Valor total do ICMS ST de ressarcimentos
function fkg_soma_ressarc_st
         return nfregist_analit.vl_icms_st%type
is
   --
   vn_vl_icms_st   nfregist_analit.vl_icms_st%type := 0;
   vn_vl_icms_st1  nfregist_analit.vl_icms_st%type := 0;
   vn_vl_icms_st2  nfregist_analit.vl_icms_st%type := 0;
   vn_vl_fcp_st1   imp_itemnf.vl_fcp%type := 0;
   vn_vl_fcp_st2   imp_itemnf.vl_fcp%type := 0;
   --
begin
   --
   select sum(nvl(r.vl_icms_st,0)) vl_icms_st
     into vn_vl_icms_st1
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nfregist_analit  r
        , cfop             c
        , nota_fiscal_dest nfd
    where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_ind_emit     = 0
      and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('00', '06', '08')
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id              = nfd.notafiscal_id
      and nfd.uf             = gv_apur_sigla_estado
      and r.notafiscal_id    = nf.id
      and c.id               = r.cfop_id
      and c.cd in (1603, 2603);

   select sum(nvl(r.vl_icms_st,0)) vl_icms_st
     into vn_vl_icms_st2
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nfregist_analit  r
        , cfop             c
        , nota_fiscal_emit nfe
    where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_ind_emit     = 1
      and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('00', '06', '08')
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id              = nfe.notafiscal_id
      and nfe.uf             = gv_apur_sigla_estado
      and r.notafiscal_id    = nf.id
      and c.id               = r.cfop_id
      and c.cd in (1603, 2603);
   --
   select sum(nvl(ii.vl_fcp,0))
     into vn_vl_fcp_st1
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nota_fiscal_dest nfd
        , item_nota_fiscal it
        , imp_itemnf       ii
        , tipo_imposto     ti
    where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_ind_emit     = 0
      and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('00', '06', '08')
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id              = nfd.notafiscal_id
      and nfd.uf             = gv_apur_sigla_estado
      and it.notafiscal_id   = nf.id
      and it.cfop           in (1603, 2603)
      and ii.itemnf_id       = it.id
      and ii.dm_tipo         = 0 -- imposto
      and ti.id              = ii.tipoimp_id
      and ti.cd              = 2; -- ICMS-ST
   --
   select sum(nvl(ii.vl_fcp,0))
     into vn_vl_fcp_st2
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nota_fiscal_emit nfe
        , item_nota_fiscal it
        , imp_itemnf       ii
        , tipo_imposto     ti
    where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_ind_emit     = 1
      and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('00', '06', '08')
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id              = nfe.notafiscal_id
      and nfe.uf             = gv_apur_sigla_estado
      and it.notafiscal_id   = nf.id
      and it.cfop           in (1603, 2603)
      and ii.itemnf_id       = it.id
      and ii.dm_tipo         = 0 -- imposto
      and ti.id              = ii.tipoimp_id
      and ti.cd              = 2; -- ICMS-ST
   --
   vn_vl_icms_st := nvl(vn_vl_icms_st1,0) + nvl(vn_vl_icms_st2,0) + nvl(vn_vl_fcp_st1,0) + nvl(vn_vl_fcp_st2,0);
   --
   return vn_vl_icms_st;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_ressarc_st:' || sqlerrm);
end fkg_soma_ressarc_st;

---------------------------------------------------------------------------------------------------------------
-- Função retorna o Valor total de Ajustes "Outros créditos ST" e “Estorno de débitos ST” para o registro C190
function fkg_soma_out_cred_st_c190
         return nfregist_analit.vl_icms_st%type
is
   --
   vn_vl_icms_st   nfregist_analit.vl_icms_st%type := 0;
   vn_vl_icms_st1  nfregist_analit.vl_icms_st%type := 0;
   vn_vl_icms_st2  nfregist_analit.vl_icms_st%type := 0;
   vn_vl_fcp_st1   imp_itemnf.vl_fcp%type := 0;
   vn_vl_fcp_st2   imp_itemnf.vl_fcp%type := 0;
   --
begin
   --
   select sum(nvl(r.vl_icms_st,0)) vl_icms_st
     into vn_vl_icms_st1
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nfregist_analit  r
        , cfop             c
        , nota_fiscal_dest nfd
    where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_ind_emit     = 0
      and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('00', '06', '08')
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id              = nfd.notafiscal_id
      and nfd.uf             = gv_apur_sigla_estado
      and r.notafiscal_id    = nf.id
      and c.id               = r.cfop_id
      and substr(c.cd,1,1)  in ('1', '2')
      and c.cd not in (1410, 1411, 1414, 1415, 1660, 1661, 1662, 2410, 2411, 2414, 2415, 2660, 2661, 2662);

   select sum(nvl(r.vl_icms_st,0)) vl_icms_st
     into vn_vl_icms_st2
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nfregist_analit  r
        , cfop             c
        , nota_fiscal_emit nfe
    where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_ind_emit     = 1
      and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('00', '06', '08')
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id              = nfe.notafiscal_id
      and nfe.uf             = gv_apur_sigla_estado
      and r.notafiscal_id    = nf.id
      and c.id               = r.cfop_id
      and substr(c.cd,1,1)  in ('1', '2')
      and c.cd not in (1410, 1411, 1414, 1415, 1660, 1661, 1662, 2410, 2411, 2414, 2415, 2660, 2661, 2662);
   --
   select sum(nvl(ii.vl_fcp,0))
     into vn_vl_fcp_st1
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nota_fiscal_dest nfd
        , item_nota_fiscal it
        , imp_itemnf       ii
        , tipo_imposto     ti
    where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_ind_emit     = 0
      and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('00', '06', '08')
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id              = nfd.notafiscal_id
      and nfd.uf             = gv_apur_sigla_estado
      and it.notafiscal_id   = nf.id
      and substr(it.cfop,1,1) in ('1', '2')
      and it.cfop not in (1410, 1411, 1414, 1415, 1660, 1661, 1662, 2410, 2411, 2414, 2415, 2660, 2661, 2662)
      and ii.itemnf_id       = it.id
      and ii.dm_tipo         = 0 -- imposto
      and ti.id              = ii.tipoimp_id
      and ti.cd              = 2; -- ICMS-ST
   --
   select sum(nvl(ii.vl_fcp,0))
     into vn_vl_fcp_st1
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nota_fiscal_emit nfe
        , item_nota_fiscal it
        , imp_itemnf       ii
        , tipo_imposto     ti
    where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_ind_emit     = 1
      and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('00', '06', '08')
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id              = nfe.notafiscal_id
      and nfe.uf             = gv_apur_sigla_estado
      and it.notafiscal_id   = nf.id
      and substr(it.cfop,1,1) in ('1', '2')
      and it.cfop not in (1410, 1411, 1414, 1415, 1660, 1661, 1662, 2410, 2411, 2414, 2415, 2660, 2661, 2662)
      and ii.itemnf_id       = it.id
      and ii.dm_tipo         = 0 -- imposto
      and ti.id              = ii.tipoimp_id
      and ti.cd              = 2; -- ICMS-ST
   --
   vn_vl_icms_st := nvl(vn_vl_icms_st1,0) + nvl(vn_vl_icms_st2,0) + nvl(vn_vl_fcp_st1,0) + nvl(vn_vl_fcp_st2,0);
   --
   return vn_vl_icms_st;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_out_cred_st_c190:' || sqlerrm);
end fkg_soma_out_cred_st_c190;

----------------------------------------------------------------------------------------------------------------------------------------
-- Função retorna o Valor total de Ajustes "Outros créditos ST" e “Estorno de débitos ST” para o registro E220 (Lançamento nos ajustes).
function fkg_soma_out_cred_st_e220
         return ajust_apuracao_icms_st.vl_aj_apur%type
is
   --
   vn_vl_aj_apur ajust_apuracao_icms_st.vl_aj_apur%type := 0;
   --
begin
   --
   select sum(aaist.vl_aj_apur) vl_aj_apur
     into vn_vl_aj_apur
     from ajust_apuracao_icms_st  aaist
        , cod_aj_saldo_apur_icms  cod
    where aaist.apuracaoicmsst_id = gt_row_apuracao_icms_st.id
      and cod.id                  = aaist.codajsaldoapuricms_id
      and cod.dm_apur            in (1) -- icms-st
      and cod.dm_util            in (2,3); -- "2-outros créditou" ou "3-estorno débitos"
   --
   return vn_vl_aj_apur;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_out_cred_st_e220:' || sqlerrm);
end fkg_soma_out_cred_st_e220;

--------------------------------------------------------------------------------------------------------------
-- Função retorna o Valor total dos ajustes a crédito de ICMS ST, provenientes de ajustes do documento fiscal
function fkg_soma_aj_creditos_st 
  return inf_prov_docto_fiscal.vl_icms%type is
  --
  vn_vl_icms  inf_prov_docto_fiscal.vl_icms%type := 0;
  vn_vl_icms1 inf_prov_docto_fiscal.vl_icms%type := 0;
  vn_vl_icms2 inf_prov_docto_fiscal.vl_icms%type := 0;
  --
begin
  --
  select sum(nvl(ipdf.vl_icms, 0)) vl_icms
    into vn_vl_icms1
    from nota_fiscal           nf,
         sit_docto             sd,
         mod_fiscal            mf,
         nfinfor_fiscal        nfif,
         inf_prov_docto_fiscal ipdf,
         cod_ocor_aj_icms      cod,
         nota_fiscal_dest      nfd
   where nf.empresa_id       = gt_row_per_apur_icms_st.empresa_id
     and nf.dm_st_proc       = 4 -- Autorizada
     and nf.dm_arm_nfe_terc  = 0 -- Não é nota de armazenamento fiscal
     and nf.dm_ind_emit      = 0 -- Emissão Própria
     and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)) 
           or
          (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)) 
           or
          (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
     and sd.id               = nf.sitdocto_id
     and sd.cd               not in ('02', '03') -- Nada cancelado
     and mf.id               = nf.modfiscal_id
     and mf.cod_mod          in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
     and nf.id               = nfd.notafiscal_id
     and nfd.uf              = gv_apur_sigla_estado
     and nfif.notafiscal_id  = nf.id
     and ipdf.nfinforfisc_id = nfif.id
     and cod.id              = ipdf.codocorajicms_id
     and cod.dm_reflexo_apur in (0, 1, 2)
     and cod.dm_tipo_apur    in (1); -- ICMS-ST 

  select sum(nvl(ipdf.vl_icms, 0)) vl_icms
    into vn_vl_icms2
    from nota_fiscal           nf,
         sit_docto             sd,
         mod_fiscal            mf,
         nfinfor_fiscal        nfif, 
         inf_prov_docto_fiscal ipdf,
         cod_ocor_aj_icms      cod,
         nota_fiscal_emit      nfe
   where nf.empresa_id       = gt_row_per_apur_icms_st.empresa_id
     and nf.dm_st_proc       = 4 -- Autorizada
     and nf.dm_arm_nfe_terc  = 0 -- Não é nota de armazenamento fiscal
     and nf.dm_ind_emit      = 1 -- Terceiros
     and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
     and sd.id               = nf.sitdocto_id
     and sd.cd               not in ('02', '03') -- Nada cancelado
     and mf.id               = nf.modfiscal_id
     and mf.cod_mod          in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
     and nf.id               = nfe.notafiscal_id
     and nfe.uf              = gv_apur_sigla_estado
     and nfif.notafiscal_id  = nf.id
     and ipdf.nfinforfisc_id = nfif.id
     and cod.id              = ipdf.codocorajicms_id
     and cod.dm_reflexo_apur in (0, 1, 2)
     and cod.dm_tipo_apur    in (1); -- ICMS-ST
  --
  vn_vl_icms := nvl(vn_vl_icms1, 0) + nvl(vn_vl_icms2, 0);
  --
  return vn_vl_icms;
  --
exception
  when no_data_found then
    return 0;
  when others then
    raise_application_error(-20101, 'Erro na fkg_soma_aj_creditos_st:' || sqlerrm);
end fkg_soma_aj_creditos_st;

-------------------------------------------------------------------------------------------------------
-- Função retorna o Valor Total do ICMS retido por Substituição Tributária p/ reg. C190
-- Antigo nome do cursor era: c_soma_retencao_st_c190_cd590
function fkg_soma_ret_st_c190_cd590
         return nfregist_analit.vl_icms_st%type
is
   --
   vn_vl_icms_st nfregist_analit.vl_icms_st%type := 0;
   vn_vl_fcp_st  imp_itemnf.vl_fcp%type := 0;
   --
begin
   --
   select sum(r.vl_icms_st) vl_icms_st
     into vn_vl_icms_st
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nfregist_analit  r
        , cfop             c
        , nota_fiscal_dest nfd
    where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
      and sd.id              = nf.sitdocto_id
      and sd.cd         not in ('02', '03') -- nada de cancelado
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nfd.notafiscal_id  = nf.id
      and nfd.uf             = gv_apur_sigla_estado
      and r.notafiscal_id    = nf.id
      and c.id               = r.cfop_id
      and substr(c.cd,1,1)  in ('5', '6');
   --
   select sum(nvl(ii.vl_fcp,0))
     into vn_vl_fcp_st
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nota_fiscal_dest nfd
        , item_nota_fiscal it
        , imp_itemnf       ii
        , tipo_imposto     ti
    where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
      and sd.id              = nf.sitdocto_id
      and sd.cd         not in ('02', '03') -- nada de cancelado
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nfd.notafiscal_id  = nf.id
      and nfd.uf             = gv_apur_sigla_estado
      and it.notafiscal_id   = nf.id
      and substr(it.cfop,1,1) in ('5', '6')
      and ii.itemnf_id       = it.id
      and ii.dm_tipo         = 0 -- imposto
      and ti.id              = ii.tipoimp_id
      and ti.cd              = 2; -- ICMS-ST
   --
   return (nvl(vn_vl_icms_st,0) + nvl(vn_vl_fcp_st,0));
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_ret_st_c190_cd590:' || sqlerrm);
end fkg_soma_ret_st_c190_cd590;

-------------------------------------------------------------------------------------------------------
-- Função retorna o Valor Total do ICMS retido por Substituição Tributária p/ reg. C690
function fkg_soma_retencao_st_c690
         return reg_anal_cons_nota_fiscal.vl_icms_st%type
is
   --
   vn_vl_icms_st reg_anal_cons_nota_fiscal.vl_icms_st%type := 0;
   --
begin
   --
   select sum(r.vl_icms_st) vl_icms_st
     into vn_vl_icms_st
     from cons_nota_fiscal           cnf
        , cidade                     cid
        , reg_anal_cons_nota_fiscal  r
        , cfop                       c
    where cnf.empresa_id          = gt_row_per_apur_icms_st.empresa_id
      and trunc(cnf.dt_doc) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
      and cid.id                  = cnf.cidade_id
      and cid.estado_id           = gt_row_apuracao_icms_st.estado_id
      and r.consnotafiscal_id     = cnf.id
      and c.id                    = r.cfop_id
      and substr(c.cd, 1, 1)     in ('5', '6');
   --
   return vn_vl_icms_st;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_retencao_st_c690:' || sqlerrm);
end fkg_soma_retencao_st_c690;

-------------------------------------------------------------------------------------------------------
-- Função retorna o Valor Total do ICMS retido por Substituição Tributária p/ reg. C791
function fkg_soma_retencao_st_c791
         return inf_consnfviaun_icmsst_uf.vl_icms_st%type
is
   --
   vn_vl_icms_st inf_consnfviaun_icmsst_uf.vl_icms_st%type := 0;
   --
begin
   --
   select sum(i.vl_icms_st) vl_icms_st
     into vn_vl_icms_st
     from cons_nf_via_unica           cnf
        , reg_anal_cons_nf_via_unica  r
        , cfop                        c
        , inf_consnfviaun_icmsst_uf   i
    where cnf.empresa_id             = gt_row_per_apur_icms_st.empresa_id
      and ( trunc(cnf.dt_doc_ini)   >= trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(cnf.dt_doc_fin) <= trunc(gt_row_per_apur_icms_st.dt_fim) )
      and r.consnfviaunica_id        = cnf.id
      and c.id                       = r.cfop_id
      and substr(c.cd, 1, 1)        in ('5', '6')
      and i.reganalconsnfviaunica_id = r.id
      and i.estado_id                = gt_row_apuracao_icms_st.estado_id;
   --
   return vn_vl_icms_st;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_retencao_st_c791:' || sqlerrm);
end fkg_soma_retencao_st_c791;

-------------------------------------------------------------------------------------------------------
-- Função retorna o Valor Total do ICMS retido por Substituição Tributária p/ reg. D690
function fkg_soma_retencao_st_d690
         return reg_an_cons_prest_serv.vl_icms_st%type
is
   --
   vn_vl_icms_st reg_an_cons_prest_serv.vl_icms_st%type := 0;
   --
begin
   --
   select sum(r.vl_icms_st) vl_icms_st
     into vn_vl_icms_st
     from cons_prest_serv         cps
        , cidade                  cid
        , reg_an_cons_prest_serv  r
        , cfop                    c
    where cps.empresa_id          = gt_row_per_apur_icms_st.empresa_id
      and trunc(cps.dt_doc) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
      and cid.ibge_cidade         = cps.cod_mun_ibge
      and cid.estado_id           = gt_row_apuracao_icms_st.estado_id
      and r.consprestserv_id      = cps.id
      and c.id                    = r.cfop_id
      and substr(c.cd, 1, 1)     in ('5', '6');
   --
   return vn_vl_icms_st;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_retencao_st_d690:' || sqlerrm);
end fkg_soma_retencao_st_d690;

-------------------------------------------------------------------------------------------------------
-- Função retorna o Valor Total do ICMS retido por Substituição Tributária p/ reg. D697
function fkg_soma_retencao_st_d697
         return reg_an_cons_prest_serv.vl_icms_st%type
is
   --
   vn_vl_icms_st reg_an_cons_prest_serv.vl_icms_st%type := 0;
   --
begin
   --
   select sum(i.vl_icms_st) vl_icms_st
     into vn_vl_icms_st
     from cons_nf_prest_serv         cnfps
        , reg_an_cons_nf_prest_serv  r
        , cfop                       c
        , reg_an_cons_nf_ps_st_uf    i
    where cnfps.empresa_id           = gt_row_per_apur_icms_st.empresa_id
      and ( trunc(cnfps.dt_doc_ini) >= trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(cnfps.dt_doc_fin) <= trunc(gt_row_per_apur_icms_st.dt_fim) )
      and r.consnfprestserv_id       = cnfps.id
      and c.id                       = r.cfop_id
      and substr(c.cd, 1, 1)        in ('5', '6')
      and i.reganconsnfprestserv_id  = r.id
      and i.estado_id                = gt_row_apuracao_icms_st.estado_id;
   --
   return vn_vl_icms_st;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_retencao_st_d697:' || sqlerrm);
end fkg_soma_retencao_st_d697;

------------------------------------------------------------------------------------------------------------------------------------------
-- Função retorna o Valor Total dos ajustes "Outros débitos ST" " e “Estorno de créditos ST” para os lançamentos realizados no bloco E220
function fkg_soma_out_deb_st
         return ajust_apuracao_icms_st.vl_aj_apur%type
is
   --
   vn_vl_aj_apur ajust_apuracao_icms_st.vl_aj_apur%type := 0;
   --
begin
   --
   select sum(aaist.vl_aj_apur) vl_aj_apur
     into vn_vl_aj_apur
     from ajust_apuracao_icms_st  aaist
        , cod_aj_saldo_apur_icms  cod
    where aaist.apuracaoicmsst_id = gt_row_apuracao_icms_st.id
      and cod.id                  = aaist.codajsaldoapuricms_id
      and cod.dm_apur            in (1) -- icms-st
      and cod.dm_util            in (0,1); -- "0-outros débitos" ou "1-estorno créditos"
   --
   return vn_vl_aj_apur;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_out_deb_st:' || sqlerrm);
end fkg_soma_out_deb_st;

--------------------------------------------------------------------------------------------------------------
-- Função retorna o Valor total dos ajustes a débito de ICMS ST, provenientes de ajustes do documento fiscal.
function fkg_soma_aj_debitos_st
         return inf_prov_docto_fiscal.vl_icms%type
is
   --
   vn_vl_icms   inf_prov_docto_fiscal.vl_icms%type := 0;
   vn_vl_icms1  inf_prov_docto_fiscal.vl_icms%type := 0;
   vn_vl_icms2  inf_prov_docto_fiscal.vl_icms%type := 0;
   --
begin
   --
   select sum(nvl(ipdf.vl_icms,0)) vl_icms
     into vn_vl_icms1
     from nota_fiscal            nf
        , sit_docto              sd
        , mod_fiscal             mf
        , nfinfor_fiscal         nfif
        , inf_prov_docto_fiscal  ipdf
        , cod_ocor_aj_icms       cod
        , nota_fiscal_dest       nfd
    where nf.empresa_id        = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_st_proc        = 4
      and nf.dm_arm_nfe_terc   = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_ind_emit       = 0
      and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
      and sd.id                = nf.sitdocto_id
      and sd.cd           not in ('02', '03', '01', '07') -- nada de cancelado, documentos extemporâneos e complementares extemporâneas
      and mf.id                = nf.modfiscal_id
      and mf.cod_mod          in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id                = nfd.notafiscal_id
      and nfd.uf               = gv_apur_sigla_estado
      and nfif.notafiscal_id   = nf.id
      and ipdf.nfinforfisc_id  = nfif.id
      and cod.id               = ipdf.codocorajicms_id
      and cod.dm_reflexo_apur in (3, 4, 5)
      and cod.dm_tipo_apur    in (1); -- icms-st

   select sum(nvl(ipdf.vl_icms,0)) vl_icms
     into vn_vl_icms2
     from nota_fiscal            nf
        , sit_docto              sd
        , mod_fiscal             mf
        , nfinfor_fiscal         nfif
        , inf_prov_docto_fiscal  ipdf
        , cod_ocor_aj_icms       cod
        , nota_fiscal_emit       nfe
    where nf.empresa_id        = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_st_proc        = 4
      and nf.dm_arm_nfe_terc   = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_ind_emit       = 1
      and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
      and sd.id                = nf.sitdocto_id
      and sd.cd           not in ('02', '03', '01', '07') -- nada de cancelado, documentos extemporâneos e complementares extemporâneas
      and mf.id                = nf.modfiscal_id
      and mf.cod_mod          in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id                = nfe.notafiscal_id
      and nfe.uf               = gv_apur_sigla_estado
      and nfif.notafiscal_id   = nf.id
      and ipdf.nfinforfisc_id  = nfif.id
      and cod.id               = ipdf.codocorajicms_id
      and cod.dm_reflexo_apur in (3, 4, 5)
      and cod.dm_tipo_apur    in (1); -- icms-st
   --
   vn_vl_icms := nvl(vn_vl_icms1,0) + nvl(vn_vl_icms2,0);
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_aj_debitos_st:' || sqlerrm);
end fkg_soma_aj_debitos_st;

-------------------------------------------------------------------------------------------------------
-- Função retorna o Valor total dos ajustes "Deduções ST", proveninentes de lançamentos no E220
function fkg_soma_deducoes_st_e220
         return ajust_apuracao_icms_st.vl_aj_apur%type
is
   --
   vn_vl_aj_apur ajust_apuracao_icms_st.vl_aj_apur%type := 0;
   --
begin
   --
   select sum(aaist.vl_aj_apur) vl_aj_apur
     into vn_vl_aj_apur
     from ajust_apuracao_icms_st  aaist
        , cod_aj_saldo_apur_icms  cod
    where aaist.apuracaoicmsst_id = gt_row_apuracao_icms_st.id
      and cod.id                  = aaist.codajsaldoapuricms_id
      and cod.dm_apur            in (1) -- icms-st
      and cod.dm_util            in (4); -- 4-Deduções de Imposto Apurado
   --
   return vn_vl_aj_apur;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_deducoes_st_e220:' || sqlerrm);
end fkg_soma_deducoes_st_e220;

-------------------------------------------------------------------------------------------------------
-- Função retorna o Valor total dos ajustes "Deduções ST" para o registro C197
function fkg_soma_deducoes_st_c197
         return inf_prov_docto_fiscal.vl_icms%type
is
   --
   vn_vl_icms   inf_prov_docto_fiscal.vl_icms%type := 0;
   vn_vl_icms1  inf_prov_docto_fiscal.vl_icms%type := 0;
   vn_vl_icms2  inf_prov_docto_fiscal.vl_icms%type := 0;
   --
begin
   --
   select sum(ipdf.vl_icms) vl_icms
     into vn_vl_icms1
     from nota_fiscal            nf
        , sit_docto              sd
        , mod_fiscal             mf
        , nfinfor_fiscal         nfif
        , inf_prov_docto_fiscal  ipdf
        , cod_ocor_aj_icms       cod
        , nota_fiscal_dest       nfd
    where nf.empresa_id        = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_st_proc        = 4
      and nf.dm_arm_nfe_terc   = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_ind_emit       = 0
      and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
      and sd.id                = nf.sitdocto_id
      and sd.cd           not in ('02', '03') -- nada de cancelado
      and mf.id                = nf.modfiscal_id
      and mf.cod_mod          in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id                = nfd.notafiscal_id
      and nfd.uf               = gv_apur_sigla_estado
      and nfif.notafiscal_id   = nf.id
      and ipdf.nfinforfisc_id  = nfif.id
      and cod.id               = ipdf.codocorajicms_id
      and cod.dm_reflexo_apur in (6) -- Dedução
      and cod.dm_tipo_apur    in (1); -- icms-st

   select sum(ipdf.vl_icms) vl_icms
     into vn_vl_icms2
     from nota_fiscal            nf
        , sit_docto              sd
        , mod_fiscal             mf
        , nfinfor_fiscal         nfif
        , inf_prov_docto_fiscal  ipdf
        , cod_ocor_aj_icms       cod
        , nota_fiscal_emit       nfe
    where nf.empresa_id        = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_st_proc        = 4
      and nf.dm_arm_nfe_terc   = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_ind_emit       = 1
      and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
      and sd.id                = nf.sitdocto_id
      and sd.cd           not in ('02', '03') -- nada de cancelado
      and mf.id                = nf.modfiscal_id
      and mf.cod_mod          in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id                = nfe.notafiscal_id
      and nfe.uf               = gv_apur_sigla_estado
      and nfif.notafiscal_id   = nf.id
      and ipdf.nfinforfisc_id  = nfif.id
      and cod.id               = ipdf.codocorajicms_id
      and cod.dm_reflexo_apur in (6) -- Dedução
      and cod.dm_tipo_apur    in (1);-- icms-st
   --
   vn_vl_icms := nvl(vn_vl_icms1,0) + nvl(vn_vl_icms2,0);
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_deducoes_st_c197:' || sqlerrm);
end fkg_soma_deducoes_st_c197;

------------------------------------------------------------------------------------------------------------
-- Função retorna os Valores recolhidos ou a recolher, extraapuração" nos documentos fiscais extemporaneos.
function fkg_soma_deb_esp_st
         return nfregist_analit.vl_icms_st%type
is
   --
   vn_vl_icms_st   nfregist_analit.vl_icms_st%type := 0;
   vn_vl_icms_st1  nfregist_analit.vl_icms_st%type := 0;
   vn_vl_icms_st2  nfregist_analit.vl_icms_st%type := 0;
   vn_vl_fcp_st1   imp_itemnf.vl_fcp%type := 0;
   vn_vl_fcp_st2   imp_itemnf.vl_fcp%type := 0;
   --
begin
   --
   select sum(r.vl_icms_st) vl_icms_st
     into vn_vl_icms_st1
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nfregist_analit  r
        , nota_fiscal_dest nfd
    where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_ind_emit     = 0
      and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('01', '07')
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id              = nfd.notafiscal_id
      and nfd.uf             = gv_apur_sigla_estado
      and r.notafiscal_id    = nf.id;

   select sum(r.vl_icms_st) vl_icms_st
     into vn_vl_icms_st2
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nfregist_analit  r
        , nota_fiscal_emit nfe
    where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_ind_emit     = 1
      and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('01', '07')
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id              = nfe.notafiscal_id
      and nfe.uf             = gv_apur_sigla_estado
      and r.notafiscal_id    = nf.id;
   --
   select sum(nvl(ii.vl_fcp,0))
     into vn_vl_fcp_st1
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nota_fiscal_dest nfd
        , item_nota_fiscal it
        , imp_itemnf       ii
        , tipo_imposto     ti
    where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_ind_emit     = 0
      and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('01', '07')
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id              = nfd.notafiscal_id
      and nfd.uf             = gv_apur_sigla_estado
      and it.notafiscal_id   = nf.id
      and ii.itemnf_id       = it.id
      and ii.dm_tipo         = 0 -- imposto
      and ti.id              = ii.tipoimp_id
      and ti.cd              = 2; -- ICMS-ST
   --
   select sum(nvl(ii.vl_fcp,0))
     into vn_vl_fcp_st2
     from nota_fiscal      nf
        , sit_docto        sd
        , mod_fiscal       mf
        , nota_fiscal_emit nfe
        , item_nota_fiscal it
        , imp_itemnf       ii
        , tipo_imposto     ti
    where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_st_proc      = 4
      and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_ind_emit     = 1
      and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
      and sd.id              = nf.sitdocto_id
      and sd.cd             in ('01', '07')
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id              = nfe.notafiscal_id
      and nfe.uf             = gv_apur_sigla_estado
      and it.notafiscal_id   = nf.id
      and ii.itemnf_id       = it.id
      and ii.dm_tipo         = 0 -- imposto
      and ti.id              = ii.tipoimp_id
      and ti.cd              = 2; -- ICMS-ST
   --
   vn_vl_icms_st := nvl(vn_vl_icms_st1,0) + nvl(vn_vl_icms_st2,0) + nvl(vn_vl_fcp_st1,0) + nvl(vn_vl_fcp_st2,0);
   --
   return vn_vl_icms_st;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_deb_esp_st:' || sqlerrm);
end fkg_soma_deb_esp_st;

-------------------------------------------------------------------------------------------------------
-- Função retorna os Valores recolhidos ou a recolher, extraapuração" para o registro C197
function fkg_soma_deb_esp_st_197
         return inf_prov_docto_fiscal.vl_icms%type
is
   --
   vn_vl_icms   inf_prov_docto_fiscal.vl_icms%type := 0;
   vn_vl_icms1  inf_prov_docto_fiscal.vl_icms%type := 0;
   vn_vl_icms2  inf_prov_docto_fiscal.vl_icms%type := 0;
   vn_vl_icms3  inf_prov_docto_fiscal.vl_icms%type := 0;
   --
begin
   --
   select sum(nvl(ipdf.vl_icms,0)) vl_icms
     into vn_vl_icms1
     from nota_fiscal            nf
        , sit_docto              sd
        , mod_fiscal             mf
        , nfinfor_fiscal         nfif
        , inf_prov_docto_fiscal  ipdf
        , cod_ocor_aj_icms       cod
        , nota_fiscal_dest       nfd
    where nf.empresa_id        = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_st_proc        = 4
      and nf.dm_arm_nfe_terc   = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_ind_emit       = 0
      and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
      and sd.id                = nf.sitdocto_id
      and sd.cd           not in ('02', '03') -- nada de cancelado
      and mf.id                = nf.modfiscal_id
      and mf.cod_mod          in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id                = nfd.notafiscal_id
      and nfd.uf               = gv_apur_sigla_estado
      and nfif.notafiscal_id   = nf.id
      and ipdf.nfinforfisc_id  = nfif.id
      and cod.id               = ipdf.codocorajicms_id
      and cod.dm_reflexo_apur in (7)  -- Débitos Especiais
      and cod.dm_tipo_apur    in (1);  -- icms-st

   select sum(nvl(ipdf.vl_icms,0)) vl_icms
     into vn_vl_icms2
     from nota_fiscal            nf
        , sit_docto              sd
        , mod_fiscal             mf
        , nfinfor_fiscal         nfif
        , inf_prov_docto_fiscal  ipdf
        , cod_ocor_aj_icms       cod
        , nota_fiscal_dest       nfd
    where nf.empresa_id        = gt_row_per_apur_icms_st.empresa_id
      and nf.dm_st_proc        = 4
      and nf.dm_arm_nfe_terc   = 0 -- Não é nota de armazenamento fiscal
      and nf.dm_ind_emit       = 1
      and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
      and sd.id                = nf.sitdocto_id
      and sd.cd           not in ('02', '03') -- nada de cancelado
      and mf.id                = nf.modfiscal_id
      and mf.cod_mod          in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
      and nf.id                = nfd.notafiscal_id
      and nfd.uf               = gv_apur_sigla_estado
      and nfif.notafiscal_id   = nf.id
      and ipdf.nfinforfisc_id  = nfif.id
      and cod.id               = ipdf.codocorajicms_id
      and cod.dm_reflexo_apur in (7)   -- Débitos Especiais
      and cod.dm_tipo_apur    in (1); -- icms-st
   --
   select sum(nvl(ci.vl_icms,0)) vl_icms
     into vn_vl_icms3
     from conhec_transp    ct
        , sit_docto        sd
        , ct_reg_anal      cr
        , ctinfor_fiscal   cf
        , ct_inf_prov      ci
        , cod_ocor_aj_icms co
    where ct.empresa_id       = gt_row_per_apur_icms_st.empresa_id
      and ct.dm_st_proc       = 4 -- Autorizado
      and ct.dm_arm_cte_terc  = 0
      and ((ct.dm_ind_emit = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 1 and trunc(ct.dt_hr_emissao) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(ct.dt_hr_emissao) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
            or
           (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(ct.dt_sai_ent,ct.dt_hr_emissao)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
      and sd.id               = ct.sitdocto_id
      and sd.cd          not in ('01', '07') -- extemporâneos
      and cr.conhectransp_id  = ct.id
      and cf.conhectransp_id  = ct.id
      and ci.ctinforfiscal_id = cf.id
	  and ct.sigla_uf_ini     = gv_apur_sigla_estado   -- #74943
      and co.id               = ci.codocorajicms_id
      and co.dm_reflexo_apur  = '7' -- corresponde ao 3º dígito do código: substr(cod.cod_aj,3,1) = 7-Débitos especiais
      and co.dm_tipo_apur    in ('1'); -- corresponde ao 4º dígito do código: substr(cod.cod_aj,4,1) in 3-Apuração 1, 4-Apuração 2, 5–Apuração 3
   --
   --
   vn_vl_icms := nvl(vn_vl_icms1,0) + nvl(vn_vl_icms2,0) + nvl(vn_vl_icms3,0);
   --
   return vn_vl_icms;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_deb_esp_st_197:' || sqlerrm);
end fkg_soma_deb_esp_st_197;

----------------------------------------------------------------------------------------------------------
-- Função retorna os Valores recolhidos ou a recolher, extraapuração provenientes dos lançamentos no E220
function fkg_soma_deb_esp_st_e220
         return ajust_apuracao_icms_st.vl_aj_apur%type
is
   --
   vn_vl_aj_apur ajust_apuracao_icms_st.vl_aj_apur%type := 0;
   --
begin
   --
   select sum(aaist.vl_aj_apur) vl_aj_apur
     into vn_vl_aj_apur
     from ajust_apuracao_icms_st  aaist
        , cod_aj_saldo_apur_icms  cod
    where aaist.apuracaoicmsst_id = gt_row_apuracao_icms_st.id
      and cod.id                  = aaist.codajsaldoapuricms_id
      and cod.dm_apur            in (1)  -- icms-st
      and cod.dm_util            in (5); -- 5-Débito Especial
   --
   return vn_vl_aj_apur;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_deb_esp_st_e220:' || sqlerrm);
end fkg_soma_deb_esp_st_e220;

-------------------------------------------------------------------------------------------------------
-- Procedimento limpa os caracteres especiais dos campos de descrição do Bloco E
procedure pkb_limpa_caracteres_bloco_e ( en_apuracaoicmsst_id  in apuracao_icms_st.id%TYPE )
is
   --
   vn_fase number := 0;
   --
begin
   --
   vn_fase := 1;
   -- Se informou o id da Apuração de ICMS-ST
   if nvl(en_apuracaoicmsst_id,0) > 0 then
      --
      vn_fase := 2;
      -- No registro E220
      update ajust_apuracao_icms_st s
         set s.descr_compl_aj = trim(pk_csf.fkg_converte(s.descr_compl_aj))
       where s.apuracaoicmsst_id = en_apuracaoicmsst_id;
      --
      vn_fase := 3;
      -- No registro E230
      update infor_ajust_apur_icms_st c
         set c.descr_proc = trim(pk_csf.fkg_converte(c.descr_proc))
           , c.txt_compl = trim(pk_csf.fkg_converte(c.txt_compl))
       where c.id in (select distinct b.id
                        from ajust_apuracao_icms_st a
                           , infor_ajust_apur_icms_st b
                       where a.apuracaoicmsst_id = en_apuracaoicmsst_id
                         and a.id = b.ajustapuracaoicmsst_id);
      --
      vn_fase := 4;
      -- No registro E250
      update obrig_rec_apur_icms_st m
         set m.descr_proc = trim(pk_csf.fkg_converte(m.descr_proc))
           , m.txt_compl  = trim(pk_csf.fkg_converte(m.txt_compl))
       where m.apuracaoicmsst_id = en_apuracaoicmsst_id;
      --
      vn_fase := 5;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      gv_resumo_log := 'Erro na pkb_limpa_caracteres_bloco_e fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_limpa_caracteres_bloco_e;

-------------------------------------------------------------------------------------------------------
-- Procedimento recupera os dados da Apuração de ICMS-ST
procedure pkb_dados_per_apur_icms_st ( en_perapuricmsst_id in per_apur_icms_st.id%type )
is
begin
   --
   if nvl(en_perapuricmsst_id,0) > 0 then
      --
      select *
        into gt_row_per_apur_icms_st
 	from per_apur_icms_st
       where id = en_perapuricmsst_id;
      --
   end if;
   --
end pkb_dados_per_apur_icms_st;

-------------------------------------------------------------------------------------------------------
-- Procedure recupera os dados da apuração de imposto de ICMS-ST
procedure pkb_dados_apuracao_icms_st ( en_apuracaoicmsst_id in apuracao_icms_st.id%type )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  Log_Generico.id%TYPE;
   --
   cursor c_apuracao_icms_st is
      select * from apuracao_icms_st
       where id = en_apuracaoicmsst_id;
   --
begin
   --
   vn_fase := 1;
   --
   gt_row_apuracao_icms_st := null;
   --
   if nvl(en_apuracaoicmsst_id,0) > 0 then
      --
      vn_fase := 2;
      --
      open c_apuracao_icms_st;
      fetch c_apuracao_icms_st into gt_row_apuracao_icms_st;
      close c_apuracao_icms_st;
      --
      vn_fase := 3;
      --
      if nvl(gt_row_apuracao_icms_st.id,0) > 0 then
         --
         vn_fase := 4;
         -- Sigla do estado da apuração
         gv_apur_sigla_estado := pk_csf.fkg_Estado_id_sigla(gt_row_apuracao_icms_st.estado_id);
         --
         vn_fase := 5;
         -- recupera os dados do período para utilizar no processo
         pkb_dados_per_apur_icms_st ( en_perapuricmsst_id => gt_row_apuracao_icms_st.perapuricmsst_id );
         --
         vn_fase := 6;
         --
         gn_dm_dt_escr_dfepoe := pk_csf.fkg_dmdtescrdfepoe_empresa( en_empresa_id => gt_row_per_apur_icms_st.empresa_id );
         --
         vn_fase := 7;
         --
         gn_referencia_id  := gt_row_apuracao_icms_st.id;
         gv_obj_referencia := 'APURACAO_ICMS_ST';
         -- Monta mensagem para o log da Apuração de ICMS-ST
         if nvl(gn_dm_dt_escr_dfepoe,0) = 0 then -- 0-data de emissão
            --
            gv_mensagem_log := 'Apuração de ICMS-ST com Data Inicial '||to_char(gt_row_per_apur_icms_st.dt_inicio, 'dd/mm/rrrr')||' até Data Final '||
                               to_char(gt_row_per_apur_icms_st.dt_fim, 'dd/mm/rrrr')||'. Data que será considerada para recuperar os documentos fiscais de '||
                               'emissão própria com operação de entrada: Data de emissão.';
            --
         else -- nvl(gn_dm_dt_escr_dfepoe,0) = 1 -- 1-data de entrada/saída
            --
            gv_mensagem_log := 'Apuração de ICMS-ST com Data Inicial '||to_char(gt_row_per_apur_icms_st.dt_inicio, 'dd/mm/rrrr')||' até Data Final '||
                               to_char(gt_row_per_apur_icms_st.dt_fim, 'dd/mm/rrrr')||'. Data que será considerada para recuperar os documentos fiscais de '||
                               'emissão própria com operação de entrada: Data da entrada/saída.';
            --
         end if;
         --
      else
         --
         vn_fase := 8;
         --
         gn_referencia_id := null;
         gv_obj_referencia := null;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms_st.pkb_dados_apuracao_icms_st fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => null
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => null
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_dados_apuracao_icms_st;

-------------------------------------------------------------------------------------------------------
-- Valida os dados a Apuração de ICMS-ST
procedure pkb_validar_dados ( est_log_generico in out nocopy  dbms_sql.number_table )
is
   --
   vn_fase                    number := 0;
   vn_loggenerico_id          log_generico.id%type;
   vn_vl_devol_st             apuracao_icms_st.vl_devol_st%type             := 0;
   vn_vl_ressarc_st           apuracao_icms_st.vl_ressarc_st%type           := 0;
   vn_vl_outro_cred_st        apuracao_icms_st.vl_outro_cred_st%type        := 0;
   vn_vl_aj_credito_st        apuracao_icms_st.vl_aj_credito_st%type        := 0;
   vn_vl_retencao_st          apuracao_icms_st.vl_retencao_st%type          := 0;
   vn_vl_out_deb_st           apuracao_icms_st.vl_out_deb_st %type          := 0;
   vn_vl_ajust_deb_st         apuracao_icms_st.vl_ajust_deb_st%type         := 0;
   vn_vl_saldo_dev_ant_st     apuracao_icms_st.vl_saldo_dev_ant_st%type     := 0;
   vn_vl_deducao_st           apuracao_icms_st.vl_deducao_st%type           := 0;
   vn_vl_saldo_cred_ant_st    apuracao_icms_st.vl_saldo_cred_ant_st%type    := 0;
   vn_vl_icms_recol_st        apuracao_icms_st.vl_icms_recol_st%type        := 0;
   vn_vl_saldo_cred_st_transp apuracao_icms_st.vl_saldo_cred_st_transp%type := 0;
   vn_vl_deb_esp_st           apuracao_icms_st.vl_deb_esp_st%type           := 0;
   vn_vl_orig_rec             obrig_rec_apur_icms_st.vl_orig_rec%type       := 0;
   vn_vl_bc_icms_st           apuracao_icms_st.vl_base_calc_icms_st%type    := 0;
   vn_vl_aj_apur_gia          ajust_apur_icms_gia.vl_aj_apur%type           := 0;
   --
   vv_ibge_estado             estado.ibge_estado%type;
   vv_resumo_log              varchar2(500);
   vd_data                    date := null;
   vn_qtde                    number;
   --
   cursor c_aj_apur is
      select aa.id ajustapuracaoicmsst_id
           , aa.codajsaldoapuricms_id
           , nvl(sum(nvl(aa.vl_aj_apur,0)),0) vl_aj_apur
        from ajust_apuracao_icms_st aa
       where aa.apuracaoicmsst_id = gt_row_apuracao_icms_st.id
       group by aa.id
           , aa.codajsaldoapuricms_id;
   --
   cursor c_aj_gia( en_ajustapuracaoicmsst_id in ajust_apuracao_icms_st.id%type ) is
      select nvl(sum(nvl(aa.vl_aj_apur,0)),0) vl_aj_apur_gia
        from ajust_apur_icmsst_gia aa
       where aa.ajustapuracaoicmsst_id = en_ajustapuracaoicmsst_id;
   --
   cursor c_ajust_rj(en_apuracaoicmsst_id in number) is
      select sg.cd
           , c.compl_dados_1
           , c.compl_dados_2
           , c.compl_dados_3
        from apuracao_icms_st       a
           , ajust_apuracao_icms_st b
           , ajust_apur_icmsst_gia  c
           , subitem_gia            sg
       where a.id                     = en_apuracaoicmsst_id
         and b.apuracaoicmsst_id      = a.id
         and c.ajustapuracaoicmsst_id = b.id
         and sg.id                    = c.subitemgia_id;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(gt_row_per_apur_icms_st.empresa_id, 0) > 0
      and trunc(gt_row_per_apur_icms_st.dt_inicio) is not null
      and trunc(gt_row_per_apur_icms_st.dt_fim) is not null then
      --
      vn_fase := 2;
      -- Re-calcula o Vlr Saldo Credor Anterior ST
      vn_vl_saldo_cred_ant_st := nvl(fkg_saldo_credor_ant_st,0);
      --
      vn_fase := 3;
      --
      -- Validação: Só realiza a comparação entre o Saldo Credor Anterior da ST na Apuração de ICMS-ST
      -- e o do Saldo Credor Anterior Cálculo se ambos forem maiores que zero.
      -- OU seja, se o Saldo Credor Anterior da ST não foi lançado manualmente.
      if ( nvl(gt_row_apuracao_icms_st.vl_saldo_cred_ant_st,0) <> nvl(vn_vl_saldo_cred_ant_st,0) ) then
         --
         vn_fase := 4;
         --
         gv_resumo_log := 'O "Valor do Saldo Credor Anterior da ST" na Apuração do ICMS-ST ('||
                          trim(to_char(nvl(gt_row_apuracao_icms_st.vl_saldo_cred_ant_st,0),'9999G999G999G990D00'))||') está divergente do "Cálculo do Saldo '||
                          'Credor Anterior da ST" ('||trim(to_char(nvl(vn_vl_saldo_cred_ant_st,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 5;
      --  Re-calcula o Valor total do ICMS ST de devolução de mercadorias
      vn_vl_devol_st := nvl(fkg_soma_devol_st, 0);
      --
      vn_fase := 6;
      --
      -- Validação: Compara o Vlr da icms_st na devolução das mercadorias no apuração de icms
      -- com a soma dos valores de icms_st nos doc. fiscal de devolução.
      if nvl(gt_row_apuracao_icms_st.vl_devol_st,0) <> nvl(vn_vl_devol_st, 0) then
         --
         vn_fase := 7;
         --
         gv_resumo_log := 'O "Valor de ICMS_ST de Devolução de mercadorias" na Apuração do ICMS-ST ('||
                          trim(to_char(nvl(gt_row_apuracao_icms_st.vl_devol_st,0),'9999G999G999G990D00'))||')  está divergente da "Soma dos Valor do '||
                          'ICMS-ST nos Doc. Fiscais de devolução das mercadorias" ('||trim(to_char(nvl(vn_vl_devol_st,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 8;
      --  Re-calcula o Valor total do ICMS-ST de ressarcimentos decorrente de doc. fiscal
      vn_vl_ressarc_st := nvl(fkg_soma_ressarc_st, 0);
      --
      vn_fase := 9;
      --
      -- Validação: Compara o Vlr da icms_stde ressarcimentos decorrente de doc. fiscal na apuração de icms
      -- com a soma dos valores de icms_st nos doc. fiscal referentes ao ressarcimento.
      if nvl(gt_row_apuracao_icms_st.vl_ressarc_st,0) <> nvl(vn_vl_ressarc_st, 0) then
         --
         vn_fase := 10;
         --
         gv_resumo_log := 'O "Valor de ICMS_ST de Ressarcimentos" na Apuração do ICMS-ST ('||
                          trim(to_char(nvl(gt_row_apuracao_icms_st.vl_ressarc_st,0),'9999G999G999G990D00'))||') está divergente da "Soma dos Valores do '||
                          'ICMS-ST nos Doc. Fiscais referentes aos ressarcimentos" ('||trim(to_char(nvl(vn_vl_ressarc_st,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 11;
      --  Re-calcula o Valor total de Ajustes "Outros créditos ST" e “Estorno de débitos ST”"
      vn_vl_outro_cred_st := nvl(fkg_soma_out_cred_st_c190,0) + nvl(fkg_soma_out_cred_st_e220,0);
      --
      vn_fase := 12;
      --
      -- Validação: Compara o Valor total de Ajustes "Outros créditos ST" e “Estorno de débitos ST”" na apuração de icms
      -- com a soma dos valores nos lancamentos dos ajustes com os docs. fiscais referentes a outros créditos.
      if nvl(gt_row_apuracao_icms_st.vl_outro_cred_st,0) <> nvl(vn_vl_outro_cred_st, 0) then
         --
         vn_fase := 13;
         --
         gv_resumo_log := 'O "Valor de Ajuste de Cred. e Estorno de Deb. ST" na Apuração do ICMS-ST ('||
                          trim(to_char(nvl(gt_row_apuracao_icms_st.vl_outro_cred_st,0),'9999G999G999G990D00'))||') está divergente da "Soma dos Valores '||
                          'dos Lançamentos de Ajustes e dos Doc. Fiscais referentes Outros Cred. e Estorno de Deb." ('||
                          trim(to_char(nvl(vn_vl_outro_cred_st,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 14;
      --  Re-calcula o Vlr Tot. dos ajustes a crédito de ICMS-ST, provenientes de ajustes do documento fiscal.
      vn_vl_aj_credito_st := nvl(fkg_soma_aj_creditos_st,0);
      --
      vn_fase := 15;
      --
      -- Validação: Compara o Vlr Tot. dos ajustes a crédito de ICMS-ST,
      -- provenientes de ajustes do doc. fiscal na apuração de icms
      -- com a soma do icms-st nos doc. Fiscais provenientes de ajuste
      if nvl(gt_row_apuracao_icms_st.vl_aj_credito_st,0) <> nvl(vn_vl_aj_credito_st, 0) then
         --
         vn_fase := 16;
         --
         gv_resumo_log := 'O "Valor de Ajuste a Cred. de ICMS-ST" na Apuração do ICMS-ST ('||
                          trim(to_char(nvl(gt_row_apuracao_icms_st.vl_aj_credito_st,0),'9999G999G999G990D00'))||') está divergente da "Soma do Valor ICMS-ST '||
                          'nos Doc. Fiscais provenientes de ajuste" ('||trim(to_char(nvl(vn_vl_aj_credito_st,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 17;
      --  Re-calcula o Vlr Tot. do ICMS retido por Substituição Tributária
      vn_vl_retencao_st:= nvl(fkg_soma_ret_st_c190_cd590,0)
                          + nvl(fkg_soma_retencao_st_c690,0)
                          + nvl(fkg_soma_retencao_st_c791,0)
                          + nvl(fkg_soma_retencao_st_d690,0)
                          + nvl(fkg_soma_retencao_st_d697,0);
      --
      vn_fase := 18;
      --
      -- Validação: Compara o Vlr Tot. do ICMS Retido por Subst. Tribut. na apuração de icms
      -- com a soma cálculo do icms_st retido nos doc. fiscais.
      if nvl(gt_row_apuracao_icms_st.vl_retencao_st,0) <> nvl(vn_vl_retencao_st, 0) then
         --
         vn_fase := 19;
         --
         gv_resumo_log := 'O "Valor Tot. do ICMS Retido por Subst. Tribut." na Apuração do ICMS-ST ('||
                          trim(to_char(nvl(gt_row_apuracao_icms_st.vl_retencao_st,0),'9999G999G999G990D00'))||') está divergente da "Soma do Valor ICMS-ST '||
                          'Retido nos Doc. Fiscais" ('||trim(to_char(nvl(vn_vl_retencao_st,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 20;
      -- Re-calcula o Vlr Tot. dos ajustes "Outros débitos ST" " e “Estorno de créditos ST”
      vn_vl_out_deb_st:= nvl(fkg_soma_out_deb_st,0);
      --
      vn_fase := 21;
      --
      -- Validação: Compara o Vlr. Tot. dos Ajustes Outros Deb. de ST e Estorno de cred. st na apuração de icms
      -- com a soma dos lancamentos de ajustes.
      if nvl(gt_row_apuracao_icms_st.vl_out_deb_st,0) <> nvl(vn_vl_out_deb_st, 0) then
         --
         vn_fase := 22;
         --
         gv_resumo_log := 'O "Valor dos Ajustes de Outros Deb. e Estorno de Cred." na Apuração do ICMS-ST ('||
                          trim(to_char(nvl(gt_row_apuracao_icms_st.vl_out_deb_st,0),'9999G999G999G990D00'))||') está divergente da "Soma dos Lançamentos de '||
                          'Ajustes de Outros Deb. e Estorno de Cred." ('||trim(to_char(nvl(vn_vl_out_deb_st,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 23;
      -- Re-calcula o Vlr Tot. dos ajustes a débito de ICMS ST,
      -- provenientes de ajustes do doc. fiscal
      vn_vl_ajust_deb_st:= nvl(fkg_soma_aj_debitos_st,0);
      --
      vn_fase := 24;
      --
      -- Validação: Compara o Vlr. Tot. dos ajustes a débito de ICMS ST,
      -- provenientes de ajustes do doc. fiscal na apuração de icms
      -- com a soma dos icms_st nos doc. fiscais referente a ajuste de débitos
      if nvl(gt_row_apuracao_icms_st.vl_ajust_deb_st,0) <> nvl(vn_vl_ajust_deb_st, 0) then
         --
         vn_fase := 25;
         --
         gv_resumo_log := 'O "Valor Tot. dos Ajuste a Deb. de ICMS-ST" na Apuração do ICMS-ST ('||
                          trim(to_char(nvl(gt_row_apuracao_icms_st.vl_ajust_deb_st,0),'9999G999G999G990D00'))||') está divergente da "Soma dos ICMS-ST '||
                          'provenientes dos doc. fiscais referente a ajuste de deb." ('||trim(to_char(nvl(vn_vl_ajust_deb_st,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 26;
      -- Re-calcula o Vlr Tot. de Saldo devedor antes das deduções
      -- Se o Saldo Credor na Apuração for igual ao calculado. Utiliza o Cálculado, caso contrário
      -- utiliza-se o lançado a mão.
      vn_vl_saldo_dev_ant_st := ( nvl(vn_vl_retencao_st,0)
                                + nvl(vn_vl_out_deb_st,0)
                                + nvl(vn_vl_ajust_deb_st,0) )
                                - ( ( case when nvl(gt_row_apuracao_icms_st.vl_saldo_cred_ant_st,0) = nvl(vn_vl_saldo_cred_ant_st,0) then
                                         nvl(vn_vl_saldo_cred_ant_st,0)
                                      else
                                         nvl(gt_row_apuracao_icms_st.vl_saldo_cred_ant_st,0)
                                      end )
                                    + nvl(vn_vl_devol_st,0)
                                    + nvl(vn_vl_ressarc_st,0)
                                    + nvl(vn_vl_outro_cred_st,0)
                                    + nvl(vn_vl_aj_credito_st,0)
                                );
      --
      vn_fase := 27;
      --
      if nvl(vn_vl_saldo_dev_ant_st,0) >= 0 then
         --
         vn_vl_saldo_cred_st_transp := 0;
         --
      else
         --
         vn_vl_saldo_cred_st_transp := nvl(vn_vl_saldo_dev_ant_st,0) * (-1);
         vn_vl_saldo_dev_ant_st := 0;
         --
      end if;
      --
      vn_fase := 28;
      --
      -- Validação: Compara o Vlr. de Saldo devedor antes da deduções na apuração de icms
      -- com a soma o cálculo do Saldo devedor antes da deduções.
      if nvl(gt_row_apuracao_icms_st.vl_saldo_dev_ant_st,0) <> nvl(vn_vl_saldo_dev_ant_st, 0) then
         --
         vn_fase := 29;
         --
         gv_resumo_log := 'O "Valor do Saldo Devedor antes das Deduções" na Apuração do ICMS-ST ('||
                          trim(to_char(nvl(gt_row_apuracao_icms_st.vl_saldo_dev_ant_st,0),'9999G999G999G990D00'))||') está divergente do "Cálculo do Saldo '||
                          'devedor Antes da Deduções" ('||trim(to_char(nvl(vn_vl_saldo_dev_ant_st,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 30;
      -- Re-calcula o Vlr Tot. dos ajustes "Deduções ST"
      vn_vl_deducao_st := nvl(fkg_soma_deducoes_st_e220,0) + nvl(fkg_soma_deducoes_st_c197,0);
      --
      vn_fase := 31;
      --
      -- Validação: Compara o Vlr. Tot. dos ajustes "Deduções ST" na apuração de icms
      -- com a soma dos Lançamentos de Ajustes de Deduções ST com os Doc. Fiscais
      -- referentes as Deduções de ST.
      if nvl(gt_row_apuracao_icms_st.vl_deducao_st,0) <> nvl(vn_vl_deducao_st, 0) then
         --
         vn_fase := 32;
         --
         gv_resumo_log := 'O "Valor Tot. dos Ajuste de Deduções ST" na Apuração do ICMS-ST ('||
                          trim(to_char(nvl(gt_row_apuracao_icms_st.vl_deducao_st,0),'9999G999G999G990D00'))||') está divergente do "Soma dos Lançamentos de '||
                          'Ajustes de Deduções ST e dos Doc. Fiscais de referentes as Deduções ST" ('||
                          trim(to_char(nvl(vn_vl_deducao_st,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 33;
      -- Re-calcula o Imposto a recolher ST
      vn_vl_icms_recol_st := nvl(vn_vl_saldo_dev_ant_st,0) - nvl(vn_vl_deducao_st,0);
      --
      vn_fase := 34;
      --
      -- Validação: Compara o Vlr. do ST a recolher na Apuração do ICMS-ST com o subtração entre o
      -- Saldo Credor anterior e o Vlr da Decução Obtidos.
      if nvl(gt_row_apuracao_icms_st.vl_icms_recol_st,0) <>  nvl(vn_vl_icms_recol_st, 0)  then
         --
         vn_fase := 35;
         --
         gv_resumo_log := 'O "Valor de ST a Recolher" na Apuração do ICMS-ST ('||
                          trim(to_char(nvl(gt_row_apuracao_icms_st.vl_icms_recol_st,0),'9999G999G999G990D00'))||') está divergente do "Cálculo do Valor de '||
                          'ST a Recolher" ('||trim(to_char(nvl(vn_vl_icms_recol_st,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 36;
      -- Re-calcula o vlr de saldo credor st a transportar
      if vn_vl_icms_recol_st <= 0 then
         --
         vn_vl_saldo_cred_st_transp := ( ( case when nvl(gt_row_apuracao_icms_st.vl_saldo_cred_ant_st,0) = nvl(vn_vl_saldo_cred_ant_st,0) then
                                              nvl(vn_vl_saldo_cred_ant_st,0)
                                           else
                                              nvl(gt_row_apuracao_icms_st.vl_saldo_cred_ant_st,0)
                                           end )
                                         + nvl(vn_vl_devol_st,0)
                                         + nvl(vn_vl_ressarc_st,0)
                                         + nvl(vn_vl_outro_cred_st,0)
                                         + nvl(vn_vl_aj_credito_st,0) )
                                       - ( nvl(vn_vl_retencao_st,0)
                                           + nvl(vn_vl_out_deb_st,0)
                                           + nvl(vn_vl_ajust_deb_st,0) );
         --
         vn_fase := 37;
         --
         if nvl(vn_vl_saldo_cred_st_transp,0) < 0 then
            --
            vn_vl_saldo_cred_st_transp := nvl(vn_vl_saldo_cred_st_transp,0) * (-1);
            --
         end if;
            --
      end if;
      --
      vn_fase := 38;
      --
      -- Validação: Compara o Vlr. de Saldo Credor ST a Transp. na Apuração de ICMS-ST com o
      -- Cálculo do Vlr. do Saldo Credor ST a Transp.
      if nvl(gt_row_apuracao_icms_st.vl_saldo_cred_st_transp,0) <> nvl(vn_vl_saldo_cred_st_transp,0)  then
         --
         vn_fase := 39;
         --
         gv_resumo_log := 'O "Valor de Saldo Credor ST a Transp." na Apuração do ICMS-ST ('||
                          trim(to_char(nvl(gt_row_apuracao_icms_st.vl_saldo_cred_st_transp,0),'9999G999G999G990D00'))||') está divergente do "Cálculo do '||
                          'Saldo Credor ST a Transp." ('||trim(to_char(nvl(vn_vl_saldo_cred_st_transp,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 40;
      -- Re-calcula o Valores recolhidos ou a recolher, extraapuração"
      vn_vl_deb_esp_st :=  (nvl(fkg_soma_deb_esp_st, 0)
                            + nvl(fkg_soma_deb_esp_st_197, 0)
                            + nvl(fkg_soma_deb_esp_st_e220, 0));
      vn_fase := 41;
      --
      -- Validação: Compara o Vlr. recolhidos ou a recolher, extraapuração na Apuração de ICMS-ST com o
      -- Soma dos Vlrs. Referentes a extraapuração.
      if nvl(gt_row_apuracao_icms_st.vl_deb_esp_st,0) <> nvl(vn_vl_deb_esp_st, 0)  then
         --
         vn_fase := 42;
         --
         gv_resumo_log := 'O "Valores Recolhidos ao a Recolher, extraapuração" na Apuração do ICMS-ST ('||
                          trim(to_char(nvl(gt_row_apuracao_icms_st.vl_deb_esp_st,0),'9999G999G999G990D00'))||') está divergente do "Soma dos Valores de '||
                          'Extraapuração" ('||trim(to_char(nvl(vn_vl_deb_esp_st,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 43;
      -- Busca o valor da obrigação a recolher da ST.
      Begin
         select sum(v.vl_orig_rec)
           into vn_vl_orig_rec
           from obrig_rec_apur_icms_st v
          where v.apuracaoicmsst_id = gt_row_apuracao_icms_st.id;
      exception
         when others then
            vn_vl_orig_rec := 0;
      end;
      --
      vn_fase := 44;
      -- Validação: Verifica se as obrigações de imposto ST a recolher foram lançadas
      -- corretamente com o valor de ICMS-ST a recolher na apuração de ICMS-ST.
      -- Atenção: Durante os testes vou ter que lançar: ..." e o somatório dos valores informados no registro C197 cujo terceiro e quarto caractere seja 71
      if  ( nvl(gt_row_apuracao_icms_st.vl_icms_recol_st, 0)
           + nvl(gt_row_apuracao_icms_st.vl_deb_esp_st, 0) ) <> nvl(vn_vl_orig_rec, 0) then
         --
         vn_fase := 45;
         --
         gv_resumo_log := 'O "Valor da Obrigação a recolher " na Obrigações de ICMS-ST a Recolher ('||
                          trim(to_char(nvl(vn_vl_orig_rec,0),'9999G999G999G990D00'))||') está divergente do "Cálculo do Valor da Obrigação a recolher" na '||
                          'Apuração de ICMS-ST ('||trim(to_char(nvl(gt_row_apuracao_icms_st.vl_icms_recol_st,0),'9999G999G999G990D00'))||' + '||
                          trim(to_char(nvl(gt_row_apuracao_icms_st.vl_deb_esp_st,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 46;
      --  Re-calcula o Vlr Total da Base de Cálculo do ICMS retido por Substituição Tributária
      vn_vl_bc_icms_st:= nvl(fkg_soma_bc_ret_st_c190_cd590,0)
                       + nvl(fkg_soma_bc_retencao_st_c690,0)
                       + nvl(fkg_soma_bc_retencao_st_c791,0)
                       + nvl(fkg_soma_bc_retencao_st_d690,0)
                       + nvl(fkg_soma_bc_retencao_st_d697,0);
      --
      vn_fase := 47;
      --
      -- Validação: Compara o Vlr Total da Base de Cálculo do ICMS Retido por Subst. Tribut. na apuração de icms
      -- com a soma cálculo da Base de Cálculo do icms_st retido nos doc. fiscais.
      if nvl(gt_row_apuracao_icms_st.vl_base_calc_icms_st,0) <> nvl(vn_vl_bc_icms_st, 0) then
         --
         vn_fase := 48;
         --
         gv_resumo_log := 'O "Valor Total da Base de Cálculo do ICMS Retido por Subst. Tribut." na Apuração do ICMS-ST ('||
                          trim(to_char(nvl(gt_row_apuracao_icms_st.vl_base_calc_icms_st,0),'9999G999G999G990D00'))||') está divergente da "Soma da Base de '||
                          'Cálculo do Valor ICMS-ST Retido nos Doc. Fiscais" ('||trim(to_char(nvl(vn_vl_bc_icms_st,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 49;
      -- Caso exista registro na tabela "AJUST_APUR_ICMSST_GIA", a soma dos valores deve ser igual ao campo VL_AJ_APUR da tabela AJUST_APURACAO_ICMS_ST
      for r_aj_apur in c_aj_apur
      loop
         --
         exit when c_aj_apur%notfound or (c_aj_apur%notfound) is null;
         --
         vn_fase := 50;
         --
         open c_aj_gia(en_ajustapuracaoicmsst_id => r_aj_apur.ajustapuracaoicmsst_id);
         fetch c_aj_gia into vn_vl_aj_apur_gia;
         close c_aj_gia;
         --
         vn_fase := 51;
         --
         if nvl(vn_vl_aj_apur_gia,0) > 0 and
            nvl(r_aj_apur.vl_aj_apur,0) <> nvl(vn_vl_aj_apur_gia,0) then
            --
            vn_fase := 52;
            --
            gv_resumo_log := 'Código de Ajuste da Apuração = '||pk_csf_efd.fkg_cod_codajsaldoapuricms(r_aj_apur.codajsaldoapuricms_id)||'. O Valor de '||
                             'ajuste ('||trim(to_char(nvl(r_aj_apur.vl_aj_apur,0),'9999G999G999G990D00'))||'), está diferente do Valor de ajuste referente '||
                             'a GIA ('||trim(to_char(nvl(vn_vl_aj_apur_gia,0),'9999G999G999G990D00'))||').';
            --
            vn_loggenerico_id := null;
            --
            pk_log_generico.pkb_log_generico( sn_loggenerico_id => vn_loggenerico_id
                                       , ev_mensagem       => gv_mensagem_log
                                       , ev_resumo         => gv_resumo_log
                                       , en_tipo_log       => erro_de_validacao
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pk_log_generico.pkb_gt_log_generico( en_loggenerico   => vn_loggenerico_id
                                          , est_log_generico => est_log_generico );
            --
         end if;
         --
      end loop;
      --
      vn_fase := 53;
      --
      -- Recuperando o IBGE do estado da empresa em questão.
      begin
         --
         select es.ibge_estado
           into vv_ibge_estado
           from empresa e
              , pessoa  p
              , cidade  c
              , estado  es
          where e.id  = gt_row_per_apur_icms_st.empresa_id
            and p.id  = e.pessoa_id
            and c.id  = p.cidade_id
            and es.id = c.estado_id;
         --
      exception
         when others then
            --
            vv_ibge_estado := null;
            --
      end;
      --
      vn_fase := 54;
      --
      if nvl(vv_ibge_estado, '0') = '33' then -- Estado do Rio de Janeiro
         --
         for rec in c_ajust_rj(en_apuracaoicmsst_id => gt_row_apuracao_icms_st.id) loop
            exit when c_ajust_rj%notfound or (c_ajust_rj%notfound) is null;
            --
            if rec.cd in('O350006') then
               --
               vv_resumo_log := null;
               --
               if trim(rec.compl_dados_1) is null or
                  trim(rec.compl_dados_2) is null or
                  trim(rec.compl_dados_3) is null then
                  --
                  vn_fase := 54.1;
                  --
                  vv_resumo_log := 'Para o código de Sub-Item: "O350006"; devem ser informados valores para os campos: "Complemento Dados 1" como sendo '||
                                   'a "Data de Início do Período" (formato: ddmmrrrr), "Complemento Dados 2" como sendo o "Tipo de Período", e "Complemento '||
                                   'Dados 3" como sendo o valor da "Base de Cálculo". Verifique na aba "Ocorrência GIA" relacionada com a aba "Ajuste/'||
                                   'Benefício/Incentivo".';
                  --
               end if;
               --
               vn_fase := 54.2;
               --
               if trim(rec.compl_dados_1) is not null then
                  --
                  vn_fase := 54.3;
                  --
                  begin
                     vd_data := rec.compl_dados_1;
                  exception
                     when others then
                        vv_resumo_log := 'Para o código de Sub-Item: "O350006"; deve ser informado valor para o campo: "Complemento Dados 1" como sendo a '||
                                         '"Data de Início do Período" no formato: ddmmrrrr. Verifique na aba "Ocorrência GIA" relacionada com a aba '||
                                         '"Ajuste/Benefício/Incentivo".';
                  end;
                  --
               end if;
               --
            elsif rec.cd in('O350011') then
               --
               vv_resumo_log := null;
               --
               if trim(rec.compl_dados_1) is null or
                  trim(rec.compl_dados_2) is null then
                  --
                  vn_fase := 54.4;
                  --
                  vv_resumo_log := 'Para o código de Sub-Item: "O350011"; devem ser informados valores para os campos: "Complemento Dados 1" '||
                                   'como sendo a "Data de Início do Período" (formato: ddmmrrrr), e "Complemento Dados 2" como sendo o "Tipo de Período". '||
                                   'Verifique na aba "Ocorrência GIA" relacionada com a aba "Ajuste/Benefício/Incentivo".';
                  --
               end if;
               --
               vn_fase := 54.5;
               --
               if trim(rec.compl_dados_1) is not null then
                  --
                  vn_fase := 54.6;
                  --
                  begin
                     vd_data := rec.compl_dados_1;
                  exception
                     when others then
                        vv_resumo_log := 'Para o código de Sub-Item: "O350011"; deve ser informado valor para o campo: "Complemento Dados 1" '||
                                         'como sendo a "Data de Início do Período" no formato: ddmmrrrr. Verifique na aba "Ocorrência GIA" relacionada com '||
                                         'a aba "Ajuste/Benefício/Incentivo".';
                  end;
                  --
               end if;
               --
               vn_fase := 54.7;
               --
               if trim(rec.compl_dados_3) is not null then
                  --
                  vn_fase := 54.8;
                  --
                  vv_resumo_log := 'Para o código de Sub-Item: "O350011"; não deve ser informado valor para o campo: "Complemento Dados 3". '||
                                   'Verifique na aba "Ocorrência GIA" relacionada com a aba "Ajuste/Benefício/Incentivo".';
                  --
               end if;
               --
            elsif rec.cd in('S029999','S039999','S079999','S089999','S149999','S309999') then
               --
               if trim(rec.compl_dados_1) is null or
                  trim(rec.compl_dados_2) is null then
                  --
                  vn_fase := 54.9;
                  --
                  vv_resumo_log := 'Para os códigos de Sub-Item: "S029999", "S039999", "S079999", "S089999", "S149999", "S309999";'||
                                   ' devem ser informados valores para os campos: "Complemento Dados 1" como '||
                                   'sendo a "Descrição da Ocorrência", e "Complemento Dados 2" como sendo a "Legislação Tributária". Verifique na aba '||
                                   '"Ocorrência GIA" relacionada com a aba "Ajuste/Benefício/Incentivo".';
                  --
               end if;
               --
               vn_fase := 54.10;
               --
               if trim(rec.compl_dados_3) is not null then
                  --
                  vn_fase := 54.11;
                  --
                  vv_resumo_log := 'Para os códigos de Sub-Item: "S029999", "N039999", "S039999", "S089999", "S149999", "S309999";'||
                                   ' não deve ser informado valor para o campo: "Complemento Dados 3". '||
                                   'Verifique na aba "Ocorrência GIA" relacionada com a aba "Ajuste/Benefício/Incentivo".';
                  --
               end if;
               --
            else
               --
               -- Outros códigos não devem permitir informações nos campos complementares.
               if trim(rec.compl_dados_1) is not null or
                  trim(rec.compl_dados_2) is not null or
                  trim(rec.compl_dados_3) is not null then
                  --
                  vv_resumo_log := 'Para o código de Sub-Item informado, não é permitido informar dados nos campos Complementares: Dados 1, Dados 2, e/ou '
                                || 'Dados 3. Verifique na aba "Ocorrência GIA" relacionada com a aba "Ajuste/Benefício/Incentivo".';
                  --
               end if;
               --
            end if;
            --
         end loop;
         --
         if vv_resumo_log is not null then
            --
            vn_fase := 54.12;
            --
            gv_resumo_log := vv_resumo_log;
            --
            vn_loggenerico_id := null;
            --
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                             , ev_mensagem       => gv_mensagem_log
                                             , ev_resumo         => gv_resumo_log
                                             , en_tipo_log       => erro_de_validacao
                                             , en_referencia_id  => gn_referencia_id
                                             , ev_obj_referencia => gv_obj_referencia
                                             );
            --
            -- Armazena o "loggenerico_id" na memória
            pk_log_generico.pkb_gt_log_generico ( en_loggenerico   => vn_loggenerico_id
                                                , est_log_generico => est_log_generico
                                                );
            --
         end if;
         --
      else
         --
         -- IBGE não pertence ao estado do Rio de Janeiro.
         begin
            --
            select count(*)
              into vn_qtde
              from apuracao_icms_st       ai
                 , ajust_apuracao_icms_st aa
                 , ajust_apur_icmsst_gia  ag
             where ai.id                     = gt_row_apuracao_icms_st.id
               and aa.apuracaoicmsst_id      = ai.id
               and ag.ajustapuracaoicmsst_id = aa.id
               and ( ag.compl_dados_1 is not null
                     or ag.compl_dados_2 is not null
                     or ag.compl_dados_3 is not null
                   );
            --
         exception
            when others then
               --
               vn_qtde := 1;
               --
         end;
         --
         vn_fase := 55;
         --
         if nvl(vn_qtde, 0) > 0 then
            --
            gv_resumo_log := 'A abertura do GIA pertence a uma empresa que não é do estado do Rio de Janeiro, portanto os campos Complementares Dados_1, '||
                             'Dados_2 e Dados_3, não devem ser preenchidos. Verificar na aba "Ocorrência GIA" relacionada com a aba "Ajuste/Benefício/Incentivo".';
            --
            vn_loggenerico_id := null;
            --
            pk_log_generico.pkb_log_generico( sn_loggenerico_id => vn_loggenerico_id
                                            , ev_mensagem       => gv_mensagem_log
                                            , ev_resumo         => gv_resumo_log
                                            , en_tipo_log       => erro_de_validacao
                                            , en_referencia_id  => gn_referencia_id
                                            , ev_obj_referencia => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pk_log_generico.pkb_gt_log_generico( en_loggenerico   => vn_loggenerico_id
                                               , est_log_generico => est_log_generico );
            --
         end if;
         --
      end if;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      gv_resumo_log := 'Erro na pk_apur_icms_st.pkb_validar_dados fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                        , est_log_generico  => est_log_generico );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_validar_dados;

-------------------------------------------------------------------------------------------------------
-- Procedimento valida as informações da Apuração de IPI
procedure pkb_validar ( en_apuracaoicmsst_id in apuracao_icms_st.id%type )
is
   --
   vn_fase            number := 0;
   vt_log_generico    dbms_sql.number_table;
   vn_loggenerico_id  Log_Generico.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   -- recupera os dados da apuração de imposto
   pkb_dados_apuracao_icms_st ( en_apuracaoicmsst_id => en_apuracaoicmsst_id );
   --
   vn_fase := 2;
   --
   if nvl(gt_row_apuracao_icms_st.id,0) > 0 then
      --
      vn_fase := 3;
      -- Limpar os logs
      delete log_generico o
       where o.obj_referencia = gv_obj_referencia
         and o.referencia_id  = gt_row_apuracao_icms_st.id;
      --
      commit;
      --
      vn_fase := 4;
      -- Inicia processo de validação do ICMS
      pkb_validar_dados ( est_log_generico => vt_log_generico );
      --
      vn_fase := 5;
      --
      if nvl(vt_log_generico.count,0) <= 0 then
         --
         vn_fase := 6;
         -- Como não há erros de validação ai limpa os caracteres numa única vez.
         pkb_limpa_caracteres_bloco_e ( en_apuracaoicmsst_id => gt_row_apuracao_icms_st.id);
         --
         vn_fase := 7;
         --  Atualiza status como processado
         update apuracao_icms_st set dm_situacao = 3
         where id = gt_row_apuracao_icms_st.id;
         --
         gv_resumo_log := 'Apuração de ICMS-ST Processada com sucesso!';
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => INFO_APUR_IMPOSTO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      else
         --
         vn_fase := 8;
         --  Atualiza status de erros de validação
         update apuracao_icms_st set dm_situacao = 4
         where id = gt_row_apuracao_icms_st.id;
         --
         gv_resumo_log := 'Cálculo da Apuração de ICMS-ST possui erros de validação!';
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => INFO_APUR_IMPOSTO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms_st.pkb_validar fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => null
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_validar;

-------------------------------------------------------------------------------------------------------
-- Procedimento desfaz a situação da Apuração de ICMS e volta para seu anterior
procedure pkb_desfazer ( en_apuracaoicmsst_id in apuracao_icms_st.id%type )
is
   --
   vn_fase               number := 0;
   vv_descr_dm_situacao  Dominio.dominio%TYPE;
   vn_loggenerico_id     Log_Generico.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   -- recupera os dados da apuração de imposto
   pkb_dados_apuracao_icms_st ( en_apuracaoicmsst_id => en_apuracaoicmsst_id );
   --
   vn_fase := 2;
   --
   if nvl(gt_row_apuracao_icms_st.id,0) > 0 then
      --
      vn_fase := 3;
      -- Limpar os logs
      delete log_generico o
       where o.obj_referencia = 'APURACAO_ICMS_ST'
         and o.referencia_id  = en_apuracaoicmsst_id;
      --
      commit;
      --
      vn_fase := 4;
      -- Se o DM_SITUACAO = 4 "Erro de Validação" ou 3 "Processada", defaz para 2 "Cálculado"
      if gt_row_apuracao_icms_st.dm_situacao in (4, 3) then
         --
         vn_fase := 5;
         --
         update apuracao_icms_st set dm_situacao = 1
          where id = gt_row_apuracao_icms_st.id;
         --
         vn_fase := 6;
         --
         vv_descr_dm_situacao := pk_csf.fkg_dominio ( ev_dominio   => 'APURACAO_ICMS_ST.DM_SITUACAO'
                                                    , ev_vl        => '1' );
         --
      elsif gt_row_apuracao_icms_st.dm_situacao in (1, 2) then
         -- Se o DM_SITUACAO = 1 "Calculado" ou 2 "Erro no Cálculo", defaz para 0 "Aberto"
         vn_fase := 7;
         --
         update apuracao_icms_st set dm_situacao              = 0
                                   , vl_saldo_cred_ant_st     = 0
                                   , vl_devol_st              = 0
                                   , vl_ressarc_st            = 0
                                   , vl_outro_cred_st         = 0
                                   , vl_aj_credito_st         = 0
                                   , vl_retencao_st           = 0
                                   , vl_out_deb_st            = 0
                                   , vl_ajust_deb_st          = 0
                                   , vl_saldo_dev_ant_st      = 0
                                   , vl_deducao_st            = 0
                                   , vl_icms_recol_st         = 0
                                   , vl_saldo_cred_st_transp  = 0
                                   , vl_deb_esp_st            = 0
                                   , vl_base_calc_icms_st     = 0
          where id = gt_row_apuracao_icms_st.id;
         --
         vn_fase := 8;
         --
         vv_descr_dm_situacao := pk_csf.fkg_dominio ( ev_dominio => 'APURACAO_ICMS_ST.DM_SITUACAO'
                                                    , ev_vl      => '0' );
         --
      end if;
      --
      vn_fase := 9;
      --
      commit;
      --
      vn_fase := 10;
      --
      gv_resumo_log := 'Desfeito a situação de "' || pk_csf.fkg_dominio ( ev_dominio => 'APURACAO_ICMS_ST.DM_SITUACAO'
                                                                        , ev_vl      => gt_row_apuracao_icms_st.dm_situacao
                                                                        )
                       || '" para a situação "' || vv_descr_dm_situacao || '"';
      --
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                  , ev_mensagem        => gv_mensagem_log
                                  , ev_resumo          => gv_resumo_log
                                  , en_tipo_log        => INFO_APUR_IMPOSTO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia );
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms_st.pkb_desfazer fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => null
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_desfazer;

-------------------------------------------------------------------------------------------------------
-- Procedimento de gravar informações de Ajuste de Apuração de ICMS-ST
procedure pkb_insere_ajust_apur_icms_st ( en_apuracaoicmsst_id      in ajust_apuracao_icms_st.apuracaoicmsst_id%type
                                        , en_codajsaldoapuricms_id  in ajust_apuracao_icms_st.codajsaldoapuricms_id%type
                                        , ev_descr_compl_aj         in ajust_apuracao_icms_st.descr_compl_aj%type
                                        , en_vl_aj_apur             in ajust_apuracao_icms_st.vl_aj_apur%type
                                        )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  Log_Generico.id%TYPE;
   vn_qtde            number;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_apuracaoicmsst_id,0) > 0 
      and nvl(en_codajsaldoapuricms_id,0) > 0
      and nvl(en_vl_aj_apur,0) > 0
      then
      --
      vn_fase := 2;
      --
      begin
         --
         select count(1) 
           into vn_qtde
           from ajust_apuracao_icms_st
          where apuracaoicmsst_id      = en_apuracaoicmsst_id
            and codajsaldoapuricms_id  = en_codajsaldoapuricms_id;
         --
      exception
         when others then
            vn_qtde := 0;
      end;
      --
      vn_fase := 3;
      --
      if nvl(vn_qtde,0) <= 0 then
         --
         vn_fase := 3.1;
         --
         insert into ajust_apuracao_icms_st ( id
                                            , apuracaoicmsst_id
                                            , codajsaldoapuricms_id
                                            , descr_compl_aj
                                            , vl_aj_apur
                                            )
                                     values ( ajustapuracaoicmsst_seq.nextval --id
                                            , en_apuracaoicmsst_id -- apuracaoicmsst_id
                                            , en_codajsaldoapuricms_id -- codajsaldoapuricms_id
                                            , ev_descr_compl_aj -- descr_compl_aj
                                            , en_vl_aj_apur -- vl_aj_apur
                                            );
         --
      else
         --
         vn_fase := 3.2;
         --
         update ajust_apuracao_icms_st set descr_compl_aj  = ev_descr_compl_aj
                                         , vl_aj_apur      = en_vl_aj_apur
          where apuracaoicmsst_id      = en_apuracaoicmsst_id
            and codajsaldoapuricms_id  = en_codajsaldoapuricms_id;
         --
      end if;
      --
      vn_fase := 4;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms_st.pkb_insere_ajust_apur_icms_st fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => null
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_insere_ajust_apur_icms_st;

-------------------------------------------------------------------------------------------------------
-- Procedimento de Lançamento de Ajuste para Valor de ICMS-ST Não Destacado
procedure pkb_criar_aj_icmsst_nao_dest
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  Log_Generico.id%TYPE;
   vn_vl_aj_apur      ajust_apuracao_icms_st.vl_aj_apur%type;
   --
   cursor c_param is
   select p2.*
     from param_efd_icms_ipi     p1
        , param_efd_icmsst       p2
    where p1.empresa_id          = gt_row_per_apur_icms_st.empresa_id
      and p2.paramefdicmsipi_id  = p1.id
      and p2.estado_id           = gt_row_apuracao_icms_st.estado_id
      and p2.dm_efeito           = 1 -- Imposto não destacado
    order by p2.estado_id;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_param loop
      exit when c_param%notfound or (c_param%notfound) is null;
      --
      vn_fase := 2;
      --
      begin
         --
         select sum(ii.vl_imp_nao_dest)
           into vn_vl_aj_apur
           from nota_fiscal      nf
              , mod_fiscal       mf
              , nota_fiscal_dest nfd
              , item_nota_fiscal inf
              , imp_itemnf       ii
              , tipo_imposto     ti
          where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
            and nf.dm_st_proc      = 4
            and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
            and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
                  or
                 (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
                  or
                 (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
                  or
                 (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65')
            and nfd.notafiscal_id  = nf.id
            and nfd.uf             = gv_apur_sigla_estado
            and inf.notafiscal_id  = nf.id
            and ii.itemnf_id       = inf.id
            and ti.id              = ii.tipoimp_id
            and ti.cd              = 2; -- ICMS-ST
         --
      exception
         when others then
            vn_vl_aj_apur := 0;
      end;
      --
      vn_fase := 3;
      --
      pkb_insere_ajust_apur_icms_st ( en_apuracaoicmsst_id      => gt_row_apuracao_icms_st.id
                                    , en_codajsaldoapuricms_id  => rec.codajsaldoapuricms_id
                                    , ev_descr_compl_aj         => 'Ajuste de valor de imposto não destacado'
                                    , en_vl_aj_apur             => vn_vl_aj_apur
                                    );
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms_st.pkb_criar_aj_icmsst_nao_dest fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => null
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_criar_aj_icmsst_nao_dest;

-------------------------------------------------------------------------------------------------------
-- Procedimento faz a apuração do ICMS_ST
procedure pkb_apuracao ( en_apuracaoicmsst_id in apuracao_icms_st.id%type )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  Log_Generico.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_apuracaoicmsst_id,0) > 0 then
      --
      vn_fase := 2;
      --
      pkb_dados_apuracao_icms_st ( en_apuracaoicmsst_id => en_apuracaoicmsst_id );
      --
      vn_fase := 3;
      --
      if nvl(gt_row_apuracao_icms_st.id,0) > 0 then
         --
         vn_fase := 4;
         -- Procedimento de Lançamento de Ajuste para Valor de ICMS-ST Não Destacado
         pkb_criar_aj_icmsst_nao_dest;
         --
         vn_fase := 5;
         -- "04-VL_DEVOL_ST: Valor total do ICMS ST de devolução de mercadorias"
         -- Campo 04 - Validação: o valor informado deve corresponder à soma do campo VL_ICMS_ST do registro C190, quando o
         -- valor do campo CFOP for igual a 1410, 1411, 1414, 1415, 1660, 1661, 1662, 2410, 2411, 2414, 2415, 2660, 2661 ou 2662
         -- e para documentos com data (campo DT_E_S ou DT_DOC do registro C100) compreendida no período de apuração do
         -- registro E200. Só será considerada a data do campo DT_DOC, quando o campo DT_E_S estiver em branco.
         --
         gt_row_apuracao_icms_st.vl_devol_st := nvl(fkg_soma_devol_st, 0);
         --
         vn_fase := 6;
         -- "05-VL_RESSARC_ST: Valor total do ICMS ST de ressarcimentos"
         -- Campo 05 – Preenchimento: só deve ser informado valor neste campo se o ressarcimento tiver origem em documento fiscal.
         -- Validação: o valor informado deve corresponder à soma do campo VL_ICMS_ST do registro C190, quando o valor do
         -- campo CFOP for igual a 1603 ou 2603 e para documentos com data, campo DT_E_S ou campo DT_DOC do registro
         -- C100, compreendida no período de apuração do registro E200. Só será considerada a data do campo DT_DOC, quando o
         -- campo DT_E_S estiver em branco.
         --
         gt_row_apuracao_icms_st.vl_ressarc_st := nvl(fkg_soma_ressarc_st, 0);
         --
         vn_fase := 7;
         -- "06-VL_OUT_CRED_ST: Valor total de Ajustes "Outros créditos ST" e “Estorno de débitos ST”"
         -- Campo 06 - Validação: o valor informado deve corresponder ao somatório do campo VL_AJ_APUR dos registros E220
         -- quando o terceiro caractere for igual a ‘1’ e o quarto caractere do campo COD_AJ_APUR for igual a ‘2’ ou ‘3’ mais a
         -- soma do campo VL_ICMS_ST do registro C190 (demais CFOPs), quando o primeiro caractere do campo CFOP for ‘1’ ou
         -- ‘2’, exceto se o valor do campo CFOP for 1410, 1411, 1414, 1415, 1660, 1661, 1662, 2410, 2411, 2414, 2415, 2660, 2661
         -- ou 2662. Para documentos com data (campo DT_E_S ou DT_DOC do Registro C100) compreendida no período de apuração
         -- do Registro E200. Só será considerada a data do Campo DT_DOC, quando o Campo DT_E_S estiver em branco.
         --
         gt_row_apuracao_icms_st.vl_outro_cred_st := nvl(fkg_soma_out_cred_st_c190,0) + nvl(fkg_soma_out_cred_st_e220,0);
         --
         vn_fase := 8;
         -- "07-VL_AJ_CREDITOS_ST: Valor total dos ajustes a crédito de ICMS ST, provenientes de ajustes do documento fiscal.
         -- Campo 07 – Validação: o valor informado deve corresponder ao somatório do campo VL_ICMS do registro C197, por
         -- UF, se o terceiro caractere do código de ajuste no campo COD_AJ do registro C197 for “0”, “1” ou “2” e o quarto caractere
         -- for “1”(um) para todos os registros onde os documentos estejam compreendidos no período informado no registro
         -- E200, considerando a UF, utilizando para tanto o campo DT_E_S (C100). Quando o campo DT_E_S (C100) não estiver
         -- preenchido, a data considerada é a informada no campo DT_DOC.
         -- Para os documentos extemporâneos (campo COD_SIT, do registro C100, com valor igual ‘01’), assim como para os documentos
         -- complementares extemporâneas (campo COD_SIT, do registro C100, com valor igual ‘07’), estes valores devem
         -- ser informados no primeiro período no registro E200, para a UF.
         --
         gt_row_apuracao_icms_st.vl_aj_credito_st := nvl(fkg_soma_aj_creditos_st,0);
         --
         vn_fase := 9;
         -- "08-VL_RETENÇAO_ST: Valor Total do ICMS retido por Substituição Tributária"
         -- Campo 08 – Validação: o valor informado deve corresponder ao somatório do campo VL_ICMS_ST de todos os registros
         -- C190, C590, C690, C791, D590, D690 e D697, por UF, se o primeiro caractere do campo CFOP for igual a 5 ou 6, considerando
         -- o período, por UF. Para os registros C791 e D697, o CFOP a ser considerado é o do registro pai C790 e D696,
         -- respectivamente. Nesta soma, devem constar apenas os documentos fiscais compreendidos no período informado no registro
         -- E200, utilizando-se, para tanto, os campos DT_DOC (C600, D600) ou DT_E_S (C100, C500, D500) ou DT_DOC_FIN (C700, D695).
         -- Quando a data do campo DT_E_S não for informada, será utilizada a data do campo DT_DOC.
         --
         gt_row_apuracao_icms_st.vl_retencao_st := nvl(fkg_soma_ret_st_c190_cd590,0)
                                                   + nvl(fkg_soma_retencao_st_c690,0)
                                                   + nvl(fkg_soma_retencao_st_c791,0)
                                                   + nvl(fkg_soma_retencao_st_d690,0)
                                                   + nvl(fkg_soma_retencao_st_d697,0);
         --
         vn_fase := 10;
         -- "09-VL_OUT_DEB_ST: Valor Total dos ajustes "Outros débitos ST" " e “Estorno de créditos ST”
         -- Campo 09 - Validação: o valor informado deve corresponder ao somatório do campo VL_AJ_APUR do Registro E220,
         -- quando o terceiro caractere for igual a ‘1’ e o quarto for igual a ‘0’ ou ‘1’, ambos do campo COD_AJ_APUR do registro E220.
         --
         gt_row_apuracao_icms_st.vl_out_deb_st := nvl(fkg_soma_out_deb_st,0);
         --
         vn_fase := 11;
         -- "10-VL_AJ_DEBITOS_ST: Valor total dos ajustes a débito de ICMS ST, provenientes de ajustes do documento fiscal."
         -- Campo 10 - Validação: o valor informado deve corresponder ao somatório do campo VL_ICMS do registro C197, por UF,
         -- se o terceiro caractere do código de ajuste (campo COD_AJ) do registro C197 for ‘3’, ‘4’ ou ‘5’ e o quarto caractere for
         -- ‘1’, para todos os registros onde os documentos estejam compreendidos no período informado no registro E200, por UF,
         -- utilizando-se, para tanto, o campo DT_E_S (C100).
         -- Quando a data do campo DT_E_S (C100) não estiver preenchida, é utilizada a data do campo DT_DOC.
         -- Devem ser excluídos os documentos extemporâneos (campo COD_SIT do registro C100 com valor igual ‘01’) e os documentos
         -- complementares extemporâneas (campo COD_SIT do registro C100 com valor igual ‘07’), cujos valores devem ser
         -- informados no campo DEB_ESP_ST junto com os demais valores extra-apuração.
         --
         gt_row_apuracao_icms_st.vl_ajust_deb_st := nvl(fkg_soma_aj_debitos_st,0);
         --
         vn_fase := 12;
         -- recupera o saldo anterior
         if nvl(gt_row_apuracao_icms_st.vl_saldo_cred_ant_st,0) <= 0 then
            gt_row_apuracao_icms_st.vl_saldo_cred_ant_st := fkg_saldo_credor_ant_st;
         end if;         
         --
         vn_fase := 13;
         -- "11-VL_SLD_DEV_ANT_ST: Valor total de Saldo devedor antes das deduções"
         -- Campo 11 - Validação: o valor informado deve ser preenchido com base na expressão: soma do total de retenção por ST,
         -- campo VL_RETENCAO_ST, com total de outros débitos por ST, campo VL_OUT_DEB_ST, com total de ajustes de débito
         -- por ST, campo VL_AJ_DEBITOS_ST, menos a soma do saldo credor do período anterior por ST, campo
         -- VL_SLD_CRED_ANT_ST, com total de devolução por ST, campo VL_DEVOL_ST, com total de ressarcimento por ST,
         -- campo VL_RESSARC_ST, com o total de outros créditos por ST, campo VL_OUT_CRED_ST, com o total de ajustes de
         -- crédito por ST, campo VL_AJ_CREDITOS_ST. Se o valor da expressão for maior ou igual a “0” (zero), então este valor
         -- deve ser informado neste campo e o campo VL_SLD_CRED_ST_TRANSPORTAR deve ser igual a “0” (zero). Se o valor
         -- da expressão for menor que “0” (zero), então este campo deve ser preenchido com “0” (zero) e o valor absoluto da expressão
         -- deve ser informado no campo VL_SLD_CRED_ST_TRANSPORTAR.
         --
         gt_row_apuracao_icms_st.vl_saldo_dev_ant_st := ( nvl(gt_row_apuracao_icms_st.vl_retencao_st,0)
                                                          + nvl(gt_row_apuracao_icms_st.vl_out_deb_st,0)
                                                          + nvl(gt_row_apuracao_icms_st.vl_ajust_deb_st,0) )
                                                        - ( nvl(gt_row_apuracao_icms_st.vl_saldo_cred_ant_st,0)
                                                            + nvl(gt_row_apuracao_icms_st.vl_devol_st,0)
                                                            + nvl(gt_row_apuracao_icms_st.vl_ressarc_st,0)
                                                            + nvl(gt_row_apuracao_icms_st.vl_outro_cred_st,0)
                                                            + nvl(gt_row_apuracao_icms_st.vl_aj_credito_st,0)
                                                           );
         --
         vn_fase := 14;
         --
         if nvl(gt_row_apuracao_icms_st.vl_saldo_dev_ant_st,0) >= 0 then
            --
            gt_row_apuracao_icms_st.vl_saldo_cred_st_transp := 0;
            --
         else
            --
            gt_row_apuracao_icms_st.vl_saldo_cred_st_transp := nvl(gt_row_apuracao_icms_st.vl_saldo_dev_ant_st,0) * (-1);
            gt_row_apuracao_icms_st.vl_saldo_dev_ant_st := 0;
            --
         end if;
         --
         vn_fase := 15;
         -- 12-VL_DEDUÇÕES_ST: Valor total dos ajustes "Deduções ST"
         -- Campo 12 - Validação: o valor informado deve corresponder ao somatório do campo VL_AJ_APUR do Registro E220,
         -- por UF, quando o terceiro caractere for igual a ‘1’ e o quarto caractere do campo COD_AJ_APUR for igual a ‘4’, mais a
         -- soma do campo VL_ICMS do registro C197, se o terceiro caractere do campo COD_AJ for ‘6’ e o quarto caractere for
         -- ‘1’, para todos os registros onde os documentos estejam compreendidos no período informado no registro E200, por UF,
         -- utilizando-se, para tanto, o campo DT_E_S, do registro C100. Quando o campo DT_E_S do registro C100 não estiver preenchido,
         -- utilizar o campo DT_DOC do mesmo registro.
         --
         gt_row_apuracao_icms_st.vl_deducao_st := nvl(fkg_soma_deducoes_st_e220,0) + nvl(fkg_soma_deducoes_st_c197,0);
         --
         vn_fase := 16;
         -- "13-VL_ICMS_RECOL_ST: Imposto a recolher ST (11-12)"
         -- Campo 13 - Validação: o valor informado deve corresponder à diferença entre o campo VL_SLD_DEV_ANT_ST e o
         -- campo VL_DEDUCOES_ST.
         -- O valor da soma deste campo com o campo DEB_ESP_ST deve corresponder à soma dos valores do campo VL_OR do
         -- registro E250.
         --
         gt_row_apuracao_icms_st.vl_icms_recol_st := nvl(gt_row_apuracao_icms_st.vl_saldo_dev_ant_st,0) - nvl(gt_row_apuracao_icms_st.vl_deducao_st,0);
         --
         vn_fase := 17;
         -- "14-VL_SLD_CRED_ST_TRANSPORTAR: Saldo credor de ST a transportar para o período seguinte [(03+04+05+06+07)– (08+09+10)]"
         -- Campo 14 - Validação: se o valor da expressão: soma do total de retenção por ST, campo VL_RETENCAO_ST, com total
         -- de outros débitos por ST, campo VL_OUT_DEB_ST, com total de ajustes de débito por ST, campo
         -- VL_AJ_DEBITOS_ST, menos a soma do saldo credor do período anterior por ST, campo VL_SLD_CRED_ANT_ST, com
         -- total de devolução por ST, campo VL_DEVOL_ST, com total de ressarcimento por ST, campo VL_RESSARC_ST, com o
         -- total de outros créditos por ST, campo VL_OUT_CRED_ST, com o total de ajustes de crédito por ST, campo
         -- VL_AJ_CREDITOS_ST, for maior ou igual a “0” (zero), este campo deve ser preenchido com “0” (zero). Se for menor que
         -- “0” (zero), o valor absoluto do resultado deve ser informado.
         --
         if nvl(gt_row_apuracao_icms_st.vl_icms_recol_st,0) <= 0 then
            --
            vn_fase := 18;
            --
            gt_row_apuracao_icms_st.vl_saldo_cred_st_transp := ( nvl(gt_row_apuracao_icms_st.vl_saldo_cred_ant_st,0)
                                                                 + nvl(gt_row_apuracao_icms_st.vl_devol_st,0)
                                                                 + nvl(gt_row_apuracao_icms_st.vl_ressarc_st,0)
                                                                 + nvl(gt_row_apuracao_icms_st.vl_outro_cred_st,0)
                                                                 + nvl(gt_row_apuracao_icms_st.vl_aj_credito_st,0) )
                                                                - ( nvl(gt_row_apuracao_icms_st.vl_retencao_st,0)
                                                                    + nvl(gt_row_apuracao_icms_st.vl_out_deb_st,0)
                                                                    + nvl(gt_row_apuracao_icms_st.vl_ajust_deb_st,0) );
            --
            vn_fase := 19;
            --
            if nvl(gt_row_apuracao_icms_st.vl_saldo_cred_st_transp,0) < 0 then
               --
               gt_row_apuracao_icms_st.vl_saldo_cred_st_transp := nvl(gt_row_apuracao_icms_st.vl_saldo_cred_st_transp,0) * (-1);
               --
            end if;
            --
         end if;
         --
         vn_fase := 20;
         -- "15-DEB_ESP_ST: Valores recolhidos ou a recolher, extraapuração"
         -- Campo 15 – Preenchimento: Informar por UF, valor correspondente ao somatório dos valores:
         -- a) de ICMS_ST referente aos documentos fiscais extemporâneos (COD_SIT igual a “01”) e das notas fiscais complementares
         -- extemporâneas (COD_SIT igual a “07”);
         -- b) de ajustes do campo VL_ICMS do registro C197, se o terceiro caractere do código informado no campo COD_AJ
         -- do registro C197 for igual a “7” (débitos especiais) e o quarto caractere for igual a “1” (operações por ST) referente
         -- aos documentos compreendidos no período a que se refere a escrituração; e
         -- c) de ajustes do campo VL_AJ_APUR do registro E220, se o terceiro caractere do código informado no campo
         -- COD_AJ_APUR do registro E220 for igual a “1” (ICMS- ST) e o quarto caractere for igual a “5”(débito especial).
         --
         gt_row_apuracao_icms_st.vl_deb_esp_st :=  (nvl(fkg_soma_deb_esp_st, 0)
                                                  + nvl(fkg_soma_deb_esp_st_197, 0)
                                                  + nvl(fkg_soma_deb_esp_st_e220, 0));
         --
         vn_fase := 21;
         -- "16-VL_BASE_CALC_ICMS_ST: Valor da Base de Cálculo do ICMS retido por Substituição Tributária"
         -- Campo 16 – Validação: o valor informado deve corresponder ao somatório do campo VL_BC_ICMS_ST de todos os registros
         -- C190, C590, C690, C791, D590, D690 e D697, por UF, se o primeiro caractere do campo CFOP for igual a 5 ou 6, considerando
         -- o período, por UF. Para os registros C791 e D697, o CFOP a ser considerado é o do registro pai C790 e D696,
         -- respectivamente. Nesta soma, devem constar apenas os documentos fiscais compreendidos no período informado no registro
         -- E200, utilizando-se, para tanto, os campos DT_DOC (C600, D600) ou DT_E_S (C100, C500, D500) ou DT_DOC_FIN (C700, D695).
         -- Quando a data do campo DT_E_S não for informada, será utilizada a data do campo DT_DOC.
         --
         gt_row_apuracao_icms_st.vl_base_calc_icms_st := nvl(fkg_soma_bc_ret_st_c190_cd590,0)
                                                       + nvl(fkg_soma_bc_retencao_st_c690,0)
                                                       + nvl(fkg_soma_bc_retencao_st_c791,0)
                                                       + nvl(fkg_soma_bc_retencao_st_d690,0)
                                                       + nvl(fkg_soma_bc_retencao_st_d697,0);
         --
         vn_fase := 22;
         -- 02 - ind_mov_st: 0 – sem operações com st ou 1 – com operações de st
         if (nvl(gt_row_apuracao_icms_st.vl_devol_st,0) > 0
             or nvl(gt_row_apuracao_icms_st.vl_ressarc_st,0) > 0
             or nvl(gt_row_apuracao_icms_st.vl_outro_cred_st,0) > 0
             or nvl(gt_row_apuracao_icms_st.vl_aj_credito_st,0) > 0
             or nvl(gt_row_apuracao_icms_st.vl_retencao_st,0) > 0
             or nvl(gt_row_apuracao_icms_st.vl_out_deb_st,0) > 0
             or nvl(gt_row_apuracao_icms_st.vl_ajust_deb_st,0) > 0
             or nvl(gt_row_apuracao_icms_st.vl_base_calc_icms_st,0) > 0) then
            gt_row_apuracao_icms_st.dm_ind_mov_st := 1;
          else
            gt_row_apuracao_icms_st.dm_ind_mov_st := 0;
          end if;
         --
         vn_fase := 23;
         --
         update apuracao_icms_st
            set dm_situacao                = 1   -- Calculada
              , dm_ind_mov_st              = gt_row_apuracao_icms_st.dm_ind_mov_st
              , vl_saldo_cred_ant_st       = nvl(gt_row_apuracao_icms_st.vl_saldo_cred_ant_st,0)
              , vl_devol_st                = nvl(gt_row_apuracao_icms_st.vl_devol_st,0)
              , vl_ressarc_st              = nvl(gt_row_apuracao_icms_st.vl_ressarc_st,0)
              , vl_outro_cred_st           = nvl(gt_row_apuracao_icms_st.vl_outro_cred_st,0)
              , vl_aj_credito_st           = nvl(gt_row_apuracao_icms_st.vl_aj_credito_st,0)
              , vl_retencao_st             = nvl(gt_row_apuracao_icms_st.vl_retencao_st,0)
              , vl_out_deb_st              = nvl(gt_row_apuracao_icms_st.vl_out_deb_st,0)
              , vl_ajust_deb_st            = nvl(gt_row_apuracao_icms_st.vl_ajust_deb_st,0)
              , vl_saldo_dev_ant_st        = nvl(gt_row_apuracao_icms_st.vl_saldo_dev_ant_st,0)
              , vl_deducao_st              = nvl(gt_row_apuracao_icms_st.vl_deducao_st,0)
              , vl_icms_recol_st           = nvl(gt_row_apuracao_icms_st.vl_icms_recol_st,0)
              , vl_saldo_cred_st_transp    = nvl(gt_row_apuracao_icms_st.vl_saldo_cred_st_transp,0)
              , vl_deb_esp_st              = nvl(gt_row_apuracao_icms_st.vl_deb_esp_st,0)
              , vl_base_calc_icms_st       = nvl(gt_row_apuracao_icms_st.vl_base_calc_icms_st,0)
         where id = gt_row_apuracao_icms_st.id;
         --
         vn_fase := 24;
         --
         commit;
         --
         vn_fase := 25;
         --
         gv_resumo_log := 'Cálculo da Apuração de ICMS-ST realizado com sucesso!';
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => INFO_APUR_IMPOSTO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --

      end if;
      --
   end if;
   --
exception
   when others then
      --
      update apuracao_icms_st set dm_situacao = 2 -- Erro no Calculo
       where id = en_apuracaoicmsst_id;
      --
      commit;
      --
      gv_mensagem_log := 'Erro na pk_apur_icms_st.pkb_apuracao fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => null
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_apuracao;

-------------------------------------------------------------------------------------------------------
-- Procedimento Valida a apuração do ICMS_ST para todos os estados do período
procedure pkb_validar_geral ( en_perapuricmsst_id in per_apur_icms_st.id%type )
is
   --
   vn_fase  number := 0;
   --
   cursor c_apur is
   select id
     from apuracao_icms_st
	where perapuricmsst_id = en_perapuricmsst_id
	order by id;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_perapuricmsst_id,0) > 0 then
      --
      vn_fase := 2;
      --
      for rec in c_apur
      loop
	 --
         exit when c_apur%notfound or (c_apur%notfound) is null;
	 --
	 vn_fase := 3;
	 --
	 pkb_validar ( en_apuracaoicmsst_id => rec.id );
	 --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms_st.pkb_validar_geral fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => null
                                     , ev_obj_referencia  => null );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_validar_geral;

-------------------------------------------------------------------------------------------------------
-- Procedimento desfaz a apuração do ICMS_ST para todos os estados do período
procedure pkb_desfazer_geral ( en_perapuricmsst_id in per_apur_icms_st.id%type )
is
   --
   vn_fase  number := 0;
   --
   cursor c_apur is
   select id
     from apuracao_icms_st
	where perapuricmsst_id = en_perapuricmsst_id
	order by id;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_perapuricmsst_id,0) > 0 then
      --
      vn_fase := 2;
      --
      for rec in c_apur
      loop
	 --
         exit when c_apur%notfound or (c_apur%notfound) is null;
	 --
	 vn_fase := 3;
	 --
	 pkb_desfazer ( en_apuracaoicmsst_id => rec.id );
	 --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms_st.pkb_desfazer_geral fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => null
                                     , ev_obj_referencia  => null );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_desfazer_geral;

-------------------------------------------------------------------------------------------------------
-- Procedimento faz a apuração do ICMS_ST para todos os estados do período
procedure pkb_apuracao_geral ( en_perapuricmsst_id in per_apur_icms_st.id%type )
is
   --
   vn_fase  number := 0;
   --
   cursor c_apur is
   select id
     from apuracao_icms_st
	where perapuricmsst_id = en_perapuricmsst_id
	order by id;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_perapuricmsst_id,0) > 0 then
      --
      vn_fase := 2;
      --
      for rec in c_apur
      loop
	 --
         exit when c_apur%notfound or (c_apur%notfound) is null;
	 --
	 vn_fase := 3;
	 --
	 pkb_apuracao ( en_apuracaoicmsst_id => rec.id );
	 --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms_st.pkb_apuracao_geral fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => null
                                     , ev_obj_referencia  => null );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_apuracao_geral;

-------------------------------------------------------------------------------------------------------
-- Processo de geração dos estados
procedure pkb_gerar_estados ( en_perapuricmsst_id in per_apur_icms_st.id%type )
is
   --
   vn_fase      number := 0;
   vn_estado_id number := 0;
   --
   cursor c_dados1 is
   select distinct i.estado_id
     from cons_nf_prest_serv         cnfps
        , reg_an_cons_nf_prest_serv  r
        , cfop                       c
        , reg_an_cons_nf_ps_st_uf    i
    where cnfps.empresa_id           = gt_row_per_apur_icms_st.empresa_id
      and ( trunc(cnfps.dt_doc_ini) >= trunc(gt_row_per_apur_icms_st.dt_inicio) and
            trunc(cnfps.dt_doc_fin) <= trunc(gt_row_per_apur_icms_st.dt_fim) )
      and r.consnfprestserv_id       = cnfps.id
      and c.id                       = r.cfop_id
      and substr(c.cd, 1, 1)        in ('5', '6')
      and i.reganconsnfprestserv_id  = r.id;
   --
   cursor c_dados2 is
   select distinct cid.estado_id
     from cons_prest_serv         cps
        , cidade                  cid
        , reg_an_cons_prest_serv  r
        , cfop                    c
    where cps.empresa_id          = gt_row_per_apur_icms_st.empresa_id
      and trunc(cps.dt_doc) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
      and cid.ibge_cidade         = cps.cod_mun_ibge
      and r.consprestserv_id      = cps.id
      and c.id                    = r.cfop_id
      and substr(c.cd, 1, 1)     in ('5', '6');
   --
   cursor c_dados3 is
   select distinct i.estado_id
     from cons_nf_via_unica           cnf
        , reg_anal_cons_nf_via_unica  r
        , cfop                        c
        , inf_consnfviaun_icmsst_uf   i
    where cnf.empresa_id             = gt_row_per_apur_icms_st.empresa_id
      and ( trunc(cnf.dt_doc_ini)   >= trunc(gt_row_per_apur_icms_st.dt_inicio) and
            trunc(cnf.dt_doc_fin)   <= trunc(gt_row_per_apur_icms_st.dt_fim) )
      and r.consnfviaunica_id        = cnf.id
      and c.id                       = r.cfop_id
      and substr(c.cd, 1, 1)        in ('5', '6')
      and i.reganalconsnfviaunica_id = r.id;
   --
   cursor c_dados4 is
   select distinct cid.estado_id
     from cons_nota_fiscal           cnf
        , cidade                     cid
        , reg_anal_cons_nota_fiscal  r
        , cfop                       c
    where cnf.empresa_id          = gt_row_per_apur_icms_st.empresa_id
      and trunc(cnf.dt_doc) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
      and cid.id                  = cnf.cidade_id
      and r.consnotafiscal_id     = cnf.id
      and c.id                    = r.cfop_id
      and substr(c.cd, 1, 1)     in ('5', '6');
   --
   cursor c_dados5 is
      select distinct nfd.uf
        from nota_fiscal      nf
           , mod_fiscal       mf
           , sit_docto        sd
           , nfregist_analit  r
           , cfop             c
           , nota_fiscal_dest nfd
       where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
         and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
         and nf.dm_st_proc      = 4
         and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
         and mf.id              = nf.modfiscal_id
         and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
         and sd.id              = nf.sitdocto_id
         and sd.cd         not in ('02', '03') -- nada de cancelado
         and r.notafiscal_id    = nf.id
         and c.id               = r.cfop_id
         and substr(c.cd,1,1)  in ('5', '6')
         and nfd.notafiscal_id  = nf.id;
   --
   cursor c_dados6 is
      select distinct nfd.uf
        from nota_fiscal      nf
           , sit_docto        sd
           , mod_fiscal       mf
           , nfregist_analit  r
           , cfop             c
           , nota_fiscal_dest nfd
       where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
         and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
         and nf.dm_st_proc      = 4
         and nf.dm_ind_emit     = 0
         and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
               or
              (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
               or
              (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
         and sd.id              = nf.sitdocto_id
         and sd.cd             in ('00', '06', '08')
         and mf.id              = nf.modfiscal_id
         and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
         and nf.id              = nfd.notafiscal_id
         and r.notafiscal_id    = nf.id
         and c.id               = r.cfop_id
         and substr(c.cd,1,1)  in ('1', '2');
   --
   cursor c_dados7 is
      select distinct nfe.uf
        from nota_fiscal      nf
           , sit_docto        sd
           , mod_fiscal       mf
           , nfregist_analit  r
           , cfop             c
           , nota_fiscal_emit nfe
       where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
         and nf.dm_st_proc      = 4
         and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
         and nf.dm_ind_emit     = 1
         and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
         and sd.id              = nf.sitdocto_id
         and sd.cd             in ('00', '06', '08')
         and mf.id              = nf.modfiscal_id
         and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
         and nf.id              = nfe.notafiscal_id
         and r.notafiscal_id    = nf.id
         and c.id               = r.cfop_id
         and substr(c.cd,1,1)  in ('1', '2');
   --
   cursor c_dados8 is
      select distinct nfd.uf
        from nota_fiscal      nf
           , sit_docto        sd
           , mod_fiscal       mf
           , nfregist_analit  r
           , nota_fiscal_dest nfd
       where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
         and nf.dm_st_proc      = 4
         and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
         and nf.dm_ind_emit     = 0
         and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
               or
              (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
               or
              (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
         and sd.id              = nf.sitdocto_id
         and sd.cd             in ('01', '07')
         and mf.id              = nf.modfiscal_id
         and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
         and nf.id              = nfd.notafiscal_id
         and r.notafiscal_id    = nf.id;
   --
   cursor c_dados9 is
      select distinct nfe.uf
        from nota_fiscal      nf
           , sit_docto        sd
           , mod_fiscal       mf
           , nfregist_analit  r
           , nota_fiscal_emit nfe
       where nf.empresa_id      = gt_row_per_apur_icms_st.empresa_id
         and nf.dm_st_proc      = 4
         and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
         and nf.dm_ind_emit     = 1
         and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
         and sd.id              = nf.sitdocto_id
         and sd.cd             in ('01', '07')
         and mf.id              = nf.modfiscal_id
         and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
         and nf.id              = nfe.notafiscal_id
         and r.notafiscal_id    = nf.id;
   --
   cursor c_dados10 is
      select distinct nfd.uf
        from nota_fiscal            nf
           , sit_docto              sd
           , mod_fiscal             mf
           , nfinfor_fiscal         nfif
           , inf_prov_docto_fiscal  ipdf
           , cod_ocor_aj_icms       cod
           , nota_fiscal_dest       nfd
       where nf.empresa_id        = gt_row_per_apur_icms_st.empresa_id
         and nf.dm_st_proc        = 4
         and nf.dm_arm_nfe_terc   = 0 -- Não é nota de armazenamento fiscal
         and nf.dm_ind_emit       = 0
         and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
               or
              (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
               or
              (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
         and sd.id                = nf.sitdocto_id
         and sd.cd               in ('02', '03') -- cancelado
         and mf.id                = nf.modfiscal_id
         and mf.cod_mod          in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
         and nf.id                = nfd.notafiscal_id
         and nfif.notafiscal_id   = nf.id
         and ipdf.nfinforfisc_id  = nfif.id
         and cod.id               = ipdf.codocorajicms_id
         and cod.dm_reflexo_apur in (0, 1, 2)
         and cod.dm_tipo_apur    in (1); -- icms-st
   --
   cursor c_dados11 is
      select distinct nfe.uf
        from nota_fiscal            nf
           , sit_docto              sd
           , mod_fiscal             mf
           , nfinfor_fiscal         nfif
           , inf_prov_docto_fiscal  ipdf
           , cod_ocor_aj_icms       cod
           , nota_fiscal_emit       nfe
       where nf.empresa_id        = gt_row_per_apur_icms_st.empresa_id
         and nf.dm_st_proc        = 4
         and nf.dm_arm_nfe_terc   = 0 -- Não é nota de armazenamento fiscal
         and nf.dm_ind_emit       = 1
         and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
         and sd.id                = nf.sitdocto_id
         and sd.cd               in ('02', '03') -- cancelado
         and mf.id                = nf.modfiscal_id
         and mf.cod_mod          in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
         and nf.id                = nfe.notafiscal_id
         and nfif.notafiscal_id   = nf.id
         and ipdf.nfinforfisc_id  = nfif.id
         and cod.id               = ipdf.codocorajicms_id
         and cod.dm_reflexo_apur in (0, 1, 2)
         and cod.dm_tipo_apur    in (1); -- icms-st
   --
   cursor c_dados12 is
      select distinct nfd.uf
        from nota_fiscal            nf
           , sit_docto              sd
           , mod_fiscal             mf
           , nfinfor_fiscal         nfif
           , inf_prov_docto_fiscal  ipdf
           , cod_ocor_aj_icms       cod
           , nota_fiscal_dest       nfd
       where nf.empresa_id        = gt_row_per_apur_icms_st.empresa_id
         and nf.dm_st_proc        = 4
         and nf.dm_arm_nfe_terc   = 0 -- Não é nota de armazenamento fiscal
         and nf.dm_ind_emit       = 0
         and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
               or
              (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
               or
              (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
         and sd.id                = nf.sitdocto_id
         and sd.cd           not in ('02', '03', '01', '07') -- nada de cancelado, documentos extemporâneos e complementares extemporâneas
         and mf.id                = nf.modfiscal_id
         and mf.cod_mod          in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
         and nf.id                = nfd.notafiscal_id
         and nfif.notafiscal_id   = nf.id
         and ipdf.nfinforfisc_id  = nfif.id
         and cod.id               = ipdf.codocorajicms_id
         and cod.dm_reflexo_apur in (3, 4, 5)
         and cod.dm_tipo_apur    in (1); -- icms-st
   --
   cursor c_dados13 is
      select distinct nfe.uf
        from nota_fiscal            nf
           , sit_docto              sd
           , mod_fiscal             mf
           , nfinfor_fiscal         nfif
           , inf_prov_docto_fiscal  ipdf
           , cod_ocor_aj_icms       cod
           , nota_fiscal_emit       nfe
       where nf.empresa_id        = gt_row_per_apur_icms_st.empresa_id
         and nf.dm_st_proc        = 4
         and nf.dm_arm_nfe_terc   = 0 -- Não é nota de armazenamento fiscal
         and nf.dm_ind_emit       = 1
         and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
         and sd.id                = nf.sitdocto_id
         and sd.cd           not in ('02', '03', '01', '07') -- nada de cancelado, documentos extemporâneos e complementares extemporâneas
         and mf.id                = nf.modfiscal_id
         and mf.cod_mod          in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
         and nf.id                = nfe.notafiscal_id
         and nfif.notafiscal_id   = nf.id
         and ipdf.nfinforfisc_id  = nfif.id
         and cod.id               = ipdf.codocorajicms_id
         and cod.dm_reflexo_apur in (3, 4, 5)
         and cod.dm_tipo_apur    in (1); -- icms-st
   --
   cursor c_dados14 is
      select distinct nfd.uf
        from nota_fiscal            nf
           , sit_docto              sd
           , mod_fiscal             mf
           , nfinfor_fiscal         nfif
           , inf_prov_docto_fiscal  ipdf
           , cod_ocor_aj_icms       cod
           , nota_fiscal_dest       nfd
       where nf.empresa_id        = gt_row_per_apur_icms_st.empresa_id
         and nf.dm_st_proc        = 4
         and nf.dm_arm_nfe_terc   = 0 -- Não é nota de armazenamento fiscal
         and nf.dm_ind_emit       = 0
         and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
               or
              (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim))
               or
              (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)))
         and sd.id                = nf.sitdocto_id
         and sd.cd           not in ('02', '03') -- cancelado
         and mf.id                = nf.modfiscal_id
         and mf.cod_mod          in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
         and nf.id                = nfd.notafiscal_id
         and nfif.notafiscal_id   = nf.id
         and ipdf.nfinforfisc_id  = nfif.id
         and cod.id               = ipdf.codocorajicms_id
         and cod.dm_reflexo_apur in (6,7) -- Dedução, Débitos Especiais
         and cod.dm_tipo_apur    in (1); -- icms-st
   --
   cursor c_dados15 is
      select distinct nfe.uf
        from nota_fiscal            nf
           , sit_docto              sd
           , mod_fiscal             mf
           , nfinfor_fiscal         nfif
           , inf_prov_docto_fiscal  ipdf
           , cod_ocor_aj_icms       cod
           , nota_fiscal_emit       nfe
       where nf.empresa_id        = gt_row_per_apur_icms_st.empresa_id
         and nf.dm_st_proc        = 4
         and nf.dm_ind_emit       = 1
         and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_st.dt_inicio) and trunc(gt_row_per_apur_icms_st.dt_fim)
         and nf.dm_arm_nfe_terc   = 0 -- Não é nota de armazenamento fiscal
         and sd.id                = nf.sitdocto_id
         and sd.cd           not in ('02', '03') -- cancelado
         and mf.id                = nf.modfiscal_id
         and mf.cod_mod          in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
         and nf.id                = nfe.notafiscal_id
         and nfif.notafiscal_id   = nf.id
         and ipdf.nfinforfisc_id  = nfif.id
         and cod.id               = ipdf.codocorajicms_id
         and cod.dm_reflexo_apur in (6,7) -- Dedução, Débitos Especiais
         and cod.dm_tipo_apur    in (1);-- icms-st
   --
   cursor c_e200_ie is
   select es.sigla_estado uf
     from ie_subst iu
        , estado   es
    where iu.empresa_id = gt_row_per_apur_icms_st.empresa_id
      and es.id         = iu.estado_id;
   --
   procedure pkb_ins_apuracao_icms_st ( en_estado_id  in estado.id%type
                                      )
   is
      --
      vn_qtde      number := 0;
      --
   begin
      --
      if nvl(en_estado_id,0) > 0 then
         --
         begin
            select count(1)
              into vn_qtde
              from apuracao_icms_st ai
             where ai.estado_id        = en_estado_id
               and ai.perapuricmsst_id = gt_row_per_apur_icms_st.id;
         exception
            when others then
               vn_qtde := 0;
         end;
         --
         if nvl(vn_qtde,0) <= 0 then
            --
            insert into apuracao_icms_st ( id
                                         , estado_id
                                         , dm_situacao
                                         , dm_ind_mov_st
                                         , vl_saldo_cred_ant_st
                                         , vl_devol_st
                                         , vl_ressarc_st
                                         , vl_outro_cred_st
                                         , vl_aj_credito_st
                                         , vl_retencao_st
                                         , vl_out_deb_st
                                         , vl_ajust_deb_st
                                         , vl_saldo_dev_ant_st
                                         , vl_deducao_st
                                         , vl_icms_recol_st
                                         , vl_saldo_cred_st_transp
                                         , vl_deb_esp_st
                                         , perapuricmsst_id
                                         , vl_base_calc_icms_st
                                         )
                                  values ( apuracaoicmsst_seq.nextval
                                         , en_estado_id
                                         , 0 -- dm_situacao
                                         , 0 -- dm_ind_mov_st
                                         , 0 -- vl_saldo_cred_ant_st
                                         , 0 -- vl_devol_st
                                         , 0 -- vl_ressarc_st
                                         , 0 -- vl_outro_cred_st
                                         , 0 -- vl_aj_credito_st
                                         , 0 -- vl_retencao_st
                                         , 0 -- vl_out_deb_st
                                         , 0 -- vl_ajust_deb_st
                                         , 0 -- vl_saldo_dev_ant_st
                                         , 0 -- vl_deducao_st
                                         , 0 -- vl_icms_recol_st
                                         , 0 -- vl_saldo_cred_st_transp
                                         , 0 -- vl_deb_esp_st
                                         , gt_row_per_apur_icms_st.id -- perapuricmsst_id
                                         , 0 -- vl_base_calc_icms_st
                                         );
            --
         end if;
         --
         commit;
         --
      end if;
      --
   exception
      when others then
         raise_application_error ( -20101, 'Erro na pk_apur_icms_st.pkb_ins_apuracao_icms_st: '||sqlerrm );
   end pkb_ins_apuracao_icms_st;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_perapuricmsst_id,0) > 0 then
      --
      vn_fase := 2;
      -- recupera dados do período
      pkb_dados_per_apur_icms_st ( en_perapuricmsst_id => en_perapuricmsst_id );
      --
      vn_fase := 3;
      --
      if nvl(gt_row_per_apur_icms_st.id,0) > 0 then
         --
         vn_fase := 4;
         --
         gn_dm_dt_escr_dfepoe := pk_csf.fkg_dmdtescrdfepoe_empresa( en_empresa_id => gt_row_per_apur_icms_st.empresa_id );
         --
         vn_fase := 5;
         --| chama procedimento que gera o Registro C190 de Nota Fiscal
         pk_csf_api.pkb_gera_c190 ( en_empresa_id  => gt_row_per_apur_icms_st.empresa_id
                                  , ed_dt_ini      => gt_row_per_apur_icms_st.dt_inicio
                                  , ed_dt_fin      => gt_row_per_apur_icms_st.dt_fim
                                  );
         --
         vn_fase := 6;
         --
         for rec in c_dados1
         loop
            --
            exit when c_dados1%notfound or (c_dados1%notfound) is null;
            --
            vn_fase := 6.1;
            --
            pkb_ins_apuracao_icms_st ( en_estado_id  => rec.estado_id
                                     );
            --
         end loop;
         --
         vn_fase := 7;
         --
         for rec in c_dados2
         loop
            --
            exit when c_dados2%notfound or (c_dados2%notfound) is null;
            --
            vn_fase := 7.1;
            --
            pkb_ins_apuracao_icms_st ( en_estado_id  => rec.estado_id
                                     );
            --
         end loop;
         --
         vn_fase := 8;
         --
         for rec in c_dados3
         loop
            --
            exit when c_dados3%notfound or (c_dados3%notfound) is null;
            --
            vn_fase := 8.1;
            --
            pkb_ins_apuracao_icms_st ( en_estado_id  => rec.estado_id
                                     );
            --
         end loop;
         --
         vn_fase := 9;
         --
         for rec in c_dados4
         loop
            --
            exit when c_dados4%notfound or (c_dados4%notfound) is null;
            --
            vn_fase := 9.1;
            --
            pkb_ins_apuracao_icms_st ( en_estado_id  => rec.estado_id
                                     );
            --
         end loop;
         --
         vn_fase := 10;
         --
         for rec in c_dados5
         loop
            --
            exit when c_dados5%notfound or (c_dados5%notfound) is null;
            --
            vn_fase := 10.1;
            --
            vn_estado_id := pk_csf.fkg_Estado_id(rec.uf);
            --
            vn_fase := 10.2;
            --
            pkb_ins_apuracao_icms_st ( en_estado_id  => vn_estado_id
                                     );
            --
         end loop;
         --
         vn_fase := 11;
         --
         for rec in c_dados6
         loop
            --
            exit when c_dados6%notfound or (c_dados6%notfound) is null;
            --
            vn_fase := 11.1;
            --
            vn_estado_id := pk_csf.fkg_Estado_id(rec.uf);
            --
            vn_fase := 11.2;
            --
            pkb_ins_apuracao_icms_st ( en_estado_id  => vn_estado_id
                                     );
            --
         end loop;
         --
         vn_fase := 12;
         --
         for rec in c_dados7
         loop
            --
            exit when c_dados7%notfound or (c_dados7%notfound) is null;
            --
            vn_fase := 12.1;
            --
            vn_estado_id := pk_csf.fkg_Estado_id(rec.uf);
            --
            vn_fase := 12.2;
            --
            pkb_ins_apuracao_icms_st ( en_estado_id  => vn_estado_id
                                     );
            --
         end loop;
         --
         vn_fase := 13;
         --
         for rec in c_dados8
         loop
            --
            exit when c_dados8%notfound or (c_dados8%notfound) is null;
            --
            vn_fase := 13.1;
            --
            vn_estado_id := pk_csf.fkg_Estado_id(rec.uf);
            --
            vn_fase := 13.2;
            --
            pkb_ins_apuracao_icms_st ( en_estado_id  => vn_estado_id
                                     );
            --
         end loop;
         --
         vn_fase := 14;
         --
         for rec in c_dados9
         loop
            --
            exit when c_dados9%notfound or (c_dados9%notfound) is null;
            --
            vn_fase := 14.1;
            --
            vn_estado_id := pk_csf.fkg_Estado_id(rec.uf);
            --
            vn_fase := 14.2;
            --
            pkb_ins_apuracao_icms_st ( en_estado_id  => vn_estado_id
                                     );
            --
         end loop;
         --
         vn_fase := 15;
         --
         for rec in c_dados10
         loop
            --
            exit when c_dados10%notfound or (c_dados10%notfound) is null;
            --
            vn_fase := 15.1;
            --
            vn_estado_id := pk_csf.fkg_Estado_id(rec.uf);
            --
            vn_fase := 15.2;
            --
            pkb_ins_apuracao_icms_st ( en_estado_id  => vn_estado_id
                                     );
            --
         end loop;
         --
         vn_fase := 16;
         --
         for rec in c_dados11
         loop
            --
            exit when c_dados11%notfound or (c_dados11%notfound) is null;
            --
            vn_fase := 16.1;
            --
            vn_estado_id := pk_csf.fkg_Estado_id(rec.uf);
            --
            vn_fase := 16.2;
            --
            pkb_ins_apuracao_icms_st ( en_estado_id  => vn_estado_id
                                     );
            --
         end loop;
         --
         vn_fase := 17;
         --
         for rec in c_dados12
         loop
            --
            exit when c_dados12%notfound or (c_dados12%notfound) is null;
            --
            vn_fase := 17.1;
            --
            vn_estado_id := pk_csf.fkg_Estado_id(rec.uf);
            --
            vn_fase := 17.2;
            --
            pkb_ins_apuracao_icms_st ( en_estado_id  => vn_estado_id
                                     );
            --
         end loop;
         --
         vn_fase := 18;
         --
         for rec in c_dados13
         loop
            --
            exit when c_dados13%notfound or (c_dados13%notfound) is null;
            --
            vn_fase := 18.1;
            --
            vn_estado_id := pk_csf.fkg_Estado_id(rec.uf);
            --
            vn_fase := 18.2;
            --
            pkb_ins_apuracao_icms_st ( en_estado_id  => vn_estado_id
                                     );
            --
         end loop;
         --
         vn_fase := 19;
         --
         for rec in c_dados14
         loop
            --
            exit when c_dados14%notfound or (c_dados14%notfound) is null;
            --
            vn_fase := 19.1;
            --
            vn_estado_id := pk_csf.fkg_Estado_id(rec.uf);
            --
            vn_fase := 19.2;
            --
            pkb_ins_apuracao_icms_st ( en_estado_id  => vn_estado_id
                                     );
            --
         end loop;
         --
         vn_fase := 20;
         --
         for rec in c_dados15
         loop
            --
            exit when c_dados15%notfound or (c_dados15%notfound) is null;
            --
            vn_fase := 20.1;
            --
            vn_estado_id := pk_csf.fkg_Estado_id(rec.uf);
            --
            vn_fase := 20.2;
            --
            pkb_ins_apuracao_icms_st ( en_estado_id  => vn_estado_id
                                     );
            --
         end loop;
         --
         vn_fase := 21;
         --
         for rec in c_e200_ie
         loop
            --
            exit when c_e200_ie%notfound or (c_e200_ie%notfound) is null;
            --
            vn_fase := 21.1;
            --
            vn_estado_id := pk_csf.fkg_Estado_id(rec.uf);
            --
            vn_fase := 21.2;
            --
            pkb_ins_apuracao_icms_st ( en_estado_id  => vn_estado_id
                                     );
            --
         end loop;
         --
         vn_fase := 99;
         --
         commit;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms_st.pkb_gerar_estados fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_SISTEMA
                                          , en_referencia_id   => null
                                          , ev_obj_referencia  => null 
                                          );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_gerar_estados;

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-- Procedure para Geração da Guia de Pagamento de Imposto
procedure pkg_gera_guia_pgto (en_apuracaoicmsst_id  in apuracao_icms_st.id%type,
                              en_usuario_id         in neo_usuario.id%type)
is
   --       
   vn_fase              number := 0;       
   vt_csf_log_generico  dbms_sql.number_table;
   vn_guiapgtoimp_id    guia_pgto_imp.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   begin
      --
      select t.* 
        into gt_row_apuracao_icms_st  
      from APURACAO_ICMS_ST t
      where t.id = en_apuracaoicmsst_id;
      --
   exception
      when others then
         raise;
   end;
   --
   vn_fase := 1;
   --
   begin
      --
      select t.* 
        into gt_row_per_apur_icms_st
      from PER_APUR_ICMS_ST t
      where t.id = gt_row_apuracao_icms_st.perapuricmsst_id;
      --
   exception
      when others then
         raise;
   end;

   -- Geração das Guias do Imposto ICMS-ST ---
   for x in (
      select orai.id obrigrecapuricmsst_id, pai.empresa_id,  e.pessoa_id, pai.dt_inicio, pai.dt_fim,
             orai.dt_vencto_obrig dt_vencto, pai.dt_inicio dt_ref,
             orai.vl_orig_rec vl_rec,
             pdgi.dm_tipo, pdgi.dm_origem, pdgi.pessoa_id_sefaz, pdgi.tipoimp_id, pdgi.obs
         from APURACAO_ICMS_ST         ais,
              PER_APUR_ICMS_ST         pai,
              OBRIG_REC_APUR_ICMS_ST  orai,
              PARAM_GUIA_PGTO       pgp,
              PARAM_DET_GUIA_IMP   pdgi,
              EMPRESA                 e              
      where pai.id                  = ais.perapuricmsst_id
        and orai.apuracaoicmsst_id  = ais.id 
        and pgp.empresa_id          = pai.empresa_id      
        and pdgi.paramguiapgto_id   = pgp.id
        and pdgi.tipoimp_id         = pk_csf.fkg_Tipo_Imposto_id(2) -- ICMS-ST
        and e.id                    = pdgi.empresa_id_guia
        and ais.id                  = en_apuracaoicmsst_id
         )
   loop
   --
      vn_fase := 3.1;
      --
      -- Popula a Variável de Tabela -- 
      pk_csf_api_gpi.gt_row_guia_pgto_imp.id                       := null;                          
      pk_csf_api_gpi.gt_row_guia_pgto_imp.empresa_id               := x.empresa_id;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.usuario_id               := en_usuario_id;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_situacao              := 0;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.tipoimposto_id           := x.tipoimp_id;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.tiporetimp_id            := null;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.tiporetimpreceita_id     := null;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.pessoa_id                := x.pessoa_id;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_tipo                  := x.dm_tipo;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_origem                := x.dm_origem;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.nro_via_impressa         := 1;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_ref                   := x.dt_ref;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_vcto                  := x.dt_vencto;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_princ                 := x.vl_rec;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_multa                 := 0;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_juro                  := 0;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_outro                 := 0;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_total                 := x.vl_rec;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.obs                      := x.obs;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.pessoa_id_sefaz          := x.pessoa_id_sefaz;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.nro_tit_financ           := null;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_alteracao             := sysdate;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_ret_erp               := 0;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.id_erp                   := null;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.apuracaoicmsst_id        := en_apuracaoicmsst_id;
      --
      vn_fase := 3.2;
      --
      -- Chama a procedure de integração e finalização da guia
      pk_csf_api_pgto_imp_ret.pkb_finaliza_pgto_imp_ret(est_log_generico  => vt_csf_log_generico,
                                                        en_empresa_id     => x.empresa_id,
                                                        en_dt_ini         => x.dt_inicio,
                                                        en_dt_fim         => x.dt_fim,
                                                        sn_guiapgtoimp_id => vn_guiapgtoimp_id);
      --
      vn_fase := 3.3;
      --
      -- Trata se houve Erro na geração da Guia --
      if nvl(vt_csf_log_generico.count,0) > 0 then
         --
         vn_fase := 3.4;
         --
         update APURACAO_ICMS_ST
            set dm_situacao_guia = 2 -- Erro
         where id = en_apuracaoicmsst_id;
         --
      else
         --
         vn_fase := 3.5;
         --
         update APURACAO_ICMS_ST t
            set t.dm_situacao_guia  = 1 -- Guia Gerada
         where id = en_apuracaoicmsst_id;
         --
         vn_fase := 3.6;
         --
         update OBRIG_REC_APUR_ICMS_ST t
            set t.guiapgtoimp_id = vn_guiapgtoimp_id
         where t.id = x.obrigrecapuricmsst_id;
         --   
      end if;                                                           
      --
   end loop;   
   --
   commit;
   --
exception
   when others then
      --
      gv_resumo_log := 'Erro na pk_apur_icms_st.pkg_gera_guia_pgto fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                          , ev_mensagem       => gv_mensagem_log
                                          , ev_resumo         => gv_resumo_log
                                          , en_tipo_log       => erro_de_sistema
                                          , en_referencia_id  => gt_row_per_apur_icms_st.ID
                                          , ev_obj_referencia => gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo_log);
      --     
end pkg_gera_guia_pgto; 
--
-------------------------------------------------------------------------------------------------------
-- Procedure para Estorno da Guia de Pagamento de Imposto
procedure pkg_estorna_guia_pgto (en_apuracaoicmsst_id  in apuracao_icms_st.id%type)
is
   --
   vn_fase              number := 0;       
   vt_csf_log_generico  dbms_sql.number_table;
   --
begin
   --
   vn_fase := 1;
   --
   if gt_row_per_apur_icms_st.id is null then
      --
      begin
         --
         select t.* 
           into gt_row_apuracao_icms_st  
         from APURACAO_ICMS_ST t
         where t.id = en_apuracaoicmsst_id;
         --
      exception
         when others then
            raise;
      end;
      --
      vn_fase := 2;
      --
      begin
         --
         select t.* 
           into gt_row_per_apur_icms_st
         from PER_APUR_ICMS_ST t
         where t.id = gt_row_apuracao_icms_st.perapuricmsst_id;
         --
      exception
         when others then
            raise;
      end;
      --
   end if;
   --
   vn_fase := 3;
   --
   pk_csf_api_pgto_imp_ret.pkb_estorna_pgto_imp_ret(est_log_generico => vt_csf_log_generico,
                                                    en_empresa_id    => gt_row_per_apur_icms_st.empresa_id,
                                                    en_dt_ini        => gt_row_per_apur_icms_st.dt_inicio,
                                                    en_dt_fim        => gt_row_per_apur_icms_st.dt_fim,
                                                    en_pgtoimpret_id => null);
   --
   vn_fase := 4;
   --
  
   if nvl(vt_csf_log_generico.count,0) > 0 then
      --
      vn_fase := 4.1;
      --
      update APURACAO_ICMS_ST
         set dm_situacao_guia = 2 -- Erro
       where id = en_apuracaoicmsst_id;
      --
      update GUIA_PGTO_IMP t set
        t.dm_situacao = 2 -- Erro de Validação
      where t.apuracaoicmsst_id = en_apuracaoicmsst_id;
      --
   else
      --
      vn_fase := 4.2;
      --
      update APURACAO_ICMS_ST
         set dm_situacao_guia = 0 -- Guia Não Gerada
       where id = en_apuracaoicmsst_id;
      --
      update guia_pgto_imp t set
        t.dm_situacao = 3 -- Cancelado
      where t.aberturaefdpc_id = en_apuracaoicmsst_id;  
      --      
   end if;                                                           
   --  
   commit;
   --
exception
   when others then
      --
      gv_resumo_log := 'Erro na pk_gera_arq_efd_pc.pkg_estorna_guia_pgto fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                          , ev_mensagem       => gv_mensagem_log
                                          , ev_resumo         => gv_resumo_log
                                          , en_tipo_log       => erro_de_sistema
                                          , en_referencia_id  => gt_row_per_apur_icms_st.id
                                          , ev_obj_referencia => gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo_log);
      --                                                          
end pkg_estorna_guia_pgto; 
--
-------------------------------------------------------------------------------------------------------
end pk_apur_icms_st;
/
