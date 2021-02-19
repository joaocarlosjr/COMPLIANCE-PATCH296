create or replace package body csf_own.pk_gera_arq_ecd is

-------------------------------------------------------------------------------------------------------
-- Corpo do pacote de procedimentos de criação do arquivo do sped contábil
-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia as matriz de dados

procedure pkb_inicia_dados is
  
begin
  --
  gn_aberturaecd_id    := null;
  gn_empresa_id        := null;
  gn_dm_ind_dec_contab := null;
  gn_tipo_escr_contab  := null;
  gt_param_contabil    := null;
  gv_cod_ccus          := null;
  --
  gn_qtde_reg_0000 := 0;
  gn_qtde_reg_0001 := 0;
  gn_qtde_reg_0007 := 0;
  gn_qtde_reg_0020 := 0;
  gn_qtde_reg_0035 := 0;
  gn_qtde_reg_0150 := 0;
  gn_qtde_reg_0180 := 0;
  gn_qtde_reg_0990 := 0;
  
  gn_qtde_reg_i001 := 0;
  gn_qtde_reg_i010 := 0;
  gn_qtde_reg_i012 := 0;
  gn_qtde_reg_i015 := 0;
  gn_qtde_reg_i020 := 0;
  gn_qtde_reg_i030 := 0;
  gn_qtde_reg_i050 := 0;
  gn_qtde_reg_i051 := 0;
  gn_qtde_reg_i052 := 0;
  gn_qtde_reg_i053 := 0;
  gn_qtde_reg_i075 := 0;
  gn_qtde_reg_i100 := 0;
  gn_qtde_reg_i150 := 0;
  gn_qtde_reg_i155 := 0;
  gn_qtde_reg_i157 := 0;
  gn_qtde_reg_i200 := 0;
  gn_qtde_reg_i250 := 0;
  gn_qtde_reg_i300 := 0;
  gn_qtde_reg_i310 := 0;
  gn_qtde_reg_i350 := 0;
  gn_qtde_reg_i355 := 0;
  gn_qtde_reg_i500 := 0;
  gn_qtde_reg_i510 := 0;
  gn_qtde_reg_i550 := 0;
  gn_qtde_reg_i555 := 0;
  gn_qtde_reg_i990 := 0;
  
  gn_qtde_reg_j001 := 0;
  gn_qtde_reg_j005 := 0;
  gn_qtde_reg_j100 := 0;
  gn_qtde_reg_j150 := 0;
  gn_qtde_reg_j200 := 0;
  gn_qtde_reg_j210 := 0;
  gn_qtde_reg_j215 := 0;
  gn_qtde_reg_j800 := 0;
  gn_qtde_reg_j801 := 0;
  gn_qtde_reg_j900 := 0;
  gn_qtde_reg_j930 := 0;
  gn_qtde_reg_j932 := 0;
  gn_qtde_reg_j990 := 0;
  
  gn_qtde_reg_9001 := 0;
  gn_qtde_reg_9900 := 0;
  gn_qtde_reg_9990 := 0;
  gn_qtde_reg_9999 := 0;
  --
  vt_tab_reg_0000.delete;
  --
end pkb_inicia_dados;

-------------------------------------------------------------------------------------------------------

-- Procedimento inicia os valores das váriaveis globais

procedure pkb_inicia_param(en_aberturaecd_id in abertura_ecd.id%type) is
  --
  vn_fase number := 0;
  --
begin
  --
  vn_fase := 1;
  --
  gn_aberturaecd_id := en_aberturaecd_id;
  --
  vn_fase := 2;
  --
  begin
    --
    select e.id, e.dm_ind_dec_contab, t.sigla, ecd.dt_ini, ecd.dt_fim
      into gn_empresa_id,
           gn_dm_ind_dec_contab,
           gn_tipo_escr_contab,
           gd_dt_ini,
           gd_dt_fin
      from abertura_ecd ecd, empresa e, tipo_escr_contab t
     where ecd.id = en_aberturaecd_id
       and ecd.dm_situacao IN (2,12) -- EM GERACAO
       and e.id = ecd.empresa_id
       and t.id = ecd.tipoescrcontab_id;
    --
  exception
    when others then
      gn_aberturaecd_id    := null;
      gn_empresa_id        := null;
      gn_dm_ind_dec_contab := null;
      gn_tipo_escr_contab  := null;
      gd_dt_ini            := null;
      gd_dt_fin            := null;
  end;
  --
  vn_fase := 3;
  --
  gv_versaolayoutecd_cd := pk_csf_ecd.fkg_versao_ecd_cd(ed_dt_ini => gd_dt_ini,
                                                        ed_dt_fin => gd_dt_fin);
  --
  vn_fase := 4;
  --
  begin
    --
    select *
      into gt_row_abertura_ecd
      from abertura_ecd
     where id = en_aberturaecd_id;
    --
  exception
    when others then
      gt_row_abertura_ecd := null;
  end;
  --
  vn_fase := 5;
  --
  if nvl(gn_empresa_id, 0) > 0 then
    --
    gt_param_contabil := pk_csf_ecd.fkg_param_contabil(en_empresa_id => gn_empresa_id);
    --
    vn_fase := 5.1;
    --
    gv_cod_ccus := pk_csf_ecd.fkg_centro_custo_cod(en_id => gt_param_contabil.centrocusto_id);
    --
  end if;
  --
exception
  when no_data_found then
    gn_empresa_id        := null;
    gn_dm_ind_dec_contab := null;
    gn_tipo_escr_contab  := null;
    gt_param_contabil    := null;
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_inicia_param fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_inicia_param;

-------------------------------------------------------------------------------------------------------

-- procedimento recupera dados da empresa que esta sendo gerado o SPED Contábil

procedure pkb_dados_empresa is
  
  vn_fase number := 0;
  
begin
  --
  vn_fase := 1;
  --
  select e.dm_ind_dec_contab
    into gn_dm_ind_dec_contab
    from empresa e
   where e.id = gn_empresa_id;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_dados_empresa fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_dados_empresa;

-------------------------------------------------------------------------------------------------------

-- Procedimento que armazena a estrutura do arquivo da ECD em um array

procedure pkb_armaz_estr_arq_ecd(ev_reg_blc     in registro_ecd.cod%type,
                                 el_conteudo    in estr_arq_ecd.conteudo%type,
                                 en_quebra_line in number default 1) is
  
  vn_fase number := 0;
  
  vn_registroecd_id registro_ecd.id%TYPE;
  vl_conteudo       estr_arq_ecd.conteudo%type;
  
begin
  --
  vn_fase := 1;
  --
  if ev_reg_blc is not null and el_conteudo is not null then
    --
    vn_fase := 2;
    --
    gn_seq_arq := nvl(gn_seq_arq, 0) + 1;
    --
    vn_registroecd_id := pk_csf_ecd.fkg_registro_ecd_id(ev_reg_blc);
    --
    vn_fase := 3;
    --
    if nvl(en_quebra_line, 0) = 1 then
      vl_conteudo := (el_conteudo || FINAL_DE_LINHA);
    else
      vl_conteudo := el_conteudo;
    end if;
    --
    insert into estr_arq_ecd
      (ID, ABERTURAECD_ID, REGISTROECD_ID, SEQUENCIA, CONTEUDO)
    values
      (estrarqecd_seq.nextval -- ID
      ,
       gn_aberturaecd_id -- ABERTURAECD_ID
      ,
       vn_registroecd_id -- REGISTROECD_ID
      ,
       gn_seq_arq -- SEQUENCIA
      ,
       vl_conteudo -- CONTEUDO
       );
    --
    commit;
    --
  end if;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_armaz_estr_arq_ecd fase(' ||
                                      vn_fase || ', gn_qtde_reg_i200: ' ||
                                      gn_qtde_reg_i200 ||
                                      ',gn_qtde_reg_i250:' ||
                                      gn_qtde_reg_i250 || '): ' ||
                                      sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_armaz_estr_arq_ecd;

-------------------------------------------------------------------------------------------------------

-- Procedimento cria as informações do Registro 0007: Outras inscrições Cadastrais do Empresário ou Sociedade Empresária
procedure pkb_monta_bloco_0007 is
  
  vn_fase         number := 0;
  vv_sigla_estado estado.sigla_estado%type;
  
  cursor c_empresa is
    select e.pessoa_id, j.codentref_id, j.ie
      from juridica j, empresa e
     where e.pessoa_id = j.pessoa_id
     start with e.id = gn_empresa_id
    connect by prior e.id = e.ar_empresa_id;
  
begin
  --
  vn_fase := 1;
  --
  for rec in c_empresa loop
    exit when c_empresa%notfound or(c_empresa%notfound) is null;
    --
    vn_fase := 2;
    --
    gl_conteudo := '|';
    --
    gl_conteudo := gl_conteudo || '0007' || '|';
    --
    if nvl(rec.codentref_id, 0) > 0 then
      --
      gl_conteudo := gl_conteudo || substr(pk_csf_ecd.fkg_cod_ent_ref_cad_cod(rec.codentref_id),
                                           1,
                                           2) || '|';
      --
    else
      --
      gl_conteudo := gl_conteudo ||
                     pk_csf.fkg_siglaestado_pessoaid(rec.pessoa_id) || '|';
      --
    end if;
    --
    gl_conteudo := gl_conteudo || rec.ie || '|';
    --
    gn_qtde_reg_0007 := nvl(gn_qtde_reg_0007, 0) + 1;
    --
    vn_fase := 2.2;
    --
    pkb_armaz_estr_arq_ecd(ev_reg_blc  => '0007',
                           el_conteudo => gl_conteudo);
    --
  end loop;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_0007 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_0007;

-------------------------------------------------------------------------------------------------------

-- Procedimento cria as informações do Registro 0020: Escrituração Contábil Descentralizada
procedure pkb_monta_bloco_0020 is
  
  vn_fase number := 0;
  
  cursor c_empresa is
    select (lpad(j.num_cnpj, 8, '0') || lpad(j.num_filial, 4, '0') ||
           lpad(j.dig_cnpj, 2, '0')) cnpj,
           es.sigla_estado,
           j.ie,
           c.ibge_cidade,
           j.im,
           j.nire
      from pessoa p, cidade c, estado es, juridica j, empresa e
     where c.id = p.cidade_id
       and es.id = c.estado_id
       and j.pessoa_id = p.id
       and e.pessoa_id = p.id
     start with e.id = gn_empresa_id
    connect by prior e.id = e.ar_empresa_id;
  
begin
  --
  vn_fase := 1;
  -- Se o tipo de escrituração for igual a "1-escrituração na filial"
  if nvl(gn_dm_ind_dec_contab, 0) = 1 then
    --
    vn_fase := 2;
    --
    for rec in c_empresa loop
      exit when c_empresa%notfound or(c_empresa%notfound) is null;
      --
      vn_fase := 2;
      --
      gl_conteudo := '|';
      --
      gl_conteudo := gl_conteudo || '0020' || '|';
      gl_conteudo := gl_conteudo || gn_dm_ind_dec_contab || '|';
      gl_conteudo := gl_conteudo || rec.cnpj || '|';
      gl_conteudo := gl_conteudo || rec.sigla_estado || '|';
      gl_conteudo := gl_conteudo || rec.ie || '|';
      gl_conteudo := gl_conteudo || rec.ibge_cidade || '|';
      gl_conteudo := gl_conteudo || rec.im || '|';
      gl_conteudo := gl_conteudo || rec.nire || '|';
      --
      gn_qtde_reg_0020 := nvl(gn_qtde_reg_0020, 0) + 1;
      --
      pkb_armaz_estr_arq_ecd(ev_reg_blc  => '0020',
                             el_conteudo => gl_conteudo);
      --
    end loop;
    --
  end if;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_0020 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_0020;

-------------------------------------------------------------------------------------------------------

-- Procedimento cria as informações do Registro 0035: Identificação das SCP
procedure pkb_monta_bloco_0035 is
  --
  vn_fase number := 0;
  --
  cursor c_scp is
    select pr.pessoa_id
      from pessoa_relac pr, relac_part rp
     where pr.empresa_id = gn_empresa_id
       and pr.relacpart_id = rp.id
       and rp.cod_rel = '99';
  --
begin
  --
  vn_fase := 1;
  --
  if to_number(gv_versaolayoutecd_cd) >= 300 and
     gn_tipo_escr_contab not in ('A', 'S', 'Z') then
    --
    for rec in c_scp loop
      exit when c_scp%notfound or(c_scp%notfound) is null;
      --
      vn_fase := 2;
      --
      gl_conteudo := '|';
      --
      gl_conteudo := gl_conteudo || '0035' || '|';
      gl_conteudo := gl_conteudo ||
                     pk_csf.fkg_cnpjcpf_pessoa_id(rec.pessoa_id) || '|';
      gl_conteudo := gl_conteudo ||
                     pk_csf.fkg_nome_pessoa_id(rec.pessoa_id) || '|';
      --
      gn_qtde_reg_0035 := nvl(gn_qtde_reg_0035, 0) + 1;
      --
      pkb_armaz_estr_arq_ecd(ev_reg_blc  => '0035',
                             el_conteudo => gl_conteudo);
      --
    end loop;
    --
  end if;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pk_gera_arq_ecd.pkb_monta_bloco_0035 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
end pkb_monta_bloco_0035;

-------------------------------------------------------------------------------------------------------

-- Procedimento cria as informações do Registro 0150: Tabela de Cadastro de Participante
procedure pkb_monta_bloco_0150 is
  
  vn_fase number := 0;
  --
  vv_cnpj    varchar2(14);
  vv_ie      juridica.ie%type;
  vv_iest    juridica.iest%type;
  vv_im      juridica.im%type;
  vv_suframa juridica.suframa%type;
  vv_cpf     varchar2(11);
  vn_nit     fisica.nit%type;
  --
  cursor c_lc is
    select distinct ilc.pessoa_id
      from TMP_INT_LCTO_CONTABIL ilc
     where ilc.empresa_id = gn_empresa_id
       and ilc.DT_LCTO between gd_dt_ini and gd_dt_fin
     order by 1;
  /*select distinct ipl.pessoa_id
   from int_lcto_contabil  ilc
      , int_partida_lcto   ipl
  where ilc.empresa_id = gn_empresa_id
    and ilc.DT_LCTO between gd_dt_ini and gd_dt_fin
    and ipl.INTLCTOCONTABIL_ID = ilc.id
  order by 1;*/
  --
  cursor c_pessoa(en_pessoa_id pessoa.id%type) is
    select p.id pessoa_id,
           p.cod_part,
           p.nome,
           pa.cod_siscomex,
           e.sigla_estado,
           c.ibge_cidade
      from pessoa p, cidade c, estado e, pais pa
     where p.id = en_pessoa_id
       and c.id = p.cidade_id
       and e.id = c.estado_id
       and pa.id = p.pais_id
    --and pa.id = e.pais_id
     order by p.cod_part;
  
  cursor c_pessoa_relac(en_pessoa_id pessoa.id%type) is
    select pr.relacpart_id, pr.dt_ini_rel, pr.dt_fim_rel
      from pessoa_relac pr
     where pr.pessoa_id = en_pessoa_id
       and pr.empresa_id = gn_empresa_id;
  --
begin
  --
  vn_fase := 1;
  -- Se for diferente de "B - Livro de Balancetes Diários e Balanços"
  -- registra os participantes relacionados
  if gn_tipo_escr_contab <> 'B' then
    --
    vn_fase := 1.1;
    --
    for rec_lc in c_lc loop
      exit when c_lc%notfound or(c_lc%notfound) is null;
      --
      for rec in c_pessoa(rec_lc.pessoa_id) loop
        exit when c_pessoa%notfound or(c_pessoa%notfound) is null;
        --
        vn_fase := 2;
        --
        begin
          --
          select (lpad(j.num_cnpj, 8, '0') || lpad(j.num_filial, 4, '0') ||
                 lpad(j.dig_cnpj, 2, '0')) cnpj,
                 j.ie,
                 j.iest,
                 j.im,
                 j.suframa
            into vv_cnpj, vv_ie, vv_iest, vv_im, vv_suframa
            from juridica j
           where j.pessoa_id = rec.pessoa_id;
          --
        exception
          when others then
            vv_cnpj    := null;
            vv_ie      := null;
            vv_iest    := null;
            vv_im      := null;
            vv_suframa := null;
        end;
        --
        vn_fase := 2.1;
        --
        begin
          --
          select (lpad(f.num_cpf, 9, '0') || lpad(f.dig_cpf, 2, '0')) cpf,
                 to_char(f.nit) nit
            into vv_cpf, vn_nit
            from fisica f
           where f.pessoa_id = rec.pessoa_id;
          --
        exception
          when others then
            vv_cpf := null;
            vn_nit := null;
        end;
        --
        vn_fase := 3;
        --
        gl_conteudo := '|';
        --
        gl_conteudo := gl_conteudo || '0150' || '|';
        gl_conteudo := gl_conteudo || rec.cod_part || '|';
        gl_conteudo := gl_conteudo || trim(pk_csf.fkg_converte(rec.nome)) || '|';
        gl_conteudo := gl_conteudo || lpad(rec.cod_siscomex, 5, '0') || '|';
        gl_conteudo := gl_conteudo || vv_cnpj || '|';
        gl_conteudo := gl_conteudo || vv_cpf || '|';
        gl_conteudo := gl_conteudo || vn_nit || '|';
        --
        if rec.cod_siscomex = 1058 then
          gl_conteudo := gl_conteudo || rec.sigla_estado || '|';
        else
          gl_conteudo := gl_conteudo || '|';
        end if;
        --
        gl_conteudo := gl_conteudo || vv_ie || '|';
        gl_conteudo := gl_conteudo || vv_iest || '|';
        --
        if rec.cod_siscomex = 1058 then
          gl_conteudo := gl_conteudo || rec.ibge_cidade || '|';
        else
          gl_conteudo := gl_conteudo || '|';
        end if;
        --
        gl_conteudo := gl_conteudo || vv_im || '|';
        gl_conteudo := gl_conteudo || vv_suframa || '|';
        --
        gn_qtde_reg_0150 := nvl(gn_qtde_reg_0150, 0) + 1;
        --
        pkb_armaz_estr_arq_ecd(ev_reg_blc  => '0150',
                               el_conteudo => gl_conteudo);
        
        --
        vn_fase := 4;
        --
        -- Criação do Registro 0180: Identificação do Relacionamento com o Participante
        for rec_rel in c_pessoa_relac(rec.pessoa_id) loop
          exit when c_pessoa_relac%notfound or(c_pessoa_relac%notfound) is null;
          --
          vn_fase := 5;
          --
          gl_conteudo := '|';
          --
          gl_conteudo := gl_conteudo || '0180' || '|';
          gl_conteudo := gl_conteudo || substr(pk_csf_ecd.fkg_Relac_Part_cod_rel(rec_rel.relacpart_id),
                                               1,
                                               2) || '|';
          gl_conteudo := gl_conteudo ||
                         to_char(rec_rel.dt_ini_rel, 'ddmmrrrr') || '|';
          gl_conteudo := gl_conteudo ||
                         to_char(rec_rel.dt_fim_rel, 'ddmmrrrr') || '|';
          --
          gn_qtde_reg_0180 := nvl(gn_qtde_reg_0180, 0) + 1;
          --
          pkb_armaz_estr_arq_ecd(ev_reg_blc  => '0180',
                                 el_conteudo => gl_conteudo);
          --
        end loop;
        --
      end loop;
      --
    end loop;
    --
  end if;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_0150 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_0150;

-------------------------------------------------------------------------------------------------------

-- Procedimento cria as informações do Registro 0990: Encerramento do Bloco 0
procedure pkb_monta_bloco_0990 is
  
  vn_fase number := 0;
  
  vn_qtde_total number := 0;
  
begin
  --
  vn_fase          := 1;
  gn_qtde_reg_0990 := 1;
  --
  vn_qtde_total := nvl(gn_qtde_reg_0000, 0) + nvl(gn_qtde_reg_0001, 0) +
                   nvl(gn_qtde_reg_0007, 0) + nvl(gn_qtde_reg_0020, 0) +
                   nvl(gn_qtde_reg_0035, 0) + nvl(gn_qtde_reg_0150, 0) +
                   nvl(gn_qtde_reg_0180, 0) + nvl(gn_qtde_reg_0990, 0);
  --
  gl_conteudo := '|';
  --
  gl_conteudo := gl_conteudo || '0990' || '|';
  gl_conteudo := gl_conteudo || nvl(vn_qtde_total, 0) || '|';
  --
  vn_fase := 2;
  --
  pkb_armaz_estr_arq_ecd(ev_reg_blc  => '0990',
                         el_conteudo => gl_conteudo);
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_0990 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_0990;

-------------------------------------------------------------------------------------------------------

-- Procedimento monta os registros do BLOCO 0
procedure pkb_monta_bloco_0 is
  --
  vn_fase         number := 0;
  vn_pessoa_id    number;
  vn_codentref_id number;
  --
  vv_cod_ent_ref cod_ent_ref.cod_ent_ref%type;
  vn_cod_ent_ref number;
  --
  cursor c_abertura_ecd is
    select aecd.empresa_id,
           aecd.dt_ini,
           aecd.dt_fim,
           aecd.nome,
           aecd.cnpj,
           aecd.uf,
           aecd.ie,
           aecd.cidade_ibge,
           aecd.im,
           aecd.dm_ind_sit_esp,
           aecd.dm_ind_sit_ini_per,
           aecd.dm_ind_emp_grd_prt,
           aecd.dm_ind_nire,
           aecd.dm_ind_fin_esc,
           aecd.cod_hash_sub,
           aecd.nire_subst,
           aecd.dm_tip_ecd,
           aecd.dm_ident_mf,
           aecd.DM_IND_ESC_CONS,
           tec.sigla,
           pr.pessoa_id,
           aecd.codentref_id,
           aecd.dm_ind_centralizada,
           aecd.dm_ind_mudanca_pc
      from abertura_ecd aecd, tipo_escr_contab tec, pessoa_relac pr
     where aecd.id = gn_aberturaecd_id
       and tec.id = aecd.tipoescrcontab_id
       and pr.id(+) = aecd.pessoarelac_id;
  --
begin
  --
  vn_fase := 1;
  --
  -- criação do Registro 0000: Abertura do arquivo digital
  vt_tab_reg_0000(1).reg := '0000';
  vt_tab_reg_0000(1).lecd := 'LECD';
  --
  vn_fase := 2;
  -- Recupera os dados do período de abertura do SPED Contábil
  open c_abertura_ecd;
  fetch c_abertura_ecd
    into gn_empresa_id,
         vt_tab_reg_0000    (1).dt_ini,
         vt_tab_reg_0000    (1).dt_fin,
         vt_tab_reg_0000    (1).nome,
         vt_tab_reg_0000    (1).cnpj,
         vt_tab_reg_0000    (1).uf,
         vt_tab_reg_0000    (1).ie,
         vt_tab_reg_0000    (1).cod_mun,
         vt_tab_reg_0000    (1).im,
         vt_tab_reg_0000    (1).ind_sit_esp,
         vt_tab_reg_0000    (1).ind_sit_ini_per,
         vt_tab_reg_0000    (1).ind_emp_grd_prt,
         vt_tab_reg_0000    (1).ind_nire,
         vt_tab_reg_0000    (1).ind_fin_esc,
         vt_tab_reg_0000    (1).cod_hash_sub,
         vt_tab_reg_0000    (1).nire_subst,
         vt_tab_reg_0000    (1).tip_ecd,
         vt_tab_reg_0000    (1).ident_mf,
         vt_tab_reg_0000    (1).ind_esc_cons,
         gn_tipo_escr_contab,
         vn_pessoa_id,
         vn_codentref_id,
         vt_tab_reg_0000    (1).ind_centr,
         vt_tab_reg_0000    (1).ind_mud_pc;
  close c_abertura_ecd;
  --
  vn_fase := 2.1;
  -- cria a estrutura do registro separado por PIPE "|"
  gl_conteudo := '|';
  --
  gl_conteudo := gl_conteudo || vt_tab_reg_0000(1).reg || '|';
  gl_conteudo := gl_conteudo || vt_tab_reg_0000(1).lecd || '|';
  gl_conteudo := gl_conteudo ||
                 to_char(vt_tab_reg_0000(1).dt_ini, 'ddmmrrrr') || '|';
  gl_conteudo := gl_conteudo ||
                 to_char(vt_tab_reg_0000(1).dt_fin, 'ddmmrrrr') || '|';
  gl_conteudo := gl_conteudo ||
                 pk_csf.fkg_converte(vt_tab_reg_0000(1).nome) || '|';
  gl_conteudo := gl_conteudo || vt_tab_reg_0000(1).cnpj || '|';
  gl_conteudo := gl_conteudo || vt_tab_reg_0000(1).uf || '|';
  gl_conteudo := gl_conteudo || vt_tab_reg_0000(1).ie || '|';
  gl_conteudo := gl_conteudo || vt_tab_reg_0000(1).cod_mun || '|';
  gl_conteudo := gl_conteudo || vt_tab_reg_0000(1).im || '|';
  gl_conteudo := gl_conteudo || vt_tab_reg_0000(1).ind_sit_esp || '|';
  --
  vn_fase := 2.11;
  --
  if to_number(gv_versaolayoutecd_cd) >= 200 then
    --
    gl_conteudo := gl_conteudo || vt_tab_reg_0000(1).ind_sit_ini_per || '|';
    gl_conteudo := gl_conteudo || vt_tab_reg_0000(1).ind_nire || '|';
    --
    if to_number(gv_versaolayoutecd_cd) >= 500 then
      --
      if vt_tab_reg_0000(1).ind_fin_esc in (1, 2, 3) then
        gl_conteudo := gl_conteudo || '1' || '|';
      else
        gl_conteudo := gl_conteudo || vt_tab_reg_0000(1).ind_fin_esc || '|';
      end if;
      --
    else
      gl_conteudo := gl_conteudo || vt_tab_reg_0000(1).ind_fin_esc || '|';
    end if;
    --
    gl_conteudo := gl_conteudo || vt_tab_reg_0000(1).cod_hash_sub || '|';
    --
    if to_number(gv_versaolayoutecd_cd) < 500 then
      gl_conteudo := gl_conteudo || vt_tab_reg_0000(1).nire_subst || '|';
    end if;
    --
    gl_conteudo := gl_conteudo || vt_tab_reg_0000(1).ind_emp_grd_prt || '|';
    --
  end if;
  --
  if to_number(gv_versaolayoutecd_cd) >= 300 then
    --
    gl_conteudo := gl_conteudo || vt_tab_reg_0000(1).tip_ecd || '|';
    --
    if nvl(vt_tab_reg_0000(1).tip_ecd, 0) = 2 then
      gl_conteudo := gl_conteudo ||
                     pk_csf.fkg_cnpjcpf_pessoa_id(vn_pessoa_id) || '|';
    else
      gl_conteudo := gl_conteudo || '|';
    end if;
    --
  end if;
  --
  if to_number(gv_versaolayoutecd_cd) >= 400 then
    --
    gl_conteudo := gl_conteudo || vt_tab_reg_0000(1).ident_mf || '|';
    --
  end if;
  --
  if to_number(gv_versaolayoutecd_cd) >= 500 then
    --
    gl_conteudo := gl_conteudo || vt_tab_reg_0000(1).ind_esc_cons || '|';
    --
  end if;
  --
  if to_number(gv_versaolayoutecd_cd) >= 800 then
    --
    gl_conteudo := gl_conteudo || vt_tab_reg_0000(1).ind_centr || '|';
    gl_conteudo := gl_conteudo || vt_tab_reg_0000(1).ind_mud_pc || '|';      
    /*gl_conteudo := gl_conteudo || pk_csf_ecd.fkg_cod_ent_ref(en_id => vn_codentref_id) || '|';*/
    --
    vv_cod_ent_ref := null;
    ---
    vv_cod_ent_ref := pk_csf_ecd.fkg_cod_ent_ref(en_id => vn_codentref_id);    
    gl_conteudo    := gl_conteudo || pk_csf_ecd.fkg_tratar_cod_ent_ref(ev_cod_ent_ref => vv_cod_ent_ref) || '|';
    --
  end if;
  --
  gn_qtde_reg_0000 := 1;
  --
  vn_fase := 2.2;
  --
  pkb_armaz_estr_arq_ecd(ev_reg_blc  => '0000',
                         el_conteudo => gl_conteudo);
  --
  vn_fase := 3;
  -- criação do Registro 0001: Abertura do Bloco 0
  gl_conteudo := '|';
  --
  gl_conteudo := gl_conteudo || '0001' || '|';
  gl_conteudo := gl_conteudo || 0 || '|';
  --
  gn_qtde_reg_0001 := 1;
  --
  vn_fase := 3.1;
  --
  pkb_armaz_estr_arq_ecd(ev_reg_blc  => '0001',
                         el_conteudo => gl_conteudo);
  --
  vn_fase := 4;
  -- criação do Registro 0007: Outras inscrições Cadastrais do Empresário ou Sociedade Empresária
  pkb_monta_bloco_0007;
  --
  vn_fase := 5;
  -- criação do Registro 0020: Escrituração Contábil Descentralizada
  pkb_monta_bloco_0020;
  --
  vn_fase := 6;
  -- criação do Registro 0035: Identificação das SCP
  pkb_monta_bloco_0035;
  --
  vn_fase := 7;
  -- criação do Registro 0150: Tabela de Cadastro de Participante
  pkb_monta_bloco_0150;
  --
  vn_fase := 8;
  -- criação do Registro 0990: Encerramento do Bloco 0
  pkb_monta_bloco_0990;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_0 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_0;

-------------------------------------------------------------------------------------------------------

-- Procedimento cria as informações do Registro I012: Livros Auxiliares ao Diário
procedure pkb_monta_bloco_i012 is
  
  vn_fase    number := 0;
  vv_cod_cta plano_conta.cod_cta%type;
  
  cursor c_livro_aux_diario is
    select lad.id livroauxdiario_id,
           lad.num_ord,
           lad.nat_livr,
           lad.dm_tipo,
           lad.cod_hash_aux
      from livro_aux_diario lad
     where lad.aberturaecd_id = gn_aberturaecd_id;
  
  cursor c_cta_res(en_livroauxdiario_id livro_aux_diario_cta_res.livroauxdiario_id%type) is
    select planoconta_id
      from livro_aux_diario_cta_res
     where livroauxdiario_id = en_livroauxdiario_id;
  
begin
  --
  vn_fase := 1;
  -- Se for diferente de "G - Livro Diário Geral (completo, sem escrituração auxiliar)"
  if gn_tipo_escr_contab not in ('G', 'S') then
    --
    vn_fase := 2;
    --
    for rec in c_livro_aux_diario loop
      exit when c_livro_aux_diario%notfound or(c_livro_aux_diario%notfound) is null;
      --
      vn_fase := 3;
      --
      gl_conteudo := '|';
      --
      gl_conteudo := gl_conteudo || 'I012' || '|';
      gl_conteudo := gl_conteudo || rec.num_ord || '|';
      gl_conteudo := gl_conteudo ||
                     trim(pk_csf.fkg_converte(rec.nat_livr)) || '|';
      gl_conteudo := gl_conteudo || rec.dm_tipo || '|';
      gl_conteudo := gl_conteudo || rec.cod_hash_aux || '|';
      --
      gn_qtde_reg_i012 := nvl(gn_qtde_reg_i012, 0) + 1;
      --
      pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I012',
                             el_conteudo => gl_conteudo);
      --
      vn_fase := 4;
      --
      -- criação do Registro I015: Identificação das Contas da Escrituração Resumida a que se refere a Escrituração Auxiliar
      for rec_cta in c_cta_res(rec.livroauxdiario_id) loop
        exit when c_cta_res%notfound or(c_cta_res%notfound) is null;
        --
        vn_fase := 5;
        --
        gl_conteudo := '|';
        --
        vv_cod_cta := trim(pk_csf_ecd.fkg_plano_conta_cod(rec_cta.planoconta_id));
        --
        gl_conteudo := gl_conteudo || 'I015' || '|';
        gl_conteudo := gl_conteudo || vv_cod_cta || '|';
        --
        gn_qtde_reg_i015 := nvl(gn_qtde_reg_i015, 0) + 1;
        --
        pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I015',
                               el_conteudo => gl_conteudo);
        --
      end loop;
      --
    end loop;
    --
  end if;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_i012 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_i012;

-------------------------------------------------------------------------------------------------------

-- Procedimento cria as informações do Registro I020: Campos Adicionais
procedure pkb_monta_bloco_i020 is
  
  vn_fase number := 0;
  
  cursor c_campo_adic is
    select pk_csf_ecd.fkg_registro_ecd_cod(ca.registroecd_id) reg_cod,
           ca.num_ad,
           ca.campo,
           ca.descr,
           ca.dm_tipo
      from campo_adic_ecd ca
     where ca.aberturaecd_id = gn_aberturaecd_id
     order by 1, 2;
  
begin
  --
  vn_fase := 1;
  -- Se for diferente de "Z - Razão Auxiliar (Livro Contábil Auxiliar conforme leiaute definido pelo titular da escrituração) "
  if gn_tipo_escr_contab <> 'Z' then
    --
    vn_fase := 2;
    --
    for rec in c_campo_adic loop
      exit when c_campo_adic%notfound or(c_campo_adic%notfound) is null;
      --
      vn_fase := 3;
      --
      gl_conteudo := '|';
      --
      gl_conteudo := gl_conteudo || 'I020' || '|';
      gl_conteudo := gl_conteudo || trim(rec.reg_cod) || '|';
      gl_conteudo := gl_conteudo || rec.num_ad || '|';
      gl_conteudo := gl_conteudo || trim(pk_csf.fkg_converte(rec.campo)) || '|';
      gl_conteudo := gl_conteudo || trim(pk_csf.fkg_converte(rec.descr)) || '|';
      gl_conteudo := gl_conteudo || rec.dm_tipo || '|';
      --
      gn_qtde_reg_i020 := nvl(gn_qtde_reg_i020, 0) + 1;
      --
      pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I020',
                             el_conteudo => gl_conteudo);
      --
    end loop;
    --
  end if;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_i020 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_i020;

-------------------------------------------------------------------------------------------------------
-- Procedimento cria as informações do Registro I030: Termo de abertura do livro
-------------------------------------------------------------------------------------------------------
procedure pkb_monta_bloco_i030 is

  vn_fase number := 0;
  --
  cursor c_termo_abert is
    select tal.id,
           tal.aberturaecd_id,
           tal.num_ord,
           --tal.nat_livr,
           tec.sigla nat_livr,
           tal.qtd_lin,
           tal.nome_empr,
           tal.nire,
           tal.cnpj,
           tal.dt_arq,
           tal.dt_arq_conv,
           tal.desc_mun,
           tal.dt_enc_social,
           tal.nome_auditor,
           tal.cod_cvm_auditor,
           tal.ni_cpf_cnpj
      from termo_abert_livro tal, 
           tipo_escr_contab tec
     where /*tal.nat_livr       = to_char(tec.id)*/
            (tal.nat_livr       = to_char(tec.id)
            or substr(tal.nat_livr,1,1) = tec.sigla)
       and tal.aberturaecd_id = gn_aberturaecd_id;

begin
  --
  vn_fase := 1;
  --
  for rec in c_termo_abert loop
    exit when c_termo_abert%notfound or(c_termo_abert%notfound) is null;
    --
    vn_fase := 2;
    --
    gl_conteudo := '|';
    --
    gl_conteudo := gl_conteudo || 'I030' || '|';
    gl_conteudo := gl_conteudo || 'TERMO DE ABERTURA' || '|';
    gl_conteudo := gl_conteudo || rec.num_ord || '|';
    --gl_conteudo := gl_conteudo || trim(pk_csf.fkg_converte(rec.nat_livr)) || '|';
    gl_conteudo := gl_conteudo || trim(rec.nat_livr) || '|'; 
    gl_conteudo := gl_conteudo || 0 || '|';
    gl_conteudo := gl_conteudo || trim(pk_csf.fkg_converte(rec.nome_empr)) || '|';
    gl_conteudo := gl_conteudo || rec.nire || '|';
    gl_conteudo := gl_conteudo || rec.cnpj || '|';
    gl_conteudo := gl_conteudo || to_char(rec.dt_arq, 'ddmmrrrr') || '|';
    gl_conteudo := gl_conteudo || to_char(rec.dt_arq_conv, 'ddmmrrrr') || '|';
    gl_conteudo := gl_conteudo || trim(pk_csf.fkg_converte(rec.desc_mun)) || '|';
    --
    vn_fase := 2.1;
    --
    if to_number(gv_versaolayoutecd_cd) >= 200 then
      --
      gl_conteudo := gl_conteudo || to_char(rec.dt_enc_social, 'ddmmrrrr') || '|';
      --
    end if;
    --
    if to_number(gv_versaolayoutecd_cd) = 200 then
      --
      gl_conteudo := gl_conteudo || to_char(rec.dt_enc_social, 'ddmmrrrr') || '|';
      gl_conteudo := gl_conteudo || rec.nome_auditor || '|';
      --
    end if;
    --
    vn_fase := 2.2;
    --
    gn_qtde_reg_i030 := nvl(gn_qtde_reg_i030, 0) + 1;
    --
    pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I030',
                           el_conteudo => gl_conteudo);
    --
  end loop;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_i030 fase(' || vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_i030;

-------------------------------------------------------------------------------------------------------

-- Procedimento cria as informações do Registro I050: Plano de Contas
procedure pkb_monta_bloco_i050 is

  vn_fase number := 0;

  vn_planoconta_id plano_conta.id%type;
  vv_cod_agl       plano_conta.cod_cta%type;
  vv_cod_agl_tmp   plano_conta.cod_cta%type;
  vv_cod_nat       cod_nat_pc.cod_nat%type := null;
  vv_cod_cta_sup   plano_conta.cod_cta%type;
  vv_cod_ent_ref   cod_ent_ref.cod_ent_ref%type;
  vv_cod_ccus      centro_custo.cod_ccus%type;
  vv_cod_cta_ref   plano_conta_ref_ecd.cod_cta_ref%type;

  vb_tem_cod_agl boolean;

  cursor c_planoconta is
    select pc.id planoconta_id,
           case
             when pc.dt_inc_alt > gd_dt_fin then
              gd_dt_ini
             else
              pc.dt_inc_alt
           end dt_inc_alt,
           pc.empresa_id,
           pc.codnatpc_id,
           pc.dm_ind_cta,
           pc.nivel,
           pc.cod_cta,
           pc.planoconta_id_sup,
           pc.descr_cta
      from plano_conta pc
     where pc.empresa_id  = gn_empresa_id
       and pc.dm_situacao = 1 -- Conta Ativa
       and pc.dm_tipo     = 1; -- 1-Normal, 2-Lalur/Lacs
  --
  cursor c_pc_referen(en_planoconta_id plano_conta.id%type) is
    select r.codentref_id, r.centrocusto_id, r.planocontarefecd_id
      from pc_referen r, plano_conta_ref_ecd pcre
     where r.planoconta_id = en_planoconta_id
       and (gt_row_abertura_ecd.codentref_id is null or
           r.codentref_id = gt_row_abertura_ecd.codentref_id)
       and r.planocontarefecd_id = pcre.id
          -- Considerar o periodo de referencia
       and (to_number(to_char(nvl(r.dt_ini, gd_dt_fin), 'RRRR')) <=
           to_number(to_char(gd_dt_fin, 'RRRR')) and
           to_number(to_char(nvl(r.dt_fin, sysdate), 'RRRR')) >=
           to_number(to_char(gd_dt_fin, 'RRRR')))
          -- Considerar o periodo do plano de conta do ecd
       and (to_number(to_char(pcre.dt_ini, 'RRRR')) <=
           to_number(to_char(gd_dt_fin, 'RRRR')) and
           to_number(to_char(nvl(pcre.dt_fin, sysdate), 'RRRR')) >=
           to_number(to_char(gd_dt_fin, 'RRRR')))
     order by 2;
  --
  cursor c_sc(en_planoconta_id plano_conta.id%type) is
    select sc.*
      from subconta_correlata sc
     where sc.planoconta_id = en_planoconta_id
     order by 1;
  --
begin
  --
  vn_fase := 1;
  --
  for rec in c_planoconta loop
    exit when c_planoconta%notfound or(c_planoconta%notfound) is null;
    --
    vn_fase := 2;
    --
    gl_conteudo := '|';
    --
    vn_fase    := 2.1;
    vv_cod_nat := trim(pk_csf_ecd.fkg_cod_nat_pc_cod(rec.codnatpc_id));
    --
    vn_fase := 2.2;
    --
    vv_cod_cta_sup := trim(pk_csf_ecd.fkg_plano_conta_cod(rec.planoconta_id_sup));
    --
    vn_fase := 2.3;
    --
    gl_conteudo := gl_conteudo || 'I050' || '|';
    gl_conteudo := gl_conteudo || to_char(rec.dt_inc_alt, 'ddmmrrrr') || '|';
    gl_conteudo := gl_conteudo || vv_cod_nat || '|';
    gl_conteudo := gl_conteudo || rec.dm_ind_cta || '|';
    gl_conteudo := gl_conteudo || rec.nivel || '|';
    gl_conteudo := gl_conteudo || rec.cod_cta || '|';
    gl_conteudo := gl_conteudo || vv_cod_cta_sup || '|';
    gl_conteudo := gl_conteudo ||
                   trim(pk_csf.fkg_converte(rec.descr_cta)) || '|';
    --
    gn_qtde_reg_i050 := nvl(gn_qtde_reg_i050, 0) + 1;
    --
    pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I050',
                           el_conteudo => gl_conteudo);
    --
    vn_fase := 3;
    --
    vb_tem_cod_agl := false;
    --
    if rec.dm_ind_cta = 'A' then
      -- Se a conta for Analitica
      --
      vn_fase := 5;
      --
      if nvl(gt_row_abertura_ecd.dm_gerar_pc_refen, 0) = 1 then
        --
        -- criação do Registro I051: Plano de Contas Referêncial
        for rec_r in c_pc_referen(rec.planoconta_id) loop
          exit when c_pc_referen%notfound or(c_pc_referen%notfound) is null;
          --
          vn_fase := 6;
          --
          if to_number(gv_versaolayoutecd_cd) < 800 then
             vv_cod_ent_ref := trim(pk_csf_ecd.fkg_cod_ent_ref(rec_r.codentref_id));
          end if;
          --
          if nvl(rec_r.centrocusto_id, 0) > 0 then
            vv_cod_ccus := trim(pk_csf_ecd.fkg_centro_custo_cod(rec_r.centrocusto_id));
          else
            vv_cod_ccus := trim(gv_cod_ccus);
          end if;
          --
          vv_cod_cta_ref := trim(pk_csf_ecd.fkg_plano_conta_ref_ecd_cod(rec_r.planocontarefecd_id));
          --
          gl_conteudo := '|';
          --
          gl_conteudo := gl_conteudo || 'I051' || '|';
          --
          if to_number(gv_versaolayoutecd_cd) < 800 then
             gl_conteudo := gl_conteudo || to_number(vv_cod_ent_ref) || '|'; -- Feito a conversão para remover o 0 do inicio, SPED não aceita mais.
          end if;
          --
          gl_conteudo := gl_conteudo || vv_cod_ccus || '|';
          gl_conteudo := gl_conteudo || vv_cod_cta_ref || '|';
          --
          gn_qtde_reg_i051 := nvl(gn_qtde_reg_i051, 0) + 1;
          --
          pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I051',
                                 el_conteudo => gl_conteudo);
          --
        end loop; -- fim c_pc_referen
        --
      end if; -- DM_GERAR_PC_REFEN
      --
      vn_fase := 9;
      -- Se não teve Plano de contas referencial para auxiliar na montagem dos códigos de aglutinação, monta a partir da Conta
      if gn_tipo_escr_contab not in ('A', 'Z') then
        --
        vn_fase := 9.1;
        --
        vv_cod_agl_tmp := pk_csf_ecd.fkg_pcaglcont_aglcont_cod_agl(en_planoconta_id => rec.planoconta_id);
        --
        vn_fase := 9.2;
        --
        if vv_cod_agl_tmp is null then
          --
          vn_planoconta_id := pk_csf_ecd.pkb_plano_conta_id_aglut(en_planoconta_id => rec.planoconta_id);
          --
          vv_cod_agl := pk_csf_ecd.fkg_plano_conta_cod(vn_planoconta_id);
          --
        else
          --
          vv_cod_agl := vv_cod_agl_tmp;
          --
        end if;
        --
        gl_conteudo := '|';
        --
        gl_conteudo := gl_conteudo || 'I052' || '|';
        gl_conteudo := gl_conteudo || '|'; -- nulo
        gl_conteudo := gl_conteudo || vv_cod_agl || '|';
        --
        gn_qtde_reg_i052 := nvl(gn_qtde_reg_i052, 0) + 1;
        --
        vn_fase := 9.3;
        --
        pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I052',
                               el_conteudo => gl_conteudo);
        --
      end if;
      --
      vn_fase := 10;
      --
      if gv_versaolayoutecd_cd >= '300' then
        -- Subcontas Correlatas
        for rec_sc in c_sc(rec.planoconta_id) loop
          exit when c_sc%notfound or(c_sc%notfound) is null;
          --
          vn_fase := 10.1;
          --
          gl_conteudo := '|';
          --
          gl_conteudo := gl_conteudo || 'I053' || '|';
          gl_conteudo := gl_conteudo || rec_sc.cod_idt || '|';
          --
          vn_fase := 10.2;
          --
          gl_conteudo := gl_conteudo ||
                         pk_csf_ecd.fkg_plano_conta_cod(en_id => rec_sc.planoconta_id_corr) || '|';
          --
          vn_fase := 10.3;
          --
          gl_conteudo := gl_conteudo ||
                         pk_csf_ecd.fkg_cd_nat_sub_cnt(en_natsubcnt_id => rec_sc.natsubcnt_id) || '|';
          --
          vn_fase := 10.4;
          --
          gn_qtde_reg_i053 := nvl(gn_qtde_reg_i053, 0) + 1;
          --
          pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I053',
                                 el_conteudo => gl_conteudo);
          --
        end loop;
        --
      end if;
      --
    end if;
    --
  end loop; -- fim c_planoconta
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_i050 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_i050;

-------------------------------------------------------------------------------------------------------

-- Procedimento cria as informações do Registro I075: Tabela de Histórico Padrão
procedure pkb_monta_bloco_i075 is
  
  vn_fase number := 0;
  
  vn_indice pls_integer := 0;
  
  cursor c_hist_padrao is
    select hp.cod_hist, hp.descr_hist
      from hist_padrao hp
     where exists (select 1
              from TMP_INT_LCTO_CONTABIL pl
             where pl.empresa_id = gn_empresa_id
               and pl.HISTPADRAO_ID = hp.id
               and pl.dt_lcto between gd_dt_ini and gd_dt_fin
            /*select 1
             from int_lcto_contabil lc
                , int_partida_lcto  pl
            where lc.empresa_id          = gn_empresa_id
              and lc.dt_lcto between gd_dt_ini and gd_dt_fin
              and pl.intlctocontabil_id  = lc.id
              and pl.histpadrao_id       = hp.id*/
            )
     order by hp.cod_hist;
  
begin
  --
  vn_fase := 1;
  -- se o tipo de escrituração contábil não for: B - Livro de Balancetes Diários e Balanços
  if gn_tipo_escr_contab <> 'B' then
    --
    vn_fase := 2;
    --
    for rec in c_hist_padrao loop
      exit when c_hist_padrao%notfound or(c_hist_padrao%notfound) is null;
      --
      vn_fase := 3;
      --
      vn_indice := nvl(vn_indice, 0) + 1;
      --
      gl_conteudo := '|';
      --
      gl_conteudo := gl_conteudo || 'I075' || '|';
      gl_conteudo := gl_conteudo || rec.cod_hist || '|';
      gl_conteudo := gl_conteudo ||
                     trim(pk_csf.fkg_converte(rec.descr_hist)) || '|';
      --
      gn_qtde_reg_i075 := nvl(gn_qtde_reg_i075, 0) + 1;
      --
      pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I075',
                             el_conteudo => gl_conteudo);
      --
    end loop;
    --
  end if;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_i075 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_i075;

-------------------------------------------------------------------------------------------------------

-- Procedimento cria as informações do Registro I100: Centro de Custos
procedure pkb_monta_bloco_i100 is
  
  vn_fase number := 0;
  
  vn_indice pls_integer := 0;
  
  cursor c_centrocusto is
    select case
             when cc.dt_inc_alt > gd_dt_fin then
              gd_dt_ini
             else
              cc.dt_inc_alt
           end dt_inc_alt,
           cc.cod_ccus,
           cc.descr_ccus
      from centro_custo cc
     where cc.empresa_id = gn_empresa_id
    /*
    and exists (select dsp.centrocusto_id
                  from int_det_saldo_periodo dsp
                 where dsp.empresa_id = gn_empresa_id
                   and ( dsp.dt_ini >= gd_dt_ini and dsp.dt_fim <= gd_dt_fin )
                   and dsp.centrocusto_id = cc.id
                   and ( nvl(dsp.vl_sld_ini,0) > 0
                         or nvl(dsp.vl_deb,0) > 0
                         or nvl(dsp.vl_cred,0) > 0
                         or nvl(dsp.vl_sld_fin,0) > 0 ) )
    */
     order by cc.cod_ccus;
  
begin
  --
  vn_fase := 1;
  --
  for rec in c_centrocusto loop
    exit when c_centrocusto%notfound or(c_centrocusto%notfound) is null;
    --
    vn_fase := 2;
    --
    vn_indice := nvl(vn_indice, 0) + 1;
    --
    gl_conteudo := '|';
    --
    gl_conteudo := gl_conteudo || 'I100' || '|';
    gl_conteudo := gl_conteudo || to_char(rec.dt_inc_alt, 'ddmmrrrr') || '|';
    gl_conteudo := gl_conteudo || rec.cod_ccus || '|';
    gl_conteudo := gl_conteudo ||
                   trim(pk_csf.fkg_converte(rec.descr_ccus)) || '|';
    --
    gn_qtde_reg_i100 := nvl(gn_qtde_reg_i100, 0) + 1;
    --
    vn_fase := 5;
    --
    pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I100',
                           el_conteudo => gl_conteudo);
    --
  end loop;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_i100 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_i100;

-------------------------------------------------------------------------------------------------------

-- Procedimento cria as informações do Registro I150: Saldos Períodicos - Identificação do Período
procedure pkb_monta_bloco_i150 is
  
  vn_fase number := 0;
  
  vd_dt_ini   int_det_saldo_periodo.dt_ini%type := trunc(sysdate);
  vd_dt_fim   int_det_saldo_periodo.dt_fim%type := trunc(sysdate);
  vv_cod_cta  plano_conta.cod_cta%type;
  vv_cod_ccus centro_custo.cod_ccus%type;
  
  cursor c_periodo is
    select dsp.dt_ini,
           dsp.dt_fim,
           dsp.planoconta_id,
           dsp.centrocusto_id,
           dsp.vl_sld_ini,
           dsp.dm_ind_dc_ini,
           dsp.vl_deb,
           dsp.vl_cred,
           dsp.vl_sld_fin,
           dsp.dm_ind_dc_fin,
           dsp.id intdetsaldoperiodo_id
      from int_det_saldo_periodo dsp
     where dsp.empresa_id = gn_empresa_id
       and (dsp.dt_ini >= gd_dt_ini and dsp.dt_fim <= gd_dt_fin)
       and (nvl(dsp.vl_sld_ini, 0) > 0 or nvl(dsp.vl_deb, 0) > 0 or
           nvl(dsp.vl_cred, 0) > 0 or nvl(dsp.vl_sld_fin, 0) > 0)
     order by 1 -- dsp.dt_ini
             ,
              2 -- dsp.dt_fim
             ,
              3 -- plano_conta
             ,
              4; -- centro_custo
  --
  cursor c_transf(en_intdetsaldoperiodo_id int_det_saldo_periodo.id%type) is
    select *
      from int_trans_saldo_cont_ant
     where intdetsaldoperiodo_id = en_intdetsaldoperiodo_id
     order by 1;
  --
begin
  --
  vn_fase := 1;
  --
  for rec in c_periodo loop
    exit when c_periodo%notfound or(c_periodo%notfound) is null;
    --
    vn_fase := 2;
    -- se os períodos são diferentes cria o Registro I150: Saldos Períodicos - Identificação do Período
    if trunc(rec.dt_ini) <> vd_dt_ini or trunc(rec.dt_fim) <> vd_dt_fim then
      -- Sim
      --
      vn_fase := 3;
      --
      vd_dt_ini := trunc(rec.dt_ini);
      vd_dt_fim := trunc(rec.dt_fim);
      --
      vn_fase := 4;
      --
      gl_conteudo := '|';
      --
      gl_conteudo := gl_conteudo || 'I150' || '|';
      gl_conteudo := gl_conteudo || to_char(vd_dt_ini, 'ddmmrrrr') || '|';
      gl_conteudo := gl_conteudo || to_char(vd_dt_fim, 'ddmmrrrr') || '|';
      --
      gn_qtde_reg_i150 := nvl(gn_qtde_reg_i150, 0) + 1;
      --
      pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I150',
                             el_conteudo => gl_conteudo);
      --
    end if;
    --
    vn_fase := 5;
    --
    -- criação do Registro I155: Detalhes dos Saldos Períodicos
    gl_conteudo := '|';
    --
    gl_conteudo := gl_conteudo || 'I155' || '|';
    gl_conteudo := gl_conteudo ||
                   pk_csf_ecd.fkg_plano_conta_cod(rec.planoconta_id) || '|';
    --
    if nvl(rec.centrocusto_id, 0) > 0 then
      gl_conteudo := gl_conteudo ||
                     pk_csf_ecd.fkg_centro_custo_cod(rec.centrocusto_id) || '|';
    else
      gl_conteudo := gl_conteudo || trim(gv_cod_ccus) || '|';
    end if;
    --
    gl_conteudo := gl_conteudo ||
                   trim(to_char(rec.vl_sld_ini, '99999999999999990D00')) || '|';
    gl_conteudo := gl_conteudo || rec.dm_ind_dc_ini || '|';
    gl_conteudo := gl_conteudo ||
                   trim(to_char(rec.vl_deb, '99999999999999990D00')) || '|';
    gl_conteudo := gl_conteudo ||
                   trim(to_char(rec.vl_cred, '99999999999999990D00')) || '|';
    gl_conteudo := gl_conteudo ||
                   trim(to_char(rec.vl_sld_fin, '99999999999999990D00')) || '|';
    gl_conteudo := gl_conteudo || rec.dm_ind_dc_fin || '|';
    --
    gn_qtde_reg_i155 := nvl(gn_qtde_reg_i155, 0) + 1;
    --
    pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I155',
                           el_conteudo => gl_conteudo);
    --
    vn_fase := 6;
    --  Registro I157: Transferência de Saldos de Plano de Contas Anterior
    if gv_versaolayoutecd_cd >= '300' then
      --
      for rec2 in c_transf(rec.intdetsaldoperiodo_id) loop
        exit when c_transf%notfound or(c_transf%notfound) is null;
        --
        vn_fase     := 6.1;
        gl_conteudo := '|';
        gl_conteudo := gl_conteudo || 'I157' || '|';
        gl_conteudo := gl_conteudo ||
                       pk_csf_ecd.fkg_plano_conta_cod(rec2.planoconta_id) || '|';
        --
        if nvl(rec2.centrocusto_id, 0) > 0 then
          gl_conteudo := gl_conteudo ||
                         pk_csf_ecd.fkg_centro_custo_cod(rec2.centrocusto_id) || '|';
        else
          gl_conteudo := gl_conteudo || trim(gv_cod_ccus) || '|';
        end if;
        --
        gl_conteudo := gl_conteudo ||
                       trim(to_char(rec2.VL_SLD_INI,
                                    '99999999999999990D00')) || '|';
        gl_conteudo := gl_conteudo || rec2.DM_IND_DC_INI || '|';
        --
        gn_qtde_reg_i157 := nvl(gn_qtde_reg_i157, 0) + 1;
        --
        pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I157',
                               el_conteudo => gl_conteudo);
        --
      end loop;
      --
    end if;
    --
  end loop;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_i150 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_i150;

-------------------------------------------------------------------------------------------------------

-- Procedimento cria as informações do Registro I200: Lançamento Contábil
procedure pkb_monta_bloco_i200 is
  
  vn_fase     number := 0;
  vv_cod_cta  plano_conta.cod_cta%type;
  vv_cod_ccus centro_custo.cod_ccus%type;
  vv_cod_hist hist_padrao.cod_hist%type;
  vv_cod_part pessoa.cod_part%type;
  
  cursor c_lctocontabil is
    select DISTINCT lc.id intlctocontabil_id,
                    lc.num_lcto,
                    lc.dt_lcto,
                    lc.vl_lcto,
                    lc.dm_ind_lcto,
                    lc.dt_lcto_ext
      from TMP_INT_LCTO_CONTABIL lc
     where lc.empresa_id = gn_empresa_id
       and lc.dt_lcto between gd_dt_ini and gd_dt_fin
     order by lc.num_lcto;
  
  cursor c_partida(en_intlctocontabil_id int_lcto_contabil.id%type) is
    select pl.planoconta_id,
           pl.centrocusto_id,
           pl.vl_dc,
           pl.dm_ind_dc,
           pl.num_arq,
           pl.histpadrao_id,
           pl.compl_hist,
           pl.pessoa_id
      from TMP_INT_LCTO_CONTABIL pl
     where pl.intlctocontabil_id = en_intlctocontabil_id
     order by pl.num_arq;
  
begin
  --
  vn_fase := 1;
  -- se o tipo de escrituração contábil não for:
  -- B - Livro de Balancetes Diários e Balanços
  -- Z - Razão Auxiliar (Livro Contábil Auxiliar conforme leiaute definido pelo titular da escrituração)
  
  -- PROCEDURE PARA CARREGAR I200 E I250
  
  if gn_tipo_escr_contab not in ('B', 'Z') then
    --
    vn_fase := 2;
    --
    for rec in c_lctocontabil loop
      exit when c_lctocontabil%notfound or(c_lctocontabil%notfound) is null;
      --
      vn_fase := 3;
      
      gl_conteudo := '|';
      --
      gl_conteudo := gl_conteudo || 'I200' || '|';
      gl_conteudo := gl_conteudo || rec.num_lcto || '|';
      gl_conteudo := gl_conteudo || to_char(rec.dt_lcto, 'ddmmrrrr') || '|';
      gl_conteudo := gl_conteudo ||
                     trim(to_char(rec.vl_lcto, '99999999999999990D00')) || '|';
      gl_conteudo := gl_conteudo || rec.dm_ind_lcto || '|';
      --
      if to_number(gv_versaolayoutecd_cd) >= 700 then
        gl_conteudo := gl_conteudo ||
                       to_char(rec.dt_lcto_ext, 'ddmmrrrr') || '|';
      end if;
      --
      gn_qtde_reg_i200 := nvl(gn_qtde_reg_i200, 0) + 1;
      --
      pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I200',
                             el_conteudo => gl_conteudo);
      --
      vn_fase := 4;
      -- criação do Registro I250: Partidas do Lançamento
      for rec_par in c_partida(rec.intlctocontabil_id) loop
        exit when c_partida%notfound or(c_partida%notfound) is null;
        --
        vn_fase := 5;
        --
        vv_cod_cta := trim(pk_csf_ecd.fkg_plano_conta_cod(rec_par.planoconta_id));
        --
        vn_fase := 5.01;
        --
        if nvl(rec_par.centrocusto_id, 0) > 0 then
          vv_cod_ccus := trim(pk_csf_ecd.fkg_centro_custo_cod(rec_par.centrocusto_id));
        else
          vv_cod_ccus := trim(gv_cod_ccus);
        end if;
        --
        vn_fase := 5.02;
        --
        vv_cod_hist := trim(pk_csf_ecd.fkg_hist_padrao_cod(rec_par.histpadrao_id));
        --
        vn_fase := 5.03;
        --
        vv_cod_part := trim(pk_csf.fkg_pessoa_cod_part(rec_par.pessoa_id));
        --
        vn_fase := 5.04;
        --
        gl_conteudo := '|';
        --
        gl_conteudo := gl_conteudo || 'I250' || '|';
        gl_conteudo := gl_conteudo || vv_cod_cta || '|';
        gl_conteudo := gl_conteudo || vv_cod_ccus || '|';
        gl_conteudo := gl_conteudo ||
                       trim(to_char(rec_par.vl_dc, '99999999999999990D00')) || '|';
        gl_conteudo := gl_conteudo || rec_par.dm_ind_dc || '|';
        gl_conteudo := gl_conteudo || rec_par.num_arq || '|';
        gl_conteudo := gl_conteudo || vv_cod_hist || '|';
        --
        vn_fase := 5.2;
        --
        if trim(pk_csf.fkg_converte(rec_par.compl_hist)) is null then
          gl_conteudo := gl_conteudo || 'Lancamento conforme documento' || '|';
        else
          gl_conteudo := gl_conteudo ||
                         trim(pk_csf.fkg_converte(rec_par.compl_hist)) || '|';
        end if;
        --
        vn_fase := 5.3;
        --
        gl_conteudo := gl_conteudo || vv_cod_part || '|';
        --
        gn_qtde_reg_i250 := nvl(gn_qtde_reg_i250, 0) + 1;
        --
        pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I250',
                               el_conteudo => gl_conteudo);
        --
      end loop;
      --
    end loop;
    --
  end if;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_i200 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_i200;

-------------------------------------------------------------------------------------------------------

-- Procedimento cria as informações do Registro I300: Balancetes diários - Identificação da data
procedure pkb_monta_bloco_i300 is
  
  vn_fase number := 0;
  
  vd_dt_bcte balancete_diario.dt_bcte%type := trunc(sysdate);
  
  cursor c_bctediario is
    select bd.dt_bcte,
           bd.planoconta_id,
           bd.centrocusto_id,
           bd.vl_debito,
           bd.vl_credito
      from balancete_diario bd
     where bd.aberturaecd_id = gn_aberturaecd_id
     order by 1 -- dt_bcte
             ,
              2 -- cod_cta
             ,
              3; -- cod_ccus
  
begin
  --
  vn_fase := 1;
  -- se o tipo de escrituração contábil for: B - Livro de Balancetes Diários e Balanços
  if gn_tipo_escr_contab = 'B' then
    --
    vn_fase := 2;
    --
    for rec in c_bctediario loop
      exit when c_bctediario%notfound or(c_bctediario%notfound) is null;
      --
      vn_fase := 3;
      --
      if trunc(rec.dt_bcte) <> vd_dt_bcte then
        --
        vn_fase := 4;
        --
        vd_dt_bcte := trunc(rec.dt_bcte);
        --
        vn_fase := 5;
        --
        gl_conteudo := '|';
        --
        gl_conteudo := gl_conteudo || 'I300' || '|';
        gl_conteudo := gl_conteudo || to_char(vd_dt_bcte, 'ddmmrrrr') || '|';
        --
        gn_qtde_reg_i300 := nvl(gn_qtde_reg_i300, 0) + 1;
        --
        vn_fase := 5;
        --
        pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I300',
                               el_conteudo => gl_conteudo);
        --
      end if;
      --
      vn_fase := 6;
      --
      gl_conteudo := '|';
      --
      gl_conteudo := gl_conteudo || 'I310' || '|';
      gl_conteudo := gl_conteudo ||
                     pk_csf_ecd.fkg_plano_conta_cod(rec.planoconta_id) || '|';
      --
      if nvl(rec.centrocusto_id, 0) > 0 then
        gl_conteudo := gl_conteudo ||
                       pk_csf_ecd.fkg_centro_custo_cod(rec.centrocusto_id) || '|';
      else
        gl_conteudo := gl_conteudo || trim(gv_cod_ccus) || '|';
      end if;
      --
      gl_conteudo := gl_conteudo ||
                     trim(to_char(rec.vl_debito, '99999999999999990D00')) || '|';
      gl_conteudo := gl_conteudo ||
                     trim(to_char(rec.vl_credito, '99999999999999990D00')) || '|';
      --
      gn_qtde_reg_i310 := nvl(gn_qtde_reg_i310, 0) + 1;
      --
      pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I310',
                             el_conteudo => gl_conteudo);
      --
    end loop;
    --
  end if;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_i300 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_i300;

-------------------------------------------------------------------------------------------------------

-- Procedimento cria as informações do Registro I350: Saldo das Contas de Resultado Antes do Encerramento - Identificação da Data
procedure pkb_monta_bloco_i350 is
  
  vn_fase number := 0;
  
  vd_dt_res saldo_conta_res.dt_res%type := trunc(sysdate);
  
  cursor c_contares is
    select scr.dt_res,
           scr.planoconta_id,
           scr.centrocusto_id,
           scr.vl_saldo,
           scr.dm_ind_dc
      from saldo_conta_res scr
     where scr.aberturaecd_id = gn_aberturaecd_id
     order by 1 -- dt_res
             ,
              2 -- cod_cta
             ,
              3; -- cod_ccus
  
begin
  --
  vn_fase := 1;
  -- Não Sendo escrituração do Tipo "A"
  if gn_tipo_escr_contab not in ('A') then
    --
    for rec in c_contares loop
      exit when c_contares%notfound or(c_contares%notfound) is null;
      --
      vn_fase := 2;
      --
      if trunc(rec.dt_res) <> vd_dt_res then
        --
        vn_fase := 3;
        --
        vd_dt_res := trunc(rec.dt_res);
        --
        vn_fase := 4;
        --
        gl_conteudo := '|';
        --
        gl_conteudo := gl_conteudo || 'I350' || '|';
        gl_conteudo := gl_conteudo || to_char(vd_dt_res, 'ddmmrrrr') || '|';
        --
        gn_qtde_reg_i350 := nvl(gn_qtde_reg_i350, 0) + 1;
        --
        vn_fase := 5;
        --
        pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I350',
                               el_conteudo => gl_conteudo);
        --
      end if;
      --
      vn_fase := 5;
      -- Registro I355: Detalhes dos Saldos das Contas de Resultado Antes do Encerramento
      gl_conteudo := '|';
      --
      gl_conteudo := gl_conteudo || 'I355' || '|';
      gl_conteudo := gl_conteudo ||
                     pk_csf_ecd.fkg_plano_conta_cod(rec.planoconta_id) || '|';
      --
      if nvl(rec.centrocusto_id, 0) > 0 then
        gl_conteudo := gl_conteudo ||
                       pk_csf_ecd.fkg_centro_custo_cod(rec.centrocusto_id) || '|';
      else
        gl_conteudo := gl_conteudo || trim(gv_cod_ccus) || '|';
      end if;
      --
      gl_conteudo := gl_conteudo ||
                     trim(to_char(rec.vl_saldo, '99999999999999990D00')) || '|';
      gl_conteudo := gl_conteudo || rec.dm_ind_dc || '|';
      --
      gn_qtde_reg_i355 := nvl(gn_qtde_reg_i355, 0) + 1;
      --
      pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I355',
                             el_conteudo => gl_conteudo);
      --
    end loop;
    --
  end if;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_i350 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_i350;

-------------------------------------------------------------------------------------------------------

-- Procedimento cria as informações do Registro I500: Parâmetros de Impressão e Visualização do Livro Razão Auxiliar com leiaute parametrizável
procedure pkb_monta_bloco_i500 is
  
  vn_fase number := 0;
  
  vn_tam_fonte param_razao_aux.tam_fonte%type := null;
  
begin
  --
  vn_fase := 1;
  -- se o tipo de escrituração contábil for:
  -- Z - Razão Auxiliar (Livro Contábil Auxiliar conforme leiaute definido pelo titular da escrituração)
  if gn_tipo_escr_contab = 'Z' then
    --
    vn_fase := 2;
    --
    begin
      --
      select pra.tam_fonte
        into vn_tam_fonte
        from param_razao_aux pra
       where pra.aberturaecd_id = gn_aberturaecd_id;
      --
    exception
      when others then
        vn_tam_fonte := 0;
    end;
    --
    vn_fase := 3;
    --
    gl_conteudo := '|';
    --
    gl_conteudo := gl_conteudo || 'I500' || '|';
    gl_conteudo := gl_conteudo || vn_tam_fonte || '|';
    --
    gn_qtde_reg_i500 := 1;
    --
    pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I500',
                           el_conteudo => gl_conteudo);
    --
  end if;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_i500 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_i500;

-------------------------------------------------------------------------------------------------------

-- Procedimento cria as informações do Registro I510: Definição do Livro Razão Auxiliar com o Leiaute Parametrizável
procedure pkb_monta_bloco_i510 is
  
  vn_fase number := 0;
  
  cursor c_camporazaoaux is
    select cra.nm_campo,
           cra.desc_campo,
           cra.dm_tipo_campo,
           cra.tam_campo,
           cra.qtde_casa_dec,
           cra.larg_col
      from campo_razao_aux cra
     where cra.aberturaecd_id = gn_aberturaecd_id;
  
begin
  --
  vn_fase := 1;
  -- se o tipo de escrituração contábil for:
  -- Z - Razão Auxiliar (Livro Contábil Auxiliar conforme leiaute definido pelo titular da escrituração)
  if gn_tipo_escr_contab = 'Z' then
    --
    vn_fase := 2;
    --
    for rec in c_camporazaoaux loop
      exit when c_camporazaoaux%notfound or(c_camporazaoaux%notfound) is null;
      --
      vn_fase := 3;
      
      gl_conteudo := '|';
      --
      gl_conteudo := gl_conteudo || 'I510' || '|';
      gl_conteudo := gl_conteudo ||
                     trim(pk_csf.fkg_converte(rec.nm_campo)) || '|';
      gl_conteudo := gl_conteudo ||
                     trim(pk_csf.fkg_converte(rec.desc_campo)) || '|';
      gl_conteudo := gl_conteudo || rec.dm_tipo_campo || '|';
      gl_conteudo := gl_conteudo || rec.tam_campo || '|';
      gl_conteudo := gl_conteudo || rec.qtde_casa_dec || '|';
      gl_conteudo := gl_conteudo || rec.larg_col || '|';
      --
      gn_qtde_reg_i510 := nvl(gn_qtde_reg_i510, 0) + 1;
      --
      vn_fase := 5;
      --
      pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I510',
                             el_conteudo => gl_conteudo);
      --
    end loop;
    --
  end if;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_i510 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_i510;

-------------------------------------------------------------------------------------------------------

-- Procedimento cria as informações do Registro I550: Detalhes do Livro Razão Auxiliar com Leiaute Parametrizável
procedure pkb_monta_bloco_i550 is
  
  vn_fase number := 0;
  
  cursor c_detrazaoaux is
    select dra.conteudo, dra.dm_tipo
      from det_razao_aux dra
     where dra.aberturaecd_id = gn_aberturaecd_id;
  
begin
  --
  vn_fase := 1;
  -- se o tipo de escrituração contábil for:
  -- Z - Razão Auxiliar (Livro Contábil Auxiliar conforme leiaute definido pelo titular da escrituração)
  if gn_tipo_escr_contab = 'Z' then
    --
    vn_fase := 2;
    --
    for rec in c_detrazaoaux loop
      exit when c_detrazaoaux%notfound or(c_detrazaoaux%notfound) is null;
      --
      vn_fase := 3;
      --
      if rec.dm_tipo = 'L' then
        -- Linha de detalhe
        --
        vn_fase := 4;
        --
        gl_conteudo := '|';
        --
        gl_conteudo := gl_conteudo || 'I550' || '|';
        gl_conteudo := gl_conteudo || rec.conteudo || '|';
        --
        gn_qtde_reg_i550 := nvl(gn_qtde_reg_i550, 0) + 1;
        --
        pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I550',
                               el_conteudo => gl_conteudo);
        --
      elsif rec.dm_tipo = 'T' then
        -- Total
        --
        vn_fase := 5;
        --
        gl_conteudo := '|';
        --
        gl_conteudo := gl_conteudo || 'I555' || '|';
        gl_conteudo := gl_conteudo || rec.conteudo || '|';
        --
        gn_qtde_reg_i555 := nvl(gn_qtde_reg_i555, 0) + 1;
        --
        vn_fase := 9;
        --
        pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I555',
                               el_conteudo => gl_conteudo);
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
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_i550 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_i550;

-------------------------------------------------------------------------------------------------------

-- Procedimento cria as informações do Registro I990: Encerramento do Bloco I
procedure pkb_monta_bloco_i990 is
  
  vn_fase number := 0;
  
  vn_qtde_total number := 0;
  
begin
  --
  vn_fase := 1;
  --
  gn_qtde_reg_i990 := 1;
  --
  --
  vn_fase := 2;
  --
  vn_qtde_total := nvl(gn_qtde_reg_i001, 0) + nvl(gn_qtde_reg_i010, 0) +
                   nvl(gn_qtde_reg_i012, 0) + nvl(gn_qtde_reg_i015, 0) +
                   nvl(gn_qtde_reg_i020, 0) + nvl(gn_qtde_reg_i030, 0) +
                   nvl(gn_qtde_reg_i050, 0) + nvl(gn_qtde_reg_i051, 0) +
                   nvl(gn_qtde_reg_i052, 0) + nvl(gn_qtde_reg_i053, 0) +
                   nvl(gn_qtde_reg_i075, 0) + nvl(gn_qtde_reg_i100, 0) +
                   nvl(gn_qtde_reg_i150, 0) + nvl(gn_qtde_reg_i155, 0) +
                   nvl(gn_qtde_reg_i157, 0) + nvl(gn_qtde_reg_i200, 0) +
                   nvl(gn_qtde_reg_i250, 0) + nvl(gn_qtde_reg_i300, 0) +
                   nvl(gn_qtde_reg_i310, 0) + nvl(gn_qtde_reg_i350, 0) +
                   nvl(gn_qtde_reg_i355, 0) + nvl(gn_qtde_reg_i500, 0) +
                   nvl(gn_qtde_reg_i510, 0) + nvl(gn_qtde_reg_i550, 0) +
                   nvl(gn_qtde_reg_i555, 0) + nvl(gn_qtde_reg_i990, 0);
  --
  gl_conteudo := '|';
  --
  gl_conteudo := gl_conteudo || 'I990' || '|';
  gl_conteudo := gl_conteudo || nvl(vn_qtde_total, 0) || '|';
  --
  vn_fase := 3;
  --
  pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I990',
                         el_conteudo => gl_conteudo);
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_i990 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_i990;

-------------------------------------------------------------------------------------------------------

-- Procedimento monta registro do BLOCO I: LANÇAMENTOS CONTÁBEIS
procedure pkb_monta_bloco_i is
  
  vn_fase           number := 0;
  vn_loggenerico_id log_generico_dc.id%TYPE;
  
begin
  --
  vn_fase := 1;
  -- criação do Registro I001: Abertura do bloco I
  gl_conteudo := '|';
  --
  gl_conteudo := gl_conteudo || 'I001' || '|';
  gl_conteudo := gl_conteudo || 0 || '|';
  --
  gn_qtde_reg_i001 := 1;
  --
  pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I001',
                         el_conteudo => gl_conteudo);
  --
  vn_fase := 2;
  -- criação do Registro I010: Identificação da Escrituração Contábil
  gl_conteudo := '|';
  --
  gl_conteudo := gl_conteudo || 'I010' || '|';
  gl_conteudo := gl_conteudo || gn_tipo_escr_contab || '|';
  gl_conteudo := gl_conteudo ||
                 pk_csf_ecd.fkg_versao_ecd(ed_dt_ini => vt_tab_reg_0000(1)
                                                        .dt_ini,
                                           ed_dt_fin => vt_tab_reg_0000(1)
                                                        .dt_fin) || '|';
  --
  gn_qtde_reg_i010 := nvl(gn_qtde_reg_i010, 0) + 1;
  --
  pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'I010',
                         el_conteudo => gl_conteudo);
  --
  vn_fase := 3;
  -- criação do Registro I012: Livros Auxiliares ao Diário
  pkb_monta_bloco_i012;
  --
  vn_fase := 4;
  -- criação do Registro I020: Campos Adicionais
  pkb_monta_bloco_i020;
  --
  vn_fase := 5;
  -- criação do Registro I030: Termo de abertura do livro
  pkb_monta_bloco_i030;
  --
  vn_fase := 6;
  -- criação do Registro I050: Plano de Contas
  pkb_monta_bloco_i050;
  --
  vn_fase := 7;
  -- criação do Registro I075: Tabela de Histórico Padrão
  pkb_monta_bloco_i075;
  --
  vn_fase := 8;
  -- criação do Registro I100: Centro de Custos
  pkb_monta_bloco_i100;
  --
  vn_fase := 9;
  -- criação do Registro I150: Saldos Períodicos - Identificação do Período
  pkb_monta_bloco_i150;
  --
  vn_fase := 10;
  -- criação do Registro I200: Lançamento Contábil
  --pkb_monta_bloco_i200;
  pkb_carrega_I200_I250;
  --
  vn_fase := 11;
  -- criação do Registro I300: Balancetes diários - Identificação da data
  pkb_monta_bloco_i300;
  --
  vn_fase := 12;
  -- criação do Registro I350: Saldo das Contas de Resultado Antes do Encerramento - Identificação da Data
  pkb_monta_bloco_i350;
  --
  vn_fase := 13;
  -- criação do Registro I500: Parâmetros de Impressão e Visualização do Livro Razão Auxiliar com leiaute parametrizável
  pkb_monta_bloco_i500;
  --
  vn_fase := 14;
  -- criação do Registro I510: Definição do Livro Razão Auxiliar com o Leiaute Parametrizável
  pkb_monta_bloco_i510;
  --
  vn_fase := 15;
  -- criação do Registro I550: Detalhes do Livro Razão Auxiliar com Leiaute Parametrizável
  pkb_monta_bloco_i550;
  --
  vn_fase := 16;
  -- criação do Registro I990: Encerramento do Bloco I
  pkb_monta_bloco_i990;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_i fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_i;

-------------------------------------------------------------------------------------------------------

-- Procedimento monta registro do criação do Registro J005: Demonstrações contábeis
procedure pkb_monta_bloco_j005 is
  
  vn_fase        number := 0;
  vn_vl_fat_cont number;
  --
  vb_arq_rtf     outras_infor_ecd.arq_rtf%type;
  vcl_arq        clob;
  vn_length      number;
  vn_posicao_ini number;
  vn_dif         number;
  vv_texto       varchar2(4000);
  --
  vn_nivel_agl_ativ      balan_patr.nivel_agl%type;
  vn_nivel_agl_pass      balan_patr.nivel_agl%type;
  vv_dm_ind_grp_bal      balan_patr.dm_ind_grp_bal%type;
  vn_planoconta_id_sup   plano_conta.planoconta_id_sup%type;
  vv_cod_cta_sup         plano_conta.cod_cta%type;
  vn_ar_aglutcontabil_id aglut_contabil.ar_aglutcontabil_id%type;
  vv_cod_agl             aglut_contabil.cod_agl%type;
  vn_nivel_agl           dem_result_exerc.nivel_agl%type;
  vv_dm_ind_vl_ult_dre   dem_result_exerc.dm_ind_vl_ult_dre%type;
  vv_dm_ind_vl           dem_result_exerc.dm_ind_vl%type;
  vn_dm_sit              plano_conta.dm_situacao%type;
  --
  cursor c_demoncontab is
    select dc.id demoncontab_id,
           dc.dt_ini,
           dc.dt_fin,
           dc.dm_id_dem,
           dc.cab_dem,
           a.empresa_id
      from abertura_ecd a, demon_contab dc
     where a.id = gn_aberturaecd_id
       and dc.aberturaecd_id = a.id
     order by dc.dt_ini;
  
  cursor c_balanpatr(en_demoncontab_id demon_contab.id%type) is
    select bp.cod_agl,
           bp.nivel_agl,
           bp.dm_ind_grp_bal,
           bp.descr_cod_agl,
           bp.vl_cod_agl,
           bp.dm_ind_dc_bal,
           bp.vl_cod_agl_ini,
           bp.dm_ind_dc_bal_ini,
           bp.planoconta_id
      from balan_patr bp
     where bp.demoncontab_id = en_demoncontab_id
     order by bp.id;
  
  cursor c_resultexerc(en_demoncontab_id demon_contab.id%type) is
    select row_number() over(order by id) as nu_ordem,
           dre.cod_agl,
           dre.nivel_agl,
           dre.descr_cod_agl,
           dre.vl_cod_agl,
           dre.dm_ind_vl,
           dre.vl_cta_ult_dre,
           dre.dm_ind_vl_ult_dre,
           dre.planoconta_id
      from dem_result_exerc dre
     where dre.demoncontab_id = en_demoncontab_id
     order by 1 ; /*dre.id;*/
  
  cursor c_outrasinforecd(en_demoncontab_id demon_contab.id%type) is
    select oi.id outrasinforecd_id, oi.descr, oi.dm_tipo_doc, oi.hash_rtf
      from outras_infor_ecd oi
     where oi.demoncontab_id = en_demoncontab_id
     order by 1;
  
  cursor c_termosubecd(en_demoncontab_id demon_contab.id%type) is
    select ts.id termosubecd_id,
           ts.desc_rtf,
           ts.dm_tipo_doc,
           ts.hash_rtf,
           ms.cod_mot_subs,
           ts.ind_aut_cfc
      from termo_sub_ecd ts, mot_subst ms
     where ts.demoncontab_id = en_demoncontab_id
       and ts.motsubst_id = ms.id
     order by 1;
  
  cursor c_hist(en_empresa_id number, ed_dt_ini date, ed_dt_fin date) is
    select pc.cod_cta, pc.descr_cta
      from plano_conta pc, cod_nat_pc cn
     where pc.id in (select distinct a.planoconta_id
                       from TMP_INT_LCTO_CONTABIL a
                      where a.empresa_id = en_empresa_id
                        and a.dt_lcto between ed_dt_ini and ed_dt_fin
                     /*select ipl.planoconta_id
                      from int_partida_lcto ipl
                         , int_lcto_contabil ilc
                     where ilc.id = ipl.intlctocontabil_id
                       and ilc.empresa_id = en_empresa_id
                       and trunc(ilc.dt_lcto) between ed_dt_ini and ed_dt_fin*/
                     )
       and cn.id = pc.codnatpc_id
       and cn.cod_nat in ('03') -- Patr. Líquido
     order by pc.cod_cta;
  
  cursor c_balanpatr2(en_demoncontab_id demon_contab.id%type) is
    select bp.cod_agl,
           bp.nivel_agl,
           bp.dm_ind_grp_bal,
           bp.descr_cod_agl,
           bp.vl_cod_agl,
           bp.dm_ind_dc_bal,
           bp.vl_cod_agl_ini,
           bp.dm_ind_dc_bal_ini,
           bp.planoconta_id
      from balan_patr        bp,
           plano_conta       pc,
           cod_nat_pc        cn,
           nivel_agl_pc_empr n
     where bp.demoncontab_id = en_demoncontab_id
       and pc.id = bp.planoconta_id
       and cn.id = pc.codnatpc_id
       and cn.cod_nat in ('03') -- Patr. Líquido
       and n.empresa_id = pc.empresa_id
       and n.codnatpc_id = pc.codnatpc_id
       and n.nivel = bp.nivel_agl
     order by 1;
       
 cursor c_balanpatr2_agl(en_demoncontab_id demon_contab.id%type
                        ,en_empresa_id empresa.id%type) is /* novo*/
    select bp.cod_agl,
           bp.nivel_agl,
           bp.dm_ind_grp_bal,
           bp.descr_cod_agl,
           bp.vl_cod_agl,
           bp.dm_ind_dc_bal,
           bp.vl_cod_agl_ini,
           bp.dm_ind_dc_bal_ini,
           ac.id aglutcontabil_id
    from balan_patr bp,
         aglut_contabil ac,
         cod_nat_pc cn
    where bp.demoncontab_id = en_demoncontab_id
      and bp.planoconta_id is null
      and ac.cod_agl     = bp.cod_agl
      and ac.dm_ind_cta = 'A'
      and ac.empresa_id  = en_empresa_id
      and ac.dm_st_proc  = 1
      and ac.codnatpc_id = cn.id
      and cn.cod_nat     = '03';
  
  cursor c_fato(en_empresa_id        number,
                en_planoconta_id_sup plano_conta.id%type) is
    select pc.id planoconta_id, pc.cod_cta
      from plano_conta pc, nivel_agl_pc_empr n, cod_nat_pc cn
     where pc.empresa_id = en_empresa_id
       and n.empresa_id = pc.empresa_id
       and n.codnatpc_id = pc.codnatpc_id
          --      and n.nivel       >= pc.nivel
       and cn.id = pc.codnatpc_id
       and cn.cod_nat in ('03') -- Ativo, Passivo e Patr. Líquido
     start with pc.planoconta_id_sup = en_planoconta_id_sup
    connect by prior pc.id = pc.planoconta_id_sup
    union
    select pc.id planoconta_id, pc.cod_cta
      from plano_conta pc
     where pc.id = en_planoconta_id_sup;
  --
  cursor c_fato_agl(en_empresa_id number,
                   en_aglutcontabil_id number) is
  select pc.planoconta_id , p.cod_cta
    from PC_AGLUT_CONTABIL pc, plano_conta p
   where pc.aglutcontabil_id = en_aglutcontabil_id 
     and p.empresa_id        = en_empresa_id; 
  --
  cursor c_fato_descr(en_empresa_id    number,
                      ed_dt_ini        date,
                      ed_dt_fin        date,
                      en_planoconta_id number) is
    select sum(decode(lc.dm_ind_dc,
                      'C',
                      (nvl(lc.vl_dc, 0) * -1),
                      nvl(lc.vl_dc, 0))) as vn_vl_fat_cont,
           pc.descr_cta,
           pc.cod_cta
      from TMP_INT_LCTO_CONTABIL lc, plano_conta pc
     where lc.empresa_id = en_empresa_id
       and lc.dt_lcto between ed_dt_ini and ed_dt_fin
       and lc.planoconta_id = pc.id
       and pc.id = en_planoconta_id
    /*select sum( decode(pl.dm_ind_dc, 'C', (nvl(pl.vl_dc,0) * -1), nvl(pl.vl_dc,0)) ) as vn_vl_fat_cont ,
          pc.descr_cta, pc.cod_cta
     from int_lcto_contabil lc
        , int_partida_lcto pl
         ,plano_conta pc
    where lc.empresa_id          = en_empresa_id
      and lc.dt_lcto            between ed_dt_ini and ed_dt_fin
      and pl.intlctocontabil_id = lc.id
      and pl.planoconta_id      = pc.id
      and pc.id                 = en_planoconta_id*/
     group by pc.descr_cta, pc.cod_cta
    union
    select sum(decode(lc.dm_ind_dc,
                      'C',
                      (nvl(lc.vl_dc, 0) * -1),
                      nvl(lc.vl_dc, 0))) as vn_vl_fat_cont,
           pc.descr_cta,
           pc.cod_cta
      from TMP_INT_LCTO_CONTABIL lc, plano_conta pc
     where lc.empresa_id = en_empresa_id
       and lc.dt_lcto between ed_dt_ini and ed_dt_fin
       and lc.planoconta_id = pc.id
       and pc.id in
           (select pc.id
              from plano_conta pc
             where pc.empresa_id = en_empresa_id
               and pc.planoconta_id_sup = en_planoconta_id)
    /*select sum( decode(pl.dm_ind_dc, 'C', (nvl(pl.vl_dc,0) * -1), nvl(pl.vl_dc,0)) ) as vn_vl_fat_cont ,
          pc.descr_cta, pc.cod_cta
     from int_lcto_contabil lc
        , int_partida_lcto pl
         ,plano_conta pc
    where lc.empresa_id          = en_empresa_id
      and lc.dt_lcto            between ed_dt_ini and ed_dt_fin
      and pl.intlctocontabil_id = lc.id
      and pl.planoconta_id      = pc.id
      and pc.id in (select pc.id 
                      from plano_conta pc 
                     where pc.empresa_id = en_empresa_id 
                       and pc.planoconta_id_sup = en_planoconta_id )*/
     group by pc.descr_cta, pc.cod_cta;
  --
  cursor c_fato_descr_agl(en_empresa_id number,
                          ed_dt_ini     date,
                          ed_dt_fin     date,
                          en_aglutcontabil_id number) is
    select sum(decode(lc.dm_ind_dc,
           'C',
           (nvl(lc.vl_dc, 0) * -1),
           nvl(lc.vl_dc, 0))) as vn_vl_fat_cont,
           pc.descr_cta,
           pc.cod_cta
     from TMP_INT_LCTO_CONTABIL lc, plano_conta pc, pc_aglut_contabil ac
    where lc.empresa_id        = en_empresa_id
      and lc.dt_lcto between ed_dt_ini and ed_dt_fin
      and lc.planoconta_id    = pc.id
      and ac.planoconta_id    = pc.id
      and ac.aglutcontabil_id = en_aglutcontabil_id
    group by pc.descr_cta, pc.cod_cta;
--
begin
  --
  vn_fase := 1;
  -- se o tipo de escrituração contábil não for:
  -- A - Livro Diário Auxiliar ao Diário com Escrituração Resumida
  -- Z - Razão Auxiliar (Livro Contábil Auxiliar conforme leiaute definido pelo titular da escrituração)
  if gn_tipo_escr_contab not in ('A', 'Z') then
    --
    vn_fase := 2;
    --
    for rec in c_demoncontab loop
      exit when c_demoncontab%notfound or(c_demoncontab%notfound) is null;
      --
      vn_fase := 2.1;
      --
      gl_conteudo := '|';
      --
      gl_conteudo := gl_conteudo || 'J005' || '|';
      gl_conteudo := gl_conteudo || to_char(rec.dt_ini, 'ddmmrrrr') || '|';
      gl_conteudo := gl_conteudo || to_char(rec.dt_fin, 'ddmmrrrr') || '|';
      gl_conteudo := gl_conteudo || rec.dm_id_dem || '|';
      gl_conteudo := gl_conteudo ||
                     trim(pk_csf.fkg_converte(rec.cab_dem)) || '|';
      --
      gn_qtde_reg_j005 := nvl(gn_qtde_reg_j005, 0) + 1;
      --
      vn_fase := 2.2;
      --
      pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'J005',
                             el_conteudo => gl_conteudo);
      --
      vn_fase := 3;
      --
      if to_number(gv_versaolayoutecd_cd) >= 700 then
        /*Para obter o maior nivel do código de aglutinação tanto para ativo quanto para o passivo*/
        vn_nivel_agl_ativ := null;
        vn_nivel_agl_pass := null;
        ---
        select max(bp.nivel_agl)
          into vn_nivel_agl_ativ
          from balan_patr bp
         where bp.demoncontab_id = rec.demoncontab_id
           and bp.dm_ind_grp_bal = 1; /*Ativo*/
        --
        select max(bp.nivel_agl)
          into vn_nivel_agl_pass
          from balan_patr bp
         where bp.demoncontab_id = rec.demoncontab_id
           and bp.dm_ind_grp_bal = 2; /*Passivo*/
        --
      end if;
      --
      -- criação do Registro J100: Balanço Patrimonial
      for rec_bp in c_balanpatr(rec.demoncontab_id) loop
        exit when c_balanpatr%notfound or(c_balanpatr%notfound) is null;
        --
        vn_fase := 3.1;
        --
        if to_number(gv_versaolayoutecd_cd) >= 700 then
          /*COD_AGL_SUP*/
          /*rec_bp.planoconta_id*/
          ------
          vn_fase   := 3.11;
          vn_dm_sit := null;
          ------
          if gt_row_abertura_ecd.DM_GERAR_BP_AGLT_CONTABIL = 1 and
             gt_row_abertura_ecd.DM_GERAR_DRE_AGLT_CONTABIL = 1 then
            ----
            vn_dm_sit := 1;
            ----
          else
            ----
            vn_dm_sit := pk_csf_ecd.fkg_plano_conta_dm_sit(en_planoconta_id => rec_bp.planoconta_id);
            ----
          end if;
          ------
          vn_fase := 3.12;
          ------
          /*Se DM_SITUACAO do plano de conta for inativo, o registro não será gerado.*/
          if nvl(vn_dm_sit, 0) = 0 then
            ---
            goto sair_j100;
            ---
          end if;
          ------
        end if;
        --
        gl_conteudo := '|';
        --
        gl_conteudo := gl_conteudo || 'J100' || '|'; /* REG*/
        gl_conteudo := gl_conteudo || rec_bp.cod_agl || '|'; /*COD_AGL*/
        -------------
        vn_fase := 3.2;
        --
        if to_number(gv_versaolayoutecd_cd) >= 700 then
          /*IND_COD_AGL*/
          ---
          if rec_bp.dm_ind_grp_bal = '1' then
            /*Ativo*/
            ---
            if to_number(vn_nivel_agl_ativ) = to_number(rec_bp.nivel_agl) then
              gl_conteudo := gl_conteudo || 'D' || '|'; -- detalhe
            else
              gl_conteudo := gl_conteudo || 'T' || '|'; -- totalizador
            end if;
            ---
          end if;
          ---
          if rec_bp.dm_ind_grp_bal = '2' then
            /*Passivo*/
            ---
            if to_number(vn_nivel_agl_pass) = to_number(rec_bp.nivel_agl) then
              gl_conteudo := gl_conteudo || 'D' || '|'; -- detalhe
            else
              gl_conteudo := gl_conteudo || 'T' || '|'; -- totalizador
            end if;
            ---
          end if;
          ---
        end if;
        -------------
        gl_conteudo := gl_conteudo || rec_bp.nivel_agl || '|'; /*NIVEL_AGL*/
        -------------
        vn_fase := 3.3;
        --
        if to_number(gv_versaolayoutecd_cd) >= 700 then
          /*COD_AGL_SUP*/
          /*rec_bp.planoconta_id*/
          if gt_row_abertura_ecd.dm_gerar_bp_aglt_contabil = 0 then
            -----
            if rec_bp.nivel_agl <> 1 then
              ------
              vn_planoconta_id_sup := null;
              select planoconta_id_sup
                into vn_planoconta_id_sup
                from plano_conta
               where id = rec_bp.planoconta_id;
              ------
              vv_cod_cta_sup := null;
              vv_cod_cta_sup := trim(pk_csf_ecd.fkg_plano_conta_cod(vn_planoconta_id_sup));
              ------
              gl_conteudo := gl_conteudo || vv_cod_cta_sup || '|';
              ------
            else
              ------
              gl_conteudo := gl_conteudo || null || '|';
              ------
            end if;
            -----
          else
            ------
            if rec_bp.nivel_agl <> 1 then
              ------
              vn_ar_aglutcontabil_id := null;
              begin
                select ac.ar_aglutcontabil_id
                  into vn_ar_aglutcontabil_id
                  from aglut_contabil ac
                 where ac.empresa_id = gt_row_abertura_ecd.empresa_id
                   and ac.cod_agl = rec_bp.cod_agl;
              exception
                when others then
                  vn_ar_aglutcontabil_id := null;
              end;
              ------
              vv_cod_agl := null;
              begin
                select cod_agl
                  into vv_cod_agl
                  from aglut_contabil
                 where id = vn_ar_aglutcontabil_id;
              exception
                when others then
                  vv_cod_agl := null;
              end;
              ------
              gl_conteudo := gl_conteudo || vv_cod_agl || '|';
              ------
            else
              ------
              gl_conteudo := gl_conteudo || null || '|';
              ------
            end if;
            ------
          end if;
          
        end if;
        -------------
        vn_fase := 3.4;
        --
        if to_number(gv_versaolayoutecd_cd) >= 700 then
          /* IND_GRP_BAL*/
          ---
          vv_dm_ind_grp_bal := null;
          ---
          if rec_bp.dm_ind_grp_bal = '1' then
            ---
            vv_dm_ind_grp_bal := 'A'; /*Ativo*/
            ---
          else
            ---
            vv_dm_ind_grp_bal := 'P'; /*Passivo e Patrimônio Líquido*/
            ---
          end if;
          ---
          gl_conteudo := gl_conteudo || vv_dm_ind_grp_bal || '|';
          ---
        else
          gl_conteudo := gl_conteudo || rec_bp.dm_ind_grp_bal || '|';
        end if;
        -------------
        gl_conteudo := gl_conteudo ||
                       trim(pk_csf.fkg_converte(rec_bp.descr_cod_agl)) || '|'; /*DESCR_COD_AGL*/
        -------------
        vn_fase := 3.5;
        --
        if to_number(gv_versaolayoutecd_cd) >= 700 then
          --
          gl_conteudo := gl_conteudo ||
                         trim(to_char(rec_bp.vl_cod_agl_ini,
                                      '99999999999999990D00')) || '|'; /*VL_CTA_INI*/
          gl_conteudo := gl_conteudo || rec_bp.dm_ind_dc_bal_ini || '|'; /*IND_DC_CTA_INI*/
          --
          gl_conteudo := gl_conteudo ||
                         trim(to_char(rec_bp.vl_cod_agl,
                                      '99999999999999990D00')) || '|'; /*VL_CTA_FIN*/
          gl_conteudo := gl_conteudo || rec_bp.dm_ind_dc_bal || '|'; /*IND_DC_CTA_FIN*/
          --
        else
          --
          gl_conteudo := gl_conteudo ||
                         trim(to_char(rec_bp.vl_cod_agl,
                                      '99999999999999990D00')) || '|'; /*VL_CTA_INI*/
          gl_conteudo := gl_conteudo || rec_bp.dm_ind_dc_bal || '|'; /*IND_DC_CTA_INI*/
          --
          if to_number(gv_versaolayoutecd_cd) >= 200 then
            --
            gl_conteudo := gl_conteudo ||
                           trim(to_char(rec_bp.vl_cod_agl_ini,
                                        '99999999999999990D00')) || '|'; /*VL_CTA_FIN*/
            gl_conteudo := gl_conteudo || rec_bp.dm_ind_dc_bal_ini || '|'; /*IND_DC_CTA_FIN*/
            --
          end if;
          --
        end if;
        --
        -- Inclui as notas explicativas relativas as demonstrações contábeis
        if to_number(gv_versaolayoutecd_cd) >= 600 then
          gl_conteudo := gl_conteudo || null || '|';
        end if;
        --
        gn_qtde_reg_j100 := nvl(gn_qtde_reg_j100, 0) + 1;
        --
        vn_fase := 3.5;
        --
        pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'J100',
                               el_conteudo => gl_conteudo);
        --
        <<sair_j100>>
      --
        vn_fase := 3.6;
        --
      end loop;
      --
      vn_fase := 4;
      --
      if to_number(gv_versaolayoutecd_cd) >= 700 then
        /*Para obter o maior nivel do código de aglutinação tanto para ativo quanto para o passivo*/
        vn_nivel_agl := null;
        ---
        select max(dre.nivel_agl)
          into vn_nivel_agl
          from dem_result_exerc dre
         where dre.demoncontab_id = rec.demoncontab_id;
        --
      end if;
      --
      -- criação do Registro J150: Demonstrações do Resultado do Exercício
      for rec_dre in c_resultexerc(rec.demoncontab_id) loop
        exit when c_resultexerc%notfound or(c_resultexerc%notfound) is null;
        --
        vn_fase := 4.1;
        --
        if to_number(gv_versaolayoutecd_cd) >= 700 then
          /*COD_AGL_SUP*/
          /*rec_bp.planoconta_id*/
          vn_fase := 4.11;
          ------
          vn_dm_sit := null;
          ------
          if gt_row_abertura_ecd.DM_GERAR_BP_AGLT_CONTABIL = 1 and
             gt_row_abertura_ecd.DM_GERAR_DRE_AGLT_CONTABIL = 1 then
            ----
            vn_dm_sit := 1;
            ----
          else
            ----
            vn_dm_sit := pk_csf_ecd.fkg_plano_conta_dm_sit(en_planoconta_id => rec_dre.planoconta_id);
            ----
          end if;
          ------
          vn_fase := 4.12;
          ------
          /*Se DM_SITUACAO do plano de conta for inativo, o registro não será gerado.*/
          if nvl(vn_dm_sit, 0) = 0 then
            ---
            goto sair_j150;
            ---
          end if;
          ------
        end if;
        --
        gl_conteudo := '|';
        --
        gl_conteudo := gl_conteudo || 'J150' || '|'; /*REG*/
        --
        if to_number(gv_versaolayoutecd_cd) >= 800 then
          gl_conteudo := gl_conteudo || rec_dre.nu_ordem || '|'; /*nu_ordem*/
        end if;
        --
        gl_conteudo := gl_conteudo || rec_dre.cod_agl || '|'; /*COD_AGL*/
        ---
        vn_fase := 4.2;
        --
        if to_number(gv_versaolayoutecd_cd) >= 700 then
          /*IND_COD_AGL*/
          ---
          if to_number(vn_nivel_agl) = to_number(rec_dre.nivel_agl) then
            gl_conteudo := gl_conteudo || 'D' || '|'; -- detalhe
          else
            gl_conteudo := gl_conteudo || 'T' || '|'; -- totalizador
          end if;
          ---
        end if;
        ---
        gl_conteudo := gl_conteudo || rec_dre.nivel_agl || '|'; /*NIVEL_AGL*/
        --------------
        vn_fase := 4.3;
        --
        if to_number(gv_versaolayoutecd_cd) >= 700 then
          /*COD_AGL_SUP*/
          ---
          if gt_row_abertura_ecd.dm_gerar_bp_aglt_contabil = 0 then
            -----
            if rec_dre.nivel_agl <> 1 then
              ------
              vn_planoconta_id_sup := null;
              select planoconta_id_sup
                into vn_planoconta_id_sup
                from plano_conta
               where id = rec_dre.planoconta_id;
              ------
              vv_cod_cta_sup := null;
              vv_cod_cta_sup := trim(pk_csf_ecd.fkg_plano_conta_cod(vn_planoconta_id_sup));
              ------
              gl_conteudo := gl_conteudo || vv_cod_cta_sup || '|';
              ------
            else
              ------
              gl_conteudo := gl_conteudo || null || '|';
              ------
            end if;
            -----
          else
            ------
            if rec_dre.nivel_agl <> 1 then
              ------
              vn_ar_aglutcontabil_id := null;
              begin
                select ac.ar_aglutcontabil_id
                  into vn_ar_aglutcontabil_id
                  from aglut_contabil ac
                 where ac.empresa_id = gt_row_abertura_ecd.empresa_id
                   and ac.cod_agl = rec_dre.cod_agl;
              exception
                when others then
                  vn_ar_aglutcontabil_id := null;
              end;
              ------
              vv_cod_agl := null;
              begin
                select cod_agl
                  into vv_cod_agl
                  from aglut_contabil
                 where id = vn_ar_aglutcontabil_id;
              exception
                when others then
                  vv_cod_agl := null;
              end;
              ------
              gl_conteudo := gl_conteudo || vv_cod_agl || '|';
              ------
            else
              ------
              gl_conteudo := gl_conteudo || null || '|';
              ------
            end if;
            ------
          end if;
          /*if rec_dre.nivel_agl <> 1 and vn_dm_sit <> 1 then
                            ------
                            vn_planoconta_id_sup := null;
          \*                  select planoconta_id_sup into vn_planoconta_id_sup
                            from plano_conta where id = rec_dre.planoconta_id;*\
                            vn_planoconta_id_sup:= pk_csf_ecd.fkg_planoconta_id_sup (rec_dre.planoconta_id);
                            ------
                            vv_cod_cta_sup := null;
                            vv_cod_cta_sup := trim(pk_csf_ecd.fkg_plano_conta_cod(vn_planoconta_id_sup));
                            ------
                            gl_conteudo := gl_conteudo || vv_cod_cta_sup || '|';
                            ------
                         else
                           ------
                           --gl_conteudo := gl_conteudo || null|| '|';
                           ------
                           --ini #55799
                           if rec_dre.nivel_agl <> 1 then
                             ------
                             vn_ar_aglutcontabil_id:=null;
                             --
                             begin
                               select ac.ar_aglutcontabil_id
                                 into vn_ar_aglutcontabil_id
                                 from aglut_contabil ac
                                where ac.empresa_id = gt_row_abertura_ecd.empresa_id
                                  and ac.cod_agl = rec_dre.cod_agl;
                             exception
                               when others then
                                 vn_ar_aglutcontabil_id:=null;
                             end;
                             ------
                             vv_cod_agl:=null;
                             begin
                               select cod_agl
                                 into vv_cod_agl
                                 from aglut_contabil
                                where id = vn_ar_aglutcontabil_id;
                             exception
                               when others then
                                 vv_cod_agl:=null;
                             end;
                             ------
                             gl_conteudo := gl_conteudo || vv_cod_agl || '|';
                             ------
                           else
                             ------
                             gl_conteudo := gl_conteudo || null|| '|';
                             ------
                           end if;
                           ------ fim #55799
                         end if;
                       */ ---
        end if;
        --------------
        gl_conteudo := gl_conteudo ||
                       trim(pk_csf.fkg_converte(rec_dre.descr_cod_agl)) || '|'; /*DESCR_COD_AGL*/
        -----           
        if to_number(gv_versaolayoutecd_cd) >= 800 then
          --
          gl_conteudo := gl_conteudo || trim(to_char(rec_dre.vl_cta_ult_dre,
                                      '99999999999999990D00')) || '|';
          --  
          gl_conteudo := gl_conteudo ||rec_dre.dm_ind_vl_ult_dre || '|';
          --          
        end if;
        ----- 
        gl_conteudo := gl_conteudo ||
                       trim(to_char(rec_dre.vl_cod_agl,
                                    '99999999999999990D00')) || '|'; /*VL_CTA*/
        --
        vn_fase := 4.4;
        --
        if to_number(gv_versaolayoutecd_cd) >= 700 then
          /*IND_DC_CTA*/
          ----
          if rec_dre.dm_ind_vl in ('R', 'P') then
            /*considerados como Crédito - C*/
            vv_dm_ind_vl := 'C';
          elsif rec_dre.dm_ind_vl in ('N', 'D') then
            /*considerados como Débito -  D*/
            vv_dm_ind_vl := 'D';
          end if;
          ----
          gl_conteudo := gl_conteudo || vv_dm_ind_vl || '|';
          ----
        else
          ----
          gl_conteudo := gl_conteudo || rec_dre.dm_ind_vl || '|';
          ----
        end if;
        --
        vn_fase := 4.5;
        --
        if gv_versaolayoutecd_cd >= '400' then
          --
          /*gl_conteudo := gl_conteudo || trim( to_char(rec_dre.vl_cta_ult_dre, '99999999999999990D00') ) || '|';*/
          --
          if to_number(gv_versaolayoutecd_cd) >= 700 then
            ----
            vv_dm_ind_vl_ult_dre := null;
            ---
            if rec_dre.dm_ind_vl in ('R', 'P') then
              /*dm_ind_vl_ult_dre*/ /*considerados como D ¿ Linha totalizadora ou de detalhe da demonstração
                                                                              que, por sua natureza de despesa, represente redução do lucro.*/
              vv_dm_ind_vl_ult_dre := 'R';
            elsif rec_dre.dm_ind_vl in ('N', 'D') then
              /*dm_ind_vl_ult_dre*/ /*considerados como R ¿ Linha totalizadora ou de detalhe da demonstração
                                                                                 que, por sua natureza de receita, represente incremento do lucro.*/
              vv_dm_ind_vl_ult_dre := 'D';
            end if;
            ----
            gl_conteudo := gl_conteudo || vv_dm_ind_vl_ult_dre || '|';
            ----
          else
            ----
            gl_conteudo := gl_conteudo ||
                           trim(to_char(rec_dre.vl_cta_ult_dre,
                                        '99999999999999990D00')) || '|';
            gl_conteudo := gl_conteudo || rec_dre.dm_ind_vl_ult_dre || '|';
            ----
          end if;
          --
        end if;
        --
        -- Inclui as notas explicativas relativas as demonstrações contábeis
        if to_number(gv_versaolayoutecd_cd) >= 600 then
          gl_conteudo := gl_conteudo || null || '|';
        end if;
        --
        gn_qtde_reg_j150 := nvl(gn_qtde_reg_j150, 0) + 1;
        --
        vn_fase := 4.2;
        --
        pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'J150',
                               el_conteudo => gl_conteudo);
        --
        <<sair_j150>>
      --
        vn_fase := 4.3;
        --
      end loop;
      --
      if to_number(gv_versaolayoutecd_cd) >= 300 and
         nvl(gt_row_abertura_ecd.dm_gerar_dmpl, 0) = 1 then
        -- Sim
        --
        vn_fase := 5;
        --
        if to_number(gv_versaolayoutecd_cd) < 700 then
          -- este registro foi excluído a partir da versão 7.00
          --
          for rec_hist in c_hist(rec.empresa_id, rec.dt_ini, rec.dt_fin) loop
            exit when c_hist%notfound or(c_hist%notfound) is null;
            --
            vn_fase := 5.1;
            --
            gl_conteudo := '|';
            gl_conteudo := gl_conteudo || 'J200' || '|';
            gl_conteudo := gl_conteudo || trim(rec_hist.cod_cta) || '|';
            gl_conteudo := gl_conteudo ||
                           trim(pk_csf.fkg_converte(rec_hist.descr_cta)) || '|';
            --
            gn_qtde_reg_j200 := nvl(gn_qtde_reg_j200, 0) + 1;
            --
            vn_fase := 5.2;
            --
            pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'J200',
                                   el_conteudo => gl_conteudo);
            --
          end loop;
          --
        end if;
        --
        vn_fase := 6;
        --
        if nvl(gt_row_abertura_ecd.dm_gerar_dmpl,0) = 1
        and nvl(gt_row_abertura_ecd.dm_gerar_dre_aglt_contabil,0) =1 
        and nvl(gt_row_abertura_ecd.dm_gerar_bp_aglt_contabil,0) = 1 then
          --
          vn_fase := 6.1;
          --
          /*com aglutinação*/
          for rec_bp2_agl in c_balanpatr2_agl(rec.demoncontab_id,rec.empresa_id) loop
            exit when c_balanpatr2_agl%notfound or(c_balanpatr2_agl%notfound) is null;
            --
            vn_fase := 6.2;
            --
            gl_conteudo := '|';
            --
            gl_conteudo := gl_conteudo || 'J210' || '|';
            gl_conteudo := gl_conteudo || 1 || '|'; -- 1 ¿ DMPL ¿ Demonstração de Mutações do Patrimônio Líquido
            gl_conteudo := gl_conteudo || trim(rec_bp2_agl.cod_agl) || '|';
            gl_conteudo := gl_conteudo ||
                           trim(pk_csf.fkg_converte(rec_bp2_agl.descr_cod_agl)) || '|';
            --
            if to_number(gv_versaolayoutecd_cd) >= 700 then
              --
              gl_conteudo := gl_conteudo ||
                             trim(to_char(rec_bp2_agl.vl_cod_agl_ini,
                                          '99999999999999990D00')) || '|';
              gl_conteudo := gl_conteudo || rec_bp2_agl.dm_ind_dc_bal_ini || '|';
              --
              gl_conteudo := gl_conteudo ||
                             trim(to_char(rec_bp2_agl.vl_cod_agl,
                                          '99999999999999990D00')) || '|';
              gl_conteudo := gl_conteudo || rec_bp2_agl.dm_ind_dc_bal || '|';
              --
            else
              --
              gl_conteudo := gl_conteudo ||
                             trim(to_char(rec_bp2_agl.vl_cod_agl,
                                          '99999999999999990D00')) || '|';
              gl_conteudo := gl_conteudo || rec_bp2_agl.dm_ind_dc_bal || '|';
              --
              gl_conteudo := gl_conteudo ||
                             trim(to_char(rec_bp2_agl.vl_cod_agl_ini,
                                          '99999999999999990D00')) || '|';
              gl_conteudo := gl_conteudo || rec_bp2_agl.dm_ind_dc_bal_ini || '|';
              --
            end if;
            --
            -- Inclui as notas explicativas relativas as demonstrações contábeis
            if to_number(gv_versaolayoutecd_cd) >= 600 then
              gl_conteudo := gl_conteudo || null || '|';
            end if;
            --
            gn_qtde_reg_j210 := nvl(gn_qtde_reg_j210, 0) + 1;
            --
            vn_fase := 6.3;
            --
            pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'J210',
                                   el_conteudo => gl_conteudo);
            --
            vn_fase := 6.4;
            --
            if to_number(gv_versaolayoutecd_cd) < 700 then
              --
              -- J215: FATO CONTÁBIL QUE ALTERA A CONTA LUCROS ACUMULADOS OU A CONTA PREJUÍZOS ACUMULADOS OU TODO O PATRIMÔNIO LÍQUIDO
              for rec_fato_agl in c_fato_agl(rec.empresa_id, rec_bp2_agl.aglutcontabil_id ) loop
                exit when c_fato_agl%notfound or(c_fato_agl%notfound) is null;
                --
                vn_fase := 6.5;
                --                    --
                begin
                  --

                  select sum(decode(lc.dm_ind_dc,
                                    'C',
                                    (nvl(lc.vl_dc, 0) * -1),
                                    nvl(lc.vl_dc, 0)))
                    into vn_vl_fat_cont
                    from TMP_INT_LCTO_CONTABIL lc
                   where lc.empresa_id = rec.empresa_id
                     and lc.planoconta_id = rec_fato_agl.planoconta_id
                     and lc.dt_lcto between rec.dt_ini and rec.dt_fin;
                  --
                exception
                  when others then
                    vn_vl_fat_cont := 0;
                end;
                --
                vn_fase := 6.6;
                --
                if nvl(vn_vl_fat_cont, 0) <> 0 then
                  --
                  gl_conteudo := '|';
                  gl_conteudo := gl_conteudo || 'J215' || '|';
                  gl_conteudo := gl_conteudo || trim(rec_fato_agl.cod_cta) || '|';
                  --
                  if nvl(vn_vl_fat_cont, 0) < 0 then
                    gl_conteudo := gl_conteudo ||
                                   trim(to_char(nvl(vn_vl_fat_cont, 0) * -1,
                                                '99999999999999990D00')) || '|';
                    gl_conteudo := gl_conteudo || 'C' || '|';
                  else
                    gl_conteudo := gl_conteudo ||
                                   trim(to_char(nvl(vn_vl_fat_cont, 0),
                                                '99999999999999990D00')) || '|';
                    gl_conteudo := gl_conteudo || 'D' || '|';
                  end if;
                  --
                  gn_qtde_reg_j215 := nvl(gn_qtde_reg_j215, 0) + 1;
                  --
                  pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'J215',
                                         el_conteudo => gl_conteudo);
                  --
                end if;
                --
              end loop;
              --
            else
              --
              /*a partir da versão 7.00*/
              for rec_fato_descr_agl in c_fato_descr_agl(rec.empresa_id,
                                                 rec.dt_ini,
                                                 rec.dt_fin,
                                                 rec_bp2_agl.aglutcontabil_id) loop
                exit when c_fato_descr_agl%notfound or(c_fato_descr_agl%notfound) is null;
                -------
                vn_fase := 6.6;
                --
                vn_vl_fat_cont := rec_fato_descr_agl.vn_vl_fat_cont;
                ---
                vn_fase := 6.7;
                --
                if nvl(vn_vl_fat_cont, 0) <> 0 then
                  --
                  gl_conteudo := '|';
                  gl_conteudo := gl_conteudo || 'J215' || '|';
                  gl_conteudo := gl_conteudo ||
                                 trim(rec_fato_descr_agl.cod_cta) || '|';
                  gl_conteudo := gl_conteudo ||
                                 trim(pk_csf.fkg_converte(rec_fato_descr_agl.descr_cta)) || '|'; /*DESC_FAT*/
                  --
                  if nvl(vn_vl_fat_cont, 0) < 0 then
                    gl_conteudo := gl_conteudo ||
                                   trim(to_char(nvl(vn_vl_fat_cont, 0) * -1,
                                                '99999999999999990D00')) || '|';
                    gl_conteudo := gl_conteudo || 'C' || '|';
                  else
                    gl_conteudo := gl_conteudo ||
                                   trim(to_char(nvl(vn_vl_fat_cont, 0),
                                                '99999999999999990D00')) || '|';
                    gl_conteudo := gl_conteudo || 'D' || '|';
                  end if;
                  --
                  gn_qtde_reg_j215 := nvl(gn_qtde_reg_j215, 0) + 1;
                  --
                  pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'J215',
                                         el_conteudo => gl_conteudo);
                  --
                end if;
                --
              end loop;
              --
            end if;
            --
          end loop;
          --
        else
          --
          vn_fase := 7;
          --
          /*original - sem aglutinação*/
          for rec_bp2 in c_balanpatr2(rec.demoncontab_id) loop
            exit when c_balanpatr2%notfound or(c_balanpatr2%notfound) is null;
            --
            vn_fase := 7.1;
            --
            gl_conteudo := '|';
            --
            gl_conteudo := gl_conteudo || 'J210' || '|';
            gl_conteudo := gl_conteudo || 1 || '|'; -- 1 ¿ DMPL ¿ Demonstração de Mutações do Patrimônio Líquido
            gl_conteudo := gl_conteudo || trim(rec_bp2.cod_agl) || '|';
            gl_conteudo := gl_conteudo ||
                           trim(pk_csf.fkg_converte(rec_bp2.descr_cod_agl)) || '|';
            --
            if to_number(gv_versaolayoutecd_cd) >= 700 then
              --
              gl_conteudo := gl_conteudo ||
                             trim(to_char(rec_bp2.vl_cod_agl_ini,
                                          '99999999999999990D00')) || '|';
              gl_conteudo := gl_conteudo || rec_bp2.dm_ind_dc_bal_ini || '|';
              --
              gl_conteudo := gl_conteudo ||
                             trim(to_char(rec_bp2.vl_cod_agl,
                                          '99999999999999990D00')) || '|';
              gl_conteudo := gl_conteudo || rec_bp2.dm_ind_dc_bal || '|';
              --
            else
              --
              gl_conteudo := gl_conteudo ||
                             trim(to_char(rec_bp2.vl_cod_agl,
                                          '99999999999999990D00')) || '|';
              gl_conteudo := gl_conteudo || rec_bp2.dm_ind_dc_bal || '|';
              --
              gl_conteudo := gl_conteudo ||
                             trim(to_char(rec_bp2.vl_cod_agl_ini,
                                          '99999999999999990D00')) || '|';
              gl_conteudo := gl_conteudo || rec_bp2.dm_ind_dc_bal_ini || '|';
              --
            end if;
            --
            -- Inclui as notas explicativas relativas as demonstrações contábeis
            if to_number(gv_versaolayoutecd_cd) >= 600 then
              gl_conteudo := gl_conteudo || null || '|';
            end if;
            --
            gn_qtde_reg_j210 := nvl(gn_qtde_reg_j210, 0) + 1;
            --
            vn_fase := 7.2;
            --
            pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'J210',
                                   el_conteudo => gl_conteudo);
            --
            vn_fase := 7.3;
            --
            if to_number(gv_versaolayoutecd_cd) < 700 then
              --
              -- J215: FATO CONTÁBIL QUE ALTERA A CONTA LUCROS ACUMULADOS OU A CONTA PREJUÍZOS ACUMULADOS OU TODO O PATRIMÔNIO LÍQUIDO
              for rec_fato in c_fato(rec.empresa_id, rec_bp2.planoconta_id) loop
                exit when c_fato%notfound or(c_fato%notfound) is null;
                --
                vn_fase := 7.4;
                --                    --
                begin
                  --

                  select sum(decode(lc.dm_ind_dc,
                                    'C',
                                    (nvl(lc.vl_dc, 0) * -1),
                                    nvl(lc.vl_dc, 0)))
                    into vn_vl_fat_cont
                    from TMP_INT_LCTO_CONTABIL lc
                   where lc.empresa_id = rec.empresa_id
                     and lc.planoconta_id = rec_fato.planoconta_id
                     and lc.dt_lcto between rec.dt_ini and rec.dt_fin;
                  /*select sum( decode(pl.dm_ind_dc, 'C', (nvl(pl.vl_dc,0) * -1), nvl(pl.vl_dc,0)) )
                   into vn_vl_fat_cont
                   from int_lcto_contabil lc
                      , int_partida_lcto pl
                  where lc.empresa_id = rec.empresa_id
                    and lc.dt_lcto between rec.dt_ini and rec.dt_fin
                    and pl.intlctocontabil_id = lc.id
                    and pl.planoconta_id = rec_fato.planoconta_id;*/
                  --
                exception
                  when others then
                    vn_vl_fat_cont := 0;
                end;
                --
                vn_fase := 7.5;
                --
                if nvl(vn_vl_fat_cont, 0) <> 0 then
                  --
                  gl_conteudo := '|';
                  gl_conteudo := gl_conteudo || 'J215' || '|';
                  gl_conteudo := gl_conteudo || trim(rec_fato.cod_cta) || '|';
                  --
                  if nvl(vn_vl_fat_cont, 0) < 0 then
                    gl_conteudo := gl_conteudo ||
                                   trim(to_char(nvl(vn_vl_fat_cont, 0) * -1,
                                                '99999999999999990D00')) || '|';
                    gl_conteudo := gl_conteudo || 'C' || '|';
                  else
                    gl_conteudo := gl_conteudo ||
                                   trim(to_char(nvl(vn_vl_fat_cont, 0),
                                                '99999999999999990D00')) || '|';
                    gl_conteudo := gl_conteudo || 'D' || '|';
                  end if;
                  --
                  gn_qtde_reg_j215 := nvl(gn_qtde_reg_j215, 0) + 1;
                  --
                  pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'J215',
                                         el_conteudo => gl_conteudo);
                  --
                end if;
                --
              end loop;
              --
            else
              --
              /*a partir da versão 7.00*/
              for rec_fato_descr in c_fato_descr(rec.empresa_id,
                                                 rec.dt_ini,
                                                 rec.dt_fin,
                                                 rec_bp2.planoconta_id) loop
                exit when c_fato_descr%notfound or(c_fato_descr%notfound) is null;
                -------
                vn_fase := 7.6;
                --
                vn_vl_fat_cont := rec_fato_descr.vn_vl_fat_cont;
                ---
                vn_fase := 7.7;
                --
                if nvl(vn_vl_fat_cont, 0) <> 0 then
                  --
                  gl_conteudo := '|';
                  gl_conteudo := gl_conteudo || 'J215' || '|';
                  gl_conteudo := gl_conteudo ||
                                 trim(rec_fato_descr.cod_cta) || '|';
                  gl_conteudo := gl_conteudo ||
                                 trim(pk_csf.fkg_converte(rec_fato_descr.descr_cta)) || '|'; /*DESC_FAT*/
                  --
                  if nvl(vn_vl_fat_cont, 0) < 0 then
                    gl_conteudo := gl_conteudo ||
                                   trim(to_char(nvl(vn_vl_fat_cont, 0) * -1,
                                                '99999999999999990D00')) || '|';
                    gl_conteudo := gl_conteudo || 'C' || '|';
                  else
                    gl_conteudo := gl_conteudo ||
                                   trim(to_char(nvl(vn_vl_fat_cont, 0),
                                                '99999999999999990D00')) || '|';
                    gl_conteudo := gl_conteudo || 'D' || '|';
                  end if;
                  --
                  gn_qtde_reg_j215 := nvl(gn_qtde_reg_j215, 0) + 1;
                  --
                  pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'J215',
                                         el_conteudo => gl_conteudo);
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
      end if;
      --
      vn_fase := 9;
      -- criação do Registro J800: Outras Informações
      --
      for rec_oi in c_outrasinforecd(rec.demoncontab_id) loop
        exit when c_outrasinforecd%notfound or(c_outrasinforecd%notfound) is null;
        --
        vn_fase := 9.01;
        --
        vn_length      := 0;
        vn_posicao_ini := 0;
        vn_dif         := 0;
        vv_texto       := null;
        --
        begin
          --
          select a.arq_rtf
            into vb_arq_rtf
            from outras_infor_ecd a
           where a.id = rec_oi.outrasinforecd_id;
          --
        exception
          when others then
            vb_arq_rtf := null;
        end;
        --
        gl_conteudo := '|';
        --
        vn_fase := 9.1;
        --
        gl_conteudo := gl_conteudo || 'J800' || '|';
        --
        if to_number(gv_versaolayoutecd_cd) >= 500 then
          --
          gl_conteudo := gl_conteudo || rec_oi.DM_TIPO_DOC || '|';
          gl_conteudo := gl_conteudo || rec_oi.DESCR || '|';
          gl_conteudo := gl_conteudo || rec_oi.HASH_RTF || '|';
          --
        end if;
        --
        vcl_arq := pk_csf.fkg_blob_to_clob(blob_in => vb_arq_rtf);
        --
        vn_fase := 9.2;
        --
        --gl_conteudo := gl_conteudo || to_char(vcl_arq) || '|';
        vn_length := length(vcl_arq);
        --
        if nvl(vn_length, 0) > 0 then
          --
          vn_fase := 9.21;
          if nvl(vn_length, 0) < 4000 then
            vn_dif := nvl(vn_length, 0);
          else
            vn_dif := 4000;
          end if;
          --
          vn_fase        := 9.22;
          vn_posicao_ini := 1;
          --
          loop
            --
            vn_fase := 9.23;
            if nvl(vn_posicao_ini, 0) >= nvl(vn_length, 0) then
              exit;
            end if;
            --
            vn_fase  := 9.24;
            vv_texto := null;
            vv_texto := substr(vcl_arq, vn_posicao_ini, vn_dif);
            --
            vn_fase     := 9.25;
            gl_conteudo := gl_conteudo || vv_texto;
            --
            vn_fase        := 9.26;
            vn_posicao_ini := nvl(vn_posicao_ini, 0) + nvl(vn_dif, 0);
            --
            if length(gl_conteudo) > 31999 then
              --
              pkb_armaz_estr_arq_ecd(ev_reg_blc     => 'J800',
                                     el_conteudo    => gl_conteudo,
                                     en_quebra_line => 0 -- Não quebra linha
                                     );
              --
              gl_conteudo := null;
              --
            end if;
            --
          end loop;
          --
        end if;
        --
        gl_conteudo := gl_conteudo || '|';
        gl_conteudo := gl_conteudo || 'J800FIM' || '|';
        --
        vn_fase := 9.3;
        --
        pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'J800',
                               el_conteudo => gl_conteudo);
        --
        gn_qtde_reg_j800 := nvl(gn_qtde_reg_j800, 0) + 1;
        --
      end loop;
      --
      vn_fase := 10;
      --
      if to_number(gv_versaolayoutecd_cd) >= 500 then
        --
        vn_fase := 10.1;
        -- REGISTRO J801: TERMO DE VERIFICAÇÃO PARA FINS DE SUBSTITUIÇÃO DA ECD
        --
        for rec_ts in c_termosubecd(rec.demoncontab_id) loop
          exit when c_termosubecd%notfound or(c_termosubecd%notfound) is null;
          --
          vn_fase := 10.2;
          --
          vn_length      := 0;
          vn_posicao_ini := 0;
          vn_dif         := 0;
          vv_texto       := null;
          --
          begin
            --
            select a.arq_rtf
              into vb_arq_rtf
              from termo_sub_ecd a
             where a.id = rec_ts.termosubecd_id;
            --
          exception
            when others then
              vb_arq_rtf := null;
          end;
          --
          gl_conteudo := '|';
          --
          vn_fase := 9.1;
          --
          gl_conteudo := gl_conteudo || 'J801' || '|';
          --
          gl_conteudo := gl_conteudo || rec_ts.DM_TIPO_DOC || '|';
          gl_conteudo := gl_conteudo || rec_ts.DESC_RTF || '|';
          ---
          if to_number(gv_versaolayoutecd_cd) >= 700 then
            ---
            gl_conteudo := gl_conteudo || rec_ts.cod_mot_subs || '|';
            ---
          end if;
          ---
          gl_conteudo := gl_conteudo || rec_ts.HASH_RTF || '|';
          --
          vcl_arq := pk_csf.fkg_blob_to_clob(blob_in => vb_arq_rtf);
          --
          vn_fase := 9.2;
          --
          vn_length := length(vcl_arq);
          --
          if nvl(vn_length, 0) > 0 then
            --
            vn_fase := 9.21;
            if nvl(vn_length, 0) < 4000 then
              vn_dif := nvl(vn_length, 0);
            else
              vn_dif := 4000;
            end if;
            --
            vn_fase        := 9.22;
            vn_posicao_ini := 1;
            --
            loop
              --
              vn_fase := 9.23;
              if nvl(vn_posicao_ini, 0) >= nvl(vn_length, 0) then
                exit;
              end if;
              --
              vn_fase  := 9.24;
              vv_texto := null;
              vv_texto := substr(vcl_arq, vn_posicao_ini, vn_dif);
              --
              vn_fase     := 9.25;
              gl_conteudo := gl_conteudo || vv_texto;
              --
              vn_fase        := 9.26;
              vn_posicao_ini := nvl(vn_posicao_ini, 0) + nvl(vn_dif, 0);
              --
              if length(gl_conteudo) > 31999 then
                --
                pkb_armaz_estr_arq_ecd(ev_reg_blc     => 'J801',
                                       el_conteudo    => gl_conteudo,
                                       en_quebra_line => 0 -- Não quebra linha
                                       );
                --
                gl_conteudo := null;
                --
              end if;
              --
            end loop;
            --
          end if;
          --
          gl_conteudo := gl_conteudo || '|';
          gl_conteudo := gl_conteudo || 'J801FIM' || '|'; /*IND_FIM_RTF*/
          --
          vn_fase := 9.3;
          --
          pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'J801',
                                 el_conteudo => gl_conteudo);
          --
          gn_qtde_reg_j801 := nvl(gn_qtde_reg_j801, 0) + 1;
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
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_j005 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_j005;

-------------------------------------------------------------------------------------------------------
-- Procedimento monta registro do Registro J900: Termo de encerramento
-------------------------------------------------------------------------------------------------------
procedure pkb_monta_bloco_j900 is
  --
  vn_fase      number := 0;
  vn_pessoa_id pessoa.id%type := null;
  vv_email     pessoa.email%type := null;
  vv_fone      pessoa.fone%type := null;
  vv_uf        estado.sigla_estado%type := null;
  --
  cursor c_encerra is
    select e.id      encerraecd_id,
           e.num_ord, 
           /*e.nat_livro*/
           tec.sigla nat_livro,
           e.qtd_lin
      from encerra_ecd e, 
           tipo_escr_contab tec
     where /*e.nat_livro      = to_char(tec.id)*/
          (e.nat_livro = to_char(tec.id) 
           or substr(e.nat_livro,1,1) = tec.sigla) 
       and e.aberturaecd_id = gn_aberturaecd_id;
  --
  cursor c_signatario(en_encerraecd_id encerra_ecd.id%type) is
    select ise.ident_nom,
           ise.ident_cpf,
           qa.ident_assin,
           qa.cod_assin,
           ise.ind_crc,
           ise.dt_crc,
           ise.dm_ind_resp_legal
      from ident_sig_escr ise, 
           qualif_assin qa
     where ise.encerraecd_id     = en_encerraecd_id
       and ise.dm_resp_ver_subst = 'N'
       and qa.id                 = ise.qualifassin_id
     order by ise.ident_nom;
  --
  cursor c_signatario_subst(en_encerraecd_id encerra_ecd.id%type) is
    select ise.ident_nom,
           ise.ident_cpf,
           qa.ident_assin,
           qa.cod_assin,
           ise.ind_crc,
           ise.dt_crc,
           ise.dm_ind_resp_legal
      from ident_sig_escr ise, 
           qualif_assin qa
     where ise.encerraecd_id     = en_encerraecd_id
       and ise.dm_resp_ver_subst = 'S'
       and qa.id                 = ise.qualifassin_id
     order by ise.ident_nom;
  --
  cursor c_termo_abert is
    select tal.*
      from termo_abert_livro tal
     where tal.aberturaecd_id = gn_aberturaecd_id;
  --
  cursor c_aud(en_encerraecd_id encerra_ecd.id%type) is
    select *
      from ident_aud_ind
     where encerraecd_id = en_encerraecd_id
     order by nome_auditor;
  --

begin
  --
  vn_fase := 1;
  --
  for rec in c_encerra loop
    exit when c_encerra%notfound or(c_encerra%notfound) is null;
    --
    vn_fase := 2;
    --
    gl_conteudo := '|'; 
    --
    gl_conteudo := gl_conteudo || 'J900' || '|';
    gl_conteudo := gl_conteudo || 'TERMO DE ENCERRAMENTO' || '|';
    gl_conteudo := gl_conteudo || rec.num_ord || '|';
    gl_conteudo := gl_conteudo || trim(rec.nat_livro) || '|'; 
    gl_conteudo := gl_conteudo || pk_csf.fkg_converte(vt_tab_reg_0000(1).nome) || '|';
    gl_conteudo := gl_conteudo || 0 || '|';
    gl_conteudo := gl_conteudo || to_char(vt_tab_reg_0000(1).dt_ini, 'ddmmrrrr') || '|';
    gl_conteudo := gl_conteudo || to_char(vt_tab_reg_0000(1).dt_fin, 'ddmmrrrr') || '|';
    --
    gn_qtde_reg_j900 := nvl(gn_qtde_reg_j900, 0) + 1;
    --
    vn_fase := 2.1;
    --
    pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'J900',
                           el_conteudo => gl_conteudo);
    --
    vn_fase := 3;
    --
    -- Criação do Registro J930: Identificação dos Signatários da Escrituração
    for rec_sig in c_signatario(rec.encerraecd_id) loop
      exit when c_signatario%notfound or(c_signatario%notfound) is null;
      --
      vn_fase := 4;
      --
      gl_conteudo := '|';
      --
      gl_conteudo := gl_conteudo || 'J930' || '|';
      gl_conteudo := gl_conteudo || trim(pk_csf.fkg_converte(rec_sig.ident_nom)) || '|';
      gl_conteudo := gl_conteudo || rec_sig.ident_cpf || '|';
      gl_conteudo := gl_conteudo || rec_sig.ident_assin || '|';
      gl_conteudo := gl_conteudo || rec_sig.cod_assin || '|';
      --
      if rec_sig.cod_assin = '900' then
        --
        begin
          select p.id, 
                 p.email, 
                 p.fone
            into vn_pessoa_id, 
                 vv_email, 
                 vv_fone
            from contador c, 
                 pessoa p
           where c.crc       = rec_sig.ind_crc
             and c.pessoa_id = p.id
             and rownum      = 1;
        exception
          when others then
            vn_pessoa_id := null;
            vv_email     := null;
            vv_fone      := null;
        end;
        --
        vv_uf := pk_csf.fkg_siglaestado_pessoaid(en_pessoa_id => vn_pessoa_id);
        --
        gl_conteudo := gl_conteudo || rec_sig.ind_crc || '|';
        gl_conteudo := gl_conteudo || vv_email || '|';
        gl_conteudo := gl_conteudo || vv_fone || '|';
        gl_conteudo := gl_conteudo || vv_uf || '|';
        gl_conteudo := gl_conteudo || vv_uf || '/' || to_char(rec_sig.dt_crc, 'RRRR') || '/' || rec_sig.ind_crc || '|';
        gl_conteudo := gl_conteudo || to_char(rec_sig.dt_crc, 'ddmmrrrr') || '|';
        --
      else
        --
        gl_conteudo := gl_conteudo || '|';
        gl_conteudo := gl_conteudo || '|';
        gl_conteudo := gl_conteudo || '|';
        gl_conteudo := gl_conteudo || '|';
        gl_conteudo := gl_conteudo || '|';
        gl_conteudo := gl_conteudo || '|';
        --
      end if;
      --
      if to_number(gv_versaolayoutecd_cd) >= 500 then -- 12-IND_RESP_LEGAL Identificação do signatário que será validado como responsável legal da empresa junto as bases da RFB
        --
        gl_conteudo := gl_conteudo || rec_sig.dm_ind_resp_legal || '|';
        --
      else
        --
        gl_conteudo := gl_conteudo || 'S|'; -- Default para versões anteriores
        --
      end if;
      --
      gn_qtde_reg_j930 := nvl(gn_qtde_reg_j930, 0) + 1;
      --
      pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'J930',
                             el_conteudo => gl_conteudo);
      --
    end loop;
    --
    vn_fase := 5;
    --
    --if to_number(gv_versaolayoutecd_cd) >= 700 then
    ---
    if vt_tab_reg_0000(1).ind_fin_esc <> '0' then
      --
      /* Criação do registro J932: Signatários do Termo de Verificação para Fins de Substituição da ECD*/
      for rec_subst in c_signatario_subst(rec.encerraecd_id) loop
        exit when c_signatario_subst%notfound or(c_signatario_subst%notfound) is null;
        --
        vn_fase := 5.1;
        --
        gl_conteudo := '|';
        --
        gl_conteudo := gl_conteudo || 'J932' || '|';
        gl_conteudo := gl_conteudo || trim(pk_csf.fkg_converte(rec_subst.ident_nom)) || '|';
        gl_conteudo := gl_conteudo || rec_subst.ident_cpf || '|';
        gl_conteudo := gl_conteudo || rec_subst.ident_assin || '|';
        gl_conteudo := gl_conteudo || rec_subst.cod_assin || '|';
        --
        begin
          select p.id, 
                 p.email, 
                 p.fone
            into vn_pessoa_id, 
                 vv_email, 
                 vv_fone
            from contador c, 
                 pessoa p
           where c.crc       = rec_subst.ind_crc
             and c.pessoa_id = p.id
             and rownum      = 1;
        exception
          when others then
            vn_pessoa_id := null;
            vv_email     := null;
            vv_fone      := null;
        end;
        --
        vv_uf := pk_csf.fkg_siglaestado_pessoaid(en_pessoa_id => vn_pessoa_id);
        --
        gl_conteudo := gl_conteudo || rec_subst.ind_crc || '|';
        gl_conteudo := gl_conteudo || vv_email || '|';
        gl_conteudo := gl_conteudo || vv_fone || '|';
        gl_conteudo := gl_conteudo || vv_uf || '|';
        gl_conteudo := gl_conteudo || vv_uf || '/' || to_char(rec_subst.dt_crc, 'RRRR') || '/' || rec_subst.ind_crc || '|';
        gl_conteudo := gl_conteudo || to_char(rec_subst.dt_crc, 'ddmmrrrr') || '|';
        --
        gn_qtde_reg_j932 := nvl(gn_qtde_reg_j932, 0) + 1;
        --
        pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'J932',
                               el_conteudo => gl_conteudo);
        --
      end loop;
    end if;
    --
    --end if;
    --
    vn_fase := 6;
    --
    if gv_versaolayoutecd_cd >= '300' then -- Registro J935: Identificação dos Auditores Independentes
      --
      vn_fase := 6.1;
      for rec_tal in c_termo_abert loop
        exit when c_termo_abert%notfound or(c_termo_abert%notfound) is null;
        --
        if trim(pk_csf.fkg_converte(rec_tal.nome_auditor)) is not null and trim(rec_tal.cod_cvm_auditor) is not null then
          --
          gl_conteudo := '|';
          gl_conteudo := gl_conteudo || 'J935' || '|';
          --
          /*if to_number(gv_versaolayoutecd_cd) >= 700 then*/
          if gv_versaolayoutecd_cd >= '700' then
            --
            gl_conteudo := gl_conteudo || trim(pk_csf.fkg_converte(rec_tal.ni_cpf_cnpj)) || '|';
            --
          end if;
          --
          gl_conteudo := gl_conteudo || trim(pk_csf.fkg_converte(rec_tal.nome_auditor)) || '|';
          gl_conteudo := gl_conteudo || trim(rec_tal.cod_cvm_auditor) || '|';
          --
          gn_qtde_reg_j935 := nvl(gn_qtde_reg_j935, 0) + 1;
          --
          pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'J935',
                                 el_conteudo => gl_conteudo);
          --
        end if;
        --
      --
      end loop;
      --
      vn_fase := 6.2;
      --
      /*Caso não for gerado nenhum registro pelo cursor c_termo_abert, 
      será gerado registro J935 pelo cursor c_aud.*/
      --
      if nvl(gn_qtde_reg_j935, 0) = 0 then
        --
        for rec_aud in c_aud(rec.encerraecd_id) loop
          exit when c_aud%notfound or(c_aud%notfound) is null;
          --
          gl_conteudo := '|';
          gl_conteudo := gl_conteudo || 'J935' || '|';
          ---
          /*if to_number(gv_versaolayoutecd_cd) >= 700 then*/
          if gv_versaolayoutecd_cd >= '700' then
            --
            gl_conteudo := gl_conteudo || trim(pk_csf.fkg_converte(rec_aud.ni_cpf_cnpj)) || '|';
            --
          end if;
          ---
          gl_conteudo := gl_conteudo || trim(pk_csf.fkg_converte(rec_aud.nome_auditor)) || '|';
          gl_conteudo := gl_conteudo || trim(rec_aud.cod_cvm_auditor) || '|';
          --
          gn_qtde_reg_j935 := nvl(gn_qtde_reg_j935, 0) + 1;
          --
          pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'J935',
                                 el_conteudo => gl_conteudo);
          --
        end loop;
        --
      end if;
      --
    end if;
    --
  end loop;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_j900 fase(' || vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_j900;

-------------------------------------------------------------------------------------------------------

-- Procedimento monta registro do Registro J990: Encerramento do Bloco J
procedure pkb_monta_bloco_j990 is
  
  vn_fase number := 0;
  
  vn_qtde_total number := 0;
  
begin
  --
  vn_fase := 1;
  --
  gn_qtde_reg_j990 := 1;
  --
  vn_fase := 2;
  --
  vn_qtde_total := nvl(gn_qtde_reg_j001, 0) + nvl(gn_qtde_reg_j005, 0) +
                   nvl(gn_qtde_reg_j100, 0) + nvl(gn_qtde_reg_j150, 0) +
                   nvl(gn_qtde_reg_j200, 0) + nvl(gn_qtde_reg_j210, 0) +
                   nvl(gn_qtde_reg_j215, 0) + nvl(gn_qtde_reg_j800, 0) +
                   nvl(gn_qtde_reg_j801, 0) + nvl(gn_qtde_reg_j900, 0) +
                   nvl(gn_qtde_reg_j930, 0) + nvl(gn_qtde_reg_j932, 0) +
                   nvl(gn_qtde_reg_j935, 0) + nvl(gn_qtde_reg_j990, 0);
  
  --
  vn_fase := 3;
  --
  gl_conteudo := '|';
  --
  gl_conteudo := gl_conteudo || 'J990' || '|';
  gl_conteudo := gl_conteudo || nvl(vn_qtde_total, 0) || '|';
  --
  vn_fase := 3;
  --
  pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'J990',
                         el_conteudo => gl_conteudo);
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_j990 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_j990;

-------------------------------------------------------------------------------------------------------

-- procedimento monta o registro do BLOCO J: DEMONSTRAÇÕES CONTÁBEIS
procedure pkb_monta_bloco_j is
  
  vn_fase number := 0;
  
begin
  --
  vn_fase := 1;
  -- criação do Registro J001: Abertura do Bloco J
  gl_conteudo := '|';
  --
  gl_conteudo := gl_conteudo || 'J001' || '|';
  gl_conteudo := gl_conteudo || 0 || '|';
  --
  gn_qtde_reg_j001 := 1;
  --
  pkb_armaz_estr_arq_ecd(ev_reg_blc  => 'J001',
                         el_conteudo => gl_conteudo);
  --
  vn_fase := 2;
  -- criação do Registro J005: Demonstrações contábeis
  pkb_monta_bloco_j005;
  --
  vn_fase := 3;
  -- criação do Registro J900: Termo de encerramento
  pkb_monta_bloco_j900;
  --
  vn_fase := 4;
  -- criação do Registro J990: Encerramento do Bloco J
  pkb_monta_bloco_j990;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_j fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_j;

-------------------------------------------------------------------------------------------------------

-- Procedimento monta os registro do Registro 9900: Registros do arquivo
procedure pkb_monta_bloco_9900 is
  
  vn_fase number := 0;
  
  procedure pkb_ins_array(ev_reg_blc     in varchar2,
                          en_qtd_reg_blc in number) is
    
  begin
    --
    if ev_reg_blc is not null and nvl(en_qtd_reg_blc, 0) > 0 then
      --
      gl_conteudo := '|';
      --
      gl_conteudo := gl_conteudo || '9900' || '|';
      gl_conteudo := gl_conteudo || ev_reg_blc || '|';
      gl_conteudo := gl_conteudo || en_qtd_reg_blc || '|';
      --
      gn_qtde_reg_9900 := nvl(gn_qtde_reg_9900, 0) + 1;
      --
      pkb_armaz_estr_arq_ecd(ev_reg_blc  => '9900',
                             el_conteudo => gl_conteudo);
      --
    end if;
    --
  end pkb_ins_array;
  
begin
  --
  vn_fase := 1;
  --
  pkb_ins_array(ev_reg_blc => '0000', en_qtd_reg_blc => gn_qtde_reg_0000);
  --
  vn_fase := 3;
  --
  pkb_ins_array(ev_reg_blc => '0001', en_qtd_reg_blc => gn_qtde_reg_0001);
  --
  vn_fase := 5;
  --
  pkb_ins_array(ev_reg_blc => '0007', en_qtd_reg_blc => gn_qtde_reg_0007);
  --
  vn_fase := 7;
  --
  pkb_ins_array(ev_reg_blc => '0020', en_qtd_reg_blc => gn_qtde_reg_0020);
  --
  vn_fase := 8;
  --
  pkb_ins_array(ev_reg_blc => '0035', en_qtd_reg_blc => gn_qtde_reg_0035);
  --
  vn_fase := 9;
  --
  pkb_ins_array(ev_reg_blc => '0150', en_qtd_reg_blc => gn_qtde_reg_0150);
  --
  vn_fase := 11;
  --
  pkb_ins_array(ev_reg_blc => '0180', en_qtd_reg_blc => gn_qtde_reg_0180);
  --
  vn_fase := 13;
  --
  pkb_ins_array(ev_reg_blc => '0990', en_qtd_reg_blc => gn_qtde_reg_0990);
  --
  vn_fase := 15;
  --
  pkb_ins_array(ev_reg_blc => 'I001', en_qtd_reg_blc => gn_qtde_reg_i001);
  --
  vn_fase := 17;
  --
  pkb_ins_array(ev_reg_blc => 'I010', en_qtd_reg_blc => gn_qtde_reg_i010);
  --
  vn_fase := 19;
  --
  pkb_ins_array(ev_reg_blc => 'I012', en_qtd_reg_blc => gn_qtde_reg_i012);
  --
  vn_fase := 21;
  --
  pkb_ins_array(ev_reg_blc => 'I015', en_qtd_reg_blc => gn_qtde_reg_i015);
  --
  vn_fase := 23;
  --
  pkb_ins_array(ev_reg_blc => 'I020', en_qtd_reg_blc => gn_qtde_reg_i020);
  --
  vn_fase := 24;
  --
  pkb_ins_array(ev_reg_blc => 'I030', en_qtd_reg_blc => gn_qtde_reg_i030);
  --
  vn_fase := 26;
  --
  pkb_ins_array(ev_reg_blc => 'I050', en_qtd_reg_blc => gn_qtde_reg_i050);
  --
  vn_fase := 28;
  --
  pkb_ins_array(ev_reg_blc => 'I051', en_qtd_reg_blc => gn_qtde_reg_i051);
  --
  vn_fase := 30;
  --
  pkb_ins_array(ev_reg_blc => 'I052', en_qtd_reg_blc => gn_qtde_reg_i052);
  --
  vn_fase := 31;
  --
  pkb_ins_array(ev_reg_blc => 'I053', en_qtd_reg_blc => gn_qtde_reg_i053);
  --
  vn_fase := 32;
  --
  pkb_ins_array(ev_reg_blc => 'I075', en_qtd_reg_blc => gn_qtde_reg_i075);
  --
  vn_fase := 34;
  --
  pkb_ins_array(ev_reg_blc => 'I100', en_qtd_reg_blc => gn_qtde_reg_i100);
  --
  vn_fase := 36;
  --
  pkb_ins_array(ev_reg_blc => 'I150', en_qtd_reg_blc => gn_qtde_reg_i150);
  --
  vn_fase := 38;
  --
  pkb_ins_array(ev_reg_blc => 'I155', en_qtd_reg_blc => gn_qtde_reg_i155);
  --
  vn_fase := 39;
  --
  pkb_ins_array(ev_reg_blc => 'I157', en_qtd_reg_blc => gn_qtde_reg_i157);
  --
  vn_fase := 40;
  --
  pkb_ins_array(ev_reg_blc => 'I200', en_qtd_reg_blc => gn_qtde_reg_i200);
  --
  vn_fase := 42;
  --
  pkb_ins_array(ev_reg_blc => 'I250', en_qtd_reg_blc => gn_qtde_reg_i250);
  --
  vn_fase := 44;
  --
  pkb_ins_array(ev_reg_blc => 'I300', en_qtd_reg_blc => gn_qtde_reg_i300);
  --
  vn_fase := 46;
  --
  pkb_ins_array(ev_reg_blc => 'I310', en_qtd_reg_blc => gn_qtde_reg_i310);
  --
  vn_fase := 48;
  --
  pkb_ins_array(ev_reg_blc => 'I350', en_qtd_reg_blc => gn_qtde_reg_i350);
  --
  vn_fase := 50;
  --
  pkb_ins_array(ev_reg_blc => 'I355', en_qtd_reg_blc => gn_qtde_reg_i355);
  --
  vn_fase := 52;
  --
  pkb_ins_array(ev_reg_blc => 'I500', en_qtd_reg_blc => gn_qtde_reg_i500);
  --
  vn_fase := 54;
  --
  pkb_ins_array(ev_reg_blc => 'I510', en_qtd_reg_blc => gn_qtde_reg_i510);
  --
  vn_fase := 56;
  --
  pkb_ins_array(ev_reg_blc => 'I550', en_qtd_reg_blc => gn_qtde_reg_i550);
  --
  vn_fase := 58;
  --
  pkb_ins_array(ev_reg_blc => 'I555', en_qtd_reg_blc => gn_qtde_reg_i555);
  --
  vn_fase := 60;
  --
  pkb_ins_array(ev_reg_blc => 'I990', en_qtd_reg_blc => gn_qtde_reg_i990);
  --
  vn_fase := 62;
  --
  --
  -- registros do Bloco J
  pkb_ins_array(ev_reg_blc => 'J001', en_qtd_reg_blc => gn_qtde_reg_j001);
  --
  vn_fase := 64;
  --
  pkb_ins_array(ev_reg_blc => 'J005', en_qtd_reg_blc => gn_qtde_reg_j005);
  --
  vn_fase := 66;
  --
  pkb_ins_array(ev_reg_blc => 'J100', en_qtd_reg_blc => gn_qtde_reg_j100);
  --
  vn_fase := 68;
  --
  pkb_ins_array(ev_reg_blc => 'J150', en_qtd_reg_blc => gn_qtde_reg_j150);
  --
  pkb_ins_array(ev_reg_blc => 'J200', en_qtd_reg_blc => gn_qtde_reg_j200);
  --
  pkb_ins_array(ev_reg_blc => 'J210', en_qtd_reg_blc => gn_qtde_reg_j210);
  --
  pkb_ins_array(ev_reg_blc => 'J215', en_qtd_reg_blc => gn_qtde_reg_j215);
  --
  vn_fase := 69.1;
  --
  pkb_ins_array(ev_reg_blc => 'J800', en_qtd_reg_blc => gn_qtde_reg_j800);
  --
  vn_fase := 69.1;
  --
  pkb_ins_array(ev_reg_blc => 'J801', en_qtd_reg_blc => gn_qtde_reg_j801);
  --
  vn_fase := 70;
  --
  --vn_qtde_reg_j800 := 0;
  pkb_ins_array(ev_reg_blc => 'J900', en_qtd_reg_blc => gn_qtde_reg_j900);
  --
  vn_fase := 72;
  --
  pkb_ins_array(ev_reg_blc => 'J930', en_qtd_reg_blc => gn_qtde_reg_j930);
  --
  vn_fase := 72.1;
  --
  pkb_ins_array(ev_reg_blc => 'J932', en_qtd_reg_blc => gn_qtde_reg_j932);
  --
  vn_fase := 73;
  --
  pkb_ins_array(ev_reg_blc => 'J935', en_qtd_reg_blc => gn_qtde_reg_j935);
  --
  vn_fase := 74;
  --
  pkb_ins_array(ev_reg_blc => 'J990', en_qtd_reg_blc => gn_qtde_reg_j990);
  --
  vn_fase := 76;
  --
  --
  -- registros do bloco 9
  pkb_ins_array(ev_reg_blc => '9001', en_qtd_reg_blc => gn_qtde_reg_9001);
  --
  vn_fase := 78;
  --
  pkb_ins_array(ev_reg_blc     => '9900',
                en_qtd_reg_blc => (gn_qtde_reg_9900 + 3));
  --
  vn_fase := 81;
  --
  pkb_ins_array(ev_reg_blc => '9990', en_qtd_reg_blc => 1);
  --
  vn_fase := 83;
  --
  pkb_ins_array(ev_reg_blc => '9999', en_qtd_reg_blc => 1);
  --
  vn_fase := 80;
  -- criação do Registro 9990: Encerramento do bloco 9
  gl_conteudo := '|';
  --
  gl_conteudo := gl_conteudo || '9990' || '|';
  gl_conteudo := gl_conteudo ||
                 (nvl(gn_qtde_reg_9001, 0) + nvl(gn_qtde_reg_9900, 0) + 2) || '|';
  --
  gn_qtde_reg_9990 := 1;
  --
  vn_fase := 3;
  --
  pkb_armaz_estr_arq_ecd(ev_reg_blc  => '9990',
                         el_conteudo => gl_conteudo);
  --
  vn_fase := 82;
  -- criação do Registro 9999: ENCERRAMENTO DO ARQUIVO DIGITAL
  gl_conteudo := '|';
  --
  gl_conteudo := gl_conteudo || '9999' || '|';
  gl_conteudo := gl_conteudo || 0 || '|';
  --
  gn_qtde_reg_9999 := 1;
  --
  pkb_armaz_estr_arq_ecd(ev_reg_blc  => '9999',
                         el_conteudo => gl_conteudo);
  
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_9900 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_9900;

-------------------------------------------------------------------------------------------------------

-- Procedimento monta os registro do BLOCO 9: CONTROLE E ENCERRAMENTO DO ARQUIVO DIGITAL
procedure pkb_monta_bloco_9 is
  
  vn_fase number := 0;
  
begin
  --
  vn_fase := 1;
  -- criação do Registro 9001: Abertura do bloco 9
  gl_conteudo := '|';
  --
  gl_conteudo := gl_conteudo || '9001' || '|';
  gl_conteudo := gl_conteudo || 0 || '|';
  --
  gn_qtde_reg_9001 := 1;
  --
  vn_fase := 2;
  --
  pkb_armaz_estr_arq_ecd(ev_reg_blc  => '9001',
                         el_conteudo => gl_conteudo);
  --
  vn_fase := 3;
  -- criação do Registro 9900: Registros do arquivo
  pkb_monta_bloco_9900;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_bloco_9 fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_monta_bloco_9;

-------------------------------------------------------------------------------------------------------

-- Cálcula todas de linhas do arquivo e atualiza os campos com o mesmo
procedure pkb_total_linhas is
  
  vn_fase number := 0;
  
  vn_qtde_total_linhas number := 0;
  
  vv_texto varchar2(4000);
  
  cursor c_dados is
    select e.*
      from estr_arq_ecd e, registro_ecd r
     where e.aberturaecd_id = gn_aberturaecd_id
       and r.id = e.registroecd_id
       and r.cod in ('I030', 'J900', '9999');
  
begin
  --
  vn_fase := 1;
  -- soma o total de linhas do arquivo ( 0990 + I990 + J990 + 9990 )
  begin
    --
    select count(1)
      into vn_qtde_total_linhas
      from estr_arq_ecd
     where aberturaecd_id = gn_aberturaecd_id;
    --
  exception
    when others then
      vn_qtde_total_linhas := 0;
  end;
  --
  vn_fase := 2;
  -- Atualiza os registro que tem que ter o "total de linhas do arquivo"
  -- vt_tab_reg_i030(1).qtd_lin := nvl(vn_qtde_total_linhas,0);
  --
  vn_fase := 3;
  --
  -- vt_tab_reg_j900(1).qtd_lin := nvl(vn_qtde_total_linhas,0);
  --
  vn_fase := 4;
  --
  -- vt_tab_reg_9999(1).qtd_lin := nvl(vn_qtde_total_linhas,0);
  --
  for rec in c_dados loop
    exit when c_dados%notfound or(c_dados%notfound) is null;
    --
    vv_texto := rec.conteudo;
    --
    vv_texto := replace(vv_texto,
                        '|0|',
                        '|' || nvl(vn_qtde_total_linhas, 0) || '|');
    --
    update estr_arq_ecd set conteudo = vv_texto where id = rec.id;
    --
  end loop;
  --
  commit;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_total_linhas fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_total_linhas;

-------------------------------------------------------------------------------------------------------

-- Procedimento exclui a estrutura do arquivo do Sped Contábil já gerado

procedure pkb_exclui_estr_arq_ecd is
  
  vn_fase number := 0;
  SQL_EXC VARCHAR2(255);
  
begin
  --
  declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => 'LIMPANDO ARQUIVO ',
                                         ev_resumo           => 'LIMPANDO ARQUIVO ',
                                         en_tipo_log         => pk_csf_api_ecd.INFORMACAO,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
  --
  SQL_EXC := 'delete from estr_arq_ecd where aberturaecd_id = ' ||
             gn_aberturaecd_id;
  --
  EXECUTE IMMEDIATE SQL_EXC;
  
  commit;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_monta_estr_arq_ecd fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_exclui_estr_arq_ecd;

-------------------------------------------------------------------------------------------------------

-- Atualiza a Situação da ECD
procedure pkb_atual_sit_ecd(en_aberturaecd_id in abertura_ecd.id%type,
                            en_dm_situacao    in abertura_ecd.dm_situacao%type) is
  
  vn_fase number := 0;
  
begin
  --
  vn_fase := 1;
  --
  update abertura_ecd
     set dm_situacao = en_dm_situacao
   where id = en_aberturaecd_id;
  --
  vn_fase := 2;
  --
  commit;
  --
exception
  when others then
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_atual_sit_ecd fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => en_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_atual_sit_ecd;

-------------------------------------------------------------------------------------------------------

-- Procedimento inicia montagem da estrutura do arquivo texto do SPED Contábil

procedure pkb_gera_arquivo_ecd(en_aberturaecd_id in abertura_ecd.id%type) is
  --
  vn_fase           number := 0;
  vn_loggenerico_id log_generico_dc.id%TYPE;
  
  --
begin
  --
  declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => 'INICIANDO GERAÇÃO ',
                                         ev_resumo           => 'INICIANDO GERAÇÃO ',
                                         en_tipo_log         => pk_csf_api_ecd.INFORMACAO,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
  --
  vn_fase := 1;
  --
  begin
    select a.empresa_id, a.dt_ini, a.dt_fim
      into en_empresa_id, ed_dt_ini, ed_dt_fin
      from abertura_ecd a
     where id = en_aberturaecd_id;
  exception
    when others then
      en_empresa_id := null;
      ed_dt_ini     := null;
      ed_dt_fin     := null;
  end;
  
  --
  pkb_inicia_dados;
  --
  vn_fase := 2;
  --
  delete from log_generico_dc
   where referencia_id = en_aberturaecd_id
     and obj_referencia = 'ABERTURA_ECD';
  --
  if nvl(en_aberturaecd_id, 0) > 0 then
    --
    pkb_carrega_lctos(en_empresa_id => en_empresa_id,
                      ed_dt_ini     => ed_dt_ini,
                      ed_dt_fin     => ed_dt_fin);
    --
    vn_fase := 3;
    --
    pkb_inicia_param(en_aberturaecd_id);
    --
    pkb_atual_sit_ecd(en_aberturaecd_id => en_aberturaecd_id,
                          en_dm_situacao    => 12);
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => 'ALTERANDO SITUAÇÃO PARA EM GERAÇÃO ',
                                         ev_resumo           => 'ALTERANDO SITUAÇÃO PARA EM GERAÇÃO ',
                                         en_tipo_log         => pk_csf_api_ecd.INFORMACAO,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
    if nvl(gn_aberturaecd_id, 0) > 0 then
      --
      if gv_versaolayoutecd_cd is not null then
        --
        vn_fase := 4;
        -- Procedimento exclui a estrutura do arquivo do Sped Contábil já gerado
        pkb_exclui_estr_arq_ecd;
        --
        vn_fase := 5;
        -- recupera dados da empresa que esta sendo gerado o Sped Contábil
        pkb_dados_empresa;
        --
        vn_fase := 6;
        --
        pkb_atual_sit_ecd(en_aberturaecd_id => en_aberturaecd_id,
                          en_dm_situacao    => 13);
        --
        declare
          vn_loggenerico_id log_generico_dc.id%TYPE;
        begin
          --
          pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                             ev_mensagem         => 'ALTERANDO SITUAÇÃO PARA EM GERAÇÃO BLOCO 0 ',
                                             ev_resumo           => 'ALTERANDO SITUAÇÃO PARA EM GERAÇÃO BLOCO 0 ',
                                             en_tipo_log         => pk_csf_api_ecd.INFORMACAO,
                                             en_referencia_id    => gn_aberturaecd_id,
                                             ev_obj_referencia   => 'ABERTURA_ECD');
          --
        exception
          when others then
            null;
        end;                  
        -- procedimento monta os registros do BLOCO 0
        pkb_monta_bloco_0;
        --
        vn_fase := 7;
        --
        pkb_atual_sit_ecd(en_aberturaecd_id => en_aberturaecd_id,
                          en_dm_situacao    => 14);
        declare
          vn_loggenerico_id log_generico_dc.id%TYPE;
        begin
          --
          pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                             ev_mensagem         => 'ALTERANDO SITUAÇÃO PARA EM GERAÇÃO BLOCO I ',
                                             ev_resumo           => 'ALTERANDO SITUAÇÃO PARA EM GERAÇÃO BLOCO I ',
                                             en_tipo_log         => pk_csf_api_ecd.INFORMACAO,
                                             en_referencia_id    => gn_aberturaecd_id,
                                             ev_obj_referencia   => 'ABERTURA_ECD');
          --
        exception
          when others then
            null;
        end;
        -- procedimento monta os registros do BLOCO I: LANÇAMENTOS CONTÁBEIS
        pkb_monta_bloco_i;
        --
        pkb_atual_sit_ecd(en_aberturaecd_id => en_aberturaecd_id,
                          en_dm_situacao    => 15);
        --
        declare
          vn_loggenerico_id log_generico_dc.id%TYPE;
        begin
          --
          pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                             ev_mensagem         => 'ALTERANDO SITUAÇÃO PARA EM GERAÇÃO BLOCO J ',
                                             ev_resumo           => 'ALTERANDO SITUAÇÃO PARA EM GERAÇÃO BLOCO J ',
                                             en_tipo_log         => pk_csf_api_ecd.INFORMACAO,
                                             en_referencia_id    => gn_aberturaecd_id,
                                             ev_obj_referencia   => 'ABERTURA_ECD');
          --
        exception
          when others then
            null;
        end;
        --
        vn_fase := 8;
        -- procedimento monta os registros do BLOCO J: DEMONSTRAÇÕES CONTÁBEIS
        pkb_monta_bloco_j;
        --
        pkb_atual_sit_ecd(en_aberturaecd_id => en_aberturaecd_id,
                          en_dm_situacao    => 16);
        --
        declare
          vn_loggenerico_id log_generico_dc.id%TYPE;
        begin
          --
          pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                             ev_mensagem         => 'ALTERANDO SITUAÇÃO PARA EM GERAÇÃO BLOCO 9 ',
                                             ev_resumo           => 'ALTERANDO SITUAÇÃO PARA EM GERAÇÃO BLOCO 9 ',
                                             en_tipo_log         => pk_csf_api_ecd.INFORMACAO,
                                             en_referencia_id    => gn_aberturaecd_id,
                                             ev_obj_referencia   => 'ABERTURA_ECD');
          --
        exception
          when others then
            null;
        end;
        --
        vn_fase := 9;
        -- procedimento monta os registro do BLOCO 9: CONTROLE E ENCERRAMENTO DO ARQUIVO DIGITAL
        pkb_monta_bloco_9;
        --
        vn_fase := 10;
        -- Cálcula todas de linhas do arquivo
        pkb_total_linhas;
        --
        vn_fase := 12;
        --
        --pk_gera_arq_fcont.pkb_gera_arquivo_fcont(en_aberturaecd_id);
        --
        pkb_atual_sit_ecd(en_aberturaecd_id => en_aberturaecd_id,
                          en_dm_situacao    => 3); -- Gerado Aquivo ECD
        --
      else
        --
        pkb_atual_sit_ecd(en_aberturaecd_id => en_aberturaecd_id,
                          en_dm_situacao    => 6); -- Erro na geração
        --
        pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                           ev_mensagem         => 'Problemas na geração.',
                                           ev_resumo           => 'Versão do SPED Contábil não encontrada para o periodo informado.',
                                           en_tipo_log         => pk_csf_api_ecd.ERRO_DE_VALIDACAO,
                                           en_referencia_id    => en_aberturaecd_id,
                                           ev_obj_referencia   => 'ABERTURA_ECD');
        --
      end if;
      --
    else
      --
      pkb_atual_sit_ecd(en_aberturaecd_id => en_aberturaecd_id,
                          en_dm_situacao    => 2);
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => 'Problemas na geração.',
                                         ev_resumo           => 'Situação atual não permite que o arquivo seja gerado',
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_VALIDACAO,
                                         en_referencia_id    => en_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    end if;
    --
  end if;
  --
exception
  when others then
    --
    pkb_atual_sit_ecd(en_aberturaecd_id => en_aberturaecd_id,
                      en_dm_situacao    => 6); -- Erro na geração do arquivo
    --
    pk_csf_api_ecd.gv_mensagem_log := 'Erro na pkb_gera_arquivo_ecd fase(' ||
                                      vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_dc.id%TYPE;
    begin
      --
      pk_csf_api_ecd.pkb_log_generico_dc(sn_loggenericodc_id => vn_loggenerico_id,
                                         ev_mensagem         => pk_csf_api_ecd.gv_mensagem_log,
                                         ev_resumo           => pk_csf_api_ecd.gv_mensagem_log,
                                         en_tipo_log         => pk_csf_api_ecd.ERRO_DE_SISTEMA,
                                         en_referencia_id    => gn_aberturaecd_id,
                                         ev_obj_referencia   => 'ABERTURA_ECD');
      --
    exception
      when others then
        null;
    end;
    --
  --raise_application_error (-20101, pk_csf_api_ecd.gv_mensagem_log);
  --
end pkb_gera_arquivo_ecd;

-----------------------------------------------------------------------------
-- Processo que carrega os lançamentos contábeis em um type para agilizar o processamento
-----------------------------------------------------------------------------
procedure pkb_carrega_lctos(en_empresa_id in empresa.id%type,
                            ed_dt_ini     in date,
                            ed_dt_fin     in date) is
  --
  vn_fase number;
  --
begin
  
  vn_fase := 1.00;
  --CARREGA DADOS DO PERÍODO EM TYPE PARA AGILIZAR O PROCESSO DE CONSOLIDAÇÃO DO SALDO
  --
          INSERT INTO TMP_INT_LCTO_CONTABIL
             SELECT PL.INTLCTOCONTABIL_ID,
                              PL.ID,
                              LC.EMPRESA_ID,
                              VL_LCTO,
                              LC.NUM_LCTO,
                              LC.DT_LCTO,
                              PL.PLANOCONTA_ID,
                              PL.CENTROCUSTO_ID,
                              PL.VL_DC,
                              PL.DM_IND_DC,
                              LC.DM_IND_LCTO,
                              PL.NUM_ARQ,
                              PL.HISTPADRAO_ID,
                              PL.COMPL_HIST,
                              PL.PESSOA_ID,
         LC.DT_LCTO_EXT
    FROM INT_LCTO_CONTABIL LC
       , INT_PARTIDA_LCTO PL
   WHERE LC.EMPRESA_ID = EN_EMPRESA_ID
     AND LC.DT_LCTO BETWEEN ed_dt_ini AND ed_dt_fin
     AND LC.DM_IND_LCTO IN ('N', 'E')
     AND PL.INTLCTOCONTABIL_ID = LC.ID;

  
exception
  when others then
    rollback;
    raise_application_error(-20101,
                            'Erro na pk_csf_api_ecd.pkb_carrega_lctos fase (' ||
                            vn_fase || '): ' || sqlerrm);
end pkb_carrega_lctos;

-----------------------------------------------------------------------------
-- Processo que carrega O I200 E I250
-----------------------------------------------------------------------------
procedure pkb_carrega_I200_I250 is
 pragma autonomous_transaction;
  --
  vn_fase       number;
  qtde_reg_i200 NUMBER := 0;
  qtde_reg_i250 NUMBER := 0;
  qtd_commit    number := 0;
  vb_gera_reg   boolean:=true;
  --
begin

  vn_fase := 1.00;
  --
/*  A partir do Layout 8, os registros I200 e I250 só poderão ser gerados se o tipo de escrituração:
  G - Livro Diário (Completo sem escrituração auxiliar)
  R - Livro Diário com Escrituração Resumida
  A - Livro Diário Auxiliar ao Diário com Escrituração Resumida.*/
  ---
  if to_number(gv_versaolayoutecd_cd) >= 800 then
    ---
    if gn_tipo_escr_contab in ('G','R','A') then
      vb_gera_reg:= true;
    else
      vb_gera_reg:= false;
    end if;
    ---
  else
    ---
    vb_gera_reg:= true;
    ---
  end if;
  ---
  if vb_gera_reg = true then
    --
    --CARREGA DADOS DO PERÍODO EM TYPE PARA AGILIZAR O PROCESSO DE CONSOLIDAÇÃO DO SALDO
    --
    BEGIN
    for x in (SELECT  /*+ APPEND */
                     estrarqecd_seq.nextval  id,
                     aberturaecd_id,
                     registro,
                     registroecd_id,
                     null sequencia,
                     conteudo
              FROM ( SELECT NULL ID,
                            gn_aberturaecd_id  ABERTURAECD_ID,
                            reg registro,
                            PK_CSF_ECD.FKG_REGISTRO_ECD_ID(REG) REGISTROECD_ID,
                            NULL SEQUENCIA,
                            '|' || REG || '|' ||
                            DECODE(REG, 'I200', NUM_LCTO|| '|', pk_csf_ecd.fkg_plano_conta_cod(PLANOCONTA)|| '|')||
                            DECODE(REG,'I200',TO_CHAR(DT_LCTO, 'DDMMRRRR')|| '|',pk_csf_ecd.fkg_centro_custo_cd(CENTROCUSTO)|| '|')||
                            DECODE(REG,'I200', trim(to_char(VL_LCTO,'99999999999999990D00'))|| '|', trim(to_char(VL_DC,'99999999999999990D00'))|| '|')||
                            DECODE(REG,'I200', DM_IND_LCTO|| '|', DM_IND_DC|| '|')||
                            DECODE(REG,'I200', TO_CHAR(DT_LCTO_EXT,'DDMMRRRR')|| '|', NUM_ARQ|| '|')||
                            DECODE(REG,'I250',DECODE(NVL(HISTPADRAO_ID, 0),0,NULL,TRIM(PK_CSF_ECD.FKG_HIST_PADRAO_COD(HISTPADRAO_ID)))|| '|',NULL)||
                            DECODE(REG,'I250',NVL(COMPL_HIST, 'Lancamento conforme documento')|| '|',NULL) ||
                            DECODE(REG,'I250',DECODE(NVL(PESSOA_ID, 0),0,NULL,TRIM(PK_CSF.FKG_PESSOA_COD_PART(PESSOA_ID)))|| '|',NULL)||FINAL_DE_LINHA CONTEUDO
                      FROM (SELECT  DISTINCT
                               B.NUM_LCTO NUM_LCTO,
                                 'I200'    REG,
                               B.DT_LCTO DT_LCTO,
                               B.VL_LCTO VL_LCTO,
                               B.DM_IND_LCTO DM_IND_LCTO,
                               B.DT_LCTO_EXT DT_LCTO_EXT,
                               NULL PLANOCONTA,
                               NULL CENTROCUSTO,
                               NULL VL_DC,
                               NULL DM_IND_DC,
                               NULL NUM_ARQ,
                               NULL HISTPADRAO_ID,
                               NULL COMPL_HIST,
                               NULL PESSOA_ID
                           FROM (  SELECT PL.INTLCTOCONTABIL_ID,
                                          PL.ID,
                                          LC.EMPRESA_ID,
                                          VL_LCTO,
                                          LC.NUM_LCTO,
                                          LC.DT_LCTO,
                                          PL.PLANOCONTA_ID,
                                          pc.cod_cta,
                                          PL.CENTROCUSTO_ID,
                                          cc.cod_ccus,
                                          PL.VL_DC,
                                          PL.DM_IND_DC,
                                          LC.DM_IND_LCTO,
                                          PL.NUM_ARQ,
                                          PL.HISTPADRAO_ID,
                                          PL.COMPL_HIST,
                                          PL.PESSOA_ID,
                                          LC.DT_LCTO_EXT
                                     FROM INT_LCTO_CONTABIL LC
                                        , INT_PARTIDA_LCTO PL
                                        , PLANO_CONTA PC
                                        , CENTRO_CUSTO CC
                                    WHERE 1=1
                                      AND LC.EMPRESA_ID         = en_empresa_id
                                      AND LC.DT_LCTO            BETWEEN ed_dt_ini and ed_dt_fin
                                      AND LC.DM_IND_LCTO        IN ('N', 'E')
                                      AND PL.INTLCTOCONTABIL_ID = LC.ID
                                      AND PL.PLANOCONTA_ID             = PC.ID(+)
                                      AND PL.CENTROCUSTO_ID            = CC.ID(+)   ) b
                           union all
                          SELECT A.NUM_LCTO NUM_LCTO,
                                 'I250' REG,
                                 A.DT_LCTO DT_LCTO,
                                 A.VL_LCTO VL_LCTO,
                                 A.DM_IND_LCTO DM_IND_LCTO,
                                 A.DT_LCTO_EXT DT_LCTO_EXT,
                                 A.PLANOCONTA_ID PLANOCONTA,
                                 A.CENTROCUSTO_ID CENTROCUSTO,
                                 A.VL_DC VL_DC,
                                 A.DM_IND_DC DM_IND_DC,
                                 A.NUM_ARQ NUM_ARQ,
                                 A.HISTPADRAO_ID HISTPADRAO_ID,
                                 TRIM(PK_CSF.FKG_CONVERTE(A.COMPL_HIST)) COMPL_HIST,
                                 A.PESSOA_ID PESSOA_ID
                           from (SELECT PL.INTLCTOCONTABIL_ID,
                                        PL.ID,
                                        LC.EMPRESA_ID,
                                        VL_LCTO,
                                        LC.NUM_LCTO,
                                        LC.DT_LCTO,
                                        PL.PLANOCONTA_ID,
                                        pc.cod_cta,
                                        PL.CENTROCUSTO_ID,
                                        cc.cod_ccus,
                                        PL.VL_DC,
                                        PL.DM_IND_DC,
                                        LC.DM_IND_LCTO,
                                        PL.NUM_ARQ,
                                        PL.HISTPADRAO_ID,
                                        PL.COMPL_HIST,
                                        PL.PESSOA_ID,
                                        LC.DT_LCTO_EXT
                                   FROM INT_LCTO_CONTABIL LC
                                      , INT_PARTIDA_LCTO PL
                                      , PLANO_CONTA PC
                                      , CENTRO_CUSTO CC
                                  WHERE 1=1
                                    AND LC.EMPRESA_ID         = en_empresa_id
                                    AND LC.DT_LCTO            BETWEEN ed_dt_ini and ed_dt_fin
                                    AND LC.DM_IND_LCTO        IN ('N', 'E')
                                    AND PL.INTLCTOCONTABIL_ID = LC.ID
                                    AND PL.PLANOCONTA_ID             = PC.ID(+)
                                    AND PL.CENTROCUSTO_ID            = CC.ID(+)   ) a
                                  ORDER BY DT_LCTO, NUM_LCTO, REG
                      )
                 )
               ) loop
        --
        gn_seq_arq := gn_seq_arq + 1;
        --
        if x.registro = 'I200' THEN
          gn_qtde_reg_I200 := gn_qtde_reg_I200 + 1;
        ELSE
          gn_qtde_reg_I250 := gn_qtde_reg_I250 + 1;
        END IF;
        --
        INSERT INTO ESTR_ARQ_ECD (id, aberturaecd_id, registroecd_id, sequencia, conteudo)
            VALUES (estrarqecd_seq.nextval, GN_ABERTURAECD_ID, x.registroecd_id, gn_seq_arq, x.conteudo);
          --
        if qtd_commit = 10000 then
          commit;
          qtd_commit := 0;
        else
          qtd_commit := qtd_commit + 1;
        end if;
      end loop;
      --
   vn_fase := 2.00;
      --
  exception
    when others then
        rollback;
        raise_application_error(-20101,
                              'Erro na pk_gera_arq_ecd.pkb_carrega_I200-i250 fase (' ||
                                vn_fase || '): ' || sqlerrm);
  end;
    --
    COMMIT;
  end if;
  --
exception
  when others then
    rollback;
    raise_application_error(-20101,
                            'Erro na pk_gera_arq_ecd.pkb_carrega_I200_I250 fase (' ||
                            vn_fase || '): ' || sqlerrm);
end pkb_carrega_I200_I250;

-------------------------------------------------------------------------------------------------------

end pk_gera_arq_ecd;
/
