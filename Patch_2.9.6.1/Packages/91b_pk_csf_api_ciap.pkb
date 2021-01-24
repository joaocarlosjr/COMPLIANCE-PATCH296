create or replace package body csf_own.pk_csf_api_ciap is

-------------------------------------------------------------------------------------------------------
-- Corpo do pacote de integração de CIAP
-------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--| Procedimento seta o "ID de Referencia" utilizado na Validação da Informação
--------------------------------------------------------------------------------
procedure pkb_seta_referencia_id ( en_id in number
                                 ) is
begin
   --
   gn_referencia_id := en_id;
   --
end pkb_seta_referencia_id;
-----------------------------------------
--| Procedimento finaliza o Log Genérico
-----------------------------------------
procedure pkb_finaliza_log_generico_ciap is
begin
   --
   gn_processo_id := null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_ciap.pkb_finaliza_log_generico_ciap: '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                               , ev_mensagem        => gv_cabec_log
                               , ev_resumo          => gv_mensagem_log
                               , en_tipo_log        => ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_finaliza_log_generico_ciap;
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
------------------------------------------------------
--| Procedimento armazena o valor do "loggenerico_id"
------------------------------------------------------
procedure pkb_gt_log_generico_ciap ( en_loggenericociap_id  in             Log_generico_ciap.id%TYPE
                                   , est_log_generico_ciap  in out nocopy  dbms_sql.number_table
                                   ) is
   --
   i pls_integer;
   --
begin
   --
   if nvl(en_loggenericociap_id,0) > 0 then
      --
      i := nvl(est_log_generico_ciap.count,0) + 1;
      --
      est_log_generico_ciap(i) := en_loggenericociap_id;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_ciap.pkb_gt_log_generico_ciap: '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico_ciap.id%TYPE;
      begin
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                               , ev_mensagem        => gv_cabec_log
                               , ev_resumo          => gv_mensagem_log
                               , en_tipo_log        => ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_gt_log_generico_ciap;
-----------------------------------------------------------------
--| Procedimento de registro de log de erros na validação do ECF
-----------------------------------------------------------------
procedure pkb_log_generico_ciap ( sn_loggenericociap_id     out nocopy Log_Generico_ciap.id%TYPE
                                , ev_mensagem            in            Log_Generico_ciap.mensagem%TYPE
                                , ev_resumo              in            Log_Generico_ciap.resumo%TYPE
                                , en_tipo_log            in            csf_tipo_log.cd_compat%type      default 1
                                , en_referencia_id       in            Log_Generico_ciap.referencia_id%TYPE  default null
                                , ev_obj_referencia      in            Log_Generico_ciap.obj_referencia%TYPE default null
                                , en_empresa_id          in            Empresa.Id%type                  default null
                                , en_dm_impressa         in            Log_Generico_ciap.dm_impressa%type    default 0
                                ) is
   --
   vn_fase          number := 0;
   vn_csftipolog_id csf_tipo_log.id%type := null;
   pragma           autonomous_transaction;
   --
begin
   --
   vn_fase := 1;
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
      select loggenericociap_seq.nextval
        into sn_loggenericociap_id
        from dual;
      --
      vn_fase := 4;
      --
      insert into Log_Generico_ciap ( id
                                    , processo_id
                                    , dt_hr_log
                                    , mensagem
                                    , referencia_id
                                    , obj_referencia
                                    , resumo
                                    , dm_impressa
                                    , dm_env_email
                                    , csftipolog_id
                                    , empresa_id
                                    )
                             values
                                    ( sn_loggenericociap_id     -- Valor de cada log de validação
                                    , gn_processo_id        -- Valor ID do processo de integração
                                    , sysdate               -- Sempre atribui a data atual do sistema
                                    , ev_mensagem           -- Mensagem do log
                                    , en_referencia_id      -- Id de referência que gerou o log
                                    , ev_obj_referencia     -- Objeto do Banco que gerou o log
                                    , ev_resumo
                                    , en_dm_impressa
                                    , 0
                                    , vn_csftipolog_id
                                    , nvl(en_empresa_id, gn_empresa_id)
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
      gv_mensagem_log := 'Erro na pkb_log_generico_ciap fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                               , ev_mensagem        => gv_cabec_log
                               , ev_resumo          => gv_mensagem_log
                               , en_tipo_log        => ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_log_generico_ciap;
-----------------------------------------------
--| Procedimento excluir os movimentos de CIAP
-----------------------------------------------
procedure pkb_excluir_ciap ( est_log_generico_ciap      in out nocopy  dbms_sql.number_table
                           , en_icmsatpermciap_id  in             icms_atperm_ciap.id%type
                           ) is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ciap.id%type;
   pragma             autonomous_transaction;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_icmsatpermciap_id,0) > 0 then
      --
      vn_fase := 2;
      --
      delete from mov_atperm_doc_fiscal_item it
       where it.movatpermdocfiscal_id in ( select df.id
                                             from mov_atperm m
                                                , mov_atperm_doc_fiscal df
                                            where m.icmsatpermciap_id  = en_icmsatpermciap_id
                                              and df.movatperm_id      = m.id );
      --
      vn_fase := 3;
      --
      delete from mov_atperm_doc_fiscal df
       where df.movatperm_id in ( select m.id from mov_atperm m
                                   where m.icmsatpermciap_id  = en_icmsatpermciap_id );
      --
      vn_fase := 4;
      --
      delete from outro_cred_ciap o
       where o.movatperm_id in ( select m.id from mov_atperm m
                                  where m.icmsatpermciap_id  = en_icmsatpermciap_id );
      --
      vn_fase := 5;
      --
      delete from mov_atperm m
       where m.icmsatpermciap_id  = en_icmsatpermciap_id;
      --
      vn_fase := 5.1;
      --
      delete from r_loteintws_ciap where icmsatpermciap_id = en_icmsatpermciap_id;
      --
   end if;
   --
   vn_fase := 6;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_excluir_ciap fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ciap.id%TYPE;
      begin
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                               , ev_mensagem        => gv_cabec_log
                               , ev_resumo          => gv_mensagem_log
                               , en_tipo_log        => ERRO_DE_SISTEMA
                               , en_referencia_id   => gn_referencia_id
                               , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ciap ( en_loggenericociap_id  => vn_loggenerico_id
                                  , est_log_generico_ciap  => est_log_generico_ciap );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_excluir_ciap;
----------------------------------------------------------------------
--| Procedimento de Integração de Item do Documento Fiscal Complemento
----------------------------------------------------------------------
procedure pkb_int_movatpermdocfisit_comp ( est_log_generico_ciap             in out nocopy  dbms_sql.number_table
                                         , est_row_movatpermdocfiscitcomp    in out nocopy  mov_atperm_doc_fiscal_item%rowtype
                                         ) is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ciap.id%type;
   vd_dt_mov          mov_atperm.dt_mov%type;
   --
begin
   --
   vn_fase := 1;
   --   
   if nvl(est_row_movatpermdocfiscitcomp.movatpermdocfiscal_id,0) <= 0 then
      --
      vn_fase := 1.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Documento Fiscal" não informado/integrado para a geração do Item do Documento Fiscal.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                               , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 1.11;
   --  
   begin   
      select ma.dt_mov 
        into vd_dt_mov	  
        from mov_atperm_doc_fiscal md
           , mov_atperm ma     
       where md.id = est_row_movatpermdocfiscitcomp.movatpermdocfiscal_id
         and ma.id = md.movatperm_id;
   exception
      when others then
         vd_dt_mov := null;
   end;	
   --
   vn_fase := 2;
   --  
   if vd_dt_mov is not null and 
      ( vd_dt_mov >= to_date('01/01/2020','dd/mm/rrrr') and nvl(est_row_movatpermdocfiscitcomp.qtde,0) <= 0 ) then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Quantidade do item constante no documento fiscal de entrada não informada ou negaviva.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                            , ev_mensagem            => gv_cabec_log
                            , ev_resumo              => gv_mensagem_log
                            , en_tipo_log            => ERRO_DE_VALIDACAO
                            , en_referencia_id       => gn_referencia_id
                            , ev_obj_referencia      => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id  => vn_loggenerico_id
                               , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;	  
   --
   vn_fase := 3;   
   --   
   if vd_dt_mov is not null and 
      ( vd_dt_mov >= to_date('01/01/2020','dd/mm/rrrr') and nvl(est_row_movatpermdocfiscitcomp.unidade_id,0) <= 0 ) then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Unidade do item constante no documento fiscal de entrada não informada ou invalida.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                            , ev_mensagem            => gv_cabec_log
                            , ev_resumo              => gv_mensagem_log
                            , en_tipo_log            => ERRO_DE_VALIDACAO
                            , en_referencia_id       => gn_referencia_id
                            , ev_obj_referencia      => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id  => vn_loggenerico_id
                               , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;	  
   --
   vn_fase := 4;
   --
   if vd_dt_mov is not null and 
      ( vd_dt_mov >= to_date('01/01/2020','dd/mm/rrrr') and nvl(est_row_movatpermdocfiscitcomp.vl_icms_op_aplicado,0) <= 0 ) then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Valor do ICMS da Operação Própria na entrada do item" não pode ser zero ou negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                            , ev_mensagem            => gv_cabec_log
                            , ev_resumo              => gv_mensagem_log
                            , en_tipo_log            => ERRO_DE_VALIDACAO
                            , en_referencia_id       => gn_referencia_id
                            , ev_obj_referencia      => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id  => vn_loggenerico_id
                               , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;	  
   --
   vn_fase := 5;
   --
   if vd_dt_mov is not null and 
      ( vd_dt_mov >= to_date('01/01/2020','dd/mm/rrrr') and nvl(est_row_movatpermdocfiscitcomp.vl_icms_st_aplicado,0) <= 0 ) then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Valor do ICMS ST na entrada do item" não pode ser zero ou negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                            , ev_mensagem            => gv_cabec_log
                            , ev_resumo              => gv_mensagem_log
                            , en_tipo_log            => ERRO_DE_VALIDACAO
                            , en_referencia_id       => gn_referencia_id
                            , ev_obj_referencia      => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id  => vn_loggenerico_id
                               , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;	  
   --      
   vn_fase := 6;
   --
   if vd_dt_mov is not null and 
      ( vd_dt_mov >= to_date('01/01/2020','dd/mm/rrrr') and nvl(est_row_movatpermdocfiscitcomp.vl_icms_frt_aplicado,0) <= 0 ) then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Valor do ICMS sobre Frete do CTE na entrada do item" não pode ser zero ou negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                            , ev_mensagem            => gv_cabec_log
                            , ev_resumo              => gv_mensagem_log
                            , en_tipo_log            => ERRO_DE_VALIDACAO
                            , en_referencia_id       => gn_referencia_id
                            , ev_obj_referencia      => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id  => vn_loggenerico_id
                               , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;	  
   -- 
   vn_fase := 7;
   --
   if vd_dt_mov is not null and 
      ( vd_dt_mov >= to_date('01/01/2020','dd/mm/rrrr') and nvl(est_row_movatpermdocfiscitcomp.vl_icms_dif_aplicado,0) <= 0 ) then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Valor do ICMS Difal, na entrada do item" não pode ser zero ou negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                            , ev_mensagem            => gv_cabec_log
                            , ev_resumo              => gv_mensagem_log
                            , en_tipo_log            => ERRO_DE_VALIDACAO
                            , en_referencia_id       => gn_referencia_id
                            , ev_obj_referencia      => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id  => vn_loggenerico_id
                               , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;	  
   -- 
   vn_fase := 99;
   --
   if nvl(gn_tipo_integr,0) = 1 and
      nvl(est_row_movatpermdocfiscitcomp.id,0) > 0 and
      vd_dt_mov is not null and
      vd_dt_mov >= to_date('01/01/2020','dd/mm/rrrr') then
      --
      vn_fase := 99.4;
      --
      update mov_atperm_doc_fiscal_item set qtde                   = est_row_movatpermdocfiscitcomp.qtde
                                          , unidade_id             = est_row_movatpermdocfiscitcomp.unidade_id
                                          , vl_icms_op_aplicado    = est_row_movatpermdocfiscitcomp.vl_icms_op_aplicado
                                          , vl_icms_st_aplicado    = est_row_movatpermdocfiscitcomp.vl_icms_st_aplicado
                                          , vl_icms_frt_aplicado   = est_row_movatpermdocfiscitcomp.vl_icms_frt_aplicado
                                          , vl_icms_dif_aplicado   = est_row_movatpermdocfiscitcomp.vl_icms_dif_aplicado									 
       where id = est_row_movatpermdocfiscitcomp.id;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_int_movatpermdocfisit_comp fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ciap.id%TYPE;
      begin
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                               , ev_mensagem            => gv_cabec_log
                               , ev_resumo              => gv_mensagem_log
                               , en_tipo_log            => ERRO_DE_SISTEMA
                               , en_referencia_id       => gn_referencia_id
                               , ev_obj_referencia      => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ciap ( en_loggenericociap_id  => vn_loggenerico_id
                                  , est_log_generico_ciap  => est_log_generico_ciap );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_int_movatpermdocfisit_comp;
-----------------------------------------------------------
--| Procedimento de Integração de Item do Documento Fiscal
-----------------------------------------------------------
procedure pkb_integr_movatpermdocfisitem ( est_log_generico_ciap            in out nocopy  dbms_sql.number_table
                                         , est_row_movatpermdocfisitem      in out nocopy  mov_atperm_doc_fiscal_item%rowtype
                                         , ev_cod_item                      in             item.cod_item%type
                                         , en_empresa_id                    in             empresa.id%type
                                         ) is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ciap.id%type;

   --
begin
   --
   vn_fase := 1;
   -- 
   if nvl(est_row_movatpermdocfisitem.movatpermdocfiscal_id,0) <= 0 then
      --
      vn_fase := 1.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Documento Fiscal" não informado/integrado para a geração do Item do Documento Fiscal.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                               , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 2;
   --
   est_row_movatpermdocfisitem.item_id := pk_csf.fkg_Item_id_conf_empr ( en_empresa_id  => en_empresa_id
                                                                       , ev_cod_item    => trim(ev_cod_item)
                                                                       );
   --
   vn_fase := 2.1;
   --
   if nvl(est_row_movatpermdocfisitem.item_id,0) <= 0 then
      --
      vn_fase := 2.2;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Código correspondente do bem no documento fiscal" não informado ou inválido ('||trim(ev_cod_item)||').';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_row_movatpermdocfisitem.num_item,0) <= 0 then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Número sequencial do item no documento fiscal" não pode ser zero ou negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   -- 
   vn_fase := 99;
   --
   if nvl(est_row_movatpermdocfisitem.movatpermdocfiscal_id,0) > 0
      and nvl(est_row_movatpermdocfisitem.item_id,0) > 0
      and nvl(est_row_movatpermdocfisitem.num_item,0) > 0 then
      --
      vn_fase := 99.1;
      --
      if nvl(gn_tipo_integr,0) = 1 then
         --	
         est_row_movatpermdocfisitem.id := pk_csf_ciap.fkg_movatperdocfiscalitem_id ( en_movatpermdocfiscal_id => est_row_movatpermdocfisitem.movatpermdocfiscal_id
                                                                                    , en_num_item              => est_row_movatpermdocfisitem.num_item
                                                                                    , en_item_id               => est_row_movatpermdocfisitem.item_id );
         --
	     if nvl(est_row_movatpermdocfisitem.id,0) <= 0 then
            --
            vn_fase := 99.2;
            --
            select movatpermdocfiscalitem_seq.nextval
              into est_row_movatpermdocfisitem.id
              from dual;
            --
            vn_fase := 99.3;
            --
            insert into mov_atperm_doc_fiscal_item ( id
                                                   , movatpermdocfiscal_id
                                                   , num_item
                                                   , item_id											
                                                   )
                                            values ( est_row_movatpermdocfisitem.id
                                                   , est_row_movatpermdocfisitem.movatpermdocfiscal_id
                                                   , est_row_movatpermdocfisitem.num_item
                                                   , est_row_movatpermdocfisitem.item_id
                                                   );
            --
         else
            --
            vn_fase := 99.4;
            --
            update mov_atperm_doc_fiscal_item set movatpermdocfiscal_id  = est_row_movatpermdocfisitem.movatpermdocfiscal_id
                                                , num_item               = est_row_movatpermdocfisitem.num_item
                                                , item_id                = est_row_movatpermdocfisitem.item_id									 
             where id = est_row_movatpermdocfisitem.id;
            --
         end if;
         --	  
	  end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_integr_movatpermdocfisitem fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ciap.id%TYPE;
      begin
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                             , est_log_generico_ciap  => est_log_generico_ciap );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_movatpermdocfisitem;
---------------------------------------------------
--| Procedimento de Integração do documento fiscal
---------------------------------------------------
procedure pkb_integr_movatpermdocfiscal ( est_log_generico_ciap                 in out nocopy  dbms_sql.number_table
                                        , est_row_movatpermdocfiscal       in out nocopy  mov_atperm_doc_fiscal%rowtype
                                        , ev_cod_part                      in             pessoa.cod_part%type
                                        , ev_cod_mod                       in             mod_fiscal.cod_mod%type
                                        , en_multorg_id                    in             mult_org.id%type
                                        ) is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ciap.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(est_row_movatpermdocfiscal.movatperm_id,0) <= 0 then
      --
      vn_fase := 2;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Movimentação de Ativo Permanente" não informado/integrado para a geração do Documento Fiscal.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_row_movatpermdocfiscal.dm_ind_emit,-1) not in (0, 1) then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Indicador do emitente do documento fiscal" não informado.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 4;
   --
   --
   if nvl(est_row_movatpermdocfiscal.pessoa_id,0) <= 0 then
      --
      est_row_movatpermdocfiscal.pessoa_id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id => en_multorg_id
                                                                            , ev_cod_part   => trim(ev_cod_part) );
      --
   end if;
   --
   vn_fase := 4.1;
   --
   if nvl(est_row_movatpermdocfiscal.pessoa_id,0) <= 0 then
      --
      vn_fase := 4.2;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Código do participante" ('||trim(ev_cod_part)||') está incorreto.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 5;
   --
   -- Recupera o modelo do documento fiscal
   if nvl(est_row_movatpermdocfiscal.modfiscal_id,0) <= 0 then
      --
      est_row_movatpermdocfiscal.modfiscal_id := pk_csf.fkg_Mod_Fiscal_id ( ev_cod_mod => trim(ev_cod_mod) );
      --
   end if;
   --
   vn_fase := 5.1;
   --
   if nvl(est_row_movatpermdocfiscal.modfiscal_id,0) <= 0 then
      --
      vn_fase := 5.2;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Modelo do Documento Fiscal" ('||trim(ev_cod_mod)||') está incorreto.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 6;
   --
   if nvl(est_row_movatpermdocfiscal.num_doc,0) <= 0 then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Número do Documento Fiscal" não informada.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 7;
   --
   if est_row_movatpermdocfiscal.dt_doc is null then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Data de emissão do documento fiscal" não informada.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_row_movatpermdocfiscal.movatperm_id,0) > 0
      and nvl(est_row_movatpermdocfiscal.dm_ind_emit,-1) in (0, 1)
      and nvl(est_row_movatpermdocfiscal.pessoa_id,0) > 0
      and nvl(est_row_movatpermdocfiscal.num_doc,0) > 0
      and nvl(est_row_movatpermdocfiscal.modfiscal_id, 0) > 0
      and est_row_movatpermdocfiscal.dt_doc is not null
      then
      --
      vn_fase := 99.1;
      --
      if nvl(gn_tipo_integr,0) = 1 then
         --
         est_row_movatpermdocfiscal.id := pk_csf_ciap.fkg_movatperdocfiscal_id ( en_movatperm_id => est_row_movatpermdocfiscal.movatperm_id
                                                                               , en_dm_ind_emit  => est_row_movatpermdocfiscal.dm_ind_emit
                                                                               , en_pessoa_id    => est_row_movatpermdocfiscal.pessoa_id
                                                                               , en_modfiscal_id => est_row_movatpermdocfiscal.modfiscal_id
                                                                               , ev_serie        => est_row_movatpermdocfiscal.serie
                                                                               , en_num_doc      => est_row_movatpermdocfiscal.num_doc                                								  
                                                                               , en_chv_nfe_cte  => est_row_movatpermdocfiscal.chv_nfe_cte );	 
         --
         if nvl(est_row_movatpermdocfiscal.id,0) <= 0 then
            --
            vn_fase := 99.2;
            --
            select movatpermdocfiscal_seq.nextval
              into est_row_movatpermdocfiscal.id
              from dual;
            --
            vn_fase := 99.3;
            --
            insert into mov_atperm_doc_fiscal ( id
                                              , movatperm_id
                                              , dm_ind_emit
                                              , pessoa_id
                                              , modfiscal_id
                                              , serie
                                              , num_doc
                                              , chv_nfe_cte
                                              , dt_doc
                                              )
                                       values ( est_row_movatpermdocfiscal.id
                                              , est_row_movatpermdocfiscal.movatperm_id
                                              , est_row_movatpermdocfiscal.dm_ind_emit
                                              , est_row_movatpermdocfiscal.pessoa_id
                                              , est_row_movatpermdocfiscal.modfiscal_id
                                              , est_row_movatpermdocfiscal.serie
                                              , est_row_movatpermdocfiscal.num_doc
                                              , est_row_movatpermdocfiscal.chv_nfe_cte
                                              , est_row_movatpermdocfiscal.dt_doc
                                              );
            --
         else
            --
            vn_fase := 99.4;
            update mov_atperm_doc_fiscal set movatperm_id  = est_row_movatpermdocfiscal.movatperm_id
                                           , dm_ind_emit   = est_row_movatpermdocfiscal.dm_ind_emit
                                           , pessoa_id     = est_row_movatpermdocfiscal.pessoa_id
                                           , modfiscal_id  = est_row_movatpermdocfiscal.modfiscal_id
                                           , serie         = est_row_movatpermdocfiscal.serie
                                           , num_doc       = est_row_movatpermdocfiscal.num_doc
                                           , chv_nfe_cte   = est_row_movatpermdocfiscal.chv_nfe_cte
                                           , dt_doc        = est_row_movatpermdocfiscal.dt_doc
             where id = est_row_movatpermdocfiscal.id;
            --
         end if;
         --
      end if;
      --	  
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_integr_movatpermdocfiscal fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ciap.id%TYPE;
      begin
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                             , est_log_generico_ciap  => est_log_generico_ciap );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_movatpermdocfiscal;
-------------------------------------------------------
--| Procedimento de Integração de Outros Créditos CIAP
-------------------------------------------------------
procedure pkb_integr_outro_cred_ciap ( est_log_generico_ciap         in out nocopy  dbms_sql.number_table
                                     , est_row_outro_cred_ciap  in out nocopy  outro_cred_ciap%rowtype
                                     ) is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ciap.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(est_row_outro_cred_ciap.movatperm_id,0) <= 0 then
      --
      vn_fase := 1.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Movimentação de Ativo Permanente" (identificador) não informado para geração de Outros Créditos de CIAP.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 2;
   --
   if est_row_outro_cred_ciap.dt_ini is null then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Data inicial a que a apuração anterior" não informada.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 3;
   --
   if est_row_outro_cred_ciap.dt_fim is null then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Data final a que a apuração anterior" não informada.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 4;
   --
   if est_row_outro_cred_ciap.dt_ini > est_row_outro_cred_ciap.dt_fim then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Data Inicial não pode ser maior que a Data Final.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 5;
   --
   if nvl(est_row_outro_cred_ciap.num_parc,0) <= 0 then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Número da parcela do ICMS" não pode ser zero ou negativa.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 6;
   --
   if nvl(est_row_outro_cred_ciap.vl_parc_pass,0) <= 0 then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Valor da parcela de ICMS passível de apropriação - antes da aplicação da participação percentual do valor das saídas '||
                         'tributadas/exportação sobre as saídas totais" não pode ser zero ou negativa.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 7;
   --
   if nvl(est_row_outro_cred_ciap.vl_trib_oc,0) <= 0 then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Valor do somatório das saídas tributadas e saídas para exportação no período indicado neste registro" não pode ser zero ou negativa.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 8;
   --
   if nvl(est_row_outro_cred_ciap.vl_total,0) <= 0 then
      --
      vn_fase := 8.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Valor total de saídas no período indicado neste registro" não pode ser zero ou negativa.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 9;
   --
   if nvl(est_row_outro_cred_ciap.ind_per_sai,0) < 0 then
      --
      vn_fase := 9.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Índice de participação do valor do somatório das saídas tributadas e saídas para exportação no valor total de saídas" não pode '||
                         'negativa.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 10;
   --
   if nvl(est_row_outro_cred_ciap.vl_parc_aprop,0) <= 0 then
      --
      vn_fase := 10.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Valor de outros créditos de ICMS a ser apropriado na apuração" não pode ser zero ou negativa.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_row_outro_cred_ciap.movatperm_id,0) > 0
      and est_row_outro_cred_ciap.dt_ini is not null
      and est_row_outro_cred_ciap.dt_fim is not null
      and nvl(est_row_outro_cred_ciap.num_parc,0) > 0 then
      --
      vn_fase := 99.1;
      --
      if nvl(gn_tipo_integr,0) = 1 then
         --	  
         est_row_outro_cred_ciap.id := pk_csf_ciap.fkg_outrocredciap_id ( en_movatperm_id  => est_row_outro_cred_ciap.movatperm_id
                                                                        , ed_dt_ini        => est_row_outro_cred_ciap.dt_ini
                                                                        , ed_dt_fim        => est_row_outro_cred_ciap.dt_fim
                                                                        , en_num_parc      => est_row_outro_cred_ciap.num_parc );	  
         --	  
         if nvl(est_row_outro_cred_ciap.id,0) <= 0 then
            --
            vn_fase := 99.2;
            --
            select outrocredciap_seq.nextval
              into est_row_outro_cred_ciap.id
              from dual;
            --
            vn_fase := 99.3;
            --
            insert into outro_cred_ciap ( id
                                        , movatperm_id
                                        , dt_ini
                                        , dt_fim
                                        , num_parc
                                        , vl_parc_pass
                                        , vl_trib_oc
                                        , vl_total
                                        , ind_per_sai
                                        , vl_parc_aprop
                                        )
                                 values ( est_row_outro_cred_ciap.id
                                        , est_row_outro_cred_ciap.movatperm_id
                                        , est_row_outro_cred_ciap.dt_ini
                                        , est_row_outro_cred_ciap.dt_fim
                                        , est_row_outro_cred_ciap.num_parc
                                        , nvl(est_row_outro_cred_ciap.vl_parc_pass,0)
                                        , nvl(est_row_outro_cred_ciap.vl_trib_oc,0)
                                        , nvl(est_row_outro_cred_ciap.vl_total,0)
                                        , nvl(est_row_outro_cred_ciap.ind_per_sai,0)
                                        , nvl(est_row_outro_cred_ciap.vl_parc_aprop,0)
                                        );
            --
         else
            --
            vn_fase := 99.4;
            --
            update outro_cred_ciap set movatperm_id   = est_row_outro_cred_ciap.movatperm_id
                                     , dt_ini         = est_row_outro_cred_ciap.dt_ini
                                     , dt_fim         = est_row_outro_cred_ciap.dt_fim
                                     , num_parc       = est_row_outro_cred_ciap.num_parc
                                     , vl_parc_pass   = nvl(est_row_outro_cred_ciap.vl_parc_pass,0)
                                     , vl_trib_oc     = nvl(est_row_outro_cred_ciap.vl_trib_oc,0)
                                     , vl_total       = nvl(est_row_outro_cred_ciap.vl_total,0)
                                     , ind_per_sai    = nvl(est_row_outro_cred_ciap.ind_per_sai,0)
                                     , vl_parc_aprop  = nvl(est_row_outro_cred_ciap.vl_parc_aprop,0)
             where id = est_row_outro_cred_ciap.id;
            --
         end if;
         --
      end if;
      --	  
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_integr_outro_cred_ciap fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ciap.id%TYPE;
      begin
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                             , est_log_generico_ciap  => est_log_generico_ciap );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_outro_cred_ciap;
-----------------------------------------------------------------------------------------
--| Procedimento de Integração de Movimentação do Bem ou Componente do Ativo Imobilizado
-----------------------------------------------------------------------------------------
procedure pkb_integr_mov_atperm ( est_log_generico_ciap            in out nocopy  dbms_sql.number_table
                                , est_row_mov_atperm          in out nocopy  mov_atperm%rowtype
                                , en_empresa_id               in             empresa.id%type
                                , ev_cod_ind_bem              in             bem_ativo_imob.cod_ind_bem%type
                                ) is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ciap.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(est_row_mov_atperm.icmsatpermciap_id,0) <= 0 then
      --
      vn_fase := 1.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Período de Apuração do CIAP" não informado para a Movimentação de Ativo Permanente.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 2;
   --
   if trim(ev_cod_ind_bem) is not null then
      --
      est_row_mov_atperm.bemativoimob_id := pk_csf_ciap.fkg_bemativoimob_id ( en_empresa_id   => en_empresa_id
                                                                            , ev_cod_ind_bem  => ev_cod_ind_bem
                                                                            );
      --
   end if;
   --
   vn_fase := 2.1;
   --
   if nvl(est_row_mov_atperm.bemativoimob_id,0) <= 0 then
      --
      vn_fase := 2.2;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Bem ou Componente do Ativo Imobilizado" ('||ev_cod_ind_bem||') está inválido. Não cadastrado/integrado com a empresa em questão.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 3;
   --
   if est_row_mov_atperm.dt_mov is null then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Data da movimentação ou do saldo inicial" não informada.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 4;
   --
   if est_row_mov_atperm.dm_tipo_mov not in ( 'SI', 'IM', 'IA', 'CI', 'MC', 'BA', 'AT', 'PE', 'OT' ) then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Tipo de movimentação do bem ou componente" ('||est_row_mov_atperm.dm_tipo_mov||') informada está inválida.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 5;
   --
   if nvl(est_row_mov_atperm.vl_imob_icms_op,0) < 0 then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Valor do ICMS da Operação Própria na entrada do bem ou componente" não pode ser negativa.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 6;
   --
   if nvl(est_row_mov_atperm.vl_imob_icms_st,0) < 0 then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Valor do ICMS da Oper. por Sub. Tributária na entrada do bem ou componente" não pode ser negativa.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 7;
   --
   if nvl(est_row_mov_atperm.vl_imob_icms_frt,0) < 0 then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Valor do ICMS sobre Frete do Conhecimento de Transporte na entrada do bem ou componente" não pode ser negativa.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 8;
   --
   if nvl(est_row_mov_atperm.vl_imob_icms_dif,0) < 0 then
      --
      vn_fase := 8.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Valor do ICMS - Diferencial de Alíquota, conforme Doc. de Arrecadação, na entrada do bem ou componente" não pode ser negativa.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 9;
   --
   if nvl(est_row_mov_atperm.num_parc,0) < 0 then
      --
      vn_fase := 9.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Número da parcela do ICMS" não pode ser negativa.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 10;
   --
   if nvl(est_row_mov_atperm.vl_parc_pass,0) < 0 then
      --
      vn_fase := 10.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Valor da parcela de ICMS passível de apropriação" não pode ser negativa.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_row_mov_atperm.icmsatpermciap_id,0) > 0
      and nvl(est_row_mov_atperm.bemativoimob_id,0) > 0
      and est_row_mov_atperm.dt_mov is not null
      and est_row_mov_atperm.dm_tipo_mov in ( 'SI', 'IM', 'IA', 'CI', 'MC', 'BA', 'AT', 'PE', 'OT' )
      then
      --
      vn_fase := 99.1;
      --
      if nvl(gn_tipo_integr,0) = 1 then
         --
         est_row_mov_atperm.id := pk_csf_ciap.fkg_movatper_id ( en_icmsatpermciap_id => est_row_mov_atperm.icmsatpermciap_id
                                                              , en_bemativoimob_id   => est_row_mov_atperm.bemativoimob_id
                                                              , ev_dm_tipo_mov       => est_row_mov_atperm.dm_tipo_mov );		 
         --	  
         if nvl(est_row_mov_atperm.id,0) <= 0 then
            --
            vn_fase := 99.2;
            --
            select movatperm_seq.nextval
              into est_row_mov_atperm.id
              from dual;
            --
            vn_fase := 99.3;
            --
            insert into mov_atperm ( id
                                   , icmsatpermciap_id
                                   , bemativoimob_id
                                   , dt_mov
                                   , dm_tipo_mov
                                   , vl_imob_icms_op
                                   , vl_imob_icms_st
                                   , vl_imob_icms_frt
                                   , vl_imob_icms_dif
                                   , num_parc
                                   , vl_parc_pass
                                   )
                            values ( est_row_mov_atperm.id
                                   , est_row_mov_atperm.icmsatpermciap_id
                                   , est_row_mov_atperm.bemativoimob_id
                                   , est_row_mov_atperm.dt_mov
                                   , est_row_mov_atperm.dm_tipo_mov
                                   , est_row_mov_atperm.vl_imob_icms_op
                                   , est_row_mov_atperm.vl_imob_icms_st
                                   , est_row_mov_atperm.vl_imob_icms_frt
                                   , est_row_mov_atperm.vl_imob_icms_dif
                                   , est_row_mov_atperm.num_parc
                                   , est_row_mov_atperm.vl_parc_pass
                                   );
            --
         else
            --
            vn_fase := 99.4;
            --
            update mov_atperm set icmsatpermciap_id  = est_row_mov_atperm.icmsatpermciap_id
                                , bemativoimob_id    = est_row_mov_atperm.bemativoimob_id
                                , dt_mov             = est_row_mov_atperm.dt_mov
                                , dm_tipo_mov        = est_row_mov_atperm.dm_tipo_mov
                                , vl_imob_icms_op    = est_row_mov_atperm.vl_imob_icms_op
                                , vl_imob_icms_st    = est_row_mov_atperm.vl_imob_icms_st
                                , vl_imob_icms_frt   = est_row_mov_atperm.vl_imob_icms_frt
                                , vl_imob_icms_dif   = est_row_mov_atperm.vl_imob_icms_dif
                                , num_parc           = est_row_mov_atperm.num_parc
                                , vl_parc_pass       = est_row_mov_atperm.vl_parc_pass
             where id = est_row_mov_atperm.id;
            --
         end if;
         --
      end if;
      --	  
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_integr_mov_atperm fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ciap.id%TYPE;
      begin
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                             , est_log_generico_ciap  => est_log_generico_ciap );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_mov_atperm;
----------------------------------------------------
--| Procedimento de integração do cabeçalho do CIAP
----------------------------------------------------
procedure pkb_integr_icms_atperm_ciap ( est_log_generico_ciap            in out nocopy  dbms_sql.number_table
                                      , est_row_icms_atperm_ciap    in out nocopy  icms_atperm_ciap%rowtype
                                      , ev_empresa_cpf_cnpj         in             varchar2                 default null -- CPF/CNPJ da empresa
                                      , en_multorg_id               in             mult_org.id%type
                                      , en_loteintws_id             in             lote_int_ws.id%type default 0
                                      ) is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ciap.id%type;
   vn_count           integer:=0;
   --
begin
   --
   vn_fase := 1;
   --
   -- Recupera ID da empresa
   if nvl(est_row_icms_atperm_ciap.empresa_id,0) <= 0 then
      --
      est_row_icms_atperm_ciap.empresa_id := pk_csf.fkg_empresa_id2 ( en_multorg_id        => en_multorg_id
                                                                    , ev_cod_matriz        => null
                                                                    , ev_cod_filial        => null
                                                                    , ev_empresa_cpf_cnpj  => ev_empresa_cpf_cnpj );
      --
   end if;
   --
   vn_fase := 1.1;
   -- Monta Cabeçalho do log
   if nvl(est_row_icms_atperm_ciap.empresa_id,0) > 0 then
      --
      gv_cabec_log := 'Empresa: ' || pk_csf.fkg_nome_empresa ( en_empresa_id => est_row_icms_atperm_ciap.empresa_id );
      --
      gv_cabec_log := gv_cabec_log || chr(10);
      --
   end if;
   --
   vn_fase := 1.2;
   --
   gv_cabec_log := gv_cabec_log || 'Data Inicial: ' || to_char(est_row_icms_atperm_ciap.dt_ini, 'dd/mm/rrrr') || chr(10);
   gv_cabec_log := gv_cabec_log || 'Data Final: ' || to_char(est_row_icms_atperm_ciap.dt_fin, 'dd/mm/rrrr') || chr(10);
   --
   if nvl(en_loteintws_id,0) > 0 then
      gv_cabec_log := gv_cabec_log || 'Lote WS: ' || en_loteintws_id || chr(10);
   end if;
   --
   vn_fase := 1.3;
   --
   -- Busca se o registro movimento já existe no sistema.
   if nvl(est_row_icms_atperm_ciap.empresa_id, 0) > 0
      and est_row_icms_atperm_ciap.dt_ini is not null
      and est_row_icms_atperm_ciap.dt_fin is not null then
      --
      vn_fase := 1.4;
      --
      est_row_icms_atperm_ciap.id := pk_csf_ciap.fkg_icmsatpermciap_id ( en_empresa_id => est_row_icms_atperm_ciap.empresa_id
                                                                       , ed_dt_ini => est_row_icms_atperm_ciap.dt_ini
                                                                       , ed_dt_fin =>  est_row_icms_atperm_ciap.dt_fin );
      --
   end if;
   --
   vn_fase := 1.5;
   --
   if nvl(est_row_icms_atperm_ciap.id,0) <= 0
      and nvl(gn_tipo_integr,0) = 1 -- Valida e integra
      then
      --
      vn_count:=pk_csf_ciap.fkg_icmsatpermciap_mes(en_empresa_id => est_row_icms_atperm_ciap.empresa_id,
                                                   ed_dt_ini => est_row_icms_atperm_ciap.dt_ini);
      if vn_count = 0 then
        select icmsatpermciap_seq.nextval
          into est_row_icms_atperm_ciap.id
          from dual;
      else
        --
        gv_mensagem_log := null;
        --
        gv_mensagem_log := 'Já existe registro gerado para esta empresa no periodo '||to_char(est_row_icms_atperm_ciap.dt_ini,'mm/rrrr')||'.' ;
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                         , ev_mensagem        => gv_cabec_log
                         , ev_resumo          => gv_mensagem_log
                         , en_tipo_log        => ERRO_DE_VALIDACAO
                         , en_referencia_id   => gn_referencia_id
                         , ev_obj_referencia  => gv_obj_referencia );
        --
        -- Armazena o "loggenerico_id" na memória
        pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                            , est_log_generico_ciap  => est_log_generico_ciap );
        --        
      end if;
      --
   end if;
   --
   vn_fase := 1.6;
   --
   if nvl(gn_tipo_integr,0) = 1 -- Valida e integra
      then
      --
      pkb_excluir_ciap ( est_log_generico_ciap     => est_log_generico_ciap
                       , en_icmsatpermciap_id    => est_row_icms_atperm_ciap.id
                       );
      --
   end if;
   --
   vn_fase := 1.7;
   --
   pkb_seta_referencia_id ( en_id => est_row_icms_atperm_ciap.id );
   --
   vn_fase := 1.8;
   -- remove os logs anteriores
   delete from log_generico_ciap
    where referencia_id = gn_referencia_id
      and obj_referencia = gv_obj_referencia;
   --
   vn_fase := 2;
   --
   -- Válida se a empresa é válida
   if pk_csf.fkg_empresa_id_valido ( en_empresa_id => est_row_icms_atperm_ciap.empresa_id ) = false then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Empresa" ('||est_row_icms_atperm_ciap.empresa_id||') está incorreta.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 3;
   --
   if est_row_icms_atperm_ciap.dt_ini is null then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := null;
      --
      est_row_icms_atperm_ciap.dt_ini := sysdate;
      --
      gv_mensagem_log := '"Data Inicial" não informada.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 4;
   --
   if est_row_icms_atperm_ciap.dt_fin is null then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := null;
      --
      est_row_icms_atperm_ciap.dt_fin := sysdate;
      --
      gv_mensagem_log := '"Data Final" não informada.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 5;
   -- valida datas
   if est_row_icms_atperm_ciap.dt_ini > est_row_icms_atperm_ciap.dt_fin then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Data Inicial não pode ser maior que a Data Final.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 6;
   --
   if nvl(est_row_icms_atperm_ciap.vl_saldo_in_icms,0) < 0 then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Saldo inicial de ICMS do CIAP" não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 7;
   --
   if nvl(est_row_icms_atperm_ciap.vl_som_parc,0) < 0 then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Somatório das parcelas de ICMS passível de apropriação de cada bem" não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 8;
   --
   if nvl(est_row_icms_atperm_ciap.vl_trib_exp,0) < 0 then
      --
      vn_fase := 8.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Valor do somatório das saídas tributadas e saídas para exportação" não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 9;
   --
   if nvl(est_row_icms_atperm_ciap.vl_total,0) < 0 then
      --
      vn_fase := 9.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Valor total de saídas" não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 10;
   --
   if nvl(est_row_icms_atperm_ciap.vl_icms_aprop,0) < 0 then
      --
      vn_fase := 10.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Valor de ICMS a ser apropriado na apuração do ICMS" não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 11;
   --
   if nvl(est_row_icms_atperm_ciap.ind_per_sai,0) < 0 then
      --
      vn_fase := 11.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Índice de participação do valor do somatório das saídas tributadas e saídas para exportação no valor total de saídas" não pode '||
                         'ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 12;
   --
   if nvl(est_row_icms_atperm_ciap.vl_som_icms_oc,0) < 0 then
      --
      vn_fase := 12.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Valor de outros créditos a ser apropriado na Apuração do ICMS" não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 13;
   --
   if nvl(est_row_icms_atperm_ciap.dm_st_proc,-1) not in (0, 1, 2, 3, 4, 5, 6) then
      --
      vn_fase := 13.1;
      --
      gv_mensagem_log := null;
      --
      est_row_icms_atperm_ciap.dm_st_proc := 2;
      --
      gv_mensagem_log := '"Situação" informada está inválida ('||nvl(est_row_icms_atperm_ciap.dm_st_proc,-1)||')!';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 14;
   --
   if nvl(est_row_icms_atperm_ciap.dm_st_integra,-1) not in (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 15) then
      --
      vn_fase := 14.1;
      --
      gv_mensagem_log := null;
      --
      est_row_icms_atperm_ciap.dm_st_integra := 0;
      --
      gv_mensagem_log := '"Situação de integração" informada está inválida ('||nvl(est_row_icms_atperm_ciap.dm_st_integra,-1)||')!';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                          , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 99;
   -- Se não teve erro na validação, integra a nota fiscal
   -- Se não existe registro de Log e o Tipo de integração é 1 (válida e insere)
   if nvl(est_log_generico_ciap.count,0) > 0 then
      --
      est_row_icms_atperm_ciap.dm_st_proc := 2;
      --
   end if;
   --
   vn_fase := 99.1;
   --
   if nvl(est_row_icms_atperm_ciap.empresa_id,0) > 0
      and est_row_icms_atperm_ciap.dt_ini is not null
      and est_row_icms_atperm_ciap.dt_fin is not null
      then
      --
      vn_fase := 99.2;
      --
      -- Calcula a quantidade de registros Totais integrados para ser
      -- mostrado na tela de agendamento.
      --
      begin
         pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
      exception
         when others then
         null;
      end;
      --
      if nvl(gn_tipo_integr,0) = 1 then
         --
         vn_fase := 99.3;
         --
         if pk_csf_ciap.fkg_existe_ciap (en_icmsatpermciap_id => est_row_icms_atperm_ciap.id ) = True then
            --
            vn_fase := 99.4;
            --
            update icms_atperm_ciap set empresa_id        = est_row_icms_atperm_ciap.empresa_id
                                      , dt_ini            = est_row_icms_atperm_ciap.dt_ini
                                      , dt_fin            = est_row_icms_atperm_ciap.dt_fin
                                      , vl_saldo_in_icms  = nvl(est_row_icms_atperm_ciap.vl_saldo_in_icms, 0)
                                      , vl_som_parc       = nvl(est_row_icms_atperm_ciap.vl_som_parc, 0)
                                      , vl_trib_exp       = nvl(est_row_icms_atperm_ciap.vl_trib_exp, 0)
                                      , vl_total          = nvl(est_row_icms_atperm_ciap.vl_total, 0)
                                      , vl_icms_aprop     = nvl(est_row_icms_atperm_ciap.vl_icms_aprop, 0)
                                      , ind_per_sai       = nvl(est_row_icms_atperm_ciap.ind_per_sai, 0)
                                      , vl_som_icms_oc    = nvl(est_row_icms_atperm_ciap.vl_som_icms_oc, 0)
                                      , dm_st_proc        = est_row_icms_atperm_ciap.dm_st_proc
                                      , dm_st_integra     = est_row_icms_atperm_ciap.dm_st_integra
            where id = est_row_icms_atperm_ciap.id;
            --
         else
            --
            vn_fase := 99.5;
            --
            insert into icms_atperm_ciap ( id
                                         , empresa_id
                                         , dt_ini
                                         , dt_fin
                                         , vl_saldo_in_icms
                                         , vl_som_parc
                                         , vl_trib_exp
                                         , vl_total
                                         , vl_icms_aprop
                                         , ind_per_sai
                                         , vl_som_icms_oc
                                         , dm_st_proc
                                         , dm_st_integra
                                         )
                                  values ( est_row_icms_atperm_ciap.id
                                         , est_row_icms_atperm_ciap.empresa_id
                                         , est_row_icms_atperm_ciap.dt_ini
                                         , est_row_icms_atperm_ciap.dt_fin
                                         , nvl(est_row_icms_atperm_ciap.vl_saldo_in_icms, 0)
                                         , nvl(est_row_icms_atperm_ciap.vl_som_parc, 0)
                                         , nvl(est_row_icms_atperm_ciap.vl_trib_exp, 0)
                                         , nvl(est_row_icms_atperm_ciap.vl_total, 0)
                                         , nvl(est_row_icms_atperm_ciap.vl_icms_aprop, 0)
                                         , nvl(est_row_icms_atperm_ciap.ind_per_sai, 0)
                                         , nvl(est_row_icms_atperm_ciap.vl_som_icms_oc, 0)
                                         , est_row_icms_atperm_ciap.dm_st_proc
                                         , est_row_icms_atperm_ciap.dm_st_integra
                                         );
            --
         end if;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_integr_icms_atperm_ciap fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ciap.id%TYPE;
      begin
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                             , est_log_generico_ciap  => est_log_generico_ciap );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_icms_atperm_ciap;
----------------------------------------------------------------------------------------------------------
--| Válida informação dos documentos fiscais relacionados ao ciap com as notas fiscais integradas no C100
----------------------------------------------------------------------------------------------------------
procedure pkb_valida_ciap_nf ( est_log_generico_ciap     in out nocopy dbms_sql.number_table
                             , en_icmsatpermciap_id in            icms_atperm_ciap.id%type
                             ) is
   --
   vn_fase              number := 0;
   vn_loggenerico_id    log_generico_ciap.id%type;
   vn_notafiscal_id     nota_fiscal.id%type;
   vn_empresa_id        empresa.id%type;
   vn_dm_dt_escr_dfepoe empresa.dm_dt_escr_dfepoe%type;
   --
   cursor c_movat is
      select ma.id movatperm_id
           , ma.bemativoimob_id
        from mov_atperm ma
       where ma.icmsatpermciap_id = en_icmsatpermciap_id
         and ma.num_parc          = 1
         and ma.dm_tipo_mov      in ('MC', 'IM', 'IA', 'AT')
       order by ma.bemativoimob_id;
   --
   cursor c_doctonf (en_movatperm_id in mov_atperm.id%type) is
      select ma.dm_ind_emit
           , ma.pessoa_id
           , ma.modfiscal_id
           , ma.serie
           , ma.num_doc
           , ma.dt_doc
        from mov_atperm_doc_fiscal ma
       where ma.movatperm_id = en_movatperm_id;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_icmsatpermciap_id,0) > 0 then
      --
      vn_fase := 2;
      --
      for r_mov in c_movat
      loop
         --
         exit when c_movat%notfound or (c_movat%notfound) is null;
         --
         vn_fase := 3;
         -- Verificar se o movimento possui documento fiscal vinculado e verificar se o mesmo está integrado com C100-NF:
         -- Nota fiscal (código 01), nota fiscal avulsa (código 1B), nota fiscal de produtor (código 04) e nfe (código 55)
         if pk_csf_ciap.fkg_existe_doc_fiscal_ciap ( en_movatperm_id => r_mov.movatperm_id) = true then
            --
            vn_fase := 4;
            --
            for r_docnf in c_doctonf ( en_movatperm_id => r_mov.movatperm_id )
            loop
               --
               exit when c_doctonf%notfound or (c_doctonf%notfound) is null;
               --
               vn_fase := 5;
               --
               if pk_csf.fkg_cod_mod_id(r_docnf.modfiscal_id) in ('01', '1B', '04', '55') then
                  --
                  vn_fase := 6;
                  --
                  begin
                     select ia.empresa_id
                       into vn_empresa_id
                       from icms_atperm_ciap ia
                      where ia.id = en_icmsatpermciap_id;
                  exception
                     when others then
                        --
                        gv_mensagem_log := 'Problemas ao recuperar identificador da empresa - pkb_csf_api_ciap.pkb_valida_ciap_nf - identificador do icms '||
                                           'ativo permanente = '||en_icmsatpermciap_id||' fase ('||vn_fase||'). Erro = '||sqlerrm;
                        --
                        declare
                           vn_loggenerico_id  log_generico_ciap.id%type;
                        begin
                           --
                           pkb_log_generico_ciap ( sn_loggenericociap_id => vn_loggenerico_id
                                            , ev_mensagem       => gv_cabec_log
                                            , ev_resumo         => gv_mensagem_log
                                            , en_tipo_log       => erro_de_sistema
                                            , en_referencia_id  => gn_referencia_id
                                            , ev_obj_referencia => gv_obj_referencia );
                           --
                           -- Armazena o "loggenerico_id" na memória
                           pkb_gt_log_generico_ciap ( en_loggenericociap_id   => vn_loggenerico_id
                                               , est_log_generico_ciap => est_log_generico_ciap );
                           --
                        exception
                           when others then
                              null;
                        end;
                        --
                  end;
                  --
                  vn_fase := 7;
                  --
                  vn_dm_dt_escr_dfepoe := pk_csf.fkg_dmdtescrdfepoe_empresa( en_empresa_id => vn_empresa_id );
                  --
                  begin
                     select nf.id
                       into vn_notafiscal_id
                       from nota_fiscal nf
                      where nf.empresa_id      = vn_empresa_id
                        and nf.dm_ind_emit     = r_docnf.dm_ind_emit
                        and nf.serie           = trim(r_docnf.serie)
                        and nf.nro_nf          = r_docnf.num_doc
                        and nf.dm_arm_nfe_terc = 0
                        and nf.modfiscal_id    = r_docnf.modfiscal_id
                        and nf.pessoa_id       = r_docnf.pessoa_id
                        and nf.dm_st_proc      = 4 -- 4-Autorizada
                        and ((nf.dm_ind_emit = 1 and (trunc(nf.dt_sai_ent) = r_docnf.dt_doc or trunc(nf.dt_emiss) = r_docnf.dt_doc))
                              or
                             (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) = r_docnf.dt_doc)
                              or
                             (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and vn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) = r_docnf.dt_doc)
                              or
                             (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and vn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) = r_docnf.dt_doc));
                  exception
                     when no_data_found then
                        --
                        if pk_csf.fkg_is_numerico(trim(r_docnf.serie)) then
                           --
                           begin
                              select nf.id
                                into vn_notafiscal_id
                                from nota_fiscal nf
                               where nf.empresa_id      = vn_empresa_id
                                 and nf.dm_ind_emit     = r_docnf.dm_ind_emit
                                 and nf.serie           = to_number(trim(r_docnf.serie))
                                 and nf.nro_nf          = r_docnf.num_doc
                                 and nf.dm_arm_nfe_terc = 0
                                 and nf.modfiscal_id    = r_docnf.modfiscal_id
                                 and nf.pessoa_id       = r_docnf.pessoa_id
                                 and nf.dm_st_proc      = 4 -- 4-Autorizada
                                 and ((nf.dm_ind_emit = 1 and (trunc(nf.dt_sai_ent) = r_docnf.dt_doc or trunc(nf.dt_emiss) = r_docnf.dt_doc))
                                       or
                                      (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) = r_docnf.dt_doc)
                                       or
                                      (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and vn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) = r_docnf.dt_doc)
                                       or
                                      (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and vn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) = r_docnf.dt_doc));
                           exception
                              when no_data_found then
                                 vn_notafiscal_id := 0;
                              when too_many_rows then
                                 vn_notafiscal_id := 1;
                              when others then
                                 --
                                 gv_mensagem_log := 'Problemas ao recuperar identificador da nota fiscal, com série numérica - pkb_csf_api_ciap.'||
                                                    'pkb_valida_ciap_nf - identificador do icms ativo permanente = '||en_icmsatpermciap_id||' fase ('||
                                                    vn_fase||'). Erro = '||sqlerrm;
                                 --
                                 declare
                                    vn_loggenerico_id  log_generico_ciap.id%type;
                                 begin
                                    --
                                    pkb_log_generico_ciap ( sn_loggenericociap_id => vn_loggenerico_id
                                                          , ev_mensagem           => gv_cabec_log
                                                          , ev_resumo             => gv_mensagem_log
                                                          , en_tipo_log           => erro_de_sistema
                                                          , en_referencia_id      => gn_referencia_id
                                                          , ev_obj_referencia     => gv_obj_referencia );
                                    --
                                    -- Armazena o "loggenerico_id" na memória
                                    pkb_gt_log_generico_ciap ( en_loggenericociap_id => vn_loggenerico_id
                                                             , est_log_generico_ciap => est_log_generico_ciap );
                                    --
                                 exception
                                    when others then
                                       null;
                                 end;
                                 --
                           end;
                           --
                        else
                           vn_notafiscal_id := 0;
                        end if;
                        --
                     when too_many_rows then
                        vn_notafiscal_id := 1;
                     when others then
                        --
                        gv_mensagem_log := 'Problemas ao recuperar identificador da nota fiscal - pkb_csf_api_ciap.pkb_valida_ciap_nf - identificador do icms '||
                                           'ativo permanente = '||en_icmsatpermciap_id||' fase ('||vn_fase||'). Erro = '||sqlerrm;
                        --
                        declare
                           vn_loggenerico_id  log_generico_ciap.id%type;
                        begin
                           --
                           pkb_log_generico_ciap ( sn_loggenericociap_id => vn_loggenerico_id
                                            , ev_mensagem       => gv_cabec_log
                                            , ev_resumo         => gv_mensagem_log
                                            , en_tipo_log       => erro_de_sistema
                                            , en_referencia_id  => gn_referencia_id
                                            , ev_obj_referencia => gv_obj_referencia );
                           --
                           -- Armazena o "loggenerico_id" na memória
                           pkb_gt_log_generico_ciap ( en_loggenericociap_id   => vn_loggenerico_id
                                               , est_log_generico_ciap => est_log_generico_ciap );
                           --
                        exception
                           when others then
                              null;
                        end;
                        --
                  end;
                  --
                  vn_fase := 8;
                  --
                  if nvl(vn_notafiscal_id,0) = 0 and
                     pk_csf_ciap.fkg_valdocfiscciap_empresa(vn_empresa_id) then -- True: o docto deve ser validado
                     --
                     vn_fase := 9;
                     --
                     gv_mensagem_log := 'O "Documento Fiscal" que acobertou a entrada/saída do "Bem ou Componente do CIAP" não foi encontrado nos documentos '||
                                        'fiscais integrados e autorizados (Bem do Ativo = '||pk_csf_ciap.fkg_bemativoimob_cd(r_mov.bemativoimob_id)||
                                        ', Número do documento = '||r_docnf.num_doc||' Série = '||r_docnf.serie||' Modelo = '||
                                        pk_csf.fkg_cod_mod_id(r_docnf.modfiscal_id)||' Data = '||r_docnf.dt_doc||' Participante = '||
                                        pk_csf.fkg_pessoa_cod_part(r_docnf.pessoa_id)||' - '||pk_csf.fkg_dominio('NOTA_FISCAL.DM_IND_EMIT',r_docnf.dm_ind_emit)||').';
                     --
                     vn_loggenerico_id := null;
                     --
                     pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                                      , ev_mensagem        => gv_cabec_log
                                      , ev_resumo          => gv_mensagem_log
                                      , en_tipo_log        => erro_de_validacao
                                      , en_referencia_id   => gn_referencia_id
                                      , ev_obj_referencia  => gv_obj_referencia );
                     --
                     -- Armazena o "loggenerico_id" na memória
                     pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                         , est_log_generico_ciap  => est_log_generico_ciap );
                     --
                  end if;
                  --
               end if;
               --
            end loop;
            --
         end if; -- pk_csf_ciap.fkg_existe_doc_fiscal_ciap ( en_movatperm_id => r_mov.movatperm_id) = false
         --
      end loop;
      --
   end if; -- nvl(en_icmsatpermciap_id,0) = 0
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_valida_ciap_nf fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ciap.id%TYPE;
      begin
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id => vn_loggenerico_id
                          , ev_mensagem       => gv_cabec_log
                          , ev_resumo         => gv_mensagem_log
                          , en_tipo_log       => erro_de_sistema
                          , en_referencia_id  => gn_referencia_id
                          , ev_obj_referencia => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ciap ( en_loggenericociap_id   => vn_loggenerico_id
                             , est_log_generico_ciap => est_log_generico_ciap );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_valida_ciap_nf;
--------------------------------------------------------------
--| Válida informação dos bens que estão relacionados ao ciap
--------------------------------------------------------------
procedure pkb_valida_bem_ativo_imob ( est_log_generico_ciap     in out nocopy  dbms_sql.number_table
                                    , en_icmsatpermciap_id in             icms_atperm_ciap.Id%TYPE
                                    ) is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ciap.id%type;
   --
   cursor c_Bem_Ativo_Imob is
      select distinct b.bemativoimob_id
            , a.cod_ind_bem
            , a.dm_ident_merc
            , a.ar_bemativoimob_id
        from bem_ativo_imob a
           , mov_atperm b
       where b.icmsatpermciap_id = en_icmsatpermciap_id
         and b.bemativoimob_id = a.id
       order by b.bemativoimob_id;
   --
Begin
   --
   vn_fase := 1;
   --
   if nvl(en_icmsatpermciap_id,0) > 0 then
      --
      vn_fase := 1.1;

      for rec in c_Bem_Ativo_Imob loop
         exit when c_Bem_Ativo_Imob%notfound or (c_Bem_Ativo_Imob%notfound) is null;
         --
         vn_fase := 2;
         --
         -- Se o imobilizado for um componente obrigatoriamente ele deve ter uma Bem(  "Pai" ) relacionado a ele.
         if nvl(rec.dm_ident_merc, 0) = 2
            and nvl(rec.ar_bemativoimob_id, 0) = 0 then
            --
            vn_fase := 2.1;
            --
            gv_mensagem_log := 'O "Componente Imobilizado" ( Código: '||rec.cod_ind_bem||') '||'não possui um "Bem Principal" relacionado a ele.';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                , est_log_generico_ciap  => est_log_generico_ciap );
            --
         end if;
         --
         vn_fase := 3;
         --
         -- Se o imobilizado for um componente obrigatoriamente ele deve ter uma Bem Principal ( "Pai" ) relacionado a ele.
         if nvl(rec.dm_ident_merc, 0) = 1
            and pk_csf_ciap.fkg_existe_inforutilbem_id ( en_bemativoimob_id => rec.bemativoimob_id) = False then
            --
            vn_fase := 3.1;
            --
            gv_mensagem_log := 'O "Bem Imobilizado" ( Código: '||rec.cod_ind_bem||') não possui informações sobre a utilização do bem.';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                , est_log_generico_ciap  => est_log_generico_ciap );
            --
         end if;
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_valida_bem_ativo_imob fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ciap.id%TYPE;
      begin
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                             , est_log_generico_ciap  => est_log_generico_ciap );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_valida_bem_ativo_imob;
--------------------------------------------------------------------------------------
--| Válida informação dos itens das notas fiscal que registram a movimentação do ciap
--------------------------------------------------------------------------------------
procedure pkb_valida_mov_atperm_itemdc ( est_log_generico_ciap     in out nocopy  dbms_sql.number_table
                                       , en_icmsatpermciap_id in             icms_atperm_ciap.Id%TYPE
                                       ) is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ciap.id%type;
   vv_cod_ind_bem     bem_ativo_imob.cod_ind_bem%type;
   --
   cursor c_Mov_Atperm_dc is
      select mv.bemativoimob_id
           , mv.dm_tipo_mov
           , nf.id
        from mov_atperm mv
           , mov_atperm_doc_fiscal nf
       where mv.dm_tipo_mov in ('MC', 'IM', 'IA', 'AT')
         and mv.icmsatpermciap_id = en_icmsatpermciap_id
         and mv.id = nf.movatperm_id
       order by mv.bemativoimob_id
           , nf.id;
   --
Begin
   --
   vn_fase := 1;
   --
   if nvl(en_icmsatpermciap_id,0) > 0 then
      --
      vn_fase := 2;
      -- Informações sobre os bens imobilizados e nota fiscal relacionada.
      for rec in c_Mov_Atperm_dc loop
         exit when c_Mov_Atperm_dc%notfound or (c_Mov_Atperm_dc%notfound) is null;
         --
         vn_fase := 3;
         --
         -- Busca o código do bem ou componente imobilizado
         vv_cod_ind_bem := pk_csf_ciap.fkg_bemativoimob_cd ( en_bemativoimob_id => rec.bemativoimob_id);
         --
         -- Verifica se a nota tem item relacionado.
         if pk_csf_ciap.fkg_existe_itemdocfiscal_ciap ( en_movatpermdocfiscal_id => rec.id ) = false then
            --
            vn_fase := 4;
            --
            gv_mensagem_log := 'O "Documento Fiscal" que acobertou a entrada ou saída do "Bem ou Componente do CIAP" ('||vv_cod_ind_bem||
                               ') obrigatoriamente deve ter item.';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                , est_log_generico_ciap  => est_log_generico_ciap );
            --
         end if ;
         --
      --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_valida_mov_atperm_itemdc fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ciap.id%TYPE;
      begin
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                             , est_log_generico_ciap  => est_log_generico_ciap );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_valida_mov_atperm_itemdc;
---------------------------------------------
--| Válida informação dos documentos Fiscais
---------------------------------------------
procedure pkb_valida_mov_atperm_dc ( est_log_generico_ciap     in out nocopy  dbms_sql.number_table
                                   , en_icmsatpermciap_id in             icms_atperm_ciap.Id%TYPE
                                   ) is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ciap.id%type;
   --
   cursor c_Mov_Atperm is
      select mv.id movatperm_id
           , mv.bemativoimob_id
        from mov_atperm mv
       where mv.icmsatpermciap_id = en_icmsatpermciap_id
         and mv.dm_tipo_mov in ('MC', 'IM', 'IA', 'AT')
    order by mv.dt_mov,
             mv.bemativoimob_id;
    --
Begin
   --
   vn_fase := 1;
   --
   if nvl(en_icmsatpermciap_id,0) > 0 then
      --
      vn_fase := 1.1;
      --
      for rec in c_Mov_Atperm loop
         exit when c_Mov_Atperm%notfound or (c_Mov_Atperm%notfound) is null;
         --
         vn_fase := 2;
         --
         -- Quando o tipo de Movimentação do Bem ou Componente Imobilizado for MC, IM, IA ou AT, o documento fiscal é obrigatório
         if pk_csf_ciap.fkg_existe_doc_fiscal_ciap ( en_movatperm_id => rec.movatperm_id) = false then
            --
            vn_fase := 2.1;
            --
            gv_mensagem_log := 'O "Documento Fiscal" que acobertou a entrada ou saída do "Bem ou Componente do CIAP" ('||
                               pk_csf_ciap.fkg_bemativoimob_cd(rec.bemativoimob_id)||') obrigatoriamente deve ser informado.';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                , est_log_generico_ciap  => est_log_generico_ciap );
            --
         end if;
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_valida_mov_atperm_dc fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ciap.id%TYPE;
      begin
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                             , est_log_generico_ciap  => est_log_generico_ciap );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_valida_mov_atperm_dc;
-----------------------------------------
--| Válida informação dos totais do ciap
-----------------------------------------
procedure pkb_valida_outro_cred_ciap ( est_log_generico_ciap     in out nocopy  dbms_sql.number_table
                                     , en_icmsatpermciap_id in             icms_atperm_ciap.Id%TYPE
                                     ) is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ciap.id%type;
   vn_ind_per_sai     number := 0;
   --
   cursor c_Outro_Cred_Ciap is
   select oc.*
     from outro_cred_ciap oc
        , mov_atperm mv
    where mv.icmsatpermciap_id = en_icmsatpermciap_id
      and mv.id = oc.movatperm_id;
   --
Begin
   --
   vn_fase := 1;
   --
   if nvl(en_icmsatpermciap_id,0) > 0 then
      --
      vn_fase := 1.1;

      for rec in c_Outro_Cred_Ciap loop
         exit when c_Outro_Cred_Ciap%notfound or (c_Outro_Cred_Ciap%notfound) is null;
         --
         vn_fase := 2;
         --
         vn_ind_per_sai := pk_csf_ciap.fkg_ind_per_out_cred ( en_outrocredciap_id => rec.id );
         --
         -- Compara se o Indice de Participação  com o valor da divisão do  vl_trib_oc pelo vl_total
         if vn_ind_per_sai <> rec.ind_per_sai then
            --
            vn_fase := 2.1;
            --
            gv_mensagem_log := 'O "Índice de Participação do Outros Créd. do CIAP" ('||rec.ind_per_sai||') deve correspondente ao resultado da divisão das '||
                               '"Vlr Saídas Trib. e Saídas para Exportação de Outros Créd. do CIAP" ('||rec.vl_trib_oc||') pelo "Vlr Total de Saídas de '||
                               'Outros Créd. do CIAP" ('||rec.vl_total||').';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                , est_log_generico_ciap  => est_log_generico_ciap );
            --
         end if;
         --
         vn_fase := 3;
         --
         -- O valor do campo VL_parc_aprop deve ser menor ou igual a multiplicação entre o campo vl_par_pass pelo ind_per_sai
         if rec.vl_parc_aprop > round(rec.vl_parc_pass * rec.ind_per_sai, 2) then
            --
            vn_fase := 3.1;
            --
            gv_mensagem_log := 'O "Vlr de Outros Créditos de ICMS a ser apropriado na apuração do ICMS" ('||rec.vl_parc_aprop||') deve ser menor ou igual '||
                               'da multiplicação "Valor de ICMS Passível de Apropriação" ('||rec.vl_parc_pass||') com o "Indíce de Participação do Outros '||
                               'Créd. do CIAP" ('||rec.ind_per_sai||').';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                , est_log_generico_ciap  => est_log_generico_ciap );
            --
         end if;
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_valida_outro_cred_ciap fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ciap.id%TYPE;
      begin
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                             , est_log_generico_ciap  => est_log_generico_ciap );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_valida_outro_cred_ciap;
--------------------------------------------------------------------------------
--| Válida informação da movimentação de bem ou componente do ativo imobilizado
--------------------------------------------------------------------------------
procedure pkb_valida_mov_atperm ( est_log_generico_ciap     in out nocopy  dbms_sql.number_table
                                , en_icmsatpermciap_id in             icms_atperm_ciap.Id%TYPE
                                ) is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ciap.id%type;
   vd_dt_ini          icms_atperm_ciap.dt_ini%type;
   vd_dt_fin          icms_atperm_ciap.dt_fin%type;
   vn_parcela         mov_atperm.vl_parc_pass%type;
   vv_cod_ind_bem     bem_ativo_imob.cod_ind_bem%type;
   vn_nr_parc_bem     bem_ativo_imob.nr_parc%type;
   vn_dif             number := 0;
   --
   cursor c_mov_atperm_comb is
      select count(m.id) qtde
           , m.bemativoimob_id
           , m.dm_tipo_mov
        from mov_atperm m
       where m.icmsatpermciap_id = en_icmsatpermciap_id
    group by m.bemativoimob_id
           , m.dm_tipo_mov
      having count(m.id) > 1;
   --
   cursor c_mov_atperm is
      select m.*
        from mov_atperm m
       where m.icmsatpermciap_id = en_icmsatpermciap_id;
   --
Begin
   --
   vn_fase := 1;
   --
   if nvl(en_icmsatpermciap_id,0) > 0 then
      --
      vn_fase := 2;
      -- Validação: Não podem ser informados dois ou mais registros com a mesma combinação de conteúdo nos campos COD_IND_BEM e TIPO_MOV.
      for rec in c_mov_atperm_comb loop
         exit when c_mov_atperm_comb%notfound or (c_mov_atperm_comb%notfound) is null;
         --
         vn_dif := 0;
         --
         vn_fase := 3;
         --
         if rec.qtde > 1 then
            --
            vn_fase := 3.1;
            --
            gv_mensagem_log := 'Não pode ser informado dois ou mais "Códigos de Bens ou Componentes" ('||pk_csf_ciap.fkg_bemativoimob_cd(rec.bemativoimob_id)||
                               ') para o mesmo tipo de movimento ('||rec.dm_tipo_mov||').';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                , est_log_generico_ciap  => est_log_generico_ciap );
            --
         end if;
         --
      end loop;
      --
      vn_fase := 4;
      -- Busca Período da Apuração do CIAP
      begin
         --
         select ciap.dt_ini
              , ciap.dt_fin
           into vd_dt_ini
              , vd_dt_fin
           from icms_atperm_ciap ciap
          where ciap.id = en_icmsatpermciap_id;
         --
      exception
         when others then
            vd_dt_ini := null;
            vd_dt_fin := null;
      end;
      --
      vn_fase := 5;
      --
      for rec2 in c_mov_atperm loop
         exit when c_mov_atperm%notfound or (c_mov_atperm%notfound) is null;
         --
         vn_fase := 6;
         --
         -- Busca o código do bem ou componente imobilizado
         vv_cod_ind_bem := pk_csf_ciap.fkg_bemativoimob_cd ( en_bemativoimob_id => rec2.bemativoimob_id);
         --
         -- Se o Tipo de Movimento for SI a data deve ser igual a data inicial da Apuração do Ciap (G110)
         if trim(rec2.dm_tipo_mov) = 'SI'
            and rec2.dt_mov <> vd_dt_ini then
            --
            vn_fase := 6.1;
            --
            gv_mensagem_log := 'O "Bem ou Componente" (Código: '||vv_cod_ind_bem||') deve ter a "Data de Movimentação" ('||rec2.dt_mov||') igual a "Data '||
                               'Inicial do Apuração do CIAP" ('||vd_dt_ini||') para os movimentos do tipo SI.';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                , est_log_generico_ciap  => est_log_generico_ciap );
            --
         end if;
         --
         vn_fase := 7;
         --
         -- Se o Tipo de Movimento for “IA”, “IM”, “CI”, “MC”, “BA”, “AT”, “PE” ou “OT”
         -- a data deve ser menor ou igual a data final da Apuração do Ciap (G110)
         if trim(rec2.dm_tipo_mov) in ('IA', 'IM', 'CI', 'MC', 'BA', 'AT', 'PE', 'OT')
            and rec2.dt_mov > vd_dt_fin then
            --
            vn_fase := 7.1;
            --
            gv_mensagem_log := 'O "Bem ou Componente" (Código: '||vv_cod_ind_bem||') deve ter a "Data de Movimentação" ('||rec2.dt_mov||') menor ou igual '||
                               'a "Data Final do Apuração do CIAP" ('||vd_dt_ini||') para os movimentos do tipo IA, IM, CI, MC, BA, AT, PE ou OT.';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                , est_log_generico_ciap  => est_log_generico_ciap );
            --
         end if;
         --
         vn_fase := 8;
         --
         -- Para o Bem que entrar no estabelecimento no período da apuração seu tipo de movimentação deverá ser IM
         if nvl(rec2.num_parc, 0)  = 1
            and pk_csf_ciap.fkg_bemativoimob_ind ( en_bemativoimob_id => rec2.bemativoimob_id ) = 1
            and rec2.dm_tipo_mov not in ('IM', 'CI') then
            --
            vn_fase := 8.1;
            --
            gv_mensagem_log := 'O "Tipo de Movimento" ('||rec2.dm_tipo_mov||') deve ser igual a IM quando o "Bem Imobilizado" (Código: '||vv_cod_ind_bem||
                               ') entrar no estabelecimento.';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                , est_log_generico_ciap  => est_log_generico_ciap );
            --
         end if;
         --
         vn_fase := 9;
         -- Veririfica ocorrência de registros na Baixa do Bem ou Componente após apropriação de todas as parcelas.
         if nvl(rec2.num_parc, 0) = pk_csf_ciap.fkg_bemativoimob_par ( en_bemativoimob_id => rec2.bemativoimob_id )
            and rec2.dm_tipo_mov = 'SI' then
            --
            vn_fase := 9.1;
            -- Verifica qtde de tipos de movimento no período quando for apropriação da última parcela
            if pk_csf_ciap.fkg_movatperm_qtde ( en_icmsatpermciap_id => en_icmsatpermciap_id
                                              , en_bemativoimob_id => rec2.bemativoimob_id) <> 2 then
               --
               vn_fase := 9.2;
               --
               gv_mensagem_log := 'O "Componente Imobilizado" (Código: '||vv_cod_ind_bem||') deve ter apenas dois tipos de movimentos para registrar sua '||
                                  'Baixa da Apuração do CIAP.';
               --
               vn_loggenerico_id := null;
               --
               pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                                , ev_mensagem        => gv_cabec_log
                                , ev_resumo          => gv_mensagem_log
                                , en_tipo_log        => ERRO_DE_VALIDACAO
                                , en_referencia_id   => gn_referencia_id
                                , ev_obj_referencia  => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                   , est_log_generico_ciap  => est_log_generico_ciap );
               --
            end if;
            --
            vn_fase := 9.3;
            --
            -- Verifica se o movimento de baixa durante apropriação da última parcela.
            if pk_csf_ciap.fkg_existe_mov_ciap ( en_icmsatpermciap_id => en_icmsatpermciap_id
                                               ,   en_bemativoimob_id => rec2.bemativoimob_id
                                               ,       ev_dm_tipo_mov => 'BA' ) = 0 then
               --
               vn_fase := 9.4;
               --
               gv_mensagem_log := 'Não existe "Tipo de Movimento" de BA para o "Bem ou Componente Imobilizado" (Código: '||vv_cod_ind_bem||').';
               --
               vn_loggenerico_id := null;
               --
               pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                                , ev_mensagem        => gv_cabec_log
                                , ev_resumo          => gv_mensagem_log
                                , en_tipo_log        => ERRO_DE_VALIDACAO
                                , en_referencia_id   => gn_referencia_id
                               , ev_obj_referencia  => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                   , est_log_generico_ciap  => est_log_generico_ciap );
               --
            end if;
            --
         end if;
         --
         vn_fase := 10;
         -- Se o tipo de movimento for BA, AT, PE ou OT não poderá haver valor nos campos: VL_IMOB_ICMS_OP, VL_IMOB_ICMS_ST, VL_IMOB_ICMS_FRT,
         -- VL_IMOB_ICMS_DIF, NUM_PARC e VL_PARC_PASS
         if trim(rec2.dm_tipo_mov) in ('BA', 'AT', 'PE', 'OT') then
            --
            vn_fase := 10.1;
            --
            if nvl(rec2.vl_imob_icms_op, 0) > 0 then
               --
               vn_fase := 10.2;
               --
               gv_mensagem_log := 'O "Bem ou Componente" (Código: '||vv_cod_ind_bem||') não deve informar "Valor do ICMS da Oper. Própria" ('||
                                  rec2.vl_imob_icms_op||') para o Tipo de Movimento ('||rec2.dm_tipo_mov||').';
               --
               vn_loggenerico_id := null;
               --
               pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                                , ev_mensagem        => gv_cabec_log
                                , ev_resumo          => gv_mensagem_log
                                , en_tipo_log        => ERRO_DE_VALIDACAO
                                , en_referencia_id   => gn_referencia_id
                                , ev_obj_referencia  => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                   , est_log_generico_ciap  => est_log_generico_ciap );
            end if;
            --
            vn_fase := 10.3;
            --
            if nvl(rec2.vl_imob_icms_st, 0) > 0 then
               --
               vn_fase := 10.4;
               --
               gv_mensagem_log := 'O "Bem ou Componente" (Código: '||vv_cod_ind_bem||') não deve informar "Valor do ICMS da Oper. por Sub. Tributária" ('||
                                  rec2.vl_imob_icms_st||') para o Tipo de Movimento ('||rec2.dm_tipo_mov||').';
               --
               vn_loggenerico_id := null;
               --
               pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                                , ev_mensagem        => gv_cabec_log
                                , ev_resumo          => gv_mensagem_log
                                , en_tipo_log        => ERRO_DE_VALIDACAO
                                , en_referencia_id   => gn_referencia_id
                                , ev_obj_referencia  => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                   , est_log_generico_ciap  => est_log_generico_ciap );
               --
            end if;
            --
            vn_fase := 10.5;
            --
            if nvl(rec2.vl_imob_icms_frt, 0) > 0 then
               --
               vn_fase := 10.6;
               --
               gv_mensagem_log := 'O "Bem ou Componente" (Código: '||vv_cod_ind_bem||') não deve informar "Valor do ICMS da Oper. sobre Frete de Conhec. '||
                                  'Transp." ('||rec2.vl_imob_icms_st||') para o Tipo de Movimento ('||rec2.dm_tipo_mov||').';
               --
               vn_loggenerico_id := null;
               --
               pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                                , ev_mensagem        => gv_cabec_log
                                , ev_resumo          => gv_mensagem_log
                                , en_tipo_log        => ERRO_DE_VALIDACAO
                                , en_referencia_id   => gn_referencia_id
                                , ev_obj_referencia  => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                   , est_log_generico_ciap  => est_log_generico_ciap );
               --
            end if;
            --
            vn_fase := 10.7;
            --
            if nvl(rec2.vl_imob_icms_dif, 0) > 0 then
               --
               vn_fase := 10.8;
               --
               gv_mensagem_log := 'O "Bem ou Componente" (Código: '||vv_cod_ind_bem||') não deve informar "Valor do ICMS - Dif. de Aliq. conforme Doc. de '||
                                  'Arrecadação" ('||rec2.vl_imob_icms_dif||') para o Tipo de Movimento ('||rec2.dm_tipo_mov||').';
               --
               vn_loggenerico_id := null;
               --
               pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                                , ev_mensagem        => gv_cabec_log
                                , ev_resumo          => gv_mensagem_log
                                , en_tipo_log        => ERRO_DE_VALIDACAO
                                , en_referencia_id   => gn_referencia_id
                                , ev_obj_referencia  => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                   , est_log_generico_ciap  => est_log_generico_ciap );
               --
            end if;
            --
            vn_fase := 10.9;
            --
            if nvl(rec2.num_parc, 0) > 0 then
               --
               vn_fase := 10.10;
               --
               gv_mensagem_log := 'O "Bem ou Componente" (Código: '||vv_cod_ind_bem||') não deve informar o "Número da Parcela" ('||rec2.num_parc||
                                  ') para o Tipo de Movimento ('||rec2.dm_tipo_mov||').';
               --
               vn_loggenerico_id := null;
               --
               pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                                , ev_mensagem        => gv_cabec_log
                                , ev_resumo          => gv_mensagem_log
                                , en_tipo_log        => ERRO_DE_VALIDACAO
                                , en_referencia_id   => gn_referencia_id
                                , ev_obj_referencia  => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                   , est_log_generico_ciap  => est_log_generico_ciap );
               --
            end if;
            --
            vn_fase := 10.11;
            --
            if nvl(rec2.vl_parc_pass, 0) > 0 then
               --
               vn_fase := 10.12;
               --
               gv_mensagem_log := 'O "Bem ou Componente" (Código: '||vv_cod_ind_bem||') '||' não deve informar o "Valor da Parcela" ('||rec2.vl_parc_pass||
                                  ') para o Tipo de Movimento ('||rec2.dm_tipo_mov||').';
               --
               vn_loggenerico_id := null;
               --
               pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                                , ev_mensagem        => gv_cabec_log
                                , ev_resumo          => gv_mensagem_log
                                , en_tipo_log        => ERRO_DE_VALIDACAO
                                , en_referencia_id   => gn_referencia_id
                                , ev_obj_referencia  => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                   , est_log_generico_ciap  => est_log_generico_ciap );
               --
            end if;
            --
         end if;
         --
         vn_fase := 11;
         -- Verifica a ocorrência de registros quando ha saída do bem ou compomente
         -- sem terminar a apropriação devem ser informados dois registros
         if trim(rec2.dm_tipo_mov) in ('AT', 'PE', 'OT') then
            --
            vn_fase := 11.1;
            --
            if pk_csf_ciap.fkg_movatperm_qtde ( en_icmsatpermciap_id => en_icmsatpermciap_id
                                              , en_bemativoimob_id => rec2.bemativoimob_id) <> 2 then
               --
               vn_fase := 11.2;
               --
               gv_mensagem_log := 'O "Bem ou Componente Imobilizado" (Código: '||vv_cod_ind_bem||') deve ter apenas dois tipos de movimentos para registrar '||
                                  'sua Saída da Apuração do Ciap.';
               --
               vn_loggenerico_id := null;
               --
               pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                                , ev_mensagem        => gv_cabec_log
                                , ev_resumo          => gv_mensagem_log
                                , en_tipo_log        => ERRO_DE_VALIDACAO
                                , en_referencia_id   => gn_referencia_id
                                , ev_obj_referencia  => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                   , est_log_generico_ciap  => est_log_generico_ciap );
               --
            end if;
            --
            vn_fase := 11.3;
            --
            -- Verifica a existencia se o movimento de SI durante a Saída da Apuração do Ciap
            if pk_csf_ciap.fkg_existe_mov_ciap ( en_icmsatpermciap_id => en_icmsatpermciap_id
                                               ,   en_bemativoimob_id => rec2.bemativoimob_id
                                               ,       ev_dm_tipo_mov => 'SI' ) = 0 then
               --
               vn_fase := 11.4;
               --
               gv_mensagem_log := 'Não existe "Tipo de Movimento" de SI para o "Bem ou Componente Imobilizado" (Código: '||vv_cod_ind_bem||').';
               --
               vn_loggenerico_id := null;
               --
               pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                                , ev_mensagem        => gv_cabec_log
                                , ev_resumo          => gv_mensagem_log
                                , en_tipo_log        => ERRO_DE_VALIDACAO
                                , en_referencia_id   => gn_referencia_id
                                , ev_obj_referencia  => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                   , est_log_generico_ciap  => est_log_generico_ciap );
               --
            end if;
            --
         end if;
         --
         vn_fase := 12;
         -- Se o tipo de movimento estiver entre SI, IM, IA, CI ou MC pelo menos um dos campos: VL_IMOB_ICMS_OP,
         -- VL_IMOB_ICMS_ST, VL_IMOB_ICMS_FRT ou VL_IMOB_ICMS_DIF devem ser informados.
         if trim(rec2.dm_tipo_mov) in ('SI', 'IM', 'IA', 'CI', 'MC')
            and nvl(rec2.vl_imob_icms_op, 0) = 0
            and nvl(rec2.vl_imob_icms_st, 0) = 0
            and nvl(rec2.vl_imob_icms_frt, 0) = 0
            and nvl(rec2.vl_imob_icms_dif, 0) = 0  then
            --
            vn_fase := 12.1;
            --
            gv_mensagem_log := 'Se o "Bem ou Componente Imobilizado" (Código: '||vv_cod_ind_bem||' for do "Tipo de Movimento '||rec2.dm_tipo_mov||' deverá '||
                               'ser maior que zero pelo menos um dos valores de Oper. Própria, Oper. por Sub. Tributária, Frete sobre Conhec. Transp. ou Vlr. '||
                               'de ICMS sobre diferencial de Aliq.';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                , est_log_generico_ciap  => est_log_generico_ciap );
            --
         end if;
         --
         vn_fase := 13;
         -- O número da parcela é obrigatório se o valor da parcela for informado
         if nvl(rec2.num_parc, 0) = 0
            and nvl(rec2.vl_parc_pass, 0) > 0  then
            --
            vn_fase := 13.1;
            --
            gv_mensagem_log := 'O "Número da Parcela" ('||rec2.num_parc||') deverá ser informado quando o "Valor da Parcela" ('||rec2.vl_parc_pass||
                               ') for maior que zero para o "Bem ou Componente" (Código: '||vv_cod_ind_bem||').';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                , est_log_generico_ciap  => est_log_generico_ciap );
            --
         end if;
         --
         vn_fase := 14;
         -- O Valor da parcela é obrigatório se o número da parcela for informada
         if nvl(rec2.num_parc, 0) > 0
            and nvl(rec2.vl_parc_pass, 0) = 0  then
            --
            vn_fase := 14.1;
            --
            gv_mensagem_log := 'O "Valor da Parcela" ('||rec2.vl_parc_pass||') deverá ser informado quando o "Número da Parcela" ('||rec2.num_parc||
                               ') for maior que zero para o "Bem ou Componente" (Código: '||vv_cod_ind_bem||').';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                , est_log_generico_ciap  => est_log_generico_ciap );
            --
         end if;
         -- Busca o número de parcelas que consta no cadastro do produto.
         Begin
            select nr_parc
              into vn_nr_parc_bem
              from bem_ativo_imob b
             where b.id = rec2.bemativoimob_id;
         exception
            when others then
               vn_nr_parc_bem := 0;
         end;
         --
         vn_fase := 14.2;
         -- O número das parcelas de icms não pode 
         -- ultrapassar o número de parcelas fornecidos no cadastro do bem
         if nvl(rec2.num_parc, 0) >  nvl(vn_nr_parc_bem, 0) then
            --
            vn_fase := 14.3;
            --
            gv_mensagem_log := 'O "Número da Parcela" ('||rec2.num_parc||') não pode ser maior que o valor informado no cadastro do Bem ou Componente (Código: '||
                                vv_cod_ind_bem||').';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                , est_log_generico_ciap  => est_log_generico_ciap );
            --
         end if;
         --
         vn_fase := 15;
         -- O Valor da parcela de ser igual ou menor que o somatório dos campos VL_IMOB_ICMS_OP, VL_IMOB_ICMS_ST,
         -- VL_IMOB_ICMS_FRT, VL_IMOB_ICMS_DIF dividido pelo numeros de parcelas a serem apropriadas no CIAP.
         if nvl(rec2.vl_parc_pass, 0) > 0  then
            --
            vn_fase := 15.1;
            --
            vn_parcela := 0;
            --
            begin
               --
               select round( ( nvl(a.vl_imob_icms_op, 0)
                             + nvl(a.vl_imob_icms_st, 0)
                             + nvl(a.vl_imob_icms_frt, 0)
                             + nvl(a.vl_imob_icms_dif, 0) )
                             / decode(b.nr_parc, 0, 1, b.nr_parc), 2
                           ) parcela
                 into vn_parcela
                 from mov_atperm a,
                      bem_ativo_imob b
                where a.id = rec2.id
                  and a.bemativoimob_id = b.id;
               --
            exception
               when others then
                  vn_parcela := 0;
            end;
            --
            vn_fase := 15.2;
            --
            vn_dif := nvl(vn_parcela,0) - nvl(rec2.vl_parc_pass, 0);
            --
            if vn_parcela < nvl(rec2.vl_parc_pass, 0)
               and ( nvl(vn_dif,0) < -0.10 or nvl(vn_dif,0) > 0.10 )
               then
               --
               vn_fase := 15.3;
               --
               gv_mensagem_log := 'O "Valor da Parcela" ('||rec2.vl_parc_pass||') deverá ser menor ou igual a soma do ICMS de "Operações Próprias", "Operações '||
                                  'por Sub. Tributária", "Frete sobre Conhec. Transp." e "ICMS por Diferencial de Alíq" dividido pelo total de parcela em que '||
                                  'o "Bem ou Componente" pode ser apropriado (Valor calculado = '||vn_parcela||'), Código do Bem: '||vv_cod_ind_bem||'.';
               --
               vn_loggenerico_id := null;
               --
               pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                                , ev_mensagem        => gv_cabec_log
                                , ev_resumo          => gv_mensagem_log
                                , en_tipo_log        => ERRO_DE_VALIDACAO
                                , en_referencia_id   => gn_referencia_id
                                , ev_obj_referencia  => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                   , est_log_generico_ciap  => est_log_generico_ciap );
               --
            end if;
         --
         end if;
       --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_valida_mov_atperm fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ciap.id%TYPE;
      begin
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                             , est_log_generico_ciap  => est_log_generico_ciap );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_valida_mov_atperm;
-----------------------------------------
--| Válida informação dos totais do ciap
-----------------------------------------
procedure pkb_valida_icmsatpermciap_id ( est_log_generico_ciap     in out nocopy  dbms_sql.number_table
                                       , en_icmsatpermciap_id in             icms_atperm_ciap.Id%TYPE
                                       ) is
   --
   vn_fase                    number := 0;
   vn_loggenerico_id          log_generico_ciap.id%type;
   vn_qtde_icms_atperm_ciap   number := 0;
   vn_saldo_inicial           number := 0;
   vn_vl_parc_pass            mov_atperm.vl_parc_pass%type := 0;
   vn_vl_som_icms_oc          outro_cred_ciap.vl_parc_aprop%type := 0;
   vn_ind_per_sai             icms_atperm_ciap.ind_per_sai%type := 0;
   vn_dif                     number := 0;
   --
   cursor c_Icms_Atperm_Ciap is
   select cp.*
     from Icms_Atperm_Ciap cp
    where cp.id = en_icmsatpermciap_id;
   --
Begin
   --
   vn_fase := 1;
   --
   if nvl(en_icmsatpermciap_id,0) > 0 then
      --
      vn_fase := 1.1;
      -- valida a quantidade de "Informações dos Totais do Ciap", que deve ser igual a "1"
      begin
         --
         select count(1)
           into vn_qtde_icms_atperm_ciap
           from icms_atperm_ciap ciap
          where ciap.id = en_icmsatpermciap_id;
         --
      exception
         when others then
            vn_qtde_icms_atperm_ciap := 0;
      end;
      --
      vn_fase := 1.2;
      --
      if nvl(vn_qtde_icms_atperm_ciap,0) > 1 then
         --
         vn_fase := 1.3;
         --
         gv_mensagem_log := 'Foi informado mais de um registro de "Informações dos Totais do Ciap".';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_VALIDACAO
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                             , est_log_generico_ciap  => est_log_generico_ciap );
         --
      end if;
      --
      vn_fase := 2;
      --
      for rec in c_Icms_Atperm_Ciap loop
         exit when c_Icms_Atperm_Ciap%notfound or (c_Icms_Atperm_Ciap%notfound) is null;
         --
         vn_fase := 3;
         --
         begin
            --
            select sum(nvl(m.vl_imob_icms_op, 0)) +
                   sum(nvl(m.vl_imob_icms_st, 0)) +
                   sum(nvl(m.vl_imob_icms_frt, 0)) +
                   sum(nvl(m.vl_imob_icms_dif, 0)) soma
              into vn_saldo_inicial
              from mov_atperm m
             where m.dm_tipo_mov = 'SI'
               and m.icmsatpermciap_id =  en_icmsatpermciap_id;
            --
         exception
            when others then
               vn_saldo_inicial := 0;
         end;
         --
         vn_fase := 3.1;
         --
         -- Compara se o saldo inicial do icms é igual a soma de credito no movimento
         if nvl(vn_saldo_inicial,0) <> nvl(rec.vl_saldo_in_icms,0) then
            --
            vn_fase := 3.2;
            --
            gv_mensagem_log := 'O "Saldo inicial de ICMS do CIAP" ('||rec.vl_saldo_in_icms||') deve ser composto pelo somatório de crédito ('||
                               vn_saldo_inicial||') de ICMS de Ativo Imobilizado de bens ou componentes.';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                , est_log_generico_ciap  => est_log_generico_ciap );
            --
         end if;
         --
         vn_fase := 4;
         --
         begin
            --
            select sum(nvl(m.vl_parc_pass, 0))
              into vn_vl_parc_pass
              from mov_atperm m
             where m.icmsatpermciap_id = en_icmsatpermciap_id;
            --
         exception
            when others then
               vn_vl_parc_pass := 0;
         end;
         --
         vn_fase := 4.1;
         --
         vn_dif := nvl(vn_vl_parc_pass,0) - nvl(rec.vl_som_parc,0);
         --
         -- Compara a soma das parcelas no movimento com o informado no total do ciap
         if nvl(vn_vl_parc_pass,0) <> nvl(rec.vl_som_parc,0)
            and ( nvl(vn_dif,0) < -0.10 or nvl(vn_dif,0) > 0.10 )
            then
            --
            vn_fase := 4.2;
            --
            gv_mensagem_log := 'A "Somatória das parcelas de ICMS passível de apropriação" ('||rec.vl_som_parc||') deve corresponder a somatória de todas '||
                               'as parcelas informadas ('||vn_vl_parc_pass||') na movimentação do bem ou componente.';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                , est_log_generico_ciap  => est_log_generico_ciap );
            --
         end if;
         --
         vn_fase := 5;
         -- O campo VL_TRIB_EXP deve ser menor ou igual ao campo VL_TOTAL
         if nvl(rec.vl_trib_exp,0) > nvl(rec.vl_total,0) then
            --
            vn_fase := 5.1;
            --
            gv_mensagem_log := 'O "Valor do somatório das saídas tributadas e saídas para exportação" ('||rec.vl_trib_exp||') deve ser menor ou igual ao '||
                               'Valor total de saídas ('||rec.vl_total||').';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                , est_log_generico_ciap  => est_log_generico_ciap );
            --
         end if;
         --
         vn_fase := 6;
         --
         -- O Percentual não pode negativo (dá erro no validador) e deve ser sempre menor ou igual a 1
         if rec.ind_per_sai not between 0 and 1 then
            --
            vn_fase := 6.1;
            --
            gv_mensagem_log := 'O "Índice de participação do valor do somatório das saídas tributadas e saídas para exportação no valor total de saídas" ('||
                               rec.ind_per_sai||') deve ser sempre igual ou menor que 1(um).';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                , est_log_generico_ciap  => est_log_generico_ciap );
            --
         end if;
         --
         vn_fase := 7;
         --
         vn_ind_per_sai := pk_csf_ciap.fkg_ind_per_sai_calc( en_icmsatpermciap_id => en_icmsatpermciap_id );
         --
         --  Verifica se o índice de participação é igual a divisão entre o vl_trib_exp com vl_total
         if vn_ind_per_sai <> rec.ind_per_sai then
            --
            vn_fase := 7.1;
            --
            gv_mensagem_log := 'O "Índice de Participação" ('||rec.ind_per_sai||') deve correspondente ao resultado da divisão das "Saídas Tributadas e '||
                               'Saídas para Exportação" ('||rec.vl_trib_exp||') pelo "Vlr Total de Saídas" ('||rec.vl_total||').';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                , est_log_generico_ciap  => est_log_generico_ciap );
            --
         end if;
         --
         vn_fase := 8;
         -- O valor do campo VL_ICMS_APROP deve ser igual a VL_SOM_PARC multiplicado pelo IND_PER_SAI
         if rec.vl_icms_aprop <> round(rec.vl_som_parc * rec.ind_per_sai, 2) then
            --
            vn_fase := 8.1;
            --
            gv_mensagem_log := 'O "Valor de ICMS a ser apropriado na apuração do ICMS" ('||rec.vl_icms_aprop||') deve corresponder á multiplicação do '||
                               '"Somatório das parcelas de ICMS passível de apropriação" ('||rec.vl_som_parc||') com o "Indíce de Participação" ('||
                               rec.ind_per_sai||').';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                , est_log_generico_ciap  => est_log_generico_ciap );
            --
         end if;
         --
         vn_fase := 9;
         --
         begin
            --
            select sum(o.vl_parc_aprop)
              into vn_vl_som_icms_oc
              from mov_atperm m,
                   outro_cred_ciap o
             where m.icmsatpermciap_id = en_icmsatpermciap_id
               and m.id = o.movatperm_id;
            --
         exception
            when others then
               vn_vl_som_icms_oc := 0;
         end;
         --
         vn_fase := 9.1;
         --
         vn_dif := nvl(vn_vl_som_icms_oc, 0) - nvl(rec.vl_som_icms_oc,0);
         --
         -- O valor do campo VL_SOM_ICMS_OC deve ser igual a soma VL_PARC_APROP em outros creditos de ICMS.
         if nvl(vn_vl_som_icms_oc, 0) <> rec.vl_som_icms_oc
            and ( nvl(vn_dif,0) < -0.10 or nvl(vn_dif,0) > 0.10 )
            then
            --
            vn_fase := 9.2;
            --
            gv_mensagem_log := 'O "Valor de outros créditos a ser apropriado" ('||rec.vl_som_icms_oc||') deve corresponder a "Somatória das parcelas a ser '||
                               'apropriada de Outros Créditos do CIAP" ('||vn_vl_som_icms_oc||').';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                , est_log_generico_ciap  => est_log_generico_ciap );
            --
         end if;
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_valida_icmsatpermciap_id fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ciap.id%TYPE;
      begin
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                             , est_log_generico_ciap  => est_log_generico_ciap );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_valida_icmsatpermciap_id;
--------------------------------------------
--| Procedure que consiste os dados do CIAP
--------------------------------------------
procedure pkb_consistem_ciap ( est_log_generico_ciap     in out nocopy  dbms_sql.number_table
                             , en_icmsatpermciap_id in             Icms_Atperm_Ciap.id%TYPE
                             ) is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ciap.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(est_log_generico_ciap.count,0) = 0 then
      --
      vn_fase := 2;
      -- Válida informação dos totais do ciap
      pkb_valida_icmsatpermciap_id ( est_log_generico_ciap      => est_log_generico_ciap
                                   , en_icmsatpermciap_id  => en_icmsatpermciap_id );
      --
      vn_fase := 3;
      -- Válida informação sobre os movimentos no ciap
      pkb_valida_mov_atperm ( est_log_generico_ciap      => est_log_generico_ciap
                            , en_icmsatpermciap_id  => en_icmsatpermciap_id );
      --
      vn_fase := 4;
     -- Válida informação sobre os outros creditos no ciap
      pkb_valida_outro_cred_ciap ( est_log_generico_ciap      => est_log_generico_ciap
                                 , en_icmsatpermciap_id  => en_icmsatpermciap_id );
      --
      vn_fase := 5;
      -- Válida informação sobre as notas fiscais dos bens que compõe o ciap
      pkb_valida_mov_atperm_dc ( est_log_generico_ciap      => est_log_generico_ciap
                               , en_icmsatpermciap_id  => en_icmsatpermciap_id );
      --
      vn_fase := 6;
      -- Válida informação sobre as itens das notas fiscais dos bens que compõe o ciap
      pkb_valida_mov_atperm_itemdc ( est_log_generico_ciap      => est_log_generico_ciap
                                   , en_icmsatpermciap_id  => en_icmsatpermciap_id );
      --
      vn_fase := 7;
      -- Valida os bens ou compononentes que compoê o ciap
      pkb_valida_bem_ativo_imob ( est_log_generico_ciap     => est_log_generico_ciap
                                , en_icmsatpermciap_id => en_icmsatpermciap_id );
      --
      vn_fase := 8;
      -- Valida se as notas fiscais vinculadas ao ciap estão integradas e autorizadas
      pkb_valida_ciap_nf ( est_log_generico_ciap     => est_log_generico_ciap
                         , en_icmsatpermciap_id => en_icmsatpermciap_id );
      --
   end if;
   --
   vn_fase := 9;
   --
   if nvl(est_log_generico_ciap.count,0) > 0 then
      --
      update icms_atperm_ciap ia
         set ia.dm_st_proc = 2
       where ia.id = en_icmsatpermciap_id;
      --
   end if;
   --
   vn_fase := 10;
   -- Se não contém erro de validação, Grava o Log de Ciap Integrada
   gv_mensagem_log := 'Ciap integrado.';
   --
   if nvl(est_log_generico_ciap.count,0) = 0 then
      --
      gv_mensagem_log := gv_mensagem_log || ' Ciap validado.';
      --
   end if;
   --
   vn_fase := 11;
   --
   pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                    , ev_mensagem        => gv_cabec_log
                    , ev_resumo          => gv_mensagem_log
                    , en_tipo_log        => nota_fiscal_integrada
                    , en_referencia_id   => gn_referencia_id
                    , ev_obj_referencia  => gv_obj_referencia );
   --
exception
   when others then
      --
      rollback;
      --
      gv_mensagem_log := 'Erro na pkb_consistem_ciap fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ciap.id%TYPE;
      begin
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                               , ev_mensagem        => gv_cabec_log
                               , ev_resumo          => gv_mensagem_log
                               , en_tipo_log        => ERRO_DE_SISTEMA
                               , en_referencia_id   => gn_referencia_id
                               , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ciap ( en_loggenericociap_id         => vn_loggenerico_id
                                  , est_log_generico_ciap  => est_log_generico_ciap );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_consistem_ciap;

-------------------------------------------------------------------------------------------------------

procedure pkb_ret_multorg_id( est_log_generico       in out nocopy  dbms_sql.number_table
                            , ev_cod_mult_org        in             mult_org.cd%type
                            , ev_hash_mult_org       in             mult_org.hash%type
                            , sn_multorg_id          in out nocopy  mult_org.id%type
                            , en_referencia_id       in             Log_Generico_ciap.referencia_id%TYPE  default null
                            , ev_obj_referencia      in             Log_Generico_ciap.obj_referencia%TYPE default null
                            )
is
   vn_fase               number := 0;
   vv_multorg_hash       mult_org.hash%type;
   vn_multorg_id         mult_org.id%type;
   vn_loggenerico_id     log_generico_ciap.id%type;
   vn_dm_obrig_integr    mult_org.dm_obrig_integr%type;

begin
   --
   vn_fase := 1;
   --
   gn_referencia_id   := en_referencia_id;
   gv_obj_referencia  := ev_obj_referencia;
   --
   begin
      --
      select mo.hash, mo.id, mo.dm_obrig_integr
        into vv_multorg_hash, vn_multorg_id, vn_dm_obrig_integr
        from mult_org mo
       where mo.cd = ev_cod_mult_org;
      --
      vn_fase := 2;
      --
   exception
      when no_data_found then
         --
         vn_fase := 3;
         --
         vv_multorg_hash := null;
         --
         vn_multorg_id := 0;
         --
      when others then
         --
         vn_fase := 4;
         --
         vv_multorg_hash := null;
         --
         vn_multorg_id := 0;
         --
         gv_mensagem_log := 'Problema ao tentar buscar o Mult Org. Fase: '||vn_fase;
         gv_cabec_log :=  'Codigo do MultOrg: |' || ev_cod_mult_org || '| Hash do MultOrg: |'||ev_hash_mult_org||'|';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_cabec_log
                              , en_tipo_log           => ERRO_DE_VALIDACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                 , est_log_generico_ciap  => est_log_generico );
   --
   end;
   --
   vn_fase := 5;
   --
   if nvl(vn_multorg_id, 0) = 0 then

      gv_mensagem_log := 'O Mult Org de codigo: |' || ev_cod_mult_org || '| não existe.';
      --
      vn_loggenerico_id := null;
      --
      vn_fase := 5.1;
      --
      if vn_dm_obrig_integr = 0 then -- Não validar o multorg.
         --
         vn_fase := 5.2;
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                               , ev_mensagem            => gv_mensagem_log
                               , ev_resumo              => gv_mensagem_log
                               , en_tipo_log            => INFORMACAO
                               , en_referencia_id       => gn_referencia_id
                               , ev_obj_referencia      => gv_obj_referencia
                               );
         --
      elsif vn_dm_obrig_integr = 1 then -- Validar o multorg.
         --
         vn_fase := 5.3;
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                               , ev_mensagem            => gv_mensagem_log
                               , ev_resumo              => gv_mensagem_log
                               , en_tipo_log            => ERRO_DE_VALIDACAO
                               , en_referencia_id       => gn_referencia_id
                               , ev_obj_referencia      => gv_obj_referencia
                               );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                 , est_log_generico_ciap  => est_log_generico );
         --
      end if;
      --
   elsif vv_multorg_hash != ev_hash_mult_org then
      --
      vn_fase := 6;
      --
      gv_mensagem_log := 'O valor do Hash ('|| ev_hash_mult_org ||') do Mult Org:'|| ev_cod_mult_org ||'esta incorreto.';
      --
      vn_loggenerico_id := null;
      --
      if vn_dm_obrig_integr = 0 then -- Não validar o multorg.
         --
         vn_fase := 6.1;
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                               , ev_mensagem            => gv_mensagem_log
                               , ev_resumo              => gv_mensagem_log
                               , en_tipo_log            => INFORMACAO
                               , en_referencia_id       => gn_referencia_id
                               , ev_obj_referencia      => gv_obj_referencia
                               );
         --
      elsif vn_dm_obrig_integr = 1 then -- Validar o multorg.
         --
         vn_fase := 6.2;
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                               , ev_mensagem            => gv_mensagem_log
                               , ev_resumo              => gv_mensagem_log
                               , en_tipo_log            => ERRO_DE_VALIDACAO
                               , en_referencia_id       => gn_referencia_id
                               , ev_obj_referencia      => gv_obj_referencia
                               );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                 , est_log_generico_ciap  => est_log_generico );
         --
      end if;
      --
   end if;
   --
   vn_fase := 7;
   --
   sn_multorg_id := vn_multorg_id;

exception
   when others then
      raise_application_error (-20101, 'Problemas ao validar Mult Org - pk_csf_api.pkb_ret_multorg_id. Fase: '||vn_fase||' Erro = '||sqlerrm);
end pkb_ret_multorg_id;

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
                                )


is
   --
   vn_fase                number := 0;
   vn_loggenerico_id   log_generico_ciap.id%type;
   vv_mensagem            varchar2(1000) := null;
   vn_dmtipocampo         ff_obj_util_integr.dm_tipo_campo%type;
   vv_hash_mult_org     mult_org.hash%type;
   vv_cod_mult_org      mult_org.cd%type;
  --
begin
 --
   vn_fase := 1;
   --
   gv_mensagem_log := null;
   --
   gn_referencia_id  := en_referencia_id;
   gv_obj_referencia := ev_obj_referencia;
   --
   vn_fase := 2;
   --
   if trim(ev_valor) is null then
      --
      vn_fase := 3;
      --
      gv_mensagem_log := '"Código ou HASH da Mult-Organização (objeto: '|| ev_obj_name ||'): "VALOR" referente ao atributo deve ser informado.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                           , ev_mensagem        => gv_mensagem_log
                           , ev_resumo          => gv_cabec_log
                           , en_tipo_log        => ERRO_DE_VALIDACAO
                           , en_referencia_id   => gn_referencia_id
                           , ev_obj_referencia  => gv_obj_referencia );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                              , est_log_generico_ciap  => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   --
   vv_mensagem := pk_csf.fkg_ff_verif_campos( ev_obj_name => ev_obj_name
                                            , ev_atributo => trim(ev_atributo)
                                            , ev_valor    => trim(ev_valor) );
   --
   vn_fase := 5;
   --
   if vv_mensagem is not null then
      --
      vn_fase := 6;
      --
      gv_mensagem_log := vv_mensagem;
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                           , ev_mensagem        => gv_mensagem_log
                           , ev_resumo          => gv_cabec_log
                           , en_tipo_log        => ERRO_DE_VALIDACAO
                           , en_referencia_id   => gn_referencia_id
                           , ev_obj_referencia  => gv_obj_referencia );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                              , est_log_generico_ciap  => est_log_generico );
      --
   else
       --
      vn_fase := 7;
      --
      vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo( ev_obj_name => ev_obj_name
                                                         , ev_atributo => trim(ev_atributo) );
      --
      vn_fase := 8;
      --
      if trim(ev_valor) is not null then
         --
         vn_fase := 9;
         --
         if vn_dmtipocampo = 2 then -- tipo de campo = 0-data, 1-numérico, 2-caractere
            --
            vn_fase := 10;
            --
            if trim(ev_atributo) = 'COD_MULT_ORG' then
                --
                vn_fase := 11;
                --
                begin
                   vv_cod_mult_org := pk_csf.fkg_ff_ret_vlr_caracter( ev_obj_name => ev_obj_name
                                                                    , ev_atributo => trim(ev_atributo)
                                                                    , ev_valor    => trim(ev_valor) );
                exception
                   when others then
                      vv_cod_mult_org := null;
                end;
                --
            elsif trim(ev_atributo) = 'HASH_MULT_ORG' then
               --
                vn_fase := 12;
                --
                begin
                   vv_hash_mult_org := pk_csf.fkg_ff_ret_vlr_caracter( ev_obj_name => ev_obj_name
                                                                     , ev_atributo => trim(ev_atributo)
                                                                     , ev_valor    => trim(ev_valor) );
                exception
                   when others then
                      vv_hash_mult_org := null;
                end;
                --
            end if;
            --
         else
            --
            vn_fase := 13;
            --
            gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado não confere com o tipo de campo, deveria ser CARACTERE.';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id => vn_loggenerico_id
                                , ev_mensagem       => gv_mensagem_log
                                , ev_resumo         => gv_cabec_log
                                , en_tipo_log       => ERRO_DE_VALIDACAO
                                , en_referencia_id  => gn_referencia_id
                                , ev_obj_referencia => gv_obj_referencia );
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id   => vn_loggenerico_id
                                   , est_log_generico_ciap => est_log_generico );
            --
         end if;
         --
      end if;
      --
   end if;
   --
   vn_fase := 14;
   --
   sv_cod_mult_org := vv_cod_mult_org;
   --
   sv_hash_mult_org := vv_hash_mult_org;
--
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api.pkb_val_atrib_multorg fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                              , ev_mensagem        => gv_mensagem_log
                              , ev_resumo          => gv_cabec_log
                              , en_tipo_log        => ERRO_DE_VALIDACAO
                              , en_referencia_id   => gn_referencia_id
                              , ev_obj_referencia  => gv_obj_referencia );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ciap ( en_loggenericociap_id    => vn_loggenerico_id
                                 , est_log_generico_ciap  => est_log_generico );
      exception
         when others then
            null;
      end;
end pkb_val_atrib_multorg;

-------------------------------------------------------------------------------------------------------

-- Integra as informacões do Documento Fiscal CIAP - campos flex field

procedure pkb_int_movatpermdocfiscal_ff ( est_log_generico_ciap     in out nocopy  dbms_sql.number_table
                                        , en_movatpermdocfiscal_id  in             mov_atperm_doc_fiscal.id%type
                                        , ev_atributo               in             varchar2
                                        , ev_valor                  in             varchar2
                                        , en_referencia_id          in             Log_Generico_ciap.referencia_id%TYPE  default null
                                        , ev_obj_referencia         in             Log_Generico_ciap.obj_referencia%TYPE default null
                                        )
is
   --
   vn_fase               number := 0;
   vn_loggenerico_id     log_generico_ciap.id%type;
   vv_mensagem           varchar2(1000) := null;
   vn_dmtipocampo        ff_obj_util_integr.dm_tipo_campo%type;
   vv_num_da             mov_atperm_doc_fiscal.num_da%type;
   vd_dt_mov             mov_atperm.dt_mov%type;
   --
begin
   --
   vn_fase := 1;
   --
   gv_mensagem_log := null;
   --
   gn_referencia_id  := en_referencia_id;
   gv_obj_referencia := ev_obj_referencia;
   --   
   vn_fase := 2;
   --
   begin
      --   
      select ma.dt_mov 
        into vd_dt_mov
        from mov_atperm_doc_fiscal mo  
           , mov_atperm            ma
       where mo.id = en_movatpermdocfiscal_id
         and ma.id = mo.movatperm_id;   
      --		 
   exception
      when others then
         vd_dt_mov := null;
   end;		 
   --   
   if ev_atributo is null then
      --
      vn_fase := 3;
      --
      gv_mensagem_log := 'Documentos Fiscais CIAP: "Atributo" deve ser informado.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                            , ev_mensagem            => gv_mensagem_log
                            , ev_resumo              => gv_cabec_log
                            , en_tipo_log            => erro_de_validacao
                            , en_referencia_id       => gn_referencia_id
                            , ev_obj_referencia      => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memoria
      pkb_gt_log_generico_ciap ( en_loggenericociap_id  => vn_loggenerico_id
                               , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 4;
   --
   if ev_valor is null then
      --
      vn_fase := 5;
      --
      gv_mensagem_log := 'Documentos Fiscais CIAP: "VALOR" referente ao atributo deve ser informado.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                            , ev_mensagem            => gv_mensagem_log
                            , ev_resumo              => gv_cabec_log
                            , en_tipo_log            => erro_de_validacao
                            , en_referencia_id       => gn_referencia_id
                            , ev_obj_referencia      => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memoria
      pkb_gt_log_generico_ciap ( en_loggenericociap_id  => vn_loggenerico_id
                               , est_log_generico_ciap  => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 6;
   --
   vv_mensagem := pk_csf.fkg_ff_verif_campos( ev_obj_name => 'VW_CSF_MOV_ATPERM_DOCFISCAL_FF'
                                            , ev_atributo => ev_atributo
                                            , ev_valor    => ev_valor );
   --
   vn_fase := 7;
   --
   if vv_mensagem is not null then
      --
      vn_fase := 8;
      --
      gv_mensagem_log := vv_mensagem;
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id  => vn_loggenerico_id
                            , ev_mensagem            => gv_mensagem_log
                            , ev_resumo              => gv_cabec_log
                            , en_tipo_log            => erro_de_validacao
                            , en_referencia_id       => gn_referencia_id
                            , ev_obj_referencia      => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memoria
      pkb_gt_log_generico_ciap ( en_loggenericociap_id  => vn_loggenerico_id
                               , est_log_generico_ciap  => est_log_generico_ciap );
      --
   else
      --
      vn_fase := 9;
      --
      vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo( ev_obj_name => 'VW_CSF_MOV_ATPERM_DOCFISCAL_FF'
                                                         , ev_atributo => ev_atributo );
      --
      vn_fase := 10;
      --
	  if vd_dt_mov >= to_date('01/01/2020','dd/mm/rrrr') then 
         --	  
         if ev_atributo = 'NUM_DA' and ev_valor is not null then
            --
            vn_fase := 11;
            --
            if vn_dmtipocampo = 2 then -- tipo de campo = caracter
               --
               vn_fase := 12;
               --
               vv_num_da := pk_csf.fkg_ff_ret_vlr_caracter ( ev_obj_name => 'VW_CSF_MOV_ATPERM_DOCFISCAL_FF'
                                                           , ev_atributo => ev_atributo
                                                           , ev_valor    => ev_valor
                                                           );			
               --
               vn_fase := 13;
               --
               if vv_num_da is null then
                  --
                  vn_fase := 14;
                  --
                  gv_mensagem_log := 'Número do documento de arrecadação estadual ('||vv_num_da||') e valor do atributo ('||
                                     ev_valor||'), não informados.';
                  --
                  vn_loggenerico_id := null;
                  --
                  pkb_log_generico_ciap ( sn_loggenericociap_id => vn_loggenerico_id
                                        , ev_mensagem           => gv_mensagem_log
                                        , ev_resumo             => gv_cabec_log
                                        , en_tipo_log           => ERRO_DE_VALIDACAO
                                        , en_referencia_id      => gn_referencia_id
                                        , ev_obj_referencia     => gv_obj_referencia );
                  -- Armazena o "loggenerico_id" na memória
                  pkb_gt_log_generico_ciap ( en_loggenericociap_id => vn_loggenerico_id
                                           , est_log_generico_ciap => est_log_generico_ciap );
                  --
               end if;
               --
            else
               --
               vn_fase := 15;
               --
               gv_mensagem_log := 'Para o atributo NUM_DA, o VALOR informado não confere com o tipo de campo, deveria ser CARACTERE.';
               --
               vn_loggenerico_id := null;
               --
               pkb_log_generico_ciap ( sn_loggenericociap_id => vn_loggenerico_id
                                     , ev_mensagem           => gv_mensagem_log
                                     , ev_resumo             => gv_cabec_log
                                     , en_tipo_log           => ERRO_DE_VALIDACAO
                                     , en_referencia_id      => gn_referencia_id
                                     , ev_obj_referencia     => gv_obj_referencia );
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_ciap ( en_loggenericociap_id => vn_loggenerico_id
                                        , est_log_generico_ciap => est_log_generico_ciap );
               --
            end if;
            --
         else
            --
            vn_fase := 16;
            --
            gv_mensagem_log := '"Atributo" ('||ev_atributo||') e "VALOR" ('||ev_valor||') relacionados, nâo especificados no processo.';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ciap ( sn_loggenericociap_id => vn_loggenerico_id
                                  , ev_mensagem           => gv_mensagem_log
                                  , ev_resumo             => gv_cabec_log
                                  , en_tipo_log           => ERRO_DE_VALIDACAO
                                  , en_referencia_id      => gn_referencia_id
                                  , ev_obj_referencia     => gv_obj_referencia );
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ciap ( en_loggenericociap_id => vn_loggenerico_id
                                     , est_log_generico_ciap => est_log_generico_ciap );
            --
         end if;
         --
      end if;
      --	  
   end if;
   --
   vn_fase := 17;
   --
   if nvl(en_movatpermdocfiscal_id,0) = 0 then
      --
      vn_fase := 18;
      --
      gv_mensagem_log := 'Identificador do Documento Fiscal - CIAP não informado para geração dos campos complementares (FF).';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ciap ( sn_loggenericociap_id => vn_loggenerico_id
                            , ev_mensagem           => gv_mensagem_log
                            , ev_resumo             => gv_cabec_log
                            , en_tipo_log           => ERRO_DE_VALIDACAO
                            , en_referencia_id      => gn_referencia_id
                            , ev_obj_referencia     => gv_obj_referencia );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ciap ( en_loggenericociap_id => vn_loggenerico_id
                               , est_log_generico_ciap => est_log_generico_ciap );
      --
   end if;
   --
   vn_fase := 99;
   --
   if vd_dt_mov >= to_date('01/01/2020','dd/mm/rrrr') then 
      --
      if  nvl(en_movatpermdocfiscal_id,0) > 0 and
      ev_atributo = 'NUM_DA'              and
      vv_num_da is not null               and
      gv_mensagem_log is null             then
      --
      vn_fase := 99.1;
      --
      update mov_atperm_doc_fiscal mo
         set mo.num_da = ev_valor
       where mo.id = en_movatpermdocfiscal_id; 
      --
   end if;
   end if;
   --
   vn_fase := 100;
   --
   <<sair_integr>>
   null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_int_movatpermdocfiscal_ff fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ciap.id%type;
      begin
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_ciap ( sn_loggenericociap_id => vn_loggenerico_id
                               , ev_mensagem           => gv_mensagem_log
                               , ev_resumo             => gv_cabec_log
                               , en_tipo_log           => ERRO_DE_VALIDACAO
                               , en_referencia_id      => gn_referencia_id
                               , ev_obj_referencia     => gv_obj_referencia );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ciap ( en_loggenericociap_id => vn_loggenerico_id
                                  , est_log_generico_ciap => est_log_generico_ciap );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_int_movatpermdocfiscal_ff;

-----------------------------------------------------------------------------------------------------

end pk_csf_api_ciap;
/
