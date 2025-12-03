-- =====================================================
-- AUDIT TRAIL SETUP
-- Track all database activities
-- =====================================================
-- Demo: Log tất cả thao tác trên GRADES table
--       Track login/logout
--       Monitor unauthorized access attempts
-- =====================================================

CONNECT sys/123@localhost:1521/ORCLPDB AS SYSDBA;

-- =====================================================
-- STEP 1: ENABLE AUDIT TRAIL
-- =====================================================
-- Check current audit settings
SHOW PARAMETER audit_trail;

-- Enable audit trail (DB level)
-- ALTER SYSTEM SET audit_trail=DB,EXTENDED SCOPE=SPFILE;
-- Note: Requires database restart. For demo, we'll use triggers instead.

-- =====================================================
-- STEP 2: CREATE AUDIT LOG TABLE
-- =====================================================
CREATE TABLE GMS_ADMIN.AUDIT_LOG (
    audit_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    audit_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP,
    username VARCHAR2(50),
    user_type VARCHAR2(20),
    action_type VARCHAR2(20), -- SELECT, INSERT, UPDATE, DELETE
    table_name VARCHAR2(50),
    record_id VARCHAR2(50),
    old_value CLOB,
    new_value CLOB,
    sql_text VARCHAR2(4000),
    session_id NUMBER,
    ip_address VARCHAR2(50),
    success VARCHAR2(1) DEFAULT 'Y', -- Y/N
    error_message VARCHAR2(500)
);

-- Create index for faster queries
CREATE INDEX idx_audit_timestamp ON GMS_ADMIN.AUDIT_LOG(audit_timestamp);
CREATE INDEX idx_audit_username ON GMS_ADMIN.AUDIT_LOG(username);
CREATE INDEX idx_audit_table ON GMS_ADMIN.AUDIT_LOG(table_name);

COMMENT ON TABLE GMS_ADMIN.AUDIT_LOG IS 'Audit trail for all database activities';

PROMPT Audit log table created

-- =====================================================
-- STEP 3: CREATE AUDIT TRIGGER FOR GRADES
-- =====================================================
CREATE OR REPLACE TRIGGER GMS_ADMIN.trg_audit_grades
AFTER INSERT OR UPDATE OR DELETE ON GMS_ADMIN.GRADES
FOR EACH ROW
DECLARE
    v_action VARCHAR2(20);
    v_old_value CLOB;
    v_new_value CLOB;
    v_username VARCHAR2(50);
    v_user_type VARCHAR2(20);
BEGIN
    -- Determine action type
    IF INSERTING THEN
        v_action := 'INSERT';
    ELSIF UPDATING THEN
        v_action := 'UPDATE';
    ELSIF DELETING THEN
        v_action := 'DELETE';
    END IF;

    -- Get context info
    v_username := SYS_CONTEXT('gms_context', 'user_id');
    v_user_type := SYS_CONTEXT('gms_context', 'user_type');

    -- If no context, use Oracle user
    IF v_username IS NULL THEN
        v_username := USER;
        v_user_type := 'SYSTEM';
    END IF;

    -- Build old/new values
    IF DELETING OR UPDATING THEN
        v_old_value := 'student_id=' || :OLD.student_id ||
                      ', course_id=' || :OLD.course_id ||
                      ', score=' || :OLD.score ||
                      ', grade=' || :OLD.grade;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_new_value := 'student_id=' || :NEW.student_id ||
                      ', course_id=' || :NEW.course_id ||
                      ', score=' || :NEW.score ||
                      ', grade=' || :NEW.grade;
    END IF;

    -- Insert audit record
    INSERT INTO GMS_ADMIN.AUDIT_LOG (
        username,
        user_type,
        action_type,
        table_name,
        record_id,
        old_value,
        new_value,
        session_id,
        ip_address
    ) VALUES (
        v_username,
        v_user_type,
        v_action,
        'GRADES',
        :NEW.grade_id,
        v_old_value,
        v_new_value,
        SYS_CONTEXT('USERENV', 'SESSIONID'),
        SYS_CONTEXT('USERENV', 'IP_ADDRESS')
    );

EXCEPTION
    WHEN OTHERS THEN
        -- Don't fail the main transaction if audit fails
        NULL;
END;
/

PROMPT Audit trigger for GRADES created

-- =====================================================
-- STEP 4: CREATE AUDIT TRIGGER FOR STUDENTS
-- =====================================================
CREATE OR REPLACE TRIGGER GMS_ADMIN.trg_audit_students
AFTER INSERT OR UPDATE OR DELETE ON GMS_ADMIN.STUDENTS
FOR EACH ROW
DECLARE
    v_action VARCHAR2(20);
    v_old_value CLOB;
    v_new_value CLOB;
    v_username VARCHAR2(50);
BEGIN
    IF INSERTING THEN
        v_action := 'INSERT';
    ELSIF UPDATING THEN
        v_action := 'UPDATE';
    ELSIF DELETING THEN
        v_action := 'DELETE';
    END IF;

    v_username := NVL(SYS_CONTEXT('gms_context', 'user_id'), USER);

    IF DELETING OR UPDATING THEN
        v_old_value := 'name=' || :OLD.first_name || ' ' || :OLD.last_name;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_new_value := 'name=' || :NEW.first_name || ' ' || :NEW.last_name;
    END IF;

    INSERT INTO GMS_ADMIN.AUDIT_LOG (
        username, action_type, table_name, record_id,
        old_value, new_value, session_id
    ) VALUES (
        v_username, v_action, 'STUDENTS', :NEW.student_id,
        v_old_value, v_new_value, SYS_CONTEXT('USERENV', 'SESSIONID')
    );
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

PROMPT Audit trigger for STUDENTS created

-- =====================================================
-- STEP 5: ENABLE FINE-GRAINED AUDIT (FGA)
-- =====================================================
-- FGA: Track SELECT statements (VPD violations)
BEGIN
    -- Drop if exists
    BEGIN
        DBMS_FGA.DROP_POLICY(
            object_schema => 'GMS_ADMIN',
            object_name => 'GRADES',
            policy_name => 'fga_grades_select'
        );
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    -- Create FGA policy for unauthorized SELECT attempts
    DBMS_FGA.ADD_POLICY(
        object_schema => 'GMS_ADMIN',
        object_name => 'GRADES',
        policy_name => 'fga_grades_select',
        audit_condition => 'SYS_CONTEXT(''gms_context'', ''user_type'') IS NULL',
        audit_column => 'score,grade',
        handler_schema => NULL,
        handler_module => NULL,
        enable => TRUE,
        statement_types => 'SELECT',
        audit_trail => DBMS_FGA.DB + DBMS_FGA.EXTENDED,
        audit_column_opts => DBMS_FGA.ANY_COLUMNS
    );

    DBMS_OUTPUT.PUT_LINE('FGA policy created for GRADES table');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('FGA Error: ' || SQLERRM);
END;
/

-- =====================================================
-- STEP 6: CREATE AUDIT VIEWS FOR REPORTING
-- =====================================================

-- Recent audit activities
CREATE OR REPLACE VIEW GMS_ADMIN.v_recent_audit AS
SELECT
    audit_id,
    audit_timestamp,
    username,
    user_type,
    action_type,
    table_name,
    record_id,
    success
FROM GMS_ADMIN.AUDIT_LOG
WHERE audit_timestamp >= SYSTIMESTAMP - INTERVAL '7' DAY
ORDER BY audit_timestamp DESC;

-- Audit summary by user
CREATE OR REPLACE VIEW GMS_ADMIN.v_audit_by_user AS
SELECT
    username,
    user_type,
    table_name,
    action_type,
    COUNT(*) as action_count,
    MAX(audit_timestamp) as last_action
FROM GMS_ADMIN.AUDIT_LOG
GROUP BY username, user_type, table_name, action_type
ORDER BY last_action DESC;

-- Failed access attempts
CREATE OR REPLACE VIEW GMS_ADMIN.v_failed_access AS
SELECT
    audit_timestamp,
    username,
    table_name,
    action_type,
    error_message
FROM GMS_ADMIN.AUDIT_LOG
WHERE success = 'N'
ORDER BY audit_timestamp DESC;

PROMPT Audit views created

-- =====================================================
-- STEP 7: GRANT PERMISSIONS
-- =====================================================
GRANT SELECT ON GMS_ADMIN.AUDIT_LOG TO GMS_APP;
GRANT SELECT ON GMS_ADMIN.v_recent_audit TO GMS_APP;

PROMPT Permissions granted

-- =====================================================
-- STEP 8: ENABLE STANDARD AUDITING
-- =====================================================
-- Audit login/logout
AUDIT SESSION BY ACCESS;

-- Audit failed login attempts
AUDIT SESSION WHENEVER NOT SUCCESSFUL;

-- Audit specific operations
AUDIT SELECT TABLE, UPDATE TABLE, INSERT TABLE, DELETE TABLE
BY GMS_APP BY ACCESS;

PROMPT Standard auditing enabled

-- =====================================================
-- VERIFY AUDIT SETUP
-- =====================================================
PROMPT =====================================================
PROMPT Checking Audit Configuration...
PROMPT =====================================================

-- Check audit log table
SELECT COUNT(*) as "Audit Records" FROM GMS_ADMIN.AUDIT_LOG;

-- Check triggers
SELECT trigger_name, table_name, status
FROM dba_triggers
WHERE owner = 'GMS_ADMIN'
AND trigger_name LIKE 'TRG_AUDIT%';

-- Check FGA policies
SELECT object_schema, object_name, policy_name, enabled
FROM dba_audit_policies
WHERE object_schema = 'GMS_ADMIN';

-- Check standard audit options
SELECT user_name, audit_option, success, failure
FROM dba_stmt_audit_opts
WHERE user_name = 'GMS_APP' OR user_name IS NULL;

PROMPT =====================================================
PROMPT Audit Setup Complete!
PROMPT =====================================================
PROMPT Components created:
PROMPT   - AUDIT_LOG table (custom audit trail)
PROMPT   - Triggers on GRADES, STUDENTS tables
PROMPT   - FGA policy for unauthorized SELECT
PROMPT   - Audit views for reporting
PROMPT   - Standard audit for sessions
PROMPT =====================================================

-- =====================================================
-- STEP 9: INSERT TEST AUDIT RECORD
-- =====================================================
INSERT INTO GMS_ADMIN.AUDIT_LOG (
    username, user_type, action_type, table_name,
    record_id, new_value, session_id, success
) VALUES (
    'SYSTEM', 'Admin', 'SETUP', 'AUDIT_LOG',
    '0', 'Audit system initialized', 0, 'Y'
);

COMMIT;

PROMPT Test audit record inserted

EXIT;
