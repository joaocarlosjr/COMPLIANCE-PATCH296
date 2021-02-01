create or replace package body csf_own.pk_csf_gera_dados_fci is

-------------------------------------------------------------------------------------------------------
-- Especificação do pacote de Geração de Dados da Ficha de Conteudo do Importação.
-------------------------------------------------------------------------------------------------------    
-- Verificar se existe a necessidade de geração de um novo numero de FCI para os Itens da Abertura.
procedure pkb_verif_nro_fci_ant is
  --
  vn_fase             number;
  vn_mcfciitemnf_id   mcfci_itemnf.id%type;
  vv_nro_fci          retorno_fci.nro_fci%type;
  vd_max_dt_fin                date;
  vn_max_infitemfci_id         number;
  vt_retorno_fci      retorno_fci%rowtype;
  --
  cursor c_inf is
  select ii.*
    from inf_item_fci ii
   where ii.aberturafciarq_id = pk_csf_api_fci.gt_abertura_fci_arq.id;
  --
begin
  --
  vn_fase := 1;
  --
  if nvl(pk_csf_api_fci.gt_abertura_fci.id,0) > 0 then
     --
     vn_fase := 2;
     --
     for rec in c_inf loop
      exit when c_inf%notfound or (c_inf%notfound) is null;
        --
        vn_fase := 3;
        --
        vt_retorno_fci := null;
        vd_max_dt_fin := null;
        vn_max_infitemfci_id := null;
        --
        begin
           --
           select max(af.dt_fin)
             into vd_max_dt_fin
             from inf_item_fci      ii
                , retorno_fci       rf
                , abertura_fci_arq  afa
                , abertura_fci      af
            where 1 = 1
              and ii.item_id        = rec.item_id
              and ii.coef_import between (rec.coef_import - 5) and (rec.coef_import + 5)
              and rf.infitemfci_id  = ii.id
              and rf.nro_fci        is not null
              and afa.id            = ii.aberturafciarq_id
              and afa.dm_situacao   = 8 -- Finalizado
              and af.id             = afa.aberturafci_id
              and af.empresa_id     = pk_csf_api_fci.gt_abertura_fci.empresa_id
              and af.dt_fin         < pk_csf_api_fci.gt_abertura_fci.dt_fin;
            --
        exception
           when no_data_found then
              vd_max_dt_fin := null;
        end;
        --
        vn_fase := 3.1;
        --
        if vd_max_dt_fin is not null then
           --
           vn_fase := 4;
           --
           begin
              --
              select max(ii.id)
                into vn_max_infitemfci_id
                from inf_item_fci      ii
                   , retorno_fci       rf
                   , abertura_fci_arq  afa
                   , abertura_fci      af
               where 1 = 1
                 and ii.item_id        = rec.item_id
                 and ii.coef_import between (rec.coef_import - 5) and (rec.coef_import + 5)
                 and rf.infitemfci_id  = ii.id
                 and rf.nro_fci        is not null
                 and afa.id            = ii.aberturafciarq_id
                 and afa.dm_situacao   = 8 -- Finalizado
                 and af.id             = afa.aberturafci_id
                 and af.empresa_id     = pk_csf_api_fci.gt_abertura_fci.empresa_id
                 and af.dt_fin         = vd_max_dt_fin;
              --
           exception
              when others then
                 vn_max_infitemfci_id := null;
           end;
           --
           vn_fase := 4.1;
           --
           if nvl(vn_max_infitemfci_id,0) > 0 then
              --
              vn_fase := 4.2;
              --
              begin
                 --
                 select * into vt_retorno_fci
                  from retorno_fci
                 where infitemfci_id = vn_max_infitemfci_id;
                 --
              exception
                 when others then
                    vt_retorno_fci := null;
              end;
              --
              vn_fase := 4.3;
              --
              if nvl(vt_retorno_fci.id,0) > 0 then
                 --
                 select retornofci_seq.nextval
                   into vt_retorno_fci.id
                   from dual;
                 --
                 vn_fase := 4.4;
                 --
                 vt_retorno_fci.item_id := rec.item_id;
                 vt_retorno_fci.infitemfci_id := rec.id;
                 vt_retorno_fci.dm_tipo := 1; -- Importado
                 --
                 vn_fase := 4.5;
                 --
                 insert into retorno_fci ( id
                                         , item_id
                                         , infitemfci_id
                                         , nro_fci
                                         , dm_tipo
                                         )
                                   values( vt_retorno_fci.id
                                         , vt_retorno_fci.item_id
                                         , vt_retorno_fci.infitemfci_id
                                         , vt_retorno_fci.nro_fci
                                         , vt_retorno_fci.dm_tipo
                                         );
                 --
                 vn_fase := 4.6;
                 --
                 update inf_item_fci
                    set dm_situacao = 8 -- Finalizado
                  where id = rec.id;
                 --
              else
                 --
                 vn_fase := 4.7;
                 --
                 update inf_item_fci
                    set dm_situacao = 5 -- Aguardando Envio
                  where id = rec.id;
                 --
              end if;
              --
           else
              --
              vn_fase := 4.8;
              --
              update inf_item_fci
                 set dm_situacao = 5 -- Aguardando Envio
               where id = rec.id;
              --
           end if;
           --
        else
           --
           vn_fase := 5;
           --
           update inf_item_fci
              set dm_situacao = 5 -- Aguardando Envio
            where id = rec.id
              and dm_situacao = 3; -- Calculado
           --
        end if;
        --
        commit;
        --
     end loop;
     --
  end if;
  --
exception
   when others then
      --
      pk_csf_api_fci.gv_resumo := 'Erro na pk_csf_gera_dados_fci.pkb_verif_nro_fci_ant fase:'|| vn_fase ||' Erro: '|| sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_fci.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_fci.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_fci.gv_resumo
                                         , en_tipo_log        => pk_csf_api_fci.ERRO_DE_SISTEMA
                                         , en_referencia_id   => pk_csf_api_fci.gn_referencia_id
                                         , ev_obj_referencia  => pk_csf_api_fci.gv_obj_referencia
                                         );
      exception
         when others then
            null;
      end;
      --
end pkb_verif_nro_fci_ant;

-------------------------------------------------------------------------------------------------------
-- Processo Responsavel por recuperar médias de calculos ponderados dos meses anteriores.
procedure pkb_gerar_calc_anter( sn_med_pond_item out nocopy mem_calc_fci.vl_med_pond_item%type
                              , en_item_id       in item.id%type
                              , en_dm_ind_oper   in nota_fiscal.dm_ind_oper%type
                              , sn_memcalcfci_id out mem_calc_fci.id%type
                              , en_infitemfci_id in inf_item_fci.id%type
                              )
is
   --
   vn_fase                      number := null;
   vt_mem_calc_iifci            mem_calc_iifci%rowtype;
   vd_max_dt_fin                date;
   vn_max_memcalcfci_id         number;
   vt_mem_calc_fci              mem_calc_fci%rowtype;
   --
begin
   --
   vn_max_memcalcfci_id := null;
   --
   vn_fase := 1;
   --
   begin
      --
      select max(af.dt_fin)
        into vd_max_dt_fin
        from mem_calc_fci      mc
           , inf_item_fci      ii
           , abertura_fci_arq  afa
           , abertura_fci      af
       where 1 = 1
         and mc.item_id        = en_item_id
         and mc.dm_tipo_item   = en_dm_ind_oper
         and ii.id             = mc.infitemfci_id
         and afa.id            = ii.aberturafciarq_id
         and afa.dm_situacao   = 8 -- Finalizado
         and af.id             = afa.aberturafci_id
         and af.empresa_id     = pk_csf_api_fci.gt_abertura_fci.empresa_id
         and af.dt_fin         < pk_csf_api_fci.gt_abertura_fci.dt_fin;
      --
   exception
      when no_data_found then
         vd_max_dt_fin := null;
   end;
   --
   vn_fase := 1.1;
   --
   begin
      --
      select max(mc.id)
        into vn_max_memcalcfci_id
        from mem_calc_fci      mc
           , inf_item_fci      ii
           , abertura_fci_arq  afa
           , abertura_fci      af
       where 1 = 1
         and mc.item_id        = en_item_id
         and mc.dm_tipo_item   = en_dm_ind_oper
         and ii.id             = mc.infitemfci_id
         and afa.id            = ii.aberturafciarq_id
         and afa.dm_situacao   = 8 -- Finalizado         
         and af.id             = afa.aberturafci_id
         and af.empresa_id     = pk_csf_api_fci.gt_abertura_fci.empresa_id
         and mc.qtde_item      > 0
         and af.dt_fin         = vd_max_dt_fin;
      --
   exception
      when no_data_found then
         vn_max_memcalcfci_id := null;
   end;
   --
   vn_fase := 1.2;
   --
   vt_mem_calc_iifci := null;
   --
   if nvl(vn_max_memcalcfci_id,0) > 0 then -- Verifica se encontrou um mémoria anterior do item
      --
      begin
         --
         select * into vt_mem_calc_fci
           from mem_calc_fci
          where id = vn_max_memcalcfci_id;
         --
      exception
         when others then
            vt_mem_calc_fci := null;
      end;
      --
      vt_mem_calc_iifci.id := pk_csf_fci.fkg_verif_memcalciifci_id ( en_infitemfci_id => en_infitemfci_id
                                                                   , en_memcalcfci_id => vn_max_memcalcfci_id );
      --
      vt_mem_calc_iifci.infitemfci_id := en_infitemfci_id;
      vt_mem_calc_iifci.memcalcfci_id := vt_mem_calc_fci.id;
      vt_mem_calc_iifci.vl_med_pond_item := nvl(vt_mem_calc_fci.VL_MED_POND_ITEM,0) / nvl(vt_mem_calc_fci.QTDE_ITEM,1);
      --
      if nvl(vt_mem_calc_iifci.id,0) = 0 then
         --
         select memcalciifci_seq.nextval
           into vt_mem_calc_iifci.id
           from dual;
         --
         insert into mem_calc_iifci ( id
                                    , infitemfci_id
                                    , memcalcfci_id
                                    , vl_med_pond_item )
                              values( vt_mem_calc_iifci.id
                                    , vt_mem_calc_iifci.infitemfci_id
                                    , vt_mem_calc_iifci.memcalcfci_id
                                    , vt_mem_calc_iifci.vl_med_pond_item );
         --
      else
         --
         update mem_calc_iifci
            set infitemfci_id    = vt_mem_calc_iifci.infitemfci_id
              , memcalcfci_id    = vt_mem_calc_iifci.memcalcfci_id
              , vl_med_pond_item = vt_mem_calc_iifci.vl_med_pond_item
          where id               = vt_mem_calc_iifci.id;
         --
      end if;
      --
      sn_memcalcfci_id := vn_max_memcalcfci_id;
      sn_med_pond_item := nvl(vt_mem_calc_fci.VL_MED_POND_ITEM,0) / nvl(vt_mem_calc_fci.QTDE_ITEM,1);
      commit;
      --
   else
      --
      pk_csf_api_fci.gv_resumo := 'Não foi encontrado nenhuma Mem_Calc_Fci anterior para Nota Fiscal de entrada do ITEM: ' || pk_csf.fkg_Item_cod ( en_item_id => en_item_id ) ||
                                  ', favor verificar a possibilidade de Importação de Calculos dos meses anteriores.';
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_fci.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_fci.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_fci.gv_resumo
                                         , en_tipo_log        => pk_csf_api_fci.INFORMACAO
                                         , en_referencia_id   => pk_csf_api_fci.gn_referencia_id
                                         , ev_obj_referencia  => pk_csf_api_fci.gv_obj_referencia
                                         );
      exception
         when others then
            null;
      end;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_fci.gv_resumo := 'Erro na pk_csf_gera_dados_fci.pkb_gerar_calc_anter fase:'|| vn_fase ||' Erro: '|| sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_fci.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_fci.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_fci.gv_resumo
                                         , en_tipo_log        => pk_csf_api_fci.ERRO_DE_SISTEMA
                                         , en_referencia_id   => pk_csf_api_fci.gn_referencia_id
                                         , ev_obj_referencia  => pk_csf_api_fci.gv_obj_referencia
                                         );
      exception
         when others then
            null;
      end;
      --
end pkb_gerar_calc_anter;

-------------------------------------------------------------------------------------------------------
-- Buscar valores a partir das notas fiscais que estejam dentro do periodo e insere na MCFCI_ITEMNF
procedure pkb_buscar_vlr_nf ( en_memcalcfci_id in         mem_calc_fci.id%type
                            , en_item_id       in         item_insumo.item_id_ins%type
                            , en_dm_ind_oper   in         nota_fiscal.dm_ind_oper%type
                            , en_dm_ind_emit   in         nota_fiscal.dm_ind_emit%type
                            , en_tipo_data     in         number default 0
                            )
is
   --
   vn_fase                  number;
   i                        pls_integer;
   --
   vt_row_mcfci_itemnf      mcfci_itemnf%rowtype;
   vn_vl_item_tot           number;
   --
   vn_cfop                cfop.cd%type;
   vn_vl_operacao         number;
   vv_cod_st_icms         cod_st.cod_st%type;
   vn_vl_base_calc_icms   imp_itemnf.vl_base_calc%type;
   vn_aliq_icms           imp_itemnf.aliq_apli%type;
   vn_vl_imp_trib_icms    imp_itemnf.vl_imp_trib%type;
   vn_vl_base_calc_icmsst imp_itemnf.vl_base_calc%type;
   vn_vl_imp_trib_icmsst  imp_itemnf.vl_imp_trib%type;
   vn_vl_bc_isenta_icms   number;
   vn_vl_bc_outra_icms    number;
   vv_cod_st_ipi          cod_st.cod_st%type;
   vn_vl_base_calc_ipi    imp_itemnf.vl_base_calc%type;
   vn_aliq_ipi            imp_itemnf.aliq_apli%type;
   vn_vl_imp_trib_ipi     imp_itemnf.vl_imp_trib%type;
   vn_vl_bc_isenta_ipi    number;
   vn_vl_bc_outra_ipi     number;
   vn_ipi_nao_recup       number;
   vn_outro_ipi           number;
   vn_vl_imp_nao_dest_ipi number;
   vn_vl_fcp_icmsst       number;
   vn_aliq_fcp_icms       number;
   vn_vl_fcp_icms         number;
   vn_fat_conv            conversao_unidade.fat_conv%type := null;
   vn_dm_orig_merc        item.dm_orig_merc%type := null;
   vb_achou_nf_periodo    boolean := false;
   vd_dt_inicio           date := null;
   vn_aliq_apli_ii        imp_itemnf.aliq_apli%type;
   --
   -- nf de entrada interestaduais
   cursor c_nf (ed_dt_inicio in date) is
   select inf.id itemnotafiscal_id
        , inf.item_id
        , inf.unid_com
        , inf.vl_unit_comerc
        , inf.qtde_comerc
        , inf.vl_item_bruto
     from nota_fiscal      nf
        , mod_fiscal       mf
        , item_nota_fiscal inf
        , cfop             cf
        , tipo_operacao    top
    where 1 = 1
      and nf.empresa_id      = pk_csf_api_fci.gt_abertura_fci.empresa_id
      and nf.dm_ind_emit     = en_dm_ind_emit
      and nf.dm_ind_oper     = en_dm_ind_oper
      and nf.dm_fin_nfe      = 1
      and nf.dm_st_proc      = 4 -- Autorizada
      and nf.dm_arm_nfe_terc = 0 -- Não
      and ( ( en_tipo_data in (-2, -1)
            and  trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between add_months(pk_csf_api_fci.gt_abertura_fci.dt_ini, en_tipo_data)  and add_months(pk_csf_api_fci.gt_abertura_fci.dt_fin, en_tipo_data)
            --) or ( en_tipo_data not in (-2, -1) and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) <= pk_csf_api_fci.gt_abertura_fci.dt_fin )
            ) or ( en_tipo_data not in (-2, -1) and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between ed_dt_inicio and pk_csf_api_fci.gt_abertura_fci.dt_fin )
          )
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod         = '55'
      and inf.notafiscal_id  = nf.id
      and inf.item_id        = en_item_id
      and inf.cfop_id        = cf.id
      and cf.tipooperacao_id = top.id
      and top.cd             <> 3 -- Não é Devolução

    union all

    select  i.id itemnotafiscal_id 
          , i.item_id
          , i.unid_com
          , i.vl_unit_comerc
          , i.qtde_comerc
          , i.vl_item_bruto
    from nota_fiscal_referen nfr
        ,nota_fiscal nf
        ,nota_fiscal nf2
        ,item_nota_fiscal i
   where 1=1
     and nf2.id = i.notafiscal_id
     and nf2.dm_fin_nfe   = 2
     and nf2.dm_st_proc   = 4
     and i.item_id        = en_item_id
     and nf2.id           = nfr.notafiscal_id
     and nf.nro_chave_nfe = nfr.nro_chave_nfe
     and nf.id in (select nf.id
                     from nota_fiscal      nf
                        , mod_fiscal       mf
                        , item_nota_fiscal inf
                        , cfop             cf
                        , tipo_operacao    top
                    where 1 = 1
                      and nf.empresa_id      = pk_csf_api_fci.gt_abertura_fci.empresa_id
                      and nf.dm_ind_emit     = en_dm_ind_emit
                      and nf.dm_ind_oper     = en_dm_ind_oper
                      and nf.dm_fin_nfe      = 1
                      and nf.dm_st_proc      = 4 -- Autorizada
                      and nf.dm_arm_nfe_terc = 0 -- Não
                      and ( ( en_tipo_data in (-2, -1)
                            and  trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between add_months(pk_csf_api_fci.gt_abertura_fci.dt_ini, en_tipo_data)  and add_months(pk_csf_api_fci.gt_abertura_fci.dt_fin, en_tipo_data)
                            --) or ( en_tipo_data not in (-2, -1) and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) <= pk_csf_api_fci.gt_abertura_fci.dt_fin )
                            ) or ( en_tipo_data not in (-2, -1) and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between ed_dt_inicio and pk_csf_api_fci.gt_abertura_fci.dt_fin )
                          )
                      and mf.id              = nf.modfiscal_id
                      and mf.cod_mod         = '55'
                      and inf.notafiscal_id  = nf.id
                      and inf.item_id        = en_item_id
                      and inf.cfop_id        = cf.id
                      and cf.tipooperacao_id = top.id
                      and top.cd             <> 3 -- Não é Devolução
                      )
   order by itemnotafiscal_id;   
   --
   -- nf de devolução
   cursor c_nf_dev (ed_dt_inicio in date) is
   select inf.id itemnotafiscal_id
        , inf.item_id
        , inf.unid_com
        , inf.vl_unit_comerc
        , inf.qtde_comerc
        , inf.vl_item_bruto
     from nota_fiscal      nf
        , mod_fiscal       mf
        , item_nota_fiscal inf
        , cfop             cf
        , tipo_operacao    top
    where 1 = 1
      and nf.empresa_id      = pk_csf_api_fci.gt_abertura_fci.empresa_id
      and nf.dm_ind_emit     = en_dm_ind_emit
      and nf.dm_ind_oper     = en_dm_ind_oper
      and nf.dm_st_proc      = 4 -- Autorizada
      and nf.dm_arm_nfe_terc = 0 -- Não
      and ( ( en_tipo_data in (-2, -1)
            and  trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between add_months(pk_csf_api_fci.gt_abertura_fci.dt_ini, en_tipo_data)  and add_months(pk_csf_api_fci.gt_abertura_fci.dt_fin, en_tipo_data)
            ) or ( en_tipo_data not in (-2, -1) and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between ed_dt_inicio and pk_csf_api_fci.gt_abertura_fci.dt_fin )
          )
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod         = '55'
      and inf.notafiscal_id  = nf.id
      and inf.item_id        = en_item_id
      and inf.cfop_id        = cf.id
      and cf.tipooperacao_id = top.id
      and top.cd             = 3 -- É Devolução
    order by inf.id;
   --
begin
   --
   vn_fase := 1;
   --
   if en_tipo_data = 0 then -- Recuperar o último mês que houve entrada ou saída do Item/Consumo
      --
      begin
         select max(trunc(nf.dt_emiss,'mm'))
           into vd_dt_inicio
           from nota_fiscal      nf
              , mod_fiscal       mf
              , item_nota_fiscal inf
          where 1 = 1
            and nf.empresa_id      = pk_csf_api_fci.gt_abertura_fci.empresa_id
            and nf.dm_ind_emit     = en_dm_ind_emit
            and nf.dm_ind_oper     = en_dm_ind_oper
            and nf.dm_fin_nfe      = 1
            and nf.dm_st_proc      = 4 -- Autorizada
            and nf.dm_arm_nfe_terc = 0 -- Não
            and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) <= pk_csf_api_fci.gt_abertura_fci.dt_fin
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod         = '55'
            and inf.notafiscal_id  = nf.id
            and inf.item_id        = en_item_id;
      exception
         when others then
            vd_dt_inicio := pk_csf_api_fci.gt_abertura_fci.dt_ini;
      end;
      --
   else
      --
      vd_dt_inicio := pk_csf_api_fci.gt_abertura_fci.dt_ini;
      --
   end if;
   --
   if nvl(en_item_id,0) > 0 then
      --
      vn_fase := 2;
      --
      i  := null;
      --
      for rec in c_nf (ed_dt_inicio => vd_dt_inicio) loop
       exit when c_nf%notfound or (c_nf%notfound) is null;
         --
         vn_fase := 3;
         --
         vt_row_mcfci_itemnf    := null;
         vn_vl_item_tot         := null;
         vn_cfop                := null;
         vn_vl_operacao         := null;
         vv_cod_st_icms         := null;
         vn_vl_base_calc_icms   := null;
         vn_aliq_icms           := null;
         vn_vl_imp_trib_icms    := null;
         vn_vl_base_calc_icmsst := null;
         vn_vl_imp_trib_icmsst  := null;
         vn_vl_bc_isenta_icms   := null;
         vn_vl_bc_outra_icms    := null;
         vv_cod_st_ipi          := null;
         vn_vl_base_calc_ipi    := null;
         vn_aliq_ipi            := null;
         vn_vl_imp_trib_ipi     := null;
         vn_vl_bc_isenta_ipi    := null;
         vn_vl_bc_outra_ipi     := null;
         vn_ipi_nao_recup       := null;
         vn_outro_ipi           := null;
         vn_vl_imp_nao_dest_ipi := null;
         vn_vl_fcp_icmsst       := null;
         vn_aliq_fcp_icms       := null;
         vn_vl_fcp_icms         := null;
         --
         vn_fase := 3.1;
         --
         pk_csf_api.pkb_vlr_fiscal_item_nf ( en_itemnf_id           => rec.itemnotafiscal_id
                                           , sn_cfop                => vn_cfop
                                           , sn_vl_operacao         => vn_vl_operacao
                                           , sv_cod_st_icms         => vv_cod_st_icms
                                           , sn_vl_base_calc_icms   => vn_vl_base_calc_icms
                                           , sn_aliq_icms           => vn_aliq_icms
                                           , sn_vl_imp_trib_icms    => vn_vl_imp_trib_icms
                                           , sn_vl_base_calc_icmsst => vn_vl_base_calc_icmsst
                                           , sn_vl_imp_trib_icmsst  => vn_vl_imp_trib_icmsst
                                           , sn_vl_bc_isenta_icms   => vn_vl_bc_isenta_icms
                                           , sn_vl_bc_outra_icms    => vn_vl_bc_outra_icms
                                           , sv_cod_st_ipi          => vv_cod_st_ipi
                                           , sn_vl_base_calc_ipi    => vn_vl_base_calc_ipi
                                           , sn_aliq_ipi            => vn_aliq_ipi
                                           , sn_vl_imp_trib_ipi     => vn_vl_imp_trib_ipi
                                           , sn_vl_bc_isenta_ipi    => vn_vl_bc_isenta_ipi
                                           , sn_vl_bc_outra_ipi     => vn_vl_bc_outra_ipi
                                           , sn_ipi_nao_recup       => vn_ipi_nao_recup
                                           , sn_outro_ipi           => vn_outro_ipi
                                           , sn_vl_imp_nao_dest_ipi => vn_vl_imp_nao_dest_ipi
                                           , sn_vl_fcp_icmsst       => vn_vl_fcp_icmsst
                                           , sn_aliq_fcp_icms       => vn_aliq_fcp_icms
                                           , sn_vl_fcp_icms         => vn_vl_fcp_icms
                                           );
         --
         vn_fase := 3.2;
         --
         if substr(vn_cfop, 1, 1) in (1, 2, 5, 6) then -- Estadual e Interestadual, desconta o ICMS e IPI do valor da operação
            vn_vl_item_tot := nvl(vn_vl_operacao,0) - nvl(vn_vl_imp_trib_icms,0) - nvl(vn_vl_imp_trib_ipi,0);
         else
            --vn_vl_item_tot := nvl(vn_vl_operacao,0);
            if substr(vn_cfop, 1, 1) = (3) then -- Importação - Entradas
               vn_vl_item_tot := nvl(rec.vl_item_bruto,0);
            else
               vn_vl_item_tot := nvl(vn_vl_operacao,0);
            end if;
         end if;
         --
         vn_fase := 3.3;
         --
         if en_dm_ind_oper = 0 then -- Entrada
            --
            begin
               select it.dm_orig_merc
                 into vn_dm_orig_merc
                 from item it
                where it.id = en_item_id; -- item_id_ins - insumo = rec.item_id
            exception
               when others then
                  vn_dm_orig_merc := 1;
            end;
            --
            if vn_dm_orig_merc = 3 then -- Nacional, mercadoria ou bem com Conteúdo de Importação superior a 40%
               vn_vl_item_tot := (nvl(vn_vl_item_tot,0) / 2); -- considerar metade do valor
            end if;
            --
            if vn_dm_orig_merc in (6,7) then
               -- 6-Estrangeira - Importação direta, sem similar nacional, constante em lista da CAMEX
               -- 7-Estrangeira - Adquirida no mercado interno, sem similar nacional, constante em lista da CAMEX
               begin
                  select ii.aliq_apli
                    into vn_aliq_apli_ii
                    from imp_itemnf ii
                       , tipo_imposto ti
                   where ii.itemnf_id = rec.itemnotafiscal_id
                     and ti.id        = ii.tipoimp_id
                     and ti.cd        = 7; -- II-Imposto de importação
               exception
                  when others then
                     vn_aliq_apli_ii := -1;
               end;
               --
               if nvl(vn_aliq_apli_ii,0) in (0,2) then -- 0% ou 2%, não considerar o valor do item
                  vn_vl_item_tot := 0;
               end if;
               --
            end if;
            --
         end if; -- en_dm_ind_oper = 0-Entrada
         --
         vn_fase := 3.4;
         --
         begin
            select cn.fat_conv
              into vn_fat_conv
              from item              it
                 , unidade           un
                 , unidade           ui
                 , conversao_unidade cn
             where it.id         = rec.item_id
               and un.id         = it.unidade_id
               and upper(un.sigla_unid) <> upper(rec.unid_com)
               and upper(ui.sigla_unid)  = upper(rec.unid_com)
               and cn.item_id    = it.id
               and cn.unidade_id = ui.id;
         exception
            when others then
               vn_fat_conv := 1;
         end;
         --
         vn_fase := 3.5;
         --
         vn_vl_item_tot := (nvl(vn_vl_item_tot,0) * nvl(vn_fat_conv,0));
         --
         vn_fase := 3.6;
         -- registra a memoria de calculo para o insumo
         vt_row_mcfci_itemnf.memcalcfci_id     := en_memcalcfci_id;
         vt_row_mcfci_itemnf.itemnotafiscal_id := rec.itemnotafiscal_id;
         vt_row_mcfci_itemnf.vl_item_tot       := nvl(vn_vl_item_tot,0);
         vt_row_mcfci_itemnf.dm_tipo_nf        := 0; -- Compra
         --
         pk_csf_api_fci.pkb_integr_mcfciitemnf ( est_row_mcfci_itemnf => vt_row_mcfci_itemnf );
         --
         vn_fase := 3.7;
         --
         vb_achou_nf_periodo := true;
         --
      end loop;
      --
      vn_fase := 4;
      --
      -- Verificar se houve Notas Fiscais de Devolução
      for rec in c_nf_dev (ed_dt_inicio => vd_dt_inicio) loop
       exit when c_nf_dev%notfound or (c_nf_dev%notfound) is null;
         --
         vn_fase := 5;
         --
         vt_row_mcfci_itemnf    := null;
         vn_vl_item_tot         := null;
         vn_cfop                := null;
         vn_vl_operacao         := null;
         vv_cod_st_icms         := null;
         vn_vl_base_calc_icms   := null;
         vn_aliq_icms           := null;
         vn_vl_imp_trib_icms    := null;
         vn_vl_base_calc_icmsst := null;
         vn_vl_imp_trib_icmsst  := null;
         vn_vl_bc_isenta_icms   := null;
         vn_vl_bc_outra_icms    := null;
         vv_cod_st_ipi          := null;
         vn_vl_base_calc_ipi    := null;
         vn_aliq_ipi            := null;
         vn_vl_imp_trib_ipi     := null;
         vn_vl_bc_isenta_ipi    := null;
         vn_vl_bc_outra_ipi     := null;
         vn_ipi_nao_recup       := null;
         vn_outro_ipi           := null;
         vn_vl_imp_nao_dest_ipi := null;
         vn_vl_fcp_icmsst       := null;
         vn_aliq_fcp_icms       := null;
         vn_vl_fcp_icms         := null;
         --
         vn_fase := 5.1;
         --
         pk_csf_api.pkb_vlr_fiscal_item_nf ( en_itemnf_id           => rec.itemnotafiscal_id
                                           , sn_cfop                => vn_cfop
                                           , sn_vl_operacao         => vn_vl_operacao
                                           , sv_cod_st_icms         => vv_cod_st_icms
                                           , sn_vl_base_calc_icms   => vn_vl_base_calc_icms
                                           , sn_aliq_icms           => vn_aliq_icms
                                           , sn_vl_imp_trib_icms    => vn_vl_imp_trib_icms
                                           , sn_vl_base_calc_icmsst => vn_vl_base_calc_icmsst
                                           , sn_vl_imp_trib_icmsst  => vn_vl_imp_trib_icmsst
                                           , sn_vl_bc_isenta_icms   => vn_vl_bc_isenta_icms
                                           , sn_vl_bc_outra_icms    => vn_vl_bc_outra_icms
                                           , sv_cod_st_ipi          => vv_cod_st_ipi
                                           , sn_vl_base_calc_ipi    => vn_vl_base_calc_ipi
                                           , sn_aliq_ipi            => vn_aliq_ipi
                                           , sn_vl_imp_trib_ipi     => vn_vl_imp_trib_ipi
                                           , sn_vl_bc_isenta_ipi    => vn_vl_bc_isenta_ipi
                                           , sn_vl_bc_outra_ipi     => vn_vl_bc_outra_ipi
                                           , sn_ipi_nao_recup       => vn_ipi_nao_recup
                                           , sn_outro_ipi           => vn_outro_ipi
                                           , sn_vl_imp_nao_dest_ipi => vn_vl_imp_nao_dest_ipi
                                           , sn_vl_fcp_icmsst       => vn_vl_fcp_icmsst
                                           , sn_aliq_fcp_icms       => vn_aliq_fcp_icms
                                           , sn_vl_fcp_icms         => vn_vl_fcp_icms
                                           );
         --
         vn_fase := 5.2;
         --
         if substr(vn_cfop, 1, 1) in (1, 2, 5, 6) then -- Estadual e Interestadual, desconta o ICMS e IPI do valor da operação
            vn_vl_item_tot := nvl(vn_vl_operacao,0) - nvl(vn_vl_imp_trib_icms,0) - nvl(vn_vl_imp_trib_ipi,0);
         else
            --vn_vl_item_tot := nvl(vn_vl_operacao,0);
            if substr(vn_cfop, 1, 1) = (3) then -- Importação - Entradas
               vn_vl_item_tot := nvl(rec.vl_item_bruto,0);
            else
               vn_vl_item_tot := nvl(vn_vl_operacao,0);
            end if;
         end if;
         --
         vn_fase := 5.3;
         --
         if en_dm_ind_oper = 0 then -- Entrada
            --
            begin
               select it.dm_orig_merc
                 into vn_dm_orig_merc
                 from item it
                where it.id = en_item_id; -- item_id_ins - insumo = rec.item_id
            exception
               when others then
                  vn_dm_orig_merc := 1;
            end;
            --
            if vn_dm_orig_merc = 3 then -- Nacional, mercadoria ou bem com Conteúdo de Importação superior a 40%
               vn_vl_item_tot := (nvl(vn_vl_item_tot,0) / 2); -- considerar metade do valor
            end if;
            --
            if vn_dm_orig_merc in (6,7) then
               -- 6-Estrangeira - Importação direta, sem similar nacional, constante em lista da CAMEX
               -- 7-Estrangeira - Adquirida no mercado interno, sem similar nacional, constante em lista da CAMEX
               begin
                  select ii.aliq_apli
                    into vn_aliq_apli_ii
                    from imp_itemnf   ii
                       , tipo_imposto ti
                   where ii.itemnf_id = rec.itemnotafiscal_id
                     and ti.id        = ii.tipoimp_id
                     and ti.cd        = 7; -- II-Imposto de importação
               exception
                  when others then
                     vn_aliq_apli_ii := -1;
               end;
               --
               if nvl(vn_aliq_apli_ii,0) in (0,2) then -- 0% ou 2%, não considerar o valor do item
                  vn_vl_item_tot := 0;
               end if;
               --
            end if;
            --
         end if; -- en_dm_ind_oper = 0-Entrada
         --
         vn_fase := 5.4;
         --
         begin
            select cn.fat_conv
              into vn_fat_conv
              from item              it
                 , unidade           un
                 , unidade           ui
                 , conversao_unidade cn
             where it.id         = rec.item_id
               and un.id         = it.unidade_id
               and upper(un.sigla_unid) <> upper(rec.unid_com)
               and upper(ui.sigla_unid)  = upper(rec.unid_com)
               and cn.item_id    = it.id
               and cn.unidade_id = ui.id;
         exception
            when others then
               vn_fat_conv := 1;
         end;
         --
         vn_fase := 5.5;
         --
         vn_vl_item_tot := (nvl(vn_vl_item_tot,0) * nvl(vn_fat_conv,0));
         --
         vn_fase := 5.6;
         --
         vt_row_mcfci_itemnf.memcalcfci_id     := en_memcalcfci_id;
         vt_row_mcfci_itemnf.itemnotafiscal_id := rec.itemnotafiscal_id;
         vt_row_mcfci_itemnf.vl_item_tot       := nvl(vn_vl_item_tot,0);
         vt_row_mcfci_itemnf.dm_tipo_nf        := 1; -- Devolução
         --
         pk_csf_api_fci.pkb_integr_mcfciitemnf ( est_row_mcfci_itemnf => vt_row_mcfci_itemnf );
         --
      end loop;
      --
      vn_fase := 6;
      --
      if not vb_achou_nf_periodo then
         -- trabalha a recursividade
         vn_fase := 7;
         --
         if en_dm_ind_oper = 0 then -- Entrada
            --
            vn_fase := 8;
            --
            if en_dm_ind_emit = 0 -- Emissão propria
               and en_tipo_data = -2
               then
               --
               vn_fase := 8.1;
               pkb_buscar_vlr_nf ( en_memcalcfci_id => en_memcalcfci_id
                                 , en_item_id       => en_item_id
                                 , en_dm_ind_oper   => en_dm_ind_oper
                                 , en_dm_ind_emit   => en_dm_ind_emit
                                 , en_tipo_data     => -1  -- Busca o mês anterior a geração
                                 );
               --
            elsif en_dm_ind_emit = 0 -- Emissão propria
               and en_tipo_data = -1
               then
               --
               vn_fase := 8.2;
               pkb_buscar_vlr_nf ( en_memcalcfci_id => en_memcalcfci_id
                                 , en_item_id       => en_item_id
                                 , en_dm_ind_oper   => en_dm_ind_oper
                                 , en_dm_ind_emit   => en_dm_ind_emit
                                 , en_tipo_data     => 0  -- Busca em qualquer período igual ou anterior a geração
                                 );
               --
            elsif en_dm_ind_emit = 0 -- Emissão propria
               and en_tipo_data = 0
               then
               -- Inverte de Emissão Própria para terceiro
               vn_fase := 8.3;
               pkb_buscar_vlr_nf ( en_memcalcfci_id => en_memcalcfci_id
                                 , en_item_id       => en_item_id
                                 , en_dm_ind_oper   => en_dm_ind_oper
                                 , en_dm_ind_emit   => 1 -- Terceiro
                                 , en_tipo_data     => -2 -- Pesquisa pelo penultimo mes da geração
                                 );
               --
            elsif en_dm_ind_emit = 1 -- Terceiro
               and en_tipo_data = -2
               then
               --
               vn_fase := 8.4;
               pkb_buscar_vlr_nf ( en_memcalcfci_id => en_memcalcfci_id
                                 , en_item_id       => en_item_id
                                 , en_dm_ind_oper   => en_dm_ind_oper
                                 , en_dm_ind_emit   => en_dm_ind_emit
                                 , en_tipo_data     => -1  -- Busca o mês anterior a geração
                                 );
               --
            elsif en_dm_ind_emit = 1 -- Terceiro
               and en_tipo_data = -1
               then
               --
               vn_fase := 8.5;
               pkb_buscar_vlr_nf ( en_memcalcfci_id => en_memcalcfci_id
                                 , en_item_id       => en_item_id
                                 , en_dm_ind_oper   => en_dm_ind_oper
                                 , en_dm_ind_emit   => en_dm_ind_emit
                                 , en_tipo_data     => 0  -- Busca em qualquer período igual ou anterior a geração
                                 );
               --
            end if;
            --
         else
            --
            vn_fase := 9;
            -- Operação de Saída
            if en_dm_ind_emit = 0 -- Emissão propria
               and en_tipo_data = -2
               then
               --
               vn_fase := 9.1;
               pkb_buscar_vlr_nf ( en_memcalcfci_id => en_memcalcfci_id
                                 , en_item_id       => en_item_id
                                 , en_dm_ind_oper   => en_dm_ind_oper
                                 , en_dm_ind_emit   => en_dm_ind_emit
                                 , en_tipo_data     => -1  -- Busca o mês anterior a geração
                                 );
               --
            elsif en_dm_ind_emit = 0 -- Emissão propria
               and en_tipo_data = -1
               then
               --
               vn_fase := 9.2;
               pkb_buscar_vlr_nf ( en_memcalcfci_id => en_memcalcfci_id
                                 , en_item_id       => en_item_id
                                 , en_dm_ind_oper   => en_dm_ind_oper
                                 , en_dm_ind_emit   => en_dm_ind_emit
                                 , en_tipo_data     => 0  -- Busca em qualquer período igual ou anterior a geração
                                 );
               --
             end if;
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
      pk_csf_api_fci.gv_resumo := 'Erro na pk_csf_gera_dados_fci.pkb_buscar_vlr_nf fase:'|| vn_fase ||' Erro: '|| sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_fci.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_fci.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_fci.gv_resumo
                                         , en_tipo_log        => pk_csf_api_fci.ERRO_DE_SISTEMA
                                         , en_referencia_id   => pk_csf_api_fci.gn_referencia_id
                                         , ev_obj_referencia  => pk_csf_api_fci.gv_obj_referencia
                                         );
      exception
         when others then
            null;
      end;
      --
end pkb_buscar_vlr_nf;

-------------------------------------------------------------------------------------------------------
-- Procedimento de recuperação dos valores de Saida
procedure pkb_recup_vlr_saida ( en_aberturafciarq_id in abertura_fci_arq.id%type )
is
   --
   vn_memcalcfci_id             mem_calc_fci.id%type := null;
   vn_memcalcfci_id_old         mem_calc_fci.id%type := null;
   vn_qtde_comerc               item_nota_fiscal.qtde_comerc%type := null;
   vn_med_pond_item_old         number := null;
   vn_fase                      number := null;
   --
   vn_qtde_dev                  item_nota_fiscal.qtde_comerc%type := null;
   vn_vl_item_tot               mcfci_itemnf.vl_item_tot%type := null;
   vn_med_pond_item             mem_calc_fci.vl_med_pond_item%type := null;
   vn_vl_est_venda              item_compl.vl_est_venda%type;
   --
   vv_cfop                      cfop.cd%type := null;
   vt_row_mcfci_itemnf          mcfci_itemnf%rowtype;
   vn_vl_imp_trib               imp_itemnf.vl_imp_trib%type;
   --
   vn_loggenerico_id            log_generico.id%type;
   --
   cursor c_inf is
   select ii.*
     from inf_item_fci  ii
    where aberturafciarq_id = en_aberturafciarq_id
      and dm_situacao       = 1; -- validado
   --
  cursor c_calc ( en_memcalcfci_id in mem_calc_fci.id%type) is
  select mi.vl_item_tot
       , inf.qtde_comerc
    from mcfci_itemnf mi
       , item_nota_fiscal inf
   where memcalcfci_id = en_memcalcfci_id
     and inf.id        = mi.itemnotafiscal_id
     and mi.dm_tipo_nf = 0; -- Compra/Venda
   --
   cursor c_nf_est ( en_item_id in item.id%type ) is
   select nvl(sum(nvl(inf.vl_unit_comerc,0)),0) vl_unit_comerc
        , nvl(sum(nvl(inf.qtde_comerc,0)),0)    qtde_comer
        , inf.id itemnotafiscal_id
     from nota_fiscal nf
        , item_nota_fiscal inf
        , cfop             cf
        , tipo_operacao    top
        , mod_fiscal       mf
    where inf.item_id       = en_item_id
      and inf.notafiscal_id = nf.id
      and nf.dm_st_proc = 4 -- Autorizada
      and nf.dm_arm_nfe_terc = 0 -- Não
      and nf.modfiscal_id    = mf.id
      and mf.cod_mod = '55'
      and nf.empresa_id     = pk_csf_api_fci.gt_abertura_fci.empresa_id
      and nf.dm_ind_oper     = 1 -- Saida
      and nf.dm_ind_emit     = 0 -- Emissão Própria
      and inf.cfop_id        = cf.id
      and cf.tipooperacao_id = top.id
      and top.cd             <> 3
      and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between pk_csf_api_fci.gt_abertura_fci.dt_ini and pk_csf_api_fci.gt_abertura_fci.dt_fin
    group by inf.id;
begin
   --
   vn_fase := 1;
   --
   if nvl(en_aberturafciarq_id,0) > 0 then
      --
      vn_fase := 2;
      --
      for rec in c_inf loop
       exit when c_inf%notfound or (c_inf%notfound) is null;
         --
         vn_fase := 3;
         --
         gn_infitemfci_id := rec.id;
         vn_memcalcfci_id := null;
         --
         begin
            --
            vn_fase := 3.1;
            --
            vn_memcalcfci_id := pk_csf_fci.fkg_memcalcfci_id ( en_item_id       => rec.item_id
                                                             , en_infitemfci_id => rec.id
                                                             );
            --
            vn_fase := 3.2;
            --
            if nvl(vn_memcalcfci_id,0) = 0 then
               --
               vn_fase := 3.3;
               --
               pk_csf_fci.pkb_gerar_memcalcfci ( en_memcalcfci_id     => vn_memcalcfci_id
                                               , en_item_id           => rec.item_id
                                               , en_infitemfci_id     => rec.id
                                               , en_dm_tipo_item      => 1 -- Saida
                                               , en_aberturafciarq_id => rec.aberturafciarq_id
                                               );
               --
            end if;
            --
         end;
         --
         vn_fase := 4;
         --
         pkb_buscar_vlr_nf ( en_memcalcfci_id  => vn_memcalcfci_id
                           , en_item_id        => rec.item_id
                           , en_dm_ind_oper    => 1 -- Saida
                           , en_dm_ind_emit    => 0 -- Emissão Própria
                           , en_tipo_data      => -2 -- Pesquisa pelo penultimo mes da geração
                           );
         --
         vn_fase := 4.1;
         --
         vn_qtde_dev := null;
         -- Verificar se a quantidade comprada foi suficiente
         vn_qtde_comerc := pk_csf_fci.fkg_qtde_item_recup ( en_memcalcfci_id => vn_memcalcfci_id
                                                          , en_dm_tipo_nf    => 0  -- Compra/Venda
                                                          );
         --
         vn_fase := 4.2;
         -- Recuperar a quantidade de NF de devolução
         vn_qtde_dev := pk_csf_fci.fkg_qtde_item_recup ( en_memcalcfci_id => vn_memcalcfci_id );
         --
         -- Verificar se a quantidade Vendida é maior que zero
         vn_qtde_comerc := nvl(vn_qtde_comerc,0) - nvl(vn_qtde_dev,0);
         --
         vn_fase := 4.3;
         --
         if nvl(vn_qtde_comerc,0) <= 0 then
            --
            vn_fase := 5;
            -- Buscar Notas Fiscais de dentro do estado.
            for r_nf_est in c_nf_est(rec.item_id) loop
             exit when c_nf_est%notfound or (c_nf_est%notfound) is null;
               --
               vn_fase := 5.1;
               --
               vn_vl_imp_trib := 0;
               --
               begin
                  select nvl(sum(nvl(vl_imp_trib,0)),0)
                    into vn_vl_imp_trib
                    from imp_itemnf ii
                       , tipo_imposto ti
                   where ii.itemnf_id  = r_nf_est.itemnotafiscal_id
                     and ii.tipoimp_id = ti.id
                     and ti.cd         in (1,3) -- ICMS, IPI
                     and ii.dm_tipo    = 0; -- Imposto
               exception
                  when no_data_found then
                     vn_vl_imp_trib := 0;
               end;
               --
               vn_fase := 5.2;
               --
               vt_row_mcfci_itemnf.memcalcfci_id     := vn_memcalcfci_id;
               vt_row_mcfci_itemnf.itemnotafiscal_id := r_nf_est.itemnotafiscal_id;
               vt_row_mcfci_itemnf.vl_item_tot       :=(nvl(r_nf_est.vl_unit_comerc,0) - nvl(vn_vl_imp_trib,0)) * r_nf_est.qtde_comer;
               vt_row_mcfci_itemnf.dm_tipo_nf        := 0; -- Compra/Devolução
               --
               vn_fase := 5.3;
               --
               pk_csf_api_fci.pkb_integr_mcfciitemnf ( est_row_mcfci_itemnf => vt_row_mcfci_itemnf );
               --
            end loop;
            --
            vn_fase := 6;
            --
            vn_qtde_comerc := 0;
            --
            -- Verificar se a quantidade comprada foi suficiente
            vn_qtde_comerc := pk_csf_fci.fkg_qtde_item_recup ( en_memcalcfci_id => vn_memcalcfci_id
                                                             , en_dm_tipo_nf    => 0  -- Compra/Venda
                                                             );
            --
            vn_fase := 6.1;
            --
            vn_qtde_comerc := nvl(vn_qtde_comerc,0) - nvl(vn_qtde_dev,0);
            --
            vn_med_pond_item_old := null;
            vn_memcalcfci_id_old := null;
            --
            vn_fase := 6.2;
            --
            if nvl(vn_qtde_comerc,0) <= 0 then
               -- Caso não seja encontrado nenhuma NF de venda para o item
               -- Recuperar Calculos anteriores
               --
               vn_fase := 6.3;
               --
               pkb_gerar_calc_anter( en_item_id       => rec.item_id
                                   , en_dm_ind_oper   => 1 -- Saida
                                   , sn_memcalcfci_id => vn_memcalcfci_id_old
                                   , en_infitemfci_id => rec.id
                                   , sn_med_pond_item => vn_med_pond_item_old
                                   );
               --
            end if;
            --
         end if;
         --
         vn_fase := 7;
         --
         if nvl(pk_csf_fci.fkg_verif_memcalciifci_id ( rec.id, vn_memcalcfci_id_old),0) > 0
         or nvl(vn_qtde_comerc,0) > 0 then
            --
            vn_fase := 8;
            --
            begin
               --
               vn_vl_item_tot := 0;
               vn_qtde_comerc := 0;
               --
               select nvl(sum(nvl(mi.vl_item_tot,0)),0)
                    , nvl(sum(nvl(inf.qtde_comerc,0)),0)
                 into vn_vl_item_tot
                    , vn_qtde_comerc
                 from mcfci_itemnf mi
                    , item_nota_fiscal inf
                where memcalcfci_id = vn_memcalcfci_id
                  and inf.id        = mi.itemnotafiscal_id;
                --
            exception
               when others then
                  vn_vl_item_tot := 0;
                  vn_qtde_comerc := 0;
            end;
            --
            vn_fase := 8.1;
            --
           -- vn_med_pond_item := nvl(vn_med_pond_item_old,0) + nvl(vn_vl_item_tot,0);
            --
           -- if nvl(vn_med_pond_item_old,0) > 0 then
               --
           --    vn_qtde_comerc := 1 + nvl(vn_qtde_comerc,0);
               --
           -- end if;
            --
            vn_fase := 8.2;
            --
            if vn_qtde_comerc = 0 then
               --
               update mem_calc_fci
                  set vl_med_pond_item = ( nvl(vn_vl_item_tot,0) / 1 )
                    , qtde_item        = nvl(vn_qtde_comerc,0)
                where id               = vn_memcalcfci_id;
               --
            else
               --
               update mem_calc_fci
                  set vl_med_pond_item = ( nvl(vn_vl_item_tot,0) / nvl(vn_qtde_comerc,0) )
                    , qtde_item        = nvl(vn_qtde_comerc,0)
                where id               = vn_memcalcfci_id;
               --
            end if;
            --
            vn_fase := 8.3;
            --
            commit;
            --
         else
            --
            -- Caso tenha encontrado nenhum tipo de NF Recuperar o Valor Estimado do ITEM
            vn_fase := 9;
            --
            vn_vl_est_venda := null;
            --
            begin
               --
               select vl_est_venda
                 into vn_vl_est_venda
                 from item_compl ic
                where item_id = rec.item_id;
               --
            exception
               when no_data_found then
                  vn_vl_est_venda := null;
            end;
            --
            vn_fase := 9.1;
            --
            if nvl(vn_vl_est_venda,0) <= 0 then
               --
               vn_fase := 9.2;
               --
               pk_csf_api_fci.gv_resumo := 'Não informado valor de estimativa de venda, para o Item ' || pk_csf.fkg_Item_cod ( en_item_id => rec.item_id ) || '!';
               --
               pk_csf_api_fci.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                               , ev_mensagem        => pk_csf_api_fci.gv_mensagem_log
                                               , ev_resumo          => pk_csf_api_fci.gv_resumo
                                               , en_tipo_log        => pk_csf_api_fci.ERRO_DE_VALIDACAO
                                               , en_referencia_id   => pk_csf_api_fci.gn_referencia_id
                                               , ev_obj_referencia  => pk_csf_api_fci.gv_obj_referencia
                                               );
               --
               vn_fase := 9.3;
               --
               update inf_item_fci
                  set dm_situacao = 4 -- erro de calculado
                where id = rec.id;
               --
               goto erro_calculo;
               --
            end if;
            --
            vn_fase := 9.4;
            --
            update mem_calc_fci
               set vl_med_pond_item = nvl(vn_vl_est_venda,0)
                 , qtde_item        = 1
             where id               = vn_memcalcfci_id;
            --
            vn_fase := 9.5;
            --
            commit;
            --
         end if;
         --
         vn_fase := 10;
         --
         update inf_item_fci
            set dm_situacao = 3 --calculado
          where id = rec.id;
         --
         <<erro_calculo>>
         --
         vn_fase := 11;
         --
         commit;
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      update inf_item_fci
         set dm_situacao = 4 -- erro de calculado
       where id = gn_infitemfci_id;
      --
      commit;
      --
      pk_csf_api_fci.gv_resumo := 'Erro na pk_csf_gera_dados_fci.pkb_recup_vlr_saida fase(' || vn_fase || '):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_fci.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_fci.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_fci.gv_resumo
                                         , en_tipo_log        => pk_csf_api_fci.ERRO_DE_SISTEMA
                                         , en_referencia_id   => pk_csf_api_fci.gn_referencia_id
                                         , ev_obj_referencia  => pk_csf_api_fci.gv_obj_referencia
                                         );
      exception
         when others then
            null;
      end;
      --
end pkb_recup_vlr_saida;

-------------------------------------------------------------------------------------------------------
-- Procedimento de Recuperação de valores de Notas de Entrada
procedure pkb_recup_vlr_entrada ( en_aberturafciarq_id in abertura_fci_arq.id%type
                                )
is
   --
   vn_fase                      number := null;
   i                            pls_integer;
   vn_memcalcfci_id             mem_calc_fci.id%type;
   vn_memcalcfci_id_old         mem_calc_fci.id%type;
   vn_qtde_compr                item_nota_fiscal.qtde_comerc%type;
   --
   vn_qtde_item_old             item_nota_fiscal.QTDE_COMERC%type;
   vn_med_pond_item_old         mcfci_itemnf.vl_item_tot%type := null;
   vn_vl_item_tot               mcfci_itemnf.vl_item_tot%type := null;
   vn_qtde_item                 item_nota_fiscal.QTDE_COMERC%type;
   --
   vn_med_pond_item             mem_calc_fci.vl_med_pond_item%type;
   ve_qtd_ins_insufic           exception;
   vn_item_id                   item.id%type;
   --
   vb_gera_fci                  boolean := false;
   --
   cursor c_inf is
   select ii.*
     from inf_item_fci  ii
    where aberturafciarq_id = en_aberturafciarq_id
      and dm_situacao       = 1; -- validado
   --
   cursor c_itens_orig ( en_item_id in item.id%type )is
   select it.*
     from item_insumo ii
        , item it
    where 1 = 1
      and it.dm_orig_merc in (1, 2, 3, 6, 7, 8)
      and ii.item_id_ins = it.id
      and ii.item_id = en_item_id;
--    start with ii.item_id = en_item_id
--  connect by ii.item_id = prior ii.item_id_ins;
   --
   cursor c_itens ( en_item_id in item.id%type )is
   select ii.*
     from item_insumo ii
        , item it
    where it.dm_orig_merc in (1, 2, 3, 6, 7, 8)
      and ii.item_id_ins = it.id
      and ii.item_id     = en_item_id;
  --
  cursor c_calc ( en_memcalcfci_id in mem_calc_fci.id%type ) is
  select mi.vl_item_tot
       , inf.qtde_comerc
    from mcfci_itemnf      mi
       , item_nota_fiscal  inf
   where memcalcfci_id = en_memcalcfci_id
     and inf.id        = mi.itemnotafiscal_id;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_aberturafciarq_id,0) > 0 then
      --
      vn_fase := 2;
      --
      for rec in c_inf loop
       exit when c_inf%notfound or (c_inf%notfound) is null;
         --
         vn_fase := 3;
         --
         gn_infitemfci_id := rec.id;
         --
         vn_qtde_compr := null;
         vb_gera_fci   := false;
         -----------------------------------------------------------------------------------
         -- Se o unico insumo de origem exterior for de origem 6 ou 7, não irá gerar o FCI
         -- 6-Estrangeira - Importação direta, sem similar nacional, constante em lista da CAMEX
         -- 7-Estrangeira - Adquirida no mercado interno, sem similar nacional, constante em lista da CAMEX.
         -----------------------------------------------------------------------------------
         for rec_itens_orig in c_itens_orig (rec.item_id) loop
            exit when c_itens_orig%notfound or (c_itens_orig%notfound) is null;
            --
            vn_fase := 3.1;
            --
            if rec_itens_orig.dm_orig_merc not in (6, 7) then
               --
               vb_gera_fci := true;
               goto gera_fci;
               --
            else
               --
               vb_gera_fci := false;
               --
            end if;
            --
         end loop;
         --
         -----------------------------------------------------------------------------------
         --
         vn_fase := 4;
         --
         <<gera_fci>>
         --
         if vb_gera_fci then -- Sim gera o FCI
            --
            vn_fase := 5;
            -- Recupera todos os Itens de insumo até mesmo os Insumos que compõe o Item de Insumo
            for rec2 in c_itens (rec.item_id) loop
             exit when c_itens%notfound or (c_itens%notfound) is null;
               --
               vn_fase := 5.1;
               --
               vn_memcalcfci_id := null;
               --
               begin
                  --
                  vn_memcalcfci_id := pk_csf_fci.fkg_memcalcfci_id ( en_item_id       => rec2.item_id_ins
                                                                   , en_infitemfci_id => rec.id
                                                                   );
                  --
                  if nvl(vn_memcalcfci_id,0) = 0 then
                     --
                     pk_csf_fci.pkb_gerar_memcalcfci ( en_memcalcfci_id     => vn_memcalcfci_id
                                                     , en_item_id           => rec2.item_id_ins
                                                     , en_infitemfci_id     => rec.id
                                                     , en_dm_tipo_item      => 0 -- Entrada
                                                     , en_aberturafciarq_id => rec.aberturafciarq_id
                                                     );
                     --
                  end if;
                  --
               end;
               --
               vn_fase := 6;
               -- Buscar os valores dos itens
               pkb_buscar_vlr_nf ( en_memcalcfci_id => vn_memcalcfci_id
                                 , en_item_id       => rec2.item_id_ins
                                 , en_dm_ind_oper   => 0 -- Entrada
                                 , en_dm_ind_emit   => 0 -- Emissão Própria (Importação Direta)
                                 , en_tipo_data     => -2 -- Pesquisa pelo penultimo mes da geração
                                 );
               --
               vn_fase := 7;
               --
               declare
                 --
                 vn_qtde_dev number := null;
                 --
               begin
                  --
                  vn_fase := 8;
                  -- Verificar se a quantidade comprada foi suficiente
                  vn_qtde_compr := pk_csf_fci.fkg_qtde_item_recup ( en_memcalcfci_id => vn_memcalcfci_id
                                                                  , en_dm_tipo_nf    => 0  -- Entrada
                                                                  );
                  --
                  vn_fase := 8.1;
                  -- Recuperar a quantidade de NF de devolução
                  vn_qtde_dev := pk_csf_fci.fkg_qtde_item_recup ( en_memcalcfci_id => vn_memcalcfci_id );
                  --
                  vn_qtde_compr := nvl(vn_qtde_compr,0) - nvl(vn_qtde_dev,0);
                  --
               end;
               --
               vn_fase := 9;
               --
               vn_qtde_item_old := 0;
               vn_med_pond_item_old := 0;
                  --
               if nvl(rec2.qtd_comp,0) > nvl(vn_qtde_compr,0)
                  and pk_csf_fci.fkg_verif_ult_insumo( en_item_id => rec2.item_id_ins ) = 1
                  then
                  --
                  vn_fase := 10;
                  -- Não houve quantidade suficiente de compra de fora do estado,
                  -- Verificar as rotas alternativas de consulta, e memórizar na MEM_CALC_IIFCI.
                  pkb_gerar_calc_anter( en_item_id       => rec2.item_id_ins
                                      , en_dm_ind_oper   => 0               -- Recuperar calc anteiores de Entrada
                                      , sn_memcalcfci_id => vn_memcalcfci_id_old
                                      , en_infitemfci_id => rec.id
                                      , sn_med_pond_item => vn_med_pond_item_old
                                      );
                  --
                  --if nvl(vn_med_pond_item_old,0) > 0 then
                     --
                  --   vn_qtde_item_old := 1;
                     --
                 -- end if;
                  --
               end if;
               --
               -- Finalizar o Item INSUMO inserindo a media ponderada do INSUMO na tebela de MEM_CALC_FCI
               /*
               if ( nvl(rec2.qtd_comp,0) <= pk_csf_fci.fkg_qtde_item_recup ( en_memcalcfci_id => vn_memcalcfci_id, en_dm_tipo_nf => 0 )
                or nvl(pk_csf_fci.fkg_verif_memcalciifci_id ( rec.id, vn_memcalcfci_id_old),0) > 0 )
                and pk_csf_fci.fkg_verif_ult_insumo( en_item_id => rec2.item_id_ins ) = 1 then -- por em quanto será somado apenas os itens de insumo de ultimo
                  --                                                                              nivel da tabela ITEM_INSUMO
               */
               --
               vn_fase := 11;
               --
                  begin
                     --
                     vn_vl_item_tot := 0;
                     --vn_qtde_item   := 0;
                     --
                     select nvl(sum(nvl(mi.vl_item_tot,0)),0)
                          , nvl(sum(nvl(inf.qtde_comerc,0)),0)
                       into vn_vl_item_tot
                          , vn_qtde_item
                       from mcfci_itemnf mi
                          , item_nota_fiscal inf
                      where memcalcfci_id = vn_memcalcfci_id
                        and inf.id        = mi.itemnotafiscal_id;
                      --
                  exception
                     when no_data_found then
                        vn_vl_item_tot := 0;
                        vn_qtde_item   := 0;
                  end;
                  --
                  vn_fase := 12;
                  --
                  /*
                  if vn_qtde_item = 0 then
                     --
                     update mem_calc_fci
                        set vl_med_pond_item = ( nvl(vn_vl_item_tot,0) / 1 )
                          , qtde_item        = nvl(vn_qtde_item,0)
                      where id               = vn_memcalcfci_id;
                     --
                  else
                     --
                     update mem_calc_fci
                        set vl_med_pond_item = ( nvl(vn_vl_item_tot,0) / nvl(vn_qtde_item,0) )
                          , qtde_item        = nvl(vn_qtde_item,0)
                      where id               = vn_memcalcfci_id;
                  end if;
                  */
                  --
                  if vn_qtde_item = 0 then
                     --
                     update mem_calc_fci
                        set vl_med_pond_item = ( nvl(vn_vl_item_tot,0) / 1 )
                          , qtde_item        = nvl(rec2.qtd_comp,0)
                      where id               = vn_memcalcfci_id;
                     --
                  else
                     --
                     update mem_calc_fci
                        set vl_med_pond_item = ( nvl(vn_vl_item_tot,0) / nvl(vn_qtde_item,0) )
                          , qtde_item        = nvl(rec2.qtd_comp,0)
                      where id               = vn_memcalcfci_id;
                  end if;
                  --
                  vn_fase := 13;
                  --
                  commit;
                  --
                if nvl(rec2.qtd_comp,0) > pk_csf_fci.fkg_qtde_item_recup ( en_memcalcfci_id => vn_memcalcfci_id, en_dm_tipo_nf => 0 )
                  and nvl(pk_csf_fci.fkg_verif_memcalciifci_id ( rec.id, vn_memcalcfci_id_old),0) = 0
                 and pk_csf_fci.fkg_verif_ult_insumo( en_item_id => rec2.item_id_ins ) = 1 then
                  --
                  vn_fase := 14;
                  vn_item_id := rec2.item_id_ins;
                  RAISE ve_qtd_ins_insufic;
                  --
               end if;
               --
            end loop;
            --
         end if;
         --
      end loop;
      --
   end if;
   --
exception
   when ve_qtd_ins_insufic then
      --
      update inf_item_fci
         set dm_situacao = 4 -- Erro de Calculo
       where id = gn_infitemfci_id;
      --
      commit;
      --
      pk_csf_api_fci.gv_resumo := 'Quantidade Insuficiente de Insumo para geração dos dados do FCI para o Item: '|| pk_csf.fkg_Item_cod (vn_item_id);
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_fci.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_fci.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_fci.gv_resumo
                                         , en_tipo_log        => pk_csf_api_fci.ERRO_DE_SISTEMA
                                         , en_referencia_id   => pk_csf_api_fci.gn_referencia_id
                                         , ev_obj_referencia  => pk_csf_api_fci.gv_obj_referencia
                                         );
      exception
         when others then
            null;
      end;
      --
   when others then
      --
      update inf_item_fci
         set dm_situacao = 4 -- Erro de Calculo
       where id = gn_infitemfci_id;
      --
      commit;
      --
      pk_csf_api_fci.gv_resumo := 'Erro na pk_csf_gera_dados_fci.pkb_recup_vlr_entrada fase:'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_fci.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_fci.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_fci.gv_resumo
                                         , en_tipo_log        => pk_csf_api_fci.ERRO_DE_SISTEMA
                                         , en_referencia_id   => pk_csf_api_fci.gn_referencia_id
                                         , ev_obj_referencia  => pk_csf_api_fci.gv_obj_referencia
                                         );
      exception
         when others then
            null;
      end;
      --
end pkb_recup_vlr_entrada;

-------------------------------------------------------------------------------------------------------
-- Procedimento de criação do Registro ABERTURA_FCI_ARQ
procedure pkb_gera_aberturafciarq ( en_aberturafci_id  in abertura_fci.id%type
                                  )
is
   --
   vn_fase                        number;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_aberturafci_id,0) > 0 then
      --
      pk_csf_api_fci.gt_abertura_fci_arq := null;
      --
      select aberturafciarq_seq.nextval
        into pk_csf_api_fci.gt_abertura_fci_arq.id
        from dual;
      --
      pk_csf_api_fci.gt_abertura_fci_arq.aberturafci_id := en_aberturafci_id;
      pk_csf_api_fci.gt_abertura_fci_arq.dm_situacao := 0; -- Aberto
      pk_csf_api_fci.gt_abertura_fci_arq.nro_sequencia := pk_csf_fci.fkg_ret_sequencia( en_aberturafci_id => pk_csf_api_fci.gt_abertura_fci.id); 
      --
      insert into abertura_fci_arq ( id
                                   , aberturafci_id
                                   , nro_sequencia
                                   , nro_prot
                                   , dm_situacao )
                             values( pk_csf_api_fci.gt_abertura_fci_arq.id
                                   , pk_csf_api_fci.gt_abertura_fci_arq.aberturafci_id
                                   , pk_csf_api_fci.gt_abertura_fci_arq.nro_sequencia
                                   , null
                                   , pk_csf_api_fci.gt_abertura_fci_arq.dm_situacao
                                   );
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_fci.gv_resumo := 'Erro na pk_csf_gera_dados_fci.pkb_gera_aberturaficarq fase:'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_fci.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_fci.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_fci.gv_resumo
                                         , en_tipo_log        => pk_csf_api_fci.ERRO_DE_SISTEMA
                                         , en_referencia_id   => pk_csf_api_fci.gn_referencia_id
                                         , ev_obj_referencia  => pk_csf_api_fci.gv_obj_referencia
                                         );
      exception
         when others then
            null;
      end;
      --
end pkb_gera_aberturafciarq;

-------------------------------------------------------------------------------------------------------
-- Procedimento de recuperação do registros da ABERTURA_FCI_ARQ
procedure pkb_rec_aberturafciarq ( en_aberturafciarq_id in abertura_fci_arq.id%type
                                 )
is
   --
begin
   --
   if nvl(en_aberturafciarq_id,0) > 0 then
      --
      select *
        into pk_csf_api_fci.gt_abertura_fci_arq
        from abertura_fci_arq
       where id = en_aberturafciarq_id;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_fci.gv_resumo := 'Erro na pk_csf_gera_dados_fci.pkb_rec_aberturafciarq fase:'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_fci.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_fci.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_fci.gv_resumo
                                         , en_tipo_log        => pk_csf_api_fci.ERRO_DE_SISTEMA
                                         , en_referencia_id   => pk_csf_api_fci.gn_referencia_id
                                         , ev_obj_referencia  => pk_csf_api_fci.gv_obj_referencia
                                         );
      exception
         when others then
            null;
      end;
      --
end pkb_rec_aberturafciarq;

-------------------------------------------------------------------------------------------------------
-- Procedimento que Buscar os itens de NF de saida e verifica se existe na tabela de INF_ITEM_FCI
procedure pkb_verif_itens_nfs ( en_empresa_id  in empresa.id%type
                              )
is
   --
   vn_fase                   number := null;
   vt_row_inf_item_fci       inf_item_fci%rowtype;
   vn_item_infitemfci        inf_item_fci.id%type;
   vn_qtde_item_abertfciarq  number := null;
   --
   cursor c_dados is
    select it.id
      from item    it
         , tipo_item ti
         , empresa   e
         , item_insumo ii
         , item it2
     where e.id            = en_empresa_id
       and it.empresa_id   = e.id
       and it.tipoitem_id  = ti.id
       and ti.cd           in ('03','04')
       and it.dm_orig_merc in (3, 5, 8)
       and it.id = ii.item_id
       and ii.item_id_ins =  it2.id
       and it2.dm_orig_merc in (1, 2, 3, 6, 7, 8)
   union
    select it.id
      from item    it
         , tipo_item ti
         , empresa e
         , item_insumo ii
         , item    it2
     where e.id            = en_empresa_id
       and it.empresa_id   = decode(nvl(e.ar_empresa_id,0),0,e.id,e.ar_empresa_id)
       and it.tipoitem_id  = ti.id
       and ti.cd           in ('03','04')
       and it.dm_orig_merc in (3, 5, 8) 
       and it.id = ii.item_id     
       and ii.item_id_ins = it2.id
       and it2.dm_orig_merc in (1, 2, 3, 6, 7, 8);
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_empresa_id,0) > 0 then
      --
      vn_fase := 2;
      --
      for rec in c_dados loop
       exit when c_dados%notfound or (c_dados%notfound) is null;
         --
         vn_fase := 3;
         --
         vt_row_inf_item_fci := null;
         --
         begin
            --
            select ii.id
              into vn_item_infitemfci
              from inf_item_fci     ii
                 , abertura_fci_arq aa
             where item_id = rec.id
               and ii.aberturafciarq_id = aa.id
               and aa.aberturafci_id    = nvl(pk_csf_api_fci.gt_abertura_fci.id,0);
            --
         exception
            when no_data_found then
               vn_item_infitemfci := null;
         end;
         --
         vn_fase := 3.1;
         --
         if nvl(vn_item_infitemfci,0) = 0 then
            --
            vn_fase := 4;
            --
            select infitemfci_seq.nextval
              into vt_row_inf_item_fci.id
              from dual;
            --
            vt_row_inf_item_fci.aberturafciarq_id := pk_csf_api_fci.gt_abertura_fci_arq.id;
            vt_row_inf_item_fci.vl_saida          := 0;
            vt_row_inf_item_fci.vl_entr_tot       := null;
            vt_row_inf_item_fci.item_id           := rec.id;
            vt_row_inf_item_fci.dm_situacao       := 0; -- Em aberto
            --
            vn_fase := 4.1;
            --
            insert into inf_item_fci ( id
                                     , aberturafciarq_id
                                     , vl_saida
                                     , vl_entr_tot
                                     , coef_import
                                     , item_id
                                     , dm_situacao )
                               values( vt_row_inf_item_fci.id
                                     , vt_row_inf_item_fci.aberturafciarq_id
                                     , vt_row_inf_item_fci.vl_saida
                                     , vt_row_inf_item_fci.vl_entr_tot
                                     , vt_row_inf_item_fci.coef_import
                                     , vt_row_inf_item_fci.item_id
                                     , vt_row_inf_item_fci.dm_situacao );
            --
            commit;
            --
            vn_fase := 4.2;
            --
            vn_qtde_item_abertfciarq := pk_csf_fci.fkg_qtde_item_abertfciarq ( en_aberturafciarq_id => pk_csf_api_fci.gt_abertura_fci_arq.id );
            --
            if nvl(vn_qtde_item_abertfciarq,0) >= nvl(pk_csf_api_fci.gt_param_abert_fci.qtd_linhas_estr,0) then
               --
               pkb_gera_aberturafciarq ( en_aberturafci_id => pk_csf_api_fci.gt_abertura_fci.id );
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
      pk_csf_api_fci.gv_resumo := 'Erro na pk_csf_gera_dados_fci.pkb_verif_itens_nfs fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_fci.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_fci.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_fci.gv_resumo
                                         , en_tipo_log        => pk_csf_api_fci.ERRO_DE_SISTEMA
                                         , en_referencia_id   => pk_csf_api_fci.gn_referencia_id
                                         , ev_obj_referencia  => pk_csf_api_fci.gv_obj_referencia
                                         );
      exception
         when others then
            null;
      end;
      --
end pkb_verif_itens_nfs;

-------------------------------------------------------------------------------------------------------
-- Procedimento de geração de Abertura_Fci_Arq  1.1- PARTE
procedure pkb_gerar_abertfciarq
is
   --
   vn_fase                      number := null;
   vn_qtde_itens_abert          number := null;
   vn_aberturafciarq_id         number := null;
   vn_teste                     number := null;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(pk_csf_api_fci.gt_abertura_fci.id,0) > 0 then
      --
      vn_fase := 2;
      -- Verificar se ja existe alguma ABERTURA_FCI_ARQ
      if pk_csf_fci.fkg_exist_aberturafciarq ( en_aberturafci_id => pk_csf_api_fci.gt_abertura_fci.id ) > 0 then
         --
         vn_fase  := 3;
         --
         begin -- pegar o id da abertura fci arq
            -- verificar se a quantidade é maior ou igual ao parametrizado caso for criar uma nova abertura_arq_fci e pegar o id
            select af.id
                 , count(ii.id)
              into vn_aberturafciarq_id
                 , vn_qtde_itens_abert
              from abertura_fci_arq af
                 , inf_item_fci ii
             where ii.aberturafciarq_id (+) = af.id -- Pode ser que não exista nenhum item para abertura ainda.
               and af.dm_situacao = 0
               and af.id = ( select max(id)
                               from abertura_fci_arq afa
                              where afa.aberturafci_id = nvl(pk_csf_api_fci.gt_abertura_fci.id,0))
             group by af.id;
            --
         exception
            when no_data_found then
               vn_qtde_itens_abert  := 0;
               vn_aberturafciarq_id := 0;
            when others then
               raise_application_error(-20101,'Problemas ao buscar qtde de itens por abertura. Erro na pk_csf_gera_dados_fci.pkb_gerar_abertfciarq:' || sqlerrm);
         end;
         --
         vn_fase := 3.1;
         --
         if nvl(pk_csf_api_fci.gt_param_abert_fci.qtd_linhas_estr,0) <= vn_qtde_itens_abert then
            --
            vn_fase := 3.2;
            --
            pkb_gera_aberturafciarq ( en_aberturafci_id => pk_csf_api_fci.gt_abertura_fci.id );
            --
         else
            --
            pkb_rec_aberturafciarq ( en_aberturafciarq_id => vn_aberturafciarq_id );
            --
         end if;
         --
      else
         -- caso não exista nenhum ainda ja criar uma nova abertura_arq_fci e pegar o id
         vn_fase := 4;
         --
         pkb_gera_aberturafciarq ( en_aberturafci_id => pk_csf_api_fci.gt_abertura_fci.id );
         --
         vn_fase := 4.1;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_fci.gv_resumo := 'Erro na pk_csf_gera_dados_fci.pkb_gerar_abertfciarq fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_fci.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_fci.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_fci.gv_resumo
                                         , en_tipo_log        => pk_csf_api_fci.ERRO_DE_SISTEMA
                                         , en_referencia_id   => pk_csf_api_fci.gn_referencia_id
                                         , ev_obj_referencia  => pk_csf_api_fci.gv_obj_referencia
                                         );
      exception
         when others then
            null;
      end;
      --
end pkb_gerar_abertfciarq;
-------------------------------------------------------------------------------------------------------
-- Procedimento que desfaz situação do registro do FCI
procedure pkb_desprocessa_dados_arq ( en_aberturafciarq_id in abertura_fci_arq.id%type )
is
   --
   vn_fase                 number := null;
   --
   cursor c_arq is
   select aa.*
     from abertura_fci_arq aa
    where aa.id = en_aberturafciarq_id;
   --
   cursor c_inf (en_aberturafciarq_id in abertura_fci_arq.id%type) is
   select ii.id infitemfci_id
        , ii.dm_situacao
     from inf_item_fci ii
    where ii.aberturafciarq_id = en_aberturafciarq_id;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_aberturafciarq_id,0) > 0 then
      --
      vn_fase := 2;
      --
      for rec in c_arq loop
       exit when c_arq%notfound or (c_arq%notfound) is null;
         --
         vn_fase := 3;
         --
         delete from log_generico
          where referencia_id  = rec.id
            and obj_referencia = 'ABERTURA_FCI_ARQ';
         --
         vn_fase := 4;
         --
         if nvl(rec.dm_situacao,-1) = 0 then -- Aberto
            --
            vn_fase := 4.1;
            --
            delete from estr_arq_fci
             where aberturafciarq_id = rec.id;
            --
            vn_fase := 4.2;
            --
            delete from inf_item_fci
             where aberturafciarq_id = rec.id;
            --
            vn_fase := 4.3;
            --
            delete from abertura_fci_arq
             where id = rec.id;
            --
         elsif nvl(rec.dm_situacao,0) in (1,2) then -- Validado / Erro de validação
            --
            vn_fase := 4.4;
            --
            update abertura_fci_arq
               set dm_situacao = 0
             where id = rec.id;
            --
            vn_fase := 4.5;
            --
            update inf_item_fci
               set dm_situacao = 0 -- Aberto
             where aberturafciarq_id = rec.id;
            --
         elsif nvl(rec.dm_situacao,0) in (3,4) then -- Calculado / Erro de Calculo
           --
            vn_fase := 4.6;
            --
            update abertura_fci_arq
               set dm_situacao = 1 -- Validado
             where id = rec.id;
            --
            vn_fase := 4.7;
            --
            update inf_item_fci
               set dm_situacao = 1 -- Validado
                 , vl_saida  = 0
                 , vl_entr_tot = 0
                 , coef_import = 0
             where aberturafciarq_id = rec.id;
            --
            vn_fase := 4.8;
            --
            delete mcfci_itemnf mi
             where memcalcfci_id in ( select mc.id
                                         from mem_calc_fci mc
                                            , inf_item_fci ii
                                        where ii.aberturafciarq_id = rec.id
                                          and mc.infitemfci_id = ii.id );
            --
            vn_fase := 4.9;
            --
            delete mem_calc_iifci mc
             where infitemfci_id in ( select ii.id
                                       from inf_item_fci ii
                                      where ii.aberturafciarq_id = rec.id );
            --
            vn_fase := 4.10;
            --
            delete from mem_calc_fci
             where infitemfci_id in ( select id
                                       from inf_item_fci
                                      where aberturafciarq_id = rec.id );
            --
         elsif nvl(rec.dm_situacao,0) in (5) then -- Aguardando envio
               --
               vn_fase := 4.11;
               --
               if trim(rec.nro_prot) is null then
                  --
                  -- Caso abertura_fci_arq.dm_situacao = 5 e inf_item_fci.dm_situacao = 8, excluir retorno_fci where infitemfci_id = id que está como 8
                  -- e voltar para 3 o inf_item_fci
                  --
                  vn_fase := 4.12;
                  --
                  for r_inf in c_inf (en_aberturafciarq_id => rec.id)
                  loop
                     --
                     exit when c_inf%notfound or (c_inf%notfound) is null;
                     --
                     vn_fase := 4.13;
                     --
                     if r_inf.dm_situacao = 8 then -- Finalizado
                        --
                        vn_fase := 4.14;
                        --
                        delete from retorno_fci rf
                         where rf.infitemfci_id = r_inf.infitemfci_id;
                        --
                        vn_fase := 4.15;
                        --
                        update inf_item_fci ii
                           set ii.dm_situacao = 3 -- Calculado
                         where ii.aberturafciarq_id = r_inf.infitemfci_id;
                        --
                     end if;
                     --
                  end loop;
                  --
                  vn_fase := 4.16;
                  --
                  update abertura_fci_arq
                     set dm_situacao = 3 -- Calculado
                   where id = rec.id;
                  --
                  vn_fase := 4.17;
                  --
                  update inf_item_fci
                     set dm_situacao = 3 -- Calculado
                   where aberturafciarq_id = rec.id;
                  --
                  vn_fase := 4.18;
                  --
                  delete from estr_arq_fci
                   where aberturafciarq_id = rec.id;
                  --
               end if;
               --
         elsif nvl(rec.dm_situacao,0) in (6,7) -- Enviado / Erro na Geração do Arquivo
          and trim(rec.nro_prot) is null then
            -- Thiago alterou aqui, atv 70069
            vn_fase := 4.19;
            --
            -- Caso abertura_fci_arq.dm_situacao in (6,7) e inf_item_fci.dm_situacao = 8, excluir retorno_fci where infitemfci_id = id que está como 8
            -- e voltar para 3 o inf_item_fci, inclusão a partir da atividade 70069 que ao desfazer a geração de algum registro que já tinha sido gerado o arquivo
            -- não estava sendo excluído a RETORNO_FCI, gerando duplicidades ao gerar novamente o arquivo.
            for r_inf in c_inf (en_aberturafciarq_id => rec.id)
               loop
                  --
                  exit when c_inf%notfound or (c_inf%notfound) is null;
                  --
                  vn_fase := 4.20;
                  --
                  if r_inf.dm_situacao = 8 then -- Finalizado
                     --
                     vn_fase := 4.21;
                     --
                     delete from retorno_fci rf
                      where rf.infitemfci_id = r_inf.infitemfci_id;
                     --
                  end if;
                  --
            end loop;
            --
            vn_fase := 4.22;
            --
            update abertura_fci_arq
               set dm_situacao = 3 -- Calculado
             where id = rec.id;
            --
            vn_fase := 4.23;
            --
            update inf_item_fci
               set dm_situacao = 3 -- Calculado
             where aberturafciarq_id = rec.id;
            --
            vn_fase := 4.24;
            --
            delete from estr_arq_fci
             where aberturafciarq_id = rec.id;
            --
         end if;
         -- Thiago finalizou aqui, atv 70069
         commit;
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_fci.gv_resumo := 'Erro na pk_csf_gera_dados_fci.pkb_desfazer_fci fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_fci.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_fci.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_fci.gv_resumo
                                         , en_tipo_log        => pk_csf_api_fci.ERRO_DE_SISTEMA
                                         , en_referencia_id   => pk_csf_api_fci.gn_referencia_id
                                         , ev_obj_referencia  => pk_csf_api_fci.gv_obj_referencia
                                         );
      exception
         when others then
            null;
      end;
      --
end pkb_desprocessa_dados_arq;

-------------------------------------------------------------------------------------------------------
-- Procedimento que desfaz situação do registro do FCI
procedure pkb_desprocessa_dados ( en_aberturafci_id in abertura_fci.id%type 
                                )
is
   --
   vn_fase                      number;
   --
   cursor c_dados is
   select afa.*
     from abertura_fci_arq afa
    where afa.aberturafci_id = en_aberturafci_id;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_aberturafci_id,0) > 0 then
      --
      vn_fase := 2;
      --
      for rec in c_dados loop
       exit when c_dados%notfound or (c_dados%notfound) is null;
         --
         vn_fase := 3;
         --
         pkb_desprocessa_dados_arq ( en_aberturafciarq_id => rec.id );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_fci.gv_resumo := 'Erro na pk_csf_gera_dados_fci.pkb_desprocessa_dados fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_fci.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_fci.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_fci.gv_resumo
                                         , en_tipo_log        => pk_csf_api_fci.ERRO_DE_SISTEMA
                                         , en_referencia_id   => pk_csf_api_fci.gn_referencia_id
                                         , ev_obj_referencia  => pk_csf_api_fci.gv_obj_referencia
                                         );
      exception
         when others then
            null;
      end;
      --
end pkb_desprocessa_dados;

-------------------------------------------------------------------------------------------------------
-- Procedimento de gerar e calcular os dados da Ficha de Conteudo de Importação     1- PARTE
procedure pkb_gera_dados ( en_aberturafci_id in abertura_fci.id%type
                         )
is
   --
   vn_fase             number := null;
   vn_loggenerico_id  log_generico.id%type;
   --
   cursor c_dados is
   select *
     from abertura_fci
    where id = en_aberturafci_id;
   --
begin
   --
   vn_fase := 1;
   --
   pk_csf_api_fci.pkb_inicia_param ( en_aberturafci_id => en_aberturafci_id );
   --
   vn_fase := 2;
   --
   if nvl(en_aberturafci_id,0) > 0 then
      --
      vn_fase := 2.1;
      --
      open c_dados;
      fetch c_dados into pk_csf_api_fci.gt_abertura_fci;
      close c_dados;
      --
      vn_fase := 3;
      --
      pk_csf_api_fci.gv_mensagem_log := 'Geração dos dados da Ficha de Conteudo de Importação do periodo de: '|| to_char(pk_csf_api_fci.gt_abertura_fci.dt_ini,'dd/mm/rrrr')||
                                        ' Até '||to_char(pk_csf_api_fci.gt_abertura_fci.dt_fin,'dd/mm/rrrr')||'.';
                                        
      pk_csf_api_fci.gn_referencia_id  := pk_csf_api_fci.gt_abertura_fci.id;
      pk_csf_api_fci.gv_obj_referencia := 'ABERTURA_FCI';
      -- 
      vn_fase := 3.1;
      --
      delete from log_generico
       where obj_referencia = pk_csf_api_fci.gv_obj_referencia
         and referencia_id  = pk_csf_api_fci.gn_referencia_id;
      --
      commit;
      -- 1 Parte - Trabalhar a ABERTURA_FCI_ARQ
      -- Verificar se ja existe alguma ABERTURA_FCI_ARQ.
      pkb_gerar_abertfciarq;
      --
      vn_fase := 3.2;
      --
      -- Verificar itens de Notas Fiscais de saida e Inserir na Abertura_FCI
      pkb_verif_itens_nfs( en_empresa_id => pk_csf_api_fci.gt_abertura_fci.empresa_id );
      --
      vn_fase := 3.3;
      --
      pk_csf_api_fci.gv_resumo := 'Finalizado o Processo de geração, Existem '|| pk_csf_fci.fkg_qtde_item_abertfci ( en_aberturafci_id => pk_csf_api_fci.gt_abertura_fci.id )
                               || ' itens para ser validado para continuar o processo de geração do FCI.';
      --
      pk_csf_api_fci.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                      , ev_mensagem        => pk_csf_api_fci.gv_mensagem_log
                                      , ev_resumo          => pk_csf_api_fci.gv_resumo
                                      , en_tipo_log        => pk_csf_api_fci.INFORMACAO
                                      , en_referencia_id   => pk_csf_api_fci.gn_referencia_id
                                      , ev_obj_referencia  => pk_csf_api_fci.gv_obj_referencia
                                      );
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_fci.gv_resumo := 'Erro na pk_csf_gera_dados_fci.pkb_gera_dados fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_fci.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_fci.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_fci.gv_resumo
                                         , en_tipo_log        => pk_csf_api_fci.ERRO_DE_SISTEMA
                                         , en_referencia_id   => pk_csf_api_fci.gn_referencia_id
                                         , ev_obj_referencia  => pk_csf_api_fci.gv_obj_referencia
                                         );
      exception
         when others then
            null;
      end;
      --
end pkb_gera_dados;
--
-------------------------------------------------------------------------------------------------------
-- Procedimento de Calculo do Numero do Ficha Conteudo de Importação.
procedure pkb_calcular_arq ( en_aberturafciarq_id in abertura_fci_arq.id%type )
is
   --
   vn_fase                    number := null;
   vv_dominio_descr           dominio.dominio%type := null;
   vt_inf_item_fci            inf_item_fci%rowtype;
   vn_qtd_comp                number := null;
   vn_reg_aguardenvio         number := null;
   vn_sum_med_ponderada       number := null;
   vn_reg_qtd                 number := null;
   vn_qtd_reg_sit             number := null;
   --
   cursor c_dados is
   select af.*
     from abertura_fci af
        , abertura_fci_arq afa
    where afa.id      = en_aberturafciarq_id
      and afa.aberturafci_id = af.id; -- Validado
   --
   cursor c_inf is
   select ii.*
     from inf_item_fci ii
    where ii.aberturafciarq_id = en_aberturafciarq_id;
   --
   ---------------------------------------------------------------------------------
   --   Query que ja busca a soma dos itens que foram gerados tanto na MEM_CALC_FCI
   --   quanto na MEM_CALC_IIFCI, para Inserir na INF_ITEM_FCI
   cursor c_mem ( en_infitemfci_id inf_item_fci.id%type ) is
   select nvl(sum(nvl(vl_med_pond_item,0)),0) vl_med_pond_item
        , nvl(sum(nvl(qtde_item_tot,0)),0)    qtde_item_tot
        , dm_tipo_item
        , item_id
    from( select nvl(sum(nvl(mc.vl_med_pond_item,0)),0)  vl_med_pond_item
               , nvl(sum(nvl(mc.qtde_item,0)),0)         qtde_item_tot
               , mc.dm_tipo_item          dm_tipo_item
               , mc.item_id               item_id
            from mem_calc_fci mc
           where mc.infitemfci_id = en_infitemfci_id
            -- 
           group by mc.dm_tipo_item
               , mc.item_id
          union
          select nvl(sum(nvl(mci.vl_med_pond_item,0)),0) vl_med_pond_item
               , 1 qtde_item_tot
               , mc.dm_tipo_item dm_tipo_item
               , mc.item_id
            from mem_calc_fci mc
               , mem_calc_iifci mci
           where mc.infitemfci_id  = en_infitemfci_id
             and mci.memcalcfci_id = mc.id
             --
           group by mc.dm_tipo_item
               , mc.item_id )
           group by dm_tipo_item
                  , item_id;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_aberturafciarq_id,0) > 0 then
      --
      vn_fase := 2;
      --
      open c_dados;
      fetch c_dados into pk_csf_api_fci.gt_abertura_fci;
      close c_dados;
      --
      vn_fase := 2.1;
      --
      pkb_rec_aberturafciarq ( en_aberturafciarq_id => en_aberturafciarq_id );
      --
      if nvl(pk_csf_api_fci.gt_abertura_fci_arq.dm_situacao,0) = 1 then -- Validado
         --
         vn_fase := 3;
         --
         begin
            delete log_generico
             where referencia_id  = pk_csf_api_fci.gt_abertura_fci_arq.id
               and obj_referencia = 'ABERTURA_FCI_ARQ';
         exception
            when others then
               raise_application_error(-20101, 'Erro ao excluir log/inconsistência - pk_csf_gera_dados_fci.pkb_calcular_fci: '||sqlerrm);
         end;
         --
         pk_csf_api_fci.gv_mensagem_log := 'Processo de Calculo da Ficha de Conteudo de Importação do periodo de: '|| to_char(pk_csf_api_fci.gt_abertura_fci.dt_ini,'dd/mm/rrrr')||
                                           ' Até '||to_char(pk_csf_api_fci.gt_abertura_fci.dt_fin,'dd/mm/rrrr')||'.';

         pk_csf_api_fci.gn_referencia_id  := pk_csf_api_fci.gt_abertura_fci_arq.id;
         pk_csf_api_fci.gv_obj_referencia := 'ABERTURA_FCI_ARQ';
         --
         vn_fase := 3.1;
         --
         -- Recuperar as informações das Notas Fiscais de entrada e inserir nas tabelas de memoria de calculo
         pkb_recup_vlr_entrada ( en_aberturafciarq_id => pk_csf_api_fci.gt_abertura_fci_arq.id );
         --
         vn_fase := 3.2;
         --
         -- Recuperar as Informações das Notas Fiscais de saida e inserir nas tabelas de memoria de calculo
         pkb_recup_vlr_saida ( en_aberturafciarq_id => pk_csf_api_fci.gt_abertura_fci_arq.id );
         --
         vn_fase := 3.3;
         -- Efetuar o Calculo do Percentual de Importação do FCI
         --
         vt_inf_item_fci := null;
         --
         begin
            --
            vn_fase := 3.4;
            --
            for rec in c_inf loop
             exit when c_inf%notfound or (c_inf%notfound) is null;
               --
               vn_fase := 3.5;
               --
               vn_sum_med_ponderada := null;
               --
               for r_mem in c_mem (rec.id)loop
                exit when c_inf%notfound or (c_inf%notfound) is null;
                  --
                  vn_fase := 3.6;
                  --
                  vn_sum_med_ponderada := nvl(vn_sum_med_ponderada,0) + nvl(r_mem.vl_med_pond_item,0);
                  --
                  vn_fase := 3.7;
                  --
                  if nvl(r_mem.dm_tipo_item,-1) = 0
                   and nvl(r_mem.qtde_item_tot,0) > 0 then -- entrada
                     --
                     vn_fase := 3.8;
                     -- Recuperar a quantidade necessaria para insumo
                     -- do ITEM no caso de ITENS DE INSUMO
                     pk_csf_api_fci.gv_resumo := null;
                     vn_qtd_comp              := null;
                     --
                     begin
                        --
                        select qtd_comp
                          into vn_qtd_comp
                          from item_insumo iin
                         where iin.item_id_ins = r_mem.item_id
                           and iin.item_id     = rec.item_id;
                        --
                     exception
                        when too_many_rows then
                           --
                           pk_csf_api_fci.gv_resumo := 'Problema para recuperar a quantidade que compõe o ITEM INSUMO: '|| pk_csf.fkg_Item_cod ( en_item_id => r_mem.item_id );
                           --
                        when no_data_found then
                           --
                           pk_csf_api_fci.gv_resumo := 'Não foi encontrado a quantidade do ITEM INSUMO: '|| pk_csf.fkg_Item_cod ( en_item_id => r_mem.item_id );
                           --
                        when others then
                           raise;   
                     end;
                     --
                     vn_fase := 3.9;
                     --
                     if trim(pk_csf_api_fci.gv_resumo) is not null then
                        --
                        declare
                          vn_loggenerico_id  log_generico.id%type;
                        begin
                        --
                        pk_csf_api_fci.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                                        , ev_mensagem        => pk_csf_api_fci.gv_mensagem_log
                                                        , ev_resumo          => pk_csf_api_fci.gv_resumo
                                                        , en_tipo_log        => pk_csf_api_fci.INFORMACAO
                                                        , en_referencia_id   => pk_csf_api_fci.gn_referencia_id
                                                        , ev_obj_referencia  => pk_csf_api_fci.gv_obj_referencia
                                                        );
                        exception
                         when others then
                             null;
                        end;
                        --
                     end if;
                     --
                     vn_fase := 3.91;
                     --
                     vt_inf_item_fci.vl_entr_tot :=  nvl(vt_inf_item_fci.vl_entr_tot,0) + ( nvl(r_mem.vl_med_pond_item,0) * nvl(vn_qtd_comp,0) );
                     --
                  elsif nvl(r_mem.dm_tipo_item,-1) = 1 then -- saida
                     --
                     vn_fase := 4;
                     --
                     vt_inf_item_fci.vl_saida := nvl(vt_inf_item_fci.vl_saida,0) + nvl(r_mem.vl_med_pond_item,0);
                     --
                  end if;
                  --
               end loop;
               --
               vn_fase := 4.1;
               --
               if nvl(vt_inf_item_fci.vl_saida,0) = 0 then
                  --
                  vt_inf_item_fci.vl_saida := null;
                  --
                  pk_csf_api_fci.gv_resumo := 'Não foi encontrado VALOR DE SAÍDA para o ITEM: ' || pk_csf.fkg_Item_cod ( en_item_id => rec.item_id ) ||
                                              ', favor verificar se existe notas fiscais para o item ou o valor de "Venda do Item estimado" foi cadastrado.';
                  --
                  declare
                     vn_loggenerico_id  log_generico.id%type;
                  begin
                     pk_csf_api_fci.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                                     , ev_mensagem        => pk_csf_api_fci.gv_mensagem_log
                                                     , ev_resumo          => pk_csf_api_fci.gv_resumo
                                                     , en_tipo_log        => pk_csf_api_fci.INFORMACAO
                                                     , en_referencia_id   => pk_csf_api_fci.gn_referencia_id
                                                     , ev_obj_referencia  => pk_csf_api_fci.gv_obj_referencia
                                                     );
                  exception
                     when others then
                        null;
                  end;
                  --
               else
                  --
                  vn_fase := 4.1;
                  --
                  begin
                     vt_inf_item_fci.coef_import := (nvl(vt_inf_item_fci.vl_entr_tot,0) / nvl(vt_inf_item_fci.vl_saida,1)) * 100;
                  exception
                     when others then
                        raise;
                  end;
                  --
               end if;
               --
               vn_fase := 4.2;
               --
               begin
                  update inf_item_fci
                     set vl_entr_tot = case when nvl(vt_inf_item_fci.vl_entr_tot,0) = 0 then nvl(vn_sum_med_ponderada,0) else nvl(vt_inf_item_fci.vl_entr_tot,0) end
                       , vl_saida    = case when nvl(vt_inf_item_fci.vl_saida,0)    = 0 then nvl(vn_sum_med_ponderada,0) else nvl(vt_inf_item_fci.vl_saida,0)    end
                       , coef_import = nvl(vt_inf_item_fci.coef_import,0)
                  where id = rec.id;
                    
               exception
                 when others then
                    raise;
               end;    
               --
               vt_inf_item_fci := null;
               --
            end loop;
            --
            pk_csf_api_fci.gt_abertura_fci_arq.dm_situacao := 3;
            --
            update abertura_fci_arq
               set dm_situacao = pk_csf_api_fci.gt_abertura_fci_arq.dm_situacao
             where id = pk_csf_api_fci.gt_abertura_fci_arq.id;
            --
            commit;
            --
         end;
         --
         vn_fase := 5;
         --
         if nvl(pk_csf_api_fci.gt_abertura_fci_arq.dm_situacao,0) = 3 then
            --
            -- Verificar se existe a necessidade de geração de um novo numero
            -- de FCI para os Itens da Abertura.
            pkb_verif_nro_fci_ant;
            --
         end if;
         --
         vn_fase := 6;
         --
         -- Total de registros da abertura
         begin
            --
            select count(1)
              into vn_reg_qtd
              from inf_item_fci
             where aberturafciarq_id = pk_csf_api_fci.gt_abertura_fci_arq.id
               and dm_situacao       <> 8;
            --
         exception
           when no_data_found then
             vn_reg_qtd := 0;
         end;
         --
         vn_fase := 6.0; -- Thiago alterou aqui, atv 70069
         --
         -- Total de registros "5 - Aguardando Envio"
         begin
            select count(1)
              into vn_qtd_reg_sit
              from inf_item_fci
             where aberturafciarq_id = pk_csf_api_fci.gt_abertura_fci_arq.id
               and dm_situacao       = 5; -- Aguardando Envio
            --
         exception
           when no_data_found then
             vn_qtd_reg_sit  := 0;
         end;
         --
         if nvl(vn_reg_qtd,0) = nvl(vn_qtd_reg_sit,0) then
            -- -- Thiago alterou aqui, atv 70069
            vn_fase := 6.1;
            --
            if nvl(vn_qtd_reg_sit,0) > 0 then
            --
            pk_csf_api_fci.gt_abertura_fci_arq.dm_situacao := 5;
            --
            update abertura_fci_arq
               set dm_situacao = pk_csf_api_fci.gt_abertura_fci_arq.dm_situacao
             where id = pk_csf_api_fci.gt_abertura_fci_arq.id;
            --
            commit;
            --
         else
            --
               pk_csf_api_fci.gt_abertura_fci_arq.dm_situacao := 8;
               --
               update abertura_fci_arq
                  set dm_situacao = pk_csf_api_fci.gt_abertura_fci_arq.dm_situacao
                where id = pk_csf_api_fci.gt_abertura_fci_arq.id;
               --
               commit;
               --
            end if;
         -- Thiago finalizou aqui, atv 70069
         else
            --
            vn_fase := 6.2;
            --
            -- Total de registros "2 - Erro de Validação"
            begin
               select count(1)
                 into vn_qtd_reg_sit
                 from inf_item_fci
                where aberturafciarq_id = pk_csf_api_fci.gt_abertura_fci_arq.id
                  and dm_situacao       = 2; -- Erro de Validação
               --
            exception
               when no_data_found then
                  vn_qtd_reg_sit  := 0;
            end;
            --
            if nvl(vn_qtd_reg_sit,0) > 0 then
               --
               pk_csf_api_fci.gt_abertura_fci_arq.dm_situacao := 2;
               --
               update abertura_fci_arq
                  set dm_situacao = pk_csf_api_fci.gt_abertura_fci_arq.dm_situacao
                where id = pk_csf_api_fci.gt_abertura_fci_arq.id;
               --
               commit;
               --
            else
               --
               vn_fase := 6.3;
               --
               -- Total de registros "4 - Erro de Cálculo"
               begin
                  select count(1)
                    into vn_qtd_reg_sit
                    from inf_item_fci
                   where aberturafciarq_id = pk_csf_api_fci.gt_abertura_fci_arq.id
                     and dm_situacao       = 4; -- Erro de Cálculo
                  --
               exception
                  when no_data_found then
                     vn_qtd_reg_sit  := 0;
               end;
               --
               if nvl(vn_qtd_reg_sit,0) > 0 then
                  --
                  pk_csf_api_fci.gt_abertura_fci_arq.dm_situacao := 4;
                  --
                  update abertura_fci_arq
                     set dm_situacao = pk_csf_api_fci.gt_abertura_fci_arq.dm_situacao
                   where id = pk_csf_api_fci.gt_abertura_fci_arq.id;
                  --
                  commit;
                  --
               end if;
               --
            end if;
            --
         end if;
         --
      else
         --
         vv_dominio_descr := pk_csf.fkg_dominio ( ev_dominio   => 'ABERTURA_FCI_ARQ.DM_SITUACAO'
                                                , ev_vl        => pk_csf_api_fci.gt_abertura_fci_arq.dm_situacao
                                                );
         --
         pk_csf_api_fci.gv_resumo := 'A situação atual da Abertura '|| vv_dominio_descr || ', não permite que realizar o evento de "Calcular".';
         --
         declare
            vn_loggenerico_id  log_generico.id%type;
         begin
            pk_csf_api_fci.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                            , ev_mensagem        => pk_csf_api_fci.gv_mensagem_log
                                            , ev_resumo          => pk_csf_api_fci.gv_resumo
                                            , en_tipo_log        => pk_csf_api_fci.INFORMACAO
                                            , en_referencia_id   => pk_csf_api_fci.gn_referencia_id
                                            , ev_obj_referencia  => pk_csf_api_fci.gv_obj_referencia
                                            );
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
      begin
         --
         update abertura_fci_arq
            set dm_situacao = 4
          where id = pk_csf_api_fci.gt_abertura_fci_arq.id;
         --
         commit;
         --
      end;
      --
      pk_csf_api_fci.gv_resumo := 'Erro na pk_csf_gera_dados_fci.pkb_calcular_arq fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_fci.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_fci.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_fci.gv_resumo
                                         , en_tipo_log        => pk_csf_api_fci.ERRO_DE_SISTEMA
                                         , en_referencia_id   => pk_csf_api_fci.gn_referencia_id
                                         , ev_obj_referencia  => pk_csf_api_fci.gv_obj_referencia
                                         );
      exception
         when others then
            null;
      end;
      --
end pkb_calcular_arq;
--
-------------------------------------------------------------------------------------------------------
-- Procedimento de Calculo do Numero do Ficha Conteudo de Importação.
procedure pkb_calcular ( en_aberturafci_id in abertura_fci.id%type )
is
   --
   vn_fase             number := null;
   --
   cursor c_abert is
   select af.id
     from abertura_fci_arq af
    where af.aberturafci_id = en_aberturafci_id;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_aberturafci_id,0) > 0 then
      --
      vn_fase := 2;
      --
      for rec in c_abert loop
       exit when c_abert%notfound or (c_abert%notfound) is null;
         --
         vn_fase := 3;
         --
         pkb_calcular_arq ( en_aberturafciarq_id => rec.id );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_fci.gv_resumo := 'Erro na pk_csf_gera_dados_fci.pkb_calcular fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_fci.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_fci.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_fci.gv_resumo
                                         , en_tipo_log        => pk_csf_api_fci.ERRO_DE_SISTEMA
                                         , en_referencia_id   => pk_csf_api_fci.gn_referencia_id
                                         , ev_obj_referencia  => pk_csf_api_fci.gv_obj_referencia
                                         );
      exception
         when others then
            null;
      end;
      --
end pkb_calcular;

end pk_csf_gera_dados_fci;
/
