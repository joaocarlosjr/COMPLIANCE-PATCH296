CREATE OR REPLACE PACKAGE BODY csf_own.pk_csf_ct IS

-------------------------------------------------------------------------------------------------------
-- Corpo do pacote de funções auxiliares para Conhecimento de Transporte
-------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
--| Procedure retorna o dm_ind_emit e o dm_legado do conhecimento da do Conhecimento de Transporte através do ID
----------------------------------------------------------------------------------------------------------------
procedure pkb_busca_dm_ind_emit ( en_conhectransp_id in  conhec_transp.id%type
                               , sn_dm_ind_emit     out conhec_transp.dm_ind_emit%type
                               , sn_dm_legado       out conhec_transp.dm_legado%type ) is
   --
   vn_dm_ind_emit  conhec_transp.dm_ind_emit%type;
   vn_dm_legado    conhec_transp.dm_legado%type;
   --
begin
   --
   if nvl(en_conhectransp_id,0) > 0 then
      --
      select ct.dm_ind_emit
           , ct.dm_legado
        into vn_dm_ind_emit
           , vn_dm_legado
        from conhec_transp ct
       where ct.id = en_conhectransp_id;
      --
   end if;
   --
exception
   when no_data_found then
      vn_dm_ind_emit := null;
      vn_dm_legado   := null;
   when others then
      raise_application_error(-20101, 'Erro na pkb_busca_dm_ind_emit:' || sqlerrm);
end pkb_busca_dm_ind_emit;
--
-------------------------------------------------------------------------------------------------------
--| Função retorna o id da empresa através do ID do Conhecimento de Transporte
-------------------------------------------------------------------------------------------------------
function fkg_busca_empresa_ct ( en_conhectransp_id in conhec_transp.id%type )
         return conhec_transp.empresa_id%type
is
   --
   vn_empresa_id  empresa.id%type := 0;
   --
begin
   --
   if nvl(en_conhectransp_id,0) > 0 then
      --
      select ct.empresa_id
        into vn_empresa_id
        from conhec_transp ct
       where ct.id = en_conhectransp_id;
      --
   end if;
   --
   return vn_empresa_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_busca_empresa_ct:' || sqlerrm);
end fkg_busca_empresa_ct;

-------------------------------------------------------------------------------------------------------
-- Função retorna o ID do Conhecimento de Transporte conforme chave UNIQUE
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_BUSCA_CONHECTRANSP_ID ( EN_EMPRESA_ID       IN EMPRESA.ID%TYPE
                                   , EV_COD_PART         IN PESSOA.COD_PART%TYPE
                                   , EV_COD_MOD          IN MOD_FISCAL.COD_MOD%TYPE
                                   , EV_SERIE            IN CONHEC_TRANSP.SERIE%TYPE
                                   , EV_SUBSERIE         IN CONHEC_TRANSP.SUBSERIE%TYPE
                                   , EN_NRO_CT           IN CONHEC_TRANSP.NRO_CT%TYPE
                                   , EN_DM_IND_OPER      IN CONHEC_TRANSP.DM_IND_OPER%TYPE
                                   , EN_DM_IND_EMIT      IN CONHEC_TRANSP.DM_IND_EMIT%TYPE
                                   , EN_DM_ARM_CTE_TERC  IN CONHEC_TRANSP.DM_ARM_CTE_TERC%TYPE
                                   )
         RETURN CONHEC_TRANSP.ID%TYPE IS
   --
   vn_conhectransp_id  conhec_transp.id%type;
   vn_pessoa_id        pessoa.id%type;
   vn_modfiscal_id     mod_fiscal.id%type;
   --
BEGIN
   --
   vn_pessoa_id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id => pk_csf.fkg_multorg_id_empresa ( en_empresa_id => en_empresa_id )
                                                 , ev_cod_part   => trim(ev_cod_part) );
   --
   vn_modfiscal_id := pk_csf.fkg_Mod_Fiscal_id ( ev_cod_mod => trim(ev_cod_mod) );
   --
   if en_dm_ind_emit = 1 then
      --
      select ct.id
        into vn_conhectransp_id
        from Conhec_Transp ct
       where ct.empresa_id      = en_empresa_id
         and ct.dm_ind_oper     = nvl(en_dm_ind_oper, ct.dm_ind_oper)
         and ct.modfiscal_id    = vn_modfiscal_id
         and ct.serie           = nvl(trim(ev_serie), ct.serie)
         and ct.nro_ct          = en_nro_ct
         and ct.dm_ind_emit     = en_dm_ind_emit
         and ct.dm_arm_cte_terc = nvl(en_dm_arm_cte_terc,0)
         and ct.pessoa_id       = vn_pessoa_id;
      --
   else
      --
      select ct.id
        into vn_conhectransp_id
        from Conhec_Transp ct
       where ct.empresa_id      = en_empresa_id
         and ct.dm_ind_oper     = nvl(en_dm_ind_oper, ct.dm_ind_oper)
         and ct.modfiscal_id    = vn_modfiscal_id
         and ct.serie           = nvl(trim(ev_serie), ct.serie)
         and ct.nro_ct          = en_nro_ct
         and ct.dm_ind_emit     = en_dm_ind_emit
         and ct.dm_arm_cte_terc = nvl(en_dm_arm_cte_terc,0);
      --
   end if;
   --
   return vn_conhectransp_id;
   --
EXCEPTION
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na pk_csf_ct.fkg_busca_conhectransp_id: '||sqlerrm);
END FKG_BUSCA_CONHECTRANSP_ID;

-------------------------------------------------------------------------------------------------------
-- Função retorna o DM_ST_PROC (Situação do Processo) do Conhecimento de Transporte
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_ST_PROC_CT ( EN_CONHECTRANSP_ID  IN CONHEC_TRANSP.ID%TYPE )
         RETURN CONHEC_TRANSP.DM_ST_PROC%TYPE IS
   --
   vn_dm_st_proc conhec_transp.dm_st_proc%type := -1;
   --
BEGIN
   --
   if nvl(en_conhectransp_id,0) > 0 then
      --
      select ct.dm_st_proc
        into vn_dm_st_proc
        from Conhec_Transp ct
       where ct.id = en_conhectransp_id;
      --
   end if;
   --
   return vn_dm_st_proc;
   --
EXCEPTION
   when no_data_found then
      return -1;
   when others then
      raise_application_error(-20101, 'Erro na pk_csf_ct.fkg_st_proc_ct: '||sqlerrm);
END FKG_ST_PROC_CT;
--
-- ==================================================================================================== --
-- Função retorna o DM_LEGADO (Integração informação de CTe Legado) do Conhecimento de Transporte
-- ==================================================================================================== --
function fkg_legado_ct ( en_conhectransp_id in conhec_transp.id%type ) return conhec_transp.dm_legado%type is
   --
   vn_dm_legado conhec_transp.dm_legado%type := -1;
   --
begin
   --
   if nvl(en_conhectransp_id,0) > 0 then
      --
      -- O campo dm_legado foi criado na tb como NULL, como o processo de integração de LEGADO(dm_legado=1)
      -- foi criado qdo já existia a integração do NÃO LEGADO, esse tratamento nvl foi incluído para não ter problema
      -- de integração com possíveis valores nulos enviados pelo dm_legado na view de conhec_transp
      select nvl(ct.dm_legado,0)
        into vn_dm_legado
        from Conhec_Transp ct
       where ct.id = en_conhectransp_id;
      --
   end if;
   --
   return vn_dm_legado;
   --
exception
   when no_data_found then
      return -1;
   when others then
      raise_application_error(-20101, 'Erro na pk_csf_ct.fkg_legado_ct: '||sqlerrm);
END fkg_legado_ct;
--
-------------------------------------------------------------------------------------------------------
-- Função retorna "1" se o conhecimento de transporte está inutilizado e "0" se não está
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_CT_INUTILIZA ( EN_EMPRESA_ID  IN EMPRESA.ID%TYPE
                          , EV_COD_MOD     IN MOD_FISCAL.COD_MOD%TYPE
                          , EN_SERIE       IN CONHEC_TRANSP.SERIE%TYPE
                          , EN_NRO_CT      IN CONHEC_TRANSP.NRO_CT%TYPE
                          )
         RETURN NUMBER IS
   --
   vn_retorno number := 0;
   vn_modfiscal_id mod_fiscal.id%type;
   --
BEGIN
   --
   vn_modfiscal_id := pk_csf.fkg_Mod_Fiscal_id ( ev_cod_mod => ev_cod_mod );
   --
   select count(1)
     into vn_retorno
     from inutiliza_conhec_transp  ict
    where ict.empresa_id   = en_empresa_id
      and ict.serie        = en_serie
      and en_nro_ct  between ict.nro_ini and ict.nro_fim
      and ict.dm_situacao  = 2
      and ict.modfiscal_id = vn_modfiscal_id;
   --
   if nvl(vn_retorno,0) > 0 then
      return 1;
   else
      return 0;
   end if;
   --
EXCEPTION
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na pk_csf_ct.fkg_ct_inutiliza: '||sqlerrm);
END FKG_CT_INUTILIZA;

-------------------------------------------------------------------------------------------------------
-- Função retorna "true" se a CT-e existe e "false" se não existe
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_EXISTE_CTE ( EN_CONHEC_TRANSP IN CONHEC_TRANSP.ID%TYPE )
         RETURN BOOLEAN IS
   --
   vn_lixo  number;
   --
BEGIN
   --
   select 1
     into vn_lixo
     from Conhec_Transp
    where id = en_conhec_transp;
   --
   return true;
   --
EXCEPTION
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na pk_csf_ct.fkg_existe_cte: '||sqlerrm);
END FKG_EXISTE_CTE;
--
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- Função retorna "true" se for uma CTe de emissão própria (Não Legado) já autorizada, cancelada, denegada ou inutulizada, não pode ser re-integrada
-- Para emissão própria LEGADO, sempre será integrada, por isso, não foi inserido o tratamento para dm_legado = 1
-----------------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION FKG_CTE_NAO_INTEGRAR ( EN_CONHECTRANSP_ID IN CONHEC_TRANSP.ID%TYPE )
         RETURN BOOLEAN IS
   --
   vn_ret number := 0;
   --
BEGIN
   --
   select 1 ret
     into vn_ret
     from conhec_transp cf
        , mod_fiscal    mf
    where cf.id                = en_conhectransp_id
      and cf.dm_ind_emit       = 0 -- Emissão Própria
      and mf.id                = cf.modfiscal_id
      and mf.cod_mod           in ('57','67') --Atualização CTe 3.0
      and nvl(cf.dm_legado,0)  = 0 -- Não Legado
      and ( cf.dm_st_proc in ( 4, 6, 7, 8 ) or (cf.dm_st_proc = 5 and cf.cod_msg = 204) );
   --
   return true;
   --
EXCEPTION
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na pk_csf_ct.fkg_cte_nao_integrar: '||sqlerrm);
END FKG_CTE_NAO_INTEGRAR;
--
-------------------------------------------------------------------------------------------------------
-- Função retorna identificação do Conhecimento de Transporte através do identificador
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_DADOS_CONHECTRANSP_ID ( EN_CONHECTRANSP_ID IN CONHEC_TRANSP.ID%TYPE )
         RETURN VARCHAR2 IS
   --
   vv_dados_ct varchar2(1000) := null;
   --
BEGIN
   --
   begin
      select 'Número: '||ct.nro_ct||' Série: '||ct.serie||' Subsérie: '||ct.subserie||' Modelo fiscal: '||mf.cod_mod
        into vv_dados_ct
        from mod_fiscal    mf
           , conhec_transp ct
       where ct.id = en_conhectransp_id
         and mf.id = ct.modfiscal_id;
   exception
      when others then
         vv_dados_ct := 'Conhecimento de Transporte não identificado.';
   end;
   --
   return (vv_dados_ct);
   --
EXCEPTION
   when others then
      raise_application_error(-20101, 'Erro na pk_csf_ct.fkg_dados_conhectransp_id: '||sqlerrm);
END FKG_DADOS_CONHECTRANSP_ID;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da NF referenciada do CTe

function fkg_ct_inf_nf_id ( en_conhectransp_id in conhec_transp.id%type
                          , ev_cod_mod_nf      in mod_fiscal.cod_mod%type
                          , ev_serie_nf        in ct_inf_nf.serie%type
                          , en_nro_nf          in ct_inf_nf.nro_nf%type
                          )
          return ct_inf_nf.id%type
is
   --
   vn_modfiscal_id   mod_fiscal.id%type;
   vn_ctinfnf_id     ct_inf_nf.id%type;
   --
begin
   --
   vn_modfiscal_id := pk_csf.fkg_Mod_Fiscal_id ( ev_cod_mod => trim(ev_cod_mod_nf) );
   --
   select id
     into vn_ctinfnf_id
     from ct_inf_nf
    where conhectransp_id = en_conhectransp_id
      and modfiscal_id    = vn_modfiscal_id
      and serie           = trim(ev_serie_nf)
      and nro_nf          = en_nro_nf;
   --
   return vn_ctinfnf_id;
   --
exception
   when others then
      return null;
end fkg_ct_inf_nf_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da INformação de Unidade de Transporte COnforme o CTe

function fkg_ct_inf_unid_transp_id ( en_conhectransp_id in conhec_transp.id%type
                                   , en_dm_tp_unid_transp in ct_inf_unid_transp.dm_tp_unid_transp%type
                                   , ev_ident_unid_transp in ct_inf_unid_transp.ident_unid_transp%type
                                   )
         return ct_inf_unid_transp.id%type
is
   --
   vn_ctinfunidtransp_id ct_inf_unid_transp.id%type;
   --
begin
   --
   select id
     into vn_ctinfunidtransp_id
     from ct_inf_unid_transp
    where conhectransp_id    = en_conhectransp_id
      and dm_tp_unid_transp  = en_dm_tp_unid_transp
      and ident_unid_transp  = trim(ev_ident_unid_transp);
   --
   return vn_ctinfunidtransp_id;
   --
exception
   when others then
      return null;
end fkg_ct_inf_unid_transp_id;

-------------------------------------------------------------------------------------------------------

-- Função Retona do ID da Unidade de Carga

function fkg_ct_inf_unid_carga_id ( en_conhectransp_id in conhec_transp.id%type
                                  , en_dm_tp_unid_carga in ct_inf_unid_carga.dm_tp_unid_carga%type
                                  , ev_ident_unid_carga in ct_inf_unid_carga.ident_unid_carga%type
                                  )
         return ct_inf_unid_carga.id%type
is
   --
   vn_ctinfunidcarga_id ct_inf_unid_carga.id%type;
   --
begin
   --
   select id
     into vn_ctinfunidcarga_id
     from ct_inf_unid_carga
    where conhectransp_id   = en_conhectransp_id
      and dm_tp_unid_carga  = en_dm_tp_unid_carga
      and ident_unid_carga  = trim(ev_ident_unid_carga);
   --
   return vn_ctinfunidcarga_id;
   --
exception
   when others then
      return null;
end fkg_ct_inf_unid_carga_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da NFe referenciada do CTe

function fkg_ct_inf_nfe_id ( en_conhectransp_id in conhec_transp.id%type
                           , ev_nro_chave_nfe   in ct_inf_nfe.nro_chave_nfe%type
                           )
          return ct_inf_nf.id%type
is
   --
   vn_ctinfnfe_id     ct_inf_nfe.id%type;
   --
begin
   --
   select id
     into vn_ctinfnfe_id
     from ct_inf_nfe
    where conhectransp_id  = en_conhectransp_id
      and nro_chave_nfe    = ev_nro_chave_nfe;
   --
   return vn_ctinfnfe_id;
   --
exception
   when others then
      return null;
end fkg_ct_inf_nfe_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID de OUtros Documentos referenciada do CTe

function fkg_ct_inf_outro_id ( en_conhectransp_id in conhec_transp.id%type
                             , ev_dm_tipo_doc     in ct_inf_outro.dm_tipo_doc%type
                             , ev_nro_docto       in ct_inf_outro.nro_docto%type
                             ) return ct_inf_nf.id%type
is
   --
   vn_ctinfoutro_id     ct_inf_outro.id%type;
   --
begin
   --
   select id
     into vn_ctinfoutro_id
     from ct_inf_outro
    where conhectransp_id  = en_conhectransp_id
      and dm_tipo_doc      = ev_dm_tipo_doc
      and nro_docto        = ev_nro_docto;
   --
   return vn_ctinfoutro_id;
   --
exception
   when others then
      return null;
end fkg_ct_inf_outro_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da ESTRUT_CTE desde que seja um GRUPO ou Elemento de Grupo

function fkg_estrutcte_id_grupo ( ev_campo in estrut_cte.campo%type )
         return estrut_cte.id%type
is
   --
   vn_estrutcte_id estrut_cte.id%type;
   --
begin
   --
   select id
     into vn_estrutcte_id
     from estrut_cte
    where upper(campo) = trim(upper(ev_campo))
      and dm_elemento in ('G', 'CG');
   --
   return vn_estrutcte_id;
   --
exception
   when others then
      return null;
end fkg_estrutcte_id_grupo;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da ESTRUT_CTE desde que seja um campo, conforme o grupo

function fkg_estrutcte_id_campo ( en_estrutcte_id  in estrut_cte.id%type
                                , ev_campo         in estrut_cte.campo%type
                                )
         return estrut_cte.id%type
is
   --
   vn_estrutcte_id estrut_cte.id%type;
   --
begin
   --
   select id
     into vn_estrutcte_id
     from estrut_cte
    where ar_estrutcte_id  = en_estrutcte_id
      and upper(campo)     = trim(upper(ev_campo));
   --
   return vn_estrutcte_id;
   --
exception
   when others then
      return null;
end fkg_estrutcte_id_campo;

-------------------------------------------------------------------------------------------------------

-- Função retorna o CAMPO da ESTRUT_CTE conforme o ID

function fkg_estrutcte_campo ( en_estrutcte_id  in estrut_cte.id%type )
         return estrut_cte.campo%type
is
   --
   vv_campo estrut_cte.campo%type;
   --
begin
   --
   select campo
     into vv_campo
     from estrut_cte
    where id = en_estrutcte_id;
   --
   return vv_campo;
   --
exception
   when others then
      return null;
end fkg_estrutcte_campo;

-------------------------------------------------------------------------------------------------------
-- Função retorna a chave de acesso de CTe de Armazenamento de Terceiro
function fkg_ret_chave_cte_arm_terc ( ev_cpf_cnpj_emit in varchar2
                                    , ev_serie         in conhec_transp.serie%type
                                    , en_nro_ct        in conhec_transp.nro_ct%type
                                    )
         return conhec_transp.nro_chave_cte%type
is
   --
   vv_nro_chave_cte conhec_transp.nro_chave_cte%type;
   --
begin
   --
   select ct.nro_chave_cte
     into vv_nro_chave_cte
     from conhec_transp ct
        , conhec_transp_emit cte
    where ct.dm_arm_cte_terc   = 1
      and ct.serie             = trim(ev_serie)
      and ct.nro_ct            = en_nro_ct
      and cte.conhectransp_id  = ct.id
      and cte.cnpj             = ev_cpf_cnpj_emit;
   --
   return vv_nro_chave_cte;
   --
exception
   when others then
      return null;
end fkg_ret_chave_cte_arm_terc;

-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
-- Procedimento que retorna os valores fiscais (ICMS/ICMS-ST/IPI) de um conhecimento de transporte
-------------------------------------------------------------------------------------------------------
procedure pkb_vlr_fiscal_ct ( en_ctreganal_id        in   ct_reg_anal.id%type
                            , sv_cod_st_icms         out  cod_st.cod_st%type
                            , sn_cfop                out  cfop.cd%type
                            , sn_aliq_icms           out  ct_reg_anal.aliq_icms%type
                            , sn_vl_opr              out  ct_reg_anal.vl_opr%type
                            , sn_vl_bc_icms          out  ct_reg_anal.vl_bc_icms%type
                            , sn_vl_icms             out  ct_reg_anal.vl_icms%type
                            , sn_vl_bc_isenta_icms   out  number
                            , sn_vl_bc_outra_icms    out  number
                            )
is
   --
   vn_fase                        number := 0;
   vn_dm_ind_emit                 conhec_transp.dm_ind_emit%type;
   vv_cod_st_icms                 cod_st.cod_st%type;
   vn_cfop                        cfop.cd%type;
   vn_aliq_icms                   ct_reg_anal.aliq_icms%type;
   vn_vl_opr                      ct_reg_anal.vl_opr%type;
   vn_vl_bc_icms                  ct_reg_anal.vl_bc_icms%type;
   vn_vl_icms                     ct_reg_anal.vl_icms%type;
   vn_perc_red_bc                 ct_reg_anal.vl_red_bc%type;
   vn_vl_red_bc                   ct_reg_anal.vl_red_bc%type;
   vn_vl_bc_isenta_icms           number(15,2) := 0;
   vn_vl_bc_outra_icms            number(15,2) := 0;
   vn_dif_vlr                     number(15,2) := 0;
   --
   vn_empresa_id                  nota_fiscal.empresa_id%type;
   vn_dm_sm_vii_import_vloper     param_efd_icms_ipi.dm_sm_vii_import_vloper%type;
   vn_dm_sm_vicms_import_vloper   param_efd_icms_ipi.dm_sm_vicms_import_vloper%type;
   vn_dm_sm_vpiscof_import_vloper param_efd_icms_ipi.dm_sm_vpiscof_import_vloper%type;
   vn_dm_sm_vicms_export_vloper   param_efd_icms_ipi.dm_sm_vicms_export_vloper%type;
   vn_dm_sm_vpiscof_export_vloper param_efd_icms_ipi.dm_sm_vpiscof_export_vloper%type;
   vn_dm_subtr_vl_icms_deson      param_efd_icms_ipi.dm_subtr_vl_icms_deson%type;
   vn_perc_base_calc              param_calc_base_icms.perc_base_calc%type;
   vn_perc_base_isenta            param_calc_base_icms.perc_base_isenta%type;
   vn_perc_base_outra             param_calc_base_icms.perc_base_outra%type; 
   vn_dm_utiliza_perc_red_nf      param_calc_base_icms.dm_utiliza_perc_red_nf%type;
   --
   vn_cfop_id                     cfop.id%type;
   vn_cod_st_id                   cod_st.id%type;
   vn_vl_bc_isenta_icms_orig      ct_reg_anal.vl_base_isenta%type := null;
   vn_vl_bc_outra_icms_orig       ct_reg_anal.vl_base_outro%type := null;
   vn_vl_dif_vc_bi                number(15,2) := 0;   -- Valor de diferença entre valor contabil e base isenta
   -- 
begin
   --
   vn_fase := 1;
   --
   if nvl(en_ctreganal_id,0) > 0 then
      --
      vn_fase := 2;
      --
      begin
         --
         select ct.dm_ind_emit
              , cst.cod_st
              , c.cd
              , ra.aliq_icms
              , ra.vl_opr
              , ra.vl_bc_icms
              , ra.vl_icms
              , ra.vl_red_bc
              , ct.empresa_id
              , ra.cfop_id
              , ra.codst_id
              , ra.vl_base_isenta
              , ra.vl_base_outro
           into vn_dm_ind_emit
              , vv_cod_st_icms
              , vn_cfop
              , vn_aliq_icms
              , vn_vl_opr
              , vn_vl_bc_icms
              , vn_vl_icms
              , vn_perc_red_bc
              , vn_empresa_id
              , vn_cfop_id
              , vn_cod_st_id
              , vn_vl_bc_isenta_icms_orig
              , vn_vl_bc_outra_icms_orig
           from ct_reg_anal    ra
              , conhec_transp  ct
              , cod_st         cst
              , cfop           c
          where ra.id          = en_ctreganal_id
            and ct.id          = ra.conhectransp_id
            and cst.id         = ra.codst_id
            and c.id           = ra.cfop_id;
         --
      exception
         when others then
            --
            vn_dm_ind_emit            := null;
            vv_cod_st_icms            := null;
            vn_cfop                   := null;
            vn_aliq_icms              := null;
            vn_vl_opr                 := null;
            vn_vl_bc_icms             := null;
            vn_vl_icms                := null;
            vn_perc_red_bc            := null;
            vn_empresa_id             := null;
            vn_cfop_id                := null;
            vn_cod_st_id              := null;
            vn_vl_bc_isenta_icms_orig := null;
            vn_vl_bc_outra_icms_orig  := null;
            --
      end;
      --
      -- Inicio -  parametros de DEPARA para calculo de bases  de ICMS:
      vn_dm_utiliza_perc_red_nf := null;
      vn_perc_base_calc         := 0;
      vn_perc_base_isenta       := 0;
      vn_perc_base_outra        := 0;
      --
      vn_fase := 2.1;
      --
      if pk_csf.fkg_empresa_dmformademb_icms ( en_empresa_id => vn_empresa_id ) = 0 then
         --
         -- Possibilidade de busca por parametros:
         --   1a. possibilidade (buscar com os 3 parametros de busca preenchidos)
         --   2a. possibilidade (buscar por CFOP + COD_ITEM)
         --   3a. possibilidade (buscar por CST + COD_ITEM)
         --   4a. possibilidade (buscar por COD_ITEM)
         -- As possibilidades de 1 à 4 , não foram contempladas neste processo por não haver item no CTe.
         --   5a. possibilidade (buscar por CFOP + CST)
         --
         vn_fase := 2.2;
         --
         begin
            --
            select pc.dm_utiliza_perc_red_nf
                 , pc.perc_base_calc
                 , pc.perc_base_isenta
                 , pc.perc_base_outra
              into vn_dm_utiliza_perc_red_nf
                 , vn_perc_base_calc
                 , vn_perc_base_isenta
                 , vn_perc_base_outra
            from param_calc_base_icms pc
            where pc.empresa_id  = vn_empresa_id
              and pc.dm_situacao = '1'
              and pc.cfop_id     = vn_cfop_id
              and pc.cod_st_id   = vn_cod_st_id
              and pc.item_id     is null;
              --
         exception
            when others then
               --
               vn_dm_utiliza_perc_red_nf := null;
               vn_perc_base_calc         := 0;
               vn_perc_base_isenta       := 0;
               vn_perc_base_outra        := 0;
               --
         end;
         --
         -- 6a. possibilidade (buscar por CFOP)
         --
         vn_fase := 2.3;
         --
         if vn_dm_utiliza_perc_red_nf is null then
            begin
               --
               select pc.dm_utiliza_perc_red_nf
                    , pc.perc_base_calc
                    , pc.perc_base_isenta
                    , pc.perc_base_outra
                 into vn_dm_utiliza_perc_red_nf
                    , vn_perc_base_calc
                    , vn_perc_base_isenta
                    , vn_perc_base_outra
               from param_calc_base_icms pc
               where empresa_id  = vn_empresa_id
                 and dm_situacao = '1'
                 and cfop_id     = vn_cfop_id
                 and cod_st_id   is null
                 and item_id     is null;
                 --
            exception
               when others then
                  --
                  vn_dm_utiliza_perc_red_nf := null;
                  vn_perc_base_calc         := 0;
                  vn_perc_base_isenta       := 0;
                  vn_perc_base_outra        := 0;
                  --
            end;
            --
         end if;
         --
         -- 7a. possibilidade (buscar por CST)
         --
         vn_fase := 2.4;
         --
         if vn_dm_utiliza_perc_red_nf is null then
            --
            begin
               select pc.dm_utiliza_perc_red_nf
                    , pc.perc_base_calc
                    , pc.perc_base_isenta
                    , pc.perc_base_outra
                 into vn_dm_utiliza_perc_red_nf
                    , vn_perc_base_calc
                    , vn_perc_base_isenta
                    , vn_perc_base_outra
               from param_calc_base_icms pc
               where pc.empresa_id  = vn_empresa_id
                 and pc.dm_situacao = '1'
                 and pc.cfop_id     is null
                 and pc.cod_st_id   = vn_cod_st_id
                 and pc.item_id     is null;
                 --
            exception
               when others then
                  --
                  vn_dm_utiliza_perc_red_nf := null;
                  vn_perc_base_calc         := 0;
                  vn_perc_base_isenta       := 0;
                  vn_perc_base_outra        := 0;
                  --
            end;
            --
         end if;
         --
         vn_fase := 2.5;
         --          
         if vn_dm_utiliza_perc_red_nf = 0 then
            --
            vn_fase := 2.6;
            --
            vn_vl_bc_isenta_icms := nvl(vn_vl_opr,0) * (vn_perc_base_isenta/100);
            vn_vl_bc_icms        := nvl(vn_vl_opr,0) * (vn_perc_base_calc/100);
            vn_vl_bc_outra_icms  := nvl(vn_vl_opr,0) * (vn_perc_base_outra/100);
           --
         elsif vn_dm_utiliza_perc_red_nf = 1 then
            --
            vn_fase:=2.7;
            --
            vn_vl_bc_isenta_icms := nvl(vn_vl_opr,0) * (nvl(vn_perc_red_bc,0)/100);
            vn_vl_dif_vc_bi      := nvl(vn_vl_opr,0) - vn_vl_bc_isenta_icms;
            vn_vl_bc_icms        := nvl(vn_vl_dif_vc_bi,0) * (vn_perc_base_calc/100);
            vn_vl_bc_outra_icms  := nvl(vn_vl_dif_vc_bi,0) * (vn_perc_base_outra/100);
            --
         end if;
         --
         -- Fim -  parametros de DEPARA para calculo de bases  de ICMS*/
         --
         vn_fase := 2.8;
         --
         if nvl(vn_perc_red_bc,0) <= 0 then -- não é percentual, é valor de redução de base, para ser utilizado no teste de CST 90 (abaixo)
            --
            vn_vl_red_bc := nvl(vn_vl_opr,0) - nvl(vn_vl_bc_icms,0);
         else
             vn_vl_red_bc := nvl(vn_perc_red_bc,0);
         end if;
         --
         if nvl(vn_vl_red_bc,0) < 0 then
            --
            vn_vl_red_bc := 0;
            --
         end if;
         --
         vn_fase := 3;
         --
         if vn_dm_utiliza_perc_red_nf is null then -- Será considerada somente se não houver parametrização na tabela param_calc_base_icms
            --| monta a logica para definição dos valores fiscais de ICMS conforme Código de Situação Tributária
            if vv_cod_st_icms = '00' then -- Tributada integralmente
               --
               vn_vl_bc_outra_icms := nvl(vn_vl_red_bc,0);
               --
            elsif vv_cod_st_icms = '10' then -- Tributada e com cobrança do ICMS por substituição tributária
               --
               if nvl(vn_dm_ind_emit,0) = 0 then -- Emissão Própria
                  --
                  vn_vl_bc_isenta_icms := nvl(vn_vl_red_bc,0);
                  --
               else
                  --
                  vn_vl_bc_outra_icms := nvl(vn_vl_red_bc,0);
                  --
               end if;
                 --
            elsif vv_cod_st_icms = '20' then -- Com redução de base de cálculo
               --
               vn_vl_bc_isenta_icms := nvl(vn_vl_red_bc,0);
               --
            elsif vv_cod_st_icms = '30' then -- Isenta ou não tributada e com cobrança do ICMS por substituição tributária
               --
               if nvl(vn_dm_ind_emit,0) = 0 then -- Emissão Própria
                  --
                  vn_vl_bc_isenta_icms := nvl(vn_vl_red_bc,0);
                  --
               else
                  --
                  vn_vl_bc_outra_icms := nvl(vn_vl_red_bc,0);
                  --
               end if;
               --
            elsif vv_cod_st_icms = '40' then -- Isenta
               --
               vn_vl_bc_isenta_icms := nvl(vn_vl_red_bc,0);
               --
            elsif vv_cod_st_icms = '41' then -- Não tributada
               --
               vn_vl_bc_isenta_icms := nvl(vn_vl_red_bc,0);
               --
            elsif vv_cod_st_icms = '50' then -- Suspensão
               --
               vn_vl_bc_outra_icms := nvl(vn_vl_red_bc,0);
               --
            elsif vv_cod_st_icms = '51' then -- Diferimento. A exigência do preenchimento das informações do ICMS diferido fica à critério de cada UF.
               --
               vn_vl_bc_outra_icms := nvl(vn_vl_red_bc,0);
               --
            elsif vv_cod_st_icms = '60' then -- ICMS cobrado anteriormente por substituição tributária
               --
               vn_vl_bc_outra_icms := nvl(vn_vl_red_bc,0);
               --
            elsif vv_cod_st_icms = '70' then -- Com redução de base de cálculo e cobrança do ICMS por substituição tributária
               --
               if nvl(vn_dm_ind_emit,0) = 0 then -- Emissão Própria
                  --
                  vn_vl_bc_isenta_icms := nvl(vn_vl_red_bc,0);
                  --
               else
                  --
                  vn_vl_bc_outra_icms := nvl(vn_vl_red_bc,0);
                  --
               end if;
               --
            elsif vv_cod_st_icms = '90' then -- Outros
               --
               if nvl(vn_perc_red_bc,0) > 0 then -- não é percentual, é valor de base de redução
                  --
                  vn_vl_bc_isenta_icms := nvl(vn_vl_red_bc,0);
                  -- Colocar na base outras a diferença com a base isenta.
                  vn_vl_bc_outra_icms := nvl(vn_vl_opr,0) - nvl(vn_vl_bc_isenta_icms,0);
                  --
               else
                  --
                  if nvl(vn_vl_bc_isenta_icms_orig,0) > 0 and
                     nvl(vn_vl_bc_outra_icms_orig,0) > 0 then
                     --
                     vn_vl_bc_isenta_icms:= nvl(vn_vl_bc_isenta_icms_orig,0);
                     vn_vl_bc_outra_icms := nvl(vn_vl_bc_outra_icms_orig,0);
                     --
                  else
                     --				      
                     vn_vl_bc_outra_icms := nvl(vn_vl_red_bc,0);
                     --
                  end if;					 
                  --
               end if;
               --                                                                                                                    
            end if;
            --
         else 
            --
            vn_vl_icms := vn_vl_bc_icms*(vn_aliq_icms/100);
            --
         end if; 
         --
      else
         -- 
         vn_vl_bc_isenta_icms:= nvl(vn_vl_bc_isenta_icms_orig,0);
         vn_vl_bc_outra_icms := nvl(vn_vl_bc_outra_icms_orig,0);
         --
      end if;
      --
      vn_fase := 4;
      --
      sv_cod_st_icms         := vv_cod_st_icms;
      sn_cfop                := vn_cfop;
      sn_aliq_icms           := vn_aliq_icms;
      sn_vl_opr              := vn_vl_opr;
      sn_vl_bc_icms          := vn_vl_bc_icms;
      sn_vl_icms             := vn_vl_icms;
      sn_vl_bc_isenta_icms   := vn_vl_bc_isenta_icms;
      sn_vl_bc_outra_icms    := vn_vl_bc_outra_icms;
      --
   end if;
   --
exception
   when others then
      null;
end pkb_vlr_fiscal_ct;
--
-- ================================================================================================ --
-- Function retorna se o dado de integração deve ser validado ou não
-- ================================================================================================ --
function fkg_ret_valid_integr ( en_conhectransp_id in conhec_transp.id%type
                              , en_dm_ind_emit     in conhec_transp.dm_ind_emit%type
                              , en_dm_legado       in conhec_transp.dm_legado%type
                              , en_dm_forma_emiss  in conhec_transp.dm_forma_emiss%type
                              , ev_campo           in varchar2 ) return number is
--
-- Valores de retorno:
-- 0 - Deu algum erro ao recuperar ou não encontrou regra
-- 1 - Valida
-- 2 - Não valida
--
-- DM_ST_PROC      - sem validação no momento
-- DM_IND_EMIT     - 1-Terceiros
-- DM_ARM_CTE_TERC - sem validação no momento
-- DM_LEGADO       - 1-Legado Autorizado / 2-Legado Denegado / 3-Legado Cancelado / 4-Legado Inutilizado
--
   --
   vv_existe         varchar2(100);
   vn_dm_ind_emit    conhec_transp.dm_ind_emit%type;
   vn_dm_legado      conhec_transp.dm_legado%type;
   vn_dm_forma_emiss conhec_transp.dm_forma_emiss%type;
   vn_retorno        number(1);
   --
begin
   -- Verifica se o campo existe na tabela
   begin
      select aa.column_name
        into vv_existe
        from all_tab_columns aa
       where aa.table_name         = 'CONHEC_TRANSP'
         and aa.owner              = 'CSF_OWN'
         and upper(aa.column_name) = upper(ev_campo);
   exception
      when no_data_found then
         vv_existe := null;
      when others then
         vv_existe := null;
   end;
   --
   -- Busca dados do conhecimento de transporte
   if nvl(en_conhectransp_id,0) > 0 then
      --
      begin
         select ct.dm_ind_emit
              , ct.dm_legado
              , ct.dm_forma_emiss
           into vn_dm_ind_emit
              , vn_dm_legado
              , vn_dm_forma_emiss
           from conhec_transp ct
          where ct.id = en_conhectransp_id;
      exception
         when no_data_found then
            vn_dm_ind_emit    := -1;
            vn_dm_legado      := -1;
            vn_dm_forma_emiss := -1;
         when others then
            vn_dm_ind_emit    := -1;
            vn_dm_legado      := -1;
            vn_dm_forma_emiss := -1;
      end;
      --
   else
      --
      vn_dm_ind_emit    := en_dm_ind_emit;
      vn_dm_legado      := en_dm_legado;
      vn_dm_forma_emiss := en_dm_forma_emiss;
      --
   end if;
   --
   if vv_existe is not null then
      --
      if vv_existe in ('NRO_CHAVE_CTE') then
         --
         -- Regra para não validação
         if nvl(vn_dm_ind_emit,-1) = 1 then
            --
            if nvl(vn_dm_forma_emiss,-1) = 8 then -- não valida forma de emissão 8
               --
               vn_retorno := 2;
               --
            else
               --
               vn_retorno := 1;
               --
            end if;
            --
         elsif nvl(vn_dm_ind_emit,-1) = 0 and nvl(vn_dm_legado,-1) in (1,2,3,4) then
            --
            if nvl(vn_dm_forma_emiss,-1) = 8 then -- não valida forma de emissão 8
               --
               vn_retorno := 2;
               --
            else
               --
               vn_retorno := 1;
               --
            end if;
            --
         else
            --
            vn_retorno := 1;
            --
         end if;
         --
      else
         --
         vn_retorno := 0;
         --
      end if;
      --
   else
      --
      vn_retorno := 0;
      --
   end if;
   --
   return vn_retorno;
   --
exception
   when others then
      return 0;
end fkg_ret_valid_integr;
--
-----------------------------------------------------------------------------------------------------
--Função retorna se Conhecimento Transporte foi submetido ao evento R-2010 do REINF ou não. 
--E se o Conhecimento de tranporte está no dm_st_proc igual à 7 (Exclusão) do evento R-2010 do Reinf.
-----------------------------------------------------------------------------------------------------
function fkg_existe_reinf_r2010_ct (en_conhectransp_id conhec_transp.id%type) return boolean
is
---
vn_dummy_ct     integer;
vn_dummy_r2010  integer;
vn_dummy_return integer;
---
begin
  ---
  vn_dummy_ct    :=0;
  vn_dummy_r2010 :=0;
  vn_dummy_return:=0;
  ---
  begin
    ---
    select distinct 1 into vn_dummy_ct
    from EFD_REINF_R2010_CTE ct
    where ct.conhectransp_id  = en_conhectransp_id;
    ---
  exception
     when no_data_found then
      vn_dummy_ct:=0; 
  end; 
  ---
  if vn_dummy_ct > 0 then
    ----
    begin
      ---
      select distinct 1 into vn_dummy_r2010 
      from efd_reinf_r2010 r, EFD_REINF_R2010_CTE ct
      where r.id               = ct.efdreinfr2010_id 
        and r.dm_st_proc       <> 7
        and ct.conhectransp_id = en_conhectransp_id;
      ---
    exception
       when no_data_found then
        vn_dummy_r2010:=0; 
    end;
    ----
  end if;
  ---
  vn_dummy_return:= vn_dummy_ct*vn_dummy_r2010;
  ---
  if vn_dummy_return = 0 then
    return false;
  else
    return true;
  end if;
  ---
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_reinf_r2010_ct: ' || sqlerrm);
end;
--
-----------------------------------------------------------------------------------------------------
--Função retorna se Conhecimento Transporte foi submetido ao evento R-2020 do REINF ou não. 
--E se o Conhecimento de tranporte está no dm_st_proc igual à 7 (Exclusão) do evento R-2020 do Reinf.
-----------------------------------------------------------------------------------------------------
function fkg_existe_reinf_r2020_ct (en_conhectransp_id conhec_transp.id%type) return boolean
is
---
vn_dummy_ct     integer;
vn_dummy_r2020  integer;
vn_dummy_return integer;
---
begin
  ---
  vn_dummy_ct    :=0;
  vn_dummy_r2020 :=0;
  vn_dummy_return:=0;
  ---
  begin
    ---
    select distinct 1 into vn_dummy_ct
    from EFD_REINF_R2020_CTE ct
    where ct.conhectransp_id  = en_conhectransp_id;
    ---
  exception
     when no_data_found then
      vn_dummy_ct:=0; 
  end; 
  ---
  if vn_dummy_ct > 0 then
    ----
    begin
      ---
      select distinct 1 into vn_dummy_r2020 
      from efd_reinf_r2020 r, EFD_REINF_R2020_CTE ct
      where r.id               = ct.efdreinfr2020_id 
        and r.dm_st_proc       <> 7
        and ct.conhectransp_id = en_conhectransp_id;
      ---
    exception
       when no_data_found then
        vn_dummy_r2020:=0; 
    end;
    ----
  end if;
  ---
  vn_dummy_return:= vn_dummy_ct*vn_dummy_r2020;
  ---
  if vn_dummy_return = 0 then
    return false;
  else
    return true;
  end if;
  ---
exception
   when no_data_found then
      return false;
   when others then
      raise_application_error(-20101, 'Erro na fkg_existe_reinf_r2020_ct: ' || sqlerrm);
end;
--
END PK_CSF_CT;
/
