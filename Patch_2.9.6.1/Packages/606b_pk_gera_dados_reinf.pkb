create or replace package body csf_own.pk_gera_dados_reinf is

-------------------------------------------------------------------------------------------------------------
-- Inclui o registro na tabela EFD_REINF_EVT_PENDENTE para sinalizar a valida ambiente que tem registro pendente de validação
-------------------------------------------------------------------------------------------------------------
procedure pkb_inc_reg_pendencia_valid ( en_geracaoefdreinf_id in geracao_efd_reinf.id%type
                                      , ev_sigla_evt          in evt_efd_reinf.sigla%type)
is                                      
   --
   vn_fase                         number := 0;
   vn_evtefdreinf_id               number := 0;
   pragma                          autonomous_transaction;
   --
begin
   --
   vn_fase := 1;
   --
   -- Busca o id do evento --
   begin
      --
      select e.id
         into vn_evtefdreinf_id
      from evt_efd_reinf e
      where e.sigla_compl = ev_sigla_evt;
      --
   exception
      when others then
         vn_evtefdreinf_id := null;
   end;
   --
   vn_fase := 2;
   --
   -- Busca o período --
   if nvl(gt_row_geracao_efd_reinf.id, 0) <> en_geracaoefdreinf_id then
      begin
         --
         select *
            into gt_row_geracao_efd_reinf
         from geracao_efd_reinf g
         where g.id = en_geracaoefdreinf_id;
         --
      exception
         when others then
            gt_row_geracao_efd_reinf := null;
      end;
      --
   end if;
   --
   vn_fase := 3;
   --
   -- Insere o registro de pendencia --
   begin
      insert into EFD_REINF_EVT_PENDENTE ( id,
                                           empresa_id,
                                           geracaoefdreinf_id,
                                           evtefdreinf_id)
                                  values ( efdreinfevtpendente_seq.nextval
                                         , gt_row_geracao_efd_reinf.empresa_id
                                         , gt_row_geracao_efd_reinf.id
                                         , vn_evtefdreinf_id
                                         ); 
   exception
      when dup_val_on_index then
         null;
   end;                                            
   --
   commit;
   --  
exception
   when others then
      --
      rollback;
      --
      pk_csf_api_reinf.gv_mensagem_log := 'Erro na pk_gera_dados_reinf.pkb_inc_reg_pendencia_valid (fase: '||vn_fase||') - Erro Retornado: '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_reinf.id%TYPE;
      begin
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => gv_resumo
                                                 , en_tipo_log             => ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_inc_reg_pendencia_valid;
--
-------------------------------------------------------------------------------------------------------------
-- Exclui o registro na tabela EFD_REINF_EVT_PENDENTE para sinalizar a valida ambiente que não tem registro pendente de validação
-------------------------------------------------------------------------------------------------------------
procedure pkb_del_reg_pendencia_valid ( en_geracaoefdreinf_id in geracao_efd_reinf.id%type
                                      , ev_sigla_evt          in evt_efd_reinf.sigla%type)
is                                      
   --
   vn_fase                         number := 0;
   vn_evtefdreinf_id               number := 0;
   pragma                          autonomous_transaction;
   --
begin
   --
   vn_fase := 1;
   --
   -- Busca o id do evento --
   begin
      --
      select e.id
         into vn_evtefdreinf_id
      from evt_efd_reinf e
      where e.sigla_compl = ev_sigla_evt;
      --
   exception
      when others then
         vn_evtefdreinf_id := null;
   end;
   --
   vn_fase := 2;
   --
   -- Busca o período --
   if nvl(gt_row_geracao_efd_reinf.id, 0) <> en_geracaoefdreinf_id then
      begin
         --
         select *
            into gt_row_geracao_efd_reinf
         from geracao_efd_reinf g
         where g.id = en_geracaoefdreinf_id;
         --
      exception
         when others then
            gt_row_geracao_efd_reinf := null;
      end;
      --
   end if;
   --
   vn_fase := 3;
   --
   -- Apaga o registro de pendencia --
   begin
      --
      delete efd_reinf_evt_pendente ep
      where ep.empresa_id         = gt_row_geracao_efd_reinf.empresa_id
        and ep.geracaoefdreinf_id = gt_row_geracao_efd_reinf.id
        and ep.evtefdreinf_id     = vn_evtefdreinf_id;
      --
   exception
      when no_data_found then
         null;
   end;                                            
   --
   commit;
   --  
exception
   when others then
      --
      rollback;
      --
      pk_csf_api_reinf.gv_mensagem_log := 'Erro na pk_gera_dados_reinf.pkb_inc_reg_pendencia_valid (fase: '||vn_fase||') - Erro Retornado: '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_reinf.id%TYPE;
      begin
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => gv_resumo
                                                 , en_tipo_log             => ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --                        
end pkb_del_reg_pendencia_valid;
--
------------------------------------------------------
--| Procedimento armazena o valor do "loggenerico_id"
------------------------------------------------------
procedure pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  in             Log_generico_reinf.id%TYPE
                                    , est_log_generico_reinf  in out nocopy  dbms_sql.number_table
                                    ) is
   --
   i pls_integer;
   --
begin
   --
   if nvl(en_loggenericoreinf_id,0) > 0 then
      --
      i := nvl(est_log_generico_reinf.count,0) + 1;
      --
      est_log_generico_reinf(i) := en_loggenericoreinf_id;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      pk_csf_api_reinf.gv_mensagem_log := 'Erro na pk_gera_dados_reinf.pkb_gt_log_generico_reinf: '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_reinf.id%TYPE;
      begin
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => gv_resumo
                                                 , en_tipo_log             => ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_gt_log_generico_reinf;

-------------------------------------------------------------------------------------------------------
-- Processo que recupera os dados da Abertura do EFD-REINF
procedure pkb_dados_geracao_reinf ( en_geracaoefdreinf_id in geracao_efd_reinf.id%type
                                  )
is
begin
   --
   select *
     into gt_row_geracao_efd_reinf
     from geracao_efd_reinf gr
    where gr.id = en_geracaoefdreinf_id;
   --
   gt_row_geracao_efd_reinf.dt_ini := to_date(to_char(trunc(gt_row_geracao_efd_reinf.dt_ini),'dd/mm/rrrr') || ' ' || '00:00','dd/mm/rrrr hh24:mi');
   gt_row_geracao_efd_reinf.dt_fin := to_date(to_char(trunc(gt_row_geracao_efd_reinf.dt_fin),'dd/mm/rrrr') || ' ' || '23:59','dd/mm/rrrr hh24:mi');
   --
   commit;
   --
exception
   when no_data_found then
      gt_row_geracao_efd_reinf := null;
   when others then
      raise_application_error(-20101, 'Erro na pk_gera_dados_reinf.pkb_dados_geracao_reinf: '||sqlerrm);
end pkb_dados_geracao_reinf;

---------------------------------------------------------------------------------------------------
-- Processo de Limpeza dos Arrays do EDF-REINF
procedure pkb_limpa_arrays
is
begin
   --
   gt_row_geracao_efd_reinf       := null;
   gt_row_param_efd_reinf_empresa := null;
   --
end pkb_limpa_arrays;

---------------------------------------------------------------------------------------------------
-- Processo de Geração do ID do evento do EFD-REINF
procedure pkb_gera_id_evt_reinf ( ev_obj_referencia in varchar2
                                , en_referencia_id  in number
                                )
is
   --
   vn_fase                 number;
   vn_geracaoefdreinf_id   geracao_efd_reinf.id%type;
   vn_ctrlevtreinf_seq     ctrl_evt_reinf.seq%type;
   --
   vt_ctrl_evt_reinf       ctrl_evt_reinf%rowtype;
   vn_empresa_id           empresa.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if trim(ev_obj_referencia) is not null
    and nvl(en_referencia_id,0) > 0 then
      --
      vn_fase := 2;
      --
      vn_geracaoefdreinf_id := null;
      vt_ctrl_evt_reinf     := null;
      vn_ctrlevtreinf_seq   := null;
      vn_empresa_id         := null;
      --
      vn_fase := 3;
      --
      vn_geracaoefdreinf_id := pk_csf_reinf.fkg_geracaoefdreinf_id_objref ( ev_obj_referencia
                                                                          , en_referencia_id
                                                                          );
      --
      vn_fase := 4;
      -- Recupera os dados da Abertura do EFD-REINF
      pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => vn_geracaoefdreinf_id );
      --
      vn_fase := 5;
      --
      vt_ctrl_evt_reinf.geracaoefdreinf_id := gt_row_geracao_efd_reinf.id;
      vt_ctrl_evt_reinf.referencia_id      := en_referencia_id;
      vt_ctrl_evt_reinf.obj_referencia     := ev_obj_referencia;
      vt_ctrl_evt_reinf.dt_hr_evt          := to_date(to_char(sysdate,'dd/mm/yyyy hh24:mi:ss'),'dd/mm/yyyy hh24:mi:ss');
      --
      vn_fase := 6;
      --
      begin
         --
         select empresa_id
           into vn_empresa_id
           from geracao_efd_reinf
          where id = vt_ctrl_evt_reinf.geracaoefdreinf_id;
         --
      exception
       when others then
         vn_empresa_id := null;
      end;
      --
      vn_fase := 7;
      -- Recuperar a quantidade de eventos gerados para empresa dentro da data/hora atual
      begin
         --
         select nvl(max(ce.seq) + 1,0)
           into vn_ctrlevtreinf_seq
           from ctrl_evt_reinf    ce
              , geracao_efd_reinf ge
          where ce.geracaoefdreinf_id = ge.id
            and ge.empresa_id         = vn_empresa_id
            and ge.id                 = vn_geracaoefdreinf_id;
         --
      exception
       when others then
         vn_ctrlevtreinf_seq := 0;
      end;
      --
      vn_fase := 8;
      -- O número sequencial da chave será iniciado no valor 0
      if nvl(vn_ctrlevtreinf_seq, 0) = 0 then
         --
         vt_ctrl_evt_reinf.seq := 0;
         --
      else
         --
         vt_ctrl_evt_reinf.seq := vn_ctrlevtreinf_seq;
         --
      end if;
      --
      vn_fase := 9;
      --
      vt_ctrl_evt_reinf.evt := 'ID';
      vt_ctrl_evt_reinf.evt := vt_ctrl_evt_reinf.evt || '1';
      vt_ctrl_evt_reinf.evt := vt_ctrl_evt_reinf.evt || rpad(substr(pk_csf.fkg_cnpj_ou_cpf_empresa (vn_empresa_id),1, 8), 14, 0);
      vt_ctrl_evt_reinf.evt := vt_ctrl_evt_reinf.evt || to_char(vt_ctrl_evt_reinf.dt_hr_evt,'yyyymmdd');
      vt_ctrl_evt_reinf.evt := vt_ctrl_evt_reinf.evt || to_char(vt_ctrl_evt_reinf.dt_hr_evt,'hh24miss');
      vt_ctrl_evt_reinf.evt := vt_ctrl_evt_reinf.evt || lpad(vt_ctrl_evt_reinf.seq, 5, 0);
      --
      vn_fase := 10;
      --
      vn_fase := 11;
      --
         select ctrlevtreinf_seq.nextval
           into vt_ctrl_evt_reinf.id
           from dual;
         --
         vn_fase := 12;
         --
         insert into ctrl_evt_reinf ( id
                                    , geracaoefdreinf_id
                                    , dt_hr_evt
                                    , seq
                                    , evt
                                    , referencia_id
                                    , obj_referencia )
                              values( vt_ctrl_evt_reinf.id
                                    , vt_ctrl_evt_reinf.geracaoefdreinf_id
                                    , vt_ctrl_evt_reinf.dt_hr_evt
                                    , vt_ctrl_evt_reinf.seq
                                    , vt_ctrl_evt_reinf.evt
                                    , en_referencia_id
                                    , vt_ctrl_evt_reinf.obj_referencia );

         --
         vn_fase := 13;
         --
         -- Inclui o registro na tabela de pendencias a ser processada para agilizar a busca pelo Job da Valida ambiente
         pkb_inc_reg_pendencia_valid ( en_geracaoefdreinf_id => vt_ctrl_evt_reinf.geracaoefdreinf_id
                                     , ev_sigla_evt          => vt_ctrl_evt_reinf.obj_referencia );
         --
      end if;
      --
      commit;
      --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.fkg_gera_id_evt_reinf fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
end pkb_gera_id_evt_reinf;

----------------------------------------------------------------------------------------------------
-- Procedimento que valida se existe eventos que ainda não foram Processados pelo EFD-REINF
procedure pkb_vld_evt_espera ( est_log_generico_reinf  in out nocopy dbms_sql.number_table  
                             )
is
   --
   vn_efdreinfr1000_id        number;
   vn_dm_st_proc              number;
   --
   vn_fase                    number;
   vn_loggenericoreinf_id     number;
   --
   cursor c_r1000 is
   select er.id
        , er.dm_st_proc
     from efd_reinf_r1000  er
    where er.geracaoefdreinf_id = gt_row_geracao_efd_reinf.id
      and er.id in (select max(er2.id)
                      from efd_reinf_r1000  er2
                     where er2.geracaoefdreinf_id = er.geracaoefdreinf_id
                       and er2.dm_st_proc not in (4,5,6)); -- 4-Processado; 5-Não enviado; 6-Erro na montagem do XML
   --
   cursor c_r1070 is
   select er.id
        , er.dm_st_proc
        , pa.nro_proc
        , pa.dm_tp_proc
     from efd_reinf_r1070    er
        , proc_adm_efd_reinf pa
    where pa.id                 = er.procadmefdreinf_id
      and er.geracaoefdreinf_id = gt_row_geracao_efd_reinf.id
      and er.id in (select max(er2.id)
                      from efd_reinf_r1070    er2
                     where er2.geracaoefdreinf_id = er.geracaoefdreinf_id
                       and er2.procadmefdreinf_id = er.procadmefdreinf_id
                       and er2.dm_st_proc not in (4,5,6)); -- 4-Processado; 5-Não enviado; 6-Erro na montagem do XML

   --
   cursor c_r2010 is
   select er.id
        , er.dm_st_proc
     from efd_reinf_r2010  er
    where er.geracaoefdreinf_id = gt_row_geracao_efd_reinf.id
      and er.id in (select max(er2.id)
                      from efd_reinf_r2010  er2
                     where er2.geracaoefdreinf_id = er.geracaoefdreinf_id
                       and er2.dm_ind_tp_inscr    = er.dm_ind_tp_inscr
                       and er2.nro_inscr_estab    = er.nro_inscr_estab
                       and er2.cnpj               = er.cnpj
                       and er2.dm_st_proc not in (4,5,6,7,8)); -- 4-Processado; 5-Não enviado; 6-Erro na montagem do XML; 7-Excluído; 8-Processado R-5001
   --
   cursor c_r2020 is
   select er.id
        , er.dm_st_proc
     from efd_reinf_r2020  er
    where er.geracaoefdreinf_id = gt_row_geracao_efd_reinf.id
      and er.id in (select max(er2.id)
                      from efd_reinf_r2020  er2
                     where er2.geracaoefdreinf_id = er.geracaoefdreinf_id
                       and er2.dm_ind_tp_inscr    = er.dm_ind_tp_inscr
                       and er2.nro_inscr_estab    = er.nro_inscr_estab
                       and er2.cnpj               = er.cnpj
                       and er2.dm_st_proc not in (4,5,6,7,8)); -- 4-Processado; 5-Não enviado; 6-Erro na montagem do XML; 7-Excluído; 8-Processado R-5001
   --
   cursor c_r2030 is
   select er.id
        , er.dm_st_proc
     from efd_reinf_r2030  er
    where er.geracaoefdreinf_id = gt_row_geracao_efd_reinf.id
      and er.id in (select max(er2.id)
                      from efd_reinf_r2030  er2
                     where er2.geracaoefdreinf_id = er.geracaoefdreinf_id
                       and er2.dm_st_proc not in (4,5,6,7)); -- 4-Processado; 5-Não enviado; 6-Erro na montagem do XML; 7-Excluído
   --
   cursor c_r2040 is
   select er.id
        , er.dm_st_proc
     from efd_reinf_r2040  er
    where er.geracaoefdreinf_id = gt_row_geracao_efd_reinf.id
      and er.id in (select max(er2.id)
                      from efd_reinf_r2040  er2
                     where er2.geracaoefdreinf_id = er.geracaoefdreinf_id
                       and er2.dm_st_proc not in (4,5,6,7,8)); -- 4-Processado; 5-Não enviado; 6-Erro na montagem do XML; 7-Excluído; 8-Processado R-5001
   --
   cursor c_r2050 is
   select er.id
        , er.dm_st_proc
        , cp.empresa_id
        , cp.dt_ref
     from comer_prod_rural_pj_agr cp
        , efd_reinf_r2050         er
    where cp.id                 = er.comerprodruralpjagr_id
      and er.geracaoefdreinf_id = gt_row_geracao_efd_reinf.id
      and er.id in (select max(er2.id)
                      from efd_reinf_r2050  er2
                     where er2.geracaoefdreinf_id     = er.geracaoefdreinf_id
                       and er2.comerprodruralpjagr_id = er.comerprodruralpjagr_id
                       and er2.dm_st_proc not in (4,5,6,7,8)); -- 4-Processado; 5-Não enviado; 6-Erro na montagem do XML; 7-Excluído; 8-Processado R-5001
   --
   cursor c_r2060 is
   select er.id
        , er.dm_st_proc
     from efd_reinf_r2060  er
    where er.geracaoefdreinf_id = gt_row_geracao_efd_reinf.id
      and er.id in (select max(er2.id)
                      from efd_reinf_r2060  er2
                     where er2.geracaoefdreinf_id = er.geracaoefdreinf_id
                       and er2.apurcprbempr_id    = er.apurcprbempr_id
                       and er2.dm_st_proc not in (4,5,6,7,8)); -- 4-Processado; 5-Não enviado; 6-Erro na montagem do XML; 7-Excluído; 8-Processado R-5001
   --
   cursor c_r2070 is
   select er.id
        , er.dm_st_proc
        , tr.cd ||' - '|| tr.descr     tipo_ret_imp
     from tipo_ret_imp     tr
        , efd_reinf_r2070  er
    where tr.id                 = er.tiporetimp_id
      and er.geracaoefdreinf_id = gt_row_geracao_efd_reinf.id
      and er.id in (select max(er2.id)
                      from efd_reinf_r2070  er2
                     where er2.geracaoefdreinf_id = er.geracaoefdreinf_id
                       and er2.pessoa_id          = er.pessoa_id
                       and er2.tiporetimp_id      = er.tiporetimp_id
                       and er2.dm_st_proc not in (4,5,6,7)); -- 4-Processado; 5-Não enviado; 6-Erro na montagem do XML; 7-Excluído
   --
   cursor c_r2098 is
   select er.id
        , er.dm_st_proc
     from efd_reinf_r2098  er
    where er.geracaoefdreinf_id = gt_row_geracao_efd_reinf.id
      and er.id in (select max(er2.id)
                      from efd_reinf_r2098  er2
                     where er2.geracaoefdreinf_id = er.geracaoefdreinf_id
                       and er2.dm_st_proc not in (4,5,6)); -- 4-Processado; 5-Não enviado; 6-Erro na montagem do XML
   --
   cursor c_r2099 is
   select er.id
        , er.dm_st_proc
     from efd_reinf_r2099  er
    where er.geracaoefdreinf_id = gt_row_geracao_efd_reinf.id
      and er.id in (select max(er2.id)
                      from efd_reinf_r2099  er2
                     where er2.geracaoefdreinf_id = er.geracaoefdreinf_id
                       and er2.dm_st_proc not in (4,7)); -- 4-Processado; 7-Processado R-5011
   --
   cursor c_r3010 is
   select er.id
        , er.dm_st_proc
     from efd_reinf_r3010  er
    where er.geracaoefdreinf_id = gt_row_geracao_efd_reinf.id
      and er.id in (select max(er2.id)
                      from efd_reinf_r3010  er2
                     where er2.geracaoefdreinf_id = er.geracaoefdreinf_id
                       and er2.dm_st_proc not in (4,5,6,7,8)); -- 4-Processado; 5-Não enviado; 6-Erro na montagem do XML; 7-Excluído; 8-Processado R-5001
   --
begin
   --
   vn_efdreinfr1000_id := null;
   vn_dm_st_proc       := null;
   --
   vn_fase := 1;
   -- Verificar se o último evento de Parãmetros da empresa foi processado caso exista
   begin
      --
      select id
           , dm_st_proc
        into vn_efdreinfr1000_id
           , vn_dm_st_proc
        from efd_reinf_r1000
       where id in ( select max(id)
                       from efd_reinf_r1000
                      where geracaoefdreinf_id = gt_row_geracao_efd_reinf.id );
      --
   exception
    when others then
      vn_efdreinfr1000_id  := null;
      vn_dm_st_proc        := null;
   end;
   --
   vn_fase := 2;
   --
   if nvl(vn_efdreinfr1000_id,0) > 0
    and nvl(vn_dm_st_proc,0) in (5,6) then  -- 5-Erro no envio; 6-Erro na montagem do XML
      --
      vn_fase := 2.1;
      --
      gv_mensagem := 'Período de geração não pode ser "Fechado", pois o último evento R-1000 está com a situação "Erro no Envio" ou "Erro na montagem do XML", Favor Verificar.';
      --
      pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                              , ev_mensagem             => gv_mensagem
                                              , ev_resumo               => gv_mensagem
                                              , en_tipo_log             => INFORMACAO
                                              , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                              , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                              , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                              );
      --
      pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                , est_log_generico_reinf  => est_log_generico_reinf
                                );
      --                           
   end if;
   --
   vn_fase := 3;
   --
   for rec in c_r1000 loop
      exit when c_r1000%notfound or (c_r1000%notfound) is null;
      --
      vn_fase := 3.1;
      --
      gv_mensagem := 'Período de geração não pode ser "Fechado", pois o último evento R-1000 gerado está com a situação "'||
                     pk_csf.fkg_dominio ( 'EFD_REINF_R1000.DM_ST_PROC', rec.dm_st_proc ) ||'".';
      --
      pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                              , ev_mensagem             => gv_mensagem
                                              , ev_resumo               => gv_mensagem
                                              , en_tipo_log             => INFORMACAO
                                              , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                              , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                              , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                              );
      --
      pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                , est_log_generico_reinf  => est_log_generico_reinf
                                );
      --
   end loop;
   --
   vn_fase := 4;
   --
   for rec in c_r1070 loop
      exit when c_r1070%notfound or (c_r1070%notfound) is null;
      --
      vn_fase := 4.1;
      --
      gv_mensagem := 'Período de geração não pode ser "Fechado", pois o último evento R-1070 gerado para o processo administrativo '||rec.nro_proc||
                     ' tipo de processo "'||pk_csf.fkg_dominio('PROC_ADM_EFD_REINF.DM_TP_PROC', rec.dm_tp_proc)||'" está com a situação "'||
                     pk_csf.fkg_dominio ( 'EFD_REINF_R1070.DM_ST_PROC', rec.dm_st_proc ) ||'".';
      --
      pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                              , ev_mensagem             => gv_mensagem
                                              , ev_resumo               => gv_mensagem
                                              , en_tipo_log             => INFORMACAO
                                              , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                              , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                              , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                              );
      --
      pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                , est_log_generico_reinf  => est_log_generico_reinf
                                );
      --
   end loop;
   --
   vn_fase := 5;
   --
   if gt_row_geracao_efd_reinf.dm_tipo = 1 then -- 1-Periódico
      --
      for rec in c_r2010 loop
         exit when c_r2010%notfound or (c_r2010%notfound) is null;
         --
         vn_fase := 5.1;
         --
         gv_mensagem := 'Período de geração não pode ser "Fechado", pois o último evento R-2010 gerado está com a situação "'||
                        pk_csf.fkg_dominio ( 'EFD_REINF_R2010.DM_ST_PROC', rec.dm_st_proc ) ||'".';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      end loop;
      --
      vn_fase := 6;
      --
      for rec in c_r2020 loop
         exit when c_r2020%notfound or (c_r2020%notfound) is null;
         --
         vn_fase := 6.1;
         --
         gv_mensagem := 'Período de geração não pode ser "Fechado", pois o último evento R-2020 gerado está com a situação "'||
                        pk_csf.fkg_dominio ( 'EFD_REINF_R2020.DM_ST_PROC', rec.dm_st_proc ) ||'".';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      end loop;
      --
      vn_fase := 7;
      --
      for rec in c_r2030 loop
         exit when c_r2030%notfound or (c_r2030%notfound) is null;
         --
         vn_fase := 7.1;
         --
         gv_mensagem := 'Período de geração não pode ser "Fechado", pois o último evento R-2030 gerado está com a situação "'||
                        pk_csf.fkg_dominio ( 'EFD_REINF_R2030.DM_ST_PROC', rec.dm_st_proc ) ||'".';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      end loop;
      --
      vn_fase := 8;
      --
      for rec in c_r2040 loop
         exit when c_r2040%notfound or (c_r2040%notfound) is null;
         --
         vn_fase := 8.1;
         --
         gv_mensagem := 'Período de geração não pode ser "Fechado", pois o último evento R-2040 gerado está com a situação "'||
                        pk_csf.fkg_dominio ( 'EFD_REINF_R2040.DM_ST_PROC', rec.dm_st_proc ) ||'".';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      end loop;
      --
      vn_fase := 9;
      --
      for rec in c_r2050 loop
         exit when c_r2050%notfound or (c_r2050%notfound) is null;
         --
         vn_fase := 9.1;
         --
         gv_mensagem := 'Período de geração não pode ser "Fechado", pois o último evento R-2050 gerado para a comercialização de produção rural'||
                        ' da empresa '||pk_csf.fkg_codpart_empresaid(rec.empresa_id)||' data de referência '||to_char(rec.dt_ref, 'dd/mm/yyyy')||
                        ' está com a situação "'||pk_csf.fkg_dominio ( 'EFD_REINF_R2050.DM_ST_PROC', rec.dm_st_proc ) ||'".';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      end loop;
      --
      vn_fase := 10;
      --
      for rec in c_r2060 loop
         exit when c_r2060%notfound or (c_r2060%notfound) is null;
         --
         vn_fase := 10.1;
         --
         gv_mensagem := 'Período de geração não pode ser "Fechado", pois o último evento R-2060 gerado está com a situação "'||
                        pk_csf.fkg_dominio ( 'EFD_REINF_R2060.DM_ST_PROC', rec.dm_st_proc ) ||'".';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      end loop;
      --
      vn_fase := 11;
      --
      for rec in c_r2070 loop
         exit when c_r2070%notfound or (c_r2070%notfound) is null;
         --
         vn_fase := 11.1;
         --
         gv_mensagem := 'Período de geração não pode ser "Fechado", pois o último evento R-2070 gerado para o tipo de imposto retido '||
                         rec.tipo_ret_imp ||' está com a situação "'||pk_csf.fkg_dominio ( 'EFD_REINF_R2070.DM_ST_PROC', rec.dm_st_proc ) ||'".';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      end loop;
      --
      vn_fase := 12;
      --
      for rec in c_r2098 loop
         exit when c_r2098%notfound or (c_r2098%notfound) is null;
         --
         vn_fase := 12.1;
         --
         gv_mensagem := 'Período de geração não pode ser "Fechado", pois o último evento R-2098 gerado está com a situação "'||
                        pk_csf.fkg_dominio ( 'EFD_REINF_R2098.DM_ST_PROC', rec.dm_st_proc ) ||'".';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      end loop;
      --
      vn_fase := 13;
      --
      for rec in c_r2099 loop
         exit when c_r2099%notfound or (c_r2099%notfound) is null;
         --
         vn_fase := 13.1;
         --
         gv_mensagem := 'Período de geração não pode ser "Fechado", pois o último evento R-2099 gerado está com a situação "'||
                           pk_csf.fkg_dominio ( 'EFD_REINF_R2099.DM_ST_PROC', rec.dm_st_proc ) ||'".';
         --
         if rec.dm_st_proc in (5,6) then --5-Não enviado; 6-Erro na montagem do XML
            --
            gv_mensagem := gv_mensagem || ' Neste caso, será necessário reenviar o último evento R-2099 gerado.';
            --
         end if;
         --
         vn_fase := 13.2;
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      end loop;
      --
   else -- 2-Não periódico
      --
      vn_fase := 14;
      --
      for rec in c_r3010 loop
         exit when c_r3010%notfound or (c_r3010%notfound) is null;
         --
         vn_fase := 14.1;
         --
         gv_mensagem := 'Período de geração não pode ser "Fechado", pois o último evento R-3010 gerado está com a situação "'||
                        pk_csf.fkg_dominio ( 'EFD_REINF_R3010.DM_ST_PROC', rec.dm_st_proc ) ||'".';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_vld_evt_espera fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenerico_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_vld_evt_espera;

----------------------------------------------------------------------------------------------------
-- Procedimento que valida se existe alguma informação que não foi gerada pelo EFD-REINF
procedure pkb_vld_inf_nao_enviada ( est_log_generico_reinf  in out nocopy dbms_sql.number_table
                                  )
is
   --
   vn_fase                    number;
   vn_loggenericoreinf_id     number;

   -- Informações do Evento R-1000
   cursor c_r1000 is
   select distinct
          pe.empresa_id
     from log_param_efd_reinf_empresa lp
        , param_efd_reinf_empresa     pe
    where pe.empresa_id = gt_row_geracao_efd_reinf.empresa_id
      and pe.id         = lp.paramefdreinfempresa_id
      and lp.dm_envio   = 0;

   -- Informações do Evento R-1070
   cursor c_r1070 is
   select distinct
          pa.nro_proc
        , pa.dm_tp_proc
        , pa.dm_situacao
     from log_proc_adm_efd_reinf lp
        , proc_adm_efd_reinf     pa
    where pa.empresa_id = gt_row_geracao_efd_reinf.empresa_id
      and pa.id         = lp.procadmefdreinf_id
      and pa.dt_ini    <= gt_row_geracao_efd_reinf.dt_ini
      and ((pa.dt_fin  >= gt_row_geracao_efd_reinf.dt_fin) or (pa.dt_fin is null))
      and lp.dm_envio   = 0;

   -- Informações do Evento R-2010 (Notas Fiscais de Entrada - Emissão Terceiros)
   cursor c_r2010_nf is
   select distinct
          nf.id notafiscal_id
        , nf.nro_nf
        , nf.pessoa_id
        , nfdc.dm_ind_obra
        , nf.empresa_id
        , nf.serie
        , nfdc.nro_cno
        , trunc(nf.dt_emiss) dt_emiss
     from nota_fiscal           nf
        , item_nota_fiscal      inf
        , imp_itemnf            ii
        , tipo_imposto          ti
        , nfs_det_constr_civil  nfdc
        , mod_fiscal            mf
    where nf.id = inf.notafiscal_id
      and ii.itemnf_id   = inf.id
      and nf.empresa_id  in (select id from empresa where ar_empresa_id  = gt_row_geracao_efd_reinf.empresa_id union all select gt_row_geracao_efd_reinf.empresa_id from dual)
      and nf.dm_st_proc  = 4 -- Autorizada
      and nf.dm_ind_emit = 1 -- Terceiro
      and nf.dm_ind_oper = 0 -- Entrada
      and nf.dm_arm_nfe_terc = 0 -- Não pegar notas do MIDAS. (armazenamento)
      and nf.dt_emiss    between gt_row_geracao_efd_reinf.dt_ini and gt_row_geracao_efd_reinf.dt_fin
      and ii.tipoimp_id  = ti.id
      and ti.cd          = 13 -- INSS
      and ii.dm_tipo     = 1  -- Retido
      and nvl(ii.vl_imp_trib, 0)  > 0
      and nvl(ii.vl_base_calc, 0) > 0
      and mf.id          = nf.modfiscal_id
      and ((mf.cod_mod   = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and nf.dm_envio_reinf = 0 -- Não Enviada
      and nfdc.notafiscal_id (+) = nf.id
      and exists (select 1
                    from juridica ju
                   where ju.pessoa_id = nf.pessoa_id
                   union
                  select 1
                    from nota_fiscal_emit  nfe
                   where nfe.notafiscal_id = nf.id
                     and trim(nfe.cnpj) is not null);


   -- Informações do Evento R-2010 (CTe - Aquisição)
   cursor c_r2010_cte is
   select distinct
          ct.id conhectransp_id,
          ct.nro_ct,
          ct.serie,
          ct.dt_hr_emissao,
          ct.empresa_id
     from conhec_transp          ct,
          conhec_transp_imp_ret cti,
          tipo_imposto           ti,
          mod_fiscal             mf
    where cti.conhectransp_id  = ct.id
      and ti.id                = cti.tipoimp_id
      and mf.id                = ct.modfiscal_id
      --
      and ct.empresa_id        = gt_row_geracao_efd_reinf.empresa_id
      and ct.empresa_id  in (select id from empresa where ar_empresa_id  = gt_row_geracao_efd_reinf.empresa_id union all select gt_row_geracao_efd_reinf.empresa_id from dual)
      and ct.dt_hr_emissao     between gt_row_geracao_efd_reinf.dt_ini
                                   and gt_row_geracao_efd_reinf.dt_fin
      and ct.dm_envio_reinf    = 0    -- Não Enviada
      and ct.dm_st_proc        = 4    -- Autorizada
      and ct.dm_ind_oper       = 0    -- Aquisição
      and mf.cod_mod           = '67' -- Conhecimento de Transporte Eletrônico - Outros Serviços
      --
      and ti.cd                = 13   -- INSS
      and ct.dm_arm_cte_terc   = 0    -- Pegar somente CTes convertidos
      --
      and exists (select 1
                    from juridica ju
                   where ju.pessoa_id = ct.pessoa_id
                   union
                  select 1
                    from conhec_transp_emit  cte
                   where cte.conhectransp_id = ct.id
                     and trim(cte.cnpj) is not null);



   -- Informações do Evento R-2020 (Notas Fiscais de Saída Emissão Própria)
   cursor c_r2020_nf is
   select distinct
          nf.id notafiscal_id
        , nf.nro_nf
        , nf.pessoa_id
        , nfdc.dm_ind_obra
        , nf.empresa_id
        , nf.serie
        , nfdc.nro_cno
        , trunc(nf.dt_emiss) dt_emiss
     from nota_fiscal           nf
        , item_nota_fiscal      inf
        , imp_itemnf            ii
        , tipo_imposto          ti
        , nfs_det_constr_civil  nfdc
        , mod_fiscal            mf
    where nf.id = inf.notafiscal_id
      and ii.itemnf_id   = inf.id
      and nf.empresa_id  in (select id from empresa where ar_empresa_id  = gt_row_geracao_efd_reinf.empresa_id union all select gt_row_geracao_efd_reinf.empresa_id from dual)
      and nf.dm_st_proc  = 4 -- Autorizada
      and nf.dm_ind_emit = 0 -- Emissão própria
      and nf.dm_ind_oper = 1 -- Saida
      and nf.dm_arm_nfe_terc = 0 -- Não pegar notas do MIDAS. (armazenamento)
      and nf.dt_emiss    between gt_row_geracao_efd_reinf.dt_ini and gt_row_geracao_efd_reinf.dt_fin
      and ii.tipoimp_id  = ti.id
      and ti.cd          = 13 -- INSS
      and ii.dm_tipo     = 1  -- Retido
      and nvl(ii.vl_imp_trib, 0)  > 0
      and nvl(ii.vl_base_calc, 0) > 0
      and mf.id          = nf.modfiscal_id
      and ((mf.cod_mod   = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and nf.dm_envio_reinf = 0 -- Não Enviada
      and nfdc.notafiscal_id (+) = nf.id
      and exists (select 1
                    from juridica ju
                   where ju.pessoa_id = nf.pessoa_id
                   union
                  select 1
                    from nota_fiscal_dest  nfd
                   where nfd.notafiscal_id = nf.id
                     and trim(nfd.cnpj) is not null);


   -- Informações do Evento R-2020 (CTe - Prestação)
   cursor c_r2020_cte is
   select distinct
          ct.id conhectransp_id,
          ct.nro_ct,
          ct.serie,
          ct.dt_hr_emissao,
          ct.empresa_id
     from conhec_transp           ct,
          conhec_transp_imp_ret  cti,
          tipo_imposto            ti,
          mod_fiscal              mf
    where cti.conhectransp_id  = ct.id
      and ti.id                = cti.tipoimp_id
      and mf.id                = ct.modfiscal_id
      --
      and ct.empresa_id  in (select id from empresa where ar_empresa_id  = gt_row_geracao_efd_reinf.empresa_id union all select gt_row_geracao_efd_reinf.empresa_id from dual)
      and ct.dt_hr_emissao     between gt_row_geracao_efd_reinf.dt_ini
                                   and gt_row_geracao_efd_reinf.dt_fin
      and ct.dm_envio_reinf    = 0    -- Não Enviada
      and ct.dm_st_proc        = 4    -- Autorizada
      and ct.dm_ind_oper       = 1    -- Prestação
      and mf.cod_mod           = '67' -- Conhecimento de Transporte Eletrônico - Outros Serviços
      --
      and ti.cd                = 13   -- INSS
      and ct.dm_arm_cte_terc   = 0    -- Pegar somente CTes convertidos
      --
      and exists (select 1
                    from juridica ju
                   where ju.pessoa_id = ct.pessoa_id
                   union
                  select 1
                    from conhec_transp_emit  cte
                   where cte.conhectransp_id = ct.id
                     and trim(cte.cnpj) is not null);


   -- Informações do Evento R-2030
   cursor c_r2030 is
   select empresa_id
        , dt_ref
        , pessoa_id_orig
        , dm_st_proc
     from rec_receb_ass_desp
    where empresa_id = gt_row_geracao_efd_reinf.empresa_id
      and dt_ref     between gt_row_geracao_efd_reinf.dt_ini and gt_row_geracao_efd_reinf.dt_fin
      and dm_envio   = 0; -- Não Enviado

   -- Informações do Evento R-2040
   cursor c_r2040 is
   select empresa_id
        , dt_ref
        , pessoa_id_desp
        , dm_st_proc
     from rec_rep_ass_desp
    where empresa_id = gt_row_geracao_efd_reinf.empresa_id
      and dt_ref     between gt_row_geracao_efd_reinf.dt_ini and gt_row_geracao_efd_reinf.dt_fin
      and dm_envio   = 0; -- Não Enviado

   -- Informações do Evento R-2050
   cursor c_r2050 is
   select empresa_id
        , dt_ref
        , dm_st_proc
     from comer_prod_rural_pj_agr
    where empresa_id = gt_row_geracao_efd_reinf.empresa_id
      and dt_ref     between gt_row_geracao_efd_reinf.dt_ini and gt_row_geracao_efd_reinf.dt_fin
      and dm_envio   = 0; -- Não Enviado

   -- Informações do Evento R-2060
   cursor c_r2060 is
   select ace.empresa_id
        , ac.dt_ini
        , ac.dt_fin
        , ace.dm_tipo
        , ace.dm_situacao
     from apur_cprb ac
        , apur_cprb_empr ace
    where ac.empresa_id   = gt_row_geracao_efd_reinf.empresa_id
      and ac.dt_ini       = gt_row_geracao_efd_reinf.dt_ini
      and ac.dt_fin       = gt_row_geracao_efd_reinf.dt_fin
      and ace.apurcprb_id = ac.id
      and ace.dm_situacao = 3 -- Processado
      and ace.dm_envio    = 0;

    -- Informações do Evento R-2070
    cursor c_r2070 is
    select pg.empresa_id
         , pg.nro_doc
         , pg.dt_vcto
         , pg.dt_pgto
         , ti.cd ||' - '|| ti.descr     tipo_imp
         , tr.cd ||' - '|| tr.descr     tipo_ret_imp
         , pg.dm_situacao
      from pgto_imp_ret  pg
         , tipo_imposto  ti
         , tipo_ret_imp  tr
     where pg.tipoimp_id    = ti.id
       and pg.tiporetimp_id = tr.id
       and pg.empresa_id    = gt_row_geracao_efd_reinf.empresa_id
       and pg.dt_docto      between gt_row_geracao_efd_reinf.dt_ini and gt_row_geracao_efd_reinf.dt_fin
       and pg.dm_envio      = 0; -- Não Enviado

   -- Informações do Evento R-3010
   cursor c_r3010 is
   select *
     from rec_esp_desport
    where empresa_id  = gt_row_geracao_efd_reinf.empresa_id
      and dt_ref      between gt_row_geracao_efd_reinf.dt_ini and gt_row_geracao_efd_reinf.dt_fin
      and dm_envio    = 0;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_r1000 loop
      exit when c_r1000%notfound or (c_r1000%notfound) is null;
      --
      vn_fase := 1.1;
      --
      gv_mensagem := 'Período de geração não pode ser "Fechado", pois houve inclusão ou alteração nos parâmetros da empresa '||
                     pk_csf.fkg_codpart_empresaid (rec.empresa_id)||' relacionado ao EFD-REINF e não foi gerado '||
                     'o evento R-1000 com os dados dos parâmetros da empresa atualizados.'||
                     'Neste caso, será necessário gerar os eventos novamente antes de efetuar o fechamento. ';
      --
      pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                              , ev_mensagem             => gv_mensagem
                                              , ev_resumo               => gv_mensagem
                                              , en_tipo_log             => INFORMACAO
                                              , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                              , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                              , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                              );
      --
      pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                , est_log_generico_reinf  => est_log_generico_reinf
                                );
      --
   end loop;
   --
   vn_fase := 2;
   --
   for rec in c_r1070 loop
      exit when c_r1070%notfound or (c_r1070%notfound) is null;
      --
      vn_fase := 2.1;
      --
      gv_mensagem := 'Período de geração não pode ser "Fechado", pois houve inclusão ou alteração do processo administrativo '||rec.nro_proc||
                     ' tipo de processo "'||pk_csf.fkg_dominio('PROC_ADM_EFD_REINF.DM_TP_PROC', rec.dm_tp_proc)|| '" com a situação "'||
                     pk_csf.fkg_dominio('PROC_ADM_EFD_REINF.DM_SITUACAO', rec.dm_situacao)||
                     '" e não foi gerado o evento R-1070 para este processo administrativo atualizado. ' ||
                     'Neste caso, será necessário gerar os eventos novamente antes de efetuar o fechamento.';
      --
      pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                              , ev_mensagem             => gv_mensagem
                                              , ev_resumo               => gv_mensagem
                                              , en_tipo_log             => INFORMACAO
                                              , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                              , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                              , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                              );
      --
      pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                , est_log_generico_reinf  => est_log_generico_reinf
                                );
      --
   end loop;
   --
   vn_fase := 5;
   --
   gn_dm_dt_escr_dfepoe := pk_csf.fkg_dmdtescrdfepoe_empresa(en_empresa_id => gt_row_geracao_efd_reinf.empresa_id);
   --
   vn_fase := 6;
   --
   if gt_row_geracao_efd_reinf.dm_tipo = 1 then -- 1-Periódico
      --
      vn_fase := 6.1;
      --
      -- Primeiro passo: Checar se foi dado manutenção em alguma nota (volta para dm_envio_reinf = 0) e ela se encontra Processada R-5001
      for rec in c_r2010_nf loop
         exit when c_r2010_nf%notfound or (c_r2010_nf%notfound) is null;
         --
         vn_fase := 6.2;
         --
         if pk_csf_reinf.fkg_existe_ref_doc_receita(en_documento_id   => rec.notafiscal_id
                                                  , ev_tipo_documento => 'NF'
                                                  , ev_evento         => 'R2010') then
            --
            vn_fase := 6.3;
            --
            update nota_fiscal nf set
               nf.dm_envio_reinf = 1
            where nf.id = rec.notafiscal_id;
            --
         end if;
         --
      end loop;
      --
      vn_fase := 6.4;
      --
      -- Segundo passo: Checar se alguma nota não foi enviada para o Reinf
      for rec in c_r2010_nf loop
         exit when c_r2010_nf%notfound or (c_r2010_nf%notfound) is null;
         --
         vn_fase := 6.41;
         --
         gv_mensagem := 'Período de geração não pode ser "Fechado", pois não foi gerado o evento R-2010 para a nota fiscal '||rec.nro_nf||
                        ' serie '||rec.serie||' data de emissão '||to_char(rec.dt_emiss, 'dd/mm/yyyy')||' da empresa '||
                        pk_csf.fkg_codpart_empresaid (rec.empresa_id)||'. '||
                        'Neste caso, será necessário gerar os eventos novamente antes de efetuar o fechamento.';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      end loop;
      --
      vn_fase := 6.5;
      --
      -- Primeiro passo: Checar se foi dado manutenção em algum CT-e (volta para dm_envio_reinf = 0) e ele se encontra Processada R-5001
      for rec in c_r2010_cte loop
         exit when c_r2010_cte%notfound or (c_r2010_cte%notfound) is null;
         --
         vn_fase := 6.51;
         --
         if pk_csf_reinf.fkg_existe_ref_doc_receita(en_documento_id   => rec.conhectransp_id
                                                  , ev_tipo_documento => 'CT'
                                                  , ev_evento         => 'R2010') then
            --
            vn_fase := 6.52;
            --
            update conhec_transp ct set
               ct.dm_envio_reinf = 1
            where ct.id = rec.conhectransp_id;
            --
         end if;
         --
      end loop;
      --
      vn_fase := 6.6;
      --
      -- Segundo passo: Checar se alguma nota não foi enviada para o Reinf
      for rec in c_r2010_cte loop
         exit when c_r2010_cte%notfound or (c_r2010_cte%notfound) is null;
         --
         vn_fase := 6.61;
         --
         gv_mensagem := 'Período de geração não pode ser "Fechado", pois não foi gerado o evento R-2010 para o Conhecimento de Transporte '||rec.nro_ct||
                        ' serie '||rec.serie||' data de emissão '||to_char(rec.dt_hr_emissao, 'dd/mm/yyyy')||' da empresa '||
                        pk_csf.fkg_codpart_empresaid (rec.empresa_id)||'. '||
                        'Neste caso, será necessário gerar os eventos novamente antes de efetuar o fechamento.';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      end loop;
      --
      vn_fase := 7;
      --
      -- Primeiro passo: Checar se foi dado manutenção em alguma nota (volta para dm_envio_reinf = 0) e ela se encontra Processada R-5001
      for rec in c_r2020_nf loop
         exit when c_r2020_nf%notfound or (c_r2020_nf%notfound) is null;
         --
         vn_fase := 7.1;
         --
         if pk_csf_reinf.fkg_existe_ref_doc_receita(en_documento_id   => rec.notafiscal_id
                                                  , ev_tipo_documento => 'NF'
                                                  , ev_evento         => 'R2020') then
            --
            vn_fase := 7.2;
            --
            update nota_fiscal nf set
               nf.dm_envio_reinf = 1
            where nf.id = rec.notafiscal_id;
            --
         end if;
         --
      end loop;
      --
      vn_fase := 8;
      --
      -- Segundo passo: Checar se alguma nota não foi enviada para o Reinf
      for rec in c_r2020_nf loop
         exit when c_r2020_nf%notfound or (c_r2020_nf%notfound) is null;
         --
         vn_fase := 8.1;
         --
         gv_mensagem := 'Período de geração não pode ser "Fechado", pois não foi gerado o evento R-2020 para a nota fiscal '||rec.nro_nf||
                        ' serie '||rec.serie||' data de emissão '||to_char(rec.dt_emiss, 'dd/mm/yyyy')||' da empresa '||
                        pk_csf.fkg_codpart_empresaid (rec.empresa_id)||'. '||
                        'Neste caso, será necessário gerar os eventos novamente antes de efetuar o fechamento.';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      end loop;
      --
      vn_fase := 9;
      --
      -- Primeiro passo: Checar se foi dado manutenção em algum CT-e (volta para dm_envio_reinf = 0) e ele se encontra Processada R-5001
      for rec in c_r2020_cte loop
         exit when c_r2020_cte%notfound or (c_r2020_cte%notfound) is null;
         --
         vn_fase := 9.1;
         --
         if pk_csf_reinf.fkg_existe_ref_doc_receita(en_documento_id   => rec.conhectransp_id
                                                  , ev_tipo_documento => 'CT'
                                                  , ev_evento         => 'R2020') then
            --
            vn_fase := 9.2;
            --
            update conhec_transp ct set
               ct.dm_envio_reinf = 1
            where ct.id = rec.conhectransp_id;
            --
         end if;
         --
      end loop;
      --
      vn_fase := 10;
      --
      -- Segundo passo: Checar se alguma nota não foi enviada para o Reinf
      for rec in c_r2020_cte loop
         exit when c_r2020_cte%notfound or (c_r2020_cte%notfound) is null;
         --
         vn_fase := 10.1;
         --
         gv_mensagem := 'Período de geração não pode ser "Fechado", pois não foi gerado o evento R-2020 para o conhecimento de transporte '||rec.nro_ct||
                        ' serie '||rec.serie||' data de emissão '||to_char(rec.dt_hr_emissao, 'dd/mm/yyyy')||' da empresa '||
                        pk_csf.fkg_codpart_empresaid (rec.empresa_id)||'. '||
                        'Neste caso, será necessário gerar os eventos novamente antes de efetuar o fechamento.';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      end loop;
      --
      vn_fase := 11;
      --
      for rec in c_r2030 loop
         exit when c_r2030%notfound or (c_r2030%notfound) is null;
         --
         vn_fase := 11.1;
         --
         gv_mensagem := 'Período de geração não pode ser "Fechado", pois houve inclusão ou alteração no recurso recebido por espetáculo '||
                        'desportivo da empresa '||pk_csf.fkg_codpart_empresaid(rec.empresa_id)||' data de referência '||
                        to_char(rec.dt_ref, 'dd/mm/yyyy')|| ' participante patrocinador '||pk_csf.fkg_pessoa_cod_part(rec.pessoa_id_orig)||
                        ' com a situação "'||pk_csf.fkg_dominio('REC_RECEB_ASS_DESP.DM_ST_PROC', rec.dm_st_proc)||
                        '" e não foi gerado o evento R-2030 para este recurso atualizado. '||
                        'Neste caso, será necessário gerar os eventos novamente antes de efetuar o fechamento.';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      end loop;
      --
      vn_fase := 12;
      --
      for rec in c_r2040 loop
         exit when c_r2040%notfound or (c_r2040%notfound) is null;
         --
         vn_fase := 12.1;
         --
         gv_mensagem := 'Período de geração não pode ser "Fechado", pois houve inclusão ou alteração no recurso repassado por espetáculo '||
                        'desportivo da empresa '||pk_csf.fkg_codpart_empresaid(rec.empresa_id)||' data de referência '||
                        to_char(rec.dt_ref, 'dd/mm/yyyy')|| ' participante patrocinador '||pk_csf.fkg_pessoa_cod_part(rec.pessoa_id_desp)||
                        ' com a situação "'||pk_csf.fkg_dominio('REC_REP_ASS_DESP.DM_ST_PROC', rec.dm_st_proc)||
                        '" e não foi gerado o evento R-2040 para este recurso atualizado. '||
                        'Neste caso, será necessário gerar os eventos novamente antes de efetuar o fechamento.';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      end loop;
      --
      vn_fase := 12;
      --
      for rec in c_r2050 loop
         exit when c_r2050%notfound or (c_r2050%notfound) is null;
         --
         vn_fase := 13.1;
         --
         gv_mensagem := 'Período de geração não pode ser "Fechado", pois houve inclusão ou alteração na comercialização de produção rural '||
                        ' da empresa '||pk_csf.fkg_codpart_empresaid(rec.empresa_id)||' data de referência '||to_char(rec.dt_ref, 'dd/mm/yyyy')||
                        ' com a situação "'||pk_csf.fkg_dominio('COMER_PROD_RURAL_PJ_AGR.DM_ST_PROC', rec.dm_st_proc)||
                        '" e não foi gerado o evento R-2050 para esta comercialização atualizada. '||
                        'Neste caso, será necessário gerar os eventos novamente antes de efetuar o fechamento.';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      end loop;
      --
      vn_fase := 14;
      --
      for rec in c_r2060 loop
         exit when c_r2060%notfound or (c_r2060%notfound) is null;
         --
         vn_fase := 14.1;
         --
         gv_mensagem := 'Período de geração não pode ser "Fechado", pois houve geração da apuração de contribuição previdenciária sobre '||
                        ' a receita bruta da empresa '||pk_csf.fkg_codpart_empresaid(rec.empresa_id)||' data de inicial '||
                        to_char(rec.dt_ini, 'dd/mm/yyyy')||' data de final '||to_char(rec.dt_fin, 'dd/mm/yyyy')||' tipo "'||
                        pk_csf.fkg_dominio('APUR_CPRB_EMPR.DM_TIPO', rec.dm_tipo)||
                        '" com a situação "'||pk_csf.fkg_dominio('APUR_CPRB_EMPR.DM_SITUACAO', rec.dm_situacao)||
                        '" e não foi gerado o evento R-2060 para esta apuração de contribuição previdenciária processada. '||
                        'Neste caso, será necessário gerar os eventos novamente antes de efetuar o fechamento.';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      end loop;
      --
      vn_fase := 15;
      --
      /*
      for rec in c_r2070 loop
         exit when c_r2070%notfound or (c_r2070%notfound) is null;
         --
         vn_fase := 13.1;
         --
         gv_mensagem := 'Período de geração não pode ser "Fechado", pois houve inclusão ou alteração no pagamento de imposto retido '||
                        ' da empresa '||pk_csf.fkg_codpart_empresaid(rec.empresa_id)||' número do documento '||rec.nro_doc||
                        ' data de vencimento '||to_char(rec.dt_vcto, 'dd/mm/yyyy')|| ' data de pagamento '||to_char(rec.dt_vcto, 'dd/mm/yyyy')||
                        ' tipo de imposto '||rec.tipo_imp||' tipo de imposto retido'||rec.tipo_ret_imp||
                        ' com a situação "'||pk_csf.fkg_dominio('COMER_PROD_RURAL_PJ_AGR.DM_ST_PROC', rec.dm_situacao)||
                        '" e não foi gerado o evento R-2070 para esta comercialização atualizada. '||
                        'Neste caso, será necessário gerar os eventos novamente antes de efetuar o fechamento.';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      end loop;
      --
      vn_fase := 12;
      --
      */
   else -- 2-Não periódico
      --
      vn_fase := 16;
      --
      for rec in c_r3010 loop
         exit when c_r3010%notfound or (c_r3010%notfound) is null;
         --
         vn_fase := 16.1;
         --
         gv_mensagem := 'Período de geração não pode ser "Fechado", pois houve inclusão ou alteração na receita de espetáculo desportivo'||
                        'da empresa '||pk_csf.fkg_codpart_empresaid(rec.empresa_id)||' data de referência '||
                        to_char(rec.dt_ref, 'dd/mm/yyyy')||' número do boletim '||rec.nro_boletim||' tipo de competição '||
                        pk_csf.fkg_dominio('REC_ESP_DESPORT.DM_TP_COMPET', rec.dm_tp_compet)||' categoria '||
                        pk_csf.fkg_dominio('REC_ESP_DESPORT.DM_CATEG_EVENTO', rec.dm_categ_evento)||' modalidade '||
                        rec.descr_mod_desportiva||' competição '||rec.nome_compet|| ' praça desportiva '||rec.praca_desport||
                        ' cidade '||pk_csf.fkg_cidade_descr(rec.cidade_id)||' com a situação "'||pk_csf.fkg_dominio('REC_ESP_DESPORT.DM_SITUACAO', rec.dm_situacao)||
                        '" e não foi gerado o evento R-3010 para este recurso atualizado. '||
                        'Neste caso, será necessário gerar os eventos novamente antes de efetuar o fechamento.';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_vld_inf_nao_enviada fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenerico_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_vld_inf_nao_enviada;


---------------------------------------------------------------------------------------------------
-- Procedimento que grava a quantidade de registros gerados por evento
procedure pkb_gerar_resumo_reinf ( en_geracaoefdreinf_id in geracao_efd_reinf.id%type
                                 )
is
   --
   vn_fase                 number;
   vn_loggenericoreinf_id  log_generico_reinf.id%type;
   vv_sql                  varchar2(2000);
   vv_table_evt            varchar2(30);
   vn_qtde_evt             number;
   vn_efdreinfresumo_id    efd_reinf_resumo.id%type;

   --
   cursor c_evento is
   select *
     from evt_efd_reinf
 order by sigla;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_evento loop
      exit when c_evento%notfound or (c_evento%notfound) is null;
      --
      vn_fase := 2;
      --
      vv_sql               := null;
      vv_table_evt         := null;
      vn_qtde_evt          := null;
      vn_efdreinfresumo_id := null;
      --
      vn_fase := 3;
      --
      vv_table_evt := pk_csf_reinf.fkg_recup_tabela_evento (rec.sigla);
      --
      vn_fase := 4;
      --
      if vv_table_evt is not null then
         --
         if rec.sigla = 'R-5011' then
            --
            vn_fase := 5;
            -- Recupera a quantidade de registro gerados por evento R-5011
            vv_sql := 'select count(*)';
            vv_sql := vv_sql ||' from ' ||vv_table_evt;
            vv_sql := vv_sql ||' where efdreinfr2099_id in (select id from efd_reinf_r2099 ef where geracaoefdreinf_id = ' || en_geracaoefdreinf_id ||')';
            --
         else
            --
            vn_fase := 6;
            -- Recupera a quantidade de registro gerados por evento
            vv_sql := 'select count(*)';
            vv_sql := vv_sql ||' from ' ||vv_table_evt;
            vv_sql := vv_sql ||' where geracaoefdreinf_id = ' || en_geracaoefdreinf_id;
            --
         end if;
         --
         vn_fase := 7;
         --
         begin
            --
            execute immediate vv_sql into vn_qtde_evt;
            --
         exception
            when others then
               gv_mensagem := 'Erro ao recuperar a quantidade de registros gerados para o evento "'||rec.sigla||'" ('||vn_fase||'): '||sqlerrm;
               --
            declare
               vn_loggenericoreinf_id  log_generico_reinf.id%type;
            begin
               pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                       , ev_mensagem             => gv_resumo || gv_mensagem
                                                       , ev_resumo               => gv_mensagem
                                                       , en_tipo_log             => ERRO_DE_SISTEMA
                                                       , en_referencia_id        => en_geracaoefdreinf_id
                                                       , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                       , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                       );
            end;
            --
         end;
         --
         vn_fase := 8;
         --
         begin
            --
            select id
              into vn_efdreinfresumo_id
              from efd_reinf_resumo
             where geracaoefdreinf_id = en_geracaoefdreinf_id
               and evtefdreinf_id     = rec.id;
           --
         exception
            when others then
               vn_efdreinfresumo_id := null;
         end;
         --
         vn_fase := 9;
         --
         if nvl(vn_efdreinfresumo_id, 0) = 0 then
            --
            vn_fase := 10;
            --
            insert into efd_reinf_resumo ( id
                                                 , geracaoefdreinf_id
                                                 , evtefdreinf_id
                                                 , qtde )
                                          values ( efdreinfresumo_seq.nextval
                                                 , en_geracaoefdreinf_id
                                                 , rec.id
                                                 , vn_qtde_evt );
            --
         else
            --
            vn_fase := 11;
            --
            update efd_reinf_resumo
               set qtde = vn_qtde_evt
             where id   = vn_efdreinfresumo_id;
            --
         end if;
         --
      end if;
      --
   end loop;
   --
   commit;
   --
exception
   when others then
      --  
      gv_mensagem := 'Erro ao recuperar a quantidade de registros gerados por evento ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericoreinf_id  log_generico_reinf.id%type;
      begin 
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => en_geracaoefdreinf_id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_gerar_resumo_reinf;

---------------------------------------------------------------------------------------------------
-- Procedimento que exclui os eventos com a situação "5-Erro no envio e 6-Erro na montagem do XML"
procedure pkb_exclui_evt_com_erro_envio ( en_geracaoefdreinf_id in geracao_efd_reinf.id%type
                                        , ev_botao              in varchar2
                                        )
is
   --
   vn_fase   number;
   --
   cursor c_r1000 is
   select *
     from efd_reinf_r1000 ef
    where ef.geracaoefdreinf_id = en_geracaoefdreinf_id
      and ef.dm_st_proc in (2,5,6) -- 2-Erro de Validação; 5-Erro no Envio; 6-Erro na montagem do XML
      and ef.nro_recibo is null
 order by ef.id desc;
   --
   cursor c_r1070 is
   select *
     from efd_reinf_r1070 ef
    where ef.geracaoefdreinf_id = en_geracaoefdreinf_id
      and ef.dm_st_proc in (2,5,6) -- 2-Erro de Validação; 5-Erro no Envio; 6-Erro na montagem do XML
      and ef.nro_recibo is null
 order by ef.id desc;
   --
   cursor c_r9000 is
   select *
     from efd_reinf_r9000 ef
    where ef.geracaoefdreinf_id = en_geracaoefdreinf_id
      and ef.dm_st_proc in (2,5,6) -- 2-Erro de Validação; 5-Erro no Envio; 6-Erro na montagem do XML
      and ef.nro_recibo is null
 order by ef.id desc;
   --
   cursor c_r2010 is
   select *
     from efd_reinf_r2010 ef
    where ef.geracaoefdreinf_id = en_geracaoefdreinf_id
      and ef.dm_st_proc in (2,5,6) -- 2-Erro de Validação; 5-Erro no Envio; 6-Erro na montagem do XML
      and ef.nro_recibo is null
      and not exists (select 1
                        from efd_reinf_r5001_r2010 ef2
                       where ef2.efdreinfr2010_id = ef.id)
 order by ef.id desc;
   --
   cursor c_r2020 is
   select *
     from efd_reinf_r2020 ef
    where ef.geracaoefdreinf_id = en_geracaoefdreinf_id
      and ef.dm_st_proc in (2,5,6) -- 2-Erro de Validação; 5-Erro no Envio; 6-Erro na montagem do XML
      and ef.nro_recibo is null
      and not exists (select 1
                        from efd_reinf_r5001_r2020 ef2
                       where ef2.efdreinfr2020_id = ef.id)
 order by ef.id desc;
   --
   cursor c_r2030 is
   select *
     from efd_reinf_r2030 ef
    where ef.geracaoefdreinf_id = en_geracaoefdreinf_id
      and ef.dm_st_proc in (2,5,6) -- 2-Erro de Validação; 5-Erro no Envio; 6-Erro na montagem do XML
      and ef.nro_recibo is null
 order by ef.id desc;
   --
   cursor c_r2040 is
   select *
     from efd_reinf_r2040 ef
    where ef.geracaoefdreinf_id = en_geracaoefdreinf_id
      and ef.dm_st_proc in (2,5,6) -- 2-Erro de Validação; 5-Erro no Envio; 6-Erro na montagem do XML
      and ef.nro_recibo is null
      and not exists (select 1
                        from efd_reinf_r5001_r2040 ef2
                       where ef2.efdreinfr2040_id = ef.id)
 order by ef.id desc;
   --
   cursor c_r2050 is
   select *
     from efd_reinf_r2050 ef
    where ef.geracaoefdreinf_id = en_geracaoefdreinf_id
      and ef.dm_st_proc in (2,5,6) -- 2-Erro de Validação; 5-Erro no Envio; 6-Erro na montagem do XML
      and ef.nro_recibo is null
      and not exists (select 1
                        from efd_reinf_r5001_r2050 ef2
                       where ef2.efdreinfr2050_id = ef.id)
 order by ef.id desc;
   --
   cursor c_r2060 is
   select *
     from efd_reinf_r2060 ef
    where ef.geracaoefdreinf_id = en_geracaoefdreinf_id
      and ef.dm_st_proc in (2,5,6) -- 2-Erro de Validação; 5-Erro no Envio; 6-Erro na montagem do XML
      and ef.nro_recibo is null
      and not exists (select 1
                        from efd_reinf_r5001_r2060 ef2
                       where ef2.efdreinfr2060_id = ef.id)
 order by ef.id desc;
   --
   cursor c_r2070 is
   select *
     from efd_reinf_r2070 ef
    where ef.geracaoefdreinf_id = en_geracaoefdreinf_id
      and ef.dm_st_proc in (2,5,6) -- 2-Erro de Validação; 5-Erro no Envio; 6-Erro na montagem do XML
      and ef.nro_recibo is null
 order by ef.id desc;
   --
   cursor c_r3010 is
   select *
     from efd_reinf_r3010 ef
    where ef.geracaoefdreinf_id = en_geracaoefdreinf_id
      and ef.dm_st_proc in (2,5,6) -- 2-Erro de Validação; 5-Erro no Envio; 6-Erro na montagem do XML
      and ef.nro_recibo is null
      and not exists (select 1
                        from efd_reinf_r5001_r3010 ef2
                       where ef2.efdreinfr3010_id = ef.id)
 order by ef.id desc;
   --
   cursor c_r2098 is
   select *
     from efd_reinf_r2098 ef
    where ef.geracaoefdreinf_id = en_geracaoefdreinf_id
      and ef.dm_st_proc in (2,5,6) -- 2-Erro de Validação; 5-Erro no Envio; 6-Erro na montagem do XML
      and ef.nro_recibo is null
 order by ef.id desc;
   --
   cursor c_r2099 is
   select *
     from efd_reinf_r2099 ef
    where ef.geracaoefdreinf_id = en_geracaoefdreinf_id
      and ef.dm_st_proc in (2,5,6) -- 2-Erro de Validação; 5-Erro no Envio; 6-Erro na montagem do XML
      and ef.nro_recibo is null
 order by ef.id desc;
   --
   cursor c_r5011 (en_efdreinfr2099_id in efd_reinf_r2099.id%type) is
   select *
     from efd_reinf_r5011 ef
    where ef.efdreinfr2099_id = en_efdreinfr2099_id
 order by ef.id desc;
   --
   -- Procedimento que exclui os lotes relacionados a eventos com a situação "5-Erro no envio e 6-Erro na montagem do XML"
   procedure pkb_exclui_lotes_com_erro ( en_geracaoefdreinf_id in geracao_efd_reinf.id%type
                                       , en_loteefdreinf_id    in lote_efd_reinf.id%type
                                       )
   is
   --
   begin
      --
      delete lote_efd_reinf
       where geracaoefdreinf_id = en_geracaoefdreinf_id
         and id                 = en_loteefdreinf_id;
      --
   exception
      when others then
         --
         gv_mensagem := 'Erro ao excluir os lotes relacionados a eventos com a situação "5-Erro no envio e 6-Erro na montagem do XML" ('||vn_fase||'): '||sqlerrm;
         --
         declare
            vn_loggenericoreinf_id  log_generico_reinf.id%type;
         begin
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                    , ev_mensagem             => gv_resumo || gv_mensagem
                                                    , ev_resumo               => gv_mensagem
                                                    , en_tipo_log             => ERRO_DE_SISTEMA
                                                    , en_referencia_id        => en_geracaoefdreinf_id
                                                    , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
         exception
            when others then
               null;
         end;
         --
   end pkb_exclui_lotes_com_erro;
   --
   -- Procedimento que exclui os registros de controle dos eventos com a situação "5-Erro no envio e 6-Erro na montagem do XML"
   procedure pkb_exclui_ctrl_evt_erro ( en_geracaoefdreinf_id in geracao_efd_reinf.id%type
                                      , en_referencia_id      in number
                                      , ev_obj_referencia     in varchar2
                                      )
   is
   --
   begin
      --
      delete ctrl_evt_reinf
       where geracaoefdreinf_id = en_geracaoefdreinf_id
         and obj_referencia     = ev_obj_referencia
         and referencia_id      = en_referencia_id;
      --
   exception
      when others then
         --
         gv_mensagem := 'Erro ao excluir controle dos eventos com a situação "5-Erro no envio e 6-Erro na montagem do XML" ('||vn_fase||'): '||sqlerrm;
         --
         declare
            vn_loggenericoreinf_id  log_generico_reinf.id%type;
         begin
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                    , ev_mensagem             => gv_resumo || gv_mensagem
                                                    , ev_resumo               => gv_mensagem
                                                    , en_tipo_log             => ERRO_DE_SISTEMA
                                                    , en_referencia_id        => en_geracaoefdreinf_id
                                                    , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
         exception
            when others then
               null;
         end;
         --
   end pkb_exclui_ctrl_evt_erro;
   --
begin
   --
   vn_fase := 1;
   --
   if ev_botao = 'GERACAO' then
      --
      -- Recupera os registros do evento R-1000
      for r_r1000 in c_r1000 loop
         exit when c_r1000%notfound or (c_r1000%notfound) is null;
         -- Exclui os registros do evento R-1000
         delete efd_reinf_r1000 ef
          where ef.id = r_r1000.id;
         --
         vn_fase := 2;
         -- Exclui o lote do evento Reinf
         pkb_exclui_lotes_com_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                   , en_loteefdreinf_id    => r_r1000.loteefdreinf_id );
         --
         vn_fase := 3;
         -- Exclui o controle de evento Reinf
         pkb_exclui_ctrl_evt_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                  , en_referencia_id      => r_r1000.id
                                  , ev_obj_referencia     => 'EFD_REINF_R1000' );
        --
      end loop;
      --
      vn_fase := 4;
      -- Recupera os registros do evento R-1070
      for r_r1070 in c_r1070 loop
         exit when c_r1070%notfound or (c_r1070%notfound) is null;
         -- Exclui os registros do evento R-1070
         delete efd_reinf_r1070 ef
          where ef.id = r_r1070.id;
         --
         vn_fase := 5;
         -- Exclui o lote do evento Reinf
         pkb_exclui_lotes_com_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                   , en_loteefdreinf_id    => r_r1070.loteefdreinf_id );
         --
         vn_fase := 6;
         -- Exclui o controle de evento Reinf
         pkb_exclui_ctrl_evt_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                  , en_referencia_id      => r_r1070.id
                                  , ev_obj_referencia     => 'EFD_REINF_R1070' );
         --
      end loop;
      --
      vn_fase := 7;
      -- Recupera os registros do evento R-9000
      for r_r9000 in c_r9000 loop
         exit when c_r9000%notfound or (c_r9000%notfound) is null;
         -- Exclui os registros filhos do evento R-9000/R-2010
         delete r_efdreinf_r9000_r2010 ef
          where ef.efdreinfr9000_id = r_r9000.id;
         --
         vn_fase := 8;
         -- Exclui os registros filhos do evento R-9000/R-2020
         delete r_efdreinf_r9000_r2020 ef
          where ef.efdreinfr9000_id = r_r9000.id;
         --
         vn_fase := 9;
         -- Exclui os registros filhos do evento R-9000/R-2030
         delete r_efdreinf_r9000_r2030 ef
          where ef.efdreinfr9000_id = r_r9000.id;
         --
         vn_fase := 10;
         -- Exclui os registros filhos do evento R-9000/R-2040
         delete r_efdreinf_r9000_r2040 ef
          where ef.efdreinfr9000_id = r_r9000.id;
         --
         vn_fase := 11;
         -- Exclui os registros filhos do evento R-9000/R-2050
         delete r_efdreinf_r9000_r2050 ef
          where ef.efdreinfr9000_id = r_r9000.id;
         --
         vn_fase := 12;
         -- Exclui os registros filhos do evento R-9000/R-2060
         delete r_efdreinf_r9000_r2060 ef
          where ef.efdreinfr9000_id = r_r9000.id;
         --
         vn_fase := 13;
         -- Exclui os registros filhos do evento R-9000/R-2070
         delete r_efdreinf_r9000_r2070 ef
          where ef.efdreinfr9000_id = r_r9000.id;
         --
         vn_fase := 14;
         -- Exclui os registros filhos do evento R-9000/R-3010
         delete r_efdreinf_r9000_r3010 ef
          where ef.efdreinfr9000_id = r_r9000.id;
         --
         vn_fase := 15;
         -- Exclui os registros do evento R-9000
         delete efd_reinf_r9000 ef
          where ef.id = r_r9000.id;
         --
         vn_fase := 16;
         -- Exclui o lote do evento Reinf
         pkb_exclui_lotes_com_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                   , en_loteefdreinf_id    => r_r9000.loteefdreinf_id );
         --
         vn_fase := 17;
         -- Exclui o controle de evento Reinf
         pkb_exclui_ctrl_evt_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                  , en_referencia_id      => r_r9000.id
                                  , ev_obj_referencia     => 'EFD_REINF_R9000' );
         --
      end loop;
      --
      vn_fase := 18;
      -- Recupera os registros do evento R-2010
      for r_r2010 in c_r2010 loop
         exit when c_r2010%notfound or (c_r2010%notfound) is null;
         --
         vn_fase := 18.1;
         --
         -- Exclui os registros filhos do evento R-2010
         delete efd_reinf_r2010_nf ef
          where ef.efdreinfr2010_id = r_r2010.id;
         --
         vn_fase := 18.2;
         --
         delete efd_reinf_r2010_cte ef
          where ef.efdreinfr2010_id = r_r2010.id;
         --
         vn_fase := 19;
         -- Exclui os registros do evento R-2010
         delete efd_reinf_r2010 ef
          where ef.id = r_r2010.id;
         --
         vn_fase := 20;
         -- Exclui o lote do evento Reinf
         pkb_exclui_lotes_com_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                   , en_loteefdreinf_id    => r_r2010.loteefdreinf_id );
         --
         vn_fase := 21;
         -- Exclui o controle de evento Reinf
         pkb_exclui_ctrl_evt_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                  , en_referencia_id      => r_r2010.id
                                  , ev_obj_referencia     => 'EFD_REINF_R2010' );
         --
       end loop;
      --
      vn_fase := 22;
      -- Recupera os registros do evento R-2020
      for r_r2020 in c_r2020 loop
         exit when c_r2020%notfound or (c_r2020%notfound) is null;
         --
         vn_fase := 22.1;
         --
         -- Exclui os registros filhos do evento R-2020
         delete efd_reinf_r2020_nf ef
          where ef.efdreinfr2020_id = r_r2020.id;
         --
         vn_fase := 22.2;
         --
         delete efd_reinf_r2020_cte ef
          where ef.efdreinfr2020_id = r_r2020.id;
         --
         vn_fase := 23;
         -- Exclui os registros do evento R-2020
         delete efd_reinf_r2020 ef
          where ef.id = r_r2020.id;
         --
         vn_fase := 24;
         -- Exclui o lote do evento Reinf
         pkb_exclui_lotes_com_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                   , en_loteefdreinf_id    => r_r2020.loteefdreinf_id );
         --
         vn_fase := 25;
         -- Exclui o controle de evento Reinf
         pkb_exclui_ctrl_evt_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                  , en_referencia_id      => r_r2020.id
                                  , ev_obj_referencia     => 'EFD_REINF_R2020' );
         --
      end loop;
      --
      vn_fase := 26;
      -- Recupera os registros do evento R-2030
      for r_r2030 in c_r2030 loop
         exit when c_r2030%notfound or (c_r2030%notfound) is null;
         -- Exclui os registros filhos do evento R-2030
         delete r_efdreinfr2030_recreceb ef
          where ef.efdreinfr2030_id = r_r2030.id;
         --
         vn_fase := 27;
         -- Exclui os registros do evento R-2030
         delete efd_reinf_r2030 ef
          where ef.id = r_r2030.id;
         --
         vn_fase := 28;
         -- Exclui o lote do evento Reinf
         pkb_exclui_lotes_com_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                   , en_loteefdreinf_id    => r_r2030.loteefdreinf_id );
         --
         vn_fase := 29;
         -- Exclui o controle de evento Reinf
         pkb_exclui_ctrl_evt_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                  , en_referencia_id      => r_r2030.id
                                  , ev_obj_referencia     => 'EFD_REINF_R2030' );
         --
      end loop;
      --
      vn_fase := 30;
      -- Recupera os registros do evento R-2040
      for r_r2040 in c_r2040 loop
         exit when c_r2040%notfound or (c_r2040%notfound) is null;
         -- Exclui os registros filhos do evento R-2040
         delete r_efdreinfr2040_recrep ef
          where ef.efdreinfr2040_id = r_r2040.id;
         --
         vn_fase := 31;
         -- Exclui os registros do evento R-2040
         delete efd_reinf_r2040 ef
          where ef.id = r_r2040.id;
         --
         vn_fase := 32;
         -- Exclui o lote do evento Reinf
         pkb_exclui_lotes_com_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                   , en_loteefdreinf_id    => r_r2040.loteefdreinf_id );
         --
         vn_fase := 33;
         -- Exclui o controle de evento Reinf
         pkb_exclui_ctrl_evt_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                  , en_referencia_id      => r_r2040.id
                                  , ev_obj_referencia     => 'EFD_REINF_R2040' );
         --
      end loop;
      --
      vn_fase := 34;
      -- Recupera os registros do evento R-2050
      for r_r2050 in c_r2050 loop
         exit when c_r2050%notfound or (c_r2050%notfound) is null;
         -- Exclui os registros do evento R-2050
         delete efd_reinf_r2050 ef
          where ef.id = r_r2050.id;
         --
         vn_fase := 35;
         -- Exclui o lote do evento Reinf
         pkb_exclui_lotes_com_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                   , en_loteefdreinf_id    => r_r2050.loteefdreinf_id );
         --
         vn_fase := 36;
         -- Exclui o controle de evento Reinf
         pkb_exclui_ctrl_evt_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                  , en_referencia_id      => r_r2050.id
                                  , ev_obj_referencia     => 'EFD_REINF_R2050' );
         --
      end loop;
      --
      vn_fase := 37;
      -- Recupera os registros do evento R-2060
      for r_r2060 in c_r2060 loop
         exit when c_r2060%notfound or (c_r2060%notfound) is null;
         -- Exclui os registros do evento R-2060
         delete efd_reinf_r2060 ef
          where ef.id = r_r2060.id;
         --
         vn_fase := 38;
         -- Exclui o lote do evento Reinf
         pkb_exclui_lotes_com_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                   , en_loteefdreinf_id    => r_r2060.loteefdreinf_id );
         --
         vn_fase := 39;
         -- Exclui o controle de evento Reinf
         pkb_exclui_ctrl_evt_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                  , en_referencia_id      => r_r2060.id
                                  , ev_obj_referencia     => 'EFD_REINF_R2060' );
         --
      end loop;
      --
      vn_fase := 40;
      -- Recupera os registros do evento R-2070
      for r_r2070 in c_r2070 loop
         exit when c_r2070%notfound or (c_r2070%notfound) is null;
         -- Exclui os registros filhos do evento R-2070
         delete efd_reinf_r2070_pir ef
          where ef.efdreinfr2070_id = r_r2070.id;
         --
         vn_fase := 41;
         -- Exclui os registros do evento R-2070
         delete efd_reinf_r2070 ef
          where ef.id = r_r2070.id;
         --
         vn_fase := 42;
         -- Exclui o lote do evento Reinf
         pkb_exclui_lotes_com_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                   , en_loteefdreinf_id    => r_r2070.loteefdreinf_id );
         --
         vn_fase := 43;
         -- Exclui o controle de evento Reinf
         pkb_exclui_ctrl_evt_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                  , en_referencia_id      => r_r2070.id
                                  , ev_obj_referencia     => 'EFD_REINF_R2070' );
         --
      end loop;
      --
      vn_fase := 44;
      -- Recupera os registros do evento R-3010
      for r_r3010 in c_r3010 loop
         exit when c_r3010%notfound or (c_r3010%notfound) is null;
         -- Exclui os registros filhos do evento R-3010
         delete efd_reinf_r3010_det ef
          where ef.efdreinfr3010_id = r_r3010.id;
         --
         vn_fase := 45;
         -- Exclui os registros do evento R-3010
         delete efd_reinf_r3010 ef
          where ef.id = r_r3010.id;
         --
         vn_fase := 46;
         -- Exclui o lote do evento Reinf
         pkb_exclui_lotes_com_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                   , en_loteefdreinf_id    => r_r3010.loteefdreinf_id );
         --
         vn_fase := 47;
         -- Exclui o controle de evento Reinf
         pkb_exclui_ctrl_evt_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                  , en_referencia_id      => r_r3010.id
                                  , ev_obj_referencia     => 'EFD_REINF_R3010' );
         --
      end loop;
      --
      vn_fase := 48;
      --
   elsif ev_botao = 'REABERTURA' then
      -- Recupera os registros do evento R-2098
      for r_r2098 in c_r2098 loop
         exit when c_r2098%notfound or (c_r2098%notfound) is null;
         -- Exclui os registros do evento R-2098
         delete efd_reinf_r2098 ef
          where ef.id = r_r2098.id;
         --
         vn_fase := 49;
         -- Exclui o lote do evento Reinf
         pkb_exclui_lotes_com_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                   , en_loteefdreinf_id    => r_r2098.loteefdreinf_id );
         --
         vn_fase := 50;
         -- Exclui o controle de evento Reinf
         pkb_exclui_ctrl_evt_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                  , en_referencia_id      => r_r2098.id
                                  , ev_obj_referencia     => 'EFD_REINF_R2098' );
         --
      end loop;
      --
      vn_fase := 51;
      --
   elsif ev_botao = 'FECHAMENTO' then
      -- Recupera os registros do evento R-2099
      for r_r2099 in c_r2099 loop
         exit when c_r2099%notfound or (c_r2099%notfound) is null;
         -- Recupera os registros do evento R-5011
         for r_r5011 in c_r5011 (en_efdreinfr2099_id => r_r2099.id) loop
         exit when c_r5011%notfound or (c_r5011%notfound) is null;
            -- Exclui os registros de detalhamento do evento R-5011/R-2010
            delete efdreinf_r5011_r2010_det ef
             where ef.efdreinfr5011r2010_id in (select ef2.id
                                                  from efd_reinf_r5011_r2010 ef2
                                                 where ef2.efdreinfr5011_id = r_r5011.id);
            --
            vn_fase := 52;
            -- Exclui os registros filhos do evento R-5011/R-2010
            delete efd_reinf_r5011_r2010 ef
             where ef.efdreinfr5011_id = r_r5011.id;
            --
            vn_fase := 53;
            -- Exclui os registros filhos do evento R-5011/R-2020
            delete efd_reinf_r5011_r2020 ef
             where ef.efdreinfr5011_id = r_r5011.id;
            --
            vn_fase := 54;
            -- Exclui os registros filhos do evento R-5011/R-2040
            delete efd_reinf_r5011_r2040 ef
             where ef.efdreinfr5011_id = r_r5011.id;
            --
            vn_fase := 55;
            -- Exclui os registros filhos do evento R-5011/R-2050
            delete efd_reinf_r5011_r2050 ef
             where ef.efdreinfr5011_id = r_r5011.id;
            --
            vn_fase := 56;
            -- Exclui os registros filhos do evento R-5011/R-2060
            delete efd_reinf_r5011_r2060 ef
             where ef.efdreinfr5011_id = r_r5011.id;
            --
            vn_fase := 57;
            --
            delete efd_reinf_r5011 ef
             where ef.id = r_r5011.id;
            --
         end loop;
         --
         vn_fase := 58;
         -- Exclui os registros do evento R-2099
         delete efd_reinf_r2099 ef
          where ef.id = r_r2099.id;
         --
         vn_fase := 59;
         -- Exclui o lote do evento Reinf
         pkb_exclui_lotes_com_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                   , en_loteefdreinf_id    => r_r2099.loteefdreinf_id );
         --
         vn_fase := 60;
         -- Exclui o controle de evento Reinf
         pkb_exclui_ctrl_evt_erro ( en_geracaoefdreinf_id => en_geracaoefdreinf_id
                                  , en_referencia_id      => r_r2099.id
                                  , ev_obj_referencia     => 'EFD_REINF_R2099' );
         --
      end loop;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      rollback;
      --
      gv_mensagem := 'Erro ao excluir os eventos com a situação "5-Erro no envio e 6-Erro na montagem do XML" ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericoreinf_id  log_generico_reinf.id%type;
      begin 
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => en_geracaoefdreinf_id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_exclui_evt_com_erro_envio;

---------------------------------------------------------------------------------------------------
-- Procedimento que cria um novo evento de Reenvio para os eventos com Erro no Envio ou Erro na montagem do XML
procedure pkb_reenviar_evt_r9000( en_efdreinfr9000_id in efd_reinf_r9000.id%type
                                )
is
   --
   vn_fase                      number;
   vn_loggenericoreinf_id       log_generico_reinf.id%type;
   vn_efdreinfr9000_last_id     efd_reinf_r9000.id%type;
   --
   vt_efd_reinf_r9000           efd_reinf_r9000%rowtype;
   vt_log_generico_reinf        dbms_sql.number_table;
   --
   vv_sigla                     evt_efd_reinf.sigla%type;
   vv_table_evt_excl            varchar2(30);
   vv_column_evt_excl           varchar2(30);
   vv_sql                       varchar2(2000);
   vn_refdreinfr9000_id         number;
   vn_id_ref                    number;
   --
begin
   --
   vn_fase := 1;
   --
   vt_efd_reinf_r9000     := null;
   vv_sigla               := null;
   vv_table_evt_excl      := null;
   vv_column_evt_excl     := null;
   vn_id_ref              := null;
   --
   if nvl(en_efdreinfr9000_id,0) > 0 then
      --
      vn_fase := 2;
      --
      begin
         --
         select *
           into vt_efd_reinf_r9000
           from efd_reinf_r9000
          where id = en_efdreinfr9000_id;
         --
      exception
         when others then
            vt_efd_reinf_r9000 := null;
      end;
      --
      vn_fase := 3;
      -- Recupera os dados da Abertura do EFD-REINF
      pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => vt_efd_reinf_r9000.geracaoefdreinf_id );
      --
      delete log_generico_reinf
       where obj_referencia = 'EFD_REINF_R9000'
         and referencia_id  = vt_efd_reinf_r9000.id;
      --
      if nvl(vt_efd_reinf_r9000.id, 0) > 0
         and nvl(vt_efd_reinf_r9000.dm_st_proc,0) in (5,6) then -- 5-Erro no Envio; 6-Erro na montagem do XML
         --
         vn_fase := 4;
         --
         vn_efdreinfr9000_last_id := null;
         -- Verifica se este é o ultimo evento do Grupo do R-9000
         begin
            --
            select id
              into vn_efdreinfr9000_last_id
              from efd_reinf_r9000
             where id in ( select max(id)
                             from efd_reinf_R9000
                            where geracaoefdreinf_id = vt_efd_reinf_r9000.geracaoefdreinf_id
                              and evtefdreinf_id     = vt_efd_reinf_r9000.evtefdreinf_id);
            --
         exception
            when others then
               vn_efdreinfr9000_last_id := null;
         end;
         --
         vn_fase := 5;
         --
         if nvl(vn_efdreinfr9000_last_id,0) = nvl(vt_efd_reinf_r9000.id,0) then
            --
            vn_fase := 6;
            --
            begin
               -- Recupera a sigla do evento excluído que gerou o evento R-9000
               select sigla
                 into vv_sigla
                 from evt_efd_reinf
                where id = vt_efd_reinf_r9000.evtefdreinf_id;
               --
            exception
               when others then
                  vv_sigla := null;
            end;
            --
            vn_fase := 7;
            --
            -- Verificar a qual tipo de evento está sendo excluido
            if trim(vv_sigla) = 'R-2010' then
               --
               vv_table_evt_excl  := 'R_EFDREINF_R9000_R2010';
               vv_column_evt_excl := 'EFDREINFR2010_ID';
               --
               select refdreinfr9000r2010_seq.nextval
                 into vn_refdreinfr9000_id
                 from dual;
               --
            elsif trim(vv_sigla) = 'R-2020' then
               --
               vv_table_evt_excl := 'R_EFDREINF_R9000_R2020';
               vv_column_evt_excl := 'EFDREINFR2020_ID';
               --
               select refdreinfr9000r2020_seq.nextval
                 into vn_refdreinfr9000_id
                 from dual;
               --
            elsif trim(vv_sigla) = 'R-2030' then
               --
               vv_table_evt_excl := 'R_EFDREINF_R9000_R2030';
               vv_column_evt_excl := 'EFDREINFR2030_ID';
               --
               select refdreinfr9000r2030_seq.nextval
                 into vn_refdreinfr9000_id
                 from dual;
               --
            elsif trim(vv_sigla) = 'R-2040' then
               --
               vv_table_evt_excl := 'R_EFDREINF_R9000_R2040';
               vv_column_evt_excl := 'EFDREINFR2040_ID';
               --
               select refdreinfr9000r2040_seq.nextval
                 into vn_refdreinfr9000_id
                 from dual;
               --
            elsif trim(vv_sigla) = 'R-2050' then
               --
               vv_table_evt_excl := 'R_EFDREINF_R9000_R2050';
               vv_column_evt_excl := 'EFDREINFR2050_ID';
               --
               select refdreinfr9000r2050_seq.nextval
                 into vn_refdreinfr9000_id
                 from dual;
               --
            elsif trim(vv_sigla) = 'R-2060' then
               --
               vv_table_evt_excl := 'R_EFDREINF_R9000_R2060';
               vv_column_evt_excl := 'EFDREINFR2060_ID';
               --
               select refdreinfr9000r2060_seq.nextval
                 into vn_refdreinfr9000_id
                 from dual;
               --
            elsif trim(vv_sigla) = 'R-2070' then
               --
               vv_table_evt_excl := 'R_EFDREINF_R9000_R2070';
               vv_column_evt_excl := 'EFDREINFR2070_ID';
               --
               select refdreinfr9000r2070_seq.nextval
                 into vn_refdreinfr9000_id
                 from dual;
               --
            elsif trim(vv_sigla) = 'R-3010' then
               --
               vv_table_evt_excl := 'R_EFDREINF_R9000_R3010';
               vv_column_evt_excl := 'EFDREINFR3010_ID';
               --
               select refdreinfr9000r3010_seq.nextval
                 into vn_refdreinfr9000_id
                 from dual;
               --
            end if;
            --
            vn_fase := 8;
            --
            vv_sql := null;
            -- Recupera o ID do evento excluído que gerou o evento R-9000
            vv_sql := 'select '|| vv_column_evt_excl;
            vv_sql := vv_sql ||' from ' ||vv_table_evt_excl;
            vv_sql := vv_sql ||' where efdreinfr9000_id = ' || vt_efd_reinf_r9000.id;
            --
            vn_fase := 9;
            --
            begin
               --
               execute immediate vv_sql into vn_id_ref;
               --
            exception
                when others then
                   gv_mensagem := 'Erro ao consultar detalhamento do evento R-9000 ('||vn_fase||'): '||sqlerrm;
                   --
                   declare
                      vn_loggenerico_id  log_generico.id%type;
                   begin
                       pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                               , ev_mensagem             => gv_resumo || gv_mensagem
                                                               , ev_resumo               => gv_mensagem
                                                               , en_tipo_log             => ERRO_DE_SISTEMA
                                                               , en_referencia_id        => vt_efd_reinf_r9000.id
                                                               , ev_obj_referencia       => 'EFD_REINF_R9000'
                                                               , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                               );
                   end;
                   --
            end;
            --
            vn_fase := 10;
            --
            gt_row_efd_reinf_r9000 := vt_efd_reinf_r9000;
            --
            gt_row_efd_reinf_r9000.dm_st_proc      := 0;  -- 0-Aberto
            gt_row_efd_reinf_r9000.loteefdreinf_id := null;
            --
            vn_fase := 11;
            --
            pk_csf_api_reinf.pkb_integr_efd_reinf_r9000 ( est_log_generico_reinf   => vt_log_generico_reinf
                                                        , est_row_efd_reinf_r9000  => gt_row_efd_reinf_r9000
                                                        , en_empresa_id            => gt_row_geracao_efd_reinf.empresa_id
                                                        );
            --
            vn_fase := 12;
            --
            if nvl(vt_log_generico_reinf.count,0) > 0 then
               --
               update efd_reinf_r9000
                  set dm_st_proc = 2 -- Erro de validação
                where id = gt_row_efd_reinf_r9000.id;
               --
            else
               --
               update efd_reinf_r9000
                  set dm_st_proc = 1 -- Validado
               where id = gt_row_efd_reinf_r9000.id;
               --
            end if;
            --
            vn_fase := 13;
            --
            vv_sql := null;
            --
            if nvl(gt_row_efd_reinf_r9000.id,0) > 0
               and nvl(pk_csf_reinf.fkg_verif_exist_det_r9000 ( vv_table_evt_excl, gt_row_efd_reinf_r9000.id, vn_id_ref, vv_column_evt_excl),0) = 0  then
               --
               vn_fase := 14;
               --
               -- Insere o registro na tabela de relacionamento do evento excluído com o evento R-9000
               vv_sql := 'insert into '||vv_table_evt_excl;
               vv_sql := vv_sql || ' values (' || vn_refdreinfr9000_id ||', '|| gt_row_efd_reinf_r9000.id||', '|| vn_id_ref || ')';
               --
               vn_fase := 15;
               --
               begin
                  --
                  execute immediate vv_sql;
                  --
               exception
                  when others then
                     gv_mensagem := 'Erro ao incluir detalhamento do evento R-9000 ('||vn_fase||'): '||sqlerrm;
                     --
                  declare
                     vn_loggenerico_id  log_generico.id%type;
                     begin
                        pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                                , ev_mensagem             => gv_resumo || gv_mensagem
                                                                , ev_resumo               => gv_mensagem
                                                                , en_tipo_log             => ERRO_DE_SISTEMA
                                                                , en_referencia_id        => vt_efd_reinf_r9000.id
                                                                , ev_obj_referencia       => 'EFD_REINF_R9000'
                                                                , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                                );
                     end;
                     --
               end;
               --
            end if;
            --
         else
            --
            pk_csf_api_reinf.gv_mensagem_log := 'Está sendo reenviado um evento R-9000 ( efdreinfr9000_id = '|| vt_efd_reinf_r9000.id ||') antigo, já existe um novo evento criado para o grupo, Favor Verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                    , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                    , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                    , en_tipo_log             => INFORMACAO
                                                    , en_referencia_id        => vt_efd_reinf_r9000.id
                                                    , ev_obj_referencia       => 'EFD_REINF_R9000'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
         end if;
         --
      else
         --
         pk_csf_api_reinf.gv_mensagem_log := 'Situação "'|| pk_csf.fkg_dominio ( 'EFD_REINF_R9000.DM_ST_PROC', vt_efd_reinf_r9000.dm_st_proc ) ||'" do Evento R-9000 (EFDREINFR9000_ID = '||vt_efd_reinf_r9000.id||') não é permitido a geração do Evento de Reenvio';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => vt_efd_reinf_r9000.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R9000'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
      end if;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_reenviar_evt_r9000 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => vt_efd_reinf_r9000.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R9000'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_reenviar_evt_r9000;

---------------------------------------------------------------------------------------------------
-- Procedimento que gera o evento R-9000 de Exclusão para Eventos Periódicos e Não Periódicos
procedure pkb_gera_evt_r9000 ( ev_obj_referencia in varchar2
                             , en_referencia_id  in number
                             )
is
   --
   vn_fase                    number;
   vn_refdreinfr9000_id       number;
   vn_loggenericoreinf_id     log_generico_reinf.id%type;
   vv_sql                     varchar2(2000);
   --
   vn_geracaoefdreinf_id      geracao_efd_reinf.id%type;
   vn_dm_st_proc              efd_reinf_r1000.id%type;
   vn_loggenerico_id          log_generico.id%type;
   vv_table_evt_excl          varchar2(30);
   --
   vt_log_generico_reinf      dbms_sql.number_table;
   vv_column_evt_excl         varchar2(30);
   vn_exist_evt_r9000         number;
   --
begin
   --
   vn_fase := 1;
   --
   if trim(ev_obj_referencia) is not null
    and nvl(en_referencia_id,0) > 0 then
      --
      vv_sql :=           ' select dm_st_proc, geracaoefdreinf_id';
      vv_sql := vv_sql || '   from '||ev_obj_referencia;
      vv_sql := vv_sql || '  where id = '||en_referencia_id;
      --
      vn_fase := 2;
      --
      gv_mensagem := null;
      --
      begin
         --
         execute immediate vv_sql into vn_dm_st_proc, vn_geracaoefdreinf_id;
         --
      exception
       when no_data_found then
          --
          gv_mensagem := 'Registro de evento não encontrado '||ev_obj_referencia||' Id: '||en_referencia_id ||', favor verificar.';
       when others then
         -- não registra erro casa a view não exista
         gv_mensagem := 'Problemas para executar consulta do evento '||ev_obj_referencia||' Id: '||en_referencia_id ||' Erro: '|| sqlerrm;
      end;
      --
      if trim(gv_mensagem) is not null then
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id        => vn_loggenericoreinf_id
                                                 , ev_mensagem                   => gv_mensagem
                                                 , ev_resumo                     => gv_mensagem
                                                 , en_tipo_log                   => INFORMACAO
                                                 , en_referencia_id              => gn_referencia_id
                                                 , ev_obj_referencia             => gv_obj_referencia
                                                 , en_empresa_id                 => null
                                                 );
         --
      end if;
      --
      vn_fase := 4;
      -- Recupera os dados da Abertura do EFD-REINF
      pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => vn_geracaoefdreinf_id );
      --
      vn_fase := 3;
      --
      -- Caso o Evento ja Foi realmente processado deve ser Criado o Evento R-9000
      if nvl(vn_geracaoefdreinf_id,0) > 0
       and nvl(vn_dm_st_proc,0) in (4,8) then  -- 4-Processado; 8-Processado R-5001
         --
         vn_fase := 5;
         --
         gv_resumo := 'Processo de exclusão do evento '|| ev_obj_referencia ||' do periodo ' || to_char(gt_row_geracao_efd_reinf.dt_ini,'mm/yyyy') ||' da empresa '||
                      pk_csf.fkg_cod_nome_empresa_id ( gt_row_geracao_efd_reinf.empresa_id ) ||
                      ' e ambiente de '|| pk_csf.fkg_dominio('GERACAO_EFD_REINF.DM_TP_AMB', nvl(gt_row_geracao_efd_reinf.dm_tp_amb,0));
         --
         gn_referencia_id  := en_referencia_id;
         gv_obj_referencia := ev_obj_referencia;
         --
         begin
            --
            delete  log_generico_reinf lg
             where lg.referencia_id  = gn_referencia_id
               and lg.obj_referencia = gv_obj_referencia;
            --
         exception
            when others then
               raise_application_error(-20101, 'Erro ao excluir log/inconsistência - pk_gera_dados_reinf.pkb_gera_evt_r9000: '||sqlerrm);
         end;
         --
         if nvl(gt_row_geracao_efd_reinf.dm_situacao,0) = 2 then -- Aberto
            --
            vn_fase := 4;
            --
            vn_refdreinfr9000_id := null;
            vv_table_evt_excl   := null;
            -- Verificar a qual tipo de evento está sendo excluido
            if trim(ev_obj_referencia) = 'EFD_REINF_R2010' then
               --
               vv_table_evt_excl  := 'R_EFDREINF_R9000_R2010';
               vv_column_evt_excl := 'EFDREINFR2010_ID';
               --
               select refdreinfr9000r2010_seq.nextval
                 into vn_refdreinfr9000_id
                 from dual;
               --
            elsif trim(ev_obj_referencia) = 'EFD_REINF_R2020' then
               --
               vv_table_evt_excl := 'R_EFDREINF_R9000_R2020';
               vv_column_evt_excl := 'EFDREINFR2020_ID';
               --
               select refdreinfr9000r2020_seq.nextval
                 into vn_refdreinfr9000_id
                 from dual;
               --
            elsif trim(ev_obj_referencia) = 'EFD_REINF_R2030' then
               --
               vv_table_evt_excl := 'R_EFDREINF_R9000_R2030';
               vv_column_evt_excl := 'EFDREINFR2030_ID';
               --
               select refdreinfr9000r2030_seq.nextval
                 into vn_refdreinfr9000_id
                 from dual;
               --
            elsif trim(ev_obj_referencia) = 'EFD_REINF_R2040' then
               --
               vv_table_evt_excl := 'R_EFDREINF_R9000_R2040';
               vv_column_evt_excl := 'EFDREINFR2040_ID';
               --
               select refdreinfr9000r2040_seq.nextval
                 into vn_refdreinfr9000_id
                 from dual;
               --
            elsif trim(ev_obj_referencia) = 'EFD_REINF_R2050' then
               --
               vv_table_evt_excl := 'R_EFDREINF_R9000_R2050';
               vv_column_evt_excl := 'EFDREINFR2050_ID';
               --
               select refdreinfr9000r2050_seq.nextval
                 into vn_refdreinfr9000_id
                 from dual;
               --
            elsif trim(ev_obj_referencia) = 'EFD_REINF_R2060' then
               --
               vv_table_evt_excl := 'R_EFDREINF_R9000_R2060';
               vv_column_evt_excl := 'EFDREINFR2060_ID';
               --
               select refdreinfr9000r2060_seq.nextval
                 into vn_refdreinfr9000_id
                 from dual;
               --
            elsif trim(ev_obj_referencia) = 'EFD_REINF_R2070' then
               --
               vv_table_evt_excl := 'R_EFDREINF_R9000_R2070';
               vv_column_evt_excl := 'EFDREINFR2070_ID';
               --
               select refdreinfr9000r2070_seq.nextval
                 into vn_refdreinfr9000_id
                 from dual;
               --
            elsif trim(ev_obj_referencia) = 'EFD_REINF_R3010' then
               --
               vv_table_evt_excl := 'R_EFDREINF_R9000_R3010';
               vv_column_evt_excl := 'EFDREINFR3010_ID';
               --
               select refdreinfr9000r3010_seq.nextval
                 into vn_refdreinfr9000_id
                 from dual;
               --
            else
               --
               vn_fase := 8;
               --
               pk_csf_api_reinf.gv_mensagem_log := 'Evento não pode ser excluido via processo de exclusão de eventos periódicos e não periódicos (Tabela do evento: '||
                                                   ev_obj_referencia||', Id: '||en_referencia_id ||'), favor verificar.';
               --
               pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                       , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                       , ev_resumo               => gv_resumo
                                                       , en_tipo_log             => INFORMACAO
                                                       , en_referencia_id        => gn_referencia_id
                                                       , ev_obj_referencia       => gv_obj_referencia
                                                       , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                       );
               --
               goto sair_proc;
               --
            end if;
            --
            vn_fase := 9;
            --
            -- Verificar se este Evento ja foi Excluido
            vv_sql :=           'select count(1)  ';
            vv_sql := vv_sql || '  from efd_reinf_r9000  er';
            vv_sql := vv_sql || ', '|| vv_table_evt_excl ||' re';
            vv_sql := vv_sql || ' where er.id = re.efdreinfr9000_id';
            vv_sql := vv_sql || ' and re.'|| vv_column_evt_excl ||' = '||en_referencia_id;
            vv_sql := vv_sql || ' and er.dm_st_proc       = 4';
            --
            begin
               --
               execute immediate vv_sql into vn_exist_evt_r9000;
               --
            exception
             when no_data_found then
               vn_exist_evt_r9000 := null;
            end;
            --
            vn_fase := 10;
            --
            if nvl(vn_exist_evt_r9000,0) > 0 then
               --
               pk_csf_api_reinf.gv_mensagem_log := 'Já existe o evento de exclusão (R-9000) para o evento que está sendo solicitado (Tabela de evento: '|| ev_obj_referencia ||', Id: '|| en_referencia_id ||')';
               --
               pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                       , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                       , ev_resumo               => gv_resumo
                                                       , en_tipo_log             => INFORMACAO
                                                       , en_referencia_id        => en_referencia_id
                                                       , ev_obj_referencia       => ev_obj_referencia
                                                       , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                       );
               --
               goto sair_proc;
               --
            end if;
            --
            gt_row_efd_reinf_r9000 := null;
            --
            gt_row_efd_reinf_r9000.id                 := null;
            gt_row_efd_reinf_r9000.geracaoefdreinf_id := gt_row_geracao_efd_reinf.id;
            gt_row_efd_reinf_r9000.dt_hr_excl         := sysdate;
            gt_row_efd_reinf_r9000.dm_st_proc         := 0;
            --
            gt_row_efd_reinf_r9000.evtefdreinf_id := pk_csf_reinf.fkg_evtefdreinf_id_table ( ev_obj_referencia => ev_obj_referencia);
            --
            pk_csf_api_reinf.pkb_integr_efd_reinf_r9000 ( est_log_generico_reinf  => vt_log_generico_reinf
                                                        , est_row_efd_reinf_r9000 => gt_row_efd_reinf_r9000
                                                        , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                      --, ev_obj_referencia       => ev_obj_referencia
                                                      --, en_referencia_id        => en_referencia_id
                                                        );
            --
            -- ATUALIZAÇÃO DOS SITUACAO DO EVENTO
            if nvl(vt_log_generico_reinf.count,0) > 0 then
               --
               update efd_reinf_r9000
                  set dm_st_proc = 2 -- Erro de validação
                where id = gt_row_efd_reinf_r9000.id;
               --
            else
               --
               update efd_reinf_r9000
                  set dm_st_proc = 1 -- Validado
               where id = gt_row_efd_reinf_r9000.id;
               --
            end if;
            --
            vv_sql := null;
            --
            if nvl(gt_row_efd_reinf_r9000.id,0) > 0
             and nvl(pk_csf_reinf.fkg_verif_exist_det_r9000 ( vv_table_evt_excl, gt_row_efd_reinf_r9000.id, en_referencia_id, vv_column_evt_excl),0) = 0  then
               --
               vv_sql := 'insert into '||vv_table_evt_excl;
               vv_sql := vv_sql || ' values (' || vn_refdreinfr9000_id ||', '|| gt_row_efd_reinf_r9000.id||', '|| en_referencia_id || ')';
               --
               begin
                  --
                  execute immediate vv_sql;
                  --
               exception
                when others then
                  gv_mensagem := 'Erro ao incluir detalhamento do evento R-9000 ('||vn_fase||'): '||sqlerrm;
                  --
                  declare
                     vn_loggenerico_id  log_generico.id%type;
                  begin
                     pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                             , ev_mensagem             => gv_resumo || gv_mensagem
                                                             , ev_resumo               => gv_mensagem
                                                             , en_tipo_log             => ERRO_DE_SISTEMA
                                                             , en_referencia_id        => en_referencia_id
                                                             , ev_obj_referencia       => ev_obj_referencia
                                                             , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                             );
                  end;
                  --
               end;
               --
               pkb_gera_id_evt_reinf ( ev_obj_referencia => 'EFD_REINF_R9000'
                                     , en_referencia_id  => gt_row_efd_reinf_r9000.id
                                     );
               --
            end if;
            --
         else
            --
            -- Situação da Geração está fechada
            vn_fase := 8;
            --
            pk_csf_api_reinf.gv_mensagem_log := 'Dominio da situação que é igual a "'|| pk_csf.fkg_dominio ('GERACAO_EFD_REINF.DM_SITUACAO',  gt_row_geracao_efd_reinf.dm_situacao) ||
                                                '" da Geração que está sendo solicitado a exclusão, deveria ser igual "Aberto", favor verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                    , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                    , ev_resumo               => gv_resumo
                                                    , en_tipo_log             => INFORMACAO
                                                    , en_referencia_id        => en_referencia_id
                                                    , ev_obj_referencia       => ev_obj_referencia
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
         end if;
         --
      else
         --
         vn_fase := 8;
         --
         -- Foi encontrado o evento porem a situação do evento não permite que seja gerado efd_reinf_r9000
         if nvl(vn_dm_st_proc,-1) >= 0 then
            --
            pk_csf_api_reinf.gv_mensagem_log := 'O evento não poderá ser excluído pois a situação do evento é diferente de "Processado ou Processado R-5001", favor verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                    , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                    , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                    , en_tipo_log             => INFORMACAO
                                                    , en_referencia_id        => en_referencia_id 
                                                    , ev_obj_referencia       => ev_obj_referencia
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
         end if;
         --
      end if;
      --
   end if;
   --
   <<sair_proc>>
   --
   null;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem := vv_sql || 'Erro na pk_gera_dados_reinf.pkb_gera_evt_r9000 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => en_referencia_id                   
                                                 , ev_obj_referencia       => ev_obj_referencia
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_gera_evt_r9000;

---------------------------------------------------------------------------------------------------
-- Procedimento que cria um novo evento de Reenvio para os eventos com Erro no Envio ou Erro na montagem do XML
procedure pkb_reenviar_evt_r2099 ( en_efdreinfr2099_id in efd_reinf_r2099.id%type
                                 )
is
   --
   vn_fase                      number;
   vn_loggenericoreinf_id       log_generico_reinf.id%type;
   vn_efdreinfr2099_last_id     efd_reinf_r2099.id%type;
   --
   vt_efd_reinf_r2099           efd_reinf_r2099%rowtype;
   vt_log_generico_reinf        dbms_sql.number_table;
   --
begin
   --
   vn_fase := 1;
   --
   vt_efd_reinf_r2099     := null;
   vn_loggenericoreinf_id := null;
   --
   if nvl(en_efdreinfr2099_id,0) > 0 then
      --
      vn_fase := 2;
      --
      begin
         --
         select *
           into vt_efd_reinf_r2099
           from efd_reinf_r2099
          where id = en_efdreinfr2099_id;
         --
      exception
       when others then
         vt_efd_reinf_r2099 := null;
      end;
      --
      vn_fase := 3;
      -- Recupera os dados da Abertura do EFD-REINF
      pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => vt_efd_reinf_r2099.geracaoefdreinf_id );
      --
      delete log_generico_reinf
       where obj_referencia = 'EFD_REINF_R2099'
         and referencia_id  = gt_row_geracao_efd_reinf.id;
      --
      vn_fase := 4;
      --
      if nvl(vt_efd_reinf_r2099.id, 0) > 0
         and vt_efd_reinf_r2099.dm_st_proc in (5,6) then -- 5-Erro no Envio; 6-Erro na montagem do XML
         --
         vn_fase := 5;
         --
         vn_efdreinfr2099_last_id := null;
         -- Verificar se este é o ultimo evento do Grupo do R-2099
         begin
            --
            select id
              into vn_efdreinfr2099_last_id
              from efd_reinf_r2099
             where id in ( select max(id)
                             from efd_reinf_r2099
                            where geracaoefdreinf_id = vt_efd_reinf_r2099.geracaoefdreinf_id );
            --
         exception
          when others then
             vn_efdreinfr2099_last_id := null;
         end;
         --
         vn_fase := 6;
         --
         if nvl(vn_efdreinfr2099_last_id,0) = nvl(vt_efd_reinf_r2099.id,0) then
            --
            vn_fase := 7;
            --
            gt_row_efd_reinf_r2099 := vt_efd_reinf_r2099;
            --
            gt_row_efd_reinf_r2099.dm_st_proc      := 0;  -- 0-Aberto
            gt_row_efd_reinf_r2099.loteefdreinf_id := null;
            --
            vn_fase := 8;
            --
            pk_csf_api_reinf.pkb_integr_efd_reinf_r2099 ( est_log_generico_reinf  => vt_log_generico_reinf
                                                        , est_row_efd_reinf_r2099 => gt_row_efd_reinf_r2099
                                                        , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                        );
            --
            vn_fase := 9;
            -- 
            if nvl(vt_log_generico_reinf.count,0) > 0 then
               --
               update efd_reinf_r2099
                  set dm_st_proc = 2  -- Erro de Validação
                where id = gt_row_efd_reinf_r2099.id;
               --
            else
               --
               update efd_reinf_r2099
                  set dm_st_proc = 1  -- Validado
                where id = gt_row_efd_reinf_r2099.id;
               --
            end if;
            --
         else
            --
            pk_csf_api_reinf.gv_mensagem_log := 'Está sendo reenviado um evento R-2099 ( efdreinfr2099_id = '|| vt_efd_reinf_r2099.id ||') antigo, já existe um novo evento criado para o grupo, favor verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                    , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                    , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                    , en_tipo_log             => INFORMACAO
                                                    , en_referencia_id        => vt_efd_reinf_r2099.id
                                                    , ev_obj_referencia       => 'EFD_REINF_R2099'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
         end if;
         --
      else
         --
         pk_csf_api_reinf.gv_mensagem_log := 'Situação "'|| pk_csf.fkg_dominio ( 'EFD_REINF_R2099.DM_ST_PROC', vt_efd_reinf_r2099.dm_st_proc ) ||'" do evento R-2099 (efdreinfr2099_id = '||vt_efd_reinf_r2099.id||') não é permitido a geração do evento de reenvio';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => vt_efd_reinf_r2099.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2099'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
      end if;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_reenviar_evt_r2099 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => vt_efd_reinf_r2099.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2099'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_reenviar_evt_r2099;

----------------------------------------------------------------------------------------------------
-- Procedimento que gerencia o evento R-2099
procedure pkb_gera_evt_r2099 ( est_log_generico_reinf  in out nocopy dbms_sql.number_table
                             )
is
   --
   vn_fase                    number;
   --
begin
   --
   vn_fase := 1;
   --
   vn_fase := 2;
   --
   gt_row_efd_reinf_r2099.id                 := null;
   gt_row_efd_reinf_r2099.geracaoefdreinf_id := gt_row_geracao_efd_reinf.id;
   gt_row_efd_reinf_r2099.dm_st_proc         := 0;  -- 0-Aberto
   --
   vn_fase := 3;
   --
   pk_csf_api_reinf.pkb_integr_efd_reinf_r2099 ( est_log_generico_reinf  => est_log_generico_reinf
                                               , est_row_efd_reinf_r2099 => gt_row_efd_reinf_r2099
                                               , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                               );
   --
   vn_fase := 4;
   --
   -- Gerar o ID para o evento criado
   pkb_gera_id_evt_reinf ( ev_obj_referencia => 'EFD_REINF_R2099'
                         , en_referencia_id  => gt_row_efd_reinf_r2099.id
                         );
   --
   vn_fase := 5;
   --
   if nvl(est_log_generico_reinf.count,0) > 0 then
      --
      update efd_reinf_r2099
         set dm_st_proc = 2 -- Erro de validacao
       where id         = gt_row_efd_reinf_r2099.id;
      --
   else
      --
      update efd_reinf_r2099
         set dm_st_proc = 1 -- Validado
       where id         = gt_row_efd_reinf_r2099.id;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_gera_evt_r2099 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenerico_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_gera_evt_r2099;

---------------------------------------------------------------------------------------------------
-- Procedimento que cria um novo evento de Reenvio para os eventos com Erro no Envio ou Erro na montagem do XML
procedure pkb_reenviar_evt_r2098 ( en_efdreinfr2098_id in efd_reinf_r2098.id%type
                                 )
is
   --
   vn_fase                      number;
   vn_loggenericoreinf_id       log_generico_reinf.id%type;
   vn_efdreinfr2098_last_id     efd_reinf_r2098.id%type;
   --
   vt_efd_reinf_r2098           efd_reinf_r2098%rowtype;
   vt_log_generico_reinf        dbms_sql.number_table;
   --
begin
   --
   vn_fase := 1;
   --
   vt_efd_reinf_r2098 := null;
   --
   if nvl(en_efdreinfr2098_id,0) > 0 then
      --
      vn_fase := 2;
      --
      begin
         --
         select *
           into vt_efd_reinf_r2098
           from efd_reinf_r2098
          where id = en_efdreinfr2098_id;
         --
      exception
       when others then
         vt_efd_reinf_r2098 := null;
      end;
      --
      vn_fase := 3;
      -- Recupera os dados da Abertura do EFD-REINF
      pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => vt_efd_reinf_r2098.geracaoefdreinf_id );
      --
      delete log_generico_reinf
       where obj_referencia = 'EFD_REINF_R2098'
         and referencia_id  = gt_row_geracao_efd_reinf.id;
      --
      if nvl(vt_efd_reinf_r2098.id, 0) > 0
         and vt_efd_reinf_r2098.dm_st_proc in (5,6) then -- 5-Erro no Envio; 6-Erro na montagem do XML
         --
         vn_fase := 4;
         --
         vn_efdreinfr2098_last_id := null;
         -- Verificar se este é o ultimo evento do Grupo do R-2098
         begin
            --
            select id
              into vn_efdreinfr2098_last_id
              from efd_reinf_r2098
             where id in ( select max(id)
                             from efd_reinf_r2098
                            where geracaoefdreinf_id = vt_efd_reinf_r2098.geracaoefdreinf_id );
            --
         exception
          when others then
             vn_efdreinfr2098_last_id := null;
         end;
         --
         vn_fase := 5;
         --
         if nvl(vn_efdreinfr2098_last_id,0) = nvl(vt_efd_reinf_r2098.id,0) then
            --
            vn_fase := 6;
            --
            gt_row_efd_reinf_r2098 := vt_efd_reinf_r2098;
            --
            gt_row_efd_reinf_r2098.dm_st_proc      := 0; -- 0-Aberto
            gt_row_efd_reinf_r2098.loteefdreinf_id := null; 
            --
            vn_fase := 7;
            --
            pk_csf_api_reinf.pkb_integr_efd_reinf_r2098 ( est_log_generico_reinf  => vt_log_generico_reinf
                                                        , est_row_efd_reinf_r2098 => gt_row_efd_reinf_r2098
                                                        , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                        );
            --
            vn_fase := 8;
            --
            if nvl(vt_log_generico_reinf.count,0) > 0 then
               --
               update efd_reinf_r2098
                  set dm_st_proc = 2  -- Erro de Validação
                where id = gt_row_efd_reinf_r2098.id;
               --
            else
               --
               update efd_reinf_r2098
                  set dm_st_proc = 1  -- Validado
                where id = gt_row_efd_reinf_r2098.id;
               --
            end if;
            --
         else
            --
            pk_csf_api_reinf.gv_mensagem_log := 'Está sendo reenviado um evento R-2098 ( efdreinfr2098_id = '|| vt_efd_reinf_r2098.id ||') antigo, já existe um novo evento criado para o grupo, Favor Verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                    , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                    , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                    , en_tipo_log             => INFORMACAO
                                                    , en_referencia_id        => vt_efd_reinf_r2098.id
                                                    , ev_obj_referencia       => 'EFD_REINF_R2098'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
         end if;
         --
      else
         --
         pk_csf_api_reinf.gv_mensagem_log := 'Situação "'|| pk_csf.fkg_dominio ( 'EFD_REINF_R2098.DM_ST_PROC', vt_efd_reinf_r2098.dm_st_proc ) ||'" do evento R-2098 (EFDREINFR2098_ID = '||vt_efd_reinf_r2098.id||') não é permitido a geração do evento de reenvio';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => vt_efd_reinf_r2098.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2098'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
      end if;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_reenviar_evt_r2098 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => vt_efd_reinf_r2098.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2098'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_reenviar_evt_r2098;

----------------------------------------------------------------------------------------------------
-- Procedimento que gerencia o evento R-2098
procedure pkb_gera_evt_r2098 ( est_log_generico_reinf  in out nocopy dbms_sql.number_table
                             )
is
   --
   vn_fase                    number;
   vn_loggenericoreinf_id     log_generico_reinf.id%type;
   --
   vn_efdreinfr2099_id        number;
   vn_dm_st_proc              number;
   --
begin
   --
   vn_fase := 1;
   --
   vn_loggenericoreinf_id := null;
   --
   if nvl(gt_row_geracao_efd_reinf.id,0) > 0 then
      --
      vn_fase := 2;
      --
      gv_resumo := 'Reabertura do período ' || to_char(gt_row_geracao_efd_reinf.dt_ini,'mm/yyyy') ||' da empresa '||
                   pk_csf.fkg_cod_nome_empresa_id ( gt_row_geracao_efd_reinf.empresa_id ) ||
                   ' e ambiente de '|| pk_csf.fkg_dominio('GERACAO_EFD_REINF.DM_TP_AMB', nvl(gt_row_geracao_efd_reinf.dm_tp_amb,0));
      --
      gn_referencia_id := gt_row_geracao_efd_reinf.id;
      gv_obj_referencia := 'GERACAO_EFD_REINF';
      --
      vn_fase := 3;
      --
      begin
         --
         delete  log_generico_reinf lg
          where lg.referencia_id  = gn_referencia_id
            and lg.obj_referencia = gv_obj_referencia;
         --
      exception
         when others then
            raise_application_error(-20101, 'Erro ao excluir log/inconsistência - pk_gera_dados_reinf.pkb_gera_evt_r2098: '||sqlerrm);
      end;
      --
      vn_fase := 4;
      --
      if nvl(gt_row_geracao_efd_reinf.dm_situacao,0) = 4 then
         --
         vn_fase := 5;
         --
         vn_efdreinfr2099_id := null;
         vn_dm_st_proc       := null;
         --
         -- Verificar se o último evento de fechamento do período foi processado com sucesso.
         begin
            --
            select id
                 , dm_st_proc
              into vn_efdreinfr2099_id
                 , vn_dm_st_proc
              from efd_reinf_r2099
             where id in ( select max(id)
                             from efd_reinf_r2099
                            where geracaoefdreinf_id = gt_row_geracao_efd_reinf.id );
            --
         exception
          when others then
            vn_efdreinfr2099_id  := null;
            vn_dm_st_proc        := null;
         end;
         --
         vn_fase := 6;
         --
         if ( nvl(vn_efdreinfr2099_id,0) > 0
          and nvl(vn_dm_st_proc,0) in (5,6) ) or   -- 5-Erro no envio; 6-Erro na montagem do XML
           ( nvl(vn_efdreinfr2099_id,0) = 0 )then
            --
            vn_fase := 6.1;
            --
            pk_csf_api_reinf.gv_mensagem_log := 'Não existe o evento R-2099 "Fechamento EFD Reinf" gerado para o período ou o último evento de fechamento está '||
                                                'com a situação Erro no Envio ou Erro na montagem do XML. Neste caso, não será possível efetuar a reabertura da geração EFD Reinf.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                    , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                    , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                    , en_tipo_log             => INFORMACAO
                                                    , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                    , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
            pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                      , est_log_generico_reinf  => est_log_generico_reinf
                                      );
            --
         elsif nvl(vn_efdreinfr2099_id,0) > 0
          and nvl(vn_dm_st_proc,0) in (4,7) then -- 4-Processado; 7-Processado R-5011
            --
            vn_fase := 6.2;
            --
            gt_row_efd_reinf_r2098.id                   := null;
            gt_row_efd_reinf_r2098.geracaoefdreinf_id   := gt_row_geracao_efd_reinf.id;
            gt_row_efd_reinf_r2098.dm_st_proc           := 0; -- 0-Aberto
            --
            pk_csf_api_reinf.pkb_integr_efd_reinf_r2098 ( est_log_generico_reinf  => est_log_generico_reinf
                                                        , est_row_efd_reinf_r2098 => gt_row_efd_reinf_r2098
                                                        , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                        );
            --
            -- Gerar o ID para o evento criado
            pkb_gera_id_evt_reinf ( ev_obj_referencia => 'EFD_REINF_R2098'
                                  , en_referencia_id  => gt_row_efd_reinf_r2098.id
                                  );
            --
            vn_fase := 7;
            --
            if nvl(gt_row_efd_reinf_r2098.id,0) > 0 then
               --
               vn_fase := 8;
               --
               if nvl(est_log_generico_reinf.count,0) > 0 then
                  --
                  update efd_reinf_r2098
                     set dm_st_proc = 2 -- Erro de validação
                   where id = gt_row_efd_reinf_r2098.id;
                  --
               else
                  --
                  update efd_reinf_r2098
                     set dm_st_proc = 1 -- Validado
                   where id = gt_row_efd_reinf_r2098.id;
                  --
               end if;
               --
            end if;
            --
         else  -- Aguardando Envio
            --
            pk_csf_api_reinf.gv_mensagem_log := 'Evento de fechamento ainda não foi processado pelo EFD-REINF, aguarde o evento de fechamento ser concluído e efetue a reabertura novamente.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                    , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                    , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                    , en_tipo_log             => INFORMACAO
                                                    , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                    , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
            pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                      , est_log_generico_reinf  => est_log_generico_reinf
                                      );
            --
         end if;
         --
         vn_fase := 9;
         --
      else
         --
         vn_fase := 8;
         --
         pk_csf_api_reinf.gv_mensagem_log := 'Situação do dominio que é igual a "'|| pk_csf.fkg_dominio ('GERACAO_EFD_REINF.DM_SITUACAO',  gt_row_geracao_efd_reinf.dm_situacao) ||
                                             '" da Geração que está sendo solicitado a reabertura é diferente do esperado, e deveria ser "Fechada", favor verificar.';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      end if;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_gera_evt_r2098 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenerico_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
         --
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_gera_evt_r2098;

----------------------------------------------------------------------------------------------------
-- Procedimento que recupera e relaciona as receitas de espetáculo desportivo do evento anterior com o novo evento gerado
procedure pkb_rec_evt_anterior_r3010 ( est_log_generico_reinf  in out nocopy dbms_sql.number_table
                                     , en_efdreinfr3010_old_id in            efd_reinf_r3010.id%type
                                     , en_efdreinfr3010_new_id in            efd_reinf_r3010.id%type
                                     )
is
   --
   vn_fase                        number;
   --
   cursor c_r3010 is
   select *
     from efd_reinf_r3010_det
    where efdreinfr3010_id = en_efdreinfr3010_old_id;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_r3010 loop
      exit when c_r3010%notfound or (c_r3010%notfound) is null;
      --
      vn_fase := 2;
      --
      gt_row_efd_reinf_r3010_det := null;
      --
      gt_row_efd_reinf_r3010_det.recespdesport_id       := rec.recespdesport_id;
      gt_row_efd_reinf_r3010_det.efdreinfr3010_id       := en_efdreinfr3010_new_id;
      --
      vn_fase := 3;
      --
      pk_csf_api_reinf.pkb_integr_efdreinfr3010_det ( est_log_generico_reinf      => est_log_generico_reinf
                                                    , est_row_efdreinfr3010_det   => gt_row_efd_reinf_r3010_det
                                                    , en_empresa_id               => gt_row_geracao_efd_reinf.empresa_id
                                                    );
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_rec_evt_anterior_r3010 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id                    
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_rec_evt_anterior_r3010;

---------------------------------------------------------------------------------------------------
-- Procedimento que cria um novo evento de Reenvio para os eventos com Erro no Envio ou Erro na montagem do XML
procedure pkb_reenviar_evt_r3010 ( en_efdreinfr3010_id in efd_reinf_r3010.id%type
                                 )
is
   --
   vn_fase                      number;
   vn_loggenericoreinf_id       log_generico_reinf.id%type;
   vn_efdreinfr3010_last_id     efd_reinf_r3010.id%type;
   --
   vt_efd_reinf_r3010           efd_reinf_r3010%rowtype;
   vt_log_generico_reinf        dbms_sql.number_table;
   --
begin
   --
   vn_fase := 1;
   --
   vt_efd_reinf_r3010     := null;
   vn_loggenericoreinf_id := null;
   --
   if nvl(en_efdreinfr3010_id,0) > 0 then
      --
      vn_fase := 2;
      --
      begin
         --
         select *
           into vt_efd_reinf_r3010
           from efd_reinf_r3010
          where id = en_efdreinfr3010_id;
         --
      exception
       when others then
         vt_efd_reinf_r3010 := null;
      end;
      --
      vn_fase := 3;
      -- Recupera os dados da Abertura do EFD-REINF
      pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => vt_efd_reinf_r3010.geracaoefdreinf_id );
      --
      delete log_generico_reinf
       where obj_referencia = 'EFD_REINF_R3010'
         and referencia_id  = gt_row_geracao_efd_reinf.id;
      --
      vn_fase := 4;
      --
      if nvl(vt_efd_reinf_r3010.id, 0) > 0
         and vt_efd_reinf_r3010.dm_st_proc in (5,6) then -- 5-Erro no Envio; 6-Erro na montagem do XML
         --
         vn_fase := 5;
         --
         vn_efdreinfr3010_last_id := null;
         -- Verificar se este é o último evento do Grupo do R-3010
         begin
            --
            select max(err.id)
              into vn_efdreinfr3010_last_id
              from efd_reinf_r3010      err
                 , efd_reinf_r3010_det  erd
             where err.id                 = erd.efdreinfr3010_id
               and err.geracaoefdreinf_id = vt_efd_reinf_r3010.geracaoefdreinf_id
               and erd.recespdesport_id  in ( select erd2.recespdesport_id
                                                from efd_reinf_r3010_det  erd2
                                               where erd2.efdreinfr3010_id = vt_efd_reinf_r3010.id ) ;
            
         exception
          when others then
             vn_efdreinfr3010_last_id := null;
         end;
         --
         vn_fase := 6;
         --
         if nvl(vn_efdreinfr3010_last_id,0) = nvl(vt_efd_reinf_r3010.id,0) then
            --
            vn_fase := 7;
            --
            gt_row_efd_reinf_r3010 := vt_efd_reinf_r3010;
            --
            gt_row_efd_reinf_r3010.dm_st_proc       := 0; -- 0-Aberto
            gt_row_efd_reinf_r3010.loteefdreinf_id  := null;
            --
            vn_fase := 8;
            --
            pk_csf_api_reinf.pkb_integr_efd_reinf_r3010 ( est_log_generico_reinf => vt_log_generico_reinf
                                                        , est_row_efdreinfr3010  => gt_row_efd_reinf_r3010
                                                        , en_empresa_id          => gt_row_geracao_efd_reinf.empresa_id
                                                        );
            --
            if nvl(gt_row_efd_reinf_r3010.id,0) > 0 then
               --
               vn_fase := 9;
               -- Recupera e relaciona as receitas de espetáculo desportivo do evento anterior com o novo evento gerado
               pkb_rec_evt_anterior_r3010 ( est_log_generico_reinf  => vt_log_generico_reinf
                                          , en_efdreinfr3010_old_id => gt_row_efd_reinf_r3010.id
                                          , en_efdreinfr3010_new_id => gt_row_efd_reinf_r3010.id
                                          );
               --
               vn_fase := 10;
               --
               if nvl(vt_log_generico_reinf.count,0) > 0 then
                  --
                  update efd_reinf_r3010
                     set dm_st_proc = 2
                   where id = gt_row_efd_reinf_r3010.id;
                  --
               else
                  --
                  update efd_reinf_r3010
                     set dm_st_proc = 1
                   where id = gt_row_efd_reinf_r3010.id;
                  --
               end if;
               --
            end if;
            --
         else
            --
            pk_csf_api_reinf.gv_mensagem_log := 'Está sendo reenviado um evento R-3010 ( efdreinfr3010_id = '|| vt_efd_reinf_r3010.id ||') antigo, já existe um novo evento criado para o grupo, Favor Verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                    , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                    , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                    , en_tipo_log             => INFORMACAO
                                                    , en_referencia_id        => vt_efd_reinf_r3010.id
                                                    , ev_obj_referencia       => 'EFD_REINF_R3010'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
         end if;
         --
      else
         --
         pk_csf_api_reinf.gv_mensagem_log := 'Situação "'|| pk_csf.fkg_dominio ( 'EFD_REINF_R3010.DM_ST_PROC', vt_efd_reinf_r3010.dm_st_proc ) ||'" do Evento R-3010 (EFDREINFR3010_ID = '||vt_efd_reinf_r3010.id||') não é permitido a geração do Evento de Reenvio';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => vt_efd_reinf_r3010.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R3010'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
      end if;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_reenviar_evt_r3010 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => vt_efd_reinf_r3010.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R3010'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_reenviar_evt_r3010;

----------------------------------------------------------------------------------------------------
-- Procedimento que gerencia o evento R-3010
procedure pkb_exist_evt_r3010 ( en_empresa_id in empresa.id%type
                              )
is
   --
   vn_efdreinfr3010_id             efd_reinf_r3010.id%type;
   vn_dm_tipo_reg                  efd_reinf_r3010.dm_tipo_reg%type;
   vn_dm_st_proc                   efd_reinf_r3010.dm_st_proc%type;
   vn_fase                         number;
   --
   vn_ind2                         number;
   vt_log_generico_reinf           dbms_sql.number_table;
   vn_loggenericoreinf_id          log_generico_reinf.id%type;
   vv_mensagem                     log_generico_reinf.mensagem%type;
   --
   vd_dt_ref_red                   rec_esp_desport.dt_ref%type;
   vv_nro_boletim_red              rec_esp_desport.nro_boletim%type;
   vn_tp_compet_red                rec_esp_desport.dm_tp_compet%type;
   vn_dm_categ_evento_red          rec_esp_desport.dm_categ_evento%type;
   --
begin
   --
   vn_fase := 1;
   --
   vd_dt_ref_red          := null;
   vv_nro_boletim_red     := null;
   vn_tp_compet_red       := null;
   vn_dm_categ_evento_red := null;
   --
   vn_ind2:= nvl(vt_bi_tab_index_evt_r3010(en_empresa_id).first,0);
   --
   loop
      --
      gt_row_efd_reinf_r3010 := null;
      vn_loggenericoreinf_id := null;
      --
      vn_fase := 2;
      --
      if nvl(vn_ind2,0) = 0 then -- índice = empresa_id e recespdesport_id
         exit;
      end if;
      --
      -- Verificar se já existe evento para o indice de dentro do período
      begin
         --
         select id
              , dm_tipo_reg
              , dm_st_proc
           into vn_efdreinfr3010_id
              , vn_dm_tipo_reg
              , vn_dm_st_proc
           from efd_reinf_r3010
          where id in ( select max(err.id)
                          from efd_reinf_r3010      err
                             , efd_reinf_r3010_det  erd
                         where err.geracaoefdreinf_id = gt_row_geracao_efd_reinf.id
                           and err.id                 = erd.efdreinfr3010_id
                           and erd.recespdesport_id   = vt_bi_tab_index_evt_r3010(en_empresa_id)(vn_ind2).recespdesport_id
                           and err.dm_st_proc        in (0,1,3,4,7,8) ); -- 0-Aberto; 1-Validado; 3-Aguardando Envio; 4-Processado; 7-Excluído; 8-Processado R-5001
         --
      exception
         when others then
            vn_efdreinfr3010_id := null;
            vn_dm_tipo_reg      := null;
            vn_dm_st_proc       := null;
      end;
      --
      vn_fase := 3;
      --
      gt_row_efd_reinf_r3010.id                   := null;
      gt_row_efd_reinf_r3010.geracaoefdreinf_id   := gt_row_geracao_efd_reinf.id;
      gt_row_efd_reinf_r3010.dm_st_proc           := 0; -- 0-Aberto
      gt_row_efd_reinf_r3010.ar_efdreinfr3010_id  := null;
      --
      vn_fase := 4;
      --
      if nvl(vn_efdreinfr3010_id,0) > 0 then
         --
         vn_fase := 4.1;
         --
         begin
            -- Recupera os dados da receita de espetáculo desportivo
            select re.dt_ref
                 , re.nro_boletim
                 , re.dm_tp_compet
                 , re.dm_categ_evento
              into vd_dt_ref_red
                 , vv_nro_boletim_red
                 , vn_tp_compet_red
                 , vn_dm_categ_evento_red
              from rec_esp_desport  re
             where re.id = vt_bi_tab_index_evt_r3010(en_empresa_id)(vn_ind2).recespdesport_id;
            --
         exception
            when others then
               --
               vd_dt_ref_red          := null;
               vv_nro_boletim_red     := null;
               vn_tp_compet_red       := null;
               vn_dm_categ_evento_red := null;
               --
         end;
         --
         vn_fase := 4.2;
         --
         if vn_dm_st_proc in (0,1,3) then -- 0-Aberto; 1-Validado; 3-Aguardando Envio
            --
            vv_mensagem := 'O último evento R-3010 referente a receita de espetáculo desportivo com a data de referência '|| to_char(vd_dt_ref_red, 'dd/mm/yyyy')||
                           ' número do boletim '||vv_nro_boletim_red||' tipo de competição '|| pk_csf.fkg_dominio('REC_ESP_DESPORT.DM_TP_COMPET', vn_tp_compet_red)||
                           ' categoria '|| pk_csf.fkg_dominio('REC_ESP_DESPORT.DM_CATEG_EVENTO', vn_dm_categ_evento_red)||' está com o tipo de registro "'||
                           pk_csf.fkg_dominio('EFD_REINF_R3010.DM_TIPO_REG', vn_dm_tipo_reg)||'" e com a situação "'||
                           pk_csf.fkg_dominio('EFD_REINF_R3010.DM_ST_PROC', vn_dm_st_proc)||'". Neste caso, não poderá ser gerado um novo evento R-3010.'||
                           ' Favor verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                    , ev_mensagem             => gv_resumo || vv_mensagem
                                                    , ev_resumo               => vv_mensagem
                                                    , en_tipo_log             => INFORMACAO
                                                    , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                    , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
            goto proximo_ind;
            --
         elsif vn_dm_st_proc in (4,8) then -- 4-Processado; 8-Processado R-5001
            --
            gt_row_efd_reinf_r3010.dm_tipo_reg         := 2; -- 2-Retificado
            gt_row_efd_reinf_r3010.ar_efdreinfr3010_id := vn_efdreinfr3010_id;
            --
         elsif vn_dm_st_proc = 7 then -- 7-Excluído
            --
            gt_row_efd_reinf_r3010.dm_tipo_reg := 1; -- 1-Original
            --
         end if;
         --
      else
         --
         vn_fase := 4.3;
         --
         gt_row_efd_reinf_r3010.dm_tipo_reg := 1; --Original
         --
      end if;
      --
      vn_fase := 5;
      -- Gravar Evento Criado no Banco de Dados
      pk_csf_api_reinf.pkb_integr_efd_reinf_r3010 ( est_log_generico_reinf => vt_log_generico_reinf
                                                  , est_row_efdreinfr3010  => gt_row_efd_reinf_r3010
                                                  , en_empresa_id          => gt_row_geracao_efd_reinf.empresa_id
                                                  );
      --
      vn_fase := 6;
      --
      --
      if nvl(gt_row_efd_reinf_r3010.id,0) > 0 then
         --
         vn_fase := 7;
         --
         gt_row_efd_reinf_r3010_det.efdreinfr3010_id := gt_row_efd_reinf_r3010.id;
         gt_row_efd_reinf_r3010_det.recespdesport_id := vt_bi_tab_index_evt_r3010(en_empresa_id)(vn_ind2).recespdesport_id;
         --
         vn_fase := 8;
         --
         pk_csf_api_reinf.pkb_integr_efdreinfr3010_det ( est_log_generico_reinf      => vt_log_generico_reinf
                                                       , est_row_efdreinfr3010_det   => gt_row_efd_reinf_r3010_det
                                                       , en_empresa_id               => gt_row_geracao_efd_reinf.empresa_id
                                                       );
         --
         vn_fase := 9;
         -- Gerar o ID para o evento criado
         pkb_gera_id_evt_reinf ( ev_obj_referencia => 'EFD_REINF_R3010'
                               , en_referencia_id => gt_row_efd_reinf_r3010.id
                               );
         --
         vn_fase := 10;
         --
         if nvl(vt_log_generico_reinf.count,0) > 0 then
            --
            update efd_reinf_r3010
               set dm_st_proc = 2 -- Erro de Validação
             where id = gt_row_efd_reinf_r3010.id;
            --
         else
            --
            update efd_reinf_r3010
               set dm_st_proc = 1 -- Validado
             where id = gt_row_efd_reinf_r3010.id;
            --
         end if;
         --
      end if;
      --
      vn_fase := 11;
      --
      <<proximo_ind>>
      --
      vn_fase := 12;
      --
      if vn_ind2 = vt_bi_tab_index_evt_r3010(en_empresa_id).last then
         exit;
      else
         vn_ind2 := vt_bi_tab_index_evt_r3010(en_empresa_id).next(vn_ind2);
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_exist_evt_r3010 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_exist_evt_r3010;

----------------------------------------------------------------------------------------------------
-- Procedimento que monta o Array do Evento R-3010
procedure pkb_monta_array_r3010 ( en_empresa_id in empresa.id%type )
is
   --
   vn_fase               number;
   vn_loggenerico_id     log_generico.id%type;
   vb_achou              boolean;
   --
   vn_indx1              number;
   vn_indx2              number;
   --
   -- Cursor para recuperar as receitas de espetáculos desportivos relacionadas as empresas filiais
   cursor c_esp ( en_empresa_id number ) is
   select re.*
     from rec_esp_desport re
    where re.empresa_id  = en_empresa_id
      and re.dm_situacao = 1 -- validado
      and re.dt_ref      between gt_row_geracao_efd_reinf.dt_ini and gt_row_geracao_efd_reinf.dt_fin
      and re.dm_envio    = 0;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_esp(en_empresa_id)loop
      exit when c_esp%notfound or (c_esp%notfound) is null;
      --
      vn_fase := 2;
      --
      vn_indx1 := null;
      vn_indx2 := null;
      --
      vn_indx1 := nvl(rec.empresa_id,0);
      vn_indx2 := nvl(rec.id,0);  -- recespdesport_id
      --
      vn_fase := 2.1;
      --
      begin
         vb_achou := vt_bi_tab_index_evt_r3010(vn_indx1).exists(vn_indx2);
      exception
         when others then
            vb_achou := false;
      end;
      --
      vn_fase := 3;
      --
      if not vb_achou then
         --
         vn_fase := 3.1;
         --
         vt_tab_index_evt_r3010(vn_indx1).empresa_id := rec.empresa_id;
         --
         vt_bi_tab_index_evt_r3010(vn_indx1)(vn_indx2).recespdesport_id := rec.id;
         vt_bi_tab_index_evt_r3010(vn_indx1)(vn_indx2).dt_ref := rec.dt_ref;
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_monta_array_r3010 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_monta_array_r3010;

----------------------------------------------------------------------------------------------------
-- Procedimento de Geração do Evento R-3010
procedure pkb_gera_evt_r3010
is
   --
   vn_fase                  number;
   vn_ind1                  number;
   --
   cursor c_empr is
   select em.id empresa_id
     from empresa em
    where dm_situacao = 1 -- Ativo
    start with em.id = gt_row_geracao_efd_reinf.empresa_id
  connect by prior em.id = em.ar_empresa_id;
   --
begin
   --
   vn_fase := 1;
   --
   i := null;
   --
   vt_bi_tab_index_evt_r3010.delete;
   --
   vn_fase := 2;
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 3;
      --
      -- recupera a data de escrituação para recuperação dos documentos fiscais
      gn_dm_dt_escr_dfepoe := pk_csf.fkg_dmdtescrdfepoe_empresa( en_empresa_id => rec.empresa_id );
      --
      pkb_monta_array_r3010 ( rec.empresa_id );
      --
   end loop;
   --
   vn_fase := 4;
   --
   vn_ind1:= nvl(vt_tab_index_evt_r3010.first,0);
   --
   vn_fase := 5;
   --
   -- Manter o mesmo estilo de geração dos demais evento por conta
   -- de caso futuramente o evento para a ser declarado por empresa filial tambem
   -- ja existe boa parte do processo pronto.
   loop
      --
      vn_fase := 6;
      --
      if nvl(vn_ind1,0) = 0 then -- índice = empresa_id
         exit;
      end if;
      --
      vn_fase := 7;
      --
      pkb_exist_evt_r3010( en_empresa_id => vt_tab_index_evt_r3010(vn_ind1).empresa_id );
      --
      vn_fase := 8;
      --
      if vn_ind1 = vt_tab_index_evt_r3010.last then
         exit;
      else
         vn_ind1 := vt_tab_index_evt_r3010.next(vn_ind1);
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_gera_evt_r3010 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_gera_evt_r3010;

----------------------------------------------------------------------------------------------------
-- Procedimento que recupera e relaciona os pagamentos de impostos retidos do evento anterior com o novo evento gerado
procedure pkb_rec_evt_anterior_r2070 ( est_log_generico_reinf  in out nocopy dbms_sql.number_table
                                     , en_efdreinfr2070_old_id in            efd_reinf_r2070.id%type
                                     , en_efdreinfr2070_new_id in            efd_reinf_r2070.id%type
                                     )
is
   --
   vn_fase                        number;
   --
   cursor c_r2070 is
   select *
     from efd_reinf_r2070_pir
    where efdreinfr2070_id = en_efdreinfr2070_old_id;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_r2070 loop
      exit when c_r2070%notfound or (c_r2070%notfound) is null;
      --
      vn_fase := 2;
      --
      gt_row_efd_reinf_r2070_pir := null;
      --
      gt_row_efd_reinf_r2070_pir.pgtoimpret_id       := rec.pgtoimpret_id;
      gt_row_efd_reinf_r2070_pir.efdreinfr2070_id    := en_efdreinfr2070_new_id;
      --
      vn_fase := 3;
      --
      pk_csf_api_reinf.pkb_integr_efdreinfr2070_pgto ( est_log_generico_reinf      => est_log_generico_reinf
                                                     , est_row_efdreinfr2070_pgto  => gt_row_efd_reinf_r2070_pir
                                                     , en_empresa_id               => gt_row_geracao_efd_reinf.empresa_id
                                                     );
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_rec_evt_anterior_r2070 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id                    
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_rec_evt_anterior_r2070;

---------------------------------------------------------------------------------------------------
-- Procedimento de retificação do pagamento de imposto retido do Evento R-2070
procedure pkb_retif_evt_r2070 ( en_efdreinfr2070_id in efd_reinf_r2070.id%type
                              , en_pgtoimpret_id    in pgto_imp_ret.id%type
                              )
is
   --
   vn_fase                           number;
   vn_loggenerico_id                 log_generico_reinf.id%type;
   vt_log_generico_reinf             dbms_sql.number_table;
   --
   vv_mensagem_log                   log_generico_reinf.mensagem%type;
   vv_resumo_log                     log_generico_reinf.resumo%type;
   vt_efd_reinf_r2070                efd_reinf_r2070%rowtype;
   vt_efd_reinf_r2070_new            efd_reinf_r2070%rowtype;
   vn_efdreinfr2070_last_id          efd_reinf_r2070.id%type;
   vn_cont_reg                       number;
   --
begin
   --
   vn_fase := 1;
   --
   vt_efd_reinf_r2070       := null;
   vt_efd_reinf_r2070_new   := null;
   vn_efdreinfr2070_last_id := null;
   vn_cont_reg              := null;
   --
   vn_fase := 2;
   --
   begin
      --
      select *
        into vt_efd_reinf_r2070
        from efd_reinf_r2070
       where id = en_efdreinfr2070_id;
      --
   exception
    when others then
      vt_efd_reinf_r2070 := null;
   end;
   --
   vn_fase := 3;
   --
   -- Recupera os dados da Abertura do EFD-REINF
   pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => vt_efd_reinf_r2070.geracaoefdreinf_id );
   --
   if nvl(gt_row_geracao_efd_reinf.dm_situacao, 0) = 2 then  -- 2-Aberto
      --
      if nvl(vt_efd_reinf_r2070.id,0) > 0 then
         --
         vn_fase := 4;
         --
         vv_resumo_log := 'Procedimento de Retificação do Evento R-2070 (Impostos Retidos) do Participate: '||
                          pk_csf.fkg_pessoa_cod_part ( vt_efd_reinf_r2070.pessoa_id )||' - '||pk_csf.fkg_nome_pessoa_id ( vt_efd_reinf_r2070.pessoa_id )||
                          ', no período de '||trim(to_char(gt_row_geracao_efd_reinf.dt_ini, 'month'))||' de '||to_char(gt_row_geracao_efd_reinf.dt_ini,'yyyy');
         --
         vn_fase := 5;
         --
         delete log_generico_reinf
          where obj_referencia = 'EFD_REINF_R2070'
            and referencia_id  = vt_efd_reinf_r2070.id;
         --
         vn_fase := 6;
         --
         if vt_efd_reinf_r2070.dm_st_proc = 4 then -- 4-Processado
            --
            vn_fase := 7;
            -- Conta o número de pagamento de impostos retidos que estão relacionadas ao evento R-2070
            begin
               --
               select count(*)
                 into vn_cont_reg
                 from efd_reinf_r2070_pir
                where efdreinfr2070_id = vt_efd_reinf_r2070.id;
               --
            exception
               when others then
                  --
                  vn_cont_reg := 0;
                  --
            end;
            --
            vn_fase := 8;
            -- Se o evento estiver relacionado a apenas um pagamento de imposto retido e o mesmo estiver sendo retificado,
            -- o processo deverá gerar o evento de exclusão R-9000
            if nvl(vn_cont_reg, 0) = 1 then
               --
               vn_fase := 9;
               -- Cria o evento de exclusão R-9000 para o evento R-2070
               pk_desfazer_dados_reinf.pkb_excluir_evt_r2070(vt_efd_reinf_r2070.id);
               --
            else
               --
               vn_fase := 10;
               -- Recupera o ID do último evento do grupo R-2070
               begin
                  --
                  select id
                    into vn_efdreinfr2070_last_id
                    from efd_reinf_r2070
                   where id in ( select max(id)
                                   from efd_reinf_r2070
                                  where pessoa_id          = vt_efd_reinf_r2070.pessoa_id
                                    and geracaoefdreinf_id = vt_efd_reinf_r2070.geracaoefdreinf_id
                                    and tiporetimp_id      = vt_efd_reinf_r2070.tiporetimp_id );
                  --
               end;
               --
               vn_fase := 11;
               --
               if nvl(vn_efdreinfr2070_last_id, 0) = nvl(vt_efd_reinf_r2070.id, 0) then
                  --
                  vt_efd_reinf_r2070_new.id                   := null;
                  vt_efd_reinf_r2070_new.geracaoefdreinf_id   := vt_efd_reinf_r2070.geracaoefdreinf_id;
                  vt_efd_reinf_r2070_new.dm_st_proc           := 0; -- 0-Aberto
                  vt_efd_reinf_r2070_new.dm_tipo_reg          := 2; -- 2-Retificado
                  vt_efd_reinf_r2070_new.pessoa_id            := vt_efd_reinf_r2070.pessoa_id;
                  vt_efd_reinf_r2070_new.tiporetimp_id        := vt_efd_reinf_r2070.tiporetimp_id;
                  vt_efd_reinf_r2070_new.ar_efdreinfr2070_id  := vt_efd_reinf_r2070.id;
                  --
                  vn_fase := 12;
                  -- Cria o novo evento R-2070
                  pk_csf_api_reinf.pkb_integr_efd_reinf_r2070 ( est_log_generico_reinf  => vt_log_generico_reinf
                                                              , est_row_efdreinfr2070   => vt_efd_reinf_r2070_new
                                                              , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                              );
                  --
                  vn_fase := 13;
                  --
                  if nvl(vt_efd_reinf_r2070_new.id, 0) > 0 then
                     -- Recupera e relaciona os pagamento de impostos retidos do evento anterior com o novo evento gerado
                     pkb_rec_evt_anterior_r2070 ( est_log_generico_reinf  => vt_log_generico_reinf
                                                , en_efdreinfr2070_old_id => vt_efd_reinf_r2070.id
                                                , en_efdreinfr2070_new_id => vt_efd_reinf_r2070_new.id
                                                );
                     --
                     vn_fase := 14;
                     --Exclui o pagamento de imposto retido "retificado" do novo evento R-2070
                     delete efd_reinf_r2070_pir
                      where efdreinfr2070_id = vt_efd_reinf_r2070_new.id
                        and pgtoimpret_id    = en_pgtoimpret_id;  --Pagamento de imposto retido "retificado"
                     --
                     vn_fase := 15;
                     -- Atualiza a situação "dm_envio = 0" para o pagamento de imposto retido "retificado"
                     update pgto_imp_ret
                        set dm_envio = 0            -- 0-Não enviado
                      where id = en_pgtoimpret_id;  -- Pagamento de imposto retido "retificado"
                     --
                  end if;
                  --
                  vn_fase := 16;
                  --
                  if nvl(vt_log_generico_reinf.count,0) = 0 then
                     --
                     update efd_reinf_r2070
                        set dm_st_proc = 1 -- Validado
                      where id = vt_efd_reinf_r2070_new.id;
                     --
                  else
                     --
                     update efd_reinf_r2070
                        set dm_st_proc = 2 -- Erro de validação
                      where id = vt_efd_reinf_r2070_new.id;
                     --
                  end if;
                  --
                  vn_fase := 17;
                  --
                  -- Gerar o ID para o novo evento criado
                  pkb_gera_id_evt_reinf ( ev_obj_referencia => 'EFD_REINF_R2070'
                                        , en_referencia_id  => gt_row_efd_reinf_r2070.id
                                        );
                  --
               else
                  --
                  vn_fase := 18;
                  --
                  vv_mensagem_log := 'Evento não pode ser retificado pois não é o último evento gerado para o grupo de informação, favor verificar.';
                  --
                  pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                          , ev_mensagem             => vv_resumo_log ||' '|| vv_mensagem_log
                                                          , ev_resumo               => vv_mensagem_log
                                                          , en_tipo_log             => pk_csf_api_reinf.informacao
                                                          , en_referencia_id        => vt_efd_reinf_r2070.id
                                                          , ev_obj_referencia       => 'EFD_REINF_R2070'
                                                          , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                          );
                  --
               end if;
               --
            end if;
            --
         else  -- 0-Aberto; 1-Validado; 2-Erro de Validação; 3-Aguardando Envio; 5-Erro no Envio; 6-Erro na montagem do XML; 7-Excluído
            --
            vn_fase := 19;
            --
            vv_mensagem_log := 'O evento R-2070 não pode ser retificado pois está com o tipo de registro "'||
                               pk_csf.fkg_dominio('EFD_REINF_R2070.DM_TIPO_REG', vt_efd_reinf_r2070.dm_tipo_reg)||
                               '" e com a situação "'||pk_csf.fkg_dominio('EFD_REINF_R2070.DM_ST_PROC', vt_efd_reinf_r2070.dm_st_proc)||
                               '", favor verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                    , ev_mensagem             => vv_resumo_log ||' '|| vv_mensagem_log
                                                    , ev_resumo               => vv_mensagem_log
                                                    , en_tipo_log             => pk_csf_api_reinf.informacao
                                                    , en_referencia_id        => vt_efd_reinf_r2070.id
                                                    , ev_obj_referencia       => 'EFD_REINF_R2070'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
         end if;
         --
      end if;
      --
   else
      --
      vn_fase := 20;
      --
      vv_mensagem_log := 'Evento não pode ser retificado pois a situação do evento é diferente de "Aberto", favor verificar.';
      --
      pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                              , ev_mensagem             => vv_resumo_log ||' '|| vv_mensagem_log
                                              , ev_resumo               => vv_mensagem_log
                                              , en_tipo_log             => pk_csf_api_reinf.informacao
                                              , en_referencia_id        => vt_efd_reinf_r2070.id
                                              , ev_obj_referencia       => 'EFD_REINF_R2070'
                                              , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                             );
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      pk_csf_api_reinf.gv_mensagem_log := 'Erro na pk_gera_dados_reinf.pkb_retif_evt_r2070 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => vv_resumo_log || pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                 , en_tipo_log             => pk_csf_api_reinf.ERRO_DE_SISTEMA
                                                 , en_referencia_id        => pk_csf_api_reinf.gn_referencia_id
                                                 , ev_obj_referencia       => pk_csf_api_reinf.gv_obj_referencia
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_retif_evt_r2070;

---------------------------------------------------------------------------------------------------
-- Procedimento que cria um novo evento de Reenvio para os eventos com Erro no Envio ou Erro na montagem do XML
procedure pkb_reenviar_evt_r2070 ( en_efdreinfr2070_id in efd_reinf_r2070.id%type
                                 )
is
   --
   vn_fase                      number;
   vn_loggenericoreinf_id       log_generico_reinf.id%type;
   vn_efdreinfr2070_last_id     efd_reinf_r2070.id%type;
   --
   vt_efd_reinf_r2070           efd_reinf_r2070%rowtype;
   vt_log_generico_reinf        dbms_sql.number_table;
   --
begin
   --
   vn_fase := 1;
   --
   vt_efd_reinf_r2070     := null;
   vn_loggenericoreinf_id := null;
   --
   if nvl(en_efdreinfr2070_id,0) > 0 then
      --
      vn_fase := 2;
      --
      begin
         --
         select *
           into vt_efd_reinf_r2070
           from efd_reinf_r2070
          where id = en_efdreinfr2070_id;
         --
      exception
       when others then
         vt_efd_reinf_r2070 := null;
      end;
      --
      vn_fase := 3;
      -- Recupera os dados da Abertura do EFD-REINF
      pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => vt_efd_reinf_r2070.geracaoefdreinf_id );
      --
      delete log_generico_reinf
       where obj_referencia = 'EFD_REINF_R2070'
         and referencia_id  = gt_row_geracao_efd_reinf.id;
      --
      vn_fase := 4;
      --
      if nvl(vt_efd_reinf_r2070.id, 0) > 0
         and vt_efd_reinf_r2070.dm_st_proc in (5,6) then -- 5-Erro no Envio; 6-Erro na montagem do XML
         --
         vn_fase := 5;
         --
         vn_efdreinfr2070_last_id := null;
         -- Verificar se este é o último evento do grupo do R-2070
         begin
            --
            select max(id)
              into vn_efdreinfr2070_last_id
              from efd_reinf_r2070
             where pessoa_id          = vt_efd_reinf_r2070.pessoa_id
               and tiporetimp_id      = vt_efd_reinf_r2070.tiporetimp_id
               and geracaoefdreinf_id = vt_efd_reinf_r2070.geracaoefdreinf_id;
            --
         exception
          when others then
             vn_efdreinfr2070_last_id := null;
         end;
         --
         vn_fase := 6;
         --
         if nvl(vn_efdreinfr2070_last_id,0) = nvl(vt_efd_reinf_r2070.id,0) then
            --
            vn_fase := 7;
            --
            gt_row_efd_reinf_r2070 := vt_efd_reinf_r2070;
            --
            gt_row_efd_reinf_r2070.dm_st_proc       := 0;  -- 0-Aberto.
            gt_row_efd_reinf_r2070.loteefdreinf_id  := null;
            --
            vn_fase := 8;
            --
            pk_csf_api_reinf.pkb_integr_efd_reinf_r2070 ( est_log_generico_reinf => vt_log_generico_reinf
                                                        , est_row_efdreinfr2070  => gt_row_efd_reinf_r2070
                                                        , en_empresa_id          => gt_row_geracao_efd_reinf.empresa_id
                                                        );
            --
            vn_fase := 9;
            -- Recupera e relaciona os pagamentos de impostos retidos do evento anterior com o novo evento gerado
            pkb_rec_evt_anterior_r2070 ( est_log_generico_reinf  => vt_log_generico_reinf
                                       , en_efdreinfr2070_old_id => gt_row_efd_reinf_r2070.id
                                       , en_efdreinfr2070_new_id => gt_row_efd_reinf_r2070.id
                                       );
            --
            vn_fase := 10;
            --
            if nvl(vt_log_generico_reinf.count,0) > 0 then
               --
               update efd_reinf_r2070
                  set dm_st_proc = 2
                where id = gt_row_efd_reinf_r2070.id;
               --
            else
               --
               update efd_reinf_r2070
                  set dm_st_proc = 1
                where id = gt_row_efd_reinf_r2070.id;
               --
            end if;
            --
         else
            --
            pk_csf_api_reinf.gv_mensagem_log := 'Está sendo reenviado um evento R-2070 ( efdreinfr2070_id = '|| vt_efd_reinf_r2070.id ||') antigo, já existe um novo evento criado para o grupo, Favor Verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                    , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                    , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                    , en_tipo_log             => INFORMACAO
                                                    , en_referencia_id        => vt_efd_reinf_r2070.id
                                                    , ev_obj_referencia       => 'EFD_REINF_R2070'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
         end if;
         --
      else
         --
         pk_csf_api_reinf.gv_mensagem_log := 'Situação "'|| pk_csf.fkg_dominio ( 'EFD_REINF_R2070.DM_ST_PROC', vt_efd_reinf_r2070.dm_st_proc ) ||'" do evento R-2070 (efdreinfr2060_id = '||vt_efd_reinf_r2070.id||') não é permitido a geração do evento de reenvio';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => vt_efd_reinf_r2070.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2070'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
      end if;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_reenviar_evt_r2070 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => vt_efd_reinf_r2070.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2070'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_reenviar_evt_r2070;

---------------------------------------------------------------------------------------------------
-- Procedimento que verifica se existe o evento R-2070
procedure pkb_exist_evt_r2070 ( en_tiporetimp_id in tipo_ret_imp.id%type
                              , en_pessoa_id     in pessoa.id%type
                              )
is
   --
   vn_efdreinfr2070_id             efd_reinf_r2070.id%type;
   vn_dm_tipo_reg                  efd_reinf_r2070.dm_tipo_reg%type;
   vn_dm_st_proc                   efd_reinf_r2070.dm_st_proc%type;
   vn_fase                         number;
   --
   vn_indx1                        number;
   vn_indx2                        number;
   vt_log_generico_reinf           dbms_sql.number_table;
   vn_loggenericoreinf_id          log_generico_reinf.id%type;
   vv_mensagem                     log_generico_reinf.mensagem%type;
   --
   vn_empresa_id                   pgto_imp_ret.empresa_id%type;
   vv_nro_doc                      pgto_imp_ret.nro_doc%type;
   vd_dt_vcto                      pgto_imp_ret.dt_vcto%type;
   vd_dt_pgto                      pgto_imp_ret.dt_pgto%type;
   vv_tipo_imp                     varchar2(60);
   vv_tipo_ret_imp                 varchar2(60);
   --
begin
   --
   vn_fase := 1;
   --
   vn_indx1 := null;
   --
   vn_indx1 := en_tiporetimp_id || en_pessoa_id;
   --
   gt_row_efd_reinf_r2070 := null;
   vn_loggenericoreinf_id := null;
   --
   vn_empresa_id          := null;
   vv_nro_doc             := null;
   vd_dt_vcto             := null;
   vd_dt_pgto             := null;
   vv_tipo_imp            := null;
   vv_tipo_ret_imp        := null;
   --
   vn_fase := 2;
   -- Verificar se ja existe Evento para o Indice de dentro do Periodo
   begin
      --
      select id
           , dm_tipo_reg
           , dm_st_proc
        into vn_efdreinfr2070_id
           , vn_dm_tipo_reg
           , vn_dm_st_proc
        from efd_reinf_r2070
       where id in ( select max(err.id)
                       from efd_reinf_r2070 err
                      where err.pessoa_id          = en_pessoa_id -- Participante
                        and err.tiporetimp_id      = en_tiporetimp_id
                        and err.geracaoefdreinf_id = gt_row_geracao_efd_reinf.id 
                        and err.dm_st_proc         in (0,1,3,4,7) ); -- 0-Aberto; 1-Validado; 3-Aguardando Envio; 4-Processado; 7-Excluído
      --
   exception
    when others then
      vn_efdreinfr2070_id := null;
      vn_dm_tipo_reg      := null;
      vn_dm_st_proc       := null;
   end;
   --
   vn_fase := 3;
   --
   gt_row_efd_reinf_r2070.id                   := null;
   gt_row_efd_reinf_r2070.geracaoefdreinf_id   := gt_row_geracao_efd_reinf.id;   
   gt_row_efd_reinf_r2070.pessoa_id            := en_pessoa_id;
   gt_row_efd_reinf_r2070.tiporetimp_id        := en_tiporetimp_id;
   gt_row_efd_reinf_r2070.dm_st_proc           := 0; -- 0-Aberto
   gt_row_efd_reinf_r2070.ar_efdreinfr2070_id  := null;
   --
   vn_fase := 4;
   --
   if nvl(vn_efdreinfr2070_id,0) > 0 then
      --
      vn_fase := 4.1;
      --
      begin
         -- Recupera os dados da receita de espetáculo desportivo
         select pg.empresa_id
              , pg.nro_doc
              , pg.dt_vcto
              , pg.dt_pgto
              , ti.cd ||' - '|| ti.descr     tipo_imp
              , tr.cd ||' - '|| tr.descr     tipo_ret_imp
           into vn_empresa_id
              , vv_nro_doc
              , vd_dt_vcto
              , vd_dt_pgto
              , vv_tipo_imp
              , vv_tipo_ret_imp
          from pgto_imp_ret  pg
             , tipo_imposto  ti
             , tipo_ret_imp  tr
         where pg.tipoimp_id    = ti.id
           and pg.tiporetimp_id = tr.id
           and tr.id            = en_tiporetimp_id;
         --
      exception
         when others then
            vn_empresa_id   := null;
            vv_nro_doc      := null;
            vd_dt_vcto      := null;
            vd_dt_pgto      := null;
            vv_tipo_imp     := null;
            vv_tipo_ret_imp := null;
      end;
      --
      vn_fase := 4.2;
      --
      if vn_dm_st_proc in (0,1,3) then -- 0-Aberto; 1-Validado; 3-Aguardando Envio
         --
         vv_mensagem := 'O último evento R-2070 referente o pagamento de imposto retido da empresa '||pk_csf.fkg_codpart_empresaid(vn_empresa_id)||
                        ' número do documento '||vv_nro_doc||' data de vencimento '||to_char(vd_dt_vcto, 'dd/mm/yyyy')|| ' data de pagamento '||
                        to_char(vd_dt_pgto, 'dd/mm/yyyy')||' tipo de imposto '||vv_tipo_imp||' tipo de imposto retido'||vv_tipo_ret_imp||
                        ' está com o tipo de registro "'||pk_csf.fkg_dominio('EFD_REINF_R2070.DM_TIPO_REG', vn_dm_tipo_reg)||
                        '" e com a situação "'||pk_csf.fkg_dominio('EFD_REINF_R2070.DM_ST_PROC', vn_dm_st_proc)||
                        '". Neste caso, não poderá ser gerado um novo evento R-2070. Favor verificar.';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_resumo || vv_mensagem
                                                 , ev_resumo               => vv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         goto sair_geral;
         --
      elsif vn_dm_st_proc = 4 then -- 4-Processado
         --
         gt_row_efd_reinf_r2070.dm_tipo_reg         := 2; -- 2-Retificado
         gt_row_efd_reinf_r2070.ar_efdreinfr2070_id := vn_efdreinfr2070_id;
         --
      elsif vn_dm_st_proc = 7 then -- 7-Excluído
         --
         gt_row_efd_reinf_r2070.dm_tipo_reg := 1; -- 1-Original
         --
      else  -- 2-Erro de Validação; 5-Erro no Envio; 6-Erro na montagem do XML
         --
         gt_row_efd_reinf_r2070.dm_tipo_reg := vn_dm_tipo_reg;
         --
      end if;
      --
   else
      --
      vn_fase := 4.3;
      --
      gt_row_efd_reinf_r2070.dm_tipo_reg := 1; --Original
      --
   end if;
   --
   vn_fase := 5;
   -- Gravar Evento Criado no Banco de Dados
   pk_csf_api_reinf.pkb_integr_efd_reinf_r2070 ( est_log_generico_reinf => vt_log_generico_reinf
                                               , est_row_efdreinfr2070  => gt_row_efd_reinf_r2070
                                               , en_empresa_id          => gt_row_geracao_efd_reinf.empresa_id
                                               );
   --
   vn_fase := 6;
   --
   if nvl(gt_row_efd_reinf_r2070.id,0) > 0 then
      --
      vn_fase := 7;
      --
      vn_indx2:= nvl(vt_bi_tab_indx_evt_r2070_pgto(vn_indx1).first,0);
      --
      loop
         --
         gt_row_efd_reinf_r2070_pir := null;
         --
         if nvl(vn_indx2,0) = 0 then -- índice = tiporetimp_id e pessoa_id
            exit;
         end if;
         --
         vn_fase := 8;
         --
         gt_row_efd_reinf_r2070_pir.pgtoimpret_id    := vt_bi_tab_indx_evt_r2070_pgto(vn_indx1)(vn_indx2).pgtoimpret_id;
         gt_row_efd_reinf_r2070_pir.efdreinfr2070_id := gt_row_efd_reinf_r2070.id;
         --
         pk_csf_api_reinf.pkb_integr_efdreinfr2070_pgto ( est_log_generico_reinf      => vt_log_generico_reinf
                                                        , est_row_efdreinfr2070_pgto  => gt_row_efd_reinf_r2070_pir
                                                        , en_empresa_id               => gt_row_geracao_efd_reinf.empresa_id
                                                        );
         --
         vn_fase := 9;
         --
         if vn_indx2 = vt_bi_tab_indx_evt_r2070_pgto(vn_indx1).last then
            exit;
         else
            vn_indx2 := vt_bi_tab_indx_evt_r2070_pgto(vn_indx1).next(vn_indx2);
         end if;
         --
      end loop;
      --
      vn_fase := 10;
      --
      if nvl(vn_efdreinfr2070_id, 0) > 0 
         and nvl(vn_dm_st_proc, -1) <> 7 then -- 7-Excluído
         -- Recupera e relaciona os pagamentos de impostos retidos do evento anterior com o novo evento gerado
         pkb_rec_evt_anterior_r2070 ( est_log_generico_reinf  => vt_log_generico_reinf
                                    , en_efdreinfr2070_old_id => vn_efdreinfr2070_id
                                    , en_efdreinfr2070_new_id => gt_row_efd_reinf_r2070.id
                                    );
         --
      end if;
      --
      vn_fase := 11;
      -- Gerar o ID para o evento criado
      pkb_gera_id_evt_reinf ( ev_obj_referencia => 'EFD_REINF_R2070'
                            , en_referencia_id  => gt_row_efd_reinf_r2070.id
                            );
      --
      vn_fase := 12;
      --
      if nvl(vt_log_generico_reinf.count,0) > 0 then
         --
         update efd_reinf_r2070
            set dm_st_proc = 2 -- Erro de Validação
          where id = gt_row_efd_reinf_r2070.id;
         --
      else
         --
         update efd_reinf_r2070
            set dm_st_proc = 1 -- Validado
          where id = gt_row_efd_reinf_r2070.id;
         --
      end if;
      --
   end if;
   --
   <<sair_geral>>
   --
   null;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_exist_evt_r2070 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_exist_evt_r2070;

---------------------------------------------------------------------------------------------------
-- Procedimento que Monta o Array
procedure pkb_monta_array_r2070 ( en_empresa_id in empresa.id%type 
                                )
is
   --
   vn_fase               number;
   vn_loggenerico_id     log_generico.id%type;
   vb_achou              boolean;
   --
   vn_indx1              number;
   vn_indx2              number;
   --
   -- Cursor para recuperar os pagamentos de impostos retidos relacionados as empresas filiais
   cursor c_pgto_ret ( en_empresa_id number ) is
   select pg.*
     from pgto_imp_ret pg
        , tipo_imposto ti
    where pg.tipoimp_id  = ti.id
      and ti.cd          in (4,5,11,12,14)  -- 4-PIS; 5-COFINS; 11-CSLL, 12-IRRF e 14-PCC
      and pg.empresa_id  = en_empresa_id
      and pg.dm_situacao = 1 -- validado
      and pg.dt_docto    between gt_row_geracao_efd_reinf.dt_ini and gt_row_geracao_efd_reinf.dt_fin
      and pg.dm_envio    = 0; -- Não Enviado
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_pgto_ret(en_empresa_id)loop
      exit when c_pgto_ret%notfound or (c_pgto_ret%notfound) is null;
      --
      vn_fase := 2;
      --
      vn_indx1 := null;
      vn_indx2 := null;
      --
      vn_indx1 := nvl(rec.tiporetimp_id,0);
      vn_indx2 := nvl(rec.pessoa_id,0);
      --
      vn_fase := 2.1;
      --
      begin
         vb_achou := vt_bi_tab_index_evt_r2070(vn_indx1).exists(vn_indx2);
      exception
         when others then
            vb_achou := false;
      end;
      --
      vn_fase := 3;
      --
      if not vb_achou then
         --
         vn_fase := 3.1;
         --
         vt_bi_tab_index_evt_r2070(vn_indx1)(vn_indx2).evt_id        := vn_indx1 || vn_indx2;
         vt_bi_tab_index_evt_r2070(vn_indx1)(vn_indx2).tiporetimp_id := rec.tiporetimp_id;
         vt_bi_tab_index_evt_r2070(vn_indx1)(vn_indx2).pessoa_id     := rec.pessoa_id;
         --
         vt_bi_tab_indx_evt_r2070_pgto(vn_indx1 || vn_indx2)(rec.id).pgtoimpret_id := rec.id;
         --
      else
         --
         vn_fase := 3.2;
         --
         vt_bi_tab_indx_evt_r2070_pgto(vt_bi_tab_index_evt_r2070(vn_indx1)(vn_indx2).evt_id)(rec.id).pgtoimpret_id := rec.id;
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_monta_array_r2070 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_monta_array_r2070;

----------------------------------------------------------------------------------------------------
-- Procedimento que gera evento de R-2070
procedure pkb_gera_evt_r2070
is
   --
   vn_fase                  number;
   vn_ind1                  number;
   vn_ind2                  number;
   --
   cursor c_empr is
   select em.id empresa_id
     from empresa em
    where dm_situacao = 1 -- Ativo
    start with em.id = gt_row_geracao_efd_reinf.empresa_id
  connect by prior em.id = em.ar_empresa_id;
   --
begin
   --
   vn_fase := 1;
   --
   i := null;
   vt_bi_tab_indx_evt_r2070_pgto.delete;
   vt_bi_tab_index_evt_r2070.delete;
   --
   vn_fase := 2;
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 3;
      -- recupera a data de escrituação para recuperação dos documentos fiscais
      gn_dm_dt_escr_dfepoe := pk_csf.fkg_dmdtescrdfepoe_empresa( en_empresa_id => rec.empresa_id );
      --
      pkb_monta_array_r2070 ( rec.empresa_id );
      --
   end loop;
   --
   vn_fase := 4;
   --
   vn_ind1:= nvl(vt_bi_tab_index_evt_r2070.first,0);
   --
   vn_fase := 5;
   --
   loop
      --
      vn_fase := 6;
      --
      if nvl(vn_ind1,0) = 0 then -- índice = empresa_id e dm_ind_obra
         exit;
      end if;
      --
      vn_ind2:= nvl(vt_bi_tab_index_evt_r2070(vn_ind1).first,0);
      --
      loop
         --
         vn_fase := 7;
         --
         if nvl(vn_ind1,0) = 0 then -- índice = empresa_id e dm_ind_obra
            exit;
         end if;
         --
         vn_fase := 8;
         --
         pkb_exist_evt_r2070 ( en_tiporetimp_id => vt_bi_tab_index_evt_r2070(vn_ind1)(vn_ind2).tiporetimp_id
                             , en_pessoa_id     => vt_bi_tab_index_evt_r2070(vn_ind1)(vn_ind2).pessoa_id
                             );
         --
         if vn_ind2 = vt_bi_tab_index_evt_r2070(vn_ind1).last then
            exit;
         else
            vn_ind2 := vt_bi_tab_index_evt_r2070(vn_ind1).next(vn_ind2);
         end if;
         --
      end loop;
      --
      if vn_ind1 = vt_bi_tab_index_evt_r2070.last then
         exit;
      else
         vn_ind1 := vt_bi_tab_index_evt_r2070.next(vn_ind1);
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_gera_evt_r2070 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_gera_evt_r2070;

---------------------------------------------------------------------------------------------------
-- Procedimento que cria um novo evento de Reenvio para os eventos com Erro no Envio ou Erro na montagem do XML
procedure pkb_reenviar_evt_r2060 ( en_efdreinfr2060_id in efd_reinf_r2060.id%type
                                 )
is
   --
   vn_fase                      number;
   vn_loggenericoreinf_id       log_generico_reinf.id%type;
   vn_efdreinfr2060_last_id     efd_reinf_r2060.id%type;
   --
   vt_efd_reinf_r2060           efd_reinf_r2060%rowtype;
   vt_log_generico_reinf        dbms_sql.number_table;
   --
begin
   --
   vn_fase := 1;
   --
   vt_efd_reinf_r2060     := null;
   vn_loggenericoreinf_id := null;
   --
   if nvl(en_efdreinfr2060_id,0) > 0 then
      --
      vn_fase := 2;
      --
      begin
         --
         select *
           into vt_efd_reinf_r2060
           from efd_reinf_r2060
          where id = en_efdreinfr2060_id;
         --
      exception
       when others then
         vt_efd_reinf_r2060 := null;
      end;
      --
      vn_fase := 3;
      -- Recupera os dados da Abertura do EFD-REINF
      pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => vt_efd_reinf_r2060.geracaoefdreinf_id );
      --
      delete log_generico_reinf
       where obj_referencia = 'EFD_REINF_R2060'
         and referencia_id  = gt_row_geracao_efd_reinf.id;
      --
      vn_fase := 4;
      --
      if nvl(vt_efd_reinf_r2060.id, 0) > 0
         and vt_efd_reinf_r2060.dm_st_proc in (5,6) then -- 5-Erro no Envio; 6-Erro na montagem do XML
         --
         vn_fase := 5;
         --
         vn_efdreinfr2060_last_id := null;
         -- Verificar se este é o último evento do grupo do R-2060
         begin
            --
            select max(id)
              into vn_efdreinfr2060_last_id
              from efd_reinf_r2060
             where apurcprbempr_id    = vt_efd_reinf_r2060.apurcprbempr_id
               and geracaoefdreinf_id = vt_efd_reinf_r2060.geracaoefdreinf_id;
            --
         exception
          when others then
             vn_efdreinfr2060_last_id := null;
         end;
         --
         vn_fase := 6;
         --
         if nvl(vn_efdreinfr2060_last_id,0) = nvl(vt_efd_reinf_r2060.id,0) then
            --
            vn_fase := 7;
            --
            gt_row_efd_reinf_r2060 := vt_efd_reinf_r2060;
            --
            gt_row_efd_reinf_r2060.dm_st_proc       := 0;  -- 0-Aberto
            gt_row_efd_reinf_r2060.loteefdreinf_id  := null;
            --
            vn_fase := 8;
            --
            pk_csf_api_reinf.pkb_integr_efdreinfr2060 ( est_log_generico_reinf => vt_log_generico_reinf
                                                      , est_row_efdreinfr2060  => gt_row_efd_reinf_r2060
                                                      , en_empresa_id          => gt_row_geracao_efd_reinf.empresa_id
                                                      );
            --
            vn_fase := 9;
            --
            if nvl(vt_log_generico_reinf.count,0) > 0 then
               --
               update efd_reinf_r2060
                  set dm_st_proc = 2
                where id = gt_row_efd_reinf_r2060.id;
               --
            else
               --
               update efd_reinf_r2060
                  set dm_st_proc = 1
                where id = gt_row_efd_reinf_r2060.id;
               --
            end if;
            --
         else
            --
            pk_csf_api_reinf.gv_mensagem_log := 'Está sendo reenviado um evento R-2060 ( efdreinfr2060_id = '|| vt_efd_reinf_r2060.id ||') antigo, já existe um novo evento criado para o grupo, Favor Verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                    , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                    , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                    , en_tipo_log             => INFORMACAO
                                                    , en_referencia_id        => vt_efd_reinf_r2060.id
                                                    , ev_obj_referencia       => 'EFD_REINF_R2060'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
         end if;
         --
      else
         --
         pk_csf_api_reinf.gv_mensagem_log := 'Situação "'|| pk_csf.fkg_dominio ( 'EFD_REINF_R2060.DM_ST_PROC', vt_efd_reinf_r2060.dm_st_proc ) ||'" do Evento R-2060 (efdreinfr2060_id = '||vt_efd_reinf_r2060.id||') não é permitido a geração do evento de reenvio';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => vt_efd_reinf_r2060.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2060'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
      end if;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_reenviar_evt_r2060 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => vt_efd_reinf_r2060.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2060'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_reenviar_evt_r2060;

----------------------------------------------------------------------------------------------------
-- Procedimento verifica se o registro ja possui Evento R-2060
procedure pkb_exist_evt_r2060( en_apurcprbempr_id in apur_cprb_empr.id%type
                             )
is
   --
   vt_log_generico_reinf           dbms_sql.number_table;
   vn_fase                         number;
   --
   vn_efdreinfr2060_id             efd_reinf_r2060.id%type;
   vn_dm_tipo_reg                  efd_reinf_r2060.dm_tipo_reg%type;
   vn_dm_st_proc                   efd_reinf_r2060.dm_st_proc%type;
   vn_loggenericoreinf_id          log_generico_reinf.id%type;
   vv_mensagem                     log_generico_reinf.mensagem%type;
   --
   vn_empresa_id                   apur_cprb_empr.empresa_id%type;
   vd_dt_ini                       apur_cprb.dt_ini%type;
   vd_dt_fin                       apur_cprb.dt_fin%type;
   vn_tipo                         apur_cprb_empr.dm_tipo%type;
   --
begin
   --
   vn_fase := 1;
   --
   gt_row_efd_reinf_r2060 := null;
   vt_log_generico_reinf.delete;
   --
   vn_loggenericoreinf_id := null;
   vn_empresa_id          := null;
   vd_dt_ini              := null;
   vd_dt_fin              := null;
   vn_tipo                := null;
   --
   vn_fase := 2;
   -- Verificar se ja existe Evento para o Indice de dentro do Periodo
   begin
      --
      select id
           , dm_tipo_reg
           , dm_st_proc
        into vn_efdreinfr2060_id
           , vn_dm_tipo_reg
           , vn_dm_st_proc
        from efd_reinf_r2060
       where id in ( select max(id)
                       from efd_reinf_r2060 err
                      where err.apurcprbempr_id = en_apurcprbempr_id 
                        and err.dm_st_proc     in (0,1,3,4,7,8) ); -- 0-Aberto; 1-Validado; 3-Aguardando Envio; 4-Processado; 7-Excluído; 8-Processado R-5001
      --
   exception
    when others then
      vn_efdreinfr2060_id := null;
      vn_dm_tipo_reg      := null;
      vn_dm_st_proc       := null;
   end;
   --
   vn_fase := 3;
   --
   gt_row_efd_reinf_r2060.id                   := null;
   gt_row_efd_reinf_r2060.geracaoefdreinf_id   := gt_row_geracao_efd_reinf.id;   
   gt_row_efd_reinf_r2060.apurcprbempr_id      := en_apurcprbempr_id;
   gt_row_efd_reinf_r2060.dm_st_proc           := 0;
   gt_row_efd_reinf_r2060.ar_efdreinfr2060_id  := null;
   --
   vn_fase := 4;
   --
   if nvl(vn_efdreinfr2060_id,0) > 0 then
      --
      vn_fase := 4.1;
      --
      begin
         -- Recupera os dados da receita de espetáculo desportivo
         select ace.empresa_id
              , ac.dt_ini
              , ac.dt_fin
              , ace.dm_tipo
           into vn_empresa_id
              , vd_dt_ini
              , vd_dt_fin
              , vn_tipo
           from apur_cprb      ac
              , apur_cprb_empr ace
          where ace.apurcprb_id  = ac.id
            and ac.id = en_apurcprbempr_id;
         --
      exception
         when others then
            vn_empresa_id   := null;
            vd_dt_ini       := null;
            vd_dt_fin       := null;
            vn_tipo         := null;
      end;
      --
      vn_fase := 4.2;
      --
      if vn_dm_st_proc in (0,1,3) then -- 0-Aberto; 1-Validado; 3-Aguardando Envio
         --
         vv_mensagem := 'O último evento R-2060 referente apuração de contribuição previdenciária sobre a receita bruta da empresa '||
                        pk_csf.fkg_codpart_empresaid(vn_empresa_id)||' data de inicial '||to_char(vd_dt_ini, 'dd/mm/yyyy')||' data de final '||
                        to_char(vd_dt_fin, 'dd/mm/yyyy')||' tipo "'||pk_csf.fkg_dominio('APUR_CPRB_EMPR.DM_TIPO', vn_tipo)||
                        ' está com o tipo de registro "'||pk_csf.fkg_dominio('EFD_REINF_R2060.DM_TIPO_REG', vn_dm_tipo_reg)||
                        '" e com a situação "'||pk_csf.fkg_dominio('EFD_REINF_R2060.DM_ST_PROC', vn_dm_st_proc)||
                        '". Neste caso, não poderá ser gerado um novo evento R-2060. Favor verificar.';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_resumo || vv_mensagem
                                                 , ev_resumo               => vv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         goto sair_geral;
         --
      elsif vn_dm_st_proc in (4,8) then -- 4-Processado; 8-Processado R-5001
         --
         gt_row_efd_reinf_r2060.dm_tipo_reg         := 2; -- 2-Retificado
         gt_row_efd_reinf_r2060.ar_efdreinfr2060_id := vn_efdreinfr2060_id;
         --
      elsif vn_dm_st_proc = 7 then -- 7-Excluído
         --
         gt_row_efd_reinf_r2060.dm_tipo_reg := 1; -- 1-Original
         --
      end if;
      --
   else
      --
      vn_fase := 4.2;
      --
      gt_row_efd_reinf_r2060.dm_tipo_reg := 1; --Original
      --
   end if;
   --
   vn_fase := 5;
   -- Gravar Evento Criado no Banco de Dados
   pk_csf_api_reinf.pkb_integr_efdreinfr2060 ( est_log_generico_reinf => vt_log_generico_reinf
                                             , est_row_efdreinfr2060  => gt_row_efd_reinf_r2060
                                             , en_empresa_id          => gt_row_geracao_efd_reinf.empresa_id
                                             );
   --
   vn_fase := 6;
   -- Gerar o ID para o evento criado
   pkb_gera_id_evt_reinf ( ev_obj_referencia => 'EFD_REINF_R2060'
                         , en_referencia_id  => gt_row_efd_reinf_r2060.id
                         );
   --
   vn_fase := 7;
   --
   if nvl(vt_log_generico_reinf.count,0) > 0 then
      --
      update efd_reinf_r2060
         set dm_st_proc = 2 -- Erro de Validação
       where id = gt_row_efd_reinf_r2060.id;
      --
   else
      --
      update efd_reinf_r2060
         set dm_st_proc = 1 -- Validado
       where id = gt_row_efd_reinf_r2060.id;
      --
   end if;
   --
   <<sair_geral>>
   --
   null;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_exist_evt_r2060 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_exist_evt_r2060;

----------------------------------------------------------------------------------------------------
-- Procedimento que monta o array do evento R-2060
procedure pkb_monta_array_r2060 ( en_empresa_id in empresa.id%type
                                )
is
   --
   vn_fase               number;
   vn_loggenerico_id     log_generico.id%type;
   vb_achou              boolean;
   --
   vn_indx1              number;
   --
   -- Cursor para recuperar as apurações de contribuição previdenciárias relacionadas as empresas filiais
   cursor c_rep ( en_empresa_id number ) is
   select ace.*
     from apur_cprb ac
        , apur_cprb_empr ace
    where ac.empresa_id   = en_empresa_id
      and ac.dt_ini       = trunc(gt_row_geracao_efd_reinf.dt_ini)
      and ac.dt_fin       = trunc(gt_row_geracao_efd_reinf.dt_fin)
      and ace.apurcprb_id = ac.id
      and ace.dm_situacao = 3  -- Processado
      and ace.dm_envio    = 0; -- Não Enviado
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_rep(en_empresa_id)loop
      exit when c_rep%notfound or (c_rep%notfound) is null;
      --
      vn_fase := 2;
      --
      vn_indx1 := null;
      --
      vn_indx1 := nvl(rec.empresa_id,0);
      --
      begin
         vb_achou := vt_tab_index_evt_r2060.exists(vn_indx1);
      exception
         when others then
            vb_achou := false;
      end;
      --
      vn_fase := 3;
      --
      if not vb_achou then
         --
         vn_fase := 3.1;
         --
         vt_tab_index_evt_r2060(vn_indx1).empresa_id      := rec.empresa_id;
         vt_tab_index_evt_r2060(vn_indx1).apurcprbempr_id := rec.id;
         --
      else
         --
         vn_fase := 4;
         --
         gv_mensagem := 'Existe mais de uma apuração de contribuição previdenciária sobre a receita bruta por estabelecimento e no momento o EFD-REINF '||
                        'aceita apenas uma apuração por período. Favor verificar para que seja gerado o evento R-2060';
         --
         declare
            vn_loggenerico_id  log_generico.id%type;
         begin
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                    , ev_mensagem             => gv_resumo || gv_mensagem
                                                    , ev_resumo               => gv_mensagem
                                                    , en_tipo_log             => ERRO_DE_SISTEMA
                                                    , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                    , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
         exception
            when others then
               null;
         end;
         --
         -- Abortar Processo de geração do evento R-2060
         vt_tab_index_evt_r2060.delete;
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_monta_array_r2060 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_monta_array_r2060;

---------------------------------------------------------------------------------------------------
-- Processo que verifica se existe evento dentro do periodo para a Empresa Matriz/Filial
procedure pkb_gera_evt_r2060
is
   --
   vn_fase                  number;
   vn_ind1                  number;
   --
   cursor c_empr is
   select em.id empresa_id
     from empresa em
    where dm_situacao = 1 -- Ativo
    start with em.id = gt_row_geracao_efd_reinf.empresa_id
  connect by prior em.id = em.ar_empresa_id;
   --
begin
   --
   vn_fase := 1;
   --
   i := null;
   vt_tab_index_evt_r2060.delete;
   --
   vn_fase := 2;
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 3;
      --
      pkb_monta_array_r2060 ( rec.empresa_id );
      --
   end loop;
   --
   vn_fase := 4;
   --
   vn_ind1:= nvl(vt_tab_index_evt_r2060.first,0);
   --
   vn_fase := 5;
   --
   loop
      --
      vn_fase := 6;
      --
      if nvl(vn_ind1,0) = 0 then -- índice = empresa_id e dm_ind_obra
         exit;
      end if;
      --
      vn_fase := 7;
      --
      pkb_exist_evt_r2060( en_apurcprbempr_id => vt_tab_index_evt_r2060(vn_ind1).apurcprbempr_id
                         );
      --
      vn_fase := 8;
      --
      if vn_ind1 = vt_tab_index_evt_r2060.last then
         exit;
      else
         vn_ind1 := vt_tab_index_evt_r2060.next(vn_ind1);
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_gera_evt_r2060 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_gera_evt_r2060;

---------------------------------------------------------------------------------------------------
-- Procedimento que cria um novo evento de Reenvio para os eventos com Erro no Envio ou Erro na montagem do XML
procedure pkb_reenviar_evt_r2050 ( en_efdreinfr2050_id in efd_reinf_r2050.id%type
                                 )
is
   --
   vn_fase                      number;
   vn_loggenericoreinf_id       log_generico_reinf.id%type;
   vn_efdreinfr2050_last_id     efd_reinf_r2050.id%type;
   --
   vt_efd_reinf_r2050           efd_reinf_r2050%rowtype;
   vt_log_generico_reinf        dbms_sql.number_table;
   --
begin
   --
   vn_fase := 1;
   --
   vt_efd_reinf_r2050     := null;
   vn_loggenericoreinf_id := null;
   --
   if nvl(en_efdreinfr2050_id,0) > 0 then
      --
      vn_fase := 2;
      --
      begin
         --
         select *
           into vt_efd_reinf_r2050
           from efd_reinf_r2050
          where id = en_efdreinfr2050_id;
         --
      exception
       when others then
         vt_efd_reinf_r2050 := null;
      end;
      --
      vn_fase := 3;
      -- Recupera os dados da Abertura do EFD-REINF
      pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => vt_efd_reinf_r2050.geracaoefdreinf_id );
      --
      delete log_generico_reinf
       where obj_referencia = 'EFD_REINF_R2050'
         and referencia_id  = gt_row_geracao_efd_reinf.id;
      --
      vn_fase := 4;
      --
      if nvl(vt_efd_reinf_r2050.id, 0) > 0
         and vt_efd_reinf_r2050.dm_st_proc in (5,6) then -- 5-Erro no Envio; 6-Erro na montagem do XML
         --
         vn_fase := 5;
         --
         vn_efdreinfr2050_last_id := null;
         -- Verificar se este é o último evento do grupo do R-2050
         begin
            --
            select max(id)
              into vn_efdreinfr2050_last_id
              from efd_reinf_r2050
             where comerprodruralpjagr_id = vt_efd_reinf_r2050.comerprodruralpjagr_id
               and geracaoefdreinf_id     = vt_efd_reinf_r2050.geracaoefdreinf_id;
            --
         exception
          when others then
             vn_efdreinfr2050_last_id := null;
         end;
         --
         vn_fase := 6;
         --
         if nvl(vn_efdreinfr2050_last_id,0) = nvl(vt_efd_reinf_r2050.id,0) then
            --
            vn_fase := 7;
            --
            gt_row_efd_reinf_r2050 := vt_efd_reinf_r2050;
            --
            gt_row_efd_reinf_r2050.dm_st_proc      := 0; -- 0-Aberto.
            gt_row_efd_reinf_r2050.loteefdreinf_id := null;
            --
            vn_fase := 8;
            --
            pk_csf_api_reinf.pkb_integr_efdreinfr2050 ( est_log_generico_reinf => vt_log_generico_reinf
                                                      , est_row_efdreinfr2050  => gt_row_efd_reinf_r2050
                                                      , en_empresa_id          => gt_row_geracao_efd_reinf.empresa_id
                                                      );
            --
            vn_fase := 9;
            -- 
            if nvl(vt_log_generico_reinf.count,0) > 0 then
               --
               update efd_reinf_r2050
                  set dm_st_proc = 2
                where id = gt_row_efd_reinf_r2050.id;
               --
            else
               --
               update efd_reinf_r2050
                  set dm_st_proc = 1
                where id = gt_row_efd_reinf_r2050.id;
               --
            end if;
            --
         else
            --
            pk_csf_api_reinf.gv_mensagem_log := 'Está sendo reenviado um evento R-2050 ( efdreinfr2050_id = '|| vt_efd_reinf_r2050.id ||') antigo, já existe um novo evento criado para o grupo, Favor Verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                    , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                    , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                    , en_tipo_log             => INFORMACAO
                                                    , en_referencia_id        => vt_efd_reinf_r2050.id
                                                    , ev_obj_referencia       => 'EFD_REINF_R2050'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
         end if;
         --
      else
         --
         pk_csf_api_reinf.gv_mensagem_log := 'Situação "'|| pk_csf.fkg_dominio ( 'EFD_REINF_R2050.DM_ST_PROC', vt_efd_reinf_r2050.dm_st_proc ) ||'" do evento R-2050 (efdreinfr2050_id = '||vt_efd_reinf_r2050.id||') não é permitido a geração do evento de reenvio';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => vt_efd_reinf_r2050.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2050'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
      end if;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_reenviar_evt_r2050 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => vt_efd_reinf_r2050.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2050'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_reenviar_evt_r2050;

---------------------------------------------------------------------------------------------------
-- Processo que verifica se existe evento dentro do periodo para a Empresa
procedure pkb_exist_evt_r2050( en_empresa_id in empresa.id%type
                             )
is
   --
   vn_fase                         number;
   vt_log_generico_reinf           dbms_sql.number_table;
   vn_ind2                         number;
   --
   vn_efdreinfr2050_id             efd_reinf_r2050.id%type;
   vn_dm_tipo_reg                  efd_reinf_r2050.dm_tipo_reg%type;
   vn_dm_st_proc                   efd_reinf_r2050.dm_st_proc%type;
   vn_loggenericoreinf_id          log_generico_reinf.id%type;
   vv_mensagem                     log_generico_reinf.mensagem%type;
   --
   vn_empresa_id                   comer_prod_rural_pj_agr.empresa_id%type;
   vd_dt_ref                       comer_prod_rural_pj_agr.dt_ref%type;
   --
begin
   --
   vn_fase := 1;
   --
   vn_ind2:= nvl(vt_bi_tab_indx_evt_r2050_comer(en_empresa_id).first,0);
   --
   loop
      --
      vn_fase := 2;
      --
      gt_row_efd_reinf_r2050 := null;
      vt_log_generico_reinf.delete;
      --
      vn_empresa_id          := null;
      vd_dt_ref              := null;
      vn_efdreinfr2050_id    := null;
      vn_dm_tipo_reg         := null;
      vn_dm_st_proc          := null;
      vn_loggenericoreinf_id := null;
      --
      vn_fase := 3;
      --
      if nvl(vn_ind2,0) = 0 then -- índice = empresa_id e comerprodruralpjagr_id
         exit;
      end if;
      --
      vn_fase := 4;
      --
      -- Verificar se ja existe Evento para o Indice de dentro do Periodo
      begin
         --
         select id
              , dm_tipo_reg
              , dm_st_proc
           into vn_efdreinfr2050_id
              , vn_dm_tipo_reg
              , vn_dm_st_proc
           from efd_reinf_r2050
          where id in ( select max(err.id)
                          from efd_reinf_r2050 err
                         where err.comerprodruralpjagr_id = vt_bi_tab_indx_evt_r2050_comer(en_empresa_id)(vn_ind2).comerprodruralpjagr_id -- Estab. Matriz/Filial
                           and err.geracaoefdreinf_id     = gt_row_geracao_efd_reinf.id 
                           and err.dm_st_proc            in (0,1,3,4,7,8) ); -- 0-Aberto; 1-Validado; 3-Aguardando Envio; 4-Processado; 7-Excluído; 8-Processado R-5001
         --
      exception
       when others then
         vn_efdreinfr2050_id := null;
         vn_dm_tipo_reg      := null;
         vn_dm_st_proc       := null;
      end;
      --
      vn_fase := 5;
      --
      gt_row_efd_reinf_r2050.id                     := null;
      gt_row_efd_reinf_r2050.geracaoefdreinf_id     := gt_row_geracao_efd_reinf.id;
      gt_row_efd_reinf_r2050.dm_st_proc             := 0; -- 0-Aberto
      gt_row_efd_reinf_r2050.comerprodruralpjagr_id := vt_bi_tab_indx_evt_r2050_comer(en_empresa_id)(vn_ind2).comerprodruralpjagr_id;
      gt_row_efd_reinf_r2050.ar_efdreinfr2050_id    := null;
      --
      vn_fase := 6;
      --
      if nvl(vn_efdreinfr2050_id,0) > 0 then
         --
         vn_fase := 6.1;
         --
         begin
            --
            select empresa_id
                 , dt_ref
              into vn_empresa_id
                 , vd_dt_ref
              from comer_prod_rural_pj_agr
             where id = vt_bi_tab_indx_evt_r2050_comer(en_empresa_id)(vn_ind2).comerprodruralpjagr_id;
            --
         exception
            when others then
               vn_empresa_id := null;
               vd_dt_ref     := null;
         end;
         --
         vn_fase := 6.2;
         --
         if vn_dm_st_proc in (0,1,3) then -- 0-Aberto; 1-Validado; 3-Aguardando Envio
            --
            vv_mensagem := 'O último evento R-2050 referente a comercialização de produção rural da empresa '||pk_csf.fkg_codpart_empresaid(vn_empresa_id)||
                           ' data de referência '||to_char(vd_dt_ref, 'dd/mm/yyyy')||' está com o tipo de registro "'||pk_csf.fkg_dominio('EFD_REINF_R2050.DM_TIPO_REG', vn_dm_tipo_reg)||
                           '" e com a situação "'||pk_csf.fkg_dominio('EFD_REINF_R2050.DM_ST_PROC', vn_dm_st_proc)||
                           '". Neste caso, não poderá ser gerado um novo evento R-2050. Favor verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                    , ev_mensagem             => gv_resumo || vv_mensagem
                                                    , ev_resumo               => vv_mensagem
                                                    , en_tipo_log             => INFORMACAO
                                                    , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                    , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
            goto proximo_ind;
            --
         elsif vn_dm_st_proc in (4,8) then -- 4-Processado; 8-Processado R-5001
            --
            gt_row_efd_reinf_r2050.dm_tipo_reg         := 2; -- 2-Retificado
            gt_row_efd_reinf_r2050.ar_efdreinfr2050_id := vn_efdreinfr2050_id;
            --
         elsif vn_dm_st_proc = 7 then -- 7-Excluído
            --
            gt_row_efd_reinf_r2050.dm_tipo_reg := 1; -- 1-Original
            --
         end if;
         --
      else
         --
         vn_fase := 6.2;
         --
         gt_row_efd_reinf_r2050.dm_tipo_reg := 1; --Original
         --
      end if;
      --
      vn_fase := 7;
      -- Gravar Evento Criado no Banco de Dados
      pk_csf_api_reinf.pkb_integr_efdreinfr2050 ( est_log_generico_reinf => vt_log_generico_reinf
                                                , est_row_efdreinfr2050  => gt_row_efd_reinf_r2050
                                                , en_empresa_id          => gt_row_geracao_efd_reinf.empresa_id
                                                );
      --
      vn_fase := 8;
      --
      if nvl(gt_row_efd_reinf_r2050.id,0) > 0 then
         --
         vn_fase := 9;
         -- Gerar o ID para o evento criado
         pkb_gera_id_evt_reinf ( ev_obj_referencia => 'EFD_REINF_R2050'
                               , en_referencia_id  => gt_row_efd_reinf_r2050.id
                               );
         --
         vn_fase := 10;
         --
         if nvl(vt_log_generico_reinf.count,0) > 0 then
            --
            update efd_reinf_r2050
               set dm_st_proc = 2 -- Erro de Validação
             where id = gt_row_efd_reinf_r2050.id;
            --
         else
            --
            update efd_reinf_r2050
               set dm_st_proc = 1 -- Validado
             where id = gt_row_efd_reinf_r2050.id;
            --
         end if;
         --
      end if;
      --
      vn_fase := 11;
      --
      <<proximo_ind>>
      --
      vn_fase := 12;
      --
      if vn_ind2 = vt_bi_tab_indx_evt_r2050_comer(en_empresa_id).last then
         exit;
      else
         vn_ind2 := vt_bi_tab_indx_evt_r2050_comer(en_empresa_id).next(vn_ind2);
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_exist_evt_r2050 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_exist_evt_r2050;

---------------------------------------------------------------------------------------------------
-- Procedimento que Monta array do Evento R-2050
procedure pkb_monta_array_r2050 ( en_empresa_id in empresa.id%type )
is
   --
   vn_fase               number;
   vn_loggenerico_id     log_generico.id%type;
   vb_achou              boolean;
   --
   vn_indx1              number;
   --
   -- Cursor para recuperar as comercializações da produção por produtor rural PJ/Agroindústria relacionadas as empresas filiais
   cursor c_comer ( en_empresa_id number ) is
   select id
        , empresa_id
     from comer_prod_rural_pj_agr
    where empresa_id = en_empresa_id
      and dt_ref     between gt_row_geracao_efd_reinf.dt_ini and gt_row_geracao_efd_reinf.dt_fin
      and dm_envio   = 0 -- Não Enviado
      and dm_st_proc = 1;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_comer(en_empresa_id)loop
      exit when c_comer%notfound or (c_comer%notfound) is null;
      --
      vn_fase := 2;
      --
      vn_indx1 := null;
      --
      vn_indx1 := nvl(rec.empresa_id,0);
      --
      begin
         vb_achou := vt_tab_index_evt_r2050.exists(vn_indx1);
      exception
         when others then
            vb_achou := false;
      end;
      --
      vn_fase := 3;
      --
      if not vb_achou then
         --
         vn_fase := 4;
         --
         vn_fase := 3.1;
         --
         vt_tab_index_evt_r2050(vn_indx1).empresa_id := rec.empresa_id;
         --
         vt_bi_tab_indx_evt_r2050_comer(vn_indx1)(rec.id).comerprodruralpjagr_id := rec.id;
         --
      else
         --
         vt_bi_tab_indx_evt_r2050_comer(vn_indx1)(rec.id).comerprodruralpjagr_id := rec.id;
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_monta_array_r2050 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_monta_array_r2050;

---------------------------------------------------------------------------------------------------
-- Processo de Geração de Evento R-2050 - Comercialização da Produção por Produtor Rural PJ/Agroindústria
procedure pkb_gera_evt_r2050
is
   --
   vn_fase                  number;
   vn_ind1                  number;
   --
   cursor c_empr is
   select em.id empresa_id
     from empresa em
    where dm_situacao = 1 -- Ativo
    start with em.id = gt_row_geracao_efd_reinf.empresa_id
  connect by prior em.id = em.ar_empresa_id;
   --
begin
   --
   vn_fase := 1;
   --
   i := null;
   vt_bi_tab_indx_evt_r2050_comer.delete;
   vt_tab_index_evt_r2050.delete;
   --
   vn_fase := 2;
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 3;
      -- O evento R-2050 deve ser gerado apenas da Empresa Matriz
      pkb_monta_array_r2050 ( rec.empresa_id );
      --
   end loop;
   --
   vn_fase := 4;
   --
   vn_ind1:= nvl(vt_tab_index_evt_r2050.first,0);
   --
   vn_fase := 5;
   --
   -- Manter o mesmo estilo de geração dos demais evento por conta 
   -- de caso futuramente o evento para a ser declarado por empresa filial tambem
   -- ja existe boa parte do processo pronto.
   loop
      --
      vn_fase := 6;
      --
      if nvl(vn_ind1,0) = 0 then -- índice = empresa_id e dm_ind_obra
         exit;
      end if;
      --
      vn_fase := 7;
      --
      pkb_exist_evt_r2050( en_empresa_id => vt_tab_index_evt_r2050(vn_ind1).empresa_id );
      --
      vn_fase := 8;
      --
      if vn_ind1 = vt_tab_index_evt_r2050.last then
         exit;
      else
         vn_ind1 := vt_tab_index_evt_r2050.next(vn_ind1);
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_gera_evt_r2050 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_gera_evt_r2050;

---------------------------------------------------------------------------------------------------
-- Procedimento que recupera e relaciona os recursos repassados por associação desportiva do evento anterior com o novo evento gerado
procedure pkb_rec_evt_anterior_r2040 ( est_log_generico_reinf  in out nocopy dbms_sql.number_table
                                     , en_efdreinfr2040_old_id in            efd_reinf_r2040.id%type
                                     , en_efdreinfr2040_new_id in            efd_reinf_r2040.id%type
                                     )
is
   --
   vn_fase                        number;
   --
   cursor c_r2040 is
   select *
     from r_efdreinfr2040_recrep
    where efdreinfr2040_id = en_efdreinfr2040_old_id;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_r2040 loop
      exit when c_r2040%notfound or (c_r2040%notfound) is null;
      --
      vn_fase := 2;
      --
      gt_row_efdreinfr2040_recrep := null;
      --
      gt_row_efdreinfr2040_recrep.recrepassdesp_id := rec.recrepassdesp_id;
      gt_row_efdreinfr2040_recrep.efdreinfr2040_id := en_efdreinfr2040_new_id;
      --
      vn_fase := 3;
      --
      pk_csf_api_reinf.pkb_integr_efdreinfr2040_rep ( est_log_generico_reinf       => est_log_generico_reinf
                                                    , est_row_efdreinfr2040_rep    => gt_row_efdreinfr2040_recrep
                                                    , en_empresa_id                => gt_row_geracao_efd_reinf.empresa_id
                                                    );
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_rec_evt_anterior_r2040 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id                    
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_rec_evt_anterior_r2040; 

---------------------------------------------------------------------------------------------------
-- Procedimento de retificação do recurso repassado para associação desportiva do Evento R-2040
procedure pkb_retif_evt_r2040 ( en_efdreinfr2040_id   in efd_reinf_r2040.id%type
                              , en_recrepassdesp_id   in rec_rep_ass_desp.id%type
                              )
is
   --
   vn_fase                           number;
   vn_loggenerico_id                 log_generico_reinf.id%type;
   vt_log_generico_reinf             dbms_sql.number_table;
   --
   vv_mensagem_log                   log_generico_reinf.mensagem%type;
   vv_resumo_log                     log_generico_reinf.resumo%type;
   vt_efd_reinf_r2040                efd_reinf_r2040%rowtype;
   vt_efd_reinf_r2040_new            efd_reinf_r2040%rowtype;
   vn_efdreinfr2040_last_id          efd_reinf_r2040.id%type;
   vn_cont_reg                       number;
   --
begin
   --
   vn_fase := 1;
   --
   vt_efd_reinf_r2040       := null;
   vt_efd_reinf_r2040_new   := null;
   vn_efdreinfr2040_last_id := null;
   vn_cont_reg              := null;
   --
   vn_fase := 2;
   --
   begin
      --
      select *
        into vt_efd_reinf_r2040
        from efd_reinf_r2040
       where id = en_efdreinfr2040_id;
      --
   exception
    when others then
      vt_efd_reinf_r2040 := null;
   end;
   --
   vn_fase := 3;
   --
   -- Recupera os dados da Abertura do EFD-REINF
   pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => vt_efd_reinf_r2040.geracaoefdreinf_id );
   --
   if nvl(gt_row_geracao_efd_reinf.dm_situacao, 0) = 2 then  -- 2-Aberto
      --
      if nvl(vt_efd_reinf_r2040.id,0) > 0 then
         --
         vn_fase := 4;
         --
         vv_resumo_log := 'Procedimento de Retificação do Evento R-2040 (Recurso Repassados para Associação Desportiva) do Estabelecimento: '||
                          pk_csf.fkg_cod_nome_empresa_id ( vt_efd_reinf_r2040.empresa_id )|| ', no período de '||
                          trim(to_char(gt_row_geracao_efd_reinf.dt_ini, 'month')) || ' de ' ||
                          to_char(gt_row_geracao_efd_reinf.dt_ini,'yyyy');
         --
         vn_fase := 5;
         --
         delete log_generico_reinf
          where obj_referencia = 'EFD_REINF_R2040'
            and referencia_id  = vt_efd_reinf_r2040.id;
         --
         vn_fase := 6;
         --
         if vt_efd_reinf_r2040.dm_st_proc in (4,8) then -- 4-Processado; 8-Processado R-5001
            --
            vn_fase := 7;
            -- Conta o número de recursos repassados para associação desportiva que estão relacionados ao evento R-2040
            begin
               --
               select count(*)
                 into vn_cont_reg
                 from r_efdreinfr2040_recrep
                where efdreinfr2040_id = vt_efd_reinf_r2040.id;
               --
            exception
               when others then
                  --
                  vn_cont_reg := 0;
                  --
            end;
            --
            vn_fase := 8;
            -- Se o evento estiver relacionado a apenas um recurso repassado para associação desportiva e o mesmo estiver sendo retificado,
            -- o processo deverá gerar o evento de exclusão R-9000
            if nvl(vn_cont_reg, 0) = 1 then
               --
               vn_fase := 9;
               -- Cria o evento de exclusão R-9000 para o evento R-2040
               pk_desfazer_dados_reinf.pkb_excluir_evt_r2040(vt_efd_reinf_r2040.id);
               --
            else
               --
               vn_fase := 10;
               -- Recupera o ID do último evento do grupo R-2040
               begin
                  --
                  select id
                    into vn_efdreinfr2040_last_id
                    from efd_reinf_r2040
                   where id in ( select max(id)
                                   from efd_reinf_r2040
                                  where empresa_id         = vt_efd_reinf_r2040.empresa_id
                                    and geracaoefdreinf_id = vt_efd_reinf_r2040.geracaoefdreinf_id );
                  --
               end;
               --
               vn_fase := 11;
               --
               if nvl(vn_efdreinfr2040_last_id, 0) = nvl(vt_efd_reinf_r2040.id, 0) then
                  --
                  vt_efd_reinf_r2040_new.id                   := null;
                  vt_efd_reinf_r2040_new.geracaoefdreinf_id   := vt_efd_reinf_r2040.geracaoefdreinf_id;
                  vt_efd_reinf_r2040_new.empresa_id           := vt_efd_reinf_r2040.empresa_id;
                  vt_efd_reinf_r2040_new.dm_st_proc           := 0; -- 0-Aberto
                  vt_efd_reinf_r2040_new.dm_tipo_reg          := 2; -- 2-Retificado
                  vt_efd_reinf_r2040_new.ar_efdreinfr2040_id  := vt_efd_reinf_r2040.id;
                  --
                  vn_fase := 12;
                  -- Cria o novo evento R-2040
                  pk_csf_api_reinf.pkb_integr_efdreinfr2040 ( est_log_generico_reinf  => vt_log_generico_reinf
                                                            , est_row_efdreinfr2040   => vt_efd_reinf_r2040_new
                                                            , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                            );
                  --
                  vn_fase := 13;
                  --
                  if nvl(vt_efd_reinf_r2040_new.id, 0) > 0 then
                     -- Recupera e relaciona os recursos repassados para associação desportiva do evento anterior com o novo evento gerado
                     pkb_rec_evt_anterior_r2040 ( est_log_generico_reinf  => vt_log_generico_reinf
                                                , en_efdreinfr2040_old_id => vt_efd_reinf_r2040.id
                                                , en_efdreinfr2040_new_id => vt_efd_reinf_r2040_new.id
                                                );
                     --
                     vn_fase := 14;
                     --Exclui o recurso repassado para associação desportiva "retificado" do novo evento R-2040
                     delete r_efdreinfr2040_recrep
                      where efdreinfr2040_id = vt_efd_reinf_r2040_new.id
                        and recrepassdesp_id = en_recrepassdesp_id;  --Recurso repassado para associação desportiva "retificado"
                     --
                     vn_fase := 15;
                     -- Atualiza a situação "dm_envio = 0" para o recurso repassado para associação desportiva "retificado"
                     update rec_rep_ass_desp
                        set dm_envio = 0               -- 0-Não enviado
                      where id = en_recrepassdesp_id;  -- Recurso repassado para associação desportiva "retificado"
                     --
                  end if;
                  --
                  vn_fase := 16;
                  --
                  if nvl(vt_log_generico_reinf.count,0) = 0 then
                     --
                     update efd_reinf_r2040
                        set dm_st_proc = 1 -- Validado
                      where id = vt_efd_reinf_r2040_new.id;
                     --
                  else
                     --
                     update efd_reinf_r2040
                        set dm_st_proc = 2 -- Erro de validação
                      where id = vt_efd_reinf_r2040_new.id;
                     --
                  end if;
                  --
                  vn_fase := 17;
                  --
                  -- Gerar o ID para o novo evento criado
                  pkb_gera_id_evt_reinf ( ev_obj_referencia => 'EFD_REINF_R2040'
                                        , en_referencia_id  => gt_row_efd_reinf_r2040.id
                                        );
                  --
               else
                  --
                  vn_fase := 18;
                  --
                  vv_mensagem_log := 'Evento não pode ser retificado pois não é o último evento gerado para o grupo de informação, favor verificar.';
                  --
                  pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                          , ev_mensagem             => vv_resumo_log ||' '|| vv_mensagem_log
                                                          , ev_resumo               => vv_mensagem_log
                                                          , en_tipo_log             => pk_csf_api_reinf.informacao
                                                          , en_referencia_id        => vt_efd_reinf_r2040.id
                                                          , ev_obj_referencia       => 'EFD_REINF_R2040'
                                                          , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                          );
                  --
               end if;
               --
            end if;
            --
         else  -- 0-Aberto; 1-Validado; 2-Erro de Validação; 3-Aguardando Envio; 5-Erro no Envio; 6-Erro na montagem do XML; 7-Excluído
            --
            vn_fase := 19;
            --
            vv_mensagem_log := 'O evento R-2040 não pode ser retificado pois está com o tipo de registro "'||
                               pk_csf.fkg_dominio('EFD_REINF_R2040.DM_TIPO_REG', vt_efd_reinf_r2040.dm_tipo_reg)||
                               '" e com a situação "'||pk_csf.fkg_dominio('EFD_REINF_R2040.DM_ST_PROC', vt_efd_reinf_r2040.dm_st_proc)||
                               '", favor verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                    , ev_mensagem             => vv_resumo_log ||' '|| vv_mensagem_log
                                                    , ev_resumo               => vv_mensagem_log
                                                    , en_tipo_log             => pk_csf_api_reinf.informacao
                                                    , en_referencia_id        => vt_efd_reinf_r2040.id
                                                    , ev_obj_referencia       => 'EFD_REINF_R2040'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
         end if;
         --
      end if;
      --
   else
      --
      vn_fase := 20;
      --
      vv_mensagem_log := 'Evento não pode ser retificado pois a situação do evento é diferente de "Aberto", favor verificar.';
      --
      pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                              , ev_mensagem             => vv_resumo_log ||' '|| vv_mensagem_log
                                              , ev_resumo               => vv_mensagem_log
                                              , en_tipo_log             => pk_csf_api_reinf.informacao
                                              , en_referencia_id        => vt_efd_reinf_r2040.id
                                              , ev_obj_referencia       => 'EFD_REINF_R2040'
                                              , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                             );
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      pk_csf_api_reinf.gv_mensagem_log := 'Erro na pk_gera_dados_reinf.pkb_retif_evt_r2040 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => vv_resumo_log || pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                 , en_tipo_log             => pk_csf_api_reinf.ERRO_DE_SISTEMA
                                                 , en_referencia_id        => pk_csf_api_reinf.gn_referencia_id
                                                 , ev_obj_referencia       => pk_csf_api_reinf.gv_obj_referencia
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_retif_evt_r2040;

---------------------------------------------------------------------------------------------------
-- Processo que verifica se existe evento dentro do periodo para a Empresa
procedure pkb_reenviar_evt_r2040 ( en_efdreinfr2040_id in efd_reinf_r2040.id%type
                                 )
is
   --
   vn_fase                      number;
   vn_loggenericoreinf_id       log_generico_reinf.id%type;
   vn_efdreinfr2040_last_id     efd_reinf_r2040.id%type;
   --
   vt_efd_reinf_r2040           efd_reinf_r2040%rowtype;
   vt_log_generico_reinf        dbms_sql.number_table;
   --
begin
   --
   vn_fase := 1;
   --
   vt_efd_reinf_r2040     := null;
   vn_loggenericoreinf_id := null;
   --
   if nvl(en_efdreinfr2040_id,0) > 0 then
      --
      vn_fase := 2;
      --
      begin
         --
         select *
           into vt_efd_reinf_r2040
           from efd_reinf_r2040
          where id = en_efdreinfr2040_id;
         --
      exception
       when others then
         vt_efd_reinf_r2040 := null;
      end;
      --
      vn_fase := 3;
      -- Recupera os dados da Abertura do EFD-REINF
      pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => vt_efd_reinf_r2040.geracaoefdreinf_id );
      --
      vn_fase := 4;
      --
      delete log_generico_reinf
       where obj_referencia = 'EFD_REINF_R2040'
         and referencia_id  = gt_row_geracao_efd_reinf.id;
      --
      vn_fase := 5;
      --
      if nvl(vt_efd_reinf_r2040.id, 0) > 0
         and vt_efd_reinf_r2040.dm_st_proc in (5,6) then -- 5-Erro no Envio; 6-Erro na montagem do XML
         --
         vn_fase := 6;
         --
         vn_efdreinfr2040_last_id := null;
         -- Verificar se este é o último evento do grupo do R-2040
         begin
            --
            select max(id)
              into vn_efdreinfr2040_last_id
              from efd_reinf_r2040
             where empresa_id         = vt_efd_reinf_r2040.empresa_id
               and geracaoefdreinf_id = vt_efd_reinf_r2040.geracaoefdreinf_id;
            --
         exception
          when others then
             vn_efdreinfr2040_last_id := null;
         end;
         --
         vn_fase := 7;
         --
         if nvl(vn_efdreinfr2040_last_id,0) = nvl(vt_efd_reinf_r2040.id,0) then
            --
            vn_fase := 8;
            --
            gt_row_efd_reinf_r2040 := vt_efd_reinf_r2040;
            --
            gt_row_efd_reinf_r2040.dm_st_proc      := 0; -- Em aberto.
            gt_row_efd_reinf_r2040.loteefdreinf_id := null;
            --
            vn_fase := 9;
            --
            pk_csf_api_reinf.pkb_integr_efdreinfr2040 ( est_log_generico_reinf => vt_log_generico_reinf
                                                      , est_row_efdreinfr2040  => gt_row_efd_reinf_r2040
                                                      , en_empresa_id          => gt_row_geracao_efd_reinf.empresa_id
                                                      );
            --
            vn_fase := 10;
            -- Recupera e relaciona os recursos repassados por associação desportiva do evento anterior com o novo evento gerado
            pkb_rec_evt_anterior_r2040 ( est_log_generico_reinf  => vt_log_generico_reinf
                                       , en_efdreinfr2040_old_id => gt_row_efd_reinf_r2040.id
                                       , en_efdreinfr2040_new_id => gt_row_efd_reinf_r2040.id
                                       );
            --
            if nvl(vt_log_generico_reinf.count,0) > 0 then
               --
               update efd_reinf_r2040
                  set dm_st_proc = 2
                where id = gt_row_efd_reinf_r2040.id;
               --
            else
               --
               update efd_reinf_r2040
                  set dm_st_proc = 1
                where id = gt_row_efd_reinf_r2040.id;
               --
            end if;
            --
         else
            --
            pk_csf_api_reinf.gv_mensagem_log := 'Está sendo reenviado um evento R-2040 ( efdreinfr2040_id = '|| vt_efd_reinf_r2040.id ||') antigo, já existe um novo evento criado para o grupo, Favor Verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                    , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                    , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                    , en_tipo_log             => INFORMACAO
                                                    , en_referencia_id        => vt_efd_reinf_r2040.id
                                                    , ev_obj_referencia       => 'EFD_REINF_R2040'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
         end if;
         --
      else
         --
         pk_csf_api_reinf.gv_mensagem_log := 'Situação "'|| pk_csf.fkg_dominio ( 'EFD_REINF_R2040.DM_ST_PROC', vt_efd_reinf_r2040.dm_st_proc ) ||'" do evento R-2040 (efdreinfr2040_id = '||vt_efd_reinf_r2040.id||') não é permitido a geração do evento de reenvio';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => vt_efd_reinf_r2040.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2040'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
      end if;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_reenviar_evt_r2040 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => vt_efd_reinf_r2040.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2040'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_reenviar_evt_r2040;

---------------------------------------------------------------------------------------------------
-- Processo que verifica se existe evento dentro do periodo para a Empresa
procedure pkb_exist_evt_r2040( en_empresa_id in empresa.id%type
                             )
is
   --
   vn_fase                         number;
   vt_log_generico_reinf           dbms_sql.number_table;
   vn_ind2                         number;
   --
   vn_efdreinfr2040_id             efd_reinf_r2040.id%type;
   vn_dm_tipo_reg                  efd_reinf_r2040.dm_tipo_reg%type;
   vn_dm_st_proc                   efd_reinf_r2040.dm_st_proc%type;
   vn_loggenericoreinf_id          log_generico_reinf.id%type;
   vv_mensagem                     log_generico_reinf.mensagem%type;
   --
begin
   --
   vn_fase := 1;
   --
   gt_row_efd_reinf_r2040 := null;
   vt_log_generico_reinf.delete;
   vn_loggenericoreinf_id := null;
   --
   vn_fase := 2;
   -- Verificar se ja existe Evento para o Indice de dentro do Periodo
   begin
      --
      select id
           , dm_tipo_reg
           , dm_st_proc
        into vn_efdreinfr2040_id
           , vn_dm_tipo_reg
           , vn_dm_st_proc
        from efd_reinf_r2040
       where id in ( select max(err.id)
                       from efd_reinf_r2040 err
                      where err.empresa_id         = en_empresa_id -- Estab. Matriz/Filial
                        and err.geracaoefdreinf_id = gt_row_geracao_efd_reinf.id 
                        and err.dm_st_proc         in (0,1,3,4,7,8) ); -- 0-Aberto; 1-Validado; 3-Aguardando Envio; 4-Processado; 7-Excluído; 8-Processado R-5001
      --
   exception
    when others then
      vn_efdreinfr2040_id := null;
      vn_dm_tipo_reg      := null;
      vn_dm_st_proc       := null;
   end;
   --
   vn_fase := 3;
   --
   gt_row_efd_reinf_r2040.id                   := null;
   gt_row_efd_reinf_r2040.geracaoefdreinf_id   := gt_row_geracao_efd_reinf.id;   
   gt_row_efd_reinf_r2040.empresa_id           := en_empresa_id;
   gt_row_efd_reinf_r2040.dm_st_proc           := 0; -- 0-Aberto
   gt_row_efd_reinf_r2040.ar_efdreinfr2040_id  := null;
   --
   vn_fase := 4;
   --
   if nvl(vn_efdreinfr2040_id,0) > 0 then
      --
      vn_fase := 4.1;
      --
      if vn_dm_st_proc in (0,1,3) then -- 0-Aberto; 1-Validado; 3-Aguardando Envio
         --
         vv_mensagem := 'O último evento R-2040 está com o tipo de registro "'||pk_csf.fkg_dominio('EFD_REINF_R2040.DM_TIPO_REG', vn_dm_tipo_reg)||
                        '" e com a situação "'||pk_csf.fkg_dominio('EFD_REINF_R2040.DM_ST_PROC', vn_dm_st_proc)||
                        '". Neste caso, não poderá ser gerado um novo evento R-2040. Favor verificar.';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_resumo || vv_mensagem
                                                 , ev_resumo               => vv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         goto sair_geral;
         --
      elsif vn_dm_st_proc in (4,8) then -- 4-Processado; 8-Processado R-5001
         --
         gt_row_efd_reinf_r2040.dm_tipo_reg         := 2; -- 2-Retificado
         gt_row_efd_reinf_r2040.ar_efdreinfr2040_id := vn_efdreinfr2040_id;
         --
      elsif vn_dm_st_proc = 7 then -- 7-Excluído
         --
         gt_row_efd_reinf_r2040.dm_tipo_reg := 1; -- 1-Original
         --
      end if;
      --
   else
      --
      vn_fase := 4.2;
      --
      gt_row_efd_reinf_r2040.dm_tipo_reg := 1; --Original
      --
   end if;
   --
   vn_fase := 5;
   -- Gravar Evento Criado no Banco de Dados
   pk_csf_api_reinf.pkb_integr_efdreinfr2040 ( est_log_generico_reinf => vt_log_generico_reinf
                                             , est_row_efdreinfr2040  => gt_row_efd_reinf_r2040
                                             , en_empresa_id          => gt_row_geracao_efd_reinf.empresa_id
                                             );
   --
   vn_fase := 6;
   --
   if nvl(gt_row_efd_reinf_r2040.id,0) > 0 then
      --
      vn_fase := 7;
      --
      vn_ind2:= nvl(vt_bi_tab_index_evt_r2040_rep(en_empresa_id).first,0);
      --
      loop
         --
         gt_row_efdreinfr2040_recrep := null;
         --
         if nvl(vn_ind2,0) = 0 then -- índice = empresa_id e recrepassdesp_id
            exit;
         end if;
         --
         vn_fase := 8;
         --
         gt_row_efdreinfr2040_recrep.recrepassdesp_id := vt_bi_tab_index_evt_r2040_rep(en_empresa_id)(vn_ind2).recrepassdesp_id;
         gt_row_efdreinfr2040_recrep.efdreinfr2040_id := gt_row_efd_reinf_r2040.id;
         --
         vn_fase := 9;
         --
         pk_csf_api_reinf.pkb_integr_efdreinfr2040_rep ( est_log_generico_reinf     => vt_log_generico_reinf
                                                       , est_row_efdreinfr2040_rep  => gt_row_efdreinfr2040_recrep
                                                       , en_empresa_id              => gt_row_geracao_efd_reinf.empresa_id
                                                       );
         --
         vn_fase := 10;
         --
         if vn_ind2 = vt_bi_tab_index_evt_r2040_rep(en_empresa_id).last then
            exit;
         else
            vn_ind2 := vt_bi_tab_index_evt_r2040_rep(en_empresa_id).next(vn_ind2);
         end if;
         --
      end loop;
      --
      vn_fase := 11;
      --
      if nvl(vn_efdreinfr2040_id, 0) > 0
         and nvl(vn_dm_st_proc, -1) <> 7 then -- 7-Excluído
         -- Recupera e relaciona os recursos repassados por associação desportiva do evento anterior com o novo evento gerado
         pkb_rec_evt_anterior_r2040 ( est_log_generico_reinf  => vt_log_generico_reinf
                                    , en_efdreinfr2040_old_id => vn_efdreinfr2040_id
                                    , en_efdreinfr2040_new_id => gt_row_efd_reinf_r2040.id
                                    );
         --
      end if;
      --   
      vn_fase := 12;
      --
      -- Gerar o ID para o evento criado
      pkb_gera_id_evt_reinf ( ev_obj_referencia => 'EFD_REINF_R2040'
                            , en_referencia_id  => gt_row_efd_reinf_r2040.id
                            );
      --
      vn_fase := 13;
      --
      if nvl(vt_log_generico_reinf.count,0) > 0 then
         --
         update efd_reinf_r2040
            set dm_st_proc = 2 -- Erro de Validação
          where id = gt_row_efd_reinf_r2040.id;
         --
      else
         --
         update efd_reinf_r2040
            set dm_st_proc = 1 -- Validado
          where id = gt_row_efd_reinf_r2040.id;
         --
      end if;
      --
   end if;
   --
   <<sair_geral>>
   --
   null;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_exist_evt_r2040 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_exist_evt_r2040;

---------------------------------------------------------------------------------------------------
-- Procedimento que irá Montar o Array para que seja gerado o evento EFD_REINF_R2040
procedure pkb_monta_array_r2040( en_empresa_id in empresa.id%type )
is
   --
   vn_fase               number;
   vn_loggenerico_id     log_generico.id%type;
   vb_achou              boolean;
   --
   vn_indx1              number;
   --
   -- Cursor para recuperar os recursos repassados por associação desportiva relacionados as empresas filiais
   cursor c_rep ( en_empresa_id number ) is
   select id
        , empresa_id
     from rec_rep_ass_desp
    where empresa_id = en_empresa_id
      and dt_ref     between gt_row_geracao_efd_reinf.dt_ini and gt_row_geracao_efd_reinf.dt_fin
      and dm_envio   = 0  -- Não Enviado
      and dm_st_proc = 1; -- Validado
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_rep(en_empresa_id)loop
      exit when c_rep%notfound or (c_rep%notfound) is null;
      --
      vn_fase := 2;
      --
      vn_indx1 := null;
      --
      vn_indx1 := nvl(rec.empresa_id,0);
      --
      begin
         vb_achou := vt_tab_index_evt_r2040.exists(vn_indx1);
      exception
         when others then
            vb_achou := false;
      end;
      --
      vn_fase := 3;
      --
      if not vb_achou then
         --
         vn_fase := 3.1;
         --
         vt_tab_index_evt_r2040(vn_indx1).empresa_id := rec.empresa_id;
         --
         vt_bi_tab_index_evt_r2040_rep(vn_indx1)(rec.id).recrepassdesp_id := rec.id;
         --
      else
         --
         vt_bi_tab_index_evt_r2040_rep(vn_indx1)(rec.id).recrepassdesp_id := rec.id;
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_monta_array_r2040 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_monta_array_r2040;

---------------------------------------------------------------------------------------------------
-- Processo de Geração de Evento R-2040
procedure pkb_gera_evt_r2040
is
   --
   vn_fase                  number;
   vn_ind1                  number;
   --
   cursor c_empr is
   select em.id empresa_id
     from empresa em
    where dm_situacao = 1 -- Ativo
    start with em.id = gt_row_geracao_efd_reinf.empresa_id
  connect by prior em.id = em.ar_empresa_id;
   --
begin
   --
   vn_fase := 1;
   --
   i := null;
   vt_tab_index_evt_r2040.delete;
   vt_bi_tab_index_evt_r2040_rep.delete;
   --
   vn_fase := 2;
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 3;
      --
      -- recupera a data de escrituação para recuperação dos documentos fiscais
      gn_dm_dt_escr_dfepoe := pk_csf.fkg_dmdtescrdfepoe_empresa( en_empresa_id => rec.empresa_id );
      --
      pkb_monta_array_r2040 ( rec.empresa_id );
      --
   end loop;
   --
   vn_fase := 4;
   --
   vn_ind1:= nvl(vt_tab_index_evt_r2040.first,0);
   --
   vn_fase := 5;
   --
   loop
      --
      vn_fase := 6;
      --
      if nvl(vn_ind1,0) = 0 then -- índice = empresa_id e dm_ind_obra
         exit;
      end if;
      --
      vn_fase := 7;
      --
      pkb_exist_evt_r2040( en_empresa_id => vt_tab_index_evt_r2040(vn_ind1).empresa_id );
      --
      vn_fase := 8;
      --
      if vn_ind1 = vt_tab_index_evt_r2040.last then
         exit;
      else
         vn_ind1 := vt_tab_index_evt_r2040.next(vn_ind1);
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_gera_evt_r2040 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_gera_evt_r2040;

---------------------------------------------------------------------------------------------------
-- Procedimento que recupera e relaciona os recursos recebidos do evento anterior com o novo evento gerado
procedure pkb_rec_evt_anterior_r2030 ( est_log_generico_reinf  in out nocopy dbms_sql.number_table
                                     , en_efdreinfr2030_old_id in            efd_reinf_r2030.id%type
                                     , en_efdreinfr2030_new_id in            efd_reinf_r2030.id%type
                                     )
is 
   --
   vn_fase                        number;
   --
   cursor c_r2030 is
   select *
     from r_efdreinfr2030_recreceb
    where efdreinfr2030_id = en_efdreinfr2030_old_id;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_r2030 loop
      exit when c_r2030%notfound or (c_r2030%notfound) is null;
      --
      vn_fase := 2;
      --
      gt_row_efdreinfr2030_recreceb := null;
      --
      gt_row_efdreinfr2030_recreceb.recrecebassdesp_id := rec.recrecebassdesp_id;
      gt_row_efdreinfr2030_recreceb.efdreinfr2030_id   := en_efdreinfr2030_new_id;
      --
      vn_fase := 3;
      --
      pk_csf_api_reinf.pkb_integr_efdreinfr2030_receb ( est_log_generico_reinf       => est_log_generico_reinf
                                                      , est_row_efdreinfr2030_receb  => gt_row_efdreinfr2030_recreceb
                                                      , en_empresa_id                => gt_row_geracao_efd_reinf.empresa_id
                                                      );
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_rec_evt_anterior_r2030 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id                    
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_rec_evt_anterior_r2030;

---------------------------------------------------------------------------------------------------
-- Procedimento de retificação do recurso recebido por associação desportiva do Evento R-2030
procedure pkb_retif_evt_r2030 ( en_efdreinfr2030_id     in efd_reinf_r2030.id%type
                              , en_recrecebassdesp_id   in rec_receb_ass_desp.id%type
                              )
is
   --
   vn_fase                           number;
   vn_loggenerico_id                 log_generico_reinf.id%type;
   vt_log_generico_reinf             dbms_sql.number_table;
   --
   vv_mensagem_log                   log_generico_reinf.mensagem%type;
   vv_resumo_log                     log_generico_reinf.resumo%type;
   vt_efd_reinf_r2030                efd_reinf_r2030%rowtype;
   vt_efd_reinf_r2030_new            efd_reinf_r2030%rowtype;
   vn_efdreinfr2030_last_id          efd_reinf_r2030.id%type;
   vn_cont_reg                       number;
   --
begin
   --
   vn_fase := 1;
   --
   vt_efd_reinf_r2030       := null;
   vt_efd_reinf_r2030_new   := null;
   vn_efdreinfr2030_last_id := null;
   vn_cont_reg              := null;
   --
   vn_fase := 2;
   --
   begin
      --
      select *
        into vt_efd_reinf_r2030
        from efd_reinf_r2030
       where id = en_efdreinfr2030_id;
      --
   exception
    when others then
      vt_efd_reinf_r2030 := null;
   end;
   --
   vn_fase := 3;
   --
   -- Recupera os dados da Abertura do EFD-REINF
   pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => vt_efd_reinf_r2030.geracaoefdreinf_id );
   --
   if nvl(gt_row_geracao_efd_reinf.dm_situacao, 0) = 2 then  -- 2-Aberto
      --
      if nvl(vt_efd_reinf_r2030.id,0) > 0 then
         --
         vn_fase := 4;
         --
         vv_resumo_log := 'Procedimento de Retificação do Evento R-2030 (Recurso Recebidos por Associação Desportiva) do Estabelecimento: '||
                          pk_csf.fkg_cod_nome_empresa_id ( vt_efd_reinf_r2030.empresa_id )|| ', no período de '||
                          trim(to_char(gt_row_geracao_efd_reinf.dt_ini, 'month')) || ' de ' ||
                          to_char(gt_row_geracao_efd_reinf.dt_ini,'yyyy');
         --
         vn_fase := 5;
         --
         delete log_generico_reinf
          where obj_referencia = 'EFD_REINF_R2030'
            and referencia_id  = vt_efd_reinf_r2030.id;
         --
         vn_fase := 6;
         --
         if vt_efd_reinf_r2030.dm_st_proc = 4 then -- 4-Processado
            --
            vn_fase := 7;
            -- Conta o número de recursos recebidos por associação desportiva que estão relacionados ao evento R-2030
            begin
               --
               select count(*)
                 into vn_cont_reg
                 from r_efdreinfr2030_recreceb
                where efdreinfr2030_id = vt_efd_reinf_r2030.id;
               --
            exception
               when others then
                  --
                  vn_cont_reg := 0;
                  --
            end;
            --
            vn_fase := 8;
            -- Se o evento estiver relacionado a apenas um recurso recebidos por associação desportiva e o mesmo estiver sendo retificado,
            -- o processo deverá apenas gerar o evento de exclusão R-9000
            if nvl(vn_cont_reg, 0) = 1 then
               --
               vn_fase := 9;
               -- Cria o evento de exclusão R-9000 para o evento R-2030
               pk_desfazer_dados_reinf.pkb_excluir_evt_r2030(vt_efd_reinf_r2030.id);
               --
            else
               --
               vn_fase := 10;
               -- Recupera o ID do último evento do grupo R-2030
               begin
                  --
                  select id
                    into vn_efdreinfr2030_last_id
                    from efd_reinf_r2030
                   where id in ( select max(id)
                                   from efd_reinf_r2030
                                  where empresa_id         = vt_efd_reinf_r2030.empresa_id
                                    and geracaoefdreinf_id = vt_efd_reinf_r2030.geracaoefdreinf_id );
                  --
               end;
               --
               vn_fase := 11;
               --
               if nvl(vn_efdreinfr2030_last_id, 0) = nvl(vt_efd_reinf_r2030.id, 0) then
                  --
                  vt_efd_reinf_r2030_new.id                   := null;
                  vt_efd_reinf_r2030_new.geracaoefdreinf_id   := vt_efd_reinf_r2030.geracaoefdreinf_id;
                  vt_efd_reinf_r2030_new.empresa_id           := vt_efd_reinf_r2030.empresa_id;
                  vt_efd_reinf_r2030_new.dm_st_proc           := 0; -- 0-Aberto
                  vt_efd_reinf_r2030_new.dm_tipo_reg          := 2; -- 2-Retificado
                  vt_efd_reinf_r2030_new.ar_efdreinfr2030_id  := vt_efd_reinf_r2030.id;
                  --
                  vn_fase := 12;
                  -- Cria o novo evento R-2030
                  pk_csf_api_reinf.pkb_integr_efdreinfr2030 ( est_log_generico_reinf  => vt_log_generico_reinf
                                                            , est_row_efdreinfr2030   => vt_efd_reinf_r2030_new
                                                            , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                            );
                  --
                  vn_fase := 13;
                  --
                  if nvl(vt_efd_reinf_r2030_new.id, 0) > 0 then
                     -- Recupera e relaciona os recursos recebidos por associação desportiva do evento anterior com o novo evento gerado
                     pkb_rec_evt_anterior_r2030 ( est_log_generico_reinf  => vt_log_generico_reinf
                                                , en_efdreinfr2030_old_id => vt_efd_reinf_r2030.id
                                                , en_efdreinfr2030_new_id => vt_efd_reinf_r2030_new.id
                                                );
                     --
                     vn_fase := 14;
                     --Exclui o recurso recebido por associação desportiva "retificado" do novo evento R-2030
                     delete r_efdreinfr2030_recreceb
                      where efdreinfr2030_id = vt_efd_reinf_r2030_new.id
                        and recrecebassdesp_id = en_recrecebassdesp_id;  --Recurso recebido por associação desportiva "retificado"
                     --
                     vn_fase := 15;
                     -- Atualiza a situação "dm_envio = 0" para o recurso recebido por associação desportiva "retificado"
                     update rec_receb_ass_desp
                        set dm_envio = 0                 -- 0-Não enviado
                      where id = en_recrecebassdesp_id;  -- Recurso repassado por associação desportiva "retificado"
                     --
                  end if;
                  --
                  vn_fase := 16;
                  --
                  if nvl(vt_log_generico_reinf.count,0) = 0 then
                     --
                     update efd_reinf_r2030
                        set dm_st_proc = 1 -- Validado
                      where id = vt_efd_reinf_r2030_new.id;
                     --
                  else
                     --
                     update efd_reinf_r2030
                        set dm_st_proc = 2 -- Erro de validação
                      where id = vt_efd_reinf_r2030_new.id;
                     --
                  end if;
                  --
                  vn_fase := 17;
                  --
                  -- Gerar o ID para o novo evento criado
                  pkb_gera_id_evt_reinf ( ev_obj_referencia => 'EFD_REINF_R2030'
                                        , en_referencia_id  => gt_row_efd_reinf_r2030.id
                                        );
                  --
               else
                  --
                  vn_fase := 18;
                  --
                  vv_mensagem_log := 'Evento não pode ser retificado pois não é o último evento gerado para o grupo de informação, favor verificar.';
                  --
                  pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                          , ev_mensagem             => vv_resumo_log ||' '|| vv_mensagem_log
                                                          , ev_resumo               => vv_mensagem_log
                                                          , en_tipo_log             => pk_csf_api_reinf.informacao
                                                          , en_referencia_id        => vt_efd_reinf_r2030.id
                                                          , ev_obj_referencia       => 'EFD_REINF_R2030'
                                                          , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                          );
                  --
               end if;
               --
            end if;
            --
         else  -- 0-Aberto; 1-Validado; 2-Erro de Validação; 3-Aguardando Envio; 5-Erro no Envio; 6-Erro na montagem do XML; 7-Excluído
            --
            vn_fase := 19;
            --
            vv_mensagem_log := 'O evento R-2030 não pode ser retificado pois está com o tipo de registro "'||
                               pk_csf.fkg_dominio('EFD_REINF_R2030.DM_TIPO_REG', vt_efd_reinf_r2030.dm_tipo_reg)||
                               '" e com a situação "'||pk_csf.fkg_dominio('EFD_REINF_R2030.DM_ST_PROC', vt_efd_reinf_r2030.dm_st_proc)||
                               '", favor verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                    , ev_mensagem             => vv_resumo_log ||' '|| vv_mensagem_log
                                                    , ev_resumo               => vv_mensagem_log
                                                    , en_tipo_log             => pk_csf_api_reinf.informacao
                                                    , en_referencia_id        => vt_efd_reinf_r2030.id
                                                    , ev_obj_referencia       => 'EFD_REINF_R2030'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
         end if;
         --
      end if;
      --
   else
      --
      vn_fase := 20;
      --
      vv_mensagem_log := 'Evento não pode ser retificado pois a situação do evento é diferente de "Aberto", favor verificar.';
      --
      pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                              , ev_mensagem             => vv_resumo_log ||' '|| vv_mensagem_log
                                              , ev_resumo               => vv_mensagem_log
                                              , en_tipo_log             => pk_csf_api_reinf.informacao
                                              , en_referencia_id        => vt_efd_reinf_r2030.id
                                              , ev_obj_referencia       => 'EFD_REINF_R2030'
                                              , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                             );
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      pk_csf_api_reinf.gv_mensagem_log := 'Erro na pk_gera_dados_reinf.pkb_retif_evt_r2030 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => vv_resumo_log || pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                 , en_tipo_log             => pk_csf_api_reinf.ERRO_DE_SISTEMA
                                                 , en_referencia_id        => pk_csf_api_reinf.gn_referencia_id
                                                 , ev_obj_referencia       => pk_csf_api_reinf.gv_obj_referencia
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_retif_evt_r2030;

---------------------------------------------------------------------------------------------------
-- Procedimento que cria um novo evento de Reenvio para os eventos com Erro no Envio ou Erro na montagem do XML
procedure pkb_reenviar_evt_r2030 ( en_efdreinfr2030_id in efd_reinf_r2030.id%type
                                 )
is
   --
   vn_fase                      number;
   vn_loggenericoreinf_id       log_generico_reinf.id%type;
   vn_efdreinfr2030_last_id     efd_reinf_r2030.id%type;
   --
   vt_efd_reinf_r2030           efd_reinf_r2030%rowtype;
   vt_log_generico_reinf        dbms_sql.number_table;
   --
begin
   --
   vn_fase := 1;
   --
   vt_efd_reinf_r2030     := null;
   vn_loggenericoreinf_id := null;
   --
   if nvl(en_efdreinfr2030_id,0) > 0 then
      --
      vn_fase := 2;
      --
      begin
         --
         select *
           into vt_efd_reinf_r2030
           from efd_reinf_r2030
          where id = en_efdreinfr2030_id;
         --
      exception
       when others then
         vt_efd_reinf_r2030 := null;
      end;
      --
      vn_fase := 3;
      -- Recupera os dados da Abertura do EFD-REINF
      pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => vt_efd_reinf_r2030.geracaoefdreinf_id );
      --
      vn_fase := 4;
      --
      delete log_generico_reinf
       where obj_referencia = 'EFD_REINF_R2030'
         and referencia_id  = gt_row_geracao_efd_reinf.id;
      --
      vn_fase := 5;
      --
      if nvl(vt_efd_reinf_r2030.id, 0) > 0
         and vt_efd_reinf_r2030.dm_st_proc in (5,6) then -- 5-Erro no Envio; 6-Erro na montagem do XML
         --
         vn_fase := 6;
         --
         vn_efdreinfr2030_last_id := null;
         -- Verificar se este é o último evento do grupo do R-2030
         begin
            --
            select max(id)
              into vn_efdreinfr2030_last_id
              from efd_reinf_r2030
             where empresa_id         = vt_efd_reinf_r2030.empresa_id
               and geracaoefdreinf_id = vt_efd_reinf_r2030.geracaoefdreinf_id;
         exception
          when others then
             vn_efdreinfr2030_last_id := null;
         end;
         --
         vn_fase := 7;
         --
         if nvl(vn_efdreinfr2030_last_id,0) = nvl(vt_efd_reinf_r2030.id,0) then
            --
            vn_fase := 8;
            --
            gt_row_efd_reinf_r2030 := vt_efd_reinf_r2030;
            --
            gt_row_efd_reinf_r2030.id              := 0;  -- 0-Aberto.
            gt_row_efd_reinf_r2030.loteefdreinf_id := null;
            --
            vn_fase := 9;
            --
            pk_csf_api_reinf.pkb_integr_efdreinfr2030 ( est_log_generico_reinf  => vt_log_generico_reinf
                                                      , est_row_efdreinfr2030   => gt_row_efd_reinf_r2030
                                                      , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                      );
            --
            vn_fase := 10;
            -- Recupera e relaciona os recursos recebidos por associação despotiva do evento anterior com o novo evento gerado
            pkb_rec_evt_anterior_r2030 ( est_log_generico_reinf  => vt_log_generico_reinf
                                       , en_efdreinfr2030_old_id => gt_row_efd_reinf_r2030.id
                                       , en_efdreinfr2030_new_id => gt_row_efd_reinf_r2030.id
                                       );
            --
            vn_fase := 11;
            --
            if nvl(vt_log_generico_reinf.count,0) > 0 then
               --
               update efd_reinf_r2030
                  set dm_st_proc = 2
                where id = gt_row_efd_reinf_r2030.id;
               --
            else
               --
               update efd_reinf_r2030
                  set dm_st_proc = 1
                where id = gt_row_efd_reinf_r2030.id;
               --
            end if;
            --
         else
            --
            pk_csf_api_reinf.gv_mensagem_log := 'Está sendo reenviado um evento R-2030 ( efdreinfr2030_id = '|| vt_efd_reinf_r2030.id ||') antigo, já existe um novo evento criado para o grupo, Favor Verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                    , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                    , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                    , en_tipo_log             => INFORMACAO
                                                    , en_referencia_id        => vt_efd_reinf_r2030.id
                                                    , ev_obj_referencia       => 'EFD_REINF_R2030'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
         end if;
         --
      else
         --
         pk_csf_api_reinf.gv_mensagem_log := 'Situação "'|| pk_csf.fkg_dominio ( 'EFD_REINF_R2030.DM_ST_PROC', vt_efd_reinf_r2030.dm_st_proc ) ||'" do evento R-2030 (efdreinfr2030_id = '||vt_efd_reinf_r2030.id||') não é permitido a geração do evento de reenvio';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => vt_efd_reinf_r2030.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2030'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
      end if;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_reenviar_evt_r2030 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => vt_efd_reinf_r2030.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2030'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_reenviar_evt_r2030;

---------------------------------------------------------------------------------------------------
-- Processo que verifica se existe evento dentro do periodo para a Empresa
procedure pkb_exist_evt_r2030( en_empresa_id in empresa.id%type
                             )
is
   --
   vn_fase                         number;
   vt_log_generico_reinf           dbms_sql.number_table;
   vn_ind2                         number;
   --
   vn_efdreinfr2030_id             efd_reinf_r2030.id%type;
   vn_dm_tipo_reg                  efd_reinf_r2030.dm_tipo_reg%type;
   vn_dm_st_proc                   efd_reinf_r2030.dm_st_proc%type;
   vn_loggenericoreinf_id          log_generico_reinf.id%type;
   vv_mensagem                     log_generico_reinf.mensagem%type;
   --
begin
   --
   vn_fase := 1;
   --
   gt_row_efd_reinf_r2030 := null;
   vt_log_generico_reinf.delete;
   vn_loggenericoreinf_id := null;
   --
   vn_fase := 2;
   -- Verificar se ja existe Evento para o Indice de dentro do Periodo
   begin
      --
      select id
           , dm_tipo_reg
           , dm_st_proc
        into vn_efdreinfr2030_id
           , vn_dm_tipo_reg
           , vn_dm_st_proc
        from efd_reinf_r2030
       where id in ( select max(err.id)
                       from efd_reinf_r2030 err
                      where err.empresa_id         = en_empresa_id -- Estab. Matriz/Filial
                        and err.geracaoefdreinf_id = gt_row_geracao_efd_reinf.id
                        and err.dm_st_proc         in (0,1,3,4,7) ); -- 0-Aberto; 1-Validado; 3-Aguardando Envio; 4-Processado; 7-Excluído
      --
   exception
    when others then
      vn_efdreinfr2030_id := null;
      vn_dm_tipo_reg      := null;
      vn_dm_st_proc       := null;
   end;
   --
   vn_fase := 3;
   --
   gt_row_efd_reinf_r2030.id                   := null;
   gt_row_efd_reinf_r2030.geracaoefdreinf_id   := gt_row_geracao_efd_reinf.id;   
   gt_row_efd_reinf_r2030.empresa_id           := en_empresa_id;
   gt_row_efd_reinf_r2030.dm_st_proc           := 0; -- 0-Aberto
   gt_row_efd_reinf_r2030.ar_efdreinfr2030_id  := null;
   --
   vn_fase := 4;
   --
   if nvl(vn_efdreinfr2030_id,0) > 0 then
      --
      vn_fase := 4.1;
      --
      if vn_dm_st_proc in (0,1,3) then -- 0-Aberto; 1-Validado; 3-Aguardando Envio
         --
         vv_mensagem := 'O último evento R-2030 está com o tipo de registro "'||pk_csf.fkg_dominio('EFD_REINF_R2030.DM_TIPO_REG', vn_dm_tipo_reg)||
                        '" e com a situação "'||pk_csf.fkg_dominio('EFD_REINF_R2030.DM_ST_PROC', vn_dm_st_proc)||
                        '". Neste caso, não poderá ser gerado um novo evento R-2030. Favor verificar.';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_resumo || vv_mensagem
                                                 , ev_resumo               => vv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         goto sair_geral;
         --
      elsif vn_dm_st_proc = 4 then -- 4-Processado
         --
         gt_row_efd_reinf_r2030.dm_tipo_reg         := 2; -- 2-Retificado
         gt_row_efd_reinf_r2030.ar_efdreinfr2030_id := vn_efdreinfr2030_id;
         --
      elsif vn_dm_st_proc = 7 then -- 7-Excluído
         --
         gt_row_efd_reinf_r2030.dm_tipo_reg := 1; -- 1-Original
         --
      end if;
      --
   else
      --
      vn_fase := 4.2;
      --
      gt_row_efd_reinf_r2030.dm_tipo_reg := 1; --Original
      --
   end if;
   --
   vn_fase := 5;
   -- Gravar Evento Criado no Banco de Dados
   pk_csf_api_reinf.pkb_integr_efdreinfr2030 ( est_log_generico_reinf => vt_log_generico_reinf
                                             , est_row_efdreinfr2030  => gt_row_efd_reinf_r2030
                                             , en_empresa_id          => gt_row_geracao_efd_reinf.empresa_id
                                             );
   --
   vn_fase := 6;
   --
   if nvl(gt_row_efd_reinf_r2030.id,0) > 0 then
      --
      vn_fase := 7;
      --
      vn_ind2:= nvl(vt_bi_tab_index_evt_r2030_rec(en_empresa_id).first,0);
      --
      loop
         --
         gt_row_efdreinfr2030_recreceb := null;
         --
         if nvl(vn_ind2,0) = 0 then -- índice = empresa_id e recrecebassdesp_id
            exit;
         end if;
         --
         vn_fase := 8;
         --
         gt_row_efdreinfr2030_recreceb.recrecebassdesp_id := vt_bi_tab_index_evt_r2030_rec(en_empresa_id)(vn_ind2).recrecebassdesp_id;
         gt_row_efdreinfr2030_recreceb.efdreinfr2030_id   := gt_row_efd_reinf_r2030.id;
         --
         vn_fase := 9;
         --
         pk_csf_api_reinf.pkb_integr_efdreinfr2030_receb ( est_log_generico_reinf       => vt_log_generico_reinf
                                                         , est_row_efdreinfr2030_receb  => gt_row_efdreinfr2030_recreceb
                                                         , en_empresa_id                => gt_row_geracao_efd_reinf.empresa_id
                                                         );
         --
         vn_fase := 10;
         --
         if vn_ind2 = vt_bi_tab_index_evt_r2030_rec(en_empresa_id).last then
            exit;
         else
            vn_ind2 := vt_bi_tab_index_evt_r2030_rec(en_empresa_id).next(vn_ind2);
         end if;
         --
      end loop;
      --
      vn_fase := 11;
      --
      if nvl(vn_efdreinfr2030_id, 0) > 0 
         and nvl(vn_dm_st_proc, -1) <> 7 then -- 7-Excluído
         -- Recupera e relaciona os recursos recebidos por associação desportiva do evento anterior com o novo evento gerado
         pkb_rec_evt_anterior_r2030 ( est_log_generico_reinf  => vt_log_generico_reinf
                                    , en_efdreinfr2030_old_id => vn_efdreinfr2030_id
                                    , en_efdreinfr2030_new_id => gt_row_efd_reinf_r2030.id
                                    );
         --
      end if;
      --
      --
      vn_fase := 12;
      --
      -- Gerar o ID para o evento criado
      pkb_gera_id_evt_reinf ( ev_obj_referencia => 'EFD_REINF_R2030'
                            , en_referencia_id  => gt_row_efd_reinf_r2030.id
                            );
      --
      vn_fase := 13;
      --
      if nvl(vt_log_generico_reinf.count,0) > 0 then
         --
         update efd_reinf_r2030
            set dm_st_proc = 2 -- Erro de Validação
          where id = gt_row_efd_reinf_r2030.id;
         --
      else
         --
         update efd_reinf_r2030
            set dm_st_proc = 1 -- Validado
          where id = gt_row_efd_reinf_r2030.id;
         --
      end if;
      --
   end if;
   --
   <<sair_geral>>
   --
   null;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_exist_evt_r2030 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_exist_evt_r2030;

---------------------------------------------------------------------------------------------------
-- Procedimento que irá Montar o Array para que seja
procedure pkb_monta_array_r2030 ( en_empresa_id in empresa.id%type )
is
   --
   vn_fase               number;
   vn_indx1              number;
   --
   vn_loggenerico_id     log_generico.id%type;
   vb_achou              boolean;
   --
   -- Cursor para recuperar os recursos recebidos por associação desportiva relacionados as empresas filiais
   cursor c_reb ( en_empresa_id number ) is
   select id
        , empresa_id
     from rec_receb_ass_desp
    where empresa_id = en_empresa_id
      and dt_ref     between gt_row_geracao_efd_reinf.dt_ini and gt_row_geracao_efd_reinf.dt_fin
      and dm_envio   = 0 -- Não Enviado
      and dm_st_proc = 1; -- Validado
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_reb(en_empresa_id)loop
      exit when c_reb%notfound or (c_reb%notfound) is null;
      --
      vn_fase := 2;
      --
      vn_indx1 := null;
      --
      vn_indx1 := nvl(rec.empresa_id,0);
      --
      begin
         vb_achou := vt_tab_index_evt_r2030.exists(vn_indx1);
      exception
         when others then
            vb_achou := false;
      end;
      --
      vn_fase := 3;
      --
      if not vb_achou then
         --
         vn_fase := 3.1;
         --
         vt_tab_index_evt_r2030(vn_indx1).empresa_id := rec.empresa_id;
         --
         vt_bi_tab_index_evt_r2030_rec(vn_indx1)(rec.id).recrecebassdesp_id := rec.id;
         --
      else
         --
         vt_bi_tab_index_evt_r2030_rec(vn_indx1)(rec.id).recrecebassdesp_id := rec.id;
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_monta_array_r2030 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_monta_array_r2030;

---------------------------------------------------------------------------------------------------
-- Processo de Geração de Evento R-2030
procedure pkb_gera_evt_r2030
is
   --
   vn_fase                  number;
   vn_ind1                  number;
   --
   -- Cursor para recuperar empresas filiais
   cursor c_empr is
   select em.id empresa_id
     from empresa em
    where dm_situacao = 1 -- Ativo
    start with em.id = gt_row_geracao_efd_reinf.empresa_id
  connect by prior em.id = em.ar_empresa_id;
   --
begin
   --
   vn_fase := 1;
   --
   i := null;
   vt_tab_index_evt_r2030.delete;
   vt_bi_tab_index_evt_r2030_rec.delete;
   --
   vn_fase := 2;
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 3;
      --
      -- recupera a data de escrituação para recuperação dos documentos fiscais
      gn_dm_dt_escr_dfepoe := pk_csf.fkg_dmdtescrdfepoe_empresa( en_empresa_id => rec.empresa_id );
      --
      pkb_monta_array_r2030 ( rec.empresa_id );
      --
   end loop;
   --
   vn_fase := 4;
   --
   vn_ind1:= nvl(vt_tab_index_evt_r2030.first,0);
   --
   vn_fase := 5;
   --
   loop
      --
      vn_fase := 6;
      --
      if nvl(vn_ind1,0) = 0 then -- índice = empresa_id e dm_ind_obra
         exit;
      end if;
      --
      pkb_exist_evt_r2030( en_empresa_id => vt_tab_index_evt_r2030(vn_ind1).empresa_id );
      --
      if vn_ind1 = vt_tab_index_evt_r2030.last then
         exit;
      else
         vn_ind1 := vt_tab_index_evt_r2030.next(vn_ind1);
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_gera_evt_r2030 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id                    
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_gera_evt_r2030;

---------------------------------------------------------------------------------------------------
-- Procedimento que recupera e relaciona as notas fiscais do evento anterior com o novo evento gerado
procedure pkb_rec_doc_evt_anterior_r2020 ( est_log_generico_reinf     in out nocopy dbms_sql.number_table
                                         , en_efdreinfr2020_old_id    in            efd_reinf_r2020.id%type
                                         , en_efdreinfr2020_new_id    in            efd_reinf_r2020.id%type
                                         )
is
   --
   vn_fase                        number;
   --
   cursor c_r2020_nf is
   select *
     from efd_reinf_r2020_nf
    where efdreinfr2020_id = en_efdreinfr2020_old_id;
   --
   cursor c_r2020_cte is
   select *
     from efd_reinf_r2020_cte
    where efdreinfr2020_id = en_efdreinfr2020_old_id;
   --  
begin
   --
   vn_fase := 1;
   --
   for rec in c_r2020_nf loop
      exit when c_r2020_nf%notfound or (c_r2020_nf%notfound) is null;
      --
      vn_fase := 2;
      --
      gt_row_efd_reinf_r2020_nf := null;
      --
      gt_row_efd_reinf_r2020_nf.notafiscal_id    := rec.notafiscal_id;
      gt_row_efd_reinf_r2020_nf.efdreinfr2020_id := en_efdreinfr2020_new_id;
      --
      vn_fase := 3;
      --
      pk_csf_api_reinf.pkb_integr_efdreinfr2020_nf ( est_log_generico_reinf    => est_log_generico_reinf
                                                   , est_row_efdreinfr2020_nf  => gt_row_efd_reinf_r2020_nf
                                                   , en_empresa_id             => gt_row_geracao_efd_reinf.empresa_id
                                                   );
      --
   end loop;
   --
   for rec in c_r2020_cte loop
      exit when c_r2020_cte%notfound or (c_r2020_cte%notfound) is null;
      --
      vn_fase := 2;
      --
      gt_row_efd_reinf_r2020_cte := null;
      --
      gt_row_efd_reinf_r2020_cte.conhectransp_id   := rec.conhectransp_id;
      gt_row_efd_reinf_r2020_cte.efdreinfr2020_id  := en_efdreinfr2020_new_id;
      --
      vn_fase := 3;
      --
      pk_csf_api_reinf.pkb_integr_efdreinfr2020_cte ( est_log_generico_reinf     => est_log_generico_reinf
                                                    , est_row_efdreinfr2020_cte  => gt_row_efd_reinf_r2020_cte
                                                    , en_empresa_id              => gt_row_geracao_efd_reinf.empresa_id
                                                    );
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_rec_nf_evt_anterior_r2020 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id                    
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_rec_doc_evt_anterior_r2020;

---------------------------------------------------------------------------------------------------
-- Procedimento de retificação da nota fiscal de saída do Evento R-2020
procedure pkb_retif_evt_r2020 ( en_efdreinfr2020_id in efd_reinf_r2020.id%type
                              , ev_tipo_doc         in varchar2 -- NF / CTE
                              , en_documento_id     in number
                              )
is
   --
   vn_fase                           number;
   vn_loggenerico_id                 log_generico_reinf.id%type;
   vt_log_generico_reinf             dbms_sql.number_table;
   --
   vv_mensagem_log                   log_generico_reinf.mensagem%type;
   vv_resumo_log                     log_generico_reinf.resumo%type;
   vt_efd_reinf_r2020                efd_reinf_r2020%rowtype;
   vt_efd_reinf_r2020_new            efd_reinf_r2020%rowtype;
   vn_efdreinfr2020_last_id          efd_reinf_r2020.id%type;
   vn_cont_reg                       number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   vt_efd_reinf_r2020       := null;
   vt_efd_reinf_r2020_new   := null;
   vn_efdreinfr2020_last_id := null;
   vn_cont_reg              := 0;
   --
   vn_fase := 2;
   --
   begin
      --
      select *
        into vt_efd_reinf_r2020
        from efd_reinf_r2020
       where id = en_efdreinfr2020_id;
      --
   exception
    when others then
      vt_efd_reinf_r2020 := null;
   end;
   --
   vn_fase := 3;
   --
   -- Recupera os dados da Abertura do EFD-REINF
   pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => vt_efd_reinf_r2020.geracaoefdreinf_id );
   --
   if nvl(gt_row_geracao_efd_reinf.dm_situacao, 0) = 2 then  -- 2-Aberto
      --
      if nvl(vt_efd_reinf_r2020.id,0) > 0 then
         --
         vn_fase := 4;
         --
         vv_resumo_log := 'Procedimento de Retificação do Evento R-2020 (Nota Fiscais de Saída) do Estabelecimento: '||
                          pk_csf.fkg_cod_nome_empresa_id ( vt_efd_reinf_r2020.empresa_id )|| ', no período de '||
                          trim(to_char(gt_row_geracao_efd_reinf.dt_ini, 'month')) || ' de ' ||
                          to_char(gt_row_geracao_efd_reinf.dt_ini,'yyyy');
         --
         vn_fase := 5;
         --
         delete log_generico_reinf
          where obj_referencia = 'EFD_REINF_R2020'
            and referencia_id  = vt_efd_reinf_r2020.id;
         --
         vn_fase := 6;
         --
         if vt_efd_reinf_r2020.dm_st_proc in (4,8) then -- 4-Processado; 8-Processado R-5001
            --
            vn_fase := 7;
            -- Conta o número de notas fiscais de saída que estão relacionadas ao evento R-2020
            begin
               --
               select count(1)
                  into vn_cont_reg
               from (   
                  select 1
                     from efd_reinf_r2020_nf
                  where efdreinfr2020_id = vt_efd_reinf_r2020.id
                    and ev_tipo_doc = 'NF'
                  UNION ALL --<<<
                  select 1
                     from efd_reinf_r2020_cte
                  where efdreinfr2020_id = vt_efd_reinf_r2020.id
                    and ev_tipo_doc = 'CTE'
               );   
               --
            exception
               when others then
                  --
                  vn_cont_reg := 0;
                  --
            end;
            --
            vn_fase := 8;
            -- Se o evento estiver relacionado a apenas uma nota fiscal de saída e a mesma estiver sendo retificada,
            -- o processo deverá apenas gerar o evento de exclusão R-9000
            if nvl(vn_cont_reg, 0) = 1 then
               --
               vn_fase := 9;
               -- Cria o evento de exclusão R-9000 para o evento R-2020
               pk_desfazer_dados_reinf.pkb_excluir_evt_r2020(vt_efd_reinf_r2020.id);
               --
            else
               --
               vn_fase := 10;
               -- Recupera o ID do último evento do grupo R-2020
               begin
                  --
                  select id
                    into vn_efdreinfr2020_last_id
                    from efd_reinf_r2020
                   where id in ( select max(id)
                                   from efd_reinf_r2020
                                  where empresa_id         = vt_efd_reinf_r2020.empresa_id
                                    and geracaoefdreinf_id = vt_efd_reinf_r2020.geracaoefdreinf_id
                                    and dm_ind_tp_inscr    = vt_efd_reinf_r2020.dm_ind_tp_inscr
                                    and nro_inscr_estab    = vt_efd_reinf_r2020.nro_inscr_estab
                                    and cnpj               = vt_efd_reinf_r2020.cnpj );
                  --
               end;
               --
               vn_fase := 11;
               --
               if nvl(vn_efdreinfr2020_last_id, 0) = nvl(vt_efd_reinf_r2020.id, 0) then
                  --
                  vt_efd_reinf_r2020_new.id                   := null;
                  vt_efd_reinf_r2020_new.geracaoefdreinf_id   := vt_efd_reinf_r2020.geracaoefdreinf_id;
                  vt_efd_reinf_r2020_new.empresa_id           := vt_efd_reinf_r2020.empresa_id;
                  vt_efd_reinf_r2020_new.dm_st_proc           := 0; -- 0-Aberto
                  vt_efd_reinf_r2020_new.dm_tipo_reg          := 2; -- 2-Retificado
                  vt_efd_reinf_r2020_new.dm_ind_tp_inscr      := vt_efd_reinf_r2020.dm_ind_tp_inscr;
                  vt_efd_reinf_r2020_new.nro_inscr_estab      := vt_efd_reinf_r2020.nro_inscr_estab;
                  vt_efd_reinf_r2020_new.cnpj                 := vt_efd_reinf_r2020.cnpj;
                  vt_efd_reinf_r2020_new.pessoa_id            := vt_efd_reinf_r2020.pessoa_id;
                  vt_efd_reinf_r2020_new.ar_efdreinfr2020_id  := vt_efd_reinf_r2020.id;
                  --
                  vn_fase := 12;
                  -- Cria o novo evento R-2020
                  pk_csf_api_reinf.pkb_integr_efd_reinf_r2020 ( est_log_generico_reinf  => vt_log_generico_reinf
                                                              , est_row_efdreinfr2020   => vt_efd_reinf_r2020_new
                                                              , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                              );
                  --
                  vn_fase := 13;
                  --
                  if nvl(vt_efd_reinf_r2020_new.id, 0) > 0 then
                     -- Recupera e relaciona os documentos do evento anterior com o novo evento gerado
                     pkb_rec_doc_evt_anterior_r2020 ( est_log_generico_reinf  => vt_log_generico_reinf
                                                    , en_efdreinfr2020_old_id => vt_efd_reinf_r2020.id
                                                    , en_efdreinfr2020_new_id => vt_efd_reinf_r2020_new.id
                                                   );
                     
                     --
                     vn_fase := 13.1;
                     --
                     -- Notas Fiscais --
                     if ev_tipo_doc = 'NF' then
                        --
                        vn_fase := 13.11;
                        --Exclui a nota fiscal de saída "retificada" do novo evento R-2020
                        delete efd_reinf_r2020_nf
                         where efdreinfr2020_id = vt_efd_reinf_r2020_new.id
                           and notafiscal_id    = en_documento_id; --Nota fiscal de Saída "retificada"
                        --
                        vn_fase := 13.12;
                        -- Atualiza a situação "dm_envio = 1" para a nota fiscal de saída "retificada"
                        update nota_fiscal
                           set dm_envio_reinf = 1     -- 1-Enviado
                         where id = en_documento_id;  -- Nota fiscal de saída "retificada"
                        --
                     -- Conhecimento de Transporte --   
                     elsif ev_tipo_doc = 'CTE' then
                        --
                        vn_fase := 13.13;
                        --Exclui o Conhecimento de Transporte de Prestação "retificada" do novo evento R-2020
                        delete efd_reinf_r2020_cte
                         where efdreinfr2020_id = vt_efd_reinf_r2020_new.id
                           and conhectransp_id  = en_documento_id; -- Conhecimento de Transporte de Prestação "retificada"
                        --
                        vn_fase := 13.14;
                        -- Atualiza a situação "dm_envio = 1" para o Conhecimento de Transporte de Prestação "retificada"
                        update conhec_transp
                           set dm_envio_reinf = 1       -- 2-Enviado
                         where id = en_documento_id;    -- Conhecimento de Transporte de Prestação "retificada"
                        --
                     end if;
                     --
                  end if;
                  --
                  vn_fase := 14;
                  --
                  if nvl(vt_log_generico_reinf.count,0) = 0 then
                     --
                     update efd_reinf_r2020
                        set dm_st_proc = 1 -- Validado
                      where id = vt_efd_reinf_r2020_new.id;
                     --
                  else
                     --
                     update efd_reinf_r2020
                        set dm_st_proc = 2 -- Erro de validação
                      where id = vt_efd_reinf_r2020_new.id;
                     --
                  end if;
                  --
                  vn_fase := 15;
                  --
                  -- Gerar o ID para o novo evento criado
                  pkb_gera_id_evt_reinf ( ev_obj_referencia => 'EFD_REINF_R2020'
                                        , en_referencia_id  => gt_row_efd_reinf_r2020.id
                                        );
                  --
               else
                  --
                  vn_fase := 16;
                  --
                  vv_mensagem_log := 'Evento não pode ser retificado pois não é o último evento gerado para o grupo de informação, favor verificar.';
                  --
                  pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                          , ev_mensagem             => vv_resumo_log ||' '|| vv_mensagem_log
                                                          , ev_resumo               => vv_mensagem_log
                                                          , en_tipo_log             => pk_csf_api_reinf.informacao
                                                          , en_referencia_id        => vt_efd_reinf_r2020.id
                                                          , ev_obj_referencia       => 'EFD_REINF_R2020'
                                                          , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                          );
                  --
               end if;
               --
            end if;
            --
         else  -- 0-Aberto; 1-Validado; 2-Erro de Validação; 3-Aguardando Envio; 5-Erro no Envio; 6-Erro na montagem do XML; 7-Excluído
            --
            vn_fase := 17;
            --
            vv_mensagem_log := 'O evento R-2020 não pode ser retificado pois está com o tipo de registro "'||
                               pk_csf.fkg_dominio('EFD_REINF_R2020.DM_TIPO_REG', vt_efd_reinf_r2020.dm_tipo_reg)||
                               '" e com a situação "'||pk_csf.fkg_dominio('EFD_REINF_R2020.DM_ST_PROC', vt_efd_reinf_r2020.dm_st_proc)||
                               '", favor verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                    , ev_mensagem             => vv_resumo_log ||' '|| vv_mensagem_log
                                                    , ev_resumo               => vv_mensagem_log
                                                    , en_tipo_log             => pk_csf_api_reinf.informacao
                                                    , en_referencia_id        => vt_efd_reinf_r2020.id
                                                    , ev_obj_referencia       => 'EFD_REINF_R2020'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
         end if;
         --
      end if;
      --
   else
      --
      vn_fase := 18;
      --
      vv_mensagem_log := 'Evento não pode ser retificado pois a situação do evento é diferente de "Aberto", favor verificar.';
      --
      pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                              , ev_mensagem             => vv_resumo_log ||' '|| vv_mensagem_log
                                              , ev_resumo               => vv_mensagem_log
                                              , en_tipo_log             => pk_csf_api_reinf.informacao
                                              , en_referencia_id        => vt_efd_reinf_r2020.id
                                              , ev_obj_referencia       => 'EFD_REINF_R2020'
                                              , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                             );
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      pk_csf_api_reinf.gv_mensagem_log := 'Erro na pk_gera_dados_reinf.pkb_retif_evt_r2020 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => vv_resumo_log || pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                 , en_tipo_log             => pk_csf_api_reinf.ERRO_DE_SISTEMA
                                                 , en_referencia_id        => pk_csf_api_reinf.gn_referencia_id
                                                 , ev_obj_referencia       => pk_csf_api_reinf.gv_obj_referencia
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_retif_evt_r2020;

---------------------------------------------------------------------------------------------------
-- Processo que valida as informações do R-2020 e insere na oficial
procedure pkb_reenviar_evt_r2020 ( en_efdreinfr2020_id in efd_reinf_r2020.id%type
                                 )
is
   --
   vn_fase                      number;
   vn_loggenericoreinf_id       log_generico_reinf.id%type;
   vn_efdreinfr2020_last_id     efd_reinf_r2020.id%type;
   --
   vt_efd_reinf_r2020           efd_reinf_r2020%rowtype;
   vt_log_generico_reinf        dbms_sql.number_table;
   --
begin
   --
   vn_fase := 1;
   --
   vt_efd_reinf_r2020     := null;
   vn_loggenericoreinf_id := null;
   --
   if nvl(en_efdreinfr2020_id,0) > 0 then
      --
      vn_fase := 2;
      --
      begin
         --
         select *
           into vt_efd_reinf_r2020
           from efd_reinf_r2020
          where id = en_efdreinfr2020_id;
         --
      exception
       when others then
         vt_efd_reinf_r2020 := null;
      end;
      --
      vn_fase := 3;
      -- Recupera os dados da Abertura do EFD-REINF
      pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => vt_efd_reinf_r2020.geracaoefdreinf_id );
      --
      vn_fase := 4;
      --
      delete log_generico_reinf
       where obj_referencia = 'EFD_REINF_R2020'
         and referencia_id  = gt_row_geracao_efd_reinf.id;
      --
      vn_fase := 5;
      --
      if nvl(vt_efd_reinf_r2020.id, 0) > 0
         and vt_efd_reinf_r2020.dm_st_proc in (5,6) then -- 5-Erro no Envio; 6-Erro na montagem do XML
         --
         vn_fase := 6;
         --
         vn_efdreinfr2020_last_id := null;
         -- Verificar se este é o último evento do grupo do R-2020
         begin
            --
            select max(id)
              into vn_efdreinfr2020_last_id
              from efd_reinf_r2020
             where empresa_id         = vt_efd_reinf_r2020.empresa_id
               and geracaoefdreinf_id = vt_efd_reinf_r2020.geracaoefdreinf_id
               and dm_ind_tp_inscr    = vt_efd_reinf_r2020.dm_ind_tp_inscr
               and nro_inscr_estab    = vt_efd_reinf_r2020.nro_inscr_estab
               and cnpj               = vt_efd_reinf_r2020.cnpj;
            --
         exception
          when others then
             vn_efdreinfr2020_last_id := null;
         end;
         --
         vn_fase := 7;
         --
         if nvl(vn_efdreinfr2020_last_id,0) = nvl(vt_efd_reinf_r2020.id,0) then
            --
            vn_fase := 8;
            --
            gt_row_efd_reinf_r2020 := vt_efd_reinf_r2020;
            --
            gt_row_efd_reinf_r2020.dm_st_proc      := 0;  -- 0-Aberto.
            gt_row_efd_reinf_r2020.loteefdreinf_id := null;
            --
            vn_fase := 9;
            --
            pk_csf_api_reinf.pkb_integr_efd_reinf_r2020 ( est_log_generico_reinf => vt_log_generico_reinf
                                                        , est_row_efdreinfr2020  => gt_row_efd_reinf_r2020
                                                        , en_empresa_id          => gt_row_geracao_efd_reinf.empresa_id
                                                        );
            --
            vn_fase := 10;
            -- Recupera a relaciona documentos do evento anterior com o novo evento gerado
            pkb_rec_doc_evt_anterior_r2020 ( est_log_generico_reinf  => vt_log_generico_reinf
                                           , en_efdreinfr2020_old_id => gt_row_efd_reinf_r2020.id
                                           , en_efdreinfr2020_new_id => gt_row_efd_reinf_r2020.id
                                          );
            --
            vn_fase := 11;
            --
            if nvl(vt_log_generico_reinf.count,0) > 0 then
               --
               update efd_reinf_r2020
                  set dm_st_proc = 2
                where id = gt_row_efd_reinf_r2020.id;
               --
            else
               --
               update efd_reinf_r2020
                  set dm_st_proc = 1
                where id = gt_row_efd_reinf_r2020.id;
               --
            end if;
            --
         else
            --
            pk_csf_api_reinf.gv_mensagem_log := 'Está sendo reenviado um evento R-2020 ( efdreinfr2020_id = '|| vt_efd_reinf_r2020.id ||') antigo, já existe um novo evento criado para o grupo, Favor Verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                    , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                    , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                    , en_tipo_log             => INFORMACAO
                                                    , en_referencia_id        => vt_efd_reinf_r2020.id
                                                    , ev_obj_referencia       => 'EFD_REINF_R2020'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
         end if;
         --
      else
         --
         pk_csf_api_reinf.gv_mensagem_log := 'Situação "'|| pk_csf.fkg_dominio ( 'EFD_REINF_R2020.DM_ST_PROC', vt_efd_reinf_r2020.dm_st_proc ) ||'" do evento R-2020 (efdreinfr2020_id = '||vt_efd_reinf_r2020.id||') não é permitido a geração do evento de reenvio';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => vt_efd_reinf_r2020.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2020'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
      end if;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_reenviar_evt_r2020 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => vt_efd_reinf_r2020.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2020'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_reenviar_evt_r2020;

---------------------------------------------------------------------------------------------------
-- Processo que valida as informações do R-2020 e insere na oficial
procedure pkb_exist_evt_r2020 ( en_empresa_id           in empresa.id%type
                              , en_dm_ind_tp_inscr      in efd_reinf_r2020.dm_ind_tp_inscr%type
                              , ev_nro_inscr_estab      in efd_reinf_r2020.nro_inscr_estab%type
                              , ev_cnpj_part            in efd_reinf_r2020.cnpj%type
                              , en_indx_doc_id          in number
                              , ev_tipo_evento          in varchar2
                              , est_log_generico_reinf  in out nocopy dbms_sql.number_table
                              , est_2020_erros          in out nocopy dbms_sql.number_table
                              )
is
   --
   i                               pls_integer;
   vn_efdreinfr2020_id             efd_reinf_r2020.id%type;
   vn_dm_tipo_reg                  efd_reinf_r2020.dm_tipo_reg%type;
   vn_dm_st_proc                   efd_reinf_r2020.dm_st_proc%type;
   vn_fase                         number;
   vv_cnpj                         varchar2(14);
   --
   vn_ind2                         number;
   vn_loggenericoreinf_id          log_generico_reinf.id%type;
   vv_mensagem                     log_generico_reinf.mensagem%type;
   --
   vb_achou                        boolean := False;
begin
   --
   vn_fase := 1;
   --
   gt_row_efd_reinf_r2020 := null;
   est_log_generico_reinf.delete;
   vn_loggenericoreinf_id := null;
   --
   vn_fase := 2;
   -- Verificar se ja existe Evento para o Indice de dentro do Periodo
   begin
      --
      select id
           , dm_tipo_reg
           , dm_st_proc
        into vn_efdreinfr2020_id
           , vn_dm_tipo_reg
           , vn_dm_st_proc
        from efd_reinf_r2020
       where id in ( select max(err.id)
                       from efd_reinf_r2020 err
                      where err.empresa_id         = en_empresa_id -- Estab. Matriz/Filial
                        and err.geracaoefdreinf_id = gt_row_geracao_efd_reinf.id
                        and err.dm_ind_tp_inscr    = en_dm_ind_tp_inscr
                        and err.nro_inscr_estab    = ev_nro_inscr_estab
                        and err.cnpj               = ev_cnpj_part 
                        and err.dm_st_proc         in (0,1,3,4,7,8) ); -- 0-Aberto; 1-Validado; 3-Aguardando Envio; 4-Processado; 7-Excluído; 8-Processado R-5001
      --
   exception
    when others then
      vn_efdreinfr2020_id := null;
      vn_dm_tipo_reg      := null;
      vn_dm_st_proc       := null;
   end;
   --
   vn_fase := 3;
   --
   gt_row_efd_reinf_r2020.id                   := null;
   gt_row_efd_reinf_r2020.geracaoefdreinf_id   := gt_row_geracao_efd_reinf.id;
   gt_row_efd_reinf_r2020.empresa_id           := en_empresa_id;
   gt_row_efd_reinf_r2020.dm_st_proc           := 0; -- 0-Aberto
   gt_row_efd_reinf_r2020.dm_ind_tp_inscr      := en_dm_ind_tp_inscr;
   gt_row_efd_reinf_r2020.nro_inscr_estab      := ev_nro_inscr_estab;
   gt_row_efd_reinf_r2020.cnpj                 := ev_cnpj_part;
   gt_row_efd_reinf_r2020.ar_efdreinfr2020_id  := null;
   --
   vn_fase := 4;
   --
   if nvl(vn_efdreinfr2020_id,0) > 0 then
      --
      vn_fase := 4.1;
      --
      if vn_dm_st_proc in (0,1,3) then -- 0-Aberto; 1-Validado; 3-Aguardando Envio
         --
         vv_mensagem := 'O último evento R-2020 está com o tipo de registro "'||pk_csf.fkg_dominio('EFD_REINF_R2020.DM_TIPO_REG', vn_dm_tipo_reg)||
                        '" e com a situação "'||pk_csf.fkg_dominio('EFD_REINF_R2020.DM_ST_PROC', vn_dm_st_proc)||
                        '". Neste caso, não poderá ser gerado um novo evento R-2020. Favor verificar.';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_resumo || vv_mensagem
                                                 , ev_resumo               => vv_mensagem
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
         goto sair_geral;
         --
      elsif vn_dm_st_proc in (4,8) then -- 4-Processado; 8-Processado R-5001
         --
         gt_row_efd_reinf_r2020.dm_tipo_reg          := 2; -- 2-Retificado
         gt_row_efd_reinf_r2020.ar_efdreinfr2020_id  := vn_efdreinfr2020_id;
         --
      elsif vn_dm_st_proc = 7 then -- 7-Excluído
         --
         gt_row_efd_reinf_r2020.dm_tipo_reg := 1; -- 1-Original
         --
      end if;
      --
   else
      --
      vn_fase := 4.2;
      --
      gt_row_efd_reinf_r2020.dm_tipo_reg := 1; --Original
      --
   end if;
   --
   vn_fase := 5;
   -- Gravar Evento Criado no Banco de Dados
   pk_csf_api_reinf.pkb_integr_efd_reinf_r2020 ( est_log_generico_reinf => est_log_generico_reinf
                                               , est_row_efdreinfr2020  => gt_row_efd_reinf_r2020
                                               , en_empresa_id          => gt_row_geracao_efd_reinf.empresa_id
                                               );
   --
   vn_fase := 6;
   --
   if nvl(gt_row_efd_reinf_r2020.id,0) > 0 then
      --
      vn_fase := 7;
      --
      -- Geração das notas fiscais para o evento 2020
      --
      if ev_tipo_evento = 'N' then
         --
         begin
            vb_achou := vt_bi_tab_index_evt_r2020_nf.exists(en_indx_doc_id);
         exception
            when others then
               vb_achou := false;
         end;
         --
         vn_ind2 := null;
         --
         if vb_achou then
            vn_ind2:= nvl(vt_bi_tab_index_evt_r2020_nf(en_indx_doc_id).first,0);
         end if;   
         --
         loop
            --
            gt_row_efd_reinf_r2020_nf := null;
            --
            if nvl(vn_ind2,0) = 0 then -- índice = empresa_id e notafiscal_id
               exit;
            end if;
            --
            vn_fase := 8;
            --
            gt_row_efd_reinf_r2020_nf.notafiscal_id                           := vt_bi_tab_index_evt_r2020_nf(en_indx_doc_id)(vn_ind2).notafiscal_id;
            gt_row_efd_reinf_r2020_nf.efdreinfr2020_id                        := gt_row_efd_reinf_r2020.id;
            vv_cnpj                                                           := vt_bi_tab_index_evt_r2020_nf(en_indx_doc_id)(vn_ind2).cnpj;
            --
            vn_fase := 9;
            --
            if vv_cnpj = ev_cnpj_part then
               --
               pk_csf_api_reinf.pkb_integr_efdreinfr2020_nf ( est_log_generico_reinf    => est_log_generico_reinf
                                                            , est_row_efdreinfr2020_nf  => gt_row_efd_reinf_r2020_nf
                                                            , en_empresa_id             => gt_row_geracao_efd_reinf.empresa_id
                                                            );
               --
            end if;
            --
            vn_fase := 9.2;
            --
            if vn_ind2 = vt_bi_tab_index_evt_r2020_nf(en_indx_doc_id).last then
               exit;
            else
               vn_ind2 := vt_bi_tab_index_evt_r2020_nf(en_indx_doc_id).next(vn_ind2);
            end if;
            --
         end loop;
         --
         vn_fase := 10;
         --
         -- Valida o CPRB das Notas Fiscais do Evento R2020
         pkb_valida_cprb_nf_r2020(en_geracaoefdreinf_id  => gt_row_geracao_efd_reinf.id
                                , en_efdreinfr2020_id    => gt_row_efd_reinf_r2020.id
                                , est_log_generico_reinf => est_log_generico_reinf); 
         --
         vn_fase := 11;
         --
         -- Valida arredondamento imposto INSS para REINF - R2020
         pkb_valida_rnd_inss_r2020(en_geracaoefdreinf_id  => gt_row_geracao_efd_reinf.id
                                 , en_efdreinfr2020_id    => gt_row_efd_reinf_r2020.id
                                 , est_log_generico_reinf => est_log_generico_reinf); 
         --
      else
         --
         vn_fase := 12;
         --
         ---------------------------------------------------------------------------------------------------------
         -- Geração dos Conhecimentos de Transportes para o evento 2020
         ---------------------------------------------------------------------------------------------------------
         begin
            vb_achou := vt_bi_tab_index_evt_r2020_cte.exists(en_indx_doc_id);
         exception
            when others then
               vb_achou := false;
         end;      
         --
         vn_ind2 := null;
         --
         if vb_achou then
            vn_ind2:= nvl(vt_bi_tab_index_evt_r2020_cte(en_indx_doc_id).first,0);
         end if;   
         --
         loop
            --
            gt_row_efd_reinf_r2020_cte := null;
            --
            if nvl(vn_ind2,0) = 0 then -- índice = empresa_id e conhectransp_id
               exit;
            end if;
            --
            vn_fase := 13;
            --
            gt_row_efd_reinf_r2020_cte.conhectransp_id   := vt_bi_tab_index_evt_r2020_cte(en_indx_doc_id)(vn_ind2).conhectransp_id;
            gt_row_efd_reinf_r2020_cte.efdreinfr2020_id  := gt_row_efd_reinf_r2020.id;
            vv_cnpj                                      := vt_bi_tab_index_evt_r2020_cte(en_indx_doc_id)(vn_ind2).cnpj;
            --
            if vv_cnpj = gt_row_efd_reinf_r2020.cnpj then
               pk_csf_api_reinf.pkb_integr_efdreinfr2020_cte ( est_log_generico_reinf     => est_log_generico_reinf
                                                             , est_row_efdreinfr2020_cte  => gt_row_efd_reinf_r2020_cte
                                                             , en_empresa_id              => gt_row_geracao_efd_reinf.empresa_id
                                                             );
            end if;                                                                                                             
            --
            vn_fase := 14;
            --
            if vn_ind2 = vt_bi_tab_index_evt_r2020_cte(en_indx_doc_id).last then
               exit;
            else
               vn_ind2 := vt_bi_tab_index_evt_r2020_cte(en_indx_doc_id).next(vn_ind2);
            end if;
            --
         end loop;
         --
      end if;
      --
      vn_fase := 15;
      --
      if nvl(vn_efdreinfr2020_id, 0) > 0
         and nvl(vn_dm_st_proc, -1) <> 7 then -- 7-Excluído
         -- Recupera e relaciona os documentos do evento anterior com o novo evento gerado
         pkb_rec_doc_evt_anterior_r2020 ( est_log_generico_reinf  => est_log_generico_reinf
                                        , en_efdreinfr2020_old_id => vn_efdreinfr2020_id
                                        , en_efdreinfr2020_new_id => gt_row_efd_reinf_r2020.id
                                        );
         --
      end if;
      --
      vn_fase := 16;
      --
      -- Gerar o ID para o evento criado
      pkb_gera_id_evt_reinf ( ev_obj_referencia => 'EFD_REINF_R2020'
                            , en_referencia_id  => gt_row_efd_reinf_r2020.id
                            );
      --
      vn_fase := 17;
      --
      if (nvl(est_log_generico_reinf.count,0) > 0 or gt_row_geracao_efd_reinf.dm_situacao = 1) then
         --
         i := nvl(est_2020_erros.count,0) + 1;
         --
         est_2020_erros(i) := gt_row_efd_reinf_r2020.id;
         --
      else   
         --     
         update efd_reinf_r2020
            set dm_st_proc = 1 -- Validado
          where id         = gt_row_efd_reinf_r2020.id 
            and dm_st_proc <> 2;
         --
      end if;
      --
   end if;
   --
   <<sair_geral>>
   --
   null;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_exist_evt_r2020 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_exist_evt_r2020;

---------------------------------------------------------------------------------------------------
-- Procedimento que irá Montar o Array para que seja
procedure pkb_monta_array_r2020 ( en_empresa_id in empresa.id%type )
is
   --
   vn_fase                  number;
   vv_cnpj_prestador        varchar2(14);
   vv_cnpj_tomador          varchar2(14);
   vn_indx1                 number;
   --
   vn_loggenerico_id        log_generico.id%type;
   vb_achou                 boolean;
   vn_loggenericoreinf_id   log_generico_reinf.id%type;
   vt_log_generico_reinf    dbms_sql.number_table;
   --
   -- Cursor para recuperar as notas fiscais de saída relacionadas as empresas filiais
   cursor c_nfs ( en_empresa_id number ) is
   select distinct nf.id notafiscal_id
        , nf.nro_nf
        , nf.pessoa_id
        , nfdc.dm_ind_obra
        , nf.empresa_id
        , nf.serie
        , nfdc.nro_cno
        , trunc(nf.dt_emiss) dt_emiss
        , to_number(nvl(ii.aliq_apli,0))                       aliq_apli_inss
        , to_number(decode(inf.dm_ind_cprb, 0, 11, 1, 3.5, 0)) aliq_cprb
        , nvl(nft.vl_total_serv,0)                             vl_total_serv
     from nota_fiscal           nf
        , item_nota_fiscal      inf
        , imp_itemnf            ii
        , tipo_imposto          ti
        , nfs_det_constr_civil  nfdc
        , mod_fiscal            mf
        , nota_fiscal_total     nft
    where nf.id                   = inf.notafiscal_id
      and ii.itemnf_id            = inf.id
      and nf.empresa_id           = en_empresa_id
      and nft.notafiscal_id   (+) = nf.id
      and nf.dm_st_proc           = 4 -- Autorizada
      and nf.dm_ind_emit          = 0 -- Emissão própria
      and nf.dm_ind_oper          = 1 -- Saida
      and nf.dm_arm_nfe_terc      = 0 -- Não pegar notas do MIDAS. (armazenamento)
      and nf.dt_emiss             between gt_row_geracao_efd_reinf.dt_ini 
                                      and gt_row_geracao_efd_reinf.dt_fin
      and ii.tipoimp_id           = ti.id
      and ti.cd                   = 13 -- INSS
      and ii.dm_tipo              = 1  -- Retido
      and nvl(ii.vl_imp_trib, 0)  > 0
      and nvl(ii.vl_base_calc, 0) > 0
      and mf.id                   = nf.modfiscal_id
      and ((mf.cod_mod   = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and nf.dm_arm_nfe_terc      = 0 -- Não pegar nota de amarzenamento
      and nf.dm_envio_reinf       = 0 -- Não Enviada
      and nfdc.notafiscal_id  (+) = nf.id
      --
      and exists (select 1
                    from juridica ju
                   where ju.pessoa_id = nf.pessoa_id                  
                   union                 
                  select 1
                    from nota_fiscal_dest  nfd
                   where nfd.notafiscal_id = nf.id
                     and trim(nfd.cnpj) is not null);
   --
   -- Informações do Evento R-2020 (CTe - Prestação)
   cursor c_cte ( en_empresa_id number ) is
   select distinct
          ct.id conhectransp_id,
          ct.nro_ct,
          ct.serie,
          ct.dt_hr_emissao, 
          ct.empresa_id,
          ct.pessoa_id
     from conhec_transp          ct,
          conhec_transp_imp_ret cti,
          tipo_imposto           ti,
          mod_fiscal             mf
    where cti.conhectransp_id  = ct.id
      and ti.id                = cti.tipoimp_id
      and mf.id                = ct.modfiscal_id
      --
      and ct.empresa_id        = en_empresa_id
      and ct.dt_hr_emissao     between gt_row_geracao_efd_reinf.dt_ini
                                   and gt_row_geracao_efd_reinf.dt_fin
      and ct.dm_envio_reinf    = 0    -- Não Enviada
      and ct.dm_st_proc        = 4    -- Autorizada
      and ct.dm_ind_emit       = 0    -- Emissão Própria
      and ct.dm_ind_oper       = 1    -- Prestação (Saída)
      and mf.cod_mod           = '67' -- Conhecimento de Transporte Eletrônico - Outros Serviços
      --
      and ti.cd                = '13' -- INSS
      and ct.dm_arm_cte_terc   = 0    -- Pegar somente CTes convertidos
      --
      and exists (select 1
                    from juridica ju
                   where ju.pessoa_id = ct.pessoa_id                  
                   union                 
                  select 1
                    from conhec_transp_emit  cte
                   where cte.conhectransp_id = ct.id
                     and trim(cte.cnpj) is not null);
   --
begin
   --
   vn_loggenericoreinf_id := null;
   --
   vn_fase := 1;
   -- Notas Fiscais ----------------------------------------------------------
   for rec_nf in c_nfs (en_empresa_id) loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_fase := 1.2;
      --
      vn_indx1 := null;
      --
      vn_indx1 := nvl(rec_nf.empresa_id,0)||nvl(rec_nf.dm_ind_obra,0);
      --
      vv_cnpj_tomador := null;
      --
      -- Recuperar o CNPJ do Participante da Nota Fiscal.
      begin
         --
         select trim( lpad(j.NUM_CNPJ, 8, '0') || lpad(j.NUM_FILIAL, 4, '0') || lpad(j.DIG_CNPJ, 2, '0') ) cnpj_cpf
           into vv_cnpj_tomador
           from juridica j
          where j.pessoa_id = nvl(rec_nf.pessoa_id,0);
         --
      exception
         when others then
            vv_cnpj_tomador := null;
      end;
      --
      vn_fase := 1.3;
      --
      -- Caso não exista o cadastro do participante recuperar do detalhamento da nota.
      if trim(vv_cnpj_tomador) is null then
         --
         begin
            --
            select cnpj
              into vv_cnpj_tomador
              from nota_fiscal_dest
             where notafiscal_id = rec_nf.notafiscal_id;
            --
         exception
           when others then
            vv_cnpj_tomador := null;
         end;
         --
      end if;
      --
      vn_fase := 1.4;
      --
      if rec_nf.vl_total_serv = 0 then
         --
         gv_mensagem := 'A nota fiscal de saída nro: '|| rec_nf.nro_nf || ', serie: '|| rec_nf.serie ||' e data de emissão: '|| rec_nf.dt_emiss ||' do estabelecimento filial/matriz ' ||
                        pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id ) || ' não será possível enviar para o REINF por conta de falta de informação. (Valor Total do Serviço na nota)';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
      end if;      
      --
      vn_fase := 1.5;
      --
      -- Caso não exista o CNPJ do participante não é possivel enviar os dados relacionado, será gerado um log para que o usuario corrija posteriormente
      if trim(vv_cnpj_tomador) is null then
         --
         gv_mensagem := 'A nota fiscal de saída nro: '|| rec_nf.nro_nf || ', serie: '|| rec_nf.serie ||' e data de emissão: '|| rec_nf.dt_emiss ||' do estabelecimento filial/matriz ' ||
                        pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id ) || ' não será possível enviar para o REINF por conta de falta de informação. (CNPJ do participante da nota)';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
      end if;
      --
      vn_fase := 1.6;
      --
      vv_cnpj_prestador := null;
      --
      -- Se a Empresa for uma Obra, utilizar o Número do CNO no lugar do CNPJ
      if nvl(rec_nf.dm_ind_obra,0) > 0 then
         --
         /*vv_cnpj_prestador := rec_nf.nro_cno;*/
         vv_cnpj_prestador := pk_csf.fkg_cnpj_ou_cpf_empresa (rec_nf.empresa_id);
         vv_cnpj_tomador   := rec_nf.nro_cno;
         --
      else
         --
         vv_cnpj_prestador := pk_csf.fkg_cnpj_ou_cpf_empresa (rec_nf.empresa_id);
         --
      end if;
      --
      begin
         vb_achou := vt_tri_tab_index_evt_r2020(vn_indx1)(vv_cnpj_prestador).exists(vv_cnpj_tomador);
      exception
         when others then
            vb_achou := false;
      end;
      --
      vn_fase := 1.7;
      --
      if not vb_achou then
         --
         vn_fase := 1.71;
         --
         x := nvl(x,0) + 1;
         --
         vt_tri_tab_index_evt_r2020(vn_indx1)(vv_cnpj_prestador)(vv_cnpj_tomador).indx_doc_id      := x; -- Apenas para utilizar como indice para recup as notas
         vt_tri_tab_index_evt_r2020(vn_indx1)(vv_cnpj_prestador)(vv_cnpj_tomador).empresa_id       := rec_nf.empresa_id;
         vt_tri_tab_index_evt_r2020(vn_indx1)(vv_cnpj_prestador)(vv_cnpj_tomador).cnpj_part        := vv_cnpj_tomador;
         vt_tri_tab_index_evt_r2020(vn_indx1)(vv_cnpj_prestador)(vv_cnpj_tomador).dm_ind_obra      := nvl(rec_nf.dm_ind_obra,0);
         vt_tri_tab_index_evt_r2020(vn_indx1)(vv_cnpj_prestador)(vv_cnpj_tomador).nro_inscr_estab  := vv_cnpj_prestador;
         vt_tri_tab_index_evt_r2020(vn_indx1)(vv_cnpj_prestador)(vv_cnpj_tomador).tipo             := 'N'; -- Tipo Nota Fiscal
         --
         vt_bi_tab_index_evt_r2020_nf(x)(rec_nf.notafiscal_id).notafiscal_id   := rec_nf.notafiscal_id;
         vt_bi_tab_index_evt_r2020_nf(x)(rec_nf.notafiscal_id).cnpj            := vv_cnpj_tomador;
         vt_bi_tab_index_evt_r2020_nf(x)(rec_nf.notafiscal_id).passou_ind_cprb := case when rec_nf.aliq_apli_inss = rec_nf.aliq_cprb then 1 else 0 end; -- 0: Não passou no teste / 1: Passou no teste
      else
         --
         vn_fase := 1.72;
         vt_bi_tab_index_evt_r2020_nf(vt_tri_tab_index_evt_r2020(vn_indx1)(vv_cnpj_prestador)(vv_cnpj_tomador).indx_doc_id)(rec_nf.notafiscal_id).notafiscal_id := rec_nf.notafiscal_id;
         vt_bi_tab_index_evt_r2020_nf(vt_tri_tab_index_evt_r2020(vn_indx1)(vv_cnpj_prestador)(vv_cnpj_tomador).indx_doc_id)(rec_nf.notafiscal_id).cnpj          := vv_cnpj_tomador;
         --
      end if;
      --
   end loop;
   --
   vn_fase := 2;
   -- Conhecimento de Transporte de Prestação --------------------------------
   i := 0;
   for rec_cte in c_cte (en_empresa_id) loop
      exit when c_cte%notfound or (c_cte%notfound) is null;
      --
      vn_fase := 2.1;
      --
      vn_indx1 := null;
      --
      vn_indx1 := nvl(rec_cte.empresa_id,0);
      --
      vv_cnpj_tomador := null;
      --
      -- Recuperar o CNPJ do Participante do Conhecimento de Transporte.
      begin
         --
         select trim( lpad(j.num_cnpj, 8, '0') || lpad(j.num_filial, 4, '0') || lpad(j.dig_cnpj, 2, '0') ) cnpj_cpf
           into vv_cnpj_tomador
           from juridica j
          where j.pessoa_id = nvl(rec_cte.pessoa_id,0);
         --
      exception
         when others then
            vv_cnpj_tomador := null;
      end;
      --
      vn_fase := 2.2;
      --
      -- Caso não exista o cadastro do participante recuperar do detalhamento da nota.
      if trim(vv_cnpj_tomador) is null then
         --
         begin
            --
            select max(cnpj)
              into vv_cnpj_tomador
              from conhec_transp_dest
             where conhectransp_id = rec_cte.conhectransp_id;
            --
         exception
           when others then
            vv_cnpj_tomador := null;
         end;
         --
      end if;
      --
      vn_fase := 2.3;
      --
      -- Caso não exista o CNPJ do participante não é possivel enviar os dados relacionado, será gerado um log para que o usuario corrija posteriormente
      if trim(vv_cnpj_tomador) is null then
         --
         gv_mensagem := 'O Conhecimento de Transporte de Prestação nro: '|| rec_cte.nro_ct || ', série: '|| rec_cte.serie ||' e data de emissão: '|| to_char(rec_cte.dt_hr_emissao,'dd/mm/yyyy') ||' do estabelecimento filial/matriz ' ||
                        pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id ) || ' não será enviada para o REINF por falta de informação. (CNPJ do participante da nota)';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
      end if;
      --
      vn_fase := 2.4;
      --
      vv_cnpj_prestador := pk_csf.fkg_cnpj_ou_cpf_empresa (rec_cte.empresa_id);
      --
      begin
         vb_achou := vt_tri_tab_index_evt_r2020(vn_indx1)(vv_cnpj_prestador).exists(vv_cnpj_tomador);
      exception
         when others then
            vb_achou := false;
      end;
      --
      vn_fase := 2.5;
      --
      if not vb_achou then
         --
         vn_fase := 2.51;
         --
         i := nvl(i,0) + 1;
         --
         vt_tri_tab_index_evt_r2020(vn_indx1)(vv_cnpj_prestador)(vv_cnpj_tomador).indx_doc_id      := i; -- Apenas para utilizar como indice para recup as notas
         vt_tri_tab_index_evt_r2020(vn_indx1)(vv_cnpj_prestador)(vv_cnpj_tomador).empresa_id       := rec_cte.empresa_id;
         vt_tri_tab_index_evt_r2020(vn_indx1)(vv_cnpj_prestador)(vv_cnpj_tomador).cnpj_part        := vv_cnpj_tomador;
         vt_tri_tab_index_evt_r2020(vn_indx1)(vv_cnpj_prestador)(vv_cnpj_tomador).dm_ind_obra      := 0;
         vt_tri_tab_index_evt_r2020(vn_indx1)(vv_cnpj_prestador)(vv_cnpj_tomador).nro_inscr_estab  := vv_cnpj_prestador;
         vt_tri_tab_index_evt_r2010(vn_indx1)(vv_cnpj_prestador)(vv_cnpj_tomador).tipo             := 'C'; -- Tipo Conhecimento de Transporte
         --
         vt_bi_tab_index_evt_r2020_cte(i)(rec_cte.conhectransp_id).conhectransp_id := rec_cte.conhectransp_id;
         vt_bi_tab_index_evt_r2020_cte(i)(rec_cte.conhectransp_id).cnpj            := vv_cnpj_tomador;
         --
      else
         --
         vn_fase := 2.52;
         vt_bi_tab_index_evt_r2020_cte(vt_tri_tab_index_evt_r2020(vn_indx1)(vv_cnpj_prestador)(vv_cnpj_tomador).indx_doc_id)(rec_cte.conhectransp_id).conhectransp_id := rec_cte.conhectransp_id;
         vt_bi_tab_index_evt_r2020_cte(vt_tri_tab_index_evt_r2020(vn_indx1)(vv_cnpj_prestador)(vv_cnpj_tomador).indx_doc_id)(rec_cte.conhectransp_id).cnpj            := vv_cnpj_tomador;
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_monta_array_r2020 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_monta_array_r2020;

---------------------------------------------------------------------------------------------------
-- Processo de Geração de Evento R-2020
procedure pkb_gera_evt_r2020
is
   --
   vn_fase                  number;
   vn_ind1                  varchar2(14);
   vn_ind2                  varchar2(14);
   --
   vn_ind3                  varchar2(14);
   vn_dm_ind_tp_inscr       efd_reinf_r2020.dm_ind_tp_inscr%type;
   vt_log_generico_reinf    dbms_sql.number_table;
   vt_2020_erros            dbms_sql.number_table;
   --
   -- Cursor para recuperar empresas filiais
   cursor c_empr is
   select em.id empresa_id
     from empresa em
    where dm_situacao = 1 -- Ativo
    start with em.id = gt_row_geracao_efd_reinf.empresa_id
  connect by prior em.id = em.ar_empresa_id; -- Ativo
   --
begin
   --
   vn_fase := 1;
   --
   i := null;
   vt_tri_tab_index_evt_r2020.delete;
   vt_bi_tab_index_evt_r2020_nf.delete;
   --
   vn_fase := 2;
   --
   -- Recuperar/Montar indexes baseado no layout disponibilizado no EFD-REINF conforme
   -- existentes tanto a empresa matriz quanto as filiais
   for rec_empr in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 2.1;
      --
      -- recupera a data de escrituação para recuperação dos documentos fiscais
      gn_dm_dt_escr_dfepoe := pk_csf.fkg_dmdtescrdfepoe_empresa( en_empresa_id => rec_empr.empresa_id );
      --
      pkb_monta_array_r2020 ( rec_empr.empresa_id );
      --
   end loop;
   --
   vn_fase := 3;
   --
   -- Se não existir notas fiscais, não continua com a criação do evento R-2010
   if nvl(vt_bi_tab_index_evt_r2020_nf.count, 0)  = 0 and
      nvl(vt_bi_tab_index_evt_r2020_cte.count, 0) = 0 then
      --
      goto sair_proc;
      --
   end if;
   --
   vn_fase := 4;
   --
   vn_ind1:= nvl(vt_tri_tab_index_evt_r2020.first,0);
   --
   vn_fase := 5;
   --
   loop
      --
      vn_fase := 6;
      --
      if nvl(vn_ind1,0) = 0 then -- índice = empresa_id e dm_ind_obra
         exit;
      end if;
      --
      vn_ind2:= nvl(vt_tri_tab_index_evt_r2020(vn_ind1).first,0);
      --
      loop
         --
         vn_fase := 7;
         --
         if nvl(vn_ind2,0) = 0 then -- índice = CNPJ do Participante
            exit;
         end if;
         --
         vn_ind3:= nvl(vt_tri_tab_index_evt_r2020(vn_ind1)(vn_ind2).first,0);
         --
         loop
            --
            vn_fase := 8;
            --
            if nvl(vn_ind3,0) = 0 then -- índice = nro_inscr_estab
               exit;
            end if;
            --
            vn_fase := 9;
            --
            if nvl(vt_tri_tab_index_evt_r2020(vn_ind1)(vn_ind2)(vn_ind3).dm_ind_obra,0) = 0 then
               --
               vn_dm_ind_tp_inscr := 1; -- CNPJ
               --
            else
               --
               vn_dm_ind_tp_inscr := 4; -- CNO
               --
            end if;
            --
            pkb_exist_evt_r2020 ( en_empresa_id           => vt_tri_tab_index_evt_r2020(vn_ind1)(vn_ind2)(vn_ind3).empresa_id
                                , en_dm_ind_tp_inscr      => vn_dm_ind_tp_inscr
                                , ev_nro_inscr_estab      => vt_tri_tab_index_evt_r2020(vn_ind1)(vn_ind2)(vn_ind3).nro_inscr_estab
                                , ev_cnpj_part            => vt_tri_tab_index_evt_r2020(vn_ind1)(vn_ind2)(vn_ind3).cnpj_part
                                , en_indx_doc_id          => vt_tri_tab_index_evt_r2020(vn_ind1)(vn_ind2)(vn_ind3).indx_doc_id
                                , ev_tipo_evento          => vt_tri_tab_index_evt_r2020(vn_ind1)(vn_ind2)(vn_ind3).tipo
                                , est_log_generico_reinf  => vt_log_generico_reinf
                                , est_2020_erros          => vt_2020_erros 
                                );
            --
            if vn_ind3 = vt_tri_tab_index_evt_r2020(vn_ind1)(vn_ind2).last then
               exit;
            else
               vn_ind3 := vt_tri_tab_index_evt_r2020(vn_ind1)(vn_ind2).next(vn_ind3);
            end if;
            --
         end loop;
         --
         if vn_ind2 = vt_tri_tab_index_evt_r2020(vn_ind1).last then
            exit;
         else
            vn_ind2 := vt_tri_tab_index_evt_r2020(vn_ind1).next(vn_ind2);
         end if;
         --
      end loop;
      --
      if vn_ind1 = vt_tri_tab_index_evt_r2020.last then
         exit;
      else
         vn_ind1 := vt_tri_tab_index_evt_r2020.next(vn_ind1);
      end if;
      --
   end loop;
   --
   -- Caso encontre algum erro, invalida o evento
   if (nvl(vt_log_generico_reinf.count,0) > 0 or gt_row_geracao_efd_reinf.dm_situacao = 1) then
      --
      --forAll i in 1 .. vt_2020_erros.count
      for i in vt_2020_erros.First .. vt_2020_erros.Last
      loop 	  
         --	  
         update efd_reinf_r2020
            set dm_st_proc = 2 -- Erro de Validação
          where id         = vt_2020_erros(i);
         --		  
      end loop;		  
      --
   else
      --
      update efd_reinf_r2020
         set dm_st_proc = 1 -- Validado
       where id         = gt_row_efd_reinf_r2010.id
         and dm_st_proc <> 2;
      --
   end if;   
   --   
   <<sair_proc>>
   --
   null;
   --   
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_gera_evt_r2020 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_gera_evt_r2020;

---------------------------------------------------------------------------------------------------
-- Procedimento que recupera e relaciona as notas fiscais do evento anterior com o novo evento gerado
procedure pkb_rec_doc_evt_anterior_r2010 ( est_log_generico_reinf     in out nocopy dbms_sql.number_table
                                         , en_efdreinfr2010_old_id    in            efd_reinf_r2010.id%type
                                         , en_efdreinfr2010_new_id    in            efd_reinf_r2010.id%type
                                        )
is
   --
   vn_fase                        number;
   --
   cursor c_r2010_nf is
   select *
     from efd_reinf_r2010_nf
    where efdreinfr2010_id = en_efdreinfr2010_old_id;
   --
   cursor c_r2010_cte is
   select *
     from efd_reinf_r2010_cte
    where efdreinfr2010_id = en_efdreinfr2010_old_id;
   --   
begin
   --
   vn_fase := 1;
   --
   for rec in c_r2010_nf loop
      exit when c_r2010_nf%notfound or (c_r2010_nf%notfound) is null;
      --
      vn_fase := 2;
      --
      gt_row_efd_reinf_r2010_nf := null;
      --
      gt_row_efd_reinf_r2010_nf.notafiscal_id    := rec.notafiscal_id;
      gt_row_efd_reinf_r2010_nf.efdreinfr2010_id := en_efdreinfr2010_new_id;
      --
      vn_fase := 3;
      --
      pk_csf_api_reinf.pkb_integr_efdreinfr2010_nf ( est_log_generico_reinf    => est_log_generico_reinf
                                                   , est_row_efdreinfr2010_nf  => gt_row_efd_reinf_r2010_nf
                                                   , en_empresa_id             => gt_row_geracao_efd_reinf.empresa_id
                                                   );
      --
   end loop;
   --
   for rec in c_r2010_cte loop
      exit when c_r2010_cte%notfound or (c_r2010_cte%notfound) is null;
      --
      vn_fase := 2;
      --
      gt_row_efd_reinf_r2010_cte := null;
      --
      gt_row_efd_reinf_r2010_cte.conhectransp_id  := rec.conhectransp_id;
      gt_row_efd_reinf_r2010_cte.efdreinfr2010_id := en_efdreinfr2010_new_id;
      --
      vn_fase := 3;
      --
      pk_csf_api_reinf.pkb_integr_efdreinfr2010_cte ( est_log_generico_reinf     => est_log_generico_reinf
                                                    , est_row_efdreinfr2010_cte  => gt_row_efd_reinf_r2010_cte
                                                    , en_empresa_id              => gt_row_geracao_efd_reinf.empresa_id
                                                    );
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_rec_doc_evt_anterior_r2010 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id                    
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_rec_doc_evt_anterior_r2010;

---------------------------------------------------------------------------------------------------
-- Procedimento de retificação da nota fiscal de entrada do Evento R-2010
procedure pkb_retif_evt_r2010 ( en_efdreinfr2010_id in efd_reinf_r2010.id%type
                              , ev_tipo_doc         in varchar2 -- NF / CTE
                              , en_documento_id     in number                          
                              )
is
   --
   vn_fase                           number;
   vn_loggenerico_id                 log_generico_reinf.id%type;
   vt_log_generico_reinf             dbms_sql.number_table;
   --
   vv_mensagem_log                   log_generico_reinf.mensagem%type;
   vv_resumo_log                     log_generico_reinf.resumo%type;
   vt_efd_reinf_r2010                efd_reinf_r2010%rowtype;
   vt_efd_reinf_r2010_new            efd_reinf_r2010%rowtype;
   vn_efdreinfr2010_last_id          efd_reinf_r2010.id%type;
   vn_cont_reg                       number:= 0;
   --
begin
   --
   vn_fase := 1;
   --
   vt_efd_reinf_r2010       := null;
   vt_efd_reinf_r2010_new   := null;
   vn_efdreinfr2010_last_id := null;
   vn_cont_reg              := 0;
   --
   vn_fase := 2;
   --
   begin
      --
      select *
        into vt_efd_reinf_r2010
        from efd_reinf_r2010
       where id = en_efdreinfr2010_id;
      --
   exception
    when others then
      vt_efd_reinf_r2010 := null;
   end;
   --
   vn_fase := 3;
   --
   -- Recupera os dados da Abertura do EFD-REINF
   pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => vt_efd_reinf_r2010.geracaoefdreinf_id );
   --
   if nvl(gt_row_geracao_efd_reinf.dm_situacao, 0) = 2 then  -- 2-Aberto
      --
      if nvl(vt_efd_reinf_r2010.id,0) > 0 then
         --
         vn_fase := 4;
         --
         vv_resumo_log := 'Procedimento de Retificação do Evento R-2010 (Nota Fiscais de Entrada) do Estabelecimento: '||
                          pk_csf.fkg_cod_nome_empresa_id ( vt_efd_reinf_r2010.empresa_id )|| ', no período de '||
                          trim(to_char(gt_row_geracao_efd_reinf.dt_ini, 'month')) || ' de ' ||
                          to_char(gt_row_geracao_efd_reinf.dt_ini,'yyyy');
         --
         vn_fase := 5;
         --
         delete log_generico_reinf
          where obj_referencia = 'EFD_REINF_R2010'
            and referencia_id  = vt_efd_reinf_r2010.id;
         --
         vn_fase := 6;
         --
            if vt_efd_reinf_r2010.dm_st_proc in (4,8) then -- 4-Processado; 8-Processado R-5001
               --
               vn_fase := 7;
               -- Conta o número de notas fiscais de entrada que estão relacionadas ao evento R-2010
               begin
                  --
                  select count(1) 
                     into vn_cont_reg
                  from (   
                     select 1
                        from efd_reinf_r2010_nf
                     where efdreinfr2010_id = vt_efd_reinf_r2010.id
                       and ev_tipo_doc      = 'NF'
                     UNION ALL --<<
                     select 1
                        from efd_reinf_r2010_cte
                     where efdreinfr2010_id = vt_efd_reinf_r2010.id
                       and ev_tipo_doc      = 'CTE'
                  );
                  --
               exception
                  when others then
                     --
                     vn_cont_reg := 0;
                     --
               end;
               --
               vn_fase := 8;
               -- Se o evento estiver relacionado a apenas uma nota fiscal de entrada e a mesma estiver sendo retificada,
               -- o processo deverá apenas gerar o evento de exclusão R-9000
               if nvl(vn_cont_reg, 0) = 1 then
                  --
                  vn_fase := 9;
                  -- Cria o evento de exclusão R-9000 para o evento R-2010
                  pk_desfazer_dados_reinf.pkb_excluir_evt_r2010(vt_efd_reinf_r2010.id);
                  --
               else
                  --
                  vn_fase := 10;
                  -- Recupera o ID do último evento do grupo R-2010
                  begin
                     --
                     select id
                       into vn_efdreinfr2010_last_id
                       from efd_reinf_r2010
                      where id in ( select max(id)
                                      from efd_reinf_r2010
                                     where empresa_id         = vt_efd_reinf_r2010.empresa_id
                                       and geracaoefdreinf_id = vt_efd_reinf_r2010.geracaoefdreinf_id
                                       and dm_ind_tp_inscr    = vt_efd_reinf_r2010.dm_ind_tp_inscr
                                       and nro_inscr_estab    = vt_efd_reinf_r2010.nro_inscr_estab
                                       and cnpj               = vt_efd_reinf_r2010.cnpj );
                     --
                  end;
                  --
                  vn_fase := 11;
                  --
                  if nvl(vn_efdreinfr2010_last_id, 0) = nvl(vt_efd_reinf_r2010.id, 0) then
                     --
                     vt_efd_reinf_r2010_new.id                   := null;
                     vt_efd_reinf_r2010_new.geracaoefdreinf_id   := vt_efd_reinf_r2010.geracaoefdreinf_id;
                     vt_efd_reinf_r2010_new.empresa_id           := vt_efd_reinf_r2010.empresa_id;
                     vt_efd_reinf_r2010_new.dm_st_proc           := 0; -- 0-Aberto
                     vt_efd_reinf_r2010_new.dm_tipo_reg          := 2; -- 2-Retificado
                     vt_efd_reinf_r2010_new.dm_ind_tp_inscr      := vt_efd_reinf_r2010.dm_ind_tp_inscr;
                     vt_efd_reinf_r2010_new.nro_inscr_estab      := vt_efd_reinf_r2010.nro_inscr_estab;
                     vt_efd_reinf_r2010_new.cnpj                 := vt_efd_reinf_r2010.cnpj;
                     vt_efd_reinf_r2010_new.pessoa_id            := vt_efd_reinf_r2010.pessoa_id;
                     vt_efd_reinf_r2010_new.ar_efdreinfr2010_id  := vt_efd_reinf_r2010.id;
                     --
                     vn_fase := 12;
                     -- Cria o novo evento R-2010
                     pk_csf_api_reinf.pkb_integr_efd_reinf_r2010 ( est_log_generico_reinf  => vt_log_generico_reinf
                                                                 , est_row_efdreinfr2010   => vt_efd_reinf_r2010_new
                                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                                 );
                     --
                     vn_fase := 13;
                     --
                     if nvl(vt_efd_reinf_r2010_new.id, 0) > 0 then
                        -- Recupera e relaciona as notas fiscais de entrada do evento anterior com o novo evento gerado
                        pkb_rec_doc_evt_anterior_r2010 ( est_log_generico_reinf  => vt_log_generico_reinf
                                                       , en_efdreinfr2010_old_id => vt_efd_reinf_r2010.id
                                                       , en_efdreinfr2010_new_id => vt_efd_reinf_r2010_new.id
                                                       );
                        --
                        vn_fase := 13.1;
                        --
                        -- Notas Fiscais --
                        if ev_tipo_doc = 'NF' then
                           --
                           vn_fase := 13.11;
                           --
                           -- Exclui a nota fiscal de entrada "retificada" do novo evento R-2010
                           delete efd_reinf_r2010_nf
                            where efdreinfr2010_id = vt_efd_reinf_r2010_new.id
                              and notafiscal_id    = en_documento_id; --Nota fiscal de entrada "retificada"
                           --
                           vn_fase := 13.12;
                           -- Atualiza a situação "dm_envio = 0" para a nota fiscal de entrada "retificada"
                           update nota_fiscal
                              set dm_envio_reinf = 1       -- 1-Enviado
                            where id = en_documento_id;    -- Nota fiscal de entrada "retificada" 
                           --
                        -- Conhecimento de Transporte --   
                        elsif ev_tipo_doc = 'CTE' then
                           --
                           vn_fase := 13.13;
                           --
                           -- Exclui o Conhecimento de Transporte "retificada" do novo evento R-2010
                           delete efd_reinf_r2010_cte
                            where efdreinfr2010_id = vt_efd_reinf_r2010_new.id
                              and conhectransp_id  = en_documento_id;    -- Conhecimento de Transporte de Aquisição "retificado"
                           --
                           vn_fase := 13.14;
                           -- Atualiza a situação "dm_envio = 0" para o conhecimento de transporte de Aquisição "retificada"
                           update conhec_transp
                              set dm_envio_reinf = 1      -- 1-Enviado
                            where id = en_documento_id;   -- Conhecimento de Transporte "retificado" 
                           --
                        end if;
                        --
                     end if;
                     --
                     vn_fase := 14;
                     --
                     if nvl(vt_log_generico_reinf.count,0) = 0 then
                        --
                        update efd_reinf_r2010
                           set dm_st_proc = 1 -- Validado
                         where id = vt_efd_reinf_r2010_new.id;
                        --
                     else
                        --
                        update efd_reinf_r2010
                           set dm_st_proc = 2 -- Erro de validação
                         where id = vt_efd_reinf_r2010_new.id;
                        --
                     end if;
                     --
                  if nvl(gt_row_efd_reinf_r2010.id, 0) = 0 then
                     gt_row_efd_reinf_r2010.id := vt_efd_reinf_r2010_new.id;
                  end if;   
                  --
                     vn_fase := 15;
                     --
                     -- Gerar o ID para o novo evento criado
                     pkb_gera_id_evt_reinf ( ev_obj_referencia => 'EFD_REINF_R2010'
                                           , en_referencia_id  => vt_efd_reinf_r2010_new.id--gt_row_efd_reinf_r2010.id
                                           );
                     --
                  else
                     --
                     vn_fase := 16;
                     --
                     vv_mensagem_log := 'Evento não pode ser retificado pois não é o último evento gerado para o grupo de informação, favor verificar.';
                     --
                     pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                             , ev_mensagem             => vv_resumo_log ||' '|| vv_mensagem_log
                                                             , ev_resumo               => vv_mensagem_log
                                                             , en_tipo_log             => pk_csf_api_reinf.informacao
                                                             , en_referencia_id        => vt_efd_reinf_r2010.id
                                                             , ev_obj_referencia       => 'EFD_REINF_R2010'
                                                             , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                             );
                     --
                  end if;
                  --
               end if;
               --
            else  -- 0-Aberto; 1-Validado; 2-Erro de Validação; 3-Aguardando Envio; 5-Erro no Envio; 6-Erro na montagem do XML; 7-Excluído
               --
               vn_fase := 17;
               --
               vv_mensagem_log := 'O evento R-2010 não pode ser retificado pois está com a situação "'||pk_csf.fkg_dominio('EFD_REINF_R2010.DM_ST_PROC', vt_efd_reinf_r2010.dm_st_proc)||
                               '", favor verificar.';
               --
               pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                       , ev_mensagem             => vv_resumo_log ||' '|| vv_mensagem_log
                                                       , ev_resumo               => vv_mensagem_log
                                                       , en_tipo_log             => pk_csf_api_reinf.informacao
                                                       , en_referencia_id        => vt_efd_reinf_r2010.id
                                                       , ev_obj_referencia       => 'EFD_REINF_R2010'
                                                       , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                       );
               --
            end if;
            --
      end if;
      --
   else
      --
      vn_fase := 18;
      --
      vv_mensagem_log := 'Evento não pode ser retificado pois a situação do evento é diferente de "Aberto", favor verificar.';
      --
      pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                              , ev_mensagem             => vv_resumo_log ||' '|| vv_mensagem_log
                                              , ev_resumo               => vv_mensagem_log
                                              , en_tipo_log             => pk_csf_api_reinf.informacao
                                              , en_referencia_id        => vt_efd_reinf_r2010.id
                                              , ev_obj_referencia       => 'EFD_REINF_R2010'
                                              , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                             );
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      rollback;
      --
      --
      pk_csf_api_reinf.gv_mensagem_log := 'Erro na pk_gera_dados_reinf.pkb_retif_evt_r2010 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => vv_resumo_log || pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                 , en_tipo_log             => pk_csf_api_reinf.ERRO_DE_SISTEMA
                                                 , en_referencia_id        => pk_csf_api_reinf.gn_referencia_id
                                                 , ev_obj_referencia       => pk_csf_api_reinf.gv_obj_referencia
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_retif_evt_r2010;

---------------------------------------------------------------------------------------------------
-- Procedimento que cria um novo evento de Reenvio para os eventos com Erro no Envio ou Erro na montagem do XML
procedure pkb_reenviar_evt_r2010 ( en_efdreinfr2010_id in efd_reinf_r2010.id%type
                                 )
is
   --
   vn_fase                      number;
   vn_loggenericoreinf_id       log_generico_reinf.id%type;
   vn_efdreinfr2010_last_id     efd_reinf_r2010.id%type;
   --
   vt_efd_reinf_r2010           efd_reinf_r2010%rowtype;
   vt_log_generico_reinf        dbms_sql.number_table;
   --
begin
   --
   vn_fase := 1;
   --
   vt_efd_reinf_r2010     := null;
   vn_loggenericoreinf_id := null;
   --
   if nvl(en_efdreinfr2010_id,0) > 0 then
      --
      vn_fase := 2;
      --
      begin
         --
         select *
           into vt_efd_reinf_r2010
           from efd_reinf_r2010
          where id = en_efdreinfr2010_id;
         --
      exception
       when others then
         vt_efd_reinf_r2010 := null;
      end;
      --
      vn_fase := 3;
      -- Recupera os dados da Abertura do EFD-REINF
      pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => vt_efd_reinf_r2010.geracaoefdreinf_id );
      --
      vn_fase := 4;
      --
      delete log_generico_reinf
       where obj_referencia = 'EFD_REINF_R2010'
         and referencia_id  = vt_efd_reinf_r2010.id;
      --
      vn_fase := 5;
      --
      if nvl(vt_efd_reinf_r2010.id, 0) > 0
         and vt_efd_reinf_r2010.dm_st_proc in (5,6) then -- 5-Erro no Envio; 6-Erro na montagem do XML
         --
         vn_fase := 6;
         --
         vn_efdreinfr2010_last_id := null;
         -- Verificar se este é o último evento do grupo do R-2010
         begin
            --
            select max(id)
              into vn_efdreinfr2010_last_id
              from efd_reinf_r2010
             where empresa_id         = vt_efd_reinf_r2010.empresa_id
               and geracaoefdreinf_id = vt_efd_reinf_r2010.geracaoefdreinf_id
               and dm_ind_tp_inscr    = vt_efd_reinf_r2010.dm_ind_tp_inscr
               and nro_inscr_estab    = vt_efd_reinf_r2010.nro_inscr_estab
               and cnpj               = vt_efd_reinf_r2010.cnpj;
            --
         exception
          when others then
             vn_efdreinfr2010_last_id := null;
         end;
         --
         vn_fase := 7;
         --
         if nvl(vn_efdreinfr2010_last_id,0) = nvl(vt_efd_reinf_r2010.id,0) then
            --
            vn_fase := 8;
            --
            gt_row_efd_reinf_r2010 := vt_efd_reinf_r2010;
            --
            gt_row_efd_reinf_r2010.dm_st_proc      := 0;  -- 0-Aberto.
            gt_row_efd_reinf_r2010.loteefdreinf_id := null;
            --
            vn_fase := 9;
            --
            pk_csf_api_reinf.pkb_integr_efd_reinf_r2010 ( est_log_generico_reinf => vt_log_generico_reinf
                                                        , est_row_efdreinfr2010  => gt_row_efd_reinf_r2010
                                                        , en_empresa_id          => gt_row_geracao_efd_reinf.empresa_id
                                                        );
            --
            vn_fase := 10;
            --
            if nvl(gt_row_efd_reinf_r2010.id,0) > 0 then
               -- Recupera e relaciona as notas fiscais do evento anterior com o novo evento gerado
               pkb_rec_doc_evt_anterior_r2010 ( est_log_generico_reinf  => vt_log_generico_reinf
                                              , en_efdreinfr2010_old_id => gt_row_efd_reinf_r2010.id
                                              , en_efdreinfr2010_new_id => gt_row_efd_reinf_r2010.id
                                              );
               --
               vn_fase := 11;
               --
               if nvl(vt_log_generico_reinf.count,0) > 0 then
                  --
                  update efd_reinf_r2010
                     set dm_st_proc = 2
                   where id = gt_row_efd_reinf_r2010.id;
                  --
               else
                  --
                  update efd_reinf_r2010
                     set dm_st_proc = 1
                   where id = gt_row_efd_reinf_r2010.id;
                  --
               end if;
               --
            end if;
            --
         else
            --
            pk_csf_api_reinf.gv_mensagem_log := 'Está sendo reenviado um evento R-2010 ( efdreinfr2010_id = '|| vt_efd_reinf_r2010.id ||') antigo, já existe um novo evento criado para o grupo, Favor Verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                    , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                    , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                    , en_tipo_log             => INFORMACAO
                                                    , en_referencia_id        => vt_efd_reinf_r2010.id
                                                    , ev_obj_referencia       => 'EFD_REINF_R2010'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
         end if;
         --
      else
         --
         pk_csf_api_reinf.gv_mensagem_log := 'Situação "'|| pk_csf.fkg_dominio ( 'EFD_REINF_R2010.DM_ST_PROC', vt_efd_reinf_r2010.dm_st_proc ) ||'" do Evento R-2010 (efdreinfr2010_id = '||vt_efd_reinf_r2010.id||') não é permitido a geração do evento de reenvio';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => vt_efd_reinf_r2010.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2010'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
      end if;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_reenviar_evt_r2010 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => vt_efd_reinf_r2010.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2010'
                                                 , en_empresa_id           => vt_efd_reinf_r2010.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_reenviar_evt_r2010;
--
---------------------------------------------------------------------------------------------------
-- Procedimento que irá Montar o Array para que seja
procedure pkb_monta_array_r2010 ( en_geracaoefdreinf_id in geracao_efd_reinf.id%type )
is
   --
   vn_fase                  number;
   vv_cnpj_prestador        varchar2(14);
   vv_cnpj_tomador          varchar2(14);
   vn_indx1                 number;
   vn_idx_evt               number := 0;
   vn_idx_doc               number := 0;
   --
   vn_loggenerico_id        log_generico.id%type;
   vb_achou                 boolean;
   vn_loggenericoreinf_id   log_generico_reinf.id%type;
   vt_log_generico_reinf    dbms_sql.number_table;
   --
   -- Cursor para recuperar as notas fiscais de entrada relacionadas as empresas filiais
   cursor c_nfs is
   select distinct nf.id notafiscal_id
        , nf.nro_nf
        , nf.pessoa_id
        , nfdc.dm_ind_obra
        , nf.empresa_id
        , nf.serie
        , nfdc.nro_cno
        , trunc(nf.dt_emiss) dt_emiss
        , to_number(nvl(ii.aliq_apli,0))                       aliq_apli_inss
        , to_number(decode(inf.dm_ind_cprb, 0, 11, 1, 3.5, 0)) aliq_cprb
        , nvl(nft.vl_total_serv,0)                             vl_total_serv
     from geracao_efd_reinf      ger
        , empresa                  e
        , nota_fiscal             nf
        , item_nota_fiscal       inf
        , imp_itemnf              ii
        , tipo_imposto            ti
        , nfs_det_constr_civil  nfdc
        , mod_fiscal              mf
        , nota_fiscal_total      nft
    where /*e.id                    = ger.empresa_id*/ /*in (select ger.empresa_id from dual union all select id from empresa e where e.ar_empresa_id = ger.empresa_id)*/
     (e.id                        = ger.empresa_id 
      or  e.id    in (select e2.id from empresa e1, empresa e2  where e2.ar_empresa_id = e1.id and e1.id = ger.empresa_id ))
      and nf.empresa_id           = e.id
      and nf.id                   = inf.notafiscal_id
      and ii.itemnf_id            = inf.id
      and nft.notafiscal_id   (+) = nf.id
      and ii.tipoimp_id           = ti.id
      and mf.id                   = nf.modfiscal_id
      and nfdc.notafiscal_id (+)  = nf.id
      --
      and ger.id                  = en_geracaoefdreinf_id
      and nf.dm_st_proc           = 4 -- Autorizada
      and nf.dm_ind_emit          = 1 -- Terceiro
      and nf.dm_ind_oper          = 0 -- Entrada
      and nf.dm_arm_nfe_terc      = 0 -- Não pegar notas do MIDAS. (armazenamento)
      and nf.dt_emiss             between gt_row_geracao_efd_reinf.dt_ini
                                      and gt_row_geracao_efd_reinf.dt_fin
      and ti.cd                   = 13 -- INSS
      and ii.dm_tipo              = 1  -- Retido
      and nvl(ii.vl_imp_trib, 0)  > 0
      and nvl(ii.vl_base_calc, 0) > 0
      and ((mf.cod_mod   = '99') or (mf.cod_mod = '55' and inf.cd_lista_serv is not null))
      and nf.dm_arm_nfe_terc      = 0 -- Não pegar nota de amarzenamento
      and nf.dm_envio_reinf       = 0 -- Não Enviada
      --
      and exists (select 1
                    from juridica ju
                   where ju.pessoa_id = nf.pessoa_id
                   union
                  select 1
                    from nota_fiscal_emit  nfe
                   where nfe.notafiscal_id = nf.id
                     and trim(nfe.cnpj) is not null);
   --
   -- Informações do Evento R-2010 (CTe - Aquisição)
   cursor c_cte is
   select distinct
          ct.id conhectransp_id
        , ct.nro_ct
        , ct.serie
        , ct.dt_hr_emissao
        , ct.empresa_id
        , ct.pessoa_id
     from geracao_efd_reinf     ger
        , empresa                 e
        , conhec_transp          ct
        , conhec_transp_imp_ret cti
        , tipo_imposto           ti
        , mod_fiscal             mf
    where /*e.id                 = ger.empresa_id*/ /*in (select ger.empresa_id from dual union all select id from empresa e where e.ar_empresa_id = ger.empresa_id)*/
     (e.id                        = ger.empresa_id 
      or  e.id    in (select e2.id from empresa e1, empresa e2  where e2.ar_empresa_id = e1.id and e1.id = ger.empresa_id ))
      and ct.empresa_id        = e.id
      and cti.conhectransp_id  = ct.id
      and ti.id                = cti.tipoimp_id
      and mf.id                = ct.modfiscal_id
      --
      and ger.id               = en_geracaoefdreinf_id
      and ct.dt_hr_emissao     between gt_row_geracao_efd_reinf.dt_ini
                                   and gt_row_geracao_efd_reinf.dt_fin
      and ct.dm_envio_reinf    = 0    -- Não Enviada
      and ct.dm_st_proc        = 4    -- Autorizada
      and ct.dm_ind_emit       = 1    -- Terceiro
      and ct.dm_ind_oper       = 0    -- Aquisição (Entrada)
      and mf.cod_mod           = '67' -- Conhecimento de Transporte Eletrônico - Outros Serviços
      --
      and ti.cd                = '13' -- INSS
      and ct.dm_arm_cte_terc   = 0    -- Pegar somente CTes convertidos
      --
      and exists (select 1
                    from juridica ju
                   where ju.pessoa_id = ct.pessoa_id
                   union
                  select 1
                    from conhec_transp_emit  cte
                   where cte.conhectransp_id = ct.id
                     and trim(cte.cnpj) is not null);
   --
begin
   --
   vn_loggenericoreinf_id := null;
   --
   vn_fase := 1;
   -- Notas Fiscais ----------------------------------------------------------
   for rec_nf in c_nfs loop
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_fase := 1.2;
      --
      vn_indx1 := null;
      --
      vn_indx1 := nvl(rec_nf.empresa_id,0)||nvl(rec_nf.dm_ind_obra,0);
      --
      vv_cnpj_prestador := null;
      --
      -- Recuperar o CNPJ do Prestador da Nota Fiscal.
      begin
         --
         select trim( lpad(j.NUM_CNPJ, 8, '0') || lpad(j.NUM_FILIAL, 4, '0') || lpad(j.DIG_CNPJ, 2, '0') ) cnpj_cpf
           into vv_cnpj_prestador
           from juridica j
          where j.pessoa_id = nvl(rec_nf.pessoa_id,0);
         --
      exception
         when others then
            vv_cnpj_prestador := null;
      end;
      --
      vn_fase := 1.3;
      --
      -- Caso não exista o cadastro do participante (Prestador) recuperar do detalhamento da nota.
      if trim(vv_cnpj_prestador) is null then
         --
         begin
            --
            select cnpj
              into vv_cnpj_prestador
              from nota_fiscal_emit
             where notafiscal_id = rec_nf.notafiscal_id;
            --
         exception
           when others then
            vv_cnpj_prestador := null;
         end;
         --
      end if;
      --
      vn_fase := 1.4;
      --
      if rec_nf.vl_total_serv = 0 then
         --
         gv_mensagem := 'A nota fiscal de saída nro: '|| rec_nf.nro_nf || ', serie: '|| rec_nf.serie ||' e data de emissão: '|| rec_nf.dt_emiss ||' do estabelecimento filial/matriz ' ||
                        pk_csf.fkg_cod_nome_empresa_id ( rec_nf.empresa_id ) || ' não será possível enviar para o REINF por conta de falta de informação. (Valor Total do Serviço na nota)';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
      end if;
      --
      vn_fase := 1.5;
      --
      -- Caso não exista o CNPJ do participante (Prestador) não é possivel enviar os dados relacionado, será gerado um log para que o usuario corrija posteriormente
      if trim(vv_cnpj_prestador) is null then
         --
         gv_mensagem := 'A nota fiscal de entrada nro: '|| rec_nf.nro_nf || ', série: '|| rec_nf.serie ||' e data de emissão: '|| rec_nf.dt_emiss ||' do estabelecimento filial/matriz ' ||
                        pk_csf.fkg_cod_nome_empresa_id ( rec_nf.empresa_id ) || ' não será enviada para o REINF por falta de informação. (CNPJ do participante (Prestador) da nota)';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
      end if;
      --
      vn_fase := 1.6;
      --
      vv_cnpj_tomador := null;
      --
      -- Se a Empresa for uma Obra, utilizar o Número do CNO no lugar do CNPJ
      if nvl(rec_nf.dm_ind_obra,0) > 0 then
         --
         vv_cnpj_tomador := rec_nf.nro_cno;
         --
      else
         --
         vv_cnpj_tomador := pk_csf.fkg_cnpj_ou_cpf_empresa (rec_nf.empresa_id);
         --
      end if;
      --
      -- Verifica se já existe um evento para o mesmo tomador e prestador
      begin
         --
         vb_achou := false;
         --
         for i in vt_evento_r2010.first .. vt_evento_r2010.last
         loop
           --
           if vt_evento_r2010(i).cnpj_tomador   = vv_cnpj_tomador    and
              vt_evento_r2010(i).cnpj_prestador = vv_cnpj_prestador then
              --
              vb_achou   := True;
              vn_idx_evt := vt_evento_r2010(i).idx_evento;
              exit;
              --
           end if; 
           --
         end loop;
      exception
         when others then
            vb_achou := false;
      end;
      --
      vn_fase := 1.7;
      --
      if not vb_achou then
         --
         vn_fase := 1.71;
         --
         --vt_tri_tab_index_evt_r2010(vn_indx1)(vv_cnpj_tomador)(vv_cnpj_prestador).indx_doc_id      := i; -- Apenas para utilizar como indice para recup as notas
         --vt_tri_tab_index_evt_r2010(vn_indx1)(vv_cnpj_tomador)(vv_cnpj_prestador).empresa_id       := rec_nf.empresa_id;
         --vt_tri_tab_index_evt_r2010(vn_indx1)(vv_cnpj_tomador)(vv_cnpj_prestador).cnpj_part        := vv_cnpj_prestador;
         --vt_tri_tab_index_evt_r2010(vn_indx1)(vv_cnpj_tomador)(vv_cnpj_prestador).dm_ind_obra      := nvl(rec_nf.dm_ind_obra,0);
         --vt_tri_tab_index_evt_r2010(vn_indx1)(vv_cnpj_tomador)(vv_cnpj_prestador).nro_inscr_estab  := vv_cnpj_tomador;
         --vt_tri_tab_index_evt_r2010(vn_indx1)(vv_cnpj_tomador)(vv_cnpj_prestador).tipo             := 'N'; -- Tipo Nota Fiscal
         vn_idx_evt := nvl(vt_evento_r2010.Count,0) + 1;
         vt_evento_r2010(vn_idx_evt).idx_evento     := vn_idx_evt;
         vt_evento_r2010(vn_idx_evt).empresa_id     := rec_nf.empresa_id;
         vt_evento_r2010(vn_idx_evt).dm_ind_obra    := nvl(rec_nf.dm_ind_obra,0);
         vt_evento_r2010(vn_idx_evt).cnpj_tomador   := vv_cnpj_tomador;
         vt_evento_r2010(vn_idx_evt).cnpj_prestador := vv_cnpj_prestador;
         --
--         vt_bi_tab_index_evt_r2010_nf(i)(rec_nf.notafiscal_id).notafiscal_id   := rec_nf.notafiscal_id;
--         vt_bi_tab_index_evt_r2010_nf(i)(rec_nf.notafiscal_id).cnpj            := vv_cnpj_tomador;
--         vt_bi_tab_index_evt_r2010_nf(i)(rec_nf.notafiscal_id).passou_ind_cprb := case when rec_nf.aliq_apli_inss = rec_nf.aliq_cprb then 1 else 0 end; -- 0: Não passou no teste / 1: Passou no teste
--         vt_bi_tab_index_evt_r2010_nf(i)(rec_nf.notafiscal_id).nro_nf          := rec_nf.nro_nf;
--         vt_bi_tab_index_evt_r2010_nf(i)(rec_nf.notafiscal_id).serie           := rec_nf.serie;
--         vt_bi_tab_index_evt_r2010_nf(i)(rec_nf.notafiscal_id).aliq_apli_inss  := rec_nf.aliq_apli_inss;
--         vt_bi_tab_index_evt_r2010_nf(i)(rec_nf.notafiscal_id).aliq_cprb       := rec_nf.aliq_cprb;
         --   
         vn_idx_doc := nvl(vt_evento_r2010_doc.Count,0) + 1;
         vt_evento_r2010_doc(vn_idx_doc).idx_evento     := vn_idx_evt;
         vt_evento_r2010_doc(vn_idx_doc).documento_id   := rec_nf.notafiscal_id;
         vt_evento_r2010_doc(vn_idx_doc).tipo_documento := 'N';
         --
      else
         --
         vn_fase := 1.72;
--         vt_bi_tab_index_evt_r2010_nf(vt_tri_tab_index_evt_r2010(vn_indx1)(vv_cnpj_tomador)(vv_cnpj_prestador).indx_doc_id)(rec_nf.notafiscal_id).notafiscal_id := rec_nf.notafiscal_id;
--         vt_bi_tab_index_evt_r2010_nf(vt_tri_tab_index_evt_r2010(vn_indx1)(vv_cnpj_tomador)(vv_cnpj_prestador).indx_doc_id)(rec_nf.notafiscal_id).cnpj          := vv_cnpj_tomador;
         --
         vn_idx_doc := nvl(vt_evento_r2010_doc.Count,0) + 1;
         vt_evento_r2010_doc(vn_idx_doc).idx_evento     := vn_idx_evt;
         vt_evento_r2010_doc(vn_idx_doc).documento_id   := rec_nf.notafiscal_id;
         vt_evento_r2010_doc(vn_idx_doc).tipo_documento := 'N';
         --
      end if;
      --
   end loop;
   --
   vn_fase := 2;
   -- Conhecimento de Transporte de Aquisição --------------------------------
   i := 0;
   for rec_cte in c_cte loop
      exit when c_cte%notfound or (c_cte%notfound) is null;
      --
      vn_fase := 2.1;
      --
      vn_indx1 := null;
      --
      vn_indx1 := nvl(rec_cte.empresa_id,0);
      --
      vv_cnpj_prestador := null;
      --
      -- Recuperar o CNPJ do Participante do Conhecimento de Transporte.
      begin
         --
         select trim( lpad(j.num_cnpj, 8, '0') || lpad(j.num_filial, 4, '0') || lpad(j.dig_cnpj, 2, '0') ) cnpj_cpf
           into vv_cnpj_prestador
           from juridica j
          where j.pessoa_id = nvl(rec_cte.pessoa_id,0);
         --
      exception
         when others then
            vv_cnpj_prestador := null;
      end;
      --
      vn_fase := 2.2;
      --
      -- Caso não exista o cadastro do participante recuperar do detalhamento do Conhecimento de Transporte.
      if trim(vv_cnpj_prestador) is null then
         --
         begin
            --
            select max(cnpj)
              into vv_cnpj_prestador
              from conhec_transp_emit
             where conhectransp_id = rec_cte.conhectransp_id;
            --
         exception
           when others then
            vv_cnpj_prestador := null;
         end;
         --
      end if;
      --
      vn_fase := 2.3;
      --
      -- Caso não exista o CNPJ do participante não é possivel enviar os dados relacionado, será gerado um log para que o usuario corrija posteriormente
      if trim(vv_cnpj_prestador) is null then
         --
         gv_mensagem := 'O Conhecimento de Transporte de Aquisição nro: '|| rec_cte.nro_ct || ', série: '|| rec_cte.serie ||' e data de emissão: '|| to_char(rec_cte.dt_hr_emissao,'dd/mm/yyyy') ||' do estabelecimento filial/matriz ' ||
                        pk_csf.fkg_cod_nome_empresa_id ( rec_cte.empresa_id ) || ' não será enviada para o REINF por falta de informação. (CNPJ do participante da nota)';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
      end if;
      --
      vn_fase := 2.4;
      --
      vv_cnpj_tomador := pk_csf.fkg_cnpj_ou_cpf_empresa (rec_cte.empresa_id);
      --
      -- Verifica se já existe um evento para o mesmo tomador e prestador
      begin
         --
         vb_achou := false;
         --
         for i in vt_evento_r2010.first .. vt_evento_r2010.last
         loop
           --
           if vt_evento_r2010(i).cnpj_tomador   = vv_cnpj_tomador    and
              vt_evento_r2010(i).cnpj_prestador = vv_cnpj_prestador then
              --
              vb_achou   := True;
              vn_idx_evt := vt_evento_r2010(i).idx_evento;
              exit;
              --
           end if; 
           --
         end loop;
      exception
         when others then
            vb_achou := false;
      end;
      --
      vn_fase := 2.5;
      --
      if not vb_achou then
         --
         vn_fase := 2.51;
         --
         i := nvl(i,0) + 1;
         --
--         vt_tri_tab_index_evt_r2010(vn_indx1)(vv_cnpj_tomador)(vv_cnpj_prestador).indx_doc_id      := i; -- Apenas para utilizar como indice para recup as notas
--         vt_tri_tab_index_evt_r2010(vn_indx1)(vv_cnpj_tomador)(vv_cnpj_prestador).empresa_id       := rec_cte.empresa_id;
--         vt_tri_tab_index_evt_r2010(vn_indx1)(vv_cnpj_tomador)(vv_cnpj_prestador).cnpj_part        := vv_cnpj_prestador;
--         vt_tri_tab_index_evt_r2010(vn_indx1)(vv_cnpj_tomador)(vv_cnpj_prestador).dm_ind_obra      := 0; -- CTe não controla Obra
--         vt_tri_tab_index_evt_r2010(vn_indx1)(vv_cnpj_tomador)(vv_cnpj_prestador).nro_inscr_estab  := vv_cnpj_tomador;
--         vt_tri_tab_index_evt_r2010(vn_indx1)(vv_cnpj_tomador)(vv_cnpj_prestador).tipo             := 'C'; -- Tipo Conhecimento de Transporte
--
         vn_idx_evt := nvl(vt_evento_r2010.Count,0) + 1;
         vt_evento_r2010(vn_idx_evt).idx_evento     := vn_idx_evt;
         vt_evento_r2010(vn_idx_evt).empresa_id     := rec_cte.empresa_id;
         vt_evento_r2010(vn_idx_evt).dm_ind_obra    := 0; -- CTe não controla Obra
         vt_evento_r2010(vn_idx_evt).cnpj_tomador   := vv_cnpj_tomador;
         vt_evento_r2010(vn_idx_evt).cnpj_prestador := vv_cnpj_prestador;
         --
--         vt_bi_tab_index_evt_r2010_cte(i)(rec_cte.conhectransp_id).conhectransp_id := rec_cte.conhectransp_id;
--         vt_bi_tab_index_evt_r2010_cte(i)(rec_cte.conhectransp_id).cnpj            := vv_cnpj_tomador;
         --
         vn_idx_doc := nvl(vt_evento_r2010_doc.Count,0) + 1;
         vt_evento_r2010_doc(vn_idx_doc).idx_evento     := vn_idx_evt;
         vt_evento_r2010_doc(vn_idx_doc).documento_id   := rec_cte.conhectransp_id;
         vt_evento_r2010_doc(vn_idx_doc).tipo_documento := 'C';
         --         
      else
         --
         vn_fase := 2.52;
--         vt_bi_tab_index_evt_r2010_cte(vt_tri_tab_index_evt_r2010(vn_indx1)(vv_cnpj_tomador)(vv_cnpj_prestador).indx_doc_id)(rec_cte.conhectransp_id).conhectransp_id := rec_cte.conhectransp_id;
--         vt_bi_tab_index_evt_r2010_cte(vt_tri_tab_index_evt_r2010(vn_indx1)(vv_cnpj_tomador)(vv_cnpj_prestador).indx_doc_id)(rec_cte.conhectransp_id).cnpj            := vv_cnpj_tomador;
         --
         vn_idx_doc := nvl(vt_evento_r2010_doc.Count,0) + 1;
         vt_evento_r2010_doc(vn_idx_doc).idx_evento     := vn_idx_evt;
         vt_evento_r2010_doc(vn_idx_doc).documento_id   := rec_cte.conhectransp_id;
         vt_evento_r2010_doc(vn_idx_doc).tipo_documento := 'C';
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_monta_array_r2010 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_monta_array_r2010;

---------------------------------------------------------------------------------------------------
-- Processo de Geração de Evento R-2010
procedure pkb_gera_evt_r2010
is
   --
   vn_fase                  number;
   vn_ind1                  varchar2(14);
   vn_ind2                  varchar2(14);
   --
   vn_ind3                  varchar2(14);
   vn_dm_ind_tp_inscr       efd_reinf_r2010.dm_ind_tp_inscr%type;
   vt_log_generico_reinf    dbms_sql.number_table;
   vt_2010_erros            dbms_sql.number_table;
   vv_mensagem              log_generico_reinf.mensagem%type;
   vn_loggenericoreinf_id   log_generico_reinf.id%type;
   --
   vn_efdreinfr2010_id             efd_reinf_r2010.id%type;
   vn_dm_tipo_reg                  efd_reinf_r2010.dm_tipo_reg%type;
   vn_dm_st_proc                   efd_reinf_r2010.dm_st_proc%type;
   --
begin
   --
   vn_fase := 1;
   --
   i := null;
   vt_tri_tab_index_evt_r2010.delete;
   vt_bi_tab_index_evt_r2010_nf.delete;
   vt_bi_tab_index_evt_r2010_cte.delete;
   --
   vn_fase := 2;
   --
   -- Recuperar/Montar indexes baseado no layout disponibilizado no EFD-REINF conforme
   -- existentes tanto a empresa matriz quanto as filiais
   --
   pkb_monta_array_r2010 (gt_row_geracao_efd_reinf.id);
   --
   vn_fase := 3;
   --
   -- Caso não haja dados neste array, será executado o goto sair_proc.
   if nvl(vt_evento_r2010.count,0) = 0 then
      --
      goto sair_proc;
      --
   end if;
   --
   -- Varre o array de eventos para gerar os documentos fiscais.
   for evt in vt_evento_r2010.First .. vt_evento_r2010.Last
   loop
      --
      vn_fase := 4;
      --
      --
      if nvl(vt_evento_r2010(evt).dm_ind_obra,0) = 0 then
         --
         vn_dm_ind_tp_inscr := 1; -- CNPJ
         --
      else
         --
         vn_dm_ind_tp_inscr := 4; -- CNO
         --
      end if;      
      --
      vn_fase := 5;
      --
      -- Verificar se ja existe Evento para o Indice de dentro do Periodo
      begin
         --
         select id
              , dm_tipo_reg
              , dm_st_proc
           into vn_efdreinfr2010_id
              , vn_dm_tipo_reg
              , vn_dm_st_proc
           from efd_reinf_r2010
          where id in ( select max(err.id)
                          from efd_reinf_r2010 err
                         where err.empresa_id         = vt_evento_r2010(evt).empresa_id -- Estab. Matriz/Filial
                           and err.geracaoefdreinf_id = gt_row_geracao_efd_reinf.id
                           and err.dm_ind_tp_inscr    = vn_dm_ind_tp_inscr
                           and err.nro_inscr_estab    = vt_evento_r2010(evt).cnpj_tomador
                           and err.cnpj               = vt_evento_r2010(evt).cnpj_prestador 
                           and err.dm_st_proc         in (0,1,3,4,7,8) ); -- 0-Aberto; 1-Validado; 3-Aguardando Envio; 4-Processado; 7-Excluído; 8-Processado R-5001
         --
      exception
       when others then
         vn_efdreinfr2010_id := null;
         vn_dm_tipo_reg      := null;
         vn_dm_st_proc       := null;
      end;         
      -- 
      vn_fase := 6;
      --
      gt_row_efd_reinf_r2010.id                   := null;
      gt_row_efd_reinf_r2010.geracaoefdreinf_id   := gt_row_geracao_efd_reinf.id;
      gt_row_efd_reinf_r2010.empresa_id           := vt_evento_r2010(evt).empresa_id;
      gt_row_efd_reinf_r2010.dm_st_proc           := 0; -- 0-Aberto
      gt_row_efd_reinf_r2010.dm_ind_tp_inscr      := vn_dm_ind_tp_inscr;
      gt_row_efd_reinf_r2010.nro_inscr_estab      := vt_evento_r2010(evt).cnpj_tomador;
      gt_row_efd_reinf_r2010.cnpj                 := vt_evento_r2010(evt).cnpj_prestador;
      gt_row_efd_reinf_r2010.ar_efdreinfr2010_id  := null;                  
      --
      vn_fase := 7;
      --
      -- Tetsta o dm_st_proc do evento.
      if nvl(vn_efdreinfr2010_id,0) > 0 then
         --
         vn_fase := 8;
         --
         if vn_dm_st_proc in (0,1,3) then -- 0-Aberto; 1-Validado; 3-Aguardando Envio
            --
            vv_mensagem := 'O último evento R-2010 está com o tipo de registro "'||pk_csf.fkg_dominio('EFD_REINF_R2010.DM_TIPO_REG', vn_dm_tipo_reg)||
                           '" e com a situação "'||pk_csf.fkg_dominio('EFD_REINF_R2010.DM_ST_PROC', vn_dm_st_proc)||
                           '". Neste caso, não poderá ser gerado um novo evento R-2010. Favor verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                    , ev_mensagem             => gv_resumo || vv_mensagem
                                                    , ev_resumo               => vv_mensagem
                                                    , en_tipo_log             => INFORMACAO
                                                    , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                    , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
            goto sair_proc;
            --
         elsif vn_dm_st_proc in (4,8) then -- 4-Processado; 8-Processado R-5001
            --
            gt_row_efd_reinf_r2010.dm_tipo_reg          := 2; -- 2-Retificado
            gt_row_efd_reinf_r2010.ar_efdreinfr2010_id  := vn_efdreinfr2010_id;
            --
         elsif vn_dm_st_proc = 7 then -- 7-Excluído
            --
            gt_row_efd_reinf_r2010.dm_tipo_reg := 1; -- 1-Original
            --
         end if;
         --
      else
         --
         vn_fase := 9;
         --
         gt_row_efd_reinf_r2010.dm_tipo_reg := 1; --Original
         --
      end if;         
      --
      vn_fase := 10;
      --
      -- Gravar Evento Criado no Banco de Dados
      pk_csf_api_reinf.pkb_integr_efd_reinf_r2010 ( est_log_generico_reinf => vt_log_generico_reinf
                                                  , est_row_efdreinfr2010  => gt_row_efd_reinf_r2010
                                                  , en_empresa_id          => gt_row_geracao_efd_reinf.empresa_id
                                                  );         
      
      

   
      -- Varre os documentos fiscais -----------------------------------   
      vn_fase := 12;
      --
      for doc in vt_evento_r2010_doc.First .. vt_evento_r2010_doc.Last
      loop 
         -- 
         vn_fase := 13;
         --
         if vt_evento_r2010_doc(doc).idx_evento = vt_evento_r2010(evt).idx_evento then -- relacionamento docs fiscais com eventos.
            --
            -- Se for notas fiscais --
            if vt_evento_r2010_doc(doc).tipo_documento = 'N' then
               --
               vn_fase := 14;
               --
               gt_row_efd_reinf_r2010_nf := null;
               --
               gt_row_efd_reinf_r2010_nf.notafiscal_id    := vt_evento_r2010_doc(doc).documento_id;
               gt_row_efd_reinf_r2010_nf.efdreinfr2010_id := gt_row_efd_reinf_r2010.id;
               --
               vn_fase := 15;
               --
               pk_csf_api_reinf.pkb_integr_efdreinfr2010_nf ( est_log_generico_reinf    => vt_log_generico_reinf
                                                            , est_row_efdreinfr2010_nf  => gt_row_efd_reinf_r2010_nf
                                                            , en_empresa_id             => gt_row_geracao_efd_reinf.empresa_id
                                                            );         
               --
            -- Se for Conhecimento de Transporte --
            elsif vt_evento_r2010_doc(doc).tipo_documento = 'C' then
               --
               vn_fase := 16;
               --
               gt_row_efd_reinf_r2010_cte := null;
               --
               gt_row_efd_reinf_r2010_cte.conhectransp_id   := vt_evento_r2010_doc(doc).documento_id;
               gt_row_efd_reinf_r2010_cte.efdreinfr2010_id  := gt_row_efd_reinf_r2010.id;
               --
               vn_fase := 17;
               --
               pk_csf_api_reinf.pkb_integr_efdreinfr2010_cte ( est_log_generico_reinf     => vt_log_generico_reinf
                                                             , est_row_efdreinfr2010_cte  => gt_row_efd_reinf_r2010_cte
                                                             , en_empresa_id              => gt_row_geracao_efd_reinf.empresa_id
                                                             );         
               --
            end if;
            --
         end if;   
         --   
      end loop;
      --
      vn_fase := 18;
      --
      -- Gerar o ID para o controle evento criado
      pkb_gera_id_evt_reinf ( ev_obj_referencia => 'EFD_REINF_R2010'
                            , en_referencia_id  => gt_row_efd_reinf_r2010.id
                            );
      --
      vn_fase := 19;
      --
      -- Armazena os erros encontrados nos eventos
      if nvl(vt_log_generico_reinf.count,0) > 0 then
         --
         vn_fase := 20;
         --
         i := nvl(vt_2010_erros.count,0) + 1;
         --
         vt_2010_erros(i) := gt_row_efd_reinf_r2010.id;
         --
      else   
         --
         vn_fase := 21;
         -- 
         update efd_reinf_r2010
            set dm_st_proc = 1 -- Validado
          where id         = gt_row_efd_reinf_r2010.id
            and dm_st_proc <> 2;
         --
      end if;      
      --
      vt_log_generico_reinf.Delete;
      --
   end loop;
   --
   vn_fase := 22;
   --
   -- Valida o CPRB das Notas Fiscais do Evento R2010
   pkb_valida_cprb_nf_r2010(en_geracaoefdreinf_id  => gt_row_geracao_efd_reinf.id
                          , en_efdreinfr2010_id    => gt_row_efd_reinf_r2010.id
                          , est_log_generico_reinf => vt_log_generico_reinf); 
   --
   vn_fase := 23;
   --
   -- Valida arredondamento imposto INSS para REINF - R2020
   pkb_valida_rnd_inss_r2010(en_geracaoefdreinf_id  => gt_row_geracao_efd_reinf.id
                           , en_efdreinfr2010_id    => gt_row_efd_reinf_r2010.id
                           , est_log_generico_reinf => vt_log_generico_reinf); 
   --                        
   vn_fase := 24;
   --
   -- Recupera e relaciona os documentos do evento anterior com o novo evento gerado em caso de retificação
   --
   if nvl(vn_efdreinfr2010_id, 0) > 0
      and nvl(vn_dm_st_proc, -1) <> 7 then -- 7-Excluído
      --
      pkb_rec_doc_evt_anterior_r2010 ( est_log_generico_reinf  => vt_log_generico_reinf
                                     , en_efdreinfr2010_old_id => vn_efdreinfr2010_id
                                     , en_efdreinfr2010_new_id => gt_row_efd_reinf_r2010.id
                                     );
      --
   end if;
   --
   vn_fase := 25;
   --
   -- Caso encontre algum erro, invalida o evento
   if (nvl(vt_2010_erros.count,0) > 0 or gt_row_geracao_efd_reinf.dm_situacao = 1) then
      --
      --forAll i in 1 .. vt_2010_erros.count
      for i in vt_2010_erros.First .. vt_2010_erros.Last
      loop 	  
         --	  
         update efd_reinf_r2010
            set dm_st_proc = 2 -- Erro de Validação
          where id         = vt_2010_erros(i);
         --	   
      end loop;	   
      --
   else
      --
      update efd_reinf_r2010
         set dm_st_proc = 1 -- Validado
       where id         = gt_row_efd_reinf_r2010.id
         and dm_st_proc <> 2;
      --
   end if;   
   --
   <<sair_proc>>
   --
   null;
   --   
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_gera_evt_r2010 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_gera_evt_r2010;


-------------------------------------------------------------------------------------------------------
-- Processo que recupera os dados do último evento R-1070 gerado
procedure pkb_rec_ultimo_evento_r1070 ( en_procadmefdreinf_id  in proc_adm_efd_reinf.id%type
                                      , en_dm_tp_amb           in geracao_efd_reinf.dm_tp_amb%type
                                      , est_efdreinf_ult_r1070 out nocopy efd_reinf_r1070%rowtype
                                      )
is
begin
   --
   est_efdreinf_ult_r1070 := null;
   --
   select *
     into est_efdreinf_ult_r1070
     from efd_reinf_r1070
    where id in ( select max(er.id)
                    from geracao_efd_reinf  ge
                       , efd_reinf_r1070    er
                       , proc_adm_efd_reinf pa
                   where ge.id         = er.geracaoefdreinf_id
                     and pa.id         = er.procadmefdreinf_id
                     and ge.dm_tp_amb  = en_dm_tp_amb  -- 1-Produção; 2-Produção Restrita
                     and pa.id         = en_procadmefdreinf_id
                     and er.dm_st_proc in (0,1,3,4) ); -- 0-Aberto; 1-Validado; 3-Aguardando Envio; 4-Processado
   --
exception
   when no_data_found then
      est_efdreinf_ult_r1070 := null;
   when others then
      raise_application_error(-20101, 'Erro na pk_gera_dados_reinf.pkb_rec_ultimo_evento_r1070: '||sqlerrm);
end pkb_rec_ultimo_evento_r1070;

---------------------------------------------------------------------------------------------------
-- Procedimento que cria um novo evento de Reenvio para os eventos com Erro no Envio ou Erro na montagem do XML
procedure pkb_reenviar_evt_r1070 ( en_efdreinfr1070_id in efd_reinf_r1070.id%type
                                 )
is
   --
   vn_fase                      number;
   vn_loggenericoreinf_id       log_generico_reinf.id%type;
   vn_efdreinfr1070_last_id     efd_reinf_r1070.id%type;
   --
   vt_efd_reinf_r1070           efd_reinf_r1070%rowtype;
   vt_log_generico_reinf        dbms_sql.number_table;
   --
begin
   --
   vn_fase := 1;
   --
   vt_efd_reinf_r1070     := null;
   vn_loggenericoreinf_id := null;
   --
   if nvl(en_efdreinfr1070_id,0) > 0 then
      --
      vn_fase := 2;
      --
      begin
         --
         select *
           into vt_efd_reinf_r1070
           from efd_reinf_r1070
          where id = en_efdreinfr1070_id;
         --
      exception
       when others then
         vt_efd_reinf_r1070 := null;
      end;
      --
      vn_fase := 3;
      -- Recupera os dados da Abertura do EFD-REINF
      pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => vt_efd_reinf_r1070.geracaoefdreinf_id );
      --
      vn_fase := 4;
      --
      delete log_generico_reinf
       where obj_referencia = 'EFD_REINF_R1070'
         and referencia_id  = gt_row_geracao_efd_reinf.id;
      --
      vn_fase := 5;
      --
      if nvl(vt_efd_reinf_r1070.id, 0) > 0
         and vt_efd_reinf_r1070.dm_st_proc in (5,6) then -- 5-Erro no Envio; 6-Erro na montagem do XML
         --
         vn_fase := 6;
         --
         vn_efdreinfr1070_last_id := null;
         -- Verificar se este é o ultimo evento do Grupo do R-1070
         begin
            --
            select max(id)
              into vn_efdreinfr1070_last_id
              from efd_reinf_r1070
             where geracaoefdreinf_id = vt_efd_reinf_r1070.geracaoefdreinf_id
               and procadmefdreinf_id = vt_efd_reinf_r1070.procadmefdreinf_id;
            --
         exception
          when others then
             vn_efdreinfr1070_last_id := null;
         end;
         --
         vn_fase := 7;
         --
         if nvl(vn_efdreinfr1070_last_id,0) = nvl(vt_efd_reinf_r1070.id,0) then
            --
            vn_fase := 8;
            --
            gt_row_efd_reinf_r1070 := vt_efd_reinf_r1070;
            --
            gt_row_efd_reinf_r1070.dm_st_proc      := 0;  -- 0-Aberto
            gt_row_efd_reinf_r1070.loteefdreinf_id := null;
            --
            pk_csf_api_reinf.pkb_integr_efd_reinf_r1070 ( est_log_generico_reinf   => vt_log_generico_reinf
                                                        , est_row_efd_reinf_r1070  => gt_row_efd_reinf_r1070
                                                        , en_empresa_id            => gt_row_geracao_efd_reinf.empresa_id
                                                        );
            --
            vn_fase := 9;
            --
            if nvl(vt_log_generico_reinf.count,0) > 0 then
               --
               update efd_reinf_r1070
                  set dm_st_proc = 2
                where id = gt_row_efd_reinf_r1070.id;
               --
            else
               --
               update efd_reinf_r1070
                  set dm_st_proc = 1
                where id = gt_row_efd_reinf_r1070.id;
               --
            end if;
            --
         else
            --
            pk_csf_api_reinf.gv_mensagem_log := 'Está sendo reenviado um evento R-1070 ( efdreinfr1070_id = '|| vt_efd_reinf_r1070.id ||') antigo, já existe um novo evento criado para o grupo, Favor Verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                    , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                    , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                    , en_tipo_log             => INFORMACAO
                                                    , en_referencia_id        => vt_efd_reinf_r1070.id
                                                    , ev_obj_referencia       => 'EFD_REINF_R1070'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
         end if;
         --
      else
         --
         pk_csf_api_reinf.gv_mensagem_log := 'Situação "'|| pk_csf.fkg_dominio ( 'EFD_REINF_R1070.DM_ST_PROC', vt_efd_reinf_r1070.dm_st_proc ) ||'" do evento R-1070 (efdreinfr1070_id = '||vt_efd_reinf_r1070.id||') não é permitido a geração do evento de reenvio';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => vt_efd_reinf_r1070.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R1070'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
      end if;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_reenviar_evt_r1070 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => vt_efd_reinf_r1070.id     
                                                 , ev_obj_referencia       => 'EFD_REINF_R1070'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_reenviar_evt_r1070;

---------------------------------------------------------------------------------------------------
-- Processo de Geração de Evento R-1070
procedure pkb_gera_evt_r1070
is
   --
   vn_fase                       number;
   vt_efdreinfr1070              efd_reinf_r1070%rowtype;
   vb_existe_log                 boolean;
   vt_log_generico_reinf         dbms_sql.number_table;
   vv_mensagem                   log_generico_reinf.mensagem%type;
   vn_loggenericoreinf_id        log_generico_reinf.id%type;
   vd_dt_ini_ger_ult_evt         geracao_efd_reinf.dt_ini%type;
   --
   cursor c_proc is
   select *
     from proc_adm_efd_reinf
    where empresa_id  = gt_row_geracao_efd_reinf.empresa_id
      and dm_situacao = 1 -- Validado
      and dt_ini   <= to_date(gt_row_geracao_efd_reinf.dt_ini,gv_formato_data)
      and ((dt_fin >= to_date(gt_row_geracao_efd_reinf.dt_fin,gv_formato_data)) or (dt_fin is null));
   --

   -- Procedure para geração do novo evento
   procedure pkb_gera_evt is
   begin
      -- Criação do evento
      pk_csf_api_reinf.pkb_integr_efd_reinf_r1070 ( est_log_generico_reinf  => vt_log_generico_reinf
                                                  , est_row_efd_reinf_r1070 => gt_row_efd_reinf_r1070
                                                  , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                  );
      --
      -- Criação do id do evento para o REINF
      pkb_gera_id_evt_reinf ( ev_obj_referencia => 'EFD_REINF_R1070'
                            , en_referencia_id  => gt_row_efd_reinf_r1070.id
                            );
      --
      -- Atualização dos situacao do evento
      if nvl(vt_log_generico_reinf.count,0) > 0 then
         --
         update efd_reinf_r1070
            set dm_st_proc = 2 -- Erro de validação
          where id = gt_row_efd_reinf_r1070.id;
         --
      else
         --
         update efd_reinf_r1070
            set dm_st_proc = 1 -- Validado
          where id = gt_row_efd_reinf_r1070.id;
         --
      end if;
      --
   end pkb_gera_evt;
   --
begin
   --
   vn_fase := 1;
   --
   vn_loggenericoreinf_id := null;
   --
   vn_fase := 2;
   --
   -- Recuperar Todos os Processos Administrativos que estão Validados
   -- A partir da Empresa da Geração
   -- o Registro R-1070 Não é necessario percorrer as empresas filiais
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   for rec in c_proc loop
      exit when c_proc%notfound or (c_proc%notfound) is null;
      --
      vn_fase := 3;
      --
      vt_efdreinfr1070       := null;
      vb_existe_log          := false;
      gt_row_efd_reinf_r1070 := null;
      vn_loggenericoreinf_id := null;
      vv_mensagem            := null;
      vd_dt_ini_ger_ult_evt  := null;
      --
      vn_fase := 4;
      -- Verifica se existe log na tabela "LOG_PROC_ADM_EFD_REINF" com "DM_ENVIO = 0"
      vb_existe_log := pk_csf_reinf.fkg_existe_logprocadmefdreinf (en_procadmefdreinf_id => rec.id);
      --
      vn_fase := 5;
      --
      if vb_existe_log = true then
         -- Recupera os dados do último evento R-1070 gerado
         pkb_rec_ultimo_evento_r1070 ( en_procadmefdreinf_id  => rec.id
                                     , en_dm_tp_amb           => gt_row_geracao_efd_reinf.dm_tp_amb
                                     , est_efdreinf_ult_r1070 => vt_efdreinfr1070 );
         --
         vn_fase := 6;
         -- Não existe o evento R-1070 gerado
         if nvl(vt_efdreinfr1070.id, 0) = 0 then
            --
            vn_fase := 7;
            -- Verifica o parâmetro "Possui Legado de declarações do EFD-REINF" do processo Administrativo/Judicial
            if nvl(rec.dm_reinf_legado, -1) = 0 then -- Não existe legado
               --
               vn_fase := 8;
               --
               gt_row_efd_reinf_r1070.id                  := null;                                   -- Null
               gt_row_efd_reinf_r1070.geracaoefdreinf_id  := gt_row_geracao_efd_reinf.id;            -- Id da geração EFD Reinf
               gt_row_efd_reinf_r1070.procadmefdreinf_id  := rec.id;                                 -- Id do processo administrativo/judiciário
               gt_row_efd_reinf_r1070.dm_tipo             := 1;                                      -- 1-Inclusão
               gt_row_efd_reinf_r1070.dm_st_proc          := 0;                                      -- 0-Em Aberto
               gt_row_efd_reinf_r1070.dt_ini              := trunc(gt_row_geracao_efd_reinf.dt_ini); -- Data inicial da geração EFD Reinf
               gt_row_efd_reinf_r1070.dt_fin              := null;                                   -- Null
               gt_row_efd_reinf_r1070.ar_efdreinfr1070_id := null;                                   -- Null
               --
               vn_fase := 9;
               --
               pkb_gera_evt;
               --
            end if;
            --
            vn_fase := 10;
            --
         -- Existe o evento R-1070 gerado
         else
            --
            if vt_efdreinfr1070.dm_tipo in (1,3,4) then -- 1-Inclusão; 3-Alteração; 4-Alteração de validade
               --
               vn_fase := 11;
               -- Existe o evento de Inclusão, Alteração ou Alteração de validade para ser processado
               if vt_efdreinfr1070.dm_st_proc in (0,1,3) then -- 0-Aberto; 1-Validado; 3-Aguardando Envio
                  --
                  vv_mensagem := 'O último evento R-1070 está com o tipo "'||upper(pk_csf.fkg_dominio('EFD_REINF_R1070.DM_TIPO', vt_efdreinfr1070.dm_tipo))||
                                 '" e com a situação "'||upper(pk_csf.fkg_dominio('EFD_REINF_R1070.DM_ST_PROC', vt_efdreinfr1070.dm_st_proc))||
                                 '". Neste caso, não poderá ser gerado um novo evento R-1070. Favor verificar.';
                  --
                  pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                          , ev_mensagem             => gv_resumo || vv_mensagem
                                                          , ev_resumo               => vv_mensagem
                                                          , en_tipo_log             => INFORMACAO
                                                          , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                          , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                          , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                          );
                  --
               else
                  -- 
                  vn_fase := 12;
                  --
                  gt_row_efd_reinf_r1070 := null;
                  --
                  vn_fase := 13;
                  --
                  gt_row_efd_reinf_r1070.id                  := null;                            -- Null
                  gt_row_efd_reinf_r1070.geracaoefdreinf_id  := gt_row_geracao_efd_reinf.id;     -- Id da geração EFD Reinf
                  gt_row_efd_reinf_r1070.procadmefdreinf_id  := rec.id;                          -- Id do processo administrativo/judiciário
                  gt_row_efd_reinf_r1070.dm_tipo             := 3;                               -- 3-Alteração
                  gt_row_efd_reinf_r1070.dm_st_proc          := 0;                               -- 0-Em Aberto
                  gt_row_efd_reinf_r1070.dt_ini              := trunc(vt_efdreinfr1070.dt_ini);  -- Data inicial do último evento R-1070 processado
                  gt_row_efd_reinf_r1070.dt_fin              := trunc(vt_efdreinfr1070.dt_fin);  -- Data final do último evento R-1070 processado
                  gt_row_efd_reinf_r1070.ar_efdreinfr1070_id := vt_efdreinfr1070.id;             -- Id do último evento gerado
                  --
                  vn_fase := 14;
                  --
                  pkb_gera_evt;
                  --
               end if;
               --
            elsif vt_efdreinfr1070.dm_tipo = 2 then -- 2-Exclusão
               --
               vn_fase := 15;
               -- Existe o evento de Exclusão para ser processado
               if vt_efdreinfr1070.dm_st_proc in (0,1,3) then -- 0-Aberto; 1-Validado; 3-Aguardando Envio
                  --
                  vv_mensagem := 'O último evento R-1070 está com o tipo "'||upper(pk_csf.fkg_dominio('EFD_REINF_R1070.DM_TIPO', vt_efdreinfr1070.dm_tipo))||
                                 '" e com a situação "'||upper(pk_csf.fkg_dominio('EFD_REINF_R1070.DM_ST_PROC', vt_efdreinfr1070.dm_st_proc))||
                                 '". Neste caso, não poderá ser gerado um novo evento R-1070. Favor verificar.';
                  --
                  pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                          , ev_mensagem             => gv_resumo || vv_mensagem
                                                          , ev_resumo               => vv_mensagem
                                                          , en_tipo_log             => INFORMACAO
                                                          , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                          , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                          , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                          );
                  --
                  vn_fase := 16;
                  --
               else
                  --
                  vn_fase := 17;
                  --
                  gt_row_efd_reinf_r1070 := null;
                  --
                  vn_fase := 18;
                  --
                  gt_row_efd_reinf_r1070.id                  := null;                            -- Null
                  gt_row_efd_reinf_r1070.geracaoefdreinf_id  := gt_row_geracao_efd_reinf.id;     -- Id da geração EFD Reinf
                  gt_row_efd_reinf_r1070.procadmefdreinf_id  := rec.id;                          -- Id do processo administrativo/judiciário
                  gt_row_efd_reinf_r1070.dm_tipo             := 1;                               -- 1-Inclusão
                  gt_row_efd_reinf_r1070.dm_st_proc          := 0;                               -- 0-Em Aberto
                  gt_row_efd_reinf_r1070.dt_ini              := trunc(vt_efdreinfr1070.dt_ini);  -- Data inicial do último evento R-1070 processado
                  gt_row_efd_reinf_r1070.dt_fin              := trunc(vt_efdreinfr1070.dt_fin);  -- Data final do último evento R-1070 processado
                  gt_row_efd_reinf_r1070.ar_efdreinfr1070_id := vt_efdreinfr1070.id;             -- Id do último evento de Exclusão
                  --
                  vn_fase := 19;
                  --
                  pkb_gera_evt;
                  --
               end if;
               --
            end if; --vt_efdreinfr1070.dm_tipo in (1,3)
            --
         end if; --nvl(vt_efdreinfr1070.id, 0) = 0
         --
      end if; --vb_existe_log = true
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_gera_evt_r1070 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_gera_evt_r1070;

-------------------------------------------------------------------------------------------------------
-- Processo que recupera os dados do último evento R-1000 gerado
procedure pkb_rec_ultimo_evento_r1000 ( en_empresa_id          in geracao_efd_reinf.empresa_id%type
                                      , en_dm_tp_amb           in geracao_efd_reinf.dm_tp_amb%type
                                      , est_efdreinf_ult_r1000 out nocopy efd_reinf_r1000%rowtype
                                      )
is
begin
   --
   est_efdreinf_ult_r1000 := null;
   --
   select *
     into est_efdreinf_ult_r1000
     from efd_reinf_r1000
    where id in ( select max(er.id)
                    from efd_reinf_r1000   er
                       , geracao_efd_reinf ge
                   where ge.empresa_id         = en_empresa_id
                     and ge.dm_tp_amb          = en_dm_tp_amb  -- 1-Produção; 2-Produção Restrita
                     and er.geracaoefdreinf_id = ge.id
                     and er.dm_st_proc         in (0,1,3,4) ); -- 0-Aberto; 1-Validado; 3-Aguardando Envio; 4-Processado
   --
exception
   when no_data_found then
      est_efdreinf_ult_r1000 := null;
   when others then
      raise_application_error(-20101, 'Erro na pk_gera_dados_reinf.pkb_rec_ultimo_evento_r1000: '||sqlerrm);
end pkb_rec_ultimo_evento_r1000;

---------------------------------------------------------------------------------------------------
-- Procedimento que cria um novo evento de Reenvio para os eventos com Erro no Envio ou Erro na montagem do XML
procedure pkb_reenviar_evt_r1000 ( en_efdreinfr1000_id in efd_reinf_r1000.id%type
                                 )
is
   --
   vn_fase                      number;
   vn_loggenericoreinf_id       log_generico_reinf.id%type;
   vn_efdreinfr1000_last_id     efd_reinf_r1000.id%type;
   --
   vt_efd_reinf_r1000           efd_reinf_r1000%rowtype;
   vt_log_generico_reinf        dbms_sql.number_table;
   --
begin
   --
   vn_fase := 1;
   --
   vt_efd_reinf_r1000     := null;
   vn_loggenericoreinf_id := null;
   --
   if nvl(en_efdreinfr1000_id,0) > 0 then
      --
      vn_fase := 2;
      --
      begin
         --
         select *
           into vt_efd_reinf_r1000
           from efd_reinf_r1000
          where id = en_efdreinfr1000_id;
         --
      exception
       when others then
         vt_efd_reinf_r1000 := null;
      end;
      --
      vn_fase := 3;
      -- Recupera os dados da Abertura do EFD-REINF
      pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => vt_efd_reinf_r1000.geracaoefdreinf_id );
      --
      vn_fase := 4;
      --
      delete log_generico_reinf
       where obj_referencia = 'EFD_REINF_R1000'
         and referencia_id  = gt_row_geracao_efd_reinf.id;
      --
      vn_fase := 5;
      --
      if nvl(vt_efd_reinf_r1000.id, 0) > 0
         and vt_efd_reinf_r1000.dm_st_proc in (5,6) then -- 5-Erro no Envio; 6-Erro na montagem do XML
         --
         vn_fase := 6;
         --
         vn_efdreinfr1000_last_id := null;
         -- Verificar se este é o último evento do grupo do R-1000
         begin
            --
            select max(id)
              into vn_efdreinfr1000_last_id
              from efd_reinf_r1000
             where geracaoefdreinf_id = vt_efd_reinf_r1000.geracaoefdreinf_id
               and dm_tipo            = vt_efd_reinf_r1000.dm_tipo
               and dt_ini             = vt_efd_reinf_r1000.dt_ini;
            --
         exception
          when others then
             vn_efdreinfr1000_last_id := null;
         end;
         --
         vn_fase := 7;
         --
         if nvl(vn_efdreinfr1000_last_id,0) = nvl(vt_efd_reinf_r1000.id,0) then
            --
            vn_fase := 8;
            --
            gt_row_efd_reinf_r1000 := vt_efd_reinf_r1000;
            --
            gt_row_efd_reinf_r1000.dm_st_proc      := 0;  -- 0-Aberto
            gt_row_efd_reinf_r1000.loteefdreinf_id := null;
            --
            vn_fase := 9;
            --
            pk_csf_api_reinf.pkb_integr_efd_reinf_r1000 ( est_log_generico_reinf   => vt_log_generico_reinf
                                                        , est_row_efd_reinf_r1000  => gt_row_efd_reinf_r1000
                                                        , en_empresa_id            => gt_row_geracao_efd_reinf.empresa_id
                                                        );
            --
            vn_fase := 10;
            --
            if nvl(vt_log_generico_reinf.count,0) > 0 then
               --
               update efd_reinf_r1000
                  set dm_st_proc = 2
                where id = vt_efd_reinf_r1000.id;
               --
            else
               --
               update efd_reinf_r1000
                  set dm_st_proc = 1
                where id = vt_efd_reinf_r1000.id;
               --
            end if;
            --
         else
            --
            pk_csf_api_reinf.gv_mensagem_log := 'Está sendo reenviado um evento R-1000 ( efdreinfr1000_id = '|| vt_efd_reinf_r1000.id ||') antigo, já existe um novo evento criado para o grupo, Favor Verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                    , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                    , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                    , en_tipo_log             => INFORMACAO
                                                    , en_referencia_id        => vt_efd_reinf_r1000.id
                                                    , ev_obj_referencia       => 'EFD_REINF_R1000'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
         end if;
         --
      else
         --
         pk_csf_api_reinf.gv_mensagem_log := 'Situação "'|| pk_csf.fkg_dominio ( 'EFD_REINF_R1000.DM_ST_PROC', vt_efd_reinf_r1000.dm_st_proc ) ||'" do evento R-1000 (efdreinfr1000_id = '||vt_efd_reinf_r1000.id||') não é permitido a geração do evento de reenvio';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                 , en_tipo_log             => INFORMACAO
                                                 , en_referencia_id        => vt_efd_reinf_r1000.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R1000'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
         --
      end if;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_reenviar_evt_r1000 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => vt_efd_reinf_r1000.id
                                                 , ev_obj_referencia       => 'EFD_REINF_R1000'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_reenviar_evt_r1000;

---------------------------------------------------------------------------------------------------
-- Processo de Geração de Evento R-1000
procedure pkb_gera_evt_r1000
is
   --
   vn_fase                       number;
   vt_efdreinfr1000              efd_reinf_r1000%rowtype;
   vb_existe_log                 boolean;
   vn_dm_reinf_legado            param_efd_reinf_empresa.dm_reinf_legado%type;
   vt_log_generico_reinf         dbms_sql.number_table;
   vv_mensagem                   log_generico_reinf.mensagem%type;
   vn_loggenericoreinf_id        log_generico_reinf.id%type;
   --

   -- Procedure para geração do novo evento
   procedure pkb_gera_evt is
   begin
      -- Criação do evento
      pk_csf_api_reinf.pkb_integr_efd_reinf_r1000 ( est_log_generico_reinf  => vt_log_generico_reinf
                                                  , est_row_efd_reinf_r1000 => gt_row_efd_reinf_r1000
                                                  , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                  );
      --
      -- Criação do id do evento para o REINF
      pkb_gera_id_evt_reinf ( ev_obj_referencia => 'EFD_REINF_R1000'
                            , en_referencia_id  => gt_row_efd_reinf_r1000.id
                            );
      --
      -- Atualização dos situacao do evento
      if nvl(vt_log_generico_reinf.count,0) > 0 then
         --
         update efd_reinf_r1000
            set dm_st_proc = 2 -- Erro de validação
          where id         = gt_row_efd_reinf_r1000.id;
         --
      else
         --
         update efd_reinf_r1000
            set dm_st_proc = 1 -- Validado
          where id         = gt_row_efd_reinf_r1000.id
            and dm_st_proc <> 2;
         --
      end if;
      --
   end pkb_gera_evt;
   --
begin
   --
   vn_fase := 1;
   --
   vt_efdreinfr1000       := null;
   vb_existe_log          := false;
   gt_row_efd_reinf_r1000 := null;
   vv_mensagem            := null;
   vn_loggenericoreinf_id := null;
   --
   vn_fase := 2;
   -- Verifica se existe log na tabela "LOG_PARAM_EFD_REINF_EMPRESA" com "DM_ENVIO = 0"
   vb_existe_log := pk_csf_reinf.fkg_existe_logparamefdreinfemp (en_empresa_id => gt_row_geracao_efd_reinf.empresa_id);
   --
   vn_fase := 3;
   --
   if vb_existe_log = true then
      -- Recupera os dados do último evento R-1000 gerado
      pkb_rec_ultimo_evento_r1000 ( en_empresa_id          => gt_row_geracao_efd_reinf.empresa_id
                                  , en_dm_tp_amb           => gt_row_geracao_efd_reinf.dm_tp_amb
                                  , est_efdreinf_ult_r1000 => vt_efdreinfr1000 );
      --
      vn_fase := 4;
      -- Não existe o evento R-1000 gerado
      if nvl(vt_efdreinfr1000.id, 0) = 0 then
         --
         vn_fase := 5;
         -- Verifica o parâmetro "Indicativo de legado de declaração EFD-REINF de outros sistemas" da empresa
         begin
            --
            select dm_reinf_legado
              into vn_dm_reinf_legado
              from param_efd_reinf_empresa
             where empresa_id = gt_row_geracao_efd_reinf.empresa_id;
            --
         exception
            when others then
               vn_dm_reinf_legado := null;
         end;
         --
         vn_fase := 6;
         --
         if nvl(vn_dm_reinf_legado,-1) = 0 then -- Não existe legado
            --
            vn_fase := 7;
            --
            gt_row_efd_reinf_r1000.id                  := null;                                    -- Null
            gt_row_efd_reinf_r1000.geracaoefdreinf_id  := gt_row_geracao_efd_reinf.id;             -- Id da geração EFD Reinf
            gt_row_efd_reinf_r1000.dm_tipo             := 1;                                       -- 1-Inclusão
            gt_row_efd_reinf_r1000.dm_st_proc          := 0;                                       -- 0-Em Aberto
            gt_row_efd_reinf_r1000.dt_ini              := trunc(gt_row_geracao_efd_reinf.dt_ini);  -- Data inicial da geração EFD Reinf
            gt_row_efd_reinf_r1000.dt_fin              := null;                                    -- Null
            gt_row_efd_reinf_r1000.ar_efdreinfr1000_id := null;                                    -- Null
            --
            vn_fase := 8;
            --
            pkb_gera_evt;
            --
         end if;
         --
         vn_fase := 9;
         --
      -- Existe o evento R-1000 gerado
      else
         --
         if vt_efdreinfr1000.dm_tipo in (1,3,4)  then -- 1-Inclusão; 3-Alteração; 4-Alteração de validade
            --
            vn_fase := 10;
            -- Existe o evento de Inclusão, Alteração ou Alteração de validade para ser processado
            if vt_efdreinfr1000.dm_st_proc in (0,1,3) then -- 0-Aberto; 1-Validado; 3-Aguardando Envio
               --
               vv_mensagem := 'O último evento R-1000 está com o tipo "'||upper(pk_csf.fkg_dominio('EFD_REINF_R1000.DM_TIPO', vt_efdreinfr1000.dm_tipo))||
                              '" e com a situação "'||upper(pk_csf.fkg_dominio('EFD_REINF_R1000.DM_ST_PROC', vt_efdreinfr1000.dm_st_proc))||
                              '". Neste caso, não poderá ser gerado um novo evento R-1000. Favor verificar.';
               --
               pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                       , ev_mensagem             => gv_resumo || vv_mensagem
                                                       , ev_resumo               => vv_mensagem
                                                       , en_tipo_log             => INFORMACAO
                                                       , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                       , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                       , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                       );
               --
               vn_fase := 11;
               --
            else
               --
               vn_fase := 12;
               --
               gt_row_efd_reinf_r1000 := null;
               --
               gt_row_efd_reinf_r1000.id                  := null;                            -- Null
               gt_row_efd_reinf_r1000.geracaoefdreinf_id  := gt_row_geracao_efd_reinf.id;     -- Id da geração EFD Reinf
               gt_row_efd_reinf_r1000.dm_tipo             := 3;                               -- 3-Alteração
               gt_row_efd_reinf_r1000.dm_st_proc          := 0;                               -- 0-Em Aberto
               gt_row_efd_reinf_r1000.dt_ini              := trunc(vt_efdreinfr1000.dt_ini);  -- Data inicial do último evento R-1000 processado
               gt_row_efd_reinf_r1000.dt_fin              := trunc(vt_efdreinfr1000.dt_fin);  -- Data final do último evento R-1000 processado
               gt_row_efd_reinf_r1000.ar_efdreinfr1000_id := vt_efdreinfr1000.id;             -- Id do último evento gerado
               --
               vn_fase := 13;
               --
               pkb_gera_evt;
               --
            end if;
            --   
         elsif vt_efdreinfr1000.dm_tipo = 2 then -- 2-Exclusão
            --
            vn_fase := 14;
            -- Existe o evento de Exclusão para ser processado
            if vt_efdreinfr1000.dm_st_proc in (0,1,3) then -- 0-Aberto; 1-Validado; 3-Aguardando Envio
               --
               vv_mensagem := 'O último evento R-1000 está com o tipo "'||upper(pk_csf.fkg_dominio('EFD_REINF_R1000.DM_TIPO', vt_efdreinfr1000.dm_tipo))||
                              '" e com a situação "'||upper(pk_csf.fkg_dominio('EFD_REINF_R1000.DM_ST_PROC', vt_efdreinfr1000.dm_st_proc))||
                              '". Neste caso, não poderá ser gerado um novo evento R-1000. Favor verificar.';
               --
               pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                       , ev_mensagem             => gv_resumo || vv_mensagem
                                                       , ev_resumo               => vv_mensagem
                                                       , en_tipo_log             => INFORMACAO
                                                       , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                       , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                       , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                       );
               --
               vn_fase := 15;
               --
            else
               --
               vn_fase := 16;
               --
               gt_row_efd_reinf_r1000 := null;
               --
               vn_fase := 17;
               --
               gt_row_efd_reinf_r1000.id                  := null;                            -- Null
               gt_row_efd_reinf_r1000.geracaoefdreinf_id  := gt_row_geracao_efd_reinf.id;     -- Id da geração EFD Reinf
               gt_row_efd_reinf_r1000.dm_tipo             := 1;                               -- 1-Inclusão
               gt_row_efd_reinf_r1000.dm_st_proc          := 0;                               -- 0-Em Aberto
               gt_row_efd_reinf_r1000.dt_ini              := trunc(vt_efdreinfr1000.dt_ini);  -- Data inicial do último evento R-1000 processado
               gt_row_efd_reinf_r1000.dt_fin              := trunc(vt_efdreinfr1000.dt_fin);  -- Data final do último evento R-1000 processado
               gt_row_efd_reinf_r1000.ar_efdreinfr1000_id := vt_efdreinfr1000.id;             -- Id do último evento gerado
               --
               vn_fase := 18;
               --
               pkb_gera_evt;
               --
            end if;
            --
         end if; --vt_efdreinfr1070.dm_tipo in (1,3)
         --
      end if; --nvl(vt_efdreinfr1000.id, 0) = 0
      --
   end if; --vb_existe_log = true
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_dados_reinf.pkb_gera_evt_r1000 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_resumo || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => ERRO_DE_SISTEMA
                                                 , en_referencia_id        => gt_row_geracao_efd_reinf.id
                                                 , ev_obj_referencia       => 'GERACAO_EFD_REINF'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_gera_evt_r1000;

----------------------------------------------------------------------------------------------------
-- Procedimento que ira orquestar a geração dos eventos por período do EFD-REINF
procedure pkb_geracao_eventos
is
   --
   vn_fase                   number;
   --
begin
   --
   vn_fase := 1;
   --
   pkb_exclui_evt_com_erro_envio ( en_geracaoefdreinf_id => gt_row_geracao_efd_reinf.id
                                 , ev_botao              => 'GERACAO' );
   --
   vn_fase := 2;
   --
   if nvl(gt_row_geracao_efd_reinf.dm_situacao, 0) = 2 then -- 2-Aberto
      --
      vn_fase := 3;
      --
      pkb_gera_evt_r1000;
      --
      vn_fase := 4;
      --
      pkb_gera_evt_r1070;
      --
      if nvl(gt_row_geracao_efd_reinf.dm_tipo, 0) = 1 then -- Periódicos
         --
         vn_fase := 5;
         --
         pkb_gera_evt_r2010;
         --
         vn_fase := 6;
         --
         pkb_gera_evt_r2020;
         --
         vn_fase := 7;
         --
         pkb_gera_evt_r2030;
         --
         vn_fase := 8;
         --
         pkb_gera_evt_r2040;
         --
         vn_fase := 9;
         --
         pkb_gera_evt_r2050;
         --
         vn_fase := 10;
         --
         pkb_gera_evt_r2060;
         --
         vn_fase := 11;
         --
         --pkb_gera_evt_r2070;
         --
      else
         --
         vn_fase := 12;
         --
         pkb_gera_evt_r3010;
         --
      end if;
      --
   end if;
   --
   vn_fase := 13;
   -- Gera a quantidade de registros por evento
   pkb_gerar_resumo_reinf ( en_geracaoefdreinf_id => gt_row_geracao_efd_reinf.id);
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_gera_dados_reinf.pkb_geracao_eventos fase('||vn_fase||'): '||sqlerrm);
end pkb_geracao_eventos;

-------------------------------------------------------------------------------------------------------
-- Processo que executa a Geração dos eventos de modo Online
procedure pkb_geracao_periodo_online
is
   --
   vn_fase                       number;
   --
   cursor c_empr is
   select e.id empresa_id
        , e.multorg_id
     from empresa e
        , param_efd_reinf_empresa per
    where per.empresa_id      = e.id
      and e.dm_situacao       = 1 -- Ativa
      and per.dm_tipo_geracao = 1 -- Online
    order by 1, 2;
   --
   cursor c_ger (en_empresa_id in number)is
   select id geracaoefdreinf_id
        , dt_ini
     from geracao_efd_reinf
    where dm_situacao = 2 -- Aberto
      and empresa_id  = en_empresa_id
    order by dt_ini;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 2;
      --
      for rec2 in c_ger(rec.empresa_id) loop
         exit when c_ger%notfound or (c_ger%notfound) is null;
         --
         vn_fase := 3;
         --
         pkb_limpa_arrays;
         -- Recupera os dados da Abertura do EFD-REINF
         pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => rec2.geracaoefdreinf_id );
         --
         vn_fase := 4;
         --
         if nvl(gt_row_geracao_efd_reinf.id,0) > 0 then
            --
            vn_fase := 5;
            --
            gv_resumo := 'Execução do processo de geração de eventos on-line ' || to_char(gt_row_geracao_efd_reinf.dt_ini,'mm/yyyy') ||' da empresa '||
                         pk_csf.fkg_cod_nome_empresa_id ( gt_row_geracao_efd_reinf.empresa_id ) ||
                         ' e ambiente de '|| pk_csf.fkg_dominio('GERACAO_EFD_REINF.DM_TP_AMB', nvl(gt_row_geracao_efd_reinf.dm_tp_amb,0));
            --
            gn_referencia_id := gt_row_geracao_efd_reinf.id;
            --
            begin
               --
               delete  log_generico_reinf lg
                where lg.referencia_id  = gn_referencia_id
                  and lg.obj_referencia = gv_obj_referencia;
               --
            exception
               when others then
                  raise_application_error(-20101, 'Erro ao excluir log/inconsistência - pk_gera_dados_reinf.pkb_geracao_periodo_online: '||sqlerrm);
            end;
            --
            vn_fase := 6;
            --
            if nvl(gt_row_geracao_efd_reinf.dm_situacao, 0) = 3 then -- 3-Erro no fechamento
               --
               gt_row_geracao_efd_reinf.dm_situacao := 2; -- 2-Aberto
               --
               vn_fase := 7;
               -- Atualiza a situação da geração EFD Reinf
               begin
                  --
                  update geracao_efd_reinf
                     set dm_situacao = gt_row_geracao_efd_reinf.dm_situacao
                   where id          = gt_row_geracao_efd_reinf.id;
                  --
               exception
                  when others then
                     raise_application_error(-20101, 'Erro ao atualizar a situação da geração EFD Reinf - pk_gera_dados_reinf.pkb_geracao_periodo_offline: '||sqlerrm);
               end;
               --
            end if;
            --
            vn_fase := 8;
            --
            pkb_geracao_eventos;
            --
         end if;
         --
      end loop;
      --
   end loop;
   --
   commit;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_gera_dados_reinf.pkb_geracao_periodo_online fase('||vn_fase||'): '||sqlerrm);
end pkb_geracao_periodo_online;

-------------------------------------------------------------------------------------------------------
-- Processo que executa a Geração dos eventos de modo Offline
procedure pkb_geracao_periodo_offline ( en_geracaoefdreinf_id in geracao_efd_reinf.id%type
                                      )
is
   --
   vn_fase                       number;
   vn_loggenerico_id             log_generico.id%type;
   vv_dominio_descr               varchar2(500);
   --
begin
   --
   vn_fase := 1;
   --
   pkb_limpa_arrays;
   --
   -- Recupera os dados da Abertura do EFD-REINF
   pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => en_geracaoefdreinf_id );
   --
   vn_fase := 2;
   --
   if nvl(gt_row_geracao_efd_reinf.id,0) > 0 then
      --
      vn_fase := 3;
      --
      gv_resumo := 'Executar o processo de geração de eventos off-line ' || to_char(gt_row_geracao_efd_reinf.dt_ini,'mm/yyyy') ||' da empresa '||
                   pk_csf.fkg_cod_nome_empresa_id ( gt_row_geracao_efd_reinf.empresa_id ) ||
                   ' e ambiente de '|| pk_csf.fkg_dominio('GERACAO_EFD_REINF.DM_TP_AMB', nvl(gt_row_geracao_efd_reinf.dm_tp_amb,0));
      --
      gn_referencia_id := gt_row_geracao_efd_reinf.id;
      --
      begin
         --
         delete  log_generico_reinf lg
          where lg.referencia_id  = gn_referencia_id
            and lg.obj_referencia = gv_obj_referencia;
         --
      exception
         when others then
            raise_application_error(-20101, 'Erro ao excluir log/inconsistência - pk_gera_dados_reinf.pkb_geracao_periodo_offline: '||sqlerrm);
      end;
      --
      vn_fase := 4;
      --
      if nvl(gt_row_geracao_efd_reinf.dm_situacao, 0) = 3 then -- 3-Erro no fechamento
         --
         gt_row_geracao_efd_reinf.dm_situacao := 2; -- 2-Aberto
         --
         vn_fase := 5;
         -- Atualiza a situação da geração EFD Reinf
         begin
            --
            update geracao_efd_reinf
               set dm_situacao = gt_row_geracao_efd_reinf.dm_situacao
             where id          = gt_row_geracao_efd_reinf.id;
            --
         exception
            when others then
               raise_application_error(-20101, 'Erro ao atualizar a situação da geração EFD Reinf - pk_gera_dados_reinf.pkb_geracao_periodo_offline: '||sqlerrm);
         end;
         --
      end if;
      --
      vn_fase := 6;
      --
      if nvl(gt_row_geracao_efd_reinf.dm_situacao, 0) = 2 then -- 2-Aberto
         --
         vn_fase := 7;
         --
         pkb_geracao_eventos;
         --
      else
         --
         vn_fase := 8;
         --
         vv_dominio_descr := pk_csf.fkg_dominio('geracao_efd_reinf.dm_situacao', nvl(gt_row_geracao_efd_reinf.dm_situacao,0));
         --
         gv_mensagem := 'Situação da geração da EFD-REINF "'||vv_dominio_descr||'", não permite que os eventos sejam "GERADOS".';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => informacao
                                                 , en_referencia_id        => gn_referencia_id
                                                 , ev_obj_referencia       => gv_obj_referencia
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 , en_dm_impressa          => 1
                                                 );
         --
      end if;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_gera_dados_reinf.pkb_geracao_periodo_offline fase('||vn_fase||'): '||sqlerrm);
end pkb_geracao_periodo_offline;

-------------------------------------------------------------------------------------------------------
-- Processo que valida os parametros do EFD-REINF
procedure pkb_vld_param_efd_reinf ( est_log_generico_reinf in out nocopy dbms_sql.number_table )
is
   --
   vn_fase                       number;
   vn_loggenerico_id             log_generico.id%type;
   --
   cursor c_param is
   select *
     from param_efd_reinf_empresa
    where empresa_id = gt_row_geracao_efd_reinf.empresa_id;
   --
   cursor c_pefd is
   select *
    from pefd_reinf_empr_contato
   where paramefdreinfempresa_id = gt_row_param_efd_reinf_empresa.id;
   --
   cursor c_efr is
   select *
     from pefd_reinf_empr_efr
    where paramefdreinfempresa_id = gt_row_param_efd_reinf_empresa.id;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(gt_row_geracao_efd_reinf.empresa_id,0) > 0 then
      --
      vn_fase := 2;
      --
      open c_param;
      fetch c_param into gt_row_param_efd_reinf_empresa;
      close c_param;
      --
      vn_fase := 3;
      --
      if nvl(gt_row_param_efd_reinf_empresa.id,0) > 0 then
         --
         pk_csf_api_reinf.gv_obj_referencia := 'GERACAO_EFD_REINF';
         pk_csf_api_reinf.gn_referencia_id  := gt_row_geracao_efd_reinf.id;
         --
         vn_fase := 4;
         --
         pk_csf_api_reinf.pkb_integr_paramreinfempresa ( est_log_generico_reinf       => est_log_generico_reinf
                                                       , est_row_paramefdreinfempresa => gt_row_param_efd_reinf_empresa
                                                       , en_empresa_id                => gt_row_param_efd_reinf_empresa.empresa_id
                                                       );
         --
         vn_fase := 5;
         --
         for rec in c_pefd loop
            exit when c_pefd%notfound or (c_pefd%notfound) is null;
            --
            vn_fase := 6;
            --
            pk_csf_api_reinf.pkb_integr_pefdreinfemprcontat ( est_log_generico_reinf       => est_log_generico_reinf
                                                            , est_row_pefdreinfemprcontato => rec
                                                            , en_empresa_id                => gt_row_param_efd_reinf_empresa.empresa_id
                                                            );
            --
         end loop;
         --
         vn_fase := 7;
         --
         for rec in c_efr loop
            exit when c_efr%notfound or (c_efr%notfound) is null;
            --
            vn_fase := 8;
            --
            pk_csf_api_reinf.pkb_integr_pefdreinfemprefr ( est_log_generico_reinf       => est_log_generico_reinf
                                                         , est_row_pefdreinfemprefr     => rec
                                                         , en_empresa_id                => gt_row_param_efd_reinf_empresa.empresa_id
                                                         );
            --
         end loop;
         --
      else
         --
         vn_fase := 9;
         --
         gv_mensagem := 'Empresa que efetuou a abertura não possui parâmetros para geração do EFD-REINF (Tela: SPED -> REINF -> Parâmetros EFD-REINF por Empresa), Favor Verificar.';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => informacao
                                                 , en_referencia_id        => gn_referencia_id
                                                 , ev_obj_referencia       => gv_obj_referencia
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 , en_dm_impressa          => 1
                                                 );
         pk_csf_api_reinf.pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenerico_id
                                                    , est_log_generico_reinf  => est_log_generico_reinf
                                                    );
         --
      end if;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_gera_dados_reinf.pkb_vld_param_efd_reinf fase('||vn_fase||'): '||sqlerrm);
end pkb_vld_param_efd_reinf;

-------------------------------------------------------------------------------------------------------
-- Processo de abertura de periodo de geração do EFD-REINF
procedure pkb_abrir_periodo_reinf ( en_geracaoefdreinf_id in geracao_efd_reinf.id%type
                                  )
is
   --
   vn_fase                        number;
   vn_loggenerico_id              log_generico_ird.id%type;
   vv_dominio_descr               varchar2(500);
   --
   vt_log_generico_reinf          dbms_sql.number_table;
   --
begin
   --
   vn_fase := 1;
   -- Recupera os dados da Abertura do EFD-REINF
   pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => en_geracaoefdreinf_id );
   --
   vn_fase := 2;
   --
   if nvl(gt_row_geracao_efd_reinf.id,0) > 0 then
      --
      vn_fase := 3;
      --
      gv_cabec_log := 'Abertura do período ' || to_char(gt_row_geracao_efd_reinf.dt_ini,'mm/yyyy') ||' da empresa '||
                      pk_csf.fkg_cod_nome_empresa_id ( gt_row_geracao_efd_reinf.empresa_id ) ||
                      ' e ambiente de '|| pk_csf.fkg_dominio('GERACAO_EFD_REINF.DM_TP_AMB', nvl(gt_row_geracao_efd_reinf.dm_tp_amb,0));
      --
      gn_referencia_id := gt_row_geracao_efd_reinf.id;
      --
      begin
         --
         delete  log_generico_reinf lg
          where lg.referencia_id  = gn_referencia_id
            and lg.obj_referencia = gv_obj_referencia;
         --
      exception
         when others then
            raise_application_error(-20101, 'Erro ao excluir log/inconsistência - pk_gera_dados_reinf.pkb_abrir_periodo_reinf: '||sqlerrm);
      end;
      --
      vn_fase := 4;
      --
      pkb_exclui_evt_com_erro_envio ( en_geracaoefdreinf_id => gt_row_geracao_efd_reinf.id
                                    , ev_botao              => 'REABERTURA' );
      --
      vn_fase := 5;
      --
      if gt_row_geracao_efd_reinf.dm_situacao in (0,1) then -- 0-Criado; 1-Erro na abertura
         --
         vn_fase := 6;
         --
         pkb_vld_param_efd_reinf (vt_log_generico_reinf);
         --
         vn_fase := 7;
         --
         if nvl(vt_log_generico_reinf.count,0) > 0 then
            --
            gt_row_geracao_efd_reinf.dm_situacao := 1; -- 1-Erro na Abertura
            --
         else
            --
            gt_row_geracao_efd_reinf.dm_situacao := 2; -- 2-Aberto
            --
         end if;
         --
         vn_fase := 8;
         --
         update geracao_efd_reinf
            set dm_situacao = gt_row_geracao_efd_reinf.dm_situacao
          where id = gt_row_geracao_efd_reinf.id;
         --
         vn_fase := 9;
         --
         if pk_csf_reinf.fkg_verif_tp_geracao(gt_row_geracao_efd_reinf.empresa_id) = 0 then -- Offline
            --
            pkb_geracao_periodo_offline(gt_row_geracao_efd_reinf.id);
            --
         end if;
         --
         vn_fase := 10;
         --
      elsif gt_row_geracao_efd_reinf.dm_situacao = 4 then -- 4-Fechado
         --
         vn_fase := 11;
         --
         if gt_row_geracao_efd_reinf.dm_tipo = 1 then  -- 1-Periódico
            --
            vn_fase := 12;
            --
            pkb_gera_evt_r2098(vt_log_generico_reinf);
            --
         else  -- 2-Não periódico
            --
            vn_fase := 13;
            --
            update geracao_efd_reinf
               set dm_situacao = 2  -- 2-Aberto
             where id = gt_row_geracao_efd_reinf.id;
            --
         end if;
         --
         vn_fase := 14;
         --
      else
         --
         vn_fase := 15;
         --
         vv_dominio_descr := pk_csf.fkg_dominio('geracao_efd_reinf.dm_situacao', gt_row_geracao_efd_reinf.dm_situacao);
         --
         gv_mensagem := 'Situação da geração da EFD-REINF "'||vv_dominio_descr||'", não permite que o período seja "ABERTO".';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_cabec_log || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => informacao
                                                 , en_referencia_id        => gn_referencia_id
                                                 , ev_obj_referencia       => gv_obj_referencia
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 , en_dm_impressa          => 1
                                                 );
         --
      end if;
      --
      vn_fase := 16;
      -- Gera a quantidade de registros por evento
      pkb_gerar_resumo_reinf ( en_geracaoefdreinf_id => gt_row_geracao_efd_reinf.id);
      --
   end if;
   --
   commit;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_gera_dados_reinf.pkb_abrir_periodo_reinf fase('||vn_fase||'): '||sqlerrm);
end pkb_abrir_periodo_reinf;

-------------------------------------------------------------------------------------------------------
-- Processo de fechamento de periodo de geração do EFD-REINF
procedure pkb_fechar_periodo_reinf ( en_geracaoefdreinf_id in geracao_efd_reinf.id%type
                                   )
is
   --
   vn_fase                        number;
   vn_loggenerico_id              log_generico_ird.id%type;
   vv_dominio_descr               varchar2(500);
   --
   vt_log_generico_reinf          dbms_sql.number_table;
   --
begin
   --
   vn_fase := 1;
   -- Recupera os dados da Abertura do EFD-REINF
   pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => en_geracaoefdreinf_id );
   --
   vn_fase := 2;
   --
   if nvl(gt_row_geracao_efd_reinf.id,0) > 0 then
      --
      vn_fase := 3;
      --
      gv_cabec_log := 'Fechamento do período ' || to_char(gt_row_geracao_efd_reinf.dt_ini,'mm/yyyy') ||' da empresa '||
                      pk_csf.fkg_cod_nome_empresa_id ( gt_row_geracao_efd_reinf.empresa_id ) ||
                      ' e ambiente de '|| pk_csf.fkg_dominio('geracao_efd_reinf.dm_tp_amb', nvl(gt_row_geracao_efd_reinf.dm_tp_amb,0));
      --
      gn_referencia_id := gt_row_geracao_efd_reinf.id;
      --
      begin
         --
         delete  log_generico_reinf lg
          where lg.referencia_id  = gn_referencia_id
            and lg.obj_referencia = gv_obj_referencia;
         --
      exception
         when others then
            raise_application_error(-20101, 'Erro ao excluir log/inconsistência - pk_gera_dados_reinf.pkb_fechar_periodo_reinf: '||sqlerrm);
      end;
      --
      vn_fase := 4;
      --
      pkb_exclui_evt_com_erro_envio ( en_geracaoefdreinf_id => gt_row_geracao_efd_reinf.id
                                    , ev_botao              => 'FECHAMENTO' );
      --
      vn_fase := 5;
      --
      if nvl(gt_row_geracao_efd_reinf.dm_situacao,0) in (2,3) then -- 2-Aberto; 3-Erro no fechamento
         --
         vn_fase := 6;
         --
         -- Valida se existe eventos que ainda não foram Processados pelo EFD-REINF
         pkb_vld_evt_espera(est_log_generico_reinf => vt_log_generico_reinf);
         --
         vn_fase := 7;
         -- Valida se existe alguma informação que não foi gerada pelo EFD-REINF
         pkb_vld_inf_nao_enviada(est_log_generico_reinf => vt_log_generico_reinf);
         --
         vn_fase := 8;
         --
         if nvl(vt_log_generico_reinf.count, 0) = 0 then
            --
            if gt_row_geracao_efd_reinf.dm_tipo = 1 then  -- 1-Periódico
               --
               vn_fase := 9;
               -- Gera o evento R-2099
               pkb_gera_evt_r2099(est_log_generico_reinf => vt_log_generico_reinf);
               --
            end if;
            --
         end if;
         --
         vn_fase := 10;
         --
         if nvl(vt_log_generico_reinf.count,0) > 0 then
            --
            gt_row_geracao_efd_reinf.dm_situacao := 3; -- 3-Erro no fechamento
            --
            vn_fase := 11;
            --
            update geracao_efd_reinf
               set dm_situacao = gt_row_geracao_efd_reinf.dm_situacao
             where id          = gt_row_geracao_efd_reinf.id;
            --
         end if;
         --
      else
         --
         vn_fase := 12;
         --
         vv_dominio_descr := pk_csf.fkg_dominio('geracao_efd_reinf.dm_situacao', nvl(gt_row_geracao_efd_reinf.dm_situacao,0));
         --
         gv_mensagem := 'Situação da geração da EFD-REINF "'||vv_dominio_descr||'", não permite que o período seja "Fechado".';
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => gv_cabec_log || gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => informacao
                                                 , en_referencia_id        => gn_referencia_id
                                                 , ev_obj_referencia       => gv_obj_referencia
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 , en_dm_impressa          => 1
                                                 );
         --
      end if;
      --
      vn_fase := 13;
      -- Gera a quantidade de registros por evento
      pkb_gerar_resumo_reinf ( en_geracaoefdreinf_id => gt_row_geracao_efd_reinf.id);
      --
   end if;
   --
   commit;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_gera_dados_reinf.pkb_fechar_periodo_reinf fase('||vn_fase||'): '||sqlerrm);
end pkb_fechar_periodo_reinf;

---------------------------------------------------------------------------------------------------------------

-- Validação do CPRB das notas fiscais informadas nos Eventos R2010
procedure pkb_valida_cprb_nf_r2010 ( en_geracaoefdreinf_id   in geracao_efd_reinf.id%type
                                   , en_efdreinfr2010_id     in efd_reinf_r2010.id%type
                                   , est_log_generico_reinf  in out nocopy dbms_sql.number_table
                                   ) 
is
   vn_loggenericoreinf_id     number;
   vn_fase                    number;
   --
cursor c_nfs is
   select distinct 
          ern.efdreinfr2010_id
        , er.empresa_id  
        , nf.nro_nf
        , nf.serie 
        , to_number(nvl(ii.aliq_apli,0))                       aliq_apli_inss
        , to_number(decode(inf.dm_ind_cprb, 0, 11, 1, 3.5, 0)) aliq_cprb
     from efd_reinf_r2010        er
        , efd_reinf_r2010_nf    ern
        , nota_fiscal            nf
        , item_nota_fiscal      inf
        , imp_itemnf             ii
        , tipo_imposto           ti
    where 1=1
      and ern.efdreinfr2010_id    = er.id
      and nf.id                   = ern.notafiscal_id
      and inf.notafiscal_id       = ern.notafiscal_id
      and ii.itemnf_id            = inf.id
      and ti.id                   = ii.tipoimp_id
      --      
      and ti.cd                   = 13 -- INSS
      and ii.dm_tipo              = 1  -- Retido
      and nvl(ii.vl_imp_trib,  0) > 0
      and nvl(ii.vl_base_calc, 0) > 0
      and er.geracaoefdreinf_id   = en_geracaoefdreinf_id
      and er.id                   = nvl(en_efdreinfr2010_id, er.id);
      --
begin
   --
   vn_fase := 1;
   --
   for rec in c_nfs loop
      --
      vn_fase := 1.1;
      --
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_fase := 1.2;
      --
      if rec.aliq_apli_inss = 0 then
         --
         vn_fase := 1.21;
         --     
         gv_mensagem := 'Erro da Geração do Evento R-2010 - A Nota Fiscal Nro. '               || rec.nro_nf                   ||
                        ' série '                                                              || rec.serie                    ||
                        ' está com aliquota de INSS-Ret zerada '                               || chr(13)                      ||
                        'Favor corrigir a Aliquota na Nota Fiscal';
         --
         vn_fase := 1.22;
         --     
         delete log_generico_reinf r
         where r.obj_referencia = 'EFD_REINF_R2010'
           and r.empresa_id     = gt_row_geracao_efd_reinf.empresa_id
           and r.mensagem       = gv_mensagem;         
         --
         vn_fase := 1.23;
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => pk_csf_api_reinf.erro_de_validacao
                                                 , en_referencia_id        => rec.efdreinfr2010_id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2010'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );         
         --
         vn_fase := 1.24;
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );      
      
      elsif rec.aliq_apli_inss <> rec.aliq_cprb then
         --
         vn_fase := 1.25;
         --
         gv_mensagem := 'Erro da Geração do Evento R-2010 - A Nota Fiscal Nro. '               || rec.nro_nf                   ||
                        ' série '                                                              || rec.serie                    ||
                        ' está com aliquota de INSS-Ret diferente de seu Indicador de CPRB '   || chr(13)                      ||
                        'Aliquota informada na Nota Fiscal: '                                  || to_char(rec.aliq_apli_inss)  ||
                        ' / Indicador de CPRB: '                                               || case when rec.aliq_cprb = 0 then 'NÃO INFORMADO' else to_char(rec.aliq_cprb) end || chr(13) ||
                        'Favor corrigir o Indicador de CPRB da Nota Fiscal ou criar um parâmetro de-para na tela de Parâmetros de Itens x Classificação do Tipo de Serviço do REINF (R2010/R2020)';
         --
         vn_fase := 1.26;
         --
         delete log_generico_reinf r
         where r.obj_referencia = 'EFD_REINF_R2010'
           and r.empresa_id     = gt_row_geracao_efd_reinf.empresa_id
           and r.mensagem       = gv_mensagem;
         --
         vn_fase := 1.27;
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => pk_csf_api_reinf.erro_de_validacao
                                                 , en_referencia_id        => rec.efdreinfr2010_id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2010'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );         
         --
         vn_fase := 1.28;
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
      --
      end if;
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_gera_dados_reinf.pkb_valida_cprb_nf_r2010 fase('||vn_fase||'): '||sqlerrm);

end pkb_valida_cprb_nf_r2010;

---------------------------------------------------------------------------------------------------------------

-- Validação do CPRB das notas fiscais informadas nos Eventos R2020
procedure pkb_valida_cprb_nf_r2020 ( en_geracaoefdreinf_id   in geracao_efd_reinf.id%type
                                   , en_efdreinfr2020_id     in efd_reinf_r2020.id%type
                                   , est_log_generico_reinf  in out nocopy dbms_sql.number_table
                                   ) 
is
   vn_loggenericoreinf_id     number;
   vn_fase                    number;
   --
cursor c_nfs is
   select distinct 
          ern.efdreinfr2020_id
        , er.empresa_id  
        , nf.nro_nf
        , nf.serie 
        , to_number(nvl(ii.aliq_apli,0))                       aliq_apli_inss
        , to_number(decode(inf.dm_ind_cprb, 0, 11, 1, 3.5, 0)) aliq_cprb
     from efd_reinf_r2020        er
        , efd_reinf_r2020_nf    ern
        , nota_fiscal            nf
        , item_nota_fiscal      inf
        , imp_itemnf             ii
        , tipo_imposto           ti
    where 1=1
      and ern.efdreinfr2020_id    = er.id
      and nf.id                   = ern.notafiscal_id
      and inf.notafiscal_id       = ern.notafiscal_id
      and ii.itemnf_id            = inf.id
      and ti.id                   = ii.tipoimp_id
      --      
      and ti.cd                   = 13 -- INSS
      and ii.dm_tipo              = 1  -- Retido
      and nvl(ii.vl_imp_trib,  0) > 0
      and nvl(ii.vl_base_calc, 0) > 0
      and er.geracaoefdreinf_id   = en_geracaoefdreinf_id
      and er.id                   = nvl(en_efdreinfr2020_id, er.id);
      --
begin
   --
   vn_fase := 1;
   --
   for rec in c_nfs loop
      --
      vn_fase := 1.1;
      --
      exit when c_nfs%notfound or (c_nfs%notfound) is null;
      --
      vn_fase := 1.2;
      --
      if rec.aliq_apli_inss = 0 then
         --
         vn_fase := 1.21;
         --     
         gv_mensagem := 'Erro da Geração do Evento R-2020 - A Nota Fiscal Nro. '               || rec.nro_nf                   ||
                        ' série '                                                              || rec.serie                    ||
                        ' está com aliquota de INSS-Ret zerada '                               || chr(13)                      ||
                        'Favor corrigir a Aliquota na Nota Fiscal';
         --
         vn_fase := 1.22;
         --     
         delete log_generico_reinf r
         where r.obj_referencia = 'EFD_REINF_R2020'
           and r.empresa_id     = gt_row_geracao_efd_reinf.empresa_id
           and r.mensagem       = gv_mensagem;         
         --
         vn_fase := 1.23;
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => pk_csf_api_reinf.erro_de_validacao
                                                 , en_referencia_id        => rec.efdreinfr2020_id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2020'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );         
         --
         vn_fase := 1.24;
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );    
         --                           
      elsif rec.aliq_apli_inss <> rec.aliq_cprb then
         --
         vn_fase := 1.25;
         --
         gv_mensagem := 'Erro da Geração do Evento R-2020 - A Nota Fiscal Nro. '               || rec.nro_nf                   ||
                        ' série '                                                              || rec.serie                    ||
                        ' está com aliquota de INSS-Ret diferente de seu Indicador de CPRB '   || chr(13)                      ||
                        'Aliquota informada na Nota Fiscal: '                                  || to_char(rec.aliq_apli_inss)  ||
                        ' / Indicador de CPRB: '                                               || case when rec.aliq_cprb = 0 then 'NÃO INFORMADO' else to_char(rec.aliq_cprb) end || chr(13) ||
                        'Favor corrigir o Indicador de CPRB da Nota Fiscal ou criar um parâmetro de-para na tela de Parâmetros de Itens x Classificação do Tipo de Serviço do REINF (R2010/R2020)';
         --
         vn_fase := 1.26;
         --
         delete log_generico_reinf r
         where r.obj_referencia = 'EFD_REINF_R2020'
           and r.empresa_id     = gt_row_geracao_efd_reinf.empresa_id
           and r.mensagem       = gv_mensagem;
         --
         vn_fase := 1.27;
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => pk_csf_api_reinf.erro_de_validacao
                                                 , en_referencia_id        => rec.efdreinfr2020_id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2020'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );         
         --
         vn_fase := 1.28;
         --
         pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  => vn_loggenericoreinf_id
                                   , est_log_generico_reinf  => est_log_generico_reinf
                                   );
      --
      end if;
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_gera_dados_reinf.pkb_valida_cprb_nf_r2020 fase('||vn_fase||'): '||sqlerrm);

end pkb_valida_cprb_nf_r2020;

---------------------------------------------------------------------------------------------------------------

-- Valida arredondamento imposto INSS para REINF - R2010
procedure pkb_valida_rnd_inss_r2010 ( en_geracaoefdreinf_id   in geracao_efd_reinf.id%type
                                    , en_efdreinfr2010_id     in efd_reinf_r2010.id%type
                                    , est_log_generico_reinf  in out nocopy dbms_sql.number_table
                                    ) 
is
   -- 
   -- Variáveis --
   vn_loggenericoreinf_id     number;
   vn_fase                    number;
   --
   -- Cursores --
   cursor c_imp is
   select nf.id notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nft.vl_ret_prev
        , cast(sum(nvl(ii.vl_imp_trib,0)) as decimal(15,2)) vl_imp_trib
        , cast(
             case 
                trunc(sum(nvl(ii.vl_base_calc,0) * (nvl(ii.aliq_apli,0)/100)),3) - trunc(sum(nvl(ii.vl_base_calc,0) * (nvl(ii.aliq_apli,0)/100)),2)
             when .005 then    
                trunc(sum(nvl(ii.vl_base_calc,0) * (nvl(ii.aliq_apli,0)/100)),2)
             else  
                round(sum(nvl(ii.vl_base_calc,0) * (nvl(ii.aliq_apli,0)/100)),2) 
             end
           as decimal(15,2)) vl_imp_calculado
         --
      from imp_itemnf             ii 
         , tipo_imposto           ti
         , item_nota_fiscal      inf
         , nota_fiscal            nf
         , nota_fiscal_total     nft
         , efd_reinf_r2010_nf    ern     
         , efd_reinf_r2010        er        
   where ti.id                 = ii.tipoimp_id
     and inf.id                = ii.itemnf_id
     and nf.id                 = inf.notafiscal_id
     and nft.notafiscal_id  (+)= nf.id
     and ern.notafiscal_id     = nf.id  
     and er.id                 = ern.efdreinfr2010_id
     -- end joins --
     and ti.cd        = 13 -- INSS
     and ii.dm_tipo   = 1  -- RETENÇÂO
     and er.id        = en_efdreinfr2010_id
   group by nf.id, nf.nro_nf, nf.serie, nft.vl_ret_prev;
   --
begin
   --
   vn_fase := 1;
   --
   for r_imp in c_imp loop
      --
      exit when c_imp%notfound or (c_imp%notfound) is null;
      --
      vn_fase := 1.1;
      --
      if r_imp.vl_imp_trib <> r_imp.vl_imp_calculado then
        --
        vn_fase := 1.11;
        --
         gv_mensagem := 'Erro da Geração do Evento R2010 - Problemas com a Nota Fiscal Nro.: '                  || r_imp.nro_nf                                                ||
                        ' Série: '                                                                              || r_imp.serie                                                 ||
                        '. A Nota Fiscal está com valor do imposto INSS diferente do valor esperado pelo REINF' || chr(13)                                                     ||
                        '. Valor Total do INSS Integrado: '                                                     || trim(to_char(r_imp.vl_imp_trib,'999G999G999G990D00'))       ||
                        ' | Valor Esperado pelo REINF: '                                                        || trim(to_char(r_imp.vl_imp_calculado,'999G999G999G990D00'))  ||
                        ' Favor conferir o valor integrado na tabela de impostos - Possível causa: Arredondamento no ERP do Cliente';
         --
         vn_fase := 1.12;
         --
         delete log_generico_reinf r
         where r.obj_referencia = 'EFD_REINF_R2010'
           and r.empresa_id     = gt_row_geracao_efd_reinf.empresa_id
           and r.mensagem       = gv_mensagem;
         --
         vn_fase := 1.13;
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => pk_csf_api_reinf.informacao
                                                 , en_referencia_id        => en_efdreinfr2010_id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2010'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );         
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_gera_dados_reinf.pkb_valida_rnd_inss_r2010 fase('||vn_fase||'): '||sqlerrm);
end pkb_valida_rnd_inss_r2010;

-------------------------------------------------------------------------------------------------------

-- Valida arredondamento imposto INSS para REINF - R2020
procedure pkb_valida_rnd_inss_r2020 ( en_geracaoefdreinf_id   in geracao_efd_reinf.id%type
                                    , en_efdreinfr2020_id     in efd_reinf_r2020.id%type
                                    , est_log_generico_reinf  in out nocopy dbms_sql.number_table
                                    ) 
is
   -- 
   -- Variáveis --
   vn_loggenericoreinf_id     number;
   vn_fase                    number;
   --
   -- Cursores --
   cursor c_imp is
   select nf.id notafiscal_id
        , nf.nro_nf
        , nf.serie
        , nft.vl_ret_prev
        , cast(sum(nvl(ii.vl_imp_trib,0)) as decimal(15,2)) vl_imp_trib
        , cast(sum(
             case
                trunc(nvl(ii.vl_base_calc,0) * (nvl(ii.aliq_apli,0)/100),3) - trunc(nvl(ii.vl_base_calc,0) * (nvl(ii.aliq_apli,0)/100),2)
             when .005 then
                trunc(nvl(ii.vl_base_calc,0) * (nvl(ii.aliq_apli,0)/100),2)
             else
                round(nvl(ii.vl_base_calc,0) * (nvl(ii.aliq_apli,0)/100),2)
             end
          ) as decimal(15,2)) vl_imp_calculado
         --        
      from imp_itemnf             ii 
         , tipo_imposto           ti
         , item_nota_fiscal      inf
         , nota_fiscal            nf
         , nota_fiscal_total     nft
         , efd_reinf_r2020_nf    ern     
         , efd_reinf_r2020        er        
   where ti.id                 = ii.tipoimp_id
     and inf.id                = ii.itemnf_id
     and nf.id                 = inf.notafiscal_id
     and nft.notafiscal_id  (+)= nf.id
     and ern.notafiscal_id     = nf.id  
     and er.id                 = ern.efdreinfr2020_id
     -- end joins --
     and ti.cd        = 13 -- INSS
     and ii.dm_tipo   = 1  -- RETENÇÂO
     and er.id        = en_efdreinfr2020_id
   group by nf.id, nf.nro_nf, nf.serie, nft.vl_ret_prev;
   --
begin
   --
   vn_fase := 1;
   --
   for r_imp in c_imp loop
      --
      exit when c_imp%notfound or (c_imp%notfound) is null;
      --
      vn_fase := 1.1;
      --
      if r_imp.vl_imp_trib <> r_imp.vl_imp_calculado then
        --
        vn_fase := 1.11;
        --
         gv_mensagem := 'Erro da Geração do Evento R2020 - Problemas com a Nota Fiscal Nro.: '                  || r_imp.nro_nf                                                ||
                        ' Série: '                                                                              || r_imp.serie                                                 ||
                        '. A Nota Fiscal está com valor do imposto INSS diferente do valor esperado pelo REINF' || chr(13)                                                     ||
                        '. Valor Total do INSS Integrado: '                                                     || trim(to_char(r_imp.vl_imp_trib,'999G999G999G990D00'))       ||
                        ' | Valor Esperado pelo REINF: '                                                        || trim(to_char(r_imp.vl_imp_calculado,'999G999G999G990D00'))  ||
                        ' Favor conferir o valor integrado na tabela de impostos - Possível causa: Arredondamento no ERP do Cliente';
         --
         vn_fase := 1.12;
         --
         delete log_generico_reinf r
         where r.obj_referencia = 'EFD_REINF_R2020'
           and r.empresa_id     = gt_row_geracao_efd_reinf.empresa_id
           and r.mensagem       = gv_mensagem;
         --
         vn_fase := 1.13;
         --
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenericoreinf_id
                                                 , ev_mensagem             => gv_mensagem
                                                 , ev_resumo               => gv_mensagem
                                                 , en_tipo_log             => pk_csf_api_reinf.informacao
                                                 , en_referencia_id        => en_efdreinfr2020_id
                                                 , ev_obj_referencia       => 'EFD_REINF_R2020'
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );         
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_gera_dados_reinf.pkb_valida_rnd_inss_r2020 fase('||vn_fase||'): '||sqlerrm);
end pkb_valida_rnd_inss_r2020;

-------------------------------------------------------------------------------------------------------

-- Procedimento de retificação da nota fiscal de entrada do Evento R-2060
procedure pkb_retif_evt_r2060 ( en_efdreinfr2060_id in efd_reinf_r2060.id%type)
is
   --
   vn_fase                           number;
   vn_loggenerico_id                 log_generico_reinf.id%type;
   vt_log_generico_reinf             dbms_sql.number_table;
   --
   vv_mensagem_log                   log_generico_reinf.mensagem%type;
   vv_resumo_log                     log_generico_reinf.resumo%type;
   vt_efd_reinf_r2060                efd_reinf_r2060%rowtype;
   vt_efd_reinf_r2060_new            efd_reinf_r2060%rowtype;
   vn_efdreinfr2060_last_id          efd_reinf_r2060.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   vt_efd_reinf_r2060       := null;
   vt_efd_reinf_r2060_new   := null;
   vn_efdreinfr2060_last_id := null;
   --
   vn_fase := 2;
   --
   begin
      --
      select *
        into vt_efd_reinf_r2060
        from efd_reinf_r2060
       where id = en_efdreinfr2060_id;
      --
   exception
    when others then
      vt_efd_reinf_r2060 := null;
   end;
   --
   vn_fase := 3;
   --
   -- Recupera os dados da Abertura do EFD-REINF
   pkb_dados_geracao_reinf ( en_geracaoefdreinf_id => vt_efd_reinf_r2060.geracaoefdreinf_id );
   --
   if nvl(gt_row_geracao_efd_reinf.dm_situacao, 0) = 2 then  -- 2-Aberto
      --
      if nvl(vt_efd_reinf_r2060.id,0) > 0 then
         --
         vn_fase := 4;
         --
         vv_resumo_log := 'Procedimento de Retificação do Evento R-2060 (Contribuição Previdenciária sobre a Receita Bruta - CPRB) do Estabelecimento: '||
                          pk_csf.fkg_cod_nome_empresa_id ( gt_row_geracao_efd_reinf.empresa_id )|| ', no período de '||
                          trim(to_char(gt_row_geracao_efd_reinf.dt_ini, 'month')) || ' de ' ||
                          to_char(gt_row_geracao_efd_reinf.dt_ini,'yyyy');
         --
         vn_fase := 5;
         --
         delete log_generico_reinf
          where obj_referencia = 'EFD_REINF_R2060'
            and referencia_id  = vt_efd_reinf_r2060.id;
         --
         vn_fase := 6;
         --
         if vt_efd_reinf_r2060.dm_st_proc in (4,8) then -- 4-Processado; 8-Processado R-5001
            --
            vn_fase := 7;
            --
            -- Recupera o ID do último evento do grupo R-2010
            begin
               --
               select id
                 into vn_efdreinfr2060_last_id
                 from efd_reinf_r2060
                where id in ( select max(id)
                                from efd_reinf_r2060
                               where geracaoefdreinf_id = vt_efd_reinf_r2060.geracaoefdreinf_id);
               --
            end;
            --
            vn_fase := 8;
            --
            if nvl(vn_efdreinfr2060_last_id, 0) = nvl(vt_efd_reinf_r2060.id, 0) then
               --
               vt_efd_reinf_r2060_new.id                   := null;
               vt_efd_reinf_r2060_new.geracaoefdreinf_id   := vt_efd_reinf_r2060.geracaoefdreinf_id;
               vt_efd_reinf_r2060_new.dm_st_proc           := 0; -- 0-Aberto
               vt_efd_reinf_r2060_new.dm_tipo_reg          := 2; -- 2-Retificado
               vt_efd_reinf_r2060_new.apurcprbempr_id      := vt_efd_reinf_r2060.apurcprbempr_id;
               vt_efd_reinf_r2060_new.ar_efdreinfr2060_id  := en_efdreinfr2060_id;
               --
               vn_fase := 9;
               -- Cria o novo evento R-2060
               pk_csf_api_reinf.pkb_integr_efd_reinf_r2060 ( est_log_generico_reinf  => vt_log_generico_reinf
                                                           , est_row_efdreinfr2060   => vt_efd_reinf_r2060_new
                                                           );
               --
               vn_fase := 10;
               --
               if nvl(vt_log_generico_reinf.count,0) = 0 then
                  --
                  update efd_reinf_r2060
                     set dm_st_proc = 1 -- Validado
                   where id = vt_efd_reinf_r2060_new.id;
                  --
               else
                  --
                  update efd_reinf_r2060
                     set dm_st_proc = 2 -- Erro de validação
                   where id = vt_efd_reinf_r2060_new.id;
                  --
               end if;
               --
            if nvl(gt_row_efd_reinf_r2060.id, 0) = 0 then
               gt_row_efd_reinf_r2060.id := vt_efd_reinf_r2060_new.id;
            end if;   
            --
               vn_fase := 15;
               --
               -- Gerar o ID para o novo evento criado
               pkb_gera_id_evt_reinf ( ev_obj_referencia => 'EFD_REINF_R2060'
                                     , en_referencia_id  => vt_efd_reinf_r2060_new.id--gt_row_efd_reinf_r2010.id
                                     );
               --
            else
               --
               vn_fase := 16;
               --
               vv_mensagem_log := 'Evento não pode ser retificado pois não é o último evento gerado para o grupo de informação, favor verificar.';
               --
               pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                       , ev_mensagem             => vv_resumo_log ||' '|| vv_mensagem_log
                                                       , ev_resumo               => vv_mensagem_log
                                                       , en_tipo_log             => pk_csf_api_reinf.informacao
                                                       , en_referencia_id        => vt_efd_reinf_r2060.id
                                                       , ev_obj_referencia       => 'EFD_REINF_R2060'
                                                       , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                       );
               --
            end if;
            --
         else  -- 0-Aberto; 1-Validado; 2-Erro de Validação; 3-Aguardando Envio; 5-Erro no Envio; 6-Erro na montagem do XML; 7-Excluído
            --
            vn_fase := 17;
            --
            vv_mensagem_log := 'O evento R-2060 não pode ser retificado pois está com a situação "'||pk_csf.fkg_dominio('EFD_REINF_R2060.DM_ST_PROC', vt_efd_reinf_r2060.dm_st_proc)||
                            '", favor verificar.';
            --
            pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                    , ev_mensagem             => vv_resumo_log ||' '|| vv_mensagem_log
                                                    , ev_resumo               => vv_mensagem_log
                                                    , en_tipo_log             => pk_csf_api_reinf.informacao
                                                    , en_referencia_id        => vt_efd_reinf_r2060.id
                                                    , ev_obj_referencia       => 'EFD_REINF_R2060'
                                                    , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                    );
            --
         end if;
            --
      end if;
      --
   else
      --
      vn_fase := 18;
      --
      vv_mensagem_log := 'Evento não pode ser retificado pois a situação do evento é diferente de "Aberto", favor verificar.';
      --
      pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                              , ev_mensagem             => vv_resumo_log ||' '|| vv_mensagem_log
                                              , ev_resumo               => vv_mensagem_log
                                              , en_tipo_log             => pk_csf_api_reinf.informacao
                                              , en_referencia_id        => vt_efd_reinf_r2060.id
                                              , ev_obj_referencia       => 'EFD_REINF_R2060'
                                              , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                             );
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      rollback;
      --
      --
      pk_csf_api_reinf.gv_mensagem_log := 'Erro na pk_gera_dados_reinf.pkb_retif_evt_r2060 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_reinf.pkb_log_generico_reinf ( sn_loggenericoreinf_id  => vn_loggenerico_id
                                                 , ev_mensagem             => vv_resumo_log || pk_csf_api_reinf.gv_mensagem_log
                                                 , ev_resumo               => pk_csf_api_reinf.gv_mensagem_log
                                                 , en_tipo_log             => pk_csf_api_reinf.ERRO_DE_SISTEMA
                                                 , en_referencia_id        => pk_csf_api_reinf.gn_referencia_id
                                                 , ev_obj_referencia       => pk_csf_api_reinf.gv_obj_referencia
                                                 , en_empresa_id           => gt_row_geracao_efd_reinf.empresa_id
                                                 );
      exception
         when others then
            null;
      end;
      --
      commit;
      --
end pkb_retif_evt_r2060;

-------------------------------------------------------------------------------------------------------
end pk_gera_dados_reinf;
/
