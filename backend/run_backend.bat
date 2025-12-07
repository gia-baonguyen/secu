@echo off
REM =============================================
REM Run Backend Application
REM =============================================

echo ========================================
echo Starting Backend Application...
echo ========================================
echo.

cd /d "%~dp0"

REM Check if Maven is installed
where mvn >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Maven is not installed!
    echo.
    echo Please install Maven first:
    echo 1. Download from: https://maven.apache.org/download.cgi
    echo 2. Extract to C:\Program Files\Apache\maven
    echo 3. Add C:\Program Files\Apache\maven\bin to PATH
    echo.
    echo Or use Chocolatey: choco install maven
    echo.
    pause
    exit /b 1
)

echo [INFO] Maven found
mvn -version
echo.

REM Check if Java is installed
java -version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Java is not installed!
    pause
    exit /b 1
)

echo [INFO] Java found
java -version
echo.

echo ========================================
echo Building and starting application...
echo ========================================
echo.

REM Build and run
mvn clean spring-boot:run

pause

