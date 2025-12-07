-- =============================================
-- UNIVERSITY GRADE MANAGEMENT SYSTEM
-- Sample Data Loading Script
-- =============================================

ALTER SESSION SET CONTAINER = ORCLPDB;
ALTER SESSION SET CURRENT_SCHEMA = GMS_ADMIN;

SET FEEDBACK ON
SET ECHO ON

-- =============================================
-- 1. FACULTIES DATA
-- =============================================
PROMPT Inserting Faculties...

INSERT INTO FACULTIES (faculty_id, faculty_name, established_date, description)
VALUES ('FAC001', 'Faculty of Computer Science and Engineering', DATE '2000-01-15', 'Leading faculty in CS and IT education');

INSERT INTO FACULTIES (faculty_id, faculty_name, established_date, description)
VALUES ('FAC002', 'Faculty of Electrical and Electronics Engineering', DATE '1995-09-01', 'Excellence in EE education and research');

INSERT INTO FACULTIES (faculty_id, faculty_name, established_date, description)
VALUES ('FAC003', 'Faculty of Mechanical Engineering', DATE '1990-06-20', 'Pioneer in mechanical engineering');

-- =============================================
-- 2. DEPARTMENTS DATA
-- =============================================
PROMPT Inserting Departments...

INSERT INTO DEPARTMENTS (department_id, department_name, faculty_id, established_date, description)
VALUES ('DEPT001', 'Computer Science', 'FAC001', DATE '2000-01-15', 'Core CS programs');

INSERT INTO DEPARTMENTS (department_id, department_name, faculty_id, established_date, description)
VALUES ('DEPT002', 'Software Engineering', 'FAC001', DATE '2005-09-01', 'Software development focus');

INSERT INTO DEPARTMENTS (department_id, department_name, faculty_id, established_date, description)
VALUES ('DEPT003', 'Electrical Engineering', 'FAC002', DATE '1995-09-01', 'Power and control systems');

INSERT INTO DEPARTMENTS (department_id, department_name, faculty_id, established_date, description)
VALUES ('DEPT004', 'Mechanical Design', 'FAC003', DATE '1990-06-20', 'Machine design and manufacturing');

-- =============================================
-- 3. LECTURERS DATA
-- =============================================
PROMPT Inserting Lecturers...

INSERT INTO LECTURERS (lecturer_id, first_name, last_name, date_of_birth, gender, email, phone_number, department_id, start_date, academic_degree, specialization, lecturer_status)
VALUES ('LEC001', 'Nguyen', 'Van An', DATE '1980-05-15', 'Male', 'nv.an@university.edu.vn', '0901234567', 'DEPT001', DATE '2010-09-01', 'PhD', 'Database Systems', 'Active');

INSERT INTO LECTURERS (lecturer_id, first_name, last_name, date_of_birth, gender, email, phone_number, department_id, start_date, academic_degree, specialization, lecturer_status)
VALUES ('LEC002', 'Tran', 'Thi Binh', DATE '1985-08-20', 'Female', 'tt.binh@university.edu.vn', '0901234568', 'DEPT001', DATE '2012-09-01', 'PhD', 'Algorithms', 'Active');

INSERT INTO LECTURERS (lecturer_id, first_name, last_name, date_of_birth, gender, email, phone_number, department_id, start_date, academic_degree, specialization, lecturer_status)
VALUES ('LEC003', 'Le', 'Van Cuong', DATE '1982-03-10', 'Male', 'lv.cuong@university.edu.vn', '0901234569', 'DEPT002', DATE '2011-09-01', 'PhD', 'Software Architecture', 'Active');

INSERT INTO LECTURERS (lecturer_id, first_name, last_name, date_of_birth, gender, email, phone_number, department_id, start_date, academic_degree, specialization, lecturer_status)
VALUES ('LEC004', 'Pham', 'Thi Dung', DATE '1978-12-05', 'Female', 'pt.dung@university.edu.vn', '0901234570', 'DEPT003', DATE '2008-09-01', 'PhD', 'Control Systems', 'Active');

INSERT INTO LECTURERS (lecturer_id, first_name, last_name, date_of_birth, gender, email, phone_number, department_id, start_date, academic_degree, specialization, lecturer_status)
VALUES ('LEC005', 'Hoang', 'Van Em', DATE '1983-07-18', 'Male', 'hv.em@university.edu.vn', '0901234571', 'DEPT004', DATE '2013-09-01', 'PhD', 'Mechanical Design', 'Active');

-- Update Faculty deans
UPDATE FACULTIES SET dean_id = 'LEC001' WHERE faculty_id = 'FAC001';
UPDATE FACULTIES SET dean_id = 'LEC004' WHERE faculty_id = 'FAC002';
UPDATE FACULTIES SET dean_id = 'LEC005' WHERE faculty_id = 'FAC003';

-- Update Department heads
UPDATE DEPARTMENTS SET department_head_id = 'LEC001' WHERE department_id = 'DEPT001';
UPDATE DEPARTMENTS SET department_head_id = 'LEC003' WHERE department_id = 'DEPT002';
UPDATE DEPARTMENTS SET department_head_id = 'LEC004' WHERE department_id = 'DEPT003';
UPDATE DEPARTMENTS SET department_head_id = 'LEC005' WHERE department_id = 'DEPT004';

-- =============================================
-- 4. CLASSES DATA
-- =============================================
PROMPT Inserting Classes...

INSERT INTO CLASSES (class_id, class_name, faculty_id, academic_year, homeroom_teacher_id, total_students)
VALUES ('CLS001', 'CS2021A', 'FAC001', 2021, 'LEC001', 0);

INSERT INTO CLASSES (class_id, class_name, faculty_id, academic_year, homeroom_teacher_id, total_students)
VALUES ('CLS002', 'CS2021B', 'FAC001', 2021, 'LEC002', 0);

INSERT INTO CLASSES (class_id, class_name, faculty_id, academic_year, homeroom_teacher_id, total_students)
VALUES ('CLS003', 'SE2021A', 'FAC001', 2021, 'LEC003', 0);

INSERT INTO CLASSES (class_id, class_name, faculty_id, academic_year, homeroom_teacher_id, total_students)
VALUES ('CLS004', 'EE2021A', 'FAC002', 2021, 'LEC004', 0);

-- =============================================
-- 5. STUDENTS DATA
-- =============================================
PROMPT Inserting Students...

INSERT INTO STUDENTS (student_id, first_name, last_name, date_of_birth, gender, email, phone_number, hometown, class_id, enrollment_date, student_status)
VALUES ('STU001', 'Nguyen', 'Van Hai', DATE '2003-01-15', 'Male', 'nvhai@student.edu.vn', '0912345678', 'Ho Chi Minh', 'CLS001', DATE '2021-09-01', 'Active');

INSERT INTO STUDENTS (student_id, first_name, last_name, date_of_birth, gender, email, phone_number, hometown, class_id, enrollment_date, student_status)
VALUES ('STU002', 'Tran', 'Thi Hoa', DATE '2003-05-20', 'Female', 'tthoa@student.edu.vn', '0912345679', 'Ha Noi', 'CLS001', DATE '2021-09-01', 'Active');

INSERT INTO STUDENTS (student_id, first_name, last_name, date_of_birth, gender, email, phone_number, hometown, class_id, enrollment_date, student_status)
VALUES ('STU003', 'Le', 'Van Khanh', DATE '2003-03-10', 'Male', 'lvkhanh@student.edu.vn', '0912345680', 'Da Nang', 'CLS002', DATE '2021-09-01', 'Active');

INSERT INTO STUDENTS (student_id, first_name, last_name, date_of_birth, gender, email, phone_number, hometown, class_id, enrollment_date, student_status)
VALUES ('STU004', 'Pham', 'Thi Lan', DATE '2003-08-25', 'Female', 'ptlan@student.edu.vn', '0912345681', 'Can Tho', 'CLS003', DATE '2021-09-01', 'Active');

INSERT INTO STUDENTS (student_id, first_name, last_name, date_of_birth, gender, email, phone_number, hometown, class_id, enrollment_date, student_status)
VALUES ('STU005', 'Hoang', 'Van Minh', DATE '2003-11-30', 'Male', 'hvminh@student.edu.vn', '0912345682', 'Hai Phong', 'CLS004', DATE '2021-09-01', 'Active');

-- Update class student counts
UPDATE CLASSES SET total_students = 2 WHERE class_id = 'CLS001';
UPDATE CLASSES SET total_students = 1 WHERE class_id = 'CLS002';
UPDATE CLASSES SET total_students = 1 WHERE class_id = 'CLS003';
UPDATE CLASSES SET total_students = 1 WHERE class_id = 'CLS004';

-- =============================================
-- 6. RELATIVES DATA
-- =============================================
PROMPT Inserting Relatives...

INSERT INTO RELATIVES (relative_id, first_name, last_name, date_of_birth, gender, phone_number, occupation, email)
VALUES ('REL001', 'Nguyen', 'Van Hung', DATE '1975-03-15', 'Male', '0987654321', 'Engineer', 'nvhung@email.com');

INSERT INTO RELATIVES (relative_id, first_name, last_name, date_of_birth, gender, phone_number, occupation, email)
VALUES ('REL002', 'Tran', 'Thi Mai', DATE '1978-07-20', 'Female', '0987654322', 'Teacher', 'ttmai@email.com');

INSERT INTO RELATIVES (relative_id, first_name, last_name, date_of_birth, gender, phone_number, occupation, email)
VALUES ('REL003', 'Le', 'Van Nam', DATE '1973-02-10', 'Male', '0987654323', 'Doctor', 'lvnam@email.com');

-- =============================================
-- 7. STUDENT_RELATIVES DATA
-- =============================================
PROMPT Inserting Student-Relative relationships...

INSERT INTO STUDENT_RELATIVES (student_id, relative_id, relationship, is_primary_contact)
VALUES ('STU001', 'REL001', 'Father', 'Y');

INSERT INTO STUDENT_RELATIVES (student_id, relative_id, relationship, is_primary_contact)
VALUES ('STU002', 'REL002', 'Mother', 'Y');

INSERT INTO STUDENT_RELATIVES (student_id, relative_id, relationship, is_primary_contact)
VALUES ('STU003', 'REL003', 'Father', 'Y');

-- =============================================
-- 8. COURSES DATA
-- =============================================
PROMPT Inserting Courses...

INSERT INTO COURSES (course_id, course_name, credits, department_id, course_type, description)
VALUES ('CSE101', 'Introduction to Computer Science', 3, 'DEPT001', 'Mandatory', 'Basic CS concepts and programming');

INSERT INTO COURSES (course_id, course_name, credits, department_id, course_type, prerequisite_course_id, description)
VALUES ('CSE201', 'Data Structures and Algorithms', 4, 'DEPT001', 'Mandatory', 'CSE101', 'Advanced data structures');

INSERT INTO COURSES (course_id, course_name, credits, department_id, course_type, prerequisite_course_id, description)
VALUES ('CSE301', 'Database Systems', 3, 'DEPT001', 'Mandatory', 'CSE201', 'Relational databases and SQL');

INSERT INTO COURSES (course_id, course_name, credits, department_id, course_type, description)
VALUES ('CSE401', 'Machine Learning', 3, 'DEPT001', 'Elective', 'Introduction to ML algorithms');

INSERT INTO COURSES (course_id, course_name, credits, department_id, course_type, description)
VALUES ('SWE201', 'Software Engineering', 3, 'DEPT002', 'Mandatory', 'Software development lifecycle');

INSERT INTO COURSES (course_id, course_name, credits, department_id, course_type, description)
VALUES ('EEE201', 'Circuit Analysis', 4, 'DEPT003', 'Mandatory', 'Electrical circuit theory');

-- =============================================
-- 9. COURSE_SECTIONS DATA
-- =============================================
PROMPT Inserting Course Sections...

INSERT INTO COURSE_SECTIONS (section_id, course_id, lecturer_id, semester, academic_year, max_students, enrolled_students, classroom, schedule, section_status)
VALUES ('SEC001-HK1', 'CSE101', 'LEC001', 'HK1', 2024, 50, 0, 'H1-101', 'Mon 08:00-10:00', 'Open');

INSERT INTO COURSE_SECTIONS (section_id, course_id, lecturer_id, semester, academic_year, max_students, enrolled_students, classroom, schedule, section_status)
VALUES ('SEC002-HK1', 'CSE201', 'LEC002', 'HK1', 2024, 50, 0, 'H1-102', 'Wed 08:00-10:00', 'Open');

INSERT INTO COURSE_SECTIONS (section_id, course_id, lecturer_id, semester, academic_year, max_students, enrolled_students, classroom, schedule, section_status)
VALUES ('SEC003-HK1', 'CSE301', 'LEC001', 'HK1', 2024, 45, 0, 'H1-103', 'Fri 08:00-10:00', 'Open');

INSERT INTO COURSE_SECTIONS (section_id, course_id, lecturer_id, semester, academic_year, max_students, enrolled_students, classroom, schedule, section_status)
VALUES ('SEC004-HK1', 'SWE201', 'LEC003', 'HK1', 2024, 40, 0, 'H2-201', 'Tue 14:00-16:00', 'Open');

INSERT INTO COURSE_SECTIONS (section_id, course_id, lecturer_id, semester, academic_year, max_students, enrolled_students, classroom, schedule, section_status)
VALUES ('SEC005-HK1', 'EEE201', 'LEC004', 'HK1', 2024, 50, 0, 'H3-301', 'Thu 08:00-10:00', 'Open');

-- =============================================
-- 10. ENROLLMENTS DATA
-- =============================================
PROMPT Inserting Enrollments...

-- Student STU001 enrollments
INSERT INTO ENROLLMENTS (student_id, section_id, enrollment_date, enrollment_status)
VALUES ('STU001', 'SEC001-HK1', DATE '2024-08-01', 'Enrolled');

INSERT INTO ENROLLMENTS (student_id, section_id, enrollment_date, enrollment_status)
VALUES ('STU001', 'SEC002-HK1', DATE '2024-08-01', 'Enrolled');

INSERT INTO ENROLLMENTS (student_id, section_id, enrollment_date, enrollment_status)
VALUES ('STU001', 'SEC003-HK1', DATE '2024-08-01', 'Enrolled');

-- Student STU002 enrollments
INSERT INTO ENROLLMENTS (student_id, section_id, enrollment_date, enrollment_status)
VALUES ('STU002', 'SEC001-HK1', DATE '2024-08-01', 'Enrolled');

INSERT INTO ENROLLMENTS (student_id, section_id, enrollment_date, enrollment_status)
VALUES ('STU002', 'SEC002-HK1', DATE '2024-08-01', 'Enrolled');

-- Student STU003 enrollments
INSERT INTO ENROLLMENTS (student_id, section_id, enrollment_date, enrollment_status)
VALUES ('STU003', 'SEC001-HK1', DATE '2024-08-01', 'Enrolled');

INSERT INTO ENROLLMENTS (student_id, section_id, enrollment_date, enrollment_status)
VALUES ('STU003', 'SEC004-HK1', DATE '2024-08-01', 'Enrolled');

-- Student STU004 enrollments
INSERT INTO ENROLLMENTS (student_id, section_id, enrollment_date, enrollment_status)
VALUES ('STU004', 'SEC004-HK1', DATE '2024-08-01', 'Enrolled');

-- Student STU005 enrollments
INSERT INTO ENROLLMENTS (student_id, section_id, enrollment_date, enrollment_status)
VALUES ('STU005', 'SEC005-HK1', DATE '2024-08-01', 'Enrolled');

-- Update enrolled student counts
UPDATE COURSE_SECTIONS SET enrolled_students = 3 WHERE section_id = 'SEC001-HK1';
UPDATE COURSE_SECTIONS SET enrolled_students = 2 WHERE section_id = 'SEC002-HK1';
UPDATE COURSE_SECTIONS SET enrolled_students = 1 WHERE section_id = 'SEC003-HK1';
UPDATE COURSE_SECTIONS SET enrolled_students = 2 WHERE section_id = 'SEC004-HK1';
UPDATE COURSE_SECTIONS SET enrolled_students = 1 WHERE section_id = 'SEC005-HK1';

-- =============================================
-- 11. GRADES DATA
-- =============================================
PROMPT Inserting Grades...

-- Grades for STU001
INSERT INTO GRADES (enrollment_id, midterm_score, final_score, total_score, letter_grade, grade_status, submitted_by, submitted_date)
VALUES (1, 8.5, 9.0, 8.8, 'A', 'Approved', 'LEC001', SYSDATE - 10);

INSERT INTO GRADES (enrollment_id, midterm_score, final_score, total_score, letter_grade, grade_status, submitted_by, submitted_date)
VALUES (2, 7.5, 8.0, 7.8, 'B', 'Approved', 'LEC002', SYSDATE - 10);

INSERT INTO GRADES (enrollment_id, midterm_score, final_score, total_score, letter_grade, grade_status, submitted_by, submitted_date)
VALUES (3, 9.0, 9.5, 9.3, 'A', 'Approved', 'LEC001', SYSDATE - 10);

-- Grades for STU002
INSERT INTO GRADES (enrollment_id, midterm_score, final_score, total_score, letter_grade, grade_status, submitted_by, submitted_date)
VALUES (4, 6.5, 7.0, 6.8, 'C', 'Approved', 'LEC001', SYSDATE - 10);

INSERT INTO GRADES (enrollment_id, midterm_score, final_score, total_score, letter_grade, grade_status, submitted_by, submitted_date)
VALUES (5, 8.0, 8.5, 8.3, 'A', 'Approved', 'LEC002', SYSDATE - 10);

-- Grades for STU003
INSERT INTO GRADES (enrollment_id, midterm_score, final_score, total_score, letter_grade, grade_status, submitted_by, submitted_date)
VALUES (6, 7.0, 7.5, 7.3, 'B', 'Submitted', 'LEC001', SYSDATE - 5);

INSERT INTO GRADES (enrollment_id, midterm_score, final_score, total_score, letter_grade, grade_status, submitted_by, submitted_date)
VALUES (7, 8.5, 9.0, 8.8, 'A', 'Submitted', 'LEC003', SYSDATE - 5);

-- =============================================
-- 12. GRADE SUBMISSION DEADLINES
-- =============================================
PROMPT Inserting Grade Submission Deadlines...

INSERT INTO GRADE_SUBMISSION_DEADLINES (semester, academic_year, submission_deadline, is_active, created_by)
VALUES ('HK1', 2024, DATE '2024-12-31', 'Y', 'GMS_ADMIN');

INSERT INTO GRADE_SUBMISSION_DEADLINES (semester, academic_year, submission_deadline, is_active, created_by)
VALUES ('HK2', 2024, DATE '2025-05-31', 'N', 'GMS_ADMIN');

INSERT INTO GRADE_SUBMISSION_DEADLINES (semester, academic_year, submission_deadline, is_active, created_by)
VALUES ('HK3', 2024, DATE '2025-08-31', 'N', 'GMS_ADMIN');

-- =============================================
-- 13. SYSTEM USERS DATA
-- =============================================
PROMPT Inserting System Users...

-- Admin user
INSERT INTO SYSTEM_USERS (user_id, username, password_hash, user_type, reference_id, is_active)
VALUES ('USR001', 'admin', 'hashed_password_admin', 'Admin', 'GMS_ADMIN', 'Y');

-- Student users
INSERT INTO SYSTEM_USERS (user_id, username, password_hash, user_type, reference_id, is_active)
VALUES ('USR002', 'nvhai', 'hashed_password_stu001', 'Student', 'STU001', 'Y');

INSERT INTO SYSTEM_USERS (user_id, username, password_hash, user_type, reference_id, is_active)
VALUES ('USR003', 'tthoa', 'hashed_password_stu002', 'Student', 'STU002', 'Y');

-- Lecturer users
INSERT INTO SYSTEM_USERS (user_id, username, password_hash, user_type, reference_id, is_active)
VALUES ('USR004', 'nv.an', 'hashed_password_lec001', 'Lecturer', 'LEC001', 'Y');

INSERT INTO SYSTEM_USERS (user_id, username, password_hash, user_type, reference_id, is_active)
VALUES ('USR005', 'tt.binh', 'hashed_password_lec002', 'Lecturer', 'LEC002', 'Y');

-- Relative users
INSERT INTO SYSTEM_USERS (user_id, username, password_hash, user_type, reference_id, is_active)
VALUES ('USR006', 'nvhung', 'hashed_password_rel001', 'Relative', 'REL001', 'Y');

-- Academic Affairs user
INSERT INTO SYSTEM_USERS (user_id, username, password_hash, user_type, reference_id, is_active)
VALUES ('USR007', 'academic', 'hashed_password_academic', 'Academic_Affairs', 'ACAD001', 'Y');

-- Dean user
INSERT INTO SYSTEM_USERS (user_id, username, password_hash, user_type, reference_id, is_active)
VALUES ('USR008', 'dean', 'hashed_password_dean', 'Dean', 'LEC001', 'Y');

COMMIT;

-- =============================================
-- Display Summary
-- =============================================
PROMPT ========================================
PROMPT Sample Data Summary:
PROMPT ========================================

SELECT 'FACULTIES' as TABLE_NAME, COUNT(*) as RECORDS FROM FACULTIES
UNION ALL
SELECT 'DEPARTMENTS', COUNT(*) FROM DEPARTMENTS
UNION ALL
SELECT 'LECTURERS', COUNT(*) FROM LECTURERS
UNION ALL
SELECT 'CLASSES', COUNT(*) FROM CLASSES
UNION ALL
SELECT 'STUDENTS', COUNT(*) FROM STUDENTS
UNION ALL
SELECT 'RELATIVES', COUNT(*) FROM RELATIVES
UNION ALL
SELECT 'STUDENT_RELATIVES', COUNT(*) FROM STUDENT_RELATIVES
UNION ALL
SELECT 'COURSES', COUNT(*) FROM COURSES
UNION ALL
SELECT 'COURSE_SECTIONS', COUNT(*) FROM COURSE_SECTIONS
UNION ALL
SELECT 'ENROLLMENTS', COUNT(*) FROM ENROLLMENTS
UNION ALL
SELECT 'GRADES', COUNT(*) FROM GRADES
UNION ALL
SELECT 'GRADE_SUBMISSION_DEADLINES', COUNT(*) FROM GRADE_SUBMISSION_DEADLINES
UNION ALL
SELECT 'SYSTEM_USERS', COUNT(*) FROM SYSTEM_USERS
ORDER BY 1;

PROMPT ========================================
PROMPT Sample data loaded successfully!
PROMPT ========================================
