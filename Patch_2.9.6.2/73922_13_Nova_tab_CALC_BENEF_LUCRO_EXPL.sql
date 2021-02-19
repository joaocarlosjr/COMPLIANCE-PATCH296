-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #73922 - Estrutura de tabelas - CALC_BENEF_LUCRO_EXPL
-------------------------------------------------------------------------------------------------------------------------------

declare
  vn_qtde    number;
begin
  begin
     select count(1)
       into vn_qtde
       from all_tables t
      where t.OWNER = 'CSF_OWN'  
        and t.TABLE_NAME = 'CALC_BENEF_LUCRO_EXPL';
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
         EXECUTE IMMEDIATE 'create table CSF_OWN.CALC_BENEF_LUCRO_EXPL ( id number not null
                                                                       , perlucrexpl_id number not null
                                                                       , empresa_id number not null
                                                                       , rec_liq_acum number(15,2)
                                                                       , perc_part number(9,6)
                                                                       , lucr_expl number(15,2)
                                                                       , vl_irpj number(15,2)
                                                                       , dm_foma_calc_ir_adic varchar2(1)
                                                                       , vl_ir_adic number(15,2)
                                                                       , vl_ir_total number(15,2)
                                                                       , vl_red_benef number(15,2)
                                                                       ) tablespace CSF_DATA';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar tabela de CALC_BENEF_LUCRO_EXPL - '||SQLERRM );
      END;	  
      -- 
      commit;
      --	  
      -- Add comments to the table   
      BEGIN
         EXECUTE IMMEDIATE 'comment on table CSF_OWN.CALC_BENEF_LUCRO_EXPL is ''Calculo do Beneficio de redução sobre o Lucro da Exploração por unidade''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_BENEF_LUCRO_EXPL - '||SQLERRM );
      END;	  
      -- 
      -- Add comments to the columns	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_BENEF_LUCRO_EXPL.id is ''Identificador único do registro na tabela''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_BENEF_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_BENEF_LUCRO_EXPL.perlucrexpl_id is ''ID relacionado ao periodo de apuração da tabela PER_LUCR_EXPL''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_BENEF_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_BENEF_LUCRO_EXPL.empresa_id is ''ID relacionado a empresa filial ou matriz em que há beneficio''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_BENEF_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_BENEF_LUCRO_EXPL.rec_liq_acum is ''Valor acumulado do campo VL_RECEITA da tabela REC_UNID_LUCR_EXPL para o mesmo período''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_BENEF_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_BENEF_LUCRO_EXPL.perc_part is ''Percentual de participação da empresa sobre a receita total''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_BENEF_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_BENEF_LUCRO_EXPL.lucr_expl is ''Valor do rateio do lucro de exploração para empresa''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_BENEF_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_BENEF_LUCRO_EXPL.vl_irpj is ''Valor do IRPJ da empresa''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_BENEF_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --	 	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_BENEF_LUCRO_EXPL.dm_foma_calc_ir_adic is ''Forma de calculo de IR Adicional (R = Rateio ou D = Direto)''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_BENEF_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --		  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_BENEF_LUCRO_EXPL.vl_ir_adic is ''IR Adicional da empresa''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_BENEF_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --		  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_BENEF_LUCRO_EXPL.vl_ir_total is ''IR Total da empresa''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_BENEF_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_BENEF_LUCRO_EXPL.vl_red_benef is ''Valor do beneficio da redução na empresa''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_BENEF_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --	
      -- Create/Recreate primary, unique and foreign key constraints
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CALC_BENEF_LUCRO_EXPL add constraint CALCBENEFLUCROEXPL_PK primary key (ID) using index tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar primary de CALC_BENEF_LUCRO_EXPL - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CALC_BENEF_LUCRO_EXPL add constraint CALCBENEFLUCROEXPL_UK1 unique (PERLUCREXPL_ID, EMPRESA_ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar unique de CALC_BENEF_LUCRO_EXPL - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CALC_BENEF_LUCRO_EXPL add constraint CALCBENEFLUCREXP_PERLUCREXP_FK foreign key (PERLUCREXPL_ID) references CSF_OWN.per_lucr_expl (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de CALC_BENEF_LUCRO_EXPL - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CALC_BENEF_LUCRO_EXPL add constraint CALCBENEFLUCROEXPL_EMPRESA_FK foreign key (EMPRESA_ID) references CSF_OWN.empresa (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de CALC_BENEF_LUCRO_EXPL - '||SQLERRM );
      END;
      --	  
      -- Grant/Revoke object privileges	
      BEGIN
         EXECUTE IMMEDIATE 'grant select, insert, update, delete on CSF_OWN.CALC_BENEF_LUCRO_EXPL to CSF_WORK';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar Grant para CSF_WORK de CALC_BENEF_LUCRO_EXPL - '||SQLERRM );
      END;
      --
      begin
         execute immediate 'grant all on CSF_OWN.CALC_BENEF_LUCRO_EXPL to CONSULTORIA';
      exception
          when others then
             null;
      end;   
      --
      begin
         execute immediate 'grant all on CSF_OWN.CALC_BENEF_LUCRO_EXPL to DESENV_USER';
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
         and s.SEQUENCE_NAME  = 'CALCBENEFLUCROEXPL_SEQ';   
   exception
      when others then
         vn_qtde := 0;		 
   end;
   --  
   if vn_qtde = 0 then 
      --
      BEGIN
         -- Create sequence
         EXECUTE IMMEDIATE 'create sequence CSF_OWN.CALCBENEFLUCROEXPL_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar sequence de CALCBENEFLUCROEXPL_SEQ - '||SQLERRM );
      END;
      --	  
   end if;
   --  
   commit;
   --   
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #73922 - Estrutura de tabelas - CALC_BENEF_LUCRO_EXPL
--------------------------------------------------------------------------------------------------------------------------------------
