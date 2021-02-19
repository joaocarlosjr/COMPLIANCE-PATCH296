-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #73922 - Estrutura de tabelas - PARAM_DP_CODDIN_CTA_LUCR_EXPL
-------------------------------------------------------------------------------------------------------------------------------
 
declare
  vn_qtde    number;
begin
  begin
     select count(1)
       into vn_qtde
       from all_tables t
      where t.OWNER = 'CSF_OWN'  
        and t.TABLE_NAME = 'PARAM_DP_CODDIN_CTA_LUCR_EXPL';
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
         EXECUTE IMMEDIATE 'create table CSF_OWN.PARAM_DP_CODDIN_CTA_LUCR_EXPL( id number not null
                                                                              , empresa_id number not null		 
                                                                              , coddinlucrexpl_id number not null
                                                                              , planoconta_id number not null
                                                                              , centrocusto_id number
                                                                              , dm_tb_origem varchar2(1) not null
																			  , dm_tipo_vlr_calc varchar2(1) not null 
                                                                              ) tablespace CSF_DATA';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar tabela de PARAM_DP_CODDIN_CTA_LUCR_EXPL - '||SQLERRM );
      END;	  
      -- 
      commit;
      --	  
      -- Add comments to the table   
      BEGIN
         EXECUTE IMMEDIATE 'comment on table CSF_OWN.PARAM_DP_CODDIN_CTA_LUCR_EXPL is ''Tabela de onde será feito o depara entre os códigos dinamicos e plano de contas''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PARAM_DP_COD_DIN_CTA - '||SQLERRM );
      END;	  
      -- 
      -- Add comments to the columns	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PARAM_DP_CODDIN_CTA_LUCR_EXPL.id is ''Identificador único do registro na tabela''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PARAM_DP_CODDIN_CTA_LUCR_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PARAM_DP_CODDIN_CTA_LUCR_EXPL.empresa_id is ''ID relacionado a empresa em que a parametrização foi feita''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PARAM_DP_CODDIN_CTA_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PARAM_DP_CODDIN_CTA_LUCR_EXPL.coddinlucrexpl_id is ''ID relacionado à tabela COD_DIN_LUCRO_EXPL''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PARAM_DP_CODDIN_CTA_LUCR_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PARAM_DP_CODDIN_CTA_LUCR_EXPL.planoconta_id is ''ID relacionado ao plano de contas da matriz em que será buscado valor para montagem do lucro da exploração''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PARAM_DP_CODDIN_CTA_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PARAM_DP_CODDIN_CTA_LUCR_EXPL.centrocusto_id  is ''ID do centro de custos, sendo campo opcional''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PARAM_DP_CODDIN_CTA_LUCR_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PARAM_DP_CODDIN_CTA_LUCR_EXPL.dm_tb_origem  is ''Tabela origem das informações: S=Saldo / L=Lançamento''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PARAM_DP_CODDIN_CTA_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.PARAM_DP_CODDIN_CTA_LUCR_EXPL.dm_tipo_vlr_calc  is ''Tipo de valor calculado: N=Normal (conforme resultado) / D= Somente se devedor / C= Somente se credor''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de PARAM_DP_CODDIN_CTA_LUCR_EXPL - '||SQLERRM );
      END;	  
      --	
      -- Create/Recreate primary, unique and foreign key constraints
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.PARAM_DP_CODDIN_CTA_LUCR_EXPL add constraint PARAMDPCODDINCTALUCREXPL_PK primary key (ID) using index tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar primary de PARAM_DP_CODDIN_CTA_LUCR_EXPL - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.PARAM_DP_CODDIN_CTA_LUCR_EXPL add constraint PARDPCDINCTALUEX_EMPRESA_FK foreign key (EMPRESA_ID) references CSF_OWN.empresa (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de PARAM_DP_CODDIN_CTA_LUCR_EXPL - '||SQLERRM );
      END;
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.PARAM_DP_CODDIN_CTA_LUCR_EXPL add constraint PARDPCDINCTALUEX_CODDINLUEX_FK foreign key (CODDINLUCREXPL_ID) references CSF_OWN.cod_din_lucr_expl (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de PARAM_DP_CODDIN_CTA_LUCR_EXPL - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.PARAM_DP_CODDIN_CTA_LUCR_EXPL add constraint PARDPCDINCTALUEX_PLANOCONTA_FK foreign key (PLANOCONTA_ID) references CSF_OWN.plano_conta (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de PARAM_DP_CODDIN_CTA_LUCR_EXPL - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.PARAM_DP_CODDIN_CTA_LUCR_EXPL add constraint PARDPCDINCTALUEX_CENTROCUST_FK foreign key (CENTROCUSTO_ID) references CSF_OWN.centro_custo (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de PARAM_DP_CODDIN_CTA_LUCR_EXPL - '||SQLERRM );
      END;	    
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.PARAM_DP_CODDIN_CTA_LUCR_EXPL add constraint PARAMDPCODDINCTALUCREXPL_UK1 unique (EMPRESA_ID, CODDINLUCREXPL_ID, PLANOCONTA_ID, CENTROCUSTO_ID, DM_TB_ORIGEM)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar unique de PARAM_DP_CODDIN_CTA_LUCR_EXPL - '||SQLERRM );
      END;	    
      --
      -- Create/Recreate check constraints 
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.PARAM_DP_CODDIN_CTA_LUCR_EXPL add constraint PARDPCDINCTALUEX_DMTBORIGEM_CK check (DM_TB_ORIGEM IN (''S'', ''L''))';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar check constraints de PARAM_DP_CODDIN_CTA_LUCR_EXPL - '||SQLERRM );
      END;
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.PARAM_DP_CODDIN_CTA_LUCR_EXPL add constraint PARDPCDINCTALUEX_DMTPVLCALC_CK check (DM_TIPO_VLR_CALC IN (''N'', ''D'', ''C''))';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar check constraints de PARAM_DP_CODDIN_CTA_LUCR_EXPL - '||SQLERRM );
      END;
      --
      -- Grant/Revoke object privileges	
      BEGIN
         EXECUTE IMMEDIATE 'grant select, insert, update, delete on CSF_OWN.PARAM_DP_CODDIN_CTA_LUCR_EXPL to CSF_WORK';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar Grant para CSF_WORK de PARAM_DP_CODDIN_CTA_LUCR_EXPL - '||SQLERRM );
      END;
      --  
      begin
         execute immediate 'grant all on CSF_OWN.PARAM_DP_CODDIN_CTA_LUCR_EXPL to CONSULTORIA';
      exception
          when others then
             null;
      end;   
      --
      begin
         execute immediate 'grant all on CSF_OWN.PARAM_DP_CODDIN_CTA_LUCR_EXPL to DESENV_USER';
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
         and s.SEQUENCE_NAME  = 'PARAMDPCODDINCTALUCREXPL_SEQ';   
   exception
      when others then
         vn_qtde := 0;		 
   end;
   --  
   if vn_qtde = 0 then 
      --
      BEGIN
         -- Create sequence
         EXECUTE IMMEDIATE 'create sequence CSF_OWN.PARAMDPCODDINCTALUCREXPL_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar sequence de PARAMDPCODDINCTALUCREXPL_SEQ - '||SQLERRM );
      END;
      --	  
   end if; 
   --  
   commit;
   --   
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #73922 - Estrutura de tabelas - PARAM_DP_CODDIN_CTA_LUCR_EXPL
--------------------------------------------------------------------------------------------------------------------------------------
