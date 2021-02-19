create or replace package body csf_own.pk_calc_apur_lr is

-------------------------------------------------------------------------------------------------------
-- Corpo do pacote de Geração do Cálculo da Apuracao do Lucro Real do Sped ECF
-------------------------------------------------------------------------------------------------------

-- Procedimento para atribuir a Situação do Periodo de Cálculo da Apuração do Lucro Real
procedure pkb_seta_situacao ( ev_evento in varchar2 )
is
   --
   vn_dm_situacao per_calc_apur_lr.dm_situacao%type := 4;
   --
begin
   --
   if ev_evento = 'CALCULAR' then
      --
      if nvl(gt_log_generico.count,0) > 0 then
         --
         vn_dm_situacao := 2; -- Erro no cálculo
         --
      else
         --
         vn_dm_situacao := 1; -- Calculada
         --
      end if;
      --
   elsif ev_evento = 'PROCESSAR' then
      --
      if nvl(gt_log_generico.count,0) > 0 then
         --
         vn_dm_situacao := 4; -- Erro de validação
         --
      else
         --
         vn_dm_situacao := 3; -- Processada
         --
      end if;
      --
   end if;
   --
   update per_calc_apur_lr set dm_situacao = vn_dm_situacao
    where id = pk_csf_api_secf.gt_row_per_calc_apur_lr.id;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_calc_apur_lr.pkb_seta_situacao: ' || sqlerrm);
end pkb_seta_situacao;
-------------------------------------------------------------------------------------------------------

-- Procedimento de Desfazer Calculo da Apuracao do Lucro Real
procedure pkb_desfazer ( en_percalcapurlr_id  in per_calc_apur_lr.id%type )
is
   --
   vn_fase number;
   vn_dm_situacao per_calc_apur_lr.dm_situacao%type;
   --
   cursor c_dados1 is
   select *
     from bc_irpj_lr_comp_prej
    where percalcapurlr_id = en_percalcapurlr_id
    order by 1;
   --
   cursor c_dados2 (en_bcirpjlrcompprej_id bc_irpj_lr_comp_prej.id%type) is
   select *
     from r_mcecf_birlrcp
    where bcirpjlrcompprej_id = en_bcirpjlrcompprej_id;
   --
   cursor c_dados3 is
   select *
     from dem_lucro_expl
    where percalcapurlr_id = en_percalcapurlr_id
    order by 1;
   --
   cursor c_dados4 (en_demlucroexpl_id dem_lucro_expl.id%type) is
   select *
     from r_mcecf_dle
    where demlucroexpl_id = en_demlucroexpl_id;
   --
   cursor c_dados5 is
   select *
     from calc_isen_red_imp_lr
    where percalcapurlr_id = en_percalcapurlr_id
    order by 1;
   --
   cursor c_dados6 (en_calcisenredimplr_id calc_isen_red_imp_lr.id%type) is
   select *
     from r_mcecf_cirilr
    where calcisenredimplr_id = en_calcisenredimplr_id;
   --
   cursor c_dados7 is
   select *
     from calc_irpj_mes_estim
    where percalcapurlr_id = en_percalcapurlr_id
    order by 1;
   --
   cursor c_dados8 (en_calcirpjmesestim_id calc_irpj_mes_estim.id%type) is
   select *
     from r_mcecf_cirpjme
    where calcirpjmesestim_id = en_calcirpjmesestim_id;
   --
   cursor c_dados9 is
   select *
     from calc_irpj_base_lr
    where percalcapurlr_id = en_percalcapurlr_id
    order by 1;
   --
   cursor c_dados10 (en_calcirpjbaselr_id calc_irpj_base_lr.id%type) is
   select *
     from r_mcecf_cirpjblr
    where calcirpjbaselr_id = en_calcirpjbaselr_id;
   --
   cursor c_dados11 is
   select *
     from bc_csll_comp_neg
    where percalcapurlr_id = en_percalcapurlr_id
    order by 1;
   --
   cursor c_dados12 (en_bccsllcompneg_id bc_csll_comp_neg.id%type) is
   select *
     from r_mcecf_bccsllcp
    where bccsllcompneg_id = en_bccsllcompneg_id;
   --
   cursor c_dados13 is
   select *
     from calc_csll_mes_estim
    where percalcapurlr_id = en_percalcapurlr_id
    order by 1;
   --
   cursor c_dados14 (en_calccsllmesestim_id calc_csll_mes_estim.id%type) is
   select *
     from r_mcecf_ccsllme
    where calccsllmesestim_id = en_calccsllmesestim_id;
   --
   cursor c_dados15 is
   select *
     from calc_csll_base_lr
    where percalcapurlr_id = en_percalcapurlr_id
    order by 1;
   --
   cursor c_dados16 (en_calccsllbaselr_id calc_csll_base_lr.id%type) is
   select *
     from r_mcecf_ccsllblr
    where calccsllbaselr_id = en_calccsllbaselr_id;
   --
begin
   --
   vn_fase := 1;
   --
   gt_log_generico.delete;
   --
   if nvl(en_percalcapurlr_id,0) > 0 then
      --
      vn_fase := 1.1;
      --
      pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
      --
      begin
         --
         select *
           into pk_csf_api_secf.gt_row_per_calc_apur_lr
           from per_calc_apur_lr
          where id = en_percalcapurlr_id;
         --
      exception
         when others then
            pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
      end;
      --
      vn_fase := 1.2;
      --
      if nvl(pk_csf_api_secf.gt_row_per_calc_apur_lr.id,0) > 0 then
         --
         pk_csf_api_secf.pkb_inicia_param ( en_aberturaecf_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id );
         --
         vn_fase := 1.3;
         -- Procedimento seta o objeto de referencia utilizado na Validação da Informação
         pk_csf_api_secf.pkb_seta_obj_ref ( ev_objeto => 'PER_CALC_APUR_LR' );
         --
         vn_fase := 1.4;
         -- Procedimento seta o "ID de Referencia" utilizado na Validação da Informação
         pk_csf_api_secf.pkb_seta_referencia_id ( en_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.id );
         --
         vn_fase := 1.5;
         --
         if nvl(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_situacao,0) in (3, 4) then -- Processada / Erro de validação
            --
            vn_dm_situacao := 1; -- Calculada
            --
         elsif nvl(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_situacao,0) in (1, 2) then -- Calculada / Erro no cálculo
            --
            vn_fase := 1.6;
            --
            for rec1 in c_dados1 loop
               exit when c_dados1%notfound or (c_dados1%notfound) is null;
               --
               vn_fase := 1.7;
               --
               for rec2 in c_dados2 (rec1.id) loop
                  exit when c_dados2%notfound or (c_dados2%notfound) is null;
                  --
                  vn_fase := 1.8;
                  --
                  delete from r_mcecf_birlrcp
                   where id = rec2.id;
                  --
                  vn_fase := 1.9;
                  --
                  -- Chama Procedimento para Excluir os Registros da Memómira de Cálculo do Sped ECF
                  pk_csf_api_secf.pkb_excluir_mem_calc_ecf ( en_memcalcecf_id => rec2.memcalcecf_id );
                  --
               end loop;
               --
               vn_fase := 1.10;
               --
               update bc_irpj_lr_comp_prej set valor = 0, dm_tipo = 0
                where id = rec1.id
                  and valor is not null;
               --
            end loop;
            --
            vn_fase := 2;
            --
            for rec3 in c_dados3 loop
               exit when c_dados3%notfound or (c_dados3%notfound) is null;
               --
               vn_fase := 2.1;
               --
               for rec4 in c_dados4 (rec3.id) loop
                  exit when c_dados4%notfound or (c_dados4%notfound) is null;
                  --
                  vn_fase := 2.2;
                  --
                  delete from r_mcecf_dle
                   where id = rec4.id;
                  --
                  vn_fase := 2.3;
                  --
                  -- Chama Procedimento para Excluir os Registros da Memómira de Cálculo do Sped ECF
                  pk_csf_api_secf.pkb_excluir_mem_calc_ecf ( en_memcalcecf_id => rec4.memcalcecf_id );
                  --
               end loop;
               --
               vn_fase := 2.4;
               --
               update dem_lucro_expl set valor = 0, dm_tipo = 0
                where id = rec3.id
                  and valor is not null;
               --
            end loop;
            --
            vn_fase := 3;
            --
            for rec5 in c_dados5 loop
               exit when c_dados5%notfound or (c_dados5%notfound) is null;
               --
               vn_fase := 3.1;
               --
               for rec6 in c_dados6 (rec5.id) loop
                  exit when c_dados6%notfound or (c_dados6%notfound) is null;
                  --
                  vn_fase := 3.2;
                  --
                  delete from r_mcecf_cirilr
                   where id = rec6.id;
                  --
                  vn_fase := 3.3;
                  --
                  -- Chama Procedimento para Excluir os Registros da Memómira de Cálculo do Sped ECF
                  pk_csf_api_secf.pkb_excluir_mem_calc_ecf ( en_memcalcecf_id => rec6.memcalcecf_id );
                  --
               end loop;
               --
               vn_fase := 3.4;
               --
               update calc_isen_red_imp_lr set valor = 0, dm_tipo = 0
                where id = rec5.id
                  and valor is not null;
               --
            end loop;
            --
            vn_fase := 4;
            --
            delete from INF_BC_INC_FISCAL
             where percalcapurlr_id = en_percalcapurlr_id;
            --
            vn_fase := 5;
            --
            for rec7 in c_dados7 loop
               exit when c_dados7%notfound or (c_dados7%notfound) is null;
               --
               vn_fase := 5.1;
               --
               for rec8 in c_dados8 (rec7.id) loop
                  exit when c_dados8%notfound or (c_dados8%notfound) is null;
                  --
                  vn_fase := 5.2;
                  --
                  delete from r_mcecf_cirpjme
                   where id = rec8.id;
                  --
                  vn_fase := 5.3;
                  --
                  -- Chama Procedimento para Excluir os Registros da Memómira de Cálculo do Sped ECF
                  pk_csf_api_secf.pkb_excluir_mem_calc_ecf ( en_memcalcecf_id => rec8.memcalcecf_id );
                  --
               end loop;
               --
               vn_fase := 5.4;
               --
               update calc_irpj_mes_estim set valor = 0, dm_tipo = 0
                where id = rec7.id
                  and valor is not null;
               --
            end loop;
            --
            vn_fase := 6;
            --
            for rec9 in c_dados9 loop
               exit when c_dados9%notfound or (c_dados9%notfound) is null;
               --
               vn_fase := 6.1;
               --
               for rec10 in c_dados10 (rec9.id) loop
                  exit when c_dados10%notfound or (c_dados10%notfound) is null;
                  --
                  vn_fase := 6.2;
                  --
                  delete from r_mcecf_cirpjblr
                   where id = rec10.id;
                  --
                  vn_fase := 6.3;
                  --
                  -- Chama Procedimento para Excluir os Registros da Memómira de Cálculo do Sped ECF
                  pk_csf_api_secf.pkb_excluir_mem_calc_ecf ( en_memcalcecf_id => rec10.memcalcecf_id );
                  --
               end loop;
               --
               vn_fase := 6.4;
               --
               update calc_irpj_base_lr set valor = 0, dm_tipo = 0
                where id = rec9.id
                  and valor is not null;
               --
            end loop;
            --
            vn_fase := 7;
            --
            for rec11 in c_dados11 loop
               exit when c_dados11%notfound or (c_dados11%notfound) is null;
               --
               vn_fase := 7.1;
               --
               for rec12 in c_dados12 (rec11.id) loop
                  exit when c_dados12%notfound or (c_dados12%notfound) is null;
                  --
                  vn_fase := 7.2;
                  --
                  delete from r_mcecf_bccsllcp
                   where id = rec12.id;
                  --
                  vn_fase := 7.3;
                  --
                  -- Chama Procedimento para Excluir os Registros da Memómira de Cálculo do Sped ECF
                  pk_csf_api_secf.pkb_excluir_mem_calc_ecf ( en_memcalcecf_id => rec12.memcalcecf_id );
                  --
               end loop;
               --
               vn_fase := 7.4;
               --
               update bc_csll_comp_neg set valor = 0, dm_tipo = 0
                where id = rec11.id
                  and valor is not null;
               --
            end loop;
            --
            vn_fase := 8;
            --
            for rec13 in c_dados13 loop
               exit when c_dados13%notfound or (c_dados13%notfound) is null;
               --
               vn_fase := 8.1;
               --
               for rec14 in c_dados14 (rec13.id) loop
                  exit when c_dados14%notfound or (c_dados14%notfound) is null;
                  --
                  vn_fase := 8.2;
                  --
                  delete from r_mcecf_ccsllme
                   where id = rec14.id;
                  --
                  vn_fase := 8.3;
                  --
                  -- Chama Procedimento para Excluir os Registros da Memómira de Cálculo do Sped ECF
                  pk_csf_api_secf.pkb_excluir_mem_calc_ecf ( en_memcalcecf_id => rec14.memcalcecf_id );
                  --
               end loop;
               --
               vn_fase := 8.4;
               --
               update calc_csll_mes_estim set valor = 0, dm_tipo = 0
                where id = rec13.id
                  and valor is not null;
               --
            end loop;
            --
            vn_fase := 9;
            --
            for rec15 in c_dados15 loop
               exit when c_dados15%notfound or (c_dados15%notfound) is null;
               --
               vn_fase := 9.1;
               --
               for rec16 in c_dados16 (rec15.id) loop
                  exit when c_dados16%notfound or (c_dados16%notfound) is null;
                  --
                  vn_fase := 9.2;
                  --
                  delete from r_mcecf_ccsllblr
                   where id = rec16.id;
                  --
                  vn_fase := 9.3;
                  --
                  -- Chama Procedimento para Excluir os Registros da Memómira de Cálculo do Sped ECF
                  pk_csf_api_secf.pkb_excluir_mem_calc_ecf ( en_memcalcecf_id => rec16.memcalcecf_id );
                  --
               end loop;
               --
               vn_fase := 9.4;
               --
               update calc_csll_base_lr set valor = 0, dm_tipo = 0
                where id = rec15.id
                  and valor is not null;
               --
            end loop;
            --
            vn_dm_situacao := 0; -- Aberto
            --
         else
            --
            vn_dm_situacao := 0; -- Aberto
            --
         end if;
         --
         vn_fase := 99;
         --
         update per_calc_apur_lr set dm_situacao = vn_dm_situacao
          where id = pk_csf_api_secf.gt_row_per_calc_apur_lr.id;
         --
         commit;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_desfazer fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_desfazer;

-------------------------------------------------------------------------------------------------------

-- Procedimento para somar os valores de Cálculo da CSLL Com Base no Lucro Real
procedure pkb_soma_vlr_ccsllblr
is
   --
   vn_fase number;
   --
   vn_valor calc_csll_base_lr.valor%type;
   vn_tipo  calc_csll_base_lr.dm_tipo%type;
   --
   cursor c_dados2 is
   select d.id                   calccsllbaselr_id
        , td.id                  tabdinecf_id
        , td.registroecf_id
        , td.cd                  tabdinecf_cd
        , td.ordem
     from calc_csll_base_lr      d
        , tab_din_ecf            td
    where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
      and td.id                  = d.tabdinecf_id
      and td.dm_tipo             in ('CA', 'CNA')
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados2 loop
      exit when c_dados2%notfound or (c_dados2%notfound) is null;
      --
      vn_fase := 5;
      --
      vn_valor := 0;
      --
      if rec.tabdinecf_cd = '1' then -- BASE DE CÁLCULO DA CSLL
         --
         vn_fase := 6;
         -- N650(1)
         begin
            select nvl( sum( d.valor ) ,0)
              into vn_valor
              from bc_csll_comp_neg       d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd                  = '1';
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '2' then -- Contribuição Social sobre o Lucro Líquido por Atividade
         --
         vn_fase := 7;
         --
         if pk_csf_api_secf.gv_versao_layout_ecf_cd = '100' then
            --
         /*
SE (N670(1) <= 0) ENTAO 0 
   SENAO 
      SE (0020.IND_ALIQ_CSLL() = "'S") ENTAO 
         N670(1) * 0,15 
      SENAO 
         N670(1) * 0,09
      FIM_SE 
FIM_SE
         */
            --
            declare
               --
               vn_n670_1 number;
               --
            begin
               --
               begin
                  select d.valor
                    into vn_n670_1
                    from calc_csll_base_lr      d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('1');
               exception
                  when others then
                     vn_n670_1 := 0;
               end;
               if nvl(vn_n670_1,0) <= 0 then
                  vn_valor := 0;
               else
                  if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = 'S' then
                     vn_valor := nvl(vn_n670_1,0) * 0.15;
                  else
                     vn_valor := nvl(vn_n670_1,0) * 0.09;
                  end if;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         elsif pk_csf_api_secf.gv_versao_layout_ecf_cd = '200' then
            --
/*
SE (N670(1)<=0) ENTAO 
   0 
SENAO 
   SE (PERIODO_ATUAL()="A00") ENTAO 
      SE (0020.IND_ALIQ_CSLL()="1") ENTAO 
         N670(1)*0,09
      SENAO
         SE (0020.IND_ALIQ_CSLL()="2") ENTAO
            SE (N670("0.53")=0) ENTAO
               N670(1)*0,17
            SENAO
               N670(1)*N670("0.55")/N670("0.53")*0,02+N670(1)*0,15
            FIM_SE
         SENAO
            SE (0020.IND_ALIQ_CSLL()="3") ENTAO
               SE (N670("0.53")=0) ENTAO
                  N670(1)*0,20
               SENAO
                  N670(1)*N670("0.54")/N670("0.53")*0,05+N670(1)*0,15
               FIM_SE
            FIM_SE
         FIM_SE
      FIM_SE 
   SENAO 
      SE (0020.IND_ALIQ_CSLL()="1") ENTAO
         N670(1)*0,09
      SENAO
         SE (PERIODO_ATUAL()<"T03") ENTAO
            N670(1)*0,15
         SENAO
            SE (PERIODO_ATUAL()="T04") ENTAO
               SE (0020.IND_ALIQ_CSLL()="2") ENTAO
                  N670(1)*0,17
               SENAO
                  SE (0020.IND_ALIQ_CSLL()="3") ENTAO
                     N670(1)*0,20
                  FIM_SE
               FIM_SE
            SENAO
               SE (0020.IND_ALIQ_CSLL()="2") ENTAO
                  N670(1)*0,15
               SENAO
                  SE (N670("0.51")=0) ENTAO
                     N670(1)*0,20
                  SENAO
                     N670(1)*N670("0.52")/N670("0.51")*0,05+N670(1)*0,15
                  FIM_SE
               FIM_SE
            FIM_SE
         FIM_SE
      FIM_SE 
   FIM_SE 
FIM_SE
*/
            --
            declare
               --
               vn_n670_051 number;
               vn_n670_052 number;
               vn_n670_053 number;
               vn_n670_054 number;
               vn_n670_055 number;
               vn_n670_1 number;
               --
            begin
               --
               begin
                  select sum( case when td.cd = '1' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.51' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.52' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.53' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.54' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.55' then nvl(d.valor,0) else 0 end )
                    into vn_n670_1
                       , vn_n670_051
                       , vn_n670_052
                       , vn_n670_053
                       , vn_n670_054
                       , vn_n670_055
                    from calc_csll_base_lr      d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('1', '0.51', '0.52', '0.53', '0.54', '0.55');
               exception
                  when others then
                     vn_n670_1 := 0;
                     vn_n670_051 := 0;
                     vn_n670_052 := 0;
                     vn_n670_053 := 0;
                     vn_n670_054 := 0;
                     vn_n670_055 := 0;
               end;
               --
               if nvl(vn_n670_1,0) <= 0 then
                  vn_valor := 0;
               else
                  --
                  if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A00' then
                     --
                     if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '1' then
                        --
                        vn_valor := nvl(vn_n670_1,0) * 0.09;
                        --
                     else
                        --
                        if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                           --
                           if nvl(vn_n670_053,0) = 0 then
                              vn_valor := nvl(vn_n670_1,0) * 0.17;
                           else
                              --N670(1)*N670("0.55")/N670("0.53")*0,02+N670(1)*0,15
                              vn_valor := (( ( nvl(vn_n670_1,0) * nvl(vn_n670_055,0) ) / nvl(vn_n670_053,0) ) * 0.02) + ( nvl(vn_n670_1,0) * 0.15 );
                              --
                           end if;
                           --
                        else
                           --
                           if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '3' then
                              --
                              if nvl(vn_n670_053,0) = 0 then
                                 vn_valor := nvl(vn_n670_1,0) * 0.20;
                              else
                                 --N670(1)*N670("0.54")/N670("0.53")*0,05+N670(1)*0,15
                                 vn_valor := (( ( nvl(vn_n670_1,0) * nvl(vn_n670_054,0) ) / nvl(vn_n670_053,0) ) * 0.05) + ( nvl(vn_n670_1,0) * 0.15 );
                                 --
                              end if;
                              --
                           end if;
                           --
                        end if;
                        --
                     end if;
                     --
                  else
                     --
                     if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '1' then
                        --
                        vn_valor := nvl(vn_n670_1,0) * 0.09;
                        --
                     else
                        --
                        if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur in ('T01', 'T02') then
                           vn_valor := nvl(vn_n670_1,0) * 0.15;
                        else
                           --
                           if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'T04' then
                              --
                              if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                                 vn_valor := nvl(vn_n670_1,0) * 0.17;
                              else
                                 --
                                 if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '3' then
                                    vn_valor := nvl(vn_n670_1,0) * 0.20;
                                 end if;
                                 --
                              end if;
                              --
                           else
                              --
                              if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                                 vn_valor := nvl(vn_n670_1,0) * 0.15;
                              else
                                 --
                                 if nvl(vn_n670_051,0) = 0 then
                                    vn_valor := nvl(vn_n670_1,0) * 0.20;
                                 else
                                    -- N670(1)*N670("0.52")/N670("0.51")*0,05+N670(1)*0,15
                                    vn_valor := (( ( nvl(vn_n670_1,0) * nvl(vn_n670_052,0) ) / nvl(vn_n670_051,0) ) * 0.05) + ( nvl(vn_n670_1,0) * 0.15 );
                                    --
                                 end if;
                                 --
                              end if;
                              --
                           end if;
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
                  vn_valor := 0;
            end;
            --
         else
            --
            /*
SE(0000.DT_FIN()<="2015-12-31") ENTAO
   SE(N670(1)<=0)ENTAO 
      0 
   SENAO 
      SE(PERIODO_ATUAL()="A00")ENTAO 
         SE(0020.IND_ALIQ_CSLL()="1")ENTAO 
            N670(1)*0,09 
         SENAO 
            SE(0020.IND_ALIQ_CSLL()="2")ENTAO 
               SE(N670("0.53")=0)ENTAO 
                  N670(1)*0,17 
               SENAO 
                  N670(1)*N670("0.55")/N670("0.53")*0,02+N670(1)*0,15 
               FIM_SE 
            SENAO 
               SE(N670("0.53")=0)ENTAO 
                  N670(1)*0,2 
               SENAO 
                  N670(1)*N670("0.54")/N670("0.53")*0,05+N670(1)*0,15 
               FIM_SE 
            FIM_SE 
         FIM_SE 
      SENAO 
         SE(0020.IND_ALIQ_CSLL()="1")ENTAO 
            N670(1)*0,09 
         SENAO 
            SE(PERIODO_ATUAL()<"T03")ENTAO 
               N670(1)*0,15 
            SENAO 
               SE(PERIODO_ATUAL()="T04")ENTAO 
                  SE(0020.IND_ALIQ_CSLL()="2")ENTAO 
                     N670(1)*0,17 
                  SENAO 
                     N670(1)*0,2
                  FIM_SE 
               SENAO 
                  SE(0020.IND_ALIQ_CSLL()="2")ENTAO 
                     N670(1)*0,15 
                  SENAO 
                     SE(N670("0.51")=0)ENTAO 
                        N670(1)*0,2 
                     SENAO N670(1)*N670("0.52")/N670("0.51")*0,05+N670(1)*0,15 
                     FIM_SE 
                  FIM_SE 
               FIM_SE 
            FIM_SE 
         FIM_SE 
      FIM_SE 
   FIM_SE 
SENAO 
   SE(N670(1)<=0)ENTAO 
      0 
   SENAO 
      SE(0020.IND_ALIQ_CSLL()="1")ENTAO 
         N670(1)*0,09 
      SENAO 
         SE(0020.IND_ALIQ_CSLL()="2")ENTAO 
            N670(1)*0,17 
         SENAO 
            N670(1)*0,2 
         FIM_SE 
      FIM_SE 
   FIM_SE 
FIM_SE
            */
            --
            declare
               --
               vn_n670_1 number;
               --
            begin
               --
               begin
                  select sum( case when td.cd = '1' then nvl(d.valor,0) else 0 end )
                    into vn_n670_1
                    from calc_csll_base_lr      d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('1');
               exception
                  when others then
                     vn_n670_1 := 0;
               end;
               --
               if nvl(vn_n670_1,0) <= 0 then
                  vn_valor := 0;
               else
                  --
                  if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '1' then
                     --
                     vn_valor := nvl(vn_n670_1,0) * 0.09;
                     --
                  else
                     --
                     if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                        vn_valor := nvl(vn_n670_1,0) * 0.17;
                     else
                        --
                        if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '3' then
                           vn_valor := nvl(vn_n670_1,0) * 0.20;
                        else
                           vn_valor := 0;
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
                  vn_valor := 0;
            end;
            --
         end if;
         --
      elsif rec.tabdinecf_cd = '4' then -- TOTAL DA CONTRIBUIÇÃO SOCIAL SOBRE O LUCRO LÍQUIDO
         --
         vn_fase := 8;
         -- N670(2) + N670(3)
         begin
            select nvl( sum( d.valor ) ,0)
              into vn_valor
              from calc_csll_base_lr      d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd                  in ('2', '3');
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '8' then -- (-) Isenção sobre o Lucro da Exploração Relativo ao Prouni
         --
         vn_fase := 9;
         --
         if pk_csf_api_secf.gv_versao_layout_ecf_cd = '100' then
            --
         /*
SE (N600(2) <= 0) ENTAO 
   0 
SENAO 
   SE (0020.IND_ALIQ_CSLL() = "'S") ENTAO 
      N600(2) * 0,15 
   SENAO 
      N600(2) * 0,09 
   FIM_SE 
FIM_SE
         */
            --
            declare
               --
               vn_n600_2 number;
               --
            begin
               --
               begin
                  select d.valor
                    into vn_n600_2
                    from dem_lucro_expl         d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('2');
               exception
                  when others then
                     vn_n600_2 := 0;
               end;
               --
               if nvl(vn_n600_2,0) <= 0 then
                  vn_valor := 0;
               else
                  if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = 'S' then
                     vn_valor := nvl(vn_n600_2,0) * 0.15;
                  else
                     vn_valor := nvl(vn_n600_2,0) * 0.09;
                  end if;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         else
            --
/*
SE (N610(1)<=0) ENTAO 
   0 
SENAO 
   SE (PERIODO_ATUAL()="A00") ENTAO 
      SE (0020.IND_ALIQ_CSLL()="1") ENTAO 
         N610(1)*0,09 
      SENAO 
         SE (0020.IND_ALIQ_CSLL()="2") ENTAO 
            SE (N670("0.53")=0) ENTAO 
               N610(1)*0,17 
            SENAO 
               N610(1)*N670("0.55")/N670("0.53")*0,02+N610(1)*0,15 
            FIM_SE 
         SENAO 
            SE (0020.IND_ALIQ_CSLL()="3") ENTAO 
               SE (N670("0.53")=0) ENTAO 
                  N610(1)*0,20 
               SENAO 
                  N610(1)*N670("0.54")/N670("0.53")*0,05+N610(1)*0,15 
               FIM_SE 
            FIM_SE 
         FIM_SE 
      FIM_SE 
   SENAO 
      SE (0020.IND_ALIQ_CSLL()="1") ENTAO 
         N610(1)*0,09 
      SENAO 
         SE (PERIODO_ATUAL() < "T03") ENTAO 
            N610(1)*0,15 
         SENAO 
            SE (PERIODO_ATUAL()="T04") ENTAO 
               SE (0020.IND_ALIQ_CSLL()="2") ENTAO 
                  N610(1)*0,17 
               SENAO 
                  SE (0020.IND_ALIQ_CSLL()="3") ENTAO 
                     N610(1)*0,20 
                  FIM_SE 
               FIM_SE 
            SENAO 
               SE (0020.IND_ALIQ_CSLL()="2") ENTAO 
                  N610(1)*0,15 
               SENAO 
                  SE (N670("0.51")=0) ENTAO 
                     N610(1)*0,20 
                  SENAO 
                     N610(1)*N670("0.52")/N670("0.51")*0,05+N610(1)*0,15 
                  FIM_SE 
               FIM_SE 
            FIM_SE 
         FIM_SE 
      FIM_SE 
   FIM_SE 
FIM_SE
*/
            --
            declare
               --
               vn_n670_051 number;
               vn_n670_052 number;
               vn_n670_053 number;
               vn_n670_054 number;
               vn_n670_055 number;
               vn_n610_1 number;
               --
            begin
               --
               begin
                  select sum( case when td.cd = '1' then nvl(d.valor,0) else 0 end )
                    into vn_n610_1
                    from calc_isen_red_imp_lr   d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('1');
               exception
                  when others then
                     vn_n610_1 := 0;
               end;
               --
               begin
                  select sum( case when td.cd = '0.51' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.52' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.53' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.54' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.55' then nvl(d.valor,0) else 0 end )
                    into vn_n670_051
                       , vn_n670_052
                       , vn_n670_053
                       , vn_n670_054
                       , vn_n670_055
                    from calc_csll_base_lr      d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('0.51', '0.52', '0.53', '0.54', '0.55');
               exception
                  when others then
                     vn_n670_051 := 0;
                     vn_n670_052 := 0;
                     vn_n670_053 := 0;
                     vn_n670_054 := 0;
                     vn_n670_055 := 0;
               end;
               --
               if nvl(vn_n610_1,0) <= 0 then
                  vn_valor := 0;
               else
                  --
                  if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A00' then
                     --
                     if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '1' then
                        --
                        vn_valor := nvl(vn_n610_1,0) * 0.09;
                        --
                     else
                        --
                        if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                           --
                           if nvl(vn_n670_053,0) = 0 then
                              vn_valor := nvl(vn_n610_1,0) * 0.17;
                           else
                              --N610(1)*N670("0.55")/N670("0.53")*0,02+N610(1)*0,15
                              vn_valor := (( ( nvl(vn_n610_1,0) * nvl(vn_n670_055,0) ) / nvl(vn_n670_053,0) ) * 0.02) + ( nvl(vn_n610_1,0) * 0.15 );
                              --
                           end if;
                           --
                        else
                           --
                           if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '3' then
                              --
                              if nvl(vn_n670_053,0) = 0 then
                                 vn_valor := nvl(vn_n610_1,0) * 0.20;
                              else
                                 --N610(1)*N670("0.54")/N670("0.53")*0,05+N610(1)*0,15
                                 vn_valor := (( ( nvl(vn_n610_1,0) * nvl(vn_n670_054,0) ) / nvl(vn_n670_053,0) ) * 0.05) + ( nvl(vn_n610_1,0) * 0.15 );
                                 --
                              end if;
                              --
                           end if;
                           --
                        end if;
                        --
                     end if;
                     --
                  else
                     --
                     if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '1' then
                        --
                        vn_valor := nvl(vn_n610_1,0) * 0.09;
                        --
                     else
                        --
                        if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur in ('T01', 'T02') then
                           vn_valor := nvl(vn_n610_1,0) * 0.15;
                        else
                           --
                           if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'T04' then
                              --
                              if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                                 vn_valor := nvl(vn_n610_1,0) * 0.17;
                              else
                                 --
                                 if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '3' then
                                    vn_valor := nvl(vn_n610_1,0) * 0.20;
                                 end if;
                                 --
                              end if;
                              --
                           else
                              --
                              if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                                 vn_valor := nvl(vn_n610_1,0) * 0.15;
                              else
                                 --
                                 if nvl(vn_n670_051,0) = 0 then
                                    vn_valor := nvl(vn_n610_1,0) * 0.20;
                                 else
                                    -- N610(1)*N670("0.52")/N670("0.51")*0,05+N610(1)*0,15
                                    vn_valor := (( ( nvl(vn_n610_1,0) * nvl(vn_n670_052,0) ) / nvl(vn_n670_051,0) ) * 0.05) + ( nvl(vn_n610_1,0) * 0.15 );
                                    --
                                 end if;
                                 --
                              end if;
                              --
                           end if;
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
                  vn_valor := 0;
            end;
            --
         end if;
         --
      elsif rec.tabdinecf_cd = '9' then -- (-) Isenção sobre o Lucro da Exploração de Eventos da Fifa
         --
         vn_fase := 10;
         --
         if pk_csf_api_secf.gv_versao_layout_ecf_cd = '100' then
            --
         /*
SE (N600(6) <= 0) ENTAO
   0
SENAO
   SE (0020.IND_ALIQ_CSLL() = "'S") ENTAO
      N600(6) * 0,15
   SENAO
      N600(6) * 0,09
   FIM_SE
FIM_SE
         */
            --
            declare
               --
               vn_n600_6 number;
               --
            begin
               --
               begin
                  select d.valor
                    into vn_n600_6
                    from dem_lucro_expl         d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('6');
               exception
                  when others then
                     vn_n600_6 := 0;
               end;
               --
               if nvl(vn_n600_6,0) <= 0 then
                  vn_valor := 0;
               else
                  if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = 'S' then
                     vn_valor := nvl(vn_n600_6,0) * 0.15;
                  else
                     vn_valor := nvl(vn_n600_6,0) * 0.09;
                  end if;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         else
            --
/*
SE (N610(21)<=0) ENTAO 
   0 
SENAO 
   SE (PERIODO_ATUAL()="A00") ENTAO 
      SE (0020.IND_ALIQ_CSLL()="1") ENTAO 
         N610(21)*0,09 
      SENAO 
         SE (0020.IND_ALIQ_CSLL()="2") ENTAO 
            SE (N670("0.53")=0) ENTAO 
               N610(21)*0,17 
            SENAO 
               N610(21)*N670("0.55")/N670("0.53")*0,02+N610(21)*0,15 
            FIM_SE 
         SENAO 
            SE (0020.IND_ALIQ_CSLL()="3") ENTAO 
               SE (N670("0.53")=0) ENTAO 
                  N610(21)*0,20 
               SENAO 
                  N610(21)*N670("0.54")/N670("0.53")*0,05+N610(21)*0,15 
               FIM_SE 
            FIM_SE 
         FIM_SE 
      FIM_SE 
   SENAO 
      SE (0020.IND_ALIQ_CSLL()="1") ENTAO 
         N610(21)*0,09 
      SENAO 
         SE (PERIODO_ATUAL()<"T03") ENTAO 
            N610(21)*0,15 
         SENAO 
            SE (PERIODO_ATUAL()="T04") ENTAO 
               SE (0020.IND_ALIQ_CSLL()="2") ENTAO 
                  N610(21)*0,17 
               SENAO 
                  SE (0020.IND_ALIQ_CSLL()="3") ENTAO 
                     N610(21)*0,20 
                  FIM_SE 
               FIM_SE 
            SENAO 
               SE (0020.IND_ALIQ_CSLL()="2") ENTAO 
                  N610(21)*0,15 
               SENAO
                  SE (N670("0.51")=0) ENTAO 
                     N610(21)*0,20 
                  SENAO 
                     N610(21)*N670("0.52")/N670("0.51")*0,05+N610(21)*0,15 
                  FIM_SE 
               FIM_SE 
            FIM_SE 
         FIM_SE 
      FIM_SE 
   FIM_SE 
FIM_SE
*/
            --
            declare
               --
               vn_n670_051 number;
               vn_n670_052 number;
               vn_n670_053 number;
               vn_n670_054 number;
               vn_n670_055 number;
               vn_n610_21 number;
               --
            begin
               --
               begin
                  select sum( case when td.cd = '21' then nvl(d.valor,0) else 0 end )
                    into vn_n610_21
                    from calc_isen_red_imp_lr   d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('21');
               exception
                  when others then
                     vn_n610_21 := 0;
               end;
               --
               begin
                  select sum( case when td.cd = '0.51' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.52' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.53' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.54' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.55' then nvl(d.valor,0) else 0 end )
                    into vn_n670_051
                       , vn_n670_052
                       , vn_n670_053
                       , vn_n670_054
                       , vn_n670_055
                    from calc_csll_base_lr      d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('0.51', '0.52', '0.53', '0.54', '0.55');
               exception
                  when others then
                     vn_n670_051 := 0;
                     vn_n670_052 := 0;
                     vn_n670_053 := 0;
                     vn_n670_054 := 0;
                     vn_n670_055 := 0;
               end;
               --
               if nvl(vn_n610_21,0) <= 0 then
                  vn_valor := 0;
               else
                  --
                  if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A00' then
                     --
                     if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '1' then
                        --
                        vn_valor := nvl(vn_n610_21,0) * 0.09;
                        --
                     else
                        --
                        if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                           --
                           if nvl(vn_n670_053,0) = 0 then
                              vn_valor := nvl(vn_n610_21,0) * 0.17;
                           else
                              --N610(21)*N670("0.55")/N670("0.53")*0,02+N610(21)*0,15
                              vn_valor := (( ( nvl(vn_n610_21,0) * nvl(vn_n670_055,0) ) / nvl(vn_n670_053,0) ) * 0.02) + ( nvl(vn_n610_21,0) * 0.15 );
                              --
                           end if;
                           --
                        else
                           --
                           if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '3' then
                              --
                              if nvl(vn_n670_053,0) = 0 then
                                 vn_valor := nvl(vn_n610_21,0) * 0.20;
                              else
                                 --N610(21)*N670("0.54")/N670("0.53")*0,05+N610(21)*0,15
                                 vn_valor := (( ( nvl(vn_n610_21,0) * nvl(vn_n670_054,0) ) / nvl(vn_n670_053,0) ) * 0.05) + ( nvl(vn_n610_21,0) * 0.15 );
                                 --
                              end if;
                              --
                           end if;
                           --
                        end if;
                        --
                     end if;
                     --
                  else
                     --
                     if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '1' then
                        --
                        vn_valor := nvl(vn_n610_21,0) * 0.09;
                        --
                     else
                        --
                        if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur in ('T01', 'T02') then
                           vn_valor := nvl(vn_n610_21,0) * 0.15;
                        else
                           --
                           if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'T04' then
                              --
                              if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                                 vn_valor := nvl(vn_n610_21,0) * 0.17;
                              else
                                 --
                                 if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '3' then
                                    vn_valor := nvl(vn_n610_21,0) * 0.20;
                                 end if;
                                 --
                              end if;
                              --
                           else
                              --
                              if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                                 vn_valor := nvl(vn_n610_21,0) * 0.15;
                              else
                                 --
                                 if nvl(vn_n670_051,0) = 0 then
                                    vn_valor := nvl(vn_n610_21,0) * 0.20;
                                 else
                                    -- N610(21)*N670("0.52")/N670("0.51")*0,05+N610(21)*0,15
                                    vn_valor := (( ( nvl(vn_n610_21,0) * nvl(vn_n670_052,0) ) / nvl(vn_n670_051,0) ) * 0.05) + ( nvl(vn_n610_21,0) * 0.15 );
                                    --
                                 end if;
                                 --
                              end if;
                              --
                           end if;
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
                  vn_valor := 0;
            end;
            --
         end if;
         --
      elsif rec.tabdinecf_cd = '10' then -- (-) Isenção sobre o Lucro da Exploração da Atividade de Serviços SPE Eventos da Fifa
         --
         vn_fase := 11;
         --
         if pk_csf_api_secf.gv_versao_layout_ecf_cd = '100' then
            --
         /*
SE (N600(7) <= 0) ENTAO
   0
SENAO
   SE (0020.IND_ALIQ_CSLL() = "'S") ENTAO
      N600(7) * 0,15
   SENAO
      N600(7) * 0,09
   FIM_SE 
FIM_SE
         */
            --
            declare
               --
               vn_n600_7 number;
               --
            begin
               --
               begin
                  select d.valor
                    into vn_n600_7
                    from dem_lucro_expl         d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('7');
               exception
                  when others then
                     vn_n600_7 := 0;
               end;
               --
               if nvl(vn_n600_7,0) <= 0 then
                  vn_valor := 0;
               else
                  if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = 'S' then
                     vn_valor := nvl(vn_n600_7,0) * 0.15;
                  else
                     vn_valor := nvl(vn_n600_7,0) * 0.09;
                  end if;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         else
            --
/*
SE (N610(26)<=0) ENTAO 
   0 
SENAO 
   SE (PERIODO_ATUAL()="A00") ENTAO 
      SE (0020.IND_ALIQ_CSLL()="1") ENTAO 
         N610(26)*0,09 
      SENAO 
         SE (0020.IND_ALIQ_CSLL()="2") ENTAO 
            SE (N670("0.53")=0) ENTAO 
               N610(26)*0,17 
            SENAO 
               N610(26)*N670("0.55")/N670("0.53")*0,02+N610(26)*0,15 
            FIM_SE 
         SENAO 
            SE (0020.IND_ALIQ_CSLL()="3") ENTAO 
               SE (N670("0.53")=0) ENTAO 
                  N610(26)*0,20 
               SENAO 
                  N610(26)*N670("0.54")/N670("0.53")*0,05+N610(26)*0,15 
               FIM_SE 
            FIM_SE 
         FIM_SE 
      FIM_SE 
   SENAO 
      SE (0020.IND_ALIQ_CSLL()="1") ENTAO 
         N610(26)*0,09 
      SENAO 
         SE (PERIODO_ATUAL()<"T03") ENTAO 
            N610(26)*0,15 
         SENAO 
            SE (PERIODO_ATUAL()="T04") ENTAO 
               SE (0020.IND_ALIQ_CSLL()="2") ENTAO 
                  N610(26)*0,17 
               SENAO 
                  SE (0020.IND_ALIQ_CSLL()="3") ENTAO 
                     N610(26)*0,20 
                  FIM_SE 
               FIM_SE 
            SENAO 
               SE (0020.IND_ALIQ_CSLL()="2") ENTAO 
                  N610(26)*0,15 
               SENAO 
                  SE (N670("0.51")=0) ENTAO 
                     N610(26)*0,20 
                  SENAO 
                     N610(26)*N670("0.52")/N670("0.51")*0,05+N610(26)*0,15 
                  FIM_SE 
               FIM_SE 
            FIM_SE 
         FIM_SE 
      FIM_SE 
   FIM_SE 
FIM_SE
*/
            --
            declare
               --
               vn_n670_051 number;
               vn_n670_052 number;
               vn_n670_053 number;
               vn_n670_054 number;
               vn_n670_055 number;
               vn_n610_26 number;
               --
            begin
               --
               begin
                  select sum( case when td.cd = '26' then nvl(d.valor,0) else 0 end )
                    into vn_n610_26
                    from calc_isen_red_imp_lr   d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('26');
               exception
                  when others then
                     vn_n610_26 := 0;
               end;
               --
               begin
                  select sum( case when td.cd = '0.51' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.52' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.53' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.54' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.55' then nvl(d.valor,0) else 0 end )
                    into vn_n670_051
                       , vn_n670_052
                       , vn_n670_053
                       , vn_n670_054
                       , vn_n670_055
                    from calc_csll_base_lr      d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('0.51', '0.52', '0.53', '0.54', '0.55');
               exception
                  when others then
                     vn_n670_051 := 0;
                     vn_n670_052 := 0;
                     vn_n670_053 := 0;
                     vn_n670_054 := 0;
                     vn_n670_055 := 0;
               end;
               --
               if nvl(vn_n610_26,0) <= 0 then
                  vn_valor := 0;
               else
                  --
                  if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A00' then
                     --
                     if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '1' then
                        --
                        vn_valor := nvl(vn_n610_26,0) * 0.09;
                        --
                     else
                        --
                        if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                           --
                           if nvl(vn_n670_053,0) = 0 then
                              vn_valor := nvl(vn_n610_26,0) * 0.17;
                           else
                              --N610(26)*N670("0.55")/N670("0.53")*0,02+N610(26)*0,15
                              vn_valor := (( ( nvl(vn_n610_26,0) * nvl(vn_n670_055,0) ) / nvl(vn_n670_053,0) ) * 0.02) + ( nvl(vn_n610_26,0) * 0.15 );
                              --
                           end if;
                           --
                        else
                           --
                           if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '3' then
                              --
                              if nvl(vn_n670_053,0) = 0 then
                                 vn_valor := nvl(vn_n610_26,0) * 0.20;
                              else
                                 --N610(26)*N670("0.54")/N670("0.53")*0,05+N610(26)*0,15
                                 vn_valor := (( ( nvl(vn_n610_26,0) * nvl(vn_n670_054,0) ) / nvl(vn_n670_053,0) ) * 0.05) + ( nvl(vn_n610_26,0) * 0.15 );
                                 --
                              end if;
                              --
                           end if;
                           --
                        end if;
                        --
                     end if;
                     --
                  else
                     --
                     if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '1' then
                        --
                        vn_valor := nvl(vn_n610_26,0) * 0.09;
                        --
                     else
                        --
                        if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur in ('T01', 'T02') then
                           vn_valor := nvl(vn_n610_26,0) * 0.15;
                        else
                           --
                           if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'T04' then
                              --
                              if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                                 vn_valor := nvl(vn_n610_26,0) * 0.17;
                              else
                                 --
                                 if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '3' then
                                    vn_valor := nvl(vn_n610_26,0) * 0.20;
                                 end if;
                                 --
                              end if;
                              --
                           else
                              --
                              if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                                 vn_valor := nvl(vn_n610_26,0) * 0.15;
                              else
                                 --
                                 if nvl(vn_n670_051,0) = 0 then
                                    vn_valor := nvl(vn_n610_26,0) * 0.20;
                                 else
                                    -- N610(26)*N670("0.52")/N670("0.51")*0,05+N610(26)*0,15
                                    vn_valor := (( ( nvl(vn_n610_26,0) * nvl(vn_n670_052,0) ) / nvl(vn_n670_051,0) ) * 0.05) + ( nvl(vn_n610_26,0) * 0.15 );
                                    --
                                 end if;
                                 --
                              end if;
                              --
                           end if;
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
                  vn_valor := 0;
            end;
            --
         end if;
         --
      elsif rec.tabdinecf_cd = '11' then -- (-) Isenção sobre o Lucro da Exploração de Eventos do CIO
         --
         vn_fase := 12;
         --
         if pk_csf_api_secf.gv_versao_layout_ecf_cd = '100' then
            --
         /*
SE (N600(8) <= 0) ENTAO
   0
SENAO
   SE (0020.IND_ALIQ_CSLL() = "'S") ENTAO
      N600(8) * 0,15
   SENAO
      N600(8) * 0,09
   FIM_SE 
FIM_SE
         */
            --
            declare
               --
               vn_n600_8 number;
               --
            begin
               --
               begin
                  select d.valor
                    into vn_n600_8
                    from dem_lucro_expl         d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('8');
               exception
                  when others then
                     vn_n600_8 := 0;
               end;
               --
               if nvl(vn_n600_8,0) <= 0 then
                  vn_valor := 0;
               else
                  if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = 'S' then
                     vn_valor := nvl(vn_n600_8,0) * 0.15;
                  else
                     vn_valor := nvl(vn_n600_8,0) * 0.09;
                  end if;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         else
            --
/*
SE (N610(31)<=0) ENTAO 
   0 
SENAO 
   SE (PERIODO_ATUAL()="A00") ENTAO 
      SE (0020.IND_ALIQ_CSLL()="1") ENTAO 
         N610(31)*0,09 
      SENAO 
         SE (0020.IND_ALIQ_CSLL()="2") ENTAO 
            SE (N670("0.53")=0) ENTAO 
               N610(31)*0,17 
            SENAO 
               N610(31)*N670("0.55")/N670("0.53")*0,02+N610(31)*0,15 
            FIM_SE 
         SENAO 
            SE (0020.IND_ALIQ_CSLL()="3") ENTAO 
               SE (N670("0.53")=0) ENTAO 
                  N610(31)*0,20 
               SENAO 
                  N610(31)*N670("0.54")/N670("0.53")*0,05+N610(31)*0,15 
               FIM_SE 
            FIM_SE 
         FIM_SE 
      FIM_SE 
   SENAO 
      SE (0020.IND_ALIQ_CSLL()="1") ENTAO 
         N610(31)*0,09 
      SENAO 
         SE (PERIODO_ATUAL()<"T03") ENTAO 
            N610(31)*0,15 
         SENAO 
            SE (PERIODO_ATUAL()="T04") ENTAO 
               SE (0020.IND_ALIQ_CSLL()="2") ENTAO 
                  N610(31)*0,17 
               SENAO 
                  SE (0020.IND_ALIQ_CSLL()="3") ENTAO 
                     N610(31)*0,20 
                  FIM_SE 
               FIM_SE 
            SENAO 
               SE (0020.IND_ALIQ_CSLL()="2") ENTAO 
                  N610(31)*0,15 
               SENAO 
                  SE (N670("0.51")=0) ENTAO 
                     N610(31)*0,20 
                  SENAO 
                     N610(31)*N670("0.52")/N670("0.51")*0,05+N610(31)*0,15 
                  FIM_SE 
               FIM_SE 
            FIM_SE 
         FIM_SE 
      FIM_SE 
   FIM_SE 
FIM_SE
*/
            --
            declare
               --
               vn_n670_051 number;
               vn_n670_052 number;
               vn_n670_053 number;
               vn_n670_054 number;
               vn_n670_055 number;
               vn_n610_31 number;
               --
            begin
               --
               begin
                  select sum( case when td.cd = '31' then nvl(d.valor,0) else 0 end )
                    into vn_n610_31
                    from calc_isen_red_imp_lr   d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('31');
               exception
                  when others then
                     vn_n610_31 := 0;
               end;
               --
               begin
                  select sum( case when td.cd = '0.51' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.52' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.53' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.54' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.55' then nvl(d.valor,0) else 0 end )
                    into vn_n670_051
                       , vn_n670_052
                       , vn_n670_053
                       , vn_n670_054
                       , vn_n670_055
                    from calc_csll_base_lr      d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('0.51', '0.52', '0.53', '0.54', '0.55');
               exception
                  when others then
                     vn_n670_051 := 0;
                     vn_n670_052 := 0;
                     vn_n670_053 := 0;
                     vn_n670_054 := 0;
                     vn_n670_055 := 0;
               end;
               --
               if nvl(vn_n610_31,0) <= 0 then
                  vn_valor := 0;
               else
                  --
                  if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A00' then
                     --
                     if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '1' then
                        --
                        vn_valor := nvl(vn_n610_31,0) * 0.09;
                        --
                     else
                        --
                        if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                           --
                           if nvl(vn_n670_053,0) = 0 then
                              vn_valor := nvl(vn_n610_31,0) * 0.17;
                           else
                              --N610(31)*N670("0.55")/N670("0.53")*0,02+N610(31)*0,15
                              vn_valor := (( ( nvl(vn_n610_31,0) * nvl(vn_n670_055,0) ) / nvl(vn_n670_053,0) ) * 0.02) + ( nvl(vn_n610_31,0) * 0.15 );
                              --
                           end if;
                           --
                        else
                           --
                           if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '3' then
                              --
                              if nvl(vn_n670_053,0) = 0 then
                                 vn_valor := nvl(vn_n610_31,0) * 0.20;
                              else
                                 --N610(31)*N670("0.54")/N670("0.53")*0,05+N610(31)*0,15
                                 vn_valor := (( ( nvl(vn_n610_31,0) * nvl(vn_n670_054,0) ) / nvl(vn_n670_053,0) ) * 0.05) + ( nvl(vn_n610_31,0) * 0.15 );
                                 --
                              end if;
                              --
                           end if;
                           --
                        end if;
                        --
                     end if;
                     --
                  else
                     --
                     if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '1' then
                        --
                        vn_valor := nvl(vn_n610_31,0) * 0.09;
                        --
                     else
                        --
                        if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur in ('T01', 'T02') then
                           vn_valor := nvl(vn_n610_31,0) * 0.15;
                        else
                           --
                           if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'T04' then
                              --
                              if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                                 vn_valor := nvl(vn_n610_31,0) * 0.17;
                              else
                                 --
                                 if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '3' then
                                    vn_valor := nvl(vn_n610_31,0) * 0.20;
                                 end if;
                                 --
                              end if;
                              --
                           else
                              --
                              if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                                 vn_valor := nvl(vn_n610_31,0) * 0.15;
                              else
                                 --
                                 if nvl(vn_n670_051,0) = 0 then
                                    vn_valor := nvl(vn_n610_31,0) * 0.20;
                                 else
                                    -- N610(31)*N670("0.52")/N670("0.51")*0,05+N610(31)*0,15
                                    vn_valor := (( ( nvl(vn_n610_31,0) * nvl(vn_n670_052,0) ) / nvl(vn_n670_051,0) ) * 0.05) + ( nvl(vn_n610_31,0) * 0.15 );
                                    --
                                 end if;
                                 --
                              end if;
                              --
                           end if;
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
                  vn_valor := 0;
            end;
            --
         end if;
         --
      elsif rec.tabdinecf_cd = '12' then -- (-) Isenção sobre o Lucro da Exploração da Atividade de Serviços - SPE - Eventos do CIO
         --
         vn_fase := 13;
         --
         if pk_csf_api_secf.gv_versao_layout_ecf_cd = '100' then
            --
         /*
SE (N600(9) <= 0) ENTAO
   0
SENAO
   SE (0020.IND_ALIQ_CSLL() = "'S") ENTAO
      N600(9) * 0,15
   SENAO
      N600(9) * 0,09
   FIM_SE 
FIM_SE
         */
            --
            declare
               --
               vn_n600_9 number;
               --
            begin
               --
               begin
                  select d.valor
                    into vn_n600_9
                    from dem_lucro_expl         d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('9');
               exception
                  when others then
                     vn_n600_9 := 0;
               end;
               --
               if nvl(vn_n600_9,0) <= 0 then
                  vn_valor := 0;
               else
                  if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = 'S' then
                     vn_valor := nvl(vn_n600_9,0) * 0.15;
                  else
                     vn_valor := nvl(vn_n600_9,0) * 0.09;
                  end if;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         else
            --
/*
SE (N610(36)<=0) ENTAO 
   0 
SENAO 
   SE (PERIODO_ATUAL()="A00") ENTAO 
      SE (0020.IND_ALIQ_CSLL()="1") ENTAO 
         N610(36)*0,09 
      SENAO 
         SE (0020.IND_ALIQ_CSLL()="2") ENTAO 
            SE (N670("0.53")=0) ENTAO 
               N610(36)*0,17 
            SENAO 
               N610(36)*N670("0.55")/N670("0.53")*0,02+N610(36)*0,15 
            FIM_SE 
         SENAO 
            SE (0020.IND_ALIQ_CSLL()="3") ENTAO 
               SE (N670("0.53")=0) ENTAO 
                  N610(36)*0,20 
               SENAO 
                  N610(36)*N670("0.54")/N670("0.53")*0,05+N610(36)*0,15 
               FIM_SE 
            FIM_SE 
         FIM_SE 
      FIM_SE 
   SENAO 
      SE (0020.IND_ALIQ_CSLL()="1") ENTAO 
         N610(36)*0,09 
      SENAO 
         SE (PERIODO_ATUAL()<"T03") ENTAO 
            N610(36)*0,15 
         SENAO 
            SE (PERIODO_ATUAL()="T04") ENTAO 
               SE (0020.IND_ALIQ_CSLL()="2") ENTAO 
                  N610(36)*0,17 
               SENAO 
                  SE (0020.IND_ALIQ_CSLL()="3") ENTAO 
                     N610(36)*0,20 
                  FIM_SE 
               FIM_SE 
            SENAO 
               SE (0020.IND_ALIQ_CSLL()="2") ENTAO 
                  N610(36)*0,15 
               SENAO 
                  SE (N670("0.51")=0) ENTAO 
                     N610(36)*0,20 
                  SENAO 
                     N610(36)*N670("0.52")/N670("0.51")*0,05+N610(36)*0,15 
                  FIM_SE 
               FIM_SE 
            FIM_SE 
         FIM_SE 
      FIM_SE 
   FIM_SE 
FIM_SE
*/
            --
            declare
               --
               vn_n670_051 number;
               vn_n670_052 number;
               vn_n670_053 number;
               vn_n670_054 number;
               vn_n670_055 number;
               vn_n610_36 number;
               --
            begin
               --
               begin
                  select sum( case when td.cd = '36' then nvl(d.valor,0) else 0 end )
                    into vn_n610_36
                    from calc_isen_red_imp_lr   d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('36');
               exception
                  when others then
                     vn_n610_36 := 0;
               end;
               --
               begin
                  select sum( case when td.cd = '0.51' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.52' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.53' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.54' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.55' then nvl(d.valor,0) else 0 end )
                    into vn_n670_051
                       , vn_n670_052
                       , vn_n670_053
                       , vn_n670_054
                       , vn_n670_055
                    from calc_csll_base_lr      d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('0.51', '0.52', '0.53', '0.54', '0.55');
               exception
                  when others then
                     vn_n670_051 := 0;
                     vn_n670_052 := 0;
                     vn_n670_053 := 0;
                     vn_n670_054 := 0;
                     vn_n670_055 := 0;
               end;
               --
               if nvl(vn_n610_36,0) <= 0 then
                  vn_valor := 0;
               else
                  --
                  if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A00' then
                     --
                     if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '1' then
                        --
                        vn_valor := nvl(vn_n610_36,0) * 0.09;
                        --
                     else
                        --
                        if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                           --
                           if nvl(vn_n670_053,0) = 0 then
                              vn_valor := nvl(vn_n610_36,0) * 0.17;
                           else
                              --N610(36)*N670("0.55")/N670("0.53")*0,02+N610(36)*0,15
                              vn_valor := (( ( nvl(vn_n610_36,0) * nvl(vn_n670_055,0) ) / nvl(vn_n670_053,0) ) * 0.02) + ( nvl(vn_n610_36,0) * 0.15 );
                              --
                           end if;
                           --
                        else
                           --
                           if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '3' then
                              --
                              if nvl(vn_n670_053,0) = 0 then
                                 vn_valor := nvl(vn_n610_36,0) * 0.20;
                              else
                                 --N610(36)*N670("0.54")/N670("0.53")*0,05+N610(36)*0,15
                                 vn_valor := (( ( nvl(vn_n610_36,0) * nvl(vn_n670_054,0) ) / nvl(vn_n670_053,0) ) * 0.05) + ( nvl(vn_n610_36,0) * 0.15 );
                                 --
                              end if;
                              --
                           end if;
                           --
                        end if;
                        --
                     end if;
                     --
                  else
                     --
                     if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '1' then
                        --
                        vn_valor := nvl(vn_n610_36,0) * 0.09;
                        --
                     else
                        --
                        if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur in ('T01', 'T02') then
                           vn_valor := nvl(vn_n610_36,0) * 0.15;
                        else
                           --
                           if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'T04' then
                              --
                              if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                                 vn_valor := nvl(vn_n610_36,0) * 0.17;
                              else
                                 --
                                 if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '3' then
                                    vn_valor := nvl(vn_n610_36,0) * 0.20;
                                 end if;
                                 --
                              end if;
                              --
                           else
                              --
                              if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                                 vn_valor := nvl(vn_n610_36,0) * 0.15;
                              else
                                 --
                                 if nvl(vn_n670_051,0) = 0 then
                                    vn_valor := nvl(vn_n610_36,0) * 0.20;
                                 else
                                    -- N610(36)*N670("0.52")/N670("0.51")*0,05+N610(36)*0,15
                                    vn_valor := (( ( nvl(vn_n610_36,0) * nvl(vn_n670_052,0) ) / nvl(vn_n670_051,0) ) * 0.05) + ( nvl(vn_n610_36,0) * 0.15 );
                                    --
                                 end if;
                                 --
                              end if;
                              --
                           end if;
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
                  vn_valor := 0;
            end;
            --
         end if;
         --
      elsif rec.tabdinecf_cd = '21' then -- CSLL A PAGAR
         --
         vn_fase := 14;
         -- N670(4) - SOMA(N670(6:20))
         declare
            --
            vn_vl_1 number;
            vn_vl_2 number;
            --
         begin
            --
            vn_fase := 14.1;
            --
            begin
               select d.valor
                 into vn_vl_1
                 from calc_csll_base_lr      d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('4');
            exception
               when others then
                  vn_vl_1 := 0;
            end;
            --
            vn_fase := 14.2;
            --
            begin
               select sum( d.valor )
                 into vn_vl_2
                 from calc_csll_base_lr      d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) between 6 and 20;
            exception
               when others then
                  vn_vl_2 := 0;
            end;
            --
            vn_valor := nvl(vn_vl_1,0) - nvl(vn_vl_2,0);
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      end if;
      --
      vn_fase := 99;
      --
      update calc_csll_base_lr set valor    = nvl(vn_valor,0)
                                 , dm_tipo  = 1 -- Calculado
       where id = rec.calccsllbaselr_id;
      --
      commit;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_soma_vlr_ccsllblr fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_soma_vlr_ccsllblr;

-------------------------------------------------------------------------------------------------------

-- Procedimento de atualizar os valores de Cálculo da CSLL Com Base no Lucro Real
procedure pkb_atual_vlr_ccsllblr ( en_percalcapurlr_id  in per_calc_apur_lr.id%type )
is
   --
   vn_fase number;
   vn_loggenerico_id  log_generico.id%type;
   --
   vv_dominio_descr Dominio.descr%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   gt_log_generico.delete;
   --
   if nvl(en_percalcapurlr_id,0) > 0 then
      --
      vn_fase := 2;
      --
      pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
      --
      begin
         --
         select *
           into pk_csf_api_secf.gt_row_per_calc_apur_lr
           from per_calc_apur_lr
          where id = en_percalcapurlr_id;
         --
      exception
         when others then
            pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
      end;
      --
      vn_fase := 3;
      --
      if nvl(pk_csf_api_secf.gt_row_per_calc_apur_lr.id,0) > 0 then
         --
         pk_csf_api_secf.pkb_inicia_param ( en_aberturaecf_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id );
         --
         vn_fase := 4;
         -- Procedimento seta o objeto de referencia utilizado na Validação da Informação
         pk_csf_api_secf.pkb_seta_obj_ref ( ev_objeto => 'PER_CALC_APUR_LR' );
         --
         vn_fase := 4.1;
         -- Procedimento seta o "ID de Referencia" utilizado na Validação da Informação
         pk_csf_api_secf.pkb_seta_referencia_id ( en_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.id );
         --
         vn_fase := 5;
         --
         -- Chama Procedimento para somar os valores de Cálculo da CSLL Com Base no Lucro Real
         pkb_soma_vlr_ccsllblr;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_atual_vlr_ccsllblr fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_atual_vlr_ccsllblr;

-------------------------------------------------------------------------------------------------------

-- Procedimento para somar os valores de Cálculo da CSLL Mensal por Estimativa
procedure pkb_soma_vlr_ccsllme
is
   --
   vn_fase number;
   --
   vn_valor bc_csll_comp_neg.valor%type;
   vn_tipo  bc_csll_comp_neg.dm_tipo%type;
   --
   cursor c_dados2 is
   select d.id                   calccsllmesestim_id
        , td.id                  tabdinecf_id
        , td.registroecf_id
        , td.cd                  tabdinecf_cd
        , td.ordem
     from calc_csll_mes_estim    d
        , tab_din_ecf            td
    where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
      and td.id                  = d.tabdinecf_id
      and td.dm_tipo             in ('CA', 'CNA')
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados2 loop
      exit when c_dados2%notfound or (c_dados2%notfound) is null;
      --
      vn_fase := 5;
      --
      vn_valor := 0;
      --
      if rec.tabdinecf_cd = '2' then -- Base de Cálculo da CSLL
         --
         vn_fase := 6;
         -- SE (0010.MES_BAL_RED() = "B") ENTAO N650(1) SENAO N650(2) FIM_SE
         declare
            --
            vn_n500_1 number;
            vn_n500_2 number;
            --
         begin
            --
            vn_fase := 6.1;
            --
            begin
               select nvl( sum( case when td.cd = '1' then d.valor else 0 end ) ,0)
                    , nvl( sum( case when td.cd = '2' then d.valor else 0 end ) ,0)
                 into vn_n500_1
                    , vn_n500_2
                 from BC_CSLL_COMP_NEG       d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('1', '2');
            exception
               when others then
                  vn_n500_1 := 0;
                  vn_n500_2 := 0;
            end;
            --
            vn_fase := 6.2;
            --
            if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A01' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red1 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A02' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red2 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A03' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red3 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A04' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red4 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A05' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red5 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A06' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red6 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A07' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red7 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A08' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red8 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A09' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red9 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A10' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red10 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A11' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red11 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A12' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red12 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            else
               vn_valor := 0;
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '3' then -- CSLL Apurada
         --
         vn_fase := 7;
         --
         if pk_csf_api_secf.gv_versao_layout_ecf_cd = '100' then
            --
         /*
SE (N660(2) <= 0) ENTAO
   0
SENAO 
   SE (0020.IND_ALIQ_CSLL() = "S") ENTAO 
      N660(2) * 0,15
   SENAO
      N660(2) * 0,09
   FIM_SE 
FIM_SE
         */
            declare
               --
               vn_n660_2 number;
               --
            begin
               --
               begin
                  select d.valor
                    into vn_n660_2
                    from calc_csll_mes_estim    d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('2');
               exception
                  when others then
                     vn_n660_2 := 0;
               end;
               --
               if nvl(vn_n660_2,0) <= 0 then
                  vn_valor := 0;
               else
                  if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = 'S' then
                     vn_valor := nvl(vn_n660_2,0) * 0.15;
                  else
                     vn_valor := nvl(vn_n660_2,0) * 0.09;
                  end if;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         elsif pk_csf_api_secf.gv_versao_layout_ecf_cd = '200' then
            --
/*
SE (N660(2)<=0) ENTAO 
   0 
SENAO 
   SE (0020.IND_ALIQ_CSLL() = "1") ENTAO
      N660(2)*0,09
   SENAO
      SE (0020.IND_ALIQ_CSLL() = "2") ENTAO
         SE (PERIODO_ATUAL() < "A10") ENTAO
            N660(2)*0,15
         SENAO
            SE (N660("0.53")=0) ENTAO
               N660(2)*0,17
            SENAO
               N660(2)*N660("0.55")/N660("0.53")*0,02+N660(2)*0,15
            FIM_SE
         FIM_SE
      SENAO
         SE (0020.IND_ALIQ_CSLL() = "3") ENTAO
            SE (PERIODO_ATUAL() < "A09") ENTAO
               N660(2)*0,15
            SENAO
               SE (N660("0.53")=0) ENTAO
                  N660(2)*0,20
               SENAO
                  N660(2)*N660("0.54")/N660(" 0.53")*0,05+N660(2)*0,15
               FIM_SE
            FIM_SE
         FIM_SE
      FIM_SE
   FIM_SE
FIM_SE
*/
            --
            declare
               --
               vn_mes_periodo_atual number;
               vn_n660_2 number;
               vn_n660_053 number;
               vn_n660_054 number;
               vn_n660_055 number;
               --
            begin
               --
               vn_mes_periodo_atual := to_number(substr(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, 2, 2));
               --
               begin
                  select sum( case when td.cd = '2' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.53' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.54' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.55' then nvl(d.valor,0) else 0 end )
                    into vn_n660_2
                       , vn_n660_053
                       , vn_n660_054
                       , vn_n660_055
                    from calc_csll_mes_estim    d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('2', '0.53', '0.54', '0.55');
               exception
                  when others then
                     vn_n660_2 := 0;
                     vn_n660_053 := 0;
                     vn_n660_054 := 0;
                     vn_n660_055 := 0;
               end;
               --
               if nvl(vn_n660_2,0) <= 0 then
                  vn_valor := 0;
               else
                  if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '1' then
                     vn_valor := nvl(vn_n660_2,0) * 0.09;
                  else
                     --
                     if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                        --
                        if nvl(vn_mes_periodo_atual,0) < 10 then
                           vn_valor := nvl(vn_n660_2,0) * 0.15;
                        else
                           --
                           if nvl(vn_n660_053,0) = 0 then
                              vn_valor := nvl(vn_n660_2,0) * 0.17;
                           else
                              -- N660(2)*N660("0.55")/N660("0.53")*0,02+N660(2)*0,15
                              vn_valor := (((nvl(vn_n660_2,0) * nvl(vn_n660_055,0))/nvl(vn_n660_053,1)) * 0.02) + (nvl(vn_n660_2,0) * 0.15);
                              --
                           end if;
                           --
                        end if;
                        --
                     else
                        --
                        if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '3' then
                           --
                           if nvl(vn_mes_periodo_atual,0) < 9 then
                              vn_valor := nvl(vn_n660_2,0) * 0.15;
                           else
                              --
                              if nvl(vn_n660_053,0) = 0 then
                                 vn_valor := nvl(vn_n660_2,0) * 0.20;
                              else
                                 --
                                 -- N660(2)*N660("0.54")/N660(" 0.53")*0,05+N660(2)*0,15
                                 vn_valor := (((nvl(vn_n660_2,0) * nvl(vn_n660_055,0))/nvl(vn_n660_053,1)) * 0.05) + (nvl(vn_n660_2,0) * 0.15);
                                 --
                              end if;
                              --
                           end if;
                           --
                        end if;
                        --
                     end if;
                     --
                  end if;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         else
            --
            /*
SE (0000.DT_FIN () <= "2015-12-31") ENTAO
   SE(N660(2)<=0) ENTAO 
      0 
   SENAO 
      SE(0020.IND_ALIQ_CSLL()="1") ENTAO 
         N660(2)*0,09 
      SENAO 
         SE(0020.IND_ALIQ_CSLL()="2") ENTAO 
            SE(PERIODO_ATUAL()<"A10") ENTAO 
               N660(2)*0,15 
            SENAO 
               SE(N660("0.53")=0)ENTAO 
                  N660(2)*0,17 
               SENAO 
                  N660(2)*N660("0.55")/N660("0.53")*0,02+N660(2)*0,15 
               FIM_SE
            FIM_SE 
         SENAO 
            SE(0020.IND_ALIQ_CSLL()="3")ENTAO 
               SE(PERIODO_ATUAL()<"A09")ENTAO 
                  N660(2)*0,15 
               SENAO 
                  SE (N660("0.53")=0)ENTAO 
                     N660(2)*0,20 
                  SENAO 
                     N660(2)*N660("0.54")/N660("0.53")*0,05+N660(2)*0,15 
                  FIM_SE 
               FIM_SE
            FIM_SE 
         FIM_SE 
      FIM_SE 
   FIM_SE 
SENAO 
   SE(N660(2)<=0) ENTAO 
      0 
   SENAO 
      SE(0020.IND_ALIQ_CSLL()="1") ENTAO
         N660(2)*0,09
      SENAO
         SE(0020.IND_ALIQ_CSLL()="2") ENTAO
            N660(2)*0,17 
         SENAO 
            SE(0020.IND_ALIQ_CSLL()="3")ENTAO 
               N660(2)*0,20 
            FIM_SE 
         FIM_SE 
      FIM_SE 
   FIM_SE 
FIM_SE
            */
            --
            declare
               --
               vn_n660_2 number;
               --
            begin
               --
               begin
                  select sum( case when td.cd = '2' then nvl(d.valor,0) else 0 end )
                    into vn_n660_2
                    from calc_csll_mes_estim    d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('2');
               exception
                  when others then
                     vn_n660_2 := 0;
               end;
               --
               if nvl(vn_n660_2,0) <= 0 then
                  --
                  vn_valor := 0;
                  --
               else
                  --
                  if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '1' then
                     vn_valor := nvl(vn_n660_2,0) * 0.09;
                  else
                     --
                     if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                        --
                        vn_valor := nvl(vn_n660_2,0) * 0.17;
                        --
                     else
                        --
                        if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '3' then
                           --
                           vn_valor := nvl(vn_n660_2,0) * 0.20;
                           --
                        else
                           vn_valor := 0;
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
                  vn_valor := 0;
            end;
            --
         end if;
         --
      elsif rec.tabdinecf_cd = '5' then -- (-) Isenção sobre o Lucro da Exploração Relativo ao Prouni
         --
         vn_fase := 8;
         --
         if pk_csf_api_secf.gv_versao_layout_ecf_cd = '100' then
            --
         /*
SE (N600(50) <= 0) ENTAO 
   0 
SENAO 
   SE (0020.IND_ALIQ_CSLL() = "'S") ENTAO
      N600(50) * 0,15
   SENAO 
      N600(50) * 0,09
   FIM_SE 
FIM_SE
         */
            declare
               --
               vn_n600_50 number;
               --
            begin
               --
               begin
                  select d.valor
                    into vn_n600_50
                    from dem_lucro_expl         d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('50');
               exception
                  when others then
                     vn_n600_50 := 0;
               end;
               --
               if nvl(vn_n600_50,0) <= 0 then
                  vn_valor := 0;
               else
                  if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = 'S' then
                     vn_valor := nvl(vn_n600_50,0) * 0.15;
                  else
                     vn_valor := nvl(vn_n600_50,0) * 0.09;
                  end if;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         else
            --
/*
SE (N600(50)<=0) ENTAO
   0 
SENAO 
   SE (0020.IND_ALIQ_CSLL()= "1") ENTAO 
      N600(50)*0,09 
   SENAO 
      SE (0020.IND_ALIQ_CSLL()= "2") ENTAO 
         SE (PERIODO_ATUAL() < "A10") ENTAO 
            N600(50)*0,15 
         SENAO
            SE (N660("0.53")=0) ENTAO
               N600(50)*0,17 
            SENAO 
               N600(50)*N660("0.55")/N660( "0.53")*0,02+N600(50)*0,15 
            FIM_SE 
         FIM_SE 
      SENAO 
         SE (0020.IND_ALIQ_CSLL()= "3") ENTAO 
            SE (PERIODO_ATUAL() < "A09") ENTAO 
               N600(50)*0,15 
            SENAO 
               SE (N660("0.53")=0) ENTAO 
                  N600(50)*0,20
               SENAO 
                  N600(50)*N660("0.54")/N660( "0.53")*0,05+N600(50)*0,15 
               FIM_SE 
            FIM_SE 
         FIM_SE 
      FIM_SE 
   FIM_SE 
FIM_SE
*/
            --
            declare
               --
               vn_mes_periodo_atual number;
               vn_n660_50 number;
               vn_n660_053 number;
               vn_n660_054 number;
               vn_n660_055 number;
               --
            begin
               --
               vn_mes_periodo_atual := to_number(substr(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, 2, 2));
               --
               begin
                  select sum( case when td.cd = '50' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.53' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.54' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.55' then nvl(d.valor,0) else 0 end )
                    into vn_n660_50
                       , vn_n660_053
                       , vn_n660_054
                       , vn_n660_055
                    from calc_csll_mes_estim    d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('50', '0.53', '0.54', '0.55');
               exception
                  when others then
                     vn_n660_50 := 0;
                     vn_n660_053 := 0;
                     vn_n660_054 := 0;
                     vn_n660_055 := 0;
               end;
               --
               if nvl(vn_n660_50,0) <= 0 then
                  vn_valor := 0;
               else
                  if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '1' then
                     vn_valor := nvl(vn_n660_50,0) * 0.09;
                  else
                     --
                     if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                        --
                        if nvl(vn_mes_periodo_atual,0) < 10 then
                           vn_valor := nvl(vn_n660_50,0) * 0.15;
                        else
                           --
                           if nvl(vn_n660_053,0) = 0 then
                              vn_valor := nvl(vn_n660_50,0) * 0.17;
                           else
                              -- N600(50)*N660("0.55")/N660( "0.53")*0,02+N600(50)*0,15
                              vn_valor := (((nvl(vn_n660_50,0) * nvl(vn_n660_055,0))/nvl(vn_n660_053,1)) * 0.02) + (nvl(vn_n660_50,0) * 0.15);
                              --
                           end if;
                           --
                        end if;
                        --
                     else
                        --
                        if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '3' then
                           --
                           if nvl(vn_mes_periodo_atual,0) < 9 then
                              vn_valor := nvl(vn_n660_50,0) * 0.15;
                           else
                              --
                              if nvl(vn_n660_053,0) = 0 then
                                 vn_valor := nvl(vn_n660_50,0) * 0.20;
                              else
                                 --
                                 -- N600(50)*N660("0.54")/N660( "0.53")*0,05+N600(50)*0,15
                                 vn_valor := (((nvl(vn_n660_50,0) * nvl(vn_n660_055,0))/nvl(vn_n660_053,1)) * 0.05) + (nvl(vn_n660_50,0) * 0.15);
                                 --
                              end if;
                              --
                           end if;
                           --
                        end if;
                        --
                     end if;
                     --
                  end if;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         end if;
         --
      elsif rec.tabdinecf_cd = '6' then -- (-) Isenção sobre o Lucro da Exploração de Eventos da Fifa
         --
         vn_fase := 9;
         --
         if pk_csf_api_secf.gv_versao_layout_ecf_cd = '100' then
            --
         /*
SE (N600(54) <= 0) ENTAO
   0
SENAO
   SE (0020.IND_ALIQ_CSLL() = "'S") ENTAO
      N600(54) * 0,15
   SENAO
      N600(54) * 0,09
   FIM_SE
FIM_SE
         */
            --
            declare
               --
               vn_n600_54 number;
               --
            begin
               --
               begin
                  select d.valor
                    into vn_n600_54
                    from dem_lucro_expl         d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('54');
               exception
                  when others then
                     vn_n600_54 := 0;
               end;
               --
               if nvl(vn_n600_54,0) <= 0 then
                  vn_valor := 0;
               else
                  if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = 'S' then
                     vn_valor := nvl(vn_n600_54,0) * 0.15;
                  else
                     vn_valor := nvl(vn_n600_54,0) * 0.09;
                  end if;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         else
            --
/*
SE (N600(54)<=0) ENTAO 
   0 
SENAO 
   SE (0020.IND_ALIQ_CSLL()= "1") ENTAO
      N600(54)*0,09 
   SENAO 
      SE (0020.IND_ALIQ_CSLL()= "2") ENTAO 
         SE (PERIODO_ATUAL() < "A10") ENTAO
            N600(54)*0,15 
         SENAO 
            SE (N660("0.53")=0) ENTAO 
               N600(54)*0,17 
            SENAO 
               N600(54)*N660("0.55")/N660( "0.53")*0,02+N600(54)*0,15 
            FIM_SE 
         FIM_SE 
      SENAO 
         SE (0020.IND_ALIQ_CSLL()= "3") ENTAO 
            SE (PERIODO_ATUAL() < "A09") ENTAO
               N600(54)*0,15 
            SENAO
               SE (N660("0.53")=0) ENTAO 
                  N600(54)*0,20 
               SENAO 
                  N600(54)*N660("0.54")/N660( "0.53")*0,05+N600(54)*0,15 
               FIM_SE 
            FIM_SE 
         FIM_SE 
      FIM_SE 
   FIM_SE 
FIM_SE
*/
            --
            declare
               --
               vn_mes_periodo_atual number;
               vn_n660_54 number;
               vn_n660_053 number;
               vn_n660_054 number;
               vn_n660_055 number;
               --
            begin
               --
               vn_mes_periodo_atual := to_number(substr(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, 2, 2));
               --
               begin
                  select sum( case when td.cd = '54' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.53' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.54' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.55' then nvl(d.valor,0) else 0 end )
                    into vn_n660_54
                       , vn_n660_053
                       , vn_n660_054
                       , vn_n660_055
                    from calc_csll_mes_estim    d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('54', '0.53', '0.54', '0.55');
               exception
                  when others then
                     vn_n660_54 := 0;
                     vn_n660_053 := 0;
                     vn_n660_054 := 0;
                     vn_n660_055 := 0;
               end;
               --
               if nvl(vn_n660_54,0) <= 0 then
                  vn_valor := 0;
               else
                  if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '1' then
                     vn_valor := nvl(vn_n660_54,0) * 0.09;
                  else
                     --
                     if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                        --
                        if nvl(vn_mes_periodo_atual,0) < 10 then
                           vn_valor := nvl(vn_n660_54,0) * 0.15;
                        else
                           --
                           if nvl(vn_n660_053,0) = 0 then
                              vn_valor := nvl(vn_n660_54,0) * 0.17;
                           else
                              -- N600(54)*N660("0.55")/N660( "0.53")*0,02+N600(54)*0,15
                              vn_valor := (((nvl(vn_n660_54,0) * nvl(vn_n660_055,0))/nvl(vn_n660_053,1)) * 0.02) + (nvl(vn_n660_54,0) * 0.15);
                              --
                           end if;
                           --
                        end if;
                        --
                     else
                        --
                        if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '3' then
                           --
                           if nvl(vn_mes_periodo_atual,0) < 9 then
                              vn_valor := nvl(vn_n660_54,0) * 0.15;
                           else
                              --
                              if nvl(vn_n660_053,0) = 0 then
                                 vn_valor := nvl(vn_n660_54,0) * 0.20;
                              else
                                 --
                                 -- N600(54)*N660("0.54")/N660( "0.53")*0,05+N600(54)*0,15
                                 vn_valor := (((nvl(vn_n660_54,0) * nvl(vn_n660_055,0))/nvl(vn_n660_053,1)) * 0.05) + (nvl(vn_n660_54,0) * 0.15);
                                 --
                              end if;
                              --
                           end if;
                           --
                        end if;
                        --
                     end if;
                     --
                  end if;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         end if;
         --
      elsif rec.tabdinecf_cd = '7' then -- (-) Isenção sobre o Lucro da Exploração da Atividade de Serviços - SPE - Eventos da Fifa
         --
         vn_fase := 10;
         --
         if pk_csf_api_secf.gv_versao_layout_ecf_cd = '100' then
            --
         /*
SE (N600(55) <= 0) ENTAO
   0
SENAO
   SE (0020.IND_ALIQ_CSLL() = "'S") ENTAO
      N600(55) * 0,15
   SENAO
      N600(55) * 0,09
   FIM_SE 
FIM_SE
         */
         --
            declare
               --
               vn_n600_55 number;
               --
            begin
               --
               begin
                  select d.valor
                    into vn_n600_55
                    from dem_lucro_expl         d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('55');
               exception
                  when others then
                     vn_n600_55 := 0;
               end;
               --
               if nvl(vn_n600_55,0) <= 0 then
                  vn_valor := 0;
               else
                  if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = 'S' then
                     vn_valor := nvl(vn_n600_55,0) * 0.15;
                  else
                     vn_valor := nvl(vn_n600_55,0) * 0.09;
                  end if;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         else
            --
/*
SE (N600(55)<=0) ENTAO 
   0 
SENAO 
   SE (0020.IND_ALIQ_CSLL()= "1") ENTAO 
      N600(55)*0,09 
   SENAO
      SE (0020.IND_ALIQ_CSLL()= "2") ENTAO 
         SE (PERIODO_ATUAL()<"A1 0") ENTAO 
            N600(55)*0,15 
         SENAO 
            SE (N660("0.53")=0) ENTAO 
               N600(55)*0,17 
            SENAO 
               N600(55)*N660("0.55")/N660( "0.53")*0,02+N600(55)*0,15 
            FIM_SE 
         FIM_SE 
      SENAO 
         SE (0020.IND_ALIQ_CSLL()= "3") ENTAO 
            SE (PERIODO_ATUAL()<"A09") ENTAO 
               N600(55)*0,15 
            SENAO 
               SE (N660("0.53")=0) ENTAO 
                  N600(55)*0,20 
               SENAO 
                  N600(55)*N660("0.54")/N660( "0.53")*0,05+N600(55)*0,15 
               FIM_SE 
            FIM_SE 
         FIM_SE 
      FIM_SE 
   FIM_SE 
FIM_SE
*/
            --
            declare
               --
               vn_mes_periodo_atual number;
               vn_n660_55 number;
               vn_n660_053 number;
               vn_n660_054 number;
               vn_n660_055 number;
               --
            begin
               --
               vn_mes_periodo_atual := to_number(substr(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, 2, 2));
               --
               begin
                  select sum( case when td.cd = '55' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.53' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.54' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.55' then nvl(d.valor,0) else 0 end )
                    into vn_n660_55
                       , vn_n660_053
                       , vn_n660_054
                       , vn_n660_055
                    from calc_csll_mes_estim    d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('55', '0.53', '0.54', '0.55');
               exception
                  when others then
                     vn_n660_55 := 0;
                     vn_n660_053 := 0;
                     vn_n660_054 := 0;
                     vn_n660_055 := 0;
               end;
               --
               if nvl(vn_n660_55,0) <= 0 then
                  vn_valor := 0;
               else
                  if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '1' then
                     vn_valor := nvl(vn_n660_55,0) * 0.09;
                  else
                     --
                     if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                        --
                        if nvl(vn_mes_periodo_atual,0) < 10 then
                           vn_valor := nvl(vn_n660_55,0) * 0.15;
                        else
                           --
                           if nvl(vn_n660_053,0) = 0 then
                              vn_valor := nvl(vn_n660_55,0) * 0.17;
                           else
                              -- N600(55)*N660("0.55")/N660( "0.53")*0,02+N600(55)*0,15
                              vn_valor := (((nvl(vn_n660_55,0) * nvl(vn_n660_055,0))/nvl(vn_n660_053,1)) * 0.02) + (nvl(vn_n660_55,0) * 0.15);
                              --
                           end if;
                           --
                        end if;
                        --
                     else
                        --
                        if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '3' then
                           --
                           if nvl(vn_mes_periodo_atual,0) < 9 then
                              vn_valor := nvl(vn_n660_55,0) * 0.15;
                           else
                              --
                              if nvl(vn_n660_053,0) = 0 then
                                 vn_valor := nvl(vn_n660_55,0) * 0.20;
                              else
                                 --
                                 -- N600(55)*N660("0.54")/N660( "0.53")*0,05+N600(55)*0,15
                                 vn_valor := (((nvl(vn_n660_55,0) * nvl(vn_n660_055,0))/nvl(vn_n660_053,1)) * 0.05) + (nvl(vn_n660_55,0) * 0.15);
                                 --
                              end if;
                              --
                           end if;
                           --
                        end if;
                        --
                     end if;
                     --
                  end if;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         end if;
         --
      elsif rec.tabdinecf_cd = '8' then -- (-) Isenção sobre o Lucro da Exploração de Eventos do CIO
         --
         vn_fase := 11;
         --
         if pk_csf_api_secf.gv_versao_layout_ecf_cd = '100' then
            --
         /*
SE (N600(56) <= 0) ENTAO
   0
SENAO
   SE (0020.IND_ALIQ_CSLL() = "'S") ENTAO
      N600(56) * 0,15
   SENAO
      N600(56) * 0,09
   FIM_SE
FIM_SE
         */
            declare
               --
               vn_n600_56 number;
               --
            begin
               --
               begin
                  select d.valor
                    into vn_n600_56
                    from dem_lucro_expl         d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('56');
               exception
                  when others then
                     vn_n600_56 := 0;
               end;
               --
               if nvl(vn_n600_56,0) <= 0 then
                  vn_valor := 0;
               else
                  if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = 'S' then
                     vn_valor := nvl(vn_n600_56,0) * 0.15;
                  else
                     vn_valor := nvl(vn_n600_56,0) * 0.09;
                  end if;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         else 
            --
/*
SE (N600(56)<=0) ENTAO 
   0 
SENAO 
   SE (0020.IND_ALIQ_CSLL()= "1") ENTAO 
      N600(56)*0,09 
   SENAO
      SE (0020.IND_ALIQ_CSLL()= "2") ENTAO 
         SE (PERIODO_ATUAL()<"A1 0") ENTAO 
            N600(56)*0,15 
         SENAO 
            SE (N660("0.53")=0) ENTAO 
               N600(56)*0,17 
            SENAO 
               N600(56)*N660("0.55")/N660( "0.53")*0,02+N600(56)*0,15 
            FIM_SE 
         FIM_SE 
      SENAO 
         SE (0020.IND_ALIQ_CSLL()= "3") ENTAO 
            SE (PERIODO_ATUAL()<"A0 9") ENTAO 
               N600(56)*0,15 
            SENAO 
               SE (N660("0.53")=0) ENTAO 
                  N600(56)*0,20 
               SENAO 
                  N600(56)*N660("0.54")/N660( "0.53")*0,05+N600(56)*0,15 
               FIM_SE 
            FIM_SE
         FIM_SE 
      FIM_SE 
   FIM_SE 
FIM_SE
*/
            --
            declare
               --
               vn_mes_periodo_atual number;
               vn_n660_56 number;
               vn_n660_053 number;
               vn_n660_054 number;
               vn_n660_055 number;
               --
            begin
               --
               vn_mes_periodo_atual := to_number(substr(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, 2, 2));
               --
               begin
                  select sum( case when td.cd = '56' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.53' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.54' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.55' then nvl(d.valor,0) else 0 end )
                    into vn_n660_56
                       , vn_n660_053
                       , vn_n660_054
                       , vn_n660_055
                    from calc_csll_mes_estim    d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('56', '0.53', '0.54', '0.55');
               exception
                  when others then
                     vn_n660_56 := 0;
                     vn_n660_053 := 0;
                     vn_n660_054 := 0;
                     vn_n660_055 := 0;
               end;
               --
               if nvl(vn_n660_56,0) <= 0 then
                  vn_valor := 0;
               else
                  if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '1' then
                     vn_valor := nvl(vn_n660_56,0) * 0.09;
                  else
                     --
                     if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                        --
                        if nvl(vn_mes_periodo_atual,0) < 10 then
                           vn_valor := nvl(vn_n660_56,0) * 0.15;
                        else
                           --
                           if nvl(vn_n660_053,0) = 0 then
                              vn_valor := nvl(vn_n660_56,0) * 0.17;
                           else
                              -- N600(56)*N660("0.55")/N660( "0.53")*0,02+N600(56)*0,15
                              vn_valor := (((nvl(vn_n660_56,0) * nvl(vn_n660_055,0))/nvl(vn_n660_053,1)) * 0.02) + (nvl(vn_n660_56,0) * 0.15);
                              --
                           end if;
                           --
                        end if;
                        --
                     else
                        --
                        if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '3' then
                           --
                           if nvl(vn_mes_periodo_atual,0) < 9 then
                              vn_valor := nvl(vn_n660_56,0) * 0.15;
                           else
                              --
                              if nvl(vn_n660_053,0) = 0 then
                                 vn_valor := nvl(vn_n660_56,0) * 0.20;
                              else
                                 --
                                 -- N600(56)*N660("0.54")/N660( "0.53")*0,05+N600(56)*0,15
                                 vn_valor := (((nvl(vn_n660_56,0) * nvl(vn_n660_055,0))/nvl(vn_n660_053,1)) * 0.05) + (nvl(vn_n660_56,0) * 0.15);
                                 --
                              end if;
                              --
                           end if;
                           --
                        end if;
                        --
                     end if;
                     --
                  end if;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         end if;
         --
      elsif rec.tabdinecf_cd = '9' then -- (-) Isenção sobre o Lucro da Exploração da Atividade de Serviços - SPE - Eventos do CIO
         --
         vn_fase := 11;
         --
         if pk_csf_api_secf.gv_versao_layout_ecf_cd = '100' then
            --
         /*
SE (N600(57) <= 0) ENTAO
   0
SENAO
   SE (0020.IND_ALIQ_CSLL() = "'S") ENTAO
      N600(57) * 0,15
   SENAO
      N600(57) * 0,09
   FIM_SE 
FIM_SE
         */
            --
            declare
               --
               vn_n600_57 number;
               --
            begin
               --
               begin
                  select d.valor
                    into vn_n600_57
                    from dem_lucro_expl         d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('57');
               exception
                  when others then
                     vn_n600_57 := 0;
               end;
               if nvl(vn_n600_57,0) <= 0 then
                  vn_valor := 0;
               else
                  if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = 'S' then
                     vn_valor := nvl(vn_n600_57,0) * 0.15;
                  else
                     vn_valor := nvl(vn_n600_57,0) * 0.09;
                  end if;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         else
            --
/*
SE (N600(57)<=0) ENTAO 
   0 
SENAO 
   SE (0020.IND_ALIQ_CSLL()= "1") ENTAO 
      N600(57)*0,09 
   SENAO 
      SE (0020.IND_ALIQ_CSLL()= "2") ENTAO 
         SE (PERIODO_ATUAL()<"A10") ENTAO 
            N600(57)*0,15 
         SENAO 
            SE (N660("0.53")=0) ENTAO 
               N600(57)*0,17 
            SENAO 
               N600(57)*N660("0.55")/N660( "0.53")*0,02+N600(57)*0,15 
            FIM_SE
         FIM_SE 
      SENAO 
         SE (0020.IND_ALIQ_CSLL()= "3") ENTAO 
            SE (PERIODO_ATUAL() < "A09") ENTAO
               N600(57)*0,15 
            SENAO 
               SE (N660("0.53")=0) ENTAO 
                  N600(57)*0,20 
               SENAO 
                  N600(57)*N660("0.54")/N660("0.53")*0,05+N600(57)*0,15
               FIM_SE 
            FIM_SE 
         FIM_SE 
      FIM_SE 
   FIM_SE 
FIM_SE
*/
            --
            declare
               --
               vn_mes_periodo_atual number;
               vn_n660_57 number;
               vn_n660_053 number;
               vn_n660_054 number;
               vn_n660_055 number;
               --
            begin
               --
               vn_mes_periodo_atual := to_number(substr(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, 2, 2));
               --
               begin
                  select sum( case when td.cd = '57' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.53' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.54' then nvl(d.valor,0) else 0 end )
                       , sum( case when td.cd = '0.55' then nvl(d.valor,0) else 0 end )
                    into vn_n660_57
                       , vn_n660_053
                       , vn_n660_054
                       , vn_n660_055
                    from calc_csll_mes_estim    d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('57', '0.53', '0.54', '0.55');
               exception
                  when others then
                     vn_n660_57 := 0;
                     vn_n660_053 := 0;
                     vn_n660_054 := 0;
                     vn_n660_055 := 0;
               end;
               --
               if nvl(vn_n660_57,0) <= 0 then
                  vn_valor := 0;
               else
                  if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '1' then
                     vn_valor := nvl(vn_n660_57,0) * 0.09;
                  else
                     --
                     if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '2' then
                        --
                        if nvl(vn_mes_periodo_atual,0) < 10 then
                           vn_valor := nvl(vn_n660_57,0) * 0.15;
                        else
                           --
                           if nvl(vn_n660_053,0) = 0 then
                              vn_valor := nvl(vn_n660_57,0) * 0.17;
                           else
                              -- N600(57)*N660("0.55")/N660( "0.53")*0,02+N600(57)*0,15
                              vn_valor := (((nvl(vn_n660_57,0) * nvl(vn_n660_055,0))/nvl(vn_n660_053,1)) * 0.02) + (nvl(vn_n660_57,0) * 0.15);
                              --
                           end if;
                           --
                        end if;
                        --
                     else
                        --
                        if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_aliq_csll = '3' then
                           --
                           if nvl(vn_mes_periodo_atual,0) < 9 then
                              vn_valor := nvl(vn_n660_57,0) * 0.15;
                           else
                              --
                              if nvl(vn_n660_053,0) = 0 then
                                 vn_valor := nvl(vn_n660_57,0) * 0.20;
                              else
                                 --
                                 -- N600(57)*N660("0.54")/N660( "0.53")*0,05+N600(57)*0,15
                                 vn_valor := (((nvl(vn_n660_57,0) * nvl(vn_n660_055,0))/nvl(vn_n660_053,1)) * 0.05) + (nvl(vn_n660_57,0) * 0.15);
                                 --
                              end if;
                              --
                           end if;
                           --
                        end if;
                        --
                     end if;
                     --
                  end if;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         end if;
         --
      elsif rec.tabdinecf_cd = '12' then -- (-) CSLL Devida em Meses Anteriores
         --
         vn_fase := 12;
         /*
SE (BAL_RED(PERIODO_ATUAL()) = "B") ENTAO
   (SOMA(N660("12.01";"A01":PERIODO_ANTERIOR())) )
FIM_SE
         */
         declare
            --
            vn_n660_12_1 number;
            --
         begin
            --
            vn_fase := 10.1;
            -- PERIODO_ANTERIOR
            begin
               select nvl(sum(d.valor),0)
                 into vn_n660_12_1
                 from per_calc_apur_lr       p
                    , calc_csll_mes_estim    d
                    , tab_din_ecf            td
                where p.aberturaecf_id       = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and to_number(to_char(p.dt_fin, 'rrrrmm')) <= (to_number(to_char(pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin, 'rrrrmm')) - 1)
                  and d.percalcapurlr_id     = p.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('12.01');
            exception
               when others then
                  vn_n660_12_1 := 0;
            end;
            --
            vn_fase := 10.2;
            --
            if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A01' then
               --
               /*
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red1 = 'B' then
                  --
                  -- Mês atual calcula ele mesmo
                  --
                  declare
                     --
                     vn_vl_1 number;
                     vn_vl_2 number;
                     --
                  begin
                     --
                     begin
                        select nvl( sum( d.valor ) ,0)
                          into vn_vl_1
                          from calc_csll_mes_estim    d
                             , tab_din_ecf            td
                         where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                           and td.id                  = d.tabdinecf_id
                           and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) = 3;
                     exception
                        when others then
                           vn_vl_1 := 0;
                     end;
                     --
                     begin
                        select nvl( sum( d.valor ) ,0)
                          into vn_vl_2
                          from calc_csll_mes_estim    d
                             , tab_din_ecf            td
                         where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                           and td.id                  = d.tabdinecf_id
                           and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) between 5 and 12;
                     exception
                        when others then
                           vn_vl_2 := 0;
                     end;
                     --
                     vn_n660_12_1 := nvl(vn_vl_1,0) - nvl(vn_vl_2,0);
                     --
                     if nvl(vn_n660_12_1,0) < 0 then
                        vn_n660_12_1 := 0;
                     end if;
                     --
                  exception
                     when others then
                        vn_n660_12_1 := 0;
                  end;
                  --
                  vn_valor := nvl(vn_n660_12_1,0);
               else
                  vn_valor := 0;
               end if; */
               --
               vn_valor := 0;
               --
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A02' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red2 = 'B' then
                  vn_valor := nvl(vn_n660_12_1,0);
               else
                  vn_valor := 0;
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A03' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red3 = 'B' then
                  vn_valor := nvl(vn_n660_12_1,0);
               else
                  vn_valor := 0;
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A04' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red4 = 'B' then
                  vn_valor := nvl(vn_n660_12_1,0);
               else
                  vn_valor := 0;
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A05' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red5 = 'B' then
                  vn_valor := nvl(vn_n660_12_1,0);
               else
                  vn_valor := 0;
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A06' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red6 = 'B' then
                  vn_valor := nvl(vn_n660_12_1,0);
               else
                  vn_valor := 0;
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A07' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red7 = 'B' then
                  vn_valor := nvl(vn_n660_12_1,0);
               else
                  vn_valor := 0;
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A08' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red8 = 'B' then
                  vn_valor := nvl(vn_n660_12_1,0);
               else
                  vn_valor := 0;
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A09' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red9 = 'B' then
                  vn_valor := nvl(vn_n660_12_1,0);
               else
                  vn_valor := 0;
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A10' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red10 = 'B' then
                  vn_valor := nvl(vn_n660_12_1,0);
               else
                  vn_valor := 0;
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A11' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red11 = 'B' then
                  vn_valor := nvl(vn_n660_12_1,0);
               else
                  vn_valor := 0;
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A12' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red12 = 'B' then
                  vn_valor := nvl(vn_n660_12_1,0);
               else
                  vn_valor := 0;
               end if;
            else
               vn_valor := 0;
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '12.01' then -- CSLL Devida no Mês
         --
         vn_fase := 13;
         /*
SE(SOMA(N660(3:3)) - SOMA(N660(5:12))>0) ENTAO
   SOMA(N660(3:3)) - SOMA(N660(5:12))
SENAO
   0
FIM_SE
         */
         declare
            --
            vn_vl_1 number;
            vn_vl_2 number;
            --
         begin
            --
            begin
               select nvl( sum( d.valor ) ,0)
                 into vn_vl_1
                 from calc_csll_mes_estim    d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) = 3;
            exception
               when others then
                  vn_vl_1 := 0;
            end;
            --
            begin
               select nvl( sum( d.valor ) ,0)
                 into vn_vl_2
                 from calc_csll_mes_estim    d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and ( td.cd <> '12.01' and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) between 5 and 12 );
            exception
               when others then
                  vn_vl_2 := 0;
            end;
            --
            vn_valor := nvl(vn_vl_1,0) - nvl(vn_vl_2,0);
            --
            if nvl(vn_valor,0) < 0 then
               vn_valor := 0;
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '18' then -- CSLL A PAGAR
         --
         vn_fase := 14;
         -- N660(3) - SOMA(N660(5:12)) - SOMA(N660(13:17))
         --
         declare
            --
            vn_vl_1 number;
            vn_vl_2 number;
            vn_vl_3 number;
            --
         begin
            --
            vn_fase := 14.1;
            --
            begin
               select nvl( sum( d.valor ) ,0)
                 into vn_vl_1
                 from calc_csll_mes_estim    d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) = 3;
            exception
               when others then
                  vn_vl_1 := 0;
            end;
            --
            vn_fase := 14.2;
            --
            begin
               select nvl( sum( d.valor ) ,0)
                 into vn_vl_2
                 from calc_csll_mes_estim    d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and ( td.cd <> '12.01' and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) between 5 and 12 );
            exception
               when others then
                  vn_vl_2 := 0;
            end;
            --
            vn_fase := 14.3;
            --
            begin
               select nvl( sum( d.valor ) ,0)
                 into vn_vl_3
                 from calc_csll_mes_estim    d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) between 13 and 17.99;
            exception
               when others then
                  vn_vl_3 := 0;
            end;
            --
            vn_fase := 14.4;
            --
            vn_valor := nvl(vn_vl_1,0) - nvl(vn_vl_2,0) - nvl(vn_vl_3,0);
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      end if;
      --
      vn_fase := 99;
      --
      update calc_csll_mes_estim set valor    = nvl(vn_valor,0)
                                   , dm_tipo  = 1 -- Calculado
       where id = rec.calccsllmesestim_id;
      --
      commit;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_soma_vlr_ccsllme fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_soma_vlr_ccsllme;

-------------------------------------------------------------------------------------------------------

-- Procedimento de atualizar os valores de Cálculo da CSLL Mensal por Estimativa
procedure pkb_atual_vlr_ccsllme ( en_percalcapurlr_id  in per_calc_apur_lr.id%type )
is
   --
   vn_fase number;
   vn_loggenerico_id  log_generico.id%type;
   --
   vv_dominio_descr Dominio.descr%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   gt_log_generico.delete;
   --
   if nvl(en_percalcapurlr_id,0) > 0 then
      --
      vn_fase := 2;
      --
      pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
      --
      begin
         --
         select *
           into pk_csf_api_secf.gt_row_per_calc_apur_lr
           from per_calc_apur_lr
          where id = en_percalcapurlr_id;
         --
      exception
         when others then
            pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
      end;
      --
      vn_fase := 3;
      --
      if nvl(pk_csf_api_secf.gt_row_per_calc_apur_lr.id,0) > 0 then
         --
         pk_csf_api_secf.pkb_inicia_param ( en_aberturaecf_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id );
         --
         vn_fase := 4;
         -- Procedimento seta o objeto de referencia utilizado na Validação da Informação
         pk_csf_api_secf.pkb_seta_obj_ref ( ev_objeto => 'PER_CALC_APUR_LR' );
         --
         vn_fase := 4.1;
         -- Procedimento seta o "ID de Referencia" utilizado na Validação da Informação
         pk_csf_api_secf.pkb_seta_referencia_id ( en_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.id );
         --
         vn_fase := 5;
         --
         -- Chama Procedimento para somar os valores de Cálculo da CSLL Mensal por Estimativa
         pkb_soma_vlr_ccsllme;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_atual_vlr_ccsllme fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_atual_vlr_ccsllme;

-----------------------------------------------------------------------------------------------------------------
-- Procedimento para somar os valores de Base de Cálculo da CSLL Após as Compensações da Base de Cálculo Negativa
-----------------------------------------------------------------------------------------------------------------
procedure pkb_soma_vlr_bccsllcp is
  --
  vn_fase number;
  --
  vn_valor bc_csll_comp_neg.valor%type;
  vn_tipo  bc_csll_comp_neg.dm_tipo%type;
  --
  cursor c_dados2 is
    select d.id              bccsllcompneg_id,
           td.id             tabdinecf_id,
           td.registroecf_id,
           td.cd             tabdinecf_cd,
           td.ordem
      from bc_csll_comp_neg d, 
           tab_din_ecf td
     where d.percalcapurlr_id = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
       and td.id              = d.tabdinecf_id
       and td.dm_tipo         in ('CA', 'CNA')
     order by td.ordem, 
              td.cd;
  --
begin
  --
  vn_fase := 1;
  --
  for rec in c_dados2 loop
    exit when c_dados2%notfound or(c_dados2%notfound) is null;
    --
    vn_fase := 5;
    --
    vn_valor := 0;
    --
    -- Valor da Base de Cálculo da CSLL
    if rec.tabdinecf_cd = '1' then 
      --
      if pk_csf_api_secf.gv_versao_layout_ecf_cd = '100' then
        --
        vn_fase := 6;
        --
        /*
        SE (0010.COD_QUALIF_PJ() = "01") ENTAO
           (DEBITO(M350(149))+DEBITO(M350(349)))
        SENAO
           SE (0010.COD_QUALIF_PJ() = "02") ENTAO
              (DEBITO(M350(203)))
           SENAO
              SE (0010.COD_QUALIF_PJ() = "03") ENTAO
                 (DEBITO(M350(142)))
              SENAO
                 0
              FIM_SE
           FIM_SE
        FIM_SE */
        --
        declare
          --
          vn_m350_175 number;
          vn_m350_349 number;
          vn_m350_203 number;
          vn_m350_142 number;
          --
        begin
          --
          begin
            select nvl( sum( case when td.cd = '175' then l.valor else 0 end ) ,0),
                   nvl( sum( case when td.cd = '349' then l.valor else 0 end ) ,0),
                   nvl( sum( case when td.cd = '203' then l.valor else 0 end ) ,0),
                   nvl( sum( case when td.cd = '142' then l.valor else 0 end ) ,0)
              into vn_m350_175, 
                   vn_m350_349, 
                   vn_m350_203, 
                   vn_m350_142
              from per_apur_lr p, 
                   lanc_part_a_lacs l, 
                   tab_din_ecf td
             where p.aberturaecf_id = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
               and p.dt_ini         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
               and p.dt_fin         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
               and p.dm_per_apur    = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
               and l.perapurlr_id  = p.id
               and td.id           = l.tabdinecf_id
               and td.cd           in ('175', '349', '203', '142');
          exception
            when others then
              vn_m350_175 := 0;
              vn_m350_349 := 0;
              vn_m350_203 := 0;
              vn_m350_142 := 0;
          end;
          --
          if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_cod_qualif_pj = '01' then
            vn_valor := nvl(vn_m350_175, 0) + nvl(vn_m350_349, 0);
          elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_cod_qualif_pj = '02' then
            vn_valor := nvl(vn_m350_203, 0);
          elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_cod_qualif_pj = '03' then
            vn_valor := nvl(vn_m350_142, 0);
          else
            vn_valor := 0;
          end if;
          --
        exception
          when others then
            vn_valor := 0;
        end;
        --
      else
        --
        -- SE (0010.COD_QUALIF_PJ( ) = "01") ENTAO
        --    SE (M350(175) <= 0 E M350(349) <= 0) ENTAO
        --       M350(175) + M350(349)
        --    SENAO
        --       DEBITO(M350(175))+DEBITO(M350(349))
        --    FIM_SE
        -- SENAO
        --    SE (0010.COD_QUALIF_PJ( )= "02") ENTAO
        --       M350(203)
        --    SENAO
        --       SE (0010.COD_QUALIF_PJ( ) = "03") ENTAO
        --          M350(142)
        --       SENAO
        --          0
        --       FIM_SE
        --    FIM_SE
        -- FIM_SE
        declare
          --
          vn_m350_175 number;
          vn_m350_349 number;
          vn_m350_203 number;
          vn_m350_142 number;
          --
        begin
          --
          begin
            select nvl( sum( case when td.cd = '175' then l.valor else 0 end ) ,0),
                   nvl( sum( case when td.cd = '349' then l.valor else 0 end ) ,0),
                   nvl( sum( case when td.cd = '203' then l.valor else 0 end ) ,0),
                   nvl( sum( case when td.cd = '142' then l.valor else 0 end ) ,0)
              into vn_m350_175, 
                   vn_m350_349, 
                   vn_m350_203, 
                   vn_m350_142
              from per_apur_lr p, 
                   lanc_part_a_lacs l, 
                   tab_din_ecf td
             where p.aberturaecf_id = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
               and p.dt_ini         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
               and p.dt_fin         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
               and p.dm_per_apur    = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
               and l.perapurlr_id   = p.id
               and td.id            = l.tabdinecf_id
               and td.cd            in ('175', '349', '203', '142');
          exception
            when others then
              vn_m350_175 := 0;
              vn_m350_349 := 0;
              vn_m350_203 := 0;
              vn_m350_142 := 0;
          end;
          --
          if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_cod_qualif_pj = '01' then
            --
            --    SE (M350(175) <= 0 E M350(349) <= 0) ENTAO
            --       M350(175) + M350(349)
            --    SENAO
            --       DEBITO(M350(175))+DEBITO(M350(349))
            --    FIM_SE
            --
            if nvl(vn_m350_175, 0) <= 0 and nvl(vn_m350_349, 0) <= 0 then
              --
              vn_valor := nvl(vn_m350_175, 0) + nvl(vn_m350_349, 0);
              --
            else
              --
              vn_valor := nvl(vn_m350_175, 0) + nvl(vn_m350_349, 0);
              --
            end if;
            --
          elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_cod_qualif_pj = '02' then
            --
            vn_valor := nvl(vn_m350_203, 0);
            --
          elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_cod_qualif_pj = '03' then
            --
            vn_valor := nvl(vn_m350_142, 0);
            --
          else
            --
            vn_valor := 0;
            --
          end if;
          --
        exception
          when others then
            vn_valor := 0;
        end;
        --
      end if;
      --
    end if;
    --
    vn_fase := 99;
    --
    -- Quando valor NEGATIVO, atribuir ZERO
    /*if nvl(vn_valor, 0) < 0 then
      vn_valor := 0;
    end if;*/
    --
    vn_fase := 99.1;
    --
    update bc_csll_comp_neg
       set valor   = nvl(vn_valor, 0), 
           dm_tipo = 1 -- Calculado
     where id      = rec.bccsllcompneg_id;
    --
    commit;
    --
  end loop;
  --
exception
  when others then
    --
    pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_soma_vlr_bccsllcp fase(' || vn_fase || '):' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico.id%type;
    begin
      pk_csf_api_secf.pkb_log_generico(sn_loggenerico_id => vn_loggenerico_id,
                                       ev_mensagem       => pk_csf_api_secf.gv_mensagem_log,
                                       ev_resumo         => pk_csf_api_secf.gv_mensagem_log,
                                       en_tipo_log       => pk_csf_api_secf.ERRO_DE_SISTEMA,
                                       en_referencia_id  => pk_csf_api_secf.gn_referencia_id,
                                       ev_obj_referencia => pk_csf_api_secf.gv_obj_referencia);
    exception
      when others then
        null;
    end;
    --
end pkb_soma_vlr_bccsllcp;

-------------------------------------------------------------------------------------------------------

-- Procedimento de atualizar os valores de Base de Cálculo da CSLL Após as Compensações da Base de Cálculo Negativa
procedure pkb_atual_vlr_bccsllcp ( en_percalcapurlr_id  in per_calc_apur_lr.id%type )
is
   --
   vn_fase number;
   vn_loggenerico_id  log_generico.id%type;
   --
   vv_dominio_descr Dominio.descr%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   gt_log_generico.delete;
   --
   if nvl(en_percalcapurlr_id,0) > 0 then
      --
      vn_fase := 2;
      --
      pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
      --
      begin
         --
         select *
           into pk_csf_api_secf.gt_row_per_calc_apur_lr
           from per_calc_apur_lr
          where id = en_percalcapurlr_id;
         --
      exception
         when others then
            pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
      end;
      --
      vn_fase := 3;
      --
      if nvl(pk_csf_api_secf.gt_row_per_calc_apur_lr.id,0) > 0 then
         --
         pk_csf_api_secf.pkb_inicia_param ( en_aberturaecf_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id );
         --
         vn_fase := 4;
         -- Procedimento seta o objeto de referencia utilizado na Validação da Informação
         pk_csf_api_secf.pkb_seta_obj_ref ( ev_objeto => 'PER_CALC_APUR_LR' );
         --
         vn_fase := 4.1;
         -- Procedimento seta o "ID de Referencia" utilizado na Validação da Informação
         pk_csf_api_secf.pkb_seta_referencia_id ( en_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.id );
         --
         vn_fase := 5;
         --
         -- Chama Procedimento para somar os valores de Base de Cálculo da CSLL Após as Compensações da Base de Cálculo Negativa
         pkb_soma_vlr_bccsllcp;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_atual_vlr_bccsllcp fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_atual_vlr_bccsllcp;

-------------------------------------------------------------------------------------------------------

-- Procedimento para somar os valores de Cálculo do IRPJ Com Base no Lucro Real
procedure pkb_soma_vlr_cirpjblr
is
   --
   vn_fase number;
   --
   vn_valor calc_irpj_base_lr.valor%type;
   vn_tipo  calc_irpj_base_lr.dm_tipo%type;
   --
   cursor c_dados2 is
   select d.id                   calcirpjbaselr_id
        , td.id                  tabdinecf_id
        , td.registroecf_id
        , td.cd                  tabdinecf_cd
        , td.ordem
        , c.cod_ent_ref
     from calc_irpj_base_lr  d
        , tab_din_ecf        td
        , cod_ent_ref        c
    where d.percalcapurlr_id    = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
      and td.id                 = d.tabdinecf_id
      and td.dm_tipo            in ('CA', 'CNA')
      and c.id                  = td.codentref_id
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados2 loop
      exit when c_dados2%notfound or (c_dados2%notfound) is null;
      --
      vn_fase := 5;
      --
      vn_valor := 0;
      --
      if rec.cod_ent_ref = '01' then -- PJ em Geral (L100A + L300A da ECF)
         --
         if rec.tabdinecf_cd = '1' then -- BASE DE CÁLCULO DO IRPJ
            --
            vn_fase := 6;
            -- N500(1)
            begin
               select d.valor
                 into vn_valor
                 from bc_irpj_lr_comp_prej   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('1');
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         elsif rec.tabdinecf_cd = '3' then -- À Alíquota de 15%
            --
            vn_fase := 7;
            -- N630(1) * 0,15
            declare
               --
               vn_n630_1 number;
               --
            begin
               --
               vn_fase := 7.1;
               --
               begin
                  select d.valor
                    into vn_n630_1
                    from calc_irpj_base_lr      d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('1');
               exception
                  when others then
                     vn_n630_1 := 0;
               end;
               --
               vn_fase := 7.2;
               --
               if nvl(vn_n630_1,0) > 0 then
                  vn_valor := nvl(vn_n630_1,0) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_irpj,0) / 100);
               else
                  vn_valor := 0;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         elsif rec.tabdinecf_cd = '4' then -- Adicional
            --
            vn_fase := 8;
            /*
SE (N630(1) <= 20000 * MESES_PERIODO()) ENTAO 
   0 
SENAO 
  (N630(1) - 20000 * MESES_PERIODO()) * 0,1 
FIM_SE
            */
            declare
               --
               vn_n630_1 number;
               vn_base   number;
               --
            begin
               --
               vn_fase := 8.1;
               --
               begin
                  select d.valor
                    into vn_n630_1
                    from calc_irpj_base_lr      d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('1');
               exception
                  when others then
                     vn_n630_1 := 0;
               end;
               --
               vn_fase := 8.2;
               --
               vn_base := nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin);
               --
               vn_fase := 8.3;
               --
               if nvl(vn_n630_1,0) <= nvl(vn_base,0) then
                  vn_valor := 0;
               else
                  vn_valor := ( nvl(vn_n630_1,0) - nvl(vn_base,0) ) * 0.1;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         elsif rec.tabdinecf_cd = '17' then -- (-) Isenção e Redução do Imposto
            --
            vn_fase := 9;
            -- N610(76)
            begin
               select d.valor
                 into vn_valor
                 from calc_isen_red_imp_lr   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('76');
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         elsif rec.tabdinecf_cd = '18' then -- (-) Redução por Reinvestimento
            --
            vn_fase := 10;
            -- N610 (77)
            begin
               select d.valor
                 into vn_valor
                 from calc_isen_red_imp_lr   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('77');
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         elsif rec.tabdinecf_cd = '26' then -- IMPOSTO DE RENDA A PAGAR
            --
            vn_fase := 11;
            -- SOMA(N630(3:4)) - SOMA(N630(6:25))
            declare
               --
               vn_vl_1 number;
               vn_vl_2 number;
               --
            begin
               --
               vn_fase := 11.1;
               --
               begin
                  select sum( d.valor )
                    into vn_vl_1
                    from calc_irpj_base_lr      d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) between 3 and 4;
               exception
                  when others then
                     vn_vl_1 := 0;
               end;
               --
               vn_fase := 11.2;
               --
               begin
                  select sum( d.valor )
                    into vn_vl_2
                    from calc_irpj_base_lr      d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) between 6 and 25;
               exception
                  when others then
                     vn_vl_2 := 0;
               end;
               --
               vn_fase := 11.3;
               --
               vn_valor := nvl(vn_vl_1,0) - nvl(vn_vl_2,0);
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         end if;
         --
      elsif rec.cod_ent_ref = '03' then -- Financeiras (L100B + L300B da ECF)
         --
         vn_fase := 12;
         --
         if rec.tabdinecf_cd = '1' then -- BASE DE CÁLCULO DO IRPJ
            --
            vn_fase := 13;
            -- N500(1)
            begin
               select d.valor
                 into vn_valor
                 from bc_irpj_lr_comp_prej   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('1');
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         elsif rec.tabdinecf_cd = '3' then -- À Alíquota de 15%
            --
            vn_fase := 14;
            -- N630(1) * 0,15
            declare
               --
               vn_n630_1 number;
               --
            begin
               --
               vn_fase := 14.1;
               --
               begin
                  select d.valor
                    into vn_n630_1
                    from calc_irpj_base_lr      d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('1');
               exception
                  when others then
                     vn_n630_1 := 0;
               end;
               --
               vn_fase := 14.2;
               --
               if nvl(vn_n630_1,0) > 0 then
                  vn_valor := nvl(vn_n630_1,0) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_irpj,0) / 100);
               else
                  vn_valor := 0;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         elsif rec.tabdinecf_cd = '4' then -- Adicional
            --
            vn_fase := 15;
            /*
SE (N630(1) <= 20000 * MESES_PERIODO()) ENTAO
   0
SENAO
  (N630(1) - 20000 * MESES_PERIODO()) * 0,1
FIM_SE
            */
            declare
               --
               vn_n630_1 number;
               vn_base   number;
               --
            begin
               --
               vn_fase := 15.1;
               --
               begin
                  select d.valor
                    into vn_n630_1
                    from calc_irpj_base_lr      d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('1');
               exception
                  when others then
                     vn_n630_1 := 0;
               end;
               --
               vn_fase := 15.2;
               --
               vn_base := nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin);
               --
               vn_fase := 15.3;
               --
               if nvl(vn_n630_1,0) <= nvl(vn_base,0) then
                  vn_valor := 0;
               else
                  vn_valor := ( nvl(vn_n630_1,0) - nvl(vn_base,0) ) * 0.1;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         elsif rec.tabdinecf_cd = '23' then -- IMPOSTO DE RENDA A PAGAR
            --
            vn_fase := 11;
            -- SOMA(N630(3:4)) - SOMA(N630(5:21))
            declare
               --
               vn_vl_1 number;
               vn_vl_2 number;
               --
            begin
               --
               vn_fase := 11.1;
               --
               begin
                  select sum( d.valor )
                    into vn_vl_1
                    from calc_irpj_base_lr      d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) between 3 and 4;
               exception
                  when others then
                     vn_vl_1 := 0;
               end;
               --
               vn_fase := 11.2;
               --
               begin
                  select sum( d.valor )
                    into vn_vl_2
                    from calc_irpj_base_lr      d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) between 5 and 21;
               exception
                  when others then
                     vn_vl_2 := 0;
               end;
               --
               vn_fase := 11.3;
               --
               vn_valor := nvl(vn_vl_1,0) - nvl(vn_vl_2,0);
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         end if;
         --
      end if;
      --
      vn_fase := 99;
      --
      update calc_irpj_base_lr set valor    = nvl(vn_valor,0)
                                 , dm_tipo  = 1 -- Calculado
       where id = rec.calcirpjbaselr_id;
      --
      commit;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_soma_vlr_cirpjblr fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_soma_vlr_cirpjblr;

-------------------------------------------------------------------------------------------------------

-- Procedimento de atualizar os valores de Cálculo do IRPJ Com Base no Lucro Real
procedure pkb_atual_vlr_cirpjblr ( en_percalcapurlr_id  in per_calc_apur_lr.id%type )
is
   --
   vn_fase number;
   vn_loggenerico_id  log_generico.id%type;
   --
   vv_dominio_descr Dominio.descr%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   gt_log_generico.delete;
   --
   if nvl(en_percalcapurlr_id,0) > 0 then
      --
      vn_fase := 2;
      --
      pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
      --
      begin
         --
         select *
           into pk_csf_api_secf.gt_row_per_calc_apur_lr
           from per_calc_apur_lr
          where id = en_percalcapurlr_id;
         --
      exception
         when others then
            pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
      end;
      --
      vn_fase := 3;
      --
      if nvl(pk_csf_api_secf.gt_row_per_calc_apur_lr.id,0) > 0 then
         --
         pk_csf_api_secf.pkb_inicia_param ( en_aberturaecf_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id );
         --
         vn_fase := 4;
         -- Procedimento seta o objeto de referencia utilizado na Validação da Informação
         pk_csf_api_secf.pkb_seta_obj_ref ( ev_objeto => 'PER_CALC_APUR_LR' );
         --
         vn_fase := 4.1;
         -- Procedimento seta o "ID de Referencia" utilizado na Validação da Informação
         pk_csf_api_secf.pkb_seta_referencia_id ( en_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.id );
         --
         vn_fase := 5;
         --
         -- Chama Procedimento para somar os valores de Cálculo do IRPJ Com Base no Lucro Real
         pkb_soma_vlr_cirpjblr;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_atual_vlr_cirpjblr fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_atual_vlr_cirpjblr;

-------------------------------------------------------------------------------------------------------

-- Procedimento para somar os valores de Cálculo do IRPJ Mensal por Estimativa
procedure pkb_soma_vlr_cirpjme
is
   --
   vn_fase number;
   --
   vn_valor calc_irpj_mes_estim.valor%type;
   vn_tipo  calc_irpj_mes_estim.dm_tipo%type;
   --
   cursor c_dados2 is
   select d.id                   calcirpjmesestim_id
        , td.id                  tabdinecf_id
        , td.registroecf_id
        , td.cd                  tabdinecf_cd
        , td.ordem
     from calc_irpj_mes_estim    d
        , tab_din_ecf            td
    where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
      and td.id                  = d.tabdinecf_id
      and td.dm_tipo             in ('CA', 'CNA')
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados2 loop
      exit when c_dados2%notfound or (c_dados2%notfound) is null;
      --
      vn_fase := 5;
      --
      vn_valor := 0;
      --
      if rec.tabdinecf_cd = '1' then -- Base de Cálculo do Imposto de Renda
         --
         vn_fase := 6;
         -- SE (BAL_RED(PERIODO_ATUAL()) = "B") ENTAO N500(1) SENAO N500(2) FIM_SE
         --
         declare
            --
            vn_n500_1 number;
            vn_n500_2 number;
            --
         begin
            --
            vn_fase := 6.1;
            --
            begin
               select nvl( sum( case when td.cd = '1' then d.valor else 0 end ) ,0)
                    , nvl( sum( case when td.cd = '2' then d.valor else 0 end ) ,0)
                 into vn_n500_1
                    , vn_n500_2
                 from bc_irpj_lr_comp_prej   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('1', '2');
            exception
               when others then
                  vn_n500_1 := 0;
                  vn_n500_2 := 0;
            end;
            --
            vn_fase := 6.2;
            --
            if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A01' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red1 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A02' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red2 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A03' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red3 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A04' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red4 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A05' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red5 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A06' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red6 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A07' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red7 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A08' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red8 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A09' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red9 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A10' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red10 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A11' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red11 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A12' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red12 = 'B' then
                  vn_valor := nvl(vn_n500_1,0);
               else
                  vn_valor := nvl(vn_n500_2,0);
               end if;
            else
               vn_valor := 0;
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '3' then -- A Alíquota de 15%
         --
         vn_fase := 7;
         -- SE (N620(1) > 0) ENTAO N620(1)*0,15 SENAO 0 FIM_SE
         declare
            --
            vn_n620_1 number;
            --
         begin
            --
            vn_fase := 7.1;
            --
            begin
               select d.valor
                 into vn_n620_1
                 from calc_irpj_mes_estim    d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('1');
            exception
               when others then
                  vn_n620_1 := 0;
            end;
            --
            vn_fase := 7.2;
            --
            if nvl(vn_n620_1,0) > 0 then
               vn_valor := nvl(vn_n620_1,0) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_irpj,0) / 100);
            else
               vn_valor := 0;
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '4' then -- Adicional
         --
         vn_fase := 8;
         --
         if pk_csf_api_secf.gv_versao_layout_ecf_cd = '100' then
            --
         /*
SE (N620(1) > 0) ENTAO
   SE (N620(1) > 20000 * MESES_PERIODO()) ENTAO 
     ((N620(1) - 20000 * MESES_PERIODO()) * 0,1)
   SENAO
     0
   FIM_SE
FIM_SE
         */
            --
            declare
               --
               vn_n620_1 number;
               vn_base   number;
               --
            begin
               --
               vn_fase := 8.1;
               --
               begin
                  select d.valor
                    into vn_n620_1
                    from calc_irpj_mes_estim    d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('1');
               exception
                  when others then
                     vn_n620_1 := 0;
               end;
               --
               vn_fase := 8.2;
               --
               vn_base := nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin);
               --
               vn_fase := 8.3;
               --
               if nvl(vn_n620_1,0) > 0 then
                  if nvl(vn_n620_1,0) > nvl(vn_base,0) then
                     vn_valor := (nvl(vn_n620_1,0) - nvl(vn_base,0)) * 0.1;
                  else
                     vn_valor := 0;
                  end if;
               else
                  vn_valor := 0;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         else
            --
/*
SE (BAL_RED(PERIODO_ ATUAL()) = "B") ENTAO
   SE (N620(1) > 0) ENTAO 
      SE (N620(1) > 20000 * MESES_PERIODO()) ENTAO 
         ((N620(1) - 20000 * MESES_PERIODO()) * 0,1) 
      SENAO  
         0 
      FIM_SE 
   SENAO 
      0 
   FIM_SE 
SENAO 
   SE (BAL_RED(PERIODO_ ATUAL()) = "E") ENTAO 
      SE (N620(1) > 0) ENTAO
         SE (N620(1) > 20000) ENTAO 
            ((N620(1) - 20000) * 0,1) 
         SENAO 
            0 
         FIM_SE 
      SENAO 
         0 
      FIM_SE 
   FIM_SE 
FIM_SE
*/
            --
            declare
               --
               vn_n620_1 number;
               vn_base   number;
               vv_periodo_atual varchar2(1);
               --
            begin
               --
               vn_fase := 8.1;
               --
               begin
                  select d.valor
                    into vn_n620_1
                    from calc_irpj_mes_estim    d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('1');
               exception
                  when others then
                     vn_n620_1 := 0;
               end;
               --
               vn_fase := 8.2;
               --
               vn_base := nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin);
               --
               vn_fase := 8.3;
               --
               if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A01' then
                  if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red1 = 'B' then
                     vv_periodo_atual := 'B';
                  elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red1 = 'E' then
                     vv_periodo_atual := 'E';
                  else
                     vv_periodo_atual := null;
                  end if;
               elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A02' then
                  if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red2 = 'B' then
                     vv_periodo_atual := 'B';
                  elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red2 = 'E' then
                     vv_periodo_atual := 'E';
                  else
                     vv_periodo_atual := null;
                  end if;
               elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A03' then
                  if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red3 = 'B' then
                     vv_periodo_atual := 'B';
                  elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red3 = 'E' then
                     vv_periodo_atual := 'E';
                  else
                     vv_periodo_atual := null;
                  end if;
               elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A04' then
                  if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red4 = 'B' then
                     vv_periodo_atual := 'B';
                  elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red4 = 'E' then
                     vv_periodo_atual := 'E';
                  else
                     vv_periodo_atual := null;
                  end if;
               elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A05' then
                  if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red5 = 'B' then
                     vv_periodo_atual := 'B';
                  elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red5 = 'E' then
                     vv_periodo_atual := 'E';
                  else
                     vv_periodo_atual := null;
                  end if;
               elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A06' then
                  if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red6 = 'B' then
                     vv_periodo_atual := 'B';
                  elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red6 = 'E' then
                     vv_periodo_atual := 'E';
                  else
                     vv_periodo_atual := null;
                  end if;
               elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A07' then
                  if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red7 = 'B' then
                     vv_periodo_atual := 'B';
                  elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red7 = 'E' then
                     vv_periodo_atual := 'E';
                  else
                     vv_periodo_atual := null;
                  end if;
               elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A08' then
                  if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red8 = 'B' then
                     vv_periodo_atual := 'B';
                  elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red8 = 'E' then
                     vv_periodo_atual := 'E';
                  else
                     vv_periodo_atual := null;
                  end if;
               elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A09' then
                  if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red9 = 'B' then
                     vv_periodo_atual := 'B';
                  elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red9 = 'E' then
                     vv_periodo_atual := 'E';
                  else
                     vv_periodo_atual := null;
                  end if;
               elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A10' then
                  if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red10 = 'B' then
                     vv_periodo_atual := 'B';
                  elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red10 = 'E' then
                     vv_periodo_atual := 'E';
                  else
                     vv_periodo_atual := null;
                  end if;
               elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A11' then
                  if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red11 = 'B' then
                     vv_periodo_atual := 'B';
                  elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red11 = 'E' then
                     vv_periodo_atual := 'E';
                  else
                     vv_periodo_atual := null;
                  end if;
               elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A12' then
                  if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red12 = 'B' then
                     vv_periodo_atual := 'B';
                  elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red12 = 'E' then
                     vv_periodo_atual := 'E';
                  else
                     vv_periodo_atual := null;
                  end if;
               else
                  vv_periodo_atual := null;
               end if;
               --
               vn_fase := 8.4;
               --
               if nvl(vn_n620_1,0) > 0 then
                  if nvl(vn_n620_1,0) > nvl(vn_base,0) then
                     vn_valor := (nvl(vn_n620_1,0) - nvl(vn_base,0)) * 0.1;
                  else
                     vn_valor := 0;
                  end if;
               else
                  vn_valor := 0;
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         end if;
         --
      elsif rec.tabdinecf_cd = '18' then -- (-) Isenção e Redução do Imposto
         --
         vn_fase := 9;
         -- N610(76)
         begin
            --
            select sum( d.valor )
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('76');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '19' then -- (-) Redução por Reinvestimento
         --
         vn_fase := 10;
         -- N610(77)
         begin
            --
            select sum( d.valor )
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('77');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '20' then -- (-) Imposto de Renda Devido em Meses Anteriores
         --
         vn_fase := 10;
         /*
SE (BAL_RED(PERIODO_ATUAL()) = "B") ENTAO
   ( SOMA(N620("20.01";"A01":PERIODO_ANTERIOR())) )
FIM_SE
         */
         declare
            --
            vn_n620_20_1 number;
            --
         begin
            --
            vn_fase := 10.1;
            -- PERIODO_ANTERIOR
            begin
               select nvl(sum(d.valor),0)
                 into vn_n620_20_1
                 from per_calc_apur_lr       p
                    , calc_irpj_mes_estim    d
                    , tab_din_ecf            td
                where p.aberturaecf_id             = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and to_number(to_char(p.dt_fin, 'rrrrmm')) <= (to_number(to_char(pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin, 'rrrrmm')) - 1)
                  and d.percalcapurlr_id           = p.id
                  and td.id                        = d.tabdinecf_id
                  and td.cd in ('20.01');
            exception
               when others then
                  vn_n620_20_1 := 0;
            end;
            --
            vn_fase := 10.2;
            --
            if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A01' then
               --
               /*
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red1 = 'B' then
                  --
                  -- Mês atual calcula ele mesmo
                  --
                  declare
                     --
                     vn_vl_1 number;
                     vn_vl_2 number;
                     --
                  begin
                     --
                     begin
                        select nvl( sum( d.valor ) ,0)
                          into vn_vl_1
                          from calc_irpj_mes_estim   d
                             , tab_din_ecf            td
                         where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                           and td.id                  = d.tabdinecf_id
                           and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) between 3 and 5;
                     exception
                        when others then
                           vn_vl_1 := 0;
                     end;
                     --
                     begin
                        select nvl( sum( d.valor ) ,0)
                          into vn_vl_2
                          from calc_irpj_mes_estim   d
                             , tab_din_ecf            td
                         where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                           and td.id                  = d.tabdinecf_id
                           and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) between 7 and 20;
                     exception
                        when others then
                           vn_vl_2 := 0;
                     end;
                     --
                     vn_n620_20_1 := nvl(vn_vl_1,0) - nvl(vn_vl_2,0);
                     --
                     if nvl(vn_n620_20_1,0) < 0 then
                        vn_n620_20_1 := 0;
                     end if;
                     --
                  exception
                     when others then
                        vn_n620_20_1 := 0;
                  end;
                  --
                  vn_valor := nvl(vn_n620_20_1,0);
               else
                  vn_valor := 0;
               end if; */
               --
               vn_valor := 0;
               --
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A02' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red2 = 'B' then
                  vn_valor := nvl(vn_n620_20_1,0);
               else
                  vn_valor := 0;
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A03' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red3 = 'B' then
                  vn_valor := nvl(vn_n620_20_1,0);
               else
                  vn_valor := 0;
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A04' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red4 = 'B' then
                  vn_valor := nvl(vn_n620_20_1,0);
               else
                  vn_valor := 0;
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A05' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red5 = 'B' then
                  vn_valor := nvl(vn_n620_20_1,0);
               else
                  vn_valor := 0;
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A06' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red6 = 'B' then
                  vn_valor := nvl(vn_n620_20_1,0);
               else
                  vn_valor := 0;
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A07' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red7 = 'B' then
                  vn_valor := nvl(vn_n620_20_1,0);
               else
                  vn_valor := 0;
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A08' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red8 = 'B' then
                  vn_valor := nvl(vn_n620_20_1,0);
               else
                  vn_valor := 0;
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A09' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red9 = 'B' then
                  vn_valor := nvl(vn_n620_20_1,0);
               else
                  vn_valor := 0;
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A10' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red10 = 'B' then
                  vn_valor := nvl(vn_n620_20_1,0);
               else
                  vn_valor := 0;
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A11' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red11 = 'B' then
                  vn_valor := nvl(vn_n620_20_1,0);
               else
                  vn_valor := 0;
               end if;
            elsif pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A12' then
               if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red12 = 'B' then
                  vn_valor := nvl(vn_n620_20_1,0);
               else
                  vn_valor := 0;
               end if;
            else
               vn_valor := 0;
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '20.01' then -- Imposto de Renda Devido no Mês
         --
         vn_fase := 11;
         /*
SE(SOMA(N620(3:5)) - SOMA(N620(7:20))>0) ENTAO 
   SOMA(N620(3:5)) - SOMA(N620(7:20))
SENAO 0
FIM_SE
         */
         declare
            --
            vn_vl_1 number;
            vn_vl_2 number;
            --
         begin
            --
            vn_fase := 11.1;
            --
            begin
               select nvl( sum( d.valor ) ,0)
                 into vn_vl_1
                 from calc_irpj_mes_estim   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) between 3 and 5;
            exception
               when others then
                  vn_vl_1 := 0;
            end;
            --
            vn_fase := 11.2;
            --
            begin
               select nvl( sum( d.valor ) ,0)
                 into vn_vl_2
                 from calc_irpj_mes_estim   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and ( td.cd <> '20.01' and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) between 7 and 20 );
            exception
               when others then
                  vn_vl_2 := 0;
            end;
            --
            vn_fase := 11.3;
            --
            vn_valor := nvl(vn_vl_1,0) - nvl(vn_vl_2,0);
            --
            if nvl(vn_valor,0) < 0 then
               vn_valor := 0;
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '26' then -- IMPOSTO DE RENDA A PAGAR
         --
         vn_fase := 12;
         -- SOMA(N620(3:5)) - SOMA(N620(7:20)) - SOMA(N620(21:25))
         declare
            --
            vn_vl_1 number;
            vn_vl_2 number;
            vn_vl_3 number;
            --
         begin
            --
            vn_fase := 12.1;
            --
            begin
               select nvl( sum( d.valor ) ,0)
                 into vn_vl_1
                 from calc_irpj_mes_estim   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) between 3 and 5;
            exception
               when others then
                  vn_vl_1 := 0;
            end;
            --
            vn_fase := 12.2;
            --
            begin
               select nvl( sum( d.valor ) ,0)
                 into vn_vl_2
                 from calc_irpj_mes_estim   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and ( td.cd <> '20.01' and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) between 7 and 20 );
            exception
               when others then
                  vn_vl_2 := 0;
            end;
            --
            vn_fase := 12.3;
            --
            begin
               select nvl( sum( d.valor ) ,0)
                 into vn_vl_3
                 from calc_irpj_mes_estim   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) between 21 and 25.99;
            exception
               when others then
                  vn_vl_3 := 0;
            end;
            --
            vn_fase := 12.4;
            --
            vn_valor := nvl(vn_vl_1,0) - nvl(vn_vl_2,0) - nvl(vn_vl_3,0);
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      end if;
      --
      vn_fase := 99;
      --
      update calc_irpj_mes_estim set valor    = nvl(vn_valor,0)
                                   , dm_tipo  = 1 -- Calculado
       where id = rec.calcirpjmesestim_id;
      --
      commit;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_soma_vlr_cirpjme fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_soma_vlr_cirpjme;

-------------------------------------------------------------------------------------------------------

-- Procedimento de atualizar os valores de Cálculo do IRPJ Mensal por Estimativa
procedure pkb_atual_vlr_cirpjme ( en_percalcapurlr_id  in per_calc_apur_lr.id%type )
is
   --
   vn_fase number;
   vn_loggenerico_id  log_generico.id%type;
   --
   vv_dominio_descr Dominio.descr%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   gt_log_generico.delete;
   --
   if nvl(en_percalcapurlr_id,0) > 0 then
      --
      vn_fase := 2;
      --
      pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
      --
      begin
         --
         select *
           into pk_csf_api_secf.gt_row_per_calc_apur_lr
           from per_calc_apur_lr
          where id = en_percalcapurlr_id;
         --
      exception
         when others then
            pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
      end;
      --
      vn_fase := 3;
      --
      if nvl(pk_csf_api_secf.gt_row_per_calc_apur_lr.id,0) > 0 then
         --
         pk_csf_api_secf.pkb_inicia_param ( en_aberturaecf_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id );
         --
         vn_fase := 4;
         -- Procedimento seta o objeto de referencia utilizado na Validação da Informação
         pk_csf_api_secf.pkb_seta_obj_ref ( ev_objeto => 'PER_CALC_APUR_LR' );
         --
         vn_fase := 4.1;
         -- Procedimento seta o "ID de Referencia" utilizado na Validação da Informação
         pk_csf_api_secf.pkb_seta_referencia_id ( en_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.id );
         --
         vn_fase := 5;
         --
         -- Chama Procedimento para somar os valores de Cálculo do IRPJ Mensal por Estimativa
         pkb_soma_vlr_cirpjme;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_atual_vlr_cirpjme fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_atual_vlr_cirpjme;

-------------------------------------------------------------------------------------------------------

-- Procedimento para somar os valores de Cálculo da Isenção e Redução do Imposto Sobre o Lucro Real
procedure pkb_soma_vlr_cirilr
is
   --
   vn_fase number;
   --
   vn_valor dem_lucro_expl.valor%type;
   vn_tipo  dem_lucro_expl.dm_tipo%type;
   --
   cursor c_dados2 is
   select d.id                   calcisenredimplr_id
        , td.id                  tabdinecf_id
        , td.registroecf_id
        , td.cd                  tabdinecf_cd
        , td.ordem
     from calc_isen_red_imp_lr   d
        , tab_din_ecf            td
    where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
      and td.id                  = d.tabdinecf_id
      and td.dm_tipo             in ('CA', 'CNA')
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados2 loop
      exit when c_dados2%notfound or (c_dados2%notfound) is null;
      --
      vn_fase := 5;
      --
      vn_valor := 0;
      --
      if rec.tabdinecf_cd = '1' then -- Lucro da Exploração da Atividade de Ensino Superior - Prouni
         --
         vn_fase := 6;
         -- SE (N600(50) > 0) ENTAO N600(50) SENAO 0 FIM_SE
         declare
            --
            vn_valor1 number := 0;
            --
         begin
            --
            vn_fase := 6.1;
            --
            begin
               --
               select nvl( sum( d.valor ) ,0)
                 into vn_valor1
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd = '50';
               --
            exception
               when others then
                  vn_valor1 := 0;
            end;
            --
            vn_fase := 6.2;
            --
            if nvl(vn_valor1,0) > 0 then
               vn_valor := nvl(vn_valor1,0);
            else
               vn_valor := 0;
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '2' then -- Imposto
         --
         vn_fase := 7;
         -- N610(1)*0,15
         begin
            --
            select sum( d.valor )
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('1');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_fase := 7.1;
         --
         vn_valor := nvl(vn_valor,0) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_irpj,0) / 100);
         --
      elsif rec.tabdinecf_cd = '3' then -- Adicional
         --
         vn_fase := 8;
         --
         if pk_csf_api_secf.gv_versao_layout_ecf_cd = '100' then
            --
         /*
SE (M300(175) + M300(349) < N600(48)) ENTAO
   SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO
      0
   SENAO
      SE (N600(19) = 0) ENTAO
         0
      SENAO
         (N600(2)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/N600(19)
      FIM_SE
   FIM_SE
SENAO 
   SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO
     0
   SENAO (N600(50)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/(M300(175) + M300(349))
   FIM_SE
FIM_SE
         */
            --
            declare
               --
               vn_m300_175 number := 0;
               vn_m300_349 number := 0;
               vn_n500_1 number := 0;
               vn_n600_48 number := 0;
               vn_n600_19 number := 0;
               vn_n600_2 number := 0;
               vn_n600_50 number := 0;
               --
            begin
               --
               vn_fase := 8.1;
               --
               begin
                  --
                  select lpal.valor
                    into vn_m300_175
                    from per_apur_lr        p
                       , lanc_part_a_lalur  lpal
                       , tab_din_ecf        td
                   where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                     and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                     and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                     and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                     and lpal.perapurlr_id     = p.id
                     and td.id                 = lpal.tabdinecf_id
                     and td.cd                 = '175';
                  --
               exception
                  when others then
                     vn_m300_175 := 0;
               end;
               --
               vn_fase := 8.2;
               --
               begin
                  --
                  select lpal.valor
                    into vn_m300_349
                    from per_apur_lr        p
                       , lanc_part_a_lalur  lpal
                       , tab_din_ecf        td
                   where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                     and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                     and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                     and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                     and lpal.perapurlr_id     = p.id
                     and td.id                 = lpal.tabdinecf_id
                     and td.cd                 = '349';
                  --
               exception
                  when others then
                     vn_m300_349 := 0;
               end;
               --
               vn_fase := 8.3;
               --
               begin
                  --
                  select nvl( sum( d.valor ) ,0)
                    into vn_n500_1
                    from bc_irpj_lr_comp_prej   d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd = '1';
                  --
               exception
                  when others then
                     vn_n500_1 := 0;
               end;
               --
               vn_fase := 8.4;
               --
               begin
                  --
                  select nvl( sum( case when td.cd = '48' then d.valor else 0 end) ,0)
                       , nvl( sum( case when td.cd = '19' then d.valor else 0 end) ,0)
                       , nvl( sum( case when td.cd = '2' then d.valor else 0 end) ,0)
                       , nvl( sum( case when td.cd = '50' then d.valor else 0 end) ,0)
                    into vn_n600_48
                       , vn_n600_19
                       , vn_n600_2
                       , vn_n600_50
                    from dem_lucro_expl         d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('48', '19', '2', '50');
                  --
               exception
                  when others then
                     vn_n600_48 := 0;
                     vn_n600_19 := 0;
                     vn_n600_2 := 0;
                     vn_n600_50 := 0;
               end;
               --
               vn_fase := 8.99;
               --
               if ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) ) < nvl(vn_n600_48,0) then
                  --
                  if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                     vn_valor := 0;
                  else
                     if nvl(vn_n600_19,0) = 0 then
                        vn_valor := 0;
                     else
                        vn_valor := ( nvl(vn_n600_2,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / nvl(vn_n600_19,0);
                     end if;
                  end if;
                  --
               else
                  --
                  if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                     vn_valor := 0;
                  else
                     vn_valor := ( nvl(vn_n600_50,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) );
                  end if;
                  --
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         else
            --
            /*
SE (N500(1) < N600(48)) ENTAO
   SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
      0 
   SENAO 
      SE (N600(19) = 0) ENTAO
         0
      SENAO
         (N600(2)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/N600(19)
      FIM_SE 
   FIM_SE  
SENAO 
   SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
      0 
   SENAO 
      (N600(50)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/(M300(175) + M300(349)) 
   FIM_SE 
FIM_SE
*/
            --
            declare
               --
               vn_m300_175 number := 0;
               vn_m300_349 number := 0;
               vn_n500_1 number := 0;
               vn_n600_48 number := 0;
               vn_n600_19 number := 0;
               vn_n600_2 number := 0;
               vn_n600_50 number := 0;
               --
            begin
               --
               vn_fase := 8.1;
               --
               begin
                  --
                  select lpal.valor
                    into vn_m300_175
                    from per_apur_lr        p
                       , lanc_part_a_lalur  lpal
                       , tab_din_ecf        td
                   where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                     and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                     and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                     and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                     and lpal.perapurlr_id     = p.id
                     and td.id                 = lpal.tabdinecf_id
                     and td.cd                 = '175';
                  --
               exception
                  when others then
                     vn_m300_175 := 0;
               end;
               --
               vn_fase := 8.2;
               --
               begin
                  --
                  select lpal.valor
                    into vn_m300_349
                    from per_apur_lr        p
                       , lanc_part_a_lalur  lpal
                       , tab_din_ecf        td
                   where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                     and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                     and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                     and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                     and lpal.perapurlr_id     = p.id
                     and td.id                 = lpal.tabdinecf_id
                     and td.cd                 = '349';
                  --
               exception
                  when others then
                     vn_m300_349 := 0;
               end;
               --
               vn_fase := 8.3;
               --
               begin
                  --
                  select nvl( sum( d.valor ) ,0)
                    into vn_n500_1
                    from bc_irpj_lr_comp_prej   d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd = '1';
                  --
               exception
                  when others then
                     vn_n500_1 := 0;
               end;
               --
               vn_fase := 8.4;
               --
               begin
                  --
                  select nvl( sum( case when td.cd = '48' then d.valor else 0 end) ,0)
                       , nvl( sum( case when td.cd = '19' then d.valor else 0 end) ,0)
                       , nvl( sum( case when td.cd = '2' then d.valor else 0 end) ,0)
                       , nvl( sum( case when td.cd = '50' then d.valor else 0 end) ,0)
                    into vn_n600_48
                       , vn_n600_19
                       , vn_n600_2
                       , vn_n600_50
                    from dem_lucro_expl         d
                       , tab_din_ecf            td
                   where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                     and td.id                  = d.tabdinecf_id
                     and td.cd in ('48', '19', '2', '50');
                  --
               exception
                  when others then
                     vn_n600_48 := 0;
                     vn_n600_19 := 0;
                     vn_n600_2 := 0;
                     vn_n600_50 := 0;
               end;
               --
               vn_fase := 8.99;
               --
               if nvl(vn_n500_1,0) < nvl(vn_n600_48,0) then
                  --
                  if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                     vn_valor := 0;
                  else
                     if nvl(vn_n600_19,0) = 0 then
                        vn_valor := 0;
                     else
                        vn_valor := ( nvl(vn_n600_2,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / nvl(vn_n600_19,0);
                     end if;
                  end if;
                  --
               else
                  --
                  if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                     vn_valor := 0;
                  else
                     vn_valor := ( nvl(vn_n600_50,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) );
                  end if;
                  --
               end if;
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         end if;
         --
      elsif rec.tabdinecf_cd = '4' then -- SUBTOTAL
         --
         vn_fase := 9;
         -- N610(2) + N610(3)
         begin
            --
            select nvl( sum( case when td.cd = '2' then d.valor else 0 end) ,0) + nvl( sum( case when td.cd = '3' then d.valor else 0 end) ,0)
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('2', '3');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '5' then -- ISENÇÃO
         --
         vn_fase := 10;
         -- N610(4)*1,00
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('4');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '6' then -- Lucro da Exploração de Projeto Industrial ou Agrícola - Sudam/Sudene
         --
         vn_fase := 11;
         -- SE (N600(51) > 0) ENTAO N600(51) SENAO 0 FIM_SE
         begin
            --
            select d.valor
              into vn_valor
              from dem_lucro_expl         d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('51');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         if nvl(vn_valor,0) <= 0 then
            vn_valor := 0;
         end if;
         --
      elsif rec.tabdinecf_cd = '7' then -- Imposto
         --
         vn_fase := 12;
         -- N610(6)*0,15
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('6');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100);
         --
      elsif rec.tabdinecf_cd = '8' then -- Adicional
         --
         vn_fase := 12;
         --
/*
SE (M300(175) + M300(349) < N600(48)) ENTAO 
   SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
      0 
   SENAO 
      SE (N600(19) = 0) ENTAO 
         0 
      SENAO 
         (N600(3)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/N600(19) 
      FIM_SE 
   FIM_SE 
SENAO 
   SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
      0 
   SENAO 
      (N600(51)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/(M300(175) + M300(349)) 
   FIM_SE 
FIM_SE
*/
         --
         declare
            --
            vn_m300_175 number := 0;
            vn_m300_349 number := 0;
            vn_n500_1 number := 0;
            vn_n600_48 number := 0;
            vn_n600_19 number := 0;
            vn_n600_3 number := 0;
            vn_n600_51 number := 0;
            --
         begin
            --
            vn_fase := 12.1;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_175
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '175';
               --
            exception
               when others then
                  vn_m300_175 := 0;
            end;
            --
            vn_fase := 12.2;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_349
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '349';
               --
            exception
               when others then
                  vn_m300_349 := 0;
            end;
            --
            vn_fase := 12.3;
            --
            begin
               --
               select nvl( sum( d.valor ) ,0)
                 into vn_n500_1
                 from bc_irpj_lr_comp_prej   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd = '1';
               --
            exception
               when others then
                  vn_n500_1 := 0;
            end;
            --
            vn_fase := 12.4;
            --
            begin
               --
               select nvl( sum( case when td.cd = '48' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '19' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '3' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '51' then d.valor else 0 end) ,0)
                 into vn_n600_48
                    , vn_n600_19
                    , vn_n600_3
                    , vn_n600_51
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('48', '19', '3', '51');
               --
            exception
               when others then
                  vn_n600_48 := 0;
                  vn_n600_19 := 0;
                  vn_n600_3 := 0;
                  vn_n600_51 := 0;
            end;
            --
            --
            vn_fase := 12.99;
            --
            if ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) ) < nvl(vn_n600_48,0) then
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  if nvl(vn_n600_19,0) = 0 then
                     vn_valor := 0;
                  else
                     vn_valor := ( nvl(vn_n600_3,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / nvl(vn_n600_19,0);
                  end if;
               end if;
               --
            else
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  vn_valor := ( nvl(vn_n600_51,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) );
               end if;
               --
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '9' then -- SUBTOTAL
         --
         vn_fase := 13;
         -- N610(7) + N610(8)
         begin
            --
            select nvl( sum( case when td.cd = '7' then d.valor else 0 end) ,0) + nvl( sum( case when td.cd = '8' then d.valor else 0 end) ,0)
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('7', '8');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '10' then -- ISENÇÃO
         --
         vn_fase := 14;
         -- N610(9)*1,00
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('9');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '11' then -- Lucro da Exploração da Atividade Integrante de Programa de Inclusão Digital - Sudam/Sudene
         --
         vn_fase := 15;
         -- SE (N600(52) > 0) ENTAO N600(52) SENAO 0 FIM_SE
         begin
            --
            select d.valor
              into vn_valor
              from dem_lucro_expl         d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('52');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         if nvl(vn_valor,0) <= 0 then
            vn_valor := 0;
         end if;
         --
      elsif rec.tabdinecf_cd = '12' then -- Imposto
         --
         vn_fase := 16;
         -- N610(11)*0,15
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('11');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100);
         --
      elsif rec.tabdinecf_cd = '13' then -- Adicional
         --
         vn_fase := 17;
         --
/*
SE (M300(175) + M300(349) < N600(48)) ENTAO 
   SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
      0 
   SENAO 
      SE (N600(19) = 0) ENTAO 
         0 
      SENAO 
         (N600(4)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/N600(19)
      FIM_SE 
   FIM_SE 
SENAO 
   SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
      0 
   SENAO 
      (N600(52)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/(M300(175) + M300(349)) 
   FIM_SE 
FIM_SE
*/
         --
         declare
            --
            vn_m300_175 number := 0;
            vn_m300_349 number := 0;
            vn_n500_1 number := 0;
            vn_n600_48 number := 0;
            vn_n600_19 number := 0;
            vn_n600_4 number := 0;
            vn_n600_52 number := 0;
            --
         begin
            --
            vn_fase := 17.1;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_175
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '175';
               --
            exception
               when others then
                  vn_m300_175 := 0;
            end;
            --
            vn_fase := 17.2;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_349
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '349';
               --
            exception
               when others then
                  vn_m300_349 := 0;
            end;
            --
            vn_fase := 17.3;
            --
            begin
               --
               select nvl( sum( d.valor ) ,0)
                 into vn_n500_1
                 from bc_irpj_lr_comp_prej   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd = '1';
               --
            exception
               when others then
                  vn_n500_1 := 0;
            end;
            --
            vn_fase := 17.4;
            --
            begin
               --
               select nvl( sum( case when td.cd = '48' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '19' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '4' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '52' then d.valor else 0 end) ,0)
                 into vn_n600_48
                    , vn_n600_19
                    , vn_n600_4
                    , vn_n600_52
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('48', '19', '4', '52');
               --
            exception
               when others then
                  vn_n600_48 := 0;
                  vn_n600_19 := 0;
                  vn_n600_4 := 0;
                  vn_n600_52 := 0;
            end;
            --
            --
            vn_fase := 17.99;
            --
            if ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) ) < nvl(vn_n600_48,0) then
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  if nvl(vn_n600_19,0) = 0 then
                     vn_valor := 0; 
                  else
                     vn_valor := ( nvl(vn_n600_4,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / nvl(vn_n600_19,0);
                  end if;
               end if;
               --
            else
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  vn_valor := ( nvl(vn_n600_52,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) );
               end if;
               --
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '14' then -- SUBTOTAL
         --
         vn_fase := 18;
         -- N610(12) + N610(13)
         begin
            --
            select nvl( sum( case when td.cd = '12' then d.valor else 0 end) ,0) + nvl( sum( case when td.cd = '13' then d.valor else 0 end) ,0)
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('12', '13');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '15' then -- ISENÇÃO
         --
         vn_fase := 19;
         -- N610(14)*1,00
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('14');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '16' then -- Lucro da Exploração da Atividade Integrante de Programa de Inclusão Digital - Sudam/Sudene
         --
         vn_fase := 20;
         -- SE (N600(53) > 0) ENTAO N600(53) SENAO 0 FIM_SE
         begin
            --
            select d.valor
              into vn_valor
              from dem_lucro_expl         d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('53');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         if nvl(vn_valor,0) <= 0 then
            vn_valor := 0;
         end if;
         --
      elsif rec.tabdinecf_cd = '17' then -- Imposto
         --
         vn_fase := 21;
         -- N610(16)*0,15
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('16');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0) / 100) ;
         --
      elsif rec.tabdinecf_cd = '18' then -- Adicional
         --
         vn_fase := 22;
         --
/*
SE (M300(175) + M300(349) < N600(48)) ENTAO 
   SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
      0 
   SENAO 
      SE (N600(19) = 0) ENTAO 
         0 
      SENAO 
         (N600(5)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/N600(19) 
      FIM_SE
   FIM_SE 
SENAO 
   SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
      0 
   SENAO
      (N600(53)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/(M300(175) + M300(349))
   FIM_SE 
FIM_SE
*/
         --
         declare
            --
            vn_m300_175 number := 0;
            vn_m300_349 number := 0;
            vn_n500_1 number := 0;
            vn_n600_48 number := 0;
            vn_n600_19 number := 0;
            vn_n600_5 number := 0;
            vn_n600_53 number := 0;
            --
         begin
            --
            vn_fase := 22.1;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_175
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '175';
               --
            exception
               when others then
                  vn_m300_175 := 0;
            end;
            --
            vn_fase := 22.2;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_349
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '349';
               --
            exception
               when others then
                  vn_m300_349 := 0;
            end;
            --
            vn_fase := 22.3;
            --
            begin
               --
               select nvl( sum( d.valor ) ,0)
                 into vn_n500_1
                 from bc_irpj_lr_comp_prej   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd = '1';
               --
            exception
               when others then
                  vn_n500_1 := 0;
            end;
            --
            vn_fase := 22.4;
            --
            begin
               --
               select nvl( sum( case when td.cd = '48' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '19' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '5' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '53' then d.valor else 0 end) ,0)
                 into vn_n600_48
                    , vn_n600_19
                    , vn_n600_5
                    , vn_n600_53
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('48', '19', '5', '53');
               --
            exception
               when others then
                  vn_n600_48 := 0;
                  vn_n600_19 := 0;
                  vn_n600_5 := 0;
                  vn_n600_53 := 0;
            end;
            --
            --
            vn_fase := 22.99;
            --
            if ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) ) < nvl(vn_n600_48,0) then
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  if nvl(vn_n600_19,0) = 0 then
                     vn_valor := 0; 
                  else
                     vn_valor := ( nvl(vn_n600_5,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / nvl(vn_n600_19,0);
                  end if;
               end if;
               --
            else
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  vn_valor := ( nvl(vn_n600_53,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) );
               end if;
               --
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '19' then -- SUBTOTAL
         --
         vn_fase := 23;
         -- N610(17) + N610(18)
         begin
            --
            select nvl( sum( case when td.cd = '17' then d.valor else 0 end) ,0) + nvl( sum( case when td.cd = '18' then d.valor else 0 end) ,0)
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('17', '18');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '20' then -- ISENÇÃO
         --
         vn_fase := 24;
         -- N610(19)*1,00
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('19');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '21' then -- Lucro da Exploração de Eventos da Fifa
         --
         vn_fase := 25;
         -- SE (N600(54) > 0) ENTAO N600(54) SENAO 0 FIM_SE
         begin
            --
            select d.valor
              into vn_valor
              from dem_lucro_expl         d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('54');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         if nvl(vn_valor,0) <= 0 then
            vn_valor := 0;
         end if;
         --
      elsif rec.tabdinecf_cd = '22' then -- Imposto
         --
         vn_fase := 26;
         -- N610(21)*0,15
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('21');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0) / 100);
         --
      elsif rec.tabdinecf_cd = '23' then -- Adicional
         --
         vn_fase := 27;
         --
/*
SE (M300(175) + M300(349) < N600(48)) ENTAO 
   SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
      0 
   SENAO 
      SE (N600(19) = 0) ENTAO 
         0 
      SENAO 
         (N600(6)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/N600(19) 
      FIM_SE 
   FIM_SE 
SENAO 
  SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
     0 
  SENAO 
     (N600(54)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/(M300(175) + M300(349)) 
  FIM_SE 
FIM_SE
*/
         --
         declare
            --
            vn_m300_175 number := 0;
            vn_m300_349 number := 0;
            vn_n500_1 number := 0;
            vn_n600_48 number := 0;
            vn_n600_19 number := 0;
            vn_n600_6 number := 0;
            vn_n600_54 number := 0;
            --
         begin
            --
            vn_fase := 27.1;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_175
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '175';
               --
            exception
               when others then
                  vn_m300_175 := 0;
            end;
            --
            vn_fase := 27.2;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_349
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '349';
               --
            exception
               when others then
                  vn_m300_349 := 0;
            end;
            --
            vn_fase := 27.3;
            --
            begin
               --
               select nvl( sum( d.valor ) ,0)
                 into vn_n500_1
                 from bc_irpj_lr_comp_prej   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd = '1';
               --
            exception
               when others then
                  vn_n500_1 := 0;
            end;
            --
            vn_fase := 27.4;
            --
            begin
               --
               select nvl( sum( case when td.cd = '48' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '19' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '6' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '54' then d.valor else 0 end) ,0)
                 into vn_n600_48
                    , vn_n600_19
                    , vn_n600_6
                    , vn_n600_54
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('48', '19', '6', '54');
               --
            exception
               when others then
                  vn_n600_48 := 0;
                  vn_n600_19 := 0;
                  vn_n600_6 := 0;
                  vn_n600_54 := 0;
            end;
            --
            --
            vn_fase := 27.99;
            --
            if ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) ) < nvl(vn_n600_48,0) then
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  if nvl(vn_n600_19,0) = 0 then
                     vn_valor := 0; 
                  else
                     vn_valor := ( nvl(vn_n600_6,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / nvl(vn_n600_19,0);
                  end if;
               end if;
               --
            else
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  vn_valor := ( nvl(vn_n600_54,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) );
               end if;
               --
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '24' then -- SUBTOTAL
         --
         vn_fase := 28;
         -- N610(22) + N610(23)
         begin
            --
            select nvl( sum( case when td.cd = '22' then d.valor else 0 end) ,0) + nvl( sum( case when td.cd = '23' then d.valor else 0 end) ,0)
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('22', '23');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '25' then -- ISENÇÃO
         --
         vn_fase := 29;
         -- N610(24)*1,00
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('24');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '26' then -- Lucro da Exploração da Atividade de Serviços - SPE - Eventos da Fifa
         --
         vn_fase := 30;
         -- SE (N600(55) > 0) ENTAO N600(55) SENAO 0 FIM_SE
         begin
            --
            select d.valor
              into vn_valor
              from dem_lucro_expl         d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('55');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         if nvl(vn_valor,0) <= 0 then
            vn_valor := 0;
         end if;
         --
      elsif rec.tabdinecf_cd = '27' then -- Imposto
         --
         vn_fase := 31;
         -- N610(26)*0,15
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('26');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100);
         --
      elsif rec.tabdinecf_cd = '28' then -- Adicional
         --
         vn_fase := 32;
         --
/*
SE (M300(175) + M300(349) < N600(48)) ENTAO 
   SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
      0
   SENAO
      SE (N600(19) = 0) ENTAO 
         0 
      SENAO 
         (N600(7)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/N600(19)
      FIM_SE 
   FIM_SE 
SENAO 
  SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
     0 
  SENAO 
     (N600(55)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/(M300(175) + M300(349))
  FIM_SE 
FIM_SE
*/
         --
         declare
            --
            vn_m300_175 number := 0;
            vn_m300_349 number := 0;
            vn_n500_1 number := 0;
            vn_n600_48 number := 0;
            vn_n600_19 number := 0;
            vn_n600_7 number := 0;
            vn_n600_55 number := 0;
            --
         begin
            --
            vn_fase := 32.1;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_175
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '175';
               --
            exception
               when others then
                  vn_m300_175 := 0;
            end;
            --
            vn_fase := 32.2;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_349
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '349';
               --
            exception
               when others then
                  vn_m300_349 := 0;
            end;
            --
            vn_fase := 32.3;
            --
            begin
               --
               select nvl( sum( d.valor ) ,0)
                 into vn_n500_1
                 from bc_irpj_lr_comp_prej   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd = '1';
               --
            exception
               when others then
                  vn_n500_1 := 0;
            end;
            --
            vn_fase := 32.4;
            --
            begin
               --
               select nvl( sum( case when td.cd = '48' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '19' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '7' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '55' then d.valor else 0 end) ,0)
                 into vn_n600_48
                    , vn_n600_19
                    , vn_n600_7
                    , vn_n600_55
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('48', '19', '7', '55');
               --
            exception
               when others then
                  vn_n600_48 := 0;
                  vn_n600_19 := 0;
                  vn_n600_7 := 0;
                  vn_n600_55 := 0;
            end;
            --
            --
            vn_fase := 32.99;
            --
            if ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) ) < nvl(vn_n600_48,0) then
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  if nvl(vn_n600_19,0) = 0 then
                     vn_valor := 0; 
                  else
                     vn_valor := ( nvl(vn_n600_7,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / nvl(vn_n600_19,0);
                  end if;
               end if;
               --
            else
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  vn_valor := ( nvl(vn_n600_55,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) );
               end if;
               --
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '29' then -- SUBTOTAL
         --
         vn_fase := 33;
         -- N610(27) + N610(28)
         begin
            --
            select nvl( sum( case when td.cd = '27' then d.valor else 0 end) ,0) + nvl( sum( case when td.cd = '28' then d.valor else 0 end) ,0)
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('27', '28');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '30' then -- ISENÇÃO
         --
         vn_fase := 34;
         -- N610(29)*1,00
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('29');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '31' then -- Lucro da Exploração de Eventos do CIO
         --
         vn_fase := 35;
         -- SE (N600(56) > 0) ENTAO N600(56) SENAO 0 FIM_SE
         begin
            --
            select d.valor
              into vn_valor
              from dem_lucro_expl         d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('56');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         if nvl(vn_valor,0) <= 0 then
            vn_valor := 0;
         end if;
         --
      elsif rec.tabdinecf_cd = '32' then -- Imposto
         --
         vn_fase := 36;
         -- N610(31)*0,15
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('31');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100);
         --
      elsif rec.tabdinecf_cd = '33' then -- Adicional
         --
         vn_fase := 37;
         --
/*
SE (M300(175) + M300(349) < N600(48)) ENTAO 
   SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
      0 
   SENAO 
      SE (N600(19) = 0) ENTAO 
         0 
      SENAO 
         (N600(8)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/N600(19)
      FIM_SE 
   FIM_SE 
SENAO 
  SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
     0 
  SENAO 
     (N600(56)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/(M300(175) + M300(349))
  FIM_SE 
FIM_SE
*/
         --
         declare
            --
            vn_m300_175 number := 0;
            vn_m300_349 number := 0;
            vn_n500_1 number := 0;
            vn_n600_48 number := 0;
            vn_n600_19 number := 0;
            vn_n600_8 number := 0;
            vn_n600_56 number := 0;
            --
         begin
            --
            vn_fase := 37.1;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_175
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '175';
               --
            exception
               when others then
                  vn_m300_175 := 0;
            end;
            --
            vn_fase := 37.2;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_349
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '349';
               --
            exception
               when others then
                  vn_m300_349 := 0;
            end;
            --
            vn_fase := 37.3;
            --
            begin
               --
               select nvl( sum( d.valor ) ,0)
                 into vn_n500_1
                 from bc_irpj_lr_comp_prej   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd = '1';
               --
            exception
               when others then
                  vn_n500_1 := 0;
            end;
            --
            vn_fase := 37.4;
            --
            begin
               --
               select nvl( sum( case when td.cd = '48' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '19' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '8' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '56' then d.valor else 0 end) ,0)
                 into vn_n600_48
                    , vn_n600_19
                    , vn_n600_8
                    , vn_n600_56
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('48', '19', '8', '56');
               --
            exception
               when others then
                  vn_n600_48 := 0;
                  vn_n600_19 := 0;
                  vn_n600_8 := 0;
                  vn_n600_56 := 0;
            end;
            --
            --
            vn_fase := 37.99;
            --
            if ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) ) < nvl(vn_n600_48,0) then
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  if nvl(vn_n600_19,0) = 0 then
                     vn_valor := 0; 
                  else
                     vn_valor := ( nvl(vn_n600_8,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / nvl(vn_n600_19,0);
                  end if;
               end if;
               --
            else
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  vn_valor := ( nvl(vn_n600_56,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0) / 100) ) ) ) ) / ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) );
               end if;
               --
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '34' then -- SUBTOTAL
         --
         vn_fase := 38;
         -- N610(32) + N610(33)
         begin
            --
            select nvl( sum( case when td.cd = '32' then d.valor else 0 end) ,0) + nvl( sum( case when td.cd = '33' then d.valor else 0 end) ,0)
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('32', '33');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '35' then -- REDUÇÃO
         --
         vn_fase := 39;
         -- N610(34)*1,00
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('34');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * 1;
         --
      elsif rec.tabdinecf_cd = '36' then -- Lucro da Exploração da Atividade de Serviços – SPE - Eventos do CIO
         --
         vn_fase := 40;
         -- SE (N600(57) > 0) ENTAO N600(57) SENAO 0 FIM_SE
         begin
            --
            select d.valor
              into vn_valor
              from dem_lucro_expl         d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('57');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         if nvl(vn_valor,0) <= 0 then
            vn_valor := 0;
         end if;
         --
      elsif rec.tabdinecf_cd = '37' then -- Imposto
         --
         vn_fase := 41;
         -- N610(36)*0,15
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('36');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0) / 100);
         --
      elsif rec.tabdinecf_cd = '38' then -- Adicional
         --
         vn_fase := 42;
         --
/*
SE (M300(175) + M300(349) < N600(48)) ENTAO 
   SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
      0 
   SENAO 
      SE (N600(19) = 0) ENTAO 
         0 
      SENAO 
         (N600(9)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/N600(19)
      FIM_SE 
   FIM_SE 
SENAO 
  SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
     0 
  SENAO 
     (N600(57)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/(M300(175) + M300(349))
  FIM_SE
FIM_SE
*/
         --
         declare
            --
            vn_m300_175 number := 0;
            vn_m300_349 number := 0;
            vn_n500_1 number := 0;
            vn_n600_48 number := 0;
            vn_n600_19 number := 0;
            vn_n600_9 number := 0;
            vn_n600_57 number := 0;
            --
         begin
            --
            vn_fase := 42.1;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_175
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '175';
               --
            exception
               when others then
                  vn_m300_175 := 0;
            end;
            --
            vn_fase := 42.2;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_349
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '349';
               --
            exception
               when others then
                  vn_m300_349 := 0;
            end;
            --
            vn_fase := 42.3;
            --
            begin
               --
               select nvl( sum( d.valor ) ,0)
                 into vn_n500_1
                 from bc_irpj_lr_comp_prej   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd = '1';
               --
            exception
               when others then
                  vn_n500_1 := 0;
            end;
            --
            vn_fase := 42.4;
            --
            begin
               --
               select nvl( sum( case when td.cd = '48' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '19' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '9' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '57' then d.valor else 0 end) ,0)
                 into vn_n600_48
                    , vn_n600_19
                    , vn_n600_9
                    , vn_n600_57
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('48', '19', '9', '57');
               --
            exception
               when others then
                  vn_n600_48 := 0;
                  vn_n600_19 := 0;
                  vn_n600_9 := 0;
                  vn_n600_57 := 0;
            end;
            --
            --
            vn_fase := 42.99;
            --
            if ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) ) < nvl(vn_n600_48,0) then
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  if nvl(vn_n600_19,0) = 0 then
                     vn_valor := 0; 
                  else
                     vn_valor := ( nvl(vn_n600_9,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / nvl(vn_n600_19,0);
                  end if;
               end if;
               --
            else
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  vn_valor := ( nvl(vn_n600_57,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) );
               end if;
               --
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '39' then -- SUBTOTAL
         --
         vn_fase := 43;
         -- N610(37) + N610(38)
         begin
            --
            select nvl( sum( case when td.cd = '37' then d.valor else 0 end) ,0) + nvl( sum( case when td.cd = '38' then d.valor else 0 end) ,0)
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('37', '38');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '40' then -- REDUÇÃO
         --
         vn_fase := 44;
         -- N610(39)*1,00
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('40');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * 1;
         --
      elsif rec.tabdinecf_cd = '41' then -- Lucro da Exploração da Atividade com Redução de 100% - Padis
         --
         vn_fase := 45;
         -- SE (N600(58) > 0) ENTAO N600(58) SENAO 0 FIM_SE
         begin
            --
            select d.valor
              into vn_valor
              from dem_lucro_expl         d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('58');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         if nvl(vn_valor,0) <= 0 then
            vn_valor := 0;
         end if;
         --
      elsif rec.tabdinecf_cd = '42' then -- Imposto
         --
         vn_fase := 46;
         -- N610(41)*0,15
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('42');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0) /100);
         --
      elsif rec.tabdinecf_cd = '43' then -- Adicional
         --
         vn_fase := 47;
         --
/*
SE (M300(175) + M300(349) < N600(48)) ENTAO 
   SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
      0 
   SENAO 
      SE (N600(19) = 0) ENTAO 
         0 
      SENAO 
         (N600(10)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/N600(19)
      FIM_SE 
   FIM_SE 
SENAO 
  SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO
     0
  SENAO 
     (N600(58)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/(M300(175) + M300(349))
  FIM_SE
FIM_SE
*/
         --
         declare
            --
            vn_m300_175 number := 0;
            vn_m300_349 number := 0;
            vn_n500_1 number := 0;
            vn_n600_48 number := 0;
            vn_n600_19 number := 0;
            vn_n600_10 number := 0;
            vn_n600_58 number := 0;
            --
         begin
            --
            vn_fase := 47.1;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_175
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '175';
               --
            exception
               when others then
                  vn_m300_175 := 0;
            end;
            --
            vn_fase := 47.2;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_349
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '349';
               --
            exception
               when others then
                  vn_m300_349 := 0;
            end;
            --
            vn_fase := 47.3;
            --
            begin
               --
               select nvl( sum( d.valor ) ,0)
                 into vn_n500_1
                 from bc_irpj_lr_comp_prej   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd = '1';
               --
            exception
               when others then
                  vn_n500_1 := 0;
            end;
            --
            vn_fase := 47.4;
            --
            begin
               --
               select nvl( sum( case when td.cd = '48' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '19' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '10' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '58' then d.valor else 0 end) ,0)
                 into vn_n600_48
                    , vn_n600_19
                    , vn_n600_10
                    , vn_n600_58
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('48', '19', '10', '58');
               --
            exception
               when others then
                  vn_n600_48 := 0;
                  vn_n600_19 := 0;
                  vn_n600_10 := 0;
                  vn_n600_58 := 0;
            end;
            --
            --
            vn_fase := 47.99;
            --
            if ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) ) < nvl(vn_n600_48,0) then
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  if nvl(vn_n600_19,0) = 0 then
                     vn_valor := 0; 
                  else
                     vn_valor := ( nvl(vn_n600_10,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / nvl(vn_n600_19,0);
                  end if;
               end if;
               --
            else
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  vn_valor := ( nvl(vn_n600_58,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) );
               end if;
               --
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '44' then -- SUBTOTAL
         --
         vn_fase := 48;
         -- N610(42) + N610(43)
         begin
            --
            select nvl( sum( case when td.cd = '42' then d.valor else 0 end) ,0) + nvl( sum( case when td.cd = '43' then d.valor else 0 end) ,0)
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('42', '43');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '45' then -- REDUÇÃO
         --
         vn_fase := 49;
         -- N610(44)*1,00
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('44');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * 1;
         --
      elsif rec.tabdinecf_cd = '46' then -- Lucro da Exploração da Atividade com Redução de 75%
         --
         vn_fase := 50;
         -- SE (N600(59) > 0) ENTAO N600(59) SENAO 0 FIM_SE
         begin
            --
            select d.valor
              into vn_valor
              from dem_lucro_expl         d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('59');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         if nvl(vn_valor,0) <= 0 then
            vn_valor := 0;
         end if;
         --
      elsif rec.tabdinecf_cd = '47' then -- Imposto
         --
         vn_fase := 51;
         -- N610(46)*0,15
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('46');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0) / 100);
         --
      elsif rec.tabdinecf_cd = '48' then -- Adicional
         --
         vn_fase := 52;
         --
/*
SE (M300(175) + M300(349) < N600(48)) ENTAO 
   SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
      0
   SENAO 
      SE (N600(19) = 0) ENTAO 
         0 
      SENAO 
         (N600(11)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/N600(19)
      FIM_SE 
   FIM_SE 
SENAO 
  SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
     0 
  SENAO 
     (N600(59)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/(M300(175) + M300(349))
  FIM_SE
FIM_SE
*/
         --
         declare
            --
            vn_m300_175 number := 0;
            vn_m300_349 number := 0;
            vn_n500_1 number := 0;
            vn_n600_48 number := 0;
            vn_n600_19 number := 0;
            vn_n600_11 number := 0;
            vn_n600_59 number := 0;
            --
         begin
            --
            vn_fase := 52.1;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_175
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '175';
               --
            exception
               when others then
                  vn_m300_175 := 0;
            end;
            --
            vn_fase := 52.2;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_349
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '349';
               --
            exception
               when others then
                  vn_m300_349 := 0;
            end;
            --
            vn_fase := 52.3;
            --
            begin
               --
               select nvl( sum( d.valor ) ,0)
                 into vn_n500_1
                 from bc_irpj_lr_comp_prej   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd = '1';
               --
            exception
               when others then
                  vn_n500_1 := 0;
            end;
            --
            vn_fase := 52.4;
            --
            begin
               --
               select nvl( sum( case when td.cd = '48' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '19' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '11' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '59' then d.valor else 0 end) ,0)
                 into vn_n600_48
                    , vn_n600_19
                    , vn_n600_11
                    , vn_n600_59
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('48', '19', '11', '59');
               --
            exception
               when others then
                  vn_n600_48 := 0;
                  vn_n600_19 := 0;
                  vn_n600_11 := 0;
                  vn_n600_59 := 0;
            end;
            --
            --
            vn_fase := 52.99;
            --
            if ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) ) < nvl(vn_n600_48,0) then
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  if nvl(vn_n600_19,0) = 0 then
                     vn_valor := 0;
                  else
                     vn_valor := ( nvl(vn_n600_11,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / nvl(vn_n600_19,0);
                  end if;
               end if;
               --
            else
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  vn_valor := ( nvl(vn_n600_59,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0) / 100) ) ) ) ) / ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) );
               end if;
               --
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '49' then -- SUBTOTAL
         --
         vn_fase := 53;
         -- N610(47) + N610(48)
         begin
            --
            select nvl( sum( case when td.cd = '47' then d.valor else 0 end) ,0) + nvl( sum( case when td.cd = '48' then d.valor else 0 end) ,0)
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('47', '48');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '50' then -- REDUÇÃO
         --
         vn_fase := 54;
         -- N610(49)*0,75
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('49');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * 0.75;
         --
      elsif rec.tabdinecf_cd = '51' then -- Lucro da Exploração da Atividade com Redução de 70%
         --
         vn_fase := 55;
         -- SE (N600(60) > 0) ENTAO N600(60) SENAO 0 FIM_SE
         begin
            --
            select d.valor
              into vn_valor
              from dem_lucro_expl         d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('60');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         if nvl(vn_valor,0) <= 0 then
            vn_valor := 0;
         end if;
         --
      elsif rec.tabdinecf_cd = '52' then -- Imposto
         --
         vn_fase := 56;
         -- N610(51)*0,15
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('51');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0) / 100);
         --
      elsif rec.tabdinecf_cd = '53' then -- Adicional
         --
         vn_fase := 57;
         --
/*
SE (M300(175) + M300(349) < N600(48)) ENTAO 
   SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO
      0 
   SENAO 
      SE (N600(19) = 0) ENTAO 
         0 
      SENAO 
         (N600(12)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/N600(19)
      FIM_SE 
   FIM_SE 
SENAO 
  SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
     0 
  SENAO 
     (N600(60)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/(M300(175) + M300(349))
  FIM_SE
FIM_SE
*/
         --
         declare
            --
            vn_m300_175 number := 0;
            vn_m300_349 number := 0;
            vn_n500_1 number := 0;
            vn_n600_48 number := 0;
            vn_n600_19 number := 0;
            vn_n600_12 number := 0;
            vn_n600_60 number := 0;
            --
         begin
            --
            vn_fase := 57.1;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_175
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '175';
               --
            exception
               when others then
                  vn_m300_175 := 0;
            end;
            --
            vn_fase := 57.2;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_349
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '349';
               --
            exception
               when others then
                  vn_m300_349 := 0;
            end;
            --
            vn_fase := 57.3;
            --
            begin
               --
               select nvl( sum( d.valor ) ,0)
                 into vn_n500_1
                 from bc_irpj_lr_comp_prej   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd = '1';
               --
            exception
               when others then
                  vn_n500_1 := 0;
            end;
            --
            vn_fase := 57.4;
            --
            begin
               --
               select nvl( sum( case when td.cd = '48' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '19' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '12' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '60' then d.valor else 0 end) ,0)
                 into vn_n600_48
                    , vn_n600_19
                    , vn_n600_12
                    , vn_n600_60
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('48', '19', '12', '60');
               --
            exception
               when others then
                  vn_n600_48 := 0;
                  vn_n600_19 := 0;
                  vn_n600_12 := 0;
                  vn_n600_60 := 0;
            end;
            --
            --
            vn_fase := 57.99;
            --
            if ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) ) < nvl(vn_n600_48,0) then
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  if nvl(vn_n600_19,0) = 0 then
                     vn_valor := 0; 
                  else
                     vn_valor := ( nvl(vn_n600_12,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0) / 100) ) ) ) ) / nvl(vn_n600_19,0);
                  end if;
               end if;
               --
            else
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  vn_valor := ( nvl(vn_n600_60,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0) / 100) ) ) ) ) / ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) );
               end if;
               --
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '54' then -- SUBTOTAL
         --
         vn_fase := 58;
         -- N610(52) + N610(53)
         begin
            --
            select nvl( sum( case when td.cd = '52' then d.valor else 0 end) ,0) + nvl( sum( case when td.cd = '53' then d.valor else 0 end) ,0)
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('52', '53');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '55' then -- REDUÇÃO
         --
         vn_fase := 59;
         -- N610(54)*0,70
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('54');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * 0.70;
         --
      elsif rec.tabdinecf_cd = '56' then -- Lucro da Exploração da Atividade com Redução de 50%
         --
         vn_fase := 60;
         -- SE (N600(61) > 0) ENTAO N600(61) SENAO 0 FIM_SE
         begin
            --
            select d.valor
              into vn_valor
              from dem_lucro_expl         d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('61');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         if nvl(vn_valor,0) <= 0 then
            vn_valor := 0;
         end if;
         --
      elsif rec.tabdinecf_cd = '57' then -- Imposto
         --
         vn_fase := 61;
         -- N610(56)*0,15
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('56');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0) / 100);
         --
      elsif rec.tabdinecf_cd = '58' then -- Adicional
         --
         vn_fase := 62;
         --
/*
SE (M300(175) + M300(349) < N600(48)) ENTAO 
   SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO
      0 
   SENAO 
      SE (N600(19) = 0) ENTAO 
         0 
      SENAO 
         (N600(13)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/N600(19)
      FIM_SE 
   FIM_SE 
SENAO
  SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
     0 
  SENAO 
     (N600(61)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/(M300(175) + M300(349))
  FIM_SE
FIM_SE
*/
         --
         declare
            --
            vn_m300_175 number := 0;
            vn_m300_349 number := 0;
            vn_n500_1 number := 0;
            vn_n600_48 number := 0;
            vn_n600_19 number := 0;
            vn_n600_13 number := 0;
            vn_n600_61 number := 0;
            --
         begin
            --
            vn_fase := 62.1;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_175
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '175';
               --
            exception
               when others then
                  vn_m300_175 := 0;
            end;
            --
            vn_fase := 62.2;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_349
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '349';
               --
            exception
               when others then
                  vn_m300_349 := 0;
            end;
            --
            vn_fase := 62.3;
            --
            begin
               --
               select nvl( sum( d.valor ) ,0)
                 into vn_n500_1
                 from bc_irpj_lr_comp_prej   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd = '1';
               --
            exception
               when others then
                  vn_n500_1 := 0;
            end;
            --
            vn_fase := 62.4;
            --
            begin
               --
               select nvl( sum( case when td.cd = '48' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '19' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '13' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '61' then d.valor else 0 end) ,0)
                 into vn_n600_48
                    , vn_n600_19
                    , vn_n600_13
                    , vn_n600_61
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('48', '19', '13', '61');
               --
            exception
               when others then
                  vn_n600_48 := 0;
                  vn_n600_19 := 0;
                  vn_n600_13 := 0;
                  vn_n600_61 := 0;
            end;
            --
            --
            vn_fase := 62.99;
            --
            if ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) ) < nvl(vn_n600_48,0) then
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  if nvl(vn_n600_19,0) = 0 then
                     vn_valor := 0; 
                  else
                     vn_valor := ( nvl(vn_n600_13,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / nvl(vn_n600_19,0);
                  end if;
               end if;
               --
            else
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  vn_valor := ( nvl(vn_n600_61,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0) / 100) ) ) ) ) / ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) );
               end if;
               --
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '59' then -- SUBTOTAL
         --
         vn_fase := 63;
         -- N610(57) + N610(58)
         begin
            --
            select nvl( sum( case when td.cd = '57' then d.valor else 0 end) ,0) + nvl( sum( case when td.cd = '58' then d.valor else 0 end) ,0)
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('57', '58');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '60' then -- REDUÇÃO
         --
         vn_fase := 64;
         -- N610(59)*0,50
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('59');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * 0.50;
         --
      elsif rec.tabdinecf_cd = '61' then -- Lucro da Exploração da Atividade com Redução de 33,33%
         --
         vn_fase := 65;
         -- SE (N600(62) > 0) ENTAO N600(62) SENAO 0 FIM_SE
         begin
            --
            select d.valor
              into vn_valor
              from dem_lucro_expl         d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('62');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         if nvl(vn_valor,0) <= 0 then
            vn_valor := 0;
         end if;
         --
      elsif rec.tabdinecf_cd = '62' then -- Imposto
         --
         vn_fase := 66;
         -- N610(61)*0,15
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('61');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0) / 100);
         --
      elsif rec.tabdinecf_cd = '63' then -- Adicional
         --
         vn_fase := 67;
         --
/*
SE (M300(175) + M300(349) < N600(48)) ENTAO 
   SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO
      0 
   SENAO 
      SE (N600(19) = 0) ENTAO 
         0 
      SENAO 
         (N600(14)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/N600(19)
      FIM_SE 
   FIM_SE 
SENAO 
  SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
     0 
  SENAO
     (N600(62)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/(M300(175) + M300(349))
  FIM_SE
FIM_SE
*/
         --
         declare
            --
            vn_m300_175 number := 0;
            vn_m300_349 number := 0;
            vn_n500_1 number := 0;
            vn_n600_48 number := 0;
            vn_n600_19 number := 0;
            vn_n600_14 number := 0;
            vn_n600_62 number := 0;
            --
         begin
            --
            vn_fase := 67.1;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_175
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '175';
               --
            exception
               when others then
                  vn_m300_175 := 0;
            end;
            --
            vn_fase := 67.2;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_349
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '349';
               --
            exception
               when others then
                  vn_m300_349 := 0;
            end;
            --
            vn_fase := 67.3;
            --
            begin
               --
               select nvl( sum( d.valor ) ,0)
                 into vn_n500_1
                 from bc_irpj_lr_comp_prej   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd = '1';
               --
            exception
               when others then
                  vn_n500_1 := 0;
            end;
            --
            vn_fase := 67.4;
            --
            begin
               --
               select nvl( sum( case when td.cd = '48' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '19' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '14' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '62' then d.valor else 0 end) ,0)
                 into vn_n600_48
                    , vn_n600_19
                    , vn_n600_14
                    , vn_n600_62
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('48', '19', '14', '62');
               --
            exception
               when others then
                  vn_n600_48 := 0;
                  vn_n600_19 := 0;
                  vn_n600_14 := 0;
                  vn_n600_62 := 0;
            end;
            --
            --
            vn_fase := 67.99;
            --
            if ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) ) < nvl(vn_n600_48,0) then
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  if nvl(vn_n600_19,0) = 0 then
                     vn_valor := 0;
                  else
                     vn_valor := ( nvl(vn_n600_14,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0) / 100) ) ) ) ) / nvl(vn_n600_19,0);
                  end if;
               end if;
               --
            else
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  vn_valor := ( nvl(vn_n600_62,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) );
               end if;
               --
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '64' then -- SUBTOTAL
         --
         vn_fase := 68;
         -- N610(62) + N610(63)
         begin
            --
            select nvl( sum( case when td.cd = '62' then d.valor else 0 end) ,0) + nvl( sum( case when td.cd = '63' then d.valor else 0 end) ,0)
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('62', '63');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '65' then -- REDUÇÃO
         --
         vn_fase := 69;
         -- N610(64)*0,3333
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('64');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * 0.3333;
         --
      elsif rec.tabdinecf_cd = '66' then -- Lucro da Exploração da Atividade com Redução de 25%
         --
         vn_fase := 70;
         -- SE (N600(63) > 0) ENTAO N600(63) SENAO 0 FIM_SE
         begin
            --
            select d.valor
              into vn_valor
              from dem_lucro_expl         d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('63');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         if nvl(vn_valor,0) <= 0 then
            vn_valor := 0;
         end if;
         --
      elsif rec.tabdinecf_cd = '67' then -- Imposto
         --
         vn_fase := 71;
         -- N610(66)*0,15
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('66');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0) / 100);
         --
      elsif rec.tabdinecf_cd = '67' then -- Imposto
         --
         vn_fase := 72;
         -- N610(61)*0,15
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('61');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0) / 100);
         --
      elsif rec.tabdinecf_cd = '68' then -- Adicional
         --
         vn_fase := 73;
         --
/*
SE (M300(175) + M300(349) < N600(48)) ENTAO 
   SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO
      0 
   SENAO 
      SE (N600(19) = 0) ENTAO 
         0 
      SENAO 
         (N600(15)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/N600(19)
      FIM_SE 
   FIM_SE 
SENAO 
  SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
     0 
  SENAO
     (N600(63)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/(M300(175) + M300(349))
  FIM_SE
FIM_SE
*/
         --
         declare
            --
            vn_m300_175 number := 0;
            vn_m300_349 number := 0;
            vn_n500_1 number := 0;
            vn_n600_48 number := 0;
            vn_n600_19 number := 0;
            vn_n600_15 number := 0;
            vn_n600_63 number := 0;
            --
         begin
            --
            vn_fase := 73.1;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_175
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '175';
               --
            exception
               when others then
                  vn_m300_175 := 0;
            end;
            --
            vn_fase := 73.2;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_349
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '349';
               --
            exception
               when others then
                  vn_m300_349 := 0;
            end;
            --
            vn_fase := 73.3;
            --
            begin
               --
               select nvl( sum( d.valor ) ,0)
                 into vn_n500_1
                 from bc_irpj_lr_comp_prej   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd = '1';
               --
            exception
               when others then
                  vn_n500_1 := 0;
            end;
            --
            vn_fase := 73.4;
            --
            begin
               --
               select nvl( sum( case when td.cd = '48' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '19' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '15' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '63' then d.valor else 0 end) ,0)
                 into vn_n600_48
                    , vn_n600_19
                    , vn_n600_15
                    , vn_n600_63
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('48', '19', '15', '63');
               --
            exception
               when others then
                  vn_n600_48 := 0;
                  vn_n600_19 := 0;
                  vn_n600_15 := 0;
                  vn_n600_63 := 0;
            end;
            --
            --
            vn_fase := 73.99;
            --
            if ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) ) < nvl(vn_n600_48,0) then
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  if nvl(vn_n600_19,0) = 0 then
                     vn_valor := 0;
                  else
                     vn_valor := ( nvl(vn_n600_15,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / nvl(vn_n600_19,0);
                  end if;
               end if;
               --
            else
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  vn_valor := ( nvl(vn_n600_63,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) );
               end if;
               --
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '69' then -- SUBTOTAL
         --
         vn_fase := 74;
         -- N610(67) + N610(68)
         begin
            --
            select nvl( sum( case when td.cd = '67' then d.valor else 0 end) ,0) + nvl( sum( case when td.cd = '68' then d.valor else 0 end) ,0)
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('67', '68');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '70' then -- REDUÇÃO
         --
         vn_fase := 75;
         -- N610(69)*0,25
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('69');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * 0.25;
         --
      elsif rec.tabdinecf_cd = '71' then -- Lucro da Exploração da Atividade com Redução de 12,5%
         --
         vn_fase := 76;
         -- SE (N600(64) > 0) ENTAO N600(64) SENAO 0 FIM_SE
         begin
            --
            select d.valor
              into vn_valor
              from dem_lucro_expl         d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('64');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         if nvl(vn_valor,0) <= 0 then
            vn_valor := 0;
         end if;
         --
      elsif rec.tabdinecf_cd = '72' then -- Imposto
         --
         vn_fase := 77;
         -- N610(71)*0,15
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('71');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0) /100);
         --
      elsif rec.tabdinecf_cd = '73' then -- Adicional
         --
         vn_fase := 78;
         --
/*
SE (M300(175) + M300(349) < N600(48)) ENTAO 
   SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO
      0 
   SENAO 
      SE (N600(19) = 0) ENTAO 
         0 
      SENAO 
         (N600(16)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/N600(19)
      FIM_SE 
   FIM_SE 
SENAO 
  SE (N500(1) <= (20000 * MESES_PERIODO())) ENTAO 
     0 
  SENAO
     (N600(64)*((N500(1) - 20000 * MESES_PERIODO()) * 0,1))/(M300(175) + M300(349))
  FIM_SE
FIM_SE
*/
         --
         declare
            --
            vn_m300_175 number := 0;
            vn_m300_349 number := 0;
            vn_n500_1 number := 0;
            vn_n600_48 number := 0;
            vn_n600_19 number := 0;
            vn_n600_16 number := 0;
            vn_n600_64 number := 0;
            --
         begin
            --
            vn_fase := 78.1;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_175
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '175';
               --
            exception
               when others then
                  vn_m300_175 := 0;
            end;
            --
            vn_fase := 78.2;
            --
            begin
               --
               select lpal.valor
                 into vn_m300_349
                 from per_apur_lr        p
                    , lanc_part_a_lalur  lpal
                    , tab_din_ecf        td
                where p.aberturaecf_id      = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin              = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and lpal.perapurlr_id     = p.id
                  and td.id                 = lpal.tabdinecf_id
                  and td.cd                 = '349';
               --
            exception
               when others then
                  vn_m300_349 := 0;
            end;
            --
            vn_fase := 78.3;
            --
            begin
               --
               select nvl( sum( d.valor ) ,0)
                 into vn_n500_1
                 from bc_irpj_lr_comp_prej   d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd = '1';
               --
            exception
               when others then
                  vn_n500_1 := 0;
            end;
            --
            vn_fase := 78.4;
            --
            begin
               --
               select nvl( sum( case when td.cd = '48' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '19' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '16' then d.valor else 0 end) ,0)
                    , nvl( sum( case when td.cd = '64' then d.valor else 0 end) ,0)
                 into vn_n600_48
                    , vn_n600_19
                    , vn_n600_16
                    , vn_n600_64
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('48', '19', '16', '64');
               --
            exception
               when others then
                  vn_n600_48 := 0;
                  vn_n600_19 := 0;
                  vn_n600_16 := 0;
                  vn_n600_64 := 0;
            end;
            --
            --
            vn_fase := 78.99;
            --
            if ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) ) < nvl(vn_n600_48,0) then
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  if nvl(vn_n600_19,0) = 0 then
                     vn_valor := 0; 
                  else
                     vn_valor := ( nvl(vn_n600_16,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / nvl(vn_n600_19,0);
                  end if;
               end if;
               --
            else
               --
               if nvl(vn_n500_1,0) <= (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) then
                  vn_valor := 0;
               else
                  vn_valor := ( nvl(vn_n600_64,0) * ( (nvl(vn_n500_1,0) - ((nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.vl_bc_adic_irpj,0) * pk_csf_secf.fkg_meses_periodo(pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini, pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin)) * (nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_adic_irpj,0)/100) ) ) ) ) / ( nvl(vn_m300_175,0) + nvl(vn_m300_349,0) );
               end if;
               --
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '74' then -- SUBTOTAL
         --
         vn_fase := 79;
         -- N610(72) + N610(73)
         begin
            --
            select nvl( sum( case when td.cd = '72' then d.valor else 0 end) ,0) + nvl( sum( case when td.cd = '73' then d.valor else 0 end) ,0)
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('72', '73');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '75' then -- REDUÇÃO
         --
         vn_fase := 80;
         -- N610(74)*0,125
         begin
            --
            select d.valor
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ('74');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         vn_valor := nvl(vn_valor,0) * 0.125;
         --
      elsif rec.tabdinecf_cd = '76' then -- TOTAL DA ISENÇÃO E REDUÇÃO
         --
         vn_fase := 81;
         -- N610(5) + N610(10) + N610(15) + N610(20) + N610(25) + N610(30) + N610(35) + N610(40) + N610(45) + N610(50) + N610(55) + N610(60) + N610(65) + N610(70) + N610(75)
         begin
            --
            select nvl( sum( case when td.cd = '5' then d.valor else 0 end) ,0)
                   + nvl( sum( case when td.cd = '10' then d.valor else 0 end) ,0)
                   + nvl( sum( case when td.cd = '15' then d.valor else 0 end) ,0)
                   + nvl( sum( case when td.cd = '20' then d.valor else 0 end) ,0)
                   + nvl( sum( case when td.cd = '25' then d.valor else 0 end) ,0)
                   + nvl( sum( case when td.cd = '30' then d.valor else 0 end) ,0)
                   + nvl( sum( case when td.cd = '35' then d.valor else 0 end) ,0)
                   + nvl( sum( case when td.cd = '40' then d.valor else 0 end) ,0)
                   + nvl( sum( case when td.cd = '45' then d.valor else 0 end) ,0)
                   + nvl( sum( case when td.cd = '50' then d.valor else 0 end) ,0)
                   + nvl( sum( case when td.cd = '55' then d.valor else 0 end) ,0)
                   + nvl( sum( case when td.cd = '60' then d.valor else 0 end) ,0)
                   + nvl( sum( case when td.cd = '65' then d.valor else 0 end) ,0)
                   + nvl( sum( case when td.cd = '70' then d.valor else 0 end) ,0)
                   + nvl( sum( case when td.cd = '75' then d.valor else 0 end) ,0)
              into vn_valor
              from calc_isen_red_imp_lr   d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and td.cd in ( '5', '10', '15', '20', '25', '30', '35', '40', '45', '50', '55', '60', '65', '70', '75' );
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      end if;
      --
      vn_fase := 999;
      --
      update calc_isen_red_imp_lr set valor    = nvl(vn_valor,0)
                                    , dm_tipo  = 1 -- Calculado
       where id = rec.calcisenredimplr_id;
      --
      commit;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_soma_vlr_cirilr fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_soma_vlr_cirilr;

-------------------------------------------------------------------------------------------------------

-- Procedimento de atualizar os valores de Cálculo da Isenção e Redução do Imposto Sobre o Lucro Real
procedure pkb_atual_vlr_cirilr ( en_percalcapurlr_id  in per_calc_apur_lr.id%type )
is
   --
   vn_fase number;
   vn_loggenerico_id  log_generico.id%type;
   --
   vv_dominio_descr Dominio.descr%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   gt_log_generico.delete;
   --
   if nvl(en_percalcapurlr_id,0) > 0 then
      --
      vn_fase := 2;
      --
      pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
      --
      begin
         --
         select *
           into pk_csf_api_secf.gt_row_per_calc_apur_lr
           from per_calc_apur_lr
          where id = en_percalcapurlr_id;
         --
      exception
         when others then
            pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
      end;
      --
      vn_fase := 3;
      --
      if nvl(pk_csf_api_secf.gt_row_per_calc_apur_lr.id,0) > 0 then
         --
         pk_csf_api_secf.pkb_inicia_param ( en_aberturaecf_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id );
         --
         vn_fase := 4;
         -- Procedimento seta o objeto de referencia utilizado na Validação da Informação
         pk_csf_api_secf.pkb_seta_obj_ref ( ev_objeto => 'PER_CALC_APUR_LR' );
         --
         vn_fase := 4.1;
         -- Procedimento seta o "ID de Referencia" utilizado na Validação da Informação
         pk_csf_api_secf.pkb_seta_referencia_id ( en_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.id );
         --
         vn_fase := 5;
         --
         -- Procedimento para somar os valores de Cálculo da Isenção e Redução do Imposto Sobre o Lucro Real
         pkb_soma_vlr_cirilr;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_atual_vlr_cirilr fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_atual_vlr_cirilr;

-------------------------------------------------------------------------------------------------------

-- Procedimento para somar os valores de Demonstração do Lucro da Exploração
procedure pkb_soma_vlr_dle
is
   --
   vn_fase number;
   --
   vn_valor dem_lucro_expl.valor%type;
   vn_tipo  dem_lucro_expl.dm_tipo%type;
   --
   cursor c_dados2 is
   select d.id                   demlucroexpl_id
        , td.id                  tabdinecf_id
        , td.registroecf_id
        , td.cd                  tabdinecf_cd
        , td.ordem
     from dem_lucro_expl         d
        , tab_din_ecf            td
    where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
      and td.id                  = d.tabdinecf_id
      and td.dm_tipo             in ('CA', 'CNA')
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados2 loop
      exit when c_dados2%notfound or (c_dados2%notfound) is null;
      --
      vn_fase := 5;
      --
      vn_valor := 0;
      --
      if rec.tabdinecf_cd = '19' then -- TOTAL DA RECEITA LÍQUIDA
         --
         vn_fase := 6;
         -- SOMA(N600(2:18))
         begin
            --
            select nvl( sum( d.valor ) ,0)
              into vn_valor
              from dem_lucro_expl         d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) between 2 and 18;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '21' then -- Lucro Líquido antes do IRPJ
         --
         vn_fase := 7;
         -- T_DRE(L300("3") - L300("3.02.01.01.01.02"))
         begin
            --
            select sum( decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) ) )
              into vn_valor
              from per_demon_bp         p
                 , det_demon_dre        dre
                 , plano_conta_ref_ecd  pcr
             where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
               and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
               and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
               and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
               and dre.perdemonbp_id    = p.id
               and pcr.id               = dre.planocontarefecd_id
               and pcr.cod_cta_ref      in ('3', '3.02.01.01.01.02');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '22' then -- Ajuste do Regime Tributário de Transição – RTT
         --
         vn_fase := 8;
         -- M300(3)
         begin
            --
            select sum( l.valor )
              into vn_valor
              from per_apur_lr        p
                 , lanc_part_a_lalur  l
                 , tab_din_ecf        td
             where p.aberturaecf_id   = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
               and p.dt_ini           = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
               and p.dt_fin           = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
               and p.dm_per_apur      = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
               and l.perapurlr_id     = p.id
               and td.id              = l.tabdinecf_id
               and td.cd              in ('3');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '23' then -- Lucro Líquido Após Ajuste do RTT
         --
         vn_fase := 9;
         -- N600(21) + N600(22)
         begin
            --
            select nvl( sum( d.valor ) ,0)
              into vn_valor
              from dem_lucro_expl         d
                 , tab_din_ecf            td
             where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
               and td.id                  = d.tabdinecf_id
               and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) between 21 and 22;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '24' then -- Outras Despesas (Lei nº 6.404/1976, art. 187, IV)
         --
         vn_fase := 10;
         -- DEBITO((L300("3.01.01.11.01.05") + L300("3.01.01.11.01.06") + L300("3.01.01.11.01.08") + L300("3.11.01.11.01.05") + L300("3.11.01.11.01.06")+ L300("3.11.01.11.01.08")))
         begin
            --
            select sum( decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) ) )
              into vn_valor
              from per_demon_bp         p
                 , det_demon_dre        dre
                 , plano_conta_ref_ecd  pcr
             where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
               and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
               and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
               and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
               and dre.perdemonbp_id    = p.id
               and pcr.id               = dre.planocontarefecd_id
               and pcr.cod_cta_ref      in ('3.01.01.11.01.05', '3.01.01.11.01.06', '3.01.01.11.01.08', '3.11.01.11.01.05', '3.11.01.11.01.06', '3.11.01.11.01.08');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '25' then -- Contribuição Social sobre o Lucro Líquido
         --
         vn_fase := 11;
         --
         if pk_csf_api_secf.gv_versao_layout_ecf_cd < '300' then
            --
            -- DEBITO(L300("3.02.01.01.01.01")+L300("3.12.01.01.01.01"))
            begin
               --
               select sum( decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) ) )
                 into vn_valor
                 from per_demon_bp         p
                    , det_demon_dre        dre
                    , plano_conta_ref_ecd  pcr
                where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and dre.perdemonbp_id    = p.id
                  and pcr.id               = dre.planocontarefecd_id
                  and pcr.cod_cta_ref      in ('3.02.01.01.01.01', '3.12.01.01.01.01');
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         else
            --
            -- DEBITO(L300("3.02.01.01.01.01")+L300("3.12.01.01.01.01")+L300("3.02.01.01.01.11")+L300("3.12.01.01.01.11"))
            begin
               --
               select sum( decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) ) )
                 into vn_valor
                 from per_demon_bp         p
                    , det_demon_dre        dre
                    , plano_conta_ref_ecd  pcr
                where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and dre.perdemonbp_id    = p.id
                  and pcr.id               = dre.planocontarefecd_id
                  and pcr.cod_cta_ref      in ('3.02.01.01.01.01', '3.12.01.01.01.01', '3.02.01.01.01.11', '3.12.01.01.01.11');
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         end if;
         --
      elsif rec.tabdinecf_cd = '26' then -- Prejuízos na Alienação de Participações Integrantes do Ativo Circulante ou do Ativo Realizável a Longo Prazo
         --
         vn_fase := 12;
         --
         if pk_csf_api_secf.gv_versao_layout_ecf_cd < '300' then
            --
            -- CREDITO(L300("3.01.01.11.01.01")+L300("3.11.01.11.01.01"))-DEBITO(L300("3.01.01.11.01.04")+L300("3.11.01.11.01.04"))
            begin
               --
               select nvl( sum( case when pcr.cod_cta_ref in ('3.01.01.11.01.01', '3.11.01.11.01.01') then
                                        decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) )
                                     else 0
                                end ) ,0) -
                      nvl( sum( case when pcr.cod_cta_ref in ('3.01.01.11.01.04', '3.11.01.11.01.04') then
                                        decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) )
                                     else 0
                                end ) ,0)
                 into vn_valor
                 from per_demon_bp         p
                    , det_demon_dre        dre
                    , plano_conta_ref_ecd  pcr
                where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and dre.perdemonbp_id    = p.id
                  and pcr.id               = dre.planocontarefecd_id
                  and pcr.cod_cta_ref      in ('3.01.01.11.01.01', '3.11.01.11.01.01', '3.01.01.11.01.04', '3.11.01.11.01.04');
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         else
            -- DEBITO(L300("3.01.01.11.01.01")+L300("3.11.01.11.01.01")+L300("3.01.01.11.01.04")+L300("3.11.01.11.01.04"))
            begin
               --
               select nvl( sum( decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) ) ) ,0)
                 into vn_valor
                 from per_demon_bp         p
                    , det_demon_dre        dre
                    , plano_conta_ref_ecd  pcr
                where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and dre.perdemonbp_id    = p.id
                  and pcr.id               = dre.planocontarefecd_id
                  and pcr.cod_cta_ref      in ('3.01.01.11.01.01', '3.11.01.11.01.01', '3.01.01.11.01.04', '3.11.01.11.01.04');
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         end if;
         --
      elsif rec.tabdinecf_cd = '27' then -- Resultados Negativos em Participações Societárias e em SCP
         --
         vn_fase := 13;
         -- DEBITO(L300("3.01.01.09.01.09")+L300("3.01.01.09.01.10")+L300("3.11.01.09.01.09")+L300("3.11.01.09.01.10"))
         begin
            --
            select sum( decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) ) )
              into vn_valor
              from per_demon_bp         p
                 , det_demon_dre        dre
                 , plano_conta_ref_ecd  pcr
             where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
               and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
               and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
               and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
               and dre.perdemonbp_id    = p.id
               and pcr.id               = dre.planocontarefecd_id
               and pcr.cod_cta_ref      in ('3.01.01.09.01.09', '3.01.01.09.01.10', '3.11.01.09.01.09', '3.11.01.09.01.10');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '28' then -- Variações Cambiais Passivas (MP nº 1.858-10/1999, art. 30)
         --
         vn_fase := 14;
         -- DEBITO(L300("3.01.01.09.01.01")+L300("3.11.01.09.01.01"))
         begin
            --
            select sum( decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) ) )
              into vn_valor
              from per_demon_bp         p
                 , det_demon_dre        dre
                 , plano_conta_ref_ecd  pcr
             where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
               and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
               and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
               and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
               and dre.perdemonbp_id    = p.id
               and pcr.id               = dre.planocontarefecd_id
               and pcr.cod_cta_ref      in ('3.01.01.09.01.01', '3.11.01.09.01.01');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '30' then -- Perdas em Operações Realizadas no Exterior
         --
         vn_fase := 14;
         -- DEBITO(L300("3.01.01.09.01.11")+L300("3.11.01.09.01.11"))
         begin
            --
            select sum( decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) ) )
              into vn_valor
              from per_demon_bp         p
                 , det_demon_dre        dre
                 , plano_conta_ref_ecd  pcr
             where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
               and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
               and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
               and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
               and dre.perdemonbp_id    = p.id
               and pcr.id               = dre.planocontarefecd_id
               and pcr.cod_cta_ref      in ('3.01.01.09.01.11', '3.11.01.09.01.11');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '36' then -- (-) Outras Receitas (Lei nº 6.404/1976, art. 187, IV)
         --
         vn_fase := 15;
         -- CREDITO((L300("3.01.01.11.01.02") + L300("3.01.01.11.01.03") + L300("3.01.01.11.01.07") + L300("3.11.01.11.01.02") + L300("3.11.01.11.01.03") + L300("3.11.01.11.01.07")))
         begin
            --
            select sum( decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) ) )
              into vn_valor
              from per_demon_bp         p
                 , det_demon_dre        dre
                 , plano_conta_ref_ecd  pcr
             where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
               and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
               and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
               and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
               and dre.perdemonbp_id    = p.id
               and pcr.id               = dre.planocontarefecd_id
               and pcr.cod_cta_ref      in ('3.01.01.11.01.02', '3.01.01.11.01.03', '3.01.01.11.01.07', '3.11.01.11.01.02', '3.11.01.11.01.03', '3.11.01.11.01.07');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '37' then -- (-) Ganhos na Alienação de Participações Integrantes do Ativo Circulante ou do Ativo Realizável a Longo Prazo
         --
         vn_fase := 16;
         --
         if pk_csf_api_secf.gv_versao_layout_ecf_cd < '300' then
            -- CREDITO(L300("3.01.01.11.01.01”) +L300("3.11.01.11.01.01")) - DEBITO(L300("3.01.01.11.01.04")+L300("3.11.01.11.01.04"))
            begin
               --
               select nvl( sum( case when pcr.cod_cta_ref in ('3.01.01.11.01.01', '3.11.01.11.01.01') then
                                        decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) )
                                     else 0
                                end ) ,0) -
                      nvl( sum( case when pcr.cod_cta_ref in ('3.01.01.11.01.04', '3.11.01.11.01.04') then
                                        decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) )
                                     else 0
                                end ) ,0)
                 into vn_valor
                 from per_demon_bp         p
                    , det_demon_dre        dre
                    , plano_conta_ref_ecd  pcr
                where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and dre.perdemonbp_id    = p.id
                  and pcr.id               = dre.planocontarefecd_id
                  and pcr.cod_cta_ref      in ('3.01.01.11.01.01', '3.11.01.11.01.01', '3.01.01.11.01.04', '3.11.01.11.01.04');
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         else
            -- CREDITO(L300("3.01.01.11.01.01")+L300("3.11.01.11.01.01")+L300("3.01.01.11.01.04")+L300("3.11.01.11.01.04"))
            begin
               --
               select nvl( sum( decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) ) ) ,0)
                 into vn_valor
                 from per_demon_bp         p
                    , det_demon_dre        dre
                    , plano_conta_ref_ecd  pcr
                where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and dre.perdemonbp_id    = p.id
                  and pcr.id               = dre.planocontarefecd_id
                  and pcr.cod_cta_ref      in ('3.01.01.11.01.01', '3.11.01.11.01.01', '3.01.01.11.01.04', '3.11.01.11.01.04');
               --
            exception
               when others then
                  vn_valor := 0;
            end;
            --
         end if;
         --
      elsif rec.tabdinecf_cd = '38' then -- (-) Resultados Positivos em Participações Societárias e em SCP
         --
         vn_fase := 17;
         -- CREDITO(L300("3.01.01.05.01.06")+ L300("3.01.01.05.01.07")+L300("3.11.01.05.01.06")+ L300("3.11.01.05.01.07"))
         begin
            --
            select sum( decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) ) )
              into vn_valor
              from per_demon_bp         p
                 , det_demon_dre        dre
                 , plano_conta_ref_ecd  pcr
             where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
               and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
               and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
               and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
               and dre.perdemonbp_id    = p.id
               and pcr.id               = dre.planocontarefecd_id
               and pcr.cod_cta_ref      in ('3.01.01.05.01.06', '3.01.01.05.01.07', '3.11.01.05.01.06', '3.11.01.05.01.07');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '39' then -- (-) Rendimentos e Ganhos de Capital Auferidos no Exterior
         --
         vn_fase := 18;
         -- CREDITO(L300("3.01.01.05.01.08")+L300("3.11.01.05.01.08"))
         begin
            --
            select sum( decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) ) )
              into vn_valor
              from per_demon_bp         p
                 , det_demon_dre        dre
                 , plano_conta_ref_ecd  pcr
             where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
               and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
               and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
               and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
               and dre.perdemonbp_id    = p.id
               and pcr.id               = dre.planocontarefecd_id
               and pcr.cod_cta_ref      in ('3.01.01.05.01.08', '3.11.01.05.01.08');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '40' then -- (-) Variações Cambiais Ativas (MP nº 1.858-10/1999, art. 30)
         --
         vn_fase := 19;
         -- CREDITO(L300("3.01.01.05.01.01")+L300("3.11.01.05.01.01"))
         begin
            --
            select sum( decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) ) )
              into vn_valor
              from per_demon_bp         p
                 , det_demon_dre        dre
                 , plano_conta_ref_ecd  pcr
             where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
               and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
               and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
               and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
               and dre.perdemonbp_id    = p.id
               and pcr.id               = dre.planocontarefecd_id
               and pcr.cod_cta_ref      in ('3.01.01.05.01.01', '3.11.01.05.01.01');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '42' then -- (-)Prêmios na Emissão de Debêntures
         --
         vn_fase := 20;
         -- CREDITO(L300("3.01.01.05.01.11”) +L300("3.11.01.05.01.11"))
         begin
            --
            select sum( decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) ) )
              into vn_valor
              from per_demon_bp         p
                 , det_demon_dre        dre
                 , plano_conta_ref_ecd  pcr
             where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
               and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
               and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
               and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
               and dre.perdemonbp_id    = p.id
               and pcr.id               = dre.planocontarefecd_id
               and pcr.cod_cta_ref      in ('3.01.01.05.01.11', '3.11.01.05.01.11');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '43' then -- (-) Doações e Subvenções para Investimento
         --
         vn_fase := 21;
         -- CREDITO(L300("3.01.01.05.01.13")+L300("3.11.01.05.01.13"))
         begin
            --
            select sum( decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) ) )
              into vn_valor
              from per_demon_bp         p
                 , det_demon_dre        dre
                 , plano_conta_ref_ecd  pcr
             where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
               and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
               and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
               and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
               and dre.perdemonbp_id    = p.id
               and pcr.id               = dre.planocontarefecd_id
               and pcr.cod_cta_ref      in ('3.01.01.05.01.13', '3.11.01.05.01.13');
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '46' then -- (-) Receitas Financeiras Excedentes das Despesas Financeiras
         --
         vn_fase := 22;
         -- 
         -- CREDITO( SOMA(L300("3.01.01.05.01.02":"3.01.01.05.01.05")) + SOMA(L300("3.11.01.05.01.02":"3.11.01.05.01.05")) )
         -- - DEBITO(SOMA(L300("3.01.01.09.01.02":"3.01.01.09.01.08"))-L300("3.01.01.09.01.05"))
         -- + SOMA(L300("3.11.01.09.01.02":"3.11.01.09.01.08")) - L300("3.11.01.09.01.05"))
         --
         declare
            --
            vn_valor1  number := 0;
            vn_valor1a number := 0;
            vn_valor1b number := 0;
            vn_valor2  number := 0;
            vn_valor2a number := 0;
            vn_valor2b number := 0;
            vn_valor3  number := 0;
            vn_valor3a number := 0;
            vn_valor3b number := 0;
            --
         begin
            --
            vn_fase := 22.1;
            -- CREDITO( SOMA(L300("3.01.01.05.01.02":"3.01.01.05.01.05"))
            begin
               --
               select sum( decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) ) )
                 into vn_valor1a
                 from per_demon_bp         p
                    , det_demon_dre        dre
                    , plano_conta_ref_ecd  pcr
                where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and dre.perdemonbp_id    = p.id
                  and pcr.id               = dre.planocontarefecd_id
                  and pcr.cod_cta_ref      between '3.01.01.05.01.02' and '3.01.01.05.01.05';
               --
            exception
               when others then
                  vn_valor1a := 0;
            end;
            --
            vn_fase := 22.2;
            -- SOMA(L300("3.11.01.05.01.02":"3.11.01.05.01.05")) )
            begin
               --
               select sum( decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) ) )
                 into vn_valor1b
                 from per_demon_bp         p
                    , det_demon_dre        dre
                    , plano_conta_ref_ecd  pcr
                where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and dre.perdemonbp_id    = p.id
                  and pcr.id               = dre.planocontarefecd_id
                  and pcr.cod_cta_ref      between '3.11.01.05.01.02' and '3.11.01.05.01.05';
               --
            exception
               when others then
                  vn_valor1b := 0;
            end;
            --
            vn_valor1 := nvl(vn_valor1a,0) + nvl(vn_valor1b,0);
            --
            vn_fase := 22.3;
            -- DEBITO(SOMA(L300("3.01.01.09.01.02":"3.01.01.09.01.08"))
            begin
               --
               select sum( decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) ) )
                 into vn_valor2a
                 from per_demon_bp         p
                    , det_demon_dre        dre
                    , plano_conta_ref_ecd  pcr
                where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and dre.perdemonbp_id    = p.id
                  and pcr.id               = dre.planocontarefecd_id
                  and pcr.cod_cta_ref      between '3.01.01.09.01.02' and '3.01.01.09.01.08';
               --
            exception
               when others then
                  vn_valor2a := 0;
            end;
            --
            vn_fase := 22.4;
            -- L300("3.01.01.09.01.05"))
            begin
               --
               select sum( decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) ) )
                 into vn_valor2b
                 from per_demon_bp         p
                    , det_demon_dre        dre
                    , plano_conta_ref_ecd  pcr
                where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and dre.perdemonbp_id    = p.id
                  and pcr.id               = dre.planocontarefecd_id
                  and pcr.cod_cta_ref      = '3.01.01.09.01.05';
               --
            exception
               when others then
                  vn_valor2b := 0;
            end;
            --
            vn_valor2 := nvl(vn_valor2a,0) - nvl(vn_valor2b,0);
            --
            vn_fase := 22.5;
            -- SOMA(L300("3.11.01.09.01.02":"3.11.01.09.01.08"))
            begin
               --
               select sum( decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) ) )
                 into vn_valor3a
                 from per_demon_bp         p
                    , det_demon_dre        dre
                    , plano_conta_ref_ecd  pcr
                where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and dre.perdemonbp_id    = p.id
                  and pcr.id               = dre.planocontarefecd_id
                  and pcr.cod_cta_ref      between '3.11.01.09.01.02' and '3.11.01.09.01.08';
               --
            exception
               when others then
                  vn_valor3a := 0;
            end;
            --
            vn_fase := 22.6;
            -- L300("3.11.01.09.01.05")
            begin
               --
               select sum( decode( dre.dm_ind_valor, 'D', nvl(dre.val_cta_ref,0) * -1, nvl(dre.val_cta_ref,0) ) )
                 into vn_valor3b
                 from per_demon_bp         p
                    , det_demon_dre        dre
                    , plano_conta_ref_ecd  pcr
                where p.aberturaecf_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                  and p.dt_ini             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                  and p.dt_fin             = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                  and p.dm_per_apur        = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                  and dre.perdemonbp_id    = p.id
                  and pcr.id               = dre.planocontarefecd_id
                  and pcr.cod_cta_ref      = '3.11.01.09.01.05';
               --
            exception
               when others then
                  vn_valor3b := 0;
            end;
            --
            vn_valor3 := nvl(vn_valor3a,0) - nvl(vn_valor3b,0);
            --
            vn_fase := 22.7;
            --
            vn_valor := nvl(vn_valor1,0) - nvl(vn_valor2,0) + nvl(vn_valor3,0);
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
         if pk_csf_api_secf.gv_versao_layout_ecf_cd >= '300' then
            --
            -- SE (CREDITO(SOMA(L300("3.01.01.05.01.02":"3.01.01.05.01.05"))
            --            +SOMA(L300("3.11.01.05.01.02":"3.11.01.05.01.05")))
            --            -DEBITO(SOMA(L300("3.01.01.09.01.02":"3.01.01.09.01.08"))
            --                   -L300("3.01.01.09.01.05")
            --                   +SOMA(L300("3.11.01.09.01.02":"3.11.01.09.01.08"))-L300("3.11.01.09.01.05")) > 0) ENTAO
            --     CREDITO(SOMA(L300("3.01.01.05.01.02":"3.01.01.05.01.05"))+SOMA(L300("3.11.01.05.01.02":"3.11.01.05.01.05")))-DEBITO(SOMA(L300("3.01.01.09.01.02":"3.01.01.09.01.08"))-L300("3.01.01.09.01.05")+SOMA(L300("3.11.01.09.01.02":"3.11.01.09.01.08"))-L300("3.11.01.09.01.05"))
            -- SENAO 0
            -- FIM_SE
            --
            if nvl(vn_valor,0) <= 0 then
               vn_valor := 0;
            end if;
            --
         end if;
         --
      elsif rec.tabdinecf_cd = '48' then -- LUCRO DA EXPLORAÇÃO
         --
         vn_fase := 23;
         -- SOMA(N600(23:35))-SOMA(N600(36:47))
         declare
            --
            vn_valor1 number := 0;
            vn_valor2 number := 0;
            --
         begin
            --
            vn_fase := 23.1;
            --
            begin
               --
               select nvl( sum( d.valor ) ,0)
                 into vn_valor1
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) between 23 and 35.99;
               --
            exception
               when others then
                  vn_valor1 := 0;
            end;
            --
            vn_fase := 23.2;
            --
            begin
               --
               select nvl( sum( d.valor ) ,0)
                 into vn_valor2
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and to_number( nvl(substr(td.cd, 1, trim(instr(td.cd, '.') - 1)  ), td.cd) ) between 36 and 47;
               --
            exception
               when others then
                  vn_valor2 := 0;
            end;
            --
            vn_fase := 23.3;
            --
            vn_valor := nvl(vn_valor1,0) - nvl(vn_valor2,0);
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '50' then -- Parcela Isenta Correspondente à Atividade de Ensino Superior – Prouni
         --
         vn_fase := 24;
         -- SE (N600(48)<0 OU N600(19)=0) ENTAO 0 SENAO N600(48)*N600(2)/N600(19) FIM_SE
         declare
            --
            vn_vl_48 number := 0;
            vn_vl_19 number := 0;
            vn_vl_2  number := 0;
            --
         begin
            --
            vn_fase := 24.1;
            --
            begin
               --
               select nvl( sum( case
                                   when td.cd = '2' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '19' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '48' then
                                      d.valor
                                   else 0
                                end),0)
                 into vn_vl_2
                    , vn_vl_19
                    , vn_vl_48
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('2', '19', '48');
               --
            exception
               when others then
                  vn_vl_2 := 0;
                  vn_vl_19 := 0;
                  vn_vl_48 := 0;
            end;
            --
            vn_fase := 24.2;
            --
            if nvl(vn_vl_48,0) < 0 or nvl(vn_vl_19,0) = 0 then
               vn_valor := 0;
            else
               vn_valor := round( (nvl(vn_vl_48,0) * nvl(vn_vl_2,0)) / nvl(vn_vl_19,0), 2);
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '51' then -- Parcela Isenta Correspondente a Projeto Industrial ou Agrícola - Sudam/Sudene
         --
         vn_fase := 25;
         -- SE (N600(48)<0 OU N600(19)=0) ENTAO 0 SENAO N600(48)*N600(3)/N600(19) FIM_SE
         declare
            --
            vn_vl_48 number := 0;
            vn_vl_19 number := 0;
            vn_vl_3  number := 0;
            --
         begin
            --
            vn_fase := 25.1;
            --
            begin
               --
               select nvl( sum( case
                                   when td.cd = '3' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '19' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '48' then
                                      d.valor
                                   else 0
                                end),0)
                 into vn_vl_3
                    , vn_vl_19
                    , vn_vl_48
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('3', '19', '48');
               --
            exception
               when others then
                  vn_vl_3 := 0;
                  vn_vl_19 := 0;
                  vn_vl_48 := 0;
            end;
            --
            vn_fase := 25.2;
            --
            if nvl(vn_vl_48,0) < 0 or nvl(vn_vl_19,0) = 0 then
               vn_valor := 0;
            else
               vn_valor := round((nvl(vn_vl_48,0) * nvl(vn_vl_3,0)) / nvl(vn_vl_19,0), 2);
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '52' then -- Parcela Isenta Correspondente à Atividade Integrante de Programa de Inclusão Digital - Sudam/Sudene
         --
         vn_fase := 26;
         -- SE (N600(48)<0 OU N600(19)=0) ENTAO 0 SENAO N600(48)*N600(4)/N600(19) FIM_SE
         declare
            --
            vn_vl_48 number := 0;
            vn_vl_19 number := 0;
            vn_vl_4  number := 0;
            --
         begin
            --
            vn_fase := 26.1;
            --
            begin
               --
               select nvl( sum( case
                                   when td.cd = '4' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '19' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '48' then
                                      d.valor
                                   else 0
                                end),0)
                 into vn_vl_4
                    , vn_vl_19
                    , vn_vl_48
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('4', '19', '48');
               --
            exception
               when others then
                  vn_vl_4 := 0;
                  vn_vl_19 := 0;
                  vn_vl_48 := 0;
            end;
            --
            vn_fase := 26.2;
            --
            if nvl(vn_vl_48,0) < 0 or nvl(vn_vl_19,0) = 0 then
               vn_valor := 0;
            else
               vn_valor := round((nvl(vn_vl_48,0) * nvl(vn_vl_4,0)) / nvl(vn_vl_19,0), 2);
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '53' then -- Parcela Isenta Correspondente à Atividade de Transporte Internacional
         --
         vn_fase := 27;
         -- SE (N600(48)<0 OU N600(19)=0) ENTAO 0 SENAO N600(48)*N600(5)/N600(19) FIM_SE
         declare
            --
            vn_vl_48 number := 0;
            vn_vl_19 number := 0;
            vn_vl_5  number := 0;
            --
         begin
            --
            vn_fase := 27.1;
            --
            begin
               --
               select nvl( sum( case
                                   when td.cd = '5' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '19' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '48' then
                                      d.valor
                                   else 0
                                end),0)
                 into vn_vl_5
                    , vn_vl_19
                    , vn_vl_48
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('5', '19', '48');
               --
            exception
               when others then
                  vn_vl_5 := 0;
                  vn_vl_19 := 0;
                  vn_vl_48 := 0;
            end;
            --
            vn_fase := 27.2;
            --
            if nvl(vn_vl_48,0) < 0 or nvl(vn_vl_19,0) = 0 then
               vn_valor := 0;
            else
               vn_valor := round((nvl(vn_vl_48,0) * nvl(vn_vl_5,0)) / nvl(vn_vl_19,0), 2);
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '54' then -- Parcela Isenta Correspondente à Eventos da Fifa
         --
         vn_fase := 28;
         -- SE (N600(48)<0 OU N600(19)=0) ENTAO 0 SENAO N600(48)*N600(6)/N600(19) FIM_SE
         declare
            --
            vn_vl_48 number := 0;
            vn_vl_19 number := 0;
            vn_vl_6  number := 0;
            --
         begin
            --
            vn_fase := 28.1;
            --
            begin
               --
               select nvl( sum( case
                                   when td.cd = '6' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '19' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '48' then
                                      d.valor
                                   else 0
                                end),0)
                 into vn_vl_6
                    , vn_vl_19
                    , vn_vl_48
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('6', '19', '48');
               --
            exception
               when others then
                  vn_vl_6 := 0;
                  vn_vl_19 := 0;
                  vn_vl_48 := 0;
            end;
            --
            vn_fase := 28.2;
            --
            if nvl(vn_vl_48,0) < 0 or nvl(vn_vl_19,0) = 0 then
               vn_valor := 0;
            else
               vn_valor := round((nvl(vn_vl_48,0) * nvl(vn_vl_6,0)) / nvl(vn_vl_19,0), 2);
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '55' then -- Parcela Isenta Correspondente à Atividade de Serviços - SPE - Eventos da Fifa
         --
         vn_fase := 29;
         -- SE (N600(48)<0 OU N600(19)=0) ENTAO 0 SENAO N600(48)*N600(7)/N600(19) FIM_SE
         declare
            --
            vn_vl_48 number := 0;
            vn_vl_19 number := 0;
            vn_vl_7  number := 0;
            --
         begin
            --
            vn_fase := 29.1;
            --
            begin
               --
               select nvl( sum( case
                                   when td.cd = '7' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '19' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '48' then
                                      d.valor
                                   else 0
                                end),0)
                 into vn_vl_7
                    , vn_vl_19
                    , vn_vl_48
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('7', '19', '48');
               --
            exception
               when others then
                  vn_vl_7 := 0;
                  vn_vl_19 := 0;
                  vn_vl_48 := 0;
            end;
            --
            vn_fase := 29.2;
            --
            if nvl(vn_vl_48,0) < 0 or nvl(vn_vl_19,0) = 0 then
               vn_valor := 0;
            else
               vn_valor := round((nvl(vn_vl_48,0) * nvl(vn_vl_7,0)) / nvl(vn_vl_19,0), 2);
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '56' then -- Parcela Isenta Correspondente à Eventos do CIO
         --
         vn_fase := 30;
         -- SE (N600(48)<0 OU N600(19)=0) ENTAO 0 SENAO N600(48)*N600(8)/N600(19) FIM_SE
         declare
            --
            vn_vl_48 number := 0;
            vn_vl_19 number := 0;
            vn_vl_8  number := 0;
            --
         begin
            --
            vn_fase := 30.1;
            --
            begin
               --
               select nvl( sum( case
                                   when td.cd = '8' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '19' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '48' then
                                      d.valor
                                   else 0
                                end),0)
                 into vn_vl_8
                    , vn_vl_19
                    , vn_vl_48
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('8', '19', '48');
               --
            exception
               when others then
                  vn_vl_8 := 0;
                  vn_vl_19 := 0;
                  vn_vl_48 := 0;
            end;
            --
            vn_fase := 30.2;
            --
            if nvl(vn_vl_48,0) < 0 or nvl(vn_vl_19,0) = 0 then
               vn_valor := 0;
            else
               vn_valor := round((nvl(vn_vl_48,0) * nvl(vn_vl_8,0)) / nvl(vn_vl_19,0), 2);
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '57' then -- Parcela Isenta Correspondente à Atividade de Serviços - SPE - Eventos do CIO
         --
         vn_fase := 31;
         -- SE (N600(48)<0 OU N600(19)=0) ENTAO 0 SENAO N600(48)*N600(9)/N600(19) FIM_SE
         declare
            --
            vn_vl_48 number := 0;
            vn_vl_19 number := 0;
            vn_vl_9  number := 0;
            --
         begin
            --
            vn_fase := 31.1;
            --
            begin
               --
               select nvl( sum( case
                                   when td.cd = '9' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '19' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '48' then
                                      d.valor
                                   else 0
                                end),0)
                 into vn_vl_9
                    , vn_vl_19
                    , vn_vl_48
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('9', '19', '48');
               --
            exception
               when others then
                  vn_vl_9 := 0;
                  vn_vl_19 := 0;
                  vn_vl_48 := 0;
            end;
            --
            vn_fase := 30.2;
            --
            if nvl(vn_vl_48,0) < 0 or nvl(vn_vl_19,0) = 0 then
               vn_valor := 0;
            else
               vn_valor := round((nvl(vn_vl_48,0) * nvl(vn_vl_9,0)) / nvl(vn_vl_19,0), 2);
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '58' then -- Parcela Correspondente à Atividade com Redução de 100% - Padis
         --
         vn_fase := 31;
         -- SE (N600(48)<0 OU N600(19)=0) ENTAO 0 SENAO N600(48)*N600(10)/N600(19) FIM_SE
         declare
            --
            vn_vl_48 number := 0;
            vn_vl_19 number := 0;
            vn_vl_10  number := 0;
            --
         begin
            --
            vn_fase := 31.1;
            --
            begin
               --
               select nvl( sum( case
                                   when td.cd = '10' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '19' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '48' then
                                      d.valor
                                   else 0
                                end),0)
                 into vn_vl_10
                    , vn_vl_19
                    , vn_vl_48
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('10', '19', '48');
               --
            exception
               when others then
                  vn_vl_10 := 0;
                  vn_vl_19 := 0;
                  vn_vl_48 := 0;
            end;
            --
            vn_fase := 31.2;
            --
            if nvl(vn_vl_48,0) < 0 or nvl(vn_vl_19,0) = 0 then
               vn_valor := 0;
            else
               vn_valor := round((nvl(vn_vl_48,0) * nvl(vn_vl_10,0)) / nvl(vn_vl_19,0), 2);
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '59' then -- Parcela Correspondente à Atividade com Redução de 75%
         --
         vn_fase := 32;
         -- SE (N600(48)<0 OU N600(19)=0) ENTAO 0 SENAO N600(48)*N600(11)/N600(19) FIM_SE
         declare
            --
            vn_vl_48 number := 0;
            vn_vl_19 number := 0;
            vn_vl_11  number := 0;
            --
         begin
            --
            vn_fase := 32.1;
            --
            begin
               --
               select nvl( sum( case
                                   when td.cd = '11' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '19' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '48' then
                                      d.valor
                                   else 0
                                end),0)
                 into vn_vl_11
                    , vn_vl_19
                    , vn_vl_48
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('11', '19', '48');
               --
            exception
               when others then
                  vn_vl_11 := 0;
                  vn_vl_19 := 0;
                  vn_vl_48 := 0;
            end;
            --
            vn_fase := 32.2;
            --
            if nvl(vn_vl_48,0) < 0 or nvl(vn_vl_19,0) = 0 then
               vn_valor := 0;
            else
               vn_valor := round((nvl(vn_vl_48,0) * nvl(vn_vl_11,0)) / nvl(vn_vl_19,0), 2);
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '60' then -- Parcela Correspondente à Atividade com Redução de 70%
         --
         vn_fase := 33;
         -- SE (N600(48)<0 OU N600(19)=0) ENTAO 0 SENAO N600(48)*N600(12)/N600(19) FIM_SE
         declare
            --
            vn_vl_48 number := 0;
            vn_vl_19 number := 0;
            vn_vl_12 number := 0;
            --
         begin
            --
            vn_fase := 32.1;
            --
            begin
               --
               select nvl( sum( case
                                   when td.cd = '12' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '19' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '48' then
                                      d.valor
                                   else 0
                                end),0)
                 into vn_vl_12
                    , vn_vl_19
                    , vn_vl_48
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('12', '19', '48');
               --
            exception
               when others then
                  vn_vl_12 := 0;
                  vn_vl_19 := 0;
                  vn_vl_48 := 0;
            end;
            --
            vn_fase := 32.2;
            --
            if nvl(vn_vl_48,0) < 0 or nvl(vn_vl_19,0) = 0 then
               vn_valor := 0;
            else
               vn_valor := round((nvl(vn_vl_48,0) * nvl(vn_vl_12,0)) / nvl(vn_vl_19,0), 2);
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '61' then -- Parcela Correspondente à Atividade com Redução de 50%
         --
         vn_fase := 33;
         -- SE (N600(48)<0 OU N600(19)=0) ENTAO 0 SENAO N600(48)*N600(13)/N600(19) FIM_SE
         declare
            --
            vn_vl_48 number := 0;
            vn_vl_19 number := 0;
            vn_vl_13 number := 0;
            --
         begin
            --
            vn_fase := 33.1;
            --
            begin
               --
               select nvl( sum( case
                                   when td.cd = '13' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '19' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '48' then
                                      d.valor
                                   else 0
                                end),0)
                 into vn_vl_13
                    , vn_vl_19
                    , vn_vl_48
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('13', '19', '48');
               --
            exception
               when others then
                  vn_vl_13 := 0;
                  vn_vl_19 := 0;
                  vn_vl_48 := 0;
            end;
            --
            vn_fase := 33.2;
            --
            if nvl(vn_vl_48,0) < 0 or nvl(vn_vl_19,0) = 0 then
               vn_valor := 0;
            else
               vn_valor := round((nvl(vn_vl_48,0) * nvl(vn_vl_13,0)) / nvl(vn_vl_19,0), 2);
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '62' then -- Parcela Correspondente à Atividade com Redução de 33,33%
         --
         vn_fase := 34;
         -- SE (N600(48)<0 OU N600(19)=0) ENTAO 0 SENAO N600(48)*N600(14)/N600(19) FIM_SE
         declare
            --
            vn_vl_48 number := 0;
            vn_vl_19 number := 0;
            vn_vl_14 number := 0;
            --
         begin
            --
            vn_fase := 34.1;
            --
            begin
               --
               select nvl( sum( case
                                   when td.cd = '14' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '19' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '48' then
                                      d.valor
                                   else 0
                                end),0)
                 into vn_vl_14
                    , vn_vl_19
                    , vn_vl_48
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('14', '19', '48');
               --
            exception
               when others then
                  vn_vl_14 := 0;
                  vn_vl_19 := 0;
                  vn_vl_48 := 0;
            end;
            --
            vn_fase := 34.2;
            --
            if nvl(vn_vl_48,0) < 0 or nvl(vn_vl_19,0) = 0 then
               vn_valor := 0;
            else
               vn_valor := round((nvl(vn_vl_48,0) * nvl(vn_vl_14,0)) / nvl(vn_vl_19,0), 2);
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '63' then -- Parcela Correspondente à Atividade com Redução de 25%
         --
         vn_fase := 35;
         -- SE (N600(48)<0 OU N600(19)=0) ENTAO 0 SENAO N600(48)*N600(15)/N600(19) FIM_SE
         declare
            --
            vn_vl_48 number := 0;
            vn_vl_19 number := 0;
            vn_vl_15 number := 0;
            --
         begin
            --
            vn_fase := 35.1;
            --
            begin
               --
               select nvl( sum( case
                                   when td.cd = '15' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '19' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '48' then
                                      d.valor
                                   else 0
                                end),0)
                 into vn_vl_15
                    , vn_vl_19
                    , vn_vl_48
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('15', '19', '48');
               --
            exception
               when others then
                  vn_vl_15 := 0;
                  vn_vl_19 := 0;
                  vn_vl_48 := 0;
            end;
            --
            vn_fase := 34.2;
            --
            if nvl(vn_vl_48,0) < 0 or nvl(vn_vl_19,0) = 0 then
               vn_valor := 0;
            else
               vn_valor := round((nvl(vn_vl_48,0) * nvl(vn_vl_15,0)) / nvl(vn_vl_19,0), 2);
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '64' then -- Parcela Correspondente à Atividade com Redução de 12,5%
         --
         vn_fase := 36;
         -- SE (N600(48)<0 OU N600(19)=0) ENTAO 0 SENAO N600(48)*N600(16)/N600(19) FIM_SE
         declare
            --
            vn_vl_48 number := 0;
            vn_vl_19 number := 0;
            vn_vl_16 number := 0;
            --
         begin
            --
            vn_fase := 36.1;
            --
            begin
               --
               select nvl( sum( case
                                   when td.cd = '16' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '19' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '48' then
                                      d.valor
                                   else 0
                                end),0)
                 into vn_vl_16
                    , vn_vl_19
                    , vn_vl_48
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('16', '19', '48');
               --
            exception
               when others then
                  vn_vl_16 := 0;
                  vn_vl_19 := 0;
                  vn_vl_48 := 0;
            end;
            --
            vn_fase := 34.2;
            --
            if nvl(vn_vl_48,0) < 0 or nvl(vn_vl_19,0) = 0 then
               vn_valor := 0;
            else
               vn_valor := round((nvl(vn_vl_48,0) * nvl(vn_vl_16,0)) / nvl(vn_vl_19,0), 2);
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '65' then -- Parcela Correspondente à Atividade com Redução por Reinvestimento
         --
         vn_fase := 37;
         -- SE (N600(48)<0 OU N600(19)=0) ENTAO 0 SENAO N600(48)*N600(17)/N600(19) FIM_SE
         declare
            --
            vn_vl_48 number := 0;
            vn_vl_19 number := 0;
            vn_vl_17 number := 0;
            --
         begin
            --
            vn_fase := 37.1;
            --
            begin
               --
               select nvl( sum( case
                                   when td.cd = '17' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '19' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '48' then
                                      d.valor
                                   else 0
                                end),0)
                 into vn_vl_17
                    , vn_vl_19
                    , vn_vl_48
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('17', '19', '48');
               --
            exception
               when others then
                  vn_vl_17 := 0;
                  vn_vl_19 := 0;
                  vn_vl_48 := 0;
            end;
            --
            vn_fase := 37.2;
            --
            if nvl(vn_vl_48,0) < 0 or nvl(vn_vl_19,0) = 0 then
               vn_valor := 0;
            else
               vn_valor := round((nvl(vn_vl_48,0) * nvl(vn_vl_17,0)) / nvl(vn_vl_19,0), 2);
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      elsif rec.tabdinecf_cd = '66' then -- Parcela Correspondente às Demais Atividades
         --
         vn_fase := 38;
         -- SE (N600(48)<0 OU N600(19)=0) ENTAO 0 SENAO N600(48)*N600(18)/N600(19) FIM_SE
         declare
            --
            vn_vl_48 number := 0;
            vn_vl_19 number := 0;
            vn_vl_18 number := 0;
            --
         begin
            --
            vn_fase := 38.1;
            --
            begin
               --
               select nvl( sum( case
                                   when td.cd = '18' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '19' then
                                      d.valor
                                   else 0
                                end),0)
                    , nvl( sum( case
                                   when td.cd = '48' then
                                      d.valor
                                   else 0
                                end),0)
                 into vn_vl_18
                    , vn_vl_19
                    , vn_vl_48
                 from dem_lucro_expl         d
                    , tab_din_ecf            td
                where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
                  and td.id                  = d.tabdinecf_id
                  and td.cd in ('18', '19', '48');
               --
            exception
               when others then
                  vn_vl_18 := 0;
                  vn_vl_19 := 0;
                  vn_vl_48 := 0;
            end;
            --
            vn_fase := 38.2;
            --
            if nvl(vn_vl_48,0) < 0 or nvl(vn_vl_19,0) = 0 then
               vn_valor := 0;
            else
               vn_valor := round((nvl(vn_vl_48,0) * nvl(vn_vl_18,0)) / nvl(vn_vl_19,0), 2);
            end if;
            --
         exception
            when others then
               vn_valor := 0;
         end;
         --
      end if;
      --
      vn_fase := 99;
      --
      update dem_lucro_expl set valor    = nvl(vn_valor,0)
                              , dm_tipo  = 1 -- Calculado
       where id = rec.demlucroexpl_id;
      --
      commit;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_soma_vlr_dle fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_soma_vlr_dle;

-------------------------------------------------------------------------------------------------------

-- Procedimento de atualizar os valores de Demonstração do Lucro da Exploração
procedure pkb_atual_vlr_dle ( en_percalcapurlr_id  in per_calc_apur_lr.id%type )
is
   --
   vn_fase number;
   vn_loggenerico_id  log_generico.id%type;
   --
   vv_dominio_descr Dominio.descr%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   gt_log_generico.delete;
   --
   if nvl(en_percalcapurlr_id,0) > 0 then
      --
      vn_fase := 2;
      --
      pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
      --
      begin
         --
         select *
           into pk_csf_api_secf.gt_row_per_calc_apur_lr
           from per_calc_apur_lr
          where id = en_percalcapurlr_id;
         --
      exception
         when others then
            pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
      end;
      --
      vn_fase := 3;
      --
      if nvl(pk_csf_api_secf.gt_row_per_calc_apur_lr.id,0) > 0 then
         --
         pk_csf_api_secf.pkb_inicia_param ( en_aberturaecf_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id );
         --
         vn_fase := 4;
         -- Procedimento seta o objeto de referencia utilizado na Validação da Informação
         pk_csf_api_secf.pkb_seta_obj_ref ( ev_objeto => 'PER_CALC_APUR_LR' );
         --
         vn_fase := 4.1;
         -- Procedimento seta o "ID de Referencia" utilizado na Validação da Informação
         pk_csf_api_secf.pkb_seta_referencia_id ( en_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.id );
         --
         vn_fase := 5;
         --
         -- Procedimento para somar os valores de Demonstração do Lucro da Exploração
         pkb_soma_vlr_dle;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_atual_vlr_dle fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_atual_vlr_dle;

---------------------------------------------------------------------------------------------------------------------
-- Procedimento para somar os valores de Base de Cálculo do IRPJ Sobre o Lucro Real Após as Compensações de Prejuízos
---------------------------------------------------------------------------------------------------------------------
procedure pkb_somar_vlr_birlrcp is
  --
  vn_fase number;
  --
  vn_valor bc_irpj_lr_comp_prej.valor%type;
  vn_tipo  bc_irpj_lr_comp_prej.dm_tipo%type;
  --
  cursor c_dados2 is
    select d.id              bcirpjlrcompprej_id,
           td.id             tabdinecf_id,
           td.registroecf_id,
           td.cd             tabdinecf_cd,
           td.ordem
      from bc_irpj_lr_comp_prej d,  
           tab_din_ecf td
     where d.percalcapurlr_id = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
       and td.id              = d.tabdinecf_id
       and td.dm_tipo         in ('CA', 'CNA')
     order by td.ordem, 
              td.cd;
  --
begin
  --
  vn_fase := 1;
  --
  for rec in c_dados2 loop
    exit when c_dados2%notfound or(c_dados2%notfound) is null;
    --
    vn_fase := 5;
    --
    vn_valor := 0;
    --
    -- Valor da base de cálculo do IRPJ
    if rec.tabdinecf_cd = '1' then
      --
      if pk_csf_api_secf.gv_versao_layout_ecf_cd = '100' then
        --
        vn_fase := 6;
        --
        -- SE (0010.COD_QUALIF_PJ( ) = "01") ENTAO
        -- DEBITO(M300(175))+DEBITO(M300(349))
        -- SENAO SE (0010.COD_QUALIF_PJ( )= "02") ENTAO
        -- (DEBITO(M300(204)))
        -- SENAO SE (0010.COD_QUALIF_PJ( ) = "03") ENTAO
        -- (DEBITO(M300(142)))
        -- SENAO 0
        -- FIM_SE
        -- FIM_SE
        -- FIM_SE
        --
        if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_cod_qualif_pj = '01' then
          --
          vn_fase := 6.1;
          --
          -- DEBITO(M300(175)) + DEBITO(M300(349))
          begin
            select sum(l.valor)
              into vn_valor
              from per_apur_lr p,    
                   lanc_part_a_lalur l, 
                   tab_din_ecf td
             where p.aberturaecf_id = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
               and p.dt_ini         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
               and p.dt_fin         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
               and p.dm_per_apur    = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
               and l.perapurlr_id   = p.id
               and td.id            = l.tabdinecf_id
               and td.cd            in ('175', '349');
          exception
            when others then
              vn_valor := 0;
          end;
          --
        elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_cod_qualif_pj = '02' then
          --
          vn_fase := 6.2;
          --
          -- DEBITO(M300(204))
          begin
            select sum(l.valor)
              into vn_valor
              from per_apur_lr p, 
                   lanc_part_a_lalur l, 
                   tab_din_ecf td
             where p.aberturaecf_id = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
               and p.dt_ini         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
               and p.dt_fin         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
               and p.dm_per_apur    = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
               and l.perapurlr_id   = p.id
               and td.id            = l.tabdinecf_id
               and td.cd            in ('204');
          exception
            when others then
              vn_valor := 0;
          end;
          --
        elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_cod_qualif_pj = '03' then
          --
          vn_fase := 6.3;
          --
          -- DEBITO(M300(142))
          begin
            select sum(l.valor)
              into vn_valor
              from per_apur_lr p, 
                   lanc_part_a_lalur l, 
                   tab_din_ecf td
             where p.aberturaecf_id = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
               and p.dt_ini         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
               and p.dt_fin         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
               and p.dm_per_apur    = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
               and l.perapurlr_id   = p.id
               and td.id            = l.tabdinecf_id
               and td.cd            in ('142');
          exception
            when others then
              vn_valor := 0;
          end;
          --
        else
          --
          vn_valor := 0;
          --
        end if;
        --
      else
        --
        -- SE (0010.COD_QUALIF_PJ( ) = "01") ENTAO
        --    SE (M300(175) < 0 E M300(349) < 0) ENTAO
        --       M300(175) + M300(349)
        --    SENAO
        --       DEBITO(M300(175))+DEBITO(M300(349))
        --    FIM_SE
        -- SENAO
        --    SE (0010.COD_QUALIF_PJ( )= "02") ENTAO
        --       M300(203)
        --    SENAO
        --       SE (0010.COD_QUALIF_PJ( ) = "03") ENTAO
        --          M300(142)
        --       SENAO
        --          0
        --       FIM_SE
        --    FIM_SE
        -- FIM_SE
        --
        if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_cod_qualif_pj = '01' then
          --
          --    SE (M300(175) < 0 E M300(349) < 0) ENTAO
          --       M300(175) + M300(349)
          --    SENAO
          --       DEBITO(M300(175))+DEBITO(M300(349))
          --    FIM_SE
          --
          declare
            --
            vn_m300_175 number;
            vn_m300_349 number;
            --
          begin
            --
            begin
              select sum( case when td.cd = '175' then nvl(l.valor,0) else 0 end ),
                     sum( case when td.cd = '349' then nvl(l.valor,0) else 0 end )
                into vn_m300_175, 
                     vn_m300_349
                from per_apur_lr p, 
                     lanc_part_a_lalur l, 
                     tab_din_ecf td
               where p.aberturaecf_id = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                 and p.dt_ini         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                 and p.dt_fin         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                 and p.dm_per_apur    = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                 and l.perapurlr_id   = p.id
                 and td.id            = l.tabdinecf_id
                 and td.cd            in ('175', '349');
            exception
              when others then
                vn_m300_175 := 0;
                vn_m300_349 := 0;
            end;
            --
            if nvl(vn_m300_175, 0) < 0 and nvl(vn_m300_349, 0) < 0 then
              --
              vn_valor := nvl(vn_m300_175, 0) + nvl(vn_m300_349, 0);
              --
            else
              --
              vn_valor := nvl(vn_m300_175, 0) + nvl(vn_m300_349, 0);
              --
            end if;
            --
          exception
            when others then
              vn_valor := 0;
          end;
          --
        else
          --
          if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_cod_qualif_pj = '02' then
            --
            -- DEBITO(M300(203))
            begin
              select sum(l.valor)
                into vn_valor
                from per_apur_lr p, 
                     lanc_part_a_lalur l, 
                     tab_din_ecf td
               where p.aberturaecf_id = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                 and p.dt_ini         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                 and p.dt_fin         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                 and p.dm_per_apur    = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                 and l.perapurlr_id   = p.id
                 and td.id            = l.tabdinecf_id
                 and td.cd            in ('203');
            exception
              when others then
                vn_valor := 0;
            end;
            --
          else
            --
            if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_cod_qualif_pj = '03' then
              --
              -- DEBITO(M300(142))
              begin
                select sum(l.valor)
                  into vn_valor
                  from per_apur_lr p, 
                       lanc_part_a_lalur l, 
                       tab_din_ecf td
                 where p.aberturaecf_id = pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                   and p.dt_ini         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                   and p.dt_fin         = pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                   and p.dm_per_apur    = pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                   and l.perapurlr_id   = p.id
                   and td.id            = l.tabdinecf_id
                   and td.cd            in ('142');
              exception
                when others then
                  vn_valor := 0;
              end;
              --
            else
              --
              vn_valor := 0;
              --
            end if;
            --
          end if;
          --
        end if;
        --
      end if;
      --
    end if;
    --
    vn_fase := 7;
    --
    -- Caso o valor seja Negativo, atribui ZERO
    /*if nvl(vn_valor, 0) < 0 then
      vn_valor := 0;
    end if;*/
    --
    vn_fase := 99;
    --
    update bc_irpj_lr_comp_prej
       set valor   = nvl(vn_valor, 0), 
           dm_tipo = 1 -- Calculado
     where id      = rec.bcirpjlrcompprej_id;
    --
    commit;
    --
  end loop;
  --
exception
  when others then
    --
    pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_somar_vlr_birlrcp fase(' || vn_fase || '):' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico.id%type;
    begin
      pk_csf_api_secf.pkb_log_generico(sn_loggenerico_id => vn_loggenerico_id,
                                       ev_mensagem       => pk_csf_api_secf.gv_mensagem_log,
                                       ev_resumo         => pk_csf_api_secf.gv_mensagem_log,
                                       en_tipo_log       => pk_csf_api_secf.ERRO_DE_SISTEMA,
                                       en_referencia_id  => pk_csf_api_secf.gn_referencia_id,
                                       ev_obj_referencia => pk_csf_api_secf.gv_obj_referencia);
    exception
      when others then
        null;
    end;
    --
end pkb_somar_vlr_birlrcp;

-------------------------------------------------------------------------------------------------------

-- Procedimento de atualizar os valores de Base de Cálculo do IRPJ Sobre o Lucro Real Após as Compensações de Prejuízos
procedure pkb_atual_vlr_birlrcp ( en_percalcapurlr_id  in per_calc_apur_lr.id%type )
is
   --
   vn_fase number;
   vn_loggenerico_id  log_generico.id%type;
   --
   vv_dominio_descr Dominio.descr%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   gt_log_generico.delete;
   --
   if nvl(en_percalcapurlr_id,0) > 0 then
      --
      vn_fase := 2;
      --
      pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
      --
      begin
         --
         select *
           into pk_csf_api_secf.gt_row_per_calc_apur_lr
           from per_calc_apur_lr
          where id = en_percalcapurlr_id;
         --
      exception
         when others then
            pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
      end;
      --
      vn_fase := 3;
      --
      if nvl(pk_csf_api_secf.gt_row_per_calc_apur_lr.id,0) > 0 then
         --
         pk_csf_api_secf.pkb_inicia_param ( en_aberturaecf_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id );
         --
         vn_fase := 4;
         -- Procedimento seta o objeto de referencia utilizado na Validação da Informação
         pk_csf_api_secf.pkb_seta_obj_ref ( ev_objeto => 'PER_CALC_APUR_LR' );
         --
         vn_fase := 4.1;
         -- Procedimento seta o "ID de Referencia" utilizado na Validação da Informação
         pk_csf_api_secf.pkb_seta_referencia_id ( en_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.id );
         --
         vn_fase := 5;
         --
         -- Procedimento para somar os valores de Base de Cálculo do IRPJ Sobre o Lucro Real Após as Compensações de Prejuízos
         pkb_somar_vlr_birlrcp;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_atual_vlr_birlrcp fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_atual_vlr_birlrcp;

-------------------------------------------------------------------------------------------------------

-- Procedimento de validação de Cálculo da CSLL Com Base no Lucro Real
procedure pkb_vld_calc_csll_base_lr
is
   --
   vn_fase number;
   --
   cursor c_dados is
   select l.*
        , td.codentref_id
        , td.registroecf_id
        , td.cd
        , td.ordem
     from calc_csll_base_lr    l
        , tab_din_ecf          td
    where l.percalcapurlr_id    = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
      and td.id                 = l.tabdinecf_id
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api_secf.gt_row_calc_csll_base_lr := null;
      --
      pk_csf_api_secf.gt_row_calc_csll_base_lr.id                  := rec.id;
      pk_csf_api_secf.gt_row_calc_csll_base_lr.percalcapurlr_id    := rec.percalcapurlr_id;
      pk_csf_api_secf.gt_row_calc_csll_base_lr.tabdinecf_id        := rec.tabdinecf_id;
      pk_csf_api_secf.gt_row_calc_csll_base_lr.valor               := rec.valor;
      pk_csf_api_secf.gt_row_calc_csll_base_lr.dm_tipo             := rec.dm_tipo;
      --
      vn_fase := 3;
      --
      -- Chama API que Integra as informações de Cálculo da CSLL Mensal por Estimativa N660
      pk_csf_api_secf.pkb_integr_calc_csll_base_lr ( est_log_generico            => gt_log_generico
                                                   , est_row_calc_csll_base_lr   => pk_csf_api_secf.gt_row_calc_csll_base_lr
                                                   , en_codentref_id             => rec.codentref_id
                                                   , en_registroecf_id           => rec.registroecf_id
                                                   , ev_tabdinecf_cd             => rec.cd
                                                   );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_vld_calc_csll_base_lr fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_vld_calc_csll_base_lr;

-------------------------------------------------------------------------------------------------------

-- Procedimento de validação de Cálculo da CSLL Mensal por Estimativa
procedure pkb_vld_calc_csll_mes_estim
is
   --
   vn_fase number;
   --
   cursor c_dados is
   select l.*
        , td.codentref_id
        , td.registroecf_id
        , td.cd
        , td.ordem
     from calc_csll_mes_estim  l
        , tab_din_ecf          td
    where l.percalcapurlr_id    = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
      and td.id                 = l.tabdinecf_id
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api_secf.gt_row_calc_csll_mes_estim := null;
      --
      pk_csf_api_secf.gt_row_calc_csll_mes_estim.id                  := rec.id;
      pk_csf_api_secf.gt_row_calc_csll_mes_estim.percalcapurlr_id    := rec.percalcapurlr_id;
      pk_csf_api_secf.gt_row_calc_csll_mes_estim.tabdinecf_id        := rec.tabdinecf_id;
      pk_csf_api_secf.gt_row_calc_csll_mes_estim.valor               := rec.valor;
      pk_csf_api_secf.gt_row_calc_csll_mes_estim.dm_tipo             := rec.dm_tipo;
      --
      vn_fase := 3;
      --
      -- Chama API que Integra as informações de Cálculo da CSLL Mensal por Estimativa N660
      pk_csf_api_secf.pkb_integr_calc_csll_mes_estim ( est_log_generico              => gt_log_generico
                                                     , est_row_calc_csll_mes_estim   => pk_csf_api_secf.gt_row_calc_csll_mes_estim
                                                     , en_codentref_id               => rec.codentref_id
                                                     , en_registroecf_id             => rec.registroecf_id
                                                     , ev_tabdinecf_cd               => rec.cd
                                                     );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_vld_calc_csll_mes_estim fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_vld_calc_csll_mes_estim;

-------------------------------------------------------------------------------------------------------

-- Procedimento de validação de Base de Cálculo da CSLL Após as Compensações da Base de Cálculo Negativa
procedure pkb_vld_bc_csll_comp_neg
is
   --
   vn_fase number;
   --
   cursor c_dados is
   select l.*
        , td.codentref_id
        , td.registroecf_id
        , td.cd
        , td.ordem
     from bc_csll_comp_neg     l
        , tab_din_ecf          td
    where l.percalcapurlr_id    = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
      and td.id                 = l.tabdinecf_id
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api_secf.gt_row_bc_csll_comp_neg := null;
      --
      pk_csf_api_secf.gt_row_bc_csll_comp_neg.id                  := rec.id;
      pk_csf_api_secf.gt_row_bc_csll_comp_neg.percalcapurlr_id    := rec.percalcapurlr_id;
      pk_csf_api_secf.gt_row_bc_csll_comp_neg.tabdinecf_id        := rec.tabdinecf_id;
      pk_csf_api_secf.gt_row_bc_csll_comp_neg.valor               := rec.valor;
      pk_csf_api_secf.gt_row_bc_csll_comp_neg.dm_tipo             := rec.dm_tipo;
      --
      vn_fase := 3;
      --
      -- Chama API que Integra as informações de Base de Cálculo da CSLL Após as Compensações da Base de Cálculo Negativa N650
      pk_csf_api_secf.pkb_integr_bc_csll_comp_neg ( est_log_generico           => gt_log_generico
                                                  , est_row_bc_csll_comp_neg   => pk_csf_api_secf.gt_row_bc_csll_comp_neg
                                                  , en_codentref_id            => rec.codentref_id
                                                  , en_registroecf_id          => rec.registroecf_id
                                                  , ev_tabdinecf_cd            => rec.cd
                                                  );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_vld_bc_csll_comp_neg fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_vld_bc_csll_comp_neg;

-------------------------------------------------------------------------------------------------------

-- Procedimento de validação de Cálculo do IRPJ Com Base no Lucro Real
procedure pkb_vld_calc_irpj_base_lr
is
   --
   vn_fase number;
   --
   cursor c_dados is
   select l.*
        , td.codentref_id
        , td.registroecf_id
        , td.cd
        , td.ordem
     from calc_irpj_base_lr    l
        , tab_din_ecf          td
    where l.percalcapurlr_id    = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
      and td.id                 = l.tabdinecf_id
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api_secf.gt_row_calc_irpj_base_lr := null;
      --
      pk_csf_api_secf.gt_row_calc_irpj_base_lr.id                  := rec.id;
      pk_csf_api_secf.gt_row_calc_irpj_base_lr.percalcapurlr_id    := rec.percalcapurlr_id;
      pk_csf_api_secf.gt_row_calc_irpj_base_lr.tabdinecf_id        := rec.tabdinecf_id;
      pk_csf_api_secf.gt_row_calc_irpj_base_lr.valor               := rec.valor;
      pk_csf_api_secf.gt_row_calc_irpj_base_lr.dm_tipo             := rec.dm_tipo;
      --
      vn_fase := 3;
      --
      -- Chama API que Integra as informações de Cálculo do IRPJ Com Base no Lucro Real N630
      pk_csf_api_secf.pkb_integr_calc_irpj_base_lr ( est_log_generico              => gt_log_generico
                                                   , est_row_calc_irpj_base_lr   => pk_csf_api_secf.gt_row_calc_irpj_base_lr
                                                   , en_codentref_id               => rec.codentref_id
                                                   , en_registroecf_id             => rec.registroecf_id
                                                   , ev_tabdinecf_cd               => rec.cd
                                                   );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_vld_calc_irpj_base_lr fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_vld_calc_irpj_base_lr;

-------------------------------------------------------------------------------------------------------

-- Procedimento de validação de Cálculo do IRPJ Mensal por Estimativa
procedure pkb_vld_calc_irpj_mes_estim
is
   --
   vn_fase number;
   --
   cursor c_dados is
   select l.*
        , td.codentref_id
        , td.registroecf_id
        , td.cd
        , td.ordem
     from calc_irpj_mes_estim  l
        , tab_din_ecf          td
    where l.percalcapurlr_id    = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
      and td.id                 = l.tabdinecf_id
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api_secf.gt_row_calc_irpj_mes_estim := null;
      --
      pk_csf_api_secf.gt_row_calc_irpj_mes_estim.id                  := rec.id;
      pk_csf_api_secf.gt_row_calc_irpj_mes_estim.percalcapurlr_id    := rec.percalcapurlr_id;
      pk_csf_api_secf.gt_row_calc_irpj_mes_estim.tabdinecf_id        := rec.tabdinecf_id;
      pk_csf_api_secf.gt_row_calc_irpj_mes_estim.valor               := rec.valor;
      pk_csf_api_secf.gt_row_calc_irpj_mes_estim.dm_tipo             := rec.dm_tipo;
      --
      vn_fase := 3;
      --
      -- Chama API que Integra as informações de Cálculo do IRPJ Mensal por Estimativa N620
      pk_csf_api_secf.pkb_integr_calc_irpj_mes_estim ( est_log_generico              => gt_log_generico
                                                     , est_row_calc_irpj_mes_estim   => pk_csf_api_secf.gt_row_calc_irpj_mes_estim
                                                     , en_codentref_id               => rec.codentref_id
                                                     , en_registroecf_id             => rec.registroecf_id
                                                     , ev_tabdinecf_cd               => rec.cd
                                                     );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_vld_calc_irpj_mes_estim fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_vld_calc_irpj_mes_estim;

-------------------------------------------------------------------------------------------------------

-- Procedimento de validação de Informações da Base de Cálclulo dos Incentivos Fiscais
procedure pkb_vld_inf_bc_inc_fiscal
is
   --
   vn_fase number;
   --
   cursor c_dados is
   select l.*
     from inf_bc_inc_fiscal l
    where l.percalcapurlr_id    = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
    order by 1;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api_secf.gt_row_inf_bc_inc_fiscal := null;
      --
      pk_csf_api_secf.gt_row_inf_bc_inc_fiscal := rec;
      --
      vn_fase := 3;
      --
      -- Chama API que Integra as Informações da Base de Cálclulo dos Incentivos Fiscais N615
      pk_csf_api_secf.pkb_integr_inf_bc_inc_fiscal ( est_log_generico            => gt_log_generico
                                                   , est_row_inf_bc_inc_fiscal   => pk_csf_api_secf.gt_row_inf_bc_inc_fiscal
                                                   );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_vld_inf_bc_inc_fiscal fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_vld_inf_bc_inc_fiscal;

-------------------------------------------------------------------------------------------------------

-- Procedimento de validação de Cálculo da Isenção e Redução do Imposto Sobre o Lucro Real
procedure pkb_vld_calc_isen_red_imp_lr
is
   --
   vn_fase number;
   --
   cursor c_dados is
   select l.*
        , td.codentref_id
        , td.registroecf_id
        , td.cd
        , td.ordem
     from calc_isen_red_imp_lr l
        , tab_din_ecf          td
    where l.percalcapurlr_id    = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
      and td.id                 = l.tabdinecf_id
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api_secf.gt_row_calc_isen_red_imp_lr := null;
      --
      pk_csf_api_secf.gt_row_calc_isen_red_imp_lr.id                  := rec.id;
      pk_csf_api_secf.gt_row_calc_isen_red_imp_lr.percalcapurlr_id    := rec.percalcapurlr_id;
      pk_csf_api_secf.gt_row_calc_isen_red_imp_lr.tabdinecf_id        := rec.tabdinecf_id;
      pk_csf_api_secf.gt_row_calc_isen_red_imp_lr.valor               := rec.valor;
      pk_csf_api_secf.gt_row_calc_isen_red_imp_lr.dm_tipo             := rec.dm_tipo;
      --
      vn_fase := 3;
      --
      -- Chama API que Integra as informações de Cálculo da Isenção e Redução do Imposto Sobre o Lucro Real N610
      pk_csf_api_secf.pkb_integr_calc_isen_red_implr ( est_log_generico               => gt_log_generico
                                                     , est_row_calc_isen_red_imp_lr   => pk_csf_api_secf.gt_row_calc_isen_red_imp_lr
                                                     , en_codentref_id                => rec.codentref_id
                                                     , en_registroecf_id              => rec.registroecf_id
                                                     , ev_tabdinecf_cd                => rec.cd
                                                     );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_vld_calc_isen_red_imp_lr fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_vld_calc_isen_red_imp_lr;

-------------------------------------------------------------------------------------------------------

-- Procedimento de validação de Demonstração do Lucro da Exploração
procedure pkb_vld_dem_lucro_expl
is
   --
   vn_fase number;
   --
   cursor c_dados is
   select l.*
        , td.codentref_id
        , td.registroecf_id
        , td.cd
        , td.ordem
     from dem_lucro_expl       l
        , tab_din_ecf          td
    where l.percalcapurlr_id    = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
      and td.id                 = l.tabdinecf_id
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api_secf.gt_row_dem_lucro_expl := null;
      --
      pk_csf_api_secf.gt_row_dem_lucro_expl.id                  := rec.id;
      pk_csf_api_secf.gt_row_dem_lucro_expl.percalcapurlr_id    := rec.percalcapurlr_id;
      pk_csf_api_secf.gt_row_dem_lucro_expl.tabdinecf_id        := rec.tabdinecf_id;
      pk_csf_api_secf.gt_row_dem_lucro_expl.valor               := rec.valor;
      pk_csf_api_secf.gt_row_dem_lucro_expl.dm_tipo             := rec.dm_tipo;
      --
      vn_fase := 3;
      --
      -- Chama API que Integra as informações de Demonstração do Lucro da Exploração N600
      pk_csf_api_secf.pkb_integr_dem_lucro_expl ( est_log_generico         => gt_log_generico
                                                , est_row_dem_lucro_expl   => pk_csf_api_secf.gt_row_dem_lucro_expl
                                                , en_codentref_id          => rec.codentref_id
                                                , en_registroecf_id        => rec.registroecf_id
                                                , ev_tabdinecf_cd          => rec.cd
                                                );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_vld_dem_lucro_expl fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_vld_dem_lucro_expl;

-------------------------------------------------------------------------------------------------------

-- Procedimento de validação de Base de Cálculo do IRPJ Sobre o Lucro Real Após as Compensações de Prejuízos
procedure pkb_vld_bc_irpj_lr_compprej
is
   --
   vn_fase number;
   --
   cursor c_dados is
   select l.*
        , td.codentref_id
        , td.registroecf_id
        , td.cd
        , td.ordem
     from bc_irpj_lr_comp_prej l
        , tab_din_ecf          td
    where l.percalcapurlr_id    = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
      and td.id                 = l.tabdinecf_id
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api_secf.gt_row_bc_irpj_lr_comp_prej := null;
      --
      pk_csf_api_secf.gt_row_bc_irpj_lr_comp_prej.id                  := rec.id;
      pk_csf_api_secf.gt_row_bc_irpj_lr_comp_prej.percalcapurlr_id    := rec.percalcapurlr_id;
      pk_csf_api_secf.gt_row_bc_irpj_lr_comp_prej.tabdinecf_id        := rec.tabdinecf_id;
      pk_csf_api_secf.gt_row_bc_irpj_lr_comp_prej.valor               := rec.valor;
      pk_csf_api_secf.gt_row_bc_irpj_lr_comp_prej.dm_tipo             := rec.dm_tipo;
      --
      vn_fase := 3;
      --
      -- Chama API que Integra as informações de Base de Cálculo do IRPJ Sobre o Lucro Real Após as Compensações de Prejuízos N500
      pk_csf_api_secf.pkb_integr_bc_irpj_lr_compprej ( est_log_generico               => gt_log_generico
                                                     , est_row_bc_irpj_lr_comp_prej   => pk_csf_api_secf.gt_row_bc_irpj_lr_comp_prej
                                                     , en_codentref_id                => rec.codentref_id
                                                     , en_registroecf_id              => rec.registroecf_id
                                                     , ev_tabdinecf_cd                => rec.cd
                                                     );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_vld_bc_irpj_lr_compprej fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_vld_bc_irpj_lr_compprej;

-------------------------------------------------------------------------------------------------------

-- Procedimento de processo de Calculo da Apuracao do Lucro Real
procedure pkb_processar ( en_percalcapurlr_id  in per_calc_apur_lr.id%type )
is
   --
   vn_fase number;
   vn_loggenerico_id  log_generico.id%type;
   --
   vv_dominio_descr Dominio.descr%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   gt_log_generico.delete;
   --
   if nvl(en_percalcapurlr_id,0) > 0 then
      --
      vn_fase := 2;
      --
      pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
      --
      begin
         --
         select *
           into pk_csf_api_secf.gt_row_per_calc_apur_lr
           from per_calc_apur_lr
          where id = en_percalcapurlr_id;
         --
      exception
         when others then
            pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
      end;
      --
      vn_fase := 3;
      --
      if nvl(pk_csf_api_secf.gt_row_per_calc_apur_lr.id,0) > 0 then
         --
         pk_csf_api_secf.pkb_inicia_param ( en_aberturaecf_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id );
         --
         vn_fase := 4;
         -- Procedimento seta o objeto de referencia utilizado na Validação da Informação
         pk_csf_api_secf.pkb_seta_obj_ref ( ev_objeto => 'PER_CALC_APUR_LR' );
         --
         vn_fase := 4.1;
         -- Procedimento seta o "ID de Referencia" utilizado na Validação da Informação
         pk_csf_api_secf.pkb_seta_referencia_id ( en_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.id );
         --
         vn_fase := 5;
         --
         if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_situacao = 1 then -- Calculado
            --
            vn_fase := 6;
            --| Chama procedimento para validar os dados
            --
            vn_fase := 6.1;
            --
            -- Chama API que Integra as informações do Periodo de Cálculo da Apuração do Lucro Real N030
            pk_csf_api_secf.pkb_integr_per_calc_apur_lr ( est_log_generico          => gt_log_generico
                                                        , est_row_per_calc_apur_lr  => pk_csf_api_secf.gt_row_per_calc_apur_lr
                                                        );
            --
            vn_fase := 6.2;
            --
            -- Chama Procedimento de atualizar os valores de Base de Cálculo do IRPJ Sobre o Lucro Real Após as Compensações de Prejuízos
            pkb_somar_vlr_birlrcp;
            --
            vn_fase := 6.21;
            -- Chama Procedimento de validação de Base de Cálculo do IRPJ Sobre o Lucro Real Após as Compensações de Prejuízos
            pkb_vld_bc_irpj_lr_compprej;
            --
            vn_fase := 6.3;
            --
            -- Chama Procedimento de atualizar os valores de Demonstração do Lucro da Exploração
            pkb_soma_vlr_dle;
            --
            vn_fase := 6.31;
            -- Chama Procedimento de validação de Demonstração do Lucro da Exploração
            pkb_vld_dem_lucro_expl;
            --
            vn_fase := 6.4;
            --
            -- Chama Procedimento de atualizar os valores de Cálculo da Isenção e Redução do Imposto Sobre o Lucro Real
            pkb_soma_vlr_cirilr;
            --
            vn_fase := 6.41;
            -- Chama Procedimento de validação de Cálculo da Isenção e Redução do Imposto Sobre o Lucro Real
            pkb_vld_calc_isen_red_imp_lr;
            --
            vn_fase := 6.5;
            --
            -- Chama Procedimento de atualizar os valores de Cálculo da Isenção e Redução do Imposto Sobre o Lucro Real
            pkb_soma_vlr_cirilr;
            --
            vn_fase := 6.51;
            -- Chama Procedimento de validação de Informações da Base de Cálclulo dos Incentivos Fiscais
            pkb_vld_inf_bc_inc_fiscal;
            --
            vn_fase := 6.6;
            --
            -- Chama Procedimento de atualizar os valores de Cálculo do IRPJ Mensal por Estimativa
            pkb_soma_vlr_cirpjme;
            --
            vn_fase := 6.61;
            -- Chama Procedimento de validação de Cálculo do IRPJ Mensal por Estimativa
            pkb_vld_calc_irpj_mes_estim;
            --
            vn_fase := 6.7;
            --
            -- Chama Procedimento de atualizar os valores de Cálculo do IRPJ Com Base no Lucro Real
            pkb_soma_vlr_cirpjblr;
            --
            vn_fase := 6.71;
            -- Chama Procedimento de validação de Cálculo do IRPJ Com Base no Lucro Real
            pkb_vld_calc_irpj_base_lr;
            --
            vn_fase := 6.8;
            --
            -- Chama Procedimento de atualizar os valores de Base de Cálculo da CSLL Após as Compensações da Base de Cálculo Negativa
            pkb_soma_vlr_bccsllcp;
            --
            vn_fase := 6.81;
            -- Chama Procedimento de validação de Base de Cálculo da CSLL Após as Compensações da Base de Cálculo Negativa
            pkb_vld_bc_csll_comp_neg;
            --
            vn_fase := 6.9;
            --
            -- Chama Procedimento de atualizar os valores de Cálculo da CSLL Mensal por Estimativa
            pkb_soma_vlr_ccsllme;
            --
            vn_fase := 6.91;
            -- Chama Procedimento de validação de Cálculo da CSLL Mensal por Estimativa
            pkb_vld_calc_csll_mes_estim;
            --
            vn_fase := 6.10;
            --
            -- Chama Procedimento de atualizar os valores de Cálculo da CSLL Com Base no Lucro Real
            pkb_soma_vlr_ccsllblr;
            --
            vn_fase := 6.101;
            -- Chama Procedimento de validação de Cálculo da CSLL Com Base no Lucro Real
            pkb_vld_calc_csll_base_lr;
            --
            vn_fase := 7;
            -- Chama procedimento para atribuir a Situação do Periodo de Cálculo da Apuração do Lucro Real
            pkb_seta_situacao ( ev_evento => 'PROCESSAR' );
            --
            commit;
            --
         else
            --
            vn_fase := 8;
            --
            vv_dominio_descr := pk_csf.fkg_dominio ( ev_dominio   => 'PER_CALC_APUR_LR.DM_SITUACAO'
                                                   , ev_vl        => pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_situacao
                                                   );
            --
            vn_fase := 8.1;
            --
            pk_csf_api_secf.gv_mensagem_log := 'Bloco N - Situação atual "' || vv_dominio_descr || '" não permite realizar o evento de "Processar".';
            --
            pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                             , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                             , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                             , en_tipo_log        => pk_csf_api_secf.INFORMACAO
                                             , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                             , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
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
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_processar fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_processar;

-------------------------------------------------------------------------------------------------------

-- Procedimento para gerar os valores de Cálculo da CSLL Com Base no Lucro Real
procedure pkb_gerar_vlr_ccsllblr
is
   --
   vn_fase number;
   --
   vn_valor calc_csll_base_lr.valor%type;
   vn_tipo  calc_csll_base_lr.dm_tipo%type;
   --
   cursor c_dados is
   select d.id                   calccsllbaselr_id
        , td.id                  tabdinecf_id
        , td.registroecf_id
        , td.ordem
     from calc_csll_base_lr      d
        , tab_din_ecf            td
    where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
      and td.id                  = d.tabdinecf_id
      and td.dm_tipo             = 'E' -- Editável
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      vn_fase := 2;
      --
      vn_valor := 0;
      --
      -- Procedimento CORAÇÃO do Sped ECF para geração dos valores DE-PARA
      pk_csf_api_secf.pkb_monta_vlr_tab_din_ecf ( en_aberturaecf_id    => pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                                                , en_registroecf_id    => rec.registroecf_id
                                                , en_tabdinecf_id      => rec.tabdinecf_id
                                                , ed_dt_ini            => pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                                                , ed_dt_fin            => pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                                                , ev_tabela_orig       => 'CALC_CSLL_BASE_LR'
                                                , ev_tabela_relac      => 'R_MCECF_CCSLLBLR'
                                                , ev_col_relac         => 'CALCCSLLBASELR_ID'
                                                , en_id_orig           => rec.calccsllbaselr_id
                                                , ev_dm_per_apur       => pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                                                , ev_dm_mes_bal_red    => pk_csf_secf.fkg_vlr_mes_bal_red ( ev_dm_per_apur => pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur )
                                                , sn_vl                => vn_valor
                                                , sn_tipo              => vn_tipo
                                                );
      --
      vn_fase := 3;
      --
      update calc_csll_base_lr set valor    = nvl(vn_valor,0)
                                 , dm_tipo  = nvl(vn_tipo,0)
       where id = rec.calccsllbaselr_id;
      --
   end loop;
   --
   vn_fase := 4;
   --
   pkb_soma_vlr_ccsllblr;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_gerar_vlr_ccsllblr fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_gerar_vlr_ccsllblr;

-------------------------------------------------------------------------------------------------------

-- Procedimento para gerar os valores de Cálculo da CSLL Mensal por Estimativa
procedure pkb_gerar_vlr_ccsllme
is
   --
   vn_fase number;
   --
   vn_valor bc_csll_comp_neg.valor%type;
   vn_tipo  bc_csll_comp_neg.dm_tipo%type;
   --
   cursor c_dados is
   select d.id                   calccsllmesestim_id
        , td.id                  tabdinecf_id
        , td.registroecf_id
        , td.ordem
     from calc_csll_mes_estim    d
        , tab_din_ecf            td
    where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
      and td.id                  = d.tabdinecf_id
      and td.dm_tipo             = 'E' -- Editável
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      vn_fase := 2;
      --
      vn_valor := 0;
      --
      -- Procedimento CORAÇÃO do Sped ECF para geração dos valores DE-PARA
      pk_csf_api_secf.pkb_monta_vlr_tab_din_ecf ( en_aberturaecf_id    => pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                                                , en_registroecf_id    => rec.registroecf_id
                                                , en_tabdinecf_id      => rec.tabdinecf_id
                                                , ed_dt_ini            => pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                                                , ed_dt_fin            => pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                                                , ev_tabela_orig       => 'CALC_CSLL_MES_ESTIM'
                                                , ev_tabela_relac      => 'R_MCECF_CCSLLME'
                                                , ev_col_relac         => 'CALCCSLLMESESTIM_ID'
                                                , en_id_orig           => rec.calccsllmesestim_id
                                                , ev_dm_per_apur       => pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                                                , ev_dm_mes_bal_red    => pk_csf_secf.fkg_vlr_mes_bal_red ( ev_dm_per_apur => pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur )
                                                , sn_vl                => vn_valor
                                                , sn_tipo              => vn_tipo
                                                );
      --
      vn_fase := 3;
      --
      update calc_csll_mes_estim set valor    = nvl(vn_valor,0)
                                   , dm_tipo  = nvl(vn_tipo,0)
       where id = rec.calccsllmesestim_id;
      --
   end loop;
   --
   vn_fase := 4;
   --
   pkb_soma_vlr_ccsllme;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_gerar_vlr_ccsllme fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_gerar_vlr_ccsllme;

-------------------------------------------------------------------------------------------------------

-- Procedimento para gerar os valores de Base de Cálculo da CSLL Após as Compensações da Base de Cálculo Negativa
procedure pkb_gerar_vlr_bccsllcp
is
   --
   vn_fase number;
   --
   vn_valor bc_csll_comp_neg.valor%type;
   vn_tipo  bc_csll_comp_neg.dm_tipo%type;
   vv_mes_bal_red abert_ecf_param_trib.dm_mes_bal_red1%type;
   --
   cursor c_dados is
   select d.id                   bccsllcompneg_id
        , td.id                  tabdinecf_id
        , td.registroecf_id
        , td.ordem
        , td.cd
     from bc_csll_comp_neg       d
        , tab_din_ecf            td
    where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
      and td.id                  = d.tabdinecf_id
      and td.dm_tipo             = 'E' -- Editável
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   -- Função recupera a Indicação da Forma de Apuração da Estimativa
   vv_mes_bal_red := trim(pk_csf_secf.fkg_vlr_mes_bal_red ( ev_dm_per_apur => pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur ));
   --
   vn_fase := 1.1;
   --
   if vv_mes_bal_red is null
      or vv_mes_bal_red = 'E' -- Receita Bruta
      then
      --
      for rec in c_dados loop
         exit when c_dados%notfound or (c_dados%notfound) is null;
         --
         vn_fase := 2;
         --
         vn_valor := 0;
         --
         -- Procedimento CORAÇÃO do Sped ECF para geração dos valores DE-PARA
         pk_csf_api_secf.pkb_monta_vlr_tab_din_ecf ( en_aberturaecf_id    => pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                                                   , en_registroecf_id    => rec.registroecf_id
                                                   , en_tabdinecf_id      => rec.tabdinecf_id
                                                   , ed_dt_ini            => pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                                                   , ed_dt_fin            => pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                                                   , ev_tabela_orig       => 'BC_CSLL_COMP_NEG'
                                                   , ev_tabela_relac      => 'R_MCECF_BCCSLLCP'
                                                   , ev_col_relac         => 'BCCSLLCOMPNEG_ID'
                                                   , en_id_orig           => rec.bccsllcompneg_id
                                                   , ev_dm_per_apur       => pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                                                   , ev_dm_mes_bal_red    => pk_csf_secf.fkg_vlr_mes_bal_red ( ev_dm_per_apur => pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur )
                                                   , sn_vl                => vn_valor
                                                   , sn_tipo              => vn_tipo
                                                   );
         --
         vn_fase := 3;
         --
         if rec.cd = '2' then
            -- Percentual recolhimento por estimativa no lucro real
            if nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_recol_estim_lr,0) > 0 then
               -- Redução da base
               vn_valor := nvl(vn_valor,0) * ( nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_recol_estim_lr,0)/100 );
               --
            end if;
            --
         end if;
         --
         vn_fase := 4;
         --
         update bc_csll_comp_neg set valor    = nvl(vn_valor,0)
                                   , dm_tipo  = nvl(vn_tipo,0)
          where id = rec.bccsllcompneg_id;
         --
      end loop;
      --
   end if;
   --
   vn_fase := 4;
   --
   pkb_soma_vlr_bccsllcp;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_gerar_vlr_bccsllcp fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_gerar_vlr_bccsllcp;

-------------------------------------------------------------------------------------------------------

-- Procedimento para gerar os valores de Cálculo do IRPJ Com Base no Lucro Real
procedure pkb_gerar_vlr_cirpjblr
is
   --
   vn_fase number;
   --
   vn_valor calc_irpj_base_lr.valor%type;
   vn_tipo  calc_irpj_base_lr.dm_tipo%type;
   --
   cursor c_dados is
   select d.id                   calcirpjbaselr_id
        , td.id                  tabdinecf_id
        , td.registroecf_id
        , td.ordem
     from calc_irpj_base_lr      d
        , tab_din_ecf            td
    where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
      and td.id                  = d.tabdinecf_id
      and td.dm_tipo             = 'E' -- Editável
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      vn_fase := 2;
      --
      vn_valor := 0;
      --
      -- Procedimento CORAÇÃO do Sped ECF para geração dos valores DE-PARA
      pk_csf_api_secf.pkb_monta_vlr_tab_din_ecf ( en_aberturaecf_id    => pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                                                , en_registroecf_id    => rec.registroecf_id
                                                , en_tabdinecf_id      => rec.tabdinecf_id
                                                , ed_dt_ini            => pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                                                , ed_dt_fin            => pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                                                , ev_tabela_orig       => 'CALC_IRPJ_BASE_LR'
                                                , ev_tabela_relac      => 'R_MCECF_CIRPJBLR'
                                                , ev_col_relac         => 'CALCIRPJBASELR_ID'
                                                , en_id_orig           => rec.calcirpjbaselr_id
                                                , ev_dm_per_apur       => pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                                                , ev_dm_mes_bal_red    => pk_csf_secf.fkg_vlr_mes_bal_red ( ev_dm_per_apur => pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur )
                                                , sn_vl                => vn_valor
                                                , sn_tipo              => vn_tipo
                                                );
      --
      vn_fase := 3;
      --
      update calc_irpj_base_lr set valor    = nvl(vn_valor,0)
                                 , dm_tipo  = nvl(vn_tipo,0)
       where id = rec.calcirpjbaselr_id;
      --
   end loop;
   --
   vn_fase := 4;
   --
   pkb_soma_vlr_cirpjblr;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_gerar_vlr_cirpjblr fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_gerar_vlr_cirpjblr;

-------------------------------------------------------------------------------------------------------

-- Procedimento para gerar os valores de Cálculo do IRPJ Mensal por Estimativa
procedure pkb_gerar_vlr_cirpjme
is
   --
   vn_fase number;
   --
   vn_valor calc_irpj_mes_estim.valor%type;
   vn_tipo  calc_irpj_mes_estim.dm_tipo%type;
   --
   cursor c_dados is
   select d.id                   calcirpjmesestim_id
        , td.id                  tabdinecf_id
        , td.registroecf_id
        , td.ordem
     from calc_irpj_mes_estim    d
        , tab_din_ecf            td
    where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
      and td.id                  = d.tabdinecf_id
      and td.dm_tipo             = 'E' -- Editável
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      vn_fase := 2;
      --
      vn_valor := 0;
      --
      -- Procedimento CORAÇÃO do Sped ECF para geração dos valores DE-PARA
      pk_csf_api_secf.pkb_monta_vlr_tab_din_ecf ( en_aberturaecf_id    => pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                                                , en_registroecf_id    => rec.registroecf_id
                                                , en_tabdinecf_id      => rec.tabdinecf_id
                                                , ed_dt_ini            => pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                                                , ed_dt_fin            => pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                                                , ev_tabela_orig       => 'CALC_IRPJ_MES_ESTIM'
                                                , ev_tabela_relac      => 'R_MCECF_CIRPJME'
                                                , ev_col_relac         => 'CALCIRPJMESESTIM_ID'
                                                , en_id_orig           => rec.calcirpjmesestim_id
                                                , ev_dm_per_apur       => pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                                                , ev_dm_mes_bal_red    => pk_csf_secf.fkg_vlr_mes_bal_red ( ev_dm_per_apur => pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur )
                                                , sn_vl                => vn_valor
                                                , sn_tipo              => vn_tipo
                                                );
      --
      vn_fase := 3;
      --
      update calc_irpj_mes_estim set valor    = nvl(vn_valor,0)
                                   , dm_tipo  = nvl(vn_tipo,0)
       where id = rec.calcirpjmesestim_id;
      --
   end loop;
   --
   vn_fase := 4;
   --
   pkb_soma_vlr_cirpjme;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_gerar_vlr_cirpjme fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_gerar_vlr_cirpjme;

-------------------------------------------------------------------------------------------------------

-- Procedimento para gerar os valores de Cálculo da Isenção e Redução do Imposto Sobre o Lucro Real
procedure pkb_gerar_vlr_cirilr
is
   --
   vn_fase number;
   --
   vn_valor dem_lucro_expl.valor%type;
   vn_tipo  dem_lucro_expl.dm_tipo%type;
   --
   cursor c_dados is
   select d.id                   calcisenredimplr_id
        , td.id                  tabdinecf_id
        , td.registroecf_id
        , td.ordem
     from calc_isen_red_imp_lr   d
        , tab_din_ecf            td
    where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
      and td.id                  = d.tabdinecf_id
      and td.dm_tipo             = 'E' -- Editável
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      vn_fase := 2;
      --
      vn_valor := 0;
      --
      -- Procedimento CORAÇÃO do Sped ECF para geração dos valores DE-PARA
      pk_csf_api_secf.pkb_monta_vlr_tab_din_ecf ( en_aberturaecf_id    => pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                                                , en_registroecf_id    => rec.registroecf_id
                                                , en_tabdinecf_id      => rec.tabdinecf_id
                                                , ed_dt_ini            => pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                                                , ed_dt_fin            => pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                                                , ev_tabela_orig       => 'CALC_ISEN_RED_IMP_LR'
                                                , ev_tabela_relac      => 'R_MCECF_CIRILR'
                                                , ev_col_relac         => 'CALCISENREDIMPLR_ID'
                                                , en_id_orig           => rec.calcisenredimplr_id
                                                , ev_dm_per_apur       => pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                                                , ev_dm_mes_bal_red    => pk_csf_secf.fkg_vlr_mes_bal_red ( ev_dm_per_apur => pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur )
                                                , sn_vl                => vn_valor
                                                , sn_tipo              => vn_tipo
                                                );
      --
      vn_fase := 3;
      --
      update calc_isen_red_imp_lr set valor    = nvl(vn_valor,0)
                                    , dm_tipo  = nvl(vn_tipo,0)
       where id = rec.calcisenredimplr_id;
      --
   end loop;
   --
   vn_fase := 4;
   --
   pkb_soma_vlr_cirilr;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_gerar_vlr_cirilr fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_gerar_vlr_cirilr;

-------------------------------------------------------------------------------------------------------

-- Procedimento para gerar os valores de Demonstração do Lucro da Exploração
procedure pkb_gerar_vlr_dle
is
   --
   vn_fase number;
   --
   vn_demlucroexpl_id  dem_lucro_expl.id%type;   
   vn_valor            dem_lucro_expl.valor%type;
   vn_tipo             dem_lucro_expl.dm_tipo%type;
   vd_dt_ini           per_calc_apur_lr.dt_ini%type;
   vd_dt_fin           per_calc_apur_lr.dt_fin%type;  
   vn_empresa_id       abertura_ecf.empresa_id%type;
   vv_cd               tab_din_ecf.cd%type;
   vn_existe           number;   
   --
   cursor c_dados is
   select d.id                   demlucroexpl_id
        , td.id                  tabdinecf_id
        , td.registroecf_id
        , td.ordem
     from dem_lucro_expl         d
        , tab_din_ecf            td
    where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
      and td.id                  = d.tabdinecf_id
      and td.dm_tipo             = 'E' -- Editável
    order by td.ordem, td.cd;
   --
   cursor c_dados2 is
    select d.id  demlucroexpl_id
         , p.dt_ini
         , p.dt_fin
         , a.empresa_id
         , t.cd		 
      from dem_lucro_expl d
         , per_calc_apur_lr p 
         , tab_din_ecf t
         , registro_ecf r
         , abertura_ecf a          
     where d.percalcapurlr_id = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
       and p.id               = d.percalcapurlr_id
       and a.id               = p.aberturaecf_id
       and t.id               = d.tabdinecf_id 
       and t.cd              in ('11','18')
       and r.id               = t.registroecf_id
       and r.cod              = 'N600';
   --   
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      vn_fase := 2;
      --
      vn_valor := 0;
      --
      -- Procedimento CORAÇÃO do Sped ECF para geração dos valores DE-PARA
      pk_csf_api_secf.pkb_monta_vlr_tab_din_ecf ( en_aberturaecf_id    => pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                                                , en_registroecf_id    => rec.registroecf_id
                                                , en_tabdinecf_id      => rec.tabdinecf_id
                                                , ed_dt_ini            => pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                                                , ed_dt_fin            => pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                                                , ev_tabela_orig       => 'DEM_LUCRO_EXPL'
                                                , ev_tabela_relac      => 'R_MCECF_DLE'
                                                , ev_col_relac         => 'DEMLUCROEXPL_ID'
                                                , en_id_orig           => rec.demlucroexpl_id
                                                , ev_dm_per_apur       => pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                                                , ev_dm_mes_bal_red    => pk_csf_secf.fkg_vlr_mes_bal_red ( ev_dm_per_apur => pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur )
                                                , sn_vl                => vn_valor
                                                , sn_tipo              => vn_tipo
                                                );
      --
      vn_fase := 3;
      --
      update dem_lucro_expl set valor    = nvl(vn_valor,0)
                              , dm_tipo  = nvl(vn_tipo,0)
       where id = rec.demlucroexpl_id;
      --
   end loop;	  
   --   
   vn_fase := 4;
   --
   for rec2 in c_dados2 loop
      exit when c_dados2%notfound or (c_dados2%notfound) is null;
	  
      vn_fase := 4.1;
      --
      vn_demlucroexpl_id := rec2.demlucroexpl_id;
      vd_dt_ini          := rec2.dt_ini;
      vd_dt_fin          := rec2.dt_fin;
      vn_empresa_id      := rec2.empresa_id;
      vv_cd              := rec2.cd; 
      --	  
      vn_existe          := null;
      vn_valor           := null;
      --	  
      if vv_cd = '11' then
         --	  
         begin
            select c.vl_red_benef_tot
                 , 1
              into vn_valor
                 , vn_existe			  
              from calc_lucro_expl c
                 , per_lucr_expl   p
             where p.id         = c.perlucrexpl_id
               and p.empresa_id = vn_empresa_id
               and p.dt_ini    >= vd_dt_ini
               and p.dt_fim    <= vd_dt_fin;		 
         exception
            when no_data_found then
               vn_valor  := null;
               vn_existe := null;			   
         end;		 
         --
         vn_fase := 4.2;		 
         --
         if nvl( vn_existe, 0 ) <> 0 and nvl( vn_valor,0 ) > 0 then
            --		 
            update dem_lucro_expl set valor    = nvl(vn_valor,0)
             where id = rec2.demlucroexpl_id;
            --
         end if;
         --
      end if;
      --	
      vn_fase := 4.3;
      --	  
      if vv_cd = '18' then
	     --
         vn_existe := null;
         vn_valor  := null;		 
         --		 
         begin
            select c.vl_rec_demais_ativ
                 , 1
              into vn_valor
                 , vn_existe			  
              from calc_lucro_expl c
                 , per_lucr_expl   p
             where p.id         = c.perlucrexpl_id
               and p.empresa_id = vn_empresa_id
               and p.dt_ini    >= vd_dt_ini
               and p.dt_fim    <= vd_dt_fin;		 
         exception
            when no_data_found then
               vn_valor  := null;
               vn_existe := null;			   
         end;		 
         --
         vn_fase := 4.4;		 
         --
         if nvl( vn_existe, 0 ) <> 0 and nvl( vn_valor,0 ) > 0 then
            --		 
            update dem_lucro_expl set valor    = nvl(vn_valor,0)
             where id = rec2.demlucroexpl_id;
            --
         end if;
         --
      end if;
      -- 	  
   end loop;
   --
   vn_fase := 5;
   --
   pkb_soma_vlr_dle;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_gerar_vlr_dle fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_gerar_vlr_dle;

-------------------------------------------------------------------------------------------------------

-- Procedimento para gerar os valores de Base de Cálculo do IRPJ Sobre o Lucro Real Após as Compensações de Prejuízos
procedure pkb_gerar_vlr_birlrcp
is
   --
   vn_fase number;
   --
   vn_valor bc_irpj_lr_comp_prej.valor%type;
   vn_tipo  bc_irpj_lr_comp_prej.dm_tipo%type;
   vv_mes_bal_red abert_ecf_param_trib.dm_mes_bal_red1%type;
   --
   cursor c_dados is
   select d.id                   bcirpjlrcompprej_id
        , td.id                  tabdinecf_id
        , td.registroecf_id
        , td.ordem
        , td.cd
     from bc_irpj_lr_comp_prej   d
        , tab_din_ecf            td
    where d.percalcapurlr_id     = pk_csf_api_secf.gt_row_per_calc_apur_lr.id
      and td.id                  = d.tabdinecf_id
      and td.dm_tipo             = 'E' -- Editável
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   -- Função recupera a Indicação da Forma de Apuração da Estimativa
   vv_mes_bal_red := trim(pk_csf_secf.fkg_vlr_mes_bal_red ( ev_dm_per_apur => pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur ));
   --
   vn_fase := 1.1;
   --
   if vv_mes_bal_red is null
      or vv_mes_bal_red = 'E' -- Receita Bruta
      then
      --
      for rec in c_dados loop
         exit when c_dados%notfound or (c_dados%notfound) is null;
         --
         vn_fase := 2;
         --
         vn_valor := 0;
         --
         -- Procedimento CORAÇÃO do Sped ECF para geração dos valores DE-PARA
         pk_csf_api_secf.pkb_monta_vlr_tab_din_ecf ( en_aberturaecf_id    => pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id
                                                   , en_registroecf_id    => rec.registroecf_id
                                                   , en_tabdinecf_id      => rec.tabdinecf_id
                                                   , ed_dt_ini            => pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini
                                                   , ed_dt_fin            => pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin
                                                   , ev_tabela_orig       => 'BC_IRPJ_LR_COMP_PREJ'
                                                   , ev_tabela_relac      => 'R_MCECF_BIRLRCP'
                                                   , ev_col_relac         => 'BCIRPJLRCOMPPREJ_ID'
                                                   , en_id_orig           => rec.bcirpjlrcompprej_id
                                                   , ev_dm_per_apur       => pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur
                                                   , ev_dm_mes_bal_red    => pk_csf_secf.fkg_vlr_mes_bal_red ( ev_dm_per_apur => pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur )
                                                   , sn_vl                => vn_valor
                                                   , sn_tipo              => vn_tipo
                                                   );
         --
         vn_fase := 3;
         --
         if rec.cd = '2' then
            -- Percentual recolhimento por estimativa no lucro real
            if nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_recol_estim_lr,0) > 0 then
               -- Redução da base
               vn_valor := nvl(vn_valor,0) * ( nvl(pk_csf_api_secf.gt_abert_ecf_param_geral.perc_recol_estim_lr,0)/100 );
               --
            end if;
            --
         end if;
         --
         vn_fase := 4;
         --
         update bc_irpj_lr_comp_prej set valor    = nvl(vn_valor,0)
                                       , dm_tipo  = nvl(vn_tipo,0)
          where id = rec.bcirpjlrcompprej_id;
         --
      end loop;
      --
   end if;
   --
   vn_fase := 4;
   --
   pkb_somar_vlr_birlrcp;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_gerar_vlr_birlrcp fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_gerar_vlr_birlrcp;

-------------------------------------------------------------------------------------------------------

-- Procedimento de calcular o Calculo da Apuracao do Lucro Real
procedure pkb_calcular ( en_percalcapurlr_id  in per_calc_apur_lr.id%type )
is
   --
   vn_fase number;
   vn_loggenerico_id  log_generico.id%type;
   --
   vv_dominio_descr Dominio.descr%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   gt_log_generico.delete;
   --
   if nvl(en_percalcapurlr_id,0) > 0 then
      --
      vn_fase := 2;
      --
      pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
      --
      begin
         --
         select *
           into pk_csf_api_secf.gt_row_per_calc_apur_lr
           from per_calc_apur_lr
          where id = en_percalcapurlr_id;
         --
      exception
         when others then
            pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
      end;
      --
      vn_fase := 3;
      --
      if nvl(pk_csf_api_secf.gt_row_per_calc_apur_lr.id,0) > 0 then
         --
         pk_csf_api_secf.pkb_inicia_param ( en_aberturaecf_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id );
         --
         vn_fase := 4;
         -- Procedimento seta o objeto de referencia utilizado na Validação da Informação
         pk_csf_api_secf.pkb_seta_obj_ref ( ev_objeto => 'PER_CALC_APUR_LR' );
         --
         vn_fase := 4.1;
         -- Procedimento seta o "ID de Referencia" utilizado na Validação da Informação
         pk_csf_api_secf.pkb_seta_referencia_id ( en_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.id );
         --
         vn_fase := 5;
         --
         if pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_situacao = 0 then -- Aberto
            --
            vn_fase := 6;
            --| Chama procedimento para calcular os dados
            --
            -- Chama Procedimento para gerar os valores de Base de Cálculo do IRPJ Sobre o Lucro Real Após as Compensações de Prejuízos
            pkb_gerar_vlr_birlrcp;
            --
            vn_fase := 6.1;
            --
            -- Chama Procedimento para gerar os valores de Demonstração do Lucro da Exploração
            pkb_gerar_vlr_dle;
            --
            vn_fase := 6.2;
            --
            -- Chama Procedimento para gerar os valores de Cálculo da Isenção e Redução do Imposto Sobre o Lucro Real
            pkb_gerar_vlr_cirilr;
            --
            vn_fase := 6.3;
            --
            --
            vn_fase := 6.4;
            -- Chama Procedimento para gerar os valores de Cálculo do IRPJ Mensal por Estimativa
            pkb_gerar_vlr_cirpjme;
            --
            vn_fase := 6.5;
            --
            -- Chama Procedimento para gerar os valores de Cálculo do IRPJ Com Base no Lucro Real
            pkb_gerar_vlr_cirpjblr;
            --
            vn_fase := 6.6;
            --
            -- Chama Procedimento para gerar os valores de Base de Cálculo da CSLL Após as Compensações da Base de Cálculo Negativa
            pkb_gerar_vlr_bccsllcp;
            --
            vn_fase := 6.7;
            --
            -- Chama Procedimento para gerar os valores de Cálculo da CSLL Mensal por Estimativa
            pkb_gerar_vlr_ccsllme;
            --
            vn_fase := 6.8;
            -- Chama Procedimento para gerar os valores de Cálculo da CSLL Com Base no Lucro Real
            pkb_gerar_vlr_ccsllblr;
            --
            vn_fase := 7;
            -- Chama procedimento para atribuir a Situação do Periodo de Cálculo da Apuração do Lucro Real
            pkb_seta_situacao ( ev_evento => 'CALCULAR' );
            --
            commit;
            --
         else
            --
            vn_fase := 8;
            --
            vv_dominio_descr := pk_csf.fkg_dominio ( ev_dominio   => 'PER_CALC_APUR_LR.DM_SITUACAO'
                                                   , ev_vl        => pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_situacao
                                                   );
            --
            vn_fase := 8.1;
            --
            pk_csf_api_secf.gv_mensagem_log := 'Bloco N - Situação atual "' || vv_dominio_descr || '" não permite realizar o evento de "Calcular".';
            --
            pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                             , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                             , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                             , en_tipo_log        => pk_csf_api_secf.INFORMACAO
                                             , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                             , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
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
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_calcular fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_calcular;

-------------------------------------------------------------------------------------------------------

-- Procedimento de montagem de Cálculo da CSLL Com Base no Lucro Real N670
procedure pkb_monta_calc_csll_base_lr
is
   --
   vn_fase number;
   --
   cursor c_dados is
   select td.id
        , td.registroecf_id
        , td.cd
        , td.descr
        , td.dt_ini
        , td.dt_fin
        , td.ordem
        , td.dm_tipo
        , td.dm_formato
        , td.formula
        , td.dm_tipo_lanc
        , td.codentref_id
     from tab_din_ecf td
        , registro_ecf r
    where r.id = td.registroecf_id
      and r.cod = 'N670'
      and ( to_number(to_char(td.dt_ini, 'RRRR')) <= to_number(to_char(pk_csf_api_secf.gt_abertura_ecf.dt_ini, 'RRRR'))
            and to_number(to_char(nvl(td.dt_fin, sysdate), 'RRRR')) >= to_number(to_char(pk_csf_api_secf.gt_abertura_ecf.dt_ini, 'RRRR'))
            )
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   if (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A00')
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur in ('T01', 'T02', 'T03', 'T04')) --#69540
      then
      --
      for rec in c_dados loop
         exit when c_dados%notfound or (c_dados%notfound) is null;
         --
         vn_fase := 2;
         --
         pk_csf_api_secf.gt_row_calc_csll_base_lr := null;
         --
         pk_csf_api_secf.gt_row_calc_csll_base_lr.percalcapurlr_id   := pk_csf_api_secf.gt_row_per_calc_apur_lr.id;
         pk_csf_api_secf.gt_row_calc_csll_base_lr.tabdinecf_id   := rec.id;
         --
         if rec.dm_tipo = 'R' then
            pk_csf_api_secf.gt_row_calc_csll_base_lr.valor        := null;
         else
            pk_csf_api_secf.gt_row_calc_csll_base_lr.valor        := 0;
         end if;
         --
         pk_csf_api_secf.gt_row_calc_csll_base_lr.dm_tipo         := 0;
         --
         vn_fase := 3;
         --
         -- Chama API Integra as informações de Cálculo da CSLL Com Base no Lucro Real N670
         pk_csf_api_secf.pkb_integr_calc_csll_base_lr ( est_log_generico            => gt_log_generico
                                                      , est_row_calc_csll_base_lr   => pk_csf_api_secf.gt_row_calc_csll_base_lr
                                                      , en_codentref_id             => rec.codentref_id
                                                      , en_registroecf_id           => rec.registroecf_id
                                                      , ev_tabdinecf_cd             => rec.cd
                                                      );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_monta_calc_csll_base_lr fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_monta_calc_csll_base_lr;

-------------------------------------------------------------------------------------------------------

-- Procedimento de montagem de Cálculo da CSLL Mensal por Estimativa N660
procedure pkb_monta_calc_csll_mes_estim
is
   --
   vn_fase number;
   --
   cursor c_dados is
   select td.id
        , td.registroecf_id
        , td.cd
        , td.descr
        , td.dt_ini
        , td.dt_fin
        , td.ordem
        , td.dm_tipo
        , td.dm_formato
        , td.formula
        , td.dm_tipo_lanc
        , td.codentref_id
     from tab_din_ecf td
        , registro_ecf r
    where r.id = td.registroecf_id
      and r.cod = 'N660'
      and ( to_number(to_char(td.dt_ini, 'RRRR')) <= to_number(to_char(pk_csf_api_secf.gt_abertura_ecf.dt_ini, 'RRRR'))
            and to_number(to_char(nvl(td.dt_fin, sysdate), 'RRRR')) >= to_number(to_char(pk_csf_api_secf.gt_abertura_ecf.dt_ini, 'RRRR'))
            )
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   if (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A01' )
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A02' )
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A03' )
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A04' )
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A05' )
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A06' )
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A07' )
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A08' )
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A09' )
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A10' )
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A11' )
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A12' )
      then
      --
      for rec in c_dados loop
         exit when c_dados%notfound or (c_dados%notfound) is null;
         --
         vn_fase := 2;
         --
         pk_csf_api_secf.gt_row_calc_csll_mes_estim := null;
         --
         pk_csf_api_secf.gt_row_calc_csll_mes_estim.percalcapurlr_id   := pk_csf_api_secf.gt_row_per_calc_apur_lr.id;
         pk_csf_api_secf.gt_row_calc_csll_mes_estim.tabdinecf_id   := rec.id;
         --
         if rec.dm_tipo = 'R' then
            pk_csf_api_secf.gt_row_calc_csll_mes_estim.valor        := null;
         else
            pk_csf_api_secf.gt_row_calc_csll_mes_estim.valor        := 0;
         end if;
         --
         pk_csf_api_secf.gt_row_calc_csll_mes_estim.dm_tipo         := 0;
         --
         vn_fase := 3;
         --
         -- Chama API Integra as informações de Cálculo da CSLL Mensal por Estimativa N660
         pk_csf_api_secf.pkb_integr_calc_csll_mes_estim ( est_log_generico              => gt_log_generico
                                                        , est_row_calc_csll_mes_estim   => pk_csf_api_secf.gt_row_calc_csll_mes_estim
                                                        , en_codentref_id               => rec.codentref_id
                                                        , en_registroecf_id             => rec.registroecf_id
                                                        , ev_tabdinecf_cd               => rec.cd
                                                        );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_monta_calc_csll_mes_estim fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_monta_calc_csll_mes_estim;

-------------------------------------------------------------------------------------------------------

-- Procedimento de montagem de Base de Cálculo da CSLL Após as Compensações da Base de Cálculo Negativa N650
procedure pkb_monta_bc_csll_comp_neg
is
   --
   vn_fase number;
   --
   cursor c_dados is
   select td.id
        , td.registroecf_id
        , td.cd
        , td.descr
        , td.dt_ini
        , td.dt_fin
        , td.ordem
        , td.dm_tipo
        , td.dm_formato
        , td.formula
        , td.dm_tipo_lanc
        , td.codentref_id
     from tab_din_ecf td
        , registro_ecf r
    where r.id = td.registroecf_id
      and r.cod = 'N650'
      and ( to_number(to_char(td.dt_ini, 'RRRR')) <= to_number(to_char(pk_csf_api_secf.gt_abertura_ecf.dt_ini, 'RRRR'))
            and to_number(to_char(nvl(td.dt_fin, sysdate), 'RRRR')) >= to_number(to_char(pk_csf_api_secf.gt_abertura_ecf.dt_ini, 'RRRR'))
            )
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_forma_trib in (1, 2, 3, 4) -- Forma de Tributação do Lucro
      then
      --
      for rec in c_dados loop
         exit when c_dados%notfound or (c_dados%notfound) is null;
         --
         vn_fase := 2;
         --
         pk_csf_api_secf.gt_row_bc_csll_comp_neg := null;
         --
         pk_csf_api_secf.gt_row_bc_csll_comp_neg.percalcapurlr_id   := pk_csf_api_secf.gt_row_per_calc_apur_lr.id;
         pk_csf_api_secf.gt_row_bc_csll_comp_neg.tabdinecf_id   := rec.id;
         --
         if rec.dm_tipo = 'R' then
            pk_csf_api_secf.gt_row_bc_csll_comp_neg.valor        := null;
         else
            pk_csf_api_secf.gt_row_bc_csll_comp_neg.valor        := 0;
         end if;
         --
         pk_csf_api_secf.gt_row_bc_csll_comp_neg.dm_tipo         := 0;
         --
         vn_fase := 3;
         --
         -- Chama API Integra as informações de Base de Cálculo da CSLL Após as Compensações da Base de Cálculo Negativa N650
         pk_csf_api_secf.pkb_integr_bc_csll_comp_neg ( est_log_generico           => gt_log_generico
                                                     , est_row_bc_csll_comp_neg   => pk_csf_api_secf.gt_row_bc_csll_comp_neg
                                                     , en_codentref_id            => rec.codentref_id
                                                     , en_registroecf_id          => rec.registroecf_id
                                                     , ev_tabdinecf_cd            => rec.cd
                                                     );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_monta_bc_csll_comp_neg fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_monta_bc_csll_comp_neg;

-------------------------------------------------------------------------------------------------------

-- Procedimento de montagem de Cálculo do IRPJ Com Base no Lucro Real N630
procedure pkb_monta_calc_irpj_base_lr
is
   --
   vn_fase number;
   --
   cursor c_dados is
   select td.id
        , td.registroecf_id
        , td.cd
        , td.descr
        , td.dt_ini
        , td.dt_fin
        , td.ordem
        , td.dm_tipo
        , td.dm_formato
        , td.formula
        , td.dm_tipo_lanc
        , td.codentref_id
     from tab_din_ecf td
        , registro_ecf r
    where td.codentref_id = pk_csf_api_secf.gt_abertura_ecf.codentref_id
      and r.id = td.registroecf_id
      and r.cod = 'N630'
      and ( to_number(to_char(td.dt_ini, 'RRRR')) <= to_number(to_char(pk_csf_api_secf.gt_abertura_ecf.dt_ini, 'RRRR'))
            and to_number(to_char(nvl(td.dt_fin, sysdate), 'RRRR')) >= to_number(to_char(pk_csf_api_secf.gt_abertura_ecf.dt_ini, 'RRRR'))
            )
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   if (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A00')
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur in ('T01', 'T02', 'T03', 'T04')) --#69540
      then
      --
      for rec in c_dados loop
         exit when c_dados%notfound or (c_dados%notfound) is null;
         --
         vn_fase := 2;
         --
         pk_csf_api_secf.gt_row_calc_irpj_base_lr := null;
         --
         pk_csf_api_secf.gt_row_calc_irpj_base_lr.percalcapurlr_id   := pk_csf_api_secf.gt_row_per_calc_apur_lr.id;
         pk_csf_api_secf.gt_row_calc_irpj_base_lr.tabdinecf_id   := rec.id;
         --
         if rec.dm_tipo = 'R' then
            pk_csf_api_secf.gt_row_calc_irpj_base_lr.valor        := null;
         else
            pk_csf_api_secf.gt_row_calc_irpj_base_lr.valor        := 0;
         end if;
         --
         pk_csf_api_secf.gt_row_calc_irpj_base_lr.dm_tipo         := 0;
         --
         vn_fase := 3;
         --
         -- Chama API Integra as informações de Cálculo do IRPJ Com Base no Lucro Real N630
         pk_csf_api_secf.pkb_integr_calc_irpj_base_lr ( est_log_generico            => gt_log_generico
                                                      , est_row_calc_irpj_base_lr   => pk_csf_api_secf.gt_row_calc_irpj_base_lr
                                                      , en_codentref_id             => rec.codentref_id
                                                      , en_registroecf_id           => rec.registroecf_id
                                                      , ev_tabdinecf_cd             => rec.cd
                                                      );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_monta_calc_irpj_base_lr fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_monta_calc_irpj_base_lr;

-------------------------------------------------------------------------------------------------------

-- Procedimento de montagem de Cálculo do IRPJ Mensal por Estimativa N620
procedure pkb_monta_calc_irpj_mes_estim
is
   --
   vn_fase number;
   --
   cursor c_dados is
   select td.id
        , td.registroecf_id
        , td.cd
        , td.descr
        , td.dt_ini
        , td.dt_fin
        , td.ordem
        , td.dm_tipo
        , td.dm_formato
        , td.formula
        , td.dm_tipo_lanc
        , td.codentref_id
     from tab_din_ecf td
        , registro_ecf r
    where r.id = td.registroecf_id
      and r.cod = 'N620'
      and ( to_number(to_char(td.dt_ini, 'RRRR')) <= to_number(to_char(pk_csf_api_secf.gt_abertura_ecf.dt_ini, 'RRRR'))
            and to_number(to_char(nvl(td.dt_fin, sysdate), 'RRRR')) >= to_number(to_char(pk_csf_api_secf.gt_abertura_ecf.dt_ini, 'RRRR'))
            )
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   if (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A01' )
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A02' )
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A03' )
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A04' )
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A05' )
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A06' )
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A07' )
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A08' )
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A09' )
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A10' )
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A11' )
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A12' )
      then
      --
      for rec in c_dados loop
         exit when c_dados%notfound or (c_dados%notfound) is null;
         --
         vn_fase := 2;
         --
         pk_csf_api_secf.gt_row_calc_irpj_mes_estim := null;
         --
         pk_csf_api_secf.gt_row_calc_irpj_mes_estim.percalcapurlr_id   := pk_csf_api_secf.gt_row_per_calc_apur_lr.id;
         pk_csf_api_secf.gt_row_calc_irpj_mes_estim.tabdinecf_id   := rec.id;
         --
         if rec.dm_tipo = 'R' then
            pk_csf_api_secf.gt_row_calc_irpj_mes_estim.valor        := null;
         else
            pk_csf_api_secf.gt_row_calc_irpj_mes_estim.valor        := 0;
         end if;
         --
         pk_csf_api_secf.gt_row_calc_irpj_mes_estim.dm_tipo         := 0;
         --
         vn_fase := 3;
         --
         -- Chama API Integra as informações de Cálculo do IRPJ Mensal por Estimativa N620
         pk_csf_api_secf.pkb_integr_calc_irpj_mes_estim ( est_log_generico              => gt_log_generico
                                                        , est_row_calc_irpj_mes_estim   => pk_csf_api_secf.gt_row_calc_irpj_mes_estim
                                                        , en_codentref_id               => rec.codentref_id
                                                        , en_registroecf_id             => rec.registroecf_id
                                                        , ev_tabdinecf_cd               => rec.cd
                                                        );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_monta_calc_irpj_mes_estim fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_monta_calc_irpj_mes_estim;

-------------------------------------------------------------------------------------------------------

-- Procedimento de montagem de Informações da Base de Cálclulo dos Incentivos Fiscais N615
procedure pkb_monta_inf_bc_inc_fiscal
is
   --
   vn_fase number;
   --
   --
begin
   --
   vn_fase := 1;
   -- FINOR/FINAM/FUNRES = Sim e não é (A01..A12 e “Receita Bruta”)?
   if pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_fin = 'S'
      and
      ( (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A00')
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur in ('T01', 'T02', 'T03', 'T04')) --#69540
         or ( (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A01' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red1 = 'B')
              or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A02' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red2 = 'B')
              or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A03' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red3 = 'B')
              or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A04' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red4 = 'B')
              or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A05' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red5 = 'B')
              or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A06' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red6 = 'B')
              or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A07' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red7 = 'B')
              or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A08' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red8 = 'B')
              or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A09' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red9 = 'B')
              or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A10' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red10 = 'B')
              or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A11' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red11 = 'B')
              or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A12' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red12 = 'B')
             )
       )
      then
      --
      vn_fase := 1.1;
      --
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_monta_inf_bc_inc_fiscal fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_monta_inf_bc_inc_fiscal;

-------------------------------------------------------------------------------------------------------

-- Procedimento de montagem de Cálculo da Isenção e Redução do Imposto Sobre o Lucro Real N610
procedure pkb_monta_calc_isen_red_imp_lr
is
   --
   vn_fase number;
   --
   cursor c_dados is
   select td.id
        , td.registroecf_id
        , td.cd
        , td.descr
        , td.dt_ini
        , td.dt_fin
        , td.ordem
        , td.dm_tipo
        , td.dm_formato
        , td.formula
        , td.dm_tipo_lanc
        , td.codentref_id
     from tab_din_ecf td
        , registro_ecf r
    where r.id = td.registroecf_id
      and r.cod = 'N610'
      and ( to_number(to_char(td.dt_ini, 'RRRR')) <= to_number(to_char(pk_csf_api_secf.gt_abertura_ecf.dt_ini, 'RRRR'))
            and to_number(to_char(nvl(td.dt_fin, sysdate), 'RRRR')) >= to_number(to_char(pk_csf_api_secf.gt_abertura_ecf.dt_ini, 'RRRR'))
            )
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   -- (Período A01..A12 e “Receita Bruta”) e Lucro da Exploração = SIM?
   if ( (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A01' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red1 = 'E')
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A02' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red2 = 'E')
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A03' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red3 = 'E')
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A04' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red4 = 'E')
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A05' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red5 = 'E')
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A06' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red6 = 'E')
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A07' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red7 = 'E')
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A08' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red8 = 'E')
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A09' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red9 = 'E')
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A10' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red10 = 'E')
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A11' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red11 = 'E')
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A12' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red12 = 'E')
      ) and pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_luc_exp = 'S'
      then
      --
      for rec in c_dados loop
         exit when c_dados%notfound or (c_dados%notfound) is null;
         --
         vn_fase := 2;
         --
         pk_csf_api_secf.gt_row_calc_isen_red_imp_lr := null;
         --
         pk_csf_api_secf.gt_row_calc_isen_red_imp_lr.percalcapurlr_id   := pk_csf_api_secf.gt_row_per_calc_apur_lr.id;
         pk_csf_api_secf.gt_row_calc_isen_red_imp_lr.tabdinecf_id   := rec.id;
         --
         if rec.dm_tipo = 'R' then
            pk_csf_api_secf.gt_row_calc_isen_red_imp_lr.valor        := null;
         else
            pk_csf_api_secf.gt_row_calc_isen_red_imp_lr.valor        := 0;
         end if;
         --
         pk_csf_api_secf.gt_row_calc_isen_red_imp_lr.dm_tipo         := 0;
         --
         vn_fase := 3;
         --
         -- Chama API Integra as informações de Cálculo da Isenção e Redução do Imposto Sobre o Lucro Real N610
         pk_csf_api_secf.pkb_integr_calc_isen_red_implr ( est_log_generico               => gt_log_generico
                                                        , est_row_calc_isen_red_imp_lr   => pk_csf_api_secf.gt_row_calc_isen_red_imp_lr
                                                        , en_codentref_id                => rec.codentref_id
                                                        , en_registroecf_id              => rec.registroecf_id
                                                        , ev_tabdinecf_cd                => rec.cd
                                                        );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_monta_calc_isen_red_imp_lr fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_monta_calc_isen_red_imp_lr;

-------------------------------------------------------------------------------------------------------

-- Procedimento de montagem de Demonstração do Lucro da Exploração N600
procedure pkb_monta_dem_lucro_expl
is
   --
   vn_fase number;
   --
   cursor c_dados is
   select td.id
        , td.registroecf_id
        , td.cd
        , td.descr
        , td.dt_ini
        , td.dt_fin
        , td.ordem
        , td.dm_tipo
        , td.dm_formato
        , td.formula
        , td.dm_tipo_lanc
        , td.codentref_id
     from tab_din_ecf td
        , registro_ecf r
    where r.id = td.registroecf_id
      and r.cod = 'N600'
      and ( to_number(to_char(td.dt_ini, 'RRRR')) <= to_number(to_char(pk_csf_api_secf.gt_abertura_ecf.dt_ini, 'RRRR'))
            and to_number(to_char(nvl(td.dt_fin, sysdate), 'RRRR')) >= to_number(to_char(pk_csf_api_secf.gt_abertura_ecf.dt_ini, 'RRRR'))
            )
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   -- (Período é A00 ou “T1..T4” ou (A01..A12 e “Balanço ou Balancete”)) e Lucro da Exploração = SIM?
   if ( (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A00')
         or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur in ('T01', 'T02', 'T03', 'T04')) --#69540
         or ( (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A01' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red1 = 'B')
              or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A02' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red2 = 'B')
              or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A03' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red3 = 'B')
              or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A04' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red4 = 'B')
              or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A05' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red5 = 'B')
              or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A06' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red6 = 'B')
              or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A07' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red7 = 'B')
              or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A08' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red8 = 'B')
              or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A09' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red9 = 'B')
              or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A10' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red10 = 'B')
              or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A11' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red11 = 'B')
              or (pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur = 'A12' and pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red12 = 'B')
             )
       ) and pk_csf_api_secf.gt_abert_ecf_param_compl.dm_ind_luc_exp = 'S'
      then
      --
      for rec in c_dados loop
         exit when c_dados%notfound or (c_dados%notfound) is null;
         --
         vn_fase := 2;
         --
         pk_csf_api_secf.gt_row_dem_lucro_expl := null;
         --
         pk_csf_api_secf.gt_row_dem_lucro_expl.percalcapurlr_id   := pk_csf_api_secf.gt_row_per_calc_apur_lr.id;
         pk_csf_api_secf.gt_row_dem_lucro_expl.tabdinecf_id   := rec.id;
         --
         if rec.dm_tipo = 'R' then
            pk_csf_api_secf.gt_row_dem_lucro_expl.valor        := null;
         else
            pk_csf_api_secf.gt_row_dem_lucro_expl.valor        := 0;
         end if;
         --
         pk_csf_api_secf.gt_row_dem_lucro_expl.dm_tipo         := 0;
         --
         vn_fase := 3;
         --
         -- Chama API Integra as informações de Demonstração do Lucro da Exploração N600
         pk_csf_api_secf.pkb_integr_dem_lucro_expl ( est_log_generico         => gt_log_generico
                                                   , est_row_dem_lucro_expl   => pk_csf_api_secf.gt_row_dem_lucro_expl
                                                   , en_codentref_id          => rec.codentref_id
                                                   , en_registroecf_id        => rec.registroecf_id
                                                   , ev_tabdinecf_cd          => rec.cd
                                                   );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_monta_dem_lucro_expl fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_monta_dem_lucro_expl;

-------------------------------------------------------------------------------------------------------

-- Procedimento de montagem de Base de Cálculo do IRPJ Sobre o Lucro Real Após as Compensações de Prejuízos N500
procedure pkb_monta_bc_irpj_lr_comp_prej
is
   --
   vn_fase number;
   --
   cursor c_dados is
   select td.id
        , td.registroecf_id
        , td.cd
        , td.descr
        , td.dt_ini
        , td.dt_fin
        , td.ordem
        , td.dm_tipo
        , td.dm_formato
        , td.formula
        , td.dm_tipo_lanc
        , td.codentref_id
     from tab_din_ecf td
        , registro_ecf r
    where r.id = td.registroecf_id
      and r.cod = 'N500'
      and ( to_number(to_char(td.dt_ini, 'RRRR')) <= to_number(to_char(pk_csf_api_secf.gt_abertura_ecf.dt_ini, 'RRRR'))
            and to_number(to_char(nvl(td.dt_fin, sysdate), 'RRRR')) >= to_number(to_char(pk_csf_api_secf.gt_abertura_ecf.dt_ini, 'RRRR'))
            )
    order by td.ordem, td.cd;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_forma_trib in (1, 2, 3, 4) -- Forma de Tributação do Lucro
      then
      --
      for rec in c_dados loop
         exit when c_dados%notfound or (c_dados%notfound) is null;
         --
         vn_fase := 2;
         --
         pk_csf_api_secf.gt_row_bc_irpj_lr_comp_prej := null;
         --
         pk_csf_api_secf.gt_row_bc_irpj_lr_comp_prej.percalcapurlr_id   := pk_csf_api_secf.gt_row_per_calc_apur_lr.id;
         pk_csf_api_secf.gt_row_bc_irpj_lr_comp_prej.tabdinecf_id   := rec.id;
         --
         if rec.dm_tipo = 'R' then
            pk_csf_api_secf.gt_row_bc_irpj_lr_comp_prej.valor        := null;
         else
            pk_csf_api_secf.gt_row_bc_irpj_lr_comp_prej.valor        := 0;
         end if;
         --
         pk_csf_api_secf.gt_row_bc_irpj_lr_comp_prej.dm_tipo         := 0;
         --
         vn_fase := 3;
         --
         -- Chama API Integra as informações de Base de Cálculo do IRPJ Sobre o Lucro Real Após as Compensações de Prejuízos N500
         pk_csf_api_secf.pkb_integr_bc_irpj_lr_compprej ( est_log_generico               => gt_log_generico
                                                        , est_row_bc_irpj_lr_comp_prej   => pk_csf_api_secf.gt_row_bc_irpj_lr_comp_prej
                                                        , en_codentref_id                => rec.codentref_id
                                                        , en_registroecf_id              => rec.registroecf_id
                                                        , ev_tabdinecf_cd                => rec.cd
                                                        );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_monta_bc_irpj_lr_comp_prej fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_monta_bc_irpj_lr_comp_prej;

-------------------------------------------------------------------------------------------------------

-- Procedimento de gerar o Periodo de Cálculo da Apuração do Lucro Real
procedure pkb_gerar_per_calc_apur_lr ( ed_dt_ini       in per_calc_apur_lr.dt_ini%type
                                     , ed_dt_fin       in per_calc_apur_lr.dt_fin%type
                                     , ev_dm_per_apur  in per_calc_apur_lr.dm_per_apur%type
                                     )
is
   --
   vn_fase number;
   --
   vn_dm_situacao per_calc_apur_lr.dm_situacao%type;
   --
begin
   --
   vn_fase := 1;
   --
   gt_log_generico.delete;
   --
   pk_csf_api_secf.gt_row_per_calc_apur_lr := null;
   --
   pk_csf_api_secf.gt_row_per_calc_apur_lr.aberturaecf_id     := pk_csf_api_secf.gt_abertura_ecf.id;
   pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_ini             := ed_dt_ini;
   pk_csf_api_secf.gt_row_per_calc_apur_lr.dt_fin             := ed_dt_fin;
   pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_per_apur        := ev_dm_per_apur;
   pk_csf_api_secf.gt_row_per_calc_apur_lr.dm_situacao        := 0;
   --
   vn_fase := 2;
   -- Chama API que Integra as informações do Periodo de Cálculo da Apuracao do Lucro Real N030
   pk_csf_api_secf.pkb_integr_per_calc_apur_lr ( est_log_generico          => gt_log_generico
                                               , est_row_per_calc_apur_lr  => pk_csf_api_secf.gt_row_per_calc_apur_lr
                                               );
   --
   vn_fase := 2.1;
   --
   -- Procedimento seta o objeto de referencia utilizado na Validação da Informação
   pk_csf_api_secf.pkb_seta_obj_ref ( ev_objeto => 'PER_CALC_APUR_LR' );
   --
   -- Procedimento seta o "ID de Referencia" utilizado na Validação da Informação
   pk_csf_api_secf.pkb_seta_referencia_id ( en_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.id );
   --
   vn_fase := 2.2;
   -- Chama procedimento que excluir os registros filhos
   pk_csf_api_secf.pkb_excluir_calc_apur_lr ( en_percalcapurlr_id => pk_csf_api_secf.gt_row_per_calc_apur_lr.id );
   --
   vn_fase := 3;
   --
   -- Chama Procedimento de montagem de Base de Cálculo do IRPJ Sobre o Lucro Real Após as Compensações de Prejuízos N500
   pkb_monta_bc_irpj_lr_comp_prej;
   --
   vn_fase := 3.1;
   --
   -- Chama Procedimento de montagem de emonstração do Lucro da Exploração N600
   pkb_monta_dem_lucro_expl;
   --
   vn_fase := 3.2;
   --
   -- Chama Procedimento de montagem de Cálculo da Isenção e Redução do Imposto Sobre o Lucro Real N610
   pkb_monta_calc_isen_red_imp_lr;
   --
   vn_fase := 3.3;
   --
   -- Chama Procedimento de montagem de Informações da Base de Cálclulo dos Incentivos Fiscais N615
   pkb_monta_inf_bc_inc_fiscal;
   --
   vn_fase := 3.4;
   --
   -- Chama Procedimento de montagem de Cálculo do IRPJ Mensal por Estimativa N620
   pkb_monta_calc_irpj_mes_estim;
   --
   vn_fase := 3.5;
   --
   -- Chama Procedimento de montagem de Cálculo do IRPJ Com Base no Lucro Real N630
   pkb_monta_calc_irpj_base_lr;
   --
   vn_fase := 3.6;
   --
   -- Chama Procedimento de montagem de Base de Cálculo da CSLL Após as Compensações da Base de Cálculo Negativa N650
   pkb_monta_bc_csll_comp_neg;
   --
   vn_fase := 3.7;
   --
   -- Chama Procedimento de montagem de Cálculo da CSLL Mensal por Estimativa N660
   pkb_monta_calc_csll_mes_estim;
   --
   vn_fase := 3.8;
   --
   -- Chama Procedimento de montagem de Cálculo da CSLL Com Base no Lucro Real N670
   pkb_monta_calc_csll_base_lr;
   --
   vn_fase := 4;
   --
   -- Chama Procedimento para gerar os valores de Base de Cálculo do IRPJ Sobre o Lucro Real Após as Compensações de Prejuízos
   pkb_gerar_vlr_birlrcp;
   --
   vn_fase := 4.1;
   -- Chama Procedimento para gerar os valores de Demonstração do Lucro da Exploração
   pkb_gerar_vlr_dle;
   --
   vn_fase := 4.2;
   --
   -- Chama Procedimento para gerar os valores de Cálculo da Isenção e Redução do Imposto Sobre o Lucro Real
   pkb_gerar_vlr_cirilr;
   --
   vn_fase := 4.3;
   --
   --
   vn_fase := 4.4;
   -- Chama Procedimento para gerar os valores de Cálculo do IRPJ Mensal por Estimativa
   pkb_gerar_vlr_cirpjme;
   --
   vn_fase := 4.5;
   --
   -- Chama Procedimento para gerar os valores de Cálculo do IRPJ Com Base no Lucro Real
   pkb_gerar_vlr_cirpjblr;
   --
   vn_fase := 4.6;
   --
   -- Chama Procedimento para gerar os valores de Base de Cálculo da CSLL Após as Compensações da Base de Cálculo Negativa
   pkb_gerar_vlr_bccsllcp;
   --
   vn_fase := 4.7;
   --
   -- Chama Procedimento para gerar os valores de Cálculo da CSLL Mensal por Estimativa
   pkb_gerar_vlr_ccsllme;
   --
   vn_fase := 4.8;
   -- Chama Procedimento para gerar os valores de Cálculo da CSLL Com Base no Lucro Real
   pkb_gerar_vlr_ccsllblr;
   --
   vn_fase := 99;
   --
   -- Chama procedimento para atribuir a Situação do Periodo de Cálculo da Apuração do Lucro Real
   pkb_seta_situacao ( ev_evento => 'CALCULAR' );
   --
   commit;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_gerar_per_calc_apur_lr fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_gerar_per_calc_apur_lr;

-------------------------------------------------------------------------------------------------------

-- Procedimento para gerar os períodos
procedure pkb_gerar_periodos
is
   --
   vn_fase number;
   vn_loggenerico_id  log_generico.id%type;
   vv_dm_per_apur     per_calc_apur_lr.dm_per_apur%type;
   vn_mes_adicional   number;
   --
   vd_dt_ref          date;
   vd_dt_ini          date;
   --
begin
   --
   vn_fase := 1;
   --
   vd_dt_ref := pk_csf_api_secf.gt_abertura_ecf.dt_ini;
   --
   -- Período de Apuração [para 0010.FORMA_APUR = “A” ou (0010.FORMA_APUR_I = “A” OU 0010.APUR_CSLL = “A” )]
   if ( pk_csf_api_secf.gt_abert_ecf_param_trib.dm_forma_apur = 'A' )
      or ( pk_csf_api_secf.gt_abert_ecf_param_trib.dm_forma_apur_i = 'A' )
      or ( pk_csf_api_secf.gt_abert_ecf_param_trib.dm_apur_csll = 'A' )
      then
      --
      vn_fase := 2;
      -- Chama procedimento para criação do período Anual
      pkb_gerar_per_calc_apur_lr ( ed_dt_ini       => pk_csf_api_secf.gt_abertura_ecf.dt_ini
                                 , ed_dt_fin       => pk_csf_api_secf.gt_abertura_ecf.dt_fin
                                 , ev_dm_per_apur  => 'A00'
                                 );
      --
      vn_fase := 2.1;
      --
      while vd_dt_ref < pk_csf_api_secf.gt_abertura_ecf.dt_fin loop
         --
         vn_fase := 2.2;
         --
         vv_dm_per_apur := null;
         -- Balanço ou Balancete/Receita Bruta
         if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red1 in ('B', 'E')
            and to_char(last_day(vd_dt_ref), 'MM') = '01'
            then -- Janeiro
            --
            vv_dm_per_apur := 'A01';
            --
            if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red1 = 'B' then
               vd_dt_ini := pk_csf_api_secf.gt_abertura_ecf.dt_ini;
            else
               vd_dt_ini := vd_dt_ref;
            end if;
            --
         elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red2 in ('B', 'E')
            and to_char(last_day(vd_dt_ref), 'MM') = '02'
            then -- Fevereiro
            --
            vv_dm_per_apur := 'A02';
            --
            if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red2 = 'B' then
               vd_dt_ini := pk_csf_api_secf.gt_abertura_ecf.dt_ini;
            else
               vd_dt_ini := vd_dt_ref;
            end if;
            --
         elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red3 in ('B', 'E')
            and to_char(last_day(vd_dt_ref), 'MM') = '03'
            then -- Março
            --
            vv_dm_per_apur := 'A03';
            --
            if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red3 = 'B' then
               vd_dt_ini := pk_csf_api_secf.gt_abertura_ecf.dt_ini;
            else
               vd_dt_ini := vd_dt_ref;
            end if;
            --
         elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red4 in ('B', 'E')
            and to_char(last_day(vd_dt_ref), 'MM') = '04'
            then -- Abril
            --
            vv_dm_per_apur := 'A04';
            --
            if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red4 = 'B' then
               vd_dt_ini := pk_csf_api_secf.gt_abertura_ecf.dt_ini;
            else
               vd_dt_ini := vd_dt_ref;
            end if;
            --
         elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red5 in ('B', 'E')
            and to_char(last_day(vd_dt_ref), 'MM') = '05'
            then -- Maio
            --
            vv_dm_per_apur := 'A05';
            --
            if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red5 = 'B' then
               vd_dt_ini := pk_csf_api_secf.gt_abertura_ecf.dt_ini;
            else
               vd_dt_ini := vd_dt_ref;
            end if;
            --
         elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red6 in ('B', 'E')
            and to_char(last_day(vd_dt_ref), 'MM') = '06'
            then -- Junho
            --
            vv_dm_per_apur := 'A06';
            --
            if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red6 = 'B' then
               vd_dt_ini := pk_csf_api_secf.gt_abertura_ecf.dt_ini;
            else
               vd_dt_ini := vd_dt_ref;
            end if;
            --
         elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red7 in ('B', 'E')
            and to_char(last_day(vd_dt_ref), 'MM') = '07'
            then -- Julho
            --
            vv_dm_per_apur := 'A07';
            --
            if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red7 = 'B' then
               vd_dt_ini := pk_csf_api_secf.gt_abertura_ecf.dt_ini;
            else
               vd_dt_ini := vd_dt_ref;
            end if;
            --
         elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red8 in ('B', 'E')
            and to_char(last_day(vd_dt_ref), 'MM') = '08'
            then -- Agosto
            --
            vv_dm_per_apur := 'A08';
            --
            if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red8 = 'B' then
               vd_dt_ini := pk_csf_api_secf.gt_abertura_ecf.dt_ini;
            else
               vd_dt_ini := vd_dt_ref;
            end if;
            --
         elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red9 in ('B', 'E')
            and to_char(last_day(vd_dt_ref), 'MM') = '09'
            then -- Setembro
            --
            vv_dm_per_apur := 'A09';
            --
            if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red9 = 'B' then
               vd_dt_ini := pk_csf_api_secf.gt_abertura_ecf.dt_ini;
            else
               vd_dt_ini := vd_dt_ref;
            end if;
            --
         elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red10 in ('B', 'E')
            and to_char(last_day(vd_dt_ref), 'MM') = '10'
            then -- Outubro
            --
            vv_dm_per_apur := 'A10';
            --
            if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red10 = 'B' then
               vd_dt_ini := pk_csf_api_secf.gt_abertura_ecf.dt_ini;
            else
               vd_dt_ini := vd_dt_ref;
            end if;
            --
         elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red11 in ('B', 'E')
            and to_char(last_day(vd_dt_ref), 'MM') = '11'
            then -- Novembro
            --
            vv_dm_per_apur := 'A11';
            --
            if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red11 = 'B' then
               vd_dt_ini := pk_csf_api_secf.gt_abertura_ecf.dt_ini;
            else
               vd_dt_ini := vd_dt_ref;
            end if;
            --
         elsif pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red12 in ('B', 'E')
            and to_char(last_day(vd_dt_ref), 'MM') = '12'
            then -- Dezembro
            --
            vv_dm_per_apur := 'A12';
            --
            if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_mes_bal_red12 = 'B' then
               vd_dt_ini := pk_csf_api_secf.gt_abertura_ecf.dt_ini;
            else
               vd_dt_ini := vd_dt_ref;
            end if;
            --
         end if;
         --
         vn_fase := 2.3;
         --
         if vv_dm_per_apur is not null then
            --
            vn_fase := 2.4;
            -- Chama procedimento para criação do período
            pkb_gerar_per_calc_apur_lr ( ed_dt_ini       => vd_dt_ini
                                       , ed_dt_fin       => last_day(vd_dt_ref)
                                       , ev_dm_per_apur  => vv_dm_per_apur
                                       );
            --
         end if;
         --
         vn_fase := 2.5;
         --
         vd_dt_ref := add_months(vd_dt_ref, 1);
         --
      end loop;
      --
   else
      --
      vn_fase := 3;
      --
      pk_csf_api_secf.gv_mensagem_log := 'Parâmetro de Tributação não atendem a geração de dados Anual do Cálculo da Apuração do Lucro Real.';
      --
      pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                       , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                       , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                       , en_tipo_log        => pk_csf_api_secf.INFORMACAO
                                       , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                       , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                       );
      --
   end if;
   --
   vd_dt_ref := pk_csf_api_secf.gt_abertura_ecf.dt_ini;
   --
   -- Procedimento seta o objeto de referencia utilizado na Validação da Informação
   pk_csf_api_secf.pkb_seta_obj_ref ( ev_objeto => 'ABERTURA_ECF' );
   --
   -- Procedimento seta o "ID de Referencia" utilizado na Validação da Informação
   pk_csf_api_secf.pkb_seta_referencia_id ( en_id => pk_csf_api_secf.gt_abertura_ecf.id );
   --
   if ( pk_csf_api_secf.gt_abert_ecf_param_trib.dm_forma_apur = 'T' )
      or ( ( pk_csf_api_secf.gt_abert_ecf_param_trib.dm_forma_apur_i = 'T' )
            or ( pk_csf_api_secf.gt_abert_ecf_param_trib.dm_apur_csll = 'T' ) )
      then
      --
      -- Indicador do período de referência [para 0010.FORMA_APUR = “T” OU (0010.FORMA_APUR = “A” E 0010.FORMA_TRIB = “2”) ou (0010.FORMA_APUR_I = “T” OU 0010.APUR_CSLL = “T” E 0010.TIP_ESC_PRE = “C”)]:
      --
      vn_fase := 4;
      --
      while vd_dt_ref < pk_csf_api_secf.gt_abertura_ecf.dt_fin loop
         --
         vn_fase := 4.1;
         --
         vn_mes_adicional := 0;
         vv_dm_per_apur := null;
         --
         -- R-Real/E-Real Estimativa
         if to_number(to_char(vd_dt_ref, 'MM')) between 1 and 3
            then -- 1º Trimestre
            --
            vv_dm_per_apur := 'T01';
            --
         elsif to_number(to_char(vd_dt_ref, 'MM')) between 4 and 6
            then -- 2º Trimestre
            --
            vv_dm_per_apur := 'T02';
            --
         elsif to_number(to_char(vd_dt_ref, 'MM')) between 7 and 9
            then -- 3º Trimestre
            --
            vv_dm_per_apur := 'T03';
            --
         elsif to_number(to_char(vd_dt_ref, 'MM')) between 10 and 12
            then -- 4º Trimestre
            --
            vv_dm_per_apur := 'T04';
            --
         end if;
         --
         vn_fase := 4.2;
         --
         if vv_dm_per_apur is not null then
            --
            vn_fase := 4.3;
            --
            --vn_mes_adicional := to_number(to_char( last_day(add_months(vd_dt_ref, 2)), 'rrrrmm' )) - to_number(to_char(vd_dt_ref, 'rrrrmm'));
            if to_number(to_char(vd_dt_ref, 'MM')) in (1, 4, 7, 10)
               then
               vn_mes_adicional := 2;
            elsif to_number(to_char(vd_dt_ref, 'MM')) in (2, 5, 8, 11)
               then
               vn_mes_adicional := 1;
            elsif to_number(to_char(vd_dt_ref, 'MM')) in (3, 6, 9, 12)
               then
               vn_mes_adicional := 0;
            else
               vn_mes_adicional := 0;
            end if;
            --
            vn_fase := 4.4;
            --
            -- Chama procedimento para criação do período
            pkb_gerar_per_calc_apur_lr ( ed_dt_ini       => vd_dt_ref
                                       , ed_dt_fin       => last_day( add_months( vd_dt_ref, nvl(vn_mes_adicional,0) ) )
                                       , ev_dm_per_apur  => vv_dm_per_apur
                                       );
            --
         end if;
         --
         vn_fase := 4.5;
         --
         --vd_dt_ref := add_months(vd_dt_ref, 3);
         if to_number(to_char(vd_dt_ref, 'MM')) in (1, 4, 7)
            then
         vd_dt_ref := add_months(vd_dt_ref, 3);
         elsif to_number(to_char(vd_dt_ref, 'MM')) in (2, 5, 8)
            then 
              vd_dt_ref := add_months(vd_dt_ref, 2);
         elsif to_number(to_char(vd_dt_ref, 'MM')) in (3, 6, 9)
           then
             vd_dt_ref := add_months(vd_dt_ref, 1);
		 else
		   vd_dt_ref := pk_csf_api_secf.gt_abertura_ecf.dt_fin;
         end if; 
         --
      end loop;
      --
   else
      --
      vn_fase := 5;
      --
      pk_csf_api_secf.gv_mensagem_log := 'Parâmetro de Tributação não atendem a geração de dados Trimestral do Cálculo da Apuração do Lucro Real.';
      --
      pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                       , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                       , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                       , en_tipo_log        => pk_csf_api_secf.INFORMACAO
                                       , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                       , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                       );
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_gerar_periodos fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_gerar_periodos;

-------------------------------------------------------------------------------------------------------

-- Procedimento de gerar dados da Apuracao do Lucro Real

procedure pkb_gerar_dados ( en_aberturaecf_id in abertura_ecf.id%type )
is
   --
   vn_fase number;
   --
begin
   --
   vn_fase := 1;
   --
   pk_csf_api_secf.pkb_inicia_param ( en_aberturaecf_id => en_aberturaecf_id );
   --
   if nvl(pk_csf_api_secf.gt_abertura_ecf.id,0) > 0 then
      --
      -- Procedimento seta o objeto de referencia utilizado na Validação da Informação
      pk_csf_api_secf.pkb_seta_obj_ref ( ev_objeto => 'ABERTURA_ECF' );
      --
      -- Procedimento seta o "ID de Referencia" utilizado na Validação da Informação
      pk_csf_api_secf.pkb_seta_referencia_id ( en_id => pk_csf_api_secf.gt_abertura_ecf.id );
      --
      -- Obrigatório se (0010. FORMA_TRIB = “1”, “2”, “3” ou “4”)
      --
      vn_fase := 2;
      --
      if pk_csf_api_secf.gt_abert_ecf_param_trib.dm_forma_trib in (1, 2, 3, 4) -- Forma de Tributação do Lucro
         then
         --
         vn_fase := 3;
         --
         -- Chama procedimento para gerar os períodos
         pkb_gerar_periodos;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_calc_apur_lr.pkb_gerar_dados fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => pk_csf_api_secf.gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
end pkb_gerar_dados;

-------------------------------------------------------------------------------------------------------

end pk_calc_apur_lr;
/
