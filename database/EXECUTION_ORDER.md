# Database Scripts Execution Order

## Thứ tự Chạy Scripts - Quan Trọng!

Các scripts trong thư mục `database/` phải được thực thi theo **đúng thứ tự** như sau. Nếu chạy sai thứ tự, hệ thống sẽ gặp lỗi do thiếu dependencies.

---

## Tổng quan Cấu trúc

```
database/
├── 01-schema/          # Step 1-2: Users và Tables
├── 02-security/        # Step 3-5: Security Policies
├── 03-data/           # Step 6: Sample Data
├── 04-tests/          # Test Scripts (chạy sau khi hoàn tất 1-6)
└── 05-backup-scripts/ # Backup files (không cần chạy)
```

---

## Các Bước Thực thi

### Điều kiện Tiên quyết
- Đã cài đặt Oracle Database 19c
- Có quyền SYSDBA
- PDB ORCLPDB đã mở và sẵn sàng
- Kết nối: `sqlplus sys/oracle@//localhost:1521/ORCLPDB as sysdba`

---

## STEP 1: Tạo Database Users

**File**: `01-schema/step1_create_users.sql`

**Mục đích**: Tạo 8 database users với các roles khác nhau

**Cách chạy**:
```bash
sqlplus sys/oracle@//localhost:1521/ORCLPDB as sysdba
@e:\Desktop\HCMUT\baomat\grade-management-system\database\01-schema\step1_create_users.sql
```

**Kết quả**: 8 users được tạo
- GMS_ADMIN (schema owner)
- GMS_APP (application user)
- GMS_STUDENT, GMS_LECTURER, GMS_ACADEMIC, GMS_DEAN, GMS_DEPT_HEAD, GMS_RELATIVE

**Kiểm tra**:
```sql
SELECT username, account_status FROM dba_users WHERE username LIKE 'GMS_%';
```

**Thời gian ước tính**: 30 giây

---

## STEP 2: Tạo Tables và Relationships

**File**: `01-schema/step2_create_tables.sql`

**Mục đích**: Tạo 15 tables với foreign keys, indexes, và constraints

**Dependencies**: STEP 1 phải hoàn tất (cần GMS_ADMIN user)

**Cách chạy**:
```bash
sqlplus sys/oracle@//localhost:1521/ORCLPDB as sysdba
@e:\Desktop\HCMUT\baomat\grade-management-system\database\01-schema\step2_create_tables.sql
```

**Tables được tạo**:
1. FACULTIES
2. DEPARTMENTS
3. LECTURERS
4. CLASSES
5. STUDENTS
6. RELATIVES
7. STUDENT_RELATIVES
8. COURSES
9. COURSE_SECTIONS
10. ENROLLMENTS
11. GRADES
12. GRADE_SUBMISSION_DEADLINES
13. SYSTEM_USERS
14. AUDIT_LOGS
15. FGA_AUDIT_LOG

**Kiểm tra**:
```sql
SELECT COUNT(*) FROM dba_tables WHERE owner = 'GMS_ADMIN';
-- Kết quả: 15
```

**Thời gian ước tính**: 1-2 phút

---

## STEP 3: Cấu hình Password Profiles

**File**: `02-security/step3_password_profiles.sql`

**Mục đích**: Tạo 5 password profiles với các mức bảo mật khác nhau

**Dependencies**: STEP 1 phải hoàn tất (cần users để gán profiles)

**Cách chạy**:
```bash
sqlplus sys/oracle@//localhost:1521/ORCLPDB as sysdba
@e:\Desktop\HCMUT\baomat\grade-management-system\database\02-security\step3_password_profiles.sql
```

**Profiles được tạo**:
1. GMS_STUDENT_PROFILE (90 days, 5 failed attempts)
2. GMS_LECTURER_PROFILE (90 days, 5 failed attempts)
3. GMS_ADMIN_PROFILE (60 days, 3 failed attempts)
4. GMS_RELATIVE_PROFILE (180 days, 3 failed attempts)
5. GMS_SYSADMIN_PROFILE (30 days, 3 failed attempts)

**Kiểm tra**:
```sql
SELECT profile, resource_name, limit
FROM dba_profiles
WHERE profile LIKE 'GMS_%'
AND resource_name = 'PASSWORD_LIFE_TIME';
```

**Thời gian ước tính**: 30 giây

---

## STEP 4: Cài đặt VPD Policies

**File**: `02-security/step4_vpd_policies.sql`

**Mục đích**: Implement Virtual Private Database (Row-Level Security)

**Dependencies**:
- STEP 1 hoàn tất (cần GMS_ADMIN user)
- STEP 2 hoàn tất (cần tables: STUDENTS, GRADES, RELATIVES, etc.)

**Cách chạy**:
```bash
sqlplus sys/oracle@//localhost:1521/ORCLPDB as sysdba
@e:\Desktop\HCMUT\baomat\grade-management-system\database\02-security\step4_vpd_policies.sql
```

**Thành phần**:
1. Security Context: GMS_CONTEXT
2. Security Package: GMS_SECURITY_PKG (7 policy functions)
3. 6 VPD Policies:
   - student_access_policy (STUDENTS)
   - grade_student_policy (GRADES)
   - grade_lecturer_policy (GRADES)
   - grade_relative_policy (GRADES)
   - relative_access_policy (RELATIVES)
   - student_relative_policy (STUDENT_RELATIVES)

**Kiểm tra**:
```sql
SELECT object_name, policy_name, enable
FROM dba_policies
WHERE object_owner = 'GMS_ADMIN';
-- Kết quả: 6 policies
```

**Thời gian ước tính**: 1 phút

---

## STEP 5: Cài đặt Audit Policies

**File**: `02-security/step5_audit_policies.sql`

**Mục đích**: Implement Fine-Grained Auditing (FGA) và audit triggers

**Dependencies**:
- STEP 1 hoàn tất (cần GMS_ADMIN user)
- STEP 2 hoàn tất (cần tables: GRADES, STUDENTS, AUDIT_LOGS, FGA_AUDIT_LOG)

**Cách chạy**:
```bash
sqlplus sys/oracle@//localhost:1521/ORCLPDB as sysdba
@e:\Desktop\HCMUT\baomat\grade-management-system\database\02-security\step5_audit_policies.sql
```

**Thành phần**:
1. Audit Handler: audit_grade_handler (procedure)
2. 8 FGA Policies:
   - fga_grade_update
   - fga_grade_delete
   - fga_student_update
   - fga_student_delete
   - fga_enrollment_insert
   - fga_enrollment_delete
   - fga_relative_access
   - fga_system_user_changes
3. 2 Audit Triggers:
   - trg_audit_grade_insert
   - trg_audit_student_insert

**Kiểm tra**:
```sql
-- Check FGA policies
SELECT object_name, policy_name
FROM dba_audit_policies
WHERE object_schema = 'GMS_ADMIN';
-- Kết quả: 8 policies

-- Check triggers
SELECT trigger_name, status
FROM dba_triggers
WHERE owner = 'GMS_ADMIN' AND trigger_name LIKE 'TRG_AUDIT%';
-- Kết quả: 2 triggers, ENABLED
```

**Thời gian ước tính**: 1 phút

---

## STEP 6: Load Sample Data

**File**: `03-data/step6_sample_data.sql`

**Mục đích**: Load sample data để testing và demonstration

**Dependencies**: STEP 2 phải hoàn tất (cần tất cả tables)

**Cách chạy**:
```bash
sqlplus sys/oracle@//localhost:1521/ORCLPDB as sysdba
@e:\Desktop\HCMUT\baomat\grade-management-system\database\03-data\step6_sample_data.sql
```

**Data được load**:
- 3 Faculties (FAC001, FAC002, FAC003)
- 4 Departments
- 5 Lecturers (LEC001-LEC005)
- 4 Classes (CLS001-CLS004)
- 5 Students (STU001-STU005)
- 3 Relatives (REL001-REL003)
- 6 Courses (CSE101, CSE201, CSE301, CSE401, EEE101, EEE201)
- 5 Course Sections
- 9 Enrollments
- 7 Grades
- 3 Grade Submission Deadlines
- 8 System Users

**Kiểm tra**:
```sql
SELECT 'STUDENTS' as table_name, COUNT(*) FROM gms_admin.STUDENTS
UNION ALL
SELECT 'GRADES', COUNT(*) FROM gms_admin.GRADES
UNION ALL
SELECT 'LECTURERS', COUNT(*) FROM gms_admin.LECTURERS;
-- Kết quả: 5 students, 7 grades, 5 lecturers
```

**Thời gian ước tính**: 30 giây

---

## Testing (Optional - Sau khi hoàn tất Step 1-6)

### Test 1: Comprehensive System Tests

**File**: `04-tests/02_comprehensive_tests.sql`

**Mục đích**: 29 test cases across 10 test suites

**Cách chạy**:
```bash
sqlplus sys/oracle@//localhost:1521/ORCLPDB as sysdba
@e:\Desktop\HCMUT\baomat\grade-management-system\database\04-tests\02_comprehensive_tests.sql
```

**Kết quả mong đợi**: 29/29 tests PASSED

**Thời gian ước tính**: 2-3 phút

---

### Test 2: VPD Policy Context Testing

**File**: `04-tests/01_test_vpd_policies.sql`

**Mục đích**: Test VPD policies với different contexts (Student, Lecturer, Dean, etc.)

**Cách chạy**:
```bash
sqlplus sys/oracle@//localhost:1521/ORCLPDB as sysdba
@e:\Desktop\HCMUT\baomat\grade-management-system\database\04-tests\01_test_vpd_policies.sql
```

**Lưu ý**: Test này chạy dưới SYSDBA nên VPD policies sẽ KHÔNG filter data (VPD exempts SYSDBA)

**Thời gian ước tính**: 1 phút

---

### Test 3: VPD Actual User Testing

**File**: `04-tests/03_vpd_actual_test.sql`

**Mục đích**: Hướng dẫn test VPD với actual non-privileged users

**LƯU Ý QUAN TRỌNG**: Trước khi test, phải grant privileges:

```sql
-- Kết nối SYSDBA
sqlplus sys/oracle@//localhost:1521/ORCLPDB as sysdba

-- Grant cho Student
GRANT SELECT ON gms_admin.STUDENTS TO GMS_STUDENT;
GRANT SELECT ON gms_admin.GRADES TO GMS_STUDENT;
GRANT SELECT ON gms_admin.ENROLLMENTS TO GMS_STUDENT;
GRANT EXECUTE ON gms_admin.gms_security_pkg TO GMS_STUDENT;

-- Grant cho Lecturer
GRANT SELECT ON gms_admin.STUDENTS TO GMS_LECTURER;
GRANT SELECT ON gms_admin.GRADES TO GMS_LECTURER;
GRANT SELECT ON gms_admin.ENROLLMENTS TO GMS_LECTURER;
GRANT SELECT ON gms_admin.COURSE_SECTIONS TO GMS_LECTURER;
GRANT EXECUTE ON gms_admin.gms_security_pkg TO GMS_LECTURER;

-- Grant cho Relative
GRANT SELECT ON gms_admin.RELATIVES TO GMS_RELATIVE;
GRANT SELECT ON gms_admin.GRADES TO GMS_RELATIVE;
GRANT SELECT ON gms_admin.ENROLLMENTS TO GMS_RELATIVE;
GRANT EXECUTE ON gms_admin.gms_security_pkg TO GMS_RELATIVE;
```

**Cách test Student**:
```bash
# Mở SQL*Plus mới
sqlplus GMS_STUDENT/Student@2024@//localhost:1521/ORCLPDB

EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');

-- Should see only 1 student (STU001)
SELECT COUNT(*) FROM gms_admin.STUDENTS;

-- Should see only 3 grades (STU001's grades)
SELECT COUNT(*) FROM gms_admin.GRADES g
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id;
```

**Thời gian ước tính**: 5 phút (for all 3 user types)

---

## Tổng kết Thời gian

| Step | File | Thời gian |
|------|------|-----------|
| 1 | step1_create_users.sql | 30s |
| 2 | step2_create_tables.sql | 1-2m |
| 3 | step3_password_profiles.sql | 30s |
| 4 | step4_vpd_policies.sql | 1m |
| 5 | step5_audit_policies.sql | 1m |
| 6 | step6_sample_data.sql | 30s |
| **Tổng** | **Steps 1-6** | **~5 phút** |
| Testing | All test suites | 8-10m |

---

## Script Chạy Nhanh (Quick Setup)

Nếu muốn chạy toàn bộ trong một session:

```bash
sqlplus sys/oracle@//localhost:1521/ORCLPDB as sysdba

-- Chạy tuần tự
@e:\Desktop\HCMUT\baomat\grade-management-system\database\01-schema\step1_create_users.sql
@e:\Desktop\HCMUT\baomat\grade-management-system\database\01-schema\step2_create_tables.sql
@e:\Desktop\HCMUT\baomat\grade-management-system\database\02-security\step3_password_profiles.sql
@e:\Desktop\HCMUT\baomat\grade-management-system\database\02-security\step4_vpd_policies.sql
@e:\Desktop\HCMUT\baomat\grade-management-system\database\02-security\step5_audit_policies.sql
@e:\Desktop\HCMUT\baomat\grade-management-system\database\03-data\step6_sample_data.sql

-- Chạy test
@e:\Desktop\HCMUT\baomat\grade-management-system\database\04-tests\02_comprehensive_tests.sql
```

---

## Xử lý Lỗi

### Nếu gặp lỗi ở bất kỳ step nào:

1. **Không tiếp tục các steps sau** - sẽ gặp lỗi dependency
2. **Kiểm tra lỗi chi tiết** trong output
3. **Fix lỗi** theo hướng dẫn trong SETUP_GUIDE.md
4. **Re-run script bị lỗi** sau khi fix
5. **Tiếp tục từ step tiếp theo**

### Rollback và Restart:

Nếu muốn bắt đầu lại từ đầu:

```sql
-- Kết nối SYSDBA
sqlplus sys/oracle@//localhost:1521/ORCLPDB as sysdba

-- Drop tất cả (thận trọng!)
DROP USER GMS_ADMIN CASCADE;
DROP USER GMS_APP CASCADE;
DROP USER GMS_STUDENT CASCADE;
DROP USER GMS_LECTURER CASCADE;
DROP USER GMS_ACADEMIC CASCADE;
DROP USER GMS_DEAN CASCADE;
DROP USER GMS_DEPT_HEAD CASCADE;
DROP USER GMS_RELATIVE CASCADE;

-- Drop profiles
DROP PROFILE GMS_STUDENT_PROFILE CASCADE;
DROP PROFILE GMS_LECTURER_PROFILE CASCADE;
DROP PROFILE GMS_ADMIN_PROFILE CASCADE;
DROP PROFILE GMS_RELATIVE_PROFILE CASCADE;
DROP PROFILE GMS_SYSADMIN_PROFILE CASCADE;

-- Sau đó chạy lại từ Step 1
```

---

## Lưu ý Quan trọng

1. **Luôn chạy với SYSDBA privilege** cho Steps 1-6
2. **Đảm bảo đang ở ORCLPDB**, không phải CDB$ROOT
3. **Chạy đúng thứ tự** - không được skip steps
4. **Kiểm tra kết quả** sau mỗi step trước khi tiếp tục
5. **VPD testing** phải dùng non-privileged users, không test với SYSDBA
6. **Backup scripts** trong `05-backup-scripts/` không cần chạy

---

## Tài liệu Tham khảo

- [SETUP_GUIDE.md](../SETUP_GUIDE.md) - Hướng dẫn chi tiết cài đặt
- [IMPLEMENTATION_SUMMARY.md](../IMPLEMENTATION_SUMMARY.md) - Technical details
- [TEST_REPORT.md](../TEST_REPORT.md) - Kết quả testing

**Good luck with your deployment!**
