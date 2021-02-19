-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #73922 - Estrutura de tabelas - REL_DISTR_ATV_LUCR_EXPLR
-------------------------------------------------------------------------------------------------------------------------------

declare
  vn_qtde    number;
begin
  begin
     select count(1)
       into vn_qtde
       from all_tables t
      where t.OWNER = 'CSF_OWN'  
        and t.TABLE_NAME = 'REL_DISTR_ATV_LUCR_EXPLR';
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
         EXECUTE IMMEDIATE 'create table CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR ( id number not null
                                                                          , empresa_id  number not null
                                                                          , dt_ini date not null
                                                                          , dt_fim date not null
                                                                          , usuario_id number
                                                                          , dt_hr_alteracao date not null
                                                                          , descr varchar2(500)
                                                                          , perc_reduc number(5,2)
                                                                          , rec_liquida number(15,2)
                                                                          , perc_part number(9,6)
                                                                          , lucr_expl number(15,2)
                                                                          , vl_irpj number(15,2)
                                                                          , vl_ir_adic number(15,2)
                                                                          , vl_ir_total number(15,2)
                                                                          , vl_red_benef number(15,2)
                                                                          ) tablespace CSF_DATA';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar tabela de REL_DISTR_ATV_LUCR_EXPLR - '||SQLERRM );
      END;	  
      -- 
      commit;
      --	  
      -- Add comments to the table   
      BEGIN
         EXECUTE IMMEDIATE 'comment on table CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR is ''Relatório de Distribuição por Atividade do Lucro da Exploração''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_DISTR_ATV_LUCR_EXPLR - '||SQLERRM );
      END;	  
      -- 
      -- Add comments to the columns
	        BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR.id is ''Identificador único do registro na tabela''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_DISTR_ATV_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR.empresa_id is ''ID relacionado a empresa em que o periodo foi criado''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_DISTR_ATV_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR.dt_ini is ''Data inicial a ser considerada na apuração''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_DISTR_ATV_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR.dt_fim is ''Data final a ser considerada na apuração''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_DISTR_ATV_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR.usuario_id is ''ID relacionado a NEO_USUARIO que fez a ultima alteração no registro''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_DISTR_ATV_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR.dt_hr_alteracao is ''Data da ultima alteração do registro''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_DISTR_ATV_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR.descr is ''Texto que aparecerá na coluna descrição''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_DISTR_ATV_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR.perc_reduc is ''Percentual de redução''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_DISTR_ATV_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR.rec_liquida is ''Valor da Receita Liquida''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_DISTR_ATV_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR.perc_part is ''Percentual de participação''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_DISTR_ATV_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR.lucr_expl is ''Valor do Lucro da Exploração''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_DISTR_ATV_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR.vl_irpj is ''Valor do IRPJ''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_DISTR_ATV_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR.vl_ir_adic is ''Valor do IR Adicional''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_DISTR_ATV_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR.vl_ir_total is ''Valor do IR Total''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_CALC_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --	 	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR.vl_red_benef is ''Valor de redução do beneficio''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de REL_CALC_LUCR_EXPLR - '||SQLERRM );
      END;	  
      --		  
      -- Create/Recreate primary, unique and foreign key constraints
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR add constraint RELDISTRATVLUCREXPLR_PK primary key (ID) using index tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar primary de REL_DISTR_ATV_LUCR_EXPLR - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR add constraint RELDISTRATVLUCREXPL_EMPRESA_FK foreign key (EMPRESA_ID) references CSF_OWN.empresa (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de REL_DISTR_ATV_LUCR_EXPLR - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR add constraint RELDISTRATVLUCEX_NEOUSUARIO_FK foreign key (USUARIO_ID) references CSF_OWN.neo_usuario (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de REL_DISTR_ATV_LUCR_EXPLR - '||SQLERRM );
      END;
      --	  
      -- Grant/Revoke object privileges	
      BEGIN
         EXECUTE IMMEDIATE 'grant select, insert, update, delete on CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR to CSF_WORK';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar Grant para CSF_WORK de REL_DISTR_ATV_LUCR_EXPLR - '||SQLERRM );
      END;
      --
      begin
         execute immediate 'grant all on CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR to CONSULTORIA';
      exception
          when others then
             null;
      end;   
      --
      begin
         execute immediate 'grant all on CSF_OWN.REL_DISTR_ATV_LUCR_EXPLR to DESENV_USER';
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
         and s.SEQUENCE_NAME  = 'RELDISTRATVLUCREXPLR_SEQ';   
   exception
      when others then
         vn_qtde := 0;		 
   end;
   --  
   if vn_qtde = 0 then 
      --
      BEGIN
         -- Create sequence
         EXECUTE IMMEDIATE 'create sequence CSF_OWN.RELDISTRATVLUCREXPLR_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar sequence de RELDISTRATVLUCREXPLR_SEQ - '||SQLERRM );
      END;
      --	  
   end if;
   --  
   commit;
   --   
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #73922 - Estrutura de tabelas - REL_DISTR_ATV_LUCR_EXPLR
--------------------------------------------------------------------------------------------------------------------------------------
