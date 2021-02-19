create or replace package csf_own.pk_gera_arq_ecd is

-------------------------------------------------------------------------------------------------------
-- Especificação do pacote de procedimentos de criação do arquivo do sped contábil
-------------------------------------------------------------------------------------------------------
--
-- Em 17/02/2021 - Eduardo Linden
-- Redmine #76264: Arquivo Sped Contabil - Registro J900 - Bramlls
-- Alteração do cursor para geração do registro J900
-- Rotina alterada: pkb_monta_bloco_j900
-- Liberado para Release 297 e para os patch's 2.9.6.2 e 2.9.5.5.
--
-- Em 16/02/2021 - Eduardo Linden
-- Redmine #76131 - Arquivo Sped Contabil - Registro I030 - Bramlls
-- Alteração do cursor para geração do registro I030
-- Rotina alterada: pkb_monta_bloco_i030
-- Liberado para Release 297 e para os patch's 2.9.6.2 e 2.9.5.5.
--
-- Em 25/05/2020 - Renan Alves
-- Redmine #67861 - [Registro I030] Preenchimento da natureza do livro
-- Foi alterado o select do cursor C_TERMO_ABERT na procedure pkb_monta_bloco_i030 e
-- o select do cursor C_ENCERRA do cursor pkb_monta_bloco_j900.
-- Rotina: pkb_monta_bloco_i030 e pkb_monta_bloco_j900
-- Patch_2.9.3.2 / Release_2.9.4 
--
-- Em 14/05/2020 - Eduardo Linden
-- Redmine #67646 - Correção do Código Entidade
-- Alteração para tratar o retorno da tabela  cod_ent_ref no registro 0000.
-- Rotina alterada: pkb_monta_bloco_0
-- Liberado para Release 294 e para os patch's 292-5 e 293-2.
--
-- Em 08/05/2020 - Eduardo Linden
-- Redmine #67450 - Geração do registro J935
-- Alteração da rotina de geração do registro J935, a fim de gerar somente um registro.
-- Rotina Alterada: pkb_monta_bloco_j900 
-- Liberado para Release 294 e para os patch's 292-5 e 293-2.
--
-- Em 07/05/2020 - Eduardo Linden
-- Redmine #67360 - Erro no I200 esta dando cartesiano e gerando erro no arquivo - RELATO DE BUG [200506-1100]
-- Ajuste no cursor que gera os registros I200 e I250
-- Rotina Alterada: pkb_carrega_I200_I250
-- Liberado para Release 294 e para os patch's 292-5 e 293-2.
--
-- Em 04/05/2020 - Luis Marques - 292-5 / 293-2 / 294
-- Redmine #67034 - Bloco I200 e I250 - ECD
--         #66946 - Filtrar para incluir apenas conta ativa
-- Rotina Alterada: pkb_carrega_I200_I250 - Alterado o alter join para o plano de conta e centro de custos pois estavam
--                  em lado errado da query ocasionando erro.
--                  pkb_monta_bloco_i050 - colocado filtro na query na leitura do plano de conta (1-Normal) conforme
--                  soliciatdo.
--
-- Em 09/04/2020  - Wendel Albino
-- Redmine #66404 - Realizar melhoria de performance.
-- Correção 
-- Rotina alterada: pkb_carrega_I200_I250. Incluido a chamada de pragma autonomous_transaction, para esta procedure 
--                  ser executada em outra secao agilizando assim o processo de execucao total.
--                  Alteracao do select principal , inclusao de hint APPEND ,para melhoria de performance.
-- Rotina excluida: pkb_carrega_lctos. O select desta rotina foi inserido na pkb_carrega_I200_I250 como sub-tabela
-- Rotina excluida: type tab_reg_I200_I250 e pkb_monta_bloco_i200.
-- Rotina alterada: pkb_inicia_param para validar o dm_situacao = 12 (em execucao) e nao 2.
--
-- Em 17/03/2020 - Eduardo Linden
-- Redmine #66151 - Geração do registros I200 e I250
-- Foi feita alteração para que os registros I200 e I250 fossem gerados se o layout for a partir da versão 8.00
-- e o tipo de escrituração (gn_tipo_escr_contab) for 'G','R' e 'A'
-- Rotina alterada: pkb_carrega_I200_I250
-- Liberado para Release 294 e para os patch's 292-4 e 293-1.
--
-- Em 13/03/2020 - Eduardo Linden
-- Redmine #66045 - Alterar tipo de conta contabil (ECD)
-- trocar a clausula de conta ativas para contas normais.
-- Rotina alterada: pkb_monta_bloco_i050
-- Liberado na versão - Release_2.9.3 e Patch_2.9.2.3
--
-- Em 09/03/2020 - Eduardo Linden
-- Redmine #65774 - Incluir indicador no cursor c_balanpatr2_agl
-- Ajuste no cursor c_balanpatr2_agl, para trazer contas analiticas (aglut_contabil.dm_ind_cta = 'A').
-- Rotina alterada: pkb_monta_bloco_j005
-- Liberado na versão - Release_2.9.3 e Patch_2.9.2.3
--
-- Em 05/03/2020 - Eduardo Linden
-- Redmine #65622 - Desenvolver a geração dos registros J210 e J215 com aglutinação contabil
-- Inclusão de novos cursores para geração dos registros J210 e J215 com aglutinação contabil.
-- Rotina alterada: pkb_monta_bloco_j005
-- Liberado na versão - Release_2.9.3 e Patch_2.9.2.3
--
-- Em 26/02/2020 - Eduardo Linden
-- Redmine #65241 - Feed - ECD
-- Correção sobre a geração do registro J935, para que o campo de CNPJ possa ser gerado a partir do layout 700.
-- Rotina alterada: pkb_monta_bloco_j900
-- Foi feito ajuste no registro 0000, para que não aparecesse 0 à esquerda no codigo de entidade referencial
-- Rotina alterada: pkb_monta_bloco_0
--
-- Em 21/02/2020 - Eduardo Linden
-- Redmine #65183 - Feed - ECD
-- Correção sobre a geração do registro 0000, sobre os campos ind_centr e codentref_id
-- Rotina alterada: pkb_monta_bloco_0
-- Correção sobre a geração do registro I051, para não gerar o campo de entidade referencial
-- Rotina alterada: pkb_monta_bloco_i050
-- Correção sobre a geração do registro J935, para que o campo de CNPJ possa ser gerado a partir do layout 700.
-- Rotina alterada: pkb_monta_bloco_j900
-- Liberado na versão - Release_2.9.3 e Patch_2.9.2.2
--
-- Em 18/02/2020 - Eduardo Linden
-- Redmine #64337 - Alteração de estrutura
-- Inclusão dos campos dm_ind_centralizada,dm_ind_mudanca_pc e codentref_id no registro 0000 a partir da versão 800.
-- Rotina alterada: pkb_monta_bloco_0
-- O campo de código da entidade referencial foi removido da geração do registro I051 a partir da versão 800.
-- Rotina alterada: pkb_monta_bloco_i050
-- Alterar cursor c_demoncontab para incluir sequencia para o registro J150 e 
-- inclusão dos novos campos no registro J150 a partir da versão 800.
-- Rotina alterada: pkb_monta_bloco_j005
-- Liberado na versão - Release_2.9.3 e Patch_2.9.2.2
--
-- Em 23/12/2019 - Luiz Armando Azoni
-- Redmine #56495 - Ajuste de performance na geração da ECD
--
-- utilização da global temporary table TMP_I200_I250 no processo de inclusão dos registros I200 e I250
-- na tabela ESTR_ARQ_ECD com intuito de melhorar perfomance com incusão de insert forall.
-- Rotina alterada: pkb_carrega_I200_I250
--
-- Em 06/08/2019 - Allan Magrini
-- Redmine #57057 - Erro na montagem do registro I200 e I250
-- Adicionado estrarqecd_seq.nextval no INSERT INTO ESTR_ARQ_ECD 
-- Rotina alterada: pkb_carrega_I200_I250
--
-- Em 02/08/2019 - Allan Magrini
-- Redmine #56921 - Quebra de linhas na partida do lançamento
-- Adicionado trim(pk_csf.fkg_converte(compl_hist)) na hora de carregar dados do período em type para agilizar o processo de consolidação do saldo
-- Rotina alterada: pkb_carrega_I200_I250
--
-- Em 22/07/2019 - Luiz armando Azoni
-- Redmine # - Agilizar o processo de consolidação do saldo bloco I
-- Processo que carrega os lançamentos contábeis em um type para agilizar o processamento
-- Rotina criada: pkb_carrega_lctos, pkb_carrega_I200_I250
--
-- Em 11/07/2019 - Eduardo Linden
-- Redmine #56232 - Não gera o registro I075
-- Retirada do comentario para chamado a rotina pkb_monta_bloco_i075
-- Rotina alterada: pkb_monta_bloco_i
--
-- Em 29/06/2019 - Luiz armando Azoni
-- Redmine #55799 - Erro ao Gerar o J150
-- Adicionado condiçaõ para gerar o J150 com códigos de aglutinação.
-- Rotina alterada: pkb_monta_bloco_j005 
--
-- Em 07/06/2019 - Eduardo Linden
-- Redmine #55242 - Correção na geração da ECD - registro J150
-- Troca para function pk_csf_ecd.fkg_planoconta_id_sup para encontrar id do plano de conta superior
-- Rotina alterada: pkb_monta_bloco_j005 
--
--------------------------------------------------------------------------------------------------------
-- Em 17/03/2015 - Rogério Silva. 
-- Redmine #6903 - Desenvolvimento de novos campos na geração do arquivo e correções/melhorias - SPED Contábil
--
-- Em 14/04/2015 - Rogério Silva.
-- Redmine #7205 - Alteração Leiaute ECD, versão 1.0 para versão 2.0 e versão 3.0.
--
-- Em 18/05/2015 - Rogério Silva.
-- Redmine #8454 - Erro validação de arquivo
-- Redmine #8419 - Erro na geração do arquivo sped contabil
-- Redmine #8424 - Erro dado no PVA                                            
--
-- Em 27/05/2015 - Rogério Silva.
-- Redmine #8694 - Plano de contas referencial (ACECO)
--
-- Em 08/06/2015 - Rogério Silva.
-- Redmine #8238 - Processo de Registro de Log em Packages - Dados Contábil
--
-- Em 02/06/2016 - Rogério Silva.
-- Redmine #10827 - REGISTRO J200 - INFORMAÇÕES INCORRETAS
--
-- Em 21/02/2015 - Leandro Savenhago
-- Redmine #22470 - Lições Aprendidas ECF e ECD - Movimento Contábil com centro de custo e sem centro de custo
-- Obs.: Utilização do Centro de Custo default dos parâmetros contábeis por empresa, quando não existir no registro
--
-- Em 06/04/2017 - Fábio Tavares
-- Redmine #27483 - Melhorias referentes ao plano de contas referencial
-- Relacionado ao Periodo de Referencia de um plano de conta e centro de custo da empresa para o plano de conta do ECD.
--
-- Em 09/05/2017 - Angela Inês.
-- Redmine #30880 - Alterar o processo de recuperar dados do participante - Registro 0150 - País.
-- Ao recuperar os dados do País, considerar as informações que estão na tabela do Participante/Pessoa (pessoa.pais_id/pais.cod_siscomex).
-- Rotina: pkb_monta_bloco_0150.
--
-- Em 20/05/2017 - Leandro Savenhago
-- Redmine #31240 - Sped Contábil geração do registros 0150 para participantes que são do Exterior
-- Rotina: pkb_monta_bloco_0150.
--
-- Em 13/06/2017 - Melina Carniel
-- Redmine #31977 - Alteração do campo nome de varchar2(60) para varchar2(70)
-- OBS: Registro 0000 (tab_reg_0000).
--
-- Em 08/05/2018 - Marcos Ferreira
-- Redmine: #42586 - Processo de geração do Sped ECD.
-- Alterado Procedure pkb_monta_bloco_j005 
--   * Incluído as notas explicativas relativas as demonstrações contábeis nos blocos J100, J150, J210
--    
-- Em 02/07/2018 - Marcos Ferreira
-- Redmine: #44537 - Montagem de plano de contas incorreta
-- Problema: Lentidão no processo de geração do bloco I050
-- Solução: Correção  no cursor c_planoconta, estava sem join com o exists
-- Rotina: pkb_monta_bloco_i050
--    
-- Em 04/07/2018 - Marcos Ferreira
-- Redmine: #44682 - Não montou contas sintéticas
-- Problema: Identificado que o cursor c_planoconta está montado errado e não pega as contas sintéticas
-- Solução: Correção  no cursor c_planoconta, setado o correto posicionamento do prior no connect by
--          e incluído o Start With com a query da tabela de períodos int_det_saldo_periodo
-- Rotina: pkb_monta_bloco_i050
--    
-- Em 30/08/2018 - Marcos Ferreira
-- Redmine: #46474 - Alterar forma de montagem do registro I050
-- Melhoria: Incluir coluna dm_situacao na tabela Plano_Conta, onde 0 = Inativa / 1 = Ativa.
--           Alterar os Cursores da Plano_Conta para a geração do Bloco I050 para buscar somente as contas ativas
-- Rotina: pkb_monta_bloco_i050
--
-- Em 10/10/2018 - Angela Inês.
-- Redmine #47481 - Sped Contábil - Geração do registro 0000 para o campo nome da Razão Social.
-- Favor realizar alteração na package 54b_pk_gera_arq_ecd para que a função converte seja chamada para limpa o campo nome da mesma forma que é realizada na
-- exportação do registro I030.
-- Rotina: pkb_monta_bloco_0.
--
-- Em 13/11/2018 - Eduardo Linden
-- Redmine #47958 - Sped Contábil - Geração do registro J900 para o campo nome da Razão Social
-- Inclusão da function pk_csf.fkg_converte para o campo Razão Social para o registro J900 (Termo de encerramento)
-- Rotina: pkb_monta_bloco_j900
--
-- Em 01/03/2019 - Eduardo Linden
-- Redmine #51697 - Atualizar geração da ECD conforme especificação
-- registro J932: Inclusão de novo cursor para o novo registro J932 e inclusão de novo campo para os cursores c_signatario e c_signatario_subst (novo).
-- Rotina:  pkb_inicia_dados , pkb_monta_bloco_j900 e pkb_monta_bloco_j990
-- registro J801: alteração no cursor c_termosubecd e inclusão de dois novos campos cod_mot_subs e ind_aut_cfc.
-- Rotina:  pkb_monta_bloco_j005
-- registro J215: Criação de novo cursor c_fato_descr e alteração de código para preencher o novo campo 'Descrição do Fato Contábil' 
-- Rotina:  pkb_monta_bloco_j005
-- registro J935 : Inclusão dos campos NI_CPF_CNPJ nas tabelas TERMO_ABERT_LIVRO e IDENT_AUD_IND .
-- Rotina: pkb_monta_bloco_j900
-- registro J100: Inclusão dos seguintes campos :Indicador do Tipo de Código de Aglutinação (IND_COD_AGL), Código de Aglutinação de Nível Superior (COD_AGL_SUP) 
-- e Indicador de Grupo do Balanço (IND_GRP_BAL). Redefinição dos campos VL_CTA_INI,  IND_DC_CTA_INI , VL_CTA_FIN e IND_DC_CTA_FIN a partir do layout 7.
-- Rotina : pkb_monta_bloco_j005
-- registro J150: Inclusão dos seguintes campos: Indicador do Tipo de Código de Aglutinação(IND_COD_AGL), Código de Aglutinação de Nível Superior (COD_AGL_SUP), 
-- Indicador da Situação do Saldo Informado no Campo Anterior (IND_DC_CTA) e  Indicador de Grupo da DRE (IND_GRP_DRE)
-- Rotina: pkb_monta_bloco_j005
-- registro I200: inclusão do campo Data do Lançamento Extemporâneo (DT_LCTO_EXT)
-- Rotina: pkb_monta_bloco_i200
-- registro J210: Alteração no preenchimento dos campos :Saldo Inicial do Código de Aglutinação (VL_CTA_INI), Indicador da Situação do Saldo Inicial (IND_DC_CTA_INI),
-- Saldo Final do Código de Aglutinação (VL_CTA_FIN) e Indicador da Situação do Saldo Final (IND_DC_CTA_FIN)
-- rotina: pkb_monta_bloco_j005
--
-- Em 08/04/2019 - Eduardo Linden
-- Redmine #53194 - Geração J200
-- Exclusão do registro J200 na geração do arquivo SPED no Layout 7.00.
-- Rotina alterada: pkb_monta_bloco_j005
--
-- Em 24/04/2019 - Eduardo Linden
-- Redmine #53857: Ajuste no campo IND_GRP_DRE do registro J150
-- Mudança para dedução do campo 9 IND_GRP_DRE. Será utilizado o campo dm_ind_vl da tabela dem_result_exer.
-- Rotina Alterada: pkb_monta_bloco_j005
--
-- Em 25/04/2019 - Luiz Armando Azoni
-- Redmine #53731: Ajuste na geração do registro J932
-- Adicionada a condição vt_tab_reg_0000(1).ind_fin_esc <> '0' para gerar o registro J932
-- Rotina Alterada: pk_gera_arq_ecd.pkb_monta_bloco_j900
--
-- Em 26/04/2019 - Luiz Armando Azoni
-- Redmine #53731: Ajuste na geração do registro J932
-- Adicionando as linhas 
-- vn_fase := 72.1;
-- pkb_ins_array ( ev_reg_blc      => 'J932'
--               , en_qtd_reg_blc  => gn_qtde_reg_j932 );
-- Rotina Alterada: pk_gera_arq_ecd.pkb_monta_bloco_9900

-- Em 26/04/2019 - Luiz Armando Azoni
-- Redmine #53986: Retirada o if que valida se o contador era do tipo 900
-- Rotina Alterada: pk_gera_arq_ecd.pkb_monta_bloco_j900
--
-- Em 29/04/2019 - Eduardo Linden
-- Redmine #54011 - Correção na geração J215 - ECD
-- Correção no cursor c_fato_descr, incluindo tabela plano_conta, para evitar repetição no campo desc_fat.
-- Rotina Alterada: pkb_monta_bloco_j005
-- 
-- Em 02/05/2019 - Eduardo Linden
-- Redmine #54047 - Ajuste no registro I052 - ECD
-- Inclusão da rotina para obter cod de aglutinação através das tabelas PC_AGLUT_CONTABIL e AGLUT_CONTABIL
-- Rotina Alterada: pkb_monta_bloco_i050
-- 
-- Em 09/05/2019 - Eduardo Linden
-- redmine #54289 - Não gerar registros J100 e J150 para plano de conta inativa - SPED Contabil 
-- Alteração na rotina para a geração dos registros J100 e J150 caso o plano de conta superior for inativo
-- Rotina alterada: pkb_monta_bloco_j005
--
-- Em 09/05/2019 - Eduardo Linden
-- Redmine #54319 - feed - ainda está saindo conta inativa no J100
-- Correção sobre o plano de conta a ser considerado para não gerar os registros J100 e J150.
-- Rotina alterada: pkb_monta_bloco_j005
--
-- Em 13/05/2019 - Eduardo Linden
-- Redmine #54353: Ajuste no cursor do registro J215 - ECD 
-- Correção no cursor do registro J215 para ser gerado tanto contas analiticas quanto contas sintéticas.
-- Rotina alterada: pkb_monta_bloco_j005
--
-- Em 15/05/2019 - Eduardo Linden
-- Redmine#54473: Correção da geração do J150 - ECD
-- Correção relacionado a variavel vn_planoconta_id_sup
-- Rotina alterada: pkb_monta_bloco_j005
--
-- Em 28/05/2019 - Eduardo Linden
-- Redmine #54874 - Correção na geração dos registros J100 e J150 - ECD
-- Inclusão dos parametros DM_GERAR_BP_AGLT_CONTABIL e DM_GERAR_DRE_AGLT_CONTABIL (tab abertura_ecd), para 
-- ser levada em conta o status ativo/inativo para plano de conta para gerar os registros J100 e J150.
-- Rotina alterada: pkb_monta_bloco_j005
---
-----------------------------------------------------------------------------------------------------------

  --
  -- ARMAZEZA OS DADO DA INT_PARTIDA_LCTO
  GA_INT_LCTO_CONTABIL TB_INT_LCTO_CONTABIL := TB_INT_LCTO_CONTABIL();
  --| Registro 0000: Abertura do arquivo digital
  -- Nível - 0
  -- Ocorrência: 1-1
  type tab_reg_0000 is record(
    reg             varchar2(4),
    lecd            varchar2(4),
    dt_ini          date,
    dt_fin          date,
    nome            varchar2(70),
    cnpj            varchar2(14),
    uf              varchar2(2),
    ie              varchar2(14),
    cod_mun         number(7),
    im              varchar2(15),
    ind_sit_esp     number(1),
    ind_sit_ini_per number(1),
    ind_emp_grd_prt number(1),
    ind_nire        number(1),
    ind_fin_esc     number(1),
    cod_hash_sub    varchar2(40),
    nire_subst      varchar2(11),
    tip_ecd         number(1),
    cod_scp         varchar2(14),
    ident_mf        varchar2(1),
    ind_esc_cons    varchar2(1),
    ind_centr       varchar2(1),
    ind_mud_pc      varchar2(1));
    vb_gera_reg     boolean;
  --
  type t_tab_reg_0000 is table of tab_reg_0000 index by binary_integer;
  vt_tab_reg_0000 t_tab_reg_0000;
  -------------------------------------------------------------------------------------------------------
  --
  type tab_reg_I200_I250 is record
 (id             NUMBER,
  aberturaecd_id NUMBER,
  registroecd_id NUMBER,
  sequencia      NUMBER,  
  conteudo       LONG );
  --
  type t_tab_reg_I200_I250 is table of tab_reg_I200_I250 index by binary_integer;
  vt_tab_reg_I200_I250 t_tab_reg_I200_I250;
  -------------------------------------------------------------------------------------------------------

  type t_estr_arq_ecd is table of estr_arq_ecd%rowtype index by binary_integer;
  vt_estr_arq_ecd t_estr_arq_ecd;

  -------------------------------------------------------------------------------------------------------

  --| Variáveis globais utilizadas na geração do arquivo

  gn_aberturaecd_id     abertura_ecd.id%type;
  gt_row_abertura_ecd   abertura_ecd%rowtype;
  gn_empresa_id         empresa.id%type;
  gn_dm_ind_dec_contab  empresa.dm_ind_dec_contab%type;
  gn_tipo_escr_contab   tipo_escr_contab.sigla%type;
  gl_conteudo           estr_arq_ecd.conteudo%type;
  gn_seq_arq            number;
  gv_versaolayoutecd_cd versao_layout_ecd.cd%type := null;
  gd_dt_ini             date;
  gd_dt_fin             date;
  gt_param_contabil     param_contabil%rowtype;
  gv_cod_ccus           centro_custo.cod_ccus%type;
  ed_dt_ini             abertura_ecd.dt_ini%type;
  ed_dt_fin             abertura_ecd.dt_fim%type;
  en_empresa_id         abertura_ecd.empresa_id%type;

  -------------------------------------------------------------------------------------------------------

  -- COntadores de registros do arquivo
  gn_qtde_reg_0000 number := 0;
  gn_qtde_reg_0001 number := 0;
  gn_qtde_reg_0007 number := 0;
  gn_qtde_reg_0020 number := 0;
  gn_qtde_reg_0035 number := 0;
  gn_qtde_reg_0150 number := 0;
  gn_qtde_reg_0180 number := 0;
  gn_qtde_reg_0990 number := 0;

  gn_qtde_reg_i001 number := 0;
  gn_qtde_reg_i010 number := 0;
  gn_qtde_reg_i012 number := 0;
  gn_qtde_reg_i015 number := 0;
  gn_qtde_reg_i020 number := 0;
  gn_qtde_reg_i030 number := 0;
  gn_qtde_reg_i050 number := 0;
  gn_qtde_reg_i051 number := 0;
  gn_qtde_reg_i052 number := 0;
  gn_qtde_reg_i053 number := 0;
  gn_qtde_reg_i075 number := 0;
  gn_qtde_reg_i100 number := 0;
  gn_qtde_reg_i150 number := 0;
  gn_qtde_reg_i155 number := 0;
  gn_qtde_reg_i157 number := 0;
  gn_qtde_reg_i200 number := 0;
  gn_qtde_reg_i250 number := 0;
  gn_qtde_reg_i300 number := 0;
  gn_qtde_reg_i310 number := 0;
  gn_qtde_reg_i350 number := 0;
  gn_qtde_reg_i355 number := 0;
  gn_qtde_reg_i500 number := 0;
  gn_qtde_reg_i510 number := 0;
  gn_qtde_reg_i550 number := 0;
  gn_qtde_reg_i555 number := 0;
  gn_qtde_reg_i990 number := 0;

  gn_qtde_reg_j001 number := 0;
  gn_qtde_reg_j005 number := 0;
  gn_qtde_reg_j100 number := 0;
  gn_qtde_reg_j150 number := 0;
  gn_qtde_reg_j200 number := 0;
  gn_qtde_reg_j210 number := 0;
  gn_qtde_reg_j215 number := 0;
  gn_qtde_reg_j800 number := 0;
  gn_qtde_reg_j801 number := 0;
  gn_qtde_reg_j900 number := 0;
  gn_qtde_reg_j930 number := 0;
  gn_qtde_reg_j932 number := 0;
  gn_qtde_reg_j935 number := 0;
  gn_qtde_reg_j990 number := 0;

  gn_qtde_reg_9001 number := 0;
  gn_qtde_reg_9900 number := 0;
  gn_qtde_reg_9990 number := 0;
  gn_qtde_reg_9999 number := 0;

  -------------------------------------------------------------------------------------------------------
  /*
  Todos os registros devem conter no final de cada linha do arquivo digital, após o caractere delimitador
  Pipe acima mencionado, os caracteres "CR" (Carriage Return) e "LF" (Line Feed) correspondentes a
  "retorno do carro" e "salto de linha" (CR e LF: caracteres 13 e 10, respectivamente, da Tabela ASCII).
  */

  CR             CONSTANT VARCHAR2(4000) := CHR(13);
  LF             CONSTANT VARCHAR2(4000) := CHR(10);
  FINAL_DE_LINHA CONSTANT VARCHAR2(4000) := CR || LF;
  --FINAL_DE_LINHA CONSTANT VARCHAR2(4000) := null;

  -------------------------------------------------------------------------------------------------------

  -- Procedimento inicia montagem da estrutura do arquivo texto do SPED Contábil

  procedure pkb_gera_arquivo_ecd(en_aberturaecd_id in abertura_ecd.id%type);

  -------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- Processo que carrega os lançamentos contábeis em um type para agilizar o processamento
  -----------------------------------------------------------------------------
  procedure pkb_carrega_lctos(en_empresa_id in empresa.id%type,
                              ed_dt_ini     in date,
                              ed_dt_fin     in date);

  procedure pkb_carrega_I200_I250;

end pk_gera_arq_ecd;
/
