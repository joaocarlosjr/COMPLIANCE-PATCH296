create or replace package csf_own.pk_csf_api is

------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- Especificação do pacote de integração de notas fiscais para o CSF
------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- Em 07/01/2021   - Luis Marques - 2.9.5-4 / 2.9.6-1 / 2.9.7
-- Redmine #74199  - Alterar regra de validação para notas de importação de legado
-- Rotina Alterada - PKB_INTEGR_NOTA_FISCAL, PKB_INTEGR_NOTA_FISCAL_FF - Incluida variável global "GN_DM_LEGADO" para se utilizado 
--                   na procedure PKB_INTEGR_ITEMNFDI_ADIC.
--                   PKB_INTEGR_ITEMNFDI_ADIC - Incluida Verificação para só efetuar as validações se o documento não for
--                   legado DM_LEGADO = 0.
--                   PKB_VALIDA_INFOR_IMPORTACAO - Colocado para tabela "itemnfdi_adic" como facultativa (alter_join).
--
-- Em 05/01/2021   - João Carlos - 2.9.5-4 / 2.9.6-1 / 2.9.7
-- Redmine #73962  - Criação de validação para ipi devolvido diferente dos itens e do total
-- Rotina Alterada - PKB_VALIDA_TOTAL_NF
--
-- Em 05/01/2021 - Eduardo Linden - 2.9.5-4 / 2.9.6-1 / 2.9.7
-- Redmine #74822 - Falha na execução da query - ORA-01422 - NFe emissão propria (OCQ)
-- Rotina Alterada - PKB_INTEGR_NF_REFEREN => Inclusão nova clausula (nota_fiscal.id) para busca de chave nfe
-- 
-- Em 04/01/2021 - Eduardo Linden - 2.9.5-4 / 2.9.6-1 / 2.9.7
-- Redmine #74792 - Alteração sobre mensagem na rotina de integração de nota referencia 
-- Rotina Alterada - PKB_INTEGR_NF_REFEREN => Alteração do log 'Não encontrada nf escriturada no compliance para a Nro_Chave_NF' de erro de validação para informação.
--
-- Em 21/12/2020   - João Carlos - 2.9.4-6 / 2.9.5-3 / 2.9.6
-- Redmine #74238  - Alteração do tipo de LOG para a validação de VL. UNIT. X QTD de Validação para Erro de Validação.
-- Rotina Alterada - PKB_INTEGR_ITEM_NOTA_FISCAL -> Alterado log de Validação para Erro de Validação
--
-- Em 21/12/2020   - João Carlos - 2.9.4-6 / 2.9.5-3 / 2.9.6
-- Redmine #73027  - Desenvolvido rotina para inserir o valor de cofins majorada de acordo com a parametrização do sistema.
-- Rotina Alterada - PKB_AJUSTA_TOTAL_NF -> Inserida rotina para calcular valor cofins majorado de acordo com o parâmetro
--
-- Em 21/12/2020 - Eduardo Linden - 2.9.4-5 / 2.9.5-2 / 2.9.6
-- Redmine #72729 - NF-e de emissão própria autorizada indevidamente (CERRADÃO)
-- Rotina alterada -  PKB_CONSISTEM_NF => Caso não tenha sido gerado log, e se nota de emissao propria e não de legado, o dm_st_proc passa ser 1 .
--                                        Se a nota não for emissão ou de legado, o dm_st_proc passa a ser 4.
--
-- Em 10/12/2020   - Allan Magrini - 2.9.4-5 / 2.9.5-2 / 2.9.6
-- Redmine #74071  - Registro C113 - Indicador de operação e participante divergentes da nota de origem
-- Rotina Alterada - PKB_INTEGR_NF_REFEREN comentado o select de exception da fase 8.1 e incluida a geração de log de erro se não encontrar a nota.
--
-- Em 09/12/2020   - Wendel Albino - 2.9.4-6 / 2.9.5-3 / 2.9.6
-- Redmine #73490  - Validação de obrigatoriedade de chave X modelo 55 deixou de ser feita.
-- Rotina Alterada - pkb_valida_cria_nro_chave_nfe - inlcuida validacao para nota modelo 55 que nao tenha enviado a chave de acesso na integracao.
--
-- Em 16/11/2020   - Luis Marques - 2.9.4-5 / 2.9.5-2 / 2.9.6
-- Redmine #73138  - Registro analitico não considerando outros valores do item
-- Rotina Alterada - PKB_GERA_REGIST_ANALIT_IMP - Incluido no calculo de base reduzida de icms os campos "vl_frete", 
--                   "vl_seguro" e "vl_desc" do item da nota fiscal.
--
-- Em 16/11/2020   - Joao Carlos - 2.9.4-5 / 2.9.5-2 / 2.9.6
-- Redmine #73332  - Correção na condição do select de and tc.cd_compat = ln.csftipolog_id para and tc.id = ln.csftipolog_id
-- Rotina Alterada - fkg_ver_erro_log_generico
--
-- Em 17/11/2020   - Wendel Albino - 2.9.5-2 / 2.9.6
-- Redmine #73470  -  [Emergencial] Alterar regra para considerar UF do destinatario
-- Rotina Alterada - PKB_GERAR_INFO_TRIB - alteracao do UF do emitente para UF destinatario no select do cursor (campo uf_empresa) e alteracao no 
--                 -   parametro para a chamada da procedure pkb_busca_vlr_aprox_ibpt (ev_uf_empresa ).
--
-- Em 13/11/2020   - Wendel Albino - 2.9.5-2 / 2.9.6
-- Redmine #73193  - Não está preenchendo NOTA_FISCAL.MODELODANFE_ID
-- Rotina Alterada - PKB_INTEGR_NOTA_FISCAL -> alterada a validacao do modelodanfe_id
--
-- Em 13/11/2020   - Wendel Albino - 2.9.5-2 / 2.9.6
-- Redmine #73353  - [EMERGENCIAL] Ajuste de regra de produtos importados
-- Rotina Alterada - pkb_busca_vlr_aprox_ibpt na especificacao e no body : alterado o parametro EN_DM_ID_DEST por EN_ORIG_TRIB_FED 
--                 -  para identificar o valor do tributo FEDERAL(nacional/importado) com base no campo item_nota_fiscal.orig .
--                 - PKB_GERAR_INFO_TRIB -> alteradao o select do cursor para trazer o campo item_nota_fsical.orig como orig_trib_fed 
--                 -  incluido o campo na chamada da procedure pkb_busca_vlr_aprox_ibpt(en_orig_trib_fed  => rec.orig_trib_fed).
--
-- Em 12/11/2020   - Luis Marques - 2.9.5-2 / 2.9.6
-- Redmine #73049  - STATUS DA NFSE NÃO BATE COM O LOG
-- Rotina Alterada - pkb_integr_Imp_ItemNf - Colocada tolerancia para validação de INSS retido por causa do trunc 
--                   usado no REINF para quem informa.
--                   PKB_VALIDA_TOTAL_NF - Colocada tolerancia para INSS, ISS, IRRF, PIS, COFINS retidos.
--
-- Em 09/11/2020   - Wendel Albino - Patch 2.9.5-2 release 2.9.6
-- Redmine #73013/73180 - Informação geral ocasionando erro de validação em NFE
-- Rotina Alterada - PKB_INTEGR_NOTA_FISCAL -> retirado log generico de memoria onde era erro de informacao da tarefa 71745, e retirado o filtro de pessoa_id da tabela empresa.
--                 - alterada a validacao do else para elsif da tarefa 71745 para quando for nf de terceiro e dm_arm_nfe_terc = 1 (emissao de danfe))
--
-- Em 05/11/2020   - Luiz Armando/Luis Marques - 2.9.4-5 / 2.9.5-2 / 2.9.6
-- Redmine #72798  - Falha no registro do evento "Operação não realizada" (SANTA VITORIA)
-- Rotina Alterada - pkb_gera_lote_mde - corrigido cursor "c_mde" para verificar o tipo de evento da sefaz para
--                   registro do evento.
--
-- Em 28/10/2020   - Luis Marques - 2.9.4-5 / 2.9.5-2 / 2.9.6
-- Redmine #72338  - Validação do FCp DIFAL - Total X Itens não está ocorrendo
-- Rotina Alterada - PKB_VALIDA_TOTAL_NF - Incluida verificação de FCP DIFAL se o valor na NOTA_FISCAL_TOTAL bate 
--                   com os valores do item na linha do imposto.
--
-- Em 30/10/2020   - Wendel Albino - Patch 2.9.4-5 , 2.9.5-2 , release 2.9.6
-- Redmine #72960  - Ajustar função que valida se é nota fiscal de serviço
-- Rotina Alterada - PKB_VALIDA_TOTAL_NF  -> alteracao select que valida a variavel vv_cd_lista_serv para retornar apenas 1 linha se tiver item de servico na nota.
--
-- Em 23/10/2020   - Wendel Albino - Patch 2.9.5-1 release 2.9.6
-- Redmine #71745  - Modelos de Danfe personalizados
-- Rotina Alterada - PKB_INTEGR_NOTA_FISCAL -> Na validacao da nota, adotadar as seguintes regras para preencher campo NOTA_FISCAL.MODELODANFE_ID:
--                 -  Se for nota de emissão propria , busca o valor da tabela EMPRESA_PARAM_SERIE.MODELODANFE_ID 
--                      se nao encontrar, busca da EMPRESA.MODELODANFE_ID (confirmar se pode colocar em trigger que define a impressora_id).
--                 -  Se for notas de terceiros, pegar o conteudo de EMPRESA.MODELODANFE_ID.
--
-- Em 22/10/2020   - Wendel Albino - Patch 2.9.5-1 release 2.9.6
-- Redmine #72508  - Erro de validação NF_e - Serviços (Modelo 55)
-- Rotina Alterada - PKB_VALIDA_TOTAL_NF  -> incluida variavel vv_cd_lista_serv que atua na validacao de nota fiscal modelo 55 , servico e de brasilia 
--                 -  pra nao validar valor total do item, pois este valor nao é enviado nesta regra. 
--
-- Em 21/10/2020   - Wendel Albino - 
-- Redmine #72544  - Ajuste em integração de NFe de emissão propria devido falha na solicitação da atividade #69347
-- Rotina Alterada - PKB_INTEGR_ITEM_NOTA_FISCAL_FF - > nova regra de validacao do campo COD_OCOR_AJ_ICMS.
--                 -   Se o campo COD_OCOR_AJ_ICMS vier com 8 posicoes, o código deverá ser buscado na tabela COD_INF_ADIC_VLR_DECL 
--                 -     e seu respectivo ID gravado na ITEM_NOTA_FISCAL.CODINFADICVLRDECL_ID.
--                 -   Caso contrário (tamanho de 10 posicoes), seguir com a pesquisa na COD_OCOR_AJ_ICMS 
--                 -     e gravar seu respectivo ID na ITEM_NOTA_FISCAL.CODOCORAJICMS_ID. 
--
-- Em 16/10/2020   - Luis Marques - 2.9.4-4 / 2.9.5-1 / 2.9.6
-- Redmine #72338  - Validação do FCp - Total X Itens não está ocorrendo
-- Rotina Alterada - PKB_VALIDA_TOTAL_NF - Incluida verificação de FCP, FCP retido p/ subst. tributária e FCP retido 
--                   p/ subst. tributária retido anteriormente se o valor na NOTA_FISCAL_TOTAL bate com os valores 
--                   do item na linha do imposto.
--
-- Em 14/10/2020   - Wendel Albino - 
-- Redmine #72354  - Integração Open Interface - Campo COD_INF_ADIC_VL_DECL
-- Rotina Alterada - PKB_INTEGR_ITEM_NOTA_FISCAL_FF - > ajustes nas validacoes do campo vv_cod_inf_adic_vlr_decl 
--
-- Em 09/10/2020   - Karina de Paula
-- Redmine #71600  - Erro na Chave de acesso terceiro NFE
-- Rotina Alterada - PKB_VALIDA_CHAVE_ACESSO => Incluído tratamento no parâmetro de entrada ev_cnpj para preencher com zeros a esquerda até tamanho 14 posições
-- Liberado        - Patch_2.9.5.1, Patch_2.9.4.4 e Release_296
--
-- Em 30/09/2020   - Luis Marques - 2.9.4-4 / 2.9.5-1 / 2.9.6
-- Redmine #70529  - Validação indevida - NFe (PIS e COFINS)
-- Rotina Alterada - PKB_VALIDA_IMPOSTO_ITEM - Foi colocado verificação se valida os imposto PIS e COFINS conforme
--                   parametrizado na empresa em que a nota está entrando.
--
-- Em 08/10/2020   - Wendel Albino - 2.9.5
-- Redmine #72221  - alterar o log de erro para log de informacao na validacao de qtd x item
-- Rotina Alterada - PKB_INTEGR_NOTA_FISCAL - alterada na chamada pkb_log_generico_nf,  na tarefa 70852 a variavel en_tipo_log = informacao, ao invez de erro_de_validacao
--
-- Em 07/10/2020 - Eduardo Linden
-- Redmine #72181 - valor imposto tributado INSS está sendo arredondado (feed)
-- Ajuste sobre o calculo do INSS Retido para truncar o valor e revisão da validação para o campo Imp_ItemNf.vl_imp_trib
-- Rotina alterada - pkb_integr_Imp_ItemNf
-- Liberado para o release 296 e patches 2.9.4.4 e 2.9.5.1
---
-- Em 25/09/2020 - Eduardo Linden
-- Redmine #67715 - Criar regra de validação
-- Inclusão para calculo do campo Imp_ItemNf.vl_imp_trib para as notas de serviços de terceiros.
-- Rotina alterada - PKB_INTEGR_IMP_ITEMNF
--
-- Em 17/08/2020   - Luis Marques - 2.9.5
-- Redmine #58588  - Alterar tamanho de campo NRO_NF
-- Rotina Alterada - PKB_INTEGR_NOTA_FISCAL, PKB_INTEGR_NF_REFEREN - Colocado verificação que a quantidade de dígitos 
--                   do numero da nota fiscal para NF-e não pode ser maior que 9 dígitos.
--
-- Em 15/09/2020   - Luis Marques - 2.9.4-3 / 2.9.5
-- Redmine #71433  - Falha na execução pré-validação da rotina 'PB_PREENCHE_ITEM_NF_CEAN'
-- Rotina Alterada - PKB_CONSISTEM_NF - Ajuste na leitura do objeto de integração para rotinas programáveis
--
-- Em 23/09/2020   - Armando -- obs: não foi aberta ficha de testes posi as alterações foram realizadas diretamente no ambiente de da amazon produção
--								mesmo com os ajustes ainda terá ocorrencia Rejeição por duplicidade de evento. Este caso será tratado no novo desenvolvimento do RabbitMQ.
--								a atual estrutura não permitiu a alteração.
-- Redmine #70986 
-- Rotina Alterada - FKG_CK_NOTA_FISCAL_MDE_REGISTR - retirada a condição do select and nf.dm_situacao = 3    -- Processado 
--																                    and nf.cod_msg = 135;  -- Evento registrado e vinculado a NF-e
--                                                    pois basta existir uma nota fiscal relacionada.
--                 - PKB_EXCLUIR_DADOS_NF - alteração do de  if vn_dm_arm_nfe_terc = 0 or nvl( vn_dm_ind_emit, 0 ) = 1 then --ALTERAÇÃO ARMANDO 15/09/2020
--         										       para  if vn_dm_arm_nfe_terc = 0 AND nvl( vn_dm_ind_emit, 0 ) = 1 then   
--			       - PKB_INTEGR_NOTA_FISCAL_MDE - adicionado mais condições no update
--												  update nota_fiscal_mde set just        = est_row_nota_fiscal_mde.just
--                                    									   , dm_situacao = vn_dm_situacao
--            														   where id          = est_row_nota_fiscal_mde.id
--              														 and dm_situacao = 0
--              														 and nota_fiscal_mde.lotemde_id is null;
--				  - pkb_gera_lote_mde - cursor c_lmde (en_lotemde_id number), adicionado a condição and dm_situacao in (4, 5)  
--							            na fase 7 adicionado a condição , dm_situacao = 2 -- Aguardando Envio
--
--
-- Em 11/09/2020   - Wendel Albino
-- Redmine #71235  - integração NF-e
-- Rotina Alterada - pkb_valida_cria_nro_chave_nfe -> Alterada no select da procedure onde buscava a uf_ibge_emit da tabela nota fical, 
--                 -   passou a buscar da nota_fiscal_emit(campo_uf) com a inclusao desta tabela no select.
--
-- Em 10/09/2020   - Wendel Albino
-- Redmine #70852  - Validar processo - "quantidade X item = valor do item bruto"
-- Rotina Alterada - PKB_INTEGR_ITEM_NOTA_FISCAL -> Inclusao de Erro de validacao do vl_Item_Bruto, caso
--                 -  o valor nao seja correspondente a (qtde_Comerc * vl_Unit_Comerc) com margem de 1 centavo.
--
-- Em 01/09/2020 - Marcos Ferreira
-- Distribuições: 2.9.5 / 2.9.4.3
-- Redmine #69604 - Erro na emissão de NFe
-- Rotinas Alteradas: pkb_calc_vl_aprox_trib
--
-- Em 31/08/2020  - Wendel Albino
-- Redmine #69348 - Inclusão de campo COD_INF_ADIC_VL_DECL (cBenef)
-- Rotina Alterada: PKB_INTEGR_ITEM_NOTA_FISCAL_FF-> Inclusao de novo atributo na integracao (CODINFADICVLRDECL_ID)
--
-- Em 20/08/2020 - Renan Alves
-- Redmine #70277 - Validação Incorreta - Total X Valor do item
-- No IF que é verificado se o valor total dos itens (vn_vl_total_item) encontra-se igual ao 
-- valor total, foi incluído a variável vn_vl_serv_nao_trib, pois, quando existe 
-- um serviço na nota, o valor não fecha, porque não estava sendo considerado o valor de serviço.
-- Rotina: pkb_valida_total_nf
-- Patch_2.9.4.2 / Patch_2.9.3.5 / Release_2.9.5
--
-- Em 10/08/2020   - Armando / Karina de Paula
-- Redmine #71288  - Erro na chamada de rotinas programáveis Online.
-- Rotina Alterada - PKB_CONSISTEM_NF => A rotina estava fechando na tabela de WS não integrando para outras integrações
-- Liberado        - Release_295 e Patch_2.9.4.2
--
-- Em 14/08/2020 - Marcos Ferreira
-- Distribuições: 2.9.5 / 2.9.4.2
-- Redmine #66908: Realizar adequação na demonstração de tributos aproximados
-- Rotinas Criadas: pkb_busca_vlr_aprox_ibpt
-- Rotina Alterada: pkb_gerar_info_trib
--
-- Em 10/08/2020   - Karina de Paula
-- Redmine #69653  - Incluir objeto integração 16 na mesma validação do objeto 6
-- Rotina Alterada - PKB_CONSISTEM_NF => Incluído o objeto de integração 16
--
-- Em 05/08/2020   - Luis Marques - 2.9.3-5 / 2.9.4-2 / 2.9.5
-- Redmine #70108  - Ajuste na validação do registro C113 da nota fiscal
-- Rotina Alterada - PKB_INTEGR_NF_REFEREN - Colocado verificação na validação de CPF/CNPJ para nulo, se existir valor
--                   no campo "pessoa_id" da tabela "nota_fiscal_referen" verifica qual o tipo de pessoa e só retorna
--                   erro se o tipo de pessoa (DM_TIPO_PESSOA) for diferente de (2-Estrangeiro).
-- Em 03/08/2020   - Luiz Armando Azoni
-- Redmine #70049  - este processo não será mais utilizado canelado na ficha #70049
-- Rotina Alterada - pkb_reg_danfe_rec_armaz_terc
-- 
-- Em 23/07/2020   - Karina de Paula
-- Redmine #69836  - Mensagem dm_st_proc divergente e inscrição Estadual não validada
-- Rotina Alterada - PKB_INTEGR_NOTA_FISCAL_EMIT => Alterada a msg da verificação do IE
--                 - pkb_valida_cria_nro_chave_nfe => Incluído "elsif nvl(vn_qtde_erro_chave,0) > 0 then" na verificação de erros para gerar
--                 - log de erro de validação somente se houver na chave
--
-- Em 21/07/2020   - Luis Marques - 2.9.4-1 / 2.9.5
-- Redmine #68300  - Falha na integração & "E" comercial - WEBSERVICE NFE EMISSAO PROPRIA (OCQ) 
-- Rotina Alterada - PKB_INTEGR_NOTA_FISCAL_EMIT - Colocado nos campos nome,fantasia e lograd pra utiliza no parametro
--                   "en_ret_carac_espec" valor 4 que retira todos os caracteres especiais menos o caracter & (E comercial).
--
-- Em 20/07/2020   - Karina de Paula
-- Redmine #69699  - Erro ao gerar DANFe - Texto informações complementares do item
-- Rotina Alterada - PKB_GERAR_INFO_TRIB(Alteração executada pelo Armando) => Retirada a concatenação: substr(trim(trim(inf_cpl_imp_item)||' '||vv_inf_cpl_imp_item),1,500)
--                 - PKB_GERAR_INFO_TRIB => Em análise junto com Armando vimos que select feito na tab item não é necessário 
--
-- Em 16/07/2020   - Karina de Paula
-- Redmine #69383  - Rejeição: Erro na Chave de Acesso - Campo ID não corresponde a concatenação dos campos correspondentes (MOGYANA)
-- Rotina Alterada - PKB_INTEGR_NFCHAVE_REFER => Retirada a chamada da função pk_csf.fkg_chave_nf pq não usava o valor retornado. Incluída o 
--                   parâmetro de saída sn_dm_nro_chave_nfe_orig para retornar q a chave foi criada
--                 - PKB_VALIDA_CHAVE_ACESSO => Incluída a validação novamente do DM_FORMA_EMISS mas somente para NRO_CHAVE_NFE criado pela Compliance
--                 - pkb_valida_cria_nro_chave_nfe => Incluída a rotina de criação de uma nova chave quando gerado erro e for NRO_CHAVE_NFE criado pela Compliance
--
-- Em 15/07/2020   - Luis Marques - 2.9.3-4 / 2.9.4-1 / 2.9.5
-- Redmine #69451  - Falha na integração do codigo do participante de documentos referenciados modelo 04 (BREJEIRO)
-- Rotina alterada - PKB_INTEGR_NF_REFEREN - Ajustado para recuperar o id_pessoa via cod_part caso a chave de acesso
--                   referenciada seja nula, caso contrario a recuperação do id_pessoa será recuperado no processo
--                   de tratamento da chave.
--
-- Em 13/07/2020   - Karina de Paula
-- Redmine #69515  - Falha na validação da chave de acesso - tabela itemnf_export (USJ)
-- Rotina Alterada - pkb_integr_itemnf_export => Retirei a chamada da pkb_valida_chave_acesso e retornei a validação que fazia antes
-- Liberado        - Release_2.9.4, Release_2.9.5, Patch_2.9.4.1 e Patch_2.9.3.4 
--
-- Em 09/07/2020 - Allan Magrini
-- Redmine #69380: Erro no calculo do DIFAL
-- Alterações: Ajuste select para buscar o valor vn_vl_imp_trib fase 7.3
-- Rotina:  PKB_CALC_ICMS_INTER_CF
--
-- Em 10/06/2020 - Luis Marques - 2.9.3-4 / 2.9.4-1 / 2.9.5
-- Redmine #68486 - Participante da Nota Fiscal referenciada não atualiza/ Nota de origem está correta
-- Rotina Alterada: PKB_INTEGR_NF_REFEREN - Ajustado verificação da chave da nota fiscal referenciada para ler
--                  tanto notas com escrituração DM_ARM_NFE_TERC = 0 como notas apenas de armazenamento 
--                  DM_ARM_NFE_TERC = 1, pois ocasionava erro e consequentemente voltada os dados da nota que 
--                  referenciou.
--
-- Em 06/07/2020 - Allan Magrini
-- Redmine #65449 - Remoção de caracteres especiais.
-- Alterada as fase 8,45 e 46 com ret_carac_espec = 2 =>  pk_csf.fkg_converte ( est_row_Item_Nota_Fiscal.descr_item,0,1,3,1,1,1  )  
-- Rotina Alterada:  PKB_INTEGR_ITEM_NOTA_FISCAL
--
-- Em 03/07/2020   - Luis Marques - 2.9.3-4 / 2.9.4-1 / 2.9.5
-- Redmine #68973  - Valor Total do ICMS Desonerado sendo retirado na validação das notas
-- Rotina Alterada - PKB_AJUSTA_TOTAL_NF - Total de ICMS Desonerado sendo colocado no campo específico independente  
--                   do parâmetro  e verificado o parâmetro  "PARAM_EFD_ICMS_IPI.DM_SUBTR_VL_ICMS_DESON" para somar no 
--                   VL_TOTAL_NF da tabela "nota_fiscal_total".
--
-- Em 02/07/2020  - Karina de Paula
-- Redmine #57986 - [PLSQL] PIS e COFINS (ST e Retido) na NFe de Serviços (Brasília)
-- Alterações     - pkb_integr_notafiscal_total_ff/pkb_solic_calc_imp/pkb_atual_nfe_inut/pkb_relac_nfe_cons_sit/pkb_integr_nota_fiscal_total
--                  PKB_AJUSTA_TOTAL_NF/PKB_VALIDA_TOTAL_NF => Inclusão dos campos vl_pis_st e vl_cofins_st
-- Liberado       - Release_2.9.5, Patch_2.9.4.1 e Patch_2.9.3.4
--
-- Em 02/07/2020 - Renan Alves
-- Redmine #68991 - Diferença - Valor contábil de CF-e
-- Foi alterado o valor do produto (VL_PROD) do select que recupera os valores do item, incluindo
-- todos os campos que compõe o valor liquido do produto.
-- Rotina: pkb_vlr_fiscal_item_cfe
-- Patch_2.9.4.1 / Patch_2.9.3.4 / Release_2.9.5
--
-- Em 23/06/2020   - Wendel Albino
-- Redmine #68193  - CFOP 2933 Integração NFSe - MIDAS
-- Rotina Alterada - incluida validacao de nf de servico nao validar na pkb_valida_cfop_por_dest na procedure PKB_CONSISTEM_NF .
--
-- Em 23/06/2020   - Wendel Albino
-- Redmine #68345  - Verificar procedure
-- Rotina Alterada - PKB_GERA_REGIST_ANALIT_IMP - inclusao de validacao se a nf possui item e imposto e retirado delete da nfregist_analiti na procedure PKB_AJUSTA_TOTAL_NF.
--
-- Em 18/06/2020 - Allan Magrini
-- Redmine #67791: Ajuste de DIFAL Franklin
-- Alterações: colocada validação do campo se o valor do campo VL_ICMS_UF_DEST na criação do registro
-- na tabela IMP_ITEMNF_ICMS_DEST for inferior a X (parametrizado), então esse campo deve ser gravado como zero na fase 7.7
-- Ajuste nos calculos da Difal fase 7.6 e na função fkg_emp_calcula_icms_difal
-- Rotina:  PKB_CALC_ICMS_INTER_CF, fkg_emp_calcula_icms_difal
--
-- Em 15/06/2020 - Karina de Paula
-- Redmine #63341  - Erro na integração da chave persiste
-- Rotina Alterada - pkb_valida_chave_acesso => A validação foi retirada em razão da empresa cadastrar um forma de emissão padrão nos parâmetros
--                   porém poder integrar um doc como forma de emissão de contingência
--
-- Em 15/06/2020   - Karina de Paula
-- Redmine #63341  - Erro na integração da chave persiste
-- Rotina Alterada - pkb_integr_nota_fiscal_compl => Foi criado um único update para todos os campos abaixo gerando assim uma economia de 6 comando de update na nota fiscal
--                   (sub_serie, inforcompdctofiscal_id, cod_cta, codconsitemcont_id, nro_ord_emb, seq_nro_ord_emb)        
--                 - Trouxe para o início do processo o select feito na tab nota_fiscal
--                 - Incluído geração de log quando é criada um chave para a nota fiscal 
--                 - Estava criando NRO_CHAVE_NFE para Nota Fiscal de Emissão Própria e "Legado" e também diferente dos modelos 55 e 65
--                 - PKB_INTEGR_NOTA_FISCAL => Só atualiar o id_tag_nfe se o valor da nro_chave_nfe não for nulo, para não gravar 
--                   somente "NFe" no campo que gerava erro da tag
--                 - PKB_VALIDA_NOTA_FISCAL => Retirada a validação na NRO_CHAVE_NFE dessa procedure pq será validada pela pkb_valida_cria_nro_chave_nfe chamada pela pkb_consistem_nf
--                 - pkb_integr_itemnf_export => Retirada a validação na NRO_CHAVE_NFE e incluída a chamada da pkb_valida_cria_nro_chave_nfe
--                 - PKB_CONSISTEM_NF => Incluída a chamada da pkb_valida_cria_nro_chave_nfe
--                 - Ao gerar uma nova chave era gravado um log como ERRO DE VALIDAÇÃO e o correto é INFORMACAO
--                 - pkb_integr_itemnf_export => Retirada a validação na NRO_CHAVE_NFE e incluída a chamada da pkb_valida_cria_nro_chave_nfe
--
-- Em 03/06/2020  - Karina de Paula
-- Redmine #62471 - Criar processo de validação da CSF_CONS_SIT
-- Alterações     - PKB_INTEGR_CONS_CHAVE_NFE => Exclusão dessa rotina pq foi substituída pela pk_csf_api_cons_sit.pkb_integr_cons_chave_nfe
--                - PKB_RELAC_NFE_CONS_SIT    => Incluída a verificação do modelo fiscal <> 65 (65 está na rotina pk_csf_api_nfce.PKB_RELAC_NFE_CONS_SIT)
--                -                              Retirado o update na csf_cons_sit e incluída a chamada da pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit
--                - PKB_CONS_NFE_TERC         => Retirado o insert na csf_cons_sit e incluída a chamada da pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit
--                - PKB_REL_CONS_NFE_DEST_OLD => Excluída a rotina não estava sendo utilizada
--                - pkb_rel_cons_nfe_dest     => Retirado o insert na csf_cons_sit e incluída a chamada da pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit
--                - PKB_REG_AUT_MDE           => Retirado o insert na csf_cons_sit e incluída a chamada da pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit
-- Liberado       - Release_2.9.4, Patch_2.9.3.3 e Patch_2.9.2.6
--
-- Em 03/06/2020 - Allan Magrini
-- Redmine #65449 - Ajustes em integração e validação 
-- Alterada as fase 8,45 e 46 com ret_carac_espec = 2 =>  pk_csf.fkg_converte ( est_row_Item_Nota_Fiscal.descr_item,0,1,2,1,1,1  )  
-- Rotina Alterada:  PKB_INTEGR_ITEM_NOTA_FISCAL
--
-- Em 27/05/2020 - Allan Magrini
-- Redmine #67815: Erro na PBK_CALC_ICMS_INTER_CF
-- Alterações: Ajuste na fkg_emp_calcula_icms_difal colocando no primeiro select a validação por item e ncm e distinct nele e nos demais
-- Rotina:  fkg_emp_calcula_icms_difal
--
-- Em 27/05/2020  - Luiz Armando Azoni
-- Redmine #67676 - referente a validação do "Deve ser informado o registro de emitente da nota fiscal, para nota fiscal de emissão propria e de modelos 55 e 65". 
--                   Retirando o validação do modelo 65 pois o mesmo nao tem emitente destacado no xml
-- Alterações     - pkb_valida_nf_emit;
-- Liberado       - Release_2.9.4, Patch_2.9.3.2 e Patch_2.9.2.5
--
-- Em 06/05/2020  - Karina de Paula
-- Redmine #65401 - NF-e de emissão própria autorizada indevidamente (CERRADÃO)
-- Alterações     - Incluído para o gv_objeto o nome da package como valor default para conseguir retornar nos logs o objeto;
-- Liberado       - Release_2.9.4, Patch_2.9.3.2 e Patch_2.9.2.5
--
-- Em 23/04/2020 - Luis Marques - 2.9.2-4 / 2.9.3-1 / 2.9.4
-- Redmine #67039 - Integração Legado campo nota_fiscal_referenc.pessoa_id
-- Rotina Alterada: PKB_INTEGR_NF_REFEREN - Verifica se a nota fiscal referenciada pela chave_nfe existe no Compliance 
--                  e carrega os dados, colocado verificação que se o cnpj da nota referenciada for o mesmo da
--                  nota fiscal e o pessoa_id não estiver carregado colocar o pessoa_id da nota fiscal no pessoa_id 
--                  da nota fiscal referenciada.
--
-- Em 17/03/2020 - Luis Marques - 2.9.3
-- Redmine #65362 - Criar regra de validação para ICMS60
-- Rotina Alterada: PKB_INTEGR_IMP_ITEMNF_FF - Incluida validação para caso os campos BC_ICMS_EFET, ALIQ_ICMS_EFET e 
--                  VL_ICMS_EFET forem nulos e se o parametro "DM_VALID_ICMS60" da tabela "empresa" estiver ativo (1) 
--                  e o CODST for 60 e imposto 1 ICMS gravar log de erro.
--
-- Em 07/04/2020 - Allan Magrini
-- Redmine #66013 - Criação de funcionalidade
-- Alterações: Inclusão da fkg_emp_calcula_icms_difal e inclusão da validação do parâmetro e calculo do icms na fase 7.4
-- Rotina: PKB_CALC_ICMS_INTER_CF,  fkg_emp_calcula_icms_difal
-- 
-- Em 30/03/2020 - Allan Magrini
-- Redmine #64726 - Upload de XML legado mod 65
-- Alterações: na fase 3.4 no insert da tabela nota_fiscal, foi colocado dm_ind_oper = 1 e dt_emiss = rec.dt_hr_recbto 
-- Rotina: PKB_ATUAL_NFE_INUT
--
-- Em 27/03/2020   - Karina de Paula
-- Redmine #64629  - Ajuste na integração Open interface
-- Rotina Alterada - PKB_INTEGR_IMP_ITEMNF_FF => Incluída a verificacao: se a percentual de redução de base efetivo, base, alíquota ou valor de
-- ICMS Efetivo for maior que zero e CST de ICMS for diferente de 41, 60 ou 500, nesse caso deverá gerar erro de validação e informar
-- que "O grupo de ICMS Efetivo só deve ser informado para o CST ICMS for 41 ou 60 ou CSOSN de Simples 500."
-- Liberado        - Release_2.9.3.10
--
-- Em 25/03/2020 - Luis Marques - 2.9.3 / 2.9.2-3 / 2.9.1.6
-- Redmine #66271 - Cáculo do ICMS para a UF do destinatário incorreto para o CFOP de retorno de bem
-- Rotina Alterada: PKB_CALC_ICMS_INTER_CF - Colocado verificação do tipo de operação do CFOP para verificar se
--                  calcula a partilha de icms inter-estadual, considerado só tipos 3 - Devolução / 10 - Vendas.
--
--
-- Em 18/03/20120  - Karina de Paula
-- Redmine #58105  - Duplicidade nas informações complementares do item da nota fiscal
-- Rotina Alterada - PKB_INTEGR_ITEMNF_COMPL => Incluída a verificação se já existe itemnf_id (vn_itemnf_id)
--
-- Em 12/03/2020 - Luis Marques - 2.9.3
-- Redmine #63776 - Integração de NFSe - Aumentar Campo Razao Social do Destinatário e Logradouro
-- Rotinas alteradas: PKB_INTEGR_NF_AGEND_TRANSP, PKB_REG_PESSOA_DEST_NF, PKB_INTEGR_NOTA_FISCAL_DEST, 
--                    PKB_CRIA_PESSOA_NFE_LEGADO - Alterado para recuperar 60 caracteres dos campos nome e lograd da 
--                    nota_fiscal_dest para todas as validações, colocado verificação que se nome ou logradouro
--                    campos "nome" e "lograd" vierem com mais de 60 caracteres será gravado log de erro.
--
-- Em 10/03/20120 - Marcos Ferreira
-- Distribuições: 2.9.2-3 / 2.9.3
-- Redmine #65319: Alterar regra para obter base de calculo do Difal de saída
-- Rotina: PKB_CALC_ICMS_INTER_CF
-- Alterações: Alteração do parametro de checagem de verificação se existe percentual de redução de ICMS Interno (Dentro do Estado)
--
-- Em 03/03/20120 - Marcos Ferreira
-- Distribuições: 2.9.2-3, 2.9.3
-- Redmine #65495 - Consulta de notas de terceiros canceladas com erro por nota de serviço da Midas cancelada
-- Rotina: pkb_cons_nfe_terc, 
-- Alterações: Padronização do código modelo 55 e 65 nos cursores c_nf e c_nf_zero
--
-- Em 02/03/20120 - Marcos Ferreira
-- Distribuições: 2.9.2-3, 2.9.1-6, 2.9.3
-- Redmine #63871 - Tratar duplicidade de evento MDE
-- Rotina: fkg_ck_nota_fiscal_mde_registr, pkb_integr_nota_fiscal_mde, pkb_relac_nfe_cons_sit, 
--         pkb_rel_cons_nfe_dest_old, pkb_rel_cons_nfe_dest, pkb_reg_aut_mde, pkb_gera_lote_download_xml, 
--         pkb_grava_mde
-- Alterações: Criado função para checagem de registro MDE e geração de Log. Alterado Rotinas para checagem
--             antes da inserção na tabela NOTA_FISCAL_MDE.
--
-- Em 11/02/20120 - Marcos Ferreira
-- Redmine #64565 - Inclusão do modelo fiscal no processo de consulta de notas de terceiro
-- Rotina: pkb_cons_nfe_terc
-- Alterações: Inclusão do modelo fiscal no cursof c_nf
--
-- Em 06/02/2020   - Luiz Armando Azoni
-- Redmine #64149  - Ajuste no calculo do registro analitico
-- Rotina Alterada - pkb_gera_regist_analit_imp - ajustado a forma de calculo levando em consideração o percentual de fcp
--
-- Em 29/01/2020   - Luis Marques
-- Redmine #63056  - ICMS Desonerado RJ
-- Rotina Alterada - PKB_AJUSTA_TOTAL_NF - Ajustado para considerar o parametro na tabela "PARAM_EFD_ICMS_IPI" campo
--                   "DM_SUBTR_VL_ICMS_DESON" e se estiver marcado como 1 ler o valor do ICMS desonerado para 
--                   subtrair do valor total da nota fiscal.
--
-- Em 29/01/2020   - Luis Marques 
-- Redmine #63985  - Alteração da package pk_csf_api para quando a informação dm_ind_final não for informado na integração
-- Rotina Alterada - PKB_VALIDA_NOTA_FISCAL - colocada validação para DM_IND_FINAL conforme orientação do suporte
--                   canais.
--
-- Em 23/01/2020   - Eduardo Linden
-- Redmine #63995 - Campo VL_ABAT_NT divergente ao integrar NF
-- Rotina Alterada - pkb_integr_item_nota_fiscal_ff => ajuste de caracter para numerico
--
-- Em 21/01/2020   - Eduardo Linden
-- Redmine #62945  - Processos PLSQL (Adaptar o campo VL_ABAT_NT nos itens da Nota Fiscal)
-- Rotinas Alteradas - pkb_integr_item_nota_fiscal_ff => inclusão do campo VL_ABAT_NT
--                   - pkb_valida_total_nf            => inclusão do campo VL_ABAT_NT na rotina de validação.
--
-- Em 17/01/2020   - Luiz Armando
-- Redmine #63586  - Como o cliente não esta enviando na integração o campo nota_fiscal.dm_id_dest, o mesmo será tratado neste processo.
-- Rotina Alterada - PKB_VALIDA_CFOP_POR_DEST                 
--
-- Em 13/01/2020   - Karina de Paula
-- Redmine #63033  - Feed - problema continua
-- Rotina Alterada - PKB_INTEGR_NFREGIST_ANALIT e PKB_INTEGR_NOTA_FISCAL_TOTAL => Incluída a validação para gerar log quando o valor vl_icms for "nulo" ou "0" e o valor
--                   do vl_fcp_icms for maior que "0"
--
-- Em 06/01/2020 - Luis Marques
-- Redmine #63033 - Feed - problema continua
-- Rotina Alterada: PKB_CONSISTEM_NF - ajuste para nota com erro de validação e for feito ajuste e revalidada novamente e
--                  só conter informações geral no log mudar o DM_ST_PROC para 4 - validada.
--
-- Em 20/12/2019 - Luiz Armando / Luis Marques
-- redmine #62794 - Validação do código do DIFAL incorreta
-- Rotina alterada: pkb_integr_inf_prov_docto_fisc - colocada verificação do Código de Ocorrência de Ajuste de ICMS quando
--                  for de emissão propia não estva verificando UF do destinatário.
--
-- Em 19/12/2019 - Luis Marques
-- Redmine #62738 - Criação de novo valor no tipo de objeto de integração
-- Rotinas Alteradas: PKB_INTEGR_NOTA_FISCAL_MDE, PKB_RELAC_NFE_CONS_SIT, PKB_REL_CONS_NFE_DEST_OLD, pkb_rel_cons_nfe_dest,
--                    PKB_REG_AUT_MDE, pkb_reg_danfe_rec_armaz_terc, pkb_gera_lote_download_xml, PKB_GRAVA_MDE - Inserido
--                    novo campo "DM_TIPO_INTEGRA" com valor default 0.
--
-- Em 16/12/2019 - Luis Marques
-- Redmine #62628 - Feed - notas que tinham atualizado estao ficando com erro de validação
-- Rotinas Alteradas: PKB_AJUSTA_TOTAL_NF, PKB_VALIDA_TOTAL_NF - Novo ajuste para o  valor de serviço não tributado 
--                    "VL_SERV_NAO_TRIB" e valor total de serviço "VL_TOTAL_SERV" para composição do valor total da NF e 
--                    da tag do xml "vServ". 
--
-- Em 16/12/2019 - Luis Marques
-- Redmine #62577 - Campo VL_TOTAL_SERV não está somando nos totais
-- Rotinas Alteradas: PKB_AJUSTA_TOTAL_NF, PKB_VALIDA_TOTAL_NF - Ajustado valor de serviço não tributado "VL_SERV_NAO_TRIB" e
--                    valor total de serviço "VL_TOTAL_SERV" para composição do valor total da NF e da tag do xml "vServ".
--                    Considerar para serviço não tributado menos a base de calculo de ICMS.
--
-- Em 12/12/2019 - Luis Marques
-- Redmine #62524 - Feed - O valor total da nota está dobrando
-- Rotina Alterada: PKB_AJUSTA_TOTAL_NF - Ajustado o valor total da nf para considerar o ajuste no valor total do item.
--
-- Em 12/12/2019 - Luis Marques
-- Redmine #62219 - Ajustar parâmetro do ajusta totais quando for emissão de serviço (Mod 55) Brasília
-- Rotinas Alteradas: PKB_AJUSTA_TOTAL_NF, PKB_VALIDA_TOTAL_NF - Ajustado valor total dos itens caso a nota seja modelo '55'.
--                    o valor total dos itens tem que ser menos o valor total de serviços para esta condição.
--
-- Em 11/12/2019 - LUIZ ARMANDO AZONI
-- Redmine #62316 - ADEQUAÇÃO NO PROCESSO DE GERAÇÃO DE CONSULTA DO MDE PARA NÃO DUPLICAR 
--				  - ADEQUAÇÃO NO PROCESSO DE EXCLUSÃO DOS DADOS DA NOTA Fiscal  
-- Rotina Alterada: PKB_EXCLUIR_DADOS_NF E pkb_rel_cons_nfe_dest
--
-- Em 10/12/2019 - Allan Magrini
-- Redmine #61841 - Cálculo Difal - Uso consumo / Cte
-- Alteração na fase 16, adicionado vt_itemnf_dif_aliq := null para zerar as variáveis antes de iniciar o novo loop.  
-- Rotina Alterada: PKB_CALC_DIF_ALIQ
--
-- Em 08/12/2019 - Luis Marques
-- Redmine #62217 - feed - Foi mudado o tipo de mensagem mas a situação da nota continua com erro de validação
-- Rotinas alteradas - PKB_VALIDA_IMPOSTO_ITEM - Ajustando validação de N18-20 para facultativa pois algumas UF(s) não são obrigatórias.
--                     PKB_CONSISTEM_NF - verificação se os logs gravados são de erro função "fkg_ver_erro_log_generico_nf".
-- Nova Função       - fkg_ver_erro_log_generico_nf - verifica se existe log de erro dentro dos logs gravados ou só informação 
--                     e ou aviso.
--
-- Em 05/12/2019 - Eduardo Linden
-- Redmine #62059 - Nfe complementar está exigindo que o indpres seja 0
-- Rotina alterada - PKB_VALIDA_NOTA_FISCAL => Inclusão dos campos dm_ind_final e dm_proc_emiss sobre a validação da NF-e complementar ou de ajuste.
-- 
-- Em 03/12/2019   - Eduardo Linden
-- Redmine #61891  - Feed - DM_FIN_NFE alterando para 4
-- Rotina alterada - PKB_VALIDA_NOTA_FISCAL => Não será aplicada regra para mudar nota_fiscal.dm_fin_nfe para 4, se o mesmo
--                                             campo já estiver com valor 2 e 4 (gt_row_nota_fiscal.dm_fin_nfe).
--
-- Em 29/11/2019   - Karina de Paula
-- Redmine #61109  - Nota Fiscais de complemento/ajuste validando quantidade do item
-- Rotina Alterada - PKB_INTEGR_ITEM_NOTA_FISCAL => Incluída a verificação (gt_row_nota_fiscal.dm_fin_nfe <> 02 -- NF-e complementar)
--
-- Em 27/11/2019 - Luis Marques
-- Redmine #61665 - Ajustar parâmetro do ajusta totais quando for emissão de serviço (Mod 55) Brasília
-- Rotinas Alteradas: PKB_AJUSTA_TOTAL_NF, PKB_VALIDA_TOTAL_NF - Ajustado valor de serviço não tributado para subtrair
--                    o valor da base de calculo de ISS para a composição do valor não tributado que será somado no valor
--                    total do documento.
--
-- Em 27/11/2019 - Luiz Armando / Luis Marques
-- Redmine #61768 - Retorno de XML CT-e e NF-e em Duplicidade
-- Rotinas Alteradas: pkb_relac_nfe_cons_sit, pkb_rel_cons_nfe_dest - Ajustado para verificar o DM_ST_PROC do documento antes 
--                    de setar DM_RET_NF_ERP que inicia nova leitura na SEFAZ e retorna ao ERP.
--
-- Em 22/11/2019 - Allan Magrini
-- Redmine #61486 - Integração de NFe Mercantil - Open Interface - Chamada de Rotina Programável do Tipo Pré-Validação
-- Alteração na fase 1, no retorno do nvl do if de 1 para valor 0
-- Rotina Alterada: PKB_CONSISTEM_NF
--
-- Em 22/11/2019 - Eduardo Linden
-- Redmine #61145 - Ajustar trecho de validação na PK_CSF_API
-- Caso NF-e for complementar (dm_fin_nfe = 2),os campos vl_ipi_devol e percent_devol serão zerados.
-- Rotina alterada: PKB_VALIDA_ITEM_NOTA_DEVOL
--
-- Em 15/11/2019 - Allan Magrini
-- Redmine #61180 - Integração de NFe Mercantil - Open Interface - Chamada de Rotina Programável do Tipo Pré-Validação
-- Inclusão da rotina pkb_exec_rot_prog_online_pv na fase 1 PKB_CONSISTEM_NF
-- Rotina Alterada: PKB_CONSISTEM_NF
--
-- Em 14/11/2019 - Luis Marques
-- Redmine #61180 - Validações da Regras N18-10 e N18-20 Facultativas - Amazon Prod
-- Rotina Alterada: PKB_VALIDA_IMPOSTO_ITEM - Tornando validações N18-10 para (Margem Valor Agregado) facultativa
--                  pois algumas UF(s) não são obrigatórias.
--
-- Em 11/11/2019 - Luis Marques
-- Redmine #60931 - Verificar processo PKB_GERAR_INFO_TRIB - ITEM_NOTA_FISCAL.INF_CPL_IMP_ITEM (USV)
-- Rotina Alterada: PKB_GERAR_INFO_TRIB - Colocado verificação se o texto gerado já está gravado no campo "inf_cpl_imp_item" -
--                  'Informações Complementares de Impostos do Item' da tabela "item_nota_fiscal".
--
-- Em 08/11/2019   - Karina de Paula
-- Redmine #57901  - Criar validação para Verificar o código de benefício fiscal com o estado da empresa emitente
-- Rotina Alterada - PKB_INTEGR_ITEM_NOTA_FISCAL_FF e pkb_integr_inf_prov_docto_fisc => Incluída a verificação da UF do COD_OCOR_AJ_ICMS
--                   pkb_integr_inf_prov_docto_fisc => não estava atualizando os campos itemnf_id e codocorajicms_id na tabela inf_prov_docto_fiscal
--
-- Em 06/11/2019 - Marcos Ferreira
-- Redmine #60871 - Erro ao executar validação do MDE
-- Procedure: PKB_CONS_NFE_TERC
-- Alterações: Após a ativação do Midas em Amazon Prod, a rotina começou a tentar incluir as notas com modelo fical 99 (nota de serviço), dando erro, pois não tinha a chave nfe
--             Fiz a inclusão do modelo fiscal 55 no where do cursor c_nf_zero                    
--
-- Em 06/11/2019 - Luis Marques
-- Redmine #60843 - NFe validação cobrança está divergente.
-- Rotina Alterada: PKB_CALC_ICMS_ST - Feito ajuste na atualização do valor liquido para a nota de cobrança. 
--
-- Em 01/11/2019 - Marcos Ferreira
-- Redmine #60615 - Correção em processo de consulta situação da chave CSF_CONS_SIT
-- Alterações: Criado função de checagem de envio pendente para chave de acesso nfe
-- Função Criada: fkg_checa_chave_envio_pendente
-- Alterações: Checagem de envio pendente antes de fazer o insert na CSF_CONS_SIT
-- Procedure alterada: pkb_rel_cons_nfe_dest 
-- Alterações: Substituido query que checa envio pendente pela nova função antes dos inserts na CSF_CONS_SIT
-- Procedure alterada: pkb_cons_nfe_terc  
--
-- Em 01/11/2019 - Luiz Armando
-- Redmine       - 
-- Rotina Alterada: Adequação na pkb_gerar_info_trib na vn_fase := 4.3, adicionando a condição if vv_inf_cpl_imp_item is not null then
--                  para realizar o update somente se tiver valor na variavel vv_inf_cpl_imp_item
--
-- Em 24/10/2019 - Luis Marques
-- Redmine #60178 - AS informações contidas na view VW_CSF_ITEM_NOTA_FISCAL_FF devem ser concatenadas
-- Rotina Alterada: PKB_GERAR_INFO_TRIB para no campo 'INF_CPL_IMP_ITEM' verificar se já existe valor e concatenar com o valor
--                  que está entrando se o parametro 'DM_GERA_TOT_TRIB' não for 0 (zero) 'Não Gera'.
--
-- Em 21/10/2019        - Karina de Paula
-- Redmine #60155	- Feed - Rel Apuração ICMS
-- Rotinas Alteradas    - pk_csf_api.pkb_vlr_fiscal_nfsc => Valor retornado como nulo tratado c nvl para não dar erro no valor final
-- NÃO ALTERE A REGRA DESSA ROTINA SEM CONVERSAR COM EQUIPE
--
-- Em 21/10/2019 - Marcos Ferreira
-- Redmine #60142 - Campo VL_ICMS_DESON incorreto na geração da nota fiscal
-- Rotina Alterada: PKB_INTEGR_IMP_ITEMNF_FF, PKB_INTEGR_IMP_ITEMNF -  Inclusão de checagem para a variável vn_vl_icms_deson,
--                  se for zero, jogar null no update
--
-- Em 18/10/2019        - Karina de Paula
-- Redmine #59854	- Notas Fiscais não estão entrando na apuração de ICMS
-- Rotinas Alteradas    - pk_csf_api.pkb_vlr_fiscal_nfsc => Foi incluído o cálculo do FCP para compor o valor do ICMS
--                        A rotina pk_apur_icms.fkg_modp9_cred_c190_c_d_590 soma o FCP, por isso a alteração
-- NÃO ALTERE A REGRA DESSA ROTINA SEM CONVERSAR COM EQUIPE
--
-- Em 11/10/2019 - Luis Marques
-- Redmine #58182 - Ajustar validação de valor de cobrança
-- Rotina Alterada: PKB_VALIDA_NF_COBR - Lendo "vl_orig" valor original para fazer a verificação contra o valor
--                  total da nota fiscal.
--
-- Em 10/10/2019        - Karina de Paula
-- Redmine #52654/59814 - Alterar todas as buscar na tabela PESSOA para retornar o MAX ID
-- Rotinas Alteradas    - Trocada a função pk_csf.fkg_Pessoa_id_cpf_cnpj_interno pela pk_csf.fkg_Pessoa_id_cpf_cnpj
-- NÃO ALTERE A REGRA DESSAS ROTINAS SEM CONVERSAR COM EQUIPE
--
-- Em 09/10/2019 - Luis Marques
-- Redmine #59784 - Criar integração na VW_CSF_ITEM_NOTA_FISCAL_FF para campo inf_cpl_imp_item
-- Rotina Alterada: PKB_INTEGR_ITEM_NOTA_FISCAL_FF - Incluido a leitura para o campo 'INF_CPL_IMP_ITEM',
--                  será atualizado para nota de emissão propria e modelo 55.
--
-- Em 03/10/2019 - Luiz Armando Azoni
-- Redmine #59632 - 
-- Alterações: Na query que recupera o campo vn_dm_mot_des_icms, foi adicionado a tipo de imposto 1-icms.
-- Procedures Alteradas: PKB_INTEGR_IMP_ITEMNF_FF
--
-- Em 02/10/2019 - Allan Magrini
-- Redmine #59181 - XML legado - itens da nota não sendo cadastrados corretamente
-- Alterações: Inclusão de update no campo COD_BARRA na tabela item, quando já existir o cadastro do mesmo e o campo COD_BARRA for diferente de nulo
-- Procedures Alteradas: PKB_CRIA_ITEM_NFE_LEGADO
--
-- Em 01/10/2019 - Luis Marques
-- Redmine #59448 - Falha na integração VL_ICMS_DESON (CISNE)
-- Rotina Alterada: PKB_INTEGR_IMP_ITEMNF_FF - Incluido verificação do campo de VL_ICMS_DESON.
--
-- Em 26/09/2019 - Luis Marques
-- Redmine #41547 - Calculo Diferencial de Alíquota - MG
-- Rotina Alterada: PKB_CALC_DIF_ALIQ - Liberado calculo do DIFAL para todos, antes simples nacional não era 
--                  feito, conforme "Lei Complementar 155/2016".
--
-- Em 25/09/2019 - Allan Magrini
-- Redmine #59181 - XML legado - itens da nota não sendo cadastrados corretamente
-- Alterações: adicionado o campo intem_nota_fiscal.cean no cursor c_item para gravar em cod_barra na tabela item e
-- inclusão de update no campo CEST na tabela item, quando já existir o cadastro do mesmo e o campo CEST for diferente de nulo
-- Procedures Alteradas: PKB_CRIA_ITEM_NFE_LEGADO
--
-- Em 23/09/2019 - Marcos Ferreira
-- Redmine #58157 - Validação de total.
-- Alterações: Comentado teste "and nvl(vn_qtde_cfop_3_7, 0) <= 0" para validação de Totais
-- Procedures Alteradas: PKB_VALIDA_TOTAL_NF
--
-- Em 18/09/2019   - Luis Marques
-- Redmine #58745  - Erro na tag PMVast
-- Rotina Alterada: PKB_INTEGR_IMP_ITEMNF - Verificado se o valor estiver zero e for (0,1,2,3,4,5) na Modalidade de Determinação 
--                  da base de calculo do ICMS-ST, o imposto for ICMS-ST e a situação tributária for '10', '30', '60', '70' ou '90'
--                  coloca null para o campo perc_adic para não ocorrer erro na tag PMVast do XML.
--
-- Em 15/09/2019 - Luis Marques
-- Redmine #58778 - feed - nao está sendo reduzida a base de calculo
-- Rotina Alterada: PKB_CALC_ICMS_INTER_CF - Ajustado para gravar a base com a redução.
--
-- Em 12/09/2019 - Luis Marques
-- Redmine #58703 - Erro na Integração do Cupom SAT com Desconto
-- Rotina Alterada: PKB_VLR_FISCAL_ITEM_CFE - ajustado para retornar o valor do conhecimento considerando o valor
--                  do desconto caso ocorra
--
-- Em 10/09/2019 - Luis Marques
-- Redmine #58674 - erro ao integrar NF com opção mod_base_calc_st = 6
-- Rotina Alterada: PKB_INTEGR_ITEM_NOTA_FISCAL e PKB_VALIDA_IMPOSTO_ITEM - Ajustado para aceitar 6 no campo 
--                  'dm_mod_base_calc_st'
--
-- Em 09/09/2019 - Luis Marques
-- Redmine #58551 - feed - Continua saindo o valor do ICMS-st no valor contabil
-- Rotina Alterada: pkb_vlr_fiscal_item_nf - O entendimento anterior não estava correto (redmine #58383) o correto 
--                  é se existe icms-st (2) e existe icms (1) com codigo de situação tributária '60' não deve ser 
--                  somado. Feito ajuste para contemplar esse novo entendimento.
--
-- Em 05/09/2019 - Luis Marques
-- Redmine #58373 - Feed - não está calculando o difal
-- Rotina Alterada: pkb_recup_param_part_icms_empr - Ajustada para não fazer loop por NCM
--
-- Em 05/09/2019 - Luis Marques
-- Redmine #58383 - Corrigir o calculo do valor contábil
-- Rotina Alterada: pkb_vlr_fiscal_item_nf - ajustado para quando for buscar ICMS-ST não trazer se o cod_st for '60'
--
-- Em 05/09/2019   - Karina de Paula
-- Redmine #58328  - verificar erro no participante
-- Rotina Alterada - pkb_integr_Nota_Fiscal => Alterada a verificação do pessoa_id referente ao COD_PART
--
-- Em 02/09/2019 - Luis Marques
-- Redmine #58229 - Extrema demora no cálculo ICMS DIFAL
-- Rotina Alterada: pkb_recup_param_part_icms_empr - Na procedure interna pkb_recup_param_ncm tirada chamada para ncm superior
--                  que era recursiva e estava causando o lock que causa a demora,colocada antes de iniciar processo de
--                  recuperação dos valores para calculo do DIFAL.
--
-- Em 01/09/2019 - Luis Marques
-- Redmine #57717 - Alterar validação de alguns campos após liberar #57714
-- Ajustadas as chamadas da fkg_converte para considerar novo valor de parametro dois (2) para conversão de campo para NF-e.
-- Rotinas Alteradas: pkb_integr_item_nota_fiscal, pkb_integr_Nota_Fiscal, pkb_integr_nfinfor_adic
--
-- Em 30/08/2019 - Allan Magrini
-- Redmine #58019 - Erro validação campo Perc_Adic (PKB_VALIDA_IMPOSTO_ITEM)
-- Foi incluido junto a validação (rec_imp.perc_adic > 0)  para todos os impostos, a validação do tipo de imposto (rec_imp.tipoimp_id = 2) para ICMS-ST.
-- Rotina Alterada:PKB_VALIDA_IMPOSTO_ITEM
--
-- Em 28/08/2019 e 29/08/2019 - Luis Marques
-- Redmine #57454 - Mudar calculo do DIFAL
-- Rotinas Alteradas: pkb_recup_param_part_icms_empr e PKB_CALC_ICMS_INTER_CF
-- Ajustado para verificar novos campos de percentual de redução de base de ICMS se colocados na tabela de parametros.
--
-- EM 20/08/2019 - Luis Marques
-- Redmine #56316 - Compliance valida incorretamente NF de devolução PF
-- Ajustado que Se for devolução e for PIS/COFINS com CST '50' e tem valor tributado aceita o credito e não apresenta erro
-- Rotina Alterada: PKB_VAL_CRED_NF_PESSOA_FISICA
--
-- Em 19/08/2019 - Eduardo Linden
-- Redmine #57724 - feed - não exibiu mensagem de validação para o item 3 E16a-40
-- Ajuste sobre a regra de validação E16a-40 na NT2019.001
-- Rotina Alterada: pkb_valida_nf_dest
--
-- Em 17/08/2019 - Eduardo Linden
-- Redmine#57649 - Faltou para VW_CSF 
-- As regras de validação para NT 2019.001 foram realocadas para outras rotinas já existentes. 
-- As rotinas criadas para as tabelas NFE_NF e NFE_NF_ITEM foram excluidas desta package.
-- Rotinas Alteradas: pkb_valida_nf_dest e pkb_valida_imposto_item
-- Rotinas excluidas: pkb_valida_nfe e pkb_valida_nfe_item 
--
-- Em 15/08/2019 - Eduardo Linden
-- Redmine #56637 - Regras de validação NT 2019.001
-- Criação das rotinas de validação dos dados da Nota Fiscal Eletronica (tabela NFE_NF) e dos seus Itens ( tabela NFE_NF_ITEM), para atender a NT2019.001.
-- Rotinas Criadas: pkb_valida_nfe e pkb_valida_nfe_item 
--
-- Em 13/08/2019 - Karina de Paula
-- Redmine - Karina de Paula - 57525 - Liberar trigger criada para gravar log de alteração da tabela NOTA_FISCAL_TOTAL e adequar os 
-- objetos que carregam as variáveis globais
-- Rotina Alterada: Todos inserts e updates da tabela nota_fiscal_total estão carregando as variáveis globais para insert na T_A_I_U_Nota_Fiscal_Total_01
--
-- Em 12/08/2019 - Luis Marques
-- Redmine #57250 -  Disponibilizar para cliente Taxiweb ambiente atualizado e notas fiscais convertidas não são integradas.
--
-- Em 10/08/2019 - Luis Marques
-- Redmine #57361 - feed - Não exclui a nota
-- Rotina Alterada: PKB_EXCLUIR_DADOS_NF
--                  Verificação na hora da exclusão do nota fiscal MDE se a a nota é de terceiro permite e se for terceiro
--                  e exista registros na NFE_DOWNLOAD_XML tambem exclui desta tabela.
--
-- Em 09/08/2019 - Luis Marques
-- Redmine #56630 - Nota Referenciada não sobe mais de 1 Registros [NFE.NF]
-- Rotina Alterada: PKB_INTEGR_NF_REFEREN
--                  Acertado para respeitar o set de inclusão ou alteração e a verificação de registro já excistente
--
-- Em 09/08/2019 - LuiZ ARMANDO
-- Redmine #55900 - CRIAÇÃO DA PKB_GRAVA_MDE
-- Rotina Alterada: PKB_GRAVA_MDE 
--
-- Em 07/08/2019 - Luis Marques
-- Redmine #57230 - Erro na execução da package pk_csf_api.pkb_excluir_dados_nf
-- Rotina Alterada: FKG_NOTA_MDE_ARMAZ - Ajustado para verificação se é de terceiro permite a exclusão 
--
-- Em 19/07/2019 - Luis Marques
-- Redmine #56467 - Feed - ao integrar a NF-e de terceiro
-- Rotina Alterada: FKG_NOTA_MDE_ARMAZ - Ajustado para não apresentar mensagem quando da
--                  integração da nota.
--
-- Em 10/07/2019 - Eduardo Linden
-- Redmine #56191 - Ajuste no Calculo do ICMS FCP - Relatório de resumo de impostos
-- Rotina Alterada    : busca de parametrização "Recupera ICMS" na tabela param_oper_fiscal_entr
-- Procedure alterada : PKB_VLR_FISCAL_ITEM_NF.
--
-- Em 04/07/2019 - Luis Marques
-- Redmine #27836 Validação PIS e COFINS - Gerar log de advertência durante integração dos documentos
-- Rotinas alteradas: Incluido verificação de advertencia da falta de Codigo da base de calculo do credito
--                    se existir base e aliquota de imposto for do tipo imposto (0) e cliente juridico
--                    pkb_integr_nfcompl_operpis e pkb_integr_nfcompl_opercofins
--
-- Em 05/07/2019 - Allan Magrini
-- Redmine #52601 - Alteração da situação do documento
-- Rotina Alterada: Correção na fase 6 Valida informação da situação do documento foi incluido no if 
-- (ev_cd_sitdocto in ('01') and vn_dm_st_proc = 10 )) para documentos com erro de integração liberada a alteração para 01 extemporâneo
-- Procedures Alteradas: PKB_INTEGR_NOTA_FISCAL
--
-- Em 03/07/2019 - Allan Magrini
-- Redmine #52601 - Alterar forma de calculo de DIFAL
-- Rotina Alterada: Fase 14.1, para que o sistema faça o calculo automático esse parâmetro deverá estar marcado como
--                  “Sim” dm_cal_difal_nf = '0'. Se vier valor de DIFAL por integração vt_itemnf_dif_aliq.vl_dif_aliq,
--                  calculo não deverá ser efetuado e deve ser considerado o valor enviado pela integração
-- Procedures Alteradas: PKB_CALC_DIF_ALIQ
--
-- Em 02/07/2019 - Luis Marques
-- Redmine #54631 - [Falha] ao excluir uma NFE de terceiro
-- Rotina Alterada: pkb_excluir_dados_nf 
-- Nova function: fkg_nota_mde_armaz
--
-- Em 28/06/2019 - Allan Magrini
-- Redmine #55320 - Validação do campo número de registro de exportação (Vitopel)
-- Rotina Alterada: Foi colocado no final da package a validação da dm_ind_doc e retirada da query as tabelas de view
-- Procedures Alteradas: pkb_integr_itemnf_export e epkb_integr_itemnf_export_compl
--
-- Em 27/06/2019 - Allan
-- Redmine #55363 - ADEQUAR DOMINIO DM_MOT_DES_ICMS CONFORME NT2016_02
-- Rotina Alterada: PKB_INTEGR_ITEM_NOTA_FISCAL =>  Adicionado: 90 na validação do campo DM_MOT_DES_ICMS
--                  PKB_INTEGR_NOTA_FISCAL_FF   =>  Adicionado: 90 na validação do campo dm_mot_des_icms_part
--
-- Em 19/06/2019 - Luis marques
-- Redmine #55408 - Erro ao excluir Nota Fiscal de Serviços Contínuos
-- Rotina Alterada: PKB_EXCLUIR_DADOS_NF, Incluido exclusão de tabelas impr_cab_nfsc e impr_item_nfsc
--                    referente a serviços contínuos.
--
-- Em 13/06/2019 - Allan Magrini
-- Redmine #55320 - Validação do campo número de registro de exportação (Vitopel)
-- Rotina Alterada: Foi feito ajuste na validação quando a nota não tem dm_ind_doc,
--                    adicionado o valor 3 para não gerar erro e dar continuidade no processo e 
--                    neste caso não grava valor no num_reg_export, somente se vier o valor e  alterada a fase 3 
--                    para só validar os campos chv_nfe_export e qtde_export se o vn_dm_ind_doc_ic <> 3
-- Procedures Alteradas: pkb_integr_itemnf_export
--
-- Em 21/05/2019 - Allan Magrini
-- Redmine #54504 - Validação do campo número de registro de exportação (Vitopel)
-- Rotina Alterada: (num_reg_export) este campo deve ser preenchido se o campo dm_ind_doc for 0 (zero) REGISTRO 1100.
--                    foi colocada a validação senão da erro com msg informando, pois é campo obrigatório
--                    se for diferente o Reg Export recebe 0, não pode ficar nulo por validação do icms
-- Procedures Alteradas: pkb_integr_itemnf_export
--
-- Em 29/05/2019 - Luiz Armando Azoni
-- Redmine #54844 - Livro P1/P1A - CFOP 3556 - Base de Cálculo e valores do Imposto
-- Rotina Alterada: PKB_VLR_FISCAL_ITEM_NF
-- Descrição: adicionada as variáveis vn_vl_bc_isenta_icms := 0;
--				      vn_vl_base_calc_icms := 0;
--				      vn_aliq_icms         := 0;
--				      vn_vl_imp_trib_icms  := 0;
--				      vn_vl_bc_outra_icms  := nvl(vn_vl_operacao,0);
--				      vv_cod_st_icms      := '90';
--            logo após a condição if vn_cfop in (3551, 3556) then para ajustar a impressão dos livros fiscais
--
-- Em 23/05/2019 - Marcos Ferreira
-- Redmine #53630: Verificar processo de validação de Imposto NF Em.Prop quando ICMS = 60
-- Alterações: Caso seja CST 60 e base de calculo zerada, não vazer o confronto de valor de item com o valor da base de calculo
-- Procedures Alteradas: PKB_VALIDA_BASE_ICMS
--
-- Em 20/05/2019 - Karina de Paula
-- Redmine #54556 - feed - Duplicidade de tabela em nfe
-- Rotina Alterada: Incluída a verificação de duplicação de dados: PKB_INTEGR_NFINFOR_ADIC / PKB_INTEGR_NOTA_FISCAL_LOCAL / PKB_INTEGR_NFINFOR_FISCAL /  pkb_integr_nf_forma_pgto
--                  nfcobr_dup / NFTRANSP_VEIC / NFTRANSP_VOL
--
-- Em 16/05/2019 - Karina de Paula
-- Redmine #54516 - feed - Valor de FCP está aparecendo no total da nota
-- Rotina Alterada: PKB_AJUSTA_TOTAL_NF => Incluída a verificação se a nota fiscal de conversão para chamar o ajuste independente do vlr do parâmetro
--
-- Em 16/05/2019 - Karina de Paula
-- Redmine #54406 - feed - nfe erro de validação duplica itens e fatura
-- Rotina Alterada: PKB_INTEGR_NOTA_FISCAL_COBR / PKB_INTEGR_NFINFOR_ADIC / pkb_integr_nf_referen / PKB_INTEGR_CF_REF => Incluída a verificação de duplicação de dados
--
-- Em 14/05/2019 - Allan Magrini
-- Redmine #43349 - Falha na validação partilha - NFe CFOP 2554 (CREMER)
-- Rotina Alterada: foi incluida a validação do cfop com uf destino linha 6490
-- Procedures Alteradas: PKB_INTEGR_IMP_ITEMNFICMSDEST
--
-- Em 13/05/2019 - Karina de Paula
-- Redmine #54344 - feed - erro em PK
-- Rotina Alterada: PKB_INTEGR_NOTA_FISCAL => Alterada a ordem da verificação de duplicação para pegar duplicação de notas integradas via WS (WebService)
--
-- Em 09/05/2019 - Luiz Armando Azoni
-- Redmine #54081: Validação do campo número de registro de exportação
-- Solicitação: Adequação na geração do registro de exportação, inserindo sempre zero quando o campo num_reg_export for nulo
-- Alterações: Adequação na pk_csf_api.pkg_integr_itemnf_export, no insert e no update, sempre que o campo num_reg_export for nulo, adicionar 0
-- Procedures Alteradas: pk_csf_api.pkg_integr_itemnf_export
--
-- Em 24/04/2019 - Marcos Ferreira
-- Redmine #53839: Erro ORA-01426 overflow numérico - FKG_GERA_CNF_NFE_RAND (CREMER)
-- Solicitação: Melhorias na função de geração do CNF_NFE RANDOMICO. Foi encontrado problema quandoa numeração da nota e empresa superam 9 caracters
-- Alterações: Melhoria na função para compatibilizar. Aplicado nas procedures que fazem a chamada da função
-- Procedures Alteradas: FKG_GERA_CNF_NFE_RAND, PKB_INTEGR_NOTA_FISCAL_COMPL, PKB_INTEGR_NOTA_FISCAL
--
-- Em 08/04/2019 - Angela Inês.
-- Redmine #53266 - Correção na função que retorna os valores de Nota Fiscal - Valor de IPI.
-- Zerar os valores de IPI quando o CFOP do item da nota for 3551, da mesma forma que é feito para o CFOP 3556.
-- Rotina: pkb_vlr_fiscal_item_nf.
--
-- Em 26/03/2019 - Marcos Ferreira
-- Redmine #52812: Mudar forma de geração CNF_NFE - Novo Método
-- Solicitação: Para evitar fraudes e aumentar a segurança, gerar o campo CNF_NFE por numero randomico, utilizar novo método mais estável
-- Alterações: Alterado Função FKG_GERA_CNF_NFE_RAND e Alterado as procedures que utilizam a composição do campo CNF_NFE
-- Procedures Alteradas: FKG_GERA_CNF_NFE_RAND, PKB_INTEGR_NOTA_FISCAL_COMPL, PKB_INTEGR_NOTA_FISCAL
--
-- Em 18/03/2019 - Marcos Ferreira
-- Redmine #52298: Mudar forma de geração CNF_NFE
-- Solicitação: Para evitar fraudes e aumentar a segurança, gerar o campo CNF_NFE por numero randomico
-- Alterações: Criado Função FKG_GERA_CNF_NFE_RAND e Alterado as procedures que utilizam a composição do campo CNF_NFE
-- Procedures Alteradas: FKG_GERA_CNF_NFE_RAND, PKB_INTEGR_NOTA_FISCAL_COMPL, PKB_INTEGR_NOTA_FISCAL
--
-- Em 12/03/2019 - Renan Alves
-- Redmine #49355 - Vínculo da NFe emissão própria legado com MDe
-- Foi comentado a parte onde é utilizado a pk_csf.fkg_notafiscal_id_chave_empr para retornar o ID da NOTA FISCAL,
-- incluindo o select da pk_csf.fkg_notafiscal_id_chave_empr dentro da rotina, trazendo somente o ID da nota fiscal
-- de terceiros
-- Rotina: pkb_rel_cons_nfe_dest
--
-- Em 27/02/2019 - Karina de Paula
-- Redmine #51799 - Integração do atributo VW_CSF_NOTA_FISCAL_FF.DM_ID_DEST (ALTA GENETICS)
-- Rotina Alterada: PKB_VALIDA_NF_DEST     => Retirada a duplicacao da verificacao: if nvl(vn_dm_ind_ie_dest, 0) = 2 and vv_ie is not null
--                  PKB_VALIDA_NOTA_FISCAL => Somente irá alterar o dm_id_dest se o campo estiver nulo, do contrário mantém o que foi enviado pelo cliente
--                                            Alterada a verificacao: if vn_dm_id_dest_comparar <> nvl(gt_row_nota_fiscal.dm_id_dest,0) then
--                                                              para: if nvl(gt_row_nota_fiscal.dm_id_dest,0) = 0 then
--
-- Em 21/02/2019 - Karina de Paula
-- Redmine #51311 - Relatório NFSe Contínuo
-- Rotina Alterada: PKB_EXCLUIR_DADOS_NF => retirados os deletes das tabelas impr_cab_nfsc e impr_item_nfsc
--
-- Em 19/02/2019 - Karina de Paula
-- Redmine #51743 - pq está ocorrendo erro de integração e validação, sendo que foi integrado.
-- Rotina Alterada: PKB_INTEGR_ITEMNF_MED_FF => Corrigido código para trabalhar com elsif na verificacao dos valores
--
-- Em 18/02/2019 - Karina de Paula
-- Redmine #51625 - Alterar a integracao dos novos campos view VW_CSF_NOTA_FISCAL_LOCAL para VW_CSF_NOTA_FISCAL_LOCAL_FF
-- Rotina Alterada: pkb_integr_nota_fiscal_local => Excluídos os campos: nome, cep, cod_pais, desc_pais, fone e email
-- Rotina Criada  : pkb_integr_nota_fiscal_localff
--
-- Em 13/02/2019 - Renan Alves
-- Redmine #51531 - Alterações PLSQL para atender layout 005 (vigência 01/2019) - Parte 2.
-- Foi acrescentado o número 2, no if que realiza a valida a informação do tipo de declaração de importação.
-- Rotina: pkb_integr_itemnf_dec_impor.
--
-- Em 12/02/2019 - Angela Inês.
-- Redmine #51435 - Alterar a função que recupera os valores fiscais dos documentos fiscais mercantis - Valor de IPI Devolvido.
-- 1) Acrescentar o valor do IPI Devolvido (item da nota fiscal), ao valor contábil/operação das notas fiscais.
-- 2) Ao validar o valor da base de ICMS, considerar os valores de FCP do ICMS-ST, e do valor do IPI Devolvido.
-- Rotina: pkb_vlr_fiscal_item_nf e pkb_valida_base_icms.
--
-- Em 06/02/2019 - Karina de Paula
-- Redmine #48956 - De acordo com a solicitação, o Indicador de Pagamento passa a ser considerado na Forma de Pagamento, além da Nota Fiscal (cabeçalho).
-- Rotina Alterada: PKB_INTEGR_NF_FORMA_PGTO_FF => Incluído o campo: dm_ind_pag
--
-- Em 05/02/2019 - Eduardo Linden
-- Redmine #51215 - Remover validação do GTIN
-- A validação para GTIN incluida devido a ativ #46741 só poderá ser acionada, se não for legado (nota_fiscal.dm_legado=0)
-- Rotina alterada: PKB_INTEGR_ITEM_NOTA_FISCAL
--
-- Em 05/02/2019 - Eduardo Linden
-- Redmine #51128 - ID_Empresa divergente - tabela Log_generico_nf
-- Inclusão da variavel vn_empresa_id para o parametro en_empresa_id da procedure pkb_log_generico_nf.
-- Para evitar registro na tabela log_generico_nf com id_empresa diferente do que está registrado na tabela nota_fiscal.
-- Rotina alterada: pkb_integr_Nota_Fiscal_Canc
--
-- Em 01/02/2019 - Karina de Paula
-- Redmine #51038 - Criar campos no banco
-- Rotina Alterada: PKB_INTEGR_NOTA_FISCAL_FF    => Incluídos os campos: cod_mensagem e msg_sefaz
--                  PKB_INTEGR_NOTA_FISCAL_LOCAL => Incluídos os campos: nome, cep, cod_pais, desc_pais, fone e email
--                  PKB_INTEGR_ITEMNF_MED_FF     => Incluídos os campos: mot_isen_anvisa
--
-- Em 28/01/2019 - Angela Inês.
-- Redmine #50953 - Correção na rotina programável que atualiza NRO_CHAVE_NFE e Atualização e Validação da Chave na NF.
-- Com a correção da Atv/Redmine #49312 - NFe validada duas vezes e alterada a Chave de Acesso enviada pelo cliente, o processo passou a não considerar o valor
-- do campo da Chave de Acesso, como sendo NULO, fazendo com que a alteração dos novos valores não fossem realizadas.
-- O processo considerava alteração nos dados de Chave se o valor enviado na View VW_CSF_NOTA_FISCAL_COMPL, campo NRO_CHAVE_NFE fosse nulo, ou, se houvesse erro
-- de validação dos campos da chave enviado na View VW_CSF_NOTA_FISCAL_COMPL campo NRO_CHAVE_NFE, ou, se o valor enviado na View VW_CSF_NOTA_FISCAL_COMPL campo
-- NRO_CHAVE_NFE não fosse nulo porém diferente do valor possivelmente na gravado na Nota Fiscal, campo NRO_CHAVE_NFE.
-- Nessa mudança, não foi avaliado a possibilidade do valor possivelmente na gravado na Nota Fiscal, campo NRO_CHAVE_NFE, estar NULO, por isso ocorreu o erro.
-- O processo passa a considerar se o valor enviado na View VW_CSF_NOTA_FISCAL_COMPL, campo NRO_CHAVE_NFE for nulo, ou, se houvesse erro de validação dos campos
-- da chave enviado na View VW_CSF_NOTA_FISCAL_COMPL campo NRO_CHAVE_NFE, ou, se o valor enviado na View VW_CSF_NOTA_FISCAL_COMPL campo NRO_CHAVE_NFE não fosse
-- nulo porém diferente do valor possivelmente na gravado na Nota Fiscal campo NRO_CHAVE_NFE, considerando que se o mesmo for NULO, tratar com o comando NVL e
-- considerar 'A' como valor default.
-- Rotina: pkb_integr_nota_fiscal_compl.
--
-- Em 24/01/2019 - Eduardo Linden
-- Redmine #46741 - Validação GTIN
-- Foi adicionado uma nova validação para GTIN. Caso os os campos CEAN e CEAN_Trib estiverem nulos, será gerado um log informando que estes dois campos devem ser preenchido como 'SEM GTIN'.
-- Uma vez que gerado o log para está situação, o registro na tabela Nota_fiscal será considerada como 'Erro de validação' (dm_st_proc =10).
-- Rotina alterada: PKB_INTEGR_ITEM_NOTA_FISCAL
--
-- Em 23/01/2019 - Karina de Paula
-- Redmine #49691 - DMSTPROC alterando para 1 após update em NFSE - Dr Consulta
-- Criadas as variáveis globais gv_objeto e gn_fase para ser usada no trigger T_A_I_U_Nota_Fiscal_02 tb alterados os objetos q
-- alteram ou incluem dados na nota_fiscal.dm_st_proc para carregar popular as variáveis
--
-- Em 24/01/2019 - Angela Inês.
-- Redmine #50879 - Correção na função que recupera os valores de Item de Nota Fiscal e na montagem do Registro Analítico.
-- 1) Ao considerar o valor de FCP do Imposto ICMS-ST no valor da operação, desconsiderar o mesmo para conferência dos valores das bases de redução e bases
-- tributadas, isenta e outras.
-- Rotina: pkb_vlr_fiscal_item_nf.
-- 2) Incluir as colunas VL_FCP_ICMS e VL_FCP_ICMSST na inclusão do registro que se refere a tabela NFREGIST_ANALIT.
-- Rotina: pkb_gera_regist_analit_imp.
--
-- Em 23/01/2019 - Angela Inês.
-- 3) Incluir as colunas VL_FCP_ICMS e VL_FCP_ICMSST na tabela NFREGIST_ANALIT.
-- Essas colunas farão parte dos processos de Notas Fiscais Mercantis, porém não temos integração dessa tabela, processo de View. A tabela é gerada no momento da
-- integração da nota através da rotina PK_CSF_API.PKB_GERA_C190.
-- Rotina: pkb_gera_regist_analit_imp.
--
-- Em 21/01/2019 - Angela Inês.
-- Redmine #48915 - ICMS FCP e ICMS FCP ST.
-- Considerando a data de emissão da nota fiscal, a partir de 01/08/2018:
-- 1) Somar o valor do FCP do Imposto ICMS-ST ao valor da operação.
-- 2) Retornar o valor tributado de FCP do Imposto ICMS; retornar o valor e a alíquota tributados de FCP do Imposto ICMS-ST.
-- Rotina: pkb_vlr_fiscal_item_nf.
-- Atribuir os campos referente aos valores de FCP que são retornados na função de valores do Item da Nota Fiscal (pkb_vlr_fiscal_item_nf).
-- Rotina: pkb_gera_regist_analit_imp.
--
-- Em 15/01/2019 - Karina de Paula
-- Redmine #50344 - Processo para gerar os dados dos impostos originais
-- Rotina Alterada: PKB_EXCLUIR_DADOS_NF => Incluido o delete da tabela imp_itemnf_orig
--
-- Em 07/01/2019 - Marcos Ferreira
-- Redmine #49312 - NFe validada duas vezes e alterada a Chave de Acesso enviada pelo cliente
-- Solicitação: Em alguns casos, quando o cliente envia a Chave de Acesso gerada em seu ERP, o Compliance altera o número da chave enviada
-- Alterações: Incluído algumas validações antes do update da chave de acesso na tabela nota_fiscal
-- Procedures Alteradas: pkb_integr_nota_fiscal_compl
--
--
-- === AS ALTERAÇÕES ABAIXO ESTÃO NA ORDEM CRESCENTE USADA ANTERIORMENTE ================================================================================= --
--
--
-- Em 29/04/2011 - Angela Inês.
-- Incluído processo de leiaute de Complemento da operação de PIS/PASEP.
-- Incluído processo de leiaute de Complemento da operação de COFINS.
-- Incluído processo de leiaute de Processo referenciado.
--
-- Em 02/09/2011 - Angela Inês.
-- Inclusão de rotinas para o processo Ecredac.
--
-- Em 09/04/2012 - Angela Inês.
-- Correção na mensagem referente ao dígito verificador da chave da NFe.
--
-- Em 10/04/2012 - Angela Inês.
-- Incluir a exclusão dos dados da tabela inf_prov_docto_fiscal, quando houver desprocesso de integração de nota fiscal.
--
-- Em 17/05/2012 - Angela Inês.
-- Liberar a rotina de validação de CFOP por destinatário incluindo o parâmetro da empresa que indica validação ou não do processo.
--
-- Em 18/05/2012 - Angela Inês.
-- Correção em mensagens e comentários de dados nas rotinas: pkb_integr_nfcompl_operpis e pkb_integr_nfcompl_opercofins.
-- Incluir na rotina pkb_integr_imp_itemnf, verificação do CST correto para integração dos impostos PIS e COFINS.
--
-- Em 22/05/2012 - Angela Inês.
-- Ficha HD 59774 - Passar a não validar o código SUFRAMA - rotina pkb_integr_Nota_Fiscal_Dest.
--
-- Em 26/06/2012 - Angela Inês.
-- Ficha HD 60745 - O processo de integração dos dados das notas fiscais de transporte (tab.: nota_fiscal_transp), passa a consistir a
-- unicidade da nota fiscal, portanto, não será possível incluir mais de um registro para a mesma nota fiscal. Rotina pkb_integr_Nota_Fiscal_Transp.
--
-- Em 27/06/2012 - Angela Inês.
-- 1) Pelo processo do PVA do Sped PIS/COFINS, o mesmo gera inconsistência quando um documento fiscal de "entrada", tem crédito de Pis/Cofins para pessoa física.
--    Na rotina pkb_val_cred_nf_pessoa_fisica, essa validação passa a existir, gerando inconsistência.
--
-- Em 02/07/2012 - Angela Inês.
-- 1) Inclusão da rotina de geração de log/alterações nos processos de Notas fiscais (tabela: nota_fiscal) - pkb_inclui_log_nota_fiscal.
-- 2) Inclusão da exclusão dos dados de log/alteração dos processos de Notas fiscais (tabela: log_nota_fiscal, log_nf_serv_cont) - pkb_excluir_dados_nf.
--
-- Em 05/07/2012 - Leandro.
-- 1) Incluir validação para o TEXTO de correção de CCe - Deve ser informado pelo menos 15 caracteres - rotina pkb_integr_nota_fiscal_cce.
-- 2) Ao recuperar valor de ICMS não considerar cod_st.cod_st in ('40', '41', '50', '60') - rotina pkb_valida_total_nf.
-- 3) Consistir para COD_ST = 60, o valor da base de cálculo, a alíquota e o valor do imposto - não podem ser maiores que zero - rotina pkb_valida_imposto_item.
--
-- Em 06/07/2012 - Angela Inês.
-- 1) Ficha HD 61249 - Alterar na integração das tabelas nf_compl_oper_cofins e nf_compl_oper_pis a regra do processo de validação:
--    1 - Para modelos documentos entre 06, 28 e 29 só pode aceitar os códigos de base de calculo entre: 01, 02, 04, 13 .
--    2 - Para modelos documentos entre 21 e 22 só pode aceitar os códigos de base de calculo entre: 03, 13.
--    Rotinas: pkb_integr_nfcompl_opercofins e pkb_integr_nfcompl_operpis.
-- 2) Na rotina pkb_val_cred_nf_pessoa_fisica, considerar o valor do imposto diferente de zero (imp_itemnf.vl_imp_trib <> 0).
--
-- Em 25/07/2012 - Angela Inês.
-- Alterar a rotina que valida crédito de pis/cofins para pessoa física através da função que relaciona cfop do item da nota fiscal com empresa
-- e da função que indica se a empresa permite a validação.
-- Rotina/função: pk_csf.fkg_empr_val_cred_pf_pc e, pkb_val_cred_nf_pessoa_fisica e pk_csf_efd_pc.fkg_existe_cfop_rec_empr.
--
-- Em 27/07/2012 - Angela Inês.
-- Alterar a rotina de integração de notas fiscais (pkb_integr_nota_fiscal), gerando valor fictício para os campos cidade_ibge_emit e uf_ibge_emit,
-- quando forem nulos.
--
-- Em 17/08/2012 - Angela Inês.
-- Inclusão de parâmetro de saída - base de cálculo de ST.
-- Rotina: pkb_vlr_fiscal_item_nf e pkb_vlr_fiscal_nfsc.
--
-- Em 26/09/2012 - Angela Inês - Ficha HD 62250.
-- 1) Inclusão do processo de integração de Notas Fiscais Referenciadas - Processo Flex Field (FF).
--
-- Em 07/11/2012 - Angela Inês.
-- 1) Ficha HD 63810 - Validação da chave de NFE, considerando o Número da NF com o campo da chave.
--    Rotina: pkb_integr_nota_fiscal_compl.
--
-- Em 08/11/2012 - Angela Inês.
-- Ficha HD 64080 - Escrituração Doctos Fiscais e Bloco M. Nova tabela para considerações de CFOP - param_cfop_empresa.
-- Rotinas: pkb_val_cred_nf_pessoa_fisica -> pk_csf_efd_pc.fkg_gera_cred_nfpc_cfop_empr.
--
-- Em 23/11/2012 - Rogério Silva.
-- Ficha HD 64482 - Criação do processo de integração dos dados do diferencial de alíquota.
-- Rotina: pkb_int_itemnf_dif_aliq.
--
-- Em 28/11/2012 - Angela Inês.
-- Ficha HD 64674 - Melhoria em validações, não permitir valores zerados para os campos:
-- Rotina: pkb_integr_nota_fiscal_total -> nota_fiscal_total.vl_total_nf.
-- Rotina: pkb_integr_nfregist_analit -> nfregist_analit.vl_operacao.
--
-- Em 11/12/2012 - Angela Inês.
-- Ficha HD 65023 - Validação de Qtde e Valor comerciais, e de Qtde e Valor tributados.
-- Não permitir integração com valores negativos e zerados.
--
-- Em 19/12/2012 - Angela Inês.
-- Ficha HD 64603 - Implementar os campos flex field para a integração dos impostos dos itens das Notas Fiscais: imp_itemnf.
-- Ficha HD 64597 - Implementar os campos flex field para a integração de Nota Fiscal de Serviço: nfregist_analit.
--
-- Em 09/01/2013 - Angela Inês.
-- Alterar o nome do atributo IE para IE_REF do processo de campos flex field da NOTA_FISCAL_REFEREN.
--
-- Em 07/02/2013 - Angela Inês.
-- Ficha HD 65753 - A pedido do Leandro, considerar a validação do total da NF dos impostos que sejam do tipo imposto (imp_itemnf.dm_tipo = 0).
-- Rotinas: PKB_VALIDA_TOTAL_NF e PKB_AJUSTA_TOTAL_NF.
--
-- Em 14/02/2013 - Angela Inês.
-- Ficha HD 65753 - A pedido do Leandro, considerar a validação do total da NF dos itens de produtos com código de serviço (item_nota_fiscal.cd_lista_serv <> 0).
-- Rotinas: PKB_VALIDA_TOTAL_NF.
--
-- Em 15/02/2013 - Angela Inês.
-- Ficha HD 66086 - Alterado a recuperação dos impostos consistindo a coluna ORIG.
-- Rotinas: PKB_GERA_REGIST_ANALIT_IMP.
--
-- Em 18/02/2013 - Angela Inês.
-- Ficha HD 65753 - A pedido do Leandro, considerar a validação do total da NF dos impostos que sejam do tipo imposto (imp_itemnf.dm_tipo = 0).
-- Validação dos itens de serviço da nota fiscal, no ajuste total e na validação.
-- Rotinas: PKB_VALIDA_TOTAL_NF e PKB_AJUSTA_TOTAL_NF.
--
-- Em 20/02/2013 - Angela Inês.
-- Ficha HD 66003 - Nota de complemento de ICMS - Permitir valor zerado para quantidade de volume e valor total da nota.
-- Rotinas: PKB_INTEGR_NFTRANSP_VOL e PKB_INTEGR_NOTA_FISCAL_TOTAL.
--
-- Em 20/02/2013 - Angela Inês.
-- Ficha HD 65753 - A pedido do Leandro, considerar no ajuste de notas e validação separar os itens de serviço e itens de produto.
-- Rotina: PKB_AJUSTA_TOTAL_NF.
--
-- Em 25/02/2013 - Angela Inês.
-- Ficha HD 65753 - A pedido do Leandro, considerar no ajuste de notas e validação separar os itens de serviço e itens de produto.
-- Consistir se o item é serviço através de item_nota_fiscal.cd_lista_serv <> 0.
-- A tabela imp_itemnf fica com dm_tipo = 0 e vl_imp_trib, para PIS e COFINS dos itens de serviço.
-- A tabela nota_fiscal_total fica com vl_pis_iss, vl_cofins_iss, vl_serv_nao_trib e vl_total_nf, a coluna vl_total_serv com zero dos itens de serviço.
-- Rotinas: PKB_VALIDA_TOTAL_NF e PKB_AJUSTA_TOTAL_NF.
--
-- Em 13/03/2013 - Angela Inês.
-- Ficha HD 66073 - Nas validações de imposto são parametrizáveis, grava a mensagem de log, porém o "tipo de log" quando "não é para validar" indicar como
-- "Informação".
-- Rotina: pkb_valida_imposto_item.
--
-- Em 02/04/2013 - Angela Inês.
-- Considerar a validação de Base de Cálculo de COFINS e PIS se o parâmetro da empresa indicar que devem ser validados.
-- Rotina: pkb_valida_imposto_item.
--
-- Em 28/05/2013 - Angela Inês.
-- Alteração na geração das mensagens de log/erro no processo de validação dos impostos.
-- Rotina: pkb_valida_imposto_item.
--
-- Em 04/06/2013 - Angela Inês.
-- Anulação da variável que armazena os dados da nota, feita devido a pk_integr_nfe, pois as notas estavam sendo recuperadas novamente, e gerando mais
-- registros filhos/após da nota (itens, emitente, destinatário, transportadora, total, etc...).
-- Os itens e os outros dados, passavam a ser incluídos a mais cada vez que a nota passava pelo processo de nota já autorizada.
-- Rotina: pkb_integr_nota_fiscal.
--
-- Em 05/07/2013 - Angela Inês.
-- Redmine #303 - Validação de informações Fiscais - Ficha HD 66733.
-- Correção nas rotinas chamadas pela pkb_consistem_nf, eliminando as referências das variáveis globais, pois essa rotina será chamada de outros processos.
-- Rotina: pkb_consistem_nf e todas as chamadas dentro dessa rotina.
-- Inclusão da função de validação das notas fiscais, através dos processos de sped fiscal, contribuições e gias.
-- Rotina: fkg_valida_nf.
-- Incluído a verificação de estados/uf  da empresa da nota fiscal de acordo com os registros de emitente/destinatário.
-- Rotinas: pkb_valida_nf_emit e pkb_valida_nf_dest.
--
-- Em 10/07/2013 - Angela Inês.
-- Correção nas rotinas de validação de UF da pessoa/participante com destinatário e/ou emitente.
-- Rotinas: pkb_valida_nf_emit e pkb_valida_nf_dest.
--
-- Em 12/07/2013 - Angela Inês.
-- Permitir base de cálculo maior que zero quando a CST for 73 para os impostos PIS e COFINS.
-- Rotina: pkb_valida_imposto_item.
--
-- Em 18/07/2013 - Angela Inês.
-- Redmine Atividade #58 - Ficha HD 66037
-- Melhoria na validação de impostos de Nota Fiscal mercantil, separar a validação de "Emissão Própria" e "Emissão de Terceiros".
-- Duplicar os parâmetros para validação de impostos: icms, icms-60, ipi, pis, cofins.
-- Os que já existem deverão fazer parte da opção Emissão Própria, que são: DM_VALID_IMP, DM_VALID_ICMS60, DM_VALIDA_IPI, DM_VALIDA_PIS, DM_VALIDA_COFINS.
-- Os novos deverão fazer parte da opção Terceiros, ficando: DM_VALID_IMP_TERC, DM_VALID_ICMS60_TERC, DM_VALIDA_IPI_TERC, DM_VALIDA_PIS_TERC, DM_VALIDA_COFINS_TERC.
-- Rotina: pkb_valida_imposto_item.
--
-- Em 25/07/2013 - Angela Inês.
-- Redmine #404 - Leiautes: Nota Fiscal Mercantil, de Terceiros e Nota Fiscal de Serviço.
-- Implementar no Imposto o flex-field para o "Código da Natureza de Receita".
-- Rotina: pkb_integr_imp_itemnf_ff.
--
-- Em 30/07/2013 - Angela Inês.
-- Redmine #405 - Leiaute: NF Serviço Continuo: Implementar no complemento de Pis/Cofins o código da natureza de receita isenta - Campos Flex Field.
-- Rotinas: pkb_integr_nfcomploperpis_ff e pkb_integr_nfcomplopercof_ff.
--
-- Em 15/08/2013 - Angela Inês.
-- Redmine #504 - Notas com divergência de sigla de estado da pessoa_id da nota com emitente ou destinatário.
-- Utilização das rotinas: fkg_pessoa_id_cpf_cnpj, fkg_pessoa_id_cpf_cnpj_interno e fkg_pessoa_id_cpf_cnpj_uf
-- Rotinas: pkb_integr_nota_fiscal_transp, pkb_reg_pessoa_dest_nf, pkb_reg_pessoa_emit_nf, pkb_acerta_pessoa_nf,
--          pkb_acerta_pessoa_emiss_prop e pkb_acerta_pessoa_terceiro.
--
-- Em 27/08/2013 - Angela Inês.
-- Redmine #590 - Geração da GIA e processo de validação das notas fiscais.
-- As notas ficam inválidas devido as rotinas de validação pkb_consistem_nf.
-- Rotina: pkb_valida_imposto_item.
-- Incluído informações da nota nas mensagens de inconsistência.
-- Rotina: pkb_consistem_nf.
--
-- Em 17/09/2013 - Angela Inês.
-- Redmine #680 - Função de validação dos documentos fiscais.
-- Eliminar a alteração de alguns processos que invalidam a nota fiscal, pois o mesmo processo é feito nas rotinas principais.
-- Rotinas: pkb_integr_nfregist_analit_ff e pkb_integr_nfregist_analit.
-- Excluir os registros relacionados a agendamento de transporte (registros filho: nf_agend_transp_pdf e nf_obs_agend_transp).
-- Rotina: pkb_gera_agend_transp.
-- Invalidar a nota fiscal no processo de consistência dos dados, se o objeto de referência for NOTA_FISCAL.
-- Rotina: pkb_consistem_nf.
--
-- Em 26/09/2013 - Rogério Silva
-- Inclusão do processo de integração do Item da Nota Fiscal - Processo Flex Field (FF)
--
-- Em 27/09/2013 - Rogério Silva
-- Alteração da origem da mercadoria, adicionado o valor 8.
--
-- Em 03/10/2013 - Angela Inês.
-- Redmine #1043 - Ficha HD 66893 - Validação pis cofins.
-- O processo está pedindo para inserir natureza da base de cálculo do crédito sendo que a cst é 70 operação de entrada sem direito a crédito.
-- O processo passa a exigir Código de Base de Crédito para PIS e COFINS com CST entre 50 and 56 e 60 e 66.
-- Rotinas: pkb_integr_nfcompl_operpis e pkb_integr_nfcompl_opercofins.
--
-- Em 08/10/2013 - Rogério Silva
-- Redmine #1030
-- Criado o procedimento PKB_INTEGR_NOTA_FISCAL_MDE, para validação do MDE.
--
-- Em 16/08/2013
-- Redmine #1031, #1032 e #1035
-- Criado os procedimentos procedure pkb_rel_cons_nfe_dest, procedure pkb_rel_down_nfe e procedure pkb_reg_aut_mde.
--
-- Em 22/10/2013 - Angela Inês.
-- Redmine #1199 - Fábio/Adidas.
-- Alterações para CFOP 2902 e 5557:
-- Rotina: pkb_vlr_fiscal_item_nf: alterar o valor da base de cálculo para 0(zero) quando a cst de IPI for 02, 03, 52 e 53.
-- Alterações para CFOPs 3551 e 3949:
-- Rotina: pkb_vlr_fiscal_item_nf: zerar os valores de ipi para as cfops 3551 e 3949, mantendo o valor da operação/contábil em base outras.
--
-- Em 06/11/2013 - Angela Inês.
-- Redmine #1161 - Alteração do processo de validação de valor dos documentos fiscais.
-- Inclusão da recuperação dos valores de tolerância através dos parâmetros da empresa - utilizar a função pk_csf.fkg_vlr_toler_empresa,
-- e manter 0.03 como valor de tolerância caso não exista o parâmetro.
-- Rotinas: pkb_valida_total_nf, pkb_ajust_base_imp.
--
-- Em 14/01/2014 - Angela Inês.
-- Redmine #1339 - Validação IPI para NF Terceiro - Ficha HD 66836.
-- Para notas fiscais cuja emissão é terceiro e o imposto de IPI estiver com CST 49: não gerar erro de validação quando base, alíquota e imposto estiver com zero.
--
-- Em 13/02/2014 - Angela Inês.
-- Redmine #1358 - Apuração de ICMS a 2%.
-- 1) Inclusão da rotina de geração de log/alterações nos processos de Apurações de ICMS (tabela: apuracao_icms) - pkb_inclui_log_apuracao_icms.
--
-- Em 20/02/2014 - Angela Inês.
-- Redmine #1979 - Alterar processo nota fiscal devido aos modelos fiscais de serviço contínuo, incluir data de emissão.
-- Rotina: fkg_busca_notafiscal_id.
--
-- Em 07/03/2014 - Angela Inês.
-- Redmine #2243 - Integração de Flex-Field CD_TIPO_RET_IMP para Nota Fiscal Mercantil.
-- Rotina: pkb_integr_imp_itemnf_ff.
--
-- Em 25/03/2014 - Angela Inês.
-- Redmine #2450 - Processo de apuração do sped fiscal icms/ipi com divergência dos registros c190.
-- No processo de apuração icms/ipi é usada a função pk_csf_api.pkb_vlr_fiscal_item_nf: o valor do IPI é zerado de acordo com algumas situações.
-- No processo de geração do sped/arquivo: o valor do ipi é considerado por estar na nfregist_analit.
-- Alterada a montagem do C190: pk_csf_api.pkb_gera_c190.pkb_gera_regist_analit_imp verificando os processos da função que zeram o IPI.
--
-- Em 09/05/2014 - Angela Inês.
-- Redmine #2903 - Notas fiscais de integração: falta de informação nos campos CIDADE_IBGE_EMIT e UF_IBGE_EMIT. Esses campos estão vindo com 0.
-- Alteração: Considerar CIDADE_IBGE_EMIT = 1111111 e UF_IBGE_EMIT = 11, quando vieram com 0(zero).
-- Rotina: pkb_integr_nota_fiscal.
--
-- Em 15/05/2014 - Angela Inês.
-- Redmine #2908 - Verificar relatórios de impostos, de notas fiscais, de livros fiscais, sped fiscal e sped gia, que estão com diferença nos valores.
-- Na integração da nota fiscal será validado se o valor do item bruto é menor do que o valor do desconto, e a nota ficará com erro de validação.
-- Rotina: pkb_integr_item_nota_fiscal.
--
-- Em 03/06/2014 - Angela Inês.
-- Rdemine #3040 - Erro ao integrar nota de serviço contínuo.
-- Ao realizar a integração de notas de serviço contínuo, o compliance está integrando a série incorreta, na view de integração a série está como B1 e
-- subserie = 0, porém ao integrar o compliance considera a série = 0.
-- 1) Ao integrar a nota fiscal, o campo "sub_serie" não estava sendo incluído (insert).
-- Rotina: pk_csf_api.pkb_integr_nota_fiscal.
--
-- Em 16/07/2014 - Angela Inês.
-- Redmine #3272 - Desprocessar Integração - Compliance.
-- Verificar o desprocessamento das integrações: Tabelas que não estão destacadas para exclusão.
-- Rotina: pkb_excluir_dados_nf.
--
-- Em 14/08/2014 - Angela Inês.
-- Redmine #3723 - Verificar os processos que criam/atualizam/excluem o registro analítico dos documentos fiscais.
-- Rotina: pkb_gera_regist_analit_imp.
--
-- Em 21/08/2014 - Angela Inês.
-- Redmine #3788 - Erro no código de participante e Valores de IPI - C190 e E520 - Aline/Adidas.
-- Rotina: pkb_vlr_fiscal_item_nf: acertar os testes de CST de IPI para correção nos valores de base outras e isentas.
-- Rotina: pkb_gera_regist_analit_imp: acertar a recuperação dos valores de IPI devido a CST 49 e 99.
--
-- Em 29/08/2014 - Angela Inês.
-- Redmine #3844 - Problemas ao alterar Natureza de Operação na NFe - Código do Participante está sendo alterado indevidamente.
-- Rotina: pkb_reg_pessoa_emit_nf e pkb_reg_pessoa_dest_nf: alterar pessoa_id em nota_fiscal somente se for 0/nulo.
--
-- Em 01/09/2014 - Angela Inês.
-- Alteradas as variáveis para resumo e mensagem dos logs relacionados: de log_nota_fiscal para log_apuracao_icms.
-- Rotina: pkb_inclui_log_apuracao_icms.
--
-- Em 09/09/2014- Rogério Silva
-- Alteração para que valide o campo NRO_RECOPI como caractere e não como numerico.
-- Rotina: pkb_integr_item_nota_fiscal_ff
-- Redmine: #4065
--
-- Em 18/09/2014 - Angela Inês.
-- Redmine #4415 - Alteração do campo CIDADE_IBGE - Integração da nota fiscal - emitente.
-- Alteração na integração da nota fiscal - emitente (nota_fiscal_emit).
-- 1) Considerar o código 9999999 para o campo CIDADE_IBGE quando a nota for de terceiro e a UF for do exterior, no registro de Emitente.
-- 2) Informar mensagem de erro de validação quando o campo CIDADE_IBGE no Emitente de Nota Fiscal de Terceiro estiver vazio/nulo, pois o campo deve ser informado.
-- Rotina: pkb_integr_nota_fiscal_emit.
--
-- Em 26/09/2014 - Angela Inês.
-- Redmine #4511 - Validação de NCM em NFe de transferência de saldo.
-- Na validação da nota fiscal a ser integrada, permitir que o código NCM seja '00000000' se a CFOP for 5602 e o tipo de operação seja 2-Transferência.
-- CFOP: 5602-Transferência de saldo credor do ICMS, para outro estabelecimento da mesma empresa, destinado à compensação de saldo devedor do ICMS.
-- Rotina: pkb_integr_item_nota_fiscal.
--
-- Em 02/10/2014 - Rogério Silva
-- Redmine: #4631 - Atribuição da FINALIDADE de NFE
-- Rotina: pkb_valida_nota_fiscal
--
-- Em 16/10/2014 - Rogério Silva
-- Redmine #4813 - Criação de validação para os campos obrigatórios e alteração do documento
-- Rotinas alteradas: pkb_valida_inf_issqn e pkb_valida_imposto_item.
--
-- Em 23/10/2014 - Angela Inês.
-- Redmine #4865 - Mensagem de erro de validação incoerente.
-- Ao efetuar o recebimento da nota 1361 é demonstrado que a nota foi recebida, processada mas é dado o seguinte erro de validação:
-- ""Código IBGE da cidade do emitente da Nota Fiscal" inválida (3515004), o código deve ser informado."
-- O Emitente é a empresa 42274696002561 que é da cidade de EMBU e o código IBGE é 3515004.
-- Rotina: pkb_integr_nota_fiscal_emit.
--
-- Em 05/11/2014 - Angela Inês.
-- Redmine #5073 - Correção - Diferença valor GIA-ICMS SISMETAL X Livro de Apuração ICMS (ACECO).
-- Corrigir o processo que retorna os valores fiscais (ICMS/ICMS-ST/IPI) de um item de nota fiscal.
-- 1) Considerar os valores de Impostos do Tipo Simples Nacional (tipo_imposto.cd=10, sigla_imposto=SN), quando o item da nota fiscal não possuir o Imposto
-- do Tipo ICMS (tipo_imposto.cd=1, sigla_imposto=ICMS).
-- Rotina: pkb_vlr_fiscal_item_nf.
--
-- Em 06/10/2014 - Rogério Silva
-- Redmine #5020 - Processo de contagem de registros integrados do ERP (Agendamento de integração)
--
-- Em 12/11/2014 - Rogério Silva
-- Redmine #5175 - Erro ao executar a pk_valida_ambiente.pkb_integracao
-- Rotina: PKB_EXCLUIR_LOTE_SEM_NFE
--
-- Em 18/11/2014 - Rogério Silva
-- Redmine #5018 - Alterar os processos de integração NFe, CTe e NFSe (emissão própria)
-- Rotina: pkb_consistem_nf
--
-- Em 24/11/2014 - Rogério Silva
-- Redmine #5287 - Confirmação Automática do MDe para Barcelos
-- Rotina: pkb_reg_danfe_rec_armaz_terc
--
-- Em 02/12/2014 - Leandro Savenhago
-- Redmine #5412 - Falha na atualização da situação NFe Terceiro (SANTA FÉ)
-- Rotina: PKB_REL_CONS_NFE_DEST
--
-- Em 03/12/2014 - Rogério Silva
-- Redmine #5420 - Nota não integra os itens
-- Rotina: pkb_integr_item_nota_fiscal
--
-- Em 04/12/2014 - Rogério Silva
-- Redmine #5415 - Alteração na ordenação da tela monitoramento da NFE
-- Rotina: pkb_relac_nfe_cons_sit
--
-- Em 26/12/2014 - Angela Inês.
-- Redmine #5616 - Adequação dos objetos que utilizam dos novos conceitos de Mult-Org.
-- Alterar os parâmetros das Rotinas/Funções que passaram a utilizar o parâmetro multorg_id.
-- Incluir o código mult-org = 1, valor default para recuperar os dados de usuário. Rotina: pkb_integr_empr_usuario.
-- Incluir o código mult-org = 1, valor default para inclusão de novo usuário. Rotina: pkb_integr_usuario.
--
-- Em 30/12/2014 - Angela Inês.
-- Redmine #5632 - Alterar erro de validação em nota de importação - compliance rejeita e sefaz aceita.
-- Alterar o tratamento no Compliance que rejeita a nota quando a DI vinculada tem data de desembaraço inferior a 1 ano.
-- Rotina: pkb_integr_itemnf_dec_impor.
--
-- Em 07/01/2015 - Angela Inês.
-- Redmine #5616 - Adequação dos objetos que utilizam dos novos conceitos de Mult-Org.
-- Correção em processos de acordo com o banco Quality.
--
-- Em 21/01/2015 - Rogério Silva.
-- Redmine #5908 - NF-e com item de serviço (ACECO).
-- Atualização de valor retido de ISS nos totais da nota fiscal
-- rotina: PKB_VALIDA_INF_ISSQN
--
-- Em 20/01/2015 - Leandro Savenhago.
-- Redmine #5904 - FALHA NO DOWNLOAD XML
-- Correção na procedure pkb_gera_lote_download_xml.
--
-- Em 26/01/2015 - Rogério Silva
-- Redmine #6041 - Remover campo "NUM_ACDRAW" da tabela "VW_CSF_ITEMNFDI_ADIC" e das integrações
--
-- Em 26/01/2015 - Rogério Silva
-- Redmine #5696 - Indicação do parâmetro de integração
--
-- Em 28/01/2015 - Rogério Silva
-- Redmine #5845 - Criar validação para NF com "Vencimento da Fatura" e "Complemento do Documento Fatura" duplicadas.
--
-- Em 30/01/2015 - Angela Inês.
-- Redmine #6140 - Correção: Integração de IPI não destacado.
-- O processo de integração do imposto flex-field não está considerando o campo/variável corretamente para incluir na tabela oficial
-- IMP_ITEMNF do atributo VL_IMP_NAO_DEST-Valor do imposto não destacado.
-- Rotina: pk_csf_api.
--
-- Em 30/01/2015 - Rogério Silva
-- Redmine #6169 - Ajustar validação para que quando o campo referente a quantidade de exportação for "null", não gerar erro.
-- Rotina: PKB_VALIDA_INFOR_EXPORTACAO
--
-- Em 02/02/2015 - Angela Inês.
-- Redmine #6140 - Correção: Integração de IPI não destacado.
-- 1) Colocar TRIM no teste referente ao nome do atributo a ser integrado.
-- 2) Corrigir o nome do objeto de integração para a função que retorna o valor do atributo: pk_csf.fkg_ff_ret_vlr_number.
-- Rotina: pkb_integr_imp_itemnf_ff.
--
-- Em 05/02/2015 - Rogério Silva.
-- Redmine #6276 - Analisar os processos na qual a tabela CTRL_RESTR_PESSOA é utilizada.
-- Rotinas: pkb_verif_pessoas_restricao e pkb_integr_nota_fiscal_dest.
--
-- Em 10/02/2015 - Angela Inês.
-- Redmine #6320 - Mensagem de aviso em empresa inativa na tela Conversão de NFe Empresa/Terceiro.
-- Rotina: pkb_integr_nota_fiscal.
--
-- Em 11/02/2015 - Rogério Silva.
-- Redmine #6356 - Corrigir as mensagens de erro, acrescentando informações necessárias e efetuar tratamento para não ocorrer erros de constraint.
-- Rotina: pkb_integr_nota_fiscal_compl
--
-- Em 19/02/2015 - Rogério Silva.
-- Redmine #6314 - Analisar os processos na qual a tabela UNIDADE é utilizada.
-- Rotina: pkb_cria_item_nfe_legado
-- Adicionado o multorg_id no insert da tabela unidade
--
-- Em 19/03/2015 - Rogério Silva.
-- Redmine #6315 - Analisar os processos na qual a tabela EMPRESA é utilizada.
-- Rotina: pkb_integr_empresa
-- Adicionado o multorg_id na criação da empresa e recuperação de empresa
--
-- Em 26/03/2015 - Rogério Silva.
-- Redmine #7276 - Falha na integração de notas - BASE HML (BREJEIRO)
-- Rontina: PKB_INTEGR_NOTA_FISCAL_DEST_FF
--
-- Em 30/03/2015 - Angela Inês.
-- Redmine #6684 - Validação de Importação de Nota Fiscal.
-- Implementar uma nova regra de validação de NOta Fiscal, onde ao importar uma NOta Fiscal Mercantil de Terceiro e o modelo for "55-NFe", verificar se existe
-- XML armazenado (DM_ARM_NFE_TERC=1) pela chave de acesso, caso a situação for "cancelada", gerar erro de validação para a NFe de Terceiro.
-- Rotina: pkb_integr_nota_fiscal.
--
-- Em 08/04/2015 - Leandro Savenhago
-- Redmine #7300 - Nota Técnica NF-e 2013/005 - versão 1.22
-- Implementar rotina de criar informações adicionais de impostos
-- Rotina: pkb_gerar_info_trib.
--
-- Em 09/04/2015 - Leandro Savenhago
-- Redmine #7555 - Processo de definir geração do XML de WS Sinal Suframa
-- Rotina: PKB_DEFINE_WSSINAL_SUFRAMA.
--
-- Em 14/04/2015 - Rogério Silva.
-- Redmine #7654 - Erro de validação NF-e Terceiro - TRANSFERENCIA DE SALDO CREDOR (ACECO)
-- Rotina: pkb_integr_item_nota_fiscal
--
-- Em 17/04/2015 - Rogério Silva.
-- Redmine #7687 - Diferimento ICMS
--
-- Em 24/04/2015 - Angela Inês.
-- Redmine #7059 - Critério de escrituração base isenta e base outras (MANIKRAFT).
-- Ajustar o processo que determina a escrituração em base Isenta e Outras, da seguinte forma:
-- 1) CST ICMS = 50 ==>> Base Outras
-- 2) Para os itens que possuam CST de ICMS como 90, porém possuam o % de redução da base de cálculo, fazer o cálculo da redução, e lançar o valor como Isentas,
--    o restante do valor deverá ser escriturado como Outras.
-- Rotina: pkb_vlr_fiscal_item_nf e pkb_vlr_fiscal_nfsc.
--
-- Em 28/04/2015 - Rogério Silva
-- Redmine #7925 - Consulta chave não gera documento na nota_fiscal
-- Rotina: pkb_relac_nfe_cons_sit
--
-- Em 05/05/2015 - Rogério Silva
-- Redmine #8057 - NFe 3.10 - Notas em contingência forçada
-- Rotina: pkb_gera_lote
--
-- Em 14/05/2015 - Angela Inês.
-- Redmine #8395 - Correção na geração da GIA-SP. Registro CR-10.
-- Na função que recupera os valores pk_csf_api.pkb_vlr_fiscal_item_nf verificar:
-- 1) Se CST de ICMS = 51 e valor do imposto = 0: atribuir para o valor de base outras, o valor da base tributada, e zerar o valor da base tributada e o valor da alíquota.
-- Rotina: pk_csf_api.pkb_vlr_fiscal_item_nf.
--
-- Em 18/05/2015 - Rogério Silva.
-- Redmine #8198 - Travar alteração na Forma de Emissão de NFe, quando for EPEC
--
-- Em 22/05/2015 - Rogério Silva.
-- Redmine #7711 - Consistir na integração da emissão nfe dt_emiss superior a 30 dias
-- Rotina: pk_integr_nota_fiscal
--
-- Em 22/05/2015 - Rogério Silva.
-- Redmine #7754 - Registro duplicado NFe própria/terceiro (SANTA FÉ)
-- Rotina: pkb_rel_cons_nfe_dest
--
-- Em 25/05/2015 - Rogério Silva.
-- Redmine #8226 - Processo de Registro de Log em Packages - LOG_GENERICO
--
-- Em 26/05/2015 - Rogério Silva.
-- Redmine #8699 - Alterar integração de destinatario flex-field para ignorar os espaços enviados no campo ATRIBUTO.
--
-- Em 27/05/2015 - Leandro Savenhago
-- Redmine #8781 - Calculo do Regime especial ICMS-ST
-- Rorina: PKB_CALC_ICMS_ST
--
-- Em 27/05/2015 - Angela Inês.
-- Redmine #8792 - Erro de validação na integração de notas.
-- Mudança na mensagem para identificar qual o tipo de imposto faltante de acordo com o tipo de regime de tributação relacionado a nota fiscal emitente.
-- Rotina: pkb_valida_imposto_item.
--
-- Em 02/06/2015 - Rogério Silva.
-- Redmine #7754 - Registro duplicado NFe própria/terceiro (SANTA FÉ)
-- Rotina: pkb_rel_cons_nfe_dest
--
-- Em 05/06/2015 - Angela Inês.
-- Redmine #8543 - Processos que utilizam as tabelas de códigos de ajustes para Apuração do ICMS.
-- Incluir as datas inicial e final na função que recupera o ID do código de ajuste de apuração de icms através do código.
-- Rotina: pkb_integr_inf_prov_docto_fisc.
--
-- Em 09/06/2015 - Leandro Savenhago.
-- Redmine #9073 - Erro de validação - imposto de ICMS ou Simples Nacional (MANIKRAFT).
-- Acertar a obrigatoriedade de imposto de ICMS e Simples Nacional para Emissão de Terceiro
-- Rotina: PKB_VALIDA_IMPOSTO_ITEM.
--
-- Em 11/06/2015 - Rogério Silva.
-- Redmine #8232 - Processo de Registro de Log em Packages - Notas Fiscais Mercantis
--
-- Em 12/06/2015 - Leandro Savenhago.
-- - Tratameto do Retorno de Evento de Cancelamento do MDe.
-- Rotina: PKB_REL_CONS_NFE_DEST.
--
-- Em 17/06/2015 - Angela Inês.
-- Redmine #9271 - Erro Registro C113 SISMETAL (ACECO).
-- Retorno: No processo de integração de notas fiscais, a integração de nota fiscal referenciada não está exigindo a informação do código do participante de
-- nota referenciada, portanto, caso o código não exista no cadastro, o campo fica sem informação (nulo), e ao gerar o sped, esse campo é exigido.
-- Correção: Na integração da nota fiscal referenciada, será validado se a situação do documento fiscal (nota_fiscal.sitdocto_id) for 06 ou 07, o código do
-- participante deverá ser informado (nota_fiscal_referen.pessoa_id).
-- Rotina: pkb_integr_nf_referen.
--
-- Em 30/06/2015 - Rogério Silva.
-- Redmine #9335 -  Ao reenviar uma nota em EPEC, está ficando com o nro de protocolo nulo
--
-- Em 02/07/2015 - Angela Inês.
-- Redmine #9740 - Aliquota ICMS trocada 19% - 4% (ADIDAS).
-- Considerar a Inscrição Estadual nula OU isenta no destinatário da nota fiscal para gerar o imposto ICMS com 4% de alíquota.
-- Rotina: pkb_calc_icms_orig_merc.
--
-- Em 13/07/2015 - Rogério Silva.
-- Redmine #9629 - Falha na integração NFC-e (ADIDAS)
--
-- Em 28/07/2015 - Angela Inês.
-- Redmine #10117 - Escrituração de documentos fiscais - Processos.
-- Inclusão do novo conceito de recuperação de data dos documentos fiscais para retorno dos registros.
--
-- Em 05/08/2015 - Angela Inês.
-- Redmine #10457 - Corrigir integração do SIT_DOCTO na integração de notas.
-- Correção:
-- 1) Se a Nota Fiscal estiver com situação Inutilizada (Nota_Fiscal.dm_st_proc=8): gerar a nota com situação de documento "NF-e ou CT-e : Numeração inutilizada" (sit_docto.cd='05').
-- 2) Se a Nota Fiscal estiver com situação Cancelada (Nota_Fiscal.dm_st_proc=7): gerar a nota com situação de documento "Documento cancelado" (sit_docto.cd='02').
-- 3) Se a Nota Fiscal estiver com situação Denegada (Nota_Fiscal.dm_st_proc=6): gerar a nota com situação de documento "NF-e ou CT-e denegado" (sit_docto.cd='04').
-- 4) Se a Nota Fiscal for de finalidade NF-e complementar (nota_fiscal.dm_fin_nfe=2): permitir envio de situação do documento como sendo "Documento Fiscal Complementar" ou "Documento Fiscal Complementar extemporâneo" (sit_docto.cd='06' ou '07'). Se não for enviado nenhum dos dois, considerar como "Documento Fiscal Complementar" (sit_docto.cd='06').
-- 5) Se a Nota Fiscal não atender aos itens acima, permitir envio de situação do documento como sendo "Documento regular" ou "Documento Fiscal emitido com base em Regime Especial ou Norma Específica" (sit_docto.cd='00' ou '08'). Se não for enviado nenhum dos dois, considerar como "Documento regular" (sit_docto.cd='00').
-- Rotina: pkb_integr_nota_fiscal.
--
-- Em 07/08/2015 - Angela Inês.
-- Redmine #10586 - Processo da API de Notas Fiscais - Exclusão de Log.
-- Alterar pk_csf_api.pkb_integra_nota_fiscal: mudar de lugar o delete da log_generico_nf - tem mensagem sendo gerada antes do delete e não pode deletar.
--
-- Em 02/09/2015 - Angela Inês.
-- Redmine #11377 - Validação de CFOP com Destinatário - Integração de Notas Fiscais.
-- Na validação de CFOP com Emitente e Destinatário da nota, ignorar o item da nota que seja de serviço (item_nota_fiscal.cd_lista_serv not null),
-- pois neste caso o item de serviço poderá estar com a CFOP que indica dentro do estado e o destinatário sendo fora do estado.
-- Rotina: pkb_valida_cfop_por_dest.
--
-- Em 04/09/2015 - Rogério Silva.
-- Redmine #11313 - NFe emissão própria - autorizada no Compliance - cancelada na SEFAZ (VIGOR)
--
-- Em 21/09/2015 - Angela Inês.
-- Redmine #11732 - Integração de Nota Fiscal - Valor líquido da Cobrança.
-- Os valores de origem e líquido da Cobrança devem permanecer NULOs quando forem Zero(0), devido a montagem do XML.
-- Rotina: pkb_integr_Nota_Fiscal_Cobr.
--
-- Em 29/09/2015 - Angela Inês.
-- Redmine #11918 - Função que retorna os valores dos impostos para notas fiscais mercantis.
-- No processo que emite o relatório de apuração é utilizado a rotina/função geral que retorna os valores dos impostos.
-- Alterar o processo que considera o CST-ICMS=90 para:
-- 1) base isenta - quando o percentual de redução for maior que zero(0); e,
-- 2) base outra - quando o percentual de redução for zero(0).
-- Rotina: pkb_vlr_fiscal_item_nf.
--
-- Em 05/10/2015 - Angela Inês.
-- Redmine #11911 - Implementação do UF DEST nos processos de Integração e Validação.
-- Nota fiscal Total Flex-field: Incluir os campos VL_ICMS_UF_DEST e VL_ICMS_UF_REMET.
-- Item da nota fiscal Flex-Field: Incluir o campo COD_CEST.
-- Incluir o grupo de tributação do ICMS para a UF do destinatário: VW_CSF_IMP_ITEMNF_ICMS_DEST.
-- Rotinas: pkb_integr_NotaFiscal_Total_ff, pkb_integr_Item_Nota_Fiscal_ff e pkb_integr_imp_itemnficmsdest.
--
-- Em 16/10/2015 - Angela Inês.
-- Redmine #12084 - Acerto de CFOP.
-- Rotina: pkb_vlr_fiscal_item_nf.
--
-- Em 22/10/2015 - Angela Inês.
-- Redmine #12391 - Implementação das novas colunas nos processos de Integração e Validação.
-- vw_csf_imp_itemnf_icms_dest.perc_comb_pobr_uf_dest.
-- vw_csf_imp_itemnf_icms_dest.vl_comb_pobr_uf_dest.
-- vw_csf_nota_fiscal_total_ff.atributo: vl_comb_pobr_uf_dest.
-- Rotinas: pkb_integr_imp_itemnficmsdest e pkb_integr_notafiscal_total_ff.
--
-- Em 29/10/2015 - Rogério Silva.
-- Redmine #12552 - NFe emissão própria autorizada somente com dados na tb NOTA_FISCAL (TENDÊNCIA).
--
-- Em 30/10/2015 - Angela Inês.
-- Redmine #12591 - Valor de Operação - Resumo de NF e NF/CFOP - Função de valores.
-- Acrescentar no valor da operação (vl_operacao) os valores tributados de icms, pis e cofins quando o item da nota for de importação.
-- Rotina: pkb_vlr_fiscal_item_nf.
--
-- Em 04/11/2015 - Angela Inês.
-- Redmine #12515 - Verificar/Alterar os relatórios que irão atender o Cupom Fiscal Eletrônico - CFe/SAT.
-- Nova rotina: pkb_vlr_fiscal_item_cfe.
--
-- Em 09/11/2015 - Angela Inês.
-- Redmine #12103 - CST 90 - Livro P1 (MANIKRAFT).
-- No processo que emite o relatório de apuração é utilizado a rotina/função geral que retorna os valores dos impostos.
-- Alterar o processo que considera o CST-ICMS=90 para:
-- 1) base isenta - quando o percentual de redução for maior que zero(0); e,
-- 2) base outra - quando o percentual de redução for zero(0).
-- Rotina: pkb_vlr_fiscal_nfsc.
--
-- Em 10/11/2015 - Angela Inês.
-- Redmine #12476 - Rejeição SEFAZ BA - Data de Saida menor que a Data de Emissao (ADIDAS).
-- Correção na integração da data de entrada/saída de acordo com data de emissão e hora de entrada/saída.
-- Rotina: pkb_integr_nota_fiscal.
--
-- Em 11/11/2015 - Angela Inês.
-- Redmine #12525 - Alteração no processo de Integração das Notas Fiscais.
-- Processos - View/Tabela VW_CSF_ITEMNF_COMB_FF/ITEMNF_COMB - Registros de combustíveis do item da nota fiscal.
-- Rotina: pkb_integr_itemnf_comb_ff.
-- Processos - Tabela ITEM_NOTA_FISCAL - Item da Nota Fiscal - Campo DM_MOT_DES_ICMS: 16-Olimpíadas Rio 2016.
-- Rotina: pkb_integr_item_nota_fiscal.
-- Processos - View/Tabela VW_CSF_NF_FORMA_PGTO_FF/NF_FORMA_PGTO - Formas de Pagamento da Nota Fiscal.
-- Rotina: pkb_integr_nf_forma_pgto_ff.
-- Processos - View/Tabela VW_CSF_NOTA_FISCAL_FF/NOTA_FISCAL - Nota Fiscal.
-- Rotina: pkb_integr_nota_fiscal_ff.
--
-- Em 16/11/2015 - Rogério Silva.
-- Redmine #12918 - Inserir um registro na tabela NF_AUT_XML caso não exista e a nota for de empresa da Bahia
--
-- Em 26/11/2015 - Rogério Silva.
-- Redmine #13197 - Acertar o processo de integração
--
-- Em 27/11/2015 - Rogério Silva.
-- Redmine #13211 - Acertar o processo de validação (API)
--
-- Em 27/11/2015 - Rogério Silva.
-- Redmine #13220 - Falha na integração VW_CSF_NOTA_FISCAL_TOTAL_FF (CREMER)
--
-- Em 30/11/2015 - Rogério Silva.
-- Redmine #13259 - Campo NOTA_FISCAL.DM_IND_FINAL (CREMER)
--
-- Em 01/12/2015 - Angela Inês.
-- Redmine #13250 - NFe 3.10 - Erro do validador: 698 - [Simulacao] Rejeicao: Aliquota interestadual do ICMS incompativel com as UF envolvidas na operacao.
-- Consistir as regras de alíquotas 4%, 7% e 12% de notas de produtos importados.
-- Rotina: pkb_integr_imp_itemnficmsdest.
--
-- Em 02/12/2015 - Angela Inês.
-- Redmine #13347 - Rejeicao: Aliquota interestadual do ICMS com origem diferente do previsto.
-- Consistir as regras de alíquotas 4%, 7% e 12% de notas de produtos importados.
-- Rotina: pkb_integr_imp_itemnficmsdest.
--
-- Em 04/12/2015 - Angela Inês.
-- Redmine #13367 - Rejeições do ICMS de UF de Destinatário.
-- Correção nas rejeições do ICMS de UF de Destinatário.
-- Rotina: pkb_integr_imp_itemnficmsdest.
--
-- Em 04/12/2015 - Rogério Silva.
-- Redmine #13404 - Adicionar exclusão da tabela imp_itemnf_icms_dest na procedure pk_csf_api.pkb_excluir_dados_nf
--
-- Em 08/12/2015 - Angela Inês.
-- Redmine #13455 - Acertar a recuperação dos valores de base de ICMS para Notas Fiscais de Serviço Contínuo.
-- Para CST de ICMS 90-Outros, considerar base Isenta quando houver redução de base de cálculo, e considerar base Outras, quando não houver redução de base de cálculo.
-- Rotina: pkb_vlr_fiscal_nfsc.
--
-- Em 11/12/2015 - Angela Inês.
-- Redmine #13583 - Alterar validação de UF de Destinatário.
-- Considerar a UFs de Origem e Destinatário com 7% ou 12%, somente se a origem do produto não for importação.
-- Rotina: pkb_integr_imp_itemnficmsdest.
--
-- Em 16/12/2015 - Rogério Silva.
-- Redmine #13721 - Campo NOTA_FISCAL.DM_IND_FINAL (CREMER-HML)
--
-- Em 16/12/2015 - Rogério Silva.
-- Redmine #13751 - Remover a "trava" que impede que o valor do campo DM_IND_IE_DEST seja alterado em homologação.
--
-- Em 16/12/2015 - Angela Inês.
-- Redmine #13760 - Alterar função que retorna valores contábeis das notas fiscais.
-- Rotinas: pkb_vlr_fiscal_item_nf e pkb_vlr_fiscal_item_cfe.
--
-- Em 17/12/2015 - Angela Inês.
-- Redmine #13793 - Correção na função que recupera valores contábeis para Notas Fiscais de Serviço.
-- Rotina: pk_csf_api.pkb_vlr_fiscal_nfsc.
--
-- Em 17/12/2015 - Angela Inês.
-- Redmine #13796 - Regras da Nota Técnica - 002 e 003 - ICMS para UF de Destinatário.
-- Correção nas regras de validação da Nota Técnica 002 e 003 - ICMS para UF de Destinatário, devido a alguns estados não estarem validando as regras.
-- Destino: recuperar do participante da nota, e caso não tenha recuperar do registro destinatário coluna UF.
-- Origem: recuperar da empresa da nota, e caso não tenha recuperar do registro emitente coluna UF.
-- Caso não encontre destino e/ou origem não fazer os testes da regra de percentuais 7% ou 12%.
-- Rotina: pkb_integr_imp_itemnficmsdest.
--
-- Em 18/12/2015 - Angela Inês.
-- Redmine #13919 - Eliminar as regras da Nota Técnica 2015.002 e 2015.003 - ICMS de UF de Destinatário.
-- Não consistir os percentuais de 4%, 7% e 12%, devido a SEFAZ validar para alguns estados e para outros não.
-- O processo deverá ficar comentado, caso em 01/01/2016, o processo da SEFAZ fique mais coerente com as regras da Nota Técnica.
-- Rotina: pkb_integr_imp_itemnficmsdest.
--
-- Em 11/01/2016 - Angela Inês.
-- Redmine #14414 - Integração de Nota Fiscal - Item da nota com CFOP 5206 e NCM = 00000000.
-- Permitir que seja informado NCM 00000000 (8 zeros), para os itens das notas fiscais que estiverem com CFOP 5206-Anulação de valor relativo a aquisição
-- de serviço de transporte.
-- Rotina: pkb_integr_item_nota_fiscal.
--
-- Em 11/01/2016 - Angela Inês.
-- Redmine #14418 - Integração de Notas Fiscais - Desoneração de ICMS.
-- Desconsiderar a regra de desoneração 7-SUFRAMA com CFOP 6109 e 6110. A SEFAZ não faz mais a validação de CFOP com Desoneração 7-SUFRAMA.
-- Rotina: pkb_integr_item_nota_fiscal.
--
-- Em 04/02/2016 - Fábio Tavares Santana.
-- Redmine #14985 - Implementar na package a integração Flex-Field para o campo COD_CEST da tabela ITEM_NOTA_FISCAL
-- Rotina: pkb_integr_item_nota_fiscal_ff
--
-- Em 05/02/2016 - Rogério Silva
-- Redmine #13079 - Registro do Número do Lote de Integração Web-Service nos logs de validação
--
-- Em 05/02/2016 - Fábio Tavares Santana.
-- Redmine #14986 - Implementação de Localizar a Configuração do Código do CEST para o Item da Nota Fiscal.
-- Rotina: pkb_consistem_nf e pkb_buscar_cod_cest.
--
-- Em 23/02/2016 - Rogério Silva.
-- Redmine #15666 - Erro de validação indevido (VIGOR)
--
-- Em 26/02/2016 - Rogério Silva.
-- Redmine #15796 - Erro ao desprocessar NF de serviço contínuo.
--
-- Em 29/02/2016 - Fábio Tavares
-- Redmine #15902 - Correção na mensagem de log.
--
-- Em 29/02/2016 - Angela Inês.
-- Redmine #15971 - Validação de Série, IEST e MotDesICMS - nas Notas Fiscais.
-- 1) Série da nota: eliminar o zero a esquerda da série da nota fiscal. Rotina: pkb_integr_nota_fiscal.
-- 2) IE do Substituto Tributário: considerar o tamanho de 2 até 14 posições quando informado, e para emissão própria. Invalidar a Nota caso isso ocorra. Rotina: pkb_integr_nota_fiscal_emit.
-- 3) motDesICMS (Motivo da desoneração do ICMS): Incluir rotina para conferir se o Código de Motivo de Desoneração foi informado e se foi informado com Valor de ICMS Desonerado. Invalidar a Nota caso isso ocorra. Rotina: pkb_confere_motivo_vlr_deson.
--
-- Em 01/03/2016 - Rogério Silva.
-- Redmine #15973 - Não está gravando XML do MDE
--
-- Em 04/03/2016 - Angela Inês.
-- Redmine #16205 - Integração de NF - Item da nota com CFOP 1401 e 5601 com NCM = 00000000.
-- Permitir que seja informado NCM 00000000 (8 zeros), para os itens das notas fiscais que estiverem com CFOP 1401-Compra para industrialização ou produção
-- rural de mercadoria sujeita ao regime de substituição tributária (NR Ajuste SINIEF 05/2005) (Decreto 28.868/2006), e 5601-Transferência de crédito de ICMS
-- acumulado.
-- Rotina: pkb_integr_item_nota_fiscal.
--
-- Em 07/03/2016 - Angela Inês.
-- Redmine #16237 - Integração de Notas Fiscais Mercantis - Código NCM.
-- Permitir informação do Código NCM 00000000, independente do CFOPs informado para Notas de Emissão Própria.
-- Rotina: pkb_integr_item_nota_fiscal.
--
-- Em 10/03/2016 - Angela Inês.
-- Redmine #16314 - Exclusão de Nota Fiscal de Serviços Contínuos.
-- 1) Eliminado a exclusão do relacionamento do Lote de Integração Web-Service com a Nota Fiscal (tabela R_LOTEINTWS_NF) no processo de Desprocessar a Integração
-- de Notas Fiscais de Serviço Contínuo.
-- Rotina: pk_despr_integr.pkb_despr_nf_serv_cont.
-- 2) Incluído no processo/api de exclusão da nota fiscal, a exclusão do relacionamento do Lote de Integração Web-Service com a Nota Fiscal (tabela R_LOTEINTWS_NF).
-- Rotina: pk_csf_api.pkb_excluir_dados_nf.
-- 3) Eliminar o relacionamento com o processo MDE (nota_fiscal_mde), Consulta de Evento (csf_cons_sit_evento) e Consulta de Situação (csf_cons_sit), somente se
-- a Nota não estiver armazenamento de XML (nota_fiscal.dm_arm_nfe_terc = 0).
-- Rotina: pk_csf_api.pkb_excluir_dados_nf.
--
-- Em 14/03/2016 - Angela Inês.
-- Redmine #16525 - Validação de Nota Fiscal Mercantil - Série.
-- Ao validar a série da nota fiscal, verificando se tem o 0(zero) como valor inicial, o campo utilizado para comparação é numérico, e o campo
-- nota_fiscal.serie compõe letras, é do tipo caracter.
-- Corrigir a comparação com aspas simples, para que o processo identifique que seja letra/caracter.
-- Rotina: pkb_integr_nota_fiscal.
--
-- Em 30/03/2016 - Rogério Silva.
-- Redmine #17001 - Alteração na validação de NFC-e
--
-- Em 30/03/2016 - Angela Inês.
-- Redmine #17014 - Correção no Valor Contábil - Funções utilizadas em relatórios, gias, sped e livros fiscais.
-- Ao compôr o valor da redução de base, eliminar a subtração da variável de redução de base. Variável: vn_vl_red_bc_icms.
-- Rotinas: pkb_vlr_fiscal_item_nf e pkb_vlr_fiscal_item_cfe.
-- Se o valor da redução de base for negativo, atribuir zero (0) para a variável de redução de base. Variável: vn_vl_red_bc_icms.
-- Rotina: pkb_vlr_fiscal_item_nf.
--
-- Em 31/03/2016 - Rogério Silva.
-- Redmine #17063 - Erro de validação NF-e Terceiro (ACECO)
--
-- Em 01/04/2016 - Rogério Silva.
-- Feedback #17101
--
-- Em 04/04/2016 - Rogério Silva.
-- Redmine #17212 - Alterar a integração de NFe para que o problema declarado na atividade superior não ocorra.
--
-- Em 14/04/2016 - Fábio Tavares
-- Redmine #16793 - Melhoria nas mensagens dos processos flex-field.
--
-- Em 14/04/2016 - Rogério Silva.
-- Redmine #17662 - Remover a obrigatoriedade do campo NRO da tabela NOTA_FISCAL_EMIT
--
-- Em 18/04/2016 - Angela Inês.
-- Redmine #17787 - Correção na validação do campo SERIE da NOTA_FISCAL.
-- Na atividade #15971 tínhamos uma mensagem de erro na montagem do XML com relação ao campo SÉRIE da nota fiscal quando vinha com '01' (zero a esquerda),
-- e a atividade solicitava e eliminação do zero a esquerda que viesse no campo. Devido a essa correção as notas fiscais passaram a duplicar na base dos clientes,
-- pois entravam para validação considerando o campo SÉRIE '01', e ao passar pelo novo teste da validação trocava de '01' para '1', ou seja, a nota era consultada
-- com SÉRIE '01' e era gravada com '1', ao reintegrar, consultamos a chave com '01', não existia, e ao gravar, outro registro era incluído com SÉRIE '1'.
-- Correção: Eliminar o teste de validação e troca do campo SÉRIE, e o tratamento desse campo SÉRIE estará sendo feito na entrada da nota pelo lote Web-Service.
-- Rotina: pkb_integr_nota_fiscal.
--
-- Em 26/04/2016 - Angela Inês.
-- Redmine #18070 - Correção na validação dos PIS e COFINS na Integração da Nota Fiscal.
-- Incluir o tipo de imposto (0-imposto, 1-retenção), para identificar/validar se o item da nota fiscal possui os impostos PIS e COFINS (um ou vários).
-- Incluir o tipo de imposto (0-imposto, 1-retenção), para identificar/validar se o item da nota fiscal possui os impostos PIS e COFINS (cursor: c_dados_imp).
-- Rotina: pkb_valida_imposto_item.
--
-- Em 12/05/2016 - Angela Inês.
-- Redmine #18829 - Correção na validação das Notas Fiscais - Impostos PIS e COFINS.
-- Considerar Código de ST válido somente se o imposto PIS e/ou COFINS for do Tipo Retenção.
-- Rotina: pkb_valida_imposto_item.
--
-- Em 13/05/2016 - Angela Inês.
-- Redmine #18829 - Correção na validação das Notas Fiscais - Impostos PIS e COFINS.
-- Se o imposto PIS for integrado, o imposto COFINS deverá ser integrado com o mesmo Código de ST, Valor de Base de Cálculo e Tipo de Imposto iguais.
-- Se o imposto COFINS for integrado, o imposto PIS deverá ser integrado com o mesmo Código de ST, Valor de Base de Cálculo e Tipo de Imposto iguais.
-- Rotina: pkb_valida_imposto_item.
--
-- Em 19/05/2016 - Rogério Silva.
-- Redmine #19077 - Alteração na validação de NF-e (NFINFOR_ADIC.CONTEUDO)
--
-- Em 24/05/2016 - Rogério Silva.
-- Redmine #19329 - Incluir a soma do valor do Imposto de importação na composição do Valor Contábil/Valor da Operação.
--
-- Em 02/06/2016 - Angela Inês.
-- Redmine #19699 - Validação de Notas Fiscais de Emissão Própria e Modelos '55' e '65'.
-- Incluir o teste na validação das notas fiscais de Emissão Própria e Modelos '55' e '65', com a finalidade de verificar se a data de vencimento do certificado
-- digital da empresa está vencida. Se estiver vencida, gerar uma mensagem de log com "erro de validação", e a nota deverá ficar com o status de
-- "erro de validação".
-- Rotina: pkb_integr_nota_fiscal.
--
-- Em 03/06/2016 - Angela Inês.
-- Redmine #19763 - Correção na montagem do valor da base Outras de ICMS.
-- A nota fiscal de importação, na base do cliente, já compõe na base tributada do icms, o valor do imposto de importação.
-- Portanto, não deve ser somado o valor do imposto de importação em base outras, somente em valor contábil.
-- O valor da base Outras já estará sendo composto pelo valor da base tributada.
-- Rotina: pkb_vlr_fiscal_item_nf.
--
-- Em 06/06/2016 - Angela Inês.
-- Redmine #19666 - Nf de terceiro com chave errada e a nota fica autorizada.
-- Incluir no processo de validação da view vw_csf_nota_fiscal_compl, a mesma validação de chave efetuada no validação da view w_csf_nota_fiscal.
-- Validação: pk_csf_api.pkb_valida_chave_acesso. Rotina: pkb_integr_nota_fiscal_compl.
--
-- Em 07/06/2016 - Angela Inês.
-- Redmine #19874 - Correção na validação da chave da nota fiscal referenciada.
-- Correção na validação da chave da nota fiscal referenciada, permitindo a chave de acesso com modelo '59-Cupom Fiscal Eletrônico - CF-e'.
-- Rotina: pkb_valida_nota_referenciada.
--
-- Em 08/06/2016 - Leandro Savenhago
-- Redmine #19835 - Falha na resposta MD-e (BARCELOS)
-- Foi implementado para recupera o ID da NOTA_FISCAL de Armazenamento de Terceiro, de uma unica empresa, mesmo que o MDe do Governo Retorne para outra
-- Rotina: pkb_rel_cons_nfe_dest.
--
-- Em 17/06/2016 - Angela Inês.
-- Redmine #20365 - Atualização do Código CEST no Item da Nota Fiscal.
-- 1) Se o Código CEST for enviado na integração, vamos manter da integração: VW_CSF_ITEM_NOTA_FISCAL_FF, atributo COD_CEST.
-- 2) Se o Código CEST não for enviado na integração, vamos recuperar do parâmetro (tabela item_param_cest), e ainda considerar se o Item da Nota Fiscal
-- possui o Imposto ICMS-ST (imp_itemnf/tipo_imposto.cd=2).
-- Rotina: pkb_buscar_cod_cest.
--
-- Em 20/06/2016 - Leandro Savenhago.
-- Redmine #20441 - Alteração dos processos de Validação e Integração Open-Interface do Compliance - Campo DM_LEGADO
-- Adaptação do Flex-Field
-- Rotina: PKB_INTEGR_NOTA_FISCAL_FF.
--
-- Em 22/06/2016 - Angela Inês.
-- Redmine #20520 - Melhoria na atualização do indicador de destinatário da Nota Fiscal.
-- Alterar a rotina pkb_valida_nota_fiscal, considerando o grupo de CFOP para correção do campo DM_ID_DEST ao invés dos Estados/UFs da Empresa e Emitente
-- ou Destinatário da nota fiscal. Se o CFOP for do grupo 1 ou 5, considerar o indicador 1; se for do grupo 2 ou 6, considerar o indicador 2; e se for do
-- grupo 3 ou 7, considerar o indicador 3.
-- Rotina: pkb_valida_nota_fiscal.
--
-- Em 22/06/2016 - Angela Inês.
-- Redmine #20525 - Melhoria na rotina que define Código de Enquadramento Legal de IPI - Nota Fiscal.
-- Alteração na Rotina pkb_define_cod_enq_legal_ipi, para que os valores do item da nota fiscal sejam comparados com os valores dos parâmetros.
--
-- Em 24/06/2016 - Angela Inês.
-- Redmine #20596 - Processo de Validação de Notas Fiscais - Cupom Fiscal Referenciado.
-- Ao atualizar a integração do cupom referenciado, o valor do número do documento está sendo atualizado com o valor do número do caixa.
-- Rotina: pkb_integr_cf_ref.
--
-- Em 01/07/2016 - Angela Inês.
-- Redmine #20882 - Validação Nota Fiscal de Entrada/Terceiro - UF destinatário com Chave NFE.
-- Ao validar a UF da Chave da Nota Fiscal, identificar se o Grupo de CFOP pertence a Importação, 3 ou 7, e neste caso, não fazer a validação.
-- Rotina: pkb_valida_chave_acesso.
--
-- Em 04/07/2016 - Angela Inês.
-- Redmine #19645 - Retirar espaço em branco (VIGOR).
-- Ao integrar a NFe retirar os espaços em branco dos campos: NOTA_FISCAL_DEST.IE e NOTA_FISCAL_REFEREN.IE.
-- Rotina: pkb_integr_nf_referen.
--
-- Em 19/07/2016 - Angela Inês.
-- Redmine #21446 - Validação de NF de entrada de Importação - Indicador de Destinatário.
-- Sugestão/Murillo: No select da PK de validação, adicionar o filtro abaixo, pois notas de entrada de importação o destinatário pode ser Nacional:
-- (dm_ind_emit = 0 or dm_ind_emit = 1 and dm_arm_nf_terc = 1).
-- Rotina: pkb_valida_nf_dest.
--
-- Em 19/07/2016 - Angela Inês.
-- Redmine #21460 - Função que retorna os valores dos impostos para notas fiscais mercantis e cupons fiscais eletrônicos.
-- Considerar o CFOP 5605 para zerar os valores de icms e ipi, da mesma forma que é feito para o CFOP 5602.
-- Rotinas: pkb_vlr_fiscal_item_nf, pkb_vlr_fiscal_item_cfe.
--
-- Em 02/08/2016 - Angela Inês.
-- Redmine #21962 - Correção na validação do campo DM_IND_IE_DEST do Destinatário da Nota Fiscal.
-- Caso não exista indicador de inscrição estadual (dm_ind_ie_dest), no destinatário da nota fiscal (nota_fiscal_dest), o processo deverá fazer da seguinte forma:
-- 1) Se houver inscrição estadual no destinatário (nota_fiscal_dest.ie) e o modelo da nota fiscal for '55' ou '65' (nota_fiscal.modfiscal_id/mod_fiscal.cod_mod),
-- atualizar o indicador de inscrição estadual do destinatário para 1-Contribuinte ICMS (informar a IE do destinatário).
-- 2) Não atendendo o item (1), atualizar o indicador de inscrição estadual do destinatário para 9-Não Contribuinte, que pode ou não possuir Inscrição Estadual
-- no Cadastro de Contribuintes do ICMS (nota_fiscal_dest.dm_ind_ie_dest), e anular a inscrição estadual (nota_fiscal_dest.ie).
-- Rotina: pkb_valida_nf_dest.
--
-- Em 05/08/2016 - Angela Inês.
-- Redmine #22139 - Validação de Emitente de Nota Fiscal de Emissão Própria.
-- Quando for emissão própria dm_ind_emit = 0, DM_ARM_NFE_TERC = 0 e o modelo documento for 55 ou 65 e não houver dados
-- na tabela nota_fiscal_emit gerar mensagem de erro de validação dizendo que para emissão da Nfe é necessário dados do emitente.
-- Rotina: pkb_valida_nf_emit.
--
-- Em 02/09/2016
-- Desenvolvedor: Marcos Garcia
-- Redmine #22304 - Alterar os processos de integração/validação.
-- Foi alterado a manipulação dos campos Fone e Fax, por conta da alteração dos mesmos em tabelas de integração.
--
-- Em 08/09/2016 - Angela Inês.
-- Redmine #18250 - Parâmetros de Montagem de "Valor da Operação" para CFOP de Importação e Exportação.
-- Rotinas: pkb_vlr_fiscal_item_nf e pkb_vlr_fiscal_item_cfe.
--
-- Em 16/09/2016 - Angela Inês.
-- Redmine #23467 - Alterar integração considerando dm_st_proc para preencher dm_legado.
-- Rotina: pkb_integr_nota_fiscal.
--
-- Em 27/09/2016 - Angela Inês.
-- Redmine #23820 - Correção no Ajuste de Nota Fiscal pela Tela/Portal.
-- Incluir no processo de ajuste de totais da nota fiscal, utilizado pela tela/portal, a condição do parâmetro que indica se a empresa permite o ajuste, e ainda
-- se a nota possui itens com cfop de importação. Neste caso, a empresa permitindo o ajuste e a nota não possuir itens de importação, o ajuste deverá ser
-- efetuado.
-- Rotina: pkb_ajusta_total_nf.
-- Redmine #23825 - Correção na validação da situação da nota fiscal.
-- Incluir as situações 20 e 21 para serem consideradas na integração da nota fiscal.
-- Rotina: pkb_integr_nota_fiscal.
--
-- Em 13/10/2016 - Angela Inês.
-- Redmine #24350 - Correção na rotina que calcula valor aproximado na integração/validação da Nota Fiscal.
-- O processo de calcular o valor aproximado de tributação deve permanecer da mesma forma com relação a recuperação do valor dos impostos, e atualização dos
-- itens, porém ao atualizar o valor no total da nota deverá ser somado os valores de tributação dos itens, e com isso atualizar o valor total da nota.
-- Rotina: pkb_calc_vl_aprox_trib.
--
-- Em 08/11/2016 - Leandro Savenhago
-- Redmine #25174 - Processo de Utilizar Unidade da Sefaz por NCM na Emissão da Nota Fiscal
-- Rotina: PKB_INTEGR_ITEM_NOTA_FISCAL.
--
-- Em 26/12/2016 - Fábio Tavares
-- Redmine #26486 - Foi ajustado o procedimento para que não seja mantido o código de sit. trib. para os impostos de Simples Nacional
-- Rotina: pkb_vlr_fiscal_item_nf.
--
-- Em 23/01/2017 - Angela Inês.
-- Redmine #27615 - Correção na validação de Notas Fiscais - CFOP por Destinatário/Emitente.
-- Verificar a variável que utilizamos na rotina que valida CFOP por destinatário e/ou emitente, pois o valor da nota_fiscal_dest deveria estar NULO, porque a
-- nota não possui destinatário. Deve ser "sujeira" da base ou informação de nota anterior que havia destinatário.
-- Rotina: pkb_valida_cfop_por_dest.
--
-- Em 25/01/2017 - Leandro Savenhago
-- Redmine #27546 - Adequação dos impostos no DANFE/XML NFe modelo 55 - Lei da transparência
-- Implementado o parâmetro da empresa "Informações de Tributações apenas para Venda" (dm_inf_trib_oper_venda: 0-Não; 1-Sim)
-- Rotina: PKB_GERAR_INFO_TRIB.
--
-- Em 27/01/2017 - Marcos Garcia
-- Redmine #27221 - Processo de Validação dos dados Complemento da Informação de Exportação do Item da NFe
-- Rotina pkb_integr_info_export_compl
-- Obs.: Rotina responsável por validar os dados para a inserção na tabela ITEMNF_EXPORT_COMPL.
--       Dados esses que vem da table/view VW_CSF_ITEMNF_EXPORT_COMPL.
--
-- Em 27/01/2017 - Angela Inês.
-- Redmine #27787 - Validação de Notas Fiscais Mercantis de Emissão Própria - Digitadas.
-- Ao validar a nota fiscal, o processo identifica que a situação como sendo 18-Digitada, não deve ser "integrada" novamente, e não executa o processo do
-- validação corretamente. Alterar o processo para que as notas fiscais com situação 18-Digitada sejam validadas normalmente, da mesma forma que as notas
-- fiscais de integração.
-- Rotina: pkb_integr_Nota_Fiscal.
--
-- Em 31/01/2017 - Angela Inês.
-- Redmine #27904 - Alteração de domínio da Tabela de Declaração de Importação do Item da Nota Fiscal.
-- Inclusão de domínio para a coluna DM_TP_VIA_TRANSP, da tabela ITEMNF_DEC_IMPOR: 11-Courier e 12-Handcarry.
-- Rotina: pkb_integr_itemnf_dec_impor_ff.
--
-- Em 03/02/2016 - Fábio Tavares.
-- Redmine #27380 - Revisão de processos de exclusão - BD
-- Foi adicionado a exclusão do registro da tabela de relacionamento R_CTRLINTEGRARQ_NF.
--
-- Em 06/02/2017 - Angela Inês.
-- Redmine #28038 - Atualizar validação - Geração de informação de orientação de Entrega - Nota Fiscal.
-- Na rotina pk_csf_api.pkb_gera_agend_transp está sendo utilizado a função pk_csf.fkg_empresa_id_pelo_cpf_cnpj que retorna o campo EMPRESA_ID conforme
-- o multorg_id e CPF/CNPJ. Porém estamos enviando como parâmetro de entrada EMPRESA_ID e não MULTORG_ID. Corrigir para que seja enviado o MULTORG_ID.
-- Rotina: pkb_gera_agend_transp.
--
-- Em 13/02/2017 - Leandro Savenhago.
-- Redmine #27311 - REJEIÇÃO: IE DO DESTINATÁRIO!
-- Alterado o procedimento PKB_VALIDA_NF_DEST
--
-- Em 18/02/2017 - Leandro Savenhago.
-- Redmine #28456 - VENDA ORDEM INTERNACIONAL
-- Alterado o procedimento PKB_VALIDA_NOTA_FISCAL
--
-- Em 23/02/2017 - Leandro Savenhago.
-- Redmine #28744 - Aguardar Liberação de Emissão de NFe" indevidamente
-- Rotina: PKB_INTEGR_NOTA_FISCAL
-- Não será atribuído o 21 ao campo DM_ST_PROC, somente se for por parâmetro de empresa
--
-- Em 01/03/2017 - Leandro Savenhago.
-- Redmine #26927 - Divergência entre tabelas do CSF_INT_ENT
-- Rotina: PKB_RELAC_NFE_CONS_SIT
-- Alterado a atualização da tabela NOTA_FISCAL e acrescentado "dm_ret_nf_erp  = 0"
--
-- Em 02/03/2017 - Fábio Tavares.
-- Redmine #28721 - Falha ao integrar dados da vw_csf_nota_fiscal_referen_ff (CREMER)
-- Rotina: PKB_INTEGR_NF_REFEREN_FF
-- Incluido a função trim quando é feita a comparação do registro atributo.
--
-- Em 09/03/2017 - Fábio Tavares
-- Redmine #28949 - Impressão de Local de Retirada e Local de Entrega na Nota Fiscal Mercantil.
--
-- Em 09/03/2017 - Angela Inês.
-- Redmine #29212 - Correção no calculo do valor de icms em Operações Interestaduais de Vendas a Consumidor Final.
-- Considerar os itens de notas fiscais que possuem impostos de ICMS com valor tributado maior que zero(0).
-- Rotina: pkb_calc_icms_inter_cf.
--
-- Em 09/03/2017 - Leandro Savenhago
-- Redmine #29225 - Adição de Tags no XML de NFe para Parker
-- Alterado a limpeza de caracteres especial dos campos ITEM_NOTA_FISCAL.INFADPROD e NFINFOR_ADIC.CONTEUDO
--
-- Em 30/03/2017 - Fábio Tavares
-- Redmine #29773 - AJUSTE NA EMISSÃO DE NFE COM IMPOSTO ICMS E CST 60
-- Rotinas: PKB_VALIDA_IMPOSTO_ITEM e PKB_BUSCAR_COD_CEST.
--
-- Em 04/05/2017 - Angela Inês.
-- Redmine #30748 - Alterar o processo de validação da Nota Fiscal Mercantil - Imposto ICMS e Substituição Tributária - Código CEST.
-- Ao verificar se a nota fiscal possui imposto ICMS com CST indicando Substituição Tributária, e não possui o Código CEST no Item, nao considerar a CST
-- '70-Com redução de base de cálculo e cobrança do ICMS por substituição tributária'. Passar a considerar somente as CSTs: '10-Tributada e com cobrança do
-- ICMS por substituição tributária', '30-Isenta ou não tributada e com cobrança do ICMS por substituição tributária', e '90-Outros'.
-- Rotina: pkb_buscar_cod_cest.
--
-- Em 05/05/2017 - Angela Inês.
-- Redmine #30800 - Alterar o processo de validação da Nota Fiscal - Informações do Grupo de Tributação do Imposto ICMS.
-- Ao validar os percentuais de icms de partilha, verificar se a nota fiscal (tabela: nota_fiscal), em questão, possui nota fiscal referenciada (tabela:
-- nota_fiscal_referen). Utilizar a data de emissão da nota fiscal referenciada, caso contrário, utilizar a data de emissão da nota fiscal em questão.
-- Rotina: pkb_integr_imp_itemnficmsdest.
--
-- Em 09/05/2017 - Angela Inês.
-- Redmine #30892 - Alterar a validação da Nota Fiscal - Data de emissão fora do prazo estabelecido.
-- Ao verificar se a nota fiscal está fora do prazo estabelecido, consideramos se a nota fiscal é de Emissão Própria (nota_fiscal.dm_ind_emit=0), se a data de
-- emissão está fora do prazo limite por estado, e se a nota está com situação de não validada (nota_fiscal.dm_st_proc=0).
-- Passar a verificar também, se a nota está como Não-Legado (nota_fiscal.dm_legado=0). Se a nota estiver como Legado (nota_fiscal.dm_legado<>0), a validação não
-- deverá ser efetuada.
-- Rotina: pkb_integr_nota_fiscal.
--
-- Em 10/05/2017 - Leandro Savenhago
-- Redmine #30054 - Processo de Integração de Nota Fiscal de Serviço versus atualiza dependência de item_id
-- Alterada a rotina para considerar a crição do item (produto ou serviço) para documentos fiscais de escrituração (DM_ARM_NFE_TERC = 0)
-- Rotina: PKB_CRIA_ITEM_NFE_LEGADO.
--
-- Em 11/05/2017 - Angela Inês.
-- Redmine #31005 - Validação do CEST nos Itens das Notas Fiscais.
-- Alterar o processo de busca de CEST, quando estiver nulo no item da nota fiscal, considerando os CSTs 60 e 70.
-- Rotina: pkb_buscar_cod_cest.
--
-- Em 07/06/2017 - Angela Ins.
-- Redmine #31808 - Atualizar o processo de integração de notas fiscais - Data de emissão fora do prazo.
-- A informação sobre DM_LEGADO não é enviada na integração, portanto, o campo/coluna deve ser considerado como 0-Não Legado.
-- Utilizar o comando NVL para tratar o campo/coluna quando o mesmo for nulo.
-- Rotina: pkb_integr_nota_fiscal.
--
-- Em 30/06/2017 - Angela Inês.
-- Redmine #32490 - Alterar na tabela NOTA_FISCAL_FISCO o campo FONE para NULL.
-- Além da coluna FONE também foi alterado para NULL as colunas NRO_DAR, DT_EMISS e VL_DAR.
-- O processo de validação foi alterado, eliminado a obrigatoriedade das colunas.
-- Rotina: pkb_integr_nota_fiscal_fisco.
--
-- Em 03/08/2017 - Angela Inês.
-- Redmine #33361 - Alterar a validação dos dados da DI nas Notas Fiscais - Importação.
-- Incluir o CFOP 3930 nos processos de validação dos dados da DI, para inicializar as colunas DM_TP_VIA_TRANSP, VAFRMM, DM_TP_INTERMEDIO.
-- Os valores das colunas são inicializados com DM_TP_VIA_TRANSP=1-Marítima, VAFRMM=0, DM_TP_INTERMEDIO=1-Importação por conta própria.
-- Rotina: pkb_valida_infor_importacao.
--
-- Em 21/08/2017 - Angela Inês.
-- Redmine #33890 - Alterar o processo de relacionamento de Consulta de NFe Destinadas.
-- 1) Recuperar a raiz do CNPJ da empresa do lote da consulta de nfe destinatário (lote_cons_nfe_dest.empresa_id/empresa.pessoa_id/juridica.num_cnpj).
-- 2) Recuperar o parâmetro da empresa do lote da consulta de nfe destinatário que indica o "Indicador do Emissor" (lote_cons_nfe_dest.empresa_id/empresa/
-- empr_param_cons_mde.dm_ind_emi). Menu: Administração/Empresa/Aba Parâmetros do MDE.
-- 3) Verificar se temos algum processo utilizando esse campo EMPR_PARAM_CONS_MDE.DM_IND_EMI. Segundo o Leandro é antigo e foi utilizado somente pelo Java/Mensageria.
-- 4) Recuperar a raiz do CNPJ da chave de identificação da nota fiscal (cons_nfe_dest.nro_chave_nfe).
-- 5) Fazer o teste: se o item 2 for "1-Somente as NF-e emitidas por emissores / remetentes que não tenham a mesma raiz do CNPJ do destinatário (para excluir as
-- notas fiscais de transferência entre filiais)", e se o item 1 for igual ao item 4: o processo não deverá prosseguir, não será gerado registro de ciência da
-- operação.
-- Rotina: pkb_rel_cons_nfe_dest.
--
-- Em 22/08/2017
-- Redmine Defeito #33937
-- Correção na geração do relatório DIFAL
-- Rotina PKB_CALC_DIF_ALIQ verificar valores: itemnf_id, aliq_orig, aliq_ie, vl_bc_icms, vl_dif_aliq, antes de fazer a inserção na tabela itemnf_dif_aliq.
-- Ao menos um valor deve ser > 0
--
-- Em 25/08/2017 - Marcelo Ono
-- Redmine #33869 - Valida se o participante está cadastrado como empresa, se estiver cadastrado como empresa, não deverá atualizar os dados do participante
-- Rotina: pkb_integr_empresa, pkb_reg_pessoa_dest_nf, pkb_reg_pessoa_emit_nf, pkb_reg_pessoa_emit_nf.
--
-- Em 28/08/2017 - Angela Inês.
-- Redmine #34058 - Correção no processo da Calculadora Fiscal.
-- Alterar o identificador do CFOP (cfop_id) e o código do CFOP (cfop), no item da nota fiscal (item_nota_fiscal), após o processo da calculadora fiscal.
-- Rotina: pkb_solic_calc_imp.
--
-- Em 31/08/2017 - Angela Inês.
-- Redmine #34225 - Geração do Item da Solicitação de Cálculo - Processo da Calculadora Fiscal.
-- Atualizar os valores de domínio dos campos do Item da Solicitação de Cálculo, de acordo com os valores informados no Item da Nota Fiscal:
-- item_solic_calc.dm_mod_base_calc := item_nota_fiscal.dm_mod_base_calc;
-- item_solic_calc.dm_mod_base_calc_st := item_nota_fiscal.dm_mod_base_calc_st;
-- item_solic_calc.dm_mot_des_icms := item_nota_fiscal.dm_mot_des_icms;
-- Rotina: pkb_solic_calc_imp.
--
-- Em 11/09/2017 - Leandro Savenhago
-- Redmine #34486 - Divergência na geração livro CFOP 1556/2556 (MANIKRAFT)
-- Rotina: PKB_VLR_FISCAL_ITEM_NF.
-- Comentado tratamento do CFOP 1556, 2556 e 3556
--
-- Em 11/09/2017 - Leandro Savenhago
-- Redmine #34486 - Divergência na geração livro CFOP 1556/2556 (MANIKRAFT)
-- Rotina: PKB_CALC_ICMS_INTER_CF.
-- Comentado tratamento do CFOP 1556, 2556 e 3556
--
-- Em 19/09/2017 - Leandro Savenhago.
-- Redmine #34429 - API de Integração 06 – Nota Fiscal Mercantil para NFe 4.00
--
-- Em 21/09/2017 - Marcelo Ono.
-- Redmine #33524 - Implementado validação, para não permitir o percentual de diferimento menor ou igual a 0 para impostos ICMS com o CST 51 (Diferimento).
-- Rotina: pkb_integr_imp_itemnf.
--
-- Em 27/09/2017 - Marcos Garcia
-- Redmine # 34935 - Digitação NF-e via Compliance.
-- Campos estão com valores 0 e precisão ficar com valores nulos. VL_ICMS_OPER e VL_ICMS_DIFER
--
-- Em 27/09/2017 - Angela Inês.
-- Redmine #35018 - Correção nos processos geração de notas fiscais inutilizadas, consulta de situação de NF e NF destinadas.
-- De acordo com informações do Leandro, devemos alterar o identificador de impressão da DANFE (nota_fiscal.dm_impressa), para "3-Não se aplica" nos seguintes
-- processos: Atualização de NF-e inutilizadas; Relacionamento da Consulta de Situação da NFe; e, Relacionamento de Consulta de NFe Destinadas.
-- Rotinas: pkb_atual_nfe_inut, pkb_relac_nfe_cons_sit e pkb_rel_cons_nfe_dest.
--
-- Em 29/09/2017 - Marcelo Ono.
-- Redmine #34948 - Correções no processo de Integração Table/view 06 Nota Fiscal Mercantil NFe 4.00.
-- 1-Incluído a exclusão dos registros da tabela ITEMNF_RASTREAB.
-- 2-Alterado processo para validar se a data de fabricação é maior que data de validade.
-- Rotinas: pkb_excluir_dados_nf e pkb_integr_itemnf_rastreab.
--
-- Em 04/10/2017 - Angela Inês.
-- Redmine #35243 - Correção na geração do registro de Autorização para obter XML - Notas Fiscais Mercantis.
-- 1) Verificar se o registro já existe na tabela com a nota fiscal e CPF em questão. Neste caso, não gerar outro registro.
-- 2) Verificar se o registro já existe na tabela com a nota fiscal e CNPJ em questão. Neste caso, não gerar outro registro.
-- Rotinas: pkb_integr_nf_aut_xml e pkb_define_cpf_cnpj_cont.
--
-- Em 11/10/2017 - Fábio Tavares
-- Redmine #33862 - Integração Complementar de NFS para o Sped Reinf - Desprocessamento de Integração
-- Rotina: pkb_excluir_dados_nf.
--
-- Em 11/10/2017 - Angela Inês.
-- Redmine #35439 - Correção na validação do imposto ICMS dos itens das notas fiscais mercantis.
-- 1) Alterar para 0(zero) os valores dos campos VL_ICMS_OPER e VL_ICMS_DIFER, se estiverem nulos, e ainda se o CST do imposto ICMS for "51-Diferimento. A
-- exigência do preenchimento das informações do ICMS diferido fica à critério de cada UF."
-- Rotina: pkb_integr_imp_itemnf.
--
-- Em 24/10/2017 - Angela Inês.
-- Redmine #35816 - Correção de base de calculo com ICMS por dentro.
-- Correção no cálculo do DIFAL - Validação/Integração da Nota Fiscal Mercantil.
-- Fazer o cálculo conforme exemplo para os estados MG ou BA:
-- Base Calc. DIFAL = ((imp_itemnf.vl_base_outro ou imp_itemnf.vl_base_calc - param_dif_aliq_forn.aliq_orig ou 12%) / (1 - param_dif_aliq_forn.aliq_ie ou 18% / 100))
-- Valor DIFAL = ((Base Calc. DIFAL * param_dif_aliq_forn.aliq_ie ou 18% / 100) - param_dif_aliq_forn.aliq_orig ou 12%)
-- Rotina: pkb_calc_dif_aliq.
--
-- Em 25/10/2017 - Angela Inês.
-- Redmine #35842 - Novo Cálculo - Correção de base de calculo com ICMS por dentro.
-- De acordo com a consultoria, o cálculo estava incorreto, passar a calcular da seguinte forma:
-- Base Calc. DIFAL = ((100,00 - (100,00 * 12/100)) / (1-(18/100))) = 107,32
-- Base Calc. DIFAL = ((imp_itemnf.vl_base_outro ou imp_itemnf.vl_base_calc - (imp_itemnf.vl_base_outro ou imp_itemnf.vl_base_calc * param_dif_aliq_forn.aliq_orig ou 12% / 100)) / (1 - param_dif_aliq_forn.aliq_ie ou 18% / 100))
-- Valor DIFAL = ((107,32 * 18 / 100) - (100,00 * 12/100)) = 7,32
-- Valor DIFAL = ((Base Calc. DIFAL * param_dif_aliq_forn.aliq_ie ou 18% / 100) - (imp_itemnf.vl_base_outro ou imp_itemnf.vl_base_calc * param_dif_aliq_forn.aliq_orig ou 12% / 100))
-- Rotina: pkb_calc_dif_aliq.
--
-- Em 27/10/2017 - Marcelo Ono
-- Redmine #35937 - Inclusão do parâmetro de entrada empresa_id, para que seja filtrado a empresa do documento na execução das rotinas programáveis.
-- Rotina: pkb_consistem_nf.
--
-- Em 07/11/2017 - Leandro Savenhago
-- Melhoria da geração de lote de NFe
-- Rotina: pkb_gera_lote.
--
-- Em 14/11/2017 - Leandro Savenhago
-- Redmine #36486 - Calculo FCP - ICMS em Operacoes Interestaduais de Vendas a Consumidor Final
-- Rotina: PKB_CALC_ICMS_INTER_CF.
--
-- Em 13/11/2017 - Marcelo Ono
-- Redmine #35530 - Implementado processo na integração de complemento de serviço, para inclusão e alteração do centro de custo na tabela ITEMNF_COMPL_SERV.
-- Rotina: pkb_integr_itemnf_compl_serv.
--
-- Em 23/11/2017 - Marcelo Ono
-- Redmine #36037 - Alterações no processo de busca do código CEST.
-- 1- Implementado processo para buscar o código CEST, Indicador de Produção em Escala, CNPJ do fabricante e Código de ocorrência de Ajuste de ICMS
-- filtrando por EMPRESA_ID, CFOP_ID, NCM_ID e ITEM_ID.
-- 2- Implementado processo para buscar o código CEST, Indicador de Produção em Escala, CNPJ do fabricante e Código de ocorrência de Ajuste de ICMS
-- filtrando por EMPRESA_ID, CFOP_ID.
-- 3- Atualização do item da nota fiscal com as informações da Tabela Parâmetros de DE-PARA do CEST (código CEST, Indicador de Produção em Escala,
-- CNPJ do fabricante e Código de ocorrência de Ajuste de ICMS).
-- Rotina: pkb_buscar_cod_cest.
--
-- Em 24/11/2017 - Marcelo Ono
-- Redmine #36192 - Implementado o parâmetro "en_ret_underline" com o valor 0 (Não) no processo de conversão de caracteres especiais para o pedido
-- de compra da Nota Fiscal e do Item da Nota Fiscal.
-- Rotina: pkb_integr_nota_fiscal, pkb_integr_item_nota_fiscal.
--
-- Em 27/11/2017 - Marcos Garcia
-- Redmine # - 35997
-- Processo alterado para o cancelamento de nota fiscais, por conta do atributo ID_ERP, que é o novo valor do campo atributo da
-- view VW_CSF_NOTA_FISCAL_CANC_FF.
--
-- Em 30/11/2017 - Marcelo Ono
-- Redmine #36975 - Implementado processo na validação de CFOP por destinatário.
-- Se a UF do emitente for diferente da UF do destinatário e a UF do destinatário for "EX", deverá respeitar a seguinte regra:
-- Nota Fiscal com operação de Entrada: Primeiro dígito do CFOP deve ser igual a 3.
-- Nota Fiscal com operação de Saída:   Primeiro dígito do CFOP deve ser igual a 7.
-- Rotina: pkb_valida_cfop_por_dest.
--
-- Em 11/01/2018 - Angela Inês.
-- Redmine #38381 - Correção na geração do Sped Fiscal e Validação de Notas Fiscais.
-- Ao validar a nota fiscal e atualizar a situação do documento, considerar as notas de situação 6-Denegada (nota_fiscal.dm_st_proc=6), e atualizar a situação
-- do documento (sit_docto), para 04-NF-e ou CT-e denegado (sit_docto.cd).
-- Rotina: pkb_atual_sit_docto.
--
-- Em 19/01/2018 - Marcelo Ono
-- Redmine #38694 - Implementações nos processos da NFe 4.0.
-- 1- Implementado o valor default "0" para os campos "VL_FCP, VL_FCP_ST, VL_FCP_ST_RET e VL_IPI_DEVOL" da tabela "NOTA_FISCAL_TOTAL", quando os mesmos não forem informados.
-- 2- Implementado a atualização de valores nos campos "VL_FCP, VL_FCP_ST, VL_FCP_ST_RET e VL_IPI_DEVOL" da tabela "NOTA_FISCAL_TOTAL", quando o parâmetro "Ajusta Total NF" estiver ativo.
-- Rotina: pkb_integr_nota_fiscal_total.
--
-- Em 01/02/2018 - Leandro Savenhago
-- Redmine #38939 - Performance dos Processos PL-SQL na Nuvem
-- Separação de fila de execução por MultOrg
--
-- Em 01/02/2018 - Angela Inês.
-- Redmine #39081 - Validação de MDe de NFe (Manifesto do destinatário) por Job Scheduller.
-- Rotinas: pkb_rel_cons_nfe_dest, pkb_rel_down_nfe, pkb_reg_aut_mde, pkb_reg_danfe_rec_armaz_terc, pkb_gera_lote_mde e pkb_gera_lote_download_xml.
--
-- Em 12/02/2018 - Leandro Savenhago
-- Redmine #39392 - Sped Fiscal - Validação e Geração do arquivo do Sped está demorando por volta de 45 minutos
-- Rotinas: PKB_ACERTA_VINC_CADASTRO
--
-- Em 22/02/2018 - Angela Inês.
-- Redmine #39703 - Correção nas validações das notas fiscais Mercantis e de Serviço Contínuo - Informações de Energia Elétrica.
-- Alterar o processo de validação de notas fiscais mercantis, eliminando a obrigatoriedade dos campos: DM_TP_LIGACAO, DM_COD_GRUPO_TENSAO e DM_TP_ASSINANTE.
-- Essas informações são relacionadas as notas fiscais de serviço contínuo.
-- Rotina: pkb_integr_nota_fiscal_compl.
--
-- Em 15/03/2018 - Angela Inês.
-- Redmine #40584 - Alterar o processo de exclusão de nota fiscal.
-- Ao excluir a nota fiscal incluir a exclusão do relacionamento da nota fiscal com Diferencial de Alíquota do Resumo de ICMS para Nota Fiscal de Serviço
-- Contínuo (tabela nfregist_analit_difal).
-- Rotina: pkb_excluir_dados_nf.
--
-- Em 27/04/2018 - Angela Inês.
-- Redmine #39942 - Acompanhar e atualizar os processos de Performance - Amazon PRD.
-- Foi desmembrado o cursor principal, deixando o primeiro cursor como sendo somente a tabela do LOTE (lote_cons_nfe_dest), e o segundo cursor somente com a
-- tabela de CONSULTA (cons_nfe_dest), o relacionamento é através do LOTE processado. Ainda vamos considerar o NVL na nota_fiscal, porém teremos menos Lote
-- consultados. Foi corrigido também o contexto da rotina que possuia muitos SELECTs repetidos e funções junto com INSERTs.
-- Deixamos a rotina antiga com o nome pk_csf_api.pkb_rel_cons_nfe_dest_old.
-- Rotina: pkb_rel_cons_nfe_dest e pkb_rel_cons_nfe_dest_old.
--
-- Em 11/05/2018 - Angela Inês.
-- Redmine #42748 - Correção no processo de validação de notas fiscais mercantis.
-- Situação: A nota fiscal enviada pela View de Integração, não envia o ID, e a nota não foi encontrada no Compliance. Com isso, recuperamos um ID de nota fiscal,
-- através de sequence de banco de dados. Esse ID encontrado já existia na base do cliente com outra nota fiscal, e diante disso a nota fiscal enviada pela View
-- sobrepôs uma nota fiscal já existente no Compliance, e possui um ID enviado do ERP/SGI.
-- Correção: O processo na PK_CSF_API.PKB_INTEGR_NOTA_FISCAL deverá identificar que a Nota Fiscal não existe no Compliance com a chave (fkg_busca_notafiscal_id), e
-- que o ID recuperado pela sequence também não exista. Caso seja encontrado, não gravar a nota fiscal e gerar mensagem de erro.
-- Rotina: pkb_integr_nota_fiscal.
--
-- Em 15/05/2018 - Angela Inês.
-- Redmine #42849 - Melhoria no processo de Consulta de NFe Destinatário.
-- 1) Incluir o identificador da Empresa (empresa.id) no LOG (log_generico_nf), que informa: "NFe criada a partir da consulta de dados Destinados a empresa".
-- 2) Incluir LOG indicando que a nota fiscal foi gerada porém não foi criado o MDE, processo de inclusão do registro de MDE (nota_fiscal_mde).
-- 3) Ao considerar as consultas das notas de destinatário, alterar a condição de identificadores. Hoje o processo está relacionando o ID da tabela cons_nfe_dest
-- com o ID da tabela lote_cons_nfe_dest, erroneamente. Alterar para que seja utilizado a coluna LOTECONSNFEDEST_ID da tabela CONS_NFE_DEST, com o ID da tabela
-- LOTE_CONS_NFE_DEST.
-- Rotina: pkb_rel_cons_nfe_dest.
--
-- Em 17/05/2018 - Karina de Paula
-- #42781 - Cálculo de FCP para NFe 4.0 - Modelo Simples
-- Rotina Alterada: PKB_INTEGR_IMP_ITEMNF_FF - Foi incluído na verificação dos atributos Valor da Base de Cálculo - VL_BC_FCP, Alíquota - ALIQ_FCP
-- e Valor do Imposto - VL_FCP se o tipo de imposto é ICMS ou ICMS-ST. Se não for gera mensagem de informação e carrega null p os valores
-- Rotina Criada: Foi criada a rotina pkb_calc_fcp para que é chamada pela PKB_CONSISTEM_NF para validar se quando o tipo de imposto for
-- ICMS ou ICMS-ST e a aliquota da fcp não for nula calcular os campos Valor da Base de Cálculo - VL_BC_FCP e Valor do Imposto - VL_FCP
-- *** Não foi alterada a rotina de atualização da nota_fiscal_total
--
-- Em 17/05/2018 - Karina de Paula
-- Rotina Alterada: pkb_integr_nf_forma_pgto - Incluída mensagem de log (informação) quando o tipo de pagamento (NF_FORMA_PGTO.DM_TP_PAG)
-- for igual a 14=Duplicata Mercantil. Porque a partir da versão NT_2016_002 esse tipo não será mais aceito
--
-- Em 02/06/2018 - Marcelo Ono
-- Redmine #43088 - Implementado a exclusão das informações de impostos adicionais de aposentadoria especial.
-- Rotina: pkb_excluir_dados_nf.
--
-- Em 04/06/2018 - Marcelo Ono
-- Redmine #00000 - Retirado o processo implementado pelo Leandro Savenhago, referente a otimização de performance.
-- Obs: Este processo ainda está incompleto, conforme alinhado com o Carlos e o Marcos.
-- Rotina:
--
-- Em 12/06/2018 - Angela Inês.
-- Redmine #43886 - Correção na validação de Notas Fiscais Mercantis - Forma de Pagamento.
-- Ao validar o campo de valor de pagamento, VL_PGTO, no processo de Forma de Pagamento, NF_FORMA_PGTO, estamos considerando que o Valor seja Maior ou Igual a Zero.
-- Porém, ao identificar o registro com todos os campos informados, estamos considerando que o Valor deva ser Maior que Zero.
-- Alterar o essa condição, considerando que o Valor deva ser Maior ou Igual que Zero.
-- Rotina: pkb_integr_nf_forma_pgto.
--
-- Em 12/06/2018 - Marcos Ferreira.
-- Redmine #43427 - Erro no envio do e-mail quando consta mais de um destinatário.
-- Problema: Quando no XML da Nota fiscal vem com mais de um e-mail, separado por ";", o sistema dá um erro na hora de fazer o envio
-- Correção: Remover o replace ';', '' da rotina
-- Rotina: pkb_integr_nfdest_email.
--
-- Em 14/06/2018 - Marcos Ferreira.
-- Redmine #41514 - Não carrega as informações de VL_BASE_CALC e ALIQ_APLI na integração WS.
-- Problema: Quando é nota fiscal mercantil, para não dar problema na geração do xml, a rotina nula o campo base de calculo e aliquota,
--           Mas isso não pode ocorrer para notas Mercantils de Terceiros
-- Correção: Incluído checagem de dm_ind_emit = 0 antes de nular estes campos
-- Rotina: pkb_integr_imp_itemnf.
--
-- Em 15/06/2018 - Angela Inês.
-- Redmine #43601: Integração dos Dados de Pagamentos na NFe - Limpar campos com espaços.
-- Melhoria nas mensagens de Forma de Pagamento.
-- Rotina: pkb_integr_nf_forma_pgto.
--
-- Em 22/06/2018 - Karina de Paula
-- Redmine #43816 - Incidência de IPI na Base ICMS
-- Rotina Alterada: PKB_INTEGR_NOTA_FISCAL_FF, PKB_GERAR_INFO_TRIB e PKB_VALIDA_NOTA_FISCAL - Incluído no DM_IND_FINAL valor 7-Industria / Consumo Final
--
-- Em 27/06/2018 - Karina de Paula
-- Redmine 44299 - Nova opção de Documento para Infor. Exportação
-- Rotina Alterada: pkb_integr_info_export_compl => Incluído novo valor 2-Declaração Unica de exportação para o campo DM_IND_DOC
--
-- Em 28/06/2018 - Angela Inês.
-- Redmine #44515 - Processo do Sped EFD-Contribuições: Cálculo, Validação e Geração do Arquivo.
-- Alterar o processo que utiliza a função pk_csf_efd_pc.fkg_gera_cred_nfpc_cfop_empr, para considerar apenas o imposto PIS e identificar a informação com o CST.
-- Rotina: pkb_val_cred_nf_pessoa_fisica.
--
-- Em 03/07/2018 - Karina de Paula
-- Redmine #32743 - Pessoa_id diferente do destinatário informado (Usina Santa Vitoria)
-- Rotina Alterada: PKB_INTEGR_NOTA_FISCAL_DEST => Foi criado na pk_csf_api a verificação se existe pessoa_id para o destinatário fechando
-- no CNPJ ou CPF e também verificando a cidade ibge e a UF do destinatário, para não correr o risco de trazer pessoa_id com o mesmo número
-- de documento porém de cidade diferente. Essa verificação foi incluída devido à problemas de cadastro duplicado que estava retornando pessoa_id de outra cidade
--
-- Em 03/07/2018 - Marcelo Ono.
-- Redmine #41705 - Implementado a integração dos campos "tipo de serviço Reinf e indicador do CPRB" no item da nota fiscal.
-- Rotina: pkb_integr_item_nota_fiscal_ff.
--
-- Em 04/07/2018 - Angela Inês.
-- Redmine #44696 - Atualização na validação da Nota Fiscal Mercantil - Valor de Desconto - Cobrança.
-- Manter o valor que vier na integração da Nota Fiscal.
-- Será tratado na montagem do XML a versão da Nota Fiscal, para enviar com Nulo se for Versão diferente de 4.0.
-- Rotina: pkb_integr_nota_fiscal_cobr.
--
-- Em 05/07/2018 - Angela Inês.
-- Redmine #44714 - Correção no processo de validação da Nota Fiscal Mercantil - Informações de Cana de Açúcar.
-- No processo que valida as informações de Cana de Açúcar, temos a rotina que verifica se a somatória dos tipos de Deduções de cana é diferente a declarada
-- mensalmente. Nessa verificação o agrupamento utilizado está incorreto, conforme atividade principal. Passar a agrupar pela coluna VL_TOTAL_DED, que é a coluna
-- utilizada no select.
-- Rotina: pkb_valida_aq_cana.
-- Redmine #41408 - Tratamento no retorno erro do XML.
-- Alteração na validação do Percentual de ICMS Interestadual - Nota Fiscal Mercantil.
-- Ao validar o Percentual de ICMS Interestadual, verificar os valores relacionados a mudança da NFe 4.0.
-- Os valores poderão ser 4%, 7% e 12%, dependendo dos Estados/UF do destinatário. As validações NÃO IRÃO INVALIDAR a nota fiscal, pois ainda estamos atendendo
-- a NFe 3.10, que não exige essas alíquotas, podendo ser 0(zero). Os logs/mensagens de inconsistência serão gerados como advertência/aviso.
-- Rotina: pkb_integr_imp_itemnficmsdest.
--
-- Em 10/07/2018 - Angela Inês.
-- Redmine #44791 - Correção na validação de Forma de Pagamento - NF Mercantil.
-- Verificar se o tipo de integração para pagamento é 1-Pagamento integrado com o sistema de automação da empresa, e neste caso os campos CNPJ, Tipo de Bandeira
-- e Número de Autorização, devem ser informados, caso contrário, se o tipo de integração para pagamento é 2-Pagamento não integrado com o sistema de automação
-- da empresa, os campos CNPJ, Tipo de Bandeira e Número de Autorização, não devem ser informados.
-- Rotinas: pkb_confere_nfformapgto e pkb_consistem_nf.
-- Redmine #44799 - Correção no processo validação do Total da Nota Fiscal - Registro já existente.
-- Identificar se a nota fiscal já possui registro de Total ao validar a mesma. Caso já exista, alterar os valores do registro (update), do contrário, manter a
-- inclusão do mesmo (insert).
-- Rotina: pkb_integr_nota_fiscal_total.
--
-- Em 11/07/2018 - Angela Inês.
-- Redmine #44847 - Correção na validação da Nota Fiscal Mercantil - Forma de Pagamento.
-- Ao recuperar os valores de forma de pagamento da nota fiscal, considerar o identificador da nota fiscal (NOTAFISCAL_ID).
-- Rotina: pkb_confere_nfformapgto.
--
-- Em 24/07/2018 - Marcos Ferreira
-- Redmine #40179 - Integração de XML Legado de NFe não está chamando as rotinas programaveis
-- Defeito: Após importação do XML de NFE Legado, as tabelas item e unidade estavam ficando desatualziadas
-- Correção: Alterado a procedure PKB_CRIA_ITEM_NFE_LEGADO.
--           Incluído parâmetro en_multorg_id na chamada da procedure
--           Alterado cursor c_emp, incluído clausulas e.dm_atu_item_nf_legado = 1 e e.multorg_id = en_multorg_id;
--           Alterado cursor c_item, incluído clausulas and nf.dm_st_integra = 6, nf.dm_st_proc = 4, and rownum <= 100
--
-- Em 31/07/2018 - Angela Inês.
-- Redmine #45540 - Correção na validação dos valores de FCP - Notas Fiscais Mercantis.
-- Ao validar os valores de FCP, verificar se o valor da Base de Cálculo está zerado, e se possui alíquota diferente de zero(0). Neste caso, utilizar o valor da
-- Base de Cálculo do Imposto ICMS ou ICMS-ST, de acordo com o imposto a ser tratado, e atualizar o valor da Base de Cálculo de FCP. Aplicar o valor da Alíquota
-- de FCP nessa base atualizada, e atualizar o valor do Imposto FCP.
-- Rotina: pkb_calc_fcp.
--
-- Em 06/08/2018 - Angela Inês.
-- Redmine #45472 - Gera Mensagem da Lei de Transparência Fiscal para NFe de modelo 55 para CFOP de Serviços.
-- No processo de geração das Informações Complementares de Tributos, passar a considerar, também, a geração com os parâmetros como sendo:
-- 1) nota_fiscal.dm_ind_emit = 0 (indicador de emitente como sendo emissão própria); 2) nota_fiscal.dm_ind_oper = 1 (indicador de operação como sendo saída);
-- 3) nota_fiscal.mod_fiscal.cod_mod = 55 (modelo como sendo nfe); 4) nota_fiscal.dm_legado = 0 (indicador de legado como sendo não legado);
-- 5) nota_fiscal.dm_arm_nfe_terc = 0 (indicador de armazenamento de terceito como sendo não armazenamento); 6) item_nota_fiscal.cd_list_serv <> 0 (item da nota
-- fiscal como sendo de serviço, contendo informação no código da lista de serviço); 7) item_nota_fiscal.cfop 5933,6933,7933 (considerar somente os CFOPs
-- informado por SupCanais/Islaine); e, 8) imp_itemnf.tpimp_id / tipo_imposto.sigla = iss (possuir o registro do imposto ISS, mesmo sem valor tributado e retido).
-- Rotina: pkb_gerar_info_trib.
--
-- Em 03/09/2018 - Angela Inês.
-- Redmine #44325 - Regras de Validações NF-e 4.0 (Informações de Pagamento).
-- Correção no processo gerando log/mensagem de erro de validação: "Para a 'Forma de Pagamento' escolhida ('90'), não deve ser informado Valor de Pagamento.".
-- Rotina: pkb_integr_nf_forma_pgto.
--
-- Em 03/09/2018 - Marcos Ferreira
-- Redmine #41843 - Alteração Chave de Acesso na Integração
-- Solicitação: Quando é nota fiscal de legado, a rotina está re-validando a chave de acesso da nota fiscal, ficando diferente do ERP do cliente
-- Alterações: Feito alteração para validar somente se não for nota fiscal de legado
-- Rotinas alteradas: PKB_INTEGR_NOTA_FISCAL_COMPL, PKB_INTEGR_NOTA_FISCAL
--
-- Em 04/09/2018 - Marcos Ferreira
-- Redmine #46307 - Deleção do Diferencial de Aliquota do item de nota fiscal
-- Solicitação: Ao incluir um item de diferencial de aliquota e clicar em salvar, o item é exluído
-- Alterações: PKB_CALC_DIF_ALIQ - Incluído o dm_tipo = 5 (digitado) na Verificação de Calculo Integrado
--
-- Em 10/09/2018 - Marcos Ferreira
-- Redmine #46754 - Incluir novo domínio - 'Não Incidência'
-- Solicitação: Incluir o nono domínio 'Não Incidência', na estrutura: 'NF_COMPL_SERV.DM_NAT_OPER'.
-- Alterações: Inclusão do do novo item do domínio 8 = 'Não Incidência'
-- Procedures Alteradas: PKB_INTEGR_NOTA_FISCAL_FF / 
--
-- Em 14/09/2018 - Marcos Ferreira
-- Redmine #46885 - VL_IPI_DEVOL sendo alterado para nulo para notas de devolução
-- Solicitação: Em notas fiscais de Devolução, o valor e percentual de IPI não pode ser nulo, pois dá erro no XML
-- Alterações: Incluído validação pelo campo nota_fiscal.Dm_Fin_Nfe. Se for 4 (Devolução de mercadoria) não nular o campo, e sim jogar zero
-- Procedures Alteradas: PKB_INTEGR_ITEM_NOTA_FISCAL
--
-- Em 16/10/2018 - Angela Inês.
-- Redmine #38531 - Emissão de NFe - Campo nota_fiscal_emit.cep - Tratar na integração.
-- Identificar se o campo CEP do emitente da nota fiscal, nota_fiscal_emit, estiver nulo, atualizar com o CEP da Empresa vinculada com a Nota Fiscal, desde que
-- a situação da nota esteja como "Não Validada", e "Não" seja "Legado".
-- Rotina: pkb_integr_nota_fiscal_emit.
--
-- Em 17/10/2018 - Angela Inês.
-- Redmine #47891 - Atualização do Valor de Abatimento Não Tributável - Nota Fiscal Total.
-- Incluir o registro na tabela de campos FlexField, ff_obj_util_integr, a nova coluna, relacionada com o Objeto VW_CSF_NOTA_FISCAL_TOTAL_FF.
-- Rotina: pkb_integr_notafiscal_total_ff.
--
-- Em 15/10/2018 - Eduardo Linden
-- Redmine #47651 - Criar parâmetros de Validação de Integração/Digitação.
-- Solicitação  : Criação da procedure para validação das bases de ICMS. A mesma será acionada via pkb_consistem_nf.
-- Rotina criada: pkb_valida_base_icms
--
-- Em 18/10/2018 - Eduardo Linden
-- Redmine #47653 - Criar tabela de DEPARA para Cálculo de bases de ICMS
-- Solicitação: Incluir na PKB_VLR_FISCAL_ITEM_NF, a aplicação das regras existentes na tabela param_calc_base_icms e aplicação das definições
-- para calculo das bases de calculo, isenta e outra.
-- Rotina     :PKB_VLR_FISCAL_ITEM_NF
--
-- Em 07/11/2018 - Angela Inês.
-- Redmine #48476 - Correção na Validação da Placa em "Informações do Modal Rodoviário CTe Outros Serviços" e em "Veículos do Transporte da Nota Fiscal".
-- Não fazer a validação de Sufixo e Prefixo da Placa do Veículo.
-- Rotina: pkb_integr_nftransp_veic.
--
-- Em 14/11/2018 - Marcos Ferreira
-- Redmine #48441 - Preenchimentos de campos indevidos e forma de pagamento não deixar salvar.
-- Solicitação: Na tabela IMP_ITEMNF nas colunas PERC_BC_OPER_PROP e ESTADO_ID o cliente não informou nada porem o Compliance está carregando informações automáticas e isso está causando erros no momento da autorização do documento.
-- Alterações: Setado null quando era zero, nas associações do campo PERC_BC_OPER_PROP
-- Procedures Alteradas: PKB_INTEGR_IMP_ITEMNF
--
-- Em 20/11/2018 - Eduardo Linden
-- Redmine #48809 - Alteração no processo de Cálculo do Diferencial de Alíquota - Indicador de Tipo de Cálculo.
-- para pkb_calc_dif_aliq    : O Calculo de Diferencial de Aliquota , Difal, só podera ser feito com registro na tabela itemnf_dif_aliq com status Calculado (dm_tipo   = 3).
-- para pkb_valida_base_icms : Correção no cursor c_base_icms sobre o parametro en_dm_tipo. foi colocado um novo parametro en_cd_tipo.
-- Rotinas: pkb_calc_dif_aliq e pkb_valida_base_icms.
--
-- Em 22/11/2018 - Leandro Savenhago
-- Redmine #48814 - Avaliação do processo FCI
-- Rotinas: PKB_ATRIBUI_NRO_FCI - Criado a rotina para ser executada pela PKB_CONSISTEM_NF e atribuir o Número do FCI
--
-- Em 23/11/2018 - Eduardo Linden
-- Redmine #48966 - feed-está recalculando o difal qdo é validado
-- Correção para restringir o recalculo para o status de 'Calculado' (dm_tipo=3).
-- Rotina: pkb_calc_dif_aliq
--
-- Em 26/11/2018 -  Eduardo Linden
-- Redmine #48946 - feed - Processo errado
-- para rotina PKB_VALIDA_BASE_ICMS   : Correção no processo.
-- Inclusão de desoneração de IMCS, ICMS-ST do item , IPI do Item e Valor de PIS/COFINS para item de Importação ou Exportação para compor o valor de total do item da NF.
-- Melhora das mensagens de log.
-- para rotina PKB_VLR_FISCAL_ITEM_NF : Revisão do processo. Correção quanto a localização do parâmetros e as possibilidades de busca.
-- Rotinas: PKB_VALIDA_BASE_ICMS e PKB_VLR_FISCAL_ITEM_NF
--
-- Em 28/11/2018 - Eduardo Linden
-- Redmine #49127 - Feed - base isenta
-- Analise e correção no enquadramento dos parâmetros da tabela param_calc_base_icms.
-- Rotina: PKB_VLR_FISCAL_ITEM_NF
--
-- Em 29/11/2018 - Eduardo Linden
-- Redmine #49192 - feed - o item 3 ainda tá com problema
-- Correção no calculo do imposto tributado ICMS (vn_vl_imp_trib_icms).
-- Rotina: PKB_VLR_FISCAL_ITEM_NF
--
-- Em 29/11/2018 - Eduardo Linden
-- Redmine #49169 - Criar parametro DM_FORMA_DEM_BASE_ICMS
-- Inclusão de function pk_csf.fkg_empresa_dmformademb_icms, devido ao novo parametro de empresa: dm_forma_dem_base_icms.
-- Rotina: PKB_VLR_FISCAL_ITEM_NF
--
-- Em 30/11/2018 - Eduardo Linden
-- Redmine #49227 - feed- parâmetro = 1
-- Analise e reestruturação do código devido ao parametro DM_FORMA_DEM_BASE_ICMS .
-- Rotina: PKB_VLR_FISCAL_ITEM_NF
--
-- Em 10/12/2018 - Eduardo Linden
-- Redmine #49536: ERRO VALIDAÇÃO NOTA MERCANTIL TERCEIRO
-- Considerar que o calculo de difal deve ser feito, mesmo se não houver registro na tabela  itemnf_dif_aliq.
-- Rotina : PKB_CALC_DIF_ALIQ
--
-- Em 13/12/2018 - Angela Inês.
-- Redmine #49553 - NFe 4.0 - Falha no XML da NFe, ausência do campo vlIpiDevol.
-- Validação no Item da Nota Fiscal:
-- 1) Se na Nota fiscal o campo que indica a Finalidade de Emissão da NFe FOR 4-Devolução de Mercadoria (nota_fiscal.dm_fin_nfe=4), será atribuído 0(zero) para
-- os campos de Percentual e Valor de IPI Devolvido, se esses campos forem NULOS. Não sendo NULOS, os campos permaneceram de acordo com a Integração.
-- 2) Se na Nota fiscal o campo que indica a Finalidade de Emissão da NFe NÃO FOR 4-Devolução de Mercadoria (nota_fiscal.dm_fin_nfe=4):
-- 2.1) Verificar se o CFOP vinculado ao Item da Nota Fiscal é de Operação de Devolução (item_nota_fiscal.cfop/cfop.tipooperacao/tipo_operacao.cd=3), e neste
-- caso enviar log/mensagem, como "Informação Geral", dizendo: "Se o campo que indica a Finalidade de Emissão da NFe não for 4-Devolução de Mercadoria (X), e o
-- CFOP (XXXX), utilizado no Item está indicando um CFOP de Operação de Devolução, a Finalidade de Emissão da NFe passa a ser 4-Devolução de Mercadoria.". Em
-- seguida atribuir 0(zero) para o Percentual e Valor de IPI Devolvido, caso sejam NULOS. Não sendo NULOS, os campos permaneceram de acordo com a Integração.
-- 2.2) Verificar se o CFOP vinculado ao Item da Nota Fiscal não é de Operação de Devolução (item_nota_fiscal.cfop/cfop.tipooperacao/tipo_operacao.cd<>3), se o
-- Percentual ou o Valor de IPI Devolvido estão diferentes de 0(zero) ou Nulos, e neste caso enviar log/mensagem, como "Erro de Validação", dizendo: "Se o campo
-- que indica a Finalidade de Emissão da NFe não for 4-Devolução de mercadoria (X), os campos de Percentual e Valor de IPI Devolvido (1 e 1), deverão ser Nulos.".
-- 2.3) Verificar se o CFOP vinculado ao Item da Nota Fiscal não é de Operação de Devolução (item_nota_fiscal.cfop/cfop.tipooperacao/tipo_operacao.cd<>3), se o
-- Percentual ou o Valor de IPI Devolvido estão como 0(zero) ou Nulos, e neste caso alterar os valores dos campos para Nulos.
-- Rotina: pkb_integr_item_nota_fiscal.
--
-- Em 14/12/2018 - Angela Inês.
-- Redmine #49725 - Correção no processo de Validação de Finalidade de NFe e IPI Devolvido.
-- Fazer o processo de validação descrito na atividade #49553, tecnicamente em outra posição da rotina.
-- O processo foi feito na integração/validação do Item da Nota Fiscal, porém os valores de IPI Devolvido são integrados/validados após esse processo, através
-- dos campos FlexField do Item da Nota Fiscal. Com essa correção, tecnicamente, o processo irá fazer as considerações na rotina que consiste todos os dados da
-- Nota Fiscal, após as integrações/validações que vieram inicialmente.
-- Rotina: pkb_integr_item_nota_fiscal e pkb_valida_item_nota_devol.
--
-- Em 24/12/2018 - Angela Inês.
-- Redmine #49824 - Processos de Integração e Validações de Nota Fiscal (vários modelos).
-- Incluir os processos de integração, validações api e ambiente, para a tabela/view VW_CSF_ITEMNF_RES_ICMS_ST e tabela ITEMNF_RES_ICMS_ST. Esse processo se
-- refere aos modelos de notas fiscais 01-Nota Fiscal, e 55-Nota Fiscal Eletrônica, e são utilizados para montagem do Registro C176-Ressarcimento de ICMS e
-- Fundo de Combate à Pobreza (FCP) em Operações com Substituição Tributária (Código 01, 55), do arquivo Sped Fiscal.
-- Rotinas: pkb_integr_itemnf_res_icms_st e pkb_excluir_dados_nf.
--
-- Em 26/12/2018 - Angela Inês.
-- Redmine #49824 - Processos de Integração e Validações de Nota Fiscal (vários modelos).
-- Alterar os processos de integração, validações api e ambiente, que utilizam a Tabela/View VW_CSF_ITEM_NOTA_FISCAL_FF, para receber a coluna DM_MAT_PROP_TERC.
-- Rotina: pkb_integr_item_nota_fiscal_ff.
-- Alteração de domínio incluindo novos valores na coluna da tabela de Ressarcimento de ICMS em operações com substituição Tributária do Item da Nota Fiscal.
-- Rotina: pkb_integr_itemnf_res_icms_st.
--
-- Em 27/12/2018 - Angela Inês.
-- Redmine #50045 - Atualização de Número de FCI e Origem de Mercadoria - Item da Nota Fiscal.
-- Passar a não considerar a origem de mercadoria do item, ou seja, independente da origem de mercadoria, os itens serão recuperados, considerando somente os
-- itens de notas fiscais que estejam com o número de FCI nulo; que sejam notas de emissão própria e sem armazenamento de NFE de terceiro; que a sigla do estado
-- do destinatário não seja Exterior, e seja diferente da sigla do estado do emitente.
-- Rotina: pkb_atribui_nro_fci.
--
-- === AS ALTERAÇÕES PASSARAM A SER INCLUÍDAS NO INÍCIO DA PACKAGE ================================================================================= --
--
------------------------------------------------------------------------------------------------------------------------------------------------------------------
   --
   gt_row_cf_ref                cupom_fiscal_ref%rowtype;
   --
   gt_row_cfe_ref               cfe_ref%rowtype;
   --
   gt_row_nota_fiscal           nota_fiscal%rowtype;
   --
   gt_row_nf_referen            nota_fiscal_referen%rowtype;
   --
   gt_row_nota_fiscal_emit      nota_fiscal_emit%rowtype;
   --
   gt_row_nota_fiscal_dest      nota_fiscal_dest%rowtype;
   --
   gt_row_nota_fiscal_local     nota_fiscal_local%rowtype;
   --
   gt_row_nota_fiscal_transp    nota_fiscal_transp%rowtype;
   --
   gt_row_nota_fiscal_cobr      nota_fiscal_cobr%rowtype;
   --
   gt_row_nota_fiscal_fisco     nota_fiscal_fisco%rowtype;
   --
   gt_row_nota_fiscal_total     nota_fiscal_total%rowtype;
   --
   gt_row_nota_fiscal_canc      nota_fiscal_canc%rowtype;
   --
   gt_row_nota_fiscal_compl     nota_fiscal_compl%rowtype;
   --
   gt_row_nota_fiscal_cce       nota_fiscal_cce%rowtype;
   --
   gt_row_nfdest_email          nfdest_email%rowtype;
   --
   gt_row_nftransp_vol          nftransp_vol%rowtype;
   --                                                                      
   gt_row_nftransp_veic         nftransp_veic%rowtype;
   --
   gt_row_nftranspvol_lacre     nftranspvol_lacre%rowtype;
   --
   gt_row_nfcobr_dup            nfcobr_dup%rowtype;
   --
   gt_row_nfinfor_fiscal        nfinfor_fiscal%rowtype;
   --
   gt_row_nfinfor_adic          nfinfor_adic%rowtype;
   --
   gt_row_nfregist_analit       nfregist_analit%rowtype;
   --
   gt_row_nf_compl_oper_pis     nf_compl_oper_pis%rowtype;
   --
   gt_row_nf_compl_oper_cofins  nf_compl_oper_cofins%rowtype;
   --
   gt_row_nf_aquis_cana         nf_aquis_cana%rowtype;
   --
   gt_row_nf_aquis_cana_dia     nf_aquis_cana_dia%rowtype;
   --
   gt_row_nf_aquis_cana_ded     nf_aquis_cana_ded%rowtype;
   --
   gt_row_nf_agend_transp       nf_agend_transp%rowtype;
   --
   gt_row_nf_obs_agend_transp   nf_obs_agend_transp%rowtype;
   --
   gt_row_item_nota_fiscal      item_nota_fiscal%rowtype;
   --
   gt_row_itemnf_dec_impor      itemnf_dec_impor%rowtype;
   --
   gt_row_itemnfdi_adic         itemnfdi_adic%rowtype;
   --
   gt_row_itemnf_veic           itemnf_veic%rowtype;
   --
   gt_row_itemnf_med            itemnf_med%rowtype;
   --
   gt_row_itemnf_arma           itemnf_arma%rowtype;
   --
   gt_row_itemnf_comb           itemnf_comb%rowtype;
   --
   gt_row_itemnf_compl          itemnf_compl%rowtype;
   --
   gt_row_itemnf_compl_transp   itemnf_compl_transp%rowtype;
   --
   gt_row_imp_itemnf            imp_itemnf%rowtype;
   --
   gt_row_imp_itemnficmsdest    imp_itemnf_icms_dest%rowtype;
   --
   gt_row_inf_nf_romaneio       inf_nf_romaneio%rowtype;
   --
   gt_row_inutiliza_nota_fiscal inutiliza_nota_fiscal%rowtype;
   --
   gt_row_lote                  lote%rowtype;
   --
   gt_row_usuempr_unidorg       usuempr_unidorg%rowtype;
   --
   gt_row_itemnf_dif_aliq       itemnf_dif_aliq%rowtype;
   --
   gt_row_r_nf_nf               r_nf_nf%rowtype;
   --
   gt_row_nota_fiscal_mde       nota_fiscal_mde%rowtype;
   --
   gt_row_inf_prov_docto_fiscal inf_prov_docto_fiscal%rowtype;
   --
   gt_row_nf_aut_xml            nf_aut_xml%rowtype;
   --
   gt_row_nf_forma_pgto         nf_forma_pgto%rowtype;
   --
   gt_row_itemnf_nve            itemnf_nve%rowtype; 
   --
   gt_row_itemnf_rastreab       itemnf_rastreab%rowtype;
   --
   gt_row_itemnf_export         itemnf_export%rowtype;
   --
   gt_row_itemnf_export_compl   itemnf_export_compl%rowtype;
   --
   gt_row_itemnf_compl_serv     itemnf_compl_serv%rowtype;
   --
   gt_row_itemnf_res_icms_st    itemnf_res_icms_st%rowtype;
   --
-------------------------------------------------------------------------------------------------------
   --
   gv_cabec_log          log_generico_nf.mensagem%type;
   gv_cabec_log_item     log_generico_nf.mensagem%type;
   gv_mensagem_log       log_generico_nf.mensagem%type;
   gn_processo_id        log_generico_nf.processo_id%type := null;
   gv_obj_referencia     log_generico_nf.obj_referencia%type default 'NOTA_FISCAL';
   gn_referencia_id      log_generico_nf.referencia_id%type := null;
   --
   gv_dominio            dominio.descr%type;
   gn_notafiscal_id      nota_fiscal.id%type;
   gn_dm_legado          nota_fiscal.dm_legado%type := null;   
   gn_dm_tp_amb          empresa.dm_tp_amb%type := null;
   gn_empresa_id         empresa.id%type := null;
   gn_tipo_integr        number := null;
   --
   gv_objeto             varchar2(300);
   gn_fase               number;
   --
-------------------------------------------------------------------------------------------------------

-- Declaração de constantes

   erro_de_validacao       constant number := 1;
   erro_de_sistema         constant number := 2;
   nota_fiscal_integrada   constant number := 16;
   cons_sit_nfe_sefaz      constant number := 30;
   info_canc_nfe           constant number := 31;
   informacao              constant number := 35;
   INFO_CALC_FISCAL        constant number := 38;
   gv_cd_obj               obj_integr.cd%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento insere ou atualiza um usuário no sistema
procedure pkb_integr_usuario ( ev_nome       in  neo_usuario.nome%type
                             , ev_login      in  neo_usuario.login%type
                             , ev_senha      in  neo_usuario.senha%type
                             , ev_email      in  neo_usuario.email%type
                             , en_bloqueado  in  neo_usuario.bloqueado%type
                             , ev_id_erp     in  neo_usuario.id_erp%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento insere ou atualiza das empresas que o usuário tem acesso
procedure pkb_integr_empr_usuario ( ev_login            in  neo_usuario.login%type
                                  , ev_cnpj_cpf         in  varchar2
                                  , en_dm_acesso        in  usuario_empresa.dm_acesso%type
                                  , en_dm_empr_default  in  usuario_empresa.dm_empr_default%type
                                  , ev_cod_unid_org     in  unid_org.cd%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento insere ou atualiza uma empresa no sistema.
procedure pkb_integr_empresa ( ev_cod_part         in pessoa.cod_part%type
                             , ev_nome             in pessoa.nome%type
                             , ev_fantasia         in pessoa.fantasia%type
                             , ev_lograd           in pessoa.lograd%type
                             , ev_nro              in pessoa.nro%type
                             , ev_cx_postal        in pessoa.cx_postal%type
                             , ev_compl            in pessoa.compl%type
                             , ev_bairro           in pessoa.bairro%type
                             , ev_cod_ibge_cidade  in cidade.ibge_cidade%type
                             , en_cep              in pessoa.cep%type
                             , ev_fone             in pessoa.fone%type
                             , ev_fax              in pessoa.fax%type
                             , ev_email            in pessoa.email%type
                             , ev_cnpj             in varchar2
                             , ev_ie               in juridica.ie%type
                             , EV_IM               in juridica.IM%type
                             , ev_cnae             in juridica.cnae%type
                             , ev_suframa          in juridica.suframa%type
                             , ev_cod_matriz       in empresa.cod_matriz%type
                             , ev_cod_filial       in empresa.cod_filial%type
                             , eb_logotipo         in empresa.logotipo%type
                             , ev_cod_unid_org     in unid_org.cd%type
                             , ev_descr_unid_org   in unid_org.descr%type
                             );

-------------------------------------------------------------------------------------------------------

-- Procedimento seta o tipo de integração que será feito
   -- 0 - Somente válida os dados e registra o Log de ocorrência
   -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
   -- Todos os procedimentos de integração fazem referência a ele
procedure pkb_seta_tipo_integr ( en_tipo_integr in number );

-------------------------------------------------------------------------------------------------------

-- Procedimento seta o objeto de referencia utilizado na Validação da Informação
procedure pkb_seta_obj_ref ( ev_objeto in varchar2 );

-------------------------------------------------------------------------------------------------------

-- Procedimento seta o "ID de Referencia" utilizado na Validação da Informação
procedure pkb_seta_referencia_id ( en_id in number );

-------------------------------------------------------------------------------------------------------

-- Procedimento exclui dados de uma nota fiscal
procedure pkb_excluir_dados_nf ( en_notafiscal_id  in nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento armazena o valor do "loggenerico_id" da nota fiscal
procedure pkb_gt_log_generico_nf ( en_loggenericonf_id  in             log_generico_nf.id%type
                                 , est_log_generico_nf  in out nocopy  dbms_sql.number_table );

-------------------------------------------------------------------------------------------------------

-- Procedimento finaliza o Log Genérico
procedure pkb_finaliza_log_generico_nf;

-------------------------------------------------------------------------------------------------------

-- Procedimento de registro de log de erros na validação da nota fiscal
procedure pkb_log_generico_nf ( sn_loggenericonf_id   out nocopy log_generico_nf.id%type
                              , ev_mensagem        in            log_generico_nf.mensagem%type
                              , ev_resumo          in            log_generico_nf.resumo%type
                              , en_tipo_log        in            csf_tipo_log.cd_compat%type      default 1
                              , en_referencia_id   in            log_generico_nf.referencia_id%type  default null
                              , ev_obj_referencia  in            log_generico_nf.obj_referencia%type default null
                              , en_empresa_id      in            empresa.id%type                  default null
                              , en_dm_impressa     in            log_generico_nf.dm_impressa%type    default 0 );

---------------------------------------------------------------------------------------------------

-- Procedimento de integração de relacionamento entre Notas Fiscais
procedure pkb_integr_r_nf_nf ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                             , est_row_r_nf_nf     in out nocopy  r_nf_nf%rowtype
                             );

-------------------------------------------------------------------------------------------------------

-- Procedimento de integração da Nota Fiscal para registro da Carta de Correção Eletrônica - CCE
procedure pkb_integr_nota_fiscal_cce ( est_log_generico_nf     in out nocopy  dbms_sql.number_table
                                     , est_row_nota_fiscal_cce in out nocopy  nota_fiscal_cce%rowtype );
                                     
-------------------------------------------------------------------------------------------------------

-- Procedimento de integração da Nota Fiscal para registro do Manifesto do Destinatario - MDE
procedure pkb_integr_nota_fiscal_mde ( est_log_generico_nf     in out nocopy  dbms_sql.number_table
                                     , est_row_nota_fiscal_mde in out nocopy  nota_fiscal_mde%rowtype );

-------------------------------------------------------------------------------------------------------

-- Procedimento de Integração de dados Complementares do Item da Nota Fiscal
procedure pkb_integr_itemnf_compl ( est_log_generico_nf    in out nocopy  dbms_sql.number_table
                                  , est_row_itemnf_compl   in out nocopy  itemnf_compl%rowtype
                                  , en_notafiscal_id       in             nota_fiscal.id%type
				  , ev_cod_class           in             class_cons_item_cont.cod_class%type
				  , en_dm_ind_rec          in             item_nota_fiscal.dm_ind_rec%type
				  , ev_cod_part_item       in             pessoa.cod_part%type
				  , en_dm_ind_rec_com      in             item_nota_fiscal.dm_ind_rec_com%type
				  , ev_cod_nat             in             nat_oper.cod_nat%type
                                  , en_multorg_id          in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento de Integração de dados Complementares da Nota Fiscal
procedure pkb_integr_nota_fiscal_compl ( est_log_generico_nf        in out nocopy  dbms_sql.number_table
                                       , est_row_nota_fiscal_compl  in out nocopy  nota_fiscal_compl%rowtype
                                       , en_notafiscal_id           in             nota_fiscal.id%type
                                       , en_nro_nf                  in             nota_fiscal.nro_nf%type
                                       , ev_nro_chave_nfe           in             nota_fiscal.nro_chave_nfe%type
                                       , en_sub_serie               in             nota_fiscal.sub_serie%type
                                       , ev_cod_mod                 in             mod_fiscal.cod_mod%type
                                       , ev_cod_infor               in             infor_comp_dcto_fiscal.cod_infor%type
                                       , ev_cod_cta                 in             nota_fiscal.cod_cta%type
                                       , ev_cod_cons                in             cod_cons_item_cont.cod_cons%type
                                       , en_dm_tp_ligacao           in             nota_fiscal.dm_tp_ligacao%type
                                       , ev_dm_cod_grupo_tensao     in             nota_fiscal.dm_cod_grupo_tensao%type
                                       , en_dm_tp_assinante         in             nota_fiscal.dm_tp_assinante%type
                                       , en_nro_ord_emb             in             nota_fiscal.nro_ord_emb%type
                                       , en_seq_nro_ord_emb         in             nota_fiscal.seq_nro_ord_emb%type
                                       , en_multorg_id              in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento de Integração dos dados complementares de transporte do item da nota fiscal
procedure pkb_integr_itemnf_compl_transp ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                         , est_row_itemnf_compl_transp  in out nocopy  itemnf_compl_transp%rowtype
                                         , en_notafiscal_id             in             nota_fiscal.id%type );

-----------------------------------------------------------------------------------------------------------------------------

-- Integra as informações sobre Observações de Agendamento de Transporte
procedure pkb_integr_nf_obs_agend_transp ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                         , est_row_nf_obs_agend_transp  in out nocopy  nf_obs_agend_transp%rowtype
                                         , en_notafiscal_id             in             nf_agend_transp.notafiscal_id%type );

-----------------------------------------------------------------------------------------------------------------------------

-- Integra as informações sobre Agendamento de Transporte
procedure pkb_integr_nf_agend_transp ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                                     , est_row_nf_agend_transp  in out nocopy  nf_agend_transp%rowtype );

-----------------------------------------------------------------------------------------------------------------------------

-- Integra as informações sobre NF de fornecedores dos produtos constantes na DANFE para romaneio
procedure pkb_integr_inf_nf_romaneio ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                                     , est_row_inf_nf_romaneio  in out nocopy  inf_nf_romaneio%rowtype );

-----------------------------------------------------------------------------------------------------------------------------

-- Integra as informações sobre a dedução da cana-de-açuca
procedure pkb_integr_nfaq_cana_ded ( est_log_generico_nf    in out nocopy  dbms_sql.number_table
                                   , est_row_nfaq_cana_ded  in out nocopy  nf_aquis_cana_ded%rowtype
                                   , en_notafiscal_id       in             nf_aquis_cana.notafiscal_id%type );

-----------------------------------------------------------------------------------------------------------------------------

-- Integra as informações de cana-de-açuca ao dia
procedure pkb_integr_nfaq_cana_dia ( est_log_generico_nf    in out nocopy  dbms_sql.number_table
                                   , est_row_nfaq_cana_dia  in out nocopy  nf_aquis_cana_dia%rowtype
                                   , en_notafiscal_id       in             nf_aquis_cana.notafiscal_id%type );

-------------------------------------------------------------------------------------------------------

-- Integra as informações de cana-de-açucar
procedure pkb_integr_nfaquis_cana ( est_log_generico_nf   in out nocopy  dbms_sql.number_table
                                  , est_row_nfaquis_cana  in out nocopy  nf_aquis_cana%rowtype );

-------------------------------------------------------------------------------------------------------

-- Integra as informações de impostos do Item da Nota Fiscal
procedure pkb_integr_imp_itemnf ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                , est_row_imp_itemnf   in out nocopy  imp_itemnf%rowtype
                                , en_cd_imp            in             tipo_imposto.cd%type
                                , ev_cod_st            in             cod_st.cod_st%type
                                , en_notafiscal_id     in             nota_fiscal.id%type
                                , ev_sigla_estado      in             estado.sigla_estado%type default null );

-------------------------------------------------------------------------------------------------------

-- Integra as informações de impostos do Item da Nota Fiscal - Campos Flex Field
procedure pkb_integr_imp_itemnf_ff ( est_log_generico_nf in out nocopy dbms_sql.number_table
                                   , en_notafiscal_id    in            nota_fiscal.id%type
                                   , en_impitemnf_id     in            imp_itemnf.id%type
                                   , ev_atributo         in            varchar2
                                   , ev_valor            in            varchar2
                                   , en_multorg_id       in            mult_org.id%type );

------------------------------------------------------------------------------------------------
-- Procedimento integra as informações de impostos partilha ICMS - campos flex field --
------------------------------------------------------------------------------------------------
PROCEDURE pkb_integr_impitnficmsdest_ff ( EST_LOG_GENERICO_NF      IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                        , EN_NOTAFISCAL_ID         IN            NOTA_FISCAL.ID%TYPE
                                        , EN_IMPITEMNF_ID          IN            IMP_ITEMNF.ID%TYPE
                                        , EN_IMPITEMNFICMSDEST_ID  IN            IMP_ITEMNF_ICMS_DEST.id%type
                                        , EV_ATRIBUTO              IN            VARCHAR2
                                        , EV_VALOR                 IN            VARCHAR2
                                        , EN_MULTORG_ID            IN            MULT_ORG.ID%TYPE
                                        );

-------------------------------------------------------------------------------------------------------

-- Integra as informações do Grupo de Tributação do Imposto ICMS
procedure pkb_integr_imp_itemnficmsdest ( est_log_generico_nf        in out nocopy dbms_sql.number_table
                                        , est_row_imp_itemnficmsdest in out        imp_itemnf_icms_dest%rowtype
                                        , en_notafiscal_id           in            nota_fiscal.id%type
                                        , en_multorg_id              in            mult_org.id%type );

-------------------------------------------------------------------------------------------------------
-- Integra as informações de Rastreabilidade de produto
PROCEDURE pkb_integr_itemnf_rastreab ( est_log_generico_nf     in out nocopy dbms_sql.number_table
                                     , est_row_itemnf_rastreab  in out        itemnf_rastreab%rowtype
                                     , en_notafiscal_id        in            nota_fiscal.id%type
                                     );

-------------------------------------------------------------------------------------------------------
-- Integra Ressarcimento de ICMS em operações com substituição Tributária do Item da Nota Fiscal
procedure pkb_integr_itemnf_res_icms_st ( est_log_generico_nf        in out nocopy dbms_sql.number_table
                                        , est_row_itemnf_res_icms_st in out        itemnf_res_icms_st%rowtype
                                        , en_notafiscal_id           in            nota_fiscal.id%type
                                        , en_multorg_id              in            mult_org.id%type
                                        , ev_cod_mod_e               in            varchar2
                                        , ev_cod_part_e              in            varchar2
                                        , ev_cod_part_nfe_ret        in            varchar2
                                        );

-------------------------------------------------------------------------------------------------------

-- Integra as informações do detalhamento do NCM: NVE
procedure pkb_integr_itemnf_nve ( est_log_generico_nf in out nocopy dbms_sql.number_table
                                , est_row_itemnf_nve  in out        itemnf_nve%rowtype
                                , en_notafiscal_id    in            nota_fiscal.id%type
                                );

-------------------------------------------------------------------------------------------------------

-- Integra as informações do Controle de Exportação por Item
procedure pkb_integr_itemnf_export ( est_log_generico_nf   in out nocopy dbms_sql.number_table
                                   , est_row_itemnf_export in out        itemnf_export%rowtype
                                   , en_notafiscal_id      in            nota_fiscal.id%type
                                   );

-------------------------------------------------------------------------------------------------------

-- Procedimento de validação referente ao complemento da informação de exportação do item da NFe
procedure pkb_integr_info_export_compl ( est_log_generico_nf         in out nocopy dbms_sql.number_table
                                       , est_row_itemnf_export_compl in out itemnf_export_compl%rowtype
                                       );
-------------------------------------------------------------------------------------------------------

-- Integra as informações Complementares do Item da NFe
procedure pkb_integr_itemnf_compl_serv ( est_log_generico_nf       in out nocopy dbms_sql.number_table
                                       , est_row_itemnf_compl_serv in out        itemnf_compl_serv%rowtype
                                       , en_notafiscal_id          in            nota_fiscal.id%type
                                       , ev_cod_trib_municipio     in            cod_trib_municipio.cod_trib_municipio%type
                                       , en_cod_siscomex           in            pais.cod_siscomex%type
                                       , ev_cod_mun                in            cidade.ibge_cidade%type
                                       );

-------------------------------------------------------------------------------------------------------

-- Integra as informações de combustíveis
procedure pkb_integr_itemnf_comb ( est_log_generico_nf   in out nocopy  dbms_sql.number_table
                                 , est_row_itemnf_comb   in out nocopy  itemnf_comb%rowtype
                                 , ev_uf_emit            in             estado.sigla_estado%type
                                 , en_notafiscal_id      in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Integra as informações de combustíveis - Flex Field
procedure pkb_integr_itemnf_comb_ff ( est_log_generico_nf   in out nocopy  dbms_sql.number_table
                                    , en_notafiscal_id      in             nota_fiscal.id%type
                                    , en_itemnfcomb_id      in             itemnf_comb.id%type
                                    , ev_atributo           in             varchar2
                                    , ev_valor              in             varchar2 );

-------------------------------------------------------------------------------------------------------

-- Integra as informações de armas
procedure pkb_integr_itemnf_arma ( est_log_generico_nf   in out nocopy  dbms_sql.number_table
                                 , est_row_itemnf_arma   in out nocopy  itemnf_arma%rowtype
                                 , en_notafiscal_id      in             nota_fiscal.id%type );


-------------------------------------------------------------------------------------------------------

-- Integra as informações de medicamentos - Flex Field
PROCEDURE pkb_integr_itemnf_med_ff ( EST_LOG_GENERICO_NF IN OUT NOCOPY  DBMS_SQL.NUMBER_TABLE
                                   , EN_NOTAFISCAL_ID    IN             NOTA_FISCAL.ID%TYPE
                                   , EN_ITEMNFMED_ID     IN             ITEMNF_MED.ID%TYPE
                                   , EV_ATRIBUTO         IN             VARCHAR2
                                   , EV_VALOR            IN             VARCHAR2 
                                   );

-------------------------------------------------------------------------------------------------------

-- Integra as informações de medicamentos
procedure pkb_integr_itemnf_med ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                , est_row_itemnf_med   in out nocopy  itemnf_med%rowtype
                                , en_notafiscal_id     in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Integra as informações de veículos
procedure pkb_integr_itemnf_veic ( est_log_generico_nf   in out nocopy  dbms_sql.number_table
                                 , est_row_itemnf_veic   in out nocopy  itemnf_veic%rowtype
                                 , en_notafiscal_id      in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Integra as informações adicionais da Nota Fiscal
procedure pkb_integr_nfinfor_fiscal ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                                    , est_row_nfinfor_fiscal   in out nocopy  nfinfor_fiscal%rowtype
                                    , ev_cd_obs                in obs_lancto_fiscal.cod_obs%type default null
                                    , en_multorg_id            in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Integra as informações das Adições da Declaração de Exortação
procedure pkb_integr_itemnfdi_adic ( est_log_generico_nf     in out nocopy  dbms_sql.number_table
                                   , est_row_itemnfdi_adic   in out nocopy  itemnfdi_adic%rowtype
                                   , en_notafiscal_id        in             nota_fiscal.id%type );
                                   
---------------------------------------------------------------------------------------------

-- Integra as informações das Adições da Declaração de Exortação - Flex Field
procedure pkb_integr_itemnfdi_adic_ff ( est_log_generico_nf   in out nocopy  dbms_sql.number_table
                                      , en_notafiscal_id      in             nota_fiscal.id%type
                                      , en_itemnfdiadic_id    in             itemnfdi_adic.id%type
                                      , ev_atributo           in             varchar2
                                      , ev_valor              in             varchar2 );

-------------------------------------------------------------------------------------------------------

-- Integra as informações da Declaração de Impotação do Item
procedure pkb_integr_itemnf_dec_impor ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                      , est_row_itemnf_dec_impor  in out nocopy  itemnf_dec_impor%rowtype
                                      , en_notafiscal_id          in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Integra as informações da Declaração de Impotação do Item - Flex Field
procedure pkb_integr_itemnf_dec_impor_ff ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                         , en_notafiscal_id     in             nota_fiscal.id%type
                                         , en_itemnfdi_id       in             itemnf_dec_impor.id%type
                                         , ev_atributo          in             varchar2
                                         , ev_valor             in             varchar2);
-------------------------------------------------------------------------------------------------------

-- Integra as informações dos itens da nota fiscal
procedure pkb_integr_item_nota_fiscal ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                      , est_row_item_nota_fiscal  in out nocopy  item_nota_fiscal%rowtype
                                      , en_multorg_id             in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Integra as informações dos itens da nota fiscal - campos flex field
procedure pkb_integr_Item_Nota_Fiscal_ff ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                         , en_notafiscal_id     in             nota_fiscal.id%type
                                         , en_itemnotafiscal_id in             item_nota_fiscal.id%type
                                         , ev_atributo          in             varchar2
                                         , ev_valor             in             varchar2 );

-------------------------------------------------------------------------------------------------------

-- Procedimento para complemento da operação de COFINS
procedure pkb_integr_nfcompl_opercofins ( est_log_generico_nf        in out nocopy  dbms_sql.number_table
                                        , est_row_nfcompl_opercofins in out nocopy  nf_compl_oper_cofins%rowtype
                                        , ev_cpf_cnpj_emit           in             varchar2
                                        , ev_cod_st                  in             cod_st.cod_st%type
                                        , ev_cod_bc_cred_pc          in             base_calc_cred_pc.cd%type
                                        , ev_cod_cta                 in             plano_conta.cod_cta%type
                                        , en_multorg_id              in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento para complemento da operação de COFINS - Campos Flex Field
procedure pkb_integr_nfcomplopercof_ff ( est_log_generico_nf     in out nocopy  dbms_sql.number_table
                                       , en_nfcomplopercofins_id in             nf_compl_oper_cofins.id%type
                                       , ev_atributo             in             varchar2
                                       , ev_valor                in             varchar2
                                       , en_multorg_id           in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento para complemento da operação de PIS/PASEP
procedure pkb_integr_nfcompl_operpis ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                                     , est_row_nfcompl_operpis  in out nocopy  nf_compl_oper_pis%rowtype
                                     , ev_cpf_cnpj_emit         in             varchar2
                                     , ev_cod_st                in             cod_st.cod_st%type
                                     , ev_cod_bc_cred_pc        in             base_calc_cred_pc.cd%type
                                     , ev_cod_cta               in             plano_conta.cod_cta%type
                                     , en_multorg_id            in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento para complemento da operação de PIS/PASEP - Campos Flex Field
procedure pkb_integr_nfcomploperpis_ff ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                       , en_nfcomploperpis_id in             nf_compl_oper_pis.id%type
                                       , ev_atributo          in             varchar2
                                       , ev_valor             in             varchar2
                                       , en_multorg_id        in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Integra as informações do resumo de impostos  - nfregist_analit
procedure pkb_integr_nfregist_analit ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                                     , est_row_nfregist_analit  in out nocopy  nfregist_analit%rowtype
                                     , ev_cod_st                in             cod_st.cod_st%type
                                     , en_cfop                  in             cfop.cd%type
                                     , ev_cod_obs               in             obs_lancto_fiscal.cod_obs%type
                                     , en_multorg_id            in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Integra as informações do resumo de impostos  - nfregist_analit - campos flex field
procedure pkb_integr_nfregist_analit_ff ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                        , en_nfregistanalit_id in             nfregist_analit.id%type
                                        , ev_atributo          in             varchar2
                                        , ev_valor             in             varchar2 );

-------------------------------------------------------------------------------------------------------

-- Integra as informações de Totais de Nota Fiscal
procedure pkb_integr_nota_fiscal_total ( est_log_generico_nf        in out nocopy  dbms_sql.number_table
                                       , est_row_nota_fiscal_total  in out nocopy  nota_fiscal_total%rowtype );

-------------------------------------------------------------------------------------------------------

-- Integra as informações de Totais de Nota Fiscal - Flex Field
procedure pkb_integr_notafiscal_total_ff ( est_log_generico_nf     in out nocopy dbms_sql.number_table
                                         , en_notafiscal_id        in            nota_fiscal.id%type 
                                         , en_notafiscaltotal_id   in            nota_fiscal_total.id%type
                                         , ev_atributo             in            varchar2
                                         , ev_valor                in            varchar2);

-------------------------------------------------------------------------------------------------------

-- Integra as informações adicionais da Nota Fiscal
procedure pkb_integr_nfinfor_adic ( est_log_generico_nf    in out nocopy  dbms_sql.number_table
                                  , est_row_nfinfor_adic   in out nocopy  nfinfor_adic%rowtype
                                  , en_cd_orig_proc        in             orig_proc.cd%type default null );

-------------------------------------------------------------------------------------------------------

-- Integra informações que do Fisco
procedure pkb_integr_nota_fiscal_fisco ( est_log_generico_nf        in out nocopy  dbms_sql.number_table
                                       , est_row_nota_fiscal_fisco  in out nocopy  nota_fiscal_fisco%rowtype );

-------------------------------------------------------------------------------------------------------

-- Integra informações da Duplicata de cobrança
procedure pkb_integr_nfcobr_dup ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                , est_row_nfcobr_dup   in out nocopy  nfcobr_dup%rowtype
                                , en_notafiscal_id     in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Integra informações da cobrança da Nota Fiscal
procedure pkb_integr_nota_fiscal_cobr ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                      , est_row_nota_fiscal_cobr  in out nocopy  nota_fiscal_cobr%rowtype );

-------------------------------------------------------------------------------------------------------

-- Integra informações dos lacres dos volumes transportados
procedure pkb_integr_nftranspvol_lacre ( est_log_generico_nf        in out nocopy  dbms_sql.number_table
                                       , est_row_nftranspvol_lacre  in out nocopy  nftranspvol_lacre%rowtype
                                       , en_notafiscal_id           in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Integra informações dos volumes transportados
procedure pkb_integr_nftransp_vol ( est_log_generico_nf    in out nocopy  dbms_sql.number_table
                                  , est_row_nftransp_vol   in out nocopy  nftransp_vol%rowtype
                                  , en_notafiscal_id       in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Integra informações dos veículos utilizados no transporte
procedure pkb_integr_nftransp_veic ( est_log_generico_nf     in out nocopy  dbms_sql.number_table
                                   , est_row_nftransp_veic   in out nocopy  nftransp_veic%rowtype
                                   , en_notafiscal_id        in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Integra informações referênte ao transporte da Nota Fiscal
procedure pkb_integr_nota_fiscal_transp ( est_log_generico_nf         in out nocopy  dbms_sql.number_table
                                        , est_row_nota_fiscal_transp  in out nocopy  nota_fiscal_transp%rowtype
                                        , en_multorg_id               in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Integra informações do Local de Retirada/Entrega de mercadorias - campos flex field --
--
procedure pkb_integr_nota_fiscal_localff ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                                         , en_notafiscal_id         in             nota_fiscal.id%type
                                         , en_notafiscallocal_id    in             nota_fiscal_local.id%type
                                         , ev_atributo              in             varchar2
                                         , ev_valor                 in             varchar2
                                         ) ;

-------------------------------------------------------------------------------------------------------

-- Integra informações do Local de Retirada/Entrega de mercadorias
procedure pkb_integr_nota_fiscal_local ( est_log_generico_nf        in out nocopy  dbms_sql.number_table
                                       , est_row_nota_fiscal_local  in out nocopy  nota_fiscal_local%rowtype );

-------------------------------------------------------------------------------------------------------

-- Integra informações de email por tipo de anexo
procedure pkb_integr_nfdest_email ( est_log_generico_nf   in out nocopy  dbms_sql.number_table
                                  , est_row_nfdest_email  in out nocopy  nfdest_email%rowtype
                                  , en_notafiscal_id      in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento de registro da pessoa destinatário da Nota Fiscal
procedure pkb_verif_pessoas_restricao ( est_log_generico_nf in  out nocopy  dbms_sql.number_table
                                      , ev_cpf_cnpj         in  ctrl_restr_pessoa.cpf_cnpj%type
                                      , en_multorg_id       in  ctrl_restr_pessoa.multorg_id%type default 0
                                      );

-------------------------------------------------------------------------------------------------------

-- Integra as informações do Destinatário da Nota Fiscal
procedure pkb_integr_nota_fiscal_dest ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                      , est_row_nota_fiscal_dest  in out nocopy  nota_fiscal_dest%rowtype
                                      , ev_cod_part               in             pessoa.cod_part%type
                                      , en_multorg_id             in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Integra as informações do Destinatário da Nota Fiscal - Flex Field
procedure pkb_integr_nota_fiscal_dest_ff ( est_log_generico_nf   in out nocopy  dbms_sql.number_table
                                         , en_notafiscal_id      in             nota_fiscal.id%type
                                         , en_notafiscaldest_id  in             nota_fiscal_dest.id%type
                                         , ev_atributo           in             varchar2
                                         , ev_valor              in             varchar2 );

---------------------------------------------------------------------------------------------------------------------------------------
-- Integra as informações do Emitente da Nota Fiscal - Flex Field                                                    --
---------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE pkb_integr_nota_fiscal_emit_ff ( EST_LOG_GENERICO_NF       IN OUT NOCOPY  DBMS_SQL.NUMBER_TABLE
                                         , EN_NOTAFISCAL_ID          IN             NOTA_FISCAL.ID%TYPE
                                         , EN_NOTAFISCALEMIT_ID      IN             NOTA_FISCAL_EMIT.ID%TYPE
                                         , EV_ATRIBUTO               IN             VARCHAR2
                                         , EV_VALOR                  IN             VARCHAR2
                                         );

-------------------------------------------------------------------------------------------------------

-- Procedimento integra as informação do emitente da Nota Fiscal
procedure pkb_integr_nota_fiscal_emit ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                      , est_row_nota_fiscal_emit  in out nocopy  nota_fiscal_emit%rowtype
                                      , en_empresa_id             in             empresa.id%type
                                      , en_dm_ind_emit            in             nota_fiscal.dm_ind_emit%type
                                      , ev_cod_part               in             pessoa.cod_part%type default null );
                                      
-------------------------------------------------------------------------------------------------------

-- Procedimento integra as informações da Autorização de acesso ao XML da Nota Fiscal
procedure pkb_integr_nf_aut_xml ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                , est_row_nf_aut_xml   in out nocopy  nf_aut_xml%rowtype
                                );

-------------------------------------------------------------------------------------------------------

-- Procedimento integra as informações da Formas de Pagamento
procedure pkb_integr_nf_forma_pgto ( est_log_generico_nf   in out nocopy  dbms_sql.number_table
                                   , est_row_nf_forma_pgto in out nocopy  nf_forma_pgto%rowtype
                                   );

-------------------------------------------------------------------------------------------------------

-- Procedimento integra as informações da Formas de Pagamento - Campos Flex Field
procedure pkb_integr_nf_forma_pgto_ff ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                      , en_notafiscal_id    in             nota_fiscal.id%type
                                      , en_nfformapgto_id   in             nf_forma_pgto.id%type
                                      , ev_atributo         in             varchar2
                                      , ev_valor            in             varchar2 );

-------------------------------------------------------------------------------------------------------

-- Procedimento integra os cupum fiscal referenciado
procedure pkb_integr_cf_ref ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                            , est_row_cf_ref      in out nocopy  cupom_fiscal_ref%rowtype
                            , ev_cod_mod          in             mod_fiscal.cod_mod%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento integra os cupum fiscal eletronico referenciado
procedure pkb_integr_cfe_ref ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                             , est_row_cfe_ref     in out nocopy  cfe_ref%rowtype
                             , ev_cod_mod          in             mod_fiscal.cod_mod%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento integra as notas fiscais referenciadas
procedure pkb_integr_nf_referen ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                , est_row_nf_referen   in out nocopy  nota_fiscal_referen%rowtype
                                , ev_cod_mod           in             mod_fiscal.cod_mod%type
                                , ev_cod_part          in             pessoa.cod_part%type
                                , en_multorg_id        in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento integra as notas fiscais referenciadas - campos flex field
procedure pkb_integr_nf_referen_ff ( est_log_generico_nf     in out nocopy  dbms_sql.number_table
                                   , en_notafiscalreferen_id in             nota_fiscal_referen.id%type
                                   , ev_cod_mod_ref          in             varchar2
                                   , ev_atributo             in             varchar2
                                   , ev_valor                in             varchar2 );

-------------------------------------------------------------------------------------------------------

-- Procedimento que faz a integração as Notas Fiscais Cancelas
procedure pkb_integr_nota_fiscal_canc ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                      , est_row_nota_fiscal_canc  in out nocopy  nota_fiscal_canc%rowtype 
                                      , en_loteintws_id           in     lote_int_ws.id%type default 0
                                      );

-------------------------------------------------------------------------------------------------------

-- Procedimento integra a Chave da Nota Fiscal
procedure pkb_integr_nfchave_refer ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                   , en_empresa_id        in             empresa.id%type
                                   , en_notafiscal_id     in             nota_fiscal.id%type
                                   , ed_dt_emiss          in             nota_fiscal.dt_emiss%type
                                   , ev_cod_mod           in             mod_fiscal.cod_mod%type
                                   , en_serie             in             nota_fiscal.serie%type
                                   , en_nro_nf            in             nota_fiscal.nro_nf%type
                                   , en_dm_forma_emiss    in             nota_fiscal.dm_forma_emiss%type
                                   , esn_cnf_nfe          in out nocopy  nota_fiscal.cnf_nfe%type
                                   , sn_dig_verif_chave   out            nota_fiscal.dig_verif_chave%type
                                   , sv_nro_chave_nfe         out            nota_fiscal.nro_chave_nfe%type
                                   , sn_dm_nro_chave_nfe_orig out            nota_fiscal.dm_nro_chave_nfe_orig%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida a chave de acesso da Nota Fiscal
procedure pkb_valida_chave_acesso ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                  , ev_nro_chave_nfe     in             nota_fiscal.nro_chave_nfe%type
                                  , EN_UF_IBGE           IN             NOTA_FISCAL.UF_IBGE_EMIT%TYPE
                                  , EV_CNPJ              IN             varchar2
                                  , ed_dt_emiss          in             nota_fiscal.dt_emiss%type
                                  , ev_cod_mod           in             mod_fiscal.cod_mod%type
                                  , en_serie             in             nota_fiscal.serie%type
                                  , en_nro_nf            in             nota_fiscal.nro_nf%type
                                  , en_dm_forma_emiss    in             nota_fiscal.dm_forma_emiss%type
                                  , en_dm_nro_chave_nfe_orig in         nota_fiscal.dm_nro_chave_nfe_orig%type 
                                  , sn_cnf_nfe           out            nota_fiscal.cnf_nfe%type
                                  , sn_dig_verif_chave   out            nota_fiscal.dig_verif_chave%type
                                  , sn_qtde_erro         out            number );

-------------------------------------------------------------------------------------------------------

--| Procedimento que faz validações na Nota Fiscal e grava na CSF
procedure pkb_integr_nota_fiscal ( est_log_generico_nf        in out nocopy  dbms_sql.number_table
                                 , est_row_nota_fiscal        in out nocopy  nota_fiscal%rowtype
                                 , ev_cod_mod                 in             mod_fiscal.cod_mod%type
                                 , ev_cod_matriz              in             empresa.cod_matriz%type  default null
                                 , ev_cod_filial              in             empresa.cod_filial%type  default null
                                 , ev_empresa_cpf_cnpj        in             varchar2                 default null -- cpf/cnpj da empresa
                                 , ev_cod_part                in             pessoa.cod_part%type     default null
                                 , ev_cod_nat                 in             nat_oper.cod_nat%type    default null
                                 , ev_cd_sitdocto             in             sit_docto.cd%type        default null
                                 , ev_cod_infor               in             infor_comp_dcto_fiscal.cod_infor%type  default null
                                 , ev_sist_orig               in             sist_orig.sigla%type     default null
                                 , ev_cod_unid_org            in             unid_org.cd%type         default null
                                 , en_multorg_id              in             mult_org.id%type
                                 , en_empresaintegrbanco_id   in             empresa_integr_banco.id%type default null
                                 , en_loteintws_id            in             lote_int_ws.id%type default 0
                                 );

-------------------------------------------------------------------------------------------------------

--| Procedimento que faz validações na Nota Fiscal e grava na CSF - Campos Flex Field
procedure pkb_integr_nota_fiscal_ff ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                    , en_notafiscal_id    in             nota_fiscal.id%type
                                    , ev_atributo         in             varchar2
                                    , ev_valor            in             varchar2
                                    );

-------------------------------------------------------------------------------------------------------

-- procedimento complementa a informação da nota fiscal
procedure pkb_monta_compl_infor_adic ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                     , en_notafiscal_id    in             nota_fiscal.id%type
				     , ev_texto_compl      in             nfinfor_adic.conteudo%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida informação de exportação
-- Verifica se o cfop informado no Item é de Exportação (Tipo "7")
-- então deve obrigatóriamente constar informações nos campos "UF_Embarq" e "Local_Embarq"
procedure pkb_valida_infor_exportacao ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                      , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida informações de Importação
-- Verifica se o cfop informado no Item é do tipo de Importação ("3")
-- Se for deve obrigatóriamente existir a informação da Declaração de Importação
procedure pkb_valida_infor_importacao ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                      , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida se existe Notas Fiscais Referênciadas se a finalidade for "2-NF-e complementar"
procedure pkb_valida_nota_referenciada ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                       , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento valida informações adicionais da Nota Fiscal
procedure pkb_valida_infor_adic ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Valida informações do veículo e reboque utilizados no transporte
procedure pkb_valida_veic_transp ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                 , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida informação da transportadora
procedure pkb_valida_transportadora ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                    , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida informações do Local de Retirada/Entrega
-- verifica se existe apenas uma informação para cada registro de Retirada ou Entrega
procedure pkb_valida_nf_local ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                              , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida os itens de combustível - Só pode existir um Item de Combustível por item da nota
procedure pkb_valida_item_comb ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                               , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida informações do Veículo - Só pode existir uma informação de veículo por Nota Fiscal
procedure pkb_valida_item_veic ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                               , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida informações dos totais - Só pode existir um único registro de totais
procedure pkb_valida_total_nf ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                              , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida informações Fatura/Conbrança da Nota Fiscal - Só pode existir um registro de Fatura/Cobrança
procedure pkb_valida_nf_cobr ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                             , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida informações do Emitente da Nota Fiscal
-- verifica se existe mais de um emitente, ou se não foi informado o emitente
procedure pkb_valida_nf_emit ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                             , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida informações do Destinatário da Nota Fiscal
-- verifica se existe mais de um Destinatário, ou se não foi informado o emitente
procedure pkb_valida_nf_dest ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                             , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida a quantidade de Itema de uma Nota Fiscal - Só pode ter até 990 itens em uma nota Fiscal
procedure pkb_valida_qtde_item_nf ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                  , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida a quantidade de impostos por item da Nota Fiscal
-- Só pode existir um registro de cada tipo de imposto por Nota Fiscal
procedure pkb_valida_qtde_imposto_item ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                       , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento de válidações de impostos
procedure pkb_valida_imposto_item ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                  , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------
-- Procedimento de validações de base de impostos de ICMS

procedure pkb_valida_base_icms ( est_log_generico_nf  IN OUT NOCOPY  dbms_sql.number_table
                               , en_notafiscal_id     IN             nota_fiscal.id%type );
                               
-------------------------------------------------------------------------------------------------------

-- Função retorna as notas fiscais que não pode ser inutilizadas
function fkg_nf_nao_inutiliza ( en_empresa_id   in  inutiliza_nota_fiscal.empresa_id%type
                              , en_dm_tp_amb    in  inutiliza_nota_fiscal.dm_tp_amb%type
                              , ev_cod_mod      in  mod_fiscal.cod_mod%type
                              , en_serie        in  inutiliza_nota_fiscal.serie%type
                              , en_nro_ini      in  inutiliza_nota_fiscal.nro_ini%type
                              , en_nro_fim      in  inutiliza_nota_fiscal.nro_fim%type )
          return varchar2;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a integração da Inutilização de Notas Fiscais
procedure pkb_integr_inutilizanf ( est_log_generico_nf            in out nocopy  dbms_sql.number_table
                                 , est_row_inutiliza_nota_fiscal  in out nocopy  inutiliza_nota_fiscal%rowtype
                                 , ev_cod_mod                     in             mod_fiscal.cod_mod%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento que busca todas as Inutilizações com a situação "5-Não Validada"
procedure pkb_consit_inutilizacao ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Função cria o Lote de Envio da Nota Fiscal e retorna o ID
function fkg_integr_lote ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                         , en_empresa_id       in             empresa.id%type
			 , en_dm_forma_emiss   in             empresa.dm_forma_emiss%type default null )
         return lote.id%type;

-------------------------------------------------------------------------------------------------------

-- Processo de criação do Lote de Notas Fiscais
procedure pkb_gera_lote ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------
-- Procedimento realiza a criação de registro analitico de impostos da Nota Fiscal --
-------------------------------------------------------------------------------------
PROCEDURE pkb_gera_regist_analit_imp ( EST_LOG_GENERICO_NF IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                     , EN_NOTAFISCAL_ID IN            NOTA_FISCAL.ID%TYPE );

-------------------------------------------------------------------------------------------------------

-- Procedimento para gerar o registro C190 de Nota Fiscal
procedure pkb_gera_c190 ( en_empresa_id   in empresa.id%type
                        , ed_dt_ini       in date
                        , ed_dt_fin       in date );

-------------------------------------------------------------------------------------------------------

-- Procedimento de Cálculo de ICMS-Normal
procedure pkb_calc_icms_normal ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                               , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento de Ajuste do total da NFe
procedure pkb_ajusta_total_nf ( en_notafiscal_id in nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedure que consiste os dados da Nota Fiscal
procedure pkb_consistem_nf ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                           , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento registra Log de processamento da Nota Fiscal
procedure pkb_reg_log_proc_nfe;

-------------------------------------------------------------------------------------------------------

-- Re-envia lote que teve erro ao ser enviado a SEFAZ
procedure pkb_reenvia_lote ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento ajusta lotes que estão com a situação 2-concluído e suas notas não
procedure pkb_ajusta_lote_nfe ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento de atualiar NF-e inutilizadas
-- Depois de Homologado a Inutilização, verifica se tem alguma NFe vinculada e
-- Altera o DM_ST_PROC para 8-Inutilizada e a Situação do Documento para "05-NF-e ou CT-e - Numeração inutilizada"
procedure pkb_atual_nfe_inut ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento de atualização do campo NOTAFISCAL_ID da tabela CSF_CONS_SIT
-- Pega todos os registros que o campo NOTAFISCAL_ID estão nulos, verifica se sua chave de acesso existe
-- na tabela NOTA_FISCAL, se exitir relacionar o campo NOTA_FISCCAL.ID com campo CSF_CONS_SIT.NOTAFISCCAL_ID
procedure pkb_relac_nfe_cons_sit ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Atualiza Situação do Documento Fiscal
procedure pkb_atual_sit_docto ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Metodo para consultar NFe de Terceiro, com "Data de Autorização" menor que sete dias da data atual
-- serve para verificar se o emitente da NFe cancelou a mesma
procedure pkb_cons_nfe_terc ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Função retorna a Valor Base de Cálculo do PIS/Cofins conforme o ITEMNF_ID
function fkg_vl_base_calc_pc_itemnf ( en_itemnf_id in item_nota_fiscal.id%type )
         return imp_itemnf.vl_base_calc%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento de acerta pessoa emissão propria
PROCEDURE pkb_acerta_pessoa_emiss_prop ( EN_EMPRESA_ID IN EMPRESA.ID%TYPE
                                       , ED_DATA       IN DATE
                                       );

-------------------------------------------------------------------------------------------------------

-- Procedimento de acerta pessoa Terceiros
PROCEDURE PKB_ACERTA_PESSOA_TERCEIRO ( EN_EMPRESA_ID IN EMPRESA.ID%TYPE
                                     , ED_DATA       IN DATE
                                     );

-------------------------------------------------------------------------------------------------------

-- Procedimento de acerto de item
PROCEDURE PKB_ACERTA_ITEM_NF ( EN_EMPRESA_ID IN EMPRESA.ID%TYPE
                             , ED_DATA       IN DATE
                             );

-------------------------------------------------------------------------------------------------------

-- Procedimento acerta o vinculo de nota fiscal com os cadastros de Participante e Item
PROCEDURE PKB_ACERTA_VINC_CADASTRO ( EN_EMPRESA_ID IN EMPRESA.ID%TYPE
                                   , ED_DATA       IN DATE
                                   );

-------------------------------------------------------------------------------------------------------

-- Procedimento para gravar o log/alteração das notas fiscais
procedure pkb_inclui_log_nota_fiscal( en_notafiscal_id in nota_fiscal.id%type
                                    , ev_resumo        in log_nota_fiscal.resumo%type
                                    , ev_mensagem      in log_nota_fiscal.mensagem%type
                                    , en_usuario_id    in neo_usuario.id%type
                                    , ev_maquina       in varchar2 );

-------------------------------------------------------------------------------------------------------

-- Procedimento que retorna os valores fiscais (ICMS/ICMS-ST/IPI) de um item de nota fiscal
procedure pkb_vlr_fiscal_item_nf ( en_itemnf_id           in   item_nota_fiscal.id%type
                                 , sn_cfop                out  cfop.cd%type
                                 , sn_vl_operacao         out  number
                                 , sv_cod_st_icms         out  cod_st.cod_st%type
                                 , sn_vl_base_calc_icms   out  imp_itemnf.vl_base_calc%type
                                 , sn_aliq_icms           out  imp_itemnf.aliq_apli%type
                                 , sn_vl_imp_trib_icms    out  imp_itemnf.vl_imp_trib%type
                                 , sn_vl_base_calc_icmsst out  imp_itemnf.vl_base_calc%type
                                 , sn_vl_imp_trib_icmsst  out  imp_itemnf.vl_imp_trib%type
                                 , sn_vl_bc_isenta_icms   out  number
                                 , sn_vl_bc_outra_icms    out  number
                                 , sv_cod_st_ipi          out  cod_st.cod_st%type
                                 , sn_vl_base_calc_ipi    out  imp_itemnf.vl_base_calc%type
                                 , sn_aliq_ipi            out  imp_itemnf.aliq_apli%type
                                 , sn_vl_imp_trib_ipi     out  imp_itemnf.vl_imp_trib%type
                                 , sn_vl_bc_isenta_ipi    out  number
                                 , sn_vl_bc_outra_ipi     out  number
                                 , sn_ipi_nao_recup       out  number
                                 , sn_outro_ipi           out  number
                                 , sn_vl_imp_nao_dest_ipi out  number
                                 , sn_vl_fcp_icmsst       out  number
                                 , sn_aliq_fcp_icms       out  number
                                 , sn_vl_fcp_icms         out  number
                                 );

-------------------------------------------------------------------------------------------------------

-- Procedimento que retorna os valores fiscais (ICMS/ICMS-ST/IPI) de uma nota fiscal de serviço continuo
procedure pkb_vlr_fiscal_nfsc ( en_nfregistanalit_id   in  nfregist_analit.id%type
                              , sv_cod_st_icms         out cod_st.cod_st%type
                              , sn_cfop                out cfop.cd%type
                              , sn_aliq_icms           out nfregist_analit.aliq_icms%type
                              , sn_vl_operacao         out nfregist_analit.vl_operacao%type
                              , sn_vl_bc_icms          out nfregist_analit.vl_bc_icms%type
                              , sn_vl_icms             out nfregist_analit.vl_icms%type
                              , sn_vl_bc_icmsst        out nfregist_analit.vl_bc_icms%type
                              , sn_vl_icms_st          out nfregist_analit.vl_icms_st%type
                              , sn_vl_ipi              out nfregist_analit.vl_ipi%type
                              , sn_vl_bc_isenta_icms   out number
                              , sn_vl_bc_outra_icms    out number
                              );

--------------------------------------------------------------------------------------------------------

-- Procedimento que retorna os valores fiscais (ICMS/ICMS-ST/IPI) de um item de cupom fiscal eletrônico
procedure pkb_vlr_fiscal_item_cfe ( en_itemcupomfiscal_id  in   item_cupom_fiscal.id%type
                                  , sn_cfop                out  cfop.cd%type
                                  , sn_vl_operacao         out  number
                                  , sv_cod_st_icms         out  cod_st.cod_st%type
                                  , sn_vl_base_calc_icms   out  imp_itemcf.vl_base_calc%type
                                  , sn_aliq_icms           out  imp_itemcf.aliq_apli%type
                                  , sn_vl_imp_trib_icms    out  imp_itemcf.vl_imp_trib%type
                                  , sn_vl_base_calc_icmsst out  imp_itemcf.vl_base_calc%type
                                  , sn_vl_imp_trib_icmsst  out  imp_itemcf.vl_imp_trib%type
                                  , sn_vl_bc_isenta_icms   out  number
                                  , sn_vl_bc_outra_icms    out  number
                                  , sv_cod_st_ipi          out  cod_st.cod_st%type
                                  , sn_vl_base_calc_ipi    out  imp_itemcf.vl_base_calc%type
                                  , sn_aliq_ipi            out  imp_itemcf.aliq_apli%type
                                  , sn_vl_imp_trib_ipi     out  imp_itemcf.vl_imp_trib%type
                                  , sn_vl_bc_isenta_ipi    out  number
                                  , sn_vl_bc_outra_ipi     out  number
                                  , sn_ipi_nao_recup       out  number
                                  , sn_outro_ipi           out  number
                                  );

-------------------------------------------------------------------------------------------------------

-- Procedimento de integração dos dados do diferencial de alíquota.
procedure pkb_int_itemnf_dif_aliq ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                                  , est_row_itemnf_dif_aliq  in out nocopy  itemnf_dif_aliq%rowtype
                                  , en_notafiscal_id         in             nota_fiscal.id%type
                                  );

-------------------------------------------------------------------------------------------------------

-- Procedimento de integração dos dados do ajuste do item.
procedure pkb_integr_inf_prov_docto_fisc ( est_log_generico_nf           in out nocopy  dbms_sql.number_table
                                         , est_row_inf_prov_docto_fiscal in out nocopy  inf_prov_docto_fiscal%rowtype
                                         , ev_cod_obs                    in             obs_lancto_fiscal.cod_obs%type
                                         , ev_cod_aj                     in             cod_ocor_aj_icms.cod_aj%type
                                         , en_notafiscal_id              in             nota_fiscal.id%type
                                         , en_nro_item                   in             item_nota_fiscal.nro_item%type
                                         , en_multorg_id                 in             mult_org.id%type
                                         );

-------------------------------------------------------------------------------------------------------

-- Procedimento cria o "item" de NFe legado
procedure pkb_cria_item_nfe_legado( en_multorg_id in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento cria a Pessoa de NFe legado
procedure pkb_cria_pessoa_nfe_legado ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Função para validar as notas fiscais - utilizada na rotina de validação da GIA-SP - PK_GERA_ARQ_GIA.PKB_VALIDAR
function fkg_valida_nf ( en_empresa_id      in  empresa.id%type
                       , ed_dt_ini          in  date
                       , ed_dt_fin          in  date
                       , ev_obj_referencia  in  log_generico_nf.obj_referencia%type
                       , en_referencia_id   in  log_generico_nf.referencia_id%type )
         return boolean;
         
-------------------------------------------------------------------------------------------------------

-- Processo de relacionamento de Consulta de NFe Destinadas
procedure pkb_rel_cons_nfe_dest( en_multorg_id in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Processo de relacionamento de Download de NFe
procedure pkb_rel_down_nfe( en_multorg_id in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Processo de registro automático do MDe
procedure pkb_reg_aut_mde( en_multorg_id in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento de Indicar que a Nota Fiscal de Terceiro, informa que o DANFE foi recebido na NFE de Armazenamento de XML
--Redmine #70049  - este processo não será mais utilizado
--procedure pkb_reg_danfe_rec_armaz_terc( en_multorg_id in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento para gravar o log/alteração das apurações de ICMS
procedure pkb_inclui_log_apuracao_icms( en_apuracaoicms_id in apuracao_icms.id%type
                                      , ev_resumo          in log_apuracao_icms.resumo%type
                                      , ev_mensagem        in log_apuracao_icms.mensagem%type
                                      , en_usuario_id      in neo_usuario.id%type
                                      , ev_maquina         in varchar2 );

-----------------------------------------------------------------------------------------------------

-- Procedimento de criar o lote do MDE
procedure pkb_gera_lote_mde( en_multorg_id in mult_org.id%type );

-----------------------------------------------------------------------------------------------------

-- Procedimento de criar o lote de download do XML
procedure pkb_gera_lote_download_xml( en_multorg_id in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento que recupera o mult org de acordo com o COD e o HASH
procedure pkb_ret_multorg_id( est_log_generico       in out nocopy  dbms_sql.number_table
                            , ev_cod_mult_org        in             mult_org.cd%type
                            , ev_hash_mult_org       in             mult_org.hash%type
                            , sn_multorg_id          in out nocopy  mult_org.id%type
                            , en_referencia_id       in             log_generico_nf.referencia_id%type
                            , ev_obj_referencia      in             log_generico_nf.obj_referencia%type
                            );

-------------------------------------------------------------------------------------------------------

-- Procedimento valida o mult org de acordo com o COD e o HASH das tabelas Flex-Field
procedure pkb_val_atrib_multorg ( est_log_generico   in out nocopy  dbms_sql.number_table
                                , ev_obj_name        in             VARCHAR2
                                , ev_atributo        in             VARCHAR2
                                , ev_valor           in             VARCHAR2
                                , sv_cod_mult_org    out            VARCHAR2
                                , sv_hash_mult_org   out            VARCHAR2
                                , en_referencia_id   in             log_generico_nf.referencia_id%type
                                , ev_obj_referencia  in             log_generico_nf.obj_referencia%type
                                );

-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
-- Ler view VW_CSF_NOTA_FISCAL_CANC_FF por conta do atributo ID_ERP
procedure pkb_val_ler_nf_canc_ff ( est_log_generico_nf  in out nocopy dbms_sql.number_table
                                 , en_notafiscalcanc_id in number
                                 , ev_atributo          in varchar2
                                 , ev_valor             in varchar2
                                 );
-------------------------------------------------------------------------------------------------------
-- Função valida Nota Fiscal MDE com flag de armazenamento XML
function fkg_nota_mde_armaz( en_notafiscal_id      in       nota_fiscal.id%type
                           , en_dm_arm_nfe_terc    in       nota_fiscal.dm_arm_nfe_terc%type ) 
         return number;

--------------------------------------------------------
-- CRIA NOTA_FISCAL_MDE  --
--------------------------------------------------------
PROCEDURE PKB_GRAVA_MDE ( EN_NOTAFISCAL_ID       NOTA_FISCAL.ID%TYPE
                        , EA_TIPOEVENTOSEFAZ_ID  TIPO_EVENTO_SEFAZ.ID%TYPE
                        , EA_JUSTIFICATIVA       VARCHAR2 DEFAULT NULL);
						
----------------------------------------------------------------------------
-- Função para verificar se existe registro de erro gravados no Log Generico
----------------------------------------------------------------------------
function fkg_ver_erro_log_generico_nf( en_nota_fiscal_id in nota_fiscal.id%type )
         return number;
		 
----------------------------------------------------------------------------------------
-- Função para verificar se a empresa soma valor de IPI na Base de Calculo do ICMS Difal
----------------------------------------------------------------------------------------
function fkg_emp_calcula_icms_difal( en_empresa_id                in empresa.id%type
                                   , ed_dt_emiss                  in nota_fiscal.dt_emiss%type
                                  -- , en_estado_id_orig            in estado.id%type
                                   , en_estado_id_dest            in estado.id%type
                                   --| Item   
                                   , en_orig                      in param_icms_inter_cf.orig%type										 
                                   , en_item_id                   in item.id%type
                                   , en_ncm_id                    in ncm.id%type
                                   , en_cfop_id                   in cfop.id%type
                                   )
                                   return number; 
--
------------------------------------------------------------------------------------------------------------
-- PROCEDURE PARA RETORNAR OS VALORES DE TRIBUTAÇÃO PROVENIENTES DO IBPT
procedure pkb_busca_vlr_aprox_ibpt ( ev_cod_mod         in mod_fiscal.cod_mod%type,
                                     ev_uf_empresa      in estado.sigla_estado%type,
                                    -- en_dm_id_dest      in number, --#73353
                                     en_orig_trib_fed   in number,   --#73353
                                     ev_codigo          in valor_aprox_tributo.codigo%type,
                                     en_dm_tipo         in valor_aprox_tributo.dm_tipo%type,
                                     ev_ex_tipi         in valor_aprox_tributo.ex_tipi%type default null,
                                     ed_dt_emiss        in date,
                                     sn_trib_federal   out valor_aprox_tributo.trib_fed_nacional%type,
                                     sn_trib_estadual  out valor_aprox_tributo.trib_estadual%type,
                                     sn_trib_municipal out valor_aprox_tributo.trib_municipal%type,
                                     sv_chave_ibpt     out valor_aprox_tributo.chave_ibpt%type,
                                     sn_fonte          out valor_aprox_tributo.fonte%type,
                                     sn_erro           out number);

end pk_csf_api;
/
