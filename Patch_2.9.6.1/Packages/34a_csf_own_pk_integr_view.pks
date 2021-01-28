create or replace package csf_own.pk_integr_view is
-- 
-- ============================================================================================================================================= --
-- Especificação do pacote de integração de Notas Fiscais a partir de leitura de views
--
-- Em 25/01/2021   - Luis Marques - 2.9.6-1 / 2.9.7
-- Redmine #75509  - alterar mensagem de retorno
-- Rotina Alterada - pkb_ler_Nota_Fiscal_Fisco - Alterado mensagem de retorno diminuindo caracteres para a apresentação ser completa.
--
-- Em 20/01/2021   - Luis Marques - 2.9.6-1 / 2.9.7
-- Redmine #71035  - Integração para nota_fiscal_fisco
-- Nova Rotina     - pkb_ler_nota_fiscal_fisco - Procedimento de leitura das informacões do documento de arrecadação referenciado.
-- Rotina Alterada - pkb_limpa_array - Incluido limpeza para os array(s) "vt_tab_csf_nota_fiscal_fisco"
--                   pkb_ler_Nota_Fiscal - Incluir chamada para nova rotina "pkb_ler_nota_fiscal_fisco".
--
-- Em 10/08/2020   - Luis Marques - 2.9.5
-- Redmine #58588  - Alterar tamanho de campo NRO_NF
--                 - Ajuste do type de notas fiscal "vt_tab_csf_nota_fiscal" campo "NRO_NF" de 9 para 30 para notas
--                   de serviços.
--
-- Em 10/08/2020   - Armando
-- Redmine   - ajuste no objeto para trabalhar com RabbitM
--
-- Em 02/09/2020   - Karina de Paula
-- Redmine #70508  - Falha na transmissão da Atualização do status da nota para o SIC
-- Rotina Alterada - pkb_int_infor_erp e pkb_int_infor_erp_neo => Incluído no cursor da nf o valor 5--Integrado via Arquivo Texto (ENT) do domínio dm_st_integra
-- Liberado        - Release_2.9.5, Patch_2.9.4.3 e Patch_2.9.3.6
--
-- Em 03 e 08/06/2020  - Karina de Paula
-- Redmine #62471      - Criar processo de validação da CSF_CONS_SIT
-- Alterações          - pkb_ler_cons_chave_nfe     => Alterada a chamada pk_csf_api.pkb_integr_cons_chave_nfe para pk_csf_api_cons_sit.pkb_integr_cons_chave_nfe
--                     - pkb_seta_integr_erp_csf_cs => Retirado o update na csf_cons_sit e incluída a chamada da pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit
--                     - pkb_ret_cons_erp           => Retirado o update na csf_cons_sit e incluída a chamada da pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit
--                     - pkb_seta_integr_erp_csf_cs => Incluído o parâmetro de entrada empresa_id
--                     - pkb_int_csf_cons_sit       => Incluída a empresa_id na chamada da pkb_seta_integr_erp_csf_cs
-- Liberado            - Release_2.9.4, Patch_2.9.3.3 e Patch_2.9.2.6
--
-- Em 06/05/2020  - Karina de Paula
-- Redmine #65401 - NF-e de emissão própria autorizada indevidamente (CERRADÃO)
-- Alterações     - Incluído para o gv_objeto o nome da package como valor default para conseguir retornar nos logs o objeto;
-- Liberado       - Release_2.9.4, Patch_2.9.3.2 e Patch_2.9.2.5
--
-- Em_15/01/2020 - Luis marques
-- Redmine #63705 - feed - continua da mesma forma
-- Rotina Alterada: pkb_ler_Nota_Fiscal - Incluida verificação se os log(s) gerado(s) existe(m) algum(s) registro(s) de erro ou só de
--                  informação geral e alerta, para colocar a nota com erro de validação.
--
-- Em 28/11/2019        - Karina de Paula
-- Redmine #60469       - Criar novo objeto e tipo de objeto Emissão Própria NFCE (modelo 65)
-- Rotinas Alteradas    - pkb_ler_Nota_Fiscal_Canc/pkb_seta_where_emissao_propria => Retirada a integração da nota cod_mod 65 (NFCE)
--                        A nota cod_mod 65 (NFCE) passou a ser integrada pela view pk_integr_view_nfce
--
-- Em 28/11/2019        - Karina de Paula
-- Redmine #61627       - NF 86608
-- Rotinas Alteradas    - pkb_int_ret_infor_erp_ff => Alterado o select do cursor c_ff que estava retornando valores nulos
--
-- Em 21/11/2019        - Karina de Paula
-- Redmine #61507       - Integração continua não funcionando
-- Rotinas Alteradas    - pkb_ler_NFInfor_Fiscal        => Tirar o trim do cod_obs na chamada da pkb_ler_inf_prov_docto_fiscal
--                        pkb_ler_inf_prov_docto_fiscal => Incluir o trim do cod_obs na chamada da pk_csf_api.pkb_integr_inf_prov_docto_fisc
--
-- Em 05/11/2019        - Karina de Paula
-- Redmine #60526	- Retorno de NFe - Open Interface
-- Rotinas Alteradas    - Retornei a função fkg_empresa_id_cpf_cnpj onde tinha sido trocada pela fkg_empresa_id_pelo_cpf_cnpj
-- NÃO ALTERE A REGRA DESSAS ROTINAS SEM CONVERSAR COM EQUIPE
--
-- Em 09/10/2019        - Karina de Paula
-- Redmine #52654/59814 - Alterar todas as buscar na tabela PESSOA para retornar o MAX ID
-- Rotinas Alteradas    - Trocada a função pk_csf.fkg_cnpj_empresa_id pela pk_csf.fkg_empresa_id_cpf_cnpj
-- NÃO ALTERE A REGRA DESSAS ROTINAS SEM CONVERSAR COM EQUIPE
--
-- Em 16/09/2019   - Luis Marques
-- Redmine #58745  - Erro na tag PMVast
-- Rotina Alterada: pkb_ler_Imp_ItemNf - Verificado se o valor estiver zero e for (0,1,2,3,4,5) na Modalidade de Determinação 
--                  da base de calculo do ICMS-ST, o imposto for ICMS-ST e a situação tributária for '10', '30', '60', '70' ou '90'
--                  coloca null para o campo perc_adic para não ocorrer erro na tag PMVast do XML.
-- 
-- Em 13/09/2019         - Karina de Paula
-- Redmine #58226/58769  - feed - retorno para NFe
-- Rotina Alterada       - pkb_ret_infor_erp_neo  => Incluída a desativiação das viewSs VW_CSF_RESP_NFS_ERP e VW_CSF_RESP_NFS_ERP_FF quando estiver ATIVADA a VW_CSF_RESP_NFS_ERP_NEO
-- As alterações feitas inicialmente foram perdidas em função de uma atualização indevida minha
--
-- Em 21/08/2019 - Karina de Paula
-- Redmine #53545 - Criar VW unica para retorno ao ERP
-- Rotina Alterada: Criada a nova procedure pkb_int_infor_erp_neo para integração da view VW_CSF_RESP_NF_ERP_NEO
--                  Criada a nova procedure pkb_ret_infor_erp_neo para integração da view VW_CSF_RESP_NF_ERP_NEO
--                  fkg_ret_dm_st_proc_erp    => Incluído o novo parâmetro de entrada ev_obj_name para poder ser usado também pela nova view VW_CSF_RESP_NF_ERP_NEO
--                  pkb_ret_infor_erro_nf_erp => Retirado da função interna fkg_existe_log a chamada da pk_csf.fkg_existe_obj_util_integr porque já é chamada
--                                               no início do processo da pkb_ret_infor_erro_nf_erp
--                                            => Criado o parâmetro de entrada ev_obj para que possa ser usado para as duas views: 
--                                               VW_CSF_RESP_NF_ERP e VW_CSF_RESP_NF_ERP_NEO
--                                            => Incluídos novos campos COD_MSG e ID_ERP para retorno na view VW_CSF_RESP_NF_ERP_NEO
--                  pkb_integracao/pkb_integr_multorg/pkb_gera_retorno/pkb_gera_retorno_bloco => Incluída a chamada da pkb_int_infor_erp_neo e pkb_ret_infor_erp_neo
--
-- Em 16/05/2019 - Karina de Paula
-- Redmine #54406 - feed - nfe erro de validação duplica itens e fatura
-- Rotina Alterada: pkb_ler_Nota_Fiscal => Incluída a chave da view da nota fiscal no order by do select de integração
--
-- === AS ALTERAÇÕES ABAIXO ESTÃO NA ORDEM CRESCENTE USADA ANTERIORMENTE ================================================================================= --

-- Em 25/09/2012 - Angela Inês - Ficha HD 62250.
-- 1) Inclusão do processo de integração de Notas Fiscais Referenciadas - Processo Flex Field (FF).
--
-- Em 07/11/2012 - Angela Inês.
-- 1) Ficha HD 63810 - Validação da chave de NFE, considerando o Número da NF com o campo da chave.
--    Rotina: pkb_ler_nota_fiscal_compl.
--
-- Em 26/11/2012 - Rogério Silva - Ficha HD 64482.
-- Inclusão do processo de integração do diferencial de aliquota do item da nota fiscal
-- Rotina: pkb_ler_itemnf_dif_aliq.
--
-- Em 29/11/2012 - Angela Inês.
-- Ficha HD 64680 - Eliminar caracteres especiais para integração dos campos: cnpj, cpf e ie.
-- Rotinas: pkb_ler_nota_fiscal_dest e pkb_ler_nota_fiscal_emit.
--
-- Em 19/12/2012 - Angela Inês.
-- Ficha HD 64603 - Implementar os campos flex field para a integração dos impostos dos itens das Notas Fiscais.
--
-- Em 28/12/2012 - Angela Inês.
-- Ficha HD 65154 - Fechamento Fiscal por empresa.
-- Verificar a data de último fechamento fiscal, não permitindo integrar, se a data estiver posterior ao período em questão.
--
-- Em 29/12/2012 - Rogério Silva.
-- Ficha HD 65330 - Integração XML de terceiro.
--
-- Em 26/09/2013 - Rogério Silva
-- Inclusão do processo de integração do Item da Nota Fiscal - Processo Flex Field (FF)
--
-- Em 07/11/2013 - Rogério Silva
-- Alterado o tamanho do campo "renavam" de 9 para 11 na definição do tipo "tab_csf_itemnf_veic"
--
-- Em 22/01/2014 - Angela Inês.
-- Redmine #1813 - Integração de notas fiscais: algumas notas não integram pelo agendamento e qdo executa pk_integra_view.pkb_integr_periodo, a nota é integrada.
-- Limpar a variável gd_dt_ini_integr nos processos de agendamento e integração quando a mesma não for utilizada.
-- Rotina: pkb_integr_perido_geral.
--
-- Em 26/02/2014 - Angela Inês.
-- Redmine #2087 - Passar a gerar log no agendamento quando a data do documento estiver no período da data de fechamento.
-- Rotina: pkb_ler_nota_fiscal.
--
-- Em 17/04/2014 - Angela Inês.
-- Redmine #2682 - Processo de integração em blocos não retorna as notas integradas.
-- Alteração/rotina: pkb_gera_retorno_bloco: incluímos o comando COMMIT no final do loop na rotina.
-- Alteração/rotina: pkb_ret_infor_erp: descomentado o comando PRAGMA.
--
--
-- Em 08/09/2014 - Leandro Savenhago.
-- Processo de retorno da Integração
-- Alteração/rotina: pkb_int_infor_erp: incluida a opção de exclusão da tabela VW_CSF_RESP_NF_ERP, pois há registros 
                                    -- que o cliente manipula manualmente no Compliance, perdendo a referencia do NOTAFISCAL_ID
-- Alteração/rotina: pkb_ret_infor_erp: Alterado a rotina para que caso não exista registro na tabela VW_CSF_RESP_NF_ERP, 
                                    -- alteração do campo DM_ST_INTEGRA da tabela NOTA_FISCAL para 7-Integração por view de banco de dados, para incluir novamente o registro.
-- Alteração/rotina: pkb_excluir_nf: comentado para não gravar o log da exclusão sem necessidade.
--
-- Em 06/10/2014 - Rogério Silva
-- Redmine #5020 - Processo de contagem de registros integrados do ERP (Agendamento de integração)
--
-- Em 12/10/2014 - Rogério Silva
-- Redmine #5508 - Desenvolver tratamento no processo de contagem de dados
--
-- Em 30/12/2014 e 06/01/2015 - Angela Inês.
-- Redmine #5616 - Adequação dos objetos que utilizam dos novos conceitos de Mult-Org.
--
-- Em 15/01/2015 - Leandro Savenhago
-- Redmine #5874 - Informação de retorno ERP (MANIKRAFT
--
-- Em 26/01/2015 - Rogério Silva
-- Redmine #6041 - Remover campo "NUM_ACDRAW" da tabela "VW_CSF_ITEMNFDI_ADIC" e das integrações
--
-- Em 26/01/2015 - Rogério Silva
-- Redmine #5696 - Indicação do parâmetro de integração
--
-- Em 26/01/2015 - Rogério Silva
-- Redmine #6016 - Integração de Notas Fiscais com opção de "Terceiro" no agendamento.
-- Rotina: pkb_ler_Nota_Fiscal
--
-- Em 19/02/2015 - Leandro Savenhago
-- Redmine #6459 - Demora na integração NFe.
-- Avaliação dos Indices com a DBSI
--
-- Em 30/03/2015 - Rogério Silva
-- Redmine #6881 - Integração de notas com CFOP 1152 (BARCELOS)
-- Rotina: pkb_ler_Nota_Fiscal
--
-- Em 26/05/2015 - Rogério Silva
-- Redmine #8635 - Retorno NF-e - vw_csf_resp_nf_erp (ADIDAS)
--
-- Em 11/06/2015 - Rogério Silva.
-- Redmine #8232 - Processo de Registro de Log em Packages - Notas Fiscais Mercantis
--
-- Em 01/07/2015 - Rogério Silva.
-- Redmine #9707 - Avaliar os processos que utilizam empresa_integr_banco.dm_ret_infor_integr: variáveis locais e globais.
--
-- Em 30/07/2014 - Rogério Silva.
-- Redmine #10264 - VW_CSF_RESP_NF_ERP - pk_integr_view
--
-- Em 07/08/2015 - Angela Inês.
-- Redmine #10117 - Escrituração de documentos fiscais - Processos.
-- Inclusão do novo conceito de recuperação de data dos documentos fiscais para retorno dos registros.
--
-- Em 31/08/2014 - Rogério Silva.
-- Redmine #11142 - Registrar log no caso de notas duplicadas no momento da integração
-- e fazer com que o processo não seja interrompido, mesmo com erro de duplicidade.
--
-- Em 16/09/2015 - Rogério Silva.
-- Redmine #11637 - Erro de validação - Looping - pk_integr_view.pkb_ret_infor_erro_nf_erp (CREMER)
--
-- Em 05/10/2015 - Angela Inês.
-- Redmine #11911 - Implementação do UF DEST nos processos de Integração e Validação.
-- Nota fiscal Total Flex-field: Incluir os campos VL_ICMS_UF_DEST e VL_ICMS_UF_REMET.
-- Item da nota fiscal Flex-Field: Incluir o campo COD_CEST.
-- Incluir o grupo de tributação do ICMS para a UF do destinatário: VW_CSF_IMP_ITEMNF_ICMS_DEST.
-- Rotinas: pkb_ler_nota_fiscal_total_ff, pkb_ler_item_nota_fiscal_ff e pkb_ler_imp_itemnf_icms_dest.
--
-- Em 22/10/2015 - Angela Inês.
-- Redmine #12391 - Implementação das novas colunas nos processos de Integração e Validação.
-- vw_csf_imp_itemnf_icms_dest.perc_comb_pobr_uf_dest.
-- vw_csf_imp_itemnf_icms_dest.vl_comb_pobr_uf_dest.
-- vw_csf_nota_fiscal_total_ff.atributo: vl_comb_pobr_uf_dest.
-- Rotina: pkb_ler_imp_itemnficmsdest.
--
-- Em 12/11/2015 - Angela Inês.
-- Redmine #12525 - Alteração no processo de Integração das Notas Fiscais.
-- Processos - View/Tabela VW_CSF_NF_FORMA_PGTO_FF/NF_FORMA_PGTO - Formas de Pagamento da Nota Fiscal.
-- Rotina: pkb_integr_nf_forma_pgto_ff.
--
-- Em 24/11/2015 - Rogério Silva.
-- Redmine #13060 - URGENTISSIMO - SISTEM DEMORA 20 MIN PARA BUSCAR NF PARA VALIDAÇÃO SEFAZ
--
-- Em 26/11/2015 - Rogério Silva.
-- Redmine #13197 - Acertar o processo de integração
--
-- Em 30/11/2015 - Angela Inês.
-- Redmine #13264 - Não está integrando as notas 1007 e 1008.
-- Correção no tamanho do campo ATRIBUTO para varchar2(600) na view de integração VW_CSF_NOTA_FISCAL_FF.
--
-- Em 15/01/2016 - Angela Inês.
-- Redmine #14550 - Recuperação das consultas de chave NFE ao retorno ERP.
-- Correção da recuperação das consultas de chave NFE ao retorno ERP, considerando a situação do registro como sendo diferente de 'Consulta Pendente'
-- (csf_cons_sit.dm_situacao <> 1-Consulta Pendente).
-- Rotina: pkb_ret_cons_erp.
--
-- Em 26/01/2016 - Angela Inês.
-- Redmine #14834 - Retornar as mensagens/erro na View de Retorno.
-- Considerar a tabela LOG_GENERICO para retorno das mensagens de resposta de erro, além da tabela LOG_GENERICO_NF.
-- Rotina: pkb_ret_infor_erro_nf_erp.
--
-- Em 29/01/2016 - Angela Inês.
-- Redmine #14809 - Erro na pk_integr_view.pkb_int_csf_cons_sit (CISNE).
-- Correção no processo de consulta de situação da nota fiscal: alterar a conversão de datas para compôr a qtde de dias em consulta.
-- Rotina: pkb_int_csf_cons_sit.
--
-- Em 09/08/2016 - Angela Inês.
-- Redmine #22200 - Correção na Integração da Nota Fiscal - Consultas de NFe com o ERP.
-- No procedimento que integra as consultas de NFe com o ERP, verificar na view de xml (VW_CSF_XML_NFE_TERC), se o registro da nota fiscal já existe registro 
-- pelo seu identificador (notafiscal_id), se não existir, verificar pelo número da chave nfe (nro_chave_nfe). Fazer a inclusão do registro na view de xml 
-- (VW_CSF_XML_NFE_TERC) caso não exista em nenhuma verificação, ou fazer a alteração através do identificador da nota (notafiscal_id), ou do número da chave 
-- nfe (nro_chave_nfe), verificado anteriormente.
-- Rotina: pkb_int_csf_cons_sit.
--
-- Em 17/08/2016 - Angela Inês.
-- Redmine #22536 - Melhoria nas mensagens de Integração de Consulta de Nota Fiscal.
-- Incluir nas mensagens de inconsistência do processo de Integração das consultas de NFe com o ERP, dados da Nota Fiscal e da Consulta para melhor identificação
-- do problema.
-- Rotina: pkb_int_csf_cons_sit.
--
-- Em 24/01/2017 - Marcos Garcia
-- Redmine #27226 - Integração Normal Table/View - ITEMNF_EXPORT_COMPL
-- Obs.: Realizar a leitura da table/view de integração vw_csf_itemnf_export_compl.
--
-- Em 14/02/2017 - Leandro Savenhago
-- Redmine #27781 - ERRO INTEGRAÇÃO MDE
-- Rotina: pkb_ret_cons_erp - comentado o campo campo DM_SITUACAO do cursor
--
-- Em 22/02/2017 - Fábio Tavares
-- Redmine #28662 - Registros do Agendamento de Integração
-- Rotina: pkb_integr_periodo_geral.
--
-- Em 01/03/2017 - Leandro Savenhago
-- Redmine 28832- Implementar o "Parâmetro de Formato de Data Global para o Sistema".
-- Implementar o "Parâmetro de Formato de Data Global para o Sistema".
--
-- Em 03/03/2017 - Leandro Savenhago
-- Redmine #29048 - Lentidão Emissão e erro no Retorno de Notas de terceiro
-- Rotina: pkb_int_csf_cons_sit - Alterado para se não retornar XML, então não montar o campo ARQUIVO no insert da tabela VW_CSF_XML_NFE_TERC
--
-- Em 07/07/2017 - Leandro Savenhago
-- Redmine #27083 - Indevida geração de Lote p/ envio á Sefaz.
-- Rotina: pkb_ler_Nota_Fiscal - Implementando a utilização do DM_LEGADO, para definir a situação da NF de Emissão Própria
--
-- Em 16/06/2017 - Marcos Garcia
-- Redmine #30475 - Avaliações nos Processos de Integração e Relatórios de Inconsistências - Processo de Fechamento Fiscal.
-- Atividade: Parametrização do log com o tipo 39-fechamento fiscal
--            referencia_id nula, obj_referencia = a tabela atual no momento da integração e a empresa solicitante da integração.
--            Log de fechamento fiscal aparecerá nos relatórios de integração.
--
--  Em 30/06/2017 - Leandro Savenhago
-- Redmine #31839 - CRIAÇÃO DOS OBJETOS DE INTEGRAÇÃO - STAFE
-- Criação do Procedimento PKB_STAFE
--
-- Em 19/07/2017 - Marcos Garcia
-- Redmine# 30475 - Avaliações nos Processos de Integração e Relatórios de Inconsistências - Processo de Fechamento Fiscal.
-- Criação da variavel global info_fechamento, que é alimentada antes do inicio das integrações
-- com o identificador do fechamento fiscal.(csf_tipo_log).
--
-- Em 24/07/2017 - Angela Inês.
-- Redmine #33061 - Alterar o processo de Integração de Notas Fiscais Mercantis: Retorno de Informação para o ERP.
-- Eliminar o comando PRAGMA da rotina que retorna as informação na view de retorno para o ERP do cliente.
-- Rotina: pkb_ret_infor_erp
--
-- Em 20/09/2017 - Leandro Savenhago
-- Redmine #34431 - Integração Table/view 06 Nota Fiscal Mercantil NFe 4.00
--
-- Em 29/09/2017 - Marcelo Ono
-- Redmine #34948 - Correções no processo de Integração Table/view 06 Nota Fiscal Mercantil NFe 4.00
-- Alterado o tamanho do type tab_csf_itemnf_rastreab qtde_lote (11,3)
--
-- Em 23/11/2017 - Angela Inês.
-- Redmine #36829 - Processo de integração de NFe por Job Scheduller.
-- Rotina: pkb_integr_multorg.
--
-- Em 27/11/2017 - Marcos Garcia
-- Redmine # 35998 - Correção na reuperação do cursor que faz o retorno das notas canceladas para o ERP do cliente
-- Rotina: pkb_int_ret_infor_erp_ff.
--
-- Em 07/12/2017 - Angela Inês.
-- Redmine #37356 - Correção na integração de notas fiscais mercantis - Medicamentos.
-- 1) No processo de integração dos campos flex-field para medicamentos em cada item da nota fiscal, corrigir a montagem do select dinâmico, considerando as
-- aspas simples, para o campo NRO_LOTE, pois o mesmo é caractere. Correção técnica não visível pelo portal ou mensageria.
-- Rotina: pkb_ler_ItemNF_Med_ff.
--
-- Em 02/02/2018 - Angela Inês.
-- Redmine #39021 - Processo de Agendamento de Integração - alteração nos processos do tipo Todas as Empresas.
-- Na tela/portal do agendamento, quando selecionamos o campo "Tipo" como sendo "Todas as empresas" (agend_integr.dm_tipo=3), o processo de agendamento
-- (pk_agend_integr.pkb_inicia_agend_integr), executa a rotina pk_agend_integr.pkb_inicia_agend_integr/pkb_agend_integr_csf.
-- Utilizando esse processo, incluir nas rotinas relacionadas a cada objeto de integração, o processo criado para o cliente Usina Santa Fé, rotina com o nome
-- padrão "PKB_STAFE". Essa rotina está sendo utilizada nas integrações, porém quando o agendamento é feito por empresa (agend_integr.dm_tipo=1).
-- Com essa mudança a integração passará a ser feita também para a opção de "Todas as empresas".
-- Rotina: pkb_integr_perido_geral.
--
-- Em 01/03/2018 - Angela Inês.
-- Redmine #39997 - Integração da Nota Fiscal Mercantil - Tratar o campo "Código do Grupo de Tensão de Energia Elétrica".
-- Ao integrar a nota fiscal mercantil eliminar os espaços do campo "Código do Grupo de Tensão de Energia Elétrica" (NOTA_FISCAL.DM_COD_GRUPO_TENSAO).
-- Rotina: pkb_ler_nota_fiscal_compl.
--
-- Em 18/05/2018 - Angela Inês.
-- Redmine #43020 - Correção no processo de Integração de NFE - Montagem VW_CSF_XML_NFE_TERC.
-- Correção no processo de Integração de NFE - Montagem VW_CSF_XML_NFE_TERC.
-- Alterar o procedimento que integra as consultas de NFe com o ERP na view VW_CSF_XML_NFE_TERC, considerando que o CPF/CNPJ da Empresa deva ser relacionado com a
-- empresa da Nota Fiscal e não com a empresa da consulta de NFE, pois a mesma poderá estar indicando uma Matriz, e a empresa da nota fiscal seja de uma Filial.
-- Rotina: pkb_int_csf_cons_sit.
--
-- Em 07/06/2018 - Angela Inês.
-- Redmine #43719 - Melhoria no processo de Integração de Nota Fiscal - Forma de Pagamento.
-- Alterar no processo de Integração de Nota Fiscal a mensagem que indica problemas ao recuperar os dados da View de Integração da Forma de Pagamento, para as
-- variáveis declaradas de acordo com as colunas da Tabela NF_FORMA_PGTO.
-- Rotinas: pkb_ler_nf_forma_pgto e pkb_ler_nf_forma_pgto_ff.
--
-- Em 13/06/2018 - Angela Inês.
-- Redmine #43970 - Correção no processo de Integração de Notas Fiscais - Forma de Pagamento.
-- Ao identificar o registro de Forma de Pagamento, estamos eliminando os espaços dos campos CNPJ e NRO_AUT, para serem incluídos na Tabela NF_FORMA_PGTO.
-- Quando o registro possui informações que estão na view Flex-Field, enviamos esses campos sem os espaços, portanto o registro não é encontrado.
-- Corrigir o envio desses campos não considerando a eliminação dos espaços, enviar os campos com os espaços para que o mesmo seja encontrado na view Flex-Field.
-- Rotina: pkb_ler_nf_forma_pgto.
--
-- Em 14/06/2018 - Angela Inês.
-- Redmine #44063 - Alterar o processo de Integração de Notas Fiscais - Forma de Pagamento.
-- Para atender o cliente devido as condições de não conseguirem eliminar os espaços dos registros a serem enviados para o Compliance, alterar os valores dos
-- campos DM_TP_PAG e DM_TP_BAND, para nulo, quando vierem com espaços.
-- Rotina: pkb_ler_nf_forma_pgto.
--
-- Em 28/06/2018 - Angela Inês.
-- Redmine #44496 - Correção no processo de Integração de Notas Fiscais Mercantis - Forma de Pagamento.
-- Considerar o valor do campo/coluna VL_PGTO das views de integração VW_CSF_NF_FORMA_PGTO e VW_CSF_NF_FORMA_PGTO_FF, multiplicado por 100 devido as duas casas
-- decimais. Hoje o campo VL_PGTO é utilizado na leitura dos campos FlexField, e pelo fato de ser numérico com casas decimais, o select dinâmico não preenche
-- corretamente as informações, ficando da seguinte forma:
-- 1) Processo recupera da tabela inicial VW_CSF_NF_FORMA_PGTO o valor do campo VL_PGTO: 88786,82.
-- 2) Para recuperar os valores da FlexField VW_CSF_NF_FORMA_PGTO_FF comparamos o campo VL_PGTO com a variável enviada com o valor da tabela inicial, e devido
-- aos decimais no campo com valor maior que zero, o select dinâmico fica inválido, montando algo como:
-- select * from vw_csf_nf_forma_pgto_ff where vl_pgto = 88786,82. Tecnicamente esse comando fica incorreto.
-- Rotina: pkb_ler_nf_forma_pgto_ff.
--
-- Em 10/07/2018 - Angela Inês.
-- Redmine #44801 - Correção na validação da Nota Fiscal Mercantil - Forma de Pagamento.
-- Considerar os campos DM_TP_BAND, CNPJ e NRO_AUT, para leitura da view FlexField, VW_CSF_NF_FORMA_PGTO_FF, somente se não forem nulos.
-- A comparação dos valores dos campos quando são nulos, não é validada corretamente.
-- Rotina: pkb_ler_nf_forma_pgto_ff.
--
-- Em 13/07/2018 - Angela Inês.
-- Redmine #44960 - Correção no processo de Integração de Nota Fiscal - Aquisição de Cana-de-Açúcar por dia.
-- Conforme solicitado, corrigir o processo de integração com relação a comparação do campo COD_PART.
-- Erro técnico ao montar string para recuperar os registros da view.
-- Rotina: pkb_ler_nf_aquis_cana_dia.
--
-- Em 20/08/2018 - Marcos Ferreira
-- Redmine #45828 - Realizar adequação - Correção de layout Registro 1100
-- Solicitação: Adequação ao layout do sped fiscal, campo NRO_DE alterado para varchar2(14)
-- Alterações: Type: tab_csf_itemnf_export_compl
--
-- Em 25/08/2018 - Angela Inês.
-- Redmine #46371 - Agendamento de Integração cujo Tipo seja "Todas as Empresas".
-- Incluir o identificador do Mult-Org como parâmetro de entrada (mult_org.id), para Agendamento de Integração como sendo do Tipo "Todas as Empresas".
-- Rotina: pkb_integr_periodo_geral.
--
-- Em 31/10/2018 - Angela Inês.
-- Redmine #48292 - Correção na integração de Notas Fiscais Mercantis - Período de Agendamento.
-- Desconsiderar a "Hora" nas datas de emissão e de saída/entrada dos registros que estarão sendo integrados.
-- Ao agendar, utilizamos a Data Inicial e Final de Integração, para compôr o período dos registros a serem encontrados, considerando as datas de emissão ou de saída/entrada.
-- Rotinas: pkb_ler_Nota_Fiscal, pkb_seta_where_periodo e pkb_int_bloco.
--
-- Em 19/11/2018 - Eduardo Linden.
-- Redmine #48782 - Não fazer retorno de NFCE - Integração Open Interface - View.
-- Não considerar as notas fiscais de modelo "65" para retorno na View de Integração VW_CSF_RESP_NF_ERP.
-- Rotinas: pkb_int_infor_erp e pkb_ret_infor_erp.
--
-- Em 17/12/2018 - Marcos Ferreira
-- Redmine #48007 - Falha ao integrar o atributo COD_CEST da CSF_INT.VW_CSF_NOTA_ITEM_NOTA_FISCAL_FF (MANIFRAKFT)
-- Solicitação: Remover espaço em branco do campo cod_item
-- Alterações: Incluído a pk_csf_fkg_converte na montagem do gv_sql, e o trim na associação a tabela de memória
-- Procedures Alteradas: pkb_ler_Item_Nota_Fiscal
--
-- Em 24/12/2018 - Angela Inês.
-- Redmine #49824 - Processos de Integração e Validações de Nota Fiscal (vários modelos).
-- Incluir os processos de integração, validações api e ambiente, para a tabela/view VW_CSF_ITEMNF_RES_ICMS_ST e tabela ITEMNF_RES_ICMS_ST. Esse processo se
-- refere aos modelos de notas fiscais 01-Nota Fiscal, e 55-Nota Fiscal Eletrônica, e são utilizados para montagem do Registro C176-Ressarcimento de ICMS e
-- Fundo de Combate à Pobreza (FCP) em Operações com Substituição Tributária (Código 01, 55), do arquivo Sped Fiscal.
-- Rotinas: pkb_ler_item_nota_fiscal e pkb_ler_itemnf_res_icms_st.
--
-- Em 03/01/2019 - Angela Inês.
-- Redmine #50204 - Correção na Integração de NF Mercantil - Item da Nota Fiscal.
-- A nova coluna de domínio que identifica o tipo de material não deve estar declarada na variável do registro de Item da Nota Fiscal, pois a mesma é integrada
-- através do processo Flex Field.
-- Variável: vt_tab_csf_item_nota_fiscal.
--
-- Em 23/01/2019 - Karina de Paula
-- Redmine #49691 - DMSTPROC alterando para 1 após update em NFSE - Dr Consulta
-- Criadas as variáveis globais gv_objeto e gn_fase para ser usada no trigger T_A_I_U_Nota_Fiscal_02 tb alterados os objetos q
-- alteram ou incluem dados na nota_fiscal.dm_st_proc para carregar popular as variáveis
--
-- Em 01/02/2019 - Karina de Paula
-- Redmine #51038 - Criar campos no banco
-- Rotina Alterada: pkb_ler_Nota_Fiscal_Local => Incluídos os campos: nome, cep, cod_pais, desc_pais, fone e email
--
-- Em 13/02/2019 - Renan Alves  
-- Redmine #51531 - Alterações PLSQL para atender layout 005 (vigência 01/2019) - Parte 2.
-- Foi alterado o tamanho da coluna NRO_DI de 12 caracteres para 15 caracteres nas tabelas (SPEC):
--  tab_csf_itemnf_dec_impor
--  tab_csf_itemnf_dec_impor_ff 
--  tab_csf_itemnfdi_adic 
--  tab_csf_itemnfdi_adic_ff
--
-- Em 15/02/2019 - Karina de Paula
-- Redmine #51625 - Alterar a integracao dos novos campos view VW_CSF_NOTA_FISCAL_LOCAL para VW_CSF_NOTA_FISCAL_LOCAL_FF
-- Rotina Alterada: pkb_ler_Nota_Fiscal_Local => Excluídos os campos: nome, cep, cod_pais, desc_pais, fone e email e incluída a chamada da pkb_ler_Nota_Fiscal_Local_ff
-- Rotina Criada  : pkb_ler_Nota_Fiscal_Local_ff
--
-- Em 25/02/2019 - Karina de Paula
-- Redmine #51882 - Incluir exclusao dos dados da view VW_CSF_NOTA_FISCAL_CANC_FF nos objetos que chamam a exclusao da VW_CSF_NOTA_FISCAL_CANC
-- Rotina Alterada: pkb_ler_Nota_Fiscal_Canc.pkb_excluir_canc => Incluído delete da view VW_CSF_NOTA_FISCAL_CANC_FF
--
-- Em 09/05/2019 - Luiz Armando Azoni
-- Redmine #54081: Validação do campo en_num_acdraw que na query dinamica não estava sendo preenchido.
-- Solicitação: Falha na execução da query dinamica campo en_num_acdraw não estava sendo preenchido.
-- Alterações: Adequação na pk_integr_view.pkb_ler_itemnf_export_compl, adicionando um if validando se o campo en_num_acdraw esta preechido.
-- Procedures Alteradas: pk_integr_view.pkb_ler_itemnf_export_compl
--
-- === AS ALTERAÇÕES PASSARAM A SER INCLUÍDAS NO INÍCIO DA PACKAGE ================================================================================= --
--
-- INICIO 1979
   vb_entrou               boolean := false; -- 1979
   vn_util_rabbitmq        number := 0;-- variável que receberá dados da param_geral_sistema.PARAM_NAME = 'UTILIZA_RABBIT_MQ'
   MODULO_SISTEMA          constant number := pk_csf.fkg_ret_id_modulo_sistema('INTEGRACAO');
   GRUPO_SISTEMA           constant number := pk_csf.fkg_ret_id_grupo_sistema(MODULO_SISTEMA, 'CTRL_FILAS');
   vn_empresa_id           empresa.id%type; 
   vn_multorg_id           mult_org.id%type;
   vv_erro                 varchar2(4000);
   -- FIM 1979
--| informações de notas fiscais não integradas
   -- Nível - 0
   type tab_csf_nota_fiscal is record ( cpf_cnpj_emit     varchar2(14)
                                      , dm_ind_emit       number(1)
                                      , dm_ind_oper       number(1)
                                      , cod_part          varchar2(60)
                                      , cod_mod           varchar2(2)
                                      , serie             varchar2(3)
                                      , nro_nf            number(30)
                                      , sit_docto         varchar2(2)
                                      , cod_nat_oper      varchar2(10)
                                      , descr_nat_oper    varchar2(60)
                                      , dm_ind_pag        number(1)
                                      , dt_sai_ent        date
                                      , hora_sai_ent      varchar2(8)
                                      , dt_emiss          date
                                      , uf_embarq         varchar2(2)
                                      , local_embarq      varchar2(60)
                                      , nf_empenho        varchar2(22)
                                      , pedido_compra     varchar2(60)
                                      , contrato_compra   varchar2(60)
                                      , dm_st_proc        number(2)
                                      , dm_fin_nfe        number(1)
                                      , dm_proc_emiss     number(1)
                                      , cidade_ibge_emit  number(7)
                                      , uf_ibge_emit      number(2)
                                      , usuario           varchar2(30)
                                      , vias_danfe_custom number(2)
                                      , nro_chave_cte_ref varchar2(44)
                                      , sist_orig         varchar2(10)
                                      , unid_org          varchar2(20)
                                      );
--
   type t_tab_csf_nota_fiscal is table of tab_csf_nota_fiscal index by binary_integer;
   vt_tab_csf_nota_fiscal t_tab_csf_nota_fiscal;
--
--| informações de notas fiscais não integradas - campos flex field
   -- Nível 1
   type tab_csf_nota_fiscal_ff is record ( cpf_cnpj_emit  varchar2(14)
                                         , dm_ind_emit    number(1)
                                         , dm_ind_oper    number(1)
                                         , cod_part       varchar2(60)
                                         , cod_mod        varchar2(2)
                                         , serie          varchar2(3)
                                         , nro_nf         number(9)
                                         , atributo       varchar2(30)
                                         , valor          varchar2(600) );
--
   type t_tab_csf_nota_fiscal_ff is table of tab_csf_nota_fiscal_ff index by binary_integer;
   vt_tab_csf_nota_fiscal_ff t_tab_csf_nota_fiscal_ff;
--
--| informações do emitente da nota fiscal
   -- Nível 1
   type tab_csf_nota_fiscal_emit is record ( cpf_cnpj_emit  varchar2(14)
                                           , dm_ind_emit    number(1)
                                           , dm_ind_oper    number(1)
                                           , cod_part       varchar2(60)
                                           , cod_mod        varchar2(2)
                                           , serie          varchar2(3)
                                           , nro_nf         number(9)
                                           , nome           varchar2(60)
                                           , fantasia       varchar2(60)
                                           , lograd         varchar2(60)
                                           , nro            varchar2(10)
                                           , compl          varchar2(60)
                                           , bairro         varchar2(60)
                                           , cidade         varchar2(60)
                                           , cidade_ibge    number(7)
                                           , uf             varchar2(2)
                                           , cep            number(8)
                                           , cod_pais       number(4)
                                           , pais           varchar2(60)
                                           , fone           varchar2(14)
                                           , ie             varchar2(14)
                                           , iest           varchar2(14)
                                           , im             varchar2(15)
                                           , cnae           varchar2(7)
                                           , dm_reg_trib    number(1) );
--
   type t_tab_csf_nota_fiscal_emit is table of tab_csf_nota_fiscal_emit index by binary_integer;
   vt_tab_csf_nota_fiscal_emit t_tab_csf_nota_fiscal_emit;
--
--| informações do emitente da nota fiscal - campos Flex Field
   -- Nível 2
   type tab_csf_nota_fiscal_emit_ff is record ( cpf_cnpj_emit  varchar2(14)
                                              , dm_ind_emit    number(1)
                                              , dm_ind_oper    number(1)
                                              , cod_part       varchar2(60)
                                              , cod_mod        varchar2(2)
                                              , serie          varchar2(3)
                                              , nro_nf         number(9)
                                              , atributo       varchar2(30)
                                              , valor          varchar2(255));
--
   type t_tab_csf_nota_fiscal_emit_ff is table of tab_csf_nota_fiscal_emit_ff index by binary_integer;
   vt_tab_csf_nota_fiscal_emit_ff t_tab_csf_nota_fiscal_emit_ff;
--
--| informações do destinatário da nota fiscal
   -- Nível 1
   type tab_csf_nota_fiscal_dest is record ( cpf_cnpj_emit  varchar2(14)
                                           , dm_ind_emit    number(1)
                                           , dm_ind_oper    number(1)
                                           , cod_part       varchar2(60)
                                           , cod_mod        varchar2(2)
                                           , serie          varchar2(3)
                                           , nro_nf         number(9)
                                           , cnpj           varchar2(14)
                                           , cpf            varchar2(11)
                                           , nome           varchar2(60)
                                           , lograd         varchar2(60)
                                           , nro            varchar2(10)
                                           , compl          varchar2(60)
                                           , bairro         varchar2(60)
                                           , cidade         varchar2(60)
                                           , cidade_ibge    number(7)
                                           , uf             varchar2(2)
                                           , cep            number(8)
                                           , cod_pais       number(4)
                                           , pais           varchar2(60)
                                           , fone           varchar2(14)
                                           , ie             varchar2(14)
                                           , suframa        varchar2(9)
                                           , email          varchar2(4000) );
--
   type t_tab_csf_nota_fiscal_dest is table of tab_csf_nota_fiscal_dest index by binary_integer;
   vt_tab_csf_nota_fiscal_dest t_tab_csf_nota_fiscal_dest;
--
--| informações do destinatário da nota fiscal - campos Flex Field
   -- Nível 2
   type tab_csf_nota_fiscal_dest_ff is record ( cpf_cnpj_emit  varchar2(14)
                                              , dm_ind_emit    number(1)
                                              , dm_ind_oper    number(1)
                                              , cod_part       varchar2(60)
                                              , cod_mod        varchar2(2)
                                              , serie          varchar2(3)
                                              , nro_nf         number(9)
                                              , atributo       varchar2(30)
                                              , valor          varchar2(255));
--
   type t_tab_csf_nota_fiscal_dest_ff is table of tab_csf_nota_fiscal_dest_ff index by binary_integer;
   vt_tab_csf_nota_fiscal_dest_ff t_tab_csf_nota_fiscal_dest_ff;
--
--| informações do destinatário da nota fiscal
   -- Nível 2
   type tab_csf_nfdest_email is record ( cpf_cnpj_emit  varchar2(14)
                                       , dm_ind_emit    number(1)
                                       , dm_ind_oper    number(1)
                                       , cod_part       varchar2(60)
                                       , cod_mod        varchar2(2)
                                       , serie          varchar2(3)
                                       , nro_nf         number(9)
                                       , email          varchar2(4000)
                                       , dm_tipo_anexo  number(1) );
--
   type t_tab_csf_nfdest_email is table of tab_csf_nfdest_email index by binary_integer;
   vt_tab_csf_nfdest_email t_tab_csf_nfdest_email;
--
--| informações dos totais da nota fiscal
   -- Nível 1
   type tab_csf_nota_fiscal_total is record ( cpf_cnpj_emit          varchar2(14)
                                            , dm_ind_emit            number(1)
                                            , dm_ind_oper            number(1)
                                            , cod_part               varchar2(60)
                                            , cod_mod                varchar2(2)
                                            , serie                  varchar2(3)
                                            , nro_nf                 number(9)
                                            , vl_base_calc_icms      number(15,2)
                                            , vl_imp_trib_icms       number(15,2)
                                            , vl_base_calc_st        number(15,2)
                                            , vl_imp_trib_st         number(15,2)
                                            , vl_total_item          number(15,2)
                                            , vl_frete               number(15,2)
                                            , vl_seguro              number(15,2)
                                            , vl_desconto            number(15,2)
                                            , vl_imp_trib_ii         number(15,2)
                                            , vl_imp_trib_ipi        number(15,2)
                                            , vl_imp_trib_pis        number(15,2)
                                            , vl_imp_trib_cofins     number(15,2)
                                            , vl_outra_despesas      number(15,2)
                                            , vl_total_nf            number(15,2)
                                            , vl_serv_nao_trib       number(15,2)
                                            , vl_base_calc_iss       number(15,2)
                                            , vl_imp_trib_iss        number(15,2)
                                            , vl_pis_iss             number(15,2)
                                            , vl_cofins_iss          number(15,2)
                                            , vl_ret_pis             number(15,2)
                                            , vl_ret_cofins          number(15,2)
                                            , vl_ret_csll            number(15,2)
                                            , vl_base_calc_irrf      number(15,2)
                                            , vl_ret_irrf            number(15,2)
                                            , vl_base_calc_ret_prev  number(15,2)
                                            , vl_ret_prev            number(15,2)
                                            , vl_total_serv          number(15,2) );
--
   type t_tab_csf_nota_fiscal_total is table of tab_csf_nota_fiscal_total index by binary_integer;
   vt_tab_csf_nota_fiscal_total t_tab_csf_nota_fiscal_total;
--
--| informações dos totais da nota fiscal - campos Flex Field
   -- Nível 2
   type tab_csf_nota_fiscal_total_ff is record ( cpf_cnpj_emit          varchar2(14)
                                                , dm_ind_emit            number(1)
                                                , dm_ind_oper            number(1)
                                                , cod_part               varchar2(60)
                                                , cod_mod                varchar2(2)
                                                , serie                  varchar2(3)
                                                , nro_nf                 number(9)
                                                , atributo               varchar2(30)
                                                , valor                  varchar2(255) );
--
   type t_tab_csf_nota_fiscal_total_ff is table of tab_csf_nota_fiscal_total_ff index by binary_integer;
   vt_tab_csf_notafiscal_total_ff t_tab_csf_nota_fiscal_total_ff;
--
--| informações de documentos fiscais referenciados
   -- Nível 1
   type tab_csf_nota_fiscal_referen is record ( cpf_cnpj_emit         varchar2(14)
                                              , dm_ind_emit           number(1)
                                              , dm_ind_oper           number(1)
                                              , cod_part              varchar2(60)
                                              , cod_mod               varchar2(2)
                                              , serie                 varchar2(3)
                                              , nro_nf                number(9)
                                              , nro_chave_nfe_ref     varchar2(44)
                                              , ibge_estado_emit_ref  varchar2(2)
                                              , cnpj_emit_ref         varchar2(14)
                                              , dt_emiss_ref          date
                                              , cod_mod_ref           varchar2(2)
                                              , nro_nf_ref            number(9)
                                              , serie_ref             varchar2(3)
                                              , subserie_ref          number(3)
                                              , cod_part_ref          varchar2(60)
                                              , dm_ind_oper_ref       number(1)
                                              , dm_ind_emit_ref       number(1) );
--
   type t_tab_csf_nota_fiscal_referen is table of tab_csf_nota_fiscal_referen index by binary_integer;
   vt_tab_csf_nota_fiscal_referen t_tab_csf_nota_fiscal_referen;
--
--| informações de documentos fiscais referenciados - campos flex field
   -- Nível 1
   type tab_csf_notafiscalrefer_ff is record ( cpf_cnpj_emit         varchar2(14)
                                             , dm_ind_emit           number(1)
                                             , dm_ind_oper           number(1)
                                             , cod_part              varchar2(60)
                                             , cod_mod               varchar2(2)
                                             , serie                 varchar2(3)
                                             , nro_nf                number(9)
                                             , nro_chave_nfe_ref     varchar2(44)
                                             , ibge_estado_emit_ref  varchar2(2)
                                             , cnpj_emit_ref         varchar2(14)
                                             , dt_emiss_ref          date
                                             , cod_mod_ref           varchar2(2)
                                             , nro_nf_ref            number(9)
                                             , serie_ref             varchar2(3)
                                             , subserie_ref          number(3)
                                             , cod_part_ref          varchar2(60)
                                             , dm_ind_oper_ref       number(1)
                                             , dm_ind_emit_ref       number(1)
                                             , atributo              varchar2(30)
                                             , valor                 varchar2(255) );
--
   type t_tab_csf_notafiscalrefer_ff is table of tab_csf_notafiscalrefer_ff index by binary_integer;
   vt_tab_csf_notafiscalrefer_ff t_tab_csf_notafiscalrefer_ff;
--
--| informações de cupom fiscal referenciado
   -- Nível 1
   type tab_csf_cupom_fiscal_ref is record ( cpf_cnpj_emit         varchar2(14)
                                           , dm_ind_emit           number(1)
                                           , dm_ind_oper           number(1)
                                           , cod_part              varchar2(60)
                                           , cod_mod               varchar2(2)
                                           , serie                 varchar2(3)
                                           , nro_nf                number(9)
                                           , cod_mod_cf            varchar2(2)
                                           , ecf_fab               varchar2(20)
                                           , ecf_cx                number(3)
                                           , num_doc               number(6)
                                           , dt_doc                date );
--
   type t_tab_csf_cupom_fiscal_ref is table of tab_csf_cupom_fiscal_ref index by binary_integer;
   vt_tab_csf_cupom_fiscal_ref t_tab_csf_cupom_fiscal_ref;
--
--| informações de Autorização de acesso ao XML da Nota Fiscal
   -- Nível 1
   type tab_csf_nf_aut_xml is record ( cpf_cnpj_emit         varchar2(14)
                                    , dm_ind_emit           number(1)
                                    , dm_ind_oper           number(1)
                                    , cod_part              varchar2(60)
                                    , cod_mod               varchar2(2)
                                    , serie                 varchar2(3)
                                    , nro_nf                number(9)
                                    , cnpj                  varchar2(14)
                                    , cpf                   varchar2(11));
--
   type t_tab_csf_nf_aut_xml is table of tab_csf_nf_aut_xml index by binary_integer;
   vt_tab_csf_nf_aut_xml t_tab_csf_nf_aut_xml;

--| informações de Formas de Pagamento
   -- Nível 1
   type tab_csf_nf_forma_pgto is record ( cpf_cnpj_emit         varchar2(14)
                                        , dm_ind_emit           number(1)
                                        , dm_ind_oper           number(1)
                                        , cod_part              varchar2(60)
                                        , cod_mod               varchar2(2)
                                        , serie                 varchar2(3)
                                        , nro_nf                number(9)
                                        , dm_tp_pag             varchar2(2)
                                        , vl_pgto               number(15,2)
                                        , cnpj                  varchar2(14)
                                        , dm_tp_band            varchar2(2)
                                        , nro_aut               varchar2(20));
--
   type t_tab_csf_nf_forma_pgto is table of tab_csf_nf_forma_pgto index by binary_integer;
   vt_tab_csf_nf_forma_pgto t_tab_csf_nf_forma_pgto;

--| informações de Formas de Pagamento - Flex-Field
   -- Nível 1
   type tab_csf_nf_forma_pgto_ff is record ( cpf_cnpj_emit   varchar2(14)
                                           , dm_ind_emit     number(1)
                                           , dm_ind_oper     number(1)
                                           , cod_part        varchar2(60)
                                           , cod_mod         varchar2(2)
                                           , serie           varchar2(3)
                                           , nro_nf          number(9)
                                           , dm_tp_pag       varchar2(2)
                                           , vl_pgto         number(15,2)
                                           , cnpj            varchar2(14)
                                           , dm_tp_band      varchar2(2)
                                           , nro_aut         varchar2(20)
                                           , atributo        varchar2(30)
                                           , valor           varchar2(255));
--
   type t_tab_csf_nf_forma_pgto_ff is table of tab_csf_nf_forma_pgto_ff index by binary_integer;
   vt_tab_csf_nf_forma_pgto_ff t_tab_csf_nf_forma_pgto_ff;

--| informações fiscais da nota fiscal
   -- Nível 1
   type tab_csf_nfinfor_fiscal is record ( cpf_cnpj_emit  varchar2(14)
                                         , dm_ind_emit    number(1)
                                         , dm_ind_oper    number(1)
                                         , cod_part       varchar2(60)
                                         , cod_mod        varchar2(2)
                                         , serie          varchar2(3)
                                         , nro_nf         number(9)
                                         , cod_obs        varchar2(6)
                                         , txt_compl      varchar2(255) );
--
   type t_tab_csf_nfinfor_fiscal is table of tab_csf_nfinfor_fiscal index by binary_integer;
   vt_tab_csf_nfinfor_fiscal t_tab_csf_nfinfor_fiscal;
--
--| informações adicionais da nota fiscal
   -- Nível 1
   type tab_csf_nfinfor_adic is record ( cpf_cnpj_emit  varchar2(14)
                                       , dm_ind_emit    number(1)
                                       , dm_ind_oper    number(1)
                                       , cod_part       varchar2(60)
                                       , cod_mod        varchar2(2)
                                       , serie          varchar2(3)
                                       , nro_nf         number(9)
                                       , dm_tipo        number(1)
                                       , campo          varchar2(256)
                                       , conteudo       varchar2(4000)
                                       , orig_proc      number(1) );
--
   type t_tab_csf_nfinfor_adic is table of tab_csf_nfinfor_adic index by binary_integer;
   vt_tab_csf_nfinfor_adic t_tab_csf_nfinfor_adic;
--
--| informações de cobrança da nota fiscal
   -- Nível 1
   type tab_csf_nota_fiscal_cobr is record ( cpf_cnpj_emit    varchar2(14)
                                           , dm_ind_emit      number(1)
                                           , dm_ind_oper      number(1)
                                           , cod_part         varchar2(60)
                                           , cod_mod          varchar2(2)
                                           , serie            varchar2(3)
                                           , nro_nf           number(9)
                                           , nro_fat          varchar2(60)
                                           , dm_ind_emit_tit  number(1)
                                           , dm_ind_tit       varchar2(2)
                                           , vl_orig          number(15,2)
                                           , vl_desc          number(15,2)
                                           , vl_liq           number(15,2)
                                           , descr_tit        varchar2(255) );
--
   type t_tab_csf_nota_fiscal_cobr is table of tab_csf_nota_fiscal_cobr index by binary_integer;
   vt_tab_csf_nota_fiscal_cobr t_tab_csf_nota_fiscal_cobr;
--
--| informações das duplicatas da cobrança da nota fiscal
   -- Nível 2
   type tab_csf_nf_cobr_dup is record ( cpf_cnpj_emit  varchar2(14)
                                      , dm_ind_emit    number(1)
                                      , dm_ind_oper    number(1)
                                      , cod_part       varchar2(60)
                                      , cod_mod        varchar2(2)
                                      , serie          varchar2(3)
                                      , nro_nf         number(9)
                                      , nro_fat        varchar2(60)
                                      , nro_parc       varchar2(60)
                                      , dt_vencto      date
                                      , vl_dup         number(15,2) );
--
   type t_tab_csf_nf_cobr_dup is table of tab_csf_nf_cobr_dup index by binary_integer;
   vt_tab_csf_nf_cobr_dup t_tab_csf_nf_cobr_dup;
--
--| informações do local de coleta e entrega da nota fiscal local - campos flex field
   -- Nível 1
   type tab_csf_nota_fiscal_local_ff is record ( cpf_cnpj_emit  varchar2(14)
                                               , dm_ind_emit    number(1)
                                               , dm_ind_oper    number(1)
                                               , cod_part       varchar2(60)
                                               , cod_mod        varchar2(2)
                                               , serie          varchar2(3)
                                               , nro_nf         number(9)
                                               , dm_tipo_local  number(1)
                                               , atributo       varchar2(30)
                                               , valor          varchar2(255)
                                               );
--
   type t_tab_csf_nota_fiscal_local_ff is table of tab_csf_nota_fiscal_local_ff index by binary_integer;
   vt_tab_csf_nota_fiscal_localff t_tab_csf_nota_fiscal_local_ff;
--
--| informações do local de coleta e entrega da nota fiscal
   -- Nível 1
   type tab_csf_nota_fiscal_local is record ( cpf_cnpj_emit  varchar2(14)
                                            , dm_ind_emit    number(1)
                                            , dm_ind_oper    number(1)
                                            , cod_part       varchar2(60)
                                            , cod_mod        varchar2(2)
                                            , serie          varchar2(3)
                                            , nro_nf         number(9)
                                            , dm_tipo_local  number(1)
                                            , cnpj           varchar2(14)
                                            , lograd         varchar2(60)
                                            , nro            varchar2(10)
                                            , compl          varchar2(60)
                                            , bairro         varchar2(60)
                                            , cidade         varchar2(60)
                                            , cidade_ibge    number(7)
                                            , uf             varchar2(2)
                                            , dm_ind_carga   number(1)
                                            , cpf            varchar2(11)
                                            , ie             varchar2(15)
                                            );
--
   type t_tab_csf_nota_fiscal_local is table of tab_csf_nota_fiscal_local index by binary_integer;
   vt_tab_csf_nota_fiscal_local t_tab_csf_nota_fiscal_local;
--
--| informações do transporte da nota fiscal
   -- Nível 1
   type tab_csf_nota_fiscal_transp is record ( cpf_cnpj_emit    varchar2(14)
                                             , dm_ind_emit      number(1)
                                             , dm_ind_oper      number(1)
                                             , cod_part         varchar2(60)
                                             , cod_mod          varchar2(2)
                                             , serie            varchar2(3)
                                             , nro_nf           number(9)
                                             , dm_mod_frete     number(1)
                                             , cnpj_cpf         varchar2(14)
                                             , cod_part_transp  varchar2(60)
                                             , nome             varchar2(60)
                                             , ie               varchar2(14)
                                             , ender            varchar2(60)
                                             , cidade           varchar2(60)
                                             , cidade_ibge      number(7)
                                             , uf               varchar2(2)
                                             , vl_serv          number(15,2)
                                             , vl_basecalc_ret  number(15,2)
                                             , aliqicms_ret     number(5,2)
                                             , vl_icms_ret      number(15,2)
                                             , cfop             number(4)
                                             , cpf_mot          number(11)
                                             , nome_mot         varchar2(60) );
--
   type t_tab_csf_nota_fiscal_transp is table of tab_csf_nota_fiscal_transp index by binary_integer;
   vt_tab_csf_nota_fiscal_transp t_tab_csf_nota_fiscal_transp;
--
--| informações de veículos utilizados no transporte da nota fiscal
   -- Nível 2
   type tab_csf_nftransp_veic is record ( cpf_cnpj_emit  varchar2(14)
                                        , dm_ind_emit    number(1)
                                        , dm_ind_oper    number(1)
                                        , cod_part       varchar2(60)
                                        , cod_mod        varchar2(2)
                                        , serie          varchar2(3)
                                        , nro_nf         number(9)
                                        , dm_tipo        number(1)
                                        , placa          varchar2(8)
                                        , uf             varchar2(2)
                                        , rntc           varchar2(20)
                                        , vagao          varchar2(20)
                                        , balsa          varchar2(20) );
--
   type t_tab_csf_nftransp_veic is table of tab_csf_nftransp_veic index by binary_integer;
   vt_tab_csf_nftransp_veic t_tab_csf_nftransp_veic;
--
--| informações de volumes de transporte da nota fiscal
   -- Nível 2
   type tab_csf_nftransp_vol is record ( cpf_cnpj_emit  varchar2(14)
                                       , dm_ind_emit    number(1)
                                       , dm_ind_oper    number(1)
                                       , cod_part       varchar2(60)
                                       , cod_mod        varchar2(2)
                                       , serie          varchar2(3)
                                       , nro_nf         number(9)
                                       , nro_vol        varchar2(60)
                                       , qtdevol        number(15)
                                       , especie        varchar2(60)
                                       , marca          varchar2(60)
                                       , peso_bruto     number(15,3)
                                       , peso_liq       number(15,3) );
--
   type t_tab_csf_nftransp_vol is table of tab_csf_nftransp_vol index by binary_integer;
   vt_tab_csf_nftransp_vol t_tab_csf_nftransp_vol;
--
--| informações de lacres do volume de transporte da nota fiscal
   -- Nível 3
   type tab_csf_nftranspvol_lacre is record ( cpf_cnpj_emit  varchar2(14)
                                            , dm_ind_emit    number(1)
                                            , dm_ind_oper    number(1)
                                            , cod_part       varchar2(60)
                                            , cod_mod        varchar2(2)
                                            , serie          varchar2(3)
                                            , nro_nf         number(9)
                                            , nro_vol        varchar2(60)
                                            , nro_lacre      varchar2(60) );
--
   type t_tab_csf_nftranspvol_lacre is table of tab_csf_nftranspvol_lacre index by binary_integer;
   vt_tab_csf_nftranspvol_lacre t_tab_csf_nftranspvol_lacre;
--
--| informações Complementares do Item da NFe
   -- Nível 1
   type tab_csf_itemnfe_compl_serv is record ( cpf_cnpj_emit           varchar2(14)
                                             , dm_ind_emit             number(1)
                                             , dm_ind_oper             number(1)
                                             , cod_part                varchar2(60)
                                             , cod_mod                 varchar2(2)
                                             , serie                   varchar2(3)
                                             , nro_nf                  number(9)
                                             , nro_item                number
                                             , vl_deducao              number(15,2)
                                             , vl_outra_ret            number(15,2)
                                             , vl_desc_incondicionado  number(15,2)
                                             , vl_desc_condicionado    number(15,2)
                                             , cod_trib_municipio      varchar2(20)
                                             , cod_siscomex            number(4)
                                             , nro_proc                varchar2(30)
                                             , dm_ind_incentivo        number(1) 
                                             , cod_mun                 varchar2(7));
--
   type t_tab_csf_itemnfe_compl_serv is table of tab_csf_itemnfe_compl_serv index by binary_integer;
   vt_tab_csf_itemnfe_compl_serv t_tab_csf_itemnfe_compl_serv;
--
--| informações dos itens da nota fiscal
   -- Nível 1
   type tab_csf_item_nota_fiscal is record ( cpf_cnpj_emit        varchar2(14)
                                           , dm_ind_emit          number(1)
                                           , dm_ind_oper          number(1)
                                           , cod_part             varchar2(60)
                                           , cod_mod              varchar2(2)
                                           , serie                varchar2(3)
                                           , nro_nf               number(9)
                                           , nro_item             number
                                           , cod_item             varchar2(60)
                                           , dm_ind_mov           number(1)
                                           , cean                 varchar2(14)
                                           , descr_item           varchar2(120)
                                           , cod_ncm              varchar2(8)
                                           , genero               number(2)
                                           , cod_ext_ipi          varchar2(3)
                                           , cfop                 number(4)
                                           , unid_com             varchar2(6)
                                           , qtde_comerc          number(15,4)
                                           , vl_unit_comerc       number(22,10)
                                           , vl_item_bruto        number(15,2)
                                           , cean_trib            varchar2(14)
                                           , unid_trib            varchar2(6)
                                           , qtde_trib            number(15,4)
                                           , vl_unit_trib         number(22,10)
                                           , vl_frete             number(15,2)
                                           , vl_seguro            number(15,2)
                                           , vl_desc              number(15,2)
                                           , vl_outro             number(15,2)
                                           , dm_ind_tot           number(1)
                                           , infadprod            varchar2(500)
                                           , orig                 number(1)
                                           , dm_mod_base_calc     number(1)
                                           , dm_mod_base_calc_st  number(1)
                                           , cnpj_produtor        varchar2(14)
                                           , qtde_selo_ipi        number(12)
                                           , vl_desp_adu          number(15,2)
                                           , vl_iof               number(15,2)
                                           , cl_enq_ipi           varchar2(5)
                                           , cod_selo_ipi         varchar2(10)
                                           , cod_enq_ipi          varchar2(3)
                                           , cidade_ibge          number(7)
                                           , cd_lista_serv        number(4)
                                           , dm_ind_apur_ipi      number(1)
                                           , cod_cta              varchar2(255)
                                           , pedido_compra        varchar2(15)
                                           , item_pedido_compra   number(6)
                                           , dm_mot_des_icms      number(2)
                                           , dm_cod_trib_issqn    varchar2(1) );
--
   type t_tab_csf_item_nota_fiscal is table of tab_csf_item_nota_fiscal index by binary_integer;
   vt_tab_csf_item_nota_fiscal t_tab_csf_item_nota_fiscal;
--
--| informações dos itens da nota fiscal - campos flex field
   -- Nível 1
   type tab_csf_item_nota_fiscal_ff is record ( cpf_cnpj_emit        varchar2(14)
                                              , dm_ind_emit          number(1)
                                              , dm_ind_oper          number(1)
                                              , cod_part             varchar2(60)
                                              , cod_mod              varchar2(2)
                                              , serie                varchar2(3)
                                              , nro_nf               number(9)
                                              , nro_item             number
                                              , cod_item             varchar2(60)
                                              , atributo             varchar2(30)
                                              , valor                varchar2(255));
--
   type t_tab_csf_item_nota_fiscal_ff is table of tab_csf_item_nota_fiscal_ff index by binary_integer;
   vt_tab_csf_item_nota_fiscal_ff t_tab_csf_item_nota_fiscal_ff;
--
--| informações de impostos do item da nota fiscal
   -- Nível 2
   type tab_csf_imp_itemnf is record ( cpf_cnpj_emit        varchar2(14)
                                     , dm_ind_emit          number(1)
                                     , dm_ind_oper          number(1)
                                     , cod_part             varchar2(60)
                                     , cod_mod              varchar2(2)
                                     , serie                varchar2(3)
                                     , nro_nf               number(9)
                                     , nro_item             number
                                     , cod_imposto          number(3)
                                     , dm_tipo              number(1)
                                     , cod_st               varchar2(3)
                                     , vl_base_calc         number(15,2)
                                     , aliq_apli            number(7,4)
                                     , vl_imp_trib          number(15,2)
                                     , perc_reduc           number(5,2)
                                     , perc_adic            number(5,2)
                                     , qtde_base_calc_prod  number(16,4)
                                     , vl_aliq_prod         number(15,4)
                                     , perc_bc_oper_prop    number(5,2)
                                     , ufst                 varchar2(2)
                                     , vl_bc_st_ret         number(15,2)
                                     , vl_icmsst_ret        number(15,2)
                                     , vl_bc_st_dest        number(15,2)
                                     , vl_icmsst_dest       number(15,2) );
--
   type t_tab_csf_imp_itemnf is table of tab_csf_imp_itemnf index by binary_integer;
   vt_tab_csf_imp_itemnf t_tab_csf_imp_itemnf;
--
--| informações de impostos do item da nota fiscal - campos flex field
   -- Nível 2
   type tab_csf_imp_itemnf_ff is record ( cpf_cnpj_emit  varchar2(14)
                                        , dm_ind_emit    number(1)
                                        , dm_ind_oper    number(1)
                                        , cod_part       varchar2(60)
                                        , cod_mod        varchar2(2)
                                        , serie          varchar2(3)
                                        , nro_nf         number(9)
                                        , nro_item       number
                                        , cod_imposto    number(3)
                                        , dm_tipo        number(1)
                                        , atributo       varchar2(30)
                                        , valor          varchar2(255) );
--
   type t_tab_csf_imp_itemnf_ff is table of tab_csf_imp_itemnf_ff index by binary_integer;
   vt_tab_csf_imp_itemnf_ff t_tab_csf_imp_itemnf_ff;
--
--| informações de grupo de tributação do imposto ICMS para UF do destinatário do item da nota fiscal
   -- Nível 2
   type tab_csf_imp_itemnficmsdest is record ( cpf_cnpj_emit           varchar2(14)
                                             , dm_ind_emit             number(1)
                                             , dm_ind_oper             number(1)
                                             , cod_part                varchar2(60)
                                             , cod_mod                 varchar2(2)
                                             , serie                   varchar2(3)
                                             , nro_nf                  number(9)
                                             , nro_item                number
                                             , cod_imposto             number(3)
                                             , dm_tipo                 number(1)
                                             , vl_bc_uf_dest           number(15,2)
                                             , perc_icms_uf_dest       number(7,4)
                                             , perc_icms_inter         number(7,4)
                                             , perc_icms_inter_part    number(7,4)
                                             , vl_icms_uf_dest         number(15,2)
                                             , vl_icms_uf_remet        number(15,2)
                                             , perc_comb_pobr_uf_dest  number(7,4)
                                             , vl_comb_pobr_uf_dest    number(15,2) );
--
   type t_tab_csf_imp_itemnficmsdest is table of tab_csf_imp_itemnficmsdest index by binary_integer;
   vt_tab_csf_imp_itemnficmsdest t_tab_csf_imp_itemnficmsdest;
--
--| informações de impostos da partilha do do item da nota fiscal - campos flex field
   -- Nível 2
   type tab_csf_impitnficmsdest_ff is record ( cpf_cnpj_emit  varchar2(14)
                                             , dm_ind_emit    number(1)
                                             , dm_ind_oper    number(1)
                                             , cod_part       varchar2(60)
                                             , cod_mod        varchar2(2)
                                             , serie          varchar2(3)
                                             , nro_nf         number(9)
                                             , nro_item       number
                                             , cod_imposto    number(3)
                                             , dm_tipo        number(1)
                                             , atributo       varchar2(30)
                                             , valor          varchar2(255)
                                             );
--
   type t_tab_csf_impitnficmsdest_ff is table of tab_csf_impitnficmsdest_ff index by binary_integer;
   vt_tab_csf_impitnficmsdest_ff t_tab_csf_impitnficmsdest_ff;
--
--| informações do detalhamento do NCM: NVE
   -- Nível 2
   type tab_csf_itemnf_nve is record ( cpf_cnpj_emit        varchar2(14)
                                     , dm_ind_emit          number(1)
                                     , dm_ind_oper          number(1)
                                     , cod_part             varchar2(60)
                                     , cod_mod              varchar2(2)
                                     , serie                varchar2(3)
                                     , nro_nf               number(9)
                                     , nro_item             number
                                     , nve                  varchar2(6) );
--
   type t_tab_csf_itemnf_nve is table of tab_csf_itemnf_nve index by binary_integer;
   vt_tab_csf_itemnf_nve t_tab_csf_itemnf_nve;
--
--| informações do Controle de Exportação por Item
   -- Nível 2
   type tab_csf_itemnf_export is record ( cpf_cnpj_emit        varchar2(14)
                                        , dm_ind_emit          number(1)
                                        , dm_ind_oper          number(1)
                                        , cod_part             varchar2(60)
                                        , cod_mod              varchar2(2)
                                        , serie                varchar2(3)
                                        , nro_nf               number(9)
                                        , nro_item             number
                                        , num_acdraw           number(11)
                                        , num_reg_export       number(12)
                                        , chv_nfe_export       varchar2(44)
                                        , qtde_export          number(15,4));
--
   type t_tab_csf_itemnf_export is table of tab_csf_itemnf_export index by binary_integer;
   vt_tab_csf_itemnf_export t_tab_csf_itemnf_export;
--
--| Informações complementares do item da nota fiscal.
   -- Nível 3
   type tab_csf_itemnf_export_compl is record ( cpf_cnpj_emit varchar2(14)
                                              , dm_ind_emit   number(1)
                                              , dm_ind_oper   number(1)
                                              , cod_part      varchar2(60)
                                              , cod_mod       varchar2(2)
                                              , serie         varchar2(3)
                                              , nro_nf        number(9)
                                              , nro_item      number
                                              , num_acdraw    number(11)
                                              , dm_ind_doc    number(1)
                                              , nro_de        varchar2(14)
                                              , dt_de         date
                                              , dm_nat_exp    number(1)
                                              , nro_re        number(12)
                                              , dt_re         date
                                              , chc_emb       varchar2(18)
                                              , dt_chc        date
                                              , dt_avb        date
                                              , dm_tp_chc     varchar2(2)
                                              , nr_memo       number
                                              );
   --
   type t_tab_csf_itemnf_export_compl is table of tab_csf_itemnf_export_compl index by binary_integer;
   vt_tab_csf_itemnf_export_compl t_tab_csf_itemnf_export_compl;
--
--| registros de combustíveis do item da nota fiscal
   -- Nível 2
   type tab_csf_itemnf_comb is record ( cpf_cnpj_emit         varchar2(14)
                                      , dm_ind_emit           number(1)
                                      , dm_ind_oper           number(1)
                                      , cod_part              varchar2(60)
                                      , cod_mod               varchar2(2)
                                      , serie                 varchar2(3)
                                      , nro_nf                number(9)
                                      , nro_item              number
                                      , codprodanp            number(9)
                                      , codif                 number(21)
                                      , qtde_temp             number(16,4)
                                      , qtde_bc_cide          number(16,4)
                                      , vl_aliq_prod_cide     number(15,4)
                                      , vl_cide               number(15,2)
                                      , vl_base_calc_icms     number(15,2)
                                      , vl_icms               number(15,2)
                                      , vl_base_calc_icms_st  number(15,2)
                                      , vl_icms_st            number(15,2)
                                      , vl_bc_icms_st_dest    number(15,2)
                                      , vl_icms_st_dest       number(15,2)
                                      , vl_bc_icms_st_cons    number(15,2)
                                      , vl_icms_st_cons       number(15,2)
                                      , uf_cons               varchar2(2)
                                      , nro_passe             varchar2(255) );
--
   type t_tab_csf_itemnf_comb is table of tab_csf_itemnf_comb index by binary_integer;
   vt_tab_csf_itemnf_comb t_tab_csf_itemnf_comb;
--
--| registros de combustíveis do item da nota fiscal - campos Flex Field
   -- Nível 3
   type tab_csf_itemnf_comb_ff is record ( cpf_cnpj_emit         varchar2(14)
                                          , dm_ind_emit           number(1)
                                          , dm_ind_oper           number(1)
                                          , cod_part              varchar2(60)
                                          , cod_mod               varchar2(2)
                                          , serie                 varchar2(3)
                                          , nro_nf                number(9)
                                          , nro_item              number
                                          , atributo              varchar2(30)
                                          , valor                 varchar2(255) );
--
   type t_tab_csf_itemnf_comb_ff is table of tab_csf_itemnf_comb_ff index by binary_integer;
   vt_tab_csf_itemnf_comb_ff t_tab_csf_itemnf_comb_ff;
--
--| informações de veículos do item da nota fiscal
   -- Nível 2
   type tab_csf_itemnf_veic is record ( cpf_cnpj_emit     varchar2(14)
                                      , dm_ind_emit       number(1)
                                      , dm_ind_oper       number(1)
                                      , cod_part          varchar2(60)
                                      , cod_mod           varchar2(2)
                                      , serie             varchar2(3)
                                      , nro_nf            number(9)
                                      , nro_item          number
                                      , dm_tp_oper        number(1)
                                      , dm_ind_veic_oper  number(1)
                                      , chassi            varchar2(17)
                                      , cod_cor           varchar2(4)
                                      , descr_cor         varchar2(40)
                                      , potencia_motor    varchar2(4)
                                      , cm3               varchar2(4)
                                      , peso_liq          varchar2(9)
                                      , peso_bruto        varchar2(9)
                                      , nro_serie         varchar2(9)
                                      , tipo_combust      varchar2(8)
                                      , nro_motor         varchar2(21)
                                      , cmkg              varchar2(9)
                                      , dist_entre_eixo   varchar2(4)
                                      , renavam           varchar2(11)
                                      , ano_mod           number(4)
                                      , ano_fabr          number(4)
                                      , tp_pintura        varchar2(1)
                                      , tp_veiculo        number(2)
                                      , esp_veiculo       number(1)
                                      , vin               varchar2(1)
                                      , dm_cond_veic      number(1)
                                      , cod_marca_modelo  number(6)
                                      , cilin             number(4)
                                      , tp_comb           varchar2(2)
                                      , cmt               varchar2(9)
                                      , cod_cor_detran    varchar2(2)
                                      , cap_max_lotacao   number(3)
                                      , dm_tp_restricao   number(1) );
--
   type t_tab_csf_itemnf_veic is table of tab_csf_itemnf_veic index by binary_integer;
   vt_tab_csf_itemnf_veic t_tab_csf_itemnf_veic;
--
--| informações de medicamentos da nota fiscal
   -- Nível 2
   type tab_csf_itemnf_med is record ( cpf_cnpj_emit  varchar2(14)
                                     , dm_ind_emit    number(1)
                                     , dm_ind_oper    number(1)
                                     , cod_part       varchar2(60)
                                     , cod_mod        varchar2(2)
                                     , serie          varchar2(3)
                                     , nro_nf         number(9)
                                     , nro_item       number
                                     , nro_lote       varchar2(20)
                                     , dm_tp_prod     number(1)
                                     , dm_ind_med     number(1)
                                     , qtde_lote      number(11,3)
                                     , dt_fabr        date
                                     , dt_valid       date
                                     , vl_tab_max     number(15,2) );
--
   type t_tab_csf_itemnf_med is table of tab_csf_itemnf_med index by binary_integer;
   vt_tab_csf_itemnf_med t_tab_csf_itemnf_med;
--
--| registros de Medicadmentos do item da nota fiscal - campos Flex Field
   -- Nível 3
   type tab_csf_itemnf_med_ff is record ( cpf_cnpj_emit         varchar2(14)
                                        , dm_ind_emit           number(1)
                                        , dm_ind_oper           number(1)
                                        , cod_part              varchar2(60)
                                        , cod_mod               varchar2(2)
                                        , serie                 varchar2(3)
                                        , nro_nf                number(9)
                                        , nro_item              number
                                        , nro_lote              varchar2(20)
                                        , atributo              varchar2(30)
                                        , valor                 varchar2(255) 
                                        );
--
   type t_tab_csf_itemnf_med_ff is table of tab_csf_itemnf_med_ff index by binary_integer;
   vt_tab_csf_itemnf_med_ff t_tab_csf_itemnf_med_ff;
--
--| informações de armamentos do item da nota fiscal
   -- Nível 2
   type tab_csf_itemnf_arma is record ( cpf_cnpj_emit  varchar2(14)
                                      , dm_ind_emit    number(1)
                                      , dm_ind_oper    number(1)
                                      , cod_part       varchar2(60)
                                      , cod_mod        varchar2(2)
                                      , serie          varchar2(3)
                                      , nro_nf         number(9)
                                      , nro_item       number
                                      , dm_ind_arm     number(1)
                                      , nro_serie      number(15)
                                      , nro_cano       number(15)
                                      , descr_compl    varchar2(255) );
--
   type t_tab_csf_itemnf_arma is table of tab_csf_itemnf_arma index by binary_integer;
   vt_tab_csf_itemnf_arma t_tab_csf_itemnf_arma;
--
--| informações de declarações de importação do item da nota fiscal
   -- Nível 2
   type tab_csf_itemnf_dec_impor is record ( cpf_cnpj_emit    varchar2(14)
                                           , dm_ind_emit      number(1)
                                           , dm_ind_oper      number(1)
                                           , cod_part         varchar2(60)
                                           , cod_mod          varchar2(2)
                                           , serie            varchar2(3)
                                           , nro_nf           number(9)
                                           , nro_item         number
                                           , nro_di           varchar2(15)
                                           , dt_di            date
                                           , local_desemb     varchar2(60)
                                           , uf_desemb        varchar2(2)
                                           , dt_desemb        date
                                           , cod_part_export  varchar2(60)
                                           , dm_cod_doc_imp   number(1) );
--
   type t_tab_csf_itemnf_dec_impor is table of tab_csf_itemnf_dec_impor index by binary_integer;
   vt_tab_csf_itemnf_dec_impor t_tab_csf_itemnf_dec_impor;
--
--| informações de declarações de importação do item da nota fiscal - campos Flex Field
   -- Nível 3
   type tab_csf_itemnf_dec_impor_ff is record ( cpf_cnpj_emit    varchar2(14)
                                               , dm_ind_emit      number(1)
                                               , dm_ind_oper      number(1)
                                               , cod_part         varchar2(60)
                                               , cod_mod          varchar2(2)
                                               , serie            varchar2(3)
                                               , nro_nf           number(9)
                                               , nro_item         number
                                               , nro_di           varchar2(15) 
                                               , atributo         varchar2(30)
                                               , valor            varchar2(255) );
--
   type t_tab_csf_itemnf_dec_impor_ff is table of tab_csf_itemnf_dec_impor_ff index by binary_integer;
   vt_tab_csf_itemnf_dec_impor_ff t_tab_csf_itemnf_dec_impor_ff;
--
--| informações das adições da declaração de importação do item da nota fiscal
   -- Nível 3
   type tab_csf_itemnfdi_adic is record ( cpf_cnpj_emit   varchar2(14)
                                        , dm_ind_emit     number(1)
                                        , dm_ind_oper     number(1)
                                        , cod_part        varchar2(60)
                                        , cod_mod         varchar2(2)
                                        , serie           varchar2(3)
                                        , nro_nf          number(9)
                                        , nro_item        number
                                        , nro_di          varchar2(15)
                                        , nro_adicao      number(3)
                                        , nro_seq_adic    number(3)
                                        , cod_fabricante  varchar2(60)
                                        , vl_desc_di      number(15,2)
                                        );
--
   type t_tab_csf_itemnfdi_adic is table of tab_csf_itemnfdi_adic index by binary_integer;
   vt_tab_csf_itemnfdi_adic t_tab_csf_itemnfdi_adic;
--
--| informações das adições da declaração de importação do item da nota fiscal
   -- Nível 3
   type tab_csf_itemnfdi_adic_ff is record ( cpf_cnpj_emit   varchar2(14)
                                           , dm_ind_emit     number(1)
                                           , dm_ind_oper     number(1)
                                           , cod_part        varchar2(60)
                                           , cod_mod         varchar2(2)
                                           , serie           varchar2(3)
                                           , nro_nf          number(9)
                                           , nro_item        number
                                           , nro_di          varchar2(15)
                                           , nro_adicao      number(3)
                                           , atributo        varchar2(30)
                                           , valor           varchar2(255)
                                           );
--
   type t_tab_csf_itemnfdi_adic_ff is table of tab_csf_itemnfdi_adic_ff index by binary_integer;
   vt_tab_csf_itemnfdi_adic_ff t_tab_csf_itemnfdi_adic_ff;
--
--| Informações do diferencial de aliquota  do item da nota fiscal
  type tab_csf_itemnf_dif_aliq is record ( cpf_cnpj_emit    varchar2(14)
                                         , dm_ind_emit      number(1)
                                         , dm_ind_oper      number(1)
                                         , cod_part         varchar2(60)
                                         , cod_mod          varchar2(2)
                                         , serie            varchar2(3)
                                         , nro_nf           number(9)
                                         , nro_item         number
                                         , aliq_orig        number(5,2)
                                         , aliq_ie          number(5,2)
                                         , vl_bc_icms       number(15,2)
                                         , vl_dif_aliq      number(15,2)
                                         );
--
  type t_tab_csf_itemnf_dif_aliq is table of tab_csf_itemnf_dif_aliq index by binary_integer;
  vt_tab_csf_itemnf_dif_aliq t_tab_csf_itemnf_dif_aliq;
--
--| Informações do Rastreabilidade de produto
  type tab_csf_itemnf_rastreab is record ( cpf_cnpj_emit    varchar2(14)
                                         , dm_ind_emit      number(1)
                                         , dm_ind_oper      number(1)
                                         , cod_part         varchar2(60)
                                         , cod_mod          varchar2(2)
                                         , serie            varchar2(3)
                                         , nro_nf           number(9)
                                         , nro_item         number
                                         , nro_lote         varchar2(20)
                                         , qtde_lote        number(11,3)
                                         , dt_fabr          date
                                         , dt_valid         date
                                         , cod_agreg        varchar2(20)
                                         );
--
  type t_tab_csf_itemnf_rastreab is table of tab_csf_itemnf_rastreab index by binary_integer;
  vt_tab_csf_itemnf_rastreab t_tab_csf_itemnf_rastreab;
--
--| Tabela/view de Ressarcimento de ICMS em operações com substituição Tributária do Item da Nota Fiscal
  type tab_csf_itemnf_res_icms_st is record ( cpf_cnpj_emit                varchar2(14)
                                            , dm_ind_emit                  number(1)
                                            , dm_ind_oper                  number(1)
                                            , cod_part                     varchar2(60)
                                            , cod_mod                      varchar2(2)
                                            , serie                        varchar2(3)
                                            , nro_nf                       number(9)
                                            , nro_item                     number(3)
                                            , cod_mod_e                    varchar2(2)
                                            , num_doc_ult_e                number(9)
                                            , ser_ult_e                    varchar2(3)
                                            , dt_ult_e                     date
                                            , cod_part_e                   varchar2(60)
                                            , quant_ult_e                  number(12,3)
                                            , vl_unit_ult_e                number(15,3)
                                            , vl_unit_bc_st                number(15,3)
                                            , vl_unit_limite_bc_icms_ult_e number(15,2)
                                            , vl_unit_icms_ult_e           number(15,3)
                                            , aliq_st_ult_e                number(3,2)
                                            , vl_unit_res                  number(15,3)
                                            , dm_cod_resp_ret              number(1)
                                            , dm_cod_mot_res               number(1)
                                            , chave_nfe_ret                varchar2(44)
                                            , cod_part_nfe_ret             varchar2(60)
                                            , ser_nfe_ret                  varchar2(3)
                                            , num_nfe_ret                  number(9)
                                            , item_nfe_ret                 number(3)
                                            , dm_cod_da                    varchar2(1)
                                            , num_da                       varchar2(255)
                                            , chave_nfe_ult_e              varchar2(44)
                                            , num_item_ult_e               number(3)
                                            , vl_unit_bc_icms_ult_e        number(15,3)
                                            , aliq_icms_ult_e              number(5,2)
                                            , vl_unit_res_fcp_st           number(15,2)
                                            );
--
  type t_tab_csf_itemnf_res_icms_st is table of tab_csf_itemnf_res_icms_st index by binary_integer;
  vt_tab_csf_itemnf_res_icms_st t_tab_csf_itemnf_res_icms_st;
--
--| Informações do ajuste  do item da nota fiscal
  type tab_csf_inf_prov_docto_fisc is record ( cpf_cnpj_emit    varchar2(14)
                                             , dm_ind_emit      number(1)
                                             , dm_ind_oper      number(1)
                                             , cod_part         varchar2(60)
                                             , cod_mod          varchar2(2)
                                             , serie            varchar2(3)
                                             , nro_nf           number(9)
                                             , cod_obs          varchar2(6)
                                             , cod_aj           varchar2(10)
                                             , nro_item         number
                                             , descr_compl_aj   varchar2(255)
                                             , vl_bc_icms       number(15,2)
                                             , aliq_icms        number(5,2)
                                             , vl_icms          number(15,2) 
                                             , vl_outros        number(15,2)
                                             );
--
  type t_tab_csf_inf_prov_docto_fisc is table of tab_csf_inf_prov_docto_fisc index by binary_integer;
  vt_tab_csf_inf_prov_docto_fisc t_tab_csf_inf_prov_docto_fisc;
--

--| informações de aquisição de cana-de-açúcar
    type tab_csf_nf_aquis_cana is record ( cpf_cnpj_emit   varchar2(14)
                                         , dm_ind_emit     number(1)
                                         , dm_ind_oper     number(1)
                                         , cod_part        varchar2(60)
                                         , cod_mod         varchar2(2)
                                         , serie           varchar2(3)
                                         , nro_nf          number(9)
                                         , safra           varchar2(9)
                                         , mes_ano_ref     varchar2(9)
                                         , qtde_total_mes  number(21,10)
                                         , qtde_total_ant  number(21,10)
                                         , qtde_total_ger  number(21,10)
                                         , vl_forn         number(15,2)
                                         , vl_total_ded    number(15,2)
                                         , vl_liq_forn     number(15,2) );
--
   type t_tab_csf_nf_aquis_cana is table of tab_csf_nf_aquis_cana index by binary_integer;
   vt_tab_csf_nf_aquis_cana t_tab_csf_nf_aquis_cana;
--
--| informações de aquisição de cana-de-açúcar por dia.
   type tab_csf_nf_aquis_cana_dia is record ( cpf_cnpj_emit   varchar2(14)
                                            , dm_ind_emit     number(1)
                                            , dm_ind_oper     number(1)
                                            , cod_part        varchar2(60)
                                            , cod_mod         varchar2(2)
                                            , serie           varchar2(3)
                                            , nro_nf          number(9)
                                            , safra           varchar2(9)
                                            , mes_ano_ref     varchar2(9)
                                            , dia             number(2)
                                            , qtde            number(21,10) );
--
   type t_tab_csf_nf_aquis_cana_dia is table of tab_csf_nf_aquis_cana_dia index by binary_integer;
   vt_tab_csf_nf_aquis_cana_dia t_tab_csf_nf_aquis_cana_dia;
--
--| informações de dedução da aquisição de cana-de-açúcar
   type tab_csf_nf_aquis_cana_ded is record ( cpf_cnpj_emit   varchar2(14)
                                            , dm_ind_emit     number(1)
                                            , dm_ind_oper     number(1)
                                            , cod_part        varchar2(60)
                                            , cod_mod         varchar2(2)
                                            , serie           varchar2(3)
                                            , nro_nf          number(9)
                                            , safra           varchar2(9)
                                            , mes_ano_ref     varchar2(9)
                                            , deducao         varchar2(60)
                                            , vl_ded          number(15,2) );
--
   type t_tab_csf_nf_aquis_cana_ded is table of tab_csf_nf_aquis_cana_ded index by binary_integer;
   vt_tab_csf_nf_aquis_cana_ded t_tab_csf_nf_aquis_cana_ded;
--
--|  informações de NF de fornecedores a serem impressas na DANFE (Romaneio)
   type tab_csf_inf_nf_romaneio is record ( cpf_cnpj_emit   varchar2(14)
                                          , dm_ind_emit     number(1)
                                          , dm_ind_oper     number(1)
                                          , cod_part        varchar2(60)
                                          , cod_mod         varchar2(2)
                                          , serie           varchar2(3)
                                          , nro_nf          number(9)
                                          , cnpj_cpf_forn   varchar2(20)
                                          , nro_nf_forn     number(9)
                                          , serie_forn      varchar2(3)
                                          , dt_emiss_forn   date
                                          );
--
   type t_tab_csf_inf_nf_romaneio is table of tab_csf_inf_nf_romaneio index by binary_integer;
   vt_tab_csf_inf_nf_romaneio t_tab_csf_inf_nf_romaneio;
--
--|  informações de Agendamento de Transporte
   type tab_csf_nf_agend_transp is record ( cpf_cnpj_emit   varchar2(14)
                                          , dm_ind_emit     number(1)
                                          , dm_ind_oper     number(1)
                                          , cod_part        varchar2(60)
                                          , cod_mod         varchar2(2)
                                          , serie           varchar2(3)
                                          , nro_nf          number(9)
                                          , pedido          varchar2(60)
                                          );
--
   type t_tab_csf_nf_agend_transp is table of tab_csf_nf_agend_transp index by binary_integer;
   vt_tab_csf_nf_agend_transp t_tab_csf_nf_agend_transp;
--
--|  informações de Observações do Agendamento de Transporte
   type tab_csf_nf_obs_agend_transp is record ( cpf_cnpj_emit   varchar2(14)
                                              , dm_ind_emit     number(1)
                                              , dm_ind_oper     number(1)
                                              , cod_part        varchar2(60)
                                              , cod_mod         varchar2(2)
                                              , serie           varchar2(3)
                                              , nro_nf          number(9)
                                              , dm_tipo         varchar2(1)
                                              , codigo          varchar2(30)
                                              , obs             varchar2(500)
                                              );
--
   type t_tab_csf_nf_obs_agend_transp is table of tab_csf_nf_obs_agend_transp index by binary_integer;
   vt_tab_csf_nf_obs_agend_transp t_tab_csf_nf_obs_agend_transp;
--
--| informações para o cancelamento da nota fiscal
   type tab_csf_nota_fiscal_canc is record ( cpf_cnpj_emit  varchar2(14)
                                           , dm_ind_emit    number(1)
                                           , dm_ind_oper    number(1)
                                           , cod_part       varchar2(60)
                                           , cod_mod        varchar2(2)
                                           , serie          varchar2(3)
                                           , nro_nf         number(9)
                                           , dt_canc        date
                                           , justif         varchar2(255) );
--
   type t_tab_csf_nota_fiscal_canc is table of tab_csf_nota_fiscal_canc index by binary_integer;
   vt_tab_csf_nota_fiscal_canc t_tab_csf_nota_fiscal_canc;
--
--| informações para inutilização de nota fiscla
   type tab_csf_inutiliza_nf is record ( cpf_cnpj_emit   varchar2(14)
                                       , ano             number(4)
                                       , serie           varchar2(3)
                                       , nro_ini         number(9)
                                       , nro_fim         number(9)
                                       , justif          varchar2(255)
                                       , dm_st_proc      number(1)
                                       );
--
   type t_tab_csf_inutiliza_nf is table of tab_csf_inutiliza_nf index by binary_integer;
   vt_tab_csf_inutiliza_nf t_tab_csf_inutiliza_nf;
--

--| Informações Complementares de Transporte do Item da Nota Fiscal
   type tab_csf_itemnf_compl_transp is record ( cpf_cnpj_emit   varchar2(14)
                                              , dm_ind_emit     number(1)
                                              , dm_ind_oper     number(1)
                                              , cod_part        varchar2(60)
                                              , cod_mod         varchar2(2)
                                              , serie           varchar2(3)
                                              , nro_nf          number(9)
                                              , nro_item        number
                                              , qtde_prod       number(16,6)
                                              , qtde_emb        number(16,6)
                                              , peso_bruto      number(16,6)
                                              , peso_liq        number(16,6)
                                              , volume          number(16,6)
                                              , s_num_cot       number(20)
                                              , cnl_cli         varchar2(10)
                                              , cnl_cli_des     varchar2(100)
                                              , alq_pis         number(7,3)
                                              , ind_rec_pis     varchar2(1)
                                              , alq_cofins      number(7,3)
                                              , ind_rec_cofins  varchar2(1)
                                              );
--
   type t_tab_csf_itemnf_compl_transp is table of tab_csf_itemnf_compl_transp index by binary_integer;
   vt_tab_csf_itemnf_compl_transp t_tab_csf_itemnf_compl_transp;
--
--| Informações Complementares da Nota Fiscal
   type tab_csf_nota_fiscal_compl is record ( cpf_cnpj_emit        varchar2(14)
                                            , dm_ind_emit          number(1)
                                            , dm_ind_oper          number(1)
                                            , cod_part             varchar2(60)
                                            , cod_mod              varchar2(2)
                                            , serie                varchar2(3)
                                            , nro_nf               number(9)
                                            , nro_chave_nfe        varchar2(44)
                                            , id_erp               number
                                            , sub_serie            number(3)
                                            , cod_infor            varchar2(6)
                                            , cod_cta              varchar2(30)
                                            , cod_cons             varchar2(2)
                                            , dm_tp_ligacao        number(1)
                                            , dm_cod_grupo_tensao  varchar2(2)
                                            , dm_tp_assinante      number(1)
                                            , nro_ord_emb          number
                                            , seq_nro_ord_emb      number
                                            );
--
   type t_tab_csf_nota_fiscal_compl is table of tab_csf_nota_fiscal_compl index by binary_integer;
   vt_tab_csf_nota_fiscal_compl t_tab_csf_nota_fiscal_compl;
--
--| Informações Complementares do Item da Nota Fiscal
   type tab_csf_itemnf_compl is record ( cpf_cnpj_emit   varchar2(14)
                                       , dm_ind_emit     number(1)
                                       , dm_ind_oper     number(1)
                                       , cod_part        varchar2(60)
                                       , cod_mod         varchar2(2)
                                       , serie           varchar2(3)
                                       , nro_nf          number(9)
                                       , nro_item        number
                                       , id_item_erp     number
                                       , cod_class       varchar2(4)
                                       , dm_ind_rec      number(1)
                                       , cod_part_item   varchar2(60)
                                       , dm_ind_rec_com  number(1)
                                       , cod_nat         varchar2(10)
                                       );
--
   type t_tab_csf_itemnf_compl is table of tab_csf_itemnf_compl index by binary_integer;
   vt_tab_csf_itemnf_compl t_tab_csf_itemnf_compl;
--
--
--| informações de cupom fiscal eletronico referenciado
   -- Nível 1
   type tab_csf_cfe_ref is record ( cpf_cnpj_emit         varchar2(14)
                                  , dm_ind_emit           number(1)
                                  , dm_ind_oper           number(1)
                                  , cod_part              varchar2(60)
                                  , cod_mod               varchar2(2)
                                  , serie                 varchar2(3)
                                  , nro_nf                number(9)
                                  , cod_mod_ref           varchar2(2)
                                  , nr_sat                varchar2(9)
                                  , chv_cfe               varchar2(44)
                                  , num_cfe               number(6)
                                  , dt_doc                date
                                  );
--
   type t_tab_csf_cfe_ref is table of tab_csf_cfe_ref index by binary_integer;
   vt_tab_csf_cfe_ref t_tab_csf_cfe_ref;
--

--| informações de CCe
   -- Nível 1
   type tab_csf_nota_fiscal_cce is record ( cpf_cnpj_emit         varchar2(14)
                                          , dm_ind_emit           number(1)
                                          , dm_ind_oper           number(1)
                                          , cod_part              varchar2(60)
                                          , cod_mod               varchar2(2)
                                          , serie                 varchar2(3)
                                          , nro_nf                number(9)
                                          , dm_st_proc            number(2)
                                          , correcao              varchar2(1000)
                                          , cod_msg               varchar2(4)
                                          , motivo_resp           varchar2(4000)
                                          , dt_hr_reg_evento      date
                                          , nro_protocolo         number(15)
                                          , dm_leitura            number(1)
                                          );
--
   type t_tab_csf_nota_fiscal_cce is table of tab_csf_nota_fiscal_cce index by binary_integer;
   vt_tab_csf_nota_fiscal_cce t_tab_csf_nota_fiscal_cce;
--

--| Informações de Consulta de chave de acesso
   -- Nível 1
   type tab_csf_cons_chave_nfe is record ( cpf_cnpj_emit  varchar2(14)
                                         , unid_org       varchar2(20)
                                         , nro_chave_nfe  varchar2(44)
                                         , dm_situacao    number(1)
                                         , cstat          varchar2(3)
                                         , xmotivo        varchar2(255)
                                         , dhrecbto       date
                                         , nprot          varchar2(15)
                                         , dm_leitura     number(1)
                                         );
--
   type t_tab_csf_cons_chave_nfe is table of tab_csf_cons_chave_nfe index by binary_integer;
   vt_tab_csf_cons_chave_nfe t_tab_csf_cons_chave_nfe;
--
--| informações para o cancelamento da nota fiscal
   type tab_csf_nota_fiscal_canc_ff is record ( cpf_cnpj_emit  varchar2(14)
                                           , dm_ind_emit    number(1)
                                           , dm_ind_oper    number(1)
                                           , cod_part       varchar2(60)
                                           , cod_mod        varchar2(2)
                                           , serie          varchar2(3)
                                           , nro_nf         number(9)
                                           , atributo       varchar2(30)
                                           , valor          varchar2(255));
--
   type t_tab_csf_nota_fiscal_canc_ff is table of tab_csf_nota_fiscal_canc_ff index by binary_integer;
   vt_tab_csf_nota_fiscal_canc_ff t_tab_csf_nota_fiscal_canc_ff;
--
--|
   type tab_csf_nota_fiscal_inu_ff is record ( cpf_cnpj_emit  VARCHAR2(14)
                                             , ano            NUMBER(4)
                                             , serie          VARCHAR2(3)
                                             , nro_ini        NUMBER(9)
                                             , nro_fim        NUMBER(9)
                                             , atributo       VARCHAR2(30)
                                             , valor          VARCHAR2(255));
--
   type t_tab_csf_nota_fiscal_inu_ff is table of tab_csf_nota_fiscal_inu_ff index by binary_integer;
   vt_tab_csf_nota_fiscal_inu_ff t_tab_csf_nota_fiscal_inu_ff;
--
--| Tabela com informacões do documento de arrecadação referenciado
   type tab_csf_nota_fiscal_fisco is record ( cpf_cnpj_emit  varchar2(14)
                                            , dm_ind_emit    number(1)
                                            , dm_ind_oper    number(1)
                                            , cod_part       varchar2(60)
                                            , cod_mod        varchar2(2)
                                            , serie          varchar2(3)
                                            , nro_nf         number(9)
                                            , dm_cod_mod_da  number(1)
                                            , orgao_emit     varchar2(60)
                                            , cnpj           varchar2(14)
                                            , matr_agente    varchar2(60)
                                            , nome_agente    varchar2(60)
                                            , fone           varchar2(14)
                                            , uf             varchar2(2)
                                            , nro_dar        varchar2(60)
                                            , dt_emiss       date
                                            , vl_dar         number(15,2)
                                            , repart_emit    varchar2(60)
                                            , dt_pagto       date
                                            , cod_aut_banc   varchar2(256)
                                            , dt_vencto      date );
--
   type t_tab_csf_nota_fiscal_fisco is table of tab_csf_nota_fiscal_fisco index by binary_integer;
   vt_tab_csf_nota_fiscal_fisco t_tab_csf_nota_fiscal_fisco;
--
-------------------------------------------------------------------------------------------------------

   gv_sql            varchar2(4000) := null;
   gv_where          varchar2(4000) := null;
   gn_rel_part       number := 0;
   gd_dt_ini_integr  date := null;
   gv_resumo         log_generico_nf.resumo%type := null;
   gv_cabec_nf       varchar2(4000) := null;
   gd_formato_dt_erp empresa.formato_dt_erp%type := 'dd/mm/rrrr';
   gn_dm_form_dt_erp empresa_integr_banco.dm_form_dt_erp%type;

-------------------------------------------------------------------------------------------------------

   gv_aspas                   char(1) := null;
   gv_nome_dblink             empresa.nome_dblink%type := null;
   gv_owner_obj               empresa.owner_obj%type := null;
   gn_dm_ret_infor_integr     empresa.dm_ret_infor_integr%type := null;
   gv_sist_orig               sist_orig.sigla%type := null;
   gn_dm_ind_emit             nota_fiscal.dm_ind_emit%type := null;
   gv_cd_obj                  obj_integr.cd%type := '6';
   gn_multorg_id              mult_org.id%type;
   gn_empresaintegrbanco_id   empresa_integr_banco.id%type;
   gn_empresa_id              empresa.id%type;
   gv_formato_data            param_global_csf.valor%type := null;
   --
   gv_objeto                  varchar2(300);
   gn_fase                    number;
   --
   info_fechamento number;
-------------------------------------------------------------------------------------------------------

-- Procedimento integra as consultas de NFe com o ERP
procedure pkb_int_csf_cons_sit ( en_empresa_id   in empresa.id%type
                               , ev_nome_dblink  in empresa_integr_banco.nome_dblink%type -- ev_nome_dblink
                               , ev_aspas        in varchar2 -- ev_aspas
                               , ev_owner_obj    in empresa_integr_banco.owner_obj%type -- ev_owner_obj
                               );

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração de Notas Fiscais
procedure pkb_integracao ( ev_sist_orig in varchar2 default null );

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração de Notas Fiscais através do Mult-Org.
--| Esse processo estará sendo executado por JOB SCHEDULER, especifícamente para Ambiente Amazon.
--| A rotina deverá executar o mesmo procedimento da rotina pkb_integracao, porém com a identificação da mult-org.
procedure pkb_integr_multorg ( en_multorg_id in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração de Notas Fiscais por empresa e período
procedure pkb_integr_periodo ( en_empresa_id   in  empresa.id%type
                             , ed_dt_ini       in  date
                             , ed_dt_fin       in  date
                             , en_dm_ind_emit  in  nota_fiscal.dm_ind_emit%type default null
                             );

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração Normal de Notas Fiscais, recuperando todas as empresas
procedure pkb_integr_periodo_normal ( ed_dt_ini       in  date
                                    , ed_dt_fin       in  date
                                    , en_dm_ind_emit  in  nota_fiscal.dm_ind_emit%type default null
                                    );

-------------------------------------------------------------------------------------------------------

--| Procedimento Gera o Retorno para o ERP
procedure pkb_gera_retorno ( ev_sist_orig in varchar2 default null );

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração de Notas Fiscais Eletrônicas de Emissão Própria
-- por meio da integração por Bloco
procedure pkb_int_bloco ( en_paramintegrdados_id  in param_integr_dados.id%type
                        , en_dm_ind_emit          in nota_fiscal.dm_ind_emit%type
                        , ed_dt_ini               in date default null
			, ed_dt_fin               in date default null
			, en_empresa_id           in empresa.id%type default null
                        );

-------------------------------------------------------------------------------------------------------

--| Procedimento Gera o Retorno para o ERP com a Integração em Bloco
procedure pkb_gera_retorno_bloco ( en_paramintegrdados_id in param_integr_dados.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento de integração por período informando todas empresas ativas
procedure pkb_integr_perido_geral ( en_multorg_id in mult_org.id%type
                                  , ed_dt_ini     in date
                                  , ed_dt_fin     in date 
                                  );

-------------------------------------------------------------------------------------------------------

end pk_integr_view;
/
