-- =====================================================
-- MASTER SETUP SCRIPT
-- Run all database security setup scripts in order
-- =====================================================
-- Prerequisites:
--   - Oracle Database 19c running
--   - ORCLPDB pluggable database created
--   - Connected as SYS with SYSDBA privilege
-- =====================================================

SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON
SPOOL setup_all.log

PROMPT =====================================================
PROMPT Grade Management System - Complete Setup
PROMPT =====================================================
PROMPT This script will:
PROMPT   1. Create database schema and tables
PROMPT   2. Setup VPD (Virtual Private Database)
PROMPT   3. Setup OLS (Oracle Label Security)
PROMPT   4. Setup Audit Trail
PROMPT   5. Setup Password Policies
PROMPT   6. Load test data
PROMPT =====================================================
PROMPT
PROMPT Starting setup at:
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') as current_time FROM dual;
PROMPT =====================================================

-- =====================================================
-- STEP 1: CREATE SCHEMA
-- =====================================================
PROMPT
PROMPT =====================================================
PROMPT STEP 1/6: Creating Database Schema...
PROMPT =====================================================
@@01-schema/create_tables.sql

PROMPT
PROMPT Schema creation completed.
PROMPT Press Enter to continue...
PAUSE

-- =====================================================
-- STEP 2: SETUP VPD
-- =====================================================
PROMPT
PROMPT =====================================================
PROMPT STEP 2/6: Setting up VPD (Virtual Private Database)...
PROMPT =====================================================
@@02-security/01_vpd_setup.sql

PROMPT
PROMPT VPD setup completed.
PROMPT Press Enter to continue...
PAUSE

-- =====================================================
-- STEP 3: SETUP OLS
-- =====================================================
PROMPT
PROMPT =====================================================
PROMPT STEP 3/6: Setting up OLS (Oracle Label Security)...
PROMPT =====================================================
PROMPT NOTE: This requires LBACSYS to be installed.
PROMPT If OLS is not available, this step may fail (non-critical).
PROMPT =====================================================
@@02-security/02_ols_setup.sql

PROMPT
PROMPT OLS setup completed (or skipped if not available).
PROMPT Press Enter to continue...
PAUSE

-- =====================================================
-- STEP 4: SETUP AUDIT TRAIL
-- =====================================================
PROMPT
PROMPT =====================================================
PROMPT STEP 4/6: Setting up Audit Trail...
PROMPT =====================================================
@@02-security/03_audit_setup.sql

PROMPT
PROMPT Audit trail setup completed.
PROMPT Press Enter to continue...
PAUSE

-- =====================================================
-- STEP 5: SETUP PASSWORD POLICY
-- =====================================================
PROMPT
PROMPT =====================================================
PROMPT STEP 5/6: Setting up Password Policies...
PROMPT =====================================================
@@02-security/04_password_policy.sql

PROMPT
PROMPT Password policy setup completed.
PROMPT Press Enter to continue...
PAUSE

-- =====================================================
-- STEP 6: LOAD TEST DATA
-- =====================================================
PROMPT
PROMPT =====================================================
PROMPT STEP 6/6: Loading Test Data...
PROMPT =====================================================
@@03-data/simple_test_data.sql

PROMPT
PROMPT Test data loaded.

-- =====================================================
-- FINAL VERIFICATION
-- =====================================================
PROMPT
PROMPT =====================================================
PROMPT FINAL VERIFICATION
PROMPT =====================================================

PROMPT
PROMPT 1. Checking Tables:
SELECT owner, table_name, num_rows
FROM dba_tables
WHERE owner = 'GMS_ADMIN'
ORDER BY table_name;

PROMPT
PROMPT 2. Checking VPD Policies:
SELECT object_owner, object_name, policy_name, enable
FROM dba_policies
WHERE object_owner = 'GMS_ADMIN';

PROMPT
PROMPT 3. Checking Audit Configuration:
SELECT trigger_name, table_name, status
FROM dba_triggers
WHERE owner = 'GMS_ADMIN'
AND trigger_name LIKE 'TRG_%';

PROMPT
PROMPT 4. Checking Test Users:
SELECT username, user_type, reference_id, is_active
FROM GMS_ADMIN.SYSTEM_USERS
ORDER BY user_type, username;

PROMPT
PROMPT 5. Checking Security Status:
SELECT * FROM GMS_ADMIN.v_user_security_status;

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
PROMPT Next Steps:
PROMPT   1. Review the setup_all.log file for any errors
PROMPT   2. Start the Spring Boot backend (port 8081)
PROMPT   3. Open demo/index.html in your browser
PROMPT   4. Test with the provided credentials
PROMPT
PROMPT Test Credentials:
PROMPT   Students:
PROMPT     username: nvhai   | password: student123
PROMPT     username: tthoa   | password: student123
PROMPT     username: lvminh  | password: student123
PROMPT
PROMPT   Lecturers:
PROMPT     username: ntmai   | password: lecturer123
PROMPT     username: tvnam   | password: lecturer123
PROMPT
PROMPT   Admin:
PROMPT     username: admin   | password: admin123
PROMPT
PROMPT Security Features Enabled:
PROMPT   - VPD (Virtual Private Database) - Row-level security
PROMPT   - OLS (Oracle Label Security) - Classification labels
PROMPT   - Audit Trail - Activity logging
PROMPT   - Password Policy - Security enforcement
PROMPT
PROMPT Refer to demo/README.md for testing instructions.
PROMPT =====================================================

SPOOL OFF
EXIT;
