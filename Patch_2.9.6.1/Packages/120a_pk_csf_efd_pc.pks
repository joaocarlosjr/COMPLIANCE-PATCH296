create or replace package csf_own.pk_csf_efd_pc is

-------------------------------------------------------------------------------------------------------
-- Especificação do pacote geral de processos e funções da EFD PIS/COFINS
--
-- Em 05/01/2021   - Luis Marques - 2.9.5-4 / 2.9.6-1 / 2.9.7
-- Redmine #74674  - Geração do registro M100 - Código do Tipo de Crédito para servicos de transporte gerando como agroindustria
-- Rotina Alterada - fkg_relac_tipo_cred_pc_id - Incluido verificação de novo parametro "TIPO_CRED_GRUPO_CST_60" para o padrão de
--                   CST de 60 a 66 (106,206 ou 306) ou (107,207 ou 307) com verificação se for produtor rural e o padrão for
--                   (107,207 ou 307) considera o padrão como (106,206 ou 306).
--                   "TIPO_CRED_GRUPO_CST_60" -> 0 - Padrão (106,206 ou 306) / 1 - Padrão (107,207 ou 307)
--
-- Em 05/11/2020 - Eduardo Linden
-- Redmine #72780 - Não foi gerado o evento R2060 ao gerar os períodos REINF (feed)
-- Ajuste no select para enquandramento da regra e recuperar o id da tabela empresa_ativcprb
-- Rotina alterada: fkg_codativcprb_id_empativcprb
-- Liberado para Release 2.9.6 e os patchs 2.9.5.2 e 2.9.4.5
--
-- Em 02/09/2020 - Eduardo Linden
-- Redmine #54371 - Inclusão de Tipo de Serviço no de X para - R2060
-- Inclusão dos campos cnae_id e tpservico_id para recuperar o id da tabela empresa_ativcprb
-- Rotina alterada: fkg_codativcprb_id_empativcprb
-- Liberado para Release 2.9.5 e os patchs 2.9.4.3 e 2.9.3.6
--
-- Em 10/08/2020 - Allan Magrini
-- Redmine #68646 - Melhoria na Rotina de geração de contas EFD
-- Alterados os cursores incluindo o novo campo COD_ST_PISCOFINS da tabela PARAM_EFD_CONTR_GERAL 
-- Rotina: fkb_recup_pcta_ccto_pc.
--
--------------------------------------------------------------------------------------------------------
-- Em 29/04/2011 - Angela Inês.
-- Incluído processo para recuperar identificador da base de cálculo de crédito.
--
-- Em 03/05/2011 - Angela Inês.
-- Incluído processo de item de marca comercial.
--
-- Em 19/05/2011 - Angela Inês.
-- Incluído processo para recuperar tipo de crédito através relacionamentos.
-- Incluído processo para recuperar identificador do tipo de crédito.
--
-- Em 08/06/2011 - Angela Inês.
-- Incluído processo para recuperar código de contribuição social
--
-- Em 17/01/2012 - Angela Inês.
-- Eliminada a função para retornar a situação do período de apuração de crédito para o imposto PIS
-- Eliminada a função para retornar a situação do período de apuração de crédito para o imposto COFINS
--
-- Em 18/01/2012 - Angela Inês.
-- Incluir função para retornar quantidade de registros relacionados ao período das receitas isentas - PIS
-- Incluir função para retornar quantidade de registros relacionados ao período das receitas isentas - COFINS
--
-- Em 23/01/2012 - Angela Inês.
-- Incluir função para retornar quantidade de registros relacionados ao período das consolidações - PIS
-- Incluir função para retornar quantidade de registros relacionados ao período das consolidações - COFINS
--
-- Em 23/02/2012 - Angela Inês.
-- Acertar a recuperação do código de CFOP pela primeira posição, na rotina de recuperação de tipo de crédito.
--
-- Em 26/06/2012 - Leandro.
-- Incluída função para verificar se o CFOP gera receita para a empresa
-- O sistema busca na empresa, seja filial, ou busca na matriz
--
-- Em 04/07/2012 - Angela Inês.
-- 1) Inclusão da rotina de geração de log/alterações nos processos de Notas fiscais de serviços contínuos
--    (tabela: nota_fiscal) - pkb_inclui_log_nf_serv_cont.
--
-- Em 25/07/2012 - Angela Inês.
-- Alterar a função que verifica cfop x empresa para receita de crédito (cfop_receita_empresa), considerando a coluna dm_gera_cred_pf_pc = 1 (0-não, 1-sim).
-- Rotina: fkg_existe_cfop_rec_empr.
--
-- Em 10/09/2012 - Angela Inês.
-- 1) Alterar a função que recupera natureza de receita de pis/cofins. Inclusão de novos parâmetros de entrada - alíquotas.
--    Rotina: fkg_nat_rec_pc_id.
-- 2) Incluir nova função para confirmar o identificador da natureza de receita de pis/cofins através do próprio identificador.
--    Rotina: fkg_conf_id_nat_rec_pc.
--
-- Em 13/09/2012 - Angela Inês.
-- 1) Considerar os códigos de CFOP 1102-Compra para comercialização - dentro do estado, 2102-Compra para comercialização - fora do estado e
--    3102-Compra para comercialização - fora do país, para considerar os tipos de créditos 105, 205 e 305, além do código ncm de cada produto.
--    Rotina: fkg_relac_tipo_cred_pc_id.
--
-- Em 24/09/2012 - Angela Inês.
-- 1) Inclusão de novos parâmetros para recuperar o código da natureza de receita ( en_ncm_id e ev_cod_ncm ). Deve existir o código de NCM.
--    Rotina: fkg_nat_rec_pc_id.
--
-- Em 11/10/2012 - Angela Inês.
-- Ficha HD 63865 - Considerar o primeiro registro encontrado na recuperação da natureza de receita isenta, devido aos NCMs que aparecem em mais de uma natureza.
-- Rotina: fkg_nat_rec_pc_id.
--
-- Em 08/11/2012 - Angela Inês.
-- Ficha HD 64080 - Escrituração Doctos Fiscais e Bloco M. Nova tabela para considerações de CFOP - param_cfop_empresa.
-- Rotinas: fkg_gera_recisen_cfop_empr, fkg_gera_cred_nfpc_cfop_empr e fkg_gera_escr_efdpc_cfop_empr.
--
-- Em 23/11/2012 - Angela Inês.
-- Ficha HD 64743 - Alterar recuperação dos parâmetros de CFOP para os valores default.
-- Rotinas: fkg_gera_recisen_cfop_empr, fkg_gera_cred_nfpc_cfop_empr e fkg_gera_escr_efdpc_cfop_empr.
--
-- Em 31/01/2013 - Vanessa N. F. Ribeiro
-- Ficha HD65502 - Inclusao da função fkg_codst_id_nat_rec_pc para uso da integração do complemnto do item
--
-- Em 02/05/2013 - Angela Inês.
-- Ficha HD 66673 - Considerar o código 102-Crédito vinculado à receita tributada no mercado interno - Alíquotas Diferenciadas
-- para CST 50 quando a alíquota do imposto for 0 (zero) e a base de cálculo for por unidade de produto (qtde).
-- Rotina: fkg_relac_tipo_cred_pc_id.
--
-- Em 07/05/2013 - Marcelo Ono.
-- Corrigido o tipo da variável de return da function fkg_cod_id_nat_rec_pc.
--
-- Em 27/08/2013 - Angela Inês.
-- Redmine #598 - Islaine - EFD Contribuicoes Ficha HD 66842.
-- Alterar a função que recupera o tipo de crédito considerando a CFOP de Importação (início 3), utilizando os códigos 108, 208 e 308.
-- Rotina: fkg_relac_tipo_cred_pc_id.
--
-- Em 09/09/2013 - Angela Inês.
-- Redmine #648 - Suporte - Tadeu/Verdemar - Geração do PIS/COFINS - Abertura do arquivo.
-- Considerar o parâmetro da empresa que indica se irá utilizar recuperação do tipo de crédito com o processo Embalagem ou não.
-- Rotina: fkg_relac_tipo_cred_pc_id.
--
-- Em 04/11/2013 - Angela Inês.
-- Redmine #1156 - Implementar o parâmetro que indica geração automática de ajuste no bloco M210 nos processos do PIS/COFINS.
-- Rotina: fkg_dmgeraajusm210_parcfopempr - Inclusão da função para retornar se o CFOP gera valor como ajuste na consolidação para PIS e COFINS.
-- Rotina: fkg_id_cd_ajustcontrpc - Inclusão da função para retornar o identificador do código de ajuste de contribuição ou crédito.
--
-- Em 26/12/2013 - Angela Inês.
-- Redmine #1324 - Informação - Nova regra de validação CST 05 EFD Contribuições Versão 2.0.5.
-- 1) Função criada para encontrar a parametrização na tabela NAT_REC_PC que indica se o código de situação tributária vinculado (nat_rec_pc.codst_id),
-- irá gerar receita (blocos M400 e M800): DM_GERA_RECEITA = 0-NÃO, 1-SIM.
-- Rotina: fkg_dm_gerareceita_natrecpc.
--
-- Em 20/02/2014 - Angela Inês.
-- Redmine #1971 - Função para retornar o parâmetro de Cálculo automático do Bloco M.
-- Rotina: fkg_dmcalcblocomaut_empresa.
--
-- Em 27/03/2014 - Angela Inês.
-- Redmine #2416 - Processo de cálculo do M105 e M505.
-- Incluir a função que recupera a descrição do "Código da Base de Cálculo do Crédito" através do identificador.
-- Rotina: fkg_descr_basecalccredpc.
--
-- Em 07/04/2014 - Angela Inês.
-- Redmine #2454 - Embora a Geração do EFD Contribuições está com o status Validado ou Gerado o Portal permite que o usuário abra o Bloco M.
-- Incluir a função que verifica se existe período de abertura de efd pis/cofins com arquivo gerado, para desprocessar os registros desejados.
-- Rotina: fkb_existe_perarq_gerado.
--
-- Em 24/04/2014 - Angela Inês.
-- Redmine #2506/#2766 - Processo da Apuração da Contribuição Previdenciária Sobre a Receita Bruta.
-- Incluir a função que retorna o identificador do código de atividade incidente da contribuição previdenciária sobre a receita bruta.
-- Rotina: fkg_codativcprb_id_empativcprb.
--
-- Em 19/05/2014 - Angela Inês.
-- Redmine #2767 - Geração do arquivo da EFD Contribuições. Implementar a geração do Bloco P – Apuração da Contribuição Previdenciária sobre a Receita Bruta.
-- 1) Incluir função para retornar o código da atividade sujeita a incidência da Contribuição Previdenciária sobre a Receita Bruta.
-- 2) Incluir função para retornar o código de Detalhamento da Contribuição Previdenciária sobre a Receita Bruta.
-- 3) Incluir função para retornar o código de ajuste de contribuição ou crédito através do identificador.
-- Rotinas: fkg_cd_codativcprb, fkg_cd_coddetcprb e fkg_cd_ajustcontrpc.
--
-- Em 08/09/2014 - Angela Inês.
-- Redmine #4110 - Feedback #3901 - Melhoria #3842: Adptação do Modelo 65-NFCe para Obrigações Fiscais.
-- Função retorna o identificador do código de atividade incidente da contribuição previdenciária sobre a receita bruta, deve recuperar da empresa enviada
-- pelo parâmetro, e caso não exista, recuperar da empresa matriz.
-- Rotina: fkg_codativcprb_id_empativcprb.
--
-- Em 26/12/2014 - Angela Inês.
-- Redmine #5616 - Adequação dos objetos que utilizam dos novos conceitos de Mult-Org.
-- Inverter os parâmetros de entrada mantendo en_multorg_id como sendo o primeiro parâmetro.
--
-- Em 17/03/2015 - Angela Inês.
-- Redmine #7027 - Apuração do Bloco P - Previdência.
-- Devemos acertar a função que recupera o parâmetro que indica se a CFOP gera receita pk_csf_efd_pc.fkg_gera_recisen_cfop_empr:
-- Considerar 0-Não, caso não tenha parâmetro gerado (no_data_found: empresa do parâmetro e empresa da matriz).
--
-- Em 25/03/2015 - Angela Inês.
-- Redmine #7269 - Alteração no processo de funções específicas do EFD-Contribuições.
-- 1) Criar uma função que recupera o parâmetro PARAM_CFOP_EMPRESA.DM_GERA_INSS_DESON: CFOP gera INSS Desonerado - fkb_gerainssdeson_cfop.
-- Parâmetros de entrada: empresa_id e cfop_id.
-- 2) Criar uma função que recupera o parâmetro PARAM_EFD_CONTR.DM_VALIDA_INSS_DESON: Empresa valida ou não e se gera ou não log de inconsistência
-- para INSS Desonerado - fkb_valinssdeson_empr. Parâmetro de entrada: empresa_id.
-- 3) Criar uma função que consiste o código de atividade incidente da contribuição previdenciária sobre a receita bruta com o período de
-- validade da apuração (cod_ativ_cprb.dt_ini e cod_ativ_cprb.dt_fin / apuracao_cprb.dt_ini e apuracao_cprb.dt_fin) - fkb_valida_codativcprb_id.
-- Parâmetros de entrada: cod_ativ_cprb.id, dt_inicial e dt_final.
--
-- Em 16/04/2015 - Angela Inês.
-- Redmine #7724 - Processo INSS Desonerado - Bloco CPRB. Correção no processo.
-- Incluir função para recuperar a alíquota vinculada ao código da atividade da previdência (cod_ativ_cprb.aliq).
-- Rotina: fkb_aliq_codativcprb_id.
--
-- Em 09/06/2015 - Angela Inês.
-- Redmine #9024 - Apuração automática dos ajustes dos Blocos M200 e M600 - Sped EFD-Contribuições.
-- Alterar o nome da tabela onde retorna o tipo de campo da função fkg_contr_soc_apur_pc_id, ficando: contr_soc_apur_pc.id.
--
-- Em 16/07/2015 - Angela Inês.
-- Redmine #10092 - Correção no Ajuste automático Blocos M210 e M610.
-- Para recuperar o código da contribuição social do ajuste (contr_soc_apur_pc), deve ser considerado também a alíquota de cofins (pk_apur_cofins.pkb_monta_dados_m600).
-- Rotina: pk_csf_efd_pc.fkg_ajuste_cons_contr_id.
--
-- Em 19/08 - 01/09/2015 - Angela Inês.
-- Redmine #9837 - Ajuste Automático Apuração Bloco P - CPRB - Processos.
-- Incluir função para retornar os parâmetros de CFOP para os ajustes da CPRB através de Empresa e CFOP (param_cfop_empresa).
-- Rotina: pk_csf_efd_pc.fkb_paramcfopempr_emprcfop.
--
-- Em 13/10/2015 - Angela Inês.
-- Redmine #12181 - Geração do Arquivo Sped EFD-Contribuições.
-- Considerar a composição do tipo de crédito 102 do CST 50, igual para os outros CSTs.
-- Rotina: pk_csf_efd_pc.fkg_relac_tipo_cred_pc_id.
--
-- Em 20/04/2016 - Fábio Tavares.
-- Redmine #10112 - Alteraos processos que utilizam o parâmetro para o novo nome da coluna dm_gera_ajuste_contr
-- da tabela param_cfop_empresa.
-- Rotina: fkg_gera_recisen_cfop_empr.
--
-- Em 03/05/2016 - Angela Inês.
-- Redmine #18448 - Correção na geração do EFD-Contribuições - Blocos M200 e M600.
-- 1) Inclusão da função que identifica se existe Obrigações a Recolher da Apuração de PIS das consolidações de contribuições com origem Digitado.
-- Rotina: fkb_existe_pisor_gerado.
-- 2) Inclusão da função que identifica se existe Obrigações a Recolher da Apuração de COFINS das consolidações de contribuições com origem Digitado.
-- Rotina: fkb_existe_cofinsor_gerado.
--
-- Em 29/06/2016 - Angela Inês.
-- Redmine #20812 - Processo de PIS e COFINS - Geração do Bloco M100/M500.
-- Função retorna se existe Relacionamento entre Apuração de Crédito (M100) e Controle de Crédito Fiscal (1100) - PIS.
-- Função retorna se existe Valores de Relacionamento entre Apuração de Crédito (M100) e Controle de Crédito Fiscal (1100) - PIS.
-- Funções: fkb_existe_relac_apur_pis e fkb_existe_rel_apur_contr_pis.
-- Função retorna se existe Relacionamento entre Apuração de Crédito (M500) e Controle de Crédito Fiscal (1500) - COFINS.
-- Função retorna se existe Valores de Relacionamento entre Apuração de Crédito (M500) e Controle de Crédito Fiscal (1500) - COFINS.
-- Funções: fkb_existe_relac_apur_cof e fkb_existe_rel_apur_contr_cof.
-- Redmine #20813 - Processo de PIS e COFINS - Geração do Bloco 1100/1500.
-- Função retorna se existe Relacionamento entre Apuração de Crédito (M100) e Controle de Crédito Fiscal (1100) - Controle de Crédito Fiscal
-- Função retorna se existe Valores de Relacionamento entre Apuração de Crédito (M100) e Controle de Crédito Fiscal (1100) - Controle de Crédito Fiscal
-- Funções: fkb_existe_relac_contr_pis e fkb_existe_rel_vlr_contr_pis.
-- Função retorna se existe Relacionamento entre Apuração de Crédito (M500) e Controle de Crédito Fiscal (1500) - Controle de Crédito Fiscal
-- Função retorna se existe Valores de Relacionamento entre Apuração de Crédito (M500) e Controle de Crédito Fiscal (1500) - Controle de Crédito Fiscal
-- Funções: fkb_existe_relac_contr_cof e fkb_existe_rel_vlr_contr_cof.
--
-- Em 17/11/2016 - Angela Inês.
-- Redmine #25369 - Alteração em função que recupera Código de Contribuição Social.
-- 1) Alterar a rotina que recupera o identificador da contribuição social, incluindo o parâmetro que indica qual o bloco a ser gerado devido ao processo do
-- Bloco F200. Rotina: pk_csf_efd_pc.fkg_relac_cons_contr_id.
-- 2) Alterar a rotina que retorna o identificador do tipo de crédito para os impostos PIS/PASEP e COFINS através de parâmetros, incluindo o identificador da
-- base de cálculo de crédito como parâmetro de entrada - en_basecalccredpc_id, que deverá ser utilizado somente para os dados do Bloco F150, caso contrário,
-- deverá ser enviado como 0(zero). Rotina: fkg_relac_tipo_cred_pc_id.
--
-- Em 20/12/2017 - Angela Inês.
-- Redmine #37054 - Criar processo de validação das informações dos Blocos A, C, D, F e I.
-- Rotinas criadas para retornar os identificadores do Plano de Contas e do Centro de Custo dos Impostos PIS e COFINS:
-- Funções: fkb_recup_pcta_pis, fkb_recup_pcta_cofins, fkb_recup_ccust_pis e fkb_recup_ccust_cofins.
--
-- Em 09/01/2018 - Angela Inês.
-- Redmine #38308 - Correções nos processos de validação.
-- Passar a considerar os parâmetros de entrada para recuperação dos planos de contas e centros de custos da seguinte forma e ordem:
-- 1) Todos os parâmetros iguais seguindo a ordem: en_dm_ind_emit, en_dm_ind_oper, en_modfiscal_id, en_pessoa_id, en_cfop_id, en_item_id, en_ncm_id e en_tpservico_id.
-- 2) Não encontramos estaremos recuperando na mesma ordem do item 1, porém eliminando do último campo até o primeiro, comparando na igualdade (=).
-- 3) Não encontrando nos itens 1 e 2, estaremos recuperando na mesma do item 1, porém do primeiro até o último, mas com apenas um dos campos enviado no
-- parâmetro, e os outros como sendo nulos. Exemplo: en_dm_ind_emit = tabela, e os outros campos da tabela como sendo nulos (is null).
-- Funções: fkb_recup_pcta_pis, fkb_recup_pcta_cofins, fkb_recup_ccust_pis e fkb_recup_ccust_cofins.
--
-- Em 10/01/2018 - Angela Inês.
-- Redmine #38364 - Correção na recuperação dos parâmetros - Planos de Contas e Centros de Custos - PIS e COFINS.
-- 1) Atender a recuperação dos planos de contas e centros de custos através dos parâmetros enviados dos documentos fiscais e registros dos Blocos F e I.
-- 2) Não encontrando parâmetros através do item 1, o processo irá recuperar os planos de contas e centros de custos com apenas um dos campos enviado no parâmetro, e os outros como sendo nulos. Exemplo: en_dm_ind_emit = tabela, e os outros campos da tabela como sendo nulos (is null).
-- Função: fkb_recup_pcta_ccto_pc.
--
-- Em 13/03/2018 - Angela Inês.
-- Redmine #40467 - Alteração dos Registro C110 e 0450 do Sped Contribuições que as informações adicionais sejam exportadas de forma integral no arquivo Texto.
-- Criar função para recuperar parâmetro em "Parâmetros EFD PIS/COFINS": param_efd_contr.dm_quebra_infadic_spedc - 0-Não, 1-Sim.
-- Função: fkg_parefdcontr_dmqueinfadi.
--
-- Em 23/03/2018 - Angela Inês.
-- Redmine #40901 - Correção nas funções que recuperam Plano de Contas de Centros de Custos.
-- 1) Eliminar as funções: fkb_recup_pcta_pis, fkb_recup_pcta_cofins, fkb_recup_ccust_pis e fkb_recup_ccust_cofins.
-- 2) Alterar a função que retorna ou plano de conta para PIS ou COFINS, ou, centro de custo para PIS ou COFINS, considerando os valores enviados dos documentos
-- fiscais, porém nos parâmetros os valores possam estar nulos.
-- Funções eliminadas: fkb_recup_pcta_pis, fkb_recup_pcta_cofins, fkb_recup_ccust_pis e fkb_recup_ccust_cofins.
-- Função: fkb_recup_pcta_ccto_pc.
--
-- Em 11/04/2018 - Marcos Ferreira
-- Redmine #41435 - Processos - Criação de Parâmetros CST de PIS e COFINS para Geração e Apuração do EFD-Contribuições.
-- Inclusão das variáveis globais para tratar log_genérico
-- Alteração na Função fkg_gera_recisen_cfop_empr
-- Alteração na Função fkg_gera_escr_efdpc_cfop_empr
-- Alteração na Função fkg_dmgeraajusm210_parcfopempr
--
-- Em 27/04/2018 - Angela Inês.
-- Redmine #42250 - Parametrização de Conta Contábil SPED - PIS/COFINS.
-- A função que recupera o plano de conta para atualização dos documentos fiscais, irá recuperar o plano de conta mais recente (max planoconta_id), quando
-- houver mais de um registro de acordo com os parâmetros enviados para consulta.
-- Rotina: fkb_recup_pcta_ccto_pc.
--
-- Em 16/05/2018 - Angela Inês.
-- Redmine #42924 - Correções nos processos de Validação e Atualização de Plano de Contas e Centros de Custos - Sped EFD-Contribuições.
-- Correção na recuperação dos identificadores de Plano de Contas e Centros de Custos.
-- Quando existem mais de um registro, com duplicidade de informações, a recuperação será feita considerando todos os campos enviados, porém ordenados por:
-- tpservico_id, ncm_id, item_id, cfop_id, pessoa_id, modfiscal_id, dm_ind_oper e dm_ind_emit. Consideramos do último parâmetro enviado até o primeiro.
-- Rotina: fkb_recup_pcta_ccto_pc.
--
-- Em 29/06/2018 - Angela Inês.
-- Redmine #44515 - Processo do Sped EFD-Contribuições: Cálculo, Validação e Geração do Arquivo.
-- Revisar todos os processos de Cálculo, Validação e Geração do Arquivo Sped EFD-Contribuições.
-- Rotinas: fkg_gera_recisen_cfop_empr, fkg_gera_cred_nfpc_cfop_empr, fkg_gera_escr_efdpc_cfop_empr, fkg_dmgeraajusm210_parcfopempr, fkb_gerainssdeson_cfop, e
-- fkb_paramcfopempr_emprcfop.
--
-- Em 20/07/2018 - Angela Inês.
-- Redmine #45001 - Correções nos processos de Apuração e Geração do EFD-Contribuições.
-- Correção na função que recupera o Tipo de Crédito para os Impostos PIS e COFINS.
-- Na montagem da Apuração dos PIS e COFINS - Blocos M100 e M500, considerar os 3(três) lançamentos, com os Tipos de Créditos 108, 208 e 308, para os registros
-- informados no Bloco F130 - Bens incorporados ao ativo imobilizado - Aquisição/Contribuição, quando a Origem de Crédito for Operação de Importação, que não
-- possui CST e nem possui CFOP. Atualmente o processo considera apenas um lançamento com o Tipo de Crédito 108.
-- Rotina: fkg_relac_tipo_cred_pc_id.
--
-- Em 24/07/2018 - Angela Inês.
-- Redmine #45297 - Alterar as funções utilizadas nas Apurações e Gerações do Arquivo Sped EFD-Contribuições.
-- Alterar as funções que recuperam os valores dos Parâmetros de CFOP e CST, para compôr os valores de Apuração e Geração do Arquivo.
-- Rotinas: fkg_gera_recisen_cfop_empr, fkg_gera_cred_nfpc_cfop_empr, fkg_gera_escr_efdpc_cfop_empr, fkg_dmgeraajusm210_parcfopempr, fkb_gerainssdeson_cfop, e
-- fkb_paramcfopempr_emprcfop.
--
-- Em 15/08/2018 - Marcos Ferreira.
-- Redmine #45660 - R-2060 - Parametrização por NCM
-- Solicitação: Atualmente para realizarmos o calculo da CPRB da Reinf está sendo utilizada a configuração que era utilizada no cálculo do bloco P, ou seja, por parametrização dos itens que ficam sujeitos a CPRB.
--              Como a configuração atual é massificante e demanda uma manutenção maior, sugerimos que a regra de parametrização seja feita por NCM conforme especificado no projeto inicial da REINF e em complemento utilize a configuração por item para filtrar as notas sujeitas a CPRB.
-- Alteração: Após Incluído coluna nova ncm_id na tabela EMPRESA_ATIVCPRB, alterado a função fkg_codativcprb_id_empativcprb para buscar por ncm caso não encontre por item_id
--            Inlcuído novo parametro de entrada na função: ncm_id
--
-- Em 17/09/2018 - Karina de Paula
-- Redmine #46949 - fkg_gera_escr_efdpc_cfop_empr => Alterada a pk_csf_efd_pc.fkg_gera_escr_efdpc_cfop_empr para retornar valor do dm_gera_escr_efd
-- como "zero" qdo o impostos CST de PIS e/ou COFINS estiver cadastrado na tab de parâmetros param_cfop_empr_cst.
--
-- Em 15/10/2018 - Angela Inês.
-- Redmine #47800 - Correção na recuperação dos parâmetros de CFOP para PIS e COFINS.
-- Recuperar os valores gerados para o parâmetro param_cfop_empresa.dm_gera_escr_efd, e não atribuir 0(zero), quando existir informação de CST.
-- Rotina: fkg_gera_escr_efdpc_cfop_empr.
--
-------------------------------------------------------------------------------------------------------

   gv_mensagem_log       log_generico.mensagem%type := null;
   gv_obj_referencia     log_generico.obj_referencia%type := null;
   gn_referencia_id      log_generico.referencia_id%type := null;
   gv_resumo_log         log_generico.resumo%type := null;

-------------------------------------------------------------------------------------------------------

-- Declaração de constantes
   erro_de_validacao     constant number := 1;
   erro_de_sistema       constant number := 2; -- 2-Erro geral do sistema
   erro_inform_geral     constant number := 35; -- 35-Informação Geral

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do Registro do Bloco da EFD Pis/Cofins conforme código do bloco
function fkg_registr_efd_pc_id ( ev_cd in registr_efd_pc.cd%type )
         return registr_efd_pc.id%type;

-------------------------------------------------------------------------------------------------------
-- Função retorna o ID da tabela Base de Cálculo de Crédito
function fkg_base_calc_cred_pc_id ( ev_cd in base_calc_cred_pc.cd%type )
         return base_calc_cred_pc.id%type;

-------------------------------------------------------------------------------------------------------
-- Função retorna o CD da tabela Base de Cálculo de Crédito, conforme ID
function fkg_base_calc_cred_pc_cd ( en_id in base_calc_cred_pc.id%type )
         return base_calc_cred_pc.cd%type;

-------------------------------------------------------------------------------------------------------
-- Função confirma o ID da tabela Base de Cálculo de Crédito
function fkg_id_base_calc_cred_pc_id ( en_id in base_calc_cred_pc.id%type )
         return base_calc_cred_pc.id%type;

-------------------------------------------------------------------------------------------------------
-- Função que recupera a descrição do "Código da Base de Cálculo do Crédito" através do identificador
function fkg_descr_basecalccredpc ( en_basecalccredpc_id in base_calc_cred_pc.id%type )
         return base_calc_cred_pc.descr%type;

-------------------------------------------------------------------------------------------------------
-- Função retorna o ID do Código do Grupo por Marca Comercial/Refrigerantes
function fkg_id_item_marca_comerc ( en_item_id in item.id%type )
         return item_marca_comerc.id%type;

---------------------------------------------------------------------------------------------------------------
-- Função retorna o identificador do tipo de crédito para os impostos PIS/PASEP e COFINS através de parâmetros
function fkg_relac_tipo_cred_pc_id ( en_empresa_id        in empresa.id%type      -- identificador da empresa
                                   , en_tipoimp_id        in tipo_imposto.id%type -- identificador do tipo de imposto (pis ou cofins)
                                   , en_codst_id          in cod_st.id%type       -- identificador do código ST
                                   , en_ncm_id            in ncm.id%type          -- identificador do código ncm
                                   , en_cfop_id           in cfop.id%type         -- identificador do código cfop
                                   , en_ind_orig_cred     in number               -- indicador de crédito 0-Oper.Mercado Interno, 1-Oper.Importação
                                   , en_vl_aliq           in number               -- valor de alíquota dos impostos: identificar básica ou diferenciada
                                   , en_qt_bc_imp         in number               -- valor da base de cálculo - por unidade de produto
                                   , en_vl_bc_imp         in number               -- valor da base de cálculo - por valor
                                   , en_seq_lancto        in number               -- sequência de lançamento
                                   , en_basecalccredpc_id in number               -- identificador da base de cálculo de crédito para Bloco F150
                                   , en_pessoa_id         in pessoa.id%type )     -- identificador da pessoa do documento fiscal								   
         return tipo_cred_pc.id%type;

-------------------------------------------------------------------------------------------------------
-- Função para retornar o identificador do tipo de crédito para os impostos pis/cofins
function fkg_tipo_cred_pc_id ( ev_cd in tipo_cred_pc.cd%type )
         return tipo_cred_pc.id%type;

-------------------------------------------------------------------------------------------------------
-- Função para retornar o código do identificador do tipo de crédito para os impostos pis/cofins
function fkg_cd_tipo_cred_pc ( en_tipocredpc_id in tipo_cred_pc.id%type )
         return tipo_cred_pc.cd%type;

-------------------------------------------------------------------------------------------------------
-- Função para retornar o código do identificador da Contribuição Social para os Impostos PIS e COFINS
function fkg_cd_contr_soc_apur_pc ( en_contrsocapurpc_id in contr_soc_apur_pc.id%type )
         return contr_soc_apur_pc.cd%type;

-------------------------------------------------------------------------------------------------------
-- Função para retornar o identificador do Código de Contribuição Social para os Impostos PIS e COFINS
function fkg_contr_soc_apur_pc_id ( ev_cd in contr_soc_apur_pc.cd%type )
         return contr_soc_apur_pc.id%type;

-------------------------------------------------------------------------------------------------------
-- Função retorna o código de contribuição social através de parâmetros
function fkg_relac_cons_contr_id ( en_tipoimp_id      in tipo_imposto.id%type -- identificador do tipo de imposto (pis ou cofins)
                                 , en_ind_orig_cred   in number               -- indicador de crédito 0-Oper.Mercado Interno, 1-Oper.Importação
                                 , en_codst_id        in cod_st.id%type       -- identificador do código ST
                                 , en_vl_aliq         in number               -- valor de alíquota em percentual
                                 , en_vl_aliq_quant   in number               -- valor da alíquota por unidade de produto
                                 , en_dm_cod_inc_trib in abertura_efd_pc_regime.dm_cod_inc_trib%type -- indicador da incidência tributária
                                 , ev_bloco           in varchar2 default null ) -- código do bloco a ser processado
         return contr_soc_apur_pc.id%type;

------------------------------------------------------------------------------------------------------------------------
-- Função retorna o código de contribuição social através de parâmetros para ajustes automáticos dos blocos M200 e M600
function fkg_ajuste_cons_contr_id ( en_tipoimp_id      in tipo_imposto.id%type                        -- identificador do tipo de imposto (pis ou cofins)
                                  , en_dm_ind_ativ     in abertura_efd_pc.dm_ind_ativ%type            -- indicador de atividade
                                  , en_dm_cod_inc_trib in abertura_efd_pc_regime.dm_cod_inc_trib%type -- indicador da incidência tributária
                                  , en_cd_codst        in cod_st.cod_st%type                          -- código ST
                                  , en_aliq            in imp_itemnf.aliq_apli%type )                 -- valor de alíquota em percentual
         return contr_soc_apur_pc.id%type;

--------------------------------------------------------------------------------------------------------------
-- Função para retornar a descrição do código do identificador do tipo de crédito para os impostos PIS/COFINS
function fkg_descr_tipo_cred_pc ( en_tipocredpc_id in tipo_cred_pc.id%type )
         return tipo_cred_pc.descr%type;

------------------------------------------------------------------------------------------------------------------
-- Função para retornar o identificador da Natureza de Receita Conforme Código de Situação Tributária e Alíquotas
function fkg_nat_rec_pc_id ( en_multorg_id in nat_rec_pc.multorg_id%type
                           , en_codst_id   in cod_st.id%type
                           , en_aliq_apli  in number
                           , en_aliq_qtde  in number
                           , en_ncm_id     in number   default 0
                           , ev_cod_ncm    in varchar2 default null )
         return nat_rec_pc.id%type;

------------------------------------------------------------------------------------------------------
-- Função para confirmar o identificador da Natureza de Receita
function fkg_conf_id_nat_rec_pc ( en_natrecpc_id in nat_rec_pc.id%type )
         return nat_rec_pc.id%type;

------------------------------------------------------------------------------------------------------------------
-- Função para retorar o "código" da Natureza da Receita do Pis/COFINS
function fkg_cod_id_nat_rec_pc ( en_natrecpc_id in nat_rec_pc.id%type )
         return nat_rec_pc.cod%type;

------------------------------------------------------------------------------------------------------------------
-- Função para retorar o "ID" da Natureza da Receita do Pis/COFINS pelo Cod_st e cod
function fkg_codst_id_nat_rec_pc ( en_multorg_id        in nat_rec_pc.multorg_id%type
                                 , en_natrecpc_codst_id in nat_rec_pc.codst_id%type
                                 , en_natrecpc_cod      in nat_rec_pc.cod%type )
          return nat_rec_pc.id%type;

------------------------------------------------------------------------------------------------------
-- Função para retornar a situação da apuração de crédito
function fkg_sit_apur_pis ( en_apurcredpis_id in apur_cred_pis.id%type )
         return apur_cred_pis.dm_situacao%type;

------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados ao período da apuração de crédito - PIS
function fkg_qtde_apur_pis ( en_perapurcredpis_id in per_apur_cred_pis.id%type )
         return number;

------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados a apuração de crédito - PIS
function fkg_qtde_det_apur_pis ( en_apurcredpis_id in apur_cred_pis.id%type )
         return number;

------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados ao período de consolidação do imposto PIS
function fkg_qtde_cons_pis ( en_perconscontrpis_id in per_cons_contr_pis.id%type )
         return number;

------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados a consolidação do imposto PIS
function fkg_qtde_det_cons_pis ( en_conscontrpis_id in cons_contr_pis.id%type )
         return number;

------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados ao período das receitas isentas - PIS
function fkg_qtde_per_rec_pis ( en_perrecisentapis_id in per_rec_isenta_pis.id%type )
         return number;

------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados a receitas isentas do imposto PIS
function fkg_qtde_det_rec_pis ( en_recisentapis_id in rec_isenta_pis.id%type )
         return number;

------------------------------------------------------------------------------------------------------
-- Função para retornar a situação da apuração de crédito para o imposto COFINS
function fkg_sit_apur_cofins ( en_apurcredcofins_id in apur_cred_cofins.id%type )
         return apur_cred_cofins.dm_situacao%type;

----------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados ao período da apuração de crédito - COFINS
function fkg_qtde_apur_cofins ( en_perapurcredcofins_id in per_apur_cred_cofins.id%type )
         return number;

------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados a apuração de crédito - COFINS
function fkg_qtde_det_apur_cofins ( en_apurcredcofins_id in apur_cred_cofins.id%type )
         return number;

------------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados ao período da consolidação do imposto COFINS
function fkg_qtde_cons_cofins ( en_perconscontrcofins_id in per_cons_contr_cofins.id%type )
         return number;

----------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados a consolidação do imposto COFINS
function fkg_qtde_det_cons_cofins ( en_conscontrcofins_id in cons_contr_cofins.id%type )
         return number;

----------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados ao período das receitas isentas - COFINS
function fkg_qtde_per_rec_cofins ( en_perrecisentacofins_id in per_rec_isenta_cofins.id%type )
         return number;

----------------------------------------------------------------------------------------------------------
-- Função para retornar a quantidade de registros relacionados a receitas isentas do imposto COFINS
function fkg_qtde_det_rec_cofins ( en_recisentacofins_id in rec_isenta_cofins.id%type )
         return number;

----------------------------------------------------------------------------------------------------------
-- Função retorna o CD da tabela Orig_Proc
function fkg_cd_orig_proc ( en_origproc_id  in orig_proc.id%type )
         return orig_proc.cd%type;

----------------------------------------------------------------------------------------------------------
-- Função confirma o ID da tabela Plano de Conta
function fkg_id_plano_conta_id ( en_id in plano_conta.id%type )
         return plano_conta.id%type;

----------------------------------------------------------------------------------------------------------
-- Função confirma o ID da tabela Centro de Custo
function fkg_id_centro_custo_id ( en_id in centro_custo.id%type )
         return centro_custo.id%type;

----------------------------------------------------------------------------------------------------------
-- Procedimento para gravar o log/alteração das notas fiscais de serviços contínuos
procedure pkb_inclui_log_nf_serv_cont( en_notafiscal_id in nota_fiscal.id%type
                                     , ev_resumo        in log_nf_serv_cont.resumo%type
                                     , ev_mensagem      in log_nf_serv_cont.mensagem%type
                                     , en_usuario_id    in neo_usuario.id%type
                                     , ev_maquina       in varchar2 );

----------------------------------------------------------------------------------------------------------
-- Função verifica se o CFOP gera receita isenta para a empresa
-- O sistema busca na empresa, seja filial, ou busca na matriz -> 0-não, 1-sim -> valor default 1-sim
function fkg_gera_recisen_cfop_empr ( en_empresa_id      in param_cfop_empresa.empresa_id%type
                                    , en_cfop_id         in param_cfop_empresa.cfop_id%type
                                    , en_codst_id_pis    in param_cfop_empr_cst.codst_id_pis%type    default null
                                    , en_codst_id_cofins in param_cfop_empr_cst.codst_id_cofins%type default null
                                    )
         return param_cfop_empresa.dm_gera_receita%type;

----------------------------------------------------------------------------------------------------------
-- Função verifica se o CFOP gerou crédito de pis/cofins para nota fiscal de entrada de pessoa física e não deveria
-- O sistema busca na empresa, seja filial, ou busca na matriz -> 0-não, 1-sim -> valor default 0-não
function fkg_gera_cred_nfpc_cfop_empr ( en_empresa_id      in param_cfop_empresa.empresa_id%type
                                      , en_cfop_id         in param_cfop_empresa.cfop_id%type
                                      , en_codst_id_pis    in param_cfop_empr_cst.codst_id_pis%type    default null
                                      , en_codst_id_cofins in param_cfop_empr_cst.codst_id_cofins%type default null
                                      )
         return param_cfop_empresa.dm_gera_cred_pf_pc%type;

----------------------------------------------------------------------------------------------------------
-- Função verifica se o CFOP gera escrituração fiscal - geração do arquivo texto de pis/cofins
-- O sistema busca na empresa, seja filial, ou busca na matriz -> 0-não, 1-sim -> valor default 1-sim
function fkg_gera_escr_efdpc_cfop_empr ( en_empresa_id      in param_cfop_empresa.empresa_id%type
                                       , en_cfop_id         in param_cfop_empresa.cfop_id%type
                                       , en_codst_id_pis    in param_cfop_empr_cst.codst_id_pis%type    default null
                                       , en_codst_id_cofins in param_cfop_empr_cst.codst_id_cofins%type default null
                                       )
         return param_cfop_empresa.dm_gera_escr_efd_pc%type;

----------------------------------------------------------------------------------------------------------
-- Função retorna id da tabela REGISTRO_DACON conforme o código.
function fkg_registrodacon_id ( ev_cod  in  registro_dacon.cd%type )
         return registro_dacon.id%type;

----------------------------------------------------------------------------------------------------------
-- Função retorna código da tabela REGISTRO_DACON conforme o id.
function fkg_registrodacon_cd ( en_registrodacon_id  in  registro_dacon.id%type )
         return registro_dacon.cd%type;

----------------------------------------------------------------------------------------------------------
-- Função retorna id da tabela PROD_DACON conforme o código e o dm_tabela.
function fkg_proddacon_id ( ev_cod        in  prod_dacon.cd%type
                          , ev_dm_tabela  in  prod_dacon.dm_tabela%type )
         return prod_dacon.id%type;

----------------------------------------------------------------------------------------------------------
-- Função retorna código da tabela PROD_DACON conforme o id.
function fkg_proddacon_cd ( en_proddacon_id  in  prod_dacon.id%type )
         return prod_dacon.cd%type;

----------------------------------------------------------------------------------------------------------
-- Função para retornar se o CFOP gera valor como ajuste na consolidação para PIS e COFINS.
function fkg_dmgeraajusm210_parcfopempr ( en_empresa_id      in empresa.id%type
                                        , en_cfop_id         in cfop.id%type
                                        , en_codst_id_pis    in param_cfop_empr_cst.codst_id_pis%type    default null
                                        , en_codst_id_cofins in param_cfop_empr_cst.codst_id_cofins%type default null
                                        )
         return param_cfop_empresa.dm_gera_ajuste_contr%type;

----------------------------------------------------------------------------------------------------------
-- Função para retornar o identificador do código de ajuste de contribuição ou crédito através do código.
function fkg_id_cd_ajustcontrpc ( en_cd in ajust_contr_pc.cd%type )
         return ajust_contr_pc.id%type;

----------------------------------------------------------------------------------------------------------
-- Função para retornar o parâmetro que indica geração de receita para CST através da Natureza de Receita
function fkg_dm_gerareceita_natrecpc( en_natrecpc_id in nat_rec_pc.id%type )
         return nat_rec_pc.dm_gera_receita%type;

----------------------------------------------------------------------------------------------------------
-- Função para retornar o parâmetro de Cálculo automático do Bloco M
function fkg_dmcalcblocomaut_empresa( en_empresa_id in param_efd_contr.empresa_id%type )
         return param_efd_contr.dm_calc_bloco_m_aut%type;

----------------------------------------------------------------------------------------------------------
-- Função retorna se existe período de abertura efd pis/cofins com arquivo gerado
function fkb_existe_perarq_gerado( en_empresa_id in empresa.id%type
                                 , ed_data       in date
                                 )
         return boolean;

------------------------------------------------------------------------------------------------------------------------
-- Função retorna o identificador do código de atividade incidente da contribuição previdenciária sobre a receita bruta
function fkg_codativcprb_id_empativcprb( en_empresa_id   in empresa.id%type
                                       , en_item_id      in item.id%type default null
                                       , en_ncm_id       in ncm.id%type  default null
                                       , en_tpservico_id in tipo_servico.id%type default null 
                                       , en_cnae_id      in cnae.id%type default null
                                       )
         return empresa_ativcprb.codativcprb_id%type;

--------------------------------------------------------------------------------------------------------------------------------
-- Função retorna o código da atividade incidente da contribuição previdenciária sobre a receita bruta através do identificador
function fkg_cd_codativcprb( en_codativcprb_id in cod_ativ_cprb.id%type
                           )
         return cod_ativ_cprb.cd%type;

-------------------------------------------------------------------------------------------------------------------------
-- Função retorna o código de Detalhamento da contribuição previdenciária sobre a receita bruta através do identificador
function fkg_cd_coddetcprb( en_coddetcprb_id in cod_det_cprb.id%type
                          )
         return cod_det_cprb.cd%type;

-----------------------------------------------------------------------------------------------
-- Função para retornar o código de ajuste de contribuição ou crédito através do identificador
function fkg_cd_ajustcontrpc ( en_ajustcontrpc_id in ajust_contr_pc.id%type )
         return ajust_contr_pc.cd%type;

----------------------------------------------------------------------------------------------------------------
-- Função para retornar se o CFOP gera INSS desonerado, porém sem utilizar os parâmetros de CST de PIS e COFINS
function fkb_gerainssdeson_cfop ( en_empresa_id      in empresa.id%type
                                , en_cfop_id         in cfop.id%type
                                , en_codst_id_pis    in param_cfop_empr_cst.codst_id_pis%type    default null
                                , en_codst_id_cofins in param_cfop_empr_cst.codst_id_cofins%type default null
                                )
         return param_cfop_empresa.dm_gera_inss_deson%type;

---------------------------------------------------------------------------------------------------------------
-- Função para retornar se a Empresa permite validação com registro de log/inconsistência para INSS desonerado
function fkb_valinssdeson_empr ( en_empresa_id empresa.id%type )
         return param_efd_contr.dm_valida_inss_deson%type;

---------------------------------------------------------------------------------------------------------------
-- Função para retornar se o código de atividade incidente CPRB está válido dentro do período da apuração
function fkb_valida_codativcprb_id ( en_codativcprb_id in cod_ativ_cprb.id%type
                                   , ed_dt_inicial     in date
                                   , ed_dt_final       in date )
         return cod_ativ_cprb.id%type;

---------------------------------------------------------------------------------------------------------------
-- Função para retornar a alíquota vinculada ao código da atividade da previdência (cod_ativ_cprb.aliq)
function fkb_aliq_codativcprb_id( en_codativcprb_id in cod_ativ_cprb.id%type )
         return cod_ativ_cprb.aliq%type;

---------------------------------------------------------------------------------------------------------------------
-- Função para retornar os parâmetros de CFOP para os ajustes da CPRB através de Empresa e CFOP (param_cfop_empresa)
function fkb_paramcfopempr_emprcfop ( en_empresa_id          in  param_cfop_empresa.empresa_id%type
                                    , en_cfop_id             in  param_cfop_empresa.cfop_id%type
                                    , sn_dm_gera_receita     out param_cfop_empresa.dm_gera_receita%type
                                    , sn_dm_gera_inss_deson  out param_cfop_empresa.dm_gera_inss_deson%type
                                    , sn_dm_gera_ajuste_cprb out param_cfop_empresa.dm_gera_ajuste_cprb%type
                                    , sn_dm_tipo_ajuste      out param_cfop_empresa.dm_tipo_ajuste%type
                                    , sn_dm_ind_aj           out param_cfop_empresa.dm_ind_aj%type
                                    , sn_ajustcontrpc_id     out param_cfop_empresa.ajustcontrpc_id%type )
         return number;

----------------------------------------------------------------------------------------------------------------------------
-- Função retorna se existe Obrigações a Recolher da Apuração de PIS das consolidações de contribuições com origem Digitado
function fkb_existe_pisor_gerado( en_perconscontrpis_id in per_cons_contr_pis.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------------------------------
-- Função retorna se existe Obrigações a Recolher da Apuração de COFINS das consolidações de contribuições com origem Digitado
function fkb_existe_cofinsor_gerado( en_perconscontrcofins_id in per_cons_contr_cofins.id%type )
         return boolean;

----------------------------------------------------------------------------------------------------------------------
-- Função retorna se existe Relacionamento entre Apuração de Crédito (M100) e Controle de Crédito Fiscal (1100) - PIS
function fkb_existe_relac_apur_pis( en_apurcredpis_id in apur_cred_pis.id%type )
         return boolean;

---------------------------------------------------------------------------------------------------------------------------------
-- Função retorna se existe Valores de Relacionamento entre Apuração de Crédito (M100) e Controle de Crédito Fiscal (1100) - PIS
function fkb_existe_rel_apur_contr_pis( en_apurcredpis_id in apur_cred_pis.id%type )
         return boolean;

---------------------------------------------------------------------------------------------------------------------------------------------
-- Função retorna se existe Relacionamento entre Apuração de Crédito (M100) e Controle de Crédito Fiscal (1100) - Controle de Crédito Fiscal
function fkb_existe_relac_contr_pis( en_contrcredfiscalpis_id in contr_cred_fiscal_pis.id%type )
         return boolean;

--------------------------------------------------------------------------------------------------------------------------------------------------------
-- Função retorna se existe Valores de Relacionamento entre Apuração de Crédito (M100) e Controle de Crédito Fiscal (1100) - Controle de Crédito Fiscal
function fkb_existe_rel_vlr_contr_pis( en_contrcredfiscalpis_id in contr_cred_fiscal_pis.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------------------------
-- Função retorna se existe Relacionamento entre Apuração de Crédito (M500) e Controle de Crédito Fiscal (1500) - COFINS
function fkb_existe_relac_apur_cof( en_apurcredcofins_id in apur_cred_cofins.id%type )
         return boolean;

------------------------------------------------------------------------------------------------------------------------------------
-- Função retorna se existe Valores de Relacionamento entre Apuração de Crédito (M500) e Controle de Crédito Fiscal (1500) - COFINS
function fkb_existe_rel_apur_contr_cof( en_apurcredcofins_id in apur_cred_cofins.id%type )
         return boolean;

---------------------------------------------------------------------------------------------------------------------------------------------
-- Função retorna se existe Relacionamento entre Apuração de Crédito (M500) e Controle de Crédito Fiscal (1500) - Controle de Crédito Fiscal
function fkb_existe_relac_contr_cof( en_contrcredfiscalcofins_id in contr_cred_fiscal_cofins.id%type )
         return boolean;

--------------------------------------------------------------------------------------------------------------------------------------------------------
-- Função retorna se existe Valores de Relacionamento entre Apuração de Crédito (M500) e Controle de Crédito Fiscal (1500) - Controle de Crédito Fiscal
function fkb_existe_rel_vlr_contr_cof( en_contrcredfiscalcofins_id in contr_cred_fiscal_cofins.id%type )
         return boolean;

---------------------------------------------------------------------------------------------------------------
-- Função para retornar: ou plano de conta para PIS ou COFINS; ou, centro de custo para PIS ou COFINS
function fkb_recup_pcta_ccto_pc( en_empresa_id   in param_efd_contr_geral.empresa_id%type
                               , en_dm_ind_emit  in param_efd_contr_geral.dm_ind_emit%type default null
                               , en_dm_ind_oper  in param_efd_contr_geral.dm_ind_oper%type default null
                               , en_modfiscal_id in param_efd_contr_geral.modfiscal_id%type default null
                               , en_pessoa_id    in param_efd_contr_geral.pessoa_id%type default null
                               , en_cfop_id      in param_efd_contr_geral.cfop_id%type default null
                               , en_item_id      in param_efd_contr_geral.item_id%type default null
                               , en_ncm_id       in param_efd_contr_geral.ncm_id%type default null
                               , en_tpservico_id in param_efd_contr_geral.tpservico_id%type default null
                               , ed_dt_ini       in param_efd_contr_geral.dt_ini%type
                               , ed_dt_final     in param_efd_contr_geral.dt_final%type default null
                               , en_cod_st_piscofins  in param_efd_contr_geral.cod_st_piscofins%type default null
                               , ev_ret          in varchar2 ) -- 'PCTA_PIS', 'PCTA_COF', 'CCTO_PIS', 'CCTO_COF'
         return number; -- planoconta_id_pis, centrocusto_id_pis, planoconta_id_cofins, centrocusto_id_cofins

---------------------------------------------------------------------------------------------------------------
-- Procedimento retorna o parâmetro que Permite a quebra da Informação Adicional no arquivo Sped Contribuições
function fkg_parefdcontr_dmqueinfadi ( en_empresa_id in empresa.id%type )
         return param_efd_contr.dm_quebra_infadic_spedc%type;

----------------------------------------------------------------------------------------------------------

end pk_csf_efd_pc;
/
