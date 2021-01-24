create or replace package csf_own.pk_csf_ciap is

-------------------------------------------------------------------------------------------------------
-- Especificação do pacote de funções de CIAP
--
-- Em 12/11/2020 - Eduardo Linden
-- Redmine #73300 - Incluir validação para evitar de haver mais de registro no mesmo mês (CIAP)
-- Função valida se há registro na tabela icms_atperm_ciap no mesmo mes/ano.
-- Nova função: fkg_icmsatpermciap_mes
-- Para o release 297 e patches Patch_2.9.5.4 e Patch_2.9.6.1
--
-- Em 24/02/2020 - Luis Marques
-- Redmine #64984 - Integração do G140 juntando os itens
-- Nova Funções: fkg_movatper_id, fkg_outrocredciap_id, fkg_movatperdocfiscal_id, fkg_movatperdocfiscalitem_id - para 
--               retornar os id(s) das tabelas mov_atperm, outro_cred_ciap, mov_atperm_doc_fiscal e mov_atperm_doc_fiscal_item.
-- 
-- ====================================================================================================
-- Em 10/05/2012 - Angela Inês.
-- 1) Alterada a função fkg_existe_itemdocfiscal_ciap - Função retorna o True se existe Item do Documento Fiscais para o Bem ou Componente Imobilizado.
--    Considerar a existência de registro (rownum=1), pois pode haver mais de um no processo.
--
-- Em 14/01/2014 - Angela Inês.
-- Redmine #1780 - Integração do CIAP correção no Índice de Participação:
-- No processo ERP/SGI o valor do índice é considerado 1 quando o valor total das saídas estiver zerado (icms_atperm_ciap.vl_total = 0), caso contrário,
-- o cálculo é feito dividindo o Valor tributado de exportação pelo Valor total das saídas (icms_atperm_ciap.vl_trib_exp / icms_atperm_ciap.vl_total).
-- Alteramos o processo para atender da mesma forma. Rotina: fkg_ind_per_sai_calc.
--
-- Em 02/04/2014 - Angela Inês.
-- Redmine #2281 - Processo de Validação do CIAP.
-- Inclusão da função que retorna True se a empresa obriga validação do documento fiscal relacionado ao CIAP através do identificador da empresa.
-- Rotina: fkg_valdocfiscciap_empresa.
--
-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do Bem do Ativo Imobilizado
function fkg_bemativoimob_id ( en_empresa_id   in  empresa.id%type
                             , ev_cod_ind_bem  in  bem_ativo_imob.cod_ind_bem%type
                             )
         return bem_ativo_imob.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do Movimento do Bem do Ativo Imobilizado
function fkg_icmsatpermciap_id ( en_empresa_id   in  empresa.id%type
                               , ed_dt_ini  in  icms_atperm_ciap.dt_ini%type
                               , ed_dt_fin  in  icms_atperm_ciap.dt_fin%type
                             )
         return icms_atperm_ciap.id%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o True se existe Movimento do Bem do Ativo Imobilizado e false se não.
function fkg_existe_ciap ( en_icmsatpermciap_id   in  icms_atperm_ciap.id%type )
        return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna o dm_st_proc do Movimento do CIAP.
function fkg_dm_st_proc_ciap ( en_icmsatpermciap_id   in  icms_atperm_ciap.id%type )
        return icms_atperm_ciap.dm_st_proc%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o calculo ind_per_sai do Movimento do CIAP.
function fkg_ind_per_sai_calc ( en_icmsatpermciap_id   in  icms_atperm_ciap.id%type )
        return icms_atperm_ciap.ind_per_sai%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o codigo do Bem do Ativo Imobilizado
function fkg_bemativoimob_cd ( en_bemativoimob_id  in bem_ativo_imob.id%type)
         return bem_ativo_imob.cod_ind_bem%type;

-------------------------------------------------------------------------------------------------------

-- Função retorno se um Imobilizado é bem ou Componente Através do ID
function fkg_bemativoimob_ind ( en_bemativoimob_id in bem_ativo_imob.id%type)
         return bem_ativo_imob.dm_ident_merc%type;

-------------------------------------------------------------------------------------------------------

-- Função retorno da quantidade de parcelas que um Imobilizado pode tomar crédito
function fkg_bemativoimob_par ( en_bemativoimob_id  in bem_ativo_imob.id%type)
         return bem_ativo_imob.nr_parc%type;

-------------------------------------------------------------------------------------------------------

-- Função retorno da quantidade de registros de movimento por periodo de apuração
function fkg_movatperm_qtde ( en_icmsatpermciap_id in icms_atperm_ciap.id%type
                            , en_bemativoimob_id   in bem_ativo_imob.id%type)
         return number;

-------------------------------------------------------------------------------------------------------

-- Função retorno 1 se existe registro de baixa no período de apuração e zero caso não haja.
function fkg_existe_mov_ciap ( en_icmsatpermciap_id in icms_atperm_ciap.id%type
                             , en_bemativoimob_id   in bem_ativo_imob.id%type
                             , ev_dm_tipo_mov       in mov_atperm.dm_tipo_mov%type )
         return number;

-------------------------------------------------------------------------------------------------------

-- Função retorna o calculo ind_per_sai dos Outros Créditos do Ciap.
function fkg_ind_per_out_cred ( en_outrocredciap_id   in  outro_cred_ciap.id%type )
        return outro_cred_ciap.ind_per_sai%type;

-------------------------------------------------------------------------------------------------------

-- Função retorna o True se existe Documento Fiscais para o Bem ou Componente Imobilizado
function fkg_existe_doc_fiscal_ciap ( en_movatperm_id in  mov_atperm.id%type )
        return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorno da quantidade de registros de movimento por periodo de apuração
function fkg_movatpermdocfiscal_qtde ( en_icmsatpermciap_id in icms_atperm_ciap.id%type
                                     , en_bemativoimob_id   in bem_ativo_imob.id%type )
         return number;

-------------------------------------------------------------------------------------------------------

-- Função retorna o True se existe Item do Documento Fiscais para o Bem ou Componente Imobilizado
function fkg_existe_itemdocfiscal_ciap ( en_movatpermdocfiscal_id in  mov_atperm_doc_fiscal_item.id%type )
        return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna id da utilização do bem através do id do ativo imobilizado
function fkg_inforutilbem_id ( en_bemativoimob_id  bem_ativo_imob.id%type)
         return infor_util_bem.id%type;

------------------------------------------------------------------------------------------------------- 

-- Função retorna True se existe Informação da Utilização do Bem através do id
function fkg_existe_inforutilbem_id ( en_bemativoimob_id  bem_ativo_imob.id%type)
        return boolean;

-------------------------------------------------------------------------------------------------------

-- Função retorna True se a empresa obriga validação do documento fiscal relacionado ao CIAP através do identificador da empresa
function fkg_valdocfiscciap_empresa ( en_empresa_id in empresa.id%type )
        return boolean;


-------------------------------------------------------------------------------------------------------

-- Função retorna o id do registro de baixa no período de apuração 
function fkg_movatper_id ( en_icmsatpermciap_id   in icms_atperm_ciap.id%type
                         , en_bemativoimob_id     in bem_ativo_imob.id%type
                         , ev_dm_tipo_mov         in mov_atperm.dm_tipo_mov%type)
         return number;

-------------------------------------------------------------------------------------------------------

-- Função retorna o id dos outros creditos do CIAP
function fkg_outrocredciap_id ( en_movatperm_id   in mov_atperm.id%type
                              , ed_dt_ini         in outro_cred_ciap.dt_ini%type
                              , ed_dt_fim         in outro_cred_ciap.dt_fim%type
                              , en_num_parc       in outro_cred_ciap.num_parc%type )
         return number;							       

-------------------------------------------------------------------------------------------------------

-- Função retorna o id do documento fiscal do registro de baixa no período de apuração 
function fkg_movatperdocfiscal_id ( en_movatperm_id   in mov_atperm.id%type
                                  , en_dm_ind_emit    in mov_atperm_doc_fiscal.dm_ind_emit%type
                                  , en_pessoa_id      in mov_atperm_doc_fiscal.pessoa_id%type
                                  , en_modfiscal_id   in mov_atperm_doc_fiscal.modfiscal_id%type
                                  , ev_serie          in mov_atperm_doc_fiscal.serie%type
                                  , en_num_doc        in mov_atperm_doc_fiscal.num_doc%type                                  								  
                                  , en_chv_nfe_cte    in mov_atperm_doc_fiscal.chv_nfe_cte%type )
         return number;
		 
-------------------------------------------------------------------------------------------------------

-- Função retorna o id do item do documento fiscal do registro de baixa no período de apuração 
function fkg_movatperdocfiscalitem_id ( en_movatpermdocfiscal_id   in mov_atperm_doc_fiscal.id%type
                                      , en_num_item                in mov_atperm_doc_fiscal_item.num_item%type
                                      , en_item_id                 in mov_atperm_doc_fiscal_item.item_id%type )
         return number;		 

-------------------------------------------------------------------------------------------------------
--Função valida se há registro na tabela icms_atperm_ciap no mesmo mes/ano.

function fkg_icmsatpermciap_mes ( en_empresa_id   in  empresa.id%type
                                , ed_dt_ini  in  icms_atperm_ciap.dt_ini%type
                                ) return integer;
------------------------------------------------------------------------------------------------------- 
end pk_csf_ciap;
/
