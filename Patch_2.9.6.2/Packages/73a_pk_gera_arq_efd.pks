create or replace package csf_own.pk_gera_arq_efd is

-------------------------------------------------------------------------------------------------------
-- Especificação do pacote de procedimentos de criação do arquivo do sped fiscal
--
-- Em 22/02/2021   - Luis Marques - 2.9.5.5 / 2.9.6-2 / 2.9.7
-- Redmine #76361  - Registro C113 - Participante saindo incorreto / Registro 0150 - nome do participante incorreto
-- Rotina Alterada - pkb_monta_reg_C100 - Fixado para registro C113 para trazer os dados do cadastro de pessoa ignorando parametro
--                   ORIGEM_DADO_PESSOA, conforme manual SPED por se tratar de nota referenciada.
--
-- Em 19/02/2021   - Luis Marques - 2.9.5.5 / 2.9.6-2 / 2.9.7
-- Redmine #76194  - Embasamento legal GIA - Valores negativos para o município
-- Rotina Alterada - pkb_monta_reg_1400 - Colocado verificação para se valores de rateio por municipio forem negativos no caso de 
--                   nota fiscal colocada R$ 0,01 e no caso de conhecimento de transporte coloca R$ 1,00 igual a GIA-SP 30.
--
-- Em 18/02/2020   - Allan Magrini - 2.9.6-2 / 2.9.7
-- Redmine #76296 - Erro "valor maior que a precisão especificada" na geração do SPED
-- Rotina Alterada - pkb_monta_reg_1400 alterados no cursor c_1400 os to_date para trunc
--                   pkb_insert_tabela_tmp inseridos os campos no insert da tmp_nota_fiscal e retirado o camando /*+ APPEND */
--
-- Em 12/02/2021   - Luis Marques - 2.9.6-2 / 2.9.7
-- Redmine #76110  - Verificar restante dos CNPJ's
-- Rotina Alterada - pkb_monta_reg_1400 - Ajuste nas leituras de Notas retirando valor fixo de empresa para que todas as
--                 - empresas sejam geradas para o registro 1400.  
--
-- Em 10/02/2021   - Luis Marques - 2.9.6-2 / 2.9.7
-- Redmine #76013  - Verificar valores entre GIA X SPED
-- Rotina Alterada - pkb_monta_reg_1400 - Ajuste nas leituras de Notas e conhecimentos para que os valoers fiquem iguais abaixo
--                 - DIPAM CR-30 SP.  
--
-- Em 21/01/2021   - Luis Marques - 2.9.6-2 / 2.9.7
-- Redmine #75408  - Ajustes na geração do registro 1400.
-- Rotina Alterada - pkb_monta_reg_1400 - Ajuste na leitura de conhecimento de transporte para ficar igual a GIA 30 -SP
--                   pkb_monta_reg_1010 - Ajuste na soma qtde registros de valores agregados incluindo registros DIPAM.
--
-- Em 28/12/2020   - Allan Magrini - 2.9.4-6 / 2.9.5-3 / 2.9.6
-- Redmine #74507  - Gerar SPED Fiscal apenas com alíquota simbólica no C197
-- Rotina Alterada -  pkb_monta_reg_C100, ajuste no if da fase 50.6, foi adicionada a condição or nvl(rec_c197.aliq_icms,0) > 0
--                    pkb_monta_bloco_e, adicionada validação para iniciar o pkb_monta_reg_E500
--
-- Em 21/12/2020   - Allan Magrini - 2.9.4-6 / 2.9.5-3 / 2.9.6
-- Redmine #74384  - SPED Fiscal DF - Notas sendo duplicadas no registro B020
-- Rotina Alterada - pkb_monta_reg_B020, ajuste no cursor c_b020 e na montagem do bloco
--
-- Em 05/10/2020   - Luis Marques - 2.9.5-3 / 2.9.6
-- Redmine #70399  - [PLSQL] Obrigatoriedade do campo 02 dos registros E113 e E313 para OC
-- Rotina Alterada - pkb_monta_reg_E100 e pkb_monta_reg_E300 retirada a obrigatoriedade do pessoa_id (cod_part).
--
-- Em 27/11/20202  - Luis Marques - 2.9.4-6 / 2.9.5-3 / 2.9.6
-- Redmine #73857  -  SPED Fiscal (E113) SPED Contribuições (C100)
-- Rotina Alterada - pkb_monta_reg_E100 - na geração do registro 0150 gerar usando o parametro 
--                   "ORIGEM_DADO_PESSOA" como "CADASTRO_PESSOA" para registro E113 de Apuração de ICMS.
--
-- Em 23/11/2020   - Luis Marques - 2.9.4-6 / 2.9.5-3 / 2.9.6
-- Redmine #73654  - Revisar caso - C500
-- Rotina Alterada - pkb_monta_reg_C500, pkb_monta_reg_D100 - na geração do registro 0150 gerar usando o parametro 
--                   "ORIGEM_DADO_PESSOA" como "CADASTRO_PESSOA" para Notas Fiscais de Serviços Continuos e para 
--                   Conhecimento de Transporte.
--
-- Em 24/11/2020   -  Allan Magrini
-- Redmine #68839  -  Problemas no Bloco B (DF)
-- Alteracao: Alterada a condição "and mf.cod_mod in ('01', '03', '3B', '04', '08', '55', '65')" incluindo 
-- o modelo '99' nos cursores das pkb abaixo, incluído mais um select no cursor c_b025 da pkb_monta_reg_B020 para o dm_tipo=1 retenção
-- e o preenchimento do reg 025 só deverá ser dos campos VL_CONT_P e COD_SERV com os demais ficando zerados 
-- Rotina Alterada - pkb_monta_reg_B020, pkb_monta_reg_B420, pkb_monta_reg_B440
-- Patch_2.9.4.5 / Patch_2.9.5.2 / Release_2.9.6     
--
-- Em 24/11/2020  - Allan Magrini
-- Redmine #69130 - DIFAL - Registros C101 e E310
-- Alterações     - pkb_monta_reg_C100, ajustada validação na fase 12.2 vn_dm_ind_ie_dest <> 1; -- 1-Contribuinte ICMS 
-- Liberado       - Release_2.9.6, Patch_2.9.5.2 e Patch_2.9.4.5
--
-- Em 09/11/2020  - Wendel Albino
-- Redmine #72837 - Campo de destinatário incorreto para notas de serviço contínuo emitidas por terceiros
-- Alterações     - pkb_monta_reg_C500 -> aplicar regra do leiaute "Guia Prático EFD-ICMS/IPI – Versão 3.0.4 Atualização:22/06/2020" nas colunas 
--                -   vt_tab_reg_c500(i).ind_dest e vt_tab_reg_c500(i).cod_mun_dest .Se nf de entrada nao envia as colunas, se saida envia os dados referentes a empresa.
--
-- Em 16/10/2020  - Allan Magrini
-- Redmine #71638 - Valores de ICMS desonerado com CST 20 zerados no C170, e preenchidos no C190
-- Alterações     - pkb_monta_reg_C100 na fase 32.2 foi adicionada a validação vv_cst_icms <> '20' no if
-- Liberado       - Release_2.9.5, Patch_2.9.5.1 e Patch_2.9.4.4
--
-- Em 07/10/2020  - Allan Magrini
-- Redmine #70727 - Erros nos campos obrigatórios do D100 para CTe's complementares.
-- Alterações     - pkb_monta_reg_D100 = > Else if da fase 5, foi retirado modelo 06 da cod_sit
-- Liberado       - Release_2.9.5, Patch_2.9.4.3 e Patch_2.9.3.6
--
-- Em 02/09/2020   - Wendel Albino
-- Redmine #69103  - Alterar geração do Sped Fiscal para contribuintes de ISS no DF
-- Rotina Alterada - pkb_monta_reg_0000 -> inclusao de validacao do bloco 0000 se dm_ind_ativ = '2' grava fixo "1¿Outros"
--                 - pkb_monta_reg_c001,pkb_monta_reg_d001,pkb_monta_reg_g001,pkb_monta_reg_H001,pkb_monta_reg_k001 ->
--                 -   incluida validacao se dm_ind_ativ = '2', ind_mov := 1 (sem movimento).
--                 - pkb_monta_reg_H005-> valida se dm_ind_ativ = '2' gera somente o h005.
--                 - pkb_monta_reg_1010-> registros 1010 devem ser enviados todos como 'N'.
--                 - pkb_monta_reg_B470 -> se nao tiver valor no select e dm_ind_ativ = '2' e for DF , gera zerado
--
-- Em 26/08/2020   - Allan Magrini
-- Redmine #64852  - Registro 1923 EFD ICMS/IPI.
-- Alteracao: Alterado o cursor c_1923, adiconanto cte e novos campos da tabela INF_AJUST_SUBAPUR_ICMS_NF
-- campo NOTAFISCAL_ID mudou para REFERENCIA_ID 
-- Rotina Alterada - pkb_monta_reg_1900
--
-- Em 26/08/2020   - Allan 2.9.4-2 / 2.9.5
-- Redmine #70570 Problema recorrente do registro C100
-- Rotina Alterada - pkb_monta_reg_C100 - Na fase 8 data de entrada/saida sendo colocado nulo indevidamente para notas do tipo vv_cod_sit in ('08'), revisado 
--                   para não colocar nulo em data de entrada/saida valida
--
-- Em 18/08/2020   - Armando 2.9.4-2 / 2.9.5
-- Redmine #70570 Demora voltou a ocorrer
-- Rotina Alterada - pkb_gera_arquivo_efd - adicionando nova condição de sessão 'ALTER SESSION SET DB_FILE_MULTIBLOCK_READ_COUNT=8'.
--
-- Em 12/08/2020   - Luis Marques - 2.9.3-5 / 2.9.4-2 / 2.9.5
-- Redmine #70460  - Feedback- Teste mal-sucedido
-- Rotina Alterada - pkb_monta_reg_B470 - Ajustado para carregar o identificador do type que não estava carregando.
--
-- Em 11/08/2020   - Luis Marques - 2.9.3-5 / 2.9.4-2 / 2.9.5
-- Redmine #70309  - Bloco B470 - Registro filho obrigatório
-- Rotina Alterada - pkb_monta_reg_B001 e pkb_monta_reg_B470 - Criado opção para gerar registro B470 zerado para clientes
--                   do DF que não temnham movimento no bloco B visto que para o DF o conjunto do bloco B é obrigatorio.
--
-- Em 03/08/2020  - Wendel Albino
-- Redmine #68509 - Criar coluna ITEM_NOTA_FISCAL.CODINFITEM_ID e ajustar geração do C177
-- Alterações     - alteradao cursor c_nf incluido uf para usar no cursor c177_sefaz , que passara a ser utilizado com a nova tabela cod_inf_item.
-- Rotina         - pkb_monta_reg_C100 
--
-- Em 30/07/2020 - Armando
-- Distribuições: 2.9.4-2
-- Redmine #70048: adicionado regra de performance de sessão 
-- Rotinas Alteradas: ppkb_gera_arquivo_efd
-- Alterações: adicionado regra de performance de sessão
--
-- Em 29/07/2020   - Allan Magrini
-- Redmine #64852  - Registro 1923 EFD ICMS/IPI.
-- Alteracao: Ajustados campos que foram alterados cursor cursor c_1923, na tabela INF_AJUST_SUBAPUR_ICMS_NF
-- campo NOTAFISCAL_ID mudou para REFERENCIA_ID 
-- Rotina Alterada - pkb_monta_reg_1900
--  
-- Em 07/07/2020 - Marcos Ferreira
-- Distribuições: 2.9.4
-- Redmine #68776: Estrutura para integrar guia da PGTO_IMP_RET
-- Rotinas Alteradas: pkb_monta_reg_1900, pkb_monta_reg_E300, pkb_monta_reg_E200, pkb_monta_reg_E100
-- Alterações: Adequação a nova estrutura de tabela
--
-- Em 02/07/2020  - Karina de Paula
-- Redmine #57986 - [PLSQL] PIS e COFINS (ST e Retido) na NFe de Serviços (Brasília)
-- Alterações     - pkb_monta_reg_C100 => Inclusão dos valores vl_pis_st e vl_cofins_st no cursor c_nf e vt_tab_reg_c100
-- Liberado       - Release_2.9.5, Patch_2.9.4.1 e Patch_2.9.3.4
--
-- Em 23/06/2020   - Allan Magrini
-- Redmine #68428  - Numeração inutilizada gera mais de um registro no C100
-- Alteracao: Alteração no cursor c_nf_inut para trazer notas intulizadaa com numero de protocolo
-- Rotina Alterada - pkb_monta_reg_C100
-- Patch_2.9.3.3 / Patch_2.9.2.6 / Release_2.9.4      
--
-- Em 22/06/2020     - Wendel Albino
-- Redmine #67592    - Registro 1391 do SPED Fiscal preenchendo código do item com o ID do banco de dados
-- Rotinas Alteradas - Alterada a procedure pkb_monta_reg_1390 e pkb_armaz_reg_1390 onde esta trazendo "item_id" trazer "cod_item" , e no Select do cursor c_1390,
--                   - Alterado type da tabela vt_bi_tab_reg_1391 onde havia coluna item_id NUMBER para cod_item VARCHAR2(60).
--
-- Em 19/06/2020 - Renan Alves
-- Redmine #68506 - Comentar cursor C_C177_SEFAZ
-- Foi comentado o cursor rec_c177_sefaz que não será utilizado.
-- Rotina: pkb_monta_reg_C100
-- Patch_2.9.3.3 / Patch_2.9.2.6 / Release_2.9.4
-- 
-- Em 16/06/2020   - Luis Marques - 2.9.3-3 / 2.9.2-6 / 2.9.4
-- Redmine #68633  - Documentos de entrada sem data ent/sai preenchida no TXT
-- Rotina Alterada - pkb_monta_reg_C100 - Na fase 9 data de entrada/saida sendo colocado nulo indevidamente, revisado 
--                   para não colocar nulo em data de entrada/saida valida.
--
-- Em 11/06/2020   - Allan Magrini
-- Redmine #68485  - Notas com data de entrada/saída fora do período da geração entrando com data nula
-- Alteracao: Na fase 9 (Se o mês de entrada/saída for maior que o mês da escrituração então atribui nulo) se dm_dt_escr_dfepoe = 0 
--            a data e_s estava indo null foi colocada validação para neste caso ir a data de emissão
-- Rotina Alterada - pkb_monta_reg_C100
--
--
-- Em 09/06/2020   - Wendel Albino
-- Redmine #68167  - Tratar processo de Geração do Bloco B EFD
-- Rotina alterada - Alterado os cursores C_B440 (PKB_MONTA_REG_B440) e C_B420(PKB_MONTA_REG_B420)
--                 -  comentando o trecho que realiza um not exists no parâmetro que foi criado incorretamente.
--                 - Alterado cursor C_B020(pkb_monta_reg_b020) para só retornar valor na base de calculo do ISS_RETIDO (iin.vl_base_calc)),
--                 -  quando o valor do ISS Retido for maior que 0.
--                 - Alterado cursor C_B440, para que seja somado o campo vl_tota_nf (nft.vl_total_nf), ao invés de retornar somente o mesmo.
--
-- Em 15/05/2020   - Luis Marques
-- Redmine #67669  - Registro C190 da nota fiscal com duplicidade
-- Rotina alterada - pkb_monta_reg_C100 - Ajustado cursor do registro C190 (c_c190) para trazer apenas um registro 
--                   por aliquota, CST e CFOP. Incluido novo cursor auxiliar (c_c190_aux) para ler valores de FCP.
--
-- Em 16/04/2020   - Luis Marques - 2.9.2-4 / 2.9.3-1 / 2.9.4
-- Redmine #66358  - Revisão da exportação do CTE - SPED Fiscal
-- Rotina Alterada - pkb_monta_reg_D100 - Colocado verificação do Cod ST para trazer os valores de base e 
--                   icms tributados para composição do campo de valor de icms não tributado no registro D100.
-- 
-- Em 01/04/2020   - Allan Magrini
-- Redmine #66582  - Integração de NFe com mais de uma informação fiscal (C195 e C197) e exportação dos Sped de ICMS
-- Alteracao: Ajustado o group by do cursor c_c160
-- Rotina Alterada - pkb_monta_reg_C100
--
-- Em 13/03/2020 - Luis Marques - 2.9.3
-- Redmine #63776 - Integração de NFSe - Aumentar Campo Razao Social do Destinatário e Logradouro
-- Rotinas alteradas - pkb_monta_reg_0150 - Alterado para recuperar 100 e 60 caracteres dos campos nome e lograd 
--                     respectivamente da nota_fiscal_dest para gravação no registro. 
--
-- Em 16/03/2020   - Allan Magrini
-- Redmine #66055  - Bloco K275 não gerando o registro 0200 do Item
-- Alteracao: Foi colocada verificação se existir item gera o 0200 pkb_monta_reg_0200 e corrigido formatação do campo vl_item_ir
-- Rotina Alterada - pkb_monta_reg_k275, pkb_armaz_reg_h005
--
-- Em 09/03/2020   - Allan Magrini
-- Redmine #65683  - Data do inventário - Registro H005
-- Alteracao: colocada função para retornar o ultimo dia/mes/ano anterior a abertura na fase 7
-- Rotina Alterada - pkb_monta_reg_H005
--
-- Em 05/03/2020   - Allan Magrini
-- Redmine #65646  - Documentos de entrada com data de emissão de outro mês e data de entrada/saída no mês de geração não sendo considerados.
-- Alteracao: Corrigido os parametros de data do select que fornece os dados para a tmp_nota_fiscal
-- Rotina Alterada - pkb_insert_tabela_tmp
--  
-- Em 21/02/2020   - Allan Magrini
-- Redmine #65187  - Erro de overflow na geração do arquivo
-- Alteracao: No cursor c_nf_inut, foi adiconado o campo iu.id => nfinut_id e na fase 1.3  na entrada do valor do vv_indice :=  rec_c100_inut.nfinut_id;
-- Rotina Alterada - pkb_monta_reg_c100
-- 
-- Em 20/02/2020   - Allan Magrini / Luiz Armando Azoni
-- Redmine #64001   - Correção em campo DT_SAI_ENT no registro C100
-- Alteracao: Na fase 9 colocado colocada validação rec_c100.dm_ind_oper  = 1 para não popular campo DT_SAI_ENT
-- Alterado o registro c890 adicionando o dm_orig na query e no group by. alterando o lugar de insert nas tmp'S	
-- Rotina Alterada - pkb_monta_reg_c100, pkb_insert_tabela_tmp
--  
-- Em 20/02/2020   - Allan Magrini
-- Redmine #64004   - Ajuste em D500
-- Alteracao: Na vn_fase 5 foi colocado o rec_d500.dt_a_p na vt_tab_reg_d500(i).dt_a_p  
-- Rotina Alterada - pkb_monta_reg_D500 
--   
-- Em 19/02/2020   - Luiz Armando Azoni
-- Redmine #65079   - 1110 e 1105 - Sped ICMS/IPI
-- Alteracao: troca das query's nas tabelas de tmp para as definitivas dos cursores c_1110 e c_1105 do sped icms ipi pois os dados deste registro podem ser de outro período.
-- Rotina Alterada - pkb_mota_reg_1100
-- 
-- Em 17/02/2020 - Renan Alves / Luiz Armando Azoni
-- Redmine #64990 - Criando registro C115 sem declarar no 0400
-- Foi ajustado a geração do registro C191.
-- Rotina: pkb_monta_reg_c100 
--   
-- Em 17/02/2020   - Luiz Armando Azoni/Allan Magrini
-- Redmine #63926   - C800 C850 - Sped ICMS/IPI
-- Alterado no cursor c_c850 a soma do vl_opr
-- Rotina Alterada - pbk_monta_reg_c800 
-- 
-- Em 17/02/2020   - Luiz Armando Azoni/Allan Magrini
-- Redmine #64915   - BLOCO 0450 está gerando algumas linhas sem valor no texto
-- fase  17.3 alterada a passagem de parametro da chamada pkb_monta_reg_0450 colocando o valor en_cod_inf e 
-- na fase 12.2 da pkb_monta_reg_0450 incluida validação para o campo en_cod_inf
-- Rotina Alterada - pbk_monta_reg_c100, pkb_monta_reg_0450, pkb_monta_reg_0450
-- 
-- Em 14/02/2020 - Renan Alves
-- Redmine #64369 - retirado do registro c190 a soma com o fcp_st pois já esta certo na tabela registro analitico
-- Rotina: pkb_monta_reg_c100
--
-- Em 13/02/2020 - Renan Alves
-- Redmine #64347 - Tratar registro 1391 quando campo for nulo
-- Foi tratado o campo quantidade de resíduo produzido QTD_RESIDUO, incluíndo um NVL no mesmo, para
-- situações da qual o campo for nulo. 
-- Rotina: pkb_monta_reg_1390  
--   
-- Em 12/02/2020 - Renan Alves
-- Redmine #64844 - Ctes de emissão própria não sobem para o Sped Fiscal
-- Foi incluído mais uma condição de emissão própria (DM_IND_EMIT = 0), no select que alimenta a tabela temporária de 
-- conhecimento de transporte (TMP_CONHEC_TRANSP).
-- Rotina: pkb_insert_tabela_tmp  
--  
-- Em 11/02/2020   - Allan Magrini
-- Redmine #64638   - Erro no bloco 002 
-- Na tab_reg_0002 aterado o contrb de number para varchar2 
-- Rotina Alterada - type tab_reg_0002 da spec
--
-- Em 11/02/2020   - Allan Magrini
-- Redmine #64712  - Gerando registro 0002 para tipo de atividade "outros" indevidamente 
-- Foi colocado no if gt_row_abertura_efd.dm_ind_ativ <> 1  "outros¿ não deve ser gerado o registro 0002 do Sped 
-- Rotina Alterada - pkb_armaz_reg_0002, fkg_qtde_linha_reg_0002
--
-- Em 11/02/2020   - Luiz Armando Azoni
-- Redmine #64386  - Correção na pk_gera_arq_efd - RELATO DE BUG [200204-0920] - Casa do Lojista 
-- Feita alteração no group by do cursor cursor c_c850, adicionando ic.dm_orig||cs.cod_st  
-- Rotina Alterada - pkb_monta_reg_C800
--
-- Em 06/02/2020   - Allan Magrini
-- Redmine #64667  - Cupom Fiscal não entra no Sped Fiscal - D365
-- Corrigido o insert de redução onde foi trocada a tabela r_empresa_abertura_efd_pc para abertura_efd 
-- Rotina Alterada - pkb_insert_tabela_tmp
--
-- Em 06/02/2020   - Luiz Armando Azoni
-- Redmine #64149  - Ajuste no calculo do registro c190
-- Rotina Alterada - pkb_monta_reg_C100
--
-- Em 31/01/2020 - Allan Magrini
-- Redmine #61766  - Inclusão de coluna e domínios para Classificação de Contribuintes do IPI (registro 0002)
-- Alterado o if da fase 5 para considerar o m_tipo_mov in ('MC','IM','IA','AT') que são obrigatórios mesmo que o parametro estiver para não gerar os campos
-- Rotina: pkb_monta_reg_g110
--
-- Em 31/01/2020 - Luiz Armando
-- Redmine #64300 292-1/292-2/293 - ajuste na geração do registro c110, c113 e 0450 refente as notas fiscais com referencia
-- Rotinas Alteradas: pkb_monta_reg_C100
--
-- Em 16/01/2020 - Luiz Armando
-- Redmine #60559 - feed - ajustando a criação dos registros D100 e D500 referente ao registro 0150
-- Rotinas Alteradas: 
--
-- Em 15/01/2020 - Luis Marques
-- Redmine #63704 - feed - erro de estrutura
-- Rotinas Alteradas: pkb_monta_reg_C500 - Novo campo para o registro C500 a partir de 01/01/2020
--                    pkb_armaz_reg_c500 - Ajuste para armazenar novos campos do registro C500 a partir de 01/01/2020
--
-- Rotinas Alteradas: pk_monta_re
-- Em 14/01/2020 - Luiz Armando Azoni / Luis Marques
-- Redmine #63639 - feed - não gerou registro C591,595 e 597
-- Rotina Alterada: pkb_monta_reg_C500 - Incluido tipo de documento '66' para registros C591, C595 e C597 a partir de 01/01/2020.
--                  pkb_armaz_reg_c500 - Ajustado chamada de gravação com registros em minusculo e na tabela está em maiusculo
--                                       reg(s): C591, C595 e C597
--
-- Em 14/01/2020 - Luis Marques
-- Redmine #63669 - Sped fiscal nao listando doc com sit 08 no C100
-- Rotina Alterada: pkb_monta_reg_C100 - ajustado local para validar antecipação de credito e zerar as bases.
--
-- Em 08/01/2020 - Allan Magrini
-- Redmine #63430- feed - geracao sped fiscal
-- Ano 2019 -> Adicionada a validação na fase 1 gt_row_abertura_efd.dt_ini >= '01/01/2020' --reg_0002
-- Ano 2020 -> 0150 adicionando mais um select para buscar o cod_part, g110 vn_fase := 5.6 alterada a chamada do reg 150 colocada nro_chv
-- Rotina: fkg_qtde_linha_reg_0002, pkb_armaz_reg_0002, pkb_monta_reg_0150, pkb_monta_reg_g110
--
-- Em 08/01/2020 - Allan Magrini
-- Redmine #63422 - feed - campos saindo em layout antigo de 2019
-- Adicionada a validação na fase 7.5 gt_row_abertura_efd.dt_ini >= '01/01/2020'
-- Rotina: pkb_armaz_reg_1390
--
-- Em 08/01/2020 - Luis Marques
-- Redmine #63416 - feed - está saindo o campo para o layout antigo
-- Rotinas Alteradas: PKB_MONTA_REG_1010, PKB_ARMAZ_REG_1010 - Incluida verificação pra só gera dados para
--                    "IND_REST_RESSARC_COMPL_ICMS" a partir de 01/01/2020.
--
-- Em 30/12/2019 - Armando
-- Redmine #62019 - Performance
-- Criadas tmp para o processo, necessário script_csf_own da 2.9.2.11 para utlização desta pck
-- Rotina: GERA_ARQ_EFD_PC_REG_C170, GERA_ARQ_EFD_PC_REG_C175, NOTA_FISCAL_TOTAL, NOTA_FISCAL, ITEM_NOTA_FISCAL, IMP_ITEMNF, NFREGIST_ANALIT, CONHEC_TRANSP
--
-- Em 30/12/2019 - Allan Magrini
-- Redmine #62019 - Registro C110 - Incluir informações do tipo Fisco
-- No cursor c_c110 foi adicionado a condição  ad.dm_tipo in (0,1) -- 0 - Contribuinte/ 1 - Fisco
-- Rotina: pkb_monta_reg_C100
--
-- Em 26/12/2019 - Allan Magrini
-- Redmine #61766  - Inclusão de coluna e domínios para Classificação de Contribuintes do IPI (registro 0002)
-- Alerado o cursor c_c1390 para pegar o valor item_id, dm_tp_residuo, qtd_residuo na fase 3 pkb_ monta e fase 7.5 na pkb_armaz
-- Rotina: pkb_monta_reg_1390 e pkb_armaz_reg_1390
--
-- Em 26/12/2019 - Allan Magrini
-- Redmine #61668 - C190 - alteração na descrição dos Campos 05, 07 e 09 e orientações de preenchimento
-- Alerado o cursor c_c190 para pegar o valor do fcp e adicionado na fase 48.8 vl_opr  =  vl_opr  + vl_fcp_st
-- Rotina: pkb_monta_reg_C100
--
-- Em 26/12/2019 - Allan Magrini
-- Redmine #61183  - Inclusão de coluna e domínios para Classificação de Contribuintes do IPI (registro 0002)
-- Foi Incluido os registro 0002 no processo de geração do arquivo texto
-- Nova Função: fkg_qtde_linha_reg_0002, pkb_monta_reg_0002, pkb_armaz_reg_0002
-- Rotina alterada: pkb_inicia_dados, pkb_armaz_reg_9900, pkb_monta_reg_0990, pkb_monta_bloco_0, pkb_armaz_arq_bloco_0
--
-- Em 26/12/2019 - Allan Magrini
-- Redmine #62107  - Geração dos registros no Sped
-- Foi Incluido os registro C591, C595 e C597 no processo de geração do arquivo texto
-- Nova Função: fkg_qtde_linha_reg_c591, fkg_qtde_linha_reg_c595, fkg_qtde_linha_reg_c597
-- Rotina alterada: pkb_inicia_dados, pkb_monta_reg_9900, pkb_monta_reg_C990, pkb_monta_reg_C500, pkb_armaz_reg_C500
--
-- Em 23/12/2019 - Luiz Armando
-- Redmine #62845 - alteração na declaração do tab_reg_c850 campo cst_icms number(3) para varchar2(3).
--                  alterando o cursor c_c850 concatenando os campos ic.dm_orig||cs.cod_st cst_icms
-- Rotina: pkb_monta_reg_C800
--
-- Em 20/12/2019 - Luis Marques
-- Redmine #61818 - Feed - nao está sendo montado o registro 0150 para o C500
-- Rotina alterada: pkb_monta_reg_0150 - Incluido tratamento para notas fiscais de energia eletrica modelo "06", Gás modelo "28" 
--                  e Agua modelo "29" para retornar o codigo do participante da pessoa do documento.
--
-- Em 18/12/2019 - Luis Marques
-- Redmine #61778 - Feed - reg 0150 de terceiro não está concatenando com o ibge
-- Rotina alterada: pkb_monta_reg_0150 - Incluido modelo "99" de serviços junto com modelos "21" e "22" de telecomunicação.
--
-- Em 16/12/2019 - Allan Magrini
-- Redmine #62548 - Erro Campo C850 - VlrOperação - Sped Fiscal
-- Correção no cursor c_c850, campo vl_opr vai ser igual sum(ic.vl_prod)  - (sum(ic.vl_rateio_descto)
-- Rotina: pkb_monta_reg_C800
--
-- Em 17/12/2019 - Renan Alves
-- Redmine #54463 - Tornar as informações dos documentos fiscais no Bloco G ¿ CIAP não obrigatórias
-- Foi incluído uma verificação no parâmetro documentos fiscais, no momento da geração dos registros G130 e G140
-- Rotina: pkb_monta_reg_g110
--
-- Em 17/12/2019 - Luis Marques
-- Redmine #62113 - Não gerou o registro 0150 do cod_part do D500
-- Rotina alterada: pkb_monta_reg_0150 - Incluido tratamento para notas fiscais de telecomunicação modelos "21" e "22"
--                  para retornar o codigo do participante da pessoa do documento.
--
-- Em 17/12/2019 - Luiz Armando
-- Redmine #62353 - Adequação: não gerar o imposto IPI no registro C170 quando o mesmo não existir na tabela de impostos.
--
-- Em 13/12/2019 - Luis Marques
-- Redmine #50385 - Escrituração Fiscal a fim atender Notas Fiscais com Antecipação de Crédito de ICMS
-- Nova função: fkg_antecipacao_credito_icms - retorna se o documento é de antecipação de credito de ICMS
-- Rotina alterada: pkb_monta_reg_C100 - verificação nos registros C100 e C190 caso seja antecipação de credito
--                  zera a base e o valor do ICMS.
--
-- Em 12/12/2019 - Luis Marques
-- Redmine #61765 - Incluir campo na geração do Sped
-- Rotinas Alteradas: PKB_MONTA_REG_G110, PKB_ARMAZ_REG_G110 - Incluido campo NUM_DA no registro G130 para ser utilizado
--                    apartir de 01/01/2020.
--
-- Em 09/12/2019 - Luis Marques
-- Redmine #61764 - Alterar geração do Sped Fiscal
-- Rotinas Alteradas: PKB_MONTA_REG_G110, PKB_ARMAZ_REG_G110 - Incluido novos campos do registro G140 para serem utilizados
--                    apartir de 01/01/2020.
--
-- Em 05/12/2019 - Luis Marques
-- Redmine #61903 - Ajuste de layout do registro 1010
-- Rotinas Alteradas: PKB_MONTA_REG_1010, PKB_ARMAZ_REG_1010 - Incluido novo campo para o registro
--                    "IND_REST_RESSARC_COMPL_ICMS".
--
-- Em 03/12/2019 - Allan Magrini
-- Redmine #61957 - Campos facultativos - D500
-- Na fase 5, foram colocados valores vindo da rec_d500 nos campos vl_doc, vl_desc, vl_serv, vl_serv_nt, vl_terc e vl_da
-- Rotina: pkb_monta_reg_D500
--
-- Em 08/11/2019 - Luis Marques
-- Redmine #60631/#60990 - Problemas no bloco D / Defeito - está ocorrendo o mesmo erro da ficha 60589
-- Rotinas Alteradas: fkb_ret_cnpjcpj_ibge_cod_part - Ajustado retorno na função de retorno de Cod_part
--                    por municipio.
--
-- Em 06/11/2019 - Allan Magrini
-- Redmine #60888 - Valor Contabil SAT
-- Correção no cursor c_c850 e c_c890, foi somando ao valor item_cupom_fiscal.VL_ITEM_LIQ o campo item_cupom_fiscal.vl_rateio_descto
-- Rotina: pkb_monta_reg_C800 e pkb_monta_reg_C860
--
-- Em 28/10/2019 - Luis Marques
-- Redmine #60419 - Sped Fiscal e Sped Contribuições
-- Nova função: fkb_ret_cnpjcpj_ibge_cod_part
-- Rotina Alterada: pkb_monta_reg_0150 - Mudado indexador para notas e conhecimentos com informações lidas do documento
--                  fiscal para concatenar cnpj ou cpf mais codigo do ibge da cidade, mudado todas as chamadas e gravação
--                  do cod_part dos registros usando nova função fkb_ret_cnpjcpj_ibge_cod_part.
--
-- Em 25/10/2019 - Luis Marques
-- Redmine #60391 - feed - continua nao gerando o 0150 qdo é emissão própria saída para sped fiscal e contribuições
-- Rotina Alterada: pkb_monta_reg_0150 - Ajuste no identificador que para noemral é id_pessoa, para documento id do documento.
--
-- Em 25/10/2019 - Luis Marques
-- Redmine #60346 - Feed - Corrigir a descrição do parâmetro no campo dsc_param / sped fiscal e sped contribvuições
-- Rotina Alterada: pkb_monta_reg_0150 - ajuste na leitura do tipo de documento proprio/terceiro para ler os dados.
--
-- Em 22/10/2019 - Luis Marques
-- Redmine #58808 - Cidade do relatório divergente da cidade da NFe
-- Rotina Alterada: pkb_monta_reg_0150 - para ler dados da pessoa ou por cod_part ou por documento fiscal, alterada
--                  chamada em diversos blocos.
--
-- Em 21/10/2019 - Luis Marques
-- Redmine #60071 - Registro E200 não sendo montado com base no 0015
-- Rotina Alterada: pkb_monta_reg_0015 - Colocada verificação se existe dados do registro E200 por estado
--                  para a montagem do registro 0015.
--
-- Em 04/10/2019 - Renan Alves
-- Redmine #60091 - Informado código errado para recuperação
-- Conforme solicitado, foi realizado a alteração dos campos referente ao IBGE, para que seja recuperado
-- o campo do IBGE composto de 7 dígitos
-- Rotina: pkb_monta_reg_1400
--
-- Em 04/10/2019 - Renan Alves
-- Redmine #59342 - Alterar a geração do CR_30 - código 2.5
-- Foi alterado o select do cursor C_1400, alterando o decode por um case para que recuperada o EMPRESA_ID
-- da cidade que está gerando o arquivo
-- Rotina: pkb_monta_reg_1400
--
-- Em 02/10/2019 - Luis Marques
-- Redmine #59545 - Apuração do BLOCO B DF
-- Rotinas Alteradas: pkb_monta_reg_B020 - Tratado campo "vl_iss_rt" para não colocar nulo a não ser cancelado ou
--                    inutilizado.
--
-- Em 02/10/2019 - Renan Alves
-- Redmine #59022 - Erro ao gerar registro 0450
-- Foi comentado o IF (vv_gerou_c110 = 'N') que verificava se existia informação gerada no registro C110, para
-- gerar ou não o registro C113, dentro do registro 0450
-- Rotina: pkb_monta_reg_0450
--
-- Em 20/09/2019 - Luis Marques
-- Redmine #58996 - Bloco K280 não esta incluindo o 0200 (cadastro do item)
-- Rotina Alterada: pkb_monta_reg_k280 - Chamada para gerar o registro 0200(cadastro dos produtos) quando gerado o registro K280.
--                  Correção do cursor c_cae para gerar o registro K280 só deve ser gerado quando o tipo do item
--                  for ('00','01','02','03','04','05','06','10').
--
-- Em 19/09/2019 - Luis Marques
-- Redmine #58997 - Notas Canceladas/Denegadas Informar nulo C100 - Campos vl_pis_st e vl_cofins_st
-- Rotina Alterada: pkb_monta_reg_C100 - colocado nulo nos campos vl_pis_st e vl_cofins_st aonde estava
--                  sendo passados valores de retensão e retirado if que colocava valor nulo para esses campos.
--
-- Em 17/09/2019 - Allan Magrini
-- Redmine 58907 - Inserção da "descrição complementar" no registro C110
-- Foi incluido no cursor cursor c_c110, na subquery c111 o retorno da informação pk_csf.fkg_converte(ad.conteudo) txt_compl
-- Rotina Alterada: pkb_monta_reg_c100
--
-- Em 12/09/2019 - Luis Marques
-- Redmine #58615 - Erros no SPED DF
-- Rotinas Alteradas - pkb_monta_reg_b420, pkb_monta_reg_n440 - Trazer nestes dois blocos tudo menos se
--                     o participante estiver parametrizado como setor publico.
--
-- Em 03/09/2019 - Luis Marques
-- Redmine #58280 - defeito- buscar para gerar no registro 1400 somente o que tiver validada
-- Rotina Alterada: pkb_monta_reg_1400 ajustado para na leitura da tabela 'inf_valor_agreg' trazer apenas
-- registros validados.
--
-- Em 30/08/2019 - Luis Marques
-- Redmine #57949 - Alterar geração do C100 campos 28 e 29
-- Colocado verificação se os campos VL_PIS_ST e VL_COFINS_ST estiverem nulos serem setados com zero (0).
-- Rotina Alterada: pkb_monta_reg_C100
--
-- Em 27/08/2019 - Luis Marques
-- Redmine #57953 - Corrigir geração do registro 1400 do SPED ICMS/IPI
-- Rotina Alterada: pkb_monta_reg_1400 - Corrigido leitura na tabela 'inf_valor_agreg' em que o 'cod_dipam' estava fixo
-- null, buscando conforme item e estado.
--
-- Em 26/08/2019 - Luis Marques
-- Redmine #57641 - Valores do DIFAL localizados errados no registro C101
-- Rotina Alterada: pkb_monta_reg_C100 - Alterado para se for devolução inverte os valores de diferencial de aliquota
-- no registro C101 conforme manual do SPED.
--
-- Em 03/06/2019 - Marcos Ferreira
-- Redmine #57691 - SPED Fiscal - Erros nos registros B420 e B440
-- Alterações: Tratado forma sintética para geração do Bloco B420 / B440
-- Procedures Alteradas: pkb_monta_reg_B420
--
-- Em 14/08/2019
-- Redmine #53699 - Tela de Item - Aba Alteração de Item e Tabela
-- Rotina: pkb_monta_reg_0200 - Alterado para ler alter_item apenas com data menor ou igual a data final do período.
--
-- Em 17/07/2019 - Allan Magrini
-- Redmine #56300 - Erro SPED ICMS IPI
-- Alterado o cursor c_c190 pois estava gerando duas linhas com registro 90 ao passar pelo if
-- c_c190 foi incluido (cfo.cd in (1556, 3556, 5602, 5605, 5929, 6602, 6929) and (sum(res.vl_icms) > 0)) then  res.dm_orig_merc || '90'
-- Foram alterados os if (rec_c190.cfop_cd in (1556... e incluido vt_bi_tab_reg_c190(i)(j).vl_icms  > 0
-- e  if (rec_c170.cfop in (1556...  e incluido  vt_bi_tab_reg_c170(i)(j).vl_icms  > 0
-- Rotina: pkb_monta_reg_c100
--
-- Em 02/07/2019 - Renan Alves
-- Redmine #55452 - Ao passar no Validador é dado erro no bloco B
-- Foi alterado o tipo de imposto do cursor C_B420, que se encontrava com o tipo "Retenção" (IIN.DM_TIPO = 1)
-- para o tipo "Imposto" (IIN.DM_TIPO = 0), pois, o B420 deve trazer informações do tipo imposto.
-- Rotina: pkb_monta_reg_B420
--
-- Em 26/06/2019 - Luiz Armando Azoni
-- Redmine #36339 - Geração do registro 1400
-- Adicionado no cursor c_1400 a query do registro Cr30 da gia para geração do registro DIPAM no sped icms ipi
-- Rotina: pkb_monta_reg_1400
--
-- Em 19/06/2019 - Luiz Armando Azoni
-- Redmine #55526 - Erro ao gerar SPED
-- loga após a fase 48.20, se a vt_bi_tab_reg_c190(i).count for nula, o sistema estava acusando erro de no_data_found
-- foi adicionado o tratamento de erro para gerar log para que não interrompa o processo.
-- Rotina: pkb_monta_reg_C100
--
-- Em 14/06/2019 - Renan Alves
-- Redmine #55138 - Duplicidade de registro C190
-- Foi alterado o cursor C_SEM_C190, incluíndo um agrupando, pois, ele encontrava-se gerando informações
-- duplicadas, sendo que o correto, seria apeas um registro do C1900.
-- Rotina: pkb_monta_reg_C100
--
-- Em 29/05/2019 - Luiz Armando Azoni
-- Redmine #54853 - feed - Depois da atualização semanal no QA parou de sair notas no C100
-- O sistema estava gerando o registro C190 para notas fiscais  3-Documento cancelado; 4-Documento cancelado extemporâneo; 6-NF-e ou CT-e Numeração inutilizada
-- gerando erro na geração do arquivo da EFD.
-- processo corrigido adicinando a validação if rec_c100.sitdocto_id not in (3,4,6) then
-- Rotina: pkb_monta_reg_C100
--
-- Em 29/05/2019 - Renan Alves
-- Redmine #54803 - SPED FISCAL - ERRO BLOCO B020 E B025 - erro geração
-- Foi incluído uma tratativa para situações da qual, não exista registro C190 para a nota fiscal. Para
-- essas situações, deverá ser gerado uma mensagem (log) no momento da geração do arquivo.
-- Rotina: pkb_monta_reg_b020
--
-- Em 27/05/2019 - Allan Magrini
-- Redmine #54693 Erro D500 documentos cancelados
-- Ao gerar o arquivo do SPED e importar no PVA da receita federal é apresentado alguns erros, onde está sendo preenchido campos que não deveriam
-- ser preenchidos quando a situação do documento é cancelada.
-- na vn_fase := 3, onde é tratado a parte de geração dos registros quando a situação do documento é cancelado e ou inutilizado,
-- favor alterar para null as variáveis vt_tab_reg_d500(i).cod_part e vt_tab_reg_d500(i).sub. Foi retirado o nvl do vl_serv na pkb_armaz_reg_d500 e colocado no select da PKB_MONTA_REG_D500
-- Rotina PKB_MONTA_REG_D500 e pkb_armaz_reg_d500
--
-- Em 21/05/2019 - Allan Magrini
-- Redmine #54580 Erro ao montar o registro D510
-- Foi constado que ao gerar o registro D510, a package PK_GERA_ARQ_EFD recupera os valores através do cursor C_D510 e o registro IND_REC
-- no processo está buscando os valores do DM_IND_REC, ao invés de buscar do campo DM_IND_REC_COM que representa os valores corretos
-- sera alterada DM_IND_REC para DM_IND_REC_COM
-- Rotina PKB_MONTA_REG_D500
--
-- Em 21/05/2019 - Allan Magrini
-- Redmine #54580 Montagem do Campo VL_TERC do registro D500
-- Foi constado que ao gerar o registro D500 o campo VL_TERC não é completado com o valor ¿0¿ quando a 
-- informação é nula na tabela, sera colocado nvl(t.vl_terc,0) no cursor.
-- Rotina PKB_MONTA_REG_D500
--
-- Em 20/05/2019 - Renan Alves
-- Redmine #54315 - SPED FISCAL - ERRO BLOCO B020 E B025
-- O problema de duplicidade, foi devido a coluna tipo de imposto (0 - Tipo Imposto) estar comentado no select
-- do cursor C_B020 e C_B025.
-- Rotina: pkb_monta_reg_b020
--
-- Em 20/05/2019 - Allan Magrini.
-- Redmine # 53659 ERRO GERAÇÃO SPED FISCAL O sistema não gerou o valor do IPI no registro C100 e GEROU o
--                 valor do IPI no registro C190 causando erro de validação no PVA
-- Foram retiradas nas linhas 36243 , 36494 , 37252 o cfop 4949 da validação para geração do c100 e c170
-- conforme reunião com a consultoria e o Luiz Armando
-- Rotina pkb_monta_reg_C100
--
-- Em 10/05/2019 - Renan Alves
-- Redmine #53575 - Erro de EFD Fiscal Aceco DF
-- Foi incluído a coluna Valor ISS (VL_ISS_P), pois, após atualização do leiaute (2019) é necessário
-- enviarmos o valor referente a essa coluna.
-- Rotina: pkb_monta_reg_B420
-- Foi incluído no registro B001 a verificação dos registros B420, B440, B460 e B470 para a informações
-- existente no bloco B.
-- Rotina: pkb_monta_reg_B001
--
-- Em 23/04/2012 - Luiz Armando.
-- Redmine # 53562 Adequação do cursor c_nf , no campo t.vl_imp_trib_ipi alterado para decode(t.vl_imp_trib_ipi,0,null,t.vl_imp_trib_ipi) vl_imp_trib_ipi
--                 no registro C100 o campo do IPI só pode ser preenchido quando seu valor for maior do que zero, senão ele deverá ser nulo.
--                 Retirada a validação acima. Quando o tipo de documento fiscal for 65 o campo valor do IPI já esta recebendo null.
--
-- Em 12/04/2019 - Angela Inês.
-- Redmine #53533 - Montagem do registro C110 e C115.
-- Ao montar o registro C110 e as informações vinculadas, considerar o registro C115 somente se atender nota de operação de saída (nota_fiscal.dm_ind_oper=1) e
-- modelo fiscal sendo 01-Nota Fiscal, 04-Nota Fiscal de Produtor ou 1B-Nota Fiscal Avulsa.
-- Rotina: pkb_monta_reg_C100.
--
-- Em 10/04/2019 - Eduardo Linden
-- Redmine #53378 - Geração dos registros C113
-- Inclusão da linha para incluir valor  vt_bi_tab_reg_c190 para vl_ipi para versão anterior à 112.
-- Rotina : pkb_monta_reg_c100
--
-- Em 10/04/2019 - Eduardo Linden
-- Redmine #53353 - Erro no PVS C170 CSTIPI
-- Remoção do rec_c170.orig para o cst_ipi
-- Rotina: pkb_monta_reg_c100
--
-- Em 10/04/2019 - Eduardo Linden
-- Redmine #53343 - erro na geração do arquivo
-- Correção nas variaveis vv_cst_pis (pkb_monta_reg_c100) e cst_ipi (type tab_reg_c170)
-- Rotina: pkb_monta_reg_c100
--
-- Em 09/04/2019 - Eduardo Linden
-- Redmine #53310 - Ajuste sobre preenchimento de CST IPI e ICMS - SPED Fiscal
-- Correção sobre preenchimento das CST's de IPI e ICMS  com o campos de origem
-- Rotina: pkb_monta_reg_c100
--
-- Em 08/04/2019 - Fernando Basso
-- Redmine #53107 - Geração dos registros C113
-- Correção na montagem do arquivo acertando a quantidade linhas geradas com a apresentada no proprio arquivo
-- Rotinas: pkb_monta_reg_C100 e pkb_monta_reg_0450
--
-- Em 05/04/2019 - Eduardo Linden
-- Redmine #53187: feed - está do mesmo jeito
-- Correções e ajustes na rotina , referentes ao controles dos registros C170 e C190.
-- Rotina alterada: pkb_monta_reg_c100
--
-- Em 04/04/2019 - Eduardo Linden
-- Redmine #53123 - Pontos de correções do SPED Fiscal
-- Considerar os pontos levantados pelo Thiago para ajustar os valores de ICMS e IPI devido as criticas no PVA.
-- Rotina alterada: pkb_monta_reg_c100
--
-- Em 02/04/2019 - Fernando Basso
-- Redmine #52774 - Geração dos registros C113
-- Na Montagem da quebra de informação adicional ocultar as linhas sem texto complementar (C110)
-- Rotina: pkb_monta_reg_C100
--
-- Em 25/03/2019 - Angela Inês.
-- Redmine #31021 - SPED Contribuições - NFE Inutilizadas.
-- Considerar as Inutilizações sem vínculo com Nota Fiscal, na montagem do Registro C100.
-- Considerar as Inutilizações sem vínculo com Conhecimento de Transporte, na montagem do Registro D100.
-- Rotinas: pkb_monta_reg_c100 e pkb_monta_reg_d100.
--
-- Em 07/03/2019 - Fernando Basso
-- Redmine #51994 - Ajustar tags ibge_cidade_ini e ibge_cidade_fim - SPED
-- Correção no recebimento de valores das cidades de inicio e fim recebendo os valores anteriormente armazenados em tabela
-- Rotina: pkb_monta_reg_D100
--
-- Em 06/03/2019 - Renan Alves
-- Redmine #51641 - Erro de inventario no arquivo do Sped
-- Foi realizado um tratamento na coluna COD_ST, incluindo o RPAD.
-- Rotina: pkb_monta_reg_H010
--
-- Em 27/02/2019 - Renan Alves
-- Redmine #51565 - Geração do Sped de ICMS e IPI - Gerou erro no log mas o processo continua com status de "Em Geração"
-- Foi realizado uma tratativa para situações das quais forem apresentados erros em meio ao processo, o registo que
-- contém erros, será alterado para "Erro na geração do arquivo".
-- Rotina: pkb_gera_arquivo_efd
--
-- Em 21/02/2019 - Eduardo Linden
-- Redmine #51795 - Tratar o não preenchimento dos campos para CTE - Sped de ICMS e IPI
-- Para o registro D100, os campos COD_PART, DT_DOC, COD_MUN_ORIG e COD_MUN_DEST não podem estar preenchidos com as CTe's tenham os seguintes código de situação (cod_sit) 02,03 e 04.
-- Só poderão estar preenchidos os seguintes campos: reg, ind_oper, ind_emit, cod_mod, cod_sit, ser, sub, num_doc e chv_cte.
-- Rotina :pkb_monta_reg_D100
--
-- Em 20/02/2019 - Angela Inês.
-- Redmine #51392 - Correção na montagem do Registro C191.
-- Considerar para o campo VL_FCP_OP, os valores de FCP do Imposto ICMS com CST: "00" , "10", "20", "51", "70", e "90".
-- Considerar para o campo VL_FCP_ST, os valores de FCP do Imposto ICMS-ST, com CST: "10", "30", "70", "90", "201", "202", "203", e "900".
-- Considerar para o campo VL_FCP_RET, os valores de FCP do Imposto ICMS-ST, com CST: "60" e "500".
-- Rotina: pkb_monta_reg_C100.
--
-- Em 20/02/2019 - Eduardo Linden
-- Redmine #51748 - Inclusão de novo paramentro estado_id ( Sped de ICMS e IPI - Erro na Exportação do Registro 1400)
-- Inclusão de novo campo estado_id no cursor c_1400 e ajustar o código para o novo parametro en_estado_id da function  pk_csf_efd.fkg_recup_cod_ipm_item.
-- Rotina: pkb_monta_reg_1400
--
-- Em 14/02/2019 - Angela Inês.
-- Redmine #51575 - Correção no processo de geração dos valores de FCP.
-- Manter a soma dos valores de FCP do imposto ICMS no registro C100 a partir de 01/08/2018.
-- Manter a soma dos valores de FCP-ST do imposto ICMS-ST no registro C100 a partir de 01/08/2018.
-- Manter a soma dos valores de FCP do imposto ICMS no registro C170 a partir de 01/08/2018.
-- Manter a soma dos valores de FCP-ST do imposto ICMS-ST no registro C170 a partir de 01/08/2018.
-- Manter a soma dos valores de FCP do imposto ICMS no registro C190 a partir de 01/08/2018.
-- Manter a soma dos valores de FCP-ST do imposto ICMS-ST no registro C190 a partir de 01/08/2018.
-- Rotina: pkb_monta_reg_C100.
--
-- Em 11/02/2019 - Angela Inês.
-- Redmine #51392 - Correção na montagem do Registro C191.
-- O registro C191 deve ser montado após o registro C190, uma linha de registro C191 para cada linha do registro C190. Atualmento o proceso gera o registro C191
-- após todos os registros C190. Considerar para o campo VL_FCP_OP, os valores de FCP do Imposto ICMS com CST: "00" , "10", "20", "51", "70", e "90".
-- Considerar para o campo VL_FCP_ST, os valores de FCP do Imposto ICMS mais () os valores de FCP do Imposto ST, com CST: "10", "30", "70", "90", "201", "202",
-- "203", e "900". Considerar para o campo VL_FCP_RET, os valores de FCP do Imposto ICMS mais () os valores de FCP do Imposto ST, com CST: "60" e "500".
-- Rotina: pkb_monta_reg_C100.
--
-- Em 23/01/2019 -  Eduardo Linden
-- Redmine #50291 - Processos de Geração do Arquivo Sped Fiscal.
-- Inclusão dos registros K290, K291, K292, K300, K301 e K302.
-- Rotinas novas: pkb_monta_reg_k290, pkb_monta_reg_k291, pkb_monta_reg_k292, pkb_monta_reg_k300, pkb_monta_reg_k301, pkb_monta_reg_k302,
-- fkg_qtde_linha_reg_k290, fkg_qtde_linha_reg_k291,fkg_qtde_linha_reg_k292, fkg_qtde_linha_reg_k300, fkg_qtde_linha_reg_k301, fkg_qtde_linha_reg_k302
-- Rotinas alteradas: pkb_monta_reg_k100, pkb_monta_reg_9900, pkb_monta_reg_k990, pkb_inicia_dados,pkb_armaz_reg_k100
--
-- Em 23/01/2019 - Marcos Ferreira
-- Redmine #50799: Erro de geração do SPED Fiscal - Produção de Usina (Santa Fé)
-- Solicitação: Correção de erro de ORA-06502: PL/SQL: erro: character string buffer too small numérico ou de valor
-- Alterações: Associação de Data em formato errado no vetor vt_bi_tab_reg_1391
-- Procedures Alteradas: pkb_monta_reg_1390
--
-- Em 21/01/2019 - Eduardo Linden
-- redmine #50733 - feed - registro 1975
-- Correção de casa decimal para o campo aliq_imp_base para o registro 1975
-- Rotina alterada:pkb_armaz_reg_1970
--
-- Em 21/01/2019 - Eduardo Linden
-- Redmine #50718 - feed - erro na estrutura do arquivo
-- Correção do formato campo IND_AP para os registros 1960, 1970 e 1980. Correção na lógica de dedução para
-- preenchimento do campo IND_MOV para o registro B001.
-- Rotinas alteradas: pkb_armaz_reg_1980, pkb_armaz_reg_1970, pkb_armaz_reg_1960 e pkb_monta_reg_B001
--
-- Em 18/01/2019 - Eduardo Linden
-- Redmine #50686 - feed - arquivo sped fiscal giaf
-- Correção para geração dos registros GIAF , tanto sua chamada para armazenamento do arquivo quanto correção
-- no armazenamento do registro 1975 (GIAF 3)
-- Rotinas alteradas: pkb_armaz_arq_bloco_1 e pkb_armaz_reg_1970
--
-- Em 18/01/2019 - Angela Inês.
-- Redmine #50666 - Correção na geração do Sped Fiscal - Registro 1010.
-- Considerar as informações do GIAF mo Registro 1010, desde que a versão do leiaute seja maior ou igual a 112, que se refere a partir de Janeiro/2019.
-- Rotinas: pkb_monta_reg_1010 e pkb_armaz_reg_1010.
--
-- Em 16/01/2019 - Angela Inês.
-- Redmine #50611 - Correção na geração do arquivo Sped Fiscal - Bloco B e GIAF.
-- Permitir as informações do Bloco B e GIAF para os arquivos cuja data inicial sejam maior ou igual a 01/01/2019, ou através do código da versão sendo a partir
-- da versão 112.
-- Rotinas: pkb_monta_bloco_1 e pkb_monta_array_efd.
--
-- Em 10/01/2019 - Eduardo Linden
-- Redmine #50407 - Feed - Arquivo Sped Fiscal
-- Correções na geração do bloco B
-- Rotinas alteradas: pkb_monta_reg_B020,pkb_armaz_reg_1010,pkb_armaz_reg_b020
--
-- Em 09/01/2019 - Eduardo Linden
-- Redmine #50401 - feed - arquivo Sped Fiscal
-- Correção do registro 9900, incluidos os registros do bloco b , C191 e GIAF
-- Rotinas alteradas: pkb_monta_reg_9900,pkb_monta_reg_b990, pkb_armaz_reg_b990
--
-- Em 09/01/2019 - Eduardo Linden
-- Redmine #50390 - feed - apuração ISS e Sped Fiscal
-- inclusão do campo 'B460' na montagem da linha do registros B460.
-- Rotina alterada: pkb_armaz_reg_b460
--
-- Em 09/01/2019 - Angela Inês.
-- Redmine #50376 - Finalizar as rotinas de armazenamento do Bloco B.
-- Tecnicamente, o processo possui LOOP com variáveis de índice, e o LOOP não estava sendo finalizado, mantendo sempre o mesmo registro e não finalizando.
-- Rotinas: todas pkb_armaz_reg_bXXX.
--
-- Em 09/01/2019 - Eduardo Linden
-- Redmine #50315 - Feed - Apuração de ISS e Sped Fiscal
-- Ajuste no cursor c_b470
-- Rotinas Alteradas: pkb_monta_reg_B470
--
-- Em 07/01/2019 - Eduardo Linden
-- Redmine #50289 - Feed - Apuração de ISS e Sped Fiscal
-- Ajuste no cursor c_b460
-- Rotinas Alteradas: pkb_monta_reg_B460
--
-- Em 04/01/2019 - Eduardo Linden
-- Redmine #49828 - Processos de Geração do Arquivo Sped Fiscal.
-- Inclusão dos registros 1960, 1970, 1975 e 1980
-- Rotinas novas: fkg_qtde_linha_reg_1960, fkg_qtde_linha_reg_1970, fkg_qtde_linha_reg_1975, fkg_qtde_linha_reg_1980,
-- pkb_monta_reg_1960, pkb_monta_reg_1970, pkb_monta_reg_1980
-- Rotinas alteradas: pkb_monta_bloco_1, pkb_monta_reg_1990,pkb_monta_reg_1010
--
-- Em 28/12/2018 - Eduardo Linden
-- Redmine #49828 - Processos de Geração do Arquivo Sped Fiscal.
-- Desenvolvimento do bloco B -  registros B001, B020, B025, B420, B440, B460, B470, B990
-- Alteração nos registros C170, C176 e C177. Inclusão no registro C191.
-- Rotinas novas: pkb_armaz_reg_b001, pkb_armaz_reg_b020, pkb_armaz_reg_b025, pkb_armaz_reg_b440, pkb_armaz_reg_b460, pkb_armaz_reg_b470, pkb_armaz_reg_b990,
-- fkg_qtde_linha_reg_b001,fkg_qtde_linha_reg_b020,fkg_qtde_linha_reg_b025,fkg_qtde_linha_reg_b440,fkg_qtde_linha_reg_b460,fkg_qtde_linha_reg_b470,,fkg_qtde_linha_reg_b990,pkb_monta_bloco_b,
-- fkg_qtde_linha_reg_c191
-- Rotinas Alteradas: pkb_monta_reg_C990, pkb_monta_reg_C100,pkb_armaz_reg_c100,pkb_inicia_dados
--
-- Em 11/12/2018 - Angela Inês.
-- Redmine #49588 - Alteração da geração do Arquivo Sped Fiscal - Datas inválidas.
-- Ao identificar as datas de abertura do arquivo, inicial e final, com datas "fixas" nos processos/testes, utilizar o comando técnico "to_date" formatando
-- como "dd/mm/rrrr".
-- Rotina: pkb_monta_reg_C100.
--
-- Em 06/12/2018 - Marcos Ferreira
-- Redmine #48578 - Erro na pk_gera_arq_efd - Alta Genetics
-- Solicitação: Erro ao gerar arquivo
-- Alterações: Corrigido a associação de campo String para Date. Removido o To_char
-- Procedures Alteradas: pkb_monta_reg_k100
--
-- Em 29/11/2018 - Angela Inês.
-- Redmine #49206 - Ajuste nos valores do Imposto ICMS e ICMS-ST incluindo os valores de FCP.
-- 1) Na geração do Arquivo Sped Fiscal, alterar o registro C190 eliminando a soma do valor de FCP do Imposto ICMS, incorporado no Valor da Operação.
-- 2) Na geração do Arquivo Sped Fiscal, alterar o registro C170 incluindo a soma do valor de FCP do Imposto ICMS, ao Valor Tributado de ICMS.
-- 3) Na geração do Arquivo Sped Fiscal, alterar o registro C170 incluindo a soma da alíquota de FCP do Imposto ICMS, à Alíquota de ICMS.
-- 4) Na geração do Arquivo Sped Fiscal, alterar o registro C170 incluindo a soma do valor de FCP do Imposto ICMS-ST, ao Valor Tributado de ICMS-ST.
-- 5) Na Apuração do ICMS, incluir a soma do valor de FCP do Imposto ICMS, ao Valor Tributado de ICMS, para os campos: "Valor total dos débitos por Saídas e
-- prestações com débito do imposto" (vl_total_debito), " Valor total dos créditos por Entradas e aquisições com crédito do imposto" (vl_total_credito), "Valores
-- recolhidos ou a recolher, extraapuração." (vl_deb_esp).
-- Rotina: pkb_monta_reg_C100.
--
-- Em 31/10/2018 - Angela Inês.
-- Redmine #48344 - Correção na geração do arquivo - Registro C190 - Valores de FCP.
-- Considerar a origem da mercadoria para recuperar os valores de FCP de ICMS e ICMS-ST, para montagem do Registro C190.
-- Rotina: pkb_monta_reg_C100.
--
-- Em 25/10/2018 - Angela Inês.
-- Redmine #48133 - Correção na montagem do Registro C190 - Valores de FCP.
-- Nem todas as notas fiscais possuem os impostos ICMS e ICMS-ST para um mesmo Item de Nota Fiscal, portanto, ao recuperar os valores, é possível que o Item da
-- Nota Fiscal possua somente o Imposto ICMS. Acertar o processo para recuperar os valores separadamente.
-- Rotina: pkb_monta_reg_C100.
--
-- Em 23/10/2018 - Angela Inês.
-- Redmine #48042 - Correções na geração do Sped Fiscal e Livro Fiscal - Valores de FCP.
-- 1) No arquivo do Sped Fiscal, registro C100, o valor tributado de ICMS será somado com o valor do FCP, sem identificar se a Empresa é ou não do Rio de Janeiro.
-- 2) No arquivo do Sped Fiscal, registro C100, o valor tributado de ICMS-ST será somado com o valor do FCP-ST, sem identificar se a Empresa é ou não do Rio de Janeiro.
-- 3) No arquivo do Sped Fiscal, registro C190, o valor da operação será somado com o valor do FCP, sem identificar se a Empresa é ou não do Rio de Janeiro.
-- 4) No arquivo do Sped Fiscal, registro C190, o valor tributado de ICMS será somado com o valor do FCP, sem identificar se a Empresa é ou não do Rio de Janeiro.
-- 5) No arquivo do Sped Fiscal, registro C190, o valor da alíquota de ICMS será somado com o valor da alíquota do FCP, sem identificar se a Empresa é ou não do Rio de Janeiro.
-- 6) No arquivo do Sped Fiscal, registro C190, o valor tributado de ICMS-ST será somado com o valor do FCP-ST, sem identificar se a Empresa é ou não do Rio de Janeiro.
-- 7) No arquivo do Sped Fiscal, registro C190, o valor da alíquota de ICMS-ST será somado com o valor da alíquota do FCP-ST, sem identificar se a Empresa é ou não do Rio de Janeiro.
-- 8) Essas somas deverão estar disponíveis somente com os arquivos enviados com data até 31/12/2018. A partir de Janeiro/2019 teremos um novo leiaute que irá contemplar as informações.
-- Rotina: pkb_monta_reg_C100.
--
-- Em 24/08/2018 - Angela Inês.
-- Redmine #46323 - Alteração na geração do Registro C113 - Sped Fiscal.
-- Considerar as Notas Fiscais Mercantis de Emissão Própria e de Terceiros para montagem do Registro C113 - Documento Fiscal referenciado.
-- Rotinas alteradas:
-- 1) pkb_monta_reg_0450 - Geração de Informações Complementares.
-- 2) pkb_monta_reg_C100 - Geração dos documentos fiscais - Registro C113 - Documento Fiscal referenciado.
--
-- Em 20/08/2018 - Marcos Ferreira
-- Redmine #45828 - Realizar adequação - Correção de layout Registro 1100
-- Solicitação: Adequação ao layout do sped fiscal, campo NRO_DE alterado para varchar2(14)
-- Alterações: type: tab_reg_1100
--
-- Em 18/06/2018 - Karina de Paula
-- Redmine #40168 - Conversão de CTE e Geração dos campo COD_MUN_ORIG e COD_MUN_DEST no registro D100 do Sped de ICMS e IPI
-- Alterada a Rotina: pk_gera_arq_efd =>  Incluídos novos campos no cursor c_d100 (ibge_cidade_ini / descr_cidade_ini / sigla_uf_ini
-- ibge_cidade_fim / descr_cidade_fim / sigla_uf_fim)
--
-- Em 18/06/2018 - Marcos Ferreira
-- Redmine: #44070 - SPED Fiscal - Advertencias registro C190 diferente do VL_DOC do C100
-- Problema: O campo valor da operação está sendo zerado erroneamente no Bloco C190, devido a regra dos CFOP´s
-- Correção:  vn_fase = 48.7 - Remover o zeramento do campo no if que utilizam as CFOPs (1556, 3556, 5602, 5605, 5929, 6602, 6929)
--
-- Em 09/05/2018 - Marcos Ferreira
-- Redmine: #36113 - ERRO POR DIFERENÇA ENTRE C170 E C190
-- O Validador indica erro ao conferir a aliquota de icms do bloco C170 (itens) E C190 (analítico)
-- Correção:
--   1) Incluido no Cursor c_c190 o Join com a Tabela CFOP para retornar o CFOP_CD.
--   2) Incluído a mesma validação do IF do Bloco C170 no Bloco C190 na associação do vetor vt_bi_tab_reg_c190(i)(j).aliq_icms  :=
--
-- Em 20/04/2018 - Angela Inês.
-- Redmine #41971 - Alteração na geração do Sped Fiscal - Registro C110.
-- Ao fazer a quebra de 255 caracteres, está "sobrando" o último caracter como espaço, e nesse caso esse espaço não está sendo eliminado.
-- Correção: Eliminar os espaços no registro C110 - Informações Adicionais.
-- Rotina: pkb_monta_reg_C100 - cursor c_c110.
--
-- Em 02/04/2018 - Angela Inês.
-- Redmine #41204 - Correção no processo de geração do Sped Fiscal - Registro E531.
-- A variável utilizada para identificação do Registro E531 não estava sendo utilizanda corretamente.
-- Correção técnica: alimentar a variável de índice tridimensional.
-- Rotina: pkb_armaz_reg_e500.
--
-- Em 29/03/2018 - Angela Inês.
-- Redmine #40761 - Parametro de Código de Ajuste do IPI não destacado (E530) e Documentos fiscais (E531) (Aceco).
-- 1) Acertar as variáveis utilizadas internamente para a Geração do Arquivo Sped Fiscal dos registros E531.
-- Rotinas: pkb_monta_reg_E990 e pkb_monta_reg_9900.
--
-- Em 16/03/2018 - Karina de Paula
-- Redmine #39930 - Incluir Notas Denegadas no Sped Fiscal
-- Alterada a pk_gera_arq_efd na rotina pkb_monta_reg_C100 para verificar se a situação do documento é "04 - NF-e ou CT-e denegado"
-- para popular o nro_chave_nfe do array.
-- Rotina alterada: pkb_monta_reg_C100
--
-- Em 09/03/2018 - Angela Inês.
-- Redmine #40359 - Erro de estrutura no arquivo do sped fiscal e na apuração do IPI.
-- Ao montar o registro D100, considerar os campos COD_MUN_ORIG e COD_MUN_DEST, se o arquivo for com data a partir de Janeiro/2018.
-- Rotina: pkb_armaz_reg_d100.
--
-- Em 08/03/2018 - Angela Inês.
-- Redmine #40180 - Alteração na geração do arquivo Sped Fiscal - Registros C100 e 0450.
-- 1) Criado parâmetro em "Parâmetros do Sped ICMS/IPI": param_efd_icms_ipi.dm_quebra_infadic_spedf - 0-Não, 1-Sim.
-- 2) Alterar o processo de geração do arquivo, recuperando o campo param_efd_icms_ipi.dm_quebra_infadic_spedf, através da empresa vinculada com a abertura do
-- arquivo (abertura_efd.empresa_id).
-- 3) Se o parâmetro estiver parametrizado como 0-Não, permanecer o processo montando a informação adicional do registro C110 somente com os 255 caracteres.
-- 4) Se o parâmetro estiver parametrizado como 1-Sim, alterar o processo montando a informação adicional do registro C110 com todos os caracteres e quebrando
-- em linhas distintas.
-- Rotinas: pkb_monta_reg_0450, pkb_monta_reg_D100, pkb_monta_reg_C500 e pkb_monta_reg_C100.
--
-- Em 02/03/2018 - Angela Inês.
-- Redmine #40049 - Correção na geração do arquivo Sped Fiscal - Registro 0210.
-- Alterar a máscara do campo PERDA para "999,0000".
-- Rotina: pkb_armaz_reg_0200.
--
-- Em 23/02/2018 - Angela Inês.
-- Redmine #39755 - Correção no processo de geração do Sped Fiscal - Registro D100.
-- Identificar se o conhecimento de transporte é de emissão própria ou de terceiro, e atualizar os campos relacionados com o IBGE de origem ou destinatário, ficando:
-- Se Emissão Própria, o Código do IBGE de Origem será da cidade da empresa/emitente, e o Código do IBGE de Destino será da cidade do participante/destinatário.
-- Se Emissão de Terceiro, o Código do IBGE de Origem será da cidade do participante/destinatário, e o Código do IBGE de Destino será da cidade da empresa/emitente.
-- Rotina: pkb_monta_reg_D100.
-- Redmine #39770 - Correção no processo de geração do Sped Fiscal - Registro D100.
-- Utilizar variáveis distintas para atualizar os campos COD_MUN_ORIG e COD_MUN_DEST.
-- Rotina: pkb_monta_reg_D100.
--
-- Em 14/02/2018 - Angela Inês.
-- Redmine #39400 - Alterações conforme guia prático da EFD ICMS/IPI.
-- 1) Incluir as colunas COD_MUN_ORIG e COD_MUN_DEST no registro D100. As colunas são obrigatórias para os modelos fiscais "57", "63" ou "67".
-- Consideramos o COD_MUN_ORIG como sendo o IBGE da cidade da empresa que emitiu o conhecimento de transporte (conhec_transp.empresa_id/empresa/pessoa/cidade).
-- Consideramos o COD_MUN_DEST como sendo o IBGE da cidade do participante do conhecimento de transporte (conhec_transp.pessoa_id/pessoa/cidade).
-- Rotinas: pkb_monta_reg_D100 e pkb_armaz_reg_d100.
-- 2) Incluída a coluna QTD_DEST na view de Integração VW_CSF_OUTR_MOVTO_INTER_MERC, e na tabela OUTR_MOVTO_INTER_MERC. Registro K220.
-- Rotinas: pkb_monta_reg_k220 e pkb_armaz_reg_k100.
-- 3) Incluir informação do Registro E531-Informações adicionais dos ajustes da apuração do IPI ¿ Identificação dos documentos fiscais (01 E 55).
-- Rotinas: pkb_inicia_dados, fkg_qtde_linha_reg_e531, pkb_monta_reg_E500 e pkb_armaz_reg_e500.
--
-- Em 24/01/2018 - Karina de Paula
-- Redmine #38656 - Processos de integração de Conhecimento de Transporte - Modelo D100.
-- Incluido o modelo fiscal 67 para todas as rotinas que estão tratando o modelo 57-Conhecimento de Transporte Eletrônico
--
-- Em 22/01/2018 - Angela Inês.
-- Redmine #38740 - Correção nos processos de Informação Sobre Exportação - Recuperação dos registros.
-- Alterar os objetos que utilizam a tabela de Informação Sobre Exportação e considerar a DATA DE AVERBAÇÃO (DT_AVB) ao invés de considerar a DATA DA
-- DECLARAÇÃO (DT_DE), para recuperação dos registros.
-- Rotinas: pkb_monta_reg_1100 e pkb_monta_reg_1010.
--
-- Em 18/01/2018 - Angela Inês.
-- Redmine #38643 - Atualizar a geração do arquivo Sped Fiscal - Registro 0200/0210.
-- Alterar o tamanho da variável PERDA do registro 0210 de numérico (5,4), para numérico (7,4).
-- Rotina: declaração da variável PERDA no registro 0210.
--
-- Em 11/01/2018 - Angela Inês.
-- Redmine #38381 - Correção na geração do Sped Fiscal e Validação de Notas Fiscais.
-- Considerar no Sped Fiscal as notas fiscais denegadas, com situação de documento 6-Denegada (nota_fiscal.dm_st_proc=6), nas informações dos registros C100.
-- Rotina: pkb_monta_reg_0450 e pkb_monta_reg_C100.
--
-- Em 17/11/2017 - Angela Inês.
-- Redmine #36603 - Correção da montagem do registro 0200 e 0210 - Cadastro de Itens e Insumos.
-- Foram avaliados os processos que montam o registro K230 e K235, e constatamos que a montagem do registro 0200 e 0210 não estava correta, com relação
-- aos itens/produtos de insumos consumidos, com insumos consumidos de substituição.
-- Rotinas: pkb_monta_reg_k230 e pkb_monta_reg_k235.
--
-- Em 16/08/2017 - Angela Inês.
-- Redmine #33705 - Correção na geração dos Arquivos Sped Fiscal e EFD-Contribuições - Registro 0190.
-- Alterar o processo de geração do Registro 0190 - Unidades, para manter apenas uma Sigla de Unidade, sem repetir.
-- Rotinas: pkb_monta_reg_0190 e pkb_armaz_reg_0190.
--
-- Em 15/08/2017 - Angela Inês.
-- Redmine #33636 - Correção no Sped Fiscal e EFD-Contribuições - Registro 0190 - Unidade.
-- Alterar o índice utilizado para armazenar a Unidade de Medida para ser a Sigla da Unidade, pois armazenando pelo identificador da Unidade (unidade.id), a
-- sigla estava se repetindo conforme descrito na atividade, e além disso, será gerado no arquivo a Sigla com letras Maiúsculas.
-- Rotinas: pkb_monta_reg_0190 e pkb_armaz_reg_0190.
--
-- Em 16/05/2017 - Angela Inês.
-- Redmine #31157 - Alterar a geração do arquivo Sped Fiscal - registro C170.
-- Para montar os valores de ICMS (base, alíquota e imposto), no registro C170, zeramos os valores quando o CFOP for 1551.
-- Passar a não zerar os valores, e considerar os valores encontrados no Imposto ICMS.
-- Rotina: pkb_monta_reg_C100.
--
-- Em 12/05/2017 - Leandro Savenhago
-- Redmine #16547 - GERAÇÃO DO REGISTRO C197 ZERADO
-- Definido para não montar os registros C197 e D197 se o valor de imposto de ICMS for menor ou igual a zero
--
-- Em 18/04/2017 - Angela Inês.
-- Redmine #30304 - Alterar o processo que recupera os valores de base de cálculo e valor do imposto ICMS.
-- Para o registro C100, recuperar os valores de base de cálculo de ICMS e valor do imposto ICMS, da seguinte forma:
-- 1) Se o código ST de ICMS for "51-Diferimento. A exigência do preenchimento das informações do ICMS diferido fica à critério de cada UF"
-- (tabela=imp_itemnf/cod_st.cod_st), o valor da base de cálculo de ICMS for 0-zero (tabela=imp_itemnf.vl_base_calc), e o valor do imposto tributado for 0-zero
-- (tabela=imp_itemnf.vl_imp_trib), considerar 0-zero para os valores de base de cálculo e valor de imposto.
-- 2) Se o CFOP do item da nota fiscal for "1556, 3556, 5602, 5605, 5929, 6602 ou 6929" (tabela=item_nota_fiscal.cfop), considerar 0-zero para os valores de base
-- de cálculo e valor de imposto.
-- 3) Não atendendo aos itens 1 e 2, considerar os valores de base de cálculo e valor de imposto gerados no imposto (tabela=imp_itemnf/tipo_imposto.cd=1-icms).
-- Rotina: pkb_monta_reg_c100 - cursor c_nf - select que recupera os valores de base de cálculo e valor do imposto ICMS.
--
-- Em 24/03/2017 - Angela Inês.
-- Redmine #29727 - Alterar Sped Fiscal - Registro C111 - Número de Processo.
-- O registro C111 informa o Número do Processo que se encontra no campo CONTEUDO de informações adicionais. Nesse campo recuperamos 255 caracteres, porém o
-- arquivo do Sped considera 15 caracteres. Alterar a recuperação do campo para 15 caracteres.
-- Rotina: pkb_monta_reg_C100, cursor c_c111.
--
-- Em 18/01/2017 - Angela Inês.
-- Redmine #27456 - Montagem do arquivo Sped Fiscal - Registro C100 - VL_DOC e VL_MERC.
-- 1) De acordo com o documento de leiaute do Sped Fiscal Dezembro/2016:
-- C100/VL_DOC = soma C190/VL_OPR (nfregist_analit.vl_operacao)
-- C100/VL_MERC = C170/VL_ITEM (soma(item_nota_fiscal.vl_item_bruto)).
-- 2) Eliminar o processo que identifica se algum item da nota possui CFOP de isenção para montagem dos campos VL_DOC e VL_MERC do registro C100.
-- Rotina: pkb_monta_reg_C100.
--
-- Em 24/11/2016 - Fábio Tavares
-- Redmine #25723 - Feedback
-- Blocos: K280.
--
-- Em 20/10/2016 - Fábio Tavares
-- Redmine #24153 - Revisar o processo de geração do arquivo Sped Fiscal - Bloco K.
-- Blocos: K210, K210, K260, K265, K270, K275 e K280.
--
-- Em 13/10/2016 - Angela Inês.
-- Redmine #24369 - Corrigir a geração do Sped Fiscal - Registro C800 - Chave de Acesso.
-- O sped fiscal monta a chave de Acesso com o CNPJ do emitente, e deveria ser do destinatário. Corrigir para que o processo considere o CNPJ do emitente
-- do cupom fiscal para montar a chave de acesso a ser enviada no arquivo.
-- Rotina: pkb_monta_reg_C800.
--
-- Em 10/10/2016 - Angela Inês.
-- Redmine #24253 - Correção na montagem do arquivo Sped Fiscal - Registro C800 - Cupom Fiscal Eletrônico.
-- Na montagem do registro C800 - Cupom Fiscal Eletrônico, considerar para o campo CNPJ_CPF, o CNPJ do destinatário, sendo NULO, considerar o CPF do destinatário,
-- sendo NULO, considerar o CNPJ do emitente. Para o campo CHV_CFE considerar a mesma informação.
-- Rotina: pkb_monta_reg_C800.
--
-- Em 30/09/2016 - Angela Inês.
-- Redmine #23840 - 12894 - SPED Fiscal - sobe CNPJ e CPF incorreto.
-- Informar o CNPJ ou CPF do destinatário e não do emitente, no registro C800 - Cupons Fiscais Eletrônicos.
-- Rotina: pkb_monta_reg_c800.
--
-- Em 02/09/2016 - Angela Inês.
-- Redmine #23125 - Cálculo do CIAP - Patrimônio - Índice.
-- Alterar o tamanho do campo IND_PER_SAI das views VW_CSF_ICMS_ATPERM_CIAP e VW_CSF_OUTRO_CRED_CIAP; e das tabelas ICMS_ATPERM_CIAP e OUTRO_CRED_CIAP:
-- de numérico(15,4) para numérico (19,8).
--
-- Em 17/05/2016 - Angela Inês.
-- Redmine #19008 - Correção na geração do SPED Fiscal - Registro C800/C850.
-- Para o Registro C800 temos: VL_CFE (valor líquido) e VL_DESC.
-- Para o Registro C850 temos: VL_OPR (valor total líquido, que devemos considerar o valor do desconto: VL_ITEM_LIQ).
-- Rotina: pkb_monta_reg_C800.
--
-- Em 09/05/2016 - Rogério Silva.
-- Redmine #18352 - Integração de Informação Adicional com o Caractere PIPE e ENTER (\n)
--
-- Em 04/03/2016 - Angela Inês.
-- Redmine #16220 - Processo de geração do arquivo - registro C100.
-- Alterar o processo de geração do arquivo - registro C100, valores de Base de ICMS e valores de Imposto de ICMS, quando a Nota Fiscal estiver com
-- Valor de Base de ICMS e Imposto de ICMS no registro C190.
-- Rotina: pkb_monta_reg_C100.
--
-- Em 24/02/2016 - Angela Inês.
-- Redmine #15781 - Geração do Arquivo Sped Fiscal.
-- Quando o valor de serviço for nulo, deve ser enviado com 0(zero) - Registro D500 - VL_SERV.
-- Rotina: pkb_armaz_reg_d500.
--
-- Em 12/02/2016 - Angela Inês.
-- Redmine #15372 - Correção na Apuração de ICMS e Geração do SPED Fiscal - Registro E200.
-- Alterar a geração do arquivo Sped Fiscal, registro E200, considerando os registros de apuração independente do indicador de movimento (apuracao_icms_st.dm_ind_mov_st).
-- Rotina: pkb_monta_reg_e200.
--
-- Em 23/01/2016 - Leandro Savenhago.
-- Redmine #12575 - Sped-Fiscal - Atualização versão 010
--
-- Em 21/12/2015 - Angela Inês.
-- Redmine #13946 - Sped-Fiscal - Correção na data de entrada/saída.
-- Correção no processo de recuperar a data de entrada/saída das notas fiscais, identificando se a data de entrada/saída for maior que a data da escrituação,
-- considerar nulo, caso contrário considerar a data de entrada/saída mesmo que seja menor que a data de escrituração.
-- Rotina: pkb_monta_reg_C100.
--
-- Em 25/11/2015 - Angela Inês.
-- Redmine #13125 - Feedback 12383.
-- 1) Alterar a montagem do registro C800, campo COD_SIT, para o tamanho máximo com 0(zeros) à esquerda.
-- 2) Alterar a montagem dos registros C850 e C890, campo CST_ICMS, para o tamanho máximo com 0(zeros) à esquerda.
-- 3) Montar o registro C800 somente se o perfil da abertura for A.
-- 4) Montar o registro C860 somente se o perfil da abertura for B e C.
-- 5) Incluir o dígito verificador da chave através do Módulo 11.
-- Rotinas: pkb_monta_reg_C860, pkb_monta_reg_C800 e pkb_monta_bloco_c.
--
-- Em 23/11/2015 - Angela Inês.
-- Redmine #13061 - Erro na geração do sped fiscal.
-- O tamanho do campo de chave estava sendo montado incorretamente. Processo corrigido.
-- Rotina: pkb_monta_reg_C800.
--
-- Em 03/11/2015 - Angela Inês.
-- Redmine #12624 - ERRO COD_ITEM_COMP BLOCO K.
-- Montar o registro 0210 com os insumos dos registro 0200, quando os registros K235 e K255, não possuírem item de substituição.
-- Rotinas: pkb_monta_reg_k230 e pkb_monta_reg_k250.
--
-- Em 23/10/2015 - Angela Inês.
-- Redmine #12383 - Verificar/Alterar o processo de arquivo fiscal - Sped Fiscal.
-- Verificar/Alterar no processo de Sped Fiscal os registros que se referem ao Cupom Fiscal Eletrônico - modelo 59-CFe.
-- Rotinas: pkb_inicia_dados, pkb_monta_reg_9900, pkb_monta_reg_C990, pkb_monta_reg_C800, pkb_monta_reg_C860, pkb_monta_reg_C001,
-- pkb_armaz_reg_c800 e pkb_armaz_reg_c860.
--
-- Em 14/08/2015 - Angela Inês.
-- Redmine #10117 - Escrituração de documentos fiscais - Processos.
-- Inclusão do novo conceito de recuperação de data dos documentos fiscais para retorno dos registros.
--
-- Em 03-04/08/2015 - Angela Inês.
-- Redmine #10453 - Erro na geração do registro 1400 - EFD ICMS/IPI.
-- Agrupar o valor agregado por código de ibge da cidade/município e por item/produto.
-- O item a ser agrupado não é somente do cadastro, tabela ITEM, relacionar também com a tabela de ITEM/IPM. Agrupar pelo código do item.
-- Rotina: pkb_monta_reg_1400.
--
-- Em 30/07/2015 - Rogério Silva.
-- Redmine #10209 - Códigos de País - IBGE e SISCOMEX. Geração do Sped Fiscal.
--
-- Em 28/07/2015 - Angela Inês.
-- Redmine #10117 - Escrituração de documentos fiscais - Processos.
-- Inclusão do novo conceito de recuperação de data dos documentos fiscais para retorno dos registros.
--
-- Em 16/07/2015 - Rogério Silva.
-- Redmine #9979 - Duplicidade de Ocorrencia da Chave
--
-- Em 18/06/2015 - Angela Inês.
-- Redmine #9344 - Recuperação dos registros 1100 - Sped Fiscal.
-- Corrigir a recuperação dos registros 1100, considerando que uma das datas do registros atenda o período de abertura do arquivo.
-- Datas: Data da declaração (infor_exportacao.dt_de), Data do Registro de Exportação (infor_exportacao.dt_re),
-- Data do conhecimento de embarque (infor_exportacao.dt_chc) e Data da averbação da Declaração de exportação (infor_exportacao.dt_avb).
-- Rotina: pkb_monta_reg_1100.
--
-- Em 11/06/2015 - Rogério Silva.
-- Redmine #8226 - Processo de Registro de Log em Packages - LOG_GENERICO
--
-- Em 29/04/2015 - Rogério Silva.
-- Redmine #7917 - cod lista serviço no sped fiscal
-- Rotina: pkb_monta_reg_0200
--
-- Em 23/04/2015 - Rogério Silva.
-- Redmine #7494 - Erro validação código do serviço no SPED Fiscal.
-- Rotina: pkb_monta_reg_0200
--
-- Em 17/04/2015 - Angela Inês.
-- Redmine #7765 - Registro H010 - Inventário - Geração do Sped Fiscal.
-- Alterar o processo de geração do arquivo fiscal para recuperar a nova coluna VL_ITEM_IR na montagem do registro H010.
-- Rotina: pkb_monta_reg_h010.
--
-- Em 06/04/2015 - Angela Inês.
-- Redmine #5706 - Atualização Escrituração Fiscal Digital - EFD - Versão Ato Cotepe 108 e 109.
-- 01) Alteração na recuperação do tamanho do campo pessoa.nro: 10 caracteres. Registros 0005, 0100 e 0150.
-- 02) Correção na recuperação da CHV_CTE na montagem do registro D100.
-- 03) Alterada o tipo do campo 8-SubSérie para varchar2 do registro D500.
-- 04) Considerar para o Registro 0175 - Alteração da tabela de cadastro de participante, que a coluna NR_CAMPO, seja somente dos campos 03 a 13, exceto 07, a partir da versão 107-01/01/2014.
-- 05) Alteração de alguns títulos dos registros.
-- 06) Alterado o tamanho do campo para numérico(9): registro c405, coluna num_coo_fin.
-- 07) Alterado o tamanho do campo para numérico(9): registro c460, coluna num_doc.
-- 08) Alterado o tamanho do campo para numérico(4): registro d300, coluna sub.
-- 09) Alterado o tamanho do campo para numérico(9): registro d355, coluna num_coo_fin.
-- 10) Considerar a coluna cod_ant_item do registro 0200 até a versão 106, e anular o valor após essa versão.
-- 11) Gerar o registro C195 para as notas fiscais de modelo '04'.
--
-- Em 20/02/2015 - Angela Inês.
-- Redmine #6443 - Erro de validação do Sped Fiscal.
-- Ao gerar o arquivo de Sped Fiscal e fazer a validação está sendo exibido um erro referente a falta do registro 0450.
-- Correção: Gerar o registro C110 com informação do registro C115, somente se a nota fiscal for de saída e o modelo fiscal for ('01','04','1B').
-- Rotina: pkb_monta_reg_C100.
--
-- Em 19/02/2015 - Angela Inês.
-- Redmine #6468 - Correção na geração do Sped Fiscal - Cupom Fiscal - Registro C425.
-- Consistir os valores do registro C425 de acordo com o processo de integração: utilizar o parâmetro que indica qual a tributação a ser utilizada nos
-- totalizadores da redução Z (empresa.dm_ind_trib_tot_parc_redz).
-- Rotina: pkb_monta_reg_C400.
--
-- Em 09/02/2015 - Angela Inês.
-- Redmine #5706 - Atualização Escrituração Fiscal Digital - EFD - Versão Ato Cotepe 108 e 109.
--
-- Em 03/02/2015 - Rogério Silva.
-- Redmine #6015 - Sped EFD-Fiscal - Nota Fiscal - Quantidade do item.
--
-- Em 06/01/2015 - Angela Inês.
-- Redmine #5616 - Adequação dos objetos que utilizam dos novos conceitos de Mult-Org.
--
-- Em 30/12/2014 - Angela Inês.
-- Redmine #5610 - Erro na Validação do SPED Fiscal.
-- Rotina pkb_monta_reg_0150: limpar os espaços no campo IE.
-- Rotina pkb_monta_reg_0450: considerar o registro C113 na montagem do registro 0450 se não houver geração do registro C110 no registro 0450.
--
-- Em 09/12/2014 - Angela Inês.
-- Redmine #5476 - Erro na Validação do SPED Fiscal.
-- Ao validar o arquivo de Sped Fiscal está ocorrendo erro de validação devido a 2 cupons fiscais, relatório de erros em anexo.
-- Cupom fiscal com valores incorretos nos registros C420 e C425.
-- Correção: Deve ser considerado o CST '41' com Totalizador N1, e os outros CSTs com totalizador I1.
-- Rotina: pkb_monta_reg_c400.
--
-- Em 19/11/2014 - Angela Inês.
-- Redmine #5274 - Correção: Erro C110 Sped Fiscal (ADIDAS).
-- Correção: Alterar o registro C100 - enviar/montar o registro 0150 - Participantes somente se o modelo fiscal da NF não for 65-Consumidor Final.
-- Rotina: pkb_monta_reg_c100.
--
-- Em 07/11/2014 - Angela Inês.
-- Redmine #5082 - Erro na geração do Sped Fiscal SISMETAL 10/2014 (ACECO).
-- Problema: As notas fiscais estão com Imposto do Simples Nacional e o código de CST relacionado possui 3 caracteres.
-- Na montagem do arquivo do Sped Fiscal - Registro C190, o campo CST_ICMS é composto com os campos: Origem da Mercadoria || CST_ICMS, compondo 3 caracteres.
-- Para essas notas o CST de Simples Nacional possui 3 caracteres, e concatenado com a origem da mercadoria, esse campo fica com 4 caracteres, estourando o campo.
-- Correção: Verificar se a CST tiver 3 caracteres, considerar somente ela e não concatenar com o origem de mercadoria - Registros C170 e C190.
-- Correção: Desconsiderar o modelo fiscal 65 para montagem dos registros diferentes de C190.
-- Correção: Recuperar os valores do imposto 10-Simples Nacional para montagem do registro C100, na parte de totais do ICMS.
-- Correção: Na montagem do registro C100 considerar zero (0) para o valor da mercadoria quando for recuperado do item da nota fiscal.
-- Rotina: pkb_monta_reg_C100.
--
-- Em 21/10/2014 - Rogério Silva.
-- Redmine #4864 - Alterar tamanho máximo da coluna "NRO" do registro referente a Pessoa
-- Rotina: pkb_monta_reg_0150.
--
-- Em 03/10/2014 - Angela Inês.
-- Redmine #4626 - Adequações EFD ICMS/IPI - NFConsumidor-E - Modelo 65.
-- a) Registro C100: Não devem ser informados os campos COD_PART, VL_BC_ICMS_ST, VL_ICMS_ST, VL_IPI, VL_PIS, VL_COFINS, VL_PIS_ST e VL_COFINS_ST.
-- b) Registro C190: Campo 03 - CFOP: Informar CFOPs iniciados com 5.
-- c) Registro C190: Não devem ser informados os campos COD_PART, VL_BC_ICMS_ST, VL_ICMS_ST, VL_IPI, VL_PIS, VL_COFINS, VL_PIS_ST e VL_COFINS_ST.
-- d) Não devem ser informados os outros tipos de registros.
-- Rotina: pkb_monta_reg_C100.
--
-- Em 21/08/2014 - Angela Inês.
-- Redmine #3788 - Erro no código de participante e Valores de IPI - C190 e E520 - Aline/Adidas.
-- Rotina: pkb_monta_reg_C100: voltar a recuperar os valores de ipi com exceção da CST 49 e 99, e das CFOPs: (1551, 1556, 5929, 6929, 3551, 3949, 5602, 6602, 3556).
-- Rotina: pkb_monta_reg_C100: somar ao valor de outras despesas, os valores de ipi com CST 49 e 99.
--
-- Em 07/08/2014 - Angela Inês.
-- Redmine #3712 - Correção nos processos - Eliminar o comando dbms_output.put_line.
--
-- Em 17/07/2014 - Angela Inês.
-- Redmine #3526 - Feedback 2049 - Funcionalidade #2037: Bloco K Controle da Produção e do Estoque (Sped Fiscal ICMS/IPI).
-- No arquivo do sped fiscal na quantidade está vindo a quantidade errada. Foi colocado 1000 na tela e no arquivo está saindo 1000000,000.
-- 1) Correção: as quantidades relacionadas aos registros do bloco K não devem ser multiplicadas por 1000.
-- Rotinas: pkb_monta_reg_k200, pkb_monta_reg_k220, pkb_monta_reg_k230, pkb_monta_reg_k235, pkb_monta_reg_k250 e pkb_monta_reg_k255.
-- 2) Correção: no registro totalizador do bloco K100 estava sendo considerado K001.
-- Rotina: pkb_monta_reg_9900.
--
-- Em 17/07/2014 - Angela Inês.
-- Redmine #3514 - Divergência no Registro C100 - Montagem do valor de IPI no Sped ICMS.
-- Registro C100 da EFD ICMS/IPI sem informação de IPI. Informação existe na tabela NOTA_FISCAL_TOTAL, IMP_ITEMNF e NFREGIST_ANILIT.
-- Correção: Voltamos o processo eliminando o select que recupera os valores de IPI com relação a CST 49 e 99 que zeram os valores de IPI, referente ao redmine #1807.
-- Rotina: pkb_monta_reg_C100.
--
-- Em 08/05/2014 - Angela Inês.
-- Redmine #2896 - Erro geração do EFD ICMS e IPI - Ao validar o arquivo do PVA o mesmo apresenta erro de contagem de linhas.
-- Ao montar o registro 0220 - Unidade de Conversão, o indexador utilizado é o identificador do item (item.id).
-- Esse registro é "filho" do registro 0200 - Itens dos Produtos, e o indexador utilizado é o código do item.
-- Quando existem itens com o mesmo código mas de empresas diferentes, o registro 0200 é montado corretamente, mas o 0220 não, devido aos indexadores.
-- A rotina foi alterada recuperando o código do item já gerado no registro 0200 e utilizando o identificador como índice.
-- Rotina: pkb_monta_reg_0220.
--
-- Em 23/04/2014 - Angela Inês.
-- Redmine #2704 - Suporte - Aline/Adidas. Sped Fiscal: erro no registro C110. Alterações:
-- 1) Considerar para os registros 0450 e C113, as notas fiscais com situação 4-Autorizada, 7-Cancelada e 8-Inutilizada, com modelos fiscais 01-Nota Fiscal,
-- 04-Nota Fiscal de Produtor, 1B-Nota Fiscal Avulsa e 55-Nota Fiscal Eletrônica, e que possua dados em nota fiscal referenciada (nota_fiscal_referen).
-- 2) Considerar para os registros 0450 e C110, as notas fiscais com situação 4-Autorizada, 7-Cancelada e 8-Inutilizada, com modelos fiscais 01-Nota Fiscal,
-- 04-Nota Fiscal de Produtor, 1B-Nota Fiscal Avulsa e 55-Nota Fiscal Eletrônica, e que possua dados em informações adicionais do tipo contribuinte
-- (nfinfor_adic.dm_tipo = 0).
-- 3) Considerar para os registros 0450 e C110, as notas fiscais com situação 4-Autorizada, 7-Cancelada e 8-Inutilizada, com modelos fiscais 01-Nota Fiscal,
-- 04-Nota Fiscal de Produtor e 1B-Nota Fiscal Avulsa, de emissão própria, e com situação do documento 08-Documento Fiscal emitido com base em Regime Especial ou
-- Norma Específica.
-- 4) Ao gerar o registro C113 não é necessário executar a chamada da montagem do registro 0450, pois a mesma está relacionada ao registro C110.
-- Rotinas: pkb_monta_reg_0450 e pkb_monta_reg_C100.
--
-- Em 09/04/2014 - Angela Inês.
-- Redmine #2505 - Alteração da Geração do arquivo do Sped ICMS/IPI. Implementar a geração do registro 1900.
--
-- Em 08/04/2014 - Angela Inês.
-- Redmine #2622 - Alteração na geração do arquivo - Bloco K.
-- Gerar os dados do bloco K desde que a data inicial da abertura do arquivo seja a partir de 01/01/2015.
-- Rotina: pkb_monta_array_efd.
--
-- Em 14/03/2014 - Angela Inês.
-- Redmine #2049 - Geração do Sped Fiscal ICMS/IPI - Inclusão do Bloco K.
--
-- Em 14/03/2014 - Angela Inês.
-- Redmine #2297 - Alterar Arquivo Sped/Fiscal - Karina/Aceco.
-- Para notas fiscais de modelo 55, emissão de terceiro e item de serviço que não possui imposto ICMS, alterar:
-- 1) Registro C170: incluir o registro do imposto ICMS com cst 40 e valores zerados.
-- 2) Registro C190: incluir o registro com origem = 0, cst = 40, valor do item, e impostos zerados.
-- Rotina: pkb_monta_reg_C100.
--
-- Em 22/01/2014 - Angela Inês.
-- Redmine #1807 - Erro no PVA.
-- 1) "A soma dos valores de IPI do registro C190 deverá ser igual ao valor informado no campo valor total do IPI (VL_IPI) dos registros C100."
-- Incluímos no processo "Gambiarra" já existente para ICMS o mesmo para IPI.
-- O arquivo ficou com advertência, mas foi liberado no PVA, e será preciso rever o processo para correção dessa situação.
-- 2) "Não informar código da informação complementar, se não referenciado em pelo menos um dos demais blocos."
-- O registro 0450 está sendo gerado sem que existam registros C110 de documentos fiscais com modelo fiscal "01/1B/04", situação 08 e emitente emissão própria.
-- Foi alterado para que gere o registro 0450 somente se houver registros C110 e C113.
-- Rotina: pkb_monta_reg_C100.
--
-- Em 19/11/2013 - Angela Inês.
-- Considerar o contador que esteja cadastrado como pessoa jurídica ou pessoa física.
-- Rotina: pkb_monta_reg_0100.
--
-- Em 31/10/2013 - Angela Inês.
-- Redmine #1239 - Sped de ICMS ¿ Está exportando o E210 sem movimento. Só pode exportar com movimento.
-- Rotina: pkb_armaz_reg_e200.
--
-- Em 20/09/2013 - Angela Inês.
-- Redmine #668 - Exportação do Sped ICMS/IPI Ficha HD 66864.
-- Alterar a recuperação dos valores de ICMS-ST somente se houver movimentação (apuracao_icms_st.dm_ind_mov_st = 1: 0-Sem operações com ST, 1-Com operações de ST).
-- Rotina: pkb_monta_reg_E200.
--
-- Em 17/09/2013 - Angela Inês.
-- Redmine #702 - Suporte - Aline/Sermatec.
-- Tamanho do campo NUM_DOC_IMP do registro C120: OPERAÇÕES DE IMPORTAÇÃO (CÓDIGO 01), atendia até 10 caracteres.
-- O processo foi alterado devido ao novo layout do governo - tamanho varchar2(12).
--
-- Em 21/08/2013 - Angela Inês.
-- Redmine #573 - Correção na geração dos registros C420 e C425, com relação ao código do totalizador: 00T1700, considerar 01T1700.
-- Rotina: pkb_monta_reg_C400.
--
-- Em 19/06/2013 - Angela Inês.
-- RC #293 - Tratar versão Layout do EFD icms/IPI - Ficha HD 66710.
-- Favor realizar os devidos tratamentos para que os arquivos do Sped ICMS/IPI sejam exportados conforme o layout aceito no período.
-- Isso porque já está existindo clientes que devem restituir ou gerar arquivos em período antigos e hoje o Compliance não trata a exportação da estrutura do
-- layout desses registros e campos conforme o período e versão. Dessa forma, o consultor ou usuário devem ficar dando manutenção manualmente para poder
-- validar os arquivos. Em anexo pagina 11 a 13 do manual da sped com as alterações por período.
-- Rotinas: pkb_monta_bloco_1, pkb_monta_bloco_g, pkb_monta_reg_c100, pkb_armaz_reg_h005, pkb_armaz_reg_e200, pkb_armaz_reg_e100 e pkb_armaz_reg_c100.
--
-- Em 11/04/2013 - Angela Inês.
-- Correção no registro C420 - Considerar a alteração no código do totalizador para 01 somente se o código possuir S ou T e ainda possuir 00 antes do código S ou T.
-- Rotina: pkb_monta_reg_C400.
--
-- Em 03/04/2013 - Angela Inês.
-- Ficha HD 66304 - Ao gerar o registro C113 relacionado com o registro 0450, está considerando somente as notas com dm_ind_emit = 1.
-- No processo antigo essa condição não existia. Rotina: pkb_monta_reg_0450.
-- Verificar a rotina pkb_monta_reg_C100 pois essa gera o registro C113 e 0450 de acordo com algumas condições.
-- Utilizar essas condições para montagem do registro 0450.
-- Rotina: pkb_monta_reg_0450
--
-- Em 21/03/2013 - Angela Inês.
-- Ficha HD 66483 - Nas gerações dos arquivos do sped icms/ipi e pis/cofins:
-- Os registros 0500 e 0600 (centro de custo e plano de conta) devem ser revistos.
-- Deve ser armazenado como índice do array o código (CD) de cada um e não o identificador (ID), para que os dados não sejam repetidos, porém temos o
-- problema da quantidade de dígitos do código (CD) para armazenar com índice do array que deve ter no máximo 9 dígitos, por isso colocamos o identificador (ID).
-- Rotinas: pkb_monta_reg_0500 e pkb_monta_reg_0600.
--
-- Em 26/02/2013 - Angela Inês.
-- Atualizar a montagem do bloco C420 (Leandro/Islaine). Rotina: pkb_monta_reg_C400.
--
-- Em 23/01/2013 - Angela Inês.
-- Ficha HD 65546 - Correção nos blocos de geração c400 (c420 e c460) - Código totalizador.
-- Rotina: pkb_monta_reg_C400.
--
-- Em 16/01/2013 - Angela Inês.
-- Ficha HD 65546 - Correção nos blocos de geração c400 (c420 e c460) - Código totalizador.
-- Rotina: pkb_monta_reg_C400.
--
-- Em 26/12/2012 - Angela Inês.
-- Ficha HD 65155 - Incluir situção "Em Geração" para o Sped ICMS/IPI enquanto o mesmo estiver sendo gerado.
--
-- Em 22/11/2012 - Angela Inês.
-- Ficha HD 64702 - Erro na geração do registro 0500.
-- 1) Considerar o código da conta como índice do processo.
-- 2) Considerar o código do centro de custo como índice do processo.
-- Rotina: pkb_monta_reg_0500 e pkb_monta_reg_0600.
--
-- Em 16/11/2012 - Angela Inês.
-- Ficha HD 64237 - Islaine - Cliente gera os cupons fiscais com o cot_tot tudo maiúsculo no registro C420.
-- Porém, dentro da nossa procedure o cod_tot tá fixo em um único formado.
-- Rotina: pkb_monta_reg_C400.
--
-- Em 01/11/2012 - Angela Inês.
-- Ficha HD 64307 - Alterar geração do arquivo texto - sped icms - Colocar NVL para os valores dos impostos ICMS-ST e IPI.
--
-- Em 27/09/2012 - Angela Inês.
-- Considerar versão de layout maior/igual 1.04 (104) para informar o registro C110.
-- Rotina: pkb_monta_reg_C100.
--
-- Em 13/09/2012 - Angela Inês.
-- Atualização do indexador para o registro 1391 (j), pois o mesmo não estava sendo atualizado.
--
-- Em 06/09/2012 - Angela Inês.
-- Na montagem do registro 1391, o código de registro deve estar associado ao referido registro, estava sendo enviado o registro 1210.
--
-- Em 30/08/2012 - Angela Inês.
-- Na montagem do regitro 1990 somar as linhas dos registros 1390 e 1391.
--
-- Em 08/05/2012 - Angela Inês.
-- Na montagem do registro C100/C110, eliminar caracteres impróprios.
-- Em 25/04/2012 - Angela Inês.
-- Considerar para o registro C170 o imposto SN - Simples Nacional, junto com o imposto ICMS.
--
-------------------------------------------------------------------------------------------------------

-- BLOCO 0: ABERTURA, IDENTIFICAÇÃO E REFERÊNCIAS

--| REGISTRO 0000: ABERTURA DO ARQUIVO DIGITAL E IDENTIFICAÇÃO DA ENTIDADE
   -- Nível hierárquico - 0
   -- Ocorrência - um por arquivo
   type tab_reg_0000 is record ( reg         varchar2(4)
                               , cod_ver     varchar2(3)
                               , cod_fin     number(1)
                               , dt_ini      date
                               , dt_fin      date
                               , nome        varchar2(100)
                               , cnpj        varchar2(14)
                               , cpf         varchar2(11)
                               , uf          varchar2(2)
                               , ie          varchar2(14)
                               , cod_mun     number(7)
                               , im          varchar2(15)
                               , suframa     varchar2(9)
                               , ind_perfil  varchar2(1)
                               , ind_ativ    number(1) );
--
   type t_tab_reg_0000 is table of tab_reg_0000 index by binary_integer;
   vt_tab_reg_0000 t_tab_reg_0000;
--
--| REGISTRO 0001: ABERTURA DO BLOCO 0
   -- Nível hierárquico - 1
   -- Ocorrência ¿ um por arquivo
   type tab_reg_0001 is record ( reg      varchar2(4)
                               , ind_mov  number(1) );
--
   type t_tab_reg_0001 is table of tab_reg_0001 index by binary_integer;
   vt_tab_reg_0001 t_tab_reg_0001;
--
--| REGISTRO 0002: ABERTURA DO BLOCO 0
   -- Nível hierárquico - 1
   -- Ocorrência ¿ um por arquivo
   type tab_reg_0002 is record ( reg      varchar2(4)
                               , contrb   varchar2(2) );
--
   type t_tab_reg_0002 is table of tab_reg_0002 index by binary_integer;
   vt_tab_reg_0002 t_tab_reg_0002;
   --
--| REGISTRO 0005: DADOS COMPLEMENTARES DA ENTIDADE
   -- Nível hierárquico - 2
   -- Ocorrência ¿ um por arquivo
   type tab_reg_0005 is record ( reg        varchar2(4)
                               , fantasia   varchar2(60)
                               , cep        varchar2(8)
                               , lograd     varchar2(60)
                               , num        varchar2(10)
                               , compl      varchar2(60)
                               , bairro     varchar2(60)
                               , fone       varchar2(11)
                               , fax        varchar2(11)
                               , email      varchar2(60)
                               );
--
   type t_tab_reg_0005 is table of tab_reg_0005 index by binary_integer;
   vt_tab_reg_0005 t_tab_reg_0005;
--
--| REGISTRO 0015: DADOS DO CONTRIBUINTE SUBSTITUTO
   -- Nível hierárquico - 2
   -- Ocorrência ¿ vários por arquivo
   type tab_reg_0015 is record ( reg     varchar2(4)
                               , uf_st   varchar2(2)
                               , ie_st   varchar2(14) );
--
   type t_tab_reg_0015 is table of tab_reg_0015 index by binary_integer;
   vt_tab_reg_0015 t_tab_reg_0015;
--
--| REGISTRO 0100: DADOS DO CONTABILISTA
   -- Nível hierárquico - 2
   -- Ocorrência ¿ um por arquivo
   type tab_reg_0100 is record ( reg        varchar2(4)
                               , nome       varchar2(100)
                               , cpf        varchar2(11)
                               , crc        varchar2(15)
                               , cnpj       varchar2(14)
                               , cep        varchar2(8)
                               , lograd     varchar2(60)
                               , num        varchar2(10)
                               , compl      varchar2(60)
                               , bairro     varchar2(60)
                               , fone       varchar2(11)
                               , fax        varchar2(11)
                               , email      varchar2(60)
                               , cod_mun    number(7) );
--
   type t_tab_reg_0100 is table of tab_reg_0100 index by binary_integer;
   vt_tab_reg_0100 t_tab_reg_0100;
--
--| REGISTRO 0150: TABELA DE CADASTRO DO PARTICIPANTE
   -- Nível hierárquico - 2
   -- Ocorrência ¿vários por arquivo
   type tab_reg_0150 is record ( reg        varchar2(4)
                               , pessoa_id  number
                               , cod_part   varchar2(60)
                               , nome       varchar2(100)
                               , cod_pais   number(5)
                               , cnpj       varchar2(14)
                               , cpf        varchar2(11)
                               , ie         varchar2(14)
                               , cod_mun    number(7)
                               , suframa    varchar2(9)
                               , lograd     varchar2(60)
                               , num        varchar2(10)
                               , compl      varchar2(60)
                               , bairro     varchar2(60) );
--
   type t_tab_reg_0150 is table of tab_reg_0150 index by binary_integer;
   vt_tab_reg_0150 t_tab_reg_0150;
--
--| REGISTRO 0175: ALTERAÇÃO DA TABELA DE CADASTRO DE PARTICIPANTE
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_0175 is record ( reg        varchar2(4)
                               , dt_alt     date
                               , nr_campo   varchar2(2)
                               , cont_ant   varchar2(100) );
--
   type t_tab_reg_0175 is table of tab_reg_0175 index by binary_integer;
   type t_bi_tab_reg_0175 is table of t_tab_reg_0175 index by binary_integer;
   vt_bi_tab_reg_0175 t_bi_tab_reg_0175;
--
--| REGISTRO 0190: IDENTIFICAÇÃO DAS UNIDADES DE MEDIDA
   -- Nível hierárquico: 2
   -- Ocorrência: vários por arquivo
   type tab_reg_0190 is record ( reg        varchar2(4)
                               , unidade_id number
                               , unid       varchar2(6)
                               , descr      varchar2(255) );
--
   --type t_tab_reg_0190 is table of tab_reg_0190 index by binary_integer; -- foi trocado o índice numérico pelo caracter, utilizando a sigla da unidade
   type t_tab_reg_0190 is table of tab_reg_0190 index by varchar2(6);      -- pois estava sendo enviado mais de um registro com a mesma sigla
   vt_tab_reg_0190 t_tab_reg_0190;
--
--| REGISTRO 0200: TABELA DE IDENTIFICAÇÃO DO ITEM (PRODUTO E SERVIÇOS)
   -- Nível hierárquico - 2
   -- Ocorrência - vários (por arquivo)
   type tab_reg_0200 is record ( reg            varchar2(4)
                               , item_id        number
                               , cod_item       varchar2(60)
                               , descr_item     varchar2(255)
                               , cod_barra      varchar2(255)
                               , cod_ant_item   varchar2(60)
                               , unid_inv       varchar2(6)
                               , tipo_item      varchar2(2)
                               , cod_ncm        varchar2(8)
                               , ex_ipi         varchar2(3)
                               , cod_gen        varchar2(2)
                               , cod_lst        varchar2(5)
                               , aliq_icms      number(6,2)
                               , cest           varchar2(7)
                               );
--
   type t_tab_reg_0200 is table of tab_reg_0200 index by binary_integer;
   vt_tab_reg_0200 t_tab_reg_0200;
--
--| REGISTRO 0205: ALTERAÇÃO DO ITEM
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_0205 is record ( reg              varchar2(4)
                               , descr_ant_item   varchar2(255)
                               , dt_ini           date
                               , dt_fim           date
                               , cod_ant_item     varchar2(60) );
--
   type t_tab_reg_0205 is table of tab_reg_0205 index by binary_integer;
   type t_bi_tab_reg_0205 is table of t_tab_reg_0205 index by binary_integer;
   vt_bi_tab_reg_0205 t_bi_tab_reg_0205;
--
--| REGISTRO 0206: CÓDIGO DE PRODUTO CONFORME TABELA PUBLICADA PELA ANP (COMBUSTÍVEIS)
   -- Nível hierárquico - 3
   -- Ocorrência - 1:1
   type tab_reg_0206 is record ( reg        varchar2(4)
                               , cod_comb   varchar2(255) );
--
   type t_tab_reg_0206 is table of tab_reg_0206 index by binary_integer;
   type t_bi_tab_reg_0206 is table of t_tab_reg_0206 index by binary_integer;
   vt_bi_tab_reg_0206 t_bi_tab_reg_0206;
--
--| REGISTRO 0210: CONSUMO ESPECÍFICO PADRONIZADO
   -- Nível hierárquico - 3
   -- Ocorrência - 1:1
   type tab_reg_0210 is record ( reg            varchar2(4)
                               , cod_item_comp  varchar2(60)
                               , qtd_comp       number(17,6)
                               , perda          number(7,4) );
--
   type t_tab_reg_0210 is table of tab_reg_0210 index by binary_integer;
   type t_bi_tab_reg_0210 is table of t_tab_reg_0210 index by binary_integer;
   vt_bi_tab_reg_0210 t_bi_tab_reg_0210;
--
--| REGISTRO 0220: FATORES DE CONVERSÃO DE UNIDADES
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_0220 is record ( reg        varchar2(4)
                               , unid_conv  varchar2(6)
                               , fat_conv   number(13,6) );
--
   type t_tab_reg_0220 is table of tab_reg_0220 index by binary_integer;
   type t_bi_tab_reg_0220 is table of t_tab_reg_0220 index by binary_integer;
   vt_bi_tab_reg_0220 t_bi_tab_reg_0220;
--
--| REGISTRO 0300: CADASTRO DE BENS OU COMPONENTES DO ATIVO IMOBILIZADO
   -- Nível hierárquico - 2
   -- Ocorrência ¿ Vários (por arquivo)
   type tab_reg_0300 is record ( reg             varchar2(4)
                               , bemativoimob_id number
                               , cod_ind_bem     varchar2(60)
                               , ident_merc      varchar2(1)
                               , descr_item      varchar2(255)
                               , cod_prnc        varchar2(60)
                               , cod_cta         varchar2(60)
                               , nr_parc         number(3) );
--
   type t_tab_reg_0300 is table of tab_reg_0300 index by binary_integer;
   vt_tab_reg_0300 t_tab_reg_0300;
--
--| REGISTRO 0305 ¿ INFORMAÇÃO SOBRE A UTILIZAÇÃO DO BEM
-- Nível hierárquico - 3
-- Ocorrência ¿ 1:1
   type tab_reg_0305 is record ( reg           varchar2(4)
                               , cod_ccus      varchar2(60)
                               , func          varchar2(255)
                               , vida_util     number(3) );
--
   type t_tab_reg_0305 is table of tab_reg_0305 index by binary_integer;
   type t_bi_tab_reg_0305 is table of t_tab_reg_0305 index by binary_integer;
   vt_bi_tab_reg_0305 t_bi_tab_reg_0305;
--
--| REGISTRO 0400: TABELA DE NATUREZA DA OPERAÇÃO/PRESTAÇÃO
   -- Nível hierárquico - 2
   -- Ocorrência ¿ vários por arquivo
   type tab_reg_0400 is record ( reg         varchar2(4)
                               , natoper_id  number
                               , cod_nat     varchar2(10)
                               , descr_nat   varchar2(255) );
--
   type t_tab_reg_0400 is table of tab_reg_0400 index by binary_integer;
   vt_tab_reg_0400 t_tab_reg_0400;
--
--| REGISTRO 0450: TABELA DE INFORMAÇÃO COMPLEMENTAR DO DOCUMENTO FISCAL
   -- Nível hierárquico - 2
   -- Ocorrência ¿vários por arquivo
   type tab_reg_0450 is record ( reg       varchar2(4)
                               , cod_inf   varchar2(6)
                               , txt       varchar2(255) );
--
   type t_tab_reg_0450 is table of tab_reg_0450 index by binary_integer;
   vt_tab_reg_0450 t_tab_reg_0450;
--
--| REGISTRO 0460: TABELA DE OBSERVAÇÕES DO LANÇAMENTO FISCAL
   -- Nível hierárquico - 2
   -- Ocorrência ¿vários por arquivo
   type tab_reg_0460 is record ( reg                varchar2(4)
                               , obslanctofiscal_id number
                               , cod_obs            varchar2(6)
                               , txt                varchar2(255) );
--
   type t_tab_reg_0460 is table of tab_reg_0460 index by binary_integer;
   vt_tab_reg_0460 t_tab_reg_0460;
--
--| REGISTRO 0500: PLANO DE CONTAS CONTÁBEIS
   -- Nível hierárquico - 2
   -- Ocorrência - vários (por arquivo)
   type tab_reg_0500 is record ( reg            varchar2(4)
                               , planoconta_id number
                               , dt_alt        date
                               , cod_nat_cc    varchar2(2)
                               , ind_cta       varchar2(1)
                               , nivel         number(5)
                               , cod_cta       varchar2(60)
                               , nome_cta      varchar2(60) );
--
   type t_tab_reg_0500 is table of tab_reg_0500 index by binary_integer;
   vt_tab_reg_0500 t_tab_reg_0500;
--
--| REGISTRO 0600: CENTRO DE CUSTOS
   -- Nível hierárquico - 2
   -- Ocorrência - vários (por arquivo)
   type tab_reg_0600 is record ( reg            varchar2(4)
                               , centrocusto_id number
                               , dt_alt         date
                               , cod_ccus       varchar2(60)
                               , ccus           varchar2(60) );
--
   type t_tab_reg_0600 is table of tab_reg_0600 index by binary_integer;
   vt_tab_reg_0600 t_tab_reg_0600;
--
--| REGISTRO 0990: ENCERRAMENTO DO BLOCO 0
   -- Nível hierárquico - 1
   -- Ocorrência ¿ um por arquivo
   type tab_reg_0990 is record ( reg         varchar2(4)
                               , qtd_lin_0   number );
--
   type t_tab_reg_0990 is table of tab_reg_0990 index by binary_integer;
   vt_tab_reg_0990 t_tab_reg_0990;
--

-- BLOCO B: BLOCO B: APURAÇÃO DO ISS (SEFAZ DF)
--
--| REGISTRO B001: ABERTURA DO BLOCO B
   -- Nível hierárquico - 1
   -- Ocorrência - um por arquivo
   type tab_reg_b001 is record ( reg      varchar2(4)
                               , ind_mov  number(1) );
--
   type t_tab_reg_b001 is table of tab_reg_b001 index by binary_integer;
   vt_tab_reg_b001 t_tab_reg_b001;

--| REGISTRO B020: B020: NOTA FISCAL (CÓDIGO 01), NOTA FISCAL DE SERVIÇOS (CÓDIGO 03), NOTA FISCAL DE SERVIÇOS AVULSA (CÓDIGO 3B), NOTA FISCAL DE PRODUTOR
-- (CÓDIGO 04), CONHECIMENTO DE TRANSPORTE RODOVIÁRIO DE CARGAS (CÓDIGO 08), NF-e (CÓDIGO 55) e NFC-e (CÓDIGO 65).
   -- Nível hierárquico - 2
   -- Ocorrência ¿ vários por arquivo
   type tab_reg_b020 is record ( reg             varchar2(4)
                               , ind_oper        number(1)
                               , ind_emit        number(1)
                               , cod_part        varchar2(60)
                               , cod_mod         varchar2(2)
                               , cod_sit         varchar2(2)
                               , ser             varchar2(3)
                               , num_doc         number(9)
                               , chv_nfe         varchar2(44)
                               , dt_doc          date
                               , cod_mun_serv    number(7)
                               , VL_CONT         number(15,2)
                               , VL_MAT_TERC     number(15,2)
                               , VL_SUB          number(15,2)
                               , VL_ISNT_ISS     number(15,2)
                               , VL_DED_BC       number(15,2)
                               , VL_BC_ISS       number(15,2)
                               , VL_BC_ISS_RT    number(15,2)
                               , VL_ISS_RT       number(15,2)
                               , VL_ISS          number(15,2)
                               , COD_INF_OBS     varchar2(60) );
--
   type t_tab_reg_b020 is table of tab_reg_b020 index by binary_integer;
   vt_tab_reg_b020 t_tab_reg_b020;
--
--| B025 - DETALHAMENTO POR COMBINAÇÃO DE ALÍQUOTA E ITEM DA LISTA DE SERVIÇOS DA LC 116/2003)
   type tab_reg_b025 is record ( reg            varchar2(4)
                               , VL_CONT_P      number(15,2)
                               , VL_BC_ISS_P    number(15,2)
                               , ALIQ_ISS       number(15,2)
                               , VL_ISS_P       number(15,2)
                               , VL_ISNT_ISS_P  number(15,2)
                               , COD_SERV       varchar2(4));
--
   type t_tab_reg_b025 is table of tab_reg_b025 index by binary_integer;
   type t_bi_tab_reg_b025 is table of t_tab_reg_b025 index by binary_integer;
   vt_bi_tab_reg_b025 t_bi_tab_reg_b025;

--| B420 - TOTALIZAÇÃO DOS VALORES DE SERVIÇOS PRESTADOS POR COMBINAÇÃO DE ALÍQUOTA E ITEM DA LISTA DE SERVIÇOS DA LC 116/2003
   type tab_reg_b420 is record ( reg            varchar2(4)
                               , VL_CONT_P      number(15,2)
                               , VL_BC_ISS_P    number(15,2)
                               , ALIQ_ISS       number(15,2)
                               , VL_ISS_P       number(15,2)
                               , VL_ISNT_ISS_P  number(15,2)
                               , COD_SERV       varchar2(4));
   type t_tab_reg_b420 is table of tab_reg_b420 index by binary_integer;
   vt_tab_reg_b420  t_tab_reg_b420 ;

--| B440 - TOTALIZAÇÃO DOS VALORES RETIDOS
   type tab_reg_b440 is record ( reg             varchar2(4)
                               , ind_oper        number(1)
                               , cod_part        varchar2(60)
                               , VL_CONT_RT      number(15,2)
                               , VL_BC_ISS_RT    number(15,2)
                               , VL_ISS_RT       number(15,2));
   type t_tab_reg_b440 is table of tab_reg_b440 index by binary_integer;
   vt_tab_reg_b440 t_tab_reg_b440;

--| B460 - DEDUÇÕES DO ISS
   type tab_reg_b460 is record ( REG          varchar2(4)
                                ,IND_DED      NUMBER(1)
                                ,VL_DED       NUMBER(15,2)
                                ,NUM_PROC     VARCHAR2(50)
                                ,DM_IND_PROC  NUMBER(1)
                                ,PROC          VARCHAR2(100)
                                ,COD_INF_OBS  VARCHAR2(60)
                                ,DM_IND_OBR    NUMBER(1));                               
   type t_tab_reg_b460 is table of tab_reg_b460 index by binary_integer;  
   vt_tab_reg_b460 t_tab_reg_b460;   

--| B470 - APURAÇÃO DO ISS
   type tab_reg_b470 is record ( REG              varchar2(4)
                                ,VL_CONT          number(15,2)
                                ,VL_MAT_TERC      number(15,2)
                                ,VL_MAT_PROP      number(15,2)
                                ,VL_SUB           number(15,2)
                                ,VL_ISNT          number(15,2)
                                ,VL_DED_BC        number(15,2)
                                ,VL_BC_ISS        number(15,2)
                                ,VL_BC_ISS_RT     number(15,2)
                                ,VL_ISS           number(15,2)
                                ,VL_ISS_RT        number(15,2)
                                ,VL_DED           number(15,2)
                                ,VL_ISS_REC       number(15,2)
                                ,VL_ISS_ST        number(15,2)
                                ,VL_ISS_REC_UNI   number(15,2));
   type t_tab_reg_b470 is table of tab_reg_b470 index by binary_integer;
   vt_tab_reg_b470 t_tab_reg_b470;

--| REGISTRO B990: ENCERRAMENTO DO BLOCO B
   -- Nível hierárquico - 1
   -- Ocorrência ¿ um por arquivo
   type tab_reg_b990 is record ( reg        varchar2(4)
                               , qtd_lin_b  number );
--
   type t_tab_reg_b990 is table of tab_reg_b990 index by binary_integer;
   vt_tab_reg_b990 t_tab_reg_b990;

-- BLOCO C: DOCUMENTOS FISCAIS I - MERCADORIAS (ICMS/IPI)
--
--| REGISTRO C001: ABERTURA DO BLOCO C
   -- Nível hierárquico - 1
   -- Ocorrência - um por arquivo
   type tab_reg_c001 is record ( reg      varchar2(4)
                               , ind_mov  number(1) );
--
   type t_tab_reg_c001 is table of tab_reg_c001 index by binary_integer;
   vt_tab_reg_c001 t_tab_reg_c001;
--
--| REGISTRO C100: NOTA FISCAL (CÓDIGO 01), NOTA FISCAL AVULSA (CÓDIGO 1B), NOTA FISCAL DE PRODUTOR (CÓDIGO 04) E NFE (CÓDIGO 55).
   -- Nível hierárquico - 2
   -- Ocorrência ¿ vários por arquivo
   type tab_reg_c100 is record ( reg            varchar2(4)
                               , ind_oper       number(1)
                               , ind_emit       number(1)
                               , cod_part       varchar2(60)
                               , cod_mod        varchar2(2)
                               , cod_sit        varchar2(2)
                               , ser            varchar2(3)
                               , num_doc        number(9)
                               , chv_nfe        varchar2(44)
                               , dt_doc         date
                               , dt_e_s         date
                               , vl_doc         number(15,2)
                               , ind_pgto       number(1)
                               , vl_desc        number(15,2)
                               , vl_abat_nt     number(15,2)
                               , vl_merc        number(15,2)
                               , ind_frt        number(1)
                               , vl_frt         number(15,2)
                               , vl_seg         number(15,2)
                               , vl_out_da      number(15,2)
                               , vl_bc_icms     number(15,2)
                               , vl_icms        number(15,2)
                               , vl_bc_icms_st  number(15,2)
                               , vl_icms_st     number(15,2)
                               , vl_ipi         number(15,2)
                               , vl_pis         number(15,2)
                               , vl_cofins      number(15,2)
                               , vl_pis_st      number(15,2)
                               , vl_cofins_st   number(15,2) );
--
   type t_tab_reg_c100 is table of tab_reg_c100 index by binary_integer;
   vt_tab_reg_c100 t_tab_reg_c100;
--
--| REGISTRO C101: INFORMAÇÃO COMPLEMENTAR DOS DOCUMENTOS FISCAIS QUANDO DAS OPERAÇÕES INTERESTADUAIS
    -- DESTINADAS A CONSUMIDOR FINAL NÃO CONTRIBUINTE EC 87/15 (CÓDIGO 55)
   -- Nível hierárquico - 3
   -- Ocorrência ¿ 1:1
   type tab_reg_c101 is record ( reg               varchar2(4)
                               , vl_fcp_uf_dest    number(15,2)
                               , vl_icms_uf_dest   number(15,2)
                               , vl_icms_uf_rem    number(15,2)
                               );
--
   type t_tab_reg_c101 is table of tab_reg_c101 index by binary_integer;
   vt_tab_reg_c101 t_tab_reg_c101;
--
--| REGISTRO C105 ¿ OPERAÇÕES COM ICMS ST RECOLHIDO PARA UF DIVERSA DO DESTINATÁRIO DO DOCUMENTO FISCAL (CÓDIGO 55)
   -- Nível hierárquico - 3
   -- Ocorrência - 1:1
   type tab_reg_c105 is record ( reg        varchar2(4)
                               , oper       number(1)
                               , uf         varchar2(2) );
--
   type t_tab_reg_c105 is table of tab_reg_c105 index by binary_integer;
   type t_bi_tab_reg_c105 is table of t_tab_reg_c105 index by binary_integer;
   vt_bi_tab_reg_c105 t_bi_tab_reg_c105;
--
--| REGISTRO C110: INFORMAÇÃO COMPLEMENTAR DA NOTA FISCAL (CÓDIGO 01, 1B, 04 e 55)
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_c110 is record ( reg        varchar2(4)
                               , cod_inf    varchar2(6)
                               , txt_compl  varchar2(255) );
--
   type t_tab_reg_c110 is table of tab_reg_c110 index by binary_integer;
   type t_bi_tab_reg_c110 is table of t_tab_reg_c110 index by binary_integer;
   vt_bi_tab_reg_c110 t_bi_tab_reg_c110;
--
--| REGISTRO C111: PROCESSO REFERENCIADO
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_c111 is record ( reg       varchar2(4)
                               , num_proc  varchar2(15)
                               , ind_proc  number(1) );
--
   type t_tab_reg_c111 is table of tab_reg_c111 index by binary_integer;
   type t_bi_tab_reg_c111 is table of t_tab_reg_c111 index by binary_integer;
   type t_tri_tab_reg_c111 is table of t_bi_tab_reg_c111 index by binary_integer;
   vt_tri_tab_reg_c111 t_tri_tab_reg_c111;
--
--| REGISTRO C112: DOCUMENTO DE ARRECADAÇÃO REFERENCIADO
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_c112 is record ( reg      varchar2(4)
                               , cod_da   number(1)
                               , uf       varchar2(2)
                               , num_da   varchar2(255)
                               , cod_aut  varchar2(255)
                               , vl_da    number(15,2)
                               , dt_vcto  date
                               , dt_pgto  date );
--
   type t_tab_reg_c112 is table of tab_reg_c112 index by binary_integer;
   type t_bi_tab_reg_c112 is table of t_tab_reg_c112 index by binary_integer;
   type t_tri_tab_reg_c112 is table of t_bi_tab_reg_c112 index by binary_integer;
   vt_tri_tab_reg_c112 t_tri_tab_reg_c112;
--
--| REGISTRO C113: DOCUMENTO FISCAL REFERENCIADO
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_c113 is record ( reg       varchar2(4)
                               , ind_oper  number(1)
                               , ind_emit  number(1)
                               , cod_part  varchar2(60)
                               , cod_mod   varchar2(2)
                               , ser       varchar2(4)
                               , sub       number(3)
                               , num_doc   number(9)
                               , dt_doc    date
                               , chv_doce  varchar2(44)
                               );
--
   type t_tab_reg_c113 is table of tab_reg_c113 index by binary_integer;
   type t_bi_tab_reg_c113 is table of t_tab_reg_c113 index by binary_integer;
   type t_tri_tab_reg_c113 is table of t_bi_tab_reg_c113 index by binary_integer;
   vt_tri_tab_reg_c113 t_tri_tab_reg_c113;
--
--| REGISTRO C114: CUPOM FISCAL REFERENCIADO
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_c114 is record ( reg      varchar2(4)
                               , cod_mod  varchar2(2)
                               , ecf_fab  varchar2(21)
                               , ecf_cx   number(3)
                               , num_doc  number(9)
                               , dt_doc   date );
--
   type t_tab_reg_c114 is table of tab_reg_c114 index by binary_integer;
   type t_bi_tab_reg_c114 is table of t_tab_reg_c114 index by binary_integer;
   type t_tri_tab_reg_c114 is table of t_bi_tab_reg_c114 index by binary_integer;
   vt_tri_tab_reg_c114 t_tri_tab_reg_c114;
--
--| REGISTRO C115: LOCAL DA COLETA E/OU ENTREGA (CÓDIGO 01, 1B E 04)
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_c115 is record ( reg           varchar2(4)
                               , ind_carga     number(1)
                               , cnpj_col      varchar2(14)
                               , ie_col        varchar2(14)
                               , cpf_col       varchar2(11)
                               , cod_mun_col   number(7)
                               , cnpj_entg     varchar2(14)
                               , ie_entg       varchar2(14)
                               , cpf_entg      varchar2(11)
                               , cod_mun_entg  number(7) );
--
   type t_tab_reg_c115 is table of tab_reg_c115 index by binary_integer;
   type t_bi_tab_reg_c115 is table of t_tab_reg_c115 index by binary_integer;
   type t_tri_tab_reg_c115 is table of t_bi_tab_reg_c115 index by binary_integer;
   vt_tri_tab_reg_c115 t_tri_tab_reg_c115;
--
--| REGISTRO C116: CUPOM FISCAL ELETRONICO REFERENCIADO
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_c116 is record ( reg      varchar2(4)
                               , cod_mod  varchar2(2)
                               , nr_sat   number(9)
                               , chv_cfe  varchar2(44)
                               , num_cfe  number(6)
                               , dt_doc   date );
--
   type t_tab_reg_c116 is table of tab_reg_c116 index by binary_integer;
   type t_bi_tab_reg_c116 is table of t_tab_reg_c116 index by binary_integer;
   type t_tri_tab_reg_c116 is table of t_bi_tab_reg_c116 index by binary_integer;
   vt_tri_tab_reg_c116 t_tri_tab_reg_c116;
--
--| REGISTRO C120: COMPLEMENTO DE DOCUMENTO - OPERAÇÕES DE IMPORTAÇÃO (CÓDIGOS 01 e 55)
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_c120 is record ( reg          varchar2(4)
                               , cod_doc_imp  number(1)
                               , num_doc_imp  varchar2(12)
                               , pis_imp      number(15,2)
                               , cofins_imp   number(15,2)
                               , num_acdraw   varchar2(20) );
--
   type t_tab_reg_c120 is table of tab_reg_c120 index by binary_integer;
   type t_bi_tab_reg_c120 is table of t_tab_reg_c120 index by binary_integer;
   vt_bi_tab_reg_c120 t_bi_tab_reg_c120;
--
--| REGISTRO C130: ISSQN, IRRF E PREVIDÊNCIA SOCIAL
   -- Nível hierárquico - 3
   -- Ocorrência - 1:1
   type tab_reg_c130 is record ( reg          varchar2(4)
                               , vl_serv_nt   number(15,2)
                               , vl_bc_issqn  number(15,2)
                               , vl_issqn     number(15,2)
                               , vl_bc_irrf   number(15,2)
                               , vl_irrf      number(15,2)
                               , vl_bc_prev   number(15,2)
                               , vl_prev      number(15,2) );
--
   type t_tab_reg_c130 is table of tab_reg_c130 index by binary_integer;
   type t_bi_tab_reg_c130 is table of t_tab_reg_c130 index by binary_integer;
   vt_bi_tab_reg_c130 t_bi_tab_reg_c130;
--
--| REGISTRO C140: FATURA (CÓDIGO 01)
   -- Nível hierárquico - 3
   -- Ocorrência - 1:1
   type tab_reg_c140 is record ( reg        varchar2(4)
                               , ind_emit   number(1)
                               , ind_tit    varchar2(2)
                               , desc_tit   varchar2(255)
                               , num_tit    varchar2(255)
                               , qtd_parc   number(2)
                               , vl_tit     number(15,2) );
--
   type t_tab_reg_c140 is table of tab_reg_c140 index by binary_integer;
   type t_bi_tab_reg_c140 is table of t_tab_reg_c140 index by binary_integer;
   vt_bi_tab_reg_c140 t_bi_tab_reg_c140;
--
--| REGISTRO C141: VENCIMENTO DA FATURA (CÓDIGO 01)
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_c141 is record ( reg       varchar2(4)
                               , num_parc  number(2)
                               , dt_vcto   date
                               , vl_parc   number(15,2) );
--
   type t_tab_reg_c141 is table of tab_reg_c141 index by binary_integer;
   type t_bi_tab_reg_c141 is table of t_tab_reg_c141 index by binary_integer;
   type t_tri_tab_reg_c141 is table of t_bi_tab_reg_c141 index by binary_integer;
   vt_tri_tab_reg_c141 t_tri_tab_reg_c141;
--
--| REGISTRO C160: VOLUMES TRANSPORTADOS (CÓDIGO 01 E 04) - EXCETO COMBUSTÍVEIS
   -- Nível hierárquico - 3
   -- Ocorrência - 1:1
   type tab_reg_c160 is record ( reg        varchar2(4)
                               , cod_part   varchar2(60)
                               , veic_id    varchar2(7)
                               , qtd_vol    number
                               , peso_brt   number(15,2)
                               , peso_liq   number(15,2)
                               , uf_id      varchar2(2) );
--
   type t_tab_reg_c160 is table of tab_reg_c160 index by binary_integer;
   type t_bi_tab_reg_c160 is table of t_tab_reg_c160 index by binary_integer;
   vt_bi_tab_reg_c160 t_bi_tab_reg_c160;
--
--| REGISTRO C165: OPERAÇÕES COM COMBUSTÍVEIS (CÓDIGO 01)
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_c165 is record ( reg        varchar2(4)
                               , cod_part   varchar2(60)
                               , veic_id    varchar2(7)
                               , cod_aut    varchar2(255)
                               , nr_passe   varchar2(255)
                               , hora       varchar2(6)
                               , temper     number(15,1)
                               , qtd_vol    number
                               , peso_brt   number(15,2)
                               , peso_liq   number(15,2)
                               , nom_mot    varchar2(60)
                               , cpf        varchar2(11)
                               , uf_id      varchar2(2) );
--
   type t_tab_reg_c165 is table of tab_reg_c165 index by binary_integer;
   type t_bi_tab_reg_c165 is table of t_tab_reg_c165 index by binary_integer;
   vt_bi_tab_reg_c165 t_bi_tab_reg_c165;
--
--| REGISTRO C170: ITENS DO DOCUMENTO (CÓDIGO 01, 1B, 04 e 55).
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N (um ou vários por registro C100)
   type tab_reg_c170 is record ( reg               varchar2(4)
                               , num_item          number(3)
                               , cod_item          varchar2(60)
                               , descr_compl       varchar2(255)
                               , qtd               number(16,5)
                               , unid              varchar2(6)
                               , vl_item           number(15,2)
                               , vl_desc           number(15,2)
                               , ind_mov           number(1)
                               , cst_icms          varchar2(3)
                               , cfop              number(4)
                               , cod_nat           varchar2(10)
                               , vl_bc_icms        number(15,2)
                               , aliq_icms         number(6,2)
                               , vl_icms           number(15,2)
                               , vl_bc_icms_st     number(15,2)
                               , aliq_st           number(6,2)
                               , vl_icms_st        number(15,2)
                               , ind_apur          number(1)
                               , cst_ipi           varchar2(3)
                               , cod_enq           varchar2(3)
                               , vl_bc_ipi         number(15,2)
                               , aliq_ipi          number(6,2)
                               , vl_ipi            number(15,2)
                               , cst_pis           varchar2(2)
                               , vl_bc_pis         number(15,2)
                               , aliq_pis          number(8,4)
                               , quant_bc_pis      number(16,3)
                               , vl_aliq_pis       number(15,4)
                               , vl_pis            number(15,2)
                               , cst_cofins        varchar2(2)
                               , vl_bc_cofins      number(15,2)
                               , aliq_cofins       number(8,4)
                               , quant_bc_cofins   number(16,3)
                               , vl_aliq_cofins    number(16,4)
                               , vl_cofins         number(15,2)
                               , cod_cta           varchar2(255)
                               , vl_abat_nt        number(15,2));
--
   type t_tab_reg_c170 is table of tab_reg_c170 index by binary_integer;
   type t_bi_tab_reg_c170 is table of t_tab_reg_c170 index by binary_integer;
   vt_bi_tab_reg_c170 t_bi_tab_reg_c170;
--
--| REGISTRO C171: ARMAZENAMENTO DE COMBUSTIVEIS (código 01, 55)
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_c171 is record ( reg         varchar2(4)
                               , num_tanque  varchar2(3)
                               , qtde        number(15,3) );
--
   type t_tab_reg_c171 is table of tab_reg_c171 index by binary_integer;
   type t_bi_tab_reg_c171 is table of t_tab_reg_c171 index by binary_integer;
   type t_tri_tab_reg_c171 is table of t_bi_tab_reg_c171 index by binary_integer;
   vt_tri_tab_reg_c171 t_tri_tab_reg_c171;
--
--| REGISTRO C172: OPERAÇÕES COM ISSQN (CÓDIGO 01)
   -- Nível hierárquico - 4
   -- Ocorrência - 1:1
   type tab_reg_c172 is record ( reg           varchar2(4)
                               , vl_bc_issqn   number(15,2)
                               , aliq_issqn    number(6,2)
                               , vl_issqn      number(15,2) );
--
   type t_tab_reg_c172 is table of tab_reg_c172 index by binary_integer;
   type t_bi_tab_reg_c172 is table of t_tab_reg_c172 index by binary_integer;
   type t_tri_tab_reg_c172 is table of t_bi_tab_reg_c172 index by binary_integer;
   vt_tri_tab_reg_c172 t_tri_tab_reg_c172;
--
--| REGISTRO C173: OPERAÇÕES COM MEDICAMENTOS (CÓDIGO 01 e 55)
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_c173 is record ( reg         varchar2(4)
                               , lote_med    varchar2(255)
                               , qtd_item    number(11,3)
                               , dt_fab      date
                               , dt_val      date
                               , ind_med     number(1)
                               , tp_prod     number(1)
                               , vl_tab_max  number(15,2) );
--
   type t_tab_reg_c173 is table of tab_reg_c173 index by binary_integer;
   type t_bi_tab_reg_c173 is table of t_tab_reg_c173 index by binary_integer;
   type t_tri_tab_reg_c173 is table of t_bi_tab_reg_c173 index by binary_integer;
   vt_tri_tab_reg_c173 t_tri_tab_reg_c173;
--
--| REGISTRO C174: OPERAÇÕES COM ARMAS DE FOGO (CÓDIGO 01).
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_c174 is record ( reg          varchar2(4)
                               , ind_arm      number(1)
                               , num_arm      varchar2(255)
                               , descr_compl  varchar2(255) );
--
   type t_tab_reg_c174 is table of tab_reg_c174 index by binary_integer;
   type t_bi_tab_reg_c174 is table of t_tab_reg_c174 index by binary_integer;
   type t_tri_tab_reg_c174 is table of t_bi_tab_reg_c174 index by binary_integer;
   vt_tri_tab_reg_c174 t_tri_tab_reg_c174;
--
--| REGISTRO C175: OPERAÇÕES COM VEÍCULOS NOVOS (CÓDIGO 01 e 55)
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_c175 is record ( reg            varchar2(4)
                               , ind_veic_oper  number(1)
                               , cnpj           varchar2(14)
                               , uf             varchar2(2)
                               , chassi_veic    varchar2(17) );
--
   type t_tab_reg_c175 is table of tab_reg_c175 index by binary_integer;
   type t_bi_tab_reg_c175 is table of t_tab_reg_c175 index by binary_integer;
   type t_tri_tab_reg_c175 is table of t_bi_tab_reg_c175 index by binary_integer;
   vt_tri_tab_reg_c175 t_tri_tab_reg_c175;
--
--| REGISTRO C176: RESSARCIMENTO DE ICMS EM OPERAÇÕES COM SUBSTITUIÇÃO TRIBUTÁRIA (CÓDIGO 01, 55)
   -- Nível hierárquico - 4
   -- Ocorrência - 1:1
   type tab_reg_c176 is record ( reg                            varchar2(4)
                               , cod_mod_ult_e                  varchar2(2)
                               , num_doc_ult_e                  number(9)
                               , ser_ult_e                      varchar2(3)
                               , dt_ult_e                       date
                               , cod_part_ult_e                 varchar2(60)
                               , quant_ult_e                    number(12,3)
                               , vl_unit_ult_e                  number(15,3)
                               , vl_unit_bc_st                  number(15,3)
                               , chave_nfe_ult_e                varchar2(44)
                               , num_item_ult_e                 number(3)
                               , vl_unit_bc_icms_ult_e          number(15,2)
                               , aliq_icms_ult_e                number(5,2)
                               , vl_unit_limite_bc_icms_ult_e   number(15,2)
                               , vl_unit_icms_ult_e             number(15,3)
                               , aliq_st_ult_e                  number(5,2)
                               , vl_unit_res                    number(15,3)
                               , dm_cod_resp_ret                number(1)
                               , dm_cod_mot_res                 number(1)
                               , chave_nfe_ret                  varchar2(44)
                               , cod_part_nfe_ret               varchar2(60)
                               , ser_nfe_ret                    varchar2(3)
                               , num_nfe_ret                    number(9)
                               , item_nfe_ret                   number(3)
                               , dm_cod_da                      varchar2(1)
                               , num_da                         varchar2(255)
                               , vl_unit_res_fcp_st             number(15,3)
                               );
--
   type t_tab_reg_c176 is table of tab_reg_c176 index by binary_integer;
   type t_bi_tab_reg_c176 is table of t_tab_reg_c176 index by binary_integer;
   type t_tri_tab_reg_c176 is table of t_bi_tab_reg_c176 index by binary_integer;
   vt_tri_tab_reg_c176 t_tri_tab_reg_c176;
--
--| REGISTRO C177: OPERAÇÕES COM PRODUTOS SUJEITOS A SELO DE CONTROLE IPI
   -- Nível hierárquico - 4
   -- Ocorrência - 1:1
   type tab_reg_c177 is record ( reg           varchar2(4)
                               , cod_selo_ipi  varchar2(6)
                               , qt_selo_ipi   number(12)
                               , cod_inf_item  varchar2(8));
--
   type t_tab_reg_c177 is table of tab_reg_c177 index by binary_integer;
   type t_bi_tab_reg_c177 is table of t_tab_reg_c177 index by binary_integer;
   type t_tri_tab_reg_c177 is table of t_bi_tab_reg_c177 index by binary_integer;
   vt_tri_tab_reg_c177 t_tri_tab_reg_c177;
--
--| REGISTRO C178: OPERAÇÕES COM PRODUTOS SUJEITOS À TRIBUTAÇÀO DE IPI POR UNIDADE OU QUANTIDADE DE PRODUTO
   -- Nível hierárquico - 4
   -- Ocorrência - 1:1
   type tab_reg_c178 is record ( reg        varchar2(4)
                               , cl_enq     varchar2(5)
                               , vl_unid    number(15,2)
                               , quant_pad  number(16,3) );
--
   type t_tab_reg_c178 is table of tab_reg_c178 index by binary_integer;
   type t_bi_tab_reg_c178 is table of t_tab_reg_c178 index by binary_integer;
   type t_tri_tab_reg_c178 is table of t_bi_tab_reg_c178 index by binary_integer;
   vt_tri_tab_reg_c178 t_tri_tab_reg_c178;
--
--| REGISTRO C179: INFORMAÇÕES COMPLEMENTARES ST (CÓDIGO 01)
   -- Nível hierárquico - 4
   -- Ocorrência - 1:1
   type tab_reg_c179 is record ( reg              varchar2(4)
                               , bc_st_orig_dest  number(15,2)
                               , icms_st_rep      number(15,2)
                               , icms_st_compl    number(15,2)
                               , bc_ret           number(15,2)
                               , icms_ret         number(15,2) );
--
   type t_tab_reg_c179 is table of tab_reg_c179 index by binary_integer;
   type t_bi_tab_reg_c179 is table of t_tab_reg_c179 index by binary_integer;
   type t_tri_tab_reg_c179 is table of t_bi_tab_reg_c179 index by binary_integer;
   vt_tri_tab_reg_c179 t_tri_tab_reg_c179;
--
--| REGISTRO C190: REGISTRO ANALÍTICO DO DOCUMENTO (CÓDIGO 01, 1B, 04 E 55).
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_c190 is record ( reg            varchar2(4)
                               , cst_icms       varchar2(3)
                               , cfop           number(4)
                               , aliq_icms      number(6,2)
                               , vl_opr         number(15,2)
                               , vl_bc_icms     number(15,2)
                               , vl_icms        number(15,2)
                               , vl_bc_icms_st  number(15,2)
                               , vl_icms_st     number(15,2)
                               , vl_red_bc      number(15,2)
                               , vl_ipi         number(15,2)
                               , cod_obs        varchar2(6) );
--
   type t_tab_reg_c190 is table of tab_reg_c190 index by binary_integer;
   type t_bi_tab_reg_c190 is table of t_tab_reg_c190 index by binary_integer;
   vt_bi_tab_reg_c190 t_bi_tab_reg_c190;

--|C191: INFORMAÇÕES DO FUNDO DE COMBATE À POBREZA ¿ FCP ¿ NA NFe (CÓDIGO 55)

   type tab_reg_c191 is record ( reg        varchar2(4)
                               , vl_fcp_op   number(15,2)
                               , vl_fcp_st   number(15,2)
                               , vl_fcp_ret  number(15,2));
--
   type t_tab_reg_c191 is table of tab_reg_c191 index by binary_integer;
   type t_bi_tab_reg_c191 is table of t_tab_reg_c191 index by binary_integer;
   type t_tri_tab_reg_c191 is table of t_bi_tab_reg_c191 index by binary_integer;
   vt_tri_tab_reg_c191 t_tri_tab_reg_c191;
--
--| NOVO TÍTULO: REGISTRO C195: OBSERVAÇOES DO LANÇAMENTO FISCAL (CÓDIGO 01, 1B, 04 E 55)
--| REGISTRO C195: OBSERVAÇOES DO LANÇAMENTO FISCAL (CÓDIGO 01, 1B E 55)
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_c195 is record ( reg        varchar2(4)
                               , cod_obs    varchar2(6)
                               , txt_compl  varchar2(255) );
--
   type t_tab_reg_c195 is table of tab_reg_c195 index by binary_integer;
   type t_bi_tab_reg_c195 is table of t_tab_reg_c195 index by binary_integer;
   vt_bi_tab_reg_c195 t_bi_tab_reg_c195;
--
--| REGISTRO C197: OUTRAS OBRIGAÇÕES TRIBUTÁRIAS, AJUSTES E INFORMAÇÕES DE VALORES PROVENIENTES DE DOCUMENTO FISCAL
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_c197 is record ( reg             varchar2(4)
                               , cod_aj          varchar2(10)
                               , descr_compl_aj  varchar2(255)
                               , cod_item        varchar2(60)
                               , vl_bc_icms      number(15,2)
                               , aliq_icms       number(6,2)
                               , vl_icms         number(15,2)
                               , vl_outros       number(15,2) );
--
   type t_tab_reg_c197 is table of tab_reg_c197 index by binary_integer;
   type t_bi_tab_reg_c197 is table of t_tab_reg_c197 index by binary_integer;
   type t_tri_tab_reg_c197 is table of t_bi_tab_reg_c197 index by binary_integer;
   vt_tri_tab_reg_c197 t_tri_tab_reg_c197;
--
--| REGISTRO C300: RESUMO DIÁRIO DAS NOTAS FISCAIS DE VENDA A CONSUMIDOR (CÓDIGO 02)
   -- Nível hierárquico - 2
   -- Ocorrência ¿vários por Arquivo
   type tab_reg_c300 is record ( reg            varchar2(4)
                               , cod_mod        varchar2(2)
                               , ser            varchar2(4)
                               , sub            varchar2(3)
                               , num_doc_ini    number(6)
                               , num_doc_fin    number(6)
                               , dt_doc         date
                               , vl_doc         number(15,2)
                               , vl_pis         number(15,2)
                               , vl_cofins      number(15,2)
                               , cod_cta        varchar2(255) );
--
   type t_tab_reg_c300 is table of tab_reg_c300 index by binary_integer;
   vt_tab_reg_c300 t_tab_reg_c300;
--
--| REGISTRO C310: DOCUMENTOS CANCELADOS DE NOTAS FISCAIS DE VENDA A CONSUMIDOR (CÓDIGO 02).
   -- Nível hierárquico - 3
   -- Ocorrência ¿ 1:N
   type tab_reg_c310 is record ( reg            varchar2(4)
                               , num_doc_canc   number(6) );
--
   type t_tab_reg_c310 is table of tab_reg_c310 index by binary_integer;
   type t_bi_tab_reg_c310 is table of t_tab_reg_c310 index by binary_integer;
   vt_bi_tab_reg_c310 t_bi_tab_reg_c310;
--
--| REGISTRO C320: REGISTRO ANALÍTICO DO RESUMO DIÁRIO DAS NOTAS FISCAIS DE VENDA A CONSUMIDOR (CÓDIGO 02)
   -- Nível hierárquico - 3
   -- Ocorrência ¿ 1:N
   type tab_reg_c320 is record ( reg            varchar2(4)
                               , cst_icms       varchar2(3)
                               , cfop           number(4)
                               , aliq_icms      number(6,2)
                               , vl_opr         number(15,2)
                               , vl_bc_icms     number(15,2)
                               , vl_icms        number(15,2)
                               , vl_red_bc      number(15,2)
                               , cod_obs        varchar2(6) );
--
   type t_tab_reg_c320 is table of tab_reg_c320 index by binary_integer;
   type t_bi_tab_reg_c320 is table of t_tab_reg_c320 index by binary_integer;
   vt_bi_tab_reg_c320 t_bi_tab_reg_c320;
--
--| REGISTRO C321: ITENS DO RESUMO DIÁRIO DOS DOCUMENTOS (CÓDIGO 02).
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_c321 is record ( reg            varchar2(4)
                               , cod_item       varchar2(60)
                               , qtd            number(12,3)
                               , unid           varchar2(6)
                               , vl_item        number(15,2)
                               , vl_desc        number(15,2)
                               , vl_bc_icms     number(15,2)
                               , vl_icms        number(15,2)
                               , vl_pis         number(15,2)
                               , vl_cofins      number(15,2) );
--
   type t_tab_reg_c321 is table of tab_reg_c321 index by binary_integer;
   type t_bi_tab_reg_c321 is table of t_tab_reg_c321 index by binary_integer;
   type t_tri_tab_reg_c321 is table of t_bi_tab_reg_c321 index by binary_integer;
   vt_tri_tab_reg_c321 t_tri_tab_reg_c321;
--
--| REGISTRO C350: NOTA FISCAL DE VENDA A CONSUMIDOR (CÓDIGO 02)
   -- Nível hierárquico - 2
   -- Ocorrência ¿ vários (por arquivo)
   type tab_reg_c350 is record ( reg            varchar2(4)
                               , ser            varchar2(4)
                               , sub_ser        varchar2(3)
                               , num_doc        number(6)
                               , dt_doc         date
                               , cnpj_cpf       varchar2(14)
                               , vl_merc        number(15,2)
                               , vl_doc         number(15,2)
                               , vl_desc        number(15,2)
                               , vl_pis         number(15,2)
                               , vl_cofins      number(15,2)
                               , cod_cta        varchar2(255) );
--
   type t_tab_reg_c350 is table of tab_reg_c350 index by binary_integer;
   vt_tab_reg_c350 t_tab_reg_c350;
--
--| REGISTRO C370: ITENS DO DOCUMENTO (CÓDIGO 02)
   -- Nível hierárquico - 3
   -- Ocorrência ¿ 1:N
   type tab_reg_c370 is record ( reg            varchar2(4)
                               , num_item       number(3)
                               , cod_item       varchar2(60)
                               , qtd            number(12,3)
                               , unid           varchar2(6)
                               , vl_item        number(15,2)
                               , vl_desc        number(15,2) );
--
   type t_tab_reg_c370 is table of tab_reg_c370 index by binary_integer;
   type t_bi_tab_reg_c370 is table of t_tab_reg_c370 index by binary_integer;
   vt_bi_tab_reg_c370 t_bi_tab_reg_c370;
--
--| REGISTRO C390 ¿ REGISTRO ANALÍTICO DAS NOTAS FISCAIS DE VENDA A CONSUMIDOR (CÓDIGO 02)
   -- Nível hierárquico - 3
   -- Ocorrência ¿ 1:N
   type tab_reg_c390 is record ( reg            varchar2(4)
                               , cst_icms       varchar2(3)
                               , cfop           number(4)
                               , aliq_icms      number(6,2)
                               , vl_opr         number(15,2)
                               , vl_bc_icms     number(15,2)
                               , vl_icms        number(15,2)
                               , vl_red_bc      number(15,2)
                               , cod_obs        varchar2(6) );
--
   type t_tab_reg_c390 is table of tab_reg_c390 index by binary_integer;
   type t_bi_tab_reg_c390 is table of t_tab_reg_c390 index by binary_integer;
   vt_bi_tab_reg_c390 t_bi_tab_reg_c390;
--
--| REGISTRO C400 - EQUIPAMENTO ECF (CÓDIGO 02 e 2D)
   -- Nível hierárquico - 2
   -- Ocorrência - 1:N
   type tab_reg_c400 is record ( reg            varchar2(4)
                               , cod_mod        varchar2(2)
                               , ecf_mod        varchar2(20)
                               , ecf_fab        varchar2(20)
                               , ecf_cx         number(3) );
--
   type t_tab_reg_c400 is table of tab_reg_c400 index by binary_integer;
   vt_tab_reg_c400 t_tab_reg_c400;
--
--| NOVO TÍTULO: REGISTRO C405: REDUÇÃO Z (CÓDIGO 02, 2D e 60)
--| REGISTRO C405 - REDUÇÃO Z (CÓDIGO 02 e 2D)
   -- Nível hierárquico - 3
   -- Ocorrência ¿ 1:N
   type tab_reg_c405 is record ( reg            varchar2(4)
                               , dt_doc         date
                               , cro            number(3)
                               , crz            number(6)
                               , num_coo_fin    number(9)
                               , gt_fin         number(15,2)
                               , vl_brt         number(15,2) );
--
   type t_tab_reg_c405 is table of tab_reg_c405 index by binary_integer;
   type t_bi_tab_reg_c405 is table of t_tab_reg_c405 index by binary_integer;
   vt_bi_tab_reg_c405 t_bi_tab_reg_c405;
--
--| REGISTRO C410: PIS E COFINS TOTALIZADOS NO DIA (CÓDIGO 02 e 2D)
   -- Nível hierárquico - 4
   -- Ocorrência - 1:1
   type tab_reg_c410 is record ( reg            varchar2(4)
                               , vl_pis         number(15,2)
                               , vl_cofins      number(15,2) );
--
   type t_tab_reg_c410 is table of tab_reg_c410 index by binary_integer;
   type t_bi_tab_reg_c410 is table of t_tab_reg_c410 index by binary_integer;
   type t_tri_tab_reg_c410 is table of t_bi_tab_reg_c410 index by binary_integer;
   vt_tri_tab_reg_c410 t_tri_tab_reg_c410;
--
--| REGISTRO C420: REGISTRO DOS TOTALIZADORES PARCIAIS DA REDUÇÃO Z (COD 02 e 2D)
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_c420 is record ( reg            varchar2(4)
                               , cod_tot_par    varchar2(7)
                               , vlr_acum_tot   number(15,2)
                               , nr_tot         number(2)
                               , descr_nr_tot   varchar2(255) );
--
   type t_tab_reg_c420 is table of tab_reg_c420 index by binary_integer;
   type t_bi_tab_reg_c420 is table of t_tab_reg_c420 index by binary_integer;
   type t_tri_tab_reg_c420 is table of t_bi_tab_reg_c420 index by binary_integer;
   vt_tri_tab_reg_c420 t_tri_tab_reg_c420;
--
--| REGISTRO C425: RESUMO DE ITENS DO MOVIMENTO DIÁRIO (CÓDIGO 02 e 2D).
   -- Nível hierárquico - 5
   -- Ocorrência - 1:N
   type tab_reg_c425 is record ( reg            varchar2(4)
                               , cod_item       varchar2(60)
                               , qtd            number(12,3)
                               , unid           varchar2(6)
                               , vl_item        number(15,2)
                               , vl_pis         number(15,2)
                               , vl_cofins      number(15,2) );
--
   type t_tab_reg_c425 is table of tab_reg_c425 index by binary_integer;
   type t_bi_tab_reg_c425 is table of t_tab_reg_c425 index by binary_integer;
   type t_tri_tab_reg_c425 is table of t_bi_tab_reg_c425 index by binary_integer;
   type t_tetra_tab_reg_c425 is table of t_tri_tab_reg_c425 index by binary_integer;
   vt_tetra_tab_reg_c425 t_tetra_tab_reg_c425;
--
--| REGISTRO C460: DOCUMENTO FISCAL EMITIDO POR ECF (CÓDIGO 02 e 2D)
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_c460 is record ( reg            varchar2(4)
                               , cod_mod        varchar2(2)
                               , cod_sit        varchar2(2)
                               , num_doc        number(9)
                               , dt_doc         date
                               , vl_doc         number(15,2)
                               , vl_pis         number(15,2)
                               , vl_cofins      number(15,2)
                               , cpf_cnpj       varchar2(14)
                               , nom_adq        varchar2(60) );
--
   type t_tab_reg_c460 is table of tab_reg_c460 index by binary_integer;
   type t_bi_tab_reg_c460 is table of t_tab_reg_c460 index by binary_integer;
   type t_tri_tab_reg_c460 is table of t_bi_tab_reg_c460 index by binary_integer;
   vt_tri_tab_reg_c460 t_tri_tab_reg_c460;
--
--| REGISTRO C470: ITENS DO DOCUMENTO FISCAL EMITIDO POR ECF (CÓDIGO 02 e 2D)
   -- Nível hierárquico - 5
   -- Ocorrência - 1:N
   type tab_reg_c470 is record ( reg            varchar2(4)
                               , cod_item       varchar2(60)
                               , qtd            number(12,3)
                               , qtd_canc       number(12,3)
                               , unid           varchar2(6)
                               , vl_item        number(15,2)
                               , cst_icms       varchar2(3)
                               , cfop           number(4)
                               , aliq_icms      number(6,2)
                               , vl_pis         number(15,2)
                               , vl_cofins      number(15,2) );
--
   type t_tab_reg_c470 is table of tab_reg_c470 index by binary_integer;
   type t_bi_tab_reg_c470 is table of t_tab_reg_c470 index by binary_integer;
   type t_tri_tab_reg_c470 is table of t_bi_tab_reg_c470 index by binary_integer;
   type t_tetra_tab_reg_c470 is table of t_tri_tab_reg_c470 index by binary_integer;
   vt_tetra_tab_reg_c470 t_tetra_tab_reg_c470;
--
--| REGISTRO C490: REGISTRO ANALÍTICO DO MOVIMENTO DIÁRIO (CÓDIGO 02 e 2D)
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_c490 is record ( reg            varchar2(4)
                               , cst_icms       varchar2(3)
                               , cfop           number(4)
                               , aliq_icms      number(6,2)
                               , vl_opr         number(15,2)
                               , vl_bc_icms     number(15,2)
                               , vl_icms        number(15,2)
                               , cod_obs        varchar2(6) );
--
   type t_tab_reg_c490 is table of tab_reg_c490 index by binary_integer;
   type t_bi_tab_reg_c490 is table of t_tab_reg_c490 index by binary_integer;
   type t_tri_tab_reg_c490 is table of t_bi_tab_reg_c490 index by binary_integer;
   vt_tri_tab_reg_c490 t_tri_tab_reg_c490;
--
--| REGISTRO C495: RESUMO MENSAL DE ITENS DO ECF POR ESTABELECIMENTO (CÓDIGO 02 e 2D)
   -- Nível hierárquico - 2
   -- Ocorrência - vários
   type tab_reg_c495 is record ( reg            varchar2(4)
                               , aliq_icms      number(6,2)
                               , cod_item       varchar2(60)
                               , qtd            number(12,3)
                               , qtd_canc       number(12,3)
                               , unid           varchar2(6)
                               , vl_item        number(15,2)
                               , vl_desc        number(15,2)
                               , vl_canc        number(15,2)
                               , vl_acmo        number(15,2)
                               , vl_bc_icms     number(15,2)
                               , vl_icms        number(15,2)
                               , vl_isen        number(15,2)
                               , vl_nt          number(15,2)
                               , vl_icms_st     number(15,2) );
--
   type t_tab_reg_c495 is table of tab_reg_c495 index by binary_integer;
   vt_tab_reg_c495 t_tab_reg_c495;
--
--| NOVO TÍTULO: REGISTRO C500: NOTA FISCAL/CONTA DE ENERGIA ELÉTRICA (CÓDIGO 06), NOTA FISCAL/CONTA DE FORNECIMENTO D'ÁGUA CANALIZADA (CÓDIGO 29) E
--| NOTA FISCAL CONSUMO FORNECIMENTO DE GÁS (CÓDIGO 28)
--| REGISTRO C500: NOTA FISCAL/CONTA DE ENERGIA ELÉTRICA (CÓDIGO 06) E NOTA FISCAL CONSUMO FORNECIMENTO DE GÁS (CÓDIGO 28)
   -- Nível hierárquico - 2
   -- Ocorrência ¿vários por Arquivo
   type tab_reg_c500 is record ( reg               varchar2(4)
                               , ind_oper          number(1)
                               , ind_emit          number(1)
                               , cod_part          varchar2(60)
                               , cod_mod           varchar2(2)
                               , cod_sit           varchar2(2)
                               , ser               varchar2(4)
                               , sub               number(3)
                               , cod_cons          varchar2(2)
                               , num_doc           number(9)
                               , dt_doc            date
                               , dt_e_s            date
                               , vl_doc            number(15,2)
                               , vl_desc           number(15,2)
                               , vl_forn           number(15,2)
                               , vl_serv_nt        number(15,2)
                               , vl_terc           number(15,2)
                               , vl_da             number(15,2)
                               , vl_bc_icms        number(15,2)
                               , vl_icms           number(15,2)
                               , vl_bc_icms_st     number(15,2)
                               , vl_icms_st        number(15,2)
                               , cod_inf           varchar2(6)
                               , vl_pis            number(15,2)
                               , vl_cofins         number(15,2)
                               , tp_ligacao        number(1)
                               , cod_grupo_tensao  varchar2(2) 
                               , chave_nfe         varchar2(44)                
                               , fin_doc           number(1)
                               , chave_nfe_ref     varchar2(44)
                               , ind_dest          number(1)                 
                 , cod_mun_dest      number(7)
                 , cod_cta           varchar2(255) );
--
   type t_tab_reg_c500 is table of tab_reg_c500 index by binary_integer;
   vt_tab_reg_c500 t_tab_reg_c500;
--
--| NOVO TÍTULO: REGISTRO C510: ITENS DO DOCUMENTO - NOTA FISCAL/CONTA DE ENERGIA ELÉTRICA (CÓDIGO 06), NOTA FISCAL/CONTA DE FORNECIMENTO DÁGUA CANALIZADA
--| (CÓDIGO 29) E NOTA FISCAL/CONTA FORNECIMENTO DE GÁS (CÓDIGO 28)
--| REGISTRO C510: ITENS DO DOCUMENTO NOTA FISCAL/CONTA ENERGIA ELÉTRICA (CÓDIGO 06) E NOTA FISCAL/CONTA DE FORNECIMENTO DE GÁS (CÓDIGO 28).
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_c510 is record ( reg            varchar2(4)
                               , num_item       number(3)
                               , cod_item       varchar2(60)
                               , cod_class      varchar2(4)
                               , qtd            number(12,3)
                               , unid           varchar2(6)
                               , vl_item        number(15,2)
                               , vl_desc        number(15,2)
                               , cst_icms       varchar2(3)
                               , cfop           number(4)
                               , vl_bc_icms     number(15,2)
                               , aliq_icms      number(6,2)
                               , vl_icms        number(15,2)
                               , vl_bc_icms_st  number(15,2)
                               , aliq_st        number(6,2)
                               , vl_icms_st     number(15,2)
                               , ind_rec        number(1)
                               , cod_part       varchar2(60)
                               , vl_pis         number(15,2)
                               , vl_cofins      number(15,2)
                               , cod_cta        varchar2(255) );
--
   type t_tab_reg_c510 is table of tab_reg_c510 index by binary_integer;
   type t_bi_tab_reg_c510 is table of t_tab_reg_c510 index by binary_integer;
   vt_bi_tab_reg_c510 t_bi_tab_reg_c510;
--
--| NOVO TÍTULO: REGISTRO C590: REGISTRO ANALÍTICO DO DOCUMENTO - NOTA FISCAL/CONTA DE ENERGIA ELÉTRICA (CÓDIGO 06), NOTA FISCAL/CONTA DE FORNECIMENTO DÁGUA
--| CANALIZADA (CÓDIGO 29) E NOTA FISCAL/CONTA FORNECIMENTO DE GÁS (CÓDIGO 28)
--| REGISTRO C590: REGISTRO ANALÍTICO DO DOCUMENTO - NOTA FISCAL/CONTA DE ENERGIA ELÉTRICA (CÓDIGO 06) E NOTA FISCAL CONSUMO FORNECIMENTO DE GÁS (CÓDIGO 28)
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N (um ou vários por registro C500)
   type tab_reg_c590 is record ( reg            varchar2(4)
                               , cst_icms       varchar2(3)
                               , cfop           number(4)
                               , aliq_icms      number(6,2)
                               , vl_opr         number(15,2)
                               , vl_bc_icms     number(15,2)
                               , vl_icms        number(15,2)
                               , vl_bc_icms_st  number(15,2)
                               , vl_icms_st     number(15,2)
                               , vl_red_bc      number(15,2)
                               , cod_obs        varchar2(6) );
--
   type t_tab_reg_c590 is table of tab_reg_c590 index by binary_integer;
   type t_bi_tab_reg_c590 is table of t_tab_reg_c590 index by binary_integer;
   vt_bi_tab_reg_c590 t_bi_tab_reg_c590;
--
--|c591: INFORMAÇÕES DO FUNDO DE COMBATE À POBREZA ¿ FCP ¿ NA NFe (CÓDIGO 55)

   type tab_reg_c591 is record ( reg        varchar2(4)
                               , vl_fcp_op   number(15,2)
                               , vl_fcp_st   number(15,2)
                               , vl_fcp_ret  number(15,2));
--
   type t_tab_reg_c591 is table of tab_reg_c591 index by binary_integer;
   type t_bi_tab_reg_c591 is table of t_tab_reg_c591 index by binary_integer;
   type t_tri_tab_reg_c591 is table of t_bi_tab_reg_c591 index by binary_integer;
   vt_tri_tab_reg_c591 t_tri_tab_reg_c591;
--
--| NOVO TÍTULO: REGISTRO c595: OBSERVAÇOES DO LANÇAMENTO FISCAL (CÓDIGO 01, 1B, 04 E 55)
--| REGISTRO c595: OBSERVAÇOES DO LANÇAMENTO FISCAL (CÓDIGO 01, 1B E 55)
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_c595 is record ( reg        varchar2(4)
                               , cod_obs    varchar2(6)
                               , txt_compl  varchar2(255) );
--
   type t_tab_reg_c595 is table of tab_reg_c595 index by binary_integer;
   type t_bi_tab_reg_c595 is table of t_tab_reg_c595 index by binary_integer;
   vt_bi_tab_reg_c595 t_bi_tab_reg_c595;
--
--| REGISTRO c597: OUTRAS OBRIGAÇÕES TRIBUTÁRIAS, AJUSTES E INFORMAÇÕES DE VALORES PROVENIENTES DE DOCUMENTO FISCAL
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_c597 is record ( reg             varchar2(4)
                               , cod_aj          varchar2(10)
                               , descr_compl_aj  varchar2(255)
                               , cod_item        varchar2(60)
                               , vl_bc_icms      number(15,2)
                               , aliq_icms       number(6,2)
                               , vl_icms         number(15,2)
                               , vl_outros       number(15,2) );
--
   type t_tab_reg_c597 is table of tab_reg_c597 index by binary_integer;
   type t_bi_tab_reg_c597 is table of t_tab_reg_c597 index by binary_integer;
   type t_tri_tab_reg_c597 is table of t_bi_tab_reg_c597 index by binary_integer;
   vt_tri_tab_reg_c597 t_tri_tab_reg_c597;
--
--| REGISTRO C600: CONSOLIDAÇÃO DIÁRIA DE NOTAS FISCAIS/CONTAS DE ENERGIA ELÉTRICA (CÓDIGO 06), NOTA FISCAL/CONTA DE FORNECIMENTO D'ÁGUA CANALIZADA (CÓDIGO 29) E NOTA FISCAL/CONTA DE FORNECIMENTO DE GÁS (CÓDIGO 28) (EMPRESAS NÃO OBRIGADAS AO CONVÊNIO ICMS 115/03)
   -- Nível hierárquico - 2
   -- Ocorrência ¿vários por Arquivo
   type tab_reg_c600 is record ( reg            varchar2(4)
                               , cod_mod        varchar2(2)
                               , cod_mun        number(7)
                               , ser            varchar2(4)
                               , sub            number(3)
                               , cod_cons       varchar2(2)
                               , qtd_cons       number
                               , qtd_canc       number
                               , dt_doc         date
                               , vl_doc         number(15,2)
                               , vl_desc        number(15,2)
                               , cons           number
                               , vl_forn        number(15,2)
                               , vl_serv_nt     number(15,2)
                               , vl_terc        number(15,2)
                               , vl_da          number(15,2)
                               , vl_bc_icms     number(15,2)
                               , vl_icms        number(15,2)
                               , vl_bc_icms_st  number(15,2)
                               , vl_icms_st     number(15,2)
                               , vl_pis         number(15,2)
                               , vl_cofins      number(15,2) );
--
   type t_tab_reg_c600 is table of tab_reg_c600 index by binary_integer;
   vt_tab_reg_c600 t_tab_reg_c600;
--
--| REGISTRO C601: DOCUMENTOS CANCELADOS - CONSOLIDAÇÃO DIÁRIA DE NOTAS FISCAIS/CONTAS DE ENERGIA ELÉTRICA (CÓDIGO 06), NOTA FISCAL/CONTA DE FORNECIMENTO D'ÁGUA CANALIZADA (CÓDIGO 29) E NOTA FISCAL/CONTA DE FORNECIMENTO DE GÁS (CÓDIGO 28)
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_c601 is record ( reg            varchar2(4)
                               , num_doc_canc   number(9) );
--
   type t_tab_reg_c601 is table of tab_reg_c601 index by binary_integer;
   type t_bi_tab_reg_c601 is table of t_tab_reg_c601 index by binary_integer;
   vt_bi_tab_reg_c601 t_bi_tab_reg_c601;
--
--| REGISTRO C610: ITENS DO DOCUMENTO CONSOLIDADO (CÓDIGO 06), NOTA FISCAL/CONTA DE FORNECIMENTO D'ÁGUA CANALIZADA (CÓDIGO 29) E NOTA FISCAL/CONTA DE FORNECIMENTO DE GÁS (CÓDIGO 28) (EMPRESAS NÃO OBRIGADAS AO CONVÊNIO ICMS 115/03)
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_c610 is record ( reg            varchar2(4)
                               , cod_class      varchar2(4)
                               , cod_item       varchar2(60)
                               , qtd            number(12,3)
                               , unid           varchar2(6)
                               , vl_item        number(15,2)
                               , vl_desc        number(15,2)
                               , cst_icms       varchar2(3)
                               , cfop           number(4)
                               , aliq_icms      number(6,2)
                               , vl_bc_icms     number(15,2)
                               , vl_icms        number(15,2)
                               , vl_bc_icms_st  number(15,2)
                               , vl_icms_st     number(15,2)
                               , vl_pis         number(15,2)
                               , vl_cofins      number(15,2)
                               , cod_cta        varchar2(255) );
--
   type t_tab_reg_c610 is table of tab_reg_c610 index by binary_integer;
   type t_bi_tab_reg_c610 is table of t_tab_reg_c610 index by binary_integer;
   vt_bi_tab_reg_c610 t_bi_tab_reg_c610;
--
--| REGISTRO C690: REGISTRO ANALÍTICO DOS DOCUMENTOS (NOTAS FISCAIS/CONTAS DE ENERGIA ELÉTRICA (CÓDIGO 06), NOTA FISCAL/CONTA DE FORNECIMENTO D¿ÁGUA CANALIZADA (CÓDIGO 29) E NOTA FISCAL/CONTA DE FORNECIMENTO DE GÁS (CÓDIGO 28)
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_c690 is record ( reg            varchar2(4)
                               , cst_icms       varchar2(3)
                               , cfop           number(4)
                               , aliq_icms      number(6,2)
                               , vl_opr         number(15,2)
                               , vl_bc_icms     number(15,2)
                               , vl_icms        number(15,2)
                               , vl_red_bc      number(15,2)
                               , vl_bc_icms_st  number(15,2)
                               , vl_icms_st     number(15,2)
                               , cod_obs        varchar2(6) );
--
   type t_tab_reg_c690 is table of tab_reg_c690 index by binary_integer;
   type t_bi_tab_reg_c690 is table of t_tab_reg_c690 index by binary_integer;
   vt_bi_tab_reg_c690 t_bi_tab_reg_c690;
--
--| REGISTRO C700: CONSOLIDAÇÃO DOS DOCUMENTOS NF/CONTA ENERGIA ELÉTRICA (CÓD 06), EMITIDAS EM VIA ÚNICA (EMPRESAS OBRIGADAS AO CONVÊNIO ICMS 115/03) ) E NOTA FISCAL/CONTA DE FORNECIMENTO DE GÁS CANALIZADO (CÓDIGO 28)
   -- Nível hierárquico - 2
   -- Ocorrência ¿ vários por arquivo
   type tab_reg_c700 is record ( reg            varchar2(4)
                               , cod_mod        varchar2(2)
                               , ser            varchar2(4)
                               , nro_ord_ini    number(9)
                               , nro_ord_fin    number(9)
                               , dt_doc_ini     date
                               , dt_doc_fin     date
                               , nom_mest       varchar2(15)
                               , chv_cod_dig    varchar2(32) );
--
   type t_tab_reg_c700 is table of tab_reg_c700 index by binary_integer;
   vt_tab_reg_c700 t_tab_reg_c700;
--
--| REGISTRO C790: REGISTRO ANALÍTICO DOS DOCUMENTOS (CÓDIGO 06)
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N (um ou vários por registro C700)
   type tab_reg_c790 is record ( reg            varchar2(4)
                               , cst_icms       varchar2(3)
                               , cfop           number(4)
                               , aliq_icms      number(6,2)
                               , vl_opr         number(15,2)
                               , vl_bc_icms     number(15,2)
                               , vl_icms        number(15,2)
                               , vl_bc_icms_st  number(15,2)
                               , vl_icms_st     number(15,2)
                               , vl_red_bc      number(15,2)
                               , cod_obs        varchar2(6) );
--
   type t_tab_reg_c790 is table of tab_reg_c790 index by binary_integer;
   type t_bi_tab_reg_c790 is table of t_tab_reg_c790 index by binary_integer;
   vt_bi_tab_reg_c790 t_bi_tab_reg_c790;
--
--| REGISTRO C791: REGISTRO DE INFORMAÇÕES DE ST POR UF (COD 06)
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_c791 is record ( reg            varchar2(4)
                               , uf             varchar2(2)
                               , vl_bc_icms_st  number(15,2)
                               , vl_icms_st     number(15,2) );
--
   type t_tab_reg_c791 is table of tab_reg_c791 index by binary_integer;
   type t_bi_tab_reg_c791 is table of t_tab_reg_c791 index by binary_integer;
   type t_tri_tab_reg_c791 is table of t_bi_tab_reg_c791 index by binary_integer;
   vt_tri_tab_reg_c791 t_tri_tab_reg_c791;
--
--| REGISTRO C800: CUPOM FISCAL ELETRÔNICO ¿ SAT (CF-E-SAT) (CÓDIGO 59)
   -- Nível hierárquico: 2
   -- Ocorrência: Vários
   type tab_reg_c800 is record ( reg              varchar2(4)
                               , cod_mod          varchar2(2)
                               , cod_sit          number(2)
                               , num_cfe          number(6)
                               , dt_doc           date
                               , vl_cfe           number(15,2)
                               , vl_pis           number(15,2)
                               , vl_cofins        number(15,2)
                               , cnpj_cpf         varchar2(14)
                               , nr_sat           number(9)
                               , chv_cfe          varchar2(44)
                               , vl_desc          number(15,2)
                               , vl_merc          number(15,2)
                               , vl_out_da        number(15,2)
                               , vl_icms          number(15,2)
                               , vl_pis_st        number(15,2)
                               , vl_cofins_st     number(15,2) );
--
   type t_tab_reg_c800 is table of tab_reg_c800 index by binary_integer;
   vt_tab_reg_c800 t_tab_reg_c800;
--
--| REGISTRO C850: REGISTRO ANALÍTICO DO CF-E-SAT (CODIGO 59)
   -- Nível hierárquico: 3
   -- Ocorrência - 1:N
   type tab_reg_c850 is record ( reg           varchar2(4)
                               , cst_icms      varchar2(3)
                               , cfop          number(4)
                               , aliq_icms     number(6,2)
                               , vl_opr        number(15,2)
                               , vl_bc_icms    number(15,2)
                               , vl_icms       number(15,2)
                               , cod_obs       varchar2(6) );
--
   type t_tab_reg_c850 is table of tab_reg_c850 index by binary_integer;
   type t_bi_tab_reg_c850 is table of t_tab_reg_c850 index by binary_integer;
   vt_bi_tab_reg_c850 t_bi_tab_reg_c850;
--
--| REGISTRO C860: IDENTIFICAÇÃO DO EQUIPAMENTO SAT-CF-E
   -- Nível hierárquico: 2
   -- Ocorrência: 1:N
   type tab_reg_c860 is record ( reg        varchar2(4)
                               , cod_mod    varchar2(2)
                               , nr_sat     number(9)
                               , dt_doc     date
                               , doc_ini    number(6)
                               , doc_fim    number(6) );
--
   type t_tab_reg_c860 is table of tab_reg_c860 index by binary_integer;
   vt_tab_reg_c860 t_tab_reg_c860;
--
--| REGISTRO C890: RESUMO DIÁRIO DO CF-E-SAT (CÓDIGO 59) POR EQUIPAMENTO SAT-CF-E
   -- Nível hierárquico: 3
   -- Ocorrência - 1:N
   type tab_reg_c890 is record ( reg           varchar2(4)
                               , cst_icms      number(3)
                               , cfop          number(4)
                               , aliq_icms     number(6,2)
                               , vl_opr        number(15,2)
                               , vl_bc_icms    number(15,2)
                               , vl_icms       number(15,2)
                               , cod_obs       varchar2(6) );
--
   type t_tab_reg_c890 is table of tab_reg_c890 index by binary_integer;
   type t_bi_tab_reg_c890 is table of t_tab_reg_c890 index by binary_integer;
   vt_bi_tab_reg_c890 t_bi_tab_reg_c890;
--
--| REGISTRO C990: ENCERRAMENTO DO BLOCO C
   -- Nível hierárquico - 1
   -- Ocorrência ¿ um por arquivo
   type tab_reg_c990 is record ( reg        varchar2(4)
                               , qtd_lin_c  number );
--
   type t_tab_reg_c990 is table of tab_reg_c990 index by binary_integer;
   vt_tab_reg_c990 t_tab_reg_c990;
--
-- BLOCO D: DOCUMENTOS FISCAIS II - SERVIÇOS (ICMS).
--
--| REGISTRO D001: ABERTURA DO BLOCO D
   -- Nível hierárquico - 1
   -- Ocorrência - um por arquivo
   type tab_reg_d001 is record ( reg      varchar2(4)
                               , ind_mov  number(1) );
--
   type t_tab_reg_d001 is table of tab_reg_d001 index by binary_integer;
   vt_tab_reg_d001 t_tab_reg_d001;
--
--| REGISTRO D100: NOTA FISCAL DE SERVIÇO DE TRANSPORTE (CÓDIGO 07) E CONHECIMENTOS DE TRANSPORTE RODOVIÁRIO DE CARGAS (CÓDIGO 08), CONHECIMENTOS DE TRANSPORTE DE CARGAS AVULSO (CÓDIGO 8B), AQUAVIÁRIO DE CARGAS (CÓDIGO 09), AÉREO (CÓDIGO 10), FERROVIÁRIO DE CARGAS (CÓDIGO 11) E MULTIMODAL DE CARGAS (CÓDIGO 26), NOTA FISCAL DE TRANSPORTE FERROVIÁRIO DE CARGA ( CÓDIGO 27) E CONHECIMENTO DE TRANSPORTE ELETRÔNICO ¿ CT-e (CÓDIGO 57 e 67).
   -- Nível hierárquico - 2
   -- Ocorrência ¿vários por Arquivo
   type tab_reg_d100 is record ( reg          varchar2(4)
                               , ind_oper     number(1)
                               , ind_emit     number(1)
                               , cod_part     varchar2(60)
                               , cod_mod      varchar2(2)
                               , cod_sit      varchar2(2)
                               , ser          varchar2(3)
                               , sub          number(3)
                               , num_doc      number(9)
                               , chv_cte      varchar2(44)
                               , dt_doc       date
                               , dt_a_p       date
                               , tp_cte       number(1)
                               , chv_cte_ref  varchar2(44)
                               , vl_doc       number(15,2)
                               , vl_desc      number(15,2)
                               , ind_frt      number(1)
                               , vl_serv      number(15,2)
                               , vl_bc_icms   number(15,2)
                               , vl_icms      number(15,2)
                               , vl_nt        number(15,2)
                               , cod_inf      varchar2(6)
                               , cod_cta      varchar2(255)
                               , cod_mun_orig number(7)
                               , cod_mun_dest number(7) );
--
   type t_tab_reg_d100 is table of tab_reg_d100 index by binary_integer;
   vt_tab_reg_d100 t_tab_reg_d100;
--
--| REGISTRO D110: ITENS DO DOCUMENTO - NOTA FISCAL DE SERVIÇOS DE TRANSPORTE (CÓDIGO 07)
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_d110 is record ( reg         varchar2(4)
                               , num_item    number(3)
                               , cod_item    varchar2(60)
                               , vl_serv     number(15,2)
                               , vl_out      number(15,2) );
--
   type t_tab_reg_d110 is table of tab_reg_d110 index by binary_integer;
   type t_bi_tab_reg_d110 is table of t_tab_reg_d110 index by binary_integer;
   vt_bi_tab_reg_d110 t_bi_tab_reg_d110;
--
--| REGISTRO D120: COMPLEMENTO DA NOTA FISCAL DE SERVIÇOS DE TRANSPORTE (CÓDIGO 07)
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_d120 is record ( reg           varchar2(4)
                               , cod_mun_orig  number(7)
                               , cod_mun_dest  number(7)
                               , veic_id       varchar2(7)
                               , uf_id         varchar2(2) );
--
   type t_tab_reg_d120 is table of tab_reg_d120 index by binary_integer;
   type t_bi_tab_reg_d120 is table of t_tab_reg_d120 index by binary_integer;
   type t_tri_tab_reg_d120 is table of t_bi_tab_reg_d120 index by binary_integer;
   vt_tri_tab_reg_d120 t_tri_tab_reg_d120;
--
--| REGISTRO D130: COMPLEMENTO DO CONHECIMENTO RODOVIÁRIO DE CARGAS (CÓDIGO 08) E DO CONHECIMENTO RODOVIÁRIO DE CARGAS AVULSO (CÓDIGO 8B)
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_d130 is record ( reg             varchar2(4)
                               , cod_part_consg  varchar2(60)
                               , cod_part_red    varchar2(60)
                               , ind_frt_red     number(1)
                               , cod_mun_orig    number(7)
                               , cod_mun_dest    number(7)
                               , veic_id         varchar2(7)
                               , vl_liq_frt      number(15,2)
                               , vl_sec_cat      number(15,2)
                               , vl_desp         number(15,2)
                               , vl_pedg         number(15,2)
                               , vl_out          number(15,2)
                               , vl_frt          number(15,2)
                               , uf_id           varchar2(2) );
--
   type t_tab_reg_d130 is table of tab_reg_d130 index by binary_integer;
   type t_bi_tab_reg_d130 is table of t_tab_reg_d130 index by binary_integer;
   vt_bi_tab_reg_d130 t_bi_tab_reg_d130;
--
--| REGISTRO D140: COMPLEMENTO DO CONHECIMENTO AQUAVIÁRIO DE CARGAS (CÓDIGO 09).
   -- Nível hierárquico - 3
   -- Ocorrência - 1:1
   type tab_reg_d140 is record ( reg               varchar2(4)
                               , cod_part_consg    varchar2(60)
                               , cod_mun_orig      number(7)
                               , cod_mun_dest      number(7)
                               , ind_veic          number(1)
                               , veic_id           varchar2(255)
                               , ind_nav           number(1)
                               , viagem            number
                               , vl_frt_liq        number(15,2)
                               , vl_desp_port      number(15,2)
                               , vl_desp_car_desc  number(15,2)
                               , vl_out            number(15,2)
                               , vl_frt_brt        number(15,2)
                               , vl_frt_mm         number(15,2) );
--
   type t_tab_reg_d140 is table of tab_reg_d140 index by binary_integer;
   type t_bi_tab_reg_d140 is table of t_tab_reg_d140 index by binary_integer;
   vt_bi_tab_reg_d140 t_bi_tab_reg_d140;
--
--| REGISTRO D150: COMPLEMENTO DO CONHECIMENTO AÉREO (CÓDIGO 10)
   -- Nível hierárquico - 3
   -- Ocorrência - 1:1
   type tab_reg_d150 is record ( reg           varchar2(4)
                               , cod_mun_orig  number(7)
                               , cod_mun_dest  number(7)
                               , veic_id       varchar2(255)
                               , viagem        number
                               , ind_tfa       number(1)
                               , vl_peso_tx    number(15,2)
                               , vl_tx_terr    number(15,2)
                               , vl_tx_red     number(15,2)
                               , vl_out        number(15,2)
                               , vl_tx_adv     number(15,2) );
--
   type t_tab_reg_d150 is table of tab_reg_d150 index by binary_integer;
   type t_bi_tab_reg_d150 is table of t_tab_reg_d150 index by binary_integer;
   vt_bi_tab_reg_d150 t_bi_tab_reg_d150;
--
--| REGISTRO D160: CARGA TRANSPORTADA (CÓDIGO 08, 8B, 09, 10, 11, 26 e 27)
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_d160 is record ( reg            varchar2(4)
                               , despacho       varchar2(255)
                               , cnpj_cpf_rem   varchar2(14)
                               , ie_rem         varchar2(14)
                               , cod_mun_ori    number(7)
                               , cnpj_cfp_dest  varchar2(14)
                               , ie_dest        varchar2(14)
                               , cod_mun_dest   number(7) );
--
   type t_tab_reg_d160 is table of tab_reg_d160 index by binary_integer;
   type t_bi_tab_reg_d160 is table of t_tab_reg_d160 index by binary_integer;
   vt_bi_tab_reg_d160 t_bi_tab_reg_d160;
--
--| REGISTRO D161: LOCAL DA COLETA E ENTREGA (CÓDIGO 08, 8B, 09, 10, 11 e 26)
   -- Nível hierárquico - 4
   -- Ocorrência - 1:1
   type tab_reg_d161 is record ( reg            varchar2(4)
                               , ind_carga      number(1)
                               , cnpj_cpf_col   varchar2(14)
                               , ie_col         varchar2(14)
                               , cod_mun_col    number(7)
                               , cnpj_cpf_entg  varchar2(14)
                               , ie_entg        varchar2(14)
                               , cod_mun_entg   number(7) );
--
   type t_tab_reg_d161 is table of tab_reg_d161 index by binary_integer;
   type t_bi_tab_reg_d161 is table of t_tab_reg_d161 index by binary_integer;
   type t_tri_tab_reg_d161 is table of t_bi_tab_reg_d161 index by binary_integer;
   vt_tri_tab_reg_d161 t_tri_tab_reg_d161;
--
--| REGISTRO D162: IDENTIFICAÇÃO DOS DOCUMENTOS FISCAIS (CÓDIGOS 08, 8B, 09, 10, 11, 26 E 27)
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_d162 is record ( reg            varchar2(4)
                               , cod_mod        varchar2(2)
                               , ser            varchar2(4)
                               , num_doc        number(9)
                               , dt_doc         date
                               , vl_doc         number(15,2)
                               , vl_merc        number(15,2)
                               , qtd_vol        number
                               , peso_btr       number(15,2)
                               , peso_liq       number(15,2) );
--
   type t_tab_reg_d162 is table of tab_reg_d162 index by binary_integer;
   type t_bi_tab_reg_d162 is table of t_tab_reg_d162 index by binary_integer;
   type t_tri_tab_reg_d162 is table of t_bi_tab_reg_d162 index by binary_integer;
   vt_tri_tab_reg_d162 t_tri_tab_reg_d162;
--
--| REGISTRO D170: COMPLEMENTO DO CONHECIMENTO MULTIMODAL DE CARGAS (CÓDIGO 26)
   -- Nível hierárquico - 3
   -- Ocorrência - 1:1
   type tab_reg_d170 is record ( reg             varchar2(4)
                               , cod_part_consg  varchar2(60)
                               , cod_part_red    varchar2(60)
                               , cod_mun_orig    number(7)
                               , cod_mun_dest    number(7)
                               , otm             varchar2(255)
                               , ind_nat_frt     number(1)
                               , vl_liq_frt      number(15,2)
                               , vl_gris         number(15,2)
                               , vl_pdg          number(15,2)
                               , vl_out          number(15,2)
                               , vl_frt          number(15,2)
                               , veic_id         varchar2(7)
                               , uf_id           varchar2(2) );
--
   type t_tab_reg_d170 is table of tab_reg_d170 index by binary_integer;
   type t_bi_tab_reg_d170 is table of t_tab_reg_d170 index by binary_integer;
   vt_bi_tab_reg_d170 t_bi_tab_reg_d170;
--
--| REGISTRO D180: MODAIS (CÓDIGO 26)
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_d180 is record ( reg             varchar2(4)
                               , num_seq         number
                               , ind_emit        number(1)
                               , cnpj_cpf_emit   varchar2(14)
                               , uf_emit         varchar2(2)
                               , ie_emit         varchar2(14)
                               , cod_mun_orig    number(7)
                               , cnpj_cpf_tom    varchar2(14)
                               , uf_tom          varchar2(2)
                               , ie_tom          varchar2(14)
                               , cod_mun_dest    number(7)
                               , cod_mod         varchar2(2)
                               , ser             varchar2(4)
                               , sub             number(3)
                               , num_doc         number(9)
                               , dt_doc          date
                               , vl_doc          number(15,2) );
--
   type t_tab_reg_d180 is table of tab_reg_d180 index by binary_integer;
   type t_bi_tab_reg_d180 is table of t_tab_reg_d180 index by binary_integer;
   vt_bi_tab_reg_d180 t_bi_tab_reg_d180;
--
--
--| REGISTRO D190: REGISTRO ANALÍTICO DOS DOCUMENTOS (CÓDIGO 07, 08, 8B, 09, 10, 11, 26, 27, 57 e 67)
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_d190 is record ( reg         varchar2(4)
                               , cst_icms    varchar2(3)
                               , cfop        number(4)
                               , aliq_icms   number(6,2)
                               , vl_opr      number(15,2)
                               , vl_bc_icms  number(15,2)
                               , vl_icms     number(15,2)
                               , vl_red_bc   number(15,2)
                               , cod_obs     varchar2(6) );
--
   type t_tab_reg_d190 is table of tab_reg_d190 index by binary_integer;
   type t_bi_tab_reg_d190 is table of t_tab_reg_d190 index by binary_integer;
   vt_bi_tab_reg_d190 t_bi_tab_reg_d190;
--
--| REGISTRO D195: OBSERVAÇÕES DO LANÇAMENTO FISCAL
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_d195 is record ( reg         varchar2(4)
                               , cod_obs     varchar2(6)
                               , txt_compl   varchar2(255));
--
   type t_tab_reg_d195 is table of tab_reg_d195 index by binary_integer;
   type t_bi_tab_reg_d195 is table of t_tab_reg_d195 index by binary_integer;
   vt_bi_tab_reg_d195 t_bi_tab_reg_d195;
--
--| REGISTRO D197: OUTRAS OBRIGAÇÕES TRIBUTÁRIAS, AJUSTES E INFORMAÇÕES DE VALORES PROVENIENTES DE DOCUMENTO FISCAL
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_d197 is record ( reg            varchar2(4)
                               , cod_aj         varchar2(10)
                               , descr_compl_aj varchar2(255)
                               , cod_item       varchar2(60)
                               , vl_bc_icms     number(15,2)
                               , aliq_icms      number(5,2)
                               , vl_icms        number(15,2)
                               , vl_outros      number(15,2) );
--
   type t_tab_reg_d197 is table of tab_reg_d197 index by binary_integer;
   type t_bi_tab_reg_d197 is table of t_tab_reg_d197 index by binary_integer;
   type t_tri_tab_reg_d197 is table of t_bi_tab_reg_d197 index by binary_integer;
   vt_tri_tab_reg_d197 t_tri_tab_reg_d197;
--
--| REGISTRO D300: REGISTRO ANALÍTICO DOS BILHETES CONSOLIDADOS DE PASSAGEM RODOVIÁRIO (CÓDIGO 13), DE PASSAGEM AQUAVIÁRIO (CÓDIGO 14), DE PASSAGEM E NOTA DE BAGAGEM (CÓDIGO 15) E DE PASSAGEM FERROVIÁRIO (CÓDIGO 16)
   -- Nível hierárquico - 2
   -- Ocorrência ¿vários por Arquivo
   type tab_reg_d300 is record ( reg           varchar2(4)
                               , cod_mod       varchar2(2)
                               , ser           varchar2(4)
                               , sub           number(4)
                               , num_doc_ini   number(6)
                               , num_doc_fin   number(6)
                               , cst_icms      varchar2(3)
                               , cfop          number(4)
                               , aliq_icms     number(6,2)
                               , dt_doc        date
                               , vl_opr        number(15,2)
                               , vl_desc       number(15,2)
                               , vl_serv       number(15,2)
                               , vl_seg        number(15,2)
                               , vl_out_desp   number(15,2)
                               , vl_bc_icms    number(15,2)
                               , vl_icms       number(15,2)
                               , vl_red_bc     number(15,2)
                               , cod_obs       varchar2(6)
                               , cod_cta       varchar2(255) );
--
   type t_tab_reg_d300 is table of tab_reg_d300 index by binary_integer;
   vt_tab_reg_d300 t_tab_reg_d300;
--
--| REGISTRO D301: DOCUMENTOS CANCELADOS DOS BILHETES DE PASSAGEM RODOVIÁRIO (CÓDIGO 13), DE PASSAGEM AQUAVIÁRIO (CÓDIGO 14), DE PASSAGEM E NOTA DE BAGAGEM (CÓDIGO 15) E DE PASSAGEM FERROVIÁRIO (CÓDIGO 16)
   -- Nível hierárquico - 3
   -- Ocorrência ¿ 1:N
   type tab_reg_d301 is record ( reg           varchar2(4)
                               , num_doc_canc  number(6) );
--
   type t_tab_reg_d301 is table of tab_reg_d301 index by binary_integer;
   type t_bi_tab_reg_d301 is table of t_tab_reg_d301 index by binary_integer;
   vt_bi_tab_reg_d301 t_bi_tab_reg_d301;
--
--| REGISTRO D310: COMPLEMENTO DOS BILHETES (CÓDIGO 13, 14, 15 E 16)
   -- Nível hierárquico - 3
   -- Ocorrência ¿ 1:N
   type tab_reg_d310 is record ( reg           varchar2(4)
                               , cod_mun_orig  number(7)
                               , vl_serv       number(15,2)
                               , vl_bc_icms    number(15,2)
                               , vl_icms       number(15,2) );
--
   type t_tab_reg_d310 is table of tab_reg_d310 index by binary_integer;
   type t_bi_tab_reg_d310 is table of t_tab_reg_d310 index by binary_integer;
   vt_bi_tab_reg_d310 t_bi_tab_reg_d310;
--
--| REGISTRO D350 EQUIPAMENTO ECF (CÓDIGOS 2E, 13, 14, 15 e 16)
   -- Nível hierárquico - 2
   -- Ocorrência ¿ 1:N
   type tab_reg_d350 is record ( reg           varchar2(4)
                               , cod_mod       varchar2(2)
                               , ecf_mod       varchar2(20)
                               , ecf_fab       varchar2(20)
                               , ecf_cx        number(3) );
--
   type t_tab_reg_d350 is table of tab_reg_d350 index by binary_integer;
   vt_tab_reg_d350 t_tab_reg_d350;
--
--| REGISTRO D355 REDUÇÃO Z (CÓDIGOS 2E, 13, 14, 15 e 16)
   -- Nível hierárquico - 3
   -- Ocorrência ¿ 1:N
   type tab_reg_d355 is record ( reg           varchar2(4)
                               , dt_doc        date
                               , cro           number(3)
                               , crz           number(6)
                               , num_coo_fin   number(9)
                               , gt_fin        number(15,2)
                               , vl_brt        number(15,2) );
--
   type t_tab_reg_d355 is table of tab_reg_d355 index by binary_integer;
   type t_bi_tab_reg_d355 is table of t_tab_reg_d355 index by binary_integer;
   vt_bi_tab_reg_d355 t_bi_tab_reg_d355;
--
--| REGISTRO D360: PIS E COFINS TOTALIZADOS NO DIA (CÓDIGOS 2E, 13, 14, 15 e 16)
   -- Nível hierárquico - 4
   -- Ocorrência ¿ 1:1
   type tab_reg_d360 is record ( reg           varchar2(4)
                               , vl_pis        number(15,2)
                               , vl_cofins     number(15,2) );
--
   type t_tab_reg_d360 is table of tab_reg_d360 index by binary_integer;
   type t_bi_tab_reg_d360 is table of t_tab_reg_d360 index by binary_integer;
   type t_tri_tab_reg_d360 is table of t_bi_tab_reg_d360 index by binary_integer;
   vt_tri_tab_reg_d360 t_tri_tab_reg_d360;
--
--| REGISTRO D365: REGISTRO DOS TOTALIZADORES PARCIAIS DA REDUÇÃO Z (CÓDIGOS 2E, 13, 14, 15 e 16)
   -- Nível hierárquico - 4
   -- Ocorrência - vários por Arquivo
   type tab_reg_d365 is record ( reg           varchar2(4)
                               , cod_tot_par   varchar2(7)
                               , vlr_acum_tot  number(15,2)
                               , nr_tot        number(2)
                               , descr_nr_tot  varchar2(255) );
--
   type t_tab_reg_d365 is table of tab_reg_d365 index by binary_integer;
   type t_bi_tab_reg_d365 is table of t_tab_reg_d365 index by binary_integer;
   type t_tri_tab_reg_d365 is table of t_bi_tab_reg_d365 index by binary_integer;
   vt_tri_tab_reg_d365 t_tri_tab_reg_d365;
--
--| REGISTRO D370: COMPLEMENTO DOS DOCUMENTOS INFORMADOS (CÓDIGOS 13, 14, 15 e 16 e 2E)
   -- Nível hierárquico - 5
   -- Ocorrência ¿ 1:N
   type tab_reg_d370 is record ( reg           varchar2(4)
                               , cod_mun_orig  number(7)
                               , vl_serv       number(15,2)
                               , qtd_bilh      number
                               , vl_bc_icms    number(15,2)
                               , vl_icms       number(15,2) );
--
   type t_tab_reg_d370 is table of tab_reg_d370 index by binary_integer;
   type t_bi_tab_reg_d370 is table of t_tab_reg_d370 index by binary_integer;
   type t_tri_tab_reg_d370 is table of t_bi_tab_reg_d370 index by binary_integer;
   type t_tetra_tab_reg_d370 is table of t_tri_tab_reg_d370 index by binary_integer;
   vt_tetra_tab_reg_d370 t_tetra_tab_reg_d370;
--
--| REGISTRO D390: REGISTRO ANALÍTICO DO MOVIMENTO DIÁRIO (CÓDIGOS 13, 14, 15, 16 E 2E)
   -- Nível hierárquico - 4
   -- Ocorrência ¿ 1:N
   type tab_reg_d390 is record ( reg           varchar2(4)
                               , cst_icms      varchar2(3)
                               , cfop          number(4)
                               , aliq_icms     number(6,2)
                               , vl_opr        number(15,2)
                               , vl_bc_issqn   number(15,2)
                               , aliq_issqn    number(6,2)
                               , vl_issqn      number(15,2)
                               , vl_bc_icms    number(15,2)
                               , vl_icms       number(15,2)
                               , cod_obs       varchar2(6) );
--
   type t_tab_reg_d390 is table of tab_reg_d390 index by binary_integer;
   type t_bi_tab_reg_d390 is table of t_tab_reg_d390 index by binary_integer;
   type t_tri_tab_reg_d390 is table of t_bi_tab_reg_d390 index by binary_integer;
   vt_tri_tab_reg_d390 t_tri_tab_reg_d390;
--
--| REGISTRO D400: RESUMO DE MOVIMENTO DIÁRIO - RMD (CÓDIGO 18)
   -- Nível hierárquico - 2
   -- Ocorrência ¿vários por Arquivo
   type tab_reg_d400 is record ( reg           varchar2(4)
                               , cod_part      varchar2(60)
                               , cod_mod       varchar2(2)
                               , cod_sit       varchar2(2)
                               , ser           varchar2(4)
                               , sub           number(3)
                               , num_doc       number(6)
                               , dt_doc        date
                               , vl_doc        number(15,2)
                               , vl_desc       number(15,2)
                               , vl_serv       number(15,2)
                               , vl_bc_icms    number(15,2)
                               , vl_icms       number(15,2)
                               , vl_pis        number(15,2)
                               , vl_cofins     number(15,2)
                               , cod_cta       varchar2(255) );
--
   type t_tab_reg_d400 is table of tab_reg_d400 index by binary_integer;
   vt_tab_reg_d400 t_tab_reg_d400;
--
--| REGISTRO D410: DOCUMENTOS INFORMADOS (CÓDIGOS 13, 14, 15 E 16)
   -- Nível hierárquico - 3
   -- Ocorrência ¿ 1:N
   type tab_reg_d410 is record ( reg           varchar2(4)
                               , cod_mod       varchar2(2)
                               , ser           varchar2(4)
                               , sub           number(3)
                               , num_doc_ini   number(6)
                               , num_doc_fin   number(6)
                               , dt_doc        date
                               , cst_icms      varchar2(3)
                               , cfop          number(4)
                               , aliq_icms     number(6,2)
                               , vl_opr        number(15,2)
                               , vl_desc       number(15,2)
                               , vl_serv       number(15,2)
                               , vl_bc_icms    number(15,2)
                               , vl_icms       number(15,2) );
--
   type t_tab_reg_d410 is table of tab_reg_d410 index by binary_integer;
   type t_bi_tab_reg_d410 is table of t_tab_reg_d410 index by binary_integer;
   vt_bi_tab_reg_d410 t_bi_tab_reg_d410;
--
--| REGISTRO D411: DOCUMENTOS CANCELADOS DOS DOCUMENTOS INFORMADOS (CÓDIGO 13, 14, 15 e 16)
   -- Nível hierárquico - 4
   -- Ocorrência ¿vários por Arquivo
   type tab_reg_d411 is record ( reg           varchar2(4)
                               , num_doc_canc  number(6) );
--
   type t_tab_reg_d411 is table of tab_reg_d411 index by binary_integer;
   type t_bi_tab_reg_d411 is table of t_tab_reg_d411 index by binary_integer;
   type t_tri_tab_reg_d411 is table of t_bi_tab_reg_d411 index by binary_integer;
   vt_tri_tab_reg_d411 t_tri_tab_reg_d411;
--
--| REGISTRO D420: COMPLEMENTO DOS DOCUMENTOS INFORMADOS (CÓDIGO 13, 14, 15 e 16)
   -- Nível hierárquico - 3
   -- Ocorrência ¿ 1:N
   type tab_reg_d420 is record ( reg           varchar2(4)
                               , cod_mun_orig  number(7)
                               , vl_serv       number(15,2)
                               , vl_bc_icms    number(15,2)
                               , vl_icms       number(15,2) );
--
   type t_tab_reg_d420 is table of tab_reg_d420 index by binary_integer;
   type t_bi_tab_reg_d420 is table of t_tab_reg_d420 index by binary_integer;
   vt_bi_tab_reg_d420 t_bi_tab_reg_d420;
--
--| REGISTRO D500: NOTA FISCAL DE SERVIÇO DE COMUNICAÇÃO (CÓDIGO 21) E NOTA FISCAL DE SERVIÇO DE TELECOMUNICAÇÃO (CÓDIGO 22).
   -- Nível hierárquico - 2
   -- Ocorrência ¿vários por Arquivo
   type tab_reg_d500 is record ( reg          varchar2(4)
                               , ind_oper     number(1)
                               , ind_emit     number(1)
                               , cod_part     varchar2(60)
                               , cod_mod      varchar2(2)
                               , cod_sit      varchar2(2)
                               , ser          varchar2(4)
                               , sub          varchar2(3)
                               , num_doc      number(9)
                               , dt_doc       date
                               , dt_a_p       date
                               , vl_doc       number(15,2)
                               , vl_desc      number(15,2)
                               , vl_serv      number(15,2)
                               , vl_serv_nt   number(15,2)
                               , vl_terc      number(15,2)
                               , vl_da        number(15,2)
                               , vl_bc_icms   number(15,2)
                               , vl_icms      number(15,2)
                               , cod_inf      varchar2(6)
                               , vl_pis       number(15,2)
                               , vl_cofins    number(15,2)
                               , cod_cta      varchar2(255)
                               , tp_assinante number(1) );
--
   type t_tab_reg_d500 is table of tab_reg_d500 index by binary_integer;
   vt_tab_reg_d500 t_tab_reg_d500;
--
--| REGISTRO D510: ITENS DO DOCUMENTO ¿ NOTA FISCAL DE SERVIÇO DE COMUNICAÇÃO (CÓDIGO 21) E SERVIÇO DE TELECOMUNICAÇÃO (CÓDIGO 22)
   -- Nível hierárquico - 3
   -- Ocorrência ¿ 1:N
   type tab_reg_d510 is record ( reg            varchar2(4)
                               , num_item       number(3)
                               , cod_item       varchar2(60)
                               , cod_class      varchar2(4)
                               , qtd            number(12,3)
                               , unid           varchar2(6)
                               , vl_item        number(15,2)
                               , vl_desc        number(15,2)
                               , cst_icms       varchar2(3)
                               , cfop           number(4)
                               , vl_bc_icms     number(15,2)
                               , aliq_icms      number(6,2)
                               , vl_icms        number(15,2)
                               , vl_bc_icms_st  number(15,2)
                               , vl_icms_st     number(15,2)
                               , ind_rec        number(1)
                               , cod_part       varchar2(60)
                               , vl_pis         number(15,2)
                               , vl_cofins      number(15,2)
                               , cod_cta        varchar2(255) );
--
   type t_tab_reg_d510 is table of tab_reg_d510 index by binary_integer;
   type t_bi_tab_reg_d510 is table of t_tab_reg_d510 index by binary_integer;
   vt_bi_tab_reg_d510 t_bi_tab_reg_d510;
--
--| REGISTRO D530: TERMINAL FATURADO
   -- Nível hierárquico - 3
   -- Ocorrência ¿ 1:N
   type tab_reg_d530 is record ( reg            varchar2(4)
                               , ind_serv       number(1)
                               , dt_ini_serv    date
                               , dt_fin_serv    date
                               , per_fiscal     varchar2(6)
                               , cod_area       varchar2(255)
                               , terminal       number );
--
   type t_tab_reg_d530 is table of tab_reg_d530 index by binary_integer;
   type t_bi_tab_reg_d530 is table of t_tab_reg_d530 index by binary_integer;
   vt_bi_tab_reg_d530 t_bi_tab_reg_d530;
--
--| REGISTRO D590: REGISTRO ANALÍTICO DO DOCUMENTO (CÓDIGO 21 E 22).
   -- Nível hierárquico - 3
   -- Ocorrência ¿ 1:N
   type tab_reg_d590 is record ( reg            varchar2(4)
                               , cst_icms       varchar2(3)
                               , cfop           number(4)
                               , aliq_icms      number(6,2)
                               , vl_opr         number(15,2)
                               , vl_bc_icms     number(15,2)
                               , vl_icms        number(15,2)
                               , vl_bc_icms_st  number(15,2)
                               , vl_icms_st     number(15,2)
                               , vl_red_bc      number(15,2)
                               , cod_obs        varchar2(6) );
--
   type t_tab_reg_d590 is table of tab_reg_d590 index by binary_integer;
   type t_bi_tab_reg_d590 is table of t_tab_reg_d590 index by binary_integer;
   vt_bi_tab_reg_d590 t_bi_tab_reg_d590;
--
--| REGISTRO D600: CONSOLIDAÇÃO DA PRESTAÇÃO DE SERVIÇOS - NOTAS DE SERVIÇO DE COMUNICAÇÃO (CÓDIGO 21) E DE SERVIÇO DE TELECOMUNICAÇÃO (CÓDIGO 22)
   -- Nível hierárquico - 2
   -- Ocorrência ¿vários por Arquivo
   type tab_reg_d600 is record ( reg            varchar2(4)
                               , cod_mod        varchar2(2)
                               , cod_mun        number(7)
                               , ser            varchar2(4)
                               , sub            number(3)
                               , cod_cons       varchar2(2)
                               , qtd_cons       number
                               , dt_doc         date
                               , vl_doc         number(15,2)
                               , vl_desc        number(15,2)
                               , vl_serv        number(15,2)
                               , vl_serv_nt     number(15,2)
                               , vl_terc        number(15,2)
                               , vl_da          number(15,2)
                               , vl_bc_icms     number(15,2)
                               , vl_icms        number(15,2)
                               , vl_pis         number(15,2)
                               , vl_cofins      number(15,2) );
--
   type t_tab_reg_d600 is table of tab_reg_d600 index by binary_integer;
   vt_tab_reg_d600 t_tab_reg_d600;
--
--| REGISTRO D610: ITENS DO DOCUMENTO CONSOLIDADO (CÓDIGO 21 E 22)
   -- Nível hierárquico - 3
   -- Ocorrência ¿ 1:N
   type tab_reg_d610 is record ( reg            varchar2(4)
                               , cod_class      varchar2(4)
                               , cod_item       varchar2(60)
                               , qtd            number(12,3)
                               , unid           varchar2(6)
                               , vl_item        number(15,2)
                               , vl_desc        number(15,2)
                               , cst_icms       varchar2(3)
                               , cfop           number(4)
                               , aliq_icms      number(6,2)
                               , vl_bc_icms     number(15,2)
                               , vl_icms        number(15,2)
                               , vl_bc_icms_st  number(15,2)
                               , vl_icms_st     number(15,2)
                               , vl_red_bc      number(15,2)
                               , vl_pis         number(15,2)
                               , vl_cofins      number(15,2)
                               , cod_cta        varchar2(255) );
--
   type t_tab_reg_d610 is table of tab_reg_d610 index by binary_integer;
   type t_bi_tab_reg_d610 is table of t_tab_reg_d610 index by binary_integer;
   vt_bi_tab_reg_d610 t_bi_tab_reg_d610;
--
--| REGISTRO D690: REGISTRO ANALÍTICO DOS DOCUMENTOS (CÓDIGOS 21 e 22)
   -- Nível hierárquico - 3
   -- Ocorrência ¿ 1:N
   type tab_reg_d690 is record ( reg            varchar2(4)
                               , cst_icms       varchar2(3)
                               , cfop           number(4)
                               , aliq_icms      number(6,2)
                               , vl_opr         number(15,2)
                               , vl_bc_icms     number(15,2)
                               , vl_icms        number(15,2)
                               , vl_bc_icms_st  number(15,2)
                               , vl_icms_st     number(15,2)
                               , vl_red_bc      number(15,2)
                               , cod_obs        varchar2(6) );
--
   type t_tab_reg_d690 is table of tab_reg_d690 index by binary_integer;
   type t_bi_tab_reg_d690 is table of t_tab_reg_d690 index by binary_integer;
   vt_bi_tab_reg_d690 t_bi_tab_reg_d690;
--
--| REGISTRO D695: CONSOLIDAÇÃO DA PRESTAÇÃO DE SERVIÇOS - NOTAS DE SERVIÇO DE COMUNICAÇÃO (CÓDIGO 21) E DE SERVIÇO DE TELECOMUNICAÇÃO (CÓDIGO 22)
   -- Nível hierárquico - 2
   -- Ocorrência ¿vários por Arquivo
   type tab_reg_d695 is record ( reg            varchar2(4)
                               , cod_mod        varchar2(2)
                               , ser            varchar2(4)
                               , nro_ord_ini    number(9)
                               , nro_ord_fin    number(9)
                               , dt_doc_ini     date
                               , dt_doc_fin     date
                               , nom_mest       varchar2(15)
                               , chv_cod_dig    varchar2(32) );
--
   type t_tab_reg_d695 is table of tab_reg_d695 index by binary_integer;
   vt_tab_reg_d695 t_tab_reg_d695;
--
--| REGISTRO D696: REGISTRO ANALÍTICO DOS DOCUMENTOS (CÓDIGO 21 E 22)
   -- Nível hierárquico - 3
   -- Ocorrência ¿ 1:N
   type tab_reg_d696 is record ( reg            varchar2(4)
                               , cst_icms       varchar2(3)
                               , cfop           number(4)
                               , aliq_icms      number(6,2)
                               , vl_opr         number(15,2)
                               , vl_bc_icms     number(15,2)
                               , vl_icms        number(15,2)
                               , vl_bc_icms_st  number(15,2)
                               , vl_icms_st     number(15,2)
                               , vl_red_bc      number(15,2)
                               , cod_obs        varchar2(6) );
--
   type t_tab_reg_d696 is table of tab_reg_d696 index by binary_integer;
   type t_bi_tab_reg_d696 is table of t_tab_reg_d696 index by binary_integer;
   vt_bi_tab_reg_d696 t_bi_tab_reg_d696;
--
--| REGISTRO D697: REGISTRO DE INFORMAÇÕES DE OUTRAS UFs, RELATIVAMENTE AOS SERVIÇOS ¿NÃO-MEDIDOS¿ DE TELEVISÃO POR ASSINATURA VIA SATÉLITE.
   -- Nível hierárquico - 4
   -- Ocorrência ¿ 1:N
   type tab_reg_d697 is record ( reg            varchar2(4)
                               , uf             varchar2(2)
                               , vl_bc_icms_st  number(15,2)
                               , vl_icms_st     number(15,2) );
--
   type t_tab_reg_d697 is table of tab_reg_d697 index by binary_integer;
   type t_bi_tab_reg_d697 is table of t_tab_reg_d697 index by binary_integer;
   type t_tri_tab_reg_d697 is table of t_bi_tab_reg_d697 index by binary_integer;
   vt_tri_tab_reg_d697 t_tri_tab_reg_d697;
--
--| REGISTRO D990: ENCERRAMENTO DO BLOCO D.
   -- Nível hierárquico - 1
   -- Ocorrência ¿ um por arquivo
   type tab_reg_d990 is record ( reg        varchar2(4)
                               , qtd_lin_d  number );
--
   type t_tab_reg_d990 is table of tab_reg_d990 index by binary_integer;
   vt_tab_reg_d990 t_tab_reg_d990;
--
-- BLOCO E: APURAÇÃO DO ICMS E DO IPI
--
--| REGISTRO E001: ABERTURA DO BLOCO E
   -- Nível hierárquico - 1
   -- Ocorrência ¿ um por Arquivo
   type tab_reg_e001 is record ( reg      varchar2(4)
                               , ind_mov  number(1) );
--
   type t_tab_reg_e001 is table of tab_reg_e001 index by binary_integer;
   vt_tab_reg_e001 t_tab_reg_e001;
--
--| REGISTRO E100: PERÍODO DA APURAÇÃO DO ICMS
   -- Nível hierárquico ¿ 2
   -- Ocorrência ¿ 1:N
   type tab_reg_e100 is record ( reg     varchar2(4)
                               , dt_ini  date
                               , dt_fin  date );
--
   type t_tab_reg_e100 is table of tab_reg_e100 index by binary_integer;
   vt_tab_reg_e100 t_tab_reg_e100;
--
--| REGISTRO E110: APURAÇÃO DO ICMS ¿ OPERAÇÕES PRÓPRIAS
   -- Nível hierárquico ¿ 3 ¿ registro obrigatório
   -- Ocorrência ¿ um por período
   type tab_reg_e110 is record ( reg                        varchar2(4)
                               , vl_tot_debitos             number(15,2)
                               , vl_aj_debitos              number(15,2)
                               , vl_tot_aj_debitos          number(15,2)
                               , vl_estornos_cred           number(15,2)
                               , vl_tot_creditos            number(15,2)
                               , vl_aj_creditos             number(15,2)
                               , vl_tot_aj_creditos         number(15,2)
                               , vl_estornos_deb            number(15,2)
                               , vl_sld_credor_ant          number(15,2)
                               , vl_sld_apurado             number(15,2)
                               , vl_tot_ded                 number(15,2)
                               , vl_icms_recolher           number(15,2)
                               , vl_sld_credor_transportar  number(15,2)
                               , deb_esp                    number(15,2) );
--
   type t_tab_reg_e110 is table of tab_reg_e110 index by binary_integer;
   vt_tab_reg_e110 t_tab_reg_e110;
--
--| REGISTRO E111: AJUSTE/BENEFÍCIO/INCENTIVO DA APURAÇÃO DO ICMS.
   -- Nível hierárquico ¿ 4
   -- Ocorrência ¿ 1:N
   type tab_reg_e111 is record ( reg             varchar2(4)
                               , cod_aj_apur     varchar2(8)
                               , descr_compl_aj  varchar2(255)
                               , vl_aj_apur      number(15,2) );
--
   type t_tab_reg_e111 is table of tab_reg_e111 index by binary_integer;
   type t_bi_tab_reg_e111 is table of t_tab_reg_e111 index by binary_integer;
   vt_bi_tab_reg_e111 t_bi_tab_reg_e111;
--
--| REGISTRO E112: INFORMAÇÕES ADICIONAIS DOS AJUSTES DA APURAÇÃO DO ICMS
   -- Nível hierárquico ¿ 5
   -- Ocorrência ¿ 1:N
   type tab_reg_e112 is record ( reg        varchar2(4)
                               , num_da     varchar2(255)
                               , num_proc   varchar2(15)
                               , ind_proc   number(1)
                               , proc       varchar2(255)
                               , txt_compl  varchar2(255) );
--
   type t_tab_reg_e112 is table of tab_reg_e112 index by binary_integer;
   type t_bi_tab_reg_e112 is table of t_tab_reg_e112 index by binary_integer;
   type t_tri_tab_reg_e112 is table of t_bi_tab_reg_e112 index by binary_integer;
   vt_tri_tab_reg_e112 t_tri_tab_reg_e112;
--
--| REGISTRO E113: INFORMAÇÕES ADICIONAIS DOS AJUSTES DA APURAÇÃO DO ICMS ¿ IDENTIFICAÇÃO DOS DOCUMENTOS FISCAIS.
   -- Nível hierárquico - 5
   -- Ocorrência ¿ 1:N
   type tab_reg_e113 is record ( reg         varchar2(4)
                               , cod_part    varchar2(60)
                               , cod_mod     varchar2(2)
                               , ser         varchar2(3)
                               , sub         number(3)
                               , num_doc     number(9)
                               , dt_doc      date
                               , cod_item    varchar2(60)
                               , vl_aj_item  number(15,2)
                               , chv_doce    varchar2(44)
                               );
--
   type t_tab_reg_e113 is table of tab_reg_e113 index by binary_integer;
   type t_bi_tab_reg_e113 is table of t_tab_reg_e113 index by binary_integer;
   type t_tri_tab_reg_e113 is table of t_bi_tab_reg_e113 index by binary_integer;
   vt_tri_tab_reg_e113 t_tri_tab_reg_e113;
--
--| REGISTRO E115: INFORMAÇÕES ADICIONAIS DA APURAÇÃO ¿ VALORES DECLARATÓRIOS
   -- Nível hierárquico - 4
   -- Ocorrência ¿ 1:N
   type tab_reg_e115 is record ( reg             varchar2(4)
                               , cod_inf_adic    varchar2(8)
                               , vl_inf_adic     number(15,2)
                               , descr_compl_aj  varchar2(255) );
--
   type t_tab_reg_e115 is table of tab_reg_e115 index by binary_integer;
   type t_bi_tab_reg_e115 is table of t_tab_reg_e115 index by binary_integer;
   vt_bi_tab_reg_e115 t_bi_tab_reg_e115;
--
--| REGISTRO E116: OBRIGAÇÕES DO ICMS A RECOLHER ¿ OPERAÇÕES PRÓPRIAS
   -- Nível hierárquico - 4
   -- Ocorrência ¿ 1:N
   type tab_reg_e116 is record ( reg          varchar2(4)
                               , cod_or       varchar2(3)
                               , vl_or        number(15,2)
                               , dt_vcto      date
                               , cod_rec      varchar2(255)
                               , num_proc     varchar2(15)
                               , ind_proc     number(1)
                               , proc         varchar2(255)
                               , txt_compl    varchar2(255)
                               , mes_ref      varchar2(6) );
--
   type t_tab_reg_e116 is table of tab_reg_e116 index by binary_integer;
   type t_bi_tab_reg_e116 is table of t_tab_reg_e116 index by binary_integer;
   vt_bi_tab_reg_e116 t_bi_tab_reg_e116;
--
--| REGISTRO E200: PERÍODO DA APURAÇÃO DO ICMS - SUBSTITUIÇÃO TRIBUTÁRIA
   -- Nível hierárquico - 2
   -- Ocorrência ¿ 1:N
   type tab_reg_e200 is record ( reg     varchar2(4)
                               , uf      varchar2(2)
                               , dt_ini  date
                               , dt_fin  date );
--
   type t_tab_reg_e200 is table of tab_reg_e200 index by binary_integer;
   vt_tab_reg_e200 t_tab_reg_e200;
--
--| REGISTRO E210: APURAÇÃO DO ICMS ¿ SUBSTITUIÇÃO TRIBUTÁRIA
   -- Nível hierárquico - 3
   -- Ocorrência ¿ um por período
   type tab_reg_e210 is record ( reg                         varchar2(4)
                               , ind_mov_st                  number(1)
                               , vl_sld_cred_ant_st          number(15,2)
                               , vl_devol_st                 number(15,2)
                               , vl_ressarc_st               number(15,2)
                               , vl_out_cred_st              number(15,2)
                               , vl_aj_creditos_st           number(15,2)
                               , vl_retencao_st              number(15,2)
                               , vl_out_deb_st               number(15,2)
                               , vl_aj_debitos_st            number(15,2)
                               , vl_sld_dev_ant_st           number(15,2)
                               , vl_deducoes_st              number(15,2)
                               , vl_icms_recol_st            number(15,2)
                               , vl_sld_cred_st_transportar  number(15,2)
                               , deb_esp_st                  number(15,2) );
--
   type t_tab_reg_e210 is table of tab_reg_e210 index by binary_integer;
   vt_tab_reg_e210 t_tab_reg_e210;
--
--| REGISTRO E220: AJUSTE/BENEFÍCIO/INCENTIVO DA APURAÇÃO DO ICMS SUBSTITUIÇÃO TRIBUTÁRIA
   -- Nível hierárquico - 4
   -- Ocorrência ¿ 1:N
   type tab_reg_e220 is record ( reg             varchar2(4)
                               , cod_aj_apur     varchar2(8)
                               , descr_compl_aj  varchar2(255)
                               , vl_aj_apur      number(15,2) );
--
   type t_tab_reg_e220 is table of tab_reg_e220 index by binary_integer;
   type t_bi_tab_reg_e220 is table of t_tab_reg_e220 index by binary_integer;
   vt_bi_tab_reg_e220 t_bi_tab_reg_e220;
--
--| REGISTRO E230: INFORMAÇÕES ADICIONAIS DOS AJUSTES DA APURAÇÃO DO ICMS SUBSTITUIÇÃO TRIBUTÁRIA
   -- Nível hierárquico - 5
   -- Ocorrência ¿ 1:N
   type tab_reg_e230 is record ( reg         varchar2(4)
                               , num_da      varchar2(255)
                               , num_proc    varchar2(15)
                               , ind_proc    number(1)
                               , proc        varchar2(255)
                               , txt_compl   varchar2(255) );
--
   type t_tab_reg_e230 is table of tab_reg_e230 index by binary_integer;
   type t_bi_tab_reg_e230 is table of t_tab_reg_e230 index by binary_integer;
   type t_tri_tab_reg_e230 is table of t_bi_tab_reg_e230 index by binary_integer;
   vt_tri_tab_reg_e230 t_tri_tab_reg_e230;
--
--| REGISTRO E240: INFORMAÇÕES ADICIONAIS DOS AJUSTES DA APURAÇÃO DO ICMS SUBSTITUIÇÃO TRIBUTÁRIA ¿ IDENTIFICAÇÃO DOS DOCUMENTOS FISCAIS
   -- Nível hierárquico - 5
   -- Ocorrência ¿ 1:N
   type tab_reg_e240 is record ( reg         varchar2(4)
                               , cod_part    varchar2(60)
                               , cod_mod     varchar2(2)
                               , ser         varchar2(3)
                               , sub         number(3)
                               , num_doc     number(9)
                               , dt_doc      date
                               , cod_item    varchar2(60)
                               , vl_aj_item  number(15,2)
                               , chv_doce    varchar2(44)
                               );
--
   type t_tab_reg_e240 is table of tab_reg_e240 index by binary_integer;
   type t_bi_tab_reg_e240 is table of t_tab_reg_e240 index by binary_integer;
   type t_tri_tab_reg_e240 is table of t_bi_tab_reg_e240 index by binary_integer;
   vt_tri_tab_reg_e240 t_tri_tab_reg_e240;
--
--| REGISTRO E250: OBRIGAÇÕES DO ICMS A RECOLHER ¿ SUBSTITUIÇÃO TRIBUTÁRIA
   -- Nível hierárquico - 4
   -- Ocorrência ¿ 1:N
   type tab_reg_e250 is record ( reg        varchar2(4)
                               , cod_or     varchar2(3)
                               , vl_or      number(15,2)
                               , dt_vcto    date
                               , cod_rec    varchar2(255)
                               , num_proc   varchar2(15)
                               , ind_proc   number(1)
                               , proc       varchar2(255)
                               , txt_compl  varchar2(255)
                               , mes_ref    varchar2(6) );
--
   type t_tab_reg_e250 is table of tab_reg_e250 index by binary_integer;
   type t_bi_tab_reg_e250 is table of t_tab_reg_e250 index by binary_integer;
   vt_bi_tab_reg_e250 t_bi_tab_reg_e250;

--
--| REGISTRO E300: PERÍODO DE APURAÇÃO DO ICMS DIFERENCIAL DE ALÍQUOTA ¿ UF ORIGEM/DESTINO EC 87/15
   -- Nível hierárquico - 2
   -- Ocorrência ¿ 1:1
   type tab_reg_e300 is record ( reg     varchar2(4)
                               , uf      varchar2(2)
                               , dt_ini  date
                               , dt_fin  date
                               );
--
   type t_tab_reg_e300 is table of tab_reg_e300 index by binary_integer;
   vt_tab_reg_e300 t_tab_reg_e300;
--
--| REGISTRO  E310: APURAÇÃO DO ICMS DIFERENCIAL DE ALÍQUOTA ¿ UF ORIGEM/DESTINO EC 87/15.
   -- Nível hierárquico - 3
   -- Ocorrência ¿ um por período
   type tab_reg_e310 is record ( reg                         varchar2(4)
                               , ind_mov_difal               number(1)
                               , vl_sld_cred_ant_difal       number(15,2)
                               , vl_tot_debitos_difal        number(15,2)
                               , vl_out_deb_difal            number(15,2)
                               , vl_tot_creditos_difal       number(15,2)
                               , vl_out_cred_difal           number(15,2)
                               , vl_sld_dev_ant_difal        number(15,2)
                               , vl_deducoes_difal           number(15,2)
                               , vl_recol                    number(15,2)
                               , vl_sld_cred_transportar     number(15,2)
                               , deb_esp_difal               number(15,2)
                               , vl_sld_cred_ant_fcp         number(15,2)
                               , vl_tot_deb_fcp              number(15,2)
                               , vl_out_deb_fcp              number(15,2)
                               , vl_tot_cred_fcp             number(15,2)
                               , vl_out_cred_fcp             number(15,2)
                               , vl_sld_dev_ant_fcp          number(15,2)
                               , vl_deducoes_fcp             number(15,2)
                               , vl_recol_fcp                number(15,2)
                               , vl_sld_cred_transportar_fcp number(15,2)
                               , deb_esp_fcp                 number(15,2)
                               );
--
   type t_tab_reg_e310 is table of tab_reg_e310 index by binary_integer;
   vt_tab_reg_e310 t_tab_reg_e310;
--
--| REGISTRO E311: AJUSTE/BENEFÍCIO/INCENTIVO DA APURAÇÃO DO ICMS DIFERENCIAL DE ALÍQUOTA UF ORIGEM/DESTINO EC 87/15
   -- Nível hierárquico - 4
   -- Ocorrência ¿ 1:N
   type tab_reg_e311 is record ( reg             varchar2(4)
                               , cod_aj_apur     varchar2(8)
                               , descr_compl_aj  varchar2(255)
                               , vl_aj_apur      number(15,2)
                               );
--
   type t_tab_reg_e311 is table of tab_reg_e311 index by binary_integer;
   type t_bi_tab_reg_e311 is table of t_tab_reg_e311 index by binary_integer;
   vt_bi_tab_reg_e311 t_bi_tab_reg_e311;
--
--| REGISTRO E312: INFORMAÇÕES ADICIONAIS DOS AJUSTES DA APURAÇÃO DO ICMS DIFERENCIAL DE ALÍQUOTA UF ORIGEM/DESTINO EC 87/15.
   -- Nível hierárquico - 5
   -- Ocorrência ¿ 1:N
   type tab_reg_e312 is record ( reg         varchar2(4)
                               , num_da      varchar2(255)
                               , num_proc    varchar2(15)
                               , ind_proc    number(1)
                               , proc        varchar2(255)
                               , txt_compl   varchar2(255)
                               );
--
   type t_tab_reg_e312 is table of tab_reg_e312 index by binary_integer;
   type t_bi_tab_reg_e312 is table of t_tab_reg_e312 index by binary_integer;
   type t_tri_tab_reg_e312 is table of t_bi_tab_reg_e312 index by binary_integer;
   vt_tri_tab_reg_e312 t_tri_tab_reg_e312;
--
--| REGISTRO E313: INFORMAÇÕES ADICIONAIS DOS AJUSTES DA APURAÇÃO DO ICMS DIFERENCIAL DE ALÍQUOTA UF ORIGEM/DESTINO EC 87/15 IDENTIFICAÇÃO DOS DOCUMENTOS FISCAIS
   -- Nível hierárquico - 5
   -- Ocorrência ¿ 1:N
   type tab_reg_e313 is record ( reg         varchar2(4)
                               , cod_part    varchar2(60)
                               , cod_mod     varchar2(2)
                               , ser         varchar2(3)
                               , sub         number(3)
                               , num_doc     number(9)
                               , chv_doce    varchar2(44)
                               , dt_doc      date
                               , cod_item    varchar2(60)
                               , vl_aj_item  number(15,2)
                               );
--
   type t_tab_reg_e313 is table of tab_reg_e313 index by binary_integer;
   type t_bi_tab_reg_e313 is table of t_tab_reg_e313 index by binary_integer;
   type t_tri_tab_reg_e313 is table of t_bi_tab_reg_e313 index by binary_integer;
   vt_tri_tab_reg_e313 t_tri_tab_reg_e313;
--
--| REGISTRO E316: OBRIGAÇÕES DO ICMS RECOLHIDO OU A RECOLHER ¿ DIFERENCIAL DE ALÍQUOTA UF ORIGEM/DESTINO EC 87/15
   -- Nível hierárquico - 4
   -- Ocorrência ¿ 1:N
   type tab_reg_e316 is record ( reg        varchar2(4)
                               , cod_or     varchar2(3)
                               , vl_or      number(15,2)
                               , dt_vcto    date
                               , cod_rec    varchar2(255)
                               , num_proc   varchar2(15)
                               , ind_proc   number(1)
                               , proc       varchar2(255)
                               , txt_compl  varchar2(255)
                               , mes_ref    varchar2(6)
                               );
--
   type t_tab_reg_e316 is table of tab_reg_e316 index by binary_integer;
   type t_bi_tab_reg_e316 is table of t_tab_reg_e316 index by binary_integer;
   vt_bi_tab_reg_e316 t_bi_tab_reg_e316;


--| REGISTRO E500: PERÍODO DE APURAÇÃO DO IPI
   -- Nível hierárquico - 2
   -- Ocorrência ¿um ou vários por Arquivo
   type tab_reg_e500 is record ( reg       varchar2(4)
                               , ind_apur  number(1)
                               , dt_ini    date
                               , dt_fin    date );
--
   type t_tab_reg_e500 is table of tab_reg_e500 index by binary_integer;
   vt_tab_reg_e500 t_tab_reg_e500;
--
--| REGISTRO E510: CONSOLIDAÇÃO DOS VALORES DO IPI
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_e510 is record ( reg          varchar2(4)
                               , cfop         number(4)
                               , cst_ipi      varchar2(2)
                               , vl_cont_ipi  number(15,2)
                               , vl_bc_ipi    number(15,2)
                               , vl_ipi       number(15,2) );
--
   type t_tab_reg_e510 is table of tab_reg_e510 index by binary_integer;
   type t_bi_tab_reg_e510 is table of t_tab_reg_e510 index by binary_integer;
   vt_bi_tab_reg_e510 t_bi_tab_reg_e510;
--
--| REGISTRO E520: APURAÇÃO DO IPI
   -- Nível hierárquico - 3
   -- Ocorrência - 1:1
   type tab_reg_e520 is record ( reg            varchar2(4)
                               , vl_sd_ant_ipi  number(15,2)
                               , vl_deb_ipi     number(15,2)
                               , vl_cred_ipi    number(15,2)
                               , vl_od_ipi      number(15,2)
                               , vl_oc_ipi      number(15,2)
                               , vl_sc_ipi      number(15,2)
                               , vl_sd_ipi      number(15,2) );
--
   type t_tab_reg_e520 is table of tab_reg_e520 index by binary_integer;
   vt_tab_reg_e520 t_tab_reg_e520;
--
--| REGISTRO E530: AJUSTES DA APURAÇÃO DO IPI
   -- Nível hierárquico - 4
   -- Ocorrência ¿ 1:N por Período
   type tab_reg_e530 is record ( reg       varchar2(4)
                               , ind_aj    number(1)
                               , vl_aj     number(15,2)
                               , cod_aj    varchar2(3)
                               , ind_doc   number(1)
                               , num_doc   varchar2(255)
                               , descr_aj  varchar2(255) );
--
   type t_tab_reg_e530 is table of tab_reg_e530 index by binary_integer;
   type t_bi_tab_reg_e530 is table of t_tab_reg_e530 index by binary_integer;
   vt_bi_tab_reg_e530 t_bi_tab_reg_e530;
--
--| REGISTRO E531: INFORMAÇÕES ADICIONAIS DOS AJUSTES DA APURAÇÃO DO IPI ¿ IDENTIFICAÇÃO DOS DOCUMENTOS FISCAIS (01 e 55)
   -- Nível hierárquico - 5
   -- Ocorrência ¿ 1:N por Período
   type tab_reg_e531 is record ( reg        varchar2(4)
                               , cod_part   varchar2(60)
                               , cod_mod    varchar2(2)
                               , ser        varchar2(4)
                               , sub        number(3)
                               , num_doc    number(9)
                               , dt_doc     date
                               , cod_item   varchar2(60)
                               , vl_aj_item number(15,2)
                               , chv_nfe    varchar2(44) );
--
   type t_tab_reg_e531 is table of tab_reg_e531 index by binary_integer;
   type t_bi_tab_reg_e531 is table of t_tab_reg_e531 index by binary_integer;
   type t_tri_tab_reg_e531 is table of t_bi_tab_reg_e531 index by binary_integer;
   vt_tri_tab_reg_e531 t_tri_tab_reg_e531;
--
--| REGISTRO E990: ENCERRAMENTO DO BLOCO E
   -- Nível hierárquico - 1
   -- Ocorrência ¿ um por Arquivo
   type tab_reg_e990 is record ( reg        varchar2(4)
                               , qtd_lin_e  number );
--
   type t_tab_reg_e990 is table of tab_reg_e990 index by binary_integer;
   vt_tab_reg_e990 t_tab_reg_e990;
--
-- BLOCO G ¿ CONTROLE DO CRÉDITO DE ICMS DO ATIVO PERMANENTE ¿ CIAP ¿ modelos ¿C¿ e ¿D¿
--
--| REGISTRO G001: ABERTURA DO BLOCO G
   -- Nível hierárquico - 1
   -- Ocorrência - um (por arquivo)
   type tab_reg_g001 is record ( reg      varchar2(4)
                               , ind_mov  number(1) );
--
   type t_tab_reg_g001 is table of tab_reg_g001 index by binary_integer;
   vt_tab_reg_g001 t_tab_reg_g001;
--
--| REGISTRO G110 ¿ ICMS ¿ ATIVO PERMANENTE ¿ CIAP
   -- Nível hierárquico - 2
   -- Ocorrência ¿ um (por período de apuração)
   type tab_reg_g110 is record ( reg            varchar2(4)
                               , dt_ini         date
                               , dt_fin         date
                               , saldo_in_icms  number(15,2)
                               , som_parc       number(15,2)
                               , vl_trib_exp    number(15,2)
                               , vl_total       number(15,2)
                               , ind_per_sai    number(19,8)
                               , icms_aprop     number(15,2)
                               , som_icms_oc    number(15,2)
                               );
--
   type t_tab_reg_g110 is table of tab_reg_g110 index by binary_integer;
   vt_tab_reg_g110 t_tab_reg_g110;
--
--| REGISTRO G125 ¿ MOVIMENTAÇÃO DE BEM OU COMPONENTE DO ATIVO IMOBILIZADO
   -- Nível hierárquico ¿ 3
   -- Ocorrência - 1:N
   type tab_reg_g125 is record ( reg               varchar2(4)
                               , cod_ind_bem       varchar2(60)
                               , dt_mov            date
                               , tipo_mov          varchar2(2)
                               , vl_imob_icms_op   number(15,2)
                               , vl_imob_icms_st   number(15,2)
                               , vl_imob_icms_frt  number(15,2)
                               , vl_imob_icms_dif  number(15,2)
                               , num_parc          number(3)
                               , vl_parc_pass      number(15,2)
                               );
--
   type t_tab_reg_g125 is table of tab_reg_g125 index by binary_integer;
   type t_bi_tab_reg_g125 is table of t_tab_reg_g125 index by binary_integer;
   vt_bi_tab_reg_g125 t_bi_tab_reg_g125;
--
--| REGISTRO G126 ¿ OUTROS CRÉDITOS CIAP
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_g126 is record ( reg               varchar2(4)
                               , dt_ini            date
                               , dt_fim            date
                               , num_parc          number(3)
                               , vl_parc_pass      number(15,2)
                               , vl_trib_oc        number(15,2)
                               , vl_total          number(15,2)
                               , ind_per_sai       number(19,8)
                               , vl_parc_aprop     number(15,2)
                               );
--
   type t_tab_reg_g126 is table of tab_reg_g126 index by binary_integer;
   type t_bi_tab_reg_g126 is table of t_tab_reg_g126 index by binary_integer;
   type t_tri_tab_reg_g126 is table of t_bi_tab_reg_g126 index by binary_integer;
   vt_tri_tab_reg_g126 t_tri_tab_reg_g126;
--
--| REGISTRO G130 ¿ IDENTIFICAÇÃO DO DOCUMENTO FISCAL
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_g130 is record ( reg               varchar2(4)
                               , ind_emit          varchar2(1)
                               , cod_part          varchar2(60)
                               , cod_mod           varchar2(2)
                               , serie             varchar2(3)
                               , num_doc           number(9)
                               , chv_nfe_cte       varchar2(44)
                               , dt_doc            date
                               , num_da            varchar2(255)  );
--
   type t_tab_reg_g130 is table of tab_reg_g130 index by binary_integer;
   type t_bi_tab_reg_g130 is table of t_tab_reg_g130 index by binary_integer;
   type t_tri_tab_reg_g130 is table of t_bi_tab_reg_g130 index by binary_integer;
   vt_tri_tab_reg_g130 t_tri_tab_reg_g130;
--
--| REGISTRO G140 ¿ IDENTIFICAÇÃO DO ITEM DO DOCUMENTO FISCAL
   -- Nível hierárquico - 5
   -- Ocorrência - 1:N
   type tab_reg_g140 is record ( reg                   varchar2(4)
                               , num_item              number(3)
                               , cod_item              varchar2(60) 
                               , qtde                  number(15,5)                 
                               , sigla_unid            varchar2(6)
                               , vl_icms_op_aplicado   number(15,2)
                               , vl_icms_st_aplicado   number(15,2)
                               , vl_icms_frt_aplicado  number(15,2)
                               , vl_icms_dif_aplicado  number(15,2) );
--
   type t_tab_reg_g140 is table of tab_reg_g140 index by binary_integer;
   type t_bi_tab_reg_g140 is table of t_tab_reg_g140 index by binary_integer;
   type t_tri_tab_reg_g140 is table of t_bi_tab_reg_g140 index by binary_integer;
   type t_tetra_tab_reg_g140 is table of t_tri_tab_reg_g140 index by binary_integer;
   vt_tetra_tab_reg_g140 t_tetra_tab_reg_g140;
--
--| REGISTRO G990: ENCERRAMENTO DO BLOCO G
   -- Nível hierárquico - 1
   -- Ocorrência - um (por arquivo)
   type tab_reg_g990 is record ( reg               varchar2(4)
                               , qtd_lin_g         number );
--
   type t_tab_reg_g990 is table of tab_reg_g990 index by binary_integer;
   vt_tab_reg_g990 t_tab_reg_g990;
--
-- BLOCO H: INVENTÁRIO FÍSICO
--
--| REGISTRO H001: ABERTURA DO BLOCO H
   -- Nível hierárquico - 1
   -- Ocorrência ¿ um por Arquivo
   type tab_reg_h001 is record ( reg      varchar2(4)
                               , ind_mov  number(1) );
--
   type t_tab_reg_h001 is table of tab_reg_h001 index by binary_integer;
   vt_tab_reg_h001 t_tab_reg_h001;
--
--| registro h005: totais do inventário
   -- nível hierárquico - 2
   -- ocorrência ¿ 1:n
   type tab_reg_h005 is record ( reg        varchar2(4)
                               , dt_inv     date
                               , vl_inv     number(15,2)
                               , dm_mot_inv varchar2(2)
                               );
--
   type t_tab_reg_h005 is table of tab_reg_h005 index by binary_integer;
   vt_tab_reg_h005 t_tab_reg_h005;
--
--| REGISTRO H010: INVENTÁRIO
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_h010 is record ( reg        varchar2(4)
                               , cod_item   varchar2(60)
                               , unid       varchar2(6)
                               , qtd        number(14,3)
                               , vl_unit    number(15,6)
                               , vl_item    number(15,2)
                               , ind_prop   number(1)
                               , cod_part   varchar2(60)
                               , txt_compl  varchar2(255)
                               , cod_cta    varchar2(255)
                               , vl_item_ir number(15,2)
                               );
--
   type t_tab_reg_h010 is table of tab_reg_h010 index by binary_integer;
   type t_bi_tab_reg_h010 is table of t_tab_reg_h010 index by binary_integer;
   vt_bi_tab_reg_h010 t_bi_tab_reg_h010;
--
--| REGISTRO H020: INVENTÁRIO
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_h020 is record ( reg        varchar2(4)
                               , cod_st     varchar2(3)
                               , vl_bc_icms number(15,2)
                               , vl_icms    number(15,2)
                               );
--
   type t_tab_reg_h020 is table of tab_reg_h020 index by binary_integer;
   type t_bi_tab_reg_h020 is table of t_tab_reg_h020 index by binary_integer;
   type t_tri_tab_reg_h020 is table of t_bi_tab_reg_h020 index by binary_integer;
   vt_tri_tab_reg_h020 t_tri_tab_reg_h020;
--
--| REGISTRO H990: ENCERRAMENTO DO BLOCO H
   -- Nível hierárquico - 1
   -- Ocorrência ¿ um por arquivo
   type tab_reg_h990 is record ( reg        varchar2(4)
                               , qtd_lin_h  number );
--
   type t_tab_reg_h990 is table of tab_reg_h990 index by binary_integer;
   vt_tab_reg_h990 t_tab_reg_h990;
--
-- BLOCO K: CONTROLE DA PRODUÇÃO E DO ESTOQUE
--
--| REGISTRO K001: ABERTURA DO BLOCO K
    -- Nível hierárquico - 1
    -- Ocorrência ¿ um por Arquivo
   type tab_reg_k001 is record ( reg      varchar2(4)
                               , ind_mov  number );
--
   type t_tab_reg_k001 is table of tab_reg_k001 index by binary_integer;
   vt_tab_reg_k001 t_tab_reg_k001;
--
--| REGISTRO K100: PERÍODO DE APURAÇÃO DO ICMS/IPI
    -- Nível hierárquico - 2
    -- Ocorrência ¿ Vários
   type tab_reg_k100 is record ( reg     varchar2(4)
                               , dt_ini  date
                               , dt_fin  date );
--
   type t_tab_reg_k100 is table of tab_reg_k100 index by binary_integer;
   vt_tab_reg_k100 t_tab_reg_k100;
--
--| REGISTRO K200: ESTOQUE ESCRITURADO
    -- Nível hierárquico - 3
    -- Ocorrência ¿ Vários
   type tab_reg_k200 is record ( reg       varchar2(4)
                               , dt_est    date
                               , cod_item  varchar2(60)
                               , qtd       number(17,3)
                               , ind_est   varchar2(1)
                               , cod_part  varchar2(60) );
--
   type t_tab_reg_k200 is table of tab_reg_k200 index by binary_integer;
   type t_bi_tab_reg_k200 is table of t_tab_reg_k200 index by binary_integer;
   vt_bi_tab_reg_k200 t_bi_tab_reg_k200;
--
--| REGISTRO K210: DESMONTAGEM DE MERCADORIAS - ITEM DE ORIGEM
    -- Nivel hierárquico - 3
    -- Ocorrência - Vários
    type tab_reg_k210 is record ( reg            varchar2(4)
                                , dt_ini_os      date
                                , dt_fin_os      date
                                , cod_doc_os     varchar2(30)
                                , cod_item_ori   varchar2(60)
                                , qtd_ori        number(17,3) );
--
   type t_tab_reg_k210 is table of tab_reg_k210 index by binary_integer;
   type t_bi_tab_reg_k210 is table of t_tab_reg_k210 index by binary_integer;
   vt_bi_tab_reg_k210 t_bi_tab_reg_k210;
--
--| REGISTRO K215: DESMONTAGEM DE MERCADORIAS ¿ ITENS DE DESTINO
    -- Nivel hierárquico - 4
    -- Ocorrência - Vários
    type tab_reg_k215 is record ( reg            varchar2(4)
                                , cod_item_des   varchar2(60)
                                , qtd_des        number(17,3) );
--
   type t_tab_reg_k215 is table of tab_reg_k215 index by binary_integer;
   type t_bi_tab_reg_k215 is table of t_tab_reg_k215 index by binary_integer;
   type t_tri_tab_reg_k215 is table of t_bi_tab_reg_k215 index by binary_integer;
   vt_tri_tab_reg_k215  t_tri_tab_reg_k215;
--
--| REGISTRO K220: OUTRAS MOVIMENTAÇÕES INTERNAS ENTRE MERCADORIAS
    -- Nível hierárquico - 3
    -- Ocorrência ¿ Vários
   type tab_reg_k220 is record ( reg            varchar2(4)
                               , dt_mov         date
                               , cod_item_orig  varchar2(60)
                               , cod_item_dest  varchar2(60)
                               , qtd            number(17,3)
                               , qtd_dest       number(17,3) );
--
   type t_tab_reg_k220 is table of tab_reg_k220 index by binary_integer;
   type t_bi_tab_reg_k220 is table of t_tab_reg_k220 index by binary_integer;
   vt_bi_tab_reg_k220 t_bi_tab_reg_k220;
--
--| REGISTRO K230: ITENS PRODUZIDOS
    -- Nível hierárquico - 3
    -- Ocorrência ¿ Vários
   type tab_reg_k230 is record ( reg         varchar2(4)
                               , dt_ini_op   date
                               , dt_fin_op   date
                               , cod_doc_op  varchar2(30)
                               , cod_item    varchar2(60)
                               , qtd_enc     number(17,3) );
--
   type t_tab_reg_k230 is table of tab_reg_k230 index by binary_integer;
   type t_bi_tab_reg_k230 is table of t_tab_reg_k230 index by binary_integer;
   vt_bi_tab_reg_k230 t_bi_tab_reg_k230;
--
--| REGISTRO K235: INSUMOS CONSUMIDOS
    -- Nível hierárquico - 4
    -- Ocorrência - 1:N
   type tab_reg_k235 is record ( reg            varchar2(4)
                               , dt_saida       date
                               , cod_item       varchar2(60)
                               , qtd            number(17,3)
                               , cod_ins_subst  varchar2(60) );
--
   type t_tab_reg_k235 is table of tab_reg_k235 index by binary_integer;
   type t_bi_tab_reg_k235 is table of t_tab_reg_k235 index by binary_integer;
   type t_tri_tab_reg_k235 is table of t_bi_tab_reg_k235 index by binary_integer;
   vt_tri_tab_reg_k235 t_tri_tab_reg_k235;
--
--| REGISTRO K250: INDUSTRIALIZAÇÃO EFETUADA POR TERCEIROS ¿ ITENS PRODUZIDOS
    -- Nível hierárquico - 3
    -- Ocorrência ¿ Vários
   type tab_reg_k250 is record ( reg       varchar2(4)
                               , dt_prod   date
                               , cod_item  varchar2(60)
                               , qtd       number(17,3) );
--
   type t_tab_reg_k250 is table of tab_reg_k250 index by binary_integer;
   type t_bi_tab_reg_k250 is table of t_tab_reg_k250 index by binary_integer;
   vt_bi_tab_reg_k250 t_bi_tab_reg_k250;
--
--| REGISTRO K255: INDUSTRIALIZAÇÃO EM TERCEIROS ¿ INSUMOS CONSUMIDOS
    -- Nível hierárquico - 4
    -- Ocorrência - 1:N
   type tab_reg_k255 is record ( reg            varchar2(4)
                               , dt_cons        date
                               , cod_item       varchar2(60)
                               , qtd            number(17,3)
                               , cod_ins_subst  varchar2(60) );
--
   type t_tab_reg_k255 is table of tab_reg_k255 index by binary_integer;
   type t_bi_tab_reg_k255 is table of t_tab_reg_k255 index by binary_integer;
   type t_tri_tab_reg_k255 is table of t_bi_tab_reg_k255 index by binary_integer;
   vt_tri_tab_reg_k255 t_tri_tab_reg_k255;
--
--| REGISTRO K260: REPROCESSAMENTO/REPARO DE PRODUTO/INSUMO
    -- Nível hierárquico - 3
    -- Ocorrência - 1:N
    type tab_reg_k260 is record ( reg        varchar2(4)
                                , cod_op_os  varchar2(30)
                                , cod_item   varchar2(60)
                                , dt_saida   date
                                , qtd_saida  number(17,3)
                                , dt_ret     date
                                , qtd_ret    number(17,3));
--
   type t_tab_reg_k260 is table of tab_reg_k260 index by binary_integer;
   type t_bi_tab_reg_k260 is table of t_tab_reg_k260 index by binary_integer;
   vt_bi_tab_reg_k260 t_bi_tab_reg_k260;
--
--| REGISTRO K265: REPROCESSAMENTO/REPARO - MERCADORIAS CONSUMIDAS E/OU RETORNADAS
    -- Nível hierárquico - 4
    -- Ocorrência - 1:N
    type tab_reg_k265 is record ( reg        varchar2(4)
                                , cod_item   varchar2(60)
                                , qtd_cons   number(17,3)
                                , qtd_ret    number(17,3));
--
   type t_tab_reg_k265 is table of tab_reg_k265 index by binary_integer;
   type t_bi_tab_reg_k265 is table of t_tab_reg_k265 index by binary_integer;
   type t_tri_tab_reg_k265 is table of t_bi_tab_reg_k265 index by binary_integer;
   vt_tri_tab_reg_k265 t_tri_tab_reg_k265;
--
--| REGISTRO K270: CORREÇÃO DE APONTAMENTO DOS REGISTROS K210, K220, K230, K250 E K260
    -- Nível hierárquico - 3
    -- Ocorrência ¿ 1:N
    type tab_reg_k270 is record ( reg         varchar2(4)
                                , dt_ini_ap   date
                                , dt_fin_ap   date
                                , cod_op_os   varchar2(30)
                                , cod_item    varchar2(60)
                                , qtd_cor_pos number(17,3)
                                , qtd_cor_neg number(17,3)
                                , origem      varchar2(1));
--
   type t_tab_reg_k270 is table of tab_reg_k270 index by binary_integer;
   type t_bi_tab_reg_k270 is table of t_tab_reg_k270 index by binary_integer;
   vt_bi_tab_reg_k270 t_bi_tab_reg_k270;
--
--| REGISTRO K275: CORREÇÃO DE APONTAMENTO E RETORNO DE INSUMOS DOS REGISTROS K215, K220, K235, K255 E K265
    -- Nível hierárquico - 4
    -- Ocorrência ¿ 1:N
    type tab_reg_k275 is record ( reg           varchar2(4)
                                , cod_item      varchar2(60)
                                , qtd_cor_pos   number(17,3)
                                , qtd_cor_neg   number(17,3)
                                , cod_ins_subst varchar2(60));
--
   type t_tab_reg_k275 is table of tab_reg_k275 index by binary_integer;
   type t_bi_tab_reg_k275 is table of t_tab_reg_k275 index by binary_integer;
   type t_tri_tab_reg_k275 is table of t_bi_tab_reg_k275 index by binary_integer;
   vt_tri_tab_reg_k275 t_tri_tab_reg_k275;
--
--| REGISTRO K280: CORREÇÃO DE APONTAMENTO ¿ ESTOQUE ESCRITURADO
    -- Nível hierárquico - 3
    -- Ocorrência ¿ 1:N
    type tab_reg_k280 is record ( reg           varchar2(4)
                                , dt_est        date
                                , cod_item      varchar2(60)
                                , qtd_cor_pos   number(17,3)
                                , qtd_cor_neg   number(17,3)
                                , ind_est       varchar2(1)
                                , cod_part      varchar2(60));
--
   type t_tab_reg_k280 is table of tab_reg_k280 index by binary_integer;
   type t_bi_tab_reg_k280 is table of t_tab_reg_k280 index by binary_integer;
   vt_bi_tab_reg_k280 t_bi_tab_reg_k280;
--
--
--|REGISTRO K290: PRODUÇÃO CONJUNTA ¿ ORDEM DE PRODUÇÃO
    -- Nível hierárquico - 2
    -- Ocorrência ¿ Vários
   type tab_reg_k290 is record ( reg        varchar2(4)
                               , dt_ini_op  date
                               , dt_fin_op  date 
                               , cod_doc_op varchar2(30) );
--
   type t_tab_reg_k290 is table of tab_reg_k290 index by binary_integer;
   type t_bi_tab_reg_k290 is table of t_tab_reg_k290 index by binary_integer;
   vt_bi_tab_reg_k290 t_bi_tab_reg_k290;
--
--|REGISTRO K291: PRODUÇÃO CONJUNTA ¿ ITENS PRODUZIDOS
    -- Nivel hierárquico - 3
    -- Ocorrência - Vários
    type tab_reg_k291 is record ( reg            varchar2(4)
                                , cod_item       varchar2(60)
                                , qtd            number(11,6) );
--
   type t_tab_reg_k291 is table of tab_reg_k291 index by binary_integer;
   type t_bi_tab_reg_k291 is table of t_tab_reg_k291 index by binary_integer;
   type t_tri_tab_reg_k291 is table of t_bi_tab_reg_k291 index by binary_integer;
   vt_tri_tab_reg_k291  t_tri_tab_reg_k291;
--
--|REGISTRO K292: PRODUÇÃO CONJUNTA ¿ INSUMOS CONSUMIDOS
    -- Nivel hierárquico - 3
    -- Ocorrência - Vários
    type tab_reg_k292 is record ( reg            varchar2(4)
                                , cod_item       varchar2(60)
                                , qtd            number(11,6) );
--
   type t_tab_reg_k292 is table of tab_reg_k292 index by binary_integer;
   type t_bi_tab_reg_k292 is table of t_tab_reg_k292 index by binary_integer;
   type t_tri_tab_reg_k292 is table of t_bi_tab_reg_k292 index by binary_integer;
   vt_tri_tab_reg_k292  t_tri_tab_reg_k292;
--
--|REGISTRO K300: PRODUÇÃO CONJUNTA ¿ INDUSTRIALIZAÇÃO EFETUADA POR TERCEIROS
    -- Nível hierárquico - 2
    -- Ocorrência ¿ Vários
   type tab_reg_k300 is record ( reg        varchar2(4)
                               , dt_prod    date );
--
   type t_tab_reg_k300 is table of tab_reg_k300 index by binary_integer;
   type t_bi_tab_reg_k300 is table of t_tab_reg_k300 index by binary_integer;
   vt_bi_tab_reg_k300 t_bi_tab_reg_k300;
--
--|REGISTRO K301: PRODUÇÃO CONJUNTA ¿ INDUSTRIALIZAÇÃO EFETUADA POR TERCEIROS ¿ ITENS PRODUZIDOS
    -- Nivel hierárquico - 3
    -- Ocorrência - Vários
    type tab_reg_k301 is record ( reg            varchar2(4)
                                , cod_item       varchar2(60)
                                , qtd            number(11,6) );
--
   type t_tab_reg_k301 is table of tab_reg_k301 index by binary_integer;
   type t_bi_tab_reg_k301 is table of t_tab_reg_k301 index by binary_integer;
   type t_tri_tab_reg_k301 is table of t_bi_tab_reg_k301 index by binary_integer;
   vt_tri_tab_reg_k301  t_tri_tab_reg_k301;
--
--|REGISTRO K302: PRODUÇÃO CONJUNTA ¿ INDUSTRIALIZAÇÃO EFETUADA POR TERCEIROS ¿ INSUMOS CONSUMIDOS
    -- Nivel hierárquico - 3
    -- Ocorrência - Vários
    type tab_reg_k302 is record ( reg            varchar2(4)
                                , cod_item       varchar2(60)
                                , qtd            number(11,6) );
--
   type t_tab_reg_k302 is table of tab_reg_k302 index by binary_integer;
   type t_bi_tab_reg_k302 is table of t_tab_reg_k302 index by binary_integer;
   type t_tri_tab_reg_k302 is table of t_bi_tab_reg_k302 index by binary_integer;
   vt_tri_tab_reg_k302  t_tri_tab_reg_k302;
--
--| REGISTRO K990: ENCERRAMENTO DO BLOCO K
    -- Nível hierárquico - 1
    -- Ocorrência ¿ um por arquivo
   type tab_reg_k990 is record ( reg        varchar2(4)
                               , qtd_lin_k  number );
--
   type t_tab_reg_k990 is table of tab_reg_k990 index by binary_integer;
   vt_tab_reg_k990 t_tab_reg_k990;
--
-- BLOCO 1: OUTRAS INFORMAÇÕES
--
--| REGISTRO 1001: ABERTURA DO BLOCO 1
   -- Nível hierárquico ¿ 1
   -- Ocorrência - um por arquivo
   type tab_reg_1001 is record ( reg      varchar2(4)
                               , ind_mov  number(1) );
--
   type t_tab_reg_1001 is table of tab_reg_1001 index by binary_integer;
   vt_tab_reg_1001 t_tab_reg_1001;
--
--| REGISTRO 1010: OBRIGATORIEDADE DE REGISTROS DO BLOCO 1
   -- Nível hierárquico - 2
   -- Ocorrência - 1:1
   type tab_reg_1010 is record ( reg                          varchar2(4)
                               , ind_exp                      varchar2(1)
                               , ind_ccrf                     varchar2(1)
                               , ind_comb                     varchar2(1)
                               , ind_usina                    varchar2(1)
                               , ind_va                       varchar2(1)
                               , ind_ee                       varchar2(1)
                               , ind_cart                     varchar2(1)
                               , ind_form                     varchar2(1)
                               , ind_aer                      varchar2(1)
                               , ind_giaf1                    varchar2(1)
                               , ind_giaf3                    varchar2(1)
                               , ind_giaf4                    varchar2(1)  
                               , ind_rest_ressarc_compl_icms  varchar2(1)                 
                               );
--
   type t_tab_reg_1010 is table of tab_reg_1010 index by binary_integer;
   vt_tab_reg_1010 t_tab_reg_1010;
--
--| REGISTRO 1100: REGISTRO DE INFORMAÇÕES SOBRE EXPORTAÇÃO
   -- Nível hierárquico - 2
   -- Ocorrência - 1:N
   type tab_reg_1100 is record ( reg      varchar2(4)
                               , ind_doc  number(1)
                               , nro_de   varchar2(14)
                               , dt_de    date
                               , nat_exp  number(1)
                               , nro_re   number(12)
                               , dt_re    date
                               , chc_emb  varchar2(18)
                               , dt_chc   date
                               , dt_avb   date
                               , tp_chc   varchar2(2)
                               , pais     number(4) );
--
   type t_tab_reg_1100 is table of tab_reg_1100 index by binary_integer;
   vt_tab_reg_1100 t_tab_reg_1100;
--
--| REGISTRO 1105: DOCUMENTOS FISCAIS DE EXPORTAÇÃO
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_1105 is record ( reg       varchar2(4)
                               , cod_mod   varchar2(2)
                               , serie     varchar2(3)
                               , num_doc   number(9)
                               , chv_nfe   varchar2(44)
                               , dt_doc    date
                               , cod_item  varchar2(60) );
--
   type t_tab_reg_1105 is table of tab_reg_1105 index by binary_integer;
   type t_bi_tab_reg_1105 is table of t_tab_reg_1105 index by binary_integer;
   vt_bi_tab_reg_1105 t_bi_tab_reg_1105;
--
--| NOVO TÍTULO: REGISTRO 1110: OPERAÇÕES DE EXPORTAÇÃO INDIRETA - MERCADORIAS DE TERCEIROS
--| REGISTRO 1110: OPERAÇÕES DE EXPORTAÇÃO INDIRETA DE PRODUTOS NÃO INDUSTRIALIZADOS PELO ESTABELECIMENTO EMITENTE
   -- Nível hierárquico - 4
   -- Ocorrência - 1:N
   type tab_reg_1110 is record ( reg       varchar2(4)
                               , cod_part  varchar2(60)
                               , cod_mod   varchar2(2)
                               , ser       varchar2(3)
                               , num_doc   number(9)
                               , dt_doc    date
                               , chv_nfe   varchar2(44)
                               , nr_memo   number
                               , qtd       number(16,3)
                               , unid      varchar2(6) );
--
   type t_tab_reg_1110 is table of tab_reg_1110 index by binary_integer;
   type t_bi_tab_reg_1110 is table of t_tab_reg_1110 index by binary_integer;
   type t_tri_tab_reg_1110 is table of t_bi_tab_reg_1110 index by binary_integer;
   vt_tri_tab_reg_1110 t_tri_tab_reg_1110;
--
--| REGISTRO 1200: CONTROLE DE CRÉDITOS FISCAIS - ICMS
   -- Nível hierárquico - 2
   -- Ocorrência ¿ 1:N
   type tab_reg_1200 is record ( reg           varchar2(4)
                               , cod_aj_apur   varchar2(8)
                               , sld_cred      number(15,2)
                               , cred_apr      number(15,2)
                               , cred_receb    number(15,2)
                               , cred_util     number(15,2)
                               , sld_cred_fim  number(15,2) );
--
   type t_tab_reg_1200 is table of tab_reg_1200 index by binary_integer;
   vt_tab_reg_1200 t_tab_reg_1200;
--
--| REGISTRO 1210: UTILIZAÇÃO DE CRÉDITOS FISCAIS ¿ ICMS
   -- Nível hierárquico - 3
   -- Ocorrência ¿ 1:N
   type tab_reg_1210 is record ( reg           varchar2(4)
                               , tipo_util     varchar2(4)
                               , nr_doc        varchar2(255)
                               , vl_cred_util  number(15,2)
                               , chv_doce      varchar2(44)
                               );
--
   type t_tab_reg_1210 is table of tab_reg_1210 index by binary_integer;
   type t_bi_tab_reg_1210 is table of t_tab_reg_1210 index by binary_integer;
   vt_bi_tab_reg_1210 t_bi_tab_reg_1210;
--
--| REGISTRO 1300: MOVIMENTAÇÃO DIÁRIA DE COMBUSTÍVEIS
   -- Nível hierárquico ¿ 2
   -- Ocorrência - 1:N
   type tab_reg_1300 is record ( reg           varchar2(4)
                               , cod_item      varchar2(60)
                               , dt_fech       date
                               , estq_abert    number(16,3)
                               , vol_entr      number(16,3)
                               , vol_disp      number(16,3)
                               , vol_saidas    number(16,3)
                               , estq_escr     number(16,3)
                               , val_aj_perda  number(16,3)
                               , val_aj_ganho  number(16,3)
                               , fech_fisico   number(16,3) );
--
   type t_tab_reg_1300 is table of tab_reg_1300 index by binary_integer;
   vt_tab_reg_1300 t_tab_reg_1300;
--
--| REGISTRO 1310: MOVIMENTAÇÃO DIÁRIA DE COMBUSTÍVEIS POR TANQUE
   -- Nível hierárquico ¿ 3
   -- Ocorrência - 1:N
   type tab_reg_1310 is record ( reg           varchar2(4)
                               , num_tanque    number
                               , estq_abert    number(16,3)
                               , vol_entr      number(16,3)
                               , vol_disp      number(16,3)
                               , vol_saidas    number(16,3)
                               , estq_escr     number(16,3)
                               , val_aj_perda  number(16,3)
                               , val_aj_ganho  number(16,3)
                               , fech_fisico   number(16,3) );
--
   type t_tab_reg_1310 is table of tab_reg_1310 index by binary_integer;
   type t_bi_tab_reg_1310 is table of t_tab_reg_1310 index by binary_integer;
   vt_bi_tab_reg_1310 t_bi_tab_reg_1310;
--
--| REGISTRO 1320: VOLUME DE VENDAS
   -- Nível hierárquico ¿ 4
   -- Ocorrência - 1:N
   type tab_reg_1320 is record ( reg          varchar2(4)
                               , num_bico     number
                               , nr_interv    number
                               , mot_interv   varchar2(50)
                               , nom_interv   varchar2(30)
                               , cnpj_interv  varchar2(14)
                               , cpf_interv   varchar2(11)
                               , val_fecha    number(16,3)
                               , val_abert    number(16,3)
                               , vol_aferi    number(16,3)
                               , vol_vendas   number(16,3) );
--
   type t_tab_reg_1320 is table of tab_reg_1320 index by binary_integer;
   type t_bi_tab_reg_1320 is table of t_tab_reg_1320 index by binary_integer;
   type t_tri_tab_reg_1320 is table of t_bi_tab_reg_1320 index by binary_integer;
   vt_tri_tab_reg_1320 t_tri_tab_reg_1320;
--
--| REGISTRO 1350: BOMBAS
   -- Nível hierárquico ¿ 2
   -- Ocorrência - 1:N
   type tab_reg_1350 is record ( reg           varchar2(4)
                               , serie         varchar2(255)
                               , fabricante    varchar2(60)
                               , modelo        varchar2(255)
                               , tipo_medicao  varchar2(1) );
--
   type t_tab_reg_1350 is table of tab_reg_1350 index by binary_integer;
   vt_tab_reg_1350 t_tab_reg_1350;
--
--| REGISTRO 1360: LACRES DA BOMBA
   -- Nível hierárquico ¿ 3
   -- Ocorrência - 1:N
   type tab_reg_1360 is record ( reg           varchar2(4)
                               , num_lacre     varchar2(20)
                               , dt_aplicacao  date );
--
   type t_tab_reg_1360 is table of tab_reg_1360 index by binary_integer;
   type t_bi_tab_reg_1360 is table of t_tab_reg_1360 index by binary_integer;
   vt_bi_tab_reg_1360 t_bi_tab_reg_1360;
--
--| REGISTRO 1370: BICOS DA BOMBA
   -- Nível hierárquico ¿ 3
   -- Ocorrência - 1:N
   type tab_reg_1370 is record ( reg          varchar2(4)
                               , num_bico     number(3)
                               , cod_item     varchar2(60)
                               , num_tanque   number );
--
   type t_tab_reg_1370 is table of tab_reg_1370 index by binary_integer;
   type t_bi_tab_reg_1370 is table of t_tab_reg_1370 index by binary_integer;
   vt_bi_tab_reg_1370 t_bi_tab_reg_1370;
--
--| REGISTRO 1390: CONTROLE DE PRODUÇÃO DE USINA
   -- Nível hierárquico ¿ 2
   -- Ocorrência - 1:N
   type tab_reg_1390 is record ( reg       varchar2(4)
                               , cod_prod  varchar2(2)
                               );
--
   type t_tab_reg_1390 is table of tab_reg_1390 index by binary_integer;
   vt_tab_reg_1390 t_tab_reg_1390;
--
--| REGISTRO 1391: PRODUÇÃO DIÁRIA DA USINA
   -- Nível hierárquico ¿ 3
   -- Ocorrência - 1:N
   type tab_reg_1391 is record ( reg           varchar2(4)
                               , dt_registro   varchar2(8)
                               , qtd_moid      number(15,2)
                               , estq_ini      number(15,2)
                               , qtd_produz    number(15,2)
                               , ent_anid_hid  number(15,2)
                               , outr_entr     number(15,2)
                               , perda         number(15,2)
                               , cons          number(15,2)
                               , sai_ani_hid   number(15,2)
                               , saidas        number(15,2)
                               , estq_fin      number(15,2)
                               , estq_ini_mel  number(15,2)
                               , prod_dia_mel  number(15,2)
                               , util_mel      number(15,2)
                               , prod_alc_mel  number(15,2)
                               , obs           varchar2(255)
                               --, item_id       number     --#67592
                               , cod_item      varchar2(60) --#67592
                               , dm_tp_residuo VARCHAR(2) 
                               , qtd_residuo  number(15,2)
                               );
--
   type t_tab_reg_1391 is table of tab_reg_1391 index by binary_integer;
   type t_bi_tab_reg_1391 is table of t_tab_reg_1391 index by binary_integer;
   vt_bi_tab_reg_1391 t_bi_tab_reg_1391;
--
--| REGISTRO 1400: INFORMAÇÃO SOBRE VALORES AGREGADOS
   -- Nível hierárquico ¿ 2
   -- Ocorrência - 1:N
   type tab_reg_1400 is record ( reg           varchar2(4)
                               , cod_item_ipm  varchar2(60)
                               , mun           number(7)
                               , valor         number(15,2) );
--
   type t_tab_reg_1400 is table of tab_reg_1400 index by binary_integer;
   vt_tab_reg_1400 t_tab_reg_1400;
--
--| REGISTRO 1500: NOTA FISCAL/CONTA DE ENERGIA ELÉTRICA (CÓDIGO 06) ¿ OPERAÇÕES INTERESTADUAIS
   -- Nível hierárquico - 2
   -- Ocorrência - vários (por arquivo)
   type tab_reg_1500 is record ( reg               varchar2(4)
                               , ind_oper          number(1)
                               , ind_emit          number(1)
                               , cod_part          varchar2(60)
                               , cod_mod           varchar2(2)
                               , cod_sit           varchar2(2)
                               , ser               varchar2(4)
                               , sub               number(3)
                               , cod_cons          varchar2(2)
                               , num_doc           number(9)
                               , dt_doc            date
                               , dt_e_s            date
                               , vl_doc            number(15,2)
                               , vl_desc           number(15,2)
                               , vl_forn           number(15,2)
                               , vl_serv_nt        number(15,2)
                               , vl_terc           number(15,2)
                               , vl_da             number(15,2)
                               , vl_bc_icms        number(15,2)
                               , vl_icms           number(15,2)
                               , vl_bc_icms_st     number(15,2)
                               , vl_icms_st        number(15,2)
                               , cod_inf           varchar2(6)
                               , vl_pis            number(15,2)
                               , vl_cofins         number(15,2)
                               , tp_ligacao        number(1)
                               , cod_grupo_tensao  varchar2(2) );
--
   type t_tab_reg_1500 is table of tab_reg_1500 index by binary_integer;
   vt_tab_reg_1500 t_tab_reg_1500;
--
--| REGISTRO 1510: ITENS DO DOCUMENTO NOTA FISCAL/CONTA ENERGIA ELÉTRICA (CÓDIGO 06)
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_1510 is record ( reg            varchar2(4)
                               , num_item       number(3)
                               , cod_item       varchar2(60)
                               , cod_class      varchar2(4)
                               , qtd            number(12,3)
                               , unid           varchar2(6)
                               , vl_item        number(15,2)
                               , vl_desc        number(15,2)
                               , cst_icms       varchar2(3)
                               , cfop           number(4)
                               , vl_bc_icms     number(15,2)
                               , aliq_icms      number(6,2)
                               , vl_icms        number(15,2)
                               , vl_bc_icms_st  number(15,2)
                               , aliq_st        number(6,2)
                               , vl_icms_st     number(15,2)
                               , ind_rec        number(1)
                               , cod_part       varchar2(60)
                               , vl_pis         number(15,2)
                               , vl_cofins      number(15,2)
                               , cod_cta        varchar2(255) );
--
   type t_tab_reg_1510 is table of tab_reg_1510 index by binary_integer;
   type t_bi_tab_reg_1510 is table of t_tab_reg_1510 index by binary_integer;
   vt_bi_tab_reg_1510 t_bi_tab_reg_1510;
--
--| REGISTRO 1600: TOTAL DAS OPERAÇÕES COM CARTÃO DE CRÉDITO E/OU DÉBITO
   -- Nível hierárquico ¿ 2
   -- Ocorrência - 1:N
   type tab_reg_1600 is record ( reg            varchar2(4)
                               , cod_part       varchar2(60)
                               , tot_credito    number(15,2)
                               , tot_debito     number(15,2) );
--
   type t_tab_reg_1600 is table of tab_reg_1600 index by binary_integer;
   vt_tab_reg_1600 t_tab_reg_1600;
--
--| REGISTRO 1700 - DOCUMENTOS FISCAIS UTILIZADOS
   -- Nível hierárquico - 2
   -- Ocorrência ¿ V
   type tab_reg_1700 is record ( reg            varchar2(4)
                               , cod_disp       varchar2(2)
                               , cod_mod        varchar2(2)
                               , ser            varchar2(4)
                               , sub            varchar2(3)
                               , num_doc_ini    number(12)
                               , num_doc_fin    number(12)
                               , num_aut        varchar2(60) );
--
   type t_tab_reg_1700 is table of tab_reg_1700 index by binary_integer;
   vt_tab_reg_1700 t_tab_reg_1700;
--
--| REGISTRO 1710 - DOCUMENTOS FISCAIS CANCELADOS/INUTILIZADOS
   -- Nível hierárquico - 3
   -- Ocorrência ¿ 1:N
   type tab_reg_1710 is record ( reg            varchar2(4)
                               , num_doc_ini    number(12)
                               , num_doc_fin    number(12) );
--
   type t_tab_reg_1710 is table of tab_reg_1710 index by binary_integer;
   type t_bi_tab_reg_1710 is table of t_tab_reg_1710 index by binary_integer;
   vt_bi_tab_reg_1710 t_bi_tab_reg_1710;
--
--| REGISTRO 1800 ¿ DCTA ¿ DEMONSTRATIVO DE CRÉDITO DO ICMS SOBRE TRANSPORTE AÉREO
   -- Nível hierárquico - 2
   -- Ocorrência ¿ 1:1
   type tab_reg_1800 is record ( reg              varchar2(4)
                               , vl_carga         number(15,2)
                               , vl_pass          number(15,2)
                               , vl_fat           number(15,2)
                               , ind_rat          number(8,6)
                               , vl_icms_ant      number(15,2)
                               , vl_bc_icms       number(15,2)
                               , vl_icms_apur     number(15,2)
                               , vl_bc_icms_apur  number(15,2)
                               , vl_dif           number(15,2) );
--
   type t_tab_reg_1800 is table of tab_reg_1800 index by binary_integer;
   vt_tab_reg_1800 t_tab_reg_1800;
--
--| REGISTRO 1900: INDICADOR DE SUB-APURAÇÃO DO ICMS
   -- Nível hierárquico - 2
   -- Ocorrência - 1:N
   type tab_reg_1900 is record ( reg                  varchar2(4)
                               , ind_apur_icms        varchar2(1)
                               , descr_compl_out_apur varchar2(255)
                               );
--
   type t_tab_reg_1900 is table of tab_reg_1900 index by binary_integer;
   vt_tab_reg_1900 t_tab_reg_1900;
--
--| REGISTRO 1910: PERÍODO DA SUB-APURAÇÃO DO ICMS
   -- Nível hierárquico - 3
   -- Ocorrência - 1:N
   type tab_reg_1910 is record ( reg    varchar2(4)
                               , dt_ini date
                               , dt_fin date
                               );
--
   type t_tab_reg_1910 is table of tab_reg_1910 index by binary_integer;
   vt_tab_reg_1910 t_tab_reg_1910;
--
--| REGISTRO 1920: SUB-APURAÇÃO DO ICMS
   -- Nível hierárquico - 4
   -- Ocorrência - um (por período)
   type tab_reg_1920 is record ( reg                       varchar2(4)
                               , vl_tot_transf_debitos_oa  number(15,2)
                               , vl_tot_aj_debitos_oa      number(15,2)
                               , vl_estornos_cred_oa       number(15,2)
                               , vl_tot_transf_creditos_oa number(15,2)
                               , vl_tot_aj_creditos_oa     number(15,2)
                               , vl_estornos_deb_oa        number(15,2)
                               , vl_sld_credor_ant_oa      number(15,2)
                               , vl_sld_apurado_oa         number(15,2)
                               , vl_tot_ded                number(15,2)
                               , vl_icms_recolher_oa       number(15,2)
                               , vl_sld_credor_transp_oa   number(15,2)
                               , vl_deb_esp_oa             number(15,2)
                               );
--
   type t_tab_reg_1920 is table of tab_reg_1920 index by binary_integer;
   vt_tab_reg_1920 t_tab_reg_1920;
--
--| REGISTRO 1921: AJUSTE/BENEFÍCIO/INCENTIVO DA SUB-APURAÇÃO DO ICMS
   -- Nível hierárquico - 5
   -- Ocorrência - 1:N
   type tab_reg_1921 is record ( reg            varchar2(4)
                               , cod_aj_apur    varchar2(8)
                               , descr_compl_aj varchar2(255)
                               , vl_aj_apur     number(15,2)
                               );
--
   type t_tab_reg_1921 is table of tab_reg_1921 index by binary_integer;
   type t_bi_tab_reg_1921 is table of t_tab_reg_1921 index by binary_integer;
   vt_bi_tab_reg_1921 t_bi_tab_reg_1921;
--
--| REGISTRO 1922: INFORMAÇÕES ADICIONAIS DOS AJUSTES DA SUB-APURAÇÃO DO ICMS
   -- Nível hierárquico - 6
   -- Ocorrência - 1:N
   type tab_reg_1922 is record ( reg       varchar2(4)
                               , num_da    varchar2(255)
                               , num_proc  varchar2(15)
                               , ind_proc  varchar2(1)
                               , proc      varchar2(255)
                               , txt_compl varchar2(255)
                               );
--
   type t_tab_reg_1922 is table of tab_reg_1922 index by binary_integer;
   type t_bi_tab_reg_1922 is table of t_tab_reg_1922 index by binary_integer;
   type t_tri_tab_reg_1922 is table of t_bi_tab_reg_1922 index by binary_integer;
   vt_tri_tab_reg_1922 t_tri_tab_reg_1922;
--
--| REGISTRO 1923: INFORMAÇÕES ADICIONAIS DOS AJUSTES DA SUB-APURAÇÃO DO ICMS ¿ IDENTIFICAÇÃO DOS DOCUMENTOS FISCAIS
   -- Nível hierárquico - 6
   -- Ocorrência - 1:N
   type tab_reg_1923 is record ( reg         varchar2(4)
                               , cod_part    varchar2(60)
                               , cod_mod     varchar2(2)
                               , ser         varchar2(4)
                               , sub         number(3)
                               , num_doc     number(9)
                               , dt_doc      date
                               , cod_item    varchar2(60)
                               , vl_aj_item  number(15,2)
                               , chv_doce    varchar2(44)
                               );
--
   type t_tab_reg_1923 is table of tab_reg_1923 index by binary_integer;
   type t_bi_tab_reg_1923 is table of t_tab_reg_1923 index by binary_integer;
   type t_tri_tab_reg_1923 is table of t_bi_tab_reg_1923 index by binary_integer;
   vt_tri_tab_reg_1923 t_tri_tab_reg_1923;
--
--| REGISTRO 1925: INFORMAÇÕES ADICIONAIS DA SUB-APURAÇÃO ¿ VALORES DECLARATÓRIOS
   -- Nível hierárquico - 5
   -- Ocorrência ¿ 1:N
   type tab_reg_1925 is record ( reg            varchar2(4)
                               , cod_inf_adic   varchar2(8)
                               , vl_inf_adic    number(15,2)
                               , descr_compl_aj varchar2(255)
                               );
--
   type t_tab_reg_1925 is table of tab_reg_1925 index by binary_integer;
   type t_bi_tab_reg_1925 is table of t_tab_reg_1925 index by binary_integer;
   vt_bi_tab_reg_1925 t_bi_tab_reg_1925;
--
--| REGISTRO 1926: OBRIGAÇÕES DO ICMS A RECOLHER ¿ OPERAÇÕES REFERENTES À SUB-APURAÇÃO
   -- Nível hierárquico ¿ 5
   -- Ocorrência - 1:N
   type tab_reg_1926 is record ( reg       varchar2(4)
                               , cod_or    varchar2(3)
                               , vl_or     number(15,2)
                               , dt_vcto   date
                               , cod_rec   varchar2(255)
                               , num_proc  varchar2(15)
                               , ind_proc  varchar2(1)
                               , proc      varchar2(255)
                               , txt_compl varchar2(255)
                               , mes_ref   varchar2(6)
                               );
--
   type t_tab_reg_1926 is table of tab_reg_1926 index by binary_integer;
   type t_bi_tab_reg_1926 is table of t_tab_reg_1926 index by binary_integer;
   vt_bi_tab_reg_1926 t_bi_tab_reg_1926;
--   
-- REGISTRO 1960: GIAF 1 - GUIA DE INFORMAÇÃO E APURAÇÃO DE INCENTIVOS FISCAIS E FINANCEIROS: INDÚSTRIA (CRÉDITO PRESUMIDO)
   type tab_reg_1960 is record ( REG   varchar2(4)
                               ,IND_AP number(2)
                               ,G1_01  number(15,2)
                               ,G1_02  number(15,2)
                               ,G1_03  number(15,2)
                               ,G1_04  number(15,2)
                               ,G1_05  number(15,2)
                               ,G1_06  number(15,2)
                               ,G1_07  number(15,2)
                               ,G1_08  number(15,2)
                               ,G1_09  number(15,2)
                               ,G1_10  number(15,2)
                               ,G1_11  number(15,2));--
   type t_tab_reg_1960 is table of tab_reg_1960 index by binary_integer;  
   vt_tab_reg_1960 t_tab_reg_1960;                                
--
-- REGISTRO 1970: GIAF 3 - GUIA DE INFORMAÇÃO E APURAÇÃO DE INCENTIVOS FISCAIS E FINANCEIROS: IMPORTAÇÃO (DIFERIMENTO NA ENTRADA E CRÉDITO
--                PRESUMIDO NA SAÍDA SUBSEQUENTE)
   type tab_reg_1970 is record ( REG  varchar2(4)
                               ,IND_AP number(2)
                               ,G3_01 number(15,2)
                               ,G3_02 number(15,2)
                               ,G3_03 number(15,2)
                               ,G3_04 number(15,2)
                               ,G3_05 number(15,2)
                               ,G3_06 number(15,2)
                               ,G3_07 number(15,2)
                               ,G3_T  number(15,2)
                               ,G3_08 number(15,2)
                               ,G3_09 number(15,2));--
   type t_tab_reg_1970 is table of tab_reg_1970 index by binary_integer; 
   vt_tab_reg_1970 t_tab_reg_1970;      

-- REGISTRO 1975: GIAF 3 - GUIA DE INFORMAÇÃO E APURAÇÃO DE INCENTIVOS FISCAIS E FINANCEIROS: 
-- IMPORTAÇÃO (SAÍDAS INTERNAS POR FAIXA DE ALÍQUOTA)
   type tab_reg_1975 is record ( REG varchar2(4)
                                ,ALIQ_IMP_BASE number(15,2)
                                ,G3_10 number(15,2)
                                ,G3_11 number(15,2)
                                ,G3_12 number(15,2));
  type t_tab_reg_1975  is table of tab_reg_1975  index by binary_integer; 
  type t_bi_tab_reg_1975 is table of t_tab_reg_1975 index by binary_integer;
  vt_bi_tab_reg_1975 t_bi_tab_reg_1975;   
  
-- REGISTRO 1980: GIAF 4 GUIA DE INFORMAÇÃO E APURAÇÃO DE INCENTIVOS FISCAIS E FINANCEIROS: 
-- CENTRAL DE DISTRIBUIÇÃO (ENTRADAS/SAÍDAS)
   type tab_reg_1980 is record ( REG varchar2(4)
                                ,IND_AP number(2)
                                ,G4_01 number(15,2)
                                ,G4_02 number(15,2)
                                ,G4_03 number(15,2)
                                ,G4_04 number(15,2)
                                ,G4_05 number(15,2)
                                ,G4_06 number(15,2)
                                ,G4_07 number(15,2)
                                ,G4_08 number(15,2)
                                ,G4_09 number(15,2)
                                ,G4_10 number(15,2)
                                ,G4_11 number(15,2)
                                ,G4_12 number(15,2));
   type t_tab_reg_1980 is table of tab_reg_1980 index by binary_integer;                                 
   vt_tab_reg_1980 t_tab_reg_1980;
--
--| REGISTRO 1990: ENCERRAMENTO DO BLOCO 1
   -- Nível hierárquico - 1
   -- Ocorrência ¿ um por Arquivo
   type tab_reg_1990 is record ( reg        varchar2(4)
                               , qtd_lin_1  number );
--
   type t_tab_reg_1990 is table of tab_reg_1990 index by binary_integer;
   vt_tab_reg_1990 t_tab_reg_1990;
--
-- BLOCO 9: CONTROLE E ENCERRAMENTO DO ARQUIVO DIGITAL
--
--| REGISTRO 9001: ABERTURA DO BLOCO 9
   -- Nível hierárquico - 1
   -- Ocorrência ¿ um por Arquivo
   type tab_reg_9001 is record ( reg      varchar2(4)
                               , ind_mov  number(1) );
--
   type t_tab_reg_9001 is table of tab_reg_9001 index by binary_integer;
   vt_tab_reg_9001 t_tab_reg_9001;
--
--| REGISTRO 9900: REGISTROS DO ARQUIVO
   -- Nível hierárquico - 2
   -- Ocorrência ¿ vários por Arquivo
   type tab_reg_9900 is record ( reg          varchar2(4)
                               , reg_blc      varchar2(4)
                               , qtd_reg_blc  number );
--
   type t_tab_reg_9900 is table of tab_reg_9900 index by binary_integer;
   vt_tab_reg_9900 t_tab_reg_9900;
--
--| REGISTRO 9990: ENCERRAMENTO DO BLOCO 9
   -- Nível hierárquico - 1
   -- Ocorrência ¿ um por Arquivo
   type tab_reg_9990 is record ( reg        varchar2(4)
                               , qtd_lin_9  number );
--
   type t_tab_reg_9990 is table of tab_reg_9990 index by binary_integer;
   vt_tab_reg_9990 t_tab_reg_9990;
--
--| REGISTRO 9999: ENCERRAMENTO DO ARQUIVO DIGITAL
   -- Nível hierárquico - 0
   -- Ocorrência ¿ um por Arquivo
   type tab_reg_9999 is record ( reg      varchar2(4)
                               , qtd_lin  number );
--
   type t_tab_reg_9999 is table of tab_reg_9999 index by binary_integer;
   vt_tab_reg_9999 t_tab_reg_9999;
--
-------------------------------------------------------------------------------------------------------

   type t_estr_arq_efd is table of estr_arq_efd%rowtype index by binary_integer;
   vt_estr_arq_efd t_estr_arq_efd;

-------------------------------------------------------------------------------------------------------

--| Variáveis globais utilizadas na geração do arquivo

   gl_conteudo           estr_arq_efd.conteudo%type;
   gt_row_abertura_efd   abertura_efd%rowtype;
   gn_versao             versao_layout_efd.versao%type;
   gv_dm_ind_perfil      abertura_efd.dm_ind_perfil%type;
   gv_mensagem_log       log_generico.mensagem%type;
   gn_dm_dt_escr_dfepoe  empresa.dm_dt_escr_dfepoe%type;
   gn_origem_dado_pessoa number;   
   gv_registro           varchar2(10);
   --
   gn_error_block        number := 0;   
   --
   erro_de_sistema       constant number := 2;

-------------------------------------------------------------------------------------------------------

/*
Todos os registros devem conter no final de cada linha do arquivo digital, após o caractere delimitador
Pipe acima mencionado, os caracteres "CR" (Carriage Return) e "LF" (Line Feed) correspondentes a
"retorno do carro" e "salto de linha" (CR e LF: caracteres 13 e 10, respectivamente, da Tabela ASCII).
*/

   CR             CONSTANT VARCHAR2(4000) := CHR(13); 
   LF             CONSTANT VARCHAR2(4000) := CHR(10);
   FINAL_DE_LINHA CONSTANT VARCHAR2(4000) := CR || LF;

-------------------------------------------------------------------------------------------------------

-- Função formata o valor na mascara deseja pelo usuário 
function fkg_formata_num ( en_num in number
                         , ev_mascara in varchar2
                         )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Procedimento inicia montagem da estrutura do arquivo texto do SPED Fiscal
procedure pkb_gera_arquivo_efd ( en_aberturaefd_id in abertura_efd.id%type );

-------------------------------------------------------------------------------------------------------
end pk_gera_arq_efd;
/
