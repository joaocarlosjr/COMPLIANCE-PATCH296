create or replace package csf_own.pk_csf_api_calc_fiscal is
--------------------------------------------------------------------------------------------------------------------------------------------
-- Especificação do pacote da API para a Calculadora Fiscal
--
-- Em 19/11/2020   - Luis Marques - 2.9.5-4 / 2.9.6-1 / 2.9.7     -- atualizado em 15/01/2021
-- Redmine #73524  - Melhoria na Mensagem do Log de Calculo
-- Rotina Alterada - pkb_calc_retido - Inserida mensagem de aviso que se o participante tiver Regime especial de 
--                   tributação com tipo 7-Imune/Isenta o calculo não foi efetuado.
--
-- Em 05/01/2021   - Karina de Paula
-- Redmine #74840  - Base Imposto, Alíquota e Valor do Imposto
-- Rotina Alterada - pkb_integr_imp_itemsc e pkb_grava_impostos_orig => Alterada somente a descricao da acao do dominio dm_manter_bc_int
--                   pkb_integr_imp_itemsc => Alterado o select q recupera o perc_reduc, base, aliquota e valor imp p buscar do imposto da nf e
--                   incluido no campo memoria a regra de manter a base                      
--
-- Em 06/12/2020   - Karina de Paula
-- Redmine #72698  - Ajuste em calculodora impostos INSS e ISS Retidos
-- Rotina Alterada - pkb_integr_imp_itemsc   => Incluido campo dm_manter_bc_int e incluída verificacao do perc_reduc
--                   pkb_grava_impostos_orig => Inclusao dos campos perc_red_bc_icms_efet, bc_icms_efet, aliq_icms_efet, vl_icms_efet e dm_manter_bc_int
--                   pkb_grava_impostos_orig => Inclusao do campo dm_manter_bc_int
--
-- Em 06/10/2020   - Karina de Paula
-- Redmine #71923  - Regra de arredondamento de ISS na calculadora
-- Rotina Alterada - pkb_calc_iss => Criada a variável vv_dm_ind_regra e incluída a chamada da function fkg_dmindregra para verificar se arredonda ou trunca o valor do imposto
--
-- Em 01/10/2020 - Eduardo Linden
-- Redmine #71891 - Solicitação de Calculo não alimenta o campo "vlTotalNf"
-- Rotina Alterada - pkb_criar_total_sc => Mudança na forma para obter os valores de vl_total_item e vl_serv_nao_trib, afetando a vl_total_nf 
-- Liberado        - Release_2.9.6, Patch_2.9.4.5 e Patch_2.9.5.2
--
-- Em 20/08/2020   - Luis Marques - 2.9.5
-- Redmine #58588  - Alterar tamanho de campo NRO_NF
-- Rotina Alterada - pkb_integr_solic_calc - Colocado verificação que a quantidade de dígitos do numero da nota fiscal
--                   para NFC-e não pode ser maior que 9 dígitos.
--
-- Em 22/09/2020   - Karina de Paula
-- Redmine #71670  - Solicitação de Calculo não alimenta o campo "vlTotalNf"
-- Rotina Alterada - pkb_criar_total_sc => Alterada a linha (vt_total_solic_calc.vl_serv_nao_trib) para (nvl(vt_total_solic_calc.vl_serv_nao_trib,0))
--                   Não tinha tratamento para valor nulo 
-- Liberado        - Release_2.9.5, Patch_2.9.4.3 e Patch_2.9.3.6
--
-- Em 11/09/2020   - Karina de Paula
-- Redmine #71095  - Retornar código de tributação do municipio na solicitação de calculo
-- Rotina Alterada - pkb_recup_param_nat_oper e pkb_recup_param_cfop_tpimp => Incluída a variável vv_cod_trib_municipio para carregar o valor do campo
-- Liberado        - Release_2.9.5, Patch_2.9.4.3 e Patch_2.9.3.6
--
-- Em 03/08/2020   - Karina de Paula
-- Redmine #70043  - Alinhamento com o Gustavo a regra do parâmetro dm_ind_emit
-- Rotina Alterada - pkb_criar_total_sc => Será incluído no select "valores do item da solicitacao de calculo" a subtração do "Valor Total dos itens de serviços" quando o
--                   dm_ind_tot for igual a "1".
-- Liberado        - Release_2.9.5, Patch_2.9.4.2 e Patch_2.9.3.5
--
-- Em 10/07/2020   - Karina de Paula
-- Redmine #69394  - Calculadora Fiscal - Pedindo Cadastro de Incidência Tributária da Empresa
-- Rotina Alterada - pkb_calc_retido => Inclusão de nvl nas verificações en_dm_reg_trib_part, vn_valortipoparam_cd e vn_tipoimp_cd
-- Liberado        - Release_2.9.5, Patch_2.9.4.1 e Patch_2.9.3.4
--
-- Em 24/06/2020   - Karina de Paula
-- Redmine #68410  - Alterar calculadora
--         #68880  - Criar Parâmetros Imune ou Isento no Participante para usar na calculadora
-- Rotina Alterada - pkb_calc_retido => Inclusão da verificação vn_valortipoparam_cd e en_dm_reg_trib_part para Simples Nacional
--                 - pkb_recup_param_calc_ret_nop => Incluído novo parâmetro de entrada en_tipoimp_cd  e dm_calc_imp_sn
-- Liberado        - Release_2.9.4, Patch_2.9.3.3 e Patch_2.9.2.6
--
-- Em 18/06/2020   - Karina de Paula
-- Redmine #68730  - Solicitação de Calculo não Calcula
-- Rotina Alterada - pkb_executar_solic_calc => Alterada a ordem da chamada da pkb_excluir_dados_calc pq estava excluindo o log da verificação vn_inctrib_id
-- Liberado        - Release_2.9.4, Patch_2.9.3.3 e Patch_2.9.2.6
--
-- Em 18/05/2020        - Karina de Paula
-- Redmine #65379       - Calculadora não está considerando Natureza de Operação
-- Rotina Alterada      - pkb_calc_retido => Corrigida a passagem de parâmetro da pkb_recup_param_calc_ret_nop (Errado:en_dm_ind_emit => en_empresa_id)
-- Liberada nas versões - Release_2.9.4, Patch_2.9.3.2 e Patch_2.9.2.5
--
-- Em 14/05/2020        - Karina de Paula
-- Redmine #67086       - Melhoria no Relatório Comparativo de Impostos Calculadora Fiscal x Impostos Integrados
-- Rotina Alterada      - pkb_grava_impostos_orig => Incluído o parâmetro cd_lista_serv e no insert da imp_itemnf_orig
-- Liberado nas versões - Release_2.9.4, Patch_2.9.3.2 e Patch_2.9.2.5
--
-- Em 14/05/2020        - Karina de Paula
-- Redmine #65379       - Calculadora não está considerando Natureza de Operação
-- Rotina Alterada      - pkb_calc_iss => Corrigida a passagem de parâmetro da pkb_recup_param_calc_iss_nop (Errado:en_dm_ind_emit => en_empresa_id)
-- Liberada nas versões - Release_2.9.4, Patch_2.9.3.2 e Patch_2.9.2.5
--
-- Em 16/04/2020        - Karina de Paula
-- Redmine 66925        - Preenchimento campo COD_TRIB_MUNICIPIO
-- Rotina Alterada      - pkb_integr_item_solic_calc => Incluído o campo cod_trib_municipio no insert e update da tabela item_solic_calc
-- Liberada nas versões - Release_2.9.4, Patch_2.9.3.1 e Patch_2.9.2.4
--
-- Em 10/09/2019 - Luis Marques
-- Redmine #58698 - Inserção de novo campo no modBCST (Calculadora Fiscal)
-- Rotinas Alteradas: pkb_integr_paramcalcicmsstempr, pkb_integr_param_calc_icmsst - - Ajustado para aceitar 6 
--                    no campo 'dm_mod_base_calc_st'
--
-- Em 05/09/2019 - Luis Marques
-- Redmine #58373 - Feed - não está calculando o difal
-- Rotinas Alteradas: pkb_recup_param_part_icms_empr, pkb_calc_part_icms, pkb_recup_param_nat_oper, 
--                    pkb_recup_param_cfop_tpimp - incluido parametro orig nas leituras da tabela PARAM_ICMS_INTER_CF.
--
-- Em 30/07/2019 - Armando
-- Redmine #56899
-- Rotina Alterada: pkb_calc_iss --> alterando fase 1.9 alterado para true
--
-- Em 27/06/2019 - Allan
-- Redmine #55363 - ADEQUAR DOMINIO DM_MOT_DES_ICMS CONFORME NT2016_02
-- Rotina Alterada: pkb_integr_solic_calc =>  Adicionado: 90 na validação do campo DM_MOT_DES_ICMS_PART
--                
-- Em 21/01/2019 - Karina de Paula
-- Redmine #50486 - Código de tributação do municipio na Calculadora Fiscal
-- Rotina Alterada: pkb_integr_param_calc_iss -- pk_csf_calc_fiscal.fkg_paramcalciss_id incluído o parâmetro de entrada CODTRIBMUNICIPIO_ID
--
-- Em 10/01/2019 - Karina de Paula
-- Redmine #50344 - Processo para gerar os dados dos impostos originais
-- Rotina Criada: pkb_grava_impostos_orig
--
-- Em 13/12/2016 - Fábio Tavares
-- Redmine #26211 - feedback integração calc fiscal
--
-- Em 27/02/2018 - Karina de Paula
-- Redmine Defeito #39870 - CALCULO DE IPI ERRADO
-- Rotina Alterada: pkb_recup_param_nat_oper e pkb_recup_param_cfop_tpimp
-- Os objetos pkb_recup_param_nat_oper e pkb_recup_param_cfop_tpimp estão chamando a rotina pkb_retorna_vlr_imp_itemsc e passando no seu
-- parâmetro de entrada (en_soliccalc_id) o id vt_item_solic_calc.id que corresponde ao id do item da solicitação e não o id da solicitação.
-- Dentro do código do pkb_retorna_vlr_imp_itemsc ele passa esse parâmetro de entrada na chamada da rotina pkb_recup_dados_solic_calc que
-- recupera os dados da solicitação para carregar o array. Nesse momento não encontra pq o código passado era do item e não da solicitação.
--
-- Em 08/03/2018 - Karina de Paula
-- Redmine Funcionalidade #40295 - Calculo Utilizando NOP - Alteração do processo para incluir funcionalidade solicitada
-- Rotina Alterada: pkb_executar_solic_calc    => Incluído o parâmetro de entrada en_natoper_id na chamada da pkb_recup_param_cfop_tpimp
-- Rotina Alterada: pkb_recup_param_cfop_tpimp => Incluído o parâmetro de entrada en_natoper_id
-- -- pkb_calc_icms / pkb_calc_icmsst / pkb_calc_aliq_tipoimp_ncm / pkb_calc_iss / pkb_calc_retido
--
-- Em 27/06/2018 - Karina de Paula
-- Redmine RM Consultoria #43816 - Incidência de IPI na Base ICMS
-- pkb_integr_paramcalcicmsempr => Incluído valor 7 na verificação DM_CALC_CONS_FINAL 
--                                 Incluídos os todos os valores do domínio na mensagem gv_resumo_log
-- pkb_integr_solic_calc => Incluído valor 7 na verificação est_row_solic_calc.dm_cons_final
--
-- Em 10/09/2018 - Marcos Ferreira
-- Redmine #46754 - Incluir novo domínio - 'Não Incidência'
-- Solicitação: Incluir o nono domínio 'Não Incidência', na estrutura: 'NF_COMPL_SERV.DM_NAT_OPER'.
-- Alterações: Inclusão do do novo item do domínio 8 = 'Não Incidência'
-- Procedures Alteradas: pkb_integr_param_calc_iss / 
--
-- Em 27/06/2018 - Karina de Paula
-- Redmine 47449/48259 - Calculadora Fiscal não calcula ISS
-- Rotina Alterada: pkb_recup_param_nat_oper / pkb_recup_param_cfop_tpimp
--
--------------------------------------------------------------------------------------------------------------------------------------------
--
   gt_row_cfop_tipoimp            cfop_tipoimp%rowtype;
   gt_row_aliq_tipoimp_ncm        aliq_tipoimp_ncm%rowtype;
   gt_row_param_calc_icmsst       param_calc_icmsst%rowtype;
   gt_row_param_calc_icms         param_calc_icms%rowtype;
   gt_row_cfop_part_icms_estado   cfop_part_icms_estado%rowtype;
   gt_row_param_calc_iss          param_calc_iss%rowtype;
   gt_row_param_calc_retido       param_calc_retido%rowtype;
   gt_row_aliq_tipoimp_ncm_empr   aliq_tipoimp_ncm_empresa%rowtype;
   gt_row_param_calc_icmsst_empr  param_calc_icmsst_empr%rowtype;
   gt_row_param_calc_icms_empr    param_calc_icms_empr%rowtype;
   gt_row_param_icms_inter_cf     param_icms_inter_cf%rowtype;
   gt_row_solic_calc              solic_calc%rowtype;
   gt_row_item_solic_calc         item_solic_calc%rowtype;
   gt_row_imp_itemsc              imp_itemsc%rowtype;
   gt_row_total_solic_calc        total_solic_calc%rowtype;
   gt_row_sc_infor_adic           sc_infor_adic%rowtype;
   gt_row_part_icms_solic_calc    part_icms_solic_calc%rowtype;
   gt_row_log_generico_calcfiscal log_generico_calcfiscal%rowtype;

--
-------------------------------------------------------------------------------------------------------
-- Variaveis Globais

   gv_mensagem_log     log_generico_calcfiscal.mensagem%type;
   gv_resumo_log       log_generico_calcfiscal.resumo%type;
   gn_processo_id      log_generico_calcfiscal.processo_id%type := null;
   gv_obj_referencia   log_generico_calcfiscal.obj_referencia%type default 'SOLIC_CALC';
   gn_referencia_id    log_generico_calcfiscal.referencia_id%type := null;
   gv_cd_obj           obj_integr.cd%type := '26';
   gv_cabec_log        log_generico_calcfiscal.mensagem%TYPE;
   gn_tipo_integr      number := null;
--
-------------------------------------------------------------------------------------------------------
-- Declaração de constantes

   erro_de_validacao       constant number := 1;
   erro_de_sistema         constant number := 2;
   informacao              constant number := 35;
   info_calc_fiscal        constant number := 38;

--
-------------------------------------------------------------------------------------------------------
-- Procedimento de registro de log de erros na validação Calculo Fiscal
procedure pkb_log_generico ( sn_loggenericocalcfiscal_id  out  nocopy log_generico_calcfiscal.id%type
                           , ev_mensagem                  in          log_generico_calcfiscal.mensagem%type
                           , ev_resumo                    in          log_generico_calcfiscal.resumo%type
                           , en_tipo_log                  in          csf_tipo_log.cd_compat%type                 default 1
                           , en_referencia_id             in          log_generico_calcfiscal.referencia_id%type  default null
                           , ev_obj_referencia            in          log_generico_calcfiscal.obj_referencia%type default null
                           , en_empresa_id                in          empresa.id%type                             default null
                           , en_dm_impressa               in          log_generico_calcfiscal.dm_impressa%type    default 0
                           , en_processo_id               in          log_generico_calcfiscal.processo_id%type    default null
                           , en_dm_env_email              in          log_generico_calcfiscal.dm_env_email%type   default 0
                           );

-------------------------------------------------------------------------------------------------------

-- Procedimento armazena o valor do "loggenerico_id" do Calculo Fiscal
PROCEDURE pkb_gt_log_generico ( en_loggenericocalcfiscal_id in            log_generico_calcfiscal.id%type
                              , est_log_generico_calcfiscal in out nocopy dbms_sql.number_table
                              );

----------------------------------------------------------------------------------------------------

-- procedimento que finaliza log_locacao
procedure pkb_finaliza_log_generico;

-------------------------------------------------------------------------------------------------------

-- Procedimento de exclui os dados que são gerados, caso já existir
procedure pkb_excluir_dados_calc ( en_soliccalc_id            in  solic_calc.id%type
                                 );
--
-- ==================================================================================================================== --
-- Procedimento que verifica se a empresa está parametrizada para guardar os impostos originais
procedure pkb_grava_impostos_orig ( en_empresa_id         in empresa.id%type
                                  , en_soliccalc_id       in solic_calc.id%type
                                  , en_notafiscal_id      in nota_fiscal.id%type
                                  , en_nro_item           in item_nota_fiscal.nro_item%type
                                  , en_cod_item           in item_nota_fiscal.cod_item%type
                                  , en_cd_lista_serv      in item_nota_fiscal.cd_lista_serv%type
                                  , est_row_imp_itemnf_ii in out nocopy imp_itemnf%rowtype );
--
-- ==================================================================================================================== --
-- Procedimento que seta o objeto na variavel global
procedure pkb_seta_obj_ref ( ev_objeto in varchar2
                           );

----------------------------------------------------------------------------------------------------

-- Procedimento que seta o tipo de integração que será feito
procedure pkb_seta_tipo_integr ( en_tipo_integr in number
                               );

----------------------------------------------------------------------------------------------------

-- Procedimento que seta o tipo de integração que será feito
procedure pkb_seta_referencia_id ( en_id  in log_generico_dimob.referencia_id%type
                                 );

----------------------------------------------------------------------------------------------------
-- Procedimento que faz a integração da tabela de ICMS em Operações Interestaduais de Vendas a Consumidor Final
procedure pkb_integr_paramicmsintercf ( est_log_generico_calcfiscal in out nocopy dbms_sql.number_table
                                      , est_row_paramicmsintercf    in out nocopy PARAM_ICMS_INTER_CF%rowtype
                                      , en_empresa_id               in            empresa.id%type
                                      , ev_sigla_est                in            estado.sigla_estado%type
                                      , en_cd_cfop                  in            cfop.cd%type
                                      , ev_cd_ncm                   in            ncm.cod_ncm%type
                                      , ev_cod_item                 in            item.cod_item%type
                                      , en_loteintws_id             in            lote_int_ws.id%type default 0
                                      );

----------------------------------------------------------------------------------------------------
-- Procedimento que faz a integração da tabela de Parametros de Calculo de ICMS      
procedure pkb_integr_paramcalcicmsempr (  est_log_generico_calcfiscal  in out nocopy dbms_sql.number_table
                                       , est_row_paramcalcicmsempr     in out nocopy param_calc_icms_empr%rowtype
                                       , en_empresa_id                 in            empresa.id%type
                                       , en_cd_cfop                    in            cfop.cd%type
                                       , ev_cfop_dest                  in            cfop.cd%type
                                       , ev_sigla_est_dest             in            estado.sigla_estado%type
                                       , ev_cd_ex_tipi                 in            ex_tipi.cod_ex_tipi%type
                                       , ev_cod_item                   in            item.cod_item%type
                                       , ev_cd_codnat                  in            nat_oper.cod_nat%type
                                       , ev_cod_st                     in            cod_st.cod_st%type
                                       , ev_cod_of                     in            obs_fiscal.cod_of%type
                                       , ev_cd_ncm                     in            ncm.cod_ncm%type
                                       , en_loteintws_id               in            lote_int_ws.id%type default 0
                                       );

----------------------------------------------------------------------------------------------------
-- Procedimento que faz a integração da tabela de Parametros de Calculo de ICMS ST
procedure pkb_integr_paramcalcicmsstempr ( est_log_generico_calcfiscal   in out nocopy dbms_sql.number_table
                                         , est_row_paramcalcicmsstempr   in out nocopy param_calc_icmsst_empr%rowtype
                                         , en_empresa_id                 in            empresa.id%type
                                         , en_cd_cfop                    in            cfop.cd%type
                                         , ev_sigla_est_dest             in            estado.sigla_estado%type
                                         , ev_cd_cest                    in            cest.cd%type
                                         , ev_cd_ncm                     in            ncm.cod_ncm%type
                                         , ev_cd_ex_tipi                 in            ex_tipi.cod_ex_tipi%type
                                         , ev_cod_item                   in            item.cod_item%type
                                         , ev_cod_nat                    in            nat_oper.cod_nat%type
                                         , ev_cod_st                     in            cod_st.cod_st%type
                                         , ev_cod_of                     in            obs_fiscal.cod_of%type
                                         , en_loteintws_id               in            lote_int_ws.id%type default 0
                                         );

----------------------------------------------------------------------------------------------------
-- Procedimento que faz a integração da tabela de Aliquota do Imposto por NCM: Tratar IPI, PIS e COFINS nivel Global
procedure pkb_integr_aliqtipoimpncmempre ( est_log_generico_calcfiscal   in out nocopy dbms_sql.number_table
                                         , est_row_aliqtipoimpncmempre   in out nocopy ALIQ_TIPOIMP_NCM_EMPRESA%rowtype
                                         , en_empresa_id                 in            empresa.id%type
                                         , en_cd_tipoimposto             in            tipo_imposto.cd%type
                                         , en_cd_cfop                    in            cfop.cd%type
                                         , ev_cd_ncm                     in            varchar
                                         , ev_cd_ex_tipi                 in            varchar--ex_tipi.cod_ex_tipi%type
                                         , ev_cod_item                   in            varchar--item.cod_item%type
                                         , ev_cod_nat                    in            varchar--nat_oper.cod_nat%type
                                         , ev_cpf_cnpj                   in            varchar--varchar2
                                         , ev_cod_st                     in            varchar--nat_oper.cod_nat%type
                                         , ev_cod_of                     in            varchar--obs_fiscal.cod_of%type
                                         , ev_cd_cl_enq_ipi              in            varchar--classe_enq_ipi.id%type
                                         , ev_cod_selo_ipi               in            varchar--SELO_CONTR_IPI.COD_SELO_IPI%type
                                         , ev_cd_enqlegalipi             in            varchar--enq_legal_ipi.cd%type
                                         , en_loteintws_id               in            lote_int_ws.id%type default 0
                                         );

----------------------------------------------------------------------------------------------------
-- Procedimento que faz a integração da tabela de Parametro de Calculo de Retido nivel global
procedure pkb_integr_param_calc_retido ( est_log_generico_calcfiscal   in out nocopy dbms_sql.number_table
                                       , est_row_param_calc_retido     in out nocopy param_calc_retido%rowtype
                                       , en_empresa_id                 in            empresa.id%type
                                       , en_cd_cfop                    in            cfop.cd%type
                                       , en_cd_reg_trib                in            reg_trib.cd%type
                                       , en_cd_forma_trib              in            forma_trib.cd%type
                                       , ev_cd_cnae                    in            cnae.cd%type
                                       , ev_cod_of                     in            obs_fiscal.cod_of%type
                                       , ev_cd_lista_serv              in            tipo_servico.COD_LST%type
                                       , en_cd_tipoimposto             in            tipo_imposto.cd%type
                                       , en_loteintws_id               in            lote_int_ws.id%type default 0
                                       );

----------------------------------------------------------------------------------------------------
-- Procedimento que faz a integração da tabela de Calculo de ISS
procedure pkb_integr_param_calc_iss ( est_log_generico_calcfiscal   in out nocopy dbms_sql.number_table
                                    , est_row_param_calc_iss        in out nocopy param_calc_iss%rowtype
                                    , en_empresa_id                 in            empresa.id%type
                                    , ev_ibge_cidade                in            cidade.ibge_cidade%type
                                    , en_cd_cfop                    in            cfop.cd%type
                                    , en_cd_reg_trib                in            reg_trib.cd%type
                                    , en_cd_forma_trib              in            forma_trib.cd%type
                                    , ev_cd_cnae                    in            cnae.cd%type
                                    , ev_cod_trib_municipio         in            cod_trib_municipio.cod_trib_municipio%type
                                    , ev_cod_lst                    in            tipo_servico.cod_lst%type
                                    , ev_cod_of                     in            obs_fiscal.cod_of%type
                                    , en_loteintws_id               in            lote_int_ws.id%type default 0
                                    );

----------------------------------------------------------------------------------------------------
-- Procedimento que faz a integração da tabela de Partilha de ICMS entre Estados
procedure pkb_integr_cfopparticmsestado ( est_log_generico_calcfiscal   in out nocopy dbms_sql.number_table
                                        , est_row_cfop_part_icms_estado in out nocopy cfop_part_icms_estado%rowtype
                                        , en_empresa_id                 in            empresa.id%type
                                        , ev_sigla_est_orig             in            estado.sigla_estado%type
                                        , ev_sigla_est_dest             in            estado.sigla_estado%type
                                        , en_cd_cfop                    in            cfop.cd%type
                                        , ev_cd_ncm                     in            ncm.cod_ncm%type
                                        , en_loteintws_id               in            lote_int_ws.id%type default 0
                                        );

----------------------------------------------------------------------------------------------------
-- Procedimento que faz a integração da tabela de Parametros de Calculo de ICMS
procedure pkb_integr_param_calc_icms ( est_log_generico_calcfiscal   in out nocopy dbms_sql.number_table
                                     , est_row_param_calc_icms       in out nocopy param_calc_icms%rowtype
                                     , en_empresa_id                 in            empresa.id%type
                                     , en_cd_cfop                    in            cfop.cd%type
                                     , en_cd_reg_trib                in            reg_trib.cd%type
                                     , en_cd_forma_trib              in            forma_trib.cd%type
                                     , ev_sigla_est_orig             in            estado.sigla_estado%type
                                     , ev_sigla_est_dest             in            estado.sigla_estado%type
                                     , ev_cd_ncm                     in            ncm.cod_ncm%type
                                     , ev_cd_ex_tipi                 in            ex_tipi.cod_ex_tipi%type
                                     , ev_cod_st                     in            cod_st.cod_st%type
                                     , ev_cod_of                     in            obs_fiscal.cod_of%type
                                     , ev_cd_cnae                    in            cnae.cd%type
                                     , en_loteintws_id               in            lote_int_ws.id%type default 0
                                     );

----------------------------------------------------------------------------------------------------
-- Procedimento que faz a integração da tabela de Parametros de Calculo de ICMS ST
procedure pkb_integr_param_calc_icmsst ( est_log_generico_calcfiscal   in out nocopy dbms_sql.number_table
                                       , est_row_param_calc_icmsst     in out nocopy param_calc_icmsst%rowtype
                                       , en_empresa_id                 in            empresa.id%type
                                       , en_cd_cfop                    in            cfop.cd%type
                                       , en_cd_reg_trib                in            reg_trib.cd%type
                                       , en_cd_forma_trib              in            forma_trib.cd%type
                                       , ev_sigla_est_orig             in            estado.sigla_estado%type
                                       , ev_sigla_est_dest             in            estado.sigla_estado%type
                                       , ev_cd_cnae                    in            cnae.cd%type
                                       , ev_cd_cest                    in            cest.cd%type
                                       , ev_cd_ncm                     in            ncm.cod_ncm%type
                                       , ev_cd_ex_tipi                 in            ex_tipi.cod_ex_tipi%type
                                       , ev_cod_st                     in            cod_st.cod_st%type
                                       , ev_cod_of                     in            obs_fiscal.cod_of%type
                                       , en_loteintws_id               in            lote_int_ws.id%type default 0
                                       );

----------------------------------------------------------------------------------------------------
-- Procedimento que faz a integração da tabela de Aliquota do Imposto por NCM: Tratar IPI, PIS e COFINS
procedure pkb_integr_aliq_tipoimp_ncm ( est_log_generico_calcfiscal   in out nocopy dbms_sql.number_table
                                      , est_row_aliq_tipoimp_ncm      in out nocopy aliq_tipoimp_ncm%rowtype
                                      , en_empresa_id                 in            empresa.id%type
                                      , en_cd_tipoimposto             in            tipo_imposto.cd%type
                                      , en_cd_inc_trib                in            inc_trib.cd%type
                                      , en_cd_reg_trib                in            reg_trib.cd%type
                                      , en_cd_forma_trib              in            forma_trib.cd%type
                                      , ev_cd_cnae                    in            cnae.cd%type
                                      , en_cd_cfop                    in            cfop.cd%type
                                      , ev_cd_ncm                     in            ncm.cod_ncm%type
                                      , ev_cd_ex_tipi                 in            ex_tipi.cod_ex_tipi%type
                                      , ev_cl_enq                     in            classe_enq_ipi.cl_enq%type
                                      , ev_cod_selo_ipi               in            selo_contr_ipi.cod_selo_ipi%type
                                      , ev_cod_st                     in            cod_st.cod_st%type
                                      , ev_cod_of                     in            obs_fiscal.cod_of%type
                                      , en_loteintws_id               in            lote_int_ws.id%type default 0
                                      );

-------------------------------------------------------------------------------------------------------
-- Procedimento que faz a integração da Tabela de CFOP por Tipo de Imposto
procedure pkb_integr_cfop_tipoimp ( est_log_generico_calcfiscal   in out nocopy  dbms_sql.number_table
                                  , est_row_cfop_tipoimp          in out nocopy  cfop_tipoimp%rowtype
                                  , en_empresa_id                 in             empresa.id%type
                                  , en_cfop_cd                    in             cfop.cd%type
                                  , en_cd_reg_trib                in             reg_trib.cd%type
                                  , en_cd_forma_trib              in             forma_trib.cd%type
                                  , en_cd_tipoimp                 in             tipo_imposto.cd%type
                                  , ev_cod_st                     in             cod_st.cod_st%type
                                  , ev_cod_of                     in             obs_fiscal.cod_of%type
                                  , ev_cfop_cd_ret                in             cfop.cd%type
                                  , en_loteintws_id               in             lote_int_ws.id%type default 0
                                  );

-------------------------------------------------------------------------------------------------------

-- Procedimento que faz a validação e gravação dos dados na tabela SC_INFOR_ADIC
procedure pkb_integr_sc_infor_adic ( est_log_generico_calcfiscal   in out nocopy  dbms_sql.number_table
                                   , est_row_sc_infor_adic         in out nocopy  sc_infor_adic%rowtype
                                   , en_empresa_id                 in             empresa.id%type
                                   , ev_cod_of                     in             obs_fiscal.cod_of%type
                                   );

-------------------------------------------------------------------------------------------------------

-- Procedimento que faz a validação e gravação dos dados na tabela TOTAL_SOLIC_CALC
procedure pkb_integr_total_solic_calc ( est_log_generico_calcfiscal   in out nocopy  dbms_sql.number_table
                                      , est_row_total_solic_calc      in out nocopy  total_solic_calc%rowtype
                                      , en_empresa_id                 in             empresa.id%type
                                      );

-------------------------------------------------------------------------------------------------------

-- Procedimento que faz a validação e gravação dos dados na tabela IMP_ITEMSC
procedure pkb_integr_imp_itemsc ( est_log_generico_calcfiscal   in out nocopy  dbms_sql.number_table
                                , est_row_imp_itemsc            in out nocopy  imp_itemsc%rowtype
                                , en_empresa_id                 in             empresa.id%type
                                , en_soliccalc_id               in             solic_calc.id%type
                                , en_tipoimp_cd                 in             tipo_imposto.cd%type
                                , ev_cod_st                     in             cod_st.cod_st%type
                                , ev_descr_item                 in             varchar2
                                );

-------------------------------------------------------------------------------------------------------

-- Procedimento que faz a validação e gravação dos dados na tabela PART_ICMS_SOLIC_CALC
procedure pkb_integr_part_icms_sc ( est_log_generico_calcfiscal   in out nocopy  dbms_sql.number_table
                                  , est_row_part_icms_solic_calc  in out nocopy  part_icms_solic_calc%rowtype
                                  , en_empresa_id                 in             empresa.id%type
                                  , en_soliccalc_id               in             solic_calc.id%type
                                  , ev_descr_item                 in             varchar2
                                  );

-------------------------------------------------------------------------------------------------------

-- Procedimento que faz a validação e gravação dos dados na tabela ITEM_SOLIC_CALC
procedure pkb_integr_logcalcfiscal ( est_log_generico_calcfiscal   in out nocopy  dbms_sql.number_table
                                   , est_row_loggenericocalcfiscal in out nocopy  log_generico_calcfiscal%rowtype
                                   , en_empresa_id                 in             empresa.id%type
                                   );

-------------------------------------------------------------------------------------------------------

-- Procedimento que faz a validação e gravação dos dados na tabela ITEM_SOLIC_CALC
procedure pkb_integr_item_solic_calc ( est_log_generico_calcfiscal   in out nocopy  dbms_sql.number_table
                                     , est_row_item_solic_calc       in out nocopy  item_solic_calc%rowtype
                                     , en_empresa_id                 in             empresa.id%type
                                     );

-------------------------------------------------------------------------------------------------------

-- Procedimento que faz a validação e gravação dos dados na tabela SOLIC_CALC
procedure pkb_integr_solic_calc ( est_log_generico_calcfiscal   in out nocopy  dbms_sql.number_table
                                , est_row_solic_calc            in out nocopy  solic_calc%rowtype
                                , ev_cod_nat                    in             nat_oper.cod_nat%type
                                , ev_cod_mod                    in             mod_fiscal.cod_mod%type
                                , ev_sigla_estado_part          in             estado.sigla_estado%type
                                );

-------------------------------------------------------------------------------------------------------

-- Procedimento de Criar os totais da Solicitação de Calculo
procedure pkb_criar_total_sc ( en_soliccalc_id            in  solic_calc.id%type
                             , en_regtrib_cd              in  reg_trib.cd%type
                             , en_empresa_id              in  empresa.id%type
                             );

-------------------------------------------------------------------------------------------------------

-- Procedimento de retornar valores trabalhados de impostos do Item da Solicitação de Calculo
procedure pkb_retorna_vlr_imp_itemsc ( en_soliccalc_id              in             solic_calc.id%type
                                     , est_item_solic_calc          in out nocopy  item_solic_calc%rowtype
                                     );

-------------------------------------------------------------------------------------------------------

-- Procedimento de montagem da Observacao Fiscal da Solicitação de Calculo
procedure pkb_monta_sc_infor_adic ( en_soliccalc_id              in solic_calc.id%type
                                  , en_empresa_id                in empresa.id%type
                                  , en_obsfiscal_id              in obs_fiscal.id%type
                                  , ev_obs_compl                 in sc_infor_adic.obs_compl%type
                                  );

-------------------------------------------------------------------------------------------------------

--| Procedimento de recuperar os parâmetros de Retido a nível Global
procedure pkb_recup_param_calc_retido ( en_soliccalc_id              in solic_calc.id%type
                                      , en_empresa_id                in empresa.id%type
                                      , en_cnae_id                   in cnae.id%type
                                      , en_regtrib_id                in reg_trib.id%type
                                      , en_formatrib_id              in forma_trib.id%type
                                      , en_dm_ind_emit               in solic_calc.dm_ind_emit%type
                                      , en_dm_ind_oper               in solic_calc.dm_ind_oper%type
                                      , ed_dt_emiss                  in solic_calc.dt_emiss%type
                                      , ev_cpf_cnpj_part             in varchar2
                                      , en_dm_tipo_calc              in number -- Tipo do Calculo 0-Normal; 1-Retido
                                      , en_cfop_id                   in cfop.id%type
                                      , en_tiposervico_id            in tipo_servico.id%type
                                      , en_cidade_id                 in cidade.id%type
                                      , en_tipoimposto_id            in tipo_imposto.id%type
                                      --| Retorno do Imposto
                                      , st_row_param_calc_retido     out param_calc_retido%rowtype
                                      );

-------------------------------------------------------------------------------------------------------

--| Procedimento de recuperar os parâmetros de Retido a nível Empresa
procedure pkb_recup_param_calc_ret_nop ( en_soliccalc_id                       in solic_calc.id%type
                                       , en_empresa_id                         in empresa.id%type
                                       , en_natoper_id                         in nat_oper.id%type
                                       , en_dm_ind_emit                        in solic_calc.dm_ind_emit%type
                                       , en_dm_ind_oper                        in solic_calc.dm_ind_oper%type
                                       , ed_dt_emiss                           in solic_calc.dt_emiss%type
                                       , ev_cpf_cnpj_part                      in varchar2
                                       , en_dm_tipo_calc                       in number -- Tipo do Calculo 0-Normal; 1-Retido
                                       , en_tiposervico_id                     in tipo_servico.id%type
                                       , en_cidade_id                          in cidade.id%type
                                       , en_item_id                            in item.id%type
                                       , en_tipoimposto_id                     in tipo_imposto.id%type
                                       , en_tipoimp_cd                         in tipo_imposto.cd%type
                                       --| Retorno do Imposto
                                       , st_row_param_imp_nat_oper_serv        out param_imp_nat_oper_serv%rowtype
                                       , sv_txt                                out infor_comp_dcto_fiscal.txt%type
                                       );

-------------------------------------------------------------------------------------------------------

--| Procedimento de cálculo de Retido
procedure pkb_calc_retido ( en_soliccalc_id              in solic_calc.id%type
                          , en_empresa_id                in empresa.id%type
                          , en_cnae_id                   in cnae.id%type
                          , en_regtrib_id                in reg_trib.id%type
                          , en_formatrib_id              in forma_trib.id%type
                          , en_natoper_id                in nat_oper.id%type
                          , en_dm_ind_emit               in solic_calc.dm_ind_emit%type
                          , en_dm_ind_oper               in solic_calc.dm_ind_oper%type
                          , ed_dt_emiss                  in solic_calc.dt_emiss%type
                          , ev_cpf_cnpj_part             in varchar2
                          , en_dm_trib_imposto           in number
                          , en_dm_tipo_calc              in number -- Tipo do Calculo 0-Normal; 1-Retido
                          , en_obsfiscal_id              in obs_fiscal.id%type
                          , ev_obs_compl                 in cfop_tipoimp.obs_compl%type
                          , en_dm_reg_trib_part          in solic_calc.dm_reg_trib_part%type
                          --| Item
                          , en_item_id                   in item.id%type
                          , en_cfop_id                   in cfop.id%type
                          , en_tipoimposto_id            in tipo_imposto.id%type
                          --| Retorno do Imposto
                          , est_item_solic_calc          in out nocopy  item_solic_calc%rowtype
                          , est_row_imp_itemsc           in out nocopy  imp_itemsc%rowtype
                          );

-------------------------------------------------------------------------------------------------------

--| Procedimento de recuperar os parâmetros de ISS a nível Global
procedure pkb_recup_param_calc_iss ( en_soliccalc_id              in solic_calc.id%type
                                   , en_empresa_id                in empresa.id%type
                                   , en_cnae_id                   in cnae.id%type
                                   , en_regtrib_id                in reg_trib.id%type
                                   , en_formatrib_id              in forma_trib.id%type
                                   , en_dm_ind_emit               in solic_calc.dm_ind_emit%type
                                   , en_dm_ind_oper               in solic_calc.dm_ind_oper%type
                                   , ed_dt_emiss                  in solic_calc.dt_emiss%type
                                   , ev_cpf_cnpj_part             in varchar2
                                   , en_dm_tipo_calc              in number -- Tipo do Calculo 0-Normal; 1-Retido
                                   , en_cfop_id                   in cfop.id%type
                                   , en_tiposervico_id            in tipo_servico.id%type
                                   , en_cidade_id                 in cidade.id%type
                                   --| Retorno do Imposto
                                   , st_row_param_calc_iss        out param_calc_iss%rowtype
                                   );

-------------------------------------------------------------------------------------------------------

--| Procedimento de recuperar os parâmetros de ISS a nível Empresa
procedure pkb_recup_param_calc_iss_nop ( en_soliccalc_id                       in solic_calc.id%type
                                       , en_empresa_id                         in empresa.id%type
                                       , en_natoper_id                         in nat_oper.id%type
                                       , en_dm_ind_emit                        in solic_calc.dm_ind_emit%type
                                       , en_dm_ind_oper                        in solic_calc.dm_ind_oper%type
                                       , ed_dt_emiss                           in solic_calc.dt_emiss%type
                                       , ev_cpf_cnpj_part                      in varchar2
                                       , en_dm_tipo_calc                       in number -- Tipo do Calculo 0-Normal; 1-Retido
                                       , en_tiposervico_id                     in tipo_servico.id%type
                                       , en_cidade_id                          in cidade.id%type
                                       , en_item_id                            in item.id%type
                                       --| Retorno do Imposto
                                       , st_row_param_imp_nat_oper_serv        out param_imp_nat_oper_serv%rowtype
                                       , sn_dm_nat_oper                        out nat_oper_serv.dm_nat_oper%type
                                       , sv_txt                                out infor_comp_dcto_fiscal.txt%type
                                       );

-------------------------------------------------------------------------------------------------------

--| Procedimento de cálculo de ISS
procedure pkb_calc_iss ( en_soliccalc_id              in solic_calc.id%type
                       , en_empresa_id                in empresa.id%type
                       , en_cnae_id                   in cnae.id%type
                       , en_regtrib_id                in reg_trib.id%type
                       , en_formatrib_id              in forma_trib.id%type
                       , en_natoper_id                in nat_oper.id%type
                       , en_dm_ind_emit               in solic_calc.dm_ind_emit%type
                       , en_dm_ind_oper               in solic_calc.dm_ind_oper%type
                       , ed_dt_emiss                  in solic_calc.dt_emiss%type
                       , ev_cpf_cnpj_part             in varchar2
                       , en_dm_trib_imposto           in number
                       , en_dm_tipo_calc              in number -- Tipo do Calculo 0-Normal; 1-Retido
                       , en_obsfiscal_id              in obs_fiscal.id%type
                       , ev_obs_compl                 in cfop_tipoimp.obs_compl%type
                       --| Item
                       , en_item_id                   in item.id%type
                       , en_cfop_id                   in cfop.id%type
                       --| Retorno do Imposto
                       , est_item_solic_calc          in out nocopy  item_solic_calc%rowtype
                       , est_row_imp_itemsc           in out nocopy  imp_itemsc%rowtype
                       );

-------------------------------------------------------------------------------------------------------

--| Procedimento de recuperar parâmetros de calculo de Aliquota do Imposto por NCM, Global: Tratar IPI, PIS e COFINS
procedure pkb_recup_aliq_tipoimp_ncm ( en_soliccalc_id              in  solic_calc.id%type
                                     , en_empresa_id                in empresa.id%type
                                     , en_cnae_id                   in cnae.id%type
                                     , en_inctrib_id                in inc_trib.id%type
                                     , en_regtrib_id                in reg_trib.id%type
                                     , en_formatrib_id              in forma_trib.id%type
                                     , en_dm_ind_emit               in solic_calc.dm_ind_emit%type
                                     , en_dm_ind_oper               in solic_calc.dm_ind_oper%type
                                     , ed_dt_emiss                  in solic_calc.dt_emiss%type
                                     , ev_cpf_cnpj_part             in varchar2
                                     , en_estado_id_dest            in estado.id%type
                                     , en_dm_tipo_part              in solic_calc.dm_tipo_part%type
                                     , en_dm_cons_final             in solic_calc.dm_cons_final%type
                                     , en_dm_ind_ie_part            in solic_calc.dm_ind_ie_part%type
                                     , en_dm_reg_trib_part          in solic_calc.dm_reg_trib_part%type
                                     , en_dm_part_tem_suframa       in solic_calc.dm_part_tem_suframa%type
                                     , en_dm_ind_ativ_part          in solic_calc.dm_ind_ativ_part%type
                                     --| Item
                                     , en_ncm_id                    in ncm.id%type
                                     , en_extipi_id                 in ex_tipi.id%type
                                     , en_dm_orig_merc              in item_solic_calc.dm_orig_merc%type
                                     , en_cfop_id                   in cfop.id%type
                                     , en_tipoimposto_id            in tipo_imposto.id%type
                                     , st_row_aliq_tipoimp_ncm      out aliq_tipoimp_ncm%rowtype
                                     );

-------------------------------------------------------------------------------------------------------

--| Procedimento de recuperar parâmetros de calculo de Aliquota do Imposto por NCM, detalhe por ITEM da Empresa: Tratar IPI, PIS e COFINS
procedure pkb_recup_aliq_tipoimp_ncm_emp ( en_soliccalc_id              in  solic_calc.id%type
                                         , en_empresa_id                in empresa.id%type
                                         , en_natoper_id                in nat_oper.id%type
                                         , en_dm_ind_emit               in solic_calc.dm_ind_emit%type
                                         , en_dm_ind_oper               in solic_calc.dm_ind_oper%type
                                         , ed_dt_emiss                  in solic_calc.dt_emiss%type
                                         , ev_cpf_cnpj_part             in varchar2
                                         , en_estado_id_dest            in estado.id%type
                                         , en_dm_tipo_part              in solic_calc.dm_tipo_part%type
                                         , en_dm_cons_final             in solic_calc.dm_cons_final%type
                                         , en_dm_ind_ie_part            in solic_calc.dm_ind_ie_part%type
                                         , en_dm_reg_trib_part          in solic_calc.dm_reg_trib_part%type
                                         , en_dm_part_tem_suframa       in solic_calc.dm_part_tem_suframa%type
                                         , en_dm_ind_ativ_part          in solic_calc.dm_ind_ativ_part%type
                                         --| Item
                                         , en_item_id                   in item.id%type
                                         , en_ncm_id                    in ncm.id%type
                                         , en_extipi_id                 in ex_tipi.id%type
                                         , en_dm_orig_merc              in item_solic_calc.dm_orig_merc%type
                                         , en_cfop_id                   in cfop.id%type
                                         , en_tipoimposto_id            in tipo_imposto.id%type
                                         , st_row_aliq_tipoimp_ncm_empr out aliq_tipoimp_ncm_empresa%rowtype
                                         );

-------------------------------------------------------------------------------------------------------

-- Procedimento de calculo Aliquota do Imposto por NCM: Tratar IPI, PIS e COFINS
procedure pkb_calc_aliq_tipoimp_ncm ( en_soliccalc_id              in solic_calc.id%type
                                    , en_empresa_id                in empresa.id%type
                                    , en_cnae_id                   in cnae.id%type
                                    , en_inctrib_id                in inc_trib.id%type
                                    , en_regtrib_id                in reg_trib.id%type
                                    , en_formatrib_id              in forma_trib.id%type
                                    , en_natoper_id                in nat_oper.id%type
                                    , en_dm_ind_emit               in solic_calc.dm_ind_emit%type
                                    , en_dm_ind_oper               in solic_calc.dm_ind_oper%type
                                    , ed_dt_emiss                  in solic_calc.dt_emiss%type
                                    , ev_cpf_cnpj_part             in varchar2
                                    , en_estado_id_orig            in estado.id%type
                                    , en_estado_id_dest            in estado.id%type
                                    , en_dm_tipo_part              in solic_calc.dm_tipo_part%type
                                    , en_dm_cons_final             in solic_calc.dm_cons_final%type
                                    , en_dm_ind_ie_part            in solic_calc.dm_ind_ie_part%type
                                    , en_dm_reg_trib_part          in solic_calc.dm_reg_trib_part%type
                                    , en_dm_part_tem_suframa       in solic_calc.dm_part_tem_suframa%type
                                    , en_dm_ind_ativ_part          in solic_calc.dm_ind_ativ_part%type
                                    , en_dm_mot_des_icms_part      in solic_calc.dm_mot_des_icms_part%type
                                    , en_dm_trib_imposto           in number
                                    , en_codst_id                  in cod_st.id%type
                                    , en_obsfiscal_id              in obs_fiscal.id%type
                                    , ev_obs_compl                 in cfop_tipoimp.obs_compl%type
                                    --| Item
                                    , en_item_id                   in item.id%type
                                    , en_ncm_id                    in ncm.id%type
                                    , en_extipi_id                 in ex_tipi.id%type
                                    , en_cfop_id                   in cfop.id%type
                                    , en_tipoimposto_id            in tipo_imposto.id%type
                                    --| Retorno do Imposto
                                    , est_item_solic_calc          in out nocopy  item_solic_calc%rowtype
                                    , est_row_imp_itemsc           in out nocopy  imp_itemsc%rowtype
                                    );

-------------------------------------------------------------------------------------------------------

--| Procedimento de recuperar parâmetros de calculo de ICMS-ST Global
procedure pkb_recup_param_calc_icmsst ( en_soliccalc_id              in solic_calc.id%type
                                      , en_empresa_id                in empresa.id%type
                                      , en_cnae_id                   in cnae.id%type
                                      , en_regtrib_id                in reg_trib.id%type
                                      , en_formatrib_id              in forma_trib.id%type
                                      , en_dm_ind_emit               in solic_calc.dm_ind_emit%type
                                      , en_dm_ind_oper               in solic_calc.dm_ind_oper%type
                                      , ed_dt_emiss                  in solic_calc.dt_emiss%type
                                      , ev_cpf_cnpj_part             in varchar2
                                      , en_estado_id_orig            in estado.id%type
                                      , en_estado_id_dest            in estado.id%type
                                      , en_dm_tipo_part              in solic_calc.dm_tipo_part%type
                                      , en_dm_cons_final             in solic_calc.dm_cons_final%type
                                      , en_dm_ind_ie_part            in solic_calc.dm_ind_ie_part%type
                                      , en_dm_reg_trib_part          in solic_calc.dm_reg_trib_part%type
                                      , en_dm_part_tem_suframa       in solic_calc.dm_part_tem_suframa%type
                                      , en_dm_ind_ativ_part          in solic_calc.dm_ind_ativ_part%type
                                      , en_dm_mot_des_icms_part      in solic_calc.dm_mot_des_icms_part%type
                                      --| Item
                                      , en_cest_id                   in cest.id%type
                                      , en_ncm_id                    in ncm.id%type
                                      , en_extipi_id                 in ex_tipi.id%type
                                      , en_dm_orig_merc              in item_solic_calc.dm_orig_merc%type
                                      , en_cfop_id                   in cfop.id%type
                                      , st_row_param_calc_icmsst     out param_calc_icmsst%rowtype
                                      );

-------------------------------------------------------------------------------------------------------

--| Procedimento de recuperar parâmetros de calculo de ICMSST da Empresa
procedure pkb_rec_param_calc_icmsst_empr ( en_soliccalc_id                in solic_calc.id%type
                                         , en_empresa_id                  in empresa.id%type
                                         , en_natoper_id                  in nat_oper.id%type
                                         , en_dm_ind_emit                 in solic_calc.dm_ind_emit%type
                                         , en_dm_ind_oper                 in solic_calc.dm_ind_oper%type
                                         , ed_dt_emiss                    in solic_calc.dt_emiss%type
                                         , ev_cpf_cnpj_part               in varchar2
                                         , en_estado_id_dest              in estado.id%type
                                         , en_dm_tipo_part                in solic_calc.dm_tipo_part%type
                                         , en_dm_cons_final               in solic_calc.dm_cons_final%type
                                         , en_dm_ind_ie_part              in solic_calc.dm_ind_ie_part%type
                                         , en_dm_reg_trib_part            in solic_calc.dm_reg_trib_part%type
                                         , en_dm_part_tem_suframa         in solic_calc.dm_part_tem_suframa%type
                                         , en_dm_ind_ativ_part            in solic_calc.dm_ind_ativ_part%type
                                         , en_dm_mot_des_icms_part        in solic_calc.dm_mot_des_icms_part%type
                                         --| Item
                                         , en_item_id                     in item.id%type
                                         , en_cest_id                     in cest.id%type
                                         , en_ncm_id                      in ncm.id%type
                                         , en_extipi_id                   in ex_tipi.id%type
                                         , en_dm_orig_merc                in item_solic_calc.dm_orig_merc%type
                                         , en_cfop_id                     in cfop.id%type
                                         , st_row_param_calc_icmsst_empr  out param_calc_icmsst_empr%rowtype
                                         );

-------------------------------------------------------------------------------------------------------

-- Procedimento de calculo do ICMS-ST
procedure pkb_calc_icmsst ( en_soliccalc_id              in solic_calc.id%type
                          , en_empresa_id                in empresa.id%type
                          , en_cnae_id                   in cnae.id%type
                          , en_regtrib_id                in reg_trib.id%type
                          , en_formatrib_id              in forma_trib.id%type
                          , en_natoper_id                in nat_oper.id%type
                          , en_dm_ind_emit               in solic_calc.dm_ind_emit%type
                          , en_dm_ind_oper               in solic_calc.dm_ind_oper%type
                          , ed_dt_emiss                  in solic_calc.dt_emiss%type
                          , ev_cpf_cnpj_part             in varchar2
                          , en_estado_id_orig            in estado.id%type
                          , en_estado_id_dest            in estado.id%type
                          , en_dm_tipo_part              in solic_calc.dm_tipo_part%type
                          , en_dm_cons_final             in solic_calc.dm_cons_final%type
                          , en_dm_ind_ie_part            in solic_calc.dm_ind_ie_part%type
                          , en_dm_reg_trib_part          in solic_calc.dm_reg_trib_part%type
                          , en_dm_part_tem_suframa       in solic_calc.dm_part_tem_suframa%type
                          , en_dm_ind_ativ_part          in solic_calc.dm_ind_ativ_part%type
                          , en_dm_mot_des_icms_part      in solic_calc.dm_mot_des_icms_part%type
                          , en_dm_trib_imposto           in number
                          , en_calcular_icms_st          in number
                          , en_codst_id                  in cod_st.id%type
                          , en_obsfiscal_id              in obs_fiscal.id%type
                          , ev_obs_compl                 in cfop_tipoimp.obs_compl%type
                          --| Item
                          , en_item_id                   in item.id%type
                          , en_cest_id                   in cest.id%type
                          , en_ncm_id                    in ncm.id%type
                          , en_extipi_id                 in ex_tipi.id%type
                          , en_cfop_id                   in cfop.id%type
                          --| Retorno do Imposto
                          , est_item_solic_calc          in out nocopy  item_solic_calc%rowtype
                          , est_row_imp_itemsc           in out nocopy  imp_itemsc%rowtype
                          );

-------------------------------------------------------------------------------------------------------

--| Procedimento de recuperar parâmetros de calculo de ICMS Global
procedure pkb_recup_param_calc_icms ( en_soliccalc_id              in solic_calc.id%type
                                    , en_empresa_id                in empresa.id%type
                                    , en_cnae_id                   in cnae.id%type
                                    , en_regtrib_id                in reg_trib.id%type
                                    , en_formatrib_id              in forma_trib.id%type
                                    , en_dm_ind_emit               in solic_calc.dm_ind_emit%type
                                    , en_dm_ind_oper               in solic_calc.dm_ind_oper%type
                                    , ed_dt_emiss                  in solic_calc.dt_emiss%type
                                    , ev_cpf_cnpj_part             in varchar2
                                    , en_estado_id_orig            in estado.id%type
                                    , en_estado_id_dest            in estado.id%type
                                    , en_dm_tipo_part              in solic_calc.dm_tipo_part%type
                                    , en_dm_cons_final             in solic_calc.dm_cons_final%type
                                    , en_dm_ind_ie_part            in solic_calc.dm_ind_ie_part%type
                                    , en_dm_reg_trib_part          in solic_calc.dm_reg_trib_part%type
                                    , en_dm_part_tem_suframa       in solic_calc.dm_part_tem_suframa%type
                                    , en_dm_ind_ativ_part          in solic_calc.dm_ind_ativ_part%type
                                    , en_dm_mot_des_icms_part      in solic_calc.dm_mot_des_icms_part%type
                                    --| Item
                                    , en_ncm_id                    in ncm.id%type
                                    , en_extipi_id                 in ex_tipi.id%type
                                    , en_dm_orig_merc              in item_solic_calc.dm_orig_merc%type
                                    , en_cfop_id                   in cfop.id%type
                                    , st_row_param_calc_icms       out param_calc_icms%rowtype
                                    );

-------------------------------------------------------------------------------------------------------

--| Procedimento de recuperar parâmetros de calculo de ICMS da Empresa
procedure pkb_recup_param_calc_icms_empr ( en_soliccalc_id              in  solic_calc.id%type
                                         , en_empresa_id                in empresa.id%type
                                         , en_natoper_id                in nat_oper.id%type
                                         , en_dm_ind_emit               in solic_calc.dm_ind_emit%type
                                         , en_dm_ind_oper               in solic_calc.dm_ind_oper%type
                                         , ed_dt_emiss                  in solic_calc.dt_emiss%type
                                         , ev_cpf_cnpj_part             in varchar2
                                         , en_estado_id_dest            in estado.id%type
                                         , en_dm_tipo_part              in solic_calc.dm_tipo_part%type
                                         , en_dm_cons_final             in solic_calc.dm_cons_final%type
                                         , en_dm_ind_ie_part            in solic_calc.dm_ind_ie_part%type
                                         , en_dm_reg_trib_part          in solic_calc.dm_reg_trib_part%type
                                         , en_dm_part_tem_suframa       in solic_calc.dm_part_tem_suframa%type
                                         , en_dm_ind_ativ_part          in solic_calc.dm_ind_ativ_part%type
                                         , en_dm_mot_des_icms_part      in solic_calc.dm_mot_des_icms_part%type
                                         --| Item
                                         , en_item_id                   in item.id%type
                                         , en_ncm_id                    in ncm.id%type
                                         , en_extipi_id                 in ex_tipi.id%type
                                         , en_dm_orig_merc              in item_solic_calc.dm_orig_merc%type
                                         , en_cfop_id                   in cfop.id%type
                                         , st_row_param_calc_icms_empr  out param_calc_icms_empr%rowtype
                                         );

-------------------------------------------------------------------------------------------------------

-- Procedimento de calculo do ICMS
procedure pkb_calc_icms ( en_soliccalc_id              in solic_calc.id%type
                        , en_empresa_id                in empresa.id%type
                        , en_cnae_id                   in cnae.id%type
                        , en_regtrib_id                in reg_trib.id%type
                        , en_formatrib_id              in forma_trib.id%type
                        , en_natoper_id                in nat_oper.id%type
                        , en_dm_ind_emit               in solic_calc.dm_ind_emit%type
                        , en_dm_ind_oper               in solic_calc.dm_ind_oper%type
                        , ed_dt_emiss                  in solic_calc.dt_emiss%type
                        , ev_cpf_cnpj_part             in varchar2
                        , en_estado_id_orig            in estado.id%type
                        , en_estado_id_dest            in estado.id%type
                        , en_dm_tipo_part              in solic_calc.dm_tipo_part%type
                        , en_dm_cons_final             in solic_calc.dm_cons_final%type
                        , en_dm_ind_ie_part            in solic_calc.dm_ind_ie_part%type
                        , en_dm_reg_trib_part          in solic_calc.dm_reg_trib_part%type
                        , en_dm_part_tem_suframa       in solic_calc.dm_part_tem_suframa%type
                        , en_dm_ind_ativ_part          in solic_calc.dm_ind_ativ_part%type
                        , en_dm_mot_des_icms_part      in solic_calc.dm_mot_des_icms_part%type
                        , en_dm_trib_imposto           in number
                        , en_codst_id                  in cod_st.id%type
                        , en_obsfiscal_id              in obs_fiscal.id%type
                        , ev_obs_compl                 in cfop_tipoimp.obs_compl%type
                        --| Item
                        , en_item_id                   in item.id%type
                        , en_ncm_id                    in ncm.id%type
                        , en_extipi_id                 in ex_tipi.id%type
                        , en_cfop_id                   in cfop.id%type
                        --| Retorno do Imposto
                        , est_item_solic_calc          in out nocopy  item_solic_calc%rowtype
                        , est_row_imp_itemsc           in out nocopy  imp_itemsc%rowtype
                        );

-------------------------------------------------------------------------------------------------------

-- Prodimento de recuperar o parametro de partilha de icms Global
procedure pkb_recup_param_part_icms ( en_soliccalc_id              in solic_calc.id%type
                                    , en_empresa_id                in empresa.id%type
                                    , ed_dt_emiss                  in solic_calc.dt_emiss%type
                                    , en_estado_id_orig            in estado.id%type
                                    , en_estado_id_dest            in estado.id%type
                                    --| Item
                                    , en_ncm_id                    in ncm.id%type
                                    , en_cfop_id                   in cfop.id%type
                                    , st_row_cfop_part_icms_estado out cfop_part_icms_estado%rowtype
                                    );

-------------------------------------------------------------------------------------------------------

-- Prodimento de recuperar o parametro de partilha de icms da empresa
procedure pkb_recup_param_part_icms_empr ( en_soliccalc_id              in solic_calc.id%type
                                         , en_empresa_id                in empresa.id%type
                                         , ed_dt_emiss                  in solic_calc.dt_emiss%type
                                         , en_estado_id_orig            in estado.id%type
                                         , en_estado_id_dest            in estado.id%type
                                         --| Item
                                         , en_orig                      in param_icms_inter_cf.orig%type
                                         , en_item_id                   in item.id%type
                                         , en_ncm_id                    in ncm.id%type
                                         , en_cfop_id                   in cfop.id%type
                                         , st_row_param_icms_inter_cf   out param_icms_inter_cf%rowtype
                                         );

-------------------------------------------------------------------------------------------------------

--| Procedimento Calcula a Partilha de ICMS
procedure pkb_calc_part_icms ( en_soliccalc_id              in solic_calc.id%type
                             , en_empresa_id                in empresa.id%type
                             , en_dm_ind_emit               in solic_calc.dm_ind_emit%type
                             , ed_dt_emiss                  in solic_calc.dt_emiss%type
                             , en_dm_cons_final             in solic_calc.dm_cons_final%type
                             , en_estado_id_orig            in estado.id%type
                             , en_estado_id_dest            in estado.id%type
                             --| Item
                             , en_orig                      in param_icms_inter_cf.orig%type 							 
                             , en_item_id                   in item.id%type
                             , en_ncm_id                    in ncm.id%type
                             , en_cfop_id                   in cfop.id%type
                             , et_item_solic_calc           in item_solic_calc%rowtype
                             );

-------------------------------------------------------------------------------------------------------

--| Procedimento recupera parâmetros da Calculadora Fiscal pela Natureza da Operacao
procedure pkb_recup_param_nat_oper ( en_soliccalc_id              in solic_calc.id%type
                                   , en_empresa_id                in empresa.id%type
                                   , en_cnae_id                   in cnae.id%type
                                   , en_inctrib_id                in inc_trib.id%type
                                   , en_regtrib_id                in reg_trib.id%type
                                   , en_formatrib_id              in forma_trib.id%type
                                   , en_natoper_id                in nat_oper.id%type
                                   , en_dm_ind_emit               in solic_calc.dm_ind_emit%type
                                   , en_dm_ind_oper               in solic_calc.dm_ind_oper%type
                                   , ed_dt_emiss                  in solic_calc.dt_emiss%type
                                   , ev_cpf_cnpj_part             in varchar2
                                   , en_estado_id_dest            in estado.id%type
                                   , en_dm_tipo_part              in solic_calc.dm_tipo_part%type
                                   , en_dm_cons_final             in solic_calc.dm_cons_final%type
                                   , en_dm_ind_ie_part            in solic_calc.dm_ind_ie_part%type
                                   , en_dm_reg_trib_part          in solic_calc.dm_reg_trib_part%type
                                   , en_dm_part_tem_suframa       in solic_calc.dm_part_tem_suframa%type
                                   , en_dm_ind_ativ_part          in solic_calc.dm_ind_ativ_part%type
                                   , en_dm_mot_des_icms_part      in solic_calc.dm_mot_des_icms_part%type
                                   , en_calcular_icms_st          in number
                                   , sb_calculou                  out boolean
                                   );

-------------------------------------------------------------------------------------------------------

--| Procedimento recupera parâmetros da Calculadora Fiscal pelo CFOP x Tipo Imposto
procedure pkb_recup_param_cfop_tpimp ( en_soliccalc_id              in solic_calc.id%type
                                     , en_empresa_id                in empresa.id%type
                                     , en_cnae_id                   in cnae.id%type
                                     , en_inctrib_id                in inc_trib.id%type
                                     , en_regtrib_id                in reg_trib.id%type
                                     , en_formatrib_id              in forma_trib.id%type
                                     , en_natoper_id                in nat_oper.id%type
                                     , en_dm_ind_emit               in solic_calc.dm_ind_emit%type
                                     , en_dm_ind_oper               in solic_calc.dm_ind_oper%type
                                     , ed_dt_emiss                  in solic_calc.dt_emiss%type
                                     , ev_cpf_cnpj_part             in varchar2
                                     , en_estado_id_dest            in estado.id%type
                                     , en_dm_tipo_part              in solic_calc.dm_tipo_part%type
                                     , en_dm_cons_final             in solic_calc.dm_cons_final%type
                                     , en_dm_ind_ie_part            in solic_calc.dm_ind_ie_part%type
                                     , en_dm_reg_trib_part          in solic_calc.dm_reg_trib_part%type
                                     , en_dm_part_tem_suframa       in solic_calc.dm_part_tem_suframa%type
                                     , en_dm_ind_ativ_part          in solic_calc.dm_ind_ativ_part%type
                                     , en_dm_mot_des_icms_part      in solic_calc.dm_mot_des_icms_part%type
                                     , en_calcular_icms_st          in number
                                     , sb_calculou                  out boolean
                                     );

-------------------------------------------------------------------------------------------------------

--| Procedimento de executar o calculo de impostos
procedure pkb_executar_solic_calc ( en_soliccalc_id            in  solic_calc.id%type
                                  );

-------------------------------------------------------------------------------------------------------

--| Procedimento de solicitar o cálculo de um item sincrono
procedure pkb_solicitar_calc_item ( ev_multorg_cd              in mult_org.cd%type
                                  , ev_multorg_hash            in mult_org.hash%type
                                  , ev_cpf_cnpj_empresa        in varchar2
                                  , ev_cod_nat                 in nat_oper.cod_nat%type
                                  , en_dm_ind_emit             in solic_calc.dm_ind_emit%type
                                  , en_dm_ind_oper             in solic_calc.dm_ind_oper%type
                                  , ev_cod_mod                 in mod_fiscal.cod_mod%type
                                  , ev_serie                   in solic_calc.serie%type
                                  , en_numero                  in solic_calc.numero%type
                                  , ed_dt_emiss                in solic_calc.dt_emiss%type
                                  , ev_cpf_cnpj_part           in varchar2
                                  , ev_sigla_estado_part       in estado.sigla_estado%type
                                  , en_dm_tipo_part            in solic_calc.dm_tipo_part%type
                                  , en_dm_cons_final           in solic_calc.dm_cons_final%type
                                  , en_dm_ind_ie_part          in solic_calc.dm_ind_ie_part%type
                                  , en_dm_reg_trib_part        in solic_calc.dm_reg_trib_part%type
                                  , en_dm_part_tem_suframa     in solic_calc.dm_part_tem_suframa%type
                                  , en_dm_ind_ativ_part        in solic_calc.dm_ind_ativ_part%type
                                  , en_dm_mot_des_icms_part    in solic_calc.dm_mot_des_icms_part%type
                                  , en_dm_calc_icmsst_part     in solic_calc.dm_calc_icmsst_part%type
                                  --| Item
                                  , ev_cod_item                in item_solic_calc.cod_item%type
                                  , ev_descr_item              in item_solic_calc.descr_item%type
                                  , ev_cod_ncm                 in item_solic_calc.cod_ncm%type
                                  , ev_extipi                  in item_solic_calc.extipi%type
                                  , ev_cod_cest                in item_solic_calc.cod_cest%type
                                  , en_dm_orig_merc            in item_solic_calc.dm_orig_merc%type
                                  , en_cfop                    in item_solic_calc.cfop%type
                                  , ev_cd_lista_serv           in item_solic_calc.cd_lista_serv%type
                                  , en_dm_tipo_item            in item_solic_calc.dm_tipo_item%type
                                  , ev_unid_med                in item_solic_calc.unid_med%type
                                  , en_qtde                    in item_solic_calc.qtde%type
                                  , en_vl_unit                 in item_solic_calc.vl_unit%type
                                  , en_vl_bruto                in item_solic_calc.vl_bruto%type
                                  , en_vl_desc                 in item_solic_calc.vl_desc%type
                                  , en_vl_frete                in item_solic_calc.vl_frete%type
                                  , en_vl_seguro               in item_solic_calc.vl_seguro%type
                                  , en_vl_outro                in item_solic_calc.vl_outro%type
                                  , en_dm_ind_tot              in item_solic_calc.dm_ind_tot%type
                                  , en_vl_bc_ii                in item_solic_calc.vl_bc_ii%type
                                  , en_vl_desp_adu             in item_solic_calc.vl_desp_adu%type
                                  , en_vl_ii                   in item_solic_calc.vl_ii%type
                                  , en_vl_iof                  in item_solic_calc.vl_iof%type
                                  , en_ibge_cid_serv_prest     in item_solic_calc.ibge_cid_serv_prest%type
                                  , en_vl_desc_incondicionado  in item_solic_calc.vl_desc_incondicionado%type
                                  , en_vl_desc_condicionado    in item_solic_calc.vl_desc_condicionado%type
                                  , en_vl_deducao              in item_solic_calc.vl_deducao%type
                                  , en_vl_outra_ret            in item_solic_calc.vl_outra_ret%type
                                  , sn_soliccalc_id            out solic_calc.id%type
                                  );

-------------------------------------------------------------------------------------------------------

end pk_csf_api_calc_fiscal;
/
