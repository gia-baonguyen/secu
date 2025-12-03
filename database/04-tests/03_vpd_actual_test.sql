-- =============================================
-- VPD ACTUAL USER TESTING
-- Test VPD policies with real user connections
-- =============================================

SET SERVEROUTPUT ON
SET FEEDBACK ON
SET ECHO ON
SET LINESIZE 150

PROMPT ========================================
PROMPT VPD TEST 1: STUDENT USER (GMS_STUDENT)
PROMPT ========================================

-- Connect as GMS_STUDENT (must run this separately)
-- CONNECT GMS_STUDENT/"Student@2024"@//localhost:1521/ORCLPDB

PROMPT After connecting as GMS_STUDENT, run these queries:
PROMPT
PROMPT -- Set student context
PROMPT EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');
PROMPT
PROMPT -- Check context
PROMPT SELECT SYS_CONTEXT('gms_context', 'user_id') as user_id,
PROMPT        SYS_CONTEXT('gms_context', 'user_type') as user_type
PROMPT FROM DUAL;
PROMPT
PROMPT -- Query STUDENTS table (should see only STU001)
PROMPT SELECT student_id, first_name, last_name FROM gms_admin.STUDENTS;
PROMPT
PROMPT -- Query GRADES table (should see only STU001 grades)
PROMPT SELECT g.grade_id, e.student_id, g.total_score
PROMPT FROM gms_admin.GRADES g
PROMPT JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id;
PROMPT
PROMPT Expected: 1 student record, 3 grade records for STU001
PROMPT ========================================

PROMPT ========================================
PROMPT VPD TEST 2: LECTURER USER (GMS_LECTURER)
PROMPT ========================================

-- Connect as GMS_LECTURER (must run this separately)
-- CONNECT GMS_LECTURER/"Lecturer@2024"@//localhost:1521/ORCLPDB

PROMPT After connecting as GMS_LECTURER, run these queries:
PROMPT
PROMPT -- Set lecturer context
PROMPT EXEC gms_admin.gms_security_pkg.set_user_context('LEC001', 'Lecturer');
PROMPT
PROMPT -- Query STUDENTS table (should see homeroom students)
PROMPT SELECT student_id, first_name, last_name, class_id
PROMPT FROM gms_admin.STUDENTS;
PROMPT
PROMPT -- Query GRADES for courses taught
PROMPT SELECT g.grade_id, e.student_id, cs.course_id, g.total_score
PROMPT FROM gms_admin.GRADES g
PROMPT JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
PROMPT JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id;
PROMPT
PROMPT Expected: 2 students from CLS001, grades from SEC001 and SEC003
PROMPT ========================================

PROMPT ========================================
PROMPT VPD TEST 3: RELATIVE USER (GMS_RELATIVE)
PROMPT ========================================

-- Connect as GMS_RELATIVE (must run this separately)
-- CONNECT GMS_RELATIVE/"Relative@2024"@//localhost:1521/ORCLPDB

PROMPT After connecting as GMS_RELATIVE, run these queries:
PROMPT
PROMPT -- Set relative context
PROMPT EXEC gms_admin.gms_security_pkg.set_user_context('REL001', 'Relative');
PROMPT
PROMPT -- Query RELATIVES table (should see only own record)
PROMPT SELECT relative_id, first_name, last_name FROM gms_admin.RELATIVES;
PROMPT
PROMPT -- Query GRADES for children
PROMPT SELECT g.grade_id, e.student_id, g.total_score
PROMPT FROM gms_admin.GRADES g
PROMPT JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id;
PROMPT
PROMPT Expected: 1 relative record (REL001), 3 grade records for STU001
PROMPT ========================================

PROMPT ========================================
PROMPT NOTE: VPD policies do NOT apply to:
PROMPT - SYS and SYSTEM users
PROMPT - Table owner (GMS_ADMIN)
PROMPT - Users with EXEMPT ACCESS POLICY privilege
PROMPT
PROMPT To properly test VPD:
PROMPT 1. Open separate SQL*Plus sessions
PROMPT 2. CONNECT as each test user
PROMPT 3. Set context using gms_security_pkg
PROMPT 4. Run SELECT queries
PROMPT 5. Compare results with expected values
PROMPT ========================================
