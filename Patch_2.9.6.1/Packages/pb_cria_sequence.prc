create or replace procedure CSF_OWN.PB_CRIA_SEQUENCE (ev_sequence_name varchar2,
                                                      ev_table_name    varchar2)
AUTHID CURRENT_USER
AS
begin
   -- Cria a sequence
   BEGIN
      EXECUTE IMMEDIATE '
         CREATE SEQUENCE CSF_OWN.'||ev_sequence_name||'
         INCREMENT BY 1
         START WITH   1
         NOMINVALUE
         NOMAXVALUE
         NOCYCLE
         NOCACHE
      ';
   EXCEPTION
     WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
           NULL;
        ELSE
          RAISE;
        END IF;
   END;
   -- Inclui na seq_tab
   BEGIN
      INSERT INTO CSF_OWN.SEQ_TAB ( id
                                  , sequence_name
                                  , table_name
                                  )
                           values ( CSF_OWN.seqtab_seq.nextval
                                  , ev_sequence_name
                                  , ev_table_name
                                  );
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   commit;
   --
exception
  when others then
     rollback;
     raise;
end pb_cria_sequence;
/
