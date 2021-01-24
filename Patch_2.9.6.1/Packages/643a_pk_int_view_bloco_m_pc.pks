create or replace package csf_own.pk_int_view_bloco_m_pc is
-------------------------------------------------------------------------------------------------------
-- Especificação do pacote de integração de Bloco M do EFD PC a partir de leitura de views
-------------------------------------------------------------------------------------------------------
--
-- Em 12/01/2021 - Eduardo Linden
-- Redmine #74610 - Registros M230 / M630
-- troca de rotinas de desprocessamento de pis para cofins.
-- Processo alterado: pkb_inf_adic_dif_pc
-- Patches 2.9.5.4 e 2.9.6.1 e Release 2.9.7  
--
-- Em 24/10/2019 - Eduardo Linden
-- Redmine #60371 - Processo Bloco M 
-- Resolver problema dos contadores do agendamento de integração que não registravam a quantidade de registros.
-- Fazer com que os registros M200/600 sejam desprocessados,calculados e validados após integração dos registros M230/630.
-- Os registros M300/700 passam a estar com status "Processados".
-- Processados Alterados: pkb_contr_pis_dif_per_ant, pkb_integr_contr_pis_difperant, pkb_contr_cofins_dif_per_ant, 
-- pkb_integr_contr_cof_difperant, prc_integr_inf_adic_dif_pis e prc_integr_inf_adic_dif_cofins, pkb_inf_adic_dif_pc
-- Processos criados: prc_conscontrpis_id_status, prc_conscontrcofins_id_status, pkb_calc_val_m200, pkb_calc_val_m600, 
-- pkb_validar_m300 e pkb_validar_m700
--
-- Em 03/09/2019 - Eduardo Linden
-- Redmine #58334 - Ajuste na rotina de integração do bloco M
-- Devido ao retorno da function pk_csf.fkg_empresa_id_cpf_cnpj, será colocado um if para que variavel
-- vn_empresa não fique nula.
-- Rotinas alteradas: pkb_inf_adic_dif_pc, pkb_contr_pis_dif_per_ant e pkb_contr_cofins_dif_per_ant
--
-- Em 14/08/2019 - Eduardo Linden
-- Redmine #57450 - Incluir integração para os Registros M300 e M700 (Aceco)
-- Criação da Interface dos registros M300 e M700 para o SPED EFD PC.
--
-- Em 19/07/2019 -  Eduardo Linden
-- Redmine #56478 - Desenvolvimento da Interface para o registro M230 - PIS e M630 - Cofins
-- Criação da Package para Integração dos registros M230 e M630 para o SPED EFD PC
--
-------------------------------------------------------------------------------------------------------
gt_row_inf_adic_dif_pis      inf_adic_dif_pis%rowtype;
gt_row_inf_adic_dif_cofins   inf_adic_dif_cofins%rowtype;   
--
gt_row_contr_pis_dif_per_ant CONTR_PIS_DIF_PER_ANT%rowtype;
gt_row_contr_cof_dif_per_ant CONTR_COFINS_DIF_PER_ANT%rowtype;
--
-------------------------------------------------------------------------------------------------------

-- Especificação de array
--| Informações da tabela VW_CSF_INF_ADIC_DIF_PC
   type tab_csf_inf_adic_dif_pc is record ( CNPJ_EMPR             VARCHAR2(14)
                                               ,DT_INI               DATE
                                               ,DT_FIN               DATE
                                               ,CD_CONTR_SOC_APUR_PC VARCHAR2(2)
                                               ,CNPJ                 VARCHAR2(14)
                                               ,VL_VEND              NUMBER(15,2)
                                               ,VL_NAO_RECEB         NUMBER(15,2)
                                               ,VL_CONT_DIF          NUMBER(15,2)
                                               ,VL_CRED_DIF          NUMBER(15,2)
                                               ,CD_TP_CRED_PC        VARCHAR2(3)
                                               ,DM_IND_PC            VARCHAR2(1)
                                             );
--
   type t_tab_csf_inf_adic_dif_pc is table of tab_csf_inf_adic_dif_pc index by binary_integer;
   vt_tab_csf_inf_adic_dif_pc   t_tab_csf_inf_adic_dif_pc;
--   
--| Informações da tabela VW_CSF_CONTR_PIS_DIF_PER_ANT

   type tab_csf_contr_pis_dif_per_ant is record (CNPJ_EMPR            VARCHAR2(14) 
                                                ,DT_INI               DATE
                                                ,DT_FIN               DATE
                                                ,CD_CONTR_SOC_APUR_PC VARCHAR2(2)
                                                ,VL_CONT_APUR_DIFER   NUMBER(15,2)
                                                ,DM_NAT_CRED_DESC     VARCHAR2(2)
                                                ,VL_CRED_DESC_DIFER   NUMBER(15,2)
                                                ,VL_CONT_DIFER_ANT    NUMBER(15,2)
                                                ,PER_APUR             NUMBER(6) 
                                                ,DT_RECEB             DATE                                               
                                                );
--
   type t_tab_csf_contr_pis_dif_pant is table of tab_csf_contr_pis_dif_per_ant index by binary_integer;
   vt_tab_csf_contr_pis_dif_pant   t_tab_csf_contr_pis_dif_pant;
--
--| Informações da tabela VW_CSF_CONTR_COF_DIF_PER_ANT 

   type tab_csf_contr_cof_dif_pant is record (CNPJ_EMPR            VARCHAR2(14) 
                                                    ,DT_INI               DATE
                                                    ,DT_FIN               DATE
                                                    ,CD_CONTR_SOC_APUR_PC VARCHAR2(2)
                                                    ,VL_CONT_APUR_DIFER   NUMBER(15,2)
                                                    ,DM_NAT_CRED_DESC     VARCHAR2(2)
                                                    ,VL_CRED_DESC_DIFER   NUMBER(15,2)
                                                    ,VL_CONT_DIFER_ANT    NUMBER(15,2)
                                                    ,PER_APUR             NUMBER(6) 
                                                    ,DT_RECEB             DATE                                               
                                                    );
--
   type t_tab_csf_contr_cof_dif_pant is table of tab_csf_contr_cof_dif_pant index by binary_integer;
   vt_tab_csf_contr_cof_dif_pant   t_tab_csf_contr_cof_dif_pant;
   
-------------------------------------------------------------------------------------------------------

   gv_sql             varchar2(4000) := null;
   gv_cpf_cnpj        varchar2(14)   := null;
   gd_dt_ini          date           := null;
   gd_dt_fin          date           := null;
   gd_dt_ult_fecha    fecha_fiscal_empresa.dt_ult_fecha%type;

-------------------------------------------------------------------------------------------------------

   gv_aspas           char(1)                  := null;
   gv_nome_dblink     empresa.nome_dblink%type := null;
   gv_owner_obj       empresa.owner_obj%type   := null;
   
--   GV_SIST_ORIG            sist_orig.sigla%type := null;

-------------------------------------------------------------------------------------------------------

-- Declaração de constantes

   erro_de_validacao       constant number := 1;
   erro_de_sistema         constant number := 2;
   informacao              constant number := 35;

-------------------------------------------------------------------------------------------------------
   gv_cd_obj             obj_integr.cd%type := '57' /*'50'*/;
   --
   gv_cabec_log          log_generico_ibmpc.mensagem%TYPE;
   --
   gv_mensagem_log       log_generico_ibmpc.mensagem%TYPE;
   --
   gv_resumo             log_generico_ibmpc.resumo%TYPE;
   --
   gn_processo_id        log_generico_ibmpc.processo_id%type := null;
   --
   gv_obj_referencia     log_generico_ibmpc.obj_referencia%type default null;
   --
   gn_referencia_id      log_generico_ibmpc.referencia_id%type := null;
   --
   gn_multorg_id         mult_org.id%type;
   --
   gv_formato_data       param_global_csf.valor%type := null;
   --
   gv_formato_dt_erp     empresa.formato_dt_erp%type := null;
   --
   gn_empresa_id         empresa.id%type;
   --
   -------------------------------------------------------------------
   --
   type tab_pis_m200 is record ( pis_id cons_contr_pis.id%type );
   --
   type t_tab_pis_m200 is table of tab_pis_m200 index by binary_integer;
   vt_tab_pis_m200 t_tab_pis_m200;
   --
   type tab_cofins_m600 is record ( cofins_id cons_contr_cofins.id%type );
   --
   type t_tab_cofins_m600 is table of tab_cofins_m600 index by binary_integer;
   vt_tab_cofins_m600 t_tab_cofins_m600;
   --
   type tab_pis_m300 is record ( pis_id contr_pis_dif_per_ant.id%type );
   --
   type t_tab_pis_m300 is table of tab_pis_m300 index by binary_integer;
   vt_tab_pis_m300 t_tab_pis_m300;
   --
   type tab_cofins_m700 is record ( cofins_id contr_cofins_dif_per_ant.id%type );
   --
   type t_tab_cofins_m700 is table of tab_cofins_m700 index by binary_integer;
   vt_tab_cofins_m700 t_tab_cofins_m700;
   --
----------------------------------------------------------------------------------------------------
-- Processo de integração por periodo e empresa
----------------------------------------------------------------------------------------------------
procedure pkb_integracao ( en_empresa_id  in number
                         , ed_dt_ini      in date
                         , ed_dt_fin      in date
                         );
----------------------------------------------------------------------------------------------------
-- Processo de integração por periodo
----------------------------------------------------------------------------------------------------
procedure pkb_integr_periodo_geral ( en_multorg_id in mult_org.id%type
                                   , ed_dt_ini     in date
                                   , ed_dt_fin     in date );
-------------------------------------------------------------------------------------------------------
end pk_int_view_bloco_m_pc;
/
