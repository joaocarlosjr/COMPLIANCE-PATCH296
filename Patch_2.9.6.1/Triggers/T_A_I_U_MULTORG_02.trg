CREATE OR REPLACE TRIGGER T_A_I_U_MULTORG_02
AFTER INSERT OR UPDATE ON MULT_ORG
 FOR EACH ROW
--
-- Em 19/01/2021 - Luiz Armando 296-1 / 2.9.7
-- Redmine  - criação do trigger para popular as tabelas multorg_jobs e multorg_jobs_freq
--            sempre que for inserido um multorg ou atualizado.
-- 
--
DECLARE
VN_MULTORGJOBS_ID MULTORG_JOBS.ID%TYPE;
VV_DESCR1 VARCHAR2(4000) := 'DIA';--'frequencia diurna de segunda a sexta feira das 6 as 23:59 a cada 15 minutos';
VV_FREQ1 VARCHAR2(4000) := 'Freq=Minutely;ByDay=Mon, Tue, Wed, Thu, Fri;ByHour=00, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23;ByMinute= 00,15,30,45';

VV_DESCR2 VARCHAR2(4000) := 'NOITE';--'frequencia noturna de segunda a sexta feira das 01 as 05:59 a cada 30 minutos';
VV_FREQ2 VARCHAR2(4000) := 'Freq=Minutely;ByDay=Mon, Tue, Wed, Thu, Fri;ByHour=01, 02, 03, 04, 05;ByMinute=00,15,30,45';

VV_DESCR3 VARCHAR2(4000) := 'FDS';--'frequencia sábado e domingo das 00 as 23:59 a cada 30 minutos';
VV_FREQ3 VARCHAR2(4000) := 'Freq=Minutely;ByDay=Sat, Sun;ByHour=00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23;ByMinute=00,30';

--
BEGIN

  IF INSERTING THEN    
      FOR X IN (SELECT *
                  FROM CSF_JOBS
                )
      LOOP
        BEGIN
        INSERT INTO MULTORG_JOBS(MULTORG_ID
                               , JOB_NAME
                               , ID
                               , DM_ATIVO)
                          VALUES(:NEW.ID
                                ,X.JOB_NAME
                                ,MULTORGJOBS_SEQ.NEXTVAL
                                ,0--INATIVO
                                ) RETURNING ID INTO VN_MULTORGJOBS_ID;
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            BEGIN
              SELECT M.ID
                INTO VN_MULTORGJOBS_ID
                FROM MULTORG_JOBS M
               WHERE JOB_NAME = X.JOB_NAME
                 AND ID       = :NEW.ID;
            EXCEPTION
              WHEN OTHERS THEN
                VN_MULTORGJOBS_ID := NULL;
            END;
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001,'FALHA NA NO TRIGGER DA TABELA MULT_ORG. ERRO:'||SQLERRM);
        END;

        IF VN_MULTORGJOBS_ID IS NOT NULL THEN
          BEGIN
            INSERT INTO MULTORG_JOBS_FREQ (ID,
                                           MULTORGJOBS_ID,
                                           FREQUENCIA,
                                           DESCR)
                  VALUES (MULTORGJOBS_SEQ.NEXTVAL
                         ,VN_MULTORGJOBS_ID
                         ,VV_FREQ1
                         ,VV_DESCR1
                         );
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              NULL;
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-21002,'FALHA NA NO TRIGGER DA TABELA MULT_ORG. ERRO:'||SQLERRM);
          END;
          --
          BEGIN
            INSERT INTO MULTORG_JOBS_FREQ (ID,
                                           MULTORGJOBS_ID,
                                           FREQUENCIA,
                                           DESCR)
                  VALUES (MULTORGJOBS_SEQ.NEXTVAL
                         ,VN_MULTORGJOBS_ID
                         ,VV_FREQ2
                         ,VV_DESCR2
                         );
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              NULL;
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-21002,'FALHA NA NO TRIGGER DA TABELA MULT_ORG. ERRO:'||SQLERRM);
          END;
          --
          BEGIN
            INSERT INTO MULTORG_JOBS_FREQ (ID,
                                           MULTORGJOBS_ID,
                                           FREQUENCIA,
                                           DESCR)
                  VALUES (MULTORGJOBS_SEQ.NEXTVAL
                         ,VN_MULTORGJOBS_ID
                         ,VV_FREQ3
                         ,VV_DESCR3
                         );
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              NULL;
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-21004,'FALHA NA NO TRIGGER DA TABELA MULT_ORG. ERRO:'||SQLERRM);
          END;
          --
        END IF;
      END LOOP;
  --SE FOR DE UPDATE VERIFICAR SE A MULT_ORG.DM_SITUACAO=0 'INATIVO', SE O MULT_ORG FOI INATIVADO, ALTERAR O MULTORG_JOBS.DM_ATIVO=0 E DESLIGAR OS JOBS DESTE MULTORG UTILIZANDO A PB_GESTAO_JOB_SCHEDULER(EV_INSERT_DEL => 'D',EN_MULTORG_ID => :NEW.ID);
  ELSIF UPDATING THEN
      IF :NEW.DM_SITUACAO = 0 THEN
         -- EXECUTA A PB_GESTAO_JOB_SCHEDULER PARA APAGAR OS JOB SCHEDULER ATIVOS
         BEGIN
           PB_GESTAO_JOB_SCHEDULER(EV_INSERT_DEL => 'D',EN_MULTORG_ID => :NEW.ID);
         EXCEPTION
           WHEN OTHERS THEN
             RAISE_APPLICATION_ERROR(-21005,'FALHA NA NO TRIGGER DA TABELA MULT_ORG. ERRO:'||SQLERRM);
         END;
         --
         -- INATIVA OS MULTORG_JOBS PARA NÃO SEREM MAIS CRIADOS
         UPDATE MULTORG_JOBS  SET DM_ATIVO = 0 WHERE MULTORG_ID = :NEW.ID;
         --
      END IF;
  END IF;
END;
/
/
