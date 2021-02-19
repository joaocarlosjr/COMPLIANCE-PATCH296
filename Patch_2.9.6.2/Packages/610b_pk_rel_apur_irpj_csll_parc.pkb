create or replace package body csf_own.pk_rel_apur_irpj_csll_parc is
--
procedure pkg_retorna_M300_ir_real (en_aberturaecf_id in abertura_ecf.id%type,
                                    en_dt_ini        in per_apur_lr.dt_ini%type,
                                    en_dt_fin        in per_apur_lr.dt_fin%type  ) is

 cursor c_m300 is
   select e.cd ,sum(l.valor)  valor
  from lanc_part_a_lalur  l , per_apur_lr p, tab_din_ecf e, registro_ecf r
  where l.perapurlr_id = p.id
  and l.tabdinecf_id   = e.id
  and e.cd             in ('2','93','168','173')
  and e.registroecf_id = r.id
  and p.dt_ini         >=en_dt_ini and p.dt_fin <=en_dt_fin
  and r.cod            = 'M300'
  and p.aberturaecf_id = en_aberturaecf_id
  /*and p.dm_per_apur    = gc_dm_per_apur*/
  and l.dm_tipo        <> 0
  group by e.cd;
  
 cursor c_m300_p is
   select e.cd ,sum(l.valor)  valor
  from lanc_part_a_lalur  l , per_apur_lr p, tab_din_ecf e, registro_ecf r
  where l.perapurlr_id = p.id
  and l.tabdinecf_id   = e.id
  and e.cd             in ('2','93','168','173')
  and e.registroecf_id = r.id
  and p.dt_ini         >=en_dt_ini and p.dt_fin <=en_dt_fin
  and r.cod            = 'M300'
  and p.aberturaecf_id = en_aberturaecf_id
  and p.dm_per_apur    = gc_dm_per_apur
  and l.dm_tipo        <> 0
  group by e.cd;
  
begin
  ------------------
   if gv_parcial = 'N' then
     ----   
     for rec_m300 in c_m300 loop
        exit when c_m300%notfound or (c_m300%notfound) is null;
  /*       
         if rec_m300.cd = '2'   then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_LUCRO_CONT_CS:= rec_m300.valor; --lucro contabil antes da apuração do CS  -  real
         end if;
         if rec_m300.cd = '93'  then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_SOM_ADIC_CS := rec_m300.valor; --soma das adições - CS -  real
         end if;
         if rec_m300.cd = '168' then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_SOM_EXCL_CS := rec_m300.valor; --soma das exclusões - CS -  real
         end if;
         if rec_m300.cd = '173' then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_COMP_PREJ_CS:= rec_m300.valor; --compensação do prejuizo - CS -  real
         end if;*/  
         ---     
         if rec_m300.cd = '2'   then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_LUCRO_CONT_IR:= rec_m300.valor; --lucro contabil antes da apuração do IR -  real
         end if;
         if rec_m300.cd = '93'  then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_SOM_ADIC_IR  := rec_m300.valor; --soma das adições - IR -  real
         end if;
         if rec_m300.cd = '168' then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_SOM_EXCL_IR  := rec_m300.valor; --soma das exclusões - IR -  real
         end if;
         if rec_m300.cd = '173' then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_COMP_PREJ_IR := rec_m300.valor; --compensação do prejuizo - IR -  real
         end if;  
         ---                   
     end loop;
     ----     
   else
     ----
     for rec_m300_p in c_m300_p loop
        exit when c_m300_p%notfound or (c_m300_p%notfound) is null;
         ---     
         if rec_m300_p.cd = '2'   then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_LUCRO_CONT_IR:= rec_m300_p.valor; --lucro contabil antes da apuração do IR -  real
         end if;
         if rec_m300_p.cd = '93'  then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_SOM_ADIC_IR  := rec_m300_p.valor; --soma das adições - IR -  real
         end if;
         if rec_m300_p.cd = '168' then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_SOM_EXCL_IR  := rec_m300_p.valor; --soma das exclusões - IR -  real
         end if;
         if rec_m300_p.cd = '173' then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_COMP_PREJ_IR := rec_m300_p.valor; --compensação do prejuizo - IR -  real
         end if;  
         ---    
     end loop;     
     ----     
   end if;   
  ------------------
exception
   ------------------
   when others then
      raise_application_error(-20101, 'Erro na pkg_retorna_M300_ir_real:' || sqlerrm);
   ------------------
end;
------------------
procedure pkg_retorna_M350_ir_real (en_aberturaecf_id in abertura_ecf.id%type,
                                    en_dt_ini        in per_apur_lr.dt_ini%type,
                                    en_dt_fin        in per_apur_lr.dt_fin%type ) is
 cursor c_m350 is
   select e.cd ,sum(l.valor)  valor
   from lanc_part_a_lacs  l , per_apur_lr p, tab_din_ecf e, registro_ecf r
   where l.perapurlr_id = p.id
   and l.tabdinecf_id   = e.id
   and e.cd             in ('2','93','168','173')
   and p.aberturaecf_id = en_aberturaecf_id
   and p.dt_ini         >=en_dt_ini and p.dt_fin <=en_dt_fin
   and e.registroecf_id = r.id
   and r.cod            ='M350'
   /*and p.dm_per_apur    = gc_dm_per_apur*/
   and l.dm_tipo       <> 0
   group by e.cd;
   
 cursor c_m350_p is
   select e.cd ,sum(l.valor)  valor
   from lanc_part_a_lacs  l , per_apur_lr p, tab_din_ecf e, registro_ecf r
   where l.perapurlr_id = p.id
   and l.tabdinecf_id   = e.id
   and e.cd             in ('2','93','168','173')
   and p.aberturaecf_id = en_aberturaecf_id
   and p.dt_ini         >=en_dt_ini and p.dt_fin <=en_dt_fin
   and e.registroecf_id = r.id
   and r.cod            ='M350'
   and p.dm_per_apur    = gc_dm_per_apur
   and l.dm_tipo       <> 0
   group by e.cd;   
begin
   ------------------
   if gv_parcial = 'N' then
     ----     
     for rec_m350 in c_m350 loop
        exit when c_m350%notfound or (c_m350%notfound) is null;
  /*       
         if rec_m350.cd = '2'   then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_LUCRO_CONT_IR:= rec_m350.valor; --lucro contabil antes da apuração do IR -  real
         end if;
         if rec_m350.cd = '93'  then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_SOM_ADIC_IR  := rec_m350.valor; --soma das adições - IR -  real
         end if;
         if rec_m350.cd = '168' then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_SOM_EXCL_IR  := rec_m350.valor; --soma das exclusões - IR -  real
         end if;
         if rec_m350.cd = '173' then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_COMP_PREJ_IR := rec_m350.valor; --compensação do prejuizo - IR -  real
         end if;*/    
         ---   
         if rec_m350.cd = '2'   then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_LUCRO_CONT_CS:= rec_m350.valor; --lucro contabil antes da apuração do CS  -  real
         end if;
         if rec_m350.cd = '93'  then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_SOM_ADIC_CS := rec_m350.valor; --soma das adições - CS -  real
         end if;
         if rec_m350.cd = '168' then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_SOM_EXCL_CS := rec_m350.valor; --soma das exclusões - CS -  real
         end if;
         if rec_m350.cd = '173' then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_COMP_PREJ_CS:= rec_m350.valor; --compensação do prejuizo - CS -  real
         end if;      
         --- 
     end loop;
     ----      
   else
     ----      
     for rec_m350_p in c_m350_p loop
        exit when c_m350_p%notfound or (c_m350_p%notfound) is null;
       ---   
       if rec_m350_p.cd = '2'   then
         vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_LUCRO_CONT_CS:= rec_m350_p.valor; --lucro contabil antes da apuração do CS  -  real
       end if;
       if rec_m350_p.cd = '93'  then
         vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_SOM_ADIC_CS := rec_m350_p.valor; --soma das adições - CS -  real
       end if;
       if rec_m350_p.cd = '168' then
         vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_SOM_EXCL_CS := rec_m350_p.valor; --soma das exclusões - CS -  real
       end if;
       if rec_m350_p.cd = '173' then
         vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_COMP_PREJ_CS:= rec_m350_p.valor; --compensação do prejuizo - CS -  real
       end if;      
       --- 
     end loop;   
     ----      
   end if;
   ------------------
exception
   when others then
      raise_application_error(-20101, 'Erro na pkg_retorna_M350_ir_real:' || sqlerrm);
------------------
end;
------------------
procedure pkg_retorna_N630_cs_real (en_aberturaecf_id in abertura_ecf.id%type,
                                    en_dt_ini        in per_apur_lr.dt_ini%type,
                                    en_dt_fin        in per_apur_lr.dt_fin%type )  is
 cursor c_n630 is
   select e.cd ,sum(l.valor)  valor
   from calc_irpj_base_lr l, per_calc_apur_lr p, tab_din_ecf e, registro_ecf r
   where l.percalcapurlr_id  = p.id
   and l.tabdinecf_id        = e.id
   and e.cd                  in ('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','26')
   and e.registroecf_id      = r.id
   and r.cod                 ='N630'
   and p.aberturaecf_id      = en_aberturaecf_id
   and p.dt_ini              >=en_dt_ini and p.dt_fin <=en_dt_fin
   /*and p.dm_per_apur         = gc_dm_per_apur*/
   and l.dm_tipo             <> 0
   group by e.cd;
   
 cursor c_n630_p is
   select e.cd ,sum(l.valor)  valor
   from calc_irpj_base_lr l, per_calc_apur_lr p, tab_din_ecf e, registro_ecf r
   where l.percalcapurlr_id  = p.id
   and l.tabdinecf_id        = e.id
   and e.cd                  in ('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','26')
   and e.registroecf_id      = r.id
   and r.cod                 ='N630'
   and p.aberturaecf_id      = en_aberturaecf_id
   and p.dt_ini              >=en_dt_ini and p.dt_fin <=en_dt_fin
   and p.dm_per_apur         = gc_dm_per_apur
   and l.dm_tipo             <> 0
   group by e.cd; 
     
begin
   ------------------
   if gv_parcial = 'N' then
     ----    
     for rec_n630 in c_n630 loop
        exit when c_n630%notfound or (c_n630%notfound) is null;
          if rec_n630.cd = '1'   then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_BC_IR          := rec_n630.valor; --base de cálculo do Imposto de Renda -  real
          end if;
          if rec_n630.cd = '2'   then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IR_DEVIDO      := rec_n630.valor; --Imposto de Renda Devida
          end if;
          if rec_n630.cd = '3'   then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IR_SUJEITO     := rec_n630.valor; --Imposto de IR sujeito -  real
          end if;
          if rec_n630.cd = '4'   then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_ADIC_IR        := rec_n630.valor; --Adicional de IR -  real
          end if;
          if rec_n630.cd = '5'   then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_DEDUCOES_IRPJ  := rec_n630.valor; --Deduções IRPJ -  real
          end if;
          if rec_n630.cd in ('20','21','22')   then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRRF_RET_S_NFSE:= nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRRF_RET_S_NFSE,0) + rec_n630.valor;  --IRRF retido sem NFS-e -  real
          end if;
          if rec_n630.cd in ('19','23')   then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRRF_RET_S_APF := nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRRF_RET_S_APF,0) + rec_n630.valor; --IRRF retido sem Aplic Financeiras -  real
          end if;
          if rec_n630.cd = '24'   then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRPJ_REC_ESTIM := rec_n630.valor;  --IR recolhido por estimativa -  real
          end if;
          if rec_n630.cd in ('6','7','8','9','10','11','12','13','14','15','16','17','18')   then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRRF_OUTRAS_DED:= nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRRF_OUTRAS_DED,0) + rec_n630.valor;  --outras deduções IRPJ -  real
          end if;
          if rec_n630.cd = '26'   then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRPJ_RECOLHER  := rec_n630.valor;  --IRPJ a recolher -  real
          end if;
     end loop;
     ----      
   else
     ---- 
     for rec_n630_p in c_n630_p loop
        exit when c_n630_p%notfound or (c_n630_p%notfound) is null;
          if rec_n630_p.cd = '1'   then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_BC_IR          := rec_n630_p.valor; --base de cálculo do Imposto de Renda -  real
          end if;
          if rec_n630_p.cd = '2'   then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IR_DEVIDO      := rec_n630_p.valor; --Imposto de Renda Devida
          end if;
          if rec_n630_p.cd = '3'   then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IR_SUJEITO     := rec_n630_p.valor; --Imposto de IR sujeito -  real
          end if;
          if rec_n630_p.cd = '4'   then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_ADIC_IR        := rec_n630_p.valor; --Adicional de IR -  real
          end if;
          if rec_n630_p.cd = '5'   then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_DEDUCOES_IRPJ  := rec_n630_p.valor; --Deduções IRPJ -  real
          end if;
          if rec_n630_p.cd in ('20','21','22')   then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRRF_RET_S_NFSE:= nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRRF_RET_S_NFSE,0) + rec_n630_p.valor;  --IRRF retido sem NFS-e -  real
          end if;
          if rec_n630_p.cd in ('19','23')   then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRRF_RET_S_APF := nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRRF_RET_S_APF,0) + rec_n630_p.valor; --IRRF retido sem Aplic Financeiras -  real
          end if;
          if rec_n630_p.cd = '24'   then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRPJ_REC_ESTIM := rec_n630_p.valor;  --IR recolhido por estimativa -  real
          end if;
          if rec_n630_p.cd in ('6','7','8','9','10','11','12','13','14','15','16','17','18')   then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRRF_OUTRAS_DED:= nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRRF_OUTRAS_DED,0) + rec_n630_p.valor;  --outras deduções IRPJ -  real
          end if;
          if rec_n630_p.cd = '26'   then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRPJ_RECOLHER  := rec_n630_p.valor;  --IRPJ a recolher -  real
          end if;
     end loop;     
     ----      
   end if;        
   ------------------
exception
   when others then
      raise_application_error(-20101, 'Erro na pkg_retorna_N630_ir_real:' || sqlerrm);
   ------------------
end;
------------------
procedure pkg_retorna_N650_cs_real (en_aberturaecf_id in abertura_ecf.id%type,
                                    en_dt_ini        in per_apur_lr.dt_ini%type,
                                    en_dt_fin        in per_apur_lr.dt_fin%type  ) is
cursor c_n650 is
  select e.cd ,sum(l.valor)  valor
  from bc_csll_comp_neg l, per_calc_apur_lr p, tab_din_ecf e, registro_ecf r
  where l.percalcapurlr_id  = p.id
  and l.tabdinecf_id   = e.id
  and e.cd             = '1'
  and e.registroecf_id = r.id
  and r.cod            = 'N650'
  and p.aberturaecf_id = en_aberturaecf_id
  and p.dt_ini         >=en_dt_ini and p.dt_fin <=en_dt_fin
  /*and p.dm_per_apur    = gc_dm_per_apur*/
  and l.dm_tipo        <> 0
  group by e.cd;
  
cursor c_n650_p is
  select e.cd ,sum(l.valor)  valor
  from bc_csll_comp_neg l, per_calc_apur_lr p, tab_din_ecf e, registro_ecf r
  where l.percalcapurlr_id  = p.id
  and l.tabdinecf_id   = e.id
  and e.cd             = '1'
  and e.registroecf_id = r.id
  and r.cod            = 'N650'
  and p.aberturaecf_id = en_aberturaecf_id
  and p.dt_ini         >=en_dt_ini and p.dt_fin <=en_dt_fin
  and p.dm_per_apur    = gc_dm_per_apur
  and l.dm_tipo        <> 0
  group by e.cd;
    
begin
   ------------------
   if gv_parcial = 'N' then
     ----   
     for rec_n650 in c_n650 loop
        exit when c_n650%notfound or (c_n650%notfound) is null;
        if rec_n650.cd='1' then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_BC_CS:= rec_n650.valor;-- base de cálculo da Contribuição Social -  real
        end if;
     end loop;
     ----      
   else
     ---- 
     for rec_n650_p in c_n650_p loop
        exit when c_n650_p%notfound or (c_n650_p%notfound) is null;
        if rec_n650_p.cd='1' then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_BC_CS:= rec_n650_p.valor;-- base de cálculo da Contribuição Social -  real
        end if;
     end loop;     
     ----      
   end if;     
   ------------------
exception
   when others then
      raise_application_error(-20101, 'Erro na pkg_retorna_N650_cs_real:' || sqlerrm);
   ------------------
end;
------------------
procedure pkg_retorna_N660_cs_real (en_aberturaecf_id in abertura_ecf.id%type,
                                    en_dt_ini        in per_apur_lr.dt_ini%type,
                                    en_dt_fin        in per_apur_lr.dt_fin%type  ) is

cursor c_n660 is
  select e.cd ,sum(l.valor)  valor
  from calc_csll_mes_estim l, per_calc_apur_lr p, tab_din_ecf e, registro_ecf r
  where l.percalcapurlr_id  = p.id
  and l.tabdinecf_id        = e.id
  and e.cd                  in ('1','3','4','12','12.01','14','15','16','17','17.01','17.02','18')
  and e.registroecf_id      = r.id
  and r.cod                 ='N660'
  and p.aberturaecf_id      = en_aberturaecf_id
  and p.dt_ini              >=en_dt_ini and p.dt_fin <=en_dt_fin
  /*and p.dm_per_apur         = gc_dm_per_apur*/
  and l.dm_tipo             <> 0
  group by e.cd;
  
cursor c_n660_p is
  select e.cd ,sum(l.valor)  valor
  from calc_csll_mes_estim l, per_calc_apur_lr p, tab_din_ecf e, registro_ecf r
  where l.percalcapurlr_id  = p.id
  and l.tabdinecf_id        = e.id
  and e.cd                  in ('1','3','4','12','12.01','14','15','16','17','17.01','17.02','18')
  and e.registroecf_id      = r.id
  and r.cod                 ='N660'
  and p.aberturaecf_id      = en_aberturaecf_id
  and p.dt_ini              >=en_dt_ini and p.dt_fin <=en_dt_fin
  and p.dm_per_apur         = gc_dm_per_apur
  and l.dm_tipo             <> 0
  group by e.cd;  
begin
   ------------------
   if gv_parcial = 'N' then
     ----      
     for rec_n660 in c_n660 loop
        exit when c_n660%notfound or (c_n660%notfound) is null;
        if rec_n660.cd='3' then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CS_DEVIDA       := rec_n660.valor;-- Contribuição Social Devida
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CS_SUJEITO      := rec_n660.valor;--Imposto de CS sujeito -  real
        end if;
        if rec_n660.cd='4' then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_DEDUCOES_CSLL   := rec_n660.valor;--Deduções CSLL -  real
        end if;
        if rec_n660.cd in ('14','15','16','17') then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CSLL_RET_S_NFSE := nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CSLL_RET_S_NFSE,0) + rec_n660.valor;--CSLL retido sem NFS-e -  real
        end if;
        if rec_n660.cd in ('12','12.01') then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CS_REC_ESTIM   := nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CS_REC_ESTIM,0) +rec_n660.valor;--CS recolhido por estimativa -  real
        end if;
        if rec_n660.cd in ('17.01','17.02') then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CSLL_OUTRAS_DED:= nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CSLL_OUTRAS_DED,0) + rec_n660.valor;--outras deduções CSLL -  real
        end if;
        if rec_n660.cd ='18' then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CSLL_RECOLHER   := rec_n660.valor;--CSLL a recolher -  real
        end if;
     end loop;      
     ----      
   else
     ---- 
     for rec_n660_p in c_n660_p loop
        exit when c_n660_p%notfound or (c_n660_p%notfound) is null;
        if rec_n660_p.cd='3' then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CS_DEVIDA       := rec_n660_p.valor;-- Contribuição Social Devida
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CS_SUJEITO      := rec_n660_p.valor;--Imposto de CS sujeito -  real
        end if;
        if rec_n660_p.cd='4' then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_DEDUCOES_CSLL   := rec_n660_p.valor;--Deduções CSLL -  real
        end if;
        if rec_n660_p.cd in ('14','15','16','17') then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CSLL_RET_S_NFSE := nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CSLL_RET_S_NFSE,0) + rec_n660_p.valor;--CSLL retido sem NFS-e -  real
        end if;
        if rec_n660_p.cd in ('12','12.01') then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CS_REC_ESTIM   := nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CS_REC_ESTIM,0) +rec_n660_p.valor;--CS recolhido por estimativa -  real
        end if;
        if rec_n660_p.cd in ('17.01','17.02') then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CSLL_OUTRAS_DED:= nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CSLL_OUTRAS_DED,0) + rec_n660_p.valor;--outras deduções CSLL -  real
        end if;
        if rec_n660_p.cd ='18' then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CSLL_RECOLHER   := rec_n660_p.valor;--CSLL a recolher -  real
        end if;
     end loop;  
     ----      
   end if;    
   ------------------
exception
   when others then
      raise_application_error(-20101, 'Erro na pkg_retorna_N660_cs_real:' || sqlerrm);
   ------------------
end;
------------------
procedure pkg_retorna_P200_presumido (en_aberturaecf_id in abertura_ecf.id%type,
                                      en_dt_ini        in per_apur_lr.dt_ini%type,
                                      en_dt_fin        in per_apur_lr.dt_fin%type  )  is
 cursor c_p200 is
    select e.cd ,sum(l.valor)  valor
    from apur_bc_lp l, PER_CALC_APUR_LP p, tab_din_ecf e, registro_ecf r
    where l.PERCALCAPURLP_ID  = p.id
    and l.tabdinecf_id        = e.id
    and e.registroecf_id      = r.id
    and r.cod                 ='P200'
    and p.aberturaecf_id      = en_aberturaecf_id
    and p.dt_ini              >=en_dt_ini and p.dt_fin <=en_dt_fin
    /*and p.dm_per_apur         = gc_dm_per_apur*/
    and e.cd                  in ('1','2','4','6','8','10','11','12','13','14','15','16','17','18','19','20','20.1','21','22','23','24','25','25.01','25.02','26')
    and l.dm_tipo             <> 0
    group by e.cd;
    
 cursor c_p200_p is
    select e.cd ,sum(l.valor)  valor
    from apur_bc_lp l, PER_CALC_APUR_LP p, tab_din_ecf e, registro_ecf r
    where l.PERCALCAPURLP_ID  = p.id
    and l.tabdinecf_id        = e.id
    and e.registroecf_id      = r.id
    and r.cod                 ='P200'
    and p.aberturaecf_id      = en_aberturaecf_id
    and p.dt_ini              >=en_dt_ini and p.dt_fin <=en_dt_fin
    and p.dm_per_apur         = gc_dm_per_apur
    and e.cd                  in ('1','2','4','6','8','10','11','12','13','14','15','16','17','18','19','20','20.1','21','22','23','24','25','25.01','25.02','26')
    and l.dm_tipo             <> 0
    group by e.cd;    
begin
   ------------------
   if gv_parcial = 'N' then
     ----     
     for rec_p200 in c_p200 loop
        exit when c_p200%notfound or (c_p200%notfound) is null;
          if rec_p200.cd = '1' then
             vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_OP_IR    :=rec_p200.valor; --receita bruta operacional IR - presumido
          end if;
          if rec_p200.cd = '2' then
             vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_SUJ_PRES_1_6_IR:=rec_p200.valor; --receita sujeita à presunção 1,6% - IR - presumido
          end if;
          if rec_p200.cd = '4' then
             vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_SUJ_PRES_8_IR  :=rec_p200.valor; --receita sujeita à presunção 8% - IR - presumido
          end if;
          if rec_p200.cd = '6' then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_SUJ_PRES_16_IR  :=rec_p200.valor; --receita sujeita à presunção 16% - IR - presumido
          end if;
          if rec_p200.cd = '8' then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_SUJ_PRES_32_IR  :=rec_p200.valor; --receita sujeita à presunção 32% - IR - presumido
          end if;
          if rec_p200.cd = '10' then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_RESUL_SUM_APL_IR    :=rec_p200.valor; --resultado da soma da aplicação das Aliquotas - IR - presumido
          end if;
          if rec_p200.cd = '20' then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_GCAP_IR    :=rec_p200.valor; --Receita bruta Não Oper Ganho Capital IRPJ
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_GCAP_CS    :=rec_p200.valor; --Receita bruta Não Oper Ganho Capital CSLL
          end if;
          if rec_p200.cd in ('12','13','14','15','16','17','18','19','20.1','25.02') then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_OREC_IR    :=nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_OREC_IR,0) + rec_p200.valor;-- Outras Receitas Não Operacional IRPJ
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_OREC_CS    :=nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_OREC_CS,0) + rec_p200.valor;-- Outras Receitas Não Operacional CSLL
          end if;
          if rec_p200.cd = '11' then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_FIN_CSLL        :=rec_p200.valor; --receitas financeiras - CSLL - presumido
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_FIN_IRPJ        :=rec_p200.valor; --receitas financeiras - IRPJ - presumido
          end if;
          if rec_p200.cd in ('11','12','13','14','15','16','17','18','19','20','20.1','25.02') then
             vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_IR:= nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_IR,0) + rec_p200.valor;--Receita Bruta Não Operacional IRPJ
             --vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_CS:= nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_CS,0) + rec_p200.valor; --Receita Bruta Não Operacional CSLL
           end if;
          if rec_p200.cd = '26' then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_BC_IRPJ_PRES        :=rec_p200.valor; --base de calculo do imposto - IRPJ - presumido
          end if;
     end loop;
     ----      
   else
     ----  
     for rec_p200_p in c_p200_p loop
        exit when c_p200_p%notfound or (c_p200_p%notfound) is null;
          if rec_p200_p.cd = '1' then
             vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_OP_IR    :=rec_p200_p.valor; --receita bruta operacional IR - presumido
          end if;
          if rec_p200_p.cd = '2' then
             vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_SUJ_PRES_1_6_IR:=rec_p200_p.valor; --receita sujeita à presunção 1,6% - IR - presumido
          end if;
          if rec_p200_p.cd = '4' then
             vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_SUJ_PRES_8_IR  :=rec_p200_p.valor; --receita sujeita à presunção 8% - IR - presumido
          end if;
          if rec_p200_p.cd = '6' then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_SUJ_PRES_16_IR  :=rec_p200_p.valor; --receita sujeita à presunção 16% - IR - presumido
          end if;
          if rec_p200_p.cd = '8' then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_SUJ_PRES_32_IR  :=rec_p200_p.valor; --receita sujeita à presunção 32% - IR - presumido
          end if;
          if rec_p200_p.cd = '10' then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_RESUL_SUM_APL_IR    :=rec_p200_p.valor; --resultado da soma da aplicação das Aliquotas - IR - presumido
          end if;
          if rec_p200_p.cd = '20' then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_GCAP_IR    :=rec_p200_p.valor; --Receita bruta Não Oper Ganho Capital IRPJ
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_GCAP_CS    :=rec_p200_p.valor; --Receita bruta Não Oper Ganho Capital CSLL
          end if;
          if rec_p200_p.cd in ('12','13','14','15','16','17','18','19','20.1','25.02') then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_OREC_IR    :=nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_OREC_IR,0) + rec_p200_p.valor;-- Outras Receitas Não Operacional IRPJ
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_OREC_CS    :=nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_OREC_CS,0) + rec_p200_p.valor;-- Outras Receitas Não Operacional CSLL
          end if;
          if rec_p200_p.cd = '11' then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_FIN_CSLL        :=rec_p200_p.valor; --receitas financeiras - CSLL - presumido
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_FIN_IRPJ        :=rec_p200_p.valor; --receitas financeiras - IRPJ - presumido
          end if;
          if rec_p200_p.cd in ('11','12','13','14','15','16','17','18','19','20','20.1','25.02') then
             vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_IR:= nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_IR,0) + rec_p200_p.valor;--Receita Bruta Não Operacional IRPJ
             --vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_CS:= nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_CS,0) + rec_p200.valor; --Receita Bruta Não Operacional CSLL
           end if;
          if rec_p200_p.cd = '26' then
            vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_BC_IRPJ_PRES        :=rec_p200_p.valor; --base de calculo do imposto - IRPJ - presumido
          end if;
     end loop;     
     ----      
   end if;
   ------------------        
exception
   when others then
      raise_application_error(-20101, 'Erro na pkg_retorna_P200_presumido:' || sqlerrm);
   ------------------
end;
------------------
procedure pkg_retorna_P300_presumido (en_aberturaecf_id in abertura_ecf.id%type,
                                      en_dt_ini        in per_apur_lr.dt_ini%type,
                                      en_dt_fin        in per_apur_lr.dt_fin%type  )  is
 cursor c_p300 is
  select e.cd ,sum(l.valor)  valor
  from calc_irpj_base_lp l, PER_CALC_APUR_LP p, tab_din_ecf e, registro_ecf r
  where l.PERCALCAPURLP_ID  = p.id
  and l.tabdinecf_id        = e.id
  and e.cd                  in ('2','3','4','6','10','12','13','11','14','15')
  and e.registroecf_id      = r.id
  and r.cod                 ='P300'
  and p.aberturaecf_id      = en_aberturaecf_id
  and p.dt_ini              >=en_dt_ini and p.dt_fin <=en_dt_fin
  /*and p.dm_per_apur         = gc_dm_per_apur*/
  and l.dm_tipo             <> 0
  group by e.cd;
  
 cursor c_p300_p is
  select e.cd ,sum(l.valor)  valor
  from calc_irpj_base_lp l, PER_CALC_APUR_LP p, tab_din_ecf e, registro_ecf r
  where l.PERCALCAPURLP_ID  = p.id
  and l.tabdinecf_id        = e.id
  and e.cd                  in ('2','3','4','6','10','12','13','11','14','15')
  and e.registroecf_id      = r.id
  and r.cod                 ='P300'
  and p.aberturaecf_id      = en_aberturaecf_id
  and p.dt_ini              >=en_dt_ini and p.dt_fin <=en_dt_fin
  and p.dm_per_apur         = gc_dm_per_apur
  and l.dm_tipo             <> 0
  group by e.cd;
  
begin
   ------------------
   if gv_parcial = 'N' then
     ----     
     for rec_p300 in c_p300 loop
        exit when c_p300%notfound or (c_p300%notfound) is null;
        if rec_p300.cd = '2' then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRPJ_DEVIDO       := nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRPJ_DEVIDO, 0) + rec_p300.valor; --valor de irpj devido - presumido
        end if;
        if rec_p300.cd = '3' then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRPJ_15           := rec_p300.valor; --valor de irpj 15% - presumido
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRPJ_DEVIDO       := nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRPJ_DEVIDO, 0) + rec_p300.valor;
        end if;
        if rec_p300.cd = '4' then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_ADIC_IRPJ_10      := rec_p300.valor; --valor adicional de irpj 10% - presumido
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRPJ_DEVIDO       := nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRPJ_DEVIDO, 0) + rec_p300.valor;
        end if;
        if rec_p300.cd = '6' then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_DEDUCOES_IRPJ_PRES:= rec_p300.valor; --deduções IRPJ - presumido
        end if;
        if rec_p300.cd in ('10','12','13') then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRRF_RETIDO_S_NFSE:= nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRRF_RETIDO_S_NFSE,0) + rec_p300.valor; --IRRF retido sem NFS-e - presumido
        end if;
        if rec_p300.cd in ('11','14') then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRRF_RETIDO_S_APF := nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRRF_RETIDO_S_APF,0) + rec_p300.valor; --IRRF retido sem Aplic. Financeiras - presumido
        end if;
        if rec_p300.cd ='15' then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRPJ_TOTAL_DEV    := rec_p300.valor; --IRPJ retido (total) - presumido
        end if;
     end loop;
     ----      
   else
     ----  
     for rec_p300_p in c_p300_p loop
        exit when c_p300_p%notfound or (c_p300_p%notfound) is null;
        if rec_p300_p.cd = '2' then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRPJ_DEVIDO       := nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRPJ_DEVIDO, 0) + rec_p300_p.valor; --valor de irpj devido - presumido
        end if;
        if rec_p300_p.cd = '3' then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRPJ_15           := rec_p300_p.valor; --valor de irpj 15% - presumido
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRPJ_DEVIDO       := nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRPJ_DEVIDO, 0) + rec_p300_p.valor;
        end if;
        if rec_p300_p.cd = '4' then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_ADIC_IRPJ_10      := rec_p300_p.valor; --valor adicional de irpj 10% - presumido
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRPJ_DEVIDO       := nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRPJ_DEVIDO, 0) + rec_p300_p.valor;
        end if;
        if rec_p300_p.cd = '6' then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_DEDUCOES_IRPJ_PRES:= rec_p300_p.valor; --deduções IRPJ - presumido
        end if;
        if rec_p300_p.cd in ('10','12','13') then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRRF_RETIDO_S_NFSE:= nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRRF_RETIDO_S_NFSE,0) + rec_p300_p.valor; --IRRF retido sem NFS-e - presumido
        end if;
        if rec_p300_p.cd in ('11','14') then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRRF_RETIDO_S_APF := nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRRF_RETIDO_S_APF,0) + rec_p300_p.valor; --IRRF retido sem Aplic. Financeiras - presumido
        end if;
        if rec_p300_p.cd ='15' then
          vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_IRPJ_TOTAL_DEV    := rec_p300_p.valor; --IRPJ retido (total) - presumido
        end if;
     end loop;     
     ----      
   end if;        
   ------------------
exception
   when others then
      raise_application_error(-20101, 'Erro na pkg_retorna_P200_presumido:' || sqlerrm);
   ------------------
end;
------------------
procedure pkg_retorna_P400_presumido (en_aberturaecf_id in abertura_ecf.id%type,
                                      en_dt_ini        in per_apur_lr.dt_ini%type,
                                      en_dt_fin        in per_apur_lr.dt_fin%type )  is
 cursor c_p400 is
  select e.cd ,sum(l.valor)  valor
  from apur_bc_csll_lp l, PER_CALC_APUR_LP p, tab_din_ecf e, registro_ecf r
  where l.PERCALCAPURLP_ID  = p.id
  and l.tabdinecf_id        = e.id
  and e.registroecf_id      = r.id
  and r.cod                 = 'P400'
  and e.cd                  in ('7', '9', '10', '11', '12', '13', '14', '15', '16', '16.01', '18', '19', '19.01', '19.02', '20')
  --and e.cd                  in ('1','2','4','6','10','21')
  and p.aberturaecf_id      = en_aberturaecf_id
  and p.dt_ini              >=en_dt_ini and p.dt_fin <=en_dt_fin
  /*and p.dm_per_apur         = gc_dm_per_apur*/
  and l.dm_tipo             <> 0
  group by e.cd;
  
 cursor c_p400_p is
  select e.cd ,sum(l.valor)  valor
  from apur_bc_csll_lp l, PER_CALC_APUR_LP p, tab_din_ecf e, registro_ecf r
  where l.PERCALCAPURLP_ID  = p.id
  and l.tabdinecf_id        = e.id
  and e.registroecf_id      = r.id
  and r.cod                 = 'P400'
  and e.cd                  in ('7', '9', '10', '11', '12', '13', '14', '15', '16', '16.01', '18', '19', '19.01', '19.02', '20')
  --and e.cd                  in ('1','2','4','6','10','21')
  and p.aberturaecf_id      = en_aberturaecf_id
  and p.dt_ini              >=en_dt_ini and p.dt_fin <=en_dt_fin
  and p.dm_per_apur         = gc_dm_per_apur
  and l.dm_tipo             <> 0
  group by e.cd;  
  
begin
   ------------------
   if gv_parcial = 'N' then
     ----     
     for rec_p400 in c_p400 loop
        exit when c_p400%notfound or (c_p400%notfound) is null;
          if rec_p400.cd = '1' then
             vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_OP_CS    := rec_p400.valor;   --receita bruta operacional CS - presumido
          end if;
          if rec_p400.cd = '2' then
             vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_SUJ_PRES_12_CS := rec_p400.valor;   --receita sujeita à presunção 12% - CS - presumido
          end if;
          if rec_p400.cd = '4' then
             vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_SUJ_PRES_32_CS := rec_p400.valor;   --receita sujeita à presunção 32% - CS - presumido
          end if;
          if rec_p400.cd = '6' then
             vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_RESUL_SUM_APL_CS   := rec_p400.valor;   --resultado da soma da aplicação das Aliquotas - CS - presumido
          end if;
          if rec_p400.cd in ('7', '9', '10', '11', '12', '13', '14', '15', '16', '16.01', '18', '19', '19.01', '19.02', '20') then
          --if rec_p400.cd = '10' then
             vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_CS   :=  nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_CS, 0) + rec_p400.valor;   --receita bruta não operacional - CS - presumido
          end if;
          if rec_p400.cd = '21' then
             vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_BC_CSLL_PRES       := rec_p400.valor;   --base de calculo do imposto - CSLL - presumido
          end if;
     end loop;
     ----      
   else
     ----  
     for rec_p400_p in c_p400_p loop
        exit when c_p400_p%notfound or (c_p400_p%notfound) is null;
          if rec_p400_p.cd = '1' then
             vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_OP_CS    := rec_p400_p.valor;   --receita bruta operacional CS - presumido
          end if;
          if rec_p400_p.cd = '2' then
             vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_SUJ_PRES_12_CS := rec_p400_p.valor;   --receita sujeita à presunção 12% - CS - presumido
          end if;
          if rec_p400_p.cd = '4' then
             vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_SUJ_PRES_32_CS := rec_p400_p.valor;   --receita sujeita à presunção 32% - CS - presumido
          end if;
          if rec_p400_p.cd = '6' then
             vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_RESUL_SUM_APL_CS   := rec_p400_p.valor;   --resultado da soma da aplicação das Aliquotas - CS - presumido
          end if;
          if rec_p400_p.cd in ('7', '9', '10', '11', '12', '13', '14', '15', '16', '16.01', '18', '19', '19.01', '19.02', '20') then
          --if rec_p400.cd = '10' then
             vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_CS   :=  nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_REC_BRUTA_NOP_CS, 0) + rec_p400_p.valor;   --receita bruta não operacional - CS - presumido
          end if;
          if rec_p400_p.cd = '21' then
             vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_BC_CSLL_PRES       := rec_p400_p.valor;   --base de calculo do imposto - CSLL - presumido
          end if;
     end loop;      
     ----      
   end if;        
   ------------------
exception
   when others then
      raise_application_error(-20101, 'Erro na pkg_retorna_P400_presumido:' || sqlerrm);
   ------------------
end;
------------------
procedure pkg_retorna_P500_presumido (en_aberturaecf_id in abertura_ecf.id%type,
                                       en_dt_ini        in per_apur_lr.dt_ini%type,
                                       en_dt_fin        in per_apur_lr.dt_fin%type )  is
 cursor c_p500 is
   select e.cd,sum(l.valor) valor
   from PER_CALC_APUR_LP p,CALC_CSLL_BASE_LP l ,registro_ecf r, tab_din_ecf e
   where e.registroecf_id      = r.id
   and r.cod                 = 'P500'
   and e.cd                  in ('2','4','5','9','10','11','12','13')
   and l.tabdinecf_id        = e.id
   and l.percalcapurlp_id    = p.id
   and p.aberturaecf_id      = en_aberturaecf_id
   and p.dt_ini              >=en_dt_ini and p.dt_fin <=en_dt_fin
   /*and p.dm_per_apur         = gc_dm_per_apur*/
   and l.dm_tipo             <> 0
   group by e.cd;

 cursor c_p500_p is
   select e.cd,sum(l.valor) valor
   from PER_CALC_APUR_LP p,CALC_CSLL_BASE_LP l ,registro_ecf r, tab_din_ecf e
   where e.registroecf_id      = r.id
   and r.cod                 = 'P500'
   and e.cd                  in ('2','4','5','9','10','11','12','13')
   and l.tabdinecf_id        = e.id
   and l.percalcapurlp_id    = p.id
   and p.aberturaecf_id      = en_aberturaecf_id
   and p.dt_ini              >=en_dt_ini and p.dt_fin <=en_dt_fin
   and p.dm_per_apur         = gc_dm_per_apur
   and l.dm_tipo             <> 0
   group by e.cd;

begin
   ------------------
   if gv_parcial = 'N' then
     ----    
     for rec_p500 in c_p500 loop
        exit when c_p500%notfound or (c_p500%notfound) is null;
        if rec_p500.cd = '2' then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CSLL               := rec_p500.valor; --valor de CSLL - presumido
        end if;
        if rec_p500.cd = '4' then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CSLL_DEVIDO        := rec_p500.valor; --valor de csll devido - presumido
        end if;
        if rec_p500.cd = '5' then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_DEDUCOES_CSLL_PRES := rec_p500.valor; --deduções CSLL - presumido
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_BONUS_ADIMP_CSLL   := rec_p500.valor; --bonus de adimplência CSLL - presumido
        end if;
        if rec_p500.cd in ('9','10','11','12') then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CSLL_RETIDO_S_NFSE := nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CSLL_RETIDO_S_NFSE,0) + rec_p500.valor; --CSLL retido sem NFS-e - presumido
        end if;
        if rec_p500.cd = '13' then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CSLL_TOTAL_DEV     := rec_p500.valor;  --CSLL retido (total) - presumido
        end if;
     end loop;
     ----      
   else
     ----  
     for rec_p500_p in c_p500_p loop
        exit when c_p500_p%notfound or (c_p500_p%notfound) is null;
        if rec_p500_p.cd = '2' then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CSLL               := rec_p500_p.valor; --valor de CSLL - presumido
        end if;
        if rec_p500_p.cd = '4' then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CSLL_DEVIDO        := rec_p500_p.valor; --valor de csll devido - presumido
        end if;
        if rec_p500_p.cd = '5' then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_DEDUCOES_CSLL_PRES := rec_p500_p.valor; --deduções CSLL - presumido
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_BONUS_ADIMP_CSLL   := rec_p500_p.valor; --bonus de adimplência CSLL - presumido
        end if;
        if rec_p500_p.cd in ('9','10','11','12') then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CSLL_RETIDO_S_NFSE := nvl(vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CSLL_RETIDO_S_NFSE,0) + rec_p500_p.valor; --CSLL retido sem NFS-e - presumido
        end if;
        if rec_p500_p.cd = '13' then
           vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).VL_CSLL_TOTAL_DEV     := rec_p500_p.valor;  --CSLL retido (total) - presumido
        end if;
     end loop;     
     ----      
   end if;          
   ------------------
exception
   when others then
      raise_application_error(-20101, 'Erro na pkg_retorna_P500_presumido:' || sqlerrm);
   ------------------
end;
------------------
procedure pkg_retorna_periodo (en_APURIRPJCSLLPARCIAL_id in APUR_IRPJ_CSLL_PARCIAL.id%type) is
begin
    select a.dm_per_apur,a.ano_ref into gc_dm_per_apur, gc_ano_ref
      from APUR_IRPJ_CSLL_PARCIAL a
     where a.id = en_APURIRPJCSLLPARCIAL_id;
exception
   when others then
      raise_application_error(-20101, 'Erro na pkg_retorna_periodo:' || sqlerrm);
end;
------------------
function fkg_retorna_empresa_ecf (en_aberturaecf_id in abertura_ecf.id%type) return abertura_ecf.empresa_id%type is
vn_empresa_id abertura_ecf.empresa_id%type;
begin
  vn_empresa_id:=null;
  begin
    select empresa_id
    into vn_empresa_id
    from abertura_ecf where id = en_aberturaecf_id;
  exception
    when others then
       vn_empresa_id:=null;
  end;
  return vn_empresa_id;
exception
 when others then
    raise_application_error(-20101, 'Erro na fkg_retorna_empresa:' || sqlerrm);
end;
------------------
procedure pkg_insert_rel_parc (en_aberturaecf_id in abertura_ecf.id%type,
                               en_dt_ini        in per_apur_lr.dt_ini%type,
                               en_dt_fin        in per_apur_lr.dt_fin%type )  is
vn_indice        pls_integer;
vn_fase          number := 0;
begin
   vn_indice:= 1;
   ---
   vn_fase:= 1;
   pkg_retorna_M300_ir_real(en_aberturaecf_id,en_dt_ini,en_dt_fin);
   ---
   vn_fase:= 2;
   pkg_retorna_M350_ir_real(en_aberturaecf_id,en_dt_ini,en_dt_fin);
   ---
   vn_fase:= 3;
   pkg_retorna_N630_cs_real(en_aberturaecf_id,en_dt_ini,en_dt_fin);
   ---
   vn_fase:= 4;
   pkg_retorna_N650_cs_real(en_aberturaecf_id,en_dt_ini,en_dt_fin);
   ---
   vn_fase:= 5;
   pkg_retorna_N660_cs_real(en_aberturaecf_id,en_dt_ini,en_dt_fin);
   ---
   vn_fase:= 6;
   pkg_retorna_P200_presumido(en_aberturaecf_id,en_dt_ini,en_dt_fin);
   ---
   vn_fase:= 7;
   pkg_retorna_P300_presumido(en_aberturaecf_id,en_dt_ini,en_dt_fin);
   ---
   vn_fase:= 8;
   pkg_retorna_P400_presumido(en_aberturaecf_id,en_dt_ini,en_dt_fin);
   ---
   vn_fase:= 9;
   pkg_retorna_P500_presumido(en_aberturaecf_id,en_dt_ini,en_dt_fin);
   ---
   vn_fase:= 10;
   select RELAPURIRPJCSLLPARCIAL_SEQ.NEXTVAL into vt_REL_APUR_IRPJ_CSLL_PARCIAL(vn_indice).ID from dual;
   insert into REL_APUR_IRPJ_CSLL_PARCIAL values vt_REL_APUR_IRPJ_CSLL_PARCIAL(vn_indice);
   commit;
   ---
exception
   when others then
      raise_application_error(-20101, 'Erro na pkg_insert_rel_parc:'|| vn_fase ||'-'|| sqlerrm);
end;

procedure pkb_geracao (en_aberturaecf_id         in abertura_ecf.id%type ,
                       en_APURIRPJCSLLPARCIAL_id in APUR_IRPJ_CSLL_PARCIAL.id%type ) is
   --
   vn_fase          number := 0;
   vc_dm_per_apur   VARCHAR2(3);
   vi_int           integer;
   vn_mes           integer;
   vd_dt_ini        date;
   vd_dt_fim        date;
   vd_dt_first      date;
   --
   vn_empresa_id     abertura_ecf.empresa_id%type;
   vn_mod_sist       constant number := pk_csf.fkg_ret_id_modulo_sistema('CONTABIL');
   vn_grup_sist      constant number := pk_csf.fkg_ret_id_grupo_sistema(vn_mod_sist, 'ECF');
   --
begin
   vn_fase := 1;
   -- apaga os dados
   delete from REL_APUR_IRPJ_CSLL_PARCIAL
    where APURIRPJCSLLPARCIAL_ID = en_APURIRPJCSLLPARCIAL_id;
   --
   vn_fase := 2;
   pkg_retorna_periodo(en_APURIRPJCSLLPARCIAL_id);
   ---   
   gv_parcial :=null;
   ---
   begin
     --
     vn_fase := 2.1;
     --
     vn_empresa_id:= fkg_retorna_empresa_ecf(en_aberturaecf_id=>en_aberturaecf_id);
     --     
     vn_fase := 2.2;
     --     
     gv_erro := '';
     --
     if not pk_csf.fkg_ret_vl_param_geral_sistema(en_multorg_id => pk_csf.fkg_multorg_id_empresa(en_empresa_id => vn_empresa_id),
                                                  en_empresa_id => vn_empresa_id,
                                                  en_modulo_id  => vn_mod_sist,
                                                  en_grupo_id   => vn_grup_sist,
                                                  ev_param_name => 'APUR_IR_CSLL_PARC_MENSAL',
                                                  sv_vlr_param  => gv_parcial,
                                                  sv_erro       => gv_erro) then
       --
       gv_parcial := null;
       --
     end if;
     --
   exception
     when others then
       gv_parcial := null;
   end;
   --      
   vn_fase:= 3;
   vt_REL_APUR_IRPJ_CSLL_PARCIAL.delete;
   vt_REL_APUR_IRPJ_CSLL_PARCIAL(1).apurirpjcsllparcial_id := en_APURIRPJCSLLPARCIAL_id;
   ---
   vn_mes :=0;
   ---
   if gc_dm_per_apur In ('T01','T02','T03','T04') then
       ---
       vn_fase        := 4;
       if gc_dm_per_apur = 'T01' then vn_mes:=1;  end if;
       if gc_dm_per_apur = 'T02' then vn_mes:=4;  end if;
       if gc_dm_per_apur = 'T03' then vn_mes:=7;  end if;
       if gc_dm_per_apur = 'T04' then vn_mes:=10; end if;
       ---
       vn_fase        := 5;
       vd_dt_ini      := to_date('1/'||vn_mes||'/'||gc_ano_ref);
       vd_dt_fim      := last_day(add_months(vd_dt_ini,2));
       ---
       vn_fase        := 5.1;       
       pkg_insert_rel_parc (en_aberturaecf_id,vd_dt_ini,vd_dt_fim);
       ---  
   elsif gc_dm_per_apur ='A00' then
       ---
       vn_fase        := 6;
       vn_mes         := 1;
       vd_dt_ini      := to_date('1/'||vn_mes||'/'||gc_ano_ref);
       vd_dt_fim      := last_day(add_months(vd_dt_ini,11));
       ---
       vn_fase        := 6.1;       
       pkg_insert_rel_parc (en_aberturaecf_id,vd_dt_ini,vd_dt_fim);
       ---  
   else
       vn_fase        := 7;
       if gc_dm_per_apur = 'A01' then vn_mes:=1; end if; --janeiro
       if gc_dm_per_apur = 'A02' then vn_mes:=2; end if; --fevereiro
       if gc_dm_per_apur = 'A03' then vn_mes:=3; end if; --março
       if gc_dm_per_apur = 'A04' then vn_mes:=4; end if; --abril
       if gc_dm_per_apur = 'A05' then vn_mes:=5; end if; --maio
       if gc_dm_per_apur = 'A06' then vn_mes:=6; end if; --junho
       if gc_dm_per_apur = 'A07' then vn_mes:=7; end if; --julho
       if gc_dm_per_apur = 'A08' then vn_mes:=8; end if; --agosto
       if gc_dm_per_apur = 'A09' then vn_mes:=9; end if; --setembro
       if gc_dm_per_apur = 'A10' then vn_mes:=10; end if; --outubro
       if gc_dm_per_apur = 'A11' then vn_mes:=11; end if; --novembro
       if gc_dm_per_apur = 'A12' then vn_mes:=12; end if; --dezembro
       --
       vn_fase        := 8;
       vd_dt_ini      := to_date('1/'||vn_mes||'/'||gc_ano_ref);
       vd_dt_fim      := last_day(vd_dt_ini);
       vd_dt_first    := to_date('1/1/'||gc_ano_ref);
       --
       vn_fase        := 9;
       pkg_insert_rel_parc (en_aberturaecf_id,vd_dt_first/*vd_dt_ini*/,vd_dt_fim);  
       --
   end if;
/*   vn_fase        := 9;
   pkg_insert_rel_parc (en_aberturaecf_id,vd_dt_first\*vd_dt_ini*\,vd_dt_fim);*/
   ---
exception
   when others then
      --
      rollback;
      pk_csf_api_secf.gv_mensagem_log := 'Erro na pk_rel_apur_irpj_csll_parc.pkb_geracao fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_csf_api_secf.gv_mensagem_log
                                          , ev_resumo          => pk_csf_api_secf.gv_mensagem_log
                                          , en_tipo_log        => pk_csf_api_secf.ERRO_DE_SISTEMA
                                          , en_referencia_id   => pk_csf_api_secf.gn_referencia_id
                                          , ev_obj_referencia  => 'APUR_IRPJ_CSLL_PARCIAL'
                                          );
      exception
         when others then
            null;
      end;
end;
-------------------------------------------------------------------------------------------------------
-- Procedure para Geração da Guia de Pagamento de Imposto
procedure pkg_gera_guia_pgto (en_aberturaecf_id   in abertura_ecf.id%type,
                              en_usuario_id       in neo_usuario.id%type)
is
   --       
   vn_fase              number := 0;       
   vt_csf_log_generico  dbms_sql.number_table;
   vn_guiapgtoimp_id    guia_pgto_imp.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   begin
      --
      select t.* 
        into gt_row_abertura_ecf
      from ABERTURA_ECF t
      where t.id = en_aberturaecf_id;
      --
   exception
      when others then
         raise;
   end;
   --
   -- Geração das Guias do Imposto ICMS-ST ---
   for x in (
      select raicp.id relapurirpjcsllparcial_id
            ,e.id empresa_id
            ,e.pessoa_id
            ,ae.dt_ini
            ,ae.dt_fin
            ,case aicp.dm_tipo 
               when 'M' then last_day(to_date('01/'||substr(aicp.dm_per_apur, -2, length(aicp.dm_per_apur))||'/'||aicp.ano_ref ,'dd/mm/yyyy')) 
               when 'T' then last_day(to_date('01/'||substr(aicp.dm_per_apur, -2, length(aicp.dm_per_apur)) * 3||'/'||aicp.ano_ref ,'dd/mm/yyyy')) 
             end dt_ref
            --
            ,case when ti.sigla ='IRPJ' and aicp.dm_tipo = 'M' then raicp.vl_irpj_recolher
                  when ti.sigla ='IRPJ' and aicp.dm_tipo = 'T' then raicp.vl_irpj_total_dev
                  when ti.sigla ='CSLL' and aicp.dm_tipo = 'M' then raicp.vl_csll_recolher
                  when ti.sigla ='CSLL' and aicp.dm_tipo = 'T' then raicp.vl_csll_total_dev
             end  vl_princ
            --
            ,pdgi.dm_tipo dm_tipo_guia
            ,pdgi.dm_origem
            ,pdgi.pessoa_id_sefaz
            ,pdgi.tipoimp_id
            ,pdgi.obs
            ,ti.cd tipoimposto_cd
            ,aicp.dm_tipo 
            ,pdgi.planoconta_id
         from REL_APUR_IRPJ_CSLL_PARCIAL raicp
             ,APUR_IRPJ_CSLL_PARCIAL      aicp
             ,ABERTURA_ECF                  ae
             ,PARAM_GUIA_PGTO              pgp
             ,PARAM_DET_GUIA_IMP          pdgi
             ,EMPRESA                        e
             ,TIPO_IMPOSTO                  ti
      where 1=1
        and aicp.id               = raicp.apurirpjcsllparcial_id
        and ae.id                 = aicp.aberturaecf_id
        and pgp.empresa_id        = ae.empresa_id
        and pdgi.paramguiapgto_id = pgp.id
        and e.id                  = pdgi.empresa_id_guia
        and ti.id                 = pdgi.tipoimp_id
        and ae.id                 = en_aberturaecf_id
         )
   loop
   --
      vn_fase := 3.1;
      --
      -- Popula a Variável de Tabela -- 
      pk_csf_api_gpi.gt_row_guia_pgto_imp.id                       := null;                          
      pk_csf_api_gpi.gt_row_guia_pgto_imp.empresa_id               := x.empresa_id;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.usuario_id               := en_usuario_id;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_situacao              := 0;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.tipoimposto_id           := x.tipoimp_id;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.tiporetimp_id            := null;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.tiporetimpreceita_id     := null;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.pessoa_id                := x.pessoa_id;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_tipo                  := 1;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_origem                := x.dm_origem;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.nro_via_impressa         := 1;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_ref                   := x.dt_ref;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_vcto                  := x.dt_ref;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_princ                 := x.vl_princ;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_multa                 := 0;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_juro                  := 0;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_outro                 := 0;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_total                 := x.vl_princ;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.obs                      := x.obs;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.pessoa_id_sefaz          := x.pessoa_id_sefaz;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.nro_tit_financ           := null;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_alteracao             := sysdate;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_ret_erp               := 0;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.id_erp                   := null;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.aberturaecf_id           := en_aberturaecf_id;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.planoconta_id            := x.planoconta_id;
      --
      vn_fase := 3.2;
      --
      -- Chama a procedure de integração e finalização da guia
      pk_csf_api_pgto_imp_ret.pkb_finaliza_pgto_imp_ret(est_log_generico  => vt_csf_log_generico,
                                                        en_empresa_id     => x.empresa_id,
                                                        en_dt_ini         => x.dt_ini,
                                                        en_dt_fim         => x.dt_fin,
                                                        sn_guiapgtoimp_id => vn_guiapgtoimp_id);
      --
      vn_fase := 3.3;
      --
      -- Trata se houve Erro na geração da Guia --
      if nvl(vt_csf_log_generico.count,0) > 0 then
         --
         vn_fase := 3.4;
         --
         update APUR_IRPJ_CSLL_PARCIAL
            set dm_situacao_guia = 2 -- Erro
         where aberturaecf_id = en_aberturaecf_id;
         --
      else
         --
         vn_fase := 3.5;
         --
         update APUR_IRPJ_CSLL_PARCIAL
           set dm_situacao_guia = 1 -- Guia Gerada
         where aberturaecf_id = en_aberturaecf_id;
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
      gv_resumo_log := 'Erro na pk_apur_icms_difal.pkg_gera_guia_pgto fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                          , ev_mensagem       => gv_mensagem_log
                                          , ev_resumo         => gv_resumo_log
                                          , en_tipo_log       => erro_de_sistema
                                          , en_referencia_id  => gt_row_abertura_ecf.ID
                                          , ev_obj_referencia => gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo_log);
      --     
end pkg_gera_guia_pgto; 
--
-------------------------------------------------------------------------------------------------------
-- Procedure para Estorno da Guia de Pagamento de Imposto
procedure pkg_estorna_guia_pgto (en_aberturaecf_id   in abertura_ecf.id%type)
is
   --
   vn_fase              number := 0;       
   vt_csf_log_generico  dbms_sql.number_table;
   --
begin
   --
   vn_fase := 1;
   --
   if gt_row_abertura_ecf.id is null then
      --
      begin
         --
         select t.* 
           into gt_row_abertura_ecf
         from ABERTURA_ECF t
         where t.id = en_aberturaecf_id;
         --
      exception
         when others then
            raise;
      end;
      --
   end if;
   --
   vn_fase := 3;
   --
   pk_csf_api_pgto_imp_ret.pkb_estorna_pgto_imp_ret(est_log_generico => vt_csf_log_generico,
                                                    en_empresa_id    => gt_row_abertura_ecf.empresa_id,
                                                    en_dt_ini        => gt_row_abertura_ecf.dt_ini,
                                                    en_dt_fim        => gt_row_abertura_ecf.dt_fin,
                                                    en_pgtoimpret_id => null);
   --
   vn_fase := 4;
   --
  
   if nvl(vt_csf_log_generico.count,0) > 0 then
      --
      vn_fase := 4.1;
      --
      update APUR_IRPJ_CSLL_PARCIAL
         set dm_situacao_guia = 2 -- Erro
       where id = en_aberturaecf_id;
      --
      update GUIA_PGTO_IMP t set
        t.dm_situacao = 2 -- Erro de Validação
      where t.aberturaecf_id = en_aberturaecf_id;
      --
   else
      --
      vn_fase := 4.2;
      --
      update APUR_IRPJ_CSLL_PARCIAL
         set dm_situacao_guia = 0 -- Guia Não Gerada
       where aberturaecf_id = en_aberturaecf_id;
      --
      update GUIA_PGTO_IMP t set
        t.dm_situacao = 3 -- Cancelado
      where t.aberturaecf_id = en_aberturaecf_id;  
      --      
   end if;                                                           
   --  
   commit;
   --
exception
   when others then
      --
      gv_resumo_log := 'Erro na pk_apur_icms_difal.pkg_estorna_guia_pgto fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                          , ev_mensagem       => gv_mensagem_log
                                          , ev_resumo         => gv_resumo_log
                                          , en_tipo_log       => erro_de_sistema
                                          , en_referencia_id  => gt_row_abertura_ecf.id
                                          , ev_obj_referencia => gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo_log);
      --                                                          
end pkg_estorna_guia_pgto; 
--
end pk_rel_apur_irpj_csll_parc;
/
