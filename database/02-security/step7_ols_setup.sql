-- =============================================
-- UNIVERSITY GRADE MANAGEMENT SYSTEM
-- Step 7: Oracle Label Security (OLS) Configuration
-- Complete Setup Script with Test Cases
-- =============================================
--
-- * WARNING: OLS REQUIRES ORACLE ENTERPRISE EDITION *
-- Oracle XE does NOT fully support OLS due to missing
-- Enterprise Edition features (SUPPLEMENTAL_LOG_DATA pragma).
-- If using Oracle XE, skip this step and rely on VPD instead.
--
-- IMPORTANT: This script must be run in SEPARATE sessions!
--
-- Session 0: SYSDBA (in CDB$ROOT) - ENABLE OLS (if ORA-12458 occurs)
-- Session 1: SYSDBA (in CDB$ROOT) - Unlock LBACSYS
-- Session 2: SYSDBA (in ORCLPDB) - Create table & grant permissions
-- Session 3: LBACSYS (in ORCLPDB) - Create OLS policy
-- Session 4: GMS_ADMIN (in ORCLPDB) - Insert data & test
--
-- =============================================

-- =============================================
-- SESSION 0: ENABLE OLS (Run ONLY if you get ORA-12458!)
-- =============================================
-- sqlplus sys/password@localhost:1521/ORCL as sysdba
-- =============================================
--
-- If you see error: ORA-12458: Oracle Label Security not enabled
-- OLS is INSTALLED but NOT ENABLED. Run this section first!
--
-- IMPORTANT: After running Session 0, you MUST restart database!
-- Then continue with Session 1.
-- =============================================

PROMPT
PROMPT =============================================
PROMPT SESSION 0: ENABLE OLS (Skip if OLS already enabled)
PROMPT =============================================

SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON SIZE UNLIMITED

-- Ensure we're in CDB$ROOT
ALTER SESSION SET CONTAINER = CDB$ROOT;

-- Check current OLS status
PROMPT
PROMPT Checking if OLS is enabled...
COL PARAMETER FORMAT A30
COL VALUE FORMAT A10
SELECT PARAMETER, VALUE FROM V$OPTION WHERE PARAMETER = 'Oracle Label Security';

PROMPT
PROMPT If VALUE = TRUE, skip to Session 1.
PROMPT If VALUE = FALSE, run catols.sql below:
PROMPT

-- Uncomment and run this line to enable OLS:
-- @?/rdbms/admin/catols.sql

PROMPT
PROMPT =============================================
PROMPT AFTER RUNNING catols.sql, RESTART DATABASE:
PROMPT =============================================
PROMPT
PROMPT   SHUTDOWN IMMEDIATE;
PROMPT   STARTUP;
PROMPT   ALTER PLUGGABLE DATABASE ALL OPEN;
PROMPT
PROMPT Then verify: SELECT VALUE FROM V$OPTION WHERE PARAMETER = 'Oracle Label Security';
PROMPT (Should return TRUE)
PROMPT
PROMPT =============================================


-- =============================================
-- SESSION 1: Run as SYSDBA in CDB$ROOT
-- =============================================
-- sqlplus sys/password@localhost:1521/ORCL as sysdba
-- =============================================

PROMPT
PROMPT =============================================
PROMPT SESSION 1: CDB$ROOT - Check & Unlock LBACSYS
PROMPT =============================================

-- Make sure we're in CDB$ROOT
ALTER SESSION SET CONTAINER = CDB$ROOT;

-- Check if OLS is ENABLED (not just installed)
PROMPT
PROMPT Checking if OLS is ENABLED...
SELECT PARAMETER, VALUE FROM V$OPTION WHERE PARAMETER = 'Oracle Label Security';

-- Check OLS registry status
PROMPT
PROMPT Checking OLS installation status...
SELECT comp_id, comp_name, version, status FROM dba_registry WHERE comp_id = 'OLS';

PROMPT
PROMPT If VALUE = FALSE above, OLS is NOT ENABLED!
PROMPT You must run Session 0 commands first (see top of this file).
PROMPT

-- Unlock LBACSYS user (must be done in CDB$ROOT for common user)
PROMPT Unlocking LBACSYS...
ALTER USER LBACSYS IDENTIFIED BY "Lbacsys123#" ACCOUNT UNLOCK CONTAINER=ALL;

PROMPT
PROMPT =============================================
PROMPT SESSION 1 COMPLETE!
PROMPT Now run Session 2 commands in ORCLPDB
PROMPT =============================================
PROMPT
PROMPT Next: sqlplus sys/password@localhost:1521/ORCLPDB as sysdba
PROMPT


-- =============================================
-- SESSION 2: Run as SYSDBA in ORCLPDB
-- =============================================
-- sqlplus sys/password@localhost:1521/ORCLPDB as sysdba
-- =============================================

PROMPT
PROMPT =============================================
PROMPT SESSION 2: ORCLPDB - Setup Table & Permissions
PROMPT =============================================

ALTER SESSION SET CONTAINER = ORCLPDB;

-- Grant OLS admin role to GMS_ADMIN
GRANT LBAC_DBA TO GMS_ADMIN;

-- Grant execute on OLS packages
GRANT EXECUTE ON LBACSYS.SA_SYSDBA TO GMS_ADMIN;
GRANT EXECUTE ON LBACSYS.SA_COMPONENTS TO GMS_ADMIN;
GRANT EXECUTE ON LBACSYS.SA_LABEL_ADMIN TO GMS_ADMIN;
GRANT EXECUTE ON LBACSYS.SA_POLICY_ADMIN TO GMS_ADMIN;
GRANT EXECUTE ON LBACSYS.SA_USER_ADMIN TO GMS_ADMIN;
GRANT EXECUTE ON LBACSYS.SA_SESSION TO GMS_ADMIN;

-- Drop and create table
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE GMS_ADMIN.EXAM_QUESTIONS CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE GMS_ADMIN.EXAM_QUESTIONS (
    question_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    subject_code VARCHAR2(10),
    question_text VARCHAR2(500),
    correct_answer VARCHAR2(200),
    created_by VARCHAR2(50),
    created_date DATE DEFAULT SYSDATE
);

-- Grant permissions on table
GRANT SELECT, INSERT, UPDATE, DELETE ON GMS_ADMIN.EXAM_QUESTIONS TO GMS_STUDENT;
GRANT SELECT, INSERT, UPDATE, DELETE ON GMS_ADMIN.EXAM_QUESTIONS TO GMS_LECTURER;
GRANT SELECT, INSERT, UPDATE, DELETE ON GMS_ADMIN.EXAM_QUESTIONS TO GMS_DEAN;

PROMPT
PROMPT =============================================
PROMPT SESSION 2 COMPLETE!
PROMPT Now run Session 3 commands as LBACSYS
PROMPT =============================================
PROMPT
PROMPT Next: sqlplus LBACSYS/Lbacsys123#@localhost:1521/ORCLPDB
PROMPT


-- =============================================
-- SESSION 3: Run as LBACSYS in ORCLPDB
-- =============================================
-- sqlplus LBACSYS/Lbacsys123#@localhost:1521/ORCLPDB
-- =============================================

PROMPT
PROMPT =============================================
PROMPT SESSION 3: LBACSYS - Create OLS Policy
PROMPT =============================================

SET SERVEROUTPUT ON SIZE UNLIMITED

-- Drop existing policy
BEGIN
    SA_SYSDBA.DROP_POLICY(policy_name => 'EXAM_SEC_POLICY', drop_column => TRUE);
    DBMS_OUTPUT.PUT_LINE('Old policy dropped.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('No existing policy (OK).');
END;
/

-- Create policy
BEGIN
    SA_SYSDBA.CREATE_POLICY (
        policy_name      => 'EXAM_SEC_POLICY',
        column_name      => 'OLS_LABEL',
        default_options  => 'READ_CONTROL,WRITE_CONTROL'
    );
    DBMS_OUTPUT.PUT_LINE('Policy EXAM_SEC_POLICY created.');
END;
/

-- Create Levels
BEGIN
    SA_COMPONENTS.CREATE_LEVEL('EXAM_SEC_POLICY', 1000, 'PUB', 'PUBLIC');
    SA_COMPONENTS.CREATE_LEVEL('EXAM_SEC_POLICY', 2000, 'INT', 'INTERNAL');
    SA_COMPONENTS.CREATE_LEVEL('EXAM_SEC_POLICY', 3000, 'CONF', 'CONFIDENTIAL');
    DBMS_OUTPUT.PUT_LINE('Levels created: PUB, INT, CONF');
END;
/

-- Create Compartments
BEGIN
    SA_COMPONENTS.CREATE_COMPARTMENT('EXAM_SEC_POLICY', 100, 'CS', 'COMPUTER SCIENCE');
    SA_COMPONENTS.CREATE_COMPARTMENT('EXAM_SEC_POLICY', 200, 'EE', 'ELECTRICAL ENGINEERING');
    DBMS_OUTPUT.PUT_LINE('Compartments created: CS, EE');
END;
/

-- Create Labels
BEGIN
    SA_LABEL_ADMIN.CREATE_LABEL('EXAM_SEC_POLICY', 1000, 'PUB', TRUE);
    SA_LABEL_ADMIN.CREATE_LABEL('EXAM_SEC_POLICY', 2100, 'INT:CS', TRUE);
    SA_LABEL_ADMIN.CREATE_LABEL('EXAM_SEC_POLICY', 2200, 'INT:EE', TRUE);
    SA_LABEL_ADMIN.CREATE_LABEL('EXAM_SEC_POLICY', 3100, 'CONF:CS', TRUE);
    DBMS_OUTPUT.PUT_LINE('Labels created: PUB, INT:CS, INT:EE, CONF:CS');
END;
/

-- Apply policy to table
BEGIN
    SA_POLICY_ADMIN.APPLY_TABLE_POLICY (
        policy_name    => 'EXAM_SEC_POLICY',
        schema_name    => 'GMS_ADMIN',
        table_name     => 'EXAM_QUESTIONS',
        table_options  => 'READ_CONTROL,WRITE_CONTROL,LABEL_DEFAULT'
    );
    DBMS_OUTPUT.PUT_LINE('Policy applied to EXAM_QUESTIONS.');
END;
/

-- Authorize Users
-- GMS_STUDENT: Only PUBLIC (can only see public questions)
BEGIN
    SA_USER_ADMIN.SET_USER_LABELS('EXAM_SEC_POLICY', 'GMS_STUDENT', max_read_label => 'PUB');
    DBMS_OUTPUT.PUT_LINE('GMS_STUDENT: PUB (read only)');
END;
/

-- GMS_LECTURER: INTERNAL:CS (can see public + internal CS)
BEGIN
    SA_USER_ADMIN.SET_USER_LABELS (
        policy_name     => 'EXAM_SEC_POLICY',
        user_name       => 'GMS_LECTURER',
        max_read_label  => 'INT:CS',
        max_write_label => 'INT:CS',
        min_write_label => 'PUB',
        def_label       => 'INT:CS',
        row_label       => 'INT:CS'
    );
    DBMS_OUTPUT.PUT_LINE('GMS_LECTURER: INT:CS (read/write)');
END;
/

-- GMS_DEAN: CONFIDENTIAL:CS (can see all CS including confidential)
BEGIN
    SA_USER_ADMIN.SET_USER_LABELS (
        policy_name     => 'EXAM_SEC_POLICY',
        user_name       => 'GMS_DEAN',
        max_read_label  => 'CONF:CS',
        max_write_label => 'CONF:CS',
        min_write_label => 'PUB',
        def_label       => 'CONF:CS',
        row_label       => 'CONF:CS'
    );
    DBMS_OUTPUT.PUT_LINE('GMS_DEAN: CONF:CS (read/write)');
END;
/

-- GMS_DEAN: CONFIDENTIAL:CS (can see all CS including confidential)
BEGIN
    SA_USER_ADMIN.SET_USER_LABELS (
        policy_name     => 'EXAM_SEC_POLICY',
        user_name       => 'GMS_ACADEMIC',
        max_read_label  => 'CONF:CS',
        max_write_label => 'CONF:CS',
        min_write_label => 'PUB',
        def_label       => 'CONF:CS',
        row_label       => 'CONF:CS'
    );
    DBMS_OUTPUT.PUT_LINE('GMS_ACADEMIC: CONF:CS (read/write)');
END;
/

-- GMS_ADMIN: FULL privileges (bypass OLS)
BEGIN
    SA_USER_ADMIN.SET_USER_PRIVS('EXAM_SEC_POLICY', 'GMS_ADMIN', privileges => 'FULL');
    DBMS_OUTPUT.PUT_LINE('GMS_ADMIN: FULL privileges');
END;

BEGIN
    SA_USER_ADMIN.SET_USER_PRIVS('EXAM_SEC_POLICY', 'GMS_ACADEMIC', privileges => 'FULL');
    DBMS_OUTPUT.PUT_LINE('GMS_ACADEMIC: FULL privileges');
END;
/

-- Verify policy
PROMPT
PROMPT Verification:
SELECT policy_name, status FROM dba_sa_policies WHERE policy_name = 'EXAM_SEC_POLICY';
SELECT level_num, short_name, long_name FROM dba_sa_levels WHERE policy_name = 'EXAM_SEC_POLICY' ORDER BY level_num;
SELECT comp_num, short_name, long_name FROM dba_sa_compartments WHERE policy_name = 'EXAM_SEC_POLICY';
SELECT label_tag, label FROM dba_sa_labels WHERE policy_name = 'EXAM_SEC_POLICY' ORDER BY label_tag;

PROMPT
PROMPT =============================================
PROMPT SESSION 3 COMPLETE!
PROMPT Now run Session 4 commands as GMS_ADMIN
PROMPT =============================================
PROMPT
PROMPT Next: sqlplus GMS_ADMIN/Admin@2024#Secure@localhost:1521/ORCLPDB
PROMPT


-- =============================================
-- SESSION 4: Run as GMS_ADMIN in ORCLPDB
-- =============================================
-- sqlplus GMS_ADMIN/Admin@2024#Secure@localhost:1521/ORCLPDB
-- =============================================

PROMPT
PROMPT =============================================
PROMPT SESSION 4: GMS_ADMIN - Insert Data & Test
PROMPT =============================================

SET SERVEROUTPUT ON SIZE UNLIMITED

-- Insert sample data with different security labels
PROMPT
PROMPT Inserting sample exam questions...

-- PUBLIC question (Everyone can see)
INSERT INTO gms_admin.EXAM_QUESTIONS (subject_code, question_text, correct_answer, created_by, ols_label) VALUES ('CS101', 'PUBLIC: What is 1+1?', '2', 'SYSTEM', CHAR_TO_LABEL('EXAM_SEC_POLICY', 'PUB'));

-- INTERNAL:CS question (Lecturer CS + Dean CS can see)
INSERT INTO gms_admin.EXAM_QUESTIONS (subject_code, question_text, correct_answer, created_by, ols_label) VALUES ('CS102', 'INTERNAL CS: Explain QuickSort algorithm', 'O(n log n)', 'LEC001', CHAR_TO_LABEL('EXAM_SEC_POLICY', 'INT:CS'));

-- INTERNAL:EE question (Only EE faculty can see)
INSERT INTO gms_admin.EXAM_QUESTIONS (subject_code, question_text, correct_answer, created_by, ols_label) VALUES ('EE201', 'INTERNAL EE: State Ohm Law', 'V = I * R', 'LEC004', CHAR_TO_LABEL('EXAM_SEC_POLICY', 'INT:EE'));

-- CONFIDENTIAL:CS question (Only Dean CS can see)
INSERT INTO gms_admin.EXAM_QUESTIONS (subject_code, question_text, correct_answer, created_by, ols_label) VALUES ('CS999', 'TOP SECRET: Final Exam Key 2025', 'A,C,D,B,A...', 'DEAN001', CHAR_TO_LABEL('EXAM_SEC_POLICY', 'CONF:CS'));

COMMIT;

PROMPT
PROMPT All data as GMS_ADMIN (FULL privileges - sees all 4 rows):
SELECT question_id, subject_code, SUBSTR(question_text,1,35) as question, LABEL_TO_CHAR(ols_label) as label
FROM EXAM_QUESTIONS ORDER BY question_id;

PROMPT
PROMPT =============================================
PROMPT OLS SETUP COMPLETED!
PROMPT =============================================


-- =============================================
-- TEST CASES
-- =============================================

PROMPT
PROMPT =============================================
PROMPT TEST CASES - Run each in separate session
PROMPT =============================================

PROMPT
PROMPT =============================================
PROMPT TEST 1: GMS_STUDENT (Should see 1 row - PUB only)
PROMPT =============================================
PROMPT
PROMPT Connect: sqlplus GMS_STUDENT/Student@2024@localhost:1521/ORCLPDB
PROMPT Run: SELECT question_id, subject_code, question_text, LABEL_TO_CHAR(ols_label) as label FROM GMS_ADMIN.EXAM_QUESTIONS;
PROMPT Expected: 1 row (CS101 - PUBLIC)
PROMPT

PROMPT
PROMPT =============================================
PROMPT TEST 2: GMS_LECTURER (Should see 2 rows - PUB + INT:CS)
PROMPT =============================================
PROMPT
PROMPT Connect: sqlplus GMS_LECTURER/Lecturer@2024@localhost:1521/ORCLPDB
PROMPT Run: SELECT question_id, subject_code, question_text, LABEL_TO_CHAR(ols_label) as label FROM GMS_ADMIN.EXAM_QUESTIONS;
PROMPT Expected: 2 rows (CS101 + CS102)
PROMPT Note: Cannot see EE201 (INT:EE) or CS999 (CONF:CS)
PROMPT

PROMPT
PROMPT =============================================
PROMPT TEST 3: GMS_DEAN (Should see 3 rows - PUB + INT:CS + CONF:CS)
PROMPT =============================================
PROMPT
PROMPT Connect: sqlplus GMS_DEAN/Dean@2024@localhost:1521/ORCLPDB
PROMPT Run: SELECT question_id, subject_code, question_text, LABEL_TO_CHAR(ols_label) as label FROM GMS_ADMIN.EXAM_QUESTIONS;
PROMPT Expected: 3 rows (CS101 + CS102 + CS999)
PROMPT Note: Cannot see EE201 (INT:EE) - Dean is CS faculty only
PROMPT

PROMPT
PROMPT =============================================
PROMPT SUMMARY: OLS Security Matrix
PROMPT =============================================
PROMPT
PROMPT | User         | Can See                    |
PROMPT |--------------|----------------------------|
PROMPT | GMS_STUDENT  | PUB only (1 row)           |
PROMPT | GMS_LECTURER | PUB + INT:CS (2 rows)      |
PROMPT | GMS_DEAN     | PUB + INT:CS + CONF:CS (3) |
PROMPT | GMS_ADMIN    | ALL (4 rows - FULL bypass) |
PROMPT
PROMPT Note: INT:EE is only visible to EE faculty users
PROMPT
PROMPT =============================================