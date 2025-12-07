# 🚀 HƯỚNG DẪN CHẠY HỆ THỐNG - TỪNG BƯỚC

**Hệ thống:** University Grade Management System  
**Thứ tự:** Database → Backend → Flutter App

---

## 📋 TỔNG QUAN

Hệ thống gồm 3 thành phần chính:

1. **Database (Oracle)** - Lưu trữ dữ liệu và security policies
2. **Backend (Spring Boot)** - API server
3. **Flutter App** - Mobile application

---

## ⚙️ PREREQUISITES

### Phần mềm cần có:

- ✅ **Oracle Database 19c** (đã cài đặt)
- ✅ **Java 17+** (đã có Java 24)
- ⚠️ **Maven 3.8+** (cần cài đặt nếu chưa có)
- ✅ **Flutter SDK 3.0+** (đã cài đặt)
- ✅ **SQL\*Plus** hoặc **SQL Developer**

### Kiểm tra:

```powershell
# Kiểm tra Java
java -version

# Kiểm tra Maven (nếu chưa có, cài đặt)
mvn -version

# Kiểm tra Flutter
flutter --version

# Kiểm tra Oracle
sqlplus -version
```

---

## 📍 BƯỚC 1: SETUP DATABASE (Oracle)

### 1.1. Mở Oracle Database

Đảm bảo Oracle Database đang chạy và PDB `ORCLPDB` đã mở:

```sql
-- Connect as SYSDBA
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba

-- Kiểm tra PDB
SELECT name, open_mode FROM v$pdbs;

-- Nếu chưa mở, mở PDB
ALTER PLUGGABLE DATABASE ORCLPDB OPEN;
ALTER PLUGGABLE DATABASE ORCLPDB SAVE STATE;
```

### 1.2. Chạy Setup Script

**Option 1: Dùng PowerShell script (Khuyến nghị)**

```powershell
cd D:\BaoMatHTTT\secu\database
.\run_setup.ps1
```

**Option 2: Dùng Batch script**

```cmd
cd D:\BaoMatHTTT\secu\database
run_setup.bat
```

**Option 3: Chạy trực tiếp SQL\*Plus**

```powershell
cd D:\BaoMatHTTT\secu\database
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@SETUP_ALL.sql"
```

**Lưu ý:** Trong PowerShell, phải dùng dấu ngoặc kép `"@SETUP_ALL.sql"` để tránh lỗi splatting operator.

### 1.3. Verify Setup

```powershell
cd D:\BaoMatHTTT\secu\database\04-tests
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@RUN_ALL_TESTS.sql"
```

Hoặc dùng batch file:

```cmd
cd D:\BaoMatHTTT\secu\database\04-tests
run_tests.bat
```

**Kết quả mong đợi:** 29/29 tests PASSED ✅

### 1.4. Fix Backend Connection (Nếu cần)

Nếu backend không kết nối được database:

```powershell
cd D:\BaoMatHTTT\secu\database\scripts
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@MAINTENANCE_SCRIPTS.sql"
```

Script này sẽ:

- ✅ Grant permissions cho GMS_APP
- ✅ Update password hashes (BCrypt) cho authentication

---

## 📍 BƯỚC 2: CHẠY BACKEND (Spring Boot)

### 2.1. Cài đặt Maven (Nếu chưa có)

**Windows:**

```powershell
# Option 1: Download từ https://maven.apache.org/download.cgi
# - Tải apache-maven-3.9.x-bin.zip
# - Giải nén vào C:\Program Files\Apache\maven
# - Thêm C:\Program Files\Apache\maven\bin vào PATH

# Option 2: Dùng Chocolatey (nếu có)
choco install maven

# Verify
mvn -version
```

### 2.2. Build Project

```powershell
cd D:\BaoMatHTTT\secu\backend

# Clean và compile
mvn clean compile

# Package thành JAR (skip tests nếu cần)
mvn clean package -DskipTests
```

### 2.3. Chạy Backend

**Option 1: Dùng Maven (Khuyến nghị)**

```powershell
cd D:\BaoMatHTTT\secu\backend
mvn spring-boot:run
```

**Option 2: Dùng Batch file**

```cmd
cd D:\BaoMatHTTT\secu\backend
run_backend.bat
```

**Option 3: Dùng JAR file**

```powershell
cd D:\BaoMatHTTT\secu\backend
java -jar target/grade-management-system-1.0.0.jar
```

### 2.4. Verify Backend

Backend sẽ chạy tại: **http://localhost:8081/api**

**Test health check:**

```powershell
# PowerShell
Invoke-RestMethod -Uri "http://localhost:8081/api/actuator/health"

# Hoặc dùng browser
# http://localhost:8081/api/actuator/health
```

**Kết quả mong đợi:**

```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP"
    }
  }
}
```

**Test login:**

```powershell
$body = @{
    username = "nvhai"
    password = "password123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8081/api/auth/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

---

## 📍 BƯỚC 3: CHẠY FLUTTER APP

### 3.1. Cài đặt Dependencies

```powershell
cd D:\BaoMatHTTT\secu\flutter_app
flutter pub get
```

### 3.2. Kiểm tra API Base URL

Mở file `lib/services/api_service.dart` và kiểm tra `baseUrl`:

```dart
static String get baseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8081/api'; // Android emulator
  } else {
    return 'http://localhost:8081/api'; // iOS/Web
  }
}
```

**Lưu ý:**

- **Android Emulator:** Dùng `10.0.2.2` thay vì `localhost`
- **iOS Simulator:** Dùng `localhost`
- **Physical Device:** Dùng IP máy tính (ví dụ: `http://192.168.1.100:8081/api`)

### 3.3. Chạy Flutter App

**Option 1: Chạy trên Android Emulator**

```powershell
cd D:\BaoMatHTTT\secu\flutter_app
flutter run
```

**Option 2: Chạy trên iOS Simulator (Mac only)**

```bash
flutter run -d ios
```

**Option 3: Chạy trên Web**

```powershell
flutter run -d chrome
```

### 3.4. Test Login

**Test Users:**

| Username | Password    | Role     |
| -------- | ----------- | -------- |
| nvhai    | password123 | STUDENT  |
| nv.an    | password123 | LECTURER |
| admin    | password123 | ADMIN    |

**Các màn hình:**

- ✅ Login Screen
- ✅ Home Screen (role-based navigation)
- ✅ Profile Screen
- ✅ Grades Screen (Student only)
- ✅ GPA Screen (Student only)
- ✅ Lecturer Screens (Students, Grades)
- ✅ Admin Screens (All Students, All Grades)

---

## 🔄 QUY TRÌNH CHẠY ĐẦY ĐỦ

### Lần đầu tiên:

```powershell
# 1. Setup Database
cd D:\BaoMatHTTT\secu\database
.\run_setup.ps1

# 2. Verify Database
cd 04-tests
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@RUN_ALL_TESTS.sql"

# 3. Fix Backend Connection (nếu cần)
cd ..\scripts
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@MAINTENANCE_SCRIPTS.sql"

# 4. Start Backend
cd ..\..\backend
mvn spring-boot:run

# 5. Start Flutter App (terminal mới)
cd ..\flutter_app
flutter run
```

### Các lần sau (Database đã setup):

```powershell
# 1. Start Backend
cd D:\BaoMatHTTT\secu\backend
mvn spring-boot:run

# 2. Start Flutter App (terminal mới)
cd D:\BaoMatHTTT\secu\flutter_app
flutter run
```

---

## ⚠️ TROUBLESHOOTING

### Database không kết nối được

```sql
-- Kiểm tra PDB đã mở chưa
SELECT name, open_mode FROM v$pdbs;

-- Mở PDB nếu cần
ALTER PLUGGABLE DATABASE ORCLPDB OPEN;
```

### Backend không start được

1. **Kiểm tra database connection:**

   ```powershell
   # Test connection
   sqlplus GMS_APP/App@2024#Secure@//localhost:1521/ORCLPDB
   ```

2. **Chạy maintenance script:**

   ```powershell
   cd D:\BaoMatHTTT\secu\database\scripts
   sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@MAINTENANCE_SCRIPTS.sql"
   ```

3. **Kiểm tra port 8081:**
   ```powershell
   netstat -ano | findstr :8081
   ```

### Flutter không kết nối được API

1. **Kiểm tra backend đang chạy:**

   ```powershell
   Invoke-RestMethod -Uri "http://localhost:8081/api/actuator/health"
   ```

2. **Kiểm tra baseUrl trong `api_service.dart`**

3. **Android Emulator:** Dùng `10.0.2.2` thay vì `localhost`

4. **Physical Device:** Dùng IP máy tính thay vì `localhost`

---

## 📚 TÀI LIỆU THAM KHẢO

- **Database:** `database/README.md`
- **Kết nối SQL UI:** `database/DATABASE_CONNECTION_GUIDE.md` - ⭐ Hướng dẫn kết nối SQL Developer, DBeaver để query và demo
- **Backend:** `backend/README.md`
- **Flutter App:** `flutter_app/README.md`
- **Hướng dẫn đầy đủ:** `HUONG_DAN.md`

---

## ✅ CHECKLIST

- [ ] Oracle Database đang chạy
- [ ] PDB ORCLPDB đã mở
- [ ] Database setup đã chạy (`SETUP_ALL.sql`)
- [ ] Database tests đã pass (29/29)
- [ ] Backend đã build (`mvn clean package`)
- [ ] Backend đang chạy (port 8081)
- [ ] Flutter dependencies đã cài (`flutter pub get`)
- [ ] Flutter app đang chạy
- [ ] Login thành công với test user

---

**Last Updated:** 2025-01-XX  
**Version:** 1.0
