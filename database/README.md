# Database Setup Guide - Grade Management System

## 📁 Cấu trúc thư mục

```
database/
├── RUN_ALL.sql                    # ⭐ Script chạy tất cả từ đầu (Setup + Fix)
├── SETUP_ALL.sql                  # Setup database chính
├── HUONG_DAN_CHAY_LAI.md          # ⭐ Hướng dẫn chạy lại từ đầu
├── README.md                      # Tài liệu này
├── DATABASE_CONNECTION_GUIDE.md  # Hướng dẫn kết nối SQL UI
├── QUERY_SAMPLES.sql             # Query mẫu để demo
├── OLS_SETUP_GUIDE.md            # Hướng dẫn OLS (optional)
├── run_setup.ps1                 # PowerShell script
├── run_setup.bat                 # Batch script
├── 01-schema/                    # Schema creation
│   ├── step1_create_users.sql
│   └── step2_create_tables.sql
├── 02-security/                  # Security configuration
│   ├── step3_password_profiles.sql
│   ├── step4_vpd_policies.sql
│   ├── step5_audit_policies.sql
│   └── step7_ols_setup.sql       # Oracle Label Security (OPTIONAL)
├── 03-data/                      # Sample data
│   └── step6_sample_data.sql
├── 04-tests/                     # Testing & Verification
│   ├── RUN_ALL_TESTS.sql         # ⭐ Chạy tất cả tests
│   ├── 00_grant_test_privileges.sql
│   └── run_tests.bat
└── scripts/                      # Utility scripts
    └── MAINTENANCE_SCRIPTS.sql   # ⭐ All-in-one fix script
```

---

## 🚀 Quick Start

> **📌 Xem hướng dẫn chạy lại từ đầu:** `HUONG_DAN_CHAY_LAI.md`

### 1. Setup Database (Lần đầu - Chạy tất cả)

**Option 1: Chạy tất cả từ đầu (Khuyến nghị - Setup + Fix)**

```powershell
cd D:\BaoMatHTTT\secu\database
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@RUN_ALL.sql"
```

Script này sẽ tự động:

- ✅ Setup database (SETUP_ALL.sql)
- ✅ Grant test privileges
- ✅ Fix tất cả issues (MAINTENANCE_SCRIPTS.sql)

**Option 2: Chỉ setup database**

```powershell
cd D:\BaoMatHTTT\secu\database
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@SETUP_ALL.sql"
```

**Option 3: Dùng PowerShell/Batch script**

```powershell
cd D:\BaoMatHTTT\secu\database
.\run_setup.ps1
```

**Lưu ý:** Trong PowerShell, phải dùng dấu ngoặc kép `"@RUN_ALL.sql"` để tránh lỗi splatting operator.

### 2. Verify Setup

```bash
cd D:\BaoMatHTTT\secu\database\04-tests
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@RUN_ALL_TESTS.sql"
```

Hoặc dùng batch file:

```bash
cd D:\BaoMatHTTT\secu\database\04-tests
run_tests.bat
```

### 3. Fix Backend Connection (Nếu cần)

Nếu backend không kết nối được database hoặc gặp bất kỳ lỗi nào:

```bash
cd D:\BaoMatHTTT\secu\database\scripts
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@MAINTENANCE_SCRIPTS.sql"
```

Script này sẽ tự động fix tất cả:

- ✅ Grant permissions cho GMS_APP (SELECT, INSERT, UPDATE, DELETE trên tất cả tables)
- ✅ Update password hashes (BCrypt) cho authentication
- ✅ Fix session limits (ORA-02391)
- ✅ Fix idle time limits (ORA-02396)
- ✅ Fix VPD bypass cho GMS_APP

---

## 📋 Chi tiết các thư mục

### `01-schema/` - Schema Creation

**Mục đích:** Tạo database schema (users, tables)

**Files:**

- `step1_create_users.sql`: Tạo 8 users (GMS_ADMIN, GMS_APP, GMS_STUDENT, ...)
- `step2_create_tables.sql`: Tạo 15 tables (STUDENTS, GRADES, ENROLLMENTS, ...)

**Khi nào dùng:** Được gọi tự động bởi `SETUP_ALL.sql`

---

### `02-security/` - Security Configuration

**Mục đích:** Cấu hình bảo mật (VPD, FGA, Password Profiles)

**Files:**

- `step3_password_profiles.sql`: Tạo 5 password profiles
- `step4_vpd_policies.sql`: Tạo 7 VPD policies (row-level security)
- `step5_audit_policies.sql`: Tạo 8 FGA policies + 2 audit triggers
- `step7_ols_setup.sql`: Cấu hình OLS (Oracle Label Security) - OPTIONAL

**Khi nào dùng:** Được gọi tự động bởi `SETUP_ALL.sql`

---

### `03-data/` - Sample Data

**Mục đích:** Load dữ liệu mẫu để test

**Files:**

- `step6_sample_data.sql`: Insert sample data
  - 3 Faculties, 4 Departments, 5 Lecturers
  - 4 Classes, 5 Students, 3 Relatives
  - 6 Courses, 5 Course Sections, 9 Enrollments
  - 7 Grades, 3 Deadlines, 7 System Users

**Khi nào dùng:** Được gọi tự động bởi `SETUP_ALL.sql`

---

### `04-tests/` - Testing & Verification

**Mục đích:** Kiểm tra và xác minh database setup

**Files:**

- `RUN_ALL_TESTS.sql`: ⭐ **Script chính** - Chạy tất cả tests
  - Verify 8 users, 15 tables, 3 views
  - Test VPD policies, FGA policies
  - Test sample data
  - Test security context
- `00_grant_test_privileges.sql`: Grant privileges cho test users
- `run_tests.bat`: Batch file để chạy tests (Windows)

**Khi nào dùng:**

- Sau khi chạy `SETUP_ALL.sql` để verify
- Khi debug vấn đề database
- Khi muốn kiểm tra security policies

**Cách chạy:**

```bash
# Cách 1: SQL*Plus
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@RUN_ALL_TESTS.sql"

# Cách 2: Batch file (Windows)
cd 04-tests
run_tests.bat
```

---

### `scripts/` - Utility Scripts

**Mục đích:** Scripts tiện ích để bảo trì và fix vấn đề

**Files:**

- `MAINTENANCE_SCRIPTS.sql`: ⭐ **Script chính - ALL IN ONE** - Gộp tất cả utility scripts
  - **Part 1:** Grant permissions cho GMS_APP (SELECT, INSERT, UPDATE, DELETE trên tất cả tables/views)
  - **Part 2:** Update password hashes (BCrypt) cho authentication
  - **Part 3:** Fix session và idle time limits (ORA-02391, ORA-02396)
  - **Part 4:** Fix VPD bypass cho GMS_APP (cho phép GMS_APP xem tất cả data)
  - **Part 5:** Verify permissions

**Khi nào dùng:**

- **Sau khi setup database:** Luôn chạy `MAINTENANCE_SCRIPTS.sql` để fix tất cả issues
- **Backend không kết nối được:** Chạy `MAINTENANCE_SCRIPTS.sql` (Part 1)
- **Login không được:** Chạy `MAINTENANCE_SCRIPTS.sql` (Part 2)
- **GMS_APP không SELECT được:** Chạy `MAINTENANCE_SCRIPTS.sql` (Part 1 + Part 4)
- **Gặp lỗi session/idle time:** Chạy `MAINTENANCE_SCRIPTS.sql` (Part 3)

**Cách chạy:**

```bash
cd scripts
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@MAINTENANCE_SCRIPTS.sql"
```

**Lưu ý:** Script này tự động fix tất cả, không cần chạy từng script riêng lẻ.

---

## 🔧 Troubleshooting

### Vấn đề 1: Backend không kết nối được database

**Nguyên nhân:** GMS_APP chưa có permissions

**Giải pháp:**

```bash
cd scripts
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@MAINTENANCE_SCRIPTS.sql"
```

### Vấn đề 2: Login không được (401/403)

**Nguyên nhân:** Password chưa được hash bằng BCrypt

**Giải pháp:**

```bash
cd scripts
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@MAINTENANCE_SCRIPTS.sql"
```

### Vấn đề 3: Database chưa mở (ORA-01109)

**Nguyên nhân:** ORCLPDB chưa được mở

**Giải pháp:**

```sql
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba
ALTER PLUGGABLE DATABASE ORCLPDB OPEN;
ALTER PLUGGABLE DATABASE ORCLPDB SAVE STATE;
EXIT;
```

### Vấn đề 4: VPD policies không hoạt động

**Nguyên nhân:** Policies chưa được enable hoặc context chưa set

**Giải pháp:**

```bash
cd 04-tests
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@RUN_ALL_TESTS.sql"
```

### Vấn đề 5: Bất kỳ lỗi nào (ORA-02391, ORA-02396, GMS_APP không SELECT được, etc.)

**Giải pháp chung:** Chạy MAINTENANCE_SCRIPTS.sql (fix tất cả)

```bash
cd scripts
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@MAINTENANCE_SCRIPTS.sql"
```

Script này sẽ tự động fix:

- ✅ ORA-02391 (session limit) - Tăng SESSIONS_PER_USER
- ✅ ORA-02396 (idle time) - Tăng IDLE_TIME
- ✅ GMS_APP không SELECT được - Grant permissions + VPD bypass
- ✅ Admin không SELECT được - VPD bypass
- ✅ Password hashes - Update BCrypt hashes

**Lưu ý:** Script này fix tất cả issues, không cần chạy từng script riêng lẻ.

---

## 📊 Test Users

Sau khi setup, có các test users sau (password: `password123`):

| Username | User ID | Role             | Reference ID |
| -------- | ------- | ---------------- | ------------ |
| nvhai    | USR002  | STUDENT          | STU001       |
| tthoa    | USR003  | STUDENT          | STU002       |
| nv.an    | USR004  | LECTURER         | LEC001       |
| tt.binh  | USR005  | LECTURER         | LEC002       |
| admin    | USR001  | ADMIN            | GMS_ADMIN    |
| academic | USR007  | ACADEMIC_AFFAIRS | ACAD001      |

---

## 📝 Quy trình Setup đầy đủ

### Bước 1: Setup Database (Chạy tất cả)

```bash
cd D:\BaoMatHTTT\secu\database
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@RUN_ALL.sql"
```

### Bước 2: Verify Setup

```bash
cd D:\BaoMatHTTT\secu\database\04-tests
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@RUN_ALL_TESTS.sql"
```

### Bước 3: Test Backend

```bash
# Start backend
cd D:\BaoMatHTTT\secu\backend
mvn spring-boot:run

# Test login
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"nvhai","password":"password123"}'
```

---

## 🔐 Security Features

### VPD (Virtual Private Database) - Row-level Security

- **7 Policies:** Row-level security cho STUDENTS, GRADES, ENROLLMENTS
- **Tự động filter:** Users chỉ thấy/update data của mình
- **Bypass cho GMS_ADMIN và GMS_APP:** Admin và App có thể xem tất cả data
- **Implementation:** `step4_vpd_policies.sql`

### Column-level Security

- **Column-level UPDATE:** Users chỉ được UPDATE một số cột cụ thể
  - **Students:** `email`, `phone_number`, `contact_address`
  - **Lecturers:** `email`, `phone_number`, `contact_address`
  - **Relatives:** `email`, `phone_number`, `contact_address`
- **Implementation:** `step2_create_tables.sql` (GRANT UPDATE với column list)
- **Kết hợp với VPD:** Users chỉ update được cột được phép trong dòng của mình

### FGA (Fine-Grained Auditing)

- **8 Policies:** Audit SELECT trên sensitive columns
- **2 Triggers:** Audit INSERT/UPDATE/DELETE operations

### Password Profiles

- **5 Profiles:** Different password policies cho từng role
- **Password history:** Prevent password reuse

### OLS (Oracle Label Security) - Multi-Level Classification

- **Policy:** `EXAM_SEC_POLICY` - Bảo vệ Exam Question Bank
- **Levels:** PUB (1000), INT (2000), CONF (3000)
- **Compartments:** CS (Computer Science), EE (Electrical Engineering)
- **Use Case:** Phân loại câu hỏi thi theo mức độ bảo mật
  - **PUB:** Câu hỏi công khai (tất cả sinh viên)
  - **INT:CS/EE:** Câu hỏi nội bộ khoa (giảng viên và trưởng khoa)
  - **CONF:CS:** Đáp án thi mật (chỉ trưởng khoa)
- **Implementation:** `step7_ols_setup.sql` (OPTIONAL - requires OLS enabled)
- **Documentation:** `OLS_SETUP_GUIDE.md` - Hướng dẫn chi tiết về OLS

**Note:** OLS là tính năng tùy chọn của Oracle. Cần enable trước khi sử dụng:

```sql
EXEC LBACSYS.CONFIGURE_OLS;
EXEC LBACSYS.OLS_ENFORCEMENT.ENABLE_OLS;
```

**Chi tiết về OLS:**

- OLS chỉ áp dụng cho bảng `EXAM_QUESTIONS` (bảng mới, không ảnh hưởng hệ thống hiện tại)
- Xem `OLS_SETUP_GUIDE.md` để biết cách enable và test
- Xem `OLS_IMPACT_ANALYSIS.md` để hiểu ảnh hưởng của OLS

---

## 📚 Tài liệu tham khảo

- **Mô tả nghiệp vụ:** `MO_TA_NGHIEP_VU.md` - ⭐ Mô tả đầy đủ nghiệp vụ và quy trình của hệ thống
- **Kiểm tra tài khoản:** `USER_ACCOUNTS_GUIDE.md` - ⭐ Hướng dẫn kiểm tra tài khoản, quyền và mapping ID
- **Hướng dẫn chạy lại từ đầu:** `HUONG_DAN_CHAY_LAI.md` - Hướng dẫn chạy lại database từ đầu
- **Hướng dẫn chạy hệ thống:** `../START_HERE.md` - Hướng dẫn chạy từ database → backend → flutter
- **Kết nối SQL UI:** `DATABASE_CONNECTION_GUIDE.md` - Hướng dẫn kết nối SQL Developer, DBeaver để query và demo
- **Query mẫu:** `QUERY_SAMPLES.sql` - Các query mẫu để demo
- **Main Guide:** `../HUONG_DAN.md` (Vietnamese - Hướng dẫn đầy đủ)
- **API Testing:** `../backend/API_TEST.md`

---

## ⚠️ Lưu ý

1. **Luôn chạy với SYSDBA:** Tất cả scripts cần quyền SYSDBA
2. **Container:** Đảm bảo đang ở ORCLPDB (không phải CDB root)
3. **Backup:** Nên backup database trước khi chạy setup
4. **Password:** Test users có password mặc định `password123` (nên đổi trong production)

---

## 📞 Support

Nếu gặp vấn đề:

1. Chạy `MAINTENANCE_SCRIPTS.sql` để fix tất cả issues
2. Kiểm tra log file: `setup_all.log` (nếu có)
3. Chạy test suite: `04-tests/RUN_ALL_TESTS.sql`
4. Xem troubleshooting section ở trên

---

**Last Updated:** 2025-12-06
