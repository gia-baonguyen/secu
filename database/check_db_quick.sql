-- Quick database check
SELECT 'Database OK' FROM DUAL;
SELECT COUNT(*) as table_count FROM dba_tables WHERE owner = 'GMS_ADMIN';
SELECT COUNT(*) as user_count FROM dba_users WHERE username LIKE 'GMS%';
EXIT;

