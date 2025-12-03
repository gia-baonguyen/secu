/*******************************************************************************
 * File: 00_grant_test_privileges.sql
 * Purpose: Grant necessary privileges for VPD testing
 *
 * Run this script FIRST before testing VPD policies with non-privileged users
 *
 * Usage:
 *   sqlplus sys/YOUR_PASSWORD@ORCLPDB as sysdba
 *   @e:\Desktop\HCMUT\baomat\grade-management-system\database\04-tests\00_grant_test_privileges.sql
 *******************************************************************************/

PROMPT ===============================================================================
PROMPT Granting privileges for VPD testing...
PROMPT ===============================================================================

-- Grant privileges for GMS_STUDENT
PROMPT
PROMPT === Granting privileges to GMS_STUDENT ===
GRANT SELECT ON gms_admin.STUDENTS TO GMS_STUDENT;
GRANT SELECT ON gms_admin.GRADES TO GMS_STUDENT;
GRANT SELECT ON gms_admin.ENROLLMENTS TO GMS_STUDENT;
GRANT SELECT ON gms_admin.COURSE_SECTIONS TO GMS_STUDENT;
GRANT SELECT ON gms_admin.COURSES TO GMS_STUDENT;
GRANT EXECUTE ON gms_admin.gms_security_pkg TO GMS_STUDENT;

-- Grant privileges for GMS_LECTURER
PROMPT
PROMPT === Granting privileges to GMS_LECTURER ===
GRANT SELECT ON gms_admin.STUDENTS TO GMS_LECTURER;
GRANT SELECT ON gms_admin.GRADES TO GMS_LECTURER;
GRANT SELECT ON gms_admin.ENROLLMENTS TO GMS_LECTURER;
GRANT SELECT ON gms_admin.COURSE_SECTIONS TO GMS_LECTURER;
GRANT SELECT ON gms_admin.COURSES TO GMS_LECTURER;
GRANT SELECT ON gms_admin.LECTURERS TO GMS_LECTURER;
GRANT UPDATE ON gms_admin.GRADES TO GMS_LECTURER;
GRANT EXECUTE ON gms_admin.gms_security_pkg TO GMS_LECTURER;

-- Grant privileges for GMS_RELATIVE
PROMPT
PROMPT === Granting privileges to GMS_RELATIVE ===
GRANT SELECT ON gms_admin.RELATIVES TO GMS_RELATIVE;
GRANT SELECT ON gms_admin.GRADES TO GMS_RELATIVE;
GRANT SELECT ON gms_admin.ENROLLMENTS TO GMS_RELATIVE;
GRANT SELECT ON gms_admin.STUDENTS TO GMS_RELATIVE;
GRANT SELECT ON gms_admin.STUDENT_RELATIVES TO GMS_RELATIVE;
GRANT EXECUTE ON gms_admin.gms_security_pkg TO GMS_RELATIVE;

-- Grant privileges for GMS_DEAN
PROMPT
PROMPT === Granting privileges to GMS_DEAN ===
GRANT SELECT ON gms_admin.STUDENTS TO GMS_DEAN;
GRANT SELECT ON gms_admin.GRADES TO GMS_DEAN;
GRANT SELECT ON gms_admin.ENROLLMENTS TO GMS_DEAN;
GRANT SELECT ON gms_admin.COURSE_SECTIONS TO GMS_DEAN;
GRANT SELECT ON gms_admin.COURSES TO GMS_DEAN;
GRANT SELECT ON gms_admin.LECTURERS TO GMS_DEAN;
GRANT SELECT ON gms_admin.DEPARTMENTS TO GMS_DEAN;
GRANT SELECT ON gms_admin.FACULTIES TO GMS_DEAN;
GRANT EXECUTE ON gms_admin.gms_security_pkg TO GMS_DEAN;

-- Grant privileges for GMS_DEPT_HEAD
PROMPT
PROMPT === Granting privileges to GMS_DEPT_HEAD ===
GRANT SELECT ON gms_admin.STUDENTS TO GMS_DEPT_HEAD;
GRANT SELECT ON gms_admin.GRADES TO GMS_DEPT_HEAD;
GRANT SELECT ON gms_admin.ENROLLMENTS TO GMS_DEPT_HEAD;
GRANT SELECT ON gms_admin.COURSE_SECTIONS TO GMS_DEPT_HEAD;
GRANT SELECT ON gms_admin.COURSES TO GMS_DEPT_HEAD;
GRANT SELECT ON gms_admin.LECTURERS TO GMS_DEPT_HEAD;
GRANT SELECT ON gms_admin.DEPARTMENTS TO GMS_DEPT_HEAD;
GRANT EXECUTE ON gms_admin.gms_security_pkg TO GMS_DEPT_HEAD;

-- Grant privileges for GMS_ACADEMIC
PROMPT
PROMPT === Granting privileges to GMS_ACADEMIC ===
GRANT SELECT, INSERT, UPDATE, DELETE ON gms_admin.STUDENTS TO GMS_ACADEMIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON gms_admin.GRADES TO GMS_ACADEMIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON gms_admin.ENROLLMENTS TO GMS_ACADEMIC;
GRANT SELECT ON gms_admin.COURSE_SECTIONS TO GMS_ACADEMIC;
GRANT SELECT ON gms_admin.COURSES TO GMS_ACADEMIC;
GRANT SELECT ON gms_admin.LECTURERS TO GMS_ACADEMIC;
GRANT SELECT ON gms_admin.DEPARTMENTS TO GMS_ACADEMIC;
GRANT SELECT ON gms_admin.FACULTIES TO GMS_ACADEMIC;
GRANT EXECUTE ON gms_admin.gms_security_pkg TO GMS_ACADEMIC;

PROMPT
PROMPT ===============================================================================
PROMPT Privileges granted successfully!
PROMPT ===============================================================================
PROMPT
PROMPT You can now test VPD policies using:
PROMPT   - SQL*Plus: sqlplus GMS_STUDENT@ORCLPDB (enter password when prompted)
PROMPT   - DBeaver: Create connection with GMS_STUDENT / Student@2024
PROMPT
PROMPT After connecting, set context:
PROMPT   EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');
PROMPT
PROMPT Then query to verify VPD filtering:
PROMPT   SELECT COUNT(*) FROM gms_admin.STUDENTS;  -- Should see 1 (only STU001)
PROMPT   SELECT COUNT(*) FROM gms_admin.GRADES;     -- Should see 3 (STU001's grades)
PROMPT ===============================================================================

exit;
