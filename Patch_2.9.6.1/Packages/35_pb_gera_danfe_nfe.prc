create or replace procedure csf_own.pb_gera_danfe_nfe ( en_notafiscal_id in nota_fiscal.id%type )
is
--
-- Em 22/12/2020 - Luiz Armando
-- Redmine 74096 - Adicionado update no final da procedure verificando se alguma nf ficou travada com o 
--                 campo nota_fiscal.dm_impressa = 6. Se ficou será alterado para nota_fiscal.dm_impressa = 0 e nota_fiscal.ro_tentativas_impr = 0
--                 para que jar de impressão possa reprocessar a impressão desta nota fiscal.
--
-- Em 12/08/2020 - Luis Henrique
-- Redmine #70375 - Falha na integração "E" comercial - WEBSERVICE NFE EMISSAO PROPRIA - DANFE (OCQ).
-- Incluido no fkg_converte parametros para manter o "E" comercial na variável "vv_emitenterazaosocial" que é
-- utilizada na tabela "impr_cab_nfe" utilizada na emissão do DANFE.
--
-- Em 06/07/2020 - Allan Magrini
-- Redmine #65449 - Remoção de caracteres especiais.
-- Inclusão na fase 45 de validação do tipo de nota para liberar o caracter, pk_csf.fkg_converte(rec_item.descricao,0,1,3,1,1,1).
--
-- Em 10/06/2020 - Allan Magrini
-- Redmine #68468 - Não está gravando na DANFE os caracteres especiais
-- Inclusão na fase 45 de validação do tipo de nota para liberar o caracter, pk_csf.fkg_converte(rec_item.descricao,0,1,2,1,1,1).
--
-- Em 13/11/2019 - Luiz Armando Azoni
-- Redmine #61800 - Adequação na geração do danfe adicionando no campo reservado ao fisco dados da nota fiscal premiada do estado MS
--
-- Em 20/11/2019 - Eduardo Linden
-- Redmine #61466 - vincular empresa_id no log do DANFE
-- Inclusão do empresa_id no log de geração do DANFE e mudança do preeenchimento dos campos mensagem e resumo.
--
-- Em 20/11/2019 - Eduardo Linden
-- Redmine #61412 - Inclusão de log informando a geração do DANFE
-- Inclusão de Log informação da geração do DANFE e comentario sobre count na tabela impr_item_nfe
-- que impedia a geração do DANFE em caso de problema.
--
-- Em 14/06/2019 - Luiz Armando Azoni
-- Redmine #55463 - CORTANDO O 0 A ESQUERDA DO CAMPO CEP
-- Adequando a query que recupera o cep do destinatário, se a UF do destinatário for EX e o cep não for nulo, completar com zero a esquerda até 8 posições.
--
-- Em 05/11/2014 - Rogério Silva
-- Redmine #4994 - Ajuste na procedure de geração das informações do danfe
--
-- Em 17/11/2014 - Rogério Silva
-- Redmine #5231 - Alteração no processo de geração do danfe - EPEC
--
-- Em 26/11/2014 - Rogério Silva
-- Redmine #5323 - Correção na geração da DANFE
--
-- Em 19/02/2015 - Rogério Silva
-- Redmine #6446 - Nro de protocolo não está aparecendo na impressão de DANFE's em EPEC
-- Alterado para recuperar o número do protocolo e data da autorização na tabela ret_evento_epec
-- somente quando existir, caso contrário, recuperar da nota_fiscal.
--
-- Em 09/04/2015 - Leandro Savenhago
-- Redmine #7561 - Falha impressão telefone DANFE (CREMER)
-- Implementado da impressão do número de celular com 5 digitos no sufixo
--
-- Em 30/06/2015 - Rogério Silva.
-- Redmine #9335 -  Ao reenviar uma nota em EPEC, está ficando com o nro de protocolo nulo
--
-- Em 21/07/2015 - Angela Inês.
-- Redmine #10168 - Limpar os acentos da descrição dos itens.
--
-- Em 06/10/2015 - Rogério Silva.
-- Redmine #12028 - Problemas pb_gera_danfe_nfe fase(2)
--
-- Em 08/02/2016 - Fábio Tavares.
-- Redmine #14991 - Implementação da impressão do Código do CEST na DANFE.
--
-- Em 13/04/2016 - Fábio Tavares
-- Redmine #17584, #17583 - Inclusão dos parametros do CEST e FCI.
--
-- Em 13/05/2016 - Angela Inês.
-- Redmine #18893 - Geração da DANFE - Informações Adicionais.
-- Considerar o espaço (' ') antes do valor de Informação Adicional somente se houver valor no campo.
--
-- Em 01/06/2016 - Angela Inês.
-- Redmine #19668 - Corrigir o processo de geração dos dados para emissão da DANFE - Itens da Nota Fiscal.
-- O campo/variável que armazena os dados de Informações Adicionais do Produto, para gerar a tabela temporária (impr_item_nfe.infadprod), deve ser inicializado
-- a cada item de nota.
--
-- Em 11/01/2017 - Angela Inês.
-- Redmine #27201 - Alterar o processo de recuperação de dados para Impressão da DANFE.
-- Alterar o processo de geração da DANFE verificando antes da inclusão dos registros se os mesmos já não existem no processo. Ficando para a tabela
-- IMPR_CAB_NFE e a coluna NOTAFISCAL_ID; para a tabela IMPR_ITEM_NFE e as colunas IMPRCABNFE_ID/NOTAFISCAL_ID/ITEMNF_ID; e, para a tabela IMPR_INF_NF_ROMANEIO
-- e as colunas IMPRCABNFE_ID/NOTAFISCAL_ID/INFNFROMANEIO_ID.
--
-- Em 09/03/2017 - Fábio Tavares
-- Redmine #28949 - Impressão de Local de Retirada e Local de Entrega na Nota Fiscal Mercantil.
--
-- Em 04/05/2017 - Angela Inês.
-- Redmine #30667 - Erro na Emissão de NFe.
-- Temos o parâmetro dm_tp_impr_tot_trib - que trabalha a informação complementar conforme o "tipo de impressão" - Início da mensagem com as Informações
-- Adicionais - Sim ou Não. No processo de montagem da DANFE, quando o parâmetro indica que deve iniciar a mensagem com as Informações Adicionais (1-Sim),
-- não estava sendo utilizado um separador para a próxima informação. Foi incluído uma '/' para essa situação.
--
-- Em 01/06/2017 - Angela Inês.
-- Redmine #31594 - Alterar o processo de montagem de Informações Complementares - DANFE.
-- Tirar o comando ENTER (CHR), da montagem do campo Informações Complementares, e incluir um espaço (' ').
-- Portanto no início da mensagem não teremos uma linha em branco.
-- Variável: vv_inf_compl.
--
-- Em 06/06/2017 - Angela Inês.
-- Redmine #31734 - Geração de registros na tabela IMPR_CAB_NFE.
-- As informações referem -se ao uso da fonte com tamanho igual a 6 ou 12 e formato da impressão igual à RETRATO e PAISAGEM:
-- PAISAGEM - 565 CARACTERES, SEM QUEBRA DE LINHA - (SUPORTA APENAS FONTE TAMANHO 6)
-- RETRATO FONTE 12 - 616 CARACTERES;
-- Rotina: vn_fase=26, variável vn_qtde_carac_inf_compl.
--
-- Em 20/09/2017 - Marcos Garcia
-- Redmine #34673 - OCULTAR FORMATAÇÃO CDATA NO DANFE
-- Feito o tratamento para retirar a tag de troca de informações que vem do cliente
-- no campo de descrição do produto.
--
-- Em 27/09/2017 - Angela Inês.
-- Redmine #35058 - Alterar a mensagem que indica o motivo da DANFE não ser gerada/impressa.
-- Alterar a mensagem de: "Geração da DANFE - NFe (id=127758403) não pode ser impressa."; para: "Geração da DANFE - NFe (id=127758403) não pode ser impressa
-- devido a situação não ser 4-Autorizada ou 14-Sefaz em contingência. A situação da NFe neste momento é ||nota_fiscal.dm_st_proc||.".
-- Rotina: fase 10.
--
-- Em 28/09/2017 - Angela Inês.
-- Redmine #35090 - Mensagem detalhada errada.
-- Eliminar a utilização das variáveis globais (pk_csf_api), e substituir por variáveis locais, devido a interferência de processos.
--
-- Em 06/10/2017 - Angela Inês.
-- Redmine #35295 - Correção na geração da Informação Adicional para DANFE.
-- 1) Executar o processo que eliminar as informações da "tag CDATA", somente se houver a "tag CDATA".
--
-- Em 09/10/2017 - Angela Inês.
-- Redmine #35312 - Correção na geração da DANFE - Informações Adicionais.
-- Ao identificar se a informação adicional possui Tag CDATA, o processo altera a informação para eliminar essa Tag, porém se a informação não possui a Tag, o
-- campo que recebe a informação não está sendo atualizado. Corrigir o processo para recuperar a informação quando a Tag CDATA não existir.
--
-- Em 22/11/2017 - Angela Inês.
-- Redmine #36766 - Inclusão das informações de medicamento nas Informações Complementares de Impostos do Item - DANFE.
-- Incluir as informações "itemnf_med.nro_lote/qtde_lote/dt_fabr/dt_valid", em informações adicionais do item utilizado na impressão da DANFE
-- (impr_item_nfe.infadprod), desde que o parâmetro da empresa indique que as informações de medicamento devem ser concatenadas.
-- Foram feitas algumas correções técnicas para melhorar a performance do processo (substituir as funções/pk_csf que recuperavam valores da tabela EMPRESA
-- pelo SELECT/EMPRESA já existente no processo).
--
-- Em 04/04/2018 - Marcos Ferreira
-- Redmine #41110 - Falha na impressão da Alíquota ICMS no DANFE.
-- Se for Desoneração de ICMS, checar também se o Percentual de Redução é zero para daí zerar a base do icms, valor do icms e aliquota do icms
--
-- Em 17/04/2018 - Angela Inês.
-- Redmine #41703 - Impressão de informações de ICMS no danfe.
-- Atualizar o processo no patch 282-6.
-- Atividade atendida através do redmine #41109 que foi liberado na release 284 e patch 283-2.
-- Se for Desoneração de ICMS, checar também se o Percentual de Redução é zero para zerar a base do ICMS, valor do ICMS e alíquota do ICMS.
-- Redmine #41800 - Demonstrar Total de Pis e Cofins em Danfe.
-- Criar as colunas VALORPIS e VALORCOFINS, varchar2(20), na tabela IMPR_CAB_NFE.
-- Os valores serão recuperados dos totais da nota fiscal, NOTA_FISCAL_TOTAL, colunas VL_IMP_TRIB_PIS e VL_IMP_TRIB_COFINS.
--
-- Em 26/07/2018 - Angela Inês.
-- Redmine #45214 - Geração da DANFE Adicionar as informações referente ao Nro_Fatura no quadro Fatura do pdf.
-- Foi criado um parâmetro interno para ser utilizado na função que recupera as faturas e suas parcelas. Será considerado a montagem do Número da Fatura.
--
-- Em 24/08/2018 - Karina de Paula
-- Redmine #46316 - Defeito #46316 - Incluir tratamento com trim nos valores retornados da tabela nota_fiscal_total
-- Rotina Alterada: Rotina que retorna os dados de totais da NFe - Incluído rtrim e ltrim no tratamento dos campos
--
-- Em 03/09/2018 - Angela Inês.
-- Redmine #46571 - Correção indevida no processo de geração da DANFE.
-- Para os dados de Transportadora, o valor referente a Quantidade de Volume, não deve possuir máscara indicando casas decimais, pois o campo é inteiro; os
-- campos de Peso Líquido e Peso Bruto já possuem máscara com as casas decimais no cursor, porém ao atribuir os valores para os campos da DANFE, novamente
-- estamos atribuindo máscara, e essa atribuição está incorreta. Os valores foram corrigidos mantendo o campo Quantidade de Volume como está, e a atribuição de
-- máscara somente no cursor que recupera os campos de Valor Bruto e Valor Líquido.
-- Rotinas: cursor c_transp e select nota_fiscal_total.
--
-- Em 24/08/2018 - Karina de Paula
-- Redmine #46520 - DANFE não está trazendo os valores do campo ESPÉCIE da NFE quando valores são duplicados.
-- Rotinas: cursor c_transp retirado tratamento decode q impedia de trazer as descrições
--
-- ==============================================================================================================================================
   --
   -- variáveis cabeçalho NFe
   vn_imprcabnfe_id                impr_cab_nfe.id%type := null;
   vv_numeronfe                    impr_cab_nfe.numeronfe%type := null;
   vv_serienfe                     impr_cab_nfe.serienfe%type := null;
   vv_saidaentrada                 impr_cab_nfe.saidaentrada%type := null;
   vv_chaveacesso                  impr_cab_nfe.chaveacesso%type := null;
   vv_datasaidaentrada             impr_cab_nfe.datasaidaentrada%type := null;
   vv_horasaida                    impr_cab_nfe.horasaida%type := null;
   vv_dataemissao                  impr_cab_nfe.dataemissao%type := null;
   vv_naturezaoperacao             impr_cab_nfe.naturezaoperacao%type := null;
   vv_naturezaoperacao_tmp         varchar2(100);
   vv_emitentecnpj                 impr_cab_nfe.emitentecnpj%type := null;
   vv_emitenterazaosocial          impr_cab_nfe.emitenterazaosocial%type := null;
   vv_emitenterazaosocial_tmp      varchar2(100);
   vv_emitenteendereco             impr_cab_nfe.emitenteendereco%type := null;
   vv_emitentebairro               impr_cab_nfe.emitentebairro%type := null;
   vv_emitentemunicipio            impr_cab_nfe.emitentemunicipio%type := null;
   vv_emitenteuf                   impr_cab_nfe.emitenteuf%type := null;
   vv_emitentecep                  impr_cab_nfe.emitentecep%type := null;
   vv_emitentetelefone             impr_cab_nfe.emitentetelefone%type := null;
   vv_emitenteinscricaoestadual    impr_cab_nfe.emitenteinscricaoestadual%type := null;
   vv_emitenteInscricaoEstSub      impr_cab_nfe.emitenteInscricaoEstadualSub%type := null;
   vv_inscricaomunicipal           impr_cab_nfe.inscricaomunicipal%type := null;
   vv_destinatariocnpjcpf          impr_cab_nfe.destinatariocnpjcpf%type := null;
   vv_destinatariorazaosocial      impr_cab_nfe.destinatariorazaosocial%type := null;
   vv_destinatariorazaosocial_tmp  varchar2(100) := null;
   vv_destinatarioendereco         impr_cab_nfe.destinatarioendereco%type := null;
   vv_destinatariobairro           impr_cab_nfe.destinatariobairro%type := null;
   vv_destinatariomunicipio        impr_cab_nfe.destinatariomunicipio%type := null;
   vv_destinatariouf               impr_cab_nfe.destinatariouf%type := null;
   vv_destinatariocep              impr_cab_nfe.destinatariocep%type := null;
   vv_destinatariofonefax          impr_cab_nfe.destinatariofonefax%type := null;
   vv_destinatarioinscricaoest     impr_cab_nfe.destinatarioinscricaoestadual%type := null;
   vv_fatura                       impr_cab_nfe.fatura%type := null;
   vv_baseicms                     impr_cab_nfe.baseicms%type := null;
   vv_valoricms                    impr_cab_nfe.valoricms%type := null;
   vv_baseicmssubstituicao         impr_cab_nfe.baseicmssubstituicao%type := null;
   vv_valoricmssubstituicao        impr_cab_nfe.valoricmssubstituicao%type := null;
   vv_valortotalproduto            impr_cab_nfe.valortotalproduto%type := null;
   vv_valorfrete                   impr_cab_nfe.valorfrete%type := null;
   vv_valorseguro                  impr_cab_nfe.valorseguro%type := null;
   vv_desconto                     impr_cab_nfe.desconto%type := null;
   vv_valoripi                     impr_cab_nfe.valoripi%type := null;
   vv_outrasdespesas               impr_cab_nfe.outrasdespesas%type := null;
   vv_valortotalnota               impr_cab_nfe.valortotalnota%type := null;
   vv_valortotalservicos           impr_cab_nfe.valortotalservicos%type := null;
   vv_baseissqn                    impr_cab_nfe.baseissqn%type := null;
   vv_valorissqn                   impr_cab_nfe.valorissqn%type := null;
   vv_transportadorcnpjcpf         impr_cab_nfe.transportadorcnpjcpf%type := null;
   vv_transportadorfreteporconta   impr_cab_nfe.transportadorfreteporconta%type := null;
   vv_transportadorrazaosocial     impr_cab_nfe.transportadorrazaosocial%type := null;
   vv_transportadorrazaosoc_tmp    varchar2(100);
   vv_transportadorinscricaoest    impr_cab_nfe.transportadorinscricaoestadual%type := null;
   vv_transportadorendereco        impr_cab_nfe.transportadorendereco%type := null;
   vv_transportadormunicipio       impr_cab_nfe.transportadormunicipio%type := null;
   vv_transportadoruf              impr_cab_nfe.transportadoruf%type := null;
   vv_transportadorplacaveiculo    impr_cab_nfe.transportadorplacaveiculo%type := null;
   vv_transportadorufveiculo       impr_cab_nfe.transportadorufveiculo%type := null;
   vv_transportadorcodigoantt      impr_cab_nfe.transportadorcodigoantt%type := null;
   vv_informacoescomplementares    impr_cab_nfe.informacoescomplementares%type := null;
   vv_informacoescomplementares2   impr_cab_nfe.informacoescomplementares2%type := null;
   vv_inf_compl                    varchar2(32767) := null;
   vv_nroprotocolo                 impr_cab_nfe.nroprotocolo%type := null;
   vv_dtautorizacao                impr_cab_nfe.dtautorizacao%type := null;
   vv_nroprotocolo_epec            impr_cab_nfe.nroprotocolo%type := null;
   vv_dtautorizacao_epec           impr_cab_nfe.dtautorizacao%type := null;
   vv_transportadorquantidade      impr_cab_nfe.transportadorquantidade%type := null;
   vv_transportadorespecie         impr_cab_nfe.transportadorespecie%type := null;
   vv_transportadormarca           impr_cab_nfe.transportadormarca%type := null;
   vv_transportadornumeracao       impr_cab_nfe.transportadornumeracao%type := null;
   vv_transportadorpesobruto       impr_cab_nfe.transportadorpesobruto%type := null;
   vv_transportadorpesoliquido     impr_cab_nfe.transportadorpesoliquido%type := null;
   vv_pedidocompra                 impr_cab_nfe.pedidocompra%type := null;
   vv_vltottrib                    impr_cab_nfe.vltottrib%type := null;
   vv_valorpis                     impr_cab_nfe.valorpis%type := null;
   vv_valorcofins                  impr_cab_nfe.valorcofins%type := null;
   --
   -- variáveis item NFe
   vn_impritemnfe_id               impr_item_nfe.id%type := null;
   vn_itemnf_id                    impr_item_nfe.itemnf_id%type := null;
   vn_nro_item                     impr_item_nfe.nro_item%type := null;
   vv_infadprod                    varchar2(4000) := null;
   vv_codigo                       impr_item_nfe.codigo%type := null;
   vv_descricao                    impr_item_nfe.descricao%type := null;
   vv_ncm                          impr_item_nfe.ncm%type := null;
   vv_cst                          impr_item_nfe.cst%type := null;
   vv_cst_sn                       impr_item_nfe.cst%type := null;
   vv_cfop                         impr_item_nfe.cfop%type := null;
   vv_unidade                      impr_item_nfe.unidade%type := null;
   vv_quantidade                   impr_item_nfe.quantidade%type := null;
   vv_valorunitario                impr_item_nfe.valorunitario%type := null;
   vv_valortotal_item              impr_item_nfe.valortotal%type := null;
   vv_baseicms_item                impr_item_nfe.baseicms%type := null;
   vv_valoricms_item               impr_item_nfe.valoricms%type := null;
   vv_baseicmsst_item              impr_item_nfe.baseicmsst%type := null;
   vv_valoricmsst_item             impr_item_nfe.valoricmsst%type := null;
   vv_valoripi_item                impr_item_nfe.valoripi%type := null;
   vv_aliquotaicms_item            impr_item_nfe.aliquotaicms%type := null;
   vv_perc_reduc                   imp_itemnf.perc_reduc%type := null;
   vv_aliquotaipi_item             impr_item_nfe.aliquotaipi%type := null;
   vv_vldescontoitem               impr_item_nfe.vldescontoitem%type := null;
   --
   vn_empresa_id                   empresa.id%type := null;
   vn_qtde_item                    number := 0;
   vn_dm_forma_emiss               nota_fiscal.dm_forma_emiss%type;
   vn_dm_tp_impr                   nota_fiscal.dm_tp_impr%type;
   --
   vn_codmensagem                  nota_fiscal.cod_mensagem%type := null;
   vv_msgsefaz                     nota_fiscal.msg_sefaz%type := null;
   VV_UFMS                         ESTADO.ID%TYPE;
   VV_UFIBEGEMIT                   NOTA_FISCAL.UF_IBGE_EMIT%TYPE;
   --
   vv_dm_ind_emit                  nota_fiscal.dm_ind_emit%type := null;
   vv_dm_ind_oper                  nota_fiscal.dm_ind_oper%type := null;
   vv_dm_arm_nfe_terc              nota_fiscal.dm_arm_nfe_terc%type := null;
   --
   vn_dm_ord_impr_item_danfe       empresa.dm_ord_impr_item_danfe%type := null;
   vn_nro_casa_dec_vl_unit_nfe     empresa.nro_casa_dec_vl_unit_nfe%type := 2;
   vn_dm_tam_fonte_danfe           empresa.dm_tam_fonte_danfe%type := null;
   vn_dm_quebra_infadic_nfe        empresa.dm_quebra_infadic_nfe%type := 0;
   vn_dm_impr_danfe_fci            empresa.dm_impr_danfe_fci%type;
   vn_dm_impr_danfe_cest           empresa.dm_impr_danfe_cest%type;
   vn_dm_impr_end_entr_nfe         empresa.dm_impr_end_entr_nfe%type := null;
   vn_dm_impr_end_retir_nfe        empresa.dm_impr_end_retir_nfe%type := null;
   vn_dm_tp_impr_tot_trib          empresa.dm_tp_impr_tot_trib%type;
   vn_dm_descr_item_med            empresa.dm_descr_item_med%type;
   --
   vv_inf_fisco                    nfinfor_adic.conteudo%type := null;
   vv_inf_contr                    nfinfor_adic.conteudo%type := null;
   vn_dm_st_proc                   nota_fiscal.dm_st_proc%type := null;
   vn_vl_acm_tot_trib              nota_fiscal_total.vl_tot_trib%type;
   vv_msg_vl_aprox_trib            varchar2(255) := null;
   vv_inf_cpl_imp                  nota_fiscal.inf_cpl_imp%type;
   vv_inf_cpl_imp_item             item_nota_fiscal.inf_cpl_imp_item%type;
   vn_qtde_carac_inf_compl         number := 0;
   vv_cod_cest                     cest.cd%type := null;
   vn_imprinfnfromaneio_id         impr_inf_nf_romaneio.id%type;
   vv_infor_med                    varchar2(255) := null;
   --
   vn_fase                         number := 0;
   vn_loggenerico_id               log_generico_nf.id%type;
   vt_log_generico_nf              dbms_sql.number_table;
   vv_end_entr_retir               varchar2(4000) := null; -- endereço de entrega
   vv_mensagem_log                 log_generico_nf.mensagem%type;
   erro_de_sistema                 constant number := 2;
   informacao                      constant number := 35;
   --
   cursor c_item1 (en_notafiscal_id nota_fiscal.id%type) is
   select inf.nro_item
        , inf.id                        itemnf_id
        , inf.infadprod                 infAdProd            -- Informações adicionais do produto
        , inf.cod_item                  codigo               -- Cód. Prod. *
        , inf.descr_item                descricao            -- Descrição do Produto/Serviço *
        , inf.cod_ncm                   ncm                  -- NCM/SH *
        , nvl(inf.orig, 0)              origem
        , ltrim(rtrim(to_char(inf.cfop,'9999'))) cfop  -- CFOP *
        , inf.Unid_Com            unidade              -- Unidade *
        , ltrim(rtrim(to_char(inf.qtde_Comerc,'99999999990d0000'))) quantidade     -- Quantidade *
        , inf.vl_Unit_Comerc  valorUnitario  -- V. Unitário *
        , ltrim(rtrim(to_char(inf.vl_Item_Bruto,'999g999g999g990d00'))) valorTotal     -- V. Total *
        , inf.dm_mot_des_icms
        , inf.vl_tot_trib_item
        , ltrim(rtrim(to_char(inf.vl_desc,'999g999g999g990d00'))) vldescontoitem
        , inf.inf_cpl_imp_item
        , inf.cod_cest
        , inf.nro_fci
     from Item_Nota_Fiscal     inf
    where inf.notafiscal_id  = en_notafiscal_id
    order by 1;
   --
   cursor c_item2 (en_notafiscal_id nota_fiscal.id%type) is
   select inf.nro_item
        , inf.id                        itemnf_id
        , inf.infadprod                 infAdProd            -- Informações adicionais do produto
        , inf.cod_item                  codigo               -- Cód. Prod. *
        , inf.descr_item                descricao            -- Descrição do Produto/Serviço *
        , inf.cod_ncm                   ncm                  -- NCM/SH *
        , nvl(inf.orig, 0)              origem
        , ltrim(rtrim(to_char(inf.cfop,'9999'))) cfop  -- CFOP *
        , inf.Unid_Com            unidade              -- Unidade *
        , ltrim(rtrim(to_char(inf.qtde_Comerc,'99999999990d0000')))         quantidade     -- Quantidade *
        , inf.vl_Unit_Comerc  valorUnitario  -- V. Unitário *
        , ltrim(rtrim(to_char(inf.vl_Item_Bruto,'999g999g999g990d00')))     valorTotal     -- V. Total *
        , inf.dm_mot_des_icms
        , inf.vl_tot_trib_item
        , ltrim(rtrim(to_char(inf.vl_desc,'999g999g999g990d00'))) vldescontoitem
        , inf.inf_cpl_imp_item
        , inf.cod_cest
        , inf.nro_fci
     from Item_Nota_Fiscal     inf
    where inf.notafiscal_id  = en_notafiscal_id
    order by decode(vn_dm_ord_impr_item_danfe, 1, to_char(inf.nro_item), 2, inf.cod_item, 3, inf.descr_item, to_char(inf.nro_item));
   --
   rec_item1 c_item1%rowtype;
   rec_item2 c_item2%rowtype;
   rec_item  c_item2%rowtype;
   --
   cursor c_infnfrom (en_notafiscal_id nota_fiscal.id%type) is
   select id      infnfromaneio_id
        , cnpj_cpf
        , substr(trim(to_char(nro_nf,'000000000')),1,3) || '.'  ||
          substr(trim(to_char(nro_nf,'000000000')),4,3) || '.'  ||
          substr(trim(to_char(nro_nf,'000000000')),7,3) nro_nf
        , serie
        , to_char(dt_emiss, 'dd/mm/yyyy') dt_emiss
     from inf_nf_romaneio
    where notafiscal_id = en_notafiscal_id
    order by id;
   --
   cursor c_transp is
      select qVol  qVol
           , esp   esp
           , marca marca
           , nVol  nVol
           , trim(to_char(pesoL, '999g999g999g990d000')) pesoL
           , trim(to_char(pesoB, '999g999g999g990d000')) pesoB
        from ( select nftvol.especie             esp           -- Espécie
                    , nftvol.marca               marca         -- Marca
                    , nftvol.nro_vol             nVol          -- Númeração
                    , sum(nftvol.qtdeVol)        qVol          -- Quantidade
                    , sum(nftvol.peso_liq)       pesoL         -- Peso Líquido
                    , sum(nftvol.peso_bruto)     pesoB         -- Pedo Bruto
                 from Nota_Fiscal_Transp    nft
                    , NFTransp_Vol          nftvol
                where nft.notafiscal_id           = en_notafiscal_id
                  and nftvol.nftransp_id          = nft.id
                  and ( nftvol.especie            is not null
                     or nftvol.marca              is not null
                     or nftvol.nro_vol            is not null
                     or nvl(nftvol.qtdevol, 0)    > 0
                     or nvl(nftvol.peso_liq,0)    > 0
                     or nvl(nftvol.peso_bruto,0)  > 0 )
               group by nftvol.especie
                      , nftvol.marca
                      , nftvol.nro_vol );
   --
   cursor c_med (en_itemnf_id item_nota_fiscal.id%type) is
      select 'NRO_LOTE: '||im.nro_lote||
             ' QTDE_LOTE: '||trim(to_char(im.qtde_lote,'999G999G990D000'))||
             ' DT_FABR: '||to_char(trunc(im.dt_fabr),'dd/mm/rrrr')||
             ' DT_VALID: '||to_char(trunc(im.dt_valid),'dd/mm/rrrr') infor_med
        from itemnf_med im
       where im.itemnf_id = en_itemnf_id;
   --
   function fkg_exite_notafiscal_id ( en_notafiscal_id  in nota_fiscal.id%type )
            return boolean
   is
      --
      vn_dummy number := 0;
      --
   begin
      --
      select count(1)
        into vn_dummy
        from nota_fiscal nf
       where nf.id = en_notafiscal_id;
      --
      if nvl(vn_dummy,0) > 0 then
         return true;
      else
         return false;
      end if;
      --
   exception
      when no_data_found then
         return false;
      when others then
         raise_application_error (-20101, 'Erro na fkg_exite_notafiscal_id: ' || sqlerrm);
   end fkg_exite_notafiscal_id;
   --
   pragma autonomous_transaction;
   --
begin
   --
   vn_fase := 1;
   vv_mensagem_log:=null;
   --
   if fkg_exite_notafiscal_id ( en_notafiscal_id => en_notafiscal_id ) = true then
      --
      vn_fase := 2;
      --
/*    Foi comentado este trecho, porque isto impede a geração corretiva do DANFE em caso de problema com a nota.
      Outro motivo, há uma exclusão na impr_item_nfe considerando o id da nota fiscal. Com trecho abaixo sem comentario,
      o delete não faz sentido.*/
      --
     /* begin
	 select count(1) qtde
	   into vn_qtde_item
	   from impr_item_nfe
	  where notafiscal_id = en_notafiscal_id;
      exception
         when others then
	    vn_qtde_item := 0;
      end;
      --
      if nvl(vn_qtde_item,0) > 0 then
         return;
      end if;   */
      --
      vn_fase := 3;
      -- Exclui os registros antigos
      delete from impr_item_nfe where notafiscal_id = en_notafiscal_id;
      --
      vn_fase := 4;
      --
      delete from impr_inf_nf_romaneio where notafiscal_id = en_notafiscal_id;
      --
      vn_fase := 5;
      --
      delete from impr_cab_nfe where notafiscal_id = en_notafiscal_id;
      --
      commit;
      --
      vn_fase := 6;
      -- Busca os dados da nota fiscal
      begin
         --
         select substr(trim(to_char(nf.nro_nf,'000000000')),1,3) || '.'  ||
                substr(trim(to_char(nf.nro_nf,'000000000')),4,3) || '.'  ||
                substr(trim(to_char(nf.nro_nf,'000000000')),7,3)  numeroNfe            -- Número da nota fiscal  *
              , nf.serie                                          serieNfe             -- serie *
              , decode(nf.dm_ind_oper,0,'0','1')                  saidaEntrada         -- Entrada/Saída *
              , nf.nro_chave_nfe                                  chaveAcesso          -- Chave de acesso *
              , to_char(nf.dt_sai_ent,'dd/mm/yyyy')               dataSaidaEntrada     -- Data Entrada/Saída *
              , decode(nf.hora_sai_ent, null, to_char(nf.dt_sai_ent,'hh24:mi:ss'),nf.hora_sai_ent)                                   horaSaida            -- Hora Entrada/Saída *
              , to_char(nf.dt_emiss,'dd/mm/yyyy')                 dataEmissao          -- Data e Hora de emissão *
              , nf.nat_Oper                                       naturezaOperacao     -- Natureza da Operação *
              , to_char(nf.nro_protocolo)                         nroProtocolo
              , to_char(nf.dt_hr_recbto,'dd/mm/yyyy hh24:mi:ss')  dtAutorizacao
              , nf.empresa_id
              , nf.dm_forma_emiss
              , nf.dm_tp_impr
              , nf.dm_st_proc
              , nf.inf_cpl_imp
              , nf.pedido_compra
              --#61800
              , nf.cod_mensagem
              , nf.msg_sefaz
              , NF.UF_IBGE_EMIT
              --#68468
              , nf.dm_ind_emit
              , nf.dm_ind_oper
              , nf.dm_arm_nfe_terc
           into vv_numeronfe
              , vv_serienfe
              , vv_saidaentrada
              , vv_chaveacesso
              , vv_datasaidaentrada
              , vv_horasaida
              , vv_dataemissao
              , vv_naturezaoperacao_tmp
              , vv_nroprotocolo
              , vv_dtautorizacao
              , vn_empresa_id
              , vn_dm_forma_emiss
              , vn_dm_tp_impr
              , vn_dm_st_proc
              , vv_inf_cpl_imp
              , vv_pedidocompra
              , vn_codmensagem
              , vv_msgsefaz
              , VV_UFIBEGEMIT
              , vv_dm_ind_emit
              , vv_dm_ind_oper
              , vv_dm_arm_nfe_terc
           from nota_fiscal nf
          where nf.id = en_notafiscal_id;
         --
      exception
         when no_data_found then
            null;
         when others then
            raise_application_error (-20101, 'Erro na pb_gera_danfe_nfe fase(' || vn_fase || ') ID (' || en_notafiscal_id || '): ' || sqlerrm);
      end;
      --
      --INICIO #61800 - se o código do sefaz for 200 - código específico para o mato grosso do sul, nota fiscal premiada
      BEGIN
        SELECT E.IBGE_ESTADO
          INTO VV_UFMS
          FROM ESTADO E
         WHERE SIGLA_ESTADO = 'MS';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          VV_UFMS := NULL;
        WHEN OTHERS THEN
          VV_UFMS := NULL;
      END;

      if nvl(vn_codmensagem,0) <> 200 OR (nvl(vn_codmensagem,0) = 200 AND VV_UFMS <> VV_UFIBEGEMIT)then
         vv_msgsefaz := null;
      end if;
      --INICIO #61800
      --
      vv_naturezaoperacao := substr(pk_csf.fkg_converte (vv_naturezaoperacao_tmp),1,60);
      --
      vn_fase := 7;
      --
      if nvl(vn_dm_forma_emiss,0) = 4 then -- Se for DPEC pegar o número e data do Lote
         --
         vn_fase := 8;
         --
         begin
            select to_char(ree.nro_proc)
                 , to_char(ree.dt_hr_reg_event,'dd/mm/yyyy hh24:mi:ss')
              into vv_nroprotocolo_epec
                 , vv_dtautorizacao_epec
              from ret_evento_epec ree
             where ree.notafiscal_id      = en_notafiscal_id
               and to_char(ree.nro_proc) is not null;
         exception
            when others then
               vv_nroprotocolo_epec  := null;
               vv_dtautorizacao_epec := null;
         end;
         --
         vn_fase := 9;
         --
         if vv_nroprotocolo_epec is not null then
            vv_nroprotocolo := vv_nroprotocolo_epec;
         end if;
         --
         vn_fase := 10;
         --
         if vv_dtautorizacao_epec is not null then
            vv_dtautorizacao := vv_dtautorizacao_epec;
         end if;
         --
      end if;
      --
      vn_fase := 11;
      --
      if vn_dm_st_proc not in (4, 14) then -- sai do processo caso não for Autorizado ou Contingencia
         --raise_application_error (-20101, 'Geração da DANFE - NFe (id='||en_notafiscal_id||') não pode ser impressa.');
         raise_application_error (-20101, 'Geração da DANFE: NFe (id='||en_notafiscal_id||') não pode ser impressa devido a situação não estar como '||
                                          '4-Autorizada ou 14-Sefaz em contingência. A situação da NFe neste momento é '||vn_dm_st_proc||'-'||
                                          pk_csf.fkg_dominio( 'NOTA_FISCAL.DM_ST_PROC', vn_dm_st_proc )||'.');
      end if;
      --
      vn_fase := 12;
      -- Recupera o número de casas decimais a ser impresso na DANFE, e outros parâmetros utilizados no processo
      begin
         select em.nro_casa_dec_vl_unit_nfe
              , em.dm_tam_fonte_danfe
              , em.dm_quebra_infadic_nfe
              , em.qtde_carac_inf_compl
              , em.dm_impr_danfe_fci
              , em.dm_impr_danfe_cest
              , em.dm_ord_impr_item_danfe
              , em.dm_descr_item_med
              , em.dm_impr_end_entr_nfe
              , em.dm_impr_end_retir_nfe
              , em.dm_tp_impr_tot_trib
           into vn_nro_casa_dec_vl_unit_nfe
              , vn_dm_tam_fonte_danfe
              , vn_dm_quebra_infadic_nfe
              , vn_qtde_carac_inf_compl
              , vn_dm_impr_danfe_fci
              , vn_dm_impr_danfe_cest
              , vn_dm_ord_impr_item_danfe
              , vn_dm_descr_item_med
              , vn_dm_impr_end_entr_nfe
              , vn_dm_impr_end_retir_nfe
              , vn_dm_tp_impr_tot_trib
           from empresa em
          where em.id = vn_empresa_id;
      exception
         when others then
            vn_nro_casa_dec_vl_unit_nfe := 2; -- Quantidade de casas decimais do Valor Unitario a ser impresso na DANFE.
            vn_dm_quebra_infadic_nfe    := 0; -- Quebra/Enter informação adicional: 0-Não, 1-Sim.
            vn_qtde_carac_inf_compl     := 0; -- Quantidade de caracteres no campo "Informações Complementares".
            vn_dm_impr_danfe_fci        := 0; -- Imprimir numeração FCI na DANFE: 0-Não, 1-Sim.
            vn_dm_impr_danfe_cest       := 0; -- Imprimir código CEST na DANFE: 0-Não, 1-Sim.
            vn_dm_ord_impr_item_danfe   := 1; -- Ordem de impressão dos itens na DANFE: 1-Seqüência Item, 2-Código Item, 3-Descrição Item.
            vn_dm_descr_item_med        := 0; -- Montar descrição do item com as informações de medicamentos: 0-Não, 1-Sim.
            vn_dm_impr_end_entr_nfe     := 0; -- Imprime endereço de entrega na DANFE: 0-Não, 1-Sim.
            vn_dm_impr_end_retir_nfe    := 0; -- Imprimir Endereço de Retirada: 0-Não, 1-Sim.
            vn_dm_tp_impr_tot_trib      := 1; -- Tipo da impressão dos Totais da Tributação: 1-Inicio das Inf. Adic., 2-Final das Inf. Adic.
      end;
      --
      vn_fase := 13;
      -- dados do emitente da nota
      begin
         select substr((trim(nfe.nome)), 1, 50)   emitenteRazaoSocial  -- Nome/razão social   *
              , nfe.lograd || decode(nfe.nro,null,null,', ' || nfe.nro) || decode(nfe.compl,null,null,' - ' || nfe.compl)  emitenteEndereco  -- Endereço *
              , nfe.bairro           emitenteBairro                 -- Bairro/Distrito *
              , nfe.cidade           emitenteMunicipio              -- Municipio descrição *
              , nfe.uf               emitenteUf                     -- UF *
              , substr(lpad(nfe.cep, 8, '0'), 1, 2)
                || '.' || substr(lpad(nfe.cep, 8, '0'), 3, 3)
                || '-' || substr(lpad(nfe.cep, 8, '0'), 6, 3)    emitenteCep -- CEP *
              , nfe.fone             emitenteTelefone               -- FONE/FAX *
              , nfe.ie               emitenteInscricaoEstadual      -- Inscrição Estadual *
              , nfe.iest             emitenteInscricaoEstadualSub   -- Inscr. Estadual do Subst. Tributário *
              , nfe.im               inscricaoMunicipal             -- Inscrição Municipal (Cálculo do ISSQN) *
              , decode( trim(nfe.cpf), null, trim(nfe.cnpj), trim(nfe.cpf) ) emitentecnpj
           into vv_emitenterazaosocial_tmp
              , vv_emitenteendereco
              , vv_emitentebairro
              , vv_emitentemunicipio
              , vv_emitenteuf
              , vv_emitentecep
              , vv_emitentetelefone
              , vv_emitenteinscricaoestadual
              , vv_emitenteInscricaoEstSub
              , vv_inscricaomunicipal
              , vv_emitentecnpj
           from nota_fiscal_emit nfe
          where nfe.notafiscal_id = en_notafiscal_id
            and rownum            = 1;
      exception
         when no_data_found then
            null;
         when others then
            raise_application_error (-20101, 'Erro na pb_gera_danfe_nfe fase(' || vn_fase || ') ID (' || en_notafiscal_id || ': ' || sqlerrm);
      end;
      --
      vv_emitenterazaosocial := substr(pk_csf.fkg_converte (vv_emitenterazaosocial_tmp,0,1,4,1,1,1),1,60);
      --
      vn_fase := 14;
      --
      if trim(vv_emitentetelefone) is null then
         --
         vn_fase := 15;
         --
 	 begin
            select p.fone
	      into vv_emitentetelefone
	      from nota_fiscal nf
	         , empresa e
		 , pessoa p
	     where nf.id = en_notafiscal_id
	       and e.id  = nf.empresa_id
	       and p.id  = e.pessoa_id;
	 exception
	    when others then
	       vv_emitentetelefone := null;
         end;
	 --
      end if;
      --
      vn_fase := 16;
      --
      if trim(vv_emitentebairro) is null then
         vv_emitentebairro := 'SB';
      end if;
      --
      if trim(vv_emitenterazaosocial) is null then
         vv_emitenterazaosocial := 'NI';
      end if;
      --
      if trim(vv_emitenteendereco) is null then
         vv_emitenteendereco := 'NI';
      end if;
      --
      if trim(vv_emitentemunicipio) is null then
         vv_emitentemunicipio := 'NI';
      end if;
      --
      if trim(vv_emitenteuf) is null then
         vv_emitenteuf := 'NI';
      end if;
      --
      if trim(vv_emitentecnpj) is null then
         vv_emitentecnpj := '99999999999999';
      end if;
      --
      vn_fase := 17;
      -- Dados do CNPJ do emitente da NFe
      if nvl(length(vv_emitentecnpj),0) = 14 then
         --
         vv_emitentecnpj := (substr(vv_emitentecnpj, 1, 2) || '.' ||
                             substr(vv_emitentecnpj, 3, 3) || '.' ||
                             substr(vv_emitentecnpj, 6, 3) || '/' ||
                             substr(vv_emitentecnpj, 9, 4) || '-' ||
                             substr(vv_emitentecnpj, 13, 2));
         --
      elsif nvl(length(vv_emitentecnpj),0) = 11 then
         --
         vv_emitentecnpj := (substr(vv_emitentecnpj, 1, 3) || '.' ||
                             substr(vv_emitentecnpj, 4, 3) || '.' ||
                             substr(vv_emitentecnpj, 7, 3) || '-' ||
                             substr(vv_emitentecnpj, 10, 2));
         --
      end if;
      --
      vn_fase := 18;
      -- dados do destinatário da Nfe
      begin
         select decode( trim(nfd.cpf), null, trim(nfd.cnpj), trim(nfd.cpf) )  destinatarioCnpjCpf -- cnpj destinatario *
              , substr((trim(nfd.nome)), 1, 60) destinatarioRazaoSocial     -- Nome/razão social *
              , trim(substr(nfd.lograd || decode(nfd.nro,null,null,', ' || nfd.nro)  || decode(nfd.compl,null,null,' - ' || nfd.compl), 1, 100)) destinatarioEndereco      -- Endereço *
              , nfd.bairro               destinatarioBairro   -- Bairro/Distrito *
              , nfd.cidade               destinatarioMunicipio      -- Municipio descrição *
              , nfd.uf                   destinatarioUf        -- UF *
              , decode(nfd.cod_pais, 1058, substr(lpad(nfd.cep, 8, '0'), 1, 2)
                                           || '.' || substr(lpad(nfd.cep, 8, '0'), 3, 3)
                                           || '-' || substr(lpad(nfd.cep, 8, '0'), 6, 3)
                                         , to_char( lpad(trim(replace(replace(replace(nfd.cep,'.',''),'-',''),'/','')),8,0) ) ) destinatarioCep -- CEP *
              , nfd.fone destinatarioFoneFax             -- FONE/FAX *
              , nfd.ie                   destinatarioInscricaoEstadual        -- Inscrição Estadual *
           into vv_destinatariocnpjcpf
              , vv_destinatariorazaosocial_tmp
              , vv_destinatarioendereco
              , vv_destinatariobairro
              , vv_destinatariomunicipio
              , vv_destinatariouf
              , vv_destinatariocep
              , vv_destinatariofonefax
              , vv_destinatarioinscricaoest
           from nota_fiscal_dest nfd
          where nfd.notafiscal_id = en_notafiscal_id
            and rownum            = 1;
      exception
         when no_data_found then
            null;
         when others then
            raise_application_error (-20101, 'Erro na pb_gera_danfe_nfe fase(' || vn_fase || ') ID (' || en_notafiscal_id || ': ' || sqlerrm);
      end;
      --
      vv_destinatariorazaosocial := substr(pk_csf.fkg_converte (vv_destinatariorazaosocial_tmp),1,60);
      --
      vn_fase := 19;
      --
      if nvl( length(vv_destinatariocnpjcpf), 0) = 14 then
         --
         vv_destinatariocnpjcpf := (substr(vv_destinatariocnpjcpf, 1, 2) || '.' ||
                                    substr(vv_destinatariocnpjcpf, 3, 3) || '.' ||
                                    substr(vv_destinatariocnpjcpf, 6, 3) || '/' ||
                                    substr(vv_destinatariocnpjcpf, 9, 4) || '-' ||
                                    substr(vv_destinatariocnpjcpf, 13, 2));
         --
      elsif nvl( length(vv_destinatariocnpjcpf), 0) = 11 then
         --
         vv_destinatariocnpjcpf := (substr(vv_destinatariocnpjcpf, 1, 3) || '.' ||
                                    substr(vv_destinatariocnpjcpf, 4, 3) || '.' ||
                                    substr(vv_destinatariocnpjcpf, 7, 3) || '-' ||
                                    substr(vv_destinatariocnpjcpf, 10, 2));
         --
      else
         --
         vv_destinatariocnpjcpf := null;
         --
      end if;
      --
      vn_fase := 20;
      -- dados da fatura
      vv_fatura := trim(substr(pk_csf.fkg_String_dupl(en_notafiscal_id => en_notafiscal_id, en_monta_nro_fat => 1), 1, 3999));
      --
      vn_fase := 21;
      -- dados de totais da NFe
      begin
         select  ltrim(rtrim(to_char(nft.vl_base_calc_icms, '999g999g999g990d00')))  baseIcms                 -- Base de cálculo do ICMS   *
               , ltrim(rtrim(to_char(nft.vl_imp_trib_icms,  '999g999g999g990d00')))  valorIcms                -- Valor do ICMS *
               , ltrim(rtrim(to_char(nft.vl_base_calc_st,   '999g999g999g990d00')))  baseIcmsSubstituicao     -- Base de cálculo do ICMS Substituição *
               , ltrim(rtrim(to_char(nft.vl_imp_trib_st,    '999g999g999g990d00')))  valorIcmsSubstituicao    -- Valor do ICMS Substituição *
               , ltrim(rtrim(to_char(nft.vl_total_item,     '999g999g999g990d00')))  valorTotalProduto        -- Valor Total dos Produtos *
               , ltrim(rtrim(to_char(nft.vl_frete,          '999g999g999g990d00')))  valorFrete               -- Valor do Frete *
               , ltrim(rtrim(to_char(nft.vl_seguro,         '999g999g999g990d00')))  valorSeguro              -- Valor do Seguro *
               , ltrim(rtrim(to_char(nft.vl_desconto,       '999g999g999g990d00')))  desconto                 -- Desconto *
               , ltrim(rtrim(to_char(nft.vl_imp_trib_ipi,   '999g999g999g990d00')))  valorIpi                 -- Valor do IPI *
               , ltrim(rtrim(to_char(nft.vl_outra_despesas, '999g999g999g990d00')))  outrasDespesas           -- Outras Despesas Acessórias *
               , ltrim(rtrim(to_char(nft.vl_total_nf,       '999g999g999g990d00')))  valorTotalNota           -- Valor Total da Nota *
               -- Cálculo do ISSQN
               , ltrim(rtrim(to_char(nft.vl_serv_nao_trib,  '999g999g999g990d00')))  valorTotalServicos       -- Valor Total dos Serviços *
               , ltrim(rtrim(to_char(nft.vl_base_calc_iss,  '999g999g999g990d00')))  baseIssqn                -- Base de cálculo do ISSQN *
               , ltrim(rtrim(to_char(nft.vl_imp_trib_iss,   '999g999g999g990d00')))  valorIssqn               -- Valor do ISSQN *
               , nft.vl_tot_trib                                                     vl_tot_trib              -- Valor Total dos Impostos, total da NF-e
               , ltrim(rtrim(to_char(nft.vl_imp_trib_pis,   '999g999g999g990d00')))  valorpis                 -- Valor PIS
               , ltrim(rtrim(to_char(nft.vl_imp_trib_cofins,'999g999g999g990d00')))  valorcofins              -- Valor COFINS
            into vv_baseicms
               , vv_valoricms
               , vv_baseicmssubstituicao
               , vv_valoricmssubstituicao
               , vv_valortotalproduto
               , vv_valorfrete
               , vv_valorseguro
               , vv_desconto
               , vv_valoripi
               , vv_outrasdespesas
               , vv_valortotalnota
               , vv_valortotalservicos
               , vv_baseissqn
               , vv_valorissqn
               , vn_vl_acm_tot_trib
               , vv_valorpis
               , vv_valorcofins
            from nota_fiscal_total nft
           where nft.notafiscal_id = en_notafiscal_id
             and rownum = 1;
      exception
         when no_data_found then
            vv_baseicms              := 0;
            vv_valoricms             := 0;
            vv_baseicmssubstituicao  := 0;
            vv_valoricmssubstituicao := 0;
            vv_valortotalproduto     := 0;
            vv_valorfrete            := 0;
            vv_valorseguro           := 0;
            vv_desconto              := 0;
            vv_valoripi              := 0;
            vv_outrasdespesas        := 0;
            vv_valortotalnota        := 0;
            vv_valortotalservicos    := 0;
            vv_baseissqn             := 0;
            vv_valorissqn            := 0;
            vn_vl_acm_tot_trib       := 0;
            vv_valorpis              := 0;
            vv_valorcofins           := 0;
         when others then
            raise_application_error (-20101, 'Erro na pb_gera_danfe_nfe fase(' || vn_fase || ') ID (' || en_notafiscal_id || ': ' || sqlerrm);
      end;
      --
      vn_fase := 22;
      --
      vv_vltottrib := ltrim(rtrim(to_char(nvl(vn_vl_acm_tot_trib,0),'999g999g999g990d00')));
      --
      vn_fase := 23;
      -- dados de transporte da Nfe
      begin
         select distinct decode( length(nftransp.cnpj_cpf), 14, (substr(nftransp.cnpj_cpf, 1, 2) || '.' ||
                        substr(nftransp.cnpj_cpf, 3, 3) || '.' ||
                        substr(nftransp.cnpj_cpf, 6, 3) || '/' || substr(nftransp.cnpj_cpf, 9, 4) || '-' || substr(nftransp.cnpj_cpf, 13, 2))
                      , 11, (substr(nftransp.cnpj_cpf, 1, 3) || '.' ||
                             substr(nftransp.cnpj_cpf, 4, 3) || '.' ||
                             substr(nftransp.cnpj_cpf, 7, 3) || '-' || substr(nftransp.cnpj_cpf, 10, 2))
                            , null )             transportadorCnpjCpf              -- CNPJ/CPF transp *
              , nftransp.dm_mod_frete transportadorFretePorConta          -- Frete por conta *
              , nftransp.nome                 transportadorRazaoSocial                      -- Razão Social *
              , nftransp.ie                   transportadorInscricaoEstadual                -- Inscrição Estadual *
              , nftransp.ender                transportadorEndereco                         -- Endereço *
              , nftransp.cidade               transportadorMunicipio                        -- Municipio *
              , nftransp.uf                   transportadorUf                               -- UF*
           into vv_transportadorcnpjcpf
              , vv_transportadorfreteporconta
              , vv_transportadorrazaosoc_tmp
              , vv_transportadorinscricaoest
              , vv_transportadorendereco
              , vv_transportadormunicipio
              , vv_transportadoruf
           from nota_fiscal_transp nftransp
          where nftransp.notafiscal_id = en_notafiscal_id
            and rownum                 = 1;
      exception
         when no_data_found then
            null;
         when others then
            raise_application_error (-20101, 'Erro na pb_gera_danfe_nfe fase(' || vn_fase || ') ID (' || en_notafiscal_id || ': ' || sqlerrm);
      end;
      --
      vv_transportadorrazaosocial := substr(pk_csf.fkg_converte (vv_transportadorrazaosoc_tmp),1,60);
      --
      vn_fase := 24;
      -- Dados do veículo do transportad a NFe
      begin
         select distinct nftv.placa transportadorPlacaVeiculo         -- Placa do Veículo *
              , nftv.uf             transportadorUfVeiculo            -- UF da Placa do Veículo *
              , nftv.rntc           transportadorCodigoAntt
           into vv_transportadorplacaveiculo
              , vv_transportadorufveiculo
              , vv_transportadorcodigoantt
           from nota_fiscal_transp nft
              , NFTransp_Veic      nftv
          where nft.notafiscal_id = en_notafiscal_id
            and nftv.nftransp_id  = nft.id
            and nftv.dm_tipo      = 0 -- Veículo
            and rownum            = 1;
      exception
         when no_data_found then
            null;
         when others then
            raise_application_error (-20101, 'Erro na pb_gera_danfe_nfe fase(' || vn_fase || ') ID (' || en_notafiscal_id || ': ' || sqlerrm);
      end;
      --
      vn_fase := 25;
      --
      -- Informações Adicionais
      begin
         select inf.conteudo
           into vv_inf_fisco
           from NFInfor_Adic inf
          where inf.notafiscal_id = en_notafiscal_id
            and inf.dm_tipo       = 1 -- Fisco
            and inf.campo        is null
            and rownum            = 1;
      exception
         when no_data_found then
            null;
         when others then
            raise_application_error (-20101, 'Erro na pb_gera_danfe_nfe fase(' || vn_fase || ') ID (' || en_notafiscal_id || ': ' || sqlerrm);
      end;
      --
      vn_fase := 26;
      --
      begin
         select distinct inf.conteudo
           into vv_inf_contr
           from NFInfor_Adic inf
          where inf.notafiscal_id = en_notafiscal_id
            and inf.dm_tipo       = 0 -- Contribuinte
            and inf.campo        is null
            and rownum            = 1;
      exception
         when no_data_found then
            null;
         when others then
            raise_application_error (-20101, 'Erro na pb_gera_danfe_nfe fase(' || vn_fase || ') ID (' || en_notafiscal_id || ': ' || sqlerrm);
      end;
      --
      vn_fase := 27;
      --
      -- Trabalha a informação complementar conforme o "tipo de impressão"
      if nvl(vn_dm_tp_impr_tot_trib,0) = 1 then -- Inicio das Inf. Adic.
         vv_inf_compl := trim(substr((case when trim(vv_inf_cpl_imp) is null then
                                          (case when trim(vv_inf_contr) is null then ''
                                                else trim(vv_inf_contr) end)
                                           else trim(vv_inf_cpl_imp) || (case when trim(vv_inf_contr) is null then '' else '/'||trim(vv_inf_contr) end)
                                      end) ||
                                     (case when trim(vv_inf_fisco) is null then '' else ' ' || 'Informações Interesse Fisco: ' || vv_inf_fisco end)
                                    , 1, 4000));
      else
         -- Final das Inf. Adic.
         vv_inf_compl := trim(substr((case when trim(vv_inf_contr) is null then
                                          (case when trim(vv_inf_cpl_imp) is null then ''
                                                else trim(vv_inf_cpl_imp) end)
                                           else trim(vv_inf_contr) || (case when trim(vv_inf_cpl_imp) is null then '' else '/'||trim(vv_inf_cpl_imp) end)
                                      end) ||
                                     (case when trim(vv_inf_fisco) is null then '' else ' ' || 'Informações Interesse Fisco: ' || vv_inf_fisco end)
                                    , 1, 4000));
      end if;
      --
      -- Verificar se a empresa deseja informar local de "Endereço de Retirada" e "Endereço de Entrega" na DANFE
      vn_fase := 28;
      vv_end_entr_retir := null;
      --
      if nvl(vn_dm_impr_end_entr_nfe,0) = 1 then -- Sim, imprime endereço de entrega na DANFE
         --
         vn_fase := 28.1;
         --
         begin
            select ' ENTREGA '
                || nfl.lograd || ', '
                || nfl.nro || ', '
                || decode(nvl(length(nfl.compl),0), 0, null, nfl.compl || ', ')
                || nfl.bairro || ', '
                || nfl.cidade || ', '
                || nfl.uf || ', '
                || case
                      when trim(nfl.cnpj) is not null then
                         'CNPJ: ' || trim(nfl.cnpj) || ', '
                      when trim(nfl.cpf) is not null then
                         'CNPJ: ' || trim(nfl.cpf) || ', '
                      else null
                   end
                || decode(nvl(length(nfl.ie),0), 0, null, 'IE: ' || nfl.ie || ', ')
              into vv_end_entr_retir
              from nota_fiscal_local nfl
             where nfl.notafiscal_id = en_notafiscal_id
               and nfl.dm_tipo_local = 1; -- entrega
         exception
            when others then
               vv_end_entr_retir := null;
         end;
         --
      end if;
      --
      vv_inf_compl := trim(substr(vv_inf_compl || vv_end_entr_retir, 1, 4000));
      --
      vn_fase := 29;
      vv_end_entr_retir := null;
      --
      if nvl(vn_dm_impr_end_retir_nfe,0) = 1 then -- Sim, imprime endereço de entrega na DANFE
         --
         vn_fase := 29.1;
         --
         begin
            select ' RETIRADA '
                || nfl.lograd || ', '
                || nfl.nro || ', '
                || decode(nvl(length(nfl.compl),0), 0, null, nfl.compl || ', ')
                || nfl.bairro || ', '
                || nfl.cidade || ', '
                || nfl.uf || ', '
                || case
                      when trim(nfl.cnpj) is not null then
                         'CNPJ: ' || trim(nfl.cnpj) || ', '
                      when trim(nfl.cpf) is not null then
                         'CNPJ: ' || trim(nfl.cpf) || ', '
                      else null
                   end
                || decode(nvl(length(nfl.ie),0), 0, null, 'IE: ' || nfl.ie || ', ')
              into vv_end_entr_retir
              from nota_fiscal_local nfl
             where nfl.notafiscal_id = en_notafiscal_id
               and nfl.dm_tipo_local = 0; -- Retirada
         exception
            when others then
               vv_end_entr_retir := null;
         end;
         --
      end if;
      --
      vn_fase := 30;
      --
      vv_inf_compl := trim(substr(vv_inf_compl || vv_end_entr_retir, 1, 4000));
      --
      if vn_dm_tam_fonte_danfe = 1 then -- Tamanho 12
         --
         if vn_dm_tp_impr = 1 then -- Retrato
            --
            if nvl(vn_qtde_carac_inf_compl,0) <= 0 then
               vn_qtde_carac_inf_compl := 616; -- 523;
            end if;
            --
         else -- paisagem
            --
            if nvl(vn_qtde_carac_inf_compl,0) <= 0 then
               vn_qtde_carac_inf_compl := 250;
            end if;
            --
         end if;
         --
      else -- Tamanho 6
         --
         if vn_dm_tp_impr = 1 then -- Retrato
            --
            if nvl(vn_qtde_carac_inf_compl,0) <= 0 then
               vn_qtde_carac_inf_compl := 1303;
            end if;
            --
         else -- paisagem
            --
            if nvl(vn_qtde_carac_inf_compl,0) <= 0 then
               vn_qtde_carac_inf_compl := 565; -- 650;
            end if;
            --
         end if;
         --
      end if;
      --
      vn_fase := 31;
      --
      vv_informacoescomplementares  := substr(vv_inf_compl, 1, vn_qtde_carac_inf_compl );
      vv_informacoescomplementares2 := substr(vv_inf_compl, vn_qtde_carac_inf_compl + 1, 5500 );
      --
      vn_fase := 32;
      --
      begin
         --
         for rec_tr in c_transp
         loop
            --
            exit when c_transp%notfound or (c_transp%notfound) is null;
            --
            vn_fase := 32.1;
            --
            if nvl(rec_tr.qVol,0) <= 0 then
               vv_transportadorquantidade := null;
            else
               vv_transportadorquantidade := rec_tr.qVol;
            end if;
            --
            vv_transportadorespecie     := rec_tr.esp;
            vv_transportadormarca       := rec_tr.marca;
            vv_transportadornumeracao   := rec_tr.nVol;
            vv_transportadorpesoliquido := rec_tr.pesoL;
            vv_transportadorpesobruto   := rec_tr.pesoB;
            --
         end loop;
         --
      exception
         when no_data_found then
            null;
         when others then
            raise_application_error (-20101, 'Erro na pb_gera_danfe_nfe fase(' || vn_fase || ') ID (' || en_notafiscal_id || ': ' || sqlerrm);
      end;
      --
      vn_fase := 33;
      --
      if vv_horasaida = '00:00:00' then
         vv_horasaida := null;
      end if;
      --
      vn_fase := 34;
      -- #4212 Inicio - Emitente
      if length(vv_emitentetelefone) >= 11 then
         if substr(vv_emitentetelefone, -11, 4) = '0800' then
            vv_emitentetelefone := substr(vv_emitentetelefone, -11, 4)
                                   ||' '||substr(vv_emitentetelefone, -7, 3)
                                   ||' '||substr(vv_emitentetelefone, -4, 4);
         else
            -- celular
            vv_emitentetelefone := '(' || substr(vv_emitentetelefone,-11,2) || ')'
                                       || substr(vv_emitentetelefone,-9,1)
                                       || substr(vv_emitentetelefone,-8,4) || '-'
                                       || substr(vv_emitentetelefone,-4,4);
         end if;
      elsif vv_emitentetelefone is not null then
            vv_emitentetelefone := '(' || substr(vv_emitentetelefone,-10,2) || ') '
                                       || substr(vv_emitentetelefone,-8,4) || '-'
                                       || substr(vv_emitentetelefone,-4,4);
      end if;
      --
      vn_fase := 35;
      -- Destinatario
      if length(vv_destinatariofonefax) >= 11 then
         if substr(vv_destinatariofonefax, -11, 4) = '0800' then
            vv_destinatariofonefax := substr(vv_destinatariofonefax, -11, 4)
                                   ||' '||substr(vv_destinatariofonefax, -7, 3)
                                   ||' '||substr(vv_destinatariofonefax, -4, 4);
         else
            -- celular
            vv_destinatariofonefax := '(' || substr(vv_destinatariofonefax,-11,2) || ')'
                                       || substr(vv_destinatariofonefax,-9,1)
                                       || substr(vv_destinatariofonefax,-8,4) || '-'
                                       || substr(vv_destinatariofonefax,-4,4);
         end if;
      elsif vv_destinatariofonefax is not null then
            vv_destinatariofonefax := '(' || substr(vv_destinatariofonefax,-10,2) || ') '
                                       || substr(vv_destinatariofonefax,-8,4) || '-'
                                       || substr(vv_destinatariofonefax,-4,4);
      end if;
      --
      if trim(vv_chaveacesso) is null then
         vv_chaveacesso := lpad('0', 44, '0');
      end if;
      --
      -- #4212 Fim
      vn_fase := 36;
      --
      if vv_numeronfe is not null
         and vv_serienfe is not null
         and trim(vv_chaveacesso) is not null
         and vv_dataemissao is not null
         and vv_emitentecnpj is not null
         and vv_emitenterazaosocial is not null
         and vv_emitenteendereco is not null
         and vv_emitentebairro is not null
         and vv_emitentemunicipio is not null
         and vv_emitenteuf is not null
         and vv_destinatariorazaosocial is not null
         and vv_destinatarioendereco is not null
         and vv_destinatariobairro is not null
         and vv_destinatariomunicipio is not null
         and vv_destinatariouf is not null
         then
         --
         vn_fase := 37;
         --
         begin
            select min(ic.id)
              into vn_imprcabnfe_id
              from impr_cab_nfe ic
             where ic.notafiscal_id = en_notafiscal_id;
         exception
            when others then
               vn_imprcabnfe_id := 0;
         end;
         --
         vn_fase := 37.1;
         --
         if nvl(vn_imprcabnfe_id,0) = 0 then
            --
            vn_fase := 37.2;
            --
            begin
               select imprcabnfe_seq.nextval
                 into vn_imprcabnfe_id
                 from dual;
            exception
               when others then
                  vn_imprcabnfe_id := 0;
            end;
            --
            vn_fase := 37.3;
            --
            begin
               insert into impr_cab_nfe ( id
                                        , notafiscal_id
                                        , numeronfe
                                        , serienfe
                                        , saidaentrada
                                        , chaveacesso
                                        , datasaidaentrada
                                        , horasaida
                                        , dataemissao
                                        , naturezaoperacao
                                        , emitentecnpj
                                        , emitenterazaosocial
                                        , emitenteendereco
                                        , emitentebairro
                                        , emitentemunicipio
                                        , emitenteuf
                                        , emitentecep
                                        , emitentetelefone
                                        , emitenteinscricaoestadual
                                        , emitenteinscricaoestadualsub
                                        , inscricaomunicipal
                                        , destinatariocnpjcpf
                                        , destinatariorazaosocial
                                        , destinatarioendereco
                                        , destinatariobairro
                                        , destinatariomunicipio
                                        , destinatariouf
                                        , destinatariocep
                                        , destinatariofonefax
                                        , destinatarioinscricaoestadual
                                        , fatura
                                        , baseicms
                                        , valoricms
                                        , baseicmssubstituicao
                                        , valoricmssubstituicao
                                        , valortotalproduto
                                        , valorfrete
                                        , valorseguro
                                        , desconto
                                        , valoripi
                                        , outrasdespesas
                                        , valortotalnota
                                        , valortotalservicos
                                        , baseissqn
                                        , valorissqn
                                        , transportadorcnpjcpf
                                        , transportadorfreteporconta
                                        , transportadorrazaosocial
                                        , transportadorinscricaoestadual
                                        , transportadorendereco
                                        , transportadormunicipio
                                        , transportadoruf
                                        , transportadorplacaveiculo
                                        , transportadorufveiculo
                                        , transportadorcodigoantt
                                        , informacoescomplementares
                                        , informacoescomplementares2
                                        , nroprotocolo
                                        , dtautorizacao
                                        , transportadorquantidade
                                        , transportadorespecie
                                        , transportadormarca
                                        , transportadornumeracao
                                        , transportadorpesobruto
                                        , transportadorpesoliquido
                                        , pedidocompra
                                        , vltottrib
                                        , valorpis
                                        , valorcofins
                                        , INF_RESERV_FISCO
                                        )
                                 values ( vn_imprcabnfe_id
                                        , en_notafiscal_id
                                        , vv_numeronfe
                                        , vv_serienfe
                                        , vv_saidaentrada
                                        , vv_chaveacesso
                                        , vv_datasaidaentrada
                                        , vv_horasaida
                                        , vv_dataemissao
                                        , vv_naturezaoperacao
                                        , vv_emitentecnpj
                                        , vv_emitenterazaosocial
                                        , vv_emitenteendereco
                                        , vv_emitentebairro
                                        , vv_emitentemunicipio
                                        , vv_emitenteuf
                                        , vv_emitentecep
                                        , vv_emitentetelefone
                                        , vv_emitenteinscricaoestadual
                                        , vv_emitenteinscricaoestsub
                                        , vv_inscricaomunicipal
                                        , vv_destinatariocnpjcpf
                                        , vv_destinatariorazaosocial
                                        , vv_destinatarioendereco
                                        , vv_destinatariobairro
                                        , vv_destinatariomunicipio
                                        , vv_destinatariouf
                                        , vv_destinatariocep
                                        , vv_destinatariofonefax
                                        , vv_destinatarioinscricaoest
                                        , vv_fatura
                                        , vv_baseicms
                                        , vv_valoricms
                                        , vv_baseicmssubstituicao
                                        , vv_valoricmssubstituicao
                                        , vv_valortotalproduto
                                        , vv_valorfrete
                                        , vv_valorseguro
                                        , vv_desconto
                                        , vv_valoripi
                                        , vv_outrasdespesas
                                        , vv_valortotalnota
                                        , vv_valortotalservicos
                                        , vv_baseissqn
                                        , vv_valorissqn
                                        , vv_transportadorcnpjcpf
                                        , vv_transportadorfreteporconta
                                        , vv_transportadorrazaosocial
                                        , vv_transportadorinscricaoest
                                        , vv_transportadorendereco
                                        , vv_transportadormunicipio
                                        , vv_transportadoruf
                                        , vv_transportadorplacaveiculo
                                        , vv_transportadorufveiculo
                                        , vv_transportadorcodigoantt
                                        , vv_informacoescomplementares
                                        , vv_informacoescomplementares2
                                        , vv_nroprotocolo
                                        , vv_dtautorizacao
                                        , vv_transportadorquantidade
                                        , vv_transportadorespecie
                                        , vv_transportadormarca
                                        , vv_transportadornumeracao
                                        , vv_transportadorpesobruto
                                        , vv_transportadorpesoliquido
                                        , vv_pedidocompra
                                        , vv_vltottrib
                                        , vv_valorpis
                                        , vv_valorcofins
                                        , vv_msgsefaz
                                        );
            exception
               when others then
                  --
                  vv_mensagem_log := 'Problemas ao incluir dados em impr_cab_nfe (notafiscal_id = '||en_notafiscal_id||') - pb_gera_danfe_nfe '||
                                     'fase('||vn_fase||'). Erro = '||sqlerrm;
                  --
                  declare
                     vn_loggenerico_id  Log_Generico_nf.id%type := null;
                  begin
                     pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                    , ev_mensagem         => vv_mensagem_log
                                                    , ev_resumo           => vv_mensagem_log
                                                    , en_tipo_log         => erro_de_sistema
                                                    , en_referencia_id    => en_notafiscal_id
                                                    , ev_obj_referencia   => 'NOTA_FISCAL' );
                  exception
                     when others then
                        null;
                  end;
                  --
            end;
            --
         else
            --
            vn_fase := 37.4;
            --
            begin
               update impr_cab_nfe ic
                  set ic.numeronfe                      = vv_numeronfe
                    , ic.serienfe                       = vv_serienfe
                    , ic.saidaentrada                   = vv_saidaentrada
                    , ic.chaveacesso                    = vv_chaveacesso
                    , ic.datasaidaentrada               = vv_datasaidaentrada
                    , ic.horasaida                      = vv_horasaida
                    , ic.dataemissao                    = vv_dataemissao
                    , ic.naturezaoperacao               = vv_naturezaoperacao
                    , ic.emitentecnpj                   = vv_emitentecnpj
                    , ic.emitenterazaosocial            = vv_emitenterazaosocial
                    , ic.emitenteendereco               = vv_emitenteendereco
                    , ic.emitentebairro                 = vv_emitentebairro
                    , ic.emitentemunicipio              = vv_emitentemunicipio
                    , ic.emitenteuf                     = vv_emitenteuf
                    , ic.emitentecep                    = vv_emitentecep
                    , ic.emitentetelefone               = vv_emitentetelefone
                    , ic.emitenteinscricaoestadual      = vv_emitenteinscricaoestadual
                    , ic.emitenteinscricaoestadualsub   = vv_emitenteinscricaoestsub
                    , ic.inscricaomunicipal             = vv_inscricaomunicipal
                    , ic.destinatariocnpjcpf            = vv_destinatariocnpjcpf
                    , ic.destinatariorazaosocial        = vv_destinatariorazaosocial
                    , ic.destinatarioendereco           = vv_destinatarioendereco
                    , ic.destinatariobairro             = vv_destinatariobairro
                    , ic.destinatariomunicipio          = vv_destinatariomunicipio
                    , ic.destinatariouf                 = vv_destinatariouf
                    , ic.destinatariocep                = vv_destinatariocep
                    , ic.destinatariofonefax            = vv_destinatariofonefax
                    , ic.destinatarioinscricaoestadual  = vv_destinatarioinscricaoest
                    , ic.fatura                         = vv_fatura
                    , ic.baseicms                       = vv_baseicms
                    , ic.valoricms                      = vv_valoricms
                    , ic.baseicmssubstituicao           = vv_baseicmssubstituicao
                    , ic.valoricmssubstituicao          = vv_valoricmssubstituicao
                    , ic.valortotalproduto              = vv_valortotalproduto
                    , ic.valorfrete                     = vv_valorfrete
                    , ic.valorseguro                    = vv_valorseguro
                    , ic.desconto                       = vv_desconto
                    , ic.valoripi                       = vv_valoripi
                    , ic.outrasdespesas                 = vv_outrasdespesas
                    , ic.valortotalnota                 = vv_valortotalnota
                    , ic.valortotalservicos             = vv_valortotalservicos
                    , ic.baseissqn                      = vv_baseissqn
                    , ic.valorissqn                     = vv_valorissqn
                    , ic.transportadorcnpjcpf           = vv_transportadorcnpjcpf
                    , ic.transportadorfreteporconta     = vv_transportadorfreteporconta
                    , ic.transportadorrazaosocial       = vv_transportadorrazaosocial
                    , ic.transportadorinscricaoestadual = vv_transportadorinscricaoest
                    , ic.transportadorendereco          = vv_transportadorendereco
                    , ic.transportadormunicipio         = vv_transportadormunicipio
                    , ic.transportadoruf                = vv_transportadoruf
                    , ic.transportadorplacaveiculo      = vv_transportadorplacaveiculo
                    , ic.transportadorufveiculo         = vv_transportadorufveiculo
                    , ic.transportadorcodigoantt        = vv_transportadorcodigoantt
                    , ic.informacoescomplementares      = vv_informacoescomplementares
                    , ic.informacoescomplementares2     = vv_informacoescomplementares2
                    , ic.nroprotocolo                   = vv_nroprotocolo
                    , ic.dtautorizacao                  = vv_dtautorizacao
                    , ic.transportadorquantidade        = vv_transportadorquantidade
                    , ic.transportadorespecie           = vv_transportadorespecie
                    , ic.transportadormarca             = vv_transportadormarca
                    , ic.transportadornumeracao         = vv_transportadornumeracao
                    , ic.transportadorpesobruto         = vv_transportadorpesobruto
                    , ic.transportadorpesoliquido       = vv_transportadorpesoliquido
                    , ic.pedidocompra                   = vv_pedidocompra
                    , ic.vltottrib                      = vv_vltottrib
                    , ic.valorpis                       = vv_valorpis
                    , ic.valorcofins                    = vv_valorcofins
                where ic.id = vn_imprcabnfe_id;
            exception
               when others then
                  --
                  vv_mensagem_log := 'Problemas ao atualizar dados em impr_cab_nfe (notafiscal_id = '||en_notafiscal_id||') - pb_gera_danfe_nfe '||
                                     'fase('||vn_fase||'). Erro = '||sqlerrm;
                  --
                  declare
                     vn_loggenerico_id  Log_Generico_nf.id%type := null;
                  begin
                     pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                    , ev_mensagem         => vv_mensagem_log
                                                    , ev_resumo           => vv_mensagem_log
                                                    , en_tipo_log         => erro_de_sistema
                                                    , en_referencia_id    => en_notafiscal_id
                                                    , ev_obj_referencia   => 'NOTA_FISCAL' );
                  exception
                     when others then
                        null;
                  end;
                  --
            end;
            --
         end if;
         --
         vn_fase := 38;
         -- Itens da NFe
         open c_item1(en_notafiscal_id);
         open c_item2(en_notafiscal_id);
         --
         vn_fase := 39;
         --
         loop
            --
            vn_fase := 40;
            --
            if vn_dm_ord_impr_item_danfe = 1 then -- ordenação numerica
               --
               fetch c_item1 into rec_item1;
               rec_item := rec_item1;
               exit when c_item1%notfound or (c_item1%notfound) is null;
               --
            else
               --
               fetch c_item2 into rec_item2;
               rec_item := rec_item2;
               exit when c_item2%notfound or (c_item2%notfound) is null;
               --
            end if;
            --
            vn_fase := 41;
            --
            vn_itemnf_id := rec_item.itemnf_id;
            vn_nro_item  := rec_item.nro_item;
            --
            vn_fase := 42;
            --
            vv_infadprod := null;
            --
            --| RETIRANDO A TAG DE TROCA DE INFORMAÇÕES, CAMPO INFORMAÇÃO COMPLEMENTAR DO ITEM DA NOTA.
            declare
               --
               vn_inicio number;
               vn_fim    number;
               vn_frase  varchar(4000);
               --
            begin
               --
               if trim(rec_item.infadprod) is not null and
                  instr(rec_item.infadprod, 'CDATA', 1,1) > 0 then
                  --
                  vn_inicio := instr(rec_item.infadprod, 'CDATA', 1,1)-3;
                  vn_fim    := instr(rec_item.infadprod, ']>', vn_inicio, 1);
                  vn_frase  := substr(rec_item.infadprod, vn_inicio, (vn_fim-vn_inicio)+2);
                  --
                  vv_infadprod := replace(rec_item.infadprod, vn_frase, ' ');
                  --
               else
                  --
                  vv_infadprod := rec_item.infadprod;
                  --
               end if;
               --
            exception
               when others then
                  --
                  vv_infadprod := null;
                  --
            end;
            --
            vn_fase := 42.1;
            --
            if trim(rec_item.infadprod) is not null then
               --
               if vn_dm_quebra_infadic_nfe = 0 then
                  --vv_infadprod := ' ' || rec_item.infadprod; -- colocado o espaço para separar da descrição do item
                  vv_infadprod := ' ' || replace(vv_infadprod, '_', ''); -- colocado o espaço para separar da descrição do item
               else
                  --vv_infadprod := chr(10) || rec_item.infadprod; -- colocado o enter para quebrar da descrição do item
                  vv_infadprod := chr(10) || replace(vv_infadprod, '_', ''); -- colocado o enter para quebrar da descrição do item
               end if;
               --
            end if;
            --
            vn_fase := 43;
            vv_infor_med := null;
            --
            if nvl(vn_dm_descr_item_med,0) = 1 then -- Informar dados de medicamento
               --
               for r_med in c_med (en_itemnf_id => rec_item.itemnf_id)
               loop
                  --
                  exit when c_med%notfound or (c_med%notfound) is null;
                  --
                  if vv_infor_med is null then
                     vv_infor_med := '['||r_med.infor_med;
                  else
                     vv_infor_med := vv_infor_med||', '||r_med.infor_med;
                  end if;
                  --
               end loop;
               --
               if vv_infor_med is not null then
                  vv_infor_med := vv_infor_med||']';
               end if;
               --
            end if;
            --
            vn_fase := 44;
            --
            if trim(vv_infor_med) is not null then
               --
               if trim(rec_item.inf_cpl_imp_item) is not null then
                  vv_infadprod := substr((substr((vv_infadprod||' '||trim(vv_infor_med)),1,440)||' '||trim(rec_item.inf_cpl_imp_item)),1,500);
               else
                  vv_infadprod := substr((vv_infadprod||' '||trim(vv_infor_med)),1,500);
               end if;
               --
            else
               --
               if trim(rec_item.inf_cpl_imp_item) is not null then
                  vv_infadprod := substr( (substr(vv_infadprod, 1, 440) || ' ' || trim(rec_item.inf_cpl_imp_item)) , 1, 500);
               else
                  vv_infadprod := substr(vv_infadprod, 1, 500);
               end if;
               --
            end if;
            --
            /*
            if trim(rec_item.inf_cpl_imp_item) is not null then
               vv_infadprod := substr( (substr(vv_infadprod, 1, 440) || ' ' || trim(rec_item.inf_cpl_imp_item)) , 1, 500);
            else
               vv_infadprod := substr(vv_infadprod, 1, 500);
            end if;
            */
            --
            vn_fase := 45;
            --
            vv_codigo    := trim(substr(rec_item.codigo, 1, 60));

            if   vv_dm_ind_emit = 0 and  vv_dm_ind_oper = 1 and vv_dm_arm_nfe_terc = 0 then
               vv_descricao := trim(substr(pk_csf.fkg_converte(rec_item.descricao,0,1,3,1,1,1), 1, 120));
            else
               vv_descricao := trim(substr(pk_csf.fkg_converte(rec_item.descricao), 1, 120));
            end if;
            vv_ncm       := rec_item.ncm;
            --
            vn_fase := 46;
            --
            vv_cfop       := rec_item.cfop;
            vv_unidade    := rec_item.unidade;
            vv_quantidade := rec_item.quantidade;
            --
            vn_fase := 47;
            -- Seta o valor unitário conforme o número de casas decimais
            vv_valorunitario   := ltrim(rtrim(to_char(rec_item.valorUnitario,('99g999g999g990d' || lpad('0', vn_nro_casa_dec_vl_unit_nfe, '0')))));
            vv_valortotal_item := rec_item.valorTotal;
            vv_vldescontoitem  := rec_item.vldescontoitem;
            --
            vn_fase := 48;
            --
            vv_cst               := null;
            vv_cst_sn            := null;
            vv_baseicms_item     := null;
            vv_valoricms_item    := null;
            vv_baseicmsst_item   := null;
            vv_valoricmsst_item  := null;
            vv_valoripi_item     := null;
            vv_aliquotaicms_item := null;
            vv_aliquotaipi_item  := null;
            vv_perc_reduc        := null;
            --
            vn_fase := 49;
            -- valores de icms do item
            begin
               select cst.cod_st                    CST
                    , ltrim(rtrim(to_char(nvl(impitnf.vl_base_calc,0),'999g999g999g990d00')))  vBC_icms
                    , ltrim(rtrim(to_char(nvl(impitnf.vl_imp_trib,0),'999g999g999g990d00')))   vICMS_icms
                    , ltrim(rtrim(to_char(nvl(impitnf.aliq_apli,0),'990d00')))                 pICMS
                    , impitnf.perc_reduc                                                       pPerc_Reduc
                 into vv_cst
                    , vv_baseicms_item
                    , vv_valoricms_item
                    , vv_aliquotaicms_item
                    , vv_perc_reduc
                 from Imp_ItemNf   impitnf
                    , Tipo_Imposto ti
                    , Cod_ST       cst
                where impitnf.itemnf_id = rec_item.itemnf_id
                  and impitnf.dm_tipo   = 0    -- Imposto
                  and ti.id             = impitnf.tipoimp_id
                  and ti.cd             = 1    -- ICMS
                  and cst.id            = impitnf.codst_id
                  and cst.tipoimp_id    = ti.id
                  and rownum            = 1;
            exception
               when no_data_found then
                  null;
               when others then
                  raise_application_error (-20101, 'Erro na pb_gera_danfe_nfe fase(' || vn_fase || ') ID (' || en_notafiscal_id || ': ' || sqlerrm);
            end;
            --
            vn_fase := 50;
            --
            if vv_cst in ('40', '41', '50') then -- Se for CST de ICMS Isenta, não atribui o valor
               --
               vn_fase := 50.1;
               --
               vv_baseicms_item     := '0,00';
               vv_valoricms_item    := '0,00';
               vv_aliquotaicms_item := '0,00';
               --
            end if;
	    --
	    vn_fase := 51;
	    --
            if nvl(rec_item.dm_mot_des_icms,0) > 0 and nvl(vv_perc_reduc,0) = 0 then
	       --
	       vn_fase := 51.1;
	       --
	       vv_baseicms_item     := ltrim(rtrim(to_char(0,'999g999g999g990d00')));
	       vv_valoricms_item    := ltrim(rtrim(to_char(0,'999g999g999g990d00')));
	       vv_aliquotaicms_item := ltrim(rtrim(to_char(0,'990d00')));
	       --
	    end if;
            --
            vn_fase := 52;
            -- valores de ICMS-ST do item
            begin
               select ltrim(rtrim(to_char(nvl(impitnf.vl_base_calc,0),'999g999g999g990d00')))  vBC_icms
                    , ltrim(rtrim(to_char(nvl(impitnf.vl_imp_trib,0),'999g999g999g990d00')))   vICMS_icms
                 into vv_baseicmsst_item
                    , vv_valoricmsst_item
                 from Imp_ItemNf   impitnf
                    , Tipo_Imposto ti
                where impitnf.itemnf_id = rec_item.itemnf_id
                  and impitnf.dm_tipo   = 0    -- Imposto
                  and ti.id             = impitnf.tipoimp_id
                  and ti.cd             = 2    -- ICMS-ST
                  and rownum            = 1;
            exception
               when no_data_found then
                  null;
               when others then
                  raise_application_error (-20101, 'Erro na pb_gera_danfe_nfe fase(' || vn_fase || ') ID (' || en_notafiscal_id || ': ' || sqlerrm);
            end;
            --
            vn_fase := 53;
            --
            begin
               select cst.cod_st CST
                 into vv_cst_sn
                 from Imp_ItemNf   impitnf
                    , Tipo_Imposto ti
                    , Cod_ST       cst
                where impitnf.itemnf_id = rec_item.itemnf_id
                  and impitnf.dm_tipo   = 0    -- Imposto
                  and ti.id             = impitnf.tipoimp_id
                  and ti.cd             = 10    -- Simples Nacional
                  and cst.id            = impitnf.codst_id
                  and cst.tipoimp_id    = ti.id
                  and rownum            = 1;
               --
            exception
               when no_data_found then
                  null;
               when others then
                  raise_application_error (-20101, 'Erro na pb_gera_danfe_nfe fase(' || vn_fase || ') ID (' || en_notafiscal_id || ': ' || sqlerrm);
            end;
            --
            vn_fase := 54;
            -- Acetar campo de CST
            if trim(vv_cst_sn) is not null then
               vv_cst := rec_item.origem || vv_cst_sn;
            else
               vv_cst := rec_item.origem || vv_cst;
            end if;
            --
            vn_fase := 55;
            -- valores de IPI do item
            begin
               select ltrim(rtrim(to_char(nvl(impitnf.aliq_apli,0),'990d00')))
                    , ltrim(rtrim(to_char(nvl(impitnf.vl_imp_trib,0),'999g999g999g990d00'))) vIPI
                 into vv_aliquotaipi_item
                    , vv_valoripi_item
                 from Imp_ItemNf   impitnf
                    , Tipo_Imposto ti
                where impitnf.itemnf_id = rec_item.itemnf_id
                  and impitnf.dm_tipo   = 0    -- Imposto
                  and ti.id             = impitnf.tipoimp_id
                  and ti.cd             = 3    -- IPI
                  and rownum            = 1;
            exception
               when others then
                  vv_aliquotaipi_item := '0,00';
                  vv_valoripi_item    := '0,00';
            end;
            --
            vn_fase := 56;
            --
            -- Verificar se a numeração do FCI existe e está parametrizado para aparecer na DANFE.
           if (trim(rec_item.nro_fci) is not null) and (nvl(vn_dm_impr_danfe_fci,0) = 1) then
               --
               vv_infadprod := trim(substr(vv_infadprod || ' FCI: ' || rec_item.nro_fci, 1 , 500));
               --
            end if;
            --
            -- Verificar se Código CEST existe e está parametrizado para aparecer na DANFE.
            if (trim(rec_item.cod_cest) is not null) and (nvl(vn_dm_impr_danfe_cest,0) = 1) then
               --
               vv_infadprod  := trim(substr(vv_infadprod || ' CEST: ' || rec_item.cod_cest, 1 , 500));
               --
            end if;
            --
            vn_fase := 57;
            --
            begin
               select min(ii.id)
                 into vn_impritemnfe_id
                 from impr_item_nfe ii
                where ii.imprcabnfe_id = vn_imprcabnfe_id
                  and ii.notafiscal_id = en_notafiscal_id
                  and ii.itemnf_id     = vn_itemnf_id;
            exception
               when others then
                  vn_impritemnfe_id := 0;
            end;
            --
            vn_fase := 58;
            --
            if nvl(vn_impritemnfe_id,0) = 0 then
               --
               vn_fase := 58.1;
               --
               begin
                  select impritemnfe_seq.nextval
                    into vn_impritemnfe_id
                    from dual;
               exception
                  when others then
                     vn_impritemnfe_id := 0;
               end;
               --
               vn_fase := 58.2;
               --
               begin
                  insert into impr_item_nfe ( id
                                            , imprcabnfe_id
                                            , notafiscal_id
                                            , itemnf_id
                                            , nro_item
                                            , infadprod
                                            , codigo
                                            , descricao
                                            , ncm
                                            , cst
                                            , cfop
                                            , unidade
                                            , quantidade
                                            , valorunitario
                                            , valortotal
                                            , baseicms
                                            , valoricms
                                            , valoripi
                                            , aliquotaicms
                                            , aliquotaipi
                                            , baseicmsst
                                            , valoricmsst
                                            , vldescontoitem
                                            , cod_cest
                                            )
                                     values ( vn_impritemnfe_id
                                            , vn_imprcabnfe_id
                                            , en_notafiscal_id
                                            , vn_itemnf_id
                                            , vn_nro_item
                                            , vv_infadprod
                                            , vv_codigo
                                            , vv_descricao
                                            , vv_ncm
                                            , vv_cst
                                            , vv_cfop
                                            , vv_unidade
                                            , vv_quantidade
                                            , vv_valorunitario
                                            , vv_valortotal_item
                                            , vv_baseicms_item
                                            , vv_valoricms_item
                                            , vv_valoripi_item
                                            , vv_aliquotaicms_item
                                            , vv_aliquotaipi_item
                                            , vv_baseicmsst_item
                                            , vv_valoricmsst_item
                                            , vv_vldescontoitem
                                            , vv_cod_cest
                                            );
               exception
                  when others then
                     --
                     vv_mensagem_log := 'Problemas ao incluir dados em impr_item_nfe (notafiscal_id = '||en_notafiscal_id||') - pb_gera_danfe_nfe '||
                                        'fase('||vn_fase||'). Erro = '||sqlerrm;
                     --
                     declare
                        vn_loggenerico_id  Log_Generico_nf.id%type := null;
                     begin
                        pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                       , ev_mensagem         => vv_mensagem_log
                                                       , ev_resumo           => vv_mensagem_log
                                                       , en_tipo_log         => erro_de_sistema
                                                       , en_referencia_id    => en_notafiscal_id
                                                       , ev_obj_referencia   => 'NOTA_FISCAL' );
                     exception
                        when others then
                           null;
                     end;
                     --
               end;
               --
            else
               --
               vn_fase := 58.3;
               --
               begin
                  update impr_item_nfe ii
                     set ii.nro_item       = vn_nro_item
                       , ii.infadprod      = vv_infadprod
                       , ii.codigo         = vv_codigo
                       , ii.descricao      = vv_descricao
                       , ii.ncm            = vv_ncm
                       , ii.cst            = vv_cst
                       , ii.cfop           = vv_cfop
                       , ii.unidade        = vv_unidade
                       , ii.quantidade     = vv_quantidade
                       , ii.valorunitario  = vv_valorunitario
                       , ii.valortotal     = vv_valortotal_item
                       , ii.baseicms       = vv_baseicms_item
                       , ii.valoricms      = vv_valoricms_item
                       , ii.valoripi       = vv_valoripi_item
                       , ii.aliquotaicms   = vv_aliquotaicms_item
                       , ii.aliquotaipi    = vv_aliquotaipi_item
                       , ii.baseicmsst     = vv_baseicmsst_item
                       , ii.valoricmsst    = vv_valoricmsst_item
                       , ii.vldescontoitem = vv_vldescontoitem
                       , ii.cod_cest       = vv_cod_cest
                   where ii.id            = vn_impritemnfe_id
                     and ii.imprcabnfe_id = vn_imprcabnfe_id
                     and ii.notafiscal_id = en_notafiscal_id
                     and ii.itemnf_id     = vn_itemnf_id;
               exception
                  when others then
                     --
                     vv_mensagem_log := 'Problemas ao alterar dados em impr_item_nfe (notafiscal_id = '||en_notafiscal_id||') - pb_gera_danfe_nfe '||
                                        'fase('||vn_fase||'). Erro = '||sqlerrm;
                     --
                     declare
                        vn_loggenerico_id  Log_Generico_nf.id%type := null;
                     begin
                        pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                       , ev_mensagem         => vv_mensagem_log
                                                       , ev_resumo           => vv_mensagem_log
                                                       , en_tipo_log         => erro_de_sistema
                                                       , en_referencia_id    => en_notafiscal_id
                                                       , ev_obj_referencia   => 'NOTA_FISCAL' );
                     exception
                        when others then
                           null;
                     end;
                     --
               end;
               --
            end if;
            --
         end loop; -- fim c_item
         --
         vn_fase := 59;
         --
         for rec_inf in c_infnfrom(en_notafiscal_id)
         loop
            --
            exit when c_infnfrom%notfound or (c_infnfrom%notfound) is null;
            --
            vn_fase := 60;
            --
            begin
               select min(ii.id)
                 into vn_imprinfnfromaneio_id
                 from impr_inf_nf_romaneio ii
                where ii.imprcabnfe_id    = vn_imprcabnfe_id
                  and ii.notafiscal_id    = en_notafiscal_id
                  and ii.infnfromaneio_id = rec_inf.infnfromaneio_id;
            exception
               when others then
                  vn_imprinfnfromaneio_id := 0;
            end;
            --
            vn_fase := 60.1;
            --
            if nvl(vn_imprinfnfromaneio_id,0) = 0 then
               --
               vn_fase := 60.2;
               --
               begin
                  insert into impr_inf_nf_romaneio ( id
                                                   , imprcabnfe_id
                                                   , notafiscal_id
                                                   , infnfromaneio_id
                                                   , cnpj_cpf
                                                   , nro_nf
                                                   , serie
                                                   , dt_emiss )
                                            values ( imprinfnfromaneio_seq.nextval
                                                   , vn_imprcabnfe_id
                                                   , en_notafiscal_id
                                                   , rec_inf.infnfromaneio_id
                                                   , rec_inf.cnpj_cpf
                                                   , rec_inf.nro_nf
                                                   , rec_inf.serie
                                                   , rec_inf.dt_emiss
                                                   );
               exception
                  when others then
                     --
                     vv_mensagem_log := 'Problemas ao incluir dados em impr_inf_nf_romaneio (notafiscal_id = '||en_notafiscal_id||') - '||
                                        'pb_gera_danfe_nfe fase('||vn_fase||'). Erro = '||sqlerrm;
                     --
                     declare
                        vn_loggenerico_id  Log_Generico_nf.id%type := null;
                     begin
                        pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                       , ev_mensagem         => vv_mensagem_log
                                                       , ev_resumo           => vv_mensagem_log
                                                       , en_tipo_log         => erro_de_sistema
                                                       , en_referencia_id    => en_notafiscal_id
                                                       , ev_obj_referencia   => 'NOTA_FISCAL' );
                     exception
                        when others then
                           null;
                     end;
                     --
               end;
               --
            else
               --
               vn_fase := 60.3;
               --
               begin
                  update impr_inf_nf_romaneio ii
                     set ii.cnpj_cpf = rec_inf.cnpj_cpf
                       , ii.nro_nf   = rec_inf.nro_nf
                       , ii.serie    = rec_inf.serie
                       , ii.dt_emiss = rec_inf.dt_emiss
                   where ii.id               = vn_imprinfnfromaneio_id
                     and ii.imprcabnfe_id    = vn_imprcabnfe_id
                     and ii.notafiscal_id    = en_notafiscal_id
                     and ii.infnfromaneio_id = rec_inf.infnfromaneio_id;
               exception
                  when others then
                     --
                     vv_mensagem_log := 'Problemas ao alterar dados em impr_inf_nf_romaneio (notafiscal_id = '||en_notafiscal_id||') - '||
                                        'pb_gera_danfe_nfe fase('||vn_fase||'). Erro = '||sqlerrm;
                     --
                     declare
                        vn_loggenerico_id  Log_Generico_nf.id%type := null;
                     begin
                        pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                       , ev_mensagem         => vv_mensagem_log
                                                       , ev_resumo           => vv_mensagem_log
                                                       , en_tipo_log         => erro_de_sistema
                                                       , en_referencia_id    => en_notafiscal_id
                                                       , en_empresa_id       => vn_empresa_id
                                                       , ev_obj_referencia   => 'NOTA_FISCAL' );
                     exception
                        when others then
                           null;
                     end;
                     --
               end;
               --
            end if;
            --
         end loop;
         --
      end if;
      --
      vn_fase := 60.4;
      --
      -- no caso de alguma nota fiscal ficar com o campo nota_fiscal.dm_impressa = 6, voltamos ele para 0 e 
      -- nota_fiscal.nro_tentativas_impr = 0 para que o jar de impressão reprocesse a impressaõ
      begin
          update nota_fiscal n 
             set n.dm_impressa         = 0
                ,n.nro_tentativas_impr = 0
           where 1=1
             and n.dm_impressa = 6
             and n.dm_ind_emit = 0
             and n.dm_st_proc  = 4
             and n.empresa_id  in (select n.empresa_id
                                     from nota_fiscal n
                                    where n.id = en_notafiscal_id
                                  )
             and trunc(n.dt_emiss) between trunc(sysdate-30) and trunc(sysdate-2);
       exception
         when others then
           --
           vv_mensagem_log := 'Problemas ao alterar dados dm_impressa e nro_tentativas_impr para 0 para a (notafiscal_id = '||en_notafiscal_id||') - '||
                              'pb_gera_danfe_nfe fase('||vn_fase||'). Erro = '||sqlerrm;
           --
           declare
              vn_loggenerico_id  Log_Generico_nf.id%type := null;
           begin
              pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                             , ev_mensagem         => vv_mensagem_log
                                             , ev_resumo           => vv_mensagem_log
                                             , en_tipo_log         => erro_de_sistema
                                             , en_referencia_id    => en_notafiscal_id
                                             , en_empresa_id       => vn_empresa_id
                                             , ev_obj_referencia   => 'NOTA_FISCAL' );
           exception
              when others then
                 null;
           end;
           --
       end;
      --
   end if;
   --
   vn_fase := 61;
   --
   commit;
   --
   if vv_mensagem_log is null then
    --
    vv_mensagem_log := 'DANFE gerado.' ;
    --
    declare
       vn_loggenerico_id  Log_Generico_nf.id%type := null;
    begin
       --
       pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                      , ev_mensagem         => vv_mensagem_log
                                      , ev_resumo           => vv_mensagem_log ||' NFE:'||vv_numeronfe ||' - Serie:'||vv_serienfe
                                      , en_tipo_log         => informacao
                                      , en_referencia_id    => en_notafiscal_id
                                      , en_empresa_id       => vn_empresa_id
                                      , ev_obj_referencia   => 'NOTA_FISCAL' );
       --
    exception
       when others then
          null;
    end;
    --
   end if;
   --
exception
   when others then
      --
      rollback;
      --
      vv_mensagem_log := 'Erro na pb_gera_danfe_nfe fase(' || vn_fase || ') ID (' || en_notafiscal_id || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico_nf.id%type := null;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => vv_mensagem_log
                                        , ev_resumo           => vv_mensagem_log
                                        , en_tipo_log         => erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pb_gera_danfe_nfe;
/
