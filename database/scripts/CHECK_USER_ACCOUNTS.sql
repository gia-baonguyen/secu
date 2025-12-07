-- =============================================
-- CHECK USER ACCOUNTS AND PERMISSIONS
-- Kiểm tra các tài khoản và quyền truy cập
-- =============================================

ALTER SESSION SET CONTAINER = ORCLPDB;
ALTER SESSION SET CURRENT_SCHEMA = GMS_ADMIN;

SET PAGESIZE 1000
SET LINESIZE 200

PROMPT ========================================
PROMPT 1. KIỂM TRA CÁC ORACLE DB USERS ĐÃ TẠO
PROMPT ========================================

SELECT 
    username AS "Oracle User",
    account_status AS "Trạng thái",
    default_tablespace AS "Tablespace",
    profile AS "Profile"
FROM dba_users
WHERE username LIKE 'GMS_%'
ORDER BY username;

PROMPT
PROMPT ========================================
PROMPT 2. KIỂM TRA QUYỀN TRUY CẬP CỦA CÁC USERS
PROMPT ========================================

PROMPT
PROMPT --- GMS_STUDENT ---
SELECT table_name, privilege
FROM dba_tab_privs
WHERE grantee = 'GMS_STUDENT'
  AND owner = 'GMS_ADMIN'
ORDER BY table_name, privilege;

PROMPT
PROMPT --- GMS_LECTURER ---
SELECT table_name, privilege
FROM dba_tab_privs
WHERE grantee = 'GMS_LECTURER'
  AND owner = 'GMS_ADMIN'
ORDER BY table_name, privilege;

PROMPT
PROMPT --- GMS_RELATIVE ---
SELECT table_name, privilege
FROM dba_tab_privs
WHERE grantee = 'GMS_RELATIVE'
  AND owner = 'GMS_ADMIN'
ORDER BY table_name, privilege;

PROMPT
PROMPT --- GMS_ACADEMIC ---
SELECT table_name, privilege
FROM dba_tab_privs
WHERE grantee = 'GMS_ACADEMIC'
  AND owner = 'GMS_ADMIN'
ORDER BY table_name, privilege;

PROMPT
PROMPT --- GMS_DEAN ---
SELECT table_name, privilege
FROM dba_tab_privs
WHERE grantee = 'GMS_DEAN'
  AND owner = 'GMS_ADMIN'
ORDER BY table_name, privilege;

PROMPT
PROMPT --- GMS_DEPT_HEAD ---
SELECT table_name, privilege
FROM dba_tab_privs
WHERE grantee = 'GMS_DEPT_HEAD'
  AND owner = 'GMS_ADMIN'
ORDER BY table_name, privilege;

PROMPT
PROMPT ========================================
PROMPT 3. KIỂM TRA MAPPING SYSTEM_USERS VỚI CÁC BẢNG
PROMPT ========================================

PROMPT
PROMPT --- Mapping SYSTEM_USERS với STUDENTS ---
SELECT 
    su.user_id AS "User ID",
    su.username AS "Username",
    su.user_type AS "Loại User",
    su.reference_id AS "Reference ID",
    s.student_id AS "Student ID",
    s.first_name || ' ' || s.last_name AS "Tên Sinh viên",
    s.class_id AS "Lớp",
    su.is_active AS "Active"
FROM SYSTEM_USERS su
LEFT JOIN STUDENTS s ON su.reference_id = s.student_id
WHERE su.user_type = 'Student'
ORDER BY su.user_id;

PROMPT
PROMPT --- Mapping SYSTEM_USERS với LECTURERS ---
SELECT 
    su.user_id AS "User ID",
    su.username AS "Username",
    su.user_type AS "Loại User",
    su.reference_id AS "Reference ID",
    l.lecturer_id AS "Lecturer ID",
    l.first_name || ' ' || l.last_name AS "Tên Giảng viên",
    l.department_id AS "Bộ môn",
    su.is_active AS "Active"
FROM SYSTEM_USERS su
LEFT JOIN LECTURERS l ON su.reference_id = l.lecturer_id
WHERE su.user_type IN ('Lecturer', 'Dean', 'Department_Head')
ORDER BY su.user_id;

PROMPT
PROMPT --- Mapping SYSTEM_USERS với RELATIVES ---
SELECT 
    su.user_id AS "User ID",
    su.username AS "Username",
    su.user_type AS "Loại User",
    su.reference_id AS "Reference ID",
    r.relative_id AS "Relative ID",
    r.first_name || ' ' || r.last_name AS "Tên Người thân",
    su.is_active AS "Active"
FROM SYSTEM_USERS su
LEFT JOIN RELATIVES r ON su.reference_id = r.relative_id
WHERE su.user_type = 'Relative'
ORDER BY su.user_id;

PROMPT
PROMPT --- Tất cả SYSTEM_USERS ---
SELECT 
    su.user_id AS "User ID",
    su.username AS "Username",
    su.user_type AS "Loại User",
    su.reference_id AS "Reference ID",
    CASE 
        WHEN su.user_type = 'Student' THEN (SELECT first_name || ' ' || last_name FROM STUDENTS WHERE student_id = su.reference_id)
        WHEN su.user_type IN ('Lecturer', 'Dean', 'Department_Head') THEN (SELECT first_name || ' ' || last_name FROM LECTURERS WHERE lecturer_id = su.reference_id)
        WHEN su.user_type = 'Relative' THEN (SELECT first_name || ' ' || last_name FROM RELATIVES WHERE relative_id = su.reference_id)
        WHEN su.user_type = 'Admin' THEN 'System Administrator'
        WHEN su.user_type = 'Academic_Affairs' THEN 'Academic Affairs Office'
        ELSE 'Unknown'
    END AS "Tên",
    su.is_active AS "Active",
    su.account_locked AS "Locked",
    su.last_login AS "Last Login"
FROM SYSTEM_USERS su
ORDER BY su.user_type, su.user_id;

PROMPT
PROMPT ========================================
PROMPT 4. KIỂM TRA VPD CONTEXT MAPPING
PROMPT ========================================

PROMPT
PROMPT --- Cách set context cho từng user ---
SELECT 
    su.username AS "Username",
    su.user_type AS "User Type",
    su.reference_id AS "Reference ID",
    CASE su.user_type
        WHEN 'Student' THEN 
            'EXEC gms_admin.gms_security_pkg.set_user_context(''' || su.reference_id || ''', ''Student'');'
        WHEN 'Lecturer' THEN 
            'EXEC gms_admin.gms_security_pkg.set_user_context(''' || su.reference_id || ''', ''Lecturer'');'
        WHEN 'Relative' THEN 
            'EXEC gms_admin.gms_security_pkg.set_user_context(''' || su.reference_id || ''', ''Relative'');'
        WHEN 'Dean' THEN 
            'EXEC gms_admin.gms_security_pkg.set_user_context(''' || su.reference_id || ''', ''Dean'');'
        WHEN 'Department_Head' THEN 
            'EXEC gms_admin.gms_security_pkg.set_user_context(''' || su.reference_id || ''', ''Department_Head'');'
        WHEN 'Academic_Affairs' THEN 
            'EXEC gms_admin.gms_security_pkg.set_user_context(''' || su.reference_id || ''', ''Academic_Affairs'');'
        WHEN 'Admin' THEN 
            'EXEC gms_admin.gms_security_pkg.set_user_context(''' || su.reference_id || ''', ''Admin'');'
        ELSE 'N/A'
    END AS "Set Context Command"
FROM SYSTEM_USERS su
WHERE su.is_active = 'Y'
ORDER BY su.user_type, su.username;

PROMPT
PROMPT ========================================
PROMPT 5. TÓM TẮT: ORACLE USER vs SYSTEM_USER
PROMPT ========================================

PROMPT
PROMPT --- Oracle DB Users (để connect) ---
SELECT 
    username AS "Oracle User",
    'Password: ' || CASE username
        WHEN 'GMS_STUDENT' THEN 'Student@2024'
        WHEN 'GMS_LECTURER' THEN 'Lecturer@2024'
        WHEN 'GMS_RELATIVE' THEN 'Relative@2024'
        WHEN 'GMS_ACADEMIC' THEN 'Academic@2024'
        WHEN 'GMS_DEAN' THEN 'Dean@2024'
        WHEN 'GMS_DEPT_HEAD' THEN 'DeptHead@2024'
        WHEN 'GMS_APP' THEN 'App@2024#Connect'
        WHEN 'GMS_ADMIN' THEN 'Admin@2024#Secure'
        ELSE 'N/A'
    END AS "Password",
    'Connect: sqlplus ' || username || '/[password]@//localhost:1521/ORCLPDB' AS "Connection String"
FROM dba_users
WHERE username LIKE 'GMS_%'
ORDER BY username;

PROMPT
PROMPT --- System Users (trong bảng SYSTEM_USERS) ---
SELECT 
    username AS "System Username",
    user_type AS "Role",
    reference_id AS "Maps to ID",
    CASE user_type
        WHEN 'Student' THEN 'STUDENTS.student_id'
        WHEN 'Lecturer' THEN 'LECTURERS.lecturer_id'
        WHEN 'Relative' THEN 'RELATIVES.relative_id'
        WHEN 'Dean' THEN 'LECTURERS.lecturer_id'
        WHEN 'Department_Head' THEN 'LECTURERS.lecturer_id'
        ELSE 'N/A'
    END AS "Table Reference"
FROM SYSTEM_USERS
ORDER BY user_type, username;

PROMPT
PROMPT ========================================
PROMPT KẾT LUẬN
PROMPT ========================================
PROMPT
PROMPT 1. Oracle DB Users: Dùng để connect vào database
PROMPT    - GMS_STUDENT, GMS_LECTURER, etc.
PROMPT
PROMPT 2. System Users (SYSTEM_USERS): Dùng để login vào app
PROMPT    - username, password_hash, user_type, reference_id
PROMPT
PROMPT 3. Mapping:
PROMPT    - System User (username) -> reference_id -> STUDENTS/LECTURERS/RELATIVES
PROMPT    - Khi login app, backend set VPD context dựa trên reference_id
PROMPT
PROMPT 4. Để test VPD:
PROMPT    - Connect bằng Oracle user (GMS_STUDENT, etc.)
PROMPT    - Set context: EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');
PROMPT    - Query: SELECT * FROM gms_admin.STUDENTS;
PROMPT

