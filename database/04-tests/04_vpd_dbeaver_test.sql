/*******************************************************************************
 * File: 04_vpd_dbeaver_test.sql
 * Purpose: VPD Policy Testing via DBeaver (or SQL*Plus)
 *
 * This script is designed to be run in DBeaver with different user connections
 * to test Virtual Private Database (VPD) row-level security policies.
 *
 * PREREQUISITES:
 *   1. Run 00_grant_test_privileges.sql first (as SYSDBA)
 *   2. Create DBeaver connections for test users
 *
 * HOW TO USE IN DBEAVER:
 *   1. Create new connection: GMS_STUDENT / Student@2024
 *   2. Open this SQL file
 *   3. Run the "TEST 1: STUDENT ACCESS" section
 *   4. Disconnect and create new connection: GMS_LECTURER / Lecturer@2024
 *   5. Run the "TEST 2: LECTURER ACCESS" section
 *   6. Repeat for other users
 *
 * HOW TO USE IN SQL*PLUS:
 *   sqlplus GMS_STUDENT@ORCLPDB
 *   Enter password: Student@2024
 *   @e:\Desktop\HCMUT\baomat\grade-management-system\database\04-tests\04_vpd_dbeaver_test.sql
 *******************************************************************************/

SET SERVEROUTPUT ON
SET LINESIZE 200
SET PAGESIZE 100
COLUMN student_id FORMAT A10
COLUMN first_name FORMAT A15
COLUMN last_name FORMAT A15
COLUMN grade_id FORMAT A10
COLUMN total_score FORMAT 999.99
COLUMN letter_grade FORMAT A5
COLUMN current_user FORMAT A20
COLUMN user_id FORMAT A10
COLUMN user_type FORMAT A15

/*******************************************************************************
 * TEST 1: STUDENT ACCESS (GMS_STUDENT)
 *
 * Connection: GMS_STUDENT / Student@2024
 * Expected behavior:
 *   - See only STU001's own record in STUDENTS table
 *   - See only STU001's grades in GRADES table
 *   - VPD policy filters data automatically
 *******************************************************************************/

PROMPT ===============================================================================
PROMPT TEST 1: STUDENT ACCESS (Run this as GMS_STUDENT)
PROMPT ===============================================================================

-- Check current user
PROMPT
PROMPT === Current database user ===
SELECT USER as current_user FROM DUAL;

-- Set security context for STU001
PROMPT
PROMPT === Setting security context for Student STU001 ===
EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');

-- Verify context
PROMPT
PROMPT === Verifying security context ===
SELECT SYS_CONTEXT('gms_context', 'user_id') as user_id,
       SYS_CONTEXT('gms_context', 'user_type') as user_type
FROM DUAL;

-- Query STUDENTS table
PROMPT
PROMPT === Query STUDENTS table (should see only STU001) ===
SELECT student_id, first_name, last_name, email
FROM gms_admin.STUDENTS
ORDER BY student_id;

PROMPT
PROMPT Expected: 1 row (STU001 - Nguyen Van A)
PROMPT

-- Count students
SELECT COUNT(*) as "Total Students Visible" FROM gms_admin.STUDENTS;

-- Query GRADES table
PROMPT
PROMPT === Query GRADES table (should see only STU001's grades) ===
SELECT g.grade_id, e.student_id, c.course_name,
       g.midterm_score, g.final_score, g.total_score, g.letter_grade
FROM gms_admin.GRADES g
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN gms_admin.COURSES c ON cs.course_id = c.course_id
ORDER BY g.grade_id;

PROMPT
PROMPT Expected: 3 rows (STU001's grades in CSE101, CSE201, CSE301)
PROMPT

-- Count grades
SELECT COUNT(*) as "Total Grades Visible" FROM gms_admin.GRADES;

PROMPT
PROMPT === TEST 1 COMPLETE ===
PROMPT If you see only 1 student and 3 grades, VPD policy is working correctly!
PROMPT ===============================================================================


/*******************************************************************************
 * TEST 2: LECTURER ACCESS (GMS_LECTURER)
 *
 * Connection: GMS_LECTURER / Lecturer@2024
 * Expected behavior:
 *   - See only students in courses they teach
 *   - See only grades for their course sections
 *   - VPD policy filters based on lecturer_id
 *******************************************************************************/

PROMPT
PROMPT
PROMPT ===============================================================================
PROMPT TEST 2: LECTURER ACCESS (Run this as GMS_LECTURER)
PROMPT ===============================================================================

-- Check current user
PROMPT
PROMPT === Current database user ===
SELECT USER as current_user FROM DUAL;

-- Set security context for LEC001
PROMPT
PROMPT === Setting security context for Lecturer LEC001 ===
EXEC gms_admin.gms_security_pkg.set_user_context('LEC001', 'Lecturer');

-- Verify context
PROMPT
PROMPT === Verifying security context ===
SELECT SYS_CONTEXT('gms_context', 'user_id') as user_id,
       SYS_CONTEXT('gms_context', 'user_type') as user_type
FROM DUAL;

-- Query which courses this lecturer teaches
PROMPT
PROMPT === Courses taught by LEC001 ===
SELECT cs.section_id, c.course_id, c.course_name, cs.semester, cs.year
FROM gms_admin.COURSE_SECTIONS cs
JOIN gms_admin.COURSES c ON cs.course_id = c.course_id
WHERE cs.lecturer_id = 'LEC001'
ORDER BY cs.section_id;

-- Query STUDENTS in lecturer's classes
PROMPT
PROMPT === Students in LEC001's classes ===
SELECT DISTINCT s.student_id, s.first_name, s.last_name, s.email
FROM gms_admin.STUDENTS s
JOIN gms_admin.ENROLLMENTS e ON s.student_id = e.student_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
WHERE cs.lecturer_id = 'LEC001'
ORDER BY s.student_id;

PROMPT
PROMPT Expected: Students enrolled in LEC001's course sections
PROMPT

-- Count students visible
SELECT COUNT(DISTINCT s.student_id) as "Students in My Classes"
FROM gms_admin.STUDENTS s
JOIN gms_admin.ENROLLMENTS e ON s.student_id = e.student_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
WHERE cs.lecturer_id = 'LEC001';

-- Query GRADES for lecturer's courses
PROMPT
PROMPT === Grades in LEC001's course sections ===
SELECT g.grade_id, e.student_id, c.course_name,
       g.midterm_score, g.final_score, g.total_score, g.letter_grade
FROM gms_admin.GRADES g
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN gms_admin.COURSES c ON cs.course_id = c.course_id
ORDER BY g.grade_id;

PROMPT
PROMPT Expected: Only grades for course sections taught by LEC001
PROMPT

-- Count grades visible
SELECT COUNT(*) as "Grades in My Sections" FROM gms_admin.GRADES;

PROMPT
PROMPT === TEST 2 COMPLETE ===
PROMPT VPD policy should limit visibility to only your course sections!
PROMPT ===============================================================================


/*******************************************************************************
 * TEST 3: RELATIVE ACCESS (GMS_RELATIVE)
 *
 * Connection: GMS_RELATIVE / Relative@2024
 * Expected behavior:
 *   - See only their children's grades
 *   - VPD policy filters based on relative_id
 *******************************************************************************/

PROMPT
PROMPT
PROMPT ===============================================================================
PROMPT TEST 3: RELATIVE ACCESS (Run this as GMS_RELATIVE)
PROMPT ===============================================================================

-- Check current user
PROMPT
PROMPT === Current database user ===
SELECT USER as current_user FROM DUAL;

-- Set security context for REL001
PROMPT
PROMPT === Setting security context for Relative REL001 ===
EXEC gms_admin.gms_security_pkg.set_user_context('REL001', 'Relative');

-- Verify context
PROMPT
PROMPT === Verifying security context ===
SELECT SYS_CONTEXT('gms_context', 'user_id') as user_id,
       SYS_CONTEXT('gms_context', 'user_type') as user_type
FROM DUAL;

-- Query which students are their children
PROMPT
PROMPT === My children (students) ===
SELECT s.student_id, s.first_name, s.last_name, sr.relationship
FROM gms_admin.STUDENT_RELATIVES sr
JOIN gms_admin.STUDENTS s ON sr.student_id = s.student_id
WHERE sr.relative_id = 'REL001'
ORDER BY s.student_id;

PROMPT
PROMPT Expected: Students linked to REL001 via STUDENT_RELATIVES table
PROMPT

-- Query GRADES for their children
PROMPT
PROMPT === Grades for my children ===
SELECT g.grade_id, e.student_id, c.course_name,
       g.midterm_score, g.final_score, g.total_score, g.letter_grade
FROM gms_admin.GRADES g
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN gms_admin.COURSES c ON cs.course_id = c.course_id
ORDER BY e.student_id, g.grade_id;

PROMPT
PROMPT Expected: Only grades for students linked to REL001
PROMPT

-- Count grades visible
SELECT COUNT(*) as "Total Grades Visible" FROM gms_admin.GRADES;

PROMPT
PROMPT === TEST 3 COMPLETE ===
PROMPT VPD policy should limit visibility to only your children's grades!
PROMPT ===============================================================================


/*******************************************************************************
 * TEST 4: DEAN ACCESS (GMS_DEAN)
 *
 * Connection: GMS_DEAN / Dean@2024
 * Expected behavior:
 *   - See all students in their faculty
 *   - See all grades for faculty students
 *   - VPD policy filters based on faculty_id
 *******************************************************************************/

PROMPT
PROMPT
PROMPT ===============================================================================
PROMPT TEST 4: DEAN ACCESS (Run this as GMS_DEAN)
PROMPT ===============================================================================

-- Check current user
PROMPT
PROMPT === Current database user ===
SELECT USER as current_user FROM DUAL;

-- Set security context for LEC001 as Dean of FAC001
PROMPT
PROMPT === Setting security context for Dean (LEC001 of FAC001) ===
EXEC gms_admin.gms_security_pkg.set_user_context('LEC001', 'Dean');

-- Verify context
PROMPT
PROMPT === Verifying security context ===
SELECT SYS_CONTEXT('gms_context', 'user_id') as user_id,
       SYS_CONTEXT('gms_context', 'user_type') as user_type
FROM DUAL;

-- Query students in their faculty
PROMPT
PROMPT === Students in Faculty FAC001 ===
SELECT s.student_id, s.first_name, s.last_name, c.class_name, d.department_name
FROM gms_admin.STUDENTS s
JOIN gms_admin.CLASSES c ON s.class_id = c.class_id
JOIN gms_admin.DEPARTMENTS d ON c.department_id = d.department_id
WHERE d.faculty_id = 'FAC001'
ORDER BY s.student_id;

PROMPT
PROMPT Expected: All students from departments in FAC001
PROMPT

-- Count students visible
SELECT COUNT(*) as "Students in Faculty" FROM gms_admin.STUDENTS;

-- Query grades for faculty students
PROMPT
PROMPT === Grades for Faculty FAC001 students ===
SELECT g.grade_id, e.student_id, c.course_name, g.total_score, g.letter_grade
FROM gms_admin.GRADES g
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN gms_admin.COURSES c ON cs.course_id = c.course_id
ORDER BY e.student_id, g.grade_id;

PROMPT
PROMPT Expected: All grades for students in FAC001
PROMPT

-- Count grades visible
SELECT COUNT(*) as "Grades in Faculty" FROM gms_admin.GRADES;

PROMPT
PROMPT === TEST 4 COMPLETE ===
PROMPT VPD policy should show all students/grades in your faculty!
PROMPT ===============================================================================


/*******************************************************************************
 * SUMMARY
 *******************************************************************************/

PROMPT
PROMPT
PROMPT ===============================================================================
PROMPT VPD TESTING SUMMARY
PROMPT ===============================================================================
PROMPT
PROMPT You have completed VPD policy testing for the Grade Management System.
PROMPT
PROMPT Key Observations:
PROMPT   1. Student (GMS_STUDENT): Can only see their own data
PROMPT   2. Lecturer (GMS_LECTURER): Can only see students/grades in their sections
PROMPT   3. Relative (GMS_RELATIVE): Can only see their children's grades
PROMPT   4. Dean (GMS_DEAN): Can see all students/grades in their faculty
PROMPT
PROMPT VPD Policies Tested:
PROMPT   - student_access_policy (STUDENTS table)
PROMPT   - grade_student_policy (GRADES table for students)
PROMPT   - grade_lecturer_policy (GRADES table for lecturers)
PROMPT   - grade_relative_policy (GRADES table for relatives)
PROMPT   - relative_access_policy (RELATIVES table)
PROMPT   - student_relative_policy (STUDENT_RELATIVES table)
PROMPT
PROMPT All policies should automatically filter data based on security context!
PROMPT ===============================================================================

exit;
