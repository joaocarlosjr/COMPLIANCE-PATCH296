-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #75312 - Atualização tabela param_ipm (SP)
-------------------------------------------------------------------------------------------------------------------------------

begin
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'SPDIPAM11', 'Compras escrituradas de mercadorias de produtores agropecuários paulistas por município de origem.',25,to_date('01/01/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'SPDIPAM12', 'Compras não escrituradas de mercadorias de agropecuários paulistas por município de origem e outros ajustes determinados pela SEFAZ-SP.',25,to_date('01/01/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --      
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'SPDIPAM13', 'Recebimentos, por cooperativas, de mercadorias remetidas por produtores rurais deste Estado, desde que ocorra a efetiva transmissão da propriedade para a cooperativa. Excluem-se as situações em que haja previsão de retorno da mercadoria ao cooperado, como quando a cooperativa é simples depositária.',25,to_date('01/01/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --      
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'SPDIPAM22', 'Vendas efetuadas por revendedores ambulantes autônomos em outros municípios paulistas; Refeições preparadas fora do município do declarante, em operações autorizadas por Regime Especial; operações realizadas por empresas devidamente autorizadas a declarar por meio de uma única Inscrição Estadual; Outros ajustes determinados pela Secretaria da Fazenda mediante instrução expressa e específica.',25,to_date('01/01/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --  
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'SPDIPAM23', 'Rateio dos serviços de transporte intermunicipal e interestadual iniciados em municípios paulistas.',25,to_date('01/01/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --  
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'SPDIPAM24', 'Rateio dos serviços de comunicação aos municípios paulistas onde tenham sido prestados.',25,to_date('01/01/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --  
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'SPDIPAM25', 'Rateio de energia elétrica – Estabelecimento Distribuidor de Energia.',25,to_date('01/01/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   -- 
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'SPDIPAM26', 'Informar o Valor Adicionado (deduzidos os custos de insumos) referente à produção própria ou arrendada nos estabelecimentos nos quais o contribuinte não possua Inscrição Estadual inscrita.',25,to_date('01/01/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --  
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'SPDIPAM31', 'Saídas não escrituradas e outros ajustes determinados pela SEFAZ-SP.',25,to_date('01/01/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'SPDIPAM35', 'Entradas não escrituradas e outros ajustes determinados pela SEFAZ-SP.',25,to_date('01/01/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --      
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'SPDIPAM36', 'Entradas não escrituradas de produtores não equiparados.',25,to_date('01/01/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --      
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'SPDIPAM27', 'Informar: (i) o valor das operações de saída de mercadorias cujas transações comerciais tenham sido realizadas em outro estabelecimento localizado neste Estado, excluídas as transações comerciais não presenciais; e (ii) os respectivos municípios onde as transações comerciais foram realizadas.',25,to_date('01/07/2017','dd/mm/rrrr'), to_date('31/12/2017','dd/mm/rrrr') );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --  
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , 'SPDIPAM27', 'Vendas presenciais com saídas/vendas efetuadas em estabelecimento diverso de onde ocorreu a transação/negociação inicial',25,to_date('01/01/2018','dd/mm/rrrr'), null );
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
Prompt FIM Redmine #75312 - Atualização tabela param_ipm (SP)
--------------------------------------------------------------------------------------------------------------------------------------
 