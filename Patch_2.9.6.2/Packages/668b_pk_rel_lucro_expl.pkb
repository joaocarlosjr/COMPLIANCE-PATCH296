create or replace package body csf_own.pk_rel_lucro_expl is
--
------------------------------------------------------------------------------------------------------------------------------------------------------------------
--   
-- Corpo do pacote de Geração dos Relatoiros de Lucro na Exploração
--
-------------------------------------------------------------------------------------------------------
-- Gera inserção dos dados nos relatorios.
-------------------------------------------------------------------------------------------------------
procedure pkb_insere_dados_relatorio ( est_log_generico     in out nocopy  dbms_sql.number_table
                                     , en_perlucrexpl_id    in     per_lucr_expl.id%type
                                     , en_empresa_id        in     per_lucr_expl.empresa_id%type 
                                     , ed_dt_ini            in     per_lucr_expl.dt_ini%type
                                     , ed_dt_fin            in     per_lucr_expl.dt_fim%type																		 
                                     , en_usuario_id        in     per_lucr_expl.usuario_id%type								
                                     )
is
  --
  vn_loggenerico_id               log_generico.id%type;
  vn_fase                         number := null;
  vn_existe                       number := null; 
  vn_perc_red_ir                  empresa_forma_trib.perc_red_ir%type;  
  --
  cursor c_relcalclucexp is
    select p.empresa_id
         , p.dt_ini
         , p.dt_fim
         , c.descr
         , c.dm_estilo
         , a.valor
      from per_lucr_expl     p
         , apur_lucro_expl   a
         , cod_din_lucr_expl c
     where p.id             = en_perlucrexpl_id
       and a.perlucrexpl_id = p.id 
       and c.id             = a.coddinlucrexpl_id
     order by c.linha;	   
  --
  cursor c_reldistatvlucexpl is
    select p.empresa_id
         , p.dt_ini
         , p.dt_fim
         , s.obs descr 
         , sum(r.vl_receita) rec_liquida 
         , round((( b.rec_liq_acum / sum(r.vl_receita)) * 100 ),2) perc_part
         , b.lucr_expl
         , b.vl_irpj
         , b.vl_ir_adic
         , b.vl_ir_total
         , b.vl_red_benef 
      from csf_own.per_lucr_expl         p
         , csf_own.calc_benef_lucro_expl b
         , csf_own.rec_unid_lucr_expl    r    
         , csf_own.param_rec_lucr_expl   s
     where p.id             = en_perlucrexpl_id
       and b.perlucrexpl_id = p.id
       and r.perlucrexpl_id = p.id
       and r.empresa_id     = p.empresa_id
       and s.id             = r.paramreclucrexpl_id
     group by p.empresa_id
            , p.dt_ini
            , p.dt_fim
            , s.obs  
            , b.rec_liq_acum
            , b.lucr_expl
            , b.vl_irpj
            , b.vl_ir_adic
            , b.vl_ir_total
            , b.vl_red_benef;   
  --  
begin
   --
   vn_fase := 1;
   -- 
   begin   
      select count(1)
        into vn_existe 
        from rel_calc_lucr_explr r
       where r.empresa_id = en_empresa_id
         and r.dt_ini     = ed_dt_ini
         and r.dt_fim     = ed_dt_fin
         and r.usuario_id = en_usuario_id;     
   exception
      when others then
         vn_existe := null;
   end;
   --
   vn_fase := 2;
   --   
   if nvl( vn_existe,0) >= 1 then
      --   
      begin
         delete from rel_calc_lucr_explr r
          where r.empresa_id = en_empresa_id
            and r.dt_ini     = ed_dt_ini
            and r.dt_fim     = ed_dt_fin
            and r.usuario_id = en_usuario_id;		 
      exception
         when others then        
            --
            gv_mensagem := 'Erro na exclusão do relatorio de Calculo do lucro exploração, '||
                           'parâmetro ID: '||en_perlucrexpl_id||'- Empresa ID: '||en_empresa_id||'.'||
                           ' pk_rel_lucro_expl.pkb_insere_dados_relatorio fase('||vn_fase||'): '||sqlerrm;
            --
            declare
                vn_loggenerico_id  log_generico.id%TYPE;
            begin
                --
                pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id   => vn_loggenerico_id
                                                 , ev_mensagem         => gv_mensagem
                                                 , ev_resumo           => gv_mensagem
                                                 , en_tipo_log         => ERRO_DE_SISTEMA
                                                 , en_referencia_id    => gn_referencia_id
                                                 , ev_obj_referencia   => gv_obj_referencia
                                                 , en_empresa_id       => gn_empresa_id );
                --
                -- Armazena o "loggenerico_id" na memória
                pk_csf_api_secf.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                                    , est_log_generico  => est_log_generico );
                --			   
            exception
               when others then
                  null;
            end;
            --
      end;
      --	
   end if;  
   --
   vn_fase := 3;
   --  
   for rec in c_relcalclucexp loop
      --
      exit when c_relcalclucexp%notfound or (c_relcalclucexp%notfound) is null;   
      --
      insert into rel_calc_lucr_explr ( id
                                      , empresa_id
                                      , dt_ini
                                      , dt_fim
                                      , usuario_id
                                      , dt_hr_alteracao
                                      , descr
                                      , dm_estilo
                                      , valor
                                      )
                               values ( relcalclucrexplr_seq.nextval
                                      , rec.empresa_id
                                      , rec.dt_ini
                                      , rec.dt_fim
                                      , en_usuario_id
                                      , sysdate
                                      , rec.descr
                                      , rec.dm_estilo
                                      , rec.valor
                                      );
      --
   end loop; -- c_relcalclucexp 
   --
   vn_fase := 4;
   --   
   vn_existe := null;
   --    
   begin
      select count(1)
        into vn_existe
        from rel_distr_atv_lucr_explr r
       where r.empresa_id  = en_empresa_id
         and r.dt_ini      = ed_dt_ini
         and r.dt_fim      = ed_dt_fin
         and r.usuario_id  = en_usuario_id;   
   exception
      when others then
         vn_existe := null;
   end;
   --
   vn_fase := 5;
   --   
   if nvl( vn_existe,0) >= 1 then
      --   
      begin
         delete from rel_distr_atv_lucr_explr r
          where r.empresa_id = en_empresa_id
            and r.dt_ini     = ed_dt_ini
            and r.dt_fim     = ed_dt_fin
            and r.usuario_id = en_usuario_id;		 
      exception
         when others then        
            --
            gv_mensagem := 'Erro na exclusão do relatorio de de Distribuição por Atividade do Lucro da Exploração, '||
                           'parâmetro ID: '||en_perlucrexpl_id||'- Empresa ID: '||en_empresa_id||'.'||
                           ' pk_rel_lucro_expl.pkb_insere_dados_relatorio fase('||vn_fase||'): '||sqlerrm;
            --
            declare
                vn_loggenerico_id  log_generico.id%TYPE;
            begin
                --
                pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id   => vn_loggenerico_id
                                                 , ev_mensagem         => gv_mensagem
                                                 , ev_resumo           => gv_mensagem
                                                 , en_tipo_log         => ERRO_DE_SISTEMA
                                                 , en_referencia_id    => gn_referencia_id
                                                 , ev_obj_referencia   => gv_obj_referencia
                                                 , en_empresa_id       => gn_empresa_id );
                --
                -- Armazena o "loggenerico_id" na memória
                pk_csf_api_secf.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                                    , est_log_generico  => est_log_generico );
                --			   
            exception
               when others then
                  null;
            end;
            --
      end;
      --	  
   end if; 
   --
   vn_fase := 6;
   --   
   for rec2 in c_reldistatvlucexpl loop
      --
      exit when c_reldistatvlucexpl%notfound or (c_reldistatvlucexpl%notfound) is null;   
      --
      vn_perc_red_ir := null;
      --	  
      begin
         select e.perc_red_ir
           into vn_perc_red_ir 
           from empresa_forma_trib e
          where e.empresa_id                    = en_empresa_id
            and to_date(e.dt_ini,'dd/mm/rrrr')                 >= to_date(ed_dt_ini,'dd/mm/rrrr')
            and (e.dt_fin                                       is null or
                 to_date(nvl(e.dt_fin,ed_dt_fin),'dd/mm/rrrr') <= to_date(ed_dt_fin,'dd/mm/rrrr'));
      exception
         when others then
            vn_perc_red_ir := null;		 
      end;	  
      --
      vn_fase := 6.1;	  
      --	  
      insert into rel_distr_atv_lucr_explr( id
                                          , empresa_id
                                          , dt_ini
                                          , dt_fim
                                          , usuario_id
                                          , dt_hr_alteracao
                                          , descr
                                          , perc_reduc
                                          , rec_liquida
                                          , perc_part
                                          , lucr_expl
                                          , vl_irpj
                                          , vl_ir_adic
                                          , vl_ir_total
                                          , vl_red_benef
                                          )
                                   values ( reldistratvlucrexplr_seq.nextval
                                          ,	rec2.empresa_id
                                          , rec2.dt_ini
                                          , rec2.dt_fim	
                                          , en_usuario_id
                                          , sysdate
                                          , rec2.descr
                                          , vn_perc_red_ir
                                          , rec2.rec_liquida
                                          , rec2.perc_part
                                          , rec2.lucr_expl
                                          , rec2.vl_irpj
                                          ,	rec2.vl_ir_adic
                                          , rec2.vl_ir_total
                                          , rec2.vl_red_benef										  
                                          );
      --
   end loop;  -- c_reldistatvlucexpl
   --   
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_rel_lucro_expl.pkb_insere_dados_relatorio fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%TYPE;
      begin
         --
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id   => vn_loggenerico_id
                                          , ev_mensagem         => gv_mensagem
                                          , ev_resumo           => gv_mensagem
                                          , en_tipo_log         => ERRO_DE_SISTEMA
                                          , en_referencia_id    => gn_referencia_id
                                          , ev_obj_referencia   => gv_obj_referencia
                                          , en_empresa_id       => gn_empresa_id );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_secf.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico );
         -- 
      exception
         when others then
            null;
      end;   
      -- 
end pkb_insere_dados_relatorio;

-------------------------------------------------------------------------------------------------------
-- Procedimento para Gerar relatórios de lucro na exploração
-------------------------------------------------------------------------------------------------------
procedure pkb_gerar_relatorio ( en_perlucrexpl_id    in     per_lucr_expl.id%type
                              , en_usuario_id        in     per_lucr_expl.usuario_id%type
                              )
is
  --
  vn_loggenerico_id          log_generico.id%type;
  vt_log_generico            dbms_sql.number_table;
  vn_fase                    number := null;
  --
begin
  --
  vn_fase := 1;
  --
  gt_row_per_lucr_expl := null; 
  vt_log_generico.delete;  
  -- 
  begin
     --
     select * 
       into gt_row_per_lucr_expl	 
       from per_lucr_expl pl	   
      where pl.id          = en_perlucrexpl_id;
     --		
  exception   
     when no_data_found then
        gt_row_per_lucr_expl := null;     	 
  end;
  --  
  vn_fase := 2;
  --
  if gt_row_per_lucr_expl.id is null then
     --
     --
     gv_mensagem := 'Periodo de geração de Lucro Exploração ID: ('||en_perlucrexpl_id||', não encontrado impossível gerar os relatorios. pk_rel_lucro_expl.pkb_gerar_relatorio fase('||vn_fase||').';
     --
     declare
        vn_loggenerico_id  log_generico.id%TYPE;
     begin
        --
        pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id   => vn_loggenerico_id
                                         , ev_mensagem         => gv_mensagem
                                         , ev_resumo           => gv_mensagem
                                         , en_tipo_log         => ERRO_DE_SISTEMA
                                         , en_referencia_id    => en_perlucrexpl_id
                                         , ev_obj_referencia   => gv_obj_referencia
                                         , en_empresa_id       => null );
        --
        -- Armazena o "loggenerico_id" na memória
        pk_csf_api_secf.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                            , est_log_generico  => vt_log_generico );
		--
     exception
        when others then
           null;
     end;
     --	 
  else  
     --  
     vn_fase := 3;
     --	 
     gn_empresa_id    := gt_row_per_lucr_expl.empresa_id;
     gn_referencia_id := gt_row_per_lucr_expl.id; 
     --
     vn_fase := 4;
     -- 	 
     if gt_row_per_lucr_expl.dm_situacao <> 3 then  -- Finalizado
        --
        gv_mensagem := 'Periodo de geração de Lucro Exploração ('||to_date(gt_row_per_lucr_expl.dt_ini,'dd/mm/rrrr')||' a '||to_date(gt_row_per_lucr_expl.dt_fim,'dd/mm/rrrr')||') para empresa ID: '||gt_row_per_lucr_expl.empresa_id||', não finalizado não é possível gerar os relatorios. pk_rel_lucro_expl.pkb_gerar_relatorio fase('||vn_fase||').';
        --
        declare
           vn_loggenerico_id  log_generico.id%TYPE;
        begin
           --
           pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id   => vn_loggenerico_id
                                            , ev_mensagem         => gv_mensagem
                                            , ev_resumo           => gv_mensagem
                                            , en_tipo_log         => ERRO_DE_SISTEMA
                                            , en_referencia_id    => gn_referencia_id
                                            , ev_obj_referencia   => gv_obj_referencia
                                            , en_empresa_id       => gn_empresa_id );
           --
           -- Armazena o "loggenerico_id" na memória
           pk_csf_api_secf.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                               , est_log_generico  => vt_log_generico );
		   --
        exception
           when others then
              null;
        end;
        --	 
     else
        --   
        vn_fase := 5;
        --  
        gn_multorg_id := pk_csf.fkg_multorg_id_empresa ( en_empresa_id => gt_row_per_lucr_expl.empresa_id );
        --
        vn_fase := 5;
        -- 
        gv_mensagem := 'Iniciando geração de relatorios - Lucro Exploração Empresa: '||gt_row_per_lucr_expl.empresa_id||
                       ' período: '||to_date(gt_row_per_lucr_expl.dt_ini,'dd/mm/rrrr')||' a '||to_date(gt_row_per_lucr_expl.dt_fim,'dd/mm/rrrr');
        --
        declare
           vn_loggenerico_id  log_generico.id%TYPE;
        begin
           --
           pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id   => vn_loggenerico_id
                                            , ev_mensagem         => gv_mensagem
                                            , ev_resumo           => gv_mensagem
                                            , en_tipo_log         => INFORMACAO
                                            , en_referencia_id    => gn_referencia_id
                                            , ev_obj_referencia   => gv_obj_referencia
                                            , en_empresa_id       => gn_empresa_id );
           --
           -- Armazena o "loggenerico_id" na memória
           pk_csf_api_secf.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                               , est_log_generico  => vt_log_generico );
		   --
        exception
           when others then
              null;
        end;
        -- 
        -- Gera a inserção dos dados nos relatorios de lucro da exploração.
        pkb_insere_dados_relatorio ( est_log_generico    =>  vt_log_generico
                                   , en_perlucrexpl_id   =>  gt_row_per_lucr_expl.id
                                   , en_empresa_id       =>  gt_row_per_lucr_expl.empresa_id 
                                   , ed_dt_ini           =>  gt_row_per_lucr_expl.dt_ini
                                   , ed_dt_fin           =>  gt_row_per_lucr_expl.dt_fim                                     
                                   , en_usuario_id       =>  en_usuario_id );
        --							   
        vn_fase := 99;
        --
        gv_mensagem := 'Finalizado geração dos relatorios - período de apuração ID: '||gt_row_per_lucr_expl.id||', Empresa: '||gt_row_per_lucr_expl.empresa_id||
                       ' período: '||to_date(gt_row_per_lucr_expl.dt_ini,'dd/mm/rrrr')||' a '||to_date(gt_row_per_lucr_expl.dt_fim,'dd/mm/rrrr');
        --
        declare
           vn_loggenerico_id  log_generico.id%TYPE;
        begin
           --
           pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id   => vn_loggenerico_id
                                            , ev_mensagem         => gv_mensagem
                                            , ev_resumo           => gv_mensagem
                                            , en_tipo_log         => INFORMACAO
                                            , en_referencia_id    => gn_referencia_id
                                            , ev_obj_referencia   => gv_obj_referencia
                                            , en_empresa_id       => gn_empresa_id );
           -- 
        exception
           when others then
              null;
        end;
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
      gv_mensagem := 'Erro na pk_rel_lucro_expl.pkb_gerar_relatorio fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%TYPE;
      begin
         --
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id   => vn_loggenerico_id
                                          , ev_mensagem         => gv_mensagem
                                          , ev_resumo           => gv_mensagem
                                          , en_tipo_log         => ERRO_DE_SISTEMA
                                          , en_referencia_id    => gn_referencia_id
                                          , ev_obj_referencia   => gv_obj_referencia
                                          , en_empresa_id       => gn_empresa_id );
         --
      exception
         when others then
            null;
      end; 
      --
end pkb_gerar_relatorio;

-------------------------------------------------------------------------------------------------------

end pk_rel_lucro_expl;
/
