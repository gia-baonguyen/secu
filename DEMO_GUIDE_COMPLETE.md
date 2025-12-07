# 🎯 HƯỚNG DẪN DEMO HỆ THỐNG - COMPLETE GUIDE

> **Version**: 1.0  
> **Last Updated**: December 2024  
> **Hệ thống**: University Grade Management System với VPD, OLS, FGA

---

## 📋 MỤC LỤC

1. [Kiểm tra hệ thống còn thiếu gì](#1-kiểm-tra-hệ-thống-còn-thiếu-gì)
2. [Chuẩn bị môi trường](#2-chuẩn-bị-môi-trường)
3. [Setup Database](#3-setup-database)
4. [Chạy Backend](#4-chạy-backend)
5. [Chạy Flutter App](#5-chạy-flutter-app)
6. [Demo các tính năng](#6-demo-các-tính-năng)
7. [Troubleshooting](#7-troubleshooting)

---

## 1. KIỂM TRA HỆ THỐNG CÒN THIẾU GÌ

### ✅ Đã hoàn thành

| Component                | Status      | Files                                                                                                                      |
| ------------------------ | ----------- | -------------------------------------------------------------------------------------------------------------------------- |
| **Database**             | ✅ Complete | 14 tables, VPD policies, FGA, OLS, Password profiles                                                                       |
| **Backend Entities**     | ✅ Complete | 14 entities (Student, Lecturer, Grade, Course, Relative, AuditLog, etc.)                                                   |
| **Backend Repositories** | ✅ Complete | 14 repositories                                                                                                            |
| **Backend Services**     | ✅ Complete | 13 services                                                                                                                |
| **Backend Controllers**  | ✅ Complete | 13 controllers (Student, Lecturer, Admin, Dean, DepartmentHead, AcademicAffairs, Relative, Course, Deadline, ExamQuestion) |
| **Flutter Models**       | ✅ Complete | All models (Student, Lecturer, Grade, Relative, Course, Deadline, AuditLog, ExamQuestion)                                  |
| **Flutter API Service**  | ✅ Complete | All API methods for all roles                                                                                              |
| **Flutter Screens**      | ✅ Complete | All role-specific screens + Profile for all roles                                                                          |

### ⚠️ Cần kiểm tra

1. **Database Connection**: Backend đang dùng `GMS_LECTURER` nhưng nên dùng `GMS_APP` (Single DB User approach)
2. **Flutter main.dart**: Cần kiểm tra có đầy đủ providers và routing không
3. **CORS Configuration**: Backend cần allow Flutter app origin

---

## 2. CHUẨN BỊ MÔI TRƯỜNG

### 2.1 Yêu cầu hệ thống

| Component                    | Version | Status                          |
| ---------------------------- | ------- | ------------------------------- |
| **Oracle Database**          | 19c+    | ✅ Cần có ORCLPDB running       |
| **Java**                     | 17+     | ✅ Kiểm tra: `java -version`    |
| **Maven**                    | 3.8+    | ⚠️ Cần cài: `mvn -version`      |
| **Flutter**                  | 3.0+    | ⚠️ Cần cài: `flutter --version` |
| **Android Studio / VS Code** | Latest  | ⚠️ Cần cài để chạy Flutter      |

### 2.2 Kiểm tra Oracle Database

```bash
# Kiểm tra Oracle service đang chạy
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba

# Nếu kết nối thành công → Database OK
# Nếu lỗi → Cần start Oracle service
```

### 2.3 Kiểm tra Java

```bash
java -version
# Expected: Java 17 hoặc cao hơn
```

### 2.4 Kiểm tra Maven

```bash
mvn -version
# Nếu không có → Cần cài Maven
# Download: https://maven.apache.org/download.cgi
```

### 2.5 Kiểm tra Flutter

```bash
flutter --version
flutter doctor
# Nếu chưa cài → Download: https://flutter.dev/docs/get-started/install
```

---

## 3. SETUP DATABASE

### 3.1 Chạy Setup Database (Lần đầu)

**Option 1: Chạy tất cả từ đầu (Khuyến nghị)**

```powershell
cd D:\BaoMatHTTT\secu\database
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@RUN_ALL.sql"
```

Script này sẽ:

- ✅ Tạo 8 Oracle users
- ✅ Tạo 14 tables
- ✅ Setup VPD policies
- ✅ Setup FGA audit
- ✅ Setup Password profiles
- ✅ Insert sample data
- ✅ Fix tất cả issues

**Option 2: Chạy từng bước**

```powershell
cd D:\BaoMatHTTT\secu\database

# Step 1: Create users
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@01-schema/step1_create_users.sql"

# Step 2: Create tables (as GMS_ADMIN)
sqlplus GMS_ADMIN/Admin@2024#Secure@//localhost:1521/ORCLPDB "@01-schema/step2_create_tables.sql"

# Step 3: Password profiles (as SYSDBA)
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@02-security/step3_password_profiles.sql"

# Step 4: VPD policies (as GMS_ADMIN)
sqlplus GMS_ADMIN/Admin@2024#Secure@//localhost:1521/ORCLPDB "@02-security/step4_vpd_policies.sql"

# Step 5: Audit policies (as GMS_ADMIN)
sqlplus GMS_ADMIN/Admin@2024#Secure@//localhost:1521/ORCLPDB "@02-security/step5_audit_policies.sql"

# Step 6: Sample data (as GMS_ADMIN)
sqlplus GMS_ADMIN/Admin@2024#Secure@//localhost:1521/ORCLPDB "@03-data/step6_sample_data.sql"
```

### 3.2 Verify Database Setup

```sql
-- Kiểm tra users
SELECT username, account_status FROM dba_users WHERE username LIKE 'GMS%';

-- Kiểm tra tables
SELECT COUNT(*) FROM dba_tables WHERE owner = 'GMS_ADMIN';
-- Expected: 14 tables

-- Kiểm tra VPD policies
SELECT policy_name, object_name FROM dba_policies WHERE object_owner = 'GMS_ADMIN';
-- Expected: 6 policies

-- Kiểm tra sample data
SELECT COUNT(*) FROM GMS_ADMIN.STUDENTS;
SELECT COUNT(*) FROM GMS_ADMIN.GRADES;
SELECT COUNT(*) FROM GMS_ADMIN.SYSTEM_USERS;
```

### 3.3 Fix Backend Connection (Nếu cần)

Backend cần dùng `GMS_APP` user (Single DB User approach):

```sql
-- Kiểm tra GMS_APP đã có chưa
SELECT username, account_status FROM dba_users WHERE username = 'GMS_APP';

-- Nếu chưa có, tạo user (trong step1_create_users.sql đã có)
-- Nếu có rồi, kiểm tra permissions:
SELECT * FROM dba_role_privs WHERE grantee = 'GMS_APP';
-- Expected: CONNECT, RESOURCE roles

-- Grant permissions nếu thiếu
GRANT CONNECT, RESOURCE TO GMS_APP;
GRANT SELECT, INSERT, UPDATE, DELETE ON GMS_ADMIN.STUDENTS TO GMS_APP;
GRANT SELECT, INSERT, UPDATE, DELETE ON GMS_ADMIN.GRADES TO GMS_APP;
-- ... (grant cho tất cả tables)
```

---

## 4. CHẠY BACKEND

### 4.1 Cấu hình Database Connection

**File**: `secu/backend/src/main/resources/application.properties`

```properties
# Database Configuration
spring.datasource.url=jdbc:oracle:thin:@//localhost:1521/ORCLPDB
spring.datasource.username=GMS_APP
spring.datasource.password=App@2024#Connect
spring.datasource.driver-class-name=oracle.jdbc.OracleDriver

# Server Configuration
server.port=8081
server.servlet.context-path=/api
```

**Lưu ý**:

- Port: `8081` (không phải 8080)
- Context path: `/api`
- Username: `GMS_APP` (Single DB User approach)

### 4.2 Chạy Backend

**Option 1: Dùng Maven (Khuyến nghị)**

```bash
cd D:\BaoMatHTTT\secu\backend
mvn clean spring-boot:run
```

**Option 2: Dùng Batch file**

```bash
cd D:\BaoMatHTTT\secu\backend
.\run_backend.bat
```

**Option 3: Dùng VS Code Spring Boot Extension**

1. Mở VS Code trong thư mục `secu/backend`
2. Cài "Spring Boot Extension Pack"
3. Mở Spring Boot Dashboard
4. Click Run trên `grade-management-system`

### 4.3 Verify Backend Running

**Kiểm tra Health:**

```bash
curl http://localhost:8081/api/actuator/health
```

**Expected Response:**

```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP",
      "details": {
        "database": "Oracle"
      }
    }
  }
}
```

**Kiểm tra Swagger UI:**

Mở browser: http://localhost:8081/api/swagger-ui.html

**Kiểm tra API:**

```bash
# Test login endpoint
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"STU001\",\"password\":\"Student@2024\"}"
```

### 4.4 Troubleshooting Backend

**Lỗi: Cannot connect to database**

```bash
# 1. Kiểm tra Oracle service đang chạy
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba

# 2. Kiểm tra GMS_APP user
sqlplus GMS_APP/App@2024#Connect@//localhost:1521/ORCLPDB

# 3. Kiểm tra permissions
SELECT * FROM dba_role_privs WHERE grantee = 'GMS_APP';
```

**Lỗi: Port 8081 already in use**

```bash
# Windows: Tìm process đang dùng port 8081
netstat -ano | findstr :8081

# Kill process
taskkill /PID <PID> /F

# Hoặc đổi port trong application.properties
server.port=8082
```

---

## 5. CHẠY FLUTTER APP

### 5.1 Cấu hình API Base URL

**File**: `secu/flutter_app/lib/services/api_service.dart`

```dart
static String get baseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8081/api';  // Android emulator
  } else {
    return 'http://localhost:8081/api';  // iOS simulator / Web
  }
}
```

**Lưu ý**:

- Port: `8081` (phải khớp với backend)
- Android emulator: Dùng `10.0.2.2` thay vì `localhost`
- Physical device: Dùng IP máy tính (ví dụ: `http://192.168.1.100:8081/api`)

### 5.2 Chạy Flutter App

**Option 1: Dùng VS Code**

1. Mở VS Code trong thư mục `secu/flutter_app`
2. Cài Flutter extension
3. Chọn device (emulator hoặc physical device)
4. Nhấn `F5` hoặc click Run

**Option 2: Dùng Command Line**

```bash
cd D:\BaoMatHTTT\secu\flutter_app

# Kiểm tra devices
flutter devices

# Chạy app
flutter run

# Hoặc chạy trên device cụ thể
flutter run -d <device-id>
```

**Option 3: Dùng Android Studio**

1. Mở Android Studio
2. File → Open → Chọn `secu/flutter_app`
3. Chọn device
4. Click Run

### 5.3 Verify Flutter App

1. App khởi động → Hiển thị Login Screen
2. Test login với:
   - Username: `STU001`, Password: `Student@2024`
   - Username: `LEC001`, Password: `Lecturer@2024`
   - Username: `DEAN001`, Password: `Dean@2024`

### 5.4 Troubleshooting Flutter

**Lỗi: Connection refused**

```dart
// Kiểm tra baseUrl trong api_service.dart
// Android emulator: http://10.0.2.2:8081/api
// iOS simulator: http://localhost:8081/api
// Physical device: http://<your-computer-ip>:8081/api
```

**Lỗi: CORS error**

```java
// Backend: SecurityConfig.java
// Đảm bảo CORS cho phép Flutter origin
@Bean
public CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration configuration = new CorsConfiguration();
    configuration.setAllowedOrigins(Arrays.asList("*")); // Hoặc specific origins
    configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
    configuration.setAllowedHeaders(Arrays.asList("*"));
    configuration.setAllowCredentials(true);
    // ...
}
```

---

## 6. DEMO CÁC TÍNH NĂNG

### 6.1 Demo VPD Policies

#### Demo 1: Student chỉ xem được điểm của mình

**Bước 1: Login as Student**

```
Username: STU001
Password: Student@2024
```

**Bước 2: Xem Grades**

- Vào tab "Grades"
- Chỉ thấy điểm của STU001
- Không thấy điểm của STU002, STU003

**Bước 3: Verify trong Database**

```sql
-- Set context
EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');

-- Query grades
SELECT * FROM gms_admin.GRADES;
-- Chỉ thấy grades của STU001
```

#### Demo 2: Lecturer xem sinh viên lớp chủ nhiệm + môn dạy

**Bước 1: Login as Lecturer**

```
Username: LEC001
Password: Lecturer@2024
```

**Bước 2: Xem Students**

- Vào tab "Students"
- Thấy sinh viên lớp chủ nhiệm (nếu có)
- Thấy sinh viên đăng ký môn LEC001 dạy

**Bước 3: Xem và Update Grades**

- Click vào một student
- Xem điểm của student đó
- Có thể update điểm (nếu trước deadline)

#### Demo 3: Dean xem toàn bộ khoa

**Bước 1: Login as Dean**

```
Username: DEAN001
Password: Dean@2024
```

**Bước 2: Xem Dashboard**

- Vào tab "Dashboard"
- Thấy statistics: Students, Lecturers, Grades trong khoa
- Chỉ thấy data của khoa mình quản lý

#### Demo 4: Academic Affairs - Full Access

**Bước 1: Login as Academic Affairs**

```
Username: AA001
Password: Academic@2024
```

**Bước 2: Xem Dashboard**

- Thấy tất cả students, lecturers, grades
- Có thể update grade sau deadline
- Có thể approve grades
- Xem audit logs

### 6.2 Demo OLS (Oracle Label Security)

#### Demo 1: Student chỉ xem được PUBLIC questions

**Bước 1: Login as Student**

```
Username: STU001
Password: Student@2024
```

**Bước 2: Xem Exam Questions**

- Vào "Exam Questions" từ Home
- Chỉ thấy questions với label "PUB"
- Không thấy "INT:CS" hoặc "CONF:CS"

#### Demo 2: Lecturer xem PUBLIC + INTERNAL

**Bước 1: Login as Lecturer**

```
Username: LEC001
Password: Lecturer@2024
```

**Bước 2: Xem Exam Questions**

- Thấy "PUB" và "INT:CS" questions
- Không thấy "CONF:CS" (confidential)

#### Demo 3: Dean xem tất cả (kể cả CONFIDENTIAL)

**Bước 1: Login as Dean**

```
Username: DEAN001
Password: Dean@2024
```

**Bước 2: Xem Exam Questions**

- Thấy tất cả: PUB, INT:CS, CONF:CS

### 6.3 Demo Audit Logging

**Bước 1: Login as Academic Affairs**

```
Username: AA001
Password: Academic@2024
```

**Bước 2: Xem Audit Logs**

- Vào Dashboard → Tab "Audit Logs"
- Thấy tất cả operations: INSERT, UPDATE, DELETE, SELECT
- Filter theo table, user, date

**Bước 3: Test Audit**

- Update một grade
- Xem audit log mới xuất hiện trong list

### 6.4 Demo Profile Update

**Bước 1: Login as Student/Lecturer/Relative**

```
Username: STU001 / LEC001 / REL001
Password: Student@2024 / Lecturer@2024 / Relative@2024
```

**Bước 2: Update Profile**

- Vào tab "Profile"
- Click "Update Profile"
- Update email, phone, address
- Save → Thấy thông báo thành công

### 6.5 Demo Grade Management

**Bước 1: Login as Lecturer**

```
Username: LEC001
Password: Lecturer@2024
```

**Bước 2: View Students**

- Vào "Students" tab
- Click vào một student
- Xem grades của student

**Bước 3: Update Grade**

- Click icon edit trên grade card
- Update midterm_score, final_score
- Save → Grade được update

**Bước 4: Verify Deadline**

- Nếu sau deadline → Lecturer không thể update
- Chỉ Academic Affairs có thể update sau deadline

---

## 7. TROUBLESHOOTING

### 7.1 Database Issues

**Lỗi: ORA-01017 invalid username/password**

```sql
-- Kiểm tra user
SELECT username, account_status FROM dba_users WHERE username = 'GMS_APP';

-- Reset password nếu cần
ALTER USER GMS_APP IDENTIFIED BY "App@2024#Connect";
```

**Lỗi: ORA-00942 table or view does not exist**

```sql
-- Kiểm tra tables
SELECT table_name FROM dba_tables WHERE owner = 'GMS_ADMIN';

-- Nếu thiếu, chạy lại:
@01-schema/step2_create_tables.sql
```

**Lỗi: ORA-28113 policy predicate has error**

```sql
-- Kiểm tra VPD policies
SELECT policy_name, object_name, function FROM dba_policies WHERE object_owner = 'GMS_ADMIN';

-- Test policy function
EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');
SELECT gms_admin.gms_security_pkg.student_policy('GMS_ADMIN', 'STUDENTS') FROM DUAL;
```

### 7.2 Backend Issues

**Lỗi: Port already in use**

```bash
# Windows: Tìm và kill process
netstat -ano | findstr :8081
taskkill /PID <PID> /F

# Hoặc đổi port
# application.properties: server.port=8082
```

**Lỗi: Cannot connect to database**

```bash
# 1. Kiểm tra Oracle service
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba

# 2. Kiểm tra GMS_APP
sqlplus GMS_APP/App@2024#Connect@//localhost:1521/ORCLPDB

# 3. Kiểm tra application.properties
# spring.datasource.url=jdbc:oracle:thin:@//localhost:1521/ORCLPDB
# spring.datasource.username=GMS_APP
# spring.datasource.password=App@2024#Connect
```

**Lỗi: Maven not found**

```bash
# Download Maven: https://maven.apache.org/download.cgi
# Extract to C:\Program Files\Apache\maven
# Add to PATH: C:\Program Files\Apache\maven\bin
# Restart terminal
mvn -version
```

### 7.3 Flutter Issues

**Lỗi: Connection refused**

```dart
// Kiểm tra baseUrl
// Android emulator: http://10.0.2.2:8081/api
// iOS simulator: http://localhost:8081/api
// Physical device: http://<your-ip>:8081/api

// Kiểm tra backend đang chạy
curl http://localhost:8081/api/actuator/health
```

**Lỗi: CORS error**

```java
// Backend: SecurityConfig.java
// Đảm bảo CORS cho phép tất cả origins hoặc Flutter origin cụ thể
```

**Lỗi: Flutter not found**

```bash
# Download Flutter: https://flutter.dev/docs/get-started/install
# Add to PATH
# Restart terminal
flutter --version
flutter doctor
```

---

## 8. QUICK REFERENCE

### 8.1 Test Accounts

| Role             | Username | Password      | User ID  |
| ---------------- | -------- | ------------- | -------- |
| Student          | STU001   | Student@2024  | STU001   |
| Lecturer         | LEC001   | Lecturer@2024 | LEC001   |
| Dean             | DEAN001  | Dean@2024     | DEAN001  |
| Department Head  | DH001    | DeptHead@2024 | DH001    |
| Academic Affairs | AA001    | Academic@2024 | AA001    |
| Relative         | REL001   | Relative@2024 | REL001   |
| Admin            | ADMIN001 | Admin@2024    | ADMIN001 |

### 8.2 Important URLs

| Service      | URL                                       |
| ------------ | ----------------------------------------- |
| Backend API  | http://localhost:8081/api                 |
| Swagger UI   | http://localhost:8081/api/swagger-ui.html |
| Health Check | http://localhost:8081/api/actuator/health |
| Flutter App  | Chạy trên emulator/device                 |

### 8.3 Database Connection Strings

| Purpose               | Connection String                                              |
| --------------------- | -------------------------------------------------------------- |
| SQL\*Plus (SYSDBA)    | `sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba`           |
| SQL\*Plus (GMS_ADMIN) | `sqlplus GMS_ADMIN/Admin@2024#Secure@//localhost:1521/ORCLPDB` |
| SQL\*Plus (GMS_APP)   | `sqlplus GMS_APP/App@2024#Connect@//localhost:1521/ORCLPDB`    |
| JDBC URL              | `jdbc:oracle:thin:@//localhost:1521/ORCLPDB`                   |

### 8.4 Key Files

| File                                                | Purpose               |
| --------------------------------------------------- | --------------------- |
| `database/RUN_ALL.sql`                              | Setup database từ đầu |
| `database/SETUP_ALL.sql`                            | Setup database chính  |
| `database/scripts/MAINTENANCE_SCRIPTS.sql`          | Fix issues            |
| `backend/src/main/resources/application.properties` | Backend config        |
| `backend/run_backend.bat`                           | Chạy backend          |
| `flutter_app/lib/services/api_service.dart`         | Flutter API config    |
| `flutter_app/lib/main.dart`                         | Flutter entry point   |

---

## 9. DEMO SCRIPT - TỰ ĐỘNG

Tạo file `demo_complete.bat` để chạy demo tự động:

```batch
@echo off
echo ========================================
echo DEMO HỆ THỐNG GRADE MANAGEMENT
echo ========================================
echo.

echo [1/3] Kiểm tra Database...
sqlplus -s sys/123@//localhost:1521/ORCLPDB as sysdba @check_db.sql
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Database không kết nối được!
    pause
    exit /b 1
)
echo [OK] Database đang chạy
echo.

echo [2/3] Kiểm tra Backend...
curl -s http://localhost:8081/api/actuator/health >nul
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Backend chưa chạy. Đang khởi động...
    start cmd /k "cd /d D:\BaoMatHTTT\secu\backend && mvn spring-boot:run"
    timeout /t 30
)
echo [OK] Backend đang chạy
echo.

echo [3/3] Mở Flutter App...
cd /d D:\BaoMatHTTT\secu\flutter_app
flutter run
```

---

## 10. CHECKLIST TRƯỚC KHI DEMO

- [ ] Oracle Database đang chạy
- [ ] Database đã setup (chạy RUN_ALL.sql)
- [ ] Backend đang chạy (port 8081)
- [ ] Backend kết nối được database
- [ ] Flutter app đã build
- [ ] Flutter app kết nối được backend
- [ ] Test accounts hoạt động
- [ ] VPD policies hoạt động (test với SQL\*Plus)
- [ ] OLS policies hoạt động (nếu có)
- [ ] Audit logging hoạt động

---

**Document End**
