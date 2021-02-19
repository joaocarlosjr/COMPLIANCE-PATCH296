-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #73922 - Estrutura de tabelas - MEM_CALC_LUCRO_EXPL
-------------------------------------------------------------------------------------------------------------------------------
 
declare
  vn_qtde    number;
begin
  begin
     select count(1)
       into vn_qtde
       from all_tables t
      where t.OWNER = 'CSF_OWN'  
        and t.TABLE_NAME = 'MEM_CALC_LUCRO_EXPL';
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
         EXECUTE IMMEDIATE 'create table CSF_OWN.MEM_CALC_LUCRO_EXPL( id number not null
                                                                    , perlucrexpl_id number not null		 
                                                                    , paramdpcoddinctale_id number not null
                                                                    , planoconta_id number not null
                                                                    , centrocusto_id number
                                                                    , dm_tb_origem varchar2(1) not null
                                                                    , dm_tipo_vlr_calc varchar2(1) not null 
                                                                    , valor number(15,2) not null
                                                                    , descr varchar2(4000)																			  
                                                                    ) tablespace CSF_DATA';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar tabela de MEM_CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      -- 
      commit;
      --	  
      -- Add comments to the table   
      BEGIN
         EXECUTE IMMEDIATE 'comment on table CSF_OWN.MEM_CALC_LUCRO_EXPL is ''Memória de calculo da apuração de lucro da exploração''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de MEM_CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      -- 
      -- Add comments to the columns	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.MEM_CALC_LUCRO_EXPL.id is ''Identificador único do registro na tabela''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de MEM_CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.MEM_CALC_LUCRO_EXPL.perlucrexpl_id is ''ID relacionado ao periodo de apuração da tabela PER_LUCR_EXPL''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de MEM_CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.MEM_CALC_LUCRO_EXPL.paramdpcoddinctale_id is ''Relacionado ao ID da tabela PARAM_DP_CODDIN_CTA_LUCR_EXPL''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de MEM_CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.MEM_CALC_LUCRO_EXPL.planoconta_id is ''ID relacionado ao plano de contas da matriz em que será buscado valor para montagem do lucro da exploração''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de MEM_CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.MEM_CALC_LUCRO_EXPL.centrocusto_id  is ''ID do centro de custos, sendo campo opcional''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de MEM_CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.MEM_CALC_LUCRO_EXPL.dm_tb_origem  is ''Tabela origem das informações: S=Saldo / L=Lançamento''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de MEM_CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.MEM_CALC_LUCRO_EXPL.dm_tipo_vlr_calc  is ''Tipo de valor calculado: N=Normal (conforme resultado) / D= Somente se devedor / C= Somente se credor''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de MEM_CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.MEM_CALC_LUCRO_EXPL.valor is ''Valor utilizado''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de MEM_CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.MEM_CALC_LUCRO_EXPL.descr is ''Descrição da forma que registro foi montado''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de MEM_CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --	
      -- Create/Recreate primary, unique and foreign key constraints
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.MEM_CALC_LUCRO_EXPL add constraint MEMCALCLUCROEXPL_PK primary key (ID) using index tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar primary de MEM_CALC_LUCRO_EXPL - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.MEM_CALC_LUCRO_EXPL add constraint MEMCALCLUCROEXP_PERLUCREXP_FK foreign key (PERLUCREXPL_ID) references CSF_OWN.per_lucr_expl (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de MEM_CALC_LUCRO_EXPL - '||SQLERRM );
      END;
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.MEM_CALC_LUCRO_EXPL add constraint MEMCALCLUCEXP_PARDPCDINCTLE_FK foreign key (PARAMDPCODDINCTALE_ID) references CSF_OWN.param_dp_coddin_cta_lucr_expl (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de MEM_CALC_LUCRO_EXPL - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.MEM_CALC_LUCRO_EXPL add constraint MEMCALCLUCROEXPL_PLANOCONTA_FK foreign key (PLANOCONTA_ID) references CSF_OWN.plano_conta (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de MEM_CALC_LUCRO_EXPL - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.MEM_CALC_LUCRO_EXPL add constraint MEMCALCLUCROEXPL_CENTROCUST_FK foreign key (CENTROCUSTO_ID) references CSF_OWN.centro_custo (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de MEM_CALC_LUCRO_EXPL - '||SQLERRM );
      END;	    
      --
      -- Create/Recreate check constraints 
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.MEM_CALC_LUCRO_EXPL add constraint MEMCALCLUCROEXPL_DMTBORIGEM_CK check (DM_TB_ORIGEM IN (''S'', ''L''))';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar check constraints de MEM_CALC_LUCRO_EXPL - '||SQLERRM );
      END;
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.MEM_CALC_LUCRO_EXPL add constraint MEMCALCLUCROEXPL_DMTPVLCALC_CK check (DM_TIPO_VLR_CALC IN (''N'', ''D'', ''C''))';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar check constraints de MEM_CALC_LUCRO_EXPL - '||SQLERRM );
      END;
      --
      -- Grant/Revoke object privileges	
      BEGIN
         EXECUTE IMMEDIATE 'grant select, insert, update, delete on CSF_OWN.MEM_CALC_LUCRO_EXPL to CSF_WORK';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar Grant para CSF_WORK de MEM_CALC_LUCRO_EXPL - '||SQLERRM );
      END;
      --  
      begin
         execute immediate 'grant all on CSF_OWN.MEM_CALC_LUCRO_EXPL to CONSULTORIA';
      exception
          when others then
             null;
      end;   
      --
      begin
         execute immediate 'grant all on CSF_OWN.MEM_CALC_LUCRO_EXPL to DESENV_USER';
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
         and s.SEQUENCE_NAME  = 'MEMCALCLUCROEXPL_SEQ';   
   exception
      when others then
         vn_qtde := 0;		 
   end;
   --  
   if vn_qtde = 0 then 
      --
      BEGIN
         -- Create sequence
         EXECUTE IMMEDIATE 'create sequence CSF_OWN.MEMCALCLUCROEXPL_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar sequence de MEMCALCLUCROEXPL_SEQ - '||SQLERRM );
      END;
      --	  
   end if; 
   --  
   commit;
   --   
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #73922 - Estrutura de tabelas - MEM_CALC_LUCRO_EXPL
--------------------------------------------------------------------------------------------------------------------------------------
