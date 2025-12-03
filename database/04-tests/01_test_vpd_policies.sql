-- =============================================
-- UNIVERSITY GRADE MANAGEMENT SYSTEM
-- VPD Policy Testing Script
-- =============================================

ALTER SESSION SET CONTAINER = ORCLPDB;
ALTER SESSION SET CURRENT_SCHEMA = GMS_ADMIN;

SET SERVEROUTPUT ON
SET FEEDBACK ON
SET ECHO ON

PROMPT ========================================
PROMPT TEST 1: Student Context - Student can only see their own data
PROMPT ========================================

-- Simulate student STU001 login by setting context
BEGIN
    gms_security_pkg.set_user_context('STU001', 'Student');
    DBMS_OUTPUT.PUT_LINE('Context set for Student STU001');
END;
/

-- Check context
SELECT SYS_CONTEXT('gms_context', 'user_id') as user_id,
       SYS_CONTEXT('gms_context', 'user_type') as user_type,
       SYS_CONTEXT('gms_context', 'class_id') as class_id
FROM DUAL;

-- Student should only see their own record
PROMPT Testing STUDENTS table access...
SELECT student_id, first_name, last_name, class_id
FROM STUDENTS;

PROMPT Student should see: Only STU001 record
PROMPT ----------------------------------------

-- Student should only see their own grades
PROMPT Testing GRADES table access...
SELECT g.grade_id, e.student_id, g.midterm_score, g.final_score, g.total_score
FROM GRADES g
JOIN ENROLLMENTS e ON g.enrollment_id = e.enrollment_id;

PROMPT Student should see: Only their own grades (3 records for STU001)
PROMPT ----------------------------------------

PROMPT ========================================
PROMPT TEST 2: Lecturer Context - Lecturer can see students they teach
PROMPT ========================================

-- Simulate lecturer LEC001 login
BEGIN
    gms_security_pkg.set_user_context('LEC001', 'Lecturer');
    DBMS_OUTPUT.PUT_LINE('Context set for Lecturer LEC001');
END;
/

-- Check context
SELECT SYS_CONTEXT('gms_context', 'user_id') as user_id,
       SYS_CONTEXT('gms_context', 'user_type') as user_type,
       SYS_CONTEXT('gms_context', 'department_id') as dept_id
FROM DUAL;

-- Lecturer as homeroom teacher should see students in their class
PROMPT Testing STUDENTS table access (homeroom teacher)...
SELECT student_id, first_name, last_name, class_id
FROM STUDENTS;

PROMPT Lecturer LEC001 is homeroom teacher of CLS001
PROMPT Should see: STU001, STU002 (2 students in CLS001)
PROMPT ----------------------------------------

-- Lecturer should see grades for courses they teach
PROMPT Testing GRADES table access (courses taught)...
SELECT g.grade_id, e.student_id, cs.course_id, g.midterm_score, g.final_score
FROM GRADES g
JOIN ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN COURSE_SECTIONS cs ON e.section_id = cs.section_id;

PROMPT LEC001 teaches SEC001-HK1 (CSE101) and SEC003-HK1 (CSE301)
PROMPT Should see: Grades from these sections
PROMPT ----------------------------------------

PROMPT ========================================
PROMPT TEST 3: Relative Context - Relative can see their children data
PROMPT ========================================

-- Simulate relative REL001 login
BEGIN
    gms_security_pkg.set_user_context('REL001', 'Relative');
    DBMS_OUTPUT.PUT_LINE('Context set for Relative REL001');
END;
/

-- Check context
SELECT SYS_CONTEXT('gms_context', 'user_id') as user_id,
       SYS_CONTEXT('gms_context', 'user_type') as user_type
FROM DUAL;

-- Relative should only see their own record
PROMPT Testing RELATIVES table access...
SELECT relative_id, first_name, last_name, phone_number
FROM RELATIVES;

PROMPT Should see: Only REL001 record
PROMPT ----------------------------------------

-- Relative should see their children grades
PROMPT Testing GRADES table access (children)...
SELECT g.grade_id, e.student_id, g.midterm_score, g.final_score, g.total_score
FROM GRADES g
JOIN ENROLLMENTS e ON g.enrollment_id = e.enrollment_id;

PROMPT REL001 is father of STU001
PROMPT Should see: All grades of STU001 (3 records)
PROMPT ----------------------------------------

PROMPT ========================================
PROMPT TEST 4: Dean Context - Dean can see faculty data
PROMPT ========================================

-- Simulate dean login (LEC001 is dean of FAC001)
BEGIN
    gms_security_pkg.set_user_context('LEC001', 'Dean');
    DBMS_OUTPUT.PUT_LINE('Context set for Dean LEC001 (FAC001)');
END;
/

-- Check context
SELECT SYS_CONTEXT('gms_context', 'user_id') as user_id,
       SYS_CONTEXT('gms_context', 'user_type') as user_type,
       SYS_CONTEXT('gms_context', 'faculty_id') as faculty_id
FROM DUAL;

-- Dean should see students in their faculty
PROMPT Testing STUDENTS table access (faculty)...
SELECT student_id, first_name, last_name, class_id
FROM STUDENTS;

PROMPT Dean of FAC001 should see: Students in CLS001, CLS002, CLS003 (4 students)
PROMPT ----------------------------------------

-- Dean should see grades for students in their faculty
PROMPT Testing GRADES table access (faculty)...
SELECT g.grade_id, e.student_id, g.midterm_score, g.final_score
FROM GRADES g
JOIN ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN STUDENTS s ON e.student_id = s.student_id
JOIN CLASSES c ON s.class_id = c.class_id;

PROMPT Should see: Grades for students in FAC001
PROMPT ----------------------------------------

PROMPT ========================================
PROMPT TEST 5: Academic Affairs Context - Full access
PROMPT ========================================

-- Simulate academic affairs login
BEGIN
    gms_security_pkg.set_user_context('ACAD001', 'Academic_Affairs');
    DBMS_OUTPUT.PUT_LINE('Context set for Academic Affairs');
END;
/

-- Check context
SELECT SYS_CONTEXT('gms_context', 'user_id') as user_id,
       SYS_CONTEXT('gms_context', 'user_type') as user_type
FROM DUAL;

-- Academic Affairs should see all students
PROMPT Testing STUDENTS table access (all)...
SELECT COUNT(*) as total_students FROM STUDENTS;

PROMPT Should see: All 5 students
PROMPT ----------------------------------------

-- Academic Affairs should see all grades
PROMPT Testing GRADES table access (all)...
SELECT COUNT(*) as total_grades FROM GRADES;

PROMPT Should see: All 7 grade records
PROMPT ----------------------------------------

PROMPT ========================================
PROMPT TEST 6: Verify VPD is working - Count test
PROMPT ========================================

-- Reset to student context
BEGIN
    gms_security_pkg.set_user_context('STU001', 'Student');
END;
/

SELECT 'As Student STU001' as context, COUNT(*) as visible_students FROM STUDENTS;

-- Switch to academic affairs
BEGIN
    gms_security_pkg.set_user_context('ACAD001', 'Academic_Affairs');
END;
/

SELECT 'As Academic Affairs' as context, COUNT(*) as visible_students FROM STUDENTS;

PROMPT If VPD is working correctly:
PROMPT - Student should see 1 student (themselves)
PROMPT - Academic Affairs should see all 5 students
PROMPT ========================================

-- Clear context
BEGIN
    gms_security_pkg.clear_user_context();
END;
/

PROMPT ========================================
PROMPT VPD Policy Testing Complete!
PROMPT ========================================
