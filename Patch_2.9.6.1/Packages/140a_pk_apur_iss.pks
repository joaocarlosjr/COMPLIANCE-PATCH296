create or replace package csf_own.pk_apur_iss is

-------------------------------------------------------------------------------------------------------
-- Especificação do pacote de procedimentos de Apuração do ISS
--
-- Em 22/11/2020     - João Carlos
-- Distribuições     - 2.9.6 / 2.9.5-3 / 2.9.4-6
-- Redmine #73566    - Adicionada condição and sit.cd in ('00', '01', '06', '07', '08') -- 00-Documento regular, 01-Documento regular extemporaneo, 06-NF-e ou CT-e Numeração inutilizada, 07-Documento Fiscal Complementar extemporaneo e 08-Documento Fiscal emitido com base em Regime Especial ou Norma Especifica
--                   - Retornar somente os documento regulares.
-- Rotinas Alteradas - cursor c_apur_iss
-- Em 26/08/2020 - Marcos Ferreira
-- Distribuições: 2.9.5 / 2.9.4.2
-- Redmine #70423	Criar procedimento de apuração de ISS
-- Rotinas Criação da package e das procedures
--
--
-------------------------------------------------------------------------------------------------------
   -- GLOBAL VARIAVEIS
   --
   gn_loggenerico_id   log_generico_apur_iss.id%TYPE;
   gv_obj_referencia   log_generico_apur_iss.obj_referencia%type := 'APUR_ISS_SIMPLIFICADA';
   gn_referencia_id    log_generico_apur_iss.referencia_id%type;
   gn_processo_id      log_generico_apur_iss.processo_id%type;
   gv_mensagem_log     log_generico_apur_iss.mensagem%type;
   gv_resumo_log       log_generico_apur_iss.resumo%type;
   gn_erro             number := 0;
   gn_empresa_id       empresa.id%type;
   --
   ERRO_DE_VALIDACAO   CONSTANT NUMBER := 1;
   ERRO_DE_SISTEMA     CONSTANT NUMBER := 2;
   INFORMACAO          CONSTANT NUMBER := 35;
   --

-------------------------------------------------------------------------------------------------------
   -- CURSORES
   --
   -- Cursor para apuração do ISS --
   cursor c_apur_iss (en_apurisssimplificada_id apur_iss_simplificada.id%type) is
   select case when imp.dm_tipo = 0 then nvl(sum(imp.vl_imp_trib),0) else 0 end  vl_iss_proprio
        , case when imp.dm_tipo        = 1
                and nf.dm_arm_nfe_terc = 0
                and nf.dm_ind_emit     = 1
          then nvl(sum(imp.vl_imp_trib),0) else 0 end                            vl_iss_retido
     from APUR_ISS_SIMPLIFICADA ais,
          NOTA_FISCAL            nf,
          ITEM_NOTA_FISCAL      inf,
          IMP_ITEMNF            imp,
          MOD_FISCAL             mf,
          TIPO_IMPOSTO           tp,
          SIT_DOCTO             sit
   where inf.notafiscal_id = nf.id
     and imp.itemnf_id     = inf.id
     and mf.id             = nf.modfiscal_id
     and sit.id            = nf.sitdocto_id
     and sit.cd            in ('00', '01', '06', '07', '08') -- 00-Documento regular, 01-Documento regular extemporaneo, 06-NF-e ou CT-e Numeração inutilizada, 07-Documento Fiscal Complementar extemporaneo e 08-Documento Fiscal emitido com base em Regime Especial ou Norma Especifica #73566
     and mf.cod_mod        = '99' -- nota fiscal de servico
     and tp.cd             = '6'  -- ISS
     and ais.id            = en_apurisssimplificada_id 
     and nf.empresa_id     = ais.empresa_id
     and nf.dt_emiss        between ais.dt_inicio
                                and ais.dt_fim
   group by imp.dm_tipo, nf.dm_arm_nfe_terc, nf.dm_ind_emit
   having case when imp.dm_tipo = 0 then nvl(sum(imp.vl_imp_trib),0) else 0 end > 0
       or case when imp.dm_tipo        = 1
                and nf.dm_arm_nfe_terc = 0
                and nf.dm_ind_emit     = 1
          then nvl(sum(imp.vl_imp_trib),0) else 0 end > 0;  
   --        
   -- Cursor para validação da apuração do ISS
   cursor c_valida_apur (en_apurisssimplificada_id apur_iss_simplificada.id%type)  is
   select * 
      from APUR_ISS_SIMPLIFICADA ais
   where ais.id = en_apurisssimplificada_id;   
   --   
   
              
-------------------------------------------------------------------------------------------------------
-- PROCEDURES
--
-- Procedure para geração do Log Genérico --
procedure pkb_log_generico_apur_iss ( sn_loggenerico_id     out nocopy log_generico_apur_iss.id%type
                                    , ev_mensagem        in            log_generico_apur_iss.mensagem%type
                                    , ev_resumo          in            log_generico_apur_iss.resumo%type
                                    , en_tipo_log        in            csf_tipo_log.cd_compat%type      default 1
                                    , en_referencia_id   in            log_generico_apur_iss.referencia_id%type  default null
                                    , ev_obj_referencia  in            log_generico_apur_iss.obj_referencia%type default null
                                    , en_empresa_id      in            empresa.id%type                  default null
                                    , en_dm_impressa     in            log_generico_apur_iss.dm_impressa%type    default 0);


-------------------------------------------------------------------------------------------------------
-- Procedure para gerar apuração do Iss Simplificado
--
procedure pkb_apur_iss_simplificada ( en_apurisssimplificada_id apur_iss_simplificada.id%type); 
-------------------------------------------------------------------------------------------------------
-- Procedure para Validar apuração do Iss Simplificado
--
procedure pkb_valida_apur_iss_simp (en_apurisssimplificada_id apur_iss_simplificada.id%type); 
-------------------------------------------------------------------------------------------------------
-- Procedure para desfazer apuração do Iss Simplificado
--
procedure pkb_desfazer_apur_iss_simp (en_apurisssimplificada_id apur_iss_simplificada.id%type);   
-------------------------------------------------------------------------------------------------------
-- Procedure para Geração da Guia de Pagamento de Imposto
--
procedure pkg_gera_guia_pgto (en_apurisssimplificada_id apur_iss_simplificada.id%type,
                              en_usuario_id neo_usuario.id%type); 
-------------------------------------------------------------------------------------------------------
-- Procedure para Estorno da Guia de Pagamento de Imposto
--
procedure pkg_estorna_guia_pgto (en_apurisssimplificada_id apur_iss_simplificada.id%type,
                                 en_usuario_id neo_usuario.id%type); 
-------------------------------------------------------------------------------------------------------
--
end pk_apur_iss;
/
