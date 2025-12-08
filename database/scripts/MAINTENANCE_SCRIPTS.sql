-- =============================================
-- MAINTENANCE SCRIPTS - ALL IN ONE
-- Grade Management System - Complete Maintenance Script
-- =============================================
-- Usage: sqlplus sys/YOUR_PASSWORD@//localhost:1521/ORCLPDB as sysdba @MAINTENANCE_SCRIPTS.sql
--
-- This script includes:
-- PART 1: Grant permissions to GMS_ACADEMIC (backend)
-- PART 2: Update password hashes for authentication
-- PART 3: Fix session and idle time limits (ORA-02391, ORA-02396)
-- PART 4: Fix GMS_ACADEMIC VPD bypass (allow GMS_ACADEMIC to see all data)
-- PART 5: Verify permissions
-- =============================================

ALTER SESSION SET CONTAINER = ORCLPDB;
SET SERVEROUTPUT ON

PROMPT ========================================
PROMPT MAINTENANCE SCRIPTS - ALL IN ONE
PROMPT ========================================
PROMPT

-- =============================================
-- PART 1: GRANT PERMISSIONS TO GMS_ACADEMIC
-- =============================================
PROMPT [PART 1/5] Granting permissions to GMS_ACADEMIC...
PROMPT ========================================

-- Grant SELECT on all tables (automatic)
BEGIN
    FOR t IN (SELECT table_name FROM all_tables WHERE owner = 'GMS_ADMIN') LOOP
        BEGIN
            EXECUTE IMMEDIATE 'GRANT SELECT ON gms_admin.' || t.table_name || ' TO GMS_ACADEMIC';
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END;
/

-- Grant INSERT, UPDATE, DELETE on all tables (automatic)
BEGIN
    FOR t IN (SELECT table_name FROM all_tables WHERE owner = 'GMS_ADMIN') LOOP
        BEGIN
            EXECUTE IMMEDIATE 'GRANT INSERT, UPDATE, DELETE ON gms_admin.' || t.table_name || ' TO GMS_ACADEMIC';
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END;
/

-- Grant SELECT on all views (automatic)
BEGIN
    FOR v IN (SELECT view_name FROM all_views WHERE owner = 'GMS_ADMIN') LOOP
        BEGIN
            EXECUTE IMMEDIATE 'GRANT SELECT ON gms_admin.' || v.view_name || ' TO GMS_ACADEMIC';
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END;
/

-- Grant EXECUTE on security package
BEGIN
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON gms_admin.gms_security_pkg TO GMS_ACADEMIC';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

COMMIT;
PROMPT ✓ Permissions granted to GMS_ACADEMIC successfully!
PROMPT

-- =============================================
-- PART 2: UPDATE PASSWORD HASHES
-- =============================================
PROMPT [PART 2/5] Updating password hashes...
PROMPT ========================================

-- BCrypt hash for password "password123"
DEFINE password_hash = '$2a$10$AUVO7tMKpNbIOCKe0pm9feHwXj1thjOR6XbdwyF6veha4BnwGEEJu'

-- Update all users with the same password hash for testing
UPDATE gms_admin.SYSTEM_USERS
SET password_hash = '&password_hash',
    updated_date = SYSDATE
WHERE is_active = 'Y';

PROMPT ✓ Updated password hashes for all active users
PROMPT   Password for all users: password123
PROMPT

COMMIT;

-- =============================================
-- PART 3: FIX SESSION & IDLE TIME LIMITS
-- =============================================
PROMPT [PART 3/5] Fixing session and idle time limits...
PROMPT ========================================

-- Fix SESSIONS_PER_USER limits
ALTER PROFILE GMS_STUDENT_PROFILE LIMIT SESSIONS_PER_USER 20;
ALTER PROFILE GMS_LECTURER_PROFILE LIMIT SESSIONS_PER_USER 20;
ALTER PROFILE GMS_ADMIN_PROFILE LIMIT SESSIONS_PER_USER 20;
ALTER PROFILE GMS_RELATIVE_PROFILE LIMIT SESSIONS_PER_USER 10;
ALTER PROFILE GMS_SYSADMIN_PROFILE LIMIT SESSIONS_PER_USER UNLIMITED;

-- Fix IDLE_TIME limits
ALTER PROFILE GMS_STUDENT_PROFILE LIMIT IDLE_TIME 240;
ALTER PROFILE GMS_LECTURER_PROFILE LIMIT IDLE_TIME 240;
ALTER PROFILE GMS_ADMIN_PROFILE LIMIT IDLE_TIME 240;
ALTER PROFILE GMS_RELATIVE_PROFILE LIMIT IDLE_TIME 480;
ALTER PROFILE GMS_SYSADMIN_PROFILE LIMIT IDLE_TIME UNLIMITED;

PROMPT ✓ Session and idle time limits updated
PROMPT

COMMIT;

-- =============================================
-- PART 4: FIX GMS_ACADEMIC VPD BYPASS
-- =============================================
PROMPT [PART 4/5] Fixing VPD policies for GMS_ACADEMIC bypass...
PROMPT ========================================

-- Recompile VPD policies to allow GMS_ACADEMIC bypass
ALTER SESSION SET CURRENT_SCHEMA = GMS_ADMIN;
@@../02-security/step4_vpd_policies.sql

PROMPT ✓ VPD policies updated - GMS_ACADEMIC can now see all data
PROMPT

COMMIT;

-- =============================================
-- PART 5: VERIFY PERMISSIONS
-- =============================================
PROMPT [PART 5/5] Verifying permissions...
PROMPT ========================================

SELECT 
    COUNT(DISTINCT table_name) as tables_with_select
FROM dba_tab_privs
WHERE owner = 'GMS_ADMIN'
  AND grantee = 'GMS_ACADEMIC'
  AND privilege = 'SELECT'
  AND table_name NOT LIKE 'V_%';

SELECT 
    COUNT(DISTINCT table_name) as views_with_select
FROM dba_tab_privs
WHERE owner = 'GMS_ADMIN'
  AND grantee = 'GMS_ACADEMIC'
  AND privilege = 'SELECT'
  AND table_name LIKE 'V_%';

PROMPT
PROMPT ========================================
PROMPT MAINTENANCE COMPLETE!
PROMPT ========================================
PROMPT
PROMPT Summary:
PROMPT ✓ GMS_ACADEMIC permissions granted
PROMPT ✓ Password hashes updated
PROMPT ✓ Session/idle time limits fixed
PROMPT ✓ VPD bypass configured for GMS_ACADEMIC
PROMPT
PROMPT Test users (Password: password123):
PROMPT - Username: nvhai (STU001) - Password: password123
PROMPT - Username: nv.an (LEC001) - Password: password123
PROMPT - Username: admin (Admin) - Password: password123
PROMPT ========================================

COMMIT;
