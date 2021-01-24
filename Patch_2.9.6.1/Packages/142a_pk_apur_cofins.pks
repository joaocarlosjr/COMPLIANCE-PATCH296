CREATE OR REPLACE PACKAGE CSF_OWN.PK_APUR_COFINS IS

-------------------------------------------------------------------------------------------------------------------------------
-- Especificação do pacote de procedimentos de Geração da Apuração de Crédito de Cofins - Bloco M  
-------------------------------------------------------------------------------------------------------------------------------
--
-- Em 05/01/2021   - Luis Marques - 2.9.5-4 / 2.9.6-1 / 2.9.7
-- Redmine #74674  - Geração do registro M100 - Código do Tipo de Crédito para servicos de transporte gerando como agroindustria
-- Rotina alterada - PKB_MONTA_DADOS_M500 - Inclusão do parametro en_pessoa_id na chamada da função "fkg_relac_tipo_cred_pc_id"
--                   para ser usado nma verificação para os CST de 60 a 66.
--
-- Em 23/12/2020 - Eduardo Linden
-- Redmine #74516 - Alteração na rotina de geração do registro M100 e M500 - codigo 201
-- Para metodo de Apropriação Direta e código 201, a montagem dos registros M500 e M505 terão alguns campos zerados.
-- Rotina alterada: pkb_monta_dados_m500
-- Liberado para o Release 2.9.6 e os Patches 2.9.5.3 e 2.9.4.6
--
-- Em 23/11/2020 - Eduardo Linden
-- Redmine #73614 - Alteração na rotina de geração do registro M100 e M500
-- Alteração da rotina a fim de nivelar os registros para tabela mem_calc_apur_cofins e o array vt_tab_reg_m500
-- Rotina Alterada: pkb_monta_dados_m500
-- Liberado para o Release 2.9.6 e os Patches 2.9.5.2 e 2.9.4.5
--
-- Em 23/10/2020 - Renan Alves  
-- Redmine #72973 - Erro persiste 
-- Foi alterado o cursor C_VL_DED_COF/C_VL_DED_COFINS para que realize o cálculo da matriz e filiais.
-- Rotina: PKB_CALCULA_BLOCO_1700,
--         PKB_VALIDAR_CONS_COFINS_M600
-- Patch_2.9.5.2 / Patch_2.9.4.5 / Release_2.9.6
--
-- Em 23/11/2020 - Eduardo Linden
-- Redmine #73614 - Alteração na rotina de geração do registro M100 e M500
-- Alteração da rotina a fim de nivelar os registros para tabela mem_calc_apur_cofins e o array vt_tab_reg_m500
-- Rotina Alterada: pkb_monta_dados_m500
-- Liberado para o Release 2.9.6 e os Patches 2.9.5.2 e 2.9.4.5
--
-- Em 02/10/2020     - Luis Marques - 2.9.4-5 / 2.9.5-1 / 2.9.6
-- Redmine #71597    - Duplicidades nos registros do M400/M800 com base no F100
-- Rotina Alterada   - PKB_MONTA_DADOS_M800 - Incluido no cursor "c_f100_planoconta" verificação através das tabelas
--                     NAT_REC_PC, COD_ST e TIPO_IMPOSTO a qual imposto se refere neste caso ao PIS.
--
-- Em 01/10/2020 - Renan Alves
-- Redmine #71983 - Erro de cálculo no SPED Contribuições (pk_valida_abertura_efd_pc.pkb_gera_apur_pis fase(65))
-- Foi incluído um NVL nas colunas que alimentam as colunas vt_mem_calc_apur_cofins.aliq_perc, vt_mem_calc_apur_cofins.aliq_prod
-- vt_mem_calc_apur_cofins.vl_imp_trib do vetor da memória de cálculo
-- Rotina: PKB_MONTA_DADOS_M500, 
--         PKB_MONTA_DADOS_M600_F,
--         PKB_MONTA_DADOS_M600_ACD, 
--         PKB_CALCULA_BLOCO_1700
-- Patch_2.9.5.1 / Patch_2.9.4.4 / Release_2.9.6
--
-- Em 04/08/2020     - Luis Marques
-- Redmine #65981    - Ajustar controle de credito de Pis e Cofins
-- Rotinas alteradas - PKB_CALCULAR_CONS_COFINS_M600 - Colocada nova variável na chamada da rotina "pkb_calcula_bloco_1500"
--                     de controle de saldo que devolve valor utilizado nos registros 1500 com saldo. 
--                     PKB_CALCULA_BLOCO_1500 - Nova variável para devolver total utilizado pelo(s) registros 1500 com
--                     saldo, ajustado processo de calculo para devolver o total utilizado pelos registro 1500 com saldo.
--
-- Em 20/07/2020   - Luis Marques - 2.9.3-5 / 2.9.4-2 / 2.9.5
-- Redmine #69083  - Ajuste de regra de geração do M400 e M800
-- Rotina alterada - PKB_MONTA_DADOS_M800 - Incluido cursor para ler registros F100 sem item só por plano de contabil
--                   e parametrizado na tabela "PLANO_CONTA_NAT_REC_PC". 
--
-- Em 02/06/2020 - Renan Alves
-- Redmine #68016 - Erro no M400 com NCM preenchido no item da nota fiscal
-- Foi alterado a mensagem de erro dos pontos que verificam se existe conta contábil para a nota fiscal.
-- Rotina: pkb_monta_dados_m800   
-- Patch_2.9.3.3 / Patch_2.9.2.6 / Release_2.9.4   
--
-- Em 30/04/2020 - Eduardo Linden
-- Redmine #64368 - Erro ao gerar EFD contribuições referente a M400/800 com F500 tributado
-- Incluir tratamento sobre geração do M800 para CST's '04', '06', '07', '08', '09' e '05' sobre aliquota PIS zerada
-- Rotina: pkb_monta_dados_m800
-- Disponivel para os patch's 2.9.2.5 e 2.9.3.2 e release 2.9.4
--
-- Em 13/04/20120 - Marcos Ferreira
-- Distribuições: 2.9.2-3 / 2.9.3
-- Redmine #66751 - Erro na Geração do Sped Contribuições - Memória de Calculo
-- Rotina: pkb_grava_vet_mem_calc_cofins
-- Alterações: Tratativa de campo que não estava sendo populado
--
-- Em 13/04/2020 - Renan Alves
-- Redmine #65928 - Erro ao gerar M400_M800 empresa Cumulativo
-- Foi incluído o Regime de Competência - Escrituração detalhada, com base nos registros dos Blocos A, C, D e F (DM_IND_REG_CUM = 9)
-- no IF que verifica a escrituração de operações com incidência (gn_dm_cod_inc_trib in = 1 ou 3).
-- Rotina: pkb_monta_dados_m800  
-- Patch_2.9.3.1 / Release_2.9.4 
--
-- Em 03/03/2020 - Renan Alves
-- Redmine #64870 - Erro no M400/410 - M800/810 para modelo 59 (SAT) - RELATO DE BUG [200213-1200]
-- Foi implementado a geração do cupom fiscal sat (modelo 59).  
-- Rotina: pkb_monta_dados_m800   
-- Patch_2.9.3.1 / Release_2.9.4 
--
-- Em 26/02/20120 - Marcos Ferreira
-- Redmine #49905: - especificação Memória de Cálculo EFD Contribuições
-- Rotinas: PKB_MONTA_DADOS_M500
--          PKB_MONTA_DADOS_M600_F
--          PKB_MONTA_DADOS_M600_ACD
--          PKB_RET_PERCONSCONTRCOFINS
--          FKG_RET_REGISTREFDPC_ID 
--          PKB_MONTA_VET_MEM_CALC_COFINS 
--          PKB_GRAVA_VET_MEM_CALC_COFINS
--          PKB_EXCLUI_MEM_CALC_COFINS 
--          PKB_DESPR_PER_APUR_COFINS_M500
--          PKB_DESPR_PER_CONS_COFINS_M600  
-- Alterações: Criação de funcionalidade para geração de memória de calculo
--
-- Em 07/01/2020 - Eduardo Linden
-- Redmine #63309 - Feed - geração do M400/M800 
-- Rotina alterada: PKB_MONTA_VETOR_M800_PREGC - Ajuste para que seja feito era feita nas ativ anteriores (#61542, #61589, #62183 e #62444), e acrescentando nova function 
--                                               para obter o primeiro plano de conta a partir da conta contabil (plano_conta_nat_rec_pc).
--
-- Em 03/01/2020 - Eduardo Linden
-- Redmine #63246 - Alteração da geração do M400/M800 a partir do F500/F550
-- Rotina alterada: PKB_MONTA_VETOR_M800_PREGC - Correção na geração do registro M800 a partir do registro F500/F550. 
--                                               O id do plano de conta virá a partir da tabela plano_conta_nat_rec_pc.
--
-- Em 11/12/2019 - Eduardo Linden
-- Redmine #62444: Correção sobre validação do código de plano de conta - M400/M800
-- Rotina alterada: PKB_MONTA_DADOS_M800 - Ajuste feito sobre validação do id do plano de conta, a fim de evitar erro ORA-06502: PL/SQL numeric or value error.
--
-- Em 09/12/2019 - Eduardo Linden
-- Redmine #62183 - Correção para os registros M400/800 - EFD PIS/COFINS
-- Rotina Alterada: PKB_MONTA_DADOS_M800 - Incluir validação sobre id do plano de conta. Se preenchido, irá prosseguir na geração do registro.
--                                         Caso contrário, será gerado um log informando que plano de conta não é valido ou não está preenchido. 
--
-- Em 03/12/2019 - Luis Marques
-- Redmine #61854 - Registro M100/M500 - Sped contribuições
-- Rotina Alterada: PKB_MONTA_DADOS_M500 - Colocado distinct no cursor "c_d100" pois estva trazendo registro duplicado,
--                  dois registros analiticos como o mesmo CFOP.
--
-- Em 22/11/2019 - Eduardo Linden
-- Redmine #61589 - feed - M400/410 e M800/810
-- Troca de mensagem e dos ids dos planos de conta nos registros M800 e M810.
-- Rotina Alterada: PKB_MONTA_VETOR_M800_PREGC
--
-- Em 22/11/2019 - Eduardo Linden
-- Redmine #61542 - feed - Não está enxergando que há parametro na nat receita
-- Troca de mensagem sobre por não encontrar registro na tabela PLANO_CONTA_NAT_REC_PC (pk_csf.fkg_ncmnatrecpc_npp_id)  
-- Rotina Alterada: PKB_MONTA_VETOR_M800_PREGC
--
-- Em 21/11/2019 - Eduardo Linden
-- Redmine #61496 - feed - Erro geração
-- Foram feitos ajustes na geração dos logs sobre os planos de conta não estar parametrizado no Regime de Caixa Escrituração consolidada 
-- e na geração dos registros M400 e M800 através dos registros F500 e F550.
-- Rotinas Alteradas: PKB_MONTA_DADOS_M800 e PKB_MONTA_VETOR_M800_PREGC
--
-- Em 20/11/2019 - Eduardo Linden
-- Redmine #61429 - feed - Erro no processo
-- Inclusão de log de erro sobre a geraçao do M800/M810 e correção dos cursores de F500 e F550.
-- Rotinas corrigidas: PKB_MONTA_VETOR_M800_PREGC e PKB_MONTA_DADOS_M800 
--
-- Em 08/11/2019 - Eduardo Linden
-- Redmine #57982 - [PLSQL] Geração do M400/800 a partir do F500
-- Inclusão da geração dos registros M800 e M810, a partir dos registros F500 e F550.
-- Alteração na Geração dos registros M800 e M810, será considerado id do plano de conta a partir das tabelas
-- NAT_REC_PC e NCM_NAT_REC_PC
-- Rotinas Alteradas: PKB_MONTA_DADOS_M800 e PKB_MONTA_VETOR_M800.
-- Rotina Criada    : PKB_MONTA_VETOR_M800_PREGC (para regime cumulativo)
--
-- Em 05/11/2019 - Luis Marques
-- Redmine #60540 - SPED contribuições receitas isentas M400/M410 e M800/810
-- Rotina Alterada: PKB_MONTA_DADOS_M800 - Colocada verificação se gera receita para não considerar receitas isentas.
--
-- Em 06/11/2019 - Allan Magrini
-- Redmine #60888 - Valor Contabil SAT
-- Correção no cursor c_c860, foi alterado o campo na busca de item_cupom_fiscal.VL_PROD
-- para item_cupom_fiscal.VL_ITEM_LIQ
-- Rotina: PKB_MONTA_DADOS_M600_ACD 
--
-- Em 22/05/2019 - Renan Alves
-- Redmine #54480 - Mais de um registro M200/M600 no mesmo arquivo.
-- Foi declarada a variável VN_CH_CONC_CS_CR_ALIQ_M600 para ser utilizada na posição do vetor VT_TAB_REG_M600
-- pois o mesmo deve ter apenas uma posição, segundo o guia prático.
-- Rotina: pkb_monta_vetor_m600
--
-- Em 24/04/2019 - Marcos Ferreira
-- Redmine #53749 - ERRO DE CALCULO M200/600
-- Solicitação: Corrigir erro de Validação para os registros M600 quando utilizado quantidade na base de calculo do Cofins
-- Alterações: Inclusão de Calculo para vl_cont_apur quando utilizado quantidade na base de calculo de Cofins
-- Procedures Alteradas: PKB_CALCULAR_CONS_COFINS_M600
--
-- Em 05/04/2019 - Renan Alves
-- Redmine #53146 - Erro ao Gerar EFD Contribuições.
-- Foi incluído mais um REPLACE, removendo o "-", "/", "\" do parâmetro COD_CTA na chamada da PKB_MONTA_VETOR_M800
-- Rotina: pkb_monta_dados_m800 
--
-- Em 20/03/2019 - Renan Alves 
-- Redmine #51130 - Sped Contribuições - Regime Cumulativo.
-- Foram incluídos os novos códigos '03' e '05' na natureza da pessoa jurídica (gv_dm_ind_nat_pj).
-- Rotinas: pkb_monta_dados_m600_f e pkb_monta_dados_m600_acd
--
-- Em 15/03/2019 - Angela Inês.
-- Redmine #52518 - Ajuste nos valores de Apuração do PIS e da COFINS - Blocos M105 e M505.
-- Após recuperar os valores dos documentos fiscais para geração das Apurações de PIS e COFINS, verificar se o valor no detalhe dos Blocos M105 e M505, estão de
-- acordo com os valores apurados na Receita Bruta - Registro 0111.
-- M505 - VL_BC_PIS_CUM = (m505.vl_bc_pis_tot * 0111.rec_bru_cum / 0111.rec_bru_total)
-- M505 - VL_BC_PIS_NC = (m505.vl_bc_pis_tot - m505.vl_bc_pis_cum)
-- A tolerância utilizada para refazer o cálculo é de até 0,50. Caso a diferença seja maior que 0,50, o processo não fará alteração e a diferença irá continuar
-- aparecendo na validação do PVA.
-- Rotina: pkb_grava_dados_m500.
--
-- Em 11/03/2019 - Angela Inês.
-- Redmine #52217 - Performance - Processo de Geração de Dados do Sped EFD-Contribuições.
-- Eliminar os comentários devido as mudanças nos códigos.
-- Rotinas: pkb_monta_dados_m500, pkb_dados_per_apur_cofins_m500, pkb_monta_dados_m600_f, pkb_monta_dados_m600_acd, pkb_dados_per_cons_cofins_m600,
-- pkb_monta_dados_m800, e pkb_dados_per_rec_cofins_m800.
--
-- Em 08/03/2019 - Angela Inês.
-- Redmine #52217 - Performance - Processo de Geração de Dados do Sped EFD-Contribuições.
-- 1) Verificar os processos de geração dos dados para o arquivo do Sped EFD-Contribuições: utilização do comando TRUNC em datas e Funções utilizadas nos
-- comandos SELECT.
-- 2) Verificar os processos de validação dos dados para o arquivo do Sped EFD-Contribuições: utilização do comando TRUNC em datas e Funções utilizadas nos
-- comandos SELECT.
-- Rotinas: pkb_monta_dados_m500, pkb_dados_per_apur_cofins_m500, pkb_monta_dados_m600_f, pkb_monta_dados_m600_acd, pkb_dados_per_cons_cofins_m600,
-- pkb_monta_dados_m800, e pkb_dados_per_rec_cofins_m800.
--
-- Em 08/03/2019 - Renan Alves
-- Redmine #52219 - Erro ao calcular período - SPED Contribuições
-- Foi incluído mais um REPLACE, removendo o espaço do parâmetro COD_CTA na chamada da PKB_MONTA_VETOR_M800
-- Rotina: pkb_monta_dados_m800
--
-- Em 13/02/2019 - Marcos Ferreira
-- Redmine #51462 - Alterações PLSQL para atender layout 005 (vigência 01/2019)
-- Alterações: 1) PKB_CALCULAR_CONS_COFINS_M600: Criação de Variáveis para o controle de Ajustes
--             2) Criado Cursor c_vl_ajus_acres_bc_cofins para buscar valores de ajuste da Base de Calculo
--             3) Alterado Update da tabela det_cons_contr_cofins com inclusão de novos campos do ajuste da Base de Calculo
--
-- Em 03/12/2018 - Angela Inês.
-- Redmine #49297 - Especificação para geração do registro D200.
-- 1) Apuração de COFINS - Bloco M500.
-- Considerar para apuração somente os conhecimentos de transporte cuja operação seja "Entrada" (conhec_transp.dm_ind_oper=0), podendo ser de "Emissão Própria"
-- ou de "Terceiro" (conhec_transp.dm_ind_emit=0/=1). Os modelos fiscais "63-Bilhete de Passagem Eletrônico – BP-e" e "67-Conhecimento de Transporte Eletrônico -
-- Outros Serviços", passam a ser recuperados.
-- Rotina: pkb_monta_dados_m500.
-- 2) Consolidação de COFINS - Bloco M600.
-- Considerar para consolidação os conhecimentos de transporte autorizados (conhec_transp.dm_st_proc=4), não seja de armazenamento (conhec_transp.dm_arm_nf_terc=0),
-- operação de "Saída" (conhec_transp.dm_ind_oper=1), e emissão seja de "Emissão Própria" (conhec_transp.dm_ind_emit=0). Para os modelos fiscais, considerar: "07-
-- Nota Fiscal de Serviço de Transporte", "08-Conhecimento de Transporte Rodoviário de Cargas", "8B-Conhecimento de Transporte de Cargas Avulso", "09-Conhecimento
-- de Transporte Aquaviário de Cargas", "10-Conhecimento Aéreo", "11-Conhecimento de Transporte Ferroviário de Cargas", "26-Conhecimento de Transporte Multimodal
-- de Cargas", "27-Nota Fiscal De Transporte Ferroviário De Carga", "57-Conhecimento de Transporte Eletrônico", "63-Bilhete de Passagem Eletrônico – BP-e" e "67-
-- Conhecimento de Transporte Eletrônico - Outros Serviços". Considerar os conhecimentos que possuem Impostos PIS e/ou COFINS com as CSTs: "01-Operação Tributável
-- (base de cálculo = valor da operação alíquota normal (cumulativo/não cumulativo))", "02-Operação Tributável (base de cálculo = valor da operação (alíquota
-- diferenciada))", "03-Operação Tributável (base de cálculo = quantidade vendida x alíquota por unidade de produto)", "05-Operação Tributável (substituição
-- tributária)".
-- Rotina: pkb_monta_dados_m600_acd.
--
-- Em 14/11/2018 - Angela Inês.
-- Redmine #48717 - Apuração do PIS e da COFINS - Bloco M100 e M500.
-- Considerar a Empresa Matriz para apuração do PIS e da COFINS, ao recuperar através do CFOP, a base de cálculo de crédito. O processo está considerando a
-- empresa vinculada aos documentos fiscais, que pode ser a matriz ou suas filiais, e o cadastro está vinculado somente as empresas matrizes.
-- Rotina: pkb_monta_dados_m500.
--
-- Em 13/11/2018 - Angela Inês.
-- Redmine #48693 - Correção na geração do Bloco M100 - Variável Array - Índice.
-- Alterar o índice que armazena os valores dos Blocos M100 e M500, para tipo caracter.
-- O processo armazena com o tipo numérico, e devido ao tamanho, quantidade de números para gerar o índice, o processo técnico não aceita, devendo ser alterado
-- para tipo caracter, com tamanho de 20 posições.
-- Variável/array: vt_tab_reg_m500.
--
-- Em 31/10/2018 - Angela Inês.
-- Redmine #48321 - Inclusão do processo de F600 em geração do 1300 e/ou 1700.
-- Na geração do cálculo dos Blocos 1300 para PIS e 1700 para COFINS, considerar os valores da Contribuição Retida na Fonte - Bloco F600, que foram integrados
-- através de View de Integração, onde a situação do registro é "7-Integração por view de banco de dados".
-- Rotina: pkb_calcula_bloco_1700.
--
-- Em 29/10/2018 - Eduardo Linden
-- Redmine #48152 - Tabela de Operações Geradoras de Crédito de PIS/COFINS - Incluir Identificador da Empresa.
-- Inclusão da coluna empresa_id da tabela oper_ger_cred_pc nas clausulas dos cursores c_c100 e c_c100_ee.
-- Rotina: PKB_MONTA_DADOS_M500.
--
-- Em 17/08/2018 - Angela Inês.
-- Redmine #46140 - Processos de Apuração e Geração do Sped EFD-Contribuições.
-- 1) Incluir as NF Mercantil de modelo 55, com CFOP vinculado a Energia Elétrica, nas apurações de PIS e COFINS - Blocos M100 e M500.
-- 2) Considerar o parâmetro de Gerar Escrituração como Sim, para fazer a apuração dos Blocos M100 e M500.
-- Rotina: pkb_monta_dados_m500.
--
-- Em 13/08/2018 - Angela Inês.
-- Redmine #45912 - Agrupamento para apuração dos Blocos M400 e M800 - Plano de Contas.
-- Utilizar o Código do Plano de Conta para fazer o agrupamento, e não mais o identificador do plano de conta. Fazer a correção para PIS e COFINS.
-- Variável Global: vt_tab_reg_m800.
-- Rotina: pkb_monta_dados_m800.
--
-- Em 24/07/2018 - Angela Inês.
-- Redmine #45284 - Correção na Apuração de PIS e COFINS - Blocos 1300 e 1700.
-- A) Os valores a serem lançados no arquivo dos registros do Bloco 1300 e 1700, serão do mês corrente, do mês da abertura do arquivo.
-- B) Verificar o processo da Consolidação para geração automática dos Blocos 1300 e 1700.
--
-- Em 06/07/2018 - Karina de Paula
-- Redmine #44759 - Melhoria Apuração PIS/COFINS - Bloco F100
-- Rotina Alterada: PKB_MONTA_DADOS_M500 / PKB_MONTA_DADOS_M600_F / PKB_MONTA_DADOS_M800 => Retirada a verificação dm_gera_receita
--
-- Em 29/06/2018 - Angela Inês.
-- Redmine #44515 - Processo do Sped EFD-Contribuições: Cálculo, Validação e Geração do Arquivo.
-- Revisar todos os processos de Cálculo, Validação e Geração do Arquivo Sped EFD-Contribuições.
-- Rotinas: pkb_monta_dados_m600_acd e pkb_monta_dados_m800.
--
-- Em 24/04/2018 - Karina de Paula
-- Redmine #41878 - Novo processo para o registro Bloco F100 - Demais Documentos e Operações Geradoras de Contribuições e Créditos.
-- Incluída a verificação do campo dm_gera_receita = 1, nos objetos abaixo:
-- -- Rotina Alterada: PKB_MONTA_DADOS_M500   - Alterado o select do cursor c_f100
-- -- Rotina Alterada: PKB_MONTA_DADOS_M600_F - Alterado o select do cursor c_f100
-- -- Rotina Alterada: PKB_MONTA_DADOS_M800   - Alterado o select do cursor c_f100 / no select q conta a qtd Não validados - COFINS / Sem item e sem ncm - COFINS
--
-- Em 16/04/2018 - Marcos Ferreira.
-- Redmine: #41435 - Processos - Criação de Parâmetros CST de PIS e COFINS para Geração e Apuração do EFD-Contribuições.
-- Alterado Procedure PKB_MONTA_DADOS_M800, incluído parametros de cst na chamada da função fkg_gera_escr_efdpc_cfop_empr
-- dos cursores
-- Em 11/04/2018 - Marcos Ferreira.
-- Redmine: #41435 - Processos - Criação de Parâmetros CST de PIS e COFINS para Geração e Apuração do EFD-Contribuições.
-- Alterado a Procedure PKB_MONTA_DADOS_M200_ACD:
--   1) Incluído campo cst.id cst_id_pis no cursor c_a100_aj
--   2) Incluído campo cst.id cst_id_pis no cursor c_c100_aj
--   3) Incluído campo cst.id cst_id_pis no cursor c_c400_aj
--   4) Incluído campo cst.id cst_id_pis no cursor c_c380_aj
--   5) Incluído campo cst.id cst_id_pis no cursor c_c860_aj
--   6) Incluído campo cst.id cst_id_pis no cursor c_d600_aj
--   7) Modificado a estrutura de parâmetros do if da vn_fase := 3.1;
--   8) Modificado a estrutura de parâmetros do if da vn_fase := 6.1;
--   9) Modificado a estrutura de parâmetros do if da vn_fase := 9.1;
--  10) Modificado a estrutura de parâmetros do if da vn_fase := 12.1;
--  11) Modificado a estrutura de parâmetros do if da vn_fase := 15.1;
--  12) Modificado a estrutura de parâmetros do if da vn_fase := 18.1;
--
-- Em 29/09/2017 - Angela Inês.
-- Redmine #35139 - Correção na Apuração do PIS e da COFINS - Valores da Receita Bruta.
-- Na recuperação dos dados da abertura, para apuração do PIS e da COFINS - Blocos M100/M500, corrigir a comparação do período, data inicial e final,
-- com o período da apuração. Quando houver abertura dos registros Original e Retificação, iremos recuperar o registro que não tenha arquivo gerado (dm_situacao
-- difere de 1-erro de validação, 3-gerado arquivo, 4-Erro na geração do arquivo, 5-Erro de cálculo, 7-Em geração).
-- Rotina: pkb_dados_abert_empr.
--
-- Em 18/09/2017 - Marcelo Ono.
-- Redmine #32616 - Correção nas mensagens de logs do bloco M500.
-- Alterado a função TO_DATE pelo TO_CHAR nas mensagens de log do bloco M500.
-- Rotinas: pkb_monta_dados_m500
--
-- Em 30/08/2017 - Angela Inês.
-- Redmine #34186 - Correção na geração da consolidação do Bloco M200/M600 com apropriação de crédito do Bloco 1100/1500.
-- 1) A geração do Mês 05/2014 não gerou apuração de valores M100, por isso não foi possível recuperar os valores para utilização dos créditos do Bloco 1100.
-- Utilizamos o tipo de crédito do M100 para recuperar o mesmo tipo de crédito do 1100.
-- Correção: Corrigir a recuperação do valores de créditos do Bloco 1100/1500, sem considerar a apuração do Bloco M100/M500. Ordenar do mais antigo para o mais
-- recente (ano/mes), e em seguida pelo tipo de crédito.
-- 2) Corrigir o processo de recuperação dos valores de crédito do 1100/1500, considerando somente os valores que foram utilizados para o período em questão para
-- compôr o valor do crédito descontado de período anterior.
-- Rotinas: pkb_calcular_cons_cofins_m600 e pkb_calcula_bloco_1500.
--
-- Em 28/08/2017 - Angela Inês.
-- Redmine #34082 - Correção na Consolidação - Blocos M200 e M600, e arquivo Sped EFD - Valores de Crédito dos Blocos 1100 e 1500.
-- Alterar nos processos da Consolidação do PIS e da COFINS:
-- 1) Valores de crédito utilizados dos Blocos 1100/1500.
-- 2) Exclusão de dados.
-- 3) Desprocessamento da consolidação.
-- Rotinas: pkb_calcula_bloco_1500, pkb_excl_per_cons_cofins_m600 e pkb_desproc_cons_cofins_m600.
--
-- Em 23/05/2017 - Angela Inês.
-- Redmine #31360 - Processo de Consolidação do M200/M600 - Recuperação dos valores do Bloco F600.
-- Considerar os registros do Bloco F600, com situação de integração sendo 0-Indefinido (que seriam os digitados), e 10-Gerado por Impostos Retidos sobre
-- Receita. Ao recuperar os valores de retenção, considerar o valor retenção de pis/cofins do Imposto retido quando a situação de integração for 10-Gerado por
-- Impostos Retidos sobre Receita; e, considerar o valor de retenção de pis/cofins do próprio registro com situação de integração 0-Indefinido.
-- Rotina: pkb_calcular_cons_cofins_m600, cursores c_vl_ret_apu e c_vl_imp_cofins.
--
-- Em 19/04/2017 - Angela Inês.
-- Redmine #30373 - Alterar o processo de validação - Bloco M200/M600 - Valor retido na fonte deduzido no período - não-cumulativo e cumulativo.
-- 1) Para Bloco M200: Além dos valores recuperados do Bloco F600, recuperar também os valores do Bloco 1300, não-cumulativo e cumulativo.
-- 2) Para Bloco M600: Além dos valores recuperados do Bloco F600, recuperar também os valores do Bloco 1700, não-cumulativo e cumulativo.
-- Rotina: pkb_validar_cons_cofins_m600 - cursores: c_vl_ret_apu_nc e c_vl_ret_apu_cum.
--
-- Em 17/04/2017 - Angela Inês.
-- Redmine #30237 - Recuperar os valores dos Registros 1300 (PIS), e 1700 (COFINS) - Composição dos valores retidos em fonte deduzidos no período - Cumulativo e
-- Não-Cumulativo - Bloco M200/M600.
-- A) Para montar o valor do campo CONS_CONTR_COFINS.VL_RET_NC - Bloco M600 - Valor Retido na Fonte Deduzido no Periodo Não-Cumulativo.
-- B) Para montar o valor do campo CONS_CONTR_COFINS.VL_RET_CUM - Bloco M600 - Valor Retido na Fonte Deduzido no Período Cumulativo.
-- Utilizar os valores dos registros dos Blocos F600 e 1700.
-- Rotina: pkb_calcular_cons_cofins_m600 - cursor c_vl_ret_apu.
--
-- Em 22/12/2016 - Angela Inês.
-- Redmine #26515 - Correção no processo de consolidação - Blocos M200/M600 e Blocos 1100/1500.
-- No processo de cálculo da consolidação: Não gerar valores para utilização futura no Bloco 1100/1500 quando houver saldo na consolidação do Bloco M200/M600.
-- Somente gerar valores para utilização futura no Bloco 1100/1500 quando houver saldo na apuração do Bloco M100/M500.
-- Rotina: pkb_calcula_bloco_1500.
--
-- Em 20/12/2016 - Angela Inês.
-- Redmine #8147 - Bloco M. Processo da Apuração da COFINS.
-- Implementar no processo da apuração da COFINS os novos registros M515 e M625, descritos no Bloco M do Guia Prático da EFD Contribuições.
-- Rotinas: pkb_excl_per_apur_cofins_m500, pkb_calcular_apur_cofins_m500, pkb_validar_apur_cofins_m500, pkb_grava_dados_m600, pkb_excl_per_cons_pis_m600,
-- pkb_calcular_cons_cofins_m600, pkb_validar_cons_cofins_m600
--
-- Em 09/12/2016 - Angela Inês.
-- Redmine #26165 - Geração dos Blocos M200/M600 - Saldos utilizados nos Blocos M100/M500.
-- Considerar os códigos de tipo de crédito gerados na apuração de pis/cofins (m100/m500), ordenados pela ordem crescente de códigos, para serem utilizados na
-- consolidação de pis/cofins (m200/m600). Hoje o processo ordena pelo primeiro dígito do código.
-- Rotina: pkb_calcular_cons_cofins_m600.
--
-- Em 05/12/2016 - Angela Inês.
-- Redmine #26007 - Gerar o valor do saldo apurado - Bloco M100/M500, quando maior que zero(0), como crédito futuro em Bloco 1100/1500.
-- Rotinas: pkb_exclui_bloco_1500_m500, pkb_gera_bloco_1500_m500, pkb_calcula_bloco_1500 e pkb_calcular_cons_cofins_m600.
--
-- Em 30/11/2016 - Angela Inês.
-- Redmine #25896 - Correção na geração dos valores de consolidação - Bloco M200/M600, relacionado aos valores dos controles de créditos fiscais do Bloco 1100/1500.
-- Rotinas: pkb_calcula_bloco_1500 e pkb_calcular_cons_cofins_m600.
--
-- Em 22/11/2016 - Angela Inês.
-- Redmine #25627 - Geração automática dos Blocos 1100/1500 através da Consolidação dos Blocos M200/M600.
-- Gerar as informações do Bloco 1100/1500 através do cálculo dos Blocos M200/M600, somente se não houver lançamento com saldo nos meses anteriores dos Blocos
-- 1100/1500. Gerar o saldo não atendido pelos lançamentos dos Blocos 1100/1500, para utilizações futuras, ou seja, para os meses posteriores.
-- Rotina: pkb_calcula_bloco_1500.
--
-- Em 17/11/2016 - Angela Inês.
-- Redmine #25444 - Processo de PIS e COFINS - Geração Geral.
-- Adaptar os processos de PIS e COFINS de acordo com manual do Sped EFD-Contribuições e Programa Validador do Governo, para atender aos Regime de Caixa
-- Escrituração consolidada (Registro F500), Regime de Competência - Escrituração consolidada (Registro F550), e Regime de Competência - Escrituração detalhada,
-- com base nos registros dos Blocos A, C, D e F.
--
-- Em 19/10/2016 - Angela Inês.
-- Redmine #24520 - Correção na geração da consolidação de PIS e COFINS - Blocos 1100 e 1500.
-- No cálculo do Bloco 1100 e 1500, considerar somente os valores de saldo de crédito disponível das apurações M100 e M500.
-- Rotina: pkb_calcula_bloco_1500.
--
-- Em 10/10/2016 - Angela Inês.
-- Redmine #24269 - Correção na geração da consolidação de PIS e COFINS - Blocos 1100 e 1500.
-- Refazer a recuperação dos valores dos Blocos 1100 e 1500 para compôr os valores da consolidação dos Blocos M200 e M600.
-- Quando for utilizar parte do valor do bloco 1100/1500, gerar outra linha no bloco 1100/1500 com o valor a utilizar, e subtrair do registro digitado o valor
-- parcial utilizado.
-- Rotina: pkb_calcular_cons_pis_m600.
--
-- Em 05/10/2016 - Angela Inês.
-- Redmine #22803 - NFE de energia elétrica informada no reg. C500.
-- Não considerar as Notas Fiscais de Modelo 55, com itens de CFOP vinculados ao tipo de operação 4-Energia Elétrica, para compôr os valores da apuração do
-- pis e da cofins - Blocos M100 e M500.
-- Rotina: pkb_monta_dados_m500.
--
-- Em 26/09/2016 - Angela Inês.
-- Redmine #23791 - Correção nas apurações de PIS e COFINS e geração do arquivo Sped EFD-Contribuições.
-- Considerar os registros com data anterior ao período em questão e de origem digitação.
-- Rotina: pkb_calcular_cons_cofins_m600/cursor c_vl_cred_desc.
-- Revisar os processos considerando o cálculo somente se houver registros do Bloco 1500 com saldo para serem utilizados.
-- Rotina: pkb_calcular_bloco_1500.
--
-- Em 21/09/2016 - Angela Inês.
-- Redmine #23644 - Processo de Exclusão dos Blocos M200/M600 e Desprocesssamento dos Blocos M100/M500.
-- 1) Processo de desprocessar por apuração - Bloco M500. Verificar se existem relacionamentos gerados pelo Bloco M600, entre os Blocos M500 e 1500, e não
-- permitir o desprocessar. Rotina: pkb_despr_apur_cofins_m500.
-- 2) Processo de excluir a consolidação por período - Bloco M600. Excluir/Alterar os relacionamentos entre os Blocos M500 e 1500. Rotina: pkb_excl_per_cons_cofins_m600.
--
-- Em 14/07/2016 - Angela Inês.
-- Redmine #21324 - Correção na Geração dos Blocos 1100/1500 e Geração do Arquivo.
-- Na apuração do crédito, Blocos M100/M500, considerar o valor do crédito descontado na geração do Bloco 1100/1500, quando o saldo de crédito disponível
-- estiver zerado.
-- Rotina: pkb_calcula_bloco_1500.
--
-- Em 12/07/2016 - Angela Inês.
-- Redmine #21255 - Correção na geração do Bloco 1100/1500 automático pelos Blocos M200/M600 e Geração do Arquivo.
-- Geração do Bloco 1100/1500 automático pelos Blocos M200/M600:
-- Considerar os valores a ser utilizados no bloco 1100/1500 somando o saldo que estiver no mesmo mês.
-- Rotina: pkb_calcula_bloco_1500.
--
-- Em 01/07/2016 - Angela Inês.
-- Redmine #20872 - Geração do Arquivo Sped EFD-Contribuições. Blocos 1100/1500.
-- No cálculo do Bloco M600, recuperar o valor de crédito descontado no Bloco 1500 (contr_cred_fiscal_cofins.vl_cred_desc_efd), caso seja maior que zero, de
-- períodos anteriores até o período em questão. Utilizar os valores até que o saldo fique zerado ou maior que zero (cons_contr_cofins.vl_tot_cred_desc_ant).
-- Alterar o registro do Bloco 1500 com o identificador do Bloco M600 (contr_cred_fiscal_cofins.conscontrcofins_id).
-- Rotinas: pkb_calcular_cons_pis_m600, pkb_excl_per_cons_cofins_m600 e pkb_despr_per_cons_cofins_m600.
--
-- Em 30/06/2016 - Angela Inês.
-- Redmine #20737 - Processo de PIS e COFINS - Geração automática do Bloco 1100/1500.
-- Inclusão do processo para gerar registros de controle de créditos fiscais - bloco 1500.
-- Rotina: pkb_calcular_cons_pis_m600/pkb_calcula_bloco_1500.
-- Inclusão das novas tabelas para excluir os registros e desfazer os processos.
-- Rotinas: pkb_excl_per_cons_cofins_m600 e pkb_despr_per_cons_cofins_m600.
-- Redmine #20812 - Processo de PIS e COFINS - Geração do Bloco M100/M500.
-- Inclusão das novas tabelas para excluir os registros e desfazer os processos.
-- Rotinas: pkb_excl_per_apur_cofins_m500 e pkb_despr_per_apur_cofins_m500.
--
-- Em 12/05/2016 - Angela Inês.
-- Redmine #18819 - Correção na geração do SPED EFD-Contribuições - Bloco M200 e M600.
-- Apuração da COFINS: Considerar a montagem do registro M610 quando o documento fiscal só possui informações que geram apenas ajustes - bloco M620.
-- Rotina: pkb_monta_vetor_m620.
--
-- Em 03/05/2016 - Angela Inês.
-- Redmine #18448 - Correção na geração do EFD-Contribuições - Blocos M200 e M600.
-- 1) Excluir somente os registros gerados automaticamente do Bloco M605 (cons_contr_cofins_or.dm_origem=1).
-- Rotina: pkb_excl_per_cons_cofins_m600.
-- 2) Somar os valores Digitados do bloco M605 - Contribuição para o COFINS a Recolher, para compôr os valores da contribuição não-cumulativa e cumulativa a recolher
-- e o total da contribuição a recolher.
-- Rotina: pkb_calcular_cons_cofins_m600.
--
-- Em 15/04/2016 - Angela Inês.
-- Redmine #17699 - Correção na geração do arquivo Sped-EFD, Apuração do PIS e Apuração da COFINS.
-- Recuperação das notas fiscais de modelo '21' e '22' para a consolidação - Bloco M600.
-- Rotina: pkb_monta_dados_m600.
--
-- Em 07/04/2016 - Angela Inês.
-- Redmine #17136 - Correção na geração dos blocos D500 e D600 - Notas Fiscais de Comunicação - Sped EFD-Contribuições.
-- Considerar para o cursor c_d500, somente as notas fiscais de ENTRADA de modelos '21' e '22' - Serviço Contínuo de Comunicação.
-- Rotina: pkb_monta_dados_m500.
--
-- Em 04/03/2016 - Fábio Tavares
-- Redmine #8096 - Processo de Apuração do COFINS – Blocos M, Implementar as mudanças de acordo com o Sped para recuperação dados da Apuração das Operações
-- das Instituições Financeiras, Seguradoras, Entidades de Previdência Privada, Operadoras de Planos de Assistência à Saúde e demais Pessoas Jurídicas.
-- Rotina: pkb_monta_dados_m800.
--
-- Em 28/10/2015 - Angela Inês.
-- Redmine #12470 - Verificar/Alterar o processo de geração do Bloco M610 - Sped EFD-Contribuições.
-- Fazer a correção necessária para atender os registros do Cupom Fiscal Eletrônico (CFe/SAT), de acordo com o arquivo do Sped EFD:
-- REGISTRO C870: RESUMO DIÁRIO DE DOCUMENTOS EMITIDOS POR EQUIPAMENTO SAT-CF-E (CÓDIGO 59) – PIS/PASEP E COFINS
-- REGISTRO C880: RESUMO DIÁRIO DE DOCUMENTOS EMITIDOS POR EQUIPAMENTO SAT-CF-E (CÓDIGO 59) – PIS/PASEP E COFINS APURADO POR UNIDADE DE MEDIDA DE PRODUTO
-- Os valores escriturados nos campos de bases de cálculo 07 (VL_BC_PIS) e 11 (VL_BC_COFINS) correspondentes a itens vendidos com CST representativos de receitas
-- tributadas, serão recuperados no Bloco M, para a demonstração das bases de cálculo do PIS/Pasep e da Cofins, nos Campos “VL_BC_CONT” dos registros M210 e M610,
-- respectivamente.
-- Rotina: pkb_monta_dados_m600.
--
-- Em 22/09/2015 - Angela Inês.
-- Redmine #11794 - Geração dos Blocos M100 e M500 - PIS/COFINS.
-- Ao recuperar os valores da apuração de pis e cofins - bloco m100 e m500, não considerar as notas fiscais de modelo '55' e os itens que possuem a CFOP 1252.
-- Rotina: pkb_monta_dados_m500 - cursor c_c100.
-- Redmine #11795 - Geração dos Blocos M200 e M600 - PIS/COFINS.
-- Ao recuperar os valores dos Bloco 1100 e 1500, para consolidação da contribuição - Blocos M200 e M600, considerar os valores de todos os meses anteriores
-- ao do cálculo em questão. O processo recuperava os valores do mês do cálculo.
-- Rotinas: pkb_calcular_cons_cofins_m600 e pkb_validar_cons_cofins_m600 - cursor c_vl_cred_desc.
--
-- Em 27/07 e 13/08/2015 - Angela Inês.
-- Redmine #10117 - Escrituração de documentos fiscais - Processos.
-- Inclusão do novo conceito de recuperação de data dos documentos fiscais para retorno dos registros.
--
-- Em 08/07/2015 - Angela Inês.
-- Redmine #9934 - Correção no Ajuste automático Blocos M210 e M610.
-- Correção: O processo não estava executando o cursor correto para recuperação das notas fiscais mercantis. Houve um erro de desenvolvimento na chamada do processo.
-- Essa correção deverá ser efetuada nas versões 265, 266, 267 e 268; e, alterar o FTP nas versões 265 e 266.
-- Rotina: pkb_monta_dados_m600, cursor de: c_a100_aj para: c_c100_aj.
--
-- Em 09-11/06/2015 - Angela Inês.
-- Redmine #9024 - Apuração automática dos ajustes dos Blocos M200 e M600 - Sped EFD-Contribuições.
-- 1) Ao calcular os valores de ajuste deveríamos recuperar as notas fiscais com cfop de entrada (1,2,3), com os parâmetros gera_receita=0-não / gera_escr=0-não /
--    ajuste_m210=1-sim, e de acordo com as alíquotas comparar na tabela do COD_CONTR, em qual código será relacionado o valor, e armazenar em VL_AJUS_REDUC,
--    somando os valores tributados de PIS (m200) e COFINS (m600).
-- 2) Para essas notas fiscais com cfop de entrada (1,2,3), e todos os itens citados acima, verificar se o CST for 75, armazenar no código de situação tributária
--    (31 ou 32-SUFRAMA).
-- 3) Ao calcular os valores de ajuste deveríamos recuperar as notas fiscais com cfop de saída (5,6,7), com os parâmetros gera_receita=0-não / gera_escr=0-não /
--    ajuste_m210=1-sim, e de acordo com as alíquotas comparar na tabela do COD_CONTR, em qual código será relacionado o valor, e armazenar em VL_AJUS_ACRES,
--    somando os valores tributados de PIS (m200) e COFINS (m600).
-- 4) Para ambos os casos, considerar valores cumulativos e não-cumulativos, considerar as alíquotas, e se for alíquota diferenciada, considerar o campo
--    relacionado na abertura do arquivo que indica se é cumulativo ou não-cumulativo, se o regime for cumulativo e não-cumulativo, armazenar nos códigos que
--    forem não-cumulativos.
-- 5) Recuperar em pkb_dados_abert_empr, o indicador da atividade abertura_efd_pc.dm_ind_ativ, para identificar se a abertura é de atividade imobiliária.
-- Rotinas: pkb_monta_dados_m200, pkb_monta_vetor_m200 e pkb_monta_vetor_m220.
--
-- Em 19/05/2015 - Angela Inês.
-- Redmine #8519 - Sped contribuições M205/M605
-- Atualizar a geração dos pagamentos automáticos - Bloco M200/M205 e Bloco M600/M605.
-- Informar o número do campo do registro “M200”: Campo 08-contribuição não-cumulativa ou Campo 12-contribuição cumulativa.
-- Rotina: pkb_calcular_cons_cofins_m600 e pkb_validar_cons_cofins_m600.
--
-- Em 26/02/2015 - Angela Inês.
-- Redmine #6583 - Erro na geração do bloco M400 - Rotina Programável.
-- Incluir o parâmetro de entrada MULTORG_ID nas rotinas que utilizam a função pk_csf_efd_pc.fkg_nat_rec_pc_id.
--
-- Em 22/01/2015 - Angela Inês.
-- Redmine #5972 - EFD Contribuições - pagtos automáticos - Alterações nos processos de apuração.
-- Alterar os processos para as novas colunas:
-- Diferenciar nos processos os parâmetros de acordo com os valores a serem gerados - valor cumulativo e/ou valor não-cumulativo.
-- Rotina: pkb_calcular_cons_cofins_m600.
--
-- Em 21/01/2015 - Angela Inês.
-- Redmine #5873 - Os blocos M300 e M700 estão excluindo o registro mesmo o EFD fechado.
-- Rotina: pkb_excluir_contr_cofins_m700.
--
-- Em 12/01/2015 - Angela Inês.
-- Redmine #5799 - Erro na tela ao excluir bloco M com o período fechado.
-- Rotinas: pkb_excl_per_apur_cofins_m500, pkb_excl_per_cons_cofins_m600 e pkb_excl_per_rec_cofins_m800.
--
-- Em 06/01/2015 - Angela Inês.
-- Redmine #5616 - Adequação dos objetos que utilizam dos novos conceitos de Mult-Org.
--
-- Em 26/12/2014 - Angela Inês.
-- Redmine #5622 - Geração dos Blocos M200 e M600 com os valores do Bloco F700.
-- Correção: Considerar o valor de dedução de COFINS do Bloco F700, quando não houver impostos retidos para serem deduzidos.
-- Rotina: pkb_calcular_cons_cofins_m600.
--
-- Em 05/12/2014 - Angela Inês.
-- Redmine #5355 - Diferença na soma das receitas isentas nos blocos M800 e M400, no SPED contribuições.
-- Correção: Não somar o valor do imposto IPI tributado ao valor do item bruto, para compôr o valor da receita.
-- Rotina: pkb_monta_dados_m800.
--
-- Em 26/11/2014 - Angela Inês.
-- Redmine #5002/#4591 - EFD contribuições está validado, mas está deixando incluir registro novo, processar e excluir.
-- Conferência dos blocos M/PIS.
-- 1) Processos M500/M600/M700/M800: Não permitir cálculo/validação/exclusão do Período de Apuração se houver Arquivo gerado ou validado.
-- 2) Processos M500/M600/M700/M800: Não permitir cálculo/validação/exclusão da Apuração se houver Arquivo gerado ou validado.
--
-- Em 22/10/2014 - Angela Inês.
-- Redmine #4878 - Correção no cálculo do Bloco M600 - Consolidação da Contribuição do COFINS.
-- Totalizar os valores gerados no rateio relacionados aos campos: Valor de Retenção Não-Cumulativo e Valor de Outras Deduções.
-- Rotina: pkb_calcular_cons_cofins_m600.
--
-- Em 13/10/2014 - Angela Inês.
-- Redmine #4725 - Cálc. Consol. da Contribuição do COFINS - Bloco M600 - Cálculo.
-- Correção no processo para geração dos dados do Registro M605: Contribuição para a COFINS a recolher - Detalhamento por código de receita.
-- 1) Alterar a geração dos dados no processo de cálculo do bloco M600: Considerar os registros conforme os valores dos campos Não-Cumulativo e Cumulativo.
-- 2) Alterar o processo de validação do bloco M605: valores cumulativo e valores não-cumulativos; dm_num_campo; e, dm_origem.
-- Rotina: pkb_calcular_cons_cofins_m600 e pkb_validar_cons_cofins_m600.
--
-- Em 01/10/2014 - Angela Inês.
-- Redmine #4569 - Alterar o processo do Bloco M600 com relação a geração do Bloco 1700 - Controle de Retenção na Fonte do COFINS.
-- Os valores de retenção serão rateados por DM_IND_NAT_RET, e os valores de dedução serão rateados por Data de Retenção e CNPJ, para lançamentos no Bloco 1700.
-- Rotina: pkb_calcular_cons_cofins_m600.
-- Alterar o processo de exclusão e desfazer, considerando contr_vlr_ret_fonte_cofins.dm_origem = 1-Gerado no Bloco M600.
-- Rotina: pkb_excl_per_cons_cofins_m600 e pkb_desproc_cons_cofins_m600.
--
-- Em 12/09/2014 - Angela Inês.
-- Redmine #4159 - Notas Fiscais de Serviço sem Itens - Recuperação dos valores de PIS e COFINS.
-- 1) Ao recuperar o identificador do tipo de crédito para as notas fiscais mercantis, considerar como valor de base de cálculo, o campo de valor de base de
--    cálculo total.
-- 2) Ao recuperar os valores do bloco M505 de acordo com o rateio proporcional para o valor VL_BC_COFINS, considerar como valor base o valor do campo VL_BC_COFINS_NC.
-- Rotinas: pkb_monta_dados_m500 e fkg_recup_vl_bc_cofins.
-- 3) Ao recuperar os valores do controle de valores retidos da fonte de cofins, cumulativo e não-cumulativo - Bloco F600, considerar da empresa matriz e filiais.
-- Rotinas: pkb_calcular_cons_pis_m600 e pkb_validar_cons_pis_m600.
--
-- Em 05/09/2014 - Angela Inês.
-- Redmine #4097 - Erro de validação Bloco M100 e M500.
-- Correção nos processos de geração do Bloco M500 - Apuração da COFINS:
-- 1) Para o valor de "vl_bc_cofins_nc", considerar o campo "vl_bc_cofins_cum" para subtrair do valor da base de crédito.
-- Rotina: pkb_monta_dados_m500.
--
-- Em 07/08/2014 - Angela Inês.
-- Redmine #3704 - Processo de Apuração do COFINS - Geração do Bloco M600.
-- 1) Gerar os valores dos Pagamentos - Bloco M605, após gerar o Bloco M600, desde que o valor da contribuição não cumulativa seja maior que zero
-- (cons_contr_cofins.vl_cont_nc_rec > 0), ou que o valor da contribuição cumulativa seja maior que zero (cons_contr_cofins.vl_cont_cum_rec > 0).
-- Recuperar os valores informados nos parâmetros de EFD-Contribuições (tabela: param_efd_contr).
-- Considerar para as colunas:
-- cons_contr_cofins_or.id                   = conscontrcofinsor_seq.nextval
-- cons_contr_cofins_or.conscontrcofins_id   = cons_contr_cofins.id
-- cons_contr_cofins_or.dt_vencto            = param_efd_contr.dia_pagto||(to_number(to_char(per_cons_contr_cofins.dt_ini,'mm')) + param_efd_contr.qtde_mes_subsq)||to_char(per_cons_contr_cofins.dt_ini,'rrrr')
-- cons_contr_cofins_or.vl_rec               = cons_contr_cofins.vl_cont_nc_rec > 0 ou cons_contr_cofins.vl_cont_cum_rec > 0
-- cons_contr_cofins_or.tiporetimp_id        = param_efd_contr.tiporetimp_id_cof
-- cons_contr_cofins_or.tiporetimpreceita_id = param_efd_contr.tiporetimpreceita_id_cof
-- Obs.: Para cons_contr_cofins_or.dt_vencto verificar se a soma do mês não ultrapasse 12, e neste caso, alterar o mês para 01 e somar um ao ano em questão.
-- 2) Fazer a validação dos valores dos Pagamentos:
-- a) Tabela.coluna: cons_contr_cofins_or.tiporetimp_id. Tipo de Retenção do Imposto COFINS - Validação: consistir o imposto COFINS.
-- b) Tabela.coluna: cons_contr_cofins_or.tiporetimpreceita_id. Tipo de Retenção do Imposto COFINS de Receita - Validação: consistir se está relacionado com o Tipo de Retenção do Imposto COFINS (cons_contr_cofins_or.tiporetimp_id).
-- 3) Ao desfazer a situação da consolidação, excluir os registros de Pagamentos.
--
-- Em 25/06/2014 - Angela Inês.
-- Redmine #3163 - Alterações da EFD Contribuições (Pis/Cofins) - Apuração da COFINS.
-- 1) Registro M505: Preenchimento facultativo do Campo 06 (VL_BC_COFINS_NC), uniformizando com a regra de não obrigatoriedade de campo já especificada.
--    Alterar a recuperação dos valores de DET_APUR_CRED_COFINS.VL_BC_COFINS_CUM, para que sejam recuperados se o campo ABERTURA_EFD_PC_REGIME.DM_COD_INC_TRIB
--    for 3-Escrituração de operações com incidência nos regimes nãocumulativo e cumulativo.
--    Rotina: pk_apur_cofins.pkb_monta_dados_m500.
--
-- Em 22/04/2014 - Angela Inês.
-- Redmine #2692 - Validação Indevida dos registro M400 e M800.
-- Alteração: No final da geração dos registros M800 verificamos se ficaram algum registro com situação <> Validado e/ou com situação = Validado mas sem
-- Item/NCM, e retornamos uma mensagem do tipo informação.
-- Nessas verificações não estava sendo considerado o código ST de acordo com a regra de negócio: CST 04, 06, 07, 08, 09 e 05 com Alíquota Zero(0).
-- Rotina: pkb_monta_dados_m800.
--
-- Em 14/04/2014 - Angela Inês.
-- Redmine #2672 - Não está sendo mostrado o CFOP que foi gerado o ajuste M610.
-- Rotina: pkb_monta_vetor_m600.
--
-- Em 08/04/2014 - Angela Inês.
-- Redmine #2454 - Embora a Geração do EFD Contribuições está com o status Validado ou Gerado o Portal permite que o usuário abra o Bloco M.
-- Rotinas: pkb_despr_apur_cofins_m500, pkb_desproc_cons_cofins_m600, pkb_desproc_contr_cofins_m700 e pkb_desproc_rec_cofins_m800.
--
-- Em 03/04/2014 - Angela Inês.
-- Redmine #2576 - Feedback - Não pode criar mais de um registro 1300 e 1700 para o mesmo período de escrituração.
-- 1) Quando é utilizada toda a contribuição retida na fonte não deve ser gerado registro no bloco 1700. Rotina: pkb_calcular_cons_pis_m600.
-- 2) Ao desprocessar M600 apagar o registro do bloco 1700. Rotina: pkb_desproc_cons_cofins_m600.
-- 3) Ao desprocessar a abertura do EFD apagar o registro do bloco 1700. Rotina: pkb_excl_per_cons_cofins_m600.
--
-- Em 02/04/2014 - Angela Inês.
-- Redmine #2573 - Alterar o tipo de indexador da geração dos blocos M505 para VARCHAR2, pois como numérico o valor não comporta o tamanho.
-- Rotina: pkb_monta_vetor_m500.
-- Ao gerar M600 atualizar os valores da apuração M500 quando o valor da contribuição não-cumulativa estiver zerado e deixar como utilização de valor parcial.
-- Rotina: pkb_calcular_cons_cofins_m600.
--
-- Em 27/03/2014 - Angela Inês.
-- Redmine #2429 - Não pode criar mais de um registro 1300 e 1700 para o mesmo período de escrituração.
-- Rotina: pkb_calcular_cons_cofins_m600.
-- Redmine #2416 - Processo de cálculo do M105 e M505.
-- No "Processo de cálculo do M110 e M510", foi decidido que quando o "Código da Base de Cálculo do Crédito" for "13-Outras Operações com Direito a Crédito",
-- atribuir a própria descrição na "justificativa do crédito".
-- Rotina: pkb_monta_vetor_m500.
--
-- Em 11/03/2014 - Angela Inês.
-- Redmine #2192 - Correção do Processo para Automatizar o calculo com registro F600.
-- Rotina: pkb_calcular_cons_cofins_m600.
--
-- Em 06/03/2014 - Angela Inês.
-- Redmine #2192 - Correção do Processo para Automatizar o calculo com registro F600.
-- Rotinas: pkb_calcular_cons_cofins_m600 e pkb_validar_cons_cofins_m600.
--
-- Em 21/02/2014 - Angela Inês.
-- Redmine #1810 - Correção no parâmetro que "Gera Escrituração" - Para os processos PIS/COFINS.
-- Se o parâmetro estiver marcado como "NÃO", o documento não deve ser gerado no arquivo texto, e também não deve gerar apuração nos blocos M400 e M800.
-- Rotina: pkb_monta_dados_m800.
--
-- Em 10/02/2014 - Angela Inês.
-- Redmine #1887 - Geração Apuração PIS/COFINS - valores gerados incorretos com código 04 de base de crédito.
-- Corrigido processo para recuperar com distinct o código CFOP nas rotinas de serviço contínuo.
-- Rotina: pk_apur_cofins.pkb_monta_dados_m500.
--
-- Em 26/12/2013 - Angela Inês.
-- Redmine #1324 - Informação - Nova regra de validação CST 05 EFD Contribuições Versão 2.0.5.
-- 1) Parametrizar na tabela NAT_REC_PC se o código de situação tributária vinculado (nat_rec_pc.codst_id), irá gerar receita (blocos M400 e M800):
-- DM_GERA_RECEITA = 0-NÃO, 1-SIM. Deixamos como Valor Inicial = 1-Sim.
-- Considerar se a natureza (nat_rec_pc) recuperada, está com a nova coluna DM_GERA_RECEITA = 1-SIM.
-- Rotinas: pkb_monta_dados_m800.
--
-- Em 26/12/2013 - Angela Inês.
-- Redmine #1644 - Considerar os Conhecimentos de Transporte com dm_arm_cte_terc igual a 0.
--
-- Em 16/12/2013 - Angela Inês.
-- Redmine #1580 - Utilização do F600 nos registro M200 e M600 - Ficha HD 67009.
-- Alteração: Deve ser somado, também, os valores do Bloco F600 devido a regra.
-- Rotina: pkb_calcular_cons_cofins_m600 e pkb_validar_cons_cofins_m600.
--
-- Em 04/11/2013 - Angela Inês.
-- Redmine #1156 - Implementar o parâmetro que indica geração automática de ajuste no bloco M610 nos processos do PIS/COFINS.
-- Se o CFOP não permite credito, o valor de credito tem que ser gerado no ajuste automático no M610.
-- Rotinas: pkb_calcular_cons_cofins_m600/pkb_validar_cons_cofins_m600 - Incluir situação na recuperação dos valores que estejam processadas e/ou validadas.
-- Rotinas: pkb_dados_abert_empr - Incluir a recuperação do identificador da geração (abertura_efd_pc.id).
-- Rotinas: pkb_gerar_per_apur_cofins_m500/pkb_gerar_per_cons_cofins_m600/pkb_calcular_cons_cofins_m600/pkb_gerar_per_rec_cofins_m800 - Verificar se existe geração da abertura do efd no mesmo período e calculado.
-- Rotinas: pkb_monta_dados_m600/pkb_monta_vetor_m600/pkb_grava_dados_m600 - Incluir inclusão do ajuste (ajust_contr_pis_apur).
-- Rotina: pkb_excl_per_cons_cofins_m600 - Excluir a tabela cons_contr_cofins_or - Obrigações a Recolher da Apuração de COFINS, ao excluir a consolidação.
--
-- Em 16/10/2013 - Angela Inês.
-- Redmine #1141 - Geração do PIS/COFINS - Bloco M100/M500.
-- Está sendo gerado tipo de crédito 199 e 299 e não deveria, pois os valores estão vindo zerados.
-- Correção no nome da coluna ID do cursor dos créditos presumidos.
-- Rotina: pkb_monta_dados_m500.
--
-- Em 09/10/2013 - Angela Inês.
-- Considerar valor = 1 para valor de receita bruta total no cálculo da receita bruta cumulativa.
-- Rotina: pkb_dados_abert_empr.
--
-- Em 02/10/2013 - Angela Inês.
-- Redmine #1038 - Geração do Bloco M200 e M600 - Consolidação de Pis e Cofins.
-- Não separar geração da consolidação quando o código da contribuição for 51-Contribuição cumulativa apurada a alíquota básica.
-- Rotina: pkb_monta_dados_m600.
--
-- Em 27/09/2013 - Angela Inês.
-- Redmine #599 - Islaine - EFD Contribuições Aceco Matriz - Ficha HD: 66843
-- Geração do Bloco M500: nos registros F100, o item/produto é necessário devido ao NCM para identificar a embalagem, caso não tenha item/produto
-- não será considerado embalagem, portanto não exigir o ITEM.
-- Geração do Bloco M500: nos cursores, recuperar o valor de receita bruta cumulativa e não cumulativa de acordo com o percentual do registro 0111.
-- Rotina: pkb_monta_dados_m500.
--
-- Em 04/09/2013 - Angela Inês.
-- Redmine #648 - Suporte - Tadeu/Verdemar - Geração do PIS/COFINS - Abertura do arquivo.
-- Ao desprocessar a abertura do status de calculado para não gerado, excluir os dados gerados automaticamente - blocos M100/M200/M400 e M500/M600/M800.
-- Para essa atividade foi necessário alterar os parâmetros de mensagens.
-- Rotinas: pkb_excl_per_apur_cofins_m500, pkb_excl_per_cons_cofins_m600 e pkb_excl_per_rec_cofins_m800.
-- Considerar o parâmetro da empresa que indica se irá utilizar recuperação do tipo de crédito com o processo Embalagem ou não.
-- Rotina: pkb_monta_dados_m500.
--
-- Em 19/08/2013 - Angela Inês.
-- Redmine #569 - Geração de Receitas Isentas Bloco M800.
-- Realizar a alteração da recuperação da "Natureza de Receita de Pis/Cofins" - Ordem de recuperação:
-- 1) Imposto do Documento Fiscal, 2) Cadastro do Item (tabela item_compl), 3) Cadastro com o NCM (NAT_REC_PC)
-- Rotina: pkb_monta_dados_m800.
--
-- Em 01/08/2013 - Angela Inês.
-- Redmine #406 - Alterar os processos de cálculo do Pis/Cofins, bloco M.
-- Referente a atividade #403: Implementar o campo de "Flex Field" e campo definitivo para a "Cód. Nat. Rec" (Pis/Cofins).
-- Alterar os processos de cálculo do Pis/Cofins, bloco M, para verificar primeiro o "código de natureza de receita" no documento de origem.
-- Rotina: pkb_monta_dados_m800.
--
-- Ficha HD 66689 RC #206 - Configuração do Portal para Geração do Bloco M.
-- Ao gerar os blocos M600 - Consolidação, o mesmo não está atualizando os valores da apuração que se referem aos blocos M500, valores de crédito descontado.
-- Ao validar os valores de crédito descontado da apuração, utilizar o total da consolidação por período e não por consolidação.
-- Rotinas: pkb_calcular_cons_cofins_m600 e pkb_validar_cons_cofins_m600.
--
-- Em 17/05/2013 - Angela Inês.
-- Ficha HD 66689 - Configuração do Portal para Geração do Bloco M.
-- Considerar o tipo de indicidência tributária = 3 para ratear os valores acumulados por tipo de crédito quando a CST for 53 ou 63.
-- Rotina: pkb_monta_dados_m500.
--
-- Em 02/05/2013 - Angela Inês.
-- Ficha HD 66673 - Considerar os valores de apuração se a situação for 3-processada, para o cálculo e validação do bloco M600.
-- Rotinas: pkb_calcular_cons_cofins_m600 e pkb_validar_cons_cofins_m600.
--
-- Em 29/04/2013 - Angela Inês.
-- Ficha HD 66642 - Bloco M800 - Ao recuperar os dados do F100 e o DM_ST_PROC <> VALIDADO, informar com mensagem no LOG/Informação geral do sistema.
--                  Bloco M800 - Ao recuperar os dados do F100 e o ITEM_ID = 0, informar com mensagem no LOG/Informação geral do sistema.
-- Rotinas: pkb_monta_dados_m800.
--
-- Em 25/03/2013 - Angela Inês.
-- Ficha HD 66442 - Implementar validações para os erros encontrados no PVA da EFD Pis/Cofins.
-- 1) Campo obrigatório para Natureza do Crédito igual a Outras Operações com Direito a Crédito.
-- Rotinas: pkb_validar_apur_cofins_m500.
--
-- Em 24/01/2013 - Angela Inês.
-- Ficha HD 65704 - Estrela - Bloco M500 e M600 - Cofins.
-- Correção na atualuzação dos valores de crédito disponível e saldo do bloco M500 através do bloco M600.
-- Rotina: pkb_calcular_cons_pis_m600.
--
-- Em 11/01/2013 - Angela Inês.
-- Não incluir o valor de outras despesas nos itens das notas fiscais (item_nota_fiscal.vl_outro).
--
-- Em 08/11/2012 - Angela Inês.
-- Ficha HD 64080 - Escrituração Doctos Fiscais e Bloco M. Nova tabela para considerações de CFOP - param_cfop_empresa.
-- 1) Eliminada a verificação das cfops que geram receita isentas no bloco de consolidação M600.  Rotina: pkb_monta_dados_m600.
-- 2) Eliminada a verificação das cfops que geram receita isentas no bloco de receitas isentas M800. Rotina: pkb_monta_dados_m800.
--
-- Em 17/10/2012 - Angela Inês.
-- Ficha HD 63978 - Considerar a coluna natrecpc_id para gerar os detalhes das receitas isentas - bloco M400.
-- Rotinas: pkb_grava_dados_m800 e pkb_monta_vetor_m800.
--
-- Em 11/10/2012 - Angela Inês.
-- Ficha HD 63865 - Considerar 0-Operação Mercado Interno, quando não houver indicador de origem de crédito.
-- Rotina: pkb_monta_dados_m600.
--
-- Em 10/10/2012 - Angela Inês.
-- 1) Ficha HD 63843 - Incluir nas inconsistências de equipamento sem identificador de natureza de receita o código do item e a data da redução Z.
--    Rotina: pkb_monta_dados_m800.
--
-- Em 03/10/2012 - Angela Inês.
-- 1) Ficha HD 63697 - Considerar o valor de frete/seguro/outros no valor do item bruto para compôr os valores de receita e consolidação.
--    Rotinas: pkb_monta_dados_m600 e pkb_monta_dados_m800.
--
-- Em 24/09/2012 - Angela Inês.
-- 1) Inclusão de novos parâmetros para recuperar o código da natureza de receita ( en_ncm_id e ev_cod_ncm ). Deve existir o código NCM.
--    Rotina: pkb_monta_dados_m800.
--
-- Em 10/09/2012 - Angela Inês.
-- 1) Atualizar a recuperação do identificador da natureza de receita de pis/cofins para o bloco M810, enviando as alíquotas.
--    Rotina: pkb_monta_dados_m800.
-- 2) Alterar a verificação do identificador da natureza de receita de pis/cofins, utilizando a rotina pk_csf_efd_pc.fkg_conf_id_nat_rec_pc.
--    Rotina: pkb_validar_rec_cofins_m800.
--
-- Em 05/09/2012 - Angela Inês.
-- 1) Atualização dos registros do bloco M500 através do cálculo do bloco M600, com relação aos campos DM_IND_DESC_CRED, VL_CRED_DESC e VL_TOT_CRED_DESC.
--    Rotina: pkb_calcular_cons_cofins_m600.
--
-- Em 02/08/2012 - Angela Inês.
-- 1) Não considerar o valor de imposto IPI caso a nota não tenha.
--   Rotina: pkb_monta_dados_m800.
--
-- Em 17/07/2012 - Angela Inês.
-- Ficha HD 61413:
-- 1) Ao calcular o registro M600 - verificar se a CFOP do registro faz parte dos valores da receita para os dados de resumo diário de venda.
--    Nova função pk_csf_efd_pc.fkg_existe_cfop_rec_empr - Rotina PKB_MONTA_DADOS_M600.
-- 2) Ao calcular o registro M800 - verificar se a CFOP do registro faz parte dos valores da receita para os dados de saída.
--    Nova função pk_csf_efd_pc.fkg_existe_cfop_rec_empr - Rotina PKB_MONTA_DADOS_M800.
--
-- Em 26/06/2012 - Angela Inês.
-- 1) Ao calcular o registro M600 - verificar se a CFOP do registro faz parte dos valores da receita.
--    Nova função pk_csf_efd_pc.fkg_existe_cfop_rec_empr - Rotina PKB_MONTA_DADOS_M600.
--
-- Em 22/06/2012 - Angela Inês.
-- 1) Eliminar variáveis declaradas e não utilizadas no processo.
--
-- Em 13/06/2012 - Angela Inês.
-- 1) Alteração na montagem do bloco M500, considerar todos os códigos de CST, não fazendo restrição dos códigos ('50', '51', '52', '53', '54', '55', '56').
--
-- Em 15/05/2012 - Angela Inês.
-- Ficha HD 58940 - Solicitante: Islaine
-- Solicitação:
-- Para as notas fiscais de serviços continuos criar a validação abaixo para o campo BASECALCCREDPC_ID da tabela nf_compl_oper_cofins:
-- 1) Para modelos documentos entre 06, 28 e 29 só pode aceitar os códigos de base de calculo entre: 01, 02, 04, 13 . Regra no manual do Contribuinte.
-- 2) Para modelos documentos entre 21 e 22 só pode aceitar os códigos de base de calculo entre: 03, 13. Regra no manual do Contribuinte.
--
-- Em 18/04/2012 - Angela Inês.
-- Nos processos de bloco M500 não estava sendo considerado a CST 64 e 55 corretamente.
--
-- Em 12/04/2012 - Angela Inês.
-- Incluir o valor do imposto tributado IPI no valor a ser gerado para o Bloco M800.
-- Referente aos valores de C100 - NOTA FISCAL (CÓDIGO 01), NOTA FISCAL AVULSA (CÓDIGO 1B), NOTA FISCAL DE PRODUTOR (CÓDIGO 04) E NFE (CÓDIGO 55).
--
-- Em 05/03/2012 - Angela Inês.
-- Ao gerar o bloco M500 considerar mais de um registro para as CSTs de mais de um tipo de regime (53, 54, 55, 56, 63, 64, 65, 66).
-- Ao gerar o bloco M600 considerar o campo da chave de contribuição social como 01 para códigos 01, 02, 03, 04, 32 e 71.
-- Ao gerar o bloco M610 considerar o campo da chave de contribuição social como 01 para códigos 01, 02, 03, 04, 32 e 71, mais o identificador da mesma.
--
-- Em 02/03/2011 - Angela Inês.
-- Acertar os parâmetros que se referem a recuperação das notas fiscais, conhecimentos de transporte, demais doctos, bens do ativo e crédtio de estoque.
--
-- Em 28/02/2012 - Angela Inês.
-- Atualizar a recuperação dos dados na montagem do bloco M100 - mês e ano de referência.
--
-- Em 24/02/2012 - Angela Inês.
-- Gerar consolidação (bloco m600) mesmo não tendo detalhe, devido ao cálculo de apuração. O registro M600 é obrigatório.
-- Não exigir detalhe de consolidação (bloco m610) no cálculo ou validação do bloco M600.
--
-- Em 03/02/2012 - Angela Inês.
-- Não considerar o status 1-Calculada ou 2-Erro no cálculo no processo do bloco M700.
--
-- Em 02/02/2012 - Angela Inês.
-- No processo de exclusão por período, excluir o registro do período.
--
-- Em 31/01/2012 - Angela Inês.
-- Considerar a coluna chave do bloco M600 para montar o primeiro nível do processo.
--
-- Em 27/01/2012 - Angela Inês.
-- Passar a considerar ST específica para recuperar os dados do bloco M500 (comentário detalhado na rotina PKB_MONTA_DADOS_M500).
--
-- Em 23/01/2012 - Angela Inês.
-- Incluído processo por período de consolidação da contribuição - PER_CONS_CONTR_COFINS.
-- Eliminado as colunas EMPRESA_ID, DT_INI e DT_FIN da tabela de consolidação CONS_CONTR_COFINS.
--
-- Em 18/01/2012 - Angela Inês.
-- Eliminado a coluna DM_SITUACAO da tabela de período PER_APUR_CRED_COFINS
-- Eliminado as colunas EMPRESA_ID, DT_INI e DT_FIN da tabela de apuração APUR_CRED_COFINS.
-- Incluído processo por período de receita isenta da tabela de PER_REC_ISENTA_COFINS.
-- Eliminado as colunas EMPRESA_ID, DT_INI e DT_FIN da tabela de receitas isentas REC_ISENTA_COFINS.
--
-- Em 19/12/2011 - Angela Inês.
-- Alteração nas casas decimais dos campos que se referem a alíquota em percentual e em quantidade.
--
-- Em 09/12/2011 - Angela Inês.
-- Inclusão dos dados das Notas fiscais para as mensagens de erro.
--
-------------------------------------------------------------------------------------------------------------------------------
--
--| Apuração de crédito
   gt_row_per_apur_cred_cofins  per_apur_cred_cofins%rowtype;
   gt_row_apur_cred_cofins      apur_cred_cofins%rowtype;
   gn_aberturaefdpc_id          abertura_efd_pc.id%type;
   gn_dm_cod_inc_trib           abertura_efd_pc_regime.dm_cod_inc_trib%type;
   gn_dm_ind_apro_cred          abertura_efd_pc_regime.dm_ind_apro_cred%type;
   gn_dm_ind_reg_cum            abertura_efd_pc_regime.dm_ind_reg_cum%type;
   gn_recbru_nc_trntr_tri       number;
   gn_recbru_nc_trntr_ntr       number;
   gn_recbru_nc_trexp_tri       number;
   gn_recbru_nc_trexp_exp       number;
   gn_recbru_nc_ntrexp_ntr      number;
   gn_recbru_nc_ntrexp_exp      number;
   gn_recbru_nc_trntrexp_tri    number;
   gn_recbru_nc_trntrexp_ntr    number;
   gn_recbru_nc_trntrexp_exp    number;
   gn_recbru_cum                number := 0;
   gn_vl_aj_redu                ajust_apur_cred_cofins.vl_aj%type;
   gn_vl_aj_acre                ajust_apur_cred_cofins.vl_aj%type;
   gn_tipoimp_id                tipo_imposto.id%type;

--| Consolidação da contribuição para o cofins do período
   gt_row_per_cons_contr_cofins per_cons_contr_cofins%rowtype;
   gt_row_cons_contr_cofins     cons_contr_cofins%rowtype;
   gv_dm_ind_nat_pj             abertura_efd_pc.dm_ind_nat_pj%type;
   gn_dm_ind_ativ               abertura_efd_pc.dm_ind_ativ%type;

--| Contribuição para o cofins diferido em períodos anteriores
   gt_row_contr_cofins_difperant contr_cofins_dif_per_ant%rowtype;

--| Receitas isentas
   gt_row_per_rec_isenta_cofins  per_rec_isenta_cofins%rowtype;
   gt_row_rec_isenta_cofins      rec_isenta_cofins%rowtype;

-------------------------------------------------------------------------------------------------------

-- Declaração de constantes
   erro_de_validacao     constant number := 1;
   erro_de_sistema       constant number := 2; -- 2-Erro geral do sistema
   erro_inform_geral     constant number := 35; -- 35-Informação Geral

-------------------------------------------------------------------------------------------------------

   gv_mensagem_log       log_generico.mensagem%type := null;
   gv_obj_referencia     log_generico.obj_referencia%type := null;
   gn_referencia_id      log_generico.referencia_id%type := null;
   gv_resumo_log         log_generico.resumo%type := null;

-------------------------------------------------------------------------------------------------------
-- Global Arrays
   ga_mem_calc_apur_cofins  tb_mem_calc_apur_cofins   := tb_mem_calc_apur_cofins();

-- Variáveis para os vetores
   type tab_reg_m500 is record ( ch_cc_tpcr_or_tp_aliq number -- item 1 da chave -- foram concatenados os campos, pois as alíquotas podem estar zeradas
                                                                                 -- tipocredpc_id||dm_ind_cred_ori||tipo||aliq_cofins||vl_aliq_cofins_quant
                               , tipocredpc_id         number
                               , dm_ind_cred_ori       number(1)
                               , tipo                  number(1) -- 1-alíq.percentual, 2-alíq.quantidade
                               , aliq_cofins           number(8,4)
                               , vl_aliq_cofins_quant  number(9,4)
                               , apurcredcofins_id     number
                               , dm_situacao           number(1)
                               , vl_bc_cofins          number(15,2)
                               , quant_bc_cofins       number(15,3)
                               , vl_cred               number(15,2)
                               , vl_ajus_acres         number(15,2)
                               , vl_ajus_reduc         number(15,2)
                               , vl_cred_dif           number(15,2)
                               , vl_cred_disp          number(15,2)
                               , dm_ind_desc_cred      number(1)
                               , vl_cred_desc          number(15,2)
                               , vl_sld_cred           number(15,2) );
   --
   type t_tab_reg_m500 is table of tab_reg_m500 index by varchar2(20); -- binary_integer;
   vt_tab_reg_m500        t_tab_reg_m500;
   --
   type tab_reg_m505 is record ( apurcredcofins_id    number -- item 1 da chave -- a chave está concatenada dentro do processo
                               , basecalccredpc_id    number -- item 2 da chave -- a chave está concatenada dentro do processo
                               , codst_id             number -- item 3 da chave -- a chave está concatenada dentro do processo
                               , detapurcredcofins_id number
                               , vl_bc_cofins_tot     number(15,2)
                               , vl_bc_cofins_cum     number(15,2)
                               , vl_bc_cofins_nc      number(15,2)
                               , vl_bc_cofins         number(15,2)
                               , quant_bc_cofins_tot  number(15,3)
                               , quant_bc_cofins      number(15,3)
                               , desc_cred            varchar2(255) );
   --
   type t_tab_reg_m505 is table of tab_reg_m505 index by varchar2(20); -- binary_integer;
   vt_tab_reg_m505        t_tab_reg_m505;
   --
   type tab_reg_m600 is record ( ch_conc_cs_cr_aliq    number -- foram concatenados os campos, pois as alíquotas podem estar zeradas
                                                              -- contrsocapurpc_id||aliq_cofins||aliq_cofins_quant
                               , conscontrcofins_id   number
                               , dm_situacao          number(1)
                               , vl_tot_cont_nc_per   number(15,2)
                               , vl_tot_cred_desc     number(15,2)
                               , vl_tot_cred_desc_ant number(15,2)
                               , vl_tot_cont_nc_dev   number(15,2)
                               , vl_ret_nc            number(15,2)
                               , vl_out_ded_nc        number(15,2)
                               , vl_cont_nc_rec       number(15,2)
                               , vl_tot_cont_cum_per  number(15,2)
                               , vl_ret_cum           number(15,2)
                               , vl_out_ded_cum       number(15,2)
                               , vl_cont_cum_rec      number(15,2)
                               , vl_tot_cont_rec      number(15,2) );
   --
   type t_tab_reg_m600 is table of tab_reg_m600 index by binary_integer;
   vt_tab_reg_m600        t_tab_reg_m600;
   --
   type tab_reg_m610 is record ( conscontrcofins_id      number
                               , contrsocapurpc_id       number      -- item 1 da chave
                               , aliq_cofins             number(8,4) -- item 2 da chave
                               , aliq_cofins_quant       number(9,4) -- item 3 da chave
                               , detconscontrcofins_id   number
                               , vl_rec_brt              number(15,2)
                               , vl_bc_cont              number(15,2)
                               , quant_bc_cofins         number(15,3)
                               , vl_cont_apur            number(15,2)
                               , vl_ajust_acrec          number(15,2)
                               , vl_ajust_reduc          number(15,2)
                               , vl_cont_difer           number(15,2)
                               , vl_cont_difer_ant       number(15,2)
                               , vl_cont_per             number(15,2) 
                               , vl_ajus_acres_bc_cofins number(15,2)
                               , vl_ajus_reduc_bc_cofins number(15,2)
                               , vl_bc_cont_ajus         number(15,2)
                               );
   --
   type t_tab_reg_m610 is table of tab_reg_m610 index by binary_integer;
   type t_bi_tab_reg_m610 is table of t_tab_reg_m610 index by binary_integer;
   vt_bi_tab_reg_m610        t_bi_tab_reg_m610;
   --
   type tab_reg_m620 is record ( ajustcontrcofinsapur_id number
                               , dm_ind_aj               number
                               , vl_ajuste               number(15,2)
                               , cd_cfop                 varchar2(1000) );
   --
   type t_tab_reg_m620     is table of tab_reg_m620 index by binary_integer;
   type t_bi_tab_reg_m620  is table of t_tab_reg_m620 index by binary_integer;
   type t_tri_tab_reg_m620 is table of t_bi_tab_reg_m620 index by binary_integer;
   vt_tri_tab_reg_m620        t_tri_tab_reg_m620;
   --
   type tab_reg_m800 is record ( ch_rec_cstplacta   varchar2(100) -- foram concatenados os campos, pois o plano de contas pode estar zerado
                                                                  -- codst_id||plano_conta.cod_cta - alteramos para varchar2 devido ao tamanho
                               , codst_id           number -- item 1 da chave
                               , planoconta_id      number -- item 2 da chave sendo o código da conta e não o ID
                               , recisentacofins_id number
                               , dm_situacao        number(1)
                               , vl_tot_rec         number(15,2)
                               , desc_compl         varchar2(255) );
   --
   type t_tab_reg_m800 is table of tab_reg_m800 index by varchar2(100);
   vt_tab_reg_m800        t_tab_reg_m800;
   --
   type tab_reg_m810 is record ( recisentacofins_id    number -- item 1 da chave
                               , planoconta_id         number -- item 2 da chave
                               , natrecpc_id           number -- item 3 da chave
                               , detrecisentacofins_id number
                               , vl_rec                number(15,2)
                               , desc_compl            varchar2(255)  );
   --
   type t_tab_reg_m810     is table of tab_reg_m810   index by varchar2(100);
   type t_bi_tab_reg_m810  is table of t_tab_reg_m810 index by varchar2(100);
   type t_tri_tab_reg_m810 is table of t_bi_tab_reg_m810 index by varchar2(100);
   vt_tri_tab_reg_m810        t_tri_tab_reg_m810;
   --

-------------------------------------------------------------------------------------------------------

--| CRÉDITO DE COFINS RELATIVO AO PERÍODO - BLOCO M500
--| Procedimento para gerar por período a apuração do crédito do COFINS - Bloco M500
--| Serão gerados os blocos M500 e M505
PROCEDURE PKB_GERAR_PER_APUR_COFINS_M500( EN_PERAPURCREDCOFINS_ID IN PER_APUR_CRED_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para excluir por período a apuração do crédito do COFINS - Bloco M500
PROCEDURE PKB_EXCL_PER_APUR_COFINS_M500( EN_PERAPURCREDCOFINS_ID IN PER_APUR_CRED_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para calcular por período a apuração do crédito do COFINS - Bloco M500
--| Serão calculados alguns campos dos blocos M500, M505 e M550
PROCEDURE PKB_CALC_PER_APUR_COFINS_M500( EN_PERAPURCREDCOFINS_ID IN PER_APUR_CRED_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para validar por período a apuração do crédito do COFINS - Bloco M500
--| Serão validados alguns campos dos blocos M500, M505 e M550
PROCEDURE PKB_VAL_PER_APUR_COFINS_M500( EN_PERAPURCREDCOFINS_ID IN PER_APUR_CRED_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para desprocessar por período a apuração do crédito do COFINS - Bloco M500
PROCEDURE PKB_DESPR_PER_APUR_COFINS_M500( EN_PERAPURCREDCOFINS_ID IN PER_APUR_CRED_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para calcular a apuração do crédito do COFINS - Bloco M500
--| Serão calculados alguns campos dos blocos M500, M505 e M510
PROCEDURE PKB_CALCULAR_APUR_COFINS_M500( EN_APURCREDCOFINS_ID IN APUR_CRED_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para validar a apuração do crédito do COFINS - Bloco M500
--| Serão validados alguns campos dos blocos M500, M505 e M510
PROCEDURE PKB_VALIDAR_APUR_COFINS_M500( EN_APURCREDCOFINS_ID IN APUR_CRED_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para desprocessar a apuração do crédito do COFINS - Bloco M500
PROCEDURE PKB_DESPR_APUR_COFINS_M500( EN_APURCREDCOFINS_ID IN APUR_CRED_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

--| CONSOLIDAÇÃO DA CONTRIBUIÇÃO PARA O COFINS DO PERÍODO - BLOCO M600
--| Procedimento para gerar por período a consolidação do COFINS - Bloco M600
--| Serão gerados os blocos M600 e M610
PROCEDURE PKB_GERAR_PER_CONS_COFINS_M600( EN_PERCONSCONTRCOFINS_ID IN PER_CONS_CONTR_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para excluir por período a consolidação do COFINS - Bloco M600
PROCEDURE PKB_EXCL_PER_CONS_COFINS_M600( EN_PERCONSCONTRCOFINS_ID IN PER_CONS_CONTR_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para calcular por período a consolidação do COFINS - Bloco M600
--| Serão calculados alguns campos dos blocos M600, M610 e M620
PROCEDURE PKB_CALC_PER_CONS_COFINS_M600( EN_PERCONSCONTRCOFINS_ID IN PER_CONS_CONTR_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para validar por período a consolidação do COFINS - Bloco M600
--| Serão validados alguns campos dos blocos M600, M610 e M620
PROCEDURE PKB_VAL_PER_CONS_COFINS_M600( EN_PERCONSCONTRCOFINS_ID IN PER_CONS_CONTR_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para desprocessar por período a consolidação do COFINS - Bloco M600
PROCEDURE PKB_DESPR_PER_CONS_COFINS_M600( EN_PERCONSCONTRCOFINS_ID IN PER_CONS_CONTR_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para calcular a consolidação do COFINS - Bloco M600
--| Serão calculados alguns campos dos blocos M600, M610 e M620
PROCEDURE PKB_CALCULAR_CONS_COFINS_M600( EN_CONSCONTRCOFINS_ID IN CONS_CONTR_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para validar a consolidação do COFINS - Bloco M600
--| Serão validados alguns campos dos blocos M600, M610, M611, M620 e M630
PROCEDURE PKB_VALIDAR_CONS_COFINS_M600( EN_CONSCONTRCOFINS_ID IN CONS_CONTR_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para desprocessar a consolidação do COFINS - Bloco M600
PROCEDURE PKB_DESPROC_CONS_COFINS_M600( EN_CONSCONTRCOFINS_ID IN CONS_CONTR_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

--| Procedimento para validar a contribuição do COFINS diferida em períodos anteriores
--| valores a pagar no período - Bloco M700
PROCEDURE PKB_VALIDAR_CONTR_COFINS_M700( EN_CONTRCOFINSDIFPERANT_ID IN CONTR_COFINS_DIF_PER_ANT.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para desprocessar a contribuição do COFINS diferida em períodos anteriores
--| valores a pagar no período - Bloco M700
PROCEDURE PKB_DESPROC_CONTR_COFINS_M700( EN_CONTRCOFINSDIFPERANT_ID IN CONTR_COFINS_DIF_PER_ANT.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para excluir a contribuição do COFINS diferida em períodos anteriores
--| valores a pagar no período - Bloco M700
PROCEDURE PKB_EXCLUIR_CONTR_COFINS_M700( EN_CONTRCOFINSDIFPERANT_ID IN CONTR_COFINS_DIF_PER_ANT.ID%TYPE );

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

--| Procedimento para gerar por período as receitas isentas não alcançadas pela incidência da
--| contribuição, sujeitas a alíquota zero ou de vendas com suspensão - COFINS - Bloco M800
--| Serão gerados os blocos M800 e M810
PROCEDURE PKB_GERAR_PER_REC_COFINS_M800( EN_PERRECISENTACOFINS_ID IN PER_REC_ISENTA_COFINS.ID%TYPE );
-------------------------------------------------------------------------------------------------------

--| Procedimento para excluir por período as receitas isentas não alcançadas pela incidência da
--| contribuição, sujeitas a alíquota zero ou de vendas com suspensão - COFINS - Bloco M800
PROCEDURE PKB_EXCL_PER_REC_COFINS_M800( EN_PERRECISENTACOFINS_ID IN PER_REC_ISENTA_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para calcular por período as receitas isentas não alcançadas pela incidência da
--| contribuição, sujeitas a alíquota zero ou de vendas com suspensão - COFINS - Bloco M800
--| Serão calculados alguns campos dos blocos M800 e M810
PROCEDURE PKB_CALC_PER_REC_COFINS_M800( EN_PERRECISENTACOFINS_ID IN PER_REC_ISENTA_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para validar por período as receitas isentas não alcançadas pela incidência da
--| contribuição, sujeitas a alíquota zero ou de vendas com suspensão - COFINS - Bloco M800
--| Serão validados alguns campos dos blocos M800 e M810
PROCEDURE PKB_VAL_PER_REC_COFINS_M800( EN_PERRECISENTACOFINS_ID IN PER_REC_ISENTA_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para desprocessar por período as receitas isentas não alcançadas pela incidência da
--| contribuição, sujeitas a alíquota zero ou de vendas com suspensão - COFINS - Bloco M800
PROCEDURE PKB_DESPR_PER_REC_COFINS_M800( EN_PERRECISENTACOFINS_ID IN PER_REC_ISENTA_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para calcular as receitas isentas - Bloco M800
--| Serão calculados alguns campos dos blocos M800 e M810
PROCEDURE PKB_CALCULAR_REC_COFINS_M800( EN_RECISENTACOFINS_ID IN REC_ISENTA_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para validar as receitas isentas - Bloco M800
--| Serão validados alguns campos dos blocos M800 e M810
PROCEDURE PKB_VALIDAR_REC_COFINS_M800( EN_RECISENTACOFINS_ID IN REC_ISENTA_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para desprocessar as receitas isentas - Bloco M800
PROCEDURE PKB_DESPROC_REC_COFINS_M800( EN_RECISENTACOFINS_ID IN REC_ISENTA_COFINS.ID%TYPE );

-------------------------------------------------------------------------------------------------------

--| Procedimento para descarregar o vetor de memória de calculo na tabela física
PROCEDURE PKB_GRAVA_VET_MEM_CALC_COFINS;

-------------------------------------------------------------------------------------------------------
END PK_APUR_COFINS;
/
