create or replace package csf_own.pk_rel_lucro_expl is
--
------------------------------------------------------------------------------------------------------------------------------------------------------------------
--   
-- Especifica��o do pacote de Gera��o dos Relat�rios de Calculo de Lucro na Explora��o
--
-- Em 12/02/2021  - Luis Marques - 2.9.6-2 / 2.9.7
-- Redmine #75363 - Cria��o de procedure de relat�rios
-- Cria��o de package para Gera��o dos Relat�rios de Calculo de Lucro na Explora��o
--
-------------------------------------------------------------------------------------------------------

   gt_log_generico   dbms_sql.number_table;
   gv_mensagem       log_generico.mensagem%type;
   gv_resumo         log_generico.resumo%type;
   gn_referencia_id  log_generico.referencia_id%type := null;
   gv_obj_referencia log_generico.obj_referencia%type default 'PER_LUCR_EXPL';
   gn_empresa_id     empresa.id%type;
   gn_multorg_id     mult_org.id%type;   
   --
   erro_de_validacao     constant number := 1;
   erro_de_sistema       constant number := 2;
   informacao            constant number := 35;
   --
   gt_row_per_lucr_expl  per_lucr_expl%rowtype; 
   -- 
  
-------------------------------------------------------------------------------------------------------
-- Procedimento para Gerar relat�rios de lucro na explora��o
procedure pkb_gerar_relatorio ( en_perlucrexpl_id    in     per_lucr_expl.id%type
                              , en_usuario_id        in     per_lucr_expl.usuario_id%type
                              );

------------------------------------------------------------------------------------------------------

end pk_rel_lucro_expl;
/
