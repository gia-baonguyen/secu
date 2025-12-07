-- =============================================
-- CHECK MAPPING SIMPLE - Kiểm tra mapping đơn giản
-- =============================================

ALTER SESSION SET CONTAINER = ORCLPDB;
ALTER SESSION SET CURRENT_SCHEMA = GMS_ADMIN;

SET PAGESIZE 1000
SET LINESIZE 200

PROMPT ========================================
PROMPT 1. ORACLE DB USERS
PROMPT ========================================
SELECT username, account_status, profile
FROM dba_users
WHERE username LIKE 'GMS_%'
ORDER BY username;

PROMPT
PROMPT ========================================
PROMPT 2. SYSTEM_USERS - Tất cả users
PROMPT ========================================
SELECT 
    user_id,
    username,
    user_type,
    reference_id,
    is_active
FROM SYSTEM_USERS
ORDER BY user_type, user_id;

PROMPT
PROMPT ========================================
PROMPT 3. MAPPING STUDENTS
PROMPT ========================================
SELECT 
    su.user_id,
    su.username,
    su.reference_id,
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    s.class_id
FROM SYSTEM_USERS su
LEFT JOIN STUDENTS s ON su.reference_id = s.student_id
WHERE su.user_type = 'Student'
ORDER BY su.user_id;

PROMPT
PROMPT ========================================
PROMPT 4. MAPPING LECTURERS
PROMPT ========================================
SELECT 
    su.user_id,
    su.username,
    su.user_type,
    su.reference_id,
    l.lecturer_id,
    l.first_name || ' ' || l.last_name AS lecturer_name,
    l.department_id
FROM SYSTEM_USERS su
LEFT JOIN LECTURERS l ON su.reference_id = l.lecturer_id
WHERE su.user_type IN ('Lecturer', 'Dean', 'Department_Head')
ORDER BY su.user_id;

PROMPT
PROMPT ========================================
PROMPT 5. MAPPING RELATIVES
PROMPT ========================================
SELECT 
    su.user_id,
    su.username,
    su.reference_id,
    r.relative_id,
    r.first_name || ' ' || r.last_name AS relative_name
FROM SYSTEM_USERS su
LEFT JOIN RELATIVES r ON su.reference_id = r.relative_id
WHERE su.user_type = 'Relative'
ORDER BY su.user_id;

PROMPT
PROMPT ========================================
PROMPT 6. QUYỀN TRUY CẬP - GMS_STUDENT
PROMPT ========================================
SELECT table_name, privilege
FROM dba_tab_privs
WHERE grantee = 'GMS_STUDENT'
  AND owner = 'GMS_ADMIN'
ORDER BY table_name, privilege;

PROMPT
PROMPT ========================================
PROMPT 7. QUYỀN TRUY CẬP - GMS_LECTURER
PROMPT ========================================
SELECT table_name, privilege
FROM dba_tab_privs
WHERE grantee = 'GMS_LECTURER'
  AND owner = 'GMS_ADMIN'
ORDER BY table_name, privilege;

PROMPT
PROMPT ========================================
PROMPT 8. QUYỀN TRUY CẬP - GMS_ACADEMIC
PROMPT ========================================
SELECT table_name, privilege
FROM dba_tab_privs
WHERE grantee = 'GMS_ACADEMIC'
  AND owner = 'GMS_ADMIN'
ORDER BY table_name, privilege;

PROMPT
PROMPT ========================================
PROMPT KẾT LUẬN
PROMPT ========================================
PROMPT
PROMPT Để test với từng user:
PROMPT 1. Connect: sqlplus GMS_STUDENT/Student@2024@//localhost:1521/ORCLPDB
PROMPT 2. Set context: EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');
PROMPT 3. Query: SELECT * FROM gms_admin.STUDENTS;
PROMPT

