# =============================================
# API Testing Script
# Test all endpoints from localhost:8081
# =============================================

$baseUrl = "http://localhost:8081/api"
$headers = @{
    "Content-Type" = "application/json"
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "API TESTING - Grade Management System" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Health Check
Write-Host "[1] Testing Actuator Health..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/actuator/health" -Method Get
    Write-Host "SUCCESS: Status = $($response.status)" -ForegroundColor Green
    if ($response.components.db) {
        Write-Host "  Database: $($response.components.db.status)" -ForegroundColor Gray
    }
} catch {
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 2: Auth Health
Write-Host "[2] Testing Auth Health..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/health" -Method Get
    Write-Host "SUCCESS: $($response.message)" -ForegroundColor Green
    Write-Host "  Data: $($response.data)" -ForegroundColor Gray
} catch {
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 3: Database Connection
Write-Host "[3] Testing Database Connection..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/test/db-connection" -Method Get
    Write-Host "SUCCESS: $($response.status)" -ForegroundColor Green
    Write-Host "  Message: $($response.message)" -ForegroundColor Gray
    Write-Host "  Tables: $($response.tables_count)" -ForegroundColor Gray
    Write-Host "  Students: $($response.students_count)" -ForegroundColor Gray
    Write-Host "  Grades: $($response.grades_count)" -ForegroundColor Gray
    Write-Host "  Database: $($response.database_name)" -ForegroundColor Gray
    Write-Host "  User: $($response.current_user)" -ForegroundColor Gray
} catch {
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "  Response: $responseBody" -ForegroundColor Red
    }
}
Write-Host ""

# Test 4: Login
Write-Host "[4] Testing Login..." -ForegroundColor Yellow
Write-Host "  Note: This requires a user in SYSTEM_USERS table" -ForegroundColor Gray
Write-Host "  Trying with username: nvhai (Student)" -ForegroundColor Gray

$loginBody = @{
    username = "nvhai"
    password = "password123"
} | ConvertTo-Json

$global:token = $null
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -Headers $headers
    Write-Host "SUCCESS: Login successful!" -ForegroundColor Green
    Write-Host "  User ID: $($response.data.userId)" -ForegroundColor Gray
    Write-Host "  Role: $($response.data.role)" -ForegroundColor Gray
    $tokenPreview = $response.data.accessToken.Substring(0, [Math]::Min(50, $response.data.accessToken.Length))
    Write-Host "  Token: $tokenPreview..." -ForegroundColor Gray
    
    $global:token = $response.data.accessToken
    Write-Host "  Token saved for next requests" -ForegroundColor Gray
} catch {
    Write-Host "FAILED: Login failed" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "  Response: $responseBody" -ForegroundColor Red
    }
    Write-Host "  Note: You may need to create users in SYSTEM_USERS table first" -ForegroundColor Yellow
}
Write-Host ""

# Test 5: Get Profile (if token exists)
if ($global:token) {
    Write-Host "[5] Testing Get Profile..." -ForegroundColor Yellow
    $authHeaders = $headers.Clone()
    $authHeaders["Authorization"] = "Bearer $global:token"
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/auth/profile" -Method Get -Headers $authHeaders
        Write-Host "SUCCESS: Profile retrieved!" -ForegroundColor Green
        Write-Host "  User ID: $($response.data.userId)" -ForegroundColor Gray
        Write-Host "  Username: $($response.data.username)" -ForegroundColor Gray
        Write-Host "  Role: $($response.data.role)" -ForegroundColor Gray
        
        $userRole = $response.data.role
        
        # Test 6: Student Endpoints (if role is STUDENT)
        if ($userRole -eq "STUDENT") {
            Write-Host ""
            Write-Host "[6] Testing Student Endpoints..." -ForegroundColor Yellow
            
            # Get My Profile
            try {
                $studentResponse = Invoke-RestMethod -Uri "$baseUrl/students/me" -Method Get -Headers $authHeaders
                Write-Host "SUCCESS: Get My Profile" -ForegroundColor Green
                Write-Host "  Student ID: $($studentResponse.data.studentId)" -ForegroundColor Gray
            } catch {
                Write-Host "FAILED: Get My Profile - $($_.Exception.Message)" -ForegroundColor Red
            }
            
            # Get My Grades
            try {
                $gradesResponse = Invoke-RestMethod -Uri "$baseUrl/students/me/grades" -Method Get -Headers $authHeaders
                $gradeCount = if ($gradesResponse.data) { $gradesResponse.data.Count } else { 0 }
                Write-Host "SUCCESS: Get My Grades ($gradeCount grades)" -ForegroundColor Green
            } catch {
                Write-Host "FAILED: Get My Grades - $($_.Exception.Message)" -ForegroundColor Red
            }
            
            # Get My GPA
            try {
                $gpaResponse = Invoke-RestMethod -Uri "$baseUrl/students/me/gpa" -Method Get -Headers $authHeaders
                Write-Host "SUCCESS: Get My GPA" -ForegroundColor Green
            } catch {
                Write-Host "FAILED: Get My GPA - $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    } catch {
        Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""
}

# Test 7: Swagger UI
Write-Host "[7] Swagger UI Available:" -ForegroundColor Yellow
Write-Host "  URL: $baseUrl/swagger-ui.html" -ForegroundColor Cyan
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "API Testing Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
