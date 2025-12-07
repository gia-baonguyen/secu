@echo off
REM =============================================
REM Run All Database Tests
REM =============================================

echo ========================================
echo Running Database Tests...
echo ========================================
echo.

cd /d "%~dp0"
sqlplus -s sys/oracle@//localhost:1521/ORCLPDB as sysdba @RUN_ALL_TESTS.sql

echo.
echo ========================================
echo Tests completed!
echo ========================================
pause

