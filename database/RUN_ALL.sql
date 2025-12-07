-- =============================================
-- RUN ALL - Complete Database Setup & Maintenance
-- =============================================
-- This script runs everything from scratch:
-- 1. Complete database setup (SETUP_ALL.sql)
-- 2. Grant test privileges
-- 3. Run maintenance scripts (fixes all common issues)
-- =============================================
-- Usage:
--   cd D:\BaoMatHTTT\secu\database
--   sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@RUN_ALL.sql"
-- =============================================

SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON

ALTER SESSION SET CONTAINER = ORCLPDB;

PROMPT ========================================
PROMPT RUN ALL - Complete Setup & Maintenance
PROMPT ========================================
PROMPT
PROMPT This script will:
PROMPT   1. Run complete database setup (SETUP_ALL.sql)
PROMPT   2. Grant test privileges
PROMPT   3. Run maintenance scripts (fix all issues)
PROMPT ========================================
PROMPT

-- =============================================
-- STEP 1: COMPLETE DATABASE SETUP
-- =============================================
PROMPT
PROMPT [STEP 1/3] Running complete database setup...
PROMPT ========================================
@@SETUP_ALL.sql

PROMPT
PROMPT Database setup completed!
PROMPT

-- =============================================
-- STEP 2: GRANT TEST PRIVILEGES
-- =============================================
PROMPT
PROMPT [STEP 2/3] Granting test privileges...
PROMPT ========================================
@@04-tests/00_grant_test_privileges.sql

PROMPT
PROMPT Test privileges granted!
PROMPT

-- =============================================
-- STEP 3: RUN MAINTENANCE SCRIPTS
-- =============================================
PROMPT
PROMPT [STEP 3/3] Running maintenance scripts...
PROMPT ========================================
@@scripts/MAINTENANCE_SCRIPTS.sql

PROMPT
PROMPT ========================================
PROMPT ALL STEPS COMPLETED!
PROMPT ========================================
PROMPT
PROMPT Database is ready to use!
PROMPT
PROMPT Next steps:
PROMPT   1. Start backend: cd ..\backend && mvn spring-boot:run
PROMPT   2. Start Flutter app: cd ..\flutter_app && flutter run
PROMPT   3. Test login with: nvhai / password123
PROMPT ========================================

COMMIT;

