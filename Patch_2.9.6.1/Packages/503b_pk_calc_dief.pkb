create or replace package body csf_own.pk_calc_dief is

-------------------------------------------------------------------------------------------------------
--| Corpo do pacote de Cálculo de dados da DIEF-Pará
-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
-- Procedimento de geração de Informações de Serviços 
-------------------------------------------------------------------------------------------------------
procedure pkb_gerar_inf_serv
is
   --
   vn_fase number;
   vn_qtde number := 0;
   vn_dm_decl_sem_serv_mes abertura_dief.dm_decl_sem_serv_mes%type;
   --
   cursor c_nf is
   select pii.paramipm_id
        , sum(inf.qtde_comerc) qtde_comerc
        , sum( case
                  when nf.dm_ind_oper = 1 then
                     inf.vl_item_bruto
                  else
                     0
               end ) vl_saida
        , sum( case
                  when nf.dm_ind_oper = 0 then
                     inf.vl_item_bruto
                  else
                     0
               end ) vl_entrada
        , p.cidade_id
     from nota_fiscal nf
        , mod_fiscal mf
        , item_nota_fiscal inf
        , param_ipm_item pii
        , pessoa p
    where nf.empresa_id = pk_csf_dief.gt_abertura_dief.empresa_id
      and nf.dm_arm_nfe_terc = 0
      and ((nf.dm_ind_emit = 1 and to_char(nvl(nf.dt_sai_ent,nf.dt_emiss), 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref||pk_csf_dief.gt_abertura_dief.ano_ref )
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and to_char(nf.dt_emiss, 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref||pk_csf_dief.gt_abertura_dief.ano_ref )
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_char(nf.dt_emiss, 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref||pk_csf_dief.gt_abertura_dief.ano_ref )
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and to_char(nvl(nf.dt_sai_ent,nf.dt_emiss), 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref||pk_csf_dief.gt_abertura_dief.ano_ref ))
      and nf.dm_st_proc = 4
      and nf.modfiscal_id = mf.id
      and mf.cod_mod in ('01', '55', '65', '99')
      and nf.id = inf.notafiscal_id
      and inf.item_id = pii.item_id
      and pii.empresa_id = nf.empresa_id
      and nf.pessoa_id = p.id
    group by  pii.paramipm_id, p.cidade_id;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_nf loop
      exit when c_nf%notfound or (c_nf%notfound) is null;
      --
      vn_fase := 2;
      --
      insert into dief_inf_serv ( id
                                , aberturadief_id
                                , paramipm_id
                                , qtde
                                , vl_saida
                                , vl_entrada
                                , dm_tipo
                                , cidade_id
                                )
                         values
                                ( diefinfserv_seq.nextval
                                , pk_csf_dief.gt_abertura_dief.id
                                , rec.paramipm_id
                                , rec.qtde_comerc
                                , rec.vl_saida
                                , rec.vl_entrada
                                , 1
                                , rec.cidade_id
                                );
      --
      vn_qtde := nvl(vn_qtde,0) + 1;
      --
   end loop;
   --
   if nvl(vn_qtde,0) <= 0
      then
      vn_dm_decl_sem_serv_mes := 1; -- Sim
   else
      vn_dm_decl_sem_serv_mes := 0; -- Não
   end if;
   --
   update abertura_dief set dm_decl_sem_serv_mes = vn_dm_decl_sem_serv_mes
    where id = pk_csf_dief.gt_abertura_dief.id;
   --
   commit;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_calc_dief.pkb_gerar_inf_serv fase(' || vn_fase || '): ' || sqlerrm);
end pkb_gerar_inf_serv;

-------------------------------------------------------------------------------------------------------
-- Procedimento de geração de Informações de ICMS-ST
-------------------------------------------------------------------------------------------------------
procedure pkb_gerar_inf_st
is
   --
   vn_fase number;
   --
   vn_dm_nat_oper   dief_st.dm_nat_oper%type;
   vn_dm_tipo_oper  dief_st.dm_tipo_oper%type;
   vn_estado_id     dief_st.estado_id%type;
   vn_cidade_id     dief_st.cidade_id%type;
   --
   cursor c_nf is
   select nf.dm_ind_oper
        , substr(inf.cfop,1,1) dm_tipo_oper
        , case
             when cs.cod_st in ('10', '30', '70', '90') then
                1
             when cs.cod_st = '60' then
                3
          end dm_nro_oper
        , nf.pessoa_id
        , sum(ii_st.vl_base_calc) vl_contabil
        , sum(ii_st.vl_imp_trib)  vl_icms
     from nota_fiscal nf
        , item_nota_fiscal inf
        , imp_itemnf ii_st
        , tipo_imposto ti_st
        , imp_itemnf ii_icms
        , tipo_imposto ti_icms
        , cod_st cs
    where nf.empresa_id = pk_csf_dief.gt_abertura_dief.empresa_id
      and nf.dm_arm_nfe_terc = 0
      and ((nf.dm_ind_emit = 1 and to_char(nvl(nf.dt_sai_ent,nf.dt_emiss), 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref||pk_csf_dief.gt_abertura_dief.ano_ref )
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and to_char(nf.dt_emiss, 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref||pk_csf_dief.gt_abertura_dief.ano_ref )
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_char(nf.dt_emiss, 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref||pk_csf_dief.gt_abertura_dief.ano_ref )
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and to_char(nvl(nf.dt_sai_ent,nf.dt_emiss), 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref||pk_csf_dief.gt_abertura_dief.ano_ref ))
      and nf.dm_st_proc = 4
      and nvl(nf.pessoa_id,0) > 0
      and nf.id = inf.notafiscal_id
      and substr(inf.cfop,1,1) not in ('3', '7')
      and inf.id = ii_st.itemnf_id
      and ii_st.tipoimp_id = ti_st.id
      and ti_st.cd = 2
      and inf.id = ii_icms.itemnf_id
      and ii_icms.tipoimp_id = ti_icms.id
      and ti_icms.cd = 1
      and ii_icms.codst_id = cs.id
      and cs.cod_st in ('10', '30', '60', '70', '90')
    group by nf.dm_ind_oper
           , substr(inf.cfop,1,1)
           , case
                when cs.cod_st in ('10', '30', '70', '90') then
                   1
                when cs.cod_st = '60' then
                   3
             end
           , nf.pessoa_id;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_nf loop
      exit when c_nf%notfound or (c_nf%notfound) is null;
      --
      vn_fase := 2;
      --
      if rec.dm_ind_oper = 0 then
         vn_dm_nat_oper := 1;
      else
         vn_dm_nat_oper := 2;
      end if;
      --
      vn_fase := 3;
      --
      if rec.dm_tipo_oper in ('1', '5') then
         vn_dm_tipo_oper := 1;
      else
         vn_dm_tipo_oper := 2;
      end if;
      --
      vn_fase := 4;
      --
      begin
         --
         select c.id
              , c.estado_id
           into vn_cidade_id
              , vn_estado_id
           from pessoa p
              , cidade c
          where p.id = rec.pessoa_id
            and p.cidade_id = c.id;
         --
      exception
         when others then
            vn_cidade_id := 0;
            vn_estado_id := 0;
      end;
      --
      vn_fase := 5;
      --
      insert into dief_st ( id
                          , aberturadief_id
                          , dm_nat_oper
                          , dm_tipo_oper
                          , dm_nro_oper
                          , pessoa_id
                          , estado_id
                          , vl_contabil
                          , vl_icms
                          , cidade_id
                          , dm_tipo
                          )
                   values
                          ( diefst_seq.nextval -- id
                          , pk_csf_dief.gt_abertura_dief.id -- aberturadief_id
                          , vn_dm_nat_oper -- dm_nat_oper
                          , vn_dm_tipo_oper -- dm_tipo_oper
                          , rec.dm_nro_oper -- dm_nro_oper
                          , rec.pessoa_id -- pessoa_id
                          , vn_estado_id -- estado_id
                          , rec.vl_contabil -- vl_contabil
                          , rec.vl_icms     -- vl_icms
                          , vn_cidade_id -- cidade_id
                          , 1 -- dm_tipo
                          );
      --
   end loop;
   --
   commit;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_calc_dief.pkb_gerar_inf_st fase(' || vn_fase || '): ' || sqlerrm);
end pkb_gerar_inf_st;

-------------------------------------------------------------------------------------------------------
-- Procedimento de geração de Informações de Cupom Fiscal
-------------------------------------------------------------------------------------------------------
procedure pkb_gerar_inf_ecf
is
   --
   vn_fase number;
   --
   cursor c_ecf is
   select e.ecf_fab
        , r.num_coo_fin
        , r.cro
        , r.crz
        , r.vl_grande_total_fin
     from equip_ecf e
        , reducao_z_ecf r
    where e.empresa_id = pk_csf_dief.gt_abertura_dief.empresa_id
      and e.id = r.equipecf_id
      and to_char(r.dt_doc, 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref||pk_csf_dief.gt_abertura_dief.ano_ref
      and r.dm_st_proc = 1; -- Validado
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_ecf loop
      exit when c_ecf%notfound or (c_ecf%notfound) is null;
      --
      insert into dief_inf_ecf ( id
                               , aberturadief_id
                               , ecf_fab
                               , num_coo_fin
                               , qtde_redz
                               , cro
                               , crz
                               , vl_grande_total_fin
                               , dm_tipo
                               )
                        values
                               ( diefinfecf_seq.nextval -- id
                               , pk_csf_dief.gt_abertura_dief.id -- aberturadief_id
                               , rec.ecf_fab -- ecf_fab
                               , rec.num_coo_fin -- num_coo_fin
                               , 1 -- qtde_redz
                               , rec.cro -- cro
                               , rec.crz -- crz
                               , rec.vl_grande_total_fin -- vl_grande_total_fin
                               , 1 -- dm_tipo
                               );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_calc_dief.pkb_gerar_inf_ecf fase(' || vn_fase || '): ' || sqlerrm);
end pkb_gerar_inf_ecf;

-------------------------------------------------------------------------------------------------------
-- Procedimento de geração de Informações de Estoque
-------------------------------------------------------------------------------------------------------
procedure pkb_gerar_info_est
is
   --
   vn_fase number;
   --
   vd_data_ref                  date := to_date(pk_csf_dief.gt_abertura_dief.dm_mes_ref||pk_csf_dief.gt_abertura_dief.ano_ref, 'mmrrrr');
   vn_vl_venda_ano_ant_ini      number := 0;
   vn_vl_uso_cons_ano_ant_ini   number := 0;
   vn_vl_terc_ano_ant_ini       number := 0;
   vn_vl_total_ano_ant_ini      number := 0;
   vn_vl_venda_ano_ant_fin      number := 0;
   vn_vl_uso_cons_ano_ant_fin   number := 0;
   vn_vl_terc_ano_ant_fin       number := 0;
   vn_vl_total_ano_ant_fin      number := 0;
   vn_vl_venda_ano_atu_ini      number := 0;
   vn_vl_uso_cons_ano_atu_ini   number := 0;
   vn_vl_terc_ano_atu_ini       number := 0;
   vn_vl_total_ano_atu_ini      number := 0;
   vn_vl_venda_ano_atu_fin      number := 0;
   vn_vl_uso_cons_ano_atu_fin   number := 0;
   vn_vl_terc_ano_atu_fin       number := 0;
   vn_vl_total_ano_atu_fin      number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   -- Inicial do ano anterior
   --
   -- Valor de Venda
   begin
      --
      select nvl(sum(inv.vl_item),0)
        into vn_vl_venda_ano_ant_ini
        from inventario inv
           , item i
           , tipo_item ti
       where inv.empresa_id = pk_csf_dief.gt_abertura_dief.empresa_id
         and to_char(inv.dt_inventario, 'mmrrrr') = '01' || to_char(add_months(vd_data_ref,-12), 'rrrr')
         and inv.dm_ind_prop in (0,2)
         and inv.item_id = i.id
         and i.tipoitem_id = ti.id
         and ti.cd <> '07';
      --
   exception
      when others then
         vn_vl_venda_ano_ant_ini := 0;
   end;
   --
   vn_fase := 2;
   --
   -- Valor de Uso e Consumo
   begin
      --
      select nvl(sum(inv.vl_item),0)
        into vn_vl_uso_cons_ano_ant_ini
        from inventario inv
           , item i
           , tipo_item ti
       where inv.empresa_id = pk_csf_dief.gt_abertura_dief.empresa_id
         and to_char(inv.dt_inventario, 'mmrrrr') = '01' || to_char(add_months(vd_data_ref,-12), 'rrrr')
         and inv.dm_ind_prop in (0,2)
         and inv.item_id = i.id
         and i.tipoitem_id = ti.id
         and ti.cd = '07';
      --
   exception
      when others then
         vn_vl_uso_cons_ano_ant_ini := 0;
   end;
   --
   vn_fase := 3;
   --
   -- Valor de Terceiros
   begin
      --
      select nvl(sum(inv.vl_item),0)
        into vn_vl_terc_ano_ant_ini
        from inventario inv
       where inv.empresa_id = pk_csf_dief.gt_abertura_dief.empresa_id
         and to_char(inv.dt_inventario, 'mmrrrr') = '01' || to_char(add_months(vd_data_ref,-12), 'rrrr')
         and inv.dm_ind_prop = 1;
      --
   exception
      when others then
         vn_vl_terc_ano_ant_ini := 0;
   end;
   --
   vn_fase := 4;
   --
   -- Valor Total
   vn_vl_total_ano_ant_ini := nvl(vn_vl_venda_ano_ant_ini,0)+nvl(vn_vl_uso_cons_ano_ant_ini,0)+nvl(vn_vl_terc_ano_ant_ini,0);
   --
   vn_fase := 5;
   --
   insert into dief_info_est ( id
                             , aberturadief_id
                             , dm_tipo_info_est
                             , vl_venda
                             , vl_uso_cons
                             , vl_terceiro
                             , vl_total
                             )
                      values
                             ( diefinfoest_seq.nextval -- id
                             , pk_csf_dief.gt_abertura_dief.id -- aberturadief_id
                             , 1 -- DM_TIPO_INFO_EST
                             , vn_vl_venda_ano_ant_ini -- vl_venda
                             , vn_vl_uso_cons_ano_ant_ini -- vl_uso_cons
                             , vn_vl_terc_ano_ant_ini -- vl_terceiro
                             , vn_vl_total_ano_ant_ini -- vl_total
                             );
   --
   vn_fase := 6;
   --
   -- Final do ano anterior
   --
   -- Valor de Venda
   begin
      --
      select nvl(sum(inv.vl_item),0)
        into vn_vl_venda_ano_ant_fin
        from inventario inv
           , item i
           , tipo_item ti
       where inv.empresa_id = pk_csf_dief.gt_abertura_dief.empresa_id
         and to_char(inv.dt_inventario, 'mmrrrr') = '12' || to_char(add_months(vd_data_ref,-12), 'rrrr')
         and inv.dm_ind_prop in (0,2)
         and inv.item_id = i.id
         and i.tipoitem_id = ti.id
         and ti.cd <> '07';
      --
   exception
      when others then
         vn_vl_venda_ano_ant_fin := 0;
   end;
   --
   vn_fase := 7;
   --
   -- Valor de Uso e Consumo
   begin
      --
      select nvl(sum(inv.vl_item),0)
        into vn_vl_uso_cons_ano_ant_fin
        from inventario inv
           , item i
           , tipo_item ti
       where inv.empresa_id = pk_csf_dief.gt_abertura_dief.empresa_id
         and to_char(inv.dt_inventario, 'mmrrrr') = '12' || to_char(add_months(vd_data_ref,-12), 'rrrr')
         and inv.dm_ind_prop in (0,2)
         and inv.item_id = i.id
         and i.tipoitem_id = ti.id
         and ti.cd = '07';
      --
   exception
      when others then
         vn_vl_uso_cons_ano_ant_fin := 0;
   end;
   --
   vn_fase := 8;
   --
   -- Valor de Terceiros
   begin
      --
      select nvl(sum(inv.vl_item),0)
        into vn_vl_terc_ano_ant_fin
        from inventario inv
       where inv.empresa_id = pk_csf_dief.gt_abertura_dief.empresa_id
         and to_char(inv.dt_inventario, 'mmrrrr') = '12' || to_char(add_months(vd_data_ref,-12), 'rrrr')
         and inv.dm_ind_prop = 1;
      --
   exception
      when others then
         vn_vl_terc_ano_ant_fin := 0;
   end;
   --
   vn_fase := 9;
   --
   -- Valor Total
   vn_vl_total_ano_ant_fin := nvl(vn_vl_venda_ano_ant_fin,0)+nvl(vn_vl_uso_cons_ano_ant_fin,0)+nvl(vn_vl_terc_ano_ant_fin,0);
   --
   vn_fase := 10;
   --
   insert into dief_info_est ( id
                             , aberturadief_id
                             , dm_tipo_info_est
                             , vl_venda
                             , vl_uso_cons
                             , vl_terceiro
                             , vl_total
                             )
                      values
                             ( diefinfoest_seq.nextval -- id
                             , pk_csf_dief.gt_abertura_dief.id -- aberturadief_id
                             , 2 -- DM_TIPO_INFO_EST
                             , vn_vl_venda_ano_ant_fin -- vl_venda
                             , vn_vl_uso_cons_ano_ant_fin -- vl_uso_cons
                             , vn_vl_terc_ano_ant_fin -- vl_terceiro
                             , vn_vl_total_ano_ant_fin -- vl_total
                             );
   --
   vn_fase := 11;
   --
   -- Inicial do ano atual
   --
   -- Valor de Venda
   begin
      --
      select nvl(sum(inv.vl_item),0)
        into vn_vl_venda_ano_atu_ini
        from inventario inv
           , item i
           , tipo_item ti
       where inv.empresa_id = pk_csf_dief.gt_abertura_dief.empresa_id
         and to_char(inv.dt_inventario, 'mmrrrr') = '01' || to_char(vd_data_ref, 'rrrr')
         and inv.dm_ind_prop in (0,2)
         and inv.item_id = i.id
         and i.tipoitem_id = ti.id
         and ti.cd <> '07';
      --
   exception
      when others then
         vn_vl_venda_ano_atu_ini := 0;
   end;
   --
   vn_fase := 12;
   --
   -- Valor de Uso e Consumo
   begin
      --
      select nvl(sum(inv.vl_item),0)
        into vn_vl_uso_cons_ano_atu_ini
        from inventario inv
           , item i
           , tipo_item ti
       where inv.empresa_id = pk_csf_dief.gt_abertura_dief.empresa_id
         and to_char(inv.dt_inventario, 'mmrrrr') = '01' || to_char(vd_data_ref, 'rrrr')
         and inv.dm_ind_prop in (0,2)
         and inv.item_id = i.id
         and i.tipoitem_id = ti.id
         and ti.cd = '07';
      --
   exception
      when others then
         vn_vl_uso_cons_ano_atu_ini := 0;
   end;
   --
   vn_fase := 13;
   --
   -- Valor de Terceiros
   begin
      --
      select nvl(sum(inv.vl_item),0)
        into vn_vl_terc_ano_atu_ini
        from inventario inv
       where inv.empresa_id = pk_csf_dief.gt_abertura_dief.empresa_id
         and to_char(inv.dt_inventario, 'mmrrrr') = '01' || to_char(vd_data_ref, 'rrrr')
         and inv.dm_ind_prop = 1;
      --
   exception
      when others then
         vn_vl_terc_ano_atu_ini := 0;
   end;
   --
   vn_fase := 14;
   --
   -- Valor Total
   vn_vl_total_ano_atu_ini := nvl(vn_vl_venda_ano_atu_ini,0)+nvl(vn_vl_uso_cons_ano_atu_ini,0)+nvl(vn_vl_terc_ano_atu_ini,0);
   --
   vn_fase := 15;
   --
   insert into dief_info_est ( id
                             , aberturadief_id
                             , dm_tipo_info_est
                             , vl_venda
                             , vl_uso_cons
                             , vl_terceiro
                             , vl_total
                             )
                      values
                             ( diefinfoest_seq.nextval -- id
                             , pk_csf_dief.gt_abertura_dief.id -- aberturadief_id
                             , 3 -- DM_TIPO_INFO_EST
                             , vn_vl_venda_ano_atu_ini -- vl_venda
                             , vn_vl_uso_cons_ano_atu_ini -- vl_uso_cons
                             , vn_vl_terc_ano_atu_ini -- vl_terceiro
                             , vn_vl_total_ano_atu_ini -- vl_total
                             );
   --
   vn_fase := 16;
   --
   -- Final do ano atual
   --
   -- Valor de Venda
   begin
      --
      select nvl(sum(inv.vl_item),0)
        into vn_vl_venda_ano_atu_fin
        from inventario inv
           , item i
           , tipo_item ti
       where inv.empresa_id = pk_csf_dief.gt_abertura_dief.empresa_id
         and to_char(inv.dt_inventario, 'mmrrrr') = to_char(vd_data_ref, 'mmrrrr')
         and inv.dm_ind_prop in (0,2)
         and inv.item_id = i.id
         and i.tipoitem_id = ti.id
         and ti.cd <> '07';
      --
   exception
      when others then
         vn_vl_venda_ano_atu_fin := 0;
   end;
   --
   vn_fase := 17;
   --
   -- Valor de Uso e Consumo
   begin
      --
      select nvl(sum(inv.vl_item),0)
        into vn_vl_uso_cons_ano_atu_fin
        from inventario inv
           , item i
           , tipo_item ti
       where inv.empresa_id = pk_csf_dief.gt_abertura_dief.empresa_id
         and to_char(inv.dt_inventario, 'mmrrrr') = to_char(vd_data_ref, 'mmrrrr')
         and inv.dm_ind_prop in (0,2)
         and inv.item_id = i.id
         and i.tipoitem_id = ti.id
         and ti.cd = '07';
      --
   exception
      when others then
         vn_vl_uso_cons_ano_atu_fin := 0;
   end;
   --
   vn_fase := 18;
   --
   -- Valor de Terceiros
   begin
      --
      select nvl(sum(inv.vl_item),0)
        into vn_vl_terc_ano_atu_fin
        from inventario inv
       where inv.empresa_id = pk_csf_dief.gt_abertura_dief.empresa_id
         and to_char(inv.dt_inventario, 'mmrrrr') = to_char(vd_data_ref, 'mmrrrr')
         and inv.dm_ind_prop = 1;
      --
   exception
      when others then
         vn_vl_terc_ano_atu_fin := 0;
   end;
   --
   vn_fase := 19;
   --
   -- Valor Total
   vn_vl_total_ano_atu_fin := nvl(vn_vl_venda_ano_atu_fin,0)+nvl(vn_vl_uso_cons_ano_atu_fin,0)+nvl(vn_vl_terc_ano_atu_fin,0);
   --
   vn_fase := 20;
   --
   insert into dief_info_est ( id
                             , aberturadief_id
                             , dm_tipo_info_est
                             , vl_venda
                             , vl_uso_cons
                             , vl_terceiro
                             , vl_total
                             )
                      values
                             ( diefinfoest_seq.nextval -- id
                             , pk_csf_dief.gt_abertura_dief.id -- aberturadief_id
                             , 4 -- DM_TIPO_INFO_EST
                             , vn_vl_venda_ano_atu_fin -- vl_venda
                             , vn_vl_uso_cons_ano_atu_fin -- vl_uso_cons
                             , vn_vl_terc_ano_atu_fin -- vl_terceiro
                             , vn_vl_total_ano_atu_fin -- vl_total
                             );
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_calc_dief.pkb_gerar_info_est fase(' || vn_fase || '): ' || sqlerrm);
end pkb_gerar_info_est;

-------------------------------------------------------------------------------------------------------
-- Procedimento de geração de Despesas do Ano Anterior
-------------------------------------------------------------------------------------------------------
procedure pkb_gerar_desp_ano_ant
is
   --
   vn_fase number;
   --
   vn_diefdespanoant_id   dief_desp_ano_ant.id%type;
   vn_valor               dief_desp_ano_ant.valor%type;
   vn_tipo                dief_desp_ano_ant.dm_tipo%type;
   --
   cursor c_dados is
   select td.id   tabdindief_id
        , r.id    registrodief_id
        , td.ordem
     from tab_din_dief    td
        , registro_dief   r
    where td.registrodief_id   = r.id
      and td.dm_tipo           = 'E' -- Editável
      and r.cod                = '13'
    order by td.ordem;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      begin
         select diefdespanoant_seq.nextval
           into vn_diefdespanoant_id
           from dual;
      exception
         when others then
            vn_diefdespanoant_id := 0;
      end;
      --
      insert into dief_desp_ano_ant ( id
                                    , aberturadief_id
                                    , tabdindief_id
                                    , valor
                                    , dm_tipo
                                    )
                             values
                                    ( vn_diefdespanoant_id -- id
                                    , pk_csf_dief.gt_abertura_dief.id -- aberturadief_id
                                    , rec.tabdindief_id -- tabdindief_id
                                    , 0 -- valor
                                    , 0 -- dm_tipo
                                    );
      --
      vn_fase := 2;
      --
      vn_valor := 0;
      --
      -- Procedimento para geração dos valores DE-PARA
      pk_csf_api_dief.pkb_monta_vlr_tab_din_dief ( en_aberturadief_id   => pk_csf_dief.gt_abertura_dief.id
                                                 , en_registrodief_id   => rec.registrodief_id
                                                 , en_tabdindief_id     => rec.tabdindief_id
                                                 , ed_dt_ini            => to_date(pk_csf_dief.gt_abertura_dief.dm_mes_ref||pk_csf_dief.gt_abertura_dief.ano_ref, 'mmrrrr')
                                                 , ed_dt_fin            => to_date(pk_csf_dief.gt_abertura_dief.dm_mes_ref||pk_csf_dief.gt_abertura_dief.ano_ref, 'mmrrrr')
                                                 , ev_tabela_orig       => 'DIEF_DESP_ANO_ANT'
                                                 , ev_tabela_relac      => 'R_MCDIEF_DDAA'
                                                 , ev_col_relac         => 'DIEFDESPANOANT_ID'
                                                 , en_id_orig           => vn_diefdespanoant_id
                                                 , sn_vl                => vn_valor
                                                 );
      --
      vn_fase := 3;
      --
      update dief_desp_ano_ant
         set valor = nvl(vn_valor,0)
       where id = vn_diefdespanoant_id;
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_calc_dief.pkb_gerar_desp_ano_ant fase(' || vn_fase || '): ' || sqlerrm);
end pkb_gerar_desp_ano_ant;

-------------------------------------------------------------------------------------------------------
-- Procedimento de geração de Outras Informações
-------------------------------------------------------------------------------------------------------
procedure pkb_gerar_outra_infor
is
   --
   vn_fase number;
   --
   vn_diefoutrainfor_id   dief_outra_infor.id%type;
   vn_valor               dief_outra_infor.valor%type;
   vn_tipo                dief_outra_infor.dm_tipo%type;
   --
   cursor c_dados is
   select td.id   tabdindief_id
        , r.id    registrodief_id
        , td.ordem
     from tab_din_dief    td
        , registro_dief   r
    where td.registrodief_id   = r.id
      and td.dm_tipo           = 'E' -- Editável
      and r.cod                = '12'
    order by td.ordem;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      begin
         select diefoutrainfor_seq.nextval
           into vn_diefoutrainfor_id
           from dual;
      exception
         when others then
            vn_diefoutrainfor_id := 0;
      end;
      --
      insert into dief_outra_infor ( id
                                   , aberturadief_id
                                   , tabdindief_id
                                   , valor
                                   , dm_tipo
                                   )
                            values
                                   ( vn_diefoutrainfor_id -- id
                                   , pk_csf_dief.gt_abertura_dief.id -- aberturadief_id
                                   , rec.tabdindief_id -- tabdindief_id
                                   , 0 -- valor
                                   , 0 -- dm_tipo
                                   );
      --
      vn_fase := 2;
      --
      vn_valor := 0;
      --
      -- Procedimento para geração dos valores DE-PARA
      pk_csf_api_dief.pkb_monta_vlr_tab_din_dief ( en_aberturadief_id   => pk_csf_dief.gt_abertura_dief.id
                                                 , en_registrodief_id   => rec.registrodief_id
                                                 , en_tabdindief_id     => rec.tabdindief_id
                                                 , ed_dt_ini            => to_date(pk_csf_dief.gt_abertura_dief.dm_mes_ref||pk_csf_dief.gt_abertura_dief.ano_ref, 'mmrrrr')
                                                 , ed_dt_fin            => to_date(pk_csf_dief.gt_abertura_dief.dm_mes_ref||pk_csf_dief.gt_abertura_dief.ano_ref, 'mmrrrr')
                                                 , ev_tabela_orig       => 'DIEF_OUTRA_INFOR'
                                                 , ev_tabela_relac      => 'R_MCDIEF_DOI'
                                                 , ev_col_relac         => 'DIEFOUTRAINFOR_ID'
                                                 , en_id_orig           => vn_diefoutrainfor_id
                                                 , sn_vl                => vn_valor
                                                 );
      --
      vn_fase := 3;
      --
      update dief_outra_infor
         set valor = nvl(vn_valor,0)
       where id = vn_diefoutrainfor_id;
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_calc_dief.pkb_gerar_outra_infor fase(' || vn_fase || '): ' || sqlerrm);
end pkb_gerar_outra_infor;

-------------------------------------------------------------------------------------------------------
-- Procedimento de geração das Informações de Impostos Devidos
-------------------------------------------------------------------------------------------------------
procedure pkb_gerar_inf_imp_dev
is
   --
   vn_fase              number := 0;
   vn_apuracaoicms_id   apuracao_icms.id%type;
   --
   cursor c_imp_dev ( en_apuracaoicms_id number ) is
   select orai.ajobrigrecestado_id
        , orai.vl_orig_rec
     from obrig_rec_apur_icms orai
    where apuracaoicms_id = en_apuracaoicms_id;
   --
begin
   --
   vn_fase := 1;
   --
   begin
      --
      select ai.id
        into vn_apuracaoicms_id
        from apuracao_icms ai
           , obrig_rec_apur_icms orai
       where ai.empresa_id = pk_csf_dief.gt_abertura_dief.empresa_id
         and to_date(pk_csf_dief.gt_abertura_dief.dm_mes_ref||pk_csf_dief.gt_abertura_dief.ano_ref, 'mmrrrr') between ai.dt_inicio and ai.dt_fim
         and ai.dm_tipo = 0 -- Real
         and ai.dm_situacao = 3 -- Processada
         and orai.apuracaoicms_id = ai.id
         and rownum = 1;
      --
   exception
      when others then
         vn_apuracaoicms_id := 0;
   end;
   --
   vn_fase := 2;
   --
   for rec in c_imp_dev (vn_apuracaoicms_id) loop
      exit when c_imp_dev%notfound or (c_imp_dev%notfound) is null;
      --
      vn_fase := 3;
      --
      if nvl(rec.ajobrigrecestado_id,0) > 0 then
         --
         insert into dief_imp_dev ( id
                                  , aberturadief_id
                                  , period_ref
                                  , ajobrigrecestado_id
                                  , vl_icms
                                  , vl_ressarc_comp
                                  , vl_total
                                  , dm_tipo
                                  )
                           values
                                  ( diefimpdev_seq.nextval -- id
                                  , pk_csf_dief.gt_abertura_dief.id -- aberturadief_id
                                  , pk_csf_dief.gt_abertura_dief.dm_mes_ref||pk_csf_dief.gt_abertura_dief.ano_ref -- period_ref
                                  , rec.ajobrigrecestado_id -- ajobrigrecestado_id
                                  , rec.vl_orig_rec -- vl_icms
                                  , 0 -- vl_ressarc_comp
                                  , 0 -- vl_total
                                  , 1 -- dm_tipo
                                  );
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_calc_dief.pkb_gerar_inf_imp_dev fase(' || vn_fase || '): ' || sqlerrm);
end pkb_gerar_inf_imp_dev;

-------------------------------------------------------------------------------------------------------
-- Procedimento de geração da Apuração de ICMS
-------------------------------------------------------------------------------------------------------
procedure pkb_gerar_apur_icms is
  --
  vn_fase number := 0;
  --
  vn_vl_total_debito        apuracao_icms.vl_total_debito%type := 0;
  vn_vl_ajust_debito        apuracao_icms.vl_ajust_debito%type := 0;
  vn_vl_estorno_credito     apuracao_icms.vl_estorno_credito %type := 0;
  vn_vl_total_ajust_deb     apuracao_icms.vl_total_ajust_deb%type := 0;
  vn_vl_total_credito       apuracao_icms.vl_total_credito%type := 0;
  vn_vl_estorno_debito      apuracao_icms.vl_estorno_debido%type := 0;
  vn_vl_ajust_credito       apuracao_icms.vl_ajust_credito%type := 0;
  vn_vl_saldo_credor_ant    apuracao_icms.vl_saldo_credor_ant%type := 0;
  vn_vl_total_ajust_cred    apuracao_icms.vl_total_ajust_cred%type := 0;
  vn_vl_saldo_apurado       apuracao_icms.vl_saldo_apurado%type := 0;
  vn_vl_total_deducao       apuracao_icms.vl_total_deducao%type := 0;
  vn_vl_icms_recolher       apuracao_icms.vl_icms_recolher%type := 0;
  vn_vl_saldo_credor_transp apuracao_icms.vl_saldo_credor_transp%type := 0;
  vn_vl_aj_apur             ajust_apuracao_icms.vl_aj_apur%type := 0;
  vb_encontrou_apur         boolean := true;
  --
begin
  --
  vn_fase := 1;
  --
  begin
    select nvl(ai.vl_total_debito, 0) vl_total_debito,
           nvl(ai.vl_ajust_debito, 0) vl_ajust_debito,
           nvl(ai.vl_estorno_credito, 0) vl_estorno_credito,
           nvl(ai.vl_total_ajust_deb, 0) vl_total_ajust_deb,
           nvl(ai.vl_total_credito, 0) vl_total_credito,
           nvl(ai.vl_estorno_debido, 0) vl_estorno_debido,
           nvl(ai.vl_ajust_credito, 0) vl_ajust_credito,
           nvl(ai.vl_saldo_credor_ant, 0) vl_saldo_credor_ant,
           nvl(ai.vl_total_ajust_cred, 0) vl_total_ajust_cred,
           nvl(ai.vl_saldo_apurado, 0) vl_saldo_apurado,
           nvl(ai.vl_total_deducao, 0) vl_total_deducao,
           nvl(ai.vl_icms_recolher, 0) vl_icms_recolher,
           nvl(ai.vl_saldo_credor_transp, 0) vl_saldo_credor_transp,
           nvl((select sum(aai.vl_aj_apur)
                  from ajust_apuracao_icms aai,
                       cod_aj_saldo_apur_icms ca
                 where aai.apuracaoicms_id       = ai.id
                   and aai.codajsaldoapuricms_id = ca.id
                   and ca.dm_util                = 2), 0) vl_aj_apur
      into vn_vl_total_debito,
           vn_vl_ajust_debito,
           vn_vl_estorno_credito,
           vn_vl_total_ajust_deb,
           vn_vl_total_credito,
           vn_vl_estorno_debito,
           vn_vl_ajust_credito,
           vn_vl_saldo_credor_ant,
           vn_vl_total_ajust_cred,
           vn_vl_saldo_apurado,
           vn_vl_total_deducao,
           vn_vl_icms_recolher,
           vn_vl_saldo_credor_transp,
           vn_vl_aj_apur
      from apuracao_icms ai
     where ai.empresa_id  = pk_csf_dief.gt_abertura_dief.empresa_id
       and to_date(pk_csf_dief.gt_abertura_dief.dm_mes_ref || pk_csf_dief.gt_abertura_dief.ano_ref, 'mmrrrr') between ai.dt_inicio and ai.dt_fim
       and ai.dm_tipo     = 0 -- Real
       and ai.dm_situacao = 3 -- Processada
       and rownum         = 1;
  exception
    when others then
      vb_encontrou_apur := false;
  end;
  --
  vn_fase := 2;
  --
  if vb_encontrou_apur then
    --
    vn_fase := 3;
    --
    begin
      insert into dief_apur_icms
        (id,
         aberturadief_id,
         vl_deb_saida,
         vl_outro_deb_total,
         vl_sld_credor_trans1,
         vl_sld_credor_trans2,
         vl_outro_deb,
         vl_estorn_cred_total,
         vl_transf_cred_cm,
         vl_outro_est_cred,
         vl_total_deb,
         vl_cred_ent,
         vl_estorn_deb,
         vl_outro_cred_total,
         vl_cred_pres_total,
         vl_inc_fiscal,
         vl_outro_cred_pres,
         vl_cred_ativ_imob,
         vl_cred_ch_mor,
         vl_cred_transf_ch_mor,
         vl_cred_hom_ant_saida,
         vl_cred_rec_icms_ant_esp,
         vl_cred_rec_icms_ant_glosa,
         vl_sld_cred_rec_transf1,
         vl_sld_cred_rec_transf2,
         vl_outro_cred,
         vl_sld_period_ant,
         vl_total_cred,
         vl_sld_devedor,
         vl_deducao,
         vl_lei_semear,
         vl_outro_deducao,
         vl_sub_total,
         vl_lei_6489,
         vl_icms_receber,
         vl_saldo_cred_transf)
      values
        (diefapuricms_seq.nextval, -- id
         pk_csf_dief.gt_abertura_dief.id, -- aberturadief_id
         vn_vl_total_debito, -- vl_deb_saida
         (nvl(vn_vl_ajust_debito, 0) + nvl(vn_vl_total_ajust_deb, 0)), -- vl_outro_deb_total -- (vl_sld_credor_trans1 + vl_sld_credor_trans2 + vl_outro_deb)
         0, -- vl_sld_credor_trans1
         0, -- vl_sld_credor_trans2
         (nvl(vn_vl_ajust_debito, 0) + nvl(vn_vl_total_ajust_deb, 0)), -- vl_outro_deb
         vn_vl_estorno_credito, -- vl_estorn_cred_total
         0, -- vl_transf_cred_cm
         0, -- vl_outro_est_cred
         vn_vl_total_ajust_deb, -- vl_total_deb
         vn_vl_total_credito, -- vl_cred_ent
         vn_vl_estorno_debito, -- vl_estorn_deb
         (nvl(vn_vl_ajust_credito, 0) + nvl(vn_vl_total_ajust_cred, 0)), -- vl_outro_cred_total
         0, -- vl_cred_pres_total
         0, -- vl_inc_fiscal
         0, -- vl_outro_cred_pres
         0, -- vl_cred_ativ_imob
         0, -- vl_cred_ch_mor
         0, -- vl_cred_transf_ch_mor
         0, -- vl_cred_hom_ant_saida
         0, -- vl_cred_rec_icms_ant_esp
         0, -- vl_cred_rec_icms_ant_glosa
         0, -- vl_sld_cred_rec_transf1
         0, -- vl_sld_cred_rec_transf2
         vn_vl_aj_apur, -- vl_outro_cred
         vn_vl_saldo_credor_ant, -- vl_sld_period_ant
         (nvl(vn_vl_total_credito, 0) + nvl(vn_vl_estorno_debito, 0) + nvl(vn_vl_saldo_credor_ant, 0) + nvl(vn_vl_total_ajust_cred, 0)), -- vl_total_cred
         vn_vl_saldo_apurado, -- vl_sld_devedor
         vn_vl_total_deducao, -- vl_deducao
         0, -- vl_lei_semear
         0, -- vl_outro_deducao
         0, -- vl_sub_total
         0, -- vl_lei_6489
         vn_vl_icms_recolher, -- vl_icms_receber
         vn_vl_saldo_credor_transp); -- vl_saldo_cred_transf
    exception
      when dup_val_on_index then
        --
        vn_fase := 4;
        --
        begin
          update dief_apur_icms da
             set da.vl_deb_saida               = vn_vl_total_debito,
                 da.vl_outro_deb_total         = (nvl(vn_vl_ajust_debito, 0) + nvl(vn_vl_total_ajust_deb, 0)),
                 da.vl_sld_credor_trans1       = 0,
                 da.vl_sld_credor_trans2       = 0,
                 da.vl_outro_deb               = (nvl(vn_vl_ajust_debito, 0) + nvl(vn_vl_total_ajust_deb, 0)),
                 da.vl_estorn_cred_total       = vn_vl_estorno_credito,
                 da.vl_transf_cred_cm          = 0,
                 da.vl_outro_est_cred          = 0,
                 da.vl_total_deb               = vn_vl_total_ajust_deb,
                 da.vl_cred_ent                = vn_vl_total_credito,
                 da.vl_estorn_deb              = vn_vl_estorno_debito,
                 da.vl_outro_cred_total        = (vn_vl_ajust_credito + vn_vl_total_ajust_cred),
                 da.vl_cred_pres_total         = 0,
                 da.vl_inc_fiscal              = 0,
                 da.vl_outro_cred_pres         = 0,
                 da.vl_cred_ativ_imob          = 0,
                 da.vl_cred_ch_mor             = 0,
                 da.vl_cred_transf_ch_mor      = 0,
                 da.vl_cred_hom_ant_saida      = 0,
                 da.vl_cred_rec_icms_ant_esp   = 0,
                 da.vl_cred_rec_icms_ant_glosa = 0,
                 da.vl_sld_cred_rec_transf1    = 0,
                 da.vl_sld_cred_rec_transf2    = 0,
                 da.vl_outro_cred              = vn_vl_aj_apur,
                 da.vl_sld_period_ant          = vn_vl_saldo_credor_ant,
                 da.vl_total_cred              = (nvl(vn_vl_total_credito, 0) + nvl(vn_vl_estorno_debito, 0) + nvl(vn_vl_saldo_credor_ant, 0) + nvl(vn_vl_total_ajust_cred, 0)),
                 da.vl_sld_devedor             = vn_vl_saldo_apurado,
                 da.vl_deducao                 = vn_vl_total_deducao,
                 da.vl_lei_semear              = 0,
                 da.vl_outro_deducao           = 0,
                 da.vl_sub_total               = 0,
                 da.vl_lei_6489                = 0,
                 da.vl_icms_receber            = vn_vl_icms_recolher,
                 da.vl_saldo_cred_transf       = vn_vl_saldo_credor_transp
           where da.aberturadief_id            = pk_csf_dief.gt_abertura_dief.id;
        exception
          when others then
            raise_application_error(-20101, 'Problemas em pk_calc_dief.pkb_gerar_apur_icms - alterar registro de apuração do icms - dief fase(' || vn_fase || '): ' || sqlerrm);
        end;
      when others then
        raise_application_error(-20101, 'Problemas em pk_calc_dief.pkb_gerar_apur_icms - incluir registro de apuração do icms - dief fase(' || vn_fase || '): ' || sqlerrm);
    end;
    --
    commit;
    --
  end if;
  --
exception
  when others then
    raise_application_error(-20101, 'Erro na pk_calc_dief.pkb_gerar_apur_icms fase(' || vn_fase || '): ' || sqlerrm);
end pkb_gerar_apur_icms;

-------------------------------------------------------------------------------------------------------
procedure pkb_acum_vl_livro_apur ( en_cfop_id        in cfop.id%type
                                 , en_vl_contabil    in dief_livro_apur.vl_contabil%type
                                 , en_vl_base_calc   in dief_livro_apur.vl_base_calc%type
                                 , en_vl_imp_trib    in dief_livro_apur.vl_imp_trib%type
                                 , en_vl_isenta      in dief_livro_apur.vl_isenta%type
                                 , en_vl_outras      in dief_livro_apur.vl_outras%type
                                 )
is
begin
   --
   vt_tab_dief_livro_apur(en_cfop_id).cfop_id        := en_cfop_id;
   vt_tab_dief_livro_apur(en_cfop_id).vl_contabil    := nvl(vt_tab_dief_livro_apur(en_cfop_id).vl_contabil,0) + nvl(en_vl_contabil,0);
   vt_tab_dief_livro_apur(en_cfop_id).vl_base_calc   := nvl(vt_tab_dief_livro_apur(en_cfop_id).vl_base_calc,0) + nvl(en_vl_base_calc,0);
   vt_tab_dief_livro_apur(en_cfop_id).vl_imp_trib    := nvl(vt_tab_dief_livro_apur(en_cfop_id).vl_imp_trib,0) + nvl(en_vl_imp_trib,0);
   vt_tab_dief_livro_apur(en_cfop_id).vl_isenta      := nvl(vt_tab_dief_livro_apur(en_cfop_id).vl_isenta,0) + nvl(en_vl_isenta,0);
   vt_tab_dief_livro_apur(en_cfop_id).vl_outras      := nvl(vt_tab_dief_livro_apur(en_cfop_id).vl_outras,0) + nvl(en_vl_outras,0);
   --
end pkb_acum_vl_livro_apur;

-------------------------------------------------------------------------------------------------------
procedure pkb_grava_livro_apur
is
   --
   vn_indice number := 0;
   --
begin
   --
   vn_indice := vt_tab_dief_livro_apur.first;
   --
   while vn_indice <= vt_tab_dief_livro_apur.last
   loop
      --
      insert into dief_livro_apur ( id
                                  , aberturadief_id
                                  , cfop_id
                                  , vl_contabil
                                  , vl_base_calc
                                  , vl_imp_trib
                                  , vl_isenta
                                  , vl_outras
                                  )
                           values ( dieflivroapur_seq.nextval
                                  , pk_csf_dief.gt_abertura_dief.id
                                  , vt_tab_dief_livro_apur(vn_indice).cfop_id
                                  , vt_tab_dief_livro_apur(vn_indice).vl_contabil
                                  , vt_tab_dief_livro_apur(vn_indice).vl_base_calc
                                  , vt_tab_dief_livro_apur(vn_indice).vl_imp_trib
                                  , vt_tab_dief_livro_apur(vn_indice).vl_isenta
                                  , vt_tab_dief_livro_apur(vn_indice).vl_outras
                                  );
      --
      vn_indice := vt_tab_dief_livro_apur.next(vn_indice);
      --
   end loop;
   --
   commit;
   --
end pkb_grava_livro_apur;

-------------------------------------------------------------------------------------------------------
-- Procedimento de geração do Livro de Apuração
-------------------------------------------------------------------------------------------------------
procedure pkb_gerar_livro_apur is
  --
  vn_fase number := 0;
  --
  vn_cfop                number := 0;
  vn_cfop_id             number := 0;
  vn_vl_contabil         number := 0;
  vn_vl_base_calc        number := 0;
  vn_vl_imp_trib         number := 0;
  vn_vl_isenta           number := 0;
  vn_vl_outras           number := 0;
  vn_vl_nao_utilizado    number := 0;
  vv_cod_st              varchar2(3);
  vn_aliq_icms           imp_itemnf.aliq_apli%type := 0;
  vn_vl_imp_trib_icms    number := 0;
  vn_vl_base_calc_icmsst number := 0;
  vn_vl_imp_trib_icmsst  number := 0;
  vn_vl_imp_trib_ipi     number := 0;
  --
  -- Nota Fiscal Mercantil e Serviço
  cursor c_nf is
    select inf.id itemnf_id
      from nota_fiscal nf,
           mod_fiscal mf,
           item_nota_fiscal inf
     where nf.empresa_id      = pk_csf_dief.gt_abertura_dief.empresa_id
       and nf.dm_st_proc      = 4
       and nf.dm_arm_nfe_terc = 0
       and ((nf.dm_ind_emit = 1 and to_char(nvl(nf.dt_sai_ent, nf.dt_emiss), 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref || pk_csf_dief.gt_abertura_dief.ano_ref)
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and to_char(nf.dt_emiss, 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref || pk_csf_dief.gt_abertura_dief.ano_ref)
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_char(nf.dt_emiss, 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref || pk_csf_dief.gt_abertura_dief.ano_ref)
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and to_char(nvl(nf.dt_sai_ent, nf.dt_emiss), 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref || pk_csf_dief.gt_abertura_dief.ano_ref))
       and mf.id              = nf.modfiscal_id
       and mf.cod_mod         in ('55', '65', '01', '04', '1B', '99', 'ND')
       and inf.notafiscal_id  = nf.id
     order by 1;
  --
  -- Nota Fiscal de Serviço Coninuo
  cursor c_nf_sc is
    select r.id nfregistanalit_id,
           r.cfop_id,
           r.vl_operacao,
           r.vl_bc_icms,
           r.vl_icms,
           r.vl_base_isenta,
           r.vl_base_outro
      from nota_fiscal nf,
           mod_fiscal mf,
           nfregist_analit r
     where nf.empresa_id      = pk_csf_dief.gt_abertura_dief.empresa_id
       and nf.dm_st_proc      = 4
       and nf.dm_arm_nfe_terc = 0
       and ((nf.dm_ind_emit = 1 and to_char(nvl(nf.dt_sai_ent, nf.dt_emiss), 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref || pk_csf_dief.gt_abertura_dief.ano_ref)
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and to_char(nf.dt_emiss, 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref || pk_csf_dief.gt_abertura_dief.ano_ref)
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_char(nf.dt_emiss, 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref || pk_csf_dief.gt_abertura_dief.ano_ref)
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and to_char(nvl(nf.dt_sai_ent, nf.dt_emiss), 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref || pk_csf_dief.gt_abertura_dief.ano_ref))
       and mf.id              = nf.modfiscal_id
       and mf.cod_mod         in ('06', '29', '28', '21', '22')
       and r.notafiscal_id    = nf.id
     order by 1;
  --
  -- Conhecimento de Transporte
  cursor c_ct is
    select r.id ctreganal_id,
           r.cfop_id,
           r.vl_opr,
           r.vl_bc_icms,
           r.vl_icms,
           r.vl_base_isenta,
           r.vl_base_outro
      from conhec_transp ct,
           ct_reg_anal r
     where ct.empresa_id      = pk_csf_dief.gt_abertura_dief.empresa_id
       and ct.dm_st_proc      = 4
       and ct.dm_arm_cte_terc = 0
       and ((ct.dm_ind_emit = 1 and to_char(nvl(ct.dt_sai_ent, ct.dt_hr_emissao), 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref || pk_csf_dief.gt_abertura_dief.ano_ref)
             or
            (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 1 and to_char(ct.dt_hr_emissao, 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref || pk_csf_dief.gt_abertura_dief.ano_ref)
             or
            (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_char(ct.dt_hr_emissao, 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref || pk_csf_dief.gt_abertura_dief.ano_ref)
             or
            (ct.dm_ind_emit = 0 and ct.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and to_char(nvl(ct.dt_sai_ent, ct.dt_hr_emissao), 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref || pk_csf_dief.gt_abertura_dief.ano_ref))
       and r.conhectransp_id  = ct.id
     order by 1;
  --
  -- Cupom Fiscal
  cursor c_ecf is
    select ramd.id reganalmovdiaecf_id
      from equip_ecf e,
           reducao_z_ecf r,
           reg_anal_mov_dia_ecf ramd
     where e.empresa_id        = pk_csf_dief.gt_abertura_dief.empresa_id
       and r.equipecf_id       = e.id
       and r.dm_st_proc        = 1 -- Validada
       and to_char(r.dt_doc, 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref || pk_csf_dief.gt_abertura_dief.ano_ref
       and ramd.reducaozecf_id = r.id
     order by 1;
  --
  -- Cupom Fiscal Eletrônico
  cursor c_cfe is
    select icf.id itemcf_id
      from cupom_fiscal      cf,
           mod_fiscal        mf,
           item_cupom_fiscal icf,
           sit_docto         sd
     where cf.empresa_id      = pk_csf_dief.gt_abertura_dief.empresa_id
       and to_char(cf.dt_emissao, 'mmrrrr') = pk_csf_dief.gt_abertura_dief.dm_mes_ref || pk_csf_dief.gt_abertura_dief.ano_ref
       and cf.dm_st_proc      = 4 -- 4-Autorizado
       and mf.id              = cf.modfiscal_id
       and mf.cod_mod         = '59' -- Cupom Fiscal Eletrônico
       and icf.cupomfiscal_id = cf.id
       and sd.id              = cf.sitdocto_id
       and sd.cd              in ('00', '01'); -- 00-Documento regular, 01-Documento regular extemporâneo
  --
begin
  --
  vn_fase := 1;
  --
  for rec in c_nf loop
    exit when c_nf%notfound or(c_nf%notfound) is null;
    --
    vn_fase := 2;
    --
    vn_cfop         := null;
    vn_cfop_id      := 0;
    vn_vl_contabil  := 0;
    vn_vl_base_calc := 0;
    vn_vl_imp_trib  := 0;
    vn_vl_isenta    := 0;
    vn_vl_outras    := 0;
    --
    vn_fase := 3;
    --
    pk_csf_api.pkb_vlr_fiscal_item_nf(en_itemnf_id           => rec.itemnf_id,
                                      sn_cfop                => vn_cfop,
                                      sn_vl_operacao         => vn_vl_contabil,
                                      sv_cod_st_icms         => vv_cod_st,
                                      sn_vl_base_calc_icms   => vn_vl_base_calc,
                                      sn_aliq_icms           => vn_vl_nao_utilizado,
                                      sn_vl_imp_trib_icms    => vn_vl_imp_trib,
                                      sn_vl_base_calc_icmsst => vn_vl_nao_utilizado,
                                      sn_vl_imp_trib_icmsst  => vn_vl_nao_utilizado,
                                      sn_vl_bc_isenta_icms   => vn_vl_isenta,
                                      sn_vl_bc_outra_icms    => vn_vl_outras,
                                      sv_cod_st_ipi          => vv_cod_st,
                                      sn_vl_base_calc_ipi    => vn_vl_nao_utilizado,
                                      sn_aliq_ipi            => vn_vl_nao_utilizado,
                                      sn_vl_imp_trib_ipi     => vn_vl_nao_utilizado,
                                      sn_vl_bc_isenta_ipi    => vn_vl_nao_utilizado,
                                      sn_vl_bc_outra_ipi     => vn_vl_nao_utilizado,
                                      sn_ipi_nao_recup       => vn_vl_nao_utilizado,
                                      sn_outro_ipi           => vn_vl_nao_utilizado,
                                      sn_vl_imp_nao_dest_ipi => vn_vl_nao_utilizado,
                                      sn_vl_fcp_icmsst       => vn_vl_nao_utilizado,
                                      sn_aliq_fcp_icms       => vn_vl_nao_utilizado,
                                      sn_vl_fcp_icms         => vn_vl_nao_utilizado);
    --
    vn_fase := 4;
    --
    vn_cfop_id := pk_csf.fkg_cfop_id(en_cd => vn_cfop);
    --
    vn_fase := 5;
    --
    pkb_acum_vl_livro_apur(en_cfop_id      => vn_cfop_id,
                           en_vl_contabil  => vn_vl_contabil,
                           en_vl_base_calc => vn_vl_base_calc,
                           en_vl_imp_trib  => vn_vl_imp_trib,
                           en_vl_isenta    => vn_vl_isenta,
                           en_vl_outras    => vn_vl_outras);
    --
  end loop;
  --
  vn_fase := 6;
  --
  for rec in c_nf_sc loop
    exit when c_nf_sc%notfound or(c_nf_sc%notfound) is null;
    --
    vn_fase := 7;
    --
    vn_cfop         := null;
    vn_cfop_id      := 0;
    vn_vl_contabil  := 0;
    vn_vl_base_calc := 0;
    vn_vl_imp_trib  := 0;
    vn_vl_isenta    := 0;
    vn_vl_outras    := 0;
    --
    vn_fase := 8;
    --
    pk_csf_api.pkb_vlr_fiscal_nfsc(en_nfregistanalit_id => rec.nfregistanalit_id,
                                   sv_cod_st_icms       => vv_cod_st,
                                   sn_cfop              => vn_cfop,
                                   sn_aliq_icms         => vn_aliq_icms,
                                   sn_vl_operacao       => vn_vl_contabil,
                                   sn_vl_bc_icms        => vn_vl_base_calc,
                                   sn_vl_icms           => vn_vl_imp_trib,
                                   sn_vl_bc_icmsst      => vn_vl_base_calc_icmsst,
                                   sn_vl_icms_st        => vn_vl_imp_trib_icmsst,
                                   sn_vl_ipi            => vn_vl_imp_trib_ipi,
                                   sn_vl_bc_isenta_icms => vn_vl_isenta,
                                   sn_vl_bc_outra_icms  => vn_vl_outras);

    --
    vn_fase := 9;
    --
    vn_cfop_id := pk_csf.fkg_cfop_id(en_cd => vn_cfop);
    --
    vn_fase := 10;
    --
    pkb_acum_vl_livro_apur(en_cfop_id      => vn_cfop_id,
                           en_vl_contabil  => vn_vl_contabil,
                           en_vl_base_calc => vn_vl_base_calc,
                           en_vl_imp_trib  => vn_vl_imp_trib,
                           en_vl_isenta    => vn_vl_isenta,
                           en_vl_outras    => vn_vl_outras);
  --
  end loop;
  --
  vn_fase := 11;
  --
  for rec in c_ct loop
    exit when c_ct%notfound or(c_ct%notfound) is null;
    --
    vn_fase := 12;
    --
    vn_cfop         := null;
    vn_cfop_id      := 0;
    vn_vl_contabil  := 0;
    vn_vl_base_calc := 0;
    vn_vl_imp_trib  := 0;
    vn_vl_isenta    := 0;
    vn_vl_outras    := 0;
    --
    vn_fase := 13;
    --
    pk_csf_ct.pkb_vlr_fiscal_ct(en_ctreganal_id      => rec.ctreganal_id,
                                sv_cod_st_icms       => vv_cod_st,
                                sn_cfop              => vn_cfop,
                                sn_aliq_icms         => vn_aliq_icms,
                                sn_vl_opr            => vn_vl_contabil,
                                sn_vl_bc_icms        => vn_vl_base_calc,
                                sn_vl_icms           => vn_vl_imp_trib,
                                sn_vl_bc_isenta_icms => vn_vl_isenta,
                                sn_vl_bc_outra_icms  => vn_vl_outras);
    --
    vn_fase := 14;
    --
    vn_cfop_id := pk_csf.fkg_cfop_id(en_cd => vn_cfop);
    --
    vn_fase := 15;
    --
    pkb_acum_vl_livro_apur(en_cfop_id      => vn_cfop_id,
                           en_vl_contabil  => vn_vl_contabil,
                           en_vl_base_calc => vn_vl_base_calc,
                           en_vl_imp_trib  => vn_vl_imp_trib,
                           en_vl_isenta    => vn_vl_isenta,
                           en_vl_outras    => vn_vl_outras);
    --
  end loop;
  --
  vn_fase := 16;
  --
  for rec in c_ecf loop
    exit when c_ecf%notfound or(c_ecf%notfound) is null;
    --
    vn_fase := 17;
    --
    vn_cfop         := null;
    vn_cfop_id      := 0;
    vn_vl_contabil  := 0;
    vn_vl_base_calc := 0;
    vn_vl_imp_trib  := 0;
    vn_vl_isenta    := 0;
    vn_vl_outras    := 0;
    --
    vn_fase := 18;
    --
    pk_csf_api_ecf.pkb_vlr_fiscal_ecf(en_reganalmovdiaecf_id => rec.reganalmovdiaecf_id,
                                      sv_cod_st_icms         => vv_cod_st,
                                      sn_cfop                => vn_cfop,
                                      sn_aliq_icms           => vn_vl_nao_utilizado,
                                      sn_vl_opr              => vn_vl_contabil,
                                      sn_vl_bc_icms          => vn_vl_base_calc,
                                      sn_vl_icms             => vn_vl_imp_trib,
                                      sn_vl_bc_isenta_icms   => vn_vl_isenta,
                                      sn_vl_bc_outra_icms    => vn_vl_outras);
    --
    vn_fase := 19;
    --
    vn_cfop_id := pk_csf.fkg_cfop_id(en_cd => vn_cfop);
    --
    vn_fase := 20;
    --
    pkb_acum_vl_livro_apur(en_cfop_id      => vn_cfop_id,
                           en_vl_contabil  => vn_vl_contabil,
                           en_vl_base_calc => vn_vl_base_calc,
                           en_vl_imp_trib  => vn_vl_imp_trib,
                           en_vl_isenta    => vn_vl_isenta,
                           en_vl_outras    => vn_vl_outras);
    --
  end loop;
  --
  vn_fase := 21;
  --
  for rec in c_cfe loop
    exit when c_cfe%notfound or(c_cfe%notfound) is null;
    --
    vn_fase := 22;
    --
    vn_cfop         := null;
    vn_cfop_id      := 0;
    vn_vl_contabil  := 0;
    vn_vl_base_calc := 0;
    vn_vl_imp_trib  := 0;
    vn_vl_isenta    := 0;
    vn_vl_outras    := 0;
    --
    vn_fase := 23;
    --
    pk_csf_api.pkb_vlr_fiscal_item_cfe(en_itemcupomfiscal_id  => rec.itemcf_id,
                                       sn_cfop                => vn_cfop,
                                       sn_vl_operacao         => vn_vl_contabil,
                                       sv_cod_st_icms         => vv_cod_st,
                                       sn_vl_base_calc_icms   => vn_vl_base_calc,
                                       sn_aliq_icms           => vn_vl_nao_utilizado,
                                       sn_vl_imp_trib_icms    => vn_vl_imp_trib,
                                       sn_vl_base_calc_icmsst => vn_vl_nao_utilizado,
                                       sn_vl_imp_trib_icmsst  => vn_vl_nao_utilizado,
                                       sn_vl_bc_isenta_icms   => vn_vl_isenta,
                                       sn_vl_bc_outra_icms    => vn_vl_outras,
                                       sv_cod_st_ipi          => vv_cod_st,
                                       sn_vl_base_calc_ipi    => vn_vl_nao_utilizado,
                                       sn_aliq_ipi            => vn_vl_nao_utilizado,
                                       sn_vl_imp_trib_ipi     => vn_vl_nao_utilizado,
                                       sn_vl_bc_isenta_ipi    => vn_vl_nao_utilizado,
                                       sn_vl_bc_outra_ipi     => vn_vl_nao_utilizado,
                                       sn_ipi_nao_recup       => vn_vl_nao_utilizado,
                                       sn_outro_ipi           => vn_vl_nao_utilizado);
    --
    vn_fase := 24;
    --
    vn_cfop_id := pk_csf.fkg_cfop_id(en_cd => vn_cfop);
    --
    vn_fase := 25;
    --
    pkb_acum_vl_livro_apur(en_cfop_id      => vn_cfop_id,
                           en_vl_contabil  => vn_vl_contabil,
                           en_vl_base_calc => vn_vl_base_calc,
                           en_vl_imp_trib  => vn_vl_imp_trib,
                           en_vl_isenta    => vn_vl_isenta,
                           en_vl_outras    => vn_vl_outras);
    --
  end loop;
  --
  vn_fase := 26;
  --
  pkb_grava_livro_apur;
  --
exception
  when others then
    raise_application_error(-20101, 'Erro na pk_calc_dief.pkb_gerar_livro_apur fase(' || vn_fase || '): ' || sqlerrm);
end pkb_gerar_livro_apur;

-------------------------------------------------------------------------------------------------------
-- Procedimento de Cálculo e Geração dos dados da DIEF-Pará
-------------------------------------------------------------------------------------------------------
procedure pkb_calcular ( en_aberturadief_id in abertura_dief.id%type )
is
   --
   vn_fase number := 0;
   --
   vn_loggenerico_id  log_generico.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   pk_csf_dief.pkb_dados_abertura_dief ( en_aberturadief_id => en_aberturadief_id );
   --
   vn_fase := 1.1;
   --
   if nvl(pk_csf_dief.gt_abertura_dief.id,0) > 0 then
      --
      vn_fase := 2;
      --
      if nvl(pk_csf_dief.gt_abertura_dief.dm_situacao,0) = 0 then -- Em Aberto
         --
         vn_fase := 3;
         --
         delete from log_generico
          where referencia_id = en_aberturadief_id
            and obj_referencia = 'ABERTURA_DIEF';
         --
         vn_fase := 4;
         --
         gn_dm_dt_escr_dfepoe := pk_csf.fkg_dmdtescrdfepoe_empresa ( en_empresa_id => pk_csf_dief.gt_abertura_dief.empresa_id );
         --
         vn_fase := 5;
         --
         -- Procedimento de geração do Livro de Apuração
         pkb_gerar_livro_apur;
         --
         vn_fase := 6;
         --
         -- Procedimento de geração da Apuração de ICMS
         pkb_gerar_apur_icms;
         --
         vn_fase := 7;
         --
         -- Procedimento de geração das Informações de Impostos Devidos
         pkb_gerar_inf_imp_dev;
         --
         vn_fase := 8;
         --
         -- Procedimento de geração de Outras Informações
         pkb_gerar_outra_infor;
         --
         vn_fase := 9;
         --
         -- Procedimento de geração de Despesas do Ano Anterior
         pkb_gerar_desp_ano_ant;
         --
         vn_fase := 10;
         --
         -- Procedimento de geração de Informações de Estoque
         pkb_gerar_info_est;
         --
         vn_fase := 11;
         --
         -- Procedimento de geração de Informações de Cupom Fiscal
         pkb_gerar_inf_ecf;
         --
         vn_fase := 12;
         --
         -- Procedimento de geração de Informações de ICMS-ST
         pkb_gerar_inf_st;
         --
         vn_fase := 13;
         --
         -- Procedimento de geração de Informações de Serviços
         pkb_gerar_inf_serv;
         --
         pk_csf_dief.pkb_definir_situacao ( en_aberturadief_id => en_aberturadief_id
                                          , en_dm_situacao     => 2 -- Calculado
                                          );
         --
      else
         --
         vn_fase := 99;
         --
         pk_log_generico.gv_mensagem := 'Situação atual não permite a realização do cálculo e geração de dados da DIEF-Pará';
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_dief.gv_resumo
                                          , ev_resumo          => pk_log_generico.gv_mensagem
                                          , en_tipo_log        => pk_log_generico.INFORMACAO
                                          , en_referencia_id   => en_aberturadief_id
                                          , ev_obj_referencia  => pk_csf_dief.gv_obj_referencia
                                          , en_empresa_id      => pk_csf_dief.gt_abertura_dief.empresa_id
                                          );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_dief.pkb_definir_situacao ( en_aberturadief_id => en_aberturadief_id
                                       , en_dm_situacao     => 1 -- Erro de cálculo
                                       );
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_calc_dief.pkb_calcular fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_dief.gv_resumo
                                          , ev_resumo          => pk_log_generico.gv_mensagem
                                          , en_tipo_log        => pk_log_generico.ERRO_DE_SISTEMA
                                          , en_referencia_id   => en_aberturadief_id
                                          , ev_obj_referencia  => pk_csf_dief.gv_obj_referencia
                                          , en_empresa_id      => pk_csf_dief.gt_abertura_dief.empresa_id
                                          );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_calcular;
-------------------------------------------------------------------------------------------------------

end pk_calc_dief;
/
