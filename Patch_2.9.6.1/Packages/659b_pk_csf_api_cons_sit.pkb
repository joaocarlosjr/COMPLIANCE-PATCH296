create or replace package body csf_own.pk_csf_api_cons_sit is
--
-------------------------------------------------------------------------------------------------------
-- Procedure que insere o log
-------------------------------------------------------------------------------------------------------
procedure pkb_log_generico_conssit( sn_loggenericonf_id    out nocopy    log_generico_nf.id%type
                                  , ev_mensagem            in            log_generico_nf.mensagem%type
                                  , ev_resumo              in            log_generico_nf.resumo%type
                                  , en_tipo_log            in            csf_tipo_log.cd_compat%type         default 1
                                  , en_empresa_id          in            Empresa.Id%type                     default null )is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_nf.id%type;
   vn_csftipolog_id  csf_tipo_log.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   gv_mensagem := ev_mensagem;
   gv_resumo   := ev_resumo;
   --
   if nvl(gn_processo_id,0) = 0 then
      select processo_seq.nextval
        into gn_processo_id
        from dual;
   end if;
   --
   if nvl(en_tipo_log,0) > 0 and ev_mensagem is not null then
   --
      vn_fase := 2;
   --
      vn_csftipolog_id := pk_csf.fkg_csf_tipo_log_id ( en_tipo_log => en_tipo_log );
      --
      vn_fase := 3;
      --
      select loggenericonf_seq.nextval
        into vn_loggenerico_id
        from dual;
      --
      sn_loggenericonf_id := vn_loggenerico_id;
      --
      vn_fase := 4;
      --
      insert into log_generico_nf ( id
                                   , processo_id
                                   , dt_hr_log
                                   , referencia_id
                                   , obj_referencia
                                   , resumo
                                   , dm_impressa
                                   , dm_env_email
                                   , csftipolog_id
                                   , empresa_id
                                   , mensagem )
                            values ( vn_loggenerico_id
                                   , gn_processo_id
                                   , sysdate
                                   , gn_referencia_id
                                   , gv_obj_referencia
                                   , ev_resumo
                                   , 0
                                   , 0
                                   , vn_csftipolog_id
                                   , nvl(en_empresa_id, gn_empresa_id)
                                   , ev_mensagem
                                   );
   --
      vn_fase := 5;
      --
   commit;
   --
   end if;
   --
exception
   when others then
      --
      gv_mensagem := gv_mensagem || '. Erro na pk_csf_api_cons_sit.pkb_log_generico_conssit fase('||vn_fase||'):'||sqlerrm;
      gv_resumo   := gv_resumo;
      --
       declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem
                                          , ev_resumo          => gv_resumo
                                          , en_tipo_log        => erro_de_sistema
                                          , en_referencia_id   => null
                                          , ev_obj_referencia  => null
                                          , en_empresa_id      => nvl(en_empresa_id, gn_empresa_id)
                                          , en_dm_impressa     => 0 );
      exception
         when others then
            null;
      end;
      --
end pkb_log_generico_conssit;
--
-------------------------------------------------------------------------------------------------------
-- Procedure que insere o log
-------------------------------------------------------------------------------------------------------
procedure pkb_log_generico_conssit_ct( sn_loggenericoct_id    out nocopy    log_generico_ct.id%type
                                     , ev_mensagem            in            log_generico_ct.mensagem%type
                                     , ev_resumo              in            log_generico_ct.resumo%type
                                     , en_tipo_log            in            csf_tipo_log.cd_compat%type         default 1
                                     , en_empresa_id          in            Empresa.Id%type                     default null )is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_ct.id%type;
   vn_csftipolog_id  csf_tipo_log.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   gv_mensagem := ev_mensagem;
   gv_resumo   := ev_resumo;
   --
   if nvl(gn_processo_id,0) = 0 then
      select processo_seq.nextval
        into gn_processo_id
        from dual;
   end if;
   --
   if nvl(en_tipo_log,0) > 0 and ev_mensagem is not null then
      --
      vn_fase := 2;
      --
      vn_csftipolog_id := pk_csf.fkg_csf_tipo_log_id ( en_tipo_log => en_tipo_log );
      --
      vn_fase := 3;
      --
      select loggenericoct_seq.nextval
        into vn_loggenerico_id
        from dual;
      --
      sn_loggenericoct_id := vn_loggenerico_id;
      --
      vn_fase := 4;
      --
      insert into log_generico_ct ( id
                                  , processo_id
                                  , dt_hr_log
                                  , referencia_id
                                  , obj_referencia
                                  , resumo
                                  , dm_impressa
                                  , dm_env_email
                                  , csftipolog_id
                                  , empresa_id
                                  , mensagem )
                           values ( vn_loggenerico_id
                                  , gn_processo_id
                                  , sysdate
                                  , gn_referencia_id
                                  , gv_obj_referencia
                                  , ev_resumo
                                  , 0
                                  , 0
                                  , vn_csftipolog_id
                                  , nvl(en_empresa_id, gn_empresa_id)
                                  , ev_mensagem
                                  );
      --
      vn_fase := 5;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem := gv_mensagem || '. Erro na pk_csf_api_cons_sit.pkb_log_generico_conssit_ct fase('||vn_fase||'):'||sqlerrm;
      gv_resumo   := gv_resumo;
      --
       declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem
                                          , ev_resumo          => gv_resumo
                                          , en_tipo_log        => erro_de_sistema
                                          , en_referencia_id   => null
                                          , ev_obj_referencia  => null
                                          , en_empresa_id      => nvl(en_empresa_id, gn_empresa_id)
                                          , en_dm_impressa     => 0 );
      exception
         when others then
            null;
      end;
      --
end pkb_log_generico_conssit_ct;
--
-----------------------------------------
--| Procedimento finaliza o Log Genérico
-----------------------------------------
procedure pkb_finaliza_log_generico_csit is
begin
   --
   gn_processo_id := null;
      --
exception
   when others then
      --
      gv_resumo := 'Erro na pk_csf_api_cons_sit.pkb_finaliza_log_generico_csit: '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                  , ev_mensagem          => 'Finalizar processo de Log Genérico - CSF_CONS_SIT'
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_sistema
                              , en_empresa_id        => gn_empresa_id );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_finaliza_log_generico_csit;
--
------------------------------------------------------
--| Procedimento armazena o valor do "loggenerico_id"
------------------------------------------------------
procedure pkb_gt_log_generico_conssit ( en_loggenericonf_id in             log_generico_nf.id%type
                                      , est_log_generico_nf in out nocopy  dbms_sql.number_table
                                      ) is
   --
   i pls_integer;
   --
begin
   --
   if nvl(en_loggenericonf_id,0) > 0 then
   --
      i := nvl(est_log_generico_nf.count,0) + 1;
   --
      est_log_generico_nf(i) := en_loggenericonf_id;
      --
   end if;
   --
exception
   when others then
   --
      gv_resumo := 'Erro na pk_csf_api_cons_sit.pkb_gt_log_generico_conssit: '||sqlerrm;
   --
   declare
         vn_loggenerico_id  Log_Generico_nf.id%TYPE;
   begin
      --
         pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                  , ev_mensagem          => 'Registrar logs genéricos com erro de validação - CSF_CONS_SIT'
                          , ev_resumo            => gv_resumo
                          , en_tipo_log          => erro_de_sistema
                          , en_empresa_id        => gn_empresa_id );
         --
   exception
      when others then
        null;
   end;
   --
end pkb_gt_log_generico_conssit;
--
------------------------------------------------------
--| Procedimento armazena o valor do "loggenerico_id"
------------------------------------------------------
procedure pkb_gt_log_generico_conssit_ct ( en_loggenericoct_id in             log_generico_ct.id%type
                                         , est_log_generico_ct in out nocopy  dbms_sql.number_table
                                         ) is
   --
   i pls_integer;
   --
begin
   --
   if nvl(en_loggenericoct_id,0) > 0 then
   --
      i := nvl(est_log_generico_ct.count,0) + 1;
   --
      est_log_generico_ct(i) := en_loggenericoct_id;
      --
   end if;
   --
exception
   when others then
   --
      gv_resumo := 'Erro na pk_csf_api_cons_sit.pkb_gt_log_generico_conssit_ct: '||sqlerrm;
   --
   declare
         vn_loggenerico_id  Log_Generico_ct.id%TYPE;
   begin
      --
      pkb_log_generico_conssit_ct( sn_loggenericoct_id  => vn_loggenerico_id
                                 , ev_mensagem          => 'Registrar logs genéricos com erro de validação - CT_CONS_SIT'
                                 , ev_resumo            => gv_resumo
                                 , en_tipo_log          => erro_de_sistema
                                 , en_empresa_id        => gn_empresa_id );
         --
   exception
      when others then
        null;
   end;
   --
end pkb_gt_log_generico_conssit_ct;
--
----------------------------------------------------------------------------------
-- Procedimento que limpa a tabela log_generico_nf
----------------------------------------------------------------------------------
procedure pkb_limpar_loggenericoconssit( en_empresa_id     in      Empresa.Id%type ) is
   --
begin
   --
   delete from log_generico_nf l
    where nvl(l.empresa_id,0) = nvl(en_empresa_id,0)
      and l.empresa_id     is not null
      and l.obj_referencia = 'CSF_CONS_SIT';
   --
   commit;
   --
exception
   when others then
      --
      gv_resumo := 'Erro na pkb_limpar_loggenericoconssit:'||sqlerrm;
      --
      declare
         vn_loggenerico_id   log_generico_nf.id%type;
      begin
      --
      pkb_log_generico_conssit( sn_loggenericonf_id  => vn_loggenerico_id
                              , ev_mensagem          => 'Limpar tabela de logs genéricos - CSF_CONS_SIT'
                          , ev_resumo            => gv_resumo
                          , en_tipo_log          => erro_de_sistema
                          , en_empresa_id        => gn_empresa_id );
      exception
         when others then
           null;
      end;
end pkb_limpar_loggenericoconssit;
--
----------------------------------------------------------------------------------
--| Procedimento seta o objeto de referencia utilizado na Validação da Informação
----------------------------------------------------------------------------------
procedure pkb_seta_obj_ref ( ev_objeto in varchar2
                           ) is
begin
   --
   gv_obj_referencia := upper(ev_objeto);
   --
end pkb_seta_obj_ref;
--
-----------------------------------------------------------------------------
--| Procedimento seta o tipo de integração que será feito
--| 0 - Somente válida os dados e registra o Log de ocorrência
--| 1 - Válida os dados e registra o Log de ocorrência e insere a informação
--| Todos os procedimentos de integração fazem referência a ele
-----------------------------------------------------------------------------
procedure pkb_seta_tipo_integr ( en_tipo_integr in number
                               ) is
begin
   --
   gn_tipo_integr := en_tipo_integr;
   --
end pkb_seta_tipo_integr;
--
-- ====================================================================================================================== --
-- Procedimento de atualização da tabela CSF_CONS_SIT                                 
-- ====================================================================================================================== --
procedure pkb_ins_atu_csf_cons_sit ( est_row_csf_cons_sit in out nocopy csf_cons_sit%rowtype
                                   , ev_campo_atu         in varchar2 
                                   , en_tp_rotina         in number
                                   , ev_rotina_orig       in varchar2
                                   ) is
   --
begin
   if en_tp_rotina = 0 then -- Atualização
      --
      -- Identifica qual campo será atualizado
      if upper(ev_campo_atu) = 'NOTAFISCAL_ID' then
         --
         update csf_cons_sit
            set notafiscal_id = est_row_csf_cons_sit.notafiscal_id
          where id = est_row_csf_cons_sit.id;
         --
      elsif upper(ev_campo_atu) = 'DM_CRIAR_MDE' then
          --
         update csf_cons_sit
            set dm_criar_mde = est_row_csf_cons_sit.dm_criar_mde
          where id = est_row_csf_cons_sit.id;
         --
      elsif upper(ev_campo_atu) = 'DM_INTEGR_ERP' then
          --
         update csf_cons_sit
            set dm_integr_erp = est_row_csf_cons_sit.dm_integr_erp
          where id = est_row_csf_cons_sit.id;
         --
      elsif upper(ev_campo_atu) = 'DM_ST_INTEGRA' then
          --
         update csf_cons_sit
            set dm_st_integra = est_row_csf_cons_sit.dm_st_integra
          where id = est_row_csf_cons_sit.id;
         --
      elsif upper(ev_campo_atu) = 'DM_SITUACAO' then
          --
         update csf_cons_sit
            set dm_situacao = est_row_csf_cons_sit.dm_situacao
          where id = est_row_csf_cons_sit.id;
         --
      elsif upper(ev_campo_atu) = 'CSTAT' then
          --
         update csf_cons_sit
            set cstat = est_row_csf_cons_sit.cstat
          where id = est_row_csf_cons_sit.id;
         --
      end if;
      --
   elsif en_tp_rotina = 1 then-- Inserção
      --
      insert into csf_cons_sit ( id
                               , empresa_id
                               , notafiscal_id
                               , usuario_id
                               , referencia
                               , chnfe
                               , codufibge
                               , dm_tp_cons
                               , dm_situacao
                               , dt_hr_cons_sit
                               , versao
                               , tpamb
                               , veraplic
                               , cstat
                               , xmotivo
                               , cuf
                               , dhrecbto
                               , nprot
                               , digval
                               , signature
                               , dm_rec_fisico )
	                      values ( csfconssit_seq.nextval -- id
                               , est_row_csf_cons_sit.empresa_id
                               , est_row_csf_cons_sit.notafiscal_id
                               , est_row_csf_cons_sit.usuario_id
                               , est_row_csf_cons_sit.referencia
                               , est_row_csf_cons_sit.chnfe
                               , est_row_csf_cons_sit.codufibge
                               , est_row_csf_cons_sit.dm_tp_cons
                               , est_row_csf_cons_sit.dm_situacao
                               , est_row_csf_cons_sit.dt_hr_cons_sit
                               , est_row_csf_cons_sit.versao
                               , est_row_csf_cons_sit.tpamb
                               , est_row_csf_cons_sit.veraplic
                               , est_row_csf_cons_sit.cstat
                               , est_row_csf_cons_sit.xmotivo
                               , est_row_csf_cons_sit.cuf
                               , est_row_csf_cons_sit.dhrecbto
                               , est_row_csf_cons_sit.nprot
                               , est_row_csf_cons_sit.digval
                               , est_row_csf_cons_sit.signature
                               , est_row_csf_cons_sit.dm_rec_fisico
                               );
      --
   end if;
   --
exception
   when others then
      --
      rollback;
      --
      gv_mensagem := 'Erro na pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit : '||sqlerrm;
      gv_resumo   := 'Rotina que chamou a pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit : '||ev_rotina_orig;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                  , ev_mensagem         => gv_mensagem
                                  , ev_resumo           => gv_resumo
                                  , en_tipo_log         => erro_de_validacao
                                  , en_empresa_id       => est_row_csf_cons_sit.empresa_id);
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem);
      --
end pkb_ins_atu_csf_cons_sit;
--
-- ====================================================================================================================== --
-- Procedimento de validação dos dados da chave da nf
-- ====================================================================================================================== --
procedure pkb_valid_cons_chave_nfe ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                   , est_row_csf_cons_sit in out nocopy  csf_cons_sit%rowtype
                                   , en_multorg_id        in             mult_org.id%type
                                   , ev_rotina            in             varchar2 default null -- rotina que chamou esse processo
                                   ) is
   vn_fase        number;
   vn_loggenerico_id log_generico_nf.id%type;
   vn_dig_verif_chave         nota_fiscal.dig_verif_chave%type;
   vn_dm_situacao_exist csf_cons_sit.dm_situacao%type;
   vn_id_existe number;
   --
begin
   --
   vn_fase := 2;
   --
   -- Verifica se valor da chave não é nulo
   -- =====================================
   if trim(est_row_csf_cons_sit.chnfe) is not null and
      nvl(est_log_generico_nf.count,0) = 0 then
      --
      vn_fase := 2.1;
      --
      -- Valida se a Chave de Acesso contêm 44 digitos
      -- =============================================
      if length(trim(est_row_csf_cons_sit.chnfe)) <> 44 and
         nvl(est_log_generico_nf.count,0)          =  0 then
         --
         vn_fase := 2.2;
         --
         gv_mensagem := 'Chave de acesso deve conter 44 dígitos';
         --
         gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_valid_cons_chave_nfe. '||
                      'Chave('||est_row_csf_cons_sit.chnfe||'). '||
                      'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                  , ev_mensagem         => gv_mensagem
                                  , ev_resumo           => gv_resumo
                             , en_tipo_log         => erro_de_validacao
                                  , en_empresa_id       => est_row_csf_cons_sit.empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit ( en_loggenericonf_id => vn_loggenerico_id
                                , est_log_generico_nf => est_log_generico_nf );
         --
      end if;
      --
      vn_fase := 2.3;
      --
      -- Valida digito verificador da chave
      -- ==================================
      -- Valida o digito verificador da Chave de Acesso
      vn_dig_verif_chave := pk_csf.fkg_mod_11 ( ev_codigo => substr(trim(est_row_csf_cons_sit.chnfe), 1,43) );
      --
      vn_fase := 2.4;
      --
      if nvl(vn_dig_verif_chave,0) <> to_number( substr(trim(est_row_csf_cons_sit.chnfe), 44,1) ) and
         nvl(est_log_generico_nf.count,0) = 0 then
         --
         vn_fase := 2.2;
         --
         gv_mensagem := 'Chave de acesso inválida';
         --
         gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_valid_cons_chave_nfe. '||
                      'Chave('||est_row_csf_cons_sit.chnfe||'). '||
                      'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                  , ev_mensagem         => gv_mensagem
                                  , ev_resumo           => gv_resumo
                             , en_tipo_log         => erro_de_validacao
                                  , en_empresa_id       => est_row_csf_cons_sit.empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit ( en_loggenericonf_id => vn_loggenerico_id
                                , est_log_generico_nf => est_log_generico_nf );
         --
      end if;
      --
      --Validar 2 primeiros dígitos da chave - devem ter um valor valido em ESTADO.IBGE_ESTADO
      -- ======================================================================================
      if nvl(pk_csf.fkg_Estado_ibge_id (substr(est_row_csf_cons_sit.chnfe,1,2)),0) = 0 and
         nvl(est_log_generico_nf.count,0) = 0 then
         --
         vn_fase := 2.2;
         --
         gv_mensagem := 'Código da UF contido na Chave está inválido';
         --
         gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_valid_cons_chave_nfe. '||
                      'Chave('||est_row_csf_cons_sit.chnfe||'). '||
                      'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                  , ev_mensagem         => gv_mensagem
                                  , ev_resumo           => gv_resumo
                             , en_tipo_log         => erro_de_validacao
                                  , en_empresa_id       => est_row_csf_cons_sit.empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit ( en_loggenericonf_id => vn_loggenerico_id
                                , est_log_generico_nf => est_log_generico_nf );
         --
      end if;
      --
      -- Validar se os dígitos que representam o ano e mês de emissão não são mais antigos que 6 meses
      -- =============================================================================================
      if to_date(sysdate,'dd/mm/yyyy') - to_date(est_row_csf_cons_sit.dt_hr_cons_sit,'dd/mm/yyyy') > 210 and -- 7 meses para garantir
         nvl(est_log_generico_nf.count,0) = 0 then
         --
         vn_fase := 2.2;
         --
         gv_mensagem := 'Chave de acesso é muito antiga. SEFAZ permite consulta apenas para notas emitidas nos ultimos 180 dias';
         --
         gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_valid_cons_chave_nfe. '||
                      'Chave('||est_row_csf_cons_sit.chnfe||'). '||
                      'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                  , ev_mensagem         => gv_mensagem
                                  , ev_resumo           => gv_resumo
                             , en_tipo_log         => erro_de_validacao
                                  , en_empresa_id       => est_row_csf_cons_sit.empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit ( en_loggenericonf_id => vn_loggenerico_id
                                , est_log_generico_nf => est_log_generico_nf );
         --
      end if;
      --
      -- Validar se se existe a mesma chave em outro registro com DM_SITUACAO IN (0,1)
      -- =============================================================================
      begin
         select max(id)
              , dm_situacao
           into vn_id_existe
              , vn_dm_situacao_exist
           from csf_cons_sit
          where chnfe = est_row_csf_cons_sit.chnfe
          and dm_situacao in (0,1)
           group by dm_situacao, chnfe;
      exception
         when no_data_found then
            vn_id_existe         := null;
            vn_dm_situacao_exist := null;
      end;
      --
      if nvl(vn_id_existe,0) > 0 and
         nvl(est_log_generico_nf.count,0) = 0 then
         --
         vn_fase := 2.2;
         --
         gv_mensagem := 'Já existe uma consulta anterior em andamento';
         --
         gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_valid_cons_chave_nfe. '||
                      'Chave('||est_row_csf_cons_sit.chnfe||'). '||
                      'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                  , ev_mensagem         => gv_mensagem
                                  , ev_resumo           => gv_resumo
                                  , en_tipo_log         => erro_de_validacao
                                  , en_empresa_id       => est_row_csf_cons_sit.empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit ( en_loggenericonf_id => vn_loggenerico_id
                                     , est_log_generico_nf => est_log_generico_nf );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_csf_api_cons_sit.pkb_valid_cons_chave_nfe fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                  , ev_mensagem         => gv_mensagem
                                  , ev_resumo           => gv_resumo
                                  , en_tipo_log         => erro_de_sistema
                                  , en_empresa_id       => est_row_csf_cons_sit.empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit ( en_loggenericonf_id => vn_loggenerico_id
                                     , est_log_generico_nf => est_log_generico_nf );
      exception
         when others then
            null;
      end;
   --
end pkb_valid_cons_chave_nfe;
--
-- ====================================================================================================================== --
-- Procedimento de integração de consulta chave nfe
-- ====================================================================================================================== --
procedure pkb_integr_cons_chave_nfe ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                    , est_row_csf_cons_sit in out nocopy  csf_cons_sit%rowtype
                                    , ev_cpf_cnpj_emit     in             varchar2
                                    , en_multorg_id        in             mult_org.id%type 
                                    , ev_rotina            in             varchar2 default null -- rotina que chamou esse processo
                                    ) is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_nf.id%type;
   vn_empresa_id      empresa.id%type;
   gv_resumo          log_generico_nf.resumo%type;
   gv_mensagem         csf_cons_sit.xmotivo%type := null;
   vn_dm_tp_amb       empresa.dm_tp_amb%type;
   --
begin
   --
   vn_fase := 1;
   --
   --est_log_generico_nf := null;
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id => en_multorg_id
                                                        , ev_cpf_cnpj   => ev_cpf_cnpj_emit );
   --
   vn_fase := 1.1;
   --
   if nvl(vn_empresa_id,0)            <= 0 and
      nvl(est_log_generico_nf.count,0) = 0 then
      --
      vn_fase := 1.2;
      --
      gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_integr_cons_chave_nfe. '||
                   'Chave('||est_row_csf_cons_sit.chnfe||'). '||
                   'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
      --
      gv_mensagem := 'Empresa não encontrada. CNPJ(' || ev_cpf_cnpj_emit || ').';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                               , ev_mensagem         => gv_mensagem
                               , ev_resumo           => gv_resumo
                               , en_tipo_log         => erro_de_validacao
                               , en_empresa_id       => vn_empresa_id );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_conssit ( en_loggenericonf_id => vn_loggenerico_id
                                  , est_log_generico_nf => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 2;
   --
   -- Valida se tem valor para a chave
   if trim(est_row_csf_cons_sit.chnfe) is null and
      nvl(est_log_generico_nf.count,0) = 0 then
      --
      gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_integr_cons_chave_nfe. '||
                   'Chave('||est_row_csf_cons_sit.chnfe||'). '||
                   'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
      --
      gv_mensagem := 'Não foi informada a chave de acesso da NFe.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                               , ev_mensagem         => gv_mensagem
                               , ev_resumo           => gv_resumo
                               , en_tipo_log         => erro_de_validacao
                               , en_empresa_id       => vn_empresa_id );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_conssit ( en_loggenericonf_id => vn_loggenerico_id
                             , est_log_generico_nf => est_log_generico_nf );
      --
   elsif trim(est_row_csf_cons_sit.chnfe) is not null then
      --
      vn_fase := 3;
      --
      -- Recupera o tipo de ambiente da empresa
      vn_dm_tp_amb := pk_csf.fkg_tp_amb_empresa ( en_empresa_id => vn_empresa_id );
      --
      vn_fase := 5;
      --
      -- O id é criado aqui para poder incluir no referencia_id das validacoes
      begin
         select csfconssit_seq.nextval
           into est_row_csf_cons_sit.id
           from dual;
      exception
         when others then
            est_row_csf_cons_sit.id := null;
      end;
      --
      begin
         -- Chama rotina que atualiza ou insere a tabela csf_cons_sit
         --
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.id               :=  est_row_csf_cons_sit.id;                -- id
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.empresa_id       :=  vn_empresa_id;                          -- empresa_id
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.chnfe            :=  est_row_csf_cons_sit.chnfe;             --chnfe
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.codufibge        :=  substr(est_row_csf_cons_sit.chnfe,1,2); -- codufibge
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.dm_tp_cons       :=  6;                                      -- dm_tp_cons -- Automática através de integração table/view
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.dm_situacao      :=  0;                                      -- dm_situacao
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.dt_hr_cons_sit   :=  sysdate;                                -- dt_hr_cons_sit
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.tpamb            :=  vn_dm_tp_amb;                           -- tpamb
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.xmotivo          :=  gv_mensagem;
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.dm_rec_fisico    :=  1;                                      -- dm_rec_fisico
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.dm_integr_erp    :=  0;                                      -- dm_integr_erp
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.dm_st_integra    :=  7;                                      -- dm_st_integra
         --
         pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit ( est_row_csf_cons_sit => pk_csf_api_cons_sit.gt_row_csf_cons_sit
                                                      , ev_campo_atu         => null
                                                      , en_tp_rotina         => 1 -- inserção
                                                      , ev_rotina_orig       => 'pk_csf_api_cons_sit.pkb_integr_cons_chave_nfe'
                                                      );
          --
          -- Chama a rotina de validacao da Chave de Acesso
          -- ==============================================
          pkb_valid_cons_chave_nfe ( est_log_generico_nf      => est_log_generico_nf
                                   , est_row_csf_cons_sit     => pk_csf_api_cons_sit.gt_row_csf_cons_sit
                                   , en_multorg_id            => null
                                   , ev_rotina                => 'pk_csf_api_cons_sit.pkb_integr_cons_chave_nfe'
                                   );
          --
          vn_fase := 6;
          --
          if nvl(est_log_generico_nf.count,0) > 0 then
             --
             -- Chama rotina que atualiza a tabela csf_cons_sit
             pk_csf_api_cons_sit.gt_row_csf_cons_sit               := null;
             pk_csf_api_cons_sit.gt_row_csf_cons_sit.empresa_id    := vn_empresa_id;
             pk_csf_api_cons_sit.gt_row_csf_cons_sit.id            := est_row_csf_cons_sit.id;
             pk_csf_api_cons_sit.gt_row_csf_cons_sit.dm_situacao   := 7;
             pk_csf_api_cons_sit.gt_row_csf_cons_sit.cstat         := '000';
             --
             pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit ( est_row_csf_cons_sit => pk_csf_api_cons_sit.gt_row_csf_cons_sit
                                                          , ev_campo_atu         => 'dm_situacao'
                                                          , en_tp_rotina         => 0 -- atualização
                                                          , ev_rotina_orig       => 'pk_csf_api_cons_sit.pkb_integr_cons_chave_nfe'
                                                          );
             --
             pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit ( est_row_csf_cons_sit => pk_csf_api_cons_sit.gt_row_csf_cons_sit
                                                          , ev_campo_atu         => 'cstat'
                                                          , en_tp_rotina         => 0 -- atualização
                                                          , ev_rotina_orig       => 'pk_csf_api_cons_sit.pkb_integr_cons_chave_nfe'
                                                          );
             --
          else
             --
             -- Chama rotina que atualiza a tabela csf_cons_sit
             pk_csf_api_cons_sit.gt_row_csf_cons_sit               := null;
             pk_csf_api_cons_sit.gt_row_csf_cons_sit.empresa_id    := vn_empresa_id;
             pk_csf_api_cons_sit.gt_row_csf_cons_sit.id            := est_row_csf_cons_sit.id;
             pk_csf_api_cons_sit.gt_row_csf_cons_sit.dm_situacao   := 1;
             --
             pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit ( est_row_csf_cons_sit => pk_csf_api_cons_sit.gt_row_csf_cons_sit
                                                          , ev_campo_atu         => 'dm_situacao'
                                                          , en_tp_rotina         => 0 -- atualização
                                                          , ev_rotina_orig       => 'pk_csf_api_cons_sit.pkb_integr_cons_chave_nfe'
                                                          );
             --
          end if;
          --
          commit;
          --
      exception
         when others then
            pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                     , ev_mensagem         => 'Erro ao tentar inserir/atualizar os dados na tabela csf_cons_sit'
                                     , ev_resumo           => 'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')Erro('||sqlerrm||')'
                                     , en_tipo_log         => erro_de_sistema
                                     , en_empresa_id       => null );
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_conssit ( en_loggenericonf_id => vn_loggenerico_id
                                        , est_log_generico_nf => est_log_generico_nf );
      end;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_csf_api_cons_sit.pkb_integr_cons_chave_nfe fase('||vn_fase||'). Erro: '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                  , ev_mensagem         => gv_mensagem
                                  , ev_resumo           => gv_mensagem
                                  , en_tipo_log         => erro_de_sistema
                                  , en_empresa_id       => vn_empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit ( en_loggenericonf_id => vn_loggenerico_id
                                     , est_log_generico_nf => est_log_generico_nf );
      exception
         when others then
            null;
      end;
   --
END pkb_integr_cons_chave_nfe;
--
-- ====================================================================================================================== --
-- Procedimento de atualização da tabela CT_CONS_SIT                                 
-- ====================================================================================================================== --
procedure pkb_ins_atu_ct_cons_sit ( est_row_ct_cons_sit in out nocopy ct_cons_sit%rowtype
                                  , ev_campo_atu        in varchar2
                                  , en_tp_rotina        in number
                                  , ev_rotina_orig      in varchar2
                                  ) is
   --
begin
   if en_tp_rotina = 0 then -- Atualização
      --
      -- Identifica qual campo será atualizado
      if upper(ev_campo_atu) = 'CONHECTRANSP_ID' and ev_rotina_orig = 'pk_csf_api_ct.pkb_excluir_dados_ct' then
         --
         update ct_cons_sit
            set conhectransp_id = null
          where conhectransp_id = est_row_ct_cons_sit.conhectransp_id;
         --
      elsif upper(ev_campo_atu) = 'CONHECTRANSP_ID' and ev_rotina_orig = 'pk_csf_api_ct.pkb_relac_cte_cons_sit' then
         --
         update ct_cons_sit
            set conhectransp_id = est_row_ct_cons_sit.conhectransp_id
          where id = est_row_ct_cons_sit.id;
         --
      elsif upper(ev_campo_atu) = 'DM_SITUACAO' then
         --
         update ct_cons_sit
            set dm_situacao = est_row_ct_cons_sit.dm_situacao
          where id = est_row_ct_cons_sit.id;
         --
      elsif upper(ev_campo_atu) = 'DM_INTEGR_ERP' then
         --
         update ct_cons_sit
            set dm_integr_erp = est_row_ct_cons_sit.dm_integr_erp
          where id = est_row_ct_cons_sit.id;
         --
      elsif upper(ev_campo_atu) = 'DM_ST_INTEGRA' then
         --
         update ct_cons_sit
            set dm_st_integra = est_row_ct_cons_sit.dm_st_integra
          where conhectransp_id = est_row_ct_cons_sit.conhectransp_id;
         --
      end if;
      --
   elsif en_tp_rotina = 1 then-- Inserção
      --
      insert into ct_cons_sit (	id
                              ,	empresa_id
                              ,	conhectransp_id
                              ,	dm_tp_cons
                              ,	dm_tp_amb
                              ,	nro_chave_cte
                              ,	dt_hr_cons_sit
                              ,	dm_situacao
                              ,	cte_proc_xml
                              ,	usuario_id
                              ,	versao
                              ,	veraplic
                              ,	msgwebserv_id
                              ,	cstat
                              ,	xmotivo
                              ,	cuf
                              ,	dhrecbto
                              ,	nprot
                              ,	digval
                              ,	ret_cons_sit_cte_xml
                              ,	c_ref_cte
                              ,	c_serie
                              ,	c_nct
                              ,	c_dhemi
                              ,	c_cnpj_emit
                              ,	c_vt_prest
                              ,	c_cst
                              ,	c_p_icms
                              ,	c_v_icms
                              ,	c_v_bc
                              ,	dm_rec_fisico
                              ,	dm_integr_erp
                              ,	dm_st_integra
                              )
	               values ( ctconssit_seq.nextval -- id
                              ,	est_row_ct_cons_sit.empresa_id
                              ,	est_row_ct_cons_sit.conhectransp_id
                              ,	est_row_ct_cons_sit.dm_tp_cons
                              ,	est_row_ct_cons_sit.dm_tp_amb
                              ,	est_row_ct_cons_sit.nro_chave_cte
                              ,	est_row_ct_cons_sit.dt_hr_cons_sit
                              ,	est_row_ct_cons_sit.dm_situacao
                              ,	est_row_ct_cons_sit.cte_proc_xml
                              ,	est_row_ct_cons_sit.usuario_id
                              ,	est_row_ct_cons_sit.versao
                              ,	est_row_ct_cons_sit.veraplic
                              ,	est_row_ct_cons_sit.msgwebserv_id
                              ,	est_row_ct_cons_sit.cstat
                              ,	est_row_ct_cons_sit.xmotivo
                              ,	est_row_ct_cons_sit.cuf
                              ,	est_row_ct_cons_sit.dhrecbto
                              ,	est_row_ct_cons_sit.nprot
                              ,	est_row_ct_cons_sit.digval
                              ,	est_row_ct_cons_sit.ret_cons_sit_cte_xml
                              ,	est_row_ct_cons_sit.c_ref_cte
                              ,	est_row_ct_cons_sit.c_serie
                              ,	est_row_ct_cons_sit.c_nct
                              ,	est_row_ct_cons_sit.c_dhemi
                              ,	est_row_ct_cons_sit.c_cnpj_emit
                              ,	est_row_ct_cons_sit.c_vt_prest
                              ,	est_row_ct_cons_sit.c_cst
                              ,	est_row_ct_cons_sit.c_p_icms
                              ,	est_row_ct_cons_sit.c_v_icms
                              ,	est_row_ct_cons_sit.c_v_bc
                              , nvl(est_row_ct_cons_sit.dm_rec_fisico,0)
                              , nvl(est_row_ct_cons_sit.dm_integr_erp,0)
                              , nvl(est_row_ct_cons_sit.dm_st_integra,0)							  
                              );
      --
   end if;
   --
exception
   when others then
      --
      rollback;
      --
      gv_mensagem := 'Erro na pk_csf_api_cons_sit.pkb_ins_atu_ct_cons_sit : '||sqlerrm;
      gv_resumo   := 'Rotina que chamou a pk_csf_api_cons_sit.pkb_ins_atu_ct_cons_sit : '||ev_rotina_orig;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         pkb_log_generico_conssit_ct ( sn_loggenericoct_id => vn_loggenerico_id
                                     , ev_mensagem         => gv_mensagem
                                     , ev_resumo           => gv_resumo
                                     , en_tipo_log         => erro_de_validacao
                                     , en_empresa_id       => est_row_ct_cons_sit.empresa_id);
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem);
      --
end pkb_ins_atu_ct_cons_sit;
--
-- ====================================================================================================================== --
-- Procedimento de validação dos dados da chave da ct
-- ====================================================================================================================== --
procedure pkb_valid_ct_cons_sit ( est_log_generico_ct in out nocopy  dbms_sql.number_table
                                , est_row_ct_cons_sit in out nocopy  ct_cons_sit%rowtype
                                , en_multorg_id       in             mult_org.id%type
                                , ev_rotina           in             varchar2 default null -- rotina que chamou esse processo
                                ) is
   --
   vn_fase              number;
   vn_loggenerico_id    log_generico_ct.id%type;
   vn_dig_verif_chave   conhec_transp.dig_verif_chave%type;
   vn_dm_situacao_exist ct_cons_sit.dm_situacao%type;
   vn_id_existe         number;
   --
begin
   --
   vn_fase := 2;
   --
   -- Verifica se valor da chave não é nulo
   -- =====================================
   if trim(est_row_ct_cons_sit.nro_chave_cte) is not null and
      nvl(est_log_generico_ct.count,0) = 0 then
      --
      vn_fase := 2.1;
      --
      -- Valida se a Chave de Acesso contêm 44 digitos
      -- =============================================
      if length(trim(est_row_ct_cons_sit.nro_chave_cte)) <> 44 and
         nvl(est_log_generico_ct.count,0)         =  0 then
         --
         vn_fase := 2.2;
         --
         gv_mensagem := 'Chave de acesso deve conter 44 dígitos';
         --
         gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_valid_ct_cons_sit. '||
                      'Chave('||est_row_ct_cons_sit.nro_chave_cte||'). '||
                      'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_conssit_ct ( sn_loggenericoct_id => vn_loggenerico_id
                                     , ev_mensagem         => gv_mensagem
                                     , ev_resumo           => gv_resumo
                                     , en_tipo_log         => erro_de_validacao
                                     , en_empresa_id       => est_row_ct_cons_sit.empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit_ct ( en_loggenericoct_id => vn_loggenerico_id
                                        , est_log_generico_ct => est_log_generico_ct );
         --
      end if;
      --
      vn_fase := 2.3;
      --
      -- Valida digito verificador da chave
      -- ==================================
      -- Valida o digito verificador da Chave de Acesso
      vn_dig_verif_chave := pk_csf.fkg_mod_11 ( ev_codigo => substr(trim(est_row_ct_cons_sit.nro_chave_cte), 1,43) );
      --
      vn_fase := 2.4;
      --
      if nvl(vn_dig_verif_chave,0) <> to_number( substr(trim(est_row_ct_cons_sit.nro_chave_cte), 44,1) ) and
         nvl(est_log_generico_ct.count,0) = 0 then
         --
         vn_fase := 2.2;
         --
         gv_mensagem := 'Chave de acesso inválida';
         --
         gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_valid_ct_cons_sit. '||
                      'Chave('||est_row_ct_cons_sit.nro_chave_cte||'). '||
                      'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_conssit_ct ( sn_loggenericoct_id => vn_loggenerico_id
                                     , ev_mensagem         => gv_mensagem
                                     , ev_resumo           => gv_resumo
                                     , en_tipo_log         => erro_de_validacao
                                     , en_empresa_id       => est_row_ct_cons_sit.empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit_ct ( en_loggenericoct_id => vn_loggenerico_id
                                        , est_log_generico_ct => est_log_generico_ct );
         --
      end if;
      --
      --Validar 2 primeiros dígitos da chave - devem ter um valor valido em ESTADO.IBGE_ESTADO
      -- ======================================================================================
      if nvl(pk_csf.fkg_Estado_ibge_id (substr(est_row_ct_cons_sit.nro_chave_cte,1,2)),0) = 0 and
         nvl(est_log_generico_ct.count,0) = 0 then
         --
         vn_fase := 2.2;
         --
         gv_mensagem := 'Código da UF contido na Chave está inválido';
         --
         gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_valid_ct_cons_sit. '||
                      'Chave('||est_row_ct_cons_sit.nro_chave_cte||'). '||
                      'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_conssit_ct ( sn_loggenericoct_id => vn_loggenerico_id
                                     , ev_mensagem         => gv_mensagem
                                     , ev_resumo           => gv_resumo
                                     , en_tipo_log         => erro_de_validacao
                                     , en_empresa_id       => est_row_ct_cons_sit.empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit_ct ( en_loggenericoct_id => vn_loggenerico_id
                                        , est_log_generico_ct => est_log_generico_ct );
         --
      end if;
      --
      -- Validar se os dígitos que representam o ano e mês de emissão não são mais antigos que 6 meses
      -- =============================================================================================
      if to_date(sysdate,'dd/mm/yyyy') - to_date(est_row_ct_cons_sit.dt_hr_cons_sit,'dd/mm/yyyy') > 210 and -- 7 meses para garantir
         nvl(est_log_generico_ct.count,0) = 0 then
         --
         vn_fase := 2.2;
         --
         gv_mensagem := 'Chave de acesso é muito antiga. SEFAZ permite consulta apenas para notas emitidas nos ultimos 180 dias';
         --
         gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_valid_ct_cons_sit. '||
                      'Chave('||est_row_ct_cons_sit.nro_chave_cte||'). '||
                      'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_conssit_ct ( sn_loggenericoct_id => vn_loggenerico_id
                                     , ev_mensagem         => gv_mensagem
                                     , ev_resumo           => gv_resumo
                                     , en_tipo_log         => erro_de_validacao
                                     , en_empresa_id       => est_row_ct_cons_sit.empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit_ct ( en_loggenericoct_id => vn_loggenerico_id
                                        , est_log_generico_ct => est_log_generico_ct );
         --
      end if;
      --
      -- Validar se se existe a mesma chave em outro registro com DM_SITUACAO IN (0,1)
      -- =============================================================================
      begin
         select max(id)
              , dm_situacao
           into vn_id_existe
              , vn_dm_situacao_exist
           from ct_cons_sit
          where nro_chave_cte = est_row_ct_cons_sit.nro_chave_cte
            and dm_situacao   in (0,1)
           group by dm_situacao, nro_chave_cte;
      exception
         when no_data_found then
            vn_id_existe         := null;
            vn_dm_situacao_exist := null;
      end;
      --
      if nvl(vn_id_existe,0) > 0 and
         nvl(est_log_generico_ct.count,0) = 0 then
         --
         vn_fase := 2.2;
         --
         gv_mensagem := 'Já existe uma consulta anterior em andamento';
         --
         gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_valid_ct_cons_sit. '||
                      'Chave('||est_row_ct_cons_sit.nro_chave_cte||'). '||
                      'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_conssit_ct ( sn_loggenericoct_id => vn_loggenerico_id
                                     , ev_mensagem         => gv_mensagem
                                     , ev_resumo           => gv_resumo
                                     , en_tipo_log         => erro_de_validacao
                                     , en_empresa_id       => est_row_ct_cons_sit.empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit_ct ( en_loggenericoct_id => vn_loggenerico_id
                                        , est_log_generico_ct => est_log_generico_ct );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_csf_api_cons_sit.pkb_valid_ct_cons_sit fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%type;
      begin
         pkb_log_generico_conssit_ct ( sn_loggenericoct_id => vn_loggenerico_id
                                     , ev_mensagem         => gv_mensagem
                                     , ev_resumo           => gv_resumo
                                     , en_tipo_log         => erro_de_sistema
                                     , en_empresa_id       => est_row_ct_cons_sit.empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit_ct ( en_loggenericoct_id => vn_loggenerico_id
                                        , est_log_generico_ct => est_log_generico_ct );
      exception
         when others then
            null;
      end;
   --
end pkb_valid_ct_cons_sit;
--
-- ====================================================================================================================== --
-- Procedimento de integração de consulta chave ct
-- ====================================================================================================================== --
procedure pkb_integr_ct_cons_sit ( est_log_generico_ct in out nocopy  dbms_sql.number_table
                                 , est_row_ct_cons_sit in out nocopy  ct_cons_sit%rowtype
                                 , ev_cpf_cnpj_emit    in             varchar2
                                 , en_multorg_id       in             mult_org.id%type
                                 , ev_rotina           in             varchar2 default null -- rotina que chamou esse processo
                                 ) is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ct.id%type;
   vn_empresa_id      empresa.id%type;
   gv_resumo          log_generico_ct.resumo%type;
   gv_mensagem        ct_cons_sit.xmotivo%type := null;
   vn_dm_tp_amb       empresa.dm_tp_amb%type;
   --
begin
   --
   vn_fase := 1;
   --
   --est_log_generico_nf := null;
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id => en_multorg_id
                                                        , ev_cpf_cnpj   => ev_cpf_cnpj_emit );
   --
   vn_fase := 1.1;
   --
   if nvl(vn_empresa_id,0)            <= 0 and
      nvl(est_log_generico_ct.count,0) = 0 then
      --
      vn_fase := 1.2;
      --
      gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_integr_ct_cons_sit. '||
                   'Chave('||est_row_ct_cons_sit.nro_chave_cte||'). '||
                   'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
      --
      gv_mensagem := 'Empresa não encontrada. CNPJ(' || ev_cpf_cnpj_emit || ').';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_conssit_ct ( sn_loggenericoct_id => vn_loggenerico_id
                                  , ev_mensagem         => gv_mensagem
                                  , ev_resumo           => gv_resumo
                                  , en_tipo_log         => erro_de_validacao
                                  , en_empresa_id       => vn_empresa_id );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_conssit_ct ( en_loggenericoct_id => vn_loggenerico_id
                                     , est_log_generico_ct => est_log_generico_ct );
      --
   end if;
   --
   vn_fase := 2;
   --
   -- Valida se tem valor para a chave
   if trim(est_row_ct_cons_sit.nro_chave_cte) is null and
      nvl(est_log_generico_ct.count,0) = 0 then
      --
      gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_integr_ct_cons_sit. '||
                   'Chave('||est_row_ct_cons_sit.nro_chave_cte||'). '||
                   'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
      --
      gv_mensagem := 'Não foi informada a chave de acesso da NFe.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_conssit_ct ( sn_loggenericoct_id => vn_loggenerico_id
                                  , ev_mensagem         => gv_mensagem
                                  , ev_resumo           => gv_resumo
                                  , en_tipo_log         => erro_de_validacao
                                  , en_empresa_id       => vn_empresa_id );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_conssit_ct ( en_loggenericoct_id => vn_loggenerico_id
                                     , est_log_generico_ct => est_log_generico_ct );
      --
   elsif trim(est_row_ct_cons_sit.nro_chave_cte) is not null then
      --
      vn_fase := 3;
      --
      -- Recupera o tipo de ambiente da empresa
      vn_dm_tp_amb := pk_csf.fkg_tp_amb_empresa ( en_empresa_id => vn_empresa_id );
      --
      vn_fase := 5;
      --
      -- O id é criado aqui para poder incluir no referencia_id das validacoes
      begin
         select ctconssit_seq.nextval
           into est_row_ct_cons_sit.id
           from dual;
      exception
         when others then
            est_row_ct_cons_sit.id := null;
      end;
      --
      begin
         -- Chama rotina que atualiza ou insere a tabela ct_cons_sit
         --
         pk_csf_api_cons_sit.gt_row_ct_cons_sit.id               :=  est_row_ct_cons_sit.id;                  -- id
         pk_csf_api_cons_sit.gt_row_ct_cons_sit.empresa_id       :=  vn_empresa_id;                           -- empresa_id
         pk_csf_api_cons_sit.gt_row_ct_cons_sit.dm_tp_cons       :=  6;                                       -- dm_tp_cons -- Automática através de integração table/view
         pk_csf_api_cons_sit.gt_row_ct_cons_sit.dm_tp_amb        :=  vn_dm_tp_amb;                            -- tpamb
         pk_csf_api_cons_sit.gt_row_ct_cons_sit.nro_chave_cte    :=  trim(est_row_ct_cons_sit.nro_chave_cte); --nro_chave_cte
         pk_csf_api_cons_sit.gt_row_ct_cons_sit.dt_hr_cons_sit   :=  sysdate;                                 -- dt_hr_cons_sit
         pk_csf_api_cons_sit.gt_row_ct_cons_sit.dm_situacao      :=  0;                                       -- dm_situacao
         pk_csf_api_cons_sit.gt_row_ct_cons_sit.xmotivo          :=  gv_mensagem;
         --
         pk_csf_api_cons_sit.pkb_ins_atu_ct_cons_sit ( est_row_ct_cons_sit => pk_csf_api_cons_sit.gt_row_ct_cons_sit
                                                     , ev_campo_atu        => null
                                                     , en_tp_rotina        => 1 -- inserção
                                                     , ev_rotina_orig      => 'pk_csf_api_cons_sit.pkb_integr_ct_cons_sit'
                                                     );
          --
          -- Chama a rotina de validacao da Chave de Acesso
          -- ==============================================
          pkb_valid_ct_cons_sit ( est_log_generico_ct => est_log_generico_ct
                                , est_row_ct_cons_sit => pk_csf_api_cons_sit.gt_row_ct_cons_sit
                                , en_multorg_id       => null
                                , ev_rotina           => 'pk_csf_api_cons_sit.pkb_integr_ct_cons_sit'
                                );
          --
          vn_fase := 6;
          --
          if nvl(est_log_generico_ct.count,0) > 0 then
             --
             -- Chama rotina que atualiza a tabela ct_cons_sit
             pk_csf_api_cons_sit.gt_row_ct_cons_sit               := null;
             pk_csf_api_cons_sit.gt_row_ct_cons_sit.empresa_id    := vn_empresa_id;
             pk_csf_api_cons_sit.gt_row_ct_cons_sit.id            := est_row_ct_cons_sit.id;
             pk_csf_api_cons_sit.gt_row_ct_cons_sit.dm_situacao   := 7;
             --
             pk_csf_api_cons_sit.pkb_ins_atu_ct_cons_sit ( est_row_ct_cons_sit => pk_csf_api_cons_sit.gt_row_ct_cons_sit
                                                         , ev_campo_atu        => 'dm_situacao'
                                                         , en_tp_rotina        => 0 -- atualização
                                                         , ev_rotina_orig      => 'pk_csf_api_cons_sit.pkb_integr_ct_cons_sit'
                                                         );
             --
          else
             --
             -- Chama rotina que atualiza a tabela ct_cons_sit
             pk_csf_api_cons_sit.gt_row_ct_cons_sit               := null;
             pk_csf_api_cons_sit.gt_row_ct_cons_sit.empresa_id    := vn_empresa_id;
             pk_csf_api_cons_sit.gt_row_ct_cons_sit.id            := est_row_ct_cons_sit.id;
             pk_csf_api_cons_sit.gt_row_ct_cons_sit.dm_situacao   := 1;
             --
             pk_csf_api_cons_sit.pkb_ins_atu_ct_cons_sit ( est_row_ct_cons_sit => pk_csf_api_cons_sit.gt_row_ct_cons_sit
                                                         , ev_campo_atu        => 'dm_situacao'
                                                         , en_tp_rotina        => 0 -- atualização
                                                         , ev_rotina_orig      => 'pk_csf_api_cons_sit.pkb_integr_ct_cons_sit'
                                                         );
             --
          end if;
          --
          commit;
          --
      exception
         when others then
            pkb_log_generico_conssit_ct ( sn_loggenericoct_id => vn_loggenerico_id
                                        , ev_mensagem         => 'Erro ao tentar inserir/atualizar os dados na tabela ct_cons_sit'
                                        , ev_resumo           => 'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')Erro('||sqlerrm||')'
                                        , en_tipo_log         => erro_de_sistema
                                        , en_empresa_id       => null );
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_conssit_ct ( en_loggenericoct_id => vn_loggenerico_id
                                           , est_log_generico_ct => est_log_generico_ct );
      end;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_csf_api_cons_sit.pkb_integr_ct_cons_sit fase('||vn_fase||'). Erro: '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         pkb_log_generico_conssit_ct ( sn_loggenericoct_id => vn_loggenerico_id
                                     , ev_mensagem         => gv_mensagem
                                     , ev_resumo           => gv_mensagem
                                     , en_tipo_log         => erro_de_sistema
                                     , en_empresa_id       => vn_empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit_ct ( en_loggenericoct_id => vn_loggenerico_id
                                        , est_log_generico_ct => est_log_generico_ct );
      exception
         when others then
            null;
      end;
   --
END pkb_integr_ct_cons_sit;
--
-- ====================================================================================================================== --
--
end pk_csf_api_cons_sit;
/
