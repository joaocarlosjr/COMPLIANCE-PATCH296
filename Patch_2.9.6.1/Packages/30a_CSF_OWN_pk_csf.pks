create or replace package csf_own.pk_csf is
--
---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Especificação do pacote de funções para o CSF
--
-- Em 30/12/2020 - Marcos Ferreira
-- Distribuições: 2.9.7 / 2.9.6-1 / 2.9.5-4
-- Redmine #74754: Criar procedure para criação de domínio
-- Rotinas Alteradas: Criação da procedure pkb_cria_dominio e fkg_parametro_geral_sistema
--
-- Em 21/07/2020 - Luis Marques - 2.9.4-1 / 2.9.5
-- Redmine #68300 - Falha na integração & "E" comercial - WEBSERVICE NFE EMISSAO PROPRIA (OCQ)
-- Rotina Alterada - fkg_converte - Foi criado o valor 4 para o parametro "en_ret_carac_espec" que retira os caracteres
--                   especiais mas mantem o caracter & (E comercial).
--
-- Em 06/07/2020 - Allan Magrini
-- Redmine #65449 - Remoção de caracteres especiais.
-- Foi alterada a regra dos caracteres que estão entre parenteses (º > < " Ø µ &) . Esse tratamento só deve ser feito quando parametro ret_carac_espec = 3.  
-- Rotina Alterada: fkg_converte
--
-- Em 18/05/2020 - Allan Magrini
-- Redmine #65449 - Ajustes em integração e validação 
-- Foi permitido que sejam integrados os caracteres que estão entre parenteses (º > < " Ø µ &) . Esse tratamento só deve ser feito quando parametro ret_carac_espec = 2 (Nfe).  
-- Rotina Alterada: fkg_converte
--
-- Em 13/03/2020 - Allan Magrini
-- Redmine #65711 - Informações Adicionais de NFSE não está pulando linhas 
-- Adicionado en_ret_chr10 para validação de chr10 de notas de serviço vindo da pk_csf_api_nfs, demais conversões não terão alterações
-- Rotina Alterada: fkg_converte
--
-- Em 12/02/20120 - Marcos Ferreira
-- Redmine #64831: Criação de procedure para criação de sequence e inclusão na seq_tab
-- Rotina: pkb_cria_sequence
-- Alterações: Criação de procedure para criação da sequence e inclusão na seq_tab
--
-- Em 07/02/2020 - Allan Magrini
-- Redmine #60926 - Falha na chamada da pk_csf.fkg_empresa_id_cpf_cnpj (ACECO)
-- Alteração: Incluido dm_situacao = 1 da tabela empresa para retornar somente empresa ativa
-- Rotina: fkg_empresa_id_cpf_cnpj
--
-- Em 24/01/2020 - Marcos Ferreira
-- Redmine #63891 - Customização no processo de Geração de Danfe 01_CR060_ENGIE_DANFE_V3
-- Rotina: fkg_String_dupl
-- Alteração: Inclusão de checagem de parametro e exibição da descrição do título no campo Fatura da Danfe
--
-- Em 23/01/2020 - Marcos Ferreira
-- Redmine #60926 - Verificar processo pk_csf.fkg_converte - NFINFOR_ADIC.CONTEUDO (USV)
-- Rotina: fkg_converte
-- Alteração: Ajustado Caracteres especiais
--
-- Em 15/01/2020 - Eduardo Linden
-- Redmine #63141 - Ajuste para emissão Florianopolis
-- Criação da function que retorna o ID da Tabela COD_ST_CIDADE
-- Rotina Criada: fkg_codstcidade_Id
--
-- Em 07/01/2020 - Allan Magrini
-- Redmine #63050 - feed - não está sendo exibido a mensagem de validação referente a data e o modelo
-- Adicionado o return vn_qtde_lac_aquav na função
-- Rotina Alterada: fkg_valid_lacre_aquav
--
-- Em 07/01/2020 - Eduardo Linden
-- Redmine #63309 - Feed - geração do m400/M800
-- Criação de nova function retorna o primeiro ID do plano de conta do Tabela plano_conta_nat_rec_pc .
-- Rotina criada: fkg_plcnatpecpc_plc_id
--
-- Em 03/01/2020 - Eduardo Linden
-- Redmine #63246 - Alteração da geração do M400/M800 a partir do F500/F550
-- Criação de nova function para obter o id da tabela NAT_PEC_PC
-- Rotina criada: fkg_natrecpc_id
--
-- Em 20/12/2019 - Luis Marques
-- Redmine #62274 - CNAE
-- Função alterada: fkg_id_cnae_cd - retirado do campo "cd" na tabela cnae os caractesres ".-/" ponto, traço e barra para 
--                  pesquisa do id do cnae visto que na tela o campo é de 7 digitos e só aceita numeros.
--
-- Em 18/12/2019 - Allan Magrini
-- Redmine #61174 - Inclusão de modelo de documento 66
-- Adicionado '66' na validação do cod_mod, notas de seviços continuos, fase 6 e 11
-- Rotina: fkg_busca_notafiscal_id
--
-- Em 10/12/2019 - Eduardo Linden
-- Redmine #62393 - Problema no SPED PIS/COFINS
-- Tratamento para evitar erro ORA-01422: exact fecth returns more than requested number of rows.
-- Rotina Alterada: fkg_ncmnatrecpc_plc_id
--
-- Em 06/11/2019 - Eduardo Linden
-- Redmine #57982 - [PLSQL] Geração do M400/800 a partir do F500
-- Criadas novas functions para :
-- 1) retorno da planoconta_id das tabelas nat_rec_pc e ncm_nat_rec_pc.
-- 2) retorno ID do Tabela NAT_PEC_PC a partir da tabela NCM_NAT_REC_PC
-- Rotinas Criadas : fkg_natrecpc_plc_id , fkg_ncmnatrecpc_plc_id e fkg_ncmnatrecpc_npp_id.
--
-- Em 05/11/2019        - Karina de Paula
-- Redmine #60526	- Retorno de NFe - Open Interface
-- Rotinas Alteradas    - fkg_empresa_id_cpf_cnpj => Alterada a busca do id da empresa
-- NÃO ALTERE A REGRA DESSAS ROTINAS SEM CONVERSAR COM EQUIPE
--
-- Em 09/10/2019        - Karina de Paula
-- Redmine #52654/59814 - Alterar todas as buscar na tabela PESSOA para retornar o MAX ID
-- Rotinas Alteradas    - fkg_Pessoa_id_cpf_cnpj / fkg_cnpj_empresa_id(EXCLUÍDA) / fkg_Pessoa_id_cpf_cnpj_interno(EXCLUÍDA)
-- Obs1.: As functions fkg_Pessoa_id_cpf_cnpj_interno e fkg_Pessoa_id_cpf_cnpj  eram iguais então foi deixada somente a fkg_Pessoa_id_cpf_cnpj
-- Obs2.: As functions fkg_cnpj_empresa_id            e fkg_empresa_id_cpf_cnpj eram iguais então foi deixada somente a fkg_empresa_id_cpf_cnpj
-- NÃO ALTERE A REGRA DESSAS ROTINAS SEM CONVERSAR COM EQUIPE
--
-- Em 05/09/2019   - Karina de Paula
-- Redmine #58459  - Não está integrando mais de um item de serviço
-- Rotina Alterada - fkg_existe_item_nota_fiscal => Excluída a verificação pk_csf.fkg_existe_item_nota_fiscal porque podemos ter mais
--                   de um item para a nota fiscal de serviço. Criada a verificação de duplicação da nota_fiscal_cobr (vn_nfcobr_id),
--                   para tratar a atividade 56740 que criou inicialmente a pk_csf.fkg_existe_item_nota_fiscal.
--
-- Em 02/09/2019 - Karina de Paula
-- Redmine 41413 - Lentidão para execução da PK_INTEGR_VIEW_NFS e pk_valida_ambiente_nfs (UNIP)
-- Rotina Criada: pkb_ret_dados_empresa => Procedure retorna dados da empresa
--
-- Em 30/08/2019 - Luis Marques
-- Redmine #57715 - Alterar função para integração de caracteres permitidos na NF-e
-- Function alterada: fkg_converte
-- Liberado todos caracteres para NF-e deixando bloqueado apenas os que dão erro de parse conforme manual, parametro
-- 'en_ret_carac_espec' passar 2
--
-- Em 21/08/2019 - Eduardo Linden
-- Redmine #50987 - Exclusão de Notas Fiscais e CTE vinculados ao REINF
-- Criação das funções para validar se Nota Fiscal está submetida ou não aos eventos R-2010 e R-2020 do Reinf.
-- Rotina criada: fkg_existe_reinf_r2010_nf e fkg_existe_reinf_r2020_nf
--
-- Em 19/08/2019 - Luis Marques
-- Redmine #56740 - defeito - Nota está ficando com erro de validação na duplicidade - Release 291
-- Nova Function: fkg_existe_item_nota_fiscal
--
-- Em 21/07/2019 - Luis Marques
-- Redmine # 56565
-- Nova Functions: fkg_empresa_dmvalpis_emis_nfs, fkg_empresa_dmvalpis_terc_nfs
--                 fkg_empr_dmvalcofins_emis_nfs, fkg_empr_dmvalcofins_terc_nfs
--
-- Em 26/06/2019 - Luiz Armando Azoni.
-- Redmine #52815
-- Adequação do processo para recuperar a quantidade a ser impressa.
-- procedure: pkb_impressora_id_serie.
--
-- Em 26/06/2019 - Luiz Armando Azoni.
-- Redmine #55659
-- Inclusão da função fkg_impressora_id_serie que recupera o valor da impressora_id para registra na nota fiscal.
--
-- Em 20/03/2012 - Angela Inês.
-- Inclusão da função para validar dígito verificador da chave de acesso da nota fiscal eletrônica ou conhecimento de transporte
--
-- Em 20/03/2012 - Angela Inês.
-- Exclusão da função para validar dígito verificador da chave de acesso da nota fiscal eletrônica ou conhecimento de transporte
-- Esse processo deve ser uma função isolada dos procedimentos da Compliance.
--
-- Em 09/04/2012 - Angela Inês.
-- Alteração na função que recupera identificador do plano de contas - fkg_Plano_Conta_id.
-- Recuperar o identificador da conta pela empresa enviada no parâmetro, e caso não exista, recuperar da empresa matriz.
--
-- Em 17/05/2012 - Angela Inês.
-- Inclusão de função para retornar parâmetro da empresa de validação de CFOP por destinatário - fkg_dm_valcfoppordest_empresa.
--
-- Em 18/05/2012 - Angela Inês.
-- Inclusão de função para retornar indicador de operação da nota fiscal - nota_fiscal.dm_ind_oper -> 0-entrada, 1-saída - fkg_recup_dmindoper_nf_id.
--
-- Em 05/07/2012 - Angela Inês.
-- Inclusão de função para retornar o identificador do modelo fiscal da nota fiscal - nota_fiscal.modfiscal_id - através do identificador da nota fiscal.
-- Rotina fkg_recup_modfisc_id_nf.
--
-- Em 25/07/2012 - Angela Inês.
-- Inclusão de função para retornar se a empresa permite validação de cfop de crédito de pis/cofins para notas fiscais de pessoa física.
-- Rotina: fkg_empr_val_cred_pf_pc.
--
-- Em 13/09/2012 - Angela Inês.
-- Correção na declaração da variável (utilizando 'in') - Função retorna o ID da tabela Tipo_Servico - fkg_Tipo_Servico_id.
--
-- Em 19/09/2012 - Angela Inês.
-- Inclusão da função para verificar campos Flex Field - FF.
-- Rotina: fkg_ff_verif_campos.
-- Inclusão da função para retornar o domínio - tipo do campo Flex Field - FF, através do objeto e do atributo.
-- Rotina: fkg_ff_retorna_dmtipocampo
-- Inclusão da função para retornar o tamanho do campo Flex Field - FF, através do objeto e do atributo.
-- Rotina: fkg_ff_retorna_tamanho
-- Inclusão da função para retornar a quantidade em decimal do campo Flex Field - FF, através do objeto e do atributo.
-- Rotina: fkg_ff_retorna_decimal
-- Inclusão da função para retornar o valor dos campos Flex Field - FF - tipo DATA.
-- Rotina: fkg_ff_ret_vlr_data
-- Inclusão da função para retornar o valor dos campos Flex Field - FF - tipo NUMÉRICO.
-- Rotina: fkg_ff_ret_vlr_number
-- Inclusão da função para retornar o valor dos campos Flex Field - FF - tipo CARACTERE.
-- Rotina: fkg_ff_ret_vlr_caracter
--
-- Em 26/09/2012 - Angela Inês.
-- Alterar os nomes das FKB para FKG, nas rotinas de campos FF - Flec Field.
--
-- Em 22/11/2012 - Angela Inês.
-- Ficha HD 64702 - Erro na geração do registro 0500.
-- 1) Implementar a função que recupera o código da conta do plano de contas através do identificador do plano.
-- 2) Implementar a função que recupera o código do centro de custo através do identificador do centro de custo.
-- Rotina: fkg_cd_plano_conta e fkg_cd_centro_custo.
--
-- Em 27/12/2012 - Angela Inês.
-- Ficha HD 65154 - Fechamento Fiscal por empresa. Função que retorna a última data de fechamento fiscal por empresa.
-- Rotina: fkg_recup_dtult_fecha_empresa.
--
-- Em 30/01/2013 - Vanessa Ribeiro
-- Inclusao da fkg_existe_item_compl
--
-- Em 20/02/2013 - Angela Inês.
-- Ficha HD 66153 - Inclusão da função que recupera os identificadores de pessoa através do cnpj ou cpf.
-- Rotina: fkg_ret_string_id_pessoa.
--
-- Em 25/02/2013 - Rogério Silva.
-- Exclusão da função fkg_busca_conhectransp_id (função substituida pela mesma porém da package PK_INTEGR_VIEW_CT).
-- Rotina: fkg_busca_conhectransp_id.
--
-- Em 09/04/2013 - Angela Inês.
-- Ficha HD 64892 - Geração do SEF-PE.
-- Correção na recuperação do código do tipo de item, pois a variável de retorno é caracter e estava retornando numérico.
-- Rotina: fkg_cd_tipo_item_id.
--
-- Em 26/04/2013 - Angela Inês.
-- Ficha HD 66641 - Bloco F100 - Se informar ITEM na tela, VALIDAR se tem NCM no cadastro de ITEM e se está cadastrado com natureza de crédito NCM_NAT_REC_PC.
-- Criada função para validar código NCM relacionado co item, e função para validar código NCM e Natureza de receita para geração de Pis/Cofins.
-- Rotinas: fkg_item_ncm_valido e fkg_ncm_id_item.
--
-- Em 02/05/2013 - Angela Inês.
-- Sem ficha HD - Aline - Sermmatec - Integração de notas fiscais de serviço modelo 99.
-- Na integração foi encontrada nota fiscal de serviço sem pessoa_id com a mesma chave a ser integrada.
-- Correção para busca de nota fiscal de acordo com o dm_st_proc da mesma.
-- Rotina: fkg_busca_notafiscal_id.
--
-- Em 02/07/2013 - Angela Inês.
-- Redmine Atividade #303 - Validação de informações Fiscais - Ficha HD 66733.
-- Inclusão de função para recuperar o parâmetro da empresa: dm_ajust_desc_zfm_item. Rotina: fkg_empr_ajust_desc_zfm_item.
-- Função para retornar o tipo de emitente da nota fiscal - nota_fiscal.dm_ind_emit = 0-emissão própria, 1-terceiros. Rotina: fkg_dmindemit_notafiscal.
-- Função para retornar a finalidade da nota fiscal - nota_fiscal.dm_fin_nfe = 1-NF-e normal, 2-NF-e complementar, 3-NF-e de ajuste. Rotina: fkg_dmfinnfe_notafiscal.
-- Função para retornar a sigla do estado do emitente da nota fiscal. Rotina: fkg_uf_notafiscalemit.
-- Função para retornar a sigla do estado do destinatário da nota fiscal. Rotina : fkg_uf_notafiscaldest.
-- Função para retornar o identificador de pessoa da nota fiscal. Rotina: fkg_pessoa_notafiscal_id.
--
-- Em 18/07/2013 - Angela Inês.
-- RedMine 58 - Ficha HD 66037
-- Melhoria na validação de impostos de Nota Fiscal mercantil, separar a validação de "Emissão Própria" e "Emissão de Terceiros".
-- Duplicar os parâmetros para validação de impostos: icms, icms-60, ipi, pis, cofins.
-- Os que já existem deverão fazer parte da opção Emissão Própria, que são: DM_VALID_IMP, DM_VALID_ICMS60, DM_VALIDA_IPI, DM_VALIDA_PIS, DM_VALIDA_COFINS.
-- Os novos deverão fazer parte da opção Terceiros, ficando: DM_VALID_IMP_TERC, DM_VALID_ICMS60_TERC, DM_VALIDA_IPI_TERC, DM_VALIDA_PIS_TERC, DM_VALIDA_COFINS_TERC.
-- Alterado os nomes das funções para: fkg_empresa_dmvalimp_emis, fkg_empresa_dmvalicms60_emis, fkg_empresa_dmvalipi_emis, fkg_empresa_dmvalpis_emis e fkg_empresa_dmvalcofins_emis.
-- Criadas as funções: fkg_empresa_dmvalimp_terc, fkg_empresa_dmvalicms60_terc, fkg_empresa_dmvalipi_terc, fkg_empresa_dmvalpis_terc e fkg_empresa_dmvalcofins_terc.
--
-- Em 22/07/2013 - Rogério Silva.
-- RedMine Atividade #399
-- Inclusão das funções: fkg_grupopat_id e fkg_subgrupopat_id
--
-- Em 24/07/2013 - Rogério Silva.
-- RedMine Atividade #398
-- Inclusão das funções: fkg_existe_grupo_pat, fkg_existe_subgrupo_pat, fkg_recimpsubgrupopat_id e fkg_existe_imp_subgrupo_pat.
--
-- Em 24/07/2013 - Angela Inês.
-- Eliminado a função fkg_item_id por estar usando somente o código do item e este pode estar cadastrado para outras empresas.
--
-- Em 25/07/2013 - Rogério Silva.
-- RedMine Atividade #401
-- Inclusão das funções: fkg_nfbemativoimob_id, fkg_existe_nf_bem_ativo_imob e fkg_itnfbemativoimob_id.
--
-- Em 26/07/2013 - Rogério Silva.
-- RedMine Atividade #401 e #400
-- Inclusão das funções: fkg_existe_itnf_bem_ativo_imob, fkg_recimpbemativoimob_id e fkg_existe_rec_imp_bem_ativo.
--
-- Em 12/08/2013 - Angela Inês.
-- Redmine #504 - Notas com divergência de sigla de estado da pessoa_id da nota com emitente ou destinatário.
-- Rotinas: fkg_pessoa_id_cpf_cnpj, fkg_pessoa_id_cpf_cnpj_interno e fkg_pessoa_id_cpf_cnpj_uf.
--
-- Em 09/09/2013 - Angela Inês.
-- Redmine #648 - Suporte - Tadeu/Verdemar - Geração do PIS/COFINS - Abertura do arquivo.
-- Recuperar o parâmetro da empresa que indica se irá utilizar recuperação do tipo de crédito com o processo Embalagem ou não.
-- Rotina: fkg_dmutilprocemb_tpcred_empr.
--
-- Em 17/09/2013 - Rogério Silva
-- Inclusão da função fkg_cod_class
--
-- Em 17/09/2013 - Rogério Silva
-- Inclusão da função fkg_codconsitemcont_cod
--
-- Em 25/09/2013 - Rogério Silva
-- Inclusão da função fkg_nro_fci_valido
--
-- Em 08/10/2013 - Rogério Silva
-- Inclusão da função fkg_tipoeventosefaz_cd
--
-- Em 24/10/2013 - Rogério Silva
-- Inclusão da função fkg_tipoeventosefaz_id
--
-- Em 28/10/2013 - Angela Inês.
-- Redmine #1274 - Eliminar a função pk_csf.fkg_nota_fiscal_id.
-- Rotina: fkg_nota_fiscal_id.
--
-- Em 31/10/2013 - Rogério Silva
-- Inclusão da função fkg_paiscnpj_cnpj
--
-- Em 04/11/2013 - Rogério Silva
-- Inclusão da função fkg_inscr_mun_empresa
--
-- Em 04/11/2013 - Rogério Silva
-- Inclusão da função fkg_ibge_cidade_empresa
--
-- Em 06/11/2013 - Angela Inês.
-- Redmine #1161 - Alteração do processo de validação de valor dos documentos fiscais.
-- Inclusão da função para retornar o valor de tolerância para os valores de documentos fiscais (nf, cf, ct) e caso não exista manter 0.03.
-- Rotina: fkg_vlr_toler_empresa.
--
-- Em 20/02/2014 - Angela Inês.
-- Redmine #1979 - Alterar processo nota fiscal devido aos modelos fiscais de serviço contínuo, incluir data de emissão.
-- Rotina: fkg_busca_notafiscal_id.
--
-- Em 03/03/2014 - Angela Inês.
-- Redmine #2043 - Alterar a API de integração de cadastros incluindo o cadastro de Item componente/insumo.
-- Incluir as funções: fkg_item_insumo_id e fkg_existe_iteminsumo.
--
-- Em 10/04/2014 - Angela Inês.
-- Redmine #2505 - Alteração da Geração do arquivo do Sped ICMS/IPI.
-- Inclusão da função que retorna o código de ajuste das obrigações a recolher através do identificador.
-- Rotina: fkg_cd_ajobrigrec.
--
-- Em 09/09/2014 - Rogério Silva.
-- Redmine #4065
-- Alteração para remover virgulas e pontos dos valores de campos flex-field
-- Rotinas: fkg_ff_ret_vlr_number e fkg_ff_verif_campos.
--
-- Em 15/10/2014 - Rogério Silva.
-- Sem atividade - Problema encontrado pelo Mateus durante testes de validação de nota.
-- Estava dando erro ao executar a função fkg_busca_notafiscal_id.
-- Foi adicionado os valores da chave da nota na mensagem de erro
--
-- Em 30/10/2014 - Angela Inês.
-- Redmine #4961 - Incluir novos tipos de log para limpeza da log_generico.
-- Incluir os códigos: INFO_NFE_INTEGRADA, INFO_ENV_EMAIL_DEST_NFE, INFO_IMPRESSAO_DANFE, CONS_SIT_NFE_SEFAZ, INFO_CANC_NFE, INFO_INTEGR,
-- CONHEC_TRANSP_INTEGRADO, INFORMACAO.
-- Rotina: pkb_limpa_log.
--
-- Em 18/11/2014 - Rogério Silva.
-- Redmine #5254 - Erro de validação em NFSe com dados corretos.
-- Rotina: fkg_Tipo_Servico_id
--
-- Em 21/11/2014 - Rogério Silva.
-- Redmine #5287 - Confirmação Automática do MDe para Barcelos
-- Rotina: fkg_empresa_reg_mde_aut
--
-- Em 21/11/2014 - Leandro Savenhago
-- Redmine #5287 - Alterações na package PK_CSF para atender a melhoria de Mult-Organização
-- Novas Rotinas: fkg_multorg_id, fkg_tipoobjintegr_id
-- Alteradas: fkg_Pessoa_id_cpf_cnpj, fkg_pessoa_id_cod_part, fkg_busca_notafiscal_id, fkg_contador_id, fkg_Pessoa_id_cpf_cnpj_interno,
--            fkg_ret_string_id_pessoa, fkg_pessoa_id_cpf_cnpj_uf, fkg_neo_usuario_id_conf_erp, pkb_insere_usuario, fkg_usuario_email_conf_erp,
--            fkg_Empresa_id, fkg_nome_empresa, fkg_empresa_id_pelo_cpf_cnpj, fkg_empresa_id_pelo_ie, fkg_empresa_id2, fkg_Unidade_id
--
-- Em 28/11/2014 - Rogério Silva.
-- Redmine #5364 - Alterações na package PK_CSF
-- Rotina alteradas: fkg_grupopat_id
--
-- Em 01/12/2014 - Rogério Silva.
-- Redmine #5364 - Alterações na package PK_CSF
-- Rotinas criadas: fkg_cod_ind_bem_id, fkg_subgrupopat_cd e fkg_grupopat_cd_subgrupo_id
--
-- Em 02/12/2014 - Rogério Silva.
-- Redmine #5364 - Alterações na package PK_CSF
-- Rotinas alteradas: fkg_Nat_Oper_id, fkg_natoper_id_cod_nat, fkg_Infor_Comp_Dcto_Fiscal_id, fkg_id_obs_lancto_fiscal
--
-- Em 05/12/2014 - Rogério Silva.
-- Redmine #5364 - Alterações na package PK_CSF
-- Rotinas criadas: fkg_existe_plano_conta, fkg_existe_pc_referen, fkg_existe_centro_custo
--
-- Em 06/12/2014 - Rogério Silva.
-- Redmine #5364 - Alterações na package PK_CSF
-- Rotinas criadas: fkg_existe_hist_padrao
--
-- Em 26/12/2014 - Angela Inês.
-- Redmine #5616 - Adequação dos objetos que utilizam dos novos conceitos de Mult-Org.
-- Inverter os parâmetros de entrada mantendo en_multorg_id como sendo o primeiro parâmetro.
--
-- Em 22/01/2015 - Rogério Silva
-- Redmine #5889 - Alterar integrações em bloco para usar o where e rownum
-- rotinas: fkg_quantidade e fkg_monta_obj
--
-- Em 23/02/2015 - Rogério Silva.
-- Redmine #6510 - Criar validação CodTributCidade.
-- Rotina: fkg_cidade_descr
--
-- Em 10/03/2015 - Rogério Silva.
-- Redmine #6881 - Integração de notas com CFOP 1152 (BARCELOS)
-- Rotina: fkg_monta_obj
--
-- Em 26/03/2015 - Rogério Silva.
-- Redmine #7195 - Realizar testes com base nas alterações efetuadas nos processos que usam a tabela CTRL_RESTR_PESSOA
-- Rotina: fkg_multorg_id_usuario
--
-- Em 26/03/2015 - Rogério Silva.
-- Redmine #7276 - Falha na integração de notas - BASE HML (BREJEIRO)
-- Rotina: fkg_dm_tp_amb_nf
--
-- Em 13/04/2015 - Angela Inês.
-- Redmine #7500 - Validação dos dados Cadastrais de Participantes (SOUTHCO).
-- O processo de validação do cadastro de pessoa recuperava os valores de tipo e valor de parâmetro pelos identificadores (ID), mas não recuperava o
-- código dos mesmos (CD), por isso os valores não estavam sendo encontrados. Criação de nova função.
-- Rotina: fkg_cd_tipoparam.
--
-- Em 22/04/2015 - Rogério Silva.
-- Redmine #6327 - Importar Arquivo ECD para Compliance - Processo Oficializar Arquivo.
-- Rotina: fkg_split
--
-- Em 23/04/2015 - Rogério Silva.
-- Redmine #7494 - Erro validação código do serviço no SPED Fiscal.
-- Rotina: fkg_Tipo_Servico_id
--
-- Em 27/04/2015 - Rogério Silva.
-- Redmine #7908 - Alterar função de buscar o id a nota fiscal para considerar apenas a data sem a hora
-- Rotina: fkg_busca_notafiscal_id
--
-- Em 05/05/2015 - Rogério Silva.
-- Redmine #6327 - Importar Arquivo ECD para Compliance - Processo Oficializar Arquivo.
-- Rotina: pkb_dividir
--
-- Em 05/05/2015 - Rogério Silva.
-- Redmine #8071 - Não está gerando lote pra notas de serviço.
-- Rotina: fkg_Tipo_Servico_id
--
-- Em 12/05/2015 - Rogério Silva.
-- Redmine #7226 - Criar package pk_vld_amb_usuario.
-- Rotinas: fkg_papel_nome_conf_id, fkg_empresa_id_cpf_cnpj
--
-- Em 18/05/2015 - Rogério Silva.
-- Redmine #8198 - Travar alteração na Forma de Emissão de NFe, quando for EPEC
--
-- Em 22/05/2015 - Rogério Silva.
-- Redmine #7711 - Consistir na integração da emissão nfe dt_emiss superior a 30 dias
-- Rotina: fkg_estado_lim_emiss_nfe
--
-- Em 02/06/2015 - Rogério Silva.
-- Redmine #7754 - Registro duplicado NFe própria/terceiro (SANTA FÉ)
--
-- Em 17/06/2015 - Angela Inês.
-- Redmine #9271 - Erro Registro C113 SISMETAL (ACECO).
-- Inclusão da função que recupera a situação do documento fiscal através do identificador da nota fiscal.
-- Rotina: fkg_sitdoc_id_nf.
--
-- Em 30/06/2015 - Rogério Silva.
-- Redmine #9335 -  Ao reenviar uma nota em EPEC, está ficando com o nro de protocolo nulo
--
-- Em 17/07/2015 - Angela Inês.
-- Redmine #10117 - Escrituração de documentos fiscais - Processos.
-- Criar a função para recuperar o parâmetro que indica qual data será escriturado o documento fiscal.
-- Rotina: fkg_dmdtescrdfepoe_empresa.
--
-- Em 30/07/2015 - Rogério Silva
-- Redmine #10208 - Códigos de País - IBGE e SISCOMEX. Processo de Validação.
-- Rotina: fkg_pais_id_tipo_cod_arq
--
-- Em 05/08/2015 - Rogério Silva
-- Redmine #9829 - Implementação do processo de exportação de Nota Fiscais de serviços Tomados para a prefeitura do Rio de Janeiro/RJ
-- Rotina: fkg_inscr_mun_pessoa
--
-- Em 07/10/2015 - Angela Inês.
-- Redmine #11911 - Implementação do UF DEST nos processos de Integração e Validação.
-- Inclusão de função para identificar se já existe grupo de tributação do imposto ICMS.
-- Rotina: fkg_existe_imp_itemnficmsdest.
--
-- Em 19/11/2015 - Leandro Savenhago
-- Implementado a limpeza de tabelas de log que não foram feitas
-- Rotina: pkb_limpa_log
--
-- Em 30/11/2015 - Angela Inês.
-- Redmine #13264 - Não está integrando as notas 1007 e 1008.
-- Correção no tamanho do campo VALOR para varchar2(600).
-- Rotina: fkg_ff_verif_campos e fkg_ff_ret_vlr_caracter.
--
-- Em 23/12/2015 - Rogério Silva.
-- Redmine #14035 - Rever procedimento pk_csf.pkb_acerta_sequence
--
-- Em 17/05/2016 - Marcos Garcia
-- Redmine #18958 - Implementar uma function que passa o id da nota por parametro e retorna as informações adicionais
-- mais detalhes na descrição desta tarefa
-- Rotina: fkg_info_adicionais
--
-- Em 02/06/2016 - Angela Inês.
-- Redmine #19699 - Validação de Notas Fiscais de Emissão Própria e Modelos '55' e '65'.
-- Funções criadas: fkg_empr_dt_venc_cert_ok e fkg_empr_dt_venc_cert.
--
-- Em 16/06/2016 - Angela Inês.
-- Redmine #20262 - Função/Processo que recupera a nota fiscal - Utilização Geral.
-- Alterar o processo que recupera as Notas Fiscais de emissão própria (nota_fiscal.dm_ind_emit=0) e modelo fiscal diferente de ('06', '21', '22', '29', '28'),
-- passando a recuperar a nota mais antiga pelo identificador da nota (min(nota_fiscal.id)), quando for encontrado mais de um registro.
-- Rotina: fkg_busca_notafiscal_id.
--
-- Em 27/06/2016 - Angela Inês.
-- Redmine #20697 - Correção nos parâmetros do Sped ICMS/IPI - DIFAL - Partilha de ICMS - Processos.
-- Incluir na função pkb_param_difal_efd_icms_ipi, outro parâmetro de saída CODAJSALDOAPURICMS_ID_DIFPART.
--
-- Em 23/01/2017 - Angela Inês.
-- Redmine #26824 - Correção no processo de acerto de sequence: Eliminar a tabela NOTA_FISCAL do processo.
-- A tabela nota_fiscal possui uma sequence diferenciada nos clientes que utilizam o ERP/SGI, temos que deixar um intervalo de valores específico.
-- Se o processo de atualização de sequence for executado, os valores das sequences ficaram incorretos.
-- Caso seja necessário atualizar a sequence da tabela nota_fiscal, o processo deverá ser específico e com atenção aos clientes de ERP/SGI.
-- Rotina: pkb_acerta_sequence.
--
-- Em 25/01/2017 - Leandro Savenhago
-- Redmine #27546 - Adequação dos impostos no DANFE/XML NFe modelo 55 - Lei da transparência
-- criação da função fkg_empresa_inf_trib_op_venda
--
-- Em 16/02/2017 - Marcos Garcia
-- Criação da função que retorna o id da tabela PARAM_ITEM_ENTR e PARAM_OPER_FISCAL_ENTR conforme a sua Unique.
-- Rotina: fkg_paramitementr_id, fkg_paramoperfiscalentr_id
--
-- Em 23/04/2017 - Leandro Savenhago
-- Redmine #28780 - Parâmetro de Formato de Data Global para o Sistema
-- criação da função fkg_param_global_csf_form_data
--
-- Em 09/03/2017 - Fábio Tavares
-- Redmine #28949 - Impressão de Local de Retirada e Local de Entrega na Nota Fiscal Mercantil.
--
-- Em 09/03/2017 - Leandro Savenhago
-- Redmine #29225 - Adição de Tags no XML de NFe para Parker
-- criação da função fkg_limpa_acento2, para não limpar caracteres como <>|! que seram utilizados em comentários de XML
--
-- Em 30/05/2017 - Angela Inês.
-- Redmine #31537 - Alterar a função que converte caracteres especiais - comando ENTER/CHR(10).
-- Eliminar da função que converte uma string limpando caracteres especiais, o comando que elimina o "ENTER"/"CHR".
-- Hoje no processo PK_CSF temos as funções FKG_CONVERTE, FKG_LIMPA_ACENTO e FKG_LIMPA_ACENTO2.
-- A função que será alterada é FKG_LIMPA_ACENTO2. Essa função é utilizada na validação da nota fiscal mercantil (pk_csf_api.pkb_integr_item_nota_fiscal e
-- pk_csf_api.pkb_integr_nfinfor_adic), com relação aos campos: Informações adicionais do produto (item_nota_fiscal.infadprod), e CONTEUDO de Informações
-- Adicionais (nfinfor_adic.conteudo).
-- Rotina: fkg_limpa_acento2.
--
-- Em 05/06/2017 - Angela Inês.
-- Redmine #31707 - Alterar função que elimina caracteres especiais.
-- Alterar na função que limpa os acento, para que a mesma limpe somente os caracteres especiais, deixando os espaços entre as palavras devido a montagem do texto.
-- Eliminar da função o caracter '%', pois esse caracter não deve ser eliminado.
-- Rotina: fkg_limpa_acento2.
--
-- Em 06/06/2017 - Angela Inês.
-- Redmine #31750 - Alterar a função que elimina os caracteres especiais - pk_csf.fkg_limpa_acento2.
-- Alterar a função que elimina somente os caracteres e o espaço inicial e final, para eliminar também o comando ENTER do início e do final do arquivo.
-- Rotina: fkg_limpa_acento2.
--
-- Em 25/08/2017 - Marcelo Ono
-- Redmine #33869 - Inclusão da função para verificar participante está cadastro como empresa
-- Rotina: fkg_valida_part_empresa.
--
-- Em 28/09/2017 - Angela Inês.
-- Redmine #33434 - Alterar o processo de validação de cadastros gerais - atualização de dependentes do ITEM.
-- 1) Na rotina que integra os Itens, executar o processo de atualização de dependência de item, se o parâmetro da empresa indicar que devem ser atualizadas
-- as dependências do Item (itens de notas fiscais sem o identificador do item - item_nota_fiscal.item_id).
-- Incluir função que retorna o indicador de atualização de dependências do Item na Integração de Cadastros Gerais - Item
-- Rotina: fkg_empr_dm_atual_dep_item.
--
-- Em 10/10/2017 - Marcos Garcia
-- Redmine#35132 - Alterações nos processos de Integração sobre Exportação.
-- Adicionado a funçao que recupera o identificador da informação sobre exportação
-- a nova coluna que faz parte da chave unica, NRO_RE. Rotina: fkg_busca_infoexp_id
--
-- Em 11/10/2017 - Marcelo Ono.
-- Redmine #35373 - Inclusão de processo para converter o caractere especial \n "New line" por chr(10) "Enter".
-- Rotina: fkg_converte.
--
-- Em 23/10/2017 - Marcelo Ono.
-- Redmine #35619 - Correção no processo de conversão do caractere especial \n "New line" por chr(10) "Enter".
-- 1- Implementado processo para verificar se a string original está com o caractere \n "New line", e caso esteja,
-- não deverá retirar o caractere chr(10) "Enter" da string.
-- Obs: Este processo foi implementado especificamente para o cliente Venâncio, que está enviando o caractere "\n" representando a quebra de linha.
-- Rotina: fkg_converte.
--
-- Em 23/01/2018 - Karina de Paula
-- Redmine #38656 - Processos de integração de Conhecimento de Transporte - Modelo D100.
-- Inclusão do modelo fiscal 67 na function fkg_cte_nao_integrar
--
-- Em 09/02/2018 - Karina de Paula
-- Redmine #39221 - Alteração nos processos de Informações sobre Exportação - Coluna CHC_EMB.
-- Rotina Alterada: fkg_busca_infoexp_id => Incluído o parâmetro entrada ev_chc_emb. Incluída a coluna na condição where do select
--
-- Em 09/02/2018 - Marcelo Ono
-- Redmine #39282 - Implementado função para recuperar o id e o código da fonte pagadora REINF.
-- Rotina: fkg_recup_fonte_pagad_reinf_id, fkg_recup_fonte_pagad_reinf.
--
-- Em 08/03/2018 - Angela Inês.
-- Redmine #40180 - Alteração na geração do arquivo Sped Fiscal - Registros C100 e 0450.
-- Criado parâmetro em "Parâmetros do Sped ICMS/IPI": param_efd_icms_ipi.dm_quebra_infadic_spedf - 0-Não, 1-Sim.
-- Função: fkg_parefdicmsipi_dmqueinfadi.
--
-- Em 26/07/2018 - Angela Inês.
-- Redmine #45214 - Geração da DANFE Adicionar as informações referente ao Nro_Fatura no quadro Fatura do pdf.
-- Foi criado um parâmetro interno para ser utilizado na função que recupera as faturas e suas parcelas. Essa função é utilizada em dois processos: Geração da
-- DANFE e Geração de Arquivo de Emissão Própria de Serviço Prestado - NFSe.
-- Parâmetro de entrada: en_monta_nro_fat, sendo: 0-Não monta o Nro da Fatura, 1-Sim, monta o Nro da Fatura.
-- Função: fkg_String_dupl.
--
-- Em 09/08/2018 - Eduardo Linden
-- Redmine #45728 - Campo nota_fiscal.vers_proc está sendo preenchido com '2.8.4.5' na release 286
-- Alteracao do processo para obter a recuperar o código da versão mais recente na tabela versao_sistema.
-- Função: fkg_ultima_versao_sistema.
--
-- Em 15/10/2018 - Eduardo Linden
-- Redmine #47653 - Inclusão das functions para os parametros de validação de base icms : empresa.dm_valid_base_icms e
-- empresa.dm_valid_base_icms_terc
-- Função: fkg_empresa_dmvalbaseicms_emis e fkg_empresa_dmvalbaseicms_terc
--
-- Em 25/10/2018 - Karina de Paula
-- Redmine #39990 - Adpatar o processo de geração da DIRF para gerar os registros referente a pagamento de rendimentos a participantes localizados no exterior
-- Rotina Alterada: fkg_existe_item_compl => Alterada a msg de erro que estava como erro no objeto fkg_existe_inf_rend_dirf_msl
-- Rotina Criada: fkg_cod_nif_pessoa / fkg_sigla_pais / fkg_pais_obrig_nif
--
-- Em 30/10/2018 - Karina de Paula
-- Redmine #47549 - Adaptar packages de integração
-- Rotina Criada: fkg_tipo_ret_imp_rec
--
-- Em 31/10/2018 - Karina de Paula
-- Redmine 47558 - Alterações na package pk_entr_cte_terceiro para atender INSS
-- Rotina Criada: fkg_tipo_ret_imp_rec_cd
--
-- Em 31/10/2018 - Angela Inês.
-- Redmine #48314 - Melhoria na função global que recupera o Identificador do Plano de Contas.
-- Alterar a função que recupera o Identificador do Plano de Contas, para considerar o código da conta enviado pelo parâmetro de entrada, no formato real, e caso
-- não seja encontrado, eliminar a máscara do código e fazer nova recuperação. Ainda não encontrando, será verificado se a empresa enviada pelo parâmetro de
-- entrada possui matriz, e neste caso, recuperar da mesma porém com a empresa matriz, recuperando primeiro, no formato real e em seguida sem a máscara.
-- Rotina: fkg_plano_conta_id.
--
-- Em 29/11/2018 - Eduardo Linden
-- Redmine #47653 - Inclusão de function para o parametro de validação de base icms : empresa.dm_forma_dem_base_icms
-- Função: fkg_empresa_dmformademb_icms 
--
-- Em 07/12/2018 - Karina de Paula
-- Redmine #48370 - Erro na integração do usuario.
-- Rotina Alterada: fkg_usuario_email_conf_erp e fkg_neo_usuario_id_conf_erp => Foi incluida essa nova verificacao em funcao do campo id_erp na integracao receber
-- o vlr do login. Nos casos de cadastro manual de usuario o campo id_erp pode ficar nulo, nao retornando o email ou o id do usuario
--
-- Em 09/01/2019 - Karina de Paula
-- Redmine #50344 - Processo para gerar os dados dos impostos originais
-- Rotina Criada: fkg_empresa_guarda_imporig e fkg_existe_nf_imp
--
-- Em 22/03/2019 - Angela Inês.
-- Redmine #52759 - Integração de Cadastro de Item - Empresa.
-- Considerar para Integração do ITEM, quando o ID do Item for NULO, a empresa enviada na View de Integração (vw_csf_item.cpf_cnpj), caso o ID do Item
-- for diferente de NULO, o processo irá validar da mesma que era antes, ou seja, considerando a empresa em questão e sua matriz.
-- Rotina: fkg_item_id.
--
-- Em 02/04/2019 - Karina de Paula
-- Redmine #52997 - feed - erro na integração do imposto
-- Rotina Criada: fkg_existe_imp_itemnf
--
-- Em 03/06/2019 - Marcos Ferreira
-- Redmine #55245: Criar função na pk_csf para retornar parametro geral
-- Alterações: Criação de nova função para buscar parametros gerais de sistema
-- Procedures Alteradas: fkg_ret_vl_param_geral_sistema, fkg_ret_idmodulo_sistema, fkg_ret_id_grupo_sistema
--
---------------------------------------------------------------------------------------------------------------------------------------------------------

--Função que retrona o id da tabela PARAM_OPER_FISCAL_ENTR, conforme sua UK.

function fkg_paramoperfiscalentr_id ( en_empresa_id         in number
                                    , en_cfop_id_orig       in number
                                    , ev_cnpj_orig          in varchar2
                                    , en_ncm_id_orig        in number
                                    , en_item_id_orig       in number
                                    , en_codst_id_icms_orig in number
                                    , en_codst_id_ipi_orig  in number )
return param_oper_fiscal_entr.id%type;

-------------------------------------------------------------------------------------------------------
--Função que retorna o id da tabela PARAM_ITEM_ENTR, conforme sua UK.

function fkg_paramitementr_id ( en_empresa_id     in number
                              , ev_cnpj_orig      in varchar2
                              , en_ncm_id_orig    in number
                              , ev_cod_item_orig  in varchar2
                              , en_item_id_dest   in number )
return param_item_entr.id%type;

-------------------------------------------------------------------------------------------------------
-- Função formata o valor na mascara deseja pelo usuário
function fkg_formata_num ( en_num in number
                         , ev_mascara in varchar2
                         )
         return varchar2;

----------------------------------------------------------------------------------------------------

--| Função retorno o valor do Parâmetro Global Formato Data do Sistema
function fkg_param_global_csf_form_data
         return param_global_csf.valor%type;

-------------------------------------------------------------------------------------------------------

-- Função retor do ID da Mult-Organização conforme código

function fkg_multorg_id ( ev_multorg_cd in mult_org.cd%type )
         return mult_org.id%type;

-------------------------------------------------------------------------------------------------------

-- Função verifica se o ID da Mult-Organização é valido

function fkg_valida_multorg_id ( en_multorg_id in mult_org.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna MULTORG_ID da Empresa

function fkg_multorg_id_empresa ( en_empresa_id in empresa.id%type )
         return mult_org.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da empresa Matriz
function fkg_empresa_id_matriz ( en_empresa_id  in empresa.id%type )
         return empresa.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Msg_WebServ
function fkg_Msg_WebServ_id ( en_cd  in Msg_WebServ.cd%TYPE )
         return Msg_WebServ.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o tipo de efeito da mensagem do webserv
function fkg_Efeito_Msg_WebServ ( en_msgwebserv_id  in Msg_WebServ.id%TYPE
                                , en_cd             in Msg_WebServ.cd%TYPE )
         return Msg_WebServ.dm_efeito%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tebale Mod_Fiscal
function fkg_Mod_Fiscal_id ( ev_cod_mod  in Mod_Fiscal.cod_mod%TYPE )
         return Mod_Fiscal.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Tipo_Servico
function fkg_Tipo_Servico_id ( ev_cod_lst  in Tipo_Servico.cod_lst%TYPE )
         return Tipo_Servico.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Classe_Enq_IPI
function fkg_Classe_Enq_IPI_id ( ev_cl_enq  in Classe_Enq_IPI.cl_enq%TYPE )
         return Classe_Enq_IPI.id%TYPE;

-------------------------------------------------------------------------------------------------------

--| Função retorna o CL_ENQ da tabela Classe_Enq_IPI conforme ID

function fkg_Classe_Enq_IPI_cd ( en_classeenqipi_id  in Classe_Enq_IPI.id%TYPE )
         return classe_enq_ipi.cl_enq%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Selo_Contr_IPI
function fkg_Selo_Contr_IPI_id ( ev_cod_selo_ipi  in Selo_Contr_IPI.cod_selo_ipi%TYPE )
         return Selo_Contr_IPI.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o CD da tabela Selo_Contr_IPI conforme ID

function fkg_Selo_Contr_IPI_cd ( en_selocontripi_id  in Selo_Contr_IPI.id%TYPE )
         return selo_contr_ipi.cod_selo_ipi%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Unidade
function fkg_Unidade_id ( en_multorg_id  in mult_org.id%type
                        , ev_sigla_unid  in Unidade.sigla_unid%TYPE
                        )
         return Unidade.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Tipo_Item
function fkg_Tipo_Item_id ( ev_cd  in Tipo_Item.cd%TYPE )
         return Tipo_Item.id%TYPE;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela Nat_Oper
function fkg_Nat_Oper_id ( en_multorg_id in mult_org.id%type
                         , ev_cod_nat    in Nat_Oper.cod_nat%TYPE )
         return Nat_Oper.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Orig_Proc
function fkg_Orig_Proc_id ( en_cd  in Orig_Proc.cd%TYPE )
         return Orig_Proc.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o CD da tabela Orig_Proc conforme ID
function fkg_Orig_Proc_cd ( en_origproc_id  in Orig_Proc.id%TYPE )
         return Orig_Proc.cd%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Sit_Docto
function fkg_Sit_Docto_id ( ev_cd  in Sit_Docto.cd%TYPE )
         return Sit_Docto.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o CD da tabela Sit_Docto
function fkg_Sit_Docto_cd ( en_sitdoc_id  in Sit_Docto.id%TYPE )
         return Sit_Docto.cd%TYPE;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela Infor_Comp_Dcto_Fiscal
function fkg_Infor_Comp_Dcto_Fiscal_id ( en_multorg_id in mult_org.id%type
                                       , en_cod_infor  in Infor_Comp_Dcto_Fiscal.cod_infor%TYPE )
         return Infor_Comp_Dcto_Fiscal.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Tipo_Imposto
function fkg_Tipo_Imposto_id ( en_cd  in Tipo_Imposto.cd%TYPE )
         return Tipo_Imposto.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Cod_ST
function fkg_Cod_ST_id ( ev_cod_st      in Cod_ST.cod_st%TYPE
                       , en_tipoimp_id  in Cod_ST.id%TYPE )
         return Cod_ST.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Aj_Obrig_Rec
function fkg_Aj_Obrig_Rec_id ( ev_cd          in Aj_Obrig_Rec.cd%TYPE
                             , en_tipoimp_id  in Aj_Obrig_Rec.id%TYPE )
         return Aj_Obrig_Rec.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Genero
function fkg_Genero_id ( ev_cod_gen  in Genero.cod_gen%TYPE )
         return Genero.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Ncm
function fkg_Ncm_id ( ev_cod_ncm  in Ncm.cod_ncm%TYPE )
         return Ncm.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela EX_TIPI
function fkg_ex_tipi_id ( ev_cod_ex_tipi  in EX_TIPI.cod_ex_tipi%TYPE
                        , en_ncm_id       in Ncm.id%TYPE )
         return EX_TIPI.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Código da tabela EX_TIPI

function fkg_ex_tipi_cod ( en_extipi_id  in ex_tipi.id%type )
         return ex_tipi.cod_ex_tipi%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Pais
function fkg_Pais_siscomex_id ( ev_cod_siscomex  in Pais.cod_siscomex%TYPE )
         return Pais.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Pais conforme sigla do pais
function fkg_Pais_sigla_id ( ev_sigla_pais  in Pais.sigla_pais%TYPE )
         return Pais.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Estado
function fkg_Estado_ibge_id ( ev_ibge_estado  in Estado.ibge_estado%TYPE )
         return Estado.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Cidade
function fkg_Cidade_ibge_id ( ev_ibge_cidade  in Cidade.ibge_cidade%TYPE )
         return Cidade.id%TYPE;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela Pessoa, conforme MultOrg_ID e CPF/CNPJ

function fkg_Pessoa_id_cpf_cnpj ( en_multorg_id  in mult_org.id%type
                                , en_cpf_cnpj    in varchar2 
                                )
         return Pessoa.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Empresa
function fkg_Empresa_id ( en_multorg_id  in mult_org.id%type
                        , ev_cod_matriz  in Empresa.cod_matriz%TYPE
                        , ev_cod_filial  in Empresa.cod_filial%TYPE 
                        )
         return Empresa.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna "true" se a NF existe e "false" se não existe
function fkg_existe_nf ( en_nota_fiscal  in Nota_Fiscal.id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna "true" se a UF for válida, e "false" se não for.
function fkg_uf_valida ( ev_sigla_estado  in Estado.Sigla_Estado%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna "true" se o IBGE do UF for válide e "false" se não for
function fkg_ibge_uf_valida ( ev_ibge_estado  in Estado.ibge_estado%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna "True" se o IBGE da cidade for válido e "false" se não for
function fkg_ibge_cidade ( ev_ibge_cidade  in Cidade.ibge_cidade%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna "true" se o código do pais for válido e "false" se não for
function fkg_codpais_siscomex_valido ( en_cod_siscomex  in Pais.cod_siscomex%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna a descrição do valor do domino
function fkg_dominio ( ev_dominio   in Dominio.dominio%TYPE
                     , ev_vl        in Dominio.vl%TYPE )
         return Dominio.descr%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna "true" se o ID da empresa for válido e "false" se não for
function fkg_empresa_id_valido ( en_empresa_id  in Empresa.id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Pessoa
function fkg_Pessoa_id_valido ( en_pessoa_id  in Pessoa.id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna a pessoa pelo MultOrg_ID e cod_part
function fkg_pessoa_id_cod_part ( en_multorg_id  in mult_org.id%type
                                , ev_cod_part    in Pessoa.cod_part%TYPE
                                )
         return Pessoa.id%TYPE;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da NAT_OPER pelo cod_nat
function fkg_natoper_id_cod_nat ( en_multorg_id in mult_org.id%type
                                , ev_cod_nat    in Nat_Oper.cod_nat%TYPE )
         return Nat_Oper.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o nome da empresa
function fkg_nome_empresa ( en_empresa_id  in Empresa.id%TYPE
                          )
         return Pessoa.nome%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna a data de emissão da nota fiscal
function fkg_dt_emiss_nf ( en_notafiscal_id in Nota_Fiscal.id%TYPE )
         return Nota_Fiscal.dt_emiss%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna "true" se o item_id é válido e "false" se não é
function fkg_item_id_valido ( en_item_id  in Item.id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna o DM_ST_PROC (Situação do Processo) da Nota Fiscal
function fkg_st_proc_nf ( en_notafiscal_id  in Nota_Fiscal.id%TYPE )
         return Nota_Fiscal.dm_st_proc%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna a Chave da Nota Fiscal
function fkg_chave_nf ( en_notafiscal_id   in  Nota_Fiscal.id%TYPE )
         return Nota_Fiscal.nro_chave_nfe%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna um número positivo aleatório na faixa de 1 a 999999999
function fkg_numero_aleatorio ( en_num in number
                              , en_ini in number
                              , en_fim in number )
         return number;

-------------------------------------------------------------------------------------------------------

-- Cálculo do dígito verificador com modulo 11
function fkg_mod_11 ( ev_codigo in varchar2 )
         return number;

-------------------------------------------------------------------------------------------------------

-- Função retorna o tipo de ambiente (Produção/Homologação) parametrizado para a empresa
function fkg_tp_amb_empresa ( en_empresa_id  in Empresa.id%TYPE )
         return Empresa.dm_tp_amb%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Tipo de impressão (Retrato/Paisagem) parametrizado na empresa
function fkg_tp_impr_empresa ( en_empresa_id  in Empresa.id%TYPE )
         return Empresa.dm_tp_impr%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Tipo de impressão (Retrato/Paisagem) parametrizado na empresa
function fkg_forma_emiss_empresa ( en_empresa_id  in Empresa.id%TYPE )
         return Empresa.dm_forma_emiss%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da nota Fiscal a partir do número da chave de acesso
function fkg_notafiscal_id_pela_chave ( en_nro_chave_nfe  in Nota_Fiscal.nro_chave_nfe%TYPE )
         return Nota_Fiscal.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do Lote conforme o número do recibo de envio fornecido pelo SEFAZ
function fkg_Lote_id_pelo_nro_recibo ( en_nro_recibo in Lote.nro_recibo%TYPE )
         return Lote.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do Cfop
function fkg_cfop_id ( en_cd  in Cfop.cd%TYPE )
         return Cfop.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna a inscrição estadual da empresa
function fkg_inscr_est_empresa ( en_empresa_id  in Empresa.id%TYPE )
         return Juridica.ie%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna "1" se a nota fiscal está inutilizada e "0" se não está
function fkg_nf_inutiliza ( en_empresa_id  in Empresa.id%TYPE
                          , ev_cod_mod     in Mod_Fiscal.cod_mod%TYPE
                          , en_serie       in Nota_Fiscal.serie%TYPE
                          , en_nro_nf      in Nota_Fiscal.nro_nf%TYPE
                          )
         return number;

-------------------------------------------------------------------------------------------------------

-- Função retorna se 1 se o Estado Obrigado o CODIF e 0 se não Obriga
function fkg_Estado_Obrig_Codif ( ev_sigla_estado  in Estado.sigla_estado%TYPE )
         return Estado.dm_obrig_codif%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do estado conforme a sigla de UF
function fkg_Estado_id ( ev_sigla_estado  in Estado.sigla_estado%TYPE )
         return Estado.id%TYPE;

-------------------------------------------------------------------------------------------------------

FUNCTION fkg_converte ( ev_string            IN varchar2
                      , en_espacamento       IN number DEFAULT 0
                      , en_remove_spc_extra  IN number DEFAULT 1
                      , en_ret_carac_espec   IN number DEFAULT 1
                      , en_ret_tecla         in number default 1 -- retira comandos CHR
                      , en_ret_underline     in number default 1 -- retira underline: 1 - sim, 0 - não
                      , en_ret_chr10         in number default 1 -- retira comandos CHR10 se a string original não vier com o caractere "\n"
                       )
         RETURN VARCHAR2;

-------------------------------------------------------------------------------------------------------

-- Função retorna uma String com as informações de Duplicatas
function fkg_String_dupl ( en_notafiscal_id  in Nota_Fiscal.id%TYPE
                         , en_monta_nro_fat  in number default 0 )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da Nota Fiscal conforme Empresa, Número, modelo, serie e tipo (entrada/saída)
function fkg_busca_notafiscal_id ( en_multorg_id       in mult_org.id%type
                                 , en_empresa_id       in Empresa.id%TYPE
                                 , ev_cod_mod          in Mod_Fiscal.cod_mod%TYPE
                                 , ev_serie            in Nota_Fiscal.serie%TYPE
                                 , en_nro_nf           in Nota_Fiscal.nro_nf%TYPE
                                 , en_dm_ind_oper      in Nota_Fiscal.dm_ind_oper%TYPE
                                 , en_dm_ind_emit      in Nota_Fiscal.dm_ind_emit%TYPE
                                 , ev_cod_part         in Pessoa.cod_part%TYPE
                                 , en_dm_arm_nfe_terc  in nota_fiscal.dm_arm_nfe_terc%type default 0
                                 , ed_dt_emiss         in nota_fiscal.dt_emiss%type default null
                                 )
         return Nota_Fiscal.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o campo EMPRESA_ID conforme o CPF ou CNPJ
function fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id  in mult_org.id%type
                                      , ev_cpf_cnpj    in varchar2
                                      )
         return Empresa.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o campo EMPRESA_ID conforme a multorg_id e Incrição Estadual
function fkg_empresa_id_pelo_ie ( en_multorg_id  in mult_org.id%type
                                , ev_ie          in juridica.ie%type
                                )
         return Empresa.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da empresa, pelo CNPJ ou pelo Cód. Matriz e Filial
function fkg_empresa_id2 ( en_multorg_id        in             mult_org.id%type
                         , ev_cod_matriz        in  Empresa.cod_matriz%TYPE  default null
                         , ev_cod_filial        in  Empresa.cod_filial%TYPE  default null
                         , ev_empresa_cpf_cnpj  in  varchar2                 default null -- CPF/CNPJ da empresa
                         )
         return empresa.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Procedimento responsável por retornar informações da Nota Fiscal
procedure pkb_inform_nf ( en_notafiscal_id       in  Nota_Fiscal.id%TYPE
                        , sn_lote_id             out Nota_Fiscal.lote_id%TYPE
                        , sv_cd_sitdocto         out Sit_Docto.cd%TYPE
                        , sn_nro_nf              out Nota_Fiscal.nro_nf%TYPE
                        , sv_serie               out Nota_Fiscal.serie%TYPE
                        , sn_dm_st_proc          out Nota_Fiscal.dm_st_proc%TYPE
                        , sd_dt_st_proc          out Nota_Fiscal.dt_st_proc%TYPE
                        , sn_dm_forma_emiss      out Nota_Fiscal.dm_forma_emiss%TYPE
                        , sn_dm_impressa         out Nota_Fiscal.dm_impressa%TYPE
                        , sn_dm_st_email         out Nota_Fiscal.dm_st_email%TYPE
                        , sn_dm_tp_amb           out Nota_Fiscal.dm_tp_amb%TYPE
                        , sd_dt_aut_sefaz        out Nota_Fiscal.dt_aut_sefaz%TYPE
                        , sn_dm_aut_sefaz        out Nota_Fiscal.dm_aut_sefaz%TYPE
                        , sv_nro_chave_nfe       out Nota_Fiscal.nro_chave_nfe%TYPE
                        , sn_cNF_nfe             out Nota_Fiscal.cNF_nfe%TYPE
                        , sn_dig_verif_chave     out Nota_Fiscal.dig_verif_chave%TYPE
                        , sn_nro_protocolo       out Nota_Fiscal.nro_protocolo%TYPE
                        , sn_nro_protocolo_canc  out Nota_Fiscal_Canc.nro_protocolo%TYPE
                        , sd_dt_canc             out Nota_Fiscal_Canc.dt_canc%TYPE
                        );

-------------------------------------------------------------------------------------------------------

-- Função retorna a Sigla do Tipo de Imposto
function fkg_Tipo_Imposto_Sigla ( en_cd  in Tipo_Imposto.cd%TYPE )
         return Tipo_Imposto.Sigla%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o COD_PART pelo ID da pessoa
function fkg_pessoa_cod_part ( en_pessoa_id in pessoa.id%type )
         return pessoa.cod_part%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Contador conforme en_multorg_id e COD_PART
function fkg_contador_id ( en_multorg_id  in mult_org.id%type
                         , ev_cod_part    in pessoa.cod_part%type
                         )
         return contador.id%type;

-------------------------------------------------------------------------------------------------------

-- Retorna o ID do usuário do Sistema conforme multorg_id e ID_ERP
function fkg_neo_usuario_id_conf_erp ( en_multorg_id  in mult_org.id%type
                                     , ev_id_erp      in neo_usuario.id_erp%type
                                     )
         return neo_usuario.id%type;

-------------------------------------------------------------------------------------------------------

-- Retorna o ID da impressora vinculada a série (EMPRESA_PARAM_SERIE)
procedure pkb_impressora_id_serie ( en_empresa_id    in  Empresa.id%TYPE
                                 , en_modfiscal_id  in  Mod_Fiscal.Id%TYPE
                                 , ev_serie         in  Nota_Fiscal.serie%TYPE
                                 , en_nfusuario_id  in  nota_fiscal.usuario_id%type
                                 , sn_impressora_id out nota_fiscal.impressora_id%type
                                 , sn_qtd_impr      out nota_fiscal.vias_danfe_custom%type);
-------------------------------------------------------------------------------------------------------

-- Retorna o ID da impressora vinculada ao usuário
function fkg_impressora_id_usuario ( en_usuario_id in neo_usuario.id%type )
         return impressora.id%type;

-------------------------------------------------------------------------------------------------------

-- Retorna o ID da impressora vincutada a empresa
function fkg_impressora_id_empresa ( en_empresa_id in empresa.id%type )
         return impressora.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna "true" se for uma NFe de emissão própria já autorizada, cancelada, denegada ou inutulizada, não pode ser re-integrada
function fkg_nfe_nao_integrar ( en_notafiscal_id  in nota_fiscal.id%Type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela CSF_TIPO_LOG conforme o identificador TIPO_LOG
function fkg_csf_tipo_log_id ( en_tipo_log in csf_tipo_log.cd_compat%type )
         return csf_tipo_log.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna um valor criptografado em MD5
function fkg_md5 ( ev_valor in varchar2 )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna o CNPJ ou CPF conforme a empresa
function fkg_cnpj_ou_cpf_empresa ( en_empresa_id in Empresa.Id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna o CNAE conforme a empresa
function fkb_retorna_cnae ( en_empresa_id in empresa.id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do usuário
function fkg_usuario_id ( ev_login in neo_usuario.login%type)
         return neo_usuario.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna TRUE se a pessoa existe e FALSE se ela não existe, conforme o ID
function fkg_existe_pessoa ( en_pessoa_id in pessoa.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna "true" se o código do pais for válido e "false" se não for, conforme ID
function fkg_pais_id_valido ( en_pais_id  in Pais.id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da cidade conforme o código do IBGE
function fkg_cidade_id_ibge ( ev_ibge_cidade in cidade.ibge_cidade%type )
         return cidade.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o IBGE da cidade conforme o ID
function fkg_ibge_cidade_id ( en_cidade_id  in Cidade.id%TYPE )
         return cidade.ibge_cidade%type;

-------------------------------------------------------------------------------------------------------

-- Retorna o códido do siscomex conforme o id do país
function fkg_cod_siscomex_pais_id ( en_pais_id  in Pais.id%TYPE )
         return pais.cod_siscomex%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna TRUE se a unidade existe e FALSE se não existe, conforme o ID
function fkg_existe_unidade_id ( en_unidade_id in unidade.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorno o CD do tipo de item conforme o ID
function fkg_cd_tipo_item_id ( en_tipoitem_id in tipo_item.id%type )
         return tipo_item.cd%type;

-------------------------------------------------------------------------------------------------------

-- Função Retorna o Código da ANP do produto
function fkg_cod_anp_valido ( ev_cod_anp in cod_anp.cd%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da Coversão de Unidade conforme Item e Unidade
function fkg_id_conv_unid ( en_item_id     in item.id%type
                          , ev_unidade_id  in unidade.id%type )
         return conversao_unidade.id%Type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do bem do ativo imobilizado conforme empresa e código do item
function fkg_id_bem_ativo_imob ( en_empresa_id   in empresa.id%type
                               , ev_cod_ind_bem  in bem_ativo_imob.cod_ind_bem%type )
         return bem_ativo_imob.id%type;

-------------------------------------------------------------------------------------------------------

-- Função returna TRUE se existe o bem ID ou FALSE se não existe, conforme o ID
function fkg_existe_bem_ativo_imob ( en_bemativoimob_id in bem_ativo_imob.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da Utilização do Bem conforme Bem, Conta Contábil e Centro de Custo
function fkg_id_infor_util_bem ( en_bemativoimob_id in bem_ativo_imob.id%type
                               , ev_cod_ccus        in infor_util_bem.cod_ccus%type )
         return infor_util_bem.id%type;

-------------------------------------------------------------------------------------------------------

-- Função verifica se existe o ID da Informação Complementar do Documento Fiscal
function fkg_existe_Inf_Comp_Dcto_Fis ( en_infcompdctofis_id in infor_comp_dcto_fiscal.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função Retorna o ID da Observação do Lançamento Fiscal
function fkg_id_obs_lancto_fiscal ( en_multorg_id in mult_org.id%type
                                  , ev_cod_obs in obs_lancto_fiscal.cod_obs%type )
         return obs_lancto_fiscal.id%type;

-------------------------------------------------------------------------------------------------------

-- Função verifica se existe da Observação do Lançamento Fiscal
function fkg_existe_obs_lancto_fiscal ( en_obslanctofiscal_id in obs_lancto_fiscal.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do inventário
function fkg_inventario_id ( en_empresa_id     in empresa.id%type
                           , en_item_id        in item.id%type
                           , en_unidade_id     in unidade.id%type
                           , ed_dt_inventario  in inventario.dt_inventario%type
                           , en_dm_ind_prop    in inventario.dm_ind_prop%type
                           , en_pessoa_id      in pessoa.id%type
                           )
         return inventario.id%type;

-------------------------------------------------------------------------------------------------------

-- Função verifica se existe o ID do inventário
function fkg_existe_inventario ( en_inventario_id in inventario.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do inventário
function fkg_inventario_info_compl_id ( en_empresa_id     in empresa.id%type
                                      , en_item_id        in item.id%type
                                      , ed_dt_inventario  in inventario.dt_inventario%type
                                      )
         return inventario.id%type;
-------------------------------------------------------------------------------------------------------

-- Função verifica se existe o ID do inventário
function fkg_existe_invent_cst ( en_invent_cst_id in invent_cst.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

function fkg_invent_cst_id ( en_inventario_id  in inventario.id%type
                           , en_codst_id       in cod_st.id%type
                           )
         return invent_cst.id%type;
-------------------------------------------------------------------------------------------------------

-- Conforme o ID da Pessoa Retorna o Nome
function fkg_nome_pessoa_id ( en_pessoa_id  in pessoa.id%type )
         return pessoa.nome%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da Unidade Organizacional conforme EMPRESA_ID e código UO
function fkg_unig_org_id ( en_empresa_id    in  empresa.id%type
                         , ev_cod_unid_org  in  unid_org.cd%type )
         return unid_org.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do Sistema de Origem conforme a Sigla
function fkg_unig_org_cd ( en_unidorg_id    in  unid_org.id%type )
         return unid_org.cd%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do Sistema de Origem conforme a Sigla
function fkg_sist_orig_id ( en_multorg_id in  sist_orig.multorg_id%type
                          , ev_sigla      in  sist_orig.sigla%type )
         return sist_orig.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Sigla do Sistema de Origem conforme o ID
function fkg_sist_orig_sigla ( en_sistorig_id  in  sist_orig.id%type )
         return sist_orig.sigla%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o parâmetro de impressa automática 0-Não ou 1-Sim, conforme ID da empresa
function fkg_empresa_impr_aut ( en_empresa_id  in  empresa.id%type )
         return empresa.dm_impr_aut%type;

-------------------------------------------------------------------------------------------------------

-- Retorna true se a IBGE_UF for o mesmo da empresa, e false se não for
function fkg_uf_ibge_igual_empresa ( en_empresa_id   in  empresa.id%type
                                   , ev_ibge_estado  in  estado.ibge_estado%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Verifica se o código do IBGE do estado corresponde a sigla do estado
function fkg_compara_ibge_com_sigla_uf ( ev_ibge_estado   in  estado.ibge_estado%type
                                       , ev_sigla_estado  in  estado.sigla_estado%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna a sigla do estado conforme o ID
function fkg_Estado_id_sigla ( en_estado_id in estado.id%type )
         return estado.sigla_estado%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna "true" se o valor é númerico ou "false" se não é
function fkg_is_numerico ( ev_valor in varchar2 )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna "true" se for uma CTe de emissão própria já autorizada, cancelada, denegada ou inutulizada, não pode ser re-integrada
function fkg_cte_nao_integrar ( en_conhectransp_id in Conhec_Transp.id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna a Sigla do Tipo de Imposto através do Id - cte
function fkg_Tipo_Imp_Sigla ( en_id  in Tipo_Imposto.id%TYPE )
         return Tipo_Imposto.Sigla%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Código da tabela Cod_ST através do ID
function fkg_Cod_ST_cod ( en_id_st in Cod_ST.id%TYPE )
         return Cod_ST.cod_st%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função valida o formato da hora, passa o hora e o formato
function fkg_vld_formato_hora ( ev_hora     in varchar2
                              , ev_formato  in varchar2 )
                              return varchar2;

-------------------------------------------------------------------------------------------------------


-- Função retorna o DM_ST_PROC (Situação do Processo) do Conhecimento de Transporte
function fkg_st_proc_ct ( en_conhectransp_id  in Conhec_Transp.id%TYPE )
         return Conhec_Transp.dm_st_proc%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna "1" se o conhecimento de transporte está inutilizado e "0" se não está
function fkg_ct_inutiliza ( en_empresa_id  in Empresa.id%TYPE
                          , ev_cod_mod     in Mod_Fiscal.cod_mod%TYPE
                          , en_serie       in Conhec_Transp.serie%TYPE
                          , en_nro_ct      in Conhec_Transp.nro_ct%TYPE
                          )
         return number;

-------------------------------------------------------------------------------------------------------

-- Função retorna a Chave do Conhecimento de Transporte
function fkg_chave_ct ( en_conhectransp_id   in  Conhec_Transp.id%TYPE )
         return Conhec_Transp.nro_chave_cte%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna "true" se a CT-e existe e "false" se não existe
function fkg_existe_cte ( en_conhec_transp  in Conhec_Transp.id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do Conhec. de Transp. a partir do número da chave de acesso
function fkg_conhectransp_id_pela_chave ( en_nro_chave_cte  in Conhec_Transp.nro_chave_cte%TYPE )
         return Conhec_Transp.id%TYPE;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela Item, conforme ID Empresa, para Integração do Item por Open Interface
function fkg_item_id ( en_empresa_id in empresa.id%type
                     , ev_cod_item   in item.cod_item%type )
         return item.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Item, conforme ID Empresa
function fkg_Item_id_conf_empr ( en_empresa_id  in  empresa.id%type
                               , ev_cod_item    in  Item.cod_item%TYPE )
         return Item.id%TYPE;

------------------------------------------------------------------------------------------------------

-- Função retorna o Tipo do CT-e conforme o Id do CT-e.
-- Onde: 0 - CT-e Normal;
--       1 - CT-e de Complemento de Valores;
--       2 - CT-e de Anulação de Valores;
--       3 - CT-e Substituto
function fkg_dm_tp_cte ( en_conhectransp_id  in  Conhec_Transp.Id%TYPE )
         return Conhec_Transp.dm_tp_cte%TYPE;

------------------------------------------------------------------------------------------------------

-- Função retorna a data de emissão do conhecimento de transporte
function fkg_dt_emiss_ct ( en_conhectransp_id in Conhec_Transp.id%TYPE )
         return Conhec_Transp.dt_hr_emissao%TYPE;

------------------------------------------------------------------------------------------------------

-- Função retorna o valor de prestação do serviço através do ID do conhecimento de transporte
function fkg_vl_valor_prest_ct ( en_conhectransp_id in Conhec_Transp.id%TYPE )
         return Conhec_Transp_Vlprest.vl_prest_serv%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o valor de ICMS através do ID do conhecimento de transporte
function fkg_vl_imp_trib_ct ( en_conhectransp_id in Conhec_Transp.id%TYPE )
         return Conhec_Transp_Imp.vl_imp_trib%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna true se o Ct-e a ser Anulado ou Substituido já foi anulado ou substtuido anteriormente.
function fkg_val_ref_anul ( en_conhectransp_id    in Conhec_Transp.id%TYPE
                          , ev_nro_chave_cte_anul in conhec_transp_anul.nro_chave_cte_anul%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

function fkg_dmformaemiss_pelo_id ( en_conhectransp_id  in Conhec_Transp.id%TYPE )
         return Conhec_Transp.dm_forma_emiss%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna true se o Ct-e a ser Substituido já foi substtuido anteriormente.
function fkg_val_ref_cte_sub ( en_conhectransp_id   in Conhec_Transp.id%TYPE
                             , ev_nro_chave_cte_sub in Conhec_Transp_Subst.nro_chave_cte_sub%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna CNPJ do Remente/Destinatário/Expedidor/recebedor/tomador através do Id do Conhecimento de Transporte
-- E parametro vv_pessoa onde assumir: R - Remetente, D- Destinarario, E - Expedidor, RC - Recebedor, T - Tomador, EM - Emitente
function fkg_cnpj_pelo_id ( en_conhectransp_id  in Conhec_Transp.id%TYPE
                          , vv_pessoa              varchar2 )
         return conhec_transp_rem.cnpj%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna IE do Remente/Destinatário/Expedidor/recebedor/tomador através do Id do Conhecimento de Transporte
-- E parametro vv_pessoa onde assumir: R - Remetente, D- Destinarario, E - Expedidor, RC - Recebedor, T - Tomador, EM - Emitente
function fkg_ie_pelo_id ( en_conhectransp_id  in Conhec_Transp.id%TYPE
                        , vv_pessoa varchar2 )
         return conhec_transp_rem.cnpj%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna UF de Início da Prestação do Ct-e através do Id do Conhecimento de Transporte
function fkg_siglaufini_pelo_id ( en_conhectransp_id  in Conhec_Transp.id%TYPE )
         return conhec_transp.sigla_uf_ini%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna UF de Final da Prestação do Ct-e através do Id do Conhecimento de Transporte
function fkg_siglauffim_pelo_id ( en_conhectransp_id  in Conhec_Transp.id%TYPE )
         return conhec_transp.sigla_uf_fim%TYPE;

-------------------------------------------------------------------------------------------------------

-- Se foi informado o Ct-e de Anulação no grupo "Tomador não é contribuinte de do ICMS", o Ct-e de anulação deve existir.
-- A função retorna True se existir e False se não existir
function fkg_val_ref_cte_anul ( en_conhectransp_id    in Conhec_Transp.id%TYPE
                              , ev_nro_chave_cte_anul in Conhec_Transp_Anul.nro_chave_cte_anul%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Cód. IBGE do Estado conformer a sigla do Estado.
function fkg_Estado_ibge_sigla ( ev_sigla_estado  in Estado.sigla_estado%TYPE )
         return Estado.ibge_estado%TYPE;

-------------------------------------------------------------------------------------------------------

-- Verifica se a empresa Utiliza Endereço de Faturamento do destinatário na emissão da NFe
function fkg_empresa_util_end_fat_nfe ( en_empresa_id  in empresa.id%type )
         return empresa.dm_util_end_fat_nfe%type;

-------------------------------------------------------------------------------------------------------

-- Verifica se a empresa imprime o endereço de entrega na DANFE
function fkg_empresa_impr_end_entr_nfe ( en_empresa_id  in empresa.id%type )
         return empresa.dm_impr_end_entr_nfe%type;
         
-------------------------------------------------------------------------------------------------------

--| Verifica se a empresa imprime o endereço de Retirada na DANFE
function fkg_empresa_impr_end_retir_nfe ( en_empresa_id  in empresa.id%type )
         return empresa.dm_impr_end_entr_nfe%type;

-------------------------------------------------------------------------------------------------------

-- Verifica se a empresa valida a unidade de médida
function fkg_empresa_valid_unid_med ( en_empresa_id  in empresa.id%type )
         return empresa.dm_valid_unid_med%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento que acetar conforme o máximo ID de cada tabela

procedure pkb_acerta_sequence;

-------------------------------------------------------------------------------------------------------

-- Função retorna 0 Se a empresa Não valida totais da Nota Fiscal
-- ou 1 Se e empresa valida totais da Nota Fiscal
function fkg_valid_total_nfe_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_valid_total_nfe%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna a sitação da empresa: 0-Inativa ou 1-Ativa
function fkg_empresa_id_situacao ( en_empresa_id  in empresa.id%type )
         return empresa.dm_situacao%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna a sitação da empresa: 0-Inativa ou 1-Ativa
function fkg_empresa_id_certificado_ok ( en_empresa_id  in empresa.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

--| Função retorna o tipo de inclusão da pessoa
function fkg_pessoa_id_dm_tipo_incl ( en_pessoa_id  in pessoa.id%type )
         return pessoa.dm_tipo_incl%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna "true" se o Código do IBGE da cidade pertente ao estado
-- e "false" se estiver incorreto
function fkg_ibge_cidade_por_sigla_uf ( en_ibge_cidade   in  cidade.ibge_cidade%type
                                      , ev_sigla_estado  in  estado.sigla_estado%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna a Versão válida do WSDL da NFE
function fkg_versaowsdl_nfe_estado ( en_estado_id in estado.id%type )
         return versao_wsdl.cd%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Tipo Modal através do ID do Ct-e
-- Onde: 01-Rodoviário;
-- 02-Aéreo;
-- 03-Aquaviário;
-- 04-Ferroviário;
-- 05-Dutoviário
function fkg_dm_modal ( en_conhectransp_id   in   Conhec_Transp.Id%TYPE )
         return Conhec_Transp.dm_modal%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna True se existir informações referente a produtos perigosos.
function fkg_valid_prod_peri ( en_conhectransp_id   in   Conhec_Transp.Id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna a quantidade de registros de lacres aquaviários por CT-e Aquaviário
function fkg_valid_lacre_aquav ( en_conhectranspaquav_id   in   conhec_transp_aquav.id%TYPE )
         return number;

-------------------------------------------------------------------------------------------------------

-- Função retorna a quantidade de registros de Ordens de Coleta associados ao CT-e Rodoviário
function fkg_valid_ctrodo_occ ( en_conhectransprodo_id in ctrodo_occ.conhectransprodo_id%TYPE )
         return number;

-------------------------------------------------------------------------------------------------------

-- Função retorna a quantidade de registros de Dados dos Veículos ao CT-e Rodoviário
function fkg_valid_ctrodo_veic ( en_conhectransprodo_id in ctrodo_occ.conhectransprodo_id%TYPE )
         return number;

-------------------------------------------------------------------------------------------------------

-- Função retorna a quantidade de registros de vale pedágio ao CT-e Rodoviário
function fkg_valid_ctrodo_valeped ( en_conhectransprodo_id in ctrodo_occ.conhectransprodo_id%TYPE )
         return number;

-------------------------------------------------------------------------------------------------------

-- Função retorna True se existir informações sobre os veículos e False caso não houver.
function fkg_valid_ctrodo_veic_prop ( en_ctrodoveic_id in ctrodo_veic_prop.ctrodoveic_id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna True se existir informações no Grupo Informações do(s) Motorista(s)
function fkg_valid_ctrodo_moto ( en_conhectransprodo_id in ctrodo_moto.conhectransprodo_id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna o tipo de serviço do conhecimento de transporte
-- Onde: 0 - Normal; 1 - Subcontratação; 2 - Redespacho; 3 - Redespacho Intermediario
function fkg_dm_tp_serv ( en_conhectransp_id in Conhec_Transp.id%TYPE )
         return Conhec_Transp.dm_tp_serv%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela registro_in86
function fkg_registroin86_id ( en_cd  in Registro_In86.cod%TYPE )
         return Registro_In86.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna cod_mod_ref através do dm_tp_cte e ID do CTE
function fkg_ct_ref_moddoc ( en_conhectransp_id  in Conhec_Transp.id%TYPE
                           , en_dm_tp_cte        in Conhec_Transp.dm_tp_cte%TYPE)
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna serie_ref através do dm_tp_cte e ID do CTE
function fkg_ct_ref_serie ( en_conhectransp_id  in Conhec_Transp.id%TYPE
                          , en_dm_tp_cte        in Conhec_Transp.dm_tp_cte%TYPE)
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna num_doc_ref, através do dm_tp_cte e ID do CTE
function fkg_ct_ref_nro_nf ( en_conhectransp_id  in Conhec_Transp.id%TYPE
                           , en_dm_tp_cte        in Conhec_Transp.dm_tp_cte%TYPE)
         return number;

-------------------------------------------------------------------------------------------------------

-- Função retorna dt_doc_ref através do dm_tp_cte e ID do CTE
function fkg_ct_ref_dtdoc ( en_conhectransp_id  in Conhec_Transp.id%TYPE
                          , en_dm_tp_cte        in Conhec_Transp.dm_tp_cte%TYPE)
         return date;

-------------------------------------------------------------------------------------------------------

-- Função retorna cod_part_ref através do dm_tp_cte e ID do CTE
function fkg_ct_ref_codpart ( en_conhectransp_id  in Conhec_Transp.id%TYPE
                            , en_dm_tp_cte        in Conhec_Transp.dm_tp_cte%TYPE)
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Procedimento retornar dados do CTe referenciado, por meio de variáveis "out"
procedure pkb_dados_ct_ref ( en_conhectransp_id  in   Conhec_Transp.id%TYPE
                           , en_dm_tp_cte        in   Conhec_Transp.dm_tp_cte%TYPE
                           , sv_cod_mod_ref      out  mod_fiscal.cod_mod%type
                           , sv_serie            out  conhec_transp.serie%type
                           , sn_nro_ct           out  conhec_transp.nro_ct%type
                           , sd_dt_hr_emissao    out  conhec_transp.dt_hr_emissao%type
                           , sv_cod_part         out  pessoa.cod_part%type
                           );

-------------------------------------------------------------------------------------------------------

-- Função para formatar campos varchar2
-- Onde: ev_campo é o contéudo que será formatado
--       en_qtdecasa é a quantidade de casas
--       ev_caracter o tipo de caracte
--       ev_lado é o lado utilizar 'D'para direita e 'E' para esquerda
function fkg_formatachar ( ev_campo    in varchar2
                         , ev_caracter in varchar2
                         , en_qtdecasa in number
                         , ev_lado     in varchar2 )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Procedimento para retornar valores de Impostos na tabela IMP_NOTA_FISCAL
procedure pkb_impostonf ( en_itemnf_id             in  item_nota_fiscal.id%type
                        , en_cod_tpimp             in  tipo_imposto.cd%type
                        , en_dm_tipo               in  imp_itemnf.dm_tipo%type
                        , sv_cod_st                out cod_st.cod_st%type
                        , sn_vl_base_calc          out imp_itemnf.vl_base_calc%type
                        , sn_aliq_apli             out imp_itemnf.aliq_apli%type
                        , sn_vl_imp_trib           out imp_itemnf.vl_imp_trib%type
                        , sn_perc_reduc            out imp_itemnf.perc_reduc%type
                        , sn_perc_adic             out imp_itemnf.perc_adic%type
                        , sn_qtde_base_calc_prod   out imp_itemnf.qtde_base_calc_prod%type
                        , sn_vl_aliq_prod          out imp_itemnf.vl_aliq_prod%type
                        , sn_vl_bc_st_ret          out imp_itemnf.vl_bc_st_ret%type
                        , sn_vl_icmsst_ret         out imp_itemnf.vl_icmsst_ret%type
                        , sn_perc_bc_oper_prop     out imp_itemnf.perc_bc_oper_prop%type
                        , sv_sigla_estado          out estado.sigla_estado%type
                        , sn_vl_bc_st_dest         out imp_itemnf.vl_bc_st_dest%type
                        , sn_vl_icmsst_dest        out imp_itemnf.vl_icmsst_dest%type
                        );

-------------------------------------------------------------------------------------------------------

-- Procedimento para retornar valores de Impostos na tabela CONHEC_TRANSP_IMP
procedure pkb_impostoct ( en_conhectransp_id  in  conhec_transp.id%TYPE
                        , en_cod_tpimp        in  tipo_imposto.cd%type
                        , sv_cod_st           out cod_st.cod_st%type
                        , sn_vl_base_calc     out conhec_transp_imp.vl_base_calc%type
                        , sn_aliq_apli        out conhec_transp_imp.aliq_apli%type
                        , sn_vl_imp_trib      out conhec_transp_imp.vl_imp_trib%type
                        , sn_perc_reduc       out conhec_transp_imp.perc_reduc%type
                        , sn_vl_cred          out conhec_transp_imp.vl_cred%type
                        , sn_dm_inf_imp       out conhec_transp_imp.dm_inf_imp%type
                        );

-------------------------------------------------------------------------------------------------------

-- Função retorna DM_TIPO_PESSOA da tabela pessoa através do ID pessoa
function fkg_pessoa_dmtipo_id ( en_pessoa_id  in Pessoa.id%TYPE )
         return Pessoa.dm_tipo_pessoa%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o IE Subst. conforme o ID da pessoa
function fkg_iest_pessoa_id ( en_pessoa_id in Pessoa.Id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna o cod_participante pelo id_empresa
-- Função retorna o código da empresa através do id empresa em que está relacionado.
function fkg_codpart_empresaid ( en_empresa_id in Empresa.Id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Cod da tabale Mod_Fiscal
function fkg_cod_mod_id ( en_modfiscal_id  in Mod_Fiscal.id%TYPE )
         return Mod_Fiscal.cod_mod%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna cod_nat pelo ID da NAT_oper
function fkg_cod_nat_id ( en_natoper_id  in Nat_Oper.id%TYPE )
         return Nat_Oper.cod_nat%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o cod_ncm através do ID NCM
function fkg_cod_ncm_id ( en_ncm_id  in Ncm.id%TYPE )
         return Ncm.cod_ncm%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Cod do Serviço através do ID da tabela Tipo_Servico
function fkg_Tipo_Servico_cod ( en_tpservico_id  in Tipo_Servico.id%TYPE )
         return Tipo_Servico.cod_lst%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o tpservico_id através relacionado a tabela item através do código do item
function fkg_Item_tpservico_conf_empr ( en_empresa_id  in  empresa.id%type
                                      , ev_cod_item    in  Item.cod_item%TYPE )
         return Item.tpservico_id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna a Desc do Serviço através do ID da tabela Tipo_Servico
function fkg_Tipo_Servico_desc ( en_tpservico_id  in Tipo_Servico.id%TYPE )
         return Tipo_Servico.descr%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna a Data de Inclusão da tabela alter_pessoa através do Pessoa_id
function fkg_dt_alt_pessoa_id ( en_pessoa_id  in Pessoa.id%TYPE
                              , ed_data       in date )
         return alter_pessoa.dt_alt%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna a Data de Inclusão da tabela alter_item através do item_id
function fkg_dt_alt_item_id ( en_item_id  in Item.id%TYPE
                            , ed_data     in date )
         return alter_item.dt_ini%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o código da versão da In que será exportada. Através do ID  disponibilizado na abertura_in86
function fkg_cod_in86_id ( en_versaoin86_id  in versao_in86.id%TYPE)
         return versao_in86.cd%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o CNPJ ou CPF conforme o ID da pessoa
function fkg_cnpjcpf_pessoa_id ( en_pessoa_id in Pessoa.Id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna o sigla_estado que está relacionado ao pessoa_id
function fkg_siglaestado_pessoaid ( en_pessoa_id in Pessoa.Id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Inscrição Estadual conforme o ID da pessoa
function fkg_ie_pessoa_id ( en_pessoa_id in Pessoa.Id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retornar o valor do campo DM_PERM_EXP ID do País.
function fkg_perm_exp_pais_id  ( en_pais_id in pais.id%type )
         return pais.dm_perm_exp%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna se uma view está configurada para ser utilizada em nosso sistema.
-- 0 - Não e 1 - Sim
function fkg_existe_obj_util_integr ( ev_obj_name  in Obj_Util_Integr.obj_name%TYPE )
         return obj_util_integr.dm_ativo%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna 0 Se a empresa Não valida totais entre as duplicatas, cobraçãs e total da Nota Fiscal
-- ou 1 Se e empresa valida totais entre as duplicatas, cobraçãs e total da Nota Fiscal
function fkg_valid_cobr_nf_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_valid_cobr_nf%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o id da empresa através do ID da Nota Fiscal
function fkg_busca_empresa_nf ( en_notafiscal_id in Nota_Fiscal.id%type )
         return Empresa.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o id_erp do usuário através do ID do usuário
function fkg_id_erp_usuario_id ( en_usuario_id in neo_usuario.id%type )
         return neo_usuario.id_erp%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Plano de Conta
function fkg_Plano_Conta_id ( ev_cod_cta    in Plano_Conta.cod_cta%TYPE
                            , en_empresa_id in Plano_Conta.empresa_id%TYPE)
         return Plano_Conta.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Centro de Custo
function fkg_Centro_Custo_id ( ev_cod_ccus   in Centro_Custo.cod_ccus%TYPE
                             , en_empresa_id in Centro_Custo.empresa_id%TYPE)
         return Centro_Custo.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função Retorna o Código da Observação do Lançamento Fiscal
function fkg_cd_obs_lancto_fiscal ( en_obslanctofiscal_id in obs_lancto_fiscal.id%type )
         return obs_lancto_fiscal.cod_obs%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Sigla da tabela Unidade através do id.
function fkg_Unidade_sigla ( en_unidade_id  in Unidade.id%TYPE )
         return Unidade.sigla_unid%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o cd do Cfop
function fkg_cfop_cd ( en_cfop_id  in Cfop.id%TYPE )
         return Cfop.cd%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Código da tabela Item
function fkg_Item_cod ( en_item_id  in Item.id%TYPE )
         return Item.cod_item%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Infor_Comp_Dcto_Fiscal
function fkg_Infor_Comp_Dcto_Fiscal_cod( en_inforcompdctofiscal_id  in Infor_Comp_Dcto_Fiscal.id%TYPE )
         return Infor_Comp_Dcto_Fiscal.cod_infor%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função verifica se a data é valida
function fkg_data_valida ( ev_dt       in  varchar2
                         , ev_formato  in  varchar2 )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Procedimento cria usuário
procedure pkb_insere_usuario ( en_multorg_id  in  mult_org.id%type
                             , ev_login       in  neo_usuario.login%type
                             , ev_senha       in  neo_usuario.senha%type
                             , ev_nome        in  neo_usuario.nome%type
                             , ev_email       in  neo_usuario.email%type
                             );

-------------------------------------------------------------------------------------------------------

-- Procedimento bloqueia o usuário
procedure pkb_bloqueia_usuario ( ev_login    in  neo_usuario.login%type );

-------------------------------------------------------------------------------------------------------

-- Copia perfil de um usuário de origem para um usuário de destino
procedure pkb_copia_perfil_usuario ( ev_login_origem   in  neo_usuario.login%type
                                   , ev_login_destino  in  neo_usuario.login%type
                                   );

-------------------------------------------------------------------------------------------------------

-- Procedimento Copia Empresas de um usuário de origem para um usuário de destino
procedure pkb_copia_empresa_usuario ( ev_login_origem   in  neo_usuario.login%type
                                    , ev_login_destino  in  neo_usuario.login%type
                                    );

-------------------------------------------------------------------------------------------------------

--| Função retornar se existe o CPF/CNPJ para integração EDI
function fkg_integr_edi ( en_multorg_id in param_integr_edi.multorg_id%type
                        , ev_cpf_cnpj   in param_integr_edi.cpf_cnpj%type
                        , en_dm_tipo    in param_integr_edi.dm_tipo%type
                        )
         return boolean;

-------------------------------------------------------------------------------------------------------

FUNCTION fkg_limpa_acento ( ev_string  in varchar2 )
         RETURN VARCHAR2;

-------------------------------------------------------------------------------------------------------

-- Função retorna se o NCM obrigada a informação de medicamento para Nota Fiscal
function fkg_ncm_id_obrig_med_itemnf ( en_ncm_id  in ncm.id%type )
         return ncm.dm_obrig_med_itemnf%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o código da versão do sistema conforme id
function fkg_versao_sistema_id ( en_versaosistema_id in versao_sistema.id%type )
         return versao_sistema.versao%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o código da última versão atual do sistema
function fkg_ultima_versao_sistema
         return versao_sistema.versao%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o parâmetro de "Retorno da Informação de Hora de Autorização/Cancelamento da empresa"
function fkg_ret_hr_aut_empresa_id ( en_empresa_id in empresa.id%type )
         return empresa.dm_ret_hr_aut%type;

-------------------------------------------------------------------------------------------------------

-- Função converte um BLOB em CLOB
FUNCTION fkg_blob_to_clob (blob_in IN BLOB)
RETURN CLOB;

-------------------------------------------------------------------------------------------------------

-- Função retorna o dm_mod_frete da tabela nota_fiscal_transp através do notafiscal_id
function fkg_modfrete_nftransp ( en_notafiscal_id  in nota_fiscal.id%type )
         return nota_fiscal_transp.dm_mod_frete%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o codigo do imposto através do id
function fkg_Tipo_Imposto_cd ( en_tipoimp_id  in Tipo_Imposto.id%TYPE )
         return Tipo_Imposto.cd%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do conhecimento de transporte/frete através de empresa, indicadores de emissão e operação, pessoa, modelo fiscal, nro/série/subsérie do ct
function fkg_conhec_transp_id( en_empresa_id   in conhec_transp.empresa_id%type
                             , en_dm_ind_emit  in conhec_transp.dm_ind_emit%type
                             , en_dm_ind_oper  in conhec_transp.dm_ind_oper%type
                             , en_pessoa_id    in conhec_transp.pessoa_id%type
                             , en_modfiscal_id in conhec_transp.modfiscal_id%type
                             , en_nro_ct       in conhec_transp.nro_ct%type
                             , ev_serie        in conhec_transp.serie%type
                             , ev_subserie     in conhec_transp.subserie%type )
         return conhec_transp.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do item da nota fiscal através do identificador da nota fiscal e do nro do item
function fkg_item_nota_fiscal_id( en_notafiscal_id in item_nota_fiscal.notafiscal_id%type
                                , en_nro_item      in item_nota_fiscal.nro_item%type )
         return item_nota_fiscal.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do conhecimento de transporte/frete relacionado com o item da nota fiscal
function fkg_frete_itemnf_id( en_conhectransp_id   in conhec_transp.id%type
                            , en_notafiscal_id     in nota_fiscal.id%type
                            , en_itemnotafiscal_id in item_nota_fiscal.id%type )
         return frete_itemnf.id%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento de limpeza dos logs
procedure pkb_limpa_log;

-------------------------------------------------------------------------------------------------------

-- Função retorno o nome do usuário
function fkg_usuario_nome ( en_usuario_id in neo_usuario.id%type )
         return neo_usuario.nome%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da nota Fiscal de terceiro de armazenamento fiscal a partir do número da chave de acesso
function fkg_nf_id_terceiro_pela_chave ( en_nro_chave_nfe in Nota_Fiscal.nro_chave_nfe%TYPE )
         return Nota_Fiscal.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorno o ID da tabela NEO_PAPEL conforme "sigla da descrição"
function fkg_papel_id_conf_nome ( ev_nome in neo_papel.nome%type )
         return neo_papel.id%type;

-------------------------------------------------------------------------------------------------------

-- Função verifica se existe o papel informado para o usuário
function fkg_existe_usuario_papel ( en_usuario_id  in neo_usuario.id%type
                                  , en_papel_id    in neo_papel.id%type
                                  )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do acesso de usuário/empresa
function fkg_usuario_empresa_id ( en_usuario_id  in neo_usuario.id%type
                                , en_empresa_id  in empresa.id%type
                                )
         return usuario_empresa.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorno o ID do acesso do usuário a Unidade Organizacional
function fkg_usuempr_unidorg_id ( en_usuempr_id  in usuario_empresa.id%type
                                , en_unidorg_id  in unid_org.id%type
                                )
         return usuempr_unidorg.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorno o código de nome da empresa conforme seu ID
function fkg_cod_nome_empresa_id ( en_empresa_id in empresa.id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Código de Consumo do Item de Serviço Contínuo "COD_CONS_ITEM_CONT"
function fkg_codconsitemcont_id ( en_modfiscal_id  in  mod_fiscal.id%type
                                , ev_cod_cons      in  cod_cons_item_cont.cod_cons%type
								)
         return cod_cons_item_cont.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do Código da Classe de Consumo do Item de Serviço Contínuo
function fkg_class_cons_item_cont_id ( ev_cod_class in class_cons_item_cont.cod_class%type )
         return class_cons_item_cont.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retona o ID da empresa pelo ID da nota fiscal
function fkg_empresa_notafiscal ( en_notafiscal_id in nota_fiscal.id%type )
         return empresa.id%type;

-------------------------------------------------------------------------------------------------------

-- Função verifica se cálcula ICMS-ST para a Nota Fiscal conforme Empresa
function fkg_dm_nf_calc_icmsst_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_nf_calc_icmsst%type;

-------------------------------------------------------------------------------------------------------

-- Função verifica se a empresa ajusta o total da nota fiscal
function fkg_ajustatotalnf_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_ajusta_total_nf%type;

-------------------------------------------------------------------------------------------------------

-- Função Retorna o Texto da Observação do Lançamento Fiscal
function fkg_txt_obs_lancto_fiscal ( en_obslanctofiscal_id in obs_lancto_fiscal.id%type )
         return obs_lancto_fiscal.txt%type;

-------------------------------------------------------------------------------------------------------

-- Função Retorna a Inscrição Estadual do Substituto conforme Empresa e Estado
function fkg_iest_empresa ( en_empresa_id  in empresa.id%type
                          , en_estado_id   in estado.id%type
                          )
         return ie_subst.iest%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna "true" se o id é válido e "false" se não é
function fkg_itemparamicmsst_id_valido ( en_id  in item_param_icmsst.id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função que verifica a existencia de resgistro na Item_param_icmsst
function fkg_item_param_icmsst_id ( en_item_id	     in  item_param_icmsst.item_id%type
				  , en_empresa_id    in  item_param_icmsst.empresa_id%type
                                  , en_estado_id     in  item_param_icmsst.estado_id%type
              	                  , en_cfop_id_orig  in  item_param_icmsst.cfop_id%type
              	                  , ed_dt_ini	     in	 item_param_icmsst.dt_ini%type
              	                  , ed_dt_fin	     in	 item_param_icmsst.dt_fin%type
				  )
         return item_param_icmsst.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna CD através do tipo de parâmetro
function fkg_cd_tipoparam ( en_tipoparam_id in tipo_param.id%type )
         return tipo_param.cd%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna ID do tipo de parâmetro
function fkg_tipoparam_id ( ev_cd in tipo_param.cd%type )
         return tipo_param.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna a informação do "ID" do Valor do Tipo de Parametro salvo na pessoa
function fkg_pessoa_valortipoparam_id ( en_tipoparam_id in tipo_param.id%type
                                      , en_pessoa_id    in pessoa.id%type
									  )
         return valor_tipo_param.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o a informação do "CD" do Valor do Tipo de Parametro conforme o ID
function fkg_valortipoparam_id ( en_valortipoparam_id valor_tipo_param.id%type )
         return valor_tipo_param.cd%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna a informação do "código" do Valor do Tipo de Parametro conforme pessoa
function fkg_pessoa_valortipoparam_cd ( ev_tipoparam_cd in tipo_param.cd%type
                                      , en_pessoa_id    in pessoa.id%type
									  )
         return valor_tipo_param.cd%type;

-------------------------------------------------------------------------------------------------------

-- Retorna o CD do código de tributação do município, conforme o ID
function fkg_codtribmunicipio_cd ( en_codtribmunicipio_id in cod_trib_municipio.id%type )
         return cod_trib_municipio.cod_trib_municipio%type;

-------------------------------------------------------------------------------------------------------

-- Retorna o ID do código de tributação do município, conforme o CD e Cidade
function fkg_codtribmunicipio_id ( ev_codtribmunicipio_cd  in cod_trib_municipio.cod_trib_municipio%type
                                 , en_cidade_id            in cod_trib_municipio.cidade_id%type
                                 )
         return cod_trib_municipio.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorma a descrição da cidade conforme o IBGE dela
function fkg_descr_cidade_conf_ibge ( ev_ibge_cidade  in cidade.ibge_cidade%type )
         return cidade.descr%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do Tipo de Código de arquivo
function fkg_tipocodarq_id ( ev_cd in tipo_cod_arq.cd%type )
         return tipo_cod_arq.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o código do "Tipo de Código de arquivo" por pais

function fkg_cd_pais_tipo_cod_arq ( en_pais_id        in pais.id%type
                                  , en_tipocodarq_id  in tipo_cod_arq.id%type
                                  )
         return pais_tipo_cod_arq.cd%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o código do "Tipo de Código de arquivo" por estado
function fkg_cd_estado_tipo_cod_arq ( en_estado_id in estado.id%type
                                    , en_tipocodarq_id in tipo_cod_arq.id%type
                                    )
         return estado_tipo_cod_arq.cd%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o código do "Tipo de Código de arquivo" por cidade
function fkg_cd_cidade_tipo_cod_arq ( en_cidade_id in cidade.id%type
                                    , en_tipocodarq_id in tipo_cod_arq.id%type
                                    )
         return cidade_tipo_cod_arq.cd%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o sigla_estado que está relacionado ao pessoa_id
function fkg_sigla_estado_empresa ( en_empresa_id in empresa.id%type )
         return estado.sigla_estado%type;

-------------------------------------------------------------------------------------------------------

-- Função verifica se cálcula ICMS-Normal para a Nota Fiscal conforme Empresa
function fkg_dm_nf_calc_icms_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_nf_calc_icms%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento Copia o perfil de acesso de um usuário (papeis e empresas)
procedure pkb_copia_perfil_acesso_usu ( ev_login_origem   in  neo_usuario.login%type
                                      , ev_login_destino  in  neo_usuario.login%type
                                      );

-------------------------------------------------------------------------------------------------------

-- Função retorna o valor do parâmetro "Ajusta valores dos itens da NF com o Total" conforme empresa
function fkg_ajustvlr_inf_conf_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_ajust_vlr_itemnf%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o valor do parâmetro "Integra o Item (produto/serviço)" conforme empresa
function fkg_integritem_conf_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_integr_item%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna parâmetro de validação de CFOP por destinatário - conforme o identificador da empresa.
function fkg_dm_valcfoppordest_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_valida_cfop_por_dest%type;

-------------------------------------------------------------------------------------------------------

-- Função para retornar indicador de operação da nota fiscal - nota_fiscal.dm_ind_oper -> 0-entrada, 1-saída.
function fkg_recup_dmindoper_nf_id ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal.dm_ind_oper%type;

-------------------------------------------------------------------------------------------------------

-- Retorna o E-mail do usuário do Sistema conforme multorg_id e ID_ERP
function fkg_usuario_email_conf_erp ( en_multorg_id in mult_org.id%type
                                    , ev_id_erp     in neo_usuario.id_erp%type
                                    )
         return neo_usuario.email%type;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o identificador do modelo fiscal da nota fiscal - nota_fiscal.modfiscal_id - através do identificador da nota fiscal.
function fkg_recup_modfisc_id_nf ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal.modfiscal_id%type;

-------------------------------------------------------------------------------------------------------

-- Função recupera a Ordem de impressão dos itens na DANFE na empresa
function fkg_dm_ordimpritemdanfe_empr ( en_empresa_id empresa.id%type )
         return empresa.dm_ord_impr_item_danfe%type;

-------------------------------------------------------------------------------------------------------

-- Função para retornar se a empresa permite validação de cfop de crédito de pis/cofins para notas fiscais de pessoa física.
function fkg_empr_val_cred_pf_pc ( en_empresa_id empresa.id%type )
         return empresa.dm_val_gera_cred_pf_pc%type;

-------------------------------------------------------------------------------------------------------

-- Função para retornar se a empresa permite Ajustar base de cálculo de imposto
function fkg_empr_ajust_base_imp ( en_empresa_id in empresa.id%type )
         return empresa.dm_ajust_base_imp%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna ibge_estado conforme o empresa_id
function fkg_ibge_estado_empresa_id ( ev_empresa_id  in empresa.id%type )
         return estado.ibge_estado%type;

-------------------------------------------------------------------------------------------------------

-- Função para verificar campos Flex Field - FF.
function fkg_ff_verif_campos( ev_obj_name in obj_util_integr.obj_name%type
                            , ev_atributo in ff_obj_util_integr.atributo%type
                            , ev_valor    in varchar2 )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o domínio - tipo do campo Flex Field - FF, através do objeto e do atributo.
function fkg_ff_retorna_dmtipocampo( ev_obj_name in obj_util_integr.obj_name%type
                                   , ev_atributo in ff_obj_util_integr.atributo%type )
         return ff_obj_util_integr.dm_tipo_campo%type;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o tamanho do campo Flex Field - FF, através do objeto e do atributo.
function fkg_ff_retorna_tamanho( ev_obj_name in obj_util_integr.obj_name%type
                               , ev_atributo in ff_obj_util_integr.atributo%type )
         return ff_obj_util_integr.tamanho%type;

-------------------------------------------------------------------------------------------------------

-- Função para retornar a quantidade em decimal do campo Flex Field - FF, através do objeto e do atributo.
function fkg_ff_retorna_decimal( ev_obj_name in obj_util_integr.obj_name%type
                               , ev_atributo in ff_obj_util_integr.atributo%type )
         return ff_obj_util_integr.qtde_decimal%type;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o valor dos campos Flex Field - FF - tipo DATA.
function fkg_ff_ret_vlr_data( ev_obj_name in obj_util_integr.obj_name%type
                            , ev_atributo in varchar2
                            , ev_valor    in varchar2 )
         return date;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o valor dos campos Flex Field - FF - tipo NUMÉRICO.
function fkg_ff_ret_vlr_number( ev_obj_name in obj_util_integr.obj_name%type
                              , ev_atributo in varchar2
                              , ev_valor    in varchar2 )
         return number;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o valor dos campos Flex Field - FF - tipo CARACTERE.
function fkg_ff_ret_vlr_caracter( ev_obj_name in obj_util_integr.obj_name%type
                                , ev_atributo in varchar2
                                , ev_valor    in varchar2 )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorno o CPF ou CNPJ com mascara
function fkg_masc_cpf_cnpj ( ev_cpf_cnpj in varchar2 )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do Tipo de Operacao do CFOP
function fkg_tipooperacao_id ( ev_id in tipo_operacao.id%type )
         return tipo_operacao.cd%type;

-------------------------------------------------------------------------------------------------------

-- Função retornda o CD do Tipo de Operação conforme CD do CFOP
function fkg_cd_tipooper_conf_cfop ( ev_cfop_cd in cfop.cd%type )
         return tipo_operacao.cd%type;

-------------------------------------------------------------------------------------------------------

-- Função verifica o tipo de formato de data do retorno da informação para o ERP
function fkg_empresa_dm_form_dt_erp ( en_empresa_id in Empresa.id%type )
         return empresa.dm_form_dt_erp%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna código da conta do plano de contas através do ID do Plano de Conta
function fkg_cd_plano_conta ( en_planoconta_id in plano_conta.id%type )
         return plano_conta.cod_cta%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna código do centro de custo através do ID do Centro de Custo
function fkg_cd_centro_custo ( en_centrocusto_id in centro_custo.id%type )
         return centro_custo.cod_ccus%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o identificador do objeto de integração através do código
function fkg_recup_objintegr_id( ev_cd in obj_integr.cd%type )
         return obj_integr.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do tabela TIPO_OBJ_INTEGR, conforme OBJINTEGR_ID e Código

function fkg_tipoobjintegr_id ( en_objintegr_id      in tipo_obj_integr.objintegr_id%type
                              , ev_tipoobjintegr_cd  in tipo_obj_integr.cd%type
                              )
         return tipo_obj_integr.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o CD do tabela TIPO_OBJ_INTEGR, conforme ID

function fkg_tipoobjintegr_cd ( en_tipoobjintegr_id  in tipo_obj_integr.id%type
                              )
         return tipo_obj_integr.cd%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna a última data de fechamento fiscal por empresa
function fkg_recup_dtult_fecha_empresa( en_empresa_id   in fecha_fiscal_empresa.empresa_id%type
                                      , en_objintegr_id in fecha_fiscal_empresa.objintegr_id%type )
         return fecha_fiscal_empresa.dt_ult_fecha%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna se o período informado está fechado - fechamento fiscal por empresa - 0-não ou 1-sim
function fkg_periodo_fechado_empresa( en_empresa_id   in fecha_fiscal_empresa.empresa_id%type
                                    , en_objintegr_id in fecha_fiscal_empresa.objintegr_id%type
                                    , ed_dt_ult_fecha in fecha_fiscal_empresa.dt_ult_fecha%type )
         return number;

-------------------------------------------------------------------------------------------------------

-- Função verifica se existe o ID do Complemento do Item
function fkg_existe_item_compl ( en_inf_item_compl_id in item_compl.item_id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função para recuperar as pessoas de mesmo cpf ou cnpj
function fkg_ret_string_id_pessoa ( en_multorg_id  in mult_org.id%type
                                  , ev_cpf_cnpj    in varchar2
                                  )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do Valor do Tipo de Parâmetro
function fkg_valor_tipo_param_id ( en_tipoparam_id          in tipo_param.id%type
                                 , ev_valor_tipo_param_cd   in valor_tipo_param.cd%type
                                 )
         return valor_tipo_param.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do parâmetro de pessoa
function fkg_pessoa_tipo_param_id ( en_pessoa_id          in pessoa.id%type
                                  , en_tipoparam_id       in tipo_param.id%type
                                  , en_valortipoparam_id  in valor_tipo_param.id%type
                                  )
         return pessoa_tipo_param.id%Type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o valor do campo DM_TROCA_CFOP_NF por empresa
function fkg_empresa_troca_cfop_nf ( en_empresa_id in empresa.id%type )
         return empresa.dm_troca_cfop_nf%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna "true" se o item_id possui código de NCM válido e "false" se não possui.
function fkg_item_ncm_valido ( en_item_id  in Item.id%TYPE )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna o identificador do NCM através do identificador do Item do produto
function fkg_ncm_id_item ( en_item_id  in item.id%type )
         return ncm.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela tipo_ret_imp conforme o codigo de retenção e o id do tipo do imposto.
function fkg_tipo_ret_imp ( en_multorg_id  in tipo_ret_imp.multorg_id%TYPE
                          , en_cd_ret      in tipo_ret_imp.cd%TYPE
                          , en_tipoimp_id  in tipo_imposto.id%TYPE
                          )
         return tipo_ret_imp.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o código do tipo de retenção do imposto através do id
function fkg_tipo_ret_imp_cd ( en_tiporetimp_id  in tipo_ret_imp.id%TYPE )
         return tipo_ret_imp.cd%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna verifica se a empresa Gera tributações de impostos
function fkg_empresa_gera_tot_trib ( en_empresa_id in empresa.id%type )
         return empresa.dm_gera_tot_trib%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do Controle de Versão Contábil conforme UK (unique key)
function fkg_ctrlversaocontabil_id ( en_empresa_id  in empresa.id%type
                                   , ev_cd          in ctrl_versao_contabil.cd%type
                                   , en_dm_tipo     in ctrl_versao_contabil.dm_tipo%type
                                   )
         return ctrl_versao_contabil.id%type;

-------------------------------------------------------------------------------------------------------

-- Função verifica se o valor do ID existe no Controle de Versão Contábil
function fkg_existe_ctrlversaocontabil ( en_ctrlversaocontabil_id in ctrl_versao_contabil.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função para retornar se a empresa permite Ajustar valores de impostos de importação com suframa
function fkg_empr_ajust_desc_zfm_item ( en_empresa_id in empresa.id%type )
         return empresa.dm_ajust_desc_zfm_item%type;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o tipo de emitente da nota fiscal - nota_fiscal.dm_ind_emit = 0-emissão própria, 1-terceiros
function fkg_dmindemit_notafiscal ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal.dm_ind_emit%type;

-------------------------------------------------------------------------------------------------------

-- Função para retornar a finalidade da nota fiscal - nota_fiscal.dm_fin_nfe = 1-NF-e normal, 2-NF-e complementar, 3-NF-e de ajuste
function fkg_dmfinnfe_notafiscal ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal.dm_fin_nfe%type;

-------------------------------------------------------------------------------------------------------

-- Função para retornar a sigla do estado do emitente da nota fiscal
function fkg_uf_notafiscalemit ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal_emit.uf%type;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o CNPJ do emitente da nota fiscal
function fkg_cnpj_notafiscalemit ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal_emit.cnpj%type;
         
-------------------------------------------------------------------------------------------------------

-- Função para retornar a sigla do estado do destinatário da nota fiscal
function fkg_uf_notafiscaldest ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal_dest.uf%type;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o identificador de pessoa da nota fiscal
function fkg_pessoa_notafiscal_id ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal.pessoa_id%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto ICMS - Parâmetro para Notas Fiscais com Emissão Própria
function fkg_empresa_dmvalimp_emis ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valid_imp%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto ICMS60 - Parâmetro para Notas Fiscais com Emissão Própria
function fkg_empresa_dmvalicms60_emis ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valid_icms60%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida Bases de ICMS - Parâmetro para Notas Fiscais com Emissão Própria

function fkg_empresa_dmvalbaseicms_emis ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valid_base_icms%type;         

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto IPI - Parâmetro para Notas Fiscais com Emissão Própria
function fkg_empresa_dmvalipi_emis ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_ipi%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto PIS - Parâmetro para Notas Fiscais com Emissão Própria
function fkg_empresa_dmvalpis_emis ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_pis%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto Cofins - Parâmetro para Notas Fiscais com Emissão Própria
function fkg_empresa_dmvalcofins_emis ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_cofins%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto ICMS - Parâmetro para Notas Fiscais com Emissão de Terceiros
function fkg_empresa_dmvalimp_terc ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valid_imp_terc%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto ICMS60 - Parâmetro para Notas Fiscais com Emissão de Terceiros
function fkg_empresa_dmvalicms60_terc ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valid_icms60_terc%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida Bases de ICMS - Parâmetro para Notas Fiscais com Emissão de Terceiros

function fkg_empresa_dmvalbaseicms_terc ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valid_base_icms_terc%type;         

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida Bases de ICMS - Parâmetro para Forma de demonstração das bases de ICMS
function fkg_empresa_dmformademb_icms ( en_empresa_id in Empresa.id%type )
         return empresa.dm_forma_dem_base_icms%type ;

-------------------------------------------------------------------------------------------------------
-- Procedimento verifica se a empresa valida o imposto IPI - Parâmetro para Notas Fiscais com Emissão de Terceiros
function fkg_empresa_dmvalipi_terc ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_ipi_terc%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto PIS - Parâmetro para Notas Fiscais com Emissão de Terceiros
function fkg_empresa_dmvalpis_terc ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_pis_terc%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto Cofins - Parâmetro para Notas Fiscais com Emissão de Terceiros
function fkg_empresa_dmvalcofins_terc ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_cofins_terc%type;

-------------------------------------------------------------------------------------------------------
--| Função retorna o ID da tabela GRUPO_PAT

function fkg_grupopat_id ( en_multorg_id    in  mult_org.id%type
                         , ev_cod_grupopat  in  grupo_pat.cd%type )
         return grupo_pat.id%TYPE;
         
-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela SUBGRUPO_PAT

function fkg_subgrupopat_id ( ev_cod_subgrupopat  in  subgrupo_pat.cd%type
                            , en_grupopat_id      in  grupo_pat.id%type )
         return subgrupo_pat.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função returna TRUE se existe o grupo ou FALSE caso contrário

function fkg_existe_grupo_pat ( en_grupopat_id in grupo_pat.id%type )
         return boolean;
         
-------------------------------------------------------------------------------------------------------

-- Função returna TRUE se existe o subgrupo ou FALSE caso contrário

function fkg_existe_subgrupo_pat ( en_subgrupopat_id in subgrupo_pat.id%type )
         return boolean;         

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela REC_IMP_SUBGRUPO_PAT

function fkg_recimpsubgrupopat_id ( en_subgrupopat_id  in subgrupo_pat.id%type
                                  , en_tipoimp_id      in tipo_imposto.id%type )
         return rec_imp_subgrupo_pat.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função returna TRUE se existe o imposto do subgrupo ou FALSE caso contrário

function fkg_existe_imp_subgrupo_pat ( en_recimpsubgrupo_id in rec_imp_subgrupo_pat.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela NF_BEM_ATIVO_IMOB

function fkg_nfbemativoimob_id ( en_bemativoimob_id  in   bem_ativo_imob.id%type
                               , en_dm_ind_emit      in   nf_bem_ativo_imob.dm_ind_emit%type
                               , en_pessoa_id        in   nf_bem_ativo_imob.pessoa_id%type
                               , en_modfiscal_id     in   nf_bem_ativo_imob.modfiscal_id%type
                               , ev_serie            in   nf_bem_ativo_imob.serie%type
                               , ev_num_doc          in   nf_bem_ativo_imob.num_doc%type )
         return nf_bem_ativo_imob.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna TRUE se existe o documento fiscal do bem ou FALSE caso contrário

function fkg_existe_nf_bem_ativo_imob ( en_nfbemativoimob_id in nf_bem_ativo_imob.id%type )
         return boolean;
         
-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela ITNF_BEM_ATIVO_IMOB

function fkg_itnfbemativoimob_id ( en_nfbemativoimob_id in nf_bem_ativo_imob.id%type
                                 , en_num_item          in itnf_bem_ativo_imob.num_item%type )
         return itnf_bem_ativo_imob.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna TRUE se existe o item do documento fiscal do bem ou FALSE caso contrário

function fkg_existe_itnf_bem_ativo_imob ( en_itnfbemativoimob_id in itnf_bem_ativo_imob.id%type )
         return boolean;
         
-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela REC_IMP_BEM_ATIVO_IMOB

function fkg_recimpbemativoimob_id ( en_bemativoimob_id in bem_ativo_imob.id%type
                                   , en_tipoimp_id      in tipo_imposto.id%type )
         return rec_imp_bem_ativo_imob.id%TYPE;
         
-------------------------------------------------------------------------------------------------------

-- Função retorna TRUE se existe o imposto do bem ou FALSE caso contrário

function fkg_existe_rec_imp_bem_ativo ( en_recimpbemativoimob_id in rec_imp_bem_ativo_imob.id%type )
         return boolean;                  

-------------------------------------------------------------------------------------------------------

-- Função para retorno o "Cálculo do Imposto do Patrimônio" da Empresa

function fkg_empresa_calc_imp_patr ( en_empresa_id in empresa.id%type )
         return empresa.dm_calc_imp_patr%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela Pessoa através do CNPJ ou CPF e da Sigla do Estado - UF
function fkg_pessoa_id_cpf_cnpj_uf ( en_multorg_id  in mult_org.id%type
                                   , en_cpf_cnpj    in varchar2
                                   , ev_uf          in varchar2
                                   )
         return pessoa.id%type;

-------------------------------------------------------------------------------------------------------

-- Função para recuperar parãmetro que indica se a empresa compõe o tipo de código de crédito através do tipo de embalagem.
function fkg_dmutilprocemb_tpcred_empr( en_empresa_id in empresa.id%type )
         return empresa.dm_util_proc_emb_tipocred%type;

-------------------------------------------------------------------------------------------------------

--| Função retorna cod_class da tabela class_cons_item_cont conforme o id

function fkg_cod_class ( ev_classconsitemcont_id in class_cons_item_cont.id%type )
         return class_cons_item_cont.cod_class%type;

-------------------------------------------------------------------------------------------------------

--| Função retorna o cod_cons da tabela cod_cons_item_cont

function fkg_codconsitemcont_cod( en_codconsitemcont_id  in cod_cons_item_cont.id%TYPE )
         return cod_cons_item_cont.cod_cons%type;
         
-------------------------------------------------------------------------------------------------------

--| Função que verifica se o Número de controle da FCI do Item é válido.
-- É válido o número da FCI que é de tamanho 36, contém apenas caracteres de "A" a "F", algarismos
-- e o caractere de hífen "-" nas posições 9, 14, 19 e 24.

function fkg_nro_fci_valido ( ev_nro_fci in item_nota_fiscal.nro_fci%type )
         return boolean;
         
-------------------------------------------------------------------------------------------------------

--| Função retorna o cd da tabela tipo_evento_sefaz conforme o ID

function fkg_tipoeventosefaz_cd( en_tipoeventosefaz_id  in tipo_evento_sefaz.id%TYPE )
         return tipo_evento_sefaz.cd%type;
         
-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela tipo_evento_sefaz conforme o CD

function fkg_tipoeventosefaz_id( ev_cd  in tipo_evento_sefaz.cd%TYPE )
         return tipo_evento_sefaz.id%type;

-------------------------------------------------------------------------------------------------------

--| Função retorna o parâmatro da Empresa de "Retorna Consulta de CTe sem XML de Terceiro"

function fkg_ret_cons_cte_sem_xml ( en_empresa_id in Empresa.id%type )
         return empresa.dm_ret_cons_cte_sem_xml%type;
         
-------------------------------------------------------------------------------------------------------

--| Função retorna o CNPJ da tabela pais_cnpj conforme o id do PAIS e da CIDADE

function fkg_paiscnpj_cnpj ( en_pais_id    in pais.id%TYPE
                           , en_cidade_id  in cidade.id%TYPE )
         return pais_cnpj.cnpj%type;
         
-------------------------------------------------------------------------------------------------------

-- Função retorna a inscrição municipal da empresa

function fkg_inscr_mun_empresa ( en_empresa_id  in Empresa.id%TYPE )
         return Juridica.im%TYPE;
         
-------------------------------------------------------------------------------------------------------

-- Função retorna o código do IBGE da cidade da empresa conforme o ID da empresa

function fkg_ibge_cidade_empresa ( en_empresa_id  in Empresa.id%TYPE )
         return cidade.ibge_cidade%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o valor de tolerância para os valores de documentos fiscais (nf, cf, ct) e caso não exista manter 0.03

function fkg_vlr_toler_empresa ( en_empresa_id  in empresa.id%type
                               , ev_opcao       in varchar2 )
         return number;

-------------------------------------------------------------------------------------------------------

-- Procedimento retorna os parâmetros de Difirencial de Alíquota para a EFD ICMS/IPI
procedure pkb_param_difal_efd_icms_ipi ( en_empresa_id                   in empresa.id%type
                                       , sn_dm_lcto_difal               out param_efd_icms_ipi.dm_lcto_difal%type
                                       , sn_codajsaldoapuricms_id_difal out param_efd_icms_ipi.codajsaldoapuricms_id_difal%type
                                       , sn_codocorajicms_id_difal      out param_efd_icms_ipi.codocorajicms_id_difal%type
                                       , sn_codajsaldoapuricms_id_difpa out param_efd_icms_ipi.codajsaldoapuricms_id_difpart%type
                                       );

-------------------------------------------------------------------------------------------------------

-- Procedimento retorna os parâmetros de Difirencial de Alíquota para a EFD ICMS/IPI
function fkg_param_ciap_efd_icms_ipi ( en_empresa_id                   in empresa.id%type
                                     )
         return param_efd_icms_ipi.codajsaldoapuricms_id_ciap%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento retorna os parâmetros Código de Ajuste de IPI Não destacado para a EFD ICMS/IPI
function fkg_par_ipi_naodest_efdicmsipi ( en_empresa_id                   in empresa.id%type
                                        )
         return param_efd_icms_ipi.codajapuripi_id_ipi_nao_dest%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Parâmetro de Indicador de Tributação do Totalizador Parcial de ECF da empresa
function fkg_indtribtotparcredz_empresa ( en_empresa_id                   in empresa.id%type
                                        )
         return empresa.dm_ind_trib_tot_parc_redz%type;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o identificador do relacionamento de item/componente e insumo
function fkg_item_insumo_id( en_item_id     in item.id%type
                           , en_item_id_ins in item.id%type
                           )
         return item_insumo.id%type;

-------------------------------------------------------------------------------------------------------

-- Função para retornar se o relacionamento de item/componente e insumo já existe
function fkg_existe_iteminsumo( en_iteminsumo_id in item_insumo.id%type
                              )
         return boolean;
         
-------------------------------------------------------------------------------------------------------
-- Função retorna o ID da tabela NFINFOR_FISCAL conforme o NOTAFISCAL_ID

function fkg_nfinfor_fiscal_id ( en_notafiscal_id      in nota_fiscal.id%type
                               , en_obslanctofiscal_id in obs_lancto_fiscal.id%type )
         return nfinfor_fiscal.id%type;

-------------------------------------------------------------------------------------------------------
-- Função retorna o COD_OBS da tabela OBS_LANCTO_FISCAL conforme o NFINFORFISCAL_ID

function fkg_cod_obs_nfinfor_fiscal ( en_nfinforfiscal_id in nfinfor_fiscal.id%type )
         return obs_lancto_fiscal.cod_obs%type;

-------------------------------------------------------------------------------------------------------
-- Função retorna o NRO_ITEM da tabela ITEM conforme o ITEMNOTAFISCAL_ID

function fkg_nro_item ( en_itemnotafiscal_id  in item_nota_fiscal.id%type )
         return item_nota_fiscal.nro_item%type;        

-------------------------------------------------------------------------------------------------------
-- Função retorna o código de ajuste das obrigações a recolher através do identificador
function fkg_cd_ajobrigrec ( en_ajobrigrec_id in aj_obrig_rec.id%type )
         return aj_obrig_rec.cd%type;

-------------------------------------------------------------------------------------------------------

--| Retorna o parâmetro de empresa EMPR_PARAM_CONS_MDE.DM_REG_CO_MDE_AUT

function fkg_empresa_reg_co_mde_aut ( en_empresa_id                   in empresa.id%type
                                    )
         return empr_param_cons_mde.dm_reg_co_mde_aut%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o IBGE_CIDADE conforme Estado e Descrição da Cidade

function fkg_ibge_cidade_dados ( ev_sigla_estado in estado.sigla_estado%type 
                               , ev_descr_cidade in cidade.descr%type
                               )
         return cidade.ibge_cidade%type;

-------------------------------------------------------------------------------------------------------

--| Retorna o parâmetro de empresa EMPR_PARAM_CONS_MDE.DM_REG_MDE_AUT

function fkg_empresa_reg_mde_aut ( en_empresa_id in empresa.id%type )
         return empr_param_cons_mde.dm_reg_mde_aut%type;
         
-------------------------------------------------------------------------------------------------------

-- Função retorna o código do bem do ativo imobilizado conforme o id

function fkg_cod_ind_bem_id ( en_bemativoimob_id in bem_ativo_imob.id%type )
         return bem_ativo_imob.cod_ind_bem%type;
         
-------------------------------------------------------------------------------------------------------

-- Função retorna o Código da tabela SUBGRUPO_PAT

function fkg_subgrupopat_cd ( en_subgrupopat_id  in subgrupo_pat.id%type )
         return subgrupo_pat.cd%type;
         
-------------------------------------------------------------------------------------------------------

-- Função retorna o CD da tabela GRUPO_PAT conforme o ID da tabela SUBGRUPO_PAT

function fkg_grupopat_cd_subgrupo_id ( en_subgrupopat_id  in subgrupo_pat.id%type )
         return grupo_pat.cd%type;
         
-------------------------------------------------------------------------------------------------------

-- Função retorna TRUE se existe o Plano de Contas ou FALSE caso não exista

function fkg_existe_plano_conta ( en_planoconta_id in plano_conta.id%type )
         return boolean;
         
-------------------------------------------------------------------------------------------------------

-- Função retorna TRUE se existe o Plano de Contas Referencial ou FALSE caso não exista

function fkg_existe_pc_referen ( en_pcreferen_id in pc_referen.id%type )
         return boolean;
         
-------------------------------------------------------------------------------------------------------

-- Função retorna TRUE se existe o Centro de Custo ou FALSE caso não exista

function fkg_existe_centro_custo ( en_centrocusto_id in centro_custo.id%type )
         return boolean;
         
-------------------------------------------------------------------------------------------------------

-- Função retorna TRUE se existe o Histórico Padrão ou FALSE caso não exista

function fkg_existe_hist_padrao ( en_histpadrao_id in hist_padrao.id%type )
         return boolean;
         
-------------------------------------------------------------------------------------------------------

--| Retorna a quantidade de registros da tabela enviada no parâmetro

function fkg_quantidade ( ev_obj    varchar2 )
         return number;
         
-------------------------------------------------------------------------------------------------------

--| Monta o objeto conforme aspas, owner e dblink

function fkg_monta_obj ( ev_obj         in varchar2
                       , ev_aspas       in varchar2
                       , ev_owner_obj   in varchar2
                       , ev_nome_dblink in varchar2
                       , en_dm_ind_emit in number default null
                       )
         return varchar2; 

-------------------------------------------------------------------------------------------------------

--| Retorna a descrição (nome) da cidade conforme o ID

function fkg_cidade_descr ( en_cidade_id   in cidade.id%type )
         return cidade.descr%type;
         
-------------------------------------------------------------------------------------------------------

-- Retorna o ID do mult_org vinculado ao usuário

function fkg_multorg_id_usuario ( en_usuario_id in neo_usuario.id%type )
         return mult_org.id%type; 
         
-------------------------------------------------------------------------------------------------------

-- Retorna o tipo de ambiente da nota fiscal

function fkg_dm_tp_amb_nf ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal.dm_tp_amb%type;

-------------------------------------------------------------------------------------------------------

-- Retorna o valor do Parâmetro Gerar XML WS Sinal Suframa

function fkg_cfop_gerar_sinal_suframa ( en_empresa_id in empresa.id%type
                                      , en_cfop_id    in cfop.id%type
                                      )
         return param_cfop_empresa.dm_gera_sinal_suframa%type;
         
-------------------------------------------------------------------------------------------------------

--
-- Recebe como entrada um texto(ev_texto) separado por algum simbolo(ev_separador)
-- e devolve um array onde cada posição do array é uma palavra que estava entre o separador.
--

procedure pkb_dividir ( ev_texto       in     varchar2
                      , ev_separador   in     varchar2
                      , estv_texto     in out dbms_sql.varchar2_table );       

-------------------------------------------------------------------------------------------------------

-- Função retorna código da conta + descrição do plano de contas através do ID do Plano de Conta

function fkg_texto_plano_conta_id ( en_planoconta_id in plano_conta.id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna código do centro de custo + descrição através do ID do Centro de Custo

function fkg_texto_centro_custo_id ( en_centrocusto_id in centro_custo.id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID "CNAE"conforme o Código

function fkg_id_cnae_cd ( en_cnae_cd in cnae.cd%TYPE )
         return cnae.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Código do "CNAE" conforme ID

function fkg_cd_cnae_id ( en_cnae_id in cnae.id%TYPE )
         return cnae.cd%TYPE;
         
-------------------------------------------------------------------------------------------------------

--| Função retorna o NOME da tabela NEO_PAPEL conforme ID

function fkg_papel_nome_conf_id ( en_papel_id in neo_papel.id%type )
         return neo_papel.nome%type;   
         
-------------------------------------------------------------------------------------------------------

-- Função retorna o campo EMPRESA_ID conforme o multorg_id e (CPF ou CNPJ)
-- Esta função é uma cópia da fkg_empresa_id_pelo_cpf_cnpj, porém essa nova não considera
-- se a empresa está ativa ou não.

function fkg_empresa_id_cpf_cnpj ( en_multorg_id  in mult_org.id%type
                                 , ev_cpf_cnpj    in varchar2
                                 ) return Empresa.id%TYPE;
         
-------------------------------------------------------------------------------------------------------

--| Função retorna o NRO_PROC da tabela RET_EVENTO_EPEC conforme ID da nota

function fkg_ret_evento_epec_proc_id ( en_notafiscal_id in nota_fiscal.id%type )
         return ret_evento_epec.nro_proc%type;

-------------------------------------------------------------------------------------------------------

--| Função retorna o COD_STAT da tabela RET_EVENTO_EPEC conforme ID da nota

function fkg_ret_evento_epec_stat_id ( en_notafiscal_id in nota_fiscal.id%type )
         return ret_evento_epec.cod_stat%type;
         
-------------------------------------------------------------------------------------------------------

--| Retorna o limite de quantade de dias para emissão da NFe conforme a empresa

function fkg_estado_lim_emiss_nfe ( en_empresa_id in empresa.id%type )
         return estado.lim_emiss_nfe%type;
         
-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da nota Fiscal a partir do número da chave de acesso e empresa_id

function fkg_notafiscal_id_chave_empr ( en_nro_chave_nfe  in Nota_Fiscal.nro_chave_nfe%TYPE
                                      , en_empresa_id     in empresa.id%type )
         return nota_fiscal.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna situação do documento da Nota Fiscal através do identificador da nota fiscal
function fkg_sitdoc_id_nf ( en_notafiscal_id in nota_fiscal.id%type )
         return sit_docto.id%type;
         
-------------------------------------------------------------------------------------------------------

-- Função retorna a data de contingência da Nota Fiscal através do identificador
function fkg_dt_cont_nf ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal.dt_cont%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna DM_VAL_NCM_ITEM através do ID da empresa.
function fkg_dmvalncm_empid(en_empresa_id in empresa.id%type)
         return empresa.dm_val_ncm_item%type;

-------------------------------------------------------------------------------------------------------

-- Função que retorna DM_DT_ESCR_DFEPOE através do ID da empresa.
function fkg_dmdtescrdfepoe_empresa(en_empresa_id in empresa.id%type)
         return empresa.dm_dt_escr_dfepoe%type;
         
-------------------------------------------------------------------------------------------------------

-- Função que retorna cidade_id da empresa da nota informada.

function fkg_cidade_id_nf_id ( en_notafiscal_id in nota_fiscal.id%type)
         return cidade.id%type; 
         
-------------------------------------------------------------------------------------------------------

-- Função retorna o id do país conforme o "Pais do tipo do código de arquivo" e "Tipo de Código de arquivo"

function fkg_pais_id_tipo_cod_arq ( ev_paistipocodarq_cd in pais_tipo_cod_arq.cd%type
                                  , ev_tipocodarq_cd     in tipo_cod_arq.cd%type
                                  , en_pais_id           in pais.id%type
                                  )
         return pais.id%type;
         
-------------------------------------------------------------------------------------------------------

-- Função retorna a inscrição municipal da pessoa

function fkg_inscr_mun_pessoa ( en_pessoa_id  in pessoa.id%TYPE )
         return juridica.im%type;         

-------------------------------------------------------------------------------------------------------

-- Função para descrever valores por extenso

function fkg_descValor_extenso(valor number)
  return varchar2;

-------------------------------------------------------------------------------------------------------

-- Função retorna TRUE se existe grupo de tributação do imposto ICMS ou FALSE caso não exista

function fkg_existe_imp_itemnficmsdest ( en_impitemnf_id in imp_itemnf_icms_dest.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------

-- Função recupera o "Código" do Enquadramento Legal do IPI conforme ID
function fkg_cd_enq_legal_ipi ( en_enqlegalipi_id in enq_legal_ipi.id%type )
         return enq_legal_ipi.cd%type;

-------------------------------------------------------------------------------------------------------

-- Função recupera o "ID" do Enquadramento Legal do IPI conforme Código
function fkg_id_enq_legal_ipi ( ev_enqlegalipi_cd in enq_legal_ipi.cd%type )
         return enq_legal_ipi.id%type;

-------------------------------------------------------------------------------------------------------

procedure pkb_cria_nat_oper( ev_cod_nat         nat_oper.cod_nat%type
                           , ev_descr_nat       nat_oper.descr_nat%type default null
                           , en_multorg_id      mult_org.id%type);

-----------------------------------------------------------------------------------------------------
--Retorna o DM_OBRIG_INTEGR do mult org informado. 1 - obrigatorio, 0 - não obrigatorio;

function fkg_multorg_obrig_integr (en_multorg_id    mult_org.id%type)
         return mult_org.DM_OBRIG_INTEGR%type;
         
-------------------------------------------------------------------------------------------------------
--Retorna o conteudo adicional referente a nota fiscal, atraves do id da mesma.
function fkg_info_adicionais (en_notafiscal_id in nota_fiscal.id%type)
         return varchar2;

-------------------------------------------------------------------------------------------------------
-- Função identifica se a data de vencimento do certificado está OK
function fkg_empr_dt_venc_cert_ok ( en_empresa_id in empresa.id%type )
         return boolean;

-------------------------------------------------------------------------------------------------------
--| Função retorna a data de vencimento do certificado
function fkg_empr_dt_venc_cert ( en_empresa_id in empresa.id%type )
         return date;

-------------------------------------------------------------------------------------------------------

--| Função retorno do "código do Cest" conforme ID
function fkg_cd_cest_id ( en_cest_id in cest.id%type )
         return cest.cd%type;

-------------------------------------------------------------------------------------------------------

--| Função retorno do "ID do Cest" conforme CD
function fkg_id_cest_cd ( ev_cest_cd in cest.cd%type )
         return cest.id%type;

-------------------------------------------------------------------------------------------------------
--| Função retorna do Valor do Parâmetro de Aguardar Liberação da NFe na Empresa

function fkg_empr_aguard_liber_nfe ( en_empresa_id in empresa.id%type )
         return empresa.dm_aguard_liber_nfe%type;

-------------------------------------------------------------------------------------------------------

--| Função retorna a Descrição do Pais conforme Siscomex

function fkg_Descr_Pais_siscomex ( ev_cod_siscomex  in Pais.cod_siscomex%TYPE )
         return Pais.descr%TYPE;

-------------------------------------------------------------------------------------------------------
--| Função que pega o valor da sequence
function fkg_vlr_sequence ( ev_sequence_name in seq_tab.sequence_name%type )
         return number;

-------------------------------------------------------------------------------------------------------
--| Função retorna o primeiro furo ID nos registros da tabela
function fkg_primeiro_furo_id ( ev_tabela    in varchar2
                              , ev_campo_id  in varchar2
                              )
         return number;

-------------------------------------------------------------------------------------------------------
--| Função retorna o proximo valor livre (Furo do ID) ou o valor da sequence
function fkg_vlr_livre_sequence ( ev_tabela         in varchar2
                                , ev_campo_id       in varchar2
                                , ev_sequence_name  in seq_tab.sequence_name%type
                                )
         return number;

-------------------------------------------------------------------------------------------------------
--| Função retorna o código indentificador da tabela ABERTURA_FCI
function fkg_aberturafci_id ( en_empresa_id in empresa.id%type
                            , ed_dt_ini in abertura_fci.dt_ini%type
                            ) return number;

-------------------------------------------------------------------------------------------------------
--| Função que retorna o código identificador da tabela ABERTURA_FCI_ARQ
function pk_aberturafciarq_id ( en_aberturafci_id in abertura_fci_arq.aberturafci_id%type
                              , en_nro_sequencia  in abertura_fci_arq.nro_sequencia%type
                              ) return abertura_fci_arq.id%type;
                              
----------------------------------------------------------------------------------------------------
--| Função que retorna o código identificador da tabela de Retorno_Fci
function fkg_infitemfci_id ( en_aberturafciarq_id in abertura_fci_arq.id%type
                           , en_item_id           in item.id%type
                           ) return inf_item_fci.id%type;

----------------------------------------------------------------------------------------------------
--| Função que retorna o código identificador da tabela de Retorno_Fci
function fkg_retornofci_id ( en_item_id       in item.id%type
                           , en_infitemfci_id in inf_item_fci.id%type
                           ) return retorno_fci.id%type;

----------------------------------------------------------------------------------------------------

--| Função de Retornar o ID do Regime Tributário
function fkg_id_reg_trib_cd ( ev_regtrib_cd in reg_trib.cd%type )
         return reg_trib.id%type;

----------------------------------------------------------------------------------------------------

--| Função de Retornar o CD do Regime Tributário
function fkg_cd_reg_trib_id ( en_regtrib_id in reg_trib.id%type )
         return reg_trib.cd%type;

----------------------------------------------------------------------------------------------------

--| Função retorna o CD da Forma de Tributação
function fkg_cd_forma_trib_id ( en_formatrib_id  in forma_trib.id%type )
         return forma_trib.cd%type;

----------------------------------------------------------------------------------------------------

--| Função retorna o ID da Forma de Tributação
function fkg_forma_trib_cd ( en_regtrib_id    in reg_trib.id%type
                           , ev_formatrib_cd  in forma_trib.cd%type
                           )
         return forma_trib.id%type;

----------------------------------------------------------------------------------------------------

--| Função retorna o ID da Incidencia Tributaria
function fkg_id_inc_trib_cd ( ev_inctrib_cd in inc_trib.cd%type )
         return inc_trib.id%type;

----------------------------------------------------------------------------------------------------

--| Função retorna o CD da Incidencia Tributaria
function fkg_cd_inc_trib_id ( en_inctrib_id in inc_trib.id%type )
         return inc_trib.cd%type;

-------------------------------------------------------------------------------------------------------

-- Função retor do ID da Mult-Organização conforme código e hash

function fkg_multorg_id ( ev_multorg_cd    in  mult_org.cd%type
                        , ev_multorg_hash  in  mult_org.hash%type
                        )
         return mult_org.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o CD da Mult-Organização conforme ID

function fkg_multorg_cd ( en_multorg_id in mult_org.id%type
                        )
         return mult_org.cd%type;

----------------------------------------------------------------------------------------------------
--| Função que retorna o código identificador da tabela de Cod_Nat_Pc
function fkg_codnatpc_id ( ev_cod_nat in cod_nat_pc.cod_nat%type
                         ) return cod_nat_pc.id%type;

----------------------------------------------------------------------------------------------------
--| Função que retorna o código da tabela de Cod_Nat_Pc
function fkg_codnatpcid_cod_nat ( en_codnatpc_id in cod_nat_pc.id%type 
                                ) return cod_nat_pc.id%type;

----------------------------------------------------------------------------------------------------
--| Função que retorna o código identificador da tabela de AGLUT_CONTABIL
function fkg_aglutcontabil_id ( en_empresa_id  in empresa.id%type
                              , ev_cod_agl     in aglut_contabil.cod_agl%type
                              ) return aglut_contabil.id%type;

----------------------------------------------------------------------------------------------------
--| Função que retorna o código da tabela de AGLUT_CONTABIL
function fkg_cd_aglutcontabil ( en_aglutcontabil_id  in aglut_contabil.id%type
                              ) return aglut_contabil.cod_agl%type;
                              
----------------------------------------------------------------------------------------------------
--| Função que retorna o código identificador da tabela de PC_AGLUT_CONTABIL
function fkg_pcaglutcontabil_id ( en_planoconta_id    in plano_conta.id%type
                                , en_aglutcontabil_id in aglut_contabil.id%type
                                , en_centrocusto_id   in centro_custo.id%type
                                ) return pc_aglut_contabil.id%TYPE;

----------------------------------------------------------------------------------------------------

-- Procedimento para retornar o Regime Tributário da Empresa e Forma de Tributação
procedure pkb_empresa_forma_trib ( en_empresa_id     in empresa.id%type
                                 , ed_dt_ref         in date
                                 , sn_regtrib_id     out reg_trib.id%type
                                 , sn_formatrib_id   out forma_trib.id%type
                                 );

----------------------------------------------------------------------------------------------------

-- Procedimento para retornar CNAE Primario da Empresa
function fkg_empresa_cnae_primario ( en_empresa_id     in empresa.id%type
                                   , ed_dt_ref         in date
                                   )
          return empresa_cnae.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Id de Auto-Relacionamento do "CNAE" conforme ID

function fkg_ar_cnae_id ( en_cnae_id in cnae.id%TYPE )
         return cnae.ar_cnae_id%type;

----------------------------------------------------------------------------------------------------

-- Função para retornar o Incidencia Tributária da Empresa
function fkg_empresa_inc_trib ( en_empresa_id     in empresa.id%type
                              , ed_dt_ref         in date
                              )
         return inc_trib.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o id do país conforme o codigo do "Pais do tipo do código de arquivo" e do "Tipo de Código de arquivo"
function fkg_pais_id_tipo_arq_cd ( ev_paistipocodarq_cd in pais_tipo_cod_arq.cd%type
                                 , ev_tipocodarq_cd     in tipo_cod_arq.cd%type
                                 )
         return pais.id%type;

----------------------------------------------------------------------------------------------------

-- Função para retornar o ID da informação sobre exportação com base na chave
function fkg_busca_infoexp_id ( ev_cpf_cnpj_emit   in   pessoa.cod_part%type
                              , en_dm_ind_doc      in   infor_exportacao.dm_ind_doc%type
                              , en_nro_de          in   infor_exportacao.nro_de%type
                              , ed_dt_de           in   infor_exportacao.dt_de%type
                              , en_nro_re          in   infor_exportacao.nro_re%type
                              , ev_chc_emb         in   infor_exportacao.chc_emb%type
                              , en_multorg_id      in   mult_org.id%type )
         return infor_exportacao.id%type;

----------------------------------------------------------------------------------------------------

-- Função para retornar o ID do documento da informação sobre exportação com base no item e na nota do documento
function fkg_busca_docinfoexp_id ( en_item_id              in   item.id%type
                                 , en_notafiscal_id        in   nota_fiscal.id%type
                                 , en_inforexportacao_id   in   infor_exportacao.id%type )
         return infor_export_nota_fiscal.id%type;

----------------------------------------------------------------------------------------------------

--| Função retorno o valor do Parâmetro Global
function fkg_vlr_param_global_csf ( ev_paramglobalcsf_cd in param_global_csf.cd%type )
         return param_global_csf.valor%type;

----------------------------------------------------------------------------------------------------

-- Função retorna se a Empresa Utiliza Unidade de Medida da Sefaz por NCM
function fkg_util_unidsefaz_conf_ncm ( en_empresa_id in empresa.id%type )
         return empresa.dm_util_unidsefaz_conf_ncm%type;

----------------------------------------------------------------------------------------------------

-- Função para retornar a Sigla da Unidade de Medida do Sefaz Conforme NCM e Período
function fkg_unidsefaz_conf_ncm ( en_ncm_id     in ncm.id%type
                                , ed_dt_ref     in date
                                )
         return unidade_sefaz.sigla_unid%type;

----------------------------------------------------------------------------------------------------

-- Função retorna o ID do NCM Supostamente Seperior

function fkg_ncm_id_superior ( ev_cod_ncm  in ncm.cod_ncm%type )
         return ncm.id%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto ISS - Parâmetro para Notas Fiscais com Emissão Propria

function fkg_empresa_vld_iss_epropria ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_iss_epropria%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento verifica se a empresa valida o imposto ISS - Parâmetro para Notas Fiscais com Emissão de Terceiros

function fkg_empresa_vld_iss_terc ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_iss_terc%type;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o ibge da cidade do emitente da nota fiscal
function fkg_cidadeibge_notafiscalemit ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal_emit.cidade_ibge%type;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o ibge da cidade do destinatário da nota fiscal
function fkg_cidadeibge_notafiscaldest ( en_notafiscal_id in nota_fiscal.id%type )
         return nota_fiscal_dest.cidade_ibge%type;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o ibge da cidade da pessoa do conhecimento de transporte
function fkg_cidadeibge_conhectransp ( en_conhectransp_id in conhec_transp.id%type )
         return cidade.ibge_cidade%type;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o ibge da cidade do destinatário do conhecimento de transporte
function fkg_cidadeibge_ct_dest ( en_conhectransp_id in conhec_transp.id%type )
         return conhec_transp_dest.ibge_cidade%type;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o ibge da cidade da pessoa da nota fiscal
function fkg_cidadeibge_notafiscalid ( en_notafiscal_id in nota_fiscal.id%type )
         return cidade.ibge_cidade%type;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o ibge do estado da pessoa da nota fiscal
function fkg_estadoibge_notafiscalid ( en_notafiscal_id in nota_fiscal.id%type )
         return estado.ibge_estado%type;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o ibge do estado do destinatário do conhecimento de transporte
function fkg_estadoibge_ct_dest ( en_conhectransp_id in conhec_transp.id%type )
         return estado.ibge_estado%type;

-------------------------------------------------------------------------------------------------------

-- Função para retornar o ibge do estado da pessoa do conhecimento de transporte
function fkg_estadoibge_conhectransp ( en_conhectransp_id in conhec_transp.id%type )
         return estado.ibge_estado%type;

-------------------------------------------------------------------------------------------------------

--| Função retorna verifica se a empresa Gera Informações de Tributações apenas para Venda
function fkg_empresa_inf_trib_op_venda ( en_empresa_id in empresa.id%type )
         return empresa.dm_inf_trib_oper_venda%type;

-------------------------------------------------------------------------------------------------------

FUNCTION fkg_limpa_acento2 ( ev_string            IN varchar2 )
         RETURN VARCHAR2;

-------------------------------------------------------------------------------------------------------

-- Função retorna o valor do campo Tipo da impressão dos Totais da Tributação

function fkg_tp_impr_tot_trib_empresa ( en_empresa_id in empresa.id%type )
         return empresa.dm_tp_impr_tot_trib%type;

-------------------------------------------------------------------------------------------------------

-- Função para Recuperar o Código do DIPAM-GIA

function fkg_dipamgia_id ( en_estado_id   in estado.id%type
                         , ev_cd_dipamgia in dipam_gia.cd%type
                         ) return dipam_gia.id%type;

-------------------------------------------------------------------------------------------------------

-- Função para Recuperar o Código da Tabela de Parametros do DIPAM-GIA

function fkg_paramdipamgia_id ( en_empresa_id  in empresa.id%type
                              , en_dipamgia_id in dipam_gia.id%type
                              , en_cfop_id     in cfop.id%type
                              , en_item_id     in item.id%type
                              , en_ncm_id      in ncm.id%type
                              ) return param_dipamgia.id%type;

-------------------------------------------------------------------------------------------------------

--| Processo que recupera o identificador do tipo do log pelo código(id)
function fkg_retorna_csftipolog_id(ev_cd in varchar2)
return number;
--

--------------------------------------------------------------------------------------------------------
--| FUNÇÃO QUE RECUPERA TODOS OS CÓDIGOS CFOP DE ITEM, PERTENCENTES A UMA NOTA FISCAL
--------------------------------------------------------------------------------------------------------
function fkg_recupera_cfop (en_notafiscal_id in number)
return varchar2;
--

--------------------------------------------------------------------------------------------------------
--| FUNÇÃO QUE RECUPERA CÓDIGO IDENTIFICADOR DO PROCESSO ADMINISTRATIVO - REINF
--------------------------------------------------------------------------------------------------------
function fkg_procadmefdreinf_id ( en_empresa_id in empresa.id%type
                                , ed_dt_ini     in date
                                , ed_dt_fin     in date
                                , en_dm_tp_proc in number
                                , ev_nro_proc   in varchar2
                                ) return proc_adm_efd_reinf.id%type;

--------------------------------------------------------------------------------------------------------
--| Função que verifica se o código identificador ja existe na tabela
function fkg_verif_procadmefdreinf ( en_procadmefdreinf_id in proc_adm_efd_reinf.id%type 
                                   ) return boolean;

--------------------------------------------------------------------------------------------------------
--| Recupera código identificador de Indicativo de Suspensão da Exigibilidade
function fkg_indsuspexig_id ( ev_ind_susp_exig in ind_susp_exig.cd%type
                            ) return ind_susp_exig.id%type;

--------------------------------------------------------------------------------------------------------
--| Função valida se o participante está cadastrado como empresa
function fkg_valida_part_empresa ( en_multorg_id  in mult_org.id%type
                                 , ev_cod_part    in pessoa.cod_part%TYPE
                                 ) return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna o indicador de atualização de dependências do Item na Integração de Cadastros Gerais - Item
function fkg_empr_dm_atual_dep_item ( en_empresa_id  in empresa.id%type )
         return empresa.dm_atual_dep_item%type;

-------------------------------------------------------------------------------------------------------
-- Recupera o id da fonte pagadora do REINF
function fkg_recup_fonte_pagad_reinf_id ( ev_cd_font_pag_reinf  in rel_fonte_pagad_reinf.cod%type )
         return rel_fonte_pagad_reinf.id%type;

-------------------------------------------------------------------------------------------------------
-- Recupera o código da fonte pagadora do REINF
function fkg_recup_fonte_pagad_reinf ( en_relfontepagadreinf_id  in rel_fonte_pagad_reinf.id%type )
         return rel_fonte_pagad_reinf.cod%type;

-------------------------------------------------------------------------------------------------------
-- Procedimento retorna o parâmetro que Permite a quebra da Informação Adicional no arquivo Sped Fiscal
function fkg_parefdicmsipi_dmqueinfadi ( en_empresa_id in empresa.id%type )
         return param_efd_icms_ipi.dm_quebra_infadic_spedf%type;

-------------------------------------------------------------------------------------------------------
-- Procedimento retorna o código NIF da pessoa
function fkg_cod_nif_pessoa ( en_pessoa_id in pessoa.id%type ) return pessoa.cod_nif%type;

-------------------------------------------------------------------------------------------------------
-- Procedimento retorna o se o país obriga o cod_nif p a pessoa_id
function fkg_pais_obrig_nif ( en_pais_id in pais.id%type ) return pais.dm_obrig_nif%type;

-------------------------------------------------------------------------------------------------------
-- Procedimento retorna a sigla do pais da pessoa_id
function fkg_sigla_pais ( en_pessoa_id in pessoa.id%type ) return pais.sigla_pais%type;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da tabela TIPO_RET_IMP_RECEITA
function fkg_tipo_ret_imp_rec ( en_cod_receita   in tipo_ret_imp_receita.cod_receita%TYPE
                              , en_tiporetimp_id in tipo_ret_imp_receita.tiporetimp_id%TYPE
                              ) return tipo_ret_imp_receita.id%TYPE;
--
-- ============================================================================================================= --
-- Função retorna o COD_RECEITA da tabela TIPO_RET_IMP_RECEITA
function fkg_tipo_ret_imp_rec_cd ( en_tiporetimpreceita_id in tipo_ret_imp_receita.id%TYPE
                                 , en_tiporetimp_id        in tipo_ret_imp_receita.tiporetimp_id%TYPE
                                 ) return tipo_ret_imp_receita.cod_receita%TYPE;
--
-- ============================================================================================================= --
-- Função retorna o valor do parametro dm_guarda_imp_orig
function fkg_empresa_guarda_imporig ( en_empresa_id in empresa.id%type ) return empresa.dm_guarda_imp_orig%type;
--
-- ============================================================================================================= --
-- Função verifica se a nota fiscal já possui os impostos originais salvos na tabela imp_itemnf_orig
function fkg_existe_nf_imp ( en_notafiscal_id in nota_fiscal.id%type ) return number;
--
-- ============================================================================================================= --
-- Função verifica se o imposto já foi inserido na tabela imp_itemnf
function fkg_existe_imp_itemnf ( en_itemnf_id  in imp_itemnf.itemnf_id%type
                               , en_tipoimp_id in imp_itemnf.tipoimp_id%type
                               , en_dm_tipo    in imp_itemnf.dm_tipo%type ) return number;
--
-- ============================================================================================================= --
-- Função buscar parâmetro do sistema (PARAM_GERAL_SISTEMA)
function fkg_ret_vl_param_geral_sistema ( en_multorg_id      in mult_org.id%type                        -- MultiOrganização - Obrigatório
                                        , en_empresa_id      in empresa.id%type                         -- Empresa - Opcional
                                        , en_modulo_id       in modulo_sistema.id%type                  -- Modulos do Sistema - Obrigatório
                                        , en_grupo_id        in grupo_sistema.id%type                   -- Grupo de Parâmetros por Modulo - Obrigatório
                                        , ev_param_name      in param_geral_sistema.param_name%type     -- Nome do Parâmetro - Obrigatório
                                        , sv_vlr_param      out param_geral_sistema.vlr_param%type      -- Valor do Parâmetro (saída)
                                        , sv_erro           out varchar2                                -- Mensagem de erro (return false)
                                        ) return boolean;
--
-- ============================================================================================================= --
-- Função para retornar o id do modulo do sistema
function fkg_ret_id_modulo_sistema ( ev_cod_modulo  in modulo_sistema.cod_modulo%type
                                   ) return number;
--
-- ============================================================================================================= --
-- Função para retornar o id do grupo do sistema
function fkg_ret_id_grupo_sistema ( en_modulo_id  in modulo_sistema.id%type
                                  , ev_cod_grupo  in grupo_sistema.cod_grupo%type
                                   ) return number;
--
-- ============================================================================================================= --
--
-- Função para retornar o valor do parâmetro do sistema, utilizando os parâmetros nome do módulo, nome do grupo e nome do parametro
function fkg_parametro_geral_sistema ( en_multorg_id   mult_org.id%type,
                                       en_empresa_id   empresa.id%type,  
                                       ev_cod_modulo   modulo_sistema.cod_modulo%type,
                                       ev_cod_grupo    grupo_sistema.cod_grupo%type,
                                       ev_param_name   param_geral_sistema.param_name%type) return param_geral_sistema.vlr_param%type;
--
-- ============================================================================================================= --
-- Procedimento verifica se a empresa valida o imposto PIS - Parâmetro para Notas Fiscais Servicos com Emissão Própria
function fkg_empresa_dmvalpis_emis_nfs ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_pis_emiss_nfs%type;
-- 
-- ============================================================================================================= --
-- Procedimento verifica se a empresa valida o imposto PIS - Parâmetro para Notas Fiscais Serviços com Emissão de Terceiros
function fkg_empresa_dmvalpis_terc_nfs ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_pis_terc_nfs%type; 
--
-- ============================================================================================================= --
-- Procedimento verifica se a empresa valida o imposto Cofins - Parâmetro para Notas Fiscais Serviços com Emissão Própria
function fkg_empr_dmvalcofins_emis_nfs ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_cofins_emiss_nfs%type;
--
-- ============================================================================================================= --
-- Procedimento verifica se a empresa valida o imposto Cofins - Parâmetro para Notas Fiscais Serviços com Emissão de Terceiros
function fkg_empr_dmvalcofins_terc_nfs ( en_empresa_id in Empresa.id%type )
         return empresa.dm_valida_cofins_terc_nfs%type;
--
-- ============================================================================================================= --
--Função retorna se Nota Fiscal foi submetido ao evento R-2010 do REINF ou não.
--E se o Conhecimento de tranporte está no dm_st_proc igual à 7 (Exclusão) do evento R-2010 do Reinf.
--
function fkg_existe_reinf_r2010_nf (en_notafiscal_id Nota_Fiscal.id%type) return boolean;
--
-- ============================================================================================================= --
--Função retorna se Nota Fiscal foi submetido ao evento R-2020 do REINF ou não. 
--E se o Conhecimento de tranporte está no dm_st_proc igual à 7 (Exclusão) do evento R-2020 do Reinf.
--
function fkg_existe_reinf_r2020_nf (en_notafiscal_id Nota_Fiscal.id%type) return boolean;
--
-- ============================================================================================================================== --
--
-- Procedure retorna dados da empresa
procedure pkb_ret_dados_empresa ( en_empresa_id         in empresa.id%type
                                , sv_nome              out pessoa.nome%type
                                , sn_dm_situacao       out empresa.dm_situacao%type
                                , sv_dados             out varchar2
                                , sn_sit_empresa       out number
                                , sn_dm_habil          out cidade_nfse.dm_habil%type
                                , sn_existe_id         out empresa.id%type
                                , sn_dm_tp_impr        out empresa.dm_tp_impr%type
                                , sn_dm_tp_amb         out empresa.dm_tp_amb%type
                                , sv_cnpj_cpf          out varchar2
                                , sv_cod_part          out pessoa.cod_part%type
                                , sv_im                out juridica.im%type
                                , sn_pessoa_id         out pessoa.id%type
                                , sv_ibge_cidade       out cidade.ibge_cidade%type
                                , sv_ibge_estado       out estado.ibge_estado%type );
--
-- ============================================================================================================================== --
--
-------------------------------------------------------------------------------------------------------
--| Função retorna o ID do Plano de Conta a partir da tab NAT_REC_PC
--
function fkg_natrecpc_plc_id ( en_natrecpc_id  in nat_rec_pc.id%TYPE )
         return nat_rec_pc.planoconta_id%TYPE;
--
-------------------------------------------------------------------------------------------------------
--| Função retorna o ID do Plano de Conta a partir da tab NCM_NAT_REC_PC
--
function fkg_ncmnatrecpc_plc_id ( en_natrecpc_id  in nat_rec_pc.id%TYPE,
                                  en_ncm_id       in ncm.id%TYPE )
         return ncm_nat_rec_pc.planoconta_id%TYPE;
--
-------------------------------------------------------------------------------------------------------
--| Função retorna o ID do Tabela NAT_PEC_PC a partir da tab NCM_NAT_REC_PC
--
function fkg_ncmnatrecpc_npp_id (en_planoconta_id in nat_rec_pc.planoconta_id%TYPE)
                 return PLANO_CONTA_NAT_REC_PC.NATRECPC_ID%type;
--
-------------------------------------------------------------------------------------------------------
--| Função retorna o ID do Tabela NAT_PEC_PC a partir dos parametros planoconta_id e codst_id 
--
function fkg_natrecpc_id (en_planoconta_id in nat_rec_pc.planoconta_id%TYPE,
                          en_codst_id      in nat_rec_pc.codst_id%TYPE) 
                          return nat_rec_pc.id%type;
--
-------------------------------------------------------------------------------------------------------
--| Função retorna o primeiro ID do plano de conta do Tabela NAT_PEC_PC
--
function fkg_plcnatpecpc_plc_id ( en_natrecpc_id  in nat_rec_pc.id%TYPE)
                             return plano_conta_nat_rec_pc.planoconta_id%type;
--
-------------------------------------------------------------------------------------------------------
--| Função retorna o ID da Tabela COD_ST_CIDADE
--
function fkg_codstcidade_Id (ev_cod_st    in  cod_st_cidade.cod_st%TYPE,
                             en_cidade_id in  cod_st_cidade.cidade_id%TYPE)
                             return cod_st_cidade.id%type;
-------------------------------------------------------------------------------------------------------
--| Procedure para criação de sequence e inclusão na seq_tab
--
procedure pkb_cria_sequence (ev_sequence_name varchar2,
                             ev_table_name    varchar2);

-------------------------------------------------------------------------------------------------------
--| Procedure para criação de domínio
--
procedure pkb_cria_dominio (ev_dominio    varchar2,
                            ev_valor      varchar2,
                            ev_descricao  varchar2);
--
end pk_csf;
/
