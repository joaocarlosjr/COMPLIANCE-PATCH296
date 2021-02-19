-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #73922 - Estrutura de tabelas - REL_CALC_LUCR_EXPLR
-------------------------------------------------------------------------------------------------------------------------------

declare
  vn_qtde    number;
begin
  begin
     select count(1)
       into vn_qtde
       from all_tables t
      where t.OWNER = 'CSF_OWN'  
        and t.TABLE_NAME = 'REL_CALC_LUCR_EXPLR';
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
         EXECUTE IMMEDIATE 'create table CSF_OWN.REL_CALC_LUCR_EXPLR ( id number not null
                                                                     , empresa_id number not null
                                                                     , dt_ini date not null
                                                                     , Dt_fim date not null
                                                                     , usuario_id number
                                                                     , dt_hr_alteracao date not null
                                                                     , descr varchar2(500)
                                                                     , dm_estilo number(1) not null																	 
                                                                     , valor number(15,2)
                                                                     ) tablespace CSF_DATA';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar tabela de REL_CALC_LUCR_EXPLR - '||SQLERRM );
      END;	  
      -- 
      commit;
      --	  
      -- Add comments to the table   
      BEGIN
         EXECUTE IMMEDIATE 'comment on table CSF_OWN.REL_CALC_LUCR_EXPLR is ''Relatório do Calculo do Lucro da Exploração''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_CALC_LUCR_EXPLR - '||SQLERRM );
      END;	  
      -- 
      -- Add comments to the columns	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_CALC_LUCR_EXPLR.id is ''Identificador único do registro na tabela''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_CALC_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_CALC_LUCR_EXPLR.empresa_id is ''ID relacionado a empresa em que o periodo foi criado''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_CALC_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_CALC_LUCR_EXPLR.dt_ini is ''Data inicial a ser considerada na apuração''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_CALC_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_CALC_LUCR_EXPLR.dt_fim is ''Data final a ser considerada na apuração''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_CALC_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_CALC_LUCR_EXPLR.usuario_id is ''ID relacionado a NEO_USUARIO que fez a ultima alteração no registro''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_CALC_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_CALC_LUCR_EXPLR.dt_hr_alteracao is ''Data da ultima alteração do registro''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_CALC_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_CALC_LUCR_EXPLR.descr is ''Texto que aparecerá na coluna descrição''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_CALC_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_CALC_LUCR_EXPLR.dm_estilo is ''Estilo de como a linha será exibida em relatório: 0: Sem formatação / 1: Negrito / 2: Fundo Cinza / 3: Negrito e fundo cinza''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_CALC_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_CALC_LUCR_EXPLR.valor is ''Valor a ser exibido no relatório''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_CALC_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --		  
      -- Create/Recreate primary, unique and foreign key constraints
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.REL_CALC_LUCR_EXPLR add constraint RELCALCLUCREXPLR_PK primary key (ID) using index tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar primary de REL_CALC_LUCR_EXPLR - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.REL_CALC_LUCR_EXPLR add constraint RELCALCLUCREXPLR_EMPRESA_FK foreign key (EMPRESA_ID) references CSF_OWN.empresa (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de REL_CALC_LUCR_EXPLR - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.REL_CALC_LUCR_EXPLR add constraint RELCALCLUCREXPLR_NEOUSUARIO_FK foreign key (USUARIO_ID) references CSF_OWN.neo_usuario (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de REL_CALC_LUCR_EXPLR - '||SQLERRM );
      END;
      --	  
      -- Create/Recreate check constraints 
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.REL_CALC_LUCR_EXPLR add constraint RELCALCLUCREXPLR_DMESTILO_CK check (DM_ESTILO IN (0, 1, 2, 3))';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar check constraints de REL_CALC_LUCR_EXPLR - '||SQLERRM );
      END;
      --	  
      -- Grant/Revoke object privileges	
      BEGIN
         EXECUTE IMMEDIATE 'grant select, insert, update, delete on CSF_OWN.REL_CALC_LUCR_EXPLR to CSF_WORK';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar Grant para CSF_WORK de REL_CALC_LUCR_EXPLR - '||SQLERRM );
      END;
      --
      begin
         execute immediate 'grant all on CSF_OWN.REL_CALC_LUCR_EXPLR to CONSULTORIA';
      exception
          when others then
             null;
      end;   
      --
      begin
         execute immediate 'grant all on CSF_OWN.REL_CALC_LUCR_EXPLR to DESENV_USER';
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
         and s.SEQUENCE_NAME  = 'RELCALCLUCREXPLR_SEQ';   
   exception
      when others then
         vn_qtde := 0;		 
   end;
   --  
   if vn_qtde = 0 then 
      --
      BEGIN
         -- Create sequence
         EXECUTE IMMEDIATE 'create sequence CSF_OWN.RELCALCLUCREXPLR_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar sequence de RELCALCLUCREXPLR_SEQ - '||SQLERRM );
      END;
      --	  
   end if;
   --  
   commit;
   --   
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #73922 - Estrutura de tabelas - REL_CALC_LUCR_EXPLR
--------------------------------------------------------------------------------------------------------------------------------------
