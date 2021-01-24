CREATE OR REPLACE PACKAGE CSF_OWN.PK_VALID_ATUAL_PARAM_PC IS

----------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- Em 07/01/2021   - João Carlos
-- Redmine #74522  - Parâmetros gerais Sped Contribuições, quando a escrituração é centralizada o plano de contas
--                 - deverá ser o da matriz e não da filial. 
-- Alterações      - Alterado cursor c_empresa para retornar um campo com o id da empresa Matriz,
--                 - Alteração da chamada da pk_csf_efd_pc.fkb_recup_pcta_ccto_pc, enveiando para retorno do plano de contas
--                 - o ID da empresa Matriz.
-- Rotina          - PKB_VAL_ATU_PC
--
-- Em 10/08/2020 - Allan Magrini
-- Redmine #68646 - Melhoria na Rotina de geração de contas EFD
-- Alterados as chamadas fkb_recup_pcta_ccto_pc novo campo COD_ST_PISCOFINS da tabela PARAM_EFD_CONTR_GERAL
-- Rotina: PKB_VAL_ATU_CC,PKB_VAL_ATU_PC
--
-- Em 21/07/2020 - thiago Denadai / Armando
-- Redmine #69584 - Validação e atualização de informações blocos A,C,D,F e I – Insert de contas contábeis para modelo cupom 59 - SAT
-- Rotina: PKB_VAL_ATU_PC
--
-- Em 03/06/2019 - Renan Alves
-- Redmine #54799 - Atualizar a packge PK_VALID_ATUAL_PARAM_PC
-- Foi incluído o modelo de documento fiscal 'ND - Nota de Débito' nos cursores C_A170_CT e C_A170_PL.
-- Rotina: pkb_val_atu_cc e pkb_val_atu_pc
-- 
-- Em 03/10/2018 - Angela Inês.
-- Redmine #47522 - Alterar o processo de Atualização de Plano de Conta - Sped EFD-Contribuições.
-- No processo que atualiza os planos de contas, considerar as notas fiscais de modelo "65" da mesma forma que são consideradas as notas fiscais de modelo "55".
-- Rotina: pkb_val_atu_pc.
--
-- Em 06/07/2018 - Karina de Paula
-- Redmine #44759 - Melhoria Apuração PIS/COFINS - Bloco F100
-- Rotina Alterada: PKB_VAL_ATU_CC / PKB_VAL_ATU_PC => Retirada a verificação dm_gera_receita
--
-- Em 16/05/2018 - Angela Inês.
-- Redmine #42924 - Correções nos processos de Validação e Atualização de Plano de Contas e Centros de Custos - Sped EFD-Contribuições.
-- Atualizar os conhecimentos de transporte com o código da conta contábil.
-- Será atualizado o código da conta encontrado para o Imposto do PIS, e caso não tenha, será atualizado com o código da conta encontrado para o imposto da COFINS.
-- Tabela: conhec_transp.cod_cta. Tabelas: ct_comp_doc_pis.planoconta_id e ct_comp_doc_cofins.planoconta_id.
-- Rotina: pkb_val_atu_pc.
--
-- Em 25/04/2018 - Karina de Paula
-- Redmine #41878 - Novo processo para o registro Bloco F100 - Demais Documentos e Operações Geradoras de Contribuições e Créditos.
-- Incluída a verificação do campo dm_gera_receita = 1, nos cursores dos objetos abaixo:
-- -- Rotina Alterada: PKB_VAL_ATU_CC / PKB_VAL_ATU_PC
--
-- Em 25/04/2018 - Angela Inês.
-- Redmine #42169 - Correções: Registro C100 - Atualização do Plano de Contas; Conversão de CTE - CFOP.
-- Registro C100 - Notas Fiscais de modelo 55. Na montagem do arquivo utilizamos o Código da Conta Contábil através do Item da Nota Fiscal
-- (item_nota_fiscal.cod_cta). Correção: No processo de atualização de plano de conta, não verificar se as notas possuem valores isentos de créditos para
-- atualização do Código da Conta Contábil no Item da Nota Fiscal. Antes: cod_st diferente de ('70','71','72','73','74','75'). Depois: não considerar o cod_st.
-- Rotina: pkb_val_atu_pc - cursor c_c170_pl.
--
-- Em 23/03/2018 - Angela Inês.
-- Redmine #40901 - Correção nas funções que recuperam Plano de Contas de Centros de Custos.
-- Eliminar as funções: fkb_recup_pcta_pis, fkb_recup_pcta_cofins, fkb_recup_ccust_pis e fkb_recup_ccust_cofins.
--
-- Em 11/01/2018 - Angela Inês.
-- Redmine #38390 - Correção na validação para recuperação das NFS-e, Venda de Consumidor e Redução Z.
-- Recuperar as informações das NFS-e, Venda de Consumidor e Redução Z, para atualização do Plano de Contas e Centro de Custo.
-- Rotina: pkb_val_atu_pc.
--
-- Em 10/01/2018 - Angela Inês.
-- Redmine #38364 - Correção na recuperação dos parâmetros - Planos de Contas e Centros de Custos - PIS e COFINS.
-- 1) Atender a recuperação dos planos de contas e centros de custos através dos parâmetros enviados dos documentos fiscais e registros dos Blocos F e I.
-- 2) Não encontrando parâmetros através do item 1, o processo irá recuperar os planos de contas e centros de custos com apenas um dos campos enviado no parâmetro, e os outros como sendo nulos. Exemplo: en_dm_ind_emit = tabela, e os outros campos da tabela como sendo nulos (is null).
-- 3) Criar processo para validar o período de validade do parâmetro: data inicial e data final, tabela param_efd_contr_geral.
-- Não poderá existir mais de um período aberto sem a data de finalização, e não poderá ocorrer períodos com intervalos intercalados em outros períodos.
-- Rotinas: pkb_val_per, pkb_val_atu_pc e pkb_val_atu_cc.
--
-- Em 09/01/2018 - Angela Inês.
-- Redmine #38308 - Correções nos processos de validação.
-- Os registros que possuem data devem estar dentro do período inicial e final utilizado para validação.
-- Rotinas: pkb_val_atu_pc e pkb_val_atu_cc.
--
-- Em 12/12/2017 - Angela Inês.
-- Especificação da package - Processo de validação das informações dos Blocos A, C, D, F e I.
-- Rotinas para validação dos parâmetros para PIS e COFINS, dos registros dos blocos A, C, D, F e I.
-- Redmine #37054. 
--
----------------------------------------------------------------------------------------------------------------------------------------------------------
--| Variáveis dos tipos de registros
   gt_row_valid_atual_param_pc   valid_atual_param_pc%rowtype;

--| Declaração de constantes
   erro_de_validacao  constant number := 1;
   erro_inform_geral  constant number := 35; -- 35-Informação Geral
   erro_de_sistema    constant number := 2;

--| Variáveis para logs/mensagens
   gv_obj_referencia  log_generico.obj_referencia%type := null;
   gn_referencia_id   log_generico.referencia_id%type := null;
   gv_mensagem_log    log_generico.mensagem%type := null;
   gv_resumo_log      log_generico.resumo%type := null;

---------------------------------------------------------------------------------------------------------------------------------------------------
-- Processo para validar nos documentos relacionados aos blocos  A, C, D, F e I, a ausência e atualização dos planos de contas e centros de custos
-- Rotina a ser executada através da tela/portal/menu: Sped/PIS-COFINS/Validação e Atualização dos Registros
-- Parâmetro de entrada:
-- en_validatualparampc_id: tabela valid_atual_param_pc, coluna id.
--
PROCEDURE PKB_VALIDAR_ATUALIZAR( EN_VALIDATUALPARAMPC_ID IN VALID_ATUAL_PARAM_PC.ID%TYPE );

----------------------------------------------------------------------------------------------------------------------------------------------------------

END PK_VALID_ATUAL_PARAM_PC;
/
