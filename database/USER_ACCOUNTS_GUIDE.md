# 📋 HƯỚNG DẪN KIỂM TRA TÀI KHOẢN VÀ QUYỀN TRUY CẬP

## 🎯 Mục đích

Hướng dẫn kiểm tra:

1. Các Oracle DB users đã được tạo và có quyền chưa
2. Mapping giữa SYSTEM_USERS và các bảng thực tế (STUDENTS, LECTURERS, etc.)
3. Cách demo/test quyền truy cập của từng user

---

## 📊 CẤU TRÚC TÀI KHOẢN

### 1. Oracle DB Users (Để connect vào database)

Các user này được tạo trong `step1_create_users.sql`:

| Oracle User     | Password            | Mục đích                        |
| --------------- | ------------------- | ------------------------------- |
| `GMS_ADMIN`     | `Admin@2024#Secure` | Schema owner, có toàn quyền     |
| `GMS_APP`       | `App@2024#Connect`  | Application user (backend dùng) |
| `GMS_STUDENT`   | `Student@2024`      | Test user cho Student role      |
| `GMS_LECTURER`  | `Lecturer@2024`     | Test user cho Lecturer role     |
| `GMS_RELATIVE`  | `Relative@2024`     | Test user cho Relative role     |
| `GMS_ACADEMIC`  | `Academic@2024`     | Test user cho Academic Affairs  |
| `GMS_DEAN`      | `Dean@2024`         | Test user cho Dean role         |
| `GMS_DEPT_HEAD` | `DeptHead@2024`     | Test user cho Department Head   |

**Lưu ý:** Các Oracle users này chỉ dùng để **connect vào database**, không phải để login vào app.

---

### 2. System Users (Trong bảng SYSTEM_USERS)

Các user này được tạo trong `step6_sample_data.sql` và dùng để **login vào app**:

| User ID | Username | User Type        | Reference ID | Maps to               |
| ------- | -------- | ---------------- | ------------ | --------------------- |
| USR001  | admin    | Admin            | GMS_ADMIN    | System Admin          |
| USR002  | nvhai    | Student          | STU001       | STUDENTS.student_id   |
| USR003  | tthoa    | Student          | STU002       | STUDENTS.student_id   |
| USR004  | nv.an    | Lecturer         | LEC001       | LECTURERS.lecturer_id |
| USR005  | tt.binh  | Lecturer         | LEC002       | LECTURERS.lecturer_id |
| USR006  | nvhung   | Relative         | REL001       | RELATIVES.relative_id |
| USR007  | academic | Academic_Affairs | ACAD001      | N/A (system user)     |
| USR008  | dean     | Dean             | LEC001       | LECTURERS.lecturer_id |

**Mapping:**

- `Student` → `reference_id` trỏ đến `STUDENTS.student_id`
- `Lecturer` → `reference_id` trỏ đến `LECTURERS.lecturer_id`
- `Relative` → `reference_id` trỏ đến `RELATIVES.relative_id`
- `Dean` → `reference_id` trỏ đến `LECTURERS.lecturer_id` (Dean là Lecturer)
- `Academic_Affairs` → `reference_id` là system ID (không map đến bảng cụ thể)

---

## 🔍 KIỂM TRA TÀI KHOẢN VÀ QUYỀN

### Bước 1: Kiểm tra Oracle DB Users

```sql
-- Connect với quyền SYSDBA
sqlplus sys/YOUR_PASSWORD@//localhost:1521/ORCLPDB as sysdba

-- Chạy script kiểm tra
@database/scripts/CHECK_USER_ACCOUNTS.sql
```

Script này sẽ hiển thị:

- ✅ Danh sách Oracle users đã tạo
- ✅ Quyền truy cập của từng user
- ✅ Mapping SYSTEM_USERS với các bảng
- ✅ Cách set VPD context cho từng user

---

### Bước 2: Kiểm tra Quyền Truy cập

**Lưu ý quan trọng:** Các Oracle users (GMS_STUDENT, GMS_LECTURER, etc.) **CHƯA có quyền SELECT** trên các bảng sau khi chạy `step1_create_users.sql`.

**Cần chạy script cấp quyền:**

```sql
-- Connect với quyền SYSDBA
sqlplus sys/YOUR_PASSWORD@//localhost:1521/ORCLPDB as sysdba

-- Cấp quyền cho các test users
@database/04-tests/00_grant_test_privileges.sql
```

Script này sẽ cấp:

- ✅ `SELECT` trên các bảng cần thiết
- ✅ `UPDATE` (column-level) cho STUDENTS, LECTURERS, RELATIVES
- ✅ `EXECUTE` trên `gms_security_pkg`

---

### Bước 3: Kiểm tra Mapping

```sql
-- Connect với GMS_ADMIN
sqlplus GMS_ADMIN/Admin@2024#Secure@//localhost:1521/ORCLPDB

-- Xem mapping SYSTEM_USERS
SELECT
    su.user_id,
    su.username,
    su.user_type,
    su.reference_id,
    CASE
        WHEN su.user_type = 'Student' THEN
            (SELECT first_name || ' ' || last_name FROM STUDENTS WHERE student_id = su.reference_id)
        WHEN su.user_type IN ('Lecturer', 'Dean', 'Department_Head') THEN
            (SELECT first_name || ' ' || last_name FROM LECTURERS WHERE lecturer_id = su.reference_id)
        WHEN su.user_type = 'Relative' THEN
            (SELECT first_name || ' ' || last_name FROM RELATIVES WHERE relative_id = su.reference_id)
        ELSE 'System User'
    END AS "Name"
FROM SYSTEM_USERS su
ORDER BY su.user_type, su.user_id;
```

---

## 🧪 DEMO QUYỀN TRUY CẬP

### Demo 1: Test với GMS_STUDENT (STU001)

**Lưu ý:** Khi test trực tiếp bằng SQL\*Plus, bạn cần set context thủ công. Trong app (qua backend), context được set tự động, không cần làm gì.

```sql
-- 1. Connect với GMS_STUDENT
sqlplus GMS_STUDENT/Student@2024@//localhost:1521/ORCLPDB

-- 2. Set VPD context THỦ CÔNG (chỉ khi test trực tiếp, không cần trong app)
-- Trong app, backend tự động set context trước mỗi request
EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');

-- 3. Kiểm tra context
SELECT
    SYS_CONTEXT('gms_context', 'user_id') AS user_id,
    SYS_CONTEXT('gms_context', 'user_type') AS user_type
FROM dual;

-- 4. Query STUDENTS (chỉ thấy 1 record - STU001)
SELECT
    student_id,
    first_name || ' ' || last_name AS name,
    email,
    class_id
FROM gms_admin.STUDENTS;

-- 5. Query GRADES (chỉ thấy điểm của STU001)
SELECT
    g.grade_id,
    c.course_name,
    g.midterm_score,
    g.final_score,
    g.total_score,
    g.letter_grade
FROM gms_admin.GRADES g
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN gms_admin.COURSES c ON cs.course_id = c.course_id
WHERE e.student_id = 'STU001';

-- 6. Thử xem sinh viên khác (sẽ không thấy - VPD filter)
SELECT COUNT(*) AS "Số sinh viên có thể xem" FROM gms_admin.STUDENTS;
-- Kết quả: 1 (chỉ STU001)
```

---

### Demo 2: Test với GMS_LECTURER (LEC001)

**Lưu ý:** Khi test trực tiếp bằng SQL\*Plus, bạn cần set context thủ công. Trong app (qua backend), context được set tự động.

```sql
-- 1. Connect với GMS_LECTURER
sqlplus GMS_LECTURER/Lecturer@2024@//localhost:1521/ORCLPDB

-- 2. Set VPD context THỦ CÔNG (chỉ khi test trực tiếp)
-- Trong app, backend tự động set context trước mỗi request
EXEC gms_admin.gms_security_pkg.set_user_context('LEC001', 'Lecturer');

-- 3. Query STUDENTS (chỉ thấy sinh viên trong lớp mình chủ nhiệm)
SELECT
    s.student_id,
    s.first_name || ' ' || s.last_name AS name,
    c.class_name
FROM gms_admin.STUDENTS s
JOIN gms_admin.CLASSES c ON s.class_id = c.class_id
WHERE c.homeroom_teacher_id = 'LEC001';

-- 4. Query GRADES (chỉ thấy điểm của môn mình dạy)
SELECT
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    c.course_name,
    g.midterm_score,
    g.final_score,
    g.total_score,
    g.letter_grade
FROM gms_admin.GRADES g
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN gms_admin.STUDENTS s ON e.student_id = s.student_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN gms_admin.COURSES c ON cs.course_id = c.course_id
WHERE cs.lecturer_id = 'LEC001';

-- 5. Thử update điểm (chỉ có thể update điểm của môn mình dạy)
UPDATE gms_admin.GRADES
SET midterm_score = 8.5
WHERE enrollment_id IN (
    SELECT e.enrollment_id
    FROM gms_admin.ENROLLMENTS e
    JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
    WHERE cs.lecturer_id = 'LEC001'
    AND e.enrollment_id = 1  -- Chỉ update 1 grade cụ thể
);
COMMIT;
```

---

### Demo 3: Test với GMS_ACADEMIC (Academic Affairs)

**Lưu ý:** Khi test trực tiếp bằng SQL\*Plus, bạn cần set context thủ công. Trong app (qua backend), context được set tự động.

```sql
-- 1. Connect với GMS_ACADEMIC
sqlplus GMS_ACADEMIC/Academic@2024@//localhost:1521/ORCLPDB

-- 2. Set VPD context THỦ CÔNG (chỉ khi test trực tiếp)
-- Trong app, backend tự động set context trước mỗi request
EXEC gms_admin.gms_security_pkg.set_user_context('ACAD001', 'Academic_Affairs');

-- 3. Query STUDENTS (thấy TẤT CẢ)
SELECT COUNT(*) AS "Tổng số sinh viên" FROM gms_admin.STUDENTS;

-- 4. Query GRADES (thấy TẤT CẢ)
SELECT COUNT(*) AS "Tổng số điểm" FROM gms_admin.GRADES;

-- 5. Xem tất cả điểm chi tiết
SELECT
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    c.course_name,
    g.midterm_score,
    g.final_score,
    g.total_score,
    g.letter_grade,
    g.grade_status
FROM gms_admin.GRADES g
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN gms_admin.STUDENTS s ON e.student_id = s.student_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN gms_admin.COURSES c ON cs.course_id = c.course_id
ORDER BY s.student_id, c.course_name;
```

---

## 📝 SỬ DỤNG SCRIPT DEMO

Để demo nhanh, chạy script:

```sql
-- Connect với GMS_ADMIN
sqlplus GMS_ADMIN/Admin@2024#Secure@//localhost:1521/ORCLPDB

-- Chạy script demo
@database/scripts/DEMO_USER_ACCESS.sql
```

Script này sẽ:

- ✅ Set context cho từng user type
- ✅ Query và hiển thị kết quả
- ✅ So sánh quyền truy cập giữa các roles

---

## 🔐 KIỂM TRA QUYỀN CHI TIẾT

### Kiểm tra quyền của một user cụ thể:

```sql
-- Xem quyền SELECT
SELECT
    table_name,
    privilege
FROM dba_tab_privs
WHERE grantee = 'GMS_STUDENT'
  AND owner = 'GMS_ADMIN'
ORDER BY table_name, privilege;

-- Xem quyền UPDATE (column-level)
SELECT
    table_name,
    column_name,
    privilege
FROM dba_col_privs
WHERE grantee = 'GMS_STUDENT'
  AND owner = 'GMS_ADMIN'
ORDER BY table_name, column_name;

-- Xem quyền EXECUTE
SELECT
    object_name,
    privilege
FROM dba_proc_privs
WHERE grantee = 'GMS_STUDENT'
  AND owner = 'GMS_ADMIN'
ORDER BY object_name;
```

---

## 🎯 TÓM TẮT

### Oracle DB Users vs System Users

| Loại               | Mục đích             | Ví dụ              | Password       |
| ------------------ | -------------------- | ------------------ | -------------- |
| **Oracle DB User** | Connect vào database | `GMS_STUDENT`      | `Student@2024` |
| **System User**    | Login vào app        | `nvhai` (username) | Hash trong DB  |

### Mapping Flow

```
App Login (username: nvhai)
    ↓
SYSTEM_USERS (username = 'nvhai')
    ↓
reference_id = 'STU001'
    ↓
STUDENTS (student_id = 'STU001')
    ↓
Backend set VPD context: set_user_context('STU001', 'Student')
    ↓
VPD filter: chỉ thấy data của STU001
```

### Checklist Kiểm tra

- [ ] Oracle DB users đã được tạo (`step1_create_users.sql`)
- [ ] Quyền đã được cấp (`00_grant_test_privileges.sql`)
- [ ] SYSTEM_USERS đã được tạo (`step6_sample_data.sql`)
- [ ] Mapping đúng (reference_id → STUDENTS/LECTURERS/RELATIVES)
- [ ] VPD context có thể set được
- [ ] VPD filter hoạt động đúng (mỗi user chỉ thấy data của mình)

---

## 🔐 VPD CONTEXT - Tự động hay thủ công?

### ⚠️ QUAN TRỌNG: Context được set tự động trong app!

**Trong app (qua backend):**

- ✅ Backend tự động set context khi user login
- ✅ Backend tự động set context trước mỗi request (Interceptor)
- ✅ User không cần làm gì cả
- ✅ Không cần LOGON TRIGGER

**Khi test trực tiếp (SQL\*Plus):**

- ⚠️ Cần set context thủ công
- ⚠️ Vì không có backend để set tự động
- ⚠️ Chỉ để test/demo VPD

**Xem chi tiết:** `VPD_CONTEXT_EXPLAINED.md`

---

## 📚 Files liên quan

- `VPD_CONTEXT_EXPLAINED.md` - ⭐ Giải thích chi tiết về VPD context
- `scripts/CHECK_USER_ACCOUNTS.sql` - Kiểm tra tài khoản và quyền
- `scripts/DEMO_USER_ACCESS.sql` - Demo quyền truy cập
- `scripts/CHECK_MAPPING.sql` - Kiểm tra mapping đơn giản
- `04-tests/00_grant_test_privileges.sql` - Cấp quyền cho test users
- `QUERY_SAMPLES.sql` - Các query mẫu để demo

---

**Last Updated:** 2025-01-XX
