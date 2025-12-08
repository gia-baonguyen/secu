# HỆ THỐNG QUẢN LÝ ĐIỂM ĐẠI HỌC
# UNIVERSITY GRADE MANAGEMENT SYSTEM

> **Version**: 1.0  
> **Database**: Oracle 19c+  
> **Backend**: Spring Boot 3.x  
> **Frontend**: Flutter  

---

## 📋 MỤC LỤC

1. [Tổng quan](#1-tổng-quan)
2. [Cấu trúc thư mục](#2-cấu-trúc-thư-mục)
3. [Yêu cầu hệ thống](#3-yêu-cầu-hệ-thống)
4. [Hướng dẫn cài đặt](#4-hướng-dẫn-cài-đặt)
5. [Tài khoản test](#5-tài-khoản-test)
6. [Chạy ứng dụng](#6-chạy-ứng-dụng)
7. [Tính năng bảo mật](#7-tính-năng-bảo-mật)
8. [Tài liệu tham khảo](#8-tài-liệu-tham-khảo)

---

## 1. TỔNG QUAN

Hệ thống quản lý điểm đại học với đầy đủ tính năng bảo mật:

- **VPD (Virtual Private Database)**: Bảo mật cấp hàng
- **Column-Level Security**: Bảo mật cấp cột
- **OLS (Oracle Label Security)**: Phân loại dữ liệu bảo mật
- **Password Profiles**: Chính sách mật khẩu mạnh
- **Fine-Grained Auditing**: Ghi log chi tiết

### Các vai trò người dùng

| Role | Mô tả | Quyền hạn |
|------|-------|-----------|
| STUDENT | Sinh viên | Xem điểm của mình |
| LECTURER | Giảng viên | Nhập/sửa điểm sinh viên mình dạy |
| DEPARTMENT_HEAD | Trưởng bộ môn | Xem điểm toàn bộ môn |
| DEAN | Trưởng khoa | Xem điểm toàn khoa |
| ACADEMIC_AFFAIRS | Giáo vụ | Quản lý toàn bộ điểm |
| RELATIVE | Phụ huynh | Xem điểm con (không xem thông tin cá nhân) |
| ADMIN | Quản trị | Toàn quyền |

---

## 2. CẤU TRÚC THƯ MỤC

```
secu/
├── database/                    # Database scripts
│   ├── 01-schema/              # Tạo users & tables
│   │   ├── step1_create_users.sql
│   │   └── step2_create_tables.sql
│   ├── 02-security/            # Cấu hình bảo mật
│   │   ├── step3_password_profiles.sql
│   │   ├── step4_vpd_policies.sql
│   │   ├── step5_audit_policies.sql
│   │   └── step7_ols_setup.sql
│   ├── 03-data/                # Dữ liệu mẫu
│   │   └── step6_sample_data.sql
│   └── SETUP_ALL.sql           # Script chạy tất cả
│
├── backend/                     # Spring Boot API
│   ├── src/main/java/          # Source code
│   ├── src/main/resources/     # Config files
│   └── pom.xml                 # Maven dependencies
│
├── flutter_app/                 # Flutter mobile app
│   ├── lib/                    # Dart source code
│   └── pubspec.yaml            # Dependencies
│
├── LOGIC_NGHIEP_VU_TONG_HOP.md # Tài liệu logic nghiệp vụ chi tiết
└── README.md                    # File này
```

---

## 3. YÊU CẦU HỆ THỐNG

### Database
- Oracle Database 19c trở lên
- Oracle Enterprise Edition (cho OLS)
- SQL*Plus hoặc SQL Developer

### Backend
- Java JDK 17+
- Maven 3.8+
- IDE: IntelliJ IDEA hoặc VS Code

### Frontend (Flutter)
- Flutter SDK 3.x
- Dart SDK 3.x
- Android Studio (cho Android emulator)

---

## 4. HƯỚNG DẪN CÀI ĐẶT

### Bước 1: Cài đặt Database

```bash
# 1. Mở SQL*Plus với SYSDBA
sqlplus sys/password@localhost:1521/ORCLPDB as sysdba

# 2. Chạy script setup tất cả
@database/SETUP_ALL.sql
```

**Hoặc chạy từng bước:**

```sql
-- Bước 1.1: Tạo users
@database/01-schema/step1_create_users.sql

-- Bước 1.2: Tạo tables
@database/01-schema/step2_create_tables.sql

-- Bước 1.3: Password profiles
@database/02-security/step3_password_profiles.sql

-- Bước 1.4: VPD policies
@database/02-security/step4_vpd_policies.sql

-- Bước 1.5: Audit policies
@database/02-security/step5_audit_policies.sql

-- Bước 1.6: Sample data
@database/03-data/step6_sample_data.sql

-- Bước 1.7: OLS (tùy chọn - yêu cầu Enterprise Edition)
-- Xem hướng dẫn trong file step7_ols_setup.sql
```

### Bước 2: Cấu hình Backend

```bash
# 1. Vào thư mục backend
cd backend

# 2. Sửa file cấu hình database
# File: src/main/resources/application.properties
```

```properties
# Cấu hình Oracle
spring.datasource.url=jdbc:oracle:thin:@//localhost:1521/ORCLPDB
spring.datasource.username=GMS_ACADEMIC
spring.datasource.password=Academic@2024
```

```bash
# 3. Build và chạy
mvn clean install
mvn spring-boot:run
```

Backend sẽ chạy tại: `http://localhost:8081/api`

### Bước 3: Cấu hình Flutter App

```bash
# 1. Vào thư mục flutter_app
cd flutter_app

# 2. Cài đặt dependencies
flutter pub get

# 3. Sửa API URL (nếu cần)
# File: lib/services/api_service.dart
# Đổi baseUrl thành IP của backend
```

```dart
// Cho Android emulator
final String baseUrl = 'http://10.0.2.2:8081/api';

// Cho thiết bị thật
final String baseUrl = 'http://YOUR_IP:8081/api';
```

```bash
# 4. Chạy app
flutter run
```

---

## 5. TÀI KHOẢN TEST

### Tài khoản ứng dụng (login Flutter app)

| Username | Password | Role |
|----------|----------|------|
| nvhai | 123456 | STUDENT |
| lecturer01 | 123456 | LECTURER |
| depthead01 | 123456 | DEPARTMENT_HEAD |
| dean01 | 123456 | DEAN |
| academic01 | 123456 | ACADEMIC_AFFAIRS |
| relative01 | 123456 | RELATIVE |
| admin | admin123 | ADMIN |

### Tài khoản Database (SQL*Plus)

| Username | Password | Mô tả |
|----------|----------|-------|
| GMS_ADMIN | Admin@2024#Secure | Schema owner |
| GMS_ACADEMIC | Academic@2024 | App connection user |
| GMS_STUDENT | Student@2024 | Test student access |
| GMS_LECTURER | Lecturer@2024 | Test lecturer access |
| GMS_DEAN | Dean@2024 | Test dean access |

---

## 6. CHẠY ỨNG DỤNG

### Khởi động nhanh (Quick Start)

```bash
# Terminal 1: Chạy Backend
cd backend
mvn spring-boot:run

# Terminal 2: Chạy Flutter
cd flutter_app
flutter run
```

### Test API

```bash
# Login
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"nvhai","password":"123456"}'

# Get grades (with token)
curl http://localhost:8081/api/students/me/grades \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 7. TÍNH NĂNG BẢO MẬT

### 7.1 VPD (Virtual Private Database)
- Sinh viên chỉ xem được điểm của mình
- Giảng viên chỉ xem được sinh viên mình dạy
- Trưởng khoa xem được sinh viên trong khoa

### 7.2 Column-Level Security
- Phụ huynh (Relative) không xem được họ tên sinh viên
- Chỉ xem được mã sinh viên và điểm

### 7.3 OLS (Oracle Label Security)
- Phân loại câu hỏi thi theo mức độ bảo mật
- PUBLIC, INTERNAL, CONFIDENTIAL

### 7.4 Password Profiles
- Mật khẩu phải có chữ hoa, chữ thường, số, ký tự đặc biệt
- Tự động khóa sau 5 lần đăng nhập sai
- Mật khẩu hết hạn sau 90 ngày

### 7.5 Audit Logging
- Ghi log tất cả thao tác SELECT trên bảng GRADES
- Ghi log INSERT, UPDATE, DELETE trên các bảng quan trọng

---

## 8. TÀI LIỆU THAM KHẢO

- **LOGIC_NGHIEP_VU_TONG_HOP.md**: Chi tiết toàn bộ logic nghiệp vụ, cấu trúc database, VPD policies, test cases
- **database/02-security/**: Các script bảo mật với comments chi tiết

---

## 📞 Liên hệ

- **Authors**: 2210230, 2210238
- **Course**: Bảo mật Hệ thống Thông tin

---

*Last updated: December 2024*
