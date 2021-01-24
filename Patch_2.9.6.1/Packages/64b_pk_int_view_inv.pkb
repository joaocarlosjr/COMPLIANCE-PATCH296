create or replace package body csf_own.pk_int_view_inv is

-------------------------------------------------------------------------------------------------------
--| Corpo do pacote de procedimentos de integração e validação de Cadastros
-------------------------------------------------------------------------------------------------------

function fkg_monta_from ( ev_obj in varchar2 )
         return varchar2
is
   --
   vv_from  varchar2(4000) := null;
   vv_obj   varchar2(4000) := null;
   --
begin
   --
   vv_obj := ev_obj;
   --
   if GV_NOME_DBLINK is not null then
      --
      vv_from := vv_from || trim(GV_ASPAS) || vv_obj || trim(GV_ASPAS) || '@' || GV_NOME_DBLINK;
      --
   else
      --
      vv_from := vv_from || trim(GV_ASPAS) || vv_obj || trim(GV_ASPAS);
      --
   end if;
   --
   if trim(GV_OWNER_OBJ) is not null then
      vv_from := trim(GV_OWNER_OBJ) || '.' || vv_from;
   end if;
   --
   vv_from := ' from ' || vv_from;
   --
   return vv_from;
   --
end fkg_monta_from;

-------------------------------------------------------------------------------------------------------

--| Procedimento de integração de Inventário
procedure pkb_invent_cst ( est_log_generico   in out nocopy  dbms_sql.number_table
                         , en_inventario_id   in inventario.id%type
                         , ev_cpf_cnpj        in varchar2
                         , ev_cod_item        in item.cod_item%type
                         , ed_dt_inventario   in date
                         )
   --
is
   --
   vn_fase               number := 0;
   vn_loggenericoinv_id  log_generico_inv.id%type;
   vn_qtde               number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_INVENT_CST' ) = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_invent_cst.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select trim(';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ' || trim(GV_ASPAS) || ')';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_INVENTARIO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'COD_ITEM' || trim(GV_ASPAS) || ')';
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'COD_ST' || trim(GV_ASPAS) || ')';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_BC_ICMS' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_ICMS' || trim(GV_ASPAS);
   --
   vn_fase := 1.1;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_INVENT_CST' );
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where trim(';
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ' || trim(GV_ASPAS) || ') = ' || '''' || ev_cpf_cnpj || '''';
   gv_sql := gv_sql || ' and trim(' || trim(GV_ASPAS) || 'COD_ITEM' || trim(GV_ASPAS) || ') = ' || '''' || ev_cod_item || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DT_INVENTARIO' || trim(GV_ASPAS) || ' = ' || '''' || to_char(ed_dt_inventario, GV_FORMATO_DT_ERP) || '''';
   --
   vn_fase := 2;
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_invent_cst;
      --
   exception
      when others then
         -- não registra erro casa a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            gv_mensagem_log := 'Erro na pk_int_view_inv.pkb_invent_cst fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenericoinv_id  Log_Generico_inv.id%TYPE;
            begin
               --
               pk_csf_api_inv.pkb_log_generico_inv ( sn_loggenericoinv_id  => vn_loggenericoinv_id
                                                   , ev_mensagem        => gv_mensagem_log
                                                   , ev_resumo          => gv_mensagem_log
                                                   , en_tipo_log        => ERRO_DE_SISTEMA
                                                   , en_referencia_id   => null
                                                   , ev_obj_referencia  => gv_obj_referencia
                                                   , en_empresa_id      => gn_empresa_id
                                                   );
               --
            exception
               when others then
                  null;
            end;
            --
            raise_application_error (-20101, gv_mensagem_log);
            --
         end if;
   end;
   --
   vn_fase := 2.1;
   --
   if nvl(vt_tab_csf_invent_cst.count,0) > 0 then
      --
      for i in vt_tab_csf_invent_cst.first .. vt_tab_csf_invent_cst.last loop
         --
         vn_fase := 3;
         --
         vn_qtde := nvl(vn_qtde,0) + 1;
         --
         vn_fase := 3.1;
         --
         pk_csf_api_inv.gt_row_invent_cst := null;
         --
         pk_csf_api_inv.gt_row_invent_cst.vl_bc_icms     := vt_tab_csf_invent_cst(i).vl_bc_icms;
         pk_csf_api_inv.gt_row_invent_cst.vl_icms        := vt_tab_csf_invent_cst(i).vl_icms;
         pk_csf_api_inv.gt_row_invent_cst.inventario_id  := en_inventario_id;
         --
         vn_fase := 3.2;
         --
         pk_csf_api_inv.pkb_integr_invent_cst ( est_log_generico => est_log_generico
                                              , est_invent_cst   => pk_csf_api_inv.gt_row_invent_cst
                                              , ev_cpf_cnpj      => vt_tab_csf_invent_cst(i).cpf_cnpj
                                              , ev_cod_item      => vt_tab_csf_invent_cst(i).cod_item
                                              , ev_cod_st        => vt_tab_csf_invent_cst(i).cod_st
                                              , en_multorg_id    => gn_multorg_id
                                              );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_inv.pkb_invent_cst fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenericoinv_id  Log_Generico_inv.id%TYPE;
      begin
         --
         pk_csf_api_inv.pkb_log_generico_inv ( sn_loggenericoinv_id => vn_loggenericoinv_id
                                             , ev_mensagem          => gv_mensagem_log
                                             , ev_resumo            => gv_mensagem_log
                                             , en_tipo_log          => erro_de_sistema
                                             , en_referencia_id     => null
                                             , ev_obj_referencia    => gv_obj_referencia
                                             , en_empresa_id        => gn_empresa_id
                                             );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_invent_cst;

-------------------------------------------------------------------------------------------------------

--| Procedimento de leitura do Inventário - campos Flex Field

procedure pkb_inventario_ff ( est_log_generico   in out nocopy  dbms_sql.number_table
                            , en_inventario_id   in inventario.id%type
                            , ev_cpf_cnpj        in varchar2
                            , ev_cod_item        in item.cod_item%type
                            , ed_dt_inventario   in date
                            )
is
   --
   vn_fase   number := 0;
   i         pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_INVENTARIO_FF') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select trim(';
   --
   gv_sql := gv_sql ||         trim(GV_ASPAS) || 'CPF_CNPJ'      || trim(GV_ASPAS) || ')';
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'COD_ITEM'      || trim(GV_ASPAS) || ')';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_INVENTARIO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || GV_ASPAS       || 'ATRIBUTO'      || GV_ASPAS || ')';
   gv_sql := gv_sql || ', trim(' || GV_ASPAS       || 'VALOR'         || GV_ASPAS || ')';
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_INVENTARIO_FF');
   --
   vn_fase := 2;
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where trim(';
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ' || trim(GV_ASPAS) || ') = ' || '''' || ev_cpf_cnpj || '''';
   gv_sql := gv_sql || ' and trim(' || trim(GV_ASPAS) || 'COD_ITEM' || trim(GV_ASPAS) || ') = ' || '''' || ev_cod_item || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DT_INVENTARIO' || trim(GV_ASPAS) || ' = ' || '''' || to_char(ed_dt_inventario, GV_FORMATO_DT_ERP) || '''';
   --
   vn_fase := 3;
   -- recupera as Notas Fiscais não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_inventario_ff;
     --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            gv_mensagem_log := 'Erro na pk_integr_view.pkb_ler_inventario_ff fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenericoinv_id  log_generico_inv.id%type;
            begin
               --
               pk_csf_api_inv.pkb_log_generico_inv ( sn_loggenericoinv_id => vn_loggenericoinv_id
                                                   , ev_mensagem          => gv_mensagem_log
                                                   , ev_resumo            => gv_mensagem_log
                                                   , en_tipo_log          => erro_de_sistema
                                                   , en_referencia_id     => null
                                                   , ev_obj_referencia    => gv_obj_referencia
                                                   , en_empresa_id        => gn_empresa_id
                                                   );
               --
            exception
               when others then
                  null;
            end;
            --
            raise_application_error (-20101, gv_mensagem_log);
            --
         end if;
   end;
   --
   vn_fase := 4;
   --
   if vt_tab_csf_inventario_ff.count > 0 then
      --
      for i in vt_tab_csf_inventario_ff.first..vt_tab_csf_inventario_ff.last loop
         --
         if upper(trim(vt_tab_csf_inventario_ff(i).atributo)) not in ('COD_MULT_ORG', 'HASH_MULT_ORG') then
            --
            pk_csf_api_inv.pkb_integr_inventario_ff ( est_log_generico => est_log_generico
                                                    , en_inventario_id => en_inventario_id
                                                    , ev_cpf_cnpj      => vt_tab_csf_inventario_ff(i).cpf_cnpj
                                                    , ev_cod_item      => vt_tab_csf_inventario_ff(i).cod_item
                                                    , ev_atributo      => vt_tab_csf_inventario_ff(i).atributo
                                                    , ev_valor         => vt_tab_csf_inventario_ff(i).valor
                                                    , en_multorg_id    => gn_multorg_id
                                                    );
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
      gv_mensagem_log := 'Erro na pk_integr_view.pkb_inventario_ff fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericoinv_id  log_generico_inv.id%type;
      begin
         --
         pk_csf_api_inv.pkb_log_generico_inv ( sn_loggenericoinv_id => vn_loggenericoinv_id
                                             , ev_mensagem          => gv_mensagem_log
                                             , ev_resumo            => gv_mensagem_log
                                             , en_tipo_log          => erro_de_sistema
                                             , en_referencia_id     => null
                                             , ev_obj_referencia    => gv_obj_referencia
                                             , en_empresa_id        => gn_empresa_id
                                             );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_inventario_ff;

-------------------------------------------------------------------------------------------------------

procedure pkb_inventario_multorg_ff( est_log_generico  in  out nocopy  dbms_sql.number_table
                                   , ev_cpf_cnpj       in  varchar2
                                   , ev_cod_item       in  varchar2
                                   , ed_dt_inventario  in  date
                                   , sn_multorg_id     in  out nocopy  mult_org.id%type)
is
   vn_fase               number := 0;
   vn_loggenericoinv_id  log_generico_inv.id%TYPE;
   vv_cod                mult_org.cd%type;
   vv_hash               mult_org.hash%type;
   vv_cod_ret            mult_org.cd%type;
   vv_hash_ret           mult_org.hash%type;
   vn_multorg_id         mult_org.id%type := 0;
   vb_multorg            boolean  := false;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_INVENTARIO_FF') = 0 then
      --
      sn_multorg_id := vn_multorg_id;
      --
      return;
      --
   end if;
   --
   gv_obj_referencia := 'INVENTARIO';
   --
   gv_sql := null;
   --
   vt_tab_csf_inventario_ff.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select trim(';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ' || trim(GV_ASPAS) || ')';
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'COD_ITEM' || trim(GV_ASPAS) || ')';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_INVENTARIO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'ATRIBUTO' || trim(GV_ASPAS) || ')';
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'VALOR' || trim(GV_ASPAS) || ')';
   --
   vn_fase := 1.1;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_INVENTARIO_FF' );
   --
   gv_sql := gv_sql || ' WHERE trim(' || trim(GV_ASPAS) || 'CPF_CNPJ' || trim(GV_ASPAS) || ') = ' ||''''||ev_cpf_cnpj||'''';
   --
   gv_sql := gv_sql || ' AND trim(' || trim(GV_ASPAS) || 'COD_ITEM' || trim(GV_ASPAS) || ') = ' ||''''||ev_cod_item||'''';
   --
   gv_sql := gv_sql || ' AND ' || trim(GV_ASPAS) || 'DT_INVENTARIO' || trim(GV_ASPAS) || ' = ' || '''' || to_char(ed_dt_inventario, GV_FORMATO_DT_ERP) || '''';
   --
   gv_sql := gv_sql || ' ORDER BY ' || trim(GV_ASPAS) || 'CPF_CNPJ' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'COD_ITEM' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'DT_INVENTARIO' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'ATRIBUTO' || trim(GV_ASPAS);
   --
   vn_fase := 2;
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_inventario_ff;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            gv_mensagem_log := 'Erro na pk_int_view_int.pkb_inventario_multorg_ff fase('||vn_fase||'):'||sqlerrm;
            --
            declare
               vn_loggenericoinv_id  log_generico_inv.id%TYPE;
            begin
               --
               pk_csf_api_inv.pkb_log_generico_inv ( sn_loggenericoinv_id  => vn_loggenericoinv_id
                                                   , ev_mensagem        => gv_mensagem_log
                                                   , ev_resumo          => 'Inventario: item - ' || ev_cod_item ||'cnpj/cpf - '||ev_cpf_cnpj
                                                   , en_tipo_log        => ERRO_DE_SISTEMA
                                                   , en_referencia_id   => null
                                                   , ev_obj_referencia  => gv_obj_referencia
                                                   , en_empresa_id      => gn_empresa_id
                                                   );
               --
            exception
               when others then
                  null;
            end;
            --
            raise_application_error (-20101, gv_mensagem_log);
            --
         end if;
   end;
   --
   vn_fase := 3;
   --
   if vt_tab_csf_inventario_ff.count > 0 then
      --
      for i in vt_tab_csf_inventario_ff.first..vt_tab_csf_inventario_ff.last loop
         --
         vn_fase := 4;
         --
         if vt_tab_csf_inventario_ff(i).atributo in ('COD_MULT_ORG', 'HASH_MULT_ORG') then
            --
            vb_multorg := true;
            --
            vn_fase := 5;
            -- Chama procedimento que faz a validação dos itens da Inventario - campos flex field.
            vv_cod_ret := null;
            vv_hash_ret := null;

            pk_csf_api_inv.pkb_val_atrib_multorg ( est_log_generico     => est_log_generico
                                                 , ev_obj_name          => 'VW_CSF_INVENTARIO_FF'
                                                 , ev_atributo          => vt_tab_csf_inventario_ff(i).atributo
                                                 , ev_valor             => vt_tab_csf_inventario_ff(i).valor
                                                 , sv_cod_mult_org      => vv_cod_ret
                                                 , sv_hash_mult_org     => vv_hash_ret
                                                 , en_referencia_id     => null
                                                 , ev_obj_referencia    => gv_obj_referencia);
           --
           vn_fase := 6;
           --
           if vv_cod_ret is not null then
              vv_cod := vv_cod_ret;
           end if;
           --
           if vv_hash_ret is not null then
              vv_hash := vv_hash_ret;
           end if;
           --
        end if;
        --
      end loop;
      --
      vn_fase := 7;
      --
      if nvl(est_log_generico.count, 0) <= 0 and
         vb_multorg then
         --
         vn_fase := 8;
         --
         vn_multorg_id := sn_multorg_id;
         pk_csf_api_inv.pkb_ret_multorg_id( est_log_generico   => est_log_generico
                                          , ev_cod_mult_org    => vv_cod
                                          , ev_hash_mult_org   => vv_hash
                                          , sn_multorg_id      => vn_multorg_id
                                          , en_referencia_id   => null
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
      end if;
      --
      vn_fase := 9;
      --
      sn_multorg_id := vn_multorg_id;
      --
   else
      --
      gv_mensagem_log := 'Inventario cadastrada com Mult Org default (codigo = 1), pois não foram passados o codigo e a hash do multorg.';
      --
      vn_loggenericoinv_id := null;
      --
      vn_fase := 10;
      --
      pk_csf_api_inv.pkb_log_generico_inv ( sn_loggenericoinv_id  => vn_loggenericoinv_id
                                          , ev_mensagem           => gv_mensagem_log
                                          , ev_resumo             => 'Inventario: item - ' || ev_cod_item ||'cnpj/cpf - '||ev_cpf_cnpj
                                          , en_tipo_log           => INFORMACAO
                                          , en_referencia_id      => gn_referencia_id
                                          , ev_obj_referencia     => gv_obj_referencia
                                          , en_empresa_id         => gn_empresa_id
                                          );
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_int.pkb_inventario_multorg_ff fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenericoinv_id  log_generico_inv.id%TYPE;
      begin
         --
         pk_csf_api_inv.pkb_log_generico_inv ( sn_loggenericoinv_id  => vn_loggenericoinv_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => 'Inventario: item - ' || ev_cod_item ||'cnpj/cpf - '||ev_cpf_cnpj
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => pk_csf_api_inv.gt_row_inventario.id
                                     , ev_obj_referencia  => gv_obj_referencia
                                     , en_empresa_id      => gn_empresa_id
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_inventario_multorg_ff;

-------------------------------------------------------------------------------------------------------

--| Procedimento de integração de Inventário
procedure pkb_inventario ( ev_cpf_cnpj in varchar2
                         , ed_dt_ini   in date
                         , ed_dt_fin   in date 
                         )
is
   --
   vn_fase           number := 0;
   vt_log_generico   dbms_sql.number_table;
   vn_loggenericoinv_id log_generico_inv.id%type;
   vn_qtde           number := 0;
   vd_dt_ult_fecha   fecha_fiscal_empresa.dt_ult_fecha%type;
   vn_empresa_id     empresa.id%type;
   vn_multorg_id     mult_org.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_INVENTARIO') = 0 then
      --
      return;
      --
   end if;
   --
   gv_obj_referencia := 'INVENTARIO';
   --
   gv_sql := null;
   --
   delete from log_generico_inv where id in ( select lgi.id
                                                from log_generico_inv  lgi
                                                   , csf_tipo_log  tl
                                               where lgi.obj_referencia    = 'INVENTARIO'
                                                 and ( lgi.referencia_id is null or lgi.empresa_id = gn_empresa_id )
                                                 and tl.id                = lgi.csftipolog_id
                                                 and tl.cd_compat in ('1','2'));
   --
   commit;
   --
   vt_tab_csf_inventario.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select trim(';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ' || trim(GV_ASPAS) || ')';
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'COD_ITEM' || trim(GV_ASPAS) || ')';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_INVENTARIO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'SIGLA_UNID' || trim(GV_ASPAS) || ')';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'QTDE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_UNIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_ITEM' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_PROP' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS) || ')';
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'TXT_COMPL' || trim(GV_ASPAS) || ')';
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'COD_CTA' || trim(GV_ASPAS) || ')';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_REF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'DM_MOT_INV' || trim(GV_ASPAS) || ')';
   --
   vn_fase := 1.1;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_INVENTARIO' );
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where trim(';
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ' || trim(GV_ASPAS) || ') = ' || '''' || ev_cpf_cnpj || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'VL_ITEM' || trim(GV_ASPAS) || ' >= 0';
   --
   vn_fase := 1.2;
   --
   if ed_dt_ini is not null
      and ed_dt_fin is not null
      then
	  gv_sql := gv_sql || ' and trunc(nvl( ' || trim(GV_ASPAS) || 'DT_REF,DT_INVENTARIO' || trim(GV_ASPAS) || ' )) between ' || '''' || to_char(ed_dt_ini, GV_FORMATO_DT_ERP) || '''';
	  gv_sql := gv_sql || ' and '|| '''' || to_char(ed_dt_fin, GV_FORMATO_DT_ERP) || '''';
--      gv_sql := gv_sql || ' and ( trunc( ' || trim(GV_ASPAS) || 'DT_REF' || trim(GV_ASPAS) || ' ) >= ' || '''' || to_char(ed_dt_ini, GV_FORMATO_DT_ERP) || '''';
--      gv_sql := gv_sql || ' and trunc( ' || trim(GV_ASPAS) || 'DT_REF' || trim(GV_ASPAS) || ' ) <= ' || '''' || to_char(ed_dt_fin, GV_FORMATO_DT_ERP) || '''' || ')';
   end if;
   --
   vn_fase := 2;
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_inventario;
      --
   exception
      when others then
         -- não registra erro casa a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            gv_mensagem_log := 'Erro na pk_int_view_inv.pkb_inventario fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenericoinv_id  Log_Generico_inv.id%TYPE;
            begin
               --
               pk_csf_api_inv.pkb_log_generico_inv ( sn_loggenericoinv_id  => vn_loggenericoinv_id
                                           , ev_mensagem        => gv_mensagem_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_SISTEMA
                                           , en_referencia_id   => null
                                           , ev_obj_referencia  => gv_obj_referencia
                                           , en_empresa_id      => gn_empresa_id
                                           );
               --
            exception
               when others then
                  null;
            end;
            --
            raise_application_error (-20101, gv_mensagem_log);
            --
         end if;
   end;
   --
   vn_fase := 2.1;
   --
   -- Calcula a quantidade de registros buscados no ERP
   -- para ser mostrado na tela de agendamento.
   --
   begin
      pk_agend_integr.gvtn_qtd_erp(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erp(gv_cd_obj),0) + nvl(vt_tab_csf_inventario.count,0);
   exception
      when others then
      null;
   end;
   --
   if nvl(vt_tab_csf_inventario.count,0) > 0 then
      --
      for i in vt_tab_csf_inventario.first .. vt_tab_csf_inventario.last loop
         --
         vn_fase := 3;
         --
         vn_qtde := nvl(vn_qtde,0) + 1;
         --
         vt_log_generico.delete;
         --
         vn_multorg_id := gn_multorg_id;
         --
         pkb_inventario_multorg_ff( est_log_generico  =>  vt_log_generico
                                  , ev_cpf_cnpj       =>  vt_tab_csf_inventario(i).cpf_cnpj
                                  , ev_cod_item       =>  vt_tab_csf_inventario(i).cod_item
                                  , ed_dt_inventario  =>  vt_tab_csf_inventario(i).dt_inventario
                                  , sn_multorg_id     =>  vn_multorg_id );
         vn_fase := 3.1;
         --
         if nvl(vn_multorg_id, 0) <= 0 then
            --
            vn_multorg_id := gn_multorg_id;
            --
         elsif vn_multorg_id != gn_multorg_id then
            --
            vn_multorg_id := gn_multorg_id;
            --
            gv_mensagem_log := 'Mult-org informado pelo usuario('||vn_multorg_id||') não corresponde ao Mult-org da empresa('||gn_multorg_id||').';
            --
            vn_loggenericoinv_id := null;
            --
            vn_fase := 10;
            --
            pk_csf_api_inv.pkb_log_generico_inv ( sn_loggenericoinv_id  => vn_loggenericoinv_id
                                                , ev_mensagem           => gv_mensagem_log
                                                , ev_resumo             => 'Mult-Org incorreto ou não informado.'
                                                , en_tipo_log           => INFORMACAO
                                                , en_referencia_id      => gn_referencia_id
                                                , ev_obj_referencia     => gv_obj_referencia
                                                , en_empresa_id         => gn_empresa_id
                                                );
            --
         end if;
         --
         vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id => vn_multorg_id
                                                              , ev_cpf_cnpj   => vt_tab_csf_inventario(i).cpf_cnpj
                                                              );
         --
         vd_dt_ult_fecha := pk_csf.fkg_recup_dtult_fecha_empresa( en_empresa_id   => vn_empresa_id
                                                                , en_objintegr_id => pk_csf.fkg_recup_objintegr_id( ev_cd => '2' ));
         --
         vn_fase := 4;
         --
         if vd_dt_ult_fecha is null or
            nvl(vt_tab_csf_inventario(i).dt_ref,vt_tab_csf_inventario(i).dt_inventario) > vd_dt_ult_fecha then
            --
            vn_fase := 4.1;
            --
            pk_csf_api_inv.gt_row_inventario := null;
            --
            pk_csf_api_inv.gt_row_inventario.dt_inventario  := vt_tab_csf_inventario(i).dt_inventario;
            pk_csf_api_inv.gt_row_inventario.qtde           := vt_tab_csf_inventario(i).qtde;
            pk_csf_api_inv.gt_row_inventario.vl_unit        := vt_tab_csf_inventario(i).vl_unit;
            pk_csf_api_inv.gt_row_inventario.vl_item        := vt_tab_csf_inventario(i).vl_item;
            pk_csf_api_inv.gt_row_inventario.dm_ind_prop    := vt_tab_csf_inventario(i).dm_ind_prop;
            pk_csf_api_inv.gt_row_inventario.txt_compl      := vt_tab_csf_inventario(i).txt_compl;
            pk_csf_api_inv.gt_row_inventario.cod_cta        := vt_tab_csf_inventario(i).cod_cta;
            pk_csf_api_inv.gt_row_inventario.dm_st_integra  := 7; -- Integração por view de banco de dados
            pk_csf_api_inv.gt_row_inventario.dt_ref         := vt_tab_csf_inventario(i).dt_ref;
            pk_csf_api_inv.gt_row_inventario.dm_mot_inv     := vt_tab_csf_inventario(i).dm_mot_inv;
            --
            vn_fase := 4.2;
            --
            pk_csf_api_inv.pkb_integr_inventario ( est_log_generico  => vt_log_generico
                                                 , est_inventario    => pk_csf_api_inv.gt_row_inventario
                                                 , ev_cpf_cnpj       => vt_tab_csf_inventario(i).cpf_cnpj
                                                 , ev_cod_item       => vt_tab_csf_inventario(i).cod_item
                                                 , ev_sigla_unid     => vt_tab_csf_inventario(i).sigla_unid
                                                 , ev_cod_part       => vt_tab_csf_inventario(i).cod_part
                                                 , en_multorg_id     => vn_multorg_id
                                                 );
            --
            vn_fase := 4.3;
            --
            pkb_inventario_ff ( est_log_generico  => vt_log_generico
                              , en_inventario_id  => pk_csf_api_inv.gt_row_inventario.id
                              , ev_cpf_cnpj       => vt_tab_csf_inventario(i).cpf_cnpj
                              , ev_cod_item       => vt_tab_csf_inventario(i).cod_item
                              , ed_dt_inventario  => vt_tab_csf_inventario(i).dt_inventario
                              );
            --
            vn_fase := 4.4;
            --
            pkb_invent_cst ( est_log_generico  => vt_log_generico
                           , en_inventario_id  => pk_csf_api_inv.gt_row_inventario.id
                           , ev_cpf_cnpj       => vt_tab_csf_inventario(i).cpf_cnpj
                           , ev_cod_item       => vt_tab_csf_inventario(i).cod_item
                           , ed_dt_inventario  => vt_tab_csf_inventario(i).dt_inventario
                           );
            --
            if nvl(vt_log_generico.count,0) > 0 and
               pk_csf_api_inv.fkg_ver_erro_log_generico_inv( en_referencia_id => gn_referencia_id ) = 1 then  -- 0-só advertencia / 1-erro			
               --
               update inventario set dm_st_proc = 2 -- Erro de Validacao
                where id = pk_csf_api_inv.gt_row_inventario.id;
               --
            else
               --
               update inventario set dm_st_proc = 1 -- Validado
                where id = pk_csf_api_inv.gt_row_inventario.id;
               --
            end if;
            --
            -- Calcula a quantidade de registros integrados com sucesso
            -- e com erro para ser mostrado na tela de agendamento.
            --
            begin
               --
               -- (IF) bloqueado para somar a quantidade de registros com erro ou com sucesso  			    
               --if pk_agend_integr.gvtn_qtd_total(gv_cd_obj) >
               --   (pk_agend_integr.gvtn_qtd_erro(gv_cd_obj) + pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj)) then
                  --
                  if nvl(vt_log_generico.count,0) > 0 and
                     pk_csf_api_inv.fkg_ver_erro_log_generico_inv( en_referencia_id => gn_referencia_id ) = 1 then  -- 0-só advertencia / 1-erro							  
                     --
                     pk_agend_integr.gvtn_qtd_erro(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erro(gv_cd_obj),0) + 1;
                     --
                  else
                     --
                     pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj),0) + 1;
                     --
                  end if;
                  --
               --end if;
               --
            exception
               when others then
               null;
            end;
            --
         else
            --
            vn_fase := 4.5;
            -- Gerar log no agendamento devido a data de fechamento
            --
            info_fechamento := pk_csf.fkg_retorna_csftipolog_id(ev_cd => 'INFO_FECHAMENTO');
            --
            declare
               vn_loggenerico_id  log_generico_inv.id%type;
            begin
               pk_csf_api_inv.pkb_log_generico_inv ( sn_loggenericoinv_id => vn_loggenerico_id
                                                   , ev_mensagem          => 'Integração do Inventário'
                                                   , ev_resumo            => 'Período informado para integração do inventário não permitido devido a data de '||
                                                                             'fechamento fiscal '||to_char(vd_dt_ult_fecha,'dd/mm/yyyy')||' - CNPJ/CPF: '||
                                                                             vt_tab_csf_inventario(i).cpf_cnpj||', Código do item: '||vt_tab_csf_inventario(i).cod_item||
                                                                             ', Data de referência: '||vt_tab_csf_inventario(i).dt_ref||'.'
                                                   , en_tipo_log          => info_fechamento
                                                   , en_referencia_id     => null
                                                   , ev_obj_referencia    => gv_obj_referencia 
                                                   , en_empresa_id        => gn_empresa_id
                                                   );
            exception
               when others then
                  null;
            end;
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
      gv_mensagem_log := 'Erro na pk_int_view_inv.pkb_inventario fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenericoinv_id  Log_Generico_inv.id%TYPE;
      begin
         --
         pk_csf_api_inv.pkb_log_generico_inv ( sn_loggenericoinv_id  => vn_loggenericoinv_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => pk_csf_api_inv.gt_row_inventario.id
                                     , ev_obj_referencia  => gv_obj_referencia
                                     , en_empresa_id      => gn_empresa_id 
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_inventario;

-------------------------------------------------------------------------------------------------------

-- executa procedure softfacil
procedure pkb_softfacil ( ev_cpf_cnpj in varchar2
                        , ed_dt_ini   in date
                        , ed_dt_fin   in date )
is
   --
   vn_fase number := 0;
   vv_cod_matriz empresa.cod_matriz%type;
   vv_cod_filial empresa.cod_filial%type;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'PB_IN_REGISTRO_INVENTARIO_TEMP') = 0 then
      --
      return;
      --
   end if;
   --
   if length(ev_cpf_cnpj) in (11, 14) then
      --
      vn_fase := 2;
      --
      begin
         --
         select cod_matriz
              , cod_filial
           into vv_cod_matriz
              , vv_cod_filial
           from empresa
          where id = pk_csf.fkg_empresa_id_pelo_cpf_cnpj(gn_multorg_id, ev_cpf_cnpj);
         --
      exception
         when others then
            vv_cod_matriz := null;
            vv_cod_filial := null;
      end;
      --
      vn_fase := 3;
	  --
      if trim(vv_cod_matriz) is not null
         and trim(vv_cod_filial) is not null then
         --
         gv_sql := 'begin PB_IN_REGISTRO_INVENTARIO_TEMP(' ||
                              vv_cod_matriz || ', ' ||
                              vv_cod_filial || ', ' ||
                              '''' || to_date(ed_dt_ini, GV_FORMATO_DT_ERP) || '''' || ', ' ||
                              '''' || to_date(ed_dt_fin, GV_FORMATO_DT_ERP) || '''' || ' ); end;';
         --
         begin
            --
            execute immediate gv_sql;
            --
         exception
            when others then
               -- não registra erro casa a view não exista
               if sqlcode = -942 then
                  null;
               else
                  --
                  gv_mensagem_log := 'Erro na pk_int_view_inv.pkb_softfacil fase(' || vn_fase || '):' || sqlerrm;
                  --
                  declare
                     vn_loggenericoinv_id  Log_Generico_inv.id%TYPE;
                  begin
                     --
                     pk_csf_api_inv.pkb_log_generico_inv ( sn_loggenericoinv_id  => vn_loggenericoinv_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => null
                                     , ev_obj_referencia  => gv_obj_referencia
                                     , en_empresa_id      => gn_empresa_id
                                     );
                     --
                  exception
                     when others then
                        null;
                  end;
                  --
                  raise_application_error (-20101, gv_mensagem_log);
               --
               end if;
         end;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_inv.pkb_softfacil fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenericoinv_id  Log_Generico_inv.id%TYPE;
      begin
         --
         pk_csf_api_inv.pkb_log_generico_inv ( sn_loggenericoinv_id  => vn_loggenericoinv_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => null
                                     , ev_obj_referencia  => gv_obj_referencia
                                     , en_empresa_id      => gn_empresa_id
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_softfacil;

-------------------------------------------------------------------------------------------------------

-- executa procedure Stafe
procedure pkb_stafe ( ev_cpf_cnpj in varchar2
                    , ed_dt_ini   in date
                    , ed_dt_fin   in date
                    )
is
   --
   vn_fase number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'PK_INT_INV_STAFE_CSF') = 0 then
      --
      return;
      --
   end if;
   --
   if length(ev_cpf_cnpj) in (11, 14) then
      --
      vn_fase := 2;
      --
      gv_sql := 'begin PK_INT_INV_STAFE_CSF.PB_GERA(' ||
                           ev_cpf_cnpj || ', ' ||
                           '''' || to_date(ed_dt_ini, gv_formato_dt_erp) || '''' || ', ' ||
                           '''' || to_date(ed_dt_fin, gv_formato_dt_erp) || '''' || ' ); end;';
      --
      begin
         --
         execute immediate gv_sql;
         --
      exception
         when others then
            -- não registra erro casa a view não exista
            if sqlcode = -942 then
               null;
            else
               --
               pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_stafe fase(' || vn_fase || '):' || sqlerrm;
               --
               declare
                  vn_loggenerico_id  Log_Generico.id%TYPE;
               begin
                  --
                  pk_csf_api_inv.pkb_log_generico_inv ( sn_loggenericoinv_id  => vn_loggenerico_id
                                                    , ev_mensagem        => pk_csf_api_ecd.gv_mensagem_log
                                                    , ev_resumo          => pk_csf_api_ecd.gv_mensagem_log
                                                    , en_tipo_log        => pk_csf_api_ecd.ERRO_DE_SISTEMA
                                                    , en_referencia_id   => null
                                                    , ev_obj_referencia  => pk_csf_api_ecd.gv_obj_referencia
                                                    , en_empresa_id      => gn_empresa_id
                                                    );
                  --
               exception
                  when others then
                     null;
               end;
               --
               --raise_application_error (-20101, gv_mensagem_log);
               --
            end if;
      end;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pkb_stafe fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_csf_api_inv.pkb_log_generico_inv ( sn_loggenericoinv_id  => vn_loggenerico_id
                                           , ev_mensagem        => pk_csf_api_ecd.gv_mensagem_log
                                           , ev_resumo          => pk_csf_api_ecd.gv_mensagem_log
                                           , en_tipo_log        => pk_csf_api_ecd.ERRO_DE_SISTEMA
                                           , en_referencia_id   => null
                                           , ev_obj_referencia  => pk_csf_api_ecd.gv_obj_referencia
                                           , en_empresa_id      => gn_empresa_id
                                           );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_stafe;

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração de cadastros
procedure pkb_integracao ( en_empresa_id  in  empresa.id%type
                         , ed_dt_ini      in  date
                         , ed_dt_fin      in  date )
is
   --
   vn_fase         number := 0;
   vd_dt_ult_fecha fecha_fiscal_empresa.dt_ult_fecha%type;
   vv_cpf_cnpj_emit varchar2(14);
   --
   cursor c_empr is
   select e.id empresa_id
        , e.dt_ini_integr
        , eib.owner_obj
        , eib.nome_dblink
        , eib.dm_util_aspa
        , eib.dm_ret_infor_integr
        , nvl(trim(eib.formato_dt_erp), gv_formato_data) formato_dt_erp
        , eib.dm_form_dt_erp
     from empresa e
        , empresa_integr_banco eib
    where e.id             = en_empresa_id
      and e.dm_tipo_integr in (3, 4) -- Integração por view
      and e.dm_situacao    = 1 -- Ativa
      and eib.empresa_id   = e.id
    order by 1;
   --
begin
   -- Inicia os contadores de registros a serem integrados
   pk_agend_integr.pkb_inicia_cont(ev_cd_obj => gv_cd_obj);
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   vn_fase := 1;
   -- Busca o CPF/CNPJ da empresa
   gv_cpf_cnpj := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => en_empresa_id );
   --
   vn_fase := 1.1;
   --
   gn_multorg_id := pk_csf.fkg_multorg_id_empresa ( en_empresa_id => en_empresa_id );
   --
   gn_empresa_id := en_empresa_id;
   --
   vn_fase := 1.2;
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 2;
      --
      commit;
      --
      vn_fase := 2.1;
      -- Se ta o DBLink
      gv_nome_dblink    := rec.nome_dblink;
      gv_formato_dt_erp := rec.formato_dt_erp;
      gv_owner_obj      := rec.owner_obj;
      --
      vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => rec.empresa_id );
      --
      vn_fase := 3;
      -- Verifica se utiliza GV_ASPAS dupla
      if rec.dm_util_aspa = 1 then
         --
         gv_aspas := '"';
         --
      else
         --
         gv_aspas := null;
         --
      end if;
      --
      vn_fase := 4;
      -- executa procedure Softfacil
      pkb_softfacil ( ev_cpf_cnpj => gv_cpf_cnpj
                    , ed_dt_ini   => ed_dt_ini
                    , ed_dt_fin   => ed_dt_fin
                    );
      --
      vn_fase := 4.1;
      --
      pkb_stafe ( ev_cpf_cnpj => vv_cpf_cnpj_emit
                , ed_dt_ini   => ed_dt_ini
                , ed_dt_fin   => ed_dt_fin
                );
      --
      vn_fase := 5;
      --
      pkb_inventario ( ev_cpf_cnpj => gv_cpf_cnpj
                     , ed_dt_ini   => ed_dt_ini
                     , ed_dt_fin   => ed_dt_fin
                     );
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_inv.pkb_integracao fase(' || vn_fase || ') CNPJ/CPF(' || gv_cpf_cnpj || '):' || sqlerrm;
      --
      declare
         vn_loggenericoinv_id  Log_Generico_inv.id%TYPE;
      begin
         --
         pk_csf_api_inv.pkb_log_generico_inv ( sn_loggenericoinv_id  => vn_loggenericoinv_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_empresa_id      => gn_empresa_id
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integracao;

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração de cadastros
procedure pkb_integracao_normal ( ed_dt_ini      in  date
                                , ed_dt_fin      in  date 
                                )
is
   --
   vn_fase         number := 0;
   --
   cursor c_empr is
   select e.id empresa_id
     from empresa e
    where e.dm_tipo_integr in (3, 4) -- Integração por view
      and e.dm_situacao    = 1 -- Ativa
    order by 1;
   --
begin
   --
   vn_fase := 1;
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 2;
      --
      pkb_integracao ( en_empresa_id  => rec.empresa_id
                     , ed_dt_ini      => ed_dt_ini
                     , ed_dt_fin      => ed_dt_fin
                     );
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_inv.pkb_integracao_normal fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenericoinv_id  Log_Generico_inv.id%TYPE;
      begin
         --
         pk_csf_api_inv.pkb_log_generico_inv ( sn_loggenericoinv_id  => vn_loggenericoinv_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA 
                                     , en_empresa_id      => gn_empresa_id
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integracao_normal;

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração por período
procedure pkb_integr_periodo_geral ( en_multorg_id in mult_org.id%type
                                   , ed_dt_ini     in date
                                   , ed_dt_fin     in date
                                   )
is
   --
   vn_fase              number := 0;
   vv_cpf_cpf_cnpj_emit varchar2(14);
   vd_dt_ult_fecha      fecha_fiscal_empresa.dt_ult_fecha%type;
   --
   cursor c_empr is
   select e.id empresa_id
        , e.dt_ini_integr
        , e.multorg_id
        , eib.owner_obj
        , eib.nome_dblink
        , eib.dm_util_aspa
        , eib.dm_ret_infor_integr
        , eib.formato_dt_erp
        , eib.dm_form_dt_erp
     from empresa e
        , empresa_integr_banco eib
    where e.multorg_id      = en_multorg_id
      and e.dm_situacao     = 1 -- Ativo
      and e.dm_tipo_integr in (3, 4) -- Integração por view
      and eib.empresa_id    = e.id
    order by 1;
   --
begin
   --
   vn_fase := 1;
   -- Inicia os contadores de registros a serem integrados
   pk_agend_integr.pkb_inicia_cont(ev_cd_obj => gv_cd_obj);
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   vn_fase := 1.1;
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 2;
      --
      commit;
      --
      vn_fase := 2.1;
      --
      -- Se ta o DBLink
      GV_NOME_DBLINK := rec.nome_dblink;
      GV_OWNER_OBJ   := rec.owner_obj;
      --
      -- Verifica se utiliza GV_ASPAS dupla
      if rec.dm_util_aspa = 1 then
         --
         GV_ASPAS := '"';
         --
      else
         --
         GV_ASPAS := null;
         --
      end if;
      --  Seta formata da data para os procedimentos de retorno
      if trim(rec.formato_dt_erp) is not null then
         gv_formato_dt_erp := rec.formato_dt_erp;
      else
         gv_formato_dt_erp := gv_formato_data;
      end if;
      --
      vn_fase := 1.3;
      --
      gn_multorg_id := rec.multorg_id;
      --
      gn_empresa_id := rec.empresa_id;
      --
      vn_fase := 3;
      --
      vv_cpf_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => rec.empresa_id );
      --
      vn_fase := 3.1;
      --
      pkb_stafe ( ev_cpf_cnpj => vv_cpf_cpf_cnpj_emit
                , ed_dt_ini   => ed_dt_ini
                , ed_dt_fin   => ed_dt_fin
                );
      --
      vn_fase := 4;
      --
      pkb_inventario ( ev_cpf_cnpj => vv_cpf_cpf_cnpj_emit
                     , ed_dt_ini   => ed_dt_ini
                     , ed_dt_fin   => ed_dt_fin );
      --
      vn_fase := 5;
      --
      commit;
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_inv.pkb_integr_periodo_geral fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenericoinv_id  Log_Generico_inv.id%TYPE;
      begin
         --
         pk_csf_api_inv.pkb_log_generico_inv ( sn_loggenericoinv_id  => vn_loggenericoinv_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_empresa_id      => gn_empresa_id 
                                     );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_periodo_geral;

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração Geral de empresas para o Inventário
procedure pkb_integr_geral_empresa ( en_paramintegrdados_id in param_integr_dados.id%type
                                   , ed_dt_ini              in date
                                   , ed_dt_fin              in date
                                   , en_empresa_id          in empresa.id%type
                                   )
is
   --
   vn_fase              number := 0;
   vv_cpf_cpf_cnpj_emit varchar2(14);
   vd_dt_ult_fecha      fecha_fiscal_empresa.dt_ult_fecha%type;
   --
   cursor c_empr is
   select p.*
     from param_integr_dados_empresa p
        , empresa e
    where p.paramintegrdados_id = en_paramintegrdados_id
      and p.empresa_id          = nvl(en_empresa_id, p.empresa_id)
      and e.id = p.empresa_id
      and e.dm_situacao = 1 -- Ativo
    order by 1;
   --
begin
   --
   vn_fase := 1;
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 2;
      --
      gv_nome_dblink    := null;
      gv_owner_obj      := null;
      gv_aspas          := null;
      gv_formato_dt_erp := gv_formato_data;
      gn_empresa_id     := rec.empresa_id;
      --
      vn_fase := 3;
      --
      vv_cpf_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => rec.empresa_id );
      --
      vn_fase := 3.1;
      --
      gn_multorg_id := pk_csf.fkg_multorg_id_empresa ( en_empresa_id => rec.empresa_id );
      --
      vn_fase := 4;
      --
      pkb_inventario ( ev_cpf_cnpj => vv_cpf_cpf_cnpj_emit
                     , ed_dt_ini   => ed_dt_ini
                     , ed_dt_fin   => ed_dt_fin );
      --
      vn_fase := 5;
      --
      commit;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pk_int_view_inv.pkb_integr_geral_empresa fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenericoinv_id  Log_Generico_inv.id%TYPE;
      begin
         --
         pk_csf_api_inv.pkb_log_generico_inv ( sn_loggenericoinv_id  => vn_loggenericoinv_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_empresa_id      => gn_empresa_id
                                     );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_geral_empresa;

-------------------------------------------------------------------------------------------------------

end pk_int_view_inv;
/
