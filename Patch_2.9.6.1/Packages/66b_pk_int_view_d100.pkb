create or replace package body csf_own.pk_int_view_d100 is

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
--
-------------------------------------------------------------------------------------------------------
--| Procedimento de integração do complemento da operação de COFINS - Campos Flex Field
-------------------------------------------------------------------------------------------------------
procedure pkb_ct_imp_ret_efd_ff ( est_log_generico      in out nocopy dbms_sql.number_table
                                , en_ctimpretefd_id     in            conhec_transp_imp_ret.id%type
                                , ev_cpf_cnpj_emit      in            varchar2
                                , en_dm_ind_emit        in            conhec_transp.dm_ind_emit%type
                                , en_dm_ind_oper        in            conhec_transp.dm_ind_oper%type
                                , ev_cod_part           in            pessoa.cod_part%type
                                , ev_cod_mod            in            mod_fiscal.cod_mod%type
                                , ev_serie              in            conhec_transp.serie%type
                                , ev_subserie           in            conhec_transp.subserie%type
                                , en_nro_nf             in            conhec_transp.nro_ct%type
                                , ev_cod_imposto        in            tipo_imposto.cd%type
                                ) is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_ct.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_CT_IMP_RET_EFD_FF') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_ctimpretefd_ff.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         trim(GV_ASPAS) || 'CPF_CNPJ_EMIT'  || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT'    || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER'    || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_MOD'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SUBSERIE'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_IMPOSTO'    || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ATRIBUTO'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VALOR'          || trim(GV_ASPAS);
   --
   vn_fase := 2;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_CT_IMP_RET_EFD_FF' );
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT'   || trim(GV_ASPAS) || ' = ' || '''' || en_dm_ind_emit   || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER'   || trim(GV_ASPAS) || ' = ' || '''' || en_dm_ind_oper   || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART'      || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part      || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_MOD'       || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_mod       || '''';
   --
   if trim(ev_serie) is not null then
      gv_sql := gv_sql || ' and pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ' || ' = ' || '''' || ev_serie || '''';
   end if;
   --
   if trim(ev_subserie) is not null then
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS) || ' = ' || '''' || ev_subserie || '''';
   end if;
   --
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF'      || trim(GV_ASPAS) || ' = ' || '''' || en_nro_nf      || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_IMPOSTO' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_imposto || '''';
   --
   vn_fase := 3;
   --
   -- recupera o complemento dos impostos Retidos - Campos Flex Field
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_ctimpretefd_ff;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ct_imp_ret_efd_ff fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_ct.id%type;
            begin
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                                 , ev_mensagem       => gv_mensagem_log
                                                 , ev_resumo         => gv_mensagem_log
                                                 , en_tipo_log       => erro_de_sistema
                                                 , en_referencia_id  => null
                                                 , ev_obj_referencia => gv_obj_referencia );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 4;
   --
   if nvl(vt_tab_csf_ctimpretefd_ff.count,0) > 0 then
      --
      vn_fase := 5;
      --
      for i in vt_tab_csf_ctimpretefd_ff.first .. vt_tab_csf_ctimpretefd_ff.last loop
         --
         vn_fase := 6;
         --
         pk_csf_api_d100.pkb_integr_ctimpretefd_ff ( est_log_generico      => est_log_generico
                                                   , en_ctimpretefd_id     => en_ctimpretefd_id   
                                                   , ev_atributo           => vt_tab_csf_ctimpretefd_ff(i).atributo
                                                   , ev_valor              => vt_tab_csf_ctimpretefd_ff(i).valor
                                                   , en_multorg_id         => gn_multorg_id );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ct_imp_ret_efd_ff fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%type;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                     , ev_mensagem       => gv_mensagem_log
                                     , ev_resumo         => gv_mensagem_log
                                     , en_tipo_log       => erro_de_sistema
                                     , en_referencia_id  => null
                                     , ev_obj_referencia => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ct_imp_ret_efd_ff;
--
-------------------------------------------------------------------------------------------------------
--| Procedimento de integração dos Impostos Retidos para CTE
-------------------------------------------------------------------------------------------------------
procedure pkb_ct_imp_ret_efd ( est_log_generico   in out nocopy dbms_sql.number_table
                             , ev_cpf_cnpj_emit   in            varchar2
                             , en_dm_ind_emit     in            conhec_transp.dm_ind_emit%type
                             , en_dm_ind_oper     in            conhec_transp.dm_ind_oper%type
                             , ev_cod_part        in            pessoa.cod_part%type
                             , ev_cod_mod         in            mod_fiscal.cod_mod%type
                             , ev_serie           in            conhec_transp.serie%type
                             , ev_subserie        in            conhec_transp.subserie%type
                             , en_nro_nf          in            conhec_transp.nro_ct%type
                             , en_conhectransp_id in            conhec_transp.id%type
                             ) is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_ct.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_CT_IMP_RET_EFD') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_ctimpretefd.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         trim(GV_ASPAS) || 'CPF_CNPJ_EMIT'   || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT'     || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER'     || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_MOD'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SUBSERIE'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF'          || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_IMPOSTO'     || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CD_TIPO_RET_IMP' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_RECEITA'     || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_ITEM'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_BASE_CALC'    || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_ALIQ'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_IMP'          || trim(GV_ASPAS);
   --
   vn_fase := 2;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_CT_IMP_RET_EFD' );
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT'   || trim(GV_ASPAS) || ' = ' || '''' || en_dm_ind_emit   || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER'   || trim(GV_ASPAS) || ' = ' || '''' || en_dm_ind_oper   || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART'      || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part      || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_MOD'       || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_mod       || '''';
   --
   if trim(ev_serie) is not null then
      gv_sql := gv_sql || ' and pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ' || ' = ' || '''' || ev_serie || '''';
   end if;
   --
   if trim(ev_subserie) is not null then
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS) || ' = ' || '''' || ev_subserie || '''';
   end if;
   --
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS) || ' = ' || '''' || en_nro_nf || '''';
   --
   vn_fase := 3;
   -- recupera os impostos retidos
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_ctimpretefd;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ct_imp_ret_efd fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_ct.id%type;
            begin
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                                 , ev_mensagem       => gv_mensagem_log
                                                 , ev_resumo         => gv_mensagem_log
                                                 , en_tipo_log       => erro_de_sistema
                                                 , en_referencia_id  => null
                                                 , ev_obj_referencia => gv_obj_referencia );
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
   vn_fase := 4;
   --
   if nvl(vt_tab_csf_ctimpretefd.count,0) > 0 then
      --
      vn_fase := 5;
      --
      for i in vt_tab_csf_ctimpretefd.first .. vt_tab_csf_ctimpretefd.last loop
         --
         vn_fase := 6;
         --
         pk_csf_api_d100.gt_row_ct_impretefd := null;
         --
         vn_fase := 7;
         --
         pk_csf_api_d100.gt_row_ct_impretefd.conhectransp_id := en_conhectransp_id;
         pk_csf_api_d100.gt_row_ct_impretefd.vl_item      := vt_tab_csf_ctimpretefd(i).vl_item;
         pk_csf_api_d100.gt_row_ct_impretefd.vl_base_calc := vt_tab_csf_ctimpretefd(i).vl_base_calc;
         pk_csf_api_d100.gt_row_ct_impretefd.vl_aliq      := vt_tab_csf_ctimpretefd(i).vl_aliq;
         pk_csf_api_d100.gt_row_ct_impretefd.vl_imp       := vt_tab_csf_ctimpretefd(i).vl_imp;
         --
         vn_fase := 8;
         --
         pk_csf_api_d100.pkb_integr_ctimpretefd ( est_log_generico        => est_log_generico
                                                , est_ctimpretefd         => pk_csf_api_d100.gt_row_ct_impretefd
                                                , ev_cpf_cnpj_emit        => ev_cpf_cnpj_emit
                                                , ev_cod_imposto          => trim(vt_tab_csf_ctimpretefd(i).cod_imposto)
                                                , ev_cd_tipo_ret_imp      => trim(vt_tab_csf_ctimpretefd(i).cd_tipo_ret_imp)
                                                , ev_cod_receita          => trim(vt_tab_csf_ctimpretefd(i).cod_receita)
                                                , en_multorg_id           => gn_multorg_id );
         --
         vn_fase := 9;
         -- Leitura de informações do imposto retidos dos conhecimentos de transporte - campos flex field
         pkb_ct_imp_ret_efd_ff ( est_log_generico      => est_log_generico
                               , en_ctimpretefd_id     => pk_csf_api_d100.gt_row_ct_impretefd.id
                               --| parâmetros de chave
                               , ev_cpf_cnpj_emit      => ev_cpf_cnpj_emit
                               , en_dm_ind_emit        => en_dm_ind_emit
                               , en_dm_ind_oper        => en_dm_ind_oper
                               , ev_cod_part           => ev_cod_part
                               , ev_cod_mod            => ev_cod_mod
                               , ev_serie              => ev_serie
                               , ev_subserie           => ev_subserie
                               , en_nro_nf             => en_nro_nf
                               , ev_cod_imposto        => trim(vt_tab_csf_ctimpretefd(i).cod_imposto) );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ct_imp_ret_efd fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%type;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                     , ev_mensagem       => gv_mensagem_log
                                     , ev_resumo         => gv_mensagem_log
                                     , en_tipo_log       => erro_de_sistema
                                     , en_referencia_id  => null
                                     , ev_obj_referencia => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_ct_imp_ret_efd;
--
-------------------------------------------------------------------------------------------------------
--| Procedimento de integração de ajustes e de valores provenientes do CT
-------------------------------------------------------------------------------------------------------
procedure pkb_ct_inf_prov_efd ( est_log_generico    in out nocopy dbms_sql.number_table
                              , ev_cpf_cnpj_emit    in            varchar2
                              , en_dm_ind_emit      in            conhec_transp.dm_ind_emit%type
                              , en_dm_ind_oper      in            conhec_transp.dm_ind_oper%type
                              , ev_cod_part         in            pessoa.cod_part%type
                              , ev_cod_mod          in            mod_fiscal.cod_mod%type
                              , ev_serie            in            conhec_transp.serie%type
                              , ev_subserie         in            conhec_transp.subserie%type
                              , en_nro_nf           in            conhec_transp.nro_ct%type
                              , ev_cod_obs          in            varchar2
                              , en_ctinforfiscal_id in            ctinfor_fiscal.id%type
                              )
is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_ct.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_CT_INF_PROV_EFD') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_ct_inf_prov_efd.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         trim(GV_ASPAS) || 'CPF_CNPJ_EMIT'  || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT'    || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER'    || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_MOD'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SUBSERIE'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_OBS'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_AJ'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DESCR_COMPL_AJ' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_BC_ICMS'     || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ALIQ_ICMS'      || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_ICMS'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_OUTROS'      || trim(GV_ASPAS);
   --
   vn_fase := 2;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_CT_INF_PROV_EFD' );
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT'   || trim(GV_ASPAS) || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER'   || trim(GV_ASPAS) || ' = ' || en_dm_ind_oper;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART'      || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_MOD'       || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_mod || '''';
   --
   if trim(ev_serie) is not null then
      gv_sql := gv_sql || ' and pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ' || ' = ' || '''' || ev_serie || '''';
   end if;
   --
   if trim(ev_subserie) is not null then
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS) || ' = ' || ev_subserie;
   end if;
   --
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS) || ' = ' || en_nro_nf;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_OBS' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_obs || '''';
   --
   vn_fase := 3;
   -- recupera o processo referenciado
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_ct_inf_prov_efd;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ct_inf_prov_efd fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_ct.id%type;
            begin
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                           , ev_mensagem       => gv_mensagem_log
                                           , ev_resumo         => gv_mensagem_log
                                           , en_tipo_log       => erro_de_sistema
                                           , en_referencia_id  => null
                                           , ev_obj_referencia => gv_obj_referencia );
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
   vn_fase := 4;
   --
   if nvl(vt_tab_csf_ct_inf_prov_efd.count,0) > 0 then
      --
      vn_fase := 5;
      --
      for i in vt_tab_csf_ct_inf_prov_efd.first .. vt_tab_csf_ct_inf_prov_efd.last loop
         --
         vn_fase := 6;
         --
         pk_csf_api_d100.gt_row_ct_inf_prov := null;
         --
         vn_fase := 7;
         --
         pk_csf_api_d100.gt_row_ct_inf_prov.ctinforfiscal_id := en_ctinforfiscal_id;
         pk_csf_api_d100.gt_row_ct_inf_prov.descr_compl_aj   := vt_tab_csf_ct_inf_prov_efd(i).descr_compl_aj;
         pk_csf_api_d100.gt_row_ct_inf_prov.vl_bc_icms       := vt_tab_csf_ct_inf_prov_efd(i).vl_bc_icms;
         pk_csf_api_d100.gt_row_ct_inf_prov.aliq_icms        := vt_tab_csf_ct_inf_prov_efd(i).aliq_icms;
         pk_csf_api_d100.gt_row_ct_inf_prov.vl_icms          := vt_tab_csf_ct_inf_prov_efd(i).vl_icms;
         pk_csf_api_d100.gt_row_ct_inf_prov.vl_outros        := vt_tab_csf_ct_inf_prov_efd(i).vl_outros;
         --
         vn_fase := 8;
         --
         pk_csf_api_d100.pkb_integr_ct_inf_prov ( est_log_generico => est_log_generico
                                                , est_ct_inf_prov  => pk_csf_api_d100.gt_row_ct_inf_prov
                                                , ev_cod_aj        => vt_tab_csf_ct_inf_prov_efd(i).cod_aj );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ct_inf_prov_efd fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%type;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                     , ev_mensagem       => gv_mensagem_log
                                     , ev_resumo         => gv_mensagem_log
                                     , en_tipo_log       => erro_de_sistema
                                     , en_referencia_id  => null
                                     , ev_obj_referencia => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_ct_inf_prov_efd;
--
-------------------------------------------------------------------------------------------------------
--| Procedimento de integração da Informação Fiscal do CT
-------------------------------------------------------------------------------------------------------
procedure pkb_ctinfor_fiscal_efd ( est_log_generico   in out nocopy dbms_sql.number_table
                                 , ev_cpf_cnpj_emit   in            varchar2
                                 , en_dm_ind_emit     in            conhec_transp.dm_ind_emit%type
                                 , en_dm_ind_oper     in            conhec_transp.dm_ind_oper%type
                                 , ev_cod_part        in            pessoa.cod_part%type
                                 , ev_cod_mod         in            mod_fiscal.cod_mod%type
                                 , ev_serie           in            conhec_transp.serie%type
                                 , ev_subserie        in            conhec_transp.subserie%type
                                 , en_nro_nf          in            conhec_transp.nro_ct%type
                                 , en_conhectransp_id in            conhec_transp.id%type )
is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_ct.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_CTINFOR_FISCAL_EFD') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_ctinfor_fiscal_efd.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         trim(GV_ASPAS) || 'CPF_CNPJ_EMIT'  || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT'    || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER'    || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_MOD'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SUBSERIE'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_OBS'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'TXT_COMPL'      || trim(GV_ASPAS);
   --
   vn_fase := 2;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_CTINFOR_FISCAL_EFD' );
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT'   || trim(GV_ASPAS) || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER'   || trim(GV_ASPAS) || ' = ' || en_dm_ind_oper;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART'      || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_MOD'       || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_mod || '''';
   --
   if trim(ev_serie) is not null then
      gv_sql := gv_sql || ' and pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ' || ' = ' || '''' || ev_serie || '''';
   end if;
   --
   if trim(ev_subserie) is not null then
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS) || ' = ' || ev_subserie;
   end if;
   --
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS) || ' = ' || en_nro_nf;
   --
   vn_fase := 3;
   -- recupera o processo referenciado
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_ctinfor_fiscal_efd;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ctinfor_fiscal_efd fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_ct.id%type;
            begin
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                           , ev_mensagem       => gv_mensagem_log
                                           , ev_resumo         => gv_mensagem_log
                                           , en_tipo_log       => erro_de_sistema
                                           , en_referencia_id  => null
                                           , ev_obj_referencia => gv_obj_referencia );
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
   vn_fase := 4;
   --
   if nvl(vt_tab_csf_ctinfor_fiscal_efd.count,0) > 0 then
      --
      vn_fase := 5;
      --
      for i in vt_tab_csf_ctinfor_fiscal_efd.first .. vt_tab_csf_ctinfor_fiscal_efd.last loop
         --
         vn_fase := 6;
         --
         pk_csf_api_d100.gt_row_ctinfor_fiscal := null;
         --
         vn_fase := 7;
         --
         pk_csf_api_d100.gt_row_ctinfor_fiscal.conhectransp_id := en_conhectransp_id;
         pk_csf_api_d100.gt_row_ctinfor_fiscal.txt_compl       := vt_tab_csf_ctinfor_fiscal_efd(i).txt_compl;
         --
         vn_fase := 8;
         --
         pk_csf_api_d100.pkb_integr_ctinfor_fiscal ( est_log_generico   => est_log_generico
                                                   , est_ctinfor_fiscal => pk_csf_api_d100.gt_row_ctinfor_fiscal
                                                   , ev_cod_obs         => vt_tab_csf_ctinfor_fiscal_efd(i).cod_obs
                                                   , en_multorg_id      => gn_multorg_id );
         --
         vn_fase := 9;
         --
         if nvl(pk_csf_api_d100.gt_row_ctinfor_fiscal.id,0) > 0 then
            --
            pkb_ct_inf_prov_efd ( est_log_generico     =>  est_log_generico
                                , ev_cpf_cnpj_emit     =>  ev_cpf_cnpj_emit
                                , en_dm_ind_emit       =>  en_dm_ind_emit
                                , en_dm_ind_oper       =>  en_dm_ind_oper
                                , ev_cod_part          =>  ev_cod_part
                                , ev_cod_mod           =>  ev_cod_mod
                                , ev_serie             =>  ev_serie
                                , ev_subserie          =>  ev_subserie
                                , en_nro_nf            =>  en_nro_nf
                                , ev_cod_obs           =>  vt_tab_csf_ctinfor_fiscal_efd(i).cod_obs
                                , en_ctinforfiscal_id  =>  pk_csf_api_d100.gt_row_ctinfor_fiscal.id
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
      gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ctinfor_fiscal_efd fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%type;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                     , ev_mensagem       => gv_mensagem_log
                                     , ev_resumo         => gv_mensagem_log
                                     , en_tipo_log       => erro_de_sistema
                                     , en_referencia_id  => null
                                     , ev_obj_referencia => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_ctinfor_fiscal_efd;
--
-------------------------------------------------------------------------------------------------------
--| Procedimento de integração do processo referenciado
-------------------------------------------------------------------------------------------------------
procedure pkb_ct_proc_ref_efd ( est_log_generico   in out nocopy dbms_sql.number_table
                              , ev_cpf_cnpj_emit   in            varchar2
                              , en_dm_ind_emit     in            conhec_transp.dm_ind_emit%type
                              , en_dm_ind_oper     in            conhec_transp.dm_ind_oper%type
                              , ev_cod_part        in            pessoa.cod_part%type
                              , ev_cod_mod         in            mod_fiscal.cod_mod%type
                              , ev_serie           in            conhec_transp.serie%type
                              , ev_subserie        in            conhec_transp.subserie%type
                              , en_nro_nf          in            conhec_transp.nro_ct%type
                              , en_conhectransp_id in            conhec_transp.id%type )
is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_ct.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_CT_PROC_REF_EFD') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_ctprocrefefd.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         trim(GV_ASPAS) || 'CPF_CNPJ_EMIT'  || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT'    || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER'    || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_MOD'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SUBSERIE'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NUM_PROC'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ORIG_PROC'      || trim(GV_ASPAS);
   --
   vn_fase := 2;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_CT_PROC_REF_EFD' );
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT'   || trim(GV_ASPAS) || ' = ' || '''' || en_dm_ind_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER'   || trim(GV_ASPAS) || ' = ' || '''' || en_dm_ind_oper || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART'      || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_MOD'       || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_mod || '''';
   --
   if trim(ev_serie) is not null then
      gv_sql := gv_sql || ' and pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ' || ' = ' || '''' || ev_serie || '''';
   end if;
   --
   if trim(ev_subserie) is not null then
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS) || ' = ' || '''' || ev_subserie || '''';
   end if;
   --
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS) || ' = ' || '''' || en_nro_nf || '''';
   --
   vn_fase := 3;
   -- recupera o processo referenciado
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_ctprocrefefd;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ct_proc_ref_efd fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_ct.id%type;
            begin
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                           , ev_mensagem       => gv_mensagem_log
                                           , ev_resumo         => gv_mensagem_log
                                           , en_tipo_log       => erro_de_sistema
                                           , en_referencia_id  => null
                                           , ev_obj_referencia => gv_obj_referencia );
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
   vn_fase := 4;
   --
   if nvl(vt_tab_csf_ctprocrefefd.count,0) > 0 then
      --
      vn_fase := 5;
      --
      for i in vt_tab_csf_ctprocrefefd.first .. vt_tab_csf_ctprocrefefd.last loop
         --
         vn_fase := 6;
         --
         pk_csf_api_d100.gt_row_ct_procrefefd := null;
         --
         vn_fase := 7;
         --
         pk_csf_api_d100.gt_row_ct_procrefefd.conhectransp_id := en_conhectransp_id;
         pk_csf_api_d100.gt_row_ct_procrefefd.num_proc        := vt_tab_csf_ctprocrefefd(i).num_proc;
         --
         vn_fase := 8;
         --
         pk_csf_api_d100.pkb_integr_ctprocrefefd ( est_log_generico => est_log_generico
                                                 , est_ctprocrefefd => pk_csf_api_d100.gt_row_ct_procrefefd
                                                 , en_cd_orig_proc  => vt_tab_csf_ctprocrefefd(i).orig_proc );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ct_proc_ref_efd fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%type;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                     , ev_mensagem       => gv_mensagem_log
                                     , ev_resumo         => gv_mensagem_log
                                     , en_tipo_log       => erro_de_sistema
                                     , en_referencia_id  => null
                                     , ev_obj_referencia => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_ct_proc_ref_efd;
--
-------------------------------------------------------------------------------------------------------
--| Procedimento de integração do complemento da operação de COFINS - Campos Flex Field
-------------------------------------------------------------------------------------------------------
procedure pkb_ct_comp_doc_cofins_efd_ff ( est_log_generico      in out nocopy dbms_sql.number_table
                                        , en_ctcompdoccofins_id in            ct_comp_doc_cofins.id%type
                                        , ev_cpf_cnpj_emit      in            varchar2
                                        , en_dm_ind_emit        in            conhec_transp.dm_ind_emit%type
                                        , en_dm_ind_oper        in            conhec_transp.dm_ind_oper%type
                                        , ev_cod_part           in            pessoa.cod_part%type
                                        , ev_cod_mod            in            mod_fiscal.cod_mod%type
                                        , ev_serie              in            conhec_transp.serie%type
                                        , ev_subserie           in            conhec_transp.subserie%type
                                        , en_nro_nf             in            conhec_transp.nro_ct%type
                                        , ev_cod_st             in            cod_st.cod_st%type
                                        ) is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_ct.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_CTCOMPDOCCOFINS_EFD_FF') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_ctcompdoccofefd_ff.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         trim(GV_ASPAS) || 'CPF_CNPJ_EMIT'  || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT'    || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER'    || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_MOD'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SUBSERIE'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CST_COFINS'     || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ATRIBUTO'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VALOR'          || trim(GV_ASPAS);
   --
   vn_fase := 2;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_CTCOMPDOCCOFINS_EFD_FF' );
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT'   || trim(GV_ASPAS) || ' = ' || '''' || en_dm_ind_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER'   || trim(GV_ASPAS) || ' = ' || '''' || en_dm_ind_oper || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART'      || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_MOD'       || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_mod || '''';
   --
   if trim(ev_serie) is not null then
      gv_sql := gv_sql || ' and pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ' || ' = ' || '''' || ev_serie || '''';
   end if;
   --
   if trim(ev_subserie) is not null then
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS) || ' = ' || '''' || ev_subserie || '''';
   end if;
   --
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF'     || trim(GV_ASPAS) || ' = ' || '''' || en_nro_nf || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'CST_COFINS' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_st || '''';
   --
   vn_fase := 3;
   --
   -- recupera o complemento da operação de COFINS - Campos Flex Field
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_ctcompdoccofefd_ff;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ct_comp_doc_cofins_efd_ff fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_ct.id%type;
            begin
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                           , ev_mensagem       => gv_mensagem_log
                                           , ev_resumo         => gv_mensagem_log
                                           , en_tipo_log       => erro_de_sistema
                                           , en_referencia_id  => null
                                           , ev_obj_referencia => gv_obj_referencia );
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
   vn_fase := 4;
   --
   if nvl(vt_tab_csf_ctcompdoccofefd_ff.count,0) > 0 then
      --
      vn_fase := 5;
      --
      for i in vt_tab_csf_ctcompdoccofefd_ff.first .. vt_tab_csf_ctcompdoccofefd_ff.last loop
         --
         vn_fase := 6;
         --
         pk_csf_api_d100.pkb_integr_ctcompdoccofefd_ff ( est_log_generico      => est_log_generico
                                                       , en_ctcompdoccofins_id => en_ctcompdoccofins_id
                                                       , ev_atributo           => vt_tab_csf_ctcompdoccofefd_ff(i).atributo
                                                       , ev_valor              => vt_tab_csf_ctcompdoccofefd_ff(i).valor
                                                       , en_multorg_id         => gn_multorg_id );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ct_comp_doc_cofins_efd_ff fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%type;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                     , ev_mensagem       => gv_mensagem_log
                                     , ev_resumo         => gv_mensagem_log
                                     , en_tipo_log       => erro_de_sistema
                                     , en_referencia_id  => null
                                     , ev_obj_referencia => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_ct_comp_doc_cofins_efd_ff;
--
-------------------------------------------------------------------------------------------------------
--| Procedimento de integração do complemento da operação de COFINS
-------------------------------------------------------------------------------------------------------
procedure pkb_ct_comp_doc_cofins_efd ( est_log_generico   in out nocopy dbms_sql.number_table
                                     , ev_cpf_cnpj_emit   in            varchar2
                                     , en_dm_ind_emit     in            conhec_transp.dm_ind_emit%type
                                     , en_dm_ind_oper     in            conhec_transp.dm_ind_oper%type
                                     , ev_cod_part        in            pessoa.cod_part%type
                                     , ev_cod_mod         in            mod_fiscal.cod_mod%type
                                     , ev_serie           in            conhec_transp.serie%type
                                     , ev_subserie        in            conhec_transp.subserie%type
                                     , en_nro_nf          in            conhec_transp.nro_ct%type
                                     , en_conhectransp_id in            conhec_transp.id%type
                                     ) is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_ct.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_CT_COMP_DOC_COFINS_EFD') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_ctcompdoc_cofinsefd.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         trim(GV_ASPAS) || 'CPF_CNPJ_EMIT'  || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT'    || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER'    || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_MOD'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SUBSERIE'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CST_COFINS'     || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_NAT_FRT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_ITEM'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_BC_CRED_PC' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_BC_COFINS'   || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ALIQ_COFINS'    || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_COFINS'      || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_CTA'        || trim(GV_ASPAS);
   --
   vn_fase := 2;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_CT_COMP_DOC_COFINS_EFD' );
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT'   || trim(GV_ASPAS) || ' = ' || '''' || en_dm_ind_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER'   || trim(GV_ASPAS) || ' = ' || '''' || en_dm_ind_oper || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART'      || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_MOD'       || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_mod || '''';
   --
   if trim(ev_serie) is not null then
      gv_sql := gv_sql || ' and pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ' || ' = ' || '''' || ev_serie || '''';
   end if;
   --
   if trim(ev_subserie) is not null then
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS) || ' = ' || '''' || ev_subserie || '''';
   end if;
   --
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS) || ' = ' || '''' || en_nro_nf || '''';
   --
   vn_fase := 3;
   -- recupera o complemento da operação de COFINS
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_ctcompdoc_cofinsefd;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ct_comp_doc_cofins_efd fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_ct.id%type;
            begin
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                           , ev_mensagem       => gv_mensagem_log
                                           , ev_resumo         => gv_mensagem_log
                                           , en_tipo_log       => erro_de_sistema
                                           , en_referencia_id  => null
                                           , ev_obj_referencia => gv_obj_referencia );
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
   vn_fase := 4;
   --
   if nvl(vt_tab_csf_ctcompdoc_cofinsefd.count,0) > 0 then
      --
      vn_fase := 5;
      --
      for i in vt_tab_csf_ctcompdoc_cofinsefd.first .. vt_tab_csf_ctcompdoc_cofinsefd.last loop
         --
         vn_fase := 6;
         --
         pk_csf_api_d100.gt_row_ct_compdoc_cofinsefd := null;
         --
         vn_fase := 7;
         --
         pk_csf_api_d100.gt_row_ct_compdoc_cofinsefd.conhectransp_id := en_conhectransp_id;
         pk_csf_api_d100.gt_row_ct_compdoc_cofinsefd.dm_ind_nat_frt  := vt_tab_csf_ctcompdoc_cofinsefd(i).dm_ind_nat_frt;
         pk_csf_api_d100.gt_row_ct_compdoc_cofinsefd.vl_item         := vt_tab_csf_ctcompdoc_cofinsefd(i).vl_item;
         pk_csf_api_d100.gt_row_ct_compdoc_cofinsefd.vl_bc_cofins    := vt_tab_csf_ctcompdoc_cofinsefd(i).vl_bc_cofins;
         pk_csf_api_d100.gt_row_ct_compdoc_cofinsefd.aliq_cofins     := vt_tab_csf_ctcompdoc_cofinsefd(i).aliq_cofins;
         pk_csf_api_d100.gt_row_ct_compdoc_cofinsefd.vl_cofins       := vt_tab_csf_ctcompdoc_cofinsefd(i).vl_cofins;
         --
         vn_fase := 8;
         --
         pk_csf_api_d100.pkb_integr_ctcompdoc_cofinsefd ( est_log_generico        => est_log_generico
                                                        , est_ctcompdoc_cofinsefd => pk_csf_api_d100.gt_row_ct_compdoc_cofinsefd
                                                        , ev_cpf_cnpj_emit        => ev_cpf_cnpj_emit
                                                        , ev_cod_st               => trim(vt_tab_csf_ctcompdoc_cofinsefd(i).cst_cofins)
                                                        , ev_cod_bc_cred_pc       => trim(vt_tab_csf_ctcompdoc_cofinsefd(i).cod_bc_cred_pc)
                                                        , ev_cod_cta              => trim(vt_tab_csf_ctcompdoc_cofinsefd(i).cod_cta)
                                                        , en_multorg_id           => gn_multorg_id );
         --
         vn_fase := 9;
         -- Leitura de informações do imposto COFINS dos conhecimentos de transporte - campos flex field
         pkb_ct_comp_doc_cofins_efd_ff ( est_log_generico      => est_log_generico
                                       , en_ctcompdoccofins_id => pk_csf_api_d100.gt_row_ct_compdoc_cofinsefd.id
                                       --| parâmetros de chave
                                       , ev_cpf_cnpj_emit      => ev_cpf_cnpj_emit
                                       , en_dm_ind_emit        => en_dm_ind_emit
                                       , en_dm_ind_oper        => en_dm_ind_oper
                                       , ev_cod_part           => ev_cod_part
                                       , ev_cod_mod            => ev_cod_mod
                                       , ev_serie              => ev_serie
                                       , ev_subserie           => ev_subserie
                                       , en_nro_nf             => en_nro_nf
                                       , ev_cod_st             => trim(vt_tab_csf_ctcompdoc_cofinsefd(i).cst_cofins) );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ct_comp_doc_cofins_efd fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%type;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                     , ev_mensagem       => gv_mensagem_log
                                     , ev_resumo         => gv_mensagem_log
                                     , en_tipo_log       => erro_de_sistema
                                     , en_referencia_id  => null
                                     , ev_obj_referencia => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_ct_comp_doc_cofins_efd;
--
-------------------------------------------------------------------------------------------------------
--| Procedimento de integração do complemento da operação de PIS/PASEP - Campos Flex Field
-------------------------------------------------------------------------------------------------------
procedure pkb_ct_comp_doc_pis_efd_ff ( est_log_generico   in out nocopy dbms_sql.number_table
                                     , en_ctcompdocpis_id in            ct_comp_doc_pis.id%type
                                     , ev_cpf_cnpj_emit   in            varchar2
                                     , en_dm_ind_emit     in            conhec_transp.dm_ind_emit%type
                                     , en_dm_ind_oper     in            conhec_transp.dm_ind_oper%type
                                     , ev_cod_part        in            pessoa.cod_part%type
                                     , ev_cod_mod         in            mod_fiscal.cod_mod%type
                                     , ev_serie           in            conhec_transp.serie%type
                                     , ev_subserie        in            conhec_transp.subserie%type
                                     , en_nro_nf          in            conhec_transp.nro_ct%type
                                     , ev_cod_st          in            cod_st.cod_st%type
                                     ) is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_ct.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_CTCOMPDOCPIS_EFD_FF') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_ctcompdocpisefd_ff.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         trim(GV_ASPAS) || 'CPF_CNPJ_EMIT'  || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT'    || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER'    || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_MOD'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SUBSERIE'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CST_PIS'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ATRIBUTO'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VALOR'          || trim(GV_ASPAS);
   --
   vn_fase := 2;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_CTCOMPDOCPIS_EFD_FF' );
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT'   || trim(GV_ASPAS) || ' = ' || '''' || en_dm_ind_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER'   || trim(GV_ASPAS) || ' = ' || '''' || en_dm_ind_oper || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART'      || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_MOD'       || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_mod || '''';
   --
   if trim(ev_serie) is not null then
      gv_sql := gv_sql || ' and pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ' || ' = ' || '''' || ev_serie || '''';
   end if;
   --
   if trim(ev_subserie) is not null then
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS) || ' = ' || '''' || ev_subserie || '''';
   end if;
   --
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF'  || trim(GV_ASPAS) || ' = ' || '''' || en_nro_nf || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'CST_PIS' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_st || '''';
   --
   vn_fase := 3;
   --
   -- recupera o complemento da operação de PIS/PASEP - Campos Flex Field
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_ctcompdocpisefd_ff;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ct_comp_doc_pis_efd_ff fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_ct.id%type;
            begin
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                           , ev_mensagem       => gv_mensagem_log
                                           , ev_resumo         => gv_mensagem_log
                                           , en_tipo_log       => erro_de_sistema
                                           , en_referencia_id  => null
                                           , ev_obj_referencia => gv_obj_referencia );
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
   vn_fase := 4;
   --
   if nvl(vt_tab_csf_ctcompdocpisefd_ff.count,0) > 0 then
      --
      vn_fase := 5;
      --
      for i in vt_tab_csf_ctcompdocpisefd_ff.first .. vt_tab_csf_ctcompdocpisefd_ff.last loop
         --
         vn_fase := 6;
         --
         pk_csf_api_d100.pkb_integr_ctcompdocpisefd_ff ( est_log_generico   => est_log_generico
                                                       , en_ctcompdocpis_id => en_ctcompdocpis_id
                                                       , ev_atributo        => vt_tab_csf_ctcompdocpisefd_ff(i).atributo
                                                       , ev_valor           => vt_tab_csf_ctcompdocpisefd_ff(i).valor
                                                       , en_multorg_id      => gn_multorg_id );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ct_comp_doc_pis_efd_ff fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%type;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                     , ev_mensagem       => gv_mensagem_log
                                     , ev_resumo         => gv_mensagem_log
                                     , en_tipo_log       => erro_de_sistema
                                     , en_referencia_id  => null
                                     , ev_obj_referencia => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_ct_comp_doc_pis_efd_ff;
--
-------------------------------------------------------------------------------------------------------
--| Procedimento de integração do complemento da operação de PIS/PASEP
-------------------------------------------------------------------------------------------------------
procedure pkb_ct_comp_doc_pis_efd ( est_log_generico   in out nocopy dbms_sql.number_table
                                  , ev_cpf_cnpj_emit   in            varchar2
                                  , en_dm_ind_emit     in            conhec_transp.dm_ind_emit%type
                                  , en_dm_ind_oper     in            conhec_transp.dm_ind_oper%type
                                  , ev_cod_part        in            pessoa.cod_part%type
                                  , ev_cod_mod         in            mod_fiscal.cod_mod%type
                                  , ev_serie           in            conhec_transp.serie%type
                                  , ev_subserie        in            conhec_transp.subserie%type
                                  , en_nro_nf          in            conhec_transp.nro_ct%type
                                  , en_conhectransp_id in            conhec_transp.id%type )
is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_ct.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_CT_COMP_DOC_PIS_EFD') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_ctcompdoc_pisefd.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         trim(GV_ASPAS) || 'CPF_CNPJ_EMIT'  || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT'    || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER'    || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_MOD'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SUBSERIE'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CST_PIS'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_NAT_FRT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_ITEM'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_BC_CRED_PC' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_BC_PIS'      || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ALIQ_PIS'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_PIS'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_CTA'        || trim(GV_ASPAS);
   --
   vn_fase := 2;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_CT_COMP_DOC_PIS_EFD' );
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT'   || trim(GV_ASPAS) || ' = ' || '''' || en_dm_ind_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER'   || trim(GV_ASPAS) || ' = ' || '''' || en_dm_ind_oper || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART'      || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_MOD'       || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_mod || '''';
   --
   if trim(ev_serie) is not null then
      gv_sql := gv_sql || ' and pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ' || ' = ' || '''' || ev_serie || '''';
   end if;
   --
   if trim(ev_subserie) is not null then
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS) || ' = ' || '''' || ev_subserie || '''';
   end if;
   --
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS) || ' = ' || '''' || en_nro_nf || '''';
   --
   vn_fase := 3;
   --
   -- recupera o complemento da operação de PIS/PASEP
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_ctcompdoc_pisefd;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ct_comp_doc_pis_efd fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_ct.id%type;
            begin
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                           , ev_mensagem       => gv_mensagem_log
                                           , ev_resumo         => gv_mensagem_log
                                           , en_tipo_log       => erro_de_sistema
                                           , en_referencia_id  => null
                                           , ev_obj_referencia => gv_obj_referencia );
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
   vn_fase := 4;
   --
   if nvl(vt_tab_csf_ctcompdoc_pisefd.count,0) > 0 then
      --
      vn_fase := 5;
      --
      for i in vt_tab_csf_ctcompdoc_pisefd.first .. vt_tab_csf_ctcompdoc_pisefd.last loop
         --
         vn_fase := 6;
         --
         pk_csf_api_d100.gt_row_ct_compdoc_pisefd := null;
         --
         vn_fase := 7;
         --
         pk_csf_api_d100.gt_row_ct_compdoc_pisefd.conhectransp_id := en_conhectransp_id;
         pk_csf_api_d100.gt_row_ct_compdoc_pisefd.dm_ind_nat_frt  := vt_tab_csf_ctcompdoc_pisefd(i).dm_ind_nat_frt;
         pk_csf_api_d100.gt_row_ct_compdoc_pisefd.vl_item         := vt_tab_csf_ctcompdoc_pisefd(i).vl_item;
         pk_csf_api_d100.gt_row_ct_compdoc_pisefd.vl_bc_pis       := vt_tab_csf_ctcompdoc_pisefd(i).vl_bc_pis;
         pk_csf_api_d100.gt_row_ct_compdoc_pisefd.aliq_pis        := vt_tab_csf_ctcompdoc_pisefd(i).aliq_pis;
         pk_csf_api_d100.gt_row_ct_compdoc_pisefd.vl_pis          := vt_tab_csf_ctcompdoc_pisefd(i).vl_pis;
         --
         vn_fase := 8;
         --
         pk_csf_api_d100.pkb_integr_ctcompdoc_pisefd ( est_log_generico     => est_log_generico
                                                     , est_ctcompdoc_pisefd => pk_csf_api_d100.gt_row_ct_compdoc_pisefd
                                                     , ev_cpf_cnpj_emit     => ev_cpf_cnpj_emit
                                                     , ev_cod_st            => trim(vt_tab_csf_ctcompdoc_pisefd(i).cst_pis)
                                                     , ev_cod_bc_cred_pc    => trim(vt_tab_csf_ctcompdoc_pisefd(i).cod_bc_cred_pc)
                                                     , ev_cod_cta           => trim(vt_tab_csf_ctcompdoc_pisefd(i).cod_cta)
                                                     , en_multorg_id        => gn_multorg_id );
         --
         vn_fase := 9;
         -- Leitura de informações do imposto PIS dos conhecimentos de transporte - campos flex field
         pkb_ct_comp_doc_pis_efd_ff ( est_log_generico   => est_log_generico
                                    , en_ctcompdocpis_id => pk_csf_api_d100.gt_row_ct_compdoc_pisefd.id
                                    --| parâmetros de chave
                                    , ev_cpf_cnpj_emit   => ev_cpf_cnpj_emit
                                    , en_dm_ind_emit     => en_dm_ind_emit
                                    , en_dm_ind_oper     => en_dm_ind_oper
                                    , ev_cod_part        => ev_cod_part
                                    , ev_cod_mod         => ev_cod_mod
                                    , ev_serie           => ev_serie
                                    , ev_subserie        => ev_subserie
                                    , en_nro_nf          => en_nro_nf
                                    , ev_cod_st          => trim(vt_tab_csf_ctcompdoc_pisefd(i).cst_pis) );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ct_comp_doc_pis_efd fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%type;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                     , ev_mensagem       => gv_mensagem_log
                                     , ev_resumo         => gv_mensagem_log
                                     , en_tipo_log       => erro_de_sistema
                                     , en_referencia_id  => null
                                     , ev_obj_referencia => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_ct_comp_doc_pis_efd;
--
-------------------------------------------------------------------------------------------------------
--| Procedimento de integração do Resumo de Impostos - Campos Flex Field
-------------------------------------------------------------------------------------------------------
procedure pkb_ct_reg_anal_ff ( est_log_generico     in out nocopy  dbms_sql.number_table
                             , en_ctreganal_id      in             ct_reg_anal.id%type
                             --| parâmetros de chave
                             , ev_cpf_cnpj_emit     in             varchar2
                             , en_dm_ind_emit       in             conhec_transp.dm_ind_emit%type     
                             , en_dm_ind_oper       in             conhec_transp.dm_ind_oper%type     
                             , ev_cod_part          in             pessoa.cod_part%type               
                             , ev_cod_mod           in             mod_fiscal.cod_mod%type            
                             , ev_serie             in             conhec_transp.serie%type           
                             , ev_subserie          in             conhec_transp.subserie%type        
                             , en_nro_nf            in             conhec_transp.nro_ct%type
                             , ev_cod_st            in             varchar2
                             , en_dm_orig_merc      in             number
                             , en_cfop              in             number
                             , en_aliq_icms         in             number )
is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_ct.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_REGCONHECTRANSP_EFD_FF') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_reg_ct_efd_ff.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_MOD' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CST_ICMS' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_ORIG_MERC' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CFOP' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ALIQ_ICMS' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ATRIBUTO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VALOR' || trim(GV_ASPAS);
   --
   vn_fase := 2;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_REGCONHECTRANSP_EFD_FF' );
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || en_dm_ind_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS) || ' = ' || '''' || en_dm_ind_oper || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_MOD' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ' || ' = ' || '''' || ev_serie || '''';
   --
   if trim(ev_subserie) is not null then
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS) || ' = ' || '''' || ev_subserie || '''';
   end if;
   --
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS) || ' = ' || '''' || en_nro_nf || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'CST_ICMS' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_st || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_ORIG_MERC' || trim(GV_ASPAS) || ' = ' || '''' || en_dm_orig_merc || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'CFOP' || trim(GV_ASPAS) || ' = ' || '''' || en_cfop || '''';
   --
   if trim(en_aliq_icms) is not null then
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'ALIQ_ICMS' || trim(GV_ASPAS) || ' = ' || '''' || en_aliq_icms || '''';
   end if;
   --
   vn_fase := 3;
   --
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_reg_ct_efd_ff;
      --
   exception
      when others then
         --
         gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ct_reg_anal_ff fase(' || vn_fase || '):' || sqlerrm;
         --
         declare
            vn_loggenerico_id  log_generico_ct.id%type;
         begin
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                        , ev_mensagem       => gv_mensagem_log
                                        , ev_resumo         => gv_mensagem_log
                                        , en_tipo_log       => erro_de_sistema
                                        , en_referencia_id  => null
                                        , ev_obj_referencia => gv_obj_referencia );
            --
         exception
            when others then
               null;
         end;
         --
         --raise_application_error (-20101, gv_mensagem_log);
         --
   end;
   --
   vn_fase := 4;
   --
   if nvl(vt_tab_csf_reg_ct_efd_ff.count,0) > 0 then
      --
      vn_fase := 5;
      --
      for i in vt_tab_csf_reg_ct_efd_ff.first .. vt_tab_csf_reg_ct_efd_ff.last loop
         --
         vn_fase := 6;
         --
         pk_csf_api_d100.pkb_integr_ct_d190_ff ( est_log_generico => est_log_generico
                                               , en_ctreganal_id  => en_ctreganal_id
                                               , ev_atributo      => vt_tab_csf_reg_ct_efd_ff(i).atributo
                                               , ev_valor         => vt_tab_csf_reg_ct_efd_ff(i).valor );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ct_reg_anal_ff fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%type;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                     , ev_mensagem       => gv_mensagem_log
                                     , ev_resumo         => gv_mensagem_log
                                     , en_tipo_log       => erro_de_sistema
                                     , en_referencia_id  => null
                                     , ev_obj_referencia => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_ct_reg_anal_ff;
--
-------------------------------------------------------------------------------------------------------
--| Procedimento de integração do Resumo de Impostos
-------------------------------------------------------------------------------------------------------
procedure pkb_ct_reg_anal ( est_log_generico          in out nocopy  dbms_sql.number_table
                          , ev_cpf_cnpj_emit          in             varchar2
                          , en_dm_ind_emit            in             conhec_transp.dm_ind_emit%type
                          , en_dm_ind_oper            in             conhec_transp.dm_ind_oper%type
                          , ev_cod_part               in             pessoa.cod_part%type
                          , ev_cod_mod                in             mod_fiscal.cod_mod%type
                          , ev_serie                  in             conhec_transp.serie%type
                          , ev_subserie               in             conhec_transp.subserie%type
                          , en_nro_nf                 in             conhec_transp.nro_ct%type
                          , en_conhectransp_id        in             conhec_transp.id%type )
is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_ct.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_REG_CONHEC_TRANSP_EFD') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_reg_ct_efd.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_MOD' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CST_ICMS' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_ORIG_MERC' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CFOP' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ALIQ_ICMS' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_OPERACAO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_BC_ICMS' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_ICMS' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_BC_ICMS_ST' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_ICMS_ST' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_RED_BC_ICMS' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_OBS' || trim(GV_ASPAS);
   --
   vn_fase := 2;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_REG_CONHEC_TRANSP_EFD' );
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || en_dm_ind_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS) || ' = ' || '''' || en_dm_ind_oper || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_MOD' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_mod || '''';
   --
   if trim(ev_serie) is not null then
      gv_sql := gv_sql || ' and pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ' || ' = ' || '''' || ev_serie || '''';
   end if;
   --
   if trim(ev_subserie) is not null then
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS) || ' = ' || '''' || ev_subserie || '''';
   end if;
   --
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS) || ' = ' || '''' || en_nro_nf || '''';
   --
   vn_fase := 3;
   --
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_reg_ct_efd;
      --
   exception
      when others then
         --
         gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ct_reg_anal fase(' || vn_fase || '):' || sqlerrm;
         --
         declare
            vn_loggenerico_id  log_generico_ct.id%type;
         begin
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                        , ev_mensagem       => gv_mensagem_log
                                        , ev_resumo         => gv_mensagem_log
                                        , en_tipo_log       => erro_de_sistema
                                        , en_referencia_id  => null
                                        , ev_obj_referencia => gv_obj_referencia );
            --
         exception
            when others then
               null;
         end;
         --
         --raise_application_error (-20101, gv_mensagem_log);
         --
   end;
   --
   vn_fase := 4;
   --
   if nvl(vt_tab_csf_reg_ct_efd.count,0) > 0 then
      --
      vn_fase := 5;
      --
      for i in vt_tab_csf_reg_ct_efd.first .. vt_tab_csf_reg_ct_efd.last loop
         --
         vn_fase := 6;
         --
         pk_csf_api_d100.gt_row_ct_reg_anal := null;
         --
         vn_fase := 7;
         --
         pk_csf_api_d100.gt_row_ct_reg_anal.conhectransp_id  := en_conhectransp_id;
         pk_csf_api_d100.gt_row_ct_reg_anal.aliq_icms        := vt_tab_csf_reg_ct_efd(i).aliq_icms;
         pk_csf_api_d100.gt_row_ct_reg_anal.dm_orig_merc     := vt_tab_csf_reg_ct_efd(i).dm_orig_merc;
         pk_csf_api_d100.gt_row_ct_reg_anal.vl_opr           := vt_tab_csf_reg_ct_efd(i).vl_operacao;
         pk_csf_api_d100.gt_row_ct_reg_anal.vl_bc_icms       := vt_tab_csf_reg_ct_efd(i).vl_bc_icms;
         pk_csf_api_d100.gt_row_ct_reg_anal.vl_icms          := vt_tab_csf_reg_ct_efd(i).vl_icms;
         pk_csf_api_d100.gt_row_ct_reg_anal.vl_red_bc        := vt_tab_csf_reg_ct_efd(i).vl_red_bc_icms;
         --
         vn_fase := 8;
         --
         pk_csf_api_d100.pkb_integr_ct_d190 ( est_log_generico => est_log_generico
                                            , est_ct_reg_anal  => pk_csf_api_d100.gt_row_ct_reg_anal
                                            , ev_cod_st        => trim(vt_tab_csf_reg_ct_efd(i).cst_icms)
                                            , en_cfop          => vt_tab_csf_reg_ct_efd(i).cfop
                                            , ev_cod_obs       => trim(vt_tab_csf_reg_ct_efd(i).cod_obs)
                                            , en_multorg_id    => gn_multorg_id );
         --
         vn_fase := 9;
         -- Leitura de informações de impostos dos conhecimentos de transporte - campos flex field
         pkb_ct_reg_anal_ff ( est_log_generico => est_log_generico
                            , en_ctreganal_id  => pk_csf_api_d100.gt_row_ct_reg_anal.id
                            --| parâmetros de chave
                            , ev_cpf_cnpj_emit => ev_cpf_cnpj_emit
                            , en_dm_ind_emit   => en_dm_ind_emit
                            , en_dm_ind_oper   => en_dm_ind_oper
                            , ev_cod_part      => ev_cod_part
                            , ev_cod_mod       => ev_cod_mod
                            , ev_serie         => ev_serie
                            , ev_subserie      => ev_subserie
                            , en_nro_nf        => en_nro_nf
                            , ev_cod_st        => trim(vt_tab_csf_reg_ct_efd(i).cst_icms)
                            , en_dm_orig_merc  => 0
                            , en_cfop          => vt_tab_csf_reg_ct_efd(i).cfop
                            , en_aliq_icms     => vt_tab_csf_reg_ct_efd(i).aliq_icms );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ct_reg_anal fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%type;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                     , ev_mensagem       => gv_mensagem_log
                                     , ev_resumo         => gv_mensagem_log
                                     , en_tipo_log       => erro_de_sistema
                                     , en_referencia_id  => null
                                     , ev_obj_referencia => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_ct_reg_anal;
--
-------------------------------------------------------------------------------------------------------
--  Procedimento de integração do emitente do conhecimento de transporte  
-------------------------------------------------------------------------------------------------------
procedure pkb_conhec_transp_emit_efd ( est_log_generico          in out nocopy  dbms_sql.number_table
                                     , ev_cpf_cnpj_emit          in             varchar2
                                     , en_dm_ind_emit            in             conhec_transp.dm_ind_emit%type
                                     , en_dm_ind_oper            in             conhec_transp.dm_ind_oper%type
                                     , ev_cod_part               in             pessoa.cod_part%type
                                     , ev_cod_mod                in             mod_fiscal.cod_mod%type
                                     , ev_serie                  in             conhec_transp.serie%type
                                     , en_nro_nf                 in             conhec_transp.nro_ct%type
                                     , en_conhectransp_id        in             conhec_transp.id%type )
is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_ct.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_CONHEC_TRANSP_EMIT_EFD') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_conhec_transp_emit.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_MOD' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_CT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'IE' || trim(GV_ASPAS);   
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NOME' || trim(GV_ASPAS);   
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NOME_FANT' || trim(GV_ASPAS);   
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'LOGRAD' || trim(GV_ASPAS); 
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO' || trim(GV_ASPAS);  
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COMPL' || trim(GV_ASPAS); 
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'BAIRRO' || trim(GV_ASPAS); 
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'IBGE_CIDADE' || trim(GV_ASPAS);	
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DESCR_CIDADE' || trim(GV_ASPAS);   
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CEP' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'UF' || trim(GV_ASPAS);  
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PAIS' || trim(GV_ASPAS);     
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DESCR_PAIS' || trim(GV_ASPAS);   
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'FONE' || trim(GV_ASPAS); 
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_SN' || trim(GV_ASPAS);   
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CNPJ' || trim(GV_ASPAS);    
   --
   vn_fase := 2;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_CONHEC_TRANSP_EMIT_EFD' );
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || en_dm_ind_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS) || ' = ' || '''' || en_dm_ind_oper || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_MOD' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_mod || '''';
   --
   if trim(ev_serie) is not null then
      gv_sql := gv_sql || ' and pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ' || ' = ' || '''' || ev_serie || '''';
   end if;
   --
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_CT' || trim(GV_ASPAS) || ' = ' || '''' || en_nro_nf || '''';
   --
   vn_fase := 3;
   --
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_conhec_transp_emit;
      --
   exception
      when others then
         --
         gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_conhec_transp_emit_efd fase(' || vn_fase || '):' || sqlerrm;
         --
         declare
            vn_loggenerico_id  log_generico_ct.id%type;
         begin
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                              , ev_mensagem       => gv_mensagem_log
                                              , ev_resumo         => gv_mensagem_log
                                              , en_tipo_log       => erro_de_sistema
                                              , en_referencia_id  => null
                                              , ev_obj_referencia => gv_obj_referencia );
            --
         exception
            when others then
               null;
         end;
         --
         --raise_application_error (-20101, gv_mensagem_log);
         --
   end;
   --
   vn_fase := 4;
   --
   if nvl(vt_tab_csf_conhec_transp_emit.count,0) > 0 then
      --
      vn_fase := 5;
      --
      for i in vt_tab_csf_conhec_transp_emit.first .. vt_tab_csf_conhec_transp_emit.last loop
         --
         vn_fase := 6;
         --
         pk_csf_api_d100.gt_row_conhec_transp_emit := null;
         --
         vn_fase := 7;
         --
         pk_csf_api_d100.gt_row_conhec_transp_emit.conhectransp_id  := en_conhectransp_id;
         pk_csf_api_d100.gt_row_conhec_transp_emit.cnpj             := vt_tab_csf_conhec_transp_emit(i).cnpj;
         pk_csf_api_d100.gt_row_conhec_transp_emit.ie               := vt_tab_csf_conhec_transp_emit(i).ie;
         pk_csf_api_d100.gt_row_conhec_transp_emit.nome             := vt_tab_csf_conhec_transp_emit(i).nome;
         pk_csf_api_d100.gt_row_conhec_transp_emit.nome_fant        := vt_tab_csf_conhec_transp_emit(i).nome_fant;
         pk_csf_api_d100.gt_row_conhec_transp_emit.lograd           := vt_tab_csf_conhec_transp_emit(i).lograd;
         pk_csf_api_d100.gt_row_conhec_transp_emit.nro              := vt_tab_csf_conhec_transp_emit(i).nro;
         pk_csf_api_d100.gt_row_conhec_transp_emit.compl            := vt_tab_csf_conhec_transp_emit(i).compl;
         pk_csf_api_d100.gt_row_conhec_transp_emit.bairro           := vt_tab_csf_conhec_transp_emit(i).bairro;
         pk_csf_api_d100.gt_row_conhec_transp_emit.ibge_cidade      := vt_tab_csf_conhec_transp_emit(i).ibge_cidade; 
         pk_csf_api_d100.gt_row_conhec_transp_emit.descr_cidade     := vt_tab_csf_conhec_transp_emit(i).descr_cidade;
         pk_csf_api_d100.gt_row_conhec_transp_emit.cep              := vt_tab_csf_conhec_transp_emit(i).cep; 
         pk_csf_api_d100.gt_row_conhec_transp_emit.uf               := vt_tab_csf_conhec_transp_emit(i).uf;
         pk_csf_api_d100.gt_row_conhec_transp_emit.cod_pais         := vt_tab_csf_conhec_transp_emit(i).cod_pais;
         pk_csf_api_d100.gt_row_conhec_transp_emit.descr_pais       := vt_tab_csf_conhec_transp_emit(i).descr_pais;
         pk_csf_api_d100.gt_row_conhec_transp_emit.fone             := vt_tab_csf_conhec_transp_emit(i).fone;
         pk_csf_api_d100.gt_row_conhec_transp_emit.dm_ind_sn        := vt_tab_csf_conhec_transp_emit(i).dm_ind_sn; 
         --
         vn_fase := 8;
         --
         -- Chama procedimento que valida as Informações do Emitente do CT
         if pk_csf_api_d100.gt_row_conhec_transp.dm_ind_emit is null and 
            en_dm_ind_emit is not null then
            pk_csf_api_d100.gt_row_conhec_transp.dm_ind_emit := en_dm_ind_emit;		    
         end if;
         --		 
         pk_csf_api_d100.pkb_integr_conhec_transp_emit ( est_log_generico           => est_log_generico
                                                       , est_row_conhec_transp_emit => pk_csf_api_d100.gt_row_conhec_transp_emit
                                                       , en_conhectransp_id         => en_conhectransp_id
                                                       , ev_cod_part                => vt_tab_csf_conhec_transp_emit(i).cod_part );		 
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_conhec_transp_emit_efd fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%type;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                           , ev_mensagem       => gv_mensagem_log
                                           , ev_resumo         => gv_mensagem_log
                                           , en_tipo_log       => erro_de_sistema
                                           , en_referencia_id  => null
                                           , ev_obj_referencia => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_conhec_transp_emit_efd;
--
-------------------------------------------------------------------------------------------------------
--| Procedimento de integração de campos Flex-Field dos Conhecimentos de Transportes
-------------------------------------------------------------------------------------------------------
procedure pkb_ler_conhec_transp_ff ( est_log_generico    in  out nocopy  dbms_sql.number_table
                                   , ev_cpf_cnpj_emit    in  varchar2
                                   , en_dm_ind_emit      in  number
                                   , en_dm_ind_oper      in  number
                                   , ev_cod_part         in  varchar2
                                   , ev_cod_mod          in  varchar2
                                   , ev_serie            in  varchar2
                                   , en_subserie         in  number
                                   , en_nro_nf           in  number
                                   , en_conhectransp_id  in  conhec_transp.id%type
                                   )
is
   --
   vn_fase               number := 0;
   vn_loggenericoct_id   log_generico_ct.id%TYPE;
   vn_pessoa_id          conhec_transp.pessoa_id%type;
   vn_dados_munic_ini    number := 0;
   vn_dados_munic_fim    number := 0;   
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_CONHEC_TRANSP_EFD_FF') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_conhec_tranp_efd_ff.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         trim(GV_ASPAS) || 'CPF_CNPJ_EMIT'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART'            || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_MOD'             || trim(GV_ASPAS);
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS      || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SUBSERIE'            || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF'              || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ATRIBUTO'            || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VALOR'               || trim(GV_ASPAS);
   --
   vn_fase := 1.1;
   -- Monta cláusula FROM
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_CONHEC_TRANSP_EFD_FF' );
   --
   -- Monta cláusula WHERE
   gv_sql := gv_sql || ' WHERE ' || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' ||''''||ev_cpf_cnpj_emit||'''';
   --
   gv_sql := gv_sql || ' AND '   || trim(GV_ASPAS) || 'DM_IND_EMIT'   || trim(GV_ASPAS) || ' = ' ||en_dm_ind_emit;
   --
   gv_sql := gv_sql || ' AND '   || trim(GV_ASPAS) || 'DM_IND_OPER'   || trim(GV_ASPAS) || ' = ' ||en_dm_ind_oper;
   --
   gv_sql := gv_sql || ' AND '   || trim(GV_ASPAS) || 'COD_PART'      || trim(GV_ASPAS) || ' = ' ||''''||ev_cod_part||'''';
   --
   gv_sql := gv_sql || ' AND '   || trim(GV_ASPAS) || 'COD_MOD'       || trim(GV_ASPAS) || ' = ' ||''''||ev_cod_mod||'''';
   --
   gv_sql := gv_sql || ' AND '   || GV_ASPAS       || 'SERIE'         || GV_ASPAS       || ' = ' ||''''||ev_serie||'''';
   --
   if nvl(en_subserie, 0) > 0 then
      gv_sql := gv_sql || ' AND ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS) || ' = ' ||en_subserie;
   end if;
   --
   gv_sql := gv_sql || ' AND ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS) || ' = ' ||en_nro_nf;
   --
   -- Monta cláusula ORDER BY
   gv_sql := gv_sql || ' ORDER BY ' || trim(GV_ASPAS) || 'COD_PART'         || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '         || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT'    || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '         || trim(GV_ASPAS) || 'DM_IND_EMIT'      || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '         || trim(GV_ASPAS) || 'DM_IND_OPER'      || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '         || trim(GV_ASPAS) || 'COD_PART'         || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '         || trim(GV_ASPAS) || 'COD_MOD'          || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '         || trim(GV_ASPAS) || 'SERIE'            || trim(GV_ASPAS);
   --
   if nvl(en_subserie, 0) > 0 then
      gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS);
   end if;
   --
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ATRIBUTO' || trim(GV_ASPAS);
   --
   vn_fase := 2;
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_conhec_tranp_efd_ff;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ler_conhec_transp_ff fase('||vn_fase||'):'||sqlerrm;
            --
            declare
               vn_loggenericoct_id  log_generico_ct.id%TYPE;
            begin
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenericoct_id
                                                   , ev_mensagem        => gv_mensagem_log
                                                   , ev_resumo          => 'Conhecimento de transporte cod_part: ' || ev_cod_part
                                                   , en_tipo_log        => pk_csf_api_ct.ERRO_DE_SISTEMA
                                                   , en_referencia_id   => null
                                                   , ev_obj_referencia  => 'CONHEC_TRANSP' );
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
   vn_fase := 3;
   --
   if vt_tab_csf_conhec_tranp_efd_ff.count > 0 then
      --
      vn_dados_munic_ini := 0;
      vn_dados_munic_fim := 0; 	  
      --	  
      for i in vt_tab_csf_conhec_tranp_efd_ff.first..vt_tab_csf_conhec_tranp_efd_ff.last loop
         --
         vn_fase := 4;
         --
         if vt_tab_csf_conhec_tranp_efd_ff(i).atributo not in ('COD_MULT_ORG', 'HASH_MULT_ORG') then
            --
            vn_fase := 5;
            --
            pk_csf_api_d100.pkb_integr_conhec_transp_ff ( est_log_generico    => est_log_generico
                                                        , en_conhectransp_id  => en_conhectransp_id
                                                        , ev_atributo         => trim(vt_tab_csf_conhec_tranp_efd_ff(i).atributo)
                                                        , ev_valor            => trim(vt_tab_csf_conhec_tranp_efd_ff(i).valor) );
            --
         end if;
         --
         if trim(vt_tab_csf_conhec_tranp_efd_ff(i).atributo) in ( 'IBGE_CIDADE_INI', 'DESCR_CIDADE_INI', 'SIGLA_UF_INI' ) then
            vn_dados_munic_ini := 1;
         end if;			
         --
         if	trim(vt_tab_csf_conhec_tranp_efd_ff(i).atributo) in ( 'IBGE_CIDADE_FIM', 'DESCR_CIDADE_FIM', 'SIGLA_UF_FIM' ) then
            vn_dados_munic_fim := 1;	
         end if;
         --		 
      end loop;
      --
      if nvl( vn_dados_munic_ini, 0 ) = 0 or
         nvl( vn_dados_munic_fim, 0 ) = 0 then	
         --	
		 vn_fase := 5;
         begin            		 
            select c.pessoa_id
			  into vn_pessoa_id
              from conhec_transp c
             where c.id = en_conhectransp_id;
         exception
            when no_data_found then
               vn_pessoa_id := null;
         end;
         --		 
         gv_cabec_log := 'Empresa: ' || ev_cpf_cnpj_emit;
         gv_cabec_log := gv_cabec_log || chr(10) || 'Número: ' || en_nro_nf;
         gv_cabec_log := gv_cabec_log || chr(10) || 'Série: ' || ev_serie;
         gv_cabec_log := gv_cabec_log || chr(10) || 'Participante: ' || pk_csf.fkg_nome_pessoa_id ( en_pessoa_id => vn_pessoa_id );
	  end if;
      ---	  
      if nvl( vn_dados_munic_ini, 0 ) = 0 then
         --
         vn_fase := 6;
         --
         gv_mensagem_log := 'Dados do Município Inicio (Origem) da prestação do serviço para conhecimento não informados.';
         --
         declare
            vn_loggenericoct_id  log_generico_ct.id%TYPE;
         begin		 
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenericoct_id
                                              , ev_mensagem       => gv_cabec_log 
                                              , ev_resumo         => gv_mensagem_log
                                              , en_tipo_log       => ERRO_DE_SISTEMA
                                              , en_referencia_id  => en_conhectransp_id
                                              , ev_obj_referencia => 'CONHEC_TRANSP' );
            --
         exception
            when others then
               null;
         end;
          --
      end if;
      --
      if nvl( vn_dados_munic_fim, 0 ) = 0 then
         --
         vn_fase := 7;
         --
         gv_mensagem_log := 'Dados do Município Término (Destino) da prestação do serviço para conhecimento não informados.';
         --
         declare
            vn_loggenericoct_id  log_generico_ct.id%TYPE;
         begin	
            --		 
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenericoct_id
                                              , ev_mensagem       => gv_cabec_log
                                              , ev_resumo         => gv_mensagem_log
                                              , en_tipo_log       => ERRO_DE_SISTEMA
                                              , en_referencia_id  => en_conhectransp_id
                                              , ev_obj_referencia => 'CONHEC_TRANSP' );
            --
         exception
            when others then
               null;
         end;
         --
      end if;
      --	  
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ler_conhec_transp_ff fase('||vn_fase||') nro_ct('||en_nro_nf||'):'||sqlerrm;
      --
      declare
         vn_loggenericoct_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenericoct_id
                                           , ev_mensagem        => gv_mensagem_log
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => pk_csf_api_ct.ERRO_DE_SISTEMA
                                           , en_referencia_id   => pk_csf_api_ct.gt_row_conhec_transp.id
                                           , ev_obj_referencia  => 'CONHEC_TRANSP' );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_ler_conhec_transp_ff;
--
-------------------------------------------------------------------------------------------------------
--| Procedimento de leitura das informações das NF-e do Conhecimento de Transporte
-------------------------------------------------------------------------------------------------------
procedure pkb_ler_ct_inf_nfe(est_log_generico   in out nocopy dbms_sql.number_table,
                             en_conhectransp_id in conhec_transp.id%type,
                             ev_cpf_cnpj_emit in varchar2,
                             en_dm_ind_emit   in number,
                             en_dm_ind_oper   in number,
                             ev_cod_part      in varchar2,
                             ev_cod_mod       in varchar2,
                             ev_serie         in varchar2,
                             en_nro_ct        in number) is
  --
  vn_fase number := 0;
  i       pls_integer;
  --
begin
  --
  vn_fase := 1;
  --
  if pk_csf.fkg_existe_obj_util_integr(ev_obj_name => 'VW_CSF_CT_INF_NFE') = 0 then
    --
    return;
    --
  end if;
  --
  gv_sql := null;
  --
  --  inicia montagem da query
  gv_sql := 'select ';
  --
  gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
  gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
  gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
  gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
  gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS;
  gv_sql := gv_sql || ', ' || GV_ASPAS || 'SERIE' || GV_ASPAS;
  gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_CT' || GV_ASPAS;
  gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_CHAVE_NFE' || GV_ASPAS;
  gv_sql := gv_sql || ', ' || GV_ASPAS || 'PIN' || GV_ASPAS;
  gv_sql := gv_sql || ', ' || GV_ASPAS || 'DT_PREV_ENT' || GV_ASPAS;
  --
  gv_sql := gv_sql || fkg_monta_from(ev_obj => 'VW_CSF_CT_INF_NFE');
  --
  vn_fase := 2;
  --
  -- Monta a condição do where                                                                                                  e
  gv_sql := gv_sql || ' where ';
  gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
  gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
  gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
  --
  vn_fase := 3;
  --
  if en_dm_ind_emit = 1 and ev_cod_part is not null then
    --
    gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
    --
  end if;
  --
  vn_fase := 4;
  --
  gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
  gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
  gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_CT' || GV_ASPAS || ' = ' || en_nro_ct;
  --
  vn_fase := 5;
  --
  gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_CT_INF_NFE' || chr(10);
  --
  begin
    --
    execute immediate gv_sql bulk collect into vt_tab_csf_ct_inf_nfe;
    --
  exception
    when others then
      -- não registra erro caso a view não exista
      if sqlcode = -942 then
        null;
      else
        --
        pk_csf_api_ct.gv_mensagem_log := 'Erro na pk_integr_view_ct.pkb_ler_ct_inf_nfe fase(' || vn_fase || '):' || sqlerrm;
        --
        declare
          vn_loggenerico_id log_generico_ct.id%TYPE;
        begin
          --
          pk_csf_api_ct.pkb_log_generico_ct(sn_loggenerico_id => vn_loggenerico_id,
                                            ev_mensagem       => pk_csf_api_ct.gv_mensagem_log,
                                            ev_resumo         => gv_resumo || gv_cabec_ct,
                                            en_tipo_log       => pk_csf_api_ct.ERRO_DE_SISTEMA,
                                            en_referencia_id  => en_conhectransp_id,
                                            ev_obj_referencia => 'CONHEC_TRANSP');
          --
          -- Armazena o "loggenerico_id" na memória
          pk_csf_api_ct.pkb_gt_log_generico_ct(en_loggenerico   => vn_loggenerico_id,
                                               est_log_generico => est_log_generico);
          --
        exception
          when others then
            null;
        end;
        --
      end if;
  end;
  --
  vn_fase := 6;
  --
  if vt_tab_csf_ct_inf_nfe.count > 0 then
    --
    for i in vt_tab_csf_ct_inf_nfe.first .. vt_tab_csf_ct_inf_nfe.last loop
      --
      vn_fase := 7;
      --
      pk_csf_api_ct.gt_row_ct_inf_nfe := null;
      --
      pk_csf_api_ct.gt_row_ct_inf_nfe.conhectransp_id := en_conhectransp_id;
      pk_csf_api_ct.gt_row_ct_inf_nfe.nro_chave_nfe   := vt_tab_csf_ct_inf_nfe(i).nro_chave_nfe;
      pk_csf_api_ct.gt_row_ct_inf_nfe.pin             := vt_tab_csf_ct_inf_nfe(i).pin;
      pk_csf_api_ct.gt_row_ct_inf_nfe.dt_prev_ent     := vt_tab_csf_ct_inf_nfe(i).dt_prev_ent;
      --
      vn_fase := 8;
      --
      pk_csf_api_ct.pkb_seta_tipo_integr(en_tipo_integr => 1);
      --
      -- Chama procedimento que integra as informações das NF-e do Conhecimento de Transporte
      pk_csf_api_ct.pkb_integr_ct_inf_nfe(est_log_generico   => est_log_generico,
                                          est_row_ct_inf_nfe => pk_csf_api_ct.gt_row_ct_inf_nfe);
      --
    end loop;
    --
  end if;
  --
exception
  when others then
    --
    pk_csf_api_ct.gv_mensagem_log := 'Erro na pk_integr_view_ct.pkb_ler_ct_inf_nfe fase(' || vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_ct.id%TYPE;
    begin
      --
      pk_csf_api_ct.pkb_log_generico_ct(sn_loggenerico_id => vn_loggenerico_id,
                                        ev_mensagem       => pk_csf_api_ct.gv_cabec_log,
                                        ev_resumo         => pk_csf_api_ct.gv_mensagem_log,
                                        en_tipo_log       => pk_csf_api_ct.ERRO_DE_SISTEMA,
                                        en_referencia_id  => en_conhectransp_id,
                                        ev_obj_referencia => 'CONHEC_TRANSP');
      --
      -- Armazena o "loggenerico_id" na memória
      pk_csf_api_ct.pkb_gt_log_generico_ct(en_loggenerico   => vn_loggenerico_id,
                                           est_log_generico => est_log_generico);
      --
    exception
      when others then
        null;
    end;
    --
end pkb_ler_ct_inf_nfe;
-------------------------------------------------------------------------------------------------------
--| Procedimento de integração do Duferencial de Aliquota
-------------------------------------------------------------------------------------------------------
procedure pkb_ct_dif_aliq ( est_log_generico          in out nocopy  dbms_sql.number_table
                          , ev_cpf_cnpj_emit          in             varchar2
                          , en_dm_ind_emit            in             conhec_transp.dm_ind_emit%type
                          , en_dm_ind_oper            in             conhec_transp.dm_ind_oper%type
                          , ev_cod_part               in             pessoa.cod_part%type
                          , ev_cod_mod                in             mod_fiscal.cod_mod%type
                          , ev_serie                  in             conhec_transp.serie%type
                          , ev_subserie               in             conhec_transp.subserie%type
                          , en_nro_ct                 in             conhec_transp.nro_ct%type
                          , en_conhectransp_id        in             conhec_transp.id%type )
is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_ct.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_CT_DIF_ALIQ') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_reg_ct_efd.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_MOD' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_CT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ALIQ_INTERNA' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ALIQ_IE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'BC_DIF_ALIQ' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_DIF_ALIQ' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'BC_FCP' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ALIQ_FCP' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_FCP' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_TIPO' || trim(GV_ASPAS);
   --
   vn_fase := 2;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_CT_DIF_ALIQ' );
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || en_dm_ind_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS) || ' = ' || '''' || en_dm_ind_oper || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_MOD' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_mod || '''';
   --
   if trim(ev_serie) is not null then
      gv_sql := gv_sql || ' and pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ' || ' = ' || '''' || ev_serie || '''';
   end if;
   --
   if trim(ev_subserie) is not null then
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS) || ' = ' || '''' || ev_subserie || '''';
   end if;
   --
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_CT' || trim(GV_ASPAS) || ' = ' || '''' || en_nro_ct || '''';
   --
   vn_fase := 3;
   --
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_ct_dif_aliq;
      --
   exception
      when others then
         --
         gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ct_reg_anal fase(' || vn_fase || '):' || sqlerrm;
         --
         declare
            vn_loggenerico_id  log_generico_ct.id%type;
         begin
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                        , ev_mensagem       => gv_mensagem_log
                                        , ev_resumo         => gv_mensagem_log
                                        , en_tipo_log       => erro_de_sistema
                                        , en_referencia_id  => null
                                        , ev_obj_referencia => gv_obj_referencia );
            --
         exception
            when others then
               null;
         end;
         --
   end;
   --
   vn_fase := 4;
   --
   if nvl(vt_tab_csf_ct_dif_aliq.count,0) > 0 then
      --
      vn_fase := 5;
      --
      for i in vt_tab_csf_ct_dif_aliq.first .. vt_tab_csf_ct_dif_aliq.last loop
         --
         vn_fase := 6;
         --
         pk_csf_api_d100.gt_row_ct_dif_aliq := null;
         --
         vn_fase := 7;
         --
         pk_csf_api_d100.gt_row_ct_dif_aliq.conhectransp_id  := en_conhectransp_id;
         pk_csf_api_d100.gt_row_ct_dif_aliq.aliq_interna     := vt_tab_csf_ct_dif_aliq(i).aliq_interna;
         pk_csf_api_d100.gt_row_ct_dif_aliq.aliq_ie          := vt_tab_csf_ct_dif_aliq(i).aliq_ie;		 
         pk_csf_api_d100.gt_row_ct_dif_aliq.bc_dif_aliq      := vt_tab_csf_ct_dif_aliq(i).bc_dif_aliq;
         pk_csf_api_d100.gt_row_ct_dif_aliq.vl_dif_aliq      := vt_tab_csf_ct_dif_aliq(i).vl_dif_aliq;
         pk_csf_api_d100.gt_row_ct_dif_aliq.bc_fcp           := vt_tab_csf_ct_dif_aliq(i).bc_fcp;
         pk_csf_api_d100.gt_row_ct_dif_aliq.aliq_fcp         := vt_tab_csf_ct_dif_aliq(i).aliq_fcp;
         pk_csf_api_d100.gt_row_ct_dif_aliq.vl_fcp           := vt_tab_csf_ct_dif_aliq(i).vl_fcp;
         pk_csf_api_d100.gt_row_ct_dif_aliq.dm_tipo          := vt_tab_csf_ct_dif_aliq(i).dm_tipo;		 
         --
         vn_fase := 8;
         --
         pk_csf_api_d100.pkb_integr_ct_dif_aliq ( est_log_generico         => est_log_generico
                                                , est_row_ct_dif_aliq      => pk_csf_api_d100.gt_row_ct_dif_aliq
                                                , en_conhectransp_id       => en_conhectransp_id );		 
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_ct_dif_aliq fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%type;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                     , ev_mensagem       => gv_mensagem_log
                                     , ev_resumo         => gv_mensagem_log
                                     , en_tipo_log       => erro_de_sistema
                                     , en_referencia_id  => null
                                     , ev_obj_referencia => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ct_dif_aliq;
--
-------------------------------------------------------------------------------------------------------
--| Procedimento de integração de campos Flex-Field dos Conhecimentos de Transportes
-------------------------------------------------------------------------------------------------------
procedure pkb_conhec_transp_ff( est_log_generico  in  out nocopy  dbms_sql.number_table
                              , ev_cpf_cnpj_emit  in  varchar2
                              , en_dm_ind_emit    in  number
                              , en_dm_ind_oper    in  number
                              , ev_cod_part       in  varchar2
                              , ev_cod_mod        in  varchar2
                              , ev_serie          in  varchar2
                              , en_subserie       in  number
                              , en_nro_nf         in  number
                              , sn_multorg_id     in  out nocopy  mult_org.id%type)
is
   vn_fase               number := 0;
   vn_loggenericoct_id   log_generico_ct.id%TYPE;
   vv_cod                mult_org.cd%type;
   vv_hash               mult_org.hash%type;
   vv_cod_ret            mult_org.cd%type;
   vv_hash_ret           mult_org.hash%type;
   vn_multorg_id         mult_org.id%type := 0;
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_CONHEC_TRANSP_EFD_FF') = 0 then
      --
      sn_multorg_id := vn_multorg_id;
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_conhec_tranp_efd_ff.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         trim(GV_ASPAS) || 'CPF_CNPJ_EMIT'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART'            || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_MOD'             || trim(GV_ASPAS);
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SUBSERIE'            || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF'              || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ATRIBUTO'            || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VALOR'               || trim(GV_ASPAS);
   --
   vn_fase := 1.1;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_CONHEC_TRANSP_EFD_FF' );
   --
   gv_sql := gv_sql || ' WHERE ' || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' ||''''||ev_cpf_cnpj_emit||'''';
   --
   gv_sql := gv_sql || ' AND '   || trim(GV_ASPAS) || 'DM_IND_EMIT'   || trim(GV_ASPAS) || ' = ' ||en_dm_ind_emit;
   --
   gv_sql := gv_sql || ' AND '   || trim(GV_ASPAS) || 'DM_IND_OPER'   || trim(GV_ASPAS) || ' = ' ||en_dm_ind_oper;
   --
   gv_sql := gv_sql || ' AND '   || trim(GV_ASPAS) || 'COD_PART'      || trim(GV_ASPAS) || ' = ' ||''''||ev_cod_part||'''';
   --
   gv_sql := gv_sql || ' AND '   || trim(GV_ASPAS) || 'COD_MOD'       || trim(GV_ASPAS) || ' = ' ||''''||ev_cod_mod||'''';
   --
   gv_sql := gv_sql || ' AND pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ' || ' = ' ||''''||ev_serie||'''';
   --
   if nvl(en_subserie, 0) > 0 then
      gv_sql := gv_sql || ' AND ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS) || ' = ' ||en_subserie;
   end if;
   --
   gv_sql := gv_sql || ' AND ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS) || ' = ' ||en_nro_nf;
   --
   gv_sql := gv_sql || ' ORDER BY ' || trim(GV_ASPAS) || 'COD_PART'      || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '         || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '         || trim(GV_ASPAS) || 'DM_IND_EMIT'   || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '         || trim(GV_ASPAS) || 'DM_IND_OPER'   || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '         || trim(GV_ASPAS) || 'COD_PART'      || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '         || trim(GV_ASPAS) || 'COD_MOD'       || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '         || trim(GV_ASPAS) || 'SERIE'         || trim(GV_ASPAS);
   --
   if nvl(en_subserie, 0) > 0 then
      gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS);
   end if;
   --
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF'   || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ATRIBUTO' || trim(GV_ASPAS);
   --
   vn_fase := 2;
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_conhec_tranp_efd_ff;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_conhec_transp_ff fase('||vn_fase||'):'||sqlerrm;
            --
            declare
               vn_loggenericoct_id  log_generico_ct.id%TYPE;
            begin
               --
               pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenericoct_id
                                                   , ev_mensagem        => gv_mensagem_log
                                                   , ev_resumo          => 'Conhecimento de transporte cod_part: ' || ev_cod_part
                                                   , en_tipo_log        => pk_csf_api_ct.ERRO_DE_SISTEMA
                                                   , en_referencia_id   => null
                                                   , ev_obj_referencia  => 'CONHEC_TRANSP' );
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
   vn_fase := 3;
   --
   if vt_tab_csf_conhec_tranp_efd_ff.count > 0 then
      --
      for i in vt_tab_csf_conhec_tranp_efd_ff.first..vt_tab_csf_conhec_tranp_efd_ff.last loop
         --
         vn_fase := 4;
         --
         if vt_tab_csf_conhec_tranp_efd_ff(i).atributo in ('COD_MULT_ORG', 'HASH_MULT_ORG') then
            --
            vn_fase := 5;
            -- Chama procedimento que faz a validação dos itens da Pessoa - campos flex field.
            vv_cod_ret := null;
            vv_hash_ret := null;

            pk_csf_api_d100.pkb_val_atrib_multorg ( est_log_generico     => est_log_generico
                                                 , ev_obj_name          => 'VW_CSF_CONHEC_TRANSP_EFD_FF'
                                                 , ev_atributo          => vt_tab_csf_conhec_tranp_efd_ff(i).atributo
                                                 , ev_valor             => vt_tab_csf_conhec_tranp_efd_ff(i).valor
                                                 , sv_cod_mult_org      => vv_cod_ret
                                                 , sv_hash_mult_org     => vv_hash_ret
                                                 , en_referencia_id     => null
                                                 , ev_obj_referencia    => 'CONHEC_TRANSP');
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
      if nvl(est_log_generico.count, 0) <= 0 then
         --
         vn_fase := 8;
         --
         vn_multorg_id := sn_multorg_id;
         pk_csf_api_d100.pkb_ret_multorg_id( est_log_generico   => est_log_generico
                                         , ev_cod_mult_org    => vv_cod
                                         , ev_hash_mult_org   => vv_hash
                                         , sn_multorg_id      => vn_multorg_id
                                         , en_referencia_id   => null
                                         , ev_obj_referencia  => 'CONHEC_TRANSP'
                                         );
      end if;
      --
      vn_fase := 9;
      --
      sn_multorg_id := vn_multorg_id;
      --
   else
      --
      gv_mensagem_log := 'Conhecimento de transporte cadastrada com Mult Org default (codigo = 1), pois não foram passados o codigo e a hash do multorg.';
      --
      vn_loggenericoct_id := null;
      --
      vn_fase := 10;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenericoct_id
                                        , ev_mensagem           => gv_mensagem_log
                                        , ev_resumo             => 'Conhecimento de transporte cod_part: ' || ev_cod_part
                                        , en_tipo_log           => pk_csf_api_ct.INFORMACAO
                                        , en_referencia_id      => pk_csf_api_ct.gn_referencia_id
                                        , ev_obj_referencia     => 'CONHEC_TRANSP'
                                        );
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_conhec_transp_ff fase('||vn_fase||') nro_ct('||en_nro_nf||'):'||sqlerrm;
      --
      declare
         vn_loggenericoct_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenericoct_id
                                           , ev_mensagem        => gv_mensagem_log
                                           , ev_resumo          => 'Conhecimento de transporte  cod_part: ' || ev_cod_part
                                           , en_tipo_log        => pk_csf_api_ct.ERRO_DE_SISTEMA
                                           , en_referencia_id   => pk_csf_api_ct.gt_row_conhec_transp.id
                                           , ev_obj_referencia  => 'CONHEC_TRANSP' );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_conhec_transp_ff;
--
-------------------------------------------------------------------------------------------------------
--| Procedimento de integração de Conhecimento de Transporte
-------------------------------------------------------------------------------------------------------
procedure pkb_conhec_transp(ev_cpf_cnpj in varchar2,
                            ed_dt_ini   in date,
                            ed_dt_fin   in date) is
  --
  vn_fase              number := 0;
  vt_log_generico      dbms_sql.number_table;
  vn_loggenerico_id    log_generico_ct.id%type;
  vn_conhectransp_id   conhec_transp.id%TYPE;
  vn_dm_st_proc        conhec_transp.dm_st_proc%TYPE;
  vn_empresa_id        empresa.id%TYPE;
  vn_pessoa_id         pessoa.id%TYPE;
  vn_modfiscal_id      Mod_fiscal.id%TYPE;
  vd_dt_ult_fecha      fecha_fiscal_empresa.dt_ult_fecha%type;
  vn_multorg_id        mult_org.id%type;
  vn_dm_dt_escr_dfepoe empresa.dm_dt_escr_dfepoe%type;
  --
begin
  --
  vn_fase := 1;
  --
  if pk_csf.fkg_existe_obj_util_integr(ev_obj_name => 'VW_CSF_CONHEC_TRANSP_EFD') = 0 then
    --
    return;
    --
  end if;
  --
  pk_csf_api_d100.pkb_seta_obj_ref(ev_objeto => 'CONHEC_TRANSP');
  --
  -- Lê as informações e insere.
  pk_csf_api_d100.pkb_seta_tipo_integr(en_tipo_integr => 1);
  --
  gv_sql := null;
  --
  vt_tab_csf_conhec_tranp_efd.delete;
  --
  -- Inicia montagem da query
  gv_sql := 'select ';
  --
  gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
  gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
  gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
  gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
  gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_MOD' || trim(GV_ASPAS);
  gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
  gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS);
  gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
  gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SIT_DOCTO' || trim(GV_ASPAS);
  gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_CHAVE_CTE' || trim(GV_ASPAS);
  gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_TP_CTE' || trim(GV_ASPAS);
  gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CHAVE_CTE_REF' || trim(GV_ASPAS);
  gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_EMISS' || trim(GV_ASPAS);
  gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_SAI_ENT' || trim(GV_ASPAS);
  gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_DOC' || trim(GV_ASPAS);
  gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_DESC' || trim(GV_ASPAS);
  gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_FRT' || trim(GV_ASPAS);
  gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_SERV' || trim(GV_ASPAS);
  gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_BC_ICMS' || trim(GV_ASPAS);
  gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_ICMS' || trim(GV_ASPAS);
  gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_NT' || trim(GV_ASPAS);
  gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_INF' || trim(GV_ASPAS);
  gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_CTA' || trim(GV_ASPAS);
  gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_NAT_OPER' || trim(GV_ASPAS);
  --
  vn_fase := 2;
  --
  gv_sql := gv_sql || fkg_monta_from(ev_obj => 'VW_CSF_CONHEC_TRANSP_EFD');
  --
  -- Monta a condição do where
  gv_sql := gv_sql || ' where ';
  gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj || '''';
  --
  vn_fase := 3;
  --
  if ed_dt_ini is not null and ed_dt_fin is not null then
     --
     gv_sql := gv_sql || ' AND ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS) || ' = 1 AND (' || trim(GV_ASPAS) || 'DT_SAI_ENT' || trim(GV_ASPAS) || ' >= ' || '''' || to_char(ed_dt_ini, GV_FORMATO_DT_ERP) || '''' ||
                         ' AND ' || trim(GV_ASPAS) || 'DT_SAI_ENT' || trim(GV_ASPAS) || ' <= ' || '''' || to_char(ed_dt_fin, GV_FORMATO_DT_ERP) || '''' || ')';
     --
  end if;
  --
  vn_fase := 4;
  --
  -- Recupera as Notas Fiscais não integradas
  begin
    --
    execute immediate gv_sql bulk collect into vt_tab_csf_conhec_tranp_efd;
    --
  exception
    when others then
      -- Não registra erro caso a view não exista
      if sqlcode = -942 then
        null;
      else
        --
        gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_conhec_transp fase(' || vn_fase || '):' || sqlerrm;
        --
        declare
          vn_loggenerico_id log_generico_ct.id%type;
        begin
          --
          pk_csf_api_ct.pkb_log_generico_ct(sn_loggenerico_id => vn_loggenerico_id,
                                            ev_mensagem       => gv_mensagem_log,
                                            ev_resumo         => gv_mensagem_log,
                                            en_tipo_log       => erro_de_sistema,
                                            en_referencia_id  => null,
                                            ev_obj_referencia => gv_obj_referencia);
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
  vn_fase := 5;
  --
  -- Calcula a quantidade de registros buscados no ERP
  -- para ser mostrado na tela de agendamento.
  begin
    pk_agend_integr.gvtn_qtd_erp(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erp(gv_cd_obj), 0) + nvl(vt_tab_csf_conhec_tranp_efd.count, 0);
  exception
    when others then
      null;
  end;
  --
  if nvl(vt_tab_csf_conhec_tranp_efd.count, 0) > 0 then
    --
    for i in vt_tab_csf_conhec_tranp_efd.first .. vt_tab_csf_conhec_tranp_efd.last loop
      --
      vn_fase := 5.1;
      --
      vt_log_generico.delete;
      --
      -- Necessário para inclusão de dados do emitente do conhecimento ----------------------------------     
      pk_csf_api_d100.gt_row_conhec_transp             := null;
      pk_csf_api_d100.gt_row_conhec_transp.dm_ind_emit := vt_tab_csf_conhec_tranp_efd(i).dm_ind_emit;
      ---------------------------------------------------------------------------------------------------
      --
      vn_fase := 5.2;
      --
      vn_multorg_id := gn_multorg_id;
      --
      pkb_conhec_transp_ff(est_log_generico => vt_log_generico,
                           ev_cpf_cnpj_emit => vt_tab_csf_conhec_tranp_efd(i).cpf_cnpj_emit,
                           en_dm_ind_emit   => vt_tab_csf_conhec_tranp_efd(i).dm_ind_emit,
                           en_dm_ind_oper   => vt_tab_csf_conhec_tranp_efd(i).dm_ind_oper,
                           ev_cod_part      => vt_tab_csf_conhec_tranp_efd(i).cod_part,
                           ev_cod_mod       => vt_tab_csf_conhec_tranp_efd(i).cod_mod,
                           ev_serie         => vt_tab_csf_conhec_tranp_efd(i).serie,
                           en_subserie      => vt_tab_csf_conhec_tranp_efd(i).subserie,
                           en_nro_nf        => vt_tab_csf_conhec_tranp_efd(i).nro_nf,
                           sn_multorg_id    => vn_multorg_id);
      --
      vn_fase := 5.3;
      --
      if nvl(vn_multorg_id, 0) <= 0 then
        --
        vn_fase := 5.4;
        --
        vn_multorg_id := gn_multorg_id;
        --
      elsif vn_multorg_id != gn_multorg_id then
        --
        vn_fase := 5.5;
        --
        vn_multorg_id := gn_multorg_id;
        --
        pk_csf_api_ct.gv_mensagem_log := 'Mult-org informado pelo usuario(' || vn_multorg_id || ') não corresponde ao Mult-org da empresa(' || gn_multorg_id || ').';
        --
        vn_fase := 5.6;
        --
        declare
          --
          vn_loggenerico_id log_generico_ct.id%type;
          --
        begin
          --
          vn_loggenerico_id := null;
          --
          vn_fase := 5.7;
          --
          pk_csf_api_ct.pkb_log_generico_ct(sn_loggenerico_id => vn_loggenerico_id,
                                            ev_mensagem       => gv_mensagem_log,
                                            ev_resumo         => 'Mult-Org incorreto ou não informado.',
                                            en_tipo_log       => INFORMACAO,
                                            en_referencia_id  => gn_referencia_id,
                                            ev_obj_referencia => 'CONHEC_TRANSP');
        exception
          when others then
            null;
        end;
        --
      end if;
      --
      vn_fase := 6;
      --
      -- Busca status da nota.
      vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj(en_multorg_id => vn_multorg_id,
                                                           ev_cpf_cnpj   => vt_tab_csf_conhec_tranp_efd(i).cpf_cnpj_emit);
      --
      vn_fase := 7;
      --
      -- Necessário para inclusão de dados do emitente do conhecimento -----
      pk_csf_api_d100.gt_row_conhec_transp.empresa_id := vn_empresa_id;
      ----------------------------------------------------------------------                               
      --
      vn_fase := 8;
      --
      vn_dm_dt_escr_dfepoe := pk_csf.fkg_dmdtescrdfepoe_empresa(en_empresa_id => vn_empresa_id);
      --
      vn_fase := 9;
      --
      vd_dt_ult_fecha := pk_csf.fkg_recup_dtult_fecha_empresa(en_empresa_id   => vn_empresa_id,
                                                              en_objintegr_id => pk_csf.fkg_recup_objintegr_id(ev_cd => '4'));
      --
      if (vd_dt_ult_fecha is null) or
         (vt_tab_csf_conhec_tranp_efd(i).dm_ind_emit = 1 and trunc(nvl(vt_tab_csf_conhec_tranp_efd(i).dt_sai_ent, vt_tab_csf_conhec_tranp_efd(i).dt_emiss)) > vd_dt_ult_fecha) or 
         (vt_tab_csf_conhec_tranp_efd(i).dm_ind_emit = 0 and vt_tab_csf_conhec_tranp_efd(i).dm_ind_oper = 1 and trunc(vt_tab_csf_conhec_tranp_efd(i).dt_emiss) > vd_dt_ult_fecha) or 
         (vt_tab_csf_conhec_tranp_efd(i).dm_ind_emit = 0 and vt_tab_csf_conhec_tranp_efd(i).dm_ind_oper = 0 and vn_dm_dt_escr_dfepoe = 0 and trunc(vt_tab_csf_conhec_tranp_efd(i).dt_emiss) > vd_dt_ult_fecha) or 
         (vt_tab_csf_conhec_tranp_efd(i).dm_ind_emit = 0 and vt_tab_csf_conhec_tranp_efd(i).dm_ind_oper = 0 and vn_dm_dt_escr_dfepoe = 1 and trunc(nvl(vt_tab_csf_conhec_tranp_efd(i).dt_sai_ent, vt_tab_csf_conhec_tranp_efd(i).dt_emiss)) > vd_dt_ult_fecha) then
        --
        vn_fase := 9.1;
        --
        vn_pessoa_id := pk_csf.fkg_pessoa_id_cod_part(en_multorg_id => vn_multorg_id,
                                                      ev_cod_part   => trim(vt_tab_csf_conhec_tranp_efd(i).cod_part));
        --
        vn_fase := 9.2;
        --
        vn_modfiscal_id := pk_csf.fkg_Mod_Fiscal_id(ev_cod_mod => trim(vt_tab_csf_conhec_tranp_efd(i).cod_mod));
        --
        vn_fase := 9.3;
        --
        vn_conhectransp_id := pk_csf_api_d100.fkg_conhec_transp_id(en_empresa_id   => vn_empresa_id,
                                                                   en_dm_ind_emit  => vt_tab_csf_conhec_tranp_efd(i).dm_ind_emit,
                                                                   en_dm_ind_oper  => vt_tab_csf_conhec_tranp_efd(i).dm_ind_oper,
                                                                   en_pessoa_id    => vn_pessoa_id,
                                                                   en_modfiscal_id => vn_modfiscal_id,
                                                                   ev_serie        => vt_tab_csf_conhec_tranp_efd(i).serie,
                                                                   ev_subserie     => to_char(vt_tab_csf_conhec_tranp_efd(i).subserie),
                                                                   en_nro_ct       => vt_tab_csf_conhec_tranp_efd(i).nro_nf);
        --
        vn_fase := 9.4;
        --
        vn_dm_st_proc := nvl(pk_csf_api_d100.fkg_ct_dm_st_proc(en_conhectransp_id => vn_conhectransp_id), 0);
        --
        -- Se a nota já está integrada com sucesso sai do movimento
        if nvl(vn_dm_st_proc, 0) in (4, 6, 7, 8) then
          --
          goto proximo;
          --
        end if;
        --
        vn_fase := 9.5;
        --
        pk_csf_api_d100.pkb_integr_ct_d100(est_log_generico   => vt_log_generico,
                                           ev_cpf_cnpj_emit   => vt_tab_csf_conhec_tranp_efd(i).cpf_cnpj_emit,
                                           en_dm_ind_emit     => vt_tab_csf_conhec_tranp_efd(i).dm_ind_emit,
                                           en_dm_ind_oper     => vt_tab_csf_conhec_tranp_efd(i).dm_ind_oper,
                                           ev_cod_part        => vt_tab_csf_conhec_tranp_efd(i).cod_part,
                                           ev_cod_mod         => vt_tab_csf_conhec_tranp_efd(i).cod_mod,
                                           ev_serie           => vt_tab_csf_conhec_tranp_efd(i).serie,
                                           ev_subserie        => to_char(vt_tab_csf_conhec_tranp_efd(i).subserie),
                                           en_nro_nf          => vt_tab_csf_conhec_tranp_efd(i).nro_nf,
                                           ev_sit_docto       => vt_tab_csf_conhec_tranp_efd(i).sit_docto,
                                           ev_nro_chave_cte   => vt_tab_csf_conhec_tranp_efd(i).nro_chave_cte,
                                           en_dm_tp_cte       => vt_tab_csf_conhec_tranp_efd(i).dm_tp_cte,
                                           ev_chave_cte_ref   => vt_tab_csf_conhec_tranp_efd(i).chave_cte_ref,
                                           ed_dt_emiss        => trunc(vt_tab_csf_conhec_tranp_efd(i).dt_emiss),
                                           ed_dt_sai_ent      => trunc(vt_tab_csf_conhec_tranp_efd(i).dt_sai_ent),
                                           en_vl_doc          => vt_tab_csf_conhec_tranp_efd(i).vl_doc,
                                           en_vl_desc         => vt_tab_csf_conhec_tranp_efd(i).vl_desc,
                                           en_dm_ind_frt      => vt_tab_csf_conhec_tranp_efd(i).dm_ind_frt,
                                           en_vl_serv         => vt_tab_csf_conhec_tranp_efd(i).vl_serv,
                                           en_vl_bc_icms      => vt_tab_csf_conhec_tranp_efd(i).vl_bc_icms,
                                           en_vl_icms         => vt_tab_csf_conhec_tranp_efd(i).vl_icms,
                                           en_vl_nt           => vt_tab_csf_conhec_tranp_efd(i).vl_nt,
                                           ev_cod_inf         => vt_tab_csf_conhec_tranp_efd(i).cod_inf,
                                           ev_cod_cta         => vt_tab_csf_conhec_tranp_efd(i).cod_cta,
                                           ev_cod_nat_oper    => vt_tab_csf_conhec_tranp_efd(i).cod_nat_oper,
                                           en_multorg_id      => vn_multorg_id,
                                           sn_conhectransp_id => vn_conhectransp_id,
                                           --
                                           en_loteintws_id     => 0, -- preenchido com vlr default
                                           en_cfop_id          => 1, -- preenchido com vlr default
                                           en_ibge_cidade_ini  => 0, -- preenchido com vlr default
                                           ev_descr_cidade_ini => 'XX', -- preenchido com vlr default
                                           ev_sigla_uf_ini     => 'XX', -- preenchido com vlr default
                                           en_ibge_cidade_fim  => 0, -- preenchido com vlr default
                                           ev_descr_cidade_fim => 'XX', -- preenchido com vlr default
                                           ev_sigla_uf_fim     => 'XX', -- preenchido com vlr default
                                           ev_dm_modal         => '01', -- preenchido com vlr default
                                           en_dm_tp_serv       => 0 -- preenchido com vlr default
                                           --
                                           ev_cd_unid_org      => null -- preenchido com vlr default                                           
                                           );
        --
        vn_fase := 9.6;
        --
        pkb_ler_conhec_transp_ff(est_log_generico   => vt_log_generico,
                                 ev_cpf_cnpj_emit   => vt_tab_csf_conhec_tranp_efd(i).cpf_cnpj_emit,
                                 en_dm_ind_emit     => vt_tab_csf_conhec_tranp_efd(i).dm_ind_emit,
                                 en_dm_ind_oper     => vt_tab_csf_conhec_tranp_efd(i).dm_ind_oper,
                                 ev_cod_part        => vt_tab_csf_conhec_tranp_efd(i).cod_part,
                                 ev_cod_mod         => vt_tab_csf_conhec_tranp_efd(i).cod_mod,
                                 ev_serie           => vt_tab_csf_conhec_tranp_efd(i).serie,
                                 en_subserie        => vt_tab_csf_conhec_tranp_efd(i).subserie,
                                 en_nro_nf          => vt_tab_csf_conhec_tranp_efd(i).nro_nf,
                                 en_conhectransp_id => vn_conhectransp_id);
        --
        vn_fase := 9.7;
        --  
        pkb_conhec_transp_emit_efd(est_log_generico   => vt_log_generico,
                                   ev_cpf_cnpj_emit   => vt_tab_csf_conhec_tranp_efd(i).cpf_cnpj_emit,
                                   en_dm_ind_emit     => vt_tab_csf_conhec_tranp_efd(i).dm_ind_emit,
                                   en_dm_ind_oper     => vt_tab_csf_conhec_tranp_efd(i).dm_ind_oper,
                                   ev_cod_part        => vt_tab_csf_conhec_tranp_efd(i).cod_part,
                                   ev_cod_mod         => vt_tab_csf_conhec_tranp_efd(i).cod_mod,
                                   ev_serie           => vt_tab_csf_conhec_tranp_efd(i).serie,
                                   en_nro_nf          => vt_tab_csf_conhec_tranp_efd(i).nro_nf,
                                   en_conhectransp_id => vn_conhectransp_id);
        --
        vn_fase := 9.8;
        --
        pkb_ct_reg_anal(est_log_generico   => vt_log_generico,
                        ev_cpf_cnpj_emit   => vt_tab_csf_conhec_tranp_efd(i).cpf_cnpj_emit,
                        en_dm_ind_emit     => vt_tab_csf_conhec_tranp_efd(i).dm_ind_emit,
                        en_dm_ind_oper     => vt_tab_csf_conhec_tranp_efd(i).dm_ind_oper,
                        ev_cod_part        => vt_tab_csf_conhec_tranp_efd(i).cod_part,
                        ev_cod_mod         => vt_tab_csf_conhec_tranp_efd(i).cod_mod,
                        ev_serie           => vt_tab_csf_conhec_tranp_efd(i).serie,
                        ev_subserie        => vt_tab_csf_conhec_tranp_efd(i).subserie,
                        en_nro_nf          => vt_tab_csf_conhec_tranp_efd(i).nro_nf,
                        en_conhectransp_id => vn_conhectransp_id);
        --
        vn_fase := 9.9;
        --
        pkb_ct_comp_doc_pis_efd(est_log_generico   => vt_log_generico,
                                ev_cpf_cnpj_emit   => vt_tab_csf_conhec_tranp_efd(i).cpf_cnpj_emit,
                                en_dm_ind_emit     => vt_tab_csf_conhec_tranp_efd(i).dm_ind_emit,
                                en_dm_ind_oper     => vt_tab_csf_conhec_tranp_efd(i).dm_ind_oper,
                                ev_cod_part        => vt_tab_csf_conhec_tranp_efd(i).cod_part,
                                ev_cod_mod         => vt_tab_csf_conhec_tranp_efd(i).cod_mod,
                                ev_serie           => vt_tab_csf_conhec_tranp_efd(i).serie,
                                ev_subserie        => vt_tab_csf_conhec_tranp_efd(i).subserie,
                                en_nro_nf          => vt_tab_csf_conhec_tranp_efd(i).nro_nf,
                                en_conhectransp_id => vn_conhectransp_id);
        --
        vn_fase := 9.10;
        --
        pkb_ct_comp_doc_cofins_efd(est_log_generico   => vt_log_generico,
                                   ev_cpf_cnpj_emit   => vt_tab_csf_conhec_tranp_efd(i).cpf_cnpj_emit,
                                   en_dm_ind_emit     => vt_tab_csf_conhec_tranp_efd(i).dm_ind_emit,
                                   en_dm_ind_oper     => vt_tab_csf_conhec_tranp_efd(i).dm_ind_oper,
                                   ev_cod_part        => vt_tab_csf_conhec_tranp_efd(i).cod_part,
                                   ev_cod_mod         => vt_tab_csf_conhec_tranp_efd(i).cod_mod,
                                   ev_serie           => vt_tab_csf_conhec_tranp_efd(i).serie,
                                   ev_subserie        => vt_tab_csf_conhec_tranp_efd(i).subserie,
                                   en_nro_nf          => vt_tab_csf_conhec_tranp_efd(i).nro_nf,
                                   en_conhectransp_id => vn_conhectransp_id);
        --
        vn_fase := 9.11;
        --
        pkb_ct_proc_ref_efd(est_log_generico   => vt_log_generico,
                            ev_cpf_cnpj_emit   => vt_tab_csf_conhec_tranp_efd(i).cpf_cnpj_emit,
                            en_dm_ind_emit     => vt_tab_csf_conhec_tranp_efd(i).dm_ind_emit,
                            en_dm_ind_oper     => vt_tab_csf_conhec_tranp_efd(i).dm_ind_oper,
                            ev_cod_part        => vt_tab_csf_conhec_tranp_efd(i).cod_part,
                            ev_cod_mod         => vt_tab_csf_conhec_tranp_efd(i).cod_mod,
                            ev_serie           => vt_tab_csf_conhec_tranp_efd(i).serie,
                            ev_subserie        => vt_tab_csf_conhec_tranp_efd(i).subserie,
                            en_nro_nf          => vt_tab_csf_conhec_tranp_efd(i).nro_nf,
                            en_conhectransp_id => vn_conhectransp_id);
        --
        vn_fase := 9.12;
        --
        pkb_ctinfor_fiscal_efd(est_log_generico   => vt_log_generico,
                               ev_cpf_cnpj_emit   => vt_tab_csf_conhec_tranp_efd(i).cpf_cnpj_emit,
                               en_dm_ind_emit     => vt_tab_csf_conhec_tranp_efd(i).dm_ind_emit,
                               en_dm_ind_oper     => vt_tab_csf_conhec_tranp_efd(i).dm_ind_oper,
                               ev_cod_part        => vt_tab_csf_conhec_tranp_efd(i).cod_part,
                               ev_cod_mod         => vt_tab_csf_conhec_tranp_efd(i).cod_mod,
                               ev_serie           => vt_tab_csf_conhec_tranp_efd(i).serie,
                               ev_subserie        => vt_tab_csf_conhec_tranp_efd(i).subserie,
                               en_nro_nf          => vt_tab_csf_conhec_tranp_efd(i).nro_nf,
                               en_conhectransp_id => vn_conhectransp_id);
        --
        vn_fase := 9.13;
        --
        pkb_ct_imp_ret_efd(est_log_generico   => vt_log_generico,
                           ev_cpf_cnpj_emit   => vt_tab_csf_conhec_tranp_efd(i).cpf_cnpj_emit,
                           en_dm_ind_emit     => vt_tab_csf_conhec_tranp_efd(i).dm_ind_emit,
                           en_dm_ind_oper     => vt_tab_csf_conhec_tranp_efd(i).dm_ind_oper,
                           ev_cod_part        => vt_tab_csf_conhec_tranp_efd(i).cod_part,
                           ev_cod_mod         => vt_tab_csf_conhec_tranp_efd(i).cod_mod,
                           ev_serie           => vt_tab_csf_conhec_tranp_efd(i).serie,
                           ev_subserie        => vt_tab_csf_conhec_tranp_efd(i).subserie,
                           en_nro_nf          => vt_tab_csf_conhec_tranp_efd(i).nro_nf,
                           en_conhectransp_id => vn_conhectransp_id);
        --
        vn_fase := 9.14;
        --
        pkb_ler_ct_inf_nfe(est_log_generico   => vt_log_generico,
                           en_conhectransp_id => vn_conhectransp_id,
                           ev_cpf_cnpj_emit   => trim(vt_tab_csf_conhec_tranp_efd(i).cpf_cnpj_emit),
                           en_dm_ind_emit     => vt_tab_csf_conhec_tranp_efd(i).dm_ind_emit,
                           en_dm_ind_oper     => vt_tab_csf_conhec_tranp_efd(i).dm_ind_oper,
                           ev_cod_part        => trim(vt_tab_csf_conhec_tranp_efd(i).cod_part),
                           ev_cod_mod         => trim(vt_tab_csf_conhec_tranp_efd(i).cod_mod),
                           ev_serie           => trim(vt_tab_csf_conhec_tranp_efd(i).serie),
                           en_nro_ct          => vt_tab_csf_conhec_tranp_efd(i).nro_nf);
        --
        vn_fase := 9.15;
        --
        pkb_ct_dif_aliq(est_log_generico   => vt_log_generico,
                        ev_cpf_cnpj_emit   => vt_tab_csf_conhec_tranp_efd(i).cpf_cnpj_emit,
                        en_dm_ind_emit     => vt_tab_csf_conhec_tranp_efd(i).dm_ind_emit,
                        en_dm_ind_oper     => vt_tab_csf_conhec_tranp_efd(i).dm_ind_oper,
                        ev_cod_part        => vt_tab_csf_conhec_tranp_efd(i).cod_part,
                        ev_cod_mod         => vt_tab_csf_conhec_tranp_efd(i).cod_mod,
                        ev_serie           => vt_tab_csf_conhec_tranp_efd(i).serie,
                        ev_subserie        => vt_tab_csf_conhec_tranp_efd(i).subserie,
                        en_nro_ct          => vt_tab_csf_conhec_tranp_efd(i).nro_nf,
                        en_conhectransp_id => vn_conhectransp_id);
        --	
        vn_fase := 9.16;		
        -----------------------------
        -- Processos que consistem a informação do Conhecimento de Transporte
        -----------------------------
        pk_csf_api_d100.pkb_consiste_cte(est_log_generico   => vt_log_generico,
                                         en_conhectransp_id => vn_conhectransp_id);
        --
        vn_fase := 9.17;
        --
        -- Verifica se no log generico tem erro ou só aviso/informação
        if nvl(vt_log_generico.count, 0) > 0 and pk_csf_api_ct.fkg_ver_erro_log_generico_ct(en_conhec_transp_id => vn_conhectransp_id) = 1 then
          --
          update conhec_transp
             set dm_st_proc = 10
           where id         = vn_conhectransp_id;
           --
           vn_fase := 9.18;
           --
        else
          --
          update conhec_transp
             set dm_st_proc  = 4
           where dm_ind_emit = 1
             and id          = vn_conhectransp_id;
           --
           vn_fase := 9.19;
           --
        end if;
        --
        -- Calcula a quantidade de registros integrados com sucesso
        -- e com erro para ser mostrado na tela de agendamento.
        --
        begin
          --
          if pk_agend_integr.gvtn_qtd_total(gv_cd_obj) > (pk_agend_integr.gvtn_qtd_erro(gv_cd_obj) + pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj)) then
            --
            if nvl(vt_log_generico.count, 0) > 0 then -- Erro de validação
              --
              -- Verifica se no log generico tem erro ou só aviso/informação
              if pk_csf_api_ct.fkg_ver_erro_log_generico_ct(en_conhec_transp_id => vn_conhectransp_id) = 1 then
                --
                vn_fase := 9.20;
                --
                pk_agend_integr.gvtn_qtd_erro(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erro(gv_cd_obj), 0) + 1;
                --
              else
                --
                vn_fase := 9.21;
                --
                pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj), 0) + 1;
                --  
              end if;
              --
            else
              --
              vn_fase := 9.22;
              --
              pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj), 0) + 1;
              --
            end if;
            --
          end if;
          --
        exception
          when others then
            null;
        end;
        --
        commit;
        --
        vn_fase := 9.23;
        --
        <<proximo>>
        --
        null;
        --
      else
        --
        vn_fase := 99;
        --
        -- Gerar log no agendamento devido a data de fechamento
        --
        info_fechamento := pk_csf.fkg_retorna_csftipolog_id(ev_cd => 'INFO_FECHAMENTO');
        --
        declare
          vn_loggenerico_id log_generico_ct.id%type;
        begin
          pk_csf_api_ct.pkb_log_generico_ct(sn_loggenerico_id => vn_loggenerico_id,
                                            ev_mensagem       => 'Integração de Conhecimentos de Transporte',
                                            ev_resumo         => 'Período informado para integração do conhecimento de transporte não permitido devido ' ||
                                                                 'a data de fechamento fiscal ' || to_char(vd_dt_ult_fecha, 'dd/mm/yyyy') ||
                                                                 ' - CNPJ/CPF: ' || trim(vt_tab_csf_conhec_tranp_efd(i).cpf_cnpj_emit) ||
                                                                 ', Número do CT: ' || vt_tab_csf_conhec_tranp_efd(i).nro_nf ||
                                                                 ', Série: ' || trim(vt_tab_csf_conhec_tranp_efd(i).serie) ||
                                                                 ', Subserie: ' || vt_tab_csf_conhec_tranp_efd(i).subserie || '.',
                                            en_tipo_log       => info_fechamento,
                                            en_referencia_id  => null,
                                            ev_obj_referencia => gv_obj_referencia,
                                            en_empresa_id     => gn_empresa_id);
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
    gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_conhec_transp fase(' || vn_fase || '):' || sqlerrm;
    --
    declare
      --
      vn_loggenerico_id log_generico_ct.id%type;
      --
    begin
      --
      pk_csf_api_ct.pkb_log_generico_ct(sn_loggenerico_id => vn_loggenerico_id,
                                        ev_mensagem       => gv_mensagem_log,
                                        ev_resumo         => gv_mensagem_log,
                                        en_tipo_log       => erro_de_sistema,
                                        en_referencia_id  => null,
                                        ev_obj_referencia => gv_obj_referencia);
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, gv_mensagem_log);
  --
end pkb_conhec_transp;
--
-------------------------------------------------------------------------------------------------------
--| Executa procedure Stafe
-------------------------------------------------------------------------------------------------------
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
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'PK_INT_CT_STAFE_CSF') = 0 then
      --
      return;
      --
   end if;
   --
   if length(ev_cpf_cnpj) in (11, 14) then
      --
      vn_fase := 2;
      --
      gv_sql := 'begin PK_INT_CT_STAFE_CSF.PB_GERA(' ||
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
               gv_mensagem_log := 'Erro na pkb_stafe fase(' || vn_fase || '):' || sqlerrm;
               --
               declare
                  vn_loggenerico_id  Log_Generico.id%TYPE;
               begin
                  --
                  pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
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
      gv_mensagem_log := 'Erro na pkb_stafe fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
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
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_stafe;
--
-------------------------------------------------------------------------------------------------------
--| Procedimento que inicia a integração de cadastros
-------------------------------------------------------------------------------------------------------
procedure pkb_integracao ( en_empresa_id  in number
                         , ed_dt_ini      in date
                         , ed_dt_fin      in date )
is
   --
   vn_fase   number := 0;
   vv_cpf_cnpj_emit varchar2(14) := null;
   --
   cursor c_empr ( en_empresa_id number ) is
   select e.id empresa_id
        , e.dt_ini_integr
        , eib.owner_obj
        , eib.nome_dblink
        , eib.dm_util_aspa
        , eib.dm_ret_infor_integr
        , eib.formato_dt_erp
        , eib.dm_form_dt_erp
        , e.multorg_id
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
   vn_fase := 1;
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   for rec in c_empr(en_empresa_id) loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 2;
      --
      gn_multorg_id := rec.multorg_id;
      gn_empresa_id := rec.empresa_id;
      -- Se ta o DBLink
      gv_nome_dblink := rec.nome_dblink;
      gv_owner_obj   := rec.owner_obj;
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
      --  Seta formata da data para os procedimentos de integracao
      if trim(rec.formato_dt_erp) is not null then
         gv_formato_dt_erp := rec.formato_dt_erp;
      else
         gv_formato_dt_erp := gv_formato_data;
      end if;
      --
      vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => rec.empresa_id );
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
      pkb_conhec_transp ( ev_cpf_cnpj => pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => rec.empresa_id )
                        , ed_dt_ini   => ed_dt_ini
                        , ed_dt_fin   => ed_dt_fin );
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_integracao fase('||vn_fase||') CNPJ/CPF ('||
                         pk_csf.fkg_cnpj_ou_cpf_empresa(en_empresa_id => en_empresa_id)||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%type;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                     , ev_mensagem       => gv_mensagem_log
                                     , ev_resumo         => gv_mensagem_log
                                     , en_tipo_log       => erro_de_sistema );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integracao;
--
-------------------------------------------------------------------------------------------------------
--| Procedimento que inicia a integração de conhecimento de transporte com todas as empresas
-------------------------------------------------------------------------------------------------------
procedure pkb_integracao_normal ( ed_dt_ini in date
                                , ed_dt_fin in date
                                )
is
   --
   vn_fase   number := 0;
   --
   cursor c_empr is
   select e.id empresa_id
        , e.multorg_id
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
      gn_multorg_id := rec.multorg_id;
      gn_empresa_id := rec.empresa_id;
      --
      vn_fase := 3;
      --
      pkb_integracao ( en_empresa_id => rec.empresa_id
                     , ed_dt_ini     => ed_dt_ini
                     , ed_dt_fin     => ed_dt_fin
                     );
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_integracao_normal fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%type;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                     , ev_mensagem       => gv_mensagem_log
                                     , ev_resumo         => gv_mensagem_log
                                     , en_tipo_log       => erro_de_sistema );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integracao_normal;
--
-------------------------------------------------------------------------------------------------------
-- Processo de integração por período e informando todas as empresas ativas
-------------------------------------------------------------------------------------------------------
procedure pk_integr_periodo_geral ( en_multorg_id in mult_org.id%type
                                  , ed_dt_ini     in date
                                  , ed_dt_fin     in date
                                  )
is
   --
   vn_fase          number := 0;
   vv_cpf_cnpj_emit varchar2(14) := null;
   --
   cursor c_transp is
   select e.id empresa_id
        , e.multorg_id
     from empresa e
    where e.multorg_id  = en_multorg_id
      and e.dm_situacao = 1 -- Ativo
    order by 1;
   --
   cursor c_dados ( en_empresa_id number )is
   select eib.owner_obj
        , eib.nome_dblink
     from empresa e
        , empresa_integr_banco eib
    where e.id             = en_empresa_id
      AND e.dm_tipo_integr in (3, 4) -- Integração por view
      and e.dm_situacao    = 1 -- Ativa
      and eib.empresa_id   = e.id
      and eib.dm_ret_infor_integr = 1 -- retorna a informação para o ERP
    order by 1;
   --
begin
   -- Inicia os contadores de registros a serem integrados
   pk_agend_integr.pkb_inicia_cont(ev_cd_obj => gv_cd_obj);
   --
   vn_fase := 1;
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   for rec in c_transp
   loop
      --
      vn_fase := 2;
      --
      gv_nome_dblink    := null;
      gv_owner_obj      := null;
      gv_aspas          := null;
      gv_formato_dt_erp := gv_formato_data;
      --
      gn_empresa_id := rec.empresa_id;
      --
      open c_dados (rec.empresa_id);
      fetch c_dados into gv_owner_obj
                       , gv_nome_dblink;
      close c_dados;
      --
      vn_fase := 3;
      --
      vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => rec.empresa_id );
      gn_multorg_id    := rec.multorg_id;
      --
      vn_fase := 4.1;
      --
      pkb_stafe ( ev_cpf_cnpj => vv_cpf_cnpj_emit
                , ed_dt_ini   => ed_dt_ini
                , ed_dt_fin   => ed_dt_fin
                );
      --
      vn_fase := 4;
      --
      pkb_conhec_transp ( ev_cpf_cnpj => vv_cpf_cnpj_emit
                        , ed_dt_ini   => ed_dt_ini
                        , ed_dt_fin   => ed_dt_fin );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_int_view_d100.pk_integr_periodo_geral fase ('||vn_fase||'): ' || sqlerrm);
end pk_integr_periodo_geral;
--
-------------------------------------------------------------------------------------------------------
--| Procedimento que inicia a integração Geral de empresas para o CT
-------------------------------------------------------------------------------------------------------
procedure pkb_integr_geral_empresa ( en_paramintegrdados_id in param_integr_dados.id%type
                                   , ed_dt_ini in date
                                   , ed_dt_fin in date
                                   , en_empresa_id in empresa.id%type
                                   )
is
   --
   vn_fase          number := 0;
   vv_cpf_cnpj_emit varchar2(14) := null;
   --
   cursor c_empr is
   select p.*
        , e.multorg_id
     from param_integr_dados_empresa p
        , empresa e
    where p.paramintegrdados_id = en_paramintegrdados_id
      and p.empresa_id          = nvl(en_empresa_id, p.empresa_id)
      and e.id                  = p.empresa_id
      and e.dm_situacao         = 1 -- Ativo
    order by 1;
   --
begin
   --
   vn_fase := 1;
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   for rec in c_empr
   loop
      --
      vn_fase := 2;
      --
      vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => rec.empresa_id );
      gn_multorg_id    := rec.multorg_id;
      gn_empresa_id    := rec.empresa_id;
      --
      gv_nome_dblink    := null;
      gv_owner_obj      := null;
      gv_aspas          := null;
      gv_formato_dt_erp := gv_formato_data;
      --
      vn_fase := 3;
      --
      pkb_conhec_transp ( ev_cpf_cnpj => vv_cpf_cnpj_emit
                        , ed_dt_ini   => ed_dt_ini
                        , ed_dt_fin   => ed_dt_fin );
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_int_view_d100.pkb_integr_geral_empresa fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%type;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id => vn_loggenerico_id
                                     , ev_mensagem       => gv_mensagem_log
                                     , ev_resumo         => gv_mensagem_log
                                     , en_tipo_log       => erro_de_sistema );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_geral_empresa;
--
-------------------------------------------------------------------------------------------------------
end pk_int_view_d100;
/
