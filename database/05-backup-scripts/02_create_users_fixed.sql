-- =============================================
-- UNIVERSITY GRADE MANAGEMENT SYSTEM
-- User Creation Script (Fixed for Oracle 19c CDB/PDB)
-- System B: Quy trình quản lý điểm trong trường đại học
-- =============================================

-- Check if we're in CDB or PDB
SHOW CON_NAME;

-- Option 1: Switch to PDB (Recommended)
-- Uncomment the line below if you have XEPDB1 or ORCLPDB
-- ALTER SESSION SET CONTAINER = XEPDB1;
-- ALTER SESSION SET CONTAINER = ORCLPDB;

-- Option 2: Create users in PDB
-- If you're in CDB root, switch to PDB first
BEGIN
  EXECUTE IMMEDIATE 'ALTER SESSION SET CONTAINER = XEPDB1';
EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      EXECUTE IMMEDIATE 'ALTER SESSION SET CONTAINER = ORCLPDB';
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Could not switch to PDB. Creating common users instead.');
    END;
END;
/

-- Drop existing users if they exist
BEGIN
    FOR usr IN (SELECT username FROM dba_users WHERE username LIKE 'GMS_%' OR username LIKE 'C##GMS_%') LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP USER ' || usr.username || ' CASCADE';
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END;
/

-- Check current container
SELECT SYS_CONTEXT('USERENV', 'CON_NAME') AS current_container FROM DUAL;

-- Create main application user
-- Note: If in CDB, prefix with C##
DECLARE
    v_container VARCHAR2(30);
    v_sql VARCHAR2(4000);
    v_user_prefix VARCHAR2(10) := '';
BEGIN
    -- Check if we're in CDB or PDB
    SELECT SYS_CONTEXT('USERENV', 'CON_NAME') INTO v_container FROM DUAL;

    IF v_container = 'CDB$ROOT' THEN
        -- We're in CDB, need C## prefix
        v_user_prefix := 'C##';
        DBMS_OUTPUT.PUT_LINE('In CDB - Creating common users with C## prefix');
    ELSE
        -- We're in PDB, no prefix needed
        v_user_prefix := '';
        DBMS_OUTPUT.PUT_LINE('In PDB - Creating local users');
    END IF;

    -- Create GMS_ADMIN user
    v_sql := 'CREATE USER ' || v_user_prefix || 'GMS_ADMIN IDENTIFIED BY "Admin@2024#Secure" ' ||
             'DEFAULT TABLESPACE grade_mgmt_data ' ||
             'TEMPORARY TABLESPACE grade_mgmt_temp ' ||
             'QUOTA UNLIMITED ON grade_mgmt_data ' ||
             'QUOTA UNLIMITED ON grade_mgmt_idx';

    IF v_container = 'CDB$ROOT' THEN
        v_sql := v_sql || ' CONTAINER=ALL';
    END IF;

    EXECUTE IMMEDIATE v_sql;

    -- Grant privileges to admin user
    EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE, DBA TO ' || v_user_prefix || 'GMS_ADMIN';
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ' || v_user_prefix || 'GMS_ADMIN';
    EXECUTE IMMEDIATE 'GRANT CREATE TABLE TO ' || v_user_prefix || 'GMS_ADMIN';
    EXECUTE IMMEDIATE 'GRANT CREATE VIEW TO ' || v_user_prefix || 'GMS_ADMIN';
    EXECUTE IMMEDIATE 'GRANT CREATE PROCEDURE TO ' || v_user_prefix || 'GMS_ADMIN';
    EXECUTE IMMEDIATE 'GRANT CREATE SEQUENCE TO ' || v_user_prefix || 'GMS_ADMIN';
    EXECUTE IMMEDIATE 'GRANT CREATE TRIGGER TO ' || v_user_prefix || 'GMS_ADMIN';
    EXECUTE IMMEDIATE 'GRANT CREATE TYPE TO ' || v_user_prefix || 'GMS_ADMIN';
    EXECUTE IMMEDIATE 'GRANT CREATE SYNONYM TO ' || v_user_prefix || 'GMS_ADMIN';
    EXECUTE IMMEDIATE 'GRANT CREATE MATERIALIZED VIEW TO ' || v_user_prefix || 'GMS_ADMIN';
    EXECUTE IMMEDIATE 'GRANT CREATE DATABASE LINK TO ' || v_user_prefix || 'GMS_ADMIN';
    EXECUTE IMMEDIATE 'GRANT CREATE JOB TO ' || v_user_prefix || 'GMS_ADMIN';

    -- Create GMS_APP user
    v_sql := 'CREATE USER ' || v_user_prefix || 'GMS_APP IDENTIFIED BY "App@2024#Connect" ' ||
             'DEFAULT TABLESPACE grade_mgmt_data ' ||
             'TEMPORARY TABLESPACE grade_mgmt_temp';

    IF v_container = 'CDB$ROOT' THEN
        v_sql := v_sql || ' CONTAINER=ALL';
    END IF;

    EXECUTE IMMEDIATE v_sql;
    EXECUTE IMMEDIATE 'GRANT CONNECT TO ' || v_user_prefix || 'GMS_APP';
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ' || v_user_prefix || 'GMS_APP';

    -- Create GMS_STUDENT user
    v_sql := 'CREATE USER ' || v_user_prefix || 'GMS_STUDENT IDENTIFIED BY "Student@2024" ' ||
             'DEFAULT TABLESPACE grade_mgmt_data ' ||
             'TEMPORARY TABLESPACE grade_mgmt_temp';

    IF v_container = 'CDB$ROOT' THEN
        v_sql := v_sql || ' CONTAINER=ALL';
    END IF;

    EXECUTE IMMEDIATE v_sql;
    EXECUTE IMMEDIATE 'GRANT CONNECT TO ' || v_user_prefix || 'GMS_STUDENT';
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ' || v_user_prefix || 'GMS_STUDENT';

    -- Create GMS_LECTURER user
    v_sql := 'CREATE USER ' || v_user_prefix || 'GMS_LECTURER IDENTIFIED BY "Lecturer@2024" ' ||
             'DEFAULT TABLESPACE grade_mgmt_data ' ||
             'TEMPORARY TABLESPACE grade_mgmt_temp';

    IF v_container = 'CDB$ROOT' THEN
        v_sql := v_sql || ' CONTAINER=ALL';
    END IF;

    EXECUTE IMMEDIATE v_sql;
    EXECUTE IMMEDIATE 'GRANT CONNECT TO ' || v_user_prefix || 'GMS_LECTURER';
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ' || v_user_prefix || 'GMS_LECTURER';

    -- Create GMS_ACADEMIC user
    v_sql := 'CREATE USER ' || v_user_prefix || 'GMS_ACADEMIC IDENTIFIED BY "Academic@2024" ' ||
             'DEFAULT TABLESPACE grade_mgmt_data ' ||
             'TEMPORARY TABLESPACE grade_mgmt_temp';

    IF v_container = 'CDB$ROOT' THEN
        v_sql := v_sql || ' CONTAINER=ALL';
    END IF;

    EXECUTE IMMEDIATE v_sql;
    EXECUTE IMMEDIATE 'GRANT CONNECT TO ' || v_user_prefix || 'GMS_ACADEMIC';
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ' || v_user_prefix || 'GMS_ACADEMIC';

    -- Create GMS_DEAN user
    v_sql := 'CREATE USER ' || v_user_prefix || 'GMS_DEAN IDENTIFIED BY "Dean@2024" ' ||
             'DEFAULT TABLESPACE grade_mgmt_data ' ||
             'TEMPORARY TABLESPACE grade_mgmt_temp';

    IF v_container = 'CDB$ROOT' THEN
        v_sql := v_sql || ' CONTAINER=ALL';
    END IF;

    EXECUTE IMMEDIATE v_sql;
    EXECUTE IMMEDIATE 'GRANT CONNECT TO ' || v_user_prefix || 'GMS_DEAN';
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ' || v_user_prefix || 'GMS_DEAN';

    -- Create GMS_DEPT_HEAD user
    v_sql := 'CREATE USER ' || v_user_prefix || 'GMS_DEPT_HEAD IDENTIFIED BY "DeptHead@2024" ' ||
             'DEFAULT TABLESPACE grade_mgmt_data ' ||
             'TEMPORARY TABLESPACE grade_mgmt_temp';

    IF v_container = 'CDB$ROOT' THEN
        v_sql := v_sql || ' CONTAINER=ALL';
    END IF;

    EXECUTE IMMEDIATE v_sql;
    EXECUTE IMMEDIATE 'GRANT CONNECT TO ' || v_user_prefix || 'GMS_DEPT_HEAD';
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ' || v_user_prefix || 'GMS_DEPT_HEAD';

    -- Create GMS_RELATIVE user
    v_sql := 'CREATE USER ' || v_user_prefix || 'GMS_RELATIVE IDENTIFIED BY "Relative@2024" ' ||
             'DEFAULT TABLESPACE grade_mgmt_data ' ||
             'TEMPORARY TABLESPACE grade_mgmt_temp';

    IF v_container = 'CDB$ROOT' THEN
        v_sql := v_sql || ' CONTAINER=ALL';
    END IF;

    EXECUTE IMMEDIATE v_sql;
    EXECUTE IMMEDIATE 'GRANT CONNECT TO ' || v_user_prefix || 'GMS_RELATIVE';
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ' || v_user_prefix || 'GMS_RELATIVE';

    -- Display created users
    DBMS_OUTPUT.PUT_LINE('Users created successfully with prefix: ' || v_user_prefix);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RAISE;
END;
/

-- Show created users
SELECT username, account_status, default_tablespace
FROM dba_users
WHERE username LIKE '%GMS_%'
ORDER BY username;

COMMIT;