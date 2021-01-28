-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #75312 - Atualização tabela param_ipm (AC)
-------------------------------------------------------------------------------------------------------------------------------
begin
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ACIPME01','Agricultura - Valor Contábil das Entradas de insumos para produção própria de produtos agrícolas, produzidos em propriedade rural de responsabilidade do contribuinte, ainda que no sistema integrado, por município acreano, excluindo-se as operações dedutíveis',1,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ACIPMS01','Agricultura - Valor Contábil das Saídas para comercialização ou industrialização de produção própria de produtos agrícolas, produzidos em propriedade rural de responsabilidade do contribuinte, ainda que no sistema integrado, por município acreano, excluindo-se as operações dedutíveis',1,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ACIPME02','Pecuária - Valor Contábil das Entradas de mercadorias e/ou aquisições de serviços para produção pecuária, por município acreano, excluindo-se as operações dedutíveis',1,to_date('01/01/2021','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ACIPMS02','Pecuária - Valor Contábil das Saídas de mercadorias e/ou prestações de serviços de produção pecuária, por município acreano, excluindo-se as operações dedutíveis',1,to_date('01/01/2022','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ACIPME03','Pesca - Valor Contábil das Entradas de mercadorias e/ou aquisições de serviços para produção de pescado, por município acreano, excluindo-se as operações dedutíveis',1,to_date('01/01/2023','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ACIPMS03','Pesca - Valor Contábil das Saídas de mercadorias e/ou prestações de serviços da produção de pescado, por município acreano, excluindo-se as operações dedutíveis',1,to_date('01/01/2024','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ACIPME04','Transporte - Valor Contábil das Entradas provenientes das aquisições de serviços de Transporte por município acreano, excluindo-se as operações dedutíveis',1,to_date('01/01/2025','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ACIPMS04','Transporte - Valor Contábil das Saídas referente a prestações de serviços de Transporte por município acreano, excluindo-se as operações dedutíveis',1,to_date('01/01/2026','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ACIPME05','Produção de Energia Elétrica (Usinas) - Valor Contábil das Entradas de mercadorias e/ou aquisições de serviços utilizados na geração de energia elétrica, por município acreano, excluindo-se as operações dedutíveis',1,to_date('01/01/2027','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ACIPMS05','Produção de Energia Elétrica (Usinas) - Valor Contábil das Saídas de mercadorias e/ou prestações de serviços da geração de energia elétrica, por município acreano, excluindo-se as operações dedutíveis',1,to_date('01/01/2028','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ACIPME06','Energia Elétrica - Valor Contábil das Entradas de energia elétrica e insumos utilizados na transmissão, distribuição e comercialização de energia elétrica, por município acreano, excluindo-se as operações dedutíveis',1,to_date('01/01/2029','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ACIPMS06','Energia Elétrica - Valor Contábil das Saídas de energia elétrica transmitida, distribuída e comercializada, por município acreano, excluindo-se as operações dedutíveis',1,to_date('01/01/2030','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ACIPME07','Comunicação e Telecomunicação - Valor Contábil das Entradas e aquisições de serviços de comunicação e telecomunicação, por município acreano, excluindo-se as operações dedutíveis',1,to_date('01/01/2031','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ACIPMS07','Comunicação e Telecomunicação - Valor Contábil das Saídas e prestações de serviços de comunicação e telecomunicação, por município acreano, excluindo-se as operações dedutíveis',1,to_date('01/01/2032','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ACIPME08','Combustível - Valor Contábil das Entradas de mercadorias para produção e comercialização de combustíveis, por município acreano, excluindo-se as operações dedutíveis',1,to_date('01/01/2033','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ACIPMS08','Combustível - Valor Contábil das Saídas relativas da produção e comercialização de combustíveis, por município acreano, excluindo-se as operações dedutíveis',1,to_date('01/01/2034','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ACIPME09','Comércio - Valor Contábil das Entradas de mercadorias para comercialização, por município acreano, excluindo-se as operações dedutíveis',1,to_date('01/01/2035','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ACIPMS09','Comércio - Valor Contábil das Saídas de mercadorias, por município acreano, excluindo-se as operações dedutíveis',1,to_date('01/01/2036','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ACIPME10','Indústria - Valor Contábil das Entradas mercadorias e insumos utilizadas na produção industrial, por município acreano, excluindo-se as operações dedutíveis',1,to_date('01/01/2037','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ACIPMS10','Indústria - Valor Contábil das Saídas de mercadorias industrializadas, por município acreano, excluindo-se as operações dedutíveis',1,to_date('01/01/2038','dd/mm/rrrr'), null );
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
Prompt FIM Redmine #75312 - Atualização tabela param_ipm (AC)
--------------------------------------------------------------------------------------------------------------------------------------
 