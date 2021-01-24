create or replace package csf_own.pk_csf_api_ciap is

-------------------------------------------------------------------------------------------------------
--
-- Especificação do pacote de integração de CIAP
--
-- Em 12/11/2020 - Eduardo Linden
-- Redmine #73300 - Incluir validação para evitar de haver mais de registro no mesmo mês (CIAP)
-- Inclusã da chamada da rotina pk_csf_ciap.fkg_icmsatpermciap_mes, para validar se há registro no mesmo periodo.
-- Rotina alterada: pkb_integr_icms_atperm_ciap.
-- Para o release 297 e patches Patch_2.9.5.4 e Patch_2.9.6.1
--
-- Em 24/01/2020 - Luis Marques
-- Redmine # 64984 - Integração do G140 juntando os itens
-- Rotinas Alteradas: pkb_integr_movatpermdocfisitem, pkb_integr_movatpermdocfiscal, pkb_integr_outro_cred_ciap, 
--                    pkb_integr_mov_atperm - Colocado verificação se já existe os movimentos faz update se não
--                    insere o registro.
--
-- Em 11/12/2019 - Luis Marques
-- Redmine #61703 - G130 novo campo NUM_DA
-- Nova Rotina: pkb_int_movatpermdocfiscal_ff - Integração dos campos flex-field dos documentos fiscais do CIAP.
--
-- Em 06/12/2019 - Luis Marques
-- Redmine #61757 - Criar campos na tabela MOV_ATPERM_DOC_FISCAL_ITEM
-- Nova Rotina: pkb_int_movatpermdocfisit_comp - Integração dos dados complementares do item do documento fiscal com
--              verificação dos valores de ICMS aplicado e unidade.
--
-- ====================================================================================================
--
-- Em 11/07/2013 - Angela Inês.
-- Correção nas mensagens para melhor entendimento dos clientes.
-- Inclusão da variável de log/informação.
--
-- Em 18/10/2013 - Angela Inês.
-- Redmine Melhoria #1121 - Validar as notas fiscais de imobilizado escrituradas no bloco de notas fiscais (C100) com as notas fiscais escrituradas no CIAP.
-- Rotinas/Alterações: pk_csf_api_ciap: alterar as chamadas das rotinas que possui "pk_csf_api_ciap.", pois já estão na package.
-- pkb_valida_ciap_nf: verificar se a NF da primeira parcela está integrada/autorizada no C100 - Notas Fiscais.
--
-- Em 18/02/2014 - Angela Inês.
-- Redmine #1941 - Suporte - Aline/Sta Vitória. CIAP - valores incorretos das parcelas.
-- 1) Alteração na mensagem de inconsistência dos valores referente as parcelas dos movimentos.
-- 2) Alteramos a validação da parcela considerando que o valor da parcela deva ser menor ou igual, e não diferente.
-- Rotina: pk_csf_api_ciap.pkb_valida_mov_atperm.
--
-- Em 02/04/2014 - Angela Inês.
-- Redmine #2281 - Processo de Validação do CIAP.
-- Alterar na package "PK_CSF_API_CIAP", o processo de validação que obriga a vinculação de um "Documento Fiscal Existente" ao calculo do ciap.
-- Rotina: pkb_valida_ciap_nf.
--
-- Em 05/11/2014 - Rogério Silva
-- Redmine #5020 - Processo de contagem de registros integrados do ERP (Agendamento de integração)
--
-- Em 06/01/2015 - Angela Inês.
-- Redmine #5616 - Adequação dos objetos que utilizam dos novos conceitos de Mult-Org.
--
-- Em 03/06/2015 - Rogério Silva
-- Redmine #8234 - Processo de Registro de Log em Packages - C. I. A. P.
--
-- Em 28/07/2015 - Angela Inês.
-- Redmine #10117 - Escrituração de documentos fiscais - Processos.
-- Inclusão do novo conceito de recuperação de data dos documentos fiscais para retorno dos registros.
--
-- Em 05/02/2016 - Rogério Silva
-- Redmine #13079 - Registro do Número do Lote de Integração Web-Service nos logs de validação
--
-- Em 14/04/2016 - Fábio Tavares
-- Redmine #16793 - Melhoria nas mensagens dos processos flex-field.
--
-- Em 05/08/2016 - Angela Inês.
-- Redmine #22115 - Correção na Validação do CIAP - Documentos Fiscais relacionados com o Bem do Ativo.
-- Na geração do CIAP, ao identificar o Documento Fiscal e o mesmo não existir conforme dados enviados, verificar se existe considerando o campo SERIE
-- como sendo numérico, desconsiderando os 0(zeros) à esquerda.
-- Rotina: pkb_valida_ciap_nf.
--
-------------------------------------------------------------------------------------------------------
--
   gt_row_icms_atperm_ciap           icms_atperm_ciap%rowtype;
--
   gt_row_mov_atperm                 mov_atperm%rowtype;
--
   gt_row_outro_cred_ciap            outro_cred_ciap%rowtype;
--
   gt_row_mov_atperm_doc_fiscal      mov_atperm_doc_fiscal%rowtype;
--
   gt_row_movatpermdocfiscal_item    mov_atperm_doc_fiscal_item%rowtype;
--
   gt_row_movatpermdocfisc_itcomp    mov_atperm_doc_fiscal_item%rowtype;
--   
-------------------------------------------------------------------------------------------------------

   gv_cabec_log          log_generico_ciap.mensagem%TYPE;
   --
   gv_cabec_log_item     log_generico_ciap.mensagem%TYPE;
   --
   gv_mensagem_log       log_generico_ciap.mensagem%TYPE;
   --
   gv_dominio            Dominio.descr%TYPE;
   --
   gn_icmsatpermciap_id  icms_atperm_ciap.id%TYPE;
   --
   gn_dm_tp_amb          Empresa.dm_tp_amb%TYPE := null;
   --
   gn_empresa_id         Empresa.id%type := null;
   --
   gn_processo_id        log_generico_ciap.processo_id%TYPE := null;
   --
   gv_obj_referencia     log_generico_ciap.obj_referencia%type default 'REDUCAO_Z_ECF';
   --
   gn_referencia_id      log_generico_ciap.referencia_id%type := null;
   --
   gn_tipo_integr        number := null;
   --
   gv_cd_obj             obj_integr.cd%type := '8';

-------------------------------------------------------------------------------------------------------

-- Declaração de constantes

   erro_de_validacao       constant number := 1;
   erro_de_sistema         constant number := 2;
   nota_fiscal_integrada   constant number := 16;
   informacao              constant number := 35;

-------------------------------------------------------------------------------------------------------

--| Procedimento seta o "ID de Referencia" utilizado na Validação da Informação
procedure pkb_seta_referencia_id ( en_id in number );

-------------------------------------------------------------------------------------------------------

--| Procedimento finaliza o Log Genérico

procedure pkb_finaliza_log_generico_ciap;

-------------------------------------------------------------------------------------------------------

--| Procedimento seta o objeto de referencia utilizado na Validação da Informação
procedure pkb_seta_obj_ref ( ev_objeto in varchar2 );

-------------------------------------------------------------------------------------------------------
--| Procedimento seta o tipo de integração que será feito
   -- 0 - Somente válida os dados e registra o Log de ocorrência
   -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
   -- Todos os procedimentos de integração fazem referência a ele

procedure pkb_seta_tipo_integr ( en_tipo_integr in number );

-------------------------------------------------------------------------------------------------------

-- Procedimento armazena o valor do "loggenerico_id"

procedure pkb_gt_log_generico_ciap ( en_loggenericociap_id  in             log_generico_ciap.id%TYPE
                                   , est_log_generico_ciap  in out nocopy  dbms_sql.number_table );

-------------------------------------------------------------------------------------------------------

--| Procedimento de registro de log de erros na validação do ECF

procedure pkb_log_generico_ciap ( sn_loggenericociap_id  out nocopy    log_generico_ciap.id%TYPE
                                , ev_mensagem            in            log_generico_ciap.mensagem%TYPE
                                , ev_resumo              in            log_generico_ciap.resumo%TYPE
                                , en_tipo_log            in            csf_tipo_log.cd_compat%type      default 1
                                , en_referencia_id       in            log_generico_ciap.referencia_id%TYPE  default null
                                , ev_obj_referencia      in            log_generico_ciap.obj_referencia%TYPE default null
                                , en_empresa_id          in            Empresa.Id%type                  default null
                                , en_dm_impressa         in            log_generico_ciap.dm_impressa%type    default 0 );

-------------------------------------------------------------------------------------------------------

--| Procedimento excluir os movimentos de CIAP

procedure pkb_excluir_ciap ( est_log_generico_ciap   in out nocopy  dbms_sql.number_table
                           , en_icmsatpermciap_id    in             icms_atperm_ciap.id%type
                           );

-------------------------------------------------------------------------------------------------------

--| Procedimento de Integração de Item do Documento Fiscal Complemento

procedure pkb_int_movatpermdocfisit_comp ( est_log_generico_ciap             in out nocopy  dbms_sql.number_table
                                         , est_row_movatpermdocfiscitcomp    in out nocopy  mov_atperm_doc_fiscal_item%rowtype
                                         );
-------------------------------------------------------------------------------------------------------											 

-- Procedimento de Integração de Item do Documento Fiscal
procedure pkb_integr_movatpermdocfisitem ( est_log_generico_ciap            in out nocopy  dbms_sql.number_table
                                         , est_row_movatpermdocfisitem      in out nocopy  mov_atperm_doc_fiscal_item%rowtype
                                         , ev_cod_item                      in             item.cod_item%type
                                         , en_empresa_id                    in             empresa.id%type
                                         );

-------------------------------------------------------------------------------------------------------

-- Procedimento de Integração do documento fiscal
procedure pkb_integr_movatpermdocfiscal ( est_log_generico_ciap            in out nocopy  dbms_sql.number_table
                                        , est_row_movatpermdocfiscal       in out nocopy  mov_atperm_doc_fiscal%rowtype
                                        , ev_cod_part                      in             pessoa.cod_part%type
                                        , ev_cod_mod                       in             mod_fiscal.cod_mod%type
                                        , en_multorg_id                    in             mult_org.id%type
                                        );

-------------------------------------------------------------------------------------------------------

-- Procedimento de Integração de Outros Créditos CIAP
procedure pkb_integr_outro_cred_ciap ( est_log_generico_ciap    in out nocopy  dbms_sql.number_table
                                     , est_row_outro_cred_ciap  in out nocopy  outro_cred_ciap%rowtype
                                     );

-------------------------------------------------------------------------------------------------------

-- Procedimento de Integração de Movimentação do Bem ou Componente do Ativo Imobilizado
procedure pkb_integr_mov_atperm ( est_log_generico_ciap       in out nocopy  dbms_sql.number_table
                                , est_row_mov_atperm          in out nocopy  mov_atperm%rowtype
                                , en_empresa_id               in             empresa.id%type
                                , ev_cod_ind_bem              in             bem_ativo_imob.cod_ind_bem%type
                                );

-------------------------------------------------------------------------------------------------------

-- Procedimento de integração do cabeçalho do CIAP
procedure pkb_integr_icms_atperm_ciap ( est_log_generico_ciap       in out nocopy  dbms_sql.number_table
                                      , est_row_icms_atperm_ciap    in out nocopy  icms_atperm_ciap%rowtype
                                      , ev_empresa_cpf_cnpj         in             varchar2                 default null -- CPF/CNPJ da empresa
                                      , en_multorg_id               in             mult_org.id%type
                                      , en_loteintws_id             in             lote_int_ws.id%type default 0
                                      );

-------------------------------------------------------------------------------------------------------

-- Procedure que consiste os dados do CIAP

procedure pkb_consistem_ciap ( est_log_generico_ciap  in out nocopy  dbms_sql.number_table
                             , en_icmsatpermciap_id   in             Icms_Atperm_Ciap.id%TYPE );

-------------------------------------------------------------------------------------------------------
procedure pkb_ret_multorg_id( est_log_generico       in out nocopy  dbms_sql.number_table
                            , ev_cod_mult_org        in             mult_org.cd%type
                            , ev_hash_mult_org       in             mult_org.hash%type
                            , sn_multorg_id          in out nocopy  mult_org.id%type
                            , en_referencia_id       in             Log_Generico_ciap.referencia_id%TYPE  default null
                            , ev_obj_referencia      in             Log_Generico_ciap.obj_referencia%TYPE default null
                            );

-------------------------------------------------------------------------------------------------------

-- Procedimento valida o mult org de acordo com o COD e o HASH das tabelas Flex-Field

procedure pkb_val_atrib_multorg ( est_log_generico   in out nocopy  dbms_sql.number_table
                                , ev_obj_name        in             VARCHAR2
                                , ev_atributo        in             VARCHAR2
                                , ev_valor           in             VARCHAR2
                                , sv_cod_mult_org    out            VARCHAR2
                                , sv_hash_mult_org   out            VARCHAR2
                                , en_referencia_id   in             Log_Generico_ciap.referencia_id%TYPE  default null
                                , ev_obj_referencia  in             Log_Generico_ciap.obj_referencia%TYPE default null
                                );
                                
-------------------------------------------------------------------------------------------------------

-- Integra as informacões do Documento Fiscal CIAP - campos flex field

procedure pkb_int_movatpermdocfiscal_ff ( est_log_generico_ciap     in out nocopy  dbms_sql.number_table
                                        , en_movatpermdocfiscal_id  in             mov_atperm_doc_fiscal.id%type
                                        , ev_atributo               in             varchar2
                                        , ev_valor                  in             varchar2
                                        , en_referencia_id          in             Log_Generico_ciap.referencia_id%TYPE  default null
                                        , ev_obj_referencia         in             Log_Generico_ciap.obj_referencia%TYPE default null
                                        );

-------------------------------------------------------------------------------------------------------

end pk_csf_api_ciap;
/
