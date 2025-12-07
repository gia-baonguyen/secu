-- =============================================
-- UNIVERSITY GRADE MANAGEMENT SYSTEM
-- Password Profile Configuration (FIXED VERSION)
-- =============================================

ALTER SESSION SET CONTAINER = ORCLPDB;
ALTER SESSION SET CURRENT_SCHEMA = GMS_ADMIN;

PROMPT Dropping old profiles...

-- =============================================
-- KHẮC PHỤC LỖI Ở ĐÂY:
-- 1. Thêm DISTINCT để không lặp lại tên profile
-- 2. Thêm EXCEPTION để nếu xóa lỗi thì vẫn chạy tiếp
-- =============================================
BEGIN
    FOR prof IN (SELECT DISTINCT profile FROM dba_profiles
                 WHERE profile LIKE 'GMS_%') LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP PROFILE ' || prof.profile || ' CASCADE';
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Bỏ qua lỗi nếu profile không tồn tại hoặc không xóa được
        END;
    END LOOP;
END;
/

PROMPT Creating new profiles...

-- =============================================
-- 1. STUDENT PASSWORD PROFILE
-- =============================================
CREATE PROFILE GMS_STUDENT_PROFILE LIMIT
    PASSWORD_VERIFY_FUNCTION ora12c_verify_function
    PASSWORD_LIFE_TIME 90
    PASSWORD_GRACE_TIME 7
    PASSWORD_REUSE_MAX 5
    PASSWORD_REUSE_TIME 365
    FAILED_LOGIN_ATTEMPTS 5
    PASSWORD_LOCK_TIME 0.02
    SESSIONS_PER_USER 20
    IDLE_TIME 240
    CONNECT_TIME UNLIMITED;

-- =============================================
-- 2. LECTURER PASSWORD PROFILE
-- =============================================
CREATE PROFILE GMS_LECTURER_PROFILE LIMIT
    PASSWORD_VERIFY_FUNCTION ora12c_verify_function
    PASSWORD_LIFE_TIME 60
    PASSWORD_GRACE_TIME 5
    PASSWORD_REUSE_MAX 8
    PASSWORD_REUSE_TIME 365
    FAILED_LOGIN_ATTEMPTS 3
    PASSWORD_LOCK_TIME 0.04
    SESSIONS_PER_USER 20
    IDLE_TIME 240
    CONNECT_TIME UNLIMITED;

-- =============================================
-- 3. ADMINISTRATIVE PASSWORD PROFILE
-- =============================================
CREATE PROFILE GMS_ADMIN_PROFILE LIMIT
    PASSWORD_VERIFY_FUNCTION ora12c_verify_function
    PASSWORD_LIFE_TIME 30
    PASSWORD_GRACE_TIME 3
    PASSWORD_REUSE_MAX 12
    PASSWORD_REUSE_TIME 365
    FAILED_LOGIN_ATTEMPTS 3
    PASSWORD_LOCK_TIME 0.08
    SESSIONS_PER_USER 20
    IDLE_TIME 240
    CONNECT_TIME UNLIMITED;

-- =============================================
-- 4. RELATIVE PASSWORD PROFILE
-- =============================================
CREATE PROFILE GMS_RELATIVE_PROFILE LIMIT
    PASSWORD_VERIFY_FUNCTION ora12c_verify_function
    PASSWORD_LIFE_TIME 120
    PASSWORD_GRACE_TIME 14
    PASSWORD_REUSE_MAX 3
    PASSWORD_REUSE_TIME 180
    FAILED_LOGIN_ATTEMPTS 5
    PASSWORD_LOCK_TIME 0.01
    SESSIONS_PER_USER 10
    IDLE_TIME 480
    CONNECT_TIME UNLIMITED;

-- =============================================
-- 5. SYSTEM ADMINISTRATOR PROFILE
-- =============================================
CREATE PROFILE GMS_SYSADMIN_PROFILE LIMIT
    PASSWORD_VERIFY_FUNCTION ora12c_verify_function
    PASSWORD_LIFE_TIME 30
    PASSWORD_GRACE_TIME 1
    PASSWORD_REUSE_MAX 24
    PASSWORD_REUSE_TIME 730
    FAILED_LOGIN_ATTEMPTS 2
    PASSWORD_LOCK_TIME 0.16
    SESSIONS_PER_USER UNLIMITED
    IDLE_TIME UNLIMITED
    CONNECT_TIME UNLIMITED;

-- =============================================
-- Custom Password Verification Function
-- =============================================
CREATE OR REPLACE FUNCTION gms_password_verify
(
    username VARCHAR2,
    password VARCHAR2,
    old_password VARCHAR2
)
RETURN BOOLEAN
IS
    differ INTEGER;
    digit_count INTEGER;
    upper_count INTEGER;
    lower_count INTEGER;
    special_count INTEGER;
BEGIN
    -- Check length
    IF LENGTH(password) < 8 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Password must be at least 8 characters');
    END IF;

    -- Check username match
    IF UPPER(password) = UPPER(username) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Password cannot be the same as username');
    END IF;

    -- Check digit
    digit_count := LENGTH(password) - LENGTH(TRANSLATE(password, '0123456789', ' '));
    IF digit_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Password must contain at least one digit');
    END IF;

    -- Check upper
    upper_count := LENGTH(password) - LENGTH(TRANSLATE(password, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', ' '));
    IF upper_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Password must contain at least one uppercase letter');
    END IF;

    -- Check lower
    lower_count := LENGTH(password) - LENGTH(TRANSLATE(password, 'abcdefghijklmnopqrstuvwxyz', ' '));
    IF lower_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Password must contain at least one lowercase letter');
    END IF;

    -- Check special char
    special_count := LENGTH(password) - LENGTH(TRANSLATE(password, '!@#$%^&*()_+-=[]{}|;:,.<>?', ' '));
    IF special_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Password must contain at least one special character');
    END IF;

    -- Check diff
    IF old_password IS NOT NULL THEN
        differ := LENGTH(old_password) - LENGTH(password);
        IF ABS(differ) < 3 THEN
            IF LENGTH(TRANSLATE(UPPER(password), UPPER(old_password), ' ')) < 3 THEN
                RAISE_APPLICATION_ERROR(-20007, 'New password must differ from old password by at least 3 characters');
            END IF;
        END IF;
    END IF;

    -- Check weak passwords
    IF UPPER(password) IN ('PASSWORD', 'PASSWORD123', 'ADMIN123', 'STUDENT123',
                           'LECTURER123', '12345678', 'QWERTY123', 'ABC12345') THEN
        RAISE_APPLICATION_ERROR(-20008, 'Password is too common');
    END IF;

    RETURN TRUE;
END;
/

-- =============================================
-- Apply profiles to existing users
-- =============================================

ALTER USER GMS_STUDENT PROFILE GMS_STUDENT_PROFILE;
ALTER USER GMS_LECTURER PROFILE GMS_LECTURER_PROFILE;
ALTER USER GMS_ACADEMIC PROFILE GMS_ADMIN_PROFILE;
ALTER USER GMS_DEAN PROFILE GMS_ADMIN_PROFILE;
ALTER USER GMS_DEPT_HEAD PROFILE GMS_ADMIN_PROFILE;
ALTER USER GMS_RELATIVE PROFILE GMS_RELATIVE_PROFILE;
ALTER USER GMS_ADMIN PROFILE GMS_SYSADMIN_PROFILE;

-- =============================================
-- Password History Table
-- =============================================
-- Dùng BEGIN-EXCEPTION để tránh lỗi nếu bảng đã tồn tại
BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE PASSWORD_HISTORY (
        user_id VARCHAR2(10),
        username VARCHAR2(50),
        password_hash VARCHAR2(100),
        changed_date DATE DEFAULT SYSDATE,
        changed_by VARCHAR2(50),
        change_reason VARCHAR2(200)
    )';
    EXECUTE IMMEDIATE 'CREATE INDEX idx_pwd_history_user ON PASSWORD_HISTORY(user_id, changed_date)';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN NULL; -- ORA-00955: name is already used by an existing object
        ELSE RAISE;
        END IF;
END;
/

PROMPT Displaying Profiles...
SELECT profile, resource_name, limit
FROM dba_profiles
WHERE profile LIKE 'GMS_%'
ORDER BY profile, resource_name;

COMMIT;
PROMPT ========================================
PROMPT Password profiles configured successfully!
PROMPT ========================================