-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #73922 - Estrutura de tabelas - CRIT_PESQ_LCTO_LUCR_EXPL
-------------------------------------------------------------------------------------------------------------------------------
 
declare
  vn_qtde    number;
begin
  begin
     select count(1)
       into vn_qtde
       from all_tables t
      where t.OWNER = 'CSF_OWN'  
        and t.TABLE_NAME = 'CRIT_PESQ_LCTO_LUCR_EXPL';
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
         EXECUTE IMMEDIATE 'create table CSF_OWN.CRIT_PESQ_LCTO_LUCR_EXPL ( id number not null
		                                                                  , paramdpcoddinctale_id number not null
                                                                          , dm_ind_lcto varchar2(1) not null
                                                                          , dm_tipo_vlr_calc varchar2(1) not null
																		  , num_arq varchar2(255)
																		  , compl_hist varchar2(500) 
                                                                          ) tablespace CSF_DATA';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar tabela de CRIT_PESQ_LCTO_LUCR_EXPL - '||SQLERRM );
      END;	  
      -- 
      commit;
      --	  
      -- Add comments to the table   
      BEGIN
         EXECUTE IMMEDIATE 'comment on table CSF_OWN.CRIT_PESQ_LCTO_LUCR_EXPL is ''Critério de pesquisa na tabela de lançamento e partida contabil para montagem da apuração do lucro da exploração''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CRIT_PESQ_LCTO_LUCR_EXPL - '||SQLERRM );
      END;	  
      -- 
      -- Add comments to the columns	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CRIT_PESQ_LCTO_LUCR_EXPL.id is ''Identificador único do registro na tabela''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CRIT_PESQ_LCTO_LUCR_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CRIT_PESQ_LCTO_LUCR_EXPL.paramdpcoddinctale_id is ''Relacionado ao ID da tabela PARAM_DP_CODDIN_CTA_LUCR_EXPL''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CRIT_PESQ_LCTO_LUCR_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CRIT_PESQ_LCTO_LUCR_EXPL.dm_ind_lcto is ''Indicador do tipo de lançamento: N=Normal / E=Encerramento''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CRIT_PESQ_LCTO_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CRIT_PESQ_LCTO_LUCR_EXPL.dm_tipo_vlr_calc is ''Tipo de valor utilizado no calculo: N=Normal (conforme resultado) / D= Somente se devedor / C= Somente se credor''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CRIT_PESQ_LCTO_LUCR_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CRIT_PESQ_LCTO_LUCR_EXPL.num_arq is ''Numero/Codigo ou parte deles de localizacão dos documentos arquivados''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CRIT_PESQ_LCTO_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CRIT_PESQ_LCTO_LUCR_EXPL.compl_hist is ''Historico ou parte dele para busca na tabela de partida''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CRIT_PESQ_LCTO_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	
      -- Create/Recreate primary, unique and foreign key constraints
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CRIT_PESQ_LCTO_LUCR_EXPL add constraint CRITPESQLCTOLUCREXPL_PK primary key (ID)  using index tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar primary de CRIT_PESQ_LCTO_LUCR_EXPL - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CRIT_PESQ_LCTO_LUCR_EXPL add constraint CRITESLCLUEX_PARDPCDINCTLE_FK foreign key (PARAMDPCODDINCTALE_ID) references CSF_OWN.param_dp_coddin_cta_lucr_expl (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de CRIT_PESQ_LCTO_LUCR_EXPL - '||SQLERRM );
      END;
      --
      -- Create/Recreate check constraints 
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CRIT_PESQ_LCTO_LUCR_EXPL add constraint CRITPESQLCTOLUCEXP_DMINDLCT_CK check (dm_ind_lcto IN (''N'', ''E''))';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar check constraints de CRIT_PESQ_LCTO_LUCR_EXPL - '||SQLERRM );
      END;
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CRIT_PESQ_LCTO_LUCR_EXPL add constraint CRITPESQLCTOLUCEXP_DMTPVLCA_CK check (dm_tipo_vlr_calc IN (''N'', ''D'', ''C''))';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar check constraints de CRIT_PESQ_LCTO_LUCR_EXPL - '||SQLERRM );
      END;
      --
      -- Grant/Revoke object privileges	
      BEGIN
         EXECUTE IMMEDIATE 'grant select, insert, update, delete on CSF_OWN.CRIT_PESQ_LCTO_LUCR_EXPL to CSF_WORK';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar Grant para CSF_WORK de CRIT_PESQ_LCTO_LUCR_EXPL - '||SQLERRM );
      END;
      --  
      begin
         execute immediate 'grant all on CSF_OWN.CRIT_PESQ_LCTO_LUCR_EXPL to CONSULTORIA';
      exception
          when others then
             null;
      end;   
      --
      begin
         execute immediate 'grant all on CSF_OWN.CRIT_PESQ_LCTO_LUCR_EXPL to DESENV_USER';
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
         and s.SEQUENCE_NAME  = 'CRITPESQLCTOLUCREXPL_SEQ';   
   exception
      when others then
         vn_qtde := 0;		 
   end;
   --  
   if vn_qtde = 0 then 
      --
      BEGIN
         -- Create sequence
         EXECUTE IMMEDIATE 'create sequence CSF_OWN.CRITPESQLCTOLUCREXPL_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar sequence de CRITPESQLCTOLUCREXPL_SEQ - '||SQLERRM );
      END;
      --	  
   end if; 
   --  
   commit;
   --   
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #73922 - Estrutura de tabelas - CRIT_PESQ_LCTO_LUCR_EXPL
--------------------------------------------------------------------------------------------------------------------------------------


