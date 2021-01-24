create or replace package csf_own.pk_csf_calc_fiscal is
-------------------------------------------------------------------------------------------------------
-- Especificação do pacote de funções de utilizadas para a Calculadora Fiscal
--
-- Em 06/10/2020  - Karina de Paula
-- Redmine #71923 - Regra de arredondamento de ISS na calculadora
-- Rotina Criada  - fkg_dmindregra
--
-- Em 21/01/2019 - Karina de Paula
-- Redmine #50486 - Código de tributação do municipio na Calculadora Fiscal
-- Rotina Alterada: fkg_paramcalciss_id incluído o parâmetro de entrada en_codtribmunicipio_id
--
-- Em 16/11/2016 - Fábio Tavares
-- Redmine #25355 - Criação de uma nova função que retorna o código da observação fiscal
-- rotina: fkg_obsfiscal_codof
--
-------------------------------------------------------------------------------------------------------
--| Função de Retorno do ID da tabela de log_generico_calcfiscal
function fkg_loggenericocalcfiscal_id ( en_referencia_id in log_generico_calcfiscal.referencia_id%type
                                      , ev_mensagem      in log_generico_calcfiscal.mensagem%type
                                      ) return log_generico_calcfiscal.id%type;
-------------------------------------------------------------------------------------------------------
--| Função de Retorno do ID da tabela de param_icms_inter_cf
function fkg_paramicmsintercf_id ( en_empresa_id  in empresa.id%type
                                 , en_estado_id   in estado.id%type
                                 , ed_dt_ini      in param_icms_inter_cf.dt_ini%type
                                 , ed_dt_fin      in param_icms_inter_cf.dt_fin%type
                                 , en_cfop_id     in cfop.id%type
                                 , en_ncm_id      in ncm.id%type
                                 , en_item_id     in item.id%type
                                 ) return param_icms_inter_cf.id%type;

-------------------------------------------------------------------------------------------------------
--| Função de Retorno do ID da tabela de param_calc_icms_empr
function fkg_paramcalcicmsempr_id ( en_empresa_id             in empresa.id%type
                                  , ed_dt_ini                 in param_calc_icms_empr.dt_ini%type
                                  , ed_dt_fin                 in param_calc_icms_empr.dt_fin%type
                                  , ev_dm_tipo_param          in param_calc_icms_empr.dm_tipo_param%type
                                  , en_prioridade             in param_calc_icms_empr.prioridade%type
                                  , en_cfop_id                in cfop.id%type
                                  , en_estado_id_dest         in cfop.id%type
                                  , en_ncm_id                 in ncm.id%type
                                  , en_extipi_id              in ex_tipi.id%type
                                  , en_dm_orig_merc           in param_calc_icms_empr.dm_orig_merc%type
                                  , en_item_id                in item.id%type
                                  , en_natoper_id             in nat_oper.id%type
                                  , ev_cpf_cnpj               in varchar2
                                  , en_dm_calc_fisica         in param_calc_icms_empr.dm_calc_fisica%type
                                  , en_dm_calc_contr_isento   in param_calc_icms_empr.dm_calc_contr_isento%type
                                  , en_dm_calc_cons_final     in param_calc_icms_empr.dm_calc_cons_final%type
                                  , en_dm_calc_nao_contr      in param_calc_icms_empr.dm_calc_nao_contr%type
                                  , en_dm_emit_com_suframa    in param_calc_icms_empr.dm_emit_com_suframa%type
                                  , en_dm_dest_com_suframa    in param_calc_icms_empr.dm_dest_com_suframa%type
                                  ) return param_calc_icms_empr.id%type;

-------------------------------------------------------------------------------------------------------
--| Função de Retorno do ID da tabela de param_calc_icmsst_empr

function fkg_paramcalcicmsstempr_id ( en_empresa_id       in empresa.id%type
                                    , en_cfop_id          in cfop.id%type
                                    , en_estado_id_dest   in estado.id%type
                                    , ed_dt_ini           in param_calc_icmsst_empr.dt_ini%type   
                                    , ed_dt_fin           in param_calc_icmsst_empr.dt_fin%type
                                    , en_cest_id          in cest.id%type
                                    , en_ncm_id           in ncm.id%type
                                    , en_extipi_id        in ex_tipi.id%type
                                    , en_dm_orig_merc     in param_calc_icmsst_empr.dm_orig_merc%type
                                    , en_item_id          in item.id%type
                                    , ev_cpf_cnpj         in param_calc_icmsst_empr.cpf_cnpj%type
                                    , en_natoper_id       in nat_oper.id%type
                                    , en_dm_calc_fisica   in param_calc_icmsst_empr.dm_calc_fisica%type
                                    )  return param_calc_icmsst_empr.id%type;

-------------------------------------------------------------------------------------------------------
--| Função de Retorno do ID da tabela de aliq_tipoimp_ncm_empresa
function fkg_aliqtipoimpncmempresa_id ( en_empresa_id           in empresa.id%type
                                      , ed_dt_ini               in aliq_tipoimp_ncm_empresa.dt_ini%type
                                      , ed_dt_fin               in aliq_tipoimp_ncm_empresa.dt_fin%type
                                      , ev_dm_tipo_param        in aliq_tipoimp_ncm_empresa.dm_tipo_param%type
                                      , en_prioridade           in aliq_tipoimp_ncm_empresa.prioridade%type
                                      , en_tipoimposto_id       in tipo_imposto.id%type
                                      , en_cfop_id              in cfop.id%type
                                      , en_ncm_id               in ncm.id%type
                                      , en_extipi_id            in ex_tipi.id%type
                                      , en_dm_orig_merc         in param_calc_icms.dm_orig_merc%type
                                      , en_item_id              in item.id%type
                                      , en_natoper_id           in nat_oper.id%type
                                      , ev_cpf_cnpj             in aliq_tipoimp_ncm_empresa.cpf_cnpj%type
                                      , en_dm_calc_cons_final   in aliq_tipoimp_ncm_empresa.dm_calc_cons_final%type
                                      ) return aliq_tipoimp_ncm_empresa.id%type;

-------------------------------------------------------------------------------------------------------
--| Função de Retorno do ID da tabela de param_calc_retido
function fkg_paramcalcretido_id ( ed_dt_ini          in param_calc_retido.dt_ini%type
                                , ed_dt_fin          in param_calc_retido.dt_fin%type
                                , ev_dm_tipo_param   in param_calc_retido.dm_tipo_param%type
                                , en_prioridade      in param_calc_retido.prioridade%type
                                , en_tipoimposto_id  in tipo_imposto.id%type
                                , en_cfop_id         in cfop.id%type
                                , en_regtrib_id      in reg_trib.id%type
                                , en_formatrib_id    in forma_trib.id%type
                                , en_cnae_id         in cnae.id%type
                                , en_tiposervico_id  in tipo_servico.id%type
                                ) return param_calc_retido.id%type;

-------------------------------------------------------------------------------------------------------
--| Função de Retorno do ID da tabela de param_calc_iss
function fkg_paramcalciss_id ( ed_dt_ini         in param_calc_iss.dt_ini%type
                             , ed_dt_fin         in param_calc_iss.dt_fin%type
                             , en_cidade_id      in cidade.id%type
                             , en_dm_tipo_calc   in param_calc_iss.dm_tipo_calc%type
                             , en_cfop_id        in cfop.id%type
                             , en_regtrib_id     in reg_trib.id%type
                             , en_formatrib_id   in forma_trib.id%type
                             , en_cnae_id        in cnae.id%type
                             , en_codtribmunicipio_id in cod_trib_municipio.id%type
                             , en_tiposervico_id in tipo_servico.id%type
                             ) return param_calc_iss.id%type;

-------------------------------------------------------------------------------------------------------
--| Função de Retorno do ID da tabela de cfop_part_icms_estado
function fkg_cfopparticmsestado_id ( en_estado_id_orig in cfop_part_icms_estado.ESTADO_ID_ORIG%type
                                   , en_estado_id_dest in cfop_part_icms_estado.ESTADO_ID_ORIG%type
                                   , ed_dt_ini         in cfop_part_icms_estado.dt_ini%type
                                   , ed_dt_fin         in cfop_part_icms_estado.dt_fin%type
                                   , en_cfop_id        in cfop.id%type
                                   , en_ncm_id         in ncm.id%type
                                   ) return cfop_part_icms_estado.id%type;

-------------------------------------------------------------------------------------------------------
--| Função de Retorno do ID da tabela de param_calc_icms
function fkg_paramcalcicms_id ( ed_dt_ini               in param_calc_icms.dt_ini%type
                              , ed_dt_fin               in param_calc_icms.dt_fin%type
                              , ev_dm_tipo_param        in param_calc_icms.dm_tipo_param%type
                              , en_prioridade           in param_calc_icms.prioridade%type
                              , en_cfop_id              in cfop.id%type
                              , en_regtrib_id           in reg_trib.id%type   
                              , en_formatrib_id         in forma_trib.id%type 
                              , en_estado_id_orig       in estado.id%type
                              , en_estado_id_dest       in estado.id%type
                              , en_cnae_id              in cnae.id%type
                              , en_ncm_id               in ncm.id%type
                              , en_extipi_id            in ex_tipi.id%type
                              , en_dm_orig_merc         in param_calc_icms.dm_orig_merc%type
                              , en_dm_calc_fisica       in param_calc_icms.dm_calc_fisica%type
                              , en_dm_calc_cons_final   in param_calc_icms.dm_calc_cons_final%type
                              , en_dm_calc_contr_isento in param_calc_icms.dm_calc_contr_isento%type
                              , en_dm_calc_nao_contr    in param_calc_icms.dm_calc_nao_contr%type
                              , en_dm_emit_com_suframa  in param_calc_icms.dm_emit_com_suframa%type
                              , en_dm_dest_com_suframa  in param_calc_icms.dm_dest_com_suframa%type
                              ) return param_calc_icms.id%type;

-------------------------------------------------------------------------------------------------------
--| Função de Retorno do ID da tabela de param_calc_icmsst
function fkg_paramcalcicmsst_id ( ed_dt_ini          in param_calc_icmsst.dt_ini%type
                                , ed_dt_fin          in param_calc_icmsst.dt_fin%type
                              --  , ev_dm_tipo_param   in param_calc_icmsst.dm_tipo_param%type
                              --  , en_prioridade      in param_calc_icmsst.prioridade%type
                                , en_cfop_id         in cfop.id%type
                                , en_regtrib_id      in reg_trib.id%type
                                , en_formatrib_id    in forma_trib.id%type
                                , en_estado_id_orig  in estado.id%type
                                , en_estado_id_dest  in estado.id%type
                                , en_cnae_id         in cnae.id%type
                                , en_cest_id         in cest.id%type
                                , en_ncm_id          in ncm.id%type
                                , en_extipi_id       in ex_tipi.id%type
                                , en_dm_orig_merc    in param_calc_icmsst.dm_tipo_param%type
                                , en_dm_calc_fisica  in param_calc_icmsst.DM_CALC_FISICA%type
                                ) return param_calc_icmsst.id%type;

-------------------------------------------------------------------------------------------------------
--| Função de Retorno do ID da tabela de ALIQ_TIPOIMP_NCM
function fkg_aliqtipoimpncm_id ( ed_dt_ini             in aliq_tipoimp_ncm.dt_ini%type
                               , ed_dt_fin             in aliq_tipoimp_ncm.dt_fin%type --
                               , en_tipoimposto_id     in tipo_imposto.id%type
                               , en_inctrib_id         in inc_trib.id%type             --
                               , en_regtrib_id         in reg_trib.id%type             --
                               , en_formatrib_id       in forma_trib.id%type           --
                               , en_cnae_id            in cnae.id%type                 --
                               , en_cfop_id            in cfop.id%type                 --
                               , en_ncm_id             in ncm.id%type             --
                               , en_extipi_id          in ex_tipi.id%type     --
                               , en_dm_orig_merc       in aliq_tipoimp_ncm.dm_orig_merc%type --
                               , en_dm_calc_cons_final in aliq_tipoimp_ncm.dm_calc_cons_final%type
                               ) return aliq_tipoimp_ncm.id%type;

-------------------------------------------------------------------------------------------------------
--| Função de Retorno o ID da tabela de CFOP_TIPOIMP
function fkg_cfoptipoimp_id ( en_cfop_id          in cfop.cd%type
                            , en_regtrib_id       in reg_trib.cd%type
                            , en_formatrib        in forma_trib.cd%type
                            , en_tipoimposto_id   in tipo_imposto.cd%type
                            , en_dm_tipo_calc     in cfop_tipoimp.dm_tipo_calc%type
                            ) return cfop_tipoimp.id%type;

-------------------------------------------------------------------------------------------------------

--| Função de retornar o ID da Observação Fiscal
function fkg_obsfiscal_id ( ev_cod_of  in obs_fiscal.cod_of%type )
         return obs_fiscal.id%type;

-------------------------------------------------------------------------------------------------------

--| Função de retornar o registro da Observação Fiscal
function fkg_obsfiscal_row ( en_obsfiscal_id in obs_fiscal.id%type )
         return obs_fiscal%rowtype;

-------------------------------------------------------------------------------------------------------

--| Função de retornar o código da Observação Fiscal
function fkg_obsfiscal_codof ( en_obsfiscal_id in obs_fiscal.id%type )
         return obs_fiscal.cod_of%type;

-------------------------------------------------------------------------------------------------------

--| Função retorna TRUE se existe a Solicitacao de Calculo
function fkg_existe_solic_calc ( en_soliccalc_id in solic_calc.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna a memoria do parametro de Partilha de ICMS nível Empresa
function fkg_mem_param_icms_inter_cf ( en_paramicmsintercf_id in param_icms_inter_cf.id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna a memoria do parametro de Partilha de ICMS nível Global
function fkg_mem_cfop_part_icms_estado ( en_cfopparticmsestado_id in cfop_part_icms_estado.id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna a memoria de Parametro de Calculo de ICMS para Empresa
function fkg_mem_param_calc_icms_empr ( en_paramcalcicmsempr_id in param_calc_icms_empr.id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna a memoria de Parametros de Calculo de ICMS
function fkg_mem_param_calc_icms ( en_paramcalcicms_id in param_calc_icms.id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna a memoria de Parametros de Calculo de ICMS-ST
function fkg_mem_param_calc_icmsst ( en_paramcalcicmsst_id in param_calc_icmsst.id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna a memoria de Parametro de Calculo de ICMS-ST para Empresa
function fkg_mem_param_calc_icmsst_empr ( en_paramcalcicmsstempr_id in param_calc_icmsst_empr.id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna a memoria de Parametros de Calculo Aliquota do Imposto por NCM: Tratar IPI, PIS e COFINS
function fkg_mem_aliq_tipoimp_ncm ( en_aliqtipoimpncm_id in aliq_tipoimp_ncm.id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna a memoria de Parametro de Calculo Aliquota do Imposto por NCM, detalhe por ITEM da Empresa: Tratar IPI, PIS e COFINS
function fkg_mem_aliq_tipoimp_ncm_empr ( en_aliqtipoimpncmempresa_id in aliq_tipoimp_ncm_empresa.id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorno 0-Não ou 1-Sim, para utilização da Calculadora Fiscal para Emissão Propria
function fkg_empr_util_epropria ( en_empresa_id  in empresa.id%type )
         return param_empr_calc_fiscal.dm_util_epropria%type;

-------------------------------------------------------------------------------------------------------

-- Função retorno 0-Não ou 1-Sim, para utilização da Calculadora Fiscal para Emissão Terceiro
function fkg_empr_util_eterceiro ( en_empresa_id  in empresa.id%type )
         return param_empr_calc_fiscal.dm_util_eterceiro%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna a memoria de Parametros de Calculo de ISS
function fkg_mem_param_calc_iss ( en_paramcalciss_id in param_calc_iss.id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna a memoria de Parametros de Calculo de ISS conforme Natureza de Operação
function fkg_mem_param_calc_iss_nop ( en_paramimpnatoperserv_id in param_imp_nat_oper_serv.id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna a memoria de Parametros de Calculo de Retido
function fkg_mem_param_calc_retido ( en_paramcalcretido_id in param_calc_retido.id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna A-Arredondamento ou T-Trunc, para utilização da Calculadora Fiscal Imposto de ISS
function fkg_dmindregra ( en_empresa_id        in empresa.id%type
                        , ev_objeto_referencia in param_calc_regra_arred.objeto_referencia%type 
                        , en_id_referencia     in param_calc_regra_arred.id_referencia%type )
         return param_calc_regra_arred.dm_ind_regra%type;

-------------------------------------------------------------------------------------------------------
end pk_csf_calc_fiscal;
/
