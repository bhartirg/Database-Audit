

/*To keep track on changes of whole database using DDL trigger*/


--STEP 1: Create Audit Table

--This table will store all changes.

--Step 1: Audit Table (Your table is fine)
CREATE TABLE ddl_audit_log (
    username      VARCHAR2(50),
    event_type    VARCHAR2(50),
    object_name   VARCHAR2(100),
    object_type   VARCHAR2(50),
    event_date    DATE,
    sql_text      CLOB
);
-- Step 2: Create DDL Trigger on database
CREATE OR REPLACE TRIGGER trg_ddl_audit
AFTER DDL ON DATABASE
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;

    v_sql_text ORA_NAME_LIST_T;
    v_stmt     CLOB := '';
    n          NUMBER;
BEGIN
    -- Get SQL text
    n := ORA_SQL_TXT(v_sql_text);

    -- Combine SQL parts
    FOR i IN 1..n LOOP
        v_stmt := v_stmt || v_sql_text(i);
    END LOOP;

    -- Insert audit record
    INSERT INTO ddl_audit_log (
        username,
        event_type,
        object_name,
        object_type,
        event_date,
        sql_text
    )
    VALUES (
        SYS_CONTEXT('USERENV','SESSION_USER'),
        ORA_SYSEVENT,
        ORA_DICT_OBJ_NAME,
        ORA_DICT_OBJ_TYPE,
        SYSDATE,
        v_stmt
    );

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        NULL; -- prevent DDL failure
END;
/

CREATE TABLE test_ddl (id NUMBER);
DROP TABLE test_ddl;
SELECT * FROM ddl_audit_log;