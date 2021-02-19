-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #73922 - Estrutura de tabelas - FORMULA_COD_DIN_LUCEXP
-------------------------------------------------------------------------------------------------------------------------------

declare
  vn_qtde    number;
begin
  begin
     select count(1)
       into vn_qtde
       from all_tables t
      where t.OWNER = 'CSF_OWN'  
        and t.TABLE_NAME = 'FORMULA_COD_DIN_LUCEXP';
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
         EXECUTE IMMEDIATE 'create table CSF_OWN.FORMULA_COD_DIN_LUCEXP( id number not null
                                                                       , descr varchar2(100) not null
                                                                       , oper_matematico varchar2(1)
                                                                       , valor_oper_matematico number(19,4)
                                                                       ) tablespace CSF_DATA';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar tabela de FORMULA_COD_DIN_LUCEXP - '||SQLERRM );
      END;	  
      -- 
      commit;
      --	  
      -- Add comments to the table   
      BEGIN
         EXECUTE IMMEDIATE 'comment on table CSF_OWN.FORMULA_COD_DIN_LUCEXP is ''Tabela p/ campo do tipo formula do cadastro de códigos dinamicos Apuração Lucro Exportação''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de FORMULA_COD_DIN_LUCEXP - '||SQLERRM );
      END;	  
      -- 
      -- Add comments to the columns	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.FORMULA_COD_DIN_LUCEXP.id is ''Identificador único do registro na tabela''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de FORMULA_COD_DIN_LUCEXP - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.FORMULA_COD_DIN_LUCEXP.descr is ''Descrição da Formula''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de FORMULA_COD_DIN_LUCEXP - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.FORMULA_COD_DIN_LUCEXP.oper_matematico is ''Operador Matemático: A-Adição / S-Subtração / M-Multiplicação / D-Divisão''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de FORMULA_COD_DIN_LUCEXP - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.FORMULA_COD_DIN_LUCEXP.valor_oper_matematico is ''Valor a ser usado com o operador matemático''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de FORMULA_COD_DIN_LUCEXP - '||SQLERRM );
      END;	  
      --
      -- Create/Recreate primary, unique and foreign key constraints
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.FORMULA_COD_DIN_LUCEXP add constraint FORMULACODDINLUCEXP_PK primary key (ID) using index tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar primary de FORMULA_COD_DIN_LUCEXP - '||SQLERRM );
      END;
      --
      -- Create/Recreate check constraints 
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.FORMULA_COD_DIN_LUCEXP add constraint FORMULACODINLUEX_OPERMATEMA_CK check (OPER_MATEMATICO IN (''A'', ''S'', ''M'', ''D''))';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar check constraints de FORMULA_COD_DIN_LUCEXP - '||SQLERRM );
      END;
      --	  
      -- Grant/Revoke object privileges	
      BEGIN
         EXECUTE IMMEDIATE 'grant select, insert, update, delete on CSF_OWN.FORMULA_COD_DIN_LUCEXP to CSF_WORK';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar Grant para CSF_WORK de FORMULA_COD_DIN_LUCEXP - '||SQLERRM );
      END;
      --
      begin
         execute immediate 'grant all on CSF_OWN.FORMULA_COD_DIN_LUCEXP to CONSULTORIA';
      exception
          when others then
             null;
      end;   
      --
      begin
         execute immediate 'grant all on CSF_OWN.FORMULA_COD_DIN_LUCEXP to DESENV_USER';
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
         and s.SEQUENCE_NAME  = 'FORMULACODDINLUCEXP_SEQ';   
   exception
      when others then
         vn_qtde := 0;		 
   end;
   --  
   if vn_qtde = 0 then 
      --
      BEGIN
         -- Create sequence
         EXECUTE IMMEDIATE 'create sequence CSF_OWN.FORMULACODDINLUCEXP_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar sequence de FORMULACODDINLUCEXP_SEQ - '||SQLERRM );
      END;
      --	  
   end if;
   --  
   commit;
   --   
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #73922 - Estrutura de tabelas - FORMULA_COD_DIN_LUCEXP
--------------------------------------------------------------------------------------------------------------------------------------
