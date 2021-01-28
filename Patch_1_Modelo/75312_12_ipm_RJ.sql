-------------------------------------------------------------------------------------------------------------------------------
Prompt INI Redmine #75312 - Atualização tabela param_ipm (RJ)
-------------------------------------------------------------------------------------------------------------------------------
begin
   --  
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF20001','Valor adicionado por operações e prestações não escrituradas, denunciadas espontaneamente ou apuradas em ação fiscal',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF20002','Valor adicionado por aquisições de produtos agrícolas, pastoris, extrativos minerais, pescados ou outros produtos extrativos ou agropecuários sem nota fiscal de produtor',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF20003','Valor adicionado pela prestação de serviço de transporte intermunicipal e interestadual',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF20004','Valor adicionado pelo fornecimento de energia elétrica por geradora hidrelétrica',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF00005','Prestação de serviço de comunicação ou telecomunicação oneroso para consumidor final - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF10005','Prestação de serviço de comunicação ou telecomunicação oneroso para consumidor final - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF00006','Inscrição estadual centralizada - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF10006','Inscrição estadual centralizada - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF00007','Fornecimento de energia elétrica por distribuidora - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF10007','Fornecimento de energia elétrica por distribuidora - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF00008','Fornecimento de água natural canalizada - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), to_date('31/12/2019','dd/mm/rrrr') );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF10008','Fornecimento de água natural canalizada - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), to_date('31/12/2019','dd/mm/rrrr') );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF00009','Fornecimento de gás natural canalizado - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF10009','Fornecimento de gás natural canalizado - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAR00010','Fornecimento por geradora de energia elétrica gerada em modalidade distinta da hidrelétrica - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAR10010','Fornecimento por geradora de energia elétrica gerada em modalidade distinta da hidrelétrica - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF00011','Atividades de extração e produção de petróleo e gás - BLOCO DE EXPLORAÇÃO - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF10011','Atividades de extração e produção de petróleo e gás - BLOCO DE EXPLORAÇÃO - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF00112','Atividades de extração e produção de petróleo e gás - ALBACORA - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF10112','Atividades de extração e produção de petróleo e gás - ALBACORA - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF00212','Atividades de extração e produção de petróleo e gás - ALBACORA LESTE - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF10212','Atividades de extração e produção de petróleo e gás - ALBACORA LESTE - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF00312','Atividades de extração e produção de petróleo e gás - ANEQUIM - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF10312','Atividades de extração e produção de petróleo e gás - ANEQUIM - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF00412','Atividades de extração e produção de petróleo e gás - ATLANTA - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF10412','Atividades de extração e produção de petróleo e gás - ATLANTA - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF00512','Atividades de extração e produção de petróleo e gás - BADEJO - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF10512','Atividades de extração e produção de petróleo e gás - BADEJO - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF00612','Atividades de extração e produção de petróleo e gás - BAGRE - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF10612','Atividades de extração e produção de petróleo e gás - BAGRE - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF00712','Atividades de extração e produção de petróleo e gás - BARRACUDA - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF10712','Atividades de extração e produção de petróleo e gás - BARRACUDA - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF00812','Atividades de extração e produção de petróleo e gás - BERBIGÃO - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF10812','Atividades de extração e produção de petróleo e gás - BERBIGÃO - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF00912','Atividades de extração e produção de petróleo e gás - BICUDO - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF10912','Atividades de extração e produção de petróleo e gás - BICUDO - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF01012','Atividades de extração e produção de petróleo e gás - BIJUPIRÁ - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF11012','Atividades de extração e produção de petróleo e gás - BIJUPIRÁ - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF01112','Atividades de extração e produção de petróleo e gás - BONITO - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF11112','Atividades de extração e produção de petróleo e gás - BONITO - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF01212','Atividades de extração e produção de petróleo e gás - BÚZIOS - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF11212','Atividades de extração e produção de petróleo e gás - BÚZIOS - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF01312','Atividades de extração e produção de petróleo e gás - CARAPEBA - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF11312','Atividades de extração e produção de petróleo e gás - CARAPEBA - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF01412','Atividades de extração e produção de petróleo e gás - CARATINGA - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF11412','Atividades de extração e produção de petróleo e gás - CARATINGA - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF01512','Atividades de extração e produção de petróleo e gás - CHERNE - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF11512','Atividades de extração e produção de petróleo e gás - CHERNE - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF01612','Atividades de extração e produção de petróleo e gás - CONGRO - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF11612','Atividades de extração e produção de petróleo e gás - CONGRO - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF01712','Atividades de extração e produção de petróleo e gás - CORVINA - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF11712','Atividades de extração e produção de petróleo e gás - CORVINA - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF01812','Atividades de extração e produção de petróleo e gás - ENCHOVA - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF11812','Atividades de extração e produção de petróleo e gás - ENCHOVA - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF01912','Atividades de extração e produção de petróleo e gás - ENCHOVA OESTE - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF11912','Atividades de extração e produção de petróleo e gás - ENCHOVA OESTE - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF02012','Atividades de extração e produção de petróleo e gás - ESPADARTE - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF12012','Atividades de extração e produção de petróleo e gás - ESPADARTE - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF02112','Atividades de extração e produção de petróleo e gás - FRADE - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF12112','Atividades de extração e produção de petróleo e gás - FRADE - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF02212','Atividades de extração e produção de petróleo e gás - GAROUPA - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF12212','Atividades de extração e produção de petróleo e gás - GAROUPA - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF02312','Atividades de extração e produção de petróleo e gás - GAROUPINHA - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF12312','Atividades de extração e produção de petróleo e gás - GAROUPINHA - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF02412','Atividades de extração e produção de petróleo e gás - ITAPU - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF12412','Atividades de extração e produção de petróleo e gás - ITAPU - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF02512','Atividades de extração e produção de petróleo e gás - LINGUADO - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF12512','Atividades de extração e produção de petróleo e gás - LINGUADO - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF02612','Atividades de extração e produção de petróleo e gás - LULA - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF12612','Atividades de extração e produção de petróleo e gás - LULA - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF02712','Atividades de extração e produção de petróleo e gás - MALHADO - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF12712','Atividades de extração e produção de petróleo e gás - MALHADO - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF02812','Atividades de extração e produção de petróleo e gás - MARIMBÁ - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF12812','Atividades de extração e produção de petróleo e gás - MARIMBÁ - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF02912','Atividades de extração e produção de petróleo e gás - MARLIM - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF12912','Atividades de extração e produção de petróleo e gás - MARLIM - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF03012','Atividades de extração e produção de petróleo e gás - MARLIM LESTE - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF13012','Atividades de extração e produção de petróleo e gás - MARLIM LESTE - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF03112','Atividades de extração e produção de petróleo e gás - MARLIM SUL - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF13112','Atividades de extração e produção de petróleo e gás - MARLIM SUL - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF03212','Atividades de extração e produção de petróleo e gás - MORÉIA - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF13212','Atividades de extração e produção de petróleo e gás - MORÉIA - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF03312','Atividades de extração e produção de petróleo e gás - NAMORADO - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF13312','Atividades de extração e produção de petróleo e gás - NAMORADO - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF03412','Atividades de extração e produção de petróleo e gás - NE NAMORADO - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF13412','Atividades de extração e produção de petróleo e gás - NE NAMORADO - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF03512','Atividades de extração e produção de petróleo e gás - PAMPO - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF13512','|tividades de extração e produção de petróleo e gás - PAMPO - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF03612','Atividades de extração e produção de petróleo e gás - PAPA-TERRA - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF13612','Atividades de extração e produção de petróleo e gás - PAPA-TERRA - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF03712','Atividades de extração e produção de petróleo e gás - PARATI - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF13712','Atividades de extração e produção de petróleo e gás - PARATI - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF03812','Atividades de extração e produção de petróleo e gás - PARGO - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF13812','Atividades de extração e produção de petróleo e gás - PARGO - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF03912','Atividades de extração e produção de petróleo e gás - PEREGRINO - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF13912','Atividades de extração e produção de petróleo e gás - PEREGRINO - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF04012','Atividades de extração e produção de petróleo e gás - PIRAÚNA - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF14012','Atividades de extração e produção de petróleo e gás - PIRAÚNA - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF04112','Atividades de extração e produção de petróleo e gás - POLVO - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF14112','Atividades de extração e produção de petróleo e gás - POLVO - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF04212','Atividades de extração e produção de petróleo e gás - RONCADOR - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF14212','Atividades de extração e produção de petróleo e gás - RONCADOR - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF04312','Atividades de extração e produção de petróleo e gás - SALEMA - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF14312','Atividades de extração e produção de petróleo e gás - SALEMA - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF04412','Atividades de extração e produção de petróleo e gás - SAPINHOÁ - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF14412','Atividades de extração e produção de petróleo e gás - SAPINHOÁ - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF04512','Atividades de extração e produção de petróleo e gás - SÉPIA - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF14512','Atividades de extração e produção de petróleo e gás - SÉPIA - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF04612','Atividades de extração e produção de petróleo e gás - SUL DE LULA - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF14612','Atividades de extração e produção de petróleo e gás - SUL DE LULA - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF04712','Atividades de extração e produção de petróleo e gás - TAMBAÚ - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF14712','Atividades de extração e produção de petróleo e gás - TAMBAÚ - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF04812','Atividades de extração e produção de petróleo e gás - TARTARUGA VERDE - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF14812','Atividades de extração e produção de petróleo e gás - TARTARUGA VERDE - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF04912','Atividades de extração e produção de petróleo e gás - TRILHA - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF14912','Atividades de extração e produção de petróleo e gás - TRILHA - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF05012','Atividades de extração e produção de petróleo e gás - TUBARÃO AZUL - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF15012','Atividades de extração e produção de petróleo e gás - TUBARÃO AZUL - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF05112','Atividades de extração e produção de petróleo e gás - TUBARÃO MARTELO - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF15112','Atividades de extração e produção de petróleo e gás - TUBARÃO MARTELO - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF05212','Atividades de extração e produção de petróleo e gás - URUGUÁ - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF15212','Atividades de extração e produção de petróleo e gás - URUGUÁ - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF05312','Atividades de extração e produção de petróleo e gás - VERMELHO - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF15312','Atividades de extração e produção de petróleo e gás - VERMELHO - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF05412','Atividades de extração e produção de petróleo e gás - VIOLA - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF15412','Atividades de extração e produção de petróleo e gás - VIOLA - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF05512','Atividades de extração e produção de petróleo e gás - VOADOR - Valor das entradas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF15512','Atividades de extração e produção de petróleo e gás - VOADOR - Valor das saídas',19,to_date('01/01/2019','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF05612','Atividades de extração e produção de petróleo e gás - MERO- Valor das entradas',19,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF15612','Atividades de extração e produção de petróleo e gás - MERO - Valor das saídas',19,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF05712','Atividades de extração e produção de petróleo e gás - TAMBUATÁ - Valor das entradas',19,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF15712','Atividades de extração e produção de petróleo e gás - TAMBUATÁ - Valor das saídas',19,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF00013','Prestação de Serviço de comunicação ou telecomunicação gratuito para consumidor final - Valor das entradas',19,to_date('01/01/2020','dd/mm/rrrr'), null );
   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END;
   --
   BEGIN
     insert into CSF_OWN.param_ipm( id , cod_ipm , descr , estado_id , dt_ini , dt_fim  )
         values ( CSF_OWN.paramipm_seq.nextval ,'RJVAF10013','Prestação de Serviço de comunicação ou telecomunicação gratuito para consumidor final - Valor das saídas',19,to_date('01/01/2020','dd/mm/rrrr'), null );
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
Prompt FIM Redmine #75312 - Atualização tabela param_ipm (RJ)
--------------------------------------------------------------------------------------------------------------------------------------
 