@echo off
REM Script to connect as GMS_STUDENT user
echo Connecting to Oracle as GMS_STUDENT...
echo.
echo After connected, you can run:
echo   EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');
echo   SELECT COUNT(*) FROM gms_admin.STUDENTS;
echo.

sqlplus GMS_STUDENT/Student@2024@ngbao:1521/orclpdb
