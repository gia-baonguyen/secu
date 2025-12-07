-- =============================================
-- UNIVERSITY GRADE MANAGEMENT SYSTEM
-- Audit Policy Configuration (FIXED VERSION)
-- Fine-Grained Auditing for security compliance
-- =============================================

ALTER SESSION SET CONTAINER = ORCLPDB;

-- =============================================
-- FIX: Cấp quyền trực tiếp để tạo được View
-- =============================================
PROMPT Granting direct access to audit trails...
GRANT SELECT ON SYS.DBA_FGA_AUDIT_TRAIL TO GMS_ADMIN;

ALTER SESSION SET CURRENT_SCHEMA = GMS_ADMIN;

-- =============================================
-- Drop existing FGA policies if they exist
-- =============================================
BEGIN
    FOR policy IN (SELECT object_schema, object_name, policy_name
                   FROM dba_audit_policies
                   WHERE object_schema = 'GMS_ADMIN') LOOP
        BEGIN
            DBMS_FGA.DROP_POLICY(
                object_schema => policy.object_schema,
                object_name => policy.object_name,
                policy_name => policy.policy_name
            );
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END;
/

-- =============================================
-- 1. AUDIT HANDLER PROCEDURES
-- =============================================

-- Handler for grade modifications
CREATE OR REPLACE PROCEDURE audit_grade_handler(
    object_schema VARCHAR2,
    object_name VARCHAR2,
    policy_name VARCHAR2
) AS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_user VARCHAR2(50);
    v_user_type VARCHAR2(50);
    v_user_id VARCHAR2(10);
BEGIN
    v_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
    v_user_type := SYS_CONTEXT('gms_context', 'user_type');
    v_user_id := SYS_CONTEXT('gms_context', 'user_id');

    -- Log to custom audit table
    INSERT INTO gms_admin.AUDIT_LOG (
        table_name,
        operation,
        user_id,
        username,
        operation_date,
        ip_address,
        session_id
    ) VALUES (
        object_name,
        'GRADE_MODIFY',
        v_user_id,
        v_user,
        SYSDATE,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYS_CONTEXT('USERENV', 'SESSIONID')
    );

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END;
/

-- =============================================
-- 2. FINE-GRAINED AUDIT (FGA) POLICIES
-- =============================================

-- FGA for all grade modifications (SELECT)
BEGIN
    DBMS_FGA.ADD_POLICY(
        object_schema => 'GMS_ADMIN',
        object_name => 'GRADES',
        policy_name => 'fga_grade_select',
        audit_condition => NULL,
        audit_column => 'MIDTERM_SCORE,FINAL_SCORE,TOTAL_SCORE',
        statement_types => 'SELECT',
        enable => TRUE
    );
    DBMS_OUTPUT.PUT_LINE('FGA policy fga_grade_select created');
END;
/

-- FGA for grade updates
BEGIN
    DBMS_FGA.ADD_POLICY(
        object_schema => 'GMS_ADMIN',
        object_name => 'GRADES',
        policy_name => 'fga_grade_update',
        audit_condition => NULL,
        audit_column => 'MIDTERM_SCORE,FINAL_SCORE,TOTAL_SCORE,LETTER_GRADE',
        statement_types => 'UPDATE',
        enable => TRUE,
        handler_schema => 'GMS_ADMIN',
        handler_module => 'audit_grade_handler'
    );
    DBMS_OUTPUT.PUT_LINE('FGA policy fga_grade_update created');
END;
/

-- FGA for grade deletes
BEGIN
    DBMS_FGA.ADD_POLICY(
        object_schema => 'GMS_ADMIN',
        object_name => 'GRADES',
        policy_name => 'fga_grade_delete',
        audit_condition => NULL,
        statement_types => 'DELETE',
        enable => TRUE,
        handler_schema => 'GMS_ADMIN',
        handler_module => 'audit_grade_handler'
    );
    DBMS_OUTPUT.PUT_LINE('FGA policy fga_grade_delete created');
END;
/

-- FGA for student personal information access
BEGIN
    DBMS_FGA.ADD_POLICY(
        object_schema => 'GMS_ADMIN',
        object_name => 'STUDENTS',
        policy_name => 'fga_student_info_access',
        audit_condition => NULL,
        audit_column => 'EMAIL,PHONE_NUMBER,CONTACT_ADDRESS',
        statement_types => 'SELECT',
        enable => TRUE
    );
    DBMS_OUTPUT.PUT_LINE('FGA policy fga_student_info_access created');
END;
/

-- FGA for student data modifications
BEGIN
    DBMS_FGA.ADD_POLICY(
        object_schema => 'GMS_ADMIN',
        object_name => 'STUDENTS',
        policy_name => 'fga_student_modify',
        audit_condition => NULL,
        statement_types => 'UPDATE,DELETE',
        enable => TRUE
    );
    DBMS_OUTPUT.PUT_LINE('FGA policy fga_student_modify created');
END;
/

-- FGA for enrollment modifications
BEGIN
    DBMS_FGA.ADD_POLICY(
        object_schema => 'GMS_ADMIN',
        object_name => 'ENROLLMENTS',
        policy_name => 'fga_enrollment_modify',
        audit_condition => NULL,
        statement_types => 'UPDATE,DELETE',
        enable => TRUE
    );
    DBMS_OUTPUT.PUT_LINE('FGA policy fga_enrollment_modify created');
END;
/

-- FGA for system user modifications
BEGIN
    DBMS_FGA.ADD_POLICY(
        object_schema => 'GMS_ADMIN',
        object_name => 'SYSTEM_USERS',
        policy_name => 'fga_system_user_modify',
        audit_condition => NULL,
        statement_types => 'UPDATE,DELETE',
        enable => TRUE
    );
    DBMS_OUTPUT.PUT_LINE('FGA policy fga_system_user_modify created');
END;
/

-- FGA for deadline modifications
BEGIN
    DBMS_FGA.ADD_POLICY(
        object_schema => 'GMS_ADMIN',
        object_name => 'GRADE_SUBMISSION_DEADLINES',
        policy_name => 'fga_deadline_modify',
        audit_condition => NULL,
        statement_types => 'UPDATE,DELETE',
        enable => TRUE
    );
    DBMS_OUTPUT.PUT_LINE('FGA policy fga_deadline_modify created');
END;
/

-- =============================================
-- 3. CREATE AUDIT TRIGGERS FOR INSERT OPERATIONS
-- =============================================

-- Trigger for grade inserts
CREATE OR REPLACE TRIGGER trg_audit_grade_insert
AFTER INSERT ON GRADES
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO AUDIT_LOG (
        table_name,
        operation,
        user_id,
        username,
        record_id,
        new_values,
        operation_date,
        ip_address,
        session_id
    ) VALUES (
        'GRADES',
        'INSERT',
        SYS_CONTEXT('gms_context', 'user_id'),
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        TO_CHAR(:NEW.grade_id),
        'enrollment_id=' || :NEW.enrollment_id || ',midterm=' || :NEW.midterm_score || ',final=' || :NEW.final_score,
        SYSDATE,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYS_CONTEXT('USERENV', 'SESSIONID')
    );
    COMMIT;
END;
/

-- Trigger for student inserts
CREATE OR REPLACE TRIGGER trg_audit_student_insert
AFTER INSERT ON STUDENTS
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO AUDIT_LOG (
        table_name,
        operation,
        user_id,
        username,
        record_id,
        new_values,
        operation_date,
        ip_address,
        session_id
    ) VALUES (
        'STUDENTS',
        'INSERT',
        SYS_CONTEXT('gms_context', 'user_id'),
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        :NEW.student_id,
        'name=' || :NEW.first_name || ' ' || :NEW.last_name || ',class=' || :NEW.class_id,
        SYSDATE,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYS_CONTEXT('USERENV', 'SESSIONID')
    );
    COMMIT;
END;
/

-- =============================================
-- 4. VIEW AUDIT TRAIL
-- =============================================

-- Create view for FGA audit trail
-- FIX: Ép kiểu dữ liệu để tránh lỗi ORA-01790
CREATE OR REPLACE VIEW V_AUDIT_TRAIL AS
SELECT
    timestamp,
    db_user,
    object_schema,
    object_name,
    TO_CLOB(sql_text) as sql_text,
    policy_name,
    statement_type
FROM dba_fga_audit_trail
WHERE object_schema = 'GMS_ADMIN'
UNION ALL
SELECT
    CAST(operation_date AS TIMESTAMP) as timestamp,
    username as db_user,
    'GMS_ADMIN' as object_schema,
    table_name as object_name,
    new_values as sql_text,
    operation as policy_name,
    operation as statement_type
FROM gms_admin.AUDIT_LOG
ORDER BY timestamp DESC;

-- Grant select on audit view to admin (đã thừa vì GMS_ADMIN là owner, nhưng giữ lại để không lỗi nếu chạy trên user khác)
-- GRANT SELECT ON V_AUDIT_TRAIL TO GMS_ADMIN;

-- Display created FGA policies
SELECT object_schema, object_name, policy_name, enabled
FROM dba_audit_policies
WHERE object_schema = 'GMS_ADMIN'
ORDER BY object_name, policy_name;

COMMIT;
PROMPT ========================================
PROMPT Audit policies configured successfully!
PROMPT ========================================