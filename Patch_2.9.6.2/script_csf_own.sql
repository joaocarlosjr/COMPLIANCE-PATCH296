------------------------------------------------------------------------------------------
Prompt INI Patch 2.9.6.2 - Alteracoes no CSF_OWN
------------------------------------------------------------------------------------------

insert into csf_own.versao_sistema ( ID
                                   , VERSAO
                                   , DT_VERSAO
                                   )
                            values ( csf_own.versaosistema_seq.nextval -- ID
                                   , '2.9.6.2'                         -- VERSAO
                                   , sysdate                           -- DT_VERSAO
                                   )
/

commit
/

-------------------------------------------------------------------------------------------------------------------------------
Prompt INI - Redmine #75477 -  Criação de Job Scheduler JOB_CORRIGIR_NF_CT
-------------------------------------------------------------------------------------------------------------------------------

DECLARE 
  vn_cont NUMBER;
BEGIN
  --
  -- Verifica se o Job JOB_CORRIGIR_NF_CT já foi criado, caso existir sai da rotina
  BEGIN
    SELECT COUNT(1)
      INTO vn_cont
      FROM ALL_SCHEDULER_JOBS
     WHERE JOB_NAME = 'JOB_CORRIGIR_NF_CT'
       AND ENABLED  = 'TRUE';
    EXCEPTION
      WHEN OTHERS THEN
        vn_cont := 0;
    END;
    --
    IF vn_cont = 0 THEN
        DBMS_SCHEDULER.CREATE_JOB
            (
              JOB_NAME => 'JOB_CORRIGIR_NF_CT',
              JOB_TYPE => 'STORED_PROCEDURE',
              JOB_ACTION => 'CSF_OWN.PB_CORRIGIR_PESSOA_NF_CT',
              START_DATE => SYSDATE,
              REPEAT_INTERVAL => 'SYSDATE + (((1/24)/60))',
              ENABLED => TRUE,
              COMMENTS => 'POPULA PESSOA_ID NA NF/CT QUANDO ESTIVER NULO.'
            );
     END IF;
EXCEPTION
	WHEN OTHERS THEN
		RAISE_APPLICATION_ERROR(-20101, 'Erro ao criar o Job - JOB_CORRIGIR_NF_CT  : '||sqlerrm);
END;
/
-------------------------------------------------------------------------------------------------------------------------------
Prompt FIM - Redmine #75477 -  Criação de Job Scheduler JOB_CORRIGIR_NF_CT
-------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
Prompt FIM Patch 2.9.6.2 - Alteracoes no CSF_OWN
------------------------------------------------------------------------------------------
