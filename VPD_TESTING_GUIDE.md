# VPD Testing Quick Start Guide

## Vấn đề đã khắc phục

### 1. TNS Connection Error (ORA-12543)
**Nguyên nhân:** File `tnsnames.ora` thiếu entry cho ORCLPDB

**Đã fix:** Đã thêm ORCLPDB vào `E:\Desktop\WINDOWS.X64_193000_db_home\network\admin\tnsnames.ora`

```
ORCLPDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orclpdb)
    )
  )
```

### 2. Password với ký tự @ trong SQL*Plus
**Vấn đề:** Password `Student@2024` có chứa `@` gây conflict với connection string trên Windows

**Giải pháp:**
- ✅ **Khuyến nghị:** Dùng DBeaver (GUI tool, không bị conflict)
- ⚠️ **SQL*Plus:** Chỉ dùng `sqlplus USERNAME@ORCLPDB` và nhập password khi được hỏi

### 3. Thiếu Privileges cho Test Users
**Đã fix:** Tạo script `00_grant_test_privileges.sql` và đã chạy thành công

---

## Cách Test VPD Policies (Khuyến nghị)

### Bước 1: Đảm bảo đã grant privileges (CHỈ CHẠY 1 LẦN)

```bash
sqlplus sys/YOUR_PASSWORD@ORCLPDB as sysdba
@e:\Desktop\HCMUT\baomat\grade-management-system\database\04-tests\00_grant_test_privileges.sql
exit
```

✅ **ĐÃ CHẠY XONG** - Không cần chạy lại!

---

### Bước 2: Test với DBeaver (KHUYẾN NGHỊ)

#### Test 1: Student Access (GMS_STUDENT)

1. **Tạo connection trong DBeaver:**
   - Database: Oracle
   - Host: localhost
   - Port: 1521
   - Database/Service: ORCLPDB
   - Username: `GMS_STUDENT`
   - Password: `Student@2024`
   - Click "Test Connection" → Nếu OK, nhấn "Finish"

2. **Mở SQL Editor và chạy:**

```sql
-- Set security context
EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');

-- Verify context
SELECT SYS_CONTEXT('gms_context', 'user_id') as user_id,
       SYS_CONTEXT('gms_context', 'user_type') as user_type
FROM DUAL;

-- Test VPD: Should see only 1 student (STU001)
SELECT COUNT(*) as "Students Visible" FROM gms_admin.STUDENTS;
-- Expected: 1

SELECT student_id, first_name, last_name FROM gms_admin.STUDENTS;
-- Expected: 1 row (STU001 - Nguyen Van A)

-- Test VPD: Should see only STU001's grades
SELECT COUNT(*) as "Grades Visible" FROM gms_admin.GRADES;
-- Expected: 3

SELECT g.grade_id, e.student_id, g.total_score, g.letter_grade
FROM gms_admin.GRADES g
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id;
-- Expected: 3 rows (STU001's grades only)
```

**Kết quả mong đợi:**
- ✅ Students Visible: **1** (chỉ STU001)
- ✅ Grades Visible: **3** (chỉ điểm của STU001)

---

#### Test 2: Lecturer Access (GMS_LECTURER)

1. **Tạo connection mới trong DBeaver:**
   - Username: `GMS_LECTURER`
   - Password: `Lecturer@2024`
   - (Các thông tin khác giống như trên)

2. **Mở SQL Editor và chạy:**

```sql
-- Set security context
EXEC gms_admin.gms_security_pkg.set_user_context('LEC001', 'Lecturer');

-- Verify context
SELECT SYS_CONTEXT('gms_context', 'user_id') as user_id,
       SYS_CONTEXT('gms_context', 'user_type') as user_type
FROM DUAL;

-- Test VPD: Should see only students in LEC001's classes
SELECT COUNT(DISTINCT s.student_id) as "Students in My Classes"
FROM gms_admin.STUDENTS s
JOIN gms_admin.ENROLLMENTS e ON s.student_id = e.student_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
WHERE cs.lecturer_id = 'LEC001';
-- Expected: 2 (students in LEC001's sections)

-- Test VPD: Should see only grades for sections LEC001 teaches
SELECT COUNT(*) as "Grades in My Sections" FROM gms_admin.GRADES;
-- Expected: 4 (grades for LEC001's sections)
```

**Kết quả mong đợi:**
- ✅ Students in My Classes: **2**
- ✅ Grades in My Sections: **4**

---

#### Test 3: Relative Access (GMS_RELATIVE)

1. **Tạo connection mới trong DBeaver:**
   - Username: `GMS_RELATIVE`
   - Password: `Relative@2024`

2. **Mở SQL Editor và chạy:**

```sql
-- Set security context
EXEC gms_admin.gms_security_pkg.set_user_context('REL001', 'Relative');

-- Verify context
SELECT SYS_CONTEXT('gms_context', 'user_id') as user_id,
       SYS_CONTEXT('gms_context', 'user_type') as user_type
FROM DUAL;

-- Test VPD: Should see only REL001's own record
SELECT COUNT(*) as "Relatives Visible" FROM gms_admin.RELATIVES;
-- Expected: 1

-- Test VPD: Should see only their children's grades
SELECT COUNT(*) as "Children's Grades" FROM gms_admin.GRADES;
-- Expected: 3 (STU001's grades)

-- Show which students are their children
SELECT s.student_id, s.first_name, s.last_name, sr.relationship
FROM gms_admin.STUDENT_RELATIVES sr
JOIN gms_admin.STUDENTS s ON sr.student_id = s.student_id
WHERE sr.relative_id = 'REL001';
-- Expected: 1 row (STU001 - Father)
```

**Kết quả mong đợi:**
- ✅ Relatives Visible: **1** (chỉ REL001)
- ✅ Children's Grades: **3** (điểm của con - STU001)

---

## Script tự động (Tất cả tests trong 1 file)

Để chạy tất cả tests một lúc:

```bash
# Trong DBeaver hoặc SQL*Plus (sau khi kết nối với user cụ thể)
@e:\Desktop\HCMUT\baomat\grade-management-system\database\04-tests\04_vpd_dbeaver_test.sql
```

---

## Troubleshooting

### Lỗi: ORA-12543 TNS:destination host unreachable
**Fix:** Đã thêm ORCLPDB vào tnsnames.ora ✅

### Lỗi: ORA-12154 TNS:could not resolve
**Fix:** Dùng `@ORCLPDB` thay vì `@//localhost:1521/ORCLPDB` ✅

### Lỗi: ORA-01017 invalid username/password
**Check:**
```sql
-- Kết nối SYSDBA
sqlplus sys/YOUR_PASSWORD@ORCLPDB as sysdba

-- Kiểm tra user
SELECT username, account_status FROM dba_users WHERE username = 'GMS_STUDENT';
-- Should be: GMS_STUDENT | OPEN
```

### Lỗi: ORA-00942 table or view does not exist
**Fix:** Chạy grant script:
```bash
sqlplus sys/YOUR_PASSWORD@ORCLPDB as sysdba
@database/04-tests/00_grant_test_privileges.sql
```

---

## Kết luận

✅ **VPD Testing đã sẵn sàng!**

1. ✅ TNS configuration đã fix
2. ✅ Privileges đã grant cho tất cả test users
3. ✅ Scripts test đã chuẩn bị sẵn
4. ✅ Hướng dẫn chi tiết cho DBeaver (khuyến nghị) và SQL*Plus

**Recommended approach:** Sử dụng DBeaver để test VPD policies vì:
- Dễ dùng hơn (GUI)
- Không bị conflict với ký tự @ trong password
- Dễ switch giữa các connections
- Xem kết quả trực quan hơn

**Tài liệu chi tiết:** Xem [HUONG_DAN.md](HUONG_DAN.md#test-3-vpd-actual-user-testing) section "Test 3: VPD Actual User Testing"
