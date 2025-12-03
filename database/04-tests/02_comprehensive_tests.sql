-- =============================================
-- COMPREHENSIVE SYSTEM TESTING
-- Grade Management System
-- =============================================

ALTER SESSION SET CONTAINER = ORCLPDB;
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK ON
SET ECHO ON
SET LINESIZE 200
SET PAGESIZE 100

PROMPT ========================================
PROMPT TEST SUITE 1: DATABASE CONNECTIVITY & SCHEMA
PROMPT ========================================

-- Test 1.1: Verify all users exist
PROMPT Test 1.1: Verify Database Users
SELECT username, account_status, profile, default_tablespace
FROM dba_users
WHERE username LIKE 'GMS_%'
ORDER BY username;

PROMPT Expected: 8 users (GMS_ADMIN, GMS_APP, GMS_STUDENT, GMS_LECTURER, GMS_ACADEMIC, GMS_DEAN, GMS_DEPT_HEAD, GMS_RELATIVE)
PROMPT ----------------------------------------

-- Test 1.2: Verify all tables exist
PROMPT Test 1.2: Verify All Tables Created
SELECT table_name, num_rows, tablespace_name
FROM dba_tables
WHERE owner = 'GMS_ADMIN'
ORDER BY table_name;

PROMPT Expected: 15 tables
PROMPT ----------------------------------------

-- Test 1.3: Verify views
PROMPT Test 1.3: Verify Views Created
SELECT view_name, text_length
FROM dba_views
WHERE owner = 'GMS_ADMIN'
ORDER BY view_name;

PROMPT Expected: 3 views (V_STUDENT_GRADES, V_STUDENT_GPA, V_AUDIT_TRAIL)
PROMPT ----------------------------------------

-- Test 1.4: Verify indexes
PROMPT Test 1.4: Verify Indexes Created
SELECT index_name, table_name, uniqueness
FROM dba_indexes
WHERE owner = 'GMS_ADMIN'
AND index_name LIKE 'IDX_%'
ORDER BY table_name, index_name;

PROMPT Expected: 12+ indexes
PROMPT ----------------------------------------

PROMPT ========================================
PROMPT TEST SUITE 2: DATA INTEGRITY
PROMPT ========================================

-- Test 2.1: Record counts
PROMPT Test 2.1: Verify Sample Data Loaded
SELECT 'FACULTIES' as table_name, COUNT(*) as record_count FROM gms_admin.FACULTIES
UNION ALL SELECT 'DEPARTMENTS', COUNT(*) FROM gms_admin.DEPARTMENTS
UNION ALL SELECT 'LECTURERS', COUNT(*) FROM gms_admin.LECTURERS
UNION ALL SELECT 'CLASSES', COUNT(*) FROM gms_admin.CLASSES
UNION ALL SELECT 'STUDENTS', COUNT(*) FROM gms_admin.STUDENTS
UNION ALL SELECT 'RELATIVES', COUNT(*) FROM gms_admin.RELATIVES
UNION ALL SELECT 'STUDENT_RELATIVES', COUNT(*) FROM gms_admin.STUDENT_RELATIVES
UNION ALL SELECT 'COURSES', COUNT(*) FROM gms_admin.COURSES
UNION ALL SELECT 'COURSE_SECTIONS', COUNT(*) FROM gms_admin.COURSE_SECTIONS
UNION ALL SELECT 'ENROLLMENTS', COUNT(*) FROM gms_admin.ENROLLMENTS
UNION ALL SELECT 'GRADES', COUNT(*) FROM gms_admin.GRADES
UNION ALL SELECT 'DEADLINES', COUNT(*) FROM gms_admin.GRADE_SUBMISSION_DEADLINES
UNION ALL SELECT 'SYSTEM_USERS', COUNT(*) FROM gms_admin.SYSTEM_USERS
ORDER BY table_name;

PROMPT Expected counts: FAC=3, DEPT=4, LEC=5, CLASS=4, STU=5, REL=3, etc.
PROMPT ----------------------------------------

-- Test 2.2: Foreign key integrity
PROMPT Test 2.2: Verify Foreign Key Relationships
SELECT constraint_name, table_name, constraint_type, r_constraint_name
FROM dba_constraints
WHERE owner = 'GMS_ADMIN'
AND constraint_type = 'R'
ORDER BY table_name, constraint_name;

PROMPT Expected: Multiple FK constraints
PROMPT ----------------------------------------

-- Test 2.3: Check constraint validation
PROMPT Test 2.3: Verify Check Constraints
SELECT constraint_name, table_name, search_condition
FROM dba_constraints
WHERE owner = 'GMS_ADMIN'
AND constraint_type = 'C'
AND constraint_name NOT LIKE 'SYS_%'
ORDER BY table_name;

PROMPT Expected: Multiple check constraints (gender, status, etc.)
PROMPT ----------------------------------------

PROMPT ========================================
PROMPT TEST SUITE 3: PASSWORD PROFILES
PROMPT ========================================

-- Test 3.1: Verify profiles exist
PROMPT Test 3.1: Verify Password Profiles Created
SELECT profile, resource_name, limit
FROM dba_profiles
WHERE profile LIKE 'GMS_%'
AND resource_name IN ('PASSWORD_LIFE_TIME', 'FAILED_LOGIN_ATTEMPTS', 'PASSWORD_LOCK_TIME', 'SESSIONS_PER_USER')
ORDER BY profile, resource_name;

PROMPT Expected: 5 profiles with different settings
PROMPT ----------------------------------------

-- Test 3.2: Verify profile assignments
PROMPT Test 3.2: Verify Profile Assignments to Users
SELECT username, profile, account_status
FROM dba_users
WHERE username LIKE 'GMS_%'
ORDER BY profile, username;

PROMPT Expected: Each user assigned appropriate profile
PROMPT ----------------------------------------

PROMPT ========================================
PROMPT TEST SUITE 4: VPD POLICIES
PROMPT ========================================

-- Test 4.1: Verify VPD policies exist
PROMPT Test 4.1: Verify VPD Policies Configured
SELECT object_owner, object_name, policy_name,
       CASE WHEN sel = 'YES' THEN 'S' ELSE '-' END ||
       CASE WHEN ins = 'YES' THEN 'I' ELSE '-' END ||
       CASE WHEN upd = 'YES' THEN 'U' ELSE '-' END ||
       CASE WHEN del = 'YES' THEN 'D' ELSE '-' END as operations,
       enable
FROM dba_policies
WHERE object_owner = 'GMS_ADMIN'
ORDER BY object_name, policy_name;

PROMPT Expected: 6 policies (STUDENTS, GRADES x3, RELATIVES, STUDENT_RELATIVES)
PROMPT ----------------------------------------

-- Test 4.2: Verify security context exists
PROMPT Test 4.2: Verify Security Context
SELECT namespace, schema, package
FROM dba_context
WHERE namespace = 'GMS_CONTEXT';

PROMPT Expected: 1 context (GMS_CONTEXT) using GMS_ADMIN.GMS_SECURITY_PKG
PROMPT ----------------------------------------

-- Test 4.3: Verify security package exists
PROMPT Test 4.3: Verify Security Package
SELECT object_name, object_type, status
FROM dba_objects
WHERE owner = 'GMS_ADMIN'
AND object_name = 'GMS_SECURITY_PKG'
ORDER BY object_type;

PROMPT Expected: PACKAGE and PACKAGE BODY, both VALID
PROMPT ----------------------------------------

-- Test 4.4: Test context setting
PROMPT Test 4.4: Test Context Setting and Retrieval
BEGIN
    gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');
    DBMS_OUTPUT.PUT_LINE('Context set successfully');
    DBMS_OUTPUT.PUT_LINE('User ID: ' || SYS_CONTEXT('gms_context', 'user_id'));
    DBMS_OUTPUT.PUT_LINE('User Type: ' || SYS_CONTEXT('gms_context', 'user_type'));
    DBMS_OUTPUT.PUT_LINE('Class ID: ' || SYS_CONTEXT('gms_context', 'class_id'));
    DBMS_OUTPUT.PUT_LINE('Faculty ID: ' || SYS_CONTEXT('gms_context', 'faculty_id'));
END;
/

PROMPT Expected: Context values populated correctly
PROMPT ----------------------------------------

PROMPT ========================================
PROMPT TEST SUITE 5: AUDIT POLICIES (FGA)
PROMPT ========================================

-- Test 5.1: Verify FGA policies exist
PROMPT Test 5.1: Verify FGA Policies Configured
SELECT object_schema, object_name, policy_name, policy_column,
       CASE WHEN sel = 'YES' THEN 'S' ELSE '-' END ||
       CASE WHEN ins = 'YES' THEN 'I' ELSE '-' END ||
       CASE WHEN upd = 'YES' THEN 'U' ELSE '-' END ||
       CASE WHEN del = 'YES' THEN 'D' ELSE '-' END as operations,
       enabled
FROM dba_audit_policies
WHERE object_schema = 'GMS_ADMIN'
ORDER BY object_name, policy_name;

PROMPT Expected: 8 FGA policies
PROMPT ----------------------------------------

-- Test 5.2: Verify audit triggers exist
PROMPT Test 5.2: Verify Audit Triggers
SELECT trigger_name, table_name, triggering_event, status
FROM dba_triggers
WHERE owner = 'GMS_ADMIN'
AND trigger_name LIKE 'TRG_AUDIT%'
ORDER BY trigger_name;

PROMPT Expected: 2 triggers (trg_audit_grade_insert, trg_audit_student_insert)
PROMPT ----------------------------------------

-- Test 5.3: Check if audit handler exists
PROMPT Test 5.3: Verify Audit Handler Procedure
SELECT object_name, object_type, status
FROM dba_objects
WHERE owner = 'GMS_ADMIN'
AND object_name = 'AUDIT_GRADE_HANDLER';

PROMPT Expected: PROCEDURE, VALID
PROMPT ----------------------------------------

PROMPT ========================================
PROMPT TEST SUITE 6: BUSINESS LOGIC VALIDATION
PROMPT ========================================

-- Test 6.1: Verify faculty hierarchy
PROMPT Test 6.1: Verify Faculty-Department-Class Hierarchy
SELECT f.faculty_id, f.faculty_name,
       d.department_id, d.department_name,
       c.class_id, c.class_name
FROM gms_admin.FACULTIES f
LEFT JOIN gms_admin.DEPARTMENTS d ON f.faculty_id = d.faculty_id
LEFT JOIN gms_admin.CLASSES c ON f.faculty_id = c.faculty_id
ORDER BY f.faculty_id, d.department_id, c.class_id;

PROMPT Expected: Proper hierarchy relationships
PROMPT ----------------------------------------

-- Test 6.2: Verify student enrollments
PROMPT Test 6.2: Verify Student Enrollments with Courses
SELECT s.student_id, s.first_name || ' ' || s.last_name as student_name,
       COUNT(e.enrollment_id) as enrolled_courses
FROM gms_admin.STUDENTS s
LEFT JOIN gms_admin.ENROLLMENTS e ON s.student_id = e.student_id
GROUP BY s.student_id, s.first_name, s.last_name
ORDER BY s.student_id;

PROMPT Expected: Each student has 1-3 enrollments
PROMPT ----------------------------------------

-- Test 6.3: Verify grades with enrollment
PROMPT Test 6.3: Verify Grades Linked to Enrollments
SELECT e.student_id, c.course_name,
       g.midterm_score, g.final_score, g.total_score, g.letter_grade, g.grade_status
FROM gms_admin.GRADES g
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN gms_admin.COURSES c ON cs.course_id = c.course_id
ORDER BY e.student_id, c.course_name;

PROMPT Expected: 7 grade records with proper scores
PROMPT ----------------------------------------

-- Test 6.4: Test GPA calculation view
PROMPT Test 6.4: Test Student GPA View
SELECT * FROM gms_admin.V_STUDENT_GPA
WHERE rownum <= 5;

PROMPT Expected: GPA calculations visible
PROMPT ----------------------------------------

-- Test 6.5: Verify deadline configuration
PROMPT Test 6.5: Verify Grade Submission Deadlines
SELECT semester, academic_year, submission_deadline, is_active
FROM gms_admin.GRADE_SUBMISSION_DEADLINES
ORDER BY academic_year, semester;

PROMPT Expected: 3 deadlines configured
PROMPT ----------------------------------------

PROMPT ========================================
PROMPT TEST SUITE 7: SECURITY CONTEXT TESTING
PROMPT ========================================

-- Test 7.1: Test different user contexts
PROMPT Test 7.1: Testing Multiple User Contexts

-- Student context
BEGIN
    gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');
    DBMS_OUTPUT.PUT_LINE('=== Student STU001 Context ===');
    DBMS_OUTPUT.PUT_LINE('User Type: ' || SYS_CONTEXT('gms_context', 'user_type'));
    DBMS_OUTPUT.PUT_LINE('Class ID: ' || SYS_CONTEXT('gms_context', 'class_id'));
END;
/

-- Lecturer context
BEGIN
    gms_admin.gms_security_pkg.set_user_context('LEC001', 'Lecturer');
    DBMS_OUTPUT.PUT_LINE('=== Lecturer LEC001 Context ===');
    DBMS_OUTPUT.PUT_LINE('User Type: ' || SYS_CONTEXT('gms_context', 'user_type'));
    DBMS_OUTPUT.PUT_LINE('Department: ' || SYS_CONTEXT('gms_context', 'department_id'));
END;
/

-- Dean context
BEGIN
    gms_admin.gms_security_pkg.set_user_context('LEC001', 'Dean');
    DBMS_OUTPUT.PUT_LINE('=== Dean (LEC001) Context ===');
    DBMS_OUTPUT.PUT_LINE('User Type: ' || SYS_CONTEXT('gms_context', 'user_type'));
    DBMS_OUTPUT.PUT_LINE('Faculty: ' || SYS_CONTEXT('gms_context', 'faculty_id'));
END;
/

PROMPT ----------------------------------------

PROMPT ========================================
PROMPT TEST SUITE 8: DATA VALIDATION
PROMPT ========================================

-- Test 8.1: Check for orphaned records
PROMPT Test 8.1: Check for Orphaned Records (Students without Classes)
SELECT COUNT(*) as orphaned_students
FROM gms_admin.STUDENTS s
WHERE NOT EXISTS (SELECT 1 FROM gms_admin.CLASSES c WHERE c.class_id = s.class_id);

PROMPT Expected: 0 (no orphaned records)
PROMPT ----------------------------------------

-- Test 8.2: Check for invalid grades
PROMPT Test 8.2: Check for Invalid Grade Scores
SELECT grade_id, midterm_score, final_score, total_score
FROM gms_admin.GRADES
WHERE midterm_score NOT BETWEEN 0 AND 10
   OR final_score NOT BETWEEN 0 AND 10
   OR total_score NOT BETWEEN 0 AND 10;

PROMPT Expected: 0 rows (all scores valid)
PROMPT ----------------------------------------

-- Test 8.3: Check for duplicate enrollments
PROMPT Test 8.3: Check for Duplicate Enrollments
SELECT student_id, section_id, COUNT(*) as duplicate_count
FROM gms_admin.ENROLLMENTS
GROUP BY student_id, section_id
HAVING COUNT(*) > 1;

PROMPT Expected: 0 rows (no duplicates due to unique constraint)
PROMPT ----------------------------------------

PROMPT ========================================
PROMPT TEST SUITE 9: PERFORMANCE CHECK
PROMPT ========================================

-- Test 9.1: Query execution with VPD (as SYS - bypasses VPD)
PROMPT Test 9.1: Query Performance Test
SET TIMING ON

SELECT COUNT(*) as total_students FROM gms_admin.STUDENTS;
SELECT COUNT(*) as total_grades FROM gms_admin.GRADES;
SELECT COUNT(*) as total_enrollments FROM gms_admin.ENROLLMENTS;

SET TIMING OFF

PROMPT ----------------------------------------

PROMPT ========================================
PROMPT TEST SUITE 10: FINAL VALIDATION
PROMPT ========================================

-- Test 10.1: Overall system health check
PROMPT Test 10.1: System Health Check Summary

DECLARE
    v_user_count NUMBER;
    v_table_count NUMBER;
    v_vpd_count NUMBER;
    v_fga_count NUMBER;
    v_profile_count NUMBER;
    v_data_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_user_count FROM dba_users WHERE username LIKE 'GMS_%';
    SELECT COUNT(*) INTO v_table_count FROM dba_tables WHERE owner = 'GMS_ADMIN';
    SELECT COUNT(*) INTO v_vpd_count FROM dba_policies WHERE object_owner = 'GMS_ADMIN';
    SELECT COUNT(*) INTO v_fga_count FROM dba_audit_policies WHERE object_schema = 'GMS_ADMIN';
    SELECT COUNT(*) INTO v_profile_count FROM dba_profiles WHERE profile LIKE 'GMS_%';
    SELECT COUNT(*) INTO v_data_count FROM gms_admin.STUDENTS;

    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('SYSTEM HEALTH CHECK SUMMARY');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Database Users:      ' || v_user_count || ' / 8 expected');
    DBMS_OUTPUT.PUT_LINE('Tables Created:      ' || v_table_count || ' / 15 expected');
    DBMS_OUTPUT.PUT_LINE('VPD Policies:        ' || v_vpd_count || ' / 6 expected');
    DBMS_OUTPUT.PUT_LINE('FGA Policies:        ' || v_fga_count || ' / 8 expected');
    DBMS_OUTPUT.PUT_LINE('Password Profiles:   ' || v_profile_count || ' / 5 expected');
    DBMS_OUTPUT.PUT_LINE('Sample Data Loaded:  ' || v_data_count || ' / 5 students expected');
    DBMS_OUTPUT.PUT_LINE('========================================');

    IF v_user_count = 8 AND v_table_count = 15 AND v_vpd_count = 6
       AND v_fga_count = 8 AND v_profile_count = 5 AND v_data_count = 5 THEN
        DBMS_OUTPUT.PUT_LINE('RESULT: ALL TESTS PASSED ✓');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULT: SOME TESTS FAILED ✗');
    END IF;
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

PROMPT ========================================
PROMPT COMPREHENSIVE TESTING COMPLETE
PROMPT ========================================
PROMPT
PROMPT Next Steps:
PROMPT 1. Grant SELECT privileges to test users for VPD testing
PROMPT 2. Connect as individual users to verify row-level security
PROMPT 3. Perform INSERT/UPDATE operations to test audit triggers
PROMPT 4. Review audit trail in V_AUDIT_TRAIL view
PROMPT
PROMPT For VPD Testing:
PROMPT   GRANT SELECT ON gms_admin.STUDENTS TO GMS_STUDENT;
PROMPT   GRANT SELECT ON gms_admin.GRADES TO GMS_STUDENT;
PROMPT   CONNECT GMS_STUDENT/"Student@2024"@//localhost:1521/ORCLPDB
PROMPT
PROMPT ========================================
