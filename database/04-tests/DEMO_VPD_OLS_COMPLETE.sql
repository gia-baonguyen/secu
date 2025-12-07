-- =============================================
-- DEMO VPD VÀ OLS - COMPLETE DEMONSTRATION
-- Grade Management System - Security Demo
-- =============================================
-- Purpose: Demo VPD và OLS policies cho bài tập lớn
-- Usage: Chạy từng phần trong SQL*Plus với user tương ứng
-- =============================================

SET SERVEROUTPUT ON
SET PAGESIZE 1000
SET LINESIZE 200

ALTER SESSION SET CONTAINER = ORCLPDB;
ALTER SESSION SET CURRENT_SCHEMA = GMS_ADMIN;

PROMPT ========================================
PROMPT DEMO VPD VÀ OLS - COMPLETE DEMONSTRATION
PROMPT ========================================
PROMPT
PROMPT Mục đích: Demo các chính sách bảo mật VPD và OLS
PROMPT với từng tài khoản khác nhau
PROMPT
PROMPT ========================================
PROMPT

-- =============================================
-- PART 1: TỔNG QUAN DATA (Connect với GMS_ADMIN)
-- =============================================
PROMPT [PART 1] TỔNG QUAN DATA (GMS_ADMIN - Thấy tất cả)
PROMPT ========================================
PROMPT

SELECT 'Tổng số sinh viên' AS "Thống kê", COUNT(*) AS "Số lượng" FROM STUDENTS
UNION ALL
SELECT 'Tổng số điểm', COUNT(*) FROM GRADES
UNION ALL
SELECT 'Tổng số câu hỏi', COUNT(*) FROM EXAM_QUESTIONS;

PROMPT
PROMPT Chi tiết sinh viên:
SELECT student_id, first_name || ' ' || last_name AS name, class_id
FROM STUDENTS
ORDER BY student_id;

PROMPT
PROMPT Chi tiết điểm:
SELECT 
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    c.course_name,
    g.midterm_score,
    g.final_score,
    g.total_score
FROM GRADES g
JOIN ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN STUDENTS s ON e.student_id = s.student_id
JOIN COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN COURSES c ON cs.course_id = c.course_id
ORDER BY s.student_id, c.course_name;

PROMPT
PROMPT Chi tiết câu hỏi (OLS labels):
SELECT 
    question_id,
    subject_code,
    SUBSTR(question_text, 1, 50) || '...' AS question_preview,
    LABEL_TO_CHAR(ols_label) AS security_label
FROM EXAM_QUESTIONS
ORDER BY ols_label, question_id;

PROMPT
PROMPT ========================================
PROMPT [PART 2] HƯỚNG DẪN DEMO VPD
PROMPT ========================================
PROMPT
PROMPT Để demo VPD, mở các terminal/SQL*Plus riêng:
PROMPT
PROMPT --- DEMO 1: STUDENT ---
PROMPT Terminal 1:
PROMPT   sqlplus GMS_STUDENT/Student@2024@//localhost:1521/ORCLPDB
PROMPT   EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');
PROMPT   SELECT COUNT(*) FROM gms_admin.STUDENTS;  -- Chỉ thấy 1
PROMPT   SELECT COUNT(*) FROM gms_admin.GRADES;    -- Chỉ thấy điểm của STU001
PROMPT
PROMPT --- DEMO 2: LECTURER ---
PROMPT Terminal 2:
PROMPT   sqlplus GMS_LECTURER/Lecturer@2024@//localhost:1521/ORCLPDB
PROMPT   EXEC gms_admin.gms_security_pkg.set_user_context('LEC001', 'Lecturer');
PROMPT   SELECT COUNT(*) FROM gms_admin.STUDENTS;  -- Thấy SV trong lớp dạy
PROMPT   SELECT COUNT(*) FROM gms_admin.GRADES;    -- Thấy điểm của các môn dạy
PROMPT
PROMPT --- DEMO 3: ACADEMIC AFFAIRS ---
PROMPT Terminal 3:
PROMPT   sqlplus GMS_ACADEMIC/Academic@2024@//localhost:1521/ORCLPDB
PROMPT   EXEC gms_admin.gms_security_pkg.set_user_context('ACAD001', 'Academic_Affairs');
PROMPT   SELECT COUNT(*) FROM gms_admin.STUDENTS;  -- Thấy TẤT CẢ
PROMPT   SELECT COUNT(*) FROM gms_admin.GRADES;    -- Thấy TẤT CẢ
PROMPT
PROMPT ========================================
PROMPT [PART 3] HƯỚNG DẪN DEMO OLS
PROMPT ========================================
PROMPT
PROMPT Để demo OLS, mở các terminal/SQL*Plus riêng:
PROMPT
PROMPT --- DEMO 1: LECTURER (chỉ thấy PUB và INT:CS) ---
PROMPT Terminal 1:
PROMPT   sqlplus GMS_LECTURER/Lecturer@2024@//localhost:1521/ORCLPDB
PROMPT   EXEC gms_admin.gms_security_pkg.set_user_context('LEC001', 'Lecturer');
PROMPT   SELECT question_id, subject_code, LABEL_TO_CHAR(ols_label) AS label
PROMPT   FROM gms_admin.EXAM_QUESTIONS;
PROMPT   -- Kết quả: Chỉ thấy PUB và INT:CS
PROMPT
PROMPT --- DEMO 2: DEAN (thấy PUB, INT:CS, CONF:CS) ---
PROMPT Terminal 2:
PROMPT   sqlplus GMS_DEAN/Dean@2024@//localhost:1521/ORCLPDB
PROMPT   EXEC gms_admin.gms_security_pkg.set_user_context('FAC001', 'Dean');
PROMPT   SELECT question_id, subject_code, LABEL_TO_CHAR(ols_label) AS label
PROMPT   FROM gms_admin.EXAM_QUESTIONS;
PROMPT   -- Kết quả: Thấy tất cả (PUB, INT:CS, CONF:CS)
PROMPT
PROMPT --- DEMO 3: INSERT với OLS ---
PROMPT Terminal 1 (Lecturer):
PROMPT   INSERT INTO gms_admin.EXAM_QUESTIONS (
PROMPT       subject_code, question_text, correct_answer, created_by, created_date, ols_label
PROMPT   ) VALUES (
PROMPT       'CS101', 'Test question', 'Answer', 'LEC001', SYSDATE,
PROMPT       CHAR_TO_LABEL('EXAM_SEC_POLICY', 'INT:CS')
PROMPT   );
PROMPT   COMMIT;  -- Thành công
PROMPT
PROMPT   INSERT INTO gms_admin.EXAM_QUESTIONS (
PROMPT       subject_code, question_text, correct_answer, created_by, created_date, ols_label
PROMPT   ) VALUES (
PROMPT       'CS101', 'Secret question', 'Secret', 'LEC001', SYSDATE,
PROMPT       CHAR_TO_LABEL('EXAM_SEC_POLICY', 'CONF:CS')
PROMPT   );
PROMPT   -- Lỗi hoặc không thấy sau khi INSERT (không có quyền)
PROMPT
PROMPT ========================================
PROMPT [PART 4] DEMO QUA API
PROMPT ========================================
PROMPT
PROMPT Để demo qua API (giống production):
PROMPT
PROMPT 1. Start backend:
PROMPT    cd secu/backend
PROMPT    mvn spring-boot:run
PROMPT
PROMPT 2. Login với student:
PROMPT    curl -X POST http://localhost:8081/api/auth/login \
PROMPT      -H "Content-Type: application/json" \
PROMPT      -d '{"username":"nvhai","password":"password123"}'
PROMPT
PROMPT 3. Query grades (chỉ thấy điểm của STU001):
PROMPT    curl -X GET http://localhost:8081/api/students/me/grades \
PROMPT      -H "Authorization: Bearer <TOKEN>"
PROMPT
PROMPT 4. Login với lecturer:
PROMPT    curl -X POST http://localhost:8081/api/auth/login \
PROMPT      -H "Content-Type: application/json" \
PROMPT      -d '{"username":"nv.an","password":"password123"}'
PROMPT
PROMPT 5. Query exam questions (chỉ thấy PUB và INT:CS):
PROMPT    curl -X GET http://localhost:8081/api/exam-questions \
PROMPT      -H "Authorization: Bearer <TOKEN>"
PROMPT
PROMPT ========================================
PROMPT [PART 5] BẢNG SO SÁNH KẾT QUẢ
PROMPT ========================================
PROMPT

SELECT 
    'STUDENT' AS "Role",
    'GMS_STUDENT' AS "Oracle User",
    'nvhai' AS "System Username",
    'Chỉ thấy 1 SV (STU001)' AS "Query STUDENTS",
    'Chỉ thấy điểm của STU001' AS "Query GRADES",
    'Chỉ thấy PUB' AS "Query EXAM_QUESTIONS"
FROM dual
UNION ALL
SELECT 
    'LECTURER',
    'GMS_LECTURER',
    'nv.an',
    'Thấy SV trong lớp dạy/chủ nhiệm',
    'Thấy điểm của các môn dạy',
    'Thấy PUB và INT:CS'
FROM dual
UNION ALL
SELECT 
    'ACADEMIC',
    'GMS_ACADEMIC',
    'academic',
    'Thấy TẤT CẢ',
    'Thấy TẤT CẢ',
    'Thấy TẤT CẢ'
FROM dual
UNION ALL
SELECT 
    'DEAN',
    'GMS_DEAN',
    'dean_user',
    'Thấy TẤT CẢ',
    'Thấy TẤT CẢ',
    'Thấy PUB, INT:CS, CONF:CS'
FROM dual;

PROMPT
PROMPT ========================================
PROMPT DEMO COMPLETE
PROMPT ========================================
PROMPT
PROMPT Để demo chi tiết:
PROMPT 1. Chạy từng phần trong SQL*Plus với user tương ứng
PROMPT 2. Hoặc demo qua API với các username khác nhau
PROMPT 3. Screenshot kết quả để đưa vào báo cáo
PROMPT
PROMPT Lưu ý:
PROMPT - Backend dùng GMS_APP (single user) + VPD context
PROMPT - Demo SQL*Plus dùng các Oracle users khác nhau
PROMPT - Cả hai cách đều cho thấy VPD/OLS hoạt động đúng
PROMPT

COMMIT;

