create or replace package csf_own.pk_calc_dief is

-------------------------------------------------------------------------------------------------------
--| Especificação do pacote de Cálculo e Geração dos dados da DIEF-Pará 
-------------------------------------------------------------------------------------------------------
--
-- Em 20/10/2020 - Renan Alves    
-- Redmine #71898 - DIEF - PA >> Informado apenas o "Valor Contábil"
-- No for do cursor C_NF_SC foi incluído a rotina pk_csf_api.pkb_vlr_fiscal_nfsc.
-- No for do cursor C_CT foi incluído a rotina pk_csf_ct.pkb_vlr_fiscal_ct.
-- Rotina: pkb_gerar_livro_apur
-- Patch_2.9.5.2 / Patch_2.9.4.5 / Release_2.9.6
--
-- Em 19/10/2020 - Renan Alves
-- Redmine #71903 - DIEF - PA >> Campos "Outros Créditos ¿ Total" e "Total de Créditos"
-- Foi alterado o valor (vn_vl_total_debito) da coluna Por saída e/ou prestação e
-- Outros Débitos - Total, pois, o mesmo devera ser a soma das colunas Saldo Credor Transferido entre Estabelecimento do mesmo Grupo,
-- Saldos Credores Transferido para outro Estabelecimento e Outros Débitos
-- Rotina: pkb_gerar_apur_icms
-- Patch_2.9.5.1 / Patch_2.9.4.4 / Release_2.9.6
--
-- Em 19/10/2020 - Renan Alves
-- Redmine #71903 - DIEF - PA >> Campos "Outros Créditos - Total" e "Total de Créditos"
-- Foi incluido o valor total ajuste a crédito (VN_VL_TOTAL_AJUST_CRED) na soma da coluna
-- outros crédito (VL_OUTRO_CRED_TOTAL) no insert da tabela DIEF_APUR_ICMS.
-- Rotina: pkb_gerar_apur_icms
-- Patch_2.9.5.1 / Patch_2.9.4.4 / Release_2.9.6
--
-- Em 23/01/2019 - Angela Inês.
-- Redmine #48915 - ICMS FCP e ICMS FCP ST.
-- Atribuir os campos referente aos valores de FCP que são retornados na função de valores do Item da Nota Fiscal (pkb_vlr_fiscal_item_nf).
--
-- Em 28/10/2016 - Angela Inês.
-- Redmine #24798 - Erro de calculo da dief.
-- Utilizar o comando TO_CHAR ao invés do TRUNC para data de emissão dos cupons fiscais (cupom_fiscal.dt_emissao).
-- Rotina: pkb_gerar_livro_apur.
--
-- Em 29/09/2016 - Angela Inês.
-- Redmine #23897 - Atualização da montagem do arquivo DIEF-PARÁ.
-- No processo de calcular a DIEF, livro de apurações, o processo não está gravando os dados da tabela correta.
-- Rotina: pkb_gerar_livro_apur.pkb_grava_livro_apur.
--
-- Em 20/09/2016 - Angela Inês. 
-- Redmine #23594 - Correção no cálculo e validação da DIEF-Pará.
-- 1) No processo de cálculo alterar o registro da aba de Apuração do ICMS quando o mesmo já existir, passando a alterar o registro já existente com as informações
-- da Apuração do ICMS.
-- Rotina: pkb_gerar_apur_icms.
--
-------------------------------------------------------------------------------------------------------
   --
   type t_tab_dief_livro_apur is table of dief_livro_apur%rowtype index by binary_integer;
   vt_tab_dief_livro_apur t_tab_dief_livro_apur;
   --
   gn_dm_dt_escr_dfepoe   empresa.dm_dt_escr_dfepoe%type;
   --
-------------------------------------------------------------------------------------------------------
-- Procedimento de Cálculo e Geração dos dados da DIEF-Pará
procedure pkb_calcular ( en_aberturadief_id in abertura_dief.id%type );

-------------------------------------------------------------------------------------------------------

end pk_calc_dief;
/
