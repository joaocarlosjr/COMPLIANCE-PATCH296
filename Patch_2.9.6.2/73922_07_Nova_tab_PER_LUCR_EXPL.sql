-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #73922 - Estrutura de tabelas - PER_LUCR_EXPL
-------------------------------------------------------------------------------------------------------------------------------

declare
  vn_qtde    number;
begin
  begin
     select count(1)
       into vn_qtde
       from all_tables t
      where t.OWNER = 'CSF_OWN'  
        and t.TABLE_NAME = 'PER_LUCR_EXPL';
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
         EXECUTE IMMEDIATE 'create table CSF_OWN.PER_LUCR_EXPL ( id number not null
                                                               , empresa_id number not null
                                                               , dt_ini date not null
                                                               , dt_fim date not null
                                                               , dm_situacao number not null
                                                               , usuario_id number
                                                               , dt_alteracao date
                                                               ) tablespace CSF_DATA';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar tabela de PER_LUCR_EXPL - '||SQLERRM );
      END;	  
      -- 
      commit;
      --	  
      -- Add comments to the table   
      BEGIN
         EXECUTE IMMEDIATE 'comment on table CSF_OWN.PER_LUCR_EXPL is ''Definição de periodo de apuração do lucro da exploração''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PER_LUCR_EXPL - '||SQLERRM );
      END;	  
      -- 
      -- Add comments to the columns	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PER_LUCR_EXPL.id is ''Identificador único do registro na tabela''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PER_LUCR_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PER_LUCR_EXPL.empresa_id is ''ID relacionado a empresa em que o periodo foi criado''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PER_LUCR_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PER_LUCR_EXPL.dt_ini is ''Data inicial a ser considerada na apuração''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PER_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PER_LUCR_EXPL.dt_fim is ''Data final a ser considerada na apuração''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PER_LUCR_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PER_LUCR_EXPL.dm_situacao is ''Situação atual do registro: 0= Aberto / 1= Calculo em andamento / 2= Calculado / 3= Finalizado / 4= Erro de calculo''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PER_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PER_LUCR_EXPL.usuario_id is ''ID relacionado a NEO_USUARIO que fez a ultima alteração na apuração do registro''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PER_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PER_LUCR_EXPL.dt_alteracao is ''Data da ultima alteração na apuração do registro''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PER_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	
      -- Create/Recreate primary, unique and foreign key constraints
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.PER_LUCR_EXPL add constraint PERLUCREXPL_PK primary key (ID) using index tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar primary de PER_LUCR_EXPL - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.PER_LUCR_EXPL add constraint PERLUCREXPL_UK1 unique (EMPRESA_ID, DT_INI, DT_FIM)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar unique de PER_LUCR_EXPL - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.PER_LUCR_EXPL add constraint PERLUCREXPL_EMPRESA foreign key (EMPRESA_ID) references CSF_OWN.empresa (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de PER_LUCR_EXPL - '||SQLERRM );
      END;
      --
	        BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.PER_LUCR_EXPL add constraint PERLUCREXPL_NEOUSUARIO foreign key (USUARIO_ID) references CSF_OWN.neo_usuario (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de PER_LUCR_EXPL - '||SQLERRM );
      END;
      --
      -- Create/Recreate check constraints 
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.PER_LUCR_EXPL add constraint PERLUCREXPL_DMSITUACAO_CK check (DM_SITUACAO IN (0, 1, 2, 3, 4))';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar check constraints de PER_LUCR_EXPL - '||SQLERRM );
      END;
      --	  
      -- Grant/Revoke object privileges	
      BEGIN
         EXECUTE IMMEDIATE 'grant select, insert, update, delete on CSF_OWN.PER_LUCR_EXPL to CSF_WORK';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar Grant para CSF_WORK de PER_LUCR_EXPL - '||SQLERRM );
      END;
      --  
      begin
         execute immediate 'grant all on CSF_OWN.PER_LUCR_EXPL to CONSULTORIA';
      exception
          when others then
             null;
      end;   
      --
      begin
         execute immediate 'grant all on CSF_OWN.PER_LUCR_EXPL to DESENV_USER';
      exception
         when others then
            null;
      end; 
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
         and s.SEQUENCE_NAME  = 'PERLUCREXPL_SEQ';   
   exception
      when others then
         vn_qtde := 0;		 
   end;
   --  
   if vn_qtde = 0 then 
      --
      BEGIN
         -- Create sequence
         EXECUTE IMMEDIATE 'create sequence CSF_OWN.PERLUCREXPL_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar sequence de PERLUCREXPL_SEQ - '||SQLERRM );
      END;
      --	  
   end if; 
   --  
   commit;
   --   
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #73922 - Estrutura de tabelas - PER_LUCR_EXPL
--------------------------------------------------------------------------------------------------------------------------------------


