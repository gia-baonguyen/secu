-- =============================================
-- DEMO USER ACCESS - Test quyền truy cập của từng user
-- =============================================

ALTER SESSION SET CONTAINER = ORCLPDB;
ALTER SESSION SET CURRENT_SCHEMA = GMS_ADMIN;

SET PAGESIZE 1000
SET LINESIZE 200

PROMPT ========================================
PROMPT DEMO: KIỂM TRA QUYỀN TRUY CẬP CỦA CÁC USERS
PROMPT ========================================
PROMPT
PROMPT Lưu ý: Script này chạy với quyền GMS_ADMIN
PROMPT Để test thực tế, cần connect bằng từng user riêng
PROMPT

-- =============================================
-- 1. DEMO: STUDENT (STU001 - nvhai)
-- =============================================
PROMPT
PROMPT ========================================
PROMPT 1. DEMO: STUDENT (STU001 - nvhai)
PROMPT ========================================

-- Set context như student
EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');

PROMPT
PROMPT --- Context đã set ---
SELECT 
    SYS_CONTEXT('gms_context', 'user_id') AS "User ID",
    SYS_CONTEXT('gms_context', 'user_type') AS "User Type",
    SYS_CONTEXT('gms_context', 'class_id') AS "Class ID"
FROM dual;

PROMPT
PROMPT --- Sinh viên STU001 có thể xem thông tin của mình ---
SELECT 
    student_id,
    first_name || ' ' || last_name AS name,
    email,
    phone_number,
    class_id,
    student_status
FROM STUDENTS
WHERE student_id = 'STU001';

PROMPT
PROMPT --- Sinh viên STU001 có thể xem điểm của mình ---
SELECT 
    g.grade_id,
    c.course_name,
    cs.semester,
    cs.academic_year,
    g.midterm_score,
    g.final_score,
    g.total_score,
    g.letter_grade,
    g.grade_status
FROM GRADES g
JOIN ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN COURSES c ON cs.course_id = c.course_id
WHERE e.student_id = 'STU001'
ORDER BY cs.academic_year, cs.semester, c.course_name;

PROMPT
PROMPT --- Sinh viên STU001 KHÔNG thể xem sinh viên khác (VPD filter) ---
SELECT COUNT(*) AS "Số sinh viên có thể xem" FROM STUDENTS;

PROMPT
PROMPT --- Sinh viên STU001 KHÔNG thể xem điểm của người khác (VPD filter) ---
SELECT COUNT(*) AS "Số điểm có thể xem" FROM GRADES;

-- =============================================
-- 2. DEMO: LECTURER (LEC001 - nv.an)
-- =============================================
PROMPT
PROMPT ========================================
PROMPT 2. DEMO: LECTURER (LEC001 - nv.an)
PROMPT ========================================

-- Set context như lecturer
EXEC gms_admin.gms_security_pkg.set_user_context('LEC001', 'Lecturer');

PROMPT
PROMPT --- Context đã set ---
SELECT 
    SYS_CONTEXT('gms_context', 'user_id') AS "User ID",
    SYS_CONTEXT('gms_context', 'user_type') AS "User Type",
    SYS_CONTEXT('gms_context', 'department_id') AS "Department ID"
FROM dual;

PROMPT
PROMPT --- Giảng viên LEC001 có thể xem sinh viên trong lớp mình chủ nhiệm ---
SELECT 
    s.student_id,
    s.first_name || ' ' || s.last_name AS name,
    s.class_id,
    c.class_name
FROM STUDENTS s
JOIN CLASSES c ON s.class_id = c.class_id
WHERE c.homeroom_teacher_id = 'LEC001';

PROMPT
PROMPT --- Giảng viên LEC001 có thể xem điểm của sinh viên trong môn mình dạy ---
SELECT 
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    c.course_name,
    g.midterm_score,
    g.final_score,
    g.total_score,
    g.letter_grade,
    g.grade_status
FROM GRADES g
JOIN ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN STUDENTS s ON e.student_id = s.student_id
JOIN COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN COURSES c ON cs.course_id = c.course_id
WHERE cs.lecturer_id = 'LEC001'
ORDER BY s.student_id, c.course_name;

PROMPT
PROMPT --- Giảng viên LEC001 có thể xem các lớp học phần mình dạy ---
SELECT 
    cs.section_id,
    c.course_name,
    cs.semester,
    cs.academic_year,
    cs.enrolled_students,
    cs.section_status
FROM COURSE_SECTIONS cs
JOIN COURSES c ON cs.course_id = c.course_id
WHERE cs.lecturer_id = 'LEC001';

-- =============================================
-- 3. DEMO: RELATIVE (REL001 - nvhung)
-- =============================================
PROMPT
PROMPT ========================================
PROMPT 3. DEMO: RELATIVE (REL001 - nvhung)
PROMPT ========================================

-- Set context như relative
EXEC gms_admin.gms_security_pkg.set_user_context('REL001', 'Relative');

PROMPT
PROMPT --- Context đã set ---
SELECT 
    SYS_CONTEXT('gms_context', 'user_id') AS "User ID",
    SYS_CONTEXT('gms_context', 'user_type') AS "User Type"
FROM dual;

PROMPT
PROMPT --- Người thân REL001 có thể xem điểm của con (STU001) ---
SELECT 
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    sr.relationship,
    c.course_name,
    g.midterm_score,
    g.final_score,
    g.total_score,
    g.letter_grade,
    g.grade_status
FROM GRADES g
JOIN ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN STUDENTS s ON e.student_id = s.student_id
JOIN STUDENT_RELATIVES sr ON s.student_id = sr.student_id
JOIN COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN COURSES c ON cs.course_id = c.course_id
WHERE sr.relative_id = 'REL001'
ORDER BY s.student_id, c.course_name;

-- =============================================
-- 4. DEMO: ACADEMIC_AFFAIRS
-- =============================================
PROMPT
PROMPT ========================================
PROMPT 4. DEMO: ACADEMIC_AFFAIRS
PROMPT ========================================

-- Set context như academic affairs
EXEC gms_admin.gms_security_pkg.set_user_context('ACAD001', 'Academic_Affairs');

PROMPT
PROMPT --- Context đã set ---
SELECT 
    SYS_CONTEXT('gms_context', 'user_id') AS "User ID",
    SYS_CONTEXT('gms_context', 'user_type') AS "User Type"
FROM dual;

PROMPT
PROMPT --- Academic Affairs có thể xem TẤT CẢ sinh viên ---
SELECT COUNT(*) AS "Tổng số sinh viên" FROM STUDENTS;

PROMPT
PROMPT --- Academic Affairs có thể xem TẤT CẢ điểm ---
SELECT COUNT(*) AS "Tổng số điểm" FROM GRADES;

PROMPT
PROMPT --- Academic Affairs có thể xem tất cả điểm chi tiết ---
SELECT 
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    c.course_name,
    g.midterm_score,
    g.final_score,
    g.total_score,
    g.letter_grade,
    g.grade_status,
    g.submitted_by,
    g.approved_by
FROM GRADES g
JOIN ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN STUDENTS s ON e.student_id = s.student_id
JOIN COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN COURSES c ON cs.course_id = c.course_id
ORDER BY s.student_id, c.course_name
FETCH FIRST 10 ROWS ONLY;

-- =============================================
-- 5. TÓM TẮT QUYỀN TRUY CẬP
-- =============================================
PROMPT
PROMPT ========================================
PROMPT 5. TÓM TẮT QUYỀN TRUY CẬP
PROMPT ========================================

PROMPT
PROMPT --- Bảng tóm tắt quyền truy cập ---
SELECT 
    'STUDENT (STU001)' AS "User",
    'Xem thông tin của mình' AS "STUDENTS",
    'Xem điểm của mình' AS "GRADES",
    'Không' AS "Sửa điểm"
FROM dual
UNION ALL
SELECT 
    'LECTURER (LEC001)',
    'Xem sinh viên trong lớp CN',
    'Xem/sửa điểm môn mình dạy',
    'Có (trước deadline)'
FROM dual
UNION ALL
SELECT 
    'RELATIVE (REL001)',
    'Xem thông tin con',
    'Xem điểm của con',
    'Không'
FROM dual
UNION ALL
SELECT 
    'ACADEMIC_AFFAIRS',
    'Xem tất cả',
    'Xem/sửa tất cả',
    'Có (mọi lúc)'
FROM dual;

PROMPT
PROMPT ========================================
PROMPT HƯỚNG DẪN TEST THỰC TẾ
PROMPT ========================================
PROMPT
PROMPT Để test thực tế với từng user:
PROMPT
PROMPT 1. Connect bằng Oracle user:
PROMPT    sqlplus GMS_STUDENT/Student@2024@//localhost:1521/ORCLPDB
PROMPT
PROMPT 2. Set VPD context:
PROMPT    EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');
PROMPT
PROMPT 3. Query để kiểm tra:
PROMPT    SELECT * FROM gms_admin.STUDENTS;  -- Chỉ thấy 1 record (STU001)
PROMPT    SELECT * FROM gms_admin.GRADES;    -- Chỉ thấy điểm của STU001
PROMPT
PROMPT 4. Kiểm tra context:
PROMPT    SELECT SYS_CONTEXT('gms_context', 'user_id') FROM dual;
PROMPT    SELECT SYS_CONTEXT('gms_context', 'user_type') FROM dual;
PROMPT

