create or replace package csf_own.pk_gera_lucro_expl is
--
------------------------------------------------------------------------------------------------------------------------------------------------------------------
--   
-- Especificação do pacote de Geração de Calculo de Lucro na Exploração
--
-- Em 02/02/2021  - Luis Marques - 2.9.6-2 / 2.9.7
-- Redmine #75361 - Desenvolver estrutura para calculo do lucro da exploração
-- Criação de package para Geração de Calculo de Lucro na Exploração
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
-- Validar os calculos para o Lucro da Exploração.
procedure pkb_validar ( est_log_generico     in out nocopy  dbms_sql.number_table
                      , en_perlucrexpl_id    in     per_lucr_expl.id%type
                      );
   
-------------------------------------------------------------------------------------------------------
-- Procedimento para Gerar lucro na exploração
procedure pkb_gerar ( en_perlucrexpl_id    in     per_lucr_expl.id%type
                    );

-------------------------------------------------------------------------------------------------------
-- Procedimento de desfazer o Lucro da Exploração.
procedure pkb_desfazer ( est_log_generico     in out nocopy  dbms_sql.number_table
                       , en_perlucrexpl_id    in     per_lucr_expl.id%type
                       );

-------------------------------------------------------------------------------------------------------

end pk_gera_lucro_expl;
/
