create or replace package csf_own.pk_rel_lucro_expl is
--
------------------------------------------------------------------------------------------------------------------------------------------------------------------
--   
-- Especificação do pacote de Geração dos Relatórios de Calculo de Lucro na Exploração
--
-- Em 12/02/2021  - Luis Marques - 2.9.6-2 / 2.9.7
-- Redmine #75363 - Criação de procedure de relatórios
-- Criação de package para Geração dos Relatórios de Calculo de Lucro na Exploração
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
-- Procedimento para Gerar relatórios de lucro na exploração
procedure pkb_gerar_relatorio ( en_perlucrexpl_id    in     per_lucr_expl.id%type
                              , en_usuario_id        in     per_lucr_expl.usuario_id%type
                              );

------------------------------------------------------------------------------------------------------

end pk_rel_lucro_expl;
/
