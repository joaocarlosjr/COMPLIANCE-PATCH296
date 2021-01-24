create or replace package body pk_entr_cte_terceiro is

------------------------------------------------------------------------------------------
--| Corpo do pacote utilizado para Entrada de CTe de Terceiro
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
-- Função para validação se temos todas as operações Fiscais cadastradas para o CTe de Terceiro
------------------------------------------------------------------------------------------------
function fkg_verif_param_da_cte ( en_conhectransp_id_orig  in conhec_transp.id%type
                                )
         return number
is
   --
   vn_fase                number;
   vn_erro                number := 0;
   vn_loggenerico_id      number;
   vd_dt_ult_fecha        fecha_fiscal_empresa.dt_ult_fecha%type;
   vn_emp_matriz          empresa.ar_empresa_id%type;
   --vn_dm_st_proc          conhec_transp.dm_st_proc%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_conhectransp_id_orig,0) > 0 then
      --
      vn_fase := 1.1;
      --
      vd_dt_ult_fecha := pk_csf.fkg_recup_dtult_fecha_empresa ( en_empresa_id   => gn_empresa_id
                                                              , en_objintegr_id => pk_csf.fkg_recup_objintegr_id( ev_cd => '4' )
                                                              );
      --
      if vd_dt_ult_fecha is not null and
         gd_dt_sai_ent < vd_dt_ult_fecha then
         --
         gv_mensagem := 'Fechamento Fiscal.';
         gv_resumo   := 'Já foi realizado o fechamento do período fiscal para conversão de CTe. Empresa: '||pk_csf.fkg_cnpj_ou_cpf_empresa(gn_empresa_id)||
                        ', data do fechamento: '||vd_dt_ult_fecha||', data do documento = '||gd_dt_sai_ent||'.';
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => gv_mensagem
                                           , ev_resumo          => gv_resumo
                                           , en_tipo_log        => pk_csf_api_ct.erro_de_validacao
                                           , en_referencia_id   => en_conhectransp_id_orig
                                           , ev_obj_referencia  => 'CONHEC_TRANSP'
                                           );
         --
         vn_erro := 1; -- Encontrou erros!
         --
      end if;
      --
   end if;
   --
   vn_fase := 2;
   --
   gt_row_conhec_transp := null;
   --
   begin
      --
      select *
        into gt_row_conhec_transp
        from conhec_transp
       where 1 = 1
         and id = en_conhectransp_id_orig
         and dm_arm_cte_terc = 1 -- Armazenamento Fiscal
         --and dm_rec_xml = 1; -- Sim
         and cte_proc_xml is not null;
      --
   exception
      when others then
         gt_row_conhec_transp := null;
   end;
   --
   vn_fase := 2.1;
   --
   if gt_row_conhec_transp.dm_st_proc <> 4 then
      --
      gv_mensagem := 'Parâmetros da Natureza de Operação.';
      gv_resumo   := 'Situação do "Conhec. Transp." de origem, não é Autorizado, por favor verifique!';
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_mensagem
                                        , ev_resumo          => gv_resumo
                                        , en_tipo_log        => pk_csf_api_ct.erro_de_validacao
                                        , en_referencia_id   => en_conhectransp_id_orig
                                        , ev_obj_referencia  => 'CONHEC_TRANSP'
                                        );
      --
      vn_erro := 1; -- Encontrou erros!
      --
   end if;
   --
   vn_fase := 2.2;
   --
   gn_estado_id := null;
   --
   -- Recuperar o parâmetro de ICMS do Estado do Destinatário
   begin
      --
      select es.id
        into gn_estado_id
        from estado             es
           , pais               p
       where es.sigla_estado    = gt_row_conhec_transp.SIGLA_UF_FIM
         and p.id               = es.pais_id;
      --
   exception
      when others then
         gn_estado_id := null;
   end;
   --
   vn_fase := 3;
   --
   -- Valida a informações da natureza de operação
   begin
      --
      select *
        into gt_nat_oper
        from nat_oper
       where id = gn_natoper_id;
      --
   exception
      when others then
         gt_nat_oper := null;
   end;
   --
   vn_fase := 4;
   --Recupera o Id da empresa matriz
   begin
     --
     select em.ar_empresa_id
       into vn_emp_matriz
       from empresa em
      where em.id = gn_empresa_id;
     --
   exception
      when others then
         vn_emp_matriz := null;
   end;
   --
   vn_fase := 5;
   -- PIS
   begin
      --
      select a.*
        into gt_aliq_tipoimp_ncm_empr_pis
        from aliq_tipoimp_ncm_empresa a
           , tipo_imposto ti
       where a.natoper_id = gn_natoper_id
         and ti.id        = a.tipoimposto_id
         and a.empresa_id = gn_empresa_id
         and ti.cd        = '4' -- PIS
         and rownum       = 1
       order by a.prioridade;
      --
   exception
      when no_data_found then
         --
         if vn_emp_matriz is not null then
            --
            vn_fase := 5.1;
            --Recuperar os parâmetros de PIS da empresa Matriz
            begin
               --
               select a.*
                 into gt_aliq_tipoimp_ncm_empr_pis
                 from aliq_tipoimp_ncm_empresa a
                    , tipo_imposto ti
                where a.natoper_id = gn_natoper_id
                  and ti.id        = a.tipoimposto_id
                  and a.empresa_id = vn_emp_matriz --Empresa Matriz
                  and ti.cd        = '4' -- PIS
                  and rownum       = 1
             order by a.prioridade;
               --
            exception
               when others then
                  gt_aliq_tipoimp_ncm_empr_pis := null;
            end;
            --
         else
            gt_aliq_tipoimp_ncm_empr_pis := null;
         end if;
         --
      when others then
         gt_aliq_tipoimp_ncm_empr_pis := null;
   end;
   --
   vn_fase := 6;
   --
   if nvl(gt_aliq_tipoimp_ncm_empr_pis.id,0) <= 0 then
      --
      gv_mensagem := 'Parâmetros da Natureza de Operação.';
      gv_resumo   := 'Não foi informado o Imposto de PIS para a Natureza de Operação ' || gt_nat_oper.cod_nat || '-' || gt_nat_oper.descr_nat ||
                     ' da empresa '||pk_csf.fkg_codpart_empresaid(gn_empresa_id)||' ou da empresa matriz '||pk_csf.fkg_codpart_empresaid(vn_emp_matriz)||'.';
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_mensagem
                                        , ev_resumo          => gv_resumo
                                        , en_tipo_log        => pk_csf_api_ct.erro_de_validacao
                                        , en_referencia_id   => en_conhectransp_id_orig
                                        , ev_obj_referencia  => 'CONHEC_TRANSP'
                                        );
      --
      vn_erro := 1; -- Encontrou erros!
      --
   end if;
   --
   vn_fase := 7;
   -- Cofins
   begin
      --
      select a.*
        into gt_aliq_tipoimp_ncm_empr_cof
        from aliq_tipoimp_ncm_empresa a
           , tipo_imposto ti
       where a.natoper_id = gn_natoper_id
         and ti.id        = a.tipoimposto_id
         and a.empresa_id = gn_empresa_id
         and ti.cd        = '5' -- Cofins
         and rownum = 1
       order by a.prioridade;
      --
   exception
      when no_data_found then
         --
         if vn_emp_matriz is not null then
            --
            vn_fase := 7.1;
            --Recuperar os parâmetros de COFINS da empresa Matriz
            begin
               --
               select a.*
                 into gt_aliq_tipoimp_ncm_empr_cof
                 from aliq_tipoimp_ncm_empresa a
                    , tipo_imposto ti
                where a.natoper_id = gn_natoper_id
                  and ti.id        = a.tipoimposto_id
                  and a.empresa_id = vn_emp_matriz --Empresa Matriz
                  and ti.cd        = '5' -- Cofins
                  and rownum       = 1
             order by a.prioridade;
               --
            exception
               when others then
                  gt_aliq_tipoimp_ncm_empr_cof := null;
            end;
            --
         else
            gt_aliq_tipoimp_ncm_empr_cof := null;
         end if;
         --
      when others then
         gt_aliq_tipoimp_ncm_empr_cof := null;
   end;
   --
   vn_fase := 8;
   --
   if nvl(gt_aliq_tipoimp_ncm_empr_cof.id,0) <= 0 then
      --
      gv_mensagem := 'Parâmetros da Natureza de Operação.';
      gv_resumo   := 'Não foi informado o Imposto de Cofins para a Natureza de Operação ' || gt_nat_oper.cod_nat || '-' || gt_nat_oper.descr_nat ||
                     ' da empresa '||pk_csf.fkg_codpart_empresaid(gn_empresa_id)||' ou da empresa matriz '||pk_csf.fkg_codpart_empresaid(vn_emp_matriz)||'.';
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_mensagem
                                        , ev_resumo          => gv_resumo
                                        , en_tipo_log        => pk_csf_api_ct.erro_de_validacao
                                        , en_referencia_id   => en_conhectransp_id_orig
                                        , ev_obj_referencia  => 'CONHEC_TRANSP'
                                        );
      --
      vn_erro := 1; -- Encontrou erros!
      --
   end if;
   --
   vn_fase := 9;
   -- ICMS
   begin
      --
      select a.*
        into gt_param_calc_icms_empr
        from param_calc_icms_empr a
       where a.natoper_id = gn_natoper_id
         and a.empresa_id = gn_empresa_id
         and a.estado_id_dest = gn_estado_id
         and rownum = 1
       order by a.prioridade;
      --
   exception
      when others then
         gt_param_calc_icms_empr := null;
   end;
   --
   vn_fase := 10;
   --
   if nvl(gt_param_calc_icms_empr.id,0) <= 0 then
      --
      gv_mensagem := 'Parâmetros da Natureza de Operação.';
      gv_resumo   := 'Não foi informado o Imposto de ICMS para a Natureza de Operação ' || gt_nat_oper.cod_nat || '-' || gt_nat_oper.descr_nat || '.';
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_mensagem
                                        , ev_resumo          => gv_resumo
                                        , en_tipo_log        => pk_csf_api_ct.erro_de_validacao
                                        , en_referencia_id   => en_conhectransp_id_orig
                                        , ev_obj_referencia  => 'CONHEC_TRANSP'
                                        );
      --
      vn_erro := 1; -- Encontrou erros!
      --
   end if;
   --
   vn_fase := 11;
   --
   begin
      --
      select *
        into gt_nat_oper_ct
        from nat_oper_ct
       where natoper_id = gn_natoper_id;
      --
   exception
      when others then
         gt_nat_oper_ct := null;
   end;
   --
   vn_fase := 12;
   --
   if nvl(gt_nat_oper_ct.id,0) <= 0 then
      --
      gv_mensagem := 'Parâmetros da Natureza de Operação.';
      gv_resumo   := 'Não foi informado o "Conhec. Transp." para a Natureza de Operação ' || gt_nat_oper.cod_nat || '-' || gt_nat_oper.descr_nat || '.';
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_mensagem
                                        , ev_resumo          => gv_resumo
                                        , en_tipo_log        => pk_csf_api_ct.erro_de_validacao
                                        , en_referencia_id   => en_conhectransp_id_orig
                                        , ev_obj_referencia  => 'CONHEC_TRANSP'
                                        );
      --
      vn_erro := 1; -- Encontrou erros!
      --
   end if;
   --
   vn_fase := 13;
   -- INSS
   begin
      --
      select a.*
        into gt_aliq_tipoimp_ncm_empr_inss
        from aliq_tipoimp_ncm_empresa a
           , tipo_imposto ti
       where a.natoper_id = gn_natoper_id
         and ti.id        = a.tipoimposto_id
         and a.empresa_id = gn_empresa_id
         and ti.cd        = '13' -- INSS
         and rownum       = 1
       order by a.prioridade;
      --
   exception
      when no_data_found then
         --
         if vn_emp_matriz is not null then
            --
            vn_fase := 13.1;
            --Recuperar os parâmetros de INSS da empresa Matriz
            begin
               --
               select a.*
                 into gt_aliq_tipoimp_ncm_empr_inss
                 from aliq_tipoimp_ncm_empresa a
                    , tipo_imposto ti
                where a.natoper_id = gn_natoper_id
                  and ti.id        = a.tipoimposto_id
                  and a.empresa_id = vn_emp_matriz --Empresa Matriz
                  and ti.cd        = '13' -- INSS
                  and rownum       = 1
             order by a.prioridade;
               --
            exception
               when others then
                  gt_aliq_tipoimp_ncm_empr_inss := null;
            end;
            --
         else
            gt_aliq_tipoimp_ncm_empr_inss := null;
         end if;
         --
      when others then
         gt_aliq_tipoimp_ncm_empr_inss := null;
   end;
   --
   vn_fase := 13.2;
   --
   if nvl(gt_aliq_tipoimp_ncm_empr_inss.id,0) <= 0 then
      --
      gv_mensagem := 'Parâmetros da Natureza de Operação.';
      gv_resumo   := 'Não foi informado o Imposto de Retenção (INSS) para a Natureza de Operação ' || gt_nat_oper.cod_nat || '-' || gt_nat_oper.descr_nat ||
                     ' da empresa '||pk_csf.fkg_codpart_empresaid(gn_empresa_id)||' ou da empresa matriz '||pk_csf.fkg_codpart_empresaid(vn_emp_matriz)||'.';
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                        , ev_mensagem        => gv_mensagem
                                        , ev_resumo          => gv_resumo
                                        , en_tipo_log        => pk_csf_api_ct.informacao
                                        , en_referencia_id   => en_conhectransp_id_orig
                                        , ev_obj_referencia  => 'CONHEC_TRANSP'
                                        );
      --
      --vn_erro := 1; -- Encontrou erros!
      --
   end if;
   --
   vn_fase := 99;
   --
   return vn_erro;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_entr_cte_terceiro.fkg_verif_param_da_cte fase(' || vn_fase || '):' || sqlerrm;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id    => vn_loggenerico_id
                                        , ev_mensagem          => gv_mensagem
                                        , ev_resumo            => gv_resumo
                                        , en_tipo_log          => pk_csf_api_ct.ERRO_DE_SISTEMA
                                        , en_referencia_id     => en_conhectransp_id_orig
                                        , ev_obj_referencia    => 'CONHEC_TRANSP'
                                        );
      --
      raise_application_error (-20101, gv_mensagem);
      --
end fkg_verif_param_da_cte;
--
------------------------------------------------------------------------------------------
-- Função Verifica se existe Cópia do CT
function fkg_verif_copia_cte ( en_conhectransp_id_orig  in conhec_transp.id%type )
         return number
is
   --
   vn_qtde number := 0;
   --
begin
   --
   begin
      select count(1)
        into vn_qtde
        from r_ct_ct
       where conhectransp_id1 = en_conhectransp_id_orig;
   exception
      when others then
         vn_qtde := 0;
   end;
   --
   return vn_qtde;
   --
exception
   when others then
      return 0;
end fkg_verif_copia_cte;

------------------------------------------------------------------------------------------

-- Procedimento de ler os dados da CTe de origem para geração dos dados de destino
procedure pkb_ler_Conhec_Transp_orig ( en_conhectransp_id_orig in conhec_transp.id%type )
is
   --
   vn_fase                  number;
   vn_loggenerico_id        log_generico_ct.id%TYPE;
   vt_log_generico_ct       dbms_sql.number_table;
   --
   vn_existe_copia_cte      number;
   vn_conhectransp_id       conhec_transp.id%type;
   vt_conhec_transp_vlprest conhec_transp_vlprest%rowtype;
   vn_vl_base_calc          conhec_transp_imp.vl_base_calc%type;
   vv_cpf_cnpj_emit         varchar2(14);
   vv_cod_part              pessoa.cod_part%type;
   vv_cod_mod               mod_fiscal.cod_mod%type;
   --
   vn_usuario_id            number;
   vv_maquina               varchar2(255);
   vn_objintegr_id          number;
   --
   vn_vl_red_bc_inss        conhec_transp_imp.vl_base_calc%type;
   vn_vl_imp_inss           conhec_transp_imp_ret.vl_imp%type;
   --
   vv_cd_unid_org           unid_org.cd%type;
   --
begin
   --
   vn_fase := 1;
   --
   vt_log_generico_ct.delete;

   --
   vn_fase := 2;
   --
   if nvl(gt_row_conhec_transp.id,0) > 0 then
      --
      vn_fase := 2.1;
      --
      vn_existe_copia_cte := fkg_verif_copia_cte ( en_conhectransp_id_orig => en_conhectransp_id_orig );
      --
      if nvl(vn_existe_copia_cte,0) <= 0 then
         --
         vn_fase := 3;
         --
         pk_csf_api_d100.pkb_seta_obj_ref ( ev_objeto => 'CONHEC_TRANSP' );
         pk_csf_api_d100.pkb_seta_tipo_integr ( en_tipo_integr => 1 );
         --
         vn_fase := 3.1;
         -- Recupera dados de Valores da Prestação
         begin
            select *
              into vt_conhec_transp_vlprest
              from conhec_transp_vlprest
             where conhectransp_id = en_conhectransp_id_orig;
         exception
            when others then
               vt_conhec_transp_vlprest := null;
         end;
         --
         vn_fase := 3.2;
         -- Recupera dados de Valores do Imposto ICMS
         begin
            select nvl(sum(nvl(ct.vl_base_calc,0)),0)
              into vn_vl_base_calc
              from conhec_transp_imp ct
                 , tipo_imposto      ti
             where ct.conhectransp_id = en_conhectransp_id_orig
               and ti.id              = ct.tipoimp_id
               and ti.cd              = 1; -- ICMS
         exception
            when others then
               vn_vl_base_calc := null;
         end;
         --
         vn_fase := 3.3;
         --
         vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => gt_row_conhec_transp.empresa_id );
         --
         vn_fase := 3.4;
         --
         vv_cod_part := pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => gt_row_conhec_transp.pessoa_id );
         --
         vn_fase := 3.5;
         --
         vv_cod_mod := pk_csf.fkg_cod_mod_id ( en_modfiscal_id => gt_row_conhec_transp.modfiscal_id );
         --
         vn_fase := 3.6;
         -- Cálculo do ICMS
         gt_row_ct_reg_anal.codst_id       := gt_param_calc_icms_empr.codst_id;
         gt_row_ct_reg_anal.cfop_id        := nvl(gt_param_calc_icms_empr.cfop_id,gn_natoper_id);
         gt_row_ct_reg_anal.dm_orig_merc   := 0;
         gt_row_ct_reg_anal.aliq_icms      := gt_param_calc_icms_empr.aliq_dest;
         gt_row_ct_reg_anal.vl_opr         := vt_conhec_transp_vlprest.vl_docto_fiscal;
         --
         vn_fase := 3.7;
         --
         if nvl(gt_row_ct_reg_anal.aliq_icms ,0) > 0 then
            --
            if nvl(gt_param_calc_icms_empr.perc_reduc_bc,0) > 0 then
               --
               gt_row_ct_reg_anal.vl_red_bc := round( nvl(gt_row_ct_reg_anal.vl_opr,0) * (nvl(gt_param_calc_icms_empr.perc_reduc_bc,0)/100), 2);
               --
            else
               --
               gt_row_ct_reg_anal.vl_red_bc := 0;
               --
            end if;
            --
            if nvl(vn_vl_base_calc,0) = 0 then -- não foi gerado o imposto ICMS
               gt_row_ct_reg_anal.vl_bc_icms := nvl(gt_row_ct_reg_anal.vl_opr,0) - nvl(gt_row_ct_reg_anal.vl_red_bc,0);
            else
               gt_row_ct_reg_anal.vl_bc_icms := nvl(vn_vl_base_calc,0);
            end if;
            --
            gt_row_ct_reg_anal.vl_icms := round( nvl(gt_row_ct_reg_anal.vl_bc_icms,0) * (gt_row_ct_reg_anal.aliq_icms/100), 2);
            --
         else
            gt_row_ct_reg_anal.aliq_icms   := 0;
            gt_row_ct_reg_anal.vl_bc_icms  := 0;
            gt_row_ct_reg_anal.vl_icms     := 0;
            gt_row_ct_reg_anal.vl_red_bc   := 0;
         end if;
         --
         vn_fase := 3.8;
         --
         vv_cd_unid_org:= pk_csf.fkg_unig_org_cd(en_unidorg_id => gt_row_conhec_transp.unidorg_id);
         --
         vn_fase := 3.99;
         --
         pk_csf_api_d100.pkb_integr_ct_d100 ( est_log_generico     => vt_log_generico_ct
                                            , ev_cpf_cnpj_emit     => vv_cpf_cnpj_emit            -- vt_tab_csf_conhec_tranp_efd(i).cpf_cnpj_emit
                                            , en_dm_ind_emit       => 1                           -- terceiro
                                            , en_dm_ind_oper       => 0                           -- Entrada
                                            , ev_cod_part          => vv_cod_part                 -- vt_tab_csf_conhec_tranp_efd(i).cod_part
                                            , ev_cod_mod           => vv_cod_mod                  -- vt_tab_csf_conhec_tranp_efd(i).cod_mod
                                            , ev_serie             => gt_row_conhec_transp.serie
                                            , ev_subserie          => to_char(gt_row_conhec_transp.subserie)
                                            , en_nro_nf            => gt_row_conhec_transp.nro_ct
                                            , ev_sit_docto         => '00'                        -- Documento Normal
                                            , ev_nro_chave_cte     => gt_row_conhec_transp.nro_chave_cte
                                            , en_dm_tp_cte         => gt_row_conhec_transp.dm_tp_cte
                                            , ev_chave_cte_ref     => gt_row_conhec_transp.chave_cte_ref
                                            , ed_dt_emiss          => trunc(gt_row_conhec_transp.dt_hr_emissao)
                                            , ed_dt_sai_ent        => gd_dt_sai_ent
                                            , en_vl_doc            => vt_conhec_transp_vlprest.vl_docto_fiscal
                                            , en_vl_desc           => 0
                                            , en_dm_ind_frt        => gt_row_conhec_transp.dm_ind_frt
                                            , en_vl_serv           => vt_conhec_transp_vlprest.vl_prest_serv
                                            , en_vl_bc_icms        => gt_row_ct_reg_anal.vl_bc_icms --vt_tab_csf_conhec_tranp_efd(i).vl_bc_icms
                                            , en_vl_icms           => gt_row_ct_reg_anal.vl_icms --vt_tab_csf_conhec_tranp_efd(i).vl_icms
                                            , en_vl_nt             => 0 --vt_tab_csf_conhec_tranp_efd(i).vl_nt
                                            , ev_cod_inf           => null --vt_tab_csf_conhec_tranp_efd(i).cod_inf
                                            , ev_cod_cta           => null --vt_tab_csf_conhec_tranp_efd(i).cod_cta
                                            , ev_cod_nat_oper      => gt_nat_oper.cod_nat
                                            , en_multorg_id        => gn_multorg_id
                                            , sn_conhectransp_id   => vn_conhectransp_id
                                            , en_loteintws_id      => 0 -- lote_int_ws.id%type default 0
                                            , en_cfop_id           => gt_row_ct_reg_anal.cfop_id -- cfop.id%type default 1
                                            , en_ibge_cidade_ini   => gt_row_conhec_transp.ibge_cidade_ini  --conhec_transp.ibge_cidade_ini%type default 0
                                            , ev_descr_cidade_ini  => gt_row_conhec_transp.descr_cidade_ini --conhec_transp.descr_cidade_ini%type default 'XX'
                                            , ev_sigla_uf_ini      => gt_row_conhec_transp.sigla_uf_ini     --conhec_transp.sigla_uf_ini%type default 'XX'
                                            , en_ibge_cidade_fim   => gt_row_conhec_transp.ibge_cidade_fim  --conhec_transp.ibge_cidade_fim%type default 0
                                            , ev_descr_cidade_fim  => gt_row_conhec_transp.descr_cidade_fim --conhec_transp.descr_cidade_fim%type default 'XX'
                                            , ev_sigla_uf_fim      => gt_row_conhec_transp.sigla_uf_fim     --conhec_transp.sigla_uf_fim%type default 'XX'
                                            , ev_dm_modal          => gt_row_conhec_transp.dm_modal
                                            , en_dm_tp_serv        => gt_row_conhec_transp.dm_tp_serv
                                            , ev_cd_unid_org       => vv_cd_unid_org
                                            );
         --
         vn_fase := 4;
         --
         if nvl(vn_conhectransp_id,0) > 0 then
            --
            vn_fase := 4.1;
            --
            begin
               --
               insert into r_ct_ct ( ID
                                   , CONHECTRANSP_ID1
                                   , CONHECTRANSP_ID2
                                   )
                            values ( rctct_seq.nextval        -- ID
                                   , en_conhectransp_id_orig  -- CONHECTRANSP_ID1
                                   , vn_conhectransp_id       -- CONHECTRANSP_ID2
                                   );
               --
            exception
               when others then
                  --
                  gv_mensagem := 'Erro na pk_entr_cte_terceiro.pkb_ler_Conhec_Transp_orig ao relacionar R_CT_CT fase(' || vn_fase || '):' || sqlerrm;
                  --
                  pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id  => vn_loggenerico_id
                                                    , ev_mensagem        => gv_mensagem
                                                    , ev_resumo          => gv_mensagem
                                                    , en_tipo_log        => pk_csf_api_ct.ERRO_DE_SISTEMA
                                                    , en_referencia_id   => vn_conhectransp_id
                                                    , ev_obj_referencia  => 'CONHEC_TRANSP'
                                                    );
                  --
            end;
            --
            vn_fase := 4.2;
            --
            -- Implementa o Registro Analitico de Impostos
            gt_row_ct_reg_anal.conhectransp_id   := vn_conhectransp_id;
            --
            pk_csf_api_d100.pkb_integr_ct_d190 ( est_log_generico => vt_log_generico_ct
                                               , est_ct_reg_anal  => gt_row_ct_reg_anal
                                               , ev_cod_st        => pk_csf.fkg_Cod_ST_cod ( en_id_st => gt_row_ct_reg_anal.codst_id )
                                               , en_cfop          => pk_csf.fkg_cfop_cd ( en_cfop_id => gt_row_ct_reg_anal.cfop_id )
                                               , ev_cod_obs       => null --
                                               , en_multorg_id    => gn_multorg_id
                                               );
            --
            vn_fase := 5;
            --
            -- PIS
            gt_row_ct_compdoc_pisefd.conhectransp_id   := vn_conhectransp_id;
            gt_row_ct_compdoc_pisefd.dm_ind_nat_frt    := gt_nat_oper_ct.dm_ind_nat_frt;
            gt_row_ct_compdoc_pisefd.vl_item           := vt_conhec_transp_vlprest.vl_docto_fiscal;
            gt_row_ct_compdoc_pisefd.codst_id          := gt_aliq_tipoimp_ncm_empr_pis.codst_id;
            gt_row_ct_compdoc_pisefd.basecalccredpc_id := gt_nat_oper_ct.basecalccredpc_id;
            gt_row_ct_compdoc_pisefd.planoconta_id     := null;
            gt_row_ct_compdoc_pisefd.natrecpc_id       := gt_nat_oper_ct.natrecpc_id;
            --
            vn_fase := 5.1;
            --
            if nvl(gt_aliq_tipoimp_ncm_empr_pis.indice,0) > 0 then
               --
               if nvl(gt_row_ct_reg_anal.vl_bc_icms, 0) > 0 then
                  gt_row_ct_compdoc_pisefd.vl_bc_pis  := gt_row_ct_reg_anal.vl_bc_icms;
               else
                  gt_row_ct_compdoc_pisefd.vl_bc_pis  := gt_row_ct_reg_anal.vl_opr;
               end if;
               --
               gt_row_ct_compdoc_pisefd.aliq_pis   := gt_aliq_tipoimp_ncm_empr_pis.indice;
               gt_row_ct_compdoc_pisefd.vl_pis     := gt_row_ct_compdoc_pisefd.vl_bc_pis * (nvl(gt_row_ct_compdoc_pisefd.aliq_pis,0)/100);
               --
            else
               --
               gt_row_ct_compdoc_pisefd.vl_bc_pis  := 0;
               gt_row_ct_compdoc_pisefd.aliq_pis   := 0;
               gt_row_ct_compdoc_pisefd.vl_pis     := 0;
               --
            end if;
            --
            vn_fase := 5.2;
            --
            pk_csf_api_d100.pkb_integr_ctcompdoc_pisefd ( est_log_generico     => vt_log_generico_ct
                                                        , est_ctcompdoc_pisefd => gt_row_ct_compdoc_pisefd
                                                        , ev_cpf_cnpj_emit     => vv_cpf_cnpj_emit
                                                        , ev_cod_st            => pk_csf.fkg_Cod_ST_cod ( en_id_st => gt_row_ct_compdoc_pisefd.codst_id )
                                                        , ev_cod_bc_cred_pc    => pk_csf_efd_pc.fkg_base_calc_cred_pc_cd ( en_id => gt_row_ct_compdoc_pisefd.basecalccredpc_id )
                                                        , ev_cod_cta           => null
                                                        , en_multorg_id        => gn_multorg_id
                                                        );
            --
            vn_fase := 5.3;
            --
            if nvl(gt_row_ct_compdoc_pisefd.natrecpc_id,0) > 0 then
               --
               pk_csf_api_d100.pkb_integr_ctcompdocpisefd_ff ( est_log_generico   => vt_log_generico_ct
                                                             , en_ctcompdocpis_id => gt_row_ct_compdoc_pisefd.id
                                                             , ev_atributo        => 'COD_NAT_REC_PC'
                                                             , ev_valor           => pk_csf_efd_pc.fkg_cod_id_nat_rec_pc ( en_natrecpc_id => gt_row_ct_compdoc_pisefd.natrecpc_id )
                                                             , en_multorg_id      => gn_multorg_id
                                                             );
               --
            end if;
            --
            vn_fase := 6;
            --
            -- COFINS
            gt_row_ct_compdoc_cofinsefd.conhectransp_id    := vn_conhectransp_id;
            gt_row_ct_compdoc_cofinsefd.dm_ind_nat_frt     := gt_nat_oper_ct.dm_ind_nat_frt;
            gt_row_ct_compdoc_cofinsefd.vl_item            := vt_conhec_transp_vlprest.vl_docto_fiscal;
            gt_row_ct_compdoc_cofinsefd.codst_id           := gt_aliq_tipoimp_ncm_empr_cof.codst_id;
            gt_row_ct_compdoc_cofinsefd.basecalccredpc_id  := gt_nat_oper_ct.basecalccredpc_id;
            gt_row_ct_compdoc_cofinsefd.planoconta_id      := null;
            gt_row_ct_compdoc_cofinsefd.natrecpc_id        := gt_nat_oper_ct.natrecpc_id;
            --
            vn_fase := 6.1;
            --
            if nvl(gt_aliq_tipoimp_ncm_empr_cof.indice,0) > 0 then
               --
               if nvl(gt_row_ct_reg_anal.vl_bc_icms, 0) > 0 then
                  gt_row_ct_compdoc_cofinsefd.vl_bc_cofins  := gt_row_ct_reg_anal.vl_bc_icms;
               else
                  gt_row_ct_compdoc_cofinsefd.vl_bc_cofins  := gt_row_ct_reg_anal.vl_opr;
               end if;
               --
               gt_row_ct_compdoc_cofinsefd.aliq_cofins   := gt_aliq_tipoimp_ncm_empr_cof.indice;
               gt_row_ct_compdoc_cofinsefd.vl_cofins     := gt_row_ct_compdoc_cofinsefd.vl_bc_cofins * (gt_row_ct_compdoc_cofinsefd.aliq_cofins/100);
               --
            else
               --
               gt_row_ct_compdoc_cofinsefd.vl_bc_cofins  := 0;
               gt_row_ct_compdoc_cofinsefd.aliq_cofins   := 0;
               gt_row_ct_compdoc_cofinsefd.vl_cofins     := 0;
               --
            end if;
            --
            vn_fase := 6.2;
            --
            pk_csf_api_d100.pkb_integr_ctcompdoc_cofinsefd ( est_log_generico        => vt_log_generico_ct
                                                           , est_ctcompdoc_cofinsefd => gt_row_ct_compdoc_cofinsefd
                                                           , ev_cpf_cnpj_emit        => vv_cpf_cnpj_emit
                                                           , ev_cod_st               => pk_csf.fkg_Cod_ST_cod ( en_id_st => gt_row_ct_compdoc_cofinsefd.codst_id )
                                                           , ev_cod_bc_cred_pc       => pk_csf_efd_pc.fkg_base_calc_cred_pc_cd ( en_id => gt_row_ct_compdoc_cofinsefd.basecalccredpc_id )
                                                           , ev_cod_cta              => null
                                                           , en_multorg_id           => gn_multorg_id
                                                           );
            --
            vn_fase := 6.3;
            --
            if nvl(gt_row_ct_compdoc_cofinsefd.natrecpc_id,0) > 0 then
               --
               pk_csf_api_d100.pkb_integr_ctcompdoccofefd_ff ( est_log_generico      => vt_log_generico_ct
                                                             , en_ctcompdoccofins_id => gt_row_ct_compdoc_cofinsefd.id
                                                             , ev_atributo           => 'COD_NAT_REC_PC'
                                                             , ev_valor              => pk_csf_efd_pc.fkg_cod_id_nat_rec_pc ( en_natrecpc_id => gt_row_ct_compdoc_cofinsefd.natrecpc_id )
                                                             , en_multorg_id         => gn_multorg_id
                                                             );
               --
            end if;
            --
            vn_fase := 7;
            --
            -- INSS
            -- Recupera dados de Valores do Imposto INSS
            begin
               select nvl(sum(nvl(ct.vl_imp,0)),0)
                 into vn_vl_imp_inss
                 from conhec_transp_imp_ret ct
                    , tipo_imposto          ti
                where ct.conhectransp_id = en_conhectransp_id_orig
                  and ti.id              = ct.tipoimp_id
                  and ti.cd              = 13; -- INSS
            exception
               when others then
                  vn_vl_imp_inss := null;
            end;
            --
            gt_row_ct_compdoc_inssefd.conhectransp_id      := vn_conhectransp_id;
            gt_row_ct_compdoc_inssefd.vl_item              := vt_conhec_transp_vlprest.VL_PREST_SERV;
            gt_row_ct_compdoc_inssefd.vl_aliq              := gt_aliq_tipoimp_ncm_empr_inss.indice;
            gt_row_ct_compdoc_inssefd.tipoimp_id           := gt_aliq_tipoimp_ncm_empr_inss.tipoimposto_id;
            gt_row_ct_compdoc_inssefd.tiporetimp_id        := null;
            gt_row_ct_compdoc_inssefd.tiporetimpreceita_id := null;
            --
            vn_fase := 7.1;
            --
            if nvl(vn_vl_imp_inss,0) > 0 then
               --
               if nvl(gt_row_ct_compdoc_inssefd.vl_aliq ,0) > 0 then
                  --
                  if nvl(gt_aliq_tipoimp_ncm_empr_inss.perc_reduc_bc,0) > 0 then
                     --
                     vn_vl_red_bc_inss := round( nvl(gt_row_ct_compdoc_inssefd.vl_item,0) * (nvl(gt_aliq_tipoimp_ncm_empr_inss.perc_reduc_bc,0)/100), 2);
                     --
                  else
                     --
                     vn_vl_red_bc_inss := 0;
                     --
                  end if;
                  --
                  gt_row_ct_compdoc_inssefd.vl_base_calc := nvl(gt_row_ct_compdoc_inssefd.vl_item,0) - nvl(vn_vl_red_bc_inss,0);
                  gt_row_ct_compdoc_inssefd.vl_imp       := nvl(gt_row_ct_compdoc_inssefd.vl_base_calc,0) * (nvl(gt_row_ct_compdoc_inssefd.vl_aliq,0)/100);
                  --
                  -- foi solicitado q somente sera gerado o imposto se houver inss no cte de origem (48611)
                  vn_fase := 7.2;
                  --
                  pk_csf_api_d100.pkb_integr_ctimpretefd ( est_log_generico        => vt_log_generico_ct
                                                         , est_ctimpretefd         => gt_row_ct_compdoc_inssefd
                                                         , ev_cpf_cnpj_emit        => vv_cpf_cnpj_emit
                                                         , ev_cod_imposto          => pk_csf.fkg_Tipo_Imposto_cd ( en_tipoimp_id    => gt_row_ct_compdoc_inssefd.tipoimp_id )
                                                         , ev_cd_tipo_ret_imp      => pk_csf.fkg_tipo_ret_imp_cd ( en_tiporetimp_id => gt_row_ct_compdoc_inssefd.tiporetimp_id )
                                                         , ev_cod_receita          => pk_csf.fkg_tipo_ret_imp_rec_cd ( en_tiporetimpreceita_id =>  gt_row_ct_compdoc_inssefd.tiporetimpreceita_id
                                                                                                                     , en_tiporetimp_id        =>  gt_row_ct_compdoc_inssefd.tiporetimp_id )
                                                         , en_multorg_id           => gn_multorg_id );
                  --
                  vn_fase := 7.3;
                  --
                  gt_row_ct_compdoc_inssefd.tiposervreinf_id := gt_aliq_tipoimp_ncm_empr_inss.TIPOSERVREINF_ID;
                  --
                  if nvl(gt_row_ct_compdoc_inssefd.tiposervreinf_id,0) > 0 then
                     --
                     pk_csf_api_d100.pkb_integr_ctimpretefd_ff ( est_log_generico   => vt_log_generico_ct
                                                               , en_ctimpretefd_id  => gt_row_ct_compdoc_inssefd.id
                                                               , ev_atributo        => 'CD_TP_SERV_REINF'
                                                               , ev_valor           => pk_csf_reinf.fkg_tipo_serv_reinf_cd (  en_id => gt_row_ct_compdoc_inssefd.tiposervreinf_id )
                                                               , en_multorg_id      => gn_multorg_id );
                     --
                  end if;
                  --
                  vn_fase := 7.4;
                  --
                  gt_row_ct_compdoc_inssefd.dm_ind_cprb := gt_aliq_tipoimp_ncm_empr_inss.DM_IND_CPRB;
                  --
                  if gt_row_ct_compdoc_inssefd.dm_ind_cprb is not null then
                     --
                     pk_csf_api_d100.pkb_integr_ctimpretefd_ff ( est_log_generico   => vt_log_generico_ct
                                                               , en_ctimpretefd_id  => gt_row_ct_compdoc_inssefd.id
                                                               , ev_atributo        => 'DM_IND_CPRB'
                                                               , ev_valor           => gt_row_ct_compdoc_inssefd.dm_ind_cprb
                                                               , en_multorg_id      => gn_multorg_id );
                     --
                  end if;
                  --
               else
                  --
                  gt_row_ct_compdoc_inssefd.vl_base_calc  := 0;
                  gt_row_ct_compdoc_inssefd.vl_aliq       := 0;
                  gt_row_ct_compdoc_inssefd.vl_imp        := 0;
                  --
               end if;
               --
            end if;
            --
            ----------------------------------------------------------------------
            -- Processos que consistem a informação do Conhecimento de Transporte
            -----------------------------------------------------------------------
            pk_csf_api_d100.pkb_consiste_cte ( est_log_generico   => vt_log_generico_ct
                                             , en_conhectransp_id => vn_conhectransp_id );
            --
            vn_fase := 7.5;
            --
            if nvl(vt_log_generico_ct.count,0) > 0 then
               --
               update conhec_transp set dm_st_proc = 10
                where id = vn_conhectransp_id;
              --
            else
              --
              update conhec_transp set dm_st_proc = 4
               where id = vn_conhectransp_id;
              --
            end if;
            --
            commit;
            --
            vn_fase := 8;
            --
            -- Executar as Rotinas Programáveis para a nota fiscal de destino
            --
            begin
               select min(nu.id)
                 into vn_usuario_id
                 from neo_usuario nu
                where nu.multorg_id = gn_multorg_id;
            exception
               when others then
                  null;
            end;
            --
            vn_fase := 8.1;
            --
            vv_maquina := sys_context('USERENV', 'HOST');
            --
            if vv_maquina is null then
               vv_maquina := 'Servidor';
            end if;
            --
            vn_fase := 8.2;
            --
            begin
               select id
                 into vn_objintegr_id
                 from obj_integr
                where cd = '4'; -- Conhec. Transp
            exception
               when others then
                  vn_objintegr_id := 0;
            end;
            --
            vn_fase := 8.3;
            --
            pk_csf_rot_prog.pkb_exec_rot_prog_integr ( en_id_doc         => gt_row_conhec_transp.id
                                                     , ed_dt_ini         => gt_row_conhec_transp.dt_hr_emissao
                                                     , ed_dt_fin         => gt_row_conhec_transp.dt_hr_emissao
                                                     , ev_obj_referencia => 'CONHEC_TRANSP'
                                                     , en_referencia_id  => gt_row_conhec_transp.id
                                                     , en_usuario_id     => vn_usuario_id
                                                     , ev_maquina        => vv_maquina
                                                     , en_objintegr_id   => vn_objintegr_id
                                                     , en_multorg_id     => gn_multorg_id
                                                     );
            --
         end if;
         --
      else
         --
         gv_mensagem := 'CTe já foi convertido!';
         --
         pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id    => vn_loggenerico_id
                                           , ev_mensagem          => gv_mensagem
                                           , ev_resumo            => gv_mensagem
                                           , en_tipo_log          => pk_csf_api_ct.INFORMACAO
                                           , en_referencia_id     => en_conhectransp_id_orig
                                           , ev_obj_referencia    => 'CONHEC_TRANSP'
                                           );
         --
      end if;
      --
   else
      --
      gv_mensagem := 'CTe não esta preparado para ser convertido, falta a importação do XML!';
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id    => vn_loggenerico_id
                                        , ev_mensagem          => gv_mensagem
                                        , ev_resumo            => gv_mensagem
                                        , en_tipo_log          => pk_csf_api_ct.INFORMACAO
                                        , en_referencia_id     => en_conhectransp_id_orig
                                        , ev_obj_referencia    => 'CONHEC_TRANSP'
                                        );
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_entr_cte_terceiro.pkb_ler_Conhec_Transp_orig fase(' || vn_fase || '):' || sqlerrm;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id    => vn_loggenerico_id
                                        , ev_mensagem          => gv_mensagem
                                        , ev_resumo            => gv_mensagem
                                        , en_tipo_log          => pk_csf_api_ct.ERRO_DE_SISTEMA
                                        , en_referencia_id     => en_conhectransp_id_orig
                                        , ev_obj_referencia    => 'CONHEC_TRANSP'
                                        );
      --
      raise_application_error (-20101, gv_mensagem);
      --
end pkb_ler_Conhec_Transp_orig;

------------------------------------------------------------------------------------------

-- Procedimento de Cópia dos dados da CTe de Armazenamento de XML de Terceiro
-- para gerar um CTe de Terceiro

procedure pkb_copiar_cte ( en_conhectransp_id_orig  in conhec_transp.id%type
                         , en_empresa_id            in empresa.id%type
                         , ed_dt_sai_ent            in conhec_transp.dt_sai_ent%type
                         , en_natoper_id            in nat_oper.id%type
                         , en_empr_tomadora_serv    in number default 0  -- 0-Não / 1-Sim		
                         -- #74429 novos parametros
                         , en_usuario_id            in neo_usuario.id%type default null
                         , ev_maquina               in varchar2            default null					 
                         )
is
   --
   vn_fase            number;
   vn_erro            number;
   vn_qtde_tomador    number;   
   --
   vn_loggenerico_id  log_generico_ct.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_conhectransp_id_orig,0) > 0
      and nvl(en_natoper_id,0) > 0
      then
      --
      vn_fase := 2;
      --	  
      --| Data de Entrada/Saída do CTe de Destino
      vn_fase := 2.1;
      --	  
      gd_dt_sai_ent := trunc(nvl(ed_dt_sai_ent, sysdate));
      gn_empresa_id := en_empresa_id;
      gn_multorg_id := pk_csf.fkg_multorg_id_empresa ( en_empresa_id => en_empresa_id );
      gn_natoper_id := en_natoper_id;
      --
      -- seta o tipo de integração que será feito
      -- 0 - Somente válida os dados e registra o Log de ocorrência
      -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
      -- Todos os procedimentos de integração fazem referência a ele
      pk_csf_api_ct.pkb_seta_tipo_integr ( en_tipo_integr => 1 );
      --
      vn_fase := 2.2;
      --
      pk_csf_api_ct.pkb_seta_obj_ref ( ev_objeto => 'CONHEC_TRANSP' );
      --
      vn_fase := 2.3;
      -- procedimento de excluir os logs da NFe de origem para geração dos dados de destino
      begin
         delete from log_generico_ct lg
          where lg.obj_referencia = 'CONHEC_TRANSP'
            and lg.referencia_id  = en_conhectransp_id_orig;
      exception
         when others then
            --
            gv_mensagem := 'Problemas ao excluir log_generico_ct da CONHEC_TRANSP de origem - pk_entr_cte_terceiro.pkb_copiar_cte fase('||vn_fase||'):'||sqlerrm;
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id    => vn_loggenerico_id
                                              , ev_mensagem          => gv_mensagem
                                              , ev_resumo            => gv_mensagem
                                              , en_tipo_log          => pk_csf_api_ct.ERRO_DE_SISTEMA
                                              , en_referencia_id     => en_conhectransp_id_orig
                                              , ev_obj_referencia    => 'CONHEC_TRANSP'
                                              );
            --
            raise_application_error (-20101, gv_mensagem);
            --
      end;
      --
      commit;
      --
      vn_fase := 2.4;
      --
      if nvl( en_empr_tomadora_serv, 0 ) = 1 then 
         --   
         begin
            select count(1)
              into vn_qtde_tomador
              from v_conhec_transp_tomador v
             where v.conhectransp_id = en_conhectransp_id_orig;
         exception
            when others then
               vn_qtde_tomador := null;
         end;		 
         --
	     if nvl( vn_qtde_tomador, 0 ) = 0 then
            --
            gv_mensagem := 'Empresa setada como tomadora de serviço. Conhecimento de transporte não encontrado para essa situação.';
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id    => vn_loggenerico_id
                                              , ev_mensagem          => gv_mensagem
                                              , ev_resumo            => gv_mensagem
                                              , en_tipo_log          => pk_csf_api_ct.ERRO_DE_SISTEMA
                                              , en_referencia_id     => en_conhectransp_id_orig
                                              , ev_obj_referencia    => 'CONHEC_TRANSP'
                                              );
            --
            goto sair_rotina;
            --		 
         end if;
         --	  
      end if;	  
      --	  
      vn_erro := fkg_verif_param_da_cte ( en_conhectransp_id_orig => en_conhectransp_id_orig );
      --
      if nvl(vn_erro,0) <= 0 then
         --
         vn_fase := 2.5;
         -- procedimento de ler os dados da CTe de origem para geração dos dados de destino
         pkb_ler_Conhec_Transp_orig ( en_conhectransp_id_orig => en_conhectransp_id_orig );
         --         
         --#74429
         pk_csf_api_d100.pkb_inclui_log_conhec_transp(  en_conhectransp_id_orig
                                                      , 'Conversão realizada na data '||sysdate
                                                      , 'Conversão realizada na data '||sysdate
                                                      , en_usuario_id
                                                      , ev_maquina );
         --
      end if;
      --
      vn_fase := 2.6;
      --
      commit;
      --
      vn_fase := 99;
      -- Finaliza o log genérico para a integração das CTe no CSF
      pk_csf_api_ct.pkb_finaliza_log_generico_ct;
      --
      pk_csf_api_ct.pkb_seta_tipo_integr ( en_tipo_integr => null );
      --
   else
      --
      gv_mensagem := 'Não informado o CTe de origem ou Natureza de Operação.';
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id    => vn_loggenerico_id
                                        , ev_mensagem          => gv_mensagem
                                        , ev_resumo            => gv_mensagem
                                        , en_tipo_log          => pk_csf_api_ct.ERRO_DE_SISTEMA
                                        , en_referencia_id     => en_conhectransp_id_orig
                                        , ev_obj_referencia    => 'CONHEC_TRANSP'
                                        );
      --
   end if;
   --
   <<sair_rotina>>
   --   
   null;   
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_entr_cte_terceiro.pkb_copiar_cte fase(' || vn_fase || '):' || sqlerrm;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id    => vn_loggenerico_id
                                        , ev_mensagem          => gv_mensagem
                                        , ev_resumo            => gv_mensagem
                                        , en_tipo_log          => pk_csf_api_ct.ERRO_DE_SISTEMA
                                        , en_referencia_id     => en_conhectransp_id_orig
                                        , ev_obj_referencia    => 'CONHEC_TRANSP'
                                        );
      --
      raise_application_error (-20101, gv_mensagem);
      --
end pkb_copiar_cte;

------------------------------------------------------------------------------------------

-- Procedimento desfaz a cópia da CTe

procedure pkb_desfazer_copia_cte ( en_conhectransp_id_dest  in conhec_transp.id%type
                                 , en_empr_tomadora_serv    in number default 0 )  -- 0-Não / 1-Sim	
is
   --
   vn_fase                number;
   vd_dt_ult_fecha        fecha_fiscal_empresa.dt_ult_fecha%type;
   vn_empresa_id          empresa.id%type;
   vd_dt_sai_ent          date;
   vn_conhectransp_id     conhec_transp.id%type;
   vn_loggenerico_id      number;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_conhectransp_id_dest,0) > 0 then
      --
      vn_fase := 2;
      --
      if nvl(en_empr_tomadora_serv,0) = 0 then -- 0-Não	  
         --	  
         begin
            --
            select r.conhectransp_id1
                 , ct.empresa_id
                 , nvl(ct.dt_sai_ent, ct.dt_hr_emissao)
              into vn_conhectransp_id
                 , vn_empresa_id
                 , vd_dt_sai_ent
              from conhec_transp ct
                 , r_ct_ct       r
             where ct.id = en_conhectransp_id_dest
               and r.conhectransp_id2 = ct.id;
            --
         exception
            when others then
               vn_empresa_id := 0;
               vd_dt_sai_ent := null;
               vn_conhectransp_id := null;
         end;
         --
      else  -- 1-Sim
         --
         begin
            --
            select r.conhectransp_id1
                 , ct.empresa_id
                 , nvl(ct.dt_sai_ent, ct.dt_hr_emissao)
              into vn_conhectransp_id
                 , vn_empresa_id
                 , vd_dt_sai_ent
              from conhec_transp ct
                 , r_ct_ct       r
             where ct.id = en_conhectransp_id_dest
               and r.conhectransp_id2 = ct.id
               and exists (select 1
                             from v_conhec_transp_tomador v
                            where v.conhectransp_id = ct.id);
            --
         exception
            when others then
               vn_empresa_id := 0;
               vd_dt_sai_ent := null;
               vn_conhectransp_id := null;
         end;
      end if;
      --	  
      vn_fase := 2.1;
      --
      if nvl(vn_conhectransp_id,0) > 0 then
         --
         vn_fase := 3;
         --
         vd_dt_ult_fecha := pk_csf.fkg_recup_dtult_fecha_empresa ( en_empresa_id   => vn_empresa_id
                                                                 , en_objintegr_id => pk_csf.fkg_recup_objintegr_id( ev_cd => '4' )
                                                                 );
         --
         vn_fase := 3.1;
         --
         if vd_dt_ult_fecha is null or
            vd_dt_sai_ent > vd_dt_ult_fecha then
            --
            vn_fase := 4;
            --
            -- Se a exlusão partiu da rotina pk_csf_api_ct.pkb_excluir_dados_ct não será chamada novamente
            if nvl(pk_csf_api_ct.gn_ind_exclu,0) = 0 then
               --
               pk_csf_api_ct.pkb_excluir_dados_ct ( en_conhectransp_id   => en_conhectransp_id_dest
                                                  , en_excl_rloteintwsct => 0 ); -- 0-Não
               --
            end if;
            --
            vn_fase := 4.1;
            --
            delete from ct_cons_sit
             where conhectransp_id = en_conhectransp_id_dest;
            --
            vn_fase := 4.2;
            --
            delete from r_ct_ct
             where conhectransp_id2 = en_conhectransp_id_dest;
            --
            vn_fase := 4.3;
            --
            delete from conhec_transp_imp_ret
             where conhectransp_id = en_conhectransp_id_dest;
            --
            vn_fase := 4.4;
            --
            begin
               delete from conhec_transp
                where id = en_conhectransp_id_dest;
            exception
               when others then
                  if sqlcode = '-2292' THEN
                     -- Esse log será gerado sempre que houver um erro de FK com a tabela conhec_transp
                     gv_resumo   := 'O conhecimento de transporte não pode ser excluído porque possui vínculo com tabela filha.';
                     gv_mensagem := 'Fase (' || vn_fase || '):' || sqlerrm;
                     --
                     pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id    => vn_loggenerico_id
                                                       , ev_mensagem          => gv_mensagem
                                                       , ev_resumo            => gv_resumo
                                                       , en_tipo_log          => pk_csf_api_ct.ERRO_DE_SISTEMA
                                                       , en_referencia_id     => en_conhectransp_id_dest
                                                       , ev_obj_referencia    => 'CONHEC_TRANSP'
                                                       , en_empresa_id        => vn_empresa_id
                                                       , en_dm_impressa       => null
                                                       );
                  end if;
            end;
            --
            commit;
            --
         else
            --
            gv_mensagem := 'Fechamento Fiscal.';
            gv_resumo   := 'Já foi realizado o fechamento do período fiscal para conversão de Conhecimento de Transporte. Empresa: '||pk_csf.fkg_cnpj_ou_cpf_empresa(vn_empresa_id)||
                           ', data do fechamento: '||vd_dt_ult_fecha||', data do documento = '||vd_dt_sai_ent||'.';
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id    => vn_loggenerico_id
                                              , ev_mensagem          => gv_mensagem
                                              , ev_resumo            => gv_resumo
                                              , en_tipo_log          => pk_csf_api_ct.erro_de_validacao
                                              , en_referencia_id     => vn_conhectransp_id
                                              , ev_obj_referencia    => 'CONHEC_TRANSP'
                                              , en_empresa_id        => vn_empresa_id
                                              , en_dm_impressa       => null
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
      gv_mensagem := 'Erro na pk_entr_cte_terceiro.pkb_desfazer_copia_cte fase(' || vn_fase || '):' || sqlerrm;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id    => vn_loggenerico_id
                                        , ev_mensagem          => gv_mensagem
                                        , ev_resumo            => gv_mensagem
                                        , en_tipo_log          => pk_csf_api_ct.ERRO_DE_SISTEMA
                                        , en_referencia_id     => en_conhectransp_id_dest
                                        , ev_obj_referencia    => 'CONHEC_TRANSP'
                                        , en_empresa_id        => vn_empresa_id
                                        , en_dm_impressa       => null
                                        );
      --
      raise_application_error (-20101, gv_mensagem);
      --
end pkb_desfazer_copia_cte;

------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------

-- Procedimento de Cópia dos dados da CTe de Armazenamento de XML de Terceiro
-- para gerar um CTe de Terceiro, sem o limite de 99

procedure pkb_copiar_cte_todos  ( en_empresa_id          in empresa.id%type
                                , ed_dt_ini              in  date
                                , ed_dt_fin              in  date
                                , en_coid_ini            CONHEC_TRANSP.NRO_CT%type
                                , en_coid_fin            CONHEC_TRANSP.NRO_CT%type
                                , ev_serie               CONHEC_TRANSP.SERIE%type
                                , ev_cnpj                CONHEC_TRANSP_EMIT.CNPJ%type
                                , ev_uf_ibge_emit        CONHEC_TRANSP.sigla_uf_emit%type
                                , ev_sigla_uf_ini        CONHEC_TRANSP.sigla_uf_ini%type
                                , ev_sigla_uf_fim        CONHEC_TRANSP.sigla_uf_fim%type
                                , en_dm_dacte_rec        CONHEC_TRANSP.dm_dacte_rec%type
                                , en_dm_st_proc          CONHEC_TRANSP.dm_st_proc%type
                                , en_estado_operacao     in number
                                , ev_modelo              in number
                                , ed_dt_sai_ent          in conhec_transp.dt_sai_ent%type
                                , en_natoper_id          in nat_oper.id%type
                                , en_empr_tomadora_serv  in number default 0 )  -- 0-Não / 1-Sim									
is
   --
   vn_fase      number;
   vn_erro      number;
   vn_id_saida  number;
   vn_ct_id    number;
   vv_dt_ini    VARCHAR2(10):= TO_CHAR(ed_dt_ini,'dd/mm/rrrr');
   vv_dt_fin    VARCHAR2(10):= TO_CHAR(ed_dt_fin,'dd/mm/rrrr');
   --
   vn_loggenerico_id  log_generico_ct.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
      --  inicia montagem da query
    gv_sql := 'select ';
   --
    gv_sql := gv_sql || 'CO.ID';
   -- Monta o FROM
    gv_sql := gv_sql || ' FROM CONHEC_TRANSP CO ';
    gv_sql := gv_sql || ' LEFT JOIN R_CT_CT r ON r.CONHECTRANSP_ID1 = co.ID ';
    gv_sql := gv_sql || ' LEFT JOIN CONHEC_TRANSP cd ON cd.ID = r.CONHECTRANSP_ID2 ';
    gv_sql := gv_sql || ' LEFT JOIN CONHEC_TRANSP_EMIT cte ON cte.CONHECTRANSP_ID = co.ID ';
    gv_sql := gv_sql || ' LEFT JOIN CONHEC_TRANSP_VLPREST ctv ON ctv.CONHECTRANSP_ID = co.ID ';
    if nvl(en_empr_tomadora_serv,0) = 1 then -- 1-Sim
       gv_sql := gv_sql || ' LEFT JOIN V_CONHEC_TRANSP_TOMADOR V ON V.CONHECTRANSP_ID = co.ID ';
    end if;	
    gv_sql := gv_sql || ' LEFT JOIN MOD_FISCAL mf ON mf.ID = co.MODFISCAL_ID ';
   -- Monta a condição do where
    gv_sql := gv_sql || ' WHERE co.EMPRESA_ID = '||en_empresa_id||' ';
    gv_sql := gv_sql || ' AND co.DM_ST_PROC = 4 ';
    gv_sql := gv_sql || ' AND co.DM_ARM_CTE_TERC = 1 ';
    --

    --
    vn_fase := 2;
    --
     IF (ed_dt_ini IS NOT NULL and ed_dt_fin IS NOT NULL ) THEN
     gv_sql := gv_sql || ' and to_date(co.DT_HR_EMISSAO,''dd/mm/rrrr'')  between to_date('''||vv_dt_ini||''',''dd/mm/rrrr'') and to_date('''||vv_dt_fin||''',''dd/mm/rrrr'')  ';
     END IF;
     --
     IF  (ed_dt_ini IS NOT NULL and ed_dt_fin IS NULL) THEN
     gv_sql := gv_sql || ' and to_date(co.DT_HR_EMISSAO,''dd/mm/rrrr'') > to_date('''||vv_dt_ini||''',''dd/mm/rrrr'') ';
     END IF;
     --
     IF  (ed_dt_ini IS NULL and ed_dt_fin IS NOT NULL) THEN
     gv_sql := gv_sql || ' and to_date(co.DT_HR_EMISSAO,''dd/mm/rrrr'') <  to_date('''||vv_dt_fin||''',''dd/mm/rrrr'') ';
     END IF;
     --
     IF  (nvl(en_coid_ini,0) > 0 and nvl(en_coid_fin,0) > 0 ) THEN
     gv_sql := gv_sql || ' and trunc(co.nro_ct) between '||en_coid_ini||'  and '||en_coid_fin||' ';
     END IF;
     --
     IF  (nvl(en_coid_ini,0) > 0 and  nvl(en_coid_fin,0) = 0) THEN
     gv_sql := gv_sql || ' and trunc(co.nro_ct) > '||en_coid_ini||' ';
     END IF;
     --
     IF  (nvl(en_coid_ini,0) = 0 and  nvl(en_coid_fin,0) > 0) THEN
     gv_sql := gv_sql || ' and trunc(co.nro_ct) <  '||en_coid_fin||' ';
     END IF;
     --
     IF  ev_serie is not null THEN
     gv_sql := gv_sql || ' and co.serie = '''||ev_serie ||''' ';
     END IF;
     --
     IF  ev_cnpj is not null THEN
     gv_sql := gv_sql || ' and cte.cnpj = '''||ev_cnpj||''' ';
     END IF;
     --
     IF   ev_uf_ibge_emit is not null THEN
     gv_sql := gv_sql || ' and co.uf_ibge_emit = '||ev_uf_ibge_emit||' ';
     END IF;
     --
     IF  (ev_sigla_uf_ini IS NOT NULL and ev_sigla_uf_fim IS NOT NULL) THEN
     gv_sql := gv_sql || ' and co.sigla_uf_ini = '''||ev_sigla_uf_ini||''' and co.sigla_uf_fim = '''||ev_sigla_uf_fim||''' ';
     END IF;
     --
     IF  (ev_sigla_uf_ini IS NOT NULL and ev_sigla_uf_fim IS NULL) THEN
     gv_sql := gv_sql || ' and co.sigla_uf_ini = '''||ev_sigla_uf_ini||''' ';
     END IF;
     --
     IF  (ev_sigla_uf_ini IS NULL and ev_sigla_uf_fim IS NOT NULL) THEN
     gv_sql := gv_sql || ' and co.sigla_uf_fim = '''||ev_sigla_uf_fim||''' ';
     END IF;
     --
     IF  nvl(en_dm_dacte_rec,0) > 0  THEN
     gv_sql := gv_sql || ' and cd.dm_dacte_rec = '||en_dm_dacte_rec||' ';
     END IF;
     --
     IF  nvl(en_dm_st_proc,0) > 0 THEN
     gv_sql := gv_sql || ' and cd.dm_st_proc = '||en_dm_st_proc||' ';
     END IF;
     --
     IF  (en_estado_operacao = 1) THEN
     gv_sql := gv_sql || ' and co.sigla_uf_ini <> co.sigla_uf_fim';
     END IF;
     --
     IF  (en_estado_operacao = 2) THEN
     gv_sql := gv_sql || ' and co.sigla_uf_ini = co.sigla_uf_fim';
     END IF;
     --
     IF  ev_modelo > 0 THEN
     gv_sql := gv_sql || ' and mf.modelo = '''||ev_modelo||''' ';
     END IF;

     gv_sql := gv_sql || ' AND co.CTE_PROC_XML IS NOT NULL AND ROWNUM <= 10000';

   vn_fase := 3;

--declare vv_erro varchar2 (2000);
  begin
       --
     execute immediate gv_sql bulk collect into vt_tab_csf_conhec_transp;
      --
  exception
    when others then
            null;--   vv_erro:= sqlerrm;
   end;


for i in vt_tab_csf_conhec_transp.first..vt_tab_csf_conhec_transp.last loop

   if (vt_tab_csf_conhec_transp.count) > 0 then
      --
      --
      vn_ct_id:= vt_tab_csf_conhec_transp(i).ID;
      --
     vn_fase := 2;
      --| Data de Entrada/Saída do CTe de Destino
      gd_dt_sai_ent := trunc(nvl(ed_dt_sai_ent, sysdate));
      gn_empresa_id := en_empresa_id;
      gn_multorg_id := pk_csf.fkg_multorg_id_empresa ( en_empresa_id => en_empresa_id );
      gn_natoper_id := en_natoper_id;
      --
      -- seta o tipo de integração que será feito
      -- 0 - Somente válida os dados e registra o Log de ocorrência
      -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
      -- Todos os procedimentos de integração fazem referência a ele
      pk_csf_api_ct.pkb_seta_tipo_integr ( en_tipo_integr => 1 );
      --
      vn_fase := 2.1;
      --
      pk_csf_api_ct.pkb_seta_obj_ref ( ev_objeto => 'CONHEC_TRANSP' );
      --
      vn_fase := 2.2;
      -- procedimento de excluir os logs da NFe de origem para geração dos dados de destino
      begin
         delete from log_generico_ct lg
          where lg.obj_referencia = 'CONHEC_TRANSP'
            and lg.referencia_id  = vn_ct_id;
      exception
         when others then
            --
            gv_mensagem := 'Problemas ao excluir log_generico_ct da CONHEC_TRANSP de origem - pk_entr_cte_terceiro.pkb_copiar_cte fase('||vn_fase||'):'||sqlerrm;
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id    => vn_loggenerico_id
                                              , ev_mensagem          => gv_mensagem
                                              , ev_resumo            => gv_mensagem
                                              , en_tipo_log          => pk_csf_api_ct.ERRO_DE_SISTEMA
                                              , en_referencia_id     => vn_ct_id
                                              , ev_obj_referencia    => 'CONHEC_TRANSP'
                                              );
            --
            raise_application_error (-20101, gv_mensagem);
            --
      end;
      --
      commit;
      --
      vn_fase := 2.4;
      --
      vn_erro := fkg_verif_param_da_cte (  en_conhectransp_id_orig => vn_ct_id );
      --
      if nvl(vn_erro,0) <= 0 then
         --
         vn_fase := 2.5;
         -- procedimento de ler os dados da CTe de origem para geração dos dados de destino
         pkb_ler_Conhec_Transp_orig (  en_conhectransp_id_orig => vn_ct_id );
         --
      end if;
      --
      vn_fase := 2.6;
      --
      commit;
      --
      vn_fase := 99;
      -- Finaliza o log genérico para a integração das CTe no CSF
      pk_csf_api_ct.pkb_finaliza_log_generico_ct;
      --
      pk_csf_api_ct.pkb_seta_tipo_integr ( en_tipo_integr => null );
      --
   else
      --
      gv_mensagem := 'Não informado o CTe de origem ou Natureza de Operação.';
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id    => vn_loggenerico_id
                                        , ev_mensagem          => gv_mensagem
                                        , ev_resumo            => gv_mensagem
                                        , en_tipo_log          => pk_csf_api_ct.ERRO_DE_SISTEMA
                                        , en_referencia_id     => vn_ct_id
                                        , ev_obj_referencia    => 'CONHEC_TRANSP'
                                        );
      --
   end if;
   --
   vn_id_saida := vn_ct_id;
   --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_entr_cte_terceiro.pkb_copiar_cte fase(' || vn_fase || '):' || sqlerrm;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id    => vn_loggenerico_id
                                        , ev_mensagem          => gv_mensagem
                                        , ev_resumo            => gv_mensagem
                                        , en_tipo_log          => pk_csf_api_ct.ERRO_DE_SISTEMA
                                        , en_referencia_id     => vn_id_saida
                                        , ev_obj_referencia    => 'CONHEC_TRANSP'
                                        );
      --
      raise_application_error (-20101, gv_mensagem);
      --
end pkb_copiar_cte_todos;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- Procedimento desfaz a cópia da CTe, sem o limite de 99

procedure pkb_desfazer_copia_cte_todos ( en_empresa_id          in empresa.id%type
                                , ed_dt_ini              in  date
                                , ed_dt_fin              in  date
                                , en_coid_ini            CONHEC_TRANSP.NRO_CT%type
                                , en_coid_fin            CONHEC_TRANSP.NRO_CT%type
                                , ev_serie               CONHEC_TRANSP.SERIE%type
                                , ev_cnpj                CONHEC_TRANSP_EMIT.CNPJ%type
                                , ev_uf_ibge_emit        CONHEC_TRANSP.sigla_uf_emit%type
                                , ev_sigla_uf_ini        CONHEC_TRANSP.sigla_uf_ini%type
                                , ev_sigla_uf_fim        CONHEC_TRANSP.sigla_uf_fim%type
                                , en_dm_dacte_rec        CONHEC_TRANSP.dm_dacte_rec%type
                                , en_dm_st_proc          CONHEC_TRANSP.dm_st_proc%type
                                , en_estado_operacao     in number
                                , ev_modelo              in number
                                , en_empr_tomadora_serv  in number default 0  -- 0-Não / 1-Sim									
                                        )
is
   --
   vn_fase                number;
   vd_dt_ult_fecha        fecha_fiscal_empresa.dt_ult_fecha%type;
   vn_empresa_id          empresa.id%type;
   vd_dt_sai_ent          date;
   vn_conhectransp_id     conhec_transp.id%type;
   vn_loggenerico_id      number;
   vn_id_saida2           number;
   vn_ct_id               number;
   vv_dt_ini    VARCHAR2(10):= TO_CHAR(ed_dt_ini,'dd/mm/rrrr');
   vv_dt_fin    VARCHAR2(10):= TO_CHAR(ed_dt_fin,'dd/mm/rrrr');
   --
begin
   --
   vn_fase := 1;
   --
      --  inicia montagem da query
    gv_sql := 'select ';
   --
    gv_sql := gv_sql || 'CO.ID';
   -- Monta o FROM
    gv_sql := gv_sql || ' FROM CONHEC_TRANSP CO ';
    gv_sql := gv_sql || ' LEFT JOIN R_CT_CT r ON r.CONHECTRANSP_ID1 = co.ID ';
    gv_sql := gv_sql || ' LEFT JOIN CONHEC_TRANSP cd ON cd.ID = r.CONHECTRANSP_ID2 ';
    gv_sql := gv_sql || ' LEFT JOIN CONHEC_TRANSP_EMIT cte ON cte.CONHECTRANSP_ID = co.ID ';
    gv_sql := gv_sql || ' LEFT JOIN CONHEC_TRANSP_VLPREST ctv ON ctv.CONHECTRANSP_ID = co.ID ';
    if nvl(en_empr_tomadora_serv,0) = 1 then -- 1-Sim
       gv_sql := gv_sql || ' LEFT JOIN V_CONHEC_TRANSP_TOMADOR V ON V.CONHECTRANSP_ID = co.ID ';
    end if;
    gv_sql := gv_sql || ' LEFT JOIN MOD_FISCAL mf ON mf.ID = co.MODFISCAL_ID ';
   -- Monta a condição do where
    gv_sql := gv_sql || ' WHERE co.EMPRESA_ID = '||en_empresa_id||' ';
    gv_sql := gv_sql || ' AND co.DM_ST_PROC = 4 ';
    gv_sql := gv_sql || ' AND co.DM_ARM_CTE_TERC = 1 ';
    --
    --
    vn_fase := 2;
    --
     IF (ed_dt_ini IS NOT NULL and ed_dt_fin IS NOT NULL ) THEN
     gv_sql := gv_sql || ' and to_date(co.DT_HR_EMISSAO,''dd/mm/rrrr'')  between to_date('''||vv_dt_ini||''',''dd/mm/rrrr'') and to_date('''||vv_dt_fin||''',''dd/mm/rrrr'')  ';
     END IF;
     --
     IF  (ed_dt_ini IS NOT NULL and ed_dt_fin IS NULL) THEN
     gv_sql := gv_sql || ' and to_date(co.DT_HR_EMISSAO,''dd/mm/rrrr'') > to_date('''||vv_dt_ini||''',''dd/mm/rrrr'') ';
     END IF;
     --
     IF  (ed_dt_ini IS NULL and ed_dt_fin IS NOT NULL) THEN
     gv_sql := gv_sql || ' and to_date(co.DT_HR_EMISSAO,''dd/mm/rrrr'') <  to_date('''||vv_dt_fin||''',''dd/mm/rrrr'') ';
     END IF;
     --
     IF  (nvl(en_coid_ini,0) > 0 and nvl(en_coid_fin,0) > 0 ) THEN
     gv_sql := gv_sql || ' and trunc(co.nro_ct) between '||en_coid_ini||'  and '||en_coid_fin||' ';
     END IF;
     --
     IF  (nvl(en_coid_ini,0) > 0 and  nvl(en_coid_fin,0) = 0) THEN
     gv_sql := gv_sql || ' and trunc(co.nro_ct) > '||en_coid_ini||' ';
     END IF;
     --
     IF  (nvl(en_coid_ini,0) = 0 and  nvl(en_coid_fin,0) > 0) THEN
     gv_sql := gv_sql || ' and trunc(co.nro_ct) <  '||en_coid_fin||' ';
     END IF;
     --
     IF  ev_serie is not null THEN
     gv_sql := gv_sql || ' and co.serie = '''||ev_serie ||''' ';
     END IF;
     --
     IF  ev_cnpj is not null THEN
     gv_sql := gv_sql || ' and cte.cnpj = '''||ev_cnpj||''' ';
     END IF;
     --
     IF   ev_uf_ibge_emit is not null THEN
     gv_sql := gv_sql || ' and co.uf_ibge_emit = '||ev_uf_ibge_emit||' ';
     END IF;
     --
     IF  (ev_sigla_uf_ini IS NOT NULL and ev_sigla_uf_fim IS NOT NULL) THEN
     gv_sql := gv_sql || ' and co.sigla_uf_ini = '''||ev_sigla_uf_ini||''' and co.sigla_uf_fim = '''||ev_sigla_uf_fim||''' ';
     END IF;
     --
     IF  (ev_sigla_uf_ini IS NOT NULL and ev_sigla_uf_fim IS NULL) THEN
     gv_sql := gv_sql || ' and co.sigla_uf_ini = '''||ev_sigla_uf_ini||''' ';
     END IF;
     --
     IF  (ev_sigla_uf_ini IS NULL and ev_sigla_uf_fim IS NOT NULL) THEN
     gv_sql := gv_sql || ' and co.sigla_uf_fim = '''||ev_sigla_uf_fim||''' ';
     END IF;
     --
     IF  nvl(en_dm_dacte_rec,0) > 0  THEN
     gv_sql := gv_sql || ' and cd.dm_dacte_rec = '||en_dm_dacte_rec||' ';
     END IF;
     --
     IF  nvl(en_dm_st_proc,0) > 0 THEN
     gv_sql := gv_sql || ' and cd.dm_st_proc = '||en_dm_st_proc||' ';
     END IF;
     --
     IF  (en_estado_operacao = 1) THEN
     gv_sql := gv_sql || ' and co.sigla_uf_ini <> co.sigla_uf_fim';
     END IF;
     --
     IF  (en_estado_operacao = 2) THEN
     gv_sql := gv_sql || ' and co.sigla_uf_ini = co.sigla_uf_fim';
     END IF;
     --
     IF  ev_modelo > 0 THEN
     gv_sql := gv_sql || ' and mf.modelo = '''||ev_modelo||''' ';
     END IF;

     gv_sql := gv_sql || ' AND co.CTE_PROC_XML IS NOT NULL AND ROWNUM <= 10000';

   vn_fase := 3;

  begin
       --
     execute immediate gv_sql bulk collect into vt_tab_csf_conhec_transp;
      --
  exception
    when others then
            null;--   vv_erro:= sqlerrm;
   end;


for i in vt_tab_csf_conhec_transp.first..vt_tab_csf_conhec_transp.last loop

   if (vt_tab_csf_conhec_transp.count) > 0 then
      --
      vn_fase := 3;
      --
      vn_ct_id:= vt_tab_csf_conhec_transp(i).ID;
      --
      begin
         --
         select ct.id
              , ct.empresa_id
              , nvl(ct.dt_sai_ent, ct.dt_hr_emissao)
           into vn_conhectransp_id
              , vn_empresa_id
              , vd_dt_sai_ent
           from conhec_transp ct
              , r_ct_ct       r
          where r.conhectransp_id1 =  vn_ct_id
            and r.conhectransp_id2 =  ct.id;
         --
      exception
         when others then
            vn_empresa_id := 0;
            vd_dt_sai_ent := null;
            vn_conhectransp_id := null;
      end;
      --
      vn_fase := 2.1;
      --
      if nvl(vn_conhectransp_id,0) > 0 then
         --
         vn_fase := 3;
         --
         vd_dt_ult_fecha := pk_csf.fkg_recup_dtult_fecha_empresa ( en_empresa_id   => vn_empresa_id
                                                                 , en_objintegr_id => pk_csf.fkg_recup_objintegr_id( ev_cd => '4' )
                                                                 );
         --
         vn_fase := 3.1;
         --
         if vd_dt_ult_fecha is null or
            vd_dt_sai_ent > vd_dt_ult_fecha then
            --
            vn_fase := 4;
            --
            -- Se a exlusão partiu da rotina pk_csf_api_ct.pkb_excluir_dados_ct não será chamada novamente
            if nvl(pk_csf_api_ct.gn_ind_exclu,0) = 0 then
               --
               pk_csf_api_ct.pkb_excluir_dados_ct ( en_conhectransp_id   => vn_conhectransp_id
                                                  , en_excl_rloteintwsct => 0 ); -- 0-Não
               --
            end if;
            --
            vn_fase := 4.1;
            --
            delete from ct_cons_sit
             where conhectransp_id = vn_conhectransp_id;
            --
            vn_fase := 4.2;
            --
            delete from r_ct_ct
             where conhectransp_id2 = vn_conhectransp_id;
            --
            vn_fase := 4.3;
            --
            delete from conhec_transp_imp_ret
             where conhectransp_id = vn_conhectransp_id;
            --
            vn_fase := 4.4;
            --
            begin
               delete from conhec_transp
                where id = vn_conhectransp_id;
            exception
               when others then
                  if sqlcode = '-2292' THEN
                     -- Esse log será gerado sempre que houver um erro de FK com a tabela conhec_transp
                     gv_resumo   := 'O conhecimento de transporte não pode ser excluído porque possui vínculo com tabela filha.';
                     gv_mensagem := 'Fase (' || vn_fase || '):' || sqlerrm;
                     --
                     pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id    => vn_loggenerico_id
                                                       , ev_mensagem          => gv_mensagem
                                                       , ev_resumo            => gv_resumo
                                                       , en_tipo_log          => pk_csf_api_ct.ERRO_DE_SISTEMA
                                                       , en_referencia_id     => vn_conhectransp_id
                                                       , ev_obj_referencia    => 'CONHEC_TRANSP'
                                                       , en_empresa_id        => vn_empresa_id
                                                       , en_dm_impressa       => null
                                                       );
                  end if;
            end;
            --
            commit;
            --
         else
            --
            gv_mensagem := 'Fechamento Fiscal.';
            gv_resumo   := 'Já foi realizado o fechamento do período fiscal para conversão de Conhecimento de Transporte. Empresa: '||pk_csf.fkg_cnpj_ou_cpf_empresa(vn_empresa_id)||
                           ', data do fechamento: '||vd_dt_ult_fecha||', data do documento = '||vd_dt_sai_ent||'.';
            --
            pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id    => vn_loggenerico_id
                                              , ev_mensagem          => gv_mensagem
                                              , ev_resumo            => gv_resumo
                                              , en_tipo_log          => pk_csf_api_ct.erro_de_validacao
                                              , en_referencia_id     => vn_conhectransp_id
                                              , ev_obj_referencia    => 'CONHEC_TRANSP'
                                              , en_empresa_id        => vn_empresa_id
                                              , en_dm_impressa       => null
                                              );
            --
         end if;
         --
      end if;
      --
   end if;
   --
   vn_id_saida2 := vn_conhectransp_id;
   --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_entr_cte_terceiro.pkb_desfazer_copia_cte fase(' || vn_fase || '):' || sqlerrm;
      --
      pk_csf_api_ct.pkb_log_generico_ct ( sn_loggenerico_id    => vn_loggenerico_id
                                        , ev_mensagem          => gv_mensagem
                                        , ev_resumo            => gv_mensagem
                                        , en_tipo_log          => pk_csf_api_ct.ERRO_DE_SISTEMA
                                        , en_referencia_id     => vn_id_saida2
                                        , ev_obj_referencia    => 'CONHEC_TRANSP'
                                        , en_empresa_id        => vn_empresa_id
                                        , en_dm_impressa       => null
                                        );
      --
      raise_application_error (-20101, gv_mensagem);
      --

         --
end pkb_desfazer_copia_cte_todos;

------------------------------------------------------------------------------------------

end pk_entr_cte_terceiro;
/
