create or replace package csf_own.pk_csf_api_cons_sit is
--
-- Especificação do pacote de validação da CSF_CONS_SIT
--
-- Em 18/11/2020      - Karina de Paula
-- Redmine #71682     - Looping na tabela CSF_OWN.CSF_CONS_SIT após atualização da 2.9.4.1 (NOVA AMERICA)
-- Rotina Alterada    - pkb_valid_cons_chave_nfe e pkb_valid_ct_cons_sit => Alterada a verificação do valor retornado da função pk_csf.fkg_Estado_ibge_id
-- Liberado na versão - Release_2.9.6, Patch_2.9.5.2 e Patch_2.9.4.5
--
-- Em 20/10/2020   - Luiz Armando/Luis Marques - 2.9.5-1 / 2.9.6
-- Redmine #72513  - Alerta DBSI
-- Rotina Alterada - pkb_ins_atu_ct_cons_sit - Colocação de NVL nas colunas "dm_rec_fisico","dm_integr_erp", "dm_st_integra"
--
-- Em 14/09/2020   - Karina de Paula
-- Redmine #67105  - Criar processo de validação da CT_CONS_SIT
-- Rotina Criada   - pkb_integr_ct_cons_sit      => Rotina criada para ficar no lugar da rotina excluída pk_csf_api_ct.pkb_integr_ct_cons_sit
--                 -                                Inserida chamada da validação da chave(pkb_valid_ct_cons_sit) e rotina de inserção e atualização (pkb_ins_atu_ct_cons_sit)
--                 - pkb_integr_ct_cons_sit      => Passa a integrar o valor da DM_SITUACAO como "0 - Aguardando validação"
--                 - pkb_log_generico_conssit_ct => Criada para gerar o log p ct
--                 - pkb_valid_ct_cons_sit       => Rotina criada para validação da chave do ct
--                 - pkb_ins_atu_ct_cons_sit     => Rotina criada para inserção e atualização dos dados na ct_cons_sit
-- Liberado        - Release_2.9.5
--
-- Em 07/08/2020      - Karina de Paula
-- Redmine #70213     - Erro ORA-6544 [pevm_peruws_callback-1] [1400] [] [] [] [] [] [] [] [] [] [] (NOVA AMERICA)
-- Rotina Alterada    - pkb_integr_cons_chave_nfe => Retirada a (pk_csf_api_cons_sit.gt_row_csf_cons_sit recebendo null) pq estava gerando
--                    - erro na est_row_csf_cons_sit.chnfe que tb ficava null
--                    - pkb_log_generico_conssit  => A exception estava chamando a sí mesma, gerando um loop infinito
-- Liberado na versão - Release_2.9.4, Patch_2.9.4.1 e Patch_2.9.3.4
--                      Release_2.9.5, Patch_2.9.4.2 e Patch_2.9.3.5
--
-- Em 24/04/2020      - Karina de Paula
-- Redmine #62471     - Criar processo de validação da CSF_CONS_SIT
-- Redmine #63341     - Erro na integração da chave persiste
-- Criação da package de validação da CSF_CONS_SIT
-- Liberado na versão - Release_2.9.4, Patch_2.9.3.1 e Patch_2.9.2.4
--
-- ====================================================================================================================== --
--
-- Variáveis globais
   gv_resumo           log_generico_nf.resumo%type;
   gv_mensagem         log_generico_nf.mensagem%type;
   gn_processo_id      log_generico_nf.processo_id%TYPE := null;
   gn_empresa_id       empresa.id%type;
   --
   gn_tipo_integr      number := null;
   gv_obj_referencia   log_generico_nf.obj_referencia%type;
   gn_referencia_id    log_generico_nf.referencia_id%type := null;
   gv_objeto           varchar2(300);
   gn_fase             number;
   gt_row_csf_cons_sit csf_cons_sit%rowtype;
   gt_row_ct_cons_sit  ct_cons_sit%rowtype;
   --
-- Declaração de constantes
   erro_de_validacao  constant number := 1;
   erro_de_sistema    constant number := 2;
   informacao         constant number := 35;
   cons_sit_nfe_sefaz  constant number := 30;
--
-- ====================================================================================================================== --
-- Procedimento de atualização da tabela CSF_CONS_SIT
procedure pkb_ins_atu_csf_cons_sit ( est_row_csf_cons_sit in out nocopy csf_cons_sit%rowtype
                                   , ev_campo_atu         in varchar2
                                   , en_tp_rotina         in number
                                   , ev_rotina_orig       in varchar2
                                   );
--
-- ====================================================================================================================== --
-- Procedimento de validação dos dados da chave da nf
procedure pkb_valid_cons_chave_nfe ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                   , est_row_csf_cons_sit in out nocopy  csf_cons_sit%rowtype
                                   , en_multorg_id        in             mult_org.id%type
                                   , ev_rotina            in             varchar2 default null
                                   );
--
-- ====================================================================================================================== --
-- Procedimento de integração de consulta chave nfe
procedure pkb_integr_cons_chave_nfe ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                    , est_row_csf_cons_sit in out nocopy  csf_cons_sit%rowtype
                                    , ev_cpf_cnpj_emit     in             varchar2
                                    , en_multorg_id        in             mult_org.id%type
                                    , ev_rotina            in             varchar2 default null
                                    );
--
-- ====================================================================================================================== --
-- Procedimento de atualização da tabela CT_CONS_SIT                                 
procedure pkb_ins_atu_ct_cons_sit ( est_row_ct_cons_sit in out nocopy ct_cons_sit%rowtype
                                  , ev_campo_atu        in varchar2
                                  , en_tp_rotina        in number
                                  , ev_rotina_orig      in varchar2
                                  );
--
-- ====================================================================================================================== --
-- Procedimento de validação dos dados da chave da ct
procedure pkb_valid_ct_cons_sit ( est_log_generico_ct in out nocopy  dbms_sql.number_table
                                , est_row_ct_cons_sit in out nocopy  ct_cons_sit%rowtype
                                , en_multorg_id       in             mult_org.id%type
                                , ev_rotina           in             varchar2 default null
                                );
--
-- ====================================================================================================================== --
-- Procedimento de integração de consulta chave ct
procedure pkb_integr_ct_cons_sit ( est_log_generico_ct in out nocopy  dbms_sql.number_table
                                 , est_row_ct_cons_sit in out nocopy  ct_cons_sit%rowtype
                                 , ev_cpf_cnpj_emit    in             varchar2
                                 , en_multorg_id       in             mult_org.id%type
                                 , ev_rotina           in             varchar2 default null
                                 );
--
-- ====================================================================================================================== --
--
end pk_csf_api_cons_sit;
/