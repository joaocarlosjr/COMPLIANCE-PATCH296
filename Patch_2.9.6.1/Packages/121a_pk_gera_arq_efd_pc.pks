CREATE OR REPLACE PACKAGE CSF_OWN.PK_GERA_ARQ_EFD_PC IS

-------------------------------------------------------------------------------------------------------
-- Especificação do pacote de procedimentos de criação do arquivo da EFD PIS/COFINS  
-------------------------------------------------------------------------------------------------------
-- 
-- Em 12/01/2021   - Luis Marques - 2.9.5-4 / 2.9.6-1 / 2.9.7
-- Redmine #75053  - Erro continua ocorrendo parcialmente (feedback)
-- Rotina Alterada - PKB_TABS_TEMPS_POPULAR - Colocado trunc nos campos de data DT_SAI_ENT e DT_EMISS da nota fiscal e 
--                   DT_HR_EMISSAO e DT_SAI_ENT para do conhecimento de transporte na geração das tabelas temporárias 
--                   para que sejam lidos em todas as leituras dos registros sem necessidade de formatação.
--
-- Em 29/12/2020 - Renan Alves
-- Redmine #74705 - Revisar consolidação: código do modelo, situação, série, sub-serie, dia referência e CFOP
-- Foi alterado a forma de geração do registro D200, para que o mesmo monte os registros a partir do agrupamento: 
-- código do modelo, situação, série, sub-serie, dia referência e CFOP.
-- Foi comentado a procedure antiga e deixada na package até que sejam validados os registros do, por gentileza, 
-- não retirar a procedure comentada de dentro da package.
-- Rotina: pkb_monta_reg_d200  
-- Patch_2.9.6.1 / Patch_2.9.5.4 / Release_2.9.6
-- 
-- Em 18/12/2020 - Renan Alves
-- Redmine #74525 - Erros no registro D200
-- Nos cursores C_D200 e X, foi alterado a coluna CFOP, buscando direto da tabela CFOP.
-- Rotina: pkb_monta_reg_d200
-- Patch_2.9.5.3 / Patch_2.9.4.6 / Release_2.9.6
--
-- Em 18/12/2020   - Luiz Armando / Luis Marques - 2.9.4-6 / 2.9.5-3 / 2.9.6
-- Redmine #74464  - NOTAS NÃO ESTÃO SUBINDO PARA O SPED PIS COFINS
-- Rotina Alterada - PKB_TABS_TEMPS_POPULAR - Colocada a formatação de data (dd/mm/rrrr) nas leituras das tabelas para a 
--                   correta leitura dos dados.
-- 
-- Em 02/12/2020   - Luis Marques - 2.9.4-6 / 2.9.5-3 / 2.9.6 
-- Redmine #73929  - Problemas remanescentes no SPED Contribuicoes
-- Rotina Alterada - PKB_MONTA_REG_0140 - Ajuste na verificação do parametro ORIGEM_DADO_PESSOA.
--                 - PKB_MONTA_REG_0150 - Ajuste no cursor "c_part" para leitura do COD_PART.
--
-- Em 30/11/2020   - Luis Marques - 2.9.4-6 / 2.9.5-3 / 2.9.6
-- Redmine #73891  - Erro novamente - SPED Contribuicoes
-- Rotina Alterada - PKB_MONTA_REG_0140 - Ajuste na chamada para geração do registro 0150 para os blocos D500/C100/A100.
--
-- Em 27/11/2020 - Marcos Ferreira
-- Distribuições: 2.9.6 / 2.9.5-2 / 2.9.4-5
-- Redmine 73369: Adicionar a parametrização da Conta Contábil que será vinculada a Guia de Pagamento
-- Rotinas Alteradas: pkg_gera_guia_pgto
--
-- Em 27/11/2020   - Luis Marques - 2.9.4-6 / 2.9.5-3 / 2.9.6
-- Redmine #73857  - SPED Fiscal (E113) SPED Contribuições (C100)
-- Rotina Alterada - PKB_MONTA_REG_0140 - mudando cursor "c_cd500_ac100_pessoa" para "c_d500_ac100_pessoa" retirando
--                   bloco C500 e deixando só os bloco D500, A100 e C100.
--                   Criando novo cursor "c_c500_pessoa" para os registro C500 por causa de geração do registro 0150
--                   como "CADASTRO_PESSOA" independente do parametrizado.
--
-- Em 23/11/2020   - Luis Marques - 2.9.4-6 / 2.9.5-3 / 2.9.6
-- Redmine #73654  - Revisar caso - C500
-- Rotina Alterada - PKB_MONTA_REG_0140, PKB_MONTA_REG_C500, PKB_MONTA_REG_D100 - na geração do registro 0150 gerar 
--                   usando o parametro "ORIGEM_DADO_PESSOA" como "CADASTRO_PESSOA" para Notas Fiscais de Serviços 
--                   Continuos e para Conhecimento de Transporte.
--
-- Em 17/11/2020   - Wendel Albino  
-- Redmine #73431  - Demora geracao sped fiscal tuppeware
-- Rotina alterada : PKB_GERA_ARQUIVO_EFD_PC -> incluido parametro de sessao 'SESSION_OPTIMIZER'
-- Patch_2.9.5.2 / Release_2.9.6
-- 
-- Em 22/10/2020 - Renan Alves
-- Redmine #71611 - Speed Contribuições - M410 e M810 versus Código do Plano de Conta
-- Foi incluído a montagem do registro 0500 para o registro M400, M410, M800 e M810.
-- Rotina: pkb_monta_reg_0140
-- Patch_2.9.5.1 / Patch_2.9.4.4 / Release_2.9.6
--
-- Em 05/10/2020 - Renan Alves
-- Redmine #70364 - Erro na geração do arquivo
-- Foi incluído as notas fiscais com modelo NFCE (modelo 65) no cursor C_C170_PLANO, para que
-- seja montado os planos de contas.
-- Rotina: pkb_monta_reg_0140 
-- Patch_2.9.5.1 / Patch_2.9.4.4 / Release_2.9.6
--
-- Em 14/08/2020 - Eduardo Linden
-- Redmine #70558 - Gerar Log sobre a geração do C501 e C505 - SPED Contribuições
-- Inclusão de log para informar que os registros C501 e C505 não foram gerados.
-- Rotina alterada: PKB_MONTA_REG_C500
-- Liberado       - Release_2.9.5, Patch_2.9.4.1 e Patch_2.9.3.4
--
-- Em 13/08/2020 - Renan Alves
-- Redmine #70364 - Erro na geração do arquivo
-- Foi alterado a geração do registro D200
-- Rotina: pkb_monta_reg_d200
-- Patch_2.9.4.2 / Patch_2.9.3.5 / Release_2.9.5
--
-- Em 27/07/2020 - Marcos Ferreira
-- Distribuições: 2.9.5 / 2.9.4.2
-- Redmine #65265: Gerar guias de impostos a partir da apuração
-- Rotinas Criadas: pkg_gera_guia_pgto, pkg_estorna_guia_pgto
-- Alterações: Criação da Estrutura das Procedures
--
-- Em 27/07/2020  - Karina de Paula
-- Redmine #69928 - PIS e COFINS (ST e Retido) na NFe de Serviços (Brasília)
-- Alterações     - PKB_MONTA_REG_C100 => Alterei o objeto PK_GERA_ARQ_EFD_PC.PKB_MONTA_REG_C100 que estava enviando o imposto retido e não o imposto PIS e COFINS ST
-- Liberado       - Release_2.9.5, Patch_2.9.4.1 e Patch_2.9.3.4 
--
-- Em 21/07/2020 - Renan Alves
-- Redmine #69485 - Registros M215/M615 sendo replicados para todos os registros pai M210/M610
-- Foi alterado o parâmetro do cursor c_m215 para (rec_m210.detconscontrpis_id).
-- Foi alterado o parâmetro do cursor c_m615 para (rec_m610.detconscontrcofins_id).
-- Rotina: pkb_monta_reg_0140,
--         pkb_monta_reg_m200,
--         pkb_monta_reg_m600 
-- Patch_2.9.4.1 / Patch_2.9.3.4 / Release_2.9.5
--
-- Em 20/07/2020 - Renan Alves
-- Redmine #68855 - Conta sintética do F100 não é gerada no 0500
-- Foi adequado o cursor C_F100_PLANO para que o mesmo monte o registro 0500 a partir da natureza da operação.
-- Rotina: pkb_monta_reg_0140
-- Patch_2.9.4.1 / Patch_2.9.3.4 / Release_2.9.5
--
-- Em 10/07/2020 - Renan Alves
-- Redmine #69275 - Montagem do registro 0150 - Sped Contribuições
-- Foi alterado o cursor C_CD500_AC100_PESSOA incluindo o cursor C_PARAM 
-- onde é verificado se os CFOPs estão parametrizados para gerar o registro 0150
-- Rotina: pkb_monta_reg_0140
-- Patch_2.9.4.1 / Patch_2.9.3.4 / Release_2.9.5 
--
-- Em 08/07/2020  - Wendel Albino
-- Redmine #50147 - Criar status Calculando
-- Alterações     - PKB_MONTA_ARRAY_EFD - Criado dos status de geracao de cada bloco.
--
-- Em 03/07/2020 - Renan Alves
-- Redmine #68668 - Ctes de terceiros não sobem para o arquivo
-- Foi alterado o parâmetro empresa do cursor C_D100, pois, o cursor encontrava-se utilizando
-- o gt_row_abertura_efd_pc.empresa_id, para geração do D100, não fazendo para as filiais.
-- Rotina: pkb_monta_reg_d100 
--
-- Em 02/07/2020  - Karina de Paula
-- Redmine #57986 - [PLSQL] PIS e COFINS (ST e Retido) na NFe de Serviços (Brasília)
-- Alterações     - PKB_MONTA_REG_C100 => Inclusão dos campos vl_pis_st e vl_cofins_st
-- Liberado       - Release_2.9.5, Patch_2.9.4.1 e Patch_2.9.3.4
--
-- Em 24/06/2020 - Renan Alves 
-- Redmine #68719 - SPED Contribuições não está montando registro M100/500 para Metodo de Apropriação Direta
-- Foi alterado o if que realiza a montagem do registro M100/M500 e os demais registros.
-- Rotina: pkb_monta_reg_m100 e pkb_monta_reg_m500  
-- Patch_2.9.3.3 / Patch_2.9.2.6 / Release_2.9.4   
--   
-- Em 23/06/2020 - Allan Magrini
-- Redmine #68135 - Erro na soma dos documentos CTe's (Registro D200)
-- Foi alterado o cursor c_d200 para ajustar o agrupamento
-- Rotina: PKB_MONTA_REG_D200   
-- Patch_2.9.3.3 / Patch_2.9.2.6 / Release_2.9.4       
--
-- Em 04/06/2020 - Renan Alves
-- Redmine #68250 - Erro ao gerar os registros M410 e M810
-- Foi alterado o select dos cursores c_m410 e c_m810. Incluindo mais dois parâmetros 
-- no cursor de cada registro.
-- Rotina: pkb_monta_reg_m400 e pkb_monta_reg_m800   
-- Patch_2.9.3.3 / Patch_2.9.2.6 / Release_2.9.4   
--  
-- Em 27/05/2020 - Renan Alves
-- Redmine #67603 - Montagem errada do M400 e M800
-- Foi alterado o select dos cursores c_m400, c_m800, c_m410 e c_m810. 
-- Rotina: pkb_monta_reg_m400 e pkb_monta_reg_m800   
-- Patch_2.9.3.2 / Patch_2.9.2.5 / Release_2.9.4 
-- 
-- Em 13/05/2020 - Allan Magrini
-- Redmine #67367 - Bloco D indica movimentação, mas sai em branco
-- Foi adicionando um outer join (+) no cursor c_qtde_d500 na tabela de item da nota para trazer as notas que não tem itens
-- Rotina: PKB_MONTA_BLOCO_D       
-- 
-- Em 30/04/2020 - Renan Alves
-- Redmine #67168 - SPED Contribuições - Linhas duplicadas 
-- Foi descomentado a procedure pkb_tabs_temps_deletar, para que as tabelas temporárias sejam limpas
-- Rotina: pkb_gera_arquivo_efd_pc  
-- Patch_2.9.3.2 / Release_2.9.4 
-- 
-- Em 07/04/2020 - Renan Alves
-- Redmine #64362 - Criação do Registro 0190 somente para itens que tenham nos registros do arquivo
-- Foi alterado a geração do registro 0190 para o registro C170, incluindo dois novos cursores (c_nf e c_param)
-- Rotina: pkb_monta_reg_0140  
-- 
-- Em 13/03/2020 - Luis Marques - 2.9.3 
-- Redmine #63776 - Integração de NFSe - Aumentar Campo Razao Social do Destinatário e Logradouro
-- Rotina alterada - PKB_MONTA_REG_0150 - Alterado para recuperar 100 e 60 caracteres dos campos nome e lograd 
--                   respectivamente da nota_fiscal_dest para gravação no registro. 
--
-- Em 12/03/2020 - Renan Alves
-- Redmine #65860 - SPED não criando 0500 para CTe 
-- Foi descomentado a parte que realizava a geração do registro 0500 para o D100.
-- Rotina: pkb_monta_reg_0140 
--  
-- Em 09/03/2020 - Renan Alves
-- Redmine #65657 - Não gera 0500 do registro C501_C505
-- Foi incluído a geração do registro 0500 dentro do cursor do registro C501. 
-- Rotina: pkb_monta_reg_c500   
--  
-- Em 06/03/2020   - Allan Magrini
-- Redmine #65736  - Documentos de entrada com data de emissão de outro mês e data de entrada/saída no mês de geração não sendo considerados.
-- Alteracao: Corrigido os parametros de data do select que fornece os dados para a tmp_nota_fiscal
-- Rotina Alterada - pkb_tabs_temps_popular 
--  
-- Em 21/02/2020 - Renan Alves
-- Redmine #64589 - Ctes de entrada sendo escriturado em matriz e todas filiais
-- Foi alterado o IF que verifica a data para geração do registro 0900 
-- Rotina: pkb_monta_bloco_0  
-- 
-- Em 20/02/2020 - Allan Magrini
-- Redmine #64001 - Correção em campo DT_SAI_ENT no registro C100
-- Alteracao: Na fase 12 e 13 colocado colocada validação rec_c100.dm_ind_oper  = 1 para não popular campo DT_SAI_ENT
-- Rotina Alterada - pkb_monta_reg_c100 
--
-- Em 19/02/2020 - Allan Magrini
-- Redmine #65006 - Geração do SPED Contribuições travada
-- Corrigidos os cursores c_c170 e c_c175 para buscar as informações direto da tmp // ajustado o insert na TMP_NOTA_FISCAL e  C_FILIAIS 
-- Rotina: PKB_MONTA_REG_C100, PKB_TABS_TEMPS_POPULAR
--
-- Em 12/02/2020 - Renan Alves
-- Redmine #64589 - Ctes de entrada sendo escriturado em matriz e todas filiais
-- Foi alterado o parâmetro que gera as informações do D100, que antes estava utilizando o 
-- GT_ROW_ABERTURA_EFD_PC.EMPRESA_ID, e foi alterado para o EN_EMPRESA_ID. 
-- Rotina: pkb_monta_reg_d100 
-- 
-- Em 12/02/2020 - Renan Alves
-- Redmine #64579 - Ctes de emissão própria não sobem para o Sped Contribuições
-- Foi incluído mais uma condição de emissão própria (DM_IND_EMIT = 0), no select que alimenta a tabela temporária de 
-- conhecimento de transporte (TMP_CONHEC_TRANSP).
-- Rotina: pkb_tabs_temps_popular 
--   
-- Em 05/02/2020 - Allan Magrini
-- Redmine #64088 - Erro na estrutura SPED CONTRIBUIÇÕES - Registro 0190 fora da ordem
-- Corrigido campo vl_merc na fase 12, Colocado nvl no campo it.orig do cursor c_c170 e em INSERT INTO TMP_GERA_ARQ_EFD_PC_REG_C170
-- Rotina: pkb_monta_reg_C100, PKB_TABS_TEMPS_POPULAR
--    
-- Em 24/01/2020 - Renan Alves
-- Redmine #63838 - Adicionar F500, F510, F550 e F560 no receita bruta do 0111
-- Redmine #63825 - Adicionar Cupom SAT no registro 0111
-- Redmine #63841 - Adicionar registro 1800 para compor receita bruto do 0111 
-- Foi comentado as duas linhas que verifica o valor da alíquota do PIS e da COFINS C870 (c_item_cfe)
-- Rotina: pkb_monta_reg_c860          
--       
-- Em 16/01/2020 - Renan Alves
-- Redmine #62510 - M115 - 0500 Sped contribuições   
-- Foi incluído dois novos cursores que são referentes aos registros M100/M500 para seja cadastrado
-- a plano de conta no registro 0500.
-- Rotina: pkb_monta_reg_0140        
--    
-- Em 15/01/2020 - Renan Alves
-- Redmine #62552 - M100 -  M500 Sped contribuições - Ordenação de Tipo de Crédito
-- Foi realizado a coluna TC.CD no select dos registros M100 e M500, para a ordenação correta.
-- Rotina: pkb_monta_reg_m100 e pkb_monta_reg_m500     
--
-- Em 15/01/2020 - Allan Magrini
-- Redmine #62019 - Continua não saindo as informações do FISCO
-- Criado select nf emissao terceiro sem pessoa id no cursor c_part -- c_cd500_ac100_pessoa adicionado (+) na condição pe.id
-- cursor c_nf foi adicionado vl_outra_despesas no vl_total_item_serv
-- Rotina: pkb_monta_reg_0150,pkb_monta_reg_0140, pkb_monta_reg_c100
--     
-- Em 14/01/2020 - Renan Alves
-- Redmine #63686 - Sped Contribuições - Não está gerando D500
-- Foi incluído um alter join nos joins com as tabelas ITEM_NOTA_FISCAL e IMP_ITEMNF. Pois, não 
-- teríamos itens para notas fiscais de serviços contínuos.
-- Rotina: pkb_monta_reg_d500      
--      
-- Em 14/01/2020 - Renan Alves
-- Redmine #62106 - Montagem do registro 0900
-- Foi realizado a criação da geração do registro 0900.
-- Rotina: pkb_monta_reg_0900      
--
-- Em 14/01/2020 - Allan Magrini
-- Redmine #62019 - Continua não saindo as informações do FISCO
-- Retirada o vn_indice e funções na fase 19, criado select nf emissao própria sem pessoa id no cursor c_part 
-- Rotina: pkb_monta_reg_C100,PKB_MONTA_REG_0150
--
-- Em 13/01/2020 - Allan Magrini
-- Redmine #62019 - Registro C110 - Incluir informações do tipo Fisco
-- No cursor c_c110_quebra foi adicionado a condição  ad.dm_tipo in (0,1) -- 0 - Contribuinte/ 1 - Fisco
-- Rotina: pkb_monta_reg_C100
--  
-- Em 06/01/2020 - Renan Alves
-- Redmine #62108 - Alteração do layout do registro C500
-- Foi incluído o novo campo CHV_DOCe no registro C500, que será gerado à partir do layout 006.
-- Rotina: pkb_monta_reg_c500      
-- 
-- Em 30/12/2019 - Allan Magrini
-- Redmine #62019 - Registro C110 - Incluir informações do tipo Fisco
-- No cursor c_c110 foi adicionado a condição  ad.dm_tipo       in (0,1) -- 0 - Contribuinte/ 1 - Fisco
-- Rotina: pkb_monta_reg_C100    
-- 
-- Em 20/12/2019 - Luis Marques
-- Redmine #61818 - Feed - nao está sendo montado o registro 0150 para o C500
-- Rotina alterada: pkb_monta_reg_0150 - Incluido tratamento para notas fiscais de energia eletrica modelo "06", Gás modelo "28" 
--                  e Agua modelo "29" para retornar o codigo do participante da pessoa do documento.
--
-- Em 19/12/2019 - Luis Marques
-- Redmine #62483 - CodCta Notas de Serv.Cont.Energia Eletrica não vai para SPED
-- Rotina alterada: PKB_MONTA_REG_C500, PKB_MONTA_REG_0140 - Incluida verificação se não tiver plano de conta na 
--                  tabela de 'nf_compl_oper_pis' e na tabela 'nf_compl_oper_cofins' traz o cadastrado na nota_fiscal 
--                  coluna "COD_CTA".
--
-- Em 18/12/2019 - Luis Marques
-- Redmine #61778 - Feed - reg 0150 de terceiro não está concatenando com o ibge
-- Rotina alterada: pkb_monta_reg_0150, PKB_MONTA_REG_A100 - Incluido tratamento para notas fiscais de telecomunicação 
--                  modelos "21" e "22" Para retornar o codigo do participante da pessoa do documento e incluir tramento 
--                  para modelo "99" serviços.
--
-- Em 12/12/2019 - Eduardo Linden
-- Redmine #62303 - feed - não gerou 0500 das contas m400 e m800
-- Inclusão de uma segunda chamada da rotina pkb_monta_reg_0500, para os cursores c_f500_plano e c_f550_plano.
-- Rotina alterada: PKB_MONTA_REG_0140
--
-- Em 10/12/2019 - Luis Marques
-- Redmine #62290 - Gerando o registro D sem ter informações
-- Rotinas Alteradas: pkb_monta_reg_d600, pkb_monta_reg_d500, pkb_monta_reg_d100 e pkb_monta_bloco_d
--                    Ajustadas as query para geração dos registros D500 e D600 para ficarem iguais no bloco de 
--                    totalização D001 e Bloco_D aos blocos de dados D500 e D600.
--
-- Em 25/11/2019 - Eduardo Linden
-- Redmine #61613 - Feed - não está montando o registro 0500
-- Para trazer os planos de conta do registro M400/800 (gerados a partir das tabelas dos Registros F500/F550) para o registro 0500 , 
-- foram incluidas as functions na pk_csf utilizadas nas rotinas PK_APUR_PIS.PKB_MONTA_VETOR_M400_PREGC e PK_APUR_PIS.PKB_MONTA_VETOR_M800_PREGC.
-- Rotina alterada: PKB_MONTA_REG_0140
--
-- Em 22/11/2019 - Allan Magrini
-- Redmine #61335 - Erro ao gerar o 0500 - Contribuição
-- Correção no cursor c_c170_plano, foi colocado um alterjoin no par.empresa_id da tabela PARAM_EFD_CONTR par
-- Rotina: PKB_MONTA_REG_0140
--
-- Em 14/11/2019 - Luis Marques
-- Redmine #61290 - Unidade de Medida Cupom Fiscal Eletrônico diferente da unidade do item do cupom
-- Rotina Alterada: pkb_monta_reg_0140 - Trocada a unidade de medida da gravada no item do cumpo para a unidade de 
--                  medida gravada no item usado no cupom.
--               
-- Em 13/11/2019 - Luis Marques
-- Redmine #61233 - Duplicação de registros 0150
-- Rotina Alterada: pkb_monta_reg_0150 e pkb_monta_reg_0190 - Mudado retorno da função de concatenação fixado em 1 cod_part 
--                  para verificação de já existencia no type 'vt_tab_reg_0150' para evitar duplicação, mudado leitura da 
--                  unidade para ler por mult_org na unidade de medida.
--
-- Em 12/11/2019 - Luis Marques
-- Redmine #61083 - Feed - Após correção do bloco D, parou de concatenar o codpart com o ibge no 0150
-- Rotina Alterada: pkb_monta_reg_0150 - Ajustado para alterar o tipo de retorno pelo parametro geral e chamada da
--                  procedure no bloco "cd500_ac100_pessoa" da procedure pkb_monta_reg_0140.
--
-- Em 07/11/2019 - Luis Marques
-- Redmine #60631/#60990 - Problemas no bloco D / Defeito - está ocorrendo o mesmo erro da ficha 60589
-- Rotinas Alteradas: fkb_ret_cnpjcpj_ibge_cod_part, PKB_MONTA_BLOCO_D - Ajustado retorno na função de retorno de Cod_part
--                    por municipio e verificação no registro principal do bloco D se escritura CFOP para não gerar registro
--                    caso nenhuma nota atenda a condição de CFOP/CST. Mudado type registro 0150 para type simples zerado a 
--                    cada registro 0140.
--
-- Em 06/11/2019 - Allan Magrini
-- Redmine #60888 - Valor Contabil SAT
-- Correção no cursor c870, c880 e c491, foi somando ao valor item_cupom_fiscal.VL_ITEM_LIQ o campo item_cupom_fiscal.vl_rateio_descto
-- Rotina: PKB_MONTA_REG_C860, PKB_MONTA_REG_C490
--
-- Em 30/10/2019 - Luis Marques
-- Redmine #60419 - Sped Fiscal e Sped Contribuições
-- Nova função: fkb_ret_cnpjcpj_ibge_cod_part
-- Rotina Alterada: pkb_monta_reg_0150 - Mudado indexador para notas e conhecimentos com informações lidas do documento
--                  fiscal para concatenar cnpj ou cpf mais codigo do ibge da cidade, mudado todas as chamadas e gravação
--                  do cod_part dos registros usando nova função fkb_ret_cnpjcpj_ibge_cod_part.
--
-- Em 30/10/2019 - Allan Magrini
-- Redmine #60522 - Feed - Sped Contribuições fica somente em "Em Geração"
-- Foram feitos acertos no cursores c_c490_plano e c_c860_plano e adicionados nas chamadas deles do 0500 (fase 50.6 e 50.9) exceção quando o plano de conta
-- vem nulo, criando log de erro e não parando a geração.
-- Rotina Alterada: pkb_monta_reg_0140
--
-- Em 28/10/2019 - Luis Marques
-- Redmine #60110 - Erro Bloco 0190 (Unidade de Medida) - Sped Contribuições
-- Rotina Alterada: pkb_monta_reg_0200 - incluida chamada para a rotina pkb_monta_reg_0190 se existir unidade de 
--                  medida.
--
-- Em 25/10/2019 - Luis Marques
-- Redmine #60391 - feed - continua nao gerando o 0150 qdo é emissão própria saída para sped fiscal e contribuições
-- Rotina Alterada: pkb_monta_reg_0150 - Ajuste no identificador que para noemral é id_pessoa, para documento id do documento.
--
-- Em 25/10/2019 - Luis Marques
-- Redmine 60346 - Feed - Corrigir a descrição do parâmetro no campo dsc_param / sped fiscal e sped contribvuições
-- Rotina Alterada: pkb_monta_reg_0150 - ajuste na leitura do tipo de documento proprio/terceiro para ler os dados.
--
-- Em 22/10/2019 - Luis Marques
-- Redmine #58808 - Cidade do relatório divergente da cidade da NFe
-- Rotina Alterada: pkb_monta_reg_0150 - para ler dados da pessoa ou por cod_part ou por documento fiscal, alterada
--                  chamada em diversos blocos.
--
-- Em 18/10/2019 - Luis Marques
-- Redmine #58122 - CFOPs parametrizados para não subirem, subindo
-- Roitinas alteradas: pkb_monta_reg_D001, pkb_monta_reg_d100, pkb_monta_reg_d200, pkb_monta_reg_d500, pkb_monta_reg_d600
--                     ajustado para considerar os parametros de CFOP/CST por empresa.
--
-- Em 10/10/2019 - Luis Marques
-- Redmine #59809 - Montagem indevida de registros
-- Rotinas Alteradas: pkb_monta_reg_m100 e pkb_monta_reg_m500 - Gerar a linha do registro M100 e M500, se o 
--                    Indicador de incidencia tributaria no periodo for 1 ou 3,
-- (1-Escrituração de operações com incidência exclusivamente no regime não-cumulativo ou 
--  3-Escrituração de operações com incidência nos regimes nãocumulativo e cumulativo)
--                    ou Indicador de incidencia tributaria no periodo for 2, 
-- (2-Escrituração de operações com incidência exclusivamente no regime cumulativo)
--                    e Indicador do criterio de escrituração e apuração do regime cumulativo for 9,
-- (9-Regime de Competência - Escrituração detalhada, com base nos registros dos Blocos A, C, D e F
--                    e Indicador do regime de competencia for 2, 
-- (2-Método de Rateio Proporcional (Receita Bruta)).
--
-- Em 04/10/2019 - Allan Magrini
-- Redmine #59611  - Erro Geração 0500
-- Adicionado no cursor  c_c490_plano e c_c860_plano para pegar o plano de conta pelo multorg 
-- Rotinas Alteradas: PKB_MONTA_REG_0140
--
-- Em 01/10/2019 - Allan Magrini
-- Redmine #59382 - VALIDAÇÃO DE PLANO DE CONTAS - SPED CONTRIBUIÇÕES
-- Adicionado no cursor c_a170_plano a validação na PARAM_CFOP_EMPRESA por cfop, sendo possivel a parametrização por cfop para não gerar escrituração 
-- com o tipo de log de generico para erro_de_informacao 
-- Rotinas Alteradas: PKB_MONTA_REG_0140
--
-- Em 24/09/2019 - Luis Marques
-- Redmine #59132 - feed RELEASE 291- C491 e C495 está sendo enviado o valor zero no campo QUANT_BC_PIS e QUANT_BC_COFINS.
-- Rotina Alterada: PKB_MONTA_REG_C490 - Ajustado para se o valor for menor ou igual a zeor não mostrar o valor
--                  dos campos "vl_bc_prod_pis" e "vl_bc_prod_cof" na geração dos registrp C491 e C495.
--
-- Em 17/09/2019 - Allan Magrini
-- Redmine #58873 - F600 - não está sendo agrupado qdo o registro está igual
-- Ajustado no select do cursor "c_f600", agrupado as colunas DM_IND_NAT_RET, DT_RET, COD_REC, DM_IND_NAT_REC,
--  CNPJ, DM_IND_DEC somando os valores contidos nas colunas VL_BC_RET, VL_REC, VL_RET_PIS, VL_RET_COFINS.  
-- Rotinas Alteradas: PKB_MONTA_REG_F60
--
-- Em 09/09/2019 - Allan Magrini 
-- Redmine #58540 - VALIDAÇÃO DE PLANO DE CONTAS - SPED CONTRIBUIÇÕES
-- Adicionado no cursor c_c170_plano a validação na PARAM_CFOP_EMPRESA por cfop, sendo possivel a parametrização por cfop para não gerar escrituração 
-- com isso foi retirada a validação do indicador da incidência tributária no período com os cst informados pela equipe de suporte Redmine #57646 no cursor c_c170_plano
-- Alterado o tipo de log de generico para erro_de_informacao
-- Rotinas Alteradas: PKB_MONTA_REG_0140
--
-- Em 29/08/2019 - Allan Magrini 
-- Redmine #58535 - Erro no SPED Contribuições  
-- Adicionado no cursor c_c170_plano a condição  rownum = 1 pelo motivo de se ter o cod_cta em todas filiais do multorg, dando erro no cursor
-- Rotinas Alteradas: PKB_MONTA_REG_0140
--
-- Em 04/09/2019 - Renan Alves
-- Redmine #58250 - Considerar NRO_AUT_NFSna montagem do A100 de terceiros
-- Foi alterado a coluna que retornava o NRO_NF que tinha vários decode para um nvl.
-- Rotinas: pkb_monta_reg_a100
--
-- Em 29/08/2019 - Allan Magrini 
-- Redmine #58107 - Erro no cliente U.S.J. - ACUCAR E ALCOOL S/A
-- Corrigido no c_c170_plano para pegar o id da empresa da abertura efd e ajuste no if da fase 44.1 (r_reg.planoconta_id is null and r_reg.cod_cta is null)
-- Rotinas Alteradas: PKB_MONTA_REG_0140
--
-- Em 16/08/2019 - Allan Magrini
-- Redmine #57729 - Verificar o pq está saindo o plano de conta 7 no registro 0500 sendo que não há documentos fiscais com ele
-- Corrigidos os cursor c_c490_plano e c_c860_plano para validar a data do cupom fiscal com o período da abertura efd.
-- Rotinas Alteradas: PKB_MONTA_REG_0140
--
-- Em 16/08/2019 - Allan Magrini
-- Redmine #57646 - Validação Indevida de Plano de Conta Contábil Para Geração do Arquivo
-- No cursor c_c170_plano foi adicionado validação do indicador da incidência tributária no período com os cst informados pela equipe de suporte
-- corrigido o log da fase 44.1
-- Rotinas Alteradas: PKB_MONTA_REG_0140
--
-- Em 14/08/2019 - Allan Magrini
-- Redmine #57354 - está trazendo uma conta contábil que não é da empresa
-- No cursor c_c170_plano foi retirado o join na tabela plano_conta e colocado 
-- como substring e com amarração de empresa para não duplicar as contas
-- Rotinas Alteradas: PKB_MONTA_REG_0140
--
-- Em 07/08/2019 - Allan Magrini
-- Redmine #56649 - F600 - agrupar registro na geração do SPED CONTRIBUIÇÕES
-- Ajustado no select do cursor "c_f600", agrupado as colunas DM_IND_NAT_RET, DT_RET, COD_REC, DM_IND_NAT_REC,
--  CNPJ, DM_IND_DEC somando os valores contidos nas colunas VL_BC_RET, VL_REC, VL_RET_PIS, VL_RET_COFINS.  
-- Rotinas Alteradas: PKB_MONTA_REG_F60
--
-- Em 01/08/2019 - Karina de Paula
-- Redmine #56747 - Geração de Registro C111 no Sped PIS/COFINS indevidamente
-- Rotinas Alteradas: PKB_MONTA_REG_C100 - somente irá criar C111 se for origem de processo 1, 3 e 9
-- 0	SEFAZ             - NÃO entra para SPED Contribuições PIS/COFINS
-- 1	Justiça Federal   - ENTRA para SPED Contribuições PIS/COFINS
-- 2	Justiça Estadual  - NÃO entra para SPED Contribuições PIS/COFINS
-- 3	Secex/RFB         - ENTRA para SPED Contribuições PIS/COFINS
-- 9	Outros            - ENTRA para SPED Contribuições PIS/COFINS
--
-- Em 25/07/2019 - Luis Marques
-- Redmine #56578 - Erro de Validação no PVA
-- Ajustado registro C490 conforme o manual do Sped Contribuições
-- Rotinas Alteradas: PKB_MONTA_REG_C490, PKB_MONTA_REG_C860, PKB_MONTA_REG_0140
--
-- Em 19/07/2019 - Renan Alves
-- Redmine #56459 - Mais de um registro M200/M400 no mesmo arquivo - Recorrente 
-- Foi incluído o filtro da EMPRESA_ID referente a ABERTURA_EFD_PC, no where do cursor C_M200 da procedure 
-- que monta o registro m200 e no cursor C_M600 da procedure que monta o registro m600.
-- Rotina: pkb_monta_reg_m200 e pkb_monta_reg_m600 
--                 
-- Em 19/07/2019 - Luis Marques
-- Redmine #56551 - feed - Continua não gerando o C490
-- Rotina Alterada: PKB_MONTA_REG_C490 - Retirada verificação de aliquota de PIS e COFINS maior que
--                  zero, colocada verificação da situação tributária contante no manual para os
--                  registros C491 - PIS e C495 - COFINS
--
-- Em 18/07/2019 - Luis Marques
-- Redmine #56441 - feed - Não gerou C490
-- Rotinas Alteradas: PKB_MONTA_REG_C001, PKB_MONTA_BLOCO_C e PKB_MONTA_REG_C400 para
--                    incluir bloco C490 dentro do bloco C400, geração e totalização do
--                    SPED Contribuições
--
-- Em 10/07/2019 - Luis Marques
-- Redmine #44363 - Inclusão do novo - Cupom Fiscal Eletrônico CF-e ECF, codigo 60
-- Criado PKB_MONTA_REG_0490 - Cupom Fiscal Eletrônico CF-e ECF, codigo 60
-- Rotinas Alteradas: PKB_MONTA_REG_9900, PKB_MONTA_REG_C990, PKB_MONTA_REG_C001, PKB_MONTA_BLOCO_C, 
--                    PKB_INICIA_DADOS, Colocado conjunto C490 no processo de geração e totalização 
--                    do SPED Contribuições
--
-- Em 05/07/2019 - Allan Magrini
-- Redmine #55830 - Limpeza de caracteres especiais na exportação do arquivo
-- Alterada a PKB_MONTA_REG_0150 no cursor c_part para adicionar a função pk_csf.fkg_converte nos campos :
-- pessoa.nome, pessoa.lograd, pessoa.NRO, pessoa.COMPL, pessoa.BAIRRO
-- Alterada a PKB_MONTA_REG_0000 no cursor c_efd para adicionar a função pk_csf.fkg_converte nos campos :
-- pessoa.nome 
-- Rotina: PKB_MONTA_REG_0150 e PKB_MONTA_REG_0000 
--
-- Em 11/04/2019 - Renan Alves.
-- Redmine #53372 - ERRO AO GERAR EFD CONTRIBUIÇÕES.
-- Foi alterado o cursor C_AC170_ITEM, incluindo os cursores C_AC170_NF_ITEM, C_PARAM e C_AC170_ITEM.
-- Rotinas: pkb_monta_reg_0140
--
-- Em 10/04/2019 - Renan Alves.
-- Redmine #53195 - ERRO AO GERAR EFD CONTRIBUIÇÕES.
-- No cursor C_NFS foi alterado o valor do decode das colunas NRO_AUT_NFS e NRO_NF), pois, ele esperava 
-- um valor "varchar" e estava sendo comparado com um valor "number".
-- Rotinas: pkb_monta_reg_a100
--
-- Em 05/04/2019 - Renan Alves.
-- Redmine #53079 - Erros no SPED Contribuições.
-- Foi alimentado a variável vv_existe com o valor de "N" após inicializar o cursor REC_A100.
-- Rotinas: pkb_monta_reg_a100
--
-- Em 25/03/2019 - Angela Inês.
-- Redmine #31021 - SPED Contribuições - NFE Inutilizadas.
-- Considerar as Inutilizações sem vínculo com Nota Fiscal, na montagem do Registro C100.
-- Rotinas: pkb_monta_bloco_c, pkb_monta_reg_c001 e pkb_monta_reg_c100.
-- Considerar as Inutilizações sem vínculo com Conhecimento de Transporte, na montagem do Registro D100.
-- Rotinas: pkb_monta_bloco_d, pkb_monta_reg_d001 e pkb_monta_reg_d100.
--
-- Em 20/03/2019 - Eduardo Linden
-- Redmine #52572 - Ajuste no registro C120 - EFD Contribuições
-- retirada do campo cfop_id no cursor c_c120 a fim de evitar problemas com o PVA
-- Rotina: PKB_MONTA_REG_C100
--
-- Em 06/03/2019 - Angela Inês.
-- Redmine #47912 - Demora na geração do EFD contribuições.
-- Redmine #48831 - Erro de validação após atualização da package.
-- Eliminar os comentários dos processos.
-- Rotinas: todas.
--
-- Em 01/03/2019 - Angela Inês.
-- Redmine #47912 - Demora na geração do EFD contribuições.
-- 1) Alterar os valores de datas inicial e final para considerar a hora, dos parâmetros de abertura, no início do processo para não utilizar o TRUNC.
-- Rotina: pkb_inicia_param.
-- 2) Eliminar o trunc nas datas inicial e final da abertura e das tabelas em questão.
-- Rotinas: PKB_MONTA_REG_P200/P010/P001, PKB_MONTA_REG_M800/M700/M600/M500/M400/M300/M200/M100/M001, PKB_MONTA_REG_I010/I001, PKB_MONTA_REG_F800,
-- PKB_MONTA_REG_F600/F100/F001/F, PKB_MONTA_REG_D600/D500/D100/D001/D, PKB_MONTA_REG_C860/C500/C400/C380/C100/C001/C, PKB_MONTA_REG_A100/A001/A,
-- PKB_MONTA_REG_0200/0140, e, PKB_VALIDA_PLCTA_CCUSTO.
-- 3) Alterar as condições com função dentro dos processos.
-- Rotinas: PKB_MONTA_REG_C400/C380/C100/C001/C, PKB_MONTA_REG_A100/A001/A, PKB_MONTA_REG_0140.
-- 4) Considerar a empresa da abertura do arquivo, teoricamente a matriz, para recuperar a base de cálculo de crédito, além do CFOP vinculado ao documento fiscal.
-- Rotina: pkb_monta_reg_c500.
-- Redmine #48831 - Erro de validação após atualização da package.
-- Após atualizar a package de geração do EFD Contribuições, o arquivo passou a ser gerado com erros de validação identificados pelo PVA.
-- Pelo que entendi são problemas nas datas utilizadas nos filtros para buscar os documentos que devem ser levados para o arquivo. Os erros do M100/M500 e
-- filhos já existiam na geração anterior.
-- Voltamos a alterar das condições de data em função do parâmetro de escrituração (ct/nf = conhec_trans/nota_fiscal; em = empresa; ae = abertura_efd_pc), para:
-- and ((ct/nf.dm_ind_emit = 1 and nvl(ct/nf.dt_sai_ent,ct.dt_hr_emissao) between ae.dt_ini and ae.dt_fin)
--      or
--     (ct/nf.dm_ind_emit = 0 and ct/nf.dm_ind_oper = 1 and ct/nf.dt_hr_emissao between ae.dt_ini and ae.dt_fin)
--      or
--     (ct/nf.dm_ind_emit = 0 and ct/nf.dm_ind_oper = 0 and em.dm_dt_escr_dfepoe = 0 and ct/nf.dt_hr_emissao between ae.dt_ini and ae.dt_fin)
--      or
--     (ct/nf.dm_ind_emit = 0 and ct/nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and nvl(ct/nf.dt_sai_ent,ct/nf.dt_hr_emissao) between ae.dt_ini and ae.dt_fin))
-- Rotinas: pkb_monta_reg_d500, pkb_monta_reg_d100, pkb_monta_reg_d001, pkb_monta_bloco_d, pkb_monta_reg_c500, pkb_monta_reg_c100, pkb_monta_reg_c001,
-- pkb_monta_bloco_c, pkb_monta_reg_a100, pkb_monta_reg_a001, pkb_monta_bloco_a, pkb_monta_reg_0140, e, pkb_valida_plcta_ccusto.
--
-- Em 14/02/2019 - Marcos Ferreira
-- Redmine #51462 - Alterações PLSQL para atender layout 005 (vigência 01/2019).
-- Rotina: pkb_monta_reg_1050
-- Alteração: Criação da Procedure
--
-- Em 14/02/2019 - Renan Alves.
-- Redmine #51574 - Geração dos registros M215, M615 e 1050.
-- Alteração: Foi criado o cursor C_M215 e as informações que cria o registro da M215.
-- Rotina: PKB_MONTA_REG_M200.
-- Alteração: Foi cirado o cursor C_M615 e as informações que cria o registro da M615.
-- Rotina: PKB_MONTA_REG_M600.
--
-- Em 13/02/2019 - Renan Alves
-- Redmine #51462 - Alterações PLSQL para atender layout 005 (vigência 01/2019).
-- Foi comentado a linha aonde existia um substr na coluna NRO_DI.
-- Rotina: pkb_monta_reg_c100.
-- Foram incluidas às colunas VL_AJUS_ACRES_BC_COFINS, VL_AJUS_REDUC_BC_COFINS, VL_BC_CONT_AJUS
-- Rotina: pkb_monta_reg_m600.
-- Foram incluidas às colunas VL_AJUS_ACRES_BC_PIS, VL_AJUS_REDUC_BC_PIS, VL_BC_CONT_AJUS
-- Rotina: pkb_monta_reg_m200.
--
-- Em 06/02/2019 - Marcos Ferreira
-- Redmine #51260 - Sped Contribuiçõs - Nova versão de do Layout a Partir de Janeiro de 2019 - Criação de Scripts e Alteração de Objetos de Banco
-- Solicitação: Adequar layout 1.28
-- Alterações: Inclusão de novos campos com controle de versão 005
-- Procedures Alteradas: pkb_monta_reg_m200, pkb_monta_reg_m600
--
-- Em 06/02/2019 - Marcos Ferreira
-- Redmine #51260 - Sped Contribuiçõs - Nova versão de do Layout a Partir de Janeiro de 2019 - Criação de Scripts e Alteração de Objetos de Banco
-- Solicitação: Adequar layout 1.28
-- Alterações: Inclusão de novos campos com controle de versão 005
-- Procedures Alteradas: pkb_monta_reg_m200, pkb_monta_reg_m600
--
-- Em 24/01/2019 - Angela Inês.
-- Redmine #50868 - Alteração na montagem dos Registros 0150 e A100 - NFS.
-- 1) Ao montar o registro 0150 de nota fiscal de serviço, modelo 99 e emissão própria, verificar se o participante é pessoa física e o CPF é 99999999999999.
-- Neste caso, não montar o registro 0150.
-- 2) Ao montar o registro A100 de nota fiscal de serviço, modelo 99 e emissão própria, verificar se o participante é pessoa física e o CPF é 99999999999999.
-- Neste caso, não montar no registro A100 o código do participante, deixar nulo.
-- Rotinas: pkb_monta_reg_0140 e pkb_monta_reg_c100.
--
-- Em 22/01/2019 - Marcos Ferreira
-- Redmine #49574: GERAÇÃO DO REGISTRO 0150
-- Solicitação: A rotina está gerando dados de participante no Registro 0150, mas não tem documentos fiscais relacionados a ele
-- Alterações: Correção do cursor de participantes (c_cd500_ac100_pessoa), incluído filtro por cod_st igual a query de notas mercantis (PKB_MONTA_REG_C100)
-- Procedures Alteradas: PKB_MONTA_REG_0140
--
-- Em 10/12/2018 - Angela Inês.
-- Redmine #49503 - Alteração nos Processos de Validação e Geração do Arquivo Sped EFD-Contribuições - PIS e COFINS - Formato de data.
-- Processo de Geração do Arquivo: Alguns registros são gerados ou não, de acordo com a Data Inicial de Abertura do Arquivo, considerando as datas do manual do Sped.
-- Tecnicamente, ao fazer esse teste não estamos utilizando o comando correto para formatação de data. Passar a utilizar o comando "TO_DATE" com o formato "DD/MM/RRRR".
-- Rotinas: pkb_monta_reg_0200, pkb_monta_array_efd, pkb_monta_reg_1600, pkb_monta_reg_1500, pkb_monta_reg_1200 e pkb_monta_reg_1100.
--
-- Em 05/12/2018 - Angela Inês.
-- Redmine #49416 - Registro D200 - Plano de Contas.
-- Não obrigar que os impostos PIS e COFINS tenham plano de contas, pois os mesmos serão gerados como "Erro" pelo validador PVA, e será necessário que o cliente
-- faça a correção ou passe pelo processo de atualização automática de plano de contas do EFD-Contribuições.
-- Rotina: pkb_monta_reg_d200.
--
-- Em 04/12/2018 - Angela Inês.
-- Redmine #49297 - Especificação para geração do registro D200.
-- 1) Geração do Arquivo Sped EFD-Contribuições - Conhecimento de Transporte.
-- Em todos os processos que utiliza o Conhecimento de Transporte, passar a considerar os modelos fiscais "63-Bilhete de Passagem Eletrônico -  BP-e" e
-- "67-Conhecimento de Transporte Eletrônico - Outros Serviços".
-- Rotinas: pkb_monta_reg_d001, pkb_monta_reg_0140 e pkb_valida_plcta_ccusto.
-- 2) Geração do Arquivo Sped EFD-Contribuições - Registro D100.
-- Considerar os conhecimentos de transporte cuja operação seja "Entrada" (conhec_transp.dm_ind_oper=0), podendo ser de "Emissão Própria" ou de "Terceiro"
-- (conhec_transp.dm_ind_emit=0/=1).
-- Rotinas: pkb_monta_reg_d100, pkb_monta_reg_d001, pkb_monta_bloco_d, pkb_monta_reg_0140 e pkb_valida_plcta_ccusto.
-- 3) Geração do Arquivo Sped EFD-Contribuições - Registro D200.
-- Considerar para consolidação os conhecimentos de transporte autorizados (conhec_transp.dm_st_proc=4), não seja de armazenamento (conhec_transp.dm_arm_nf_terc=0),
-- operação de "Saída" (conhec_transp.dm_ind_oper=1), e emissão seja de "Emissão Própria" (conhec_transp.dm_ind_emit=0). Para os modelos fiscais, considerar: "07-
-- Nota Fiscal de Serviço de Transporte", "08-Conhecimento de Transporte Rodoviário de Cargas", "8B-Conhecimento de Transporte de Cargas Avulso", "09-Conhecimento
-- de Transporte Aquaviário de Cargas", "10-Conhecimento Aéreo", "11-Conhecimento de Transporte Ferroviário de Cargas", "26-Conhecimento de Transporte Multimodal
-- de Cargas", "27-Nota Fiscal De Transporte Ferroviário De Carga", "57-Conhecimento de Transporte Eletrônico", "63-Bilhete de Passagem Eletrônico - BP-e" e "67-
-- Conhecimento de Transporte Eletrônico - Outros Serviços". Os valores serão agrupados por modelo fiscal (mod_fiscal.cod_mod), situação do documento (sit_docto.cd),
-- série (conhec_transp.serie), sub-série (conhec_transp.subserie), CFOP (conhec_transp.cfop), e data de emissão (conhec_transp.dt_hr_emissao). Nesse agrupamento
-- estaremos incluindo como Número do CT, um Inicial e um Final.
-- Para cada agrupamento do registro D200, teremos os valores dos Registros D201, totalizando os valores de PIS, e dos Registros D205, totalizando os valores da
-- COFINS. Em seguida, para o mesmo agrupamento do registro D200, teremos as informações de Processo Referenciado, dos Registros D209.
-- As contas contábeis que estiverem vinculadas nos Registros D201 e D205, deverão estar informadas no Registro 0500.
-- Rotinas: pkb_monta_reg_d200, pkb_monta_reg_d001, pkb_monta_bloco_d, pkb_monta_reg_0140 e pkb_valida_plcta_ccusto.
--
-- Em 14/11/2018 - Angela Inês.
-- Redmine #48735 - Geração do Arquivo - Registro C500 - Nota Fiscal de modelo 55 e vinculado com CFOP de energia elétrica.
-- Considerar a empresa da abertura do arquivo, teoricamente a matriz, para recuperar a base de cálculo de crédito, além do CFOP vinculado ao documento fiscal.
-- Rotina: pkb_monta_reg_c500.
--
-- Em 29/10/2018 - Eduardo Linden
-- Redmine #48152 - Tabela de Operações Geradoras de Crédito de PIS/COFINS - Incluir Identificador da Empresa.
-- Inclusão da coluna empresa_id da tabela oper_ger_cred_pc nas clausulas dos cursores c_501_55 e c_505_55.
-- Rotina: PKB_MONTA_REG_C500.
--
-- Em 25/10/2018 - Angela Inês.
-- Redmine #48121 - Correção no processo de Geração do Sped EFD-Contribuições - Registros 0150 e 0200.
-- Ao recuperar os documentos fiscais para montagem dos registros 0150 - Cadastro de Pessoa e 0200 - Cadastro de Item, não exigir que os documentos fiscais,
-- possuam impostos PIS e/ou COFINS do tipo Imposto, pois esses impostos podem ser de Retenção.
-- Por esse motivo as informações mencionadas na atividade não estão montando os registros corretamente. As Notas Fiscais de Serviço estão com Impostos PIS e/ou
-- COFINS, do Tipo Retenção.
-- Rotina: pkb_monta_reg_0140.
--
-- Em 01/10/2018 - Marcos Ferreira
-- Redmine #46942 - Geração de cadastro de plano contas - 0500 para CTe (Otto)
-- Solicitação: Para Geração do Registro 0500 (Cadastro Plano Conta) considerar também as contas do cabeçalho do conhecimento de transporte
-- Alterações: Incluído query para buscar também as contas contábeis de conhec_transp.cod_cta
-- Procedures Alteradas: PKB_MONTA_REG_0140
--
-- Em 26/09/2018 - Marcos Ferreira
-- Redmine #44336 - Inclusão de novos registros no Bloco D
-- Solicitação: Mediante ao novo layout do governo, avaliar e fazer as alterações necessárias
-- Alterações: Avaliação de todo o layout e alteração do cursor c_qtde_d100 com a inclusão dos novos modelos fiscais
-- Procedures Alteradas: PKB_MONTA_BLOCO_D, PKB_MONTA_REG_D100
--
-- Em 31/07/2018 - Angela Inês.
-- Redmine #45556 - Alteração na geração do arquivo - Registro A100/A170 - Itens da Nota Fiscal de Serviço.
-- Verificar se o código de versão do layout é "004", e identificar se a Nota Fiscal de Serviço - Modelo 99, é de Operação de Saída. Neste caso não informar o
-- campo de Indicador de Origem de Crédito, no Registro A170. Informar somente para Notas de Operação de Entrada. Com os códigos de versões de layout anteriores
-- a "004", manter o que já temos hoje. Informamos o Indicador de Origem de Crédito independente da Operação da Nota.
-- Rotina: pkb_monta_reg_a100.
--
-- Em 27/07/2018 - Angela Inês.
-- Redmine #45001 - Correção na geração do arquivo EFD-Contribuições - Registro 0200 - Cadastro de Item.
-- Acertar a montagem do registro 0200 - Cadastro de Item, pois existem notas fiscais com vários itens, e nem todos estão com CST tributável, portanto,
-- os itens/produtos vinculados com os itens das notas fiscais que possuem CST não tributável devem sair no cadastro de item.
-- Rotina: pkb_monta_reg_0140, cursores: c_d100_pessoa, c_ac170_item e c_d100_infcompl.
--
-- Em 26/07/2018 - Angela Inês.
-- Redmine #45364 - Correção na montagem do Registro C170 - Natureza de Operação.
-- Ao informar o campo referente a natureza de operação, NAT_OPER, no registro C170, estamos informando o Identificador (ID), e não o Código (COD_NAT).
-- Passar a informar o Código (COD_NAT).
-- Rotina: pkb_monta_reg_C100.
--
-- Em 24/07/2018 - Angela Inês.
-- Redmine #45284 - Correção na Apuração de PIS e COFINS - Blocos 1300 e 1700.
-- A) Os valores a serem lançados no arquivo dos registros do Bloco 1300 e 1700, serão do mês corrente, do mês da abertura do arquivo.
-- B) Verificar o processo da Consolidação para geração automática dos Blocos 1300 e 1700.
--
-- Em 13/07/2018 - Angela Inês.
-- Redmine #45001 - Correção na geração do arquivo EFD-Contribuições - Registro 0200 - Cadastro de Item.
-- Acertar a montagem do registro 0200 - Cadastro de Item, pois existem notas fiscais com vários itens, e nem todos estão com CST tributável, portanto,
-- os itens/produtos vinculados com os itens das notas fiscais que possuem CST não tributável devem sair no cadastro de item.
-- Rotina: pkb_monta_reg_0140, cursores: c_d100_pessoa, c_ac170_item e c_d100_infcompl.
--
-- Em 06/07/2018 - Karina de Paula
-- Redmine #44759 - Melhoria Apuração PIS/COFINS - Bloco F100
-- Rotina Alterada: PKB_MONTA_REG_F100 / PKB_MONTA_REG_F001 / PKB_MONTA_BLOCO_F / PKB_MONTA_REG_0140 => Retirada a verificação dm_gera_receita
--
-- Em 02/07/2018 - Angela Inês.
-- Redmine #44597 - Correção na montagem do arquivo - registro C100/C175.
-- Rotina: pkb_monta_reg_c100.
--
-- Em 30/06/2018 - Angela Inês.
-- Redmine #44515 - Processo do Sped EFD-Contribuições: Cálculo, Validação e Geração do Arquivo.
-- Revisar todos os processos de Cálculo, Validação e Geração do Arquivo Sped EFD-Contribuições.
-- Rotinas: pkb_monta_reg_c860, pkb_monta_reg_c400, pkb_monta_reg_c380, pkb_monta_reg_c100, pkb_monta_reg_c001, pkb_monta_bloco_c, pkb_monta_reg_a100,
-- pkb_monta_reg_a001, pkb_monta_bloco_a, pkb_monta_reg_0140, e pkb_valida_plcta_ccusto.
--
-- Em 26/06/2018 - Marcos Ferreira
-- Redmine: #44234 - Erro ao gerar registro 0500 para alguns registros do C170
-- Problema: O validador criticava na hora de validar o campo C170, dizendo que a conta contábil
--           do item não estava na coleção do bloco 0500
-- Solução: Correção da clausula Where do bloco 0500, cursor c_cta_ref, corrigido origem das datas da tabela pc_referen
-- Rotina: PKB_MONTA_REG_0500
--
-- Em 20/06/2018 - Marcos Ferreira
-- Redmine: #42588 - Performance - A geração está muito demorada
-- Problema: A Geração do arquivo está muito lenta
-- Solução: Melhoria no Join dos cursores do Bloco C001
--
-- Em 24/04/2018 - Karina de Paula
-- Redmine #41878 - Novo processo para o registro Bloco F100 - Demais Documentos e Operações Geradoras de Contribuições e Créditos.
-- Incluída a verificação do campo dm_gera_receita = 1, nos objetos abaixo:
-- -- Rotina Alterada: PKB_MONTA_REG_F100 - Alterado o select do cursor c_f100
-- -- Rotina Alterada: PKB_MONTA_REG_F001 - Alterado o select que conta a qtd de registros da dem_doc_oper_ger_cc
-- -- Rotina Alterada: PKB_MONTA_BLOCO_F  - Alterado o select do cursor c_qtde_f100
-- -- Rotina Alterada: PKB_MONTA_REG_0140 - Alterado o select do cursor c_f100_pessoa / c_f100_unid / c_f100_item / c_f100_plano / c_f100_custo
-- -- Rotina Alterada: PKB_VALIDA_PLCTA_CCUSTO - Alterado o select do cursor c_f100_f120_f130_f150_plano / c_f100_f120_f130_custo
--
-- Em 16/04/2018 - Marcos Ferreira.
-- Redmine: #41435 - Processos - Criação de Parâmetros CST de PIS e COFINS para Geração e Apuração do EFD-Contribuições.
-- Alterado Procedure PKB_MONTA_REG_C860: Alterado query de vn_fase = 2, incluído relacionamento com a tabela imp_itemcf
-- e tipo_imposto para recuperar o tipoimposto_cd e codst_id para parametrizar as funções fkg_gera_escr_efdpc_cfop_empr
-- e fkg_dmgeraajusm210_parcfopempr
--
-- Procedure: PKB_MONTA_REG_C860:
--            vn_fase = 2 => inclusão do parãmetro de cst nas funções da query
--
-- Procedure: PKB_MONTA_REG_C400:
--            Alteração do Cursor c_400
--
-- Procedure: PKB_MONTA_REG_C380:
--            Alteração do Cursor c_c380, c_c381
--
-- Procedure: PKB_MONTA_REG_C100:
--            vn_fase = 4: Parametrização da função com os novos parametros de cst
--            Alteração cursor c_c170: Incluído campos codcst_id_pis e codcst_id_cofins
--            Alteração vn_fase = 37: Incluído parâmetros de cst na função
--
-- Procedure: PKB_MONTA_REG_C001:
--            vn_fase = 1: Incluído parametros de cst na query
--            vn_fase = 5: Incluído parametros de cst na query
--
-- Procedure: PKB_MONTA_BLOCO_C:
--            Parametrização com código cst no cursor c_qtde_c100 e c_qtde_c400
--
-- Procedure: PKB_MONTA_REG_A100:
--            vn_fase = 1.1: Incluído na query, na chamada de função, os parâmetros de CST
--            vn_fase = 22: Incluído no if, os parametros de cst nas funções
--            Cursor: c_imp: Incluído campo codst_id_pis e codst_id_cofins na query
--            vn_fase = 17: Incluído no if, os parametros de cst nas funções
--
-- Procedure: PKB_MONTA_REG_A001:
--            vn_fase = 1: Incluído parâmetors de cst nas funções da query
--
-- Procedure: PKB_MONTA_BLOCO_A:
--            Cursor: c_qtde_nfs - Incluido parâmetros de cst na função
--
-- Procedure: PKB_MONTA_REG_0140:
--            Cursor c_cd500_pessoa: Incluído colunas tipoimposto_cd, id codst_id na query
--            vn_fase = 11.2: Alterado a chamada das funções de cst, passando os novos parâmetros
--            Cursor: c_481_485: Incluído coluna codst_id na query
--            vn_fase = 21: Alterado a chamada das funções de cst, passando os novos parâmetros
--
--            Cursor c_c170_unid: Incluído colunas tipoimposto_cd, id codst_id na query
--            vn_fase = 19.1: Alterado a chamada das funções de cst, passando os novos parâmetros
--
--            Cursor c_c860_unid: Incluído campo codst_id
--            vn_fase = 22.1: Incluído parâmetro en_codst_id_pis na chamada das funções
--                            fkg_gera_escr_efdpc_cfop_empr e fkg_dmgeraajusm210_parcfopempr
--
--            Cursor: c_ac170_item: Incluído campos tipoimposto_cd e codst_id
--            vn_fase = 26: Incluído parâmetro en_codst_id_pis e  en_codst_id_cofins na chamada das funções
--                          fkg_gera_escr_efdpc_cfop_empr e fkg_dmgeraajusm210_parcfopempr
--
--            Cursor: c_c380_item: Incluído campos codst_id_pis e codst_id_cofins
--            vn_fase = 28: Incluído parâmetro en_codst_id_pis e  en_codst_id_cofins na chamada das funções
--                          fkg_gera_escr_efdpc_cfop_empr e fkg_dmgeraajusm210_parcfopempr
--
--            Cursor: c_1101_item: tipoimposto_cd e codst_id
--            vn_fase = 30: Incluído parâmetro en_codst_id_pis e  en_codst_id_cofins na chamada das funções
--                          fkg_gera_escr_efdpc_cfop_empr e fkg_dmgeraajusm210_parcfopempr
--
--            Cursor: c_c481_item: Incluído campo codst_id_pis
--            vn_fase = 32: Movido as chamadas das funções fkg_gera_escr_efdpc_cfop_empr e fkg_dmgeraajusm210_parcfopempr
--                          para dentro do cursor r_c481 para poder pegar o codst_id do pis
--
--            Cursor: c_c860_item: Incluído campo codst_id_pis na query
--            vn_fase = 34: Incluído parâmetro en_codst_id_pis na chamada das funções
--                          fkg_gera_escr_efdpc_cfop_empr e fkg_dmgeraajusm210_parcfopempr
--
--            Cursor: c_c170_natoper Incluído colunas codst_id_pis, codst_id_cofins na query
--            vn_fase = 36.1: Alterado validação do IF para contemplar a checagem por pis e cofins
--
--            Cursor: c_cd500_infcompl: Incluído campo codst_id_pis e codst_id_cofins na query
--            vn_fase = 38.3: Alterado validação do IF para contemplar a checagem por pis e cofins
--            vn_fase = 38.5: Alterado clausula where na validação das funções fkg_gera_escr_efdpc_cfop_empr e fkg_dmgeraajusm210_parcfopempr
--                            Incluído parâmetros de cst para pis e cofins
--
--            Cursor: c_c170_plano: Incluído campo codst_id_pis e Incluído campo codst_id_cofins na query
--            vn_fase = 44: Alterado validação do IF para contemplar a checagem por pis e cofins
--
--            Cursor: c_a170_plano: Incluído campo codst_id_pis e Incluído campo codst_id_cofins na query
--            vn_fase = 46: Alterado validação do IF para contemplar a checagem por pis e cofins
--
--            Cursor: c_c380_plano: Incluído campo codst_id_pis e Incluído campo codst_id_cofins na query
--            vn_fase = 48: Alterado validação do IF para contemplar a checagem por pis e cofins
--
--            Cursor: c_c481_c485_plano: Incluído campo codst_id_pis e Incluído campo codst_id_cofins na query
--            vn_fase = 50: Alterado validação do IF para contemplar a checagem por pis e cofins
--
--            Cursor: c_a170_custo: Incluído campo codst_id_pis e Incluído campo codst_id_cofins na query
--            vn_fase = 75.1: Alterado validação do IF para contemplar a checagem por pis e cofins
--
-- Procedure: PKB_VALIDA_PLCTA_CCUSTO:
--            Cursor: c_c170_plano: Incluído campo codst_id_pis e Incluído campo codst_id_cofins na query
--            vn_fase = 5.1: Alterado validação do IF para contemplar a checagem por pis e cofins
--
--            Cursor: c_a170_plano: Incluído campo codst_id_pis e Incluído campo codst_id_cofins na query
--            vn_fase = 6.1: Alterado validação do IF para contemplar a checagem por pis e cofins
--
--            Cursor: c_c380_plano: Incluído campo codst_id_pis e Incluído campo codst_id_cofins na query
--            vn_fase = 7.1: Alterado validação do IF para contemplar a checagem por pis e cofins
--
--            Cursor: c_c481_c485_plano: Incluído campo codst_id_pis e Incluído campo codst_id_cofins na query
--            vn_fase = 8.1: Alterado validação do IF para contemplar a checagem por pis e cofins
--
--            Cursor: c_a170_custo: Incluído campo codst_id_pis e Incluído campo codst_id_cofins na query
--            vn_fase = 20.1: Alterado validação do IF para contemplar a checagem por pis e cofins
--
-- Procedure: PKB_MONTA_REG_C400:
--            Cursor: c_400: Incluído verificação por cst_id de pis e cofins no exists da query
--
-- Procedure: PKB_MONTA_REG_C380
--            Cursor: c_c381: Incluído verificação por cst_id de pis na query
--
-- Procedure: PKB_MONTA_REG_C100:
--            Cursor: c_c120: ncluído campo codst_id_pis e Incluído campo codst_id_cofins na query
--            vn_fase = 29: Alterado validação do IF para contemplar a checagem por pis e cofins
--
-- Procedure: PKB_MONTA_REG_C100:
--            vn_fase = 33: Alterado validação do IF para contemplar a checagem por pis e cofins
--            vn_fase = 37: Alterado validação do IF para contemplar a checagem por pis e cofins
--
-- Em 20/03/2018 - Angela Inês.
-- Redmine #40731 - Correção na geração do arquivo Sped EFD-Contribuições.
-- 1) Considerar 20 caracteres para montagem do registro C111-Processo Referenciado, coluna NUM_PROC.
-- 2) Permitir informação dos registros abaixo até Julho/2013, após essa data, os registros não devem ser informados: 1101, 1102, 1200, 1210, 1220, 1501,
-- 1502, 1600, 1610, 1620.
-- Rotinas: pkb_monta_reg_c100, pkb_monta_reg_1100, pkb_monta_reg_1200, pkb_monta_reg_1500 e pkb_monta_reg_1600.
--
-- Redmine #40640 - Correção no processo de geração do arquivo Sped EFD-Contribuições.
-- Recuperar o parâmetros que indica se haverá quebra de informação adicional, para os registros 0450 e C110, por empresa.
-- Rotinas: pkb_monta_reg_0450, pkb_monta_reg_c100 e pkb_inicia_param.
--
-- Em 13/03/2018 - Angela Inês.
-- Redmine #40467 - Alteração dos Registro C110 e 0450 do Sped Contribuições que as informações adicionais sejam exportadas de forma integral no arquivo Texto.
-- 1) Alterar o processo de geração do arquivo, recuperando o campo param_efd_contr.dm_quebra_infadic_spedc, através da empresa vinculada com a abertura do
-- arquivo (abertura_efd_pc.empresa_id).
-- 2) Se o parâmetro estiver parametrizado como 0-Não, permanecer o processo montando a informação adicional do registro 0450/C110 somente com os 255 caracteres.
-- 3) Se o parâmetro estiver parametrizado como 1-Sim, alterar o processo montando a informação adicional do registro 0450/C110 com todos os caracteres e
-- quebrando em linhas distintas.
-- Rotinas: pkb_monta_reg_0450 e pkb_monta_reg_c100.
--
-- Em 23/02/2018 - Angela Inês.
-- Redmine #39727 - Correção na geração do arquivo Sped Contribuições - Registro M210/M610 - Detalhes da Consolidação.
-- Atualizar o formato do campo VL_BC_CONT para duas casas decimais.
-- Rotinas: pkb_monta_reg_m200 e pkb_monta_reg_m600.
--
-- Em 09/01/2018 - Angela Inês.
-- Redmine #38308 - Correções nos processos de validação.
-- A mensagem que indica erro de parâmetro para o Bloco F560 está indicando o Bloco F510. Corrigir.
-- Rotina: pkb_valida_plcta_ccusto.
--
-- Em 08/01/2018 - Angela Inês.
-- Redmine #38262 - Alteração na geração do Sped EFD-Contribuições - Registros M210 e M610.
-- Informar zero(0) no campo "Base de Cálculo" quando for utilizado o "CST 03 - Contribuição não-cumulativa apurada a alíquota por unidade de medida de produto".
-- A alíquota deverá permancer em branco de acordo com o manual: Campo 05 - Preenchimento: informar a alíquota do PIS/PASEP (em percentual) aplicável.
-- Quando o COD_CONT for apurado por unidade de medida de produto, este campo deverá ser deixado em branco.
-- Rotina: pkb_monta_reg_m200 e pkb_monta_reg_m600.
--
-- Em 04/01/2018 - Angela Inês.
-- Redmine #38132 - Correção ao gerar os registros de plano de contas - 0500.
-- Recuperar os registros F100 para montagem do registro 0500, considerando a empresa relacionada a abertura do arquivo, e todas as empresas vinculadas na aba
-- Empresa, na tela/portal, da geração do arquivo.
-- Rotina: pkb_monta_reg_0140.
--
-- Em 02/01/2018 - Angela Inês.
-- Redmine #38054 - Correção na geração do arquivo Sped - Contribuições - Variáveis de validação do Plano de Contas e Centros de Custos.
-- Ao recuperar os valores dos domínios sobre validar ou não os planos de contas e os centros de custos, considerar para não validar, se não houver parâmetros
-- para a empresa em questão.
-- Rotina: pkb_inicia_param.
--
-- Em 29/12/2017 - Angela Inês.
-- Redmine #38016 - Correção na geração do arquivo - validação de plano de conta e centro de custo.
-- Nos registros de notas fiscais de mercadoria, fazer o relacionamento da nota fiscal com o item da nota fiscal: nota_fiscal.id=item_nota_fiscal.notafiscal_id.
-- Rotina: pkb_valida_plcta_ccusto.
--
-- Em 20/12/2017 - Angela Inês.
-- Redmine #37778 - Correção na geração do arquivo EFD-Contribuições - Registro A100 - Nota Fiscal de Serviço.
-- Ao gerar as informações do registro A120-Informação Complementar - Operações de Importação, e do registro A170-Complemento do Documento - Itens do Documento,
-- considerar a nota fiscal de serviço que tenha o Imposto PIS e/ou o Imposto COFINS.
-- Rotina: pkb_monta_reg_a100.
--
-- Em 01/12/2017 - Angela Inês.
-- Redmine #37018 - Alterar processos - Processo do Registro 0120-Identificação de Períodos Dispensados da Escrituração Digital.
-- Alterar a montagem do registro 0120, considerando a nova coluna abertura_efd_pc_per_disp.dm_cod_inf_comp.
-- Utilizar essa informação, abertura_efd_pc_per_disp.dm_cod_inf_comp, se estiver preenchida, para a coluna do arquivo, inf_comp, caso contrário, considerar a
-- informação da tabela, abertura_efd_pc_per_disp.inf_comp. Ao utilizar a informação da tabela, abertura_efd_pc_per_disp.inf_comp, considerar até 90 caracteres.
-- Rotina: pkb_monta_reg_0120.
-- Redmine #37026 - Alterar processo - Processo de parâmetros para EFD PIS/COFINS.
-- Se a abertura do arquivo for anterior ao mês de Novembro de 2017, não utilizar essas validações.
-- Se a abertura do arquivo for a partir do mês de Novembro de 2017, utilizar as validações que seguem:
-- Se o parâmetro de validação de plano de contas estiver como 1-Sim, gerar log/erro na geração do arquivo para os registros que estiverem com o campo plano de
-- contas como nulo, e deixar a situação da abertura como 4-Erro na geração do arquivo.
-- Se o parâmetro de validação de centro de custo estiver como 1-Sim, gerar log/erro na geração do arquivo para os registros que estiverem com o campo centro de
-- custo como nulo, e deixar a situação da abertura como 4-Erro na geração do arquivo.
-- Rotinas: pkb_gera_arquivo_efd_pc/pkb_valida_plcta_ccusto.
--
-- Em 18/10/2017 - Angela Inês.
-- Redmine #35613 - Correção na geração do arquivo Sped-EFD-Contribuições - Registro M205 e M605.
-- 3) Alterar o processo de geração do arquivo considerando a montagem dos Registros M205 e M605, a partir da Versão de Leiaute 207, com data de início
-- Março/2014. Utilizar a data da abertura do arquivo para consistir a informação.
-- Rotinas: pkb_monta_reg_m200 e pkb_monta_reg_m600.
--
-- Em 11/10/2017 - Angela Inês.
-- Redmine #35418 - Correção na geração do arquivo Sped-EFD-Contribuições - Registro M205 e M605.
-- Alterar o processo de geração do arquivo considerando a montagem dos Registros M205 e M605, a partir da Versão de Leiaute 207, com data de iníco Março/2014.
-- Rotinas: pkb_monta_reg_m200 e pkb_monta_reg_m600.
--
-- Em 04/10/2017 - Angela Inês.
-- Redmine #35230 - Eliminar a obrigatoriedade do campo "Tipo de Crédito" - Bloco M230/M630-Informações adicionais de diferimento.
-- Alterar o processo de geração do arquivo, desconsiderando a obrigatoriedade do Tipo de Crédito - Registro M230/M630-Informações adicionais de diferimento.
-- Rotinas: pkb_monta_reg_m200 e pkb_monta_reg_m600.
--
-- Em 20/09/2017 - Angela Inês.
-- Redmine #34814 - Correção na geração do arquivo Sped EFD-Contribuições - Registro A100.
-- Não considerar o identificador da pessoa vinculado com a nota fiscal de serviço para identificar se existem notas fiscais de serviço a serem listada no
-- registro A100.
-- Rotina: pkb_monta_bloco_a.
--
-- Em 28/08/2017 - Angela Inês.
-- Redmine #34082 - Correção na Consolidação - Blocos M200 e M600, e arquivo Sped EFD - Valores de Crédito dos Blocos 1100 e 1500.
-- 1) Montagem dos registros 1100 e 1500.
-- Rotinas: pkb_monta_reg_1100, pkb_monta_reg_1500, pkb_monta_reg_1001 e pkb_monta_reg_0140.
--
-- Em 16/08/2017 - Angela Inês.
-- Redmine #33705 - Correção na geração dos Arquivos Sped Fiscal e EFD-Contribuições - Registro 0190.
-- Alterar o processo de geração do Registro 0190 - Unidades, para manter apenas uma Sigla de Unidade, sem repetir.
-- Rotina: pkb_monta_reg_0190.
--
-- Em 15/08/2017 - Angela Inês.
-- Redmine #33636 - Correção no Sped Fiscal e EFD-Contribuições - Registro 0190 - Unidade.
-- Alterar o índice utilizado para armazenar a Unidade de Medida para ser a Sigla da Unidade, pois armazenando pelo identificador da Unidade (unidade.id), a
-- sigla estava se repetindo conforme descrito na atividade, e além disso, será gerado no arquivo a Sigla com letras Maiúsculas.
-- Rotina: pkb_monta_reg_0190.
--
-- Em 07/07/2017 - Marcos Garcia
-- Redmine# 29845 - Sped Contribuições não gera arquivo do 0450 para o A110
-- Erro na geração do arquivo A110(informação complementar), por não haver referencia no arquivo 0450.
-- Atividade: Depois de varias execuções e testes, foi alterado os tipos de indices dos vetores que
-- realizam a montagem dos arquivos. De Inteiro para Caracter.
--
-- Em 26/04/2017 - Angela Inês.
-- Redmine #30550 - Alterar a geração do arquivo com relação aos Registros C100 e C500, para as notas fiscais de modelo '55' com itens de Energia Elétrica.
-- 1) As notas de modelo '55' com item/cfop/tipo de operação, sendo Energia Elétrica, devem ser geradas no Registro C100 se estiverem com situação 7-Cancelada ou
-- 8-Inutilizada (nota_fiscal.dm_st_proc).
-- 2) As notas de modelo '55' com item/cfop/tipo de operação, não sendo Energia Elétrica, devem ser geradas no Registro C500 se estiverem com situação 4-Autorizada
-- (nota_fiscal.dm_st_proc).
-- Rotina: pkb_monta_reg_c100 e pkb_monta_reg_c500.
--
-- Em 11/01/2017 - Angela Inês.
-- Redmine #27185 - Alterar os processos do Registro 1800 - Situação.
-- Verificar onde está sendo utilizada a tabela incorp_imob_ret e a situação do registro - dm_st_proc.
-- Rotina: pkb_monta_reg_1001
-- Redmine #27186 - Alterar os processos do Registro 1900 - Situação.
-- Verificar onde está sendo utilizada a tabela cons_docto_emit_per e a situação do registro - dm_st_proc.
-- Rotina: pkb_monta_reg_1001 e pkb_monta_reg_0140.
--
-- Em 09/01/2017 - Angela Inês.
-- Redmine #27097 - Processo de montagem do Registro 0035.
-- O relacionamento utilizado para recuperar os dados dos participantes - SCP, estão incorretos.
-- Rotina: pkb_monta_reg_0035.
--
-- Em 26/12/2016 - Angela Inês.
-- Redmine #26622 - Correção na geração do arquivo Sped EFD-Contribuições - Bloco 1.
-- Incluir a verificação da existência de registros nos Blocos 1800 e 1900 para montagem do Bloco 1.
-- Rotina: pkb_monta_reg_1001.
--
-- Em 15/12/2016 - Angela Inês.
-- Redmine #8154 - Registro A110 - Complemento do documento - informação complementar da NF.
-- 1) Alterar a PK_GERA_ARQ_EFD_PC gerando o Registro A110:
-- 1.1) Através da rotina PKB_MONTA_REG_A100, gerar o registro A110: Utilizar como exemplo a rotina PKB_MONTA_REG_C100 - CURSOR C_C110.
-- 1.2) Alterar a rotina PKB_MONTA_REG_0450, incluindo o modelo 99 para as notas fiscais de serviço: Utilizar como exemplo o cursor C_OBS_C110.
-- 1.3) Alterar a rotina PKB_MONTA_REG_0140, incluindo o modelo 99 para as notas fiscais de serviço: Utilizar como exemplo o cursor C_CD500_C100_INFCOMPL.
--
-- Em 13/12/2016 - Angela Inês.
-- Redmine #26260 - Blocos 1100/1500 - Montagem do campo "Valor do Crédito descontado neste período de escrituração".
-- Caso o valor do campo a ser informado no arquivo seja zero(0), considerar como NULO.
-- Rotina: pkb_monta_reg_1100 e pkb_monta_reg_1500.
--
-- Em 08/12/2016 - Angela Inês.
-- Redmine #26108 - Geração do Arquivo Sped EFD-Contribuições. Blocos 1100/1500.
-- Recuperar os registros não considerando a origem (contr_cred_fiscal_pis/contr_cred_fiscal_cofins.dm_origem), somente saldo de crédito final maior que
-- zero(0) ou que esteja vinculado com algum registro das apurações.
-- Rotina: pkb_monta_reg_1100 e pkb_monta_reg_1500.
--
-- Em 17/11/2016 - Angela Inês.
-- Redmine #25370 - Alteração na geração do arquivo - Sped EFD-Contribuições.
-- 01) Na montagem do registro F200, preencher com zeros a esquerda os campos: dm_ind_oper e dm_unid_imob. Rotina: pkb_monta_reg_f200.
-- 02) Na montagem do registro F550 incluir o campo Informação Complementar, tabela cons_oper_ins_pc_rcomp, coluna info_compl. Rotina: pkb_monta_reg_f550.
-- 03) Gerar os registros 1101 e 1501 somente se o valor do crédito extemporâneo for maior que zero dos registros 1100 (contr_cred_fiscal_pis.vl_cred_ext_apu) e
-- 1500 (contr_cred_fiscal_cofins.vl_cred_ext_apu). Rotinas: pkb_monta_reg_1100 e pkb_monta_reg_1500.
-- 04) Gerar os registros 1102 e 1502 somente se nos registros 1101 e 1501 os códigos de CST de PIS/COFINS forem 53, 54, 55, 56, 63, 64, 65 ou 66.
-- Rotinas: pkb_monta_reg_1100 e pkb_monta_reg_1500.
-- 05) Nos registros F510 e F560, considerar 2 casas decimais para valor de desconto de pis/cofins, 3 casas decimais para quantidade de base de pis/cofins,
-- 4 casas decimais para alíquota de pis/cofins, e 2 casas decimais para valor do imposto pis/cofins. Rotinas: pkb_monta_reg_f510 e pkb_monta_reg_f560.
-- 06) Incluir as variáveis que totalizam os Bloco F500 até F569. Rotinas: pkb_inicia_dados, pkb_monta_reg_9900.
-- 07) Incluir a recuperação do item do registro 1101 somente se o valor de crédito extemporâneo apurado for mair que zero. Rotina: pkb_monta_reg_0140.
-- 08) Incluir a recuperação da empresa, no registro 0140, para os registros gerados nos blocos 1900. Rotina: pkb_monta_reg_0140.
-- 09) Preencher com zeros a esquerda o campo CNPJ do registro 1900, completando 14 caracteres. Rotina: pkb_monta_reg_1900.
-- 10) Preencher com zeros o valor da receita acumulada, quando o mesmo for nulo, no registro F200. Rotina: pkb_monta_reg_f200.
-- 11) Refazer a geração dos blocos F500 e F560, devido ao indicador do código de incidência tributária (abertura_efd_pc_regime.dm_cod_inc_trib), e indicador do
-- regime cumulativo (abertura_efd_pc_regime.dm_ind_reg_cum). Rotinas: todas.
--
-- Em 05/10/2016 - Angela Inês.
-- Redmine #22803 - NFE de energia elétrica informada no reg. C500.
-- Considerar as Notas Fiscais de Modelo 55, com itens de CFOP vinculados ao tipo de operação 4-Energia Elétrica, para estarem no registro C500, e não aparecerem
-- no registro C100. Alterar todo o processo de geração do arquivo e das apurações de PIS e COFINS.
-- Rotinas: pkb_monta_bloco_c, pkb_monta_reg_c001, pkb_monta_reg_c100 e pkb_monta_reg_c500.
--
-- Em 03/10/2016 - Angela Inês.
-- Redmine #24007 - Correção na montagem dos registros 1100 e 1500 - Sped EFD-Contribuições.
-- Correção na recuperação dos registros 1100 e 1500 - Considerar os registros do mês atual e anteriores desde que sejam de origem "Digitado", com saldo
-- a crédito final positivo, maior que zero(0), ou que tenha vínculo com a consolidação, bloco M200/M600, do mês em questão.
-- Rotinas: pkb_monta_reg_1100/1500, pkb_monta_reg_1001 e pkb_monta_reg_0140.
--
-- Em 26/09/2016 - Angela Inês.
-- Redmine #23791 - Correção nas apurações de PIS e COFINS e geração do arquivo Sped EFD-Contribuições.
-- Eliminar a montagem do registro 1100 e 1500 anterior. Considerar os registros com saldo maiores que zero, e de origem digitação.
-- Rotina: pkb_monta_reg_1100/pkb_monta_reg_1100_anterior e pkb_monta_reg_1500/pkb_monta_reg_1500_anterior.
--
-- Em 22/09/2016 - Angela Inês.
-- Redmine #23678 - Correção na geração do SPED EFD-Contribuições - Bloco 1500.
-- Correção: Na montagem dos registros 1100 e 1500 do arquivo, considerar valores do mês atual com saldo maior que zero(0), e considerar valores do mês atual e
-- dos meses anteriores, vinculados com o período da consolidação.
-- Rotinas: pkb_monta_reg_1500 e pkb_monta_reg_1500_anterior.
--
-- Em 15/08/2016 - Angela Inês
-- Redmine #22495 - Inclusão de Contas Contábeis (registro 0500), e Centros de Custos (registro 0600), originados dos Blocos F.
-- Incluir os planos de conta no registro 0500, e os centros de custos no registro 0600, quando houver plano de conta e/ou centro de custo, destacados
-- nos Blocos F100, F120, F130, F150, F500, F510, F525, F550 e F560, dos processos de PIS e COFINS.
-- Rotina: pkb_monta_reg_0140.
--
-- Em 02/08/2016 - Angela Inês.
-- Redmine #21973 - Correção nos processos que utilizam Impostos PIS/COFINS - Geração do Arquivo.
-- Nos processos que utilizam Impostos de Itens de Notas Fiscais do Tipo PIS e COFINS, considerar se o imposto é do tipo 0-Imposto (imp_itemnf.dm_tipo=0).
--
-- Em 14/07/2016 - Angela Inês.
-- Redmine #21324 - Correção na Geração dos Blocos 1100/1500 e Geração do Arquivo.
-- Na geração do arquivo demonstrar os registros do Bloco 1100/1500 se estiverem sido utilizados na consolidação do bloco M200/M600, ou se tiverem saldo de
-- crédito a ser utilizado.
-- Rotina: pkb_monta_reg_1001.
--
-- Em 12/07/2016 - Angela Inês.
-- Redmine #21255 - Correção na geração do Bloco 1100/1500 automático pelos Blocos M200/M600 e Geração do Arquivo.
-- Considerar os registros do Bloco 1100/1500 somente se tiver sido utilizados nos Blocos M200/M500.
-- Considerar os registros do Bloco 1100/1500 somente se tiver saldo de crédito futuro.
-- Rotinas: pkb_monta_reg_1500, pkb_monta_reg_1500_anterior, pkb_monta_reg_1100 e pkb_monta_reg_1100_anterior.
--
-- Em 01/07/2016 - Angela Inês.
-- Redmine #20872 - Geração do Arquivo Sped EFD-Contribuições. Blocos 1100/1500.
-- 1) No cálculo do Bloco M200/M600, recuperar o valor de crédito descontado no Bloco 1100 (contr_cred_fiscal_pis.vl_cred_desc_efd), caso seja maior que zero, de períodos
-- anteriores até o período em questão. Utilizar os valores ate que o saldo fique zerado ou maior que zero (cons_contr_pis.vl_tot_cred_desc_ant). Alterar o registro
-- do Bloco 1100 com o identificador do Bloco M200 (contr_cred_fiscal_pis.conscontrpis_id).
-- 2) Na geração do arquivo, considerar os registros do Bloco 1100 que foram utilizados no cálculo do Bloco M200 e os registros com saldo de períodos futuros, para
-- serem demonstrados no arquivo.
-- Rotinas: pkb_monta_reg_1100_anterior e pkb_monta_reg_1500_anterior.
--
-- Em 09/05/2016 - Rogério Silva.
-- Redmine #18352 - Integração de Informação Adicional com o Caractere PIPE e ENTER (\n)
--
-- Em 15/04/2016 - Angela Inês.
-- Redmine #17699 - Correção na geração do arquivo Sped-EFD, Apuração do PIS e Apuração da COFINS.
-- Correção na recuperação do plano de contas dos itens das notas fiscais de modelo '21' e '22'.
-- Correção na montagem do registro D001 considerando as movimentações das notas fiscais de modelo '21' e '22'.
-- Correção na montagem do registro D600 considerando os itens que possuem Classificação do Consumo de Mercadoria/Serviço de Fornecimento Contínuo.
-- Correção na montagem dos registros D601 e D605 considerando a data de emissão das notas eliminado a hora.
-- Rotina: pkb_monta_reg_0140, pkb_monta_reg_d001 e pkb_monta_reg_d600.
--
-- Em 01/04/2016 - Angela Inês.
-- Redmine #17136 - Correção na geração dos blocos D500 e D600 - Notas Fiscais de Comunicação - Sped EFD-Contribuições.
-- 1) Na geração do Registro D500, considerar as notas fiscais de entrada (nota_fiscal.dm_ind_oper=0), de emissão própria e terceiros
-- (nota_fiscal.dm_ind_emit=0/1), e recuperar os dados de impostos dos complementos (tabela: nf_compl_oper_cofins e nf_compl_oper_pis).
-- 2) Criar a geração do Registro D600, considerando as notas fiscais de saída (nota_fiscal.dm_ind_oper=1), de emissão própria e terceiros
-- (nota_fiscal.dm_ind_emit=0/1), e recuperar os dados de impostos dos itens (tabela: imp_itemnf). Agrupar pelo Município da Empresa, Série e Subsérie.
-- Atribuir para Indicador de Tipo de Receita o valor fixo 0-Receita própria - serviços prestados. Os registros D601 e D605 devem ser agrupados por Código de
-- Classe (COD_CLASS), CST de PIS/COFINS (CST_PIS/CSF_COFINS), e Código da Conta (COD_CTA). O Código da Classe deverá ser recuperado do item da nota fiscal
-- ITEM_NOTA_FISCAL.CLASSCONSITEMCONT_ID.
-- Rotinas: pkb_inicia_dados, pkb_monta_bloco_d, pkb_monta_reg_d600, pkb_monta_reg_d990 e pkb_monta_reg_9900.
-- 3) Considerar os registros mesmo com os valores zerados.
-- Rotina: pkb_monta_reg_0111.
--
-- Em 15/01/2016 - Fábio Tavares
-- Redmine #13577 - Sped Contribuições;
-- Geração do Arquivo Sped EFD-Contribuições. Bloco F500/F509, F510/F519, F525, F550/F559, F560, F569.
-- Incluir a informação dos valores de PIS e COFINS no Registro F500/F509, F510/F519, F525, F550/F559, F560, F569;
--
-- Em 09/12/2015 - Angela Inês.
-- Redmine #13505 - Incluir Conta Contábil dos Registros D100 no Registro 0500.
-- Passar a recuperar os códigos do plano de contas dos registros D100 - Conhecimento de Transporte, para montagem do registro 0500.
-- Rotina: pkb_monta_reg_0140.
--
-- Em 01/12/2015 - Angela Inês.
-- Redmine #13297 - Não está criando o registro 0190 - unidade de medida.
-- Rotina: pkb_monta_reg_0140.
--
-- Em 30/11/2015 - Angela Inês.
-- Redmine #13205 - Sped Contribuições.
-- Informar o registro C870 se os valores das alíquotas em percentuais forem maiores que zero.
-- Informar o registro C880 se os valores das alíquotas em valores forem maiores que zero.
-- Através do código do item do cupom fiscal eletrônico recuperar o identificador para montar o registro 0200.
-- Rotinas: pkb_monta_reg_c860 e pkb_monta_reg_0140.
--
-- Em 25/11/2015 - Angela Inês.
-- Redmine #13128 - Feedback #12384.
-- Correção na montagem do registro C100: considerar a quantidade dos registros C800.
-- Rotina: pkb_monta_reg_c001.
--
-- Em 27/10/2015 - Angela Inês.
-- Redmine #12384 - Verificar/Alterar o processo de arquivo Sped EFD-Contribuições.
-- Verificar/Alterar no processo de Sped EFD-Contribuições os registros que se referem ao Cupom Fiscal Eletrônico - modelo 59-CFe.
-- Rotinas: pkb_monta_reg_9900, pkb_monta_reg_c990, pkb_monta_reg_c860, pkb_monta_bloco_c, pkb_monta_reg_0140 e pkb_inicia_dados.
--
-- Em 15/10/2015 - Angela Inês.
-- Redmine #12244 - Geração do Arquivo Sped EFD-Contribuições. Bloco C100.
-- Incluir a informação dos valores de PIS e COFINS no Registro C100.
-- Rotina: pk_gera_arq_efd_pc.pkb_monta_reg_c100 - Montagem do Registro C100 Modelo de Nota 65.
--
-- Em 14/10/2015 - Angela Inês.
-- Redmine #12226 - Geração do Arquivo Sped EFD-Contribuições. Bloco C100.
-- Ao gerar os registros C100, considerar primeiro a situação das notas fiscais, em seguida, o modelo 65, e depois as comuns.
-- O processo está considerando o modelo 65 primeiro, e está gerando as informações desnecessárias.
-- Rotina: pk_gera_arq_efd_pc.pkb_monta_reg_c100 - cursor c_nf - teste da montagem do cabeçalho.
--
-- Em 13/10/2015 - Angela Inês.
-- Redmine #12182 - Geração do Arquivo Sped EFD-Contribuições. Bloco 0150.
-- Não considerar as notas fiscais de modelo fiscal '65' para montar os registros 0150 - Cadastro de Participante.
-- Rotina: pkb_monta_reg_0140, cursor c_cd500_ac100_pessoa.
--
-- Em 22/09/2015 - Angela Inês.
-- Redmine #11793 - Geração do Sped EFD-Contribuições. Registro A100.
-- Na geração dos registros A100, passar a não exigir o cadastro de participante (pessoa). O validador irá informar a necessidade da informação.
-- As notas fiscais de serviço que não possuem participante (nota_fiscal.pessoa_id=null), irão aparecer no registro.
-- Rotina: pkb_monta_reg_a100 - cursor c_nf: incluir '(+)' para a tabela PESSOA.
--
-- Em 03/09/2015 - Angela Inês.
-- Redmine #11407 - Correção na geração do SPED EFD-Contribuições.
-- Ao gerar o registro 0145-Regime da CPRB, verificar se existe Apuração da CPRB como PROCESSADA.
-- Rotina: pk_gera_arq_efd_pc.pkb_monta_reg_0140 - Cursor c_cprb.
--
-- Em 14/08/2015 - Angela Inês.
-- Redmine #10117 - Escrituração de documentos fiscais - Processos.
-- Inclusão do novo conceito de recuperação de data dos documentos fiscais para retorno dos registros.
--
-- Em 10/08/2015 - Angela Inês.
-- Redmine #10619 - Falta de registro 0500 no EFD Contribuições.
-- Correção na recuperação dos registros C170 para montagem do registro 0500 caso exista plano de conta relacionado ao item da nota fiscal.
-- Rotina: pkb_monta_reg_0140.
--
-- Em 06/08/2015 - Angela Inês.
-- Redmine #10520 - Correção na Geração do Sped EFD-Contribuições.
-- No registro 0200-Cadastros dos Itens/Produtos, não considerar 0-zero na frente do código NCM, considerar o que está na base.
-- Rotina: pkb_monta_reg_0200.
--
-- Em 28/07/2015 - Angela Inês.
-- Redmine #10117 - Escrituração de documentos fiscais - Processos.
-- Inclusão do novo conceito de recuperação de data dos documentos fiscais para retorno dos registros.
--
-- Em 10/07/2015 - Angela Inês.
-- Redmine #8148 - Bloco M. Geração do arquivo da EFD Contribuições.
-- Implementar as mudanças de acordo com o Sped para recuperação dados do Bloco M - Registros M115 - Detalhamento dos ajustes do crédito de PIS/PASEP apurado,
-- M225 - Detalhamento dos ajustes da contribuição para o PIS/PASEP apurada, M515 - Detalhamento dos ajustes do crédito de COFINS apurado,
-- e M625 - Detalhamento dos ajustes da COFINS apurada.
-- Rotinas: pkb_monta_reg_m100, pkb_monta_reg_m200, pkb_monta_reg_m500, pkb_monta_reg_m600, pkb_monta_reg_9900, pkb_monta_reg_m990 e pkb_inicia_dados.
-- Redmine #8244 - Bloco F200. Geração do arquivo da EFD Contribuições.
-- Implementar as mudanças de acordo com o Sped para recuperação dados da Operação da Atividade Imobiliária - Unidade Imobiliária Vendida - Bloco F200.
-- Rotinas: pkb_monta_bloco_f, pkb_monta_reg_f001, pkb_monta_reg_f200, pkb_monta_reg_9900, pkb_monta_reg_f990 e pkb_inicia_dados.
-- Redmine #8318 - Bloco 1800. Geração do arquivo da EFD Contribuições.
-- Implementar as mudanças de acordo com o Sped para recuperação dados da Incorporação Imobiliária - RET - Bloco 1800.
-- Rotinas: pkb_monta_bloco_1, pkb_monta_reg_1800, pkb_monta_reg_9900, pkb_monta_reg_1990 e pkb_inicia_dados.
-- Redmine #8333 - Bloco 1900. Geração do arquivo da EFD Contribuições.
-- Implementar as mudanças de acordo com o Sped para recuperação dados da Consolidação dos documentos emitidos por período - Bloco 1900.
-- Rotinas: pkb_monta_bloco_1, pkb_monta_reg_1900, pkb_monta_reg_9900, pkb_monta_reg_1990 e pkb_inicia_dados.
--
-- Em 18-24-25-26/06/2015 - Angela Inês.
-- Redmine #8097 - Bloco I. Geração do arquivo da EFD Contribuições.
-- Implementar as mudanças de acordo com o Sped para recuperação dados da Apuração das Operações das Instituições Financeiras, Seguradoras, Entidades de
-- Previdência Privada, Operadoras de Planos de Assistência à Saúde e demais Pessoas Jurídicas referidas nos §§ 6º, 8º e 9º do art. 3º da Lei nº 9.718/98.
-- Rotina: pkb_monta_bloco_i.
--
-- Em 18/06/2015 - Angela Inês.
-- Redmine #8030 - Registro 0035. Geração do arquivo.
-- Implementar as mudanças de acordo com o Sped para recuperação dados da Identificação de Sociedade em Conta de Participação -  SCP -  Registro 0035.
-- 1) Relacionar abertura_efd_pc_scp.pessoarelac_id = pessoa_relac.id; relacionar pessoa_relac.pessoa_id = pessoa.id, e recuperar jurídica.cnpj,
-- para gerar o campo: cod_scp. Através de pessoa_relac.relacpart_id = relac_part.id, recuperar relac_part.cod_rel para gerar o campo: desc_scp; e,
-- recuperar relac_part.inf_compl para gerar o campo: inf_comp.
-- Rotina: pkb_monta_reg_0035.
-- Redmine #8064 - Registro 0120. Geração do arquivo.
-- Implementar as mudanças de acordo com o Sped para recuperação dos dados da Identificação dos períodos dispensados -  Registro 0120.
-- Rotina: pkb_monta_reg_0120.
--
-- Em 11/06/2015 - Rogério Silva.
-- Redmine #8226 - Processo de Registro de Log em Packages - LOG_GENERICO
--
-- Em 22/05/2015 - Angela Inês.
-- Redmine #8596 - Lançamento BLOCO 1100/1500 (MANIKRAFT).
-- Atualmente: É demostrado apenas o Saldo do mês corrente, não demostrando os períodos anteriores ao da escrituração atual.
-- Correção: Deve assim ser escriturado um registro para cada mês de períodos passados, que tenham saldos passíveis de utilização,
-- no período a que se refere à escrituração atual.
-- Rotinas: pkb_monta_reg_1100 e pkb_monta_reg_1500.
--
-- Em 15/05/2015 - Angela Inês.
-- Redmine #8417 - Apuração da CPRB - Bloco P.
-- 1) Considerar no registro P010 o cnpj/cpf da empresa relacionada ao estabelecimento, e seguir as informações dos registros posteriores de acordo com a
-- apuração e a empresa do estabelecimento. Tabelas: apuracao_cprb e apur_cprb_estab.
-- Rotina: pkb_monta_reg_p010.
--
-- Em 13/05/2015 - Angela Inês.
-- Redmine #8368 - Falta de conta de estoque no registro 0500.
-- Correção: O processo de recuperação dos planos de contas para os registros A170, estava considerando que a conta deveria estar cadastrada na empresa
-- relacionada com a nota fiscal.
-- Nos casos de notas fiscais de empresas filiais, a conta está vinculada na empresa matriz, por isso o registro da conta não estava sendo recuperado.
-- Rotina: pkb_monta_reg_0140.
--
-- Em 04/05/2015 - Angela Inês.
-- Redmine #8021 - Geração do Sped EFD-Contribuições.
-- Correção da montagem dos registros 0200 e 0450 do EFD Contribuções.
-- Rotina: pkb_monta_reg_c100.
--
-- Em 28/04/2015 - Angela Inês.
-- Redmine #7931 - Alterações da EFD Contribuições (Pis/Cofins).
-- 1) Alterar a recuperação das notas fiscais para o registro C100 considerando o modelo fiscal 65, e gerar o registro C175.
-- 2) Alterar a recuperação do COD_LST no Registro 0200, a partir de 01/05/2015, considerando o formato 'XX.XX'.
-- Rotina: pkb_monta_reg_0200, pkb_monta_reg_c100.
--
-- Em 16-17/04/2015 - Angela Inês.
-- Redmine #7689 - Falta registro C110 (VERDEMAR).
-- Informar o registro C110 quando a nota fiscal (C100) possuir informação de complemento (tabela: infor_comp_dcto_fiscal).
-- Rotina: pkb_monta_reg_c100.
--
-- Em 03/02/2015 - Rogério Silva
-- Redmine #6013 - Sped EFD-Contribuições - Nota Fiscal - Quantidade do item.
--
-- Em 09/01/2015 - Angela Inês.
-- Redmine #5598 - Versão 2.6.3 com erro EFD Contribuições (ACECO).
-- 1) Correção na montagem do registro 0500-Plano de Contas: Considerar um registro quando houver mais de um documento com o mesmo código de conta.
-- 2) Correção na montagem do registro 0500-Plano de Contas: Recuperar os dados da conta fora do processo de conta referenciada.
-- Rotina: pkb_monta_reg_0500.
--
-- Em 06/01/2015 - Angela Inês.
-- Redmine #5616 - Adequação dos objetos que utilizam dos novos conceitos de Mult-Org.
--
-- Em 24/11/2014 - Angela Inês.
-- Redmine #5277 - Falha no processo de escrituração de NFS-e (ACECO).
-- Na montagem do Bloco A100, considerar o número de autorização da nota fiscal de serviço complementar (nf_compl_serv.nro_aut_nfs), e se não existir,
-- considerar o número da nota fiscal (nota_fiscal.nro_nf). Somente para notas fiscais de serviço de emissão própria.
-- Rotina: pkb_monta_reg_a100.
--
-- Em 06/11/2014 - Angela Inês.
-- Redmine #5087 - Sped Contribuições regime cumulativo.
-- Compliance Fiscal - Teste de funcionalidade #5050: Teste Fechamento de versão 2.6.3.
-- No arquivo de Sped Contribuições, a linha que contém informação do F800, campo pa_cont_cred está com '42014'.
-- Se refere a Mês e Ano, portanto deve ser completado com zeros a esquerda, ficando '042014'.
-- Rotina: pkb_monta_reg_f800.
--
-- Em 24/10/2014 - Angela Inês.
-- Redmine #4898 - Erro de estrutura EFD (ADIDAS).
-- Correção: Eliminar a recuperação das notas fiscais de consumidor eletrônica - modelo 65.
-- Correção: No processo de geração do registro C120, não exigir os impostos PIS e COFINS de Importação, códigos 15 e 16 (alter join).
-- Rotina: pkb_monta_reg_c100.
--
-- Em 14/10/2014 - Angela Inês.
-- Redmine #4726 - Cálc. Consol. da Contribuição do COFINS - Bloco M600 - Geração do Arquivo.
-- Correção no processo para geração dos dados do Registro M605: Contribuição para a COFINS a recolher - Detalhamento por código de receita.
-- 1) Alterar o processo de geração de arquivo para recuperar a nova coluna na montagem do registro M605.
-- Rotina: pkb_monta_reg_m600.
--
-- Em 13/10/2014 - Angela Inês.
-- Redmine #4719 - Cálc. Consol. da Contribuição do PIS - Bloco M200 - Geração do Arquivo.
-- Correção no processo para geração dos dados do Registro M205: Contribuição para o PIS/PASEP a recolher - Detalhamento por código de receita.
-- 1) Alterar o processo de geração de arquivo para recuperar a nova coluna na montagem do registro M205.
-- Rotina: pkb_monta_reg_m200.
--
-- Em 07/10/2014 - Angela Inês.
-- Redmine #4710 - Erro ao validar SPED Contribuições - Aline/Murilo/Adidas.
-- Sped EFD-Contribuições: registro A100 não possui valores de PIS/COFINS e nem gera o registro A170.
-- Correção:
-- 1) Ao calcular a soma dos valores de impostos o comando estava incorreto, devido ao resultado da recuperação ser nulo, o registro não existe.
--
-- Em 29/09/2014 - Angela Inês.
-- Redmine #4530 - Desconto IRRF em NFS-e. Alteração na geração do Sped EFD-Contribuições.
-- 1) Alterar o Sped EFD, considerando como VL_DOC no registro A170, o valor total do item (nota_fiscal_total.vl_total_item).
--
-- Em 08/09/2014 - Angela Inês.
-- Redmine #4159 - Notas Fiscais de Serviço sem Itens - Recuperação dos valores de PIS e COFINS.
-- Recuperar os valores dos impostos tributados quando o registro indicar que é imposto (imp_itemnf.dm_tipo = 0).
-- Rotina: pkb_monta_reg_a100.
-- Considerar '12' para o valor do campo do bloco M205/M605, quando o valor for referente ao valor da contribuição cumulativa.
-- Rotina: pkb_monta_reg_m200 e pkb_monta_reg_m600.
--
-- Em 08/08/2014 - Angela Inês.
-- Redmine #3705 - Processo de Geração do Arquivo Texto.
-- 1) Incluir a geração dos Blocos M205 e M605, de acordo com os valores gerados nos pagamentos. Seguir o layout do Sped/Efd-Contribuições:
-- a) Bloco M205: Considerar os valores dos pagamentos (cons_contr_pis_or).
-- num_campo = '08' - se cons_contr_pis.vl_cont_nc_rec > 0, ou '09' - se cons_contr_pis.vl_cont_cum_rec > 0
-- cod_rec   = cons_contr_pis_or.tipo_ret_imp.cd||cons_contr_pis_or.tipo_ret_imp_receita.cod_receita
-- vl_debito = cons_contr_pis_or.vl_rec
-- b) Bloco M605: Considerar os valores dos pagamentos (cons_contr_cofins_or).
-- num_campo = '08' - se cons_contr_cofins.vl_cont_nc_rec > 0, ou '09' - se cons_contr_cofins.vl_cont_cum_rec > 0
-- cod_rec   = cons_contr_cofins_or.tipo_ret_imp.cd||cons_contr_cofins_or.tipo_ret_imp_receita.cod_receita
-- vl_debito = cons_contr_cofins_or.vl_rec
-- 2) Alterar os processos de somatório dos novos registros.
--
-- Em 01/08/2014 - Angela Inês.
-- Redmine #3651 - Correção do C110 - Informações Complementares - Verdemar.
-- Corrigir "Informações Complementares" do Sped PIS/COFINS de acordo com a correção efetuada no SPED - ICMS/IPI.
-- Eliminada a montagem do registro 0450 para os registros C111.
-- Rotina: pkb_monta_reg_0450.
-- Redmine ##3652 - Correção do Registro C120.
-- Corrigir Registro C120 para ficar igual ao ICMS/IPI, não está recuperando PIS/COFINS.
-- Alteração nos códigos dos tipos de impostos recuperados para PIS e COFINS sendo: tipo_imposto.cd = 15-Pis Importação e tipo_imposto.cd = 16-Cofins Importação.
-- Rotina: pkb_monta_reg_c100.
--
-- Em 28/07/2014 - Angela Inês.
-- Redmine #3639 - Inclusão de colunas faltantes da geração do Sped EFD-Contribuições.
-- 01) Registro 0500 - Plano de contas contábeis, coluna: COD_CTA_REF.
-- Recuperar a conta contábil de referência relacionada ao plano de conta.
-- Rotina: pkb_monta_reg_0500.
-- 02) Registro C381 - Detalhamento da consolidação - PIS/PASEP, coluna: COD_CTA.
-- Recuperar o código da conta das notas fiscais de venda a consumidor, modelo '02', registro C380.
-- Incluir na montagem do registro 0200 os ITENS/PRODUTOS referente ao registro C381.
-- Incluir na montagem do registro 0500 as CONTAS CONTÁBEIS referente ao registro C381.
-- Rotina: pkb_monta_reg_0140.
-- 03) Registro C385 - Detalhamento da consolidação - COFINS, coluna: COD_CTA.
-- Recuperar o código da conta das notas fiscais de venda a consumidor, modelo '02', registro C380.
-- Incluir na montagem do registro 0200 os ITENS/PRODUTOS referente ao registro C385.
-- Incluir na montagem do registro 0500 as CONTAS CONTÁBEIS referente ao registro C385.
-- Rotina: pkb_monta_reg_0140.
--
-- Em 17/07/2014 - Angela Inês.
-- Redmine #3522 - Erro na Geração PIS/COFINS - Registro A100.
-- Correção: ao gerar o registro A100 considerar 'SN' para a coluna de Número da Nota Fiscal.
-- Rotina: pkb_monta_reg_a100.
--
-- Em 15/07/2014 - Angela Inês.
-- Redmine #3499 - Suporte - Aline/Ibirapuera.
-- 1) Sped EFD-Contribuições. Não está sendo gerado o registro 0190 referente a unidade de medida 'CX' informada nos registros 0200 e C170 da empresa filial.
-- Correção: ao gerar o registro 0190-Unidades, não considerar o código ST de isento (grupo 70), apenas se os CFOPs geram escrituração.
-- Rotina: pkb_monta_reg_0140 - cursores: c_cd500_pessoa, c_c170_unid, c_c170_natoper, c_cd500_infcompl, c_a170_plano e c_a170_custo.
-- 2) Agrupar o valor da receita nos blocos M410 e M810 de acordo com a chave: natureza de receita, plano de conta e descrição complementar.
-- Rotinas: pkb_monta_reg_m400 e pkb_monta_reg_m800.
--
-- Em 24/06/2014 - Angela Inês.
-- Redmine #3161 - Alterações da EFD Contribuições (Pis/Cofins) - Abertura/Geração do Processo.
-- 1) Registro A100: Alteração das instruções de preenchimento do Campo 08 (NUM_DOC): Caso não exista nota_fiscal.nro_nf informar 'SN'.
-- 2) Registro A100: Considerar a data de emissão (nota_fiscal.dt_emiss), quando não houver a data de execução/conclusão do serviço (nf_compl_serv.dt_exe_serv)
--    para montar o registro.
-- 3) Registro A100 - Documento Cancelado - Nota Fiscal de Serviços (código da situação = 02): Somente podem ser preenchidos os campos de código da situação,
--    indicador de operação, emitente, número do documento, série, subsérie e código do participante. Os campos série e subsérie não são obrigatórios e o campo
--    código do participante é obrigatório nas operações de contratação de serviços (nota_fiscal.dm_ind_emit = 1).
-- Rotina: pkb_monta_reg_a100.
-- 4) Registro C500: Preenchimento facultativo do Campo 09 (DT_ENT) e alteração das instruções de preenchimento do Campo 07 (NUM_DOC):
-- 4.1) Para o campo NUM_DOC informar '000000000' caso não exista.
-- 4.2) Para o campo DT_ENT, validação: a data informada neste campo ou a data de emissão do documento fiscal (campo 08) deve estar compreendida no período da
--      escrituração (campos 06 e 07 do registro 0000). O valor deve ser maior ou igual à data de emissão. Regra aplicável na validação/edição de registros da
--      escrituração, a ser gerada com a versão 1.0.2 do Programa Validador e Assinador da EFD-Contribuições.
-- Rotina: pkb_monta_reg_c500.
-- 5) Para os registros C100: Alterar o processo que recupera o valor para a coluna IND_FRT. Considerar a data/período da escrituração como sendo: até 31/12/2011
--    o que está no processo, e a partir de 01/01/2012, considerar o valor dessa coluna de acordo com o domínio que temos na tabela NOTA_FISCAL_TRANSP.DM_MOD_FRETE.
-- Rotina: pkb_monta_reg_c100.
-- 6) Registro "P200 - Consolidação da Contribuição previdenciária sobre a Receita Bruta": Complemento das instruções de preenchimento do campo 07 (COD_REC).
--    Corrigir a recuperação do Código da Receita, utilizando tipo_ret_imp.cd (sendo 4 dígitos), mais tipo_ret_imp_receita.cod_receita (sendo 2 dígitos).
--    Concatenados sem hífen e com 6 dígitos.
-- Rotina: pkb_monta_reg_p200.
-- Fora do escopo:
-- 1) Incluir a função pk_csf_dctf.fkg_retorna_codrec_tpretimprec para recuperação do código de receita. Rotina: pkb_monta_reg_p200.
-- 2) Eliminar as variáveis não utilizadas no processo - Variáveis de somatórias de registros não gerados.
--
-- Em 15/05/2014 - Angela Inês.
-- Redmine #2767 - Geração do arquivo da EFD Contribuições. Implementar a geração do Bloco P -  Apuração da Contribuição Previdenciária sobre a Receita Bruta.
-- Alterações necessárias para a atividade:
-- 1) Incluir função para retornar o código da atividade sujeita a incidência da Contribuição Previdenciária sobre a Receita Bruta.
-- 2) Incluir função para retornar o código de Detalhamento da Contribuição Previdenciária sobre a Receita Bruta.
-- 3) Incluir função para retornar o código de ajuste de contribuição ou crédito através do identificador.
-- Rotinas: pk_csf_efd_pc.fkg_cd_codativcprb, pk_csf_efd_pc.fkg_cd_coddetcprb e pk_csf_efd_pc.fkg_cd_ajustcontrpc.
-- Alterações fora do escopo:
-- 1) Campos que se referem a mês e ano - mmrrrr: preencher com '0' a esquerda completando 6 caracteres.
-- 2) Inclusão dos dados do Bloco 1100/1101 para os registros 0140-Establecimento, 0150-Pessoa, 0200-Item/Produto, 0500-Plano de Conta e 0600-Centro de Custo.
-- 3) Inclusão dos dados do Bloco 1500/1501 para os registros 0140-Establecimento, 0150-Pessoa, 0200-Item/Produto, 0500-Plano de Conta e 0600-Centro de Custo.
-- Rotina: pkb_monta_reg_0140.
--
-- Em 24/02/2014 - Angela Inês.
-- Redmine #1793 - Problemas com a montagem do registro 0200 - Considerar as notas fiscais que possuem itens com CST de tributação.
-- Rotina: pkb_monta_reg_0140.
--
-- Em 19/02/2014 - Angela Inês.
-- Redmine #1861 - Suporte - Karina/Aceco.
-- Alterar a geração do arquivo sped pis/cofins registro C170 para enviar NULO quando a nota fiscal não possuir ICMS.
-- Rotina: pkb_monta_reg_c100.
--
-- Em 20/12/2013 - Angela Inês.
-- Alterar o registro 0200 - Itens, para montagem dos produtos por empresa.
--
-- Em 09/12/2013 - Angela Inês.
-- Redmine #1552 - Geração do arq sped contribuições está informando mais uma linha para o registro 0200 - Itens/Produtos, e os valores de serviços não estão coerentes.
-- 1) Alterar o processo do registro 0200 desconsiderando a empresa devido ao código aparecer mais de uma vez, cadastro de empresa duplicado.
-- 2) Alterar o processo do C100/C170 recuperando os valores de serviço para nota_fiscal_total: mercadoria e impostos pis e cofins).
-- Rotinas: pkb_monta_reg_d500, pkb_monta_reg_c500 e pkb_monta_reg_c100.
--
-- Em 05/11/2013 - Angela Inês.
-- Redmine #1157 - Implementar o parâmetro nos processos do PIS/COFINS: "Gerar Ajuste M210" para os parâmetros de CFOP.
-- Inclusão da função que verifica se o CFOP gera valor como ajuste na consolidação para PIS e COFINS, e neste caso não será informado no sped.
-- Rotinas: pkb_monta_reg_0140/pkb_monta_reg_c400/pkb_monta_reg_c380/pkb_monta_reg_c100/pkb_monta_reg_c001/pkb_monta_bloco_c/pkb_monta_reg_a100.
-- Rotinas: pkb_monta_reg_a001/pkb_monta_bloco_a.
--
-- Em 30/04/2013 - Angela Inês.
-- Ficha HD 63870 - Performance para geração dos registros de cadastro do Sped Pis e Cofins.
-- Barcelos - Geração de Pis/Cofins - Montagem dos arquivos 0200 e C170 - Itens não informados.
--
-- Em 25/04/2013 - Angela Inês.
-- Sem ficha HD - Aline - Barcelos - Gerar os registros 0200 Item/Produto com itens de notas fiscais que tenham outros itens com CST 70,
-- agrupando no registro 0140, pois o mesmo está seno informado no registro C170.
-- Rotina: pkb_monta_reg_0140.
--
-- Em 18/04/2013 - Angela Inês.
-- Sem ficha HD - Aline - Barcelos - Gerar os registros 0500 e 0600 fora do agrupamento do registro 0140.
-- Rotina: pkb_monta_reg_0140.
--
-- Em 27/03/2013 - Angela Inês.
-- Ficha HD 66442 - Implementar validações para os erros encontrados no PVA da EFD Pis/Cofins.
-- Rotina: pkb_monta_reg_0110.
-- Ficha HD 63870 - Performance para geração dos registros de cadastro do Sped Pis e Cofins.
-- Rotinas: pkb_monta_reg_0140.
--
-- Em 21/03/2013 - Angela Inês.
-- Ficha HD 66483 - Nas gerações dos arquivos do sped icms/ipi e pis/cofins:
-- Os registros 0500 e 0600 (centro de custo e plano de conta) devem ser revistos.
-- Deve ser armazenado como índice do array o código (CD) de cada um e não o identificador (ID), para que os dados não sejam repetidos, porém temos o
-- problema da quantidade de dígitos do código (CD) para armazenar com índice do array que deve ter no máximo 9 dígitos, por isso colocamos o identificador (ID).
-- Rotinas: pkb_monta_reg_0500 e pkb_monta_reg_0600.
--
-- Em 05/03/013 - Angela Inês.
-- Sem ficha HD - Indexar o identificador do plano de conta (planoconta_id) para gerar o registro 0500.
-- Limpar os vetores dos registros 0500 e 0600.
-- Considerar somente 255 caracteres para o campo DESCR_COMPL do registro A170 a 0200.
-- Considerar os planos de contas dos registros A170 para montar o registro 0500.
-- Rotinas: pkb_monta_reg_0500, pkb_limpa_vetor, pkb_monta_reg_a100, pkb_monta_reg_0200 e pkb_monta_reg_0140.
--
-- Em 08/02/2013 - Angela Inês.
-- Sem ficha HD - Verificar problema ao gerar o arquivo referente ao tipo de registro 0500.
-- Foi incluído novos valores para a variável vn_fase na rotina PKB_MONTA_REG_0500 para identificar o problema.
-- Email enviado pelo Leandro em 08/02/2013:
-- Erro inesperado, por favor tente novamente ! java.sql.SQLException: ORA-20101: Erro na pkb_gera_arquivo_efd_pc fase(11):
-- ORA-20101: Erro na pkb_monta_array_efd fase(1): ORA-20101: Erro na pkb_monta_bloco_0 fase(6):
-- ORA-20101: Erro na pkb_monta_reg_0140 fase(24): ORA-20101: Erro na pkb_monta_reg_0500 fase(4):
-- ORA-01426: overflow numérico ORA-06512: em "CSF_OWN.PK_GERA_ARQ_EFD_PC", line 12436
--
-- Em 31/01/2013 - Angela Inês.
-- Utilizar a função pk_csf.fkg_converte( ev_string           in varchar2
--                                      , en_espacamento      in number default 0
--                                      , en_remove_spc_extra in number default 1
--                                      , en_ret_carac_espec  in number default 1 ) para acertar o campo de descrição do produto no registro A170.
--
-- Em 26/12/2012 - Angela Inês.
-- Ficha HD 65155 - Incluir situção "Em Geração" para o Sped PIS/COFINS enquanto o mesmo estiver sendo gerado.
--
-- Em 22/11/2012 - Angela Inês.
-- Ficha HD 64702 - Erro na geração do registro 0500.
-- 1) Considerar o código da conta como índice do processo.
-- 2) Considerar o código do centro de custo como índice do processo.
-- Rotina: pkb_monta_reg_0500 e pkb_monta_reg_0600.
-- Ficha HD 64714 - Integração em Bloco do Layout de Serviço não está limpando espaços para o campo que se refere ao número da chave nfe.
-- Rotina: pkb_monta_reg_a100.
--
-- Em 16/11/2012 - Angela Inês.
-- Ficha HD 64615 - Alteração na recuperação do código do item do produto, registros C170. Através do código do item do produto, considerar a empresa matriz para
-- recuperar o produto, quando no item da nota fiscal o identificador do produto for nulo.
-- Rotina: pkb_monta_reg_c100.
--
-- Em 08/11/2012 - Angela Inês.
-- Ficha HD 64080 - Escrituração Doctos Fiscais e Bloco M. Nova tabela para considerações de CFOP - param_cfop_empresa.
-- Rotinas: pk_csf_efd_pc.fkg_gera_escr_efdpc_cfop_empr.
--
-- Em 14/09/2012 - Angela Inês.
-- 1) Para o registro C100, alterado a coluna que se refere ao indicador de pagamento - ind_pgto, considerando o valor 2 para os indicadores 2 ou 9.
--
-- Em 24/08/2012 - Angela Inês.
-- 1) Ficha HD - 62552 - Nova versão de geração de Arquivo Texto para PIS/COFINS.
--    Incluir validação de novo campo do regime de apuração - indicador do critério de escrituração e apuração no regime cumulativo.
-- 2) Ficha HD - 62555 - Considerar nulo para o campo QUANT_BC_PIS_TOT e QUANT_BC_COFINS_TOT dos blocos M105 e M505, quando o código de crédito não for:
--    103, 203, 303, 105, 205, 305, 108, 208 e 308.
--
-- Em 13/07/2012 - Leandro.
-- 1) Verificado no registro C100 que estava sendo recuperado duas vezes a nota fiscal, pois tinha dois registros de "transporte" na tabela NOTA_FISCAL_TRANSP.
--    Utilizado a função "pk_csf.fkg_modfrete_nftransp" para recuperar apenas um registro de transporte.
--
-- Em 11/07/2012 - Angela Inês.
-- 1) Gerar a linha do registro 0111, se o indicador de incidência tributária for 1-Regime não-cumulativo ou 3-Regimes não-cumulativo e cumulativo
--    (abertura_efd_pc_regime.dm_cod_inc_trib in (1,3)), e o indicador de apropriação de crédito for 2-Método de Rateio Proporcional (Receita Bruta)
--    (abertura_efd_pc_regime.dm_ind_apro_cred = 2) - rotina pkb_monta_reg_0111.
--
-- Em 25/06/2012 - Angela Inês.
-- 1) Eliminar variáveis declaradas e não utilizadas no processo.
--
-- Em 21/06/2012 - Angela Inês.
-- 1) Unificar os cursores que geram o registro 0200 - Cadastro dos itens/produtos. Dentro da mesma empresa não deve haver mais de uma vez o código do produto.
--    Rotina alterada - pkb_monta_reg_0140.
--
-- Em 13/06/2012 - Angela Inês.
-- 1) Nos processos que geram os registros C170-Unidade, A170-Unidade, C170-Item, A170-Item, C170-Natureza de Operação, consistir se todos os itens
--    não forem tributados de pis e cofins, não deverão ser listados, caso contrário, se pelo menos um dos itens tiver tributação, todos os outros
--    deverão estar na recuperação, deverão ser listados - rotina PKB_MONTA_REG_0140.
--
-- Em 19/04/2012 - Angela Inês.
-- 1) Ao verificar qtde de registros a serem informados na rotina pkb_monta_reg_C001, considerar a condição de CST, para C100 e D500.
-- 2) Ao verificar qtde de registros a serem informados na rotina pkb_monta_reg_a001, considerar a condição de CST, para A100.
--
-- Em 18/04/2012 - Angela Inês.
-- 1) Na montagem do registro 0600 - Centro de custo, não é necessário incluir a empresa, o comando distinct e nem ordenação,
-- devido a condição ser feita pelo identificador do centro de custo.
-- 2) Na montagem do registro 0450 - Informação complementar, não é necessário incluir o comando distinct e nem ordenação,
-- devido a condição ser feita pelo identificador da informação complementar.
-- 3) Na montagem do registro 0400 - Natureza da operação/prestação, não é necessário incluir o comando distinct e nem ordenação,
-- devido a condição ser feita pelo identificador da natureza.
-- 4) Na montagem do registro 0190 - Unidade de medida, não é necessário incluir a ordenação, devido a condição ser feita pelo identificador da unidade.
-- 5) Eliminar o comando distinct dos cursores de empresa (rotinas: pkb_monta_bloco_f, pkb_monta_bloco_d, pkb_monta_bloco_c e pkb_monta_bloco_a).
-- 6) Não considerar os processos que são isentos de créditos (CST = ('70','71','72','73','74','75')).
--
-- Em 16/04/2012 - Angela Inês.
-- Não permitir gravar repetido a conta contábil no registro 0500.
-- Foi criado um array com os cursores para não ocorrer duplicidade de registro 0500 - rotina pkb_monta_reg_0140.
--
-- Em 04/04/2012 - Angela Inês.
-- 1) Na montagem do registro A100 alterar os valores caso a nota fiscal esteja cancelada através dos códigos de situação do documento.
-- 2) Considerar os registros C500 somente se existir valores de PIS ou COFINS.
-- 3) Na montagem do registro A100 considerar a geração do registro A010 somente se houver dados em A100.
-- 4) Na montagem do registro C considerar a geração do registro C010 somente se houver dados em C100, C380, C400 e C500.
-- 5) Na montagem do registro D considerar a geração do registro D010 somente se houver dados em D100 e D500.
-- 6) Na montagem do registro F considerar a geração do registro F010 somente se houver dados em F100, F110, F120, F130, F150, F600, F700 e F800.
-- 7) Considerar as notas canceladas para os registros do bloco A100 - Notas fiscais de serviço (mod_fiscal=99, nota_fiscal.dm_st_proc in (4,7)).
--
-- Em 03/04/2012 - Angela Inês.
-- Incluir na recuperação dos planos de contas os registros D100, D101 e D105.
--
-- Em 27/03/2012 - Angela Inês.
-- Não permitir gravar repetido a conta contábil no registro 0500.
-- Foi criado um UNION com os cursores para não ocorrer duplicidade de registro 0500 - rotina pkb_monta_reg_0140.
--
-- Em 26/03/2012 - Angela Inês.
-- Considerar nulo para os campos de alíquota e base de cálculo em quantidade, quando os valores forem em percentuais.
-- Registros: M100, M210, M500, M610, C170, C381, C385, C481, C485
--
-- Em 23/03/2012 - Angela Inês.
-- Gerar o arquivo D100 somente se houver relacionamento com PIS ou COFINS - ct_comp_doc_pis ou ct_comp_doc_cofins.
--
-- Em 10/03/2012 - Leandro Savenhago
-- Refazer geração sem vetores
--
-- Em 07/03/2012 - Angela Inês.
-- Eliminar das colunas dos SELECTS as funções como retorno de colunas. Esse conceito pode causar estouro de memória em alguns clientes.
--
-- Em 05/03/2012 - Angela Inês.
-- Agrupar os valores de complemento de PIS e COFINS para montar os registros D101 e D105.
--
-- Em 05/03/2012 - Angela Inês.
-- Utilizar a função pk_csf.fkg_converte( ev_string           in varchar2
--                                      , en_espacamento      in number default 0
--                                      , en_remove_spc_extra in number default 1
--                                      , en_ret_carac_espec  in number default 1 ) para acertar o campo de texto
--
-- Em 02/03/2011 - Angela Inês.
-- Acertar os parâmetros que se referem a recuperação das notas fiscais, conhecimentos de transporte, demais doctos, bens do ativo e crédtio de estoque.
--
-- Em 28/02/2012 - Angela Inês.
-- Considerar nulo para bloco m105, coluna quant_bc_pis_tot, quando o valor for 0 e o código de crédito for 103, 203, 303, 105, 205, 305, 108, 208, 308.
-- Não considerar a condição ((mf.cod_mod <> '55' and nf.dm_ind_emit = 0) or ( nf.dm_ind_emit in (1) )) para montar o registro 0450.
--
-- Em 27/02/2012 - Angela Inês.
-- Acertar para duas casas decimais os valores de alíquota de PIS e COFINS.   
-- Fazer a quebra de dados para o registro M200 e M600 considerando a CST, alíquota em percentual e alíquota em valor.
--
-- Em 22/02/2012 - Angela Inês.
-- Não considerar a montagem dos blocos C112, C113, C114 e C115.
-- Não informar o código do participante para notas fiscais canceladas, inutilizadas e denegadas - registros C100.
-- Informar a chave da nfe modelo 55 para notas fiscais canceladas, inutilizadas e denegadas - registros C100.
-- Recuperar a inscrição estadual para o registro 0140, o processo estava recuperando o identificador da tabela juridica.
-- No registro C170 considerar o valor do item bruto e não a multiplicação da qtde pelo valor unitário.
--
-- Em 20/02/2012 - Angela Inês.
-- Considerar indexador na rotina (i) e não considerar identificador da nota fiscal como indexador
-- na montagem dos arquivos que recuperam dados de notas fiscais.
-- Acertar os valores fixos referente aos códigos de cada registro.
--
-- Em 24/01/2012 - Angela Inês.
-- Considerar somente 10 caracteres para o NRO_DI do bloco C120.
-- Tabela Compliance Varchar2(12) e Arquivo texto do processo Varchar2(10).
-- Acertar processos de montagem das linhas do arquivo texto (índices incorretos).
--
-- Em 23/01/2012 - Angela Inês.
-- Considerar o período de consolidação da contribuição para recuperar os dados do bloco M200.
-- Tabela: PER_CONS_CONTR_PIS.
-- Considerar o período de consolidação da contribuição para recuperar os dados do bloco M600.
-- Tabela: PER_CONS_CONTR_COFINS.
--
-- Em 18/01/2012 - Angela Inês.
-- Considerar o período de crédito de apuração para recuperar os dados do bloco M800.
-- Tabela: PER_REC_ISENTA_COFINS.
--
-- Em 17/01/2012 - Angela Inês.
-- Considerar o período de crédito de apuração para recuperar os dados do bloco M100.
-- Tabela: PER_APUR_CRED_PIS.
-- Considerar o período de crédito de apuração para recuperar os dados do bloco M400.
-- Tabela: PER_REC_ISENTA_PIS.
-- Considerar o período de crédito de apuração para recuperar os dados do bloco M500.
-- Tabela: PER_APUR_CRED_COFINS.
--
-------------------------------------------------------------------------------------------------------

  --| REGISTRO 1011: DETALHAMENTO DAS CONTRIBUIÇÕES COM EXIGIBILIDADE SUSPENSA
  cursor c_1011(en_empresa_id in abertura_efd_pc.empresa_id%type, 
                en_dt_ini     in abertura_efd_pc.dt_ini%type, 
                en_dt_fin     in abertura_efd_pc.dt_fin%type) is
    select rep.cd REG_REF,
           dc.nro_chave_nfe CHAVE_DOC,
           p.cod_part COD_PART,
           i.id ITEM_ID,
           i.cod_item COD_ITEM,
           to_char(dc.dt_oper, 'ddmmyyyy') DT_OPER,
           sum(dc.vl_oper) VL_OPER,
           pk_csf.fkg_cod_st_cod(dc.codst_id_pis) CST_PIS,
           sum(dc.vl_bc_pis) VL_BC_PIS,
           dc.aliq_pis ALIQ_PIS,
           sum(dc.vl_pis) VL_PIS,
           pk_csf.fkg_cod_st_cod(dc.codst_id_cofins) CST_COFINS,
           sum(dc.vl_bc_cofins) VL_BC_COFINS,
           dc.aliq_cofins ALIQ_COFINS,
           sum(dc.vl_cofins) VL_COFINS,
           pk_csf.fkg_cod_st_cod(dc.codst_id_pis_susp) CST_PIS_SUSP,
           sum(dc.vl_bc_pis_susp) VL_BC_PIS_SUSP,
           dc.aliq_pis_susp ALIQ_PIS_SUSP,
           sum(dc.vl_pis_susp) VL_PIS_SUSP,
           pk_csf.fkg_cod_st_cod(dc.codst_cofins_susp) CST_COFINS_SUSP,
           sum(dc.vl_bc_cofins_susp) VL_BC_COFINS_SUSP,
           dc.aliq_cofins_susp ALIQ_COFINS_SUSP,
           sum(dc.vl_cofins_susp) VL_COFINS_SUSP,
           pc.id PLANOCONTA_ID,
           pc.cod_cta COD_CTA,
           cc.id CENTROCUSTO_ID,
           cc.cod_ccus COD_CCUS,
           dc.desc_doc_oper DESC_DOC_OPER,
           p.id PESSOA_ID
      from acao_judic_pc       aj,
           det_contr_exig_susp dc,
           pessoa              p,
           registr_efd_pc      rep,
           plano_conta         pc,
           centro_custo        cc,
           item                i
     where aj.empresa_id          = en_empresa_id
       and aj.dt_ini             >= en_dt_ini
       and aj.dt_fin             <= en_dt_fin
       and aj.dm_situacao         = 3 -- Processada
       and dc.acaojudicpc_id      = aj.id
       and dc.registrefdpc_id_ref = rep.id
       and dc.planoconta_id       = pc.id
       and dc.centrocusto_id      = cc.id
       and dc.pessoa_id           = p.id
       and dc.item_id             = i.id
     group by rep.cd,
              dc.nro_chave_nfe,
              p.cod_part,
              i.id,
              i.cod_item,
              to_char(dc.dt_oper, 'ddmmyyyy'),
              pk_csf.fkg_cod_st_cod(dc.codst_id_pis),
              dc.aliq_pis,
              pk_csf.fkg_cod_st_cod(dc.codst_id_cofins),
              dc.aliq_cofins,
              pk_csf.fkg_cod_st_cod(dc.codst_id_pis_susp),
              dc.aliq_pis_susp,
              pk_csf.fkg_cod_st_cod(dc.codst_cofins_susp),
              dc.aliq_cofins_susp,
              pc.id,
              pc.cod_cta,
              cc.id,
              cc.cod_ccus,
              dc.desc_doc_oper,
              p.id;

  --| REGISTRO D100: NOTA FISCAL DE SERVIÇO DE TRANSPORTE (CÓDIGO 07) E CONHECIMENTOS DE TRANSPORTE RODOVIÁRIO DE CARGAS (CÓDIGO 08),
  --| CONHECIMENTOS DE TRANSPORTE DE CARGAS AVULSO (CÓDIGO 8B), AQUAVIÁRIO DE CARGAS (CÓDIGO 09), AÉREO (CÓDIGO 10), FERROVIÁRIO DE CARGAS (CÓDIGO 11)
  --| E MULTIMODAL DE CARGAS (CÓDIGO 26), NOTA FISCAL DE TRANSPORTE FERROVIÁRIO DE CARGA ( CÓDIGO 27) E CONHECIMENTO DE TRANSPORTE ELETRÔNICO - CT-e (CÓDIGO 57)
  cursor c_d100(en_empresa_id        in abertura_efd_pc.empresa_id%type, 
                en_dt_ini            in abertura_efd_pc.dt_ini%type, 
                en_dt_fin            in abertura_efd_pc.dt_fin%type, 
                en_dm_dt_escr_dfepoe in empresa.dm_dt_escr_dfepoe%type) is
    select distinct ct.id conhectransp_id,
                    ct.empresa_id,
                    ct.dm_ind_oper ind_oper,
                    ct.dm_ind_emit ind_emit,
                    mf.cod_mod cod_mod,
                    sd.cd cod_sit,
                    ct.serie ser,
                    ct.subserie sub,
                    ct.nro_ct num_doc,
                    decode(mf.cod_mod, '57', ct.nro_chave_cte, null) chv_cte,
                    ct.dt_hr_emissao dt_doc,
                    ct.dt_sai_ent dt_a_p,
                    decode(mf.cod_mod, '57', ct.dm_tp_cte, null) tp_cte,
                    decode(mf.cod_mod, '57', ct.chave_cte_ref, null) chv_cte_ref,
                    v.vl_docto_fiscal vl_doc,
                    v.vl_desc vl_desc,
                    ct.dm_ind_frt ind_frt,
                    v.vl_prest_serv vl_serv,
                    imp.vl_base_calc vl_bc_icms,
                    imp.vl_imp_trib vl_icms,
                    case
                      when (nvl(v.vl_docto_fiscal, 0) - nvl(imp.vl_base_calc, 0)) >= 0 then
                       (nvl(v.vl_docto_fiscal, 0) - nvl(imp.vl_base_calc, 0))
                      else
                       0
                    end vl_nt,
                    ct.cod_cta cod_cta,
                    ct.pessoa_id pessoa_id,
                    ct.inforcompdctofiscal_id
      from tmp_conhec_transp ct,
           tmp_ct_reg_anal ra,
           mod_fiscal mf,
           sit_docto sd,
           tmp_conhec_transp_vlprest v,
           (select i.conhectransp_id,
                   i.vl_base_calc,
                   i.vl_imp_trib,
                   st.cod_st
              from conhec_transp_imp i, 
                   cod_st st, 
                   tipo_imposto ti
             where st.id = i.codst_id
               and ti.id = i.tipoimp_id
               and ti.cd = 1) imp -- ICMS
     where ct.empresa_id          = en_empresa_id
       and ct.dm_st_proc          = 4 -- Autorizado
       and ct.dm_arm_cte_terc     = 0
       and ct.dm_ind_oper         = 0 -- 0 - Entrada, 1 - Saída
       and ((ct.dm_ind_emit = 1 and nvl(ct.dt_sai_ent, ct.dt_hr_emissao) between en_dt_ini and en_dt_fin) 
             or 
            (ct.dm_ind_emit = 0 and en_dm_dt_escr_dfepoe = 0 and ct.dt_hr_emissao between en_dt_ini and en_dt_fin) 
             or
            (ct.dm_ind_emit = 0 and en_dm_dt_escr_dfepoe = 1 and nvl(ct.dt_sai_ent, ct.dt_hr_emissao) between en_dt_ini and en_dt_fin))
       and mf.id                  = ct.modfiscal_id
       and mf.cod_mod in ('07', '08', '8B', '09', '10', '11', '26', '27', '57', '63', '67')
       and ra.conhectransp_id     = ct.id
       and sd.id                  = ct.sitdocto_id
       and v.conhectransp_id      = ct.id
       and imp.conhectransp_id(+) = ct.id
       and pk_csf_efd_pc.fkg_gera_escr_efdpc_cfop_empr(ct.empresa_id,
                                                       ra.cfop_id,
                                                       ra.codst_id,
                                                       null) = 1 -- Verifica se a CFOP faz parte da receita: 0 - Não, 1 - Sim
       and exists (select 1
                     from ct_comp_doc_pis pis, 
                          cod_st cst
                    where pis.conhectransp_id = ct.id
                      and cst.id              = pis.codst_id
                      and cst.cod_st not in ('70', '71', '72', '73', '74', '75')) -- Valores isentos de créditos
     order by ct.empresa_id,
              ct.dm_ind_oper,
              ct.dm_ind_emit,
              mf.cod_mod,
              ct.serie,
              ct.nro_ct;
              
  --| REGISTRO M100: CRÉDITO DE PIS/PASEP RELATIVO AO PERÍODO
  cursor c_m100(en_aberturaefdpc_id in abertura_efd_pc.id%type, 
                en_dt_ini           in abertura_efd_pc.dt_ini%type, 
                en_dt_fin           in abertura_efd_pc.dt_fin%type) is
    select ac.id,
           pa.empresa_id,
           pa.dt_ini,
           pa.dt_fin,
           ac.dm_situacao,
           ac.tipocredpc_id,
           tc.cd cod_cred,
           ac.dm_ind_cred_ori,
           ac.vl_bc_pis,
           ac.aliq_pis,
           ac.quant_bc_pis,
           ac.vl_aliq_pis_quant,
           ac.vl_cred,
           ac.vl_ajus_acres,
           ac.vl_ajus_reduc,
           ac.vl_cred_dif,
           ac.vl_cred_disp,
           ac.dm_ind_desc_cred,
           ac.vl_cred_desc,
           ac.vl_sld_cred
      from r_empresa_abertura_efd_pc r,
           per_apur_cred_pis         pa,
           apur_cred_pis             ac,
           tipo_cred_pc              tc
     where r.aberturaefdpc_id   = en_aberturaefdpc_id
       and pa.empresa_id        = r.empresa_id
       and pa.dt_ini           >= en_dt_ini
       and pa.dt_fin           <= en_dt_fin
       and ac.perapurcredpis_id = pa.id
       and ac.dm_situacao       = 3 -- Processada
       and tc.id                = ac.tipocredpc_id
     order by pa.empresa_id, tc.cd;

  --| REGISTRO M110: AJUSTES DO CRÉDITO DE PIS/PASEP APURADO
  cursor c_m110(en_apurcredpis_id in apur_cred_pis.id%type) is
    select a.id,
           a.apurcredpis_id,
           a.dm_ind_aj,
           a.vl_aj,
           a.ajustcontrpc_id,
           ac.cd cod_aj,
           a.num_doc,
           a.descr_aj,
           a.dt_ref
      from ajust_apur_cred_pis a, 
           ajust_contr_pc ac
     where a.apurcredpis_id = en_apurcredpis_id
       and ac.id            = a.ajustcontrpc_id
     order by a.id;

  --| REGISTRO M115: DETALHAMENTO DOS AJUSTES DO CRÉDITO DE PIS/PASEP APURADO
  cursor c_m115(en_ajustapurcredpis_id in ajust_apur_cred_pis.id%type) is
    select da.det_valor_aj,
           da.codst_id,
           da.det_bc_cred,
           da.det_aliq,
           da.dt_oper_aj,
           da.descr_aj,
           da.planoconta_id,
           da.info_compl
      from det_ajust_apur_cred_pis da
     where da.ajustapurcredpis_id = en_ajustapurcredpis_id;

  --| REGISTRO M200: CONSOLIDAÇÃO DA CONTRIBUIÇÃO PARA O PIS/PASEP DO PERÍODO
  cursor c_m200(en_aberturaefdpc_id in abertura_efd_pc.id%type, 
                en_dt_ini           in abertura_efd_pc.dt_ini%type, 
                en_dt_fin           in abertura_efd_pc.dt_fin%type) is
    select pc.id perconscontrpis_id,
           pc.empresa_id,
           pc.dt_ini,
           pc.dt_fin,
           cc.id conscontrpis_id,
           nvl(cc.vl_tot_cont_nc_per, 0) vl_tot_cont_nc_per,
           nvl(cc.vl_tot_cred_desc, 0) vl_tot_cred_desc,
           nvl(cc.vl_tot_cred_desc_ant, 0) vl_tot_cred_desc_ant,
           nvl(cc.vl_tot_cont_nc_dev, 0) vl_tot_cont_nc_dev,
           nvl(cc.vl_ret_nc, 0) vl_ret_nc,
           nvl(cc.vl_out_ded_nc, 0) vl_out_ded_nc,
           nvl(cc.vl_cont_nc_rec, 0) vl_cont_nc_rec,
           nvl(cc.vl_tot_cont_cum_per, 0) vl_tot_cont_cum_per,
           nvl(cc.vl_ret_cum, 0) vl_ret_cum,
           nvl(cc.vl_out_ded_cum, 0) vl_out_ded_cum,
           nvl(cc.vl_cont_cum_rec, 0) vl_cont_cum_rec,
           nvl(cc.vl_tot_cont_rec, 0) vl_tot_cont_rec
      from r_empresa_abertura_efd_pc re,
           per_cons_contr_pis        pc,
           cons_contr_pis            cc
     where re.aberturaefdpc_id   = en_aberturaefdpc_id
       and pc.empresa_id         = re.empresa_id
       and pc.dt_ini            >= en_dt_ini
       and pc.dt_fin            <= en_dt_fin
       and cc.perconscontrpis_id = pc.id
       and cc.dm_situacao        = 3 -- processada
     order by pc.empresa_id;

  --| REGISTRO M210: DETALHAMENTO DA CONTRIBUIÇÃO PARA O PIS/PASEP DO PERÍODO
  cursor c_m210(en_conscontrpis_id cons_contr_pis.id%type) is
    select dc.contrsocapurpc_id,
           cs.cd cod_cont,
           dc.aliq_pis,
           dc.vl_aliq_pis_quant,
           nvl(sum(nvl(dc.vl_rec_brt, 0)), 0) vl_rec_brt,
           nvl(sum(nvl(dc.vl_bc_cont, 0)), 0) vl_bc_cont,
           nvl(sum(nvl(dc.quant_bc_pis, 0)), 0) quant_bc_pis,
           nvl(sum(nvl(dc.vl_cont_apur, 0)), 0) vl_cont_apur,
           nvl(sum(nvl(dc.vl_ajust_acrec, 0)), 0) vl_ajust_acrec,
           nvl(sum(nvl(dc.vl_ajust_reduc, 0)), 0) vl_ajust_reduc,
           nvl(sum(nvl(dc.vl_cont_difer, 0)), 0) vl_cont_difer,
           nvl(sum(nvl(dc.vl_cont_difer_ant, 0)), 0) vl_cont_difer_ant,
           nvl(sum(nvl(dc.vl_cont_per, 0)), 0) vl_cont_per,
           nvl(sum(nvl(dc.vl_ajus_acres_bc_pis, 0)), 0) vl_ajus_acres_bc_pis,
           nvl(sum(nvl(dc.vl_ajus_reduc_bc_pis, 0)), 0) vl_ajus_reduc_bc_pis,
           nvl(sum(nvl(dc.vl_bc_cont_ajus, 0)), 0) vl_bc_cont_ajus,
           dc.id detconscontrpis_id
      from cons_contr_pis cc, 
           det_cons_contr_pis dc, 
           contr_soc_apur_pc cs
     where cc.id              = en_conscontrpis_id
       and cc.dm_situacao     = 3 -- processada
       and dc.conscontrpis_id = cc.id
       and cs.id              = dc.contrsocapurpc_id
     group by dc.contrsocapurpc_id,
              cs.cd,
              dc.aliq_pis,
              dc.vl_aliq_pis_quant,
              dc.id;

  --| REGISTRO M215: AJUSTES DA BASE DE CÁLCULO DA CONTRIBUIÇÃO PARA O PIS/PASEP APURADA
  cursor c_m215(en_detconscontrpis_id det_cons_contr_pis.id%type) is
    select a.dm_ind_aj_bc,
           a.vl_aj_bc,
           a.codajbccontr_id,
           a.num_doc,
           a.descr_aj_bc,
           to_char(a.dt_ref, 'ddmmrrrr') dt_ref,
           a.planoconta_id,
           a.cnpj,
           a.info_compl
      from ajust_bc_cont_pis a
     where a.detconscontrpis_id = en_detconscontrpis_id;
  /*where exists (select 1
   from cons_contr_pis     cc,
        det_cons_contr_pis dc,
        contr_soc_apur_pc  cs
  where cc.id              = en_conscontrpis_id
    and cc.dm_situacao     = 3 -- Processada
    and dc.conscontrpis_id = cc.id
    and cs.id              = dc.contrsocapurpc_id
    and dc.id              = a.detconscontrpis_id)*/

  --| REGISTRO M220: AJUSTES DA CONTRIBUIÇÃO PARA O PIS/PASEP APURADA
  cursor c_m220(en_conscontrpis_id   cons_contr_pis.id%type, 
                en_contrsocapurpc_id contr_soc_apur_pc.id%type) is
    select ap.id,
           ac.cd cod_aj,
           ap.descr_aj,
           ap.num_doc,
           ap.dm_ind_aj,
           ap.dt_ref,
           ap.vl_aj
      from cons_contr_pis       cc,
           det_cons_contr_pis   dc,
           ajust_contr_pis_apur ap,
           ajust_contr_pc       ac
     where cc.id                 = en_conscontrpis_id
       and dc.conscontrpis_id    = cc.id
       and dc.contrsocapurpc_id  = en_contrsocapurpc_id
       and ap.detconscontrpis_id = dc.id
       and ac.id                 = ap.ajustcontrpc_id
     order by ac.cd;

  --| REGISTRO M225: DETALHAMENTO DOS AJUSTES DA CONTRIBUIÇÃO PARA O PIS/PASEP APURADA
  cursor c_m225(en_ajustcontrpisapur_id in ajust_contr_pis_apur.id%type) is
    select da.det_valor_aj,
           da.codst_id,
           da.det_bc_cred,
           da.det_aliq,
           da.dt_oper_aj,
           da.descr_aj,
           da.planoconta_id,
           da.info_compl
      from det_ajust_contr_pis_apur da
     where da.ajustcontrpisapur_id = en_ajustcontrpisapur_id;

  --| REGISTRO M400: RECEITAS ISENTAS
  cursor c_m400(en_aberturaefdpc_id in abertura_efd_pc.id%type, 
                en_dt_ini           in abertura_efd_pc.dt_ini%type, 
                en_dt_fin           in abertura_efd_pc.dt_fin%type) is
    select pr.id,
           cs.cod_st,
           cs.id codst_id,
           sum(ri.vl_tot_rec) vl_tot_rec,
           pc.cod_cta,
           ri.desc_compl
      from r_empresa_abertura_efd_pc ra,
           per_rec_isenta_pis        pr,
           rec_isenta_pis            ri,
           cod_st                    cs,
           plano_conta               pc
     where ra.aberturaefdpc_id   = en_aberturaefdpc_id
       and pr.empresa_id         = ra.empresa_id
       and pr.dt_ini            >= en_dt_ini
       and pr.dt_fin            <= en_dt_fin
       and ri.perrecisentapis_id = pr.id
       and ri.dm_situacao        = 3 -- Processada
       and cs.id                 = ri.codst_id
       and pc.id(+)              = ri.planoconta_id
     group by cs.cod_st, 
              cs.id, 
              pc.cod_cta, 
              ri.desc_compl, 
              pr.id;

  --| REGISTRO M500: CRÉDITO DE COFINS RELATIVO AO PERÍODO
  cursor c_m500(en_aberturaefdpc_id in abertura_efd_pc.id%type, 
                en_dt_ini           in abertura_efd_pc.dt_ini%type, 
                en_dt_fin           in abertura_efd_pc.dt_fin%type) is
    select ac.id,
           pa.empresa_id,
           pa.dt_ini,
           pa.dt_fin,
           ac.dm_situacao,
           ac.tipocredpc_id,
           tc.cd cod_cred,
           ac.dm_ind_cred_ori,
           ac.vl_bc_cofins,
           ac.aliq_cofins,
           ac.quant_bc_cofins,
           ac.vl_aliq_cofins_quant,
           ac.vl_cred,
           ac.vl_ajus_acres,
           ac.vl_ajus_reduc,
           ac.vl_cred_difer,
           ac.vl_cred_disp,
           ac.dm_ind_desc_cred,
           ac.vl_cred_desc,
           ac.vl_sld_cred
      from r_empresa_abertura_efd_pc r,
           per_apur_cred_cofins      pa,
           apur_cred_cofins          ac,
           tipo_cred_pc              tc
     where r.aberturaefdpc_id      = en_aberturaefdpc_id
       and pa.empresa_id           = r.empresa_id
       and pa.dt_ini              >= en_dt_ini
       and pa.dt_fin              <= en_dt_fin
       and ac.perapurcredcofins_id = pa.id
       and ac.dm_situacao          = 3 -- Processada
       and tc.id                   = ac.tipocredpc_id
     order by pa.empresa_id;

  --| REGISTRO M510: AJUSTES DO CRÉDITO DE COFINS APURADO
  cursor c_m510(en_apurcredcofins_id apur_cred_cofins.id%type) is
    select a.id,
           a.apurcredcofins_id,
           a.dm_ind_aj,
           a.vl_aj,
           a.ajustcontrpc_id,
           ac.cd cod_aj,
           a.num_doc,
           a.descr_aj,
           a.dt_ref
      from ajust_apur_cred_cofins a, 
           ajust_contr_pc ac
     where a.apurcredcofins_id = en_apurcredcofins_id
       and ac.id               = a.ajustcontrpc_id
     order by a.id;

  --| REGISTRO M515: DETALHAMENTO DOS AJUSTES DO CRÉDITO DE COFINS APURADO
  cursor c_m515(en_ajustapurcredcofins_id in ajust_apur_cred_cofins.id%type) is
    select da.det_valor_aj,
           da.codst_id,
           da.det_bc_cred,
           da.det_aliq,
           da.dt_oper_aj,
           da.descr_aj,
           da.planoconta_id,
           da.info_compl
      from det_ajust_apur_cred_cofins da
     where da.ajustapurcredcofins_id = en_ajustapurcredcofins_id;

  --| REGISTRO M600: CONSOLIDAÇÃO DA CONTRIBUIÇÃO PARA A SEGURIDADE SOCIAL - COFINS DO PERÍODO
  cursor c_m600(en_aberturaefdpc_id in abertura_efd_pc.id%type,  
                en_dt_ini           in abertura_efd_pc.dt_ini%type, 
                en_dt_fin           in abertura_efd_pc.dt_fin%type) is
    select pc.id perconscontrcofins_id,
           pc.empresa_id,
           pc.dt_ini,
           pc.dt_fin,
           cc.id conscontrcofins_id,
           nvl(cc.vl_tot_cont_nc_per, 0) vl_tot_cont_nc_per,
           nvl(cc.vl_tot_cred_desc, 0) vl_tot_cred_desc,
           nvl(cc.vl_tot_cred_desc_ant, 0) vl_tot_cred_desc_ant,
           nvl(cc.vl_tot_cont_nc_dev, 0) vl_tot_cont_nc_dev,
           nvl(cc.vl_ret_nc, 0) vl_ret_nc,
           nvl(cc.vl_out_ded_nc, 0) vl_out_ded_nc,
           nvl(cc.vl_cont_nc_rec, 0) vl_cont_nc_rec,
           nvl(cc.vl_tot_cont_cum_per, 0) vl_tot_cont_cum_per,
           nvl(cc.vl_ret_cum, 0) vl_ret_cum,
           nvl(cc.vl_out_ded_cum, 0) vl_out_ded_cum,
           nvl(cc.vl_cont_cum_rec, 0) vl_cont_cum_rec,
           nvl(cc.vl_tot_cont_rec, 0) vl_tot_cont_rec
      from r_empresa_abertura_efd_pc re,
           per_cons_contr_cofins     pc,
           cons_contr_cofins         cc
     where re.aberturaefdpc_id      = en_aberturaefdpc_id
       --and re.empresa_id          = gt_row_abertura_efd_pc.empresa_id
       and pc.empresa_id            = re.empresa_id
       and pc.dt_ini               >= en_dt_ini
       and pc.dt_fin               <= en_dt_fin
       and cc.perconscontrcofins_id = pc.id
       and cc.dm_situacao           = 3 -- processada
     order by pc.empresa_id;

  --| REGISTRO M610: DETALHAMENTO DA CONTRIBUIÇÃO PARA A SEGURIDADE SOCIAL - COFINS DO PERÍODO
  cursor c_m610(en_conscontrcofins_id cons_contr_cofins.id%type) is
    select dc.contrsocapurpc_id,
           cs.cd cod_cont,
           dc.aliq_cofins,
           dc.vl_aliq_cofins_quant,
           nvl(sum(nvl(dc.vl_rec_brt, 0)), 0) vl_rec_brt,
           nvl(sum(nvl(dc.vl_bc_cont, 0)), 0) vl_bc_cont,
           nvl(sum(nvl(dc.quant_bc_cofins, 0)), 0) quant_bc_cofins,
           nvl(sum(nvl(dc.vl_cont_apur, 0)), 0) vl_cont_apur,
           nvl(sum(nvl(dc.vl_ajust_acrec, 0)), 0) vl_ajust_acrec,
           nvl(sum(nvl(dc.vl_ajust_reduc, 0)), 0) vl_ajust_reduc,
           nvl(sum(nvl(dc.vl_cont_difer, 0)), 0) vl_cont_difer,
           nvl(sum(nvl(dc.vl_cont_difer_ant, 0)), 0) vl_cont_difer_ant,
           nvl(sum(nvl(dc.vl_cont_per, 0)), 0) vl_cont_per,
           nvl(sum(nvl(dc.vl_ajus_acres_bc_cofins, 0)), 0) vl_ajus_acres_bc_cofins,
           nvl(sum(nvl(dc.vl_ajus_reduc_bc_cofins, 0)), 0) vl_ajus_reduc_bc_cofins,
           nvl(sum(nvl(dc.vl_bc_cont_ajus, 0)), 0) vl_bc_cont_ajus,
           dc.id detconscontrcofins_id
      from cons_contr_cofins     cc,
           det_cons_contr_cofins dc,
           contr_soc_apur_pc     cs
     where cc.id                 = en_conscontrcofins_id
       and cc.dm_situacao        = 3 -- processada
       and dc.conscontrcofins_id = cc.id
       and cs.id                 = dc.contrsocapurpc_id
     group by dc.contrsocapurpc_id,
              cs.cd,
              dc.aliq_cofins,
              dc.vl_aliq_cofins_quant,
              dc.id;

  --| REGISTRO M615: AJUSTES DA BASE DE CÁLCULO DA COFINS APURADA
  cursor c_m615(en_detconscontrcofins_id det_cons_contr_cofins.id%type) is
    select a.dm_ind_aj_bc,
           a.vl_aj_bc,
           a.codajbccontr_id,
           a.num_doc,
           a.descr_aj_bc,
           to_char(a.dt_ref, 'ddmmrrrr') dt_ref,
           a.planoconta_id,
           a.cnpj,
           a.info_compl
      from ajust_bc_cont_cofins a
     where a.detconscontrcofins_id = en_detconscontrcofins_id;
  /*where exists (select 1
   from cons_contr_cofins     cc,
        det_cons_contr_cofins dc,
        contr_soc_apur_pc     cs
  where cc.id                 = en_conscontrcofins_id
    and cc.dm_situacao        = 3 -- Processada
    and dc.conscontrcofins_id = cc.id
    and cs.id                 = dc.contrsocapurpc_id
    and dc.id                 = a.detconscontrcofins_id)*/

  --| REGISTRO M620: AJUSTES DA COFINS APURADA
  cursor c_m620(en_conscontrcofins_id cons_contr_cofins.id%type, 
                en_contrsocapurpc_id contr_soc_apur_pc.id%type) is
    select ap.id,
           ac.cd cod_aj,
           ap.descr_aj,
           ap.num_doc,
           ap.dm_ind_aj,
           ap.dt_ref,
           ap.vl_aj
      from cons_contr_cofins       cc,
           det_cons_contr_cofins   dc,
           ajust_contr_cofins_apur ap,
           ajust_contr_pc          ac
     where cc.id                    = en_conscontrcofins_id
       and dc.conscontrcofins_id    = cc.id
       and dc.contrsocapurpc_id     = en_contrsocapurpc_id
       and ap.detconscontrcofins_id = dc.id
       and ac.id                    = ap.ajustcontrpc_id
     order by ac.cd;

   --| REGISTRO M625: DETALHAMENTO DOS AJUSTES DA COFINS APURADA
  cursor c_m625(en_ajustcontrcofinsapur_id in ajust_contr_cofins_apur.id%type) is
    select da.det_valor_aj,
           da.codst_id,
           da.det_bc_cred,
           da.det_aliq,
           da.dt_oper_aj,
           da.descr_aj,
           da.planoconta_id,
           da.info_compl
      from det_ajust_contr_cofins_apur da
     where da.ajustcontrcofinsapur_id = en_ajustcontrcofinsapur_id;

  --| REGISTRO M800: RECEITAS ISENTAS, NÃO ALCANÇADAS PELA INCIDÊNCIA DA CONTRIBUIÇÃO, SUJEITAS A
  --| ALÍQUOTA ZERO OU DE VENDAS COM SUSPENSÃO - COFINS
  cursor c_m800(en_aberturaefdpc_id in abertura_efd_pc.id%type, 
                en_dt_ini           in abertura_efd_pc.dt_ini%type, 
                en_dt_fin           in abertura_efd_pc.dt_fin%type) is
    select pr.id,
           cs.cod_st,
           cs.id codst_id,
           sum(ri.vl_tot_rec) vl_tot_rec,
           pc.cod_cta,
           ri.desc_compl
      from r_empresa_abertura_efd_pc re,
           per_rec_isenta_cofins     pr,
           rec_isenta_cofins         ri,
           cod_st                    cs,
           plano_conta               pc
     where re.aberturaefdpc_id      = en_aberturaefdpc_id
       and pr.empresa_id            = re.empresa_id
       and pr.dt_ini               >= en_dt_ini
       and pr.dt_fin               <= en_dt_fin
       and ri.perrecisentacofins_id = pr.id
       and ri.dm_situacao           = 3 -- Processada
       and cs.id                    = ri.codst_id
       and pc.id(+)                 = ri.planoconta_id
     group by pr.id,
              cs.cod_st,
              cs.id,
              pc.cod_cta,
              ri.desc_compl; 
              
--| REGISTRO 0150: TABELA DE CADASTRO DO PARTICIPANTE
   -- Nível hierárquico - 1
   -- Ocorrência - vários por arquivo  (zerado a cada novo registro 0140)
   type tab_reg_0150 is record ( cod_part   varchar2(60) );
--
   type t_tab_reg_0150 is table of tab_reg_0150 index by binary_integer;
   vt_tab_reg_0150 t_tab_reg_0150;

--| REGISTRO 0190: IDENTIFICAÇÃO DAS UNIDADES DE MEDIDA
   -- Nível hierárquico: 2
   -- Ocorrência: vários por arquivo
   type tab_reg_0190 is record ( unid   varchar2(6)
                               );
--
   type t_tab_reg_0190 is table of tab_reg_0190 index by varchar2(6); -- binary_integer;
   type t_bi_tab_reg_0190 is table of t_tab_reg_0190 index by varchar2(6); -- binary_integer;
   vt_bi_tab_reg_0190 t_bi_tab_reg_0190;

--| REGISTRO 0200: TABELA DE IDENTIFICAÇÃO DO ITEM (PRODUTO E SERVIÇOS)
   -- Nível hierárquico - 3
   -- Ocorrência - vários (por arquivo)
   type tab_reg_0200 is record ( cod_item   varchar2(60)
                               );
--
   type t_tab_reg_0200 is table of tab_reg_0200 index by varchar2(60); --binary_integer;
   type t_bi_tab_reg_0200 is table of t_tab_reg_0200 index by varchar2(60); --binary_integer;
   vt_bi_tab_reg_0200 t_bi_tab_reg_0200;

--| REGISTRO 0400: TABELA DE NATUREZA DA OPERAÇÃO/PRESTAÇÃO
   -- Nível hierárquico - 3
   -- Ocorrência -  vários por arquivo
   type tab_reg_0400 is record ( cod_nat   varchar2(10)
                               );
--
   type t_tab_reg_0400 is table of tab_reg_0400 index by binary_integer;
   type t_bi_tab_reg_0400 is table of t_tab_reg_0400 index by binary_integer;
   vt_bi_tab_reg_0400 t_bi_tab_reg_0400;

--| REGISTRO 0450: TABELA DE INFORMAÇÃO COMPLEMENTAR DO DOCUMENTO FISCAL
   -- Nível hierárquico - 3
   -- Ocorrência - vários por arquivo
   type tab_reg_0450 is record ( cod_inf   varchar2(6)
                               );
--
   type t_tab_reg_0450    is table of tab_reg_0450   index by varchar2(30);
   type t_bi_tab_reg_0450 is table of t_tab_reg_0450 index by varchar2(30);
   vt_bi_tab_reg_0450 t_bi_tab_reg_0450;

--| REGISTRO 0500: TABELA DE PLANOS DE CONTAS CONTÁBEIS
   -- Nível hierárquico - 3
   -- Ocorrência -  vários por arquivo
   type tab_reg_0500 is record ( cod_cta_ref_dt varchar2(100) -- cod_cta||cod_cta_ref||dt_alt
                               );
--
   type t_tab_reg_0500 is table of tab_reg_0500 index by varchar2(100); -- índice: cod_cta||cod_cta_ref||dt_alt
   vt_tab_reg_0500     t_tab_reg_0500;

--| REGISTRO 0600: TABELA DE CENTROS DE CUSTOS
   -- Nível hierárquico - 3
   -- Ocorrência -  vários por arquivo
   type tab_reg_0600 is record ( cod_ccus   centro_custo.cod_ccus%type
                               );
--
   type t_tab_reg_0600 is table of tab_reg_0600 index by binary_integer;
   vt_tab_reg_0600     t_tab_reg_0600;

   --
   --| Variáveis de quantidade de linha de cada registro
   --
   -- BLOCO 0: ABERTURA, IDENTIFICAÇÃO E REFERÊNCIAS
   gn_qtde_reg_0000 number := 0;
   gn_qtde_reg_0001 number := 0;
   gn_qtde_reg_0035 number := 0;
   gn_qtde_reg_0100 number := 0;
   gn_qtde_reg_0110 number := 0;
   gn_qtde_reg_0111 number := 0;
   gn_qtde_reg_0120 number := 0;
   gn_qtde_reg_0140 number := 0;
   gn_qtde_reg_0145 number := 0;
   gn_qtde_reg_0150 number := 0;
   gn_qtde_reg_0190 number := 0;
   gn_qtde_reg_0200 number := 0;
   gn_qtde_reg_0205 number := 0;
   gn_qtde_reg_0206 number := 0;
   gn_qtde_reg_0208 number := 0;
   gn_qtde_reg_0400 number := 0;
   gn_qtde_reg_0450 number := 0;
   gn_qtde_reg_0500 number := 0;
   gn_qtde_reg_0600 number := 0;
   gn_qtde_reg_0900 number := 0;
   gn_qtde_reg_0990 number := 0;
   --
   -- BLOCO A: DOCUMENTOS FISCAIS - SERVIÇOS (NÃO SUJEITOS AO ICMS)
   gn_qtde_reg_a001 number := 0;
   gn_qtde_reg_a010 number := 0;
   gn_qtde_reg_a100 number := 0;
   gn_qtde_reg_a110 number := 0;
   gn_qtde_reg_a111 number := 0;
   gn_qtde_reg_a120 number := 0;
   gn_qtde_reg_a170 number := 0;
   gn_qtde_reg_a990 number := 0;
   --
   -- BLOCO C: DOCUMENTOS FISCAIS I - MERCADORIAS (ICMS/IPI)
   gn_qtde_reg_c001 number := 0;
   gn_qtde_reg_c010 number := 0;
   gn_qtde_reg_c100 number := 0;
   gn_qtde_reg_c110 number := 0;
   gn_qtde_reg_c111 number := 0;
   gn_qtde_reg_c120 number := 0;
   gn_qtde_reg_c170 number := 0;
   gn_qtde_reg_c175 number := 0;
   gn_qtde_reg_c380 number := 0;
   gn_qtde_reg_c381 number := 0;
   gn_qtde_reg_c385 number := 0;
   gn_qtde_reg_c400 number := 0;
   gn_qtde_reg_c405 number := 0;
   gn_qtde_reg_c481 number := 0;
   gn_qtde_reg_c485 number := 0;
   gn_qtde_reg_c489 number := 0;
   gn_qtde_reg_c490 number := 0;
   gn_qtde_reg_c491 number := 0;
   gn_qtde_reg_c495 number := 0;
   gn_qtde_reg_c500 number := 0;
   gn_qtde_reg_c501 number := 0;
   gn_qtde_reg_c505 number := 0;
   gn_qtde_reg_c509 number := 0;
   gn_qtde_reg_c860 number := 0;
   gn_qtde_reg_c870 number := 0;
   gn_qtde_reg_c880 number := 0;
   gn_qtde_reg_c990 number := 0;
   --
   -- BLOCO D: DOCUMENTOS FISCAIS II - SERVIÇOS (ICMS).
   gn_qtde_reg_d001 number := 0;
   gn_qtde_reg_d010 number := 0;
   gn_qtde_reg_d100 number := 0;
   gn_qtde_reg_d101 number := 0;
   gn_qtde_reg_d105 number := 0;
   gn_qtde_reg_d111 number := 0;
   gn_qtde_reg_d200 number := 0;
   gn_qtde_reg_d201 number := 0;
   gn_qtde_reg_d205 number := 0;
   gn_qtde_reg_d209 number := 0;
   gn_qtde_reg_d500 number := 0;
   gn_qtde_reg_d501 number := 0;
   gn_qtde_reg_d505 number := 0;
   gn_qtde_reg_d509 number := 0;
   gn_qtde_reg_d600 number := 0;
   gn_qtde_reg_d601 number := 0;
   gn_qtde_reg_d605 number := 0;
   gn_qtde_reg_d609 number := 0;
   gn_qtde_reg_d990 number := 0;
   --
   --| BLOCO F: DEMAIS DOCUMENTOS E OPERAÇÕES
   gn_qtde_reg_f001 number := 0;
   gn_qtde_reg_f010 number := 0;
   gn_qtde_reg_f100 number := 0;
   gn_qtde_reg_f111 number := 0;
   gn_qtde_reg_f120 number := 0;
   gn_qtde_reg_f129 number := 0;
   gn_qtde_reg_f130 number := 0;
   gn_qtde_reg_f139 number := 0;
   gn_qtde_reg_f150 number := 0;
   gn_qtde_reg_f200 number := 0;
   gn_qtde_reg_f205 number := 0;
   gn_qtde_reg_f210 number := 0;
   gn_qtde_reg_f211 number := 0;
   gn_qtde_reg_f500 number := 0;
   gn_qtde_reg_f509 number := 0;
   gn_qtde_reg_f510 number := 0;
   gn_qtde_reg_f519 number := 0;
   gn_qtde_reg_f525 number := 0;
   gn_qtde_reg_f550 number := 0;
   gn_qtde_reg_f559 number := 0;
   gn_qtde_reg_f560 number := 0;
   gn_qtde_reg_f569 number := 0;
   gn_qtde_reg_f600 number := 0;
   gn_qtde_reg_f700 number := 0;
   gn_qtde_reg_f800 number := 0;
   gn_qtde_reg_f990 number := 0;
   --
   -- BLOCO I - OPERAÇÕES DAS INSTITUIÇÕES FINANCEIRAS, SEGURADORAS, ENTIDADES DE PREVID. PRIVADA, OPERADORAS DE PLANOS DE ASSIST. À SAÚDE E PESSOAS JURÍDICAS
   gn_qtde_reg_i001 number := 0;
   gn_qtde_reg_i010 number := 0;
   gn_qtde_reg_i100 number := 0;
   gn_qtde_reg_i199 number := 0;
   gn_qtde_reg_i200 number := 0;
   gn_qtde_reg_i299 number := 0;
   gn_qtde_reg_i300 number := 0;
   gn_qtde_reg_i399 number := 0;
   gn_qtde_reg_i990 number := 0;
   --
   -- BLOCO M - APURAÇÃO DA CONTRIBUIÇÃO E CRÉDITO DO PIS/PASEP E DA COFINS
   gn_qtde_reg_m001 number := 0;
   gn_qtde_reg_m100 number := 0;
   gn_qtde_reg_m105 number := 0;
   gn_qtde_reg_m110 number := 0;
   gn_qtde_reg_m115 number := 0;
   gn_qtde_reg_m200 number := 0;
   gn_qtde_reg_m205 number := 0;
   gn_qtde_reg_m210 number := 0;
   gn_qtde_reg_m211 number := 0;
   gn_qtde_reg_m215 number := 0;
   gn_qtde_reg_m220 number := 0;
   gn_qtde_reg_m225 number := 0;
   gn_qtde_reg_m230 number := 0;
   gn_qtde_reg_m300 number := 0;
   gn_qtde_reg_m350 number := 0;
   gn_qtde_reg_m400 number := 0;
   gn_qtde_reg_m410 number := 0;
   gn_qtde_reg_m500 number := 0;
   gn_qtde_reg_m505 number := 0;
   gn_qtde_reg_m510 number := 0;
   gn_qtde_reg_m515 number := 0;
   gn_qtde_reg_m600 number := 0;
   gn_qtde_reg_m605 number := 0;
   gn_qtde_reg_m610 number := 0;
   gn_qtde_reg_m611 number := 0;
   gn_qtde_reg_m615 number := 0;
   gn_qtde_reg_m620 number := 0;
   gn_qtde_reg_m625 number := 0;
   gn_qtde_reg_m630 number := 0;
   gn_qtde_reg_m700 number := 0;
   gn_qtde_reg_m800 number := 0;
   gn_qtde_reg_m810 number := 0;
   gn_qtde_reg_m990 number := 0;
   --
   -- BLOCO P: APURAÇÃO DA CONTRIBUIÇÃO PREVIDENCIÁRIA SOBRE A RECEITA BRUTA (CPRB)
   gn_qtde_reg_p001 number := 0;
   gn_qtde_reg_p010 number := 0;
   gn_qtde_reg_p100 number := 0;
   gn_qtde_reg_p110 number := 0;
   gn_qtde_reg_p199 number := 0;
   gn_qtde_reg_p200 number := 0;
   gn_qtde_reg_p210 number := 0;  
   gn_qtde_reg_p990 number := 0;
   --
   -- BLOCO 1: COMPLEMENTO DA ESCRITURAÇÃO - CONTROLE DE SALDOS DE CRÉDITOS E DE RETENÇÕES, OPERAÇÕES EXTEMPORÂNEAS E OUTRAS INFORMAÇÕES
   gn_qtde_reg_1001 number := 0;
   gn_qtde_reg_1010 number := 0;
   gn_qtde_reg_1011 number := 0;
   gn_qtde_reg_1020 number := 0;
   gn_qtde_reg_1050 number := 0;
   gn_qtde_reg_1100 number := 0;
   gn_qtde_reg_1101 number := 0;
   gn_qtde_reg_1102 number := 0;
   gn_qtde_reg_1200 number := 0;
   gn_qtde_reg_1210 number := 0;
   gn_qtde_reg_1220 number := 0;
   gn_qtde_reg_1300 number := 0;
   gn_qtde_reg_1500 number := 0;
   gn_qtde_reg_1501 number := 0;
   gn_qtde_reg_1502 number := 0;
   gn_qtde_reg_1600 number := 0;
   gn_qtde_reg_1610 number := 0;
   gn_qtde_reg_1620 number := 0;
   gn_qtde_reg_1700 number := 0;
   gn_qtde_reg_1800 number := 0;
   gn_qtde_reg_1809 number := 0;
   gn_qtde_reg_1900 number := 0;
   gn_qtde_reg_1990 number := 0;
   --
   -- BLOCO 9: CONTROLE E ENCERRAMENTO DO ARQUIVO DIGITAL
   gn_qtde_reg_9001 number := 0;
   gn_qtde_reg_9900 number := 0;
   gn_qtde_reg_9990 number := 0;
   gn_qtde_reg_9999 number := 0;
   --
   gn_seq_arq number := 0;

-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------

--| Variáveis globais utilizadas na geração do arquivo
   gl_conteudo                   estr_arq_efd_pc.conteudo%type;
   gt_row_abertura_efd_pc        abertura_efd_pc%rowtype;
   gt_row_abertura_efd_pc_regime abertura_efd_pc_regime%rowtype;
   gt_row_versao_layout_efd_pc   versao_layout_efd_pc%rowtype;
   gn_dm_dt_escr_dfepoe          empresa.dm_dt_escr_dfepoe%type;
   gn_dm_val_pconta_pis          param_efd_contr.dm_val_pconta_pis%type;
   gn_dm_val_pconta_cofins       param_efd_contr.dm_val_pconta_cofins%type;
   gn_dm_val_ccusto_pis          param_efd_contr.dm_val_ccusto_pis%type;
   gn_dm_val_ccusto_cofins       param_efd_contr.dm_val_ccusto_cofins%type;
   gn_dm_quebra_infadic_spedc    param_efd_contr.dm_quebra_infadic_spedc%type;
   gn_codinf                     number := 0;
   vtn_nfinforadic_id            dbms_sql.number_table;
   gn_gerou_reg_C400             number := 0;
   gn_origem_dado_pessoa         number;  

--| Variáveis para logs/mensagens
   gv_mensagem_log    log_generico.mensagem%type := null;
   gv_obj_referencia  log_generico.obj_referencia%type := null;
   gn_referencia_id   log_generico.referencia_id%type := null;
   gv_resumo_log      log_generico.resumo%type := null;

--| Declaração de constantes
   erro_de_validacao  constant number := 1;
   erro_de_sistema    constant number := 2;
   erro_de_informacao    constant number := 35; -- 35- Erro de informação

-------------------------------------------------------------------------------------------------------

/*
Todos os registros devem conter no final de cada linha do arquivo digital, após o caractere delimitador
Pipe acima mencionado, os caracteres "CR" (Carriage Return) e "LF" (Line Feed) correspondentes a
"retorno do carro" e "salto de linha" (CR e LF: caracteres 13 e 10, respectivamente, da Tabela ASCII).
*/  

   CR  CONSTANT VARCHAR2(1) := CHR(13);
   LF  CONSTANT VARCHAR2(1) := CHR(10);
   FINAL_DE_LINHA CONSTANT VARCHAR2(4000) := CR || LF;

w_objeto         varchar2(30) := 'PK_GERA_ARQ_EFD_PC_CSF';
w_ins_mensagens  number default null;

------------------------------------------------------------------------------------------------------- 
-- Procedimento inicia montagem da estrutura do arquivo texto do SPED Fiscal Pis/Cofins
 
PROCEDURE PKB_GERA_ARQUIVO_EFD_PC(EN_ABERTURAEFDPC_ID IN ABERTURA_EFD_PC.ID%TYPE);

PROCEDURE PRC_GERA_LOG_ON_DEBUG(P_MENSAGEM IN VARCHAR2);

-------------------------------------------------------------------------------------------------------
-- Procedure para Geração da Guia de Pagamento de Imposto
procedure pkg_gera_guia_pgto (en_aberturaefdpc_id  in abertura_efd_pc.id%type,
                              en_usuario_id        in neo_usuario.id%type);


-------------------------------------------------------------------------------------------------------
-- Procedure para Estorno da Guia de Pagamento de Imposto
procedure pkg_estorna_guia_pgto (en_aberturaefdpc_id  in abertura_efd_pc.id%type);




END PK_GERA_ARQ_EFD_PC;
/
