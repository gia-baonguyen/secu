@echo off
REM Batch script to run SETUP_ALL.sql
REM Usage: run_setup.bat

echo =========================================
echo Running Oracle Database Setup
echo =========================================
echo.

REM Set Oracle connection details
set ORACLE_PASSWORD=123
set ORACLE_HOST=localhost
set ORACLE_PORT=1521
set ORACLE_PDB=ORCLPDB

REM Get current directory
set SCRIPT_DIR=%~dp0
set SETUP_SCRIPT=%SCRIPT_DIR%SETUP_ALL.sql

echo Script: %SETUP_SCRIPT%
echo.

REM Check if script exists
if not exist "%SETUP_SCRIPT%" (
    echo ERROR: SETUP_ALL.sql not found at %SETUP_SCRIPT%
    exit /b 1
)

REM Run SQL*Plus
sqlplus sys/%ORACLE_PASSWORD%@//%ORACLE_HOST%:%ORACLE_PORT%/%ORACLE_PDB% as sysdba @%SETUP_SCRIPT%

REM Check exit code
if %ERRORLEVEL% EQU 0 (
    echo.
    echo =========================================
    echo Setup completed successfully!
    echo =========================================
) else (
    echo.
    echo =========================================
    echo Setup failed with exit code: %ERRORLEVEL%
    echo Check setup_all.log for details
    echo =========================================
    exit /b %ERRORLEVEL%
)

