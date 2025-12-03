-- =====================================================
-- PASSWORD POLICY SETUP
-- Enforce strong password requirements
-- =====================================================
-- Demo: Password complexity, expiration, lockout
-- =====================================================

CONNECT sys/123@localhost:1521/ORCLPDB AS SYSDBA;

-- =====================================================
-- STEP 1: CREATE PASSWORD VERIFICATION FUNCTION
-- =====================================================
CREATE OR REPLACE FUNCTION GMS_ADMIN.verify_password
(
    username VARCHAR2,
    password VARCHAR2,
    old_password VARCHAR2
)
RETURN BOOLEAN IS
    n BOOLEAN := FALSE;
    m INTEGER := 0;
    differ INTEGER;
    db_name VARCHAR2(40);
    i INTEGER;
    reverse_user VARCHAR2(32);
BEGIN
    -- Check minimum length (8 characters)
    IF LENGTH(password) < 8 THEN
        raise_application_error(-20001, 'Password must be at least 8 characters');
    END IF;

    -- Check maximum length
    IF LENGTH(password) > 30 THEN
        raise_application_error(-20002, 'Password must not exceed 30 characters');
    END IF;

    -- Check password complexity
    -- Must contain at least one digit
    IF NOT REGEXP_LIKE(password, '[0-9]') THEN
        raise_application_error(-20003, 'Password must contain at least one digit');
    END IF;

    -- Must contain at least one letter
    IF NOT REGEXP_LIKE(password, '[A-Za-z]') THEN
        raise_application_error(-20004, 'Password must contain at least one letter');
    END IF;

    -- Must contain at least one uppercase letter
    IF NOT REGEXP_LIKE(password, '[A-Z]') THEN
        raise_application_error(-20005, 'Password must contain at least one uppercase letter');
    END IF;

    -- Check if password is same as username
    IF UPPER(password) = UPPER(username) THEN
        raise_application_error(-20006, 'Password cannot be the same as username');
    END IF;

    -- Check if password is reverse of username
    reverse_user := REVERSE(username);
    IF UPPER(password) = UPPER(reverse_user) THEN
        raise_application_error(-20007, 'Password cannot be reverse of username');
    END IF;

    -- Check if password contains username
    IF INSTR(UPPER(password), UPPER(username)) > 0 THEN
        raise_application_error(-20008, 'Password cannot contain username');
    END IF;

    -- Check common weak passwords
    IF UPPER(password) IN ('PASSWORD', 'PASSWORD123', 'ADMIN123',
                           'ORACLE', 'ORACLE123', 'WELCOME1',
                           '12345678', 'QWERTY123') THEN
        raise_application_error(-20009, 'Password is too common/weak');
    END IF;

    -- Check if password differs from old password by at least 3 characters
    IF old_password IS NOT NULL THEN
        differ := LENGTH(old_password) - LENGTH(password);
        IF ABS(differ) < 3 THEN
            IF LENGTH(password) < LENGTH(old_password) THEN
                m := LENGTH(password);
            ELSE
                m := LENGTH(old_password);
            END IF;

            differ := ABS(differ);
            FOR i IN 1..m LOOP
                IF SUBSTR(password, i, 1) != SUBSTR(old_password, i, 1) THEN
                    differ := differ + 1;
                END IF;
            END LOOP;

            IF differ < 3 THEN
                raise_application_error(-20010,
                    'New password must differ from old password by at least 3 characters');
            END IF;
        END IF;
    END IF;

    RETURN(TRUE);
END verify_password;
/

PROMPT Password verification function created

-- =====================================================
-- STEP 2: CREATE SECURE PASSWORD PROFILE
-- =====================================================
CREATE PROFILE gms_password_profile LIMIT
    -- Password aging
    PASSWORD_LIFE_TIME 90              -- Password expires in 90 days
    PASSWORD_GRACE_TIME 7              -- 7 days grace period after expiry
    PASSWORD_REUSE_TIME 365            -- Cannot reuse password for 1 year
    PASSWORD_REUSE_MAX UNLIMITED       -- Or never reuse same password

    -- Account lockout
    FAILED_LOGIN_ATTEMPTS 5            -- Lock after 5 failed attempts
    PASSWORD_LOCK_TIME 1/24            -- Lock for 1 hour (1/24 day)

    -- Password verification
    PASSWORD_VERIFY_FUNCTION GMS_ADMIN.verify_password

    -- Session limits
    SESSIONS_PER_USER 3                -- Max 3 concurrent sessions
    IDLE_TIME 60                       -- Disconnect after 60 min idle
    CONNECT_TIME 480;                  -- Max 8 hours per session

PROMPT Secure password profile created

-- =====================================================
-- STEP 3: CREATE DEVELOPMENT PASSWORD PROFILE
-- =====================================================
-- For testing/development: Less restrictive
CREATE PROFILE gms_dev_profile LIMIT
    PASSWORD_LIFE_TIME UNLIMITED
    PASSWORD_GRACE_TIME 7
    PASSWORD_REUSE_TIME UNLIMITED
    PASSWORD_REUSE_MAX UNLIMITED
    FAILED_LOGIN_ATTEMPTS 10
    PASSWORD_LOCK_TIME 1/1440          -- Lock for 1 minute
    PASSWORD_VERIFY_FUNCTION NULL      -- No verification for dev
    SESSIONS_PER_USER UNLIMITED
    IDLE_TIME UNLIMITED
    CONNECT_TIME UNLIMITED;

PROMPT Development profile created

-- =====================================================
-- STEP 4: ASSIGN PROFILES TO USERS
-- =====================================================

-- Admin users: Use secure profile
ALTER USER GMS_ADMIN PROFILE gms_password_profile;

-- App user: Use development profile for demo
ALTER USER GMS_APP PROFILE gms_dev_profile;

-- For production, use secure profile for all:
-- ALTER USER GMS_APP PROFILE gms_password_profile;

PROMPT Profiles assigned to users

-- =====================================================
-- STEP 5: CREATE ACCOUNT MANAGEMENT TABLE
-- =====================================================
CREATE TABLE GMS_ADMIN.USER_ACCOUNT_STATUS (
    user_id VARCHAR2(10) PRIMARY KEY,
    username VARCHAR2(50) NOT NULL,
    is_locked VARCHAR2(1) DEFAULT 'N',
    lock_timestamp TIMESTAMP,
    failed_attempts NUMBER DEFAULT 0,
    last_failed_attempt TIMESTAMP,
    last_successful_login TIMESTAMP,
    password_changed_date DATE DEFAULT SYSDATE,
    password_expiry_date DATE,
    must_change_password VARCHAR2(1) DEFAULT 'N',
    account_status VARCHAR2(20) DEFAULT 'ACTIVE',
    CONSTRAINT chk_locked CHECK (is_locked IN ('Y', 'N')),
    CONSTRAINT chk_must_change CHECK (must_change_password IN ('Y', 'N')),
    CONSTRAINT chk_status CHECK (account_status IN ('ACTIVE', 'LOCKED', 'EXPIRED', 'DISABLED'))
);

COMMENT ON TABLE GMS_ADMIN.USER_ACCOUNT_STATUS IS 'Track user account security status';

PROMPT User account status table created

-- =====================================================
-- STEP 6: CREATE PROCEDURE TO CHECK ACCOUNT STATUS
-- =====================================================
CREATE OR REPLACE PROCEDURE GMS_ADMIN.check_account_status(
    p_username IN VARCHAR2,
    p_is_locked OUT VARCHAR2,
    p_must_change OUT VARCHAR2,
    p_status OUT VARCHAR2
) AS
    v_user_id VARCHAR2(10);
    v_failed_attempts NUMBER;
    v_last_failed TIMESTAMP;
BEGIN
    -- Get user info
    SELECT reference_id INTO v_user_id
    FROM GMS_ADMIN.SYSTEM_USERS
    WHERE username = p_username;

    -- Get or create account status
    BEGIN
        SELECT is_locked, must_change_password, account_status
        INTO p_is_locked, p_must_change, p_status
        FROM GMS_ADMIN.USER_ACCOUNT_STATUS
        WHERE user_id = v_user_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Create initial status
            INSERT INTO GMS_ADMIN.USER_ACCOUNT_STATUS (
                user_id, username, password_expiry_date
            ) VALUES (
                v_user_id, p_username, SYSDATE + 90
            );

            p_is_locked := 'N';
            p_must_change := 'N';
            p_status := 'ACTIVE';
    END;

    -- Check if password expired
    DECLARE
        v_expiry_date DATE;
    BEGIN
        SELECT password_expiry_date INTO v_expiry_date
        FROM GMS_ADMIN.USER_ACCOUNT_STATUS
        WHERE user_id = v_user_id;

        IF v_expiry_date < SYSDATE THEN
            UPDATE GMS_ADMIN.USER_ACCOUNT_STATUS
            SET account_status = 'EXPIRED',
                must_change_password = 'Y'
            WHERE user_id = v_user_id;

            p_status := 'EXPIRED';
            p_must_change := 'Y';
        END IF;
    END;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_is_locked := 'N';
        p_must_change := 'N';
        p_status := 'ACTIVE';
    WHEN OTHERS THEN
        RAISE;
END;
/

PROMPT Account status check procedure created

-- =====================================================
-- STEP 7: CREATE LOGIN ATTEMPT LOGGING
-- =====================================================
CREATE OR REPLACE TRIGGER GMS_ADMIN.trg_login_attempt
AFTER INSERT ON GMS_ADMIN.AUDIT_LOG
FOR EACH ROW
WHEN (NEW.action_type = 'LOGIN')
DECLARE
    v_user_id VARCHAR2(10);
    v_failed_count NUMBER;
BEGIN
    -- Only process login attempts
    IF :NEW.success = 'N' THEN
        -- Failed login
        BEGIN
            SELECT reference_id INTO v_user_id
            FROM GMS_ADMIN.SYSTEM_USERS
            WHERE username = :NEW.username;

            -- Update failed attempts
            UPDATE GMS_ADMIN.USER_ACCOUNT_STATUS
            SET failed_attempts = failed_attempts + 1,
                last_failed_attempt = SYSTIMESTAMP
            WHERE user_id = v_user_id;

            -- Check if should lock
            SELECT failed_attempts INTO v_failed_count
            FROM GMS_ADMIN.USER_ACCOUNT_STATUS
            WHERE user_id = v_user_id;

            IF v_failed_count >= 5 THEN
                UPDATE GMS_ADMIN.USER_ACCOUNT_STATUS
                SET is_locked = 'Y',
                    lock_timestamp = SYSTIMESTAMP,
                    account_status = 'LOCKED'
                WHERE user_id = v_user_id;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
        END;

    ELSIF :NEW.success = 'Y' THEN
        -- Successful login - reset failed attempts
        BEGIN
            SELECT reference_id INTO v_user_id
            FROM GMS_ADMIN.SYSTEM_USERS
            WHERE username = :NEW.username;

            UPDATE GMS_ADMIN.USER_ACCOUNT_STATUS
            SET failed_attempts = 0,
                last_successful_login = SYSTIMESTAMP
            WHERE user_id = v_user_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
        END;
    END IF;

EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

PROMPT Login attempt trigger created

-- =====================================================
-- STEP 8: INITIALIZE ACCOUNT STATUS FOR EXISTING USERS
-- =====================================================
INSERT INTO GMS_ADMIN.USER_ACCOUNT_STATUS (
    user_id, username, password_changed_date, password_expiry_date
)
SELECT
    reference_id,
    username,
    SYSDATE,
    SYSDATE + 90
FROM GMS_ADMIN.SYSTEM_USERS
WHERE NOT EXISTS (
    SELECT 1 FROM GMS_ADMIN.USER_ACCOUNT_STATUS
    WHERE user_id = GMS_ADMIN.SYSTEM_USERS.reference_id
);

COMMIT;

PROMPT Account status initialized

-- =====================================================
-- STEP 9: CREATE VIEW FOR ACCOUNT MONITORING
-- =====================================================
CREATE OR REPLACE VIEW GMS_ADMIN.v_user_security_status AS
SELECT
    u.username,
    u.user_type,
    u.reference_id,
    u.is_active as user_active,
    s.account_status,
    s.is_locked,
    s.failed_attempts,
    s.last_failed_attempt,
    s.last_successful_login,
    s.password_changed_date,
    s.password_expiry_date,
    CASE
        WHEN s.password_expiry_date < SYSDATE THEN 'EXPIRED'
        WHEN s.password_expiry_date < SYSDATE + 7 THEN 'EXPIRING_SOON'
        ELSE 'VALID'
    END as password_status,
    s.must_change_password
FROM GMS_ADMIN.SYSTEM_USERS u
LEFT JOIN GMS_ADMIN.USER_ACCOUNT_STATUS s ON u.reference_id = s.user_id
ORDER BY u.username;

GRANT SELECT ON GMS_ADMIN.v_user_security_status TO GMS_APP;

PROMPT Security status view created

-- =====================================================
-- STEP 10: CREATE UNLOCK PROCEDURE
-- =====================================================
CREATE OR REPLACE PROCEDURE GMS_ADMIN.unlock_user_account(
    p_username IN VARCHAR2
) AS
    v_user_id VARCHAR2(10);
BEGIN
    SELECT reference_id INTO v_user_id
    FROM GMS_ADMIN.SYSTEM_USERS
    WHERE username = p_username;

    UPDATE GMS_ADMIN.USER_ACCOUNT_STATUS
    SET is_locked = 'N',
        lock_timestamp = NULL,
        failed_attempts = 0,
        account_status = 'ACTIVE'
    WHERE user_id = v_user_id;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('User ' || p_username || ' unlocked successfully');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        raise_application_error(-20011, 'User not found: ' || p_username);
    WHEN OTHERS THEN
        RAISE;
END;
/

PROMPT Unlock procedure created

-- =====================================================
-- VERIFY PASSWORD POLICY SETUP
-- =====================================================
PROMPT =====================================================
PROMPT Checking Password Policy Configuration...
PROMPT =====================================================

-- Check profiles
SELECT profile, resource_name, limit
FROM dba_profiles
WHERE profile IN ('GMS_PASSWORD_PROFILE', 'GMS_DEV_PROFILE')
ORDER BY profile, resource_name;

-- Check user profiles
SELECT username, profile, account_status
FROM dba_users
WHERE username IN ('GMS_ADMIN', 'GMS_APP');

-- Check account status
SELECT * FROM GMS_ADMIN.v_user_security_status;

PROMPT =====================================================
PROMPT Password Policy Setup Complete!
PROMPT =====================================================
PROMPT Components created:
PROMPT   - Password verification function
PROMPT   - Secure password profile (90-day expiry, 5 attempts)
PROMPT   - Development profile (for testing)
PROMPT   - Account status tracking table
PROMPT   - Login attempt monitoring trigger
PROMPT   - Account unlock procedure
PROMPT =====================================================
PROMPT
PROMPT To unlock a locked account:
PROMPT   EXEC GMS_ADMIN.unlock_user_account('username');
PROMPT
PROMPT To check password policy:
PROMPT   SELECT * FROM GMS_ADMIN.v_user_security_status;
PROMPT =====================================================

EXIT;
