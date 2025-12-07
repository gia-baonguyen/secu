# 🚀 HƯỚNG DẪN CHẠY LẠI TỪ ĐẦU

Hướng dẫn chạy lại toàn bộ database setup từ đầu.

---

## ⚙️ PREREQUISITES

- ✅ Oracle Database 19c đang chạy
- ✅ PDB `ORCLPDB` đã được tạo
- ✅ SQL*Plus hoặc SQL Developer
- ✅ Quyền SYSDBA

---

## 📋 CÁCH 1: CHẠY TẤT CẢ TỪ ĐẦU (KHUYẾN NGHỊ)

### Bước 1: Chạy script tổng hợp

```powershell
cd D:\BaoMatHTTT\secu\database
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@RUN_ALL.sql"
```

Script này sẽ tự động:
1. ✅ Chạy SETUP_ALL.sql (setup toàn bộ database)
2. ✅ Grant test privileges
3. ✅ Chạy MAINTENANCE_SCRIPTS.sql (fix tất cả issues)

**Thời gian:** ~5-10 phút

---

## 📋 CÁCH 2: CHẠY TỪNG BƯỚC

### Bước 1: Setup Database

```powershell
cd D:\BaoMatHTTT\secu\database
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@SETUP_ALL.sql"
```

### Bước 2: Grant Test Privileges

```powershell
cd D:\BaoMatHTTT\secu\database\04-tests
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@00_grant_test_privileges.sql"
```

### Bước 3: Run Maintenance Scripts

```powershell
cd D:\BaoMatHTTT\secu\database\scripts
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@MAINTENANCE_SCRIPTS.sql"
```

---

## 📋 CÁCH 3: DÙNG BATCH/POWERSHELL SCRIPTS

### Windows Batch:

```cmd
cd D:\BaoMatHTTT\secu\database
run_setup.bat
```

### PowerShell:

```powershell
cd D:\BaoMatHTTT\secu\database
.\run_setup.ps1
```

Sau đó chạy maintenance:

```powershell
cd D:\BaoMatHTTT\secu\database\scripts
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@MAINTENANCE_SCRIPTS.sql"
```

---

## ✅ VERIFY SETUP

### Kiểm tra database:

```sql
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba

-- Kiểm tra users
SELECT username, account_status FROM dba_users WHERE username LIKE 'GMS_%';

-- Kiểm tra tables
SELECT COUNT(*) FROM dba_tables WHERE owner = 'GMS_ADMIN';

-- Kiểm tra VPD policies
SELECT COUNT(*) FROM dba_policies WHERE object_owner = 'GMS_ADMIN';

-- Kiểm tra data
SELECT COUNT(*) FROM gms_admin.STUDENTS;
SELECT COUNT(*) FROM gms_admin.GRADES;
```

### Test với GMS_APP:

```sql
sqlplus GMS_APP/App@2024#Connect@//localhost:1521/ORCLPDB

-- Test query
SELECT COUNT(*) FROM gms_admin.GRADES;
SELECT COUNT(*) FROM gms_admin.STUDENTS;
```

---

## 🔧 FIX CÁC VẤN ĐỀ THƯỜNG GẶP

### Nếu gặp lỗi khi chạy:

**1. Database chưa mở:**
```sql
ALTER PLUGGABLE DATABASE ORCLPDB OPEN;
ALTER PLUGGABLE DATABASE ORCLPDB SAVE STATE;
```

**2. Chạy lại maintenance scripts:**
```powershell
cd D:\BaoMatHTTT\secu\database\scripts
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@MAINTENANCE_SCRIPTS.sql"
```

**3. Kiểm tra log:**
- Xem file `setup_all.log` (nếu có)
- Kiểm tra output trong terminal

---

## 📊 CẤU TRÚC SAU KHI SETUP

```
database/
├── RUN_ALL.sql                    # ⭐ Script chạy tất cả
├── SETUP_ALL.sql                  # Setup database chính
├── 01-schema/                     # Schema creation
│   ├── step1_create_users.sql
│   └── step2_create_tables.sql
├── 02-security/                   # Security configuration
│   ├── step3_password_profiles.sql
│   ├── step4_vpd_policies.sql
│   ├── step5_audit_policies.sql
│   └── step7_ols_setup.sql        # Optional
├── 03-data/                       # Sample data
│   └── step6_sample_data.sql
├── 04-tests/                      # Testing
│   ├── 00_grant_test_privileges.sql
│   └── RUN_ALL_TESTS.sql
└── scripts/                       # Maintenance
    └── MAINTENANCE_SCRIPTS.sql    # ⭐ All-in-one fix script
```

---

## 🎯 QUY TRÌNH CHẠY LẠI ĐẦY ĐỦ

### Lần đầu tiên hoặc chạy lại từ đầu:

```powershell
# 1. Chạy tất cả
cd D:\BaoMatHTTT\secu\database
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@RUN_ALL.sql"

# 2. Verify
cd 04-tests
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@RUN_ALL_TESTS.sql"
```

### Chỉ fix issues (database đã setup):

```powershell
cd D:\BaoMatHTTT\secu\database\scripts
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@MAINTENANCE_SCRIPTS.sql"
```

---

## 📝 TEST USERS

Sau khi setup, có các test users sau:

| Username | Password     | Role     | Reference ID |
| -------- | ------------ | -------- | ------------ |
| nvhai    | password123  | STUDENT  | STU001       |
| nv.an    | password123  | LECTURER | LEC001       |
| admin    | password123  | ADMIN    | GMS_ADMIN    |
| academic | password123  | ACADEMIC | ACAD001      |

---

## 🔗 TÀI LIỆU THAM KHẢO

- **README.md** - Tài liệu đầy đủ
- **DATABASE_CONNECTION_GUIDE.md** - Hướng dẫn kết nối SQL UI
- **QUERY_SAMPLES.sql** - Query mẫu để demo
- **../START_HERE.md** - Hướng dẫn chạy hệ thống (database → backend → flutter)

---

**Last Updated:** 2025-01-XX

