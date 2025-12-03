-- =====================================================
-- SIMPLE TEST DATA FOR SECURITY DEMO
-- Minimal data to demonstrate VPD, OLS, and Audit
-- =====================================================

CONNECT sys/123@localhost:1521/ORCLPDB AS SYSDBA;

-- =====================================================
-- STEP 1: INSERT TEST STUDENTS
-- =====================================================
-- Student 1: Nguyen Van Hai (STU001)
INSERT INTO GMS_ADMIN.STUDENTS (
    student_id, first_name, last_name, date_of_birth,
    email, phone, major
) VALUES (
    'STU001', 'Hai', 'Nguyen Van', TO_DATE('2003-05-15', 'YYYY-MM-DD'),
    'nvhai@student.edu.vn', '0901234567', 'Computer Science'
);

-- Student 2: Tran Thi Hoa (STU002)
INSERT INTO GMS_ADMIN.STUDENTS (
    student_id, first_name, last_name, date_of_birth,
    email, phone, major
) VALUES (
    'STU002', 'Hoa', 'Tran Thi', TO_DATE('2003-08-20', 'YYYY-MM-DD'),
    'tthoa@student.edu.vn', '0902345678', 'Information Systems'
);

-- Student 3: Le Van Minh (STU003)
INSERT INTO GMS_ADMIN.STUDENTS (
    student_id, first_name, last_name, date_of_birth,
    email, phone, major
) VALUES (
    'STU003', 'Minh', 'Le Van', TO_DATE('2003-03-10', 'YYYY-MM-DD'),
    'lvminh@student.edu.vn', '0903456789', 'Computer Science'
);

PROMPT Students inserted

-- =====================================================
-- STEP 2: INSERT TEST LECTURERS
-- =====================================================
-- Lecturer 1: Dr. Nguyen Thi Mai
INSERT INTO GMS_ADMIN.LECTURERS (
    lecturer_id, first_name, last_name, email,
    phone, department, title
) VALUES (
    'LEC001', 'Mai', 'Nguyen Thi', 'ntmai@university.edu.vn',
    '0911234567', 'Computer Science', 'Associate Professor'
);

-- Lecturer 2: Dr. Tran Van Nam
INSERT INTO GMS_ADMIN.LECTURERS (
    lecturer_id, first_name, last_name, email,
    phone, department, title
) VALUES (
    'LEC002', 'Nam', 'Tran Van', 'tvnam@university.edu.vn',
    '0912345678', 'Mathematics', 'Professor'
);

PROMPT Lecturers inserted

-- =====================================================
-- STEP 3: INSERT TEST COURSES
-- =====================================================
-- Course 1: Database Security (taught by LEC001)
INSERT INTO GMS_ADMIN.COURSES (
    course_id, course_name, course_code, credits,
    semester, year, lecturer_id, description
) VALUES (
    'CRS001', 'Database Security', 'CS301', 3,
    'Fall', 2024, 'LEC001', 'Advanced database security concepts'
);

-- Course 2: Data Structures (taught by LEC001)
INSERT INTO GMS_ADMIN.COURSES (
    course_id, course_name, course_code, credits,
    semester, year, lecturer_id, description
) VALUES (
    'CRS002', 'Data Structures', 'CS201', 4,
    'Fall', 2024, 'LEC001', 'Fundamental data structures and algorithms'
);

-- Course 3: Linear Algebra (taught by LEC002)
INSERT INTO GMS_ADMIN.COURSES (
    course_id, course_name, course_code, credits,
    semester, year, lecturer_id, description
) VALUES (
    'CRS003', 'Linear Algebra', 'MATH101', 3,
    'Fall', 2024, 'LEC002', 'Basic linear algebra for computer science'
);

PROMPT Courses inserted

-- =====================================================
-- STEP 4: INSERT ENROLLMENTS
-- =====================================================
-- STU001 enrolls in CRS001 and CRS002
INSERT INTO GMS_ADMIN.ENROLLMENTS (
    enrollment_id, student_id, course_id, enrollment_date, status
) VALUES (
    'ENR001', 'STU001', 'CRS001', TO_DATE('2024-08-15', 'YYYY-MM-DD'), 'Active'
);

INSERT INTO GMS_ADMIN.ENROLLMENTS (
    enrollment_id, student_id, course_id, enrollment_date, status
) VALUES (
    'ENR002', 'STU001', 'CRS002', TO_DATE('2024-08-15', 'YYYY-MM-DD'), 'Active'
);

-- STU002 enrolls in CRS001 and CRS003
INSERT INTO GMS_ADMIN.ENROLLMENTS (
    enrollment_id, student_id, course_id, enrollment_date, status
) VALUES (
    'ENR003', 'STU002', 'CRS001', TO_DATE('2024-08-16', 'YYYY-MM-DD'), 'Active'
);

INSERT INTO GMS_ADMIN.ENROLLMENTS (
    enrollment_id, student_id, course_id, enrollment_date, status
) VALUES (
    'ENR004', 'STU002', 'CRS003', TO_DATE('2024-08-16', 'YYYY-MM-DD'), 'Active'
);

-- STU003 enrolls in CRS002
INSERT INTO GMS_ADMIN.ENROLLMENTS (
    enrollment_id, student_id, course_id, enrollment_date, status
) VALUES (
    'ENR005', 'STU003', 'CRS002', TO_DATE('2024-08-17', 'YYYY-MM-DD'), 'Active'
);

PROMPT Enrollments inserted

-- =====================================================
-- STEP 5: INSERT GRADES (with OLS labels)
-- =====================================================
-- Note: OLS labels will be applied:
--   PUBLIC (100): General course information
--   INTERNAL (200): Grade records
--   CONFIDENTIAL (300): Special cases

-- Grades for STU001
INSERT INTO GMS_ADMIN.GRADES (
    grade_id, student_id, course_id, score, grade,
    graded_date, graded_by, comments
) VALUES (
    'GRD001', 'STU001', 'CRS001', 85.5, 'A',
    TO_DATE('2024-11-01', 'YYYY-MM-DD'), 'LEC001',
    'Excellent understanding of VPD concepts'
);

INSERT INTO GMS_ADMIN.GRADES (
    grade_id, student_id, course_id, score, grade,
    graded_date, graded_by, comments
) VALUES (
    'GRD002', 'STU001', 'CRS002', 78.0, 'B',
    TO_DATE('2024-11-02', 'YYYY-MM-DD'), 'LEC001',
    'Good implementation of binary trees'
);

-- Grades for STU002
INSERT INTO GMS_ADMIN.GRADES (
    grade_id, student_id, course_id, score, grade,
    graded_date, graded_by, comments
) VALUES (
    'GRD003', 'STU002', 'CRS001', 92.0, 'A',
    TO_DATE('2024-11-01', 'YYYY-MM-DD'), 'LEC001',
    'Outstanding audit trail implementation'
);

INSERT INTO GMS_ADMIN.GRADES (
    grade_id, student_id, course_id, score, grade,
    graded_date, graded_by, comments
) VALUES (
    'GRD004', 'STU002', 'CRS003', 88.5, 'A',
    TO_DATE('2024-11-03', 'YYYY-MM-DD'), 'LEC002',
    'Strong grasp of matrix operations'
);

-- Grades for STU003
INSERT INTO GMS_ADMIN.GRADES (
    grade_id, student_id, course_id, score, grade,
    graded_date, graded_by, comments
) VALUES (
    'GRD005', 'STU003', 'CRS002', 65.0, 'C',
    TO_DATE('2024-11-02', 'YYYY-MM-DD'), 'LEC001',
    'Needs improvement in algorithm analysis'
);

PROMPT Grades inserted

-- =====================================================
-- STEP 6: CREATE SYSTEM USERS (for login)
-- =====================================================
-- Password: student123 (for all students)
-- BCrypt hash: $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy

-- User for STU001 (nvhai)
INSERT INTO GMS_ADMIN.SYSTEM_USERS (
    user_id, username, password_hash, user_type,
    reference_id, email, is_active, created_date
) VALUES (
    'USR001', 'nvhai',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    'Student', 'STU001', 'nvhai@student.edu.vn',
    'Y', SYSDATE
);

-- User for STU002 (tthoa)
INSERT INTO GMS_ADMIN.SYSTEM_USERS (
    user_id, username, password_hash, user_type,
    reference_id, email, is_active, created_date
) VALUES (
    'USR002', 'tthoa',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    'Student', 'STU002', 'tthoa@student.edu.vn',
    'Y', SYSDATE
);

-- User for STU003 (lvminh)
INSERT INTO GMS_ADMIN.SYSTEM_USERS (
    user_id, username, password_hash, user_type,
    reference_id, email, is_active, created_date
) VALUES (
    'USR003', 'lvminh',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    'Student', 'STU003', 'lvminh@student.edu.vn',
    'Y', SYSDATE
);

-- Password: lecturer123 (for lecturers)
-- BCrypt hash: $2a$10$EblZqNptyYvchaseFRaqAOXWQ1nwXMSjr37byykLVv0Zy8.5T9G2.

-- User for LEC001 (ntmai)
INSERT INTO GMS_ADMIN.SYSTEM_USERS (
    user_id, username, password_hash, user_type,
    reference_id, email, is_active, created_date
) VALUES (
    'USR004', 'ntmai',
    '$2a$10$EblZqNptyYvchaseFRaqAOXWQ1nwXMSjr37byykLVv0Zy8.5T9G2.',
    'Lecturer', 'LEC001', 'ntmai@university.edu.vn',
    'Y', SYSDATE
);

-- User for LEC002 (tvnam)
INSERT INTO GMS_ADMIN.SYSTEM_USERS (
    user_id, username, password_hash, user_type,
    reference_id, email, is_active, created_date
) VALUES (
    'USR005', 'tvnam',
    '$2a$10$EblZqNptyYvchaseFRaqAOXWQ1nwXMSjr37byykLVv0Zy8.5T9G2.',
    'Lecturer', 'LEC002', 'tvnam@university.edu.vn',
    'Y', SYSDATE
);

-- Password: admin123 (for admin)
-- BCrypt hash: $2a$10$EblZqNptyYvchaseFRaqAOXWQ1nwXMSjr37byykLVv0Zy8.5T9G2.

-- Admin user
INSERT INTO GMS_ADMIN.SYSTEM_USERS (
    user_id, username, password_hash, user_type,
    reference_id, email, is_active, created_date
) VALUES (
    'USR006', 'admin',
    '$2a$10$EblZqNptyYvchaseFRaqAOXWQ1nwXMSjr37byykLVv0Zy8.5T9G2.',
    'Admin', 'ADM001', 'admin@university.edu.vn',
    'Y', SYSDATE
);

PROMPT System users inserted

-- =====================================================
-- STEP 7: APPLY OLS LABELS TO GRADES
-- =====================================================
-- Note: This requires OLS to be set up first (02_ols_setup.sql)
-- Apply INTERNAL label to all grade records

BEGIN
    -- Check if OLS policy exists
    FOR rec IN (SELECT COUNT(*) as cnt FROM dba_sa_policies WHERE policy_name = 'GRADE_CLASSIFICATION_POLICY') LOOP
        IF rec.cnt > 0 THEN
            -- Apply INTERNAL label to all grades
            UPDATE GMS_ADMIN.GRADES
            SET security_label = CHAR_TO_LABEL('GRADE_CLASSIFICATION_POLICY', 'INT');

            DBMS_OUTPUT.PUT_LINE('OLS labels applied to grades');
        ELSE
            DBMS_OUTPUT.PUT_LINE('OLS not configured - skipping label assignment');
        END IF;
    END LOOP;
END;
/

COMMIT;

-- =====================================================
-- VERIFY TEST DATA
-- =====================================================
PROMPT =====================================================
PROMPT Verifying Test Data...
PROMPT =====================================================

-- Count records
SELECT 'Students' as entity, COUNT(*) as count FROM GMS_ADMIN.STUDENTS
UNION ALL
SELECT 'Lecturers', COUNT(*) FROM GMS_ADMIN.LECTURERS
UNION ALL
SELECT 'Courses', COUNT(*) FROM GMS_ADMIN.COURSES
UNION ALL
SELECT 'Enrollments', COUNT(*) FROM GMS_ADMIN.ENROLLMENTS
UNION ALL
SELECT 'Grades', COUNT(*) FROM GMS_ADMIN.GRADES
UNION ALL
SELECT 'System Users', COUNT(*) FROM GMS_ADMIN.SYSTEM_USERS;

-- Show sample data
PROMPT;
PROMPT Sample Students:
SELECT student_id, first_name || ' ' || last_name as full_name, major
FROM GMS_ADMIN.STUDENTS;

PROMPT;
PROMPT Sample Courses:
SELECT course_code, course_name, c.lecturer_id,
       l.first_name || ' ' || l.last_name as lecturer_name
FROM GMS_ADMIN.COURSES c
JOIN GMS_ADMIN.LECTURERS l ON c.lecturer_id = l.lecturer_id;

PROMPT;
PROMPT Sample Grades:
SELECT g.student_id, g.course_id, g.score, g.grade,
       s.first_name || ' ' || s.last_name as student_name
FROM GMS_ADMIN.GRADES g
JOIN GMS_ADMIN.STUDENTS s ON g.student_id = s.student_id
ORDER BY g.student_id;

PROMPT;
PROMPT System Users for Login:
SELECT username, user_type, reference_id, is_active
FROM GMS_ADMIN.SYSTEM_USERS
ORDER BY user_type, username;

PROMPT =====================================================
PROMPT Test Data Setup Complete!
PROMPT =====================================================
PROMPT
PROMPT Login Credentials:
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
PROMPT =====================================================

EXIT;
