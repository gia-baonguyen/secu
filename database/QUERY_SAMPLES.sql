-- =============================================
-- QUERY SAMPLES - Grade Management System
-- File: QUERY_SAMPLES.sql
-- Purpose: Các query mẫu để demo và test
-- =============================================

-- =============================================
-- 1. QUERIES VỚI GMS_ADMIN (Xem tất cả dữ liệu)
-- =============================================

-- 1.1. Tổng quan hệ thống
SELECT 
    'Students' AS entity, COUNT(*) AS count FROM gms_admin.STUDENTS
UNION ALL
SELECT 'Lecturers', COUNT(*) FROM gms_admin.LECTURERS
UNION ALL
SELECT 'Grades', COUNT(*) FROM gms_admin.GRADES
UNION ALL
SELECT 'Enrollments', COUNT(*) FROM gms_admin.ENROLLMENTS
UNION ALL
SELECT 'Courses', COUNT(*) FROM gms_admin.COURSES
UNION ALL
SELECT 'Course Sections', COUNT(*) FROM gms_admin.COURSE_SECTIONS;

-- 1.2. Danh sách Students với thông tin đầy đủ
SELECT 
    s.student_id,
    s.first_name || ' ' || s.last_name AS full_name,
    s.email,
    s.phone_number,
    c.class_name,
    f.faculty_name,
    s.student_status,
    TO_CHAR(s.enrollment_date, 'DD/MM/YYYY') AS enrollment_date
FROM gms_admin.STUDENTS s
JOIN gms_admin.STUDENT_CLASSES c ON s.class_id = c.class_id
JOIN gms_admin.FACULTIES f ON c.faculty_id = f.faculty_id
ORDER BY s.student_id;

-- 1.3. Grades với thông tin chi tiết
SELECT 
    g.grade_id,
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    cs.course_code || ' - ' || cs.course_name AS course,
    g.grade_value,
    g.grade_letter,
    TO_CHAR(g.grade_date, 'DD/MM/YYYY') AS grade_date,
    l.first_name || ' ' || l.last_name AS lecturer_name
FROM gms_admin.GRADES g
JOIN gms_admin.STUDENTS s ON g.student_id = s.student_id
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN gms_admin.LECTURERS l ON cs.lecturer_id = l.lecturer_id
ORDER BY g.grade_date DESC;

-- 1.4. GPA của từng student
SELECT 
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    ROUND(AVG(g.grade_value), 2) AS gpa,
    COUNT(g.grade_id) AS total_grades,
    MIN(g.grade_value) AS min_grade,
    MAX(g.grade_value) AS max_grade
FROM gms_admin.STUDENTS s
LEFT JOIN gms_admin.GRADES g ON s.student_id = g.student_id
GROUP BY s.student_id, s.first_name, s.last_name
ORDER BY gpa DESC NULLS LAST;

-- 1.5. Enrollments với thông tin course
SELECT 
    e.enrollment_id,
    s.first_name || ' ' || s.last_name AS student_name,
    cs.course_code || ' - ' || cs.course_name AS course,
    TO_CHAR(e.enrollment_date, 'DD/MM/YYYY') AS enrollment_date,
    e.enrollment_status,
    l.first_name || ' ' || l.last_name AS lecturer_name
FROM gms_admin.ENROLLMENTS e
JOIN gms_admin.STUDENTS s ON e.student_id = s.student_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN gms_admin.LECTURERS l ON cs.lecturer_id = l.lecturer_id
ORDER BY e.enrollment_date DESC;

-- 1.6. Lecturers với số lượng students đang dạy
SELECT 
    l.lecturer_id,
    l.first_name || ' ' || l.last_name AS lecturer_name,
    l.email,
    d.department_name,
    COUNT(DISTINCT cs.section_id) AS total_sections,
    COUNT(DISTINCT e.student_id) AS total_students
FROM gms_admin.LECTURERS l
JOIN gms_admin.DEPARTMENTS d ON l.department_id = d.department_id
LEFT JOIN gms_admin.COURSE_SECTIONS cs ON l.lecturer_id = cs.lecturer_id
LEFT JOIN gms_admin.ENROLLMENTS e ON cs.section_id = e.section_id
GROUP BY l.lecturer_id, l.first_name, l.last_name, l.email, d.department_name
ORDER BY l.lecturer_id;

-- =============================================
-- 2. QUERIES VỚI GMS_STUDENT (VPD - Chỉ thấy data của mình)
-- =============================================

-- QUAN TRỌNG: Phải set VPD context trước khi query!
-- BEGIN
--     gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');
-- END;
-- /

-- 2.1. Student xem grades của mình
SELECT 
    g.grade_id,
    cs.course_code || ' - ' || cs.course_name AS course,
    g.grade_value,
    g.grade_letter,
    TO_CHAR(g.grade_date, 'DD/MM/YYYY') AS grade_date,
    l.first_name || ' ' || l.last_name AS lecturer_name
FROM gms_admin.GRADES g
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN gms_admin.LECTURERS l ON cs.lecturer_id = l.lecturer_id
ORDER BY g.grade_date DESC;

-- 2.2. Student xem enrollments của mình
SELECT 
    e.enrollment_id,
    cs.course_code || ' - ' || cs.course_name AS course,
    TO_CHAR(e.enrollment_date, 'DD/MM/YYYY') AS enrollment_date,
    e.enrollment_status,
    l.first_name || ' ' || l.last_name AS lecturer_name
FROM gms_admin.ENROLLMENTS e
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN gms_admin.LECTURERS l ON cs.lecturer_id = l.lecturer_id
ORDER BY e.enrollment_date DESC;

-- 2.3. Student xem GPA của mình
SELECT 
    ROUND(AVG(g.grade_value), 2) AS gpa,
    COUNT(g.grade_id) AS total_grades,
    MIN(g.grade_value) AS min_grade,
    MAX(g.grade_value) AS max_grade
FROM gms_admin.GRADES g;

-- 2.4. Student xem thông tin của mình
SELECT 
    s.student_id,
    s.first_name || ' ' || s.last_name AS full_name,
    s.email,
    s.phone_number,
    s.contact_address,
    c.class_name,
    f.faculty_name,
    s.student_status
FROM gms_admin.STUDENTS s
JOIN gms_admin.STUDENT_CLASSES c ON s.class_id = c.class_id
JOIN gms_admin.FACULTIES f ON c.faculty_id = f.faculty_id;

-- =============================================
-- 3. QUERIES VỚI GMS_LECTURER (VPD - Chỉ thấy students mình dạy)
-- =============================================

-- QUAN TRỌNG: Phải set VPD context trước khi query!
-- BEGIN
--     gms_admin.gms_security_pkg.set_user_context('LEC001', 'Lecturer');
-- END;
-- /

-- 3.1. Lecturer xem students trong lớp mình dạy
SELECT 
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    c.class_name,
    cs.course_code || ' - ' || cs.course_name AS course,
    COUNT(g.grade_id) AS total_grades,
    ROUND(AVG(g.grade_value), 2) AS avg_grade
FROM gms_admin.STUDENTS s
JOIN gms_admin.STUDENT_CLASSES c ON s.class_id = c.class_id
JOIN gms_admin.ENROLLMENTS e ON s.student_id = e.student_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
LEFT JOIN gms_admin.GRADES g ON s.student_id = g.student_id AND g.enrollment_id = e.enrollment_id
GROUP BY s.student_id, s.first_name, s.last_name, c.class_name, cs.course_code, cs.course_name
ORDER BY s.student_id;

-- 3.2. Lecturer xem grades của students mình dạy
SELECT 
    g.grade_id,
    s.first_name || ' ' || s.last_name AS student_name,
    cs.course_code || ' - ' || cs.course_name AS course,
    g.grade_value,
    g.grade_letter,
    TO_CHAR(g.grade_date, 'DD/MM/YYYY') AS grade_date
FROM gms_admin.GRADES g
JOIN gms_admin.STUDENTS s ON g.student_id = s.student_id
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
ORDER BY g.grade_date DESC;

-- 3.3. Lecturer xem course sections mình dạy
SELECT 
    cs.section_id,
    cs.course_code || ' - ' || cs.course_name AS course,
    cs.semester,
    cs.academic_year,
    COUNT(e.student_id) AS total_students
FROM gms_admin.COURSE_SECTIONS cs
LEFT JOIN gms_admin.ENROLLMENTS e ON cs.section_id = e.section_id
GROUP BY cs.section_id, cs.course_code, cs.course_name, cs.semester, cs.academic_year
ORDER BY cs.academic_year DESC, cs.semester DESC;

-- =============================================
-- 4. KIỂM TRA VPD CONTEXT
-- =============================================

-- 4.1. Xem context hiện tại
SELECT 
    SYS_CONTEXT('gms_context', 'user_id') AS user_id,
    SYS_CONTEXT('gms_context', 'user_type') AS user_type,
    SYS_CONTEXT('gms_context', 'student_id') AS student_id,
    SYS_CONTEXT('gms_context', 'lecturer_id') AS lecturer_id,
    SYS_CONTEXT('gms_context', 'class_id') AS class_id,
    SYS_CONTEXT('gms_context', 'faculty_id') AS faculty_id
FROM DUAL;

-- 4.2. Xem VPD policies đang active
SELECT 
    policy_name,
    object_schema,
    object_name,
    policy_function,
    enable,
    statement_types
FROM dba_policies
WHERE object_schema = 'GMS_ADMIN'
ORDER BY object_name, policy_name;

-- =============================================
-- 5. KIỂM TRA AUDIT (FGA)
-- =============================================

-- 5.1. Xem audit trail (cần quyền DBA)
SELECT 
    timestamp,
    db_user,
    object_schema,
    object_name,
    policy_name,
    statement_type,
    SUBSTR(sql_text, 1, 100) AS sql_text_preview
FROM dba_fga_audit_trail
WHERE object_schema = 'GMS_ADMIN'
ORDER BY timestamp DESC
FETCH FIRST 20 ROWS ONLY;

-- 5.2. Xem audit log từ triggers
SELECT 
    operation_date,
    username,
    table_name,
    operation,
    SUBSTR(new_values, 1, 100) AS values_preview
FROM gms_admin.AUDIT_LOG
ORDER BY operation_date DESC
FETCH FIRST 20 ROWS ONLY;

-- =============================================
-- 6. THỐNG KÊ VÀ BÁO CÁO
-- =============================================

-- 6.1. Thống kê grades theo course
SELECT 
    cs.course_code || ' - ' || cs.course_name AS course,
    COUNT(g.grade_id) AS total_grades,
    ROUND(AVG(g.grade_value), 2) AS avg_grade,
    MIN(g.grade_value) AS min_grade,
    MAX(g.grade_value) AS max_grade,
    COUNT(CASE WHEN g.grade_value >= 8.0 THEN 1 END) AS excellent_count,
    COUNT(CASE WHEN g.grade_value >= 6.5 AND g.grade_value < 8.0 THEN 1 END) AS good_count,
    COUNT(CASE WHEN g.grade_value < 6.5 THEN 1 END) AS fail_count
FROM gms_admin.COURSE_SECTIONS cs
LEFT JOIN gms_admin.ENROLLMENTS e ON cs.section_id = e.section_id
LEFT JOIN gms_admin.GRADES g ON e.enrollment_id = g.enrollment_id
GROUP BY cs.course_code, cs.course_name
ORDER BY avg_grade DESC NULLS LAST;

-- 6.2. Thống kê students theo class
SELECT 
    c.class_name,
    f.faculty_name,
    COUNT(s.student_id) AS total_students,
    COUNT(CASE WHEN s.student_status = 'ACTIVE' THEN 1 END) AS active_students,
    COUNT(CASE WHEN s.student_status = 'INACTIVE' THEN 1 END) AS inactive_students
FROM gms_admin.STUDENT_CLASSES c
JOIN gms_admin.FACULTIES f ON c.faculty_id = f.faculty_id
LEFT JOIN gms_admin.STUDENTS s ON c.class_id = s.class_id
GROUP BY c.class_name, f.faculty_name
ORDER BY total_students DESC;

-- 6.3. Top 10 students có GPA cao nhất
SELECT 
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    c.class_name,
    ROUND(AVG(g.grade_value), 2) AS gpa,
    COUNT(g.grade_id) AS total_grades
FROM gms_admin.STUDENTS s
JOIN gms_admin.STUDENT_CLASSES c ON s.class_id = c.class_id
JOIN gms_admin.GRADES g ON s.student_id = g.student_id
WHERE s.student_status = 'ACTIVE'
GROUP BY s.student_id, s.first_name, s.last_name, c.class_name
HAVING COUNT(g.grade_id) >= 3  -- Ít nhất 3 môn
ORDER BY gpa DESC
FETCH FIRST 10 ROWS ONLY;

-- =============================================
-- END OF FILE
-- =============================================

