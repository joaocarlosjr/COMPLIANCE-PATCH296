create or replace package csf_own.pk_csf_gera_dados_fci is

-------------------------------------------------------------------------------------------------------
-- Especificação do pacote de Geração de Dados da Ficha de Conteudo do Importação.
-------------------------------------------------------------------------------------------------------
--
-- Em 24/12/2020 - Marcos Ferreira
-- Distribuições: 2.9.6 / 2.9.5-3 / 2.9.4-6
-- Redmine #74546: Valor entrada incorreto.
-- Rotinas Alteradas: pkb_calcular_arq - Correção do join do cursor c_mem,
--
-- Em 19/10/2020 - Marcos Ferreira
-- Distribuições: 2.9.6 / 2.9.5-1 / 2.9.4-4
-- Redmine #72332: Erro no calculo FCI
-- Rotinas Alteradas: pkb_calcular_arq
--
-- Em 07/08/2020 - Luiz Armando / Denadai - 2.9.4-2/ 295
-- Redmine #70069 - pkb_desprocessa_dados_arq, pkb_calcular_arq
-- Rotina alterada - ajustado problema de duplicidade
--
-- Em 05/06/2020 - Luiz Armando / Luis Marques - 2.9.2-6 / 2.9.3-3 / 2.9.4
-- Redmine #63728 - Ajuste no processo da FCI.
-- Rotina alterada - pkb_buscar_vlr_nf - Ajustado cursor 'c-nf' - nf de entrada interestaduais para trazer 
--                   corretamente as notas para calculo do FCI.
--
-- Em 20/05/2020 - Marcos Ferreira
-- Distribuições: 2.9.3-2 / 2.9.4
-- Redmine #67459: Erro no calculo do FCI
-- Rotina: pkb_buscar_vlr_nf, pkb_calcular_arq
-- Alterações: Correção de Bugs e melhoria do processo de geração
--
-- Em 29/02/2020 - Marcos Ferreira
-- Distribuições: 2.9.2-2 / 2.9.3
-- Redmine #65376 - Quantidade de insumo divergente.
-- Rotina: pkb_recup_vlr_entrada
-- Alterações: Correção do Cursor c_itens
--
--
-- Em 09/01/2020   - Luiz Armando Azoni
-- Redmine #63470  - Ajustada a pkb_bucar_vlr_nf adicionando no cursor C_NF um union buscando as notas fiscais referenciadas desde que sejam notas complementares
--                   corrigido no primeiro select adicionando nf.dm_fin_nfe = 1
--				     Esta altearção foi necessária pois o calculo da média ponderada estava ficando incorreto quando o sistema encontrava uma nota fiscal complementar.
--				     criação do index NOTA_FISCAL_REFEREN_IDX_3 na tabela nota_fiscal_referen
--					 Solução: Sempre que for encontrada uma nota fiscal complementar, o sistema irá encontrar a sua referencia(se estiver dentro do período de 2 meses), senão recuperará a primeira nf com o mesmo item da nf complementar e utilizará as duas para calcular a média.
-- Rotina alterada - pkb_bucar_vlr_nf					
--
-- Em 03/01/2020   - Luiz Armando Azoni
-- Redmine #63063  - No processo de calculo, não estava liberando o envio pois o total de registros do período não batia com o total dos registros com a situação 5 da tabelainf_item_fci
--                   na fase=6 foi adicionada a condição and dm_situacao <> 8, permitindo a continuidade do processo.
--
-- Rotina Alterada - pkb_calcular_arq
--
-- Em 13/12/2019   - Karina de Paula
-- Redmine #62604  - feed - faltou alterar a situação para erro de validação
-- Rotina Alterada - pkb_verif_nro_fci_ant => Incluída a verificação se o dm_situacao é "Calculado" para alterar para Aguardando Envio
--                   pkb_calcular_arq      => Incluída a verificação do dm_situacao dos registros para atualizar a situacao da abertura
--
-- Em 13/12/2019   - Karina de Paula
-- Redmine #62162  - Erro no calculo do FCI.
-- Rotina Alterada - pkb_calcular_arq => Incluída a geração de log de informação quando o valor vl_saida for zerado ou nulo
--
-- Em 29/10/2019 - Marcos Ferreira
-- Redmine #60325 - Erros na geração da FCI.
-- Alterações 01: Adicionado condição and mc.qtde_item > 0 na query para trazer somente o id da memoria de calculo com quantidades
-- Procedures Alteradas: pkb_gerar_calc_anter
-- Alterações 02: Adicionado variável vn_sum_med_ponderada para acumular o valor da média podenderada para ser usada na somatoria do valor de entrada ou saída caso seja nulo.
-- Procedures Alteradas: pkb_calcular_arq
--
-- Em 23/01/2019 - Angela Inês.
-- Redmine #48915 - ICMS FCP e ICMS FCP ST.
-- Atribuir os campos referente aos valores de FCP que são retornados na função de valores do Item da Nota Fiscal (pkb_vlr_fiscal_item_nf).
--
-- Em 18/01/2019 - Angela Inês.
-- Redmine #50473 - Valor do Item bruto para nota fiscal de importação.
-- Ao recuperar os valores das Entradas e das Devoluções:
-- 1) Utilizar o valor do Item Bruto se o CFOP for de início 3-Importação (item_nota_fiscal.vl_item_bruto).
-- 2) Depois de calculado o item, identificar se a origem do Item Insumo é 6-Estrangeira - Importação direta, sem similar nacional, constante em lista da CAMEX ou
-- 7-Estrangeira - Adquirida no mercado interno, sem similar nacional, constante em lista da CAMEX, e identificar se a Alíquota do Imposto II-Importação do Item 
-- da Nota é 0% ou 2%, e neste caso, zerar o valor do item para não ser considerado no cálculo.
-- 3) Considerar o último mês de NF de entrada ou de saída, quando o tipo de data for 0-Recupera o último mês. Para que não sejam recuperadas todas as NF que
-- estejam no banco independente do mês.
-- Rotina: pkb_buscar_vlr_nf.
-- 1) Ao atualizar a quantidade de Item na memória de cálculo, considerar a Quantidade do item componente/insumo utilizada como insumo (item_insumo.qtd_comp).
-- Rotina: pkb_recup_vlr_entrada.
--
-- Em 08/01/2018 - Angela Inês.
-- Redmine #50294 - É necessário adicionar a origem 3 e 8 do insumo na geração dos dados FCI.
-- No procedimento que buscar os itens de NF de saida e verifica se existe na tabela de INF_ITEM_FCI, considerar também, os itens de insumos com Origem 3 e 8.
-- Rotina: pkb_verif_itens_nfs.
--
-- Em 28/12/2018 - Angela Inês.
-- Redmine #50054 - Adicionar os códigos 3 e 8 da origem da mercadoria nos calculos da FCI.
-- 1) Ao recuperar os itens/produto e seus insumos para recupear os valores das notas fiscais de entrada, consideramos os itens vinculados aos itens de insumo, com
-- origem de mercadoria "1-Estrangeira - Importação direta, exceto a indicada no código 6", "2-Estrangeira - Adquirida no mercado interno, exceto a indicada no
-- código 7", "6-Estrangeira - Importação direta, sem similar nacional, constante em lista da CAMEX", e "7-Estrangeira - Adquirida no mercado interno, sem similar
-- nacional, constante em lista da CAMEX".
-- Passar a recuperar também as origens "3-Nacional, mercadoria ou bem com Conteúdo de Importação superior a 40%", e "8-Nacional, mercadoria ou bem com Conteúdo de
-- Importação superior a 70%".
-- 2) Ao recuperar os valores das notas fiscais de entrada e das notas fiscais de entrada de devolução, identificar se a origem de mercadoria do item/produto
-- insumo é "3-Nacional, mercadoria ou bem com Conteúdo de Importação superior a 40%", e neste caso, considerar 50% do valor da operação.
-- Rotinas: pkb_recup_vlr_entrada e pkb_buscar_vlr_nf.
-- Redmine #50099 - Alteração no processo de cálculo do FCI.
-- 1) Ao recuperar os valores da memória de cálculo para montagem da média ponderada, o processo não estava considerando que os valores poderiam estar nulos, e o
-- cálculo não é efetuado com valor nulo.
-- Tecnicamente/incorreto: sum(mcfci_itemnf.vl_item_tot)
-- Tecnicamente/correto: nvl(sum(nvl(mcfci_itemnf.vl_item_tot,0)),0)
-- Rotinas: pkb_recup_vlr_saida e pkb_recup_vlr_entrada.
-- 2) Ao desprocessar a abertura FCI, não estava sendo considerado corretamente o desprocessamento de uma abertura com situação 5-Aguardando envio, com informação
-- de item de FCI e com retorno de FCI. O desprocessamento foi alterado para excluir retorno de FCI se a situação da informação de item de FCI estiver com situação
-- 8-Finalizado.
-- Tecnicamente: abertura_fci_arq.dm_situacao=5-Aguardando envio, e abertura_fci_arq.nro_prot=null, excluir retorno_fci se inf_item_fci.dm_situacao=8; alterar
-- inf_item_fci.dm_situacao e abertura_fci_arq.dm_situacao para 3-Calculado; e, excluir estr_arq_fci.
-- Rotina: pkb_desprocessa_dados_arq.
--
-- Em 27/12/2018 - Angela Inês.
-- Redmine #50049 - Conversão de valor devido a Unidade de Medida.
-- Ao recuperar os valores das notas fiscais, verificar se a Unidade de Medida informada no Item da Nota Fiscal é a mesma vinculada ao Cadastro do Item/Produto,
-- vinculado ao Item da Nota Fiscal.
-- Se as unidades foram as mesmas, o valor da nota se mantem da mesma forma que está no Item da Nota Fiscal.
-- Se as unidades forem diferentes, converter através do Fator de Conversão cadastrado no Item/Produto vinculado ao Item da Nota Fiscal, e vinculado a Unidade de
-- Medida vinculada ao Item da Nota Fiscal.
-- Rotina: pkb_buscar_vlr_nf.
--
-- Em 12/12/2018  - Eduardo Linden
-- Redmine #49622 - Alteração no cursor c_dados do processo pk_csf_gera_dados_fci.pkb_verif_itens_nfs
-- O cursor c_dados receberá novos joins com as tabelas item_insumo e item a fim de considerar os itens 
-- com os códigos 1,2,6 e 7 para itens com insumos importados.
-- Rotina: pkb_verif_itens_nfs
--
-- Em 22/11/2018 - Leandro Savenhago.
-- Redmine #48814 - Avaliação do processo FCI
-- Rotina: pkb_gera_dados - Correção da logica de Geração dos Dados do FCI, conforme fluxo do processo do requisito técnico
-- Rotina: pkb_calcular_arq - Correção da logica de Calculo do FCI, conforme fluxo do processo do requisito técnico
--
-------------------------------------------------------------------------------------------------------
    --
    type tab_mcfci_itemnf is record ( mcfciitemnf_id     number
                                    , memcalcfci_id      number
                                    , itemnotafiscal_id  number
                                    , vl_item_tot        number(22,10)
                                    );
    type t_tab_mcfci_itemnf is table of tab_mcfci_itemnf index by binary_integer;
    gt_tab_mcfci_itemnf      t_tab_mcfci_itemnf;

    gn_infitemfci_id               inf_item_fci.id%type;

-------------------------------------------------------------------------------------------------------
-- Procedimento de gerar os dados da Ficha de Conteudo de Importação
procedure pkb_gera_dados ( en_aberturafci_id in abertura_fci.id%type );

-------------------------------------------------------------------------------------------------------
-- Procedimento de Calculo do Numero do Ficha Conteudo de Importação.
procedure pkb_calcular_arq ( en_aberturafciarq_id in abertura_fci_arq.id%type );

-------------------------------------------------------------------------------------------------------
-- Procedimento de Calculo do Numero do Ficha Conteudo de Importação.
procedure pkb_calcular ( en_aberturafci_id in abertura_fci.id%type );

-------------------------------------------------------------------------------------------------------
-- Procedimento que desfaz situação do registro do FCI
procedure pkb_desprocessa_dados_arq ( en_aberturafciarq_id in abertura_fci_arq.id%type );

-------------------------------------------------------------------------------------------------------
-- Procedimento que desfaz situação do registro do FCI
procedure pkb_desprocessa_dados ( en_aberturafci_id in abertura_fci.id%type );

-------------------------------------------------------------------------------------------------------

end pk_csf_gera_dados_fci;
/
