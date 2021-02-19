-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #73922 - Estrutura de tabelas - PARAM_REC_LUCR_EXPL
-------------------------------------------------------------------------------------------------------------------------------
 
declare
  vn_qtde    number;
begin
  begin
     select count(1)
       into vn_qtde
       from all_tables t
      where t.OWNER = 'CSF_OWN'  
        and t.TABLE_NAME = 'PARAM_REC_LUCR_EXPL';
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
         EXECUTE IMMEDIATE 'create table CSF_OWN.PARAM_REC_LUCR_EXPL( id number not null
                                                                    , empresa_id number not null
                                                                    , modfiscal_id number not null
                                                                    , cfop_id number not null
                                                                    , tiposervico_id number not null
                                                                    , natoper_id number not null
                                                                    , dm_rec_incent number default 0 not null
                                                                    , obs varchar2(500) not null
                                                                    , dm_situacao number not null
                                                                    , usuario_id number
                                                                    , dt_alteracao date
                                                                    ) tablespace CSF_DATA';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar tabela de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;	  
      -- 
      commit;
      --	  
      -- Add comments to the table   
      BEGIN
         EXECUTE IMMEDIATE 'comment on table CSF_OWN.PARAM_REC_LUCR_EXPL is ''Parametro de receita para apuração de lucro da exploração''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;	  
      -- 
      -- Add comments to the columns	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PARAM_REC_LUCR_EXPL.id is ''Identificador único do registro na tabela''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PARAM_REC_LUCR_EXPL.empresa_id is ''ID relacionado a empresa em que a parametrização foi feita''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PARAM_REC_LUCR_EXPL.modfiscal_id is ''ID relacionado a tabela MOD_FISCAL que determina o modelo do documento fiscal''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PARAM_REC_LUCR_EXPL.cfop_id is ''ID relacionado a tabela CFOP''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PARAM_REC_LUCR_EXPL.tiposervico_id is ''ID relacionado a tabela TIPO_SERVICO que determina o código nacional do serviço conforme LC116''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PARAM_REC_LUCR_EXPL.natoper_id is ''ID relacionado a tabela NAT_OPER que determina a natureza de operação conforme cadastro do cliente''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PARAM_REC_LUCR_EXPL.dm_rec_incent is ''Indica se a receita é incentivada e fará parte do calculo do beneficio de redução de IR. Valores: 0= Não / 1= Sim''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PARAM_REC_LUCR_EXPL.obs is ''Texto opcional e livre para anotar observações sobre a linha''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PARAM_REC_LUCR_EXPL.dm_situacao is ''Situação do registro: 0= Inativo / 1= Ativo''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PARAM_REC_LUCR_EXPL.usuario_id is ''ID relacionado a NEO_USUARIO que fez a ultima alteração no registro''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PARAM_REC_LUCR_EXPL.dt_alteracao is ''Data da ultima alteração do registro''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	
      -- Create/Recreate primary, unique and foreign key constraints
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.PARAM_REC_LUCR_EXPL add constraint PARAMRECLUCREXPL_PK primary key (ID) using index tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar primary de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.PARAM_REC_LUCR_EXPL add constraint PARAMRECLUCREXPL_UK1 unique (EMPRESA_ID, MODFISCAL_ID, CFOP_ID, TIPOSERVICO_ID, NATOPER_ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar unique de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.PARAM_REC_LUCR_EXPL add constraint PARAMRECLUCREXPL_EMPRESA_FK foreign key (EMPRESA_ID) references CSF_OWN.empresa (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.PARAM_REC_LUCR_EXPL add constraint PARAMRECLUCREXPL_MODFISCAL_FK foreign key (MODFISCAL_ID) references CSF_OWN.mod_fiscal (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.PARAM_REC_LUCR_EXPL add constraint PARAMRECLUCREXPL_CFOP_FK foreign key (CFOP_ID) references CSF_OWN.cfop (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;	    
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.PARAM_REC_LUCR_EXPL add constraint PARAMRECLUCREXPL_TIPOSERVIC_FK foreign key (TIPOSERVICO_ID) references CSF_OWN.tipo_servico (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;	    
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.PARAM_REC_LUCR_EXPL add constraint PARAMRECLUCREXPL_NATOPER_FK foreign key (NATOPER_ID) references CSF_OWN.nat_oper (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;	    
      --
      -- Create/Recreate check constraints 
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.PARAM_REC_LUCR_EXPL add constraint PARAMRECLUCREXP_DMRECINCENT_CK check (DM_REC_INCENT IN (0, 1))';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar check constraints de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.PARAM_REC_LUCR_EXPL add constraint PARAMRECLUCREXP_DMSITUACAO_CK check (DM_SITUACAO IN (0,1))';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar check constraints de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;
      --
      -- Grant/Revoke object privileges	
      BEGIN
         EXECUTE IMMEDIATE 'grant select, insert, update, delete on CSF_OWN.PARAM_REC_LUCR_EXPL to CSF_WORK';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar Grant para CSF_WORK de PARAM_REC_LUCR_EXPL - '||SQLERRM );
      END;
      --  
      begin
         execute immediate 'grant all on CSF_OWN.PARAM_REC_LUCR_EXPL to CONSULTORIA';
      exception
          when others then
             null;
      end;   
      --
      begin
         execute immediate 'grant all on CSF_OWN.PARAM_REC_LUCR_EXPL to DESENV_USER';
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
         and s.SEQUENCE_NAME  = 'PARAMRECLUCREXPL_SEQ';   
   exception
      when others then
         vn_qtde := 0;		 
   end;
   --  
   if vn_qtde = 0 then 
      --
      BEGIN
         -- Create sequence
         EXECUTE IMMEDIATE 'create sequence CSF_OWN.PARAMRECLUCREXPL_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar sequence de PARAMRECLUCREXPL_SEQ - '||SQLERRM );
      END;
      --	  
   end if; 
   --  
   commit;
   --   
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #73922 - Estrutura de tabelas - PARAM_REC_LUCR_EXPL
--------------------------------------------------------------------------------------------------------------------------------------
