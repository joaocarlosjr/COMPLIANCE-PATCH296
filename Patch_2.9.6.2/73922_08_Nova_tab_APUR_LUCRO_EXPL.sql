-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #73922 - Estrutura de tabelas - APUR_LUCRO_EXPL
-------------------------------------------------------------------------------------------------------------------------------
 
declare
  vn_qtde    number;
begin
  begin
     select count(1)
       into vn_qtde
       from all_tables t
      where t.OWNER = 'CSF_OWN'  
        and t.TABLE_NAME = 'APUR_LUCRO_EXPL';
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
         EXECUTE IMMEDIATE 'create table CSF_OWN.APUR_LUCRO_EXPL ( id number not null
                                                                 , perlucrexpl_id number not null
                                                                 , coddinlucrexpl_id number not null
                                                                 , valor number(15,2)
                                                                 ) tablespace CSF_DATA';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar tabela de APUR_LUCRO_EXPL - '||SQLERRM );
      END;	  
      -- 
      commit;
      --	  
      -- Add comments to the table   
      BEGIN
         EXECUTE IMMEDIATE 'comment on table CSF_OWN.APUR_LUCRO_EXPL is ''Tabela que demonstra apuração de lucro da exploração''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de APUR_LUCRO_EXPL - '||SQLERRM );
      END;	  
      -- 
      -- Add comments to the columns	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.APUR_LUCRO_EXPL.id is ''Identificador único do registro na tabela''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de APUR_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.APUR_LUCRO_EXPL.perlucrexpl_id is ''ID relacionado ao periodo de apuração da tabela PER_LUCR_EXPL''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de APUR_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.APUR_LUCRO_EXPL.coddinlucrexpl_id is ''ID relacionado a tabela COD_DIN_LUCR_EXPL que demonstra código dinamico de apuração''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de APUR_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.APUR_LUCRO_EXPL.valor is ''Valor apurado para linha''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de APUR_LUCRO_EXPL - '||SQLERRM );
      END;	  
      -- Create/Recreate primary, unique and foreign key constraints
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.APUR_LUCRO_EXPL add constraint APURLUCROEXPL_PK primary key (ID) using index tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar primary de PER_LUCR_EXPL - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.APUR_LUCRO_EXPL add constraint APURLUCROEXPL_PERLUCREXPL_FK foreign key (PERLUCREXPL_ID) references CSF_OWN.per_lucr_expl (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de APUR_LUCRO_EXPL - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.APUR_LUCRO_EXPL add constraint APURLUCROEXP_CODDINLUCREXPL_FK foreign key (CODDINLUCREXPL_ID) references CSF_OWN.cod_din_lucr_expl (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de APUR_LUCRO_EXPL - '||SQLERRM );
      END;
      --
      -- Grant/Revoke object privileges	
      BEGIN
         EXECUTE IMMEDIATE 'grant select, insert, update, delete on CSF_OWN.APUR_LUCRO_EXPL to CSF_WORK';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar Grant para CSF_WORK de APUR_LUCRO_EXPL - '||SQLERRM );
      END;
      --  
      begin
         execute immediate 'grant all on CSF_OWN.APUR_LUCRO_EXPL to CONSULTORIA';
      exception
          when others then
             null;
      end;   
      --
      begin
         execute immediate 'grant all on CSF_OWN.APUR_LUCRO_EXPL to DESENV_USER';
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
         and s.SEQUENCE_NAME  = 'APURLUCROEXPL_SEQ';   
   exception
      when others then
         vn_qtde := 0;		 
   end;
   --  
   if vn_qtde = 0 then 
      --
      BEGIN
         -- Create sequence
         EXECUTE IMMEDIATE 'create sequence CSF_OWN.APURLUCROEXPL_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar sequence de APURLUCROEXPL_SEQ - '||SQLERRM );
      END;
      --	  
   end if; 
   --  
   commit;
   --   
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #73922 - Estrutura de tabelas - APUR_LUCRO_EXPL
--------------------------------------------------------------------------------------------------------------------------------------


