create or replace package csf_own.pk_rel_apur_irpj_csll_parc is
------------------------------------------------------------------------------------------
--
--| Especificação da package de relatório de Apuração de IRPJ e CSLL parcial
--
-- Em 18/12/2020 - Eduardo Linden -  2.9.7 / 2.9.5-5 / 2.9.6.2
-- Redmine #74444 - Pontos de correção no processo de Apuração do IRPJ e CSLL 
-- Resolução do acumulo dos valores sobre o periodo de apuração, troca dos campos conforme listados na atividade
-- e inclusão de parametro para trazer o calculo parcial do mês ou não.
-- Rotina criada    : fkg_retorna_empresa_ecf
-- Rotinas alteradas: pkg_retorna_M300_ir_real, pkg_retorna_M350_ir_real, pkg_retorna_N630_cs_real, 
--                    pkg_retorna_N650_cs_real, pkg_retorna_N660_cs_real, pkg_retorna_P200_presumido, 
--                    pkg_retorna_P300_presumido, pkg_retorna_P400_presumido, pkg_retorna_P500_presumido, 
--                    pkg_retorna_periodo e pkb_geracao
--
-- Em 27/11/2020 - Marcos Ferreira
-- Distribuições: 2.9.6 / 2.9.5-2 / 2.9.4-5
-- Redmine 73369: Adicionar a parametrização da Conta Contábil que será vinculada a Guia de Pagamento
-- Rotinas Alteradas: pkg_gera_guia_pgto
--
-- Em 05/11/2020 - Marcos Ferreira
-- Distribuições: 2.9.6 / 2.9.5-2 / 2.9.4-5
-- Redmine #72646: Geração de guia a partir de apuração de IR e CSLL
-- Rotinas Alteradas: pkg_gera_guia_pgto, pkg_estorna_guia_pgto
--
-- Em 21/11/2019 - Renan Alves
-- Redmine #59076 - Soma da LInha 4.0 - IRPJ Devido
-- Foi incluído a coluna vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRPJ_DEVIDO nos CD 3 e 4, para que a coluna
-- receba o valor de cada registro, totalizando-os.     
-- Rotina: pkg_retorna_P300_presumido
--
-- Em 26/10/2018 - Eduardo Linden
-- redmine #48067 - Feed - Processo de Apuração - PRESUMIDO
-- Alteração do processo de leitura dos registros P500, os valores passam a ser obtidos da tabela CALC_CSLL_BASE_LP.
-- Rotina: pkg_retorna_P500_presumido
--
-- Em 08/10/2018 - Eduardo Linden   
-- redmine #47603 - Feed - Processo de Apuração - PRESUMIDO
-- Ajuste processos para obtenção real e presumido para considerar o campo de dm_per_apur para evitar
-- os valores sejam somados a outros periodos.
-- Rotinas: pkg_retorna_M300_ir_real,pkg_retorna_M350_ir_real,pkg_retorna_M350_ir_real,pkg_retorna_N650_cs_real,
-- pkg_retorna_N660_cs_real,pkg_retorna_P200_presumido,pkg_retorna_P300_presumido,pkg_retorna_P400_presumido,
-- pkg_retorna_P500_presumido
--
------------------------------------------------------------------------------------------
ERRO_DE_VALIDACAO         CONSTANT NUMBER := 1;
ERRO_DE_SISTEMA           CONSTANT NUMBER := 2;
INFO_APUR_IMPOSTO         CONSTANT NUMBER := 33;

gt_row_abertura_ecf       abertura_ecf%rowtype;
gv_resumo_log             log_generico.resumo%type;
gv_mensagem_log           log_generico.mensagem%type;
gv_obj_referencia         log_generico.obj_referencia%type default 'APUR_IRPJ_CSLL_PARCIAL';

type t_REL_APUR_IRPJ_CSLL_PARCIAL is table of REL_APUR_IRPJ_CSLL_PARCIAL%rowtype index by binary_integer;
vt_REL_APUR_IRPJ_CSLL_PARCIAL t_REL_APUR_IRPJ_CSLL_PARCIAL;

gc_ano_ref      APUR_IRPJ_CSLL_PARCIAL.ANO_REF%type;
gc_dm_per_apur  APUR_IRPJ_CSLL_PARCIAL.DM_PER_APUR%type;
gv_parcial      param_geral_sistema.vlr_param%type;
gv_erro         varchar2(400);

procedure pkb_geracao ( en_aberturaecf_id         in abertura_ecf.id%type ,
                        en_APURIRPJCSLLPARCIAL_id  in APUR_IRPJ_CSLL_PARCIAL.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedure para Geração da Guia de Pagamento de Imposto
procedure pkg_gera_guia_pgto (en_aberturaecf_id   in abertura_ecf.id%type,
                              en_usuario_id       in neo_usuario.id%type);

-------------------------------------------------------------------------------------------------------

-- Procedure para Estorno da Guia de Pagamento de Imposto
procedure pkg_estorna_guia_pgto (en_aberturaecf_id   in abertura_ecf.id%type);

-------------------------------------------------------------------------------------------------------
--
end pk_rel_apur_irpj_csll_parc;
/
