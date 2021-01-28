-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #75312 - Atualização tabela param_ipm (ES)
-------------------------------------------------------------------------------------------------------------------------------
begin
   --
   

   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ESIPM01','PRODUÇÃO RURAL PRÓPRIA - Entradas para comercialização ou industrialização, de produtos agropecuários produzidos em propriedade rural que o contribuinte é responsável, inclusive as entradas por retorno de animal em sistema de integração.',8,to_date('01/10/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ESIPM02','COOPERATIVAS E CONTRIBUINTES QUE POSSUAM REOA - Valor dos produtos agropecuários adquiridos por cooperativas ou contribuintes que possuam Regime Especial de Obrigação Acessória - REOA - para emitir a NFe referente à entrada de produtos.',8,to_date('01/10/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ESIPM03','AQUISIÇÕES DE PESSOAS FÍSICAS - Valor correspondente às aquisições de mercadorias de pessoas físicas, tais como sucatas e veículos usados. Não consideraras aquisições de produtores rurais que tenham emitido nota fiscal de produtor.',8,to_date('01/10/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ESIPM04','GERAÇÃO DE ENERGIA ELÉTRICA - Receita referente à produção de energia elétrica, deduzidos os custos de produção. Detalhando para o Município de localização do estabelecimento produtor, que é onde está instalado o motor primário.',8,to_date('01/10/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ESIPM05','DISTRIBUIÇÃO DE ENERGIA ELÉTRICA - Receita de energia elétrica distribuída, deduzido o valor da compra de energia elétrica, utilizando o critério de rateio proporcional e considerando o valor total do fornecimento.',8,to_date('01/10/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ESIPM06','PRESTAÇÃO SERVIÇO DE TRANSPORTE - Valor das prestações de serviços de transporte intermunicipal e interestadual, para o Município que tenha iniciado o transporte. Se iniciado em outro Estado, registra-se para o Município sede da transportadora.',8,to_date('01/10/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ESIPM07','SERVIÇOS DE COMUNICAÇÃO E TELECOMUNICAÇÃO -Valor correspondente para cada Município nos quais foram realizadas prestações de serviços de comunicação e telecomunicação, não considerando o faturamento referente à comercialização de equipamentos.',8,to_date('01/10/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ESIPM08','PRODUÇÃO DE PETRÓLEO E GÁS NATURAL - Valor referente às atividades de produção de petróleo ou gás natural, considerando para o rateio do Município o critério “cabeça do poço”, que é onde estão instalados os equipamentos de extração.',8,to_date('01/10/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ESIPM09','DISTRIBUIÇÃO DE ÁGUA CANALIZADA - Valor relativo ao faturamento de água tratada, considerando o fornecimento para cada Município individualmente e rateando os custos proporcionalmente. Sendo vedada a inclusão do faturamento relativo ao esgoto.',8,to_date('01/10/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ESIPM10','DISTRIBUIÇÃO DE GÁS NATURAL CANALIZADO - Valor do faturamento com gás natural canalizado, deduzido por critério de rateio as compras de gás natural e os tributos incidentes.',8,to_date('01/10/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ESIPM11','COZINHAS INDUSTRIAIS E SISTEMA DE INSCRIÇÃO CENTRALIZADA - Faturamento não incluídos nos itens anteriores, realizados por contribuintes com inscrição centralizada, legislação do ICMS ou regime especial, como cozinhas industriais.',8,to_date('01/10/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ESIPM12','FOMENTOS AGROPECUÁRIOS - Valor correspondente ao fomento agropecuário realizados pelo contribuinte.',8,to_date('01/10/2015','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'ESIPM13','MUDANÇA PARA OUTRO MUNICÍPIO - Será informado para o Município onde o contribuinte estava localizado, o valor referente ao estoque final de mercadorias constantes no dia da mudança para outro Município.',8,to_date('01/10/2015','dd/mm/rrrr'), null );
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
Prompt FIM Redmine #75312 - Atualização tabela param_ipm (ES)
--------------------------------------------------------------------------------------------------------------------------------------
 