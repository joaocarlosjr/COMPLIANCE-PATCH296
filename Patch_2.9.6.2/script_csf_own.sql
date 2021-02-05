------------------------------------------------------------------------------------------
Prompt INI Patch 2.9.6.2 - Alteracoes no CSF_OWN
------------------------------------------------------------------------------------------

insert into csf_own.versao_sistema ( ID
                                   , VERSAO
                                   , DT_VERSAO
                                   )
                            values ( csf_own.versaosistema_seq.nextval -- ID
                                   , '2.9.6.2'                         -- VERSAO
                                   , sysdate                           -- DT_VERSAO
                                   )
/

commit
/

-------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #75477 -  Criação de Job Scheduler JOB_CORRIGIR_NF_CT
-------------------------------------------------------------------------------------------------------------------------------

DECLARE 
  vn_cont NUMBER;
BEGIN
  --
  -- Verifica se o Job JOB_CORRIGIR_NF_CT já foi criado, caso existir sai da rotina
  BEGIN
    SELECT COUNT(1)
      INTO vn_cont
      FROM ALL_SCHEDULER_JOBS
     WHERE JOB_NAME = 'JOB_CORRIGIR_NF_CT'
       AND ENABLED  = 'TRUE';
    EXCEPTION
      WHEN OTHERS THEN
        vn_cont := 0;
    END;
    --
    IF vn_cont = 0 THEN
        DBMS_SCHEDULER.CREATE_JOB
            (
              JOB_NAME => 'JOB_CORRIGIR_NF_CT',
              JOB_TYPE => 'STORED_PROCEDURE',
              JOB_ACTION => 'CSF_OWN.PB_CORRIGIR_PESSOA_NF_CT',
              START_DATE => SYSDATE,
              REPEAT_INTERVAL => 'SYSDATE + (((1/24)/60))',
              ENABLED => TRUE,
              COMMENTS => 'POPULA PESSOA_ID NA NF/CT QUANDO ESTIVER NULO.'
            );
     END IF;
EXCEPTION
	WHEN OTHERS THEN
		RAISE_APPLICATION_ERROR(-20101, 'Erro ao criar o Job - JOB_CORRIGIR_NF_CT  : '||sqlerrm);
END;
/
-------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #75477 -  Criação de Job Scheduler JOB_CORRIGIR_NF_CT
-------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #75193 - Adicionar campo EMPRESA_FORMA_TRIB.PERC_RED_IR
-------------------------------------------------------------------------------------------------------------------------------
 
declare
  vn_qtde    number;
begin
  begin
     select count(1)
       into vn_qtde 
       from all_tab_columns a
      where a.OWNER = 'CSF_OWN'  
        and a.TABLE_NAME = 'EMPRESA_FORMA_TRIB'
        and a.COLUMN_NAME = 'PERC_RED_IR'; 
   exception
      when others then
         vn_qtde := 0;
   end;	
   --   
   if vn_qtde = 0 then
      -- Add/modify columns    
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.EMPRESA_FORMA_TRIB add perc_red_ir number(5,2)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao incluir coluna "perc_red_ir" em EMPRESA_FORMA_TRIB - '||SQLERRM );
      END;
      -- 
      -- Add comments to the table   
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.EMPRESA_FORMA_TRIB.perc_red_ir is ''Percentual de Redução de IR para atividades incentivadas''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao alterar comentario de EMPRESA_FORMA_TRIB - '||SQLERRM );
      END;	  
      -- 
   end if;
   --  
   commit;
   --   
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #75193 - Adicionar campo EMPRESA_FORMA_TRIB.PERC_RED_IR
-------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #74016 - Criar DT_EXE_SERV no conhecimento de transporte
-------------------------------------------------------------------------------------------------------------------------------
 
declare
  vn_qtde    number;
begin
  begin
     select count(1)
       into vn_qtde 
       from all_tab_columns a
      where a.OWNER = 'CSF_OWN'  
        and a.TABLE_NAME = 'CONHEC_TRANSP'
        and a.COLUMN_NAME = 'DT_EXE_SERV'; 
   exception
      when others then
         vn_qtde := 0;
   end;	
   --   
   if vn_qtde = 0 then
      -- Add/modify columns    
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CONHEC_TRANSP add dt_exe_serv date';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao incluir coluna "DT_EXE_SERV" em CONHEC_TRANSP - '||SQLERRM );
      END;
      -- 
      -- Add comments to the table   
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP.dt_exe_serv is ''Data de competência ou em que serviço foi executado''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao alterar comentario de CONHEC_TRANSP - '||SQLERRM );
      END;	  
      -- 
   end if;
   --  
   vn_qtde := 0;   
   --
   begin
      select count(1)
        into vn_qtde 
        from all_tab_columns a
       where a.OWNER = 'CSF_OWN'  
         and a.TABLE_NAME = 'TMP_CONHEC_TRANSP'
         and a.COLUMN_NAME = 'DT_EXE_SERV'; 
   exception
      when others then
         vn_qtde := 0;
   end;	
   --  
   if vn_qtde = 0 then
      -- Add/modify columns    
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.TMP_CONHEC_TRANSP add dt_exe_serv date';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao incluir coluna "DT_EXE_SERV" em TMP_CONHEC_TRANSP - '||SQLERRM );
      END;
      -- 
   end if;
   -- 
   vn_qtde := 0;
   --
   begin
      select count(1)
        into vn_qtde	  
        from csf_own.obj_util_integr    ou
           , csf_own.ff_obj_util_integr ff
       where ou.obj_name         = 'VW_CSF_CONHEC_TRANSP_FF'
         and ff.objutilintegr_id = ou.id
         and ff.atributo         = 'DT_EXE_SERV';
   exception
      when others then
         vn_qtde := 0;
   end;
   --   
   if vn_qtde = 0 then 
      --
      begin
         insert into csf_own.ff_obj_util_integr( id
                                               , objutilintegr_id
                                               , atributo
                                               , descr
                                               , dm_tipo_campo
                                               , tamanho
                                               , qtde_decimal
                                               )    
                                         values( csf_own.objutilintegr_seq.nextval
                                               , (select oi.id from csf_own.obj_util_integr oi where oi.obj_name = 'VW_CSF_CONHEC_TRANSP_FF')
                                               , 'DT_EXE_SERV'
                                               , 'Data de competência ou em que serviço foi executado'
                                               , 0
                                               , 10
                                               , 0
                                               );     	  
      exception
         when dup_val_on_index then
            update csf_own.ff_obj_util_integr ff
               set ff.descr         = 'Data de competência ou em que serviço foi executado'
                 , ff.dm_tipo_campo = 0
                 , ff.tamanho       = 10
                 , ff.qtde_decimal  = 0
             where ff.objutilintegr_id = (select oi.id from csf_own.obj_util_integr oi where oi.obj_name = 'VW_CSF_CONHEC_TRANSP_FF')
               and ff.atributo         = 'DT_EXE_SERV';                 			 
      end;
      --	  
   end if;
   -- 
   commit;
   --   
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #74016 - Criar DT_EXE_SERV no conhecimento de transporte
-------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------
Prompt FIM Patch 2.9.6.2 - Alteracoes no CSF_OWN
------------------------------------------------------------------------------------------
