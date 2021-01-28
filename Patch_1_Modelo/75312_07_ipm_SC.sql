-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #75312 - Atualização tabela param_ipm (SC)
-------------------------------------------------------------------------------------------------------------------------------
begin

   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , '01','Extração mineral do subsolo realizada em unidades de exploração da própria empresa quando o minério ou a boca da mina se localizarem em município diverso da sede do estabelecimento do contribuinte',24,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END; 
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval , '02','Transferências recebidas de estabelecimento do mesmo titular a preço de venda a varejo',24,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   -- 		 
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'03','Transferências enviadas a estabelecimento do mesmo titular a preço de venda a varejo',24,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   -- 		 
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'04','Subsídios concedidos por órgãos dos governos federal, estadual ou municipal, sobre entradas',24,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   -- 		 
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'05','Saída de mercadoria realizada pelo sistema de marketing direto e que destine mercadorias a revendedores que operem na modalidade de venda porta-a- porta',24,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   -- 		 
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'06','Saída de mercadoria realizada por estabelecimento diverso daquele no qual as transações foram efetivadas, desde que:a) ambos estejam localizados no território catarinense, eb) o estabelecimento onde ocorreu a efetiva venda não tenha emitido a NF-e da venda.',24,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   -- 		 
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'07','Saída de mercadorias ao varejo realizada através de entreposto ou posto de abastecimento, situados no Estado (Exige TTD)',24,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   -- 		 
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'08','Saída de partes e peças de um todo realizada por detentor de TTD (Tratamento Tributário Diferenciado código 998) autorizando lançar a operação nos CFOP 5.949 ou 6.949 e desde que a posterior transmissão de propriedade do produto final seja lançada nos CFOP 5.116, 5.117, 6.116 ou 6.117.',24,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   -- 		 
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'09','Saída para informar a transmissão da propriedade de parte ou do todo realizada por detentor de TTD (998) autorizando lançar a operação no CFOP 5.116, 5.117, 6.116 ou6.117, relativo as saídas das partes e peças anteriormente registradas nos CFOP 5.949 ou 6949.',24,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   -- 		 
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'10','Entrada na Trading de mercadoria importada por conta e ordem de terceiros e registrada nos CFOP 1949, 2949, 3949 edesde que não registrada nos CFOP 1101, 1102, 2101, 2102,3101 ou 3102 e não se trate de simples remessa, devolução, retorno ou anulações. (É Exigido TTD 998)',24,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   -- 		 
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'11','Saída da Trading de mercadoria importada por conta e ordem de terceiros com destino ao adquirente e registrada nos CFOP 5949 ou 6949 e desde que não registradas nos CFOP  5101, 5102, 6101, 6102 e não se trate de simples remessa, devolução, retorno ou anulações.  (É Exigido TTD 998)',24,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   -- 		 
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'12','Exportação de produtos recebidos em transferência ou para fim específico de exportação a preço inferior ao da efetiva exportação, nos termos do disposto no art. 10-B do RICMS-SC.',24,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   -- 		 
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'13','Exportação de produtos através de estabelecimento do mesmo titular localizado em outra UF, desde que o produto tenha sido transferido para a unidade exportadora a preço inferior ao da efetiva exportação, nos termos do disposto no art. 10-C do RICMS-SC.',24,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   -- 		 
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'14','Geração de Energia Elétrica por fonte Hidráulica',24,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   -- 		 
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'15','Venda de energia elétrica adquirida de terceiros, realizada por estabelecimento gerador de energia elétrica por fonte hidráulica',24,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   -- 		 
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'16','Entrada da energia elétrica em estabelecimento gerador de energia elétrica por fonte hidráulica adquirida de terceiros, para comercialização.',24,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   -- 		 
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'17','Índice de rateio do Valor Adicionado (VA) decorrente de Convenio ou Acordo entre municípios, mesmo que por ordem judicial.',24,to_date('01/01/2020','dd/mm/rrrr'), null );
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
Prompt FIM Redmine #75312 - Atualização tabela param_ipm (SC)
--------------------------------------------------------------------------------------------------------------------------------------
 