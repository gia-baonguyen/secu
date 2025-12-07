@echo off
REM =============================================
REM QUICK START - DEMO HỆ THỐNG
REM =============================================

echo ========================================
echo  GRADE MANAGEMENT SYSTEM - DEMO
echo ========================================
echo.

cd /d "%~dp0"

echo [1/4] Kiểm tra Database...
sqlplus -s sys/123@//localhost:1521/ORCLPDB as sysdba @check_db_quick.sql >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Database có thể chưa setup. Chạy setup database trước:
    echo   cd database
    echo   sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@RUN_ALL.sql"
    echo.
    set /p continue="Tiếp tục chạy Backend và Flutter? (Y/N): "
    if /i not "%continue%"=="Y" exit /b 1
) else (
    echo [OK] Database đang chạy
)
echo.

echo [2/4] Kiểm tra Backend...
curl -s http://localhost:8081/api/actuator/health >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] Backend chưa chạy. Đang khởi động...
    start "Backend Server" cmd /k "cd /d %~dp0backend && mvn spring-boot:run"
    echo [INFO] Đợi 30 giây để backend start...
    timeout /t 30 /nobreak
) else (
    echo [OK] Backend đang chạy
)
echo.

echo [3/4] Kiểm tra Flutter...
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter chưa được cài đặt!
    echo Download: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
) else (
    echo [OK] Flutter đã cài đặt
)
echo.

echo [4/4] Mở Flutter App...
cd flutter_app
start "Flutter App" cmd /k "flutter run"
echo.

echo ========================================
echo  DEMO READY!
echo ========================================
echo.
echo Backend: http://localhost:8081/api
echo Swagger: http://localhost:8081/api/swagger-ui.html
echo.
echo Test Accounts:
echo   Student: STU001 / Student@2024
echo   Lecturer: LEC001 / Lecturer@2024
echo   Dean: DEAN001 / Dean@2024
echo.
pause

