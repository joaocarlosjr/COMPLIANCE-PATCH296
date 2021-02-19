-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #73922 - Estrutura de tabelas - CALC_LUCRO_EXPL
-------------------------------------------------------------------------------------------------------------------------------

declare
  vn_qtde    number;
begin
  begin
     select count(1)
       into vn_qtde
       from all_tables t
      where t.OWNER = 'CSF_OWN'  
        and t.TABLE_NAME = 'CALC_LUCRO_EXPL';
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
         EXECUTE IMMEDIATE 'create table CSF_OWN.CALC_LUCRO_EXPL ( id number not null
                                                                 , perlucrexpl_id number not null
                                                                 , tot_lucro_expl number(15,2)
                                                                 , vl_lucro_real number(15,2)
                                                                 , qtd_meses number
                                                                 , perc_irpj number(5,2)																 
                                                                 , vl_bc_adic_irpj number(15,2)
                                                                 , perc_adic_ir number(5,2)
                                                                 , vl_ir_adic number(15,2)
                                                                 , vl_rec_liq_tot number(15,2)
                                                                 , vl_red_benef_tot number(15,2)
                                                                 , vl_rec_demais_ativ number(15,2)
                                                                 , dm_tipo number(1) default 0 not null
                                                                 ) tablespace CSF_DATA';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar tabela de CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      -- 
      commit;
      --	  
      -- Add comments to the table   
      BEGIN
         EXECUTE IMMEDIATE 'comment on table CSF_OWN.CALC_LUCRO_EXPL is ''Consolidação do calculo do lucro da exploração''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      -- 
      -- Add comments to the columns	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_LUCRO_EXPL.id is ''Identificador único do registro na tabela''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_LUCRO_EXPL.perlucrexpl_id is ''ID relacionado ao periodo de apuração da tabela PER_LUCR_EXPL''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_LUCRO_EXPL.tot_lucro_expl is ''Total de Lucro da Exploração acumulado no ano até o momento do calculo''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_LUCRO_EXPL.vl_lucro_real is ''Valor do Lucro Real''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_LUCRO_EXPL.qtd_meses is ''Quantidade de meses que houve movimento''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_LUCRO_EXPL.perc_irpj is ''% IRPJ''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_LUCRO_EXPL.vl_bc_adic_irpj is ''Valor de redução da Base de Calculo do Adicional de IR''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_LUCRO_EXPL.perc_adic_ir is ''Percentual do IR Adicional''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --	 	  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_LUCRO_EXPL.vl_ir_adic is ''Valor de IRPJ Adicional''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --		  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_LUCRO_EXPL.vl_rec_liq_tot is ''Valor total da receita liquida anual que será obtida pela soma do grupo de contas referenciais filhas de 3.01.01.01 e 3.11.01.01''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --		  
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_LUCRO_EXPL.vl_red_benef_tot is ''Valor total do beneficio de redução''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_LUCRO_EXPL.vl_rec_demais_ativ is ''Valor das receitas das demais atividades. Será a subtração de vl_rec_liq_tot por vl_red_benef_tot (conforme regra ECF N600.18)''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --	
      BEGIN
         EXECUTE IMMEDIATE 'comment on column CSF_OWN.CALC_LUCRO_EXPL.dm_tipo is ''Tipo de geração do registro: 0-Não Definido; 1-Calculado; 2-Digitado; 3-Calculado/Digitado''';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar comentario de CALC_LUCRO_EXPL - '||SQLERRM );
      END;	  
      --	
      -- Create/Recreate primary, unique and foreign key constraints
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CALC_LUCRO_EXPL add constraint CALCLUCROEXPL_PK primary key (ID) using index tablespace CSF_INDEX';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar primary de CALC_LUCRO_EXPL - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CALC_LUCRO_EXPL add constraint CALCLUCROEXPL_UK1 unique (PERLUCREXPL_ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar unique de CALC_LUCRO_EXPL - '||SQLERRM );
      END;
      --
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CALC_LUCRO_EXPL add constraint CALCLUCROEXPL_PERLUCREXPL_FK foreign key (PERLUCREXPL_ID) references CSF_OWN.per_lucr_expl (ID)';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar foreign de CALC_LUCRO_EXPL - '||SQLERRM );
      END;
      --
      -- Create/Recreate check constraints 
      BEGIN
         EXECUTE IMMEDIATE 'alter table CSF_OWN.CALC_LUCRO_EXPL add constraint CALCLUCROEXPL_DMTIPO_CK check (DM_TIPO IN (0, 1, 2, 3))';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar check constraints de CALC_LUCRO_EXPL - '||SQLERRM );
      END;
      --	  
      -- Grant/Revoke object privileges	
      BEGIN
         EXECUTE IMMEDIATE 'grant select, insert, update, delete on CSF_OWN.CALC_LUCRO_EXPL to CSF_WORK';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar Grant para CSF_WORK de CALC_LUCRO_EXPL - '||SQLERRM );
      END;
      --
      begin
         execute immediate 'grant all on CSF_OWN.CALC_LUCRO_EXPL to CONSULTORIA';
      exception
          when others then
             null;
      end;   
      --
      begin
         execute immediate 'grant all on CSF_OWN.CALC_LUCRO_EXPL to DESENV_USER';
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
         and s.SEQUENCE_NAME  = 'CALCLUCROEXPL_SEQ';   
   exception
      when others then
         vn_qtde := 0;		 
   end;
   --  
   if vn_qtde = 0 then 
      --
      BEGIN
         -- Create sequence
         EXECUTE IMMEDIATE 'create sequence CSF_OWN.CALCLUCROEXPL_SEQ minvalue 1 maxvalue 9999999999999999999999999999 start with 1 increment by 1 nocache';
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR ( -20101, 'Erro ao criar sequence de CALCLUCROEXPL_SEQ - '||SQLERRM );
      END;
      --	  
   end if;
   --  
   commit;
   --   
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #73922 - Estrutura de tabelas - CALC_LUCRO_EXPL
--------------------------------------------------------------------------------------------------------------------------------------
