-- =============================================
-- UNIVERSITY GRADE MANAGEMENT SYSTEM
-- Schema Creation Script (FIXED VERSION)
-- Removes ORA-01408 errors by removing redundant indexes
-- =============================================

ALTER SESSION SET CONTAINER = ORCLPDB;
ALTER SESSION SET CURRENT_SCHEMA = GMS_ADMIN;

SET ECHO ON
SET FEEDBACK ON
WHENEVER SQLERROR CONTINUE

-- =============================================
-- 0. CLEANUP (Xóa bảng cũ để chạy lại cho sạch)
-- =============================================
PROMPT Cleaning up old objects...
BEGIN
    -- Drop tables
    FOR t IN (SELECT table_name FROM user_tables) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
    END LOOP;
    
    -- Drop sequences
    FOR s IN (SELECT sequence_name FROM user_sequences) LOOP
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- =============================================
-- 1. CREATE TABLES
-- =============================================

PROMPT Creating FACULTIES table...
CREATE TABLE FACULTIES (
    faculty_id VARCHAR2(10) PRIMARY KEY,
    faculty_name VARCHAR2(100) NOT NULL,
    dean_id VARCHAR2(10),
    established_date DATE,
    description VARCHAR2(500),
    created_date DATE DEFAULT SYSDATE,
    updated_date DATE DEFAULT SYSDATE
);

PROMPT Creating DEPARTMENTS table...
CREATE TABLE DEPARTMENTS (
    department_id VARCHAR2(10) PRIMARY KEY,
    department_name VARCHAR2(100) NOT NULL,
    faculty_id VARCHAR2(10) NOT NULL,
    department_head_id VARCHAR2(10),
    established_date DATE,
    description VARCHAR2(500),
    created_date DATE DEFAULT SYSDATE,
    updated_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_dept_faculty FOREIGN KEY (faculty_id) REFERENCES FACULTIES(faculty_id)
);

PROMPT Creating CLASSES table...
CREATE TABLE CLASSES (
    class_id VARCHAR2(10) PRIMARY KEY,
    class_name VARCHAR2(50) NOT NULL,
    faculty_id VARCHAR2(10) NOT NULL,
    academic_year NUMBER(4) NOT NULL,
    homeroom_teacher_id VARCHAR2(10),
    total_students NUMBER DEFAULT 0,
    created_date DATE DEFAULT SYSDATE,
    updated_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_class_faculty FOREIGN KEY (faculty_id) REFERENCES FACULTIES(faculty_id)
);

PROMPT Creating LECTURERS table...
CREATE TABLE LECTURERS (
    lecturer_id VARCHAR2(10) PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR2(10) CHECK (gender IN ('Male', 'Female', 'Other')),
    hometown VARCHAR2(100),
    email VARCHAR2(100) UNIQUE NOT NULL,
    phone_number VARCHAR2(20),
    contact_address VARCHAR2(200),
    department_id VARCHAR2(10) NOT NULL,
    start_date DATE NOT NULL,
    academic_degree VARCHAR2(50),
    specialization VARCHAR2(100),
    lecturer_status VARCHAR2(20) DEFAULT 'Active' CHECK (lecturer_status IN ('Active', 'Inactive', 'On Leave', 'Retired')),
    created_date DATE DEFAULT SYSDATE,
    updated_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_lecturer_dept FOREIGN KEY (department_id) REFERENCES DEPARTMENTS(department_id)
);

PROMPT Creating STUDENTS table...
CREATE TABLE STUDENTS (
    student_id VARCHAR2(10) PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR2(10) CHECK (gender IN ('Male', 'Female', 'Other')),
    hometown VARCHAR2(100),
    ethnicity VARCHAR2(50),
    religion VARCHAR2(50),
    email VARCHAR2(100) UNIQUE,
    phone_number VARCHAR2(20),
    contact_address VARCHAR2(200),
    class_id VARCHAR2(10) NOT NULL,
    enrollment_date DATE DEFAULT SYSDATE,
    student_status VARCHAR2(20) DEFAULT 'Active' CHECK (student_status IN ('Active', 'Inactive', 'Graduated', 'Suspended')),
    created_date DATE DEFAULT SYSDATE,
    updated_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_student_class FOREIGN KEY (class_id) REFERENCES CLASSES(class_id)
);

PROMPT Creating RELATIVES table...
CREATE TABLE RELATIVES (
    relative_id VARCHAR2(10) PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    date_of_birth DATE,
    gender VARCHAR2(10) CHECK (gender IN ('Male', 'Female', 'Other')),
    contact_address VARCHAR2(200),
    phone_number VARCHAR2(20) NOT NULL,
    occupation VARCHAR2(100),
    email VARCHAR2(100),
    created_date DATE DEFAULT SYSDATE,
    updated_date DATE DEFAULT SYSDATE
);

PROMPT Creating STUDENT_RELATIVES table...
CREATE TABLE STUDENT_RELATIVES (
    student_id VARCHAR2(10) NOT NULL,
    relative_id VARCHAR2(10) NOT NULL,
    relationship VARCHAR2(50) NOT NULL CHECK (relationship IN ('Father', 'Mother', 'Guardian', 'Sibling', 'Other')),
    is_primary_contact VARCHAR2(1) DEFAULT 'N' CHECK (is_primary_contact IN ('Y', 'N')),
    created_date DATE DEFAULT SYSDATE,
    PRIMARY KEY (student_id, relative_id),
    CONSTRAINT fk_sr_student FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id),
    CONSTRAINT fk_sr_relative FOREIGN KEY (relative_id) REFERENCES RELATIVES(relative_id)
);

PROMPT Creating COURSES table...
CREATE TABLE COURSES (
    course_id VARCHAR2(10) PRIMARY KEY,
    course_name VARCHAR2(100) NOT NULL,
    credits NUMBER(2) NOT NULL CHECK (credits > 0 AND credits <= 10),
    department_id VARCHAR2(10) NOT NULL,
    course_type VARCHAR2(20) CHECK (course_type IN ('Mandatory', 'Elective', 'Specialized')),
    prerequisite_course_id VARCHAR2(10),
    description VARCHAR2(500),
    created_date DATE DEFAULT SYSDATE,
    updated_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_course_dept FOREIGN KEY (department_id) REFERENCES DEPARTMENTS(department_id),
    CONSTRAINT fk_course_prerequisite FOREIGN KEY (prerequisite_course_id) REFERENCES COURSES(course_id)
);

PROMPT Creating COURSE_SECTIONS table...
CREATE TABLE COURSE_SECTIONS (
    section_id VARCHAR2(15) PRIMARY KEY,
    course_id VARCHAR2(10) NOT NULL,
    lecturer_id VARCHAR2(10) NOT NULL,
    semester VARCHAR2(10) NOT NULL,
    academic_year NUMBER(4) NOT NULL,
    max_students NUMBER DEFAULT 50,
    enrolled_students NUMBER DEFAULT 0,
    classroom VARCHAR2(20),
    schedule VARCHAR2(100),
    section_status VARCHAR2(20) DEFAULT 'Open' CHECK (section_status IN ('Open', 'Closed', 'Completed', 'Cancelled')),
    created_date DATE DEFAULT SYSDATE,
    updated_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_section_course FOREIGN KEY (course_id) REFERENCES COURSES(course_id),
    CONSTRAINT fk_section_lecturer FOREIGN KEY (lecturer_id) REFERENCES LECTURERS(lecturer_id)
);

PROMPT Creating ENROLLMENTS table...
CREATE TABLE ENROLLMENTS (
    enrollment_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    student_id VARCHAR2(10) NOT NULL,
    section_id VARCHAR2(15) NOT NULL,
    enrollment_date DATE DEFAULT SYSDATE,
    enrollment_status VARCHAR2(20) DEFAULT 'Enrolled' CHECK (enrollment_status IN ('Enrolled', 'Dropped', 'Completed', 'Failed')),
    created_date DATE DEFAULT SYSDATE,
    updated_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_enroll_student FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id),
    CONSTRAINT fk_enroll_section FOREIGN KEY (section_id) REFERENCES COURSE_SECTIONS(section_id),
    CONSTRAINT uk_student_section UNIQUE (student_id, section_id)
);

PROMPT Creating GRADES table...
CREATE TABLE GRADES (
    grade_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    enrollment_id NUMBER NOT NULL,
    midterm_score NUMBER(4,2) CHECK (midterm_score >= 0 AND midterm_score <= 10),
    final_score NUMBER(4,2) CHECK (final_score >= 0 AND final_score <= 10),
    total_score NUMBER(4,2) CHECK (total_score >= 0 AND total_score <= 10),
    letter_grade VARCHAR2(2),
    grade_status VARCHAR2(20) DEFAULT 'Pending' CHECK (grade_status IN ('Pending', 'Submitted', 'Approved', 'Modified')),
    submitted_by VARCHAR2(10),
    submitted_date DATE,
    approved_by VARCHAR2(10),
    approved_date DATE,
    modified_by VARCHAR2(10),
    modified_date DATE,
    modification_reason VARCHAR2(500),
    created_date DATE DEFAULT SYSDATE,
    updated_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_grade_enrollment FOREIGN KEY (enrollment_id) REFERENCES ENROLLMENTS(enrollment_id),
    CONSTRAINT uk_enrollment_grade UNIQUE (enrollment_id)
);

PROMPT Creating GRADE_SUBMISSION_DEADLINES table...
CREATE TABLE GRADE_SUBMISSION_DEADLINES (
    deadline_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    semester VARCHAR2(10) NOT NULL,
    academic_year NUMBER(4) NOT NULL,
    submission_deadline DATE NOT NULL,
    is_active VARCHAR2(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_by VARCHAR2(10),
    created_date DATE DEFAULT SYSDATE,
    updated_date DATE DEFAULT SYSDATE,
    CONSTRAINT uk_semester_year UNIQUE (semester, academic_year)
);

PROMPT Creating SYSTEM_USERS table...
CREATE TABLE SYSTEM_USERS (
    user_id VARCHAR2(10) PRIMARY KEY,
    username VARCHAR2(50) UNIQUE NOT NULL,
    password_hash VARCHAR2(100) NOT NULL,
    user_type VARCHAR2(20) NOT NULL CHECK (user_type IN ('Student', 'Lecturer', 'Academic_Affairs', 'Dean', 'Department_Head', 'Relative', 'Admin')),
    reference_id VARCHAR2(10) NOT NULL,
    is_active VARCHAR2(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    last_login DATE,
    failed_login_attempts NUMBER DEFAULT 0,
    account_locked VARCHAR2(1) DEFAULT 'N' CHECK (account_locked IN ('Y', 'N')),
    password_change_date DATE DEFAULT SYSDATE,
    must_change_password VARCHAR2(1) DEFAULT 'N' CHECK (must_change_password IN ('Y', 'N')),
    created_date DATE DEFAULT SYSDATE,
    updated_date DATE DEFAULT SYSDATE
);

PROMPT Creating AUDIT_LOG table...
CREATE TABLE AUDIT_LOG (
    log_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    table_name VARCHAR2(30) NOT NULL,
    operation VARCHAR2(10) NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE', 'SELECT')),
    user_id VARCHAR2(10),
    username VARCHAR2(50),
    record_id VARCHAR2(50),
    old_values CLOB,
    new_values CLOB,
    operation_date DATE DEFAULT SYSDATE,
    ip_address VARCHAR2(50),
    session_id VARCHAR2(100)
);

PROMPT Adding foreign key constraints...
ALTER TABLE FACULTIES ADD CONSTRAINT fk_faculty_dean FOREIGN KEY (dean_id) REFERENCES LECTURERS(lecturer_id);
ALTER TABLE DEPARTMENTS ADD CONSTRAINT fk_dept_head FOREIGN KEY (department_head_id) REFERENCES LECTURERS(lecturer_id);
ALTER TABLE CLASSES ADD CONSTRAINT fk_class_homeroom FOREIGN KEY (homeroom_teacher_id) REFERENCES LECTURERS(lecturer_id);

-- =============================================
-- 2. CREATE INDEXES
-- =============================================
PROMPT Creating indexes...

-- Index FKs (Good for performance)
CREATE INDEX idx_student_class ON STUDENTS(class_id);
-- REMOVED: idx_student_email (Already UNIQUE)

CREATE INDEX idx_lecturer_dept ON LECTURERS(department_id);
CREATE INDEX idx_course_dept ON COURSES(department_id);
CREATE INDEX idx_section_course ON COURSE_SECTIONS(course_id);
CREATE INDEX idx_section_lecturer ON COURSE_SECTIONS(lecturer_id);
CREATE INDEX idx_section_semester ON COURSE_SECTIONS(semester, academic_year);
CREATE INDEX idx_enrollment_student ON ENROLLMENTS(student_id);
CREATE INDEX idx_enrollment_section ON ENROLLMENTS(section_id);

-- REMOVED: idx_grade_enrollment (Already UNIQUE via uk_enrollment_grade)
-- REMOVED: idx_user_username (Already UNIQUE via username constraint)

CREATE INDEX idx_audit_date ON AUDIT_LOG(operation_date);

-- =============================================
-- 3. CREATE SEQUENCES & VIEWS
-- =============================================
PROMPT Creating sequences...
CREATE SEQUENCE seq_audit_log START WITH 1 INCREMENT BY 1;

PROMPT Creating views...
CREATE OR REPLACE VIEW V_STUDENT_GRADES AS
SELECT
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    c.course_id,
    c.course_name,
    c.credits,
    cs.semester,
    cs.academic_year,
    g.midterm_score,
    g.final_score,
    g.total_score,
    g.letter_grade,
    g.grade_status
FROM STUDENTS s
JOIN ENROLLMENTS e ON s.student_id = e.student_id
JOIN COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN COURSES c ON cs.course_id = c.course_id
LEFT JOIN GRADES g ON e.enrollment_id = g.enrollment_id;

CREATE OR REPLACE VIEW V_STUDENT_GPA AS
SELECT
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    cs.semester,
    cs.academic_year,
    ROUND(SUM(g.total_score * c.credits) / SUM(c.credits), 2) AS semester_gpa,
    ROUND(AVG(g.total_score), 2) AS cumulative_gpa
FROM STUDENTS s
JOIN ENROLLMENTS e ON s.student_id = e.student_id
JOIN COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN COURSES c ON cs.course_id = c.course_id
JOIN GRADES g ON e.enrollment_id = g.enrollment_id
WHERE g.grade_status = 'Approved'
GROUP BY s.student_id, s.first_name, s.last_name, cs.semester, cs.academic_year;

PROMPT Listing all created tables...
SELECT table_name FROM user_tables ORDER BY table_name;

-- =============================================
-- COLUMN-LEVEL SECURITY (Column-level UPDATE permissions)
-- =============================================
PROMPT
PROMPT ========================================
PROMPT Granting Column-level UPDATE permissions
PROMPT ========================================

-- Students can only UPDATE specific columns in their own profile
-- Allowed columns: email, phone_number, contact_address
-- Restricted columns: student_id, first_name, last_name, class_id, enrollment_date, student_status, etc.
PROMPT
PROMPT Granting UPDATE permissions to GMS_STUDENT (column-level)...
GRANT UPDATE (email, phone_number, contact_address) ON gms_admin.STUDENTS TO GMS_STUDENT;

-- Lecturers can only UPDATE specific columns in their own profile
-- Allowed columns: email, phone_number, contact_address
PROMPT
PROMPT Granting UPDATE permissions to GMS_LECTURER (column-level)...
GRANT UPDATE (email, phone_number, contact_address) ON gms_admin.LECTURERS TO GMS_LECTURER;

-- Relatives can only UPDATE specific columns in their own profile
-- Allowed columns: email, phone_number, contact_address
PROMPT
PROMPT Granting UPDATE permissions to GMS_RELATIVE (column-level)...
GRANT UPDATE (email, phone_number, contact_address) ON gms_admin.RELATIVES TO GMS_RELATIVE;

-- Note: VPD policies will ensure users can only update their own records (row-level)
-- Column-level grants ensure users can only update specific columns (column-level)
-- Combined: Users can only update specific columns in their own records

PROMPT
PROMPT Column-level security configured successfully!
PROMPT - Students can UPDATE: email, phone_number, contact_address (in their own record)
PROMPT - Lecturers can UPDATE: email, phone_number, contact_address (in their own record)
PROMPT - Relatives can UPDATE: email, phone_number, contact_address (in their own record)
PROMPT ========================================

COMMIT;
PROMPT ========================================
PROMPT All tables, indexes, sequences, views, and permissions created successfully!
PROMPT ========================================