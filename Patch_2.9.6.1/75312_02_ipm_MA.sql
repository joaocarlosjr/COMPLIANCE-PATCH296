-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #75312 - Atualização tabela param_ipm (MA)
-------------------------------------------------------------------------------------------------------------------------------

begin
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'MAVAF001', 'Atividades de Distribuição de Energia Elétrica',10,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'MAVAF002', 'Atividades de Prestação de Serviços de Comunicação/Telecomunicação',10,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --      
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'MAVAF003', 'Produção de Petróleo e Gás Natural - Na Hipótese da Produção se Estender por Mais de um Município',10,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --      
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'MAVAF004', 'Atividades de Prestação de Serviço de Transporte Ferroviário de Passageiros',10,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --  
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'MAVAF005', 'Prestação de Serviço de Transporte Rodoviário Intermunicipal e Interestadual de Passageiros',10,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --  
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'MAVAF006', 'Prestação de Serviço de Transporte Aquaviário de Passageiros',10,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --  
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'MAVAF007', 'Aquisições de produtos agrícolas, pastoris, extrativos minerais, pescados ou outros produtos extrativos ou agropecuários sem NFA-e do produtor',10,to_date('01/01/2020','dd/mm/rrrr'), null );
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
Prompt FIM Redmine #75312 - Atualização tabela param_ipm (MA)
--------------------------------------------------------------------------------------------------------------------------------------
 