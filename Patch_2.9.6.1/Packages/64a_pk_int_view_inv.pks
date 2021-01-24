create or replace package csf_own.pk_int_view_inv is

-------------------------------------------------------------------------------------------------------
--
-- Especificação do pacote de procedimentos de integração e validação de Inventário
--
-- Em 07/12/2020   - Luis Marques - 2.9.5-4 / 2.9.6-1 / 2.9.6
-- Redmine #72072  - erro
-- Rotina Alterada - pkb_inventario - Colocdado verificação para quando tiver log de erro verificar se os log(s) do
--                   registro são só de advertencia colocar como 1-Validado e não 2-Erro de validação.
--
-- Em 06/11/2020   - Luis Marques - 2.9.4-5 / 2.9.5-2 / 2.9.6
-- Redmine #72903  - Inventário integrado mas não mostra mensagem nos logs.
-- Rotina Alterada - pkb_inventario - Ajustando contador para mostrar a quantidade de registros com erro, (IF) bloqueado.
--
-- Em 30/10/2020   - Luis Marques - 2.9.4-5 / 2.9.5-2 / 2.9.6
-- Redmine #72903  - Inventário integrado mas não mostra mensagem nos logs.
-- Rotina Alterada - pkb_inventario - Colocado verificação com a data de ultimo fechamento se a data de referencia
--                   for nula usa a data de inventário na verificação com a data de ultimo fechamento.
--
-- Em 29/09/2020   - Luis Marques - 2.9.4-4 / 2.9.5-1 / 2.9.6
-- Redmine #71874  - Integração de dados do Inventário.
-- Rotina Alterada - pkb_inventario - Colocado no where de montagem do select se o campo DT_REF for nulo pega pelo
--                   campo DT_INVENTARIO da view de inventário.
--
-- Em 04/12/2019 - Luis Marques
-- Redmine #61686 - Adicionar valor ao dominio INVENTARIO.DM_MOT_INV
-- Rotina Alterada: pkb_inventario - Colocado trunc para data de referencia na leitura dos dados do inventário.
--
-- ====================================================================================================
-- Em 28/12/2012 - Angela Inês.
-- Ficha HD 65154 - Fechamento Fiscal por empresa.
-- Verificar a data de último fechamento fiscal, não permitindo integrar se a data estiver posterior ao período em questão.
--
-- Em 14/01/2013 - Angela Inês.
-- Alterar a integração, considerando somente os registros com valor de item maior que zero (vw_csf_inventario.vl_item > 0).
--
-- Em 26/02/2014 - Angela Inês.
-- Redmine #2087 - Passar a gerar log no agendamento quando a data do documento estiver no período da data de fechamento.
-- Rotina: pkb_inventario.
--
-- Em 16/10/2014 - Rogério Silva
-- Redmine #4067 - Processo de contagem de registros integrados do ERP (Agendamento de integração)
--
-- Em 21/10/2014 - Rogério Silva
-- Redmine #4067 - Processo de contagem de registros integrados do ERP (Agendamento de integração)
--
-- Em 12/10/2014 - Rogério Silva
-- Redmine #5508 - Desenvolver tratamento no processo de contagem de dados
--
-- Em 13/12/2014 - Leandro Savenhago
-- Redmine #5520 - Adequação da package pk_int_view_inv para Mult-Organização
--
-- Em 14/04/2015 - Rogério Silva
-- Redmine #7650 - Analisar todos os processos de integração, corrigir a busca dos parâmetros de empresa
-- Rotina: pkb_integracao
--
-- Em 17/04/2015 - Angela Inês.
-- Redmine #7763 - Registro H010 - Inventário - Processo de Integração.
-- Alterar o processo de integração de inventário considerando a view VW_CSF_INVENTARIO_FF. Considerar o novo campo VL_ITEM_IR.
-- Rotina: pkb_inventario_ff.
--
-- Em 27/05/2015 - Rogério Silva.
-- Redmine #8228 - Processo de Registro de Log em Packages - Inventário de estoque de produtos
--
-- Em 18/02/2017 - Fábio Tavares
-- Redmine #28545 - Alterar o tipo do log de Integração do Inventário
-- pkb_ler_inventario.
--
-- Em 01/03/2017 - Leandro Savenhago
-- Redmine 28832- Implementar o "Parâmetro de Formato de Data Global para o Sistema".
-- Implementar o "Parâmetro de Formato de Data Global para o Sistema".
--
-- Em 16/06/2017 - Marcos Garcia
-- Redmine #30475 - Avaliações nos Processos de Integração e Relatórios de Inconsistências - Processo de Fechamento Fiscal.
-- Atividade: Parametrização do log com o tipo 39-fechamento fiscal
--            referencia_id nula, obj_referencia = a tabela atual no momento da integração e a empresa solicitante da integração.
--            Log de fechamento fiscal aparecerá nos relatórios de integração.
--
--  Em 30/06/2017 - Leandro Savenhago
-- Redmine #31839 - CRIAÇÃO DOS OBJETOS DE INTEGRAÇÃO - STAFE
-- Criação do Procedimento PKB_STAFE
--
-- Em 19/07/2017 - Marcos Garcia
-- Redmine# 30475 - Avaliações nos Processos de Integração e Relatórios de Inconsistências - Processo de Fechamento Fiscal.
-- Criação da variavel global info_fechamento, que é alimentada antes do inicio das integrações
-- com o identificador do fechamento fiscal.(csf_tipo_log).
--
-- Em 25/08/2018 - Angela Inês.
-- Redmine #46371 - Agendamento de Integração cujo Tipo seja "Todas as Empresas".
-- Incluir o identificador do Mult-Org como parâmetro de entrada (mult_org.id), para Agendamento de Integração como sendo do Tipo "Todas as Empresas".
-- Rotina: pkb_integr_periodo_geral.
--
-------------------------------------------------------------------------------------------------------

-- Especificação de array

--| Informações de Inventário
   type tab_csf_inventario is record ( cpf_cnpj       varchar2(14)   
                                     , cod_item       varchar2(60)
                                     , dt_inventario  date
                                     , sigla_unid     varchar2(6)
                                     , qtde           number(14,3)
                                     , vl_unit        number(15,6)
                                     , vl_item        number(15,2)
                                     , dm_ind_prop    number(1)
                                     , cod_part       varchar2(60)
                                     , txt_compl      varchar2(255)
                                     , cod_cta        varchar2(30)
                                     , dt_ref         date
                                     , dm_mot_inv     varchar2(2)
                                     );
--
   type t_tab_csf_inventario is table of tab_csf_inventario index by binary_integer;
   vt_tab_csf_inventario t_tab_csf_inventario;
--| Informações de Inventário - Flex Field
   type tab_csf_inventario_ff is record ( cpf_cnpj       varchar2(14)
                                        , cod_item       varchar2(60)
                                        , dt_inventario  date
                                        , atributo       varchar2(60)
                                        , valor          varchar2(255)
                                        );
--
   type t_tab_csf_inventario_ff is table of tab_csf_inventario_ff index by binary_integer;
   vt_tab_csf_inventario_ff t_tab_csf_inventario_ff;
--
--| Informações Complementares do Inventario
   type tab_csf_invent_cst is record ( cpf_cnpj       varchar2(14)
                                     , dt_inventario  date
                                     , cod_item       varchar2(60)
                                     , cod_st         varchar2(3)
                                     , vl_bc_icms     number(15,2)
                                     , vl_icms        number(15,2)
                                     );
--
   type t_tab_csf_invent_cst is table of tab_csf_invent_cst index by binary_integer;
   vt_tab_csf_invent_cst t_tab_csf_invent_cst;
--
-------------------------------------------------------------------------------------------------------

   gv_sql varchar2(4000) := null;

-------------------------------------------------------------------------------------------------------

   GV_ASPAS CHAR(1) := null;

   GV_NOME_DBLINK    empresa.nome_dblink%type := null;
   GV_OWNER_OBJ      empresa.owner_obj%type := null;
   GV_FORMATO_DT_ERP empresa.FORMATO_DT_ERP%type := null;

-------------------------------------------------------------------------------------------------------

-- Declaração de constantes

   ERRO_DE_VALIDACAO       CONSTANT NUMBER := 1;
   ERRO_DE_SISTEMA         CONSTANT NUMBER := 2;
   INFORMACAO              CONSTANT NUMBER := 35;

-------------------------------------------------------------------------------------------------------

   gv_mensagem_log       Log_Generico_inv.mensagem%TYPE;
   gv_obj_referencia     Log_Generico_inv.obj_referencia%type := 'INVENTARIO';
   gn_referencia_id      Log_Generico_inv.referencia_id%type := null;
   --
   gv_cpf_cnpj           varchar2(14) := null;
   gv_cd_obj             obj_integr.cd%type := '2';
   gn_multorg_id         mult_org.id%type;
   gn_empresa_id         empresa.id%type;
   gv_formato_data       param_global_csf.valor%type := null;
   --
   info_fechamento       number;

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração
procedure pkb_integracao ( en_empresa_id  in  empresa.id%type
                         , ed_dt_ini      in  date
                         , ed_dt_fin      in  date 
                         );

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração de cadastros
procedure pkb_integracao_normal ( ed_dt_ini      in  date
                                , ed_dt_fin      in  date 
                                );

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração por período
procedure pkb_integr_periodo_geral ( en_multorg_id in mult_org.id%type
                                   , ed_dt_ini     in date
                                   , ed_dt_fin     in date
                                   );

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração Geral de empresas para o CT
procedure pkb_integr_geral_empresa ( en_paramintegrdados_id in param_integr_dados.id%type
                                   , ed_dt_ini              in date
                                   , ed_dt_fin              in date
                                   , en_empresa_id          in empresa.id%type
                                   );

-------------------------------------------------------------------------------------------------------

end pk_int_view_inv;
/
