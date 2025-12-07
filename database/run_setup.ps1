# PowerShell script to run SETUP_ALL.sql
# Usage: .\run_setup.ps1

# Set Oracle password (change if needed)
$ORACLE_PASSWORD = "123"
$ORACLE_HOST = "localhost"
$ORACLE_PORT = "1521"
$ORACLE_PDB = "ORCLPDB"

# Get current directory
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$SETUP_SCRIPT = Join-Path $SCRIPT_DIR "SETUP_ALL.sql"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Running Oracle Database Setup" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Script: $SETUP_SCRIPT" -ForegroundColor Yellow
Write-Host ""

# Check if script exists
if (-not (Test-Path $SETUP_SCRIPT)) {
    Write-Host "ERROR: SETUP_ALL.sql not found at $SETUP_SCRIPT" -ForegroundColor Red
    exit 1
}

# Build SQL*Plus command
# Note: Use quotes around the script path to avoid PowerShell @ splatting issue
$SQLPLUS_CMD = "sqlplus sys/$ORACLE_PASSWORD@//$ORACLE_HOST`:$ORACLE_PORT/$ORACLE_PDB as sysdba `"@$SETUP_SCRIPT`""

Write-Host "Executing: $SQLPLUS_CMD" -ForegroundColor Green
Write-Host ""

# Run SQL*Plus
Invoke-Expression $SQLPLUS_CMD

# Check exit code
if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "Setup completed successfully!" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Red
    Write-Host "Setup failed with exit code: $LASTEXITCODE" -ForegroundColor Red
    Write-Host "Check setup_all.log for details" -ForegroundColor Red
    Write-Host "=========================================" -ForegroundColor Red
    exit $LASTEXITCODE
}

