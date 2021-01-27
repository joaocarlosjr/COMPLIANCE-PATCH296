-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #75312 - Atualização tabela param_ipm (BA)
-------------------------------------------------------------------------------------------------------------------------------
begin
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAE01','Aquisição de Serviços de Transporte - valor contábil das entradas e aquisições de serviço de transporte intermunicipal e/ou interestadual, por município baiano, proporcionalmente às saídas informadas, excluindo-se as operações dedutíveis',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAS01','Prestação de Serviços de Transporte - valor contábil das saídas e prestações de serviço de transporte intermunicipal e/ou interestadual, por município baiano de início (origem) da prestação, excluindo-se as operações dedutíveis',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAE02','Aquisição de serviços de Comunicação/Telecomunicação -  valor contábil das entradas e aquisições de serviço de comunicação, por município baiano, proporcionalmente às saídas, excluindo-se as operações dedutíveis',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAS02','Prestação de serviços de Comunicação/Telecomunicação - valor contábil das saídas e prestações de serviço de comunicação, por município baiano onde ocorreu a prestação, excluindo-se as operações dedutíveis',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAE03','Geração e Distribuição de Energia Elétrica e Água - Entradas - valor contábil das entradas  e insumos utilizados na geração e distribuição de energia elétrica ou água, por município baiano, proporcionalmente às saídas, excluindo-se as operações dedutíveis',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAS03','Geração e Distribuição de Energia Elétrica e Água - Saídas - valor contábil das saídas de geração e distribuição de energia elétrica ou água, por município baiano onde ocorreu o fato gerador ou, no caso da distribuição, por município baiano onde ocorreu o fornecimento, excluindo-se as operações dedutíveis',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAE04','Regimes Especiais - Entradas - valor contábil das entradas, por município baiano, para as empresas que possuem regime especial de escrituração centralizada, excluindo-se as operações dedutíveis e observando o disposto no referido regime',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAS04','Regimes Especiais – Saídas - valor contábil das saídas, por município baiano de ocorrência do fato gerador, para as empresas que possuem regime especial de escrituração centralizada, excluindo-se as operações dedutíveis e observando o disposto no referido regime',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAE05','Exclusões nas entradas - IPI e ICMS/ST - Informar, para o município de localização do estabelecimento, a parcela do ICMS retido por substituição tributária e a parcela do IPI que não integra a base de cálculo do ICMS',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAS05','Exclusões nas saídas - IPI e ICMS/ST - Informar, para o município de localização do estabelecimento, a parcela do ICMS retido por substituição tributária e a parcela do IPI que não integre a base de cálculo do ICMS',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAE06','Operações não dedutíveis nas entradas - Informar, para o município de localização do estabelecimento, caso tenham ocorrido, as operações realizadas com os CFOPs genéricos 1949, 2949 e 3949, e que representem uma real movimentação econômica para a empresa, ou seja, gerem valor adicionado (agregado)',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAS06','Operações não dedutíveis nas saídas - Informar, para o município de localização do estabelecimento, caso tenham ocorrido, as operações realizadas com os CFOPs genéricos 5949, 6949 e 7949, e que representem uma real movimentação econômica para a empresa, ou seja, gerem valor adicionado (agregado)',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAE07','Aquisição de produto diferido - Eucalipto - valor das aquisições internas de EUCALIPTO oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAE08','Aquisição de produto diferido - Animais vivos - valor das aquisições internas de GADO BOVINO, SUÍNO, BUFALINO, ASININO, EQUINO E MUAR EM PÉ, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAE09','Aquisição de produto diferido - Leite fresco - valor das aquisições internas de LEITE FRESCO oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAE10','Aquisição de produto diferido - Mariscos/Peixes - valor das aquisições internas de LAGOSTA, CAMARÕES E PEIXES, oriundas de contribuintes não inscritos, por município baiano de origem, acobertadas pelo regime de diferimento',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAE11','Aquisição de produto diferido - Sucatas - valor das aquisições internas de SUCATAS METÁLICAS, SUCATAS NÃO METÁLICAS, SUCATAS DE ALUMÍNIO, FRAGMENTOS, RETALHOS DE PLASTICOS E TECIDOS, SUCATAS DE PNEUS E BORRACHAS – RECICLÁVEIS, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAE12','Aquisição de produto diferido - Couros e Peles - valor das aquisições internas de COUROS E PELES, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAE13','Aquisição de produto diferido - Materiais para combustão - valor das aquisições internas de LENHA E OUTROS MATERIAIS PARA COMBUSTÃO INDUSTRIAL, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAE14','Aquisição de produto diferido - Embalagens e insumos - valor das aquisições internas de EMBALAGENS E INSUMOS oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAE15','Aquisição de produto diferido - Cravo da Índia - valor das aquisições internas de CRAVO DA ÍNDIA, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAE16','Aquisição de produto diferido - Bambu - valor das aquisições internas de BAMBU, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAE17','Aquisição de produto diferido - Resíduo papel/papelão - valor das aquisições internas de RESÍDUOS DE PAPEL E PAPELÃO, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAE18','Aquisição de produto diferido - Sebo, osso, chifre e casco - valor das aquisições internas de SEBO, OSSOS, CHIFRES E CASCO, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAE19','Aquisição de produto diferido - Argila - valor das aquisições internas de ARGILA, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAE20','Aquisição de produto diferido - Outros - valor das aquisições internas de outros produtos não especificados nas linhas anteriores, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAE99','Outros ajustes nas entradas - outros ajustes específicos determinados pela Sefaz BA',5,to_date('01/01/2018','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --   
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'BAS99','Outros ajustes nas saídas - outros ajustes específicos determinados pela Sefaz BA',5,to_date('01/01/2018','dd/mm/rrrr'), null );
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
Prompt FIM Redmine #75312 - Atualização tabela param_ipm (BA)
--------------------------------------------------------------------------------------------------------------------------------------
 