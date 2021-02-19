create or replace package body csf_own.pk_gera_lucro_expl is
--
------------------------------------------------------------------------------------------------------------------------------------------------------------------
--   
-- Corpo do pacote de Geração de Calculo de Lucro na Exploração
--
-------------------------------------------------------------------------------------------------------
-- Procedimento para atualizar a situação do período de exploração
-------------------------------------------------------------------------------------------------------
procedure pkb_atuliza_sit_periodo ( en_perlucrexpl_id    in    per_lucr_expl.id%type
                                  , en_dm_situacao       in    per_lucr_expl.dm_situacao%type )
is
  --
  vn_fase              number := null;
  --  
begin  
  --
  vn_fase := 1;
  --  
  if en_dm_situacao is null then
     --
     goto sair_atualiza;	 
     --
  end if;
  --
  vn_fase := 2;
  --	 
  begin	 
     update per_lucr_expl pl
        set pl.dm_situacao  = en_dm_situacao
          , pl.dt_alteracao = sysdate
      where pl.id = en_perlucrexpl_id;
  exception
     when others then
        --
        gv_mensagem := 'Erro ao alterar Período de Lucro Exploração ID: ('||en_perlucrexpl_id||') na pk_gera_lucro_expl.pkb_atuliza_sit_periodo fase('||vn_fase||'): '||sqlerrm;
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
  end;
  --	 
  <<sair_atualiza>>
  null;  
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_lucro_expl.pkb_atuliza_sit_periodo fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%TYPE;
      begin
         --
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
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
end pkb_atuliza_sit_periodo;

-------------------------------------------------------------------------------------------------------
-- Procedimento para inserir na tabela de apuração 
-------------------------------------------------------------------------------------------------------
procedure pkb_insere_val_apuracao ( en_perlucrexpl_id      in   per_lucr_expl.id%type 
                                  , en_coddinlucrexpl_id   in   cod_din_lucr_expl.id%type 
                                  , en_valor               in   apur_lucro_expl.valor%type 
                                  )

is								
  --
  vn_fase                   number := null;
  vn_valor                  apur_lucro_expl.valor%type; 
  vn_dm_inverte_sinal       cod_din_lucr_expl.dm_inverte_sinal%type;        
  --  
begin
   --
   vn_fase := 1;
   -- 
   vn_dm_inverte_sinal := null;
   --   
   begin 
      select c.dm_inverte_sinal 
        into vn_dm_inverte_sinal	  
        from cod_din_lucr_expl c
       where c.id = en_coddinlucrexpl_id; 
   exception
      when others then
         vn_dm_inverte_sinal := null;
   end;
   --
   vn_fase := 2;
   --   
   vn_valor := 0;
   vn_valor := en_valor;
   -- 
   vn_fase := 3;
   --    
   if nvl(vn_dm_inverte_sinal,'N') = 'S' then 
      --
      vn_valor := vn_valor * -1;
      --
   end if;
   --   
   vn_fase := 4;
   --   
   update apur_lucro_expl al 
      set al.valor = vn_valor
    where al.perlucrexpl_id    = en_perlucrexpl_id
      and al.coddinlucrexpl_id = en_coddinlucrexpl_id;	  
   --				 
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_lucro_expl.pkb_insere_val_apuracao fase('||vn_fase||'): '||sqlerrm;
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
end pkb_insere_val_apuracao;

-------------------------------------------------------------------------------------------------------
-- Procedimento para inserir na tabela de Memoria de Calculo 
-------------------------------------------------------------------------------------------------------
procedure pkb_insere_mem_calc( en_perlucrexpl_id          in   mem_calc_lucro_expl.perlucrexpl_id%type
                             , en_paramdpcoddinctale_id   in   mem_calc_lucro_expl.paramdpcoddinctale_id%type
                             , en_planoconta_id           in   mem_calc_lucro_expl.planoconta_id%type
                             , en_centrocusto_id          in   mem_calc_lucro_expl.centrocusto_id%type
                             , ev_dm_tb_origem            in   mem_calc_lucro_expl.dm_tb_origem%type
                             , ev_dm_tipo_vlr_calc        in   mem_calc_lucro_expl.dm_tipo_vlr_calc%type
                             , en_valor                   in   mem_calc_lucro_expl.valor%type 
                             , ev_descr                   in   mem_calc_lucro_expl.descr%type
                             )
is								
  --
  vn_fase                   number := null;
  vn_existe                 number := null;  
  --  
begin
   --
   vn_fase := 1;
   -- 
   begin
      select count(1)
        into vn_existe
        from mem_calc_lucro_expl mc
       where mc.perlucrexpl_id        = en_perlucrexpl_id
         and mc.paramdpcoddinctale_id = en_paramdpcoddinctale_id;    
   exception
      when others then
         vn_existe := null;
   end;
   --
   vn_fase := 2;
   --   
   if nvl( vn_existe,0 ) = 0 then
      --   
      insert into mem_calc_lucro_expl( id
                                     , perlucrexpl_id
                                     , paramdpcoddinctale_id
                                     , planoconta_id
                                     , centrocusto_id
                                     , dm_tb_origem
                                     , dm_tipo_vlr_calc
                                     , valor
                                     , descr
                                     )
                               values( memcalclucroexpl_seq.nextval
                                     , en_perlucrexpl_id
                                     , en_paramdpcoddinctale_id
                                     , en_planoconta_id
									 , en_centrocusto_id
									 , ev_dm_tb_origem
									 , ev_dm_tipo_vlr_calc
									 , en_valor
									 , ev_descr
									 );
      --   
   end if;   
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_lucro_expl.pkb_insere_mem_calc fase('||vn_fase||'): '||sqlerrm;
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
end pkb_insere_mem_calc;
   
-------------------------------------------------------------------------------------------------------
-- Procedimento Calcula valor de campo formula só com registros to tipo E-Editável
-------------------------------------------------------------------------------------------------------
function fkg_calcula_valor_editavel ( est_formula_cod_din_lucexp   in out nocopy  formula_cod_din_lucexp%rowtype
                                    , en_perlucrexpl_id            in per_lucr_expl.id%type )
         return apur_lucro_expl.valor%type is
  --
  vn_valor      apur_lucro_expl.valor%type;  
  --  
  cursor c_formula is
    select sum(nvl(a.valor,0)) valor
      from itformula_cod_din_lucexp  i
         , apur_lucro_expl           a 	  
         , cod_din_lucr_expl         c 
     where i.formulacoddinlucexp_id = est_formula_cod_din_lucexp.id
       and a.perlucrexpl_id         = en_perlucrexpl_id
       and a.coddinlucrexpl_id      = i.coddinlucrexpl_id	 
       and c.id                     = a.coddinlucrexpl_id
       and c.dm_tipo                = 'E';  -- Editável     
   --
begin
   --
   vn_valor := null;
   --
   for cfo in c_formula loop
      --
      exit when c_formula%notfound or (c_formula%notfound) is null;
      --
      vn_valor := nvl(vn_valor,0) + cfo.valor;		 
      --		 
   end loop;
   --
   if est_formula_cod_din_lucexp.oper_matematico is not null and
      nvl(est_formula_cod_din_lucexp.valor_oper_matematico,0) > 0 then
      --
      if upper(est_formula_cod_din_lucexp.oper_matematico) = 'A' then    -- Adição
         --
         vn_valor := vn_valor + est_formula_cod_din_lucexp.valor_oper_matematico;
         --
      elsif upper(est_formula_cod_din_lucexp.oper_matematico) = 'S' then -- Subtração
         --
         vn_valor := vn_valor - est_formula_cod_din_lucexp.valor_oper_matematico;
         --
      elsif upper(est_formula_cod_din_lucexp.oper_matematico) = 'M' then -- Multiplicação
         --
         vn_valor := vn_valor * est_formula_cod_din_lucexp.valor_oper_matematico;
         --
      elsif upper(est_formula_cod_din_lucexp.oper_matematico) = 'D' then -- Divisão
         --
         vn_valor := vn_valor / est_formula_cod_din_lucexp.valor_oper_matematico;
         --
      end if;
      --
   end if;
   --
   return vn_valor;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_calcula_valor_editavel:' || sqlerrm);
end fkg_calcula_valor_editavel;

-------------------------------------------------------------------------------------------------------
-- Procedimento Calcula o valor da fórmula do campo fórmula
-------------------------------------------------------------------------------------------------------
function fkg_calcula_formula ( est_formula_cod_din_lucexp   in out nocopy  formula_cod_din_lucexp%rowtype
                             , en_perlucrexpl_id            in per_lucr_expl.id%type )
         return apur_lucro_expl.valor%type is
  -- Variável do vetor
  i pls_integer;
  --
  vn_valor      apur_lucro_expl.valor%type;
  --
  -- Valores da Fórmula
  type tab_vlr is record(
    valor          number(19,2));
  --
  type t_tab_vlr is table of tab_vlr index by binary_integer;
  vt_tab_vlr t_tab_vlr;
  --
  cursor c_formula is
    select c.linha, c.formulacoddinlucexp_id, c.dm_tipo, a.valor
      from itformula_cod_din_lucexp  i
         , apur_lucro_expl           a 		  
         , cod_din_lucr_expl         c    
     where i.formulacoddinlucexp_id = est_formula_cod_din_lucexp.id
       and a.perlucrexpl_id         = en_perlucrexpl_id
       and a.coddinlucrexpl_id      = i.coddinlucrexpl_id	 
       and c.id                     = a.coddinlucrexpl_id
     order by c.linha;  
  --
begin
   --
   vt_tab_vlr.delete;
   --
   for cfo in c_formula loop
      --
      exit when c_formula%notfound or (c_formula%notfound) is null;
      --
      i := nvl(i,0) + 1;
      --
      vt_tab_vlr(i).valor := cfo.valor;	  
      --		 
   end loop;
   --
   vn_valor := 0;
   --
   if nvl(est_formula_cod_din_lucexp.valor_oper_matematico,0) > 0 then
      --
      if nvl(vt_tab_vlr.count, 0) > 0 then
         --
         i := nvl(vt_tab_vlr.first, 0);
         --
         loop
           --
           if nvl(i, 0) = 0 then
              exit;
           end if;
           --
		   vn_valor := vn_valor + vt_tab_vlr(i).valor;
           --
           if i = vt_tab_vlr.last then
             exit;
           else
             i := vt_tab_vlr.next(i);
           end if;
           --
         end loop;
         --
      end if;
      --
      vn_valor := vn_valor * est_formula_cod_din_lucexp.valor_oper_matematico;
      --
   else
      --
      if nvl(vt_tab_vlr.count, 0) > 0 then
         --
         i := nvl(vt_tab_vlr.first, 0);
         --
         loop
           --
           if nvl(i, 0) = 0 then
             exit;
           end if;
           --
           if i = 1 then
              vn_valor := vt_tab_vlr(i).valor;
           else
              if upper(est_formula_cod_din_lucexp.oper_matematico) = 'A' then       -- Adição
                 vn_valor := vn_valor + vt_tab_vlr(i).valor;
              elsif upper(est_formula_cod_din_lucexp.oper_matematico) = 'S' then    -- Subtração
                 vn_valor := vn_valor - vt_tab_vlr(i).valor;
              end if;
           end if;
           --
           if i = vt_tab_vlr.last then
             exit;
           else
             i := vt_tab_vlr.next(i);
           end if;
           --
         end loop;
         --
      end if;
      --
   end if;
   --
   return vn_valor;
   --
exception
   when no_data_found then
      return (null);
   when others then
      raise_application_error(-20101, 'Erro na fkg_calcula_formula:' || sqlerrm);
end fkg_calcula_formula;

-------------------------------------------------------------------------------------------------------
-- Execura carga na tabela APUR_LUCRO_EXPL dos codigos dinamicos ativos para o mult_org específico
-------------------------------------------------------------------------------------------------------
procedure pkb_carrega_apurlucroexp ( en_perlucrexpl_id   in   per_lucr_expl.id%type 
                                   , en_multorg_id       in   cod_din_lucr_expl.id%type 
                                   )
is
  --
  vn_fase           number := null;
  vn_existe         number := null;
  --  
  cursor c_coddinluexp is
     select *
       from cod_din_lucr_expl cl       
      where cl.multorg_id   = en_multorg_id
        and cl.dm_situacao  = 1  -- Ativo    
      order by cl.linha;  
  --
begin
   --
   vn_fase := 1;
   --   
   for rec in c_coddinluexp loop
      --
      exit when c_coddinluexp%notfound or (c_coddinluexp%notfound) is null;
      --
      vn_fase := 1.1;
      --	  
      vn_existe := null;
      --	  
      begin
         select count(1)
           into vn_existe		 
           from apur_lucro_expl al
          where al.perlucrexpl_id    = en_perlucrexpl_id
            and al.coddinlucrexpl_id = rec.id;
      exception
         when others then	
            vn_existe := null;
      end;
      --
      vn_fase := 1.2;
      --	  
      if nvl( vn_existe,0 ) = 0 then
         --	  
         insert into apur_lucro_expl( id
                                    , perlucrexpl_id
                                    , coddinlucrexpl_id
                                    )      
                             values ( apurlucroexpl_seq.nextval
                                    , en_perlucrexpl_id
                                    , rec.id
                                    );
         --
      end if;
      --  
   end loop;  -- c_coddinluexp
   -- 
   commit;
   --   
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_lucro_expl.pkb_carrega_apurlucroexp fase('||vn_fase||'): '||sqlerrm;
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
end pkb_carrega_apurlucroexp;

-------------------------------------------------------------------------------------------------------
-- Gera calculo do Benefício
-------------------------------------------------------------------------------------------------------
procedure pkb_gera_calculo_beneficio ( est_log_generico     in out nocopy  dbms_sql.number_table
                                     , en_perlucrexpl_id    in     per_lucr_expl.id%type
                                     , en_empresa_id        in     per_lucr_expl.empresa_id%type 
                                     , ed_dt_ini            in     per_lucr_expl.dt_ini%type
                                     , ed_dt_fin            in     per_lucr_expl.dt_fim%type									
                                     )
is
  --
  vn_loggenerico_id               log_generico.id%type;
  vn_fase                         number := null;
  vt_calc_lucro_expl              calc_lucro_expl%rowtype;
  vt_calc_benef_lucro_expl        calc_benef_lucro_expl%rowtype;
  vd_dt_inicial                   date; 
  vn_perc_red_ir                  empresa_forma_trib.perc_red_ir%type;  
  --
begin
   --
   vn_fase := 1;
   -- 
   --  Calculo dos campo da tabela "CALC_LUCRO_EXPL" --------------------------------------------------------
   --   
   vt_calc_lucro_expl := null;
   --  
   begin
      --	
      select * 
        into vt_calc_lucro_expl
        from calc_lucro_expl cl
       where cl.perlucrexpl_id = en_perlucrexpl_id; 		
      --			   
   exception
      when others then
         null;
   end;	
   --   
   -- TOT_LUCRO_EXPL - Inicio  
   vn_fase := 2;
   --
   if nvl( vt_calc_lucro_expl.tot_lucro_expl, 0) <= 0 then   
      --
      begin	  
         select nvl(al.valor,0)
           into	vt_calc_lucro_expl.tot_lucro_expl	 
           from apur_lucro_expl   al
              , cod_din_lucr_expl cl
          where al.perlucrexpl_id = en_perlucrexpl_id
            and cl.id             = al.coddinlucrexpl_id     
            and cl.cod            = '10';
      exception
         when others then
            vt_calc_lucro_expl.tot_lucro_expl := null;
      end;
      --	  
   end if;   
   -- TOT_LUCRO_EXPL - Fim
   --
   -- VL_LUCRO_REAL - Inicio   
   vn_fase := 3;   
   --   
   if nvl( vt_calc_lucro_expl.vl_lucro_real, 0) <= 0 then
      --
      begin	 
         select nvl(a.valor,0)
           into vt_calc_lucro_expl.vl_lucro_real
           from lanc_part_a_lalur a
              , tab_din_ecf       b 
              , registro_ecf      c
              , per_apur_lr       d
              , abertura_ecf      e
          where a.tabdinecf_id                  = b.id
            and b.registroecf_id                = c.id
            and a.perapurlr_id                  = d.id
            and c.cod                           = 'M300'
            and b.cd                            = '175'
            and to_date(d.dt_ini,'dd/mm/rrrr') >= to_date(ed_dt_ini,'dd/mm/rrrr') 
            and to_date(d.dt_fin,'dd/mm/rrrr') <= to_date(ed_dt_fin,'dd/mm/rrrr')
            and substr(d.dm_per_apur,2,2)       = substr(to_date(ed_dt_fin,'dd/mm/rrrr'),4,2) 
            and d.dm_situacao                   = 3       -- 3-Processada
            and e.id                            = d.aberturaecf_id
            and e.empresa_id                    = en_empresa_id
            and e.dm_situacao                  in (4,6);  -- 4-Validado / 6-Gerado Arquivo
      exception
         when others then
            vt_calc_lucro_expl.vl_lucro_real := null;
      end;			
      --		 
   end if;
   --
   vn_fase := 4;
   --  
   if nvl( vt_calc_lucro_expl.vl_lucro_real, 0) <= 0 then   
      --
      begin
         select nvl(ai.vl_lucro_liq_lr,0)  
           into vt_calc_lucro_expl.vl_lucro_real		 
           from apuracao_ir_csll ai
          where ai.empresa_id              = en_empresa_id 
            and ai.dm_situacao             = 3  -- Processada
            and ai.ano_ref                 = to_number(substr(to_date(ed_dt_fin,'dd/mm/rrrr'),7,4))
            and ai.dm_tipo                 = 'M'  
            and substr(ai.dm_per_apur,2,2) = substr(to_date(ed_dt_fin,'dd/mm/rrrr'),4,2);
      exception
         when others then
            vt_calc_lucro_expl.vl_lucro_real := null;		 
      end;	  
      --
   end if;
   -- VL_LUCRO_REAL - Fim   
   --
   -- QTD_MESES - Inicio
   vn_fase := 5;   
   -- 
   if nvl(vt_calc_lucro_expl.qtd_meses,0) <= 0 then
      --   
      vt_calc_lucro_expl.qtd_meses := to_number(substr(to_date(ed_dt_ini,'dd/mm/rrrr'),4,2)) - to_number(substr(to_date(ed_dt_fin,'dd/mm/rrrr'),4,2)) + 1;
      --
   end if;	  
   -- QTD_MESES - Fim   
   --
   -- VL_BC_ADIC_IRPJ - Inicio
   vn_fase := 6;
   --  
   if nvl(vt_calc_lucro_expl.vl_bc_adic_irpj,0) <= 0 then 
      --   
      begin
         select a.vl_bc_adic_irpj 
           into vt_calc_lucro_expl.vl_bc_adic_irpj   
           from abert_ecf_param_geral a
              , abertura_ecf e
          where e.id                            = a.aberturaecf_id
            and e.empresa_id                    = en_empresa_id
            and e.dm_situacao                  in (4,6)  -- 4-Validado / 6-Gerado Arquivo 
            and to_date(e.dt_ini,'dd/mm/rrrr') >= to_date(ed_dt_ini,'dd/mm/rrrr') 
            and to_date(e.dt_fin,'dd/mm/rrrr') <= to_date(ed_dt_fin,'dd/mm/rrrr');    
      exception
         when no_data_found then
            vt_calc_lucro_expl.vl_bc_adic_irpj := 20000;	  
      end;
      --   
   end if;   
   -- VL_BC_ADIC_IRPJ - Fim
   --   
   -- PERC_IRPJ / PERC_ADIC_IRPJ - Inicio
   vn_fase := 7;
   --
   begin
      select case 
             when nvl(vt_calc_lucro_expl.perc_irpj,0) > 0 then
                 nvl(vt_calc_lucro_expl.perc_irpj,0)
              else				 
	             nvl(a.perc_irpj,0)
             end perc_irpj				 
           , case 
             when nvl(vt_calc_lucro_expl.perc_adic_ir,0) > 0 then
                 nvl(vt_calc_lucro_expl.perc_adic_ir,0)
              else				 
                 nvl(a.perc_adic_irpj,0) 
             end perc_adic_irpj
        into vt_calc_lucro_expl.perc_irpj
           , vt_calc_lucro_expl.perc_adic_ir		
        from abert_ecf_param_geral a
           , abertura_ecf e
       where e.id                            = a.aberturaecf_id
         and e.empresa_id                    = en_empresa_id
         and e.dm_situacao                  in (4,6)  -- 4-Validado / 6-Gerado Arquivo 
         and to_date(e.dt_ini,'dd/mm/rrrr') >= to_date(ed_dt_ini,'dd/mm/rrrr') 
         and to_date(e.dt_fin,'dd/mm/rrrr') <= to_date(ed_dt_fin,'dd/mm/rrrr');  
   exception
      when no_data_found then
         vt_calc_lucro_expl.perc_irpj      := 15;
         vt_calc_lucro_expl.perc_adic_ir   := 10;         		 
   end; 
   -- PERC_IRPJ / PERC_ADIC_IRPJ - Fim 
   --
   -- VL_IR_ADIC - Inicio
   vn_fase := 8;
   --  
   if nvl(vt_calc_lucro_expl.vl_ir_adic,0) <= 0 then 
      --
      begin
         select nvl(ai.vl_adic_ir_lr,0)  
           into vt_calc_lucro_expl.vl_ir_adic		 
           from apuracao_ir_csll ai
          where ai.empresa_id              = en_empresa_id 
            and ai.dm_situacao             = 3  -- Processada
            and ai.ano_ref                 = to_number(substr(to_date(ed_dt_fin,'dd/mm/rrrr'),7,4))
            and ai.dm_tipo                 = 'M'  
            and substr(ai.dm_per_apur,2,2) = substr(to_date(ed_dt_fin,'dd/mm/rrrr'),4,2);
      exception
         when others then
            vt_calc_lucro_expl.vl_ir_adic := null;		 
      end;	  
      --   
   end if;
   --  
   vn_fase := 9;
   --   
   if nvl(vt_calc_lucro_expl.vl_ir_adic,0) <= 0 then 
      --
      vt_calc_lucro_expl.vl_ir_adic := vt_calc_lucro_expl.vl_lucro_real - ((vt_calc_lucro_expl.vl_bc_adic_irpj * vt_calc_lucro_expl.qtd_meses) * vt_calc_lucro_expl.perc_adic_ir);
      --
   end if;   
   -- VL_IR_ADIC - Fim
   -- 
   -- VL_REC_LIQ_TOT - Inicio
   vn_fase := 10;
   -- 
   if vt_calc_lucro_expl.vl_rec_liq_tot <= 0 then 
      --   
      if substr(to_date(ed_dt_fin,'dd/mm/rrrr'),4,2) <> '12' then
         --   
         select sum(valor)
           into vt_calc_lucro_expl.vl_rec_liq_tot
           from ( select case 
                         when s.dm_ind_dc_fin = 'D' then
                           sum(nvl(s.vl_sld_fin,0))*-1
                         when s.dm_ind_dc_fin = 'C' then
                           sum(nvl(s.vl_sld_fin,0))
                         end valor 
                    from int_det_saldo_periodo s
                   where s.empresa_id     = en_empresa_id
                     and to_date(s.dt_ini,'dd/mm/rrrr') >= to_date(ed_dt_ini,'dd/mm/rrrr') 
                     and to_date(s.dt_fim,'dd/mm/rrrr') <= to_date(ed_dt_fin,'dd/mm/rrrr')			 
                     and s.planoconta_id in ( select e.id
                                                from plano_conta_ref_ecd a
                                                   , plano_conta_ref_ecd b
                                                   , plano_conta_ref_ecd c
                                                   , pc_referen          d
                                                   , plano_conta         e
                                               where a.cod_cta_ref            in ('3.01.01.01', '3.11.01.01')
                                                 and a.codentref_id            = 3
                                                 and nvl(a.dt_fin, ed_dt_ini) >= to_date(ed_dt_ini,'dd/mm/rrrr')
                                                 and a.id                      = b.pcrefecd_id_sup
                                                 and b.id                      = c.pcrefecd_id_sup
                                                 and c.id                      = d.planocontarefecd_id
                                                 and c.codentref_id            = d.codentref_id
                                                 and d.planoconta_id           = e.id
                                                 and e.empresa_id              = en_empresa_id
                                                 and e.dm_st_proc              = 1     -- Validada
                                                 and e.dm_situacao             = 1     -- Ativo
                                                 and e.dm_ind_cta              = 'A'   -- Analitica 
                                            )     
                   group by s.dm_ind_dc_fin
                );
      else
         -- 
         select sum(valor)*-1 
           into vt_calc_lucro_expl.vl_rec_liq_tot	  
           from ( select case 
                           when p.dm_ind_dc = 'D' then
                             sum(nvl(p.vl_dc,0))*-1               
                           when p.dm_ind_dc = 'C' then
                            sum(nvl(p.vl_dc,0))
                         end valor
                    from int_partida_lcto  p
                       , int_lcto_contabil l
                   where l.empresa_id                      = en_empresa_id
                     and to_date(l.dt_lcto,'dd/mm/rrrr')  >= to_date(ed_dt_ini,'dd/mm/rrrr') 
                     and to_date(l.dt_lcto,'dd/mm/rrrr')  <= to_date(ed_dt_fin,'dd/mm/rrrr')
                     and l.dm_ind_lcto                     = 'E'
                     and l.dm_st_proc                      = 1 -- validado
                     and p.intlctocontabil_id              = l.id
                     and p.planoconta_id                  in ( select e.id
                                                                from plano_conta_ref_ecd a
                                                                   , plano_conta_ref_ecd b
                                                                   , plano_conta_ref_ecd c
                                                                   , pc_referen          d
                                                                   , plano_conta         e
                                                               where a.cod_cta_ref            in ('3.01.01.01', '3.11.01.01')
                                                                 and a.codentref_id            = 3
                                                                 and nvl(a.dt_fin, ed_dt_ini) >= to_date(ed_dt_ini,'dd/mm/rrrr')
                                                                 and a.id                      = b.pcrefecd_id_sup
                                                                 and b.id                      = c.pcrefecd_id_sup
                                                                 and c.id                      = d.planocontarefecd_id
                                                                 and c.codentref_id            = d.codentref_id
                                                                 and d.planoconta_id           = e.id
                                                                 and e.empresa_id              = en_empresa_id
                                                                 and e.dm_st_proc              = 1     -- Validada
                                                                 and e.dm_situacao             = 1     -- Ativo
                                                                 and e.dm_ind_cta              = 'A'   -- Analitica 
                                                             )   
                   group by p.dm_ind_dc
                ); 
      end if;
      --   
   end if;   
   -- VL_REC_LIQ_TOT - Fim		  
   --    
   -- VL_RED_BENEF_TOT / VL_REC_DEMAIS_ATIV - Inicio  -- Zerando
   vn_fase := 11;
   --   
   vt_calc_lucro_expl.vl_red_benef_tot   := 0;
   vt_calc_lucro_expl.vl_rec_demais_ativ := 0;     
   -- VL_RED_BENEF_TOT / VL_REC_DEMAIS_ATIV - Fim  
   --
   --  Calculo dos campo da tabela "CALC_BENEF_LUCRO_EXPL" --------------------------------------------------
   --
   vn_fase := 12;
   --   
   vt_calc_benef_lucro_expl := null;
   --  
   begin
      --	
      select * 
        into vt_calc_benef_lucro_expl
        from calc_benef_lucro_expl cb
       where cb.perlucrexpl_id = en_perlucrexpl_id
         and cb.empresa_id     = en_empresa_id;	   
      --			   
   exception
      when others then
         null;
   end;	
   --
   vn_fase := 12.1;
   --   
   if vt_calc_benef_lucro_expl.empresa_id is null then
      --
      vt_calc_benef_lucro_expl.empresa_id := en_empresa_id;
      --	  
   end if;
   --   
   vn_fase := 13;
   --
   -- REC_LIQ_ACUM - Inicio
   vd_dt_inicial := null;     
   vd_dt_inicial := to_date('01/01'||ltrim(substr(to_date(ed_dt_fin,'dd/mm/rrrr'),7,4)),'dd/mm/rrrr');
   --   
   begin
      select sum(nvl(rl.vl_receita,0))
        into vt_calc_benef_lucro_expl.rec_liq_acum
        from rec_unid_lucr_expl rl
       where rl.perlucrexpl_id = en_perlucrexpl_id
         and rl.empresa_id     = en_empresa_id
         and to_date(rl.dt_emiss,'dd/mm/rrrr') between to_date(vd_dt_inicial,'dd/mm/rrrr') and to_date(ed_dt_fin,'dd/mm/rrrr'); 
   exception
      when others then
         vt_calc_benef_lucro_expl.rec_liq_acum := null;
   end;
   -- REC_LIQ_ACUM - Final
   --
   -- PERC_PART - Inicio
   vn_fase := 14;
   -- 
   vt_calc_benef_lucro_expl.perc_part := (( vt_calc_benef_lucro_expl.rec_liq_acum / vt_calc_lucro_expl.vl_rec_liq_tot) * 100 );
   -- PERC_PART - Fim 
   --
   -- LUCR_EXPL - Inicio
   vn_fase := 15; 
   --   
   vt_calc_benef_lucro_expl.lucr_expl := (( vt_calc_lucro_expl.tot_lucro_expl * vt_calc_benef_lucro_expl.perc_part ) / 100); 
   -- LUCR_EXPL - Fim 
   --
   -- VL_IRPJ - Inicio
   vn_fase := 16;
   --
   vt_calc_benef_lucro_expl.vl_irpj := (( vt_calc_benef_lucro_expl.lucr_expl * vt_calc_lucro_expl.perc_irpj ) / 100 );
   -- VL_IRPJ - Fim 
   --
   -- DM_FOMA_CALC_IR_ADIC - Inicio
   vn_fase := 17;
   --
   vt_calc_benef_lucro_expl.dm_foma_calc_ir_adic := 'D';
   --   
   if vt_calc_lucro_expl.vl_lucro_real > vt_calc_lucro_expl.tot_lucro_expl then
      --   
      vt_calc_benef_lucro_expl.dm_foma_calc_ir_adic := 'R';
      --	  
   end if;   
   -- DM_FOMA_CALC_IR_ADIC - Fim   
   --
   -- VL_IR_ADIC - Inicial
   vn_fase := 18;
   --   
   if vt_calc_benef_lucro_expl.dm_foma_calc_ir_adic = 'R' then
      --
      vt_calc_benef_lucro_expl.vl_ir_adic := (( vt_calc_benef_lucro_expl.lucr_expl * vt_calc_lucro_expl.vl_ir_adic ) / vt_calc_lucro_expl.vl_lucro_real );      
      --
   else
      --   
      vt_calc_benef_lucro_expl.vl_ir_adic := vt_calc_lucro_expl.vl_rec_liq_tot * vt_calc_benef_lucro_expl.perc_part;   
      --
   end if;
   -- VL_IR_ADIC - Fim
   --
   -- VL_IR_TOTAL - Inicio
   vn_fase := 19;
   --   
   vt_calc_benef_lucro_expl.vl_ir_total := vt_calc_benef_lucro_expl.vl_irpj + vt_calc_benef_lucro_expl.vl_ir_adic; 
   -- VL_IR_TOTAL - Fim
   --
   -- VL_RED_BENEF - Inicio
   vn_fase := 20;
   --
   begin
      select e.perc_red_ir 
        into vn_perc_red_ir
        from empresa_forma_trib e
       where e.empresa_id                                    = en_empresa_id
         and to_date(e.dt_ini,'dd/mm/rrrr')                 >= to_date(ed_dt_ini,'dd/mm/rrrr')
         and (e.dt_fin                                       is null or
		      to_date(nvl(e.dt_fin,ed_dt_fin),'dd/mm/rrrr') <= to_date(ed_dt_fin,'dd/mm/rrrr'));
   exception
      when no_data_found then
         vn_perc_red_ir := null;
   end;
   --
   vn_fase := 20.1;
   --   
   vt_calc_benef_lucro_expl.vl_red_benef := (( vt_calc_benef_lucro_expl.vl_ir_total * nvl(vn_perc_red_ir,1) ) / 100 );  
   -- VL_RED_BENEF - Fim
   --
   -- VL_RED_BENEF_TOT / VL_REC_DEMAIS_ATIV - Inicio  -- Calculando
   vn_fase := 21;
   --   
   vt_calc_lucro_expl.vl_red_benef_tot := vt_calc_benef_lucro_expl.vl_red_benef;   
   --   
   vt_calc_lucro_expl.vl_rec_demais_ativ :=  vt_calc_lucro_expl.vl_rec_liq_tot - vt_calc_lucro_expl.vl_red_benef_tot;
   -- VL_RED_BENEF_TOT / VL_REC_DEMAIS_ATIV - Fim
   -- 
   -- ATUALIZANDO TABELAS  --   VT_CALC_LUCRO_EXPL / CALC_BENEF_LUCRO_EXPL
   vn_fase := 99;
   --
   if vt_calc_lucro_expl.id is null then
      --      
      insert into calc_lucro_expl ( id
                                  , perlucrexpl_id
                                  , tot_lucro_expl
                                  , vl_lucro_real
                                  , qtd_meses
                                  , perc_irpj
                                  , vl_bc_adic_irpj
                                  , perc_adic_ir
                                  , vl_ir_adic
                                  , vl_rec_liq_tot
                                  , vl_red_benef_tot
                                  , vl_rec_demais_ativ
                                  , dm_tipo
                                  )
                           values ( calclucroexpl_seq.nextval
                                  , en_perlucrexpl_id
                                  , vt_calc_lucro_expl.tot_lucro_expl
                                  , vt_calc_lucro_expl.vl_lucro_real
                                  , vt_calc_lucro_expl.qtd_meses
                                  , vt_calc_lucro_expl.perc_irpj
                                  , vt_calc_lucro_expl.vl_bc_adic_irpj
                                  , vt_calc_lucro_expl.perc_adic_ir
                                  , vt_calc_lucro_expl.vl_ir_adic
                                  , vt_calc_lucro_expl.vl_rec_liq_tot
                                  , vt_calc_lucro_expl.vl_red_benef_tot
                                  , vt_calc_lucro_expl.vl_rec_demais_ativ
                                  , 1  -- Calculado 
                                  );
      --								  
   else
      --
      vn_fase := 99.1;
      --	  
      update calc_lucro_expl c   
         set c.tot_lucro_expl     = vt_calc_lucro_expl.tot_lucro_expl
           , c.vl_lucro_real      = vt_calc_lucro_expl.vl_lucro_real
           , c.qtd_meses          = vt_calc_lucro_expl.qtd_meses
           , c.perc_irpj          = vt_calc_lucro_expl.perc_irpj
           , c.vl_bc_adic_irpj    = vt_calc_lucro_expl.vl_bc_adic_irpj
           , c.perc_adic_ir       = vt_calc_lucro_expl.perc_adic_ir
           , c.vl_ir_adic         = vt_calc_lucro_expl.vl_ir_adic
           , c.vl_rec_liq_tot     = vt_calc_lucro_expl.vl_rec_liq_tot
           , c.vl_red_benef_tot   = vt_calc_lucro_expl.vl_red_benef_tot
           , c.vl_rec_demais_ativ =	vt_calc_lucro_expl.vl_rec_demais_ativ  
      where c.id = vt_calc_lucro_expl.id; 		   
      --	  
   end if;
   -- 
   vn_fase := 99.2;
   --
   if vt_calc_benef_lucro_expl.id is null then
      --   
      insert into calc_benef_lucro_expl ( id
                                        , perlucrexpl_id
                                        , empresa_id
                                        , rec_liq_acum
                                        , perc_part
                                        , lucr_expl
                                        , vl_irpj
                                        , dm_foma_calc_ir_adic
                                        , vl_ir_adic
                                        , vl_ir_total
                                        , vl_red_benef
                                        )
                                 values ( calcbeneflucroexpl_seq.nextval
                                        , en_perlucrexpl_id
                                        , vt_calc_benef_lucro_expl.empresa_id										
                                        , vt_calc_benef_lucro_expl.rec_liq_acum										
                                        , vt_calc_benef_lucro_expl.perc_part
                                        , vt_calc_benef_lucro_expl.lucr_expl										
                                        , vt_calc_benef_lucro_expl.vl_irpj
                                        , vt_calc_benef_lucro_expl.dm_foma_calc_ir_adic
                                        , vt_calc_benef_lucro_expl.vl_ir_adic
                                        , vt_calc_benef_lucro_expl.vl_ir_total
                                        , vt_calc_benef_lucro_expl.vl_red_benef
                                        );
      --										
   else
      --
      vn_fase := 99.3;
      --	  
	  update calc_benef_lucro_expl b
         set b.rec_liq_acum         = vt_calc_benef_lucro_expl.rec_liq_acum	
           , b.perc_part            = vt_calc_benef_lucro_expl.perc_part
           , b.lucr_expl            = vt_calc_benef_lucro_expl.lucr_expl
           , b.vl_irpj              = vt_calc_benef_lucro_expl.vl_irpj
           , b.dm_foma_calc_ir_adic = vt_calc_benef_lucro_expl.dm_foma_calc_ir_adic
           , b.vl_ir_adic           = vt_calc_benef_lucro_expl.vl_ir_adic
           , b.vl_ir_total          = vt_calc_benef_lucro_expl.vl_ir_total
           , b.vl_red_benef         = vt_calc_benef_lucro_expl.vl_red_benef
       where b.id = vt_calc_benef_lucro_expl.id; 		   
      -- 	  
   end if;
   --   
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_lucro_expl.pkb_gera_calculo_beneficio fase('||vn_fase||'): '||sqlerrm;
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
end pkb_gera_calculo_beneficio;

-------------------------------------------------------------------------------------------------------
-- Gera calculo utilizando parametros de receita utilizados no calculo do lucro da exploração.
-------------------------------------------------------------------------------------------------------
procedure pkb_gera_calc_param_rec_le ( est_log_generico     in out nocopy  dbms_sql.number_table
                                     , en_perlucrexpl_id    in     per_lucr_expl.id%type
                                     , en_empresa_id        in     per_lucr_expl.empresa_id%type 
                                     , ed_dt_ini            in     per_lucr_expl.dt_ini%type
                                     , ed_dt_fin            in     per_lucr_expl.dt_fim%type									
                                     )
is									
  --
  vn_loggenerico_id               log_generico.id%type;
  vn_fase                         number := null;
  vn_total_nf                     nota_fiscal_total.vl_total_nf%type;                          
  vn_vl_imp_trib                  imp_itemnf.vl_imp_trib%type;
  vn_vl_receita                   rec_unid_lucr_expl.vl_receita%type;
  vn_vl_demais_ativ               rec_unid_lucr_expl.vl_demais_ativ%type;
  vn_vl_docto_fiscal              conhec_transp_vlprest.vl_docto_fiscal%type;
  vn_vl_pis                       ct_comp_doc_pis.vl_pis%type;
  vn_vl_cofins                    ct_comp_doc_cofins.vl_cofins%type;
  --
  cursor c_parreclucrexpl is
     select *
      from param_rec_lucr_expl pr
     where pr.empresa_id = en_empresa_id
       and pr.dm_situacao = 1;   -- ativo
  --  
  cursor c_notas ( en_modfiscal_id      nota_fiscal.modfiscal_id%type
                 , en_cfop_id           item_nota_fiscal.cfop_id%type
                 , en_cd_lista_serv     item_nota_fiscal.cd_lista_serv%type
                 , en_natoper_id        item_nota_fiscal.natoper_id%type ) is
     --				 
     select distinct nf.id notafiscal_id, nc.dt_exe_serv dt_competencia, nf.dt_emiss,  nt.vl_total_nf
       from nota_fiscal       nf
          , mod_fiscal        mf	   
          , nota_fiscal_total nt  
          , item_nota_fiscal  it      
          , nf_compl_serv     nc  
      where nf.empresa_id       = en_empresa_id 
        and nf.dm_st_proc       = 4   -- Autorizada
        and nf.dm_ind_emit      = 0   -- Emissão Propria
        and mf.id               = nf.modfiscal_id
        and mf.cod_mod         in ('99','ND')	-- Serviços / Nota de Debito	
        and nf.modfiscal_id     = en_modfiscal_id
        and nc.notafiscal_id    = nf.id
        and to_date(nvl(nc.dt_exe_serv,nf.dt_emiss),'dd/mm/rrrr') between to_date(ed_dt_ini,'dd/mm/rrrr') and to_date(ed_dt_fin,'dd/mm/rrrr')   
        and nt.notafiscal_id    = nf.id 
        and it.notafiscal_id    = nf.id
        and it.cfop_id          = en_cfop_id  
        and (it.cd_lista_serv is null or pk_csf.fkg_Tipo_Servico_id ( ev_cod_lst => it.cd_lista_serv ) = en_cd_lista_serv) 
        and (it.natoper_id is null or (it.natoper_id is not null and it.natoper_id = en_natoper_id));
  -- 
  cursor c_conhec ( en_modfiscal_id      conhec_transp.modfiscal_id%type
                  , en_cfop_id           ct_reg_anal.cfop_id%type
                  , en_natoper_id        conhec_transp.natoper_id%type ) is
     --				  
     select distinct ct.id conhectransp_id, ct.dt_hr_emissao, ct.dt_exe_serv dt_competencia, cv.vl_docto_fiscal 
       from conhec_transp ct
          , conhec_transp_vlprest cv
          , ct_reg_anal   ra
      where ct.empresa_id      = en_empresa_id
        and ct.dm_st_proc      = 4   -- Autorizado
        and ct.dm_ind_oper     = 0   -- Emissão Propria 
        and to_date(nvl(ct.dt_exe_serv,ct.dt_hr_emissao),'dd/mm/rrrr') between to_date(ed_dt_ini,'dd/mm/rrrr') and to_date(ed_dt_fin,'dd/mm/rrrr')
        and ct.modfiscal_id    = en_modfiscal_id
        and cv.conhectransp_id = ct.id   
        and ra.conhectransp_id = ct.id
        and ra.cfop_id         = en_cfop_id      
        and (ct.natoper_id is null or (ct.natoper_id is not null and ct.natoper_id = en_natoper_id));  
  --  
begin
  --
  vn_fase := 1;
  --
  --
  for rec in c_parreclucrexpl loop
     --
     exit when c_parreclucrexpl%notfound or (c_parreclucrexpl%notfound) is null;
     --
     vn_fase := 2;
     -- 
     -- Notas Fiscais	 
     for rnf in c_notas( rec.modfiscal_id, rec.cfop_id, rec.tiposervico_id, rec.natoper_id ) loop
        --
        exit when c_notas%notfound or (c_notas%notfound) is null;
        --
        vn_fase := 2.1;
        --	
        vn_total_nf       := 0;
        vn_vl_receita     := 0;
        vn_vl_demais_ativ := 0;		
        --		
        vn_total_nf := rnf.vl_total_nf;
        --		
        vn_vl_imp_trib    := 0;		   
        --
        vn_fase := 2.2;
        --		   
        begin
           select sum(nvl(ip.vl_imp_trib,0)) vl_imposto
             into vn_vl_imp_trib
             from item_nota_fiscal it
                , imp_itemnf       ip
                , tipo_imposto     ti       
            where it.notafiscal_id = rnf.notafiscal_id
              and ip.itemnf_id     = it.id
              and ip.dm_tipo       = 0      -- Imposto
              and ti.id            = ip.tipoimp_id
              and ti.id           in (4,5);  -- Pis/Cofins 		   
        exception
           when others then
              vn_vl_imp_trib := 0;
        end;
        --		   
        vn_total_nf := vn_total_nf - vn_vl_imp_trib;
        --
        if rec.dm_rec_incent = 1 then -- receita é incentivada e fará parte do calculo do beneficio de redução de IR. Valores: 0= Não / 1= Sim
           --
           vn_vl_receita := vn_total_nf;
           --		   
        else
           --		
           vn_vl_demais_ativ := vn_total_nf;
           --		   
        end if;
        --		
        begin
           --
           insert into rec_unid_lucr_expl ( id
                                          , perlucrexpl_id
                                          , empresa_id
                                          , dt_emiss
                                          , dt_competencia
                                          , vl_receita
                                          , vl_demais_ativ
                                          , obj_referencia
                                          , referencia_id
                                          , paramreclucrexpl_id
                                          )
                                   values ( recunidlucrexpl_seq.nextval 
                                          , en_perlucrexpl_id
                                          , en_empresa_id											 
                                          , rnf.dt_emiss
                                          , nvl(rnf.dt_competencia,rnf.dt_emiss)
                                          , vn_vl_receita
                                          , vn_vl_demais_ativ
                                          , 'NOTA_FISCAL'
                                          , rnf.notafiscal_id
                                          , rec.id
                                          );
           --
        exception
           when others then
              --
              gv_mensagem := 'Erro na gravação no calculo de receita por unidade considerada no lucro da exploração, '||
                             'parâmetro ID: '||rec.id||'- Empresa ID: '||en_empresa_id||'.'||
                             ' pk_gera_lucro_expl.pkb_gera_calc_param_rec_le fase('||vn_fase||'): '||sqlerrm;
              --
              declare
                 vn_loggenerico_id  log_generico.id%TYPE;
              begin
                 --
                 pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
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
     end loop;
     --
     vn_fase := 3;
     -- 
     -- Conhecimento de Transporte 
     for rct in c_conhec( rec.modfiscal_id, rec.cfop_id, rec.natoper_id ) loop
        --
        exit when c_conhec%notfound or (c_conhec%notfound) is null;
        --
        vn_fase := 3.1;
        --	
        vn_vl_docto_fiscal := 0;
        vn_vl_receita      := 0;
        vn_vl_demais_ativ  := 0;		
        --	
        vn_vl_docto_fiscal := rct.vl_docto_fiscal;
        --
        vn_vl_pis          := 0;
        vn_vl_cofins       := 0;
        --
        vn_fase := 3.2;
        -- 
        begin		  
           select sum(nvl(p.vl_pis,0)) vl_pis  
             into vn_vl_pis		   
             from ct_comp_doc_pis p
            where p.conhectransp_id = rct.conhectransp_id;
        exception
           when others then
              vn_vl_pis := 0;		   
        end;
        --
        vn_fase := 3.3;
        --]
        begin
           select sum(nvl(c.vl_cofins,0)) vl_cofins 
		     into vn_vl_cofins
             from ct_comp_doc_cofins c
            where c.conhectransp_id = rct.conhectransp_id;	
        exception
           when others then
              vn_vl_cofins := 0;		   
        end;
        --		
        vn_vl_docto_fiscal := vn_vl_docto_fiscal - vn_vl_pis - vn_vl_cofins;
        --		
        if rec.dm_rec_incent = 1 then -- receita é incentivada e fará parte do calculo do beneficio de redução de IR. Valores: 0= Não / 1= Sim
           --
           vn_vl_receita := vn_vl_docto_fiscal;
           --		   
        else
           --		
           vn_vl_demais_ativ := vn_vl_docto_fiscal;
           --		   
        end if;
        --	
        vn_fase := 3.4;
        --		
        begin
           --
           insert into rec_unid_lucr_expl ( id
                                          , perlucrexpl_id
                                          , empresa_id
                                          , dt_emiss
                                          , dt_competencia
                                          , vl_receita
                                          , vl_demais_ativ
                                          , obj_referencia
                                          , referencia_id
                                          , paramreclucrexpl_id
                                          )
                                   values ( recunidlucrexpl_seq.nextval 
                                          , en_perlucrexpl_id
                                          , en_empresa_id											 
                                          , rct.dt_hr_emissao
                                          , nvl(rct.dt_competencia,rct.dt_hr_emissao)
                                          , vn_vl_receita
                                          , vn_vl_demais_ativ
                                          , 'CONHEC_TRANSP'
                                          , rct.conhectransp_id
                                          , rec.id
                                          );
           --
        exception
           when others then
              --
              gv_mensagem := 'Erro na gravação no calculo de receita por unidade considerada no lucro da exploração, '||
                             'parâmetro ID: '||rec.id||'- Empresa ID: '||en_empresa_id||'.'||
                             ' pk_gera_lucro_expl.pkb_gera_calc_param_rec_le fase('||vn_fase||'): '||sqlerrm;
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
     end loop;
     --
  end loop;  -- c_parreclucrexpl
  --  
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_lucro_expl.pkb_gera_calc_por_cod_din fase('||vn_fase||'): '||sqlerrm;
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
end pkb_gera_calc_param_rec_le;

-------------------------------------------------------------------------------------------------------
-- Gera calculo utilizando depara entre os códigos dinamicos e plano de contas utilizados no calculo do 
-- lucro da exploração.
-------------------------------------------------------------------------------------------------------
procedure pkb_gera_calc_por_cod_din ( est_log_generico     in out nocopy  dbms_sql.number_table
                                    , en_perlucrexpl_id    in     per_lucr_expl.id%type
                                    , en_empresa_id        in     per_lucr_expl.empresa_id%type 
                                    , ed_dt_ini            in     per_lucr_expl.dt_ini%type
                                    , ed_dt_fin            in     per_lucr_expl.dt_fim%type									
                                    )
is									
  --
  vn_loggenerico_id               log_generico.id%type;
  vn_fase                         number := null;
  vt_param_dp_coddin_cta_lucexp   param_dp_coddin_cta_lucr_expl%rowtype;           
  vt_crit_pesq_sld_lucr_expl      crit_pesq_sld_lucr_expl%rowtype;
  vt_crit_pesq_lcto_lucr_expl     crit_pesq_lcto_lucr_expl%rowtype;
  vt_formula_cod_din_lucexp       formula_cod_din_lucexp%rowtype;
  vn_valor                        apur_lucro_expl.valor%type;
  vn_so_editavel                  number := null;  
  --
  cursor c_coddinluexp is
     select cl.id coddinlucrexpl_id, cl.descr, cl.dm_tipo, cl.formulacoddinlucexp_id, 
            al.id apurlucroexpl_id
       from apur_lucro_expl   al
          , cod_din_lucr_expl cl       
      where al.perlucrexpl_id   = en_perlucrexpl_id
        and cl.id               = al.coddinlucrexpl_id
        and cl.dm_situacao      = 1  -- Ativo		
      order by cl.linha;   
  --  
  cursor c_saldo is
    select case 
             when vt_crit_pesq_sld_lucr_expl.dm_col_origem = 'I' then   -- Saldo inicial
               case 
                 when i.dm_ind_dc_ini = 'D' then
                   sum(nvl(i.vl_sld_ini,0))*-1               
                 when i.dm_ind_dc_ini = 'C' then
                   sum(nvl(i.vl_sld_ini,0))
               end  
             when vt_crit_pesq_sld_lucr_expl.dm_col_origem = 'F' then   -- Saldo final
               case 
                 when i.dm_ind_dc_fin = 'D' then
                   sum(nvl(i.vl_sld_fin,0))*-1
                 when i.dm_ind_dc_fin = 'C' then
                   sum(nvl(i.vl_sld_fin,0))
               end
             when vt_crit_pesq_sld_lucr_expl.dm_col_origem = 'D' then   -- Saldo a Débito
               sum(nvl(i.vl_deb,0))*-1
             when vt_crit_pesq_sld_lucr_expl.dm_col_origem = 'C' then   -- Saldo a Crédito
               sum(nvl(i.vl_cred,0))
             when vt_crit_pesq_sld_lucr_expl.dm_col_origem = 'M' then   -- Movimento (diferença entre Deb - Cred)                                   
               sum(nvl(i.vl_deb,0)-nvl(i.vl_cred,0))*-1
           end valor,
           i.id referencia_id              
      from int_det_saldo_periodo i            
     where i.empresa_id             = en_empresa_id 
       and i.dt_ini                >= ed_dt_ini
       and i.dt_fim                <= ed_dt_fin
       and i.dm_st_proc             = 1 -- validado
       and i.planoconta_id          = vt_param_dp_coddin_cta_lucexp.planoconta_id
       and vt_param_dp_coddin_cta_lucexp.centrocusto_id is null
     group by i.dm_ind_dc_ini
         , i.dm_ind_dc_fin 
         , i.id  
     union
    select case 
             when vt_crit_pesq_sld_lucr_expl.dm_col_origem = 'I' then   -- Saldo inicial
               case 
                 when i.dm_ind_dc_ini = 'D' then
                   sum(nvl(i.vl_sld_ini,0))*-1               
                 when i.dm_ind_dc_ini = 'C' then
                   sum(nvl(i.vl_sld_ini,0))
               end  
             when vt_crit_pesq_sld_lucr_expl.dm_col_origem = 'F' then   -- Saldo final
               case 
                 when i.dm_ind_dc_fin = 'D' then
                   sum(nvl(i.vl_sld_fin,0))*-1
                 when i.dm_ind_dc_fin = 'C' then
                   sum(nvl(i.vl_sld_fin,0))
               end
             when vt_crit_pesq_sld_lucr_expl.dm_col_origem = 'D' then   -- Saldo a Débito
               sum(nvl(i.vl_deb,0))*-1
             when vt_crit_pesq_sld_lucr_expl.dm_col_origem = 'C' then   -- Saldo a Crédito
               sum(nvl(i.vl_cred,0))
             when vt_crit_pesq_sld_lucr_expl.dm_col_origem = 'M' then   -- Movimento (diferença entre Deb - Cred)                                   
               sum(nvl(i.vl_deb,0)-nvl(i.vl_cred,0))*-1
           end valor,
           i.id referencia_id              
      from int_det_saldo_periodo i            
     where i.empresa_id             = en_empresa_id 
       and i.dt_ini                >= ed_dt_ini
       and i.dt_fim                <= ed_dt_fin
       and i.dm_st_proc             = 1 -- validado
       and i.planoconta_id          = vt_param_dp_coddin_cta_lucexp.planoconta_id
       and vt_param_dp_coddin_cta_lucexp.centrocusto_id is not null       
       and nvl(i.centrocusto_id,-1) = nvl(vt_param_dp_coddin_cta_lucexp.centrocusto_id,-1) 
     group by i.dm_ind_dc_ini
         , i.dm_ind_dc_fin 
         , i.id; 
  -- 
  cursor c_lancto is
    select case 
             when p.dm_ind_dc = 'D' then
               sum(nvl(p.vl_dc,0))*-1               
             when p.dm_ind_dc = 'C' then
               sum(nvl(p.vl_dc,0))
           end valor,  
           l.id referencia_id
      from int_partida_lcto  p
         , int_lcto_contabil l
     where l.empresa_id         = en_empresa_id
       and l.dt_lcto           >= ed_dt_ini
       and l.dt_lcto           <= ed_dt_fin
       and l.dm_ind_lcto        = vt_crit_pesq_lcto_lucr_expl.dm_ind_lcto
       and l.dm_st_proc         = 1 -- validado
       and p.intlctocontabil_id = l.id
       and p.planoconta_id      = vt_param_dp_coddin_cta_lucexp.planoconta_id
       and vt_param_dp_coddin_cta_lucexp.centrocusto_id is null
       and ( vt_crit_pesq_lcto_lucr_expl.num_arq is not null and 
             p.num_arq like vt_crit_pesq_lcto_lucr_expl.num_arq )
       and ( vt_crit_pesq_lcto_lucr_expl.compl_hist is not null and
             p.compl_hist like vt_crit_pesq_lcto_lucr_expl.compl_hist )
     group by p.dm_ind_dc
            , l.id         
     union     
    select case 
             when p.dm_ind_dc = 'D' then
               sum(nvl(p.vl_dc,0))*-1               
             when p.dm_ind_dc = 'C' then
               sum(nvl(p.vl_dc,0))
           end valor,  
           l.id referencia_id 
      from int_partida_lcto  p
         , int_lcto_contabil l
     where l.empresa_id             = en_empresa_id
       and l.dt_lcto               >= ed_dt_ini
       and l.dt_lcto               <= ed_dt_fin
       and l.dm_ind_lcto            = vt_crit_pesq_lcto_lucr_expl.dm_ind_lcto
       and l.dm_st_proc             = 1 -- validado
       and p.intlctocontabil_id     = l.id
       and p.planoconta_id          = vt_param_dp_coddin_cta_lucexp.planoconta_id
       and vt_param_dp_coddin_cta_lucexp.centrocusto_id is not null
       and nvl(p.centrocusto_id,-1) = nvl(vt_param_dp_coddin_cta_lucexp.centrocusto_id,-1)
       and ( vt_crit_pesq_lcto_lucr_expl.num_arq is not null and 
             p.num_arq like vt_crit_pesq_lcto_lucr_expl.num_arq )
       and ( vt_crit_pesq_lcto_lucr_expl.compl_hist is not null and
             p.compl_hist like vt_crit_pesq_lcto_lucr_expl.compl_hist )
     group by p.dm_ind_dc
            , l.id;   
  --   
begin
  --
  vn_fase := 1;
  --
  pkb_carrega_apurlucroexp ( en_perlucrexpl_id   =>   en_perlucrexpl_id 
                           , en_multorg_id       =>   gn_multorg_id );
  --
  for rec in c_coddinluexp loop
     --
     exit when c_coddinluexp%notfound or (c_coddinluexp%notfound) is null;
     --
     vn_fase := 4;
     -- 		
     if rec.dm_tipo = 'E' then  -- Editável
        --
        vn_fase := 4.2;
        --
        vt_param_dp_coddin_cta_lucexp := null;
        --		   
        begin
           --		   
           select * 
             into vt_param_dp_coddin_cta_lucexp			  
             from param_dp_coddin_cta_lucr_expl p
            where p.coddinlucrexpl_id = rec.coddinlucrexpl_id; 
           --			   
        exception
           when others then
            --
            gv_mensagem := 'Não encontrado parâmetro De Para para cadastro dinâmico: '||rec.coddinlucrexpl_id||'-'||rec.descr||'.'||
                           ' pk_gera_lucro_expl.pkb_gera_calc_por_cod_din fase('||vn_fase||'): '||sqlerrm;
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
            goto sair_rotina;
            --			   
        end;
        --	
        if vt_param_dp_coddin_cta_lucexp.dm_tb_origem = 'S' then  -- Saldo
           --
           vn_fase := 4.3;
           --
           vt_crit_pesq_sld_lucr_expl := null;
           --		   
           begin
              --		   
              select * 
                into vt_crit_pesq_sld_lucr_expl			  
                from crit_pesq_sld_lucr_expl c           
               where c.paramdpcoddinctale_id = vt_param_dp_coddin_cta_lucexp.id; 
              --			   
           exception
              when others then
               --
               gv_mensagem := 'Não encontrado critério de pesquisa saldo para parâmetro De Para para cadastro dinâmico: '||rec.coddinlucrexpl_id||'-'||rec.descr||'-'||
                              ' Parâmetro De Para ID: '||vt_param_dp_coddin_cta_lucexp.id||'. pk_gera_lucro_expl.pkb_gera_calc_por_cod_din fase('||vn_fase||'): '||sqlerrm;
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
               goto sair_rotina;
               --			   
           end;
           --	
           vn_fase := 4.4;
           --	
           for reg in c_saldo loop
              --
              exit when c_saldo%notfound or (c_saldo%notfound) is null;
              --
              if vt_crit_pesq_sld_lucr_expl.dm_tipo_vlr_calc = 'N' then     -- Normal (conforme resultado)
                 --
                 vn_fase := 4.5;		   
                 --
                 pkb_insere_val_apuracao ( en_perlucrexpl_id      =>   en_perlucrexpl_id
                                         , en_coddinlucrexpl_id   =>   rec.coddinlucrexpl_id
                                         , en_valor               =>   reg.valor );
                 --	
                 pkb_insere_mem_calc ( en_perlucrexpl_id          =>   en_perlucrexpl_id
                                     , en_paramdpcoddinctale_id   =>   vt_param_dp_coddin_cta_lucexp.id
                                     , en_planoconta_id           =>   vt_param_dp_coddin_cta_lucexp.planoconta_id
                                     , en_centrocusto_id          =>   vt_param_dp_coddin_cta_lucexp.centrocusto_id
                                     , ev_dm_tb_origem            =>   vt_param_dp_coddin_cta_lucexp.dm_tb_origem
                                     , ev_dm_tipo_vlr_calc        =>   vt_crit_pesq_sld_lucr_expl.dm_tipo_vlr_calc
                                     , en_valor                   =>   reg.valor 
                                     , ev_descr                   =>   rec.descr );					
                 --				 
              elsif vt_crit_pesq_sld_lucr_expl.dm_tipo_vlr_calc = 'D' then  -- Deverdor
                 --
                 if reg.valor < 0 then				 
                    --
                    vn_fase := 4.6;		   
                    --
                    pkb_insere_val_apuracao ( en_perlucrexpl_id      =>   en_perlucrexpl_id
                                            , en_coddinlucrexpl_id   =>   rec.coddinlucrexpl_id
                                            , en_valor               =>   reg.valor );
                    --
                    pkb_insere_mem_calc ( en_perlucrexpl_id          =>   en_perlucrexpl_id
                                        , en_paramdpcoddinctale_id   =>   vt_param_dp_coddin_cta_lucexp.id
                                        , en_planoconta_id           =>   vt_param_dp_coddin_cta_lucexp.planoconta_id
                                        , en_centrocusto_id          =>   vt_param_dp_coddin_cta_lucexp.centrocusto_id
                                        , ev_dm_tb_origem            =>   vt_param_dp_coddin_cta_lucexp.dm_tb_origem
                                        , ev_dm_tipo_vlr_calc        =>   vt_crit_pesq_sld_lucr_expl.dm_tipo_vlr_calc
                                        , en_valor                   =>   reg.valor 
                                        , ev_descr                   =>   rec.descr );					
                    --					
                 end if;
                 --				   
              elsif vt_crit_pesq_sld_lucr_expl.dm_tipo_vlr_calc = 'C' then  -- Credor			  
                 --
                 if reg.valor >= 0 then
                    --
                    vn_fase := 4.7;		   
                    --
                    pkb_insere_val_apuracao ( en_perlucrexpl_id      =>   en_perlucrexpl_id
                                            , en_coddinlucrexpl_id   =>   rec.coddinlucrexpl_id
                                            , en_valor               =>   reg.valor );
                    --	
                    pkb_insere_mem_calc ( en_perlucrexpl_id          =>   en_perlucrexpl_id
                                        , en_paramdpcoddinctale_id   =>   vt_param_dp_coddin_cta_lucexp.id
                                        , en_planoconta_id           =>   vt_param_dp_coddin_cta_lucexp.planoconta_id
                                        , en_centrocusto_id          =>   vt_param_dp_coddin_cta_lucexp.centrocusto_id
                                        , ev_dm_tb_origem            =>   vt_param_dp_coddin_cta_lucexp.dm_tb_origem
                                        , ev_dm_tipo_vlr_calc        =>   vt_crit_pesq_sld_lucr_expl.dm_tipo_vlr_calc
                                        , en_valor                   =>   reg.valor 
                                        , ev_descr                   =>   rec.descr );					
                    --					
                 end if;
                 --				 
              end if;
              --		
           end loop;	 -- c_saldo	
           --	
        elsif vt_param_dp_coddin_cta_lucexp.dm_tb_origem = 'L' then  -- Lançamento
           --
           vn_fase := 4.3;
           --
           vt_crit_pesq_lcto_lucr_expl := null;
           --		  
           begin
              --		   
              select * 
                into vt_crit_pesq_lcto_lucr_expl			  
                from crit_pesq_lcto_lucr_expl c     
               where c.paramdpcoddinctale_id = vt_param_dp_coddin_cta_lucexp.id; 
              --			   
           exception
              when others then
               --
               gv_mensagem := 'Não encontrado critério de pesquisa de Lancto. para parâmetro De Para para cadastro dinâmico: '||rec.coddinlucrexpl_id||'-'||rec.descr||'-'||
                              ' Parâmetro De Para ID: '||vt_param_dp_coddin_cta_lucexp.id||'. pk_gera_lucro_expl.pkb_gera_calc_por_cod_din fase('||vn_fase||'): '||sqlerrm;
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
               goto sair_rotina;
               --			   
           end;
           --
           for lct in c_lancto loop
              --
              exit when c_lancto%notfound or (c_lancto%notfound) is null;
              --
              --
              if vt_crit_pesq_lcto_lucr_expl.dm_tipo_vlr_calc = 'N' then     -- Normal (conforme resultado)
                 --
                 vn_fase := 4.5;		   
                 --
                 pkb_insere_val_apuracao ( en_perlucrexpl_id      =>   en_perlucrexpl_id
                                         , en_coddinlucrexpl_id   =>   rec.coddinlucrexpl_id
                                         , en_valor               =>   lct.valor );
                 --	
                 pkb_insere_mem_calc ( en_perlucrexpl_id          =>   en_perlucrexpl_id
                                     , en_paramdpcoddinctale_id   =>   vt_param_dp_coddin_cta_lucexp.id
                                     , en_planoconta_id           =>   vt_param_dp_coddin_cta_lucexp.planoconta_id
                                     , en_centrocusto_id          =>   vt_param_dp_coddin_cta_lucexp.centrocusto_id
                                     , ev_dm_tb_origem            =>   vt_param_dp_coddin_cta_lucexp.dm_tb_origem
                                     , ev_dm_tipo_vlr_calc        =>   vt_crit_pesq_lcto_lucr_expl.dm_tipo_vlr_calc
                                     , en_valor                   =>   lct.valor 
                                     , ev_descr                   =>   rec.descr );					
                 --				 
              elsif vt_crit_pesq_lcto_lucr_expl.dm_tipo_vlr_calc = 'D' then  -- Deverdor
                 --
                 if lct.valor < 0 then				 
                    --
                    vn_fase := 4.6;		   
                    --
                    pkb_insere_val_apuracao ( en_perlucrexpl_id      =>   en_perlucrexpl_id
                                            , en_coddinlucrexpl_id   =>   rec.coddinlucrexpl_id
                                            , en_valor               =>   lct.valor );
                    --	
                    pkb_insere_mem_calc ( en_perlucrexpl_id          =>   en_perlucrexpl_id
                                        , en_paramdpcoddinctale_id   =>   vt_param_dp_coddin_cta_lucexp.id
                                        , en_planoconta_id           =>   vt_param_dp_coddin_cta_lucexp.planoconta_id
                                        , en_centrocusto_id          =>   vt_param_dp_coddin_cta_lucexp.centrocusto_id
                                        , ev_dm_tb_origem            =>   vt_param_dp_coddin_cta_lucexp.dm_tb_origem
                                        , ev_dm_tipo_vlr_calc        =>   vt_crit_pesq_lcto_lucr_expl.dm_tipo_vlr_calc
                                        , en_valor                   =>   lct.valor 
                                        , ev_descr                   =>   rec.descr );					
                    --                 					
                 end if;
                 --				   
              elsif vt_crit_pesq_lcto_lucr_expl.dm_tipo_vlr_calc = 'C' then  -- Credor			  
                 --
                 if lct.valor >= 0 then
                    --
                    vn_fase := 4.7;		   
                    --
                    pkb_insere_val_apuracao ( en_perlucrexpl_id      =>   en_perlucrexpl_id
                                            , en_coddinlucrexpl_id   =>   rec.coddinlucrexpl_id
                                            , en_valor               =>   lct.valor );
                    --
                    pkb_insere_mem_calc ( en_perlucrexpl_id          =>   en_perlucrexpl_id
                                        , en_paramdpcoddinctale_id   =>   vt_param_dp_coddin_cta_lucexp.id
                                        , en_planoconta_id           =>   vt_param_dp_coddin_cta_lucexp.planoconta_id
                                        , en_centrocusto_id          =>   vt_param_dp_coddin_cta_lucexp.centrocusto_id
                                        , ev_dm_tb_origem            =>   vt_param_dp_coddin_cta_lucexp.dm_tb_origem
                                        , ev_dm_tipo_vlr_calc        =>   vt_crit_pesq_lcto_lucr_expl.dm_tipo_vlr_calc
                                        , en_valor                   =>   lct.valor 
                                        , ev_descr                   =>   rec.descr );					
                    --                 					
                 end if;
                 --				 
              end if;
              --	
           end loop;  -- c_lancto
           --
        end if; 
        --            		   
     elsif rec.dm_tipo = 'F' then  -- Fórmula		   
        --
        vn_fase := 4.9;
        --
        if rec.formulacoddinlucexp_id is not null then	
           -- 
           vn_fase := 4.10;
           --			  
           vt_formula_cod_din_lucexp := null;
           --		   
           begin
              --		   
              select * 
                into vt_formula_cod_din_lucexp			  
                from formula_cod_din_lucexp f
               where f.id = rec.formulacoddinlucexp_id; 
              --			   
           exception
              when others then
               --
               gv_mensagem := 'Não encontrada fórmula para campo tipo fórmula para cadastro dinâmico ID: '||rec.coddinlucrexpl_id||' - '||rec.descr||'.'||
                              ' pk_gera_lucro_expl.pkb_gera_calc_por_cod_din fase('||vn_fase||'): '||sqlerrm;
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
               goto sair_rotina;
               --			   
           end;
           --
           vn_valor       := null;
           vn_so_editavel := null;			  
           --	
           begin
              --
              select count(1)
                into vn_so_editavel				 
                from itformula_cod_din_lucexp i    
                   , cod_din_lucr_expl        c
               where i.formulacoddinlucexp_id = vt_formula_cod_din_lucexp.id
                 and c.id                     = i.coddinlucrexpl_id				   
                 and c.dm_tipo               <> 'E';  -- Editável
              --			  
           exception
              when others then
                 vn_so_editavel := null;
           end;
           --
           vn_fase := 4.11;
           --
           if nvl(vn_so_editavel,0) = 0 then  -- só editavel
              --		
              vn_valor := fkg_calcula_valor_editavel ( est_formula_cod_din_lucexp  => vt_formula_cod_din_lucexp
                                                     , en_perlucrexpl_id           => en_perlucrexpl_id );
              --
              pkb_insere_val_apuracao ( en_perlucrexpl_id      =>   en_perlucrexpl_id
                                      , en_coddinlucrexpl_id   =>   rec.coddinlucrexpl_id
                                      , en_valor               =>   vn_valor );
              --
           else
              --                
              vn_fase := 4.12;                				 
              --				 
              vn_valor := fkg_calcula_formula ( est_formula_cod_din_lucexp  => vt_formula_cod_din_lucexp
                                              , en_perlucrexpl_id           => en_perlucrexpl_id );
              --				 
              pkb_insere_val_apuracao ( en_perlucrexpl_id      =>   en_perlucrexpl_id
                                      , en_coddinlucrexpl_id   =>   rec.coddinlucrexpl_id
                                      , en_valor               =>   vn_valor );
              --
           end if;			  
           --			  
        end if;
        --		   
     end if;
     --		
  end loop;  -- c_coddinluexp
  --  
  <<sair_rotina>>
  null;
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_lucro_expl.pkb_gera_calc_por_cod_din fase('||vn_fase||'): '||sqlerrm;
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
end pkb_gera_calc_por_cod_din;

-------------------------------------------------------------------------------------------------------
-- Procedimento para Gerar lucro na exploração
-------------------------------------------------------------------------------------------------------
procedure pkb_gerar ( en_perlucrexpl_id    in     per_lucr_expl.id%type
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
      where pl.id          = en_perlucrexpl_id
        and pl.dm_situacao = 0;  -- Aberto  	 
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
     gv_mensagem := 'Periodo de geração de Lucro Exploração ('||to_date(gt_row_per_lucr_expl.dt_ini,'dd/mm/rrrr')||' a '||to_date(gt_row_per_lucr_expl.dt_fim,'dd/mm/rrrr')||') para empresa ID: '||gt_row_per_lucr_expl.empresa_id||', não aberto. pk_gera_lucro_expl.pkb_gerar fase('||vn_fase||'): '||sqlerrm;
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
     vn_fase := 3;
     --	 
     gn_empresa_id    := gt_row_per_lucr_expl.empresa_id;
     gn_referencia_id := gt_row_per_lucr_expl.id; 
     --   
     vn_fase := 4;
     --  
     gn_multorg_id := pk_csf.fkg_multorg_id_empresa ( en_empresa_id => gt_row_per_lucr_expl.empresa_id );
     --
     vn_fase := 5;
     -- 
     gv_mensagem := 'Iniciando geração de Lucro Exploração Empresa: '||gt_row_per_lucr_expl.empresa_id||
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
     vn_fase := 6;
     --	    
     pkb_atuliza_sit_periodo ( en_perlucrexpl_id  => gt_row_per_lucr_expl.id
                             , en_dm_situacao     => 1 );    -- Em processamento
     --	 
     vn_fase := 7;	 
     --	 
     commit;
     --	 
     -- Gera calculo utilizando depara entre os códigos dinamicos e plano de contas utilizados no calculo do 
     -- lucro da exploração.
     pkb_gera_calc_por_cod_din ( est_log_generico    =>  vt_log_generico
                               , en_perlucrexpl_id   =>  gt_row_per_lucr_expl.id
                               , en_empresa_id       =>  gt_row_per_lucr_expl.empresa_id 
                               , ed_dt_ini           =>  gt_row_per_lucr_expl.dt_ini
                               , ed_dt_fin           =>  gt_row_per_lucr_expl.dt_fim );
     --							   
     -- Gera calculo utilizando parametros de receita utilizados no calculo do lucro da exploração.
     pkb_gera_calc_param_rec_le	( est_log_generico    =>  vt_log_generico
                                , en_perlucrexpl_id   =>  gt_row_per_lucr_expl.id
                                , en_empresa_id       =>  gt_row_per_lucr_expl.empresa_id 
                                , ed_dt_ini           =>  gt_row_per_lucr_expl.dt_ini
                                , ed_dt_fin           =>  gt_row_per_lucr_expl.dt_fim ); 
     -- 
     -- Gera calculo do Benefício 
     pkb_gera_calculo_beneficio ( est_log_generico    =>  vt_log_generico
                                , en_perlucrexpl_id   =>  gt_row_per_lucr_expl.id
                                , en_empresa_id       =>  gt_row_per_lucr_expl.empresa_id 
                                , ed_dt_ini           =>  gt_row_per_lucr_expl.dt_ini
                                , ed_dt_fin           =>  gt_row_per_lucr_expl.dt_fim ); 
     --	 
     if nvl(vt_log_generico.count,0) > 0 and
        pk_csf_secf.fkg_ver_erro_log_generico_ecf( en_referencia_id => gn_referencia_id ) = 1 then  -- 0-só advertencia / 1-erro
        --
        vn_fase := 7.1;
        --     	
        pkb_atuliza_sit_periodo ( en_perlucrexpl_id  => gt_row_per_lucr_expl.id
                                , en_dm_situacao     => 4 );    -- Erro de Calculo
        --
     else
        --
        vn_fase := 7.1;
        --     	
        pkb_atuliza_sit_periodo ( en_perlucrexpl_id  => gt_row_per_lucr_expl.id
                                , en_dm_situacao     => 2 );    -- Calculado
        --
     end if;
     --  
     vn_fase := 99;
     --
     gv_mensagem := 'Finalizado geração de período de apuração ID: '||gt_row_per_lucr_expl.id||', Empresa: '||gt_row_per_lucr_expl.empresa_id||
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
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_lucro_expl.pkb_gerar fase('||vn_fase||'): '||sqlerrm;
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
end pkb_gerar;

-------------------------------------------------------------------------------------------------------
-- Validar os calculos para o Lucro da Exploração.
-------------------------------------------------------------------------------------------------------
procedure pkb_validar ( est_log_generico     in out nocopy  dbms_sql.number_table
                      , en_perlucrexpl_id    in     per_lucr_expl.id%type
                      )					  
is
  --
  vn_loggenerico_id          log_generico.id%type;
  vn_fase                    number := null; 
  vn_existe                  number;  
  vn_mes                     number(2);
  vn_ano                     number(4);
  --
begin
   --
   vn_fase := 1;
   --
   gt_row_per_lucr_expl := null;
   --   
   begin
      select *
        into gt_row_per_lucr_expl
        from per_lucr_expl p
       where p.id = en_perlucrexpl_id;
   exception
      when others then
         gt_row_per_lucr_expl := null;
   end;   
   --
   if nvl( gt_row_per_lucr_expl.dm_situacao, 0 ) <> 2 then
      --
      gv_mensagem := 'Lucro Exploração ('||to_date(gt_row_per_lucr_expl.dt_ini,'dd/mm/rrrr')||' a '||to_date(gt_row_per_lucr_expl.dt_fim,'dd/mm/rrrr')||') para empresa ID: '||gt_row_per_lucr_expl.empresa_id;
      gv_resumo   := 'Período não está como DM_SITUACAO 2-Calculado. Necessário Calcular período primeiro. pk_gera_lucro_expl.pkb_validar fase('||vn_fase||').';
      --
      declare
         vn_loggenerico_id  log_generico.id%TYPE;
      begin
         --
         pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id   => vn_loggenerico_id
                                          , ev_mensagem         => gv_mensagem
                                          , ev_resumo           => gv_resumo
                                          , en_tipo_log         => ERRO_DE_VALIDACAO
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
      goto sair_valida;	  
      --	  
   else
      --   
      vn_fase := 2;
      --
      gn_empresa_id    := gt_row_per_lucr_expl.empresa_id;
      gn_referencia_id := gt_row_per_lucr_expl.id; 		 
      --	  
      vn_existe := null;
      -- 	  
      begin
         select count(1)
           into vn_existe
           from apur_lucro_expl a
          where a.perlucrexpl_id = en_perlucrexpl_id; 
      exception
         when others then
            vn_existe := null;		 
      end;
      --
      if nvl(vn_existe,0) = 0 then
         --
         gv_mensagem := 'Lucro Exploração ('||to_date(gt_row_per_lucr_expl.dt_ini,'dd/mm/rrrr')||' a '||to_date(gt_row_per_lucr_expl.dt_fim,'dd/mm/rrrr')||') para empresa ID: '||gt_row_per_lucr_expl.empresa_id;
         gv_resumo   := 'Não foram localizados valores de na tabela de apuração de calculo do lucro da exploração. '||
                         'Essa tabela é gerada no calculo. pk_gera_lucro_expl.pkb_validar fase('||vn_fase||').';
         --
         declare
            vn_loggenerico_id  log_generico.id%TYPE;
         begin
            --
            pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id   => vn_loggenerico_id
                                             , ev_mensagem         => gv_mensagem
                                             , ev_resumo           => gv_resumo
                                             , en_tipo_log         => ERRO_DE_VALIDACAO
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
         vn_fase := 2.2;
         --		 
         pkb_atuliza_sit_periodo ( en_perlucrexpl_id  => en_perlucrexpl_id
                                 , en_dm_situacao     => 4 );    -- Erro de Calculo
         --
         goto salva_situacao;	  
         --		 
      end if;	  
      --
      vn_fase := 3;
      --
      vn_existe := null;
      -- 	  
      begin
         select count(1)
           into vn_existe
           from rec_unid_lucr_expl r
          where r.perlucrexpl_id = en_perlucrexpl_id; 
      exception
         when others then
            vn_existe := null;		 
      end;
      --
      if nvl(vn_existe,0) = 0 then
         --
         gv_mensagem := 'Lucro Exploração ('||to_date(gt_row_per_lucr_expl.dt_ini,'dd/mm/rrrr')||' a '||to_date(gt_row_per_lucr_expl.dt_fim,'dd/mm/rrrr')||') para empresa ID: '||gt_row_per_lucr_expl.empresa_id;
         gv_resumo   := 'Não foram localizados calculo de receita por unidade considerada no lucro da exploração. '||
                        'Essa tabela é gerada no calculo. pk_gera_lucro_expl.pkb_validar fase('||vn_fase||').';
         --
         declare
            vn_loggenerico_id  log_generico.id%TYPE;
         begin
            --
            pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                             , ev_mensagem         => gv_mensagem
                                             , ev_resumo           => gv_resumo
                                             , en_tipo_log         => INFORMACAO
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
      end if;
      --	
      vn_fase := 4;
      --	  
      if to_number(substr(to_date(gt_row_per_lucr_expl.dt_fim,'dd/mm/rrrr'),4,2)) > 1 then
         --
         vn_mes := to_number(substr(to_date(gt_row_per_lucr_expl.dt_fim,'dd/mm/rrrr'),4,2));		 
         vn_ano := to_number(substr(to_date(gt_row_per_lucr_expl.dt_fim,'dd/mm/rrrr'),7,4));
         --	
         vn_mes := vn_mes - 1;		 
         --		 
         if vn_mes = 0 then
            --
            vn_mes := 12;
            vn_ano := vn_ano - 1;
            --			
         end if;
         --
         vn_fase := 4.1;
         --
         vn_existe := null;
         --		 
         begin
            select count(1)
              into vn_existe			
              from apur_lucro_expl a
                 , per_lucr_expl p
             where to_number(substr(to_date(p.dt_fim,'dd/mm/rrrr'),4,2)) = vn_mes
               and to_number(substr(to_date(p.dt_fim,'dd/mm/rrrr'),7,4)) = vn_ano
               and a.perlucrexpl_id = p.id; 
         exception
            when others then
               vn_existe := null;
         end;
         --
         if nvl(vn_existe,0) = 0 then
            --
            gv_mensagem := 'Lucro Exploração ('||to_date(gt_row_per_lucr_expl.dt_ini,'dd/mm/rrrr')||' a '||to_date(gt_row_per_lucr_expl.dt_fim,'dd/mm/rrrr')||') para empresa ID: '||gt_row_per_lucr_expl.empresa_id;
            gv_resumo   := 'Não foi encontrado apuração e lucro para o mes anterior a esse período que está sendo validado. '||
                           'pk_gera_lucro_expl.pkb_validar fase('||vn_fase||').';
            --
            declare
               vn_loggenerico_id  log_generico.id%TYPE;
            begin
               --
               pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id   => vn_loggenerico_id
                                                , ev_mensagem         => gv_mensagem
                                                , ev_resumo           => gv_resumo
                                                , en_tipo_log         => INFORMACAO
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
         end if;
         --		 
      end if;
      --	  
   end if;
   -- 
   if nvl(est_log_generico.count,0) > 0 and
      pk_csf_secf.fkg_ver_erro_log_generico_ecf( en_referencia_id => gn_referencia_id ) = 0 then  -- 0-só advertencia / 1-erro
      --
      vn_fase := 7.1;
      --     	
      pkb_atuliza_sit_periodo ( en_perlucrexpl_id  => en_perlucrexpl_id
                              , en_dm_situacao     => 3 );    -- Finalizado
      --
   end if;
   --   
   <<salva_situacao>>  
   --   
   vn_fase := 99;
   --
   commit;
   --
   <<sair_valida>>
   null;  
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_lucro_expl.pkb_validar fase('||vn_fase||'): '||sqlerrm;
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
end pkb_validar;

-------------------------------------------------------------------------------------------------------
-- Procedimento de excluir geração do Lucro da Exploração
-------------------------------------------------------------------------------------------------------
procedure pkb_excluir_geracao ( est_log_generico     in out nocopy  dbms_sql.number_table
                              , en_perlucrexpl_id    in     per_lucr_expl.id%type
                              )
is
  --
  vn_loggenerico_id          log_generico.id%type;
  vn_fase                    number := null;
  --
begin
   --
   vn_fase := 1;
   --
   if en_perlucrexpl_id <= 0 then
      --
      gv_mensagem := 'Período de geração ID: '||en_perlucrexpl_id||', invalido. pk_gera_lucro_expl.pkb_excluir_geracao fase('||vn_fase||'): '||sqlerrm;
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
   else
      --
      vn_fase := 2;	
      --
      gt_row_per_lucr_expl := null;
      --	  
      begin
         select *
           into gt_row_per_lucr_expl
           from per_lucr_expl p
          where p.id = en_perlucrexpl_id;
      exception
         when others then
            gt_row_per_lucr_expl := null;
      end;	  
      --
      if nvl( gt_row_per_lucr_expl.id, 0 ) = 0 then
         --
         vn_fase := 2.1;		 
         --
         gv_mensagem := 'Período de geração ID: '||en_perlucrexpl_id||' ('||to_date(gt_row_per_lucr_expl.dt_ini,'dd/mm/rrrr')||' a '||to_date(gt_row_per_lucr_expl.dt_fim,'dd/mm/rrrr')||') para empresa ID: '||gt_row_per_lucr_expl.empresa_id||
                        ', não encontrado para exclusão. pk_gera_lucro_expl.pkb_excluir_geracao fase('||vn_fase||'): '||sqlerrm;
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
      else
         --
         vn_fase := 2.2;
         --
         begin		 
            delete from calc_benef_lucro_expl c
             where c.perlucrexpl_id = en_perlucrexpl_id;			 
         exception
            when others	then
               --
               gv_mensagem := 'Lucro Exploração ('||to_date(gt_row_per_lucr_expl.dt_ini,'dd/mm/rrrr')||' a '||to_date(gt_row_per_lucr_expl.dt_fim,'dd/mm/rrrr')||') para empresa ID: '||gt_row_per_lucr_expl.empresa_id;
               gv_resumo   := 'Erro ao excluir: "Calculo do Beneficio de redução sobre o Lucro da Exploração por unidade" '||
                              'pk_gera_lucro_expl.pkb_excluir_geracao fase('||vn_fase||').';
               --
               declare
                  vn_loggenerico_id  log_generico.id%TYPE;
               begin
                  --
                  pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id   => vn_loggenerico_id
                                                   , ev_mensagem         => gv_mensagem
                                                   , ev_resumo           => gv_resumo
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
            goto sair_excluir;
            --			
         end;		 
         --
         vn_fase := 2.3;
         --
         begin		 
            delete from calc_lucro_expl	c
             where c.perlucrexpl_id = en_perlucrexpl_id;			 
         exception
            when others	then
               --
               gv_mensagem := 'Lucro Exploração ('||to_date(gt_row_per_lucr_expl.dt_ini,'dd/mm/rrrr')||' a '||to_date(gt_row_per_lucr_expl.dt_fim,'dd/mm/rrrr')||') para empresa ID: '||gt_row_per_lucr_expl.empresa_id;
               gv_resumo   := 'Erro ao excluir: "Consolidação do calculo do lucro da exploração" '||
                              'pk_gera_lucro_expl.pkb_excluir_geracao fase('||vn_fase||').';
               --
               declare
                  vn_loggenerico_id  log_generico.id%TYPE;
               begin
                  --
                  pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id   => vn_loggenerico_id
                                                   , ev_mensagem         => gv_mensagem
                                                   , ev_resumo           => gv_resumo
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
            goto sair_excluir;
            --			
         end;		 
         --
         vn_fase := 2.4;
         --
         begin		 
            delete from rec_unid_lucr_expl r
             where r.perlucrexpl_id = en_perlucrexpl_id;			 
         exception
            when others	then
               --
               gv_mensagem := 'Lucro Exploração ('||to_date(gt_row_per_lucr_expl.dt_ini,'dd/mm/rrrr')||' a '||to_date(gt_row_per_lucr_expl.dt_fim,'dd/mm/rrrr')||') para empresa ID: '||gt_row_per_lucr_expl.empresa_id;
               gv_resumo   := 'Erro ao excluir: "Calculo de receita por unidade considerada no lucro da exploração" '||
                              'pk_gera_lucro_expl.pkb_excluir_geracao fase('||vn_fase||').';
               --
               declare
                  vn_loggenerico_id  log_generico.id%TYPE;
               begin
                  --
                  pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id   => vn_loggenerico_id
                                                   , ev_mensagem         => gv_mensagem
                                                   , ev_resumo           => gv_resumo
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
            goto sair_excluir;
            --			
         end;		 
         --
         vn_fase := 2.5;
         --
         begin		 
            delete from mem_calc_lucro_expl m
             where m.perlucrexpl_id = en_perlucrexpl_id;			 
         exception
            when others	then
               --
               gv_mensagem := 'Lucro Exploração ('||to_date(gt_row_per_lucr_expl.dt_ini,'dd/mm/rrrr')||' a '||to_date(gt_row_per_lucr_expl.dt_fim,'dd/mm/rrrr')||') para empresa ID: '||gt_row_per_lucr_expl.empresa_id;
               gv_resumo   := 'Erro ao excluir: "Memória de calculo da apuração de lucro da exploração" '||
                              'pk_gera_lucro_expl.pkb_excluir_geracao fase('||vn_fase||').';
               --
               declare
                  vn_loggenerico_id  log_generico.id%TYPE;
               begin
                  --
                  pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id   => vn_loggenerico_id
                                                   , ev_mensagem         => gv_mensagem
                                                   , ev_resumo           => gv_resumo
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
            goto sair_excluir;
            --			
         end;		 
         --
         vn_fase := 2.6;
         --
         begin		 
            delete from apur_lucro_expl	a
             where a.perlucrexpl_id = en_perlucrexpl_id;			 
         exception
            when others	then
               --
               gv_mensagem := 'Lucro Exploração ('||to_date(gt_row_per_lucr_expl.dt_ini,'dd/mm/rrrr')||' a '||to_date(gt_row_per_lucr_expl.dt_fim,'dd/mm/rrrr')||') para empresa ID: '||gt_row_per_lucr_expl.empresa_id;
               gv_resumo   := 'Erro ao excluir: "Demonstração da apuração de lucro da exploração" '||
                              'pk_gera_lucro_expl.pkb_excluir_geracao fase('||vn_fase||').';
               --
               declare
                  vn_loggenerico_id  log_generico.id%TYPE;
               begin
                  --
                  pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id   => vn_loggenerico_id
                                                   , ev_mensagem         => gv_mensagem
                                                   , ev_resumo           => gv_resumo
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
            goto sair_excluir;
            --			
         end;		 
         -- 		 
         vn_fase := 99;
         --
         commit;
         --		 
      end if;	  
      --
   end if;   
   --
   <<sair_excluir>>
   null;
   --   
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_gera_lucro_expl.pkb_excluir_geracao fase('||vn_fase||'): '||sqlerrm;
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
end pkb_excluir_geracao;					  

-------------------------------------------------------------------------------------------------------
-- Procedimento de desfazer o Lucro da Exploração.
-------------------------------------------------------------------------------------------------------
procedure pkb_desfazer ( est_log_generico     in out nocopy  dbms_sql.number_table
                       , en_perlucrexpl_id    in     per_lucr_expl.id%type
                       )
is
  --
  vn_loggenerico_id          log_generico.id%type;
  vn_fase                    number := null;
  --
begin
   --
   vn_fase := 1;
   --
   if en_perlucrexpl_id <= 0 then
      --
      gv_mensagem := 'Período de geração ID: '||en_perlucrexpl_id||', invalido. pk_gera_lucro_expl.pkb_desfazer fase('||vn_fase||'): '||sqlerrm;
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
   else
      --
      vn_fase := 2;	
      --	
      gt_row_per_lucr_expl := null;
      --	  
      begin
         select *
           into gt_row_per_lucr_expl
           from per_lucr_expl p
          where p.id = en_perlucrexpl_id;
      exception
         when others then
            gt_row_per_lucr_expl := null;
      end;	  
      --
      if nvl( gt_row_per_lucr_expl.id, 0 ) = 0 then
         --
         vn_fase := 2.1;		 
         --
         gv_mensagem := 'Perído de geração ID: '||en_perlucrexpl_id||', não encontrado. pk_gera_lucro_expl.pkb_desfazer fase('||vn_fase||'): '||sqlerrm;
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
      else
         --
         vn_fase := 2.2;
         --
         begin
            delete from log_generico lg
             where lg.referencia_id  = gt_row_per_lucr_expl.id
               and lg.obj_referencia = 'PER_LUCR_EXPL';
         exception
            when others then
               raise_application_error(-20101, 'Problemas ao excluir log/inconsistência - pk_gera_lucro_expl.pkb_desfazer: '||sqlerrm);
         end;		 
         --		 
         vn_fase := 2.3;
         --		 
         gn_empresa_id    := gt_row_per_lucr_expl.empresa_id;
         gn_referencia_id := gt_row_per_lucr_expl.id; 		 
         --		 
         if gt_row_per_lucr_expl.dm_situacao in (2,4) then
            --
            if gt_row_per_lucr_expl.dm_situacao = 2 then
               --
               pkb_excluir_geracao ( est_log_generico    =>   est_log_generico
                                   , en_perlucrexpl_id   =>   en_perlucrexpl_id );
               --
            end if;
            --			
            vn_fase := 2.4;
            --     	
            pkb_atuliza_sit_periodo ( en_perlucrexpl_id  => en_perlucrexpl_id
                                    , en_dm_situacao     => 0 );    -- Aberto
            --
         end if;                   		 
         --		 
         if gt_row_per_lucr_expl.dm_situacao = 3 then  -- Finalizado 		 
            --
            vn_fase := 2.5;
            --			
            pkb_atuliza_sit_periodo ( en_perlucrexpl_id  => en_perlucrexpl_id
                                    , en_dm_situacao     => 2 );    -- Calculado
            --			
         end if;
         -- 		 
         vn_fase := 99;
         --
         gv_mensagem := 'Finalizado processo para desfazer período de geração ID: '||en_perlucrexpl_id||', Empresa: '||gt_row_per_lucr_expl.empresa_id||
                        ' período: '||to_date(gt_row_per_lucr_expl.dt_ini,'dd/mm/rrrr')||' a '||to_date(gt_row_per_lucr_expl.dt_fim,'dd/mm/rrrr');
         --
         declare
            vn_loggenerico_id  log_generico.id%TYPE;
         begin
            --
            pk_csf_api_secf.pkb_log_generico ( sn_loggenerico_id   => vn_loggenerico_id
                                             , ev_mensagem         => gv_mensagem
                                             , ev_resumo           => gv_mensagem
                                             , en_tipo_log         => informacao
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
      gv_mensagem := 'Erro na pk_gera_lucro_expl.pkb_desfazer fase('||vn_fase||'): '||sqlerrm;
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
end pkb_desfazer;					  

-------------------------------------------------------------------------------------------------------

end pk_gera_lucro_expl;
/
