/*******************************************************************************
 * File: test_vpd_via_sysdba.sql
 * Workaround: Test VPD by switching to GMS_STUDENT schema from SYSDBA
 *
 * LƯU Ý: VPD policies KHÔNG áp dụng cho SYSDBA, nhưng có thể test basic queries
 *******************************************************************************/

SET SERVEROUTPUT ON
SET LINESIZE 200
SET PAGESIZE 50

PROMPT ===============================================================================
PROMPT Workaround Test: Check if GMS_STUDENT can query tables
PROMPT ===============================================================================

-- Grant CREATE SESSION if needed
PROMPT Ensuring GMS_STUDENT has CREATE SESSION privilege...
GRANT CREATE SESSION TO GMS_STUDENT;

PROMPT
PROMPT === Testing connection by attempting to connect as GMS_STUDENT ===
CONNECT GMS_STUDENT/Student@2024@ngbao:1521/orclpdb

-- If connection succeeds, test queries
SELECT USER as "Current User" FROM DUAL;

-- Set context
EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');

-- Verify context
SELECT SYS_CONTEXT('gms_context', 'user_id') as user_id,
       SYS_CONTEXT('gms_context', 'user_type') as user_type
FROM DUAL;

-- Test queries
SELECT COUNT(*) as "Students Visible" FROM gms_admin.STUDENTS;
SELECT student_id, first_name, last_name FROM gms_admin.STUDENTS;

PROMPT
PROMPT ===============================================================================
PROMPT If you see data above, connection works!
PROMPT ===============================================================================

exit;
