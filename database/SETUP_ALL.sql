-- =====================================================
-- MASTER SETUP SCRIPT
-- Run all database security setup scripts in order
-- =====================================================
-- Prerequisites:
--   - Oracle Database 19c running
--   - ORCLPDB pluggable database created
--   - Connected as SYS with SYSDBA privilege
-- =====================================================
-- Usage:
--   cd D:\BaoMatHTTT\secu
--   sqlplus sys/YOUR_PASSWORD@//localhost:1521/ORCLPDB as sysdba
--   @database\SETUP_ALL.sql
-- =====================================================

SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON
SPOOL setup_all.log

-- =====================================================
-- SET CONTAINER TO ORCLPDB
-- =====================================================
PROMPT Setting container to ORCLPDB...
ALTER SESSION SET CONTAINER = ORCLPDB;
SHOW CON_NAME;

PROMPT =====================================================
PROMPT Grade Management System - Complete Setup
PROMPT =====================================================
PROMPT This script will:
PROMPT   1. Create database users (8 users)
PROMPT   2. Create tables and relationships (14 tables)
PROMPT   3. Setup password profiles (5 profiles)
PROMPT   4. Setup VPD policies (6 policies)
PROMPT   5. Setup audit policies (8 FGA + 2 triggers)
PROMPT   6. Load sample data (60+ records)
PROMPT   7. Setup OLS (Oracle Label Security) - OPTIONAL
PROMPT =====================================================
PROMPT
PROMPT Starting setup at:
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') as current_time FROM dual;
PROMPT =====================================================

-- =====================================================
-- STEP 1: CREATE DATABASE USERS
-- =====================================================
PROMPT
PROMPT =====================================================
PROMPT STEP 1/6: Creating Database Users...
PROMPT =====================================================
@@01-schema/step1_create_users.sql

PROMPT
PROMPT Users creation completed.
PROMPT

-- =====================================================
-- STEP 2: CREATE TABLES
-- =====================================================
PROMPT
PROMPT =====================================================
PROMPT STEP 2/6: Creating Tables and Relationships...
PROMPT =====================================================
@@01-schema/step2_create_tables.sql

PROMPT
PROMPT Tables creation completed.
PROMPT

-- =====================================================
-- STEP 3: SETUP PASSWORD PROFILES
-- =====================================================
PROMPT
PROMPT =====================================================
PROMPT STEP 3/6: Setting up Password Profiles...
PROMPT =====================================================
@@02-security/step3_password_profiles.sql

PROMPT
PROMPT Password profiles setup completed.
PROMPT

-- =====================================================
-- STEP 4: SETUP VPD POLICIES
-- =====================================================
PROMPT
PROMPT =====================================================
PROMPT STEP 4/6: Setting up VPD (Virtual Private Database)...
PROMPT =====================================================
@@02-security/step4_vpd_policies.sql

PROMPT
PROMPT VPD policies setup completed.
PROMPT

-- =====================================================
-- STEP 5: SETUP AUDIT POLICIES
-- =====================================================
PROMPT
PROMPT =====================================================
PROMPT STEP 5/6: Setting up Audit Policies...
PROMPT =====================================================
@@02-security/step5_audit_policies.sql

PROMPT
PROMPT Audit policies setup completed.
PROMPT

-- =====================================================
-- STEP 6: LOAD SAMPLE DATA
-- =====================================================
PROMPT
PROMPT =====================================================
PROMPT STEP 6/6: Loading Sample Data...
PROMPT =====================================================
@@03-data/step6_sample_data.sql

PROMPT
PROMPT Sample data loaded.
PROMPT

-- =====================================================
-- STEP 7: SETUP OLS (OPTIONAL - Requires OLS enabled)
-- =====================================================
PROMPT
PROMPT =====================================================
PROMPT STEP 7/7: Setting up OLS (Oracle Label Security)...
PROMPT =====================================================
PROMPT NOTE: This step is OPTIONAL and requires OLS to be enabled.
PROMPT To enable OLS, run as SYSDBA:
PROMPT   EXEC LBACSYS.CONFIGURE_OLS;
PROMPT   EXEC LBACSYS.OLS_ENFORCEMENT.ENABLE_OLS;
PROMPT
PROMPT Uncomment the line below in SETUP_ALL.sql to enable OLS setup.
PROMPT

-- Uncomment the line below to enable OLS setup:
@@02-security/step7_ols_setup.sql

PROMPT
PROMPT OLS setup skipped (uncomment in SETUP_ALL.sql to enable).
PROMPT

-- =====================================================
-- FINAL VERIFICATION
-- =====================================================
PROMPT
PROMPT =====================================================
PROMPT FINAL VERIFICATION
PROMPT =====================================================

PROMPT
PROMPT 1. Checking Database Users:
SELECT username, account_status, profile
FROM dba_users
WHERE username LIKE 'GMS_%'
ORDER BY username;

PROMPT
PROMPT 2. Checking Tables:
SELECT table_name, num_rows
FROM dba_tables
WHERE owner = 'GMS_ADMIN'
ORDER BY table_name;

PROMPT
PROMPT 3. Checking VPD Policies:
SELECT object_name, policy_name, enable
FROM dba_policies
WHERE object_owner = 'GMS_ADMIN';

PROMPT
PROMPT 4. Checking Audit Configuration:
SELECT object_name, policy_name, enabled
FROM dba_audit_policies
WHERE object_schema = 'GMS_ADMIN';

PROMPT
PROMPT 5. Checking Triggers:
SELECT trigger_name, table_name, status
FROM dba_triggers
WHERE owner = 'GMS_ADMIN'
AND trigger_name LIKE 'TRG_%';

PROMPT
PROMPT 6. Checking Data Counts:
SELECT 'STUDENTS' as table_name, COUNT(*) as records FROM gms_admin.STUDENTS
UNION ALL
SELECT 'LECTURERS', COUNT(*) FROM gms_admin.LECTURERS
UNION ALL
SELECT 'GRADES', COUNT(*) FROM gms_admin.GRADES
UNION ALL
SELECT 'COURSES', COUNT(*) FROM gms_admin.COURSES
UNION ALL
SELECT 'SYSTEM_USERS', COUNT(*) FROM gms_admin.SYSTEM_USERS;

PROMPT
PROMPT 7. Checking OLS Policy (if configured):
SELECT policy_name, status
FROM dba_sa_policies
WHERE policy_name = 'EXAM_SEC_POLICY';

-- =====================================================
-- COMPLETION MESSAGE
-- =====================================================
PROMPT
PROMPT =====================================================
PROMPT Setup completed at:
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') as current_time FROM dual;
PROMPT =====================================================
PROMPT
PROMPT All components have been set up successfully!
PROMPT
PROMPT Database Users (8):
PROMPT   GMS_ADMIN, GMS_APP, GMS_STUDENT, GMS_LECTURER,
PROMPT   GMS_ACADEMIC, GMS_DEAN, GMS_DEPT_HEAD, GMS_RELATIVE
PROMPT
PROMPT Test Credentials:
PROMPT   GMS_STUDENT / Student@2024
PROMPT   GMS_LECTURER / Lecturer@2024
PROMPT   GMS_ACADEMIC / Academic@2024
PROMPT   GMS_RELATIVE / Relative@2024
PROMPT
PROMPT Next Steps:
PROMPT   1. Review setup_all.log for any errors
PROMPT   2. Run tests: @04-tests/02_comprehensive_tests.sql
PROMPT   3. Test VPD: Connect as GMS_STUDENT and query tables
PROMPT
PROMPT Refer to HUONG_DAN.md for detailed instructions.
PROMPT =====================================================

SPOOL OFF
