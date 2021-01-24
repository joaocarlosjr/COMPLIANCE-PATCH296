create or replace package body csf_own.pk_int_view_bloco_m_pc is

-----------------------------------------
--| Função para montagem de comando FROM
-----------------------------------------
function fkg_monta_from ( ev_obj in varchar2 )
         return varchar2 is
   --
   vv_from  varchar2(4000) := null;
   vv_obj   varchar2(4000) := null;
   --
begin
   --
   vv_obj := ev_obj;
   --
   if GV_NOME_DBLINK is not null then
      --
      vv_from := vv_from || trim(GV_ASPAS) || vv_obj || trim(GV_ASPAS) || '@' || GV_NOME_DBLINK;
      --
   else
      --
      vv_from := vv_from || trim(GV_ASPAS) || vv_obj || trim(GV_ASPAS);
      --
   end if;
   --
   if trim(GV_OWNER_OBJ) is not null then
      vv_from := trim(GV_OWNER_OBJ) || '.' || vv_from;
   end if;
   --
   vv_from := ' from ' || vv_from;
   --
   return vv_from;
   --
end fkg_monta_from;
----------------------------------------------------------------------------------
--| Procedimento seta o objeto de referencia utilizado na Validação da Informação
----------------------------------------------------------------------------------
procedure pkb_seta_obj_ref ( ev_objeto in varchar2
                           ) is
begin
   --
   gv_obj_referencia := upper(ev_objeto);
   --
end pkb_seta_obj_ref;
----------------------------------------------------------------------------------------------------
--| Procedimento seta o "ID de Referencia" utilizado na Validação da Informação
----------------------------------------------------------------------------------------------------
procedure pkb_seta_referencia_id ( en_id in number
                                 ) is
begin
   --
   gn_referencia_id := en_id;
   --
end pkb_seta_referencia_id;
----------------------------------------------------------------------------------------------------
--| Procedimento de registro de log de erros na validação do IBMPC
----------------------------------------------------------------------------------------------------
procedure pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id     out nocopy Log_Generico_ibmpc.id%TYPE
                                 , ev_mensagem                in         Log_Generico_ibmpc.mensagem%TYPE
                                 , ev_resumo                  in         Log_Generico_ibmpc.resumo%TYPE
                                 , en_tipo_log                in         csf_tipo_log.cd_compat%type            default 1
                                 , en_referencia_id           in         Log_Generico_ibmpc.referencia_id%TYPE  default null
                                 , ev_obj_referencia          in         Log_Generico_ibmpc.obj_referencia%TYPE default null
                                 , en_empresa_id              in         Empresa.Id%type                        default null
                                 , en_dm_impressa             in         Log_Generico_ibmpc.dm_impressa%type    default 0
                                 ) is
   --
   vn_fase          number := 0;
   vn_csftipolog_id csf_tipo_log.id%type := null;
   pragma           autonomous_transaction;
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
      select loggenericoibmpc_seq.nextval
        into sn_loggenericoibmpc_id
        from dual;
      --
      vn_fase := 4;
      --
      insert into Log_Generico_ibmpc ( id
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
                                     ( sn_loggenericoibmpc_id     -- Valor de cada log de validação
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
      gv_resumo := 'Erro na pkb_log_generico_ibmpc fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  LOG_GENERICO_IBMPC.id%TYPE;
      begin
         --
         pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id  => vn_loggenerico_id
                                , ev_mensagem             => gv_cabec_log
                                , ev_resumo               => gv_mensagem_log
                                , en_tipo_log             => ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_log_generico_ibmpc;

----------------------------------------------------------------------------------------------------
--| Procedimento armazena o valor do "loggenerico_id"
----------------------------------------------------------------------------------------------------
procedure pkb_gt_log_generico_ibmpc ( en_loggenericoibmpc_id  in             Log_generico_ibmpc.id%TYPE
                                    , est_log_generico_ibmpc  in out nocopy  dbms_sql.number_table
                                    ) is
   --
   i pls_integer;
   --
begin
   --
   if nvl(en_loggenericoibmpc_id,0) > 0 then
      --
      i := nvl(est_log_generico_ibmpc.count,0) + 1;
      --
      est_log_generico_ibmpc(i) := en_loggenericoibmpc_id;
      --
   end if;
   --
exception
   when others then
      --
      gv_resumo := 'Erro na pk_int_view_bloco_m_pc.pkb_gt_log_generico_ibmpc: '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico_ibmpc.id%TYPE;
      begin
         --
         pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id  => vn_loggenerico_id
                                , ev_mensagem             => gv_cabec_log
                                , ev_resumo               => gv_mensagem_log
                                , en_tipo_log             => ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_gt_log_generico_ibmpc;
----------------------------------------------------------------------------------
-- Procedimento que limpa a tabela Log_Generico_ibmpc
----------------------------------------------------------------------------------
procedure pkb_limpar_loggenericoibmpc is
   --
begin
   --
   delete from Log_Generico_ibmpc;
   --
   commit;
   --
exception
   when others then
      --
      gv_resumo := 'Erro na pkb_limpar_loggenericoibmpc:'||sqlerrm;
      --
      declare
         vn_loggenerico_id   Log_Generico_ibmpc.id%type;
      begin
      --
         pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id  => vn_loggenerico_id
                                , ev_mensagem             => 'Limpar tabela de logs genéricos - Bloco M'
                                , ev_resumo               => gv_resumo
                                , en_tipo_log             => ERRO_DE_SISTEMA
                                );
      exception
         when others then
           null;
      end;
end pkb_limpar_loggenericoibmpc;

-------------------------------------------------------------------------------------------------------
--| Função retorna o ID da tabela DET_CONS_CONTR_PIS (M210)
-------------------------------------------------------------------------------------------------------
function fkg_detconscontrpis_id (en_id_empresa in number,
                                 ed_dt_ini     in date,
                                 ed_dt_fin     in date,
                                 ev_cd_apur_pc in varchar2)
  return number is
  --
  vn_detconscontrpis_id inf_adic_dif_pis.detconscontrpis_id%type;
begin  
---
select d.id as detconscontrpis_id 
  into vn_detconscontrpis_id
from PER_CONS_CONTR_PIS p,
     CONS_CONTR_PIS c,
     DET_CONS_CONTR_PIS d
where p.id          = c.perconscontrpis_id 
  and c.id          = d.conscontrpis_id 
  and p.empresa_id  = en_id_empresa
  and p.dt_ini between to_Date(ed_dt_ini, gv_formato_data) and to_Date(ed_dt_fin, gv_formato_data)
  and p.dt_fin between to_Date(ed_dt_ini, gv_formato_data) and to_Date(ed_dt_fin, gv_formato_data)
  and d.contrsocapurpc_id = (select id from CONTR_SOC_APUR_PC where cd = ev_cd_apur_pc)
  and rownum = 1; 
---
return vn_detconscontrpis_id;
---
exception
  when others then 
     ----
     gv_resumo        := 'Erro na pk_int_view_bloco_m_pc.fkg_detconscontrpis_id fase: '||sqlerrm; 
     ----
    declare
       vn_loggenerico_id  log_generico_ibmpc.id%TYPE;
    begin
       --
       pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id  => vn_loggenerico_id
                              , ev_mensagem             => gv_mensagem_log
                              , ev_resumo               => gv_resumo
                              , en_tipo_log             => ERRO_DE_SISTEMA
                              , en_referencia_id        => gn_referencia_id
                              , ev_obj_referencia       => gv_obj_referencia
                              , en_empresa_id           => gn_empresa_id
                              , en_dm_impressa          => 0    
                              );
       --
    exception
       when others then
          null;
    end;
    ----
    return 0;
    ----
end fkg_detconscontrpis_id;

-------------------------------------------------------------------------------------------------------
--| Função retorna o ID da tabela DET_CONS_CONTR_COFINS (M610)
-------------------------------------------------------------------------------------------------------
function fkg_detconscontrcofins_id (en_id_empresa in number,
                                    ed_dt_ini     in date,
                                    ed_dt_fin     in date,
                                    ev_cd_apur_pc in varchar2)
  return number is
  --
  vn_detconscontrcofins_id inf_adic_dif_cofins.detconscontrcofins_id%type;
begin  
---
select d.id as detconscontrcofins_id 
  into vn_detconscontrcofins_id
from PER_CONS_CONTR_COFINS p,
     CONS_CONTR_COFINS c,
     DET_CONS_CONTR_COFINS d
where p.id          = c.perconscontrcofins_id 
  and c.id          = d.conscontrcofins_id 
  and p.empresa_id  = en_id_empresa
  and p.dt_ini between to_Date(ed_dt_ini, gv_formato_data) and to_Date(ed_dt_fin, gv_formato_data)
  and p.dt_fin between to_Date(ed_dt_ini, gv_formato_data) and to_Date(ed_dt_fin, gv_formato_data)
  and d.contrsocapurpc_id = (select id from CONTR_SOC_APUR_PC where cd = ev_cd_apur_pc)
  and rownum = 1; 
---
return vn_detconscontrcofins_id;
---
exception
  when others then 
     ----
     gv_resumo       := 'Erro na pk_int_view_bloco_m_pc.fkg_detconscontrcofins_id fase: '||sqlerrm; 
     ----
    declare
       vn_loggenerico_id  log_generico_ibmpc.id%TYPE;
    begin
       --
       pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id  => vn_loggenerico_id
                              , ev_mensagem             => gv_mensagem_log
                              , ev_resumo               => gv_resumo
                              , en_tipo_log             => ERRO_DE_SISTEMA
                              , en_referencia_id        => gn_referencia_id
                              , ev_obj_referencia       => gv_obj_referencia
                              , en_empresa_id           => gn_empresa_id
                              , en_dm_impressa          => 0    
                              );
       --
    exception
       when others then
          null;
    end;
    ----
    return 0;
    ----
end fkg_detconscontrcofins_id;
----------------------------------------------------------------------------------
-- Procedimento para retorno de ID e STATUS da tabela CONS_CONTR_PIS
----------------------------------------------------------------------------------
procedure prc_conscontrpis_id_status (en_id          in   det_cons_contr_pis.id%type
                                     ,sn_ccp_id      out  cons_contr_pis.id%type    
                                     ,sn_ccp_dm_sit  out  cons_contr_pis.dm_situacao%type)
  is
  vn_ccp_id        cons_contr_pis.id%type ;
  vn_ccp_dm_sit    cons_contr_pis.dm_situacao%type;
begin
  --
  begin
    ---
    select c.id     , c.dm_situacao
      into vn_ccp_id,vn_ccp_dm_sit
    from CONS_CONTR_PIS c , DET_CONS_CONTR_PIS d
    where c.id = d.conscontrpis_id 
      and d.id = en_id;
    ---
  exception
    when others then
      vn_ccp_id:=null;
      vn_ccp_dm_sit :=null;
  end;
  --
  sn_ccp_id     := vn_ccp_id;
  sn_ccp_dm_sit := vn_ccp_dm_sit;
  --
end;
----------------------------------------------------------------------------------
-- Procedimento para retorno de ID e STATUS da tabela CONS_CONTR_COFINS
----------------------------------------------------------------------------------
procedure prc_conscontrcofins_id_status (en_id          in   det_cons_contr_cofins.id%type
                                        ,sn_ccc_id      out  cons_contr_cofins.id%type    
                                        ,sn_ccc_dm_sit  out  cons_contr_cofins.dm_situacao%type)
  is
  vn_ccc_id        cons_contr_cofins.id%type ;
  vn_ccc_dm_sit    cons_contr_cofins.dm_situacao%type;
begin
  --
  begin
    ---
    select c.id     , c.dm_situacao
      into vn_ccc_id,vn_ccc_dm_sit
    from CONS_CONTR_COFINS c , DET_CONS_CONTR_COFINS d
    where c.id = d.conscontrcofins_id  
      and d.id = en_id;
    ---
  exception
    when others then
      vn_ccc_id:=null;
      vn_ccc_dm_sit :=null;
  end;
  --
  sn_ccc_id      := vn_ccc_id;
  sn_ccc_dm_sit  := vn_ccc_dm_sit;
  --
end;
----------------------------------------------------------------------------------------------------
--| Procedimento de integração da Tabela INF_ADIC_DIF_PIS
----------------------------------------------------------------------------------------------------
procedure prc_integr_inf_adic_dif_pis  is
-----
vn_infadicdifpis_id inf_adic_dif_pis.id%type;
vn_fase             number := 0; 
-----
begin
---
vn_fase:=1;
---
vn_infadicdifpis_id:=null;
begin
  select p.id
  into vn_infadicdifpis_id
  from inf_adic_dif_pis p
  where p.detconscontrpis_id   = gt_row_inf_adic_dif_pis.detconscontrpis_id
  and   p.cnpj                 = gt_row_inf_adic_dif_pis.cnpj
  and   nvl(p.tipocredpc_id,0) = nvl(gt_row_inf_adic_dif_pis.tipocredpc_id,0);
exception
  when others then
    vn_infadicdifpis_id:=null;
end;
---
vn_fase:=2;
---
if vn_infadicdifpis_id is null then 
    ----
    vn_fase:=2.1;    
    select  infadicdifpis_seq.nextval into vn_infadicdifpis_id from dual;
    gt_row_inf_adic_dif_pis.id := vn_infadicdifpis_id;
    --| Seta o ID de referencia
    pkb_seta_referencia_id ( en_id => gt_row_inf_adic_dif_pis.id); 
    ----
    vn_fase:=2.2; 
    insert into inf_adic_dif_pis(
    id,
    detconscontrpis_id,
    cnpj,
    vl_vend,
    vl_nao_receb,
    vl_cont_dif,
    vl_cred_dif,
    tipocredpc_id) values (
    gt_row_inf_adic_dif_pis.id,
    gt_row_inf_adic_dif_pis.detconscontrpis_id,
    gt_row_inf_adic_dif_pis.cnpj,
    gt_row_inf_adic_dif_pis.vl_vend,
    gt_row_inf_adic_dif_pis.vl_nao_receb,
    gt_row_inf_adic_dif_pis.vl_cont_dif,
    gt_row_inf_adic_dif_pis.vl_cred_dif,
    gt_row_inf_adic_dif_pis.tipocredpc_id);
    ----
else
    ----
    vn_fase:=2.3;
    --| Seta o ID de referencia
    pkb_seta_referencia_id ( en_id => gt_row_inf_adic_dif_pis.id);
    ---- 
    update inf_adic_dif_pis set     
           vl_vend      = gt_row_inf_adic_dif_pis.vl_vend ,
           vl_nao_receb = gt_row_inf_adic_dif_pis.vl_nao_receb,
           vl_cont_dif  = gt_row_inf_adic_dif_pis.vl_cont_dif,
           vl_cred_dif  = gt_row_inf_adic_dif_pis.vl_cred_dif
    where id = gt_row_inf_adic_dif_pis.id;
    ----
end if;
---
commit;
---
begin
 pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj),0) + 1;
exception
 when others then
 null;
end;
---
exception
  when others then
  -- 
  begin
    pk_agend_integr.gvtn_qtd_erro(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erro(gv_cd_obj),0) + 1;
  exception
    when others then
    null;
  end;
  --
  gv_resumo := 'Erro na pk_int_view_bloco_m_pc.prc_integr_inf_adic_dif_pis fase ('||vn_fase||'): '||sqlerrm;     
  --
  declare
     vn_loggenerico_id  log_generico_ibmpc.id%TYPE;
  begin
     --
     pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id  => vn_loggenerico_id
                            , ev_mensagem             => gv_mensagem_log
                            , ev_resumo               => gv_resumo
                            , en_tipo_log             => ERRO_DE_SISTEMA
                            , en_referencia_id        => gn_referencia_id
                            , ev_obj_referencia       => gv_obj_referencia
                            , en_empresa_id           => gn_empresa_id
                            , en_dm_impressa          => 0    
                            );
     --
  exception
     when others then
        null;
  end;
  --
end prc_integr_inf_adic_dif_pis;

----------------------------------------------------------------------------------------------------
--| Procedimento de integração da Tabela INF_ADIC_DIF_COFINS
----------------------------------------------------------------------------------------------------
procedure prc_integr_inf_adic_dif_cofins  is
-----
vn_infadicdifcofins_id inf_adic_dif_cofins.id%type;
vn_fase             number := 0; 
-----
begin
---
vn_fase:=1;
---
vn_infadicdifcofins_id:=null;
begin
  select c.id
  into vn_infadicdifcofins_id
  from inf_adic_dif_cofins c
  where c.detconscontrcofins_id = gt_row_inf_adic_dif_cofins.detconscontrcofins_id
  and   c.cnpj                  = gt_row_inf_adic_dif_cofins.cnpj
  and   nvl(c.tipocredpc_id,0)  = nvl(gt_row_inf_adic_dif_cofins.tipocredpc_id,0);
exception
  when others then
    vn_infadicdifcofins_id:=null;
end;
---
vn_fase:=2;
---
if vn_infadicdifcofins_id is null then 
    ----
    vn_fase:=2.1;    
    select  infadicdifcofins_seq.nextval into vn_infadicdifcofins_id from dual;
    gt_row_inf_adic_dif_cofins.id := vn_infadicdifcofins_id;  
    ----
    vn_fase:=2.2; 
    insert into inf_adic_dif_cofins(
    id,
    detconscontrcofins_id,
    cnpj,
    vl_vend,
    vl_nao_receb,
    vl_cont_dif,
    vl_cred_dif,
    tipocredpc_id) values (
    gt_row_inf_adic_dif_cofins.id,
    gt_row_inf_adic_dif_cofins.detconscontrcofins_id,
    gt_row_inf_adic_dif_cofins.cnpj,
    gt_row_inf_adic_dif_cofins.vl_vend,
    gt_row_inf_adic_dif_cofins.vl_nao_receb,
    gt_row_inf_adic_dif_cofins.vl_cont_dif,
    gt_row_inf_adic_dif_cofins.vl_cred_dif,
    gt_row_inf_adic_dif_cofins.tipocredpc_id);
    ----
else
    ----
    vn_fase:=2.3;
    update inf_adic_dif_cofins set     
           vl_vend      = gt_row_inf_adic_dif_cofins.vl_vend,
           vl_nao_receb = gt_row_inf_adic_dif_cofins.vl_nao_receb,
           vl_cont_dif  = gt_row_inf_adic_dif_cofins.vl_cont_dif,
           vl_cred_dif  = gt_row_inf_adic_dif_cofins.vl_cred_dif
    where id = gt_row_inf_adic_dif_cofins.id;
    ----
end if;
---
commit;
---
begin
 pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj),0) + 1;
exception
 when others then
 null;
end;
---
exception
  when others then
  --
  begin
    pk_agend_integr.gvtn_qtd_erro(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erro(gv_cd_obj),0) + 1;
  exception
    when others then
    null;
  end;
  --
  gv_resumo := 'Erro na pk_int_view_bloco_m_pc.prc_integr_inf_adic_dif_cofins fase ('||vn_fase||'): '||sqlerrm;     
  --
  declare
     vn_loggenerico_id  log_generico_ibmpc.id%TYPE;
  begin
     --     
     pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id  => vn_loggenerico_id
                            , ev_mensagem             => gv_mensagem_log 
                            , ev_resumo               => gv_resumo
                            , en_tipo_log             => ERRO_DE_SISTEMA
                            , en_referencia_id        => gn_referencia_id
                            , ev_obj_referencia       => gv_obj_referencia
                            , en_empresa_id           => gn_empresa_id
                            , en_dm_impressa          => 0    
                            );
     --
  exception
     when others then
        null;
  end;
  --
end prc_integr_inf_adic_dif_cofins;
----------------------------------------------------------------------------------------------------
--| Processo para Calcular e Validar o registro M200 (via PK_APUR_PIS)
----------------------------------------------------------------------------------------------------
procedure pkb_calc_val_m200
is
   --
   vn_fase     number := 0;
   i           pls_integer;
   vn_pis_id   cons_contr_pis.id%type;       
   --
begin
   --
   vn_fase := 1;
   --
   /*Serão utilizados os ids da tabela CONS_CONTR_PIS que foram desprocessados*/
   if nvl(vt_tab_pis_m200.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_pis_m200.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         vn_pis_id:= vt_tab_pis_m200(i).pis_id;
         --
         vn_fase := 5.1;
         --
         PK_APUR_PIS.PKB_CALCULAR_CONS_PIS_M200(EN_CONSCONTRPIS_ID => vn_pis_id);
         --
         vn_fase := 5.2;
         --
         PK_APUR_PIS.PKB_VALIDAR_CONS_PIS_M200(EN_CONSCONTRPIS_ID => vn_pis_id);
         --
         vn_fase := 6;
         --
         if i = vt_tab_pis_m200.last then
            exit;
         else
            i := vt_tab_pis_m200.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_calc_val_m200 fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ibmpc.id%TYPE;
      begin
         --
         pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id  => vn_loggenerico_id
                                , ev_mensagem             => gv_mensagem_log
                                , ev_resumo               => gv_resumo
                                , en_tipo_log             => ERRO_DE_SISTEMA
                                , en_referencia_id        => gn_referencia_id
                                , ev_obj_referencia       => gv_obj_referencia
                                , en_empresa_id           => gn_empresa_id
                                , en_dm_impressa          => 0
                                );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_calc_val_m200;
----------------------------------------------------------------------------------------------------
--| Processo para Calcular e Validar o registro M600 (via PK_APUR_COFINS)
----------------------------------------------------------------------------------------------------
procedure pkb_calc_val_m600
is
   --
   vn_fase     number := 0;
   i           pls_integer;
   vn_cofins_id   cons_contr_cofins.id%type;       
   --
begin
   --
   vn_fase := 1;
   --
   /*Serão utilizados os ids da tabela CONS_CONTR_COFINS que foram desprocessados*/
   if nvl(vt_tab_cofins_m600.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_cofins_m600.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         vn_cofins_id:= vt_tab_cofins_m600(i).cofins_id;
         --
         vn_fase := 5.1;
         --
         PK_APUR_COFINS.PKB_CALCULAR_CONS_COFINS_M600(EN_CONSCONTRCOFINS_ID => vn_cofins_id);
         --
         vn_fase := 5.2;
         --
         PK_APUR_COFINS.PKB_VALIDAR_CONS_COFINS_M600(EN_CONSCONTRCOFINS_ID => vn_cofins_id);
         --
         vn_fase := 6;
         --
         if i = vt_tab_cofins_m600.last then
            exit;
         else
            i := vt_tab_cofins_m600.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_calc_val_m600 fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ibmpc.id%TYPE;
      begin
         --
         pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id  => vn_loggenerico_id
                                , ev_mensagem             => gv_mensagem_log
                                , ev_resumo               => gv_resumo
                                , en_tipo_log             => ERRO_DE_SISTEMA
                                , en_referencia_id        => gn_referencia_id
                                , ev_obj_referencia       => gv_obj_referencia
                                , en_empresa_id           => gn_empresa_id
                                , en_dm_impressa          => 0
                                );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_calc_val_m600;
----------------------------------------------------------------------------------------------------
-- Processo de leitura da view do Blocos M230(PIS) e M630(Cofins)
----------------------------------------------------------------------------------------------------
procedure pkb_inf_adic_dif_pc
  is
   --
   vn_fase                  number := 0;
   vn_empresa               empresa.id%type;
   vn_detconscontrpis_id    inf_adic_dif_pis.detconscontrpis_id%type;
   vn_detconscontrcofins_id inf_adic_dif_cofins.detconscontrcofins_id%type;
   vn_tipocredpc_id         inf_adic_dif_pis.tipocredpc_id%type;
   --
   vn_ccp_id                cons_contr_pis.id%type;
   vn_ccp_id_ant            cons_contr_pis.id%type;
   vn_ccp_dm_sit            cons_contr_pis.dm_situacao%type;
   vn_ccc_id                cons_contr_cofins.id%type;
   vn_ccc_id_ant            cons_contr_cofins.id%type;
   vn_ccc_dm_sit            cons_contr_cofins.dm_situacao%type;
   --
   x                        pls_integer;  -- P/Pis
   y                        pls_integer;  -- P/Cofins
   --
begin
   -------------------
   --
   vn_fase := 1;
   --
   gv_sql := null;
   vt_tab_csf_inf_adic_dif_pc.delete;
   --
   x := 0;
   y := 0;
   vt_tab_pis_m200.delete;
   vt_tab_cofins_m600.delete;
   --
   -------------------
   
   vn_fase := 2;
   --
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CNPJ_EMPR' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_INI' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_FIN' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CD_CONTR_SOC_APUR_PC' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CNPJ' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_VEND' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_NAO_RECEB' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_CONT_DIF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_CRED_DIF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CD_TP_CRED_PC' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_PC' || trim(GV_ASPAS);
   --
   vn_fase := 3;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_INF_ADIC_DIF_PC' );
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CNPJ_EMPR' || trim(GV_ASPAS) || ' = ' || '''' || gv_cpf_cnpj || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DT_INI' || trim(GV_ASPAS) || ' >= ' || '''' || to_char(gd_dt_ini, GV_FORMATO_DT_ERP) || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DT_FIN' || trim(GV_ASPAS) || ' <= ' || '''' || to_char(gd_dt_fin, GV_FORMATO_DT_ERP) || '''';
   --
   vn_fase := 5;
   --
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_inf_adic_dif_pc;
     --
   exception
      when others then
        -- não registra erro caso a view não exista
        if sqlcode = -942 then
           null;
        else
           --
           begin
               pk_agend_integr.gvtn_qtd_erro(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erro(gv_cd_obj),0) + 1;
           exception
              when others then
              null;
           end;
           --
           gv_resumo := 'Erro na pk_int_view_bloco_m_pc.pkb_inf_adic_dif_pc fase ('||vn_fase||'): '||sqlerrm;
           --
          declare
             vn_loggenerico_id  log_generico_ibmpc.id%TYPE;
          begin
             --
             pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id  => vn_loggenerico_id
                                    , ev_mensagem             => gv_mensagem_log
                                    , ev_resumo               => gv_resumo
                                    , en_tipo_log             => ERRO_DE_SISTEMA
                                    , en_referencia_id        => gn_referencia_id
                                    , ev_obj_referencia       => gv_obj_referencia
                                    , en_empresa_id           => gn_empresa_id
                                    , en_dm_impressa          => 0    
                                    );
             --
          exception
             when others then
                null;
          end;
           
        end if;
   end;
   ---
   vn_fase := 6;
   --
   if vt_tab_csf_inf_adic_dif_pc.count > 0 then
      --
      vn_fase :=7;
      --
      for i in vt_tab_csf_inf_adic_dif_pc.first..vt_tab_csf_inf_adic_dif_pc.last loop
         --
         vn_fase := 7.1;
         gt_row_inf_adic_dif_pis   :=null;
         gt_row_inf_adic_dif_cofins:=null;
         vn_empresa:= pk_csf.fkg_empresa_id_cpf_cnpj ( en_multorg_id  => gn_multorg_id
                                                     , ev_cpf_cnpj    => vt_tab_csf_inf_adic_dif_pc(i).CNPJ_EMPR );
         --
         if vn_empresa is null then
            --
            vn_empresa:= gn_empresa_id;
            --
         end if;                                              
         --
         vn_fase := 7.2;
         vn_tipocredpc_id     := null;
         vn_tipocredpc_id     := pk_csf_efd_pc.fkg_tipo_cred_pc_id( ev_cd => vt_tab_csf_inf_adic_dif_pc(i).CD_TP_CRED_PC ) ;
         --
         /*Se '4', é PIS. O registro será integrado à tabela INF_ADIC_DIF_PIS.*/
         if vt_tab_csf_inf_adic_dif_pc(i).dm_ind_pc = '4' then          
           --
           vn_fase := 7.3;           
           vn_detconscontrpis_id:= null;
           vn_detconscontrpis_id:= fkg_detconscontrpis_id(en_id_empresa => vn_empresa,
                                                          ed_dt_ini     => gd_dt_ini, 
                                                          ed_dt_fin     => gd_dt_fin,
                                                          ev_cd_apur_pc => vt_tab_csf_inf_adic_dif_pc(i).CD_CONTR_SOC_APUR_PC);
           --
           if vn_detconscontrpis_id <> 0 then
              ----
              vn_fase := 7.4;
              --
              /*retorna id e status da tabela CONS_CONTR_PIS(M200)*/
              prc_conscontrpis_id_status(en_id          => vn_detconscontrpis_id,
                                         sn_ccp_id      => vn_ccp_id,
                                         sn_ccp_dm_sit  => vn_ccp_dm_sit);
              --  
              /*1-Calculada; 2-Erro no cálculo; 3-Processada; 4-Erro de validação*/                      
              if vn_ccp_dm_sit in ('1','2','3','4') then
                 ----
                 if vn_ccp_dm_sit in ('3','4') then
                   ----
                   /*foi colocado este update pois no desprocessar seria feito o mesmo para os status acima*/
                   update cons_contr_pis cc
                      set cc.dm_situacao = 1 -- Calculado
                    where cc.id = vn_ccp_id;
                    commit;
                    ----
                 end if;
                 ----
                 pk_apur_pis.pkb_desprocessar_cons_pis_m200(en_conscontrpis_id => vn_ccp_id);
                 ----
                 /*Serão os armazenados os id's da tabela cons_contr_pis que foram desprocessados*/ 
                 x := nvl(x,0) + 1;
                 --
                 vt_tab_pis_m200(x).pis_id:= vn_ccp_id;
                 ----
              end if; 
              --                      
              vn_fase := 7.41;
              gt_row_inf_adic_dif_pis.detconscontrpis_id := vn_detconscontrpis_id;
              gt_row_inf_adic_dif_pis.cnpj               := vt_tab_csf_inf_adic_dif_pc(i).CNPJ;
              gt_row_inf_adic_dif_pis.vl_vend            := vt_tab_csf_inf_adic_dif_pc(i).vl_vend;
              gt_row_inf_adic_dif_pis.vl_nao_receb       := vt_tab_csf_inf_adic_dif_pc(i).vl_nao_receb;
              gt_row_inf_adic_dif_pis.vl_cont_dif        := vt_tab_csf_inf_adic_dif_pc(i).vl_cont_dif;
              gt_row_inf_adic_dif_pis.vl_cred_dif        := vt_tab_csf_inf_adic_dif_pc(i).vl_cred_dif;
              gt_row_inf_adic_dif_pis.tipocredpc_id      := vn_tipocredpc_id;
              --
              vn_fase := 7.5;
              ----
              prc_integr_inf_adic_dif_pis;
              ----
           else
              ----
              begin
                  pk_agend_integr.gvtn_qtd_erro(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erro(gv_cd_obj),0) + 1;
              exception
                 when others then
                 null;
              end;
              --
              gv_resumo := 'Favor validar o registro na tabela VW_CSF_INF_ADIC_DIF_PC: cnpj:'||vt_tab_csf_inf_adic_dif_pc(i).CNPJ||' - vl_vend:'|| vt_tab_csf_inf_adic_dif_pc(i).vl_vend||' - vl_nao_receb:'||vt_tab_csf_inf_adic_dif_pc(i).vl_nao_receb; 
              ----
              declare
                 vn_loggenerico_id  log_generico_ibmpc.id%TYPE;
              begin
                 --
                 pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id  => vn_loggenerico_id
                                        , ev_mensagem             => gv_mensagem_log
                                        , ev_resumo               => gv_resumo
                                        , en_tipo_log             => informacao
                                        , en_referencia_id        => gn_referencia_id
                                        , ev_obj_referencia       => gv_obj_referencia
                                        , en_empresa_id           => gn_empresa_id
                                        , en_dm_impressa          => 0    
                                        );
                 --
              exception
                 when others then
                    null;
              end;
              ----
           end if;
           --
         end if;
         /*Se '5', é COFINS. O registro será integrado à tabela INF_ADIC_DIF_COFINS.*/
         if vt_tab_csf_inf_adic_dif_pc(i).dm_ind_pc = '5' then
           --
           vn_fase := 7.6; 
           vn_detconscontrcofins_id:= null; 
           vn_detconscontrcofins_id:= fkg_detconscontrcofins_id(en_id_empresa => vn_empresa,
                                                                ed_dt_ini     => gd_dt_ini, 
                                                                ed_dt_fin     => gd_dt_fin,
                                                                ev_cd_apur_pc => vt_tab_csf_inf_adic_dif_pc(i).CD_CONTR_SOC_APUR_PC); 
           --
           if vn_detconscontrcofins_id <> 0 then
              --
              vn_fase := 7.7; 
              --
              /*retorna id e status da tabela CONS_CONTR_COFINS (M600)*/
              prc_conscontrcofins_id_status(en_id          => vn_detconscontrcofins_id,
                                            sn_ccc_id      => vn_ccc_id,
                                            sn_ccc_dm_sit  => vn_ccc_dm_sit);
              --             
              /*1-Calculada; 2-Erro no cálculo; 3-Processada; 4-Erro de validação*/           
              if vn_ccc_dm_sit in ('1','2','3','4') then
                 ----
                 if vn_ccc_dm_sit in ('3','4') then
                    ----
                    /*foi colocado este update, pois no desprocessar seria feito o mesmo para os status acima*/
                    update cons_contr_cofins cc
                       set cc.dm_situacao = 1 -- Calculado
                     where cc.id = vn_ccc_id;
                     commit;
                   ----
                 end if;
                 --
                  /*pk_apur_pis.pkb_desprocessar_cons_pis_m200(en_conscontrpis_id => vn_ccc_id);*/
                 pk_apur_cofins.pkb_desproc_cons_cofins_m600(EN_CONSCONTRCOFINS_ID => vn_ccc_id);
                 ----
                 /*Serão os armazenados os id's da tabela cons_contr_cofins que foram desprocessados*/ 
                 y := nvl(y,0) + 1;
                 --
                 vt_tab_cofins_m600(y).cofins_id:= vn_ccc_id;
                 ----
              end if;
              --  
              vn_fase := 7.71;
              --
              gt_row_inf_adic_dif_cofins.detconscontrcofins_id := vn_detconscontrcofins_id;
              gt_row_inf_adic_dif_cofins.cnpj                  := vt_tab_csf_inf_adic_dif_pc(i).CNPJ;
              gt_row_inf_adic_dif_cofins.vl_vend               := vt_tab_csf_inf_adic_dif_pc(i).vl_vend;
              gt_row_inf_adic_dif_cofins.vl_nao_receb          := vt_tab_csf_inf_adic_dif_pc(i).vl_nao_receb;
              gt_row_inf_adic_dif_cofins.vl_cont_dif           := vt_tab_csf_inf_adic_dif_pc(i).vl_cont_dif;
              gt_row_inf_adic_dif_cofins.vl_cred_dif           := vt_tab_csf_inf_adic_dif_pc(i).vl_cred_dif;
              gt_row_inf_adic_dif_cofins.tipocredpc_id         := vn_tipocredpc_id;
              --
              vn_fase := 7.8;
              ----
              prc_integr_inf_adic_dif_cofins;
              ----
           else
              ----
              begin
                  pk_agend_integr.gvtn_qtd_erro(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erro(gv_cd_obj),0) + 1;
              exception
                 when others then
                 null;
              end;
              --
              gv_resumo := 'Favor validar o registro na tabela VW_CSF_INF_ADIC_DIF_PC: cnpj:'||vt_tab_csf_inf_adic_dif_pc(i).CNPJ||' - vl_vend:'|| vt_tab_csf_inf_adic_dif_pc(i).vl_vend||' - vl_nao_receb:'||vt_tab_csf_inf_adic_dif_pc(i).vl_nao_receb; 
              ----
              declare
                 vn_loggenerico_id  log_generico_ibmpc.id%TYPE;
              begin
                 --
                 pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id  => vn_loggenerico_id
                                        , ev_mensagem             => gv_mensagem_log
                                        , ev_resumo               => gv_resumo
                                        , en_tipo_log             => informacao
                                        , en_referencia_id        => gn_referencia_id
                                        , ev_obj_referencia       => gv_obj_referencia
                                        , en_empresa_id           => gn_empresa_id
                                        , en_dm_impressa          => 0    
                                        );
                 --
              exception
                 when others then
                    null;
              end;
              ----
           end if;
           --
         end if;     
         --
         -- Cálcula a quantidade de registros Totais integrados, com sucesso e com erro para serem
         -- mostrados na tela de agendamento.
         --
         begin
             pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
         exception
             when others then
             null;
         end;
         --
      end loop;
      --
   end if;
   --
   vn_fase := 8;
   /*Calcular e Validar o registro M200 (via PK_APUR_PIS)*/
   pkb_calc_val_m200;
   --
   vn_fase := 9;
   /*Calcular e Validar o registro M600 (via PK_APUR_COFINS)*/
   pkb_calc_val_m600;
   --
exception
   when others then
      --
      begin
          pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
          pk_agend_integr.gvtn_qtd_erro(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erro(gv_cd_obj),0) + 1;
      exception
          when others then
          null;
      end;
      --
      gv_resumo := 'Erro na pk_int_view_bloco_m_pc.pkb_inf_adic_dif_pc fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ibmpc.id%TYPE;
      begin
         --     
         pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id  => vn_loggenerico_id
                                , ev_mensagem             => gv_mensagem_log 
                                , ev_resumo               => gv_resumo
                                , en_tipo_log             => ERRO_DE_SISTEMA
                                , en_referencia_id        => gn_referencia_id
                                , ev_obj_referencia       => gv_obj_referencia
                                , en_empresa_id           => gn_empresa_id
                                , en_dm_impressa          => 0    
                                );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_inf_adic_dif_pc;
----------------------------------------------------------------------------------------------------
--| Processo para Validar o registro M300 (via PK_APUR_PIS)
----------------------------------------------------------------------------------------------------
procedure pkb_validar_m300
is
   --
   vn_fase     number := 0;
   i           pls_integer;
   vn_pis_id   contr_pis_dif_per_ant.id%type;       
   --
begin
   --
   vn_fase  := 1;
   vn_pis_id:= null;
   --
   /*Serão utilizados os ids da tabela CONS_CONTR_PIS que foram desprocessados*/
   if nvl(vt_tab_pis_m300.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_pis_m300.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         vn_pis_id:= vt_tab_pis_m300(i).pis_id;
         --
         vn_fase := 5.1;
         --
         PK_APUR_PIS.PKB_VALIDAR_CONTR_PIS_M300(EN_CONTRPISDIFPERANT_ID => vn_pis_id) ;
         --
         vn_fase := 6;
         --
         if i = vt_tab_pis_m300.last then
            exit;
         else
            i := vt_tab_pis_m300.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_validar_m300 fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ibmpc.id%TYPE;
      begin
         --
         pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id  => vn_loggenerico_id
                                , ev_mensagem             => gv_mensagem_log
                                , ev_resumo               => gv_resumo
                                , en_tipo_log             => ERRO_DE_SISTEMA
                                , en_referencia_id        => gn_referencia_id
                                , ev_obj_referencia       => gv_obj_referencia
                                , en_empresa_id           => gn_empresa_id
                                , en_dm_impressa          => 0
                                );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_validar_m300;
----------------------------------------------------------------------------------------------------
--| Procedimento de integração da Tabela CONTR_PIS_DIF_PER_ANT
----------------------------------------------------------------------------------------------------
procedure pkb_integr_contr_pis_difperant is
   --
   vn_fase                  number := 0;
   vn_contrpisdpant         contr_pis_dif_per_ant.id%type;
   --    
begin
 ------
  vn_fase :=1;
  vn_contrpisdpant:=null;
  ------
  begin
    select id into vn_contrpisdpant
    from contr_pis_dif_per_ant p
    where p.empresa_id      = gt_row_contr_pis_dif_per_ant.empresa_id
    and p.dt_ini            = gt_row_contr_pis_dif_per_ant.dt_ini
    and p.dt_fin            = gt_row_contr_pis_dif_per_ant.dt_fin
    and p.contrsocapurpc_id = gt_row_contr_pis_dif_per_ant.contrsocapurpc_id
    and p.per_apur          = gt_row_contr_pis_dif_per_ant.per_apur
    and (p.dt_receb         = gt_row_contr_pis_dif_per_ant.dt_receb or  p.dt_receb is null);
  exception
    when others then
      vn_contrpisdpant:=null;
  end ;
  ------
  if vn_contrpisdpant is null then
    ---
    select contrpisdifperant_seq.nextval into vn_contrpisdpant from dual;
    gt_row_contr_pis_dif_per_ant.id := vn_contrpisdpant;
    ---
    insert into contr_pis_dif_per_ant 
    (id ,
    empresa_id,
    dt_ini,
    dt_fin,
    dm_situacao ,
    contrsocapurpc_id, 
    vl_cont_apur_difer ,
    dm_nat_cred_desc ,
    vl_cred_desc_difer ,
    vl_cont_difer_ant ,
    per_apur ,
    dt_receb) values (
    gt_row_contr_pis_dif_per_ant.id ,
    gt_row_contr_pis_dif_per_ant.empresa_id,
    gt_row_contr_pis_dif_per_ant.dt_ini,
    gt_row_contr_pis_dif_per_ant.dt_fin,
    gt_row_contr_pis_dif_per_ant.dm_situacao ,
    gt_row_contr_pis_dif_per_ant.contrsocapurpc_id,
    gt_row_contr_pis_dif_per_ant.vl_cont_apur_difer ,
    gt_row_contr_pis_dif_per_ant.dm_nat_cred_desc ,
    gt_row_contr_pis_dif_per_ant.vl_cred_desc_difer ,
    gt_row_contr_pis_dif_per_ant.vl_cont_difer_ant ,
    gt_row_contr_pis_dif_per_ant.per_apur ,
    gt_row_contr_pis_dif_per_ant.dt_receb);
    ---
  else 
    ---
    gt_row_contr_pis_dif_per_ant.id := vn_contrpisdpant;
    ---
    update contr_pis_dif_per_ant set
     vl_cont_apur_difer = gt_row_contr_pis_dif_per_ant.vl_cont_apur_difer ,
     dm_nat_cred_desc   = gt_row_contr_pis_dif_per_ant.dm_nat_cred_desc ,
     vl_cred_desc_difer = gt_row_contr_pis_dif_per_ant.vl_cred_desc_difer ,
     vl_cont_difer_ant  = gt_row_contr_pis_dif_per_ant.vl_cont_difer_ant 
               where id = gt_row_contr_pis_dif_per_ant.id;
    ---
  end if;
 ------
 commit;
 ---
 begin
   pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj),0) + 1;
 exception
   when others then
   null;
 end;
 ---
exception
  when others then
  --
  begin
    pk_agend_integr.gvtn_qtd_erro(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erro(gv_cd_obj),0) + 1;
  exception
    when others then
    null;
  end;
  --
  gv_resumo := 'Erro na pk_int_view_bloco_m_pc.pkb_integr_contr_pis_difperant fase ('||vn_fase||'): '||sqlerrm;     
  --
  declare
     vn_loggenerico_id  log_generico_ibmpc.id%TYPE;
  begin
     --     
     pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id  => vn_loggenerico_id
                            , ev_mensagem             => gv_mensagem_log 
                            , ev_resumo               => gv_resumo
                            , en_tipo_log             => ERRO_DE_SISTEMA
                            , en_referencia_id        => gn_referencia_id
                            , ev_obj_referencia       => gv_obj_referencia
                            , en_empresa_id           => gn_empresa_id
                            , en_dm_impressa          => 0    
                            );
     --
  exception
     when others then
        null;
  end;
  --
end pkb_integr_contr_pis_difperant;
----------------------------------------------------------------------------------------------------
-- Processo de leitura da view do Blocos M300(PIS)
----------------------------------------------------------------------------------------------------
procedure pkb_contr_pis_dif_per_ant is
   --
   vn_fase                  number := 0;
   vn_empresa               empresa.id%type;
   vn_contrsocapurpc_id     contr_pis_dif_per_ant.contrsocapurpc_id%type;
   --
   x                        pls_integer;  -- P/Pis
   --
begin
   -------------------
   --
   vn_fase := 1;
   --
   gv_sql := null;
   vt_tab_csf_contr_pis_dif_pant.delete;
   --
   -------------------
   
   vn_fase := 2;
   --
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CNPJ_EMPR' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_INI' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_FIN' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CD_CONTR_SOC_APUR_PC' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_CONT_APUR_DIFER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_NAT_CRED_DESC' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_CRED_DESC_DIFER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_CONT_DIFER_ANT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'PER_APUR' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_RECEB' || trim(GV_ASPAS);
   --
   vn_fase := 3;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_CONTR_PIS_DIF_PER_ANT' );
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CNPJ_EMPR' || trim(GV_ASPAS) || ' = ' || '''' || gv_cpf_cnpj || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DT_INI' || trim(GV_ASPAS) || ' >= ' || '''' || to_char(gd_dt_ini, GV_FORMATO_DT_ERP) || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DT_FIN' || trim(GV_ASPAS) || ' <= ' || '''' || to_char(gd_dt_fin, GV_FORMATO_DT_ERP) || '''';
   --
   vn_fase := 5;
   --
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_contr_pis_dif_pant;
     --
   exception
      when others then
        -- não registra erro caso a view não exista
        if sqlcode = -942 then
           null;
        else
          --
          begin
              pk_agend_integr.gvtn_qtd_erro(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erro(gv_cd_obj),0) + 1;
          exception
             when others then
             null;
          end;
          --
          gv_resumo       := 'Erro na pk_int_view_bloco_m_pc.pkb_contr_pis_dif_per_ant fase ('||vn_fase||'): '||sqlerrm;
          --
          declare
             vn_loggenerico_id  log_generico_ibmpc.id%TYPE;
          begin
             --
             pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id  => vn_loggenerico_id
                                    , ev_mensagem             => gv_mensagem_log
                                    , ev_resumo               => gv_resumo
                                    , en_tipo_log             => ERRO_DE_SISTEMA
                                    , en_referencia_id        => gn_referencia_id
                                    , ev_obj_referencia       => gv_obj_referencia
                                    , en_empresa_id           => gn_empresa_id
                                    , en_dm_impressa          => 0    
                                    );
             --
          exception
             when others then
                null;
          end;
           
        end if;
   end;
   --
   if vt_tab_csf_contr_pis_dif_pant.count > 0 then
      --
      vn_fase :=7;
      --
      for i in vt_tab_csf_contr_pis_dif_pant.first..vt_tab_csf_contr_pis_dif_pant.last loop
         --
         vn_fase := 7.1;
         gt_row_contr_pis_dif_per_ant   :=null;         
         vn_empresa:= pk_csf.fkg_empresa_id_cpf_cnpj ( en_multorg_id  => gn_multorg_id
                                                     , ev_cpf_cnpj    => vt_tab_csf_contr_pis_dif_pant(i).CNPJ_EMPR );
         --
         if vn_empresa is null then
            --
            vn_empresa:= gn_empresa_id;
            --
         end if;                                              
         --
         vn_fase := 7.2;
         vn_contrsocapurpc_id     := null;
         vn_contrsocapurpc_id     := pk_csf_efd_pc.fkg_contr_soc_apur_pc_id( ev_cd => vt_tab_csf_contr_pis_dif_pant(i).CD_CONTR_SOC_APUR_PC ) ;
         ----
         vn_fase := 7.3;
         gt_row_contr_pis_dif_per_ant.empresa_id        := vn_empresa;
         gt_row_contr_pis_dif_per_ant.dt_ini            := vt_tab_csf_contr_pis_dif_pant(i).dt_ini;
         gt_row_contr_pis_dif_per_ant.dt_fin            := vt_tab_csf_contr_pis_dif_pant(i).dt_fin;
         gt_row_contr_pis_dif_per_ant.dm_situacao       := 0; -- 0-Aberto;1-Calculada;2-Erro no cálculo;3-Processada;4-Erro de validação /*vt_tab_csf_contr_cof_dif_pant(i).dm_situacao;*/
         gt_row_contr_pis_dif_per_ant.contrsocapurpc_id := vn_contrsocapurpc_id;
         gt_row_contr_pis_dif_per_ant.vl_cont_apur_difer:= vt_tab_csf_contr_pis_dif_pant(i).vl_cont_apur_difer;
         gt_row_contr_pis_dif_per_ant.dm_nat_cred_desc  := vt_tab_csf_contr_pis_dif_pant(i).dm_nat_cred_desc;
         gt_row_contr_pis_dif_per_ant.vl_cred_desc_difer:= vt_tab_csf_contr_pis_dif_pant(i).vl_cred_desc_difer;
         gt_row_contr_pis_dif_per_ant.vl_cont_difer_ant := vt_tab_csf_contr_pis_dif_pant(i).vl_cont_difer_ant; 
         gt_row_contr_pis_dif_per_ant.per_apur          := vt_tab_csf_contr_pis_dif_pant(i).per_apur;
         gt_row_contr_pis_dif_per_ant.dt_receb          := vt_tab_csf_contr_pis_dif_pant(i).dt_receb;
         --
         vn_fase := 7.4;
         --
         pkb_integr_contr_pis_difperant;
         ----
         vn_fase := 7.5;
         /*Serão os armazenados os id's da tabela contr_pis_dif_per_ant para que sejam validados posteriormente*/ 
         x := nvl(x,0) + 1;
         --
         vt_tab_pis_m300(x).pis_id:= gt_row_contr_pis_dif_per_ant.id;
         ----
         -- Cálcula a quantidade de registros Totais integrados, com sucesso e com erro para serem
         -- mostrados na tela de agendamento.
         --
         vn_fase := 7.6;
         --
         begin
             pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
         exception
             when others then
             null;
         end;
         --
      end loop;
      --
   end if;
   --
   vn_fase := 8;
   /*Validar o registro M300 (via PK_APUR_PIS)*/
   pkb_validar_m300;
   --
exception
   when others then
      --
      begin
          pk_agend_integr.gvtn_qtd_total(gv_cd_obj):= nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
          pk_agend_integr.gvtn_qtd_erro(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erro(gv_cd_obj),0) + 1;
      exception
          when others then
          null;
      end;
      --
      gv_resumo := 'Erro na pk_int_view_bloco_m_pc.pkb_contr_pis_dif_per_ant fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ibmpc.id%TYPE;
      begin
         --     
         pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id  => vn_loggenerico_id
                                , ev_mensagem             => gv_mensagem_log 
                                , ev_resumo               => gv_resumo
                                , en_tipo_log             => ERRO_DE_SISTEMA
                                , en_referencia_id        => gn_referencia_id
                                , ev_obj_referencia       => gv_obj_referencia
                                , en_empresa_id           => gn_empresa_id
                                , en_dm_impressa          => 0    
                                );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_contr_pis_dif_per_ant;
----------------------------------------------------------------------------------------------------
--| Processo para Validar o registro M700 (via PK_APUR_PIS)
----------------------------------------------------------------------------------------------------
procedure pkb_validar_m700
is
   --
   vn_fase     number := 0;
   i           pls_integer;
   vn_cofins_id   contr_cofins_dif_per_ant.id%type;       
   --
begin
   --
   vn_fase  := 1;
   vn_cofins_id:= null;
   --
   /*Serão utilizados os ids da tabela CONS_CONTR_PIS que foram desprocessados*/
   if nvl(vt_tab_cofins_m700.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_cofins_m700.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         vn_cofins_id:= vt_tab_cofins_m700(i).cofins_id;
         --
         vn_fase := 5.1;
         --
         PK_APUR_COFINS.PKB_VALIDAR_CONTR_COFINS_M700(EN_CONTRCOFINSDIFPERANT_ID => vn_cofins_id);
         --
         vn_fase := 6;
         --
         if i = vt_tab_cofins_m700.last then
            exit;
         else
            i := vt_tab_cofins_m700.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_validar_m700 fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ibmpc.id%TYPE;
      begin
         --
         pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id  => vn_loggenerico_id
                                , ev_mensagem             => gv_mensagem_log
                                , ev_resumo               => gv_resumo
                                , en_tipo_log             => ERRO_DE_SISTEMA
                                , en_referencia_id        => gn_referencia_id
                                , ev_obj_referencia       => gv_obj_referencia
                                , en_empresa_id           => gn_empresa_id
                                , en_dm_impressa          => 0
                                );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_validar_m700;
----------------------------------------------------------------------------------------------------
--| Procedimento de integração da Tabela CONTR_COFINS_DIF_PER_ANT
----------------------------------------------------------------------------------------------------
procedure pkb_integr_contr_cof_difperant is
   --
   vn_fase                  number := 0;
   vn_contrcofdpant         contr_cofins_dif_per_ant.id%type;
   --    
begin
 ------
  vn_fase :=1;
  vn_contrcofdpant:=null;
  ------
  begin
    select id into vn_contrcofdpant
    from contr_cofins_dif_per_ant p
    where p.empresa_id      = gt_row_contr_cof_dif_per_ant.empresa_id
    and p.dt_ini            = gt_row_contr_cof_dif_per_ant.dt_ini
    and p.dt_fin            = gt_row_contr_cof_dif_per_ant.dt_fin
    and p.contrsocapurpc_id = gt_row_contr_cof_dif_per_ant.contrsocapurpc_id
    and p.per_apur          = gt_row_contr_cof_dif_per_ant.per_apur
    and (p.dt_receb         = gt_row_contr_cof_dif_per_ant.dt_receb  or  p.dt_receb is null) ;
  exception
    when others then
      vn_contrcofdpant:=null;
  end ;
  ------
  if vn_contrcofdpant is null then
    ---
    select contrcofinsdifperant_seq.nextval into vn_contrcofdpant from dual;
    gt_row_contr_cof_dif_per_ant.id := vn_contrcofdpant;
    ---
    insert into contr_cofins_dif_per_ant 
    (id ,
    empresa_id,
    dt_ini,
    dt_fin,
    dm_situacao ,
    contrsocapurpc_id, 
    vl_cont_apur_difer ,
    dm_nat_cred_desc ,
    vl_cred_desc_difer ,
    vl_cont_difer_ant ,
    per_apur ,
    dt_receb) values (
    gt_row_contr_cof_dif_per_ant.id ,
    gt_row_contr_cof_dif_per_ant.empresa_id,
    gt_row_contr_cof_dif_per_ant.dt_ini,
    gt_row_contr_cof_dif_per_ant.dt_fin,
    gt_row_contr_cof_dif_per_ant.dm_situacao ,
    gt_row_contr_cof_dif_per_ant.contrsocapurpc_id,
    gt_row_contr_cof_dif_per_ant.vl_cont_apur_difer ,
    gt_row_contr_cof_dif_per_ant.dm_nat_cred_desc ,
    gt_row_contr_cof_dif_per_ant.vl_cred_desc_difer ,
    gt_row_contr_cof_dif_per_ant.vl_cont_difer_ant ,
    gt_row_contr_cof_dif_per_ant.per_apur ,
    gt_row_contr_cof_dif_per_ant.dt_receb);
    ---
  else 
    ---
    gt_row_contr_cof_dif_per_ant.id := vn_contrcofdpant;
    ---
    update contr_cofins_dif_per_ant set
     vl_cont_apur_difer = gt_row_contr_cof_dif_per_ant.vl_cont_apur_difer ,
     dm_nat_cred_desc   = gt_row_contr_cof_dif_per_ant.dm_nat_cred_desc ,
     vl_cred_desc_difer = gt_row_contr_cof_dif_per_ant.vl_cred_desc_difer ,
     vl_cont_difer_ant  = gt_row_contr_cof_dif_per_ant.vl_cont_difer_ant 
               where id = gt_row_contr_cof_dif_per_ant.id;
    ---
  end if;
 ------
 commit;
 ---
 begin
   pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj),0) + 1;
 exception
   when others then
   null;
 end;
 ---
exception
  when others then
  -- 
  begin
    pk_agend_integr.gvtn_qtd_erro(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erro(gv_cd_obj),0) + 1;
  exception
    when others then
    null;
  end;
  --
  gv_resumo := 'Erro na pk_int_view_bloco_m_pc.pkb_integr_contr_cof_difperant fase ('||vn_fase||'): '||sqlerrm;     
  --
  declare
     vn_loggenerico_id  log_generico_ibmpc.id%TYPE;
  begin
     --     
     pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id  => vn_loggenerico_id
                            , ev_mensagem             => gv_mensagem_log 
                            , ev_resumo               => gv_resumo
                            , en_tipo_log             => ERRO_DE_SISTEMA
                            , en_referencia_id        => gn_referencia_id
                            , ev_obj_referencia       => gv_obj_referencia
                            , en_empresa_id           => gn_empresa_id
                            , en_dm_impressa          => 0    
                            );
     --
  exception
     when others then
        null;
  end;
  --
end pkb_integr_contr_cof_difperant;
----------------------------------------------------------------------------------------------------
-- Processo de leitura da view do Blocos M700(Cofins)
----------------------------------------------------------------------------------------------------
procedure pkb_contr_cofins_dif_per_ant is
   --
   vn_fase                  number := 0;
   vn_empresa               empresa.id%type;
   vn_contrsocapurpc_id     contr_cofins_dif_per_ant.contrsocapurpc_id%type;
   --
   y                        pls_integer;  -- P/Cofins
   --
begin
   -------------------
   --
   vn_fase := 1;
   --
   gv_sql := null;
   vt_tab_csf_contr_cof_dif_pant.delete;
   --
   -------------------
   
   vn_fase := 2;
   --
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CNPJ_EMPR' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_INI' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_FIN' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CD_CONTR_SOC_APUR_PC' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_CONT_APUR_DIFER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_NAT_CRED_DESC' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_CRED_DESC_DIFER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_CONT_DIFER_ANT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'PER_APUR' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_RECEB' || trim(GV_ASPAS);
   --
   vn_fase := 3;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_CONTR_COF_DIF_PER_ANT' );
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CNPJ_EMPR' || trim(GV_ASPAS) || ' = ' || '''' || gv_cpf_cnpj || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DT_INI' || trim(GV_ASPAS) || ' >= ' || '''' || to_char(gd_dt_ini, GV_FORMATO_DT_ERP) || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DT_FIN' || trim(GV_ASPAS) || ' <= ' || '''' || to_char(gd_dt_fin, GV_FORMATO_DT_ERP) || '''';
   --
   vn_fase := 5;
   --
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_contr_cof_dif_pant;
     --
   exception
      when others then
        -- não registra erro caso a view não exista
        if sqlcode = -942 then
           null;
        else
           --
           begin
              pk_agend_integr.gvtn_qtd_erro(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erro(gv_cd_obj),0) + 1;
           exception
             when others then
             null;
           end;
           --
           gv_resumo        := 'Erro na pk_int_view_bloco_m_pc.pkb_contr_cofins_dif_per_ant fase ('||vn_fase||'): '||sqlerrm;
           --
          declare
             vn_loggenerico_id  log_generico_ibmpc.id%TYPE;
          begin
             --
             pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id  => vn_loggenerico_id
                                    , ev_mensagem             => gv_mensagem_log
                                    , ev_resumo               => gv_resumo
                                    , en_tipo_log             => ERRO_DE_SISTEMA
                                    , en_referencia_id        => gn_referencia_id
                                    , ev_obj_referencia       => gv_obj_referencia
                                    , en_empresa_id           => gn_empresa_id
                                    , en_dm_impressa          => 0    
                                    );
             --
          exception
             when others then
                null;
          end;
           
        end if;
   end;
   --
   if vt_tab_csf_contr_cof_dif_pant.count > 0 then
      --
      vn_fase :=7;
      --
      for i in vt_tab_csf_contr_cof_dif_pant.first..vt_tab_csf_contr_cof_dif_pant.last loop
         --
         vn_fase := 7.1;
         gt_row_contr_cof_dif_per_ant   :=null;         
         vn_empresa:= pk_csf.fkg_empresa_id_cpf_cnpj ( en_multorg_id  => gn_multorg_id
                                                     , ev_cpf_cnpj    => vt_tab_csf_contr_cof_dif_pant(i).CNPJ_EMPR );
         --
         if vn_empresa is null then
            --
            vn_empresa:= gn_empresa_id;
            --
         end if;                                              
         --
         vn_fase := 7.2;
         vn_contrsocapurpc_id     := null;
         vn_contrsocapurpc_id     := pk_csf_efd_pc.fkg_contr_soc_apur_pc_id( ev_cd => vt_tab_csf_contr_cof_dif_pant(i).CD_CONTR_SOC_APUR_PC ) ;
         ----
         vn_fase := 7.3;
         gt_row_contr_cof_dif_per_ant.empresa_id        := vn_empresa;
         gt_row_contr_cof_dif_per_ant.dt_ini            := vt_tab_csf_contr_cof_dif_pant(i).dt_ini;
         gt_row_contr_cof_dif_per_ant.dt_fin            := vt_tab_csf_contr_cof_dif_pant(i).dt_fin;
         gt_row_contr_cof_dif_per_ant.dm_situacao       := 0; -- 0-Aberto;1-Calculada;2-Erro no cálculo;3-Processada;4-Erro de validação /*vt_tab_csf_contr_cof_dif_pant(i).dm_situacao;*/
         gt_row_contr_cof_dif_per_ant.contrsocapurpc_id := vn_contrsocapurpc_id;
         gt_row_contr_cof_dif_per_ant.vl_cont_apur_difer:= vt_tab_csf_contr_cof_dif_pant(i).vl_cont_apur_difer;
         gt_row_contr_cof_dif_per_ant.dm_nat_cred_desc  := vt_tab_csf_contr_cof_dif_pant(i).dm_nat_cred_desc;
         gt_row_contr_cof_dif_per_ant.vl_cred_desc_difer:= vt_tab_csf_contr_cof_dif_pant(i).vl_cred_desc_difer;
         gt_row_contr_cof_dif_per_ant.vl_cont_difer_ant := vt_tab_csf_contr_cof_dif_pant(i).vl_cont_difer_ant; 
         gt_row_contr_cof_dif_per_ant.per_apur          := vt_tab_csf_contr_cof_dif_pant(i).per_apur;
         gt_row_contr_cof_dif_per_ant.dt_receb          := vt_tab_csf_contr_cof_dif_pant(i).dt_receb;
         --
         vn_fase := 7.4;
         ----
         pkb_integr_contr_cof_difperant;
         ----
         /*Serão os armazenados os id's da tabela contr_cofins_dif_per_ant que foram desprocessados*/
         y := nvl(y,0) + 1;
         --
         vt_tab_cofins_m700(y).cofins_id:= gt_row_contr_cof_dif_per_ant.id;
         ----
         -- Cálcula a quantidade de registros Totais integrados, com sucesso e com erro para serem
         -- mostrados na tela de agendamento.
         --
         begin
             pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
         exception
             when others then
             null;
         end;
         --
      end loop;
      --
   end if;
   --
   /*Validar o registro M700 (via PK_APUR_PIS)*/
   pkb_validar_m700;
   --
exception
   when others then
      --
      begin
          pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
          pk_agend_integr.gvtn_qtd_erro(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erro(gv_cd_obj),0) + 1;
      exception
          when others then
          null;
      end;
      --
      gv_resumo := 'Erro na pk_int_view_bloco_m_pc.pkb_contr_cofins_dif_per_ant fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ibmpc.id%TYPE;
      begin
         --     
         pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id  => vn_loggenerico_id
                                , ev_mensagem             => gv_mensagem_log 
                                , ev_resumo               => gv_resumo
                                , en_tipo_log             => ERRO_DE_SISTEMA
                                , en_referencia_id        => gn_referencia_id
                                , ev_obj_referencia       => gv_obj_referencia
                                , en_empresa_id           => gn_empresa_id
                                , en_dm_impressa          => 0    
                                );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_contr_cofins_dif_per_ant;
----------------------------------------------------------------------------------------------------
-- Processo de integração por periodo e empresa
----------------------------------------------------------------------------------------------------
procedure pkb_integracao ( en_empresa_id  in number
                         , ed_dt_ini      in date
                         , ed_dt_fin      in date
                         )
is
   --
   vn_fase          number := 0;
   vv_cpf_cnpj      varchar2(14);
   --
   cursor c_empr is
   select e.id empresa_id
        , e.dt_ini_integr
        , eib.owner_obj
        , eib.nome_dblink
        , eib.dm_util_aspa
        , eib.dm_ret_infor_integr
        , eib.formato_dt_erp
        , eib.dm_form_dt_erp
        , e.multorg_id
     from empresa e
        , empresa_integr_banco eib
    where e.id = en_empresa_id
      and e.dm_tipo_integr in (3, 4) -- Integração por view
      and e.dm_situacao    = 1 -- Ativa
      and eib.empresa_id   = e.id
    order by 1;
   -- 
begin
   -- Inicia os contadores de registros a serem integrados
   pk_agend_integr.pkb_inicia_cont(ev_cd_obj => gv_cd_obj);
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   pkb_limpar_loggenericoibmpc;
   --
   vn_fase := 1;
   --
   gv_mensagem_log := null;
   gv_mensagem_log := 'Empresa: '||vv_cpf_cnpj||' - '||pk_csf.fkg_nome_empresa(en_empresa_id => en_empresa_id);
   ---
   vn_fase := 1.1;
   gn_multorg_id   := pk_csf.fkg_multorg_id_empresa ( en_empresa_id => gn_empresa_id );
   ---
   vn_fase := 1.2;
   gd_dt_ini       := ed_dt_ini;
   gd_dt_fin       := ed_dt_fin;
   --
   pkb_seta_obj_ref ( ev_objeto => 'INF_BLOCO_M_PC' );
   --
   vn_fase := 2;
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase        := 3;
      vv_cpf_cnpj    := null;
      vv_cpf_cnpj    := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => rec.empresa_id );
      -- Se ta o DBLink
      gv_nome_dblink := rec.nome_dblink;
      gv_owner_obj   := rec.owner_obj;
      gv_cpf_cnpj    := vv_cpf_cnpj;
      gn_multorg_id  := rec.multorg_id;
      gn_empresa_id  := rec.empresa_id;
      --
      vn_fase := 4;
      -- Verifica se utiliza GV_ASPAS dupla
      if rec.dm_util_aspa = 1 then
         --
         gv_aspas := '"';
         --
      else
         --
         gv_aspas := null;
         --
      end if;
      --
      vn_fase := 5;
      --  Seta formata da data para os procedimentos de integracao
      if trim(rec.formato_dt_erp) is not null then
         gv_formato_dt_erp := rec.formato_dt_erp;
      else
         gv_formato_dt_erp := gv_formato_data;
      end if;
      --
      vn_fase := 6;
      --
      gv_mensagem_log := null;
      gv_mensagem_log := 'Empresa: '||vv_cpf_cnpj||' - '||pk_csf.fkg_nome_empresa(en_empresa_id => en_empresa_id);
      gn_empresa_id   := rec.empresa_id; -- para os logs do processo pk_int_view_ddo
      gd_dt_ult_fecha := pk_csf.fkg_recup_dtult_fecha_empresa( en_empresa_id   => rec.empresa_id
                                                             , en_objintegr_id => pk_csf.fkg_recup_objintegr_id( ev_cd => '50' )); -- Bloco M EFD Contribuições

      --
      vn_fase := 7;
      pkb_inf_adic_dif_pc;
      --
      vn_fase := 8;
      pkb_contr_pis_dif_per_ant;
      --
      vn_fase := 9;
      pkb_contr_cofins_dif_per_ant;
      --
   end loop;
   --
exception
   when others then
     --
     gv_resumo := 'Erro na pk_int_view_bloco_m_pc.pkb_integracao fase ('||vn_fase||'):'||sqlerrm;
     --
     declare
       vn_loggenerico_id   Log_Generico_ibmpc.id%type;
     begin
       --
       pkb_log_generico_ibmpc( sn_loggenericoibmpc_id  => vn_loggenerico_id
                             , ev_mensagem          => gv_mensagem_log
                             , ev_resumo            => gv_resumo
                             , en_tipo_log          => erro_de_sistema
                             , en_empresa_id        => en_empresa_id );
       --
     exception
        when others then
           raise_application_error(-20101, gv_resumo);
     end;
     --
end pkb_integracao;
----------------------------------------------------------------------------------------------------
-- Processo de integração por periodo normal
----------------------------------------------------------------------------------------------------
procedure pkb_integr_normal( ed_dt_ini in date
                           , ed_dt_fin in date ) is
   --
   vn_fase number := 0;
   --
   cursor c_empr is
   select e.id empresa_id
     from empresa e
        , empresa_integr_banco eib
    where e.id              = eib.empresa_id
      and e.dm_tipo_integr in (3, 4) -- Integração por view
      and e.dm_situacao     = 1 -- Ativa
    order by 1;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_empr loop
      exit when c_empr%notfound or(c_empr%notfound) is null;
      --
      vn_fase := 2;
      --
      pkb_integracao ( en_empresa_id => rec.empresa_id
                     , ed_dt_ini     => ed_dt_ini
                     , ed_dt_fin     => ed_dt_fin
                     );
      --
   end loop;
   --
exception
   when others then
     --
     gv_resumo := 'Erro na pk_int_view_bloco_m_pc.pkb_integr_normal fase ('||vn_fase||'):'||sqlerrm;
     --
     declare
       vn_loggenerico_id   log_generico_ibmpc.id%type;
     begin
       --
       pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id => vn_loggenerico_id
                              , ev_mensagem            => gv_mensagem_log
                              , ev_resumo              => gv_resumo
                              , en_tipo_log            => erro_de_sistema );
       --
     exception
        when others then
           raise_application_error(-20101, gv_resumo);
     end;
     --
end pkb_integr_normal;

----------------------------------------------------------------------------------------------------
-- Processo de integração por periodo
----------------------------------------------------------------------------------------------------
procedure pkb_integr_periodo_geral ( en_multorg_id in mult_org.id%type
                                   , ed_dt_ini     in date
                                   , ed_dt_fin     in date )is
   --
   vn_fase          number := 0;
   vv_cpf_cnpj      varchar2(14);
   --
   cursor c_empr is
   select e.id empresa_id
        , e.dt_ini_integr
        , eib.owner_obj
        , eib.nome_dblink
        , eib.dm_util_aspa
        , eib.dm_ret_infor_integr
        , eib.formato_dt_erp
        , eib.dm_form_dt_erp
        , e.multorg_id
     from empresa e
        , empresa_integr_banco eib
    where e.multorg_id     = en_multorg_id
      and e.dm_tipo_integr in (3, 4) -- Integração por view
      and e.dm_situacao    = 1 -- Ativa
      and eib.empresa_id   = e.id
    order by 1;

begin
   --
   vn_fase := 1;
   --Inicia os contadores de registros a serem integrados.
   pk_agend_integr.pkb_inicia_cont(ev_cd_obj => gv_cd_obj);
   --
   vn_fase := 1.1;
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   vn_fase := 1.2;
   --
   -- Limpar a tabela log_generico_ddo
   pkb_limpar_loggenericoibmpc;
   --
   vn_fase := 2;
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 3;
      --
      vv_cpf_cnpj    := null;
      vv_cpf_cnpj    := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => rec.empresa_id );
      --
      gd_dt_ini      := ed_dt_ini;
      gd_dt_fin      := ed_dt_fin;
      -- Se ta o DBLink
      gv_nome_dblink := rec.nome_dblink;/*null;*/
      gv_owner_obj   := rec.owner_obj;/*null;*/
      --
      vn_fase := 3.1;
      /*gv_aspas       := null;*/
      -- Verifica se utiliza GV_ASPAS dupla
      if rec.dm_util_aspa = 1 then
         --
         gv_aspas := '"';
         --
      else
         --
         gv_aspas := null;
         --
      end if;
      ----
      gv_cpf_cnpj    := vv_cpf_cnpj;
      gn_multorg_id  := rec.multorg_id;
      gn_empresa_id  := rec.empresa_id;
      --
      vn_fase := 4;
      --  Seta formata da data para os procedimentos de integracao
      /*gv_formato_dt_erp := gv_formato_data;*/
      if trim(rec.formato_dt_erp) is not null then
         gv_formato_dt_erp := rec.formato_dt_erp;
      else
         gv_formato_dt_erp := gv_formato_data;
      end if;
      --
      vn_fase := 5;
      --
      gv_mensagem_log := 'Empresa: '||gv_cpf_cnpj||', período de '||to_char(gd_dt_ini,'dd/mm/rrrr')||' até '||to_char(gd_dt_fin,'dd/mm/rrrr')||'.';
      gn_empresa_id   := rec.empresa_id; 
      gd_dt_ult_fecha := pk_csf.fkg_recup_dtult_fecha_empresa( en_empresa_id   => rec.empresa_id
                                                             , en_objintegr_id => pk_csf.fkg_recup_objintegr_id( ev_cd => '50' )); -- Bloco M EFD Contribuições
      --
      --
      vn_fase := 6;
      pkb_inf_adic_dif_pc;
      --
      vn_fase := 7;
      pkb_contr_pis_dif_per_ant;
      --
      vn_fase := 8;
      pkb_contr_cofins_dif_per_ant;
      --
   end loop;
/*   --
   vn_fase := 18;
   -- Finaliza o log genérico para integração dos documentos.
   pk_csf_api_ddo.pkb_finaliza_log_generico_ddo;
   --
   vn_fase := 19;
   --
   pk_csf_api_ddo.pkb_seta_tipo_integr ( en_tipo_integr => null );
   --*/
exception
   when others then
      --
      gv_resumo := 'Erro na pk_int_view_bloco_m_pc.pkb_integr_periodo_geral fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ibmpc.id%TYPE;
      begin
         --
         pkb_log_generico_ibmpc ( sn_loggenericoibmpc_id  => vn_loggenerico_id
                                , ev_mensagem             => gv_mensagem_log
                                , ev_resumo               => gv_resumo
                                , en_tipo_log             => ERRO_DE_SISTEMA
                                );
         --
      exception
         when others then
            raise_application_error(-20101, gv_resumo);
      end;
      --
end pkb_integr_periodo_geral;

-------------------------------------------------------------------------------------------------------
end pk_int_view_bloco_m_pc;
/
