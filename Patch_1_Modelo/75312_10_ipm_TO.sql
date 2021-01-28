-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #75312 - Atualização tabela param_ipm (TO)
-------------------------------------------------------------------------------------------------------------------------------
begin
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'TOIPME01','Agricultura - Valor Contábil das Entradas de insumos para produção própria de produtos agrícolas, produzidos em propriedade rural de responsabilidade do contribuinte, ainda que no sistema integrado, por município tocantinense, excluindo-se as operações dedutíveis',27,to_date('01/04/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'TOIPMS01','Agricultura - Valor Contábil das Saídas para comercialização ou industrialização de produção própria de produtos agrícolas, produzidos em propriedade rural de responsabilidade do contribuinte, ainda que no sistema integrado, por município tocantinense, excluindo-se as operações dedutíveis',27,to_date('01/04/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'TOIPME02','Pecuária - Valor Contábil das Entradas de mercadorias e/ou aquisições de serviços para produção pecuária, por município tocantinense, excluindo-se as operações dedutíveis',27,to_date('01/04/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'TOIPMS02','Pecuária - Valor Contábil das Saídas de mercadorias e/ou prestações de serviços de produção pecuária, por município tocantinense, excluindo-se as operações dedutíveis',27,to_date('01/04/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'TOIPME03','Pesca - Valor Contábil das Entradas de mercadorias e/ou aquisições de serviços para produção de pescado, por município tocantinense, excluindo-se as operações dedutíveis',27,to_date('01/04/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'TOIPMS03','Pesca - Valor Contábil das Saídas de mercadorias e/ou prestações de serviços da produção de pescado, por município tocantinense, excluindo-se as operações dedutíveis',27,to_date('01/04/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'TOIPME04','Transporte - Valor Contábil das Entradas provenientes das aquisições de serviços de Transporte por município tocantinense, excluindo-se as operações dedutíveis',27,to_date('01/04/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'TOIPMS04','Transporte - Valor Contábil das Saídas referente a prestações de serviços de Transporte por município tocantinense, excluindo-se as operações dedutíveis',27,to_date('01/04/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'TOIPME05','Produção de Energia Elétrica (Usinas) - Valor Contábil das Entradas de mercadorias e/ou aquisições de serviços utilizados na geração de energia elétrica, por município tocantinense, excluindo-se as operações dedutíveis',27,to_date('01/04/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'TOIPMS05','Produção de Energia Elétrica (Usinas) - Valor Contábil das Saídas de mercadorias e/ou prestações de serviços da geração de energia elétrica, por município tocantinense, excluindo-se as operações dedutíveis',27,to_date('01/04/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'TOIPME06','Energia Elétrica - Valor Contábil das Entradas de energia elétrica e insumos utilizados na transmissão, distribuição e comercialização de energia elétrica, por município tocantinense, excluindo-se as operações dedutíveis',27,to_date('01/04/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'TOIPMS06','Energia Elétrica - Valor Contábil das Saídas de energia elétrica transmitida, distribuída e comercializada, por município tocantinense, excluindo-se as operações dedutíveis',27,to_date('01/04/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'TOIPME07','Água Canalizada - Valor Contábil das Entradas e insumos utilizados na Captação, tratamento e distribuição de água canalizada, por município tocantinense, excluindo-se as operações dedutíveis',27,to_date('01/04/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'TOIPMS07','Água Canalizada - Valor Contábil das Saídas referente à distribuição de água canalizada, por município tocantinense, excluindo-se as operações dedutíveis',27,to_date('01/04/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'TOIPME08','Comunicação e Telecomunicação - Valor Contábil das Entradas e aquisições de serviços de comunicação e telecomunicação, por município tocantinense, excluindo-se as operações dedutíveis',27,to_date('01/04/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'TOIPMS08','Comunicação e Telecomunicação - Valor Contábil das Saídas e prestações de serviços de comunicação e telecomunicação, por município tocantinense, excluindo-se as operações dedutíveis',27,to_date('01/04/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'TOIPME09','Combustível - Valor Contábil das Entradas de mercadorias para produção e comercialização de combustíveis, por município tocantinense, excluindo-se as operações dedutíveis',27,to_date('01/04/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'TOIPMS09','Combustível - Valor Contábil das Saídas relativas da produção e comercialização de combustíveis, por município tocantinense, excluindo-se as operações dedutíveis',27,to_date('01/04/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'TOIPME10','Comércio - Valor Contábil das Entradas de mercadorias para comercialização, por município tocantinense, excluindo-se as operações dedutíveis',27,to_date('01/04/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'TOIPMS10','Comércio - Valor Contábil das Saídas de mercadorias, por município tocantinense, excluindo-se as operações dedutíveis',27,to_date('01/04/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'TOIPME11','Indústria - Valor Contábil das Entradas mercadorias e insumos utilizadas na produção industrial, por município tocantinense, excluindo-se as operações dedutíveis',27,to_date('01/04/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'TOIPMS11','Indústria - Valor Contábil das Saídas de mercadorias industrializadas, por município tocantinense, excluindo-se as operações dedutíveis',27,to_date('01/04/2018','dd/mm/rrrr'), null );
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
Prompt FIM Redmine #75312 - Atualização tabela param_ipm (TO)
--------------------------------------------------------------------------------------------------------------------------------------
 