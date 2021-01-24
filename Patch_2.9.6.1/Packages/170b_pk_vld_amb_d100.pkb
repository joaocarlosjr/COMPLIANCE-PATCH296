create or replace package body csf_own.pk_vld_amb_d100 is

-------------------------------------------------------------------------------------------------------
-- Corpo do pacote da API para ler os conhecimentos de transporte de aquisição com DM_ST_PROC = 0 (Não validada)
-- e chamar os procedimentos para validar os dados
-------------------------------------------------------------------------------------------------------
--
-- Lê os dados dos impostos Retidos
procedure pkb_ler_conhec_transp_imp_ret ( est_log_generico    in out nocopy  dbms_sql.number_table
                                        , en_conhectransp_id  in             Conhec_Transp.id%TYPE
                                        )
is
   --
   vn_fase number     := 0;
   vn_cod_imposto     tipo_imposto.cd%type;
   vv_cd_tipo_ret_imp tipo_ret_imp.cd%type;
   vv_cod_receita     tipo_ret_imp_receita.cod_receita%type;
   --
   cursor c_conhec_transp_imp_ret is
      select ct.*
        from conhec_transp_imp_ret ct
       where ct.conhectransp_id = en_conhectransp_id;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_conhec_transp_imp_ret loop
      exit when c_conhec_transp_imp_ret%notfound or (c_conhec_transp_imp_ret%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api_d100.gt_row_ct_compdoc_pisefd := null;
      --
      vn_fase := 3;
      --
      begin
         select ti.cd
           into vn_cod_imposto
           from tipo_imposto ti
          where ti.id = rec.tipoimp_id;
      exception
         when others then
            vn_cod_imposto := -1;
      end;
      --
      begin
         select tr.cd
           into vv_cd_tipo_ret_imp
           from tipo_ret_imp tr
          where tr.tipoimp_id = rec.tipoimp_id
            and tr.id         = rec.tiporetimp_id;
      exception
         when others then
            vv_cd_tipo_ret_imp := '-1';
      end;
      --
      begin
         select trr.cod_receita
           into vv_cod_receita
           from tipo_ret_imp_receita trr
          where trr.tiporetimp_id = rec.tiporetimp_id
            and trr.id           = rec.tiporetimpreceita_id;
      exception
         when others then
            vv_cod_receita := '-1';
      end;
      --
      pk_csf_api_d100.gt_row_ct_impretefd.id              := rec.id;
      pk_csf_api_d100.gt_row_ct_impretefd.conhectransp_id := rec.conhectransp_id;
      pk_csf_api_d100.gt_row_ct_impretefd.vl_item         := rec.vl_item;
      pk_csf_api_d100.gt_row_ct_impretefd.vl_base_calc    := rec.vl_base_calc;
      pk_csf_api_d100.gt_row_ct_impretefd.vl_aliq         := rec.vl_aliq;
      pk_csf_api_d100.gt_row_ct_impretefd.vl_imp          := rec.vl_imp;
      --
      vn_fase := 4;
      --    
      pk_csf_api_d100.pkb_integr_ctimpretefd ( est_log_generico        => est_log_generico
                                             , est_ctimpretefd         => pk_csf_api_d100.gt_row_ct_impretefd
                                             , ev_cpf_cnpj_emit        => gv_cpf_cnpj_emit
                                             , ev_cod_imposto          => vn_cod_imposto
                                             , ev_cd_tipo_ret_imp      => vv_cd_tipo_ret_imp
                                             , ev_cod_receita          => vv_cod_receita
                                             , en_multorg_id           => gn_multorg_id );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_ct.gv_mensagem_log := 'Erro na pkb_ler_conhec_transp_imp_ret fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => pk_csf_api_d100.gv_cabec_log
                                           , ev_resumo          => pk_csf_api_d100.gv_mensagem_log
                                           , en_tipo_log        => pk_csf_api_d100.ERRO_DE_SISTEMA
                                           , en_referencia_id   => pk_csf_api_d100.gn_referencia_id
                                           , ev_obj_referencia  => pk_csf_api_d100.gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_d100.gv_mensagem_log);
      --
end pkb_ler_conhec_transp_imp_ret;
--
-- ============================================================================================================== --
-- Lê os dados das Informaçôes Comp. de Pis
procedure pkb_ler_ct_comp_doc_pis_efd ( est_log_generico    in out nocopy  dbms_sql.number_table
                                      , en_conhectransp_id  in             Conhec_Transp.id%TYPE
                                      )
is

   vn_fase               number := 0;

   cursor c_ct_comp_doc_pis_efd is
   select n.*
        , trim(f.cod_st)                                     cst_pis
        , trim(d.cd)                                         cod_base_calc_cred
        , trim(c.cod_cta)                                    cod_cta
     from ct_comp_doc_pis n
        , plano_conta c
        , base_calc_cred_pc d
        , cod_st        f
    where n.conhectransp_id   = en_conhectransp_id
      and n.codst_id          = f.id
      and n.planoconta_id     = c.id(+)
      and n.basecalccredpc_id = d.id(+);

begin
   --
   vn_fase := 1;
   --
   for rec in c_ct_comp_doc_pis_efd loop
      exit when c_ct_comp_doc_pis_efd%notfound or (c_ct_comp_doc_pis_efd%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api_d100.gt_row_ct_compdoc_pisefd := null;
      --
      vn_fase := 3;
      --
      pk_csf_api_d100.gt_row_ct_compdoc_pisefd.id                := rec.id;
      pk_csf_api_d100.gt_row_ct_compdoc_pisefd.conhectransp_id   := rec.conhectransp_id;
      pk_csf_api_d100.gt_row_ct_compdoc_pisefd.dm_ind_nat_frt    := rec.dm_ind_nat_frt;
      pk_csf_api_d100.gt_row_ct_compdoc_pisefd.vl_item           := rec.vl_item;
      pk_csf_api_d100.gt_row_ct_compdoc_pisefd.codst_id          := rec.codst_id;
      pk_csf_api_d100.gt_row_ct_compdoc_pisefd.basecalccredpc_id := rec.basecalccredpc_id;
      pk_csf_api_d100.gt_row_ct_compdoc_pisefd.vl_bc_pis         := rec.vl_bc_pis;
      pk_csf_api_d100.gt_row_ct_compdoc_pisefd.aliq_pis          := rec.aliq_pis;
      pk_csf_api_d100.gt_row_ct_compdoc_pisefd.vl_pis            := rec.vl_pis;
      pk_csf_api_d100.gt_row_ct_compdoc_pisefd.planoconta_id     := rec.planoconta_id;

      --
      vn_fase := 4;
      --    
      pk_csf_api_d100.pkb_integr_ctcompdoc_pisefd ( est_log_generico      => est_log_generico
                                                  , est_ctcompdoc_pisefd  => pk_csf_api_d100.gt_row_ct_compdoc_pisefd
                                                  , ev_cpf_cnpj_emit      => gv_cpf_cnpj_emit
                                                  , ev_cod_st             => rec.cst_pis
                                                  , ev_cod_bc_cred_pc     => rec.cod_base_calc_cred
                                                  , ev_cod_cta            => rec.cod_cta
                                                  , en_multorg_id         => gn_multorg_id
                                                   );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_ct.gv_mensagem_log := 'Erro na pkb_ler_ct_comp_doc_pis_efd fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api_d100.gv_cabec_log
                                     , ev_resumo          => pk_csf_api_d100.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api_d100.ERRO_DE_SISTEMA
                                     , en_referencia_id   => pk_csf_api_d100.gn_referencia_id
                                     , ev_obj_referencia  => pk_csf_api_d100.gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_d100.gv_mensagem_log);
      --
end pkb_ler_ct_comp_doc_pis_efd;

-------------------------------------------------------------------------------------------------------

-- Lê os dados das Informaçôes Comp. de Cofins
procedure pkb_ler_ct_comp_doc_cofins_efd ( est_log_generico    in out nocopy  dbms_sql.number_table
                                         , en_conhectransp_id  in             Conhec_Transp.id%TYPE
                                         )
is

   vn_fase               number := 0;

   cursor c_ct_comp_doc_cofins_efd is
   select n.*
        , trim(f.cod_st)                                     cst_cofins
        , trim(d.cd)                                         cod_base_calc_cred
        , trim(c.cod_cta)                                    cod_cta
     from ct_comp_doc_cofins n
        , plano_conta c
        , base_calc_cred_pc d
        , cod_st        f
    where n.conhectransp_id   = en_conhectransp_id
      and n.codst_id          = f.id
      and n.planoconta_id     = c.id(+)
      and n.basecalccredpc_id = d.id(+);

begin
   --
   vn_fase := 1;
   --
   for rec in c_ct_comp_doc_cofins_efd loop
      exit when c_ct_comp_doc_cofins_efd%notfound or (c_ct_comp_doc_cofins_efd%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api_d100.gt_row_ct_compdoc_cofinsefd := null;
      --
      vn_fase := 3;
      --
      pk_csf_api_d100.gt_row_ct_compdoc_cofinsefd.id                := rec.id;
      pk_csf_api_d100.gt_row_ct_compdoc_cofinsefd.conhectransp_id   := rec.conhectransp_id;
      pk_csf_api_d100.gt_row_ct_compdoc_cofinsefd.dm_ind_nat_frt    := rec.dm_ind_nat_frt;
      pk_csf_api_d100.gt_row_ct_compdoc_cofinsefd.vl_item           := rec.vl_item;
      pk_csf_api_d100.gt_row_ct_compdoc_cofinsefd.codst_id          := rec.codst_id;
      pk_csf_api_d100.gt_row_ct_compdoc_cofinsefd.basecalccredpc_id := rec.basecalccredpc_id;
      pk_csf_api_d100.gt_row_ct_compdoc_cofinsefd.vl_bc_cofins      := rec.vl_bc_cofins;
      pk_csf_api_d100.gt_row_ct_compdoc_cofinsefd.aliq_cofins       := rec.aliq_cofins;
      pk_csf_api_d100.gt_row_ct_compdoc_cofinsefd.vl_cofins         := rec.vl_cofins;
      pk_csf_api_d100.gt_row_ct_compdoc_cofinsefd.planoconta_id     := rec.planoconta_id;

      --
      vn_fase := 4;
      --    
      pk_csf_api_d100.pkb_integr_ctcompdoc_cofinsefd ( est_log_generico         =>  est_log_generico
                                                     , est_ctcompdoc_cofinsefd  =>  pk_csf_api_d100.gt_row_ct_compdoc_cofinsefd
                                                     , ev_cpf_cnpj_emit         =>  gv_cpf_cnpj_emit
                                                     , ev_cod_st                =>  rec.cst_cofins
                                                     , ev_cod_bc_cred_pc        =>  rec.cod_base_calc_cred
                                                     , ev_cod_cta               =>  rec.cod_cta
                                                     , en_multorg_id            => gn_multorg_id
                                                     );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_ct.gv_mensagem_log := 'Erro na pkb_ler_ct_comp_doc_cofins_efd fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api_d100.gv_cabec_log
                                     , ev_resumo          => pk_csf_api_d100.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api_d100.ERRO_DE_SISTEMA
                                     , en_referencia_id   => pk_csf_api_d100.gn_referencia_id
                                     , ev_obj_referencia  => pk_csf_api_d100.gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_d100.gv_mensagem_log);
      --
end pkb_ler_ct_comp_doc_cofins_efd;

-------------------------------------------------------------------------------------------------------

-- Lê os dados do Analitico
procedure pkb_ler_ct_reg_anal ( est_log_generico    in out nocopy  dbms_sql.number_table
                              , en_conhectransp_id  in             Conhec_Transp.id%TYPE
                              )
is

   vn_fase               number := 0;
   --
   cursor c_ct_reg_anal is
   select a.*
        , trim(b.cod_st)  cod_st
        , c.cd            cfop
        , trim(d.cod_obs) cod_obs
     from ct_reg_anal a
        , cod_st b
        , cfop c
        , obs_lancto_fiscal d
    where a.conhectransp_id = en_conhectransp_id
      and a.codst_id           = b.id
      and a.cfop_id            = c.id
      and a.obslanctofiscal_id = d.id(+);
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_ct_reg_anal loop
      exit when c_ct_reg_anal%notfound or (c_ct_reg_anal%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api_d100.gt_row_ct_reg_anal := null;
      --
      vn_fase := 3;
      --
      pk_csf_api_d100.gt_row_ct_reg_anal.id                  := rec.id;
      pk_csf_api_d100.gt_row_ct_reg_anal.conhectransp_id     := rec.conhectransp_id;
      pk_csf_api_d100.gt_row_ct_reg_anal.codst_id            := rec.codst_id;
      pk_csf_api_d100.gt_row_ct_reg_anal.cfop_id             := rec.cfop_id;
      pk_csf_api_d100.gt_row_ct_reg_anal.dm_orig_merc        := rec.dm_orig_merc;
      pk_csf_api_d100.gt_row_ct_reg_anal.aliq_icms           := rec.aliq_icms;
      pk_csf_api_d100.gt_row_ct_reg_anal.vl_opr              := rec.vl_opr;
      pk_csf_api_d100.gt_row_ct_reg_anal.vl_bc_icms          := rec.vl_bc_icms;
      pk_csf_api_d100.gt_row_ct_reg_anal.vl_icms             := rec.vl_icms;
      pk_csf_api_d100.gt_row_ct_reg_anal.vl_red_bc           := rec.vl_red_bc;
      pk_csf_api_d100.gt_row_ct_reg_anal.obslanctofiscal_id  := rec.obslanctofiscal_id;
      --
      vn_fase := 4;
      --    
      pk_csf_api_d100.pkb_integr_ct_d190 ( est_log_generico => est_log_generico
                                         , est_ct_reg_anal  => pk_csf_api_d100.gt_row_ct_reg_anal
                                         , ev_cod_st        => rec.cod_st
                                         , en_cfop          => rec.cfop
                                         , ev_cod_obs       => rec.cod_obs
                                         , en_multorg_id    => gn_multorg_id
                                         );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_ct.gv_mensagem_log := 'Erro na pkb_ler_ct_reg_anal fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api_d100.gv_cabec_log
                                     , ev_resumo          => pk_csf_api_d100.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api_d100.ERRO_DE_SISTEMA
                                     , en_referencia_id   => pk_csf_api_d100.gn_referencia_id
                                     , ev_obj_referencia  => pk_csf_api_d100.gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_d100.gv_mensagem_log);
      --
end pkb_ler_ct_reg_anal;

-------------------------------------------------------------------------------------------------------

-- Lê os dados do Processo Referenciado
procedure pkb_ler_ct_proc_ref_efd ( est_log_generico    in out nocopy  dbms_sql.number_table
                                  , en_conhectransp_id  in             Conhec_Transp.id%TYPE
                                   )
is

   vn_fase               number := 0;

   cursor c_ct_proc_ref_efd is
   select r.*
        , trim(o.cd) cod_orig_proc
    from  ct_proc_ref r
        , orig_proc o
    where r.conhectransp_id = en_conhectransp_id
      and r.origproc_id = o.id;

begin
   --
   vn_fase := 1;
   --
   for rec in c_ct_proc_ref_efd loop
      exit when c_ct_proc_ref_efd%notfound or (c_ct_proc_ref_efd%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api_d100.gt_row_ct_procrefefd := null;
      --
      vn_fase := 3;
      --
      pk_csf_api_d100.gt_row_ct_procrefefd.id                := rec.id;
      pk_csf_api_d100.gt_row_ct_procrefefd.conhectransp_id   := rec.conhectransp_id;
      pk_csf_api_d100.gt_row_ct_procrefefd.num_proc          := rec.num_proc;
      pk_csf_api_d100.gt_row_ct_procrefefd.origproc_id       := rec.origproc_id;

      --
      vn_fase := 4;
      --    
       pk_csf_api_d100.pkb_integr_ctprocrefefd ( est_log_generico => est_log_generico
                                               , est_ctprocrefefd => pk_csf_api_d100.gt_row_ct_procrefefd
                                               , en_cd_orig_proc  => rec.cod_orig_proc );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_ct.gv_mensagem_log := 'Erro na pkb_ler_ct_proc_ref_efd fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api_d100.gv_cabec_log
                                     , ev_resumo          => pk_csf_api_d100.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api_d100.ERRO_DE_SISTEMA
                                     , en_referencia_id   => pk_csf_api_d100.gn_referencia_id
                                     , ev_obj_referencia  => pk_csf_api_d100.gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_d100.gv_mensagem_log);
      --
end pkb_ler_ct_proc_ref_efd;

-------------------------------------------------------------------------------------------------------

-- Lê os dados do Diferencial de aliquota
procedure pkb_ler_ct_dif_aliq ( est_log_generico    in out nocopy  dbms_sql.number_table
                              , en_conhectransp_id  in             Conhec_Transp.id%TYPE
                              )
is

   vn_fase               number := 0;

   cursor c_ctdifaliq is
      select d.*
        from ct_dif_aliq d
       where d.conhectransp_id = en_conhectransp_id;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_ctdifaliq loop
      exit when c_ctdifaliq%notfound or (c_ctdifaliq%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api_d100.gt_row_ct_dif_aliq := null;
      --
      vn_fase := 3;
      --
      pk_csf_api_d100.gt_row_ct_dif_aliq.conhectransp_id  := rec.conhectransp_id;
      pk_csf_api_d100.gt_row_ct_dif_aliq.aliq_interna     := rec.aliq_interna;
      pk_csf_api_d100.gt_row_ct_dif_aliq.aliq_ie          := rec.aliq_ie;	  
      pk_csf_api_d100.gt_row_ct_dif_aliq.bc_dif_aliq      := rec.bc_dif_aliq;
      pk_csf_api_d100.gt_row_ct_dif_aliq.vl_dif_aliq      := rec.vl_dif_aliq;
      pk_csf_api_d100.gt_row_ct_dif_aliq.bc_fcp           := rec.bc_fcp;
      pk_csf_api_d100.gt_row_ct_dif_aliq.aliq_fcp         := rec.aliq_fcp;
      pk_csf_api_d100.gt_row_ct_dif_aliq.vl_fcp           := rec.vl_fcp;
      pk_csf_api_d100.gt_row_ct_dif_aliq.dm_tipo          := rec.dm_tipo;	
      --		 
      vn_fase := 4;
      --    
      pk_csf_api_d100.pkb_integr_ct_dif_aliq ( est_log_generico         => est_log_generico
                                             , est_row_ct_dif_aliq      => pk_csf_api_d100.gt_row_ct_dif_aliq
                                             , en_conhectransp_id       => en_conhectransp_id );		 
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_ct.gv_mensagem_log := 'Erro na pkb_ler_ct_dif_aliq fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api_d100.gv_cabec_log
                                     , ev_resumo          => pk_csf_api_d100.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api_d100.ERRO_DE_SISTEMA
                                     , en_referencia_id   => pk_csf_api_d100.gn_referencia_id
                                     , ev_obj_referencia  => pk_csf_api_d100.gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_d100.gv_mensagem_log);
      --
end pkb_ler_ct_dif_aliq;

-------------------------------------------------------------------------------------------------------
-- Procedimento faz a leitura das Informações do Emitente do CT

procedure pkb_ler_Conhec_Transp_Emit ( est_log_generico       in  out nocopy  dbms_sql.number_table
                                     , en_conhectransp_id     in  Conhec_Transp.id%TYPE
                                     , ev_cod_part            in  pessoa.cod_part%TYPE )
is

   cursor c_Conhec_Transp_Emit is
   select ad.*
     from Conhec_Transp_Emit  ad
    where ad.conhectransp_id = en_conhectransp_id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_Conhec_Transp_Emit loop
      exit when c_Conhec_Transp_Emit%notfound or c_Conhec_Transp_Emit%notfound is null;
      --
      vn_fase := 2;
      --
      pk_csf_api_d100.gt_row_conhec_transp_emit := null;
      --
      vn_fase := 3;
      --
      pk_csf_api_d100.gt_row_conhec_transp_emit.id                := rec.id;
      pk_csf_api_d100.gt_row_conhec_transp_emit.conhectransp_id   := rec.conhectransp_id;
      pk_csf_api_d100.gt_row_conhec_transp_emit.cnpj              := rec.cnpj;
      pk_csf_api_d100.gt_row_conhec_transp_emit.ie                := rec.ie;
      pk_csf_api_d100.gt_row_conhec_transp_emit.nome              := rec.nome;
      pk_csf_api_d100.gt_row_conhec_transp_emit.nome_fant         := rec.nome_fant;
      pk_csf_api_d100.gt_row_conhec_transp_emit.lograd            := rec.lograd;
      pk_csf_api_d100.gt_row_conhec_transp_emit.nro               := rec.nro;
      pk_csf_api_d100.gt_row_conhec_transp_emit.compl             := rec.compl;
      pk_csf_api_d100.gt_row_conhec_transp_emit.bairro            := rec.bairro;
      pk_csf_api_d100.gt_row_conhec_transp_emit.ibge_cidade       := rec.ibge_cidade;
      pk_csf_api_d100.gt_row_conhec_transp_emit.descr_cidade      := rec.descr_cidade;
      pk_csf_api_d100.gt_row_conhec_transp_emit.cep               := rec.cep;
      pk_csf_api_d100.gt_row_conhec_transp_emit.uf                := rec.uf;
      pk_csf_api_d100.gt_row_conhec_transp_emit.cod_pais          := rec.cod_pais;
      pk_csf_api_d100.gt_row_conhec_transp_emit.descr_pais        := rec.descr_pais;
      pk_csf_api_d100.gt_row_conhec_transp_emit.fone              := rec.fone;


      --
      vn_fase := 4;  
      -- Chama procedimento que valida as Informações do Emitente do CT
      pk_csf_api_d100.pkb_integr_conhec_transp_emit( est_log_generico           => est_log_generico
                                                   , est_row_conhec_transp_emit => pk_csf_api_d100.gt_row_conhec_transp_emit
                                                   , en_conhectransp_id         => en_conhectransp_id
                                                   , ev_cod_part                => ev_cod_part );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_ct.gv_mensagem_log := 'Erro na pkb_ler_Conhec_Transp_Emit fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => pk_csf_api_ct.gv_cabec_log
                                        , ev_resumo          => pk_csf_api_ct.gv_mensagem_log
                                        , en_tipo_log        => pk_csf_api_ct.ERRO_DE_SISTEMA
                                        , en_referencia_id   => en_conhectransp_id
                                        , ev_obj_referencia  => 'CONHEC_TRANSP' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_ct.gv_mensagem_log);
      --
end pkb_ler_Conhec_Transp_Emit;

-------------------------------------------------------------------------------------------------------
-- Procedimento faz a leitura dos Conhec. Transp. de Aquisição com DM_ST_PROC = 0 (Não validada)
-- e o encadiamento da validação

procedure pkb_ler_ct_d100
is
   --
   vn_fase               number := 0;
   vt_log_generico       dbms_sql.number_table;
   vn_conhectransp_id    conhec_transp.id%TYPE;
   vn_dm_st_proc         conhec_transp.dm_st_proc%TYPE;
   vv_cod_part           pessoa.cod_part%TYPE;
   vv_cod_sit_doc        sit_docto.cd%TYPE;
   vn_vl_serv            conhec_transp_vlprest.vl_prest_serv%TYPE   := 0;
   vn_vl_doc             conhec_transp_vlprest.vl_docto_fiscal%TYPE := 0;
   vn_vl_desc            conhec_transp_vlprest.vl_desc%TYPE         := 0;
   vv_cod_infor          infor_comp_dcto_fiscal.cod_infor%TYPE;
   vn_vl_base_calc       conhec_transp_imp.vl_base_calc%TYPE        := 0;
   vn_vl_imp_trib        conhec_transp_imp.vl_imp_trib%TYPE         := 0;
   --
   cursor c_ct_d100 is
   select ct.*
        , mf.cod_mod
        , so.sigla      sist_orig
        , uo.cd         unid_org
        , no.cod_nat
     from Conhec_Transp ct
        , Mod_Fiscal    mf
        , sist_orig     so
        , unid_org      uo
        , nat_oper      no
    where ct.dm_st_proc      = 0 -- Não validada
      and ct.dm_ind_emit     = 1
      and ct.dm_arm_cte_terc = 0 -- 0-Não, 1-Sim
      and mf.cod_mod        in ('07', '08', '8B', '09', '10', '11', '26', '27', '57', '67') -- Busca apenas conhec. transp.
      and mf.id              = ct.modfiscal_id
      and so.id(+)           = ct.sistorig_id
      and uo.id(+)           = ct.unidorg_id
      and no.id              = ct.natoper_id
      and not exists ( select 1 from conhec_transp_canc ctc
                        where ctc.conhectransp_id = ct.id )
      and rownum <= 50
    order by ct.id;
   --
begin
   --
   vn_fase := 1;
   -- Lê as  os conhec. transp. e faz o processo de validação encadeado
   for rec in c_ct_d100 loop
      --
      vn_fase := 2;
      -- limpa o array quando inicia uma nova NF Serv. Cont.
      vt_log_generico.delete;
      --
      pk_csf_api_d100.gt_row_conhec_transp := null;
      gv_cpf_cnpj_emit                     := null;
      --
      vn_fase := 3;
      -- Seta a referencia_id
      pk_csf_api_d100.gn_referencia_id := rec.id;
      --
      vn_fase := 3.1;
      -- Seta a váriavel usada no log_generico
      vn_conhectransp_id := rec.id;
      --
      vn_fase := 4;
      /*----------- As demais váriaveis serão alimentadas no corpo da procedure----
      ------------- para não ficar tão pesado o cursor.----------------------------*/
      gv_cpf_cnpj_emit := trim( pk_csf.fkg_cnpj_ou_cpf_empresa(en_empresa_id => rec.empresa_id) );
      gn_multorg_id    := pk_csf.fkg_multorg_id_empresa(en_empresa_id => rec.empresa_id);
      --
      vn_fase := 4.1;
      -- Busca Cód. Participante
      if nvl(rec.pessoa_id, 0) > 0 then
         --
         vv_cod_part := trim( pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => rec.pessoa_id ) );
         --
      end if;
      --
      vn_fase := 4.2;
      -- Busca o Cód. da Situação do Documentos
      vv_cod_sit_doc := trim( pk_csf.fkg_Sit_Docto_cd ( en_sitdoc_id => rec.sitdocto_id ) );
      --
      vn_fase := 4.3;
      -- Busca Valores de serviço
      -- Ps.: Há mais de uma maneira fazer essa busca. Porém, escolhi essa.
      Begin
         select a.vl_prest_serv
              , a.vl_docto_fiscal
              , a.vl_desc
           into vn_vl_serv
              , vn_vl_doc
              , vn_vl_desc
           from conhec_transp_vlprest a
          where a.conhectransp_id = rec.id;
      exception
         when others then
            vn_vl_serv := 0;
            vn_vl_doc  := 0;
            vn_vl_desc := 0;
      end;
      --
      vn_fase := 4.4;
      -- Busca o Codigo da informação complementar do documento fiscal
      vv_cod_infor := trim( pk_csf.fkg_Infor_Comp_Dcto_Fiscal_cod( en_inforcompdctofiscal_id => rec.inforcompdctofiscal_id) );
      --
      vn_fase := 4.5;
      -- Busca os Valores Referentes ao ICMS
      -- Ps.: Há mais de uma maneira fazer essa busca. Porém, escolhi essa.
      Begin
         select a.vl_base_calc
              , a.vl_imp_trib
           into vn_vl_base_calc
              , vn_vl_imp_trib
           from conhec_transp_imp a,
                tipo_imposto t
          where a.conhectransp_id = rec.id
            and t.cd = 1 -- ICMS
            and a.tipoimp_id = t.id;
      exception
         when others then
            vn_vl_base_calc := 0;
            vn_vl_imp_trib  := 0;
      end;
      --
      /*---------------------------------------------------------------------------*/
      --
      vn_fase := 4.1;
      -- Chama o Processo de validação dos dados do Conhec. Transp.
      pk_csf_api_d100.pkb_integr_ct_d100 ( est_log_generico    => vt_log_generico
                                         , ev_cpf_cnpj_emit    => gv_cpf_cnpj_emit
                                         , en_dm_ind_emit      => rec.dm_ind_emit
                                         , en_dm_ind_oper      => rec.dm_ind_oper
                                         , ev_cod_part         => vv_cod_part
                                         , ev_cod_mod          => rec.cod_mod
                                         , ev_serie            => rec.serie
                                         , ev_subserie         => rec.subserie
                                         , en_nro_nf           => rec.nro_ct
                                         , ev_sit_docto        => vv_cod_sit_doc
                                         , ev_nro_chave_cte    => rec.nro_chave_cte
                                         , en_dm_tp_cte        => rec.dm_tp_cte
                                         , ev_chave_cte_ref    => rec.chave_cte_ref
                                         , ed_dt_emiss         => rec.dt_hr_emissao
                                         , ed_dt_sai_ent       => rec.dt_sai_ent
                                         , en_vl_doc           => vn_vl_doc
                                         , en_vl_desc          => vn_vl_desc
                                         , en_dm_ind_frt       => rec.dm_ind_frt
                                         , en_vl_serv          => vn_vl_serv
                                         , en_vl_bc_icms       => vn_vl_base_calc
                                         , en_vl_icms          => vn_vl_imp_trib
                                         , en_vl_nt            => vn_vl_imp_trib
                                         , ev_cod_inf          => vv_cod_infor
                                         , ev_cod_cta          => rec.cod_cta
                                         , ev_cod_nat_oper     => rec.cod_nat
                                         , en_multorg_id       => gn_multorg_id
                                         , sn_conhectransp_id  => rec.id
                                         , en_ibge_cidade_ini  => rec.ibge_cidade_ini
                                         , ev_descr_cidade_ini => rec.descr_cidade_ini
                                         , ev_sigla_uf_ini     => rec.sigla_uf_ini
                                         , en_ibge_cidade_fim  => rec.ibge_cidade_fim
                                         , ev_descr_cidade_fim => rec.descr_cidade_fim
                                         , ev_sigla_uf_fim     => rec.sigla_uf_fim
                                         , ev_cd_unid_org      => rec.unid_org
                                         );
      --
      vn_fase := 5;	  
      --Lê as informações referentes aos registros de Conhecimento de Transporte
      pkb_ler_Conhec_Transp_Emit ( est_log_generico   => vt_log_generico
                                 , en_conhectransp_id => rec.id
                                 , ev_cod_part        => vv_cod_part);	  
      vn_fase := 6;
      -- Lê os dados do Analitico
      pkb_ler_ct_reg_anal ( est_log_generico     => vt_log_generico
                          , en_conhectransp_id   => rec.id );
      --
      vn_fase := 7;
      -- Lê os dados das Informaçôes Comp. de Pis
      pkb_ler_ct_comp_doc_pis_efd ( est_log_generico    => vt_log_generico
                                  , en_conhectransp_id  => rec.id );
      --
      vn_fase := 8;
      -- Lê os dados das Informaçôes Comp. de Cofins
      pkb_ler_ct_comp_doc_cofins_efd ( est_log_generico     => vt_log_generico
                                 , en_conhectransp_id   => rec.id );
      --
      vn_fase := 9;
      -- Lê os dados do Processo Referenciado
      pkb_ler_ct_proc_ref_efd ( est_log_generico    => vt_log_generico
                              , en_conhectransp_id  => rec.id );
      --
      vn_fase := 10;
      --	  
      -- Lê os dados do diferencial de aliquota
      pkb_ler_ct_dif_aliq ( est_log_generico    => vt_log_generico
                          , en_conhectransp_id  => rec.id );
      --
      vn_fase := 11;
      --Lê os dados dos impostos Retidos
      pkb_ler_conhec_transp_imp_ret ( est_log_generico    => vt_log_generico
                                    , en_conhectransp_id  => rec.id );
      --                              
      vn_fase := 12;
      -- Chama o processo que consiste a informação do Conhec. Transp.
      pk_csf_api_d100.pkb_consiste_cte ( est_log_generico     => vt_log_generico
                                       , en_conhectransp_id   => rec.id );
      --
      vn_fase := 99;
      --
      -- Se registrou algum log, altera o Conhec. Transp. para dm_st_proc = 10 - "Erro de Validação"
      if nvl(vt_log_generico.count,0) > 0 then
         --
         vn_fase := 99.1;
         --
         begin
            --
            vn_fase := 99.2;
            --
             update Conhec_Transp set dm_st_proc = 10
                                 , dt_st_proc = sysdate
             where id = rec.id;
             --
             commit;
              --
         exception
            when others then
               --
               pk_csf_api_ct.gv_mensagem_log := 'Erro na pkb_ler_ct_d100 fase(' || vn_fase || '):' || sqlerrm;
               --
               declare
                  vn_loggenerico_id  log_generico_ct.id%TYPE;
               begin
                  --
                  pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                              , ev_mensagem        => pk_csf_api_d100.gv_mensagem_log
                                              , ev_resumo          => null
                                              , en_tipo_log        => pk_csf_api_d100.ERRO_DE_SISTEMA
                                              , en_referencia_id   => rec.id
                                              , ev_obj_referencia  => pk_csf_api_d100.gv_obj_referencia );
               --
               exception
                  when others then
                     null;
               end;
               --
               raise_application_error (-20101, pk_csf_api_d100.gv_mensagem_log);
               --
         end;
      else
         --
         update Conhec_Transp set dm_st_proc = 4
                                , dt_st_proc = sysdate
          where id = rec.id;
         --
         commit;
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_ct.gv_mensagem_log := 'Erro na pkb_ler_ct_d100 fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api_d100.gv_cabec_log
                                     , ev_resumo          => pk_csf_api_d100.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api_d100.ERRO_DE_SISTEMA
                                     , en_referencia_id   => vn_conhectransp_id
                                     , ev_obj_referencia  => pk_csf_api_d100.gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_d100.gv_mensagem_log);
      --
end pkb_ler_ct_d100;

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a validação dos Conhec. de Transp. de Aquisição
procedure pkb_integracao 
is
   --
   vn_fase   number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   -- seta o tipo de integração que será feito
   -- 0 - Válida e Atualiza os Log de Ocorrência
   -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
   -- Todos os procedimentos de integração fazem referência a ele
   pk_csf_api_d100.pkb_seta_tipo_integr ( en_tipo_integr => 0 );
   --
   vn_fase := 1.1;
   --
   pk_csf_api_d100.pkb_seta_obj_ref ( ev_objeto => 'CONHEC_TRANSP');
   --
   vn_fase := 2;
   --
   -- inicia a leitura para validação dos dados da nota fiscal
   pkb_ler_ct_d100;
   --
   vn_fase := 3;
   --
   -- Finaliza o log genérico para a integração 
   -- das Notas Fiscais de Serviço Contínuos
   pk_csf_api_ct.pkb_finaliza_log_generico_ct;
   --
   vn_fase := 11;
   --
   pk_csf_api_d100.gn_tipo_integr := null ;
   --
exception
   when others then
      --
      pk_csf_api_ct.gv_mensagem_log := 'Erro na pk_vld_amb_d100.pkb_integracao fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api_ct.gv_mensagem_log
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_csf_api_ct.ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_ct.gv_mensagem_log);
      --
end pkb_integracao;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura dos Conhec. Transp. de Aquisição conforme ID

procedure pkb_vld_ct_d100 ( en_conhectransp_id  in      conhec_transp.id%type
                          , sn_erro             in out  number         -- 0-Não; 1-Sim
                          , en_loteintws_id     in      lote_int_ws.id%type
                          )
is
   --
   vn_fase               number := 0;
   vt_log_generico       dbms_sql.number_table;
   vn_conhectransp_id    conhec_transp.id%TYPE;
   vn_dm_st_proc         conhec_transp.dm_st_proc%TYPE;
   vv_cod_part           pessoa.cod_part%TYPE;
   vv_cod_sit_doc        sit_docto.cd%TYPE;
   vn_vl_serv            conhec_transp_vlprest.vl_prest_serv%TYPE   := 0;
   vn_vl_doc             conhec_transp_vlprest.vl_docto_fiscal%TYPE := 0;
   vn_vl_desc            conhec_transp_vlprest.vl_desc%TYPE         := 0;
   vv_cod_infor          infor_comp_dcto_fiscal.cod_infor%TYPE;
   vn_vl_base_calc       conhec_transp_imp.vl_base_calc%TYPE        := 0;
   vn_vl_imp_trib        conhec_transp_imp.vl_imp_trib%TYPE         := 0;
   --
   cursor c_ct_d100 is
   /*select ct.*
        , mf.cod_mod
        , so.sigla      sist_orig
        , uo.cd         unid_org
        , no.cod_nat
     from Conhec_Transp ct
        , Mod_Fiscal    mf
        , sist_orig     so
        , unid_org      uo
        , nat_oper      no
    where ct.id              = en_conhectransp_id
      and ct.dm_ind_emit     = 1
      and ct.dm_arm_cte_terc = 0 -- 0-Não, 1-Sim
      and mf.cod_mod        in ('07', '08', '8B', '09', '10', '11', '26', '27', '57', '67') -- Busca apenas conhec. transp.
      and mf.id              = ct.modfiscal_id
      and so.id(+)           = ct.sistorig_id
      and uo.id(+)           = ct.unidorg_id
      and no.id(+)           = ct.natoper_id
      and not exists ( select 1 from conhec_transp_canc ctc
                        where ctc.conhectransp_id = ct.id )
    order by ct.id; */
   --
   select ct.*
        , mf.cod_mod
        , so.sigla sist_orig
        , uo.cd unid_org
        , no.cod_nat
     from Conhec_Transp ct
        , Mod_Fiscal mf
        , sist_orig so
        , unid_org uo
        , nat_oper no
    where ct.id = en_conhectransp_id
      --and ct.dm_ind_emit = 1
      --and ct.dm_arm_cte_terc = 0 -- 0-Não, 1-Sim
      and mf.cod_mod in ('07', '08', '8B', '09', '10', '11', '26', '27', '57', '67') -- Busca apenas conhec. transp.
      and mf.id = ct.modfiscal_id
      and so.id(+) = ct.sistorig_id
      and uo.id(+) = ct.unidorg_id
      and no.id(+) = ct.natoper_id
     and not exists ( select 1 from conhec_transp_canc ctc
                       where ctc.conhectransp_id = ct.id )
    order by ct.id;   
   --   
begin
   --
   vn_fase := 1;
   --
   pk_csf_api_d100.pkb_seta_tipo_integr ( en_tipo_integr => 0 );
   --
   vn_fase := 1.1;
   --
   pk_csf_api_d100.pkb_seta_obj_ref ( ev_objeto => 'CONHEC_TRANSP');
   --
   -- Lê as  os conhec. transp. e faz o processo de validação encadeado
   for rec in c_ct_d100 loop
      --
      vn_fase := 2;
      -- limpa o array quando inicia uma nova NF Serv. Cont.
      vt_log_generico.delete;
      --
      pk_csf_api_d100.gt_row_conhec_transp := null;
      gv_cpf_cnpj_emit                     := null;
      --
      vn_fase := 3;
      -- Seta a referencia_id
      pk_csf_api_d100.gn_referencia_id := rec.id; 
      --
      vn_fase := 3.1;
      -- Seta a váriavel usada no log_generico
      vn_conhectransp_id := rec.id;
      --
      vn_fase := 4;
      /*----------- As demais váriaveis serão alimentadas no corpo da procedure----
      ------------- para não ficar tão pesado o cursor.----------------------------*/
      gv_cpf_cnpj_emit := trim( pk_csf.fkg_cnpj_ou_cpf_empresa(en_empresa_id => rec.empresa_id) );
      gn_multorg_id    := pk_csf.fkg_multorg_id_empresa(en_empresa_id => rec.empresa_id);
      --
      vn_fase := 4.1;
      -- Busca Cód. Participante
      if nvl(rec.pessoa_id, 0) > 0 then
         --
         vv_cod_part := trim( pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => rec.pessoa_id ) );
         --
      end if;
      --
      vn_fase := 4.2;
      -- Busca o Cód. da Situação do Documentos
      vv_cod_sit_doc := trim( pk_csf.fkg_Sit_Docto_cd ( en_sitdoc_id => rec.sitdocto_id ) );
      --
      vn_fase := 4.3;  
      -- Busca Valores de serviço
      -- Ps.: Há mais de uma maneira fazer essa busca. Porém, escolhi essa.
      Begin
         select a.vl_prest_serv
              , a.vl_docto_fiscal
              , a.vl_desc
           into vn_vl_serv
              , vn_vl_doc
              , vn_vl_desc
           from conhec_transp_vlprest a
          where a.conhectransp_id = rec.id;
      exception
         when others then
            vn_vl_serv := 0;
            vn_vl_doc  := 0;
            vn_vl_desc := 0;
      end;
      --
      vn_fase := 4.4;
      -- Busca o Codigo da informação complementar do documento fiscal
      vv_cod_infor := trim( pk_csf.fkg_Infor_Comp_Dcto_Fiscal_cod( en_inforcompdctofiscal_id => rec.inforcompdctofiscal_id) );
      --
      vn_fase := 4.5;
      -- Busca os Valores Referentes ao ICMS
      -- Ps.: Há mais de uma maneira fazer essa busca. Porém, escolhi essa.
      Begin
         select a.vl_base_calc
              , a.vl_imp_trib
           into vn_vl_base_calc
              , vn_vl_imp_trib
           from conhec_transp_imp a,
                tipo_imposto t
          where a.conhectransp_id = rec.id
            and t.cd = 1 -- ICMS
            and a.tipoimp_id = t.id;
      exception
         when others then
            vn_vl_base_calc := 0;
            vn_vl_imp_trib  := 0;
      end;
      --
      /*---------------------------------------------------------------------------*/
      --
      vn_fase := 4.1;
      -- Chama o Processo de validação dos dados do Conhec. Transp.
      pk_csf_api_d100.pkb_integr_ct_d100 ( est_log_generico    => vt_log_generico
                                         , ev_cpf_cnpj_emit    => gv_cpf_cnpj_emit
                                         , en_dm_ind_emit      => rec.dm_ind_emit
                                         , en_dm_ind_oper      => rec.dm_ind_oper
                                         , ev_cod_part         => vv_cod_part
                                         , ev_cod_mod          => rec.cod_mod
                                         , ev_serie            => rec.serie
                                         , ev_subserie         => rec.subserie
                                         , en_nro_nf           => rec.nro_ct
                                         , ev_sit_docto        => vv_cod_sit_doc
                                         , ev_nro_chave_cte    => rec.nro_chave_cte
                                         , en_dm_tp_cte        => rec.dm_tp_cte
                                         , ev_chave_cte_ref    => rec.chave_cte_ref
                                         , ed_dt_emiss         => rec.dt_hr_emissao
                                         , ed_dt_sai_ent       => rec.dt_sai_ent
                                         , en_vl_doc           => vn_vl_doc
                                         , en_vl_desc          => vn_vl_desc
                                         , en_dm_ind_frt       => rec.dm_ind_frt
                                         , en_vl_serv          => vn_vl_serv
                                         , en_vl_bc_icms       => vn_vl_base_calc
                                         , en_vl_icms          => vn_vl_imp_trib
                                         , en_vl_nt            => vn_vl_imp_trib
                                         , ev_cod_inf          => vv_cod_infor
                                         , ev_cod_cta          => rec.cod_cta
                                         , ev_cod_nat_oper     => rec.cod_nat
                                         , en_multorg_id       => gn_multorg_id
                                         , sn_conhectransp_id  => rec.id 
                                         , en_loteintws_id     => en_loteintws_id
                                         , en_cfop_id          => rec.cfop_id
                                         , en_ibge_cidade_ini  => rec.ibge_cidade_ini
                                         , ev_descr_cidade_ini => rec.descr_cidade_ini
                                         , ev_sigla_uf_ini     => rec.sigla_uf_ini
                                         , en_ibge_cidade_fim  => rec.ibge_cidade_fim
                                         , ev_descr_cidade_fim => rec.descr_cidade_fim
                                         , ev_sigla_uf_fim     => rec.sigla_uf_fim
                                         , ev_dm_modal         => rec.dm_modal
                                         , en_dm_tp_serv       => rec.dm_tp_serv
                                         , ev_cd_unid_org      => rec.unid_org
                                         );
      --
      vn_fase := 5;	  
      --Lê as informações referentes aos registros de Conhecimento de Transporte
      pkb_ler_Conhec_Transp_Emit ( est_log_generico   => vt_log_generico
                                 , en_conhectransp_id => rec.id
                                 , ev_cod_part        => vv_cod_part);	  
      --
      vn_fase := 6;
      -- Lê os dados do Analitico
      pkb_ler_ct_reg_anal ( est_log_generico     => vt_log_generico
                          , en_conhectransp_id   => rec.id );
      --
      vn_fase := 7;
      -- Lê os dados das Informaçôes Comp. de Pis
      pkb_ler_ct_comp_doc_pis_efd ( est_log_generico    => vt_log_generico
                                  , en_conhectransp_id  => rec.id );
      --
      vn_fase := 8;
      -- Lê os dados das Informaçôes Comp. de Cofins
      pkb_ler_ct_comp_doc_cofins_efd ( est_log_generico     => vt_log_generico
                                     , en_conhectransp_id   => rec.id );
      --
      vn_fase := 9;
      -- Lê os dados do Processo Referenciado
      pkb_ler_ct_proc_ref_efd ( est_log_generico    => vt_log_generico
                              , en_conhectransp_id  => rec.id );
      --
      vn_fase := 10;
      --Lê os dados dos impostos Retidos
      pkb_ler_conhec_transp_imp_ret ( est_log_generico    => vt_log_generico
                                    , en_conhectransp_id  => rec.id );
      --       
      vn_fase := 11;
      -- Chama o processo que consiste a informação do Conhec. Transp.
      pk_csf_api_d100.pkb_consiste_cte ( est_log_generico     => vt_log_generico
                                       , en_conhectransp_id   => rec.id );
      --
      vn_fase := 99;
      --
      -- Se registrou algum log, altera o Conhec. Transp. para dm_st_proc = 10 - "Erro de Validação"
      if nvl(vt_log_generico.count,0) > 0 then
         --
         vn_fase := 99.1;
         --
         sn_erro := 1; -- Sim, contém erro
         --
         begin
            --
            vn_fase := 99.2;
            --
             update Conhec_Transp set dm_st_proc = 10
                                 , dt_st_proc = sysdate
             where id = rec.id;
             --
             commit;
              --
         exception
            when others then
               --
               pk_csf_api_ct.gv_mensagem_log := 'Erro na pkb_ler_ct_d100 fase(' || vn_fase || '):' || sqlerrm;
               --
               declare
                  vn_loggenerico_id  log_generico_ct.id%TYPE;
               begin
                  --
                  pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                              , ev_mensagem        => pk_csf_api_d100.gv_mensagem_log
                                              , ev_resumo          => null
                                              , en_tipo_log        => pk_csf_api_d100.ERRO_DE_SISTEMA
                                              , en_referencia_id   => rec.id
                                              , ev_obj_referencia  => pk_csf_api_d100.gv_obj_referencia );
               --
               exception
                  when others then
                     null;
               end;
               --
               raise_application_error (-20101, pk_csf_api_d100.gv_mensagem_log);
               --
         end;
      else
         --
         vn_fase := 99.3;
         --
         if rec.dm_legado = 1 then --Legado Autorizado
               vn_dm_st_proc := 4;
         elsif rec.dm_legado = 2 then --Legado Denegado
               vn_dm_st_proc := 6;
         elsif rec.dm_legado = 3 then --Legado Cancelado
               vn_dm_st_proc := 7;
         elsif rec.dm_legado = 4 then --Legado Inutilizado
               vn_dm_st_proc := 8;
         else
            --
            vn_dm_st_proc := 4;
            --
         end if;
         update Conhec_Transp set dm_st_proc = vn_dm_st_proc
                                , dt_st_proc = sysdate
          where id = rec.id;
         --
         commit;
         --
      end if;
      --
   end loop;
   --
   -- Finaliza o log genérico para a integração
   -- das Notas Fiscais de Serviço Contínuos
   pk_csf_api_ct.pkb_finaliza_log_generico_ct;
   --
   pk_csf_api_d100.gn_tipo_integr := null ;
   --
exception
   when others then
      --
      pk_csf_api_ct.gv_mensagem_log := 'Erro na pkb_vld_ct_d100 fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api_d100.gv_cabec_log
                                     , ev_resumo          => pk_csf_api_d100.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api_d100.ERRO_DE_SISTEMA
                                     , en_referencia_id   => vn_conhectransp_id
                                     , ev_obj_referencia  => pk_csf_api_d100.gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_d100.gv_mensagem_log);
      --
end pkb_vld_ct_d100;

------------------------------------------------------------------------------------------------------

-- Procedimento para recuperar dados dos Conhecimento de Transporte de Terceiros a serem validados de origem da Integração por Web-Service
procedure pkb_ler_ct_d100_int_ws ( en_loteintws_id  in      lote_int_ws.id%type
                                 , sn_erro          in out  number         -- 0-Não; 1-Sim
                                 )
is
   --
   vn_fase               number;
   vn_objintegr_id       obj_integr.id%type;
   vv_maquina            varchar2(255);
   vn_multorg_id         mult_org.id%type;
   --
   --
   -- Cursores
   cursor c_ct is
   /*select r.*, ct.dt_hr_ent_sist, ct.usuario_id, ct.empresa_id
     from r_loteintws_ct  r
        , conhec_transp   ct
    where r.loteintws_id      = en_loteintws_id
      and ct.id               = r.conhectransp_id
      and ct.dm_ind_emit      = 1 -- Terceiros
      and ct.dm_arm_cte_terc  = 0 -- Não é de armazenamento fiscal
    order by r.conhectransp_id; */
   --
   select r.*, ct.dt_hr_ent_sist, ct.usuario_id, ct.empresa_id
     from r_loteintws_ct r
        , conhec_transp ct
    where r.loteintws_id = en_loteintws_id
      and ct.id = r.conhectransp_id
      and (ct.dm_ind_emit = 1 -- Terceiros
           or ct.dm_legado <> 0 and ct.dm_ind_emit = 0)
      and ct.dm_arm_cte_terc = 0 -- Não é de armazenamento fiscal
    order by r.conhectransp_id; 
    --	
begin
   --
   vn_fase := 1;
   --
   if nvl(en_loteintws_id,0) > 0 then
      --
      vn_fase := 2;
      --
      vn_multorg_id := 0;
      --
      vn_fase := 3;
      --
      -- Recupera o id do objeto de integração
      --
      begin
         select id
           into vn_objintegr_id
           from obj_integr
          where cd = '4'; -- Conhecimento de Transporte
      exception
         when others then
         vn_objintegr_id := 0;
      end;
      --
      vn_fase := 4;
      --
      -- Recupera o nome da máquina
      vv_maquina := sys_context('USERENV', 'HOST');
      --
      if vv_maquina is null then
         --
         vv_maquina := 'Servidor';
         --
      end if;
      --
      vn_fase := 5;
      --
      for rec in c_ct loop
         exit when c_ct%notfound or (c_ct%notfound) is null;
         --
         vn_fase := 5.1;
         --
         pkb_vld_ct_d100 ( en_conhectransp_id => rec.conhectransp_id
                         , sn_erro            => sn_erro
                         , en_loteintws_id    => en_loteintws_id
                         );
         --
         vn_fase := 5.2;
         -- Executar as Rotinas Programáveis para a nota fiscal mercantil
         if nvl(vn_multorg_id,0) = 0 then
            --
            vn_fase := 5.3;
            --
            vn_multorg_id := pk_csf.fkg_multorg_id_empresa ( en_empresa_id => rec.empresa_id );
            --
         end if;
         --
         vn_fase := 5.4;
         -- Procedure de execução das rotinas programaveis do tipo "Integração/Ambas"
         pk_csf_rot_prog.pkb_exec_rot_prog_integr ( en_id_doc          => rec.conhectransp_id
                                                  , ed_dt_ini          => rec.dt_hr_ent_sist
                                                  , ed_dt_fin          => rec.dt_hr_ent_sist
                                                  , ev_obj_referencia  => 'CONHEC_TRANSP'
                                                  , en_referencia_id   => rec.conhectransp_id
                                                  , en_usuario_id      => nvl(rec.usuario_id,0)
                                                  , ev_maquina         => vv_maquina
                                                  , en_objintegr_id    => vn_objintegr_id
                                                  , en_multorg_id      => vn_multorg_id
                                                  );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_ct.gv_mensagem_log := 'Erro na pk_vld_amb_d100.pkb_ler_ct_d100_int_ws fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api_ct.gv_mensagem_log
                                     , ev_resumo          => pk_csf_api_ct.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api_ct.ERRO_DE_SISTEMA
                                     , EN_REFERENCIA_ID   => en_loteintws_id
                                     , EV_OBJ_REFERENCIA  => 'LOTE_INT_WS'
                                     );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_ct_d100_int_ws;

-------------------------------------------------------------------------------------------------------

-- Procedimento de validação de dados de Conhecimento de Transporte de Terceiro, oriundos de Integração por Web-Service
procedure pkb_int_ws ( en_loteintws_id      in     lote_int_ws.id%type
                     , en_tipoobjintegr_id  in     tipo_obj_integr.id%type
                     , sn_erro              in out number
                     )
is
   --
   vn_fase number;
   vv_tipoobjintegr_cd  tipo_obj_integr.cd%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_loteintws_id,0) > 0
      and nvl(en_tipoobjintegr_id,0) > 0 
      then
      --
      vn_fase := 2;
      --
      -- Verifica o tipo de inventario para realizar a validação
      vv_tipoobjintegr_cd := pk_csf.fkg_tipoobjintegr_cd ( en_tipoobjintegr_id => en_tipoobjintegr_id );
      --
      if vv_tipoobjintegr_cd in ('1','2','3') then -- Terceiros de Conhecimento de Transporte
         --
         vn_fase := 2.1;
         --
         pkb_ler_ct_d100_int_ws ( en_loteintws_id  => en_loteintws_id
                                , sn_erro          => sn_erro
                                );
         --
      else
         -- Não Implementado
         vn_fase := 2.99;
         --
      end if;
      --
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_ct.gv_mensagem_log := 'Erro na pk_vld_amb_d100.pkb_int_ws fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%TYPE;
      begin
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api_ct.gv_mensagem_log
                                     , ev_resumo          => pk_csf_api_ct.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api_ct.ERRO_DE_SISTEMA
                                     , EN_REFERENCIA_ID   => en_loteintws_id
                                     , EV_OBJ_REFERENCIA  => 'LOTE_INT_WS'
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_ct.gv_mensagem_log);
      --
end pkb_int_ws;

------------------------------------------------------------------------------------------

end pk_vld_amb_d100;
/
