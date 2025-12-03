-- =====================================================
-- FIX PASSWORDS FOR TEST USERS
-- Simple demo passwords (BCrypt hashed)
-- =====================================================

CONNECT sys/123@localhost:1521/ORCLPDB AS SYSDBA;

-- Password: student123
-- BCrypt hash generated: $2a$10$YourHashHere
UPDATE GMS_ADMIN.SYSTEM_USERS
SET password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    is_active = 'Y'
WHERE username = 'nvhai';

-- Password: student123
UPDATE GMS_ADMIN.SYSTEM_USERS
SET password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    is_active = 'Y'
WHERE username = 'tthoa';

-- Password: admin123
-- BCrypt hash: $2a$10$...
UPDATE GMS_ADMIN.SYSTEM_USERS
SET password_hash = '$2a$10$EblZqNptyYvchaseFRaqAOXWQ1nwXMSjr37byykLVv0Zy8.5T9G2.',
    is_active = 'Y'
WHERE username = 'admin';

COMMIT;

-- Verify
SELECT username, reference_id, user_type, is_active
FROM GMS_ADMIN.SYSTEM_USERS
WHERE username IN ('nvhai', 'tthoa', 'admin');

EXIT;
