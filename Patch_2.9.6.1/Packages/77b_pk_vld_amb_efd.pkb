create or replace package body csf_own.pk_vld_amb_efd is

-------------------------------------------------------------------------------------------------------
-- Corpo do pacote de procedimentos de criação do arquivo do sped fiscal
-------------------------------------------------------------------------------------------------------

--| Procedure inicia os parâmetros do Sped Fiscal
procedure pkb_inicia_param ( en_aberturaefd_id in abertura_efd.id%type )
is
begin
   --
   select a.*
     into pk_csf_api_efd.gt_row_abertura_efd
     from abertura_efd a
    where a.id = en_aberturaefd_id;
   --
exception
   when others then
      pk_csf_api_efd.gt_row_abertura_efd := null;
end pkb_inicia_param;

-------------------------------------------------------------------------------------------------------
-- Procedimento valida a informação do Abertura do Período da EFD

procedure pkb_vld_abertura_efd ( est_log_generico   in out nocopy  dbms_sql.number_table
                               , en_aberturaefd_id  in             abertura_efd.id%type )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  Log_Generico.id%TYPE;
   vt_log_generico    dbms_sql.number_table;
   vn_versao          versao_layout_efd.versao%type;
   vn_cdversao        versao_layout_efd.cd%type;
   vv_cod_part        pessoa.cod_part%type;
   --
   cursor c_aberturaefd is
   select efd.*
        , vl.versao
        , p.cod_part
     from abertura_efd      efd
        , versao_layout_efd vl
        , contador          c
        , pessoa            p
    where efd.id = en_aberturaefd_id
      and vl.id  = efd.verslayoutefd_id
      and c.id   = efd.contador_id
      and p.id   = c.pessoa_id;
   --
begin
   --
   vn_fase := 1;
   --
   vn_versao   := pk_csf_efd.fkg_versao_layout_efd ( en_id => pk_csf_api_efd.gt_row_abertura_efd.verslayoutefd_id );
   vn_cdversao := pk_csf_efd.fkg_cdversao_layout_efd ( en_id => pk_csf_api_efd.gt_row_abertura_efd.verslayoutefd_id );
   --
   vn_fase := 2;
   --
   begin
      --
      select p.cod_part
        into vv_cod_part
        from contador c
           , pessoa   p
       where c.id = pk_csf_api_efd.gt_row_abertura_efd.contador_id
         and p.id = c.pessoa_id;
      --
   exception
      when others then
         vv_cod_part := vv_cod_part;
   end;
   --
   vn_fase := 3;
   --
   pk_csf_api_efd.pkb_integr_abertura_efd ( est_log_generico      => est_log_generico
                                          , est_row_abertura_efd  => pk_csf_api_efd.gt_row_abertura_efd
                                          , en_cdversao           => vn_cdversao
                                          , ev_versao             => vn_versao
                                          , ev_cod_part_contador  => vv_cod_part );
   --
exception
   when others then
      --
      pk_csf_api_efd.gv_mensagem_log := 'Erro na pk_vld_amb_efd.pkb_vld_abertura_efd fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_csf_api_efd.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_efd.gv_mensagem_log
                                         , ev_resumo          => null
                                         , en_tipo_log        => pk_csf_api_efd.ERRO_DE_SISTEMA
                                         , en_referencia_id   => en_aberturaefd_id
                                         , ev_obj_referencia  => pk_csf_api_efd.gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_efd.gv_mensagem_log);
      --
end pkb_vld_abertura_efd;

-------------------------------------------------------------------------------------------------------

--| Procedure valida registro 1400 - Informação sobre valores agregados
procedure pkb_vld_reg_1400(est_log_generico in out nocopy dbms_sql.number_table,
                           en_empresa_id    in empresa.id%type) is
  --
  vn_fase           number := 0;
  vn_loggenerico_id log_generico.id%TYPE;
  vn_estado_id      estado.id%type;
  vn_ipm_estado     number;
  vv_resumo         log_generico.resumo%type;
  vv_cod_item       varchar2(60) := null;
  vv_cod_item_ipm   varchar2(60) := null;
  ve_ipm_exception exception;
  --
  vn_cod_part      number := 0;
  vc_empresa_nome  varchar2(70) := null;
  vn_cod_item      number := 0;
  vc_descr_item    varchar2(2000) := null;
  vv_cod_item_ipm_uf varchar2(60) := null;
  --
  cursor c_1400 is
    select c.ibge_cidade mun,
           iva.item_id item_id,
           nvl(sum(nvl(iva.valor, 0)), 0) valor,
           c.estado_id,
           e.sigla_estado uf
      from inf_valor_agreg iva,  
           cidade c,
           estado e
     where iva.empresa_id = en_empresa_id
       and iva.ano        = to_number(to_char(pk_csf_api_efd.gt_row_abertura_efd.dt_ini, 'RRRR'))
       and iva.mes        = to_number(to_char(pk_csf_api_efd.gt_row_abertura_efd.dt_ini, 'MM'))
       and iva.dm_st_proc in (1, 3) -- 0-Não validada, 1-Validada, 2-Erro de validação, 3-Inserido pelo portal
       and c.id           = iva.cidade_id
       and c.estado_id    = e.id
     group by c.ibge_cidade, 
              iva.item_id, 
              c.estado_id,
              e.sigla_estado;
  --
  --
begin
  --
  vn_fase := 1;
  --
  begin
    delete log_generico o
     where o.obj_referencia = 'ABERTURA_EFD'
       and o.referencia_id = pk_csf_api_efd.gt_row_abertura_efd.id;
    commit;
  end;
  --
  -- Recupera o código do estado (ESTADO_ID) da empresa
  begin
    select c.estado_id
      into vn_estado_id
      from empresa e, 
           pessoa p, 
           cidade c
     where p.id = e.pessoa_id
       and c.id = p.cidade_id
       and e.id = en_empresa_id;
  exception
    when others then
      vn_estado_id := 0;
      gv_resumo    := 'Problemas ao recuperar o código do estado para a empresa.';
  end;
  --
  vn_fase := 2;
  --
  --
  if vn_estado_id > 0 then
    --
    -- Verifica se existe código de IPM cadastrado
    -- para o estado da empresa
    begin
      select count(*)
        into vn_ipm_estado
        from param_ipm p
       where p.estado_id = vn_estado_id;
    exception
      when others then
        vn_ipm_estado := 0; -- Não existe código de IPM cadastrado
    end;
    --
    vn_fase := 3;
    --
    if vn_ipm_estado > 0 then
      --
      vn_fase := 4;
      --
      for rec_1400 in c_1400 loop
        exit when c_1400%notfound or(c_1400%notfound) is null;
        --
        vn_fase := 5;
        --
        vv_cod_item     := null;
        vv_cod_item_ipm := null;
        --
        vv_cod_item_ipm := pk_csf_efd.fkg_recup_cod_ipm_item(en_empresa_id => en_empresa_id,
                                                             en_item_id    => rec_1400.item_id,
                                                             en_estado     => rec_1400.estado_id);
      --
      -- Verifica se existe cadastro do parametro COD_ITEM_IPM para a UF
      begin
        select count(*)
            into vv_cod_item_ipm_uf
            from dominio d
           where d.dominio = 'PARAM_EFD_ICMS_IPI.DM_COD_ITEM_IPM_UF'
           and d.vl = rec_1400.uf;
        exception
          when others then
            null;
      end;  
        --
        -- Verifica se há algum item/produto com código IPM nulo
        if vv_cod_item_ipm is null and vv_cod_item_ipm_uf is not null then
        --
        begin
          select cod_part, nome
            into vn_cod_part, vc_empresa_nome
            from empresa e, pessoa p
           where e.pessoa_id = p.id
             and e.id = en_empresa_id; 
             exception 
               when others then 
                  null;
         end;
         --
       begin
          select cod_item, descr_item
            into vn_cod_item, vc_descr_item
            from item
           where id = rec_1400.item_id
             and empresa_id = en_empresa_id;
             exception 
               when others then 
                  null;
        end;          
          --
          gv_resumo := 'Para o registro 1400 será necessário o relacionamento do código do Item IPM com o código do Item '||vn_cod_item||' - '||vc_descr_item||' da Empresa '||vn_cod_part||' - '||vc_empresa_nome||'.';
          --
          pk_csf_api_efd.gv_mensagem_log := 'Erro na pk_vld_amb_efd.pkb_vld_reg_1400 fase(' || vn_fase || '): ' || sqlerrm;
          --
          declare
            vn_loggenerico_id log_generico.id%type;
          begin
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api_efd.pkb_log_generico(sn_loggenerico_id => vn_loggenerico_id,
                                            ev_mensagem       => pk_csf_api_efd.gv_mensagem_log,
                                            ev_resumo         => gv_resumo,
                                            en_tipo_log       => pk_csf_api_efd.erro_de_sistema,
                                            en_referencia_id  => pk_csf_api_efd.gt_row_abertura_efd.id,
                                            ev_obj_referencia => pk_csf_api_efd.gv_obj_referencia);
            --
            -- Armazena o "loggenerico_id" na memória
            pk_csf_api_efd.pkb_gt_log_generico(en_loggenerico    => vn_loggenerico_id,
                                               est_log_generico  => est_log_generico);
            --
            --
          exception
            when others then
              null;
          end;
          --
          exit;
          --
        end if;
        --
        vn_fase := 6;
        --
      end loop;
      --
    end if;
    --
    vn_fase := 7;
    --
  end if;
  --
exception
  when others then
    --
    pk_csf_api_efd.gv_mensagem_log := 'Erro na pk_vld_amb_efd.pkb_vld_reg_1400 fase(' || vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico.id%type;
    begin
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api_efd.pkb_log_generico(sn_loggenerico_id => vn_loggenerico_id,
                                      ev_mensagem       => pk_csf_api_efd.gv_mensagem_log,
                                      ev_resumo         => gv_resumo,
                                      en_tipo_log       => pk_csf_api_efd.erro_de_sistema,
                                      en_referencia_id  => pk_csf_api_efd.gt_row_abertura_efd.id,
                                      ev_obj_referencia => pk_csf_api_efd.gv_obj_referencia);
      --
      -- Armazena o "loggenerico_id" na memória
      pk_csf_api_efd.pkb_gt_log_generico(en_loggenerico    => vn_loggenerico_id,
                                         est_log_generico  => est_log_generico);
      -- 
    exception
      when others then
        null;
    end;
    --
    raise_application_error(-20101, pk_csf_api_efd.gv_mensagem_log);
    --
end pkb_vld_reg_1400;
-------------------------------------------------------------------------------------------------------

-- Procedimento inicia a valição do ambiente do Sped Fiscal
procedure pkb_vld_efd ( en_aberturaefd_id in abertura_efd.id%type )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  Log_Generico.id%TYPE;
   vt_log_generico    dbms_sql.number_table;
   vv_resumo          varchar2(1000) := null;
   --#69103 
   vv_uf_emp_logada   abertura_efd.uf%type          := null ;
   --
begin
   --
   if nvl(en_aberturaefd_id,0) > 0 then
      --
      vn_fase := 1;
      --
      pkb_inicia_param ( en_aberturaefd_id => en_aberturaefd_id );
      pk_csf_api_efd.gn_empresa_id := pk_csf_api_efd.gt_row_abertura_efd.empresa_id;
      pk_csf_api_efd.gv_cabec_log  := 'Validação do Sped Fiscal - Período de '||
                                      pk_csf_api_efd.gt_row_abertura_efd.dt_ini||' até '||
                                      pk_csf_api_efd.gt_row_abertura_efd.dt_fim;
      --
      vn_fase := 2;
      --
      if nvl(pk_csf_api_efd.gt_row_abertura_efd.id,0) > 0 then
         --
         vt_log_generico.delete;
         --
         vn_fase := 3;
         --
         -- #69103 
         vv_uf_emp_logada := pk_csf.fkg_sigla_estado_empresa(pk_csf_api_efd.gt_row_abertura_efd.empresa_id);      
         --
         if (pk_csf_api_efd.gt_row_abertura_efd.dm_ind_ativ = '2' AND vv_uf_emp_logada <> 'DF' ) then
         --
            pk_csf_api_efd.gv_mensagem_log := null;
            --
            pk_csf_api_efd.gv_mensagem_log := 'Somente empresas situadas no Distrito Federal podem optar pelo campo "Indicador do tipo de atividade = Contribuintes apenas do ISS - DF".';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api_efd.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                            , ev_mensagem        => pk_csf_api_efd.gv_cabec_log
                                            , ev_resumo          => pk_csf_api_efd.gv_mensagem_log
                                            , en_tipo_log        => pk_csf_api_efd.erro_de_validacao
                                            , en_referencia_id   => en_aberturaefd_id
                                            , ev_obj_referencia  => 'ABERTURA_EFD' );
            --
            -- Armazena o "loggenerico_id" na memória
            pk_csf_api_efd.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                               , est_log_generico  => vt_log_generico );
            --
            if pk_csf_api_efd.gv_mensagem_log is null or nvl(vt_log_generico.count,0) <= 0 then
               --
               vn_fase := 7;
               --
               update abertura_efd set dm_situacao = 2 -- Validado
                where id = en_aberturaefd_id;
                commit;
               --
            else
               --
               vn_fase := 8;
               --
               update abertura_efd set dm_situacao = 1 -- Erro de validação
                where id = en_aberturaefd_id;
                commit;
               --
            end if;
            --
         else
           --
           vn_fase := 4;
           -- Valida Informação da Abertura da EFD
           pkb_vld_abertura_efd ( est_log_generico   => vt_log_generico
                                , en_aberturaefd_id  => en_aberturaefd_id );
           --
           vn_fase := 5;
           --| Chama procedimento de vinculo de cadastro de nota fiscal
           pk_csf_api.pkb_acerta_vinc_cadastro ( en_empresa_id => pk_csf_api_efd.gt_row_abertura_efd.empresa_id
                                               , ed_data => pk_csf_api_efd.gt_row_abertura_efd.dt_ini
                                               );
           --
           vn_fase := 6;
           --
           -- Valida informações do registro 1400
           pkb_vld_reg_1400(est_log_generico => vt_log_generico,
                            en_empresa_id    => pk_csf_api_efd.gt_row_abertura_efd.empresa_id);
           --
           if gv_resumo is null or nvl(vt_log_generico.count,0) <= 0 then
              --
              vn_fase := 7;
              --
              update abertura_efd set dm_situacao = 2 -- Validado
               where id = en_aberturaefd_id;
               commit;
              --
           else
              --
              vn_fase := 8;
              --
              update abertura_efd set dm_situacao = 1 -- Erro de validação
               where id = en_aberturaefd_id;
               commit;
              --
           end if;
           --
        end if;
        --
      else
         --
         vn_fase := 10;
         --
         pk_csf_api_efd.gv_mensagem_log := null;
         --
         pk_csf_api_efd.gv_mensagem_log := 'Período do Sped Fiscal não permite que ele seja validado.';
         --
         vn_loggenerico_id := null;
         --
         pk_csf_api_efd.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_efd.gv_cabec_log
                                         , ev_resumo          => pk_csf_api_efd.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_efd.erro_de_validacao
                                         , en_referencia_id   => en_aberturaefd_id
                                         , ev_obj_referencia  => 'ABERTURA_EFD' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_efd.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                            , est_log_generico  => vt_log_generico );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_efd.gv_mensagem_log := 'Erro na pk_vld_amb_efd.pkb_vld_efd fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_csf_api_efd.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_efd.gv_mensagem_log
                                         , ev_resumo          => null
                                         , en_tipo_log        => pk_csf_api_efd.erro_de_sistema
                                         , en_referencia_id   => en_aberturaefd_id
                                         , ev_obj_referencia  => 'ABERTURA_EFD' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_efd.gv_mensagem_log);
      --
end pkb_vld_efd;

-------------------------------------------------------------------------------------------------------

-- Procedimento desfaz a situação de processo do Sped Fiscal

procedure pkb_desfazer ( en_aberturaefd_id  in abertura_efd.id%type )
is
   --
   vn_fase number := null;
   --
begin
   --
   vn_fase := 1;
   -- inicia os parâmetros da EFD
   pkb_inicia_param ( en_aberturaefd_id => en_aberturaefd_id );
   --
   vn_fase := 2;
   --
   if nvl(pk_csf_api_efd.gt_row_abertura_efd.id,0) > 0 then
      --
      vn_fase := 3;
      --
      if pk_csf_api_efd.gt_row_abertura_efd.dm_situacao in (3, 4, 5) then
         -- Se for 3-Gerado Arquivo ou 4-Erro na geração do arquivo ou 5-Em geração
         -- volta para 2-Validado
         --
         vn_fase := 4;
         --
         delete from estr_arq_efd where aberturaefd_id = pk_csf_api_efd.gt_row_abertura_efd.id;
         --
         vn_fase := 5;
         --
         update abertura_efd set dm_situacao = 2
          where id = pk_csf_api_efd.gt_row_abertura_efd.id;
         --
      elsif pk_csf_api_efd.gt_row_abertura_efd.dm_situacao in (2, 1) then
         -- Se for 2-Validado ou 1-Erro de validação
         -- volta para 0-Não Gerado
         --
         vn_fase := 6;
         --
         update abertura_efd set dm_situacao = 0
          where id = pk_csf_api_efd.gt_row_abertura_efd.id;
         --
      end if;
      --
      vn_fase := 7;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_efd.gv_mensagem_log := 'Erro na pk_vld_amb_efd.pkb_desfazer fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_csf_api_efd.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_efd.gv_mensagem_log
                                         , ev_resumo          => null
                                         , en_tipo_log        => pk_csf_api_efd.ERRO_DE_SISTEMA
                                         , en_referencia_id   => en_aberturaefd_id
                                         , ev_obj_referencia  => 'ABERTURA_EFD' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_efd.gv_mensagem_log);
      --
end pkb_desfazer;

-------------------------------------------------------------------------------------------------------

-- Procedimento inicia a valição do ambiente do Sped Fiscal (Contimatic)
procedure pkb_vld_efd_cont ( en_aberturaefdcont_id in abertura_efd_cont.id%type )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico.id%type;
   vt_log_generico    dbms_sql.number_table;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_aberturaefdcont_id,0) > 0 then
      --
      vn_fase := 2;
      --
      update abertura_efd_cont ae
         set ae.dm_situacao = 2 -- Validado
       where ae.id = en_aberturaefdcont_id;
      --
      vn_fase := 3;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_efd.gv_mensagem_log := 'Erro na pk_vld_amb_efd.pkb_vld_efd_cont fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         --
         pk_csf_api_efd.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_efd.gv_mensagem_log
                                         , ev_resumo          => null
                                         , en_tipo_log        => pk_csf_api_efd.erro_de_sistema
                                         , en_referencia_id   => en_aberturaefdcont_id
                                         , ev_obj_referencia  => 'ABERTURA_EFD_CONT' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_efd.gv_mensagem_log);
      --
end pkb_vld_efd_cont;

-------------------------------------------------------------------------------------------------------

--| Procedure inicia os parâmetros do Sped Fiscal (Contimatic)
procedure pkb_inicia_param_cont ( en_aberturaefdcont_id in abertura_efd_cont.id%type )
is
begin
   --
   select ae.*
     into gt_row_abertura_efd_cont
     from abertura_efd_cont ae
    where ae.id = en_aberturaefdcont_id;
   --
exception
   when others then
      gt_row_abertura_efd_cont := null;
end pkb_inicia_param_cont;

-------------------------------------------------------------------------------------------------------

-- Procedimento desfaz a situação de processo do Sped Fiscal (contimatic)

procedure pkb_desfazer_cont ( en_aberturaefdcont_id in abertura_efd_cont.id%type )
is
   --
   vn_fase number := null;
   --
begin
   --
   vn_fase := 1;
   -- inicia os parâmetros da EFD
   pkb_inicia_param_cont ( en_aberturaefdcont_id => en_aberturaefdcont_id );
   --
   vn_fase := 2;
   --
   if nvl(gt_row_abertura_efd_cont.id,0) > 0 then
      --
      vn_fase := 3;
      --
      if gt_row_abertura_efd_cont.dm_situacao in (4, 3, 5) then
         -- Se for 4-Erro na geração do arquivo ou 3-Gerado Arquivo
         -- volta para 2-Validado
         --
         vn_fase := 4;
         --
         delete from estr_arq_efd_cont ea
          where ea.aberturaefdcont_id = gt_row_abertura_efd_cont.id;
         --
         vn_fase := 5;
         --
         update abertura_efd_cont ae
            set ae.dm_situacao = 2
          where ae.id = gt_row_abertura_efd_cont.id;
         --
      elsif gt_row_abertura_efd_cont.dm_situacao in (2, 1) then
         -- Se for 2-Validado ou 1-Erro de validação
         -- volta para 0-Não Gerado
         --
         vn_fase := 6;
         --
         update abertura_efd_cont ae
            set ae.dm_situacao = 0
          where ae.id = gt_row_abertura_efd_cont.id;
         --
      end if;
      --
      vn_fase := 7;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_efd.gv_mensagem_log := 'Erro na pk_vld_amb_efd.pkb_desfazer_cont fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         --
         pk_csf_api_efd.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_efd.gv_mensagem_log
                                         , ev_resumo          => null
                                         , en_tipo_log        => pk_csf_api_efd.erro_de_sistema
                                         , en_referencia_id   => en_aberturaefdcont_id
                                         , ev_obj_referencia  => 'ABERTURA_EFD_CONT' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_efd.gv_mensagem_log);
      --
end pkb_desfazer_cont;

-------------------------------------------------------------------------------------------------------
end pk_vld_amb_efd;
/
