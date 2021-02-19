create or replace package csf_own.pk_calc_apur_lr is

-------------------------------------------------------------------------------------------------------
-- Especificação do pacote de Geração do Cálculo da Apuracao do Lucro Real do Sped ECF
-------------------------------------------------------------------------------------------------------
--
-- Em 11/02/2021   - Luis Marques - 2.9.6-2 / 2.9.7
-- Redmine #75361  - Desenvolver estrutura para calculo do lucro da exploração
-- Rotina Alterada - pkb_gerar_vlr_dle - Verificar se existe calculo do lucro de exploração e gravar os valores no registro
--                   N600. 
--
-- Em 28/08/2020 - Renan Alves
-- Redmine #70347 - N630 zerando o valor quando é negativo (prejuízo)
-- Foi comentado o if que verifica se a variável vn_valor encontra-se com valor negativo, pois,
-- deverá mostrar o valor negativo na apuração, ao invés do valor zerado para situações de números negativos
-- Rotina: pkb_soma_vlr_bccsllcp,
--         pkb_somar_vlr_birlrcp
-- Patch_2.9.4.3 / Patch_2.9.3.6 / Release_2.9.5
--
-- Em 14/08/2020  - Igor Cardoso
-- Redmine #69540 - Cálculo do registro N para registros trimestrais
-- Rotina Alterada- pkb_monta_dem_lucro_expl/ pkb_monta_calc_irpj_base_lr / pkb_monta_inf_bc_inc_fiscal/ pkb_monta_calc_csll_base_lr
--                -  foram alterados as validacoes da variavel per_calc_apur_lr.dm_per_apur in ('T1','T2','T3','T4') 
--                -  para ('T01','T02','T03','T04') .
--
-- Em 13/08/2020 - Luiz Armando Azoni
-- Redmine  #70457 - processo não sai do Status Calculando
-- Liberado para a Release 2.9.5 e os patchs 2.9.4-2
--
-- Em 10/08/2020 - Luiz Armando Azoni
-- Redmine  #70321 - Erro na Geração dos Registros K030 / L030 / M030 / N030
-- Liberado para a Release 2.9.5 e os patchs 2.9.4-2
--
-- Em 29/04/2017 - Leandro Savenhago
-- Redmine #25496 - Leiaute 3 da Escrituração Contábil Fiscal (ECF)
--
--
gt_log_generico dbms_sql.number_table;

-------------------------------------------------------------------------------------------------------
-- Procedimento de Desfazer Calculo da Apuracao do Lucro Real
procedure pkb_desfazer(en_percalcapurlr_id in per_calc_apur_lr.id%type);

-------------------------------------------------------------------------------------------------------
-- Procedimento de atualizar os valores de Cálculo da CSLL Com Base no Lucro Real
procedure pkb_atual_vlr_ccsllblr(en_percalcapurlr_id in per_calc_apur_lr.id%type);

-------------------------------------------------------------------------------------------------------
-- Procedimento de atualizar os valores de Cálculo da CSLL Mensal por Estimativa
procedure pkb_atual_vlr_ccsllme(en_percalcapurlr_id in per_calc_apur_lr.id%type);

-------------------------------------------------------------------------------------------------------
-- Procedimento de atualizar os valores de Base de Cálculo da CSLL Após as Compensações da Base de Cálculo Negativa
procedure pkb_atual_vlr_bccsllcp(en_percalcapurlr_id  in per_calc_apur_lr.id%type);

-------------------------------------------------------------------------------------------------------
-- Procedimento de atualizar os valores de Cálculo do IRPJ Com Base no Lucro Real
procedure pkb_atual_vlr_cirpjblr(en_percalcapurlr_id in per_calc_apur_lr.id%type);

-------------------------------------------------------------------------------------------------------
-- Procedimento de atualizar os valores de Cálculo do IRPJ Mensal por Estimativa
procedure pkb_atual_vlr_cirpjme(en_percalcapurlr_id in per_calc_apur_lr.id%type);

-------------------------------------------------------------------------------------------------------
-- Procedimento de atualizar os valores de Cálculo da Isenção e Redução do Imposto Sobre o Lucro Real
procedure pkb_atual_vlr_cirilr(en_percalcapurlr_id in per_calc_apur_lr.id%type);

-------------------------------------------------------------------------------------------------------

-- Procedimento de atualizar os valores de Demonstração do Lucro da Exploração
procedure pkb_atual_vlr_dle(en_percalcapurlr_id in per_calc_apur_lr.id%type);

-------------------------------------------------------------------------------------------------------
-- Procedimento de atualizar os valores de Base de Cálculo do IRPJ Sobre o Lucro Real Após as Compensações de Prejuízos
procedure pkb_atual_vlr_birlrcp(en_percalcapurlr_id in per_calc_apur_lr.id%type);

-------------------------------------------------------------------------------------------------------
-- Procedimento de processo de Calculo da Apuracao do Lucro Real
procedure pkb_processar(en_percalcapurlr_id in per_calc_apur_lr.id%type );

-------------------------------------------------------------------------------------------------------
-- Procedimento de calcular o Calculo da Apuracao do Lucro Real
procedure pkb_calcular(en_percalcapurlr_id in per_calc_apur_lr.id%type);

-------------------------------------------------------------------------------------------------------
-- Procedimento de gerar dados de Calculo da Apuracao do Lucro Real
procedure pkb_gerar_dados(en_aberturaecf_id in abertura_ecf.id%type);

-------------------------------------------------------------------------------------------------------

end pk_calc_apur_lr;
/
