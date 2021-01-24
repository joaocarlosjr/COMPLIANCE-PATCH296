create or replace package csf_own.pk_vld_amb_d100 is

-------------------------------------------------------------------------------------------------------
--
-- Especificação do pacote da API para ler os conhecimentos de transporte de aquisição com
-- DM_ST_PROC = 0 (Não validada) e chamar os procedimentos para validar os dados
--
-- Em 15/01/2020 - Eduardo Linden
-- Redmine #75237 (Feedback) - Inclusão de parametrização para preenchimento do Codigo do Tipo Serviço Reinf para CTE modelo 67
-- Foi ajustado as condições sobre dm_legado devido ao problema de estar vindo nulo. 
-- Rotina alterada - pkb_vld_ct_d100 
-- Patches 2.9.5.4 e 2.9.6.1 e Release 2.9.7 
--
-- Em 12/01/2020 - Eduardo Linden
-- Redmine #75121 (Feedback) - Inclusão de parametrização para preenchimento do Codigo do Tipo Serviço Reinf para CTE modelo 67
-- Inclusão da chamada da rotina pkb_ler_conhec_transp_imp_ret.
-- Rotinas alteradas - pkb_ler_ct_d100 e pkb_vld_ct_d100
-- Patches 2.9.5.4 e 2.9.6.1 e Release 2.9.7 
--
-- Em 12/01/2021   - LUIZ ARMANDO AZONI - 2.9.5-4 - 296-1 297
-- Redmine #75061  - ADICIONADO AJUSTE NO DM_ST_PROC PARA AS SITUAÇÕES ONDE O CT-E É LEGADO
-- Nova Rotina     - pkb_vld_ct_d100
--
-- Em 28/12/2020   - Eduardo Linden
-- Redmine #74671  - Inclusão do Flexfield UNID_ORG - VW_CSF_CONHEC_TRANSP_EFD_FF
-- Rotinas alteradas - pkb_ler_ct_d100 e pkb_vld_ct_d100 => Inclusão do novo parametro ev_cd_unid_org na rotina pk_csf_api_d100.pkb_integr_ct_d100
--
-- Em 18/09/2020   - Luis Marques - 2.9.5
-- Redmine #70848  - Implementar Diferencial de Alíquota para CTE - Aviva
-- Nova Rotina     - pkb_ler_ct_dif_aliq - Rotina para ler os dados do diferencial de aliquota do conhecimento 
-- Rotina Alterada - pkb_ler_ct_d100 - Incluida chamada para rotina "pkb_ler_ct_dif_aliq".
--
-- Em 01/10/2020     - Armando/Luis Marques - 2.9.4-4 / 2.9.5-1 / 2.9.6
-- Redmine #71894    - Integração de CTe - Emissão Própria - Documento Autorizado Adicionado por Gabriel 19 dias atrás. 
--                     Atualizado aproximadamente 6 horas atrás.
-- Rotinas Alteradas - pkb_int_ws - Incluido tipo de objeto de integração 1 e 3.
--                     pkb_ler_ct_d100_int_ws - Cursor ajustado para trazer conhecimentos de transporte proprio que sejam LEGADO.
--                     pkb_vld_ct_d100 - Tirado validação para só conhecimento de emissão de terceiro e não de armazenamento na leitura.
--
-- ====================================================================================================================
-- Em 24/07/2013 - Angela Inês.
-- Correções nas mensagens.
--
-- Em 26/12/2013 - Angela Inês.
-- Redmine #1644 - Considerar os Conhecimentos de Transporte com dm_arm_cte_terc igual a 0.
--
-- Em 21/05/2015 - Rogério Silva.
-- Redmine #8054 - Implementar package pk_vld_amb_ws
--
-- Em 02/10/2015 - Angela Inês.
-- Redmine #11914 - Acompanhar os processos que estão sendo desenvolvidos.
-- Para a integração dos conhecimentos de transporte de terceiros não deve ser exigido o código da natureza de operação.
-- Rotina: pk_vld_amb_d100.pkb_vld_ct_d100 - cursor c_ct_d100.
--
-- Em 05/02/2016 - Rogério Silva
-- Redmine #13079 - Registro do Número do Lote de Integração Web-Service nos logs de validação
--
-- Em 24/01/2018 - Karina de Paula
-- Redmine #38656 - Processos de integração de Conhecimento de Transporte - Modelo D100.
-- Incluido o modelo fiscal 67 para todas as rotinas que estão tratando o modelo 57-Conhecimento de Transporte Eletrônico
--
-- Em 20/06/2018 - Karina de Paula
-- Redmine #40168 - Conversão de CTE e Geração dos campo COD_MUN_ORIG e COD_MUN_DEST no registro D100 do Sped de ICMS e IPI
-- Rotina Alterada: pkb_ler_ct_d100 => Incluído os novos parâmetros na chamda da pk_csf_api_d100.pkb_integr_ct_d100
--
-- Em 21/06/2018 - Marcos Ferreira
-- Redmine #29340 - Integração de Conhecimento de Transporte - Processo de Integração WEb Service - Não chama processo de rotina programável
-- Problema: Ao fazer a integração de conhecimento de transporte, a valida ambiente não chamava as rotinas programáveis
-- Solução: Incluído chamada das rotinas programáveis na procedure pkb_ler_ct_d100_int_ws
-- Procedimentos alterados: pkb_ler_ct_d100_int_ws
--
-- Em 27/06/2018 - Angela Inês.
-- Redmine #43520 - Lote de Integração WS rejeitado com notas autorizadas.
-- Eliminar a recuperação do Mult-Org através do Lote de Integração WS, e recuperar da Empresa vinculada com o Conhecimento de Transporte.
-- Rotina: pkb_ler_ct_d100_int_ws.
--
-- Em 31/10/2018 - Karina de Paula
-- Redmine #47549 - Adaptar packages de integração
-- Rotina Criada: pkb_ler_conhec_transp_imp_ret
--
-- Em 09/04/2019 - Fernando Basso
-- Redmine #53141 - Ajustar tags ibge_cidade_ini e ibge_cidade_fim - SPED
-- Complementação da chamada de conhecimento de transporte
-- Rotina: pkb_vld_ct_d100
--
-- Em 23/09/2019 - Luis Marques
-- Redmine #48353 - Ao fazer upload do CTe pelo compliance, o participante não é Cadastrado/Atulizado.
-- Rotinas Alteradas: pkb_ler_ct_d100, pkb_vld_ct_d100 - Incluido chamada para nova rotina pkb_ler_Conhec_Transp_Emit
--                    para gravar os dados do emitente.
--
-------------------------------------------------------------------------------------------------------

-- Variáveis globais utilizadas no processo
   gv_cpf_cnpj_emit   varchar2(14);
   gn_multorg_id      mult_org.id%type;

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a validação de Conhecimentos de Transporte
procedure pkb_integracao;

-------------------------------------------------------------------------------------------------------

-- Procedimento de validação de dados de Conhecimento de Transporte de Terceiro, oriundos de Integração por Web-Service
procedure pkb_int_ws ( en_loteintws_id      in     lote_int_ws.id%type
                     , en_tipoobjintegr_id  in     tipo_obj_integr.id%type
                     , sn_erro              in out number
                     );

-------------------------------------------------------------------------------------------------------

end pk_vld_amb_d100;
/
