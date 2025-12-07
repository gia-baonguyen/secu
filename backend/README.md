# Backend - Grade Management System

Spring Boot backend application for the University Grade Management System.

## 📋 Prerequisites

- **Java 17 hoặc cao hơn** (hiện tại máy có Java 24 ✅)
- **Maven 3.8+** (cần cài đặt)
- **Oracle Database 19c** với ORCLPDB đã setup ✅

## 🔧 Technology Stack

- Spring Boot 3.1.5
- Spring Security + JWT Authentication
- Spring Data JPA (Hibernate)
- Oracle JDBC Driver (ojdbc11)
- OpenAPI/Swagger Documentation
- Lombok

## 📁 Project Structure

```
backend/
├── pom.xml                        # Maven dependencies
├── src/main/
│   ├── java/edu/university/grademanagement/
│   │   ├── GradeManagementApplication.java    # Main application
│   │   └── model/entity/                       # JPA entities
│   │       ├── Student.java
│   │       ├── Lecturer.java
│   │       └── Grade.java
│   └── resources/
│       └── application.properties              # Configuration
└── target/                        # Compiled classes
```

## ⚙️ Configuration

Database connection trong `src/main/resources/application.properties`:

```properties
# Oracle Database
spring.datasource.url=jdbc:oracle:thin:@localhost:1521/ORCLPDB
spring.datasource.username=GMS_APP
spring.datasource.password=App@2024#Secure

# Server
server.port=8080
server.servlet.context-path=/api

# JWT
jwt.secret=... (configured)
jwt.expiration=86400000

# CORS
security.cors.allowed-origins=http://localhost:3000,http://localhost:3001
```

## 🚀 Installation & Running

> **📌 Xem hướng dẫn đầy đủ:** `../START_HERE.md` - Hướng dẫn chạy từ database → backend → flutter

### Bước 1: Cài đặt Maven (nếu chưa có)

**Windows:**
```bash
# Option 1: Download từ https://maven.apache.org/download.cgi
# - Tải apache-maven-3.9.x-bin.zip
# - Giải nén vào C:\Program Files\Apache\maven
# - Thêm C:\Program Files\Apache\maven\bin vào PATH

# Option 2: Dùng Chocolatey (nếu có)
choco install maven

# Verify installation
mvn -version
```

### Bước 2: Build project

```bash
# Chuyển vào thư mục backend
cd e:\Desktop\HCMUT\baomat\grade-management-system\backend

# Clean và compile
mvn clean compile

# Run tests (nếu có)
mvn test

# Package thành JAR file
mvn package

# Hoặc build + skip tests
mvn clean package -DskipTests
```

### Bước 3: Run application

**Option 1: Dùng Maven**
```bash
mvn spring-boot:run
```

**Option 2: Dùng JAR file**
```bash
java -jar target/grade-management-system-1.0.0.jar
```

Application sẽ chạy tại: **http://localhost:8080/api**

## 📚 API Documentation

Sau khi start application, truy cập:

- **Swagger UI**: http://localhost:8080/api/swagger-ui.html
- **API Docs (JSON)**: http://localhost:8080/api/api-docs

## 🔍 Testing

### Test database connection

```bash
curl http://localhost:8080/api/actuator/health
```

Expected response:
```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP",
      "details": {
        "database": "Oracle",
        "validationQuery": "isValid()"
      }
    }
  }
}
```

### Test với Postman

Import Postman collection từ `/docs/postman/` (nếu có)

## ⚠️ Troubleshooting

### Lỗi: Maven not found
```bash
# Windows: thêm Maven vào PATH
setx PATH "%PATH%;C:\Program Files\Apache\maven\bin"

# Restart terminal và kiểm tra
mvn -version
```

### Lỗi: ORA-12154 TNS could not resolve
```bash
# Kiểm tra tnsnames.ora đã có ORCLPDB entry chưa
# File: E:\Desktop\WINDOWS.X64_193000_db_home\network\admin\tnsnames.ora

# Hoặc dùng Easy Connect string trong application.properties:
spring.datasource.url=jdbc:oracle:thin:@//localhost:1521/ORCLPDB
```

### Lỗi: ORA-01017 invalid username/password
```bash
# Kiểm tra user GMS_APP đã được tạo chưa
sqlplus sys/123@ORCLPDB as sysdba

SQL> SELECT username, account_status FROM dba_users WHERE username = 'GMS_APP';
# Nếu chưa có, chạy lại:
# @database/01-schema/step1_create_users.sql
```

### Lỗi: Table or view does not exist
```bash
# Kiểm tra tables đã được tạo chưa
sqlplus gms_app/App@2024#Secure@ORCLPDB

SQL> SELECT COUNT(*) FROM gms_admin.STUDENTS;
# Nếu lỗi, chạy lại:
# @database/01-schema/step2_create_tables.sql
# @database/03-data/step6_sample_data.sql
```

## 📊 Current Implementation Status

| Component | Status | Notes |
|-----------|--------|-------|
| Configuration | ✅ Complete | application.properties fully configured |
| Entity Models | ⚠️ Partial | 3/10 entities (Student, Lecturer, Grade) |
| Repositories | ❌ Not Started | Need to create JPA repositories |
| Services | ❌ Not Started | Business logic layer missing |
| Controllers | ❌ Not Started | REST API endpoints missing |
| Security | ❌ Not Started | JWT + Spring Security config missing |
| Tests | ❌ Not Started | Unit and integration tests needed |

## 🎯 Next Steps

Để hoàn thiện backend, cần implement:

1. **Repositories** - JPA repositories cho tất cả entities
2. **Services** - Business logic và VPD integration
3. **Controllers** - REST API endpoints
4. **Security** - JWT authentication và authorization
5. **DTOs** - Request/Response objects
6. **Exception Handling** - Global error handling
7. **Validators** - Input validation
8. **Tests** - Unit và integration tests

## 📝 Notes

- Backend hiện tại chỉ có cấu trúc cơ bản và entities
- Chưa có API endpoints để test
- Cần implement đầy đủ để tích hợp với frontend
- VPD context integration cần được implement trong Service layer

## 🛠️ Development Tools

### VS Code Setup

Xem `VSCODE_SETUP.md` để biết cách:
- Cài đặt Spring Boot Extension Pack
- Chạy/debug application từ VS Code
- Sử dụng Spring Boot Dashboard

## 📞 Support

- **Hướng dẫn chạy hệ thống:** `../START_HERE.md`
- **Hướng dẫn đầy đủ:** `../HUONG_DAN.md`
- **API Testing:** `API_TEST.md`
