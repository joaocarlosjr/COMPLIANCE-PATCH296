create or replace package csf_own.pk_gera_dados_reinf is

-------------------------------------------------------------------------------------------------------
--
-- Especificação do pacote de geração dos eventos do EFD-REINF
--
------------------------------------------------------------------------------------------------------------------------------
--
-- Em 27/01/2021 - Marcos Ferreira
-- Distribuições: 2.9.7 / 2.9.6-1 / 2.9.5-4
-- Redmine #75266 - Erro na retificação de eventos [reicidente]
-- Rotinas Alteradas: pkb_gera_id_evt_reinf
--
-- Em 25/11/2020     - Luis Marques - 2.9.4-5 / 2.9.5-2 / 2.9.6
-- Redmine #73526    - Melhoria] [REINF] Criar validação para time-out quando eventos ficarem travados no dmstproc=1 (Validado)
-- Rotinas Alteradas - pkb_gera_evt_r2010, pkb_gera_evt_r2020 - Colocado loop para percorrer os erros no ofinal de cada
--                     uma das rotinas para não deixar registro com erro de validação como validado.
--
-- Em 19/11/2020 - Marcos Ferreira
-- Distribuições: 2.9.6 / 2.9.5-2 / 2.9.4-5
-- Redmine 72267: Evento de Retificação exclui nota original [REINF R2010/R2020]
-- Rotinas Alteradas: pkb_retif_evt_r2010
--
-- Em 14/09/2020 - Eduardo Linden
-- Redmine #71434 - Alteração sobre a geração do Evento R2020 sobre o CNO (REINF) 
-- Alteração na rotina evento R2020, onde o tomador para a ser CNO e o prestador , a Inscrição de Estabelecimento
-- Rotina alterada: pkb_monta_array_r2020
-- Liberado para Release 295 e patchs 2.9.3.6 e 2.9.4.3
--
-- Em 10/09/2020 - Marcos Ferreira
-- Distribuições: 2.9.5 / 2.9.4-3 / 2.9.3-6
-- Redmine #62104	- Retificação do evento R-2060
-- Rotinas Alteradas: pkb_exist_evt_r2060, pkb_gera_evt_r2060. Criação: pkb_retif_evt_r2060
--
-- Em 17/08/2020 - Eduardo Linden
-- Redmine #70618 - Correção sobre a validação sobre informação não gerada para os Eventos R2010 eR2020 (Reinf)
-- Inclusão da clausula dm_arm_nfe_terc =0 para os cursores c_r2010_nf e c_r2020_nf
-- Procedure alterada: pkb_vld_inf_nao_enviada
-- Liberado para Release 295 e patchs 2.9.3.5 e 2.9.4.2
--
-- Em 30/07/2020 - Eduardo Linden
-- Redmine #70042 - Erro na pk_gera_dados_reinf.pkb_gera_evt_r2010 fase(3): ORA-06502: PL/SQL: numeric or value error
-- Tratar erro do titulo da atividade e mudança nos cursores de nota fiscal de entrada e de conhecimento de transporte.
-- Procedure alterada: pkb_monta_array_r2010 e pkb_gera_evt_r2010
-- Liberado para Release 295 e patchs 2.9.3.5 e 2.9.4.2
--
-- Em 27/07/2020 - Eduardo Linden
-- Redmine #69846 - Alteração na geração dos registros do evento R2010
-- Alteração nos cursores de notas de serviço e conhecimento de transporte,
-- a fim de evitar problemas com empresas com mais de um multorg.
-- Procedure alterada: pkb_monta_array_r2010
-- Liberado para Release 295 e patchs 2.9.3.5 e 2.9.4.2
--
-- Em 11/06/2020 - Marcos Ferreira
-- Distribuições: 2.9.3-2 / 2.9.4
-- Redmine #68477: Erro na geração de eventos REINF - Dados Juridico não vincula ao participante
-- Rotinas Alteradas: pkb_monta_array_r2010, pkb_gera_evt_r2010
-- Procedure Removida: pkb_exist_evt_r2010
-- Alterações: Reestruturação do processo de geração do evento R2010
--
-- Em 15/05/2020 - Marcos Ferreira
-- Distribuições: 2.9.3-2 / 2.9.2-5 / 2.9.4
-- Redmine #66768: Erro de geração eventos REINF - R2010_R2020
-- Rotina: pkb_monta_array_r2010, pkb_monta_array_r2020
-- Alterações: Incluído tratativa para não recuperar as notas do MIDAS no cursor
--
-- Em 13/12/2019 - Marcos Ferreira
-- Redmine #62438: Evento com o status de validado.
-- Alterações: Incluído validação do vl_total_serv na geração dos eventos
-- Procedures Alteradas: pkb_monta_array_r2010, pkb_monta_array_r2020
--
-- Em 30/10/2019 - Marcos Ferreira
-- Redmine #59391: Verificar o processo de TRUNC/ ROUND da PK_GERA_DADOS_REINF
-- Alterações: Alterado cursor c_imp, linha que monta o vl_imp_calculado. Seguindo a regra da RFB, 
--             Antes aplicava-se a regra antes do Sum, dando divergencia de 0,01 em alguns casos.
--             Agora faz-se primeiro o sum e depois aplica-se a regra do trunc.
-- Procedures Alteradas: pkb_valida_rnd_inss_r2010
--
-- Em 09/10/2019 - Renan Alves
-- Redmine #55767 - Verificar Processo de Status Validado do REINF
-- Foi incluído mais uma condição no where dos updates que passam os registros para a situação "validado"
-- Rotina: pkb_gera_evt_r2010, pkb_exist_evt_r2010, pkb_gera_evt_r2020, pkb_exist_evt_r2020 e pkb_gera_evt
--
-- Em 14/08/2019 - Eduardo Linden
-- Redmine #57514 - REINF R1070 não está sendo gerado
-- Foi incluido a chamada da function pk_csf.fkg_param_global_csf_form_data para que seu retorno seja utilizado na variavel gv_formato_data.
-- A variavel gv_formato_data vai ser utilizada no cursor c_proc, devido a problema na execução mesmo em não retornar valor.
-- Procedure alterada: pkb_gera_evt_r1070
--
-- Em 09/08/2019 - Eduardo Linden
-- Redmine #57328 - Correção na rotina que carrega os arrays do evento R2020 (REINF)
-- Foi criada uma segunda variavel pls_integer para melhorar a carga dos arrays vt_tri_tab_index_evt_r2020 e vt_bi_tab_index_evt_r2020_nf.
-- O objetivo desta evitar que notas sejam vinculadas no evento R2020 em empresa diferente do que está registrada na nota fiscal.
-- Procedures Alteradas: pkb_monta_array_r2020 e pkb_gera_evt_r2020
--
------------------------------------------------------------------------------------------------------------------------------
-- Em 11/04/2018 - Marcelo Ono.
-- Redmine #38773 - Correções e implementações nos processos do projeto REINF.
-- 1- Corrigido o comentário da variável "gt_row_geracao_efd_reinf.dm_situacao := 2" para "Aberto";
-- 2- Corrigido a query que verifica se já existe um evento de inclusão para a empresa, filtrando o último evento de inclusão para a empresa logada;
-- 3- Corrigido as mensagens de logs que estavam referenciando objeto de referência errado;
-- 4- Corrigido a variável de "gt_row_efd_reinf_r2020_nf" por "gt_row_efdreinfr2030_recreceb" que estava sendo referenciada errada;
-- 5- Corrigido o processo, permitindo que seja reenviado os eventos com status "5-Erro no Envio e 6-Rejeitado", pois terá um timer que deverá reprocessar
-- os eventos com status "0-Aberto e 2-Erro de Validação";
-- 6- Implementado processo para atualizar a situação do evento após a sua exclusão.
-- 7- Corrigido o processo, para implementar a data inicial da geração na criação de um evento R-1000 de inclusão, após constatar que existe
-- o evento de exclusão para a geração EFD Reinf;
-- 8- Implementado processo para recuperar os dados do último evento R-1000 gerado;
-- 9- Implementado processo para recuperar os dados do último evento R-1070 gerado;
-- 10- Recodificado o processo de geração dos eventos R-1000 e R-1070, implementando o auto-relacionamento para os registros de Alteração/Exclusão
-- dos eventos R-1000 e R-1070;
-- 11- Implementado os processos para reenviar os eventos R-2098, R-2099 e R-9000;
-- 12- Implementado processo para atualizar o status do evento excluído;
-- 13- Criado processo para armazenar o valor do "loggenerico_id";
-- 14- Implementado o processo de fechamento de período da geração, sendo implementado uma regra para os eventos periódicos e não periódicos;
-- 15- Alterado o processo de abertura do Reinf, sendo implementado uma regra para os eventos periódicos e não periódicos;
-- 16- Criado processo que valida o prazo de envio dos eventos;
-- 17- Implementado processo para bloquear a geração e reenvio dos eventos que estiverem com prazo de envio vencido;
-- 18- Implementado processo, para enviar o id do evento no processo de validação do evento;
-- 19- Alterado o processo de geraçao dos eventos R-2010, R-2020, R-2030, R-2040, R-2050, R-2060, R-2070 e R-3010;
-- 20- Recodificado o processo que valida se existe eventos que ainda não foram processados pelo EFD-REINF;
-- 21- Implementado o auto-relacionamento para os registros retificados dos eventos R-2010, R-2020, R-2030, R-2040, R-2050, R-2060, R-2070 e R-3010;
-- 22- Alterado o processo de geração do evento R-3010 para ser gerado um evento por receita de espetáculo desportivo;
-- 23- Excluído a procedure "pkb_rec_evt_anterior_r3010" que recuperava as receitas de espetáculos desportivos do último evento e relacionava ao novo evento;
-- 24- Implementado processo de retificação da nota fiscal de entrada do evento R-2010;
-- 25- Implementado processo de retificação da nota fiscal de saída do evento R-2020;
-- 26- Implementado processo de retificação do recurso recebido por associação desportiva do evento R-2030;
-- 27- Implementado processo de retificação do recurso repassado para associação desportiva do evento R-2040;
-- 28- Implementado processo de retificação do pagamento de imposto retido do evento R-2070;
-- 29- Excluído o processo que atualizava a situação "dm_envio = 1" dos dados enviados ao Reinf, pois este processo será executado via trigger após 
-- a validação e retorno da mensageria.
-- 30- Alterado o processo de reabertura do tipo periódico do Reinf, para atualizar a situação de "4-Fechado" para "2-Aberto" após o evento R-2098
-- estar processado no SEFAZ e com a situação "4-Processado", garantindo que nenhum evento seja gerado antes da validação do SEFAZ e retorno da mensageria.
-- Obs: Criado a trigger "t_a_u_efd_reinf_r2098_01" para atualizar a situação da geração após a validação do SEFAZ e retorno da mensageria.
-- 31- Mantido o processo de fechamento do tipo periódico do Reinf, para atualizar a situação "2-Aberto ou 3-Erro no fechamento" para
-- "3-Erro no fechamento ou 4-Fechado" após a geração do evento R-2099, garantindo que nenhum evento seja gerado antes da validação do SEFAZ e retorno da mensageria.
-- Obs: Criado a trigger "t_a_u_efd_reinf_r2099_01" para atualizar a situação da geração após a validação do SEFAZ e retorno da mensageria.
-- 32- Corrigido o processo de geração do ID do evento, respeitando a geração do ID com 36 caracteres (regra_valida_id_evento); 
-- Rotinas: pkb_abrir_periodo_reinf, pkb_gera_evt_r1000, pkb_reenviar_evt_r1000, pkb_gera_evt_r1070, pkb_reenviar_evt_r1070, pkb_gera_evt_r2010,
--          pkb_reenviar_evt_r2010, pkb_gera_evt_r2020, pkb_reenviar_evt_r2020, pkb_gera_evt_r2030, pkb_reenviar_evt_r2030, pkb_gera_evt_r2040,
--          pkb_reenviar_evt_r2040, pkb_gera_evt_r2050, pkb_reenviar_evt_r2050, pkb_gera_evt_r2060, pkb_reenviar_evt_r2060, pkb_gera_evt_r2070,
--          pkb_reenviar_evt_r2070, pkb_gera_evt_r3010, pkb_reenviar_evt_r3010, pkb_gera_evt_r2099, pkb_reenviar_evt_r2099, pkb_exist_evt_r2030,
--          pkb_gera_evt_r9000, pkb_reenviar_evt_r9000, pkb_rec_ultimo_evento_r1000, pkb_rec_ultimo_evento_r1070, pkb_gera_evt_r2098,
--          pkb_reenviar_evt_r2098, pkb_gt_log_generico_reinf, pkb_fechar_periodo_reinf, pkb_vld_evt_espera, pkb_vld_inf_nao_enviada,
--          pkb_abrir_periodo_reinf, pkb_exist_evt_r2010, pkb_exist_evt_r2020, pkb_exist_evt_r2030, pkb_exist_evt_r2040, pkb_exist_evt_r2050,
--         pkb_exist_evt_r2060, pkb_exist_evt_r2070, pkb_exist_evt_r3010, pkb_retif_evt_r2040, pkb_gera_id_evt_reinf.
--
-- Em 20/04/2018 - Marcelo Ono.
-- Redmine #41894 - Correções nas funções que verificam se existe log de alteração para os Parâmetros EFD Reinf e Processos Administrativos/Judiciários.
-- 1- Alterado a chamada da função "pk_csf_reinf.fkg_existe_logparamefdreinfemp", sendo retirado o parãmetro "ed_dt_fin";
-- 2- Alterado a chamada da função "pk_csf_reinf.fkg_existe_logprocadmefdreinf", sendo retirado o parãmetro "ed_dt_fin";
-- 3- Alterado processo de geração do evento R-2070, sendo recupera apenas os impostos retidos IR, Pis, Cofins, Csll e Pcc;
-- 4- Comentado a chamada da procedure "pkb_gera_evt_r2070", pois conforme alinhado com a consultoria "célula Reinf" os eventos R-2070 estão suspensos
-- de envio até o segundo semestre de 2018.
-- Rotina: pkb_gera_evt_r1000 e pkb_gera_evt_r1070, pkb_monta_array_r2070 e pkb_geracao_eventos.
--
-- Em 21/04/2018 - Marcelo Ono.
-- Redmine #41933 - Correção no processo de geração de eventos
-- 1- Alterado processo de geração dos eventos R-1000 e R-1070, para que seja gerado um evento do tipo "1-Inclusão", sempre que o último evento com
-- a situação "4-Processado" seja do tipo "2-Exclusão";
-- 2- Alterado processo de geração dos eventos R-2010, R-2020, R-2030, R-2040, R-2050, R-2060, R-2070 e R-3010, para que seja gerado um evento do tipo "1-Original",
-- sempre que o último evento esteja com a situação "7-Exclusão";
-- Rotina: pkb_gera_evt_r1000 e pkb_gera_evt_r1070, pkb_exist_evt_r2010, pkb_exist_evt_r2020, pkb_exist_evt_r2030, pkb_exist_evt_r2040, pkb_exist_evt_r2050,
--         pkb_exist_evt_r2060, pkb_exist_evt_r2070 e pkb_exist_evt_r3010.
--
-- Em 24/04/2018 - Marcelo Ono.
-- Redmine #42065 - Implementado processo que grava a quantidade de registros gerados por evento.
-- Rotina: pkb_gerar_resumo_reinf, pkb_geracao_periodo_online, pkb_abrir_periodo_reinf e pkb_fechar_periodo_reinf.
--
-- Em 25/04/2018 - Marcelo Ono.
-- Redmine #42036 - Retirado o processo de validação do prazo de envio Reinf, pois a empresa poderá enviar um evento com o prazo vencido, mas estará sujeita a multa.
-- Rotina: pb_valida_prazo_envio_evt, pkb_gera_evt_r1000 e pkb_gera_evt_r1070, pkb_exist_evt_r2010, pkb_exist_evt_r2020, pkb_exist_evt_r2030,
--         pkb_exist_evt_r2040, pkb_exist_evt_r2050, pkb_exist_evt_r2060, pkb_exist_evt_r2070, pkb_gera_evt_r2099 e pkb_exist_evt_r3010, pkb_gera_evt_r9000.
--
-- Em 27/04/2018 - Marcelo Ono.
-- Redmine #42209 - Correção no processo de geração de eventos
-- 1- Corrigido o processo de geração do ID do evento EFD Reinf, sendo informado o tempo "segundos" na geração do ID;
-- 2- Implementado processo na geração dos eventos "R-1000 e R-1070" para gerar o evento com o tipo "Alteração de validade", apenas quando estiver sendo
-- gerado um novo evento "R-1000 e R-1070" em outro período de geração;
-- 3- Alterado a function "pkb_rec_ultimo_evento_r1000", sendo retirado o parâmetro e filtro utilizados para recuperar os dados do evento original;
-- 4- Alterado a function "pkb_rec_ultimo_evento_r1070", sendo retirado o parâmetro e filtro utilizados para recuperar os dados do evento original;
-- Rotina: pkb_gera_id_evt_reinf, pkb_gera_evt_r1000, pkb_gera_evt_r1070, pkb_rec_ultimo_evento_r1000, pkb_rec_ultimo_evento_r1070.
--
-- Em 01/05/2018 - Marcelo Ono.
-- Redmine #42348 - Correção no processo de geração de eventos
-- 1- Correção no processo que grava a quantidade de registros gerados por evento;
-- 2- Correção no processos que recuperam e relacionam os registros do evento antigo com o novo evento;
-- 3- Correção no processo de reenvio do evento R-3010, para que seja validado os registros de receita de espetáculo desportivo;
-- Rotina: pkb_gerar_resumo_reinf, pkb_rec_nf_evt_anterior_r2010, pkb_rec_nf_evt_anterior_r2020, pkb_rec_evt_anterior_r2030, pkb_rec_evt_anterior_r2040,
--         pkb_rec_evt_anterior_r2070, pkb_reenviar_evt_r3010.
--
-- Em 02/05/2018 - Marcelo Ono.
-- Redmine #42368 - Correção no processo de geração de eventos
-- 1- Alterado o processo de geração de eventos, para que ao criar um novo evento, seja criado o auto-relacionamento com o último evento que
-- esteja com a situação "4-Processado";
-- Rotina: pkb_exist_evt_r2010, pkb_exist_evt_r2020, pkb_exist_evt_r2030, pkb_exist_evt_r2040, pkb_exist_evt_r2050, pkb_exist_evt_r2060, pkb_exist_evt_r2070,
--         pkb_exist_evt_r3010.
--
-- Em 03/05/2018 - Marcelo Ono.
-- Redmine #42361 - Correção no processo de exclusão de eventos periódicos e não periódicos e no processo de geração do ID do evento.
-- 1- Correção no processo de geração do evento R-9000, para que não atualize a situação dos evento periódicos e não periódicos para "7-Excluído"
-- se o evento R-9000 não estiver com a situação "4-Processado";
-- 2- Correção no processo de geração do ID do evento, para que quando existir um controle de geração EFD Reinf, seja atualizado a data hora do evento,
-- sequência e o ID do evento.
-- Rotina: pkb_gera_evt_r9000, pkb_gera_id_evt_reinf.
--
-- Em 07/05/2018 - Marcelo Ono.
-- Redmine #42361 - Alteração no processo de geração de eventos.
-- 1- Alteração no processo de geração de eventos, permitindo que seja efetuado a geração de eventos, mesmo que a situação da geração esteja "3-Erro no fechamento",
-- consequentemente, após a geração de eventos, a situação da geração será atualizada para "2-Aberto".
-- Rotina: pkb_abrir_periodo_reinf, pkb_geracao_periodo_offline, pkb_geracao_periodo_online.
--
-- Em 18/05/2018 - Marcelo Ono.
-- Redmine #42998 - Alteração no processo de geração do evento R-2010 e R-2020.
-- 1- Alteração no processo de geração dos eventos R-2010 e R-2020, para que seja recuperado as notas fiscais utilizando a data de emissão como data de referência 
-- da geração da EFD Reinf;
-- 2- Alteração no processo de geração do evento R-2070, para que seja recuperado os pagamentos de impostos de retidos utilizando a data do documento como data de
-- referência da geração EFD Reinf;
-- 3- Implementado processo na recuperação da data inicial e data final da geração EFD Reinf, sendo complementado com a hora e minuto, para que não seja utilizado
-- o comando "TRUNC" nas consultas das informações da geração EFD Reinf.
-- Rotina: pkb_dados_geracao_reinf, pkb_monta_array_r2010, pkb_monta_array_r2020, pkb_monta_array_r2070.
--
-- Em 25/05/2018 - Marcelo Ono.
-- Redmine #43336 - Correção no processo de geração do evento R-9000, validando se o evento excluído está com a situação "4- Processado ou 8-Processado R-5011".
-- Rotina: pkb_gera_evt_r9000.
--
-- Em 28/05/2018 - Marcelo Ono.
-- Redmine #43398 - Alteração no processo de geração dos eventos R-2010 e R-2020, validando se imposto de INSS está com valor tributado e valor da base de cálculo
-- maior que zero.
-- Rotina: pkb_monta_array_r2010 e pkb_monta_array_r2020.
--
-- Em 30/05/2018 - Marcelo Ono.
-- Redmine #38773 - Correção no processo de geração dos eventos R-1000 e R-1070, para que ao gerar um evento do tipo "4-Alteração de validade" onde o último
-- evento processado seja do tipo "4-Alteração de validade", automaticamente, seja gerado o evento com a data inicial de apuração idêntica a data inicial da geração
-- do último evento e com data final nula.
-- Rotina: pkb_gera_evt_r1000 e pkb_gera_evt_r1070.
--
-- Em 05/06/2018 - Marcelo Ono.
-- Redmine #43581 - Correção no processo de geração dos eventos R-2010, R-2020, R-2040, R-2050, R-2060 e R-3010, para que seja gerado um evento do tipo  "2-Retificado"
-- sempre que o último evento processado esteja com a situação "4- Processado ou 8-Processado R-5001".
-- Rotina: pkb_exist_evt_r2010, pkb_exist_evt_r2020, pkb_exist_evt_r2040, pkb_exist_evt_r2050, pkb_exist_evt_r2060, pkb_exist_evt_r3010.
--
-- Em 08/06/2018 - Marcelo Ono.
-- Redmine #38773 - Correção no processo de geração dos eventos R-2010 e R-2020, sendo alterado o tipo do índice de "binary_integer" para "varchar2(38)", pois o tipo
-- "binary_integer" só permite 10 dígitos.
-- Rotina: pk_gera_dados_reinf.pks.
--
-- Em 21/06/2018 - Marcelo Ono.
-- Redmine #43383 - Implementado processo para tratar a situação "6-Erro na montagem do XML".
-- Rotina: pkb_reenviar_evt_r1000, pkb_reenviar_evt_r1070, pkb_reenviar_evt_r2010, pkb_reenviar_evt_r2020, pkb_reenviar_evt_r2030, pkb_reenviar_evt_r2040
--       , pkb_reenviar_evt_r2050, pkb_reenviar_evt_r2060, pkb_reenviar_evt_r2070, pkb_reenviar_evt_r2098, pkb_reenviar_evt_r2099, pkb_reenviar_evt_r3010
--       , pkb_reenviar_evt_r9000, pkb_vld_evt_espera.
--
-- Em 22/06/2018 - Marcelo Ono.
-- Redmine #44271 - Alterado os processos de gerações dos eventos R-1000/R-1070 para que não seja gerado os eventos com o tipo "4-Alteração de validade".
-- Rotina: pkb_gera_evt_r1000 e pkb_gera_evt_r1070.
--
-- Em 26/06/2018 - Marcelo Ono.
-- Redmine #38773 - Alterado o ID e o objeto de referência dos logs do proceso de geração de eventos.
-- Rotina: pkb_gera_evt_r1000, pkb_gera_evt_r1070, pkb_gera_evt_r2010, pkb_monta_array_r2010, pkb_reenviar_evt_r2010, pkb_monta_array_r2020, pkb_reenviar_evt_r2020
--       , pkb_monta_array_r2030, pkb_reenviar_evt_r2030, pkb_monta_array_r2040, pkb_reenviar_evt_r2040, pkb_reenviar_evt_r2050, pkb_reenviar_evt_r2060
--       , pkb_reenviar_evt_r2060, pkb_reenviar_evt_r2070, pkb_reenviar_evt_r3010, pkb_reenviar_evt_r2098, pkb_gera_evt_r9000.
--
-- Em 28/06/2018 - Marcelo Ono.
-- Redmine #44189 - Implementado processo para excluir os eventos com a situação "5-Erro no envio e 6-Erro na montagem do XML".
-- Rotina: pkb_exclui_evt_com_erro_envio, pkb_geracao_eventos, pkb_abrir_periodo_reinf, pkb_fechar_periodo_reinf.
--
-- Em 28/06/2018 - Marcelo Ono.
-- Redmine #44340 - Alterado processo de reenvio de eventos, para não gerar um novo ID de controle do Reinf.
-- Rotina: pkb_reenviar_evt_r1000, pkb_reenviar_evt_r1070, pkb_reenviar_evt_r2010, pkb_reenviar_evt_r2020, pkb_reenviar_evt_r2030, pkb_reenviar_evt_r2040
--       , pkb_reenviar_evt_r2050, pkb_reenviar_evt_r2060, pkb_reenviar_evt_r2070, pkb_reenviar_evt_r2098, pkb_reenviar_evt_r2099, pkb_reenviar_evt_r3010
--       , pkb_reenviar_evt_r9000.
--
-- Em 29/06/2018 - Marcelo Ono.
-- Redmine #42795 - Alterado processo de fechamento de período de geração, para que ao selecionar o botão "Fechamento", a geração permaneça com a situação
-- "2-Aberto ou 3-Erro no fechamento", ou seja, a situação da geração só deverá ser atualizada para "4-Fechada" assim que o evento R-2099 estiver processado.
-- Rotina: pkb_fechar_periodo_reinf e pkb_vld_evt_espera.
--
-- Em 03/07/2018 - Marcelo Ono.
-- Redmine #44602 - Alterado processo de fechamento de período de geração, para que não gere um novo evento R-2099, caso exista algum evento R-2099 com a situação
-- "5-Erro no Envio ou 6-Reijeitado", neste caso, exibirá uma mensagem orientando o usuário a efetuar o reenvio do último evento.
-- Rotina: pkb_fechar_periodo_reinf e pkb_vld_evt_espera.
--
-- Em 12/07/2018 - Marcelo Ono.
-- Redmine #38773 - Alterado o processo de reenvio dos eventos, apenas para limpar o loteefdreinf_id e alterar a situação dos eventos para "0-Aberto".
-- Rotina: pkb_reenviar_evt_r1000, pkb_reenviar_evt_r1070, pkb_reenviar_evt_r2010, pkb_reenviar_evt_r2020, pkb_reenviar_evt_r2030, pkb_reenviar_evt_r2040
--       , pkb_reenviar_evt_r2050, pkb_reenviar_evt_r2060, pkb_reenviar_evt_r2070, pkb_reenviar_evt_r2098, pkb_reenviar_evt_r2099, pkb_reenviar_evt_r3010
--       , pkb_reenviar_evt_r9000.
--
-- Em 17/07/2018 - Marcelo Ono.
-- Redmine #45065 - Alteração no processo de geração dos eventos R-2010/R-2020
-- 1- Implementado processo na geração dos eventos R-2010/R-2020, para recuperar apenas as notas fiscais de serviço/mercantil relacionadas as pessoas jurídicas;
-- 2- Implementado processo na validação de informações não enviadas ao Reinf para os eventos R-2010/R-2020, validando apenas as notas fiscais de serviço/mercantil
-- relacionadas as pessoas jurídicas.
-- Rotina: pkb_monta_array_r2010, pkb_monta_array_r2020 e pkb_vld_inf_nao_enviada.
--
-- Em 18/07/2018 - Marcelo Ono.
-- Redmine #45005 - Alteração no processo de retificação de eventos, permitindo que seja efetuado a retificação dos eventos R-2010, R-2020 e R-2040
-- com a situação "4-Processado ou 8-Processado R-5001".
-- Rotina: pkb_retif_evt_r2010, pkb_retif_evt_r2020, pkb_retif_evt_r2040.
--
-- Em 20/07/2018 - Marcelo Ono.
-- Redmine #45007 - Alteração no proceso de geração dos eventos R-2010, R-2020, R-2030, R-2040 e R-2070, para que seja recuperado as informações do
-- último evento gerado, caso a situação do evento for diferente de "7-Excluído".
-- Rotina: pkb_exist_evt_r2010, pkb_exist_evt_r2020, pkb_exist_evt_r2030, pkb_exist_evt_r2040, pkb_exist_evt_r2070.
--
-- Em 07/08/2018 - Marcos Ferreira.
-- Redmine #45658 - R2010 retificado nao encontrando lote
-- Defeito: Ao retificar um registro já retificado, a informação é gerada incorretamente na tabela CTRL_EVT_REINF 
-- Solução: Não se pode retificar um registro já retificado. A Retificação só pode ser feita em cima de um registro
--          Original. Fiz a separação dos momentos de validação dos domínios dm_tipo_reg e dm_st_proc e também a melhoria da mensagem de erro
-- Procedure Alterada: pkb_retif_evt_r2010
-- Correção no controle Transacional das Procedures
--
-- Em 23/10/2018 - Marcos Ferreira
-- Redmine #48019 - R-2010/R-2020 - Retenção de INSS sobre CT-e modelo 67
-- Solicitação: Implementar nas rotinas do Reinf a associação com os Conhecimentos de Transporte
-- Procedure: pkb_vld_inf_nao_enviada
-- Alterações: Implementação das Rotinas para CTe - Modelo 67
-- Procedure: Diversas
--
-- Em 16/11/2018 - Marcos Ferreira
-- Redmine #48793 - Criação de Validação Alíquota eventos R-2010/R-2020
-- Solicitação: Implementar validação para aliquota do INSS-RET com o Indicador de CPRB
-- Procedure: pkb_monta_array_r2010, pkb_monta_array_r2020
--
-- Em 20/11/2018 - Marcos Ferreira
-- Redmine #48826 - Avaliar a mensagem incluída no processo.
-- Solicitação: Reestruturação na Geração de Logs e mensagens de Erro
-- Procedure: pkb_exist_evt_r2010, pkb_exist_evt_r2020, pkb_monta_array_r2010, pkb_monta_array_r2020
--            pkb_gera_evt_r2010, pkb_gera_evt_r2020, pkb_exist_evt_r2010, pkb_exist_evt_r2020
--
-- Em 22/11/2018 - Marcos Ferreira
-- Redmine #48884 - Erro montagem XML REINF R2010
-- Solicitação: Quando não há notas nem ctes, a rotina está gerando os eventos R2010 e R2020, neste caso não poderia gerar
-- Procedure: pkb_gera_evt_r2010, pkb_gera_evt_r2020
--
-- Em 26/11/2018 - Marcos Ferreira
-- Redmine #49013 - Considerar somente CTe-s convertidos para o Reinf
-- Solicitação: Considerar somente CTe-s convertidos para o Reinf
-- Alterações: Nos cursores de CTE-s, considerar somente os documentos convertidos (dm_arm_cte_terc   = 0)
-- Procedures Alteradas: pkb_vld_inf_nao_enviada, pkb_monta_array_r2010, pkb_monta_array_r2020
--
-- Em 13/12/2018 - Marcos Ferreira
-- Redmine #49661: - REINF - Registro R2010 gerando incorretamente
-- Solicitação: A Geração do R-2010 está gerando incorretamente, quando a entrada das notas é nas filiais
-- Alterações: Correção da validação do CNPJ do Estabelecimento vindo do Vetor antes de Inserir as notas
-- Procedures Alteradas: pkb_exist_evt_r2010
--
-- Em 20/12/2018 - Marcos Ferreira
-- Redmine #49788: - Geração REINF não está pegando todas as notas para gerar eventos
-- Alterações: Correção da validação do CNPJ do Estabelecimento vindo do Vetor antes de Inserir as notas,
--             Padronização dos eventos R-2020
-- Procedures Alteradas: pkb_exist_evt_r2010
--
-- Em 27/12/2018 - Marcos Ferreira
-- Redmine #49819: - 	Erro ao Gerar eventos/Abrir Período
-- Alterações: Alteração do ponto de validação do indicador de CPRB
--             Criação das procedures de validação de CPRB para R-2010 e R-2020
-- Procedures Alteradas: pkb_monta_array_r20120, pkb_monta_array_r2020,
--                       pkb_exist_evt_r2010, pkb_exist_evt_r2020, 
--                       pkb_valida_cprb_nf_r2010, pkb_valida_cprb_nf_r2020
--
-- Em 07/02/2019 - Marcos Ferreira
-- Redmine #51283: -	Erro no Processamento CTe - R2010
-- Alterações: Corrigido validação para chamada da Api de Integração do R2010 cte
-- Procedures Alteradas: pkb_exist_evt_r2010 
--
-- Em 27/02/2019 - Marcos Ferreira
-- Redmine #51692: - Adequação no arredondamento de NFS EFD para REINF
-- Alterações: Criado validação para Diferenças de arredondamento de INSS, seguindo exigência da Receita Federal
-- Procedures Criadas: pkb_valida_rnd_inss_r2010, pkb_valida_rnd_inss_r2020
-- Procedures Alteradas: pkb_exist_evt_r2010, pkb_exist_evt_r2020
--
-- Em 19/03/2019 - Marcos Ferreira
-- Redmine #52622: Erro abertura período REINF
-- Solicitação: Erro na abertura do período, não está mostrando o resumo do log
-- Alterações: Corrigido a geração do log_generico, onde não está aparecendo a mensagem de resumo na abertura do período
-- Procedures Alteradas: pkb_vld_param_efd_reinf
--
-- Em 27/03/2019 - Marcos Ferreira
-- Redmine #52210 - Duplicidade de Informações
-- Solicitação: Quando cliente utiliza NF e CTE e ocorre de ter mesmo prestador e mesmo tomador, os registros de nota fiscal e cte ficam duplicados
-- Alterações: Correção da rotina que varre o vetor e faz a chamada da pkb_exist_evt_r2010 para inclusão das notas e ctes na tabela do reinf
-- Procedures Alteradas: pkb_monta_array_r2010, pkb_exist_evt_r2010, pkb_gera_evt_r2010
--
-- Em 02/04/2019 - Marcos Ferreira
-- Redmine #53016 - Adequação no arredondamento de NFS EFD para REINF - 3
-- Solicitação: Mediante a solicitação da Consultoria, fazer uma nova tratativa na regra de validação do arredondamento do Imposto
-- Alterações: Alterado cursor que checa os valores arredondados - c_imp
-- Procedures Alteradas: pkb_valida_rnd_inss_r2010, pkb_valida_rnd_inss_r2020
--
-- Em 03/04/2019 - Marcos Ferreira
-- Redmine #52009 - Revisar processo do botão de "Retif Sem NF" (quando retifica, tem que deixar como DM_ENVIO_REINF = 1 a nota)
-- Solicitação: Quando retificar sem o Documento, deixar o dm_envio_reinf = 1 para não trazer novamente o documento quando gerar eventos
-- Alterações: Alteração do Update do dm_envio_reinf para notas fiscais e conhecimento de transporte
-- Procedures Alteradas: pkb_retif_evt_r2010, pkb_retif_evt_r2020
--
-- Em 09/04/2019 - Marcos Ferreira
-- Redmine #53317 - Alterar a rotina de validação de arredondamento
-- Solicitação: Quando for encontrado erro de validação do arredondamento, não gerar erro de validação e sim informação no log
-- Alterações: Alterado o en_tipo_log para Informacao e removido a chamada para pkb_gt_log_generico_reinf que somam os erros
-- Procedures Alteradas: pkb_valida_rnd_inss_r2010, pkb_valida_rnd_inss_r2020
--
-- Em 10/04/2019 - Marcos Ferreira
-- Redmine #53335 - Lentidão no processo de envio do Reinf
-- Solicitação: Fazer melhorias no processo para agilisar a execução da valida_ambiente_reinf
-- Alterações: Criação de uma tabela de eventos pendêntes para processamento e fazer o cursor seguir por ela
-- Procedures Criadas: pkb_inc_reg_pendencia_valid, pkb_del_reg_pendencia_valid
-- Procedures Alteradas: pkb_gera_id_evt_reinf
--
-- Em 22/05/2019 - Marcos Ferreira
-- Redmine #54235: [Melhoria] para alteração do DM_ENVIO_REINF quando houver PROCESSADO 5001
-- Solicitação: Incluído uma validação de segurança, para marcar todas as notas como dm_envio_reinf = 1 que já estão como Processado R-5001 antes do fechamento do período
-- Procedures Alteradas: pkb_vld_inf_nao_enviada
--
-- Em 03/06/2019 - Marcos Ferreira
-- Redmine #50215 - Validação alíquota INSS geração de eventos R-2010 e R-2020
-- Alterações: Incluído checagem para validar se a Aliquota foi informada
-- Procedures Alteradas: pkb_valida_cprb_nf_r2010 e pkb_valida_cprb_nf_r2020
--
-- Em 03/06/2019 - Marcos Ferreira
-- Redmine #54908: Erro na geração de eventos.
-- Alterações: Incluído delete dos eventos de CTe R2010 e R2020 na rotina
-- Procedures Alteradas: pkb_exclui_evt_com_erro_envio
--
-------------------------------------------------------------------------------------------------------
   --
   gv_mensagem                       log_generico_reinf.mensagem%type;
   gv_resumo                         log_generico_reinf.resumo%type;
   gv_cabec_log                      log_generico_reinf.mensagem%type;
   gv_obj_referencia                 log_generico_reinf.obj_referencia%type default 'GERACAO_EFD_REINF';
   gn_referencia_id                  log_generico_reinf.referencia_id%type := null;
   --
   gn_dm_dt_escr_dfepoe              empresa.dm_dt_escr_dfepoe%type;
   i                                 pls_integer;
   x                                 pls_integer;
   --
   ERRO_DE_SISTEMA                   constant number := 2;
   INFORMACAO                        constant number := 35;
   --
   --
   gv_formato_data                   param_global_csf.valor%type := null;
   --
   -- TYPE´s --------------------------------------------------------------------------------------------------
   type tab_index_evt_r2010 is record ( indx_doc_id        number
                                      , efdreinfr2010_id   number
                                      , cnpj_part          varchar2(14) -- do Participante
                                      , empresa_id         number
                                      , dm_ind_obra        number
                                      , nro_inscr_estab    varchar2(14) -- nro_inscr ou cnpj do estabelecimento
                                      , tipo               varchar2(1)  -- N = Nota fiscal / C = CTE
                                      );
   --
   type t_tab_index_evt_r2010         is table of tab_index_evt_r2010      index by varchar2(15);
   type t_bi_tab_index_evt_r2010      is table of t_tab_index_evt_r2010    index by varchar2(14);
   type t_tri_tab_index_evt_r2010     is table of t_bi_tab_index_evt_r2010 index by varchar2(14);
   vt_tri_tab_index_evt_r2010         t_tri_tab_index_evt_r2010;
   --
   type tab_index_evt_r2010_nf        is record ( efdreinfr2010_id   number
                                                , notafiscal_id      number
                                                , cnpj               varchar2(14)
                                                , passou_ind_cprb    number -- 0: Não passou no teste / 1: Passou no teste
                                                , nro_nf             nota_fiscal.nro_nf%type
                                                , serie              nota_fiscal.serie%type
                                                , aliq_apli_inss     number
                                                , aliq_cprb          number
                                                );
   type t_tab_index_evt_r2010_nf      is table of tab_index_evt_r2010_nf   index by varchar2(38);
   type t_bi_tab_index_evt_r2010_nf   is table of t_tab_index_evt_r2010_nf index by varchar2(38);
   vt_bi_tab_index_evt_r2010_nf       t_bi_tab_index_evt_r2010_nf;
   --
   --                                        
   type tab_index_evt_r2010_cte       is record ( efdreinfr2010_id   number
                                                , conhectransp_id    number
                                                , cnpj               varchar2(14)
                                                );
   type t_tab_index_evt_r2010_cte     is table of tab_index_evt_r2010_cte index by varchar2(38);
   type t_bi_tab_index_evt_r2010_cte  is table of t_tab_index_evt_r2010_cte index by varchar2(38);
   vt_bi_tab_index_evt_r2010_cte      t_bi_tab_index_evt_r2010_cte;
   --
   --
   type tab_index_evt_r2020 is record ( indx_doc_id        number
                                      , efdreinfr2020_id   number
                                      , cnpj_part          varchar2(14) -- do Participante
                                      , empresa_id         number
                                      , dm_ind_obra        number
                                      , nro_inscr_estab    varchar2(14) -- nro_inscr ou cnpj do estabelecimento
                                      , tipo               varchar2(1)  -- N = Nota fiscal / C = CTE
                                      );
   --
   type t_tab_index_evt_r2020         is table of tab_index_evt_r2020      index by varchar2(15);
   type t_bi_tab_index_evt_r2020      is table of t_tab_index_evt_r2020    index by varchar2(14);
   type t_tri_tab_index_evt_r2020     is table of t_bi_tab_index_evt_r2020 index by varchar2(14);
   vt_tri_tab_index_evt_r2020         t_tri_tab_index_evt_r2020;
   --
   type tab_index_evt_r2020_nf is record ( efdreinfr2020_id   number
                                         , notafiscal_id      number
                                         , cnpj               varchar2(14)
                                         , passou_ind_cprb    number -- 0: Não passou no teste / 1: Passou no teste
                                         );
   type tab_index_evt_r2020_cte is record ( efdreinfr2020_id   number
                                          , conhectransp_id    number
                                          , cnpj               varchar2(14)                                          
                                         );
   --
   type t_tab_index_evt_r2020_nf     is table of tab_index_evt_r2020_nf   index by varchar2(38);
   type t_bi_tab_index_evt_r2020_nf  is table of t_tab_index_evt_r2020_nf index by varchar2(38);
   vt_bi_tab_index_evt_r2020_nf      t_bi_tab_index_evt_r2020_nf;
   --
   type t_tab_index_evt_r2020_cte    is table of tab_index_evt_r2020_cte index by varchar2(38);
   type t_bi_tab_index_evt_r2020_cte is table of t_tab_index_evt_r2020_cte index by varchar2(38);
   vt_bi_tab_index_evt_r2020_cte     t_bi_tab_index_evt_r2020_cte;
   --
   type tab_index_evt_r2030 is record ( empresa_id     number
                                      );
   --
   type t_tab_index_evt_r2030        is table of tab_index_evt_r2030 index by varchar2(38);
   vt_tab_index_evt_r2030            t_tab_index_evt_r2030;
   --
   type tab_index_evt_r2030_rec is record ( recrecebassdesp_id    number
                                          );
   --
   type t_tab_index_evt_r2030_rec    is table of tab_index_evt_r2030_rec index by varchar2(38);
   type t_bi_tab_index_evt_r2030_rec is table of t_tab_index_evt_r2030_rec index by varchar2(38);
   vt_bi_tab_index_evt_r2030_rec     t_bi_tab_index_evt_r2030_rec;
   --
   type tab_index_evt_r2040 is record ( empresa_id     number
                                      );
   --
   type t_tab_index_evt_r2040        is table of tab_index_evt_r2040 index by varchar2(38);
   vt_tab_index_evt_r2040            t_tab_index_evt_r2040;
   --
   type tab_index_evt_r2040_rep is record ( recrepassdesp_id    number
                                          );
   --
   type t_tab_index_evt_r2040_rep    is table of tab_index_evt_r2040_rep index by varchar2(38);
   type t_bi_tab_index_evt_r2040_rep is table of t_tab_index_evt_r2040_rep index by varchar2(38);
   vt_bi_tab_index_evt_r2040_rep     t_bi_tab_index_evt_r2040_rep;
   --
   type tab_index_evt_r2050 is record ( empresa_id     number
                                      );
   --
   type t_tab_index_evt_r2050        is table of tab_index_evt_r2050 index by varchar2(38);
   vt_tab_index_evt_r2050            t_tab_index_evt_r2050;
   --
   type tab_indx_evt_r2050_comer is record ( comerprodruralpjagr_id    number
                                           );
   --
   type t_tab_indx_evt_r2050_comer    is table of tab_indx_evt_r2050_comer index by varchar2(38);
   type t_bi_tab_indx_evt_r2050_comer is table of t_tab_indx_evt_r2050_comer index by varchar2(38);
   vt_bi_tab_indx_evt_r2050_comer     t_bi_tab_indx_evt_r2050_comer;
   --
   type tab_index_evt_r2060 is record ( empresa_id       number
                                      , apurcprbempr_id  number
                                      );
   --
   type t_tab_index_evt_r2060        is table of tab_index_evt_r2060 index by varchar2(38);
   vt_tab_index_evt_r2060            t_tab_index_evt_r2060;
   --
   type tab_index_evt_r2070 is record ( evt_id           number
                                      , tiporetimp_id    number
                                      , pessoa_id        number
                                      );
   --
   type t_tab_index_evt_r2070        is table of tab_index_evt_r2070 index by varchar2(38);
   type t_bi_tab_index_evt_r2070     is table of t_tab_index_evt_r2070 index by varchar2(38);
   vt_bi_tab_index_evt_r2070         t_bi_tab_index_evt_r2070;
   --
   type tab_indx_evt_r2070_pgto is record ( pgtoimpret_id    number
                                          );
   --
   type t_tab_indx_evt_r2070_pgto    is table of tab_indx_evt_r2070_pgto index by varchar2(38);
   type t_bi_tab_indx_evt_r2070_pgto is table of t_tab_indx_evt_r2070_pgto index by varchar2(38);
   vt_bi_tab_indx_evt_r2070_pgto     t_bi_tab_indx_evt_r2070_pgto;
   --
   type tab_index_evt_r3010 is record ( empresa_id     number
                                      );
   --
   type t_tab_index_evt_r3010        is table of tab_index_evt_r3010 index by varchar2(38);
   vt_tab_index_evt_r3010            t_tab_index_evt_r3010;
   --
   --
   type tab_indx_evt_r3010 is record ( efdreinfr3010_id      number
                                     , recespdesport_id      number
                                     , dt_ref                date
                                     );
   --
   type t_tab_indx_evt_r3010         is table of tab_indx_evt_r3010   index by varchar2(38);
   type t_bi_tab_indx_evt_r3010      is table of t_tab_indx_evt_r3010 index by varchar2(38);
   vt_bi_tab_index_evt_r3010         t_bi_tab_indx_evt_r3010;
   --
   --
   -- Nova estrutura de eventos e documentos fiscais
   type t_evento_r2010 is record ( idx_evento       number
                                 , empresa_id       number
                                 , dm_ind_obra      number
                                 , cnpj_tomador     varchar2(14)
                                 , cnpj_prestador   varchar2(14));

   type tt_evento_r2010 is table of t_evento_r2010 index by binary_integer;
   vt_evento_r2010 tt_evento_r2010;
   --
   type t_evento_r2010_doc is record ( idx_evento     number        -- chave relacional com a vt_eventos_r2010
                                     , documento_id   number        -- notafiscal_id ou conhectransp_id
                                     , tipo_documento varchar2(1)); -- 'N' Nota fiscal / 'C' Cte
   type tt_evento_r2010_doc is table of t_evento_r2010_doc index by binary_integer;                                  
   vt_evento_r2010_doc tt_evento_r2010_doc;   
   --
   --
   
   
   
   -- GT´s ----------------------------------------------------------------------------------------------------
   gt_row_geracao_efd_reinf          geracao_efd_reinf%rowtype;
   gt_row_param_efd_reinf_empresa    param_efd_reinf_empresa%rowtype;
   --
   gt_row_efd_reinf_r1000            efd_reinf_r1000%rowtype;
   gt_row_efd_reinf_r1070            efd_reinf_r1070%rowtype;
   --
   gt_row_efd_reinf_r2010            efd_reinf_r2010%rowtype;
   gt_row_efd_reinf_r2010_nf         efd_reinf_r2010_nf%rowtype;
   gt_row_efd_reinf_r2010_cte        efd_reinf_r2010_cte%rowtype;
   gt_row_efd_reinf_r2020            efd_reinf_r2020%rowtype;
   gt_row_efd_reinf_r2020_nf         efd_reinf_r2020_nf%rowtype;
   gt_row_efd_reinf_r2020_cte        efd_reinf_r2020_cte%rowtype;
   --
   gt_row_efd_reinf_r2030            efd_reinf_r2030%rowtype;
   gt_row_efdreinfr2030_recreceb     r_efdreinfr2030_recreceb%rowtype;
   gt_row_efd_reinf_r2040            efd_reinf_r2040%rowtype;
   gt_row_efdreinfr2040_recrep       r_efdreinfr2040_recrep%rowtype;
   --
   gt_row_efd_reinf_r2050            efd_reinf_r2050%rowtype;
   gt_row_efd_reinf_r2060            efd_reinf_r2060%rowtype;
   gt_row_efd_reinf_r2070            efd_reinf_r2070%rowtype;
   gt_row_efd_reinf_r2070_pir        efd_reinf_r2070_pir%rowtype;
   gt_row_efd_reinf_r3010_det        efd_reinf_r3010_det%rowtype;
   gt_row_efd_reinf_r3010            efd_reinf_r3010%rowtype;
   --
   gt_row_efd_reinf_r2098            efd_reinf_r2098%rowtype;
   gt_row_efd_reinf_r2099            efd_reinf_r2099%rowtype;
   gt_row_efd_reinf_r9000            efd_reinf_r9000%rowtype;
   --
-------------------------------------------------------------------------------------------------------
-- Inclui o registro na tabela EFD_REINF_EVT_PENDENTE para sinalizar a valida ambiente que tem registro pendente de validação
procedure pkb_inc_reg_pendencia_valid ( en_geracaoefdreinf_id in geracao_efd_reinf.id%type
                                      , ev_sigla_evt          in evt_efd_reinf.sigla%type);

-------------------------------------------------------------------------------------------------------
-- Exclui o registro na tabela EFD_REINF_EVT_PENDENTE para sinalizar a valida ambiente que não tem registro pendente de validação
procedure pkb_del_reg_pendencia_valid ( en_geracaoefdreinf_id in geracao_efd_reinf.id%type
                                      , ev_sigla_evt          in evt_efd_reinf.sigla%type);

-------------------------------------------------------------------------------------------------------
-- Processo que armazena o valor do "loggenerico_id"
procedure pkb_gt_log_generico_reinf ( en_loggenericoreinf_id  in             log_generico_reinf.id%TYPE
                                    , est_log_generico_reinf  in out nocopy  dbms_sql.number_table );

-------------------------------------------------------------------------------------------------------
-- Processo que recupera os dados da Abertura do EFD-REINF
procedure pkb_dados_geracao_reinf ( en_geracaoefdreinf_id in geracao_efd_reinf.id%type
                                  );

---------------------------------------------------------------------------------------------------
-- Processo de Geração do ID do evento do EFD-REINF
procedure pkb_gera_id_evt_reinf ( ev_obj_referencia in varchar2
                                , en_referencia_id  in number
                                );

---------------------------------------------------------------------------------------------------
-- Procedimento que grava a quantidade de registros gerados por evento
procedure pkb_gerar_resumo_reinf ( en_geracaoefdreinf_id in geracao_efd_reinf.id%type
                                 );
                                 
---------------------------------------------------------------------------------------------------
-- Procedimento que exclui os eventos com a situação "5-Erro no envio e 6-Erro na montagem do XML"
procedure pkb_exclui_evt_com_erro_envio ( en_geracaoefdreinf_id in geracao_efd_reinf.id%type
                                        , ev_botao              in varchar2
                                        );

---------------------------------------------------------------------------------------------------
-- Procedimento que cria um novo evento de Reenvio para os eventos Rejeitados ou com Erro no Envio
procedure pkb_reenviar_evt_r9000 ( en_efdreinfr9000_id in efd_reinf_r9000.id%type
                                 );
                              
---------------------------------------------------------------------------------------------------
-- Procedimento que gera o evento R-9000 de Exclusão
procedure pkb_gera_evt_r9000 ( ev_obj_referencia in varchar2
                             , en_referencia_id  in number
                             );

---------------------------------------------------------------------------------------------------
-- Procedimento que cria um novo evento de Reenvio para os eventos Rejeitados ou com Erro no Envio
procedure pkb_reenviar_evt_r2099 ( en_efdreinfr2099_id in efd_reinf_r2099.id%type
                                 );

----------------------------------------------------------------------------------------------------
-- Procedimento que gerencia o evento R-2099 - Fechamento dos Eventos Periódicos
procedure pkb_gera_evt_r2099 ( est_log_generico_reinf  in out nocopy dbms_sql.number_table
                             );

---------------------------------------------------------------------------------------------------
-- Procedimento que cria um novo evento de Reenvio para os eventos Rejeitados ou com Erro no Envio
procedure pkb_reenviar_evt_r2098 ( en_efdreinfr2098_id in efd_reinf_r2098.id%type
                                 );

----------------------------------------------------------------------------------------------------
-- Procedimento que gerencia o evento R-2098 - Reabertura dos Eventos Periódicos
procedure pkb_gera_evt_r2098 ( est_log_generico_reinf  in out nocopy dbms_sql.number_table
                             );

---------------------------------------------------------------------------------------------------
-- Procedimento que cria um novo evento de Reenvio para os eventos Rejeitados ou com Erro no Envio
procedure pkb_reenviar_evt_r3010 ( en_efdreinfr3010_id in efd_reinf_r3010.id%type
                                 );

---------------------------------------------------------------------------------------------------
-- Procedimento de retificação do pagamento de imposto retido do Evento R-2070
procedure pkb_retif_evt_r2070 ( en_efdreinfr2070_id in efd_reinf_r2070.id%type
                              , en_pgtoimpret_id    in pgto_imp_ret.id%type
                              );

---------------------------------------------------------------------------------------------------
-- Procedimento que cria um novo evento de Reenvio para os eventos Rejeitados ou com Erro no Envio
procedure pkb_reenviar_evt_r2070 ( en_efdreinfr2070_id in efd_reinf_r2070.id%type
                                 );

---------------------------------------------------------------------------------------------------
-- Procedimento que cria um novo evento de Reenvio para os eventos Rejeitados ou com Erro no Envio
procedure pkb_reenviar_evt_r2060 ( en_efdreinfr2060_id in efd_reinf_r2060.id%type
                                 );

---------------------------------------------------------------------------------------------------
-- Processo que verifica se existe evento dentro do periodo para a Empresa
procedure pkb_reenviar_evt_r2050 ( en_efdreinfr2050_id in efd_reinf_r2050.id%type
                                 );

---------------------------------------------------------------------------------------------------
-- Procedimento de retificação do recurso repassado para associação desportiva do Evento R-2040
procedure pkb_retif_evt_r2040 ( en_efdreinfr2040_id   in efd_reinf_r2040.id%type
                              , en_recrepassdesp_id   in rec_rep_ass_desp.id%type default 0
                              );

---------------------------------------------------------------------------------------------------
-- Processo que verifica se existe evento dentro do periodo para a Empresa
procedure pkb_reenviar_evt_r2040 ( en_efdreinfr2040_id in efd_reinf_r2040.id%type
                                 );

---------------------------------------------------------------------------------------------------
-- Procedimento de retificação do recurso recebido por associação desportiva do Evento R-2030
procedure pkb_retif_evt_r2030 ( en_efdreinfr2030_id     in efd_reinf_r2030.id%type
                              , en_recrecebassdesp_id   in rec_receb_ass_desp.id%type
                              );

---------------------------------------------------------------------------------------------------
-- Procedimento que cria um novo evento de Reenvio para os eventos Rejeitados ou com Erro no Envio
procedure pkb_reenviar_evt_r2030 ( en_efdreinfr2030_id in efd_reinf_r2030.id%type
                                 );

---------------------------------------------------------------------------------------------------
-- Procedimento de retificação da nota fiscal de saída do Evento R-2020
procedure pkb_retif_evt_r2020 ( en_efdreinfr2020_id in efd_reinf_r2020.id%type
                              , ev_tipo_doc         in varchar2 -- NF / CTE
                              , en_documento_id     in number
                              );

---------------------------------------------------------------------------------------------------
-- Procedimento que cria um novo evento de Reenvio para os eventos Rejeitados ou com Erro no Envio
procedure pkb_reenviar_evt_r2020 ( en_efdreinfr2020_id in efd_reinf_r2020.id%type
                                 );

---------------------------------------------------------------------------------------------------
-- Procedimento de retificação da nota fiscal de entrada do Evento R-2010
procedure pkb_retif_evt_r2010 ( en_efdreinfr2010_id in efd_reinf_r2010.id%type
                              , ev_tipo_doc         in varchar2 -- NF / CTE
                              , en_documento_id     in number
                              );

---------------------------------------------------------------------------------------------------
-- Procedimento que cria um novo evento de Reenvio para os eventos Rejeitados ou com Erro no Envio
procedure pkb_reenviar_evt_r2010 ( en_efdreinfr2010_id in efd_reinf_r2010.id%type
                                 );

-------------------------------------------------------------------------------------------------------
-- Processo que recupera os dados do último evento R-1070 gerado
procedure pkb_rec_ultimo_evento_r1070 ( en_procadmefdreinf_id  in proc_adm_efd_reinf.id%type
                                      , en_dm_tp_amb           in geracao_efd_reinf.dm_tp_amb%type
                                      , est_efdreinf_ult_r1070 out nocopy efd_reinf_r1070%rowtype
                                      );

---------------------------------------------------------------------------------------------------
-- Procedimento que cria um novo evento de Reenvio para os eventos Rejeitados ou com Erro no Envio
procedure pkb_reenviar_evt_r1070 ( en_efdreinfr1070_id in efd_reinf_r1070.id%type
                                 );

-------------------------------------------------------------------------------------------------------
-- Processo que recupera os dados do último evento R-1000 gerado
procedure pkb_rec_ultimo_evento_r1000 ( en_empresa_id          in geracao_efd_reinf.empresa_id%type
                                      , en_dm_tp_amb           in geracao_efd_reinf.dm_tp_amb%type
                                      , est_efdreinf_ult_r1000 out nocopy efd_reinf_r1000%rowtype
                                      );

---------------------------------------------------------------------------------------------------
-- Procedimento que cria um novo evento de Reenvio para os eventos Rejeitados ou com Erro no Envio
procedure pkb_reenviar_evt_r1000 ( en_efdreinfr1000_id in efd_reinf_r1000.id%type
                                 );
-------------------------------------------------------------------------------------------------------
-- Processo que executa a Geração dos eventos Offline do Periodo
procedure pkb_geracao_periodo_online;

-------------------------------------------------------------------------------------------------------
-- Processo que executa a Geração dos eventos Offline do Periodo
procedure pkb_geracao_periodo_offline ( en_geracaoefdreinf_id in geracao_efd_reinf.id%type
                                      );

-------------------------------------------------------------------------------------------------------
-- Processo de abertura de periodo de geração do EFD-REINF
procedure pkb_abrir_periodo_reinf ( en_geracaoefdreinf_id in geracao_efd_reinf.id%type
                                  );

-------------------------------------------------------------------------------------------------------
-- Processo de fechamento de periodo de geração do EFD-REINF
procedure pkb_fechar_periodo_reinf ( en_geracaoefdreinf_id in geracao_efd_reinf.id%type
                                   );

-------------------------------------------------------------------------------------------------------

-- Validação do CPRB das notas fiscais informadas nos Eventos R2010
procedure pkb_valida_cprb_nf_r2010 ( en_geracaoefdreinf_id   in geracao_efd_reinf.id%type
                                   , en_efdreinfr2010_id     in efd_reinf_r2010.id%type
                                   , est_log_generico_reinf  in out nocopy dbms_sql.number_table
                                   );

-------------------------------------------------------------------------------------------------------

-- Validação do CPRB das notas fiscais informadas nos Eventos R2020
procedure pkb_valida_cprb_nf_r2020 ( en_geracaoefdreinf_id   in geracao_efd_reinf.id%type
                                   , en_efdreinfr2020_id     in efd_reinf_r2020.id%type
                                   , est_log_generico_reinf  in out nocopy dbms_sql.number_table
                                   );

-------------------------------------------------------------------------------------------------------

-- Valida arredondamento imposto INSS para REINF - R2010
procedure pkb_valida_rnd_inss_r2010 ( en_geracaoefdreinf_id   in geracao_efd_reinf.id%type
                                    , en_efdreinfr2010_id     in efd_reinf_r2010.id%type
                                    , est_log_generico_reinf  in out nocopy dbms_sql.number_table
                                    ); 

-------------------------------------------------------------------------------------------------------

-- Valida arredondamento imposto INSS para REINF - R2020
procedure pkb_valida_rnd_inss_r2020 ( en_geracaoefdreinf_id   in geracao_efd_reinf.id%type
                                    , en_efdreinfr2020_id     in efd_reinf_r2020.id%type
                                    , est_log_generico_reinf  in out nocopy dbms_sql.number_table
                                    ); 

-------------------------------------------------------------------------------------------------------

-- Procedimento de retificação da nota fiscal de entrada do Evento R-2060
procedure pkb_retif_evt_r2060 ( en_efdreinfr2060_id in efd_reinf_r2060.id%type
                              );

-------------------------------------------------------------------------------------------------------
end pk_gera_dados_reinf;
/
