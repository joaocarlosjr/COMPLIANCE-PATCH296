-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #75312 - Atualização tabela param_ipm (MG)
-------------------------------------------------------------------------------------------------------------------------------

begin
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'Cooperativas', 'Cooperativas',13,to_date('01/01/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'Geracao_de_Energia_Eletrica', 'Geração de Energia Elétrica',13,to_date('01/01/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --      
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'Outras_Entradas_a_Detalhar_por_Municipio', 'Outras Entradas a Detalhar por município',13,to_date('01/01/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --      
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'Prestacao_de_Servico_de_Transporte_Rodoviario', 'Prestação de Serviço de Transporte Rodoviário',13,to_date('01/01/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --  
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'Produtos_Agropecuarios', 'Produtos Agropecuários/Hortifrutigranjeiros',13,to_date('01/01/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --  
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'Transporte_Tomado', 'Transporte Tomado',13,to_date('01/01/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --  
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'Mudanca_de_Municipio', 'Mudança de Município',13,to_date('01/01/2015','dd/mm/rrrr'), to_date('31/05/2020','dd/mm/rrrr') );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   -- 
   COMMIT;
   --
end;
/
 
--------------------------------------------------------------------------------------------------------------------------------------
Prompt FIM Redmine #75312 - Atualização tabela param_ipm (MG)
--------------------------------------------------------------------------------------------------------------------------------------
 