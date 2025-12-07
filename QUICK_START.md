# 🚀 QUICK START GUIDE
## Chạy Database và Backend

---

## ✅ BƯỚC 1: KIỂM TRA DATABASE

### 1.1 Kiểm tra Oracle Database đang chạy

```bash
# Kiểm tra Oracle listener
lsnrctl status

# Nếu listener không chạy, start nó:
lsnrctl start
```

### 1.2 Kiểm tra PDB đã mở

```bash
sqlplus sys/oracle@//localhost:1521/ORCLPDB as sysdba
```

```sql
-- Kiểm tra PDB
SELECT name, open_mode FROM v$pdbs;
-- Kết quả: ORCLPDB phải là READ WRITE

-- Nếu chưa mở:
ALTER PLUGGABLE DATABASE ORCLPDB OPEN;
ALTER PLUGGABLE DATABASE ORCLPDB SAVE STATE;
```

### 1.3 Kiểm tra Database đã setup

```bash
cd secu/database/04-tests
sqlplus sys/oracle@//localhost:1521/ORCLPDB as sysdba @RUN_ALL_TESTS.sql
```

**Kết quả mong đợi:** Tất cả tests PASSED ✅

---

## ✅ BƯỚC 2: CÀI ĐẶT MAVEN (Nếu chưa có)

### Windows:

**Option 1: Download Manual**
1. Tải Maven từ: https://maven.apache.org/download.cgi
2. Giải nén vào `C:\Program Files\Apache\maven`
3. Thêm vào PATH:
   ```powershell
   setx PATH "%PATH%;C:\Program Files\Apache\maven\bin"
   ```
4. Restart terminal và kiểm tra:
   ```bash
   mvn -version
   ```

**Option 2: Chocolatey**
```bash
choco install maven
mvn -version
```

---

## ✅ BƯỚC 3: CHẠY BACKEND

### Cách 1: Dùng Script (Dễ nhất)

```bash
cd secu/backend
.\run_backend.bat
```

### Cách 2: Chạy thủ công

```bash
cd secu/backend

# Build project
mvn clean package -DskipTests

# Chạy application
mvn spring-boot:run
```

### Cách 3: Chạy JAR file (sau khi build)

```bash
cd secu/backend
java -jar target/grade-management-system-1.0.0.jar
```

---

## ✅ BƯỚC 4: KIỂM TRA BACKEND ĐÃ CHẠY

### 4.1 Kiểm tra Health Check

Mở browser hoặc dùng curl:
```bash
curl http://localhost:8081/api/actuator/health
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

### 4.2 Test Database Connection

```bash
curl http://localhost:8081/api/test/db-connection
```

**Kết quả mong đợi:**
```json
{
  "status": "SUCCESS",
  "message": "Database connection successful!",
  "tables_count": 15,
  "students_count": 5,
  "grades_count": 7
}
```

### 4.3 Truy cập Swagger UI

Mở browser:
```
http://localhost:8081/api/swagger-ui.html
```

---

## 📋 CHECKLIST

### Database:
- [ ] Oracle Database đang chạy
- [ ] Listener đang chạy (port 1521)
- [ ] PDB ORCLPDB đã mở (READ WRITE)
- [ ] Database users đã được tạo (8 users)
- [ ] Tables đã được tạo (15 tables)
- [ ] Sample data đã được load
- [ ] Tests đã pass

### Backend:
- [ ] Java đã cài đặt (Java 17+)
- [ ] Maven đã cài đặt (Maven 3.8+)
- [ ] Database configuration đúng (application.properties)
- [ ] Application đã build thành công
- [ ] Application đã chạy (port 8081)
- [ ] Database connection test pass
- [ ] Health check pass

---

## ⚠️ TROUBLESHOOTING

### Lỗi: Database connection failed

**Kiểm tra:**
1. Oracle Database đang chạy
2. Listener đang chạy: `lsnrctl status`
3. PDB đã mở: `SELECT name, open_mode FROM v$pdbs;`
4. User GMS_APP tồn tại và active
5. Password đúng: `App@2024#Connect`

**Sửa:**
```sql
-- Mở PDB nếu chưa mở
ALTER PLUGGABLE DATABASE ORCLPDB OPEN;

-- Kiểm tra user
SELECT username, account_status FROM dba_users WHERE username = 'GMS_APP';

-- Unlock user nếu bị lock
ALTER USER GMS_APP ACCOUNT UNLOCK;
```

### Lỗi: Maven not found

**Sửa:**
1. Cài đặt Maven (xem Bước 2)
2. Thêm Maven vào PATH
3. Restart terminal

### Lỗi: Port 8081 already in use

**Sửa:**
1. Tìm process đang dùng port 8081:
   ```bash
   netstat -ano | findstr :8081
   ```
2. Kill process hoặc đổi port trong `application.properties`:
   ```properties
   server.port=8082
   ```

### Lỗi: Table or view does not exist

**Sửa:**
```sql
-- Grant quyền cho GMS_APP
GRANT SELECT ON gms_admin.STUDENTS TO GMS_APP;
GRANT SELECT ON gms_admin.GRADES TO GMS_APP;
GRANT SELECT ON gms_admin.ENROLLMENTS TO GMS_APP;
-- ... các tables khác
```

---

## 🎯 NEXT STEPS

Sau khi backend chạy thành công:

1. **Test API endpoints** qua Swagger UI
2. **Test authentication** qua `/api/auth/login`
3. **Test database queries** qua các controllers
4. **Integrate với frontend** (nếu có)

---

## 📝 NOTES

- **Database Port**: 1521
- **Backend Port**: 8081
- **Context Path**: `/api`
- **Database User**: `GMS_APP`
- **Database Password**: `App@2024#Connect`

---

*Last updated: 2025-12-06*

