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

-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #73063 - Alterações para emissão de conhecimento de transporte.
-------------------------------------------------------------------------------------------------------------------------------
 
declare
  vn_qtde    number;
begin
  --
  begin
     select count(1)
       into vn_qtde
       from all_tables t
      where t.OWNER = 'CSF_OWN'  
        and t.TABLE_NAME = 'CONHEC_TRANSP_CCE';
   exception
      when others then
         vn_qtde := 0;
   end;	
   --   
   if vn_qtde = 0 then
      -- 
      -- Create table
      --
      BEGIN
         EXECUTE IMMEDIATE 'create table CSF_OWN.CONHEC_TRANSP_CCE (id NUMBER not null, conhectransp_id NUMBER not null, dm_st_integra NUMBER(1) default 0 not null, dm_st_proc NUMBER(2) default 0 not null, id_tag_chave VARCHAR2(54), dt_hr_evento DATE not null, tipoeventosefaz_id NUMBER, correcao VARCHAR2(1000) not null, versao_leiaute VARCHAR2(20), versao_evento VARCHAR2(20), versao_cce VARCHAR2(20), versao_aplic VARCHAR2(40), cod_msg_cab  VARCHAR2(4), motivo_resp_cab VARCHAR2(4000), msgwebserv_id_cab NUMBER, cod_msg VARCHAR2(4), motivo_resp VARCHAR2(4000), msgwebserv_id NUMBER, dt_hr_reg_evento DATE, nro_protocolo NUMBER(15), usuario_id NUMBER, xml_envio BLOB, xml_retorno BLOB, xml_proc BLOB, dm_download_xml_sic NUMBER(1) default 0 not null ) tablespace CSF_DATA';		 
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar tabela de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      -- 
      commit;
      --	  
      -- Add comments to the table   
      BEGIN
         EXECUTE IMMEDIATE 'comment on table CSF_OWN.CONHEC_TRANSP_CCE is ''Tabela de CC-e vinculada ao conhecimento de transporte''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      -- 
      -- Add comments to the columns
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.conhectransp_id is ''ID relacionado a tabela CONHEC_TRANSP''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.dm_st_integra is ''Situação de Integração: 0 - Indefinido, 2 - Integrado via arquivo texto (IN), 7 - Integração por view de banco de dados, 8 - Inserida a resposta do CTe para o ERP, 9 - Atualizada a resposta do CTe para o ERP''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.dm_st_proc is ''Situação: 0-Não Validado; 1-Validado; 2-Aguardando Envio; 3-Processado; 4-Erro de validação; 5-Rejeitada''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.id_tag_chave is ''Identificador da TAG a ser assinada, a regra de formação do Id é: ID + tpEvento + chave do CT-e + nSeqEvento''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.dt_hr_evento is ''Data e hora do evento no formato''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.tipoeventosefaz_id is ''ID relacionado a tabela TIPO_EVENTO_SEFAZ''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.correcao is ''Correção a ser considerada, texto livre. A correção mais recente substitui as anteriores''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.versao_leiaute is ''Versão do leiaute do evento''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.versao_evento is ''Versão do evento''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.versao_cce is ''Versão da carta de correção''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.versao_aplic is ''Versão da aplicação que processou o evento''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.cod_msg_cab is ''Código do status da resposta Cabeçalho''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.motivo_resp_cab is ''Descrição do status da resposta Cabeçalho''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.msgwebserv_id_cab is ''ID relacionado a tabela MSG_WEB_SERV para cabeçalho do retorno''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.cod_msg is ''Código do status da resposta''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.motivo_resp is ''Descrição do status da resposta''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.msgwebserv_id is ''ID relacionado a tabela MSG_WEB_SERV''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.dt_hr_reg_evento is ''Data e hora de registro do evento no formato''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.nro_protocolo is ''Número do Protocolo do Evento da CC-e''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.usuario_id is ''ID relacionado a tabela NEO_USUARIO''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.xml_envio is ''XML de envio da CCe''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.xml_retorno is ''XML de retorno da CCe''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.xml_proc is ''XML de processado da CCe''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CONHEC_TRANSP_CCE.dm_download_xml_sic is ''Donwload XML pelo SIC: 0-Não; 1-Sim''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;	  
      --
      -- Create/Recreate primary, unique and foreign key constraints
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CONHECTRANSPCCE_PK primary key (ID) using index tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar primary de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CTCCE_MSGWEBSERV_CAB_FK foreign key (MSGWEBSERV_ID_CAB) references CSF_OWN.MSG_WEBSERV (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign key de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CTCCE_MSGWEBSERV_FK foreign key (MSGWEBSERV_ID) references CSF_OWN.MSG_WEBSERV (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign key de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CTCCE_CONHECTRANSP_FK foreign key (CONHECTRANSP_ID) references CSF_OWN.CONHEC_TRANSP (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign key de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CTCCE_TIPOEVENTOSEFAZ_FK foreign key (TIPOEVENTOSEFAZ_ID) references CSF_OWN.TIPO_EVENTO_SEFAZ (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign key de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CONHECTRANSPCCE_USUARIO_FK foreign key (USUARIO_ID) references CSF_OWN.NEO_USUARIO (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign key de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --
      -- Create/Recreate indexes 	  
      BEGIN
         EXECUTE IMMEDIATE 'create index CTCCE_MSGWEBSERV_CAB_FK_I on CSF_OWN.CONHEC_TRANSP_CCE (MSGWEBSERV_ID_CAB) tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar index de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'create index CTCCE_MSGWEBSERV_FK_I on CSF_OWN.CONHEC_TRANSP_CCE (MSGWEBSERV_ID) tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar index de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --		  
      BEGIN
         EXECUTE IMMEDIATE 'create index CTCCE_CONHECTRANSP_FK_I on CSF_OWN.CONHEC_TRANSP_CCE (CONHECTRANSP_ID) tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar index de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'create index CTCCE_TIPOEVENTOSEFAZ_FK_I on CSF_OWN.CONHEC_TRANSP_CCE (TIPOEVENTOSEFAZ_ID) tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar index de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'create index CONHECTRANSPCCE_USUARIO_FK_I on CSF_OWN.CONHEC_TRANSP_CCE (USUARIO_ID) tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar index de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --
      -- Create/Recreate check constraints 	  
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CTCCE_STPROC_CK check (DM_ST_PROC in (0, 1, 2, 3, 4, 5))';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar check constraints de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CONHEC_TRANSP_CCE add constraint CTCCE_DMSTINTEGRA_CK check (dm_st_integra IN (0,2,7,8,9))';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar check constraints de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --
      -- Grant/Revoke object privileges	
      BEGIN
         EXECUTE IMMEDIATE 'grant select, insert, update, delete on CSF_OWN.CONHEC_TRANSP_CCE to CSF_WORK';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar check constraints de CONHEC_TRANSP_CCE - '||SQLERRM );
      END;
      --
   end if;
   --  
   vn_qtde := 0;   
   --
   begin   
      select count(1)
        into vn_qtde 
        from all_sequences s
       where s.SEQUENCE_OWNER = 'CSF_OWN'
         and s.SEQUENCE_NAME  = 'CONHECTRANSPCCE_SEQ';   
   exception
      when others then
         vn_qtde := 0;		 
   end;
   --  
   if vn_qtde = 0 then 
      --
      BEGIN
         -- Create sequence
         EXECUTE IMMEDIATE 'create sequence CSF_OWN.CONHECTRANSPCCE_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar sequence de CONHECTRANSPCCE_SEQ - '||SQLERRM );
      END;
      --	  
   end if;
   --  
   commit;
   --   
end;
/

begin
   --
   begin
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CONHEC_TRANSP_CCE.DM_ST_INTEGRA'
                                  , '0'
                                  , 'Indefinido'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Indefinido'           
          where dominio = 'CONHEC_TRANSP_CCE.DM_ST_INTEGRA'
            and vl = '0';
   end;		
   --
   begin
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CONHEC_TRANSP_CCE.DM_ST_INTEGRA'
                                  , '2'
                                  , 'Integrado via arquivo texto (IN)'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Integrado via arquivo texto (IN)'           
          where dominio = 'CONHEC_TRANSP_CCE.DM_ST_INTEGRA'
            and vl = '2';
   end;		
   --
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CONHEC_TRANSP_CCE.DM_ST_INTEGRA'
                                  , '7'
                                  , 'Integração por view de banco de dados'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Integração por view de banco de dados'           
          where dominio = 'CONHEC_TRANSP_CCE.DM_ST_INTEGRA'
            and vl = '7';
   end;		
   --   
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CONHEC_TRANSP_CCE.DM_ST_INTEGRA'
                                  , '8'
                                  , 'Inserida a resposta do CTe para o ERP'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Inserida a resposta do CTe para o ERP'           
          where dominio = 'CONHEC_TRANSP_CCE.DM_ST_INTEGRA'
            and vl = '8';
   end;		
   --   
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CONHEC_TRANSP_CCE.DM_ST_INTEGRA'
                                  , '9'
                                  , 'Atualizada a resposta do CTe para o ERP'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Atualizada a resposta do CTe para o ERP'           
          where dominio = 'CONHEC_TRANSP_CCE.DM_ST_INTEGRA'
            and vl = '9';
   end;		
   --  
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CONHEC_TRANSP_CCE.DM_ST_PROC'
                                  , '0'
                                  , 'Não Validado'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Não Validado'           
          where dominio = 'CONHEC_TRANSP_CCE.DM_ST_PROC'
            and vl = '0';
   end;	
   --   
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CONHEC_TRANSP_CCE.DM_ST_PROC'
                                  , '1'
                                  , 'Validado'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Validado'           
          where dominio = 'CONHEC_TRANSP_CCE.DM_ST_PROC'
            and vl = '1';
   end;
   --   
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CONHEC_TRANSP_CCE.DM_ST_PROC'
                                  , '2'
                                  , 'Aguardando Envio'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Aguardando Envio'           
          where dominio = 'CONHEC_TRANSP_CCE.DM_ST_PROC'
            and vl = '2';
   end;
   --   
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CONHEC_TRANSP_CCE.DM_ST_PROC'
                                  , '3'
                                  , 'Processado'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Processado'           
          where dominio = 'CONHEC_TRANSP_CCE.DM_ST_PROC'
            and vl = '3';
   end;   
   --   
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CONHEC_TRANSP_CCE.DM_ST_PROC'
                                  , '4'
                                  , 'Erro de validação'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Erro de validação'           
          where dominio = 'CONHEC_TRANSP_CCE.DM_ST_PROC'
            and vl = '4';
   end;    
   --   
   begin   
      insert into csf_own.dominio ( dominio
                                  , vl
                                  , descr
                                  , id
                                  )
                           values ( 'CONHEC_TRANSP_CCE.DM_ST_PROC'
                                  , '5'
                                  , 'Rejeitada'
                                  , csf_own.dominio_seq.nextval);
   exception
      when others then
         update csf_own.dominio
            set descr = 'Rejeitada'           
          where dominio = 'CONHEC_TRANSP_CCE.DM_ST_PROC'
            and vl = '5';
   end;   
   --
   commit;
   --     
end;
/

declare
  vn_qtde    number;
begin
  --
  begin
     select count(1)
       into vn_qtde
       from all_tab_columns c
      where c.OWNER       = 'CSF_OWN'
        and c.TABLE_NAME  = 'INUTILIZA_CONHEC_TRANSP'
        and c.COLUMN_NAME = 'ID_INUT' 
        and c.NULLABLE    = 'N';
   exception
      when others then
         vn_qtde := 0;
   end;	
   --   
   if vn_qtde = 1 then
      -- 
	  -- Add/modify columns 
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.INUTILIZA_CONHEC_TRANSP modify id_inut null';		 
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro alterar coluna ID_INUT de INUTILIZA_CONHEC_TRANSP - '||SQLERRM );
      END;	  
      -- 
      commit;
      --	  
   end if;
   --  
end;
/

begin
   --
   begin  
     insert into csf_own.tipo_obj_integr( id
                                        , objintegr_id
                                        , cd
                                        , descr )
                                 values ( tipoobjintegr_seq.nextval
                                        , (select o.id from csf_own.obj_integr o where o.cd = '4')
                                        , '4'
                                        , 'Inutilização de Emissão Própria de Conhec. de Transporte'
                                        );       
   exception
     when others then
       update csf_own.tipo_obj_integr
          set descr = 'Inutilização de Emissão Própria de Conhec. de Transporte'
        where objintegr_id in (select o.id from csf_own.obj_integr o where o.cd = '4')
          and cd           = '4';       
   end; 
   --  
   begin  
     insert into csf_own.tipo_obj_integr( id
                                        , objintegr_id
                                        , cd
                                        , descr )
                                 values ( tipoobjintegr_seq.nextval
                                        , (select o.id from csf_own.obj_integr o where o.cd = '4')
                                        , '5'
                                        , 'Carta de Correção Emissão Própria de Conhec. de Transporte'
                                        );       
   exception
     when others then
       update csf_own.tipo_obj_integr
          set descr = 'Carta de Correção Emissão Própria de Conhec. de Transporte'
        where objintegr_id in (select o.id from csf_own.obj_integr o where o.cd = '4')
          and cd           = '5';       
   end; 
   -- 
   commit;
   --   
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine Redmine #73063 - Alterações para emissão de conhecimento de transporte.
--------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #74444 - Pontos de correção no processo de Apuração do IRPJ e CSLL
-------------------------------------------------------------------------------------------------------------------------------
declare
   vn_modulo_id number := 0;
   vn_grupo_id number := 0;
   vn_param_id number := 0;
   vn_usuario_id number := null;
begin

-- MODULO DO SISTEMA --
   begin
      select ms.id
        into vn_modulo_id
        from CSF_OWN.MODULO_SISTEMA ms
       where ms.cod_modulo = 'CONTABIL';
   exception
      when no_data_found then
         vn_modulo_id := 0;
      when others then
         goto SAIR_SCRIPT;
   end;
   --
   if vn_modulo_id = 0 then
      --
      insert into CSF_OWN.MODULO_SISTEMA
      values(CSF_OWN.MODULOSISTEMA_SEQ.NEXTVAL, 'CONTABIL', 'Obrigações Contábeis ECD e ECF', 'Módulo com parametros referentes as obrigações contabeis ECD E ECF (Sped Contábil e Sped ECF)')
      returning id into vn_modulo_id;
      --
   end if;
   --
   -- GRUPO DO SISTEMA --
   begin
      select gs.id
        into vn_grupo_id
        from CSF_OWN.GRUPO_SISTEMA gs
       where gs.modulo_id = vn_modulo_id
         and gs.cod_grupo = 'ECF';
   exception
      when no_data_found then
         vn_grupo_id := 0;
      when others then
         goto SAIR_SCRIPT;
   end;
   --
   if vn_grupo_id = 0 then
      --
      insert into CSF_OWN.GRUPO_SISTEMA
      values(CSF_OWN.GRUPOSISTEMA_SEQ.NextVal, vn_modulo_id, 'ECF', 'PARAMETROS UTILIZADOS NA ECF', 'GRUPO COM INFORMAÇÕES DE PARAMETROS UTILIZADOS NA ECF')
      returning id into vn_grupo_id;
      --
   end if;
   --
   -- PARAMETRO DO SISTEMA --
   for x in (select * from CSF_OWN.EMPRESA m where m.dm_situacao = 1)
   loop
      begin
         select pgs.id
           into vn_param_id
           from CSF_OWN.PARAM_GERAL_SISTEMA pgs  -- UK: MULTORG_ID, EMPRESA_ID, MODULO_ID, GRUPO_ID, PARAM_NAME
          where pgs.Empresa_Id = x.Id
            and pgs.modulo_id  = vn_modulo_id
            and pgs.grupo_id   = vn_grupo_id
            and pgs.param_name = 'APUR_IR_CSLL_PARC_MENSAL';
      exception
         when no_data_found then
            vn_param_id := 0;
         when others then
            goto SAIR_SCRIPT;
      end;
      --
      --
      if vn_param_id = 0 then
         --
         -- Busca o usuário respondável pelo Mult_org
         begin
            select id
              into vn_usuario_id
              from CSF_OWN.NEO_USUARIO nu
             where upper(nu.login) = 'ADMIN';
         exception
            when no_data_found then
               begin
                  select min(id)
                    into vn_usuario_id
                    from CSF_OWN.NEO_USUARIO nu
                   where nu.Multorg_Id = x.MULTORG_ID;
               exception
                  when others then
                     goto SAIR_SCRIPT;
               end;
         end;
         --
         insert into CSF_OWN.PARAM_GERAL_SISTEMA( id
                                                , multorg_id
                                                , empresa_id
                                                , modulo_id
                                                , grupo_id
                                                , param_name
                                                , dsc_param
                                                , vlr_param
                                                , usuario_id_alt
                                                , dt_alteracao )
         values( CSF_OWN.PARAMGERALSISTEMA_SEQ.NextVal
               , X.MULTORG_ID
               , X.ID
               , vn_modulo_id
               , vn_grupo_id
               , 'APUR_IR_CSLL_PARC_MENSAL'
               , 'Realiza apuração parcial do IR e CSLL somente do mês e não acumulado.  Valores possíveis: N = Padrão / S = Recupera os dados de forma parcial'
               , 'N'
               , vn_usuario_id
               , sysdate);
         --
      end if;
      --
   end loop;
   --
   commit;
   --
   <<SAIR_SCRIPT>>
   rollback;
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #74444 - Pontos de correção no processo de Apuração do IRPJ e CSLL
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
