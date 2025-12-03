-- =============================================
-- UNIVERSITY GRADE MANAGEMENT SYSTEM
-- Password Profile Configuration
-- Based on security best practices and user behavior analysis
-- =============================================

ALTER SESSION SET CONTAINER = ORCLPDB;
ALTER SESSION SET CURRENT_SCHEMA = GMS_ADMIN;

-- Drop existing profiles if they exist
BEGIN
    FOR prof IN (SELECT profile FROM dba_profiles
                 WHERE profile LIKE 'GMS_%' AND profile != 'DEFAULT') LOOP
        EXECUTE IMMEDIATE 'DROP PROFILE ' || prof.profile || ' CASCADE';
    END LOOP;
END;
/

-- =============================================
-- 1. STUDENT PASSWORD PROFILE
-- For student users - moderate security
-- =============================================
CREATE PROFILE GMS_STUDENT_PROFILE LIMIT
    -- Password complexity
    PASSWORD_VERIFY_FUNCTION ora12c_verify_function
    -- Password lifetime (90 days for students)
    PASSWORD_LIFE_TIME 90
    -- Grace period for password change (7 days)
    PASSWORD_GRACE_TIME 7
    -- Password reuse (cannot reuse last 5 passwords)
    PASSWORD_REUSE_MAX 5
    PASSWORD_REUSE_TIME 365
    -- Failed login attempts (5 attempts before lock)
    FAILED_LOGIN_ATTEMPTS 5
    -- Account lock time (30 minutes)
    PASSWORD_LOCK_TIME 0.02
    -- Session limits
    SESSIONS_PER_USER 2
    -- Idle time (30 minutes)
    IDLE_TIME 30
    -- Connection time (4 hours)
    CONNECT_TIME 240;

-- =============================================
-- 2. LECTURER PASSWORD PROFILE
-- For teaching staff - enhanced security
-- =============================================
CREATE PROFILE GMS_LECTURER_PROFILE LIMIT
    -- Password complexity
    PASSWORD_VERIFY_FUNCTION ora12c_verify_function
    -- Password lifetime (60 days)
    PASSWORD_LIFE_TIME 60
    -- Grace period for password change (5 days)
    PASSWORD_GRACE_TIME 5
    -- Password reuse (cannot reuse last 8 passwords)
    PASSWORD_REUSE_MAX 8
    PASSWORD_REUSE_TIME 365
    -- Failed login attempts (3 attempts before lock)
    FAILED_LOGIN_ATTEMPTS 3
    -- Account lock time (1 hour)
    PASSWORD_LOCK_TIME 0.04
    -- Session limits
    SESSIONS_PER_USER 3
    -- Idle time (20 minutes)
    IDLE_TIME 20
    -- Connection time (8 hours)
    CONNECT_TIME 480;

-- =============================================
-- 3. ADMINISTRATIVE PASSWORD PROFILE
-- For Academic Affairs, Deans, Department Heads - high security
-- =============================================
CREATE PROFILE GMS_ADMIN_PROFILE LIMIT
    -- Password complexity
    PASSWORD_VERIFY_FUNCTION ora12c_verify_function
    -- Password lifetime (30 days)
    PASSWORD_LIFE_TIME 30
    -- Grace period for password change (3 days)
    PASSWORD_GRACE_TIME 3
    -- Password reuse (cannot reuse last 12 passwords)
    PASSWORD_REUSE_MAX 12
    PASSWORD_REUSE_TIME 365
    -- Failed login attempts (3 attempts before lock)
    FAILED_LOGIN_ATTEMPTS 3
    -- Account lock time (2 hours)
    PASSWORD_LOCK_TIME 0.08
    -- Session limits
    SESSIONS_PER_USER 2
    -- Idle time (15 minutes)
    IDLE_TIME 15
    -- Connection time (4 hours)
    CONNECT_TIME 240;

-- =============================================
-- 4. RELATIVE PASSWORD PROFILE
-- For student relatives - basic security
-- =============================================
CREATE PROFILE GMS_RELATIVE_PROFILE LIMIT
    -- Password complexity
    PASSWORD_VERIFY_FUNCTION ora12c_verify_function
    -- Password lifetime (120 days)
    PASSWORD_LIFE_TIME 120
    -- Grace period for password change (14 days)
    PASSWORD_GRACE_TIME 14
    -- Password reuse (cannot reuse last 3 passwords)
    PASSWORD_REUSE_MAX 3
    PASSWORD_REUSE_TIME 180
    -- Failed login attempts (5 attempts before lock)
    FAILED_LOGIN_ATTEMPTS 5
    -- Account lock time (15 minutes)
    PASSWORD_LOCK_TIME 0.01
    -- Session limits
    SESSIONS_PER_USER 1
    -- Idle time (60 minutes)
    IDLE_TIME 60
    -- Connection time (2 hours)
    CONNECT_TIME 120;

-- =============================================
-- 5. SYSTEM ADMINISTRATOR PROFILE
-- For system administrators - maximum security
-- =============================================
CREATE PROFILE GMS_SYSADMIN_PROFILE LIMIT
    -- Password complexity
    PASSWORD_VERIFY_FUNCTION ora12c_verify_function
    -- Password lifetime (30 days)
    PASSWORD_LIFE_TIME 30
    -- Grace period for password change (1 day)
    PASSWORD_GRACE_TIME 1
    -- Password reuse (cannot reuse last 24 passwords)
    PASSWORD_REUSE_MAX 24
    PASSWORD_REUSE_TIME 730
    -- Failed login attempts (2 attempts before lock)
    FAILED_LOGIN_ATTEMPTS 2
    -- Account lock time (4 hours)
    PASSWORD_LOCK_TIME 0.16
    -- Session limits
    SESSIONS_PER_USER 1
    -- Idle time (10 minutes)
    IDLE_TIME 10
    -- Connection time (2 hours)
    CONNECT_TIME 120;

-- =============================================
-- Custom Password Verification Function
-- Enhanced security requirements
-- =============================================
CREATE OR REPLACE FUNCTION gms_password_verify
(
    username VARCHAR2,
    password VARCHAR2,
    old_password VARCHAR2
)
RETURN BOOLEAN
IS
    n BOOLEAN;
    m INTEGER;
    differ INTEGER;
    digit_count INTEGER;
    upper_count INTEGER;
    lower_count INTEGER;
    special_count INTEGER;
BEGIN
    -- Check if the password is at least 8 characters
    IF LENGTH(password) < 8 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Password must be at least 8 characters');
    END IF;

    -- Check if password is different from username
    IF UPPER(password) = UPPER(username) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Password cannot be the same as username');
    END IF;

    -- Check for at least one digit
    digit_count := LENGTH(password) - LENGTH(TRANSLATE(password, '0123456789', ' '));
    IF digit_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Password must contain at least one digit');
    END IF;

    -- Check for at least one uppercase letter
    upper_count := LENGTH(password) - LENGTH(TRANSLATE(password, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', ' '));
    IF upper_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Password must contain at least one uppercase letter');
    END IF;

    -- Check for at least one lowercase letter
    lower_count := LENGTH(password) - LENGTH(TRANSLATE(password, 'abcdefghijklmnopqrstuvwxyz', ' '));
    IF lower_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Password must contain at least one lowercase letter');
    END IF;

    -- Check for at least one special character
    special_count := LENGTH(password) - LENGTH(TRANSLATE(password, '!@#$%^&*()_+-=[]{}|;:,.<>?', ' '));
    IF special_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Password must contain at least one special character');
    END IF;

    -- Check if new password is different from old password
    IF old_password IS NOT NULL THEN
        differ := LENGTH(old_password) - LENGTH(password);
        IF ABS(differ) < 3 THEN
            IF LENGTH(TRANSLATE(UPPER(password), UPPER(old_password), ' ')) < 3 THEN
                RAISE_APPLICATION_ERROR(-20007, 'New password must differ from old password by at least 3 characters');
            END IF;
        END IF;
    END IF;

    -- Check for common weak passwords
    IF UPPER(password) IN ('PASSWORD', 'PASSWORD123', 'ADMIN123', 'STUDENT123',
                           'LECTURER123', '12345678', 'QWERTY123', 'ABC12345') THEN
        RAISE_APPLICATION_ERROR(-20008, 'Password is too common. Please choose a stronger password');
    END IF;

    RETURN TRUE;
END;
/

-- =============================================
-- Apply profiles to existing users
-- =============================================

-- Apply student profile
ALTER USER GMS_STUDENT PROFILE GMS_STUDENT_PROFILE;

-- Apply lecturer profile
ALTER USER GMS_LECTURER PROFILE GMS_LECTURER_PROFILE;

-- Apply administrative profiles
ALTER USER GMS_ACADEMIC PROFILE GMS_ADMIN_PROFILE;
ALTER USER GMS_DEAN PROFILE GMS_ADMIN_PROFILE;
ALTER USER GMS_DEPT_HEAD PROFILE GMS_ADMIN_PROFILE;

-- Apply relative profile
ALTER USER GMS_RELATIVE PROFILE GMS_RELATIVE_PROFILE;

-- Apply system admin profile
ALTER USER GMS_ADMIN PROFILE GMS_SYSADMIN_PROFILE;

-- =============================================
-- Password History Table for Additional Tracking
-- =============================================
CREATE TABLE PASSWORD_HISTORY (
    user_id VARCHAR2(10),
    username VARCHAR2(50),
    password_hash VARCHAR2(100),
    changed_date DATE DEFAULT SYSDATE,
    changed_by VARCHAR2(50),
    change_reason VARCHAR2(200)
);

CREATE INDEX idx_pwd_history_user ON PASSWORD_HISTORY(user_id, changed_date);

-- Display created profiles
SELECT profile, resource_name, limit
FROM dba_profiles
WHERE profile LIKE 'GMS_%'
ORDER BY profile, resource_name;

COMMIT;
PROMPT ========================================
PROMPT Password profiles configured successfully!
PROMPT ========================================
