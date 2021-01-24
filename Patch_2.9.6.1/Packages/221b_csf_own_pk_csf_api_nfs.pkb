create or replace package body csf_own.pk_csf_api_nfs is

----------------------------------------------------------------------------
-- Função para verificar se existe registro de erro grvados no Log Generico 
----------------------------------------------------------------------------
function fkg_ver_erro_log_generico_nfs( en_nota_fiscal_id in nota_fiscal.id%type )
         return number
is
   --
   vn_qtde      number := 0;
   --
begin
   --
   select count(1)
     into vn_qtde 
     from log_generico_nf ln,
          csf_tipo_log tc
    where ln.referencia_id = en_nota_fiscal_id
      and tc.id            = ln.csftipolog_id
      and tc.dm_grau_sev   = 1;  -- erro 
   --
   if nvl(vn_qtde,0) > 0 then
      return 1;  -- erro
   else
      return 0;  -- só aviso/informação
   end if;   
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Problemas em fkg_ver_erro_log_generico_nfs. Erro = '||sqlerrm);
end fkg_ver_erro_log_generico_nfs;


-------------------------------------------------------------------------------------------------------
-- Corpo do pacote de integração de notas fiscais de serviço para o CSF       
-------------------------------------------------------------------------------------------------------

--| Procedimento seta o tipo de integração que será feito
   -- 0 - Somente válida os dados e registra o Log de ocorrência
   -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
   -- Todos os procedimentos de integração fazem referência a ele

procedure pkb_seta_tipo_integr ( en_tipo_integr in number )
is
begin
   --
   gn_tipo_integr := en_tipo_integr;
   --
end pkb_seta_tipo_integr;

-------------------------------------------------------------------------------------------------------

--| Procedimento seta o objeto de referencia utilizado na Validação da Informação
procedure pkb_seta_obj_ref ( ev_objeto in varchar2 )
is
begin
   --
   gv_obj_referencia := upper(ev_objeto);
   --
end pkb_seta_obj_ref;

-------------------------------------------------------------------------------------------------------

--| Procedimento seta o "ID de Referencia" utilizado na Validação da Informação
procedure pkb_seta_referencia_id ( en_id in number )
is
begin
   --
   gn_referencia_id := en_id;
   --
end pkb_seta_referencia_id;

-------------------------------------------------------------------------------------------------------
-- Procedimento armazena o valor do "loggenerico_id" da nota fiscal

procedure pkb_gt_log_generico_nf ( en_loggenericonf_id    in             log_generico_nf.id%TYPE
                                 , est_log_generico_nf  in out nocopy  dbms_sql.number_table )
is
   --
   i pls_integer;
   --
begin
   --
   if nvl(en_loggenericonf_id,0) > 0 then
      --
      i := nvl(est_log_generico_nf.count,0) + 1;
      --
      est_log_generico_nf(i) := en_loggenericonf_id;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_nfs.pkb_gt_log_generico_nf:' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  Log_Generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_gt_log_generico_nf;

-------------------------------------------------------------------------------------------------------

--| Procedimento finaliza o Log Genérico

procedure pkb_finaliza_log_generico_nf
is
   --
begin
   --
   gn_processo_id := null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_nfs.pkb_finaliza_log_generico_nf fase:' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  Log_Generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_finaliza_log_generico_nf;

-------------------------------------------------------------------------------------------------------

--| Procedimento de registro de log de erros na validação da nota fiscal

procedure pkb_log_generico_nf ( sn_loggenericonf_id     out nocopy log_generico_nf.id%TYPE
                              , ev_mensagem           in         log_generico_nf.mensagem%TYPE
                              , ev_resumo             in         log_generico_nf.resumo%TYPE
                              , en_tipo_log           in         csf_tipo_log.cd_compat%type      default 1
                              , en_referencia_id      in         log_generico_nf.referencia_id%TYPE  default null
                              , ev_obj_referencia     in         log_generico_nf.obj_referencia%TYPE default null
                              , en_empresa_id         in         Empresa.Id%type                  default null
                              , en_dm_impressa        in         log_generico_nf.dm_impressa%type    default 0 )
is
   --
   vn_fase          number := 0;
   vn_csftipolog_id csf_tipo_log.id%type := null;
   PRAGMA           AUTONOMOUS_TRANSACTION;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(gn_processo_id,0) = 0 then
      select processo_seq.nextval
        into gn_processo_id
        from dual;
   end if;
   --
   if nvl(en_tipo_log,0) > 0 and ev_mensagem is not null then
      --
      vn_fase := 2;
      --
      vn_csftipolog_id := pk_csf.fkg_csf_tipo_log_id ( en_tipo_log => en_tipo_log );
      --
      vn_fase := 3;
      --
      select loggenericonf_seq.nextval
        into sn_loggenericonf_id
        from dual;
      --
      vn_fase := 4;
      --
      insert into log_generico_nf ( id
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
                                  ( sn_loggenericonf_id     -- Valor de cada log de validação
                                  , gn_processo_id        -- Valor ID do processo de integração
                                  , sysdate               -- Sempre atribui a data atual do sistema
                                  , ev_mensagem           -- Mensagem do log
                                  , en_referencia_id      -- Id de referência que gerou o log
                                  , ev_obj_referencia     -- Objeto do Banco que gerou o log
                                  , ev_resumo
                                  , en_dm_impressa
                                  , 0
                                  , vn_csftipolog_id
                                  , nvl(en_empresa_id, gn_empresa_id)
                                  );
      --
      vn_fase := 5;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_log_generico_nf fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_log_generico_nf;

-------------------------------------------------------------------------------------------------------

-- Procedimento de atualizar dados do Lote de NFSe, responsável por atualizar dados conforme NFSe.

procedure pkb_atual_dados_lote_nfs ( en_lotenfs_id in lote_nfs.id%type 
                                   , en_qtde_nfs   in number
                                   )
is
   --
   vn_fase              number := 0;
   vn_loggenericonf_id  log_generico_nf.id%TYPE;
   --
   vd_dt_ini            lote_nfs.dt_ini%type;
   vd_dt_fin            lote_nfs.dt_fin%type;
   vn_vl_total_serv     lote_nfs.vl_total_serv%type;
   vn_vl_total_ded      lote_nfs.vl_total_ded%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_lotenfs_id,0) > 0 then
      --
      vn_fase := 2;
      --| acerta "Data Inicio" e "Data Final" do Lote de NFSe
      begin
         --
         select min(nf.dt_emiss)
              , max(nf.dt_emiss)
           into vd_dt_ini
              , vd_dt_fin
           from nota_fiscal nf
              , nf_compl_serv cs
          where cs.lotenfs_id = en_lotenfs_id
            and nf.id         = cs.notafiscal_id;
         --
      exception
         when others then
            vd_dt_ini := sysdate;
            vd_dt_fin := sysdate;
      end;
      --
      vn_fase := 3;
      --
      begin
         --
         select sum(nft.vl_total_item)
              , sum(nft.vl_deducao)
           into vn_vl_total_serv
              , vn_vl_total_ded
           from nota_fiscal        nf
              , nf_compl_serv      cs
              , nota_fiscal_total  nft
          where cs.lotenfs_id      = en_lotenfs_id
            and nf.id              = cs.notafiscal_id
            and nft.notafiscal_id  = nf.id;
         --
      exception
         when others then
            vn_vl_total_serv := 0;
            vn_vl_total_ded  := 0;
      end;
      --
      vn_fase := 4;
      --
      update lote_nfs set dt_ini         = vd_dt_ini
                        , dt_fin         = vd_dt_fin
                        , qtde_rps       = nvl(en_qtde_nfs,0)
                        , vl_total_serv  = nvl(vn_vl_total_serv,0)
                        , vl_total_ded   = nvl(vn_vl_total_ded,0)
                        , dm_situacao    = 0 -- 0-Aberto (liberado)
       where id = en_lotenfs_id;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_atual_dados_lote_nfs fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem          => gv_mensagem_log
                             , ev_resumo            => gv_mensagem_log
                             , en_tipo_log          => ERRO_DE_SISTEMA
                             );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_atual_dados_lote_nfs;

-------------------------------------------------------------------------------------------------------
--| Função cria o Lote de Envio da Nota Fiscal de Serviço e retorna o ID

function fkg_integr_lote ( est_log_generico_nf     in out nocopy  dbms_sql.number_table
                         , en_lotenfs_id           in lote_nfs.id%type
                         , en_qtde_nfs             in number
                         , en_empresa_id           in             Empresa.id%TYPE
                         , en_dm_ind_emit          in             lote_nfs.dm_ind_emit%type
                         )
         return lote_nfs.id%TYPE
is
   --
   vn_fase            number := 0;
   vn_loggenericonf_id  log_generico_nf.id%TYPE;
   vn_lotenfs_id      lote_nfs.id%TYPE;
   --
begin
   -- Monta cabeçalho do Lote para informação na validação
   -- Empresa
   vn_fase := 1;
   --
   pkb_atual_dados_lote_nfs ( en_lotenfs_id => en_lotenfs_id
                            , en_qtde_nfs   => en_qtde_nfs
                            );
   --
   vn_fase := 1.1;
   --
   if nvl(en_empresa_id,0) > 0 then
      --
      gv_cabec_log := pk_csf.fkg_nome_empresa ( en_empresa_id => en_empresa_id );
      --
   end if;
   --
   vn_fase := 2;
   --
   -- Válida se a empresa é válida
   if pk_csf.fkg_empresa_id_valido ( en_empresa_id => en_empresa_id ) = false then
      --
      vn_fase := 3;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Empresa" (' || en_empresa_id || ') está incorreta para a criação do lote de notas fiscais de serviço.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 99;
   -- Se não houve erro na válidação insere os dados
   if nvl(est_log_generico_nf.count,0) = 0 then
      --
      vn_fase := 99.1;
      --
      select lotenfs_seq.nextval
        into vn_lotenfs_id
        from dual;
      --
      vn_fase := 99.2;
      --
      insert into LOTE_NFS ( id
                           , empresa_id
                           , dm_situacao
                           , dm_tp_amb
                           , dt_abert
                           , dm_ind_emit
                           )
                    values ( vn_lotenfs_id
                           , en_empresa_id
                           , 7 -- 7-Em geração do lote, 0-Aberto
                           , pk_csf.fkg_tp_amb_empresa ( en_empresa_id )
                           , trunc(sysdate)
                           , en_dm_ind_emit
                           );
      --
   end if;
   --
   vn_fase := 100;
   --
   return vn_lotenfs_id;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na fkg_integr_lote fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end fkg_integr_lote;

-------------------------------------------------------------------------------------------------------
-- Procedimento excluir lotes sem notas fiscais de serviço.

procedure pkb_excluir_lote_sem_nfs ( en_multorg_id in mult_org.id%type )
is
   --
   vn_loggenericonf_id log_generico_nf.id%TYPE;
   vn_qtde           number;
   --
   vv_formato_data     param_global_csf.valor%type := null;
   --
   cursor c_lote ( en_multorg_id in mult_org.id%type ) is
   select lt.id
     from empresa       em
        , lote_nfs      lt
    where em.multorg_id                     = en_multorg_id
      and lt.empresa_id                     = em.id
      and lt.dm_situacao                    not in (3,7) -- 3-Erro ao enviar Lote a SEFAZ, 7-Em geração de lote
      and to_date(lt.dt_abert,vv_formato_data/*'dd/mm/yyyy'*/) >= to_date(sysdate,vv_formato_data/*'dd/mm/yyyy'*/) - 15
      and not exists ( select * from nf_compl_serv nc where nc.lotenfs_id = lt.id )
    order by lt.id;
   --
begin
   --
   vv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   for rec in c_lote ( en_multorg_id => en_multorg_id )
   loop
      --
      exit when c_lote%notfound or (c_lote%notfound) is null;
      --
      vn_qtde := 0;
      --
      delete from estr_arq_lote_nfs where lotenfs_id = rec.id;
      --
      delete from lote_nfs where id = rec.id;
      --
      commit;
      --
   end loop;
   --
exception
   when others then
      --
      rollback;
      --
      gv_mensagem_log := 'Erro na pkb_excluir_lote_sem_nfs: ' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem          => gv_cabec_log
                             , ev_resumo            => gv_mensagem_log
                             , en_tipo_log          => ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_excluir_lote_sem_nfs;

-------------------------------------------------------------------------------------------------------
-- Processo de criação do Lote de Notas Fiscais de Serviços Emissão Propria

procedure pkb_gera_lote_emissao_propria ( en_multorg_id in mult_org.id%type )
is
   --
   vn_fase            number := 0;
   vn_loggenericonf_id  log_generico_nf.id%TYPE;
   vn_lotenfs_id      Lote_nfs.id%TYPE := null;
   vn_qtde_nfs        number := 0;
   vt_log_generico    dbms_sql.number_table;
   --
   vn_dm_ws_canc        cidade_nfse.dm_ws_canc%type := null;
   vn_dm_tp_transmis    cidade_nfse.dm_tp_transmis%type;
   --
   vn_qtde_pend         number;
   vb_represa           boolean := False;
   --
   cursor c_empresa ( en_multorg_id in mult_org.id%type ) is
   select e.id            empresa_id
        , e.cod_matriz    cod_matriz
        , e.cod_filial    cod_filial
        , e.max_qtd_nfe_lote  max_qtd_nfe_lote   -- Verificar Leandro se esse parametro será utiliado pra serviço.
        , cid.ibge_cidade
        , n.dm_represa_nfse
        , n.dm_tp_transmis
        , n.dm_ws_canc
     from empresa e
        , pessoa p
        , cidade cid
        , cidade_nfse n
    where 1 = 1
      and e.multorg_id  = en_multorg_id
      and e.dm_situacao = 1 -- ativo
      and p.id          = e.pessoa_id
      and cid.id        = p.cidade_id
      and n.cidade_id   = cid.id
    order by e.cod_matriz
           , e.cod_filial;
   --
   cursor c_nfs ( en_empresa_id Empresa.id%TYPE ) is
   select nf.id notafiscal_id, nf.nro_nf, nf.serie, nfc.id notafiscalcanc_id
     from nota_fiscal       nf
        , mod_fiscal        mf
        , nf_compl_serv     nfcs
        , nota_fiscal_canc  nfc
    where nf.empresa_id        = en_empresa_id
      and nf.dm_st_proc        = 1 -- Aguardando processamento
      and nf.dm_ind_emit       = 0 -- Emissão Própria
      and mf.id                = nf.modfiscal_id
      and mf.cod_mod           = '99'
      and nfcs.notafiscal_id   = nf.id
      and nfcs.lotenfs_id      is null
      and nfc.notafiscal_id(+) = nf.id
    order by nf.serie, nf.nro_nf;
   --
begin
   --
   vn_fase := 1;
   --
   -- Inicia a criação de lote por empresa
   for rec_emp in c_empresa ( en_multorg_id => en_multorg_id )
   loop
      --
      exit when c_empresa%notfound or c_empresa%notfound is null;
      --
      vn_fase := 2;
      --
      vn_lotenfs_id := 0;
      --
      vn_dm_ws_canc := rec_emp.dm_ws_canc; -- pk_csf_nfs.fkg_empresa_cidade_ws_canc ( en_empresa_id => rec_emp.empresa_id );
      --
      vn_fase := 2.1;
      --
      vn_dm_tp_transmis := rec_emp.dm_tp_transmis; -- pk_csf_nfs.fkg_empresa_cidade_tp_transmis ( en_empresa_id => rec_emp.empresa_id );
      --
      vn_fase := 2.2;
      --
      for rec_nfs in c_nfs( rec_emp.empresa_id ) loop
         exit when c_nfs%notfound or c_nfs%notfound is null;
         --
         vn_fase := 3;
         --
         if nvl(rec_nfs.notafiscalcanc_id,0) > 0 then
            --
            if nvl(vn_dm_tp_transmis,0) <> 2
               and nvl(vn_dm_ws_canc,0) <> 1
               then
               --
               goto proximo;
               --
            end if;
            --
         end if;
         --
         vn_qtde_pend := 0;
         vb_represa   := False;
         --
         if rec_emp.dm_represa_nfse = 1 then
            begin
               --
               select /*+ USE_MERGE(MF,NF) ORDERED */count(1)
                 into vn_qtde_pend
                 from nota_fiscal nf
                    , mod_fiscal mf
                where 1 = 1
                  and nf.empresa_id      = rec_emp.empresa_id
                  and nf.dm_ind_emit     = 0
                  and nf.dm_arm_nfe_terc = 0
                  and nf.dm_st_proc      not in (4, 6, 7, 8)
                  and nf.serie           = rec_nfs.serie
                  and nf.nro_nf          < rec_nfs.nro_nf
                  and mf.id              = nf.modfiscal_id
                  and mf.cod_mod         = '99';
               --
            exception
               when others then
                  vn_qtde_pend := 0;
            end;  
            --          
            -- Sim represa NFSe se tiver pendencia anterior
            if nvl(vn_qtde_pend,0) <= 0 then
              --
              vb_represa := True;
              --
            end if;  
            --
         else
            vb_represa := False;
         end if;
         --
         -- Inicio do Teste de represar NFSe de Embu
         if vn_dm_tp_transmis = 2   -- Arquivo
            or not vb_represa then  -- Não represa ou Represa com notas pendentes
            --
            vn_fase := 3.1;
            -- Verifica se não existe lote e o cria "OU" se o número de notas for maior ou igual
            -- ao que está parametrizado, zero o lote para a criação de um novo lote
            -- if (nvl(vn_lotenfs_id,0) <= 0 or nvl(vn_qtde_nfs,0) >= nvl(rec_emp.max_qtd_nfe_lote,0) ) then
            if ( rec_emp.ibge_cidade = '3550308'
                 and vn_dm_tp_transmis = 2 -- Arquivo
                 and ( nvl(vn_lotenfs_id,0) <= 0 or nvl(vn_qtde_nfs,0) > 10000 )
               ) or ( vn_dm_tp_transmis = 1 -- webservice
                      and ( nvl(vn_lotenfs_id,0) <= 0 or nvl(vn_qtde_nfs,0) >= nvl(rec_emp.max_qtd_nfe_lote,0) )
                      ) or ( rec_emp.ibge_cidade <> '3550308'
                             and vn_dm_tp_transmis = 2 -- Arquivo
                             and ( nvl(vn_lotenfs_id,0) <= 0 or nvl(vn_qtde_nfs,0) >= nvl(rec_emp.max_qtd_nfe_lote,0) )
                           )
               then
               --
               vn_fase := 4;
               --
               commit; -- Para liberar os lotes gerados anteriormente
               --
               vt_log_generico.delete;
               --
               vn_fase := 5;
               --
               vn_lotenfs_id := fkg_integr_lote ( est_log_generico_nf     => vt_log_generico
                                                , en_lotenfs_id           => vn_lotenfs_id
                                                , en_qtde_nfs             => vn_qtde_nfs
                                                , en_empresa_id           => rec_emp.empresa_id
                                                , en_dm_ind_emit          => 0 -- Emissão Própria
                                                );
               --
               vn_fase := 6;
               --
               vn_qtde_nfs := 1;
               -- Se houve erro ao criar o lote sai do processo de notas fiscais de serviço
               if nvl(vt_log_generico.count,0) > 0 then
                  --
                  exit;
                  --
               end if;
               --
            else -- eliminado abaixo
               vn_qtde_nfs := nvl(vn_qtde_nfs,0) + 1;
            end if;
            --
            vn_fase := 7;
            -- Atualiza a Nota Fiscal de Serviço com o Id do Lote
            update nf_compl_serv set lotenfs_id = vn_lotenfs_id
             where notafiscal_id = rec_nfs.notafiscal_id;
            --
            vn_fase := 8;
            --
            -- Final do Teste de represar NFSe de Embu
            --

         else -- Lote não será gerado, devido as seguintes condições: if vn_dm_tp_transmis = 2-Arquivo, or ( rec_emp.dm_represa_nfse = 0-Não represa NFse
              -- or (rec_emp.dm_represa_nfse = 1-Sim represa NFSe se tiver pendencia anterior and nvl(vn_qtde_pend,0) <= 0 ) )
            --
            vn_fase := 9;
            --
            gv_mensagem_log := null;
            --
            gv_mensagem_log := 'Não foi criado Lote para a Nota Fiscal de Número = '||rec_nfs.nro_nf||' e Série '||rec_nfs.serie||'. Para a criação do lote de '||
                               'notas fiscais de serviço é necessário que sejam atendidas algumas das seguintes condições: 1) Tipo de Transmissão de NFSe da '||
                               'Cidade = 2-Arquivo, OU, 2) Represa NFS-e = 0-Não, OU, 3) Represa NFS-e = 1-Sim E não existir Notas Fiscais Pendentes (Situação '||
                               'diferente de 4-Autorizada, 6-Denegada, 7-Cancelada, 8-Inutilizada) com a mesma Série e Numeração anterior.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                , ev_mensagem         => 'Processo de criação do Lote de Notas Fiscais de Serviços Emissão Própria.'
                                , ev_resumo           => gv_mensagem_log
                                , en_tipo_log         => INFORMACAO
                                , en_referencia_id    => rec_nfs.notafiscal_id
                                , ev_obj_referencia   => 'NOTA_FISCAL' );
            --
            -- Armazena o "loggenerico_id" na memória
            --pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
            --                       , est_log_generico_nf => est_log_generico_nf );
            --
         end if;
         --
         vn_fase := 10;
         -- incluído acima
         --vn_qtde_nfs := nvl(vn_qtde_nfs,0) + 1;
         --
         <<proximo>>
         --
         vn_fase := 11;
         --
      end loop;
      --
      vn_fase := 12;
      --
      pkb_atual_dados_lote_nfs ( en_lotenfs_id => vn_lotenfs_id
                               , en_qtde_nfs   => vn_qtde_nfs
                               );
      --
      vn_fase := 13;
      --
      commit;
      --
   end loop;
   --
exception
   when others then
      --
      rollback;
      --
      gv_mensagem_log := 'Erro na pkb_gera_lote_emissao_propria fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem          => gv_cabec_log
                             , ev_resumo            => gv_mensagem_log
                             , en_tipo_log          => ERRO_DE_SISTEMA
                             );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_gera_lote_emissao_propria;

-------------------------------------------------------------------------------------------------------
-- Processo de criação do Lote de Notas Fiscais de Serviços Terceiros

procedure pkb_gera_lote_emissao_terceiro ( en_multorg_id in mult_org.id%type )
is
   --
   vn_fase            number := 0;
   vn_loggenericonf_id  log_generico_nf.id%TYPE;
   vn_lotenfs_id      Lote_nfs.id%TYPE := null;
   vn_qtde_nfs        number := 0;
   vt_log_generico    dbms_sql.number_table;
   --
   vn_dm_ws_canc        cidade_nfse.dm_ws_canc%type := null;
   vn_dm_tp_transmis    cidade_nfse.dm_tp_transmis%type;
   --
   cursor c_empresa ( en_multorg_id in mult_org.id%type ) is
   select e.id            empresa_id
        , e.cod_matriz    cod_matriz
        , e.cod_filial    cod_filial
        , e.max_qtd_nfe_lote  max_qtd_nfe_lote   -- Verificar Leandro se esse parametro será utiliado pra serviço.
     from empresa e
    where e.multorg_id  = en_multorg_id
      and e.dm_situacao = 1 -- ativo
    order by e.cod_matriz
           , e.cod_filial;
   --
   cursor c_nfs ( en_empresa_id Empresa.id%TYPE ) is
   select nf.id notafiscal_id, nf.nro_nf, nf.serie, nfc.id notafiscalcanc_id
     from nota_fiscal       nf
        , mod_fiscal        mf
        , nf_compl_serv     nfcs
        , nota_fiscal_canc  nfc
    where nf.empresa_id  = en_empresa_id
      and nf.dm_st_proc  = 1 -- Aguardando processamento
      and nf.dm_ind_emit = 1 -- Terceiros
      and mf.id          = nf.modfiscal_id
      and mf.cod_mod     = '99'
      and nfcs.notafiscal_id = nf.id
      and nfcs.lotenfs_id is null
      and nfc.notafiscal_id(+) = nf.id
    order by nf.serie, nf.nro_nf;
   --
begin
   --
   vn_fase := 1;
   --
   -- Inicia a criação de lote por empresa
   for rec_emp in c_empresa ( en_multorg_id => en_multorg_id )
   loop
      --
      exit when c_empresa%notfound or c_empresa%notfound is null;
      --
      vn_fase := 2;
      --
      vn_lotenfs_id := 0;
      --
      vn_dm_ws_canc := pk_csf_nfs.fkg_empresa_cidade_ws_canc ( en_empresa_id => rec_emp.empresa_id );
      --
      vn_fase := 2.1;
      --
      vn_dm_tp_transmis := pk_csf_nfs.fkg_empresa_cidade_tp_transmis ( en_empresa_id => rec_emp.empresa_id );
      --
      for rec_nfs in c_nfs( rec_emp.empresa_id ) loop
         exit when c_nfs%notfound or c_nfs%notfound is null;
         --
         vn_fase := 3;
         --
         if nvl(rec_nfs.notafiscalcanc_id,0) > 0 then
            --
            if nvl(vn_dm_tp_transmis,0) <> 2
               and nvl(vn_dm_ws_canc,0) <> 1
               then
               --
               goto proximo;
               --
            end if;
            --
         end if;
         --
         vn_fase := 3.1;
         -- Verifica se não existe lote e o cria "OU" se o número de notas for maior ou igual
         -- ao que está parametrizado, zero o lote para a criação de um novo lote
         if (nvl(vn_lotenfs_id,0) <= 0 or nvl(vn_qtde_nfs,0) >= nvl(rec_emp.max_qtd_nfe_lote,0) ) then
            --
            vn_fase := 4;
            --
            commit; -- Para liberar os lotes gerados anteriormente
            --
            vt_log_generico.delete;
            --
            vn_fase := 5;
            --
            vn_lotenfs_id := fkg_integr_lote ( est_log_generico_nf     => vt_log_generico
                                             , en_lotenfs_id           => vn_lotenfs_id
                                             , en_qtde_nfs             => vn_qtde_nfs
                                             , en_empresa_id           => rec_emp.empresa_id
                                             , en_dm_ind_emit          => 1 -- Terceiros
                                             );
            --
            vn_fase := 6;
            --
            vn_qtde_nfs := 1;
            -- Se houve erro ao criar o lote sai do processo de notas fiscais de serviço
            if nvl(vt_log_generico.count,0) > 0 then
               --
               exit;
               --
            end if;
            --
         else -- eliminado abaixo
            vn_qtde_nfs := nvl(vn_qtde_nfs,0) + 1;
         end if;
         --
         vn_fase := 7;
         -- Atualiza a Nota Fiscal de Serviço com o Id do Lote
         update nf_compl_serv set lotenfs_id = vn_lotenfs_id
          where notafiscal_id = rec_nfs.notafiscal_id;
         --
         vn_fase := 8;
         -- incluído acima
         --vn_qtde_nfs := nvl(vn_qtde_nfs,0) + 1;
         --
         <<proximo>>
         --
         vn_fase := 11;
         --
      end loop;
      --
      vn_fase := 12;
      --
      pkb_atual_dados_lote_nfs ( en_lotenfs_id => vn_lotenfs_id
                               , en_qtde_nfs   => vn_qtde_nfs
                               );
      --
      vn_fase := 13;
      --
      commit;
      --
   end loop;
   --
exception
   when others then
      --
      rollback;
      --
      gv_mensagem_log := 'Erro na pkb_gera_lote_emissao_terceiro fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem          => gv_cabec_log
                             , ev_resumo            => gv_mensagem_log
                             , en_tipo_log          => ERRO_DE_SISTEMA
                             );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_gera_lote_emissao_terceiro;

-------------------------------------------------------------------------------------------------------
-- Processo de criação do Lote de Notas Fiscais de Serviços

procedure pkb_gera_lote ( en_multorg_id in mult_org.id%type )
is
   --
   vn_fase            number := 0;
   vn_loggenericonf_id  log_generico_nf.id%TYPE;
   --
   cursor c_lote ( en_multorg_id in mult_org.id%type ) is
   select l.id
     from lote_nfs l
        , empresa  em
    where em.multorg_id = en_multorg_id
      and l.empresa_id  = em.id
      and l.dm_situacao = 0 -- 0-Aberto
    order by 1;
   --
begin
   --
   vn_fase := 1;
   --
   pkb_gera_lote_emissao_propria ( en_multorg_id => en_multorg_id );
   --
   vn_fase := 2;
   --
   pkb_gera_lote_emissao_terceiro ( en_multorg_id => en_multorg_id );
   --
   vn_fase := 3;
   -- lotes em aberto para passar no processo de geração de arquivo TXT
   for rec in c_lote ( en_multorg_id => en_multorg_id )
   loop
      --
      exit when c_lote%notfound or (c_lote%notfound) is null;
      --
      vn_fase := 3.1;
      --
      pk_emiss_nfse.pkb_geracao ( en_lotenfs_id => rec.id );
      --
   end loop;
   --
   vn_fase := 4;
   --
   pkb_excluir_lote_sem_nfs ( en_multorg_id => en_multorg_id );
   --
exception
   when others then
      --
      rollback;
      --
      gv_mensagem_log := 'Erro na pkb_gera_lote fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_gera_lote;

-------------------------------------------------------------------------------------------------------

--| Procedimento de Integração de informações de Processos Administrativos/Judiciarios do REINF vinculado com notas fiscais de serviço
procedure pkb_integr_nf_proc_reinf ( est_log_generico_nf          in out nocopy dbms_sql.number_table
                                   , est_row_nf_proc_reinf        in out nocopy nf_proc_reinf%rowtype
                                   , en_empresa_id                in            empresa.id%type
                                   , ed_dt_emiss                  in            date
                                   , en_dm_tp_proc                in            proc_adm_efd_reinf.dm_tp_proc%type
                                   , ev_nro_proc                  in            proc_adm_efd_reinf.nro_proc%type
                                   , en_cod_susp                  in            proc_adm_efd_reinf_inf_trib.cod_susp%type
                                   )
is
   --
   vn_fase              number := 0;
   vn_loggenericonf_id  log_generico_nf.id%TYPE;
   vn_emp_matriz_id     empresa.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   gv_cabec_log := gv_cabec_log || 'Dominio do Tipo de Processo: '|| pk_csf.fkg_dominio ( ev_dominio => 'NF_PROC_REINF.DM_TP_PROC', ev_vl => en_dm_tp_proc ) ||
                   ' Numero de Processo: '||ev_nro_proc || ' Código de Suspensão: '||en_cod_susp;
   --
   if pk_csf.fkg_nfe_nao_integrar ( en_notafiscal_id => est_row_nf_proc_reinf.notafiscal_id ) then
      --
      goto sair_integr;
      --
   end if;
   --
   vn_fase := 2;
   -- Recupera o ID da empresa matriz
   vn_emp_matriz_id := pk_csf.fkg_empresa_id_matriz(en_empresa_id => en_empresa_id);
   --
   vn_fase := 3;
   --
   est_row_nf_proc_reinf.procadmefdreinfinftrib_id := pk_csf_reinf.fkg_procadmefdreinfinftrib_id ( en_empresa_id => vn_emp_matriz_id
                                                                                                 , ed_dt_ref     => ed_dt_emiss
                                                                                                 , en_dm_tp_proc => en_dm_tp_proc
                                                                                                 , ev_nro_proc   => ev_nro_proc
                                                                                                 , en_cod_susp   => en_cod_susp
                                                                                                 );
   --
   vn_fase := 4;
   -- Válida Informação do Número da Parcela
   if nvl(est_row_nf_proc_reinf.procadmefdreinfinftrib_id,0) < 0 then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := 'Não foi possivel encontrar o processo administrativo/judiciario do REINF com os seguintes parametros: DM_TP_PROC: '|| en_dm_tp_proc ||
                         ', NRO_PROC: '|| ev_nro_proc ||', COD_SUSP: '||en_cod_susp || ' para a Data de Emissão '|| to_date(ed_dt_emiss,'dd/mm/yyyy') ||', Favor Verificar.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                          , ev_mensagem         => gv_cabec_log
                          , ev_resumo           => gv_mensagem_log
                          , en_tipo_log         => ERRO_DE_VALIDACAO
                          , en_referencia_id    => gn_referencia_id
                          , ev_obj_referencia   => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 5;
   --
   if trim(est_row_nf_proc_reinf.DM_IND_PROC_RET_ADIC) not in ('S','N') then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := 'Dominio de Indicador de Processo de Retenção de contribuição previdenciária adicional que deixou de ser Efetuada ('|| trim(est_row_nf_proc_reinf.DM_IND_PROC_RET_ADIC) ||
                         ') inválido, Favor Verificar.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                          , ev_mensagem         => gv_cabec_log
                          , ev_resumo           => gv_mensagem_log
                          , en_tipo_log         => ERRO_DE_VALIDACAO
                          , en_referencia_id    => gn_referencia_id
                          , ev_obj_referencia   => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 99;
   --
   -- Se não existe registro de log e o Tipo de Validação é 1 (válida e insere)
   -- então registra a Duplicata da Nota Fiscal
   if nvl(est_log_generico_nf.count,0) > 0 and
     fkg_ver_erro_log_generico_nfs( en_nota_fiscal_id => est_row_nf_proc_reinf.notafiscal_id ) = 1 then
      --
      vn_fase := 99.1;
      --
      update nota_fiscal set dm_st_proc = 10
       where id = est_row_nf_proc_reinf.notafiscal_id;
      --
   end if;
   --
   vn_fase := 99.2;
   --
   if nvl(est_row_nf_proc_reinf.notafiscal_id,0) > 0
    and nvl(est_row_nf_proc_reinf.procadmefdreinfinftrib_id,0) > 0
    and trim(est_row_nf_proc_reinf.DM_IND_PROC_RET_ADIC) in ('S', 'N')
    and nvl(est_row_nf_proc_reinf.valor,0) > 0 then
      --
      vn_fase := 99.3;
      --
      est_row_nf_proc_reinf.id := pk_csf_nfs.fkg_nfprocreinf_id ( en_notafiscal_id             => est_row_nf_proc_reinf.notafiscal_id
                                                                , en_procadmefdreinfinftrib_id => est_row_nf_proc_reinf.procadmefdreinfinftrib_id
                                                                , ev_dm_ind_proc_ret_adic      => est_row_nf_proc_reinf.dm_ind_proc_ret_adic
                                                                );
      --
      if nvl(gn_tipo_integr,0) = 1
       or nvl(est_row_nf_proc_reinf.id,0) = 0 then
         --
         vn_fase := 99.4;
         --
         select nfprocreinf_seq.nextval
           into est_row_nf_proc_reinf.id
           from dual;
         --
         insert into csf_own.nf_proc_reinf ( id
                                           , notafiscal_id
                                           , procadmefdreinfinftrib_id
                                           , dm_ind_proc_ret_adic
                                           , valor )
                                     values( est_row_nf_proc_reinf.id
                                           , est_row_nf_proc_reinf.notafiscal_id
                                           , est_row_nf_proc_reinf.procadmefdreinfinftrib_id
                                           , est_row_nf_proc_reinf.dm_ind_proc_ret_adic
                                           , est_row_nf_proc_reinf.valor );
         --
      else
         --
         vn_fase := 99.5;
         --
         update csf_own.nf_proc_reinf
            set notafiscal_id             = est_row_nf_proc_reinf.notafiscal_id
              , procadmefdreinfinftrib_id = est_row_nf_proc_reinf.procadmefdreinfinftrib_id
              , dm_ind_proc_ret_adic      = est_row_nf_proc_reinf.dm_ind_proc_ret_adic
              , valor                     = est_row_nf_proc_reinf.valor
          where id                        = est_row_nf_proc_reinf.id;
         --
      end if;
      --
      commit;
      --
   end if;
   --
    <<sair_integr>>
   null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_integr_nf_proc_reinf fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                             , ev_mensagem         => gv_cabec_log
                             , ev_resumo           => gv_mensagem_log
                             , en_tipo_log         => ERRO_DE_SISTEMA
                             , en_referencia_id    => gn_referencia_id
                             , ev_obj_referencia   => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_nf_proc_reinf;

-------------------------------------------------------------------------------------------------------

--| Procedimento que faz a integração as Notas Fiscais Cancelas

procedure pkb_integr_Nota_Fiscal_Canc ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                      , est_row_Nota_Fiscal_Canc  in out nocopy  Nota_Fiscal_Canc%rowtype
                                      , en_multorg_id             in             mult_org.id%type
                                      , en_loteintws_id           in             lote_int_ws.id%type default 0
                                      )
is
   --
   vn_fase              number := 0;
   vd_dt_emiss          Nota_Fiscal.dt_emiss%TYPE;
   vn_dm_st_proc        Nota_Fiscal.dm_st_proc%TYPE;
   vn_loggenericonf_id    log_generico_nf.id%TYPE;
   vn_empresa_id        Empresa.id%TYPE          := null;
   vn_nro_nf            Nota_Fiscal.nro_nf%TYPE  := null;
   vv_serie             Nota_Fiscal.serie%TYPE   := null;
   vv_cod_mod           Mod_Fiscal.cod_mod%TYPE  := null;
   vv_cpf_cnpj          param_integr_edi.cpf_cnpj%type := null;
   vb_integr_edi        boolean := false;
   vn_dm_integr_edi     nota_fiscal_dest.dm_integr_edi%type := 2;
   vn_nf_canc           number := 0;
   vn_dm_tipo_integr    empresa.dm_tipo_integr%type := null;
   vv_usuario_nome      neo_usuario.nome%type := null;
   vn_dm_ws_canc        cidade_nfse.dm_ws_canc%type := null;
   vn_dm_tp_transmis    cidade_nfse.dm_tp_transmis%type;
   --
begin
   --
   vn_fase := 1;
   --
   -- Busca dadaos da Nota Fiscal
   begin
      select nf.empresa_id
           , nf.nro_nf
           , nf.serie
           , mf.cod_mod
           , nf.dt_emiss
           , nf.dm_st_proc
           , nvl(nfd.cnpj, nfd.cpf)
           , e.dm_tipo_integr
        into vn_empresa_id
           , vn_nro_nf
           , vv_serie
           , vv_cod_mod
           , vd_dt_emiss
           , vn_dm_st_proc
           , vv_cpf_cnpj
           , vn_dm_tipo_integr
        from Nota_Fiscal nf
           , nota_fiscal_dest nfd
           , Mod_Fiscal  mf
           , empresa     e
           , pessoa      p
           , cidade      c
           , estado      es
       where nf.id              = est_row_Nota_Fiscal_Canc.notafiscal_id
         and nfd.notafiscal_id  = nf.id
         and mf.id              = nf.modfiscal_id
         and e.id               = nf.empresa_id
         and p.id               = e.pessoa_id
         and c.id               = p.cidade_id
         and es.id              = c.estado_id;
   exception
      when others then
         vn_empresa_id     := null;
         vn_nro_nf         := null;
         vv_serie          := null;
         vv_cod_mod        := null;
         vd_dt_emiss       := null;
         vn_dm_st_proc     := null;
         vv_cpf_cnpj       := null;
         vn_dm_tipo_integr := null;
   end;
   -- Monta cabeçalho do Log Genérico
   gv_cabec_log := null;
   --
   vn_fase := 2;
   --
   if nvl(vn_empresa_id,0) > 0 then
      --
      vn_fase := 2.1;
      --
      gv_cabec_log := 'Empresa: '||pk_csf.fkg_nome_empresa( en_empresa_id => vn_empresa_id );
      --
      gv_cabec_log := gv_cabec_log||chr(10);
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(vn_nro_nf,0) > 0 then
      --
      gv_cabec_log := gv_cabec_log||'Número: '||vn_nro_nf;
      --
      gv_cabec_log := gv_cabec_log||chr(10);
      --
   end if;
   --
   vn_fase := 4;
   --
   if vv_serie is not null then
      --
      gv_cabec_log := gv_cabec_log||'Série: '||vv_serie;
      --
      gv_cabec_log := gv_cabec_log||chr(10);
      --
   end if;
   --
   vn_fase := 5;
   --
   if vv_cod_mod is not null then
      --
      gv_cabec_log := gv_cabec_log||'Modelo: '||vv_cod_mod;
      --
      gv_cabec_log := gv_cabec_log||chr(10);
      --
   end if;
   --
   vn_fase := 6;
   --
   if vd_dt_emiss is not null then
      --
      gv_cabec_log := gv_cabec_log||'Data de emissão: '||to_char(vd_dt_emiss, 'dd/mm/yyyy');
      --
      gv_cabec_log := gv_cabec_log||chr(10);
      --
   end if;
   --
   if nvl(en_loteintws_id,0) > 0 then
      --
      gv_cabec_log := gv_cabec_log || 'Lote WS: ' || en_loteintws_id || chr(10);
      --
   end if;
   --
   vn_fase := 7;
   -- Verifica se a nota já tem registro de cancelamento
   begin
      --
      select distinct 1
        into vn_nf_canc
        from Nota_Fiscal_Canc
       where notafiscal_id = est_row_Nota_Fiscal_Canc.notafiscal_id;
      --
   exception
      when no_data_found then
         vn_nf_canc := 0;
   end;
   --
   vn_fase := 8;
   -- Se a situação da Nota Fiscal não for "7-Cancelada"
   if nvl(vn_dm_st_proc,0) in (0, 4) then
      --
      vn_fase  := 9;
      -- Verifica se teve nota fiscal informada
      if nvl(est_row_Nota_Fiscal_Canc.notafiscal_id,0) = 0
         and nvl(est_log_generico_nf.count,0) = 0 then
         --
         vn_fase := 10;
         --
         gv_mensagem_log := 'Não informada a Nota Fiscal para ser cancelada.';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_VALIDACAO
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia
                          , en_empresa_id      => vn_empresa_id );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      end if;
      --
      vn_fase := 11;
      --
      -- Verifica se a data de cancelamento é nula
      if est_row_Nota_Fiscal_Canc.dt_canc is null then
         --
         est_row_Nota_Fiscal_Canc.dt_canc := sysdate;
         --
      end if;
      --
      vn_fase := 12;
      --
      if trunc(est_row_Nota_Fiscal_Canc.dt_canc) < trunc(vd_dt_emiss) then
         --
         est_row_Nota_Fiscal_Canc.dt_canc := sysdate;
         --
      end if;
      --
      vn_fase := 13;
      --
      -- Verifica se não foi informada a juntificativa de cancelamento
      if trim( est_row_Nota_Fiscal_Canc.justif ) is null then
         --
         vn_fase := 14;
         --
         gv_mensagem_log := 'Não foi informada a justificativa do cancelamento da nota fiscal.';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_VALIDACAO
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia
                          , en_empresa_id      => vn_empresa_id  );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      else
         --
         vn_fase := 15;
         --
         if length(trim( est_row_Nota_Fiscal_Canc.justif )) < 15 then
            --
            vn_fase := 16;
            --
            gv_mensagem_log := 'Justificativa do cancelamento deve possuir no mínimo 15 caracteres.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia
                             , en_empresa_id      => vn_empresa_id );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                , est_log_generico_nf  => est_log_generico_nf );
            --
   end if;
   --
      end if;
      --
      vn_fase := 17;
      --
      -- Válida se a "Situação do Processo" da Nota Fiscal permite ser cancelada
      --
      if nvl(vn_dm_st_proc,0) not in (0, 4) then
         --
         vn_fase := 18;
         --
         gv_mensagem_log := 'Situação do processo da Nota Fiscal não permite que ela seja cancelada ('||vn_dm_st_proc||').';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_VALIDACAO
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia
                          , en_empresa_id      => vn_empresa_id );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      end if;
      --
      vn_fase := 19;
      --
      if nvl(est_row_Nota_Fiscal_Canc.notafiscal_id, 0) > 0
         and est_row_Nota_Fiscal_Canc.dt_canc is not null
         and est_row_Nota_Fiscal_Canc.justif is not null then
         --
         est_row_Nota_Fiscal_Canc.justif         := trim( pk_csf.fkg_converte( est_row_Nota_Fiscal_Canc.justif ) );
         est_row_Nota_Fiscal_Canc.dm_st_integra  := nvl(est_row_Nota_Fiscal_Canc.dm_st_integra,0);
         --
         vn_fase := 20;
         --
         if nvl(vn_dm_tipo_integr,0) = 3 then -- Integração Table/View
            est_row_Nota_Fiscal_Canc.dm_st_integra  := 8;
         else
            est_row_Nota_Fiscal_Canc.dm_st_integra  := nvl(est_row_Nota_Fiscal_Canc.dm_st_integra,0);
         end if;
         -- Se não existe registro de log e o Tipo de Integração é 1 (válida e insere)
         -- então registra o Cancelamento da NF
         if nvl(est_log_generico_nf.count,0) <= 0 then
            --
            vn_fase := 21;
            --
            if nvl(vn_nf_canc,0) <= 0 then
               --
               vn_fase := 22;
               --
               select notafiscalcanc_seq.nextval
                 into est_row_Nota_Fiscal_Canc.id
                 from dual;
               --
               vn_fase := 23;
               --
               insert into Nota_Fiscal_Canc ( id
                                            , notafiscal_id
                                            , dt_canc
                                            , justif
                                            , dm_st_integra )
                                     values ( est_row_Nota_Fiscal_Canc.id
                                            , est_row_Nota_Fiscal_Canc.notafiscal_id
                                            , est_row_Nota_Fiscal_Canc.dt_canc
                                            , est_row_Nota_Fiscal_Canc.justif
                                            , est_row_Nota_Fiscal_Canc.dm_st_integra
                                            );
               --
            else
               --
               vn_fase := 24;
               --
               update Nota_Fiscal_Canc set dt_canc        = est_row_Nota_Fiscal_Canc.dt_canc
                                         , justif         = est_row_Nota_Fiscal_Canc.justif
                                         , dm_st_integra  = est_row_Nota_Fiscal_Canc.dm_st_integra
                where notafiscal_id = est_row_Nota_Fiscal_Canc.notafiscal_id;
               --
            end if;
            --
            vn_fase := 25;
            --
            vn_dm_ws_canc := pk_csf_nfs.fkg_empresa_cidade_ws_canc ( en_empresa_id => vn_empresa_id );
            --
            vn_fase := 25.01;
            --
            vn_dm_tp_transmis := pk_csf_nfs.fkg_empresa_cidade_tp_transmis ( en_empresa_id => vn_empresa_id );
            --
            vn_fase := 25.1;
            -- Atualiza a Situação do processo da Nota Fiscal para 1-Não Processada. Aguardando Processamento
            -- e indica que não foi atualizado no ERP
            if nvl(vn_dm_ws_canc,0) = 1 -- sim faz por WebService/Arquivo
               and vv_cod_mod = '99'
               then
               --
               vn_fase := 25.2;
               --
               -- Variavel global usada em logs de triggers (carrega)
               gv_objeto := 'pk_csf_api_nfs.pkb_integr_Nota_Fiscal_Canc';
               gn_fase   := vn_fase;
               --
               update Nota_Fiscal set dm_st_proc          = 1
                                    , dt_st_proc          = sysdate
                                    , dm_st_email         = 0 -- Não enviado
                                    , dm_st_integra       = est_row_Nota_Fiscal_Canc.dm_st_integra
                                    , dm_impressa         = 0
                                    , NRO_TENTATIVAS_IMPR = 0
                                    , DT_ULT_TENTA_IMPR   = null
                                    , impressora_id       = null
                where id = est_row_Nota_Fiscal_Canc.notafiscal_id;
               --
               -- Variavel global usada em logs de triggers (limpa)
               gv_objeto := 'pk_csf_api_nfs';
               gn_fase   := null;
               --
               if nvl(vn_dm_tp_transmis,0) = 2 then -- Arquivo
                  --
                  update nf_compl_serv set lotenfs_id = null
                   where notafiscal_id = est_row_Nota_Fiscal_Canc.notafiscal_id;
                  --
               end if;
               --
            else
               --
               vn_fase := 25.3;
               --
               -- Variavel global usada em logs de triggers (carrega)
               gv_objeto := 'pk_csf_api_nfs.pkb_integr_Nota_Fiscal_Canc'; 
               gn_fase   := vn_fase;
               --
               update Nota_Fiscal set dm_st_proc          = 7
                                    , dt_st_proc          = sysdate
                                    , dm_st_email         = 0 -- Não enviado
                                    , dm_st_integra       = est_row_Nota_Fiscal_Canc.dm_st_integra
                                    , dm_impressa         = 0
                                    , NRO_TENTATIVAS_IMPR = 0
                                    , DT_ULT_TENTA_IMPR   = null
                                    , impressora_id       = null
                where id = est_row_Nota_Fiscal_Canc.notafiscal_id;
               --
               -- Variavel global usada em logs de triggers (limpa)
               gv_objeto := 'pk_csf_api_nfs';
               gn_fase   := null;
               --
               gv_mensagem_log := 'Cancelamento efetuado com sucesso no COMPLIANCE. O cancelamento deve ser feito através do site da prefeitura!';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                   , ev_mensagem        => gv_cabec_log
                                   , ev_resumo          => gv_mensagem_log
                                   , en_tipo_log        => INFO_CANC_NFE
                                   , en_referencia_id   => gn_referencia_id
                                   , ev_obj_referencia  => gv_obj_referencia
                                   , en_empresa_id      => vn_empresa_id
                                   , en_dm_impressa     => 1
                                   );
               --
            end if;
            --
            vn_fase := 25.4;
            --
            delete from nota_fiscal_pdf
             where notafiscal_id = est_row_Nota_Fiscal_Canc.notafiscal_id;
            --
            vn_fase := 26;
            --
            gv_mensagem_log := 'Inicio do processo de cancelamento.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                , ev_mensagem        => gv_cabec_log
                                , ev_resumo          => gv_mensagem_log
                                , en_tipo_log        => INFO_CANC_NFE
                                , en_referencia_id   => gn_referencia_id
                                , ev_obj_referencia  => gv_obj_referencia
                                , en_empresa_id      => vn_empresa_id
                                , en_dm_impressa     => 1
                                );
            --
            vn_fase := 27;
            --
            if nvl(est_row_Nota_Fiscal_Canc.usuario_id,0) > 0 then
               vv_usuario_nome := pk_csf.fkg_usuario_nome ( en_usuario_id => est_row_Nota_Fiscal_Canc.usuario_id );
            else
               vv_usuario_nome := 'Integração';
            end if;
            --
            vn_fase := 28;
            --
            gv_mensagem_log := 'Usuário que solicitou o cancelamento: '||vv_usuario_nome;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => INFO_CANC_NFE
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia
                             , en_empresa_id      => vn_empresa_id
                             , en_dm_impressa     => 1 );
            --
            --
            vn_fase := 29;
            -- inicio do processo de integração EDI
            vb_integr_edi := pk_csf.fkg_integr_edi ( en_multorg_id => en_multorg_id
                                                   , ev_cpf_cnpj   => vv_cpf_cnpj
                                                   , en_dm_tipo    => 1 -- NFe
                                                   );
            --
            vn_fase := 30;
            --
            if vb_integr_edi then
               vn_dm_integr_edi := 0; -- Integra EDI
            else
               vn_dm_integr_edi := 2; -- Sem efeito
            end if;
            --
            vn_fase := 31;
            --
            update nota_fiscal_dest set dm_integr_edi = vn_dm_integr_edi
             where notafiscal_id = est_row_Nota_Fiscal_Canc.notafiscal_id;
            --
         end if;
         --
      end if;
      --
   else
      --
      vn_fase := 32;
      --
      if nvl(vn_dm_st_proc,0) in (2, 3, 5, 8, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 99) then
      --
         vn_fase := 33;
         --
         if nvl(vn_dm_tipo_integr,0) = 3 then -- Integração Table/View
            est_row_Nota_Fiscal_Canc.dm_st_integra  := 8;
         else
            est_row_Nota_Fiscal_Canc.dm_st_integra  := nvl(est_row_Nota_Fiscal_Canc.dm_st_integra,0);
         end if;
         --
         -- Variavel global usada em logs de triggers (carrega)
         gv_objeto := 'pk_csf_api_nfs.pkb_integr_Nota_Fiscal_Canc'; 
         gn_fase   := vn_fase;
         --
         update nota_fiscal set dm_st_proc          = 20
                              , dt_st_proc          = sysdate
                              , dm_st_integra       = est_row_Nota_Fiscal_Canc.dm_st_integra
                              , dm_impressa         = 0
                              , NRO_TENTATIVAS_IMPR = 0
                              , DT_ULT_TENTA_IMPR   = null
                              , impressora_id       = null
            where id = est_row_Nota_Fiscal_Canc.notafiscal_id;
         --
         -- Variavel global usada em logs de triggers (limpa)
         gv_objeto := 'pk_csf_api_nfs';
         gn_fase   := null;
         --
         vn_fase := 33.1;
         --
         delete from nota_fiscal_pdf
             where notafiscal_id = est_row_Nota_Fiscal_Canc.notafiscal_id;
         --
         vn_fase := 34;
         --
         commit;
         --
         gv_mensagem_log := 'Erro ao cancelar, situação do processo alterado para 20 - RPS não convertido';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => INFO_CANC_NFE
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia
                          , en_empresa_id      => vn_empresa_id );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      end if;
      --
   end if; -- nvl(vn_dm_st_proc,0) <> 7
   --
   <<sair_integr>>
   null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_integr_Nota_Fiscal_Canc fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia
                          , en_empresa_id      => vn_empresa_id  );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_Nota_Fiscal_Canc;

-------------------------------------------------------------------------------------------------------

-- Integra informações da Duplicata de cobrança
procedure pkb_integr_NFCobr_Dup ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                , est_row_NFCobr_Dup        in out nocopy  NFCobr_Dup%rowtype
                                , en_notafiscal_id          in             Nota_Fiscal.id%TYPE )
is
   --
   vn_fase           number := 0;
   vn_loggenericonf_id log_generico_nf.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_nfe_nao_integrar ( en_notafiscal_id => en_notafiscal_id ) then
      --
      goto sair_integr;
      --
   end if;
   --
   vn_fase := 1.1;
   --
   if nvl(est_row_NFCobr_Dup.nfcobr_id,0) = 0
      and nvl(est_log_generico_nf.count,0) = 0 then
      --
      vn_fase := 1.2;
      --
      gv_mensagem_log := 'Não existe Dados da Cobrança para a Duplicata.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 2;
   -- Válida Informação do Número da Parcela
   if trim( est_row_NFCobr_Dup.nro_parc ) is null then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := 'Número da Parcela da Duplicata não foi informado.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 3;
   -- Válida informação do vencimento da Duplicata
   if est_row_NFCobr_Dup.dt_vencto is null then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := 'Data de vencimento da Parcela da Duplicata não foi informada.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   elsif to_number(to_char(est_row_NFCobr_Dup.dt_vencto, 'RRRR')) > 2099 then
      --
      vn_fase := 3.2;
      --
      gv_mensagem_log := 'Data de vencimento da Parcela da Duplicata ('||to_char(est_row_NFCobr_Dup.dt_vencto,'dd/mm/rrrr')||
                         ') não pode ultrapassar o ano de 2099.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 3.3;
   -- Quando o indicador do emitente for "terceiros", a data do vencimento não pode ser menor que a data da Entrada ou Emissão
   if est_row_NFCobr_Dup.dt_vencto is null then
      --
      if gt_row_Nota_Fiscal.dm_ind_emit = 1 -- terceiros
         and est_row_NFCobr_Dup.dt_vencto < nvl(gt_row_Nota_Fiscal.dt_sai_ent, gt_row_Nota_Fiscal.dt_emiss)
         then
         --
         vn_fase := 3.4;
         --
         gv_mensagem_log := 'Data de vencimento da Parcela da Duplicata ('||to_char(est_row_NFCobr_Dup.dt_vencto,'dd/mm/rrrr')||
                            ') não pode ser menor que a data de Entrada ou Emissão ('||
                            to_char(nvl(gt_row_Nota_Fiscal.dt_sai_ent, gt_row_Nota_Fiscal.dt_emiss), 'dd/mm/rrrr')||')';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_VALIDACAO
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      end if;
      --
   end if;
   --
   vn_fase := 4;
   --
   -- Válida informação do Valor da Duplicata
   if nvl(est_row_NFCobr_Dup.vl_dup,0) < 0 then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := 'Valor da Parcela da Duplicata não pode ser negativo ('||est_row_NFCobr_Dup.vl_dup||').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 4.2;
   -- Se o valor for zero, atribui nulo
   if est_row_NFCobr_Dup.vl_dup = 0 then
      est_row_NFCobr_Dup.vl_dup := null;
   end if;
   --
   vn_fase := 99;
   --
   -- Se não existe registro de log e o Tipo de Validação é 1 (válida e insere)
   -- então registra a Duplicata da Nota Fiscal
   -- Verifica se log generico tem erro ou só aviso/informação
   if nvl(est_log_generico_nf.count,0) > 0 and
      fkg_ver_erro_log_generico_nfs(en_nota_fiscal_id => en_notafiscal_id ) = 1  then
      --
      vn_fase := 99.1;
      --
      update nota_fiscal set dm_st_proc = 10
       where id = en_notafiscal_id;
      --
   end if;
   --
   vn_fase := 99.2;
   --
   if nvl(est_row_NFCobr_Dup.nfcobr_id,0) > 0
      and trim( pk_csf.fkg_converte ( est_row_NFCobr_Dup.nro_parc ) ) is not null
      and est_row_NFCobr_Dup.dt_vencto is not null
      then
      --
      if nvl(gn_tipo_integr,0) = 1 then
         --
         vn_fase := 99.3;
         --
         select nfcobrdup_seq.nextval
           into est_row_NFCobr_Dup.id
           from dual;
         --
         vn_fase := 99.4;
         --
         insert into NFCobr_Dup ( id
                                , nfcobr_id
                                , nro_parc
                                , dt_vencto
                                , vl_dup )
                         values ( est_row_NFCobr_Dup.id
                                , est_row_NFCobr_Dup.nfcobr_id
                                , trim( pk_csf.fkg_converte ( est_row_NFCobr_Dup.nro_parc ) )
                                , est_row_NFCobr_Dup.dt_vencto
                                , est_row_NFCobr_Dup.vl_dup );
      --
      else
         --
         vn_fase := 99.5;
         --
         update NFCobr_Dup set nro_parc   = trim( pk_csf.fkg_converte ( est_row_NFCobr_Dup.nro_parc ) )
                             , dt_vencto  = est_row_NFCobr_Dup.dt_vencto
                             , vl_dup     = est_row_NFCobr_Dup.vl_dup
          where id = est_row_NFCobr_Dup.id;
         --
      end if;
      --
   end if;
   --
   <<sair_integr>>
   null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_integr_NFCobr_Dup fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_NFCobr_Dup;

-------------------------------------------------------------------------------------------------------

-- Integra informações da cobrança da Nota Fiscal
procedure pkb_integr_Nota_Fiscal_Cobr ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                      , est_row_Nota_Fiscal_Cobr  in out nocopy  Nota_Fiscal_Cobr%rowtype )
is
   --
   vn_fase              number := 0;
   vn_loggenericonf_id  log_generico_nf.id%TYPE;
   vn_nfcobr_id         nota_fiscal_cobr.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_nfe_nao_integrar ( en_notafiscal_id => est_row_Nota_Fiscal_Cobr.notafiscal_id ) then
      --
      goto sair_integr;
      --
   end if;
   --
   vn_fase := 1.1;
   --
   if nvl(est_row_Nota_Fiscal_Cobr.notafiscal_id,0) = 0
      and nvl(est_log_generico_nf.count,0) = 0 then
      --
      vn_fase := 1.2;
      --
      gv_mensagem_log := 'Não informada a Nota Fiscal para relacionar aos Dados da Cobrança.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;

   vn_fase := 2;

   -- Válida o emitente do título
   if est_row_Nota_Fiscal_Cobr.dm_ind_emit not in (0, 1) then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := '"Indicador do emitente de Dados da Cobrança da Nota Fiscal" ('||est_row_Nota_Fiscal_Cobr.dm_ind_emit||') está inválido.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;

   vn_fase := 3;

   -- Válida o tipo de título
   if est_row_Nota_Fiscal_Cobr.dm_ind_tit not in ('00', '01', '02', '03', '99') then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := '"Tipo de Título de Dados da Cobrança da Nota Fiscal" ('||est_row_Nota_Fiscal_Cobr.dm_ind_tit||') está inválido.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 4;
   --
   -- Válida informações do Valor Original da Fatura
   if nvl(est_row_Nota_Fiscal_Cobr.vl_orig,0) < 0 then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := '"Valor Original da Fatura da Cobrança da Nota Fiscal" não pode ser negativo ('||est_row_Nota_Fiscal_Cobr.vl_orig||').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   else
      -- se for zero ocorre erro de XML
      vn_fase := 4.2;
      --
      if est_row_Nota_Fiscal_Cobr.vl_orig = 0 then
         est_row_Nota_Fiscal_Cobr.vl_orig := null;
      end if;
      --
   end if;
   --
   vn_fase := 5;
   --
   -- Válida informações do Valor do Desconto da Fatura
   if nvl(est_row_Nota_Fiscal_Cobr.vl_desc,0) < 0 then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := '"Valor do Desconto da Fatura da Cobrança da Nota Fiscal" não pode ser negativo ('||est_row_Nota_Fiscal_Cobr.vl_desc||').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   else
      -- se for zero ocorre erro de XML
      vn_fase := 5.2;
      if est_row_Nota_Fiscal_Cobr.vl_desc = 0 then
         --
         est_row_Nota_Fiscal_Cobr.vl_desc := null;
         --
      end if;
      --
   end if;
   --
   vn_fase := 6;
   --
   -- Válida informações do Valor Líquido da Fatura
   if nvl(est_row_Nota_Fiscal_Cobr.vl_liq,0) < 0 then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := '"Valor Líquido da Fatura da Cobrança da Nota Fiscal" não pode ser negativo ('||est_row_Nota_Fiscal_Cobr.vl_liq||').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   else
      -- se for zero ocorre erro de XML
      vn_fase := 6.2;
      --
      if est_row_Nota_Fiscal_Cobr.vl_liq = 0 then
         est_row_Nota_Fiscal_Cobr.vl_liq := null;
      end if;
      --
   end if;
   --
   vn_fase := 7;
   --
   if trim( pk_csf.fkg_converte ( est_row_Nota_Fiscal_Cobr.descr_tit ) ) is null
      and est_row_Nota_Fiscal_Cobr.dm_ind_tit = '99' then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := '"Descrição complementar do título de crédito" torna-se obrigatória quando o Tipo de Título é igual a 99-Outros.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 99;
   --
   -- Se não existe registro de Log e o Tipo de Integração é 1 (válida e insere)
   -- então registra a informação da Fatura da Nota Fiscal
   if nvl(est_log_generico_nf.count,0) > 0 and
      fkg_ver_erro_log_generico_nfs( en_nota_fiscal_id => est_row_Nota_Fiscal_Cobr.notafiscal_id ) = 1  then
      --
      vn_fase := 99.1;
      --
      update nota_fiscal set dm_st_proc = 10
       where id = est_row_Nota_Fiscal_Cobr.notafiscal_id;
      --
   end if;
   --
   vn_fase := 99.2;
   --
   est_row_Nota_Fiscal_Cobr.nro_fat := trim( pk_csf.fkg_converte ( est_row_Nota_Fiscal_Cobr.nro_fat ) );
   est_row_Nota_Fiscal_Cobr.descr_tit := trim( pk_csf.fkg_converte ( est_row_Nota_Fiscal_Cobr.descr_tit ) );
   --
   vn_fase := 99.3;
   --
   if nvl(est_row_Nota_Fiscal_Cobr.notafiscal_id,0) > 0
      and est_row_Nota_Fiscal_Cobr.dm_ind_emit      in (0, 1)
      and est_row_Nota_Fiscal_Cobr.dm_ind_tit       is not null
      and est_row_Nota_Fiscal_Cobr.nro_fat          is not null then
      --
      vn_fase := 99.4;
      -- Verifica se já existe o registro
      begin
         select id
           into vn_nfcobr_id
           from Nota_Fiscal_Cobr
          where notafiscal_id = est_row_Nota_Fiscal_Cobr.notafiscal_id
            and nro_fat       = trim( pk_csf.fkg_converte ( est_row_Nota_Fiscal_Cobr.nro_fat ) );
      exception
         when too_many_rows then
            vn_nfcobr_id := 1;
         when others then
            vn_nfcobr_id := null;
      end;
      --
      if nvl(gn_tipo_integr,0) = 0 or nvl(vn_nfcobr_id,0) > 0 then
         --
         vn_fase := 99.5;
         --
         update Nota_Fiscal_Cobr set dm_ind_emit  = est_row_Nota_Fiscal_Cobr.dm_ind_emit
                                   , dm_ind_tit   = est_row_Nota_Fiscal_Cobr.dm_ind_tit
                                   , nro_fat      = est_row_Nota_Fiscal_Cobr.nro_fat
                                   , vl_orig      = est_row_Nota_Fiscal_Cobr.vl_orig
                                   , vl_desc      = est_row_Nota_Fiscal_Cobr.vl_desc
                                   , vl_liq       = est_row_Nota_Fiscal_Cobr.vl_liq
                                   , descr_tit    = est_row_Nota_Fiscal_Cobr.descr_tit
          where id = est_row_Nota_Fiscal_Cobr.id;
         --
      elsif nvl(gn_tipo_integr,0) = 1 then
         --
         vn_fase := 99.4;
         --
         select nfcobr_seq.nextval
           into est_row_Nota_Fiscal_Cobr.id
           from dual;
         --
         vn_fase := 99.5;
         --
         insert into Nota_Fiscal_Cobr ( id
                                      , notafiscal_id
                                      , dm_ind_emit
                                      , dm_ind_tit
                                      , nro_fat
                                      , vl_orig
                                      , vl_desc
                                      , vl_liq
                                      , descr_tit )
                               values ( est_row_Nota_Fiscal_Cobr.id
                                      , est_row_Nota_Fiscal_Cobr.notafiscal_id
                                      , est_row_Nota_Fiscal_Cobr.dm_ind_emit
                                      , est_row_Nota_Fiscal_Cobr.dm_ind_tit
                                      , trim( pk_csf.fkg_converte ( est_row_Nota_Fiscal_Cobr.nro_fat ) )
                                      , est_row_Nota_Fiscal_Cobr.vl_orig
                                      , est_row_Nota_Fiscal_Cobr.vl_desc
                                      , est_row_Nota_Fiscal_Cobr.vl_liq
                                      , trim( pk_csf.fkg_converte ( est_row_Nota_Fiscal_Cobr.descr_tit ) )
                                      );
      --
      end if;
      --
   end if;
   --
   <<sair_integr>>
   null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_integr_Nota_Fiscal_Cobr fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_Nota_Fiscal_Cobr;

-------------------------------------------------------------------------------------------------------

-- Procedimento de registro da pessoa destinatário da Nota Fiscal

procedure pkb_reg_pessoa_dest_nf ( est_log_generico_nf         in  out nocopy  dbms_sql.number_table
                                 , et_row_Nota_Fiscal_Dest  in  Nota_Fiscal_Dest%rowtype
                                 , ev_cod_part              in  pessoa.cod_part%type
                                 , en_multorg_id            in  mult_org.id%type )
is
   --
   vt_log_generico   dbms_sql.number_table;
   vn_dm_atual_part  empresa.dm_atual_part%type;
   vn_fase           number := 0;
   vv_cod_part       pessoa.cod_part%type;
   vn_dm_tipo_incl   pessoa.dm_tipo_incl%type;
   --
begin
   --
   vn_fase := 1;
   --
   vt_log_generico.delete;
   -- verifica se a empresa que emitiu a nota atualiza o cadastro do participante
   -- somente para notas de emissão própria
   begin
      --
      select e.dm_atual_part
        into vn_dm_atual_part
        from nota_fiscal  nf
           , empresa      e
       where nf.id           = et_row_Nota_Fiscal_Dest.notafiscal_id
         and nf.dm_ind_emit  = 0 -- Emissão própria
         and e.id            = nf.empresa_id;
      --
   exception
      when others then
         vn_dm_atual_part := 0;
   end;
   --
   vn_fase := 2;
   --
   if nvl(vn_dm_atual_part,0) = 1 then
      --
      vn_fase := 3;
      --
      vv_cod_part := trim(ev_cod_part);
      --
      if trim(vv_cod_part) is null then
         --
         vv_cod_part := trim(et_row_Nota_Fiscal_Dest.cnpj);
         --
         if trim(vv_cod_part) is null then
            --
            vv_cod_part := trim(et_row_Nota_Fiscal_Dest.cpf);
            --
         end if;
         --
      end if;
      --
      if trim(vv_cod_part) is not null then
         --
         vn_fase := 4;
         --
         pk_csf_api_cad.gt_row_pessoa := null;
         --
         pk_csf_api_cad.gt_row_pessoa.dm_tipo_incl  := 1; -- Externo, cadastrado na importação dos dados
         pk_csf_api_cad.gt_row_pessoa.cod_part      := vv_cod_part;
         pk_csf_api_cad.gt_row_pessoa.nome          := substr(et_row_Nota_Fiscal_Dest.nome, 1, 60);
         pk_csf_api_cad.gt_row_pessoa.lograd        := substr(et_row_Nota_Fiscal_Dest.lograd, 1, 60);
         --
         vn_fase := 4.1;
         --
         pk_csf_api_cad.gt_row_pessoa.nro           := substr(et_row_Nota_Fiscal_Dest.nro, 1, 10);
         pk_csf_api_cad.gt_row_pessoa.cx_postal     := null;
         pk_csf_api_cad.gt_row_pessoa.compl         := et_row_Nota_Fiscal_Dest.compl;
         pk_csf_api_cad.gt_row_pessoa.bairro        := et_row_Nota_Fiscal_Dest.bairro;
         --
         vn_fase := 4.2;
         --
         if nvl(et_row_Nota_Fiscal_Dest.cidade_ibge,0) > 0 then
            pk_csf_api_cad.gt_row_pessoa.cidade_id     := pk_csf.fkg_Cidade_ibge_id ( ev_ibge_cidade => et_row_Nota_Fiscal_Dest.cidade_ibge );
         else
            pk_csf_api_cad.gt_row_pessoa.cidade_id     := pk_csf.fkg_Cidade_ibge_id ( ev_ibge_cidade => 9999999 );
         end if;
         --
         vn_fase := 4.3;
         --
         pk_csf_api_cad.gt_row_pessoa.cep           := et_row_Nota_Fiscal_Dest.cep;
         pk_csf_api_cad.gt_row_pessoa.fone          := et_row_Nota_Fiscal_Dest.fone;    --substr(et_row_Nota_Fiscal_Dest.fone, 1, 10);
         pk_csf_api_cad.gt_row_pessoa.fax           := null;
         pk_csf_api_cad.gt_row_pessoa.email         := et_row_Nota_Fiscal_Dest.email;
         pk_csf_api_cad.gt_row_pessoa.pais_id       := pk_csf.fkg_Pais_siscomex_id ( ev_cod_siscomex => et_row_Nota_Fiscal_Dest.cod_pais );
         pk_csf_api_cad.gt_row_pessoa.multorg_id    := en_multorg_id;
         --
         vn_fase := 5;
         --
         if trim(et_row_Nota_Fiscal_Dest.cnpj) is null
            and trim(et_row_Nota_Fiscal_Dest.cpf) is null then
            --
            pk_csf_api_cad.gt_row_pessoa.dm_tipo_pessoa := 2; -- EXTERIOR
            --
         elsif trim(et_row_Nota_Fiscal_Dest.cnpj) is not null then
            --
            pk_csf_api_cad.gt_row_pessoa.dm_tipo_pessoa := 1; -- JURIDICA
            --
         elsif trim(et_row_Nota_Fiscal_Dest.cpf) is not null then
            --
            pk_csf_api_cad.gt_row_pessoa.dm_tipo_pessoa := 0; -- FÍSICA
            --
         end if;
         --
         vn_fase := 6;
         --
         -- Procura pelo CPF/CNPJ
         if nvl(pk_csf_api_cad.gt_row_pessoa.id,0) <= 0 then
            -- Verifica se existe o participante no Compliance NFe (procura pelo Código do participante e se não achar, pelo CPF/CNPJ)
            pk_csf_api_cad.gt_row_pessoa.id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id => en_multorg_id
                                                                             , ev_cod_part   => vv_cod_part );
            --
            if nvl(pk_csf_api_cad.gt_row_pessoa.id,0) <= 0 then
               --
               if trim(et_row_Nota_Fiscal_Dest.cnpj) is not null then
                  vn_fase := 6.1;
                  pk_csf_api_cad.gt_row_pessoa.id := pk_csf.fkg_pessoa_id_cpf_cnpj_uf ( en_multorg_id => en_multorg_id
                                                                                      , en_cpf_cnpj   => trim(et_row_nota_fiscal_dest.cnpj)
                                                                                      , ev_uf         => trim(et_row_nota_fiscal_dest.uf)
                                                                                      );
               elsif trim(et_row_Nota_Fiscal_Dest.cpf) is not null then
                     vn_fase := 6.2;
                     pk_csf_api_cad.gt_row_pessoa.id := pk_csf.fkg_pessoa_id_cpf_cnpj_uf ( en_multorg_id => en_multorg_id
                                                                                         , en_cpf_cnpj   => trim(et_row_nota_fiscal_dest.cpf)
                                                                                         , ev_uf         => trim(et_row_nota_fiscal_dest.uf)
                                                                                         );
               end if;
               --
            end if;
            --
         end if;
         --
         if nvl(pk_csf_api_cad.gt_row_pessoa.id,0) > 0 then
            --
            vn_dm_tipo_incl := pk_csf.fkg_pessoa_id_dm_tipo_incl ( en_pessoa_id => pk_csf_api_cad.gt_row_pessoa.id );
            --
         else
            vn_dm_tipo_incl := 1;
         end if;
         --
         vn_fase := 7;
         -- Somente atualiza pessoas incluidas por meio de integração
         if vn_dm_tipo_incl = 1 then
            -- Valida se o participante não está cadastrado como empresa
            if pk_csf.fkg_valida_part_empresa ( en_multorg_id => pk_csf_api_cad.gt_row_pessoa.multorg_id
                                              , ev_cod_part   => pk_csf_api_cad.gt_row_pessoa.cod_part ) = FALSE then
               -- chama procedimento de resgitro da pessoa
               pk_csf_api_cad.pkb_ins_atual_pessoa ( est_log_generico  => vt_log_generico
                                                   , est_pessoa        => pk_csf_api_cad.gt_row_pessoa
                                                   , en_empresa_id     => gt_row_nota_fiscal.empresa_id
                                                   );
               --
            end if;
            --
            vn_fase := 8;
            --
            if nvl(pk_csf_api_cad.gt_row_pessoa.id,0) > 0 then
               --
               vn_fase := 9;
               -- Faz o Registro de pessoa física/jurídica
               if pk_csf_api_cad.gt_row_pessoa.dm_tipo_pessoa = 0 then -- Física
                  --
                  vn_fase := 10;
                  --
                  pk_csf_api_cad.gt_row_fisica := null;
                  --
                  pk_csf_api_cad.gt_row_fisica.pessoa_id  := pk_csf_api_cad.gt_row_pessoa.id;
                  --
                  vn_fase := 10.1;
                  --
                  begin
                     --
                     pk_csf_api_cad.gt_row_fisica.num_cpf    := to_number(substr(et_row_Nota_Fiscal_Dest.cpf, 1, 9));
                     pk_csf_api_cad.gt_row_fisica.dig_cpf    := to_number(substr(et_row_Nota_Fiscal_Dest.cpf, 10, 2));
                     --
                  exception
                     when others then
                        --
                        gv_mensagem_log := 'Erro inconsistência no CPF do destinatário da NFe (fase: '||vn_fase||' - pkb_reg_pessoa_dest_nf): '||sqlerrm;
                        --
                        declare
                           vn_loggenericonf_id  log_generico_nf.id%TYPE;
                        begin
                           --
                           pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                            , ev_mensagem        => gv_cabec_log
                                            , ev_resumo          => gv_mensagem_log
                                            , en_tipo_log        => ERRO_DE_SISTEMA
                                            , en_referencia_id   => gn_referencia_id
                                            , ev_obj_referencia  => gv_obj_referencia );
                           --
                           -- Armazena o "loggenerico_id" na memória
                           pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                               , est_log_generico_nf  => est_log_generico_nf );
                           --
                           exception
                              when others then
                                 null;
                        end;
                        --
                  end;
                  --
                  vn_fase := 10.2;
                  --
                  pk_csf_api_cad.gt_row_fisica.rg := null;
                  --
                  pk_csf_api_cad.pkb_ins_atual_fisica ( est_log_generico => vt_log_generico
                                                      , est_fisica => pk_csf_api_cad.gt_row_fisica
                                                      , en_empresa_id     => gt_row_nota_fiscal.empresa_id
                                                      );
                  --
               elsif pk_csf_api_cad.gt_row_pessoa.dm_tipo_pessoa = 1 then -- Jurídica
                  --
                  vn_fase := 11;
                  --
                  pk_csf_api_cad.gt_row_juridica := null;
                  --
                  pk_csf_api_cad.gt_row_juridica.pessoa_id     := pk_csf_api_cad.gt_row_pessoa.id;
                  --
                  vn_fase := 11.1;
                  --
                  begin
                     --
                     pk_csf_api_cad.gt_row_juridica.num_cnpj      := to_number(substr(et_row_Nota_Fiscal_Dest.cnpj, 1, 8));
                     pk_csf_api_cad.gt_row_juridica.num_filial    := to_number(substr(et_row_Nota_Fiscal_Dest.cnpj, 9, 4));
                     pk_csf_api_cad.gt_row_juridica.dig_cnpj      := to_number(substr(et_row_Nota_Fiscal_Dest.cnpj, 13, 2));
                     --
                  exception
                     when others then
                        --
                        gv_mensagem_log := 'Erro inconsistência no CNPJ do destinatário da NFe (fase: '||vn_fase||' - pkb_reg_pessoa_dest_nf): '||sqlerrm;
                        --
                        declare
                           vn_loggenericonf_id  log_generico_nf.id%TYPE;
                        begin
                           --
                           pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                            , ev_mensagem        => gv_cabec_log
                                            , ev_resumo          => gv_mensagem_log
                                            , en_tipo_log        => ERRO_DE_SISTEMA
                                            , en_referencia_id   => gn_referencia_id
                                            , ev_obj_referencia  => gv_obj_referencia );
                           --
                           -- Armazena o "loggenerico_id" na memória
                           pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                               , est_log_generico_nf  => est_log_generico_nf );
                           --
                           exception
                              when others then
                                 null;
                         end;
                        --
                   end;
                  --
                  vn_fase := 11.2;
                  --
                  pk_csf_api_cad.gt_row_juridica.ie            := et_row_Nota_Fiscal_Dest.ie;
                  pk_csf_api_cad.gt_row_juridica.iest          := null;
                  pk_csf_api_cad.gt_row_juridica.im            := et_row_Nota_Fiscal_Dest.im;
                  pk_csf_api_cad.gt_row_juridica.cnae          := null;
                  pk_csf_api_cad.gt_row_juridica.suframa       := et_row_Nota_Fiscal_Dest.suframa;
                  --
                  vn_fase := 11.3;
                  --
                  pk_csf_api_cad.pkb_ins_atual_juridica ( est_log_generico => vt_log_generico
                                                        , est_juridica => pk_csf_api_cad.gt_row_juridica
                                                        , en_empresa_id     => gt_row_nota_fiscal.empresa_id
                                                        );
                  --
               end if;
               --
            end if;
            --
         end if;
         --
         vn_fase := 12;
         --
         if nvl(pk_csf_api_cad.gt_row_pessoa.id,0) > 0 then
            --
            update nota_fiscal
               set pessoa_id = pk_csf_api_cad.gt_row_pessoa.id
             where id                = et_row_Nota_Fiscal_Dest.notafiscal_id
               and nvl(pessoa_id,0) <= 0;
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
      gv_mensagem_log := 'Erro na pkb_reg_pessoa_dest_nf fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_reg_pessoa_dest_nf;

-------------------------------------------------------------------------------------------------------

-- Integra as informações do Destinatário da Nota Fiscal

--| A API de integração do destinatário da NFe, irá verificar se houve algum erro de integração com os dados informados
--| do destinatário, caso exista erro, verifica se a empresa "Utiliza o Endereço de Faturamento do Destinatário para emissão de NFe",
--| se utiliza, o endereço errado será substituido pelo registrado no Compliance NFe (Cadastro de Pessoas)

procedure pkb_integr_Nota_Fiscal_Dest ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                      , est_row_Nota_Fiscal_Dest  in out nocopy  Nota_Fiscal_Dest%rowtype
                                      , ev_cod_part               in             pessoa.cod_part%type
                                      , en_multorg_id             in             mult_org.id%type 
                                      , en_cid                    in number )
is
   --
   vn_fase                number := 0;
   vn_loggenericonf_id    log_generico_nf.id%TYPE;
   vn_dm_util_end_fat_nfe empresa.dm_util_end_fat_nfe%type := 0;
   vn_indice              number := 0;
   vn_pessoa_id           Pessoa.id%type;
   vt_log_generico        dbms_sql.number_table;
   vn_atualiza_erro       number := 1; -- 0-Não; 1-Sim
   vb_integr_edi          boolean := false;
   vn_dm_email_nfse       empresa.dm_email_nfse%type := 0;
   vn_dm_valida_cep_nfse  empresa.dm_valida_cep_nfse%type;
   vt_cidade              cidade%rowtype;
   vn_dm_ind_emit         nota_fiscal.dm_ind_emit%type;
   vv_cod_mod             mod_fiscal.cod_mod%type;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_nfe_nao_integrar ( en_notafiscal_id => est_row_Nota_Fiscal_Dest.notafiscal_id ) then
      --
      goto sair_integr;
      --
   end if;
   --
   vt_log_generico.delete;
   --
   vn_fase := 1.1;
   --
   -- Verifica se a nota fiscal não foi informada
   if nvl(est_row_Nota_Fiscal_Dest.notafiscal_id,0) = 0
      and nvl(est_log_generico_nf.count,0) = 0 then
      --
      vn_fase := 1.2;
      --
      gv_mensagem_log := 'Não informado a Nota Fiscal para relacionar ao Destinatário.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => vt_log_generico );
      --
   end if;
   --
   vn_fase := 2;
   --
   -- Válida se o campo nome tem menos que 2 caracteres
   if nvl(length( trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.nome)) ),0) < 2 then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := '"Nome do destinatário da Nota Fiscal" deve ter no mínimo dois caracteres ('||est_row_Nota_Fiscal_Dest.nome||').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => vt_log_generico );
      --
   end if;

   vn_fase := 3;
   -- Válida informação do número do endereço do emitente
   if trim( pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.nro) ) is null then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := '"Número do endereço" destinatário da Nota Fiscal não informado.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => vt_log_generico );
      --
   end if;

   vn_fase := 4;

   -- Válida se o campo logradouro tem menos que 2 caracteres
   if nvl(length( trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.lograd)) ),0) < 2 then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := '"Logradouro do destinatário da Nota Fiscal" deve ter no mínimo dois caracteres ('||est_row_Nota_Fiscal_Dest.lograd||').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => vt_log_generico );
      --
   end if;

   vn_fase := 5;

   -- Válida se o campo bairro tem menos que 2 caracteres
   if nvl(length( trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.bairro)) ),0) < 2 then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := '"Bairro do destinatário da Nota Fiscal" deve ter no mínimo dois caracteres ('||est_row_Nota_Fiscal_Dest.bairro||').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => vt_log_generico );
      --
   end if;

   vn_fase := 6;

   -- Válida se o campo cidade tem menos que 2 caracteres
   if nvl(length( trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.cidade)) ),0) < 2 then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := '"Cidade do destinatário da Nota Fiscal" deve ter no mínimo dois caracteres ('||est_row_Nota_Fiscal_Dest.cidade||').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => vt_log_generico );
      --
   end if;

   vn_fase := 7;

   -- verifica se a UF é inválida
   if pk_csf.fkg_uf_valida ( ev_sigla_estado => est_row_Nota_Fiscal_Dest.uf ) = false then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := '"Sigla da UF do destinatário da Nota Fiscal" inválida ('||est_row_Nota_Fiscal_Dest.uf||').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => vt_log_generico );
      --
   end if;

   vn_fase := 8;
   -- Se o campo UF = 'EX' atribui Exterior para cidade
   if est_row_Nota_Fiscal_Dest.uf = 'EX' then
      --
      vn_fase := 8.1;
      --
      est_row_Nota_Fiscal_Dest.cidade := 'EXTERIOR';
      --
      if est_row_Nota_Fiscal_Dest.cidade_ibge is null then
         est_row_Nota_Fiscal_Dest.cidade_ibge := 9999999;
      end if;
      --
   end if;
   --
   vn_fase := 8.2;
   --
   est_row_Nota_Fiscal_Dest.cidade_ibge := nvl(est_row_Nota_Fiscal_Dest.cidade_ibge,0);
   --
   vn_fase := 8.3;
   --
   /*if en_cid = 3304557 then
     est_row_Nota_Fiscal_Dest.cidade_ibge := 9999999;  
   end if;*/   
   --
   vn_fase := 9;
   -- Válida o campo cidade_ibge
   if est_row_Nota_Fiscal_Dest.cidade_ibge <> 9999999 then
      --
      vn_fase := 9.1;
      --
      if pk_csf.fkg_ibge_cidade ( ev_ibge_cidade => est_row_Nota_Fiscal_Dest.cidade_ibge ) = false then
         --
         vn_fase := 9.2;
         --
         gv_mensagem_log := '"Código IBGE da cidade do destinatário da Nota Fiscal" inválido ('||est_row_Nota_Fiscal_Dest.cidade_ibge||').';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_VALIDACAO
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => vt_log_generico );
         --
      end if;
      --
      vn_fase := 9.3;
      -- Valida se o IBGE da cidade pertence a sigla da UF
      if pk_csf.fkg_ibge_cidade_por_sigla_uf ( en_ibge_cidade   => est_row_Nota_Fiscal_Dest.cidade_ibge
                                             , ev_sigla_estado  => est_row_Nota_Fiscal_Dest.uf
                                             ) = false then
         --
         vn_fase := 9.4;
         --
         gv_mensagem_log := '"Código IBGE da cidade do destinatário da Nota Fiscal" ('||
                            est_row_Nota_Fiscal_Dest.cidade_ibge||') não pertence a sigla do estado ('||est_row_Nota_Fiscal_Dest.uf||')';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_VALIDACAO
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => vt_log_generico );
         --
      end if;
      --
      vn_fase := 9.5;
      -- Busca o nome da cidade conforme IBGE
      est_row_Nota_Fiscal_Dest.cidade := pk_csf.fkg_descr_cidade_conf_ibge ( ev_ibge_cidade => est_row_Nota_Fiscal_Dest.cidade_ibge );
      --
      if trim(est_row_Nota_Fiscal_Dest.cidade) is null then
         est_row_Nota_Fiscal_Dest.cidade := 'NI';
      end if;
      --
      vn_fase := 9.6;
      -- Valida o CEP
      if nvl(est_row_Nota_Fiscal_Dest.cep,0) <= 0 then
         --
         vn_fase := 9.61;
         --
         gv_mensagem_log := '"CEP" não pode ser '|| est_row_Nota_Fiscal_Dest.cep||' para a cidade informada!';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_VALIDACAO
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => vt_log_generico );
         --
      end if;
      --
      vn_fase := 9.7;
      -- 
      vn_dm_valida_cep_nfse := pk_csf_nfs.fkg_empresa_valida_cep_nfs ( en_empresa_id => gn_empresa_id );
      --
      if nvl(vn_dm_valida_cep_nfse,0) = 1 then -- Sim Valida CEP
         --
         vn_fase := 9.71;
         --
         begin
            --
            select * into vt_cidade
              from cidade
             where ibge_cidade = est_row_Nota_Fiscal_Dest.cidade_ibge;
            --
         exception
            when others then
               vt_cidade := null;
         end;
         --
         vn_fase := 9.72;
         --
         if nvl(vt_cidade.id,0) > 0 then
            --
            vn_fase := 9.721;
            --
            if nvl(vt_cidade.cep_inicial,0) > 0 and nvl(vt_cidade.cep_final,0) > 0 then
               --
               if nvl(est_row_Nota_Fiscal_Dest.cep,0) not between nvl(vt_cidade.cep_inicial,0) and nvl(vt_cidade.cep_final,0) then
                  --
                  gv_mensagem_log := '"CEP" informado (' || nvl(est_row_Nota_Fiscal_Dest.cep,0) 
                                     || ') não pertence a cidade de ' || vt_cidade.descr || ' com CEP de ' 
                                     || nvl(vt_cidade.cep_inicial,0) || 'até ' || nvl(vt_cidade.cep_final,0) || '!';
                  --
                  vn_loggenericonf_id := null;
                  --
                  pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                      , ev_mensagem        => gv_cabec_log
                                      , ev_resumo          => gv_mensagem_log
                                      , en_tipo_log        => ERRO_DE_VALIDACAO
                                      , en_referencia_id   => gn_referencia_id
                                      , ev_obj_referencia  => gv_obj_referencia );
                  --
                  -- Armazena o "loggenerico_id" na memória
                  pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                         , est_log_generico_nf  => vt_log_generico );
                  --
               end if;
               --
            end if;
            --
         end if;
         --
      end if;
      --
   else -- est_row_Nota_Fiscal_Dest.cidade_ibge = 9999999
      --
      vn_fase := 9.8;
      --
      if est_row_nota_fiscal_dest.uf <> 'EX' then
         --
         vn_fase := 9.9;
         --
         begin
            select nf.dm_ind_emit
                 , mf.cod_mod
              into vn_dm_ind_emit
                 , vv_cod_mod
              from nota_fiscal nf
                 , mod_fiscal  mf
             where nf.id = est_row_nota_fiscal_dest.notafiscal_id
               and mf.id = nf.modfiscal_id;
         exception
            when others then
               vn_dm_ind_emit := 0; -- 0-emissão própria
               vv_cod_mod     := '99'; -- nota fiscal de serviço
         end;
         --
         vn_fase := 9.10;
         --
         if vn_dm_ind_emit = 0 and -- 0-emissão própria
            vv_cod_mod = '99' then -- nota fiscal de serviço
            --
            gv_mensagem_log := 'Verificar o Código de IBGE 9999999 e a UF informada ('||est_row_nota_fiscal_dest.uf||'), pois esse código deverá ser '||
                               'utilizado quando for do Exterior.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                , ev_mensagem         => gv_cabec_log
                                , ev_resumo           => gv_mensagem_log
                                , en_tipo_log         => erro_de_validacao
                                , en_referencia_id    => gn_referencia_id
                                , ev_obj_referencia   => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                   , est_log_generico_nf => vt_log_generico );
            --
         end if;
         --
      end if;
      --
   end if;
   --
   vn_fase := 10;
   -- Se o código do país for nulo, atribui 1058-Brasil
   if nvl(est_row_Nota_Fiscal_Dest.cod_pais,0) <= 0 then
      --
      vn_fase := 10.1;
      est_row_Nota_Fiscal_Dest.cod_pais := 1058;
      --
   end if;
   --
   vn_fase := 10.2;
   --
   -- Válida o campo "cod_pais"
   if pk_csf.fkg_codpais_siscomex_valido ( en_cod_siscomex => est_row_Nota_Fiscal_Dest.cod_pais ) = false then
      --
      vn_fase := 10.3;
      --
      gv_mensagem_log := '"Código do país do destinatário da Nota Fiscal" inválido ('||est_row_Nota_Fiscal_Dest.cod_pais||').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => vt_log_generico );
      --
   end if;

   vn_fase := 10.4;
   --
   if trim( pk_csf.fkg_converte ( est_row_Nota_Fiscal_Dest.pais ) ) is null then
      --
      est_row_Nota_Fiscal_Dest.pais := 'Brasil';
      --
   end if;
   --
   vn_fase := 10.5;
   --
   -- Valida se o Parâmetro que habilita a emissão da Nota Fiscal Eletrônica para Exportação está setado para 0 = Não
   --
   if nvl(pk_csf.fkg_perm_exp_pais_id ( en_pais_id => pk_csf.fkg_Pais_siscomex_id( ev_cod_siscomex => est_row_Nota_Fiscal_Dest.cod_pais )), 1) = 0 then
      --
      vn_fase := 10.6;
      --
      gv_mensagem_log := 'O "Código do País do Destinatário" ('||est_row_Nota_Fiscal_Dest.cod_pais||') não permite exportação.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => vt_log_generico );
      --
   end if;
   --
   vn_fase := 11;

   -- Válida se a inscrição estadual de produtor de Minas Gerais
   if trim(est_row_Nota_Fiscal_Dest.ie) is not null and est_row_Nota_Fiscal_Dest.uf = 'MG' then
      --
      -- “PR9999” a “PR99999999” para destinatários produtores rurais de MG.
      vn_fase := 11.1;

      if upper(substr(trim(est_row_Nota_Fiscal_Dest.ie), 1, 2)) = 'PR'
         and to_number(substr(trim(est_row_Nota_Fiscal_Dest.ie), 3, 12)) not between 9999 and 99999999 then
         --
         gv_mensagem_log := '"Inscrição estadual de produtor para Minas Gerais do destinatário da Nota Fiscal"('||
                            trim(est_row_Nota_Fiscal_Dest.ie)||') está inválida.';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_VALIDACAO
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => vt_log_generico );
         --
      end if;

   end if;
   --
   vn_fase := 11.2;
   --
   if trim(est_row_Nota_Fiscal_Dest.cnpj) = '00000000000000' or trim(est_row_Nota_Fiscal_Dest.cnpj) = '0' then
      est_row_Nota_Fiscal_Dest.cnpj := null;
   end if;
   --
   vn_fase := 11.3;
   --
   if trim(est_row_Nota_Fiscal_Dest.cpf) = '00000000000' or trim(est_row_Nota_Fiscal_Dest.cpf) = '0' then
      est_row_Nota_Fiscal_Dest.cpf := null;
   end if;
   --
   -- Se o estado for EX, então limpa o CNPJ e IE
   if est_row_Nota_Fiscal_Dest.uf = 'EX' then
      --
      est_row_Nota_Fiscal_Dest.cnpj := null;
      est_row_Nota_Fiscal_Dest.cpf := null;
      est_row_Nota_Fiscal_Dest.ie := null;
      --
   end if;
   --
   vn_fase := 12;
   -- valida se CNPJ é numerico caso ele seja informado.
   if trim(est_row_Nota_Fiscal_Dest.cnpj) is not null
      and pk_csf.fkg_is_numerico ( ev_valor =>  est_row_Nota_Fiscal_Dest.cnpj ) = false then
      --
      vn_fase := 12.1;
      --
      gv_mensagem_log := 'O "CNPJ do destinatário da Nota Fiscal" ('||est_row_Nota_Fiscal_Dest.cnpj||
                         ') deve conter somente números considerando os zeros à esquerda.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => vt_log_generico );
      --
   end if;
   --
   vn_fase := 12.2;
   --
   -- Valida o CNPJ
   if trim(est_row_Nota_Fiscal_Dest.cnpj) is not null
      and pk_csf.fkg_is_numerico ( ev_valor =>  est_row_Nota_Fiscal_Dest.cnpj ) = true
      and nvl(pk_valida_docto.fkg_valida_cpf_cgc(ev_numero => est_row_Nota_Fiscal_Dest.cnpj), 0) = 0 then
      --
      vn_fase := 12.3;
      --
      gv_mensagem_log := 'O "CNPJ do destinatário da Nota Fiscal" ('||est_row_Nota_Fiscal_Dest.cnpj||') está inválido.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => vt_log_generico );
      --
   end if;
   --
   vn_fase := 13;
   -- valida se CNPJ é numerico caso ele seja informado.
   if trim(est_row_Nota_Fiscal_Dest.cpf) is not null
      and pk_csf.fkg_is_numerico ( ev_valor =>  est_row_Nota_Fiscal_Dest.cpf ) = false then
      --
      vn_fase := 13.1;
      --
      gv_mensagem_log := 'O "CPF do destinatário da Nota Fiscal" ('||est_row_Nota_Fiscal_Dest.cpf||
                         ') deve conter somente números considerando os zeros à esquerda.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => vt_log_generico );
      --
   end if;
   --
   vn_fase := 13.2;
   --
   -- Valida o CPF
   if trim(est_row_Nota_Fiscal_Dest.cpf) is not null
      and pk_csf.fkg_is_numerico ( ev_valor =>  est_row_Nota_Fiscal_Dest.cpf ) = true
      and nvl(pk_valida_docto.fkg_valida_cpf_cgc(ev_numero => est_row_Nota_Fiscal_Dest.cpf), 0) = 0 then
      --
      vn_fase := 13.3;
      --
      gv_mensagem_log := 'O "CPF do destinatário da Nota Fiscal" ('||est_row_Nota_Fiscal_Dest.cpf||') está inválido.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => vt_log_generico );
      --
   end if;
   --
   vn_fase := 14;
   --
   -- Valida Inscrição Estadual
   if trim(est_row_Nota_Fiscal_Dest.ie) is not null
      and trim(est_row_Nota_Fiscal_Dest.uf) is not null
      and nvl(pk_valida_docto.fkg_valida_ie( ev_inscr_est => est_row_Nota_Fiscal_Dest.ie
                                           , ev_estado    => est_row_Nota_Fiscal_Dest.uf ), 0) = 0 then
      --
      vn_fase := 14.1;
      --
      gv_mensagem_log := 'A "Inscrição Estadual do destinatário da Nota Fiscal" ('||est_row_Nota_Fiscal_Dest.ie||') está inválida.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => vt_log_generico );
      --
   end if;
   --
   vn_fase := 14.2;
   --
   if trim(est_row_Nota_Fiscal_Dest.ie) like 'ISENT%' then
      --
      est_row_Nota_Fiscal_Dest.ie := 'ISENTO';
      --
   end if;
   --
   vn_fase := 15;
   --
   if trim(est_row_Nota_Fiscal_Dest.cnpj) = 'EXTERIOR' then
      est_row_Nota_Fiscal_Dest.cnpj := null;
   elsif trim(est_row_Nota_Fiscal_Dest.cnpj) is not null then
         est_row_Nota_Fiscal_Dest.cnpj := lpad(trim(est_row_Nota_Fiscal_Dest.cnpj), 14, '0');
   end if;
   --
   vn_fase := 16;
   --
   if trim(est_row_Nota_Fiscal_Dest.cpf) = 'EXTERIOR' then
      est_row_Nota_Fiscal_Dest.cpf := null;
   elsif trim(est_row_Nota_Fiscal_Dest.cpf) is not null then
      est_row_Nota_Fiscal_Dest.cpf := lpad(trim(est_row_Nota_Fiscal_Dest.cpf), 11, '0');
   end if;
   --
   -- Se o destinatário é uma pessoa física o campo "IE" não pode ter os VALORES ISENTO ou ISENTA
   vn_fase := 17;
   --
   if trim(est_row_Nota_Fiscal_Dest.cpf) is not null
      and trim(upper(est_row_Nota_Fiscal_Dest.ie)) in ('ISENTO', 'ISENTA') then
      --
      est_row_Nota_Fiscal_Dest.ie := null;
      --
   end if;
   --
   vn_fase := 18.1;
   -- retira ponto e barra do telefone
   est_row_Nota_Fiscal_Dest.fone := replace(replace(replace(replace(replace(replace(est_row_Nota_Fiscal_Dest.fone, '.', ''), '-', ''), '*', ''), '(', ''), ')', ''), ' ', '');
   --
   vn_fase := 18.2;
   --
   if trim(est_row_Nota_Fiscal_Dest.fone) is not null
      and not length(trim(est_row_Nota_Fiscal_Dest.fone)) between 6 and 14
      then
      --
      vn_fase := 18.3;
      --
      gv_mensagem_log := 'O tamanho do "fone" ('||est_row_Nota_Fiscal_Dest.fone||') do destintário deve estar entre 6 a 14 caracteres.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => vt_log_generico );
      --
   end if;
   --
   vn_fase := 18.4;
   --
   if trim(est_row_Nota_Fiscal_Dest.fone) is not null
      and pk_csf.fkg_is_numerico ( ev_valor => est_row_Nota_Fiscal_Dest.fone ) = false then
      --
      vn_fase := 18.5;
      --
      gv_mensagem_log := 'O "Telefone do Destinatário" ('||est_row_Nota_Fiscal_Dest.fone||') deve ser composto de apenas números.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => vt_log_generico );
      --
   end if;
   --
   vn_fase := 18.6;
   --
   -- Valida se o cnpj e o cpf está sendo informado em operações nacionais
   if trim(est_row_Nota_Fiscal_Dest.uf) <> 'EX'
      and trim(est_row_Nota_Fiscal_Dest.cnpj) is null
      and trim(est_row_Nota_Fiscal_Dest.cpf) is null
      and gt_row_Nota_Fiscal.dm_ind_emit = 0 -- emissão própria
      then
      --
      vn_fase := 18.7;
      --
      gv_mensagem_log := 'O "CNPJ ou CPF do destinatário" é obrigatório em operações nacionais ('||est_row_Nota_Fiscal_Dest.uf||')';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => vt_log_generico );
      --
   end if;
   --
   vn_fase := 18.8;
   --
   begin
      --
      select dm_email_nfse
        into vn_dm_email_nfse
        from empresa
       where id = gt_row_Nota_Fiscal.empresa_id;
      --
   exception
      when others then
      vn_dm_email_nfse := 0;
   end;
   --
   vn_fase := 18.9;
   --
   if nvl(vn_dm_email_nfse,0) = 1
      and est_row_Nota_Fiscal_Dest.email is null
      and pk_csf.fkg_recup_dmindoper_nf_id(est_row_Nota_Fiscal_Dest.notafiscal_id) = 1 then
      --
      vn_fase := 18.11;
      --
      gv_mensagem_log := 'O e-mail do destinatário é obrigatório para nota fiscal de saida.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => vt_log_generico );
      --
   end if;
   --
   vn_fase := 19;
   -- Verifica se foram encontrados erros no cadastro do destinatário da NFe
   if nvl(vt_log_generico.count,0) > 0 then
      --
      vn_fase := 19.1;
      --
      vn_dm_util_end_fat_nfe := pk_csf.fkg_empresa_util_end_fat_nfe ( en_empresa_id => gt_row_Nota_Fiscal.empresa_id );
      --
      vn_fase := 19.2;
      --
      if nvl(vn_dm_util_end_fat_nfe,0) = 1 then -- Sim utiliza
         --
         vn_fase := 19.3;
         --
         if trim(est_row_Nota_Fiscal_Dest.cnpj) is not null then
            vn_fase := 19.4;
            vn_pessoa_id := pk_csf.fkg_Pessoa_id_cpf_cnpj ( en_multorg_id => en_multorg_id
                                                          , en_cpf_cnpj   => trim(est_row_Nota_Fiscal_Dest.cnpj) );
         elsif trim(est_row_Nota_Fiscal_Dest.cpf) is not null then
            vn_fase := 19.5;
            vn_pessoa_id := pk_csf.fkg_Pessoa_id_cpf_cnpj ( en_multorg_id => en_multorg_id
                                                          , en_cpf_cnpj   => trim(est_row_Nota_Fiscal_Dest.cpf) );
         end if;
         --
         vn_fase := 19.6;
         -- Se acho um cadastro de PESSOA INTERNA, então pega o por integração
         if nvl(vn_pessoa_id,0) <= 0 then
            --
            if trim(est_row_Nota_Fiscal_Dest.cnpj) is not null then
               vn_pessoa_id := pk_csf.fkg_Pessoa_id_cpf_cnpj ( en_multorg_id => en_multorg_id
                                                             , en_cpf_cnpj   => trim(est_row_Nota_Fiscal_Dest.cnpj) );
            elsif trim(est_row_Nota_Fiscal_Dest.cpf) is not null then
               vn_pessoa_id := pk_csf.fkg_Pessoa_id_cpf_cnpj ( en_multorg_id => en_multorg_id
                                                             , en_cpf_cnpj   => trim(est_row_Nota_Fiscal_Dest.cpf) );
            end if;
            --
         end if;
         --
         vn_fase := 19.7;
         -- Procura pelo CPF/CNPJ
         if nvl(vn_pessoa_id,0) <= 0 then
            -- Verifica se existe o participante no Compliance NFe (procura pelo Código do participante e se não achar, pelo CPF/CNPJ)
            vn_pessoa_id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id => en_multorg_id
                                                          , ev_cod_part   => ev_cod_part );
            --
         end if;
         --
         vn_fase := 19.8;
         -- Se exite participante, recupera os dados para o destinatário, caso os dados não estejam completos, registra ERRO DE VALIDACAO
         if nvl(vn_pessoa_id,0) <= 0 then
            --
            vn_fase := 19.9;
            --
            gv_mensagem_log := 'Não existe o registro do participante no Compliance, favor cadastrar e reenviar a Nota Fiscal.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                , est_log_generico_nf  => est_log_generico_nf );
            --
         else
            -- Recupera os dados e valida se os mesmos estão corretos
            -- busca somente se o tipo de inclusão for 0-Interno, que foi cadastrado na solução fiscal
            vn_fase := 19.10;
            --
            begin
               --
               select p.nome
                    , p.lograd
                    , p.nro
                    , p.compl
                    , p.bairro
                    , c.descr
                    , c.ibge_cidade
                    , e.sigla_estado
                    , p.cep
                    , pa.cod_siscomex
                    , pa.descr
                    , p.fone
                 into est_row_Nota_Fiscal_Dest.NOME
                    , est_row_Nota_Fiscal_Dest.LOGRAD
                    , est_row_Nota_Fiscal_Dest.NRO
                    , est_row_Nota_Fiscal_Dest.COMPL
                    , est_row_Nota_Fiscal_Dest.BAIRRO
                    , est_row_Nota_Fiscal_Dest.CIDADE
                    , est_row_Nota_Fiscal_Dest.CIDADE_IBGE
                    , est_row_Nota_Fiscal_Dest.UF
                    , est_row_Nota_Fiscal_Dest.CEP
                    , est_row_Nota_Fiscal_Dest.COD_PAIS
                    , est_row_Nota_Fiscal_Dest.PAIS
                    , est_row_Nota_Fiscal_Dest.FONE
                 from pessoa p
                    , cidade c
                    , estado e
                    , pais   pa
                where p.id  = vn_pessoa_id
                  and c.id  = p.cidade_id
                  and e.id  = c.estado_id
                  and pa.id = p.pais_id;
               --
            exception
               when others then
                  null;
            end;
            --
            vn_fase := 19.11;
            --
            if trim ( pk_csf.fkg_converte ( est_row_Nota_Fiscal_Dest.nome ) ) is null
               or trim ( pk_csf.fkg_converte ( est_row_Nota_Fiscal_Dest.lograd ) ) is null
               or trim ( pk_csf.fkg_converte ( est_row_Nota_Fiscal_Dest.nro ) ) is null
               or trim ( pk_csf.fkg_converte ( est_row_Nota_Fiscal_Dest.bairro ) ) is null
               or trim ( pk_csf.fkg_converte ( est_row_Nota_Fiscal_Dest.cidade ) ) is null
               or nvl(est_row_Nota_Fiscal_Dest.cidade_ibge, 0) <= 0
               or trim ( est_row_Nota_Fiscal_Dest.uf ) is null
               then
               --
               vn_fase := 19.12;
               --
               gv_mensagem_log := 'Participante com o cadastro incompleto no Compliance NFe! Por favor corrija e re-envie e Nota Fiscal.';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                , ev_mensagem        => gv_cabec_log
                                , ev_resumo          => gv_mensagem_log
                                , en_tipo_log        => ERRO_DE_VALIDACAO
                                , en_referencia_id   => gn_referencia_id
                                , ev_obj_referencia  => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                   , est_log_generico_nf  => est_log_generico_nf );
               --
            end if;
            --
         end if;
         --
      end if;
      --
      vn_fase := 20;
      --
      if nvl(vn_atualiza_erro,0) = 1 then -- Sim, atualiza os erros
         --
         vn_indice := nvl(vt_log_generico.first,0);
         --
         vn_fase := 20.1;
         --
         loop
            --
            vn_fase := 20.2;
            --
            if vn_indice = 0 then
               exit;
            end if;
            --
            vn_fase := 20.3;
            --
            vn_loggenericonf_id := vt_log_generico(vn_indice);
            --
            vn_fase := 20.4;
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                , est_log_generico_nf  => est_log_generico_nf );
            --
            vn_fase := 20.5;
            --
            if vn_indice = vt_log_generico.last then
               exit;
            else
               vn_indice := vt_log_generico.next(vn_indice);
            end if;
            --
         end loop;
         --
      end if;
      --
   end if;
   --
   vn_fase := 21;
   -- Bloqueio de pessoas com algum tipo de restrição
   --
   if trim(est_row_Nota_Fiscal_Dest.cnpj) is not null then
      --
      pk_csf_api.pkb_verif_pessoas_restricao ( est_log_generico_nf   => est_log_generico_nf
                                             , ev_cpf_cnpj        => trim(est_row_Nota_Fiscal_Dest.cnpj)
                                             , en_multorg_id      => en_multorg_id
                                             );
      --
   elsif trim(est_row_Nota_Fiscal_Dest.cpf) is not null then
      --
      pk_csf_api.pkb_verif_pessoas_restricao ( est_log_generico_nf   => est_log_generico_nf
                                             , ev_cpf_cnpj        => trim(est_row_Nota_Fiscal_Dest.cpf)
                                             , en_multorg_id      => en_multorg_id
                                             );
      --
   end if;
   --
   vn_fase := 22;
   --
   if trim(est_row_Nota_Fiscal_Dest.cnpj) is not null then
      -- trata a integração por EDI
      vb_integr_edi := pk_csf.fkg_integr_edi ( en_multorg_id => en_multorg_id
                                             , ev_cpf_cnpj   => trim(est_row_Nota_Fiscal_Dest.cnpj)
                                             , en_dm_tipo    => 1 -- NFe
                                             );
   elsif trim(est_row_Nota_Fiscal_Dest.cpf) is not null then
      -- trata a integração por EDI
      vb_integr_edi := pk_csf.fkg_integr_edi ( en_multorg_id => en_multorg_id
                                             , ev_cpf_cnpj   => trim(est_row_Nota_Fiscal_Dest.cpf)
                                             , en_dm_tipo    => 1 -- NFe
                                             );
   else
      vb_integr_edi := false;
   end if;
   --
   vn_fase := 23;
   --
   if vb_integr_edi then
      est_row_nota_fiscal_dest.dm_integr_edi := 0; -- Não integrado por EDI
   else
      est_row_nota_fiscal_dest.dm_integr_edi := 2; -- sem efeito
   end if;
   --
   vn_fase := 99;
   --
   -- Se não existe registro de Log e o Tipo de Integração é 1 (insere e válida)
   -- então registra a informação do Destinário da NF
   if nvl(est_log_generico_nf.count,0) > 0 and
      fkg_ver_erro_log_generico_nfs( en_nota_fiscal_id => est_row_Nota_Fiscal_Dest.notafiscal_id ) = 1 then
      --
      update nota_fiscal set dm_st_proc = 10
       where id = est_row_Nota_Fiscal_Dest.notafiscal_id;
      --
   end if;
   --
   est_row_Nota_Fiscal_Dest.nome         := trim ( replace( pk_csf.fkg_converte ( est_row_Nota_Fiscal_Dest.nome ), ':', '' ) );
   est_row_Nota_Fiscal_Dest.lograd       := trim ( replace( pk_csf.fkg_converte ( est_row_Nota_Fiscal_Dest.lograd ), ':', '' ) );
   est_row_Nota_Fiscal_Dest.nro          := trim ( replace( pk_csf.fkg_converte ( est_row_Nota_Fiscal_Dest.nro ), ':', '' ) );
   est_row_Nota_Fiscal_Dest.compl        := trim ( replace( pk_csf.fkg_converte ( est_row_Nota_Fiscal_Dest.compl ), ':', '' ) );
   est_row_Nota_Fiscal_Dest.bairro       := trim ( replace( pk_csf.fkg_converte ( est_row_Nota_Fiscal_Dest.bairro ), ':', '' ) );
   est_row_Nota_Fiscal_Dest.cidade       := trim ( replace( pk_csf.fkg_converte ( est_row_Nota_Fiscal_Dest.cidade ), ':', '' ) );
   est_row_Nota_Fiscal_Dest.cidade_ibge  := nvl(est_row_Nota_Fiscal_Dest.cidade_ibge,0);
   est_row_Nota_Fiscal_Dest.uf           := trim ( est_row_Nota_Fiscal_Dest.uf );
   est_row_Nota_Fiscal_Dest.pais         := trim ( pk_csf.fkg_converte ( est_row_Nota_Fiscal_Dest.pais ) );
   est_row_Nota_Fiscal_Dest.fone         := replace(trim ( pk_csf.fkg_converte ( est_row_Nota_Fiscal_Dest.fone ) ), ' ', '');
   est_row_Nota_Fiscal_Dest.ie           := trim ( upper(est_row_Nota_Fiscal_Dest.ie) );
   est_row_Nota_Fiscal_Dest.suframa      := trim ( est_row_Nota_Fiscal_Dest.suframa );
   est_row_Nota_Fiscal_Dest.email        := trim ( replace(replace(replace( est_row_Nota_Fiscal_Dest.email , ',', ';'), ' ;', ''), ' ', '') );
   --
   est_row_Nota_Fiscal_Dest.im           := trim ( pk_csf.fkg_converte ( est_row_Nota_Fiscal_Dest.im ) );
   --
   if upper(trim(est_row_Nota_Fiscal_Dest.im)) like 'ISENT%' then
      --
      est_row_Nota_Fiscal_Dest.im := null;
      --
   end if;
   --
   -- limpa acentos de e-mail
   est_row_Nota_Fiscal_Dest.email        := pk_csf.fkg_limpa_acento ( ev_string => est_row_Nota_Fiscal_Dest.email );
   --
   if est_row_Nota_Fiscal_Dest.email is null then
      --
      update nota_fiscal set dm_st_email = 3
       where id = est_row_Nota_Fiscal_Dest.notafiscal_id;
      --
   end if;
   --
   -- Se o estado for EX, então limpa o CNPJ e IE
   if est_row_Nota_Fiscal_Dest.uf = 'EX' then
      --
      est_row_Nota_Fiscal_Dest.cnpj := null;
      est_row_Nota_Fiscal_Dest.cpf := null;
      est_row_Nota_Fiscal_Dest.ie := null;
      --
   end if;
   --
   if instr(est_row_Nota_Fiscal_Dest.email, '@') = 0 then
      est_row_Nota_Fiscal_Dest.email := null;
   end if;
   --
   if trim(est_row_Nota_Fiscal_Dest.email) = '@' then
      est_row_Nota_Fiscal_Dest.email := null;
   end if;
   --
   if nvl(est_row_Nota_Fiscal_Dest.notafiscal_id, 0) > 0
      and est_row_Nota_Fiscal_Dest.nome is not null
      and est_row_Nota_Fiscal_Dest.lograd is not null
      and est_row_Nota_Fiscal_Dest.nro is not null
      and est_row_Nota_Fiscal_Dest.bairro is not null
      and est_row_Nota_Fiscal_Dest.cidade is not null
      and nvl(est_row_Nota_Fiscal_Dest.cidade_ibge, 0) >= 0
      and est_row_Nota_Fiscal_Dest.uf is not null
      then
      --
      if nvl(gn_tipo_integr,0) = 1 then
         --
         vn_fase := 99.1;
         --
         select notafiscaldest_seq.nextval
           into est_row_Nota_Fiscal_Dest.id
           from dual;
         --
         vn_fase := 99.2;
         --
         begin
            insert into Nota_Fiscal_Dest ( id
                                         , notafiscal_id
                                         , cnpj
                                         , cpf
                                         , nome
                                         , lograd
                                         , nro
                                         , compl
                                         , bairro
                                         , cidade
                                         , cidade_ibge
                                         , uf
                                         , cep
                                         , cod_pais
                                         , pais
                                         , fone
                                         , ie
                                         , suframa
                                         , email
                                         , dm_integr_edi
                                         , im
                                         , id_estrangeiro
                                         )
                                  values ( est_row_Nota_Fiscal_Dest.id
                                         , est_row_Nota_Fiscal_Dest.notafiscal_id
                                         , est_row_Nota_Fiscal_Dest.cnpj
                                         , est_row_Nota_Fiscal_Dest.cpf
                                         , est_row_Nota_Fiscal_Dest.nome
                                         , est_row_Nota_Fiscal_Dest.lograd
                                         , est_row_Nota_Fiscal_Dest.nro
                                         , est_row_Nota_Fiscal_Dest.compl
                                         , est_row_Nota_Fiscal_Dest.bairro
                                         , est_row_Nota_Fiscal_Dest.cidade
                                         , est_row_Nota_Fiscal_Dest.cidade_ibge
                                         , est_row_Nota_Fiscal_Dest.uf
                                         , est_row_Nota_Fiscal_Dest.cep
                                         , est_row_Nota_Fiscal_Dest.cod_pais
                                         , est_row_Nota_Fiscal_Dest.pais
                                         , est_row_Nota_Fiscal_Dest.fone
                                         , est_row_Nota_Fiscal_Dest.ie
                                         , est_row_Nota_Fiscal_Dest.suframa
                                         , est_row_Nota_Fiscal_Dest.email
                                         , est_row_nota_fiscal_dest.dm_integr_edi
                                         , est_row_Nota_Fiscal_Dest.im
                                         , est_row_Nota_Fiscal_Dest.id_estrangeiro
                                         );
         exception
            when dup_val_on_index then
               --
               vn_fase := 99.3;
               --
               update Nota_Fiscal_Dest set cnpj          = est_row_Nota_Fiscal_Dest.cnpj
                                         , cpf           = est_row_Nota_Fiscal_Dest.cpf
                                         , nome          = est_row_Nota_Fiscal_Dest.nome
                                         , lograd        = est_row_Nota_Fiscal_Dest.lograd
                                         , nro           = est_row_Nota_Fiscal_Dest.nro
                                         , compl         = est_row_Nota_Fiscal_Dest.compl
                                         , bairro        = est_row_Nota_Fiscal_Dest.bairro
                                         , cidade        = est_row_Nota_Fiscal_Dest.cidade
                                         , cidade_ibge   = est_row_Nota_Fiscal_Dest.cidade_ibge
                                         , uf            = est_row_Nota_Fiscal_Dest.uf
                                         , cep           = est_row_Nota_Fiscal_Dest.cep
                                         , cod_pais      = est_row_Nota_Fiscal_Dest.cod_pais
                                         , pais          = est_row_Nota_Fiscal_Dest.pais
                                         , fone          = est_row_Nota_Fiscal_Dest.fone
                                         , ie            = est_row_Nota_Fiscal_Dest.ie
                                         , suframa       = est_row_Nota_Fiscal_Dest.suframa
                                         , email         = est_row_Nota_Fiscal_Dest.email
                                         , dm_integr_edi = est_row_nota_fiscal_dest.dm_integr_edi
                                         , im            = est_row_Nota_Fiscal_Dest.im
                                         , id_estrangeiro = est_row_Nota_Fiscal_Dest.id_estrangeiro
                where id = est_row_Nota_Fiscal_Dest.id;
               --
            when others then
               --
               gv_mensagem_log := 'Erro ao atualizar - chave duplicada fase('||vn_fase||'): '||sqlerrm;
               --
               declare
                  vn_loggenericonf_id  log_generico_nf.id%TYPE;
               begin
                  --
                  pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                   , ev_mensagem        => gv_cabec_log
                                   , ev_resumo          => gv_mensagem_log
                                   , en_tipo_log        => ERRO_DE_SISTEMA
                                   , en_referencia_id   => gn_referencia_id
                                   , ev_obj_referencia  => gv_obj_referencia );
                  --
               exception
                  when others then
                     null;
               end;
               --
         end;
         --
      else
         --
         vn_fase := 99.4;
         --
         update Nota_Fiscal_Dest set cnpj          = est_row_Nota_Fiscal_Dest.cnpj
                                   , cpf           = est_row_Nota_Fiscal_Dest.cpf
                                   , nome          = est_row_Nota_Fiscal_Dest.nome
                                   , lograd        = est_row_Nota_Fiscal_Dest.lograd
                                   , nro           = est_row_Nota_Fiscal_Dest.nro
                                   , compl         = est_row_Nota_Fiscal_Dest.compl
                                   , bairro        = est_row_Nota_Fiscal_Dest.bairro
                                   , cidade        = est_row_Nota_Fiscal_Dest.cidade
                                   , cidade_ibge   = est_row_Nota_Fiscal_Dest.cidade_ibge
                                   , uf            = est_row_Nota_Fiscal_Dest.uf
                                   , cep           = est_row_Nota_Fiscal_Dest.cep
                                   , cod_pais      = est_row_Nota_Fiscal_Dest.cod_pais
                                   , pais          = est_row_Nota_Fiscal_Dest.pais
                                   , fone          = est_row_Nota_Fiscal_Dest.fone
                                   , ie            = est_row_Nota_Fiscal_Dest.ie
                                   , suframa       = est_row_Nota_Fiscal_Dest.suframa
                                   , email         = est_row_Nota_Fiscal_Dest.email
                                   , dm_integr_edi = est_row_nota_fiscal_dest.dm_integr_edi
                                   , im            = est_row_Nota_Fiscal_Dest.im
                                   , id_estrangeiro = est_row_Nota_Fiscal_Dest.id_estrangeiro
          where id = est_row_Nota_Fiscal_Dest.id;
         --
      end if;
      --
      vn_fase := 99.5;
      --
      if nvl(vt_log_generico.count,0) <= 0
         and gt_row_Nota_Fiscal.dm_ind_emit = 0 -- Somente emissão própria
         then
         --
         -- chama procedimento de registro da pessoa destinatário da Nota Fiscal
         pkb_reg_pessoa_dest_nf ( est_log_generico_nf         => est_log_generico_nf
                                , et_row_Nota_Fiscal_Dest  => est_row_Nota_Fiscal_Dest
                                , ev_cod_part              => ev_cod_part
                                , en_multorg_id            => en_multorg_id );
         --
      end if;
      --
   end if;
   --
   <<sair_integr>>
   null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_integr_Nota_Fiscal_Dest fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_Nota_Fiscal_Dest;

-------------------------------------------------------------------------------------------------------

-- Integra as informações adicionais da Nota Fiscal
procedure pkb_integr_NFInfor_Adic ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                  , est_row_NFInfor_Adic      in out nocopy  NFInfor_Adic%rowtype
                                  , en_cd_orig_proc           in             Orig_Proc.cd%TYPE default null )
is
   --
   vn_fase           number := 0;
   vn_loggenericonf_id log_generico_nf.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_nfe_nao_integrar ( en_notafiscal_id => est_row_NFInfor_Adic.notafiscal_id ) then
      --
      goto sair_integr;
      --
   end if;
   --
   vn_fase := 1.1;
   --
   est_row_NFInfor_Adic.campo := trim( pk_csf.fkg_converte ( est_row_NFInfor_Adic.campo ) );

   est_row_NFInfor_Adic.conteudo := trim( pk_csf.fkg_converte ( ev_string            => est_row_NFInfor_Adic.conteudo
                                                              , en_espacamento       => 0
                                                              , en_remove_spc_extra  => 1
                                                              , en_ret_carac_espec   => 1
                                                              , en_ret_tecla         => 0
                                                              , en_ret_underline     => 1
                                                              , en_ret_chr10         => 0
                                                                ));
   --
   if nvl(est_row_NFInfor_Adic.notafiscal_id,0) = 0
      and nvl(est_log_generico_nf.count,0) = 0 then
      --
      vn_fase := 1.2;
      --
      gv_mensagem_log := 'Não informada a Nota Fiscal para relacionar as Informações Adicionais.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 2;
   --
   if est_row_NFInfor_Adic.dm_tipo not in (0, 1, 2) then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := '"Indicador do emitente da Informação Complementar da Nota Fiscal" ('||est_row_NFInfor_Adic.dm_tipo||') está inválido.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   else
      --
      vn_fase := 2.2;
      --
      gv_dominio := null;
      --
      gv_dominio := pk_csf.fkg_dominio ( ev_dominio   => 'NFINFOR_ADIC.DM_TIPO'
                                       , ev_vl        => est_row_NFInfor_Adic.dm_tipo );
      --
   end if;
   --
   vn_fase := 3;
   --
   if trim(est_row_NFInfor_Adic.campo) = '0' then
      --
      est_row_NFInfor_Adic.campo := null;
      --
   end if;
   --
   vn_fase := 4;
   -- Contribuinte
   if est_row_NFInfor_Adic.dm_tipo = 0 then -- Contribuinte
      --
      vn_fase := 4.1;
      --
      if trim( est_row_NFInfor_Adic.campo ) is null then
         --
         vn_fase := 4.2;
         --
         if nvl(length( trim( est_row_NFInfor_Adic.conteudo ) ),0) > 4000 then
            --
            vn_fase := 4.3;
            --
            gv_mensagem_log := 'Informações Complementares de interesse do Contribuinte ('||gv_dominio||') não pode ser maiores que 4000 caracteres.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                , est_log_generico_nf  => est_log_generico_nf );
            --
         elsif trim( est_row_NFInfor_Adic.conteudo ) is null then
            --
            vn_fase := 4.4;
            --
            gv_mensagem_log := '"Informações Complementares da NF-e" de interesse do Contribuinte ('||est_row_NFInfor_Adic.conteudo||
                               ') não foi informada. Exemplo: Pedido de Venda, Observação da nota, Dispositivo legal, etc.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                , est_log_generico_nf  => est_log_generico_nf );
            --
         end if;
         --
         if pk_csf.fkg_cod_mod_id(nvl(/*gn_modfiscal_id*/gt_row_nota_fiscal.modfiscal_id,0)) <> 'ND' and length(trim( est_row_NFInfor_Adic.conteudo )) < 10 then
            --
            vn_fase := 4.5;
            --
            gv_mensagem_log := '"Informações Complementares da NF-e" de interesse do Contribuinte ('||est_row_NFInfor_Adic.conteudo||
                               ') deve ter no mínimo 10 caracteres.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                , est_log_generico_nf  => est_log_generico_nf );
            --
         end if;
         --
      elsif trim ( est_row_NFInfor_Adic.campo ) is not null then
         --
         vn_fase := 4.6;
         --
         if nvl(length(est_row_NFInfor_Adic.campo),0) > 20 then
            --
            vn_fase := 4.7;
            --
            gv_mensagem_log := '"Identificação do campo ('||gv_dominio||') não pode ser maior que 20 caracteres.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                , est_log_generico_nf  => est_log_generico_nf );
            --
         end if;
         --
         vn_fase := 4.8;
         --
         if nvl(length(trim(est_row_NFInfor_Adic.conteudo) ),0) > 60 then
            --
            vn_fase := 4.9;
            --
            gv_mensagem_log := '"Conteúdo do campo ('||gv_dominio||') não pode ser maior que 60 caracteres.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                , est_log_generico_nf  => est_log_generico_nf );
            --
         elsif trim( trim(est_row_NFInfor_Adic.conteudo) ) is null then
            --
            vn_fase := 4.10;
            --
            gv_mensagem_log := '"Conteúdo do campo ('||gv_dominio||') não pode ser nulo.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                , est_log_generico_nf  => est_log_generico_nf );
            --
         end if;
         --
      end if;
      --
   elsif est_row_NFInfor_Adic.dm_tipo = 1 then -- Fisco
      --
      vn_fase := 5.1;
      --
      if trim( est_row_NFInfor_Adic.campo ) is null then
         --
         vn_fase := 5.2;
         --
         if nvl(length( trim(est_row_NFInfor_Adic.conteudo) ),0) > 2000 then
            --
            vn_fase := 5.3;
            --
            gv_mensagem_log := '"Informações Complementares de interesse do Fisco não podem ser maiores que 2000 caracteres.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                , est_log_generico_nf  => est_log_generico_nf );
            --
         elsif trim( trim(est_row_NFInfor_Adic.conteudo) ) is null then
            --
            vn_fase := 5.4;
            --
            gv_mensagem_log := 'Informações Complementares de interesse do Fisco não foram informadas.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                , est_log_generico_nf  => est_log_generico_nf );
            --
         end if;
         --
      elsif trim ( est_row_NFInfor_Adic.campo ) is not null then
         --
         vn_fase := 5.5;
         --
         if nvl(length(est_row_NFInfor_Adic.campo),0) > 20 then
            --
            vn_fase := 5.6;
            --
            gv_mensagem_log := '"Identificação do campo ('||gv_dominio||') não pode ser maior que 20 caracteres.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                , est_log_generico_nf  => est_log_generico_nf );
            --
         end if;
         --
         vn_fase := 5.7;
         --
         if nvl(length( trim(est_row_NFInfor_Adic.conteudo) ),0) > 60 then
            --
            vn_fase := 5.8;
            --
            gv_mensagem_log := '"Conteúdo do campo ('||gv_dominio||') não pode ser maior que 60 caracteres.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                , est_log_generico_nf  => est_log_generico_nf );
            --
         elsif trim( trim(est_row_NFInfor_Adic.conteudo) ) is null then
            --
            vn_fase := 5.9;
            --
            gv_mensagem_log := '"Conteúdo do campo ('||gv_dominio||') não pode ser nulo.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem        => gv_cabec_log
                             , ev_resumo          => gv_mensagem_log
                             , en_tipo_log        => ERRO_DE_VALIDACAO
                             , en_referencia_id   => gn_referencia_id
                             , ev_obj_referencia  => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                , est_log_generico_nf  => est_log_generico_nf );
            --
         end if;
         --
      end if;
      --
   elsif est_row_NFInfor_Adic.dm_tipo = 2 then -- Processo
      --
      vn_fase := 6.1;
      --
      est_row_NFInfor_Adic.origproc_id := pk_csf.fkg_Orig_Proc_id ( en_cd => en_cd_orig_proc );
      --
      vn_fase := 6.2;
      -- Válida a informação da origem do processo
      if nvl(est_row_NFInfor_Adic.origproc_id,0) = 0 then
         --
         vn_fase := 6.3;
         --
         gv_mensagem_log := 'Código da Origem do Processo ('||en_cd_orig_proc||') está inválido.';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_VALIDACAO
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      end if;
      --
      vn_fase := 6.4;
      --
      if nvl(length( trim(est_row_NFInfor_Adic.conteudo) ),0) > 60 then
         --
         vn_fase := 6.5;
         --
         gv_mensagem_log := 'Número do processo não pode ser maior que 60 caracteres.';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_VALIDACAO
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      elsif trim( trim(est_row_NFInfor_Adic.conteudo) ) is null then
         --
         vn_fase := 6.6;
         --
         gv_mensagem_log := 'Número do processo não pode ser nulo.';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_VALIDACAO
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      end if;
      --
   end if;
   --
   vn_fase := 99;
   --
   -- Se não existe registro de Log e o Tipo de INtegração é 1 (válida e insere)
   -- então registra a Informação Adicional da Nota Fiscal
   if nvl(est_log_generico_nf.count,0) > 0 and
      fkg_ver_erro_log_generico_nfs( en_nota_fiscal_id => est_row_NFInfor_Adic.notafiscal_id ) = 1 then
      --
      update nota_fiscal set dm_st_proc = 10
       where id = est_row_NFInfor_Adic.notafiscal_id;
      --
   end if;
   --
   if nvl(est_row_NFInfor_Adic.notafiscal_id,0) > 0
      and est_row_NFInfor_Adic.dm_tipo in (0, 1, 2)
      then
      --
      if nvl(est_row_NFInfor_Adic.id,0) <= 0 then
         --
         vn_fase := 99.1;
         --
         select NFInforAdic_seq.nextval
           into est_row_NFInfor_Adic.id
           from dual;
         --
         vn_fase := 99.2;
         --
         insert into NFInfor_Adic ( id
                                  , notafiscal_id
                                  , dm_tipo
                                  , infcompdctofis_id
                                  , campo
                                  , conteudo
                                  , origproc_id
                                  )
                           values ( est_row_NFInfor_Adic.id
                                  , est_row_NFInfor_Adic.notafiscal_id
                                  , est_row_NFInfor_Adic.dm_tipo
                                  , est_row_NFInfor_Adic.infcompdctofis_id
                                  , est_row_NFInfor_Adic.campo
                                  , est_row_NFInfor_Adic.conteudo
                                  , est_row_NFInfor_Adic.origproc_id
                                  );
         --
      else
         --
         vn_fase := 99.3;
         --
         update NFInfor_Adic set dm_tipo            = est_row_NFInfor_Adic.dm_tipo
                               , infcompdctofis_id  = est_row_NFInfor_Adic.infcompdctofis_id
                               , campo              = est_row_NFInfor_Adic.campo
                               , conteudo           = est_row_NFInfor_Adic.conteudo
                               , origproc_id        = est_row_NFInfor_Adic.origproc_id
          where id = est_row_NFInfor_Adic.id;
         --
      end if;
      --
   end if;
   --
   <<sair_integr>>
   null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_integr_NFInfor_Adic fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_NFInfor_Adic;

-------------------------------------------------------------------------------------------------------

-- Integra as informação de detalhamento de serviços prestados na construção civil

procedure pkb_integr_nfs_detconstrcivil ( est_log_generico_nf              in out nocopy  dbms_sql.number_table
                                        , est_row_nfs_det_constr_civil     in out nocopy  nfs_det_constr_civil%rowtype )
is
   --
   vn_fase              number := 0;
   vn_loggenericonf_id    log_generico_nf.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_nfe_nao_integrar ( en_notafiscal_id => est_row_nfs_det_constr_civil.notafiscal_id ) then
      --
      goto sair_integr;
      --
   end if;
   --
   vn_fase := 2;
   --
   if nvl(est_row_nfs_det_constr_civil.notafiscal_id,0) = 0
      and nvl(est_log_generico_nf.count,0) = 0 then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := 'Não informada a Nota Fiscal para registro do detalhamento de serviços prestados na construção civil.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 3;
   --
   est_row_nfs_det_constr_civil.cod_obra  := trim(pk_csf.fkg_converte(est_row_nfs_det_constr_civil.cod_obra));
   est_row_nfs_det_constr_civil.nro_art   := trim(pk_csf.fkg_converte(est_row_nfs_det_constr_civil.nro_art));
   --
   vn_fase := 4;
   --
   if nvl(est_row_nfs_det_constr_civil.dm_ind_obra,-1) not in (0,1,2) then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := 'O Dominio "Indicador de Obra"('|| est_row_nfs_det_constr_civil.dm_ind_obra ||
                         ') não informado ou inválido, Valores válidos: 0-Não é obra de construção civil ou não está sujeita a matrícula de obra, '||
                         '1-Obra de Construção Civil - Empreitada Total e 2-Obra de Construção Civil - Empreitada Parcial, favor verificar.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 5;
   -- Se for obra, o número da cno deve ser obrigatório
   if nvl(est_row_nfs_det_constr_civil.dm_ind_obra, 0) in (1,2) and
      est_row_nfs_det_constr_civil.nro_cno is null then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := '"Número do CNO" não informado.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_row_nfs_det_constr_civil.notafiscal_id,0) > 0
      and nvl(est_row_nfs_det_constr_civil.dm_ind_obra,-1) in (0,1,2)
      then
      --
      vn_fase := 99.1;
      --
      if nvl(gn_tipo_integr, 0) = 1 then
         --
         vn_fase := 99.2;
         --
         select nfsdetconstrcivil_seq.nextval
           into est_row_nfs_det_constr_civil.id
           from dual;
         --
         vn_fase := 99.3;
         --
         insert into nfs_det_constr_civil ( id
                                          , notafiscal_id
                                          , cod_obra
                                          , nro_art
                                          , nro_cno
                                          , dm_ind_obra
                                          )
                                   values ( est_row_nfs_det_constr_civil.id
                                          , est_row_nfs_det_constr_civil.notafiscal_id
                                          , est_row_nfs_det_constr_civil.cod_obra
                                          , est_row_nfs_det_constr_civil.nro_art
                                          , est_row_nfs_det_constr_civil.nro_cno
                                          , est_row_nfs_det_constr_civil.dm_ind_obra
                                          );
         --
      else
         --
         vn_fase := 99.4;
         --
         update nfs_det_constr_civil set cod_obra    = est_row_nfs_det_constr_civil.cod_obra
                                       , nro_art     = est_row_nfs_det_constr_civil.nro_art
                                       , nro_cno     = est_row_nfs_det_constr_civil.nro_cno
                                       , dm_ind_obra = est_row_nfs_det_constr_civil.dm_ind_obra
          where id = est_row_nfs_det_constr_civil.id;
         --
      end if;
      --
   end if;
   --
   <<sair_integr>>
   --
   null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_nfs.pkb_integr_nfs_detconstrcivil fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                             , ev_resumo            => gv_mensagem_log
                             , en_tipo_log          => ERRO_DE_SISTEMA
                             , en_referencia_id     => gn_referencia_id
                             , ev_obj_referencia    => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                                , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_nfs_detconstrcivil;

-------------------------------------------------------------------------------------------------------

-- Integra as informações de impostos do Item da Nota Fiscal -- Processo de impostos - campos flex field
procedure pkb_integr_imp_itemnf_ff ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                   , en_impitemnf_id  in             imp_itemnf.id%type
                                   , en_tipoimp_id    in             tipo_imposto.id%type
                                   , en_cd_imp        in             tipo_imposto.cd%type
                                   , ev_atributo      in             varchar2
                                   , ev_valor         in             varchar2
                                   , en_multorg_id    in             mult_org.id%type )
is
   --
   vn_fase           number := 0;
   vn_loggenericonf_id log_generico_nf.id%type;
   vv_sigla          tipo_imposto.sigla%type := null;
   vn_tiporetimp_id  tipo_ret_imp.id%type := null;
   vn_vl_deducao     imp_itemnf.vl_deducao%type := null;
   vv_cod_receita           tipo_ret_imp_receita.cod_receita%type;
   vn_tiporetimpreceita_id  tipo_ret_imp_receita.id%type;
   vn_dmtipocampo    ff_obj_util_integr.dm_tipo_campo%type;
   vv_cd_tiporetimp  tipo_ret_imp.cd%type;
   vn_cod_nat_rec_pc nat_rec_pc.cod%type := 0;
   vn_codst_id       cod_st.id%type := 0;
   vn_natrecpc_id    nat_rec_pc.id%type := 0;
   vv_mensagem       varchar2(1000) := null;
   vn_notafiscal_id  nota_fiscal.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   gv_mensagem_log := null;
   -- Recupera a sigla do Tipo de Imposto.
   vv_sigla := pk_csf.fkg_tipo_imposto_sigla ( en_cd => en_cd_imp );
   --
   vn_fase := 2;
   --
   if ev_atributo is null then
      --
      vn_fase := 3;
      --
      gv_mensagem_log := 'Impostos do Item da Nota Fiscal: "Atributo" deve ser informado.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => erro_de_validacao
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 4;
   --
   if ev_valor is null then
      --
      vn_fase := 5;
      --
      gv_mensagem_log := 'Impostos do Item da Nota Fiscal: "VALOR" referente ao atributo deve ser informado.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => erro_de_validacao
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 6;
   --
   vv_mensagem := pk_csf.fkg_ff_verif_campos( ev_obj_name => 'VW_CSF_IMP_ITEMNF_SERV_FF'
                                            , ev_atributo => ev_atributo
                                            , ev_valor    => ev_valor );
   --
   vn_fase := 7;
   --
   if vv_mensagem is not null then
      --
      vn_fase := 8;
      --
      gv_mensagem_log := vv_mensagem;
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => erro_de_validacao
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   else
      --
      vn_fase := 9;
      --
      vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo( ev_obj_name => 'VW_CSF_IMP_ITEMNF_SERV_FF'
                                                         , ev_atributo => ev_atributo );
      --
      vn_fase := 10;
      --
      if ev_atributo = 'CD_TIPO_RET_IMP' and ev_valor is not null then
         --
         vn_fase := 11;
         --
         if vn_dmtipocampo = 2 /*vn_dmtipocampo = 1*/ then -- tipo de campo = caracter
            --
            vn_fase := 12;
            --
 /*           vv_cd_tiporetimp := pk_csf.fkg_ff_ret_vlr_number( ev_obj_name => 'VW_CSF_IMP_ITEMNF_SERV_FF'
                                                            , ev_atributo => ev_atributo
                                                            , ev_valor    => ev_valor );*/
             begin
                vv_cd_tiporetimp := pk_csf.fkg_ff_ret_vlr_caracter( ev_obj_name => 'VW_CSF_IMP_ITEMNF_SERV_FF'
                                                                    , ev_atributo => trim(ev_atributo)
                                                                    , ev_valor    => trim(ev_valor) );
             exception
                when others then
                   vv_cd_tiporetimp := null;
             end;                                                            
            --
            vn_fase := 13;
            --
            vn_tiporetimp_id := pk_csf_nfs.fkg_id_tiporetimp( en_tipoimp_id      => en_tipoimp_id
                                                            , en_cd_tipo_ret_imp => vv_cd_tiporetimp
                                                            , en_multorg_id      => en_multorg_id);
            --
            if nvl(vn_tiporetimp_id,0) = 0 then
               --
               vn_fase := 14;
               --
               gv_mensagem_log := 'Identificador do tipo de retenção de imposto inválido de acordo com o imposto ('||vv_sigla||') e valor do atributo ('||
                                  ev_valor||'), informados.';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                , ev_mensagem       => gv_cabec_log || gv_cabec_log_item
                                , ev_resumo         => gv_mensagem_log
                                , en_tipo_log       => erro_de_validacao
                                , en_referencia_id  => gn_referencia_id
                                , ev_obj_referencia => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                   , est_log_generico_nf => est_log_generico_nf );
               --
            end if;
            --
         else
            --
            vn_fase := 15;
            --
            gv_mensagem_log := 'Para o atributo CD_TIPO_RET_IMP, o VALOR informado não confere com o tipo de campo, deveria ser CARACTERE.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                             , ev_mensagem       => gv_cabec_log || gv_cabec_log_item
                             , ev_resumo         => gv_mensagem_log
                             , en_tipo_log       => erro_de_validacao
                             , en_referencia_id  => gn_referencia_id
                             , ev_obj_referencia => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                , est_log_generico_nf => est_log_generico_nf );
            --
         end if;
         --
      elsif ev_atributo = 'VL_DEDUCAO' and ev_valor is not null then
            --
            vn_fase := 16;
            --
            if vn_dmtipocampo = 1 then -- tipo de campo = numérico
               --
               vn_fase := 17;
               --
               vn_vl_deducao := pk_csf.fkg_ff_ret_vlr_number( ev_obj_name => 'VW_CSF_IMP_ITEMNF_SERV_FF'
                                                            , ev_atributo => ev_atributo
                                                            , ev_valor    => ev_valor );
               --
               vn_fase := 18;
               --
               if nvl(vn_vl_deducao,0) <= 0 then
                  --
                  vn_fase := 19;
                  --
                  gv_mensagem_log := 'Valor para dedução deve ser maior que zero.';
                  --
                  vn_loggenericonf_id := null;
                  --
                  pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                   , ev_mensagem       => gv_cabec_log || gv_cabec_log_item
                                   , ev_resumo         => gv_mensagem_log
                                   , en_tipo_log       => erro_de_validacao
                                   , en_referencia_id  => gn_referencia_id
                                   , ev_obj_referencia => gv_obj_referencia );
                  --
                  -- Armazena o "loggenerico_id" na memória
                  pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                      , est_log_generico_nf => est_log_generico_nf );
                  --
               end if;
               --
            else
               --
               vn_fase := 20;
               --
               gv_mensagem_log := 'Para o atributo VL_DEDUCAO, o VALOR informado não confere com o tipo de campo, deveria ser NUMÉRICO.';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                , ev_mensagem       => gv_cabec_log || gv_cabec_log_item
                                , ev_resumo         => gv_mensagem_log
                                , en_tipo_log       => erro_de_validacao
                                , en_referencia_id  => gn_referencia_id
                                , ev_obj_referencia => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                   , est_log_generico_nf => est_log_generico_nf );
               --
            end if;
            --
      elsif ev_atributo = 'COD_NAT_REC_PC' and ev_valor is not null then
            --
            vn_fase := 21;
            --
            if vn_dmtipocampo = 1 then -- tipo de campo = numérico
               --
               vn_fase := 22;
               --
               begin
                  vn_cod_nat_rec_pc := pk_csf.fkg_ff_ret_vlr_number( ev_obj_name => 'VW_CSF_IMP_ITEMNF_SERV_FF'
                                                                   , ev_atributo => ev_atributo
                                                                   , ev_valor    => ev_valor );
               exception
                  when others then
                     vn_cod_nat_rec_pc := null;
               end;
               --
               vn_fase := 23;
               --
               begin
                  select ii.codst_id
                    into vn_codst_id
                    from imp_itemnf ii
                   where ii.id = en_impitemnf_id;
               exception
                  when others then
                     vn_codst_id := 0;
               end;
               --
               vn_fase := 24;
               --
               begin
                  vn_natrecpc_id := pk_csf_efd_pc.fkg_codst_id_nat_rec_pc ( en_multorg_id        => en_multorg_id
                                                                          , en_natrecpc_codst_id => vn_codst_id
                                                                          , en_natrecpc_cod      => vn_cod_nat_rec_pc );
               exception
                  when others then
                     vn_natrecpc_id := null;
               end;
               --
               vn_fase := 25;
               --
               if nvl(vn_natrecpc_id,0) <= 0 then
                  --
                  vn_fase := 26;
                  --
                  gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR ('||ev_valor||') informado está inválido.';
                  --
                  vn_loggenericonf_id := null;
                  --
                  pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                   , ev_mensagem       => gv_cabec_log || gv_cabec_log_item
                                   , ev_resumo         => gv_mensagem_log
                                   , en_tipo_log       => erro_de_validacao
                                   , en_referencia_id  => gn_referencia_id
                                   , ev_obj_referencia => gv_obj_referencia );
                  --
                  -- Armazena o "loggenerico_id" na memória
                  pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                      , est_log_generico_nf => est_log_generico_nf );
                  --
               end if;
               --
            else
               --
               vn_fase := 27;
               --
               gv_mensagem_log := 'Para o atributo COD_NAT_REC_PC, o VALOR informado não confere com o tipo de campo, deveria ser NUMÉRICO.';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                , ev_mensagem       => gv_cabec_log || gv_cabec_log_item
                                , ev_resumo         => gv_mensagem_log
                                , en_tipo_log       => erro_de_validacao
                                , en_referencia_id  => gn_referencia_id
                                , ev_obj_referencia => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                   , est_log_generico_nf => est_log_generico_nf );
               --
            end if;
            --
      elsif ev_atributo = 'COD_RECEITA' and ev_valor is not null then
         --
         vn_fase := 11;
         --
         if vn_dmtipocampo = 2 then -- tipo de campo = caractere
            --
            vn_fase := 12;
            --
            vv_cod_receita := pk_csf.fkg_ff_ret_vlr_caracter ( ev_obj_name => 'VW_CSF_IMP_ITEMNF_SERV_FF'
                                                             , ev_atributo => ev_atributo
                                                             , ev_valor    => ev_valor
                                                             );
            --
            vn_fase := 13;
            --
            begin
               select ii.tiporetimp_id
                 into vn_tiporetimp_id
                 from imp_itemnf ii
                where ii.id = en_impitemnf_id;
            exception
               when others then
                  vn_tiporetimp_id := 0;
            end;
            --
            if nvl(vn_tiporetimp_id,0) <= 0 then
               --
               begin
                  --
                  select min(r.id)
                    into vn_tiporetimpreceita_id
                    from tipo_ret_imp tri
                       , tipo_ret_imp_receita r
                   where tri.multorg_id   = en_multorg_id
                     and tri.tipoimp_id   = en_tipoimp_id
                     and r.TIPORETIMP_ID  = tri.id
                     and r.cod_receita    = trim(vv_cod_receita);
                  --
               exception
                  when others then
                     vn_tiporetimpreceita_id := 0;
               end;
               --
            else
               --
               begin
                  --
                  select r.id
                    into vn_tiporetimpreceita_id
                    from tipo_ret_imp_receita r
                   where r.TIPORETIMP_ID = vn_tiporetimp_id
                     and r.cod_receita = trim(vv_cod_receita);
                  --
               exception
                  when others then
                     vn_tiporetimpreceita_id := 0;
               end;
               --
            end if;
            --
            if nvl(vn_tiporetimpreceita_id,0) <= 0 then
               --
               vn_fase := 14;
               --
               gv_mensagem_log := 'Identificador do Código de "Receita do tipo de retenção de imposto" inválido de acordo com o "imposto" ('||
                                  pk_csf.fkg_tipo_imp_sigla(en_id => en_tipoimp_id)||'), "tipo de retenção de imposto"(' || pk_csf.fkg_tipo_ret_imp_cd ( en_tiporetimp_id => vn_tiporetimp_id )
                                           || ') e "valor do atributo" ('||ev_valor||'), informados.';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                , ev_mensagem       => gv_cabec_log || gv_cabec_log_item
                                , ev_resumo         => gv_mensagem_log
                                , en_tipo_log       => erro_de_validacao
                                , en_referencia_id  => gn_referencia_id
                                , ev_obj_referencia => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                   , est_log_generico_nf => est_log_generico_nf );
               --
            end if;
            --
         else
            --
            vn_fase := 15;
            --
            gv_mensagem_log := 'Para o atributo CD_TIPO_RET_IMP, o VALOR informado não confere com o tipo de campo, deveria ser CARACTERE.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                             , ev_mensagem       => gv_cabec_log || gv_cabec_log_item
                             , ev_resumo         => gv_mensagem_log
                             , en_tipo_log       => erro_de_validacao
                             , en_referencia_id  => gn_referencia_id
                             , ev_obj_referencia => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                , est_log_generico_nf => est_log_generico_nf );
            --
         end if;
         --
      else
         --
         vn_fase := 28;
         --
         gv_mensagem_log := '"Atributo" ('||ev_atributo||') e "VALOR" ('||ev_valor||') relacionados, não especificados no processo.';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_VALIDACAO
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      end if;
      --
   end if;
   --
   vn_fase := 29;
   --
   if nvl(en_impitemnf_id,0) = 0 then
      --
      vn_fase := 30;
      --
      gv_mensagem_log := 'Identificador do imposto do item da nota fiscal não informado para geração dos campos complementares (FF).';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => erro_de_validacao
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 99;
   --
   -- Se não foi encontrato erro e o Tipo de Integração é 1 (Válida e insere)
   -- então realiza a condição de inserir o imposto
   --
   vn_fase := 99.1;
   --
   begin
     select it.notafiscal_id 
       into vn_notafiscal_id
       from item_nota_fiscal it
      where it.id in (select ii.itemnf_id from imp_itemnf ii
                       where ii.id = en_impitemnf_id );
   exception 
     when no_data_found then
       vn_notafiscal_id := null;        
   end;
   --
   if nvl(est_log_generico_nf.count,0) > 0 and 
      fkg_ver_erro_log_generico_nfs( en_nota_fiscal_id => vn_notafiscal_id ) = 1 then
 
      --
      vn_fase := 99.2;
      --
      update nota_fiscal set dm_st_proc = 10
       where id = vn_notafiscal_id;
      --
   end if;
   --
   vn_fase := 99.2;
   --
   if nvl(en_impitemnf_id,0) > 0 and
      ev_atributo = 'CD_TIPO_RET_IMP' and
      nvl(vn_tiporetimp_id,0) > 0 and
      gv_mensagem_log is null then
      --
      vn_fase := 99.3;
      --
      update imp_itemnf ii
         set ii.tiporetimp_id = vn_tiporetimp_id
       where id = en_impitemnf_id;
      --
   elsif nvl(en_impitemnf_id,0) > 0 and
         ev_atributo = 'VL_DEDUCAO' and
         nvl(vn_vl_deducao,0) <> 0 and
         gv_mensagem_log is null then
         --
         vn_fase := 99.4;
         --
         update imp_itemnf ii
            set ii.vl_deducao = vn_vl_deducao
          where id = en_impitemnf_id;
         --
   elsif nvl(en_impitemnf_id,0) > 0 and
         ev_atributo = 'COD_NAT_REC_PC' and
         nvl(vn_natrecpc_id,0) <> 0 and
         gv_mensagem_log is null then
         --
         vn_fase := 99.5;
         --
         update imp_itemnf ii
            set ii.natrecpc_id = vn_natrecpc_id
          where id = en_impitemnf_id;
         --
   elsif nvl(en_impitemnf_id,0) > 0 and
         ev_atributo = 'COD_RECEITA' and
         nvl(vn_tiporetimpreceita_id,0) <> 0 and
         gv_mensagem_log is null then
         --
         vn_fase := 99.5;
         --
         update imp_itemnf ii
            set ii.tiporetimpreceita_id = vn_tiporetimpreceita_id
          where id = en_impitemnf_id;
         --
   end if;
   --
   vn_fase := 100;
   --
   <<sair_integr>>
   null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_integr_Imp_ItemNf_ff fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_Imp_ItemNf_ff;

-------------------------------------------------------------------------------------------------------

-- Integra as informações de impostos adicionais de aposentadoria especial
procedure pkb_int_imp_adic_apos_esp_serv ( est_log_generico_nf            in out nocopy  dbms_sql.number_table
                                         , est_row_imp_adic_apos_esp_serv in out nocopy  imp_adic_aposent_esp%rowtype
                                         , en_cd_imp                      in             tipo_imposto.cd%type)
is
   --
   vn_fase           number := 0;
   vn_loggenericonf_id log_generico_nf.id%TYPE;
   vn_notafiscal_id    nota_fiscal.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(est_row_imp_adic_apos_esp_serv.impitemnf_id,0) = 0
      and nvl(est_log_generico_nf.count,0) = 0 then
      --
      vn_fase := 1.1;
      --
      gv_mensagem_log := 'Não informado o imposto da Nota Fiscal para registro de impostos adicionais de aposentadoria especial.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 2;
   -- Valida se as informações estão relacionadas ao imposto de INSS
   if nvl(en_cd_imp, 0) <> 13 then  -- 13-INSS
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := 'As informações do imposto adicional de aposentadoria especial só deve ser informada para o código de imposto "13-INSS".';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 3;
   --
   -- Valida o percentual do imposto adicional - Reinf
   if nvl(est_row_imp_adic_apos_esp_serv.percentual, 0) not in (2,3,4) then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := 'O percentual "'|| est_row_imp_adic_apos_esp_serv.percentual ||'" do impostos adicional de aposentadoria especial está incorreto.' ||
                         ' Valores válidos: 2, 3 ou 4.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 4;
   --
   -- Valida o valor adicional do imposto adicional - Reinf
   if nvl(est_row_imp_adic_apos_esp_serv.vl_adicional, 0) <= 0 then
      --
      vn_fase := 4.2;
      --
      gv_mensagem_log := 'O valor do imposto adicional de aposentadoria especial não pode ser menor ou igual zero';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 99;
   --
   -- Se não foi encontrato erro e o Tipo de Integração é 1 (Válida e insere)
   -- então realiza a condição de inserir o imposto
   begin
     select distinct it.notafiscal_id
       into vn_notafiscal_id
       from item_nota_fiscal it
          , imp_itemnf       ii
      where it.id = ii.itemnf_id
        and ii.id = est_row_imp_adic_apos_esp_serv.impitemnf_id; 
   exception
     when no_data_found then
       vn_notafiscal_id := null;     
   end;
   --
   if nvl(est_log_generico_nf.count,0) > 0 and 
      fkg_ver_erro_log_generico_nfs( en_nota_fiscal_id => vn_notafiscal_id ) = 1 then
      --
      update nota_fiscal 
         set dm_st_proc = 10
       where id = vn_notafiscal_id;
      --
   end if;
   --
   vn_fase := 99.1;
   --
   est_row_imp_adic_apos_esp_serv.vl_adicional := nvl(est_row_imp_adic_apos_esp_serv.vl_adicional,0);
   --
   vn_fase := 99.2;
   --
   if nvl(est_row_imp_adic_apos_esp_serv.impitemnf_id, 0) > 0
      and nvl(est_row_imp_adic_apos_esp_serv.percentual, 0) in (2,3,4)
      and nvl(est_row_imp_adic_apos_esp_serv.vl_adicional, 0) > 0 then
      --
      if nvl(gn_tipo_integr,0) = 1 then
         --
         vn_fase := 99.3;
         --
         select impadicaposentesp_seq.nextval
           into est_row_imp_adic_apos_esp_serv.id
           from dual;
         --
         vn_fase := 99.4;
         --
         insert into imp_adic_aposent_esp ( id
                                          , impitemnf_id
                                          , percentual
                                          , vl_adicional 
                                          )
                                   values ( est_row_imp_adic_apos_esp_serv.id
                                          , est_row_imp_adic_apos_esp_serv.impitemnf_id
                                          , est_row_imp_adic_apos_esp_serv.percentual
                                          , est_row_imp_adic_apos_esp_serv.vl_adicional
                                          );
         --
      else
         --
         vn_fase := 99.5;
         --
         update imp_adic_aposent_esp 
            set impitemnf_id = est_row_imp_adic_apos_esp_serv.impitemnf_id
              , percentual   = est_row_imp_adic_apos_esp_serv.percentual
              , vl_adicional = est_row_imp_adic_apos_esp_serv.vl_adicional
          where id = est_row_imp_adic_apos_esp_serv.id;
         --
      end if;
      --
   end if;
   --
   <<sair_integr>>
   null;

exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_int_imp_adic_apos_esp_serv fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                             , ev_resumo            => gv_mensagem_log
                             , en_tipo_log          => ERRO_DE_SISTEMA
                             , en_referencia_id     => gn_referencia_id
                             , ev_obj_referencia    => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                                , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_int_imp_adic_apos_esp_serv;

-------------------------------------------------------------------------------------------------------

-- Integra as informações de impostos do Item da Nota Fiscal
procedure pkb_integr_Imp_ItemNf ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                , est_row_Imp_ItemNf        in out nocopy  Imp_ItemNf%rowtype
                                , en_cd_imp                 in             Tipo_Imposto.cd%TYPE
                                , ev_cod_st                 in             Cod_ST.cod_st%TYPE
                                , en_notafiscal_id          in             Nota_Fiscal.id%TYPE )
is
   --
   vn_fase               number := 0;
   vn_loggenericonf_id   log_generico_nf.id%TYPE;
   vv_Sigla              Tipo_Imposto.Sigla%TYPE := null;
   vv_dm_tipo            varchar2(50);
   vn_imp_itemnf         number;
   vn_dm_valida_pis      empresa.dm_valida_pis%type;
   vn_dm_valida_cofins   empresa.dm_valida_cofins%type;
   vn_empresa_id         empresa.id%type;
   vn_basecalccredpc_id  itemnf_compl_serv.basecalccredpc_id%type;
   vn_notafiscal_id      nota_fiscal.id%type;
   vn_dm_ind_emit        nota_fiscal.dm_ind_emit%type;
   vn_dm_legado          nota_fiscal.dm_legado%type;         
   --
   vn_cidade_id          COD_ST_CIDADE.CIDADE_ID%type;
   vv_cod_st             Cod_ST.cod_st%TYPE;
   vn_codstcid_id        COD_ST_CIDADE.id%type;
   --
   vn_vl_imp_trib          Imp_ItemNf.vl_imp_trib%type;
   vv_cod_mod              mod_fiscal.cod_mod%type;
   vn_vl_imp_trib_2        Imp_ItemNf.vl_imp_trib%type; /*number; *//*para calculo do Imp_ItemNf.vl_imp_trib sem truncar*/
   vv_cd_tipo_imposto      tipo_imposto.cd%type;
   vn_vl_toler_nf          number;
   vn_dif_valor            number;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_nfe_nao_integrar ( en_notafiscal_id => en_notafiscal_id ) then
      --
      goto sair_integr;
      --
   end if;
   --
   vn_fase := 1.1;
   --
   if nvl(est_row_Imp_ItemNf.itemnf_id,0) = 0
      and nvl(est_log_generico_nf.count,0) = 0 then
      --
      vn_fase := 1.2;
      --
      gv_mensagem_log := 'Não informado ITEM da Nota Fiscal para registro dos Impostos.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 1.2;
   --
   begin
     select nfi.empresa_id
       into vn_empresa_id
      from item_nota_fiscal ite,
           nota_fiscal nfi
     where ite.id = est_row_Imp_ItemNf.Itemnf_Id
       and nfi.id = ite.notafiscal_id;
   exception
     when no_data_found then
        vn_empresa_id := null;
   end;
   --
   vn_fase := 2;
   --
   -- Recupera o Tipo de Imposto, se não informado registra o erro de validação
   if nvl(en_cd_imp,0) > 0 then
      --
      vn_fase := 2.1;
      --
      est_row_Imp_ItemNf.tipoimp_id  := pk_csf.fkg_Tipo_Imposto_id ( en_cd => en_cd_imp );
      --
      vn_fase := 2.2;
      -- Se não encontrou o tipo de imposto registra o log
      if nvl(est_row_Imp_ItemNf.tipoimp_id,0) = 0 then
         --
         vn_fase := 2.3;
         --
         gv_mensagem_log := '"Tipo de Imposto da Nota Fiscal" está inválido ('||en_cd_imp||').';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_VALIDACAO
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      else
         --
         vn_fase := 2.4;
         --
         vv_Sigla := pk_csf.fkg_Tipo_Imposto_Sigla ( en_cd => en_cd_imp );
         --
      end if;
      --
   else
      --
      vn_fase := 2.5;
      --
      gv_mensagem_log := '"Tipo de Imposto da Nota Fiscal" não informado.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 3;
   --
   -- Válida informação do campo dm_tipo se é Imposto ou Retenção
   if est_row_Imp_ItemNf.dm_tipo not in (0, 1) then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := '"Tipo de Impostos da Nota Fiscal" ('||est_row_Imp_ItemNf.dm_tipo||') está inválido.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vv_dm_tipo := pk_csf.fkg_dominio ( ev_dominio   => 'IMP_ITEMNF.DM_TIPO'
                                    , ev_vl        => est_row_Imp_ItemNf.dm_tipo
                                    );
   --
   vn_fase := 4;
   --
   -- Recupera o código de tributação
   if ev_cod_st is not null and nvl(est_row_Imp_ItemNf.tipoimp_id,0) > 0 then
      --
      vn_fase := 4.1;
      --
      -- Conforme o imposto, restorna o ID do código da tributação
      est_row_Imp_ItemNf.codst_id := pk_csf.fkg_Cod_ST_id ( ev_cod_st      => ev_cod_st
                                                          , en_tipoimp_id  => est_row_Imp_ItemNf.tipoimp_id );
      --
   end if;
   --
   vn_fase := 4.2;
   -- Valida se o Código da Situação Tributária deveria ser obrigatório
   -- Se não tem CST e o imposto é 1-Icms, 3-IPI, 4-PIS ou 5-Cofins
   if nvl(est_row_Imp_ItemNf.codst_id,0) <= 0
      and est_row_Imp_ItemNf.dm_tipo = 0 -- IMposto
      and en_cd_imp in ( 4, 5 ) -- 3-IPI, 4-PIS, 5-COFINS, 10-SN
      then
      --
      vn_fase := 4.3;
      --
      gv_mensagem_log := 'Não foi informado o Código de Situação Tributária para o tipo de imposto '||vv_Sigla||'.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 4.4;
   --
   if nvl(est_row_Imp_ItemNf.codst_id,0) <= 0
      and en_cd_imp in ( 4, 5 )
      and trim(ev_cod_st) is not null then
      --
      vn_fase := 4.5;
      --
      gv_mensagem_log := 'Código de Situação Tributária está inválido ('||ev_cod_st||') para o tipo de imposto '||vv_Sigla||'.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 5;
   --
   if en_cd_imp in ( 4, 5 ) then -- 4-PIS, 5-COFINS
      if (ev_cod_st between 50 and 56) or (ev_cod_st between 60 and 66) then
         --
         vn_fase := 5.1;
         --
         begin
            select it.basecalccredpc_id
              into vn_basecalccredpc_id
              from itemnf_compl_serv it
             where it.itemnf_id = est_row_Imp_ItemNf.Itemnf_Id;
         exception
             when no_data_found then
                vn_basecalccredpc_id := null;
         end;
         --
         vn_fase := 5.2;
         --
         if en_cd_imp = 4 then -- 4-PIS
            -- Recupera se valida ou não pis
            --
            if pk_csf.fkg_dmindemit_notafiscal ( en_notafiscal_id => en_notafiscal_id ) = 0 then -- emissão própria
               --
               vn_dm_valida_pis := pk_csf.fkg_empresa_dmvalpis_emis_nfs ( en_empresa_id => vn_empresa_id );
               --
            elsif pk_csf.fkg_dmindemit_notafiscal ( en_notafiscal_id => en_notafiscal_id ) = 1 then -- terceiros
               --
               vn_dm_valida_pis := pk_csf.fkg_empresa_dmvalpis_terc_nfs ( en_empresa_id => vn_empresa_id );
               --
            else
               --
               vn_dm_valida_pis := 1; -- sim
               --
            end if;
            ---
            if vn_basecalccredpc_id is null and
               vn_dm_valida_pis = 1 and  -- valida pis
               nvl(est_row_Imp_ItemNf.dm_tipo,-1) = 0 and
               nvl(est_row_Imp_ItemNf.vl_base_calc,0) > 0 and
               nvl(est_row_Imp_ItemNf.aliq_apli,0) > 0 then
               --
               gv_mensagem_log := '"Código da Base de Cálculo do Crédito" para PIS/COFINS não informado e existe base e aliquota para nota fiscal.';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                   , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                   , ev_resumo          => gv_mensagem_log
                                   , en_tipo_log        => INFORMACAO
                                   , en_referencia_id   => gn_referencia_id
                                   , ev_obj_referencia  => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                      , est_log_generico_nf  => est_log_generico_nf );
               --
            end if;
            --
         else
            --
            vn_fase := 5.3;
            --
            -- Recupera se valida ou não cofins
            --
            if pk_csf.fkg_dmindemit_notafiscal ( en_notafiscal_id => en_notafiscal_id ) = 0 then -- emissão própria
               --
               vn_dm_valida_cofins := pk_csf.fkg_empr_dmvalcofins_emis_nfs ( en_empresa_id => vn_empresa_id );
               --
            elsif pk_csf.fkg_dmindemit_notafiscal ( en_notafiscal_id => en_notafiscal_id  ) = 1 then -- terceiros
               --
               vn_dm_valida_cofins := pk_csf.fkg_empr_dmvalcofins_terc_nfs ( en_empresa_id => vn_empresa_id );
               --
            else
               --
               vn_dm_valida_cofins := 1; -- sim
               --
            end if;
            ---
            if vn_basecalccredpc_id is null and
               vn_dm_valida_cofins = 1 and  -- valida cofins
               nvl(est_row_Imp_ItemNf.dm_tipo,-1) = 0 and
               nvl(est_row_Imp_ItemNf.vl_base_calc,0) > 0 and
               nvl(est_row_Imp_ItemNf.aliq_apli,0) > 0 then
               --
               gv_mensagem_log := '"Código da Base de Cálculo do Crédito" para PIS/COFINS não informado e existe base e aliquota para nota fiscal.';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                   , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                   , ev_resumo          => gv_mensagem_log
                                   , en_tipo_log        => INFORMACAO
                                   , en_referencia_id   => gn_referencia_id
                                   , ev_obj_referencia  => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                      , est_log_generico_nf  => est_log_generico_nf );
               --
            end if;
            --
         end if;
         --
      end if;
      --
   end if;
   --
   -- Válidações de números negativos
   --
   if nvl(est_row_Imp_ItemNf.vl_base_calc,0) < 0 then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := '"Valor da Base de Cálculo de '||vv_Sigla || '(' || vv_dm_tipo || ')' ||'" ('||est_row_Imp_ItemNf.vl_base_calc||') não pode ser negativo.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 6;
   --
   if nvl(est_row_Imp_ItemNf.aliq_apli,0) < 0 then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := '"Alíquota de Imposto de '||vv_Sigla || '(' || vv_dm_tipo || ')' ||'" ('||est_row_Imp_ItemNf.aliq_apli||') não pode ser negativa.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 7;
   --
   if nvl(est_row_Imp_ItemNf.vl_imp_trib,0) < 0 then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := '"Valor do Imposto Tributado de '||vv_Sigla || '(' || vv_dm_tipo || ')' ||'" ('||est_row_Imp_ItemNf.vl_imp_trib||') não pode ser negativo.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   elsif nvl(est_row_Imp_ItemNf.vl_imp_trib,0)>= 0 then
      --
      vn_fase := 7.2;
      --
      vv_cod_mod:= pk_csf.fkg_cod_mod_id(en_modfiscal_id => gt_row_nota_fiscal.modfiscal_id);
      --
      if (vv_cod_mod = '99' /*Servico*/
        or (vv_cod_mod = '55' and gt_row_item_nota_fiscal.cd_lista_serv is not null))
        and gt_row_nota_fiscal.dm_ind_emit = 1 /*(Terceiros)*/
        then 
        --
        vv_cd_tipo_imposto:= null;
        vv_cd_tipo_imposto:= pk_csf.fkg_Tipo_Imposto_cd(en_tipoimp_id =>  est_row_Imp_ItemNf.Tipoimp_Id);
        --
        vn_fase := 7.3;
        --
        if est_row_Imp_ItemNf.dm_tipo = 1 -- retencao
          and vv_cd_tipo_imposto = 13 -- INSS
          then 
          ---
          vn_fase := 7.31;
          --		  
          -- Função retorna o valor de tolerância para os valores de documentos fiscais (nf) e caso não exista manter 0.03
          vn_vl_toler_nf := pk_csf.fkg_vlr_toler_empresa ( en_empresa_id => vn_empresa_id
                                                         , ev_opcao      => 'NF' );
          --
          vn_vl_imp_trib := 0;
          vn_vl_imp_trib :=trunc(est_row_Imp_ItemNf.VL_BASE_CALC * (est_row_Imp_ItemNf.ALIQ_APLI/100),2);
          --
          vn_dif_valor := nvl(est_row_Imp_ItemNf.vl_imp_trib,0) - nvl(vn_vl_imp_trib,0);			 
          --			 
          if nvl(est_row_Imp_ItemNf.vl_imp_trib,0) <> nvl(vn_vl_imp_trib,0) and
             ((nvl(vn_dif_valor,0) < (nvl(vn_vl_toler_nf,0) * -1)) or (nvl(vn_dif_valor,0) > nvl(vn_vl_toler_nf,0))) then			 
             --
             gv_mensagem_log := '"Valor do Imposto Tributado de '||vv_Sigla||'" ('||est_row_Imp_ItemNf.vl_imp_trib||') esta diferente se calculado a partir dos valores de "Valor da Base de Cálculo de '||vv_Sigla||'" e "Alíquota de Imposto de '||vv_Sigla||'".';
             --
             vn_loggenericonf_id := null;
             --
             pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                              , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                              , ev_resumo          => gv_mensagem_log
                              , en_tipo_log        => ERRO_DE_VALIDACAO
                              , en_referencia_id   => gn_referencia_id
                              , ev_obj_referencia  => gv_obj_referencia );
             --
             -- Armazena o "loggenerico_id" na memória
             pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                 , est_log_generico_nf  => est_log_generico_nf );
             --
          end if;
          --
        end if;
        --
      end if;
      --
   end if;
   --
   vn_fase := 8;
   --    
   if en_cd_imp = 6 /*ISS*/
     /*and nvl(est_row_Imp_ItemNf.Codst_Id,0) < 0 then*/
     and ev_cod_st is not null then
      --
      vn_fase := 8.1;
      --
      vn_cidade_id  := pk_csf.fkg_cidade_id_ibge ( ev_ibge_cidade => pk_csf_api_nfs.gt_row_nota_fiscal.cidade_ibge_emit );
      --
      vn_fase := 8.2;
      --
      vn_codstcid_id:= pk_csf.fkg_codstcidade_Id(ev_cod_st    => ev_cod_st
                                                ,en_cidade_id => vn_cidade_id) ;
      --
      vn_fase := 8.3;
      --
      est_row_Imp_ItemNf.Codstcidade_Id:= vn_codstcid_id;
      --
   end if;
   --
   vn_fase := 8.4;
   --
   begin
     select it.notafiscal_id
          , nf.dm_ind_emit
          , nf.dm_legado   
       into vn_notafiscal_id
          , vn_dm_ind_emit       
          , vn_dm_legado	    
       from item_nota_fiscal it
          , nota_fiscal      nf
      where it.id = est_row_Imp_ItemNf.itemnf_id
        and nf.id = it.notafiscal_id;
   exception
     when no_data_found then
       vn_notafiscal_id := null;
       vn_dm_ind_emit   := null;
       vn_dm_legado     := null;	   
   end;
   --   
   /*Para cidade de Florianopolis*/
   if en_cd_imp = 6 and nvl(vn_dm_ind_emit,-1) = 0 and nvl(vn_dm_legado,-1) = 0 and 
      pk_csf_api_nfs.gt_row_nota_fiscal.cidade_ibge_emit = 4205407 then
     --
     vn_fase := 8.5;
     --
     if est_row_Imp_ItemNf.Codstcidade_Id is null then
       --
       vn_fase := 8.51;
       --
       gv_mensagem_log := '"O Código St do imposto ISS da cidade de Florianopolis, não está preenchido ou está invalido.';
       --
       vn_loggenericonf_id := null;
       --
       pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                           , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => ERRO_DE_VALIDACAO
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
       --
       -- Armazena o "loggenerico_id" na memória
       pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
       --
     end if;
     --
   end if;
   --
   vn_fase := 99;
   --
   -- Se não foi encontrato erro e o Tipo de Integração é 1 (Válida e insere)
   -- então realiza a condição de inserir o imposto
   --
   if nvl(est_log_generico_nf.count,0) > 0 and
      fkg_ver_erro_log_generico_nfs( en_nota_fiscal_id => vn_notafiscal_id ) = 1 then
      --
      update nota_fiscal set dm_st_proc = 10
       where id = vn_notafiscal_id;
      --
   end if;
   --
   est_row_Imp_ItemNf.vl_imp_trib := nvl(est_row_Imp_ItemNf.vl_imp_trib,0);
   --
   if nvl(est_row_Imp_ItemNf.itemnf_id,0) > 0
      and nvl(est_row_Imp_ItemNf.tipoimp_id,0) > 0
      and est_row_Imp_ItemNf.dm_tipo in (0, 1) then
      --
      if nvl(gn_tipo_integr,0) = 1 then
         --
         vn_fase := 99.1;
         --
         -- Verifica se existe imposto já inserido
         vn_imp_itemnf := pk_csf.fkg_existe_imp_itemnf ( en_itemnf_id  => est_row_Imp_ItemNf.itemnf_id
                                                       , en_tipoimp_id => est_row_Imp_ItemNf.tipoimp_id
                                                       , en_dm_tipo    => est_row_Imp_ItemNf.dm_tipo  );
         --
         if nvl(vn_imp_itemnf,0) <= 0 then
            --
            vn_fase := 99.2;
            --
            select impitemnf_seq.nextval
              into est_row_Imp_ItemNf.id
              from dual;
            --
            vn_fase := 99.3;
            --
            insert into Imp_ItemNf ( id
                                   , itemnf_id
                                   , tipoimp_id
                                   , dm_tipo
                                   , codst_id
                                   , vl_base_calc
                                   , aliq_apli
                                   , vl_imp_trib
                                   , perc_reduc
                                   , perc_adic
                                   , qtde_base_calc_prod
                                   , vl_aliq_prod
                                   , vl_bc_st_ret
                                   , vl_icmsst_ret
                                   , perc_bc_oper_prop
                                   , estado_id
                                   , vl_bc_st_dest
                                   , vl_icmsst_dest
                                   , Codstcidade_Id
                                   )
                            values ( est_row_Imp_ItemNf.id
                                   , est_row_Imp_ItemNf.itemnf_id
                                   , est_row_Imp_ItemNf.tipoimp_id
                                   , est_row_Imp_ItemNf.dm_tipo
                                   , est_row_Imp_ItemNf.codst_id
                                   , est_row_Imp_ItemNf.vl_base_calc
                                   , est_row_Imp_ItemNf.aliq_apli
                                   , est_row_Imp_ItemNf.vl_imp_trib
                                   , est_row_Imp_ItemNf.perc_reduc
                                   , est_row_Imp_ItemNf.perc_adic
                                   , est_row_Imp_ItemNf.qtde_base_calc_prod
                                   , est_row_Imp_ItemNf.vl_aliq_prod
                                   , est_row_Imp_ItemNf.vl_bc_st_ret
                                   , est_row_Imp_ItemNf.vl_icmsst_ret
                                   , est_row_Imp_ItemNf.perc_bc_oper_prop
                                   , est_row_Imp_ItemNf.estado_id
                                   , est_row_Imp_ItemNf.vl_bc_st_dest
                                   , est_row_Imp_ItemNf.vl_icmsst_dest
                                   , est_row_Imp_ItemNf.Codstcidade_Id
                                   );
         --
         end if;
         --
      else
         --
         vn_fase := 99.4;
         --
         update Imp_ItemNf set tipoimp_id           = est_row_Imp_ItemNf.tipoimp_id
                             , dm_tipo              = est_row_Imp_ItemNf.dm_tipo
                             , codst_id             = est_row_Imp_ItemNf.codst_id
                             , vl_base_calc         = est_row_Imp_ItemNf.vl_base_calc
                             , aliq_apli            = est_row_Imp_ItemNf.aliq_apli
                             , vl_imp_trib          = est_row_Imp_ItemNf.vl_imp_trib
                             , perc_reduc           = est_row_Imp_ItemNf.perc_reduc
                             , perc_adic            = est_row_Imp_ItemNf.perc_adic
                             , qtde_base_calc_prod  = est_row_Imp_ItemNf.qtde_base_calc_prod
                             , vl_aliq_prod         = est_row_Imp_ItemNf.vl_aliq_prod
                             , vl_bc_st_ret         = est_row_Imp_ItemNf.vl_bc_st_ret
                             , vl_icmsst_ret        = est_row_Imp_ItemNf.vl_icmsst_ret
                             , perc_bc_oper_prop    = est_row_Imp_ItemNf.perc_bc_oper_prop
                             , estado_id            = est_row_Imp_ItemNf.estado_id
                             , vl_bc_st_dest        = est_row_Imp_ItemNf.vl_bc_st_dest
                             , vl_icmsst_dest       = est_row_Imp_ItemNf.vl_icmsst_dest
                             , Codstcidade_Id       = est_row_Imp_ItemNf.Codstcidade_Id
          where id = est_row_Imp_ItemNf.id;
         --
      end if;
      --
   end if;
   --
   <<sair_integr>>
   null;

exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_integr_Imp_ItemNf fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_Imp_ItemNf;

-------------------------------------------------------------------------------------------------------

-- Integra as informações do intermediário do serviço

procedure pkb_integr_nf_inter_serv ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                   , est_row_nf_inter_serv     in out nocopy  nf_inter_serv%rowtype )
is
   --
   vn_fase              number := 0;
   vn_loggenericonf_id    log_generico_nf.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_nfe_nao_integrar ( en_notafiscal_id => est_row_nf_inter_serv.notafiscal_id ) then
      --
      goto sair_integr;
      --
   end if;
   --
   vn_fase := 1.1;
   --
   if nvl(est_row_nf_inter_serv.notafiscal_id,0) = 0
      and nvl(est_log_generico_nf.count,0) = 0 then
      --
      vn_fase := 1.2;
      --
      gv_mensagem_log := 'Não informada a Nota Fiscal para registro do Intermediário do Serviço.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                  , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 2;
   --
   est_row_nf_inter_serv.cpf_cnpj     := trim(pk_csf.fkg_converte(est_row_nf_inter_serv.cpf_cnpj));
   --
   if est_row_nf_inter_serv.cpf_cnpj is not null
      and pk_csf.fkg_is_numerico ( ev_valor => est_row_nf_inter_serv.cpf_cnpj ) = false then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := 'O "CNPJ ou CPF do Intermediário do Serviço" ('||est_row_nf_inter_serv.cpf_cnpj||
                         ') deve conter somente números considerando os zeros à esquerda.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 2.2;
   --
   -- Valida CNPJ
   if trim(est_row_nf_inter_serv.cpf_cnpj) is not null
      and pk_csf.fkg_is_numerico ( ev_valor =>  est_row_nf_inter_serv.cpf_cnpj ) = true
      and nvl(pk_valida_docto.fkg_valida_cpf_cgc(ev_numero => est_row_nf_inter_serv.cpf_cnpj), 0) = 0 then
      --
      vn_fase := 2.3;
      --
      gv_mensagem_log := 'O "CNPJ ou CPF do Intermediário do Serviço" ('||est_row_nf_inter_serv.cpf_cnpj||') está inválido.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 2.4;
   -- Valida CNPJ
   if trim(est_row_nf_inter_serv.cpf_cnpj) is null then
      --
      vn_fase := 2.5;
      --
      gv_mensagem_log := 'O "CNPJ ou CPF do Intermediário do Serviço" deve ser informado.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 3;
   --
   if trim(pk_csf.fkg_converte(est_row_nf_inter_serv.nome)) is null then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := 'O "Nome do Intermediário do Serviço" deve ser informado.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   est_row_nf_inter_serv.nome         := trim(pk_csf.fkg_converte(est_row_nf_inter_serv.nome));
   est_row_nf_inter_serv.inscr_munic  := trim(pk_csf.fkg_converte(est_row_nf_inter_serv.inscr_munic));
   --
   vn_fase := 99;
   --
   if nvl(est_row_nf_inter_serv.notafiscal_id,0) > 0 then
      --
      if nvl(gn_tipo_integr, 0) = 1 then
         --
         vn_fase := 99.1;
         --
         select nfinterserv_seq.nextval
           into est_row_nf_inter_serv.id
           from dual;
         --
         vn_fase := 99.2;
         --
         insert into nf_inter_serv ( id
                                   , notafiscal_id
                                   , nome
                                   , inscr_munic
                                   , cpf_cnpj
                                   )
                            values ( est_row_nf_inter_serv.id
                                   , est_row_nf_inter_serv.notafiscal_id
                                   , est_row_nf_inter_serv.nome
                                   , est_row_nf_inter_serv.inscr_munic
                                   , est_row_nf_inter_serv.cpf_cnpj
                                   );
         --
      else
         --
         vn_fase := 99.3;
         --
         update nf_inter_serv set nome         = est_row_nf_inter_serv.nome
                                , inscr_munic  = est_row_nf_inter_serv.inscr_munic
                                , cpf_cnpj     = est_row_nf_inter_serv.cpf_cnpj
          where id = est_row_nf_inter_serv.id;
         --
      end if;
      --
   end if;
   --
   <<sair_integr>>
   null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_nfs.pkb_integr_nf_inter_serv fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_nf_inter_serv;

-------------------------------------------------------------------------------------------------------

-- Integra as informações dos Itens da Nota Fiscal de serviço - campos flex field
procedure pkb_int_itemnf_compl_serv_ff ( est_log_generico_nf   in out nocopy  dbms_sql.number_table
                                       , en_notafiscal_id      in             nota_fiscal.id%type
                                       , en_itemnf_id          in             item_nota_fiscal.id%type
                                       , ev_atributo           in             varchar2
                                       , ev_valor              in             varchar2 )
is
   --
   vn_fase                   number := 0;
   vn_loggenericonf_id       log_generico_nf.id%type;
   vn_dmtipocampo            ff_obj_util_integr.dm_tipo_campo%type;
   vv_mensagem               varchar2(1000) := null;
   vn_cidadebeficfiscal_id   cidade_befic_fiscal.id%type;
   vv_cd_cidadebeficfiscal   cidade_befic_fiscal.cd%type;
   vn_cidade_id              cidade.id%type;
   vn_qtde_itemnf            number := 0;
   vn_cdtpservreinf_id       item_nota_fiscal.tiposervreinf_id%type;
   vv_cdtpservreinf_cd       tipo_serv_reinf.cd%type;
   vv_dm_ind_cprb            item_nota_fiscal.dm_ind_cprb%type;
   vn_dm_mat_prop_terc       item_nota_fiscal.dm_mat_prop_terc%type;
   vn_vl_abat_nt             item_nota_fiscal.vl_abat_nt%type;
   --
begin
   --
   vn_fase := 1;
   --
   gv_mensagem_log := null;
   --
   if ev_atributo is null then
      --
      vn_fase := 2;
      --
      gv_mensagem_log := 'Complemento de Serviços dos Itens da Nota fiscal: "Atributo" deve ser informado.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => erro_de_validacao
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 3;
   --
   if ev_valor is null then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := 'Complemento de Serviços dos Itens da Nota fiscal: "VALOR" referente ao atributo deve ser informado.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => erro_de_validacao
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 4;
   --
   vv_mensagem := pk_csf.fkg_ff_verif_campos( ev_obj_name => 'VW_CSF_ITEMNF_COMPL_SERV_FF'
                                            , ev_atributo => ev_atributo
                                            , ev_valor    => ev_valor );
   --
   vn_fase := 4.1;
   --
   if vv_mensagem is not null then
      --
      vn_fase := 4.2;
      --
      gv_mensagem_log := vv_mensagem;
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => erro_de_validacao
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   else
      --
      vn_fase := 5;
      --
      vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo( ev_obj_name => 'VW_CSF_ITEMNF_COMPL_SERV_FF'
                                                         , ev_atributo => ev_atributo );
      --
      vn_fase := 6;
      --
      if ev_atributo = 'CD_CIDADE_BENEFIC_FISCAL' and ev_valor is not null then
         --
         vn_fase := 7;
         --
         if vn_dmtipocampo = 2 then -- tipo de campo = caractere
            --
            vn_fase := 8;
            --
            vv_cd_cidadebeficfiscal := pk_csf.fkg_ff_ret_vlr_caracter ( ev_obj_name => 'VW_CSF_ITEMNF_COMPL_SERV_FF'
                                                                      , ev_atributo => ev_atributo
                                                                      , ev_valor    => ev_valor );
            --
            vn_fase := 9;
            --
            vn_cidade_id := pk_csf.fkg_cidade_id_nf_id ( en_notafiscal_id => en_notafiscal_id );
            --
            vn_cidadebeficfiscal_id := pk_csf_nfs.fkg_cidadebeficfiscal_id ( en_cidade_id            => vn_cidade_id
                                                                           , ev_cd_cidadebeficfiscal => vv_cd_cidadebeficfiscal
                                                                           );
            --
            if nvl(vn_cidadebeficfiscal_id,0) = 0 then
               --
               vn_fase := 10;
               --
               gv_mensagem_log := 'Código do beneficio fiscal da cidade ('||ev_valor||') informado está inválido.';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                   , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                   , ev_resumo           => gv_mensagem_log
                                   , en_tipo_log         => erro_de_validacao
                                   , en_referencia_id    => gn_referencia_id
                                   , ev_obj_referencia   => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                      , est_log_generico_nf   => est_log_generico_nf );
               --
            end if;
            --
         else
            --
            vn_fase := 11;
            --
            gv_mensagem_log := 'Para o atributo CD_CIDADE_BENEFIC_FISCAL, o VALOR informado não confere com o tipo de campo, deveria ser CARACTERE.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                , ev_resumo           => gv_mensagem_log
                                , en_tipo_log         => erro_de_validacao
                                , en_referencia_id    => gn_referencia_id
                                , ev_obj_referencia   => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                   , est_log_generico_nf => est_log_generico_nf );
            --
         end if;
         --
      elsif ev_atributo = 'CD_TP_SERV_REINF' and ev_valor is not null then
         --
         vn_fase := 12;
         --
         if vn_dmtipocampo = 2 then -- tipo de campo = caractere
            --
            vn_fase := 13;
            --
            vv_cdtpservreinf_cd := trim(pk_csf.fkg_ff_ret_vlr_caracter ( ev_obj_name => 'VW_CSF_ITEMNF_COMPL_SERV_FF'
                                                                       , ev_atributo => trim(ev_atributo)
                                                                       , ev_valor    => trim(ev_valor) ) );
            vn_fase := 14;
            --
            vn_cdtpservreinf_id := pk_csf_reinf.fkg_tipo_serv_reinf_id ( ev_cd => vv_cdtpservreinf_cd );
            --
            if nvl(vn_cdtpservreinf_id,0) = 0 then
               --
               vn_fase := 15;
               --
               gv_mensagem_log := 'Código identificador da classificação do serviço do Reinf ('|| vv_cdtpservreinf_cd ||'), está inválido.';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                   , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                   , ev_resumo           => gv_mensagem_log
                                   , en_tipo_log         => erro_de_validacao
                                   , en_referencia_id    => gn_referencia_id
                                   , ev_obj_referencia   => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                      , est_log_generico_nf   => est_log_generico_nf );
               --
            end if;
            --
         else
            --
            vn_fase := 16;
            --
            gv_mensagem_log := 'Para o atributo CD_TP_SERV_REINF, o VALOR informado não confere com o tipo de campo, deveria ser CARACTERE.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                , ev_resumo           => gv_mensagem_log
                                , en_tipo_log         => erro_de_validacao
                                , en_referencia_id    => gn_referencia_id
                                , ev_obj_referencia   => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                   , est_log_generico_nf => est_log_generico_nf );
            --
         end if;
         --
      elsif ev_atributo = 'DM_IND_CPRB' and ev_valor is not null then
         --
         vn_fase := 17;
         --
         if vn_dmtipocampo = 2 then -- tipo de campo = caractere
            --
            vn_fase := 18;
            --
            vv_dm_ind_cprb := trim(pk_csf.fkg_ff_ret_vlr_caracter ( ev_obj_name => 'VW_CSF_ITEMNF_COMPL_SERV_FF'
                                                                  , ev_atributo => trim(ev_atributo)
                                                                  , ev_valor    => trim(ev_valor) ) );
            vn_fase := 19;
            --
            if trim(vv_dm_ind_cprb) is not null
               and vv_dm_ind_cprb not in ('0', '1')
               then
               --
               vn_fase := 20;
               --
               gv_mensagem_log := 'Indicador de CPRB ('|| vv_dm_ind_cprb ||'), está inválido.';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                   , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                   , ev_resumo           => gv_mensagem_log
                                   , en_tipo_log         => erro_de_validacao
                                   , en_referencia_id    => gn_referencia_id
                                   , ev_obj_referencia   => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                      , est_log_generico_nf   => est_log_generico_nf );
               --
            end if;
            --
         else
            --
            vn_fase := 21;
            --
            gv_mensagem_log := 'Para o atributo DM_IND_CPRB, o VALOR informado não confere com o tipo de campo, deveria ser CARACTERE.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                , ev_resumo           => gv_mensagem_log
                                , en_tipo_log         => erro_de_validacao
                                , en_referencia_id    => gn_referencia_id
                                , ev_obj_referencia   => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                   , est_log_generico_nf => est_log_generico_nf );
            --
         end if;
         --
      elsif ev_atributo = 'DM_MAT_PROP_TERC' and ev_valor is not null then
         --
         vn_fase := 22;
         --
         if vn_dmtipocampo = 1 then -- tipo de campo = numérico
            --
            vn_fase := 23;
            --
            vn_dm_mat_prop_terc := trim(pk_csf.fkg_ff_ret_vlr_caracter ( ev_obj_name => 'VW_CSF_ITEMNF_COMPL_SERV_FF'
                                                                       , ev_atributo => trim(ev_atributo)
                                                                       , ev_valor    => trim(ev_valor) ) );
            vn_fase := 24;
            --
            if trim(vn_dm_mat_prop_terc) is not null
               and vn_dm_mat_prop_terc not in (0, 1)
               then
               --
               vn_fase := 25;
               --
               gv_mensagem_log := 'Indicador do Material utilizado ('|| vn_dm_mat_prop_terc ||'), está inválido. Valores válidos: 0-Próprio, 1-Terceiro.';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                   , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                   , ev_resumo           => gv_mensagem_log
                                   , en_tipo_log         => erro_de_validacao
                                   , en_referencia_id    => gn_referencia_id
                                   , ev_obj_referencia   => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                      , est_log_generico_nf   => est_log_generico_nf );
               --
            end if;
            --
         else
            --
            vn_fase := 26;
            --
            gv_mensagem_log := 'Para o atributo DM_MAT_PROP_TERC, o VALOR informado não confere com o tipo de campo, deveria ser NUMÉRICO.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                , ev_resumo           => gv_mensagem_log
                                , en_tipo_log         => erro_de_validacao
                                , en_referencia_id    => gn_referencia_id
                                , ev_obj_referencia   => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                   , est_log_generico_nf => est_log_generico_nf );
            --
         end if;
         --
      elsif ev_atributo = 'VL_ABAT_NT' and ev_valor is not null then
         --
         vn_fase := 27;
         --
         if vn_dmtipocampo = 1 then -- tipo de campo = numérico
            --
            vn_fase := 28;
            --
            vn_vl_abat_nt := trim(pk_csf.fkg_ff_ret_vlr_caracter ( ev_obj_name => 'VW_CSF_ITEMNF_COMPL_SERV_FF'
                                                                 , ev_atributo => trim(ev_atributo)
                                                                 , ev_valor    => trim(ev_valor) ) );
            --
         else
            --
            vn_fase := 29;
            --
            gv_mensagem_log := 'Para o atributo VL_ABAT_NT, o VALOR informado não confere com o tipo de campo, deveria ser NUMÉRICO.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                , ev_resumo           => gv_mensagem_log
                                , en_tipo_log         => erro_de_validacao
                                , en_referencia_id    => gn_referencia_id
                                , ev_obj_referencia   => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                   , est_log_generico_nf => est_log_generico_nf );
            --
         end if;
         --
      else
         --
         vn_fase := 30;
         --
         gv_mensagem_log := '"Atributo" ('||ev_atributo||') e "VALOR" ('||ev_valor||') relacionados, não especificados no processo.';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                             , ev_resumo            => gv_mensagem_log
                             , en_tipo_log          => ERRO_DE_VALIDACAO
                             , en_referencia_id     => gn_referencia_id
                             , ev_obj_referencia    => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                                , est_log_generico_nf  => est_log_generico_nf );
         --
      end if;
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_log_generico_nf.count,0) > 0 and
      fkg_ver_erro_log_generico_nfs( en_nota_fiscal_id => en_notafiscal_id ) = 1 then
      --
      vn_fase := 99.1;
      --
      update nota_fiscal set dm_st_proc = 10
       where id = en_notafiscal_id;
      --
   end if;
   --
   vn_fase := 99.2;
   --
   if nvl(en_itemnf_id,0) > 0 and
      ev_atributo = 'CD_CIDADE_BENEFIC_FISCAL' and
      nvl(vn_cidadebeficfiscal_id,0) > 0 and
      gv_mensagem_log is null then
      --
      vn_fase := 99.3;
      --
      begin
         --
         select count(1)
           into vn_qtde_itemnf
           from itemnf_compl_serv
          where itemnf_id = en_itemnf_id;
         --
      exception
         when others then
         vn_qtde_itemnf := 0;
      end;
      --
      vn_fase := 99.4;
      --
      if nvl(vn_qtde_itemnf,0) > 0 then
         --
         update itemnf_compl_serv ics
            set ics.cidadebeneficfiscal_id = vn_cidadebeficfiscal_id
          where ics.itemnf_id = en_itemnf_id;
         --
      else
         --
         insert into itemnf_compl_serv ( itemnf_id
                                       , dm_loc_exe_serv
                                       , dm_trib_mun_prest
                                       , cidadebeneficfiscal_id
                                       )
                                values
                                       ( en_itemnf_id -- notafiscal_id
                                       , 0 -- dm_loc_exe_serv
                                       , 0 -- dm_trib_mun_prest
                                       , vn_cidadebeficfiscal_id -- cidadebeneficfiscal_id
                                       );
         --
      end if;
      --
   end if;
   --
   vn_fase := 99.5;
   --
   if nvl(en_itemnf_id,0) > 0 and
      ev_atributo = 'CD_TP_SERV_REINF' and
      nvl(vn_cdtpservreinf_id,0) > 0 and
      gv_mensagem_log is null then
      --
      vn_fase := 99.6;
      --
      update item_nota_fiscal inf
         set inf.tiposervreinf_id = vn_cdtpservreinf_id
       where inf.id = en_itemnf_id;
      --
   end if;
   --
   vn_fase := 99.7;
   --
   if nvl(en_itemnf_id,0) > 0 and
      ev_atributo = 'DM_IND_CPRB' and
      trim(vv_dm_ind_cprb) in ('0','1') and
      gv_mensagem_log is null then
      --
      vn_fase := 99.8;
      --
      update item_nota_fiscal inf
         set inf.dm_ind_cprb = vv_dm_ind_cprb
       where inf.id = en_itemnf_id;
      --
   end if;
   --
   vn_fase := 99.9;
   --
   if nvl(en_itemnf_id,0) > 0 and
      ev_atributo = 'DM_MAT_PROP_TERC' and
      trim(vn_dm_mat_prop_terc) in (0,1) and
      gv_mensagem_log is null then
      --
      vn_fase := 99.10;
      --
      update item_nota_fiscal inf
         set inf.dm_mat_prop_terc = vn_dm_mat_prop_terc
       where inf.id = en_itemnf_id;
      --
   end if;
   --
   vn_fase := 99.11;
   --
   if nvl(en_itemnf_id,0) > 0 and
      ev_atributo = 'VL_ABAT_NT' and
      vn_vl_abat_nt is not null and
      gv_mensagem_log is null then
      --
      vn_fase := 99.12;
      --
      update item_nota_fiscal inf
         set inf.vl_abat_nt = vn_vl_abat_nt
       where inf.id = en_itemnf_id;
      --
   end if;
   --
   vn_fase := 100;
   --
   <<sair_integr>>
   null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_nfs.pkb_int_itemnf_compl_serv_ff fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                             , ev_resumo            => gv_mensagem_log
                             , en_tipo_log          => ERRO_DE_SISTEMA
                             , en_referencia_id     => gn_referencia_id
                             , ev_obj_referencia    => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_int_itemnf_compl_serv_ff;

-------------------------------------------------------------------------------------------------------

--| Procedimento de integração do complemento dos itens da nota fiscal de serviço
procedure pkb_integr_itemnf_compl_serv ( est_log_generico_nf       in out nocopy dbms_sql.number_table
                                       , est_row_nfserv_item_compl in out nocopy itemnf_compl_serv%rowtype
                                       , en_notafiscal_id          in            nota_fiscal.id%type
                                       , ev_cod_bc_cred_pc         in            base_calc_cred_pc.cd%type
                                       , ev_cod_ccus               in            centro_custo.cod_ccus%type
                                       , ev_cod_trib_municipio     in            cod_trib_municipio.cod_trib_municipio%type default null )
is
   --
   vn_fase               number := 0;
   vn_loggenericonf_id   log_generico_nf.id%TYPE;
   vn_cidade_id          cidade.id%type;
   vv_ibge_cidade_empr   cidade.ibge_cidade%type;
   vv_cod_mod            mod_fiscal.cod_mod%type;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_nfe_nao_integrar ( en_notafiscal_id => en_notafiscal_id ) then
      --
      goto sair_integr;
      --
   end if;
   --
   vn_fase := 1.1;
   --
   if nvl(est_row_nfserv_item_compl.itemnf_id,0) = 0
      and nvl(est_log_generico_nf.count,0) = 0
      --and gt_row_nota_fiscal.dm_ind_emit = 1 -- Terceiros
      then
      --
      vn_fase := 1.2;
      --
      gv_mensagem_log := 'Não informada a Nota Fiscal para registro de Complemento de Item de Serviço.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                  , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 2;
   --
   -- Recuperar base de cálculo
   est_row_nfserv_item_compl.basecalccredpc_id := pk_csf_efd_pc.fkg_base_calc_cred_pc_id ( ev_cd => lpad(ev_cod_bc_cred_pc, 2, '0') );
   --
   vn_fase := 2.1;
   --
   if nvl(est_row_nfserv_item_compl.basecalccredpc_id,0) <= 0
      and ev_cod_bc_cred_pc is not null
      and gt_row_nota_fiscal.dm_ind_emit = 1 -- Terceiros
      then
      --
      vn_fase := 2.2;
      --
      gv_mensagem_log := '"Código da Base de Cálculo do Crédito" inválido ('||ev_cod_bc_cred_pc||').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => erro_de_validacao
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                     , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 2.3;
   --
   -- Valida os códigos de "Base de Càlculo do Crédito" inválidos para Serviço
   if ev_cod_bc_cred_pc not in ('03', '05', '06', '07', '13', '15', '16', '17')
      and ev_cod_bc_cred_pc is not null
      then
      --
      vn_fase := 2.4;
      --
      gv_mensagem_log := '"Código da Base de Cálculo do Crédito" inválido para serviço ('||ev_cod_bc_cred_pc||').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => erro_de_validacao
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                     , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 3;
   --
   if est_row_nfserv_item_compl.dm_ind_orig_cred is not null
      and nvl(est_row_nfserv_item_compl.dm_ind_orig_cred,-1) not in (0,1)
      then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := '"Indicador da Origem do Crédito" inválido para serviço ('||est_row_nfserv_item_compl.dm_ind_orig_cred||').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => erro_de_validacao
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                     , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 4;
   --
   if est_row_nfserv_item_compl.dm_loc_exe_serv not in (0,1) then
      --
      vn_fase := 5;
      --
      gv_mensagem_log := '"Local de execução do serviço" inválido (' || est_row_nfserv_item_compl.dm_loc_exe_serv || '), deve ser 0-Executado no país, ou 1-Executado no exterior.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => erro_de_validacao
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                     , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 6;
   -- Recuperar centro de custo
   est_row_nfserv_item_compl.centrocusto_id := pk_csf.fkg_centro_custo_id ( ev_cod_ccus    => ev_cod_ccus
                                                                          , en_empresa_id  => gn_empresa_id );
   --
   vn_fase := 7;
   --
   if nvl(est_row_nfserv_item_compl.dm_trib_mun_prest,0) not in (0, 1) then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := '"Indicador de Tributação no Município do Prestador" está inválido ('|| nvl(est_row_nfserv_item_compl.dm_trib_mun_prest,0) ||').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => erro_de_validacao
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                     , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 8.1;
   --
   begin
      --
      select p.cidade_id
        into vn_cidade_id
        from empresa  e
           , pessoa   p
       where e.id     = gt_row_nota_fiscal.empresa_id
         and p.id     = e.pessoa_id;
      --
   exception
      when others then
         vn_cidade_id := null;
   end;
   --
   vn_fase := 8.2;
   --
   est_row_nfserv_item_compl.codtribmunicipio_id := pk_csf.fkg_codtribmunicipio_id ( ev_codtribmunicipio_cd  => trim(ev_cod_trib_municipio)
                                                                                   , en_cidade_id            => vn_cidade_id
                                                                                   );
   --
   vn_fase := 8.3;
   --
   -- DM_IND_EMIT 0-PROPRIA; 1-TERCEIROS 
   IF gt_row_nota_fiscal.dm_ind_emit = 0 THEN 
   if pk_csf_nfs.fkg_cidade_obrig_codtribmun(vn_cidade_id) and nvl(est_row_nfserv_item_compl.codtribmunicipio_id,0) <= 0 then
      --
      vn_fase := 8.4;
      --
      gv_mensagem_log := 'O código de tributação do município é obrigatório, não pode estar vazio.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => erro_de_validacao
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 8.5;
   --
   if trim(ev_cod_trib_municipio) is not null and nvl(est_row_nfserv_item_compl.codtribmunicipio_id,0) <= 0 then
      --
      vn_fase := 8.6;
      --
      gv_mensagem_log := 'O código de tributação do município informado (' || ev_cod_trib_municipio || '), não é válido para cidade do emitente (' || pk_csf.fkg_cidade_descr (vn_cidade_id) || ').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                          , ev_mensagem         => gv_cabec_log
                          , ev_resumo           => gv_mensagem_log
                          , en_tipo_log         => erro_de_validacao
                          , en_referencia_id    => gn_referencia_id
                          , ev_obj_referencia   => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   END IF;
   --
   vn_fase := 9;
   --
   if nvl(est_row_nfserv_item_compl.vl_desc_incondicionado,0) < 0 then
      --
      vn_fase := 9.1;
      --
      gv_mensagem_log := '"Valor do desconto incondicionado" não pode ser negativo ('|| nvl(est_row_nfserv_item_compl.vl_desc_incondicionado,0) ||').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => erro_de_validacao
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                     , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 10;
   --
   if nvl(est_row_nfserv_item_compl.vl_desc_condicionado,0) < 0 then
      --
      vn_fase := 10.1;
      --
      gv_mensagem_log := '"Valor do desconto condicionado" não pode ser negativo ('|| nvl(est_row_nfserv_item_compl.vl_desc_condicionado,0) ||').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => erro_de_validacao
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                     , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 11;
   --
   if nvl(est_row_nfserv_item_compl.vl_deducao,0) < 0 then
      --
      vn_fase := 11.1;
      --
      gv_mensagem_log := '"Valor das deduções para redução da base de cálculo de ISS" não pode ser negativo ('|| nvl(est_row_nfserv_item_compl.vl_deducao,0) ||').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => erro_de_validacao
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                     , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 12;
   --
   if nvl(est_row_nfserv_item_compl.vl_outra_ret,0) < 0 then
      --
      vn_fase := 12.1;
      --
      gv_mensagem_log := '"Valor outras retenções na fonte" não pode ser negativo ('|| nvl(est_row_nfserv_item_compl.vl_outra_ret,0) ||').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                  , ev_mensagem        => gv_cabec_log
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => erro_de_validacao
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                     , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 13;
   --
   est_row_nfserv_item_compl.cnae := trim(pk_csf.fkg_converte( replace(replace(replace(est_row_nfserv_item_compl.cnae, '.', ''), '-', ''), '/', '') ));
   --
   -- Validação da exigência do CNAE
   -- O campo CNAE vinculado ao item da nota fiscal não pode ser nulo se:
   -- A nota fiscal de serviço de emissão própria (nota_fiscal.dm_ind_emit=0)
   if gt_row_nota_fiscal.dm_ind_emit = 0 then
      -- A nota fiscal de serviço sem armazenamento (nota_fiscal.dm_arm_nfe_terc=0)
      if gt_row_nota_fiscal.dm_arm_nfe_terc = 0 then
         -- A nota fiscal de serviço de modelo "99" (nota_fiscal.modfiscal_id, mod_fiscal.cod_mod=99)
         begin
            select mf.cod_mod
              into vv_cod_mod
              from nota_fiscal nf
                 , mod_fiscal  mf
             where nf.id = en_notafiscal_id
               and mf.id = nf.modfiscal_id;
         exception
            when others then
               vv_cod_mod := '99';
         end;
         --
         --if gv_cod_mod = '99' then
         if vv_cod_mod = '99' then
            -- verificar se a cidade da pessoa vinculada a empresa é de Campinas (cidade.ibge_cidade=3509502)
            begin
               select cid.ibge_cidade
                 into vv_ibge_cidade_empr
                 from empresa  e
                    , pessoa   p
                    , cidade   cid
                where e.id     = gn_empresa_id -- vn_empresa_id
                  and p.id     = e.pessoa_id
                  and cid.id   = p.cidade_id;
            exception
               when others then
                  vv_ibge_cidade_empr := null;
            end;
            --
            --if gv_ibge_cidade_empr = '3509502' then
            if vv_ibge_cidade_empr = '3509502' then
               -- a cidade sendo de Campinas, verificar se o parão é SIAFI, e se está habilitado como SIM (dm_padrao=4, dm_habil=1)
               if pk_csf_nfs.fkg_empresa_cidade_nfse_habil ( en_empresa_id => gn_empresa_id ) = 1 then
                  if pk_csf_nfs.fkg_empresa_cidade_nfse_padrao ( en_empresa_id => gn_empresa_id ) = 4 then
                     -- atendendo as condições acima, exigir o código CNAE, e caso não tenha informação gerar mensagem/log indicando o motivo da exigência e deixando
                     -- a nota fiscal de serviço com erro de validação (itemnf_compl_serv.cnae).
                     if est_row_nfserv_item_compl.cnae is null then
                        --
                        vn_fase := 13.01;
                        --
                        gv_mensagem_log := '"O CNAE para a cidade de Campinas não pode ser nulo para as notas fiscais de serviço de emissão própria, sem armazenamento, modelo "99", padrão SIAFI e habilitadas". Valor CNAE: ('|| est_row_nfserv_item_compl.cnae ||').';
                        --
                        vn_loggenericonf_id := null;
                        --
                        pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                            , ev_mensagem          => gv_cabec_log
                                            , ev_resumo            => gv_mensagem_log
                                            , en_tipo_log          => erro_de_validacao
                                            , en_referencia_id     => gn_referencia_id
                                            , ev_obj_referencia    => gv_obj_referencia );
                        --
                        -- Armazena o "loggenerico_id" na memória
                        pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                                               , est_log_generico_nf  => est_log_generico_nf );
                        --
                     end if;
                  end if;
               end if;
            end if;
         end if;
      end if;
   end if;
   --
   vn_fase := 99;
   --
   est_row_nfserv_item_compl.dm_loc_exe_serv := nvl(est_row_nfserv_item_compl.dm_loc_exe_serv,0);
   est_row_nfserv_item_compl.dm_trib_mun_prest := nvl(est_row_nfserv_item_compl.dm_trib_mun_prest,0);
   --
   if nvl(est_row_nfserv_item_compl.vl_desc_incondicionado,0) <= 0 then
      est_row_nfserv_item_compl.vl_desc_incondicionado := null;
   end if;
   --
   if nvl(est_row_nfserv_item_compl.vl_desc_condicionado,0) <= 0 then
      est_row_nfserv_item_compl.vl_desc_condicionado := null;
   end if;
   --
   if nvl(est_row_nfserv_item_compl.vl_deducao,0) <= 0 then
      est_row_nfserv_item_compl.vl_deducao := null;
   end if;
   --
   if nvl(est_row_nfserv_item_compl.vl_outra_ret,0) <= 0 then
      est_row_nfserv_item_compl.vl_outra_ret := null;
   end if;
   --
   if nvl(est_row_nfserv_item_compl.itemnf_id,0) > 0
      then
      -- Se for tipo de integração igual a 1 insere
      if nvl(gn_tipo_integr, 0) = 1 then
         --
         vn_fase := 99.1;
         --
         insert into itemnf_compl_serv ( itemnf_id
                                       , basecalccredpc_id
                                       , dm_ind_orig_cred
                                       , dt_pag_pis
                                       , dt_pag_cofins
                                       , dm_loc_exe_serv
                                       , centrocusto_id
                                       , dm_trib_mun_prest
                                       , codtribmunicipio_id
                                       , vl_desc_incondicionado
                                       , vl_desc_condicionado
                                       , vl_deducao
                                       , vl_outra_ret
                                       , cnae
                                       , cidade_id
                                       )
                                values ( est_row_nfserv_item_compl.itemnf_id
                                       , est_row_nfserv_item_compl.basecalccredpc_id
                                       , est_row_nfserv_item_compl.dm_ind_orig_cred
                                       , est_row_nfserv_item_compl.dt_pag_pis
                                       , est_row_nfserv_item_compl.dt_pag_cofins
                                       , est_row_nfserv_item_compl.dm_loc_exe_serv
                                       , est_row_nfserv_item_compl.centrocusto_id
                                       , nvl(est_row_nfserv_item_compl.dm_trib_mun_prest,0)
                                       , est_row_nfserv_item_compl.codtribmunicipio_id
                                       , est_row_nfserv_item_compl.vl_desc_incondicionado
                                       , est_row_nfserv_item_compl.vl_desc_condicionado
                                       , est_row_nfserv_item_compl.vl_deducao
                                       , est_row_nfserv_item_compl.vl_outra_ret
                                       , est_row_nfserv_item_compl.cnae
                                       , est_row_nfserv_item_compl.cidade_id
                                       );
        --
      else
        --
        vn_fase := 99.2;
        --
        update itemnf_compl_serv ic
           set ic.basecalccredpc_id    = est_row_nfserv_item_compl.basecalccredpc_id
             , ic.dm_ind_orig_cred     = est_row_nfserv_item_compl.dm_ind_orig_cred
             , ic.dt_pag_pis           = est_row_nfserv_item_compl.dt_pag_pis
             , ic.dt_pag_cofins        = est_row_nfserv_item_compl.dt_pag_cofins
             , ic.dm_loc_exe_serv      = est_row_nfserv_item_compl.dm_loc_exe_serv
             , ic.centrocusto_id       = est_row_nfserv_item_compl.centrocusto_id
             , ic.dm_trib_mun_prest    = nvl(est_row_nfserv_item_compl.dm_trib_mun_prest,0)
             , ic.codtribmunicipio_id  = est_row_nfserv_item_compl.codtribmunicipio_id
             , vl_desc_incondicionado  = est_row_nfserv_item_compl.vl_desc_incondicionado
             , vl_desc_condicionado    = est_row_nfserv_item_compl.vl_desc_condicionado
             , vl_deducao              = est_row_nfserv_item_compl.vl_deducao
             , vl_outra_ret            = est_row_nfserv_item_compl.vl_outra_ret
             , cnae                    = est_row_nfserv_item_compl.cnae
             , cidade_id               = est_row_nfserv_item_compl.cidade_id
         where ic.itemnf_id = est_row_nfserv_item_compl.itemnf_id;
        --
      end if;
      --
   end if;
   --
   <<sair_integr>>
   null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_nfs.pkb_integr_itemnf_compl_serv fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%type;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem          => null
                             , ev_resumo            => gv_mensagem_log
                             , en_tipo_log          => erro_de_sistema
                             , en_referencia_id     => gn_referencia_id
                             , ev_obj_referencia    => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_itemnf_compl_serv;

-------------------------------------------------------------------------------------------------------

-- Integra as informações dos itens da nota fiscal
procedure pkb_integr_Item_Nota_Fiscal ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                      , est_row_Item_Nota_Fiscal  in out nocopy  Item_Nota_Fiscal%rowtype )
is
   --
   vn_fase              number := 0;
   vn_loggenericonf_id  log_generico_nf.id%TYPE;
   vn_tiposervico_id    tipo_servico.id%type;
   vn_natoper_id        nota_fiscal.natoper_id%type;
   vn_empresa_id        nota_fiscal.empresa_id%type;
   vn_cfop_id           nat_oper_serv.cfop_id%type;
   vn_dm_integr_item    empresa.dm_integr_item%type := null;
   vn_unidade_id_com    unidade.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_nfe_nao_integrar ( en_notafiscal_id => est_row_Item_Nota_Fiscal.notafiscal_id ) then
      --
      goto sair_integr;
      --
   end if;
   --
   vn_fase := 1.1;
   --
   gv_cabec_log_item := 'Item: ' || est_row_Item_Nota_Fiscal.cod_item || ' - ' || est_row_Item_Nota_Fiscal.descr_item || chr(10);
   --
   if nvl(est_row_Item_Nota_Fiscal.notafiscal_id,0) = 0
      and nvl(est_log_generico_nf.count,0) = 0 then
      --
      vn_fase := 1.2;
      --
      gv_mensagem_log := 'Não informada a Nota Fiscal para registro dos Produtos e Serviços.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 2;
   --
   -- Válida campo dm_ind_mov
   est_row_Item_Nota_Fiscal.dm_ind_mov := 0; -- Sim
   --
   vn_fase := 3;
   --
   -- Válidar o campo dm_mod_base_calc
   est_row_Item_Nota_Fiscal.dm_mod_base_calc := 0;
   --
   vn_fase := 4;
   --
   -- Válida a informação do campo dm_mod_base_calc_st
   est_row_Item_Nota_Fiscal.dm_mod_base_calc_st := 0;
   --
   vn_fase := 5;
   --
   -- Válida o campo nro_item
   if nvl(est_row_Item_Nota_Fiscal.nro_item,0) <= 0 then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := '"Número do ITEM da Nota Fiscal" (' || nvl(est_row_Item_Nota_Fiscal.nro_item,0)
                         || ') está inválido.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 6;
   --
   -- Válida o campo cod_item
   if trim( est_row_Item_Nota_Fiscal.cod_item ) is null then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := '"Código do produto ou serviço da Nota Fiscal" não informado.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   else
      --
      vn_fase := 6.2;
      -- com o "código do item" recupera do item_id
      est_row_Item_Nota_Fiscal.item_id := pk_csf.fkg_Item_id_conf_empr ( en_empresa_id  => gt_row_Nota_Fiscal.empresa_id
                                                                       , ev_cod_item    => est_row_Item_Nota_Fiscal.cod_item
                                                                       );
      --
   end if;
   --
   vn_fase := 7;
   --
   -- Válida se o campo item_id é válido (Produto/Serviço)
   if nvl(est_row_Item_Nota_Fiscal.item_id,0) > 0
      and pk_csf.fkg_item_id_valido ( en_item_id => est_row_Item_Nota_Fiscal.item_id ) = false then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := '"Código do produto ou serviço da Nota Fiscal" inválido.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 8;
   --
   -- Válida o campo descr_item
   if trim ( pk_csf.fkg_converte ( est_row_Item_Nota_Fiscal.descr_item ) ) is null then
      --
      vn_fase := 8.1;
      --
      gv_mensagem_log := '"Descrição do produto ou serviço da Nota Fiscal" deve ser informada.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 9;
   --
   -- Válida informação do campo cfop
   est_row_Item_Nota_Fiscal.cfop_id := pk_csf.fkg_cfop_id ( en_cd => est_row_Item_Nota_Fiscal.cfop );
   --
   vn_fase := 9.1;
   --
   if nvl(est_row_Item_Nota_Fiscal.cfop_id,0) = 0
      and gt_row_nota_fiscal.dm_ind_emit = 1 -- Terceiros
      then
      --
      vn_fase := 9.2;
      --
      gv_mensagem_log := '"CFOP do produto ou serviço da Nota Fiscal" está inválido (' || est_row_Item_Nota_Fiscal.cfop || ').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   else
      --
      begin
         select nf.natoper_id
              , nf.empresa_id
           into vn_natoper_id
              , vn_empresa_id
           from nota_fiscal nf
          where nf.id = est_row_Item_Nota_Fiscal.notafiscal_id;
      exception
         when others then
            vn_natoper_id := 0;
      end;
      --	  
      if nvl(est_row_Item_Nota_Fiscal.cfop_id,0) = 0
         and gt_row_nota_fiscal.dm_ind_emit = 0 -- emissão própria
         then
         --
         if nvl(vn_natoper_id,0) = 0 then
            --
            est_row_Item_Nota_Fiscal.cfop    := 1000;
            est_row_Item_Nota_Fiscal.cfop_id := pk_csf.fkg_cfop_id ( en_cd => est_row_Item_Nota_Fiscal.cfop );
            --
         else
            --
            begin
               select ns.cfop_id
                 into vn_cfop_id
                 from nat_oper_serv ns
                where ns.natoper_id = vn_natoper_id
                  and ns.empresa_id = vn_empresa_id;
            exception
               when others then
                  vn_cfop_id := 0;
            end;
            --
            if nvl(vn_cfop_id,0) = 0 then
               est_row_Item_Nota_Fiscal.cfop    := 1000;
               est_row_Item_Nota_Fiscal.cfop_id := pk_csf.fkg_cfop_id ( en_cd => est_row_Item_Nota_Fiscal.cfop );
            else
               est_row_Item_Nota_Fiscal.cfop_id := vn_cfop_id;
               est_row_Item_Nota_Fiscal.cfop    := pk_csf.fkg_cfop_cd(en_cfop_id => est_row_Item_Nota_Fiscal.cfop_id);
            end if;
            --
         end if;
         --
      end if;
      --
      if est_row_Item_Nota_Fiscal.cfop is null and est_row_Item_Nota_Fiscal.cfop_id is not null then	  
         --	  
         est_row_Item_Nota_Fiscal.cfop := pk_csf.fkg_cfop_cd(en_cfop_id => est_row_Item_Nota_Fiscal.cfop_id);
         --
      end if;		 
      --      	  
   end if;
   --
   vn_fase := 10;
   --
   -- Válida informação do campo orig
   est_row_Item_Nota_Fiscal.orig := 0; -- Nacional
   --
   vn_fase := 11;
   -- Código de Enquadramento Legal do IPI
   if trim ( est_row_Item_Nota_Fiscal.cod_enq_ipi ) is null then
      --
      est_row_Item_Nota_Fiscal.cod_enq_ipi := '999'; -- informar 999 enquanto a tabela não for criada, pela RFB
      --
   end if;
   --
   vn_fase := 12;
   --
   -- Válida informação de Quantidade Comercial
   if nvl(est_row_Item_Nota_Fiscal.qtde_Comerc,0) < 0 then
      --
      vn_fase := 12.1;
      --
      gv_mensagem_log := '"Quantidade Comercial" (' ||
                         est_row_Item_Nota_Fiscal.qtde_Comerc || ') não pode ser negativa.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 13;
   --
   -- Válida informação de Valor Unitário de comercialização
   if nvl(est_row_Item_Nota_Fiscal.vl_Unit_Comerc,0) < 0 then
      --
      vn_fase := 13.1;
      --
      gv_mensagem_log := '"Valor Unitário de comercialização" (' ||
                         est_row_Item_Nota_Fiscal.vl_Unit_Comerc || ') não pode ser negativo.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 14;
   --
   -- Válida a informação de Valor Total Bruto dos Produtos ou Serviços
   if nvl(est_row_Item_Nota_Fiscal.vl_Item_Bruto,0) < 0 then
      --
      vn_fase := 14.1;
      --
      gv_mensagem_log := '"Valor Total Bruto dos Produtos ou Serviços" (' ||
                         est_row_Item_Nota_Fiscal.vl_Item_Bruto || ') não pode ser negativo.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 15;
   --
   -- Válida a informação de Quantidade Tributável
   if nvl(est_row_Item_Nota_Fiscal.qtde_Trib,0) < 0 then
      --
      vn_fase := 15.1;
      --
      gv_mensagem_log := '"Quantidade Tributável" (' || est_row_Item_Nota_Fiscal.qtde_Trib || ') não pode ser negativa.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 16;
   --
   -- Válida a informação de Valor Unitário de tributação
   if nvl(est_row_Item_Nota_Fiscal.vl_Unit_Trib,0) < 0 then
      --
      vn_fase := 16.1;
      --
      gv_mensagem_log := '"Valor Unitário de tributação" (' || est_row_Item_Nota_Fiscal.vl_Unit_Trib || ') não pode ser negativo.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 17;
   --
   -- Válida a informação de Valor Total do Frete
   if nvl(est_row_Item_Nota_Fiscal.vl_Frete,0) < 0 then
      --
      vn_fase := 17.1;
      --
      gv_mensagem_log := '"Valor Total do Frete" (' || est_row_Item_Nota_Fiscal.vl_Frete || ') não pode ser negativo.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 18;
   --
   -- Válida a informação de Valor Total do Seguro
   if nvl(est_row_Item_Nota_Fiscal.vl_Seguro,0) < 0 then
      --
      vn_fase := 18.1;
      --
      gv_mensagem_log := '"Valor Total do Seguro" (' || est_row_Item_Nota_Fiscal.vl_Seguro || ') não pode ser negativo.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 19;
   --
   -- Válida a informação de Valor do Desconto
   if nvl(est_row_Item_Nota_Fiscal.vl_Desc,0) < 0 then
      --
      vn_fase := 19.1;
      --
      gv_mensagem_log := '"Valor do Desconto" (' || est_row_Item_Nota_Fiscal.vl_Desc || ') não pode ser negativo.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 20;
   -- Valida se a informação de Valor Total Bruto dos Produtos ou Serviços é maior ou igual a informação de Valor do Desconto
   if nvl(est_row_item_nota_fiscal.vl_item_bruto,0) < nvl(est_row_item_nota_fiscal.vl_desc,0) then
      --
      vn_fase := 20.1;
      --
      gv_mensagem_log := '"Valor Total Bruto dos Produtos ou Serviços" ('||est_row_item_nota_fiscal.vl_item_bruto||') não pode ser menor que o "Valor do '||
                         'Desconto" ('||est_row_item_nota_fiscal.vl_desc||').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 21;
   --
   -- Válida a informação de Valor das despesas aduaneiras
   if nvl(est_row_Item_Nota_Fiscal.vl_desp_adu,0) < 0 then
      --
      vn_fase := 21.1;
      --
      gv_mensagem_log := '"Valor das despesas aduaneiras" (' || est_row_Item_Nota_Fiscal.vl_desp_adu || ') não pode ser negativo.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   elsif nvl(est_row_Item_Nota_Fiscal.vl_desp_adu,0) <= 0 then
      est_row_Item_Nota_Fiscal.vl_desp_adu := 0;
   end if;
   --
   vn_fase := 22;
   -- Válida a informação de Valor do Imposto sobre Operações Financeiras
   if nvl(est_row_Item_Nota_Fiscal.vl_iof,0) < 0 then
      --
      vn_fase := 22.1;
      --
      gv_mensagem_log := '"Valor do Imposto sobre Operações Financeiras" (' ||
                         est_row_Item_Nota_Fiscal.vl_iof || ') não pode ser negativo.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   elsif nvl(est_row_Item_Nota_Fiscal.vl_iof,0) <= 0 then
      est_row_Item_Nota_Fiscal.vl_iof := 0;
   end if;
   --
   vn_fase := 23;
   --
   -- Válida informação do Indicador de Apuração do IPI
   --
   est_row_Item_Nota_Fiscal.dm_ind_apur_ipi := 0;
   --
   vn_fase := 24;
   -- Valida informação da Unidade Comercial
   est_row_Item_Nota_Fiscal.unid_com := 'UN';
   --
   vn_fase := 25;
   -- Valida informação da Unidade Comercial
   est_row_Item_Nota_Fiscal.unid_trib := 'UN';
   --
   vn_fase := 26;
   --
   if nvl(est_row_Item_Nota_Fiscal.vl_outro,0) < 0 then
      --
      vn_fase := 26.1;
      --
      gv_mensagem_log := '"Outras despesas acessórias" não pode ser negativa.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 27;
   --
   est_row_Item_Nota_Fiscal.dm_ind_tot := 0;
   --
   vn_fase := 28;
   --| Valida o código da Lista de Serviço
   vn_tiposervico_id := pk_csf.fkg_Tipo_Servico_id ( ev_cod_lst => est_row_Item_Nota_Fiscal.cd_lista_serv );
   --
   if nvl(vn_tiposervico_id,0) <= 0
      and gt_row_nota_fiscal.dm_ind_emit = 0 -- emissão propria
      then
      --
      vn_fase := 28.1;
      --
      gv_mensagem_log := '"Código da Lista de Serviço" está inválido('||est_row_Item_Nota_Fiscal.cd_lista_serv||
                         '). Deve ser informado para notas fiscais de emissão própria.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 29;
   --
   if not pk_csf.fkg_ibge_cidade ( ev_ibge_cidade => est_row_Item_Nota_Fiscal.cidade_ibge ) then
      --
      vn_fase := 29.1;
      --
      gv_mensagem_log := '"IBGE da Cidade de Prestação do Serviço" esta inválido (' || est_row_Item_Nota_Fiscal.cidade_ibge || ').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                       , ev_resumo          => gv_mensagem_log
                       , en_tipo_log        => ERRO_DE_VALIDACAO
                       , en_referencia_id   => gn_referencia_id
                       , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 30;
   --
   if nvl(est_row_Item_Nota_Fiscal.item_id,0) <= 0 then
      --
      vn_fase := 30.1;
      --
      -- verifica se a empresa integra o item, quando não existir no cadastro
      vn_dm_integr_item := pk_csf.fkg_integritem_conf_empresa ( en_empresa_id => vn_empresa_id );
      --
      if nvl(vn_dm_integr_item,0) = 1 then -- ira integrar o item
         --
         vn_fase := 30.2;
         vn_unidade_id_com := pk_csf.fkg_Unidade_id ( en_multorg_id => pk_csf.fkg_multorg_id_empresa ( en_empresa_id => vn_empresa_id )
                                                    , ev_sigla_unid => trim(est_row_Item_Nota_Fiscal.unid_com) );
         --
         vn_fase := 30.3;
         if nvl(vn_unidade_id_com,0) <= 0 then
            --
            vn_fase := 30.31;
            pk_csf_api_cad.gt_row_unidade:= null;
            --
            pk_csf_api_cad.gt_row_unidade.SIGLA_UNID := trim(est_row_Item_Nota_Fiscal.unid_com);
            pk_csf_api_cad.gt_row_unidade.DESCR      := 'Unidade: ' || trim(est_row_Item_Nota_Fiscal.unid_com);
            pk_csf_api_cad.gt_row_unidade.MULTORG_ID := pk_csf.fkg_multorg_id_empresa ( en_empresa_id => vn_empresa_id );
            pk_csf_api_cad.gt_row_unidade.DM_ST_PROC := 0;
            --
            vn_fase := 30.32;
            pk_csf_api_cad.pkb_integr_unid_med ( est_log_generico    => est_log_generico_nf
                                               , est_unidade         => pk_csf_api_cad.gt_row_unidade
                                               , en_empresa_id       => gt_row_nota_fiscal.empresa_id
                                               );
            --
         end if;
         --
         vn_fase := 30.4;
         pk_csf_api_cad.gt_row_item := null;
         pk_csf_api_cad.gt_row_item.cod_item      := trim(upper(est_row_Item_Nota_Fiscal.cod_item));
         pk_csf_api_cad.gt_row_item.descr_item    := trim(substr(est_row_Item_Nota_Fiscal.descr_item, 1, 120));
         pk_csf_api_cad.gt_row_item.dm_orig_merc  := est_row_Item_Nota_Fiscal.orig;
         pk_csf_api_cad.gt_row_item.cod_barra     := est_row_Item_Nota_Fiscal.cean;
         pk_csf_api_cad.gt_row_item.cod_ant_item  := null;
         pk_csf_api_cad.gt_row_item.aliq_icms     := 0;
         --
         vn_fase := 30.5;
         --
         pk_csf_api_cad.pkb_integr_item ( est_log_generico    => est_log_generico_nf
                                        , est_item            => pk_csf_api_cad.gt_row_item
                                        , en_multorg_id       => pk_csf.fkg_multorg_id_empresa ( en_empresa_id => vn_empresa_id )
                                        , ev_cpf_cnpj         => pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => pk_csf.fkg_empresa_id_matriz ( en_empresa_id => vn_empresa_id ) )
                                        , ev_sigla_unid       => est_row_Item_Nota_Fiscal.unid_com
                                        , ev_tipo_item        => '09' -- Serviços
                                        , ev_cod_ncm          => est_row_Item_Nota_Fiscal.cod_ncm
                                        , ev_cod_ex_tipi      => null
                                        , ev_tipo_servico     => null
                                        , ev_cest_cd          => est_row_Item_Nota_Fiscal.cod_cest
                                        );
         --
         vn_fase := 30.6;
         --
         if nvl(pk_csf_api_cad.gt_row_item.id,0) > 0
            and pk_csf.fkg_item_id_valido ( en_item_id => pk_csf_api_cad.gt_row_item.id ) = false
            then
            est_row_Item_Nota_Fiscal.item_id := null;
         else
            est_row_Item_Nota_Fiscal.item_id := pk_csf_api_cad.gt_row_item.id;
         end if;
         --
      end if;
      --
   end if;
   --
   vn_fase := 99;
   --
   -- Se não existe registro de Log e o Tipo de Integração é 1 (válida e integra)
   -- então registra a informação do Item da Nota Fiscal
   if nvl(est_log_generico_nf.count,0) > 0 and 
      fkg_ver_erro_log_generico_nfs( en_nota_fiscal_id => est_row_Item_Nota_Fiscal.notafiscal_id ) = 1 then
      --
      update nota_fiscal set dm_st_proc = 10
       where id = est_row_Item_Nota_Fiscal.notafiscal_id;
      --
   end if;
   --
   est_row_Item_Nota_Fiscal.cod_item         := trim( est_row_Item_Nota_Fiscal.cod_item );
   est_row_Item_Nota_Fiscal.cean             := trim( pk_csf.fkg_converte ( est_row_Item_Nota_Fiscal.cean ) );
   --
   est_row_Item_Nota_Fiscal.descr_item       := trim( pk_csf.fkg_converte ( ev_string            => est_row_Item_Nota_Fiscal.descr_item
                                                                          , en_remove_spc_extra  => 0
                                                                          , en_ret_tecla         => 0
                                                                          )
                                                     );
   --
   est_row_Item_Nota_Fiscal.cod_ncm          := trim( pk_csf.fkg_converte ( est_row_Item_Nota_Fiscal.cod_ncm ) );
   est_row_Item_Nota_Fiscal.genero           := trim( est_row_Item_Nota_Fiscal.genero );
   est_row_Item_Nota_Fiscal.cod_ext_ipi      := trim(est_row_Item_Nota_Fiscal.cod_ext_ipi);
   est_row_Item_Nota_Fiscal.Unid_Com         := trim( est_row_Item_Nota_Fiscal.Unid_Com );
   est_row_Item_Nota_Fiscal.qtde_Comerc      := nvl(est_row_Item_Nota_Fiscal.qtde_Comerc,0);
   est_row_Item_Nota_Fiscal.vl_Unit_Comerc   := nvl(est_row_Item_Nota_Fiscal.vl_Unit_Comerc,0);
   est_row_Item_Nota_Fiscal.vl_Item_Bruto    := nvl(est_row_Item_Nota_Fiscal.vl_Item_Bruto,0);
   est_row_Item_Nota_Fiscal.cean_Trib        := trim( pk_csf.fkg_converte ( est_row_Item_Nota_Fiscal.cean_Trib ) );
   est_row_Item_Nota_Fiscal.Unid_Trib        := trim( est_row_Item_Nota_Fiscal.Unid_Trib );
   est_row_Item_Nota_Fiscal.qtde_Trib        := nvl(est_row_Item_Nota_Fiscal.qtde_Trib,0);
   est_row_Item_Nota_Fiscal.vl_Unit_Trib     := nvl(est_row_Item_Nota_Fiscal.vl_Unit_Trib,0);
   est_row_Item_Nota_Fiscal.vl_Frete         := nvl(est_row_Item_Nota_Fiscal.vl_Frete,0);
   est_row_Item_Nota_Fiscal.vl_Seguro        := nvl(est_row_Item_Nota_Fiscal.vl_Seguro,0);
   est_row_Item_Nota_Fiscal.vl_Desc          := nvl(est_row_Item_Nota_Fiscal.vl_Desc,0);
   est_row_Item_Nota_Fiscal.infAdProd        := trim( pk_csf.fkg_converte ( est_row_Item_Nota_Fiscal.infAdProd ) );
   est_row_Item_Nota_Fiscal.dm_mod_base_calc := nvl(est_row_Item_Nota_Fiscal.dm_mod_base_calc,0);
   est_row_Item_Nota_Fiscal.cnpj_produtor    := lpad(trim( est_row_Item_Nota_Fiscal.cnpj_produtor ), 14, '0');
   est_row_Item_Nota_Fiscal.cl_enq_ipi       := trim( est_row_Item_Nota_Fiscal.cl_enq_ipi );
   est_row_Item_Nota_Fiscal.cod_selo_ipi     := trim( est_row_Item_Nota_Fiscal.cod_selo_ipi );
   est_row_Item_Nota_Fiscal.cod_enq_ipi      := trim( est_row_Item_Nota_Fiscal.cod_enq_ipi );
   est_row_Item_Nota_Fiscal.cd_lista_serv    := trim( est_row_Item_Nota_Fiscal.cd_lista_serv );
   est_row_Item_Nota_Fiscal.cod_cta          := trim( est_row_Item_Nota_Fiscal.cod_cta );
   est_row_Item_Nota_Fiscal.dm_ind_tot       := nvl(est_row_Item_Nota_Fiscal.dm_ind_tot, 1);
   est_row_Item_Nota_Fiscal.pedido_compra    := null;
   --
   if nvl(est_row_Item_Nota_Fiscal.notafiscal_id,0) > 0
      and nvl(est_row_Item_Nota_Fiscal.nro_item, 0) > 0
      and est_row_Item_Nota_Fiscal.cod_item is not null
      and est_row_Item_Nota_Fiscal.dm_ind_mov in (0, 1)
      and est_row_Item_Nota_Fiscal.descr_item is not null
      and nvl(est_row_Item_Nota_Fiscal.cfop_id,0) > 0
      and nvl(est_row_Item_Nota_Fiscal.cfop,0) > 0
      and nvl(est_row_Item_Nota_Fiscal.qtde_Comerc,0) >= 0
      and nvl(est_row_Item_Nota_Fiscal.vl_Unit_Comerc,0) >= 0
      and nvl(est_row_Item_Nota_Fiscal.vl_Item_Bruto,0) >= 0
      and nvl(est_row_Item_Nota_Fiscal.qtde_Trib,0) >= 0
      and nvl(est_row_Item_Nota_Fiscal.vl_Unit_Trib,0) >= 0
      and nvl(est_row_Item_Nota_Fiscal.dm_ind_tot,0) in (0, 1)
      then
      --
      if nvl(gn_tipo_integr, 0) = 1 then
         --
         vn_fase := 99.1;
         --
         select itemnf_seq.nextval
           into est_row_Item_Nota_Fiscal.id
           from dual;
         --
         vn_fase := 99.2;
         --         
         insert into Item_Nota_Fiscal ( id
                                      , notafiscal_id
                                      , item_id
                                      , nro_item
                                      , cod_item
                                      , dm_ind_mov
                                      , cean
                                      , descr_item
                                      , cod_ncm
                                      , genero
                                      , cod_ext_ipi
                                      , cfop_id
                                      , cfop
                                      , Unid_Com
                                      , qtde_Comerc
                                      , vl_Unit_Comerc
                                      , vl_Item_Bruto
                                      , cean_Trib
                                      , Unid_Trib
                                      , qtde_Trib
                                      , vl_Unit_Trib
                                      , vl_Frete
                                      , vl_Seguro
                                      , vl_Desc
                                      , infAdProd
                                      , orig
                                      , dm_mod_base_calc
                                      , dm_mod_base_calc_st
                                      , cnpj_produtor
                                      , qtde_selo_ipi
                                      , vl_desp_adu
                                      , vl_iof
                                      , classenqipi_id
                                      , cl_enq_ipi
                                      , selocontripi_id
                                      , cod_selo_ipi
                                      , cod_enq_ipi
                                      , cidade_ibge
                                      , cd_lista_serv
                                      , dm_ind_apur_ipi
                                      , cod_cta
                                      , vl_outro
                                      , dm_ind_tot
                                      , pedido_compra
                                      , item_pedido_compra
                                      , dm_mot_des_icms
                                      , dm_cod_trib_issqn
                                      )
                               values ( est_row_Item_Nota_Fiscal.id
                                      , est_row_Item_Nota_Fiscal.notafiscal_id
                                      , est_row_Item_Nota_Fiscal.item_id
                                      , est_row_Item_Nota_Fiscal.nro_item
                                      , est_row_Item_Nota_Fiscal.cod_item
                                      , est_row_Item_Nota_Fiscal.dm_ind_mov
                                      , est_row_Item_Nota_Fiscal.cean
                                      , est_row_Item_Nota_Fiscal.descr_item
                                      , est_row_Item_Nota_Fiscal.cod_ncm
                                      , est_row_Item_Nota_Fiscal.genero
                                      , est_row_Item_Nota_Fiscal.cod_ext_ipi
                                      , est_row_Item_Nota_Fiscal.cfop_id
                                      , est_row_Item_Nota_Fiscal.cfop
                                      , est_row_Item_Nota_Fiscal.Unid_Com
                                      , est_row_Item_Nota_Fiscal.qtde_Comerc
                                      , est_row_Item_Nota_Fiscal.vl_Unit_Comerc
                                      , est_row_Item_Nota_Fiscal.vl_Item_Bruto
                                      , est_row_Item_Nota_Fiscal.cean_Trib
                                      , est_row_Item_Nota_Fiscal.Unid_Trib
                                      , est_row_Item_Nota_Fiscal.qtde_Trib
                                      , est_row_Item_Nota_Fiscal.vl_Unit_Trib
                                      , est_row_Item_Nota_Fiscal.vl_Frete
                                      , est_row_Item_Nota_Fiscal.vl_Seguro
                                      , est_row_Item_Nota_Fiscal.vl_Desc
                                      , est_row_Item_Nota_Fiscal.infAdProd
                                      , est_row_Item_Nota_Fiscal.orig
                                      , est_row_Item_Nota_Fiscal.dm_mod_base_calc
                                      , est_row_Item_Nota_Fiscal.dm_mod_base_calc_st
                                      , est_row_Item_Nota_Fiscal.cnpj_produtor
                                      , est_row_Item_Nota_Fiscal.qtde_selo_ipi
                                      , est_row_Item_Nota_Fiscal.vl_desp_adu
                                      , est_row_Item_Nota_Fiscal.vl_iof
                                      , est_row_Item_Nota_Fiscal.classenqipi_id
                                      , est_row_Item_Nota_Fiscal.cl_enq_ipi
                                      , est_row_Item_Nota_Fiscal.selocontripi_id
                                      , est_row_Item_Nota_Fiscal.cod_selo_ipi
                                      , est_row_Item_Nota_Fiscal.cod_enq_ipi
                                      , est_row_Item_Nota_Fiscal.cidade_ibge
                                      , est_row_Item_Nota_Fiscal.cd_lista_serv
                                      , est_row_Item_Nota_Fiscal.dm_ind_apur_ipi
                                      , est_row_Item_Nota_Fiscal.cod_cta
                                      , est_row_Item_Nota_Fiscal.vl_outro
                                      , est_row_Item_Nota_Fiscal.dm_ind_tot
                                      , est_row_Item_Nota_Fiscal.pedido_compra
                                      , est_row_Item_Nota_Fiscal.item_pedido_compra
                                      , est_row_Item_Nota_Fiscal.dm_mot_des_icms
                                      , est_row_Item_Nota_Fiscal.dm_cod_trib_issqn
                                      );
         --
      else
         --
         vn_fase := 99.3;
         --
         update Item_Nota_Fiscal set item_id              = est_row_Item_Nota_Fiscal.item_id
                                   , nro_item             = est_row_Item_Nota_Fiscal.nro_item
                                   , cod_item             = est_row_Item_Nota_Fiscal.cod_item
                                   , dm_ind_mov           = est_row_Item_Nota_Fiscal.dm_ind_mov
                                   , cean                 = est_row_Item_Nota_Fiscal.cean
                                   , descr_item           = est_row_Item_Nota_Fiscal.descr_item
                                   , cod_ncm              = est_row_Item_Nota_Fiscal.cod_ncm
                                   , genero               = est_row_Item_Nota_Fiscal.genero
                                   , cod_ext_ipi          = est_row_Item_Nota_Fiscal.cod_ext_ipi
                                   , cfop_id              = est_row_Item_Nota_Fiscal.cfop_id
                                   , cfop                 = est_row_Item_Nota_Fiscal.cfop
                                   , Unid_Com             = est_row_Item_Nota_Fiscal.Unid_Com
                                   , qtde_Comerc          = est_row_Item_Nota_Fiscal.qtde_Comerc
                                   , vl_Unit_Comerc       = est_row_Item_Nota_Fiscal.vl_Unit_Comerc
                                   , vl_Item_Bruto        = est_row_Item_Nota_Fiscal.vl_Item_Bruto
                                   , cean_Trib            = est_row_Item_Nota_Fiscal.cean_Trib
                                   , Unid_Trib            = est_row_Item_Nota_Fiscal.Unid_Trib
                                   , qtde_Trib            = est_row_Item_Nota_Fiscal.qtde_Trib
                                   , vl_Unit_Trib         = est_row_Item_Nota_Fiscal.vl_Unit_Trib
                                   , vl_Frete             = est_row_Item_Nota_Fiscal.vl_Frete
                                   , vl_Seguro            = est_row_Item_Nota_Fiscal.vl_Seguro
                                   , vl_Desc              = est_row_Item_Nota_Fiscal.vl_Desc
                                   , infAdProd            = est_row_Item_Nota_Fiscal.infAdProd
                                   , orig                 = est_row_Item_Nota_Fiscal.orig
                                   , dm_mod_base_calc     = est_row_Item_Nota_Fiscal.dm_mod_base_calc
                                   , dm_mod_base_calc_st  = est_row_Item_Nota_Fiscal.dm_mod_base_calc_st
                                   , cnpj_produtor        = est_row_Item_Nota_Fiscal.cnpj_produtor
                                   , qtde_selo_ipi        = est_row_Item_Nota_Fiscal.qtde_selo_ipi
                                   , vl_desp_adu          = est_row_Item_Nota_Fiscal.vl_desp_adu
                                   , vl_iof               = est_row_Item_Nota_Fiscal.vl_iof
                                   , classenqipi_id       = est_row_Item_Nota_Fiscal.classenqipi_id
                                   , cl_enq_ipi           = est_row_Item_Nota_Fiscal.cl_enq_ipi
                                   , selocontripi_id      = est_row_Item_Nota_Fiscal.selocontripi_id
                                   , cod_selo_ipi         = est_row_Item_Nota_Fiscal.cod_selo_ipi
                                   , cod_enq_ipi          = est_row_Item_Nota_Fiscal.cod_enq_ipi
                                   , cidade_ibge          = est_row_Item_Nota_Fiscal.cidade_ibge
                                   , cd_lista_serv        = est_row_Item_Nota_Fiscal.cd_lista_serv
                                   , dm_ind_apur_ipi      = est_row_Item_Nota_Fiscal.dm_ind_apur_ipi
                                   , cod_cta              = est_row_Item_Nota_Fiscal.cod_cta
                                   , vl_outro             = est_row_Item_Nota_Fiscal.vl_outro
                                   , dm_ind_tot           = est_row_Item_Nota_Fiscal.dm_ind_tot
                                   , pedido_compra        = est_row_Item_Nota_Fiscal.pedido_compra
                                   , item_pedido_compra   = est_row_Item_Nota_Fiscal.item_pedido_compra
                                   , dm_mot_des_icms      = est_row_Item_Nota_Fiscal.dm_mot_des_icms
                                   , dm_cod_trib_issqn    = est_row_Item_Nota_Fiscal.dm_cod_trib_issqn
          where id = est_row_Item_Nota_Fiscal.id;
         --
      end if;
      --
   end if;
   --
   <<sair_integr>>
   null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_integr_Item_Nota_Fiscal fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_Item_Nota_Fiscal;

-------------------------------------------------------------------------------------------------------

--| Procedimento de integração da nota fiscal de serviço - complemento de serviço
procedure pkb_integr_nf_compl_serv ( est_log_generico_nf     in out nocopy dbms_sql.number_table
                                   , est_row_nfserv_compl in out nocopy nf_compl_serv%rowtype )
is
   --
   vn_fase            number := 0;
   vn_loggenericonf_id  log_generico_nf.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_nfe_nao_integrar ( en_notafiscal_id => est_row_nfserv_compl.notafiscal_id ) then
      --
      goto sair_integr;
      --
   end if;
   --
   vn_fase := 1.1;
   --
   if nvl(est_row_nfserv_compl.notafiscal_id,0) = 0
      and nvl(est_log_generico_nf.count,0) = 0 then
      --
      vn_fase := 1.2;
      --
      gv_mensagem_log := 'Não informada a Nota Fiscal para registro de complemento de serviço.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                  , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 2;
   --
   -- Valida o dominio de Natureza de Operação
   if est_row_nfserv_compl.dm_nat_oper is null then
      est_row_nfserv_compl.dm_nat_oper := 1;
   end if;
   --
   if nvl(est_row_nfserv_compl.dm_nat_oper,0) not in (1, 2, 3, 4, 5, 6, 7, 8)
      then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := '"Código de Natureza da Operação" está inválido (' || nvl(est_row_nfserv_compl.dm_nat_oper,0) || '). Valores válidos: '||
                         '1–Tributação do Município; 2–Tributação fora do município; 3–Isenção; 4–Imune; 5–Exigibilidade suspensa por decisão judicial; '||
                         '6–Exigibilidade suspensa por procedimento administrativo.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                  , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 3;
   -- Valida o dominio de Tipo de RPS
   if est_row_nfserv_compl.dm_tipo_rps is not null
      and nvl(est_row_nfserv_compl.dm_tipo_rps,0) not in (1, 2, 3)
      then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := '"Tipo de RPS" esta inválido (' || nvl(est_row_nfserv_compl.dm_tipo_rps,0) || ').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                  , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   if nvl(est_row_nfserv_compl.dm_tipo_rps,-1) = -1 then
      --
      est_row_nfserv_compl.dm_tipo_rps := 1;
      --
   end if;
   --
   vn_fase := 4;
   --
   if nvl(est_row_nfserv_compl.dm_status_rps,0) <= 0 then
      est_row_nfserv_compl.dm_status_rps := 1;
   end if;
   --
   -- Valida o dominio de status do serviço
   if est_row_nfserv_compl.dm_status_rps is not null
      and nvl(est_row_nfserv_compl.dm_status_rps,0) not in (1,2)
      then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := '"Status do RPS" esta inválido (' || nvl(est_row_nfserv_compl.dm_tipo_rps,0) || ').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                  , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   if nvl(est_row_nfserv_compl.nro_rps_subst,0) <= 0 then
      est_row_nfserv_compl.nro_rps_subst := null;
   end if;
   --
   est_row_nfserv_compl.serie_rps_subst := trim(pk_csf.fkg_converte(est_row_nfserv_compl.serie_rps_subst));
   --
   vn_fase := 99;
   --
   if nvl(est_row_nfserv_compl.notafiscal_id,0) > 0
      and (est_row_nfserv_compl.dm_nat_oper is null or nvl(est_row_nfserv_compl.dm_nat_oper,0) in (1, 2, 3, 4, 5, 6, 7, 8))
      and (est_row_nfserv_compl.dm_tipo_rps is null or nvl(est_row_nfserv_compl.dm_tipo_rps,0) in (1, 2, 3))
      and (est_row_nfserv_compl.dm_status_rps is null or nvl(est_row_nfserv_compl.dm_status_rps,0) in (1,2))
      then
      --
      vn_fase := 99.1;
      --
      -- Calcula a quantidade de registros Totais integrados para ser
      -- mostrado na tela de agendamento.
      --
      begin
         pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
      exception
         when others then
         null;
      end;
      --
      -- Se for tipo de integração igual a 1 insere
      if nvl(gn_tipo_integr, 0) = 1 then
         --
         vn_fase := 99.2;
         --
         insert into nf_compl_serv ( notafiscal_id
                                   , chv_nfse
                                   , dt_exe_serv
                                   , codigo_html_nfs
                                   , ret_nfs
                                   , cod_verif_nfs
                                   , nro_aut_nfs
                                   , dm_nat_oper
                                   , dt_emiss_nfs
                                   , dm_tipo_rps
                                   , dm_status_rps
                                   , nro_rps_subst
                                   , serie_rps_subst
                                   )
                            values ( est_row_nfserv_compl.notafiscal_id
                                   , est_row_nfserv_compl.chv_nfse
                                   , est_row_nfserv_compl.dt_exe_serv
                                   , est_row_nfserv_compl.codigo_html_nfs
                                   , est_row_nfserv_compl.ret_nfs
                                   , est_row_nfserv_compl.cod_verif_nfs
                                   , est_row_nfserv_compl.nro_aut_nfs
                                   , est_row_nfserv_compl.dm_nat_oper
                                   , est_row_nfserv_compl.dt_emiss_nfs
                                   , est_row_nfserv_compl.dm_tipo_rps
                                   , est_row_nfserv_compl.dm_status_rps
                                   , est_row_nfserv_compl.nro_rps_subst
                                   , est_row_nfserv_compl.serie_rps_subst
                                   );
         --
      else
         --
         vn_fase := 99.3;
         --
         update nf_compl_serv
            set chv_nfse         = est_row_nfserv_compl.chv_nfse
              , dt_exe_serv      = est_row_nfserv_compl.dt_exe_serv
              , codigo_html_nfs  = est_row_nfserv_compl.codigo_html_nfs
              , ret_nfs          = est_row_nfserv_compl.ret_nfs
              , cod_verif_nfs    = est_row_nfserv_compl.cod_verif_nfs
              , nro_aut_nfs      = est_row_nfserv_compl.nro_aut_nfs
              , dm_nat_oper      = est_row_nfserv_compl.dm_nat_oper
              , dt_emiss_nfs     = est_row_nfserv_compl.dt_emiss_nfs
              , dm_tipo_rps      = est_row_nfserv_compl.dm_tipo_rps
              , dm_status_rps    = est_row_nfserv_compl.dm_status_rps
              , nro_rps_subst    = est_row_nfserv_compl.nro_rps_subst
              , serie_rps_subst  = est_row_nfserv_compl.serie_rps_subst
          where notafiscal_id = est_row_nfserv_compl.notafiscal_id;
         --
      end if;
      --
   end if;
   --
   <<sair_integr>>
   null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_nfs.pkb_integr_nf_compl_serv fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%type;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                     , ev_mensagem        => null
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => erro_de_sistema
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_nf_compl_serv;

-------------------------------------------------------------------------------------------------------

-- Integra as informações da Nota Fiscal de serviço - campos flex field
procedure pkb_integr_nota_fiscal_serv_ff ( est_log_generico_nf   in out nocopy  dbms_sql.number_table
                                         , en_notafiscal_id      in             nota_fiscal.id%type
                                         , ev_atributo           in             varchar2
                                         , ev_valor              in             varchar2 )
is
   --
   vn_fase                 number := 0;
   vn_loggenericonf_id     log_generico_nf.id%type;
   vn_dmtipocampo          ff_obj_util_integr.dm_tipo_campo%type;
   vv_mensagem             varchar2(1000) := null;
   vn_cidademodfiscal_id   cidade_mod_fiscal.id%type;
   vv_cd_cidademodfiscal   cidade_mod_fiscal.cd%type;
   vn_cidade_id            cidade.id%type;
   vn_qtde_nf              number := 0;
   vn_dm_legado            nota_fiscal.dm_legado%type;
   vn_dm_st_proc           nota_fiscal.dm_st_proc%type;   
   vn_id_erp               nota_fiscal_compl.id_erp%type;
   vv_nro_aut_nfs          nf_compl_serv.nro_aut_nfs%type;
   vd_dt_emiss_nfs         nf_compl_serv.dt_emiss_nfs%type;
   vn_codnat_id            nat_oper.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   gv_mensagem_log := null;
   --
   if ev_atributo is null then
      --
      vn_fase := 2;
      --
      gv_mensagem_log := 'Nota Fiscal de Serviço: "Atributo" deve ser informado.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => erro_de_validacao
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   if ev_valor is null then
      --
      vn_fase := 3;
      --
      gv_mensagem_log := 'Nota Fiscal de Serviço: "VALOR" referente ao atributo deve ser informado.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => erro_de_validacao
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 4;
   --
   vv_mensagem := pk_csf.fkg_ff_verif_campos( ev_obj_name => 'VW_CSF_NOTA_FISCAL_SERV_FF'
                                            , ev_atributo => ev_atributo
                                            , ev_valor    => ev_valor );
   --
   vn_fase := 4.1;
   --
   if vv_mensagem is not null then
      --
      vn_fase := 4.2;
      --
      gv_mensagem_log := vv_mensagem;
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => erro_de_validacao
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   else
      --
      vn_fase := 5;
      --
      vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo( ev_obj_name => 'VW_CSF_NOTA_FISCAL_SERV_FF'
                                                         , ev_atributo => ev_atributo );
      --
      vn_fase := 6;
      --
      if ev_atributo = 'CD_CIDADE_MOD_FISCAL' and ev_valor is not null then
         --
         vn_fase := 7;
         --
         if vn_dmtipocampo = 2 then -- tipo de campo = caractere
            --
            vn_fase := 8;
            --
            vv_cd_cidademodfiscal := pk_csf.fkg_ff_ret_vlr_caracter ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_SERV_FF'
                                                                    , ev_atributo => ev_atributo
                                                                    , ev_valor    => ev_valor );
            --
            vn_fase := 9;
            --
            vn_cidade_id := pk_csf.fkg_cidade_id_nf_id ( en_notafiscal_id => en_notafiscal_id );
            --
            vn_cidademodfiscal_id := pk_csf_nfs.fkg_cidademodfiscal_id ( en_cidade_id          => vn_cidade_id
                                                                       , ev_cd_cidademodfiscal => vv_cd_cidademodfiscal
                                                                       );
            --
            if nvl(vn_cidademodfiscal_id,0) = 0 then
               --
               vn_fase := 14;
               --
               gv_mensagem_log := 'Modelo fiscal da cidade ('||ev_valor||') informado está inválido.';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                   , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                   , ev_resumo           => gv_mensagem_log
                                   , en_tipo_log         => erro_de_validacao
                                   , en_referencia_id    => gn_referencia_id
                                   , ev_obj_referencia   => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                      , est_log_generico_nf   => est_log_generico_nf );
               --
            end if;
            --
         else
            --
            vn_fase := 15;
            --
            gv_mensagem_log := 'Para o atributo CD_CIDADE_MOD_FISCAL, o VALOR informado não confere com o tipo de campo, deveria ser CARACTERE.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                , ev_resumo           => gv_mensagem_log
                                , en_tipo_log         => erro_de_validacao
                                , en_referencia_id    => gn_referencia_id
                                , ev_obj_referencia   => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                   , est_log_generico_nf => est_log_generico_nf );
            --
         end if;
         --
      elsif trim(ev_atributo) = 'DM_LEGADO' then
         --
         vn_fase := 20;
         --
         if trim(ev_valor) is not null then
            --
            vn_fase := 20.1;
            --
            if vn_dmtipocampo = 1 then -- tipo de campo = numérico
               --
               vn_fase := 20.2;
               --
               if trim(ev_valor) in ('0', '1', '2', '3', '4') then
                 --
                 vn_fase := 20.3;
                 --
                 vn_dm_legado := pk_csf.fkg_ff_ret_vlr_number ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_SERV_FF'
                                                              , ev_atributo => trim(ev_atributo)
                                                              , ev_valor    => trim(ev_valor)
                                                              );
                 --
               else
                   --
                   vn_fase := 20.4;
                   --
                   gv_mensagem_log := 'O valor do campo "NFSe de Legado" informado ('||ev_valor||') não é válido, deve ser 0-Não é Legado; 1-Legado Autorizado; 2-Legado Denegado; 3-Legado Cancelado; 4-Legado Inutilizado';
                   --
                   vn_loggenericonf_id := null;
                   --
                   pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                       , ev_mensagem       => gv_cabec_log
                                       , ev_resumo         => gv_mensagem_log
                                       , en_tipo_log       => erro_de_validacao
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia );
                   -- Armazena o "loggenerico_id" na memória
                   pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                       , est_log_generico_nf => est_log_generico_nf );
                   --
               end if;
               --
            else
               --
               vn_fase := 20.5;
               --
               gv_mensagem_log := 'O valor do campo "NFSe de Legado" informado não confere com o tipo de campo, deveria ser NUMÉRICO.';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                   , ev_mensagem       => gv_cabec_log
                                   , ev_resumo         => gv_mensagem_log
                                   , en_tipo_log       => erro_de_validacao
                                   , en_referencia_id  => gn_referencia_id
                                   , ev_obj_referencia => gv_obj_referencia );
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                   , est_log_generico_nf => est_log_generico_nf );
               --
            end if;
            --
         end if;
         --
      elsif trim(ev_atributo) = 'ID_ERP' then
         --
         vn_fase := 20;
         --
         if trim(ev_valor) is not null then
            --
            vn_fase := 20.1;
            --
            if vn_dmtipocampo = 1 then -- tipo de campo = numérico
               --
               vn_fase := 20.2;
               --
               if pk_csf.fkg_is_numerico( trim(ev_valor) ) then
                 --
                 vn_fase := 20.3;
                 --
                 vn_id_erp := pk_csf.fkg_ff_ret_vlr_number ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_SERV_FF'
                                                           , ev_atributo => trim(ev_atributo)
                                                           , ev_valor    => trim(ev_valor)
                                                           );
                 --
               else
                   --
                   vn_fase := 20.4;
                   --
                   gv_mensagem_log := 'O valor do campo "ID ERP" informado ('||ev_valor||') não é válido, deve conter apenas valores numéricos.';
                   --
                   vn_loggenericonf_id := null;
                   --
                   pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                       , ev_mensagem       => gv_cabec_log
                                       , ev_resumo         => gv_mensagem_log
                                       , en_tipo_log       => erro_de_validacao
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia );
                   -- Armazena o "loggenerico_id" na memória
                   pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                       , est_log_generico_nf => est_log_generico_nf );
                   --
               end if;
               --
            else
               --
               vn_fase := 20.5;
               --
               gv_mensagem_log := 'O valor do campo "ID ERP" informado não confere com o tipo de campo, deveria ser NUMÉRICO.';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                   , ev_mensagem       => gv_cabec_log
                                   , ev_resumo         => gv_mensagem_log
                                   , en_tipo_log       => erro_de_validacao
                                   , en_referencia_id  => gn_referencia_id
                                   , ev_obj_referencia => gv_obj_referencia );
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                   , est_log_generico_nf => est_log_generico_nf );
               --
            end if;
            --
         end if;
         --
      elsif trim(ev_atributo) = 'NRO_AUT_NFS' then
         --
         vn_fase := 21.1;
         --
         -- As de valor e tipo ja foram executadas pela function pk_csf.fkg_ff_verif_campos no inicio da rotina:
          vv_nro_aut_nfs := ev_valor;
         --
      elsif trim(ev_atributo) = 'DT_EMISS_NFS' then
         --
         vn_fase := 21.2;
         --
         -- As de valor e tipo ja foram executadas pela function pk_csf.fkg_ff_verif_campos no inicio da rotina:
         vd_dt_emiss_nfs := ev_valor;
         --
      elsif trim(ev_atributo) = 'COD_NAT_OPER' then
         --
         vn_fase := 21.3;
         --
         vn_codnat_id:= pk_csf_api_cad.fkg_natoper_id_cod_nat(ev_cod_nat    => ev_valor 
                                                             ,en_multorg_id => pk_integr_view_nfs.gn_multorg_id);
         --
      else
         --
         vn_fase := 28;
         --
         gv_mensagem_log := '"Atributo" ('||ev_atributo||') e "VALOR" ('||ev_valor||') relacionados, não especificados no processo.';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                             , ev_resumo            => gv_mensagem_log
                             , en_tipo_log          => ERRO_DE_VALIDACAO
                             , en_referencia_id     => gn_referencia_id
                             , ev_obj_referencia    => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                                , est_log_generico_nf  => est_log_generico_nf );
         --
      end if;
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_log_generico_nf.count,0) > 0 and
      fkg_ver_erro_log_generico_nfs( en_nota_fiscal_id => en_notafiscal_id ) = 1 then
      --
      vn_fase := 99.1;
      --
      update nota_fiscal
         set dm_st_proc = 10
       where id         = en_notafiscal_id;
      --
   end if;
   --
   vn_fase := 99.2;
   --
   if nvl(en_notafiscal_id,0) > 0 and
      ev_atributo = 'CD_CIDADE_MOD_FISCAL' and
      nvl(vn_cidademodfiscal_id,0) > 0 and
      gv_mensagem_log is null then
      --
      vn_fase := 99.3;
      --
      begin
         --
         select count(1)
           into vn_qtde_nf
           from nf_compl_serv
          where notafiscal_id = en_notafiscal_id;
         --
      exception
         when others then
         vn_qtde_nf := 0;
      end;
      --
      if nvl(vn_qtde_nf,0) > 0 then
         --
         update nf_compl_serv ncs
            set ncs.cidademodfiscal_id = vn_cidademodfiscal_id
          where ncs.notafiscal_id = en_notafiscal_id;
         --
      else
         --
         insert into nf_compl_serv ( notafiscal_id
                                   , cidademodfiscal_id
                                   )
                            values
                                   ( en_notafiscal_id -- notafiscal_id
                                   , vn_cidademodfiscal_id -- cidademodfiscal_id
                                   );
         --
      end if;
      --
   end if;
   --
   vn_fase := 99.4;
   --
   if nvl(en_notafiscal_id,0) > 0 and
      trim(ev_atributo) = 'DM_LEGADO' and
      nvl(vn_dm_legado, 0) in (0, 1, 2, 3, 4) and
      vv_mensagem is null then
      --
      vn_fase := 99.401;
      --
      begin
         --	  
         select nf.dm_st_proc
           into vn_dm_st_proc		 
           from nota_fiscal nf
          where nf.id = en_notafiscal_id;
        --		  
      exception
         when others then 
            vn_dm_st_proc := null;
      end;
      -- Verificação de DM_ST_PROC com DM_LEGADO
      --	
      if vn_dm_st_proc is not null then	  
         --
         if    vn_dm_legado = 1 then -- Legado Autorizado
               vn_dm_st_proc := 4;   -- Autorizada
         elsif vn_dm_legado = 2 then -- Legado Autorizado		 
               vn_dm_st_proc := 6;   -- Denegada
         elsif vn_dm_legado = 3 then -- Legado Cancelado
               vn_dm_st_proc := 7;   -- Cancelada
         elsif vn_dm_legado = 4 then -- Legado Inutilizado
               vn_dm_st_proc := 8;   -- Inutilizada
         end if;
         --		 
      end if;	  
      --	  
      update nota_fiscal nf
         set nf.dm_legado  = vn_dm_legado
           , nf.dm_st_proc = vn_dm_st_proc		 
		   , dt_st_proc    = sysdate
       where nf.id = en_notafiscal_id;
      --
   end if;
   --
   vn_fase := 99.5;
   --
   if nvl(en_notafiscal_id,0) > 0 and
      ev_atributo = 'ID_ERP' and
      nvl(vn_id_erp,0) > 0 and
      gv_mensagem_log is null then
      --
      vn_fase := 99.6;
      --
      begin
         --
         select count(1)
           into vn_qtde_nf
           from nota_fiscal_compl
          where notafiscal_id = en_notafiscal_id;
         --
      exception
         when others then
         vn_qtde_nf := 0;
      end;
      --
      if nvl(vn_qtde_nf,0) > 0 then
         --
         update nota_fiscal_compl ncs
            set ncs.id_erp = vn_id_erp
          where ncs.notafiscal_id = en_notafiscal_id;
         --
      else
         --
         insert into nota_fiscal_compl ( id
                                       , notafiscal_id
                                       , id_erp
                                       )
                                values ( notafiscalcompl_seq.nextval
                                       , en_notafiscal_id -- notafiscal_id
                                       , vn_id_erp -- cidademodfiscal_id
                                       );
         --
      end if;
      --
   end if;
   --
   if nvl(en_notafiscal_id,0) > 0 and
      ev_atributo = 'NRO_AUT_NFS' and
      nvl(vv_nro_aut_nfs,0) is not null and
      gv_mensagem_log is null then
      --
      vn_fase := 99.7;
      --
      begin
         --
         select count(1)
           into vn_qtde_nf
           from nf_compl_serv
          where notafiscal_id = en_notafiscal_id;
         --
      exception
         when others then
         vn_qtde_nf := 0;
      end;
      --
      if nvl(vn_qtde_nf,0) > 0 then
         --
         update nf_compl_serv ncs
            set ncs.nro_aut_nfs   = vv_nro_aut_nfs
          where ncs.notafiscal_id = en_notafiscal_id;
         --
      else
         --
         insert into nf_compl_serv ( notafiscal_id
                                   , nro_aut_nfs
                                   )
                            values
                                   ( en_notafiscal_id -- notafiscal_id
                                   , vv_nro_aut_nfs   -- nro_aut_nfs
                                   );
         --
      end if;
   --
   end if;
   --
   if nvl(en_notafiscal_id,0) > 0              and
      ev_atributo             = 'DT_EMISS_NFS' and
      vd_dt_emiss_nfs         is not null      and
      gv_mensagem_log         is null          then
      --
      vn_fase := 99.8;
      --
      begin
         --
         select count(1)
           into vn_qtde_nf
           from nf_compl_serv
          where notafiscal_id = en_notafiscal_id;
         --
      exception
         when others then
         vn_qtde_nf := 0;
      end;
      --
      if nvl(vn_qtde_nf,0) > 0 then
         --
         update nf_compl_serv ncs
            set ncs.dt_emiss_nfs  = vd_dt_emiss_nfs
          where ncs.notafiscal_id = en_notafiscal_id;
         --
      else
         --
         insert into nf_compl_serv ( notafiscal_id
                                   , dt_emiss_nfs
                                   )
                            values
                                   ( en_notafiscal_id -- notafiscal_id
                                   , vd_dt_emiss_nfs  -- dt_emiss_nfs
                                   );
         --
      end if;
   --
   end if;
   --
   vn_fase := 99.9;
   --
   if nvl(en_notafiscal_id,0) > 0 and
      trim(ev_atributo) = 'COD_NAT_OPER' and
      nvl(vn_codnat_id, 0) <> 0  and
      vv_mensagem is null then
      --
      vn_fase := 99.901;
      --
      update nota_fiscal nf
         set nf.NATOPER_ID = vn_codnat_id
       where nf.id = en_notafiscal_id;
      --
   end if;
   --
   vn_fase := 100;
   --
   <<sair_integr>>
   null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_nfs.pkb_integr_nota_fiscal_serv_ff fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                             , ev_resumo            => gv_mensagem_log
                             , en_tipo_log          => ERRO_DE_SISTEMA
                             , en_referencia_id     => gn_referencia_id
                             , ev_obj_referencia    => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_nota_fiscal_serv_ff;

-------------------------------------------------------------------------------------------------------

--| Procedimento de integração do complemento da nota fiscal de serviço - CAMPO ID_ERP
procedure pkb_integr_nota_fiscal_compl ( est_log_generico_nf          in out nocopy dbms_sql.number_table
                                       , est_row_nota_fiscal_compl in out nocopy nota_fiscal_compl%rowtype
                                       )
is
   --
   vn_fase            number := 0;
   vn_loggenericonf_id  log_generico_nf.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_nfe_nao_integrar ( en_notafiscal_id => est_row_nota_fiscal_compl.notafiscal_id ) then
      --
      goto sair_integr;
      --
   end if;
   --
   vn_fase := 1.1;
   --
   if nvl(est_row_nota_fiscal_compl.notafiscal_id,0) = 0
      and nvl(est_log_generico_nf.count,0) = 0 then
      --
      vn_fase := 1.2;
      --
      gv_mensagem_log := 'Não informada a Nota Fiscal para o complemento do serviço';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                  , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                  , ev_resumo          => gv_mensagem_log
                                  , en_tipo_log        => ERRO_DE_VALIDACAO
                                  , en_referencia_id   => gn_referencia_id
                                  , ev_obj_referencia  => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                          , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   if nvl(est_row_nota_fiscal_compl.notafiscal_id,0) > 0
      then
      --
      -- Se for tipo de integração igual a 1 insere
      if nvl(gn_tipo_integr, 0) = 1 then
         --
         vn_fase := 99.1;
         --
         select notafiscalcompl_seq.nextval
           into est_row_nota_fiscal_compl.id
           from dual;
         --
         insert into nota_fiscal_compl ( id
                                       , notafiscal_id
                                       , id_erp
                                       )
                                values ( est_row_nota_fiscal_compl.id
                                       , est_row_nota_fiscal_compl.notafiscal_id
                                       , est_row_nota_fiscal_compl.id_erp
                                       );
         --
      else
        --
        vn_fase := 99.2;
        --
        update nota_fiscal_compl
           set id_erp = est_row_nota_fiscal_compl.id_erp
         where id = est_row_nota_fiscal_compl.id;
        --
      end if;
      --
   end if;
   --
   <<sair_integr>>
   null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_nfs.pkb_integr_nota_fiscal_compl fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%type;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                     , ev_mensagem        => null
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => erro_de_sistema
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_nota_fiscal_compl;
--
-- ============================================================================================================== --
--
--| Procedimento que faz validações na Nota Fiscal e grava na CSF
procedure pkb_integr_Nota_Fiscal_serv ( est_log_generico_nf        in out nocopy  dbms_sql.number_table
                                      , est_row_Nota_Fiscal        in out nocopy  Nota_Fiscal%rowtype
                                      , ev_cod_mod                 in             Mod_Fiscal.cod_mod%TYPE
                                      , ev_empresa_cpf_cnpj        in             varchar2                 default null -- CPF/CNPJ da empresa
                                      , ev_cod_part                in             Pessoa.cod_part%TYPE     default null
                                      , ev_cd_sitdocto             in             Sit_Docto.cd%TYPE        default null
                                      , ev_sist_orig               in             sist_orig.sigla%type     default null
                                      , ev_cod_unid_org            in             unid_org.cd%type         default null
                                      , en_multorg_id              in             mult_org.id%type
                                      , en_empresaintegrbanco_id   in             empresa_integr_banco.id%type default null
                                      , en_loteintws_id            in             lote_int_ws.id%type default 0
                                      )
is
   --
   -- ESTRUTURA DA DA ROTINA
   -- ========================================================
   -- 1 - Declaração das variáveis e contadores de integracao
   -- 2 - Montagem do cabeçalho do Log Genérico e chamada da procedure que retorna os dados da empresa 
   -- 3 - Verifica se já existe a nota fiscal no Compliance se não existe cria o id para integração
   -- 4 - Remove os logs anteriores
   -- 5 - Validações dos campos e geração dos erros de validação
   -- 6 - Carrega valores para campos e/ou formata dados
   -- 7 - Atualiza ou insere dados na tabela nota fiscal   
   -- 
   -- 1 - Declaração das variáveis e contadores de integracao
   -- ========================================================                                   
   vn_fase              number                      := 0;
   vn_loggenericonf_id  log_generico_nf.id%TYPE;
   vn_dm_st_proc        Nota_Fiscal.dm_st_proc%TYPE := null;
   vn_dm_habil          cidade_nfse.dm_habil%type;
   vv_nome              pessoa.nome%type            := null;
   vn_dm_situacao       empresa.dm_situacao%type    := 0;
   vv_dados             varchar2(255)               := null;
   vn_sit_empresa       number                      := 0;
   vn_existe_id         empresa.id%type             := 0; -- 0-Não / 1-Sim  
   vn_dm_tp_impr        empresa.dm_tp_impr%type     := null;  
   vn_dm_tp_amb         empresa.dm_tp_amb%type      := null;  
   vv_cnpj_cpf          varchar2(14)                := null; 
   vv_cod_part          pessoa.cod_part%type        := null;    
   vv_im                juridica.im%type            := null;  
   vn_pessoa_id_emit    pessoa.id%type              := null;
   vv_ibge_cidade       cidade.ibge_cidade%type     := null;        
   vv_ibge_estado       estado.ibge_estado%type     := null;
   vv_cod_nat           Nat_Oper.cod_nat%TYPE       := null;
   --
begin
   --
   vn_fase := 1;
   --
   --#71510 inclusao dos contadores
   -- Calcula a quantidade de registros Totais integrados para ser mostrado na tela de agendamento.
   --
   begin
      pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
   exception
      when others then
      null;
   end;
   --  
   -- 2 - Montagem do cabeçalho do Log Genérico e chamada da procedure que retorna os dados da empresa 
   -- ================================================================================================
   gv_cabec_log := null;
   --
   if nvl(est_row_Nota_Fiscal.empresa_id,0) <= 0 then
      -- 
      est_row_Nota_Fiscal.empresa_id := pk_csf.fkg_empresa_id2 ( en_multorg_id        => en_multorg_id
                                                               , ev_cod_matriz        => null
                                                               , ev_cod_filial        => null
                                                               , ev_empresa_cpf_cnpj  => ev_empresa_cpf_cnpj );
      --
   end if;
   --
   -- Carrega os dados da empresa para serem usados nas validações 
   -- ============================================================
   vn_fase := 2;
   --
   if nvl(est_row_Nota_Fiscal.empresa_id,0) > 0 then
      --
      vn_fase := 2.1;
      --
      begin
         pk_csf.pkb_ret_dados_empresa ( en_empresa_id        => est_row_Nota_Fiscal.empresa_id
                                      , sv_nome              => vv_nome
                                      , sn_dm_situacao       => vn_dm_situacao
                                      , sv_dados             => vv_dados
                                      , sn_sit_empresa       => vn_sit_empresa
                                      , sn_dm_habil          => vn_dm_habil
                                      , sn_existe_id         => vn_existe_id
                                      , sn_dm_tp_impr        => vn_dm_tp_impr
                                      , sn_dm_tp_amb         => vn_dm_tp_amb
                                      , sv_cnpj_cpf          => vv_cnpj_cpf
                                      , sv_cod_part          => vv_cod_part
                                      , sv_im                => vv_im
                                      , sn_pessoa_id         => vn_pessoa_id_emit
                                      , sv_ibge_cidade       => vv_ibge_cidade
                                      , sv_ibge_estado       => vv_ibge_estado
                                      );
      exception 
         when others then
         --
         gv_mensagem_log := 'Erro ao chamar a pk_csf.pkb_ret_dados_empresa fase(' || vn_fase || '): ' || sqlerrm;
         --
         declare
            vn_loggenericonf_id  log_generico_nf.id%type;
         begin
            --
            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                , ev_mensagem          => null
                                , ev_resumo            => gv_mensagem_log
                                , en_tipo_log          => erro_de_sistema
                                , en_referencia_id     => gn_referencia_id
                                , ev_obj_referencia    => gv_obj_referencia );
            --
         exception
            when others then
               null;
         end;
         --
      end;
      --
      -- Atribui a empresa para registro no log
      gn_empresa_id := est_row_Nota_Fiscal.empresa_id;
      --
      gv_cabec_log := 'Empresa: '|| vv_nome;
      --
      gv_cabec_log := gv_cabec_log||chr(10);
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_row_Nota_Fiscal.nro_nf,0) > 0 then
      --
      gv_cabec_log := gv_cabec_log||'Número: '||est_row_Nota_Fiscal.nro_nf;
      --
      gv_cabec_log := gv_cabec_log||chr(10);
      --
   end if;
   --
   vn_fase := 4;
   --
   if est_row_Nota_Fiscal.serie is not null then
      --
      gv_cabec_log := gv_cabec_log||'Série: '||est_row_Nota_Fiscal.serie;
      --
      gv_cabec_log := gv_cabec_log||chr(10);
      --
   end if;
   --
   vn_fase := 5;
   --
   if trim ( ev_cod_mod ) is not null then
      --
      gv_cabec_log := gv_cabec_log||'Modelo: '||ev_cod_mod;
      --
      gv_cabec_log := gv_cabec_log||chr(10);
      --
   end if;
   --
   vn_fase := 6;
   --
   if est_row_Nota_Fiscal.dt_emiss is not null then
      --
      gv_cabec_log := gv_cabec_log||'Data de emissão: '||to_char(est_row_Nota_Fiscal.dt_emiss, 'dd/mm/yyyy');
      --
      gv_cabec_log := gv_cabec_log||chr(10);
      --
   end if;
   --
   vn_fase := 7;
   --
   gv_cabec_log := gv_cabec_log||'Operação: '||pk_csf.fkg_dominio( ev_dominio => 'NOTA_FISCAL.DM_IND_OPER'
                                                                 , ev_vl      => est_row_Nota_Fiscal.dm_ind_oper );
   --
   gv_cabec_log := gv_cabec_log||chr(10);
   --
   gv_cabec_log := gv_cabec_log||'Indicador do Emitente: '||pk_csf.fkg_dominio( ev_dominio => 'NOTA_FISCAL.DM_IND_EMIT'
                                                                              , ev_vl      => est_row_Nota_Fiscal.dm_ind_emit );
   --
   gv_cabec_log := gv_cabec_log||chr(10);
   --
   if nvl(en_loteintws_id,0) > 0 then
      --
      gv_cabec_log := gv_cabec_log || 'Lote WS: ' || en_loteintws_id || chr(10);
      --
   end if;
   --
   vn_fase := 8;
   --
   -- 3 - Verifica se já existe a nota fiscal no Compliance se não existe cria o id para integração
   -- =============================================================================================
   if nvl(est_row_Nota_Fiscal.id,0) <= 0 then
      --
      est_row_Nota_Fiscal.id := pk_csf.fkg_busca_notafiscal_id ( en_multorg_id      => en_multorg_id
                                                               , en_empresa_id      => est_row_Nota_Fiscal.empresa_id
                                                               , ev_cod_mod         => ev_cod_mod
                                                               , ev_serie           => est_row_Nota_Fiscal.serie
                                                               , en_nro_nf          => est_row_Nota_Fiscal.nro_nf
                                                               , en_dm_ind_oper     => est_row_Nota_Fiscal.dm_ind_oper
                                                               , en_dm_ind_emit     => est_row_Nota_Fiscal.dm_ind_emit
                                                               , ev_cod_part        => ev_cod_part
                                                               , en_dm_arm_nfe_terc => est_row_Nota_Fiscal.dm_arm_nfe_terc
                                                               );
      --
   end if;
   --
   vn_fase := 9;
   --
   -- Se a nota não existe, já atribui o ID
   if nvl(est_row_Nota_Fiscal.id,0) <= 0 then
      --
      select notafiscal_seq.nextval
        into est_row_Nota_Fiscal.id
        from dual;
      --
   end if;
   --
   -- Seta o ID de referencia da Nota Fiscal
   pkb_seta_referencia_id ( en_id => est_row_Nota_Fiscal.id );
   --
   vn_fase := 10;
   --
   -- 4 - Remove os logs anteriores
   -- =============================
   delete from log_generico_nf
    where referencia_id = gn_referencia_id
      and obj_referencia = gv_obj_referencia;
   --
   -- 5 - Validações dos campos e geração dos erros de validação
   -- ==========================================================
   --
   vn_fase := 11;
   --
   -- Valida se a empresa esta ativa
   if vn_dm_situacao = 0 then
      --
      gv_mensagem_log := '"Empresa" ('|| vv_dados ||') está inativa no sistema.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 12;
   --
   -- Valida se os dados do certificado estão ok
   if est_row_Nota_Fiscal.dm_ind_emit = 0     and 
      ev_cod_mod                      = '99'  and 
      vn_sit_empresa                  = 0    then
      --
      gv_mensagem_log := '"Empresa" ('||est_row_Nota_Fiscal.empresa_id||') está com os dados de certificado digital inválidos.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 13;
   --
   -- Valida se a cidade da empresa esta habilitada para emissão de NFSe
   if est_row_Nota_Fiscal.dm_ind_emit      = 0 and -- Emissão Própria
      vn_dm_habil                          = 0 and -- Não habilitada
      nvl(est_row_Nota_Fiscal.dm_legado,0) = 0 then
      --
      gv_mensagem_log := 'Cidade da empresa emitente não esta habilitada para emissão de NFSe.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 14;
   --
   -- Válida se a empresa é válida
   if vn_existe_id = 0 then
      --
      gv_mensagem_log := '"Empresa" ('||est_row_Nota_Fiscal.empresa_id||') está incorreta.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 15;
   --
   vn_dm_st_proc := pk_csf.fkg_st_proc_nf ( en_notafiscal_id => est_row_Nota_Fiscal.id );
   --
   vn_fase := 16;
   --
   -- Verifica Situação da Nota Fiscal
   if vn_dm_st_proc                   in ( 1, 2, 3, 4, 6, 7, 8, 14, 17, 18, 19, 20, 21 ) and
      est_row_Nota_Fiscal.dm_ind_emit  = 0                                           and 
      ev_cod_mod                      in ('99', 'ND') then
      -- se dm_st_proc for:
      --  1 Não Processada. Aguardando Processamento
      --  2 Processada. Aguardando Envio
      --  3 Enviada ao SEFAZ. Aguardando Retorno
      --  4 Autorizada
      --  6 Denegada
      --  7 Cancelada
      --  8 Inutilizada
      -- 14 Sefaz em contingência
      -- 17 Aguardando consulta na Sefaz
      -- 18 Digitada
      -- 19 Processada
      -- 20 RPS não Convertido
      -- 21	Aguardando Liberacao
      --
      vn_fase := 16.1;
      --
      gv_dominio := null;
      --
      gv_dominio := pk_csf.fkg_dominio ( ev_dominio   => 'NOTA_FISCAL.DM_ST_PROC'
                                       , ev_vl        => vn_dm_st_proc );
      --
      gv_mensagem_log := 'Nota Fiscal está com a situação '||gv_dominio||' não pode ser integrada novamente.';
      --
      vn_loggenericonf_id := null;
      --
      -- Sai do processo
      -- ===============
      goto sair_integr;
      --
   else
      --
      vn_fase := 16.2;
      --
      -- Se o Tipo de Integração é 1 (válida e insere)
      if nvl(gn_tipo_integr,0) = 1 then
         --
         pk_csf_api.pkb_excluir_dados_nf ( en_notafiscal_id => est_row_Nota_Fiscal.id );
         --
      end if;
      --
   end if;
   --
   vn_fase := 17;
   --
   -- Valida informação do participante
   if trim ( ev_cod_part ) is not null then
      --
      vn_fase := 17.1;
      -- Pessoa_id do PARTICIPANTE DA NOTA (COD_PART)
      est_row_Nota_Fiscal.pessoa_id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id => en_multorg_id
                                                                     , ev_cod_part   => ev_cod_part );
      --
   end if;
   --
   vn_fase := 18;
   --
   -- Válida a informação da pessoa
   if nvl(est_row_Nota_Fiscal.pessoa_id,0) > 0 then
      --
      vn_fase := 18.1;
      --
      if pk_csf.fkg_Pessoa_id_valido ( en_pessoa_id => est_row_Nota_Fiscal.pessoa_id ) = false then
         --
         gv_mensagem_log := '"Código do participante da nota fiscal" ('|| ev_cod_part ||') está incorreto.';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem          => gv_cabec_log
                             , ev_resumo            => gv_mensagem_log
                             , en_tipo_log          => ERRO_DE_VALIDACAO
                             , en_referencia_id     => gn_referencia_id
                             , ev_obj_referencia    => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                                , est_log_generico_nf  => est_log_generico_nf );
         --
      end if;
      --
   end if;
   --
   vn_fase := 19;
   --
   -- Valida a Nota Fiscal de Emissão de Terceiros verificando se tem PESSOA_ID
   if nvl(est_row_Nota_Fiscal.pessoa_id,0) <= 0  and
      est_row_Nota_Fiscal.dm_ind_emit       = 1  and -- Terceiros
      est_row_nota_fiscal.dm_arm_nfe_terc   = 0 then -- Não é de armazenamento Fiscal
      --
      gv_mensagem_log := 'Favor informar o Participante da Nota Fiscal (Cliente, Fornecedor, Transportadora, etc.)';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                             , est_log_generico_nf => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 20;
   --      
   -- Valida informação da situação do documento
   if    est_row_Nota_Fiscal.dm_st_proc = 8 then -- Inutilizada
      --
      est_row_Nota_Fiscal.sitdocto_id := pk_csf.fkg_Sit_Docto_id ( ev_cd => '05' ); -- NF-e ou CT-e : Numeração inutilizada
      --
   elsif est_row_Nota_Fiscal.dm_st_proc = 7 then -- Cancelada
         --
         est_row_Nota_Fiscal.sitdocto_id := pk_csf.fkg_Sit_Docto_id ( ev_cd => '02' ); -- Documento cancelado
         --
   elsif est_row_Nota_Fiscal.dm_st_proc = 6 then -- Denegada
         --
         est_row_Nota_Fiscal.sitdocto_id := pk_csf.fkg_Sit_Docto_id ( ev_cd => '04' ); -- NF-e ou CT-e denegado
         --
   else
      --
      if est_row_Nota_Fiscal.dm_fin_nfe = 2 then -- NF-e complementar
         --
         if ev_cd_sitdocto in ('06','07') then -- 06-Documento Fiscal Complementar, 07-Documento Fiscal Complementar extemporâneo.
            --
            est_row_Nota_Fiscal.sitdocto_id := pk_csf.fkg_Sit_Docto_id ( ev_cd => ev_cd_sitdocto );
            --
         else
            --
            est_row_Nota_Fiscal.sitdocto_id := pk_csf.fkg_Sit_Docto_id ( ev_cd => '06' ); -- Documento Fiscal Complementar
            --
         end if;
         --
      else
         --
         if ev_cd_sitdocto in ('00','08') then -- 00-Documento regular, 08-Documento Fiscal emitido com base em Regime Especial ou Norma Específica
            --
            est_row_Nota_Fiscal.sitdocto_id := pk_csf.fkg_Sit_Docto_id ( ev_cd => ev_cd_sitdocto );
            --
         else
            --
            est_row_Nota_Fiscal.sitdocto_id := pk_csf.fkg_Sit_Docto_id ( ev_cd => '00' ); -- Documento regular
            --
         end if;
         --
      end if;
      --
   end if;
   --
   vn_fase := 20.1;
   --
   -- Valida a informação da situação do documento fiscal
   if nvl(est_row_Nota_Fiscal.sitdocto_id,0) <= 0 then
      --
      gv_mensagem_log := '"Situação do Documento Fiscal" ('||ev_cd_sitdocto||') está incorreta.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
      est_row_Nota_Fiscal.sitdocto_id    := pk_csf.fkg_Sit_Docto_id ( ev_cd => '00' );
      --
   end if;
   --
   vn_fase := 21;
   --
   -- Valida se indicador da forma de pagamento está correto
   if est_row_Nota_Fiscal.dm_ind_Pag not in (0, 1, 2, 9) then
      --
      gv_mensagem_log := '"Indicador da forma de pagamento" ('||est_row_Nota_Fiscal.dm_ind_Pag||') está incorreto.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                             , est_log_generico_nf => est_log_generico_nf );
      --
      est_row_Nota_Fiscal.dm_ind_Pag := 0;
      --
   end if;
   --
   vn_fase := 22;
   --
   -- Valida informação do campo modfical_id
   est_row_Nota_Fiscal.modfiscal_id := pk_csf.fkg_Mod_Fiscal_id ( ev_cod_mod => trim ( ev_cod_mod ) );
   --
   vn_fase := 22.1;
   --
   -- Valida a informação do modelo fiscal
   if nvl(est_row_Nota_Fiscal.modfiscal_id,0) <= 0 then
      --
      gv_mensagem_log := '"Modelo do documento fiscal" ('||ev_cod_mod||') está incorreto. ' ||
                         'Será atribuído o valor "99" para que o dado possa ser inserido. Verifique os dados de integração!';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
      est_row_Nota_Fiscal.modfiscal_id   := pk_csf.fkg_Mod_Fiscal_id ( ev_cod_mod => '99' );
      --
   end if;
   --
   vn_fase := 23;
   --
   -- Valida se o Indicador da Emissão está correto
   if est_row_Nota_Fiscal.dm_ind_emit not in (0, 1) then
      --
      gv_mensagem_log := '"Indicador do emitente da Nota Fiscal" ('||est_row_Nota_Fiscal.dm_ind_emit||') está incorreto.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                             , est_log_generico_nf => est_log_generico_nf );
      --
      est_row_Nota_Fiscal.dm_ind_emit := 0;
      --
   end if;
   --
   vn_fase := 24;
   --
   -- Valida se o indicador da operação está correto
   if est_row_Nota_Fiscal.dm_ind_oper not in (0, 1) then
      --
      gv_mensagem_log := '"Indicador do tipo de operação da Nota Fiscal" ('||est_row_Nota_Fiscal.dm_ind_oper||') está incorreto.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                          , ev_mensagem         => gv_cabec_log
                          , ev_resumo           => gv_mensagem_log
                          , en_tipo_log         => ERRO_DE_VALIDACAO
                          , en_referencia_id    => gn_referencia_id
                          , ev_obj_referencia   => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                             , est_log_generico_nf => est_log_generico_nf );
      --
      est_row_Nota_Fiscal.dm_ind_oper := 0;
      --
   end if;
   --
   vn_fase := 24.1;
   --
   -- Valida se o tipo da nota é "Saída" não pode ser emitida por terceiros
   if est_row_Nota_Fiscal.dm_ind_oper = 1  and
      est_row_Nota_Fiscal.dm_ind_emit = 1 then
      --
      gv_mensagem_log := 'Nota Fiscal é do tipo saída e registrada como emitida por "terceiros".';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                             , est_log_generico_nf => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 24.2;
   --
   -- Valida se o tipo da nota é "Entrada" e de "Emissão Própria" não pode ter nf de entrada emitida como emissão própria
   if est_row_Nota_Fiscal.dm_ind_oper = 0  and -- "Entrada"
      est_row_Nota_Fiscal.dm_ind_emit = 0 then -- "Emissão Própria"
      --
      gv_mensagem_log := 'Não permitida operação de "Entrada" para uma NFS-e de "Emissão Própria". Verifique os dados de integração da nota fiscal.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                             , est_log_generico_nf => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 25;
   --
   -- Valida a informação do campo dt_emiss
   if est_row_Nota_Fiscal.dt_emiss is null then
      --
      gv_mensagem_log := '"Data de emissão da Nota Fiscal" deve ser informada.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                             , est_log_generico_nf => est_log_generico_nf );
      --
      est_row_Nota_Fiscal.dt_emiss := sysdate;
      --
   end if;
   --
   vn_fase := 26;
   --
   -- Valida a data de emissão verificando se é maior que a data atual
   if trunc(est_row_Nota_Fiscal.dt_emiss) > sysdate then
      --
      gv_mensagem_log := 'Data de emissão('||to_char(est_row_Nota_Fiscal.dt_emiss,'dd/mm/rrrr hh24:mi')||') está maior que a data atual.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                          , ev_mensagem         => gv_cabec_log
                          , ev_resumo           => gv_mensagem_log
                          , en_tipo_log         => ERRO_DE_VALIDACAO
                          , en_referencia_id    => gn_referencia_id
                          , ev_obj_referencia   => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 27;
   --
   -- Válida se a séria não foi informada
   if trim( est_row_Nota_Fiscal.serie ) is null then
      --
      gv_mensagem_log := 'Série da Nota Fiscal deve ser informada.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                             , est_log_generico_nf => est_log_generico_nf );
      --
      est_row_Nota_Fiscal.serie := '0';
      --
   end if;
   --
   vn_fase := 28;
   -- 
   -- Válida se a situação do processo está correta
   if est_row_Nota_Fiscal.dm_st_proc not in (0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 99) then
      --
      gv_mensagem_log := '"Situação do processo da Nota Fiscal" ('||est_row_Nota_Fiscal.dm_st_proc||') está incorreta.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                             , est_log_generico_nf => est_log_generico_nf );
      --
      est_row_Nota_Fiscal.dm_st_proc := 10;
      --
   end if;
   --
   vn_fase := 29;
   --
   if ev_cod_mod IN ('99', 'ND') then -- Somente NFSe
      --
      if est_row_Nota_Fiscal.dm_ind_emit = 0 then -- Emissão própria sempre imprime
         est_row_Nota_Fiscal.dm_impressa := 0; -- Não impressa
      else
         if est_row_Nota_Fiscal.dm_arm_nfe_terc = 1 then -- Armazena NFe/XML de Terceiro sempre imprimi
            est_row_Nota_Fiscal.dm_impressa := 0; -- Não impressa
         else
            est_row_Nota_Fiscal.dm_impressa := 1; -- Impressa
         end if;
      end if;
      --
   else
      est_row_Nota_Fiscal.dm_impressa := 1; -- Impressa
   end if;
   --
   vn_fase := 30.1;
   --
   -- Valida informação do campo dm_impressa
   if est_row_Nota_Fiscal.dm_impressa not in (0, 1, 2, 3) then
      --
      gv_mensagem_log := '"Situação da Impressão da Nota Fiscal" ('||est_row_Nota_Fiscal.dm_impressa||') está incorreta.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                             , est_log_generico_nf => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 31;
   --
   -- Carrega o tipo de ambiente parâmetrizado para a empresa
   est_row_Nota_Fiscal.dm_tp_impr := vn_dm_tp_impr;
   --
   vn_fase := 31.1;
   --
   -- Valida o Formato de Impressão do DANFE
   if est_row_Nota_Fiscal.dm_tp_impr not in (1, 2) then
      --
      gv_mensagem_log := '"Formato de Impressão do DANFE" ('||est_row_Nota_Fiscal.dm_tp_impr||') está incorreto.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                             , est_log_generico_nf => est_log_generico_nf );
      --
      est_row_Nota_Fiscal.dm_tp_impr := 1;
      --
   end if;
   --
   vn_fase := 32;
   --
   -- Carrega o tipo de ambiente parâmetrizado para a empresa
   est_row_Nota_Fiscal.dm_tp_amb := vn_dm_tp_amb;
   --
   vn_fase := 32.1;
   --
   -- Valida Identificação do Ambiente
   if est_row_Nota_Fiscal.dm_tp_amb not in (1, 2) then
      --
      gv_mensagem_log := '"Identificação do Ambiente" ('||est_row_Nota_Fiscal.dm_tp_amb||') está incorreto.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                             , est_log_generico_nf => est_log_generico_nf );
      --
      est_row_Nota_Fiscal.dm_tp_amb := 2;
      --
   end if;
   --
   vn_fase := 33;
   --
   -- Válida o campo dm_st_email
   if est_row_Nota_Fiscal.dm_st_email not in (0, 1, 2, 3, 4) then
      --
      gv_mensagem_log := '"Situação de envio de e-mail da Nota Fiscal" ('||est_row_Nota_Fiscal.dm_st_email||') está inválida!';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                             , est_log_generico_nf => est_log_generico_nf );
      --
      -- Carrega valor default do campo conforme estrutura da tabela
      est_row_Nota_Fiscal.dm_st_email := 0; 
      --
   else
      -- Carrega valor default do campo conforme estrutura da tabela
      est_row_Nota_Fiscal.dm_st_email := 0;
      --
   end if;
   --
   vn_fase := 34;
   --
   -- Valida o Sistema de Origem
   est_row_Nota_Fiscal.sistorig_id := pk_csf.fkg_sist_orig_id ( en_multorg_id => en_multorg_id
                                                              , ev_sigla      => trim(ev_sist_orig) );
   --
   vn_fase := 34.1;
   --
   if nvl(est_row_Nota_Fiscal.sistorig_id,0) <= 0 and 
      trim(ev_sist_orig)                     is not null then
      --
      gv_mensagem_log := '"Sistema de Origem" ('||ev_sist_orig||') não esta informado nas parâmetrizações do Compliance!';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                             , est_log_generico_nf => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 35;
   --
   -- Valida a Unidade Organizacional
   est_row_Nota_Fiscal.unidorg_id := pk_csf.fkg_unig_org_id ( en_empresa_id    => est_row_Nota_Fiscal.empresa_id
                                                            , ev_cod_unid_org  => trim(ev_cod_unid_org) );
   --
   vn_fase := 35.1;
   --
   if nvl(est_row_Nota_Fiscal.unidorg_id,0) <= 0 and trim(ev_cod_unid_org) is not null then
      --
      gv_mensagem_log := '"Unidade Organizacional" ('||ev_cod_unid_org||') não esta relacionada a empresa (' || vv_cnpj_cpf || ').';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                             , est_log_generico_nf => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 36;   
   --
   if vv_im is null and est_row_Nota_Fiscal.dm_ind_emit = 0 then
      --
      gv_mensagem_log := 'Não informado a Incrição Municipal da Empresa Emitente ('
                         || vv_cod_part
                         ||'), no cadastro de participantes.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   -- 6 - Carrega valores para campos e/ou formata dados
   -- ==================================================
   --
   vn_fase := 50; 
   --
   -- Carrega a data informação da situação 
   if est_row_Nota_Fiscal.dt_st_proc is null then
      --
      est_row_Nota_Fiscal.dt_st_proc := sysdate;
      --
   end if;
   --
   vn_fase := 50.1; 
   --
   -- Carrega Informação da autorização do SEFAZ - Se não tem valor ou inconsistente, atribui que não foi aprovada
   if est_row_Nota_Fiscal.dm_aut_sefaz       not in (0, 1)   or 
      nvl(est_row_Nota_Fiscal.dm_aut_sefaz,0)     = 0      then
      --
      est_row_Nota_Fiscal.dm_aut_sefaz := 0;
      -- 
   end if;
   --
   vn_fase := 50.2; 
   --
   -- Carrega a informação do código do IBGE da cidade e estado 
   if est_row_Nota_Fiscal.cidade_ibge_emit is null then
     --
     est_row_Nota_Fiscal.cidade_ibge_emit := vv_ibge_cidade;
     est_row_nota_fiscal.uf_ibge_emit     := vv_ibge_estado; 
     --
   end if;
   --
   vn_fase := 50.3; 
   --
   -- Carrega a data da entrada da Nota Fiscal no Sistema
   if est_row_Nota_Fiscal.dt_hr_ent_sist is null then
      --
      est_row_Nota_Fiscal.dt_hr_ent_sist := sysdate;
      --
   end if;
   --
   vn_fase := 50.4; 
   --
   -- Carrega o tipo de assinante
   if nvl(est_row_Nota_Fiscal.dm_tp_assinante,0) not in (1, 2, 3, 4, 5, 6) then
      --
      est_row_Nota_Fiscal.dm_tp_assinante := 1;
      --
   end if;
   --
   vn_fase := 50.5; 
   --
   -- Carrega o usuário do ERP
   if trim ( est_row_Nota_Fiscal.id_usuario_erp ) is not null then
      --
      vn_fase := 50.51;
      --
      est_row_Nota_Fiscal.usuario_id := pk_csf.fkg_neo_usuario_id_conf_erp ( en_multorg_id => en_multorg_id
                                                                           , ev_id_erp     => trim ( est_row_Nota_Fiscal.id_usuario_erp ) );
      --
      if nvl(est_row_Nota_Fiscal.usuario_id,0) <= 0 then
         --
         est_row_Nota_Fiscal.id_usuario_erp := null;
         --
      else
         --
         gt_row_Nota_Fiscal.usuario_id := est_row_Nota_Fiscal.usuario_id;
         --
      end if;
      --
   end if;
   --
   vn_fase := 50.6; 
   --
   -- Carrega a natureza de operação 
   if trim(est_row_Nota_Fiscal.nat_oper) is null then
      --
      est_row_Nota_Fiscal.nat_oper := 'NF Serviço';
      --
   end if;
   --
   vn_fase := 50.7; 
   --
   est_row_Nota_Fiscal.dm_forma_emiss := 1; -- Normal
   est_row_Nota_Fiscal.serie          := trim(est_row_Nota_Fiscal.serie);
   est_row_Nota_Fiscal.dm_fin_nfe     := 1; -- NF-e normal
   est_row_Nota_Fiscal.dm_proc_emiss  := 0;
   est_row_Nota_Fiscal.vers_Proc      := pk_csf.fkg_ultima_versao_sistema; 
   est_row_Nota_Fiscal.nro_chave_nfe  := null;  
   est_row_Nota_Fiscal.versao         := '1';   
   --
   vn_fase := 50.8; 
   --
   /*Validação para cidade de Florianopolis*/
   if est_row_Nota_Fiscal.CIDADE_IBGE_EMIT = 4205407 and est_row_Nota_Fiscal.dm_ind_emit = 0 then
     --
     if nvl(est_row_Nota_Fiscal.Natoper_Id,0)= 0 then
      --
      gv_mensagem_log := ' A natureza de operação deve ser informada, uma vez que o emitente pertence'
                         || 'a cidade de Florianopolis';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_cabec_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => ERRO_DE_VALIDACAO
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
     else
      --      
      vv_cod_nat:= pk_csf.fkg_cod_nat_id(en_natoper_id => est_row_Nota_Fiscal.Natoper_Id);
      --
      if vv_cod_nat is null then
        --
        gv_mensagem_log := ' A natureza de operação informada esta invalida, para o emitente da'
                           || 'a cidade de Florianopolis';
        --
        vn_loggenericonf_id := null;
        --
        pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                            , ev_mensagem          => gv_cabec_log
                            , ev_resumo            => gv_mensagem_log
                            , en_tipo_log          => ERRO_DE_VALIDACAO
                            , en_referencia_id     => gn_referencia_id
                            , ev_obj_referencia    => gv_obj_referencia );
        --
        -- Armazena o "loggenerico_id" na memória
        pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                               , est_log_generico_nf  => est_log_generico_nf );
        --
      end if;
      --
     end if;
     --
   end if;
   --
   vn_fase := 50.9;
   --
   -- Se não teve erro na validação, integra a nota fiscal
   -- Se não existe registro de Log e o Tipo de integração é 1 (válida e insere)
   -- Verifica se existe log de erro no processo
   if nvl(est_log_generico_nf.count,0) > 0 and
      fkg_ver_erro_log_generico_nfs( est_row_Nota_Fiscal.Id ) = 1 then
      --
      est_row_Nota_Fiscal.dm_st_proc := 10;
      --
   end if;
   --
   vn_fase := 50.91;
   --
   -- Carrega o dm_legado
   if est_row_nota_fiscal.dm_legado is null then
      --
      if    est_row_nota_fiscal.dm_st_proc = 4 then -- Autorizada
            est_row_nota_fiscal.dm_legado := 1;     -- Legado Autorizado
      elsif est_row_nota_fiscal.dm_st_proc = 6 then -- Denegada
            est_row_nota_fiscal.dm_legado := 2;     -- Legado Denegado
      elsif est_row_nota_fiscal.dm_st_proc = 7 then -- Cancelada
            est_row_nota_fiscal.dm_legado := 3;     -- Legado Cancelado
      elsif est_row_nota_fiscal.dm_st_proc = 8 then -- Inutilizada
            est_row_nota_fiscal.dm_legado := 4;     -- Legado Inutilizado
      else
         est_row_nota_fiscal.dm_legado := 0; -- Não é Legado
      end if;
      --
   end if;
   --  
   vn_fase := 99;
   --
   -- 7 - Atualiza ou insere dados na tabela nota fiscal 
   -- ==================================================   
   -- Verificação para inclusão ou atualização da nota fiscal  
   if     nvl(est_row_Nota_Fiscal.empresa_id, 0)       > 0
      and nvl(est_row_Nota_Fiscal.sitdocto_id, 0)      > 0
      and est_row_Nota_Fiscal.dm_ind_Pag               in (0, 1, 2, 9)
      and nvl(est_row_Nota_Fiscal.modfiscal_id, 0)     > 0
      and est_row_Nota_Fiscal.dm_ind_emit              in (0, 1)
      and est_row_Nota_Fiscal.dm_ind_oper              in (0, 1)
      and est_row_Nota_Fiscal.dt_emiss                 is not null
      and est_row_Nota_Fiscal.serie                    is not null
      and est_row_Nota_Fiscal.dm_fin_nfe               in (1, 2, 3)
      and est_row_Nota_Fiscal.dm_proc_emiss            in (0, 1, 2, 3)
      and trim( est_row_Nota_Fiscal.vers_Proc )        is not null
      and est_row_Nota_Fiscal.dm_aut_sefaz             in (0, 1)
      and nvl(est_row_Nota_Fiscal.cidade_ibge_emit, 0)  > 0
      and nvl(est_row_Nota_Fiscal.uf_ibge_emit, 0)      > 0
      and est_row_Nota_Fiscal.dt_hr_ent_sist           is not null
      and est_row_Nota_Fiscal.dm_st_email              in (0, 1, 2, 3) then
      --
      vn_fase := 99.1;
      --
      -- Se a nota fiscal já existe, só faz a atualização dos dados
      if pk_csf.fkg_existe_nf ( en_nota_fiscal => est_row_Nota_Fiscal.id ) = true then
         --
         vn_fase := 99.2;
         --
         -- Variavel global usada em logs de triggers (carrega)
         gv_objeto := 'pk_csf_api_nfs.pkb_integr_Nota_Fiscal_serv'; 
         gn_fase   := vn_fase;
         --
         update Nota_Fiscal
            set empresa_id             = est_row_Nota_Fiscal.empresa_id
              , pessoa_id              = est_row_Nota_Fiscal.pessoa_id
              , sitdocto_id            = est_row_Nota_Fiscal.sitdocto_id
              , natoper_id             = est_row_Nota_Fiscal.natoper_id
              , lote_id                = null
              , versao                 = est_row_Nota_Fiscal.versao
              , id_tag_nfe             = 'NFe' || trim( nvl(est_row_Nota_Fiscal.nro_chave_nfe, nro_chave_nfe) )
              , pk_nitem               = trim( est_row_Nota_Fiscal.pk_nitem )
              , nat_Oper             = trim ( pk_csf.fkg_converte ( est_row_Nota_Fiscal.nat_Oper, 0, 1, 2, 1, 1 ) )			  
              , dm_ind_Pag             = est_row_Nota_Fiscal.dm_ind_Pag
              , modfiscal_id           = est_row_Nota_Fiscal.modfiscal_id
              , dm_ind_emit            = est_row_Nota_Fiscal.dm_ind_emit
              , dm_ind_oper            = est_row_Nota_Fiscal.dm_ind_oper
              , dt_sai_ent             = est_row_Nota_Fiscal.dt_sai_ent
              , dt_emiss               = est_row_Nota_Fiscal.dt_emiss
              , nro_nf                 = est_row_Nota_Fiscal.nro_nf
              , serie                  = est_row_Nota_Fiscal.serie
              , UF_Embarq              = est_row_Nota_Fiscal.UF_Embarq
              , Local_Embarq           = trim ( pk_csf.fkg_converte ( est_row_Nota_Fiscal.Local_Embarq ) )
              , nf_empenho             = trim ( pk_csf.fkg_converte ( est_row_Nota_Fiscal.nf_empenho ) )
              , pedido_compra          = trim ( pk_csf.fkg_converte ( est_row_Nota_Fiscal.pedido_compra, 0, 1, 2, 1, 1 ) )			  
              , contrato_compra        = trim ( pk_csf.fkg_converte ( est_row_Nota_Fiscal.contrato_compra ) )
              , dm_st_proc             = est_row_Nota_Fiscal.dm_st_proc
              , dt_st_proc             = est_row_Nota_Fiscal.dt_st_proc
              , dm_forma_emiss         = est_row_Nota_Fiscal.dm_forma_emiss
              , dm_impressa            = est_row_Nota_Fiscal.dm_impressa
              , dm_tp_impr             = est_row_Nota_Fiscal.dm_tp_impr
              , dm_tp_amb              = est_row_Nota_Fiscal.dm_tp_amb
              , dm_fin_nfe             = est_row_Nota_Fiscal.dm_fin_nfe
              , dm_proc_emiss          = est_row_Nota_Fiscal.dm_proc_emiss
              , vers_Proc              = trim( est_row_Nota_Fiscal.vers_Proc )
              , dt_aut_sefaz           = est_row_Nota_Fiscal.dt_aut_sefaz
              , dm_aut_sefaz           = est_row_Nota_Fiscal.dm_aut_sefaz
              , cidade_ibge_emit       = est_row_Nota_Fiscal.cidade_ibge_emit
              , uf_ibge_emit           = est_row_Nota_Fiscal.uf_ibge_emit
              , dt_hr_ent_sist         = est_row_Nota_Fiscal.dt_hr_ent_sist
              , nro_chave_nfe          = trim( nvl(est_row_Nota_Fiscal.nro_chave_nfe, nro_chave_nfe) )
              , cNF_nfe                = nvl(est_row_Nota_Fiscal.cNF_nfe, cNF_nfe)
              , dig_verif_chave        = nvl(est_row_Nota_Fiscal.dig_verif_chave, dig_verif_chave)
              , dm_st_email            = nvl(est_row_Nota_Fiscal.dm_st_email, dm_st_email)
              , id_usuario_erp         = trim ( est_row_Nota_Fiscal.id_usuario_erp )
              , impressora_id          = est_row_Nota_Fiscal.impressora_id
              , usuario_id             = est_row_Nota_Fiscal.usuario_id
              , sub_serie              = est_row_Nota_Fiscal.sub_serie
              , inforcompdctofiscal_id = est_row_Nota_Fiscal.inforcompdctofiscal_id
              , cod_cta                = trim(est_row_Nota_Fiscal.cod_cta)
              , dm_tp_assinante        = est_row_Nota_Fiscal.dm_tp_assinante
              , dm_st_integra          = nvl(est_row_Nota_Fiscal.dm_st_integra,0)
              , sistorig_id            = nvl(est_row_nota_fiscal.sistorig_id, sistorig_id)
              , unidorg_id             = nvl(est_row_nota_fiscal.unidorg_id, unidorg_id)
              , hora_sai_ent           = est_row_nota_fiscal.hora_sai_ent
              , nro_chave_cte_ref      = est_row_nota_fiscal.nro_chave_cte_ref
              , dt_cont                = est_row_nota_fiscal.dt_cont
              , just_cont              = est_row_nota_fiscal.just_cont
              , vias_danfe_custom      = nvl(est_row_Nota_Fiscal.vias_danfe_custom,0)
              , nro_ord_emb            = trim(est_row_Nota_Fiscal.nro_ord_emb)
              , seq_nro_ord_emb        = est_row_Nota_Fiscal.seq_nro_ord_emb
              , nro_tentativas_impr    = 0
              , dt_ult_tenta_impr      = null
              , empresaintegrbanco_id  = en_empresaintegrbanco_id
              , dm_legado              = est_row_nota_fiscal.dm_legado
          where id = est_row_Nota_Fiscal.id;
         --
         -- Variavel global usada em logs de triggers (limpa)
         gv_objeto := 'pk_csf_api_nfs';
         gn_fase   := null;
         --
      else
         --
         vn_fase := 99.3;
         --
         if nvl(est_row_Nota_Fiscal.id,0) = 0 then
            --
            select notafiscal_seq.nextval
              into est_row_Nota_Fiscal.id
              from dual;
            --
         end if;
         --
         vn_fase := 99.4;
         --
         -- Variavel global usada em logs de triggers (carrega)
         gv_objeto := 'pk_csf_api_nfs.pkb_integr_Nota_Fiscal_serv';
         gn_fase   := vn_fase;
         --
         insert into Nota_Fiscal ( id
                                 , empresa_id
                                 , pessoa_id
                                 , sitdocto_id
                                 , natoper_id
                                 , lote_id
                                 , versao
                                 , id_tag_nfe
                                 , pk_nitem
                                 , nat_Oper
                                 , dm_ind_Pag
                                 , modfiscal_id
                                 , dm_ind_emit
                                 , dm_ind_oper
                                 , dt_sai_ent
                                 , dt_emiss
                                 , nro_nf
                                 , serie
                                 , UF_Embarq
                                 , Local_Embarq
                                 , nf_empenho
                                 , pedido_compra
                                 , contrato_compra
                                 , dm_st_proc
                                 , dt_st_proc
                                 , dm_forma_emiss
                                 , dm_impressa
                                 , dm_tp_impr
                                 , dm_tp_amb
                                 , dm_fin_nfe
                                 , dm_proc_emiss
                                 , vers_Proc
                                 , dt_aut_sefaz
                                 , dm_aut_sefaz
                                 , cidade_ibge_emit
                                 , uf_ibge_emit
                                 , dt_hr_ent_sist
                                 , nro_chave_nfe
                                 , cNF_nfe
                                 , dig_verif_chave
                                 , dm_st_email
                                 , id_usuario_erp
                                 , impressora_id
                                 , usuario_id
                                 , inforcompdctofiscal_id
                                 , cod_cta
                                 , dm_tp_assinante
                                 , dm_st_integra
                                 , sistorig_id
                                 , unidorg_id
                                 , hora_sai_ent
                                 , nro_chave_cte_ref
                                 , dt_cont
                                 , just_cont
                                 , vias_danfe_custom
                                 , nro_ord_emb
                                 , seq_nro_ord_emb
                                 , empresaintegrbanco_id
                                 , dm_legado
                                 )
                          values ( est_row_Nota_Fiscal.id                                        -- id
                                 , est_row_Nota_Fiscal.empresa_id                                -- empresa_id
                                 , est_row_Nota_Fiscal.pessoa_id                                 -- pessoa_id
                                 , est_row_Nota_Fiscal.sitdocto_id                               -- sitdocto_id
                                 , est_row_Nota_Fiscal.natoper_id                                -- natoper_id
                                 , est_row_Nota_Fiscal.lote_id                                   -- lote_id
                                 , est_row_Nota_Fiscal.versao                                    -- versao
                                 , 'NFe' || est_row_Nota_Fiscal.nro_chave_nfe                    -- id_tag_nfe
                                 , trim( est_row_Nota_Fiscal.pk_nitem )                          -- pk_nitem
                                 , trim( pk_csf.fkg_converte ( est_row_Nota_Fiscal.nat_Oper, 0, 1, 2, 1, 1 ) )	-- nat_Oper							 
                                 , est_row_Nota_Fiscal.dm_ind_Pag                                -- dm_ind_Pag
                                 , est_row_Nota_Fiscal.modfiscal_id                              -- modfiscal_id
                                 , est_row_Nota_Fiscal.dm_ind_emit                               -- dm_ind_emit
                                 , est_row_Nota_Fiscal.dm_ind_oper                               -- dm_ind_oper
                                 , est_row_Nota_Fiscal.dt_sai_ent                                -- dt_sai_ent
                                 , est_row_Nota_Fiscal.dt_emiss                                  -- dt_emiss
                                 , est_row_Nota_Fiscal.nro_nf                                    -- nro_nf
                                 , est_row_Nota_Fiscal.serie                                     -- serie
                                 , trim( est_row_Nota_Fiscal.UF_Embarq )                         -- UF_Embarq
                                 , trim ( pk_csf.fkg_converte ( est_row_Nota_Fiscal.Local_Embarq ) )   -- Local_Embarq
                                 , trim ( pk_csf.fkg_converte ( est_row_Nota_Fiscal.nf_empenho ) )     -- nf_empenho
                                 , trim ( pk_csf.fkg_converte ( est_row_Nota_Fiscal.pedido_compra, 0, 1, 2, 1, 1 ) )  -- pedido_compra								 
                                 , trim ( pk_csf.fkg_converte ( est_row_Nota_Fiscal.contrato_compra ) )-- contrato_compra
                                 , est_row_Nota_Fiscal.dm_st_proc                                -- dm_st_proc
                                 , est_row_Nota_Fiscal.dt_st_proc                                -- dt_st_proc
                                 , est_row_Nota_Fiscal.dm_forma_emiss                            -- dm_forma_emiss
                                 , est_row_Nota_Fiscal.dm_impressa                               -- dm_impressa
                                 , est_row_Nota_Fiscal.dm_tp_impr                                -- dm_tp_impr
                                 , est_row_Nota_Fiscal.dm_tp_amb                                 -- dm_tp_amb
                                 , est_row_Nota_Fiscal.dm_fin_nfe                                -- dm_fin_nfe
                                 , est_row_Nota_Fiscal.dm_proc_emiss                             -- dm_proc_emiss
                                 , trim( est_row_Nota_Fiscal.vers_Proc )                         -- vers_Proc
                                 , est_row_Nota_Fiscal.dt_aut_sefaz                              -- dt_aut_sefaz
                                 , est_row_Nota_Fiscal.dm_aut_sefaz                              -- dm_aut_sefaz
                                 , est_row_Nota_Fiscal.cidade_ibge_emit                          -- cidade_ibge_emit
                                 , est_row_Nota_Fiscal.uf_ibge_emit                              -- uf_ibge_emit
                                 , est_row_Nota_Fiscal.dt_hr_ent_sist                            -- dt_hr_ent_sist
                                 , trim( est_row_Nota_Fiscal.nro_chave_nfe )                     -- nro_chave_nfe
                                 , est_row_Nota_Fiscal.cNF_nfe                                   -- cNF_nfe
                                 , est_row_Nota_Fiscal.dig_verif_chave                           -- dig_verif_chave
                                 , est_row_Nota_Fiscal.dm_st_email                               -- dm_st_email
                                 , trim ( est_row_Nota_Fiscal.id_usuario_erp )                   -- id_usuario_erp
                                 , est_row_Nota_Fiscal.impressora_id                             -- impressora_id
                                 , est_row_Nota_Fiscal.usuario_id                                -- usuario_id
                                 , est_row_Nota_Fiscal.inforcompdctofiscal_id                    -- inforcompdctofiscal_id
                                 , trim(est_row_Nota_Fiscal.cod_cta)                             -- cod_cta
                                 , est_row_Nota_Fiscal.dm_tp_assinante                           -- dm_tp_assinante
                                 , nvl(est_row_Nota_Fiscal.dm_st_integra,0)                      -- dm_st_integra
                                 , est_row_Nota_Fiscal.sistorig_id                               -- sistorig_id
                                 , est_row_Nota_Fiscal.unidorg_id                                -- unidorg_id
                                 , est_row_Nota_Fiscal.hora_sai_ent                              -- hora_sai_ent
                                 , est_row_Nota_Fiscal.nro_chave_cte_ref                         -- nro_chave_cte_ref
                                 , est_row_Nota_Fiscal.dt_cont                                   -- dt_cont
                                 , est_row_Nota_Fiscal.just_cont                                 -- just_cont
                                 , nvl(est_row_Nota_Fiscal.vias_danfe_custom,0)                  -- vias_danfe_custom
                                 , trim(est_row_Nota_Fiscal.nro_ord_emb)                         -- nro_ord_emb
                                 , est_row_Nota_Fiscal.seq_nro_ord_emb                           -- seq_nro_ord_emb
                                 , en_empresaintegrbanco_id                                      -- empresaintegrbanco_id
                                 , est_row_nota_fiscal.dm_legado                                 -- dm_legado
                                 );
         --
         -- Variavel global usada em logs de triggers (limpa)
         gv_objeto := 'pk_csf_api_nfs';
         gn_fase   := null;
         --
      end if;
      --
   end if; -- campos obrigatórios
   --
   <<sair_integr>>
   null;
   --
exception
   when others then
      --
      if sqlcode = -1 then
         --
         est_row_Nota_Fiscal.id := pk_csf.fkg_busca_notafiscal_id ( en_multorg_id      => en_multorg_id
                                                                  , en_empresa_id      => est_row_Nota_Fiscal.empresa_id
                                                                  , ev_cod_mod         => ev_cod_mod
                                                                  , ev_serie           => est_row_Nota_Fiscal.serie
                                                                  , en_nro_nf          => est_row_Nota_Fiscal.nro_nf
                                                                  , en_dm_ind_oper     => est_row_Nota_Fiscal.dm_ind_oper
                                                                  , en_dm_ind_emit     => est_row_Nota_Fiscal.dm_ind_emit
                                                                  , ev_cod_part        => ev_cod_part
                                                                  , en_dm_arm_nfe_terc => est_row_Nota_Fiscal.dm_arm_nfe_terc
                                                                  );
         --
         gv_mensagem_log := 'Aviso: Nota Fiscal já existe no sistema, não será re-integrada novamente!';
         --
         declare
            vn_loggenericonf_id  log_generico_nf.id%TYPE;
         begin
            --
            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                , ev_mensagem          => gv_cabec_log
                                , ev_resumo            => gv_mensagem_log
                                , en_tipo_log          => ERRO_DE_VALIDACAO
                                , en_referencia_id     => est_row_Nota_Fiscal.id
                                , ev_obj_referencia    => gv_obj_referencia );
            --  
         exception
            when others then
               null;
         end;
         --
         est_row_Nota_Fiscal.id := null;
         --
      else
         --
         gv_mensagem_log := 'Erro na pkb_integr_Nota_Fiscal_serv fase('||vn_fase||'): '||sqlerrm;
         --
         declare
            vn_loggenericonf_id  log_generico_nf.id%TYPE;
         begin
            --
            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                , ev_mensagem          => gv_cabec_log
                                , ev_resumo            => gv_mensagem_log
                                , en_tipo_log          => ERRO_DE_SISTEMA
                                , en_referencia_id     => gn_referencia_id
                                , ev_obj_referencia    => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                                   , est_log_generico_nf  => est_log_generico_nf );
            --
         exception
            when others then
               null;
         end;
         --
      end if;
      --
end pkb_integr_Nota_Fiscal_serv;
--
-- ============================================================================================================== --
--
-- procedimento para criar o registro de total da Nota Fiscal de Serviço
procedure pkb_gera_total_nfs ( en_notafiscal_id  in nota_fiscal.id%type )
is
   --
   vn_fase               number := 0;
   --
   vn_vl_total_item       nota_fiscal_total.vl_total_item%type;
   vn_vl_desconto         nota_fiscal_total.vl_desconto%type;
   vn_vl_abat_nt          nota_fiscal_total.vl_abat_nt%type;
   vn_vl_base_calc_iss    nota_fiscal_total.vl_base_calc_iss%type;
   vn_vl_imp_trib_iss     nota_fiscal_total.vl_imp_trib_iss%type;
   vn_vl_imp_trib_pis     nota_fiscal_total.vl_imp_trib_pis%type;
   vn_vl_imp_trib_cofins  nota_fiscal_total.vl_imp_trib_cofins%type;
   vn_vl_ret_iss          nota_fiscal_total.vl_ret_iss%type;
   vn_vl_ret_pis          nota_fiscal_total.vl_ret_pis%type;
   vn_vl_ret_cofins       nota_fiscal_total.vl_ret_cofins%type;
   vn_vl_ret_csll         nota_fiscal_total.vl_ret_csll%type;
   vn_vl_base_calc_irrf   nota_fiscal_total.vl_base_calc_irrf%type;
   vn_vl_ret_irrf         nota_fiscal_total.vl_ret_irrf%type;
   vn_vl_base_calc_ret_prev  nota_fiscal_total.vl_base_calc_ret_prev%type;
   vn_vl_ret_prev         nota_fiscal_total.vl_ret_prev%type;
   vn_vl_total_nf         nota_fiscal_total.vl_total_nf%type;
   --
   vn_qtde_dup            number := 0;
   --
   cursor c_cobr is
   select nfc.*
     from nota_fiscal_cobr nfc
    where nfc.notafiscal_id = en_notafiscal_id
    order by 1;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_notafiscal_id,0) > 0 then
      --
      delete from nota_fiscal_total
       where notafiscal_id = en_notafiscal_id;
      --
      vn_fase := 2;
      -- Soma valor do item e desconto
      begin
         --
         select nvl(sum(inf.vl_item_bruto),0)
              , nvl(sum(inf.vl_desc),0)
              , nvl(sum(inf.vl_abat_nt),0)
           into vn_vl_total_item
              , vn_vl_desconto
              , vn_vl_abat_nt
           from nota_fiscal        nf
              , item_nota_fiscal   inf
          where nf.id              = en_notafiscal_id
            and inf.notafiscal_id  = nf.id;
           --
      exception
         when others then
            vn_vl_total_item := 0;
            vn_vl_desconto   := 0;
            vn_vl_abat_nt    := 0;
      end;
      --
      vn_fase := 3;
      -- Soma valor do ISS
      begin
         --
         select sum(imp.vl_base_calc)
              , sum(imp.vl_imp_trib)
           into vn_vl_base_calc_iss
              , vn_vl_imp_trib_iss
           from nota_fiscal        nf
              , item_nota_fiscal   inf
              , imp_itemnf         imp
              , tipo_imposto       ti
          where nf.id              = en_notafiscal_id
            and inf.notafiscal_id  = nf.id
            and imp.itemnf_id      = inf.id
            and imp.dm_tipo        = 0 -- Imposto
            and ti.id              = imp.tipoimp_id
            and ti.cd              = 6; -- ISS
           --
      exception
         when others then
            vn_vl_imp_trib_iss := 0;
      end;
      --
      vn_fase := 4;
      -- Soma valor do PIS
      begin
         --
         select sum(imp.vl_imp_trib)
           into vn_vl_imp_trib_pis
           from nota_fiscal        nf
              , item_nota_fiscal   inf
              , imp_itemnf         imp
              , tipo_imposto       ti
          where nf.id              = en_notafiscal_id
            and inf.notafiscal_id  = nf.id
            and imp.itemnf_id      = inf.id
            and imp.dm_tipo        = 0 -- Imposto
            and ti.id              = imp.tipoimp_id
            and ti.cd              = 4; -- PIS
         --
      exception
         when others then
            vn_vl_imp_trib_pis := 0;
      end;
      --
      vn_fase := 5;
      -- Soma valor do COFINS
      begin
         --
         select sum(imp.vl_imp_trib)
           into vn_vl_imp_trib_cofins
           from nota_fiscal        nf
              , item_nota_fiscal   inf
              , imp_itemnf         imp
              , tipo_imposto       ti
          where nf.id              = en_notafiscal_id
            and inf.notafiscal_id  = nf.id
            and imp.itemnf_id      = inf.id
            and imp.dm_tipo        = 0 -- Imposto
            and ti.id              = imp.tipoimp_id
            and ti.cd              = 5; -- COFINS
         --
      exception
         when others then
            vn_vl_imp_trib_cofins := 0;
      end;
      --
      vn_fase := 6;
      -- Soma valor do ISS retido
      begin
         --
         select sum(imp.vl_imp_trib)
           into vn_vl_ret_iss
           from nota_fiscal        nf
              , item_nota_fiscal   inf
              , imp_itemnf         imp
              , tipo_imposto       ti
          where nf.id              = en_notafiscal_id
            and inf.notafiscal_id  = nf.id
            and imp.itemnf_id      = inf.id
            and imp.dm_tipo        = 1 -- retenção
            and ti.id              = imp.tipoimp_id
            and ti.cd              = 6; -- ISS
            --
      exception
          when others then
             vn_vl_ret_iss := 0;
      end;
      --
      vn_fase := 7;
      -- Soma valor do PIS retido
      begin
         --
         select sum(imp.vl_imp_trib)
           into vn_vl_ret_pis
           from nota_fiscal        nf
              , item_nota_fiscal   inf
              , imp_itemnf         imp
              , tipo_imposto       ti
          where nf.id              = en_notafiscal_id
            and inf.notafiscal_id  = nf.id
            and imp.itemnf_id      = inf.id
            and imp.dm_tipo        = 1 -- Retenção
            and ti.id              = imp.tipoimp_id
            and ti.cd              = 4; -- PIS
         --
      exception
         when others then
            vn_vl_ret_pis := 0;
      end;
      --
      vn_fase := 8;
      -- Soma valor do COFINS retido
      begin
         --
         select sum(imp.vl_imp_trib)
           into vn_vl_ret_cofins
           from nota_fiscal        nf
              , item_nota_fiscal   inf
              , imp_itemnf         imp
              , tipo_imposto       ti
          where nf.id              = en_notafiscal_id
            and inf.notafiscal_id  = nf.id
            and imp.itemnf_id      = inf.id
            and imp.dm_tipo        = 1 -- Retenção
            and ti.id              = imp.tipoimp_id
            and ti.cd              = 5; -- COFINS
         --
      exception
         when others then
            vn_vl_ret_cofins := 0;
      end;
      --
      vn_fase := 9;
      -- Soma valor do CSLL retido
      begin
         --
         select sum(imp.vl_imp_trib)
           into vn_vl_ret_csll
           from nota_fiscal        nf
              , item_nota_fiscal   inf
              , imp_itemnf         imp
              , tipo_imposto       ti
          where nf.id              = en_notafiscal_id
            and inf.notafiscal_id  = nf.id
            and imp.itemnf_id      = inf.id
            and imp.dm_tipo        = 1 -- Retenção
            and ti.id              = imp.tipoimp_id
            and ti.cd              = 11; -- CSLL
         --
      exception
         when others then
            vn_vl_ret_csll := 0;
      end;
      --
      vn_fase := 10;
      -- Soma valor do IRRF retido
      begin
         --
         select sum(imp.vl_base_calc)
              , sum(imp.vl_imp_trib)
           into vn_vl_base_calc_irrf
              , vn_vl_ret_irrf
           from nota_fiscal        nf
              , item_nota_fiscal   inf
              , imp_itemnf         imp
              , tipo_imposto       ti
          where nf.id              = en_notafiscal_id
            and inf.notafiscal_id  = nf.id
            and imp.itemnf_id      = inf.id
            and imp.dm_tipo        = 1 -- Retenção
            and ti.id              = imp.tipoimp_id
            and ti.cd              = 12; -- IRRF
         --
      exception
         when others then
            vn_vl_ret_irrf := 0;
      end;
      --
      vn_fase := 11;
      -- Soma valor do INSS retido
      begin
         --
         select sum(imp.vl_base_calc)
              , sum(imp.vl_imp_trib)
           into vn_vl_base_calc_ret_prev
              , vn_vl_ret_prev
           from nota_fiscal        nf
              , item_nota_fiscal   inf
              , imp_itemnf         imp
              , tipo_imposto       ti
          where nf.id              = en_notafiscal_id
            and inf.notafiscal_id  = nf.id
            and imp.itemnf_id      = inf.id
            and imp.dm_tipo        = 1 -- Retenção
            and ti.id              = imp.tipoimp_id
            and ti.cd              = 13; -- INSS
         --
      exception
         when others then
            vn_vl_ret_prev := 0;
      end;
      --
      vn_fase := 12;
      -- total da nota fiscal
      vn_vl_total_nf := nvl(vn_vl_total_item,0)
                        - nvl(vn_vl_desconto,0)
                        - nvl(vn_vl_ret_iss,0)
                        - nvl(vn_vl_ret_pis,0)
                        - nvl(vn_vl_ret_cofins,0)
                        - nvl(vn_vl_ret_csll,0)
                        - nvl(vn_vl_ret_irrf,0)
                        - nvl(vn_vl_ret_prev,0);
      --
      vn_fase := 13;
      -- insere o total
      insert into nota_fiscal_total ( id
                                    , notafiscal_id
                                    , vl_base_calc_icms
                                    , vl_imp_trib_icms
                                    , vl_base_calc_st
                                    , vl_imp_trib_st
                                    , vl_total_item
                                    , vl_frete
                                    , vl_seguro
                                    , vl_desconto
                                    , vl_imp_trib_ii
                                    , vl_imp_trib_ipi
                                    , vl_imp_trib_pis
                                    , vl_imp_trib_cofins
                                    , vl_outra_despesas
                                    , vl_total_nf
                                    , vl_serv_nao_trib
                                    , vl_base_calc_iss
                                    , vl_imp_trib_iss
                                    , vl_pis_iss
                                    , vl_cofins_iss
                                    , vl_ret_pis
                                    , vl_ret_cofins
                                    , vl_ret_csll
                                    , vl_base_calc_irrf
                                    , vl_ret_irrf
                                    , vl_base_calc_ret_prev
                                    , vl_ret_prev
                                    , vl_total_serv
                                    , vl_abat_nt
                                    , vl_forn
                                    , vl_terc
                                    , vl_servico
                                    , vl_ret_iss
                                    , vl_pis_st 
                                    , vl_cofins_st
                                    )
                             values ( notafiscaltotal_seq.nextval
                                    , en_notafiscal_id
                                    , 0 -- vl_base_calc_icms
                                    , 0 -- vl_imp_trib_icms
                                    , 0 -- vl_base_calc_st
                                    , 0 -- vl_imp_trib_st
                                    , vn_vl_total_item
                                    , 0 -- vl_frete
                                    , 0 -- vl_seguro
                                    , vn_vl_desconto
                                    , 0 -- vl_imp_trib_ii
                                    , 0 -- vl_imp_trib_ipi
                                    , vn_vl_imp_trib_pis
                                    , vn_vl_imp_trib_cofins
                                    , 0 -- vl_outra_despesas
                                    , vn_vl_total_nf
                                    , 0 -- vl_serv_nao_trib
                                    , vn_vl_base_calc_iss
                                    , vn_vl_imp_trib_iss
                                    , 0 -- vl_pis_iss
                                    , 0 -- vl_cofins_iss
                                    , vn_vl_ret_pis
                                    , vn_vl_ret_cofins
                                    , vn_vl_ret_csll
                                    , vn_vl_base_calc_irrf
                                    , vn_vl_ret_irrf
                                    , vn_vl_base_calc_ret_prev
                                    , vn_vl_ret_prev
                                    , (vn_vl_total_item - vn_vl_desconto) -- vl_total_serv
                                    , vn_vl_abat_nt -- vl_abat_nt
                                    , 0 -- vl_forn
                                    , 0 -- vl_terc
                                    , 0 -- vl_servico
                                    , vn_vl_ret_iss
                                    , 0 -- vl_pis_st
                                    , 0 -- vl_cofins_st
                                    );
      --
      vn_fase := 14;
      -- atualiza o valor das duplicatas
      for rec in c_cobr loop
         exit when c_cobr%notfound or (c_cobr%notfound) is null;
         --
         vn_fase := 14.1;
         --
         begin
            --
            select count(1) qtde
              into vn_qtde_dup
              from nfcobr_dup
             where nfcobr_id = rec.id;
            --
         exception
            when others then
               vn_qtde_dup := 0;
         end;
         --
         if nvl(vn_qtde_dup,0) = 1 then
            --
            update nfcobr_dup
               set vl_dup = vn_vl_total_nf
             where nfcobr_id = rec.id;
            --
         end if;
         --
      end loop;
      --
   end if; -- identificador da nota não informado
   --
   vn_fase := 15;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_nfs.pkb_gera_total_nfs fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%type;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => null
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => erro_de_sistema
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            raise_application_error(-20101, gv_mensagem_log);
      end;
      --
end pkb_gera_total_nfs;

-------------------------------------------------------------------------------------------------------

--| Valida informações do item

procedure pkb_valida_item_nota_fiscal ( est_log_generico_nf     in out nocopy  dbms_sql.number_table
                                      , en_notafiscal_id     in             Nota_Fiscal.Id%TYPE )
is
   --
   vn_fase             number := 0;
   vn_loggenericonf_id   log_generico_nf.id%TYPE;
   vn_qtde_item        number := 0;
   vn_empresa_id       empresa.id%type := null;
   vn_param_qtde_item  cidade_nfse.qtde_item%type := null;
   vv_conteudo_adic    nfinfor_adic.conteudo%type;
   vn_instr_descr_item   number;
   --
   cursor c_inf_adic is
   select na.conteudo
        , inf.id        itemnf_id
        , inf.descr_item
     from nfinfor_adic na
        , item_nota_fiscal inf
    where na.notafiscal_id = en_notafiscal_id
      and na.dm_tipo = 0
      and inf.notafiscal_id = en_notafiscal_id;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_notafiscal_id,0) > 0 then
      --
      vn_fase := 2;
      --
      begin
         --
         select count(1)
           into vn_qtde_item
           from item_nota_fiscal
          where notafiscal_id = en_notafiscal_id;
         --
      exception
         when others then
            vn_qtde_item := 0;
      end;
      --
      vn_fase := 2.1;
      --
      if nvl(vn_qtde_item,0) <= 0 then
         --
         gv_mensagem_log := 'Não informado o item da nota fiscal de serviço.';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_VALIDACAO
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      end if;
      --
      vn_fase := 2.2;
      --
      begin
         --
         select nf.empresa_id
           into vn_empresa_id
           from nota_fiscal nf
          where nf.id = en_notafiscal_id;
         --
      exception
         when others then
            vn_empresa_id := null;
      end;
      --
      vn_fase := 2.3;
      --
      vn_param_qtde_item := pk_csf_nfs.fkg_empresa_cidade_qtde_item ( en_empresa_id => vn_empresa_id );
      --
      if nvl(vn_qtde_item,0) > nvl(vn_param_qtde_item,1)
         and pk_csf.fkg_dmindemit_notafiscal ( en_notafiscal_id ) = 0 -- Emissão Própria
         -- and gt_row_nota_fiscal.dm_ind_emit = 0 -- Emissão Própria
         then
         --
         gv_mensagem_log := 'Não pode ser informado mais que um ("' || nvl(vn_param_qtde_item,0) || '") item da nota fiscal de serviço.';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_VALIDACAO
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      end if;
      --
      vn_fase := 3;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_nfs.pkb_valida_item_nota_fiscal fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%type;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                     , ev_mensagem        => null
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => erro_de_sistema
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_valida_item_nota_fiscal;

-------------------------------------------------------------------------------------------------------

--| Valida informações do destinatário

procedure pkb_valida_nota_fiscal_dest ( est_log_generico_nf     in out nocopy  dbms_sql.number_table
                                      , en_notafiscal_id     in             Nota_Fiscal.Id%TYPE )
is
   --
   vn_fase            number := 0;
   vn_loggenericonf_id  log_generico_nf.id%TYPE;
   vn_qtde_dest       number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_notafiscal_id,0) > 0
      and pk_csf.fkg_dmindemit_notafiscal ( en_notafiscal_id ) = 0 -- Emissão Própria
      -- and gt_row_nota_fiscal.dm_ind_emit = 0 -- emissão própria
      then
      --
      vn_fase := 2;
      --
      begin
         --
         select count(1)
           into vn_qtde_dest
           from nota_fiscal_dest
          where notafiscal_id = en_notafiscal_id;
         --
      exception
         when others then
            vn_qtde_dest := 0;
      end;
      --
      vn_fase := 2.1;
      --
      if nvl(vn_qtde_dest,0) <= 0 then
         --
         gv_mensagem_log := 'Não informado o destinatário da nota fiscal de serviço.';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_VALIDACAO
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      end if;
      --
      vn_fase := 2.2;
      --
      if nvl(vn_qtde_dest,0) > 1 then
         --
         gv_mensagem_log := 'Não pode ser informado mais que um ("1") destinatário da nota fiscal de serviço.';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_VALIDACAO
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_nfs.pkb_valida_nota_fiscal_dest fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%type;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                     , ev_mensagem        => null
                                     , ev_resumo          => gv_mensagem_log
                                     , en_tipo_log        => erro_de_sistema
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_valida_nota_fiscal_dest;

--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Validar CFOP por destinatário de NFSev de acordo com o parâmetro da empresa: empresa.dm_valida_cfop_por_dest = 0-não, 1-sim

procedure pkb_valida_cfop_por_dest ( est_log_generico_nf in out nocopy dbms_sql.number_table
                                   , en_notafiscal_id    in            nota_fiscal.id%type ) is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_nf.id%type;
   vv_uf_emit        nota_fiscal_emit.uf%type;
   vv_uf_dest        nota_fiscal_dest.uf%type;
   vn_grupo_cfop     number := null;
   vn_grupo_cfop_ret number := null;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(pk_csf.fkg_dm_valcfoppordest_empresa(en_empresa_id => gn_empresa_id),0) = 1 and -- 0-não, 1-sim
      pk_csf.fkg_cod_mod_id(nvl(gn_modfiscal_id,0)) = '99' then -- 99-serviço
      --
      vn_fase := 2;
      -- Recuperar dados do destinatário
      begin
         select nf.uf
           into vv_uf_dest
           from nota_fiscal_dest nf
          where nf.notafiscal_id = en_notafiscal_id;
      exception
         when others then
            vv_uf_dest := null;
      end;
      --
      vn_fase := 3;
      -- Recuperar dados do emitente
      begin
         select nf.uf
           into vv_uf_emit
           from nota_fiscal_emit nf
          where nf.notafiscal_id = en_notafiscal_id;
      exception
         when others then
            vv_uf_emit := null;
      end;
      --
      vn_fase := 4;
      --
      if vv_uf_emit is null and nvl(gn_dm_ind_emit,0) = 0 then -- 0-emissão própria, 1-terceiro
         --
         vn_fase := 5;
         -- Recuperar dados do emitente - empresa da nota fiscal
         begin
            select es.sigla_estado
              into vv_uf_emit
              from empresa em
                 , pessoa  pe
                 , cidade  ci
                 , estado  es
             where em.id = gn_empresa_id
               and pe.id = em.pessoa_id
               and ci.id = pe.cidade_id
               and es.id = ci.estado_id;
         exception
            when others then
               vv_uf_emit := null;
         end;
         --
      elsif vv_uf_emit is null and nvl(gn_dm_ind_emit,0) = 1 then -- 0-emissão própria, 1-terceiro
         --
         vn_fase := 6;
         -- Recuperar dados do emitente - participante da nota fiscal
         begin
            select es.sigla_estado
              into vv_uf_emit
              from pessoa  pe
                 , cidade  ci
                 , estado  es
             where pe.id = gn_pessoa_id
               and ci.id = pe.cidade_id
               and es.id = ci.estado_id;
         exception
            when others then
               vv_uf_emit := null;
         end;
         --
      end if; -- nvl(gn_dm_ind_emit,0) -- 0-emissão própria, 1-terceiro
      --
      vn_fase := 7;
      --
      if vv_uf_emit is not null and
         vv_uf_dest is not null then
         --
         vn_fase := 8;
         --
         begin
            select distinct to_number(substr(inf.cfop, 1, 1))
              into vn_grupo_cfop_ret
              from item_nota_fiscal inf
             where inf.notafiscal_id = en_notafiscal_id;
         exception
            when others then
               vn_grupo_cfop_ret := 0;
         end;
         --
         vn_fase := 9;
         -- Verifica se a nota fiscal foi emitida dentro do estado
         if vv_uf_emit = vv_uf_dest then
            --
            vn_fase := 9.1;
            -- Se for entrada informar grupo 1 senão grupo 5
            if gn_dm_ind_oper = 0 then
               vn_grupo_cfop := 1; -- Cfop de entrada dentro do estado
            else
               vn_grupo_cfop := 5; -- Cfop de saída dentro do estado
            end if;
            --
         elsif vv_uf_emit <> vv_uf_dest and
               vv_uf_dest <> 'EX' then
               --
               vn_fase := 9.2;
               -- Se for entrada informar grupo 2 senão grupo 6
               if gn_dm_ind_oper = 0 then
                  vn_grupo_cfop := 2; -- Cfop de entrada fora do estado
               else
                  vn_grupo_cfop := 6; -- Cfop de saída fora do estado
               end if;
               --
          elsif vv_uf_emit <> vv_uf_dest and
               vv_uf_dest = 'EX' then
               --
               vn_fase := 9.3;
               -- Se for entrada informar grupo 3 senão grupo 7
               if gn_dm_ind_oper = 0 then
                  vn_grupo_cfop := 3; -- Cfop de entrada fora do país
               else
                  vn_grupo_cfop := 7; -- Cfop de saída fora do país
               end if;
               --
         end if;
         --
         vn_fase := 10;
         --
         if nvl(vn_grupo_cfop,0) <> nvl(vn_grupo_cfop_ret,0) then
            --
            vn_fase := 10.1;
            --
            gv_mensagem_log := 'Grupo de CFOP esperado nos itens da nota fiscal ('||vn_grupo_cfop||'), e Grupo de CFOP informado nos itens da nota fiscal ('||
                               vn_grupo_cfop_ret||'), está divergente para o destinatário ('||vv_uf_dest||'), e emitente ('||vv_uf_emit||'), da nota fiscal.';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                , ev_mensagem         => gv_cabec_log
                                , ev_resumo           => gv_mensagem_log
                                , en_tipo_log         => erro_de_validacao
                                , en_referencia_id    => gn_referencia_id
                                , ev_obj_referencia   => gv_obj_referencia );
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                   , est_log_generico_nf => est_log_generico_nf );
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
      gv_mensagem_log := 'Erro na pk_csf_api_nfs.pkb_valida_cfop_por_dest fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%type;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                             , ev_mensagem         => null
                             , ev_resumo           => gv_mensagem_log
                             , en_tipo_log         => erro_de_sistema
                             , en_referencia_id    => gn_referencia_id
                             , ev_obj_referencia   => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_valida_cfop_por_dest;

-------------------------------------------------------------------------------------------------------
-- Procedimento para validar os impostos dos itens
-------------------------------------------------------------------------------------------------------
procedure pkb_valida_imposto_item ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                  , en_notafiscal_id    in             Nota_Fiscal.Id%TYPE )
is
   --
   vn_fase                    number := 0;
   vn_loggenericonf_id        log_generico_nf.id%type;
   vv_cod_st_comp             cod_st.cod_st%type;
   vn_base_calc_comp          imp_itemnf.vl_base_calc%type;
   vn_imp_trib                number;
   vn_qtde_iss                number;
   vn_qtde_pis                number;
   vn_qtde_cofins             number;
   vn_dm_valida_pis           empresa.dm_valida_pis_emiss_nfs%type; -- a mesma variável será utilizada para o indicador dm_valida_pis_terc_nfs
   vn_dm_valida_cofins        empresa.dm_valida_cofins_emiss_nfs%type; -- a mesma variável será utilizada para o indicador dm_valida_cofins_terc_nfs
   vn_dm_valida_iss           number(1);
   vn_vl_toler_nf             number;
   vn_dif_valor               number;
   --
   vn_qtde_iss_imp            number := 0;
   vn_qtde_iss_ret            number := 0;
   --
   cursor c_item_nf is
   select itnf.id
        , itnf.notafiscal_id
        , itnf.item_id
        , itnf.nro_item
        , itnf.cod_item
        , itnf.dm_ind_mov
        , itnf.cean
        , itnf.descr_item
        , itnf.cod_ncm
        , itnf.genero
        , itnf.cod_ext_ipi
        , itnf.cfop_id
        , itnf.cfop
        , itnf.unid_com
        , itnf.qtde_comerc
        , itnf.vl_unit_comerc
        , itnf.vl_item_bruto
        , itnf.cean_trib
        , itnf.unid_trib
        , itnf.qtde_trib
        , itnf.vl_unit_trib
        , itnf.vl_frete
        , itnf.vl_seguro
        , itnf.vl_desc
        , itnf.infadprod
        , itnf.orig
        , itnf.dm_mod_base_calc
        , itnf.dm_mod_base_calc_st
        , itnf.cnpj_produtor
        , itnf.qtde_selo_ipi
        , itnf.vl_desp_adu
        , itnf.vl_iof
        , itnf.classenqipi_id
        , itnf.cl_enq_ipi
        , itnf.selocontripi_id
        , itnf.cod_selo_ipi
        , itnf.cod_enq_ipi
        , itnf.cidade_ibge
        , itnf.cd_lista_serv
        , itnf.dm_ind_apur_ipi
        , itnf.cod_cta
        , itnf.dm_mot_des_icms
        , itnf.dm_cod_trib_issqn
        , nf.empresa_id
        , nf.dm_ind_emit
        , mf.cod_mod
     from Item_Nota_Fiscal itnf
        , Nota_Fiscal      nf
        , mod_fiscal       mf
    where nf.id              = en_notafiscal_id
      and itnf.notafiscal_id = nf.id
      and mf.id              = nf.modfiscal_id
    order by itnf.nro_item;
   --
   cursor c_imposto ( en_itemnf_id Item_Nota_Fiscal.id%TYPE ) is
   select imp.id
        , imp.itemnf_id
        , imp.tipoimp_id
        , ti.cd          cd_imp
        , ti.descr
        , ti.sigla
        , imp.dm_tipo
        , imp.codst_id
        , st.cod_st
        , st.descr_st
        , imp.vl_base_calc
        , imp.aliq_apli
        , imp.vl_imp_trib
        , imp.perc_reduc
        , imp.perc_adic
        , imp.qtde_base_calc_prod
        , imp.vl_aliq_prod
        , imp.vl_bc_st_ret
        , imp.vl_icmsst_ret
        , imp.perc_bc_oper_prop
        , imp.estado_id
        , imp.vl_bc_st_dest
        , imp.vl_icmsst_dest
     from Imp_ItemNf      imp
        , Cod_ST          st
        , Tipo_Imposto    ti
    where imp.itemnf_id = en_itemnf_id
      and st.id(+)      = imp.codst_id
      and ti.id         = imp.tipoimp_id
    order by imp.id;
   --
   cursor c_dados_imp ( en_itemnf_id Item_Nota_Fiscal.id%TYPE
                      , en_cd_imposto tipo_imposto.cd%type
                      ) is
   select cst.cod_st
        , ii.vl_base_calc
     from imp_itemnf    ii
        , tipo_imposto  ti
        , cod_st        cst
    where ii.itemnf_id  = en_itemnf_id
      and ii.dm_tipo    = 0
      and ti.id         = ii.tipoimp_id
      and ti.cd         = en_cd_imposto
      and cst.id        = ii.codst_id;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_notafiscal_id,0) > 0 then
      --
      vn_fase := 1.1;
      -- Função retorna o valor de tolerância para os valores de documentos fiscais (nf) e caso não exista manter 0.03
      vn_vl_toler_nf := pk_csf.fkg_vlr_toler_empresa ( en_empresa_id => pk_csf.fkg_busca_empresa_nf ( en_notafiscal_id => en_notafiscal_id )
                                                     , ev_opcao      => 'NF' );
      --
      vn_fase := 2;
      -- Recupero os itens da nota fiscal
      for rec_item_nf in c_item_nf loop
         exit when c_item_nf%notfound or c_item_nf%notfound is null;
         --
         vn_fase := 2.1;
         --
         vn_qtde_pis    := 0;
         vn_qtde_cofins := 0;
         --
         if rec_item_nf.dm_ind_emit = 0 then -- nota fiscal com emissão própria
            vn_dm_valida_pis    := pk_csf_nfs.fkg_empresa_dmvalpisemiss_nfs ( en_empresa_id => rec_item_nf.empresa_id );
            vn_dm_valida_cofins := pk_csf_nfs.fkg_empresa_dmvalcofemiss_nfs ( en_empresa_id => rec_item_nf.empresa_id );
            vn_dm_valida_iss    := pk_csf.fkg_empresa_vld_iss_epropria ( en_empresa_id => rec_item_nf.empresa_id );
         else -- rec_item_nf.dm_ind_emit = 1 -- nota fiscal com emissão de terceiros
            vn_dm_valida_pis    := pk_csf_nfs.fkg_empresa_dmvalpisterc_nfs ( en_empresa_id => rec_item_nf.empresa_id );
            vn_dm_valida_cofins := pk_csf_nfs.fkg_empresa_dmvalcofterc_nfs ( en_empresa_id => rec_item_nf.empresa_id );
            vn_dm_valida_iss    := pk_csf.fkg_empresa_vld_iss_terc ( en_empresa_id => rec_item_nf.empresa_id );
         end if;
         --
         --| Se é obrigatório validar o imposto de PIS, então verifica se o mesmo foi informado para Emissão de Terceiro
         -- PIS -- CD: 4
         if vn_dm_valida_pis = 1 --and rec_item_nf.dm_ind_emit = 1
            then
            --
            vn_fase := 2.2;
            --
            begin
            --
               select count(1)
                 into vn_qtde_pis
                 from imp_itemnf     imp
                    , tipo_imposto   ti
                where imp.itemnf_id  = rec_item_nf.id
                  and ti.id          = imp.tipoimp_id
                  and ti.cd          = '4' -- PIS
                  and imp.dm_tipo    = 0;
               --
            exception
               when others then
                  vn_qtde_pis := 0;
            end;
            --
            vn_fase := 2.3;
            --
            if nvl(vn_qtde_pis,0) <= 0 then
               --
               vn_fase := 2.4;
               --
               gv_mensagem_log := 'Não informado o imposto de PIS para o item.';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                   , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                   , ev_resumo           => gv_mensagem_log
                                   , en_tipo_log         => erro_de_validacao
                                   , en_referencia_id    => gn_referencia_id
                                   , ev_obj_referencia   => gv_obj_referencia
                                   , en_dm_impressa      => 0 );
               --
               pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                      , est_log_generico_nf => est_log_generico_nf );
               --
            elsif nvl(vn_qtde_pis,0) > 1 then
               --
               vn_fase := 2.5;
               --
               gv_mensagem_log := 'Informado mais de um imposto de PIS para o item.';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                   , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                   , ev_resumo           => gv_mensagem_log
                                   , en_tipo_log         => erro_de_validacao
                                   , en_referencia_id    => gn_referencia_id
                                   , ev_obj_referencia   => gv_obj_referencia
                                   , en_dm_impressa      => 0 );
               --
               pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                      , est_log_generico_nf => est_log_generico_nf );
               --
            end if;
            --
         end if;
         --| Se é obrigatório validar o imposto de COFINS, então verifica se o mesmo foi informado para Emissão de Terceiro
         -- COFINS -- CD: 5
         if vn_dm_valida_cofins = 1 --and rec_item_nf.dm_ind_emit = 1
            then
            --
            vn_fase := 2.6;
            --
            begin
               --
               select count(1)
                 into vn_qtde_cofins
                 from imp_itemnf     imp
                    , tipo_imposto   ti
                where imp.itemnf_id  = rec_item_nf.id
                  and ti.id          = imp.tipoimp_id
                  and ti.cd          = '5' -- COFINS
               and imp.dm_tipo    = 0;
            --
            exception
               when others then
                  vn_qtde_cofins := 0;
            end;
            --
            vn_fase := 2.7;
            --
            if nvl(vn_qtde_cofins,0) <= 0 then
               --
               vn_fase := 2.8;
               --
               gv_mensagem_log := 'Não informado o imposto de COFINS para o item.';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                   , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                   , ev_resumo           => gv_mensagem_log
                                   , en_tipo_log         => erro_de_validacao
                                   , en_referencia_id    => gn_referencia_id
                                   , ev_obj_referencia   => gv_obj_referencia
                                   , en_dm_impressa      => 0 );
               --
               pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                      , est_log_generico_nf => est_log_generico_nf );
               --
            elsif nvl(vn_qtde_cofins,0) > 1 then
               --
               vn_fase := 2.9;
               --
               gv_mensagem_log := 'Informado mais de um imposto de COFINS para o item.';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                   , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                   , ev_resumo           => gv_mensagem_log
                                   , en_tipo_log         => erro_de_validacao
                                   , en_referencia_id    => gn_referencia_id
                                   , ev_obj_referencia   => gv_obj_referencia
                                   , en_dm_impressa      => 0 );
               --
               pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                      , est_log_generico_nf => est_log_generico_nf );
               --
            end if;
            --
         end if;
         --
         if vn_dm_valida_iss = 1 -- Valida ISS = SIM
            and rec_item_nf.cod_mod = '99' -- Apenas Modelo de Serviço
            then
           --
           vn_fase := 2.10;
           --
           begin
             select count(1)
               into vn_qtde_iss_imp
               from imp_itemnf imp, 
                    tipo_imposto ti
              where imp.itemnf_id = rec_item_nf.id
                and ti.id         = imp.tipoimp_id
                and ti.cd         = '6' -- ISS
                and imp.dm_tipo   = 0; -- Imposto
           exception
             when others then
               vn_qtde_iss_imp := 0;
           end;
           --
           begin
             select count(1)
               into vn_qtde_iss_ret
               from imp_itemnf imp, 
                    tipo_imposto ti
              where imp.itemnf_id = rec_item_nf.id
                and ti.id         = imp.tipoimp_id
                and ti.cd         = '6' -- ISS
                and imp.dm_tipo   = 1; -- Retenção
           exception
             when others then
               vn_qtde_iss_ret := 0;
           end;
           --
           vn_fase := 2.11;
           --
           if (nvl(vn_qtde_iss_imp, 0) <= 0 and nvl(vn_qtde_iss_ret, 0) <= 0) then
             --
             vn_fase := 2.12;
             --
             gv_mensagem_log := 'Não informado o imposto de ISS para o item.';
             --
             vn_loggenericonf_id := null;
             --
             pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenericonf_id,
                                 ev_mensagem         => gv_cabec_log || gv_cabec_log_item,
                                 ev_resumo           => gv_mensagem_log,
                                 en_tipo_log         => ERRO_DE_VALIDACAO, -- ERRO_DE_VALIDACAO
                                 en_referencia_id    => gn_referencia_id,
                                 ev_obj_referencia   => gv_obj_referencia,
                                 en_dm_impressa      => 0);
             --
             pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenericonf_id,
                                    est_log_generico_nf => est_log_generico_nf);
             --
           elsif (nvl(vn_qtde_iss_imp, 0) > 1 or nvl(vn_qtde_iss_ret, 0) > 1) then
             --
             vn_fase := 2.12;
             --
             gv_mensagem_log := 'Informado mais de um imposto de ISS para o item.';
             --
             vn_loggenericonf_id := null;
             --
             pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenericonf_id,
                                 ev_mensagem         => gv_cabec_log || gv_cabec_log_item,
                                 ev_resumo           => gv_mensagem_log,
                                 en_tipo_log         => ERRO_DE_VALIDACAO, -- ERRO_DE_VALIDACAO
                                 en_referencia_id    => gn_referencia_id,
                                 ev_obj_referencia   => gv_obj_referencia,
                                 en_dm_impressa      => 0);
             --
             pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenericonf_id,
                                    est_log_generico_nf => est_log_generico_nf);
             --
           end if;
           --
         end if;
         --
         vn_fase := 3;
         -- Recupera os impostos do Item da Nota Fiscal
         for rec_imp in c_imposto(rec_item_nf.id) loop
             exit when c_imposto%notfound or (c_imposto%notfound) is null;
             --
             vn_fase := 4;
             --
             if rec_imp.cd_imp = 4   -- PIS
                and rec_imp.dm_tipo = 0 -- IMPOSTO
                then
                --
                vn_fase := 5;
                -- valida dados de combinação de pis/cofins
                open c_dados_imp ( rec_item_nf.id
                                 , 5 --> COFINS
                                 );
                fetch c_dados_imp into vv_cod_st_comp, vn_base_calc_comp;
                if c_dados_imp%notfound then
                   vv_cod_st_comp := null;
                   vn_base_calc_comp := null;
                end if;
                close c_dados_imp;
                --
                vn_fase := 5.1;
                -- Valida se os dados do PIS são iguais ao do COFINS
                if vv_cod_st_comp is null then
                   --
                   gv_mensagem_log := 'Não informado o Imposto da COFINS para comparar os valores de CST e Base de Cálculo.';
                   --
                   vn_loggenericonf_id := null;
                   --
                   pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                       , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                       , ev_resumo           => gv_mensagem_log
                                       , en_tipo_log         => informacao -- ERRO_DE_VALIDACAO
                                       , en_referencia_id    => gn_referencia_id
                                       , ev_obj_referencia   => gv_obj_referencia
                                       , en_dm_impressa      => 0 );
                   --
                else
                   --
                   vn_fase := 6;
                   --
                   if vv_cod_st_comp <> rec_imp.cod_st then
                      --
                      gv_mensagem_log := 'Situação Tributária do COFINS ('||vv_cod_st_comp||') está diferente da Situação Tributária do PIS ('||
                                         rec_imp.cod_st||').';
                      --
                      vn_loggenericonf_id := null;
                      --
                      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                       , ev_resumo          => gv_mensagem_log
                                       , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                       , en_referencia_id   => gn_referencia_id
                                       , ev_obj_referencia  => gv_obj_referencia
                                       , en_dm_impressa     => 0 );
                      --
                      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                          , est_log_generico_nf  => est_log_generico_nf );
                      --
                   end if;
                   --
                   vn_fase := 7;
                   --
                   vn_dif_valor := nvl(vn_base_calc_comp,0) - nvl(rec_imp.vl_base_calc,0);
                   --
                   vn_fase := 8;
                   --
                   if nvl(vn_base_calc_comp,0) <> nvl(rec_imp.vl_base_calc,0) and
                     ((nvl(vn_dif_valor,0) < (nvl(vn_vl_toler_nf,0) * -1)) or (nvl(vn_dif_valor,0) > nvl(vn_vl_toler_nf,0))) then
                      --
                      gv_mensagem_log := 'Base de Cálculo do COFINS ('||to_char(nvl(vn_base_calc_comp,0),'999G999G999G999G990D00')||') está diferente da '||
                                         'Base de Cálculo do PIS ('||to_char(nvl(rec_imp.vl_base_calc,0),'999G999G999G999G990D00')||').' ;
                      --
                      vn_loggenericonf_id := null;
                      --
                      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                       , ev_resumo          => gv_mensagem_log
                                       , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                       , en_referencia_id   => gn_referencia_id
                                       , ev_obj_referencia  => gv_obj_referencia
                                       , en_dm_impressa     => 0 );
                      --
                      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                          , est_log_generico_nf  => est_log_generico_nf );
                      --
                   end if;
                   --
                end if;
                --
                vn_fase := 9;
                --| Validações utilizadas para Emissão de Terceiro e se a empresa valida o PIS
                if vn_dm_valida_pis = 1 --and rec_item_nf.dm_ind_emit = 1
                   then
                   --
                   vn_fase := 9.1;
                   -- Valida CST de PIS para entrada
                   if gt_row_Nota_Fiscal.dm_ind_oper = 0 -- Entrada
                      and rec_imp.cod_st not in ( '50', '51', '52', '53', '54', '55', '56'
                                                , '60', '61', '62', '63', '64', '65', '66', '67'
                                                , '70', '71', '72', '73', '74', '75', '98', '99')
                      then
                      --
                      vn_fase := 9.2;
                      --
                      gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                         'Está inválida para o tipo de Operação Entrada informada ao mesmo tempo para o Tipo de Imposto: '||rec_imp.sigla;
                      --
                      vn_loggenericonf_id := null;
                      --
                      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                       , ev_resumo          => gv_mensagem_log
                                       , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                       , en_referencia_id   => gn_referencia_id
                                       , ev_obj_referencia  => gv_obj_referencia
                                       , en_dm_impressa     => 0 );
                      --
                      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                          , est_log_generico_nf  => est_log_generico_nf );
                      --
                   end if;
                   --
                   vn_fase := 9.3;
                   --
                   -- Valida CST de PIS para Saída
                   --if gt_row_Nota_Fiscal.dm_ind_oper = 1 -- Saída
                   if pk_csf.fkg_recup_dmindoper_nf_id ( en_notafiscal_id ) = 1 -- Saída
                      and rec_imp.cod_st not in ('01', '02', '03', '04', '05', '06', '07', '08', '09', '49', '99')
                      then
                      --
                      vn_fase := 9.4;
                      --
                      gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                         'Está inválida para o tipo de Operação Saída informada ao mesmo tempo para o Tipo de Imposto: '||rec_imp.sigla;
                      --
                      vn_loggenericonf_id := null;
                      --
                      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                       , ev_resumo          => gv_mensagem_log
                                       , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                       , en_referencia_id   => gn_referencia_id
                                       , ev_obj_referencia  => gv_obj_referencia
                                       , en_dm_impressa     => 0 );
                      --
                      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                          , est_log_generico_nf  => est_log_generico_nf );
                      --
                   end if;
                   --
                   if rec_imp.cod_st in ('01', '02') then
                   -- 01 - Operação Tributável (base de cálculo = valor da operação alíquota normal (cumulativo/não cumulativo))
                   -- 02 - Operação Tributável (base de cálculo = valor da operação (alíquota diferenciada))
                      --
                      --vn_imp_trib := round(nvl(rec_imp.aliq_apli,0) * nvl(rec_imp.vl_base_calc,0), 2);
                      vn_imp_trib := round((nvl(rec_imp.vl_base_calc,0) * (nvl(rec_imp.aliq_apli,0) / 100)), 2);
                      --
                      if nvl(rec_imp.vl_base_calc,0) <= 0 then
                         --
                         vn_fase := 9.5;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Está com o "Valor da Base de Cálculo do PIS" divergente para o Tipo de Imposto: '||rec_imp.sigla||chr(10)||
                                            'Informado: '||to_char(nvl(rec_imp.vl_base_calc,0),'999G999G999G999G990D00');
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                      vn_fase := 9.6;
                      --
                      if nvl(rec_imp.aliq_apli,0) <= 0 then
                         --
                         vn_fase := 9.7;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Está com a "Alíquota do PIS (em percentual)" divergente para o Tipo de Imposto: '||rec_imp.sigla;
                         --
                         vn_loggenericonf_id := null;
                          --
                          pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                           , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                           , ev_resumo          => gv_mensagem_log
                                           , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                           , en_referencia_id   => gn_referencia_id
                                           , ev_obj_referencia  => gv_obj_referencia
                                           , en_dm_impressa     => 0 );
                          --
                          pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                              , est_log_generico_nf  => est_log_generico_nf );
                          --
                      end if;
                      --
                      vn_fase := 9.8;
                      --
                      if nvl(rec_imp.vl_imp_trib,0) <= 0 and nvl(vn_imp_trib,0) > 0 then
                         --
                         vn_fase := 9.9;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Está com o valor "Valor do PIS" divergente para o Tipo de Imposto: '||rec_imp.sigla||chr(10)||
                                            'Informado: '||to_char(nvl(rec_imp.vl_imp_trib,0),'999G999G999G999G990D00')||'; Para conferência: '||
                                            to_char(nvl(vn_imp_trib,0),'999G999G999G999G990D00')||'.';
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                   elsif rec_imp.cod_st = '03' then    -- Operação Tributável (base de cálculo = quantidade vendida x alíquota por unidade de produto)
                      --
                      vn_fase := 9.10;
                      --
                      if nvl(rec_imp.qtde_base_calc_prod,0) <= 0 then
                         --
                         vn_fase := 9.11;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Está com o "Quantidade Vendida do PIS" divergente para o Tipo de Imposto: '||rec_imp.sigla||chr(10)||
                                            'Informado: '||to_char(nvl(rec_imp.vl_base_calc,0),'999G999G999G999G990D00');
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                      vn_fase := 9.12;
                      --
                      if nvl(rec_imp.vl_aliq_prod,0) <= 0 then
                         --
                         vn_fase := 9.13;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Está com a "Alíquota do PIS (em reais)" divergente para o Tipo de Imposto: '||rec_imp.sigla;
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                      vn_fase := 9.14;
                      --
                      if nvl(rec_imp.vl_imp_trib,0) <= 0 then
                         --
                         vn_fase := 9.15;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Está com o valor "Valor do PIS" divergente para o Tipo de Imposto: '||rec_imp.sigla||chr(10)||
                                            'Informado: '||to_char(nvl(rec_imp.vl_imp_trib,0),'999G999G999G999G990D00');
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                   elsif rec_imp.cod_st = '99' then    -- Outras Operações
                      --
                      vn_fase := 9.16;
                      --
                      if nvl(rec_imp.vl_base_calc,0) > 0 and nvl(rec_imp.qtde_base_calc_prod,0) > 0 then
                         --
                         vn_fase := 9.17;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Não pode ter informado o "Valor da Base de Cálculo do PIS" e a "Quantidade Vendida PIS" '||
                                            'informada ao mesmo tempo para o Tipo de Imposto: '||rec_imp.sigla;
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                      vn_fase := 9.18;
                      --
                      if nvl(rec_imp.aliq_apli,0) > 0 and nvl(rec_imp.vl_aliq_prod,0) > 0 then
                         --
                         vn_fase := 9.19;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Não pode ter informada a "Alíquota do PIS (em percentual)" e a "Alíquota do PIS (em reais)" '||
                                            'informada ao mesmo tempo para o Tipo de Imposto: '||rec_imp.sigla;
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                      vn_fase := 9.20;
                      -- Válida informação do imposto por quantidade
                      if nvl(rec_imp.aliq_apli,0) < 0 or nvl(rec_imp.vl_base_calc,0) < 0 then
                         --
                         vn_fase := 9.21;
                         -- Válida o valor da alíquota em reais
                         if nvl(rec_imp.vl_aliq_prod,0) < 0 then
                            --
                            vn_fase := 9.22;
                            --
                            gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                               '"Alíquota do PIS (em reais)" deve ser informada e maior que zero para o Tipo de Imposto: '||rec_imp.sigla;
                            --
                            vn_loggenericonf_id := null;
                            --
                            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                             , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                             , ev_resumo          => gv_mensagem_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             , en_dm_impressa     => 0 );
                            --
                            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                                , est_log_generico_nf  => est_log_generico_nf );
                            --
                         end if;
                         --
                         vn_fase := 9.23;
                         --
                         if nvl(rec_imp.qtde_base_calc_prod,0) < 0 then
                            --
                            vn_fase := 9.24;
                            --
                            gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                               '"Quantidade Vendida do PIS" deve ser informada e maior que zero para o Tipo de Imposto: '||rec_imp.sigla;
                            --
                            vn_loggenericonf_id := null;
                            --
                            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                             , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                             , ev_resumo          => gv_mensagem_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             , en_dm_impressa     => 0 );
                            --
                            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                                , est_log_generico_nf  => est_log_generico_nf );
                            --
                         end if;
                         --
                         vn_fase := 9.25;
                         -- Se o imposto é por quantidade e valor, não pode ser informado a Base e percentual
                         if nvl(rec_imp.aliq_apli,0) > 0 then
                            --
                            vn_fase := 9.26;
                            --
                            gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                               '"Alíquota do PIS (em percentual)" não deve ser informada para o Tipo de Imposto: '||rec_imp.sigla;
                            --
                            vn_loggenericonf_id := null;
                            --
                            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                             , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                             , ev_resumo          => gv_mensagem_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             , en_dm_impressa     => 0 );
                            --
                            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                                , est_log_generico_nf  => est_log_generico_nf );
                            --
                         end if;
                         --
                         vn_fase := 9.27;
                         --
                         if nvl(rec_imp.vl_base_calc,0) > 0 then
                            --
                            vn_fase := 9.28;
                            --
                            gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                               '"Valor da Base de Cálculo do PIS" não deve ser informada para o Tipo de Imposto: '||rec_imp.sigla;
                            --
                            vn_loggenericonf_id := null;
                            --
                            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                             , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                             , ev_resumo          => gv_mensagem_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             , en_dm_impressa     => 0 );
                            --
                            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                                , est_log_generico_nf  => est_log_generico_nf );
                            --
                         end if;
                         --
                      end if;
                      --
                      vn_fase := 9.29;
                      -- Imposto por alíquota
                      if nvl(rec_imp.vl_aliq_prod,0) < 0 or nvl(rec_imp.qtde_base_calc_prod,0) < 0 then
                         --
                         vn_fase := 9.30;
                         -- Se o imposto é por quantidade e valor, não pode ser informado a Base e percentual
                         if nvl(rec_imp.aliq_apli,0) < 0 then
                            --
                            vn_fase := 9.31;
                            --
                            gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                               '"Alíquota do PIS (em percentual)" deve ser informada e maior que zero para o Tipo de Imposto: '||rec_imp.sigla;
                            --
                            vn_loggenericonf_id := null;
                            --
                            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                             , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                             , ev_resumo          => gv_mensagem_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             , en_dm_impressa     => 0 );
                            --
                            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                                , est_log_generico_nf  => est_log_generico_nf );
                            --
                         end if;
                         --
                         vn_fase := 9.32;
                         --
                         if nvl(rec_imp.vl_base_calc,0) < 0 then
                            --
                            vn_fase := 9.33;
                            --
                            gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                               '"Valor da Base de Cálculo do PIS" deve ser informada e maior que zero para o Tipo de Imposto: '||rec_imp.sigla;
                            --
                            vn_loggenericonf_id := null;
                            --
                            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                             , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                             , ev_resumo          => gv_mensagem_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             , en_dm_impressa     => 0 );
                            --
                            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                                , est_log_generico_nf  => est_log_generico_nf );
                            --
                         end if;
                         --
                         vn_fase := 9.34;
                         -- Válida o valor da alíquota em reais
                         if nvl(rec_imp.vl_aliq_prod,0) > 0 then
                            --
                            vn_fase := 9.35;
                            --
                            gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                               '"Alíquota do PIS (em reais)" não deve ser informada para o Tipo de Imposto: '||rec_imp.sigla;
                            --
                            vn_loggenericonf_id := null;
                            --
                            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                             , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                             , ev_resumo          => gv_mensagem_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             , en_dm_impressa     => 0 );
                            --
                            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                                , est_log_generico_nf  => est_log_generico_nf );
                            --
                         end if;
                         --
                         vn_fase := 9.36;
                         --
                         if nvl(rec_imp.qtde_base_calc_prod,0) > 0 then
                            --
                            vn_fase := 9.37;
                            --
                            gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                               '"Quantidade Vendida do PIS" não deve ser informada para o Tipo de Imposto: '||rec_imp.sigla;
                            --
                            vn_loggenericonf_id := null;
                            --
                            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                             , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                             , ev_resumo          => gv_mensagem_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             , en_dm_impressa     => 0 );
                            --
                            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                                , est_log_generico_nf  => est_log_generico_nf );
                            --
                         end if;
                         --
                      end if;
                      --
                      vn_fase := 9.38;
                      --
                      if nvl(rec_imp.vl_imp_trib,0) < 0 then
                         --
                         vn_fase := 9.39;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Está com o valor "Valor do PIS" divergente para o Tipo de Imposto: '||rec_imp.sigla||chr(10)||
                                            'Informado: '||to_char(nvl(rec_imp.vl_imp_trib,0),'999G999G999G999G990D00');
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                   end if;
                   --
                   vn_fase := 9.40;
                   --
                   -- Valida situação tributária isenta
                   if rec_imp.cod_st in ('04', '06', '07', '08', '09', '70', '71', '72', '73', '74', '75') then
                      --
                      vn_fase := 9.41;
                      --
                      if nvl(rec_imp.vl_base_calc,0) > 0 and rec_imp.cod_st <> '06' then
                         --
                         vn_fase := 9.42;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Não permite "Valor da Base de Cálculo do PIS" para o Tipo de Imposto: '||rec_imp.sigla||chr(10)||
                                            'Informado: '||to_char(nvl(rec_imp.vl_base_calc,0),'999G999G999G999G990D00');
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                      vn_fase := 9.43;
                      --
                      if nvl(rec_imp.aliq_apli,0) > 0 then
                         --
                         vn_fase := 9.44;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Não permite "Alíquota do PIS (em percentual)" para o Tipo de Imposto: '||rec_imp.sigla||chr(10)||
                                            'Informado: '||to_char(nvl(rec_imp.aliq_apli,0),'999G999G999G999G990D00');
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                      vn_fase := 9.45;
                      --
                      if nvl(rec_imp.vl_imp_trib,0) > 0 then
                         --
                         vn_fase := 9.46;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Não permite "Valor do PIS" para o Tipo de Imposto: '||rec_imp.sigla||chr(10)||
                                            'Informado: '||to_char(nvl(rec_imp.vl_imp_trib,0),'999G999G999G999G990D00');
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                      vn_fase := 9.47;
                      --
                      if nvl(rec_imp.qtde_base_calc_prod,0) > 0 then
                         --
                         vn_fase := 9.48;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Não permite "Quantidade Vendida do PIS" para o Tipo de Imposto: '||rec_imp.sigla||chr(10)||
                                            'Informado: '||to_char(nvl(rec_imp.qtde_base_calc_prod,0),'999G999G999G999G990D00');
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                      vn_fase := 9.49;
                      --
                      if nvl(rec_imp.vl_aliq_prod,0) > 0 then
                         --
                         vn_fase := 9.50;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Não permite "Alíquota do PIS (em reais)" para o Tipo de Imposto: '||rec_imp.sigla||chr(10)||
                                            'Informado: '||to_char(nvl(rec_imp.vl_aliq_prod,0),'999G999G999G999G990D00');
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                   end if;
                   --
                end if;
                --
             elsif rec_imp.cd_imp = 5   -- COFINS
                and rec_imp.dm_tipo = 0 -- IMPOSTO
                then
                --
                vn_fase := 10;
                --
                -- valida dados de combinação de pis/cofins
                open c_dados_imp ( rec_item_nf.id
                                 , 4 --> PIS
                                 );
                fetch c_dados_imp into vv_cod_st_comp, vn_base_calc_comp;
                if c_dados_imp%notfound then
                   vv_cod_st_comp := null;
                   vn_base_calc_comp := null;
                end if;
                close c_dados_imp;
                --
                vn_fase := 10.1;
                -- Valida se os dados do PIS são iguais ao do COFINS
                if vv_cod_st_comp is null then
                   --
                   gv_mensagem_log := 'Não informado o Imposto do PIS para comparar os valores de CST e Base de Cálculo.';
                   --
                   vn_loggenericonf_id := null;
                   --
                   pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                       , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                       , ev_resumo           => gv_mensagem_log
                                       , en_tipo_log         => informacao -- ERRO_DE_VALIDACAO
                                       , en_referencia_id    => gn_referencia_id
                                       , ev_obj_referencia   => gv_obj_referencia
                                       , en_dm_impressa      => 0 );
                   --
                else
                   --
                   vn_fase := 10.2;
                   --
                   if vv_cod_st_comp <> rec_imp.cod_st then
                      --
                      gv_mensagem_log := 'Situação Tributária do PIS ('||vv_cod_st_comp||') está diferente da Situação Tributária do COFINS ('||
                                         rec_imp.cod_st||').';
                      --
                      vn_loggenericonf_id := null;
                      --
                      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                       , ev_resumo          => gv_mensagem_log
                                       , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                       , en_referencia_id   => gn_referencia_id
                                       , ev_obj_referencia  => gv_obj_referencia
                                       , en_dm_impressa     => 0 );
                      --
                      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                          , est_log_generico_nf  => est_log_generico_nf );
                      --
                   end if;
                   --
                   vn_fase := 10.3;
                   --
                   vn_dif_valor := nvl(vn_base_calc_comp,0) - nvl(rec_imp.vl_base_calc,0);
                   --
                   vn_fase := 10.4;
                   --
                   if nvl(vn_base_calc_comp,0) <> nvl(rec_imp.vl_base_calc,0) and
                     ((nvl(vn_dif_valor,0) < (nvl(vn_vl_toler_nf,0) * -1)) or (nvl(vn_dif_valor,0) > nvl(vn_vl_toler_nf,0)))then
                      --
                      gv_mensagem_log := 'Base de Cálculo do PIS ('||to_char(nvl(vn_base_calc_comp,0),'999G999G999G999G990D00')||
                                         ') está diferente da Base de Cálculo do COFINS ('||to_char(nvl(rec_imp.vl_base_calc,0),'999G999G999G999G990D00')||').';
                      --
                      vn_loggenericonf_id := null;
                      --
                      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                       , ev_resumo          => gv_mensagem_log
                                       , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                       , en_referencia_id   => gn_referencia_id
                                       , ev_obj_referencia  => gv_obj_referencia
                                       , en_dm_impressa     => 0 );
                      --
                      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                          , est_log_generico_nf  => est_log_generico_nf );
                      --
                   end if;
                   --
                end if;
                --
                vn_fase := 11;
                --| Validações utilizadas para Emissão de Terceiro e se a empresa valida o COFINS
                if vn_dm_valida_cofins = 1 --and rec_item_nf.dm_ind_emit = 1
                   then
                   --
                   vn_fase := 12;
                   -- Valida CST de Cofins para entrada
                   --if gt_row_Nota_Fiscal.dm_ind_oper = 0 -- Entrada
                   if pk_csf.fkg_recup_dmindoper_nf_id ( en_notafiscal_id ) = 0 -- Entrada
                      and rec_imp.cod_st not in ( '50', '51', '52', '53', '54', '55', '56'
                                                , '60', '61', '62', '63', '64', '65', '66', '67'
                                                , '70', '71', '72', '73', '74', '75', '98', '99')
                      then
                      --
                      vn_fase := 12.1;
                      --
                      gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                         'Está inválida para o tipo de Operação Entrada informada ao mesmo tempo para o Tipo de Imposto: '||rec_imp.sigla;
                      --
                      vn_loggenericonf_id := null;
                      --
                      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                       , ev_resumo          => gv_mensagem_log
                                       , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                       , en_referencia_id   => gn_referencia_id
                                       , ev_obj_referencia  => gv_obj_referencia
                                       , en_dm_impressa     => 0 );
                      --
                      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                          , est_log_generico_nf  => est_log_generico_nf );
                      --
                   end if;
                   --
                   vn_fase := 12.2;
                   --
                   -- Valida CST de PIS para Saída
                   -- if gt_row_Nota_Fiscal.dm_ind_oper = 1 -- Saída
                   if pk_csf.fkg_recup_dmindoper_nf_id ( en_notafiscal_id ) = 1 -- Saída
                      and rec_imp.cod_st not in ('01', '02', '03', '04', '05', '06', '07', '08', '09', '49', '99')
                      then
                      --
                      vn_fase := 12.3;
                      --
                      gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                         'Está inválida para o tipo de Operação Saída informada ao mesmo tempo para o Tipo de Imposto: '||rec_imp.sigla;
                      --
                      vn_loggenericonf_id := null;
                      --
                      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                       , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                       , ev_resumo          => gv_mensagem_log
                                       , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                       , en_referencia_id   => gn_referencia_id
                                       , ev_obj_referencia  => gv_obj_referencia
                                       , en_dm_impressa     => 0 );
                      --
                      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                          , est_log_generico_nf  => est_log_generico_nf );
                      --
                   end if;
                   --
                   vn_fase := 12.4;
                   --
                   if rec_imp.cod_st in ('01', '02') then
                      -- 01 - Operação Tributável (base de cálculo = valor da operação alíquota normal (cumulativo/não cumulativo))
                      -- 02 - Operação Tributável (base de cálculo = valor da operação (alíquota diferenciada))
                      --
                      --vn_imp_trib := round( nvl(rec_imp.vl_base_calc,0) * nvl(rec_imp.aliq_apli,0) ,2);
                      vn_imp_trib := round((nvl(rec_imp.vl_base_calc,0) * (nvl(rec_imp.aliq_apli,0) / 100)),2);
                      --
                      vn_fase := 12.5;
                      --
                      if nvl(rec_imp.vl_base_calc,0) <= 0 then
                         --
                         vn_fase := 12.6;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Está com o "Valor da Base de Cálculo do COFINS" divergente para o Tipo de Imposto: '||rec_imp.sigla||chr(10)||
                                            'Informado: '||to_char(nvl(rec_imp.vl_base_calc,0),'999G999G999G999G990D00');
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                      vn_fase := 12.7;
                      --
                      if nvl(rec_imp.aliq_apli,0) <= 0 then
                         --
                         vn_fase := 12.8;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Está com a "Alíquota do COFINS (em percentual)" divergente para o Tipo de Imposto: '||rec_imp.sigla;
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                      vn_fase := 12.9;
                      --
                      if nvl(rec_imp.vl_imp_trib,0) <= 0 and nvl(vn_imp_trib,0) > 0 then
                         --
                         vn_fase := 12.10;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Está com o valor "Valor do COFINS" divergente para o Tipo de Imposto: '||rec_imp.sigla||chr(10)||
                                            'Informado: '||to_char(nvl(rec_imp.vl_imp_trib,0),'999G999G999G999G990D00')||'; Para conferência: '||
                                            to_char(nvl(vn_imp_trib,0),'999G999G999G999G990D00')||'.';
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                   elsif rec_imp.cod_st = '03' then    -- Operação Tributável (base de cálculo = quantidade vendida x alíquota por unidade de produto)
                      --
                      vn_fase := 12.11;
                      --
                      if nvl(rec_imp.qtde_base_calc_prod,0) <= 0 then
                         --
                         vn_fase := 12.12;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Está com o "Quantidade Vendida do COFINS" divergente para o Tipo de Imposto: '||rec_imp.sigla||chr(10)||
                                            'Informado: '||to_char(nvl(rec_imp.vl_base_calc,0),'999G999G999G999G990D00');
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                      vn_fase := 12.13;
                      --
                      if nvl(rec_imp.vl_aliq_prod,0) <= 0 then
                         --
                         vn_fase := 12.14;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Está com a "Alíquota do COFINS (em reais)" divergente para o Tipo de Imposto: '||rec_imp.sigla;
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                      vn_fase := 12.15;
                      --
                      if nvl(rec_imp.vl_imp_trib,0) <= 0 then
                         --
                         vn_fase := 12.16;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Está com o valor "Valor do COFINS" divergente para o Tipo de Imposto: '||rec_imp.sigla||chr(10)||
                                            'Informado: '||to_char(nvl(rec_imp.vl_imp_trib,0),'999G999G999G999G990D00');
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                   elsif rec_imp.cod_st = '99' then    -- Outras Operações
                      --
                      vn_fase := 12.17;
                      --
                      if nvl(rec_imp.vl_base_calc,0) > 0 and nvl(rec_imp.qtde_base_calc_prod,0) > 0 then
                         --
                         vn_fase := 12.18;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Não pode ter informado o "Valor da Base de Cálculo do COFINS" e o "Quantidade Vendida COFINS" '||
                                            'informados ao ao mesmo tempo para o Tipo de Imposto: '||rec_imp.sigla;
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                      vn_fase := 12.19;
                      --
                      if nvl(rec_imp.aliq_apli,0) > 0 and nvl(rec_imp.vl_aliq_prod,0) > 0 then
                         --
                         vn_fase := 12.20;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Não pode ter informado o "Alíquota do COFINS (em percentual)" e o "Alíquota do COFINS (em reais)" '||
                                            'informados ao ao mesmo tempo para o Tipo de Imposto: '||rec_imp.sigla;
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                      vn_fase := 12.21;
                      -- Válida informação do imposto por quantidade
                      if nvl(rec_imp.aliq_apli,0) < 0 or nvl(rec_imp.vl_base_calc,0) < 0 then
                         --
                         vn_fase := 12.22;
                         -- Válida o valor da alíquota em reais
                         if nvl(rec_imp.vl_aliq_prod,0) < 0 then
                            --
                            vn_fase := 12.23;
                            --
                            gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                               '"Alíquota do COFINS (em reais)" deve ser informada e maior que zero para o Tipo de Imposto: '||rec_imp.sigla;
                            --
                            vn_loggenericonf_id := null;
                            --
                            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                             , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                             , ev_resumo          => gv_mensagem_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             , en_dm_impressa     => 0 );
                            --
                            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                                , est_log_generico_nf  => est_log_generico_nf );
                            --
                         end if;
                         --
                         vn_fase := 12.24;
                         --
                         if nvl(rec_imp.qtde_base_calc_prod,0) < 0 then
                            --
                            vn_fase := 12.25;
                            --
                            gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                               '"Quantidade Vendida do COFINS" deve ser informada e maior que zero para o Tipo de Imposto: '||rec_imp.sigla;
                            --
                            vn_loggenericonf_id := null;
                            --
                            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                             , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                             , ev_resumo          => gv_mensagem_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             , en_dm_impressa     => 0 );
                            --
                            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                                , est_log_generico_nf  => est_log_generico_nf );
                            --
                         end if;
                         --
                         vn_fase := 12.26;
                         -- Se o imposto é por quantidade e valor, não pode ser informado a Base e percentual
                         if nvl(rec_imp.aliq_apli,0) > 0 then
                            --
                            vn_fase := 12.27;
                            --
                            gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                               '"Alíquota do COFINS (em percentual)" não deve ser informada para o Tipo de Imposto: '||rec_imp.sigla;
                            --
                            vn_loggenericonf_id := null;
                            --
                            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                             , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                             , ev_resumo          => gv_mensagem_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             , en_dm_impressa     => 0 );
                            --
                            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                                , est_log_generico_nf  => est_log_generico_nf );
                            --
                         end if;
                         --
                         vn_fase := 12.28;
                         if nvl(rec_imp.vl_base_calc,0) > 0 then
                            --
                            vn_fase := 12.29;
                            --
                            gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                               '"Valor da Base de Cálculo do COFINS" não deve ser informada para o Tipo de Imposto: '||rec_imp.sigla;
                            --
                            vn_loggenericonf_id := null;
                            --
                            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                             , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                             , ev_resumo          => gv_mensagem_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             , en_dm_impressa     => 0 );
                            --
                            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                                , est_log_generico_nf  => est_log_generico_nf );
                            --
                         end if;
                         --
                      end if;
                      --
                      vn_fase := 12.30;
                      -- Imposto por alíquota
                      if nvl(rec_imp.vl_aliq_prod,0) < 0 or nvl(rec_imp.qtde_base_calc_prod,0) < 0 then
                         --
                         vn_fase := 12.31;
                         -- Se o imposto é por quantidade e valor, não pode ser informado a Base e percentual
                         if nvl(rec_imp.aliq_apli,0) < 0 then
                            --
                            vn_fase := 12.32;
                            --
                            gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                               '"Alíquota do COFINS (em percentual)" deve ser informada e maior que zero para o Tipo de Imposto: '||rec_imp.sigla;
                            --
                            vn_loggenericonf_id := null;
                            --
                            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                             , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                             , ev_resumo          => gv_mensagem_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             , en_dm_impressa     => 0 );
                            --
                            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                                , est_log_generico_nf  => est_log_generico_nf );
                            --
                         end if;
                         --
                         vn_fase := 12.33;
                         if nvl(rec_imp.vl_base_calc,0) < 0 then
                            --
                            vn_fase := 12.34;
                            --
                            gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                               '"Valor da Base de Cálculo do COFINS" deve ser informada e maior que zero para o Tipo de Imposto: '||rec_imp.sigla;
                            --
                            vn_loggenericonf_id := null;
                            --
                            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                             , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                             , ev_resumo          => gv_mensagem_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             , en_dm_impressa     => 0 );
                            --
                            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                                , est_log_generico_nf  => est_log_generico_nf );
                            --
                         end if;
                         --
                         vn_fase := 12.35;
                         -- Válida o valor da alíquota em reais
                         if nvl(rec_imp.vl_aliq_prod,0) > 0 then
                            --
                            vn_fase := 12.36;
                            --
                            gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                               '"Alíquota do COFINS (em reais)" não deve ser informada para o Tipo de Imposto: '||rec_imp.sigla;
                            --
                            vn_loggenericonf_id := null;
                            --
                            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                             , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                             , ev_resumo          => gv_mensagem_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             , en_dm_impressa     => 0 );
                            --
                            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                                , est_log_generico_nf  => est_log_generico_nf );
                            --
                         end if;
                         --
                         vn_fase := 12.37;
                         if nvl(rec_imp.qtde_base_calc_prod,0) > 0 then
                            --
                            vn_fase := 12.38;
                            --
                            gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                               '"Quantidade Vendida do COFINS" não deve ser informada para o Tipo de Imposto: '||rec_imp.sigla;
                            --
                            vn_loggenericonf_id := null;
                            --
                            pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                             , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                             , ev_resumo          => gv_mensagem_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             , en_dm_impressa     => 0 );
                            --
                            pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                                , est_log_generico_nf  => est_log_generico_nf );
                            --
                         end if;
                         --
                      end if;
                      --
                      vn_fase := 12.39;
                      --
                      if nvl(rec_imp.vl_imp_trib,0) < 0 then
                         --
                         vn_fase := 12.40;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Está com o valor "Valor do COFINS" divergente para o Tipo de Imposto: '||rec_imp.sigla||chr(10)||
                                            'Informado: '||to_char(nvl(rec_imp.vl_imp_trib,0),'999G999G999G999G990D00');
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                   end if;
                   --
                   vn_fase := 12.41;
                   --
                   -- Valida situação tributária isenta
                   if rec_imp.cod_st in ('04', '06', '07', '08', '09', '70', '71', '72', '73', '74', '75')
                      then
                      --
                      vn_fase := 12.42;
                      --
                      if nvl(rec_imp.vl_base_calc,0) > 0 and rec_imp.cod_st not in ('06', '73') then
                         --
                         vn_fase := 12.43;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Não permite "Valor da Base de Cálculo do COFINS" para o Tipo de Imposto: '||rec_imp.sigla||chr(10)||
                                            'Informado: '||to_char(nvl(rec_imp.vl_base_calc,0),'999G999G999G999G990D00');
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                             , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                                             , ev_resumo            => gv_mensagem_log
                                             , en_tipo_log          => ERRO_DE_VALIDACAO
                                             , en_referencia_id     => gn_referencia_id
                                             , ev_obj_referencia    => gv_obj_referencia
                                             , en_dm_impressa       => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                                , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                      vn_fase := 12.44;
                      --
                      if nvl(rec_imp.aliq_apli,0) > 0 then
                         --
                         vn_fase := 12.45;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Não permite "Alíquota do COFINS (em percentual)" para o Tipo de Imposto: '||rec_imp.sigla||chr(10)||
                                            'Informado: '||to_char(nvl(rec_imp.aliq_apli,0),'999G999G999G999G990D00');
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                             , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                                             , ev_resumo            => gv_mensagem_log
                                             , en_tipo_log          => ERRO_DE_VALIDACAO
                                             , en_referencia_id     => gn_referencia_id
                                             , ev_obj_referencia    => gv_obj_referencia
                                             , en_dm_impressa       => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                      vn_fase := 12.46;
                      --
                      if nvl(rec_imp.vl_imp_trib,0) > 0 then
                         --
                         vn_fase := 12.47;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Não permite "Valor do COFINS" para o Tipo de Imposto: '||rec_imp.sigla||chr(10)||
                                            'Informado: '||to_char(nvl(rec_imp.vl_imp_trib,0),'999G999G999G999G990D00');
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                      vn_fase := 12.48;
                      --
                      if nvl(rec_imp.qtde_base_calc_prod,0) > 0 then
                         --
                         vn_fase := 12.49;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Não permite "Quantidade Vendida do COFINS" para o Tipo de Imposto: '||rec_imp.sigla||chr(10)||
                                            'Informado: '||to_char(nvl(rec_imp.qtde_base_calc_prod,0),'999G999G999G999G990D00');
                        --
                        vn_loggenericonf_id := null;
                        --
                        pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                         , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                         , ev_resumo          => gv_mensagem_log
                                         , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                         , en_referencia_id   => gn_referencia_id
                                         , ev_obj_referencia  => gv_obj_referencia
                                         , en_dm_impressa     => 0 );
                        --
                        pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                            , est_log_generico_nf  => est_log_generico_nf );
                        --
                      end if;
                      --
                      vn_fase := 12.50;
                      --
                      if nvl(rec_imp.vl_aliq_prod,0) > 0 then
                         --
                         vn_fase := 12.51;
                         --
                         gv_mensagem_log := 'Situação Tributária: '||rec_imp.cod_st||' - '||rec_imp.descr_st||chr(10)||
                                            'Não permite "Alíquota do COFINS (em reais)" para o Tipo de Imposto: '||rec_imp.sigla||chr(10)||
                                            'Informado: '||to_char(nvl(rec_imp.vl_aliq_prod,0),'999G999G999G999G990D00');
                         --
                         vn_loggenericonf_id := null;
                         --
                         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO -- ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          , en_dm_impressa     => 0 );
                         --
                         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                             , est_log_generico_nf  => est_log_generico_nf );
                         --
                      end if;
                      --
                   end if;
                   --
                end if;
                --
             end if;
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
      rollback;
      --
      gv_mensagem_log := 'Erro na pkb_valida_imposto_item fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_valida_imposto_item;

-------------------------------------------------------------------------------------------------------
-- Procedimento Valida informações das Faturas e Duplicadas

procedure pkb_vld_infor_dupl ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                             , en_notafiscal_id    in             nota_fiscal.id%type
                             )
is
   --
   vn_fase             number := 0;
   vn_loggenericonf_id log_generico_nf.id%type;
   vn_qtde             number := 0;
   vn_vl_liq           number;
   vn_vl_total_nf      number;
   vn_vl_dup           number;
   vn_empresa_id       number := 0;
   --
   cursor c_nfcobrdup is
      select nd.nfcobr_id
           , nd.nro_parc
        from nota_fiscal_cobr nf
           , nfcobr_dup       nd
       where nf.notafiscal_id = en_notafiscal_id
         and nd.nfcobr_id     = nf.id
    group by nd.nfcobr_id
         , nd.nro_parc
      having count(*) >  1;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_notafiscal_id,0) > 0 then
      --
      vn_fase := 2;
      --
      if nvl(gt_row_nat_oper_serv.dm_obrig_vl_dup,0) = 1 then -- Obriga valor de duplicata
         --
         vn_fase := 3;
         --
         begin
            select count(1)
              into vn_qtde
              from nota_fiscal_cobr nf
                 , nfcobr_dup       nd
             where nf.notafiscal_id = en_notafiscal_id
               and nd.nfcobr_id     = nf.id;
         exception
            when others then
               vn_qtde := 0;
         end;
         --
         vn_fase := 4;
         --
         if nvl(vn_qtde,0) <= 0 then
            --
            gv_mensagem_log := 'Não foi informado os valores de fatura e/ou duplicatas. Verifique, pois o parâmetro relacionado com a Natureza de Operação '||
                               'indica que a fatura/duplicata é obrigatória.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                , ev_resumo           => gv_mensagem_log
                                , en_tipo_log         => erro_de_validacao
                                , en_referencia_id    => gn_referencia_id
                                , ev_obj_referencia   => gv_obj_referencia
                                , en_dm_impressa      => 0 );
            --
            pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                   , est_log_generico_nf => est_log_generico_nf );
            --
         end if;
         --
      end if; -- parâmetro que obriga valor de duplicata
      --
      vn_fase := 5;
      -- verifica a quantidade de faturas da nota fiscal
      begin
         select count(1)
           into vn_qtde
           from nota_fiscal_cobr nc
          where nc.notafiscal_id = en_notafiscal_id;
      exception
         when others then
            vn_qtde := 0;
      end;
      --
      vn_fase := 6;
      --
      if nvl(vn_qtde,0) > 1 then
         --
         vn_fase := 7;
         --
         gv_mensagem_log := 'Existe mais de um registro de "Fatura" informado. Verifique.';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                             , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                             , ev_resumo           => gv_mensagem_log
                             , en_tipo_log         => erro_de_validacao
                             , en_referencia_id    => gn_referencia_id
                             , ev_obj_referencia   => gv_obj_referencia );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                , est_log_generico_nf => est_log_generico_nf );
         --
      else
         --
         vn_fase := 8;
         --
         vn_empresa_id := pk_csf.fkg_busca_empresa_nf ( en_notafiscal_id => en_notafiscal_id );
         -- Parâmetro da empresa indica que a fatura e as duplicatas devem ser validadas
         if nvl(pk_csf.fkg_valid_cobr_nf_empresa ( en_empresa_id => vn_empresa_id ), 0) = 1 then
            -- busca o valor da cobrança
            begin
               select sum(nvl(nc.vl_liq, 0))
                 into vn_vl_liq
                 from nota_fiscal_cobr nc
                where nc.notafiscal_id = en_notafiscal_id;
            exception
               when others then
                  vn_vl_liq := 0;
            end;
            --
            vn_fase := 9;
            -- busca o valor no total da nota
            begin
               select sum(nvl(nt.vl_total_nf,0))
                 into vn_vl_total_nf
                 from nota_fiscal_total nt
                where nt.notafiscal_id = en_notafiscal_id;
            exception
               when others then
                  vn_vl_total_nf := 0;
            end;
            --
            vn_fase := 10;
            -- valida se o valor liquido na tabela cobrança é maior que zero e difere do total da NFS.
            if nvl(vn_vl_liq, 0) > 0 and
               nvl(vn_vl_liq, 0) <> nvl(vn_vl_total_nf, 0) then
               --
               vn_fase := 11;
               --
               gv_mensagem_log := 'Na Fatura, o "Valor Original" ('||vn_vl_liq||'), está diferente do "Valor Total da Nota Fiscal"('||vn_vl_total_nf||').';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                   , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                   , ev_resumo           => gv_mensagem_log
                                   , en_tipo_log         => erro_de_validacao
                                   , en_referencia_id    => gn_referencia_id
                                   , ev_obj_referencia   => gv_obj_referencia );
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                      , est_log_generico_nf => est_log_generico_nf );
               --
            end if;
            --
            vn_fase := 12;
            -- Busca a somatória das duplicatas.
            begin
              select sum(nvl(nd.vl_dup,0))
                into vn_vl_dup
               from nota_fiscal_cobr nf
                  , nfcobr_dup       nd
              where nf.notafiscal_id = en_notafiscal_id
                and nd.nfcobr_id     = nf.id;
            exception
               when others then
                  vn_vl_dup := 0;
            end;
            --
            vn_fase := 13;
            --
            -- Compara somatória da duplicata com valor da cobrança.
            -- Há notas em que há registro na tabela cobrança maior que zero, porém não há duplicatas. Isso é permitido tb
            -- no manual de Integração do Contribuinte. Nesse caso só irá realizar a validação quando a duplicata for maior que zero.
            if nvl(vn_vl_dup,0) > 0 and
               nvl(vn_vl_liq,0) <> nvl(vn_vl_dup,0) then
               --
               vn_fase := 14;
               --
               gv_mensagem_log := 'Na Fatura, o "Valor Original" ('||vn_vl_liq||'), está diferente da Somatória das Duplicatas ('||vn_vl_dup||').';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                   , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                   , ev_resumo           => gv_mensagem_log
                                   , en_tipo_log         => erro_de_validacao
                                   , en_referencia_id    => gn_referencia_id
                                   , ev_obj_referencia   => gv_obj_referencia );
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                      , est_log_generico_nf => est_log_generico_nf );
               --
            end if;
            --
         end if; -- Parâmetro da empresa indica que a fatura e as duplicatas devem ser validadas
         --
         vn_fase := 15;
         --
         for rec in c_nfcobrdup loop
            exit when c_nfcobrdup%notfound or (c_nfcobrdup%notfound) is null;
            --
            vn_fase := 16;
            --
            gv_mensagem_log := 'Existe mais de uma duplicata com o mesmo "Número da parcela" (' || rec.nro_parc || '), informada.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                , ev_resumo           => gv_mensagem_log
                                , en_tipo_log         => erro_de_validacao
                                , en_referencia_id    => gn_referencia_id
                                , ev_obj_referencia   => gv_obj_referencia );
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                   , est_log_generico_nf => est_log_generico_nf );
            --
         end loop;
         --
      end if; -- verifica qtde de faturas para a nota fiscal
      --
      vn_fase := 17;
      --
      begin
         select count(1) qtde
           into vn_qtde
           from nota_fiscal_cobr nfc
              , nfcobr_dup       d
          where nfc.notafiscal_id = en_notafiscal_id
            and d.nfcobr_id       = nfc.id;
      exception
         when others then
            vn_qtde := 0;
      end;
      --
      vn_fase := 18;
      --
      if nvl(vn_qtde,0) > 120 then
         --
         vn_fase := 19;
         --
         gv_mensagem_log := 'Não pode existir mais que 120 duplicatas para a Fatura da Nota Fiscal de Serviço.';
         --
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                             , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                             , ev_resumo           => gv_mensagem_log
                             , en_tipo_log         => erro_de_validacao
                             , en_referencia_id    => gn_referencia_id
                             , ev_obj_referencia   => gv_obj_referencia );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                , est_log_generico_nf => est_log_generico_nf );
         --
      end if;
      --
   end if; -- parâmetro de entrada da nota fiscal não informado
   --
exception
   when others then
      --
      rollback;
      --
      gv_mensagem_log := 'Erro na pkb_vld_infor_dupl fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                             , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                             , ev_resumo           => gv_mensagem_log
                             , en_tipo_log         => erro_de_sistema
                             , en_referencia_id    => gn_referencia_id
                             , ev_obj_referencia   => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_vld_infor_dupl;

-------------------------------------------------------------------------------------------------------
-- Procedimento que valida informações para emissão de XML de envio por RPS

procedure pkb_vld_xml_rps ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                          , en_notafiscal_id    in             nota_fiscal.id%type
                          )
is
   --
   vn_fase                number := 0;
   vn_loggenericonf_id    log_generico_nf.id%type;
   vv_existe              varchar2(1) := 'N';
   vn_cd_lista_serv       item_nota_fiscal.cd_lista_serv%type;
   vn_codtribmunicipio_id itemnf_compl_serv.codtribmunicipio_id%type;
   vv_ibge_cidade         cidade.ibge_cidade%type;
   vv_cnae                itemnf_compl_serv.cnae%type;
   vv_cod_obra            nfs_det_constr_civil.cod_obra%type;
   vv_nro_art             nfs_det_constr_civil.nro_art%type;
   --
   cursor c_imp_ret is -- Impostos Retidos
      select al.cd
           , count(*)
        from (select ti.cd
                   , ii.aliq_apli
                   , count(*)
                from item_nota_fiscal it
                   , imp_itemnf       ii
                   , tipo_imposto     ti
               where it.notafiscal_id = en_notafiscal_id
                 and ii.itemnf_id     = it.id
                 and ii.dm_tipo       = 1 -- 0-imposto, 1-retido
                 and ti.id            = ii.tipoimp_id
               group by ti.cd
                   , ii.aliq_apli) al
       group by al.cd
      having count(*) > 1;
   --
   cursor c_imp_nor is -- Impostos Normais
      select al.cd
           , count(*)
        from (select ti.cd
                   , ii.aliq_apli
                   , count(*)
                from item_nota_fiscal it
                   , imp_itemnf       ii
                   , tipo_imposto     ti
               where it.notafiscal_id = en_notafiscal_id
                 and ii.itemnf_id     = it.id
                 and ii.dm_tipo       = 0 -- 0-imposto, 1-retido
                 and ti.id            = ii.tipoimp_id
                 and ti.cd            = 6 -- ISS
               group by ti.cd
                   , ii.aliq_apli) al
       group by al.cd
      having count(*) > 1;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_notafiscal_id,0) > 0 then
      --
      vn_fase := 2;
      --
      if nvl(gn_dm_agrupa_item_xml_rps,0) = 1 then -- Agrupar os Itens da Nota Fiscal no XML de envio do RPS: 0-Não, 1-Sim
         --
         vn_fase   := 3;
         vv_existe := 'N';
         --
         -- Os itens deverão possuir o mesmo Código da Lista de Serviço, mesmo código de tributação do município (quando informado), mesmo IBGE de município e
         -- CNAE (quando informado no complemento do serviço) em todos os itens da NFSe. Caso contrário, gerar erro de validação para o usuário final informando
         -- que para emissão de NFSe com mais de um item a regra acima deve ser atendida.
         --
         begin
            select distinct it.cd_lista_serv
                 , ic.codtribmunicipio_id
                 , ci.ibge_cidade
                 , ic.cnae
                 , 'U' -- único registro
              into vn_cd_lista_serv
                 , vn_codtribmunicipio_id
                 , vv_ibge_cidade
                 , vv_cnae
                 , vv_existe
              from item_nota_fiscal   it
                 , itemnf_compl_serv  ic
                 , cod_trib_municipio ct
                 , cidade             ci
             where it.notafiscal_id = en_notafiscal_id
               and ic.itemnf_id     = it.id
               and ct.id            = ic.codtribmunicipio_id
               and ci.id            = ct.cidade_id;
         exception
            when no_data_found then
               vv_existe := 'N'; -- não existe registro
            when too_many_rows then
               vv_existe := 'S'; -- existe mais de um registro com informação diferente
            when others then
               --
               gv_mensagem_log := 'Problemas ao identificar Itens com os mesmos: Código da Lista de Serviço, Código de Tributação do Município, IBGE do '||
                                  'Município e Código CNAE, devido ao parâmetro de Agrupar Itens para emissão do XML de envio do RPS. Erro: '||sqlerrm;
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                   , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                   , ev_resumo           => gv_mensagem_log
                                   , en_tipo_log         => erro_de_validacao
                                   , en_referencia_id    => gn_referencia_id
                                   , ev_obj_referencia   => gv_obj_referencia
                                   , en_dm_impressa      => 0 );
               --
               pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                      , est_log_generico_nf => est_log_generico_nf );
               --
         end;
         --
         vn_fase := 4;
         --
         if nvl(vv_existe,'N') = 'S' then -- existe mais de um registro com informação diferente
            --
            gv_mensagem_log := 'Existem Itens da Nota Fiscal com diferentes informações sobre: Código da Lista de Serviço, Código de Tributação do Município, '||
                               'IBGE do Município e Código CNAE. Devido ao parâmetro "Agrupar Itens para emissão do XML de envio do RPS", essas informações '||
                               'deveriam estar iguais em todos os itens da Nota Fiscal.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                , ev_resumo           => gv_mensagem_log
                                , en_tipo_log         => erro_de_validacao
                                , en_referencia_id    => gn_referencia_id
                                , ev_obj_referencia   => gv_obj_referencia
                                , en_dm_impressa      => 0 );
            --
            pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                   , est_log_generico_nf => est_log_generico_nf );
            --
         end if;
         --
         vn_fase := 5;
         --
         -- Caso haja PIS Retido no RPS, em todos os itens a alíquota de PIS Retido deverá ser a mesma
         -- Caso haja COFINS Retido no RPS, em todos os itens a alíquota de PIS Retido deverá ser a mesma
         -- Caso haja INSS Retido no RPS, em todos os itens a alíquota de INSS Retido deverá ser a mesma.
         -- Caso haja IRRF Retido no RPS, em todos os itens a alíquota de IRRF Retido deverá ser a mesma.
         -- Caso haja CSLL Retido no RPS, em todos os itens a alíquota de CSLL Retido deverá ser a mesma.
         -- Caso haja ISS Retido no RPS, em todos os itens a alíquota de ISS Retido deverá ser a mesma.
         -- Caso haja outro Imposto Retido que não foi citado acima (outras retenções), em todos os itens a alíquota desses impostos deverá ser a mesma.
         --
         for r_imp_ret in c_imp_ret
         loop
            --
            exit when c_imp_ret%notfound or (c_imp_ret%notfound) is null;
            --
            vn_fase := 6;
            --
            gv_mensagem_log := 'Existem Itens da Nota Fiscal com diferentes Alíquotas de '||pk_csf.fkg_tipo_imposto_sigla(r_imp_ret.cd)||'/Retido. Devido ao '||
                               'parâmetro "Agrupar Itens para emissão do XML de envio do RPS", essa informação deve estar igual em todos os itens da Nota '||
                               'Fiscal.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                , ev_resumo           => gv_mensagem_log
                                , en_tipo_log         => erro_de_validacao
                                , en_referencia_id    => gn_referencia_id
                                , ev_obj_referencia   => gv_obj_referencia
                                , en_dm_impressa      => 0 );
            --
            pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                   , est_log_generico_nf => est_log_generico_nf );
            --
         end loop;
         --
         vn_fase := 7;
         --
         -- Caso haja ISS NORMAL no RPS, em todos os itens a alíquota de ISS NORMAL deverá ser a mesma
         --
         for r_imp_nor in c_imp_nor
         loop
            --
            exit when c_imp_nor%notfound or (c_imp_nor%notfound) is null;
            --
            vn_fase := 8;
            --
            gv_mensagem_log := 'Existem Itens da Nota Fiscal com diferentes Alíquotas de '||pk_csf.fkg_tipo_imposto_sigla(r_imp_nor.cd)||'/Normal. Devido ao '||
                               'parâmetro "Agrupar Itens para emissão do XML de envio do RPS", essa informação deve estar igual em todos os itens da Nota '||
                               'Fiscal.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                , ev_resumo           => gv_mensagem_log
                                , en_tipo_log         => erro_de_validacao
                                , en_referencia_id    => gn_referencia_id
                                , ev_obj_referencia   => gv_obj_referencia
                                , en_dm_impressa      => 0 );
            --
            pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                   , est_log_generico_nf => est_log_generico_nf );
            --
         end loop;
         --
         vn_fase   := 9;
         vv_existe := 'N';
         --
         -- Se o RPS possuir informações referente a construção civil (tabela - nfs_det_constr_civil) o valor dos campos cod_obra e nro_art deverá ser único,
         -- ou seja, só deverá haver um registro na tabela nfs_det_constr_civil para o RPS.
         --
         begin
            select distinct nd.cod_obra
                 , nd.nro_art
                 , 'U' -- único registro
              into vv_cod_obra
                 , vv_nro_art
                 , vv_existe
              from nfs_det_constr_civil nd
             where nd.notafiscal_id = en_notafiscal_id;
         exception
            when no_data_found then
               vv_existe := 'N'; -- não existe registro
            when too_many_rows then
               vv_existe := 'S'; -- existe mais de um registro com informação diferente
            when others then
               --
               gv_mensagem_log := 'Problemas ao identificar Detalhamento Específico da Construção Civil com os mesmos: Número da matrícula CEI da obra ou '||
                                  'da empresa, e Número da ART, devido ao parâmetro de Agrupar Itens para emissão do XML de envio do RPS. Erro: '||sqlerrm;
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                   , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                   , ev_resumo           => gv_mensagem_log
                                   , en_tipo_log         => erro_de_validacao
                                   , en_referencia_id    => gn_referencia_id
                                   , ev_obj_referencia   => gv_obj_referencia
                                   , en_dm_impressa      => 0 );
               --
               pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                      , est_log_generico_nf => est_log_generico_nf );
               --
         end;
         --
         vn_fase := 10;
         --
         if nvl(vv_existe,'N') = 'S' then -- existe mais de um registro com informação diferente
            --
            gv_mensagem_log := 'Existem Detalhamentos Específicos da Construção Civil vinculados com a Nota Fiscal, com diferentes informações sobre: Número '||
                               'da matrícula CEI da obra ou da empresa, e Número da ART. Devido ao parâmetro "Agrupar Itens para emissão do XML de envio do '||
                               'RPS", essas informações deveriam estar iguais para a Nota Fiscal.';
            --
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                , ev_resumo           => gv_mensagem_log
                                , en_tipo_log         => erro_de_validacao
                                , en_referencia_id    => gn_referencia_id
                                , ev_obj_referencia   => gv_obj_referencia
                                , en_dm_impressa      => 0 );
            --
            pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                   , est_log_generico_nf => est_log_generico_nf );
            --
         end if;
         --
      end if; -- parâmetro que indica agrupamento de Itens
      --
   end if; -- parâmetro de entrada da nota fiscal não informado
   --
exception
   when others then
      --
      rollback;
      --
      gv_mensagem_log := 'Erro na pkb_vld_xml_rps fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                             , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                             , ev_resumo           => gv_mensagem_log
                             , en_tipo_log         => erro_de_sistema
                             , en_referencia_id    => gn_referencia_id
                             , ev_obj_referencia   => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_vld_xml_rps;

-------------------------------------------------------------------------------------------------------
-- Procedimento atualiza a informação da tabela NOTA_FISCAL_COBR
procedure pkb_atual_dados_cobr ( est_log_generico_nf     in out nocopy  dbms_sql.number_table
                               , en_notafiscal_id     in             Nota_Fiscal.Id%TYPE
                               )
is
   --
   vn_fase                    number := 0;
   vn_loggenericonf_id          log_generico_nf.id%type;
   vn_soma_vl_dup             number;
   --
   cursor c_cobr is
   select nfc.*
     from nota_fiscal_cobr nfc
    where nfc.notafiscal_id = en_notafiscal_id
    order by 1;
   --
begin
   --
   vn_fase := 1;
   --
   for rec_cobr in c_cobr loop
      exit when c_cobr%notfound or (c_cobr%notfound) is null;
      --
      vn_fase := 2;
      --
      vn_soma_vl_dup := 0;
      --
      begin
         --
         select sum(nvl(d.vl_dup,0))
           into vn_soma_vl_dup
           from nfcobr_dup d
          where d.nfcobr_id = rec_cobr.id;
         --
      exception
         when others then
            vn_soma_vl_dup := 0;
      end;
      --
      vn_fase := 3;
      --
      update nota_fiscal_cobr nf
         set nf.dm_ind_emit  = nvl(nf.dm_ind_emit,gt_row_nota_fiscal.dm_ind_emit)
           , nf.dm_ind_tit   = nvl(nf.dm_ind_tit,'00')
           , nf.nro_fat      = nvl(nf.nro_fat,gt_row_nota_fiscal.nro_nf)
           , nf.vl_orig      = nvl(vn_soma_vl_dup,0)
           , nf.vl_liq       = nvl(vn_soma_vl_dup,0)
       where nf.id = rec_cobr.id;
      --
   end loop;
   --
   commit;
   --
exception
   when others then
      --
      rollback;
      --
      gv_mensagem_log := 'Erro na pkb_atual_dados_cobr fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_atual_dados_cobr;

----------------------------------------------------------------------------------
-- Procedimento para gerar a Informações Complementares de Tributos --
----------------------------------------------------------------------------------
PROCEDURE PKB_GERAR_INFO_TRIB ( EST_LOG_GENERICO_NF IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                              , EN_NOTAFISCAL_ID IN            NOTA_FISCAL.ID%TYPE
                              )
IS
   --
   vn_fase              number;
   vv_inf_cpl_imp       nota_fiscal.inf_cpl_imp%type;
   vv_inf_cpl_imp_item  item_nota_fiscal.inf_cpl_imp_item%type;
   vn_dm_gera_tot_trib  empresa.dm_gera_tot_trib%type;
   --
   vn_vl_tot_trib_fed nota_fiscal_total.vl_tot_trib%type;
   vn_vl_tot_trib_est nota_fiscal_total.vl_tot_trib%type;
   vn_vl_tot_trib_mun nota_fiscal_total.vl_tot_trib%type;
   vn_vl_icms_deson nota_fiscal_total.vl_icms_deson%type;

   vn_vl_tot_trib_item_fed item_nota_fiscal.vl_tot_trib_item%type;
   vn_vl_tot_trib_item_est item_nota_fiscal.vl_tot_trib_item%type;
   vn_vl_tot_trib_item_mun item_nota_fiscal.vl_tot_trib_item%type;
   vn_vl_icms_deson_item imp_itemnf.vl_icms_deson%type;
   vn_instr_info_adic   number;
   --
   cursor c_inf is
   select inf.*
        , nf.dm_ind_final
     from nota_fiscal       nf
        , nota_fiscal_dest  nfd
        , item_nota_fiscal  inf
    where nf.id               = en_notafiscal_id
      and nf.dm_ind_emit      = 0
      and nf.dm_arm_nfe_terc  = 0
      and nfd.notafiscal_id   = nf.id
      and inf.notafiscal_id   = nf.id
    order by inf.nro_item;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_notafiscal_id,0) > 0 then
      --
      vn_fase := 2;
      --
      vv_inf_cpl_imp      := null;
      vv_inf_cpl_imp      := 'Conforme lei 12.741/2012 os impostos incidentes sobre esta NFS-e:';
      vn_vl_tot_trib_fed  := 0;
      vn_vl_tot_trib_est  := 0;
      vn_vl_tot_trib_mun  := 0;
      vn_vl_icms_deson    := 0;
      --
      vn_fase := 2.1;
      --
      vn_dm_gera_tot_trib := pk_csf.fkg_empresa_gera_tot_trib ( en_empresa_id => gt_row_nota_fiscal.empresa_id );
      --
      vn_fase := 3;
      --
      if nvl(vn_dm_gera_tot_trib,0) <> 0 then -- Diferente de "0-não gerar"
         --
         for rec in c_inf loop
            exit when c_inf%notfound or (c_inf%notfound) is null;
            --
            vn_fase := 4;
            --
            vv_inf_cpl_imp_item := null;
            vv_inf_cpl_imp_item := 'Conforme lei 12.741/2012 os impostos incidentes sobre esta NFS-e:';
            --
            begin
               --
               select sum( case
                             when ti.cd in (3, 4, 5, 7, 11, 12, 13) then
                                nvl(imp.vl_imp_trib,0)
                             else 0
                           end ) -- federal
                    , sum( case
                             when ti.cd in (1, 2, 10) then
                                nvl(imp.vl_imp_trib,0)
                             else 0
                           end ) -- estadual
                    , sum( case
                             when ti.cd in (6) then
                                nvl(imp.vl_imp_trib,0)
                             else 0
                           end ) -- municipal
                    , sum( nvl(imp.vl_icms_deson,0) )
                 into vn_vl_tot_trib_item_fed
                    , vn_vl_tot_trib_item_est
                    , vn_vl_tot_trib_item_mun
                    , vn_vl_icms_deson_item
                 from imp_itemnf imp
                    , tipo_imposto ti
                where imp.itemnf_id = rec.id
                  and imp.dm_tipo   = 0 -- Imposto
                  and ti.id         = imp.tipoimp_id;
               --
            exception
               when others then
                  vn_vl_tot_trib_item_fed := 0;
                  vn_vl_tot_trib_item_est := 0;
                  vn_vl_tot_trib_item_mun := 0;
                  vn_vl_icms_deson_item   := 0;
            end;
            --
            vn_fase := 4.1;
            --
            if nvl(vn_vl_tot_trib_item_fed,0) > 0 then
               vv_inf_cpl_imp_item := vv_inf_cpl_imp_item || ' Valor dos Tributos Federais do Item: ' || trim(to_char(vn_vl_tot_trib_item_fed, '999g999g999g990d00'));
            end if;
            --
            if nvl(vn_vl_tot_trib_item_est,0) > 0 then
               vv_inf_cpl_imp_item := vv_inf_cpl_imp_item || ' Valor dos Tributos Estaduais do Item: ' || trim(to_char(vn_vl_tot_trib_item_est, '999g999g999g990d00'));
            end if;
            --
            if nvl(vn_vl_tot_trib_item_mun,0) > 0 then
               vv_inf_cpl_imp_item := vv_inf_cpl_imp_item || ' Valor dos Tributos Municipais do Item: ' || trim(to_char(vn_vl_tot_trib_item_mun, '999g999g999g990d00'));
            end if;
            --
            if nvl(vn_vl_icms_deson_item,0) > 0 then
               vv_inf_cpl_imp_item := vv_inf_cpl_imp_item || ' Valor do ICMS Desonerado do Item: ' || trim(to_char(vn_vl_icms_deson_item, '999g999g999g990d00'));
            end if;
            --
            vn_vl_tot_trib_fed  := nvl(vn_vl_tot_trib_fed,0) + nvl(vn_vl_tot_trib_item_fed,0);
            vn_vl_tot_trib_est  := nvl(vn_vl_tot_trib_est,0) + nvl(vn_vl_tot_trib_item_est,0);
            vn_vl_tot_trib_mun  := nvl(vn_vl_tot_trib_mun,0) + nvl(vn_vl_tot_trib_item_mun,0);
            vn_vl_icms_deson    := nvl(vn_vl_icms_deson,0) + nvl(vn_vl_icms_deson_item,0);
            --
            vn_fase := 4.2;
            --
            vv_inf_cpl_imp_item := trim(vv_inf_cpl_imp_item);
            --
            if nvl(vn_dm_gera_tot_trib,0) in (2, 3)
               and rec.dm_ind_final = 0 -- Norrmal
               then
               --
               update item_nota_fiscal set inf_cpl_imp_item = vv_inf_cpl_imp_item
                where id = rec.id;
               --
            end if;
            --
         end loop;
         --
         vn_fase := 5;
         --
         if nvl(vn_vl_tot_trib_fed,0) > 0 then
            vv_inf_cpl_imp := vv_inf_cpl_imp || ' Valor dos Tributos Federais: ' || trim(to_char(vn_vl_tot_trib_fed, '999g999g999g990d00'));
         end if;
         --
         if nvl(vn_vl_tot_trib_est,0) > 0 then
            vv_inf_cpl_imp := vv_inf_cpl_imp || ' Valor dos Tributos Estaduais: ' || trim(to_char(vn_vl_tot_trib_est, '999g999g999g990d00'));
         end if;
         --
         if nvl(vn_vl_tot_trib_mun,0) > 0 then
            vv_inf_cpl_imp := vv_inf_cpl_imp || ' Valor dos Tributos Municipais: ' || trim(to_char(vn_vl_tot_trib_mun, '999g999g999g990d00'));
         end if;
         --
         if nvl(vn_vl_icms_deson,0) > 0 then
            vv_inf_cpl_imp := vv_inf_cpl_imp || ' Valor do ICMS Desonerado: ' || trim(to_char(vn_vl_icms_deson, '999g999g999g990d00'));
         end if;
         --
         vv_inf_cpl_imp := trim(vv_inf_cpl_imp);
         --
         update nota_fiscal set inf_cpl_imp = vv_inf_cpl_imp
          where id = en_notafiscal_id;
         --
         commit;
         --
         vn_fase := 6;
         --
      end if;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      rollback;
      --
      gv_mensagem_log := 'Erro na PKB_GERAR_INFO_TRIB fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                             , ev_mensagem         => gv_cabec_log
                             , ev_resumo           => gv_mensagem_log
                             , en_tipo_log         => erro_de_validacao
                             , en_referencia_id    => gn_referencia_id
                             , ev_obj_referencia   => gv_obj_referencia );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                , est_log_generico_nf => est_log_generico_nf );
      exception
         when others then
            null;
      end;
      --
END PKB_GERAR_INFO_TRIB;

-------------------------------------------------------------------------------------------------------

--| Procedure pega os parâmetros da nota Fiscal

procedure pkb_param_nfs ( en_notafiscal_id  in nota_fiscal.id%type )
is
   --
   vn_fase        number := 0;
   vn_natoper_id  nat_oper.id%type := 0;
   --
begin
   --
   vn_fase := 1;
   -- recupera a situação da nota fiscal
   begin
      --
      select nf.dm_st_proc
           , nf.pessoa_id
           , nf.natoper_id
           , nf.empresa_id
           , nf.dt_emiss
           , nf.dm_ind_emit
           , nf.dm_ind_oper
           , nf.modfiscal_id
        into gn_dm_st_proc
           , gn_pessoa_id
           , vn_natoper_id
           , gn_empresa_id
           , gd_dt_emiss
           , gn_dm_ind_emit
           , gn_dm_ind_oper
           , gn_modfiscal_id
        from nota_fiscal nf
       where nf.id = en_notafiscal_id;
      --
   exception
      when others then
         gn_dm_st_proc   := null;
         gn_pessoa_id    := null;
         gn_dm_ind_emit  := null;
         gn_dm_ind_oper  := null;
         gn_modfiscal_id := null;
   end;
   --
   vn_fase := 2;
   -- Buscar se a pessoa relacionada a NFS é do tipo "Simples Nacional"
   gv_simplesnacional := pk_csf.fkg_pessoa_valortipoparam_cd ( ev_tipoparam_cd => '1'
                                                             , en_pessoa_id    => gn_pessoa_id
                                                             );
   --
   vn_fase := 3;
   -- recupera os parâmetros da Natureza de Operação de Serviço
   begin
      --
      select nos.*
        into gt_row_nat_oper_serv
        from nat_oper_serv nos
       where nos.natoper_id = vn_natoper_id
         and nos.empresa_id = gn_empresa_id;
      --
   exception
      when others then
         gt_row_nat_oper_serv := null;
   end;
   --
   vn_fase := 4;
   --
   if gt_row_nat_oper_serv.dm_ind_emit = 0 then
      --
      vn_fase := 5;
      -- Sendo o "Tipo de Emitente = Emissão Própria", a cidade do prestador pega da empresa, e a cidade do tomador pega da pessoa
      begin
         --
         select p.cidade_id
           into gn_cidade_id_prestador
           from empresa e
              , pessoa p
          where e.id = gn_empresa_id
            and p.id = e.pessoa_id;
         --
      exception
         when others then
            gn_cidade_id_prestador := null;
      end;
      --
      vn_fase := 6;
      --
      begin
         --
         select p.cidade_id
           into gn_cidade_id_tomador
           from pessoa p
          where p.id = gn_pessoa_id;
         --
      exception
         when others then
            gn_cidade_id_tomador := null;
      end;
      --
   else
      --
      vn_fase := 7;
      -- Sendo o "Tipo de Emitente = Terceiros", a cidade do tomador pega da empresa, e a cidade do prestador pega da pessoa
      begin
         --
         select p.cidade_id
           into gn_cidade_id_tomador
           from empresa e
              , pessoa p
          where e.id = gn_empresa_id
            and p.id = e.pessoa_id;
         --
      exception
         when others then
            gn_cidade_id_tomador := null;
      end;
      --
      vn_fase := 8;
      --
      begin
         --
         select p.cidade_id
           into gn_cidade_id_prestador
           from pessoa p
          where p.id = gn_pessoa_id;
         --
      exception
         when others then
            gn_cidade_id_prestador := null;
      end;
      --
   end if;
   --
   vn_fase := 9;
   --
   gn_dm_dt_escr_dfepoe := pk_csf.fkg_dmdtescrdfepoe_empresa( en_empresa_id => gn_empresa_id );
   --
   vn_fase := 10;
   --
   begin
      select cn.dm_agrupa_item_xml_rps
        into gn_dm_agrupa_item_xml_rps
        from empresa     em
           , pessoa      pe
           , cidade_nfse cn
       where em.id        = gn_empresa_id
         and pe.id        = em.pessoa_id
         and cn.cidade_id = pe.cidade_id
         and cn.dm_padrao = 2; -- ginfes
   exception
      when others then
         gn_dm_agrupa_item_xml_rps := 0; -- 0-não, 1-sim
   end;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_nfs.pkb_param_nfs fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%type;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => null
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => erro_de_sistema
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_param_nfs;

-----------------------------------------------------
-- Função para validar as notas fiscais de serviço --
-----------------------------------------------------
function fkg_valida_nfs ( en_empresa_id      in  empresa.id%type
                        , ed_dt_ini          in  date
                        , ed_dt_fin          in  date
                        , ev_obj_referencia  in  log_generico_nf.obj_referencia%type
                        , en_referencia_id   in  log_generico_nf.referencia_id%type )
         return boolean is
   --
   vn_fase              number;
   vn_dm_dt_escr_dfepoe empresa.dm_dt_escr_dfepoe%type;
   vt_log_generico      dbms_sql.number_table;
   --
   cursor c_notas( en_dm_dt_escr_dfepoe in empresa.dm_dt_escr_dfepoe%type ) is
   select nf.id notafiscal_id
     from nota_fiscal nf
        , mod_fiscal  mf
    where nf.empresa_id      = en_empresa_id
      and nf.dm_arm_nfe_terc = 0
      and nf.dm_st_proc      = 4 -- Autorizada
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(ed_dt_ini) and trunc(ed_dt_fin))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(ed_dt_ini) and trunc(ed_dt_fin))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(ed_dt_ini) and trunc(ed_dt_fin))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(ed_dt_ini) and trunc(ed_dt_fin)))
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('99','ND')
    order by nf.id;
   --
begin
   --
   vn_fase := 1;
   --
   pkb_seta_tipo_integr ( en_tipo_integr => 0 ); -- 0-Valida e registra Log, 1-Valida, registra Log e insere a informação
   --
   pkb_seta_obj_ref ( ev_objeto => ev_obj_referencia );
   --
   pkb_seta_referencia_id ( en_id => en_referencia_id );
   --
   vn_dm_dt_escr_dfepoe := pk_csf.fkg_dmdtescrdfepoe_empresa( en_empresa_id => en_empresa_id );
   --
   vn_fase := 2;
   --
   for rec in c_notas( en_dm_dt_escr_dfepoe => vn_dm_dt_escr_dfepoe )
   loop
      --
      exit when c_notas%notfound or (c_notas%notfound) is null;
      --
      vn_fase := 3;
      --
      pkb_consistem_nf ( est_log_generico_nf => vt_log_generico
                       , en_notafiscal_id    => rec.notafiscal_id );
      --
   end loop;
   --
   vn_fase := 4;
   --
   if nvl(vt_log_generico.count,0) > 0 then
      return false;
   else
      return true;
   end if;
   --
exception
   when others then
      raise_application_error(-20101, 'Problemas em pk_csf_api_nfs.fkg_valida_nfs (fase = '||vn_fase||' empresa_id = '||en_empresa_id||' período de '||
                                      to_char(ed_dt_ini,'dd/mm/yyyy')||' até '||to_char(ed_dt_fin,'dd/mm/yyyy')||' objeto = '||ev_obj_referencia||
                                      ' referencia_id = '||en_referencia_id||'). Erro = '||sqlerrm);
end fkg_valida_nfs;

-------------------------------------------------------------------------------------------------------

--| Procedimento para desfazer a última situação da NFS

procedure pkb_desfazer ( en_notafiscal_id  in nota_fiscal.id%type )
is
   --
   vn_fase             number := 0;
   vn_dm_st_proc       nota_fiscal.dm_st_proc%type;
   vn_dm_st_proc_novo  nota_fiscal.dm_st_proc%type;
   pragma              autonomous_transaction;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_notafiscal_id,0) > 0 then
      --
      vn_fase := 2;
      -- recupera a situação da nota fiscal
      vn_dm_st_proc := pk_csf.fkg_st_proc_nf ( en_notafiscal_id => en_notafiscal_id );
      --
      vn_fase := 3;
      -- Se a situação NÃO for 18-Digitada ou 19-Processada
      if vn_dm_st_proc not in (18, 19, 10) then
         --
         vn_dm_st_proc_novo := 19; -- Processada
         --
      else
         --
         vn_dm_st_proc_novo := 18; -- Digitada
         --
      end if;
      --
      vn_fase := 4;
      --
      -- Variavel global usada em logs de triggers (carrega)
      gv_objeto := 'pk_csf_api_nfs.pkb_desfazer'; 
      gn_fase   := vn_fase;
      --
      update nota_fiscal
         set dm_st_proc = vn_dm_st_proc_novo
       where id = en_notafiscal_id;
      --
      -- Variavel global usada em logs de triggers (limpa)
      gv_objeto := 'pk_csf_api_nfs';
      gn_fase   := null;
      --
   end if;
   --
   vn_fase := 5;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_nfs.pkb_desfazer fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%type;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => null
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => erro_de_sistema
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_desfazer;

-------------------------------------------------------------------------------------------------------

-- procedimento para gerar impostos e retenções da nota fiscal
procedure pkb_gera_imposto_nfs ( en_notafiscal_id  in nota_fiscal.id%type )
is
   --
   vn_fase           number := 0;
   vv_tipoimp_sigla  tipo_imposto.sigla%type;
   vn_vlr_bc_acm     imp_itemnf.vl_base_calc%type := 0;
   vv_cod_cta        plano_conta.cod_cta%type;
   vn_cidade_id      cidade.id%type;
   vn_vl_base_calc   imp_itemnf.vl_base_calc%type := 0;
   --
   cursor c_nf is
   select inf.id itemnf_id
        , inf.vl_item_bruto
        , inf.vl_desc
        , s.dm_trib_mun_prest
     from nota_fiscal         nf
        , item_nota_fiscal    inf
        , itemnf_compl_serv   s
    where nf.id               = en_notafiscal_id
      and inf.notafiscal_id   = nf.id
      and s.itemnf_id         = inf.id
    order by 1;
   --
   cursor c_nos is
   select p.dm_tipo
        , p.tipoimp_id
        , p.codst_id
        , p.aliq
        , p.valor_min
        , p.cidade_id
        , p.codtribmunicipio_id
        , p.dm_cons_per_ant_mes
        , p.dm_fato_gera_ret
        , p.tiporetimp_id
     from param_imp_nat_oper_serv p
    where p.natoperserv_id = gt_row_nat_oper_serv.id
    order by 1, 2;
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
      for rec_nos in c_nos loop
         exit when c_nos%notfound or (c_nos%notfound) is null;
         --
         vn_fase := 3;
         --
         vv_tipoimp_sigla := pk_csf.fkg_tipo_imp_sigla ( en_id => rec_nos.tipoimp_id );
         vn_vl_base_calc  := nvl(rec.vl_item_bruto,0) - nvl(rec.vl_desc,0);
         --
         vn_fase := 4;
         --
         if vv_tipoimp_sigla = 'ISS' then -- Tratamento de ISS
            --
            vn_fase := 4.1;
            --
            if rec_nos.dm_tipo = 1 then -- Retido
               --
               vn_fase := 4.2;
               -- Se a cidade do "tomador" for diferente da cidade da "Natureza da Operação" não cálcula o imposto.
               if nvl(gn_cidade_id_tomador,0) <> nvl(rec_nos.cidade_id,0) then
                  --
                  goto proximo;
                  --
               end if;
               --
            else
               -- Tratamento do tipo "IMPOSTO"
               vn_fase := 4.3;
               --
               if nvl(rec.dm_trib_mun_prest,0) = 1 then -- Tributa imposto no "prestador"
                  --
                  vn_fase := 4.4;
                  -- Se a cidade do "prestador" for diferente da cidade da "Natureza da Operação" não cálcula o imposto.
                  if nvl(gn_cidade_id_prestador,0) <> nvl(rec_nos.cidade_id,0) then
                     --
                     goto proximo;
                     --
                  else
                     vn_cidade_id := gn_cidade_id_prestador;
                  end if;
                  --
               else
                  --
                  vn_fase := 4.5;
                  -- Se a cidade do "prestador" for diferente da cidade da "Natureza da Operação" não cálcula o imposto.
                  if nvl(gn_cidade_id_tomador,0) <> nvl(rec_nos.cidade_id,0)
                     and gt_row_nat_oper_serv.dm_nat_oper <> 2 -- Tributação fora do município
                     then
                     --
                     goto proximo;
                     --
                  else
                     vn_cidade_id := gn_cidade_id_tomador;
                  end if;
                  --
               end if;
               --
               vn_fase := 4.6;
               -- Atribui a cidade de prestação do serviço
               update item_nota_fiscal set cidade_ibge = pk_csf.fkg_ibge_cidade_id ( vn_cidade_id )
                where id = rec.itemnf_id;
               --
            end if;
            --
         end if;
         --
         vn_fase := 5;
         -- Se destinatário é do tipo "Simples Nacional" e o tipo de imposto é "retenção", não cálcula.
         if gv_simplesnacional = '1'
            and rec_nos.dm_tipo = 1
            and vv_tipoimp_sigla <> 'ISS'
            then
            --
            goto proximo;
            --
         end if;
         --
         vn_fase := 6;
         -- Considera Notas Fiscais de Serviços não retidas dentro do mês
         if nvl(rec_nos.dm_cons_per_ant_mes,0) = 1 then
            --
            vn_fase := 6.1;
            vn_vlr_bc_acm := 0;
            --
            if nvl(rec_nos.dm_fato_gera_ret,0) = 1 then -- Emissão da Nota Fiscal
               --
               vn_fase := 6.2;
               --
               begin
                  --
                  select sum(inf.vl_item_bruto)
                    into vn_vlr_bc_acm
                    from nota_fiscal       nf
                       , mod_fiscal        mf
                       , nat_oper_serv     nos
                       , param_imp_nat_oper_serv pi
                       , item_nota_fiscal  inf
                   where nf.empresa_id     = gn_empresa_id
                     and nf.dm_ind_emit    = gt_row_nat_oper_serv.dm_ind_emit
                     and nf.dm_ind_oper    = decode(gt_row_nat_oper_serv.dm_ind_emit, 0, 1, 0)
                     and nf.pessoa_id      = gn_pessoa_id
                     and nf.id             <> en_notafiscal_id
                     and ((nf.dm_ind_emit = 1 and to_char(nvl(nf.dt_sai_ent,nf.dt_emiss),'rrrrmm') = to_char(gd_dt_emiss,'rrrrmm'))
                           or
                          (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and to_char(nf.dt_emiss,'rrrrmm') = to_char(gd_dt_emiss,'rrrrmm'))
                           or
                          (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_char(nf.dt_emiss,'rrrrmm') = to_char(gd_dt_emiss,'rrrrmm'))
                           or
                          (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and to_char(nvl(nf.dt_sai_ent,nf.dt_emiss),'rrrrmm') = to_char(gd_dt_emiss,'rrrrmm')))
                     and mf.id             = nf.modfiscal_id
                     and mf.cod_mod        IN ('99', 'ND') -- Serviços
                     and nos.natoper_id    = nf.natoper_id
                     and pi.natoperserv_id = nos.id
                     and pi.dm_tipo        = rec_nos.dm_tipo
                     and pi.tipoimp_id     = rec_nos.tipoimp_id
                     and inf.notafiscal_id = nf.id;
                  --
               exception
                  when others then
                     vn_vlr_bc_acm := 0;
               end;
               --
            elsif nvl(rec_nos.dm_fato_gera_ret,0) = 2 then -- Vencimento do Título
               --
               vn_fase := 6.3;
               --
               begin
                  --
                  select sum(inf.vl_item_bruto)
                    into vn_vlr_bc_acm
                    from nota_fiscal       nf
                       , mod_fiscal        mf
                       , nat_oper_serv     nos
                       , param_imp_nat_oper_serv pi
                       , nota_fiscal_cobr  nfc
                       , nfcobr_dup        nfcd
                       , item_nota_fiscal  inf
                   where nf.empresa_id     = gn_empresa_id
                     and nf.dm_ind_emit    = gt_row_nat_oper_serv.dm_ind_emit
                     and nf.dm_ind_oper    = decode(gt_row_nat_oper_serv.dm_ind_emit, 0, 1, 0)
                     and nf.pessoa_id      = gn_pessoa_id
                     and nf.id             <> en_notafiscal_id
                     and mf.id             = nf.modfiscal_id
                     and mf.cod_mod        IN ('99', 'ND') -- Serviços
                     and nos.natoper_id    = nf.natoper_id
                     and pi.natoperserv_id = nos.id
                     and pi.dm_tipo        = rec_nos.dm_tipo
                     and pi.tipoimp_id     = rec_nos.tipoimp_id
                     and nfc.notafiscal_id = nf.id
                     and nfcd.nfcobr_id    = nfc.id
                     and to_char(nfcd.dt_vencto, 'rrrrmm') = to_char(gd_dt_emiss, 'rrrrmm')
                     and inf.notafiscal_id = nf.id;
                  --
               exception
                  when others then
                     vn_vlr_bc_acm := 0;
               end;
               --
            end if;
            --
            vn_fase := 6.4;
            -- Se a base acumulada for menor que o "valor mínimo"
            if nvl(vn_vlr_bc_acm,0) <= nvl(rec_nos.valor_min,0) then
               -- Se a (base acumulada + base da NFS) for menor que o "valor mínimo", não cálculo o imposto ainda
               if ( nvl(vn_vlr_bc_acm,0) + nvl(vn_vl_base_calc,0) ) <= nvl(rec_nos.valor_min,0) then
                  --
                  goto proximo;
                  --
               else
                  --
                  vn_vlr_bc_acm   := ( nvl(vn_vlr_bc_acm,0) + nvl(vn_vl_base_calc,0) );
                  vn_vl_base_calc := vn_vlr_bc_acm;
                  --
               end if;
               --
            else
               --
               vn_vlr_bc_acm := nvl(vn_vlr_bc_acm,0) + nvl(vn_vl_base_calc,0);
               --
            end if;
            --
         else
            --
            vn_fase := 6.5;
            vn_vlr_bc_acm := nvl(vn_vl_base_calc,0);
            --
         end if;
         --
         vn_fase := 7;
         -- Cálcula o imposto se o "valor do serviço" for maior ou igual a "valor mínimo" difinido para o cálculo
         if nvl(vn_vlr_bc_acm,0) >= nvl(rec_nos.valor_min,0) then
            --
            vn_fase := 7.1;
            -- apaga os impostos anteriores do item.
            delete from imp_itemnf
             where itemnf_id = rec.itemnf_id
               and tipoimp_id = rec_nos.tipoimp_id
               and dm_tipo = rec_nos.dm_tipo;
            --
            vn_fase := 7.2;
            -- Caso seja um cod_st que não permita base de calculo, zera a base (seguindo a regra da procedure pkb_valida_imposto_item)
            if pk_csf.fkg_cod_st_cod( en_id_st => rec_nos.codst_id ) in ('06', '73') then
               vn_vl_base_calc := 0;
            end if;
            --
            vn_fase := 7.3;
            -- gera um novo registro para o imposto
            gt_row_imp_itemnf := null;
            --
            select impitemnf_seq.nextval
              into gt_row_imp_itemnf.id
              from dual;
            --
            vn_fase := 7.4;
            --
            gt_row_imp_itemnf.itemnf_id    := rec.itemnf_id;
            gt_row_imp_itemnf.tipoimp_id   := rec_nos.tipoimp_id;
            gt_row_imp_itemnf.dm_tipo      := rec_nos.dm_tipo;
            gt_row_imp_itemnf.codst_id     := rec_nos.codst_id;
            gt_row_imp_itemnf.vl_base_calc := nvl(vn_vl_base_calc,0);
            gt_row_imp_itemnf.aliq_apli    := nvl(rec_nos.aliq,0);
            gt_row_imp_itemnf.dm_orig_calc := 2; -- Compliance
            gt_row_imp_itemnf.vl_imp_trib  := gt_row_imp_itemnf.vl_base_calc * (gt_row_imp_itemnf.aliq_apli/100);
            --
            vn_fase := 7.5;
            --
            insert into imp_itemnf ( id
                                   , itemnf_id
                                   , tipoimp_id
                                   , dm_tipo
                                   , codst_id
                                   , vl_base_calc
                                   , aliq_apli
                                   , vl_imp_trib
                                   , dm_orig_calc
                                   , tiporetimp_id
                                   )
                            values ( gt_row_imp_itemnf.id
                                   , gt_row_imp_itemnf.itemnf_id
                                   , gt_row_imp_itemnf.tipoimp_id
                                   , gt_row_imp_itemnf.dm_tipo
                                   , gt_row_imp_itemnf.codst_id
                                   , gt_row_imp_itemnf.vl_base_calc
                                   , gt_row_imp_itemnf.aliq_apli
                                   , gt_row_imp_itemnf.vl_imp_trib
                                   , gt_row_imp_itemnf.dm_orig_calc
                                   , gt_row_imp_itemnf.tiporetimp_id
                                   );
            --
            vn_fase := 7.6;
            -- Atualiza o Código de Tributação do Municipio no item
            if nvl(rec_nos.codtribmunicipio_id,0) > 0 then
               --
               vn_fase := 7.61;
               --
               update itemnf_compl_serv
                  set codtribmunicipio_id = rec_nos.codtribmunicipio_id
                    , dm_ind_orig_cred    = gt_row_nat_oper_serv.dm_ind_orig_cred
                    , cnae                = gt_row_nat_oper_serv.cnae
                where itemnf_id = rec.itemnf_id;
               --
            end if;
            --
         end if;
         --
         vn_fase := 8;
         --
         <<proximo>>
         --
         null;
         --
      end loop;
      --
      vn_fase := 10;
      --
      update item_nota_fiscal
         set unid_trib = 'UN'
           , cod_cta   = pk_csf.fkg_cd_plano_conta ( gt_row_nat_oper_serv.planoconta_id )
           , cfop_id   = gt_row_nat_oper_serv.cfop_id
           , cfop      = pk_csf.fkg_cfop_cd ( gt_row_nat_oper_serv.cfop_id )
       where id = rec.itemnf_id;
      --
      vn_fase := 11;
      --
      update itemnf_compl_serv
         set basecalccredpc_id = gt_row_nat_oper_serv.basecalccredpc_id
           , dm_loc_exe_serv   = gt_row_nat_oper_serv.dm_loc_exe_serv
           , centrocusto_id    = gt_row_nat_oper_serv.centrocusto_id
       where itemnf_id = rec.itemnf_id;
      --
   end loop;
   --
   vn_fase := 12;
   --
   update nf_compl_serv
      set dm_nat_oper = nvl(gt_row_nat_oper_serv.dm_nat_oper, 1)
    where notafiscal_id = en_notafiscal_id;
   --
   vn_fase := 13;
   --
   update nota_fiscal
      set nat_oper = 'NF Servico'
    where id             = en_notafiscal_id
      and trim(nat_oper) is null;
   --
   vn_fase := 14;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_nfs.pkb_gera_imposto_nfs fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%type;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_mensagem_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => erro_de_sistema
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_gera_imposto_nfs;

----------------------------------------------------------
-- Procedimento complementa a informação da nota fiscal --
----------------------------------------------------------
PROCEDURE PKB_MONTA_COMPL_INFOR_ADIC ( EST_LOG_GENERICO_NF   IN OUT NOCOPY  DBMS_SQL.NUMBER_TABLE
                                     , EN_NOTAFISCAL_ID      IN             NOTA_FISCAL.ID%TYPE
             , EV_TEXTO_COMPL        IN             NFINFOR_ADIC.CONTEUDO%TYPE
                                     )
IS
   --
   vn_fase                  number := 0;
   vn_loggenerico_id        log_generico_nf.id%type;
   vv_texto_compl           nfinfor_adic.conteudo%type := null;
   vv_inf_contr             NFInfor_Adic.conteudo%type := null;
   vn_nfinforadic_id        NFInfor_Adic.id%type := null;
   vn_tam_inf_contr         number := 0;
   vn_tam_compl             number := 0;
   vv_novo_conteudo         NFInfor_Adic.conteudo%type := null;
   vn_tipo_integr_atual     number := null;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if nvl(en_notafiscal_id,0) > 0 then
      --
      if trim(ev_texto_compl) is not null then
         --
         vv_texto_compl := trim(ev_texto_compl);
         --
         vn_fase := 2;
         -- Pega o tamanho da informação adicional do contribuinte para tratar e não exceder os 4 mil caracteres permitidos!
         begin
            select inf.conteudo
                 , inf.id
              into vv_inf_contr
                 , vn_nfinforadic_id
              from NFInfor_Adic inf
             where inf.notafiscal_id = en_notafiscal_id
               and inf.dm_tipo       = 0 -- Contribuinte
               and inf.campo        is null;
         exception
            when others then
               vv_inf_contr := null;
         end;
         --
         vn_fase := 3;
         --
         vn_tam_inf_contr := length(vv_inf_contr);
         --
         if nvl(vn_tam_inf_contr,0) > 0 then
            --
            vv_texto_compl := vv_texto_compl || ', ';
            --
         end if;
         -- Pega o tamanho do complemento
         vn_tam_compl := length(vv_texto_compl);
         --
         vn_fase := 4;
         -- Se a informação do contribuinte mais a o complemento exceder os 4 mil carecteres, desconta da informação do Contribuinte
         if (nvl(vn_tam_inf_contr,0) + nvl(vn_tam_compl,0)) > 4000 then
            --
            vn_tam_inf_contr := nvl(vn_tam_inf_contr,0) - nvl(vn_tam_compl,0);
            --
            if nvl(vn_tam_inf_contr,0) < 0 then
               --
               vn_tam_inf_contr := nvl(vn_tam_inf_contr,0) * (-1);
               --
            end if;
            --
         end if;
         --
         vn_fase := 5;
         -- Monta o conteúdo novo da Informação do Contribuinte
         vv_novo_conteudo := vv_texto_compl || substr(vv_inf_contr, 1, vn_tam_inf_contr);
         --
         vn_fase := 6;
         -- Trata o tipo de integração para não atrapalhar as demais notas fiscais
         vn_tipo_integr_atual := gn_tipo_integr;
         -- Se tem ID da informação Adicional do Contribuinte, então somente atualiza
         if nvl(vn_nfinforadic_id,0) > 0 then
            gn_tipo_integr := 0;
         else -- Senão, cria o registro de informação Adicional do Contribuinte
            gn_tipo_integr := 1;
         end if;
         -- Atualiza a informação do contribuinte!
         --
         gt_row_NFInfor_Adic := null;
         --
         vn_fase := 7;
         --
         gt_row_NFInfor_Adic.id                 := vn_nfinforadic_id;
         gt_row_NFInfor_Adic.notafiscal_id      := en_notafiscal_id;
         gt_row_NFInfor_Adic.dm_tipo            := 0; -- Contribuinte
         gt_row_NFInfor_Adic.infcompdctofis_id  := null;
         gt_row_NFInfor_Adic.campo              := null;
         gt_row_NFInfor_Adic.conteudo           := vv_novo_conteudo;
         gt_row_NFInfor_Adic.origproc_id        := null;
         --
         vn_fase := 8;
         --
         -- Chama o procedimento de validação dos dados da Informação Adicional da Nota Fiscal
         pkb_integr_nfinfor_adic ( est_log_generico_nf     => est_log_generico_nf
                                 , est_row_NFInfor_Adic => gt_row_NFInfor_Adic
                                 , en_cd_orig_proc      => null );
         --
         gn_tipo_integr := vn_tipo_integr_atual;
         --
      end if;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_nfs.pkb_monta_compl_infor_adic fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                             , ev_mensagem         => gv_cabec_log
                             , ev_resumo           => gv_mensagem_log
                             , en_tipo_log         => erro_de_validacao
                             , en_referencia_id    => gn_referencia_id
                             , ev_obj_referencia   => gv_obj_referencia );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                , est_log_generico_nf => est_log_generico_nf );
      exception
         when others then
            null;
      end;
      --
END PKB_MONTA_COMPL_INFOR_ADIC;

-----------------------------------------------------------------------------------------

-- Procedimento Solicita o Calculo dos Impostos
procedure pkb_solic_calc_imp ( est_log_generico_nf  in out nocopy dbms_sql.number_table
                             , en_notafiscal_id     in            nota_fiscal.id%type
                             )
is
   --
   vn_fase                      number := 0;
   vn_loggenerico_id            log_generico_nf.id%type;
   vt_log_generico_calcfiscal   dbms_sql.number_table;
   --
   vn_empresa_id                empresa.id%type;
   vn_dm_util_epropria          param_empr_calc_fiscal.dm_util_epropria%type;
   vn_dm_util_eterceiro         param_empr_calc_fiscal.dm_util_eterceiro%type;
   vn_cidade_id                 cidade.id%type;
   --
   vn_pessoa_id                 pessoa.id%type;
   vv_uf                        varchar2(2);
   vv_suframa                   nota_fiscal_dest.suframa%type;
   vv_cod_nat                   nat_oper.cod_nat%type;
   vv_cod_mod                   mod_fiscal.cod_mod%type;
   --
   vv_ind_ie_cd_part            valor_tipo_param.cd%type;
   vv_reg_trib_cd_part          valor_tipo_param.cd%type;
   vv_mot_deson_cd_part         valor_tipo_param.cd%type;
   vv_calc_icmsst_cd_part       valor_tipo_param.cd%type;
   vv_ind_ativ_cd_part          valor_tipo_param.cd%type;
   --
   vt_row_solic_calc            solic_calc%rowtype;
   vt_row_item_solic_calc       item_solic_calc%rowtype;
   vt_part_icms_solic_calc      part_icms_solic_calc%rowtype;
   vt_total_solic_calc          total_solic_calc%rowtype;
   --
   vt_row_itemnf_compl_serv     itemnf_compl_serv%rowtype;
   vt_row_imp_itemnf_ii         imp_itemnf%rowtype;
   vn_tipoimposto_cd            tipo_imposto.cd%type;
   vv_conteudo                  nfinfor_adic.conteudo%type;
   vn_tipo_log                  number;
   vn_dm_guarda_imp_orig        number(1);
   vn_existe_dados              number(1);
   vn_vl_base_calc              imp_itemnf.vl_base_calc%type;
   vn_aliq_apli                 imp_itemnf.aliq_apli%type;
   vn_vl_imp_trib               imp_itemnf.vl_imp_trib%type;
   vn_dm_manter_bc_int          imp_itemnf_orig.dm_manter_bc_int%type;
   --
   cursor c_inf is
   select inf.*
     from item_nota_fiscal inf
    where inf.notafiscal_id = en_notafiscal_id
    order by inf.nro_item;
   --
   cursor c_iisc ( en_itemsoliccalc_id in item_solic_calc.id%type ) is
   select isc.cod_item       , isc.nro_item       , ii.tipoimp_id          , ii.dm_tipo
        , ii.vl_imp_nao_dest , ii.vl_icms_deson   , ii.vl_icms_oper        , ii.percent_difer
        , ii.vl_icms_difer   , ii.vl_base_calc    , ii.vl_icmsst_dest      , ii.vl_bc_st_dest
        , ii.dm_manter_bc_int, ii.itemsoliccalc_id, ii.memoria, ii.codst_id, ii.aliq_apli
        , ii.vl_imp_trib     , ii.perc_reduc      , ii.qtde_base_calc_prod , ii.vl_aliq_prod
        , ii.vl_bc_st_ret    , ii.vl_icmsst_ret   , ii.perc_adic
     from imp_itemsc      ii
        , item_solic_calc isc
    where isc.id              = ii.itemsoliccalc_id
      and ii.itemsoliccalc_id = en_itemsoliccalc_id
    order by 1;
   --
   cursor c_iasc ( en_soliccalc_id in solic_calc.id%type ) is
   select *
     from sc_infor_adic
    where soliccalc_id = en_soliccalc_id
    order by 1;
   --
   cursor c_log ( en_soliccalc_id in solic_calc.id%type ) is
   select *
     from log_generico_calcfiscal
    where referencia_id  = en_soliccalc_id
      and obj_referencia = 'SOLIC_CALC'
    order by 1;
   --
   cursor c_imp_orig ( en_itemnf_id imp_itemnf.itemnf_id%type ) is
   select *
     from imp_itemnf ii
    where itemnf_id = en_itemnf_id
    order by 1;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_notafiscal_id,0) > 0 then
      --
      vt_log_generico_calcfiscal.delete;
      --
      vn_fase := 1.1;
      --
      vn_empresa_id := pk_csf.fkg_empresa_notafiscal ( en_notafiscal_id => en_notafiscal_id );
      --
      vn_fase := 1.2;
      --
      vt_row_solic_calc := null;
      --
      vt_row_solic_calc.empresa_id    := vn_empresa_id;
      vt_row_solic_calc.dm_situacao   := 0; -- Aberto;
      vt_row_solic_calc.dm_st_integr  := 0; -- Indefinido
      vt_row_solic_calc.dt_solic      := sysdate;
      --
      -- recupera dados da Nota Fiscal
      begin
         --
         select nf.natoper_id
              , nf.dm_ind_emit
              , nf.dm_ind_oper
              , nf.modfiscal_id
              , nf.serie
              , nf.nro_nf
              , nvl(nf.dt_sai_ent, nf.dt_emiss)
              , nf.pessoa_id
              , nf.dm_ind_final
              , nf.dm_ind_ativ_part
              , nf.dm_mot_des_icms_part
              , nf.dm_calc_icmsst_part
           into vt_row_solic_calc.natoper_id
              , vt_row_solic_calc.dm_ind_emit
              , vt_row_solic_calc.dm_ind_oper
              , vt_row_solic_calc.modfiscal_id
              , vt_row_solic_calc.serie
              , vt_row_solic_calc.numero
              , vt_row_solic_calc.dt_emiss
              , vn_pessoa_id
              , vt_row_solic_calc.dm_cons_final
              , vt_row_solic_calc.dm_ind_ativ_part
              , vt_row_solic_calc.dm_mot_des_icms_part
              , vt_row_solic_calc.dm_calc_icmsst_part
           from nota_fiscal    nf
          where nf.id               = en_notafiscal_id
            and nf.dm_arm_nfe_terc  = 0;
         --
      exception
         when others then
            vt_row_solic_calc.natoper_id           := null;
            vt_row_solic_calc.dm_ind_emit          := null;
            vt_row_solic_calc.dm_ind_oper          := null;
            vt_row_solic_calc.modfiscal_id         := null;
            vt_row_solic_calc.serie                := null;
            vt_row_solic_calc.numero               := null;
            vt_row_solic_calc.dt_emiss             := null;
            vn_pessoa_id                           := null;
            vt_row_solic_calc.dm_cons_final        := null;
            vt_row_solic_calc.dm_ind_ativ_part     := null;
            vt_row_solic_calc.dm_mot_des_icms_part := null;
            vt_row_solic_calc.dm_calc_icmsst_part  := null;
      end;
      --
      vn_fase := 1.3;
      --
      if vt_row_solic_calc.dm_ind_emit = 0 then -- Emissão Propria
         --
         vn_dm_util_epropria := pk_csf_calc_fiscal.fkg_empr_util_epropria ( en_empresa_id => vn_empresa_id );
         vn_dm_util_eterceiro := 0;
         --
      else
         --
         vn_dm_util_epropria := 0;
         vn_dm_util_eterceiro := pk_csf_calc_fiscal.fkg_empr_util_eterceiro ( en_empresa_id => vn_empresa_id );
         --
      end if;
      --
      vn_fase := 2;
      --
      if nvl(vn_dm_util_epropria,0) = 1 -- Sim, utiliza Calculadora Fiscal
         or nvl(vn_dm_util_eterceiro,0) = 1
         then
         --
         vn_fase := 2.1;
         --
         vv_cod_nat := pk_csf.fkg_cod_nat_id ( en_natoper_id => vt_row_solic_calc.natoper_id );
         --
         vn_fase := 2.2;
         --
         vv_cod_mod := pk_csf.fkg_cod_mod_id ( en_modfiscal_id => vt_row_solic_calc.modfiscal_id );
         --
         vn_fase := 2.3;
         --
         if nvl(vt_row_solic_calc.numero,0) > 0 then
            --
            vn_fase := 3;
            --
            if vt_row_solic_calc.dm_ind_emit = 0 then -- Emissão Propria
               -- recupera dados do destinatário
               vn_fase := 3.1;
               --
               begin
                  --
                  select d.uf
                       , case when trim(d.cpf) is not null then trim(d.cpf) else trim(d.cnpj) end
                       , d.dm_ind_ie_dest
                       , d.suframa
                       , d.dm_reg_trib
                    into vv_uf
                       , vt_row_solic_calc.cpf_cnpj_part
                       , vt_row_solic_calc.dm_ind_ie_part
                       , vv_suframa
                       , vt_row_solic_calc.dm_reg_trib_part
                    from nota_fiscal_dest d
                   where d.notafiscal_id = en_notafiscal_id;
                  --
               exception
                  when others then
                     vv_uf := null;
                     vt_row_solic_calc.cpf_cnpj_part   := null;
                     vt_row_solic_calc.dm_ind_ie_part  := null;
                     vv_suframa                        := null;
                     vt_row_solic_calc.dm_reg_trib_part := null;
               end;
               --
               vn_fase := 3.11;
               --
               if nvl(vn_pessoa_id,0) > 0
                  and trim(vv_uf) is null then
                  --
                  vn_fase := 3.111;
                  --
                  vt_row_solic_calc.cpf_cnpj_part := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => vn_pessoa_id );
                  --
                  vn_fase := 3.112;
                  --
                  begin
                     --
                     select est.sigla_estado
                       into vv_uf
                       from pessoa p
                          , cidade cid
                          , estado est
                      where p.id    = vn_pessoa_id
                        and cid.id  = p.cidade_id
                        and est.id  = cid.estado_id;
                     --
                  exception
                     when others then
                        vv_uf := null;
                  end;
                  --
               end if;
               --
               vn_fase := 3.14;
               --
               if trim(vv_suframa) is not null then
                  vt_row_solic_calc.dm_part_tem_suframa := 1; -- Sim
               else
                  vt_row_solic_calc.dm_part_tem_suframa := 0; -- Não
               end if;
               --
            else
               -- Emissão de Terceiros
               -- recupera dados do emitente
               vn_fase := 3.2;
               --
               begin
                  --
                  select e.uf
                       , case when trim(e.cpf) is not null then trim(e.cpf) else trim(e.cnpj) end
                       , e.dm_reg_trib
                       , e.dm_ind_ie_emit
                       , e.suframa
                    into vv_uf
                       , vt_row_solic_calc.cpf_cnpj_part
                       , vt_row_solic_calc.dm_reg_trib_part
                       , vt_row_solic_calc.dm_ind_ie_part
                       , vv_suframa
                    from nota_fiscal_emit e
                   where e.notafiscal_id = en_notafiscal_id;
                  --
               exception
                  when others then
                     vv_uf := null;
                     vt_row_solic_calc.cpf_cnpj_part := null;
                     vv_suframa := null;
                     vt_row_solic_calc.dm_reg_trib_part := null;
                     vt_row_solic_calc.dm_ind_ie_part := null;
               end;
               --
               vn_fase := 3.21;
               --
               if trim(vt_row_solic_calc.cpf_cnpj_part) is null then
                  vt_row_solic_calc.cpf_cnpj_part := pk_csf.fkg_cnpjcpf_pessoa_id ( en_pessoa_id => vn_pessoa_id );
               end if;
               --
               vn_fase := 3.22;
               --
               if trim(vv_uf) is null then
                  --
                  begin
                     --
                     select est.sigla_estado
                       into vv_uf
                       from pessoa p
                          , cidade cid
                          , estado est
                      where p.id    = vn_pessoa_id
                        and cid.id  = p.cidade_id
                        and est.id  = cid.estado_id;
                     --
                  exception
                     when others then
                        vv_uf := null;
                  end;
                  --
               end if;
               --
               vn_fase := 3.23;
               --
               if trim(vv_suframa) is null then
                  --
                  begin
                     --
                     select j.suframa
                       into vv_suframa
                       from juridica j
                      where j.pessoa_id = vn_pessoa_id;
                     --
                  exception
                     when others then
                        vv_suframa := null;
                  end;
                  --
               end if;
               --
               vn_fase := 3.24;
               --
               if trim(vv_suframa) is not null then
                  vt_row_solic_calc.dm_part_tem_suframa := 1; -- Sim
               else
                  vt_row_solic_calc.dm_part_tem_suframa := 0; -- Não
               end if;
               --
            end if;
            --
            vn_fase := 3.12;
            --
            vt_row_solic_calc.estado_id := pk_csf.fkg_Estado_id ( ev_sigla_estado => vv_uf );
            --
            vn_fase := 3.13;
            --
            if vv_uf = 'EX' then
               vt_row_solic_calc.dm_tipo_part := 2; -- Juridica
            else
               --
               if length(vt_row_solic_calc.cpf_cnpj_part) = 11 then
                  vt_row_solic_calc.dm_tipo_part := 1; -- Fisica
               else
                  vt_row_solic_calc.dm_tipo_part := 2; -- Juridica
               end if;
               --
            end if;
            --
            vn_fase := 3.3;
            --
            if vt_row_solic_calc.dm_ind_ie_part is null then
               --
               vn_fase := 3.31;
               --
               vv_ind_ie_cd_part := pk_csf.fkg_pessoa_valortipoparam_cd ( ev_tipoparam_cd => '8' -- Indicador da Inscrição Estadual
                                                                        , en_pessoa_id    => vn_pessoa_id );
               --
               vn_fase := 3.32;
               --
               if trim(vv_ind_ie_cd_part) is null then
                  vt_row_solic_calc.dm_ind_ie_part := 9; -- Não Contribuinte
               else
                  vt_row_solic_calc.dm_ind_ie_part := trim(vv_ind_ie_cd_part);
               end if;
               --
            end if;
            --
            vn_fase := 3.4;
            --
            --if vt_row_solic_calc.dm_reg_trib_part is null then
               --
               vn_fase := 3.41;
               --
               vv_reg_trib_cd_part := pk_csf.fkg_pessoa_valortipoparam_cd ( ev_tipoparam_cd => '9' -- Regime Tributário
                                                                          , en_pessoa_id    => vn_pessoa_id );
               --
               vn_fase := 3.42;
               --
               if trim(vv_reg_trib_cd_part) is null then
                  vt_row_solic_calc.dm_reg_trib_part := 3; -- Regime Normal
               else
                  vt_row_solic_calc.dm_reg_trib_part := trim(vv_reg_trib_cd_part);
               end if;
               --
            --end if;
            --
            vn_fase := 3.6;
            --
            if vt_row_solic_calc.dm_ind_ativ_part is null then
               --
               vn_fase := 3.61;
               --
               vv_ind_ativ_cd_part := pk_csf.fkg_pessoa_valortipoparam_cd ( ev_tipoparam_cd => '10' -- Indicador de tipo de atividade
                                                                          , en_pessoa_id    => vn_pessoa_id );
               --
               vn_fase := 3.62;
               --
               if trim(vv_ind_ativ_cd_part) is null then
                  vt_row_solic_calc.dm_ind_ativ_part := 1; -- Outros
               else
                  vt_row_solic_calc.dm_ind_ativ_part := trim(vv_ind_ativ_cd_part);
               end if;
               --
            end if;
            --
            vn_fase := 3.7;
            --
            if vt_row_solic_calc.dm_mot_des_icms_part is null then
               --
               vn_fase := 3.71;
               --
               vv_mot_deson_cd_part := pk_csf.fkg_pessoa_valortipoparam_cd ( ev_tipoparam_cd => '7' -- Motivo de Desoneracao
                                                                           , en_pessoa_id    => vn_pessoa_id );
               --
               vn_fase := 3.72;
               --
               if trim(vv_ind_ativ_cd_part) is null then
                  vt_row_solic_calc.dm_mot_des_icms_part := null;
               else
                  vt_row_solic_calc.dm_mot_des_icms_part := trim(vv_mot_deson_cd_part);
               end if;
               --
            end if;
            --
            vn_fase := 3.8;
            --
            if vt_row_solic_calc.dm_calc_icmsst_part is null then
               --
               vn_fase := 3.81;
               --
               vv_calc_icmsst_cd_part := pk_csf.fkg_pessoa_valortipoparam_cd ( ev_tipoparam_cd => '6' -- Calcular ICMS-ST
                                                                             , en_pessoa_id    => vn_pessoa_id );
               --
               vn_fase := 3.82;
               --
               if trim(vv_calc_icmsst_cd_part) is null then
                  vt_row_solic_calc.dm_calc_icmsst_part := 1; -- Sim
               else
                  vt_row_solic_calc.dm_calc_icmsst_part := trim(vv_calc_icmsst_cd_part);
               end if;
               --
            end if;
            --
            vn_fase := 3.9;
            --
            if vt_row_solic_calc.dm_cons_final is null then
               --
               vt_row_solic_calc.dm_cons_final := 0; -- Não
               --
            end if;
            --
            vn_fase := 3.999;
            -- Chama API
            -- Procedimento que faz a validação e gravação dos dados na tabela SOLIC_CALC
            pk_csf_api_calc_fiscal.pkb_integr_solic_calc ( est_log_generico_calcfiscal   => vt_log_generico_calcfiscal
                                                         , est_row_solic_calc            => vt_row_solic_calc
                                                         , ev_cod_nat                    => vv_cod_nat
                                                         , ev_cod_mod                    => vv_cod_mod
                                                         , ev_sigla_estado_part          => vv_uf
                                                         );
            --
            vn_fase := 4;
            --
            if nvl(vt_row_solic_calc.id,0) > 0 then
               --
               vn_fase := 4.1;
               --
               -- Verifica se guarda os dados originais de impostos
               vn_dm_guarda_imp_orig := pk_csf.fkg_empresa_guarda_imporig ( en_empresa_id => vn_empresa_id );
               --
               if nvl(vn_dm_guarda_imp_orig, 0) = 1 then
                  --
                  vn_existe_dados := pk_csf.fkg_existe_nf_imp (en_notafiscal_id => en_notafiscal_id);
                  --
               else
                  --
                  vn_existe_dados := null;
                  --
               end if;
               --
               -- Integra os itens para a Solicitação de Calculo
               --
               for rec_inf in c_inf loop
                  exit when c_inf%notfound or (c_inf%notfound) is null;
                  --
                  vt_row_item_solic_calc   := null;
                  vt_row_itemnf_compl_serv := null;
                  vt_row_imp_itemnf_ii     := null;
                  --
                  vn_fase := 4.2;
                  -- recupera dados de serviço
                  begin
                     --
                     select *
                       into vt_row_itemnf_compl_serv
                       from itemnf_compl_serv
                      where itemnf_id = rec_inf.id;
                     --
                  exception
                     when others then
                        vt_row_itemnf_compl_serv := null;
                  end;
                  --
                  vn_fase := 4.3;
                  -- recupera dados do impostos de importação
                  begin
                     --
                     select ii.*
                       into vt_row_imp_itemnf_ii
                       from imp_itemnf   ii
                          , tipo_imposto ti
                      where 1            = 1
                        and ii.itemnf_id = rec_inf.id
                        and ii.dm_tipo   = 0
                        and ti.id        = ii.tipoimp_id
                        and ti.cd        = 7;
                     --
                  exception
                     when others then
                        vt_row_imp_itemnf_ii := null;
                  end;
                  --
                  vn_fase := 4.4;
                  --
                  vn_cidade_id := 0;
                  --
                  if vt_row_itemnf_compl_serv.dm_trib_mun_prest = 1 then -- Tributa imposto no "prestador"
                     vn_cidade_id := gn_cidade_id_prestador;
                  else
                     vn_cidade_id := gn_cidade_id_tomador;
                  end if;
                  --
                  vn_fase := 5;
                  --
                  vt_row_item_solic_calc.soliccalc_id               := vt_row_solic_calc.id;
                  vt_row_item_solic_calc.nro_item                   := rec_inf.nro_item;
                  vt_row_item_solic_calc.cod_item                   := rec_inf.cod_item;
                  vt_row_item_solic_calc.descr_item                 := substr(rec_inf.descr_item, 1, 119);
                  vt_row_item_solic_calc.cod_ncm                    := rec_inf.cod_ncm;
                  vt_row_item_solic_calc.extipi                     := rec_inf.cod_ext_ipi;
                  vt_row_item_solic_calc.cod_cest                   := rec_inf.cod_cest;
                  vt_row_item_solic_calc.dm_orig_merc               := rec_inf.orig;
                  vt_row_item_solic_calc.cfop                       := rec_inf.cfop;
                  vt_row_item_solic_calc.cd_lista_serv              := rec_inf.cd_lista_serv;
                  --
                  vn_fase := 5.1;
                  --
                  if trim(rec_inf.cd_lista_serv) is not null then
                     vt_row_item_solic_calc.dm_tipo_item := 2; -- Serviço
                  else
                     vt_row_item_solic_calc.dm_tipo_item := 1; -- Produto
                  end if;
                  --
                  vn_fase := 5.2;
                  --
                  vt_row_item_solic_calc.unid_med                   := rec_inf.unid_com;
                  vt_row_item_solic_calc.qtde                       := 1;                     -- rec_inf.qtde_comerc;
                  vt_row_item_solic_calc.vl_unit                    := rec_inf.vl_item_bruto; -- rec_inf.vl_unit_comerc;
                  vt_row_item_solic_calc.vl_bruto                   := rec_inf.vl_item_bruto;
                  vt_row_item_solic_calc.vl_desc                    := rec_inf.vl_desc;
                  vt_row_item_solic_calc.vl_frete                   := rec_inf.vl_frete;
                  vt_row_item_solic_calc.vl_seguro                  := rec_inf.vl_seguro;
                  vt_row_item_solic_calc.vl_outro                   := rec_inf.vl_outro;
                  vt_row_item_solic_calc.dm_ind_tot                 := rec_inf.dm_ind_tot;
                  --
                  if nvl(vn_cidade_id,0) > 0 then
                     vt_row_item_solic_calc.ibge_cid_serv_prest        := pk_csf.fkg_ibge_cidade_id ( vn_cidade_id );
                  else
                     vt_row_item_solic_calc.ibge_cid_serv_prest        := rec_inf.cidade_ibge;
                  end if;
                  --
                  vn_fase := 5.3;
                  --
                  if nvl(vt_row_itemnf_compl_serv.itemnf_id,0) > 0 then
                     vt_row_item_solic_calc.vl_desc_incondicionado  := vt_row_itemnf_compl_serv.vl_desc_incondicionado;
                     vt_row_item_solic_calc.vl_desc_condicionado    := vt_row_itemnf_compl_serv.vl_desc_condicionado;
                     vt_row_item_solic_calc.vl_deducao              := vt_row_itemnf_compl_serv.vl_deducao;
                     vt_row_item_solic_calc.vl_outra_ret            := vt_row_itemnf_compl_serv.vl_outra_ret;
                     vt_row_item_solic_calc.cod_trib_municipio      := pk_csf_nfs.fkg_cod_trib_municipio_cd (vt_row_itemnf_compl_serv.codtribmunicipio_id);
                  end if;
                  --
                  vn_fase := 5.4;
                  if nvl(vt_row_imp_itemnf_ii.id,0) > 0 then
                     vt_row_item_solic_calc.vl_bc_ii  := vt_row_imp_itemnf_ii.vl_base_calc;
                     vt_row_item_solic_calc.vl_ii     := vt_row_imp_itemnf_ii.vl_imp_trib;
                  end if;
                  --
                  vn_fase := 5.5;
                  --
                  vt_row_item_solic_calc.vl_desp_adu                := rec_inf.vl_desp_adu;
                  vt_row_item_solic_calc.vl_iof                     := rec_inf.vl_iof;
                  --
                  vn_fase := 5.6;
                  -- Chama API
                  -- Procedimento que faz a validação e gravação dos dados na tabela ITEM_SOLIC_CALC
                  pk_csf_api_calc_fiscal.pkb_integr_item_solic_calc ( est_log_generico_calcfiscal   => vt_log_generico_calcfiscal
                                                                    , est_row_item_solic_calc       => vt_row_item_solic_calc
                                                                    , en_empresa_id                 => vt_row_solic_calc.empresa_id
                                                                    );
                  --
               end loop;
               --
               vn_fase := 6;
               --
               if nvl(vt_log_generico_calcfiscal.count,0) > 0 then
                  --
                  vt_row_solic_calc.dm_situacao := 3; -- Erro;
                  --
                  update solic_calc set dm_situacao = vt_row_solic_calc.dm_situacao
                   where id = vt_row_solic_calc.id;
                  --
               end if;
               --
               vn_fase := 6.1;
               --
               commit;
               --
               vn_fase := 6.2;
               --
               if nvl(vt_row_solic_calc.dm_situacao,0) in (0, 1) then
                  --
                  vn_fase := 6.3;
                  --| Chama procedimento da Calculadora Fiscal
                  pk_csf_api_calc_fiscal.pkb_executar_solic_calc ( en_soliccalc_id => vt_row_solic_calc.id );
                  --
               end if;
               --
               vn_fase := 7;
               -- Devolve os dados para a Nota Fiscal Mercantil
               --
               gv_mensagem_log := 'Utilizado a Calculadora Fiscal para geração dos dados fiscais de impostos e retenções (Indentificador: ' || vt_row_solic_calc.id || ' ).';
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                   , ev_mensagem         => gv_cabec_log
                                   , ev_resumo           => gv_mensagem_log
                                   , en_tipo_log         => informacao
                                   , en_referencia_id    => gn_referencia_id
                                   , ev_obj_referencia   => gv_obj_referencia
                                   );
               --
               vn_fase := 7.1;
               -- Atualiza os dados dos itens e impostos/retenções
               for rec_inf in c_inf loop
                  exit when c_inf%notfound or (c_inf%notfound) is null;
                  --
                  vn_fase := 7.2;
                  --
                  vt_row_item_solic_calc  := null;
                  vt_part_icms_solic_calc := null;
                  vt_row_imp_itemnf_ii    := null;
                  --
                  begin
                     --
                     select *
                       into vt_row_item_solic_calc
                       from item_solic_calc
                      where soliccalc_id  = vt_row_solic_calc.id
                        and nro_item      = rec_inf.nro_item;
                     --
                  exception
                     when others then
                        vt_row_item_solic_calc := null;
                  end;
                  --
                  if nvl(vt_row_item_solic_calc.id,0) > 0 then
                     --
                     vn_fase := 7.3;
                     -- Apaga partilha de ICMS
                     delete from imp_itemnf_icms_dest
                      where impitemnf_id in (select id from imp_itemnf where itemnf_id = rec_inf.id);
                     --
                     vn_fase := 7.31;
                     --
                     -- Verifica se a empresa esta parametrizada para guardar os impostos originais
                     -- Verifica se já existe o histórico da nota fiscal (Somente é guardado os impostos do primeiro calculo)
                     if nvl(vn_dm_guarda_imp_orig, 0) = 1 and nvl(vn_existe_dados, 0) = 0 then
                        --
                        vn_fase := 7.32;
                        --
                        for rec_imp_orig in c_imp_orig( rec_inf.id ) loop
                           exit when c_imp_orig%notfound or (c_imp_orig%notfound) is null;
                           --
                           vt_row_imp_itemnf_ii := null;
                           --
                           vt_row_imp_itemnf_ii.id                   := rec_imp_orig.id;
                           vt_row_imp_itemnf_ii.tipoimp_id           := rec_imp_orig.tipoimp_id;
                           vt_row_imp_itemnf_ii.dm_tipo              := rec_imp_orig.dm_tipo;
                           vt_row_imp_itemnf_ii.codst_id             := rec_imp_orig.codst_id;
                           vt_row_imp_itemnf_ii.vl_base_calc         := rec_imp_orig.vl_base_calc;
                           vt_row_imp_itemnf_ii.aliq_apli            := rec_imp_orig.aliq_apli;
                           vt_row_imp_itemnf_ii.vl_imp_trib          := rec_imp_orig.vl_imp_trib;
                           vt_row_imp_itemnf_ii.perc_reduc           := rec_imp_orig.perc_reduc;
                           vt_row_imp_itemnf_ii.perc_adic            := rec_imp_orig.perc_adic;
                           vt_row_imp_itemnf_ii.qtde_base_calc_prod  := rec_imp_orig.qtde_base_calc_prod;
                           vt_row_imp_itemnf_ii.vl_aliq_prod         := rec_imp_orig.vl_aliq_prod;
                           vt_row_imp_itemnf_ii.vl_bc_st_ret         := rec_imp_orig.vl_bc_st_ret;
                           vt_row_imp_itemnf_ii.vl_icmsst_ret        := rec_imp_orig.vl_icmsst_ret;
                           vt_row_imp_itemnf_ii.perc_bc_oper_prop    := rec_imp_orig.perc_bc_oper_prop;
                           vt_row_imp_itemnf_ii.estado_id            := rec_imp_orig.estado_id;
                           vt_row_imp_itemnf_ii.vl_bc_st_dest        := rec_imp_orig.vl_bc_st_dest;
                           vt_row_imp_itemnf_ii.vl_icmsst_dest       := rec_imp_orig.vl_icmsst_dest;
                           vt_row_imp_itemnf_ii.dm_orig_calc         := rec_imp_orig.dm_orig_calc;
                           vt_row_imp_itemnf_ii.tiporetimp_id        := rec_imp_orig.tiporetimp_id;
                           vt_row_imp_itemnf_ii.vl_deducao           := rec_imp_orig.vl_deducao;
                           vt_row_imp_itemnf_ii.vl_base_outro        := rec_imp_orig.vl_base_outro;
                           vt_row_imp_itemnf_ii.vl_imp_outro         := rec_imp_orig.vl_imp_outro;
                           vt_row_imp_itemnf_ii.vl_base_isenta       := rec_imp_orig.vl_base_isenta;
                           vt_row_imp_itemnf_ii.aliq_aplic_outro     := rec_imp_orig.aliq_aplic_outro;
                           vt_row_imp_itemnf_ii.natrecpc_id          := rec_imp_orig.natrecpc_id;
                           vt_row_imp_itemnf_ii.vl_imp_nao_dest      := rec_imp_orig.vl_imp_nao_dest;
                           vt_row_imp_itemnf_ii.vl_icms_deson        := rec_imp_orig.vl_icms_deson;
                           vt_row_imp_itemnf_ii.vl_icms_oper         := rec_imp_orig.vl_icms_oper;
                           vt_row_imp_itemnf_ii.percent_difer        := rec_imp_orig.percent_difer;
                           vt_row_imp_itemnf_ii.vl_icms_difer        := rec_imp_orig.vl_icms_difer;
                           vt_row_imp_itemnf_ii.tiporetimpreceita_id := rec_imp_orig.tiporetimpreceita_id;
                           vt_row_imp_itemnf_ii.vl_bc_fcp            := rec_imp_orig.vl_bc_fcp;
                           vt_row_imp_itemnf_ii.aliq_fcp             := rec_imp_orig.aliq_fcp;
                           vt_row_imp_itemnf_ii.vl_fcp               := rec_imp_orig.vl_fcp;
                           --
                           vn_fase := 7.33;
                           --
                           if nvl(vt_row_imp_itemnf_ii.id,0) > 0 then
                              pk_csf_api_calc_fiscal.pkb_grava_impostos_orig ( en_empresa_id          => vt_row_solic_calc.empresa_id
                                                                             , en_soliccalc_id        => vt_row_solic_calc.id
                                                                             , en_notafiscal_id       => en_notafiscal_id
                                                                             , en_nro_item            => rec_inf.nro_item
                                                                             , en_cod_item            => rec_inf.cod_item
                                                                             , en_cd_lista_serv       => rec_inf.cd_lista_serv
                                                                             , est_row_imp_itemnf_ii  => vt_row_imp_itemnf_ii );
                           end if;
                           --
                        end loop;
                        --
                     end if;
                     --
                     vn_fase := 7.34;
                     --
                     -- Apaga os Impostos
                     delete from imp_itemnf
                      where itemnf_id = rec_inf.id;
                     --
                     vn_fase := 7.4;
                     -- insere os novos impostos
                     for rec_iisc in c_iisc(vt_row_item_solic_calc.id) loop
                        exit when c_iisc%notfound or (c_iisc%notfound) is null;
                        --
                        vn_fase := 7.41;
                        --
                        -- Atualiza a base de calculo, aliquota e valor de imposto com o valor de origem se o DM_MANTER_BC_INT for "1"
                        if nvl(rec_iisc.dm_manter_bc_int,0) = 1 then
                           --
                           begin
                             select ii.vl_base_calc
                                  , ii.aliq_apli
                                  , ii.vl_imp_trib
                               into vn_vl_base_calc
                                  , vn_aliq_apli
                                  , vn_vl_imp_trib
                               from imp_itemnf_orig  ii
                              where ii.notafiscal_id = en_notafiscal_id
                                and ii.nro_item      = rec_iisc.nro_item
                                and ii.cod_item      = rec_iisc.cod_item
                                and ii.tipoimp_id    = rec_iisc.tipoimp_id
                                and ii.dm_tipo       = rec_iisc.dm_tipo;
                              --
                              update imp_itemnf_orig ii
                                 set dm_manter_bc_int = rec_iisc.dm_manter_bc_int
                                where exists ( select *
                                                 from item_nota_fiscal it
                                                where it.notafiscal_id = ii.notafiscal_id
                                                  and it.nro_item      = ii.nro_item
                                                  and it.cod_item      = ii.cod_item
                                                  and it.id            = rec_iisc.itemsoliccalc_id
                                                  and ii.tipoimp_id    = rec_iisc.tipoimp_id
                                                  and ii.dm_tipo       = rec_iisc.dm_tipo);  
                              --  
                              
                              --  
                           exception
                              when others then
                                 vn_vl_base_calc := rec_iisc.vl_base_calc;
                                 vn_aliq_apli    := rec_iisc.aliq_apli;
                                 vn_vl_imp_trib  := rec_iisc.vl_imp_trib;
                           end;
                           --
                        else
                           vn_vl_base_calc := rec_iisc.vl_base_calc;
                           vn_aliq_apli    := rec_iisc.aliq_apli;
                           vn_vl_imp_trib  := rec_iisc.vl_imp_trib;
                        end if;
                        --
                        insert into imp_itemnf ( id
                                               , itemnf_id
                                               , tipoimp_id
                                               , dm_tipo
                                               , codst_id
                                               , vl_base_calc
                                               , aliq_apli
                                               , vl_imp_trib
                                               , perc_reduc
                                               , perc_adic
                                               , qtde_base_calc_prod
                                               , vl_aliq_prod
                                               , vl_bc_st_ret
                                               , vl_icmsst_ret
                                               , perc_bc_oper_prop
                                               , estado_id
                                               , vl_bc_st_dest
                                               , vl_icmsst_dest
                                               , dm_orig_calc
                                               , tiporetimp_id
                                               , vl_deducao
                                               , vl_base_outro
                                               , vl_imp_outro
                                               , vl_base_isenta
                                               , aliq_aplic_outro
                                               , natrecpc_id
                                               , vl_imp_nao_dest
                                               , vl_icms_deson
                                               , vl_icms_oper
                                               , percent_difer
                                               , vl_icms_difer
                                               )
                                        values ( impitemnf_seq.nextval --id
                                               , rec_inf.id -- itemnf_id
                                               , rec_iisc.tipoimp_id
                                               , rec_iisc.dm_tipo
                                               , rec_iisc.codst_id
                                               , vn_vl_base_calc
                                               , vn_aliq_apli
                                               , vn_vl_imp_trib
                                               , rec_iisc.perc_reduc
                                               , rec_iisc.perc_adic
                                               , rec_iisc.qtde_base_calc_prod
                                               , rec_iisc.vl_aliq_prod
                                               , rec_iisc.vl_bc_st_ret
                                               , rec_iisc.vl_icmsst_ret
                                               , null -- perc_bc_oper_prop
                                               , null -- estado_id
                                               , rec_iisc.vl_bc_st_dest
                                               , rec_iisc.vl_icmsst_dest
                                               , 2 -- dm_orig_calc -- Compliance
                                               , null -- tiporetimp_id
                                               , null -- vl_deducao
                                               , null -- vl_base_outro
                                               , null -- vl_imp_outro
                                               , null -- vl_base_isenta
                                               , null -- aliq_aplic_outro
                                               , null -- natrecpc_id
                                               , rec_iisc.vl_imp_nao_dest
                                               , rec_iisc.vl_icms_deson
                                               , rec_iisc.vl_icms_oper
                                               , rec_iisc.percent_difer
                                               , rec_iisc.vl_icms_difer
                                               );
                        --
                        vn_fase := 7.411;
                        --
                        pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                            , ev_mensagem         => 'Nro. Item: ' || rec_inf.nro_item || ' - ' || rec_iisc.memoria
                                            , ev_resumo           => 'Nro. Item: ' || rec_inf.nro_item || ' - ' || rec_iisc.memoria
                                            , en_tipo_log         => INFO_CALC_FISCAL
                                            , en_referencia_id    => gn_referencia_id
                                            , ev_obj_referencia   => gv_obj_referencia
                                            );
                        --
                        vn_fase := 7.42;
                        --
                        vn_tipoimposto_cd := pk_csf.fkg_Tipo_Imposto_cd ( en_tipoimp_id => rec_iisc.tipoimp_id );
                        --
                        vn_fase := 7.43;
                        -- Se for ICMS, atualiza a Partilha de ICMS
                        if nvl(vn_tipoimposto_cd,0) = 1
                           and rec_iisc.dm_tipo = 0 -- Normal
                           then
                           --
                           vn_fase := 7.431;
                           --
                           begin
                              --
                              select * into vt_part_icms_solic_calc
                                from part_icms_solic_calc
                               where itemsoliccalc_id = vt_row_item_solic_calc.id;
                              --
                           exception
                              when others then
                                 vt_part_icms_solic_calc := null;
                           end;
                           --
                           vn_fase := 7.432;
                           --
                           if nvl(vt_part_icms_solic_calc.id,0) > 0 then
                              --
                              insert into imp_itemnf_icms_dest ( id
                                                               , impitemnf_id
                                                               , vl_bc_uf_dest
                                                               , perc_icms_uf_dest
                                                               , perc_icms_inter
                                                               , perc_icms_inter_part
                                                               , vl_icms_uf_dest
                                                               , vl_icms_uf_remet
                                                               , perc_comb_pobr_uf_dest
                                                               , vl_comb_pobr_uf_dest
                                                               )
                                                        values ( impitemnficmsdest_seq.nextval -- id
                                                               , impitemnf_seq.currval --impitemnf_id
                                                               , vt_part_icms_solic_calc.vl_bc_uf_dest
                                                               , vt_part_icms_solic_calc.perc_icms_uf_dest
                                                               , vt_part_icms_solic_calc.perc_icms_inter
                                                               , vt_part_icms_solic_calc.perc_icms_inter_part
                                                               , vt_part_icms_solic_calc.vl_icms_uf_dest
                                                               , vt_part_icms_solic_calc.vl_icms_uf_remet
                                                               , vt_part_icms_solic_calc.perc_comb_pobr_uf_dest
                                                               , vt_part_icms_solic_calc.vl_comb_pobr_uf_dest
                                                               );
                              --
                              vn_fase := 7.433;
                              --
                              pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                  , ev_mensagem         => 'Nro. Item: ' || rec_inf.nro_item || ' - ' || vt_part_icms_solic_calc.memoria
                                                  , ev_resumo           => 'Nro. Item: ' || rec_inf.nro_item || ' - ' || vt_part_icms_solic_calc.memoria
                                                  , en_tipo_log         => INFO_CALC_FISCAL
                                                  , en_referencia_id    => gn_referencia_id
                                                  , ev_obj_referencia   => gv_obj_referencia
                                                  );
                              --
                           end if;
                           --
                        end if;
                        --
                     end loop;
                     --
                     vn_fase := 7.5;
                     -- Atualiza informações do item
                     update item_nota_fiscal set vl_tot_trib_item     = vt_row_item_solic_calc.vl_tot_trib_item
                                               , dm_mod_base_calc     = vt_row_item_solic_calc.dm_mod_base_calc
                                               , dm_mod_base_calc_st  = vt_row_item_solic_calc.dm_mod_base_calc_st
                                               , dm_mot_des_icms      = vt_row_item_solic_calc.dm_mot_des_icms
                                               , cl_enq_ipi           = vt_row_item_solic_calc.cl_enq_ipi
                                               , cod_selo_ipi         = vt_row_item_solic_calc.cod_selo_ipi
                                               , qtde_selo_ipi        = vt_row_item_solic_calc.qtde_selo_ipi
                                               , cod_enq_ipi          = vt_row_item_solic_calc.cod_enq_ipi
                                               , cidade_ibge          = vt_row_item_solic_calc.ibge_cid_serv_prest
                      where id = rec_inf.id;
                     --
                     vn_fase := 7.51;
                     --
                     update nf_compl_serv set dm_nat_oper = vt_row_item_solic_calc.dm_nat_oper_serv
                      where notafiscal_id = en_notafiscal_id;
                     --
                     vn_fase := 7.52;
                     --
                     update itemnf_compl_serv set codtribmunicipio_id = pk_csf_nfs.fkg_cod_trib_municipio_id ( vt_row_item_solic_calc.cod_trib_municipio -- ev_cod_trib_municipio
                                                                                                             , vn_cidade_id -- en_cidadegerador_id
                                                                                                             )
                      where itemnf_id = rec_inf.id;
                     --
                  end if;
                  --
               end loop;
               --
               vn_fase := 8;
               -- Atualiza os dados de totais
               vt_total_solic_calc := null;
               --
               begin
                  --
                  select * into vt_total_solic_calc
                    from total_solic_calc
                   where soliccalc_id = vt_row_solic_calc.id;
                  --
               exception
                  when others then
                     vt_total_solic_calc := null;
               end;
               --
               if nvl(vt_total_solic_calc.id,0) > 0 then
                  --
                  vn_fase := 8.1;
                  --
                  delete from nota_fiscal_total
                   where notafiscal_id = en_notafiscal_id;
                  --
                  vn_fase := 8.2;
                  --
                  insert into nota_fiscal_total ( id
                                                , notafiscal_id
                                                , vl_base_calc_icms
                                                , vl_imp_trib_icms
                                                , vl_base_calc_st
                                                , vl_imp_trib_st
                                                , vl_total_item
                                                , vl_frete
                                                , vl_seguro
                                                , vl_desconto
                                                , vl_imp_trib_ii
                                                , vl_imp_trib_ipi
                                                , vl_imp_trib_pis
                                                , vl_imp_trib_cofins
                                                , vl_outra_despesas
                                                , vl_total_nf
                                                , vl_serv_nao_trib
                                                , vl_base_calc_iss
                                                , vl_imp_trib_iss
                                                , vl_pis_iss
                                                , vl_cofins_iss
                                                , vl_ret_pis
                                                , vl_ret_cofins
                                                , vl_ret_csll
                                                , vl_base_calc_irrf
                                                , vl_ret_irrf
                                                , vl_base_calc_ret_prev
                                                , vl_ret_prev
                                                , vl_total_serv
                                                , vl_abat_nt
                                                , vl_forn
                                                , vl_terc
                                                , vl_servico
                                                , vl_ret_iss
                                                , vl_tot_trib
                                                , vl_icms_deson
                                                , vl_deducao
                                                , vl_outras_ret
                                                , vl_desc_incond
                                                , vl_desc_cond
                                                , vl_icms_uf_dest
                                                , vl_icms_uf_remet
                                                , vl_comb_pobr_uf_dest
                                                , vl_pis_st
                                                , vl_cofins_st
                                                )
                                         values ( notafiscaltotal_seq.nextval -- id
                                                , en_notafiscal_id --notafiscal_id
                                                , vt_total_solic_calc.vl_base_calc_icms
                                                , vt_total_solic_calc.vl_imp_trib_icms
                                                , vt_total_solic_calc.vl_base_calc_st
                                                , vt_total_solic_calc.vl_imp_trib_st
                                                , vt_total_solic_calc.vl_total_item
                                                , vt_total_solic_calc.vl_frete
                                                , vt_total_solic_calc.vl_seguro
                                                , vt_total_solic_calc.vl_desconto
                                                , vt_total_solic_calc.vl_imp_trib_ii
                                                , vt_total_solic_calc.vl_imp_trib_ipi
                                                , vt_total_solic_calc.vl_imp_trib_pis
                                                , vt_total_solic_calc.vl_imp_trib_cofins
                                                , vt_total_solic_calc.vl_outra_despesas
                                                , vt_total_solic_calc.vl_total_nf
                                                , vt_total_solic_calc.vl_serv_nao_trib
                                                , vt_total_solic_calc.vl_base_calc_iss
                                                , vt_total_solic_calc.vl_imp_trib_iss
                                                , vt_total_solic_calc.vl_pis_iss
                                                , vt_total_solic_calc.vl_cofins_iss
                                                , vt_total_solic_calc.vl_ret_pis
                                                , vt_total_solic_calc.vl_ret_cofins
                                                , vt_total_solic_calc.vl_ret_csll
                                                , vt_total_solic_calc.vl_base_calc_irrf
                                                , vt_total_solic_calc.vl_ret_irrf
                                                , vt_total_solic_calc.vl_base_calc_ret_prev
                                                , vt_total_solic_calc.vl_ret_prev
                                                , vt_total_solic_calc.vl_total_serv
                                                , vt_total_solic_calc.vl_abat_nt
                                                , vt_total_solic_calc.vl_forn
                                                , vt_total_solic_calc.vl_terc
                                                , vt_total_solic_calc.vl_servico
                                                , vt_total_solic_calc.vl_ret_iss
                                                , vt_total_solic_calc.vl_tot_trib
                                                , vt_total_solic_calc.vl_icms_deson
                                                , vt_total_solic_calc.vl_deducao
                                                , vt_total_solic_calc.vl_outras_ret
                                                , vt_total_solic_calc.vl_desc_incond
                                                , vt_total_solic_calc.vl_desc_cond
                                                , vt_total_solic_calc.vl_icms_uf_dest
                                                , vt_total_solic_calc.vl_icms_uf_remet
                                                , vt_total_solic_calc.vl_comb_pobr_uf_dest
                                                , null --vt_total_solic_calc.vl_pis_st    -- esse campo não existe ainda na total_solic_calc
                                                , null --vt_total_solic_calc.vl_cofins_st -- esse campo não existe ainda na total_solic_calc
                                                );
                  --
               end if;
               --
               vv_conteudo := null;
               vn_fase := 9;
               -- Atualiza as Informações Adicionais
               for rec_iasc in c_iasc(vt_row_solic_calc.id) loop
                  exit when c_iasc%notfound or (c_iasc%notfound) is null;
                  --
                  vn_fase := 9.1;
                  --
                  if trim(rec_iasc.texto) is not null then
                     --
                     if trim(vv_conteudo) is null then
                        vv_conteudo := vv_conteudo || trim(rec_iasc.texto);
                     else
                        vv_conteudo := vv_conteudo || ' ' || trim(rec_iasc.texto);
                     end if;
                     --
                  end if;
                  --
                  vn_fase := 9.2;
                  --
                  if trim(rec_iasc.obs_compl) is not null then
                     --
                     if trim(vv_conteudo) is null then
                        vv_conteudo := vv_conteudo || trim(rec_iasc.obs_compl);
                     else
                        vv_conteudo := vv_conteudo || ' ' || trim(rec_iasc.obs_compl);
                     end if;
                     --
                  end if;
                  --
               end loop;
               --
               vn_fase := 9.3;
               --
               if trim(vv_conteudo) is not null then
                  --
            pkb_monta_compl_infor_adic ( est_log_generico_nf  => est_log_generico_nf
                                             , en_notafiscal_id     => en_notafiscal_id
                                             , ev_texto_compl       => vv_conteudo
                                             );
                  --
               end if;
               --
               vn_fase := 10;
               -- Atualiza os dados de Log Generico para NF
               for rec_log in c_log(vt_row_solic_calc.id) loop
                  exit when c_log%notfound or (c_log%notfound) is null;
                  --
                  vn_fase := 10.1;
                  --
                  begin
                     --
                     select cd_compat
                       into vn_tipo_log
                       from csf_tipo_log
                      where id = rec_log.csftipolog_id;
                     --
                  exception
                     when others then
                        vn_tipo_log := null;
                  end;
                  --
                  vn_fase := 10.1;
                  --
                  pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                      , ev_mensagem         => rec_log.mensagem
                                      , ev_resumo           => rec_log.resumo
                                      , en_tipo_log         => vn_tipo_log
                                      , en_referencia_id    => gn_referencia_id
                                      , ev_obj_referencia   => gv_obj_referencia
                                      );
                  --
                  vn_fase := 10.2;
                  --
                  if nvl(vn_tipo_log,0) in (1, 2) then
                     --
                     pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                            , est_log_generico_nf => est_log_generico_nf
                                            );
                     --
                  end if;
                  --
               end loop;
               --
            else
               --
               gv_mensagem_log := 'Não foi possível utilizar a Calculadora Fiscal.';
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                   , ev_mensagem         => gv_cabec_log
                                   , ev_resumo           => gv_mensagem_log
                                   , en_tipo_log         => erro_de_validacao
                                   , en_referencia_id    => gn_referencia_id
                                   , ev_obj_referencia   => gv_obj_referencia
                                   );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                      , est_log_generico_nf => est_log_generico_nf
                                      );
               --
            end if;
            --
         else
            --
            gv_mensagem_log := 'Não localido a Nota Fiscal para o identificador: ' || en_notafiscal_id;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                , ev_mensagem         => gv_cabec_log
                                , ev_resumo           => gv_mensagem_log
                                , en_tipo_log         => erro_de_validacao
                                , en_referencia_id    => gn_referencia_id
                                , ev_obj_referencia   => gv_obj_referencia
                                );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                   , est_log_generico_nf => est_log_generico_nf
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
      gv_mensagem_log := 'Erro na pk_csf_api_nfs.pkb_solic_calc_imp fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                             , ev_mensagem         => gv_cabec_log
                             , ev_resumo           => gv_mensagem_log
                             , en_tipo_log         => erro_de_sistema
                             , en_referencia_id    => gn_referencia_id
                             , ev_obj_referencia   => gv_obj_referencia );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                , est_log_generico_nf => est_log_generico_nf );
      exception
         when others then
            null;
      end;
      --
end pkb_solic_calc_imp;

-----------------------------------------------------------------------------------------------

--| Procedimento para processar uma Nota Fiscal de Serviço
-- o processo deverá cálcular os impostos e retenções e validar a informação

procedure pkb_processar ( en_notafiscal_id  in nota_fiscal.id%type )
is
   --
   vn_fase  number := 0;
   --
   vt_log_generico_nf           dbms_sql.number_table;
   --
   vn_dm_util_epropria          param_empr_calc_fiscal.dm_util_epropria%type;
   vn_dm_util_eterceiro         param_empr_calc_fiscal.dm_util_eterceiro%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_notafiscal_id,0) > 0 then
      --
	  --redmine #61161
	  UPDATE NOTA_FISCAL N SET N.DM_ST_PROC = 0 
       WHERE ID = EN_NOTAFISCAL_ID
         AND DM_ST_PROC IN ('5','10','18');
      COMMIT;
	  --
      pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL' );
      pkb_seta_referencia_id ( en_id => en_notafiscal_id );
      --
      vt_log_generico_nf.delete;
      --
      vn_fase := 2;
      -- recupera parâmetros da nota fiscal
      pkb_param_nfs ( en_notafiscal_id => en_notafiscal_id );
      --
      -- Não precisa, pois os passos abaixo são realizados na "pkb_consistem_nf"
      vn_fase := 2.1;
      --
      vn_dm_util_epropria := pk_csf_calc_fiscal.fkg_empr_util_epropria ( en_empresa_id => gn_empresa_id );
      vn_dm_util_eterceiro := pk_csf_calc_fiscal.fkg_empr_util_eterceiro ( en_empresa_id => gn_empresa_id );
      --
      vn_fase := 3;
      -- Desativado, substituido pela calculadora fiscal
      if nvl(gt_row_nat_oper_serv.id,0) > 0
         and ( ( gn_dm_ind_emit = 0 and nvl(vn_dm_util_epropria,0) = 0 ) -- Não, utiliza Calculadora Fiscal
               or ( gn_dm_ind_emit = 1 and nvl(vn_dm_util_eterceiro,0) = 0 ) )
         then
         --
         vn_fase := 3.1;
         -- procedimento para gerar impostos e retenções da nota fiscal
         pkb_gera_imposto_nfs ( en_notafiscal_id => en_notafiscal_id );
         --
      else
         --
         vn_fase := 3.2;
         -- Procedimento Solicita o Calculo dos Impostos
         pkb_solic_calc_imp ( est_log_generico_nf  => vt_log_generico_nf
                            , en_notafiscal_id     => en_notafiscal_id
                            );
         --
      end if;
      --
      vn_fase := 4;
      -- procedimento para gerar o total da nota fiscal
      pkb_gera_total_nfs ( en_notafiscal_id => en_notafiscal_id );
      --
      vn_fase := 5;
      -- procedimento para validar os dados
      pk_valida_ambiente_nfs.pkb_ler_nota_fiscal_serv ( en_notafiscal_id => en_notafiscal_id );
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_nfs.pkb_processar fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%type;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => null
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => erro_de_sistema
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_processar;

-------------------------------------------------------------------------------------------------------
-- Procedure que consiste os dados da Nota Fiscal

procedure pkb_consistem_nf ( est_log_generico_nf     in out nocopy  dbms_sql.number_table
                           , en_notafiscal_id     in             Nota_Fiscal.Id%TYPE )
is
   --
   vn_fase            number := 0;
   vn_loggenericonf_id  log_generico_nf.id%TYPE;
   vn_objintegr_id    obj_integr.id%type;
   vn_usuario_id      number;
   vv_maquina         varchar2(255);
   --
   vn_dm_util_epropria          param_empr_calc_fiscal.dm_util_epropria%type;
   vn_dm_util_eterceiro         param_empr_calc_fiscal.dm_util_eterceiro%type;
   --
begin
   --
   vn_fase := 1;
   gv_cabec_log := 'Validar as Notas Fiscais de Serviço. ';
   --
   -- recupera parâmetros da nota fiscal
   --
   pkb_param_nfs ( en_notafiscal_id => en_notafiscal_id );
   --
   vn_fase := 1.1;
   --
   vn_dm_util_epropria := pk_csf_calc_fiscal.fkg_empr_util_epropria ( en_empresa_id => gn_empresa_id );
   vn_dm_util_eterceiro := pk_csf_calc_fiscal.fkg_empr_util_eterceiro ( en_empresa_id => gn_empresa_id );
   --
   vn_fase := 1.2;
   --
   if nvl(gt_row_nat_oper_serv.id,0) > 0
      and ( ( gn_dm_ind_emit = 0 and nvl(vn_dm_util_epropria,0) = 0 ) -- Não, utiliza Calculadora Fiscal
            or ( gn_dm_ind_emit = 1 and nvl(vn_dm_util_eterceiro,0) = 0 ) )
      then
      --
      vn_fase := 1.22;
      -- procedimento para gerar impostos e retenções da nota fiscal
      pkb_gera_imposto_nfs ( en_notafiscal_id => en_notafiscal_id );
      --
   else
      --
      vn_fase := 1.21;
      -- Procedimento Solicita o Calculo dos Impostos
      pkb_solic_calc_imp ( est_log_generico_nf  => est_log_generico_nf
                         , en_notafiscal_id     => en_notafiscal_id
                         );
      --
   end if;
   --
   vn_fase := 2;
   -- procedimento para criar o registro de total da Nota Fiscal de Serviço
   pkb_gera_total_nfs ( en_notafiscal_id  => en_notafiscal_id );
   --
   vn_fase := 2.1;
   --
   -- Procedimento para gerar a Informações Complementares de Tributos --
   pkb_gerar_info_trib ( est_log_generico_nf => est_log_generico_nf
                       , en_notafiscal_id    => en_notafiscal_id );
   --
   vn_fase := 2.2;
   --
   --| Valida informações do item
   pkb_valida_item_nota_fiscal ( est_log_generico_nf     => est_log_generico_nf
                               , en_notafiscal_id     => en_notafiscal_id
                               );
   --
   vn_fase := 3;
   --
   --| Valida informações do destinatário
   pkb_valida_nota_fiscal_dest ( est_log_generico_nf     => est_log_generico_nf
                               , en_notafiscal_id     => en_notafiscal_id
                               );
   --
   -- #68193
/*   vn_fase := 4;
   --
   --| Validar CFOP por destinatário de NFServ de acordo com o parâmetro da empresa: empresa.dm_valida_cfop_por_dest = 0-não, 1-sim
   pkb_valida_cfop_por_dest ( est_log_generico_nf => est_log_generico_nf
                            , en_notafiscal_id    => en_notafiscal_id
                            );
   --
 */  vn_fase := 5;
   --
   pkb_valida_imposto_item ( est_log_generico_nf     => est_log_generico_nf
                           , en_notafiscal_id     => en_notafiscal_id
                           );
   --
   vn_fase := 6;
   -- Procedimento atualiza a informação da tabela NOTA_FISCAL_COBR
   pkb_atual_dados_cobr ( est_log_generico_nf     => est_log_generico_nf
                        , en_notafiscal_id     => en_notafiscal_id
                        );
   --
   vn_fase := 7;
   -- Procedimento Valida informações das Duplicadas
   pkb_vld_infor_dupl ( est_log_generico_nf     => est_log_generico_nf
                      , en_notafiscal_id     => en_notafiscal_id
                      );
   --
   vn_fase := 8;
   -- Procedimento Valida informações para emissão de XML de envio por RPS
   pkb_vld_xml_rps ( est_log_generico_nf => est_log_generico_nf
                   , en_notafiscal_id    => en_notafiscal_id
                   );
   --
   vn_fase := 9;
   --
   -- Chama as rotinas programaveis do tipo "Emissão Online"
   --
   if nvl(gt_row_nota_fiscal.dm_ind_emit,1) = 0 then
      --
      vn_fase := 10;
      -- Recupera o id do objeto de integração
      --
      begin
         select id
           into vn_objintegr_id
           from obj_integr
          where cd = '7'; -- Notas Fiscais de Serviços EFD
      exception
         when others then
         vn_objintegr_id := 0;
      end;
      --
      vn_fase := 11;
      -- Recupera o USUARIO_ID
      --
      if nvl(gt_row_nota_fiscal.usuario_id,0) > 0 then
         --
         vn_usuario_id := gt_row_nota_fiscal.usuario_id;
         --
      else
         --
         vn_usuario_id := pk_csf.fkg_usuario_id ( ev_login => 'admin' );
         --
      end if;
      --
      vn_fase := 12;
      --
      if nvl(vn_usuario_id,0) <= 0 then
         --
         begin
            --
            select min(id)
              into vn_usuario_id
              from neo_usuario;
            --
         exception
            when others then
               null;
         end;
         --
      end if;
      --
      vn_fase := 13;
      -- Recupera o nome da máquina
      --
      vv_maquina := sys_context('USERENV', 'HOST');
      --
      if vv_maquina is null then
         --
         vv_maquina := 'Servidor';
         --
      end if;
      --
      vn_fase := 14;
      -- Chama o procedimento de execução das rotinas programaveis do tipo "Emissão Online"
      pk_csf_rot_prog.pkb_exec_rot_prog_online ( en_id_doc          => en_notafiscal_id
                                               , ed_dt_ini          => trunc(gt_row_nota_fiscal.dt_emiss)
                                               , ed_dt_fin          => trunc(gt_row_nota_fiscal.dt_emiss)
                                               , ev_obj_referencia  => gv_obj_referencia
                                               , en_referencia_id   => en_notafiscal_id
                                               , en_usuario_id      => vn_usuario_id
                                               , ev_maquina         => vv_maquina
                                               , en_objintegr_id    => vn_objintegr_id
                                               , en_multorg_id      => pk_csf.fkg_multorg_id_empresa(en_empresa_id => pk_csf.fkg_busca_empresa_nf(en_notafiscal_id => en_notafiscal_id))
                                               , en_empresa_id      => pk_csf.fkg_busca_empresa_nf(en_notafiscal_id => en_notafiscal_id)
                                               );
      --
   end if;
   --
   vn_fase := 99;
   --| Define situação da nota fiscal
   if nvl(est_log_generico_nf.count,0) > 0
      and gv_obj_referencia = 'NOTA_FISCAL'
      then
      --
      if fkg_ver_erro_log_generico_nfs( en_nota_fiscal_id => en_notafiscal_id ) = 1 then
         update nota_fiscal
            set dm_st_proc = 10
          where id = en_notafiscal_id;
      end if;
      --
   end if;
   --
   vn_fase := 99.1;
   --
   if gv_obj_referencia = 'NOTA_FISCAL' then
      -- Se não contém erro de validação, Grava o Log de Nota Fiscal Integrada
      gv_mensagem_log := 'Nota Fiscal integrada';
      --
      if nvl(est_log_generico_nf.count,0) = 0 then
         --
         gv_mensagem_log := gv_mensagem_log||' e validada.';
         --
      end if;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => NOTA_FISCAL_INTEGRADA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia
                          );
      --
   end if;
   --
exception
   when others then
      --
      rollback;
      --
      gv_mensagem_log := 'Erro na pkb_consistem_nf fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem        => gv_cabec_log
                          , ev_resumo          => gv_mensagem_log
                          , en_tipo_log        => ERRO_DE_SISTEMA
                          , en_referencia_id   => gn_referencia_id
                          , ev_obj_referencia  => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_consistem_nf;

-------------------------------------------------------------------------------------------------------

--Procedimento que retorna os valores fiscais de um item de nota fiscal de serviço

procedure pkb_vlr_fiscal_item_nfs ( en_itemnf_id    in   item_nota_fiscal.id%type
                                  , sn_cfop         out  cfop.cd%type
                                  , sn_vl_operacao  out  number
                                  )
is
   --
   vn_fase                   number := 0;
   vn_cfop                   cfop.cd%type;
   vn_vl_total_item          nota_fiscal_total.vl_total_item%type;
   vn_vl_desconto            nota_fiscal_total.vl_desconto%type;
   vn_vl_base_calc_iss       nota_fiscal_total.vl_base_calc_iss%type;
   vn_vl_imp_trib_iss        nota_fiscal_total.vl_imp_trib_iss%type;
   vn_vl_imp_trib_pis        nota_fiscal_total.vl_imp_trib_pis%type;
   vn_vl_imp_trib_cofins     nota_fiscal_total.vl_imp_trib_cofins%type;
   vn_vl_ret_iss             nota_fiscal_total.vl_ret_iss%type;
   vn_vl_ret_pis             nota_fiscal_total.vl_ret_pis%type;
   vn_vl_ret_cofins          nota_fiscal_total.vl_ret_cofins%type;
   vn_vl_ret_csll            nota_fiscal_total.vl_ret_csll%type;
   vn_vl_base_calc_irrf      nota_fiscal_total.vl_base_calc_irrf%type;
   vn_vl_ret_irrf            nota_fiscal_total.vl_ret_irrf%type;
   vn_vl_base_calc_ret_prev  nota_fiscal_total.vl_base_calc_ret_prev%type;
   vn_vl_ret_prev            nota_fiscal_total.vl_ret_prev%type;
   vn_vl_total_nf            nota_fiscal_total.vl_total_nf%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_itemnf_id,0) > 0 then
      --
      vn_fase := 2;
      -- Soma valor do item e desconto
      begin
         --
         select inf.vl_item_bruto
              , inf.vl_desc
              , inf.cfop
           into vn_vl_total_item
              , vn_vl_desconto
              , vn_cfop
           from item_nota_fiscal   inf
              , nota_fiscal        nf
          where inf.id             = en_itemnf_id
            and inf.notafiscal_id  = nf.id;
           --
      exception
         when others then
            vn_vl_total_item := 0;
            vn_vl_desconto := 0;
            vn_cfop := 0;
      end;
      --
      vn_fase := 3;
      -- Soma valor do ISS
      begin
         --
         select sum(imp.vl_base_calc)
              , sum(imp.vl_imp_trib)
           into vn_vl_base_calc_iss
              , vn_vl_imp_trib_iss
           from imp_itemnf         imp
              , tipo_imposto       ti
          where imp.itemnf_id      = en_itemnf_id
            and imp.dm_tipo        = 0 -- Imposto
            and ti.id              = imp.tipoimp_id
            and ti.cd              = 6; -- ISS
           --
      exception
         when others then
            vn_vl_base_calc_iss := 0;
            vn_vl_imp_trib_iss := 0;
      end;
      --
      vn_fase := 4;
      -- Soma valor do PIS
      begin
         --
         select sum(imp.vl_imp_trib)
           into vn_vl_imp_trib_pis
           from imp_itemnf         imp
              , tipo_imposto       ti
          where imp.itemnf_id      = en_itemnf_id
            and imp.dm_tipo        = 0 -- Imposto
            and ti.id              = imp.tipoimp_id
            and ti.cd              = 4; -- PIS
         --
      exception
         when others then
            vn_vl_imp_trib_pis := 0;
      end;
      --
      vn_fase := 5;
      -- Soma valor do COFINS
      begin
         --
         select sum(imp.vl_imp_trib)
           into vn_vl_imp_trib_cofins
           from imp_itemnf         imp
              , tipo_imposto       ti
          where imp.itemnf_id      = en_itemnf_id
            and imp.dm_tipo        = 0 -- Imposto
            and ti.id              = imp.tipoimp_id
            and ti.cd              = 5; -- COFINS
         --
      exception
         when others then
            vn_vl_imp_trib_cofins := 0;
      end;
      --
      vn_fase := 6;
      -- Soma valor do ISS retido
      begin
         --
         select sum(imp.vl_imp_trib)
           into vn_vl_ret_iss
           from imp_itemnf         imp
              , tipo_imposto       ti
          where imp.itemnf_id      = en_itemnf_id
            and imp.dm_tipo        = 1 -- retenção
            and ti.id              = imp.tipoimp_id
            and ti.cd              = 6; -- ISS
            --
      exception
          when others then
             vn_vl_ret_iss := 0;
      end;
      --
      vn_fase := 7;
      -- Soma valor do PIS retido
      begin
         --
         select sum(imp.vl_imp_trib)
           into vn_vl_ret_pis
           from imp_itemnf         imp
              , tipo_imposto       ti
          where imp.itemnf_id      = en_itemnf_id
            and imp.dm_tipo        = 1 -- Retenção
            and ti.id              = imp.tipoimp_id
            and ti.cd              = 4; -- PIS
         --
      exception
         when others then
            vn_vl_ret_pis := 0;
      end;
      --
      vn_fase := 8;
      -- Soma valor do COFINS retido
      begin
         --
         select sum(imp.vl_imp_trib)
           into vn_vl_ret_cofins
           from imp_itemnf         imp
              , tipo_imposto       ti
          where imp.itemnf_id      = en_itemnf_id
            and imp.dm_tipo        = 1 -- Retenção
            and ti.id              = imp.tipoimp_id
            and ti.cd              = 5; -- COFINS
         --
      exception
         when others then
            vn_vl_ret_cofins := 0;
      end;
      --
      vn_fase := 9;
      -- Soma valor do CSLL retido
      begin
         --
         select sum(imp.vl_imp_trib)
           into vn_vl_ret_csll
           from imp_itemnf         imp
              , tipo_imposto       ti
          where imp.itemnf_id      = en_itemnf_id
            and imp.dm_tipo        = 1 -- Retenção
            and ti.id              = imp.tipoimp_id
            and ti.cd              = 11; -- CSLL
         --
      exception
         when others then
            vn_vl_ret_csll := 0;
      end;
      --
      vn_fase := 10;
      -- Soma valor do IRRF retido
      begin
         --
         select sum(imp.vl_base_calc)
              , sum(imp.vl_imp_trib)
           into vn_vl_base_calc_irrf
              , vn_vl_ret_irrf
           from imp_itemnf         imp
              , tipo_imposto       ti
          where imp.itemnf_id      = en_itemnf_id
            and imp.dm_tipo        = 1 -- Retenção
            and ti.id              = imp.tipoimp_id
            and ti.cd              = 12; -- IRRF
         --
      exception
         when others then
            vn_vl_ret_irrf := 0;
      end;
      --
      vn_fase := 11;
      -- Soma valor do INSS retido
      begin
         --
         select sum(imp.vl_base_calc)
              , sum(imp.vl_imp_trib)
           into vn_vl_base_calc_ret_prev
              , vn_vl_ret_prev
           from imp_itemnf         imp
              , tipo_imposto       ti
          where imp.itemnf_id      = en_itemnf_id
            and imp.dm_tipo        = 1 -- Retenção
            and ti.id              = imp.tipoimp_id
            and ti.cd              = 13; -- INSS
         --
      exception
         when others then
            vn_vl_base_calc_ret_prev := 0;
            vn_vl_ret_prev := 0;
      end;
      --
      vn_fase := 12;
      -- total da nota fiscal
      vn_vl_total_nf := nvl(vn_vl_total_item,0)
                        - nvl(vn_vl_desconto,0)
                        - nvl(vn_vl_ret_iss,0)
                        - nvl(vn_vl_ret_pis,0)
                        - nvl(vn_vl_ret_cofins,0)
                        - nvl(vn_vl_ret_csll,0)
                        - nvl(vn_vl_ret_irrf,0)
                        - nvl(vn_vl_ret_prev,0);
   --
   end if;
   --
   sn_vl_operacao := nvl(vn_vl_total_nf,0);
   sn_cfop        := nvl(vn_cfop,0);
   --
end pkb_vlr_fiscal_item_nfs;

-------------------------------------------------------------------------------------------------------

--Procedimento que retorna os valores fiscais de um item de nota fiscal de serviço SOMENTE para o declan-rj
-- que deve retornar o valor total sem descontos.

procedure pkb_vlr_fiscal_item_nfs_declan ( en_itemnf_id    in   item_nota_fiscal.id%type
                                         , sn_cfop         out  cfop.cd%type
                                         , sn_vl_operacao  out  number
                                          )
is
   --
   vn_fase                   number := 0;
   vn_cfop                   cfop.cd%type;
   vn_vl_total_item          nota_fiscal_total.vl_total_item%type;   
   vn_vl_total_nf            nota_fiscal_total.vl_total_nf%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_itemnf_id,0) > 0 then
      --
      vn_fase := 2;
      -- Soma valor do item e desconto
      begin
         --
         select inf.vl_item_bruto
              , inf.cfop
           into vn_vl_total_item
              , vn_cfop
           from item_nota_fiscal   inf
              , nota_fiscal        nf
          where inf.id             = en_itemnf_id
            and inf.notafiscal_id  = nf.id;
           --
      exception
         when others then
            vn_vl_total_item := 0;
            vn_cfop := 0;
      end;
      --
      vn_fase := 3;
      --
      -- total da nota fiscal
      vn_vl_total_nf := nvl(vn_vl_total_item,0);
      --              
   --
   end if;
   --
   sn_vl_operacao := nvl(vn_vl_total_nf,0);
   sn_cfop        := nvl(vn_cfop,0);
   --
end pkb_vlr_fiscal_item_nfs_declan;

-------------------------------------------------------------------------------------------------------

procedure pkb_ret_multorg_id( est_log_generico       in out nocopy  dbms_sql.number_table
                            , ev_cod_mult_org        in             mult_org.cd%type
                            , ev_hash_mult_org       in             mult_org.hash%type
                            , sn_multorg_id          in out nocopy  mult_org.id%type
                            , ev_obj_referencia      in             log_generico_nf.obj_referencia%type
                            , en_referencia_id       in             log_generico_nf.referencia_id%type
                            )
is
   vn_fase               number := 0;
   vv_multorg_hash       mult_org.hash%type;
   vn_multorg_id         mult_org.id%type;
   vn_loggenericonf_id  Log_Generico_nf.id%type;
   vn_dm_obrig_integr    mult_org.dm_obrig_integr%type;

begin
   --
   vn_fase := 1;
   --
   gn_referencia_id   := en_referencia_id;
   gv_obj_referencia  := ev_obj_referencia;
   --
   begin
      --
      select mo.hash, mo.id, mo.dm_obrig_integr
        into vv_multorg_hash, vn_multorg_id, vn_dm_obrig_integr
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
         vn_loggenericonf_id := null;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_cabec_log
                              , en_tipo_log           => ERRO_DE_VALIDACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                 , est_log_generico_nf  => est_log_generico );
   --
   end;
   --
   vn_fase := 5;
   --
   if nvl(vn_multorg_id, 0) = 0 then

      gv_mensagem_log := 'O Mult Org de codigo: |' || ev_cod_mult_org || '| não existe.';
      --
      vn_loggenericonf_id := null;
      --
      vn_fase := 5.1;
      --
      if vn_dm_obrig_integr = 0 then -- Não validar o multorg.
         --
         vn_fase := 5.2;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => INFORMACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              );
         --
      elsif vn_dm_obrig_integr = 1 then -- Validar o multorg.
         --
         vn_fase := 5.3;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_VALIDACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                 , est_log_generico_nf  => est_log_generico );
         --
      end if;
      --
   elsif vv_multorg_hash != ev_hash_mult_org then
      --
      vn_fase := 6;
      --
      gv_mensagem_log := 'O valor do Hash ('|| ev_hash_mult_org ||') do Mult Org:'|| ev_cod_mult_org ||'esta incorreto.';
      --
      vn_loggenericonf_id := null;
      --
      if vn_dm_obrig_integr = 0 then -- Não validar o multorg.
         --
         vn_fase := 5.2;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => INFORMACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              );
         --
      elsif vn_dm_obrig_integr = 1 then -- Validar o multorg.
         --
         vn_fase := 5.3;
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                              , ev_mensagem           => gv_mensagem_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_VALIDACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia
                              );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                 , est_log_generico_nf  => est_log_generico );
         --
      end if;
      --
   end if;
   --
   vn_fase := 7;
   --
   sn_multorg_id := vn_multorg_id;

exception
   when others then
      raise_application_error (-20101, 'Problemas ao validar Mult Org - pk_csf_api_nfs.pkb_ret_multorg_id. Fase: '||vn_fase||' Erro = '||sqlerrm);
end pkb_ret_multorg_id;

-------------------------------------------------------------------------------------------------------

-- Procedimento valida o mult org de acordo com o COD e o HASH das tabelas Flex-Field

procedure pkb_val_atrib_multorg ( est_log_generico   in out nocopy  dbms_sql.number_table
                                , ev_obj_name        in             VARCHAR2
                                , ev_atributo        in             VARCHAR2
                                , ev_valor           in             VARCHAR2
                                , sv_cod_mult_org    out            VARCHAR2
                                , sv_hash_mult_org   out            VARCHAR2
                                , ev_obj_referencia  in             log_generico_nf.obj_referencia%type
                                , en_referencia_id   in             log_generico_nf.referencia_id%type
                                )


is
   --
   vn_fase                number := 0;
   vn_loggenericonf_id   log_generico_nf.id%type;
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
   gn_referencia_id   := en_referencia_id;
   gv_obj_referencia  := ev_obj_referencia;
   --
   vn_fase := 2;
   --
   if trim(ev_valor) is null then
      --
      vn_fase := 3;
      --
      gv_mensagem_log := 'Código ou HASH da Mult-Organização (objeto: '|| ev_obj_name ||'): "VALOR" referente ao atributo deve ser informado.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                           , ev_mensagem        => gv_mensagem_log
                           , ev_resumo          => gv_cabec_log
                           , en_tipo_log        => ERRO_DE_VALIDACAO
                           , en_referencia_id   => gn_referencia_id
                           , ev_obj_referencia  => gv_obj_referencia );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                              , est_log_generico_nf  => est_log_generico );
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
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                           , ev_mensagem        => gv_mensagem_log
                           , ev_resumo          => gv_cabec_log
                           , en_tipo_log        => ERRO_DE_VALIDACAO
                           , en_referencia_id   => gn_referencia_id
                           , ev_obj_referencia  => gv_obj_referencia );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                              , est_log_generico_nf  => est_log_generico );
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
            vn_loggenericonf_id := null;
            --
            pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                , ev_mensagem       => gv_mensagem_log
                                , ev_resumo         => gv_cabec_log
                                , en_tipo_log       => ERRO_DE_VALIDACAO
                                , en_referencia_id  => gn_referencia_id
                                , ev_obj_referencia => gv_obj_referencia );
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                   , est_log_generico_nf => est_log_generico );
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
      gv_mensagem_log := 'Erro na pk_csf_api_nfs.pkb_val_atrib_multorg fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico.id%type;
      begin
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                              , ev_mensagem        => gv_mensagem_log
                              , ev_resumo          => gv_cabec_log
                              , en_tipo_log        => erro_de_validacao
                              , en_referencia_id   => gn_referencia_id
                              , ev_obj_referencia  => gv_obj_referencia );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                                 , est_log_generico_nf  => est_log_generico );
      exception
         when others then
            null;
      end;
end pkb_val_atrib_multorg;

-----------------------------------------------------------------------------------------------------

-- Processo que valida e integra nota fiscal de cancelamento, a partir do atributo ID_ERP
procedure pkb_val_integr_nf_canc_ff ( est_log_generico_nf  in out nocopy dbms_sql.number_table
                                    , en_notafiscalcanc_id in number
                                    , ev_atributo          in varchar2
                                    , ev_valor             in varchar2
                                    )
is
   --
   vn_fase number;
   vn_loggenericonf_id     log_generico_nf.id%type;
   vn_dmtipocampo          ff_obj_util_integr.dm_tipo_campo%type;
   vv_mensagem             varchar2(1000) := null;
   vn_qtde_nf              number := 0;
   vn_id_erp               number;
   --
begin
   --
   vn_fase := 1;
   --
   gn_referencia_id  := en_notafiscalcanc_id;
   gv_obj_referencia := 'NOTA_FISCAL_CANC';
   --
   if ev_atributo is null then
      --
      vn_fase := 2;
      --
      gv_mensagem_log := 'Nota Fiscal de Cancelamento: "Atributo" deve ser informado.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_mensagem_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => erro_de_validacao
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 3;
   --
   if ev_valor is null then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := 'Nota Fiscal de Cancelamento: "VALOR" referente ao atributo deve ser informado.';
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_mensagem_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => erro_de_validacao
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 4;
   --
   vv_mensagem := pk_csf.fkg_ff_verif_campos ( ev_obj_name => 'VW_CSF_NF_CANC_SERV_FF'
                                             , ev_atributo => ev_atributo
                                             , ev_valor    => ev_valor
                                             );
   --
   if vv_mensagem is not null then
      --
      vn_fase := 4.2;
      --
      gv_mensagem_log := vv_mensagem;
      --
      vn_loggenericonf_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                          , ev_mensagem          => gv_mensagem_log
                          , ev_resumo            => gv_mensagem_log
                          , en_tipo_log          => erro_de_validacao
                          , en_referencia_id     => gn_referencia_id
                          , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                             , est_log_generico_nf  => est_log_generico_nf );
      --
   else
      --
      vn_fase := 5;
      --
      vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo( ev_obj_name => 'VW_CSF_NF_CANC_SERV_FF'
                                                         , ev_atributo => ev_atributo );
      --
      if ev_atributo = 'ID_ERP' then
         --
         if trim(ev_valor) is not null then
            --
            vn_fase := 6;
            --
            if vn_dmtipocampo = 1 then -- tipo de campo = numérico
               --
               vn_fase := 7;
               --
               if pk_csf.fkg_is_numerico( trim(ev_valor) ) then
                 --
                 vn_fase := 8;
                 --
                 vn_id_erp := pk_csf.fkg_ff_ret_vlr_number ( ev_obj_name => 'VW_CSF_NF_CANC_SERV_FF'
                                                           , ev_atributo => trim(ev_atributo)
                                                           , ev_valor    => trim(ev_valor)
                                                           );
                 --
               else
                   --
                   vn_fase := 9;
                   --
                   gv_mensagem_log := 'O valor do campo "ID ERP" informado ('||ev_valor||') não é válido, deve conter apenas valores numéricos.';
                   --
                   vn_loggenericonf_id := null;
                   --
                   pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                       , ev_mensagem       => gv_cabec_log
                                       , ev_resumo         => gv_mensagem_log
                                       , en_tipo_log       => erro_de_validacao
                                       , en_referencia_id  => gn_referencia_id
                                       , ev_obj_referencia => gv_obj_referencia );
                   -- Armazena o "loggenerico_id" na memória
                   pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                       , est_log_generico_nf => est_log_generico_nf );
                   --
               end if;
               --
            else
               --
               vn_fase := 10;
               --
               gv_mensagem_log := 'O valor do campo "ID ERP" informado não confere com o tipo de campo, deveria ser NUMÉRICO.';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                   , ev_mensagem       => gv_cabec_log
                                   , ev_resumo         => gv_mensagem_log
                                   , en_tipo_log       => erro_de_validacao
                                   , en_referencia_id  => gn_referencia_id
                                   , ev_obj_referencia => gv_obj_referencia );
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                   , est_log_generico_nf => est_log_generico_nf );
               --
            end if;
            --
         end if;
         --
      end if;
      --
      if nvl(est_log_generico_nf.count, 0) = 0
        and nvl(en_notafiscalcanc_id, 0) > 0 and ev_atributo = 'ID_ERP' and vv_mensagem is null then
         --
         begin
            --
            select count(1)
              into vn_qtde_nf
              from nota_fiscal_canc
             where id = en_notafiscalcanc_id;
            --
         exception
            when others then
               --
               vn_qtde_nf := 0;
               --
         end;
         --
         if nvl(vn_qtde_nf, 0) > 0 then
            --
            update nota_fiscal_canc nfc
               set nfc.id_erp = vn_id_erp
             where nfc.id = en_notafiscalcanc_id;
            --
         end if;
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
      gv_mensagem_log := 'Erro na pk_csf_api_nfs.pkb_val_integr_nf_canc_ff fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         --
         pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                             , ev_mensagem          => gv_mensagem_log
                             , ev_resumo            => gv_mensagem_log
                             , en_tipo_log          => ERRO_DE_SISTEMA
                             , en_referencia_id     => gn_referencia_id
                             , ev_obj_referencia    => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                                , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_val_integr_nf_canc_ff;
--
-----------------------------------------------------------------------------------------------------
end pk_csf_api_nfs;
/
