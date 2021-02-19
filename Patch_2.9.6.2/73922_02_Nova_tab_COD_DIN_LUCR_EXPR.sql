-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #73922 - Estrutura de tabelas - COD_DIN_LUCR_EXPL
-------------------------------------------------------------------------------------------------------------------------------

declare
  vn_qtde    number;
begin
  begin
     select count(1)
       into vn_qtde
       from all_tables t
      where t.OWNER = 'CSF_OWN'  
        and t.TABLE_NAME = 'COD_DIN_LUCR_EXPL';
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
         EXECUTE IMMEDIATE 'create table CSF_OWN.COD_DIN_LUCR_EXPL ( id                     number not null,
                                                                     multorg_id             number not null,
                                                                     linha                  number not null,
                                                                     cod                    varchar2(60) not null,
                                                                     descr                  varchar2(500) not null,
                                                                     dm_tipo                varchar2(1) not null,
                                                                     obs                    varchar2(500),
                                                                     dm_situacao            number not null,
                                                                     formulacoddinlucexp_id number,
                                                                     dm_estilo              number(1) not null,
                                                                     usuario_id             number,
                                                                     dt_alteracao           date,
                                                                     dm_inverte_sinal       varchar2(1) default ''N'' not null																	 
                                                                   ) tablespace CSF_DATA';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar tabela de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;	  
      -- 
      commit;
      --	  
      -- Add comments to the table   
      BEGIN
         EXECUTE IMMEDIATE 'comment on table CSF_OWN.COD_DIN_LUCR_EXPL is ''Tabela de códigos dinamicos que formarão a apuração de lucro da exploração''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;	  
      -- 
      -- Add comments to the columns	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.COD_DIN_LUCR_EXPL.id is ''Identificador único do registro na tabela''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.COD_DIN_LUCR_EXPL.multorg_id is ''Relacionado ao ID do multorg ao qual o código pertence''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.COD_DIN_LUCR_EXPL.linha is ''Numero da linha. Será utilizado como ordenação da montagem''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.COD_DIN_LUCR_EXPL.cod is ''Código de identificação do registro''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.COD_DIN_LUCR_EXPL.descr is ''Descrição detalhada do registro''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.COD_DIN_LUCR_EXPL.dm_tipo is ''Tipo de linha: R: Rótulo / E: Editavel / F: Fórmula''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.COD_DIN_LUCR_EXPL.obs is ''Texto opcional e livre para anotar observações sobre a linha''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	 	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.COD_DIN_LUCR_EXPL.dm_situacao is ''Situação do registro: 0= Inativo / 1= Ativo''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;	  
      --		  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.COD_DIN_LUCR_EXPL.formulacoddinlucexp_id is ''Relacionado ao ID de formula_cod_din_lucexp''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;	  
      --		  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.COD_DIN_LUCR_EXPL.dm_estilo is ''Estilo de como a linha será exibida em relatório: 0: Sem formatação / 1: Negrito / 2: Fundo Cinza / 3: Negrito e fundo cinza''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.COD_DIN_LUCR_EXPL.usuario_id is ''ID relacionado a NEO_USUARIO que fez a ultima alteração no registro''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.COD_DIN_LUCR_EXPL.dt_alteracao is ''Data da ultima alteração do registro''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.COD_DIN_LUCR_EXPL.dm_inverte_sinal is ''Inverte sinal apurado para campo do tipo Editavel: S: Sim / N: Não''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;	  
      -- Create/Recreate primary, unique and foreign key constraints
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.COD_DIN_LUCR_EXPL add constraint CODDINLUCREXPL_PK primary key (ID) using index tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar primary de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.COD_DIN_LUCR_EXPL add constraint CODDINLUCREXPL_UK1 unique (MULTORG_ID, LINHA, COD)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar unique de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.COD_DIN_LUCR_EXPL add constraint CODDINLUCREXPL_MULTORG_FK foreign key (MULTORG_ID) references CSF_OWN.mult_org (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.COD_DIN_LUCR_EXPL add constraint CODDINLUCEXP_FORMCDINLUCEXP_FK foreign key (FORMULACODDINLUCEXP_ID) references CSF_OWN.formula_cod_din_lucexp (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.COD_DIN_LUCR_EXPL add constraint CODDINLUCREXPL_NEOUSUARIO_FK foreign key (USUARIO_ID) references CSF_OWN.neo_usuario (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;
      --	  
      -- Create/Recreate check constraints 
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.COD_DIN_LUCR_EXPL add constraint CODDINLUCREXPL_DMTIPO_CK check (DM_TIPO IN (''R'', ''E'', ''F''))';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar check constraints de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.COD_DIN_LUCR_EXPL add constraint CODDINLUCREXPL_DMSITUACAO_CK check (DM_SITUACAO IN (0, 1))';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar check constraints de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.COD_DIN_LUCR_EXPL add constraint CODDINLUCREXPL_DMESTILO_CK check (DM_ESTILO IN (0, 1, 2, 3))';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar check constraints de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.COD_DIN_LUCR_EXPL add constraint CODDINLUCREXP_DMINVERTSINAL_CK check (DM_INVERTE_SINAL IN (''S'', ''N''))';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar check constraints de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;
      --
      --
      -- Grant/Revoke object privileges	
      BEGIN
         EXECUTE IMMEDIATE 'grant select, insert, update, delete on CSF_OWN.COD_DIN_LUCR_EXPL to CSF_WORK';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar Grant para CSF_WORK de COD_DIN_LUCR_EXPL - '||SQLERRM );
      END;
      --
      begin
         execute immediate 'grant all on CSF_OWN.COD_DIN_LUCR_EXPL to CONSULTORIA';
      exception
          when others then
             null;
      end;   
      --
      begin
         execute immediate 'grant all on CSF_OWN.COD_DIN_LUCR_EXPL to DESENV_USER';
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
         and s.SEQUENCE_NAME  = 'CODDINLUCREXPL_SEQ';   
   exception
      when others then
         vn_qtde := 0;		 
   end;
   --  
   if vn_qtde = 0 then 
      --
      BEGIN
         -- Create sequence
         EXECUTE IMMEDIATE 'create sequence CSF_OWN.CODDINLUCREXPL_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar sequence de CODDINLUCREXPL_SEQ - '||SQLERRM );
      END;
      --	  
   end if;
   --  
   commit;
   --   
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #73922 - Estrutura de tabelas - COD_DIN_LUCR_EXPL
--------------------------------------------------------------------------------------------------------------------------------------
