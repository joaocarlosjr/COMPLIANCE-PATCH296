create or replace package body csf_own.pk_csf_api_cad is

-------------------------------------------------------------------------------------------------------
--| Especificação do pacote de procedimentos de integração e validação de Cadastros
------------------------------------------------------------------------------
-- Procedimento seta o tipo de integração que será feito                    --
-- 0 - Somente valida os dados e registra o Log de ocorrência               --
-- 1 - Valida os dados e registra o Log de ocorrência e insere a informação --
-- Todos os procedimentos de integração fazem referência a ele              --
------------------------------------------------------------------------------
PROCEDURE PKB_SETA_TIPO_INTEGR ( EN_TIPO_INTEGR IN NUMBER ) IS
BEGIN
   --
   gn_tipo_integr := en_tipo_integr;
   --
END PKB_SETA_TIPO_INTEGR;

-----------------------------------------------------------------------------------
-- Procedimento seta o objeto de referencia utilizado na Validação da Informação --
-----------------------------------------------------------------------------------
PROCEDURE PKB_SETA_OBJ_REF ( EV_OBJETO IN VARCHAR2 ) IS
BEGIN
   --
   gv_obj_referencia := upper(ev_objeto);
   --
END PKB_SETA_OBJ_REF;

---------------------------------------------------------------------------------
-- Procedimento seta o "ID de Referencia" utilizado na Validação da Informação --
---------------------------------------------------------------------------------
PROCEDURE PKB_SETA_REFERENCIA_ID ( EN_ID IN NUMBER ) IS
BEGIN
   --
   gn_referencia_id := en_id;
   --
END PKB_SETA_REFERENCIA_ID;

----------------------------------------------------------------------
-- Procedimento armazena o valor do "loggenerico_id" do cadastro --
----------------------------------------------------------------------
PROCEDURE PKB_GT_LOG_GENERICO_CAD ( EN_LOGGENERICO   IN            LOG_GENERICO_CAD.ID%TYPE
                                  , EST_LOG_GENERICO IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                  )
IS
   --
   i pls_integer;
   --
BEGIN
   --
   if nvl(en_loggenerico,0) > 0 then
      --
      i := nvl(est_Log_Generico.count,0) + 1;
      --
      est_log_generico(i) := en_loggenerico;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_gt_log_generico_cad: '||sqlerrm;
      --
      declare
         vn_loggenericocad_id  log_generico_cad.id%type;
      begin
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_sistema
                              );
      exception
         when others then
            null;
      end;
      --
END PKB_GT_LOG_GENERICO_CAD;

------------------------------------------
-- Procedimento finaliza o Log Genérico --
------------------------------------------
PROCEDURE PKB_FINALIZA_LOG_GENERICO_CAD IS
BEGIN
   --
   gn_processo_id := null;
   --
EXCEPTION
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_finaliza_log_generico_cad: '||sqlerrm;
      --
      declare
         vn_loggenericocad_id  log_generico_cad.id%type;
      begin
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_sistema
                              );
      exception
         when others then
            null;
      end;
      --
END PKB_FINALIZA_LOG_GENERICO_CAD;

-----------------------------------------------------------------------
-- Procedimento de registro de log de erros na validação do cadastro --
-----------------------------------------------------------------------
procedure pkb_log_generico_cad ( sn_loggenericocad_id  out nocopy    log_generico_cad.id%type
                               , ev_mensagem           in            log_generico_cad.mensagem%type
                               , ev_resumo             in            log_generico_cad.resumo%type
                               , en_tipo_log           in            csf_tipo_log.cd_compat%type      default 1
                               , en_referencia_id      in            log_generico_cad.referencia_id%type  default null
                               , ev_obj_referencia     in            log_generico_cad.obj_referencia%type default null
                               , en_empresa_id         in            empresa.id%type                  default null
                               , en_dm_impressa        in            log_generico_cad.dm_impressa%type    default 0
                               )
IS
   --
   vn_fase          number := 0;
   vn_empresa_id    Empresa.Id%type;
   vn_csftipolog_id csf_tipo_log.id%type := null;
   pragma           autonomous_transaction;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if nvl(gn_processo_id,0) = 0 then
      select processo_seq.nextval
        into gn_processo_id
        from dual;
   end if;
   --
   vn_empresa_id := nvl(en_empresa_id, gn_empresa_id);
   --
   if nvl(en_tipo_log,0) > 0 and ev_mensagem is not null then
      --
      vn_fase := 2;
      --
      vn_csftipolog_id := pk_csf.fkg_csf_tipo_log_id ( en_tipo_log => en_tipo_log );
      --
      vn_fase := 3;
      --
      select loggenericocad_seq.nextval
        into sn_loggenericocad_id
        from dual;
      --
      vn_fase := 4;
      --
      insert into log_generico_cad ( id
                                   , processo_id
                                   , dt_hr_log
                                   , mensagem
                                   , referencia_id
                                   , obj_referencia
                                   , resumo
                                   , dm_impressa
                                   , dm_env_email
                                   , csftipolog_id
                                   , empresa_id
                                   )
                            values
                                   ( sn_loggenericocad_id     -- Valor de cada log de validação
                                   , gn_processo_id        -- Valor ID do processo de integração
                                   , sysdate               -- Sempre atribui a data atual do sistema
                                   , ev_mensagem           -- Mensagem do log
                                   , en_referencia_id      -- Id de referência que gerou o log
                                   , ev_obj_referencia     -- Objeto do Banco que gerou o log
                                   , ev_resumo
                                   , en_dm_impressa
                                   , 0
                                   , vn_csftipolog_id
                                   , vn_empresa_id
                                   );
      --
      vn_fase := 5;
      --
      commit;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_log_generico_cad fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenericocad_id  log_generico_cad.id%type;
      begin
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_sistema
                              );
      exception
         when others then
            null;
      end;
      --
END pkb_log_generico_cad;

-------------------------------------------------------------------------------------------------------

-- Procedimento valida o mult org de acordo com o COD e o HASH das tabelas Flex-Field

procedure pkb_val_atrib_multorg ( est_log_generico   in out nocopy  dbms_sql.number_table
                                , ev_obj_name        in             VARCHAR2
                                , ev_atributo        in             VARCHAR2
                                , ev_valor           in             VARCHAR2
                                , sv_cod_mult_org    out            VARCHAR2
                                , sv_hash_mult_org   out            VARCHAR2
                                , en_referencia_id   in             log_generico_cad.referencia_id%type
                                , ev_obj_referencia  in             log_generico_cad.obj_referencia%type
                                )
is
   --
   vn_fase                number := 0;
   vn_loggenericocad_id   log_generico_cad.id%type;
   vv_mensagem            varchar2(1000) := null;
   vn_dmtipocampo         ff_obj_util_integr.dm_tipo_campo%type;

   vv_hash_mult_org     mult_org.hash%type;
   vv_cod_mult_org      mult_org.cd%type;
  --
begin
 --
   vn_fase := 1;
   --
   gv_mensagem_log := null;
   --
   gn_referencia_id  := en_referencia_id;
   gv_obj_referencia := ev_obj_referencia;
   --
   vn_fase := 2;
   --
   if trim(ev_valor) is null then
      --
      vn_fase := 3;
      --
      gv_mensagem_log := 'Código ou HASH da Mult-Organização (objeto: '|| ev_obj_name ||'): "VALOR" referente ao atributo deve ser informado.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem        => gv_mensagem_log
                           , ev_resumo          => gv_cabec_log
                           , en_tipo_log        => INFORMACAO
                           , en_referencia_id   => gn_referencia_id
                           , ev_obj_referencia  => gv_obj_referencia );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   --
   vv_mensagem := pk_csf.fkg_ff_verif_campos( ev_obj_name => ev_obj_name
                                            , ev_atributo => trim(ev_atributo)
                                            , ev_valor    => trim(ev_valor) );
   --
   vn_fase := 5;
   --
   if vv_mensagem is not null then
      --
      vn_fase := 6;
      --
      gv_mensagem_log := vv_mensagem;
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad    ( sn_loggenericocad_id => vn_loggenericocad_id
                              , ev_mensagem          => gv_mensagem_log
                              , ev_resumo            => gv_cabec_log
                              , en_tipo_log          => INFORMACAO
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico       => vn_loggenericocad_id
                              , est_log_generico     => est_log_generico );
      --
   else
       --
      vn_fase := 7;
      --
      vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo( ev_obj_name => ev_obj_name
                                                         , ev_atributo => trim(ev_atributo) );
      --
      vn_fase := 8;
      --
      if trim(ev_valor) is not null then
         --
         vn_fase := 9;
         --
         if vn_dmtipocampo = 2 then -- tipo de campo = 0-data, 1-numérico, 2-caractere
            --
            vn_fase := 10;
            --
            if trim(ev_atributo) = 'COD_MULT_ORG' then
                --
                vn_fase := 11;
                --
                begin
                   vv_cod_mult_org := pk_csf.fkg_ff_ret_vlr_caracter( ev_obj_name => ev_obj_name
                                                                    , ev_atributo => trim(ev_atributo)
                                                                    , ev_valor    => trim(ev_valor) );
                exception
                   when others then
                      vv_cod_mult_org := null;
                end;
                --
            elsif trim(ev_atributo) = 'HASH_MULT_ORG' then
               --
                vn_fase := 12;
                --
                begin
                   vv_hash_mult_org := pk_csf.fkg_ff_ret_vlr_caracter( ev_obj_name => ev_obj_name
                                                                     , ev_atributo => trim(ev_atributo)
                                                                     , ev_valor    => trim(ev_valor) );
                exception
                   when others then
                      vv_hash_mult_org := null;
                end;
                --
            end if;
            --
         else
            --
            vn_fase := 13;
            --
            gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado não confere com o tipo de campo, deveria ser CARACTERE.';
            --
            vn_loggenericocad_id := null;
            --
            pkb_log_generico_cad ( sn_loggenericocad_id => vn_loggenericocad_id
                                 , ev_mensagem       => gv_mensagem_log
                                 , ev_resumo         => gv_cabec_log
                                 , en_tipo_log       => INFORMACAO
                                 , en_referencia_id  => gn_referencia_id
                                 , ev_obj_referencia => gv_obj_referencia );
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_cad ( en_loggenerico   => vn_loggenericocad_id
                                    , est_log_generico => est_log_generico );
            --
         end if;
         --
      end if;
      --
   end if;
   --
   vn_fase := 14;
   --
   sv_cod_mult_org := vv_cod_mult_org;
   --
   sv_hash_mult_org := vv_hash_mult_org;
--
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_val_atrib_multorg fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericocad_id  log_generico.id%type;
      begin
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem        => gv_mensagem_log
                              , ev_resumo          => gv_cabec_log
                              , en_tipo_log        => erro_de_validacao
                              , en_referencia_id   => gn_referencia_id
                              , ev_obj_referencia  => gv_obj_referencia );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                 , est_log_generico  => est_log_generico );
      exception
         when others then
            null;
      end;
end pkb_val_atrib_multorg;

-------------------------------------------------------------------------------------------------------

--| Atualiza cadastro de e-mails conforme multorg_id e CPF/CNPJ
procedure pkb_atual_email_pessoa ( en_multorg_id  in mult_org.id%type
                                 , ev_cpf_cnpj    in varchar2
                                 , ev_email       in pessoa.email%type
                                 )
is
   --
   vn_fase        number := 0;
   --
   cursor c_jur is
   select j.pessoa_id
     from juridica j
        , pessoa p
    where j.num_cnpj    = substr(ev_cpf_cnpj, 1, 8)
      and j.num_filial  = substr(ev_cpf_cnpj, 9, 4)
      and j.dig_cnpj    = substr(ev_cpf_cnpj, 13, 2)
      and p.id          = j.pessoa_id
      and p.multorg_id  = en_multorg_id;
   --
   cursor c_fis is
   select f.pessoa_id
     from fisica f
        , pessoa p
    where f.num_cpf     = substr(ev_cpf_cnpj, 1, 9)
      and f.dig_cpf     = substr(ev_cpf_cnpj, 10, 2)
      and p.id          = f.pessoa_id
      and p.multorg_id  = en_multorg_id;
   --
begin
   --
   vn_fase := 1;
   --
   if trim(ev_email) is not null then
      --
      vn_fase := 2;
      --
      if trim(ev_cpf_cnpj) is not null
         and pk_csf.fkg_is_numerico( trim(ev_cpf_cnpj) )
         then
         --
         vn_fase := 2.1;
         -- recupera as pessoas juridicas
         for rec1 in c_jur loop
            exit when c_jur%notfound or (c_jur%notfound) is null;
            --
            vn_fase := 3;
            --
            update pessoa set email = trim(ev_email)
             where id = rec1.pessoa_id;
            --
         end loop;
         --
         vn_fase := 4;
         --
         for rec2 in c_fis loop
            exit when c_fis%notfound or (c_fis%notfound) is null;
            --
            vn_fase := 5;
            --
            update pessoa set email = trim(ev_email)
             where id = rec2.pessoa_id;
            --
         end loop;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      raise_application_error (-20101, 'Erro na pk_csf_api_cad.pkb_atual_email_pessoa (' || vn_fase || '):' || sqlerrm);
end pkb_atual_email_pessoa;

-------------------------------------------------------------------------------------------------------

--| Atualiza os dados de tabelas dependentes de ITEM
procedure pkb_atual_dep_item ( en_multorg_id  in mult_org.id%type
                             , ev_cpf_cnpj    in varchar2
                             , ev_cod_item    in item.cod_item%type
                             )
is
   --
   vn_fase            number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
   vn_item_id         item.id%type;
   vn_empresa_id      empresa.id%type;
   --
   cursor c_itemnf (en_empresa_id empresa.id%type) is
   select itnf.id
     from item_nota_fiscal  itnf
        , nota_fiscal       nf
    where ((nf.empresa_id  = en_empresa_id) -- Passar a considerar todas as empresas filiais da empresa em questão
            or
           (nf.empresa_id in (select em.id
                                from empresa em
                               where em.ar_empresa_id = en_empresa_id)))
      and nf.dm_arm_nfe_terc = 0
      and itnf.notafiscal_id = nf.id
      and itnf.cod_item      = ev_cod_item
      and itnf.item_id      is null;
   --
begin
   --
   vn_fase := 1;
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id  => en_multorg_id
                                                        , ev_cpf_cnpj    => ev_cpf_cnpj
                                                        );
   --
   if nvl(vn_empresa_id,0) > 0 then
      --
      vn_fase := 2;
      --
      vn_item_id := pk_csf.fkg_Item_id_conf_empr ( en_empresa_id  => vn_empresa_id
                                                 , ev_cod_item    => ev_cod_item 
                                                 );
      --
      vn_fase := 3;
      --
      if nvl(vn_item_id,0) > 0 then
         --
         vn_fase := 4;
         --
         for recnf in c_itemnf(vn_empresa_id) loop
            exit when c_itemnf%notfound or (c_itemnf%notfound) is null;
             --
             update item_nota_fiscal set item_id = vn_item_id
              where id = recnf.id;
             --
         end loop;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_atual_dep_item fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_SISTEMA
                              , en_referencia_id      => vn_item_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => vn_empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_atual_dep_item;

-------------------------------------------------------------------------------------------------------

--| Atualiza os dados de tabelas dependentes de Pessoa
--| Procedimento alterado de pkb_atual_dep_pessoa para pkb_atual_dep_pessoa_old, devido a utilização dos parâmetros de entrada: en_multorg_id e en_empresa_id.
--| Segue abaixo desta a rotina pkb_atual_dep_pessoa, otimizada.
procedure pkb_atual_dep_pessoa_old ( en_multorg_id  in  mult_org.id%type
                                   , ev_cpf_cnpj    in  varchar2
                                   , en_empresa_id  in  empresa.id%type
                                   )
is
   --
   vn_fase            number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
   vn_pessoa_id       pessoa.id%type;
   vn_existe          number := 0;
   --
   cursor c_nota_fiscal_cnpj is
   select nf.id
     from empresa           e
        , nota_fiscal       nf
        , nota_fiscal_dest  nfd
    where e.multorg_id         = en_multorg_id
      and nf.empresa_id        = e.id
      and nf.dm_ind_emit       = 0 -- Emissão Própria
      and nf.dm_st_proc in (4,7)
      and nvl(nf.pessoa_id,0)  <= 0
      and nfd.notafiscal_id    = nf.id
      and (nfd.cnpj = ev_cpf_cnpj);
   --
   cursor c_nota_fiscal_cpf is
   select nf.id
     from empresa           e
        , nota_fiscal       nf
        , nota_fiscal_dest  nfd
    where e.multorg_id        = en_multorg_id
      and nf.empresa_id       = e.id
      and nf.dm_ind_emit      = 0 -- Emissão Própria
      and nf.dm_st_proc in (4,7)
      and nvl(nf.pessoa_id,0) <= 0
      and nfd.notafiscal_id   = nf.id
      and (nfd.cpf = ev_cpf_cnpj);
   --
   cursor c_nf_terc_cnpj is
   select nf.id
     from empresa           e
        , nota_fiscal       nf
        , nota_fiscal_emit  nfe
    where e.multorg_id        = en_multorg_id
      and nf.empresa_id       = e.id
      and nf.dm_ind_emit      = 1 -- Terceiros
      and nf.dm_arm_nfe_terc  = 0
      and nvl(nf.pessoa_id,0) <= 0
      and nfe.notafiscal_id   = nf.id
      and (nfe.cnpj = ev_cpf_cnpj);
   --
   cursor c_nf_terc_cpf is
   select nf.id
     from empresa           e
        , nota_fiscal       nf
        , nota_fiscal_emit  nfe
    where e.multorg_id        = en_multorg_id
      and nf.empresa_id       = e.id
      and nf.dm_ind_emit      = 1 -- Terceiros
      and nf.dm_arm_nfe_terc  = 0
      and nvl(nf.pessoa_id,0) <= 0
      and nfe.notafiscal_id   = nf.id
      and (nfe.cpf = ev_cpf_cnpj);
   --
   cursor c_nf_referen is
   select r.id
     from empresa e
        , nota_fiscal nf
        , nota_fiscal_referen  r
    where e.multorg_id = en_multorg_id
      and nf.empresa_id = e.id
      and r.notafiscal_id = nf.id
      and r.CNPJ_EMIT = ev_cpf_cnpj
      and nvl(r.pessoa_id,0) <= 0;
   --
   cursor c_nota_fiscal_transp is
   select nft.id
     from empresa e
        , nota_fiscal nf
        , nota_fiscal_transp nft
    where e.multorg_id = en_multorg_id
      and nf.empresa_id = e.id
      and nft.notafiscal_id = nf.id
      and nft.cnpj_cpf = ev_cpf_cnpj
      and nvl(nft.pessoa_id,0) <= 0;
   --
   cursor c_conhec_transp is
   select ct.id, ct.DM_TOMADOR
     from empresa              e
        , conhec_transp        ct
    where e.multorg_id         = en_multorg_id
      and ct.empresa_id        = e.id
      and ct.dm_ind_emit       = 0 -- Emissão Própria
      and ct.DM_TOMADOR        = 0  -- Remetente
      and nvl(ct.pessoa_id,0)  <= 0;
   --
   cursor c_conhec_transp_terc is
   select ct.id
     from empresa e
        , conhec_transp       ct
        , CONHEC_TRANSP_EMIT  ctr
    where e.multorg_id         = en_multorg_id
      and ct.empresa_id        = e.id
      and ct.dm_ind_emit       = 1 -- Terceiro
      and nvl(ct.pessoa_id,0)  <= 0
      and ctr.conhectransp_id  = ct.id
      and (ctr.cnpj = ev_cpf_cnpj);
   --
begin
   --
   vn_fase := 1;
   --
   if length(ev_cpf_cnpj) in (11, 14) then
      -- busca o ID da Pessoa
      vn_pessoa_id := pk_csf.fkg_Pessoa_id_cpf_cnpj ( en_multorg_id  => en_multorg_id
                                                    , en_cpf_cnpj    => ev_cpf_cnpj
                                                    );
      --
      vn_fase := 2;
      --
      if nvl(vn_pessoa_id,0) > 0 then
         --
         vn_fase := 3;
         --
         if length(ev_cpf_cnpj) = 14 then
            -- Atualiza dados da Nota Fiscal Emissão Própria CNPJ
            for recnf in c_nota_fiscal_cnpj loop
               exit when c_nota_fiscal_cnpj%notfound or (c_nota_fiscal_cnpj%notfound) is null;
               --
               vn_fase := 3.1;
               --
               update nota_fiscal set pessoa_id = vn_pessoa_id
                where id = recnf.id;
               --
            end loop;
            --
         end if;
         --
         if length(ev_cpf_cnpj) = 11 then
            -- Atualiza dados da Nota Fiscal Emissão Própria CPF
            for recnf in c_nota_fiscal_cpf loop
               exit when c_nota_fiscal_cpf%notfound or (c_nota_fiscal_cpf%notfound) is null;
               --
               vn_fase := 3.1;
               --
               update nota_fiscal set pessoa_id = vn_pessoa_id
                where id = recnf.id;
               --
            end loop;
            --
         end if;
         --
         vn_fase := 4;
         --
         if length(ev_cpf_cnpj) = 14 then
            -- Atualiza dados da Nota Fiscal - Terceiros CNPJ
            for recnf in c_nf_terc_cnpj loop
               exit when c_nf_terc_cnpj%notfound or (c_nf_terc_cnpj%notfound) is null;
               --
               vn_fase := 4.1;
               --
               update nota_fiscal set pessoa_id = vn_pessoa_id
                where id = recnf.id;
               --
            end loop;
            --
         end if;
         --
         if length(ev_cpf_cnpj) = 11 then
            -- Atualiza dados da Nota Fiscal - Terceiros CPF
            for recnf in c_nf_terc_cpf loop
               exit when c_nf_terc_cpf%notfound or (c_nf_terc_cpf%notfound) is null;
               --
               vn_fase := 4.1;
               --
               update nota_fiscal set pessoa_id = vn_pessoa_id
                where id = recnf.id;
               --
            end loop;
            --
         end if;
         --
         vn_fase := 5;
         -- Atualiza dados de Transporte da Nota Fiscal
         for recnft in c_nota_fiscal_transp loop
            exit when c_nota_fiscal_transp%notfound or (c_nota_fiscal_transp%notfound) is null;
            --
            vn_fase := 5.1;
            --
            update nota_fiscal_transp set pessoa_id = vn_pessoa_id
             where id = recnft.id;
            --
         end loop;
         --
         vn_fase := 6;
         -- Artualiza Conhecimento de Transporte
         for recct in c_conhec_transp loop
            exit when c_conhec_transp%notfound or (c_conhec_transp%notfound) is null;
            --
            vn_fase := 6.1;
            --
            vn_existe := 0;
            --
            if recct.dm_tomador = 0 then -- Remetente
               --
               if length(ev_cpf_cnpj) = 11 then
                  --
                  begin
                     --
                     select distinct 1
                       into vn_existe
                       from conhec_transp_rem
                      where conhectransp_id = recct.id
                        and cpf = ev_cpf_cnpj;
                     --
                  exception
                     when others then
                        vn_existe := 0;
                  end;
                  --
               elsif length(ev_cpf_cnpj) = 14 then
                  --
                  begin
                     --
                     select distinct 1
                       into vn_existe
                       from conhec_transp_rem
                      where conhectransp_id = recct.id
                        and cnpj = ev_cpf_cnpj;
                     --
                  exception
                     when others then
                        vn_existe := 0;
                  end;
                  --
               end if;
               --
            elsif recct.dm_tomador = 1 then -- Expeditor
               --
               if length(ev_cpf_cnpj) = 11 then
                  --
                  begin
                     --
                     select distinct 1
                       into vn_existe
                       from conhec_transp_exped
                      where conhectransp_id = recct.id
                        and cpf = ev_cpf_cnpj;
                     --
                  exception
                     when others then
                        vn_existe := 0;
                  end;
                  --
               elsif length(ev_cpf_cnpj) = 14 then
                  --
                  begin
                     --
                     select distinct 1
                       into vn_existe
                       from conhec_transp_exped
                      where conhectransp_id = recct.id
                        and cnpj = ev_cpf_cnpj;
                     --
                  exception
                     when others then
                        vn_existe := 0;
                  end;
                  --
               end if;
               --
            elsif recct.dm_tomador = 2 then -- Recebedor
               --
               if length(ev_cpf_cnpj) = 11 then
                  --
                  begin
                     --
                     select distinct 1
                       into vn_existe
                       from conhec_transp_receb
                      where conhectransp_id = recct.id
                        and cpf = ev_cpf_cnpj;
                     --
                  exception
                     when others then
                        vn_existe := 0;
                  end;
                  --
               elsif length(ev_cpf_cnpj) = 14 then
                  --
                  begin
                     --
                     select distinct 1
                       into vn_existe
                       from conhec_transp_receb
                      where conhectransp_id = recct.id
                        and cnpj = ev_cpf_cnpj;
                     --
                  exception
                     when others then
                        vn_existe := 0;
                  end;
                  --
               end if;
               --
            elsif recct.dm_tomador = 3 then -- Destinatário
               --
               if length(ev_cpf_cnpj) = 11 then
                  --
                  begin
                     --
                     select distinct 1
                       into vn_existe
                       from conhec_transp_dest
                      where conhectransp_id = recct.id
                        and cpf = ev_cpf_cnpj;
                     --
                  exception
                     when others then
                        vn_existe := 0;
                  end;
                  --
               elsif length(ev_cpf_cnpj) = 14 then
                  --
                  begin
                     --
                     select distinct 1
                       into vn_existe
                       from conhec_transp_dest
                      where conhectransp_id = recct.id
                        and cnpj = ev_cpf_cnpj;
                     --
                  exception
                     when others then
                        vn_existe := 0;
                  end;
                  --
               end if;
               --
            elsif recct.dm_tomador = 4 then -- Outros
               --
               if length(ev_cpf_cnpj) = 11 then
                  --
                  begin
                     --
                     select distinct 1
                       into vn_existe
                       from conhec_transp_tomador
                      where conhectransp_id = recct.id
                        and cpf = ev_cpf_cnpj;
                     --
                  exception
                     when others then
                        vn_existe := 0;
                  end;
                  --
               elsif length(ev_cpf_cnpj) = 14 then
                  --
                  begin
                     --
                     select distinct 1
                       into vn_existe
                       from conhec_transp_tomador
                      where conhectransp_id = recct.id
                        and cnpj = ev_cpf_cnpj;
                     --
                  exception
                     when others then
                        vn_existe := 0;
                  end;
                  --
               end if;
               --
            end if;
            --
            if nvl(vn_existe,0) > 0 then
               --
               update conhec_transp set pessoa_id = vn_pessoa_id
                where id = recct.id;
               --
            end if;
            --
         end loop;
         --
         vn_fase := 7;
         -- Artualiza Conhecimento de Transporte de Terceiros
         for recct in c_conhec_transp_terc loop
            exit when c_conhec_transp_terc%notfound or (c_conhec_transp_terc%notfound) is null;
            --
            vn_fase := 7.1;
            --
            update conhec_transp set pessoa_id = vn_pessoa_id
             where id = recct.id;
            --
         end loop;
         --
         vn_fase := 8;
         -- Atualiza dados da Nota Fiscal Referenciada
         for recnfr in c_nf_referen loop
            exit when c_nf_referen%notfound or (c_nf_referen%notfound) is null;
            --
            vn_fase := 8.1;
            --
            update nota_fiscal_referen set pessoa_id = vn_pessoa_id
             where id = recnfr.id;
            --
         end loop;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_atual_dep_pessoa_old fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem        => gv_mensagem_log
                              , ev_resumo          => gv_mensagem_log
                              , en_tipo_log        => ERRO_DE_SISTEMA
                              , en_referencia_id   => vn_pessoa_id
                              , ev_obj_referencia  => gv_obj_referencia
                              , en_empresa_id      => en_empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_atual_dep_pessoa_old;

-------------------------------------------------------------------------------------------------------

--| Atualiza os dados de tabelas dependentes de Pessoa
procedure pkb_atual_dep_pessoa ( en_multorg_id  in  mult_org.id%type
                               , ev_cpf_cnpj    in  varchar2
                               , en_empresa_id  in  empresa.id%type
                               )
is
   --
   vn_fase              number := 0;
   vn_loggenericocad_id log_generico_cad.id%type;
   vn_pessoa_id         pessoa.id%type;
   vn_existe            number := 0;
   --
   cursor c_nota_fiscal_cnpj is
   select nf.id
     from nota_fiscal      nf
        , nota_fiscal_dest nfd
    where nf.empresa_id        = en_empresa_id
      and nf.dm_ind_emit       = 0 -- Emissão Própria
      and nf.dm_st_proc       in (4,7)
      and nvl(nf.pessoa_id,0) <= 0
      and nfd.notafiscal_id    = nf.id
      and nfd.cnpj             = ev_cpf_cnpj;
   --
   cursor c_nota_fiscal_cpf is
   select nf.id
     from nota_fiscal      nf
        , nota_fiscal_dest nfd
    where nf.empresa_id        = en_empresa_id
      and nf.dm_ind_emit       = 0 -- Emissão Própria
      and nf.dm_st_proc       in (4,7)
      and nvl(nf.pessoa_id,0) <= 0
      and nfd.notafiscal_id    = nf.id
      and nfd.cpf              = ev_cpf_cnpj;
   --
   cursor c_nf_terc_cnpj is
   select nf.id
     from nota_fiscal      nf
        , nota_fiscal_emit nfe
    where nf.empresa_id        = en_empresa_id
      and nf.dm_ind_emit       = 1 -- Terceiros
      and nf.dm_arm_nfe_terc   = 0
      and nvl(nf.pessoa_id,0) <= 0
      and nfe.notafiscal_id    = nf.id
      and nfe.cnpj             = ev_cpf_cnpj;
   --
   cursor c_nf_terc_cpf is
   select nf.id
     from nota_fiscal      nf
        , nota_fiscal_emit nfe
    where nf.empresa_id        = en_empresa_id
      and nf.dm_ind_emit       = 1 -- Terceiros
      and nf.dm_arm_nfe_terc   = 0
      and nvl(nf.pessoa_id,0) <= 0
      and nfe.notafiscal_id    = nf.id
      and nfe.cpf              = ev_cpf_cnpj;
   --
   cursor c_nf_referen is
   select r.id
     from nota_fiscal         nf
        , nota_fiscal_referen r
    where nf.empresa_id       = en_empresa_id
      and r.notafiscal_id     = nf.id
      and r.cnpj_emit         = ev_cpf_cnpj
      and nvl(r.pessoa_id,0) <= 0;
   --
   cursor c_nota_fiscal_transp is
   select nft.id
     from nota_fiscal        nf
        , nota_fiscal_transp nft
    where nf.empresa_id         = en_empresa_id
      and nft.notafiscal_id     = nf.id
      and nft.cnpj_cpf          = ev_cpf_cnpj
      and nvl(nft.pessoa_id,0) <= 0;
   --
   cursor c_conhec_transp is
   select ct.id
        , ct.dm_tomador
     from conhec_transp ct
    where ct.empresa_id        = en_empresa_id
      and ct.dm_ind_emit       = 0 -- Emissão Própria
      and ct.dm_tomador        = 0 -- Remetente
      and nvl(ct.pessoa_id,0) <= 0;
   --
   cursor c_conhec_transp_terc is
   select ct.id
     from conhec_transp      ct
        , conhec_transp_emit ctr
    where ct.empresa_id        = en_empresa_id
      and ct.dm_ind_emit       = 1 -- Terceiro
      and nvl(ct.pessoa_id,0) <= 0
      and ctr.conhectransp_id  = ct.id
      and ctr.cnpj             = ev_cpf_cnpj;
   --
begin
   --
   vn_fase := 1;
   --
   if length(ev_cpf_cnpj) in (11, 14) then
      --
      vn_fase := 2;
      -- busca o ID da Pessoa
      vn_pessoa_id := pk_csf.fkg_pessoa_id_cpf_cnpj ( en_multorg_id => en_multorg_id
                                                    , en_cpf_cnpj   => ev_cpf_cnpj
                                                    );
      --
      vn_fase := 3;
      --
      if nvl(vn_pessoa_id,0) > 0 then
         --
         vn_fase := 4;
         --
         if length(ev_cpf_cnpj) = 14 then
            --
            vn_fase := 5;
            -- Atualiza dados da Nota Fiscal Emissão Própria CNPJ
            for recnf in c_nota_fiscal_cnpj loop
               exit when c_nota_fiscal_cnpj%notfound or (c_nota_fiscal_cnpj%notfound) is null;
               --
               vn_fase := 5.1;
               --
               update nota_fiscal set pessoa_id = vn_pessoa_id
                where id = recnf.id;
               --
            end loop;
            --
            vn_fase := 5.2;
            -- Atualiza dados da Nota Fiscal - Terceiros CNPJ
            for recnf in c_nf_terc_cnpj loop
               exit when c_nf_terc_cnpj%notfound or (c_nf_terc_cnpj%notfound) is null;
               --
               vn_fase := 5.3;
               --
               update nota_fiscal set pessoa_id = vn_pessoa_id
                where id = recnf.id;
               --
            end loop;
            --
         end if;
         --
         vn_fase := 6;
         --
         if length(ev_cpf_cnpj) = 11 then
            --
            vn_fase := 7;
            -- Atualiza dados da Nota Fiscal Emissão Própria CPF
            for recnf in c_nota_fiscal_cpf loop
               exit when c_nota_fiscal_cpf%notfound or (c_nota_fiscal_cpf%notfound) is null;
               --
               vn_fase := 7.1;
               --
               update nota_fiscal set pessoa_id = vn_pessoa_id
                where id = recnf.id;
               --
            end loop;
            --
            vn_fase := 7.2;
            -- Atualiza dados da Nota Fiscal - Terceiros CPF
            for recnf in c_nf_terc_cpf loop
               exit when c_nf_terc_cpf%notfound or (c_nf_terc_cpf%notfound) is null;
               --
               vn_fase := 7.3;
               --
               update nota_fiscal set pessoa_id = vn_pessoa_id
                where id = recnf.id;
               --
            end loop;
            --
         end if;
         --
         vn_fase := 8;
         -- Atualiza dados de Transporte da Nota Fiscal
         for recnft in c_nota_fiscal_transp loop
            exit when c_nota_fiscal_transp%notfound or (c_nota_fiscal_transp%notfound) is null;
            --
            vn_fase := 8.1;
            --
            update nota_fiscal_transp set pessoa_id = vn_pessoa_id
             where id = recnft.id;
            --
         end loop;
         --
         vn_fase := 9;
         -- Artualiza Conhecimento de Transporte
         for recct in c_conhec_transp loop
            exit when c_conhec_transp%notfound or (c_conhec_transp%notfound) is null;
            --
            vn_fase := 10;
            --
            vn_existe := 0;
            --
            if recct.dm_tomador = 0 then -- Remetente
               --
               vn_fase := 10.1;
               --
               if length(ev_cpf_cnpj) = 11 then
                  --
                  vn_fase := 10.2;
                  --
                  begin
                     select distinct 1
                       into vn_existe
                       from conhec_transp_rem
                      where conhectransp_id = recct.id
                        and cpf = ev_cpf_cnpj;
                  exception
                     when others then
                        vn_existe := 0;
                  end;
                  --
               elsif length(ev_cpf_cnpj) = 14 then
                  --
                  vn_fase := 10.3;
                  --
                  begin
                     select distinct 1
                       into vn_existe
                       from conhec_transp_rem
                      where conhectransp_id = recct.id
                        and cnpj = ev_cpf_cnpj;
                  exception
                     when others then
                        vn_existe := 0;
                  end;
                  --
               end if;
               --
            elsif recct.dm_tomador = 1 then -- Expeditor
               --
               vn_fase := 10.4;
               --
               if length(ev_cpf_cnpj) = 11 then
                  --
                  vn_fase := 10.5;
                  --
                  begin
                     select distinct 1
                       into vn_existe
                       from conhec_transp_exped
                      where conhectransp_id = recct.id
                        and cpf = ev_cpf_cnpj;
                  exception
                     when others then
                        vn_existe := 0;
                  end;
                  --
               elsif length(ev_cpf_cnpj) = 14 then
                  --
                  vn_fase := 10.6;
                  --
                  begin
                     select distinct 1
                       into vn_existe
                       from conhec_transp_exped
                      where conhectransp_id = recct.id
                        and cnpj = ev_cpf_cnpj;
                  exception
                     when others then
                        vn_existe := 0;
                  end;
                  --
               end if;
               --
            elsif recct.dm_tomador = 2 then -- Recebedor
               --
               vn_fase := 10.7;
               --
               if length(ev_cpf_cnpj) = 11 then
                  --
                  vn_fase := 10.8;
                  --
                  begin
                     select distinct 1
                       into vn_existe
                       from conhec_transp_receb
                      where conhectransp_id = recct.id
                        and cpf = ev_cpf_cnpj;
                  exception
                     when others then
                        vn_existe := 0;
                  end;
                  --
               elsif length(ev_cpf_cnpj) = 14 then
                  --
                  vn_fase := 10.9;
                  --
                  begin
                     select distinct 1
                       into vn_existe
                       from conhec_transp_receb
                      where conhectransp_id = recct.id
                        and cnpj = ev_cpf_cnpj;
                  exception
                     when others then
                        vn_existe := 0;
                  end;
                  --
               end if;
               --
            elsif recct.dm_tomador = 3 then -- Destinatário
               --
               vn_fase := 10.10;
               --
               if length(ev_cpf_cnpj) = 11 then
                  --
                  vn_fase := 10.11;
                  --
                  begin
                     select distinct 1
                       into vn_existe
                       from conhec_transp_dest
                      where conhectransp_id = recct.id
                        and cpf = ev_cpf_cnpj;
                  exception
                     when others then
                        vn_existe := 0;
                  end;
                  --
               elsif length(ev_cpf_cnpj) = 14 then
                  --
                  vn_fase := 10.12;
                  --
                  begin
                     select distinct 1
                       into vn_existe
                       from conhec_transp_dest
                      where conhectransp_id = recct.id
                        and cnpj = ev_cpf_cnpj;
                  exception
                     when others then
                        vn_existe := 0;
                  end;
                  --
               end if;
               --
            elsif recct.dm_tomador = 4 then -- Outros
               --
               vn_fase := 10.13;
               --
               if length(ev_cpf_cnpj) = 11 then
                  --
                  vn_fase := 10.14;
                  --
                  begin
                     select distinct 1
                       into vn_existe
                       from conhec_transp_tomador
                      where conhectransp_id = recct.id
                        and cpf = ev_cpf_cnpj;
                  exception
                     when others then
                        vn_existe := 0;
                  end;
                  --
               elsif length(ev_cpf_cnpj) = 14 then
                  --
                  vn_fase := 10.15;
                  --
                  begin
                     select distinct 1
                       into vn_existe
                       from conhec_transp_tomador
                      where conhectransp_id = recct.id
                        and cnpj = ev_cpf_cnpj;
                  exception
                     when others then
                        vn_existe := 0;
                  end;
                  --
               end if;
               --
            end if;
            --
            vn_fase := 11;
            --
            if nvl(vn_existe,0) > 0 then
               --
               vn_fase := 11.1;
               --
               update conhec_transp set pessoa_id = vn_pessoa_id
                where id = recct.id;
               --
            end if;
            --
         end loop;
         --
         vn_fase := 12;
         -- Artualiza Conhecimento de Transporte de Terceiros
         for recct in c_conhec_transp_terc loop
            exit when c_conhec_transp_terc%notfound or (c_conhec_transp_terc%notfound) is null;
            --
            vn_fase := 13;
            --
            update conhec_transp set pessoa_id = vn_pessoa_id
             where id = recct.id;
            --
         end loop;
         --
         vn_fase := 14;
         -- Atualiza dados da Nota Fiscal Referenciada
         for recnfr in c_nf_referen loop
            exit when c_nf_referen%notfound or (c_nf_referen%notfound) is null;
            --
            vn_fase := 14.1;
            --
            update nota_fiscal_referen set pessoa_id = vn_pessoa_id
             where id = recnfr.id;
            --
         end loop;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_atual_dep_pessoa fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem        => gv_mensagem_log
                              , ev_resumo          => gv_mensagem_log
                              , en_tipo_log        => ERRO_DE_SISTEMA
                              , en_referencia_id   => vn_pessoa_id
                              , ev_obj_referencia  => gv_obj_referencia
                              , en_empresa_id      => en_empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_atual_dep_pessoa;

-------------------------------------------------------------------------------------------------------

-- Procedimento de integração de parâmetros fiscais de pessoa

procedure pkb_integr_pessoa_tipo_param ( est_log_generico       in out nocopy  dbms_sql.number_table
                                       , est_pessoa_tipo_param  in out nocopy  pessoa_tipo_param%rowtype
                                       , ev_cd_tipo_param       in     varchar2
                                       , ev_valor_tipo_param    in     varchar2
                                       , en_empresa_id          in             empresa.id%type
                                       )
is
   --
   vn_fase            number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   gv_obj_referencia  := 'PESSOA';
   gn_referencia_id   := est_pessoa_tipo_param.pessoa_id;
   --
   vn_fase := 1.1;
   --
   est_pessoa_tipo_param.tipoparam_id := pk_csf.fkg_tipoparam_id ( ev_cd => ev_cd_tipo_param );
   --
   vn_fase := 1.2;
   --
   est_pessoa_tipo_param.valortipoparam_id := pk_csf.fkg_valor_tipo_param_id ( en_tipoparam_id          => est_pessoa_tipo_param.tipoparam_id
                                                                             , ev_valor_tipo_param_cd   => ev_valor_tipo_param
                                                                             );
   --
   vn_fase := 1.3;
   --
   est_pessoa_tipo_param.id := pk_csf.fkg_pessoa_tipo_param_id ( en_pessoa_id          => est_pessoa_tipo_param.pessoa_id
                                                               , en_tipoparam_id       => est_pessoa_tipo_param.tipoparam_id
                                                               , en_valortipoparam_id  => est_pessoa_tipo_param.valortipoparam_id
                                                               );
   --
   vn_fase := 2;
   --
   if nvl(est_pessoa_tipo_param.tipoparam_id,0) <= 0 then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := '"Tipo de Parâmetro" (' || ev_cd_tipo_param || ') esta inválido.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem        => gv_cabec_log
                           , ev_resumo          => gv_mensagem_log
                           , en_tipo_log        => ERRO_DE_VALIDACAO
                           , en_referencia_id   => gn_referencia_id
                           , ev_obj_referencia  => gv_obj_referencia 
                           , en_empresa_id      => en_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_pessoa_tipo_param.valortipoparam_id,0) <= 0 then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := '"Valor do Tipo de Parâmetro" (' || ev_valor_tipo_param || ') esta inválido, para o "Tipo de Parâmetro" (' || ev_cd_tipo_param || ').';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem        => gv_cabec_log
                           , ev_resumo          => gv_mensagem_log
                           , en_tipo_log        => ERRO_DE_VALIDACAO
                           , en_referencia_id   => gn_referencia_id
                           , ev_obj_referencia  => gv_obj_referencia
                           , en_empresa_id      => en_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   --
   if nvl(est_pessoa_tipo_param.pessoa_id,0) <= 0 then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := 'Não informado o participante para o cadastro dos parâmetros fiscais.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem        => gv_cabec_log
                           , ev_resumo          => gv_mensagem_log
                           , en_tipo_log        => ERRO_DE_VALIDACAO
                           , en_referencia_id   => gn_referencia_id
                           , ev_obj_referencia  => gv_obj_referencia
                           , en_empresa_id      => en_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_pessoa_tipo_param.pessoa_id,0) > 0
      and nvl(est_pessoa_tipo_param.tipoparam_id,0) > 0
      and nvl(est_pessoa_tipo_param.valortipoparam_id,0) > 0
      then
      --
      vn_fase := 99.1;
      --
      if nvl(est_pessoa_tipo_param.id,0) > 0 then -- Atualiza
         --
         vn_fase := 99.2;
         --
         update pessoa_tipo_param set valortipoparam_id = est_pessoa_tipo_param.valortipoparam_id
          where id = est_pessoa_tipo_param.id;
         --
      else -- insere
         --
         vn_fase := 99.3;
         --
         select pessoatipoparam_seq.nextval
           into est_pessoa_tipo_param.id
           from dual;
         --
         insert into pessoa_tipo_param ( id
                                       , pessoa_id
                                       , tipoparam_id
                                       , valortipoparam_id
                                       )
                                values ( est_pessoa_tipo_param.id
                                       , est_pessoa_tipo_param.pessoa_id
                                       , est_pessoa_tipo_param.tipoparam_id
                                       , est_pessoa_tipo_param.valortipoparam_id
                                       );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_pessoa_tipo_param fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem        => gv_mensagem_log
                              , ev_resumo          => gv_mensagem_log
                              , en_tipo_log        => ERRO_DE_SISTEMA
                              , en_referencia_id   => est_pessoa_tipo_param.pessoa_id
                              , ev_obj_referencia  => gv_obj_referencia
                              , en_empresa_id      => en_empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_pessoa_tipo_param;

-------------------------------------------------------------------------------------------------------

-- Procedimento de integração de informações de pagamentos de impostos retidos/SPED REINF

procedure pkb_integr_pessoa_info_pir ( est_log_generico         in out nocopy  dbms_sql.number_table
                                     , est_pessoa_info_pir      in out nocopy  pessoa_info_pir%rowtype
                                     , ev_cd_font_pag_reinf     in             rel_fonte_pagad_reinf.cod%type
                                     , en_empresa_id            in             empresa.id%type
                                     )
is
   --
   vn_fase            number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   gv_obj_referencia  := 'PESSOA';
   gn_referencia_id   := est_pessoa_info_pir.pessoa_id;
   --
   vn_fase := 2;
   --
   if nvl(est_pessoa_info_pir.pessoa_id, 0) <= 0 then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := 'Não informado o participante para o cadastro das informações de pagamentos de impostos retidos/SPED REINF.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id      => en_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   if ev_cd_font_pag_reinf is not null then
      --
      est_pessoa_info_pir.relfontepagadreinf_id := pk_csf.fkg_recup_fonte_pagad_reinf_id (ev_cd_font_pag_reinf => ev_cd_font_pag_reinf);
      --
      vn_fase := 3.1;
      --
      if nvl(est_pessoa_info_pir.relfontepagadreinf_id, 0) <= 0 then
         --
         gv_mensagem_log := '"O código da fonte pagadora do REINF" (' || ev_cd_font_pag_reinf || ') está inválido.';
         --
         vn_loggenericocad_id := null;
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_VALIDACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => en_empresa_id
                              );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                 , est_log_generico  => est_log_generico );
         --
      end if;
      --
   end if;
   --
   vn_fase := 4;
   --
   if nvl(est_pessoa_info_pir.dm_ind_nif, 0) not in (1,2,3) then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := '"O indicativo do número de identificação fiscal" (' || est_pessoa_info_pir.dm_ind_nif || ') está inválido ou não foi informado.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => en_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_pessoa_info_pir.pessoa_id,0) > 0
      and ((ev_cd_font_pag_reinf is not null)
      and nvl(est_pessoa_info_pir.relfontepagadreinf_id, 0) > 0)
      and nvl(est_pessoa_info_pir.dm_ind_nif,0) in (1,2,3) then
      --
      vn_fase := 99.1;
      --
      if nvl(est_pessoa_info_pir.id,0) > 0 then -- Atualiza
         --
         vn_fase := 99.2;
         --
         update pessoa_info_pir 
            set dm_ind_nif            = est_pessoa_info_pir.dm_ind_nif
              , nif_benef             = est_pessoa_info_pir.nif_benef
              , relfontepagadreinf_id = est_pessoa_info_pir.relfontepagadreinf_id
              , dt_laudo_molestia     = est_pessoa_info_pir.dt_laudo_molestia
          where id = est_pessoa_info_pir.id;
         --
      else -- insere
         --
         vn_fase := 99.3;
         --
         select pessoainfopir_seq.nextval
           into est_pessoa_info_pir.id
           from dual;
         --
         insert into pessoa_info_pir ( id
                                     , pessoa_id              
                                     , dm_ind_nif             
                                     , nif_benef              
                                     , relfontepagadreinf_id
                                     , dt_laudo_molestia
                                     )
                             values ( est_pessoa_info_pir.id
                                    , est_pessoa_info_pir.pessoa_id
                                    , est_pessoa_info_pir.dm_ind_nif
                                    , est_pessoa_info_pir.nif_benef
                                    , est_pessoa_info_pir.relfontepagadreinf_id
                                    , est_pessoa_info_pir.dt_laudo_molestia
                                    );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_pessoa_info_pir fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_SISTEMA
                              , en_referencia_id      => est_pessoa_info_pir.pessoa_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => en_empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_pessoa_info_pir;

-------------------------------------------------------------------------------------------------------
-- Procedimento insere ou atualiza o registro de uma pessoa
-------------------------------------------------------------------------------------------------------
procedure pkb_ins_atual_pessoa(est_log_generico in out nocopy dbms_sql.number_table,
                               est_pessoa       in out nocopy Pessoa%rowtype,
                               ev_ibge_cidade   in Cidade.ibge_cidade%type default null,
                               en_cod_siscomex  in Pais.cod_siscomex%type default null,
                               en_loteintws_id  in lote_int_ws.id%type default 0,
                               en_empresa_id    in empresa.id%type) is
  --
  vn_fase              number := 0;
  vn_loggenericocad_id log_generico_cad.id%type;
  vv_nro_lote          varchar2(30) := null; 
  --
begin
  --
  vn_fase           := 1;
  gv_obj_referencia := 'PESSOA';
  --
  est_pessoa.dm_tipo_incl := 1; -- Externo, cadastrado na importação dos dados
  --
  if nvl(en_loteintws_id, 0) > 0 then
    vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
  end if;
  --
  gv_cabec_log := trim(est_pessoa.cod_part) || '-' || trim(pk_csf.fkg_converte(est_pessoa.nome)) || vv_nro_lote;
  --
  vn_fase := 2;
  --
  -- Recupera o id da pessoa
  if nvl(est_pessoa.id, 0) <= 0 then
    --
    est_pessoa.id := pk_csf.fkg_pessoa_id_cod_part(en_multorg_id => est_pessoa.multorg_id,
                                                   ev_cod_part   => trim(est_pessoa.cod_part));
    --
  end if;
  --
  vn_fase := 2.1;
  --
  -- Se não existe pessoa, gera a sequence
  if nvl(est_pessoa.id, 0) = 0 then
    --
    select pessoa_seq.nextval 
      into est_pessoa.id 
      from dual;
    --
  end if;
  --
  -- Seta a referencia
  gn_referencia_id := est_pessoa.id;
  --
  delete from log_generico_cad
   where referencia_id = gn_referencia_id
     and obj_referencia = gv_obj_referencia;
  --
  vn_fase := 2.2;
  --
  if nvl(est_pessoa.multorg_id, 0) <= 0 then
    --
    gv_mensagem_log := '"Mult-Organização" não informada.';
    --
    vn_loggenericocad_id := null;
    --
    pkb_log_generico_cad(sn_loggenericocad_id => vn_loggenericocad_id,
                         ev_mensagem          => gv_cabec_log,
                         ev_resumo            => gv_mensagem_log,
                         en_tipo_log          => ERRO_DE_VALIDACAO,
                         en_referencia_id     => gn_referencia_id,
                         ev_obj_referencia    => gv_obj_referencia,
                         en_empresa_id        => en_empresa_id);
    --
    -- Armazena o "loggenerico_id" na memória
    pkb_gt_log_generico_cad(en_loggenerico   => vn_loggenericocad_id,
                            est_log_generico => est_log_generico);
    --
  end if;
  --
  vn_fase := 2.3;
  --
  if not pk_csf.fkg_valida_multorg_id(en_multorg_id => est_pessoa.multorg_id) then
    --
    gv_mensagem_log := '"Mult-Organização" inválido (' || est_pessoa.multorg_id || ').';
    --
    vn_loggenericocad_id := null;
    --
    pkb_log_generico_cad(sn_loggenericocad_id => vn_loggenericocad_id,
                         ev_mensagem          => gv_cabec_log,
                         ev_resumo            => gv_mensagem_log,
                         en_tipo_log          => ERRO_DE_VALIDACAO,
                         en_referencia_id     => gn_referencia_id,
                         ev_obj_referencia    => gv_obj_referencia,
                         en_empresa_id        => en_empresa_id);
    --
    -- Armazena o "loggenerico_id" na memória
    pkb_gt_log_generico_cad(en_loggenerico   => vn_loggenericocad_id,
                            est_log_generico => est_log_generico);
    --
  end if;
  --
  vn_fase := 3;
  --
  -- Verifica se o código é nulo
  if trim(est_pessoa.cod_part) is null then
    --
    vn_fase := 3.1;
    --
    gv_mensagem_log := '"Código do participante" não pode ser nulo.';
    --
    vn_loggenericocad_id := null;
    --
    pkb_log_generico_cad(sn_loggenericocad_id => vn_loggenericocad_id,
                         ev_mensagem          => gv_cabec_log,
                         ev_resumo            => gv_mensagem_log,
                         en_tipo_log          => ERRO_DE_VALIDACAO,
                         en_referencia_id     => gn_referencia_id,
                         ev_obj_referencia    => gv_obj_referencia,
                         en_empresa_id        => en_empresa_id);
    --
    -- Armazena o "loggenerico_id" na memória
    pkb_gt_log_generico_cad(en_loggenerico   => vn_loggenericocad_id,
                            est_log_generico => est_log_generico);
    --
  end if;
  --
  vn_fase := 4;
  --
  -- Valida o nome
  if trim(pk_csf.fkg_converte(est_pessoa.nome)) is null then
    --
    vn_fase := 4.1;
    --
    gv_mensagem_log := '"Nome do participante" não pode ser nulo.';
    --
    vn_loggenericocad_id := null;
    --
    pkb_log_generico_cad(sn_loggenericocad_id => vn_loggenericocad_id,
                         ev_mensagem          => gv_cabec_log,
                         ev_resumo            => gv_mensagem_log,
                         en_tipo_log          => ERRO_DE_VALIDACAO,
                         en_referencia_id     => gn_referencia_id,
                         ev_obj_referencia    => gv_obj_referencia,
                         en_empresa_id        => en_empresa_id);
    --
    -- Armazena o "loggenerico_id" na memória
    pkb_gt_log_generico_cad(en_loggenerico   => vn_loggenericocad_id,
                            est_log_generico => est_log_generico);
    --
  end if;
  --
  vn_fase := 5;
  --
  -- Valida o tipo de pessoa
  if nvl(est_pessoa.dm_tipo_pessoa, -1) not in (0, 1, 2) then
    --
    vn_fase := 5.1;
    --
    gv_mensagem_log := '"Tipo de participante" informado (' || est_pessoa.dm_tipo_pessoa || ') está incorreto.';
    --
    vn_loggenericocad_id := null;
    --
    pkb_log_generico_cad(sn_loggenericocad_id => vn_loggenericocad_id,
                         ev_mensagem          => gv_cabec_log,
                         ev_resumo            => gv_mensagem_log,
                         en_tipo_log          => ERRO_DE_VALIDACAO,
                         en_referencia_id     => gn_referencia_id,
                         ev_obj_referencia    => gv_obj_referencia,
                         en_empresa_id        => en_empresa_id);
    --
    -- Armazena o "loggenerico_id" na memória
    pkb_gt_log_generico_cad(en_loggenerico   => vn_loggenericocad_id,
                            est_log_generico => est_log_generico);
    --
  end if;
  --
  vn_fase := 6;
  --
  -- Recupera o país se não foi informado anteriormente
  if nvl(est_pessoa.pais_id, 0) <= 0 then
    --
    vn_fase := 6.1;
    --
    if en_cod_siscomex is not null then
      --
      vn_fase := 6.2;
      --
      est_pessoa.pais_id := pk_csf.fkg_Pais_siscomex_id(ev_cod_siscomex => en_cod_siscomex);
      --
      if pk_csf.fkg_pais_id_valido(en_pais_id => est_pessoa.pais_id) = false then
        --
        vn_fase := 6.3;
        --
        gv_mensagem_log := '"Código do Siscomex do País" informado (' || en_cod_siscomex || ') está incorreto.';
        --
        vn_loggenericocad_id := null;
        --
        pkb_log_generico_cad(sn_loggenericocad_id => vn_loggenericocad_id,
                             ev_mensagem          => gv_cabec_log,
                             ev_resumo            => gv_mensagem_log,
                             en_tipo_log          => ERRO_DE_VALIDACAO,
                             en_referencia_id     => gn_referencia_id,
                             ev_obj_referencia    => gv_obj_referencia,
                             en_empresa_id        => en_empresa_id);
        --
        -- Armazena o "loggenerico_id" na memória
        pkb_gt_log_generico_cad(en_loggenerico   => vn_loggenericocad_id,
                                est_log_generico => est_log_generico);
        --
      end if;
      --
    end if;
    --
  else
    --
    vn_fase := 6.4;
    --
    -- Válida o país
    if pk_csf.fkg_pais_id_valido(en_pais_id => est_pessoa.pais_id) = false then
      --
      vn_fase := 6.5;
      --
      gv_mensagem_log := '"Identificador do código do País" informado está incorreto.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad(sn_loggenericocad_id => vn_loggenericocad_id,
                           ev_mensagem          => gv_cabec_log,
                           ev_resumo            => gv_mensagem_log,
                           en_tipo_log          => ERRO_DE_VALIDACAO,
                           en_referencia_id     => gn_referencia_id,
                           ev_obj_referencia    => gv_obj_referencia,
                           en_empresa_id        => en_empresa_id);
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad(en_loggenerico   => vn_loggenericocad_id,
                              est_log_generico => est_log_generico);
      --
    end if;
    --
  end if;
  --
  vn_fase := 7;
  --
  -- Recupera o ID da cidade, se não foi informado anteriormente
  if nvl(est_pessoa.cidade_id, 0) <= 0 then
    --
    est_pessoa.cidade_id := pk_csf.fkg_cidade_id_ibge(ev_ibge_cidade => ev_ibge_cidade);
    --
    vn_fase := 7.1;
    --
    if nvl(est_pessoa.cidade_id, 0) <= 0 then
      --
      est_pessoa.cidade_id := pk_csf.fkg_cidade_id_ibge(ev_ibge_cidade => '9999999');
      --
    end if;
    --
  end if;
  --
  vn_fase := 7.2;
  --
  -- Válida se o IBGE é uma cidade do Brasil
  if pk_csf.fkg_ibge_cidade_id(en_cidade_id => est_pessoa.cidade_id) = '9999999' and
     pk_csf.fkg_cod_siscomex_pais_id(en_pais_id => est_pessoa.pais_id) = 1058 then
    --
    vn_fase := 7.3;
    --
    gv_mensagem_log := '"Código IBGE do município" (' || ev_ibge_cidade || ' ) está inválido ou não pode ser 9999999, quando o País for Brasil';
    --
    vn_loggenericocad_id := null;
    --
    pkb_log_generico_cad(sn_loggenericocad_id => vn_loggenericocad_id,
                         ev_mensagem          => gv_cabec_log,
                         ev_resumo            => gv_mensagem_log,
                         en_tipo_log          => ERRO_DE_VALIDACAO,
                         en_referencia_id     => gn_referencia_id,
                         ev_obj_referencia    => gv_obj_referencia,
                         en_empresa_id        => en_empresa_id);
    --
    -- Armazena o "loggenerico_id" na memória
    pkb_gt_log_generico_cad(en_loggenerico   => vn_loggenericocad_id,
                            est_log_generico => est_log_generico);
    --
  end if;
  --
  vn_fase := 7.4;
  --
  -- Se o código do país é do exterior e informou uma cidade do Brasil, atribuir exterior para a cidade
  if pk_csf.fkg_ibge_cidade_id(en_cidade_id => est_pessoa.cidade_id) <> '9999999' and
     pk_csf.fkg_cod_siscomex_pais_id(en_pais_id => est_pessoa.pais_id) <> 1058 then
    --
    est_pessoa.cidade_id := pk_csf.fkg_cidade_id_ibge(ev_ibge_cidade => '9999999');
    --
  end if;
  --
  vn_fase := 8;
  --
  -- Válida o logradouro
  if trim(pk_csf.fkg_converte(est_pessoa.lograd)) is null then
    --
    vn_fase := 8.1;
    --
    gv_mensagem_log := '"Logradouro do participante" não pode ser nulo.';
    --
    vn_loggenericocad_id := null;
    --
    pkb_log_generico_cad(sn_loggenericocad_id => vn_loggenericocad_id,
                         ev_mensagem          => gv_cabec_log,
                         ev_resumo            => gv_mensagem_log,
                         en_tipo_log          => ERRO_DE_VALIDACAO,
                         en_referencia_id     => gn_referencia_id,
                         ev_obj_referencia    => gv_obj_referencia,
                         en_empresa_id        => en_empresa_id);
    --
    -- Armazena o "loggenerico_id" na memória
    pkb_gt_log_generico_cad(en_loggenerico   => vn_loggenericocad_id,
                            est_log_generico => est_log_generico);
    --
  end if;
  --
  vn_fase := 9;
  --
  -- Valida o bairro, caso a pessoa/participante seja do Brasil (1058)
  if nvl(en_cod_siscomex, 0) = 1058 then
   --   
   if est_pessoa.bairro is null then
    --
    vn_fase := 9.1;
    --
    gv_mensagem_log := 'O campo bairro encontra-se vazio, o mesmo é obrigatório para utilizar em obrigações fiscais.';
    --
    vn_loggenericocad_id := null;
    --
    pkb_log_generico_cad(sn_loggenericocad_id => vn_loggenericocad_id,
                         ev_mensagem          => gv_cabec_log,
                         ev_resumo            => gv_mensagem_log,
                         en_tipo_log          => ERRO_DE_VALIDACAO,
                         en_referencia_id     => gn_referencia_id,
                         ev_obj_referencia    => gv_obj_referencia,
                         en_empresa_id        => en_empresa_id);
    --
    -- Armazena o "loggenerico_id" na memória
    pkb_gt_log_generico_cad(en_loggenerico   => vn_loggenericocad_id,
                            est_log_generico => est_log_generico);
    --
    end if;
  --
  end if;
  --
  vn_fase := 10;
  --
  -- #70595 inclusao de validacao do campo dt_hr_alter
  if est_pessoa.DT_HR_ALTER is not null
   and est_pessoa.DT_HR_ALTER > sysdate then
      --
      vn_fase := 10.1;
      --
      gv_mensagem_log := '"Data/Hora de entrada no compliance " ('||est_pessoa.DT_HR_ALTER||') não pode ser maior que a data atual.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad(sn_loggenericocad_id => vn_loggenericocad_id,
                           ev_mensagem          => gv_cabec_log,
                           ev_resumo            => gv_mensagem_log,
                           en_tipo_log          => ERRO_DE_VALIDACAO,
                           en_referencia_id     => gn_referencia_id,
                           ev_obj_referencia    => gv_obj_referencia,
                           en_empresa_id        => en_empresa_id);
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad(en_loggenerico   => vn_loggenericocad_id,
                              est_log_generico => est_log_generico);
      --
  elsif est_pessoa.DT_HR_ALTER is null then
     est_pessoa.DT_HR_ALTER := sysdate ;
  end if;
  --
  vn_fase := 11;
  --
  -- Valida cod_nif
  -- O COD_NIF não será validado aqui pq já foi validado na pk_csf_api_cad.pkb_val_atrib_nif que é chamado pela integração
  -- pk_int_view_cad.pkb_pessoa_ff(Flex Field). Como o campo pode ser nulo essa informação será validada somente na geração da
  -- DIRF no momento de gerar os arquivos?(RPDE/BRPDE/VRPDE)
  --
  -- pk_csf.fkg_converte(est_pessoa.cod_nif
  --
  vn_fase := 12;
  --
  if nvl(est_log_generico.count, 0) > 0 then
    --
    est_pessoa.dm_st_proc := 2; -- Erro de validação
    --
  else
    --
    est_pessoa.dm_st_proc := 1; -- Validada
    --
  end if;
  --
  vn_fase := 99;
  --
  est_pessoa.dm_tipo_incl := nvl(est_pessoa.dm_tipo_incl, 1);
  est_pessoa.cod_part     := trim(upper(est_pessoa.cod_part));
  est_pessoa.nome         := trim(pk_csf.fkg_converte(est_pessoa.nome));
  est_pessoa.fantasia     := trim(pk_csf.fkg_converte(est_pessoa.fantasia));
  est_pessoa.lograd       := trim(pk_csf.fkg_converte(est_pessoa.lograd));
  est_pessoa.nro          := trim(pk_csf.fkg_converte(est_pessoa.nro));
  est_pessoa.cx_postal    := trim(pk_csf.fkg_converte(est_pessoa.cx_postal));
  est_pessoa.compl        := trim(pk_csf.fkg_converte(est_pessoa.compl));
  est_pessoa.bairro       := trim(pk_csf.fkg_converte(est_pessoa.bairro));
  est_pessoa.fone         := trim(pk_csf.fkg_converte(est_pessoa.fone));
  est_pessoa.fax          := trim(pk_csf.fkg_converte(est_pessoa.fax));
  est_pessoa.cod_nif      := trim(pk_csf.fkg_converte(est_pessoa.cod_nif));
  est_pessoa.email        := trim(replace(replace(replace(est_pessoa.email, ',', ';'), ' ;', ''), ' ', ''));
  est_pessoa.email        := trim(replace(est_pessoa.email, '@.com', ''));
  --
  -- Limpa acentos de e-mail
  est_pessoa.email := pk_csf.fkg_limpa_acento(ev_string => est_pessoa.email);
  --
  if est_pessoa.cod_part is not null and est_pessoa.nome is not null and
     est_pessoa.dm_tipo_pessoa in (0, 1, 2) and est_pessoa.cidade_id > 0 and
     nvl(est_pessoa.multorg_id, 0) > 0 then
    --
    vn_fase := 99.1;
    --
    -- Calcula a quantidade de registros totais integrados para ser
    -- mostrado na tela de agendamento.
    --
    begin
      pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj), 0) + 1;
    exception
      when others then
        null;
    end;
    --
    if pk_csf.fkg_existe_pessoa(en_pessoa_id => est_pessoa.id) = true then
      --
      vn_fase := 99.2;
      --
      update pessoa
         set nome           = est_pessoa.nome,
             dm_tipo_pessoa = est_pessoa.dm_tipo_pessoa,
             fantasia       = est_pessoa.fantasia,
             lograd         = est_pessoa.lograd,
             nro            = est_pessoa.nro,
             cx_postal      = est_pessoa.cx_postal,
             compl          = est_pessoa.compl,
             bairro         = est_pessoa.bairro,
             cidade_id      = est_pessoa.cidade_id,
             cep            = est_pessoa.cep,
             fone           = est_pessoa.fone,
             fax            = est_pessoa.fax,
             email          = est_pessoa.email,
             pais_id        = est_pessoa.pais_id,
             multorg_id     = est_pessoa.multorg_id,
             dm_st_proc     = est_pessoa.dm_st_proc,
             cod_nif        = est_pessoa.cod_nif,
             dt_hr_alter    = est_pessoa.dt_hr_alter -- #70595 
       where id             = est_pessoa.id;
      --
    else
      --
      vn_fase := 99.3;
      --
      begin
        --
        insert into pessoa
          (id,
           dm_tipo_incl,
           cod_part,
           nome,
           dm_tipo_pessoa,
           fantasia,
           lograd,
           nro,
           cx_postal,
           compl,
           bairro,
           cidade_id,
           cep,
           fone,
           fax,
           email,
           pais_id,
           multorg_id,
           dm_st_proc,
           cod_nif,
           dt_hr_alter -- #70595 
           )
        values
          (est_pessoa.id,
           est_pessoa.dm_tipo_incl,
           est_pessoa.cod_part,
           est_pessoa.nome,
           est_pessoa.dm_tipo_pessoa,
           est_pessoa.fantasia,
           est_pessoa.lograd,
           est_pessoa.nro,
           est_pessoa.cx_postal,
           est_pessoa.compl,
           est_pessoa.bairro,
           est_pessoa.cidade_id,
           est_pessoa.cep,
           est_pessoa.fone,
           est_pessoa.fax,
           est_pessoa.email,
           est_pessoa.pais_id,
           est_pessoa.multorg_id,
           est_pessoa.dm_st_proc,
           est_pessoa.cod_nif,
           est_pessoa.dt_hr_alter -- #70595 
           );
      exception
        when dup_val_on_index then
          --
          est_pessoa.id := pk_csf.fkg_pessoa_id_cod_part(en_multorg_id => est_pessoa.multorg_id,
                                                         ev_cod_part   => trim(est_pessoa.cod_part));
          --
      end;
      --
    end if;
    --
  end if;
  --
exception
  when others then
    --
    gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_ins_atual_pessoa fase(' || vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenericocad_id Log_Generico_Cad.id%TYPE;
    begin
      --
      pkb_log_generico_cad(sn_loggenericocad_id => vn_loggenericocad_id,
                           ev_mensagem          => gv_mensagem_log,
                           ev_resumo            => gv_mensagem_log,
                           en_tipo_log          => ERRO_DE_SISTEMA,
                           en_referencia_id     => est_pessoa.id,
                           ev_obj_referencia    => gv_obj_referencia,
                           en_empresa_id        => en_empresa_id);
      --
    exception
      when others then
        null;
    end;
    --
end pkb_ins_atual_pessoa;

-------------------------------------------------------------------------------------------------------

-- Procedimento insere ou atualiza os dados de pessoa física
procedure pkb_ins_atual_fisica ( est_log_generico    in out nocopy  dbms_sql.number_table
                               , est_fisica          in out nocopy  fisica%rowtype
                               , en_empresa_id       in             empresa.id%type
                               )
is
   --
   vn_fase            number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   gv_obj_referencia := 'PESSOA';
   -- Seta a referencia
   gn_referencia_id := est_fisica.pessoa_id;
   --
   vn_fase := 2;
   --
   if nvl(est_fisica.num_cpf,0) <= 0 then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := '"CPF do participante" não informado.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_fisica.num_cpf,0) > 0
      and nvl(est_fisica.dig_cpf,0) >= 0
      and nvl(pk_valida_docto.fkg_valida_cpf_cgc( ev_numero => lpad(est_fisica.num_cpf, 9, '0')||lpad(est_fisica.dig_cpf, 2, '0') ), 0) = 0  then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := 'O "CPF do participante" está inválido (' || lpad(est_fisica.num_cpf, 9, '0')||lpad(est_fisica.dig_cpf, 2, '0') || ').';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_fisica.pessoa_id,0) > 0
      and nvl(est_fisica.num_cpf,0) > 0
      and nvl(est_fisica.dig_cpf,0) >= 0 then
      --
      vn_fase := 99.1;
      -- Verifica se exite registro de pessoa física
      begin
         --
         select f.id
           into est_fisica.id
           from fisica f
          where f.pessoa_id = est_fisica.pessoa_id
            and rownum      = 1;
         --
      exception
         when no_data_found then
            est_fisica.id := 0;
         when others then
            raise_application_error(-20102, 'Erro na pkb_ins_atual_fisica: ' || sqlerrm);
      end;
      --
      vn_fase := 99.2;
      --
      est_fisica.num_cpf := nvl(est_fisica.num_cpf,0);
      est_fisica.dig_cpf := nvl(est_fisica.dig_cpf,0);
      --
      if nvl(est_fisica.id,0) <= 0 then
         --
         vn_fase := 99.3;
         --
         select fisica_seq.nextval
           into est_fisica.id
           from dual;
         --
         vn_fase := 99.4;
         --
         insert into fisica
                     ( id
                     , pessoa_id
                     , num_cpf
                     , dig_cpf
                     , rg
                     , inscr_prod
                     )
              values ( est_fisica.id
                     , est_fisica.pessoa_id
                     , est_fisica.num_cpf
                     , est_fisica.dig_cpf
                     , est_fisica.rg
                     , est_fisica.inscr_prod
                     );
         --
      else
         --
         vn_fase := 99.5;
         --
         update fisica set num_cpf    = est_fisica.num_cpf
                         , dig_cpf    = est_fisica.dig_cpf
                         , rg         = est_fisica.rg
                         , inscr_prod = est_fisica.inscr_prod
          where pessoa_id = est_fisica.pessoa_id;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_ins_atual_fisica fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia
                                     , en_empresa_id      => en_empresa_id
                                     );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ins_atual_fisica;

-------------------------------------------------------------------------------------------------------

-- Procedimento insere e atualiza o registro de pessoa juridica
procedure pkb_ins_atual_juridica ( est_log_generico    in out nocopy  dbms_sql.number_table
                                 , est_juridica        in out nocopy  juridica%rowtype
                                 , en_empresa_id       in             empresa.id%type
                                 )
is
   --
   vn_fase            number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
   vv_sigla_estado    varchar2(2);
   vn_teste_suframa   number(1);
   --
begin
   --
   vn_fase := 1;
   gv_obj_referencia := 'PESSOA';
   -- Seta a referencia
   gn_referencia_id := est_juridica.pessoa_id;
   --
   vn_fase := 2;
   --
   if nvl(est_juridica.num_cnpj,0) < 0 or nvl(est_juridica.num_filial,0) <= 0 then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := '"CNPJ do participante" não informado.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_juridica.num_cnpj,0) >= 0
      and nvl(est_juridica.num_filial,0) > 0
      and nvl(est_juridica.dig_cnpj,0) >= 0
      and nvl(pk_valida_docto.fkg_valida_cpf_cgc( ev_numero => lpad(est_juridica.NUM_CNPJ, 8, '0')||lpad(est_juridica.NUM_FILIAL, 4, '0')||lpad(est_juridica.DIG_CNPJ, 2, '0') ), 0) = 0  then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := 'O "CNPJ do participante" está inválido (' || lpad(est_juridica.NUM_CNPJ, 8, '0')||lpad(est_juridica.NUM_FILIAL, 4, '0')||lpad(est_juridica.DIG_CNPJ, 2, '0') || ').';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   -- Busca Estado da Pessoa
   vv_sigla_estado := pk_csf.fkg_siglaestado_pessoaid ( en_pessoa_id => est_juridica.pessoa_id );
   --
   est_juridica.ie := trim ( replace(replace(replace(replace(upper(est_juridica.ie), ' ', ''), '.', ''), '-', ''), '/', '') );
   --
   if trim(est_juridica.ie) is not null
      and trim(vv_sigla_estado) is not null
      and nvl(pk_valida_docto.fkg_valida_ie( ev_inscr_est => est_juridica.ie
                                           , ev_estado => vv_sigla_estado ), 0) = 0  then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := 'A "Inscrição Estadual do participante" está inválida (' || est_juridica.ie || ').';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   --
   -- Atribui nulo no suframa para todos os estados que não são da região norte.
   --
   if vv_sigla_estado not in ('AC', 'AP', 'AM', 'PA', 'RO', 'RR', 'TO') then
      --
      vn_fase := 5.1;
      --      --
      est_juridica.suframa := null;
      --
   elsif est_juridica.suframa is not null
         and pk_valida_docto.fkg_vld_suframa ( inscsuf => est_juridica.suframa ) = false then
      --
      vn_fase := 5.2;
      --
      vn_teste_suframa := 1; -- invalido
      --
      gv_mensagem_log := 'O código do suframa está inválido (' || est_juridica.suframa || ').';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   est_juridica.pessoa_id  := nvl(est_juridica.pessoa_id,0);
   est_juridica.num_cnpj   := nvl(est_juridica.num_cnpj,0);
   est_juridica.num_filial := nvl(est_juridica.num_filial,0);
   est_juridica.dig_cnpj   := nvl(est_juridica.dig_cnpj,0);
   --
   if nvl(est_juridica.pessoa_id,0) > 0
      and nvl(est_juridica.num_cnpj,0) >= 0
      and nvl(est_juridica.num_filial,0) > 0
      and nvl(est_juridica.dig_cnpj,0) >= 0
      and nvl(vn_teste_suframa,0) <> 1 then
      --
      vn_fase := 99.1;
      -- Verifica se exite registro de pessoa física
      begin
         --
         select j.id
           into est_juridica.id
           from juridica j
          where j.pessoa_id = est_juridica.pessoa_id
            and rownum      = 1;
         --
      exception
         when no_data_found then
            est_juridica.id := 0;
         when others then
            raise_application_error(-20102, 'Erro na pkb_ins_atual_juridica: ' || sqlerrm);
      end;
      --
      vn_fase := 99.2;
      --
      if nvl(est_juridica.id,0) <= 0 then
         --
         vn_fase := 99.3;
         --
         select juridica_seq.nextval
           into est_juridica.id
           from dual;
         --
         vn_fase := 99.4;
         --
         insert into juridica
                     ( id
                     , pessoa_id
                     , num_cnpj
                     , num_filial
                     , dig_cnpj
                     , ie
                     , iest
                     , im
                     , cnae
                     , suframa
                     )
              values ( est_juridica.id
                     , est_juridica.pessoa_id
                     , est_juridica.num_cnpj
                     , est_juridica.num_filial
                     , est_juridica.dig_cnpj
                     , est_juridica.ie
                     , est_juridica.iest
                     , est_juridica.im
                     , est_juridica.cnae
                     , est_juridica.suframa
                     );
         --
      else
         --
         vn_fase := 99.5;
         --
         update juridica set num_cnpj      = est_juridica.num_cnpj
                           , num_filial    = est_juridica.num_filial
                           , dig_cnpj      = est_juridica.dig_cnpj
                           , ie            = est_juridica.ie
                           , iest          = est_juridica.iest
                           , im            = est_juridica.im
                           , cnae          = est_juridica.cnae
                           , suframa       = est_juridica.suframa
          where pessoa_id = est_juridica.pessoa_id;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_ins_atual_juridica fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia
                                     , en_empresa_id      => en_empresa_id
                                     );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ins_atual_juridica;

-------------------------------------------------------------------------------------------------------

-- Procedimento insere o registro de alteração da Tabela do Cadastro do Participante
procedure pkb_ins_alter_pessoa ( en_pessoa_id  in alter_pessoa.pessoa_id%type
                               , ev_cont_ant   in alter_pessoa.cont_ant%type
                               , ev_nr_campo   in alter_pessoa.nr_campo%type
                               , ed_dt_alt     in alter_pessoa.dt_alt%type default null )
is
   --
   vn_qtde_reg number := 0;
   --
begin
   --
   if nvl(en_pessoa_id,0) > 0
      and ev_cont_ant is not null
      and ev_nr_campo is not null then
      --
      begin
         --
         select count(1)
           into vn_qtde_reg
           from alter_pessoa
          where pessoa_id = en_pessoa_id
            and trunc(dt_alt) = trunc(sysdate)
            and nr_campo = ev_nr_campo;
         --
      exception
         when others then
            vn_qtde_reg := 0;
      end;
      -- Se não existe alterado no dia para o registro da pessoa então inclui a alteração
      -- pois no projeto sped só pode ter uma alteração de registro por dia
      if nvl(vn_qtde_reg,0) <= 0 then
         --
         insert into alter_pessoa
                     ( id
                     , pessoa_id
                     , cont_ant
                     , nr_campo
                     , dt_alt )
              values ( alterpessoa_seq.nextval
                     , en_pessoa_id
                     , ev_cont_ant
                     , ev_nr_campo
                     , nvl(ed_dt_alt, sysdate) );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pkb_ins_alter_pessoa: ' || sqlerrm);
end pkb_ins_alter_pessoa;

-------------------------------------------------------------------------------------------------------
-- Procedimento para integração dos dados de Unidade de Medida
procedure pkb_integr_unid_med ( est_log_generico    in out nocopy  dbms_sql.number_table
                              , est_unidade         in out nocopy  unidade%rowtype 
                              , en_loteintws_id     in             lote_int_ws.id%type default 0
                              , en_empresa_id       in             empresa.id%type
                              )
is
   --
   vn_fase               number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
   vv_nro_lote           varchar2(30) := null;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'UNIDADE';
   --
   gv_cabec_log := est_unidade.sigla_unid || '-' || pk_csf.fkg_converte(est_unidade.descr) || vv_nro_lote;
   --
   vn_fase := 2;
   -- Busca o ID da unidade
   est_unidade.id := pk_csf.fkg_Unidade_id ( en_multorg_id => est_unidade.multorg_id
                                           , ev_sigla_unid => est_unidade.sigla_unid);
   --
   vn_fase := 2.1;
   --
   if nvl(est_unidade.id,0) <= 0 then
      --
      select unidade_seq.nextval
        into est_unidade.id
        from dual;
      --
   end if;
   --
   vn_fase := 2.2;
   -- Seta a referencia
   gn_referencia_id := est_unidade.id;
   --
   delete from log_generico_cad
    where REFERENCIA_ID = gn_referencia_id
      and OBJ_REFERENCIA = gv_obj_referencia;
   --
   vn_fase := 2.3;
   --
   if nvl(est_unidade.multorg_id,0) <= 0 then
      --
      gv_mensagem_log := '"Mult-Organização" não informada.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2.4;
   --
   if not pk_csf.fkg_valida_multorg_id ( en_multorg_id => est_unidade.multorg_id ) then
      --
      gv_mensagem_log := '"Mult-Organização" inválido ('|| est_unidade.multorg_id || ').';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   -- Válida sigla da unidade
   if trim(est_unidade.sigla_unid) is null then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := '"Sigla da Unidade de Medida" não pode ser nula.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   --
   if trim(pk_csf.fkg_converte(est_unidade.descr)) is null then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := '"Descrição da Unidade de Medida" não pode ser nula.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   --
   if nvl(est_log_generico.count,0) > 0 then
      est_unidade.dm_st_proc := 2; -- Erro de validação
   else
      est_unidade.dm_st_proc := 1; -- Validado
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_unidade.multorg_id,0) > 0
      and est_unidade.sigla_unid is not null
      then
      --
      vn_fase := 99.1;
      --
      -- Calcula a quantidade de registros totais integrados para ser
      -- mostrado na tela de agendamento.
      --
      begin
         pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
      exception
         when others then
         null;
      end;
      --
      if pk_csf.fkg_existe_unidade_id ( en_unidade_id => est_unidade.id ) = true then
         --
         vn_fase := 99.2;
         --
         update unidade set sigla_unid = est_unidade.sigla_unid
                          , descr      = pk_csf.fkg_converte(est_unidade.descr)
                          , multorg_id = est_unidade.multorg_id
                          , dm_st_proc = est_unidade.dm_st_proc
          where id = est_unidade.id;
         --
      else
         --
         insert into unidade ( id
                             , sigla_unid
                             , descr
                             , multorg_id
                             , dm_st_proc
                             )
                      values ( est_unidade.id
                             , est_unidade.sigla_unid
                             , pk_csf.fkg_converte(est_unidade.descr)
                             , est_unidade.multorg_id
                             , est_unidade.dm_st_proc
                             );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_unid_med fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia
                                     , en_empresa_id      => en_empresa_id
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_unid_med;

-------------------------------------------------------------------------------------------------------

-- Procedimento integra as informações do Item
procedure pkb_integr_item ( est_log_generico    in out nocopy  dbms_sql.number_table
                          , est_item            in out nocopy  item%rowtype
                          , en_multorg_id       in             mult_org.id%type
                          , ev_cpf_cnpj         in             varchar2
                          , ev_sigla_unid       in             unidade.sigla_unid%type
                          , ev_tipo_item        in             tipo_item.cd%type
                          , ev_cod_ncm          in             ncm.cod_ncm%type
                          , ev_cod_ex_tipi      in             ex_tipi.cod_ex_tipi%type
                          , ev_tipo_servico     in             tipo_servico.cod_lst%type
                          , ev_cest_cd          in             cest.cd%type
                          , en_loteintws_id     in             lote_int_ws.id%type default 0
                          )
is
   --
   vn_fase               number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
   vv_nro_lote           varchar2(30) := null;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'ITEM';
   --
   vn_fase := 1.1;
   --
   if nvl(est_item.empresa_id,0) <= 0 then
      --
      est_item.empresa_id := pk_csf.fkg_empresa_id2 ( ev_cod_matriz        => null
                                                    , ev_cod_filial        => null
                                                    , ev_empresa_cpf_cnpj  => ev_cpf_cnpj 
                                                    , en_multorg_id        => en_multorg_id 
                                                    );
      --
   end if;
   --
   vn_fase := 1.2;
   --
   gv_cabec_log := 'Empresa: ' || pk_csf.fkg_nome_empresa ( en_empresa_id  => est_item.empresa_id
                                                           );
   --
   vn_fase := 1.3;
   --
   gv_cabec_log := gv_cabec_log || chr(10);
   --
   gv_cabec_log := gv_cabec_log || trim(upper(est_item.cod_item)) || '-' || trim(pk_csf.fkg_converte(est_item.descr_item)) || vv_nro_lote;
   --
   vn_fase := 2;
   --
   if nvl(est_item.id,0) <= 0 then -- Integração Open Interface
      -- Função retorna o ID da tabela Item, conforme ID Empresa, para Integração do Item por Open Interface, sem verificar a matriz
      est_item.id := pk_csf.fkg_item_id ( en_empresa_id => est_item.empresa_id
                                        , ev_cod_item   => trim(upper(est_item.cod_item))
                                        );
   else -- Validação de ambiente ou Integração WebService
      -- Recuperar o ID do Item na empresa em questão, e não encontrando, recupera da empresa matriz
      est_item.id := pk_csf.fkg_Item_id_conf_empr ( en_empresa_id => est_item.empresa_id
                                                  , ev_cod_item   => trim(upper(est_item.cod_item))
                                                  );
   end if;
   --
   vn_fase := 2.1;
   --
   if nvl(est_item.id,0) <= 0 then
      --
      select item_seq.nextval
        into est_item.id
        from dual;
      --
   end if;
   -- Seta a referencia
   gn_referencia_id := est_item.id;
   --
   delete from log_generico_cad
    where REFERENCIA_ID = gn_referencia_id
      and OBJ_REFERENCIA = gv_obj_referencia;
   --
   vn_fase := 3;
   -- Válida o código do Item
   if trim(upper(est_item.cod_item)) is null then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := '"Código do Item" não pode ser nulo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => est_item.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   -- Válida a descrição do item
   if trim(pk_csf.fkg_converte(est_item.descr_item)) is null then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := '"Descrição do Item" não pode ser nula.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => est_item.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   -- Unidade de Medida
   if nvl(est_item.unidade_id,0) <= 0 then

      est_item.unidade_id := pk_csf.fkg_Unidade_id ( en_multorg_id => en_multorg_id
                                                   , ev_sigla_unid => trim(ev_sigla_unid)
                                                   );
                                                   
   end if;
   --
   vn_fase := 5.1;
   -- Válida a Unidade
   if pk_csf.fkg_existe_unidade_id ( en_unidade_id => est_item.unidade_id ) = false then
      --
      vn_fase := 5.2;
      --
      gv_mensagem_log := '"Sigla da Unidade do Item" está inválida(' || ev_sigla_unid || ')';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => est_item.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 6;
   -- Válida a origem da mercadoria
   if nvl(est_item.dm_orig_merc,-1) not in (0, 1, 2, 3, 4, 5, 6, 7, 8) then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := '"Origem da Mercadoria" está inválida(' || est_item.dm_orig_merc || ')';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => est_item.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
      est_item.dm_orig_merc := 0;
      --
   end if;
   --
   vn_fase := 7;
   -- tipo de item
   if nvl(est_item.tipoitem_id,0) <= 0 then
      est_item.tipoitem_id := pk_csf.fkg_Tipo_Item_id ( ev_cd => ev_tipo_item );
   end if;
   --
   vn_fase := 7.1;
   -- Válida o tipo de item
   if nvl(est_item.tipoitem_id,0) <= 0 then
      --
      vn_fase := 7.2;
      --
      gv_mensagem_log := '"Tipo de Item" está inválido(' || ev_tipo_item || ')';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => est_item.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 8;
   -- Válida NCM
   if nvl(est_item.ncm_id,0) <= 0 then
      est_item.ncm_id := pk_csf.fkg_Ncm_id ( ev_cod_ncm => trim(ev_cod_ncm) );
   end if;
   --
   vn_fase := 8.1;
   -- Fica dispensado o preenchimento deste campo, quando o tipo de item informado no campo TP_ITEM for
   -- igual a 07 - Material de Uso e Consumo; ou 08 ¿ Ativo Imobilizado; ou 09 -Serviços; ou 10 - Outros insumos; ou 99 - Outras.
   --
   if pk_csf.fkg_cd_tipo_item_id ( en_tipoitem_id => est_item.tipoitem_id ) not in ('07', '08', '09', '10', '99')
      and nvl(est_item.ncm_id,0) <= 0 then
      --
      vn_fase := 7.2;
      --
      gv_mensagem_log := '"NCM" está inválido (' || ev_cod_ncm || '). Para os Itens vinculados ao tipo de item 00-Mercadoria para Revenda, 01-Matéria-Prima'||
                         ', 02-Embalagem, 03-Produto em Processo, 04-Produto Acabado, 05-Subproduto e 06-Produto Intermediário, o NCM deve ser informado.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => est_item.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 8;
   -- EX TIPI
   if nvl(est_item.extipi_id,0) <= 0 then
      est_item.extipi_id := pk_csf.fkg_ex_tipi_id ( ev_cod_ex_tipi  => trim(ev_cod_ex_tipi)
                                                  , en_ncm_id       => est_item.ncm_id );
   end if;
   --
   vn_fase := 8.1;
   --
   if nvl(est_item.extipi_id,0) <= 0 and trim(ev_cod_ex_tipi) is not null then
      --
      vn_fase := 8.2;
      --
      gv_mensagem_log := '"EX TIPI do NCM" está inválida (' || ev_cod_ex_tipi || ')';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => est_item.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 9;
   -- Válida tipo de serviço
   if nvl(est_item.tpservico_id,0) <= 0 then
      est_item.tpservico_id := pk_csf.fkg_Tipo_Servico_id ( ev_cod_lst => trim(ev_tipo_servico) );
   end if;
   --
   vn_fase := 9.1;
   --
   if nvl(est_item.tpservico_id,0) <= 0
      and trim(ev_tipo_servico) is not null then
      --
      vn_fase := 9.2;
      --
      gv_mensagem_log := '"Código do Serviço" está inválido (' || ev_tipo_servico || ').';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => est_item.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 10;
   --
   if nvl(est_item.aliq_icms,0) < 0 then
      --
      vn_fase := 10.1;
      --
      gv_mensagem_log := '"Alíquota de ICMS" não pode ser negativa.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => est_item.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 11;
   --
   est_item.cest_id := pk_csf.fkg_id_cest_cd ( ev_cest_cd => trim(ev_cest_cd) );
   --
   if trim(ev_cest_cd) is not null
      and nvl(est_item.cest_id,0) > 0
      then
      --
      gv_mensagem_log := '"Código do CEST" (' || ev_cest_cd || ') informado esta inválido.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => est_item.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 12;
   --
   -- #70595 inclusao de validacao do campo dt_hr_alter
   if est_item.DT_HR_ALTER is not null
    and est_item.DT_HR_ALTER > sysdate then
       --
       vn_fase := 12.1;
       --
       gv_mensagem_log := '"Data/Hora de entrada no compliance " ('||est_item.DT_HR_ALTER||') não pode ser maior que a data atual.';
       --
       vn_loggenericocad_id := null;
       --
       pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                   , ev_mensagem        => gv_cabec_log
                                   , ev_resumo          => gv_mensagem_log
                                   , en_tipo_log        => ERRO_DE_VALIDACAO
                                   , en_referencia_id   => gn_referencia_id
                                   , ev_obj_referencia  => gv_obj_referencia
                                   , en_empresa_id      => est_item.empresa_id
                                   );
       --
       -- Armazena o "loggenerico_id" na memória
       pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                      , est_log_generico  => est_log_generico );
       --
   elsif est_item.DT_HR_ALTER is null then
      est_item.DT_HR_ALTER := sysdate ;
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_log_generico.count,0) > 0 then
      est_item.dm_st_proc := 2; -- Erro Validação
   else
      est_item.dm_st_proc := 1; -- Validado
   end if;
   --
   est_item.cod_item := trim(upper(est_item.cod_item));
   --
   if nvl(est_item.empresa_id,0) > 0
      and trim(est_item.cod_item) is not null
      and trim(pk_csf.fkg_converte(est_item.descr_item)) is not null
      and nvl(est_item.unidade_id,0) > 0 then
      --
      -- Calcula a quantidade de registros totais integrados para ser
      -- mostrado na tela de agendamento.
      --
      begin
         pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
      exception
         when others then
         null;
      end;
      --
      vn_fase := 99.1;
      --
      if pk_csf.fkg_item_id_valido ( en_item_id => est_item.id ) = true then
         --
         vn_fase := 99.2;
         --
         update item set empresa_id    = est_item.empresa_id
                       , cod_item      = trim(est_item.cod_item)
                       , descr_item    = trim(pk_csf.fkg_converte(est_item.descr_item))
                       , unidade_id    = est_item.unidade_id
                       , dm_orig_merc  = est_item.dm_orig_merc
                       , tipoitem_id   = est_item.tipoitem_id
                       , ncm_id        = est_item.ncm_id
                       , cod_barra     = trim(pk_csf.fkg_converte(est_item.cod_barra))
                       , cod_ant_item  = trim(est_item.cod_ant_item)
                       , tpservico_id  = est_item.tpservico_id
                       , extipi_id     = est_item.extipi_id
                       , aliq_icms     = est_item.aliq_icms
                       , dm_st_proc    = est_item.dm_st_proc
                       , cest_id       = est_item.cest_id
                       , dt_hr_alter   = est_item.dt_hr_alter --#70595 inclusao
          where id = est_item.id;
         --
      else
         --
         vn_fase := 99.3;
         --
         insert into item ( id
                          , empresa_id
                          , cod_item
                          , descr_item
                          , unidade_id
                          , dm_orig_merc
                          , tipoitem_id
                          , ncm_id
                          , cod_barra
                          , cod_ant_item
                          , tpservico_id
                          , extipi_id
                          , aliq_icms
                          , dm_st_proc
                          , cest_id
                          , dt_hr_alter   --#70595 inclusao
                          )
                   values ( est_item.id
                          , est_item.empresa_id
                          , trim(est_item.cod_item)
                          , trim(pk_csf.fkg_converte(est_item.descr_item))
                          , est_item.unidade_id
                          , est_item.dm_orig_merc
                          , est_item.tipoitem_id
                          , est_item.ncm_id
                          , trim(pk_csf.fkg_converte(est_item.cod_barra))
                          , trim(est_item.cod_ant_item)
                          , est_item.tpservico_id
                          , est_item.extipi_id
                          , est_item.aliq_icms
                          , est_item.dm_st_proc
                          , est_item.cest_id
                          , est_item.dt_hr_alter --#70595 inclusao
                          );
         --
      end if;
      --
      vn_fase := 99.4;
      -- Função retorna o indicador de atualização de dependências do Item na Integração de Cadastros Gerais - Item
      if nvl(pk_csf.fkg_empr_dm_atual_dep_item(est_item.empresa_id),1) = 1 then -- 0-não, 1-sim
         --
         vn_fase := 99.5;
         -- Atualiza os dados de tabelas dependentes de ITEM
         pkb_atual_dep_item ( en_multorg_id => en_multorg_id
                            , ev_cpf_cnpj   => ev_cpf_cnpj
                            , ev_cod_item   => trim(est_item.cod_item)
                            );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_item fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia
                                     , en_empresa_id      => est_item.empresa_id
                                     );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                 , est_log_generico  => est_log_generico );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_item;

-------------------------------------------------------------------------------------------------------

-- Procedimento integra as informações do Item
procedure pkb_integr_item_ff ( est_log_generico    in out nocopy  dbms_sql.number_table
                             , en_item_id          in             item.id%type
                             , ev_atributo         in             varchar2
                             , ev_valor            in             varchar2
                             )
is
   --
   vn_fase               number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
   vv_mensagem           varchar2(1000) := null;
   vn_dmtipocampo        ff_obj_util_integr.dm_tipo_campo%type;
   --
   vv_cest_cd            cest.cd%type;
   vn_cest_id            cest.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   gv_mensagem_log := null;
   --
   if trim(ev_atributo) is null then
      --
      gv_mensagem_log := 'Item (Produtos e Serviços): "Atributo" deve ser informado.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem        => gv_cabec_log
                           , ev_resumo          => gv_mensagem_log
                           , en_tipo_log        => ERRO_DE_VALIDACAO
                           , en_referencia_id   => gn_referencia_id
                           , ev_obj_referencia  => gv_obj_referencia
                           , en_empresa_id      => gt_row_item.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 1.1;
   --
   if trim(ev_valor) is null then
      --
      gv_mensagem_log := 'Item (Produtos e Serviços): "VALOR" referente ao atributo deve ser informado.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem        => gv_cabec_log
                           , ev_resumo          => gv_mensagem_log
                           , en_tipo_log        => ERRO_DE_VALIDACAO
                           , en_referencia_id   => gn_referencia_id
                           , ev_obj_referencia  => gv_obj_referencia
                           , en_empresa_id      => gt_row_item.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2;
   --
   vv_mensagem := pk_csf.fkg_ff_verif_campos ( ev_obj_name => 'VW_CSF_ITEM_FF'
                                             , ev_atributo => trim(ev_atributo)
                                             , ev_valor    => trim(ev_valor) 
                                             );
   --
   vn_fase := 3;
   --
   if vv_mensagem is not null then
      --
      gv_mensagem_log := vv_mensagem;
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem        => gv_cabec_log
                           , ev_resumo          => gv_mensagem_log
                           , en_tipo_log        => ERRO_DE_VALIDACAO
                           , en_referencia_id   => gn_referencia_id
                           , ev_obj_referencia  => gv_obj_referencia
                           , en_empresa_id      => gt_row_item.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   else
      --
      vn_fase := 4;
      --
      vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo( ev_obj_name => 'VW_CSF_ITEM_FF'
                                                         , ev_atributo => trim(ev_atributo) );
      --
      vn_fase := 5;
      --
      if trim(ev_atributo) = 'CEST'
         then
         --
         if trim(ev_valor) is not null then
            --
            if vn_dmtipocampo = 2 then -- tipo de campo = caractere
               --
               vv_cest_cd := pk_csf.fkg_ff_ret_vlr_caracter ( ev_obj_name => 'VW_CSF_ITEM_FF'
                                                            , ev_atributo => trim(ev_atributo)
                                                            , ev_valor    => trim(ev_valor) );
               --
               vn_cest_id := pk_csf.fkg_id_cest_cd ( ev_cest_cd => vv_cest_cd );
               --
               if nvl(vn_cest_id,0) <= 0 then
                  --
                  gv_mensagem_log := 'Código do CEST (' || vv_cest_cd || ') informado esta inválido.';
                  --
                  vn_loggenericocad_id := null;
                  --
                  pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                       , ev_mensagem        => gv_cabec_log
                                       , ev_resumo          => gv_mensagem_log
                                       , en_tipo_log        => ERRO_DE_VALIDACAO
                                       , en_referencia_id   => gn_referencia_id
                                       , ev_obj_referencia  => gv_obj_referencia
                                       , en_empresa_id      => gt_row_item.empresa_id
                                       );
                  --
                  -- Armazena o "loggenerico_id" na memória
                  pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                          , est_log_generico  => est_log_generico );
                  --
               end if;
               --
            else
               --
               gv_mensagem_log := 'O valor do campo "CEST" informado não confere com o tipo de campo, deveria ser CARACTERE.';
               --
               vn_loggenericocad_id := null;
               --
               pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                    , ev_mensagem        => gv_cabec_log
                                    , ev_resumo          => gv_mensagem_log
                                    , en_tipo_log        => ERRO_DE_VALIDACAO
                                    , en_referencia_id   => gn_referencia_id
                                    , ev_obj_referencia  => gv_obj_referencia
                                    , en_empresa_id      => gt_row_item.empresa_id
                                    );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                       , est_log_generico  => est_log_generico );
               --
            end if;
            --
         end if;
         --
      else
         --
         gv_mensagem_log := '"Atributo" ('||ev_atributo||') e "VALOR" ('||ev_valor||') relacionados, não especificados no processo.';
         --
         vn_loggenericocad_id := null;
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem        => gv_cabec_log
                              , ev_resumo          => gv_mensagem_log
                              , en_tipo_log        => ERRO_DE_VALIDACAO
                              , en_referencia_id   => gn_referencia_id
                              , ev_obj_referencia  => gv_obj_referencia
                              , en_empresa_id      => gt_row_item.empresa_id
                              );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                 , est_log_generico  => est_log_generico );
         --
      end if;
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(en_item_id,0) > 0 then
      --
      if trim(ev_atributo) = 'CEST'
         and trim(vv_cest_cd) is not null
         and nvl(vn_cest_id,0) > 0
         then
         --
         update item set cest_id = vn_cest_id
          where id = en_item_id;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_item_ff fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem        => gv_mensagem_log
                              , ev_resumo          => gv_mensagem_log
                              , en_tipo_log        => ERRO_DE_SISTEMA
                              , en_referencia_id   => gn_referencia_id
                              , ev_obj_referencia  => gv_obj_referencia
                              , en_empresa_id      => gt_row_item.empresa_id
                              );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                 , est_log_generico  => est_log_generico );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_item_ff;

-------------------------------------------------------------------------------------------------------

-- Procedimento integra os item de combustiveis existentes na tabela da ANP
procedure pkb_integr_item_anp ( est_log_generico    in out nocopy  dbms_sql.number_table
                              , est_item_anp        in out nocopy  item_anp%rowtype
                              , en_empresa_id       in             empresa.id%type
                              )
is
   --
   vn_fase            number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
   vn_qtde            number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   if trim(est_item_anp.cod_prod_anp) is not null then
      --
      vn_fase := 1.1;
      -- válida cod_anp
      if pk_csf.fkg_cod_anp_valido ( ev_cod_anp => trim(est_item_anp.cod_prod_anp) ) = false then
         --
         vn_fase := 1.2;
         --
         gv_mensagem_log := '"Código do Produto da ANP" (' || trim(est_item_anp.cod_prod_anp) || ') está inválido.';
         --
         vn_loggenericocad_id := null;
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                     , ev_mensagem        => gv_cabec_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_VALIDACAO
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia
                                     , en_empresa_id      => en_empresa_id
                                     );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                        , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 2;
      --
      if nvl(est_item_anp.item_id,0) > 0 then
         --
         select count(1)
           into vn_qtde
           from item_anp
          where item_id = est_item_anp.item_id;
         --
         if nvl(vn_qtde,0) > 0 then
            --
            update item_anp set cod_prod_anp = trim(est_item_anp.cod_prod_anp)
             where item_id = est_item_anp.item_id;
            --
         else
            --
            insert into item_anp ( id
                                 , item_id
                                 , cod_prod_anp
                                 )
                          values ( itemanp_seq.nextval
                                 , est_item_anp.item_id
                                 , trim(est_item_anp.cod_prod_anp)
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
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_item_anp fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia
                                     , en_empresa_id      => en_empresa_id
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_item_anp;

-------------------------------------------------------------------------------------------------------

-- Procedimento integra as informações de Códigos de Grupos por Marca Comercial/Refrigerantes
procedure pkb_integr_item_marca_comerc ( est_log_generico      in out nocopy  dbms_sql.number_table
                                       , est_item_marca_comerc in out nocopy  item_marca_comerc%rowtype
                                       , en_empresa_id         in             empresa.id%type 
                                       )
is
   --
   vn_fase           number := 0;
   vn_loggenericocad_id Log_Generico_Cad.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(est_item_marca_comerc.item_id,0) <= 0 then
      --
      vn_fase := 1.1;
      --
      gv_mensagem_log := 'Identificador do item inválido.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2;
   --
   if nvl(est_item_marca_comerc.dm_cod_tab,0) not between 01 and 12 then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := '"Código indicador da Tabela de Incidência" ('||nvl(est_item_marca_comerc.dm_cod_tab,0)||') deve estar entre 01 e 12.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_item_marca_comerc.item_id,0) > 0 then
      --
      vn_fase := 99.1;
      --
      est_item_marca_comerc.id := pk_csf_efd_pc.fkg_id_item_marca_comerc ( en_item_id => est_item_marca_comerc.item_id );
      --
      vn_fase := 99.2;
      --
      if nvl(est_item_marca_comerc.id,0) > 0 then
         --
         vn_fase := 99.3;
         --
         update item_marca_comerc im
            set im.dm_cod_tab = est_item_marca_comerc.dm_cod_tab
              , im.cod_gru    = est_item_marca_comerc.cod_gru
              , im.marca_com  = est_item_marca_comerc.marca_com
          where im.id = est_item_marca_comerc.id;
         --
      else
         --
         vn_fase := 99.4;
         --
         insert into item_marca_comerc ( id
                                       , item_id
                                       , dm_cod_tab
                                       , cod_gru
                                       , marca_com )
                                values ( itemmarcacomerc_seq.nextval
                                       , est_item_marca_comerc.item_id
                                       , est_item_marca_comerc.dm_cod_tab
                                       , est_item_marca_comerc.cod_gru
                                       , est_item_marca_comerc.marca_com );
         --
      end if;
      --
   else
      --
      vn_fase := 99.5;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_item_marca_comerc fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia
                                     , en_empresa_id      => en_empresa_id
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_item_marca_comerc;

-------------------------------------------------------------------------------------------------------

-- Procedimento integra as informações de conversão de unidade
procedure pkb_integr_conv_unid ( est_log_generico             in out nocopy  dbms_sql.number_table
                               , est_conversao_unidade        in out nocopy  conversao_unidade%rowtype
                               , ev_sigla_unid                in             unidade.sigla_unid%type
                               , en_multorg_id                in             mult_org.id%type
                               , en_empresa_id                in             empresa.id%type
                               )
is
   --
   vn_fase            number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   est_conversao_unidade.unidade_id := pk_csf.fkg_Unidade_id ( en_multorg_id => en_multorg_id
                                                             , ev_sigla_unid => trim(ev_sigla_unid)
                                                             );
   --
   vn_fase := 1.1;
   --
   if nvl(est_conversao_unidade.unidade_id,0) <= 0 then
      --
      vn_fase := 1.2;
      --
      gv_mensagem_log := '"Unidade a ser convertida" (' || ev_sigla_unid || ') está inválida.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2;
   --
   if nvl(est_conversao_unidade.fat_conv,0) <= 0 then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := '"Fator de Conversão" ('||nvl(est_conversao_unidade.fat_conv,0)||') não pode ser zero ou negativo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_conversao_unidade.unidade_id,0) > 0
      and nvl(est_conversao_unidade.item_id,0) > 0 then
      --
      vn_fase := 99.1;
      --
      est_conversao_unidade.id := pk_csf.fkg_id_conv_unid ( en_item_id     => est_conversao_unidade.item_id
                                                          , ev_unidade_id  => est_conversao_unidade.unidade_id );
      --
      vn_fase := 99.2;
      --
      if nvl(est_conversao_unidade.id,0) > 0 then
         --
         vn_fase := 99.3;
         --
         update conversao_unidade set fat_conv = nvl(est_conversao_unidade.fat_conv,0)
          where id = est_conversao_unidade.id;
         --
      else
         --
         vn_fase := 99.4;
         --
         insert into conversao_unidade ( id
                                       , item_id
                                       , unidade_id
                                       , fat_conv )
                                values ( convunid_seq.nextval
                                       , est_conversao_unidade.item_id
                                       , est_conversao_unidade.unidade_id
                                       , nvl(est_conversao_unidade.fat_conv,0) );
         --
      end if;
      --
   else
      --
      vn_fase := 99.5;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_conv_unid fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia
                                     , en_empresa_id      => en_empresa_id
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_conv_unid;

-------------------------------------------------------------------------------------------------------

--| Procedimento integra as informações dos Grupos de Patrimonio

procedure pkb_integr_grupo_pat ( est_log_generico   in out nocopy  dbms_sql.number_table
                               , est_grupo_pat      in out nocopy  grupo_pat%rowtype 
                               , en_loteintws_id    in             lote_int_ws.id%type default 0
                               , en_empresa_id      in             empresa.id%type
                               )
is
   --
   vn_fase               number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
   vv_nro_lote           varchar2(30) := null;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'GRUPO_PAT';
   --
   gv_cabec_log := 'Código do grupo: ' || est_grupo_pat.cd || ' Descrição: ' || est_grupo_pat.descr || vv_nro_lote;
   --
   est_grupo_pat.id := pk_csf.fkg_grupopat_id ( ev_cod_grupopat => est_grupo_pat.cd 
                                              , en_multorg_id   => est_grupo_pat.multorg_id );
   --
   vn_fase := 2;
   --
   if nvl(est_grupo_pat.id,0) <= 0 then
      --
      select grupopat_seq.nextval
        into est_grupo_pat.id
        from dual;
      --
   end if;
   -- Seta a referencia
   gn_referencia_id := est_grupo_pat.id;
   --
   if nvl(est_grupo_pat.multorg_id,0) <= 0 then
      --
      gv_mensagem_log := '"Mult-Organização" não informada.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => en_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2.4;
   --
   if not pk_csf.fkg_valida_multorg_id ( en_multorg_id => est_grupo_pat.multorg_id ) then
      --
      gv_mensagem_log := '"Mult-Organização" inválido ('|| est_grupo_pat.multorg_id || ').';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => en_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   if est_grupo_pat.cd is null then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := '"Código do grupo" não pode ser nulo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   --
   if est_grupo_pat.descr is null then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := '"Descrição do grupo" não pode ser nulo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   if nvl(est_log_generico.count,0) > 0 then
      est_grupo_pat.dm_st_proc := 2; -- Erro de validação
   else
      est_grupo_pat.dm_st_proc := 1; -- Validado
   end if;
   --
   vn_fase := 99;
   --
   if est_grupo_pat.cd is not null
      and est_grupo_pat.descr is not null 
      and nvl(est_grupo_pat.multorg_id,0) > 0 then
      --
      vn_fase := 99.1;
      --
      -- Calcula a quantidade de registros totais integrados para ser
      -- mostrado na tela de agendamento.
      --
      begin
         pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
      exception
         when others then
         null;
      end;
      --
      if pk_csf.fkg_existe_grupo_pat ( en_grupopat_id => est_grupo_pat.id ) = true then
         --
         vn_fase := 99.2;
         --
         update grupo_pat set cd          = trim(est_grupo_pat.cd)
                            , descr       = trim(est_grupo_pat.descr)
                            , multorg_id  = est_grupo_pat.multorg_id
                            , dm_st_proc  = est_grupo_pat.dm_st_proc
          where id = est_grupo_pat.id;
         --
      else
         --
         vn_fase := 99.3;
         --
         insert into grupo_pat ( id
                               , cd
                               , descr
                               , multorg_id
                               , dm_st_proc
                               )
                        values ( est_grupo_pat.id
                               , trim(est_grupo_pat.cd)
                               , trim(est_grupo_pat.descr)
                               , est_grupo_pat.multorg_id
                               , est_grupo_pat.dm_st_proc
                               );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_grupo_pat fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia 
                                     , en_empresa_id      => en_empresa_id
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_grupo_pat;

-------------------------------------------------------------------------------------------------------

--| Procedimento integra as informações dos Subgrupos do Patrimonio

procedure pkb_integr_subgrupo_pat ( est_log_generico   in out nocopy  dbms_sql.number_table
                                  , est_subgrupo_pat   in out nocopy  subgrupo_pat%rowtype
                                  , ev_cd_grupopat     in             grupo_pat.cd%type 
                                  , en_multorg_id      in             mult_org.id%type
                                  , en_loteintws_id    in             lote_int_ws.id%type default 0
                                  , en_empresa_id      in             empresa.id%type
                                  )
is
   --
   vn_fase               number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
   vv_nro_lote           varchar2(30) := null;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'GRUPO_PAT';
   --
   gv_cabec_log := 'Código do grupo: ' || ev_cd_grupopat || ' Código do subgrupo: ' || est_subgrupo_pat.cd || ' Descrição do subgrupo: ' || est_subgrupo_pat.descr || vv_nro_lote;
   --
   vn_fase := 2;
   --
   est_subgrupo_pat.grupopat_id := pk_csf.fkg_grupopat_id ( ev_cod_grupopat => ev_cd_grupopat
                                                          , en_multorg_id   => en_multorg_id );
   --
   if nvl(est_subgrupo_pat.grupopat_id,0) <= 0 then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := '"Código do grupo" (' || ev_cd_grupopat || ') está incorreto.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id 
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   est_subgrupo_pat.id := pk_csf.fkg_subgrupopat_id ( ev_cod_subgrupopat => est_subgrupo_pat.cd
                                                    , en_grupopat_id     => est_subgrupo_pat.grupopat_id );
   --
   vn_fase := 4;
   --
   if nvl(est_subgrupo_pat.id,0) <= 0 then
      --
      select subgrupopat_seq.nextval
        into est_subgrupo_pat.id
        from dual;
      --
   end if;
   -- Seta a referencia
   gn_referencia_id := est_subgrupo_pat.id;
   --
   vn_fase := 5;
   --
   if est_subgrupo_pat.cd is null then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := '"Código do subgrupo" não pode ser nulo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 6;
   --
   if est_subgrupo_pat.descr is null then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := '"Descrição do subgrupo" não pode ser nulo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 7;
   --
   est_subgrupo_pat.vida_util_fiscal := nvl(est_subgrupo_pat.vida_util_fiscal,0);
   --
   if est_subgrupo_pat.vida_util_fiscal < 0 then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := '"Vida útil fiscal em anos" (' || est_subgrupo_pat.vida_util_fiscal || ') não pode ser nagativo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 8;
   --
   est_subgrupo_pat.vida_util_real := nvl(est_subgrupo_pat.vida_util_real,0);
   --
   if est_subgrupo_pat.vida_util_real < 0 then
      --
      vn_fase := 8.1;
      --
      gv_mensagem_log := '"Vida útil real em anos" (' || est_subgrupo_pat.vida_util_real || ') não pode ser nagativo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 9;
   --
   if nvl(est_subgrupo_pat.dm_formacao,-1) not in (0,1) then
      --
      vn_fase := 9.1;
      --
      gv_mensagem_log := '"Sub-Grupo do Patrimonio em Formação" ('||est_subgrupo_pat.dm_formacao||') deve ser 0-Não ou 1-Sim.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 10;
   --
   if nvl(est_subgrupo_pat.dm_deprecia,-1) not in (0,1) then
      --
      vn_fase := 10.1;
      --
      gv_mensagem_log := 'Valor do campo "deprecia bem" ('||est_subgrupo_pat.dm_deprecia||') deve ser 1 - Sim ou 0 - Não.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 11;
   --
   if nvl(est_subgrupo_pat.dm_tipo_rec_pis,0) not in (1,2) then
      --
      vn_fase := 11.1;
      --
      gv_mensagem_log := '"Tipo da recuperação do PIS " ('||est_subgrupo_pat.dm_tipo_rec_pis||') deve ser 1-Valor de aquisição ou 2-Depreciação.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 12;
   --
   if nvl(est_subgrupo_pat.dm_tipo_rec_cofins,0) not in (1,2) then
      --
      vn_fase := 12.1;
      --
      gv_mensagem_log := '"Tipo da recuperação do COFINS " ('||est_subgrupo_pat.dm_tipo_rec_cofins||') deve ser 1-Valor de aquisição ou 2-Depreciação.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_subgrupo_pat.grupopat_id,0) > 0
      and est_subgrupo_pat.cd is not null
      and est_subgrupo_pat.descr is not null
      and est_subgrupo_pat.vida_util_fiscal >= 0
      and est_subgrupo_pat.vida_util_real >= 0
      and nvl(est_subgrupo_pat.dm_formacao,-1) in (0,1)
      and nvl(est_subgrupo_pat.dm_deprecia,-1) in (0,1)
      and nvl(est_subgrupo_pat.dm_tipo_rec_cofins,0) in (1,2) 
      and nvl(est_subgrupo_pat.dm_tipo_rec_cofins,0) in (1,2) then
      --
      vn_fase := 99.1;
      --
      if pk_csf.fkg_existe_subgrupo_pat ( en_subgrupopat_id => est_subgrupo_pat.id ) = true then
         --
         vn_fase := 99.2;
         --
         update subgrupo_pat set cd                     = trim(est_subgrupo_pat.cd)
                               , descr                  = trim(est_subgrupo_pat.descr)
                               , vida_util_fiscal       = est_subgrupo_pat.vida_util_fiscal
                               , vida_util_real         = est_subgrupo_pat.vida_util_real    
                               , dm_formacao            = est_subgrupo_pat.dm_formacao       
                               , dm_deprecia            = est_subgrupo_pat.dm_deprecia
                               , dm_tipo_rec_pis        = est_subgrupo_pat.dm_tipo_rec_pis   
                               , dm_tipo_rec_cofins     = est_subgrupo_pat.dm_tipo_rec_cofins
                               , cod_ccus               = est_subgrupo_pat.cod_ccus
          where id = est_subgrupo_pat.id;
         --
      else
         --
         vn_fase := 99.3;
         --
         insert into subgrupo_pat ( id
                                  , grupopat_id
                                  , cd
                                  , descr
                                  , vida_util_fiscal
                                  , vida_util_real    
                                  , dm_formacao
                                  , dm_deprecia
                                  , dm_tipo_rec_pis   
                                  , dm_tipo_rec_cofins
                                  , cod_ccus
                                  )
                           values ( est_subgrupo_pat.id
                                  , est_subgrupo_pat.grupopat_id
                                  , trim(est_subgrupo_pat.cd)
                                  , trim(est_subgrupo_pat.descr)
                                  , est_subgrupo_pat.vida_util_fiscal
                                  , est_subgrupo_pat.vida_util_real
                                  , est_subgrupo_pat.dm_formacao
                                  , est_subgrupo_pat.dm_deprecia
                                  , est_subgrupo_pat.dm_tipo_rec_pis
                                  , est_subgrupo_pat.dm_tipo_rec_cofins
                                  , est_subgrupo_pat.cod_ccus
                                 );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_subgrupo_pat fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia
                                     , en_empresa_id      => en_empresa_id
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_subgrupo_pat;

-------------------------------------------------------------------------------------------------------------

--| Procedimento integra as informações dos Impostos dos Subgrupos do Patrimonio

procedure pkb_integr_imp_subgrupo_pat ( est_log_generico          in out nocopy  dbms_sql.number_table
                                      , est_rec_imp_subgrupo_pat  in out nocopy  rec_imp_subgrupo_pat%rowtype
                                      , ev_cd_grupopat            in             grupo_pat.cd%type
                                      , ev_cd_subgrupopat         in             subgrupo_pat.cd%type
                                      , ev_cd_tipo_imp            in             tipo_imposto.cd%type 
                                      , en_multorg_id             in             mult_org.id%type 
                                      , en_loteintws_id           in             lote_int_ws.id%type default 0
                                      , en_empresa_id             in             empresa.id%type
                                      )
is
   --
   vn_fase               number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
   vn_grupopat_id        grupo_pat.id%type;
   vv_nro_lote           varchar2(30) := null;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'GRUPO_PAT';
   --
   gv_cabec_log := 'Código do grupo: ' || ev_cd_grupopat || ' Código do subgrupo: ' || ev_cd_subgrupopat || ' Codigo do Tipo de Imposto: ' || ev_cd_tipo_imp || vv_nro_lote;
   --
   vn_fase := 2;
   --
   vn_grupopat_id := pk_csf.fkg_grupopat_id ( ev_cod_grupopat => ev_cd_grupopat
                                            , en_multorg_id   => en_multorg_id );
   --
   vn_fase := 3;
   --
   est_rec_imp_subgrupo_pat.subgrupopat_id  := pk_csf.fkg_subgrupopat_id ( ev_cod_subgrupopat => ev_cd_subgrupopat
                                                                         , en_grupopat_id     => vn_grupopat_id );
   --
   if nvl(est_rec_imp_subgrupo_pat.subgrupopat_id,0) <= 0 then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := '"Código do grupo" (' || ev_cd_grupopat || ') e/ou do subgrupo (' || ev_cd_subgrupopat || ') está/estão incorreto(s).';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   --
   est_rec_imp_subgrupo_pat.tipoimp_id := pk_csf.fkg_Tipo_Imposto_id ( en_cd =>  ev_cd_tipo_imp );
   --
   if nvl(est_rec_imp_subgrupo_pat.tipoimp_id,0) <= 0 then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := '"Código do tipo de imposto" (' || ev_cd_tipo_imp || ') está incorreto.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   --
   est_rec_imp_subgrupo_pat.id := pk_csf.fkg_recimpsubgrupopat_id ( en_subgrupopat_id  =>  est_rec_imp_subgrupo_pat.subgrupopat_id
                                                                  , en_tipoimp_id      =>  est_rec_imp_subgrupo_pat.tipoimp_id );
   --
   vn_fase := 5.1;
   --
   if nvl(est_rec_imp_subgrupo_pat.id,0) <= 0 then
      --
      select recimpsubgrupopat_seq.nextval
        into est_rec_imp_subgrupo_pat.id
        from dual;
      --
   end if;
   -- Seta a referencia
   gn_referencia_id := est_rec_imp_subgrupo_pat.id;
   --
   vn_fase := 6;
   --
   est_rec_imp_subgrupo_pat.aliq := nvl(est_rec_imp_subgrupo_pat.aliq,0);
   --
   if est_rec_imp_subgrupo_pat.aliq < 0 then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := '"Aliquota de imposto" (' || est_rec_imp_subgrupo_pat.aliq || ') não pode ser negativa.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 7;
   --
   if nvl(est_rec_imp_subgrupo_pat.qtde_mes,0) <= 0 then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := '"Quantidade de meses a recuperar a partir da data de aquisição" (' || est_rec_imp_subgrupo_pat.qtde_mes || ') deve ser maior que zero.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia 
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_rec_imp_subgrupo_pat.subgrupopat_id,0) > 0
      and nvl(est_rec_imp_subgrupo_pat.tipoimp_id,0) > 0
      and est_rec_imp_subgrupo_pat.aliq >= 0
      and est_rec_imp_subgrupo_pat.qtde_mes > 0
      then
      --
      vn_fase := 99.1;
      --
      if pk_csf.fkg_existe_imp_subgrupo_pat ( en_recimpsubgrupo_id => est_rec_imp_subgrupo_pat.id ) = true then
         --
         vn_fase := 99.2;
         --
         update rec_imp_subgrupo_pat set aliq       = est_rec_imp_subgrupo_pat.aliq
                                       , qtde_mes   = est_rec_imp_subgrupo_pat.qtde_mes
          where id = est_rec_imp_subgrupo_pat.id;
         --
      else
         --
         vn_fase := 99.3;
         --
         insert into rec_imp_subgrupo_pat ( id
                                          , subgrupopat_id
                                          , aliq
                                          , qtde_mes
                                          , tipoimp_id
                                          )
                                   values ( est_rec_imp_subgrupo_pat.id
                                          , est_rec_imp_subgrupo_pat.subgrupopat_id
                                          , est_rec_imp_subgrupo_pat.aliq
                                          , est_rec_imp_subgrupo_pat.qtde_mes  
                                          , est_rec_imp_subgrupo_pat.tipoimp_id
                                          );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_imp_subgrupo_pat fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia
                                     , en_empresa_id      => en_empresa_id
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_imp_subgrupo_pat;

-------------------------------------------------------------------------------------------------------

-- Procedimento integra as informações do Bem do Ativo Imobilizado
procedure pkb_integr_bem_ativo_imob ( est_log_generico    in out nocopy  dbms_sql.number_table
                                    , est_bem_ativo_imob  in out nocopy  bem_ativo_imob%rowtype
                                    , en_multorg_id       in             mult_org.id%type
                                    , ev_cpf_cnpj         in             varchar2
                                    , ev_cod_prnc         in             bem_ativo_imob.cod_ind_bem%type 
                                    , en_loteintws_id     in             lote_int_ws.id%type default 0
                                    )
is
   --
   vn_fase               number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
   vv_nro_lote           varchar2(30) := null;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'BEM_ATIVO_IMOB';
   --
   vn_fase := 1.1;
   --
   if nvl(est_bem_ativo_imob.empresa_id,0) <= 0 then
      --
      est_bem_ativo_imob.empresa_id := pk_csf.fkg_empresa_id2 ( ev_cod_matriz        => null
                                                              , ev_cod_filial        => null
                                                              , ev_empresa_cpf_cnpj  => ev_cpf_cnpj
                                                              , en_multorg_id        => en_multorg_id
                                                              );
      --
   end if;
   --
   gv_cabec_log := 'Empresa: ' || pk_csf.fkg_nome_empresa ( en_empresa_id  => est_bem_ativo_imob.empresa_id) || vv_nro_lote;
   --
   gv_cabec_log := gv_cabec_log || chr(10);
   --
   gv_cabec_log := gv_cabec_log || trim(est_bem_ativo_imob.cod_ind_bem) || '-' || trim(pk_csf.fkg_converte(est_bem_ativo_imob.descr_item));
   --
   vn_fase := 2;
   --
   est_bem_ativo_imob.id := pk_csf.fkg_id_bem_ativo_imob ( en_empresa_id   => est_bem_ativo_imob.empresa_id
                                                         , ev_cod_ind_bem  => trim(est_bem_ativo_imob.cod_ind_bem) );
   --
   vn_fase := 2.1;
   --
   if nvl(est_bem_ativo_imob.id,0) <= 0 then
      --
      select bemativoimob_seq.nextval
        into est_bem_ativo_imob.id
        from dual;
      --
   end if;
   -- Seta a referencia
   gn_referencia_id := est_bem_ativo_imob.id;
   --
   delete from log_generico_cad
    where REFERENCIA_ID = gn_referencia_id
      and OBJ_REFERENCIA = gv_obj_referencia;
   --
   vn_fase := 3;
   --
   if trim(est_bem_ativo_imob.cod_ind_bem) is null then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := '"Código do Bem/Componente" ('||trim(est_bem_ativo_imob.cod_ind_bem)||') está inválido.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia 
                           , en_empresa_id         => est_bem_ativo_imob.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   --
   if trim(pk_csf.fkg_converte(est_bem_ativo_imob.descr_item)) is null then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := '"Descrição do Bem/Componente" ('||trim(pk_csf.fkg_converte(est_bem_ativo_imob.descr_item))||') está inválida.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_bem_ativo_imob.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   -- Identificação do tipo de mercadoria
   if nvl(est_bem_ativo_imob.dm_ident_merc, 0) not in (1, 2) then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := 'Código do Bem: '||trim(est_bem_ativo_imob.cod_ind_bem)||'-'||trim(pk_csf.fkg_converte(est_bem_ativo_imob.descr_item))||
                         '. "Identificação do tipo de mercadoria" ('||nvl(est_bem_ativo_imob.dm_ident_merc, 0)||') está inválida.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_bem_ativo_imob.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 6;
   --
   -- Código principal, quando o for componente
   est_bem_ativo_imob.ar_bemativoimob_id := pk_csf.fkg_id_bem_ativo_imob ( en_empresa_id   => est_bem_ativo_imob.empresa_id
                                                                         , ev_cod_ind_bem  => trim(ev_cod_prnc) );
   --
   if est_bem_ativo_imob.dm_ident_merc = 2
      and nvl(est_bem_ativo_imob.ar_bemativoimob_id,0) <= 0 then
      --
      vn_fase := 6.2;
      --
      gv_mensagem_log := 'Código do Bem: '||trim(est_bem_ativo_imob.cod_ind_bem)||'-'||trim(pk_csf.fkg_converte(est_bem_ativo_imob.descr_item))||
                         '. "Código Principal do Componente" (' || ev_cod_prnc || ') está inválido.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_bem_ativo_imob.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 7;
   -- Código da Conta Analitica
   if trim(est_bem_ativo_imob.cod_cta) is null then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := 'Código do Bem: '||trim(est_bem_ativo_imob.cod_ind_bem)||'-'||trim(pk_csf.fkg_converte(est_bem_ativo_imob.descr_item))||
                         '. "Código da Conta Contábil Analítica" (' || trim(est_bem_ativo_imob.cod_cta) || ') está inválido.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_bem_ativo_imob.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 8;
   -- Número total de parcelas a serem apropriadas
   if nvl(est_bem_ativo_imob.nr_parc,0) <= 0 then
      --
      vn_fase := 8.1;
      --
      gv_mensagem_log := 'Código do Bem: '||trim(est_bem_ativo_imob.cod_ind_bem)||'-'||trim(pk_csf.fkg_converte(est_bem_ativo_imob.descr_item))||
                         '. "Número total de parcelas a serem apropriadas" ('||nvl(est_bem_ativo_imob.nr_parc,0)||') não pode ser zero ou negativo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_bem_ativo_imob.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 9;
   --
   if nvl(est_log_generico.count,0) > 0 then
      est_bem_ativo_imob.dm_st_proc := 2; -- Erro Validação
   else
      est_bem_ativo_imob.dm_st_proc := 1; -- Validado
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_bem_ativo_imob.empresa_id,0) > 0
      and trim(est_bem_ativo_imob.cod_ind_bem) is not null
      and nvl(est_bem_ativo_imob.dm_ident_merc,0) in (1, 2)
      and trim(pk_csf.fkg_converte(est_bem_ativo_imob.descr_item)) is not null
      and trim(est_bem_ativo_imob.cod_cta) is not null
      and nvl(est_bem_ativo_imob.nr_parc, 0) > 0 then
      --
      vn_fase := 99.1;
      --
      -- Calcula a quantidade de registros totais integrados para ser
      -- mostrado na tela de agendamento.
      --
      begin
         pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
      exception
         when others then
         null;
      end;
      --
      if pk_csf.fkg_existe_bem_ativo_imob ( en_bemativoimob_id => est_bem_ativo_imob.id ) = true then
         --
         vn_fase := 99.2;
         --
         update bem_ativo_imob set cod_ind_bem         = trim(est_bem_ativo_imob.cod_ind_bem)
                                 , dm_ident_merc       = est_bem_ativo_imob.dm_ident_merc
                                 , descr_item          = trim(pk_csf.fkg_converte(est_bem_ativo_imob.descr_item))
                                 , ar_bemativoimob_id  = est_bem_ativo_imob.ar_bemativoimob_id
                                 , cod_cta             = trim(est_bem_ativo_imob.cod_cta)
                                 , nr_parc             = est_bem_ativo_imob.nr_parc
                                 , dm_st_proc          = est_bem_ativo_imob.dm_st_proc
          where id = est_bem_ativo_imob.id;
         --
      else
         --
         vn_fase := 99.3;
         --
         insert into bem_ativo_imob ( id
                                    , empresa_id
                                    , cod_ind_bem
                                    , dm_ident_merc
                                    , descr_item
                                    , ar_bemativoimob_id
                                    , cod_cta
                                    , nr_parc 
                                    , dm_st_proc 
                                    )
                             values 
                                    ( est_bem_ativo_imob.id
                                    , est_bem_ativo_imob.empresa_id
                                    , trim(est_bem_ativo_imob.cod_ind_bem)
                                    , est_bem_ativo_imob.dm_ident_merc
                                    , trim(pk_csf.fkg_converte(est_bem_ativo_imob.descr_item))
                                    , est_bem_ativo_imob.ar_bemativoimob_id
                                    , trim(est_bem_ativo_imob.cod_cta)
                                    , est_bem_ativo_imob.nr_parc
                                    , est_bem_ativo_imob.dm_st_proc
                                    );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_bem_ativo_imob fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_SISTEMA
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => est_bem_ativo_imob.empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_bem_ativo_imob;

-------------------------------------------------------------------------------------------------------

-- Procedimento integra os dados de Informações de Utilização do Bem
procedure pkb_integr_infor_util_bem ( est_log_generico    in out nocopy  dbms_sql.number_table
                                    , est_infor_util_bem  in out nocopy  infor_util_bem%rowtype
                                    , en_multorg_id       in             mult_org.id%type
                                    , ev_cpf_cnpj         in             varchar2
                                    , ev_cod_ind_bem      in             bem_ativo_imob.cod_ind_bem%type 
                                    )
is
   --
   vn_fase            number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
   vn_empresa_id      empresa.id%type := null;
   --
begin
   --
   vn_fase := 1;
   --
   gv_obj_referencia := 'BEM_ATIVO_IMOB';
   --
   vn_empresa_id := pk_csf.fkg_empresa_id2 ( ev_cod_matriz        => null
                                           , ev_cod_filial        => null
                                           , ev_empresa_cpf_cnpj  => ev_cpf_cnpj
                                           , en_multorg_id        => en_multorg_id
                                           );
   --
   vn_fase := 1.1;
   --
   est_infor_util_bem.bemativoimob_id := pk_csf.fkg_id_bem_ativo_imob ( en_empresa_id   => vn_empresa_id
                                                                      , ev_cod_ind_bem  => trim(ev_cod_ind_bem) );
   --
   gn_referencia_id := est_infor_util_bem.bemativoimob_id;
   --
   vn_fase := 4;
   -- Código do centro de custo
   if trim(est_infor_util_bem.cod_ccus) is null then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := 'Código do Bem: '||trim(ev_cod_ind_bem)||'. "Centro de Custo" não informado.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   -- Vida útil estimada do bem
   if nvl(est_infor_util_bem.vida_util, 0) < 0 then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := 'Código do Bem: '||trim(ev_cod_ind_bem)||'. "Vida Útil" ('||nvl(est_infor_util_bem.vida_util,0)||') não pode ser zero ou negativa.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia 
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 6;
   --
   if trim(pk_csf.fkg_converte(est_infor_util_bem.func)) is null then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := 'Código do Bem: '||trim(ev_cod_ind_bem)||'. "Descrição sucinta da função do bem na atividade do estabelecimento" não informada.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem        => gv_cabec_log
                           , ev_resumo          => gv_mensagem_log
                           , en_tipo_log        => ERRO_DE_VALIDACAO
                           , en_referencia_id   => gn_referencia_id
                           , ev_obj_referencia  => gv_obj_referencia 
                           , en_empresa_id      => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_infor_util_bem.bemativoimob_id,0) > 0
      and trim(est_infor_util_bem.cod_ccus) is not null
      and trim(pk_csf.fkg_converte(est_infor_util_bem.func)) is not null
      then
      --
      vn_fase := 99.1;
      --
      est_infor_util_bem.id := pk_csf.fkg_id_infor_util_bem ( en_bemativoimob_id => est_infor_util_bem.bemativoimob_id
                                                            , ev_cod_ccus        => trim(est_infor_util_bem.cod_ccus) );
      --
      vn_fase := 99.2;
      --
      if nvl(est_infor_util_bem.id,0) > 0 then
         --
         vn_fase := 99.3;
         --
         update infor_util_bem set vida_util = nvl(est_infor_util_bem.vida_util,0)
                                 , func = substr(trim(pk_csf.fkg_converte(est_infor_util_bem.func)),1,255)
          where id = est_infor_util_bem.id;
         --
      else
         --
         vn_fase := 99.4;
         --
         insert into infor_util_bem ( id
                                    , bemativoimob_id
                                    , cod_ccus
                                    , vida_util
                                    , func
                                    )
                             values ( inforutilbem_seq.nextval
                                    , est_infor_util_bem.bemativoimob_id
                                    , trim(est_infor_util_bem.cod_ccus)
                                    , est_infor_util_bem.vida_util
                                    , substr(trim(pk_csf.fkg_converte(est_infor_util_bem.func)),1,255)
                                    );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_infor_util_bem fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_SISTEMA
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => vn_empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_infor_util_bem;

-------------------------------------------------------------------------------------------------------

-- Procedimento que verifica se existe os dados de "Informações de Utilização do Bem" e caso não exista,
-- recupera a partir do SUB-GRUPO.

procedure pkb_rec_infor_util_bem ( en_bemativoimob_id in bem_ativo_imob.id%type
                                 , en_multorg_id      in mult_org.id%type
                                 , ev_cpf_cnpj        in varchar2
                                 , ev_cod_ind_bem     in bem_ativo_imob.cod_ind_bem%type
                                 )
is
   --
   vn_fase            number := 0;
   vt_log_generico    dbms_sql.number_table;
   vn_empresa_id      empresa.id%type;
   --
   vn_inforutilbem_id number := 0;
   --
   cursor c_recup_subgrupo is
      select s.vida_util_fiscal    VIDA_UTIL
           , s.cod_ccus            COD_CCUS
           , s.descr               FUNC_1
           , g.descr               FUNC_2
        from subgrupo_pat s
           , grupo_pat g
           , bem_ativo_imob b
       where s.id = b.subgrupopat_id
         and s.grupopat_id = g.id
         and b.id = en_bemativoimob_id;
   --
begin
   --
   vn_fase := 1;
   --
   gv_obj_referencia := 'BEM_ATIVO_IMOB';
   --
   gn_referencia_id := en_bemativoimob_id;
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id  => en_multorg_id
                                                        , ev_cpf_cnpj    => ev_cpf_cnpj );
   --
   begin
      --
      select nvl(max(id),0)
        into vn_inforutilbem_id
        from infor_util_bem i
       where i.bemativoimob_id = en_bemativoimob_id;
      --
   exception
      when others then
         --
         vn_fase := 3;
         --
         vn_inforutilbem_id := 1;
         --
         gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_rec_infor_util_bem fase(' || vn_fase || '): ' || sqlerrm;
         --
         declare
            vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
         begin
            --
            pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                 , ev_mensagem        => gv_mensagem_log
                                 , ev_resumo          => gv_mensagem_log
                                 , en_tipo_log        => ERRO_DE_SISTEMA
                                 , en_referencia_id   => gn_referencia_id
                                 , ev_obj_referencia  => gv_obj_referencia
                                 , en_empresa_id      => vn_empresa_id
                                 );
            --
         exception
            when others then
               null;
         end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
   end;
   --
   vn_fase := 4;
   --
   if vn_inforutilbem_id = 0 then
      --
      vn_fase := 5;
      --
      for rec in c_recup_subgrupo loop
         exit when c_recup_subgrupo%notfound or (c_recup_subgrupo%notfound) is null;
         --
         vn_fase := 6;
         --
         vt_Log_Generico.delete;
         --
         pk_csf_api_cad.gt_row_infor_util_bem := null;
         --
         pk_csf_api_cad.gt_row_infor_util_bem.bemativoimob_id := en_bemativoimob_id;
         pk_csf_api_cad.gt_row_infor_util_bem.cod_ccus        := rec.COD_CCUS;
         pk_csf_api_cad.gt_row_infor_util_bem.func            := rec.FUNC_1 || ' - ' || rec.FUNC_2;
         pk_csf_api_cad.gt_row_infor_util_bem.vida_util       := rec.VIDA_UTIL;
         --
         vn_fase := 7;
         --
         pkb_integr_infor_util_bem ( est_log_generico    => vt_log_generico
                                   , est_infor_util_bem  => pk_csf_api_cad.gt_row_infor_util_bem
                                   , en_multorg_id       => en_multorg_id
                                   , ev_cpf_cnpj         => ev_cpf_cnpj
                                   , ev_cod_ind_bem      => ev_cod_ind_bem
                                   );
        --
        vn_fase := 8;
        --
        commit;
        --
      end loop;
      --
      vn_fase := 9;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_rec_infor_util_bem fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem        => gv_mensagem_log
                              , ev_resumo          => gv_mensagem_log
                              , en_tipo_log        => ERRO_DE_SISTEMA
                              , en_referencia_id   => gn_referencia_id
                              , ev_obj_referencia  => gv_obj_referencia
                              , en_empresa_id      => vn_empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_rec_infor_util_bem;

-------------------------------------------------------------------------------------------------------

-- Procedimento integra as informações complementares do Bem do Ativo Imobilizado
procedure pkb_integr_bem_ativo_imob_comp ( est_log_generico         in out nocopy  dbms_sql.number_table
                                         , est_bem_ativo_imob_comp  in out nocopy  bem_ativo_imob%rowtype
                                         , en_bemativoimob_id       in             bem_ativo_imob.id%type
                                         , en_multorg_id            in             mult_org.id%type
                                         , ev_cpf_cnpj              in             varchar2
                                         , ev_cod_item              in             item.cod_item%type
                                         , ev_cod_subgrupopat       in             subgrupo_pat.cd%type
                                         , ev_cod_grupopat          in             grupo_pat.cd%type
                                         , en_loteintws_id          in             lote_int_ws.id%type default 0
                                         )
is
   --
   vn_fase                number := 0;
   vn_loggenericocad_id   Log_Generico_Cad.id%TYPE;
   vn_grupopat_id         number := 0;
   vv_nro_lote            varchar2(30) := null;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'BEM_ATIVO_IMOB';
   --
   gn_referencia_id := en_bemativoimob_id;
   --
   vn_fase := 1.1;
   --
   gv_cabec_log := 'Empresa: ' || ev_cpf_cnpj || ' Código do Bem/Componente: ' || trim(est_bem_ativo_imob_comp.cod_ind_bem) || vv_nro_lote;
   --
   vn_fase := 2;
   --
   est_bem_ativo_imob_comp.empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id  => en_multorg_id
                                                                             , ev_cpf_cnpj    => ev_cpf_cnpj
                                                                             );
   --
   if nvl(est_bem_ativo_imob_comp.empresa_id,0) <= 0 then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := '"Empresa" ('||ev_cpf_cnpj||') não encontrada.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_bem_ativo_imob_comp.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   est_bem_ativo_imob_comp.item_id := pk_csf.fkg_Item_id_conf_empr ( en_empresa_id => est_bem_ativo_imob_comp.empresa_id
                                                                   , ev_cod_item   => ev_cod_item );

   --
   vn_fase := 2.2;
   --
   if nvl(est_bem_ativo_imob_comp.item_id,0) <= 0 then
      --
      vn_fase := 2.3;
      --
      gv_mensagem_log := '"Código do item" ('||ev_cod_item||') está inválido.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_bem_ativo_imob_comp.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   if ev_cod_grupopat is not null then
      --
      vn_grupopat_id := pk_csf.fkg_grupopat_id ( ev_cod_grupopat =>  ev_cod_grupopat
                                               , en_multorg_id   =>  en_multorg_id );
      --
      if nvl(vn_grupopat_id,0) <= 0 then
         --
         vn_fase := 3.1;
         --
         gv_mensagem_log := '"Código do Grupo do Patrimonio" ('||ev_cod_grupopat||') está inválido.';
         --
         vn_loggenericocad_id := null;
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_VALIDACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => est_bem_ativo_imob_comp.empresa_id
                              );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                 , est_log_generico  => est_log_generico );
         --
      end if;
      --
   end if;
   --
   vn_fase := 4;
   --
   if ev_cod_subgrupopat is not null then
      --
      est_bem_ativo_imob_comp.subgrupopat_id  := pk_csf.fkg_subgrupopat_id ( ev_cod_subgrupopat => ev_cod_subgrupopat
                                                                           , en_grupopat_id     => vn_grupopat_id );
      --
      if nvl(est_bem_ativo_imob_comp.subgrupopat_id,0) <= 0 then
         --
         vn_fase := 4.1;
         --
         gv_mensagem_log := 'Não existe o subgrupo de código ('||ev_cod_subgrupopat||') para o grupo de código ('||ev_cod_grupopat||').';
         --
         vn_loggenericocad_id := null;
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_VALIDACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => est_bem_ativo_imob_comp.empresa_id
                              );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                 , est_log_generico  => est_log_generico );
         --
      end if;
      --
   end if;
   --
   vn_fase := 5;
   --
   if nvl(est_bem_ativo_imob_comp.vida_util_fiscal,0) < 0 then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := '"Vida útil fiscal" ('||est_bem_ativo_imob_comp.vida_util_fiscal||') não pode ser negativa.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_bem_ativo_imob_comp.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 6;
   --
   if nvl(est_bem_ativo_imob_comp.vida_util_real,0) < 0 then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := '"Vida útil real" ('||est_bem_ativo_imob_comp.vida_util_real||') não pode ser negativa.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_bem_ativo_imob_comp.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 7;
   --
   if est_bem_ativo_imob_comp.dt_aquis is not null 
   and est_bem_ativo_imob_comp.dt_aquis > sysdate then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := '"Data de aquisição do bem" ('||est_bem_ativo_imob_comp.dt_aquis||') não pode ser maior que a data atual.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_bem_ativo_imob_comp.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 8;
   --
   if nvl(est_bem_ativo_imob_comp.vl_aquis,0) < 0 then
      --
      vn_fase := 8.1;
      --
      gv_mensagem_log := '"Valor de aquisição do bem" ('||est_bem_ativo_imob_comp.vl_aquis||') não pode ser negativo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_bem_ativo_imob_comp.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 9;
   --
   if est_bem_ativo_imob_comp.dt_ini_form is not null
   and est_bem_ativo_imob_comp.dt_ini_form > est_bem_ativo_imob_comp.dt_fin_form then
      --
      vn_fase := 9.1;
      --
      gv_mensagem_log := '"Data de inicio da formação do bem" ('||est_bem_ativo_imob_comp.dt_ini_form||') não pode ser maior que a "Data final da formação do bem" ('||est_bem_ativo_imob_comp.dt_fin_form||').';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_bem_ativo_imob_comp.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 9;
   --
   if est_bem_ativo_imob_comp.dt_fin_form is not null
   and est_bem_ativo_imob_comp.dt_fin_form < est_bem_ativo_imob_comp.dt_ini_form then
      --
      vn_fase := 9.1;
      --
      gv_mensagem_log := '"Data final da formação do bem" ('||est_bem_ativo_imob_comp.dt_fin_form||') não pode ser menor que a "Data de inicio da formação do bem" ('||est_bem_ativo_imob_comp.dt_ini_form||').';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_bem_ativo_imob_comp.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 10;
   --
   if nvl(est_bem_ativo_imob_comp.dm_deprecia,0) not in (0,1) then
      --
      vn_fase := 10.1;
      --
      gv_mensagem_log := 'Valor do campo "deprecia bem" ('||est_bem_ativo_imob_comp.dm_deprecia||') deve ser 1 - Sim ou 0 Não.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem        => gv_cabec_log
                           , ev_resumo          => gv_mensagem_log
                           , en_tipo_log        => ERRO_DE_VALIDACAO
                           , en_referencia_id   => gn_referencia_id
                           , ev_obj_referencia  => gv_obj_referencia 
                           , en_empresa_id      => est_bem_ativo_imob_comp.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 10;
   --
   if nvl(est_bem_ativo_imob_comp.dm_situacao,1) not in (1,2,3,4,5) then
      --
      vn_fase := 10.1;
      --
      gv_mensagem_log := '"Situação do bem" ('||est_bem_ativo_imob_comp.dm_situacao||') deve ser 1-Em Formação; 2-Em Uso; 3-Baixado; 4-Em Manutenção; 5-Emprestado.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_bem_ativo_imob_comp.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 11;
   --
   if nvl(est_bem_ativo_imob_comp.dm_tipo_rec_pis,0) not in (1,2) then
      --
      vn_fase := 11.1;
      --
      gv_mensagem_log := '"Tipo da recuperação do PIS " ('||est_bem_ativo_imob_comp.dm_tipo_rec_pis||') deve ser 1-Valor de aquisição ou 2-Depreciação.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_bem_ativo_imob_comp.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 12;
   --
   if nvl(est_bem_ativo_imob_comp.dm_tipo_rec_cofins,0) not in (1,2) then
      --
      vn_fase := 12.1;
      --
      gv_mensagem_log := '"Tipo da recuperação do COFINS " ('||est_bem_ativo_imob_comp.dm_tipo_rec_cofins||') deve ser 1-Valor de aquisição ou 2-Depreciação.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_bem_ativo_imob_comp.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 13;
   --
   if est_bem_ativo_imob_comp.dm_tipo_rec_pis in (1,2)
   and est_bem_ativo_imob_comp.dm_tipo_rec_cofins in (1,2)
   then
      --
      update bem_ativo_imob set item_id             =   est_bem_ativo_imob_comp.item_id
                              , subgrupopat_id      =   est_bem_ativo_imob_comp.subgrupopat_id
                              , vida_util_fiscal    =   est_bem_ativo_imob_comp.vida_util_fiscal
                              , vida_util_real      =   est_bem_ativo_imob_comp.vida_util_real
                              , dt_aquis            =   est_bem_ativo_imob_comp.dt_aquis
                              , vl_aquis            =   est_bem_ativo_imob_comp.vl_aquis
                              , dt_ini_form         =   est_bem_ativo_imob_comp.dt_ini_form
                              , dt_fin_form         =   est_bem_ativo_imob_comp.dt_fin_form
                              , dm_deprecia         =   est_bem_ativo_imob_comp.dm_deprecia
                              , dm_situacao         =   est_bem_ativo_imob_comp.dm_situacao
                              , dm_tipo_rec_pis     =   est_bem_ativo_imob_comp.dm_tipo_rec_pis
                              , dm_tipo_rec_cofins  =   est_bem_ativo_imob_comp.dm_tipo_rec_cofins
             where id = en_bemativoimob_id;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_bem_ativo_imob_comp fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_SISTEMA
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => est_bem_ativo_imob_comp.empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_bem_ativo_imob_comp;

-------------------------------------------------------------------------------------------------------

--| Procedimento integra as informações dos Documentos Fiscais do Bem do Ativo Imobilizado

procedure pkb_integr_nf_bem_ativo_imob ( est_log_generico        in out nocopy  dbms_sql.number_table
                                       , est_nf_bem_ativo_imob   in out nocopy  nf_bem_ativo_imob%rowtype
                                       , en_multorg_id           in             mult_org.id%type
                                       , ev_cpf_cnpj             in             varchar2
                                       , ev_cod_ind_bem          in             bem_ativo_imob.cod_ind_bem%type
                                       , ev_cod_part             in             pessoa.cod_part%type
                                       , ev_cod_mod              in             mod_fiscal.cod_mod%type 
                                       , en_loteintws_id         in             lote_int_ws.id%type default 0
                                       )
is
   --
   vn_fase               number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
   vn_empresa_id         number := 0;
   vv_nro_lote           varchar2(30) := null;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'BEM_ATIVO_IMOB';
   --
   vn_fase := 1.1;
   --
   gv_cabec_log := 'Empresa: ' || ev_cpf_cnpj || ' Código do Bem/Componente: ' || ev_cod_ind_bem || ' Indicador do emitente: ' || est_nf_bem_ativo_imob.dm_ind_emit;
   gv_cabec_log := gv_cabec_log || ' Código do participante: ' || ev_cod_part || ' Código do modelo: ' || ev_cod_mod || ' Série: ' || est_nf_bem_ativo_imob.serie;
   gv_cabec_log := gv_cabec_log || ' Número do documento: ' || est_nf_bem_ativo_imob.num_doc || vv_nro_lote;
   --
   vn_fase := 2;
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id  => en_multorg_id
                                                        , ev_cpf_cnpj    => ev_cpf_cnpj
                                                        );
   --
   vn_fase := 3;
   --
   est_nf_bem_ativo_imob.bemativoimob_id := pk_csf.fkg_id_bem_ativo_imob ( en_empresa_id  => vn_empresa_id
                                                                         , ev_cod_ind_bem => ev_cod_ind_bem );
   --
   gn_referencia_id  := est_nf_bem_ativo_imob.bemativoimob_id;
   --
   if nvl(vn_empresa_id,0) <= 0 then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := '"Empresa" ('||ev_cpf_cnpj||') não encontrada.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3.1;
   --
   if nvl(est_nf_bem_ativo_imob.bemativoimob_id,0) <= 0 then
      --
      vn_fase := 3.2;
      --
      gv_mensagem_log := '"Código do Bem/Componente:" ('||ev_cod_ind_bem||') não existe para a empresa (' || ev_cpf_cnpj || ').';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   --
   est_nf_bem_ativo_imob.pessoa_id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id => en_multorg_id
                                                                    , ev_cod_part => ev_cod_part 
                                                                    );
   --
   vn_fase := 4.1;
   --
   if nvl(est_nf_bem_ativo_imob.pessoa_id,0) <= 0 then
      --
      vn_fase := 4.2;
      --
      gv_mensagem_log := '"Código do participante" ('||ev_cod_part||') está incorreto.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   --
   est_nf_bem_ativo_imob.modfiscal_id := pk_csf.fkg_Mod_Fiscal_id ( ev_cod_mod => ev_cod_mod );
   --
   vn_fase := 5.1;
   --
   if nvl(est_nf_bem_ativo_imob.modfiscal_id,0) <= 0 then
      --
      vn_fase := 5.2;
      --
      gv_mensagem_log := '"Código do modelo" ('||ev_cod_mod||') está incorreto.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 6;
   --
   est_nf_bem_ativo_imob.id := pk_csf.fkg_nfbemativoimob_id ( en_bemativoimob_id =>  est_nf_bem_ativo_imob.bemativoimob_id
                                                            , en_dm_ind_emit     =>  est_nf_bem_ativo_imob.dm_ind_emit
                                                            , en_pessoa_id       =>  est_nf_bem_ativo_imob.pessoa_id
                                                            , en_modfiscal_id    =>  est_nf_bem_ativo_imob.modfiscal_id
                                                            , ev_serie           =>  est_nf_bem_ativo_imob.serie
                                                            , ev_num_doc         =>  est_nf_bem_ativo_imob.num_doc );
   --
   vn_fase := 6.1;
   --
   if nvl(est_nf_bem_ativo_imob.id,0) <= 0 then
      --
      select nfbemativoimob_seq.nextval
        into est_nf_bem_ativo_imob.id
        from dual;
      --
   end if;
   -- Seta a referencia
   gn_referencia_id := est_nf_bem_ativo_imob.id;
   --
   vn_fase := 7;
   --
   if nvl(est_nf_bem_ativo_imob.dm_ind_emit,-1) not in (0, 1) then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := '"Indicador do emitente" (' || est_nf_bem_ativo_imob.dm_ind_emit || ') está incorreto, deve ser 0 - Emissão própria ou 1 - Terceiros.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 8;
   --
   if est_nf_bem_ativo_imob.num_doc is null then
      --
      vn_fase := 8.1;
      --
      gv_mensagem_log := '"Número do documento" não pode ser nulo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 9;
   --
   if est_nf_bem_ativo_imob.dt_doc is null then
      --
      vn_fase := 8.1;
      --
      gv_mensagem_log := '"Data do documento" não pode ser nula.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia 
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_nf_bem_ativo_imob.bemativoimob_id,0) > 0
      and nvl(est_nf_bem_ativo_imob.pessoa_id,0) > 0
      and nvl(est_nf_bem_ativo_imob.modfiscal_id,0) > 0
      and est_nf_bem_ativo_imob.dm_ind_emit in (0,1)
      and est_nf_bem_ativo_imob.num_doc is not null
      and est_nf_bem_ativo_imob.dt_doc is not null
      then
      --
      vn_fase := 99.1;
      --
      if pk_csf.fkg_existe_nf_bem_ativo_imob( en_nfbemativoimob_id => est_nf_bem_ativo_imob.id ) = true then
         --
         vn_fase := 99.2;
         --
         update nf_bem_ativo_imob set chv_nfe_cte = est_nf_bem_ativo_imob.chv_nfe_cte
                                    , dt_doc      = est_nf_bem_ativo_imob.dt_doc
                where id = est_nf_bem_ativo_imob.id;
         --
      else
         --
         vn_fase := 99.3;
         --
         insert into nf_bem_ativo_imob ( id
                                       , bemativoimob_id
                                       , dm_ind_emit    
                                       , pessoa_id      
                                       , modfiscal_id   
                                       , serie          
                                       , num_doc        
                                       , chv_nfe_cte    
                                       , dt_doc
                                       )
                                values ( est_nf_bem_ativo_imob.id
                                       , est_nf_bem_ativo_imob.bemativoimob_id
                                       , est_nf_bem_ativo_imob.dm_ind_emit
                                       , est_nf_bem_ativo_imob.pessoa_id      
                                       , est_nf_bem_ativo_imob.modfiscal_id   
                                       , est_nf_bem_ativo_imob.serie
                                       , est_nf_bem_ativo_imob.num_doc
                                       , est_nf_bem_ativo_imob.chv_nfe_cte
                                       , est_nf_bem_ativo_imob.dt_doc
                                       );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_nf_bem_ativo_imob fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_SISTEMA
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => vn_empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_nf_bem_ativo_imob;

-------------------------------------------------------------------------------------------------------

--| Procedimento integra as informações dos Itens dos Documentos Fiscais do Bem do Ativo Imobilizado

procedure pkb_integr_itnf_bem_ativo_imob ( est_log_generico        in out nocopy  dbms_sql.number_table
                                         , est_itnf_bem_ativo_imob in out nocopy  itnf_bem_ativo_imob%rowtype
                                         , en_multorg_id           in             mult_org.id%type
                                         , ev_cpf_cnpj             in             varchar2
                                         , ev_cod_ind_bem          in             bem_ativo_imob.cod_ind_bem%type
                                         , en_dm_ind_emit          in             nf_bem_ativo_imob.dm_ind_emit%type
                                         , ev_cod_part             in             pessoa.cod_part%type
                                         , ev_cod_mod              in             mod_fiscal.cod_mod%type 
                                         , ev_serie                in             nf_bem_ativo_imob.serie%type
                                         , en_num_doc              in             nf_bem_ativo_imob.num_doc%type
                                         , ev_cod_item             in             item.cod_item%type 
                                         , en_loteintws_id         in             lote_int_ws.id%type default 0
                                         , ev_valor                in             number                              
                                         )
is
   --
   vn_fase                number := 0;
   vn_loggenericocad_id   Log_Generico_Cad.id%TYPE;
   vn_empresa_id          number := 0;
   vn_bemativoimob_id     number := 0;
   vn_pessoa_id           number := 0;
   vn_modfiscal_id        number := 0;
   vv_nro_lote            varchar2(30) := null;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'BEM_ATIVO_IMOB';
   --
   vn_fase := 1.1;
   --
   gv_cabec_log := 'Empresa: ' || ev_cpf_cnpj || ' Código do Bem/Componente: ' || ev_cod_ind_bem || ' Indicador do emitente: ' || en_dm_ind_emit;
   gv_cabec_log := gv_cabec_log || ' Código do participante: ' || ev_cod_part || ' Código do modelo: ' || ev_cod_mod || ' Série: ' || ev_serie;
   gv_cabec_log := gv_cabec_log || ' Número do documento: ' || en_num_doc || ' Código do item: ' || ev_cod_item || vv_nro_lote;
   --
   vn_fase := 2;
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id  => en_multorg_id
                                                        , ev_cpf_cnpj    => ev_cpf_cnpj
                                                        );
   --
   vn_bemativoimob_id := pk_csf.fkg_id_bem_ativo_imob ( en_empresa_id  => vn_empresa_id
                                                      , ev_cod_ind_bem => ev_cod_ind_bem );

   --
   gn_referencia_id := vn_bemativoimob_id;
   --
   vn_fase := 3.1;
   --
   if nvl(vn_empresa_id,0) <= 0 then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := '"Empresa" ('||ev_cpf_cnpj||') não encontrada.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   if nvl(vn_bemativoimob_id,0) <= 0 then
      --
      vn_fase := 3.2;
      --
      gv_mensagem_log := '"Código do Bem/Componente:" ('||ev_cod_ind_bem||') não existe para a empresa (' || ev_cpf_cnpj || ').';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   --
   vn_pessoa_id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id => en_multorg_id
                                                 , ev_cod_part => ev_cod_part 
                                                 );
   --
   vn_fase := 4.1;
   --
   if nvl(vn_pessoa_id,0) <= 0 then
      --
      vn_fase := 4.2;
      --
      gv_mensagem_log := '"Código do participante" ('||ev_cod_part||') está incorreto.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   --
   vn_modfiscal_id := pk_csf.fkg_Mod_Fiscal_id ( ev_cod_mod => ev_cod_mod );
   --
   vn_fase := 5.1;
   --
   if nvl(vn_modfiscal_id,0) <= 0 then
      --
      vn_fase := 5.2;
      --
      gv_mensagem_log := '"Código do modelo" ('||ev_cod_mod||') está incorreto.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 6;
   --
   if nvl(en_dm_ind_emit,-1) not in (0, 1) then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := '"Indicador do emitente" (' || en_dm_ind_emit || ') está incorreto, deve ser 0 - Emissão própria ou 1 - Terceiros.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 7;
   --
   if en_num_doc is null then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := '"Número do documento" não pode ser nulo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 8;
   --
   est_itnf_bem_ativo_imob.nfbemativoimob_id := pk_csf.fkg_nfbemativoimob_id ( en_bemativoimob_id =>  vn_bemativoimob_id
                                                                             , en_dm_ind_emit     =>  en_dm_ind_emit
                                                                             , en_pessoa_id       =>  vn_pessoa_id
                                                                             , en_modfiscal_id    =>  vn_modfiscal_id
                                                                             , ev_serie           =>  ev_serie
                                                                             , ev_num_doc         =>  en_num_doc );
   --
   vn_fase := 9;
   --
   if est_itnf_bem_ativo_imob.num_item is null then
      --
      vn_fase := 9.1;
      --
      gv_mensagem_log := '"Número do item" não pode ser nulo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 10;
   --
   est_itnf_bem_ativo_imob.id := pk_csf.fkg_itnfbemativoimob_id ( en_nfbemativoimob_id => est_itnf_bem_ativo_imob.nfbemativoimob_id
                                                                , en_num_item          => est_itnf_bem_ativo_imob.num_item );
   --
   vn_fase := 10.1;
   --
   if nvl(est_itnf_bem_ativo_imob.id,0) <= 0 then
      --
      select itnfbemativoimob_seq.nextval
        into est_itnf_bem_ativo_imob.id
        from dual;
      --
   end if;
   -- Seta a referencia
   gn_referencia_id := est_itnf_bem_ativo_imob.id;
   --
   vn_fase := 11;
   --
   est_itnf_bem_ativo_imob.item_id := pk_csf.fkg_Item_id_conf_empr ( en_empresa_id => vn_empresa_id
                                                                   , ev_cod_item   => ev_cod_item );

   --
   if nvl(est_itnf_bem_ativo_imob.item_id,0) <= 0 then
      --
      vn_fase := 11.1;
      --
      gv_mensagem_log := '"Código do item" (' || ev_cod_item || ')está incorreto.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 12;
   --
   if nvl (est_itnf_bem_ativo_imob.vl_item,0) < 0 then
      --
      vn_fase := 12.1;
      --
      gv_mensagem_log := '"Valor do item" não pode ser negativo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 13;
   --
   if nvl (est_itnf_bem_ativo_imob.vl_icms,0) < 0 then
      --
      vn_fase := 13.1;
      --
      gv_mensagem_log := '"Valor total do icms" não pode ser negativo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 14;
   --
   if nvl (est_itnf_bem_ativo_imob.vl_bc_pis,0) < 0 then
      --
      vn_fase := 14.1;
      --
      gv_mensagem_log := '"Valor de Base de Calculo do pis" não pode ser negativo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia 
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 15;
   --
   if nvl (est_itnf_bem_ativo_imob.vl_bc_cofins,0) < 0 then
      --
      vn_fase := 15.1;
      --
      gv_mensagem_log := '"Valor de Base de Calculo do Cofins" não pode ser negativo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 16;
   --
   if nvl (est_itnf_bem_ativo_imob.vl_frete,0) < 0 then
      --
      vn_fase := 16.1;
      --
      gv_mensagem_log := '"Valor do Frete" não pode ser negativo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 17;
   --
   if nvl (est_itnf_bem_ativo_imob.vl_icms_st,0) < 0 then
      --
      vn_fase := 17.1;
      --
      gv_mensagem_log := '"Valor do ICMS-ST" não pode ser negativo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 18;
   --
   if nvl(est_itnf_bem_ativo_imob.nfbemativoimob_id,0) > 0
      and nvl(est_itnf_bem_ativo_imob.item_id,0) > 0
      and est_itnf_bem_ativo_imob.num_item is not null
      then
      --
      if pk_csf.fkg_existe_itnf_bem_ativo_imob ( en_itnfbemativoimob_id => est_itnf_bem_ativo_imob.id ) = true then
         --
         update itnf_bem_ativo_imob set vl_item       =  est_itnf_bem_ativo_imob.vl_item
                                      , vl_icms       =  est_itnf_bem_ativo_imob.vl_icms
                                      , vl_bc_pis     =  est_itnf_bem_ativo_imob.vl_bc_pis
                                      , vl_bc_cofins  =  est_itnf_bem_ativo_imob.vl_bc_cofins
                                      , vl_frete      =  est_itnf_bem_ativo_imob.vl_frete
                                      , vl_icms_st    =  est_itnf_bem_ativo_imob.vl_icms_st
                                      , vl_dif_aliq   =  ev_valor
                where id = est_itnf_bem_ativo_imob.id;
         --
      else
        --
        vn_fase := 18.1;
        --
         insert into itnf_bem_ativo_imob ( id               
                                         , nfbemativoimob_id
                                         , num_item         
                                         , item_id
                                         , vl_item
                                         , vl_icms          
                                         , vl_bc_pis        
                                         , vl_bc_cofins     
                                         , vl_frete         
                                         , vl_icms_st
                                         , vl_dif_aliq
                                         )
                                  values ( est_itnf_bem_ativo_imob.id               
                                         , est_itnf_bem_ativo_imob.nfbemativoimob_id
                                         , est_itnf_bem_ativo_imob.num_item
                                         , est_itnf_bem_ativo_imob.item_id
                                         , est_itnf_bem_ativo_imob.vl_item
                                         , est_itnf_bem_ativo_imob.vl_icms
                                         , est_itnf_bem_ativo_imob.vl_bc_pis
                                         , est_itnf_bem_ativo_imob.vl_bc_cofins
                                         , est_itnf_bem_ativo_imob.vl_frete
                                         , est_itnf_bem_ativo_imob.vl_icms_st
                                         , ev_valor
                                         );
         --
      end if;
      --
      
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_itnf_bem_ativo_imob fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem        => gv_mensagem_log
                              , ev_resumo          => gv_mensagem_log
                              , en_tipo_log        => ERRO_DE_SISTEMA
                              , en_referencia_id   => gn_referencia_id
                              , ev_obj_referencia  => gv_obj_referencia
                              , en_empresa_id         => vn_empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_itnf_bem_ativo_imob;

-------------------------------------------------------------------------------------------------------------

--| Procedimento integra as informações dos Impostos do Bem

procedure pkb_integr_rec_imp_bem_ativo ( est_log_generico           in out nocopy  dbms_sql.number_table
                                       , est_rec_imp_bem_ativo_imob in out nocopy  rec_imp_bem_ativo_imob%rowtype
                                       , en_multorg_id              in             mult_org.id%type
                                       , ev_cpf_cnpj                in             varchar2
                                       , ev_cod_ind_bem             in             bem_ativo_imob.cod_ind_bem%type
                                       , ev_cd_tipo_imp             in             tipo_imposto.cd%type 
                                       , en_loteintws_id            in             lote_int_ws.id%type default 0
                                       )
is
   --
   vn_fase                number := 0;
   vn_loggenericocad_id   Log_Generico_Cad.id%TYPE;
   vn_empresa_id          empresa.id%type := 0;
   vv_nro_lote            varchar2(30) := null;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_cabec_log := 'Empresa: ' || ev_cpf_cnpj || ' "Código do Bem/Componente": ' || ev_cod_ind_bem || ' Código do Tipo de Imposto: ' || ev_cd_tipo_imp || vv_nro_lote;
   --
   vn_fase := 2;
   --
   gv_obj_referencia := 'BEM_ATIVO_IMOB';
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id  => en_multorg_id
                                                        , ev_cpf_cnpj    => ev_cpf_cnpj
                                                        );
   --
   vn_fase := 2.1;
   --
   est_rec_imp_bem_ativo_imob.bemativoimob_id := pk_csf.fkg_id_bem_ativo_imob ( en_empresa_id   => vn_empresa_id
                                                                              , ev_cod_ind_bem  => ev_cod_ind_bem );
   --
   gn_referencia_id := est_rec_imp_bem_ativo_imob.bemativoimob_id;
   --
   vn_fase := 3;
   --
   if nvl(vn_empresa_id,0) <= 0 then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := '"Empresa" ('||ev_cpf_cnpj||') não encontrada.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3.2;
   --
   if nvl(est_rec_imp_bem_ativo_imob.bemativoimob_id,0) <= 0 then
      --
      vn_fase := 3.3;
      --
      gv_mensagem_log := '"Código do Bem/Componente:" ('||ev_cod_ind_bem||') não existe para a empresa (' || ev_cpf_cnpj || ').';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   --
   est_rec_imp_bem_ativo_imob.tipoimp_id := pk_csf.fkg_Tipo_Imposto_id ( en_cd =>  ev_cd_tipo_imp );
   --
   vn_fase := 4.1;
   --
   if nvl(est_rec_imp_bem_ativo_imob.tipoimp_id,0) <= 0 then
      --
      vn_fase := 4.2;
      --
      gv_mensagem_log := '"Código do tipo de imposto" (' || ev_cd_tipo_imp || ') está incorreto.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   --
   est_rec_imp_bem_ativo_imob.id := pk_csf.fkg_recimpbemativoimob_id ( en_bemativoimob_id  =>  est_rec_imp_bem_ativo_imob.bemativoimob_id
                                                                     , en_tipoimp_id       =>  est_rec_imp_bem_ativo_imob.tipoimp_id );
   --
   vn_fase := 5.1;
   --
   if nvl(est_rec_imp_bem_ativo_imob.id,0) <= 0 then
      --
      select recimpbemativoimob_seq.nextval
        into est_rec_imp_bem_ativo_imob.id
        from dual;
      --
   end if;
   -- Seta a referencia
   gn_referencia_id := est_rec_imp_bem_ativo_imob.id;
   --
   vn_fase := 6;
   --
   est_rec_imp_bem_ativo_imob.aliq := nvl(est_rec_imp_bem_ativo_imob.aliq,0);
   --
   if est_rec_imp_bem_ativo_imob.aliq < 0 then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := '"Aliquota de imposto" (' || est_rec_imp_bem_ativo_imob.aliq || ') não pode ser negativa.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia 
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 7;
   --
   if nvl(est_rec_imp_bem_ativo_imob.qtde_mes,0) <= 0 then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := '"Quantidade de meses a recuperar a partir da data de aquisição" (' || est_rec_imp_bem_ativo_imob.qtde_mes || ') deve ser maior que zero.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 8;
   --
   if nvl(est_rec_imp_bem_ativo_imob.qtde_mes_real,0) <= 0 then
      --
      vn_fase := 8.1;
      --
      gv_mensagem_log := '"Quantidade de meses real a recuperar a partir da data de aquisição" (' || est_rec_imp_bem_ativo_imob.qtde_mes_real || ') deve ser maior que zero.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => vn_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_rec_imp_bem_ativo_imob.bemativoimob_id,0) > 0
      and nvl(est_rec_imp_bem_ativo_imob.tipoimp_id,0) > 0
      and est_rec_imp_bem_ativo_imob.aliq >= 0
      and est_rec_imp_bem_ativo_imob.qtde_mes > 0
      and est_rec_imp_bem_ativo_imob.qtde_mes_real > 0
      then
      --
      vn_fase := 99.1;
      --
      if pk_csf.fkg_existe_rec_imp_bem_ativo ( en_recimpbemativoimob_id => est_rec_imp_bem_ativo_imob.id ) = true then
         --
         vn_fase := 99.2;
         --
         update rec_imp_bem_ativo_imob set aliq          = est_rec_imp_bem_ativo_imob.aliq
                                         , qtde_mes      = est_rec_imp_bem_ativo_imob.qtde_mes
                                         , qtde_mes_real = est_rec_imp_bem_ativo_imob.qtde_mes_real
          where id = est_rec_imp_bem_ativo_imob.id;
         --
      else
         --
         vn_fase := 99.3;
         --
         insert into rec_imp_bem_ativo_imob ( id
                                            , bemativoimob_id
                                            , aliq           
                                            , qtde_mes       
                                            , qtde_mes_real
                                            , tipoimp_id
                                            )
                                     values ( est_rec_imp_bem_ativo_imob.id
                                            , est_rec_imp_bem_ativo_imob.bemativoimob_id
                                            , est_rec_imp_bem_ativo_imob.aliq
                                            , est_rec_imp_bem_ativo_imob.qtde_mes
                                            , est_rec_imp_bem_ativo_imob.qtde_mes_real
                                            , est_rec_imp_bem_ativo_imob.tipoimp_id
                                            );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_rec_imp_bem_ativo fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_SISTEMA
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => vn_empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_rec_imp_bem_ativo;

-------------------------------------------------------------------------------------------------------

-- Procedimento que verifica se existe os dados do "Impostos do bem ativo" e caso não exista,
-- recupera a partir do REC_IMP_SUBGRUPO_PAT.

procedure pkb_rec_imp_bem_ativo ( en_bemativoimob_id in bem_ativo_imob.id%type
                                , en_multorg_id      in mult_org.id%type
                                , ev_cpf_cnpj        in varchar2
                                , ev_cod_ind_bem     in bem_ativo_imob.cod_ind_bem%type
                                )
is
   --
   vn_fase            number := 0;
   vt_log_generico    dbms_sql.number_table;
   --
   vn_recimpbemativoimob_id   number := 0;
   vv_cd_tipo_imp             tipo_imposto.cd%type;
   vn_empresa_id              empresa.id%type;
   --
   cursor c_rec_imp is
      select r.aliq         ALIQ
           , r.qtde_mes     QTDE_MES
           , r.tipoimp_id   TIPOIMP_ID
        from rec_imp_subgrupo_pat r
           , bem_ativo_imob b
       where b.id = en_bemativoimob_id
         and b.subgrupopat_id = r.subgrupopat_id;
   --
begin
   --
   gv_obj_referencia := 'BEM_ATIVO_IMOB';
   --
   gn_referencia_id := en_bemativoimob_id;
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id  => en_multorg_id
                                                        , ev_cpf_cnpj    => ev_cpf_cnpj );
   --
   begin
      --
      select nvl(max(id),0)
        into vn_recimpbemativoimob_id
        from rec_imp_bem_ativo_imob r
       where r.bemativoimob_id = en_bemativoimob_id;
      --
   exception
      when others then
         --
         vn_recimpbemativoimob_id := 1;
         --
         gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_rec_imp_bem_ativo fase(' || vn_fase || '): ' || sqlerrm;
         --
         declare
            vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
         begin
            --
            pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                 , ev_mensagem           => gv_mensagem_log
                                 , ev_resumo             => gv_mensagem_log
                                 , en_tipo_log           => ERRO_DE_SISTEMA
                                 , en_referencia_id      => gn_referencia_id
                                 , ev_obj_referencia     => gv_obj_referencia 
                                 , en_empresa_id         => vn_empresa_id
                                 );
            --
         exception
            when others then
               null;
         end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
   end;
   --
   if vn_recimpbemativoimob_id = 0 then
      --
      for rec in c_rec_imp loop
         exit when c_rec_imp%notfound or (c_rec_imp%notfound) is null;
         --
         vt_Log_Generico.delete;
         --
         pk_csf_api_cad.gt_row_rec_imp_bem_ativo_imob := null;
         --
         pk_csf_api_cad.gt_row_rec_imp_bem_ativo_imob.aliq          :=  rec.ALIQ;
         pk_csf_api_cad.gt_row_rec_imp_bem_ativo_imob.qtde_mes      :=  rec.QTDE_MES;
         pk_csf_api_cad.gt_row_rec_imp_bem_ativo_imob.qtde_mes_real :=  rec.QTDE_MES;
         --
         vv_cd_tipo_imp := pk_csf.fkg_Tipo_Imposto_cd ( en_tipoimp_id => rec.TIPOIMP_ID );
         --
         pkb_integr_rec_imp_bem_ativo ( est_log_generico            => vt_log_generico
                                      , est_rec_imp_bem_ativo_imob  => pk_csf_api_cad.gt_row_rec_imp_bem_ativo_imob
                                      , en_multorg_id               => en_multorg_id
                                      , ev_cpf_cnpj                 => ev_cpf_cnpj
                                      , ev_cod_ind_bem              => ev_cod_ind_bem
                                      , ev_cd_tipo_imp              => vv_cd_tipo_imp 
                                      );
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
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_rec_imp_bem_ativo fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_SISTEMA
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => vn_empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_rec_imp_bem_ativo;

-------------------------------------------------------------------------------------------------------
-- Procedure Insere ou atualiza registro nat_oper

procedure pkb_cria_nat_oper ( ev_cod_nat    in Nat_Oper.cod_nat%TYPE
                            , ev_descr_nat  in Nat_Oper.descr_nat%TYPE
                            , en_multorg_id in Nat_Oper.multorg_id%TYPE
                            , en_dm_st_proc in Nat_Oper.dm_st_proc%type
                            )
is
   --
   --
begin
   --
   if trim( ev_cod_nat ) is not null
      and trim( ev_descr_nat ) is not null 
      and nvl(en_multorg_id,0) > 0 then
      --
      begin
         --
         insert into Nat_Oper ( id
                              , cod_nat
                              , descr_nat
                              , multorg_id
                              , dm_st_proc
                              )
                        values
                              ( natoper_seq.nextval
                              , trim(ev_cod_nat)
                              , trim(ev_descr_nat)
                              , en_multorg_id
                              , en_dm_st_proc
                              );
         --
         commit;
         --
      exception
         --
         when others then
            --
            update Nat_Oper set descr_nat  = trim(ev_descr_nat)
                              , dm_st_proc = en_dm_st_proc
             where cod_nat    = ev_cod_nat
               and multorg_id = en_multorg_id;
            --
            commit;
            --
      end;
      --
      -- Calcula a quantidade de registros totais integrados e integrados com sucesso
      -- para ser mostrado na tela de agendamento.
      --
      begin
         pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
         pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj),0) + 1;
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
      raise_application_error(-20101, 'Erro na pkb_cria_nat_oper: ' || sqlerrm);
end pkb_cria_nat_oper;

-------------------------------------------------------------------------------------------------------

--| Função retorna o ID da NAT_OPER pelo cod_nat

function fkg_natoper_id_cod_nat ( en_multorg_id in mult_org.id%type
                                , ev_cod_nat    in Nat_Oper.cod_nat%TYPE )
         return Nat_Oper.id%TYPE
is

  vn_natoper_id  Nat_Oper.id%TYPE;

begin

   if ev_cod_nat is not null then

      select nop.id
        into vn_natoper_id
        from Nat_Oper  nop
       where nop.cod_nat = trim(ev_cod_nat)
         and multorg_id = en_multorg_id;

   end if;

   return vn_natoper_id;

exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_natoper_id_cod_nat: ' || sqlerrm);
end fkg_natoper_id_cod_nat;

-------------------------------------------------------------------------------------------------------

-- Procedimento integra os dados de Informação Complementar do Documento Fiscal
procedure pkb_integr_inf_comp_dcto_fis ( est_log_generico            in out nocopy  dbms_sql.number_table
                                       , est_infor_comp_dcto_fiscal  in out nocopy  infor_comp_dcto_fiscal%rowtype 
                                       , en_loteintws_id             in             lote_int_ws.id%type default 0
                                       , en_empresa_id               in             empresa.id%type
                                       )
is
   --
   vn_fase               number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
   vv_nro_lote           varchar2(30) := null;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'INFOR_COMP_DCTO_FISCAL';
   --
   gv_cabec_log := trim(est_infor_comp_dcto_fiscal.cod_infor) || '-' || trim(pk_csf.fkg_converte(est_infor_comp_dcto_fiscal.txt)) || vv_nro_lote;
   --
   est_infor_comp_dcto_fiscal.id := pk_csf.fkg_Infor_Comp_Dcto_Fiscal_id ( en_cod_infor  => trim(est_infor_comp_dcto_fiscal.cod_infor)
                                                                         , en_multorg_id => est_infor_comp_dcto_fiscal.multorg_id
                                                                         );
   --
   vn_fase := 1.1;
   --
   if nvl(est_infor_comp_dcto_fiscal.id,0) <= 0 then
      --
      select infcompdctofis_seq.nextval
        into est_infor_comp_dcto_fiscal.id
        from dual;
      --
   end if;
   --
   vn_fase := 1.2;
   --
   gn_referencia_id := est_infor_comp_dcto_fiscal.id;
   --
   delete from log_generico_cad
    where REFERENCIA_ID = gn_referencia_id
      and OBJ_REFERENCIA = gv_obj_referencia;
   --
   vn_fase := 2;
   --
   if nvl(est_infor_comp_dcto_fiscal.multorg_id,0) <= 0 then
      --
      gv_mensagem_log := '"Mult-Organização" não informada.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => en_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2.1;
   --
   if not pk_csf.fkg_valida_multorg_id ( en_multorg_id => est_infor_comp_dcto_fiscal.multorg_id ) then
      --
      gv_mensagem_log := '"Mult-Organização" inválido ('|| est_infor_comp_dcto_fiscal.multorg_id || ').';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia 
                           , en_empresa_id         => en_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   if trim(est_infor_comp_dcto_fiscal.cod_infor) is null then
      --
      vn_fase := 2.2;
      --
      gv_mensagem_log := '"Código da Informação" não pode ser nulo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   if trim(pk_csf.fkg_converte(est_infor_comp_dcto_fiscal.txt)) is null then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := '"Texto" não pode ser nulo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id      => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_log_generico.count,0) > 0 then
      est_infor_comp_dcto_fiscal.dm_st_proc := 2; -- Erro de validação
   else
      est_infor_comp_dcto_fiscal.dm_st_proc := 1; -- Validado
   end if;
   --
   if trim(est_infor_comp_dcto_fiscal.cod_infor) is not null
      and trim(pk_csf.fkg_converte(est_infor_comp_dcto_fiscal.txt)) is not null 
      and nvl(est_infor_comp_dcto_fiscal.multorg_id,0) > 0 then
      --
      vn_fase := 99.1;
      --
      -- Calcula a quantidade de registros totais integrados para ser
      -- mostrado na tela de agendamento.
      --
      begin
         pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
      exception
         when others then
         null;
      end;
      --
      if pk_csf.fkg_existe_Inf_Comp_Dcto_Fis ( en_infcompdctofis_id => est_infor_comp_dcto_fiscal.id ) = true then
         --
         vn_fase := 99.2;
         --
         update infor_comp_dcto_fiscal set txt        = trim(pk_csf.fkg_converte(est_infor_comp_dcto_fiscal.txt))
                                         , dm_st_proc = est_infor_comp_dcto_fiscal.dm_st_proc
          where id = est_infor_comp_dcto_fiscal.id;
         --
      else
         --
         vn_fase := 99.3;
         --
         insert into infor_comp_dcto_fiscal ( id
                                            , cod_infor
                                            , txt
                                            , multorg_id
                                            , dm_st_proc
                                            )
                                     values
                                            ( est_infor_comp_dcto_fiscal.id
                                            , trim(est_infor_comp_dcto_fiscal.cod_infor)
                                            , trim(pk_csf.fkg_converte(est_infor_comp_dcto_fiscal.txt))
                                            , est_infor_comp_dcto_fiscal.multorg_id
                                            , est_infor_comp_dcto_fiscal.dm_st_proc
                                            );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_inf_comp_dcto_fis fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia
                                     , en_empresa_id      => en_empresa_id
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_inf_comp_dcto_fis;

-------------------------------------------------------------------------------------------------------

-- Procedimento integra os dados de Observação do Lançamento Fiscal
procedure pkb_integr_obs_lancto_fiscal ( est_log_generico            in out nocopy  dbms_sql.number_table
                                       , est_obs_lancto_fiscal       in out nocopy  obs_lancto_fiscal%rowtype 
                                       , en_loteintws_id             in             lote_int_ws.id%type default 0
                                       , en_empresa_id               in             empresa.id%type
                                       )
is
   --
   vn_fase               number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
   vv_nro_lote           varchar2(30) := null;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'OBS_LANCTO_FISCAL';
   --
   gv_cabec_log := trim(est_obs_lancto_fiscal.cod_obs) || '-' || trim(pk_csf.fkg_converte(est_obs_lancto_fiscal.txt)) || vv_nro_lote;
   --
   est_obs_lancto_fiscal.id := pk_csf.fkg_id_obs_lancto_fiscal ( ev_cod_obs    => trim(est_obs_lancto_fiscal.cod_obs)
                                                               , en_multorg_id => est_obs_lancto_fiscal.multorg_id );
   --
   vn_fase := 1.1;
   --
   if nvl(est_obs_lancto_fiscal.id,0) <= 0 then
      --
      select obslanctofiscal_seq.nextval
        into est_obs_lancto_fiscal.id
        from dual;
      --
   end if;
   --
   vn_fase := 1.2;
   --
   gn_referencia_id := est_obs_lancto_fiscal.id;
   --
   delete from log_generico_cad
    where REFERENCIA_ID = gn_referencia_id
      and OBJ_REFERENCIA = gv_obj_referencia;
   --
   vn_fase := 1.3;
   --
   if nvl(est_obs_lancto_fiscal.multorg_id,0) <= 0 then
      --
      gv_mensagem_log := '"Mult-Organização" não informada.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => en_empresa_id 
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 1.4;
   --
   if not pk_csf.fkg_valida_multorg_id ( en_multorg_id => est_obs_lancto_fiscal.multorg_id ) then
      --
      gv_mensagem_log := '"Mult-Organização" inválido ('|| est_obs_lancto_fiscal.multorg_id || ').';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => en_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2;
   --
   if trim(est_obs_lancto_fiscal.cod_obs) is null then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := '"Código da Observação" não pode ser nulo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id         => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   if trim(pk_csf.fkg_converte(est_obs_lancto_fiscal.txt)) is null then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := '"Texto" não pode ser nulo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id         => en_empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_log_generico.count,0) > 0 then
      est_obs_lancto_fiscal.dm_st_proc := 2; -- Erro de validação
   else
      est_obs_lancto_fiscal.dm_st_proc := 1; -- Validado
   end if;
   --
   if trim(est_obs_lancto_fiscal.cod_obs) is not null
      and trim(pk_csf.fkg_converte(est_obs_lancto_fiscal.txt)) is not null 
      and nvl(est_obs_lancto_fiscal.multorg_id,0) > 0 then
      --
      vn_fase := 99.1;
      --
      -- Calcula a quantidade de registros totais integrados para ser
      -- mostrado na tela de agendamento.
      --
      begin
         pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
      exception
         when others then
         null;
      end;
      --
      if pk_csf.fkg_existe_obs_lancto_fiscal ( en_obslanctofiscal_id => est_obs_lancto_fiscal.id ) = true then
         --
         vn_fase := 99.2;
         --
         update obs_lancto_fiscal set txt        = trim(pk_csf.fkg_converte(est_obs_lancto_fiscal.txt))
                                    , dm_st_proc = est_obs_lancto_fiscal.dm_st_proc
          where id = est_obs_lancto_fiscal.id;
         --
      else
         --
         vn_fase := 99.3;
         --
         insert into obs_lancto_fiscal ( id
                                       , cod_obs
                                       , txt
                                       , multorg_id
                                       , dm_st_proc
                                       )
                                values ( est_obs_lancto_fiscal.id
                                       , trim(est_obs_lancto_fiscal.cod_obs)
                                       , trim(pk_csf.fkg_converte(est_obs_lancto_fiscal.txt))
                                       , est_obs_lancto_fiscal.multorg_id
                                       , est_obs_lancto_fiscal.dm_st_proc
                                       );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_obs_lancto_fiscal fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia
                                     , en_empresa_id      => en_empresa_id
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_obs_lancto_fiscal;

-------------------------------------------------------------------------------------------------------

-- Procedimento integra os dados de Parâmetros de Cálculo de ICMS-ST
procedure pkb_integr_item_param_icmsst ( est_log_generico       in out nocopy  dbms_sql.number_table
                                       , est_item_param_icmsst  in out nocopy  item_param_icmsst%rowtype
                                       , en_multorg_id          in             mult_org.id%type
                                       , ev_cpf_cnpj            in             varchar2
                                       , ev_cod_item 	        in 	       item.cod_item%type
                                       , ev_sigla_uf_dest       in             estado.sigla_estado%type
                                       , en_cfop_orig	        in 	       cfop.cd%type
                                       , ev_cod_obs	        in  	       obs_lancto_fiscal.cod_obs%type
                                       , en_cfop_dest	        in	       cfop.cd%type
                                       , ev_cod_st	        in 	       cod_st.cod_st%type 
                                       , en_loteintws_id        in             lote_int_ws.id%type default 0
                                       )
is
   --
   vn_fase               number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
   vn_empresa_id         empresa.id%TYPE;
   vv_nro_lote           varchar2(30) := null;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := '. Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'ITEM_PARAM_ICMSST';
   --
   gv_cabec_log := 'Parâmetros de Cálculo de ICMS-ST da Empresa CPF/CNPJ: '||ev_cpf_cnpj||'. Código do item: '||ev_cod_item|| vv_nro_lote||'.';
   --
   vn_fase := 2;
   --
   est_item_param_icmsst.empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id  => en_multorg_id
                                                                           , ev_cpf_cnpj    => ev_cpf_cnpj
                                                                           );
   --
   vn_fase := 3;
   --
   est_item_param_icmsst.item_id := pk_csf.fkg_Item_id_conf_empr ( en_empresa_id  => est_item_param_icmsst.empresa_id
                                                                 , ev_cod_item    => ev_cod_item );
   --
   --
   vn_fase := 3;
   --
   est_item_param_icmsst.estado_id := pk_csf.fkg_Estado_id ( ev_sigla_estado => ev_sigla_uf_dest );
   --
   vn_fase := 4;
   --
   est_item_param_icmsst.obslanctofiscal_id := pk_csf.fkg_id_obs_lancto_fiscal( ev_cod_obs    => ev_cod_obs
                                                                              , en_multorg_id => en_multorg_id );
   --
   vn_fase := 5;
   --
   est_item_param_icmsst.cfop_id := pk_csf.fkg_cfop_id ( en_cd => en_cfop_orig );
   --
   vn_fase := 6;
   --
   est_item_param_icmsst.cfop_id_dest := pk_csf.fkg_cfop_id ( en_cd => en_cfop_dest );
   --
   vn_fase := 7;
   --
   est_item_param_icmsst.codst_id := pk_csf.fkg_Cod_ST_id ( ev_cod_st      => ev_cod_st
                                                          , en_tipoimp_id  => pk_csf.fkg_Tipo_Imposto_id ( en_cd => 1 ) );
   --
   vn_fase := 8;
   --
   est_item_param_icmsst.id := pk_csf.fkg_item_param_icmsst_id( en_item_id 	=> est_item_param_icmsst.item_id
                                                              , en_empresa_id 	=> est_item_param_icmsst.empresa_id
                                                              , en_estado_id 	=> est_item_param_icmsst.estado_id
                                                              , en_cfop_id_orig => est_item_param_icmsst.cfop_id
                                                              , ed_dt_ini	=> est_item_param_icmsst.dt_ini
                                                              , ed_dt_fin	=> est_item_param_icmsst.dt_fin
                                                              );
   --
   vn_fase := 9;
   --
   if nvl(est_item_param_icmsst.id,0) <= 0 then
      --
      vn_fase := 9.1;
      --
      select itemparamicmsst_seq.nextval
        into  est_item_param_icmsst.id
        from dual;
   end if;
   --
   gn_referencia_id := est_item_param_icmsst.id;
   --
   delete from log_generico_cad
    where REFERENCIA_ID = gn_referencia_id
      and OBJ_REFERENCIA = gv_obj_referencia;
   --
   vn_fase := 10;
   --
   --id do item
   if nvl(est_item_param_icmsst.item_id,-1) <= 0 then
      --
      vn_fase := 11.1;
      --
      gv_mensagem_log := '"Identificador do Código do Item" O campo não pode ser nulo. Código do Item informado '||ev_cod_item;
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia 
                                  , en_empresa_id      => est_item_param_icmsst.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 13;
   --
   --id da empresa
   if nvl(est_item_param_icmsst.empresa_id,-1) <= 0 then
      --
      vn_fase := 13.1;
      --
      gv_mensagem_log := '"Identificador da Empresa Invalido" O campo não pode ser nulo. CNPJ ou CPF informado '||ev_cpf_cnpj;
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia 
                                  , en_empresa_id      => est_item_param_icmsst.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 14;
   --
   --id estado
   if nvl(est_item_param_icmsst.estado_id,-1) <= 0 then
      --
      vn_fase := 14.1;
      --
      gv_mensagem_log := '"UF do Estado de Destino Invalido" O campo não pode ser nulo. UF do Estado de Destino informado '||ev_sigla_uf_dest;
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia 
                                  , en_empresa_id      => est_item_param_icmsst.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 15;
   --
   --aliquota destino
   if nvl(est_item_param_icmsst.aliq_dest,-1) <= 0 then
      --
      vn_fase := 15.1;
      --
      gv_mensagem_log := '"Aliquota de Destino Invalido" O campo não pode ser nulo. Aliquota informada '||est_item_param_icmsst.aliq_dest;
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia 
                                  , en_empresa_id      => est_item_param_icmsst.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 16;
   --
   --Codigo da abservação de lançamento/Id da obserção de lançamento
   if( est_item_param_icmsst.obslanctofiscal_id ) is null
   		and ( ev_cod_obs ) is not null then
   		--
   		--
      vn_fase := 16.1;
      --
      gv_mensagem_log := '"Código de Lançamento Fiscal Invalido" Código de Lançamento Fisca informado '||ev_cod_obs;
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia 
                                  , en_empresa_id      => est_item_param_icmsst.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
 	 end if;
   --
   vn_fase := 17;
   --
   --CFOP de origem
   if nvl(est_item_param_icmsst.cfop_id,-1) <= 0 then
      --
      vn_fase := 17.1;
      --
      gv_mensagem_log := '"Indetificador do CFOP do Estado de Origem Invalido" O campo não pode ser nulo. CFOP informado.'||en_cfop_orig;
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia 
                                  , en_empresa_id      => est_item_param_icmsst.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 18;
   --
   --CFOP do estado de destino
   if nvl(est_item_param_icmsst.cfop_id_dest,-1) <= 0 then
      --
      vn_fase := 18.1;
      --
      gv_mensagem_log := '"Indetificador do CFOP do Estado de Destino Invalido" O campo não pode ser nulo. CFOP informado.'||en_cfop_dest;
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia 
                                  , en_empresa_id      => est_item_param_icmsst.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 19;
   --
   --Codigo da situacao tributaria/id da situacao tributaria
   if nvl(est_item_param_icmsst.codst_id,-1) <= 0 then
      --
      vn_fase :=19.1;
      --
      gv_mensagem_log := '"Identficado do Codigo da Situação Tributaria Invalido" O campo não pode ser nulo. Codigo da Situação informado. '||ev_cod_st;
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia 
                                  , en_empresa_id      => est_item_param_icmsst.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 20;
   --
   --Modalidade da Base de Calculo
   if nvl(est_item_param_icmsst.dm_mod_base_calc_st,-1) not between 0 and 6 then
      --
      vn_fase := 21.1;
      --
      gv_mensagem_log := '"Modalidade da Base de Cálculo de ICMS-ST Inválido" O campo não pode ser nulo e/ou valor informado deve estar entre 0 ou 5. Modalidade da Base de Cálculo de ICMS-ST informado '||est_item_param_icmsst.dm_mod_base_calc_st;
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 22;
   --
   --indice
   if nvl(est_item_param_icmsst.indice,-1) <= 0 then
      --
      vn_fase := 22.1;
      --
      gv_mensagem_log := '"Índice da Modalidade da Base de Cálculo de ICMS-ST Invaido" O campo não pode ser nulo. Índice da Modalidade da Base de Cálculo de ICMS-ST informado '||est_item_param_icmsst.indice;
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia 
                                  , en_empresa_id      => est_item_param_icmsst.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 23;
   --
   --Ajusta MVA
   if nvl(est_item_param_icmsst.dm_ajusta_mva,-1) not in (0,1) then
      --
      vn_fase := 23.1;
      --
      gv_mensagem_log := 'O campo "MVA" não pode ser nulo e/ou inválido, deve ser 0 ou 1. "MVA" informado '||est_item_param_icmsst.dm_ajusta_mva;
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia 
                                  , en_empresa_id      => est_item_param_icmsst.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 24;
   --
   --data de inicio do parametro
   if (est_item_param_icmsst.dt_ini) is null then
      --
      vn_fase := 24.1;
      --
      gv_mensagem_log := '"Data de Inicio do Parâmetro" O campo não pode ser nulo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia 
                                  , en_empresa_id      => est_item_param_icmsst.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 25;
   --
   --data final
   if (est_item_param_icmsst.dt_fin) is not null
   		and (est_item_param_icmsst.dt_fin < est_item_param_icmsst.dt_ini) then
      --
      vn_fase := 25.1;
      --
      gv_mensagem_log := '"Data de Fim do Parâmetro Inválido" A data final não pode ser menor que a data inicial. Data inicial '||est_item_param_icmsst.dt_ini;
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia 
                                  , en_empresa_id      => est_item_param_icmsst.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 26;
   --
   if nvl(est_item_param_icmsst.dm_efeito,-1) not between 1 and 2 then
      --
      vn_fase := 26.1;
      --
      gv_mensagem_log := '"Efeito do Parâmetro Inválido". O campo não pode ser nulo e/ou deve ser 1 ou 2. Efeito do Parâmetro informado '||est_item_param_icmsst.dm_efeito;
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia 
                                  , en_empresa_id      => est_item_param_icmsst.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 27;
   --
   if nvl(est_log_generico.count,0) > 0 then
      est_item_param_icmsst.dm_st_proc := 2; -- Erro de validação
   else
      est_item_param_icmsst.dm_st_proc := 1; -- Validado
      --
   end if;
   --
   if nvl(est_item_param_icmsst.item_id,0) >= 0
      and est_item_param_icmsst.empresa_id >= 0
      and est_item_param_icmsst.estado_id  >= 0
      and est_item_param_icmsst.aliq_dest >= 0
      and est_item_param_icmsst.cfop_id >= 0
      and est_item_param_icmsst.cfop_id_dest >= 0
      and est_item_param_icmsst.codst_id >= 0
      and est_item_param_icmsst.dm_mod_base_calc_st between 0 and 6
      and est_item_param_icmsst.indice >= 0
      and est_item_param_icmsst.dm_ajusta_mva between 0 and 1
      and est_item_param_icmsst.dm_efeito between 1 and 2 then
      --
      vn_fase := 27.1;
      --
      -- Calcula a quantidade de registros totais integrados para ser
      -- mostrado na tela de agendamento.
      --
      begin
         pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
      exception
         when others then
         null;
      end;
      --
      if pk_csf.fkg_itemparamicmsst_id_valido ( en_id  => est_item_param_icmsst.id ) = true then
    	 --
   	 vn_fase := 27.2;
   	 --
   	 update item_param_icmsst
   	    set aliq_dest            = est_item_param_icmsst.aliq_dest
	      , obslanctofiscal_id   = est_item_param_icmsst.obslanctofiscal_id
	      , cfop_id_dest         = est_item_param_icmsst.cfop_id_dest
	      , codst_id             = est_item_param_icmsst.codst_id
          , dm_mod_base_calc_st  = est_item_param_icmsst.dm_mod_base_calc_st
	      , indice               = est_item_param_icmsst.indice
	      , perc_reduc_bc        = est_item_param_icmsst.perc_reduc_bc
	      , dm_ajusta_mva        = est_item_param_icmsst.dm_ajusta_mva
	      , dm_efeito   	     = est_item_param_icmsst.dm_efeito
	      , dm_st_proc           = est_item_param_icmsst.dm_st_proc
          where id = est_item_param_icmsst.id;
      else
    	 --
   	 vn_fase := 27.3;
   	 --
	 insert into item_param_icmsst ( id
                                       , item_id
                                       , empresa_id
                                       , estado_id
                                       , aliq_dest
                                       , obslanctofiscal_id
                                       , cfop_id
                                       , cfop_id_dest
                                       , codst_id
                                       , dm_mod_base_calc_st
                                       , indice
                                       , perc_reduc_bc
                                       , dm_ajusta_mva
                                       , dt_ini
                                       , dt_fin
                                       , dm_efeito
                                       , dm_st_proc
                                       )
				values ( est_item_param_icmsst.id
                                       , est_item_param_icmsst.item_id
                                       , est_item_param_icmsst.empresa_id
                                       , est_item_param_icmsst.estado_id
                                       , est_item_param_icmsst.aliq_dest
                                       , est_item_param_icmsst.obslanctofiscal_id
                                       , est_item_param_icmsst.cfop_id
                                       , est_item_param_icmsst.cfop_id_dest
                                       , est_item_param_icmsst.codst_id
                                       , est_item_param_icmsst.dm_mod_base_calc_st
                                       , est_item_param_icmsst.indice
                                       , est_item_param_icmsst.perc_reduc_bc
                                       , est_item_param_icmsst.dm_ajusta_mva
                                       , est_item_param_icmsst.dt_ini
                                       , est_item_param_icmsst.dt_fin
                                       , est_item_param_icmsst.dm_efeito
                                       , est_item_param_icmsst.dm_st_proc
                                       );
         --
      end if;
      --
   end if;
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_item_param_icmsst fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia 
                                     , en_empresa_id      => est_item_param_icmsst.empresa_id 
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
--
end pkb_integr_item_param_icmsst;

-------------------------------------------------------------------------------------------------------

-- Procedimento de integração da tabela de Lançamento de Valores das Tabelas Dinâmicas do ECF
procedure pkb_integr_param_dipamgia ( est_log_generico         in out nocopy dbms_sql.number_table
                                    , est_row_param_dipamgia   in out nocopy param_dipamgia%rowtype
                                    , en_multorg_id            in            mult_org.id%type
                                    , ev_cpf_cnpj              in            varchar2
                                    , ev_ibge_estado           in            estado.ibge_estado%type
                                    , ev_cd_dipamgia           in            dipam_gia.cd%type
                                    , en_cd_cfop               in            cfop.cd%type
                                    , ev_cod_item              in            item.cod_item%type
                                    , ev_cod_ncm               in            ncm.cod_ncm%type
                                    , en_loteintws_id          in            lote_int_ws.id%type default 0
                                    )
is
   --
   vn_fase           number := null;
   vn_loggenerico_id log_generico.id%type;
   vv_nro_lote       varchar2(30);
   --
   vn_estado_id      estado.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   gn_referencia_id := est_row_param_dipamgia.id;
   gv_obj_referencia := 'PARAM_DIPAMGIA';
   --
   vv_nro_lote := null;
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_cabec_log := 'Parametros da DIPAM-GIA por estado' || vv_nro_lote;
   gv_cabec_log := gv_cabec_log || chr(10);
   --
   if nvl(est_row_param_dipamgia.empresa_id,0) <= 0 then
      --
      est_row_param_dipamgia.empresa_id :=  pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id  => en_multorg_id
                                                                                , ev_cpf_cnpj    => ev_cpf_cnpj );
      --
   end if;
   --
   vn_fase := 1.2;
   --
   if nvl(est_row_param_dipamgia.empresa_id,0) > 0 then
     --
     gv_cabec_log := gv_cabec_log || 'Empresa: ' || pk_csf.fkg_nome_empresa ( en_empresa_id => est_row_param_dipamgia.empresa_id );
     gv_cabec_log := gv_cabec_log || chr(10);
     --
   end if;
   --
   vn_fase := 1.3;
   --
   gv_cabec_log := gv_cabec_log || ' Cód. IBGE Estado: '|| ev_ibge_estado ;
   gv_cabec_log := gv_cabec_log || chr(10);
   --
   gv_cabec_log := gv_cabec_log || ' Cód. DIPAM-GIA: '|| ev_cd_dipamgia ;
   gv_cabec_log := gv_cabec_log || chr(10);
   --
   gv_cabec_log := gv_cabec_log || ' Cód. CFOP: '|| en_cd_cfop ;
   gv_cabec_log := gv_cabec_log || chr(10);
   --
   gv_cabec_log := gv_cabec_log || ' Cód. Item: '|| ev_cod_item ;
   gv_cabec_log := gv_cabec_log || chr(10);
   --
   gv_cabec_log := gv_cabec_log || ' Cód. NCM: '|| ev_cod_ncm ;
   gv_cabec_log := gv_cabec_log || chr(10);
   --
   vn_fase := 2;
   --
   -- Validar Registros
   vn_estado_id := pk_csf.fkg_Estado_ibge_id ( ev_ibge_estado => ev_ibge_estado );
   --
   if nvl(vn_estado_id,0) = 0
    and trim(ev_ibge_estado) is not null then
      --
      gv_mensagem_log := 'O Código do IBGE do Estado para identificar o DIPAM-GIA inválido ('|| ev_ibge_estado ||'), Favor Verificar.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log || gv_mensagem_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia
                       , en_empresa_id      => est_row_param_dipamgia.empresa_id
                       );
      --
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenerico_id
                          , est_log_generico  => est_log_generico
                          );
      --
   end if;
   --
   vn_fase := 2.1;
   --
   if nvl(vn_estado_id,0) > 0
    and trim(ev_cd_dipamgia) is not null then
      --
      vn_fase := 2.2;
      --
      est_row_param_dipamgia.dipamgia_id := pk_csf.fkg_dipamgia_id ( en_estado_id => vn_estado_id
                                                                   , ev_cd_dipamgia => ev_cd_dipamgia );
      --
      if nvl(est_row_param_dipamgia.dipamgia_id,0) = 0 then
         --
         gv_mensagem_log := 'O Código do DIPAM-GIA inválido ('|| ev_cd_dipamgia ||'), Favor Verificar.';
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenerico_id
                          , ev_mensagem        => gv_cabec_log || gv_mensagem_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_VALIDACAO
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia
                          , en_empresa_id      => est_row_param_dipamgia.empresa_id
                          );
         --
         pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenerico_id
                             , est_log_generico  => est_log_generico
                             );
         --
      end if;
      --
   end if;
   --
   vn_fase := 3;
   --
   est_row_param_dipamgia.cfop_id := pk_csf.fkg_cfop_id ( en_cd => en_cd_cfop );
   --
   if nvl(est_row_param_dipamgia.cfop_id,0) = 0 then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := 'O Código do CFOP inválido ('|| en_cd_cfop ||'), Favor Verificar.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log || gv_mensagem_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia
                       , en_empresa_id      => est_row_param_dipamgia.empresa_id
                       );
      --
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenerico_id
                          , est_log_generico  => est_log_generico
                          );
      --
   end if;
   --
   vn_fase := 4;
   --
   est_row_param_dipamgia.item_id := pk_csf.fkg_Item_id_conf_empr ( en_empresa_id => est_row_param_dipamgia.empresa_id
                                                                  , ev_cod_item   => ev_cod_item
                                                                  );
   --
   if nvl(est_row_param_dipamgia.item_id,0) = 0
    and trim(ev_cod_item) is not null then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := 'O Código do ITEM inválido ou não cadastrado na base Compliance ('|| ev_cod_item ||'), Favor Verificar.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenerico_id
                           , ev_mensagem        => gv_cabec_log || gv_mensagem_log
                           , ev_resumo          => gv_mensagem_log
                           , en_tipo_log        => ERRO_DE_VALIDACAO
                           , en_referencia_id   => gn_referencia_id
                           , ev_obj_referencia  => gv_obj_referencia
                           , en_empresa_id      => est_row_param_dipamgia.empresa_id
                           );
      --
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenerico_id
                          , est_log_generico  => est_log_generico
                          );
      --
   end if;
   --
   vn_fase := 5;
   --
   est_row_param_dipamgia.ncm_id := pk_csf.fkg_Ncm_id ( ev_cod_ncm => ev_cod_ncm );
   --
   if nvl(est_row_param_dipamgia.ncm_id,0) = 0 
    and trim(ev_cod_ncm) is not null then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := 'O Código do NCM inválido ou não cadastrado na base Compliance ('|| ev_cod_ncm ||'), Favor Verificar.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log || gv_mensagem_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia
                       , en_empresa_id      => est_row_param_dipamgia.empresa_id
                       );
      --
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenerico_id
                          , est_log_generico  => est_log_generico
                          );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_row_param_dipamgia.empresa_id,0) > 0
    and nvl(est_row_param_dipamgia.cfop_id,0) > 0 then
      --
      vn_fase := 99.1;
      --
      begin
         pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
      exception
       when others then
         null;
      end;
      --
      est_row_param_dipamgia.id := pk_csf.fkg_paramdipamgia_id ( en_empresa_id  => est_row_param_dipamgia.empresa_id
                                                               , en_dipamgia_id => est_row_param_dipamgia.dipamgia_id
                                                               , en_cfop_id     => est_row_param_dipamgia.cfop_id
                                                               , en_item_id     => est_row_param_dipamgia.item_id
                                                               , en_ncm_id      => est_row_param_dipamgia.ncm_id
                                                               );
      --
      if nvl(est_row_param_dipamgia.id,0) = 0 then
         --
         vn_fase := 99.2;
         --
         select paramdipamgia_seq.nextval
           into est_row_param_dipamgia.id
           from dual;
         --
         insert into param_dipamgia ( id
                                    , empresa_id
                                    , dipamgia_id
                                    , cfop_id
                                    , item_id
                                    , ncm_id
                                    , perc_rateio_item )
                              values( est_row_param_dipamgia.id
                                    , est_row_param_dipamgia.empresa_id
                                    , est_row_param_dipamgia.dipamgia_id
                                    , est_row_param_dipamgia.cfop_id
                                    , est_row_param_dipamgia.item_id
                                    , est_row_param_dipamgia.ncm_id
                                    , est_row_param_dipamgia.perc_rateio_item
                                    );
         --
      else
         --
         vn_fase := 99.3;
         --
         update param_dipamgia
            set empresa_id       = est_row_param_dipamgia.empresa_id
              , dipamgia_id      = est_row_param_dipamgia.dipamgia_id
              , cfop_id          = est_row_param_dipamgia.cfop_id
              , item_id          = est_row_param_dipamgia.item_id
              , ncm_id           = est_row_param_dipamgia.ncm_id
              , perc_rateio_item = est_row_param_dipamgia.perc_rateio_item
          where id          = est_row_param_dipamgia.id;
         --
      end if;
      --
      commit;
      --
    else
      --
      vn_fase := 99.4;
      --
      gv_mensagem_log := 'Layout da tabela de Parametros da DIPAM-GIA inválido(Informação obrigatória vazia ou inválida), favor verificar.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenerico_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia
                       );
      --
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenerico_id
                          , est_log_generico  => est_log_generico
                          );
      --
   end if;
   --
exception
   when others then
      --
      est_row_param_dipamgia := null;
      --
      gv_mensagem_log := 'Erro na pk_csf_api_secf.pkb_integr_param_dipamgia fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenerico_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_SISTEMA
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              );
      exception
         when others then
            null;
      end;
      --
end pkb_integr_param_dipamgia;

--------------------------------------------------------------------------------------------------------------------------

-- Procedimento integra os dados do complemento do Item
procedure pkb_integr_item_compl ( est_log_generico          in out nocopy  dbms_sql.number_table
                                , est_item_compl            in out nocopy  item_compl%rowtype
                                , en_item_id                in             number
                                , ev_codst_csosn            in             varchar2
                                , ev_codst_icms             in             varchar2
                                , ev_codst_ipi_entrada      in             varchar2
                                , ev_codst_ipi_saida        in             varchar2
                                , ev_codst_pis_entrada      in             varchar2
                                , ev_codst_pis_saida        in             varchar2
                                , ev_codst_cofins_entrada   in             varchar2
                                , ev_codst_cofins_saida     in             varchar2
                                , ev_natrecpc_pis           in             varchar2
                                , ev_natrecpc_cofins        in             varchar2
                                , en_multorg_id             in             mult_org.id%type
 )
is
   --
   vn_fase            number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   est_item_compl.item_id := en_item_id;
   --
   if nvl(est_item_compl.item_id,0) <= 0 then
      --
      vn_fase := 1.1;
      --
      gv_mensagem_log := 'Identificador do item inválido.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id         => gt_row_item.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2;
   --
   est_item_compl.codst_id_csosn := pk_csf.fkg_Cod_ST_id(ev_cod_st => ev_codst_csosn, en_tipoimp_id => 10);
   --
   vn_fase := 3;
   --
   est_item_compl.codst_id_icms := pk_csf.fkg_Cod_ST_id(ev_cod_st => ev_codst_icms, en_tipoimp_id => 1);
   --
   vn_fase := 4;
   --
   est_item_compl.codst_id_ipi_entrada := pk_csf.fkg_Cod_ST_id(ev_cod_st => ev_codst_ipi_entrada, en_tipoimp_id => 3);
   --
   vn_fase := 5;
   --
   est_item_compl.codst_id_ipi_saida := pk_csf.fkg_Cod_ST_id(ev_cod_st => ev_codst_ipi_saida, en_tipoimp_id => 3);
   --
   vn_fase := 6;
   --
   est_item_compl.codst_id_pis_entrada := pk_csf.fkg_Cod_ST_id(ev_cod_st => ev_codst_pis_entrada, en_tipoimp_id => 4);
   --
   vn_fase := 7;
   --
   est_item_compl.codst_id_pis_saida := pk_csf.fkg_Cod_ST_id(ev_cod_st => ev_codst_pis_saida, en_tipoimp_id => 4);
   --
   vn_fase := 8;
   --
   est_item_compl.codst_id_cofins_entrada := pk_csf.fkg_Cod_ST_id(ev_cod_st => ev_codst_cofins_entrada, en_tipoimp_id => 5);
   --
   vn_fase := 10;
   --
   est_item_compl.codst_id_cofins_saida := pk_csf.fkg_Cod_ST_id(ev_cod_st => ev_codst_cofins_saida, en_tipoimp_id => 5);
   --
   vn_fase := 11;
   --
   est_item_compl.natrecpc_id_pis := pk_csf_efd_pc.fkg_codst_id_nat_rec_pc ( en_multorg_id         => en_multorg_id
                                                                           , en_natrecpc_codst_id  => est_item_compl.codst_id_pis_saida
                                                                           , en_natrecpc_cod       => ev_natrecpc_pis
                                                                           );
   --
   if nvl(est_item_compl.natrecpc_id_pis,0) <= 0 then
      est_item_compl.natrecpc_id_pis := null;
   end if;
   --
   vn_fase := 12;
   --
   est_item_compl.natrecpc_id_cofins := pk_csf_efd_pc.fkg_codst_id_nat_rec_pc ( en_multorg_id         => en_multorg_id
                                                                              , en_natrecpc_codst_id  => est_item_compl.codst_id_cofins_saida
                                                                              , en_natrecpc_cod       => ev_natrecpc_cofins
                                                                              );
   --
   if nvl(est_item_compl.natrecpc_id_cofins,0) <= 0 then
      est_item_compl.natrecpc_id_cofins := null;
   end if;
   --
   vn_fase := 13;
   --
   if nvl(est_item_compl.per_red_bc_icms,0) < 0 then
      --
      vn_fase := 13.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Percentual de redução de base de cálculo para o ICMS" não pode ser negativo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id         => gt_row_item.empresa_id
                                  );

      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );


   end if;
   --
   vn_fase := 14;
   --
   if nvl(est_item_compl.vl_bc_icms_st,0) < 0 then
      --
      vn_fase := 14.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Valor unitario de base de cálculo do ICMS ST" não pode ser negativo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id         => gt_row_item.empresa_id
                                  );

      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );


   end if;
   --
   vn_fase := 15;
   --
   if nvl(est_item_compl.aliq_ipi,0) < 0 then
      --
      vn_fase := 15.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Alíquota do IPI" não pode ser negativo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id         => gt_row_item.empresa_id
                                  );

      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );


   end if;
   --
   vn_fase := 16;
   --
   if nvl(est_item_compl.aliq_pis,0) < 0 then
      --
      vn_fase := 16.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Alíquota do PIS" não pode ser negativo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id         => gt_row_item.empresa_id
                                  );

      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );

   end if;
   --
   vn_fase := 17;
   --
   if nvl(est_item_compl.aliq_iss,0) < 0 then
      --
      vn_fase := 17.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Alíquota do ISS" não pode ser negativo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id         => gt_row_item.empresa_id
                                  );

      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );

   end if;
   --
   vn_fase := 18;
   --
   if nvl(est_item_compl.aliq_cofins,0) < 0 then
      --
      vn_fase := 18.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Alíquota do COFINS" não pode ser negativo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id         => gt_row_item.empresa_id
                                  );

      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );

   end if;
   --
   vn_fase := 19;
   --
   if nvl(est_item_compl.vl_est_venda,0) < 0 then
      --
      vn_fase := 19.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Cadastre o Valor da "Venda do Item estimado". Esse valor não pode ser menor que zero e ser for zerado pode dar erro de cálculo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao --ERRO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_item.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   elsif nvl(est_item_compl.vl_est_venda,0) = 0 then
      --
      vn_fase := 19.2;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O Valor da "Venda do Item estimado" está zerado, isso pode gerar erro nos cálculos quando não houver nota de saída do item. Verifique!';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => informacao -- INFORMACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_item.empresa_id
                           );
      --
   end if;
   --
   vn_fase := 99;
   --
   if pk_csf.fkg_existe_item_compl( est_item_compl.Item_Id ) = true then
    --
      update item_compl
       set codst_id_csosn            = est_item_compl.codst_id_csosn
         , codst_id_icms             = est_item_compl.codst_id_icms
         , per_red_bc_icms           = est_item_compl.per_red_bc_icms
         , vl_bc_icms_st             = est_item_compl.vl_bc_icms_st
         , codst_id_ipi_entrada      = est_item_compl.codst_id_ipi_entrada
         , codst_id_ipi_saida        = est_item_compl.codst_id_ipi_saida
         , aliq_ipi                  = est_item_compl.aliq_ipi
         , codst_id_pis_entrada      = est_item_compl.codst_id_pis_entrada
         , codst_id_pis_saida        = est_item_compl.codst_id_pis_saida
         , natrecpc_id_pis           = est_item_compl.natrecpc_id_pis
         , aliq_pis                  = est_item_compl.aliq_pis
         , codst_id_cofins_entrada   = est_item_compl.codst_id_cofins_entrada
         , codst_id_cofins_saida     = est_item_compl.codst_id_cofins_saida
         , natrecpc_id_cofins        = est_item_compl.natrecpc_id_cofins
         , aliq_iss                  = est_item_compl.aliq_iss
         , aliq_cofins               = est_item_compl.aliq_cofins
         , cod_cta                   = est_item_compl.cod_cta
         , observacao                = est_item_compl.observacao
         , vl_est_venda              = est_item_compl.vl_est_venda
       where item_id = est_item_compl.Item_Id;
      --
   else
      --
      vn_fase := 99.2;
      --
      insert into item_compl    ( item_id
                                , codst_id_csosn
                                , codst_id_icms
                                , per_red_bc_icms
                                , vl_bc_icms_st
                                , codst_id_ipi_entrada
                                , codst_id_ipi_saida
                                , aliq_ipi
                                , codst_id_pis_entrada
                                , codst_id_pis_saida
                                , natrecpc_id_pis
                                , aliq_pis
                                , codst_id_cofins_entrada
                                , codst_id_cofins_saida
                                , natrecpc_id_cofins
                                , aliq_iss
                                , aliq_cofins
                                , cod_cta
                                , observacao
                                , vl_est_venda
                                 )
                          values ( est_item_compl.item_id
                                 , est_item_compl.codst_id_csosn
                                 , est_item_compl.codst_id_icms
                                 , est_item_compl.per_red_bc_icms
                                 , est_item_compl.vl_bc_icms_st
                                 , est_item_compl.codst_id_ipi_entrada
                                 , est_item_compl.codst_id_ipi_saida
                                 , est_item_compl.aliq_ipi
                                 , est_item_compl.codst_id_pis_entrada
                                 , est_item_compl.codst_id_pis_saida
                                 , est_item_compl.natrecpc_id_pis
                                 , est_item_compl.aliq_pis
                                 , est_item_compl.codst_id_cofins_entrada
                                 , est_item_compl.codst_id_cofins_saida
                                 , est_item_compl.natrecpc_id_cofins
                                 , est_item_compl.aliq_iss
                                 , est_item_compl.aliq_cofins
                                 , est_item_compl.cod_cta
                                 , est_item_compl.observacao
                                 , est_item_compl.vl_est_venda
                                 );
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_item_compl fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia
                                     , en_empresa_id      => gt_row_item.empresa_id
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_item_compl;

-------------------------------------------------------------------------------------------------------

-- Procedimento de integração de dados do Controle de Versão Contábil

procedure pkb_integr_ctrl_ver_contab ( est_log_generico        in out nocopy  dbms_sql.number_table
                                     , est_ctrl_ver_contab     in out nocopy  ctrl_versao_contabil%rowtype
                                     , en_multorg_id           in             mult_org.id%type 
                                     , ev_cpf_cnpj_emit        in             varchar2
                                     )
is
   --
   vn_fase            number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   gv_obj_referencia := 'CTRL_VERSAO_CONTABIL';
   -- Montagem o cabeçalho da mensgagem de log
   gv_cabec_log := 'Empresa: ' || ev_cpf_cnpj_emit || ' Código: ' || est_ctrl_ver_contab.cd || ' Tipo: ' || est_ctrl_ver_contab.dm_tipo;
   --
   vn_fase := 2;
   -- Recupera o ID da empresa a partir do CNPJ
   est_ctrl_ver_contab.empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id  => en_multorg_id
                                                                         , ev_cpf_cnpj    => ev_cpf_cnpj_emit
                                                                         );
   --
   if nvl(est_ctrl_ver_contab.empresa_id,0) <= 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Empresa não encontrada (' || ev_cpf_cnpj_emit || ')';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id         => est_ctrl_ver_contab.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   -- Recupera o ID do Controle de Versão Contábil
   est_ctrl_ver_contab.id := pk_csf.fkg_ctrlversaocontabil_id ( en_empresa_id  => est_ctrl_ver_contab.empresa_id
                                                              , ev_cd          => est_ctrl_ver_contab.cd
                                                              , en_dm_tipo     => est_ctrl_ver_contab.dm_tipo
                                                              );
   --
   vn_fase := 3.1;
   --
   if nvl(est_ctrl_ver_contab.id,0) <= 0 then
      --
      select ctrlversaocontabil_seq.nextval
        into est_ctrl_ver_contab.id
        from dual;
      --
   end if;
   --
   gn_referencia_id := est_ctrl_ver_contab.id;
   --
   delete from log_generico_cad
    where REFERENCIA_ID = gn_referencia_id
      and OBJ_REFERENCIA = gv_obj_referencia;
   --
   --| Valida os dados do Controle de Versão Contábil
   --
   vn_fase := 4;
   -- Código da Versão:
   if est_ctrl_ver_contab.cd is null then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Código da versão não pode ser nulo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id         => est_ctrl_ver_contab.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   -- Descrição:
   if est_ctrl_ver_contab.descr is null then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Descrição não pode ser nula.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id         => est_ctrl_ver_contab.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 6;
   -- Tipo:
   if est_ctrl_ver_contab.dm_tipo not in ('1','2') then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Tipo (' || est_ctrl_ver_contab.dm_tipo || ') inválido, tipo deve ser: 1-Plano de Contas; 2-Centro de Custos.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id         => est_ctrl_ver_contab.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 7;
   -- Data inicial:
   if est_ctrl_ver_contab.dt_ini is null then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Data inicial não pode ser nula.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem        => gv_cabec_log
                           , ev_resumo          => gv_mensagem_log
                           , en_tipo_log        => ERRO_DE_VALIDACAO
                           , en_referencia_id   => gn_referencia_id
                           , ev_obj_referencia  => gv_obj_referencia
                           , en_empresa_id         => est_ctrl_ver_contab.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 8;
   -- Data final:
   if est_ctrl_ver_contab.dt_fin < est_ctrl_ver_contab.dt_ini then
      --
      vn_fase := 8.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Data final não pode ser menor que a data inicial.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem        => gv_cabec_log
                           , ev_resumo          => gv_mensagem_log
                           , en_tipo_log        => ERRO_DE_VALIDACAO
                           , en_referencia_id   => gn_referencia_id
                           , ev_obj_referencia  => gv_obj_referencia
                           , en_empresa_id         => est_ctrl_ver_contab.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 9;
   --
   if nvl(est_ctrl_ver_contab.empresa_id,0) > 0
      and est_ctrl_ver_contab.cd is not null
      and est_ctrl_ver_contab.dm_tipo in ('1','2')
      then
      --
      vn_fase := 9.2;
      --
      -- Calcula a quantidade de registros totais integrados para ser
      -- mostrado na tela de agendamento.
      --
      begin
         pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
      exception
         when others then
         null;
      end;
      --
      if pk_csf.fkg_existe_ctrlversaocontabil ( en_ctrlversaocontabil_id => est_ctrl_ver_contab.id ) = true then
         --
         vn_fase := 9.3;
         --
         update ctrl_versao_contabil set empresa_id = est_ctrl_ver_contab.empresa_id
                                       , cd         = est_ctrl_ver_contab.cd
                                       , descr      = est_ctrl_ver_contab.descr
                                       , dm_tipo    = est_ctrl_ver_contab.dm_tipo
                                       , dt_ini     = est_ctrl_ver_contab.dt_ini
                                       , dt_fin     = est_ctrl_ver_contab.dt_fin
          where id = est_ctrl_ver_contab.id;
         --
      else
         --
         vn_fase := 9.4;
         --
         insert into ctrl_versao_contabil ( id
                                          , empresa_id
                                          , cd        
                                          , descr     
                                          , dm_tipo   
                                          , dt_ini    
                                          , dt_fin
                                          )
                                   values ( est_ctrl_ver_contab.id        
                                          , est_ctrl_ver_contab.empresa_id
                                          , est_ctrl_ver_contab.cd        
                                          , est_ctrl_ver_contab.descr     
                                          , est_ctrl_ver_contab.dm_tipo   
                                          , est_ctrl_ver_contab.dt_ini    
                                          , est_ctrl_ver_contab.dt_fin
                                          );
         --
      end if;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_ctrl_ver_contab fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_SISTEMA
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => est_ctrl_ver_contab.empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_ctrl_ver_contab;

-------------------------------------------------------------------------------------------------------

-- Procedimento de integração da Aglutinação Contabil
procedure pkb_integr_aglutcontabil ( est_log_generico      in out nocopy dbms_sql.number_table
                                   , est_row_aglutcontabil in out nocopy aglut_contabil%rowtype
                                   , ev_cnpj_empr          in            varchar2
                                   , en_multorg_id         in            mult_org.id%type
                                   , ev_cod_nat            in            varchar2
                                   , ev_ar_cod_agl         in            varchar2
                                   , en_loteintws_id       in            lote_int_ws.id%type default 0
                                   )
is
   --
   vn_fase              number := 0;
   vn_loggenericocad_id log_generico_cad.id%type;
   vn_empresa_id        empresa.id%type;
   vv_nro_lote          varchar2(50);
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'AGLUT_CONTABIL';
   -- Montagem o cabeçalho da mensgagem de log
   gv_cabec_log := 'Aglutinação Contábil: ' || est_row_aglutcontabil.cod_agl || vv_nro_lote;
   est_row_aglutcontabil.empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id  => en_multorg_id
                                                                           , ev_cpf_cnpj    => ev_cnpj_empr
                                                                           );
   --
   if nvl(est_row_aglutcontabil.empresa_id,0) <= 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Verificar o CPF/CNPJ do emitente ('|| ev_cnpj_empr ||') valor inválido.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_aglutcontabil.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2;
   --
   est_row_aglutcontabil.codnatpc_id := pk_csf.fkg_codnatpc_id ( ev_cod_nat => ev_cod_nat );
   --
   if nvl(est_row_aglutcontabil.codnatpc_id,0) <= 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O Valor do Campo "COD_NAT" ('|| ev_cod_nat ||') inválido, não encontrado na base Compliance, favor verificar.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_aglutcontabil.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   if trim(est_row_aglutcontabil.cod_agl) is null then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O Valor do Campo "COD_AGL" ('|| est_row_aglutcontabil.cod_agl ||') não pode ser vazio, favor verificar.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_aglutcontabil.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   --
   if trim(est_row_aglutcontabil.descr_agl) is null then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O Valor do Campo "DESCR_AGL" ('|| est_row_aglutcontabil.descr_agl ||') não pode ser vazio, favor verificar.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_aglutcontabil.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   --
   if nvl(est_row_aglutcontabil.nivel,0) <= 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O Valor do Campo "NIVEL" ('|| est_row_aglutcontabil.descr_agl ||') não pode ser menor ou igual a zero, favor verificar.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_aglutcontabil.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 6;
   --
   if trim(est_row_aglutcontabil.dm_ind_cta) not in ('A','S') then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O valor do Domínio Indicador de Conta inválido ('||trim(est_row_aglutcontabil.dm_ind_cta)||
                         '), valores válidos: "A" - Analitico e "S" - Sintético.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_aglutcontabil.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 7;
   --
   if trim(ev_ar_cod_agl) is not null then
      --
      est_row_aglutcontabil.ar_aglutcontabil_id := pk_csf.fkg_aglutcontabil_id ( en_empresa_id => est_row_aglutcontabil.empresa_id
                                                                               , ev_cod_agl    => ev_ar_cod_agl );
      --
      if nvl(est_row_aglutcontabil.ar_aglutcontabil_id,0) <= 0 then
         --
         gv_mensagem_log := null;
         --
         gv_mensagem_log := 'O valor do campo "AR_COD_AGL" inválida ('|| ev_ar_cod_agl
                            ||') código inválido ou não cadastrado no Compliance, favor verificar.';
         --
         vn_loggenericocad_id := null;
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_VALIDACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => est_row_aglutcontabil.empresa_id
                              );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                 , est_log_generico  => est_log_generico );
         --
      end if;
      --
   end if;
   --
   vn_fase := 8;
   --
   if trim(est_row_aglutcontabil.dt_ini) is null then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O valor do campo "DT_INI" Não pode ser vazia, favor verificar.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_aglutcontabil.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   if trim(est_row_aglutcontabil.dt_fin) is not null then
      --
      if est_row_aglutcontabil.dt_ini > est_row_aglutcontabil.dt_fin then
         --
         gv_mensagem_log := 'O valor do campo "DT_INI" Não pode ser maior que a "DT_FIN", favor verificar.';
         --
         vn_loggenericocad_id := null;
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_VALIDACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => est_row_aglutcontabil.empresa_id
                              );
         --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );  
         --
      end if;
      --
   end if;
   --
   if nvl(est_row_aglutcontabil.empresa_id,0) > 0
    and nvl(est_row_aglutcontabil.CODNATPC_ID,0) > 0
    and nvl(est_row_aglutcontabil.NIVEL,0) > 0
    and trim(est_row_aglutcontabil.COD_AGL) is not null
    and trim(est_row_aglutcontabil.DESCR_AGL) is not null
    and trim(est_row_aglutcontabil.DM_IND_CTA) is not null
    and trim(est_row_aglutcontabil.DT_INI) is not null then
      --
      est_row_aglutcontabil.id := pk_csf.fkg_aglutcontabil_id ( en_empresa_id  => est_row_aglutcontabil.empresa_id
                                                              , ev_cod_agl     => est_row_aglutcontabil.cod_agl
                                                              );
      --
      if nvl(est_row_aglutcontabil.id,0) <= 0 then
         --
         select aglutcontabil_seq.nextval
           into est_row_aglutcontabil.id
           from dual;
         --
         insert into aglut_contabil ( id
                                    , empresa_id
                                    , codnatpc_id
                                    , cod_agl
                                    , descr_agl
                                    , nivel
                                    , dm_ind_cta
                                    , ar_aglutcontabil_id
                                    , dt_ini
                                    , dt_fin
                                    , dm_st_proc )
                              values( est_row_aglutcontabil.id
                                    , est_row_aglutcontabil.empresa_id
                                    , est_row_aglutcontabil.codnatpc_id
                                    , est_row_aglutcontabil.cod_agl
                                    , est_row_aglutcontabil.descr_agl
                                    , est_row_aglutcontabil.nivel
                                    , est_row_aglutcontabil.dm_ind_cta
                                    , est_row_aglutcontabil.ar_aglutcontabil_id
                                    , est_row_aglutcontabil.dt_ini
                                    , est_row_aglutcontabil.dt_fin
                                    , est_row_aglutcontabil.dm_st_proc );
         --
      else
         --
         update aglut_contabil
            set empresa_id            = est_row_aglutcontabil.empresa_id
              , codnatpc_id           = est_row_aglutcontabil.codnatpc_id
              , cod_agl               = est_row_aglutcontabil.cod_agl            
              , descr_agl             = est_row_aglutcontabil.descr_agl          
              , nivel                 = est_row_aglutcontabil.nivel              
              , dm_ind_cta            = est_row_aglutcontabil.dm_ind_cta         
              , ar_aglutcontabil_id   = est_row_aglutcontabil.ar_aglutcontabil_id
              , dt_ini                = est_row_aglutcontabil.dt_ini
              , dt_fin                = est_row_aglutcontabil.dt_fin             
              , dm_st_proc            = est_row_aglutcontabil.dm_st_proc
          where id                    = est_row_aglutcontabil.id;
         --
      end if;
      --
      commit;
      --
    end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_aglutcontabil fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_sistema
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => est_row_aglutcontabil.empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_aglutcontabil;

-------------------------------------------------------------------------------------------------

-- Processo de leitura dos Parâmetros DE-PARA de Item de Fornecedor para Emp. Usuária
procedure pkb_integr_param_item_entr ( est_log_generico      in out nocopy dbms_sql.number_table
                                     , est_row_paramitementr in out nocopy param_item_entr%rowtype
                                     )
is
   --
   vn_fase number;
   --
   vn_loggenericocad_id  log_generico_cad.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if est_row_paramitementr.empresa_id is null then
      --
      gv_mensagem_log := 'Campo relacionado a empresa, não pode ser nulo.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_sistema
                           , en_referencia_id      => null
                           , ev_obj_referencia     => 'PARAM_ITEM_ENTR'
                           , en_empresa_id         => est_row_paramitementr.empresa_id
                           , en_dm_impressa        => 0
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico 
                              );
      --
   end if;
   --
   vn_fase := 2;
   --
   if est_row_paramitementr.cnpj_orig is null then
      --
      gv_mensagem_log := 'Campo CNPJ de origem não pode ser nulo';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_sistema
                           , en_referencia_id      => null
                           , ev_obj_referencia     => 'PARAM_ITEM_ENTR'
                           , en_empresa_id         => est_row_paramitementr.empresa_id
                           , en_dm_impressa        => 0
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico 
                              );
      --
   end if;
   --
   if est_row_paramitementr.item_id_dest is null then
      --
      gv_mensagem_log := 'Campo referente ao identificador do item não pode ser nulo.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_sistema
                           , en_referencia_id      => null
                           , ev_obj_referencia     => 'PARAM_ITEM_ENTR'
                           , en_empresa_id         => est_row_paramitementr.empresa_id
                           , en_dm_impressa        => 0
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico 
                              );
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_row_paramitementr.empresa_id, 0) > 0
     and est_row_paramitementr.cnpj_orig is not null
     and est_row_paramitementr.item_id_dest is not null then
      --
      est_row_paramitementr.id := pk_csf.fkg_paramitementr_id ( en_empresa_id    => est_row_paramitementr.empresa_id
                                                              , ev_cnpj_orig     => est_row_paramitementr.cnpj_orig
                                                              , en_ncm_id_orig   => est_row_paramitementr.ncm_id_orig
                                                              , ev_cod_item_orig => est_row_paramitementr.cod_item_orig
                                                              , en_item_id_dest  => est_row_paramitementr.item_id_dest
                                                              );
      --
      vn_fase := 4;
      --
      if nvl(est_row_paramitementr.id, 0) <= 0 then
         --
         select paramitementr_seq.nextval
           into est_row_paramitementr.id
           from dual;
         --
         insert into param_item_entr ( id
                                     , empresa_id
                                     , cnpj_orig
                                     , ncm_id_orig
                                     , cod_item_orig
                                     , item_id_dest
                                     )
                              values ( est_row_paramitementr.id
                                     , est_row_paramitementr.empresa_id
                                     , est_row_paramitementr.cnpj_orig
                                     , est_row_paramitementr.ncm_id_orig
                                     , est_row_paramitementr.cod_item_orig
                                     , est_row_paramitementr.item_id_dest
                                     );
         --
      else
         --
         update param_item_entr
            set empresa_id    = est_row_paramitementr.empresa_id
              , cnpj_orig     = est_row_paramitementr.cnpj_orig
              , ncm_id_orig   = est_row_paramitementr.ncm_id_orig
              , cod_item_orig = est_row_paramitementr.cod_item_orig
              , item_id_dest  = est_row_paramitementr.item_id_dest
          where id = est_row_paramitementr.id;
         --
      end if;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      begin
         --
         gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_intgr_param_item_entr fase('||vn_fase||'): '||sqlerrm;
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_sistema
                              , en_referencia_id      => null
                              , ev_obj_referencia     => 'PARAM_ITEM_ENTR'
                              , en_empresa_id         => est_row_paramitementr.empresa_id
                              , en_dm_impressa        => 0
                              );
         --
      exception
         when others then
            --
            null;
            --
      end;
      --
end pkb_integr_param_item_entr;

-------------------------------------------------------------------------------------------------------

--| Parâmetros de conversão de nfe
procedure pkb_integr_param_oper_entr ( est_log_generico      in out nocopy dbms_sql.number_table
                                     , est_row_paramoperentr in out param_oper_fiscal_entr%rowtype
                                     )
is
   --
   vn_fase number;
   --
   vn_loggenericocad_id  log_generico_cad.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if est_row_paramoperentr.empresa_id is null then
      --
      gv_mensagem_log := 'Campo relacionado a empresa, no pode ser nulo.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_sistema
                           , en_referencia_id      => null
                           , ev_obj_referencia     => 'PARAM_OPER_FISCAL_ENTR'
                           , en_empresa_id         => est_row_paramoperentr.empresa_id
                           , en_dm_impressa        => 0
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico
                              );
      --
   end if;
   --
   vn_fase := 2;
   --
   if est_row_paramoperentr.cfop_id_orig is null then
      --
      gv_mensagem_log := 'Campo CFOP - Código fiscal de operações de prestações de origem não pode ser nulo.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_sistema
                           , en_referencia_id      => null
                           , ev_obj_referencia     => 'PARAM_OPER_FISCAL_ENTR'
                           , en_empresa_id         => est_row_paramoperentr.empresa_id
                           , en_dm_impressa        => 0
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico
                              );
      --
   end if;
   --
   vn_fase := 3;
   --
   if est_row_paramoperentr.dm_raiz_cnpj_orig not in (0,1) then
      --
      gv_mensagem_log := 'Campo "DM_RAIZ_CNPJ_ORIG" não contem valores válidos. Valores válidos: 0 ou 1.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_sistema
                           , en_referencia_id      => null
                           , ev_obj_referencia     => 'PARAM_OPER_FISCAL_ENTR'
                           , en_empresa_id         => est_row_paramoperentr.empresa_id
                           , en_dm_impressa        => 0
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico
                              );
      --
   end if;
   --
   vn_fase := 4;
   --
   if est_row_paramoperentr.cfop_id_dest is null then
      --
      gv_mensagem_log := 'Campo CFOP - Código fiscal de operações de prestações de destino não pode ser nulo.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_sistema
                           , en_referencia_id      => null
                           , ev_obj_referencia     => 'PARAM_OPER_FISCAL_ENTR'
                           , en_empresa_id         => est_row_paramoperentr.empresa_id
                           , en_dm_impressa        => 0
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico
                              );
      --
   end if;
   --
   vn_fase := 5;
   --
   if est_row_paramoperentr.dm_rec_icms not in(0,1) then
      --
      gv_mensagem_log := ' Campo "DM_REC_ICMS" não contem valores válidos. Valores válidos 0 ou 1.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_sistema
                           , en_referencia_id      => null
                           , ev_obj_referencia     => 'PARAM_OPER_FISCAL_ENTR'
                           , en_empresa_id         => est_row_paramoperentr.empresa_id
                           , en_dm_impressa        => 0
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico
                              );
      --
   end if;
   --
   vn_fase := 6;
   --
   if est_row_paramoperentr.dm_rec_ipi not in(0,1) then
      --
      gv_mensagem_log := ' Campo "DM_REC_IPI" não contem valores válidos. Valores válidos 0 ou 1.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_sistema
                           , en_referencia_id      => null
                           , ev_obj_referencia     => 'PARAM_OPER_FISCAL_ENTR'
                           , en_empresa_id         => est_row_paramoperentr.empresa_id
                           , en_dm_impressa        => 0
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico
                              );
      --
   end if;
   --
   vn_fase := 7;
   --
   if est_row_paramoperentr.dm_rec_pis not in(0,1) then
      --
      gv_mensagem_log := ' Campo "DM_REC_PIS" não contem valores válidos. Valores válidos 0 ou 1.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_sistema
                           , en_referencia_id      => null
                           , ev_obj_referencia     => 'PARAM_OPER_FISCAL_ENTR'
                           , en_empresa_id         => est_row_paramoperentr.empresa_id
                           , en_dm_impressa        => 0
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico
                              );
      --
   end if;
   --
   vn_fase := 8;
   --
   if est_row_paramoperentr.dm_rec_cofins not in(0,1) then
      --
      gv_mensagem_log := ' Campo "DM_REC_COFINS" não contem valores válidos. Valores válidos 0 ou 1.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_sistema
                           , en_referencia_id      => null
                           , ev_obj_referencia     => 'PARAM_OPER_FISCAL_ENTR'
                           , en_empresa_id         => est_row_paramoperentr.empresa_id
                           , en_dm_impressa        => 0
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico
                              );
      --
   end if;
   --
   vn_fase := 9;
   --
   if nvl(est_row_paramoperentr.empresa_id, 0) > 0
     and nvl(est_row_paramoperentr.cfop_id_orig, 0) > 0
     and est_row_paramoperentr.dm_raiz_cnpj_orig in(0,1)
     and nvl(est_row_paramoperentr.cfop_id_dest, 0) > 0
     and est_row_paramoperentr.dm_rec_icms in(0,1)
     and est_row_paramoperentr.dm_rec_ipi in(0,1)
     and est_row_paramoperentr.dm_rec_pis in(0,1)
     and est_row_paramoperentr.dm_rec_cofins in(0,1) then
      --
      vn_fase := 10;
      --
      est_row_paramoperentr.id := pk_csf.fkg_paramoperfiscalentr_id ( en_empresa_id         => est_row_paramoperentr.empresa_id        
                                                                    , en_cfop_id_orig       => est_row_paramoperentr.cfop_id_orig      
                                                                    , ev_cnpj_orig          => est_row_paramoperentr.cnpj_orig
                                                                    , en_ncm_id_orig        => est_row_paramoperentr.ncm_id_orig       
                                                                    , en_item_id_orig       => est_row_paramoperentr.item_id_orig      
                                                                    , en_codst_id_icms_orig => est_row_paramoperentr.codst_id_icms_orig
                                                                    , en_codst_id_ipi_orig  => est_row_paramoperentr.codst_id_ipi_orig
                                                                    );
      --
      vn_fase := 11;
      --
      if nvl(est_row_paramoperentr.id, 0) <= 0 then
         --
         vn_fase := 12;
         --
         select paramoperfiscalentr_seq.nextval
           into est_row_paramoperentr.id
           from dual;
         --
         insert into param_oper_fiscal_entr ( id
                                            , empresa_id
                                            , cfop_id_orig
                                            , cnpj_orig
                                            , dm_raiz_cnpj_orig
                                            , item_id_orig
                                            , codst_id_icms_orig
                                            , codst_id_ipi_orig
                                            , cfop_id_dest
                                            , dm_rec_icms
                                            , codst_id_icms_dest
                                            , dm_rec_ipi
                                            , codst_id_ipi_dest
                                            , dm_rec_pis
                                            , codst_id_pis_dest
                                            , dm_rec_cofins
                                            , codst_id_cofins_dest
                                            , ncm_id_orig
                                            )
                                     values ( est_row_paramoperentr.id
                                            , est_row_paramoperentr.empresa_id
                                            , est_row_paramoperentr.cfop_id_orig        
                                            , est_row_paramoperentr.cnpj_orig           
                                            , est_row_paramoperentr.dm_raiz_cnpj_orig   
                                            , est_row_paramoperentr.item_id_orig        
                                            , est_row_paramoperentr.codst_id_icms_orig  
                                            , est_row_paramoperentr.codst_id_ipi_orig   
                                            , est_row_paramoperentr.cfop_id_dest        
                                            , est_row_paramoperentr.dm_rec_icms         
                                            , est_row_paramoperentr.codst_id_icms_dest  
                                            , est_row_paramoperentr.dm_rec_ipi          
                                            , est_row_paramoperentr.codst_id_ipi_dest   
                                            , est_row_paramoperentr.dm_rec_pis          
                                            , est_row_paramoperentr.codst_id_pis_dest   
                                            , est_row_paramoperentr.dm_rec_cofins       
                                            , est_row_paramoperentr.codst_id_cofins_dest
                                            , est_row_paramoperentr.ncm_id_orig
                                            );
         --
      else
         --
         update param_oper_fiscal_entr
            set  empresa_id            = est_row_paramoperentr.empresa_id
                , cfop_id_orig         = est_row_paramoperentr.cfop_id_orig
                , cnpj_orig            = est_row_paramoperentr.cnpj_orig
                , dm_raiz_cnpj_orig    = est_row_paramoperentr.dm_raiz_cnpj_orig
                , item_id_orig         = est_row_paramoperentr.item_id_orig
                , codst_id_icms_orig   = est_row_paramoperentr.codst_id_icms_orig
                , codst_id_ipi_orig    = est_row_paramoperentr.codst_id_ipi_orig
                , cfop_id_dest         = est_row_paramoperentr.cfop_id_dest
                , dm_rec_icms          = est_row_paramoperentr.dm_rec_icms
                , codst_id_icms_dest   = est_row_paramoperentr.codst_id_icms_dest
                , dm_rec_ipi           = est_row_paramoperentr.dm_rec_ipi
                , codst_id_ipi_dest    = est_row_paramoperentr.codst_id_ipi_dest
                , dm_rec_pis           = est_row_paramoperentr.dm_rec_pis
                , codst_id_pis_dest    = est_row_paramoperentr.codst_id_pis_dest
                , dm_rec_cofins        = est_row_paramoperentr.dm_rec_cofins
                , codst_id_cofins_dest = est_row_paramoperentr.codst_id_cofins_dest
                , ncm_id_orig          = est_row_paramoperentr.ncm_id_orig
            where id = est_row_paramoperentr.id;
         --
      end if;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      begin
         --
         gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_param_oper_entr fase('||vn_fase||'): '||sqlerrm;
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_sistema
                              , en_referencia_id      => null
                              , ev_obj_referencia     => 'PARAM_ITEM_ENTR'
                              , en_empresa_id         => est_row_paramoperentr.empresa_id
                              , en_dm_impressa        => 0
                              );
         --
      exception
         when others then
            --
            null;
            --
      end;
      --
end pkb_integr_param_oper_entr;

-------------------------------------------------------------------------------------------------------

-- Procedimento de integrações da tabela PC_AGLUT_CONTABIL
procedure pkb_integr_pcaglutcontabil ( est_log_generico        in out nocopy dbms_sql.number_table
                                     , est_row_pcaglutcontabil in out nocopy pc_aglut_contabil%rowtype
                                     , en_cnpj_empr            in            varchar2
                                     , en_multorg_id           in            mult_org.id%type
                                     , ev_cod_agl              in            aglut_contabil.cod_agl%type
                                     , ev_cod_ccus             in            centro_custo.cod_ccus%type
                                     )
is
   --
   vn_fase               number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%type;
   vn_empresa_id         empresa.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id  => en_multorg_id
                                                        , ev_cpf_cnpj    => en_cnpj_empr
                                                        );
   --
   vn_fase := 2;
   --
   est_row_pcaglutcontabil.aglutcontabil_id := pk_csf.fkg_aglutcontabil_id ( en_empresa_id  => vn_empresa_id
                                                                           , ev_cod_agl     => ev_cod_agl );
   --
   if nvl(est_row_pcaglutcontabil.aglutcontabil_id,0) <= 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O valor do campo "COD_AGL" ('|| ev_cod_agl ||') inválido ou não cadastrado na base Compliace, favor verificar.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   est_row_pcaglutcontabil.centrocusto_id := pk_csf.fkg_Centro_Custo_id ( ev_cod_ccus    => ev_cod_ccus
                                                                        , en_empresa_id  => vn_empresa_id
                                                                        );
   --
   if nvl(est_row_pcaglutcontabil.centrocusto_id,0) <= 0  
   and trim(ev_cod_ccus) is not null then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O valor do campo "COD_CCUS" ('|| ev_cod_ccus ||') inválido ou não cadastrado na base Compliace, favor verificar.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_row_pcaglutcontabil.planoconta_id,0) > 0
    and nvl(est_row_pcaglutcontabil.aglutcontabil_id,0) > 0 then
      --
      est_row_pcaglutcontabil.id := pk_csf.fkg_pcaglutcontabil_id ( en_planoconta_id    => est_row_pcaglutcontabil.planoconta_id
                                                                  , en_aglutcontabil_id => est_row_pcaglutcontabil.aglutcontabil_id
                                                                  , en_centrocusto_id   => est_row_pcaglutcontabil.centrocusto_id );
      --
      if nvl(est_row_pcaglutcontabil.id,0) <= 0 then  
         --
         select pcaglutcontabil_seq.nextval
           into est_row_pcaglutcontabil.id
           from dual;
         --
         insert into pc_aglut_contabil ( id
                                       , planoconta_id
                                       , aglutcontabil_id
                                       , centrocusto_id )
                                 values( est_row_pcaglutcontabil.id
                                       , est_row_pcaglutcontabil.planoconta_id
                                       , est_row_pcaglutcontabil.aglutcontabil_id
                                       , est_row_pcaglutcontabil.centrocusto_id
                                       );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_aglutcontabil fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_sistema
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => gt_row_plano_conta.empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_pcaglutcontabil;
-------------------------------------------------------------------------------------------------------

-- Procedimento de integrações dos Retornos dos itens do FCI
procedure pkb_integr_retornofci ( est_log_generico    in out nocopy dbms_sql.number_table
                                , est_row_retornofci  in out nocopy retorno_fci%rowtype
                                , en_cnpj_empr        in            varchar2
                                , en_multorg_id       in            mult_org.id%type
                                , ev_cod_item         in            item.cod_item%type
                                )
is
   --
   vn_fase               number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%type;
   vn_empresa_id         empresa.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id  => en_multorg_id
                                                        , ev_cpf_cnpj    => en_cnpj_empr
                                                        );
   --
   if nvl(est_row_retornofci.infitemfci_id,0) <= 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Identificador da tabela INF_ITEM_FCI não foi informado, verificar.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_abertura_fci.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2;
   --
   est_row_retornofci.item_id := pk_csf.fkg_Item_id_conf_empr ( en_empresa_id  => vn_empresa_id
                                                              , ev_cod_item    => ev_cod_item );
   --
   if nvl(est_row_retornofci.item_id,0) <= 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O campo "COD_ITEM" inválido ( '||ev_cod_item||' ) informação obrigatória, favor verificar.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_abertura_fci.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   if trim(est_row_retornofci.nro_fci) is null then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O campo "Numero do FCI" da tabela RETORNO_FCI não pode ser nula, favor verificar.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_abertura_fci.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_row_retornofci.item_id,0) > 0
    and nvl(est_row_retornofci.infitemfci_id,0) > 0
    and trim(est_row_retornofci.nro_fci) is not null then
      --
      est_row_retornofci.id := pk_csf.fkg_retornofci_id ( en_item_id       => est_row_retornofci.item_id
                                                        , en_infitemfci_id => est_row_retornofci.infitemfci_id
                                                        );
      --
      if nvl(est_row_retornofci.id,0) <= 0 then
         --
         select retornofci_seq.nextval
           into est_row_retornofci.id
           from dual;
         --
         insert into retorno_fci ( id
                                 , item_id
                                 , infitemfci_id
                                 , nro_fci
                                 , dm_tipo )
                           values( est_row_retornofci.id
                                 , est_row_retornofci.item_id
                                 , est_row_retornofci.infitemfci_id
                                 , est_row_retornofci.nro_fci
                                 , est_row_retornofci.dm_tipo );
         --
      else
         --
         update retorno_fci
            set item_id          = est_row_retornofci.item_id
              , infitemfci_id    = est_row_retornofci.infitemfci_id 
              , nro_fci          = est_row_retornofci.nro_fci       
              , dm_tipo          = est_row_retornofci.dm_tipo
          where id               = est_row_retornofci.id;
         --
      end if;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_retornofci fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_sistema
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => gt_row_abertura_fci.empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_retornofci;

-------------------------------------------------------------------------------------------------------

-- Procedimento de integrações dos itens da Ficha de Conteudo de Importação
procedure pkb_integr_infitemfci ( est_log_generico    in out nocopy dbms_sql.number_table
                                , est_row_infitemfci  in out nocopy inf_item_fci%rowtype
                                , en_cnpj_empr        in            varchar2
                                , en_multorg_id       in            mult_org.id%type
                                , ev_cod_item         in            item.cod_item%type
                                )
is
   --
   vn_fase               number := 0;
   vn_loggenericocad_id  Log_Generico_Cad.id%type;
   vn_empresa_id         empresa.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id  => en_multorg_id
                                                        , ev_cpf_cnpj    => en_cnpj_empr
                                                        );
   --
   if nvl(est_row_infitemfci.aberturafciarq_id,0) <= 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Código da abertura por arquivo do FCI não foi informado';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_abertura_fci.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2;
   --
   if nvl(est_row_infitemfci.vl_saida,0) <= 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Não foi informado a soma da media ponderada de todos os valores de saida (VL_SAIDA), informação obrigatória.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_abertura_fci.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_row_infitemfci.vl_entr_tot,0) <= 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Não foi informado a soma da media ponderada de todos os valores de entrada (VL_ENTR_TOT) do ITEM, informação obrigatória.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_abertura_fci.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   --
   if nvl(est_row_infitemfci.coef_import,0) <= 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O campo "COEF_IMPORT" é obrigatório ('||nvl(est_row_infitemfci.coef_import,0)||
                         '), informação não pode ser menor ou igual a zero.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_abertura_fci.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   --
   est_row_infitemfci.item_id := pk_csf.fkg_Item_id_conf_empr ( en_empresa_id  => vn_empresa_id
                                                              , ev_cod_item    => ev_cod_item );
   --
   if nvl(est_row_infitemfci.item_id,0) <= 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O campo "COD_ITEM" inválido ( '||ev_cod_item||' ) informação obrigatória, favor verificar.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_abertura_fci.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 6;
   --
   if nvl(est_row_infitemfci.aberturafciarq_id,0) > 0
    and nvl(est_row_infitemfci.vl_saida,0) > 0
    and nvl(est_row_infitemfci.vl_entr_tot,0) > 0
    and nvl(est_row_infitemfci.coef_import,0) > 0
    and nvl(est_row_infitemfci.item_id,0) > 0 then
      --
      est_row_infitemfci.id := pk_csf.fkg_infitemfci_id ( en_aberturafciarq_id => est_row_infitemfci.aberturafciarq_id
                                                        , en_item_id           => est_row_infitemfci.item_id 
                                                        );
      --
      if nvl(est_row_infitemfci.id,0) <= 0 then
         --
         select infitemfci_seq.nextval
           into est_row_infitemfci.id
           from dual;
         --
         insert into inf_item_fci ( id
                                  , aberturafciarq_id
                                  , vl_saida
                                  , vl_entr_tot
                                  , coef_import
                                  , item_id
                                  , dm_situacao )
                            values( est_row_infitemfci.id
                                  , est_row_infitemfci.aberturafciarq_id
                                  , est_row_infitemfci.vl_saida
                                  , est_row_infitemfci.vl_entr_tot
                                  , est_row_infitemfci.coef_import
                                  , est_row_infitemfci.item_id
                                  , est_row_infitemfci.dm_situacao );
         --
      else
         --
         update inf_item_fci
            set aberturafciarq_id = est_row_infitemfci.aberturafciarq_id
              , vl_saida          = est_row_infitemfci.vl_saida         
              , vl_entr_tot       = est_row_infitemfci.vl_entr_tot      
              , coef_import       = est_row_infitemfci.coef_import      
              , item_id           = est_row_infitemfci.item_id          
              , dm_situacao       = est_row_infitemfci.dm_situacao
          where id                = est_row_infitemfci.id;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pk_integr_infitemfci fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_sistema
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => gt_row_abertura_fci.empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_infitemfci;

-------------------------------------------------------------------------------------------------------

-- Procedimento de integração da abertura do arquivo do FCI
procedure pkb_integr_aberturafciarq ( est_log_generico       in out nocopy  dbms_sql.number_table
                                    , est_row_aberturafciarq in out nocopy  abertura_fci_arq%rowtype
                                    )
is
   --
   vn_fase                         number := 1;
   vn_loggenericocad_id  Log_Generico_Cad.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(est_row_aberturafciarq.aberturafci_id,0) <= 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Código da abertura do FCI não foi informado';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id         => gt_row_abertura_fci.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2;
   --
   if nvl(est_row_aberturafciarq.nro_sequencia,0) <= 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Numero de sequencia da Abertura do arquivo do FCI, não pode ser menor ou igual a zero.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_abertura_fci.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_row_aberturafciarq.aberturafci_id,0) > 0 then
      --
      vn_fase := 3.1;
      --
      est_row_aberturafciarq.id := pk_csf.pk_aberturafciarq_id ( en_aberturafci_id => est_row_aberturafciarq.aberturafci_id
                                                               , en_nro_sequencia  => est_row_aberturafciarq.nro_sequencia
                                                               );
      --
      if nvl(est_row_aberturafciarq.id,0) <= 0 then
         --
         vn_fase := 3.2;
         --
         select aberturafciarq_seq.nextval
           into est_row_aberturafciarq.id
           from dual;
         --
         insert into abertura_fci_arq ( id
                                      , aberturafci_id
                                      , nro_prot
                                      , nro_sequencia
                                      , dm_situacao )
                               values ( est_row_aberturafciarq.id
                                      , est_row_aberturafciarq.aberturafci_id
                                      , est_row_aberturafciarq.nro_prot
                                      , est_row_aberturafciarq.nro_sequencia
                                      , est_row_aberturafciarq.dm_situacao );

         --
      else
         --
         vn_fase := 3.3;
         --
         update abertura_fci_arq set aberturafci_id = est_row_aberturafciarq.aberturafci_id
                                   , nro_prot       = est_row_aberturafciarq.nro_prot
                                   , nro_sequencia  = est_row_aberturafciarq.nro_sequencia
                                   , dm_situacao    = est_row_aberturafciarq.dm_situacao
                               where id             = est_row_aberturafciarq.id;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pk_integr_aberturafciarq fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_sistema
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => gt_row_abertura_fci.empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_aberturafciarq;

-------------------------------------------------------------------------------------------------------

-- Procedimento de integração dos dados de abertura do FCI
procedure pkb_integr_aberturafci ( est_log_generico    in out nocopy  dbms_sql.number_table 
                                 , est_row_aberturafci in out nocopy  abertura_fci%rowtype
                                 , en_multorg_id       in             mult_org.id%type
                                 , ev_cpf_cnpj_emit    in             varchar2
                                 , en_loteintws_id     in             lote_int_ws.id%type default 0
                                 )
is
   --
   vn_fase              number := 0;
   vv_nro_lote          varchar2(200);
   vn_loggenericocad_id Log_Generico_Cad.id%type;
   --
begin
   --
   --
   vn_fase := 1;
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'ABERTURA_FCI';
   -- Montagem o cabeçalho da mensgagem de log
   gv_cabec_log := 'Empresa: '||ev_cpf_cnpj_emit||' Data Inicial: '||to_date(est_row_aberturafci.dt_ini,'dd/mm/yyyy')||
                   'até a Data Final: '||to_date(est_row_aberturafci.dt_ini,'dd/mm/yyyy') || vv_nro_lote;
   --
   vn_fase := 2;
   -- Recupera o ID da empresa a partir do CNPJ
   est_row_aberturafci.empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id  => en_multorg_id
                                                                         , ev_cpf_cnpj    => ev_cpf_cnpj_emit
                                                                         );
   --
   if nvl(est_row_aberturafci.empresa_id,0) <= 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Empresa não encontrada (' || ev_cpf_cnpj_emit || ')';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => null
                           , ev_obj_referencia     => gv_obj_referencia 
                           , en_empresa_id         => est_row_aberturafci.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2.1;
   --
   est_row_aberturafci.id := pk_csf.fkg_aberturafci_id ( en_empresa_id => est_row_aberturafci.empresa_id
                                                       , ed_dt_ini => est_row_aberturafci.dt_ini
                                                       );
   --
   vn_fase := 2.2;
   --
   if trim(est_row_aberturafci.dt_ini) is not null
    and trim(est_row_aberturafci.dt_fin) is not null then
      --
      if nvl(est_row_aberturafci.id,0) <= 0 then
         --
         select aberturafci_seq.nextval
           into est_row_aberturafci.id
           from dual;
         --
         insert into abertura_fci ( id
                                  , empresa_id
                                  , dt_ini
                                  , dt_fin )
                            values( est_row_aberturafci.id
                                  , est_row_aberturafci.empresa_id  
                                  , est_row_aberturafci.dt_ini      
                                  , est_row_aberturafci.dt_fin );

         --
      else
         --
         update abertura_fci
            set empresa_id = est_row_aberturafci.empresa_id
              , dt_ini     = est_row_aberturafci.dt_ini     
              , dt_fin     = est_row_aberturafci.dt_fin
          where id         = est_row_aberturafci.id;
         --
      end if;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_aberturafci fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_sistema
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => est_row_aberturafci.empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_aberturafci;

-------------------------------------------------------------------------------------------------------

-- Procedimento de integração dos dados de Item Componente/Insumo - Bloco K - Sped Fiscal      
procedure pkb_integr_item_insumo ( est_log_generico    in out nocopy  dbms_sql.number_table
                                 , est_item_insumo     in out nocopy  item_insumo%rowtype
                                 , en_multorg_id       in             mult_org.id%type
                                 , ev_cpf_cnpj_emit    in             varchar2
                                 , ev_cod_item         in             item.cod_item%type
                                 , ev_cod_item_insumo  in             item.cod_item%type
                                 , en_loteintws_id     in             lote_int_ws.id%type default 0
                                 )
is
   --
   vn_fase              number := 0;
   vn_loggenericocad_id Log_Generico_Cad.id%type;
   vn_empresa_id        empresa.id%type;
   vv_nro_lote          varchar2(30) := null;
   --
begin
   --
   vn_fase := 1;
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id  => en_multorg_id
                                                        , ev_cpf_cnpj    => ev_cpf_cnpj_emit
                                                        );
   --
   if nvl(vn_empresa_id,0) <= 0 then
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Empresa não encontrada (' || ev_cpf_cnpj_emit || ')';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => erro_de_validacao
                                  , en_referencia_id   => null
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id         => gt_row_item.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_item_insumo.item_id,0) <= 0 then
      -- Recupera o ID do Item/Produto  
      est_item_insumo.item_id := pk_csf.fkg_item_id_conf_empr( en_empresa_id => vn_empresa_id
                                                             , ev_cod_item   => ev_cod_item 
                                                             );
      --
   end if;
   --
   vn_fase := 4;
   --
   -- Recupera o ID do Item/Componente Insumo
   est_item_insumo.item_id_ins := pk_csf.fkg_item_id_conf_empr( en_empresa_id => vn_empresa_id
                                                              , ev_cod_item   => ev_cod_item_insumo );
   --
   vn_fase := 5;
   -- Recupera o ID do relacionamento de item e item/insumo
   est_item_insumo.id := pk_csf.fkg_item_insumo_id( en_item_id     => est_item_insumo.item_id
                                                  , en_item_id_ins => est_item_insumo.item_id_ins );
   --
   vn_fase := 6;
   -- Verificar se já existe o relacionamento
   if nvl(est_item_insumo.id,0) <= 0 then
      --
      select iteminsumo_seq.nextval
        into est_item_insumo.id
        from dual;
      --
   end if;
   --
   vn_fase := 7;
   --
   gn_referencia_id := est_item_insumo.id;
   --
   vn_fase := 8;
   --
   delete from log_generico_cad
    where referencia_id  = gn_referencia_id
      and obj_referencia = gv_obj_referencia;
   --
   --| Valida os dados do Item Componente/Insumo - Bloco K - Sped Fiscal
   --
   vn_fase := 9;
   -- Código do item
   if nvl(est_item_insumo.item_id,0) = 0 then
      --
      vn_fase := 9.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Código do item ('||ev_cod_item||') não encontrado.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => erro_de_validacao
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id         => gt_row_item.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 10;
   -- Código do item de insumo
   if nvl(est_item_insumo.item_id_ins,0) = 0 then
      --
      vn_fase := 10.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Código do item ('||ev_cod_item_insumo||') não encontrado.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => erro_de_validacao
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia
                                  , en_empresa_id         => gt_row_item.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 11;
   -- Quantidade do item/componente
   if nvl(est_item_insumo.qtd_comp,0) <= 0 then
      --
      vn_fase := 11.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Quantidade do item componente/insumo para produção do item resultante deve ser maior que zero.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => erro_de_validacao
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia 
                                  , en_empresa_id         => gt_row_item.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 12;
   -- Percentual de perda
   if nvl(est_item_insumo.perda,0) < 0 then
      --
      vn_fase := 12.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Percentual de perda/quebra para produção do item resultante deve ser maior ou igual a zero.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => erro_de_validacao
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia 
                                  , en_empresa_id         => gt_row_item.empresa_id
                                  );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                     , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 13;
   --
   if nvl(est_item_insumo.item_id,0) > 0 and
      nvl(est_item_insumo.item_id_ins,0) > 0 and
      nvl(est_item_insumo.qtd_comp,0) > 0 then
      --
      vn_fase := 13.1;
      --
      -- Calcula a quantidade de registros totais integrados para ser
      -- mostrado na tela de agendamento.
      --
      -- begin
      --    pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
      -- exception
      --    when others then
      --    null;
      --end;
      --
      if pk_csf.fkg_existe_iteminsumo( en_iteminsumo_id => est_item_insumo.id ) = true then
         --
         vn_fase := 13.2;
         --
         update item_insumo ii
            set ii.item_id     = est_item_insumo.item_id
              , ii.item_id_ins = est_item_insumo.item_id_ins
              , ii.qtd_comp    = est_item_insumo.qtd_comp
              , ii.perda       = est_item_insumo.perda
          where ii.id = est_item_insumo.id;
         --
      else
         --
         vn_fase := 13.3;
         --
         insert into item_insumo( id
                                , item_id
                                , item_id_ins
                                , qtd_comp
                                , perda
                                )
                         values ( est_item_insumo.id
                                , est_item_insumo.item_id
                                , est_item_insumo.item_id_ins
                                , est_item_insumo.qtd_comp
                                , est_item_insumo.perda
                                );
         --
      end if;
      --
      vn_fase := 13.4;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_item_insumo fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_sistema
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => gt_row_item.empresa_id 
                              );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_item_insumo;

-------------------------------------------------------------------------------------------------------
-- Procedimento integra as informações de Processos Administrativos e Judiciais da EFD REINF
procedure pkb_integr_proc_adm_efd_reinf ( est_log_generico            in out nocopy  dbms_sql.number_table
                                        , est_row_proc_adm_efd_reinf  in out nocopy  proc_adm_efd_reinf%rowtype
                                        , en_multorg_id               in             mult_org.id%type
                                        , ev_cpf_cnpj                 in             varchar2
                                        , ev_ibge_cidade              in             varchar2
                                        , en_loteintws_id             in             lote_int_ws.id%type default 0
                                        )
is
   --
   vn_fase               number := 0;
   vv_nro_lote           varchar2(225) := null;
   vn_loggenericocad_id  log_generico_cad.id%type;
   vn_cont_log           number;
   --
begin
   --
   vn_fase := 1;
   --
   est_row_proc_adm_efd_reinf.empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id  => en_multorg_id
                                                                                , ev_cpf_cnpj    => ev_cpf_cnpj
                                                                                );
   --
   vn_fase := 1.2;
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := 'Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_cabec_log := 'Empresa: '|| pk_csf.fkg_cod_nome_empresa_id (est_row_proc_adm_efd_reinf.empresa_id);
   --
   gv_obj_referencia := 'PROC_ADM_EFD_REINF';
   --
   vn_fase := 1.3;
   --
   gv_cabec_log := gv_cabec_log || chr(13) || 'Data Inicial da Ger.: '|| to_date(est_row_proc_adm_efd_reinf.dt_ini,'dd/mm/yyyy');
   --
   vn_fase := 1.4;
   --
   if est_row_proc_adm_efd_reinf.dt_fin is not null then
      gv_cabec_log := gv_cabec_log || chr(13) || 'Data Final da Ger.: '|| to_date(est_row_proc_adm_efd_reinf.dt_fin,'dd/mm/yyyy');
   end if;
   --
   vn_fase := 1.5;
   --
   gv_cabec_log := gv_cabec_log || chr(13) || 'Tipo de Processo: ' || pk_csf.fkg_dominio ('PROC_ADM_EFD_REINF.DM_TP_PROC', est_row_proc_adm_efd_reinf.dm_tp_proc );
   --
   gv_cabec_log := gv_cabec_log || chr(13) || 'Nro do Processo: ' || est_row_proc_adm_efd_reinf.nro_proc || chr(13) || vv_nro_lote;
   --
   vn_fase := 1.6;
   --
   if nvl(est_row_proc_adm_efd_reinf.id, 0) <= 0 then
      --
      est_row_proc_adm_efd_reinf.id := pk_csf.fkg_procadmefdreinf_id ( en_empresa_id => est_row_proc_adm_efd_reinf.empresa_id
                                                                     , ed_dt_ini     => est_row_proc_adm_efd_reinf.dt_ini
                                                                     , ed_dt_fin     => est_row_proc_adm_efd_reinf.dt_fin
                                                                     , en_dm_tp_proc => est_row_proc_adm_efd_reinf.dm_tp_proc
                                                                     , ev_nro_proc   => est_row_proc_adm_efd_reinf.nro_proc
                                                                     );
      --
      vn_fase := 1.7;
      --
      if nvl(est_row_proc_adm_efd_reinf.id, 0) <= 0 then
         --
         select procadmefdreinf_seq.nextval
           into est_row_proc_adm_efd_reinf.id
           from dual;
         --
      end if;
      --
   end if;
   -- Seta a referencia
   gn_referencia_id := est_row_proc_adm_efd_reinf.id;
   --
   delete from log_generico_cad
    where referencia_id  = gn_referencia_id
      and obj_referencia = gv_obj_referencia;
   --
   vn_fase := 2;
   -- Validação do Registro
   if nvl(est_row_proc_adm_efd_reinf.empresa_id, 0) = 0 then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := 'CPF/CNPJ Informado para a empresa ('|| ev_cpf_cnpj ||') inválido e/ou mult-org inválido e/ou empresa não está com situação Ativo, favor verificar.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_proc_adm_efd_reinf.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --

   --
   vn_fase := 2.2;
   --
   if trim(est_row_proc_adm_efd_reinf.dt_ini) is null then
      --
      vn_fase := 2.3;
      --
      gv_mensagem_log := 'Deve ser informado a data inicial do processo administrativo.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_proc_adm_efd_reinf.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_row_proc_adm_efd_reinf.dm_tp_proc, 0) not in (1,2) then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := 'Dominio tipo de processo ('|| est_row_proc_adm_efd_reinf.dm_tp_proc ||') inválido, favor verificar. dominios válidos:'||
                         ' 1-Administrativo, 2-Judicial';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_proc_adm_efd_reinf.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   --
   if trim(est_row_proc_adm_efd_reinf.nro_proc) is null then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := 'Número do processo administrativo/judicial não pode ser nulo, favor verificar.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_proc_adm_efd_reinf.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   --
   if nvl(est_row_proc_adm_efd_reinf.dm_tp_proc, 0) = 1 then  -- 1-Administrativo
      --
      if trim(ev_ibge_cidade) is not null
       or trim(est_row_proc_adm_efd_reinf.cod_ident_vara) is not null then
         --
         vn_fase := 5.1;
         --
         gv_mensagem_log := 'Para o tipo de processo "' || pk_csf.fkg_dominio ('PROC_ADM_EFD_REINF.DM_TP_PROC', est_row_proc_adm_efd_reinf.dm_tp_proc )||
                            '" o código de IBGE e código de identificação da vara não devem ser informados';
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_validacao
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => est_row_proc_adm_efd_reinf.empresa_id
                              );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                 , est_log_generico  => est_log_generico );
         --
      end if;
      --
   else -- 2-Judicial
      --
      if trim(ev_ibge_cidade) is null
       or trim(est_row_proc_adm_efd_reinf.cod_ident_vara) is null then
         --
         vn_fase := 5.2;
         --
         gv_mensagem_log := 'Para o tipo de processo "' || pk_csf.fkg_dominio ('PROC_ADM_EFD_REINF.DM_TP_PROC', est_row_proc_adm_efd_reinf.dm_tp_proc )||
                            '" o código de IBGE e código de identificação da vara devem ser informados';
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_validacao
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => est_row_proc_adm_efd_reinf.empresa_id
                              );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                 , est_log_generico  => est_log_generico );
         --
      elsif trim(ev_ibge_cidade) is not null
       and trim(est_row_proc_adm_efd_reinf.cod_ident_vara) is not null then
         --
         vn_fase := 5.3;
         --
         est_row_proc_adm_efd_reinf.cidade_id := pk_csf.fkg_cidade_ibge_id ( ev_ibge_cidade );
         --
         vn_fase := 5.4;
         --
         if nvl(est_row_proc_adm_efd_reinf.cidade_id, 0) = 0
          and trim(ev_ibge_cidade) is not null then
            --
            vn_fase := 5.5;
            --
            gv_mensagem_log := 'Código do IBGE da cidade ('|| ev_ibge_cidade ||') inválido, favor verificar.';
            --
            pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                 , ev_mensagem           => gv_cabec_log
                                 , ev_resumo             => gv_mensagem_log
                                 , en_tipo_log           => erro_de_validacao
                                 , en_referencia_id      => gn_referencia_id
                                 , ev_obj_referencia     => gv_obj_referencia
                                 , en_empresa_id         => est_row_proc_adm_efd_reinf.empresa_id
                                 );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                    , est_log_generico  => est_log_generico );
            --
         end if;
         --
      end if;
      --
   end if;
   --
   vn_fase := 6;
   --
   if trunc(est_row_proc_adm_efd_reinf.dt_ini) > trunc(nvl(est_row_proc_adm_efd_reinf.dt_fin, trunc(est_row_proc_adm_efd_reinf.dt_ini))) then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := 'Data Inicial ('|| to_char(est_row_proc_adm_efd_reinf.dt_ini,'dd/mm/yyyy') ||') não pode ser maior que a data final '||
                         to_char(est_row_proc_adm_efd_reinf.dt_fin,'dd/mm/yyyy');
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_proc_adm_efd_reinf.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 7;
   --
   if nvl(est_row_proc_adm_efd_reinf.dm_ind_auditoria, 0) not in (1, 2) then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := 'Código do domínio de indicador de auditoria ('|| est_row_proc_adm_efd_reinf.DM_IND_AUDITORIA ||') não foi informado ou está inválido '||
                         ', favor verificar. Valores Permitidos: 1-Próprio contribuinte e 2-Outra entidade';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_proc_adm_efd_reinf.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 8;
   --
   if nvl(est_row_proc_adm_efd_reinf.dm_reinf_legado, -1) not in (0, 1) then -- 0- Não e 1-Sim
      --
      vn_fase := 8.1;
      --
      gv_mensagem_log := 'Dominio de Indicador ('|| est_row_proc_adm_efd_reinf.dm_reinf_legado ||
                         ') de legado do registro de outro sistema inválido, favor verificar. ';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_proc_adm_efd_reinf.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_row_proc_adm_efd_reinf.empresa_id,0) > 0
    and nvl(est_row_proc_adm_efd_reinf.dm_tp_proc,0) in (1,2)
    and trim(est_row_proc_adm_efd_reinf.nro_proc) is not null
    and trim(est_row_proc_adm_efd_reinf.dt_ini) is not null
    and nvl(est_row_proc_adm_efd_reinf.dm_ind_auditoria,0) in (0,1,2) then
      --
      vn_fase := 99.1;
      --
      begin
         pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
      exception
       when others then
         null;
      end;
      --
      if pk_csf.fkg_verif_procadmefdreinf(est_row_proc_adm_efd_reinf.id) then
         --
         vn_fase := 99.2;
         --
         update csf_own.proc_adm_efd_reinf
            set empresa_id        = est_row_proc_adm_efd_reinf.empresa_id
              , dm_situacao       = est_row_proc_adm_efd_reinf.dm_situacao
              , dt_ini            = est_row_proc_adm_efd_reinf.dt_ini
              , dt_fin            = est_row_proc_adm_efd_reinf.dt_fin
              , dm_tp_proc        = est_row_proc_adm_efd_reinf.dm_tp_proc
              , nro_proc          = est_row_proc_adm_efd_reinf.nro_proc
              , cidade_id         = est_row_proc_adm_efd_reinf.cidade_id
              , cod_ident_vara    = est_row_proc_adm_efd_reinf.cod_ident_vara
              , dm_ind_auditoria  = est_row_proc_adm_efd_reinf.dm_ind_auditoria
              , dm_reinf_legado   = est_row_proc_adm_efd_reinf.dm_reinf_legado
          where id                = est_row_proc_adm_efd_reinf.id;
         --
      else
         --
         vn_fase := 99.3;
         --
         insert into csf_own.proc_adm_efd_reinf ( id
                                                , empresa_id
                                                , dm_situacao
                                                , dt_ini
                                                , dt_fin
                                                , dm_tp_proc
                                                , nro_proc
                                                , cidade_id
                                                , cod_ident_vara
                                                , dm_ind_auditoria
                                                , dm_reinf_legado )
                                          values( est_row_proc_adm_efd_reinf.id
                                                , est_row_proc_adm_efd_reinf.empresa_id
                                                , est_row_proc_adm_efd_reinf.dm_situacao
                                                , est_row_proc_adm_efd_reinf.dt_ini
                                                , est_row_proc_adm_efd_reinf.dt_fin
                                                , est_row_proc_adm_efd_reinf.dm_tp_proc
                                                , est_row_proc_adm_efd_reinf.nro_proc
                                                , est_row_proc_adm_efd_reinf.cidade_id
                                                , est_row_proc_adm_efd_reinf.cod_ident_vara
                                                , est_row_proc_adm_efd_reinf.dm_ind_auditoria
                                                , est_row_proc_adm_efd_reinf.dm_reinf_legado
                                                );
         --
      end if;
      --
      commit;
      --
      vn_fase := 99.4;
      -- Verifica se existe log na tabela "LOG_PROC_ADM_EFD_REINF" com "DM_ENVIO = 0"
      begin
         --
         select count(*)
           into vn_cont_log
           from log_proc_adm_efd_reinf
          where procadmefdreinf_id = est_row_proc_adm_efd_reinf.id;
         --
      exception
         when others then
            vn_cont_log := 0;
      end;
      --
      vn_fase := 99.5;
      --
      if nvl(vn_cont_log, 0) = 0 then
         --
         insert into csf_own.log_proc_adm_efd_reinf ( id
                                                    , procadmefdreinf_id
                                                    , dt_hr_log
                                                    , resumo
                                                    , mensagem
                                                    , usuario_id
                                                    , maquina
                                                    , dm_envio )
                                             values ( logprocadmefdreinf_seq.nextval
                                                    , est_row_proc_adm_efd_reinf.id
                                                    , sysdate
                                                    , 'Registro inserido via integração:  | [Data Inicial]: '||est_row_proc_adm_efd_reinf.dt_ini||' | [Data Final]: '||est_row_proc_adm_efd_reinf.dt_fin||' | [Tipo de Processo]: '||pk_csf.fkg_dominio ('PROC_ADM_EFD_REINF.DM_TP_PROC', est_row_proc_adm_efd_reinf.dm_tp_proc)||' | [Número Processo Adminstrativo/Judicial]: '||est_row_proc_adm_efd_reinf.nro_proc
                                                    , 'Registro inserido via integração:  | [Data Inicial]: '||est_row_proc_adm_efd_reinf.dt_ini||' | [Data Final]: '||est_row_proc_adm_efd_reinf.dt_fin||' | [Tipo de Processo]: '||pk_csf.fkg_dominio ('PROC_ADM_EFD_REINF.DM_TP_PROC', est_row_proc_adm_efd_reinf.dm_tp_proc)||' | [Número Processo Adminstrativo/Judicial]: '||est_row_proc_adm_efd_reinf.nro_proc
                                                    , null
                                                    , sys_context('USERENV', 'IP_ADDRESS')   -- Recupera o IP da máquina
                                                    , 0 );
         --
         commit;
         --
      end if;
      --
   else
      --
      vn_fase := 99.6;
      --
      gv_mensagem_log := 'Layout da Tabela de Processos Administrativo do EFD-REINF inválido(Informação obrigatória vazia ou inválida), favor verificar.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_item.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_proc_adm_efd_reinf fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_sistema
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => est_row_proc_adm_efd_reinf.empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_proc_adm_efd_reinf;

-------------------------------------------------------------------------------------------------------
-- Procedimento integra as informações de Processos Administrativos e Judiciais da EFD Reinf
procedure pkb_integr_procadmefdreinftrib ( est_log_generico                in out nocopy  dbms_sql.number_table
                                         , est_row_procadmefdreinfinftrib  in out nocopy  proc_adm_efd_reinf_inf_trib%rowtype
                                         , en_empresa_id                   in             empresa.id%type
                                         , ev_ind_susp_exig                in             ind_susp_exig.cd%type
                                         ) 
is
   --
   vn_fase               number := 0;
   vn_loggenericocad_id  log_generico.id%type;
   vn_dm_tp_proc         proc_adm_efd_reinf.dm_tp_proc%type;
   vv_nro_proc           proc_adm_efd_reinf.nro_proc%type;
   vn_cont_susp_exig     number;
   vv_nro_lote           varchar2(30) := null;
   --
begin
   --
   vn_fase := 1;
   --
   gv_cabec_log := gv_cabec_log || chr(13) || 'Código indicativo da suspensão: ' || est_row_procadmefdreinfinftrib.cod_susp;
   --
   vn_fase := 2;
   --
   vn_dm_tp_proc     := null;
   vv_nro_proc       := null;
   vn_cont_susp_exig := null;
   --
   vn_fase := 3;
   --
   begin
      --
      select dm_tp_proc
           , nro_proc
        into vn_dm_tp_proc
           , vv_nro_proc
        from proc_adm_efd_reinf
       where id = est_row_procadmefdreinfinftrib.procadmefdreinf_id;
      --
   exception
      when others then
         vn_dm_tp_proc := null;
         vv_nro_proc   := null;
   end;
   --
   vn_fase := 4;
   --
   begin
      --
      select count(*)
        into vn_cont_susp_exig
        from proc_adm_efd_reinf_inf_trib
       where procadmefdreinf_id = est_row_procadmefdreinfinftrib.procadmefdreinf_id;
      --
   exception
      when others then
         vn_cont_susp_exig := 0;
   end;
   --
      --
   vn_fase := 6;
   --
   if trim(est_row_procadmefdreinfinftrib.dt_decisao) is null then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := '"Data da decisão" não foi informado, favor verificar.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => en_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 7;
   --
   if trim(est_row_procadmefdreinfinftrib.dm_ind_deposito) not in ('N', 'S') then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := '"Data da decisão" não foi informado, favor verificar.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => en_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 8;
   --
   est_row_procadmefdreinfinftrib.indsuspexig_id := pk_csf.fkg_indsuspexig_id ( ev_ind_susp_exig );
   --
   if nvl(est_row_procadmefdreinfinftrib.indsuspexig_id,0) = 0 then
      --
      vn_fase := 8.1;
      --
      gv_mensagem_log := 'Código indicativo de suspensão da exigibilidade ('|| ev_ind_susp_exig ||') inválido, favor verificar.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => en_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 9;
   --
   --   Validação: Se {tpProc} = [1], deve ser preenchido com [03,90,92]. Se
   --   {tpProc} = [2], deve ser preenchido com [01,02,04,05,08,09,10,11,12,13,90,92]. Valores Válidos: 01,02,03,04,05,08,09,10,11,12,,13,90,92
   if nvl(vn_dm_tp_proc, 0) = 1 -- 1-Administrativo
    and trim(ev_ind_susp_exig) not in ('03','90','92') then
      --
      vn_fase := 9.1;
      --
      gv_mensagem_log := 'Para o tipo de processo "' || pk_csf.fkg_dominio ('PROC_ADM_EFD_REINF.DM_TP_PROC', vn_dm_tp_proc )||
                         '" o indicativo de suspensão da exigibilidade deve ser igual a "03, 90, 92"';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => en_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 10;
   --
   if nvl(vn_dm_tp_proc, 0) = 2 -- 2-Judicial
    and trim(ev_ind_susp_exig) not in ('01','02','04','05','08','09','10','11','12','13','90','92') then
      --
      vn_fase := 10.1;
      --
      gv_mensagem_log := 'Para o tipo de processo "' || pk_csf.fkg_dominio ('PROC_ADM_EFD_REINF.DM_TP_PROC', vn_dm_tp_proc )||
                         '" o indicativo de suspensão da exigibilidade deve ser igual a "01,02,04,05,08,09,10,11,12,13,90,92"';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => en_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 11;
   --   Validação: Se {indSusp} = [90], preencher obrigatoriamente com [N]. Se
   --   {indSusp} = [02, 03] preencher obrigatoriamente com [S]. Valores Válidos: S, N.
   if trim(ev_ind_susp_exig) = '90' 
    and trim(est_row_procadmefdreinfinftrib.dm_ind_deposito) = 'S' then
      --
      vn_fase := 11.1;
      --
      gv_mensagem_log := 'Quando o código indicativo de suspensão for igual a "90- Decisão definitiva a favor do contribuinte" o indicativo de depósito do montante integral ' ||
                         'deve ser igual a "Não"';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => en_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 12;
   --
   if trim(ev_ind_susp_exig) in ('02','03')
    and trim(est_row_procadmefdreinfinftrib.dm_ind_deposito) = 'N' then
      --
      vn_fase := 12.1;
      --
      gv_mensagem_log := 'Quando o código indicativo da suspensão for igual a "02-Depósito judicial do montante integral" ou "03 - Depósito administrativo do montante integral" o indicativo de depósito do montante integral ' ||
                         'deve ser igual a "Sim"';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => en_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if   nvl(est_row_procadmefdreinfinftrib.indsuspexig_id,0) > 0
    and trim(est_row_procadmefdreinfinftrib.dt_decisao) is not null
    and trim(est_row_procadmefdreinfinftrib.dm_ind_deposito) in ('S','N') then
      --
      vn_fase := 99.1;
      --
      if nvl(est_row_procadmefdreinfinftrib.id,0) = 0 then
         --
         vn_fase := 99.2;
         --
         select csf_own.procadmefdreinfinftrib_seq.nextval
           into est_row_procadmefdreinfinftrib.id
           from dual;
         --
         vn_fase := 99.3;
         --
         insert into csf_own.proc_adm_efd_reinf_inf_trib ( id
                                                         , procadmefdreinf_id
                                                         , cod_susp
                                                         , indsuspexig_id
                                                         , dt_decisao
                                                         , dm_ind_deposito )
                                                   values( est_row_procadmefdreinfinftrib.id
                                                         , est_row_procadmefdreinfinftrib.procadmefdreinf_id
                                                         , est_row_procadmefdreinfinftrib.cod_susp
                                                         , est_row_procadmefdreinfinftrib.indsuspexig_id
                                                         , est_row_procadmefdreinfinftrib.dt_decisao
                                                         , est_row_procadmefdreinfinftrib.dm_ind_deposito 
                                                         );
         --
      else
         --
         vn_fase := 99.4;
         --
         update csf_own.proc_adm_efd_reinf_inf_trib
            set procadmefdreinf_id  = est_row_procadmefdreinfinftrib.procadmefdreinf_id
              , cod_susp            = est_row_procadmefdreinfinftrib.cod_susp
              , indsuspexig_id      = est_row_procadmefdreinfinftrib.indsuspexig_id    
              , dt_decisao          = est_row_procadmefdreinfinftrib.dt_decisao        
              , dm_ind_deposito     = est_row_procadmefdreinfinftrib.dm_ind_deposito
          where id                  = est_row_procadmefdreinfinftrib.id;
         --
      end if;
      --
      commit;
      --
   else
      --
      vn_fase := 99.5;
      --
      gv_mensagem_log := 'Layout da Tabela de Processos Administrativo do EFD-REINF informações Tributárias inválida (Informação obrigatória vazia ou inválida), favor verificar.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => en_empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_procadmefdreinftrib fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_sistema
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => en_empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_procadmefdreinftrib;

-------------------------------------------------------------------------------------------------------
-- Procedimento integra as informações do Histórico Padrão
procedure pkb_integr_Hist_Padrao ( est_log_generico     in out nocopy  dbms_sql.number_table
                                 , est_row_Hist_Padrao  in out nocopy  hist_padrao%rowtype
                                 , en_loteintws_id      in             lote_int_ws.id%type default 0
                                 )
is
   --
   vn_fase               number := 0;
   vn_loggenericocad_id  Log_Generico.id%TYPE;
   vv_nro_lote           varchar2(30) := null;
   --
begin
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' - Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_cabec_log := est_row_Hist_Padrao.cod_hist || ' - ' || est_row_Hist_Padrao.descr_hist || vv_nro_lote;
   --
   gv_obj_referencia := 'HIST_PADRAO';
   --
   vn_fase := 1;
   --
   est_row_Hist_Padrao.cod_hist := trim( est_row_Hist_Padrao.cod_hist );
   --
   -- Válida o cod_hist
   if est_row_Hist_Padrao.cod_hist is null then
      --
      vn_fase := 1.1;
      --
      gv_mensagem_log := '"Código do histórico padrão" não foi informado.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => null
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_Hist_Padrao.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 1.2;
   --
   -- Verifica se o Histórico Padrão já Existe
   est_row_Hist_Padrao.id := pk_csf_ecd.fkg_hist_padrao_id ( en_empresa_id  => est_row_Hist_Padrao.empresa_id
                                                           , ev_cod_hist    => est_row_Hist_Padrao.cod_hist );
   --
   vn_fase := 1.3;
   --
   if nvl(est_row_Hist_Padrao.id,0) <= 0 then
      --
      select histpadrao_seq.nextval
        into est_row_Hist_Padrao.id
        from dual;
      --
   end if;
   --
   gn_referencia_id := est_row_Hist_Padrao.id;
   --
   vn_fase := 1.4;
   --
   delete from log_generico_cad
    where referencia_id  = gn_referencia_id
      and obj_referencia = gv_obj_referencia;
   --
   vn_fase := 2;
   --
   est_row_Hist_Padrao.descr_hist := trim( pk_csf.fkg_converte(est_row_Hist_Padrao.descr_hist) );
   --
   -- Válida o descr_hist
   if est_row_Hist_Padrao.descr_hist is null then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := '"Descrição do histórico padrão" não foi informada.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_Hist_Padrao.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   -- Válida se a empresa é válida
   if pk_csf.fkg_empresa_id_valido ( en_empresa_id => est_row_Hist_Padrao.empresa_id ) = false then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := '"Empresa" ('||est_row_Hist_Padrao.empresa_id||') está incorreta para o Histórico Padrão.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_Hist_Padrao.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_log_generico.count,0) = 0 then
      --
      est_row_Hist_Padrao.dm_st_proc := 1;
      --
   else
      --
      est_row_Hist_Padrao.dm_st_proc := 2;
      --
   end if;
   --
   -- Calcula a quantidade de registros totais integrados para ser
   -- mostrado na tela de agendamento.
   --
   --
   vn_fase := 99.1;
   --
   begin
      pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
   exception
      when others then
      null;
   end;
   --
   vn_fase := 99.2;
   -- Se não existe, insere o registro
   if pk_csf.fkg_existe_hist_padrao ( en_histpadrao_id => est_row_Hist_Padrao.id ) = false then
      --
      vn_fase := 99.3;
      --
      insert into Hist_Padrao ( id
                              , empresa_id
                              , cod_hist
                              , descr_hist 
                              , dm_st_proc
                              )
                       values ( est_row_Hist_Padrao.id
                              , est_row_Hist_Padrao.empresa_id
                              , est_row_Hist_Padrao.cod_hist
                              , est_row_Hist_Padrao.descr_hist
                              , est_row_Hist_Padrao.dm_st_proc
                              );
      --
   else
      --
      vn_fase := 99.5;
      -- Se já existe atualiza o registro
      update Hist_Padrao set cod_hist    = est_row_Hist_Padrao.cod_hist
                           , descr_hist  = est_row_Hist_Padrao.descr_hist
                           , dm_st_proc  = est_row_Hist_Padrao.dm_st_proc
       where id = est_row_Hist_Padrao.id;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_Hist_Padrao fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_sistema
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => est_row_Hist_Padrao.empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_Hist_Padrao;

-------------------------------------------------------------------------------------------------------
-- Procedimento integra as informações do centro de custo
procedure pkb_integr_Centro_Custo ( est_log_generico      in out nocopy  dbms_sql.number_table
                                  , est_row_Centro_Custo  in out nocopy  Centro_Custo%rowtype
                                  , ed_dt_fim_reg_0000    in             Abertura_ECD.dt_fim%TYPE 
                                  , en_loteintws_id       in             lote_int_ws.id%type default 0
                                  )
is
   --
   vn_fase               number := 0;
   vn_loggenericocad_id  Log_Generico_cad.id%TYPE;
   vv_nro_lote           varchar2(30) := null;
   --
begin
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' - Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_cabec_log := est_row_Centro_Custo.cod_ccus || ' - ' || est_row_Centro_Custo.descr_ccus || vv_nro_lote;
   --
   gv_obj_referencia := 'CENTRO_CUSTO';
   --
   -- REGRA_COD_CCUS_DT_ALT_DUPLICADO - já faz com a unique
   vn_fase := 1;
   -- Válida se a empresa é válida
   if pk_csf.fkg_empresa_id_valido ( en_empresa_id => est_row_Centro_Custo.empresa_id ) = false then
      --
      vn_fase := 1.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Empresa" ('||est_row_Centro_Custo.empresa_id||') está incorreta para o Centro de Custo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => null
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_Centro_Custo.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   est_row_Centro_Custo.id := pk_csf_ecd.fkg_centro_custo_id ( en_empresa_id  => est_row_Centro_Custo.empresa_id
                                                             , ev_cod_ccus    => est_row_Centro_Custo.cod_ccus );
   --
   if nvl(est_row_Centro_Custo.id,0) <= 0 then
      --
      select centrocusto_seq.nextval
        into est_row_Centro_Custo.id
        from dual;
      --
   end if;
   --
   gn_referencia_id := est_row_Centro_Custo.id;
   --
   vn_fase := 1.5;
   --
   delete from log_generico_cad
    where referencia_id  = gn_referencia_id
      and obj_referencia = gv_obj_referencia;
   --
   vn_fase := 2;
   -- Válida a dt_inc_alt
   if est_row_Centro_Custo.dt_inc_alt is null then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := '"Data da inclusão/alteração do Centro de Custo" não informada.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_Centro_Custo.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2.2;
   -- REGRA_DT_ALT_DATA_MAIOR - Verifica se DT_ALT<=DT_FIN do Registro 0000
   if est_row_Centro_Custo.dt_inc_alt > ed_dt_fim_reg_0000 then
      --
      vn_fase := 2.3;
      --
      gv_mensagem_log := '"Data da inclusão/alteração do Centro de Custo" não pode ser maior que a Data Final das informações contidas no arquivo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_Centro_Custo.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   est_row_Centro_Custo.cod_ccus := trim( pk_csf.fkg_converte( est_row_Centro_Custo.cod_ccus ) );
   --
   -- Válida o cod_ccus
   if est_row_Centro_Custo.cod_ccus is null then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := '"Código do centro de custo" não informado.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_Centro_Custo.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   --
   est_row_Centro_Custo.descr_ccus :=  trim( pk_csf.fkg_converte( est_row_Centro_Custo.descr_ccus ) );
   -- Valida descr_ccus
   if est_row_Centro_Custo.descr_ccus is null then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := '"Descrição do centro de custo" não informado.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_Centro_Custo.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_log_generico.count,0) = 0 then
      --
      est_row_Centro_Custo.dm_st_proc := 1; -- Validado
      --
   else
      --
      est_row_Centro_Custo.dm_st_proc := 2;
      --
   end if;
   --
   vn_fase := 99.1;
   --
   -- Calcula a quantidade de registros totais integrados para ser
   -- mostrado na tela de agendamento.
   --
   begin
      pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
   exception
      when others then
      null;
   end;
   --
   vn_fase := 99.2;
   --
   if est_row_Centro_Custo.dt_inc_alt is not null and
      est_row_Centro_Custo.dt_inc_alt <= ed_dt_fim_reg_0000 and
      est_row_Centro_Custo.cod_ccus is not null and
      est_row_Centro_Custo.descr_ccus is not null and
      nvl(est_row_Centro_Custo.empresa_id,0) > 0 then
      --
      vn_fase := 99.3;
      -- Se não existe, insere o registro
      if pk_csf.fkg_existe_centro_custo ( en_centrocusto_id => est_row_Centro_Custo.id ) = false then
         --
         vn_fase := 99.4;
         --
         insert into centro_custo ( id
                                  , empresa_id
                                  , dt_inc_alt
                                  , cod_ccus
                                  , descr_ccus
                                  , dm_st_proc
                                  )
                           values ( est_row_Centro_Custo.id
                                  , est_row_Centro_Custo.empresa_id
                                  , est_row_Centro_Custo.dt_inc_alt
                                  , est_row_Centro_Custo.cod_ccus
                                  , est_row_Centro_Custo.descr_ccus
                                  , est_row_Centro_Custo.dm_st_proc
                                  );
         --
      else
         -- Se já existe atualiza o registro
         vn_fase := 99.5;
         --
         update centro_custo set dt_inc_alt = est_row_Centro_Custo.dt_inc_alt
                               , cod_ccus   = est_row_Centro_Custo.cod_ccus
                               , descr_ccus = est_row_Centro_Custo.descr_ccus
                               , dm_st_proc = est_row_Centro_Custo.dm_st_proc
          where id = est_row_Centro_Custo.id;
         --
      end if;
      --
   end if;
   --                        
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_Centro_Custo fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_sistema
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => est_row_Centro_Custo.empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_Centro_Custo;

-------------------------------------------------------------------------------------------------------
-- Procedimento integra as informações do SUBCONTA_CORRELATA
procedure pkb_integr_subconta_correlata ( est_log_generico           in out nocopy dbms_sql.number_table
                                        , est_row_subconta_correlata in out nocopy subconta_correlata%rowtype
                                        , en_empresa_id              in            empresa.id%type
                                        , ev_cod_cta_corr            in            plano_conta.cod_cta%type
                                        , ev_cd_natsubcnt            in            nat_sub_cnt.cd%type
                                        , en_loteintws_id            in            lote_int_ws.id%type default 0
                                        )
is
   --
   vn_fase                number := null;
   vn_loggenericocad_id   log_generico_cad.id%type;
   vv_nro_lote            varchar2(60);
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id ;
   end if;
   --
   gv_cabec_log := 'Conta Correlata ' || ev_cod_cta_corr || vv_nro_lote;
   --
   gv_obj_referencia := 'PLANO_CONTA';
   -- Verifica se foi informado o ID do Plano de Contas PAI
   if nvl(est_row_subconta_correlata.planoconta_id,0) = 0 then
      --
      vn_fase := 1.1;
      --
      gv_mensagem_log := 'Não foi informado a conta contábil para o registro do Plano de Contas Subcontas Correlatas.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 1.2;
   --
   if trim(est_row_subconta_correlata.cod_idt) is null then
      --
      vn_fase := 1.3;
      --
      gv_mensagem_log := '"COD_IDT" não informado, favor verificar informação obrigatória.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
   end if;
   --
   vn_fase := 1.4;
   --
   if nvl(est_row_subconta_correlata.id,0) <= 0 then
      --
      est_row_subconta_correlata.id := pk_csf_ecd.fkg_subconta_correlata_id( en_planoconta_id => est_row_subconta_correlata.planoconta_id
                                                                           , ev_cod_idt       => est_row_subconta_correlata.cod_idt
                                                                           );
      --
   end if;
   --
   vn_fase := 2.5;
   --
   if nvl(est_row_subconta_correlata.id,0) <= 0 then
      --
      select subcontacorrelata_seq.nextval
        into est_row_subconta_correlata.id
        from dual;
      --
   end if;
   --
   gn_referencia_id := est_row_subconta_correlata.planoconta_id;
   --
   vn_fase := 3;
   --
   begin
   delete from log_generico_cad
    where referencia_id  = gn_referencia_id
      and obj_referencia = gv_obj_referencia;
   end;
   --
   vn_fase := 4;
   --
   est_row_subconta_correlata.planoconta_id_corr := pk_csf.fkg_Plano_Conta_id ( ev_cod_cta    => ev_cod_cta_corr
                                                                              , en_empresa_id => en_empresa_id
                                                                              );
   --
   vn_fase := 5;
   --
   if nvl(est_row_subconta_correlata.planoconta_id_corr,0) = 0 then
      --
      vn_fase := 6;
      --
      gv_mensagem_log := '"COD_CTA_CORR" inválido ou não pertence a empresa citada ('||ev_cod_cta_corr||') favor verificar. Informação obrigatória.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 7;
   --
   est_row_subconta_correlata.natsubcnt_id := null;
   --
   begin
      select ns.id
        into est_row_subconta_correlata.natsubcnt_id
        from nat_sub_cnt ns
       where ns.cd = ev_cd_natsubcnt;
   exception
      when no_data_found then
         est_row_subconta_correlata.natsubcnt_id := null;
   end;
   --
   vn_fase := 8;
   --
   if nvl(est_row_subconta_correlata.natsubcnt_id,0) = 0 then
      --
      vn_fase := 9;
      --
      gv_mensagem_log := '"COD_NATSUBCNT" inválido ('||ev_cd_natsubcnt||') favor verificar, informação obrigatória.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_log_generico.count,0) = 0 then
      --
      if pk_csf_ecd.fkg_verif_subcontacorrelata ( en_subcontacorrelata_id => est_row_subconta_correlata.id) = false then
         --
         insert into subconta_correlata ( id
                                        , planoconta_id
                                        , cod_idt
                                        , planoconta_id_corr
                                        , natsubcnt_id )
                                  values( est_row_subconta_correlata.id
                                        , est_row_subconta_correlata.planoconta_id
                                        , est_row_subconta_correlata.cod_idt
                                        , est_row_subconta_correlata.planoconta_id_corr
                                        , est_row_subconta_correlata.natsubcnt_id
                                        );
         --
      else
         --
         update subconta_correlata set planoconta_id      = est_row_subconta_correlata.planoconta_id
                                     , cod_idt            = est_row_subconta_correlata.cod_idt
                                     , planoconta_id_corr = est_row_subconta_correlata.planoconta_id_corr
                                     , natsubcnt_id       = est_row_subconta_correlata.natsubcnt_id
                                 where id                 = est_row_subconta_correlata.id;
         --
      end if;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_subconta_correlata fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_sistema
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => gt_row_plano_conta.empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_subconta_correlata;

/*
-------------------------------------------------------------------------------------------------------
-- Procedimento consiste as informações do PC_REFEREN
procedure pkb_consiste_pc_referen ( est_log_generico  in out nocopy dbms_sql.number_table
                                  , en_pcreferen_id   in            pc_referen.id%type
                                  )
is
   --
   vn_fase                        number;
   vv_dm_ind_cta                  plano_conta.dm_ind_cta%type;
   vd_dt_ini_ecd                  date;
   vd_dt_fin_ecd                  date;
   --
   ev_cod_cta_ref                 plano_conta_ref_ecd.cod_cta_ref%type;
   vn_loggenerico_id              log_generico.id%type;
   vn_count_pcreferen             number;
   --
   cursor c_pcref is
   select *
     from pc_referen
    where id = en_pcreferen_id;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_pcreferen_id,0) > 0 then
      --
      vn_fase := 2;
      --
      open c_pcref;
      fetch c_pcref into gt_row_pc_referen;
      close c_pcref;
      --
      vn_fase := 3;
      --
      if nvl(gt_row_pc_referen.id,0) <= 0 then
         return;
      end if;
      --
      vn_fase := 4;
      --
      vv_dm_ind_cta := null;
      --
      begin
         --
         vn_fase := 4.1;
         --
         select dm_ind_cta
           into vv_dm_ind_cta
           from plano_conta
          where id = gt_row_pc_referen.planoconta_id;
         --
      exception
       when others then
          vv_dm_ind_cta := null;
      end;
      --
      vn_fase := 5;
      --
      if trim(vv_dm_ind_cta) = 'S' then
         --
         gv_mensagem_log := 'O Plano de Conta ('|| pk_csf.fkg_cd_plano_conta ( en_planoconta_id => gt_row_pc_referen.planoconta_id) ||
                            ') Possui erro; Só deve ser Referenciado para os Planos de Conta do ECD os Planos de Conta da Empresa '||
                            'Cuja o Dominio de Indicação da Conta for "Analítico".';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenerico_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_validacao
                              , en_referencia_id      => gt_row_pc_referen.planoconta_id
                              , ev_obj_referencia     => 'PLANO_CONTA'
                              , en_empresa_id         => gt_row_plano_conta.empresa_id
                              );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenerico_id
                                 , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 6;
      --
      begin
         --
         select pc.dt_ini
              , pc.dt_fin
              , pc.COD_CTA_REF
           into vd_dt_ini_ecd
              , vd_dt_fin_ecd
              , ev_cod_cta_ref
           from plano_conta_ref_ecd pc
          where pc.id = gt_row_pc_referen.planocontarefecd_id;
          --
      exception
       when others then
         vd_dt_ini_ecd := null;
         vd_dt_fin_ecd := null;
      end;
      --
      vn_fase := 6.1;
      --
      if ( trunc(gt_row_pc_referen.dt_ini) > vd_dt_ini_ecd
             and trunc(gt_row_pc_referen.dt_ini) > vd_dt_fin_ecd )
           or
            (trunc(gt_row_pc_referen.dt_fin) < vd_dt_ini_ecd
             and trunc(gt_row_pc_referen.dt_fin) < vd_dt_fin_ecd ) then
         --
         vn_fase := 6.2;
         --
         gv_mensagem_log := 'Esta sendo Referenciado um Plano de Conta do ECD em um periodo de '|| to_date(gt_row_pc_referen.dt_ini,'dd/mm/yyyy')||
                            ' até '|| to_date(gt_row_pc_referen.dt_fin,'dd/mm/yyyy') ||' e o periodo de vigencia deste plano de Conta ECD (COD_CTA: '|| ev_cod_cta_ref||
                            ') é de ' || to_date(vd_dt_ini_ecd,'dd/mm/yyyy')|| ' até '||to_date(vd_dt_fin_ecd,'dd/mm/yyyy');
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenerico_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_validacao
                              , en_referencia_id      => gt_row_pc_referen.planoconta_id
                              , ev_obj_referencia     => 'PLANO_CONTA'
                              , en_empresa_id         => gt_row_plano_conta.empresa_id
                              );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenerico_id
                                 , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_count_pcreferen := null;
      -- Criar regra de validação do plano referencial onde: verificar se uma mesma conta contábil
      -- possui conta referencial com e sem centro de custos em vigência, se existir deverá ser gerado
      -- erro de validação informando que Não pode haver conta referencial com e sem centro de custo no mesmo
      -- período e exibir a conta e centro de custo.
      begin
         --
         select count(1)
           into vn_count_pcreferen
           from pc_referen
          where planoconta_id = gt_row_pc_referen.planoconta_id
            and nvl(centrocusto_id,0) = nvl(gt_row_pc_referen.centrocusto_id,0)
            and planocontarefecd_id not in gt_row_pc_referen.planocontarefecd_id
            and ( trunc(dt_ini) between gt_row_pc_referen.dt_ini and gt_row_pc_referen.dt_fin
              or trunc(nvl(dt_fin,sysdate)) between gt_row_pc_referen.dt_ini and gt_row_pc_referen.dt_fin
              or gt_row_pc_referen.dt_ini between trunc(dt_ini) and trunc(nvl(dt_fin,sysdate))
              or gt_row_pc_referen.dt_fin between trunc(dt_ini) and trunc(nvl(dt_fin,sysdate)));
         --
      exception
       when others then
         vn_count_pcreferen := null;
      end;
      --
      vn_fase := 7;
      --
      if nvl(vn_count_pcreferen,0) > 0 then
         --
         gv_mensagem_log := 'Já existe Referência para este Plano de Conta ('|| pk_csf.fkg_cd_plano_conta ( gt_row_pc_referen.planoconta_id) ||') e Centro de Custo ('||
                            pk_csf.fkg_cd_centro_custo (gt_row_pc_referen.centrocusto_id )|| ') Relacionado ao Periodo Integrado, Favor verificar.' ;
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenerico_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_validacao
                              , en_referencia_id      => gt_row_pc_referen.planoconta_id
                              , ev_obj_referencia     => 'PLANO_CONTA'
                              , en_empresa_id         => gt_row_plano_conta.empresa_id
                              );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenerico_id
                                 , est_log_generico  => est_log_generico );
         --
      end if;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_consiste_pc_referen - Plano de Conta Referenciada fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
        --
        pkb_log_generico_cad ( sn_loggenericocad_id  => gt_row_plano_conta.id
                             , ev_mensagem           => gv_cabec_log
                             , ev_resumo             => gv_mensagem_log
                             , en_tipo_log           => erro_de_validacao
                             , en_referencia_id      => gn_referencia_id
                             , ev_obj_referencia     => gv_obj_referencia
                             , en_empresa_id         => gt_row_plano_conta.empresa_id
                             );
        --
        -- Armazena o "loggenerico_id" na memória
        pkb_gt_log_generico_cad ( en_loggenerico    => gt_row_plano_conta.id
                                , est_log_generico  => est_log_generico );
      exception
         when others then
            null;
      end;
      --
end pkb_consiste_pc_referen;

-------------------------------------------------------------------------------------------------------
-- Procedimento consiste as informações do plano de conta e das tabelas filhas
procedure pkb_consiste_pc ( est_log_generico  in out nocopy dbms_sql.number_table
                          , en_planoconta_id  in            plano_conta.id%type
                          )
is
   --
   vn_fase                number;
   --
   cursor c_pc_ref is
   select pcr.*
     from pc_referen pcr
    where pcr.planoconta_id = en_planoconta_id;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_planoconta_id,0) > 0 then
      --
      vn_fase := 2;
      --
      for rec_pc_ref in c_pc_ref loop
       exit when c_pc_ref%notfound or (c_pc_ref%notfound) is null;
         --
         vn_fase := 3;
         --
         pkb_consiste_pc_referen ( est_log_generico => est_log_generico 
                                 , en_pcreferen_id  => rec_pc_ref.id 
                                 );
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_consiste_pc - Plano de Conta fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
        --
        pkb_log_generico_cad ( sn_loggenericocad_id  => gt_row_plano_conta.id
                             , ev_mensagem           => gv_cabec_log
                             , ev_resumo             => gv_mensagem_log
                             , en_tipo_log           => erro_de_validacao
                             , en_referencia_id      => gn_referencia_id
                             , ev_obj_referencia     => gv_obj_referencia
                             , en_empresa_id         => gt_row_plano_conta.empresa_id
                             );
        --
        -- Armazena o "loggenerico_id" na memória
        pkb_gt_log_generico_cad ( en_loggenerico    => gt_row_plano_conta.id
                                , est_log_generico  => est_log_generico );
      exception
         when others then
            null;
      end;
      --
end pkb_consiste_pc;
*/

-------------------------------------------------------------------------------------------------------
/*-- Procedimento integra as informações do Plano de Contas Referencial Flex Field
procedure pkb_integr_pc_referen_ff ( EST_LOG_GENERICO        IN OUT NOCOPY  DBMS_SQL.NUMBER_TABLE
                                   , EN_PCREFEREN_ID         IN             PC_REFEREN.ID%TYPE
                                   , EV_ATRIBUTO             IN             VARCHAR2
                                   , EV_VALOR                IN             VARCHAR2
                                   )
IS
   --
   vd_dt_ini                       date;
   vd_dt_fin                       date;
   vv_mensagem                     varchar2(1000) := null;
   vn_fase                         number;                                                 
   --
   vn_dmtipocampo                  ff_obj_util_integr.dm_tipo_campo%type;
   VV_EXIST_PC_REFEREN_PERIOD      number;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if trim(ev_atributo) is null then
      --
      vn_fase := 2;
      --
      gv_mensagem_log := 'Plano de Conta Referenciado: "Atributo" deve ser informado.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => gt_row_plano_conta.id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => gt_row_plano_conta.id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   --
   if trim(ev_valor) is null then
      --
      vn_fase := 4;
      --
      gv_mensagem_log := 'Plano de Conta Referenciado: "VALOR" referente ao atributo deve ser informado.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => gt_row_plano_conta.id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => gt_row_plano_conta.id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   --
   vv_mensagem := pk_csf.fkg_ff_verif_campos( ev_obj_name => 'VW_CSF_PC_REFEREN_FF'
                                            , ev_atributo => trim(ev_atributo)
                                            , ev_valor    => trim(ev_valor) );
   --
   if vv_mensagem is not null then
      --
      vn_fase := 7;
      --
      gv_mensagem_log := vv_mensagem;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => gt_row_plano_conta.id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => gt_row_plano_conta.id
                              , est_log_generico  => est_log_generico );
      --
   else
      --
      vn_fase := 8;
      --
      vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo( ev_obj_name => 'VW_CSF_PC_REFEREN_FF'
                                                         , ev_atributo => trim(ev_atributo) );
      --
      vn_fase := 9;
      --
      if trim(ev_atributo) = 'DT_INI' then
         --
         if trim(ev_valor) is not null then
            --
            vn_fase := 10;
            --
            if vn_dmtipocampo = 0 then -- tipo de campo = numérico
               --
               vn_fase := 11;
               --
               vd_dt_ini := pk_csf.fkg_ff_ret_vlr_caracter( ev_obj_name => 'VW_CSF_PC_REFEREN_FF'
                                                          , ev_atributo => trim(ev_atributo)
                                                          , ev_valor    => trim(ev_valor) );
               --
            else
               --
               vn_fase := 17.3;
               --
               gv_mensagem_log := 'O valor do campo "Data Inicial" informado não confere com o tipo de campo, deveria ser DATA.';
               --
               pkb_log_generico_cad ( sn_loggenericocad_id  => gt_row_plano_conta.id
                                    , ev_mensagem           => gv_cabec_log
                                    , ev_resumo             => gv_mensagem_log
                                    , en_tipo_log           => erro_de_validacao
                                    , en_referencia_id      => gn_referencia_id
                                    , ev_obj_referencia     => gv_obj_referencia
                                    , en_empresa_id         => gt_row_plano_conta.empresa_id
                                    );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_cad ( en_loggenerico    => gt_row_plano_conta.id
                                       , est_log_generico  => est_log_generico );
               --
            end if;
            --
         end if;
         --
      elsif(ev_atributo) = 'DT_FIN' then
         --
         vn_fase := 18;
         --
         if trim(ev_valor) is not null then
            --
            if vn_dmtipocampo = 0 then -- tipo de campo = numérico
               --
               vn_fase := 19;
               --
               vd_dt_fin := pk_csf.fkg_ff_ret_vlr_caracter( ev_obj_name => 'VW_CSF_PC_REFEREN_FF'
                                                          , ev_atributo => trim(ev_atributo)
                                                          , ev_valor    => trim(ev_valor) );
               --
            else
               --
               vn_fase := 19.3;
               --
               gv_mensagem_log := 'O valor do campo "Data Final" informado não confere com o tipo de campo, deveria ser DATA.';
               --
               pkb_log_generico_cad ( sn_loggenericocad_id  => gt_row_plano_conta.id
                                    , ev_mensagem           => gv_cabec_log
                                    , ev_resumo             => gv_mensagem_log
                                    , en_tipo_log           => erro_de_validacao
                                    , en_referencia_id      => gn_referencia_id
                                    , ev_obj_referencia     => gv_obj_referencia
                                    , en_empresa_id         => gt_row_plano_conta.empresa_id
                                    );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_cad ( en_loggenerico    => gt_row_plano_conta.id
                                       , est_log_generico  => est_log_generico );
               --
            end if;
            --
         end if;
         --
      else
         --
         vn_fase := 20;
         --
         gv_mensagem_log := '"Atributo" ('||ev_atributo||') e "VALOR" ('||ev_valor||') relacionados, não especificados no processo.';
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => gt_row_plano_conta.id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_cad ( en_loggenerico    => gt_row_plano_conta.id
                                 , est_log_generico  => est_log_generico );
         --
      end if;
      --
   end if;
   --
   vn_fase := 22;
   --
   if nvl(en_pcreferen_id,0) = 0 then
      --
      vn_fase := 23.1;
      --
      gv_mensagem_log := 'Identificador do Plano de Conta Referenciado não informado.';
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => gt_row_plano_conta.id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
       --
       -- Armazena o "loggenerico_id" na memória
       pkb_gt_log_generico_cad ( en_loggenerico    => gt_row_plano_conta.id
                               , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(en_pcreferen_id,0) > 0 and
      trim(ev_atributo) = 'DT_INI' and
      vd_dt_ini is not null  and
      vv_mensagem is null then
      --
      vn_fase := 99.1;
      --
      update pc_referen pr
         set pr.dt_ini = vd_dt_ini
       where pr.id = en_pcreferen_id;
      --
   end if;
   --
   vn_fase := 99.2;
   --
   if nvl(en_pcreferen_id,0) > 0 and
      trim(ev_atributo) = 'DT_FIN' and
      vd_dt_fin is not null  and
      vv_mensagem is null then
      --
      vn_fase := 99.11;
      --
      update pc_referen pr
         set pr.dt_fin = vd_dt_fin
       where pr.id = en_pcreferen_id;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_integr_pc_referen_ff fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
        --
        pkb_log_generico_cad ( sn_loggenericocad_id  => gt_row_plano_conta.id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_validacao
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => gt_row_plano_conta.empresa_id
                              );
        --
        -- Armazena o "loggenerico_id" na memória
        pkb_gt_log_generico_cad ( en_loggenerico    => gt_row_plano_conta.id
                                , est_log_generico  => est_log_generico );
      exception
         when others then
            null;
      end;
      --
END pkb_integr_pc_referen_ff;
*/

-------------------------------------------------------------------------------------------------------
-- Procedimento integra as informações do Plano de Contas Referencial
procedure pkb_integr_pc_referen ( est_log_generico    in out nocopy  dbms_sql.number_table
                                , est_row_pc_referen  in out nocopy  PC_Referen%rowtype
                                , en_empresa_id       in             Empresa.id%TYPE
                                , ev_cod_ent_ref      in             Cod_Ent_Ref.Cod_Ent_Ref%TYPE
                                , ev_cod_cta_ref      in             Plano_Conta_Ref_Ecd.cod_cta_ref%TYPE
                                , ev_cod_ccus         in             Centro_Custo.cod_ccus%TYPE 
                                , en_loteintws_id     in             lote_int_ws.id%type default 0
                                )
is
   --
   vn_fase              number := 0;
   vn_loggenericocad_id Log_Generico_Cad.id%type;
   vn_id                pc_referen.id%type;
   vv_nro_lote          varchar2(30) := null;
   --
begin
   -- REGRA_COD_CCUS_COD_CTA_REF_DUPLICIDADE - Verifica se o registro não é duplicado considerando a chave  COD_ENT+COD_CCUS + COD_CTA_REF.
   -- Integridade garantida na UNIQUE
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_cabec_log := 'Conta Referência ' || ev_cod_cta_ref || vv_nro_lote;
   --
   gv_obj_referencia := 'PLANO_CONTA';
   --
   vn_fase := 1;
   -- Verifica se foi informado o ID do Plano de Contas PAI
   if nvl(est_row_pc_referen.planoconta_id,0) = 0 then
      --
      vn_fase := 1.1;
      --
      gv_mensagem_log := 'Não foi informado a conta contábil para o registro do Plano de Contas Referencial.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 1.2;
   -- Válida se a empresa é válida
   if pk_csf.fkg_empresa_id_valido ( en_empresa_id => en_empresa_id ) = false then
      --
      vn_fase := 1.3;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Empresa" ('||en_empresa_id||') está incorreta para o Plano de Contas Referencial.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 1.4;
   -- Válida o campo codentref_id - Código da inst. respons. pela manut. plano de contas
   est_row_pc_referen.codentref_id := pk_csf_ecd.fkg_cod_ent_ref_id ( ev_cod => ev_cod_ent_ref );
   --
   vn_fase := 1.5;
   --
   if nvl(est_row_pc_referen.codentref_id,0) = 0 then
      --
      vn_fase := 1.6;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Código da instituição responsável pela manutenção do plano de contas referencial" está inválido ('||ev_cod_ent_ref||').';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 1.7;
   -- Válida o Código da conta de acordo com o plano de contas referencial
   est_row_pc_referen.planocontarefecd_id := pk_csf_ecd.fkg_plano_conta_ref_ecd_id ( ev_cod_cta_ref  => ev_cod_cta_ref
                                                                                   , en_codentref_id => est_row_pc_referen.codentref_id
                                                                                   );
   --
   vn_fase := 1.8;
   --
   if nvl(est_row_pc_referen.planocontarefecd_id,0) = 0 then
      --
      vn_fase := 1.9;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Código da conta de acordo com o plano de contas referencial" está inválido ('||ev_cod_cta_ref||').';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 1.11;
   -- Válida o Código do centro de custo
   est_row_pc_referen.centrocusto_id := pk_csf_ecd.fkg_centro_custo_id ( en_empresa_id  => en_empresa_id
                                                                       , ev_cod_ccus    => ev_cod_ccus );
   --
   vn_fase := 1.12;
   --
   if nvl(est_row_pc_referen.centrocusto_id,0) = 0 and trim(ev_cod_ccus) is not null then
      --
      vn_fase := 1.13;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Código do centro de custo" está inválido ('||ev_cod_ccus||').';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2;
   --
   -- Verifica se já existe a informação do plano de contas referenciado
   est_row_pc_referen.id := pk_csf_ecd.fkg_pc_referen_id ( en_planoconta_id       => est_row_pc_referen.planoconta_id
                                                         , en_codentref_id        => est_row_pc_referen.codentref_id
                                                         , en_planocontarefecd_id => est_row_pc_referen.planocontarefecd_id
                                                         , en_centrocusto_id      => est_row_pc_referen.centrocusto_id
                                                         , ed_dt_ini              => null
                                                         , ed_dt_fin              => null );
   --
   vn_fase := 3;
   --
   if nvl(est_row_pc_referen.id,0) <= 0 then
      --
      select pcreferen_seq.nextval
        into est_row_pc_referen.id
        from dual;
      --
   end if;
   --
   gn_referencia_id := est_row_pc_referen.planoconta_id;
   --
   vn_fase := 4;
   -- REGRA_REGISTRO_PARA_CONTA_ANALITICA - O registro somente poderá existir quando o valor do campo IND_CTA do Registro I050 = "A"
   if pk_csf_ecd.fkg_plano_conta_ind_cta ( en_planoconta_id => est_row_pc_referen.planoconta_id ) <> 'A' then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O registro do Plano de Contas Referencial somente poderá existir para contas contábeis Analiticas.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_log_generico.count,0) = 0 then
      --
      vn_fase := 99.1;
      --
      -- Se não existe, insere o registro.
      if pk_csf.fkg_existe_pc_referen ( en_pcreferen_id => est_row_pc_referen.id ) = false then
         --
         vn_fase := 99.2;
         -- Verificar se existe o registro pela chave - uk - da tabela.
         begin
            select pr.id
              into vn_id
              from pc_referen pr
             where pr.planoconta_id         = est_row_pc_referen.planoconta_id
               and pr.codentref_id          = est_row_pc_referen.codentref_id
               and pr.planocontarefecd_id   = est_row_pc_referen.planocontarefecd_id
               and nvl(pr.centrocusto_id,0) = nvl(est_row_pc_referen.centrocusto_id,0);
         exception
            when no_data_found then
               vn_id := 0;
            when others then
               --
               vn_fase := 99.3;
               --
               gv_mensagem_log := null;
               --
               gv_mensagem_log := 'Problemas ao identificar Plano Referenciado pela UK (fase = '||vn_fase||').';
               --
               vn_loggenericocad_id := null;
               --
               pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                    , ev_mensagem           => gv_cabec_log
                                    , ev_resumo             => gv_mensagem_log
                                    , en_tipo_log           => erro_de_validacao
                                    , en_referencia_id      => gn_referencia_id
                                    , ev_obj_referencia     => gv_obj_referencia
                                    , en_empresa_id         => gt_row_plano_conta.empresa_id
                                    );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                       , est_log_generico  => est_log_generico );
               --
         end;
         --
         vn_fase := 99.4;
         --
         if nvl(vn_id,0) = 0 then -- não encontrado plano referenciado pela UK
            --
            vn_fase := 99.5;
            --
            insert into pc_referen ( id
                                   , planoconta_id
                                   , codentref_id
                                   , planocontarefecd_id
                                   , centrocusto_id
                                   )
                            values ( est_row_pc_referen.id
                                   , est_row_pc_referen.planoconta_id
                                   , est_row_pc_referen.codentref_id
                                   , est_row_pc_referen.planocontarefecd_id
                                   , est_row_pc_referen.centrocusto_id
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
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_pc_referen fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                     , ev_mensagem        => gv_cabec_log
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => erro_de_sistema
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia
                                     , en_empresa_id      => gt_row_plano_conta.empresa_id
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_pc_referen;

-------------------------------------------------------------------------------------------------------
-- Procedimento integra as informações do Plano de Contas Referencial por Periodo  
procedure pkb_integr_pc_referen_period ( est_log_generico    in out nocopy  dbms_sql.number_table
                                       , est_row_pc_referen  in out nocopy  PC_Referen%rowtype
                                       , en_empresa_id       in             Empresa.id%TYPE
                                       , ev_cod_ent_ref      in             Cod_Ent_Ref.Cod_Ent_Ref%TYPE
                                       , ev_cod_cta_ref      in             Plano_Conta_Ref_Ecd.cod_cta_ref%TYPE
                                       , ev_cod_ccus         in             Centro_Custo.cod_ccus%TYPE
                                       , en_loteintws_id     in             lote_int_ws.id%type default 0
                                       )
is
   --
   vn_fase              number := 0;
   vn_loggenericocad_id Log_Generico_Cad.id%type;
   vn_id                pc_referen.id%type;
   vv_nro_lote          varchar2(30) := null;
   vn_count_pcreferen   number;
   VD_DT_INI_ECD        plano_conta_ref_ecd.dt_ini%type;
   VD_DT_FIN_ECD        plano_conta_ref_ecd.dt_ini%type;
   vv_cod_cta_ref       plano_conta_ref_ecd.cod_cta_ref%type;
   --
begin
   --
   vn_fase := 1;
   --
   -- REGRA_COD_CCUS_COD_CTA_REF_DUPLICIDADE - Verifica se o registro não é duplicado considerando a chave  COD_ENT+COD_CCUS + COD_CTA_REF.
   -- Integridade garantida na UNIQUE
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_cabec_log := 'Conta Referência ' || ev_cod_cta_ref || vv_nro_lote;
   --
   gv_obj_referencia := 'PLANO_CONTA';
   --
   vn_fase := 1;
   -- Verifica se foi informado o ID do Plano de Contas PAI
   if nvl(est_row_pc_referen.planoconta_id,0) = 0 then
      --
      vn_fase := 1.1;
      --
      gv_mensagem_log := 'Não foi informado a conta contábil para o registro do Plano de Contas Referencial.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 1.2;
   -- Válida se a empresa é válida
   if pk_csf.fkg_empresa_id_valido ( en_empresa_id => en_empresa_id ) = false then
      --
      vn_fase := 1.3;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Empresa" ('||en_empresa_id||') está incorreta para o Plano de Contas Referencial.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 1.4;
   --
   -- Válida o campo codentref_id - Código da inst. respons. pela manut. plano de contas
   est_row_pc_referen.codentref_id := pk_csf_ecd.fkg_cod_ent_ref_id ( ev_cod => ev_cod_ent_ref );
   --
   vn_fase := 1.5;
   --
   if nvl(est_row_pc_referen.codentref_id,0) = 0 then
      --
      vn_fase := 1.6;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Código da instituição responsável pela manutenção do plano de contas referencial" está inválido ('||ev_cod_ent_ref||').';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 1.7;
   --
   -- Válida o Código da conta de acordo com o plano de contas referencial
   est_row_pc_referen.planocontarefecd_id := pk_csf_ecd.fkg_plano_conta_ref_ecd_id ( ev_cod_cta_ref  => ev_cod_cta_ref
                                                                                   , en_codentref_id => est_row_pc_referen.codentref_id
                                                                                   );
   --
   vn_fase := 1.8;
   --
   if nvl(est_row_pc_referen.planocontarefecd_id,0) = 0 then
      --
      vn_fase := 1.9;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Código da conta de acordo com o plano de contas referencial" está inválido ('||ev_cod_cta_ref||').';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 1.11;
   -- Válida o Código do centro de custo
   est_row_pc_referen.centrocusto_id := pk_csf_ecd.fkg_centro_custo_id ( en_empresa_id  => en_empresa_id
                                                                       , ev_cod_ccus    => ev_cod_ccus );
   --
   vn_fase := 1.12;
   --
   if nvl(est_row_pc_referen.centrocusto_id,0) = 0 and trim(ev_cod_ccus) is not null then
      --
      vn_fase := 1.13;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Código do centro de custo" está inválido ('||ev_cod_ccus||').';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2;
   --
   -- Verifica se já existe a informação do plano de contas referenciado
   est_row_pc_referen.id := pk_csf_ecd.fkg_pc_referen_id ( en_planoconta_id       => est_row_pc_referen.planoconta_id
                                                         , en_codentref_id        => est_row_pc_referen.codentref_id
                                                         , en_planocontarefecd_id => est_row_pc_referen.planocontarefecd_id
                                                         , en_centrocusto_id      => est_row_pc_referen.centrocusto_id
                                                         , ed_dt_ini              => est_row_pc_referen.dt_ini
                                                         , ed_dt_fin              => est_row_pc_referen.dt_fin 
                                                         );
   --
   vn_fase := 3;
   --
   if nvl(est_row_pc_referen.id,0) <= 0 then
      --
      select pcreferen_seq.nextval
        into est_row_pc_referen.id
        from dual;
      --
   end if;
   --
   gn_referencia_id := est_row_pc_referen.planoconta_id;
   --
   vn_fase := 4;
   -- REGRA_REGISTRO_PARA_CONTA_ANALITICA - O registro somente poderá existir quando o valor do campo IND_CTA do Registro I050 = "A"
   if pk_csf_ecd.fkg_plano_conta_ind_cta ( en_planoconta_id => est_row_pc_referen.planoconta_id ) <> 'A' then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O registro do Plano de Contas Referencial somente poderá existir para contas contábeis Analiticas.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   --
   vd_dt_ini_ecd := null;
   vd_dt_fin_ecd := null;
   --
   begin
      --
      select pc.dt_ini
           , pc.dt_fin
           , pc.COD_CTA_REF
        into vd_dt_ini_ecd
           , vd_dt_fin_ecd
           , vv_cod_cta_ref
        from plano_conta_ref_ecd pc
       where pc.id = gt_row_pc_referen.planocontarefecd_id;
       --
   exception
    when others then
      vd_dt_ini_ecd := null;
      vd_dt_fin_ecd := null;
   end;
   --
   vn_fase := 6.1;
   --
   if ( trunc(gt_row_pc_referen.dt_ini) > vd_dt_ini_ecd
          and trunc(gt_row_pc_referen.dt_ini) > vd_dt_fin_ecd )
        or
         (trunc(gt_row_pc_referen.dt_fin) < vd_dt_ini_ecd
          and trunc(gt_row_pc_referen.dt_fin) < vd_dt_fin_ecd ) then
      --
      vn_fase := 6.2;
      --
      gv_mensagem_log := 'Esta sendo Referenciado um Plano de Conta do ECD em um periodo de '|| to_date(gt_row_pc_referen.dt_ini,'dd/mm/yyyy')||
                         ' até '|| to_date(gt_row_pc_referen.dt_fin,'dd/mm/yyyy') ||' e o periodo de vigencia deste plano de Conta ECD (COD_CTA: '|| vv_cod_cta_ref||
                         ') é de ' || to_date(vd_dt_ini_ecd,'dd/mm/yyyy')|| ' até '||to_date(vd_dt_fin_ecd,'dd/mm/yyyy');
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_mensagem_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gt_row_pc_referen.planoconta_id
                           , ev_obj_referencia     => 'PLANO_CONTA'
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_count_pcreferen := null;
   -- Criar regra de validação do plano referencial onde: verificar se uma mesma conta contábil
   -- possui conta referencial com e sem centro de custos em vigência, se existir deverá ser gerado
   -- erro de validação informando que Não pode haver conta referencial com e sem centro de custo no mesmo
   -- período e exibir a conta e centro de custo.
   begin
      --
      select count(1)
        into vn_count_pcreferen
        from pc_referen
       where planoconta_id = gt_row_pc_referen.planoconta_id
         and nvl(centrocusto_id,0) = nvl(gt_row_pc_referen.centrocusto_id,0)
         and planocontarefecd_id not in gt_row_pc_referen.planocontarefecd_id
         and ( trunc(dt_ini) between gt_row_pc_referen.dt_ini and gt_row_pc_referen.dt_fin
           or trunc(nvl(dt_fin,sysdate)) between gt_row_pc_referen.dt_ini and gt_row_pc_referen.dt_fin
           or gt_row_pc_referen.dt_ini between trunc(dt_ini) and trunc(nvl(dt_fin,sysdate))
           or gt_row_pc_referen.dt_fin between trunc(dt_ini) and trunc(nvl(dt_fin,sysdate)));
      --
   exception
    when others then
      vn_count_pcreferen := null;
   end;
   --
   vn_fase := 7;
   --
   if nvl(vn_count_pcreferen,0) > 0 then
      --
      gv_mensagem_log := 'Já existe Referência para este Plano de Conta ('|| pk_csf.fkg_cd_plano_conta ( gt_row_pc_referen.planoconta_id) ||') e Centro de Custo ('||
                         pk_csf.fkg_cd_centro_custo (gt_row_pc_referen.centrocusto_id )|| ') Relacionado ao Periodo Integrado, Favor verificar.' ;
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_mensagem_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gt_row_pc_referen.planoconta_id
                           , ev_obj_referencia     => 'PLANO_CONTA'
                           , en_empresa_id         => gt_row_plano_conta.empresa_id
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 99.1;
   -- Se não existe, insere o registro.
   if pk_csf.fkg_existe_pc_referen ( en_pcreferen_id => est_row_pc_referen.id ) = false then
      --
      vn_fase := 99.2;
      -- Verificar se existe o registro pela chave - uk - da tabela.
      begin
         select pr.id
           into vn_id
           from pc_referen pr
          where pr.planoconta_id         = est_row_pc_referen.planoconta_id
            and pr.codentref_id          = est_row_pc_referen.codentref_id
            and pr.planocontarefecd_id   = est_row_pc_referen.planocontarefecd_id
            and nvl(pr.centrocusto_id,0) = nvl(est_row_pc_referen.centrocusto_id,0)
            and pr.dt_ini                = est_row_pc_referen.dt_ini
            and nvl(pr.dt_fin,sysdate)   = nvl(est_row_pc_referen.dt_fin,sysdate);
      exception
         when no_data_found then
            vn_id := 0;
         when others then
            --
            vn_fase := 99.3;
            --
            gv_mensagem_log := null;
            --
            gv_mensagem_log := 'Problemas ao identificar Plano Referenciado pela UK (fase = '||vn_fase||').';
            --
            vn_loggenericocad_id := null;
            --
            pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                 , ev_mensagem           => gv_cabec_log
                                 , ev_resumo             => gv_mensagem_log
                                 , en_tipo_log           => erro_de_validacao
                                 , en_referencia_id      => gn_referencia_id
                                 , ev_obj_referencia     => gv_obj_referencia
                                 , en_empresa_id         => gt_row_plano_conta.empresa_id
                                 );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                    , est_log_generico  => est_log_generico );
            --
      end;
      --
      vn_fase := 99.4;
      --
      if nvl(vn_id,0) = 0 then -- não encontrado plano referenciado pela UK
         --
         vn_fase := 99.5;
         --
         insert into pc_referen ( id
                                , planoconta_id
                                , codentref_id
                                , planocontarefecd_id
                                , centrocusto_id
                                , dt_ini
                                , dt_fin
                                )
                         values ( est_row_pc_referen.id
                                , est_row_pc_referen.planoconta_id
                                , est_row_pc_referen.codentref_id
                                , est_row_pc_referen.planocontarefecd_id
                                , est_row_pc_referen.centrocusto_id
                                , est_row_pc_referen.dt_ini
                                , est_row_pc_referen.dt_fin
                                );
         --
      else
         --
         update pc_referen set planoconta_id       = est_row_pc_referen.planoconta_id
                             , codentref_id        = est_row_pc_referen.codentref_id        
                             , planocontarefecd_id = est_row_pc_referen.planocontarefecd_id 
                             , centrocusto_id      = est_row_pc_referen.centrocusto_id
                             , dt_ini              = est_row_pc_referen.dt_ini
                             , dt_fin              = est_row_pc_referen.dt_fin
                         where id                  = est_row_pc_referen.id; 
         --
      end if;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_pc_referen_period fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_sistema
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => en_empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_pc_referen_period;

-------------------------------------------------------------------------------------------------------
-- Procedimento integra as informações do Plano de Contas
procedure pkb_integr_Plano_Conta ( est_log_generico     in out nocopy  dbms_sql.number_table
                                 , est_row_Plano_Conta  in out nocopy  Plano_Conta%rowtype
                                 , ev_cod_nat           in             Cod_Nat_PC.cod_nat%TYPE
                                 , ev_cod_cta_sup       in             Plano_Conta.Cod_Cta%TYPE
                                 , ed_dt_fim_reg_0000   in             Abertura_ECD.dt_fim%TYPE 
                                 , en_loteintws_id      in             lote_int_ws.id%type default 0
                                 )
is
   --
   vn_fase              number := 0;
   vn_loggenericocad_id Log_Generico_Cad.id%type;
   vn_nivel_sup         Plano_Conta.nivel%TYPE;
   vv_nro_lote          varchar2(30) := null;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'PLANO_CONTA';
   -- Montagem o cabeçalho da mensgagem de log
   gv_cabec_log := 'Código da conta: ' || est_row_Plano_Conta.cod_cta || vv_nro_lote;
   --
   vn_fase := 1.1;
   -- Válida se a empresa é válida
   if pk_csf.fkg_empresa_id_valido ( en_empresa_id => est_row_Plano_Conta.empresa_id ) = false then
      --
      vn_fase := 1.2;
      --
      gv_mensagem_log := '"Empresa" ('||est_row_Plano_Conta.empresa_id||') está incorreta para o Plano de Contas.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => null
                           , ev_obj_referencia     => gv_obj_referencia 
                           , en_empresa_id         => est_row_Plano_Conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 1.3;
   --
   est_row_Plano_Conta.cod_cta := trim( pk_csf.fkg_converte( est_row_Plano_Conta.cod_cta ) );
   -- Válida cod_cta
   if est_row_Plano_Conta.cod_cta is null then
      --
      vn_fase := 1.4;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Código da conta analítica/grupo de contas" não informado para o Plano de Contas.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => null
                           , ev_obj_referencia     => gv_obj_referencia 
                           , en_empresa_id         => est_row_Plano_Conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 1.5;
   --
   est_row_Plano_Conta.id := pk_csf_ecd.fkg_plano_conta_id ( en_empresa_id  => est_row_Plano_Conta.empresa_id
                                                           , ev_cod_cta     => est_row_Plano_Conta.cod_cta );
   --
   vn_fase := 1.6;
   --
   -- Verificar se já existe o plano de contas
   if nvl(est_row_Plano_Conta.id,0) <= 0 then
      --
      select planoconta_seq.nextval
        into est_row_Plano_Conta.id
        from dual;
      --
   end if;
   --
   gn_referencia_id := est_row_Plano_Conta.id;
   --
   vn_fase := 1.7;
   --
   delete from log_generico_cad
    where referencia_id  = gn_referencia_id
      and obj_referencia = gv_obj_referencia;
   --
   vn_fase := 2;
   -- Válida a dt_inc_alt
   if est_row_Plano_Conta.dt_inc_alt is null then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := '"Data da inclusão/alteração da Conta Contábil" não informada para o Plano de Contas.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia 
                           , en_empresa_id         => est_row_Plano_Conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 2.2;
   -- REGRA_DT_ALT_DATA_MAIOR - Verifica se DT_ALT<=DT_FIN do Registro 0000
   if est_row_Plano_Conta.dt_inc_alt > ed_dt_fim_reg_0000 then
      --
      vn_fase := 2.3;
      --
      gv_mensagem_log := '"Data da inclusão/alteração da Conta Contábil" não pode ser maior que a Data Final das informações contidas no arquivo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia 
                           , en_empresa_id         => est_row_Plano_Conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 3;
   -- Válida o dm_cod_nat -- REGRA_TABELA_NATUREZA
   -- 01-Contas de ativo
   -- 02-Contas de passivo
   -- 03-Patrimônio Líquido
   -- 04-Contas de resultado
   -- 05-Contas de compensação
   -- 09-Outras
   est_row_Plano_Conta.codnatpc_id := pk_csf_ecd.fkg_cod_nat_pc_id ( ev_cod_nat => ev_cod_nat );
   --
   vn_fase := 3.1;
   --
   if nvl(est_row_Plano_Conta.codnatpc_id,0) <= 0 then
      --
      vn_fase := 3.2;
      --
      gv_mensagem_log := '"Código da natureza da conta/grupo de contas" ('||ev_cod_nat||') está inválida para o Plano de Contas.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_Plano_Conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   -- Válida o dm_ind_cta
   -- S - Sintética (grupo de contas); A - Analítica (conta)
   if est_row_Plano_Conta.dm_ind_cta not in ('A', 'S') then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := '"Indicador do tipo de conta" ('||est_row_Plano_Conta.dm_ind_cta||') está inválido para o Plano de Contas.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia 
                           , en_empresa_id         => est_row_Plano_Conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 5;
   --
   -- Válida o nivel
   -- REGRA_MAIOR_QUE_UM - Verifica se o valor informado para o campo é maior ou igual a 1.
   if est_row_Plano_Conta.nivel is null or nvl(est_row_Plano_Conta.nivel,0) <= 0 then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := '"Nível da conta analítica/grupo de contas" ('||est_row_Plano_Conta.nivel||') está inválido para o Plano de Contas.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia 
                           , en_empresa_id         => est_row_Plano_Conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 7;
   --
   est_row_Plano_Conta.descr_cta := trim( pk_csf.fkg_converte( est_row_Plano_Conta.descr_cta ) );
   -- Válida descr_cta
   if est_row_Plano_Conta.descr_cta is null then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := '"Descrição da conta analítica/grupo de contas" não informado para o Plano de Contas.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia 
                           , en_empresa_id         => est_row_Plano_Conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 8;
   -- Busca o código superior da conta
   -- Já aplica a REGRA_CODIGO_CONTA_NIVEL_SUPERIOR_INVALIDO (verifica se existe)
   est_row_Plano_Conta.planoconta_id_sup := pk_csf_ecd.fkg_plano_conta_id ( en_empresa_id  => est_row_Plano_Conta.empresa_id
                                                                          , ev_cod_cta     => ev_cod_cta_sup );
   --
   vn_fase := 8.1;
   -- REGRA_COD_CTA_SUP_OBRIGATORIO - Se o nível > 1 a conta superior é obrigatória
   if nvl(est_row_Plano_Conta.nivel,0) > 1 and nvl(est_row_Plano_Conta.planoconta_id_sup,0) = 0 then
      --
      vn_fase := 8.2;
      --
      gv_mensagem_log := 'Nível da conta contábil é maior que 1, então é obrigatório a informação da Conta Contábil Superior para o Plano de Contas.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia 
                           , en_empresa_id         => est_row_Plano_Conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 8.3;
   -- REGRA_CTA_DE_NIVEL_SUPERIOR_INVALIDA
   -- Verifica se NIVEL > 1, se afirmativo verifica regras:
   if nvl(est_row_Plano_Conta.nivel,0) > 1 and nvl(est_row_Plano_Conta.planoconta_id_sup,0) > 0 then
      --
      vn_fase := 8.4;
      -- REGRA_CONTA_NIVEL_SUPERIOR_NAO_SINTETICA
      -- Verifica se NIVEL > 1, se afirmativo localizar o registro em que o campo  (COD_CTA) tenha o mesmo valor do campo
      -- (COD_CTA_SUP). Neste registro, o campo (IND_CTA) deve ser igual a "S".
      -- Conta superior obrigatóriamente deve ser sintética
      if pk_csf_ecd.fkg_plano_conta_ind_cta ( en_planoconta_id => est_row_Plano_Conta.planoconta_id_sup ) <> 'S' then
         --
         vn_fase := 8.5;
         --
         gv_mensagem_log := 'A Conta Contábil Superior deve obrigatóriamente ser SINTÉTICA para o Plano de Contas.';
         --
         vn_loggenericocad_id := null;
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_validacao
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia 
                              , en_empresa_id         => est_row_Plano_Conta.empresa_id
                              );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                 , est_log_generico  => est_log_generico );
         --
      end if;
      --
      vn_fase := 8.6;
      -- REGRA_NIVEL_DE_CONTA_NIVEL_SUPERIOR_INVALIDO
      -- Verifica se NÍVEL > 1, se afirmativo localizar o registro em que o campo (COD_CTA) tenha o mesmo valor do campo
      -- (COD_CTA_SUP). Neste registro, o campo NIVEL deve ser menor que o NIVEL ATUAL
      vn_nivel_sup := pk_csf_ecd.fkg_plano_conta_nivel ( en_planoconta_id => est_row_Plano_Conta.planoconta_id_sup );
      --
      vn_fase := 8.7;
      --
      if vn_nivel_sup >= est_row_Plano_Conta.nivel then
         --
         vn_fase := 8.71;
         --
         if nvl(vn_nivel_sup,0) = 99 then
            --
            gv_mensagem_log := 'Nível da Conta Superior indicando "99". Verificar se a informação está correta. Plano de conta Superior '||ev_cod_cta_sup||'.';
            --
            vn_loggenericocad_id := null;
            --
            pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                                 , ev_mensagem           => gv_cabec_log
                                 , ev_resumo             => gv_mensagem_log
                                 , en_tipo_log           => erro_de_validacao
                                 , en_referencia_id      => gn_referencia_id
                                 , ev_obj_referencia     => gv_obj_referencia
                                 , en_empresa_id         => est_row_Plano_Conta.empresa_id
                                 );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                    , est_log_generico  => est_log_generico );
            --
         else
            --
            vn_fase := 8.72;
            --
            est_row_Plano_Conta.nivel := vn_nivel_sup + 1 ;
            --
         end if;
         --
      end if;
      --
   end if;
   --
   vn_fase := 8.8;
   --
   if nvl(est_row_Plano_Conta.nivel,0) > 2 and nvl(est_row_Plano_Conta.planoconta_id_sup,0) > 0 then
      --
      vn_fase := 8.9;
      -- Verifica se NIVEL > 2, se afirmativo verifica a regra: REGRA_NATUREZA_CONTA
      -- Verifica se a conta de nível superior tem a mesma natureza (campo COD_NAT) da subconta
      if pk_csf_ecd.fkg_plano_conta_cod_nat ( en_planoconta_id => est_row_Plano_Conta.planoconta_id_sup ) <> lpad(nvl(ev_cod_nat,'0'), 2, '0') then
         --
         vn_fase := 8.10;
         --
         gv_mensagem_log := 'A Conta Contábil Superior deve ter o mesmo "Código da natureza" que a subconta para o Plano de Contas.';
         --
         vn_loggenericocad_id := null;
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_validacao
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia 
                              , en_empresa_id         => est_row_Plano_Conta.empresa_id
                              );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                 , est_log_generico  => est_log_generico );
         --
      end if;
      --
   end if;
   --
   vn_fase := 9;
   --
   if trim(ev_cod_cta_sup) = trim(est_row_Plano_Conta.cod_cta) then
      --
      vn_fase := 9.1;
      --
      est_row_Plano_Conta.planoconta_id_sup := null;
      --
      gv_mensagem_log := 'Código da Conta ' || est_row_Plano_Conta.cod_cta || ' não pode ser igual ao da Conta Superior ' || ev_cod_cta_sup;
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia 
                           , en_empresa_id         => est_row_Plano_Conta.empresa_id
                           );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   --
   vn_fase := 10;
   --
   -- #70595 inclusao de validacao do campo dt_hr_alter
   if est_row_Plano_Conta.DT_HR_ALTER is not null
    and est_row_Plano_Conta.DT_HR_ALTER > sysdate then
       --
       vn_fase := 10.1;
       --
       gv_mensagem_log := '"Data/Hora de entrada no compliance " ('||est_row_Plano_Conta.DT_HR_ALTER||') não pode ser maior que a data atual.';
       --
       vn_loggenericocad_id := null;
       --
       pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => erro_de_validacao
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia
                           , en_empresa_id         => est_row_Plano_Conta.empresa_id
                           );
       --
       -- Armazena o "loggenerico_id" na memória
       pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                               , est_log_generico  => est_log_generico );
       --
   elsif est_row_Plano_Conta.DT_HR_ALTER is null then
      est_row_Plano_Conta.DT_HR_ALTER := sysdate ;  
   end if;
   --
   vn_fase := 99;
   -- Se não existe registro do Log e o Tipo de Integração ECD é (válida e insere)
   if nvl(est_log_generico.count,0) = 0 then
      --
      est_row_Plano_Conta.dm_st_proc := 1; -- Validado    
      --
   else
      --
      est_row_Plano_Conta.dm_st_proc := 2;
      --
   end if;
   --
   vn_fase := 99.1;
   --
   if nvl(est_row_Plano_Conta.empresa_id,0) > 0 and
      nvl(est_row_Plano_Conta.codnatpc_id,0) > 0 and
      trim(est_row_Plano_Conta.dt_inc_alt) is not null and
      trim(est_row_Plano_Conta.dm_ind_cta) in ('A','S') and
      nvl(est_row_Plano_Conta.nivel,0) > 0 then
      --
      -- Calcula a quantidade de registros totais integrados para ser
      -- mostrado na tela de agendamento.
      --
      begin
         pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
      exception
         when others then
            null;
      end;
      --
      vn_fase := 99.2;
      -- Se não existe, insere o registro
      if pk_csf.fkg_existe_plano_conta ( en_planoconta_id => est_row_Plano_Conta.id ) = false then
         --
         vn_fase := 99.3;
         --
         insert into Plano_Conta ( id
                                 , empresa_id
                                 , dt_inc_alt
                                 , codnatpc_id
                                 , dm_ind_cta
                                 , nivel
                                 , cod_cta
                                 , planoconta_id_sup
                                 , descr_cta
                                 , dm_st_proc
                                 , dt_hr_alter --#70595 
                                 )
                          values ( est_row_Plano_Conta.id
                                 , est_row_Plano_Conta.empresa_id
                                 , est_row_Plano_Conta.dt_inc_alt
                                 , est_row_Plano_Conta.codnatpc_id
                                 , est_row_Plano_Conta.dm_ind_cta
                                 , est_row_Plano_Conta.nivel
                                 , est_row_Plano_Conta.cod_cta
                                 , est_row_Plano_Conta.planoconta_id_sup
                                 , est_row_Plano_Conta.descr_cta
                                 , est_row_Plano_Conta.dm_st_proc
                                 , est_row_plano_conta.dt_hr_alter --#70595 
                                 );
         --
      else
         -- Se existe, atualiza o registro
         vn_fase := 99.5;
         --
         update Plano_Conta set dt_inc_alt         = est_row_Plano_Conta.dt_inc_alt
                              , dm_ind_cta         = est_row_Plano_Conta.dm_ind_cta
                              , codnatpc_id        = est_row_Plano_Conta.codnatpc_id
                              , nivel              = est_row_Plano_Conta.nivel
                              , cod_cta            = est_row_Plano_Conta.cod_cta
                              , planoconta_id_sup  = est_row_Plano_Conta.planoconta_id_sup
                              , descr_cta          = est_row_Plano_Conta.descr_cta
                              , dm_st_proc         = est_row_Plano_Conta.dm_st_proc
                              , dt_hr_alter        = est_row_plano_conta.dt_hr_alter --#70595 
          where id = est_row_Plano_Conta.id;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_cad.pkb_integr_Plano_Conta fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem        => gv_cabec_log
                              , ev_resumo          => gv_mensagem_log
                              , en_tipo_log        => erro_de_sistema
                              , en_referencia_id   => gn_referencia_id
                              , ev_obj_referencia  => gv_obj_referencia
                              , en_empresa_id         => est_row_Plano_Conta.empresa_id
                              );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_integr_Plano_Conta;

-------------------------------------------------------------------------------------------------------
--| Procedimento para gravar o log referente as inclusões/alterações das unidades
procedure pkb_inclui_log_unidade( en_unidade_id  in log_unidade.unidade_id%type
                                , ev_resumo      in log_unidade.resumo%type
                                , ev_mensagem    in log_unidade.mensagem%type
                                , en_usuario_id  in log_unidade.usuario_id%type
                                , ev_maquina     in log_unidade.maquina%type ) is
   --
   pragma   autonomous_transaction;
   --
begin
   --
   insert into log_unidade( id
                          , unidade_id
                          , dt_hr_log
                          , resumo
                          , mensagem
                          , usuario_id
                          , maquina )
                    values( logunidade_seq.nextval
                          , en_unidade_id
                          , sysdate
                          , ev_resumo
                          , ev_mensagem
                          , en_usuario_id
                          , ev_maquina );
   --
   commit;
   --
exception
   when others then
      raise_application_error (-20101, 'Problemas ao incluir log/alteração - pk_csf_api_cad.pkb_inclui_log_unidade (unidade_id = '||en_unidade_id||'). Erro = '||sqlerrm);
end pkb_inclui_log_unidade;

-------------------------------------------------------------------------------------------------------
--| Procedimento para gravar o log referente as inclusões/alterações dos dados de pessoas jurídicas
procedure pkb_inclui_log_juridica( en_juridica_id in log_juridica.juridica_id%type
                                 , ev_resumo      in log_juridica.resumo%type
                                 , ev_mensagem    in log_juridica.mensagem%type
                                 , en_usuario_id  in log_juridica.usuario_id%type
                                 , ev_maquina     in log_juridica.maquina%type ) is
   --
   pragma   autonomous_transaction;
   --
begin
   --
   insert into log_juridica( id
                           , juridica_id
                           , dt_hr_log
                           , resumo
                           , mensagem
                           , usuario_id
                           , maquina )
                     values( logjuridica_seq.nextval
                           , en_juridica_id
                           , sysdate
                           , ev_resumo
                           , ev_mensagem
                           , en_usuario_id
                           , ev_maquina );
   --
   commit;
   --
exception
   when others then
      raise_application_error (-20101, 'Problemas ao incluir log/alteração - pk_csf_api_cad.pkb_inclui_log_juridica (juridica_id = '||en_juridica_id||'). Erro = '||sqlerrm);
end pkb_inclui_log_juridica;

-------------------------------------------------------------------------------------------------------
--| Procedimento para gravar o log referente as inclusões/alterações dos itens/produtos
procedure pkb_inclui_log_item( en_item_id     in log_item.item_id%type
                             , ev_resumo      in log_item.resumo%type
                             , ev_mensagem    in log_item.mensagem%type
                             , en_usuario_id  in log_item.usuario_id%type
                             , ev_maquina     in log_item.maquina%type ) is
   --
   pragma   autonomous_transaction;
   --
begin
   --
   insert into log_item( id
                       , item_id
                       , dt_hr_log
                       , resumo
                       , mensagem
                       , usuario_id
                       , maquina )
                 values( logitem_seq.nextval
                       , en_item_id
                       , sysdate
                       , ev_resumo
                       , ev_mensagem
                       , en_usuario_id
                       , ev_maquina );
   --
   commit;
   --
exception
   when others then
      raise_application_error (-20101, 'Problemas ao incluir log/alteração - pk_csf_api_cad.pkb_inclui_log_item (item_id = '||en_item_id||'). Erro = '||sqlerrm);
end pkb_inclui_log_item;

-------------------------------------------------------------------------------------------------------
--| Procedimento para gravar o log referente as inclusões/alterações de pessoas
procedure pkb_inclui_log_pessoa( en_pessoa_id   in log_pessoa.pessoa_id%type
                               , ev_resumo      in log_pessoa.resumo%type
                               , ev_mensagem    in log_pessoa.mensagem%type
                               , en_usuario_id  in log_pessoa.usuario_id%type
                               , ev_maquina     in log_pessoa.maquina%type ) is
   --
   pragma   autonomous_transaction;
   --
begin
   --
   insert into log_pessoa( id
                         , pessoa_id
                         , dt_hr_log
                         , resumo
                         , mensagem
                         , usuario_id
                         , maquina )
                   values( logpessoa_seq.nextval
                         , en_pessoa_id
                         , sysdate
                         , ev_resumo
                         , ev_mensagem
                         , en_usuario_id
                         , ev_maquina );
   --
   commit;
   --
exception
   when others then
      raise_application_error (-20101, 'Problemas ao incluir log/alteração - pk_csf_api_cad.pkb_inclui_log_pessoa (pessoa_id = '||en_pessoa_id||'). Erro = '||sqlerrm);
end pkb_inclui_log_pessoa;

-------------------------------------------------------------------------------------------------------
--| Procedimento para gravar o log referente as inclusões/alterações dos dados de pessoas físicas
procedure pkb_inclui_log_fisica( en_fisica_id   in log_fisica.fisica_id%type
                               , ev_resumo      in log_fisica.resumo%type
                               , ev_mensagem    in log_fisica.mensagem%type
                               , en_usuario_id  in log_fisica.usuario_id%type
                               , ev_maquina     in log_fisica.maquina%type ) is
   --
   pragma   autonomous_transaction;
   --
begin
   --
   insert into log_fisica( id
                         , fisica_id
                         , dt_hr_log
                         , resumo
                         , mensagem
                         , usuario_id
                         , maquina )
                   values( logfisica_seq.nextval
                         , en_fisica_id
                         , sysdate
                         , ev_resumo
                         , ev_mensagem
                         , en_usuario_id
                         , ev_maquina );
   --
   commit;
   --
exception
   when others then
      raise_application_error (-20101, 'Problemas ao incluir log/alteração - pk_csf_api_cad.pkb_inclui_log_fisica (fisica_id = '||en_fisica_id||'). Erro = '||sqlerrm);
end pkb_inclui_log_fisica;

-------------------------------------------------------------------------------------------------------
--| Procedimento para gravar o log referente as inclusões/alterações dos dados da empresa
procedure pkb_inclui_log_empresa( en_empresa_id  in log_empresa.empresa_id%type
                                , ev_resumo      in log_empresa.resumo%type
                                , ev_mensagem    in log_empresa.mensagem%type
                                , en_usuario_id  in log_empresa.usuario_id%type
                                , ev_maquina     in log_empresa.maquina%type ) is
   --
   pragma   autonomous_transaction;
   --
begin
   --
   insert into log_empresa( id
                          , empresa_id
                          , dt_hr_log
                          , resumo
                          , mensagem
                          , usuario_id
                          , maquina )
                    values( logempresa_seq.nextval
                          , en_empresa_id
                          , sysdate
                          , ev_resumo
                          , ev_mensagem
                          , en_usuario_id
                          , ev_maquina );
   --
   commit;
   --
exception
   when others then
      raise_application_error (-20101, 'Problemas ao incluir log/alteração - pk_csf_api_cad.pkb_inclui_log_empresa (empresa_id = '||en_empresa_id||'). Erro = '||sqlerrm);
end pkb_inclui_log_empresa;

-------------------------------------------------------------------------------------------------------
--| Procedimento para gravar o log referente as inclusões/alterações dos dados da empresa
procedure pkb_inclui_log_ncm_nat_rec_pc( en_ncmnatrecpc_id  in log_ncm_nat_rec_pc.ncmnatrecpc_id%type
                                       , ev_resumo          in log_ncm_nat_rec_pc.resumo%type
                                       , ev_mensagem        in log_ncm_nat_rec_pc.mensagem%type
                                       , en_usuario_id      in log_ncm_nat_rec_pc.usuario_id%type
                                       , ev_maquina         in log_ncm_nat_rec_pc.maquina%type ) is
   --
   pragma   autonomous_transaction;
   --
begin
   --
   insert into log_ncm_nat_rec_pc( id
                                 , ncmnatrecpc_id
                                 , dt_hr_log
                                 , resumo
                                 , mensagem
                                 , usuario_id
                                 , maquina )
                           values( logncmnatrecpc_seq.nextval
                                 , en_ncmnatrecpc_id
                                 , sysdate
                                 , ev_resumo
                                 , ev_mensagem
                                 , en_usuario_id
                                 , ev_maquina );
   --
   commit;
   --
exception
   when others then
      raise_application_error (-20101, 'Problemas ao incluir log/alteração - pk_csf_api_cad.pkb_inclui_log_ncm_nat_rec_pc (ncmnatrecpc_id = '||en_ncmnatrecpc_id||'). Erro = '||sqlerrm);
end pkb_inclui_log_ncm_nat_rec_pc;

-------------------------------------------------------------------------------------------------------
--| Procedimento para gravar o log referente as inclusões/alterações dos dados do plano de conta
procedure pkb_inclui_log_plano_conta( en_planoconta_id  in log_plano_conta.planoconta_id%type
                                    , ev_resumo         in log_plano_conta.resumo%type
                                    , ev_mensagem       in log_plano_conta.mensagem%type
                                    , en_usuario_id     in log_plano_conta.usuario_id%type
                                    , ev_maquina        in log_plano_conta.maquina%type ) is
   --
   pragma   autonomous_transaction;
   --
begin
   --
   insert into log_plano_conta( id
                              , planoconta_id
                              , dt_hr_log
                              , resumo
                              , mensagem
                              , usuario_id
                              , maquina )
                        values( logplanoconta_seq.nextval
                              , en_planoconta_id
                              , sysdate
                              , ev_resumo
                              , ev_mensagem
                              , en_usuario_id
                              , ev_maquina );
   --
   commit;
   --
exception
   when others then
      raise_application_error (-20101, 'Problemas ao incluir log/alteração - pk_csf_api_cad.pkb_inclui_log_plano_conta (planoconta_id = '||en_planoconta_id||'). Erro = '||sqlerrm);
end pkb_inclui_log_plano_conta;

-------------------------------------------------------------------------------------------------------
--| Procedimento para gravar o log referente as inclusões/alterações dos dados do plano referencial
procedure pkb_inclui_log_pc_referen( en_pcreferen_id  in log_pc_referen.pcreferen_id%type
                                   , ev_resumo        in log_pc_referen.resumo%type
                                   , ev_mensagem      in log_pc_referen.mensagem%type
                                   , en_usuario_id    in log_pc_referen.usuario_id%type
                                   , ev_maquina       in log_pc_referen.maquina%type ) is
   --
   pragma   autonomous_transaction;
   --
begin
   --
   insert into log_pc_referen( id
                             , pcreferen_id
                             , dt_hr_log
                             , resumo
                             , mensagem
                             , usuario_id
                             , maquina )
                       values( logpcreferen_seq.nextval
                             , en_pcreferen_id
                             , sysdate
                             , ev_resumo
                             , ev_mensagem
                             , en_usuario_id
                             , ev_maquina );
   --
   commit;
   --
exception
   when others then
      raise_application_error (-20101, 'Problemas ao incluir log/alteração - pk_csf_api_cad.pkb_inclui_log_pc_referen (pcreferen_id = '||en_pcreferen_id||'). Erro = '||sqlerrm);
end pkb_inclui_log_pc_referen;

-------------------------------------------------------------------------------------------------------
procedure pkb_ret_multorg_id( est_log_generico       in out nocopy  dbms_sql.number_table
                            , ev_cod_mult_org        in             mult_org.cd%type
                            , ev_hash_mult_org       in             mult_org.hash%type
                            , sn_multorg_id          in out nocopy  mult_org.id%type
                            , en_referencia_id       in             log_generico_cad.referencia_id%type
                            , ev_obj_referencia      in             log_generico_cad.obj_referencia%type
                            )
is
   --
   vn_fase               number := 0;
   vv_multorg_hash       mult_org.hash%type;
   vn_multorg_id         mult_org.id%type;
   vn_loggenericocad_id  Log_Generico_Cad.id%type;
   vn_dm_obrig_integr    mult_org.dm_obrig_integr%type;
   vn_empresa_id         empresa.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   gn_referencia_id   := en_referencia_id;
   gv_obj_referencia  := ev_obj_referencia;
   --
   vn_fase := 1.1;
   --
   begin
      --
      select min(e.id)
        into vn_empresa_id
        from empresa e
       where e.multorg_id = sn_multorg_id;
      --
   exception
      when others then
         vn_empresa_id := null;
   end;
   --
   vn_fase := 1.11;
   --
   begin
      --
      select mo.dm_obrig_integr
        into vn_dm_obrig_integr
        from mult_org mo
       where mo.id = sn_multorg_id;
      --
   exception
      when no_data_found then
         --
         vn_dm_obrig_integr := 0; -- Não
         --
         vn_fase := 1.2;
         --
      when others then
         --
         vn_dm_obrig_integr := 0; -- Não
         --
         vn_fase := 1.3;
         --
         gv_mensagem_log := 'Problema ao tentar verificar a obrigatoriedade do Mult Org. Fase: '||vn_fase;
         gv_cabec_log :=  'Codigo do MultOrg: |' || ev_cod_mult_org || '| Hash do MultOrg: |'||ev_hash_mult_org||'|';
         --
         vn_loggenericocad_id := null;
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_cabec_log
                              , en_tipo_log           => ERRO_DE_VALIDACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => vn_empresa_id
                              );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                 , est_log_generico  => est_log_generico );
         --
   end;
   --
   begin
      --
      select mo.hash, mo.id
        into vv_multorg_hash, vn_multorg_id
        from mult_org mo
       where mo.cd = ev_cod_mult_org;
      --
      vn_fase := 2;
      --
   exception
      when no_data_found then
         --
         vn_fase := 3;
         --
         vv_multorg_hash := null;
         --
         vn_multorg_id := 0;
         --
      when others then
         --
         vn_fase := 4;
         --
         vv_multorg_hash := null;
         --
         vn_multorg_id := 0;
         --
         gv_mensagem_log := 'Problema ao tentar buscar o Mult Org. Fase: '||vn_fase;
         gv_cabec_log :=  'Codigo do MultOrg: |' || ev_cod_mult_org || '| Hash do MultOrg: |'||ev_hash_mult_org||'|';
         --
         vn_loggenericocad_id := null;
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_cabec_log
                              , en_tipo_log           => ERRO_DE_VALIDACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => vn_empresa_id
                              );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                 , est_log_generico  => est_log_generico );
   --
   end;
   --
   vn_fase := 5;
   --
   if nvl(vn_multorg_id, 0) = 0 then

      gv_mensagem_log := 'O Mult Org de codigo: |' || ev_cod_mult_org || '| não existe.';
      --
      vn_loggenericocad_id := null;
      --
      vn_fase := 5.1;
      --
      if vn_dm_obrig_integr = 0 then -- Não validar o multorg.
         --
         vn_fase := 5.2;
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => INFORMACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => vn_empresa_id
                              );
         --
      elsif vn_dm_obrig_integr = 1 then -- Validar o multorg.
         --
         vn_fase := 5.3;
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_VALIDACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => vn_empresa_id
                              );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                 , est_log_generico  => est_log_generico );
         --
      end if;
      --
   elsif vv_multorg_hash != ev_hash_mult_org then
      --
      vn_fase := 6;
      --
      gv_mensagem_log := 'O valor do Hash ('|| ev_hash_mult_org ||') do Mult Org:'|| ev_cod_mult_org ||' esta incorreto.';
      --
      vn_loggenericocad_id := null;
      --
      if vn_dm_obrig_integr = 0 then -- Não validar o multorg.
         --
         vn_fase := 6.1;
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => INFORMACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => vn_empresa_id
                              );
         --
      elsif vn_dm_obrig_integr = 1 then -- Validar o multorg.
         --
         vn_fase := 6.2;
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_VALIDACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => vn_empresa_id
                              );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                 , est_log_generico  => est_log_generico );
         --
      end if;
      --
   end if;
   --
   vn_fase := 7;
   --
   if nvl(vn_multorg_id,0) <= 0 then
      vn_multorg_id := pk_csf.fkg_multorg_id ( ev_multorg_cd => '1' );
   end if;
   --
   sn_multorg_id := vn_multorg_id;
   --
exception
   when others then
      raise_application_error (-20101, 'Problemas ao validar Mult Org - pk_csf_api_cad.pkb_ret_multorg_id. Fase: '||vn_fase||' Erro = '||sqlerrm);
end pkb_ret_multorg_id;
--
-- ================================================================================================================================ --
--

procedure pkb_val_atrib_bem_ativo ( est_log_generico   in out nocopy  dbms_sql.number_table
                                , ev_obj_name        in             VARCHAR2
                                , ev_atributo        in             VARCHAR2
                                , ev_valor           in             VARCHAR2
                                , sv_vl_dif_aliq     out            VARCHAR2                               
                                , en_referencia_id   in             log_generico_cad.referencia_id%type
                                , ev_obj_referencia  in             log_generico_cad.obj_referencia%type
                                )
is
   --
   vn_fase                number := 0;
   vn_loggenericocad_id   log_generico_cad.id%type;
   vv_mensagem            varchar2(1000) := null;
   vn_dmtipocampo         ff_obj_util_integr.dm_tipo_campo%type;
   --
   vv_vl_dif_aliq      itnf_bem_ativo_imob.vl_dif_aliq%type;
   --
begin
   --
   vn_fase := 1;
   --
   gv_mensagem_log := null;
   --
   gn_referencia_id  := en_referencia_id;
   gv_obj_referencia := ev_obj_referencia;
   --
   vn_fase := 2;
   --
   if trim(ev_valor) is null then
      --
      vn_fase := 3;
      --
      gv_mensagem_log := 'Código ou Valor do Diferencial de Alíquota (objeto: '|| ev_obj_name ||'): "VALOR" referente ao atributo deve ser informado.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                           , ev_mensagem        => gv_mensagem_log
                           , ev_resumo          => gv_cabec_log
                           , en_tipo_log        => INFORMACAO
                           , en_referencia_id   => gn_referencia_id
                           , ev_obj_referencia  => gv_obj_referencia );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                              , est_log_generico  => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   --
   vv_mensagem := pk_csf.fkg_ff_verif_campos( ev_obj_name => ev_obj_name
                                            , ev_atributo => trim(ev_atributo)
                                            , ev_valor    => trim(ev_valor) );
   --
   vn_fase := 5;
   --
   if vv_mensagem is not null then
      --
      vn_fase := 6;
      --
      gv_mensagem_log := vv_mensagem;
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad    ( sn_loggenericocad_id => vn_loggenericocad_id
                              , ev_mensagem          => gv_mensagem_log
                              , ev_resumo            => gv_cabec_log
                              , en_tipo_log          => INFORMACAO
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico       => vn_loggenericocad_id
                              , est_log_generico     => est_log_generico );
      --
   else
       --
      vn_fase := 7;
      --
      vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo( ev_obj_name => ev_obj_name
                                                         , ev_atributo => trim(ev_atributo) );
      --
      vn_fase := 8;
      --
      if trim(ev_valor) is not null then
         --
         vn_fase := 9;
         --
         if vn_dmtipocampo = 1 then -- tipo de campo = 0-data, 1-numérico, 2-caractere
            --
            vn_fase := 10;
            --
            if trim(ev_atributo) = 'VL_DIF_ALIQ' then
                --
                vn_fase := 11;
                --
                begin
                   vv_vl_dif_aliq := pk_csf.fkg_ff_ret_vlr_caracter( ev_obj_name => ev_obj_name
                                                                    , ev_atributo => trim(ev_atributo)
                                                                    , ev_valor    => trim(ev_valor) );
                exception
                   when others then
                      vv_vl_dif_aliq := null;
                end;
                --
            end if;
            --
         else
            --
            vn_fase := 13;
            --
            gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado não confere com o tipo de campo, deveria ser NUMERICO.';
            --
            vn_loggenericocad_id := null;
            --
            pkb_log_generico_cad ( sn_loggenericocad_id => vn_loggenericocad_id
                                 , ev_mensagem       => gv_mensagem_log
                                 , ev_resumo         => gv_cabec_log
                                 , en_tipo_log       => INFORMACAO
                                 , en_referencia_id  => gn_referencia_id
                                 , ev_obj_referencia => gv_obj_referencia );
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_cad ( en_loggenerico   => vn_loggenericocad_id
                                    , est_log_generico => est_log_generico );
            --
         end if;
         --
      end if;
      --
   end if;
   --
   vn_fase := 14;
   --
   sv_vl_dif_aliq := vv_vl_dif_aliq;
   --
--
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_val_atrib_bem_ativo fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericocad_id  log_generico.id%type;
      begin
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem        => gv_mensagem_log
                              , ev_resumo          => gv_cabec_log
                              , en_tipo_log        => erro_de_validacao
                              , en_referencia_id   => gn_referencia_id
                              , ev_obj_referencia  => gv_obj_referencia );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_cad ( en_loggenerico    => vn_loggenericocad_id
                                 , est_log_generico  => est_log_generico );
      exception
         when others then
            null;
      end;
end pkb_val_atrib_bem_ativo;

--
-- ================================================================================================================================ --
--
procedure pkb_val_atrib_nif ( est_log_generico   in out nocopy  dbms_sql.number_table
                            , ev_obj_name        in             VARCHAR2
                            , ev_atributo        in             VARCHAR2
                            , ev_valor           in             VARCHAR2
                            , ev_cod_part        in             pessoa.cod_part%type
                            , sv_cod_nif         in out nocopy  pessoa.cod_nif%type
                            , en_referencia_id   in             log_generico_cad.referencia_id%type
                            , ev_obj_referencia  in             log_generico_cad.obj_referencia%type ) is
   --
   vn_fase                number := 0;
   vn_loggenericocad_id   log_generico_cad.id%type;
   vv_mensagem            varchar2(1000) := null;
   vn_dmtipocampo         ff_obj_util_integr.dm_tipo_campo%type;
   vv_cod_nif             pessoa.cod_nif%type;
   vn_empresa_id          empresa.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   gv_mensagem_log := null;
   --
   gn_referencia_id   := en_referencia_id;
   gv_obj_referencia  := ev_obj_referencia;
   --
   vn_fase := 2;
   --
   -- valida o cod_nif
   if ev_valor is null then
      --
      vn_fase := 3;
      --
      gv_cabec_log    := 'Integração do COD_NIF do Participante: '|| ev_cod_part;
      gv_mensagem_log := 'O "Código NIF" está nulo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad    ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => INFORMACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => vn_empresa_id );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico        => vn_loggenericocad_id
                              , est_log_generico      => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   --
   vv_mensagem := pk_csf.fkg_ff_verif_campos( ev_obj_name => ev_obj_name
                                            , ev_atributo => trim(ev_atributo)
                                            , ev_valor    => trim(ev_valor) );
   --
   vn_fase := 5;
   --
   if vv_mensagem is not null then
      --
      vn_fase := 6;
      --
      gv_mensagem_log := vv_mensagem;
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad    ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_cabec_log
                              , en_tipo_log           => INFORMACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico        => vn_loggenericocad_id
                              , est_log_generico      => est_log_generico );
      --
   else
      --
      vn_fase := 7;
      --
      vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo( ev_obj_name => ev_obj_name
                                                         , ev_atributo => trim(ev_atributo) );
      --
      vn_fase := 8;
      --
      if trim(ev_valor) is not null then
         --
         vn_fase := 9;
         --
         if vn_dmtipocampo = 2 then -- tipo de campo = 0-data, 1-numérico, 2-caractere
            --
            vn_fase := 10;
            --
            if trim(ev_atributo) = 'COD_NIF' then
               --
               vn_fase := 11;
               --
               begin
                  vv_cod_nif := pk_csf.fkg_ff_ret_vlr_caracter( ev_obj_name => ev_obj_name
                                                              , ev_atributo => trim(ev_atributo)
                                                              , ev_valor    => trim(ev_valor) );
               exception
                  when others then
                     vv_cod_nif := null;
               end;
               --
            end if;
            --
         else
            --
            vn_fase := 13;
            --
            gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado não confere com o tipo de campo, deveria ser CARACTERE.';
            --
            vn_loggenericocad_id := null;
            --
            pkb_log_generico_cad    ( sn_loggenericocad_id => vn_loggenericocad_id
                                    , ev_mensagem          => gv_mensagem_log
                                    , ev_resumo            => gv_cabec_log
                                    , en_tipo_log          => INFORMACAO
                                    , en_referencia_id     => gn_referencia_id
                                    , ev_obj_referencia    => gv_obj_referencia );
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_cad ( en_loggenerico       => vn_loggenericocad_id
                                    , est_log_generico     => est_log_generico );
            --
         end if;
         --
      end if;
      --
   end if;
   --
   vn_fase := 14;
   --
   sv_cod_nif := vv_cod_nif;
   --
exception
   when others then
      raise_application_error (-20101, 'Problemas ao validar Código NIF - pk_csf_api_cad.pkb_val_atrib_nif. Fase: '||vn_fase||' Erro = '||sqlerrm);
end pkb_val_atrib_nif;
--
-- ================================================================================================================================ --
--
procedure pkb_integr_nat_set_pessoa ( est_log_generico   in out nocopy  dbms_sql.number_table
                                    , ev_obj_name        in             VARCHAR2
                                    , ev_atributo        in             VARCHAR2
                                    , ev_valor           in             VARCHAR2
                                    , ev_cod_part        in             pessoa.cod_part%type
                                    , en_multorg_id      in             mult_org.id%type                                    
                                    , en_referencia_id   in             log_generico_cad.referencia_id%type
                                    , ev_obj_referencia  in             log_generico_cad.obj_referencia%type ) is
   --
   vn_fase                number := 0;
   vn_loggenericocad_id   log_generico_cad.id%type;
   vv_mensagem            varchar2(1000) := null;
   vn_dmtipocampo         ff_obj_util_integr.dm_tipo_campo%type;
   vn_nat_setor_pessoa    number;
   vn_empresa_id          empresa.id%type;
   vn_pessoa_id           pessoa.id%type;   
   vn_qtde                number;
   vn_tipoparam_id        tipo_param.id%type;   
   vn_valortipopram_id    valor_tipo_param.id%type;    
   --
begin
   --
   vn_fase := 1;
   --
   gv_mensagem_log := null;
   --
   gn_referencia_id   := en_referencia_id;
   gv_obj_referencia  := ev_obj_referencia;
   --
   vn_fase := 2;
   --
   -- valida o cod_nif
   if ev_valor is null then
      --
      vn_fase := 3;
      --
      gv_cabec_log    := 'Integração do NAT_SETOR_PESSOA do Participante: '|| ev_cod_part;
      gv_mensagem_log := 'O "NAT_SETOR_PESSOA" está nulo.';
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad    ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => INFORMACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              , en_empresa_id         => vn_empresa_id );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico        => vn_loggenericocad_id
                              , est_log_generico      => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   --
   vv_mensagem := pk_csf.fkg_ff_verif_campos( ev_obj_name => ev_obj_name
                                            , ev_atributo => trim(ev_atributo)
                                            , ev_valor    => trim(ev_valor) );
   --
   vn_fase := 5;
   --
   if vv_mensagem is not null then
      --
      vn_fase := 6;
      --
      gv_mensagem_log := vv_mensagem;
      --
      vn_loggenericocad_id := null;
      --
      pkb_log_generico_cad    ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_cabec_log
                              , en_tipo_log           => INFORMACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_cad ( en_loggenerico        => vn_loggenericocad_id
                              , est_log_generico      => est_log_generico );
      --
   else
      --
      vn_fase := 7;
      --
      vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo( ev_obj_name => ev_obj_name
                                                         , ev_atributo => trim(ev_atributo) );
      --
      vn_fase := 8;
      --
      if trim(ev_valor) is not null then
         --
         vn_fase := 9;
         --
         if vn_dmtipocampo = 1 then -- tipo de campo = 0-data, 1-numérico, 2-caractere
            --
            vn_fase := 10;
            --
            if trim(ev_atributo) = 'NAT_SETOR_PESSOA' then
               --
               vn_fase := 11;
               --
               begin
                  vn_nat_setor_pessoa := pk_csf.fkg_ff_ret_vlr_caracter( ev_obj_name => ev_obj_name
                                                                       , ev_atributo => trim(ev_atributo)
                                                                       , ev_valor    => trim(ev_valor) );
               exception
                  when others then
                     vn_nat_setor_pessoa := null;
               end;
               --
            end if;
            --
            vn_fase := 11.1;
            -- 			
            if to_number(ev_valor) not in (0,1) then	
               gv_mensagem_log := '"Natureza Setor da Pessoa" invalida deve ser "0" ou "1".';
               --
               vn_loggenericocad_id := null;
               --
               pkb_log_generico_cad    ( sn_loggenericocad_id => vn_loggenericocad_id
                                       , ev_mensagem          => gv_mensagem_log
                                       , ev_resumo            => gv_cabec_log
                                       , en_tipo_log          => ERRO_DE_VALIDACAO
                                       , en_referencia_id     => gn_referencia_id
                                       , ev_obj_referencia    => gv_obj_referencia );
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_cad ( en_loggenerico       => vn_loggenericocad_id
                                       , est_log_generico     => est_log_generico );
               --
            end if;			
            --			
         else
            --
            vn_fase := 13;
            --
            gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado não confere com o tipo de campo, deveria ser NUMÉRICO.';
            --
            vn_loggenericocad_id := null;
            --
            pkb_log_generico_cad    ( sn_loggenericocad_id => vn_loggenericocad_id
                                    , ev_mensagem          => gv_mensagem_log
                                    , ev_resumo            => gv_cabec_log
                                    , en_tipo_log          => INFORMACAO
                                    , en_referencia_id     => gn_referencia_id
                                    , ev_obj_referencia    => gv_obj_referencia );
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_cad ( en_loggenerico       => vn_loggenericocad_id
                                    , est_log_generico     => est_log_generico );
            --
         end if;
         --
      end if;
      --
   end if;
   --
   vn_fase := 14;
   --
   if trim(ev_atributo) = 'NAT_SETOR_PESSOA' and
      trim(ev_cod_part) is not null and
      trim(ev_valor) is not null then 
      --	  
      vn_fase := 14.1;
      --
      vn_pessoa_id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id => en_multorg_id
                                                    , ev_cod_part   => ev_cod_part );
      --
      if nvl(vn_pessoa_id,0) > 0 then
         --
         vn_fase := 14.2;
         --		 
         begin 
            select count(1) 
              into vn_qtde			
              from pessoa_tipo_param p
                 , tipo_param t
             where t.cd           = '13' -- Natureza/Setor pessoa
               and p.pessoa_id    = vn_pessoa_id
               and p.tipoparam_id = t.id;          
         exception
            when others then
               vn_qtde := null;
         end;
         --
         vn_fase := 14.3;
         --				 
         begin 
            select t.id
              into vn_tipoparam_id		 
              from tipo_param t
             where t.cd  = '13'; -- Natureza/Setor pessoa		  
         exception
            when others then
               vn_tipoparam_id := null;
         end;			   
         --	
         vn_fase := 14.4;
         --		
         begin		 
            select v.id 
              into vn_valortipopram_id
              from valor_tipo_param v  
             where v.tipoparam_id = vn_tipoparam_id
               and v.cd           = ev_valor;		 
         exception
            when others then
               vn_valortipopram_id := null;
         end;
         --
		 vn_fase := 14.5;
         --	
         if nvl(vn_qtde,0) <= 0 then
            --		 
            insert into pessoa_tipo_param ( id
                                          , pessoa_id
                                          , tipoparam_id
                                          , valortipoparam_id
                                          )		 
                                    values( pessoatipoparam_seq.nextval
                                          , vn_pessoa_id
                                          , vn_tipoparam_id
                                          , vn_valortipopram_id
                                          );
            --										  
         else
            --		 
            update pessoa_tipo_param
               set valortipoparam_id = vn_valortipopram_id
             where pessoa_id    = vn_pessoa_id
               and tipoparam_id = vn_tipoparam_id;			 
            --			   
         end if;		 
         --	  
      end if;
      --	  
   end if;	  
   --
   vn_fase := 15;
   --
   commit;
   --
exception
   when others then
      raise_application_error (-20101, 'Problemas ao incluir / validar Código NAT_SETOR_PESSOA - pk_csf_api_cad.pkb_integr_nat_set_pessoa. Fase: '||vn_fase||' Erro = '||sqlerrm);
end pkb_integr_nat_set_pessoa;
--
-- ================================================================================================================================ --
--
--| Procedimento de replicar os registros das tabelas filhas da nat_op de uma empresa para outra
procedure pkb_replica_nat_oper (en_nat_oper_id             nat_oper.id%type,
                                en_empr_id_orig            empresa.id%type, 
                                en_empr_id_dest            empresa.id%type)
is
  --
  vn_fase                      number;
  --
  /*variaveis:*/
  vt_row_nat_oper_serv       NAT_OPER_SERV%rowtype;
  vt_row_pimp_nat_oper_serv  PARAM_IMP_NAT_OPER_SERV%rowtype;
  vt_row_ATIPOIMP_NCM_EMPR   ALIQ_TIPOIMP_NCM_EMPRESA%rowtype;
  vt_row_pcalc_icms_empr     PARAM_CALC_ICMS_EMPR%rowtype;
  vt_row_pcalc_icmsst_empr   PARAM_CALC_ICMSST_EMPR%rowtype;
  ----
  /*cursores:*/
  cursor c_no is
  select * from nat_oper where id = en_nat_oper_id; 
  ---
  cursor c_nos (en_natoper_id   nat_oper_serv.natoper_id%type,
                en_empresa_id   NAT_OPER_SERV.empresa_id%type) is
  select * from NAT_OPER_SERV where  natoper_id = en_natoper_id and empresa_id = en_empresa_id  ; -- empresa_id
  ---
  cursor c_pinos (en_natoperserv_id  PARAM_IMP_NAT_OPER_SERV.natoperserv_id%type)is
  select * from PARAM_IMP_NAT_OPER_SERV  where natoperserv_id =en_natoperserv_id ;  -- fk NAT_OPER_SERV
  ---
  cursor c_atne (en_natoper_id  ALIQ_TIPOIMP_NCM_EMPRESA.natoper_id%type,
                 en_empresa_id   ALIQ_TIPOIMP_NCM_EMPRESA.empresa_id%type)is
  select * from ALIQ_TIPOIMP_NCM_EMPRESA where natoper_id = en_natoper_id and empresa_id = en_empresa_id; -- empresa_id 
  ---
  cursor c_pcie (en_natoper_id  PARAM_CALC_ICMS_EMPR.natoper_id%type,
                 en_empresa_id  PARAM_CALC_ICMS_EMPR.empresa_id%type)is
  select * from PARAM_CALC_ICMS_EMPR where natoper_id = en_natoper_id and empresa_id = en_empresa_id;
  ---
  cursor c_pcise (en_natoper_id  PARAM_CALC_ICMSST_EMPR.natoper_id%type,
                  en_empresa_id  PARAM_CALC_ICMSST_EMPR.empresa_id%type)is
  select * from PARAM_CALC_ICMSST_EMPR where natoper_id = en_natoper_id and empresa_id = en_empresa_id;
  ----
begin
  ---
  vn_fase := 1;
  gn_referencia_id:= en_nat_oper_id;
  ---
  for reg in c_no loop
    ----    
    gv_cabec_log:= 'Codigo Natureza de operação :'||reg.cod_nat ||' - Descrição :'|| reg.descr_nat;
    ----       
    vn_fase := 2; 
    ----           
    for reg1 in c_nos (en_natoper_id => reg.id,
                       en_empresa_id => en_empr_id_orig ) loop
     ---         
     vn_fase := 2.01; 
     ---         
     begin -- busca por uk
       ---
       vt_row_nat_oper_serv:=null;
       ---
       begin
         select id 
           into vt_row_nat_oper_serv.ID
           from nat_oper_serv 
          where natoper_id = reg1.NATOPER_ID
            and empresa_id = en_empr_id_dest ;
       exception
        when others then
             vt_row_nat_oper_serv.ID:=null;
       end;
       ---
       vn_fase := 2.02; 
       ---                
       vt_row_nat_oper_serv.NATOPER_ID             := reg1.NATOPER_ID;
       vt_row_nat_oper_serv.EMPRESA_ID             := en_empr_id_dest ;
       vt_row_nat_oper_serv.ITEM_ID                := reg1.ITEM_ID;
       vt_row_nat_oper_serv.DM_IND_EMIT            := reg1.DM_IND_EMIT;
       vt_row_nat_oper_serv.INFORCOMPDCTOFISCAL_ID := reg1.INFORCOMPDCTOFISCAL_ID;
       vt_row_nat_oper_serv.BASECALCCREDPC_ID      := reg1.BASECALCCREDPC_ID;
       vt_row_nat_oper_serv.DM_LOC_EXE_SERV        := reg1.DM_LOC_EXE_SERV;
       vt_row_nat_oper_serv.PLANOCONTA_ID          := reg1.PLANOCONTA_ID;
       vt_row_nat_oper_serv.CENTROCUSTO_ID         := reg1.CENTROCUSTO_ID;
       vt_row_nat_oper_serv.EMPRESACTRLNRONF_ID    := reg1.EMPRESACTRLNRONF_ID;
       vt_row_nat_oper_serv.CFOP_ID                := reg1.CFOP_ID;
       vt_row_nat_oper_serv.CNAE                   := reg1.CNAE;
       vt_row_nat_oper_serv.DM_IND_ORIG_CRED       := reg1.DM_IND_ORIG_CRED;
       vt_row_nat_oper_serv.DM_OBRIG_VL_DUP        := reg1.DM_OBRIG_VL_DUP;
       vt_row_nat_oper_serv.DM_NAT_OPER            := reg1.DM_NAT_OPER; 
       ---
       if nvl(vt_row_nat_oper_serv.ID,0) = 0 then 
          ---
          vn_fase := 2.03; 
          ---                  
          vt_row_nat_oper_serv.ID   := natoperserv_seq.nextval;
          ---        
          insert into NAT_OPER_SERV values vt_row_nat_oper_serv;
          ---        
      else
          ---
          vn_fase := 2.04; 
          ---
          update NAT_OPER_SERV set
                NATOPER_ID             		 = vt_row_nat_oper_serv.NATOPER_ID,             
                EMPRESA_ID             		 = vt_row_nat_oper_serv.EMPRESA_ID,            
                ITEM_ID                		 = vt_row_nat_oper_serv.ITEM_ID,                
                DM_IND_EMIT            		 = vt_row_nat_oper_serv.DM_IND_EMIT,            
                INFORCOMPDCTOFISCAL_ID 		 = vt_row_nat_oper_serv.INFORCOMPDCTOFISCAL_ID, 
                BASECALCCREDPC_ID      		 = vt_row_nat_oper_serv.BASECALCCREDPC_ID,
                DM_LOC_EXE_SERV        		 = vt_row_nat_oper_serv.DM_LOC_EXE_SERV,        
                PLANOCONTA_ID          		 = vt_row_nat_oper_serv.PLANOCONTA_ID,          
                CENTROCUSTO_ID         		 = vt_row_nat_oper_serv.CENTROCUSTO_ID,         
                EMPRESACTRLNRONF_ID    		 = vt_row_nat_oper_serv.EMPRESACTRLNRONF_ID,    
                CFOP_ID                		 = vt_row_nat_oper_serv.CFOP_ID,                
                CNAE                   		 = vt_row_nat_oper_serv.CNAE,                   
                DM_IND_ORIG_CRED       		 = vt_row_nat_oper_serv.DM_IND_ORIG_CRED,       
                DM_OBRIG_VL_DUP        		 = vt_row_nat_oper_serv.DM_OBRIG_VL_DUP,        
                DM_NAT_OPER            		 = vt_row_nat_oper_serv.DM_NAT_OPER 
          where ID = vt_row_nat_oper_serv.ID;
          ---
      end if;
       ---      
     exception 
       when DUP_VAL_ON_INDEX then
       null;
     end;
     ---
     vn_fase := 2.05; 
     ---     
     for reg2 in c_pinos (en_natoperserv_id => reg1.id) loop
       ---
       vt_row_pimp_nat_oper_serv:=null;
       ---
       vn_fase := 2.06; 
       ---            
       begin
        ---
        select id 
          into vt_row_pimp_nat_oper_serv.ID
         from PARAM_IMP_NAT_OPER_SERV   
          where NATOPERSERV_ID = vt_row_nat_oper_serv.ID
                and DM_TIPO    = reg2.DM_TIPO
                and TIPOIMP_ID = reg2.TIPOIMP_ID
                and ((CIDADE_ID = reg2.CIDADE_ID) or CIDADE_ID is null) ;
        ---          
       exception
        when others then
             vt_row_pimp_nat_oper_serv.ID:=null;
       end;
       ---
       vn_fase := 2.07; 
       ---           
       vt_row_pimp_nat_oper_serv.NATOPERSERV_ID       := vt_row_nat_oper_serv.ID ;
       vt_row_pimp_nat_oper_serv.DM_TIPO              := reg2.DM_TIPO;
       vt_row_pimp_nat_oper_serv.TIPOIMP_ID           := reg2.TIPOIMP_ID;
       vt_row_pimp_nat_oper_serv.CODST_ID             := reg2.CODST_ID;
       vt_row_pimp_nat_oper_serv.ALIQ                 := reg2.ALIQ;
       vt_row_pimp_nat_oper_serv.VALOR_MIN            := reg2.VALOR_MIN;   
       vt_row_pimp_nat_oper_serv.CIDADE_ID            := reg2.CIDADE_ID;
       vt_row_pimp_nat_oper_serv.CODTRIBMUNICIPIO_ID  := reg2.CODTRIBMUNICIPIO_ID;
       vt_row_pimp_nat_oper_serv.DM_CONS_PER_ANT_MES  := reg2.DM_CONS_PER_ANT_MES;
       vt_row_pimp_nat_oper_serv.DM_FATO_GERA_RET     := reg2.DM_FATO_GERA_RET;
       vt_row_pimp_nat_oper_serv.TIPORETIMP_ID        := reg2.TIPORETIMP_ID;
       vt_row_pimp_nat_oper_serv.TIPOSERVICO_ID       := reg2.TIPOSERVICO_ID;
       vt_row_pimp_nat_oper_serv.DM_CALC_IMP_SN       := reg2.DM_CALC_IMP_SN;
       ---        
       if nvl(vt_row_pimp_nat_oper_serv.ID,0) = 0 then  
        ---  
        vn_fase := 2.08; 
        ---
        vt_row_pimp_nat_oper_serv.id := paramimpnatoperserv_seq.nextval;
        ---      
        insert into PARAM_IMP_NAT_OPER_SERV values vt_row_pimp_nat_oper_serv;
        ---
       else
        --- 
        vn_fase := 2.09; 
        ---
        update  PARAM_IMP_NAT_OPER_SERV set  
                NATOPERSERV_ID        = vt_row_pimp_nat_oper_serv.NATOPERSERV_ID,
                DM_TIPO               = vt_row_pimp_nat_oper_serv.DM_TIPO,
                TIPOIMP_ID            = vt_row_pimp_nat_oper_serv.TIPOIMP_ID,
                CODST_ID              = vt_row_pimp_nat_oper_serv.CODST_ID,
                ALIQ                  = vt_row_pimp_nat_oper_serv.ALIQ,
                VALOR_MIN             = vt_row_pimp_nat_oper_serv.VALOR_MIN,
                CIDADE_ID             = vt_row_pimp_nat_oper_serv.CIDADE_ID,
                CODTRIBMUNICIPIO_ID   = vt_row_pimp_nat_oper_serv.CODTRIBMUNICIPIO_ID,
                DM_CONS_PER_ANT_MES   = vt_row_pimp_nat_oper_serv.DM_CONS_PER_ANT_MES,
                DM_FATO_GERA_RET      = vt_row_pimp_nat_oper_serv.DM_FATO_GERA_RET,
                TIPORETIMP_ID         = vt_row_pimp_nat_oper_serv.TIPORETIMP_ID,
                TIPOSERVICO_ID        = vt_row_pimp_nat_oper_serv.TIPOSERVICO_ID,
                DM_CALC_IMP_SN        = vt_row_pimp_nat_oper_serv.DM_CALC_IMP_SN    
        where id = vt_row_pimp_nat_oper_serv.id;
       end if;
       ---      
     end loop;
     ---
    end loop;
    ----
    for reg3 in c_atne (en_natoper_id => reg.id,
                        en_empresa_id => en_empr_id_orig) loop
       ----
       vt_row_ATIPOIMP_NCM_EMPR := null;
       ---
       vn_fase := 2.10; 
       ---       
       vt_row_ATIPOIMP_NCM_EMPR.id := pk_csf_calc_fiscal.fkg_aliqtipoimpncmempresa_id ( en_empresa_id         => en_empr_id_dest 
                                                                                      , ed_dt_ini             => reg3.dt_ini
                                                                                      , ed_dt_fin             => reg3.dt_fin  
                                                                                      , ev_dm_tipo_param      => reg3.dm_tipo_param 
                                                                                      , en_prioridade         => reg3.prioridade
                                                                                      , en_tipoimposto_id     => reg3.TIPOIMPOSTO_ID
                                                                                      , en_cfop_id            => reg3.CFOP_ID
                                                                                      , en_ncm_id             => reg3.NCM_ID
                                                                                      , en_extipi_id          => reg3.EXTIPI_ID
                                                                                      , en_dm_orig_merc       => reg3.DM_ORIG_MERC
                                                                                      , en_item_id            => reg3.ITEM_ID
                                                                                      , en_natoper_id         => reg3.NATOPER_ID
                                                                                      , ev_cpf_cnpj           => reg3.CPF_CNPJ
                                                                                      , en_dm_calc_cons_final => reg3.DM_CALC_CONS_FINAL
                                                                                      ) ; 
       ---
       vn_fase := 2.11; 
       ---       
       vt_row_ATIPOIMP_NCM_EMPR.DM_TIPO_PARAM       := reg3.DM_TIPO_PARAM;
       vt_row_ATIPOIMP_NCM_EMPR.PRIORIDADE          := reg3.PRIORIDADE;
       vt_row_ATIPOIMP_NCM_EMPR.EMPRESA_ID          := en_empr_id_dest ;
       vt_row_ATIPOIMP_NCM_EMPR.TIPOIMPOSTO_ID      := reg3.TIPOIMPOSTO_ID;
       vt_row_ATIPOIMP_NCM_EMPR.CFOP_ID             := reg3.CFOP_ID;
       vt_row_ATIPOIMP_NCM_EMPR.NCM_ID              := reg3.NCM_ID;
       vt_row_ATIPOIMP_NCM_EMPR.EXTIPI_ID           := reg3.EXTIPI_ID;
       vt_row_ATIPOIMP_NCM_EMPR.DM_ORIG_MERC        := reg3.DM_ORIG_MERC;
       vt_row_ATIPOIMP_NCM_EMPR.ITEM_ID             := reg3.ITEM_ID;
       vt_row_ATIPOIMP_NCM_EMPR.DT_INI              := reg3.DT_INI;
       vt_row_ATIPOIMP_NCM_EMPR.DT_FIN              := reg3.DT_FIN;
       vt_row_ATIPOIMP_NCM_EMPR.NATOPER_ID          := reg3.NATOPER_ID;
       vt_row_ATIPOIMP_NCM_EMPR.CPF_CNPJ            := reg3.CPF_CNPJ;
       vt_row_ATIPOIMP_NCM_EMPR.DM_CALC_CONS_FINAL  := reg3.DM_CALC_CONS_FINAL;
       vt_row_ATIPOIMP_NCM_EMPR.CODST_ID            := reg3.CODST_ID;   
       vt_row_ATIPOIMP_NCM_EMPR.DM_TIPO             := reg3.DM_TIPO;
       vt_row_ATIPOIMP_NCM_EMPR.INDICE              := reg3.INDICE;
       vt_row_ATIPOIMP_NCM_EMPR.PERC_MAJOR          := reg3.PERC_MAJOR;
       vt_row_ATIPOIMP_NCM_EMPR.PERC_REDUC_BC       := reg3.PERC_REDUC_BC;
       vt_row_ATIPOIMP_NCM_EMPR.DM_SOMA_FRETE       := reg3.DM_SOMA_FRETE;
       vt_row_ATIPOIMP_NCM_EMPR.DM_SOMA_SEGURO      := reg3.DM_SOMA_SEGURO;
       vt_row_ATIPOIMP_NCM_EMPR.DM_SOMA_OUTRA_DESP  := reg3.DM_SOMA_OUTRA_DESP;
       vt_row_ATIPOIMP_NCM_EMPR.DM_SOMA_II          := reg3.DM_SOMA_II;
       vt_row_ATIPOIMP_NCM_EMPR.DM_SOMA_ICMSST      := reg3.DM_SOMA_ICMSST;
       vt_row_ATIPOIMP_NCM_EMPR.OBSFISCAL_ID        := reg3.OBSFISCAL_ID;
       vt_row_ATIPOIMP_NCM_EMPR.OBS_COMPL           := reg3.OBS_COMPL;
       vt_row_ATIPOIMP_NCM_EMPR.CLASSEENQIPI_ID     := reg3.CLASSEENQIPI_ID;
       vt_row_ATIPOIMP_NCM_EMPR.SELOCONTRIPI_ID     := reg3.SELOCONTRIPI_ID;
       vt_row_ATIPOIMP_NCM_EMPR.QTDE_SELO_CONTR_IPI := reg3.QTDE_SELO_CONTR_IPI ; 
       vt_row_ATIPOIMP_NCM_EMPR.ENQLEGALIPI_ID      := reg3.ENQLEGALIPI_ID;
       vt_row_ATIPOIMP_NCM_EMPR.TIPOSERVREINF_ID    := reg3.TIPOSERVREINF_ID;
       vt_row_ATIPOIMP_NCM_EMPR.DM_IND_CPRB         := reg3.DM_IND_CPRB;
       ----
       if nvl(vt_row_ATIPOIMP_NCM_EMPR.ID,0) = 0 then
         ----      
         vn_fase := 2.12; 
         ---                
         vt_row_ATIPOIMP_NCM_EMPR.ID   := aliqtipoimpncmempresa_seq.nextval;
         ----
         insert into ALIQ_TIPOIMP_NCM_EMPRESA values vt_row_ATIPOIMP_NCM_EMPR;
         ----
       else
         ---   
         vn_fase := 2.13;          
         ---
         update ALIQ_TIPOIMP_NCM_EMPRESA set 
                DM_TIPO_PARAM       = vt_row_ATIPOIMP_NCM_EMPR.DM_TIPO_PARAM,
                PRIORIDADE          = vt_row_ATIPOIMP_NCM_EMPR.PRIORIDADE,
                EMPRESA_ID          = vt_row_ATIPOIMP_NCM_EMPR.EMPRESA_ID,
                TIPOIMPOSTO_ID      = vt_row_ATIPOIMP_NCM_EMPR.TIPOIMPOSTO_ID,
                CFOP_ID             = vt_row_ATIPOIMP_NCM_EMPR.CFOP_ID,
                NCM_ID              = vt_row_ATIPOIMP_NCM_EMPR.NCM_ID,
                EXTIPI_ID           = vt_row_ATIPOIMP_NCM_EMPR.EXTIPI_ID,
                DM_ORIG_MERC        = vt_row_ATIPOIMP_NCM_EMPR.DM_ORIG_MERC,
                ITEM_ID             = vt_row_ATIPOIMP_NCM_EMPR.ITEM_ID,
                DT_INI              = vt_row_ATIPOIMP_NCM_EMPR.DT_INI,
                DT_FIN              = vt_row_ATIPOIMP_NCM_EMPR.DT_FIN,
                NATOPER_ID          = vt_row_ATIPOIMP_NCM_EMPR.NATOPER_ID,
                CPF_CNPJ            = vt_row_ATIPOIMP_NCM_EMPR.CPF_CNPJ,
                DM_CALC_CONS_FINAL  = vt_row_ATIPOIMP_NCM_EMPR.DM_CALC_CONS_FINAL,
                CODST_ID            = vt_row_ATIPOIMP_NCM_EMPR.CODST_ID,
                DM_TIPO             = vt_row_ATIPOIMP_NCM_EMPR.DM_TIPO,
                INDICE              = vt_row_ATIPOIMP_NCM_EMPR.INDICE,
                PERC_MAJOR          = vt_row_ATIPOIMP_NCM_EMPR.PERC_MAJOR,
                PERC_REDUC_BC       = vt_row_ATIPOIMP_NCM_EMPR.PERC_REDUC_BC,
                DM_SOMA_FRETE       = vt_row_ATIPOIMP_NCM_EMPR.DM_SOMA_FRETE,
                DM_SOMA_SEGURO      = vt_row_ATIPOIMP_NCM_EMPR.DM_SOMA_SEGURO,
                DM_SOMA_OUTRA_DESP  = vt_row_ATIPOIMP_NCM_EMPR.DM_SOMA_OUTRA_DESP,
                DM_SOMA_II          = vt_row_ATIPOIMP_NCM_EMPR.DM_SOMA_II,
                DM_SOMA_ICMSST      = vt_row_ATIPOIMP_NCM_EMPR.DM_SOMA_ICMSST,
                OBSFISCAL_ID        = vt_row_ATIPOIMP_NCM_EMPR.OBSFISCAL_ID,
                OBS_COMPL           = vt_row_ATIPOIMP_NCM_EMPR.OBS_COMPL,
                CLASSEENQIPI_ID     = vt_row_ATIPOIMP_NCM_EMPR.CLASSEENQIPI_ID,
                SELOCONTRIPI_ID     = vt_row_ATIPOIMP_NCM_EMPR.SELOCONTRIPI_ID,
                QTDE_SELO_CONTR_IPI = vt_row_ATIPOIMP_NCM_EMPR.QTDE_SELO_CONTR_IPI,
                ENQLEGALIPI_ID      = vt_row_ATIPOIMP_NCM_EMPR.ENQLEGALIPI_ID,
                TIPOSERVREINF_ID    = vt_row_ATIPOIMP_NCM_EMPR.TIPOSERVREINF_ID,
                DM_IND_CPRB         = vt_row_ATIPOIMP_NCM_EMPR.DM_IND_CPRB   
         where id = vt_row_ATIPOIMP_NCM_EMPR.ID ;
         ---
       end if;
       ----    
    end loop;
    ----
    for reg4 in c_pcie (en_natoper_id => reg.id,
                        en_empresa_id => en_empr_id_orig) loop
       ----                      
       vt_row_pcalc_icms_empr:=null;
       ----    
       vn_fase := 2.14;          
       ---       
       --EMPRESA_ID, CFOP_ID, DT_INI, DT_FIN, ESTADO_ID_DEST, NCM_ID, EXTIPI_ID, DM_ORIG_MERC, ITEM_ID, CPF_CNPJ, NATOPER_ID, DM_CALC_FISICA, DM_CALC_CONS_FINAL, DM_CALC_CONTR_ISENTO, DM_CALC_NAO_CONTR, DM_EMIT_COM_SUFRAMA, DM_DEST_COM_SUFRAMA
       vt_row_pcalc_icms_empr:= null;
       vt_row_pcalc_icms_empr.id := pk_csf_calc_fiscal.fkg_paramcalcicmsempr_id( en_empresa_id          => en_empr_id_dest 
                                                                              , ed_dt_ini               => reg4.dt_ini
                                                                              , ed_dt_fin               => reg4.dt_fin   
                                                                              , ev_dm_tipo_param        => reg4.dm_tipo_param  
                                                                              , en_prioridade           => reg4.prioridade  
                                                                              , en_cfop_id              => reg4.cfop_id   
                                                                              , en_estado_id_dest       => reg4.estado_id_dest
                                                                              , en_ncm_id               => reg4.ncm_id 
                                                                              , en_extipi_id            => reg4.extipi_id 
                                                                              , en_dm_orig_merc         => reg4.dm_orig_merc   
                                                                              , en_item_id              => reg4.item_id  
                                                                              , en_natoper_id           => reg4.natoper_id   
                                                                              , ev_cpf_cnpj             => reg4.cpf_cnpj 
                                                                              , en_dm_calc_fisica       => reg4.dm_calc_fisica 
                                                                              , en_dm_calc_contr_isento => reg4.dm_calc_contr_isento
                                                                              , en_dm_calc_cons_final   => reg4.dm_calc_cons_final
                                                                              , en_dm_calc_nao_contr    => reg4.dm_calc_nao_contr
                                                                              , en_dm_emit_com_suframa  => reg4.dm_emit_com_suframa
                                                                              , en_dm_dest_com_suframa  => reg4.dm_dest_com_suframa);
       ----   
       vn_fase := 2.15;          
       ---              
       vt_row_pcalc_icms_empr.DM_TIPO_PARAM          := reg4.DM_TIPO_PARAM;
       vt_row_pcalc_icms_empr.PRIORIDADE             := reg4.PRIORIDADE;   
       vt_row_pcalc_icms_empr.CFOP_ID                := reg4.CFOP_ID;
       vt_row_pcalc_icms_empr.DT_INI                 := reg4.DT_INI;
       vt_row_pcalc_icms_empr.DT_FIN                 := reg4.DT_FIN;
       vt_row_pcalc_icms_empr.ESTADO_ID_DEST         := reg4.ESTADO_ID_DEST;
       vt_row_pcalc_icms_empr.NCM_ID                 := reg4.NCM_ID;
       vt_row_pcalc_icms_empr.EXTIPI_ID              := reg4.EXTIPI_ID;
       vt_row_pcalc_icms_empr.DM_ORIG_MERC           := reg4.DM_ORIG_MERC;
       vt_row_pcalc_icms_empr.ITEM_ID                := reg4.ITEM_ID;  
       vt_row_pcalc_icms_empr.CPF_CNPJ               := reg4.CPF_CNPJ;
       vt_row_pcalc_icms_empr.NATOPER_ID             := reg4.NATOPER_ID;   
       vt_row_pcalc_icms_empr.DM_CALC_FISICA         := reg4.DM_CALC_FISICA;
       vt_row_pcalc_icms_empr.DM_CALC_CONS_FINAL     := reg4.DM_CALC_CONS_FINAL;
       vt_row_pcalc_icms_empr.DM_CALC_CONTR_ISENTO   := reg4.DM_CALC_CONTR_ISENTO;
       vt_row_pcalc_icms_empr.DM_CALC_NAO_CONTR      := reg4.DM_CALC_NAO_CONTR;
       vt_row_pcalc_icms_empr.DM_EMIT_COM_SUFRAMA    := reg4.DM_EMIT_COM_SUFRAMA; 
       vt_row_pcalc_icms_empr.DM_DEST_COM_SUFRAMA    := reg4.DM_DEST_COM_SUFRAMA;
       vt_row_pcalc_icms_empr.CFOP_ID_DEST           := reg4.CFOP_ID_DEST;
       vt_row_pcalc_icms_empr.CODST_ID               := reg4.CODST_ID;
       vt_row_pcalc_icms_empr.ALIQ_DEST              := reg4.ALIQ_DEST;
       vt_row_pcalc_icms_empr.PERC_REDUC_BC          := reg4.PERC_REDUC_BC;
       vt_row_pcalc_icms_empr.PERC_DIFER             := reg4.PERC_DIFER;
       vt_row_pcalc_icms_empr.OBSFISCAL_ID           := reg4.OBSFISCAL_ID;
       vt_row_pcalc_icms_empr.OBS_COMPL              := reg4.OBS_COMPL;
       vt_row_pcalc_icms_empr.DM_MOD_BASE_CALC       := reg4.DM_MOD_BASE_CALC;
       vt_row_pcalc_icms_empr.INDICE                 := reg4.INDICE;
       vt_row_pcalc_icms_empr.DM_AJUSTA_MVA          := reg4.DM_AJUSTA_MVA;
       vt_row_pcalc_icms_empr.DM_AJUST_DESC_ZFM_ITEM := reg4.DM_AJUST_DESC_ZFM_ITEM;
       vt_row_pcalc_icms_empr.DM_SOMA_FRETE          := reg4.DM_SOMA_FRETE;
       vt_row_pcalc_icms_empr.DM_SOMA_SEGURO         := reg4.DM_SOMA_SEGURO;
       vt_row_pcalc_icms_empr.DM_SOMA_OUTRA_DESP     := reg4.DM_SOMA_OUTRA_DESP; 
       vt_row_pcalc_icms_empr.DM_SOMA_IPI            := reg4.DM_SOMA_IPI; 
       vt_row_pcalc_icms_empr.DM_SOMA_II             := reg4.DM_SOMA_II;
       ----                                                                           
       if nvl(vt_row_pcalc_icms_empr.id,0) = 0 then
         ---
         vn_fase := 2.16;          
         ---                           
         vt_row_pcalc_icms_empr.id   := paramcalcicmsempr_seq.nextval;
         vt_row_pcalc_icms_empr.EMPRESA_ID := en_empr_id_dest ;
         ---
         insert into PARAM_CALC_ICMS_EMPR values vt_row_pcalc_icms_empr; 
         ---         
       else
        ---
        vn_fase := 2.17;          
        ---            
        update PARAM_CALC_ICMS_EMPR set
              DM_TIPO_PARAM           = vt_row_pcalc_icms_empr.DM_TIPO_PARAM,
              PRIORIDADE              = vt_row_pcalc_icms_empr.PRIORIDADE,
              CFOP_ID                 = vt_row_pcalc_icms_empr.CFOP_ID,
              DT_INI                  = vt_row_pcalc_icms_empr.DT_INI,
              DT_FIN                  = vt_row_pcalc_icms_empr.DT_FIN,
              ESTADO_ID_DEST          = vt_row_pcalc_icms_empr.ESTADO_ID_DEST,
              NCM_ID                  = vt_row_pcalc_icms_empr.NCM_ID,
              EXTIPI_ID               = vt_row_pcalc_icms_empr.EXTIPI_ID,
              DM_ORIG_MERC            = vt_row_pcalc_icms_empr.DM_ORIG_MERC,
              ITEM_ID                 = vt_row_pcalc_icms_empr.ITEM_ID,
              CPF_CNPJ                = vt_row_pcalc_icms_empr.CPF_CNPJ,
              NATOPER_ID              = vt_row_pcalc_icms_empr.NATOPER_ID,
              DM_CALC_FISICA          = vt_row_pcalc_icms_empr.DM_CALC_FISICA,
              DM_CALC_CONS_FINAL      = vt_row_pcalc_icms_empr.DM_CALC_CONS_FINAL,
              DM_CALC_CONTR_ISENTO    = vt_row_pcalc_icms_empr.DM_CALC_CONTR_ISENTO,
              DM_CALC_NAO_CONTR       = vt_row_pcalc_icms_empr.DM_CALC_NAO_CONTR,
              DM_EMIT_COM_SUFRAMA     = vt_row_pcalc_icms_empr.DM_EMIT_COM_SUFRAMA,
              DM_DEST_COM_SUFRAMA     = vt_row_pcalc_icms_empr.DM_DEST_COM_SUFRAMA,
              CFOP_ID_DEST            = vt_row_pcalc_icms_empr.CFOP_ID_DEST,
              CODST_ID                = vt_row_pcalc_icms_empr.CODST_ID,
              ALIQ_DEST               = vt_row_pcalc_icms_empr.ALIQ_DEST,
              PERC_REDUC_BC           = vt_row_pcalc_icms_empr.PERC_REDUC_BC,
              PERC_DIFER              = vt_row_pcalc_icms_empr.PERC_DIFER,
              OBSFISCAL_ID            = vt_row_pcalc_icms_empr.OBSFISCAL_ID,
              OBS_COMPL               = vt_row_pcalc_icms_empr.OBS_COMPL,
              DM_MOD_BASE_CALC        = vt_row_pcalc_icms_empr.DM_MOD_BASE_CALC,
              INDICE                  = vt_row_pcalc_icms_empr.INDICE,
              DM_AJUSTA_MVA           = vt_row_pcalc_icms_empr.DM_AJUSTA_MVA,
              DM_AJUST_DESC_ZFM_ITEM  = vt_row_pcalc_icms_empr.DM_AJUST_DESC_ZFM_ITEM,
              DM_SOMA_FRETE           = vt_row_pcalc_icms_empr.DM_SOMA_FRETE,
              DM_SOMA_SEGURO          = vt_row_pcalc_icms_empr.DM_SOMA_SEGURO,
              DM_SOMA_OUTRA_DESP      = vt_row_pcalc_icms_empr.DM_SOMA_OUTRA_DESP,
              DM_SOMA_IPI             = vt_row_pcalc_icms_empr.DM_SOMA_IPI,
              DM_SOMA_II              = vt_row_pcalc_icms_empr.DM_SOMA_II  
            where id = vt_row_pcalc_icms_empr.id; 
        ---        
       end if;
       ----
    end loop;
    ---
    for reg5 in c_pcise (en_natoper_id => reg.id,
                         en_empresa_id => en_empr_id_orig/*reg.empresa_id*/) loop
        ---                       
        vt_row_pcalc_icmsst_empr:=null;
        ---
        vn_fase := 2.18;          
        ---        
        vt_row_pcalc_icmsst_empr.id := pk_csf_calc_fiscal.fkg_paramcalcicmsstempr_id ( en_empresa_id    => en_empr_id_dest
                                                                                    , en_cfop_id        => reg5.cfop_id
                                                                                    , en_estado_id_dest => reg5.estado_id_dest
                                                                                    , ed_dt_ini         => reg5.dt_ini
                                                                                    , ed_dt_fin         => reg5.dt_fin
                                                                                    , en_cest_id        => reg5.cest_id 
                                                                                    , en_ncm_id         => reg5.ncm_id
                                                                                    , en_extipi_id      => reg5.extipi_id
                                                                                    , en_dm_orig_merc   => reg5.dm_orig_merc
                                                                                    , en_item_id        => reg5.item_id
                                                                                    , ev_cpf_cnpj       => reg5.cpf_cnpj
                                                                                    , en_natoper_id     => reg5.natoper_id
                                                                                    , en_dm_calc_fisica => reg5.dm_calc_fisica
                                                                                    );   
       ----
       vn_fase := 2.19;          
       ---               
       vt_row_pcalc_icmsst_empr.dm_tipo_param      := reg5.dm_tipo_param;
       vt_row_pcalc_icmsst_empr.prioridade         := reg5.prioridade;
       vt_row_pcalc_icmsst_empr.cfop_id            := reg5.cfop_id;
       vt_row_pcalc_icmsst_empr.estado_id_dest     := reg5.estado_id_dest;
       vt_row_pcalc_icmsst_empr.dt_ini             := reg5.dt_ini;
       vt_row_pcalc_icmsst_empr.dt_fin             := reg5.dt_fin;
       vt_row_pcalc_icmsst_empr.cest_id            := reg5.cest_id;
       vt_row_pcalc_icmsst_empr.ncm_id             := reg5.ncm_id;
       vt_row_pcalc_icmsst_empr.extipi_id          := reg5.extipi_id;
       vt_row_pcalc_icmsst_empr.dm_orig_merc       := reg5.dm_orig_merc;
       vt_row_pcalc_icmsst_empr.item_id            := reg5.item_id;
       vt_row_pcalc_icmsst_empr.cpf_cnpj           := reg5.cpf_cnpj;
       vt_row_pcalc_icmsst_empr.natoper_id         := reg5.natoper_id;
       vt_row_pcalc_icmsst_empr.codst_id           := reg5.codst_id;
       vt_row_pcalc_icmsst_empr.aliq_dest          := reg5.aliq_dest;
       vt_row_pcalc_icmsst_empr.obsfiscal_id       := reg5.obsfiscal_id;
       vt_row_pcalc_icmsst_empr.obs_compl          := reg5.obs_compl;
       vt_row_pcalc_icmsst_empr.dm_mod_base_calc_st:= reg5.dm_mod_base_calc_st;
       vt_row_pcalc_icmsst_empr.indice             := reg5.indice;
       vt_row_pcalc_icmsst_empr.perc_reduc_bc      := reg5.perc_reduc_bc;
       vt_row_pcalc_icmsst_empr.dm_ajusta_mva      := reg5.dm_ajusta_mva;
       vt_row_pcalc_icmsst_empr.dm_efeito          := reg5.dm_efeito;
       vt_row_pcalc_icmsst_empr.dm_calc_fisica     := reg5.dm_calc_fisica;
       vt_row_pcalc_icmsst_empr.dm_soma_frete      := reg5.dm_soma_frete;
       vt_row_pcalc_icmsst_empr.dm_soma_seguro     := reg5.dm_soma_seguro;
       vt_row_pcalc_icmsst_empr.dm_soma_outra_desp := reg5.dm_soma_outra_desp;
       vt_row_pcalc_icmsst_empr.dm_soma_ipi        := reg5.dm_soma_ipi;
       vt_row_pcalc_icmsst_empr.dm_soma_ii         := reg5.dm_soma_ii;
       vt_row_pcalc_icmsst_empr.dm_soma_icmsst_od  := reg5.dm_soma_icmsst_od;
       vt_row_pcalc_icmsst_empr.dm_tipo_calc_st    := reg5.dm_tipo_calc_st;   
       ----     
       if nvl(vt_row_pcalc_icmsst_empr.id,0) = 0 then
         ---       
         vn_fase := 2.20;          
         ---            
         vt_row_pcalc_icmsst_empr.id           := paramcalcicmsstempr_seq.nextval;
         vt_row_pcalc_icmsst_empr.empresa_id   := en_empr_id_dest; 
         ---       
         insert into PARAM_CALC_ICMSST_EMPR values vt_row_pcalc_icmsst_empr;
         ---    
       else
         ---
         vn_fase := 2.21;          
         --- 
         update PARAM_CALC_ICMSST_EMPR set
           dm_tipo_param       = vt_row_pcalc_icmsst_empr.dm_tipo_param,
           prioridade          = vt_row_pcalc_icmsst_empr.prioridade,
           cfop_id             = vt_row_pcalc_icmsst_empr.cfop_id,
           estado_id_dest      = vt_row_pcalc_icmsst_empr.estado_id_dest,
           dt_ini              = vt_row_pcalc_icmsst_empr.dt_ini,
           dt_fin              = vt_row_pcalc_icmsst_empr.dt_fin,
           cest_id             = vt_row_pcalc_icmsst_empr.cest_id,
           ncm_id              = vt_row_pcalc_icmsst_empr.ncm_id,
           extipi_id           = vt_row_pcalc_icmsst_empr.extipi_id,
           dm_orig_merc        = vt_row_pcalc_icmsst_empr.dm_orig_merc,
           item_id             = vt_row_pcalc_icmsst_empr.item_id,
           cpf_cnpj            = vt_row_pcalc_icmsst_empr.cpf_cnpj,
           natoper_id          = vt_row_pcalc_icmsst_empr.natoper_id,
           codst_id            = vt_row_pcalc_icmsst_empr.codst_id,
           aliq_dest           = vt_row_pcalc_icmsst_empr.aliq_dest,
           obsfiscal_id        = vt_row_pcalc_icmsst_empr.obsfiscal_id,
           obs_compl           = vt_row_pcalc_icmsst_empr.obs_compl,
           dm_mod_base_calc_st = vt_row_pcalc_icmsst_empr.dm_mod_base_calc_st,
           indice              = vt_row_pcalc_icmsst_empr.indice,
           perc_reduc_bc       = vt_row_pcalc_icmsst_empr.perc_reduc_bc,
           dm_ajusta_mva       = vt_row_pcalc_icmsst_empr.dm_ajusta_mva,
           dm_efeito           = vt_row_pcalc_icmsst_empr.dm_efeito,
           dm_calc_fisica      = vt_row_pcalc_icmsst_empr.dm_calc_fisica,
           dm_soma_frete       = vt_row_pcalc_icmsst_empr.dm_soma_frete,
           dm_soma_seguro      = vt_row_pcalc_icmsst_empr.dm_soma_seguro,
           dm_soma_outra_desp  = vt_row_pcalc_icmsst_empr.dm_soma_outra_desp,
           dm_soma_ipi         = vt_row_pcalc_icmsst_empr.dm_soma_ipi,
           dm_soma_ii          = vt_row_pcalc_icmsst_empr.dm_soma_ii,
           dm_soma_icmsst_od   = vt_row_pcalc_icmsst_empr.dm_soma_icmsst_od,
           dm_tipo_calc_st     = vt_row_pcalc_icmsst_empr.dm_tipo_calc_st
        where id = vt_row_pcalc_icmsst_empr.id;       
       ---
       end if;
       ----
    end loop;  
    ----    
  end loop;  
  ---        
  commit;
  --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_replica_nat_oper fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericocad_id  Log_Generico_Cad.id%TYPE;
      begin
         --
         pkb_log_generico_cad ( sn_loggenericocad_id  => vn_loggenericocad_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => erro_de_sistema
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => 'NAT_OPER'/*gv_obj_referencia*/
                              , en_empresa_id         => en_empr_id_dest
                              );
         --
      exception
         when others then
            null;
      end;
      --      
      raise_application_error (-20101, gv_mensagem_log);
      --    
end pkb_replica_nat_oper;   
--
-- ================================================================================================================================ --
--
end pk_csf_api_cad;
/
