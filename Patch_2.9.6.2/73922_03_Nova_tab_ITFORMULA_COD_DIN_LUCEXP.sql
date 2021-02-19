-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #73284 - Estrutura de tabelas - ITFORMULA_COD_DIN_LUCEXP
-------------------------------------------------------------------------------------------------------------------------------

declare
  vn_qtde    number;
begin
  begin
     select count(1)
       into vn_qtde
       from all_tables t
      where t.OWNER = 'CSF_OWN'  
        and t.TABLE_NAME = 'ITFORMULA_COD_DIN_LUCEXP';
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
         EXECUTE IMMEDIATE 'create table CSF_OWN.ITFORMULA_COD_DIN_LUCEXP ( id number not null
                                                                          , formulacoddinlucexp_id number not null
                                                                          , coddinlucrexpl_id number not null
                                                                          ) tablespace CSF_DATA';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar tabela de ITFORMULA_COD_DIN_LUCEXP - '||SQLERRM );
      END;	  
      -- 
      commit;
      --	  
      -- Add comments to the table   
      BEGIN
         EXECUTE IMMEDIATE 'comment on table CSF_OWN.ITFORMULA_COD_DIN_LUCEXP is ''Tabela de itens das formulas do cadastro de códigos dinamicos que formarão a apuração de lucro da exploração, campo tipo formula''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de ITFORMULA_COD_DIN_LUCEXP - '||SQLERRM );
      END;	  
      -- 
      -- Add comments to the columns	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.ITFORMULA_COD_DIN_LUCEXP.id is ''Identificador único do registro na tabela''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de ITFORMULA_COD_DIN_LUCEXP - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.ITFORMULA_COD_DIN_LUCEXP.formulacoddinlucexp_id is ''Relacionado ao ID da tabela formula_cod_din_lucexp''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de ITFORMULA_COD_DIN_LUCEXP - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.ITFORMULA_COD_DIN_LUCEXP.coddinlucrexpl_id is ''Relacionado ao ID da tabela cod_din_lucr_expl''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de ITFORMULA_COD_DIN_LUCEXP - '||SQLERRM );
      END;	  
      --
      -- Create/Recreate primary, unique and foreign key constraints
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.ITFORMULA_COD_DIN_LUCEXP add constraint ITFORMULACODDINLUCEXP_PK primary key (ID) using index tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar primary de ITFORMULA_COD_DIN_LUCEXP - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.ITFORMULA_COD_DIN_LUCEXP add constraint ITFORMUCDINLUE_FORMUCDINLUE_FK foreign key (FORMULACODDINLUCEXP_ID) references CSF_OWN.formula_cod_din_lucexp (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de ITFORMULA_COD_DIN_LUCEXP - '||SQLERRM );
      END;
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.ITFORMULA_COD_DIN_LUCEXP  add constraint ITFORMUCDINLUE_CODDINLUCEXP_FK foreign key (CODDINLUCREXPL_ID) references CSF_OWN.COD_DIN_LUCR_EXPL (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de ITFORMULA_COD_DIN_LUCEXP - '||SQLERRM );
      END;
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.ITFORMULA_COD_DIN_LUCEXP add constraint ITFORMULACODDINLUCEXP_UK1 unique (FORMULACODDINLUCEXP_ID, CODDINLUCREXPL_ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar unique de ITFORMULA_COD_DIN_LUCEXP - '||SQLERRM );
      END;
      --	  
      -- Grant/Revoke object privileges	
      BEGIN
         EXECUTE IMMEDIATE 'grant select, insert, update, delete on CSF_OWN.ITFORMULA_COD_DIN_LUCEXP to CSF_WORK';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar Grant para CSF_WORK de ITFORMULA_COD_DIN_LUCEXP - '||SQLERRM );
      END;
      --
      begin
         execute immediate 'grant all on CSF_OWN.ITFORMULA_COD_DIN_LUCEXP to CONSULTORIA';
      exception
          when others then
             null;
      end;   
      --
      begin
         execute immediate 'grant all on CSF_OWN.ITFORMULA_COD_DIN_LUCEXP to DESENV_USER';
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
         and s.SEQUENCE_NAME  = 'ITFORMULACODDINLUCEXP_SEQ';   
   exception
      when others then
         vn_qtde := 0;		 
   end;
   --  
   if vn_qtde = 0 then 
      --
      BEGIN
         -- Create sequence
         EXECUTE IMMEDIATE 'create sequence CSF_OWN.ITFORMULACODDINLUCEXP_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar sequence de ITFORMULACODDINLUCEXP_SEQ - '||SQLERRM );
      END;
      --	  
   end if;
   --  
   commit;
   --   
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #73284 - Estrutura de tabelas - ITFORMULA_COD_DIN_LUCEXP
--------------------------------------------------------------------------------------------------------------------------------------
