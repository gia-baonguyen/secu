# 🔌 Hướng dẫn kết nối Oracle Database với SQL UI Tools

Hướng dẫn chi tiết cách kết nối vào Oracle Database để query và demo.

---

## 📋 Thông tin kết nối

### Connection Details

| Thông tin | Giá trị |
|-----------|---------|
| **Host** | `localhost` |
| **Port** | `1521` |
| **Service Name** | `ORCLPDB` |
| **Connection String** | `localhost:1521/ORCLPDB` |
| **Easy Connect Format** | `//localhost:1521/ORCLPDB` |

### Database Users

| Username | Password | Role | Mục đích |
|----------|----------|------|----------|
| `GMS_ADMIN` | `Admin@2024#Secure` | Admin | Quản trị, có quyền cao nhất |
| `GMS_APP` | `App@2024#Connect` | Application | Backend application (không dùng để query trực tiếp) |
| `GMS_STUDENT` | `Student@2024` | Student | Test VPD với role Student |
| `GMS_LECTURER` | `Lecturer@2024` | Lecturer | Test VPD với role Lecturer |
| `GMS_ACADEMIC` | `Academic@2024` | Academic Affairs | Test VPD với role Academic |
| `GMS_DEAN` | `Dean@2024` | Dean | Test VPD với role Dean |
| `GMS_DEPT_HEAD` | `DeptHead@2024` | Department Head | Test VPD với role Department Head |
| `GMS_RELATIVE` | `Relative@2024` | Relative | Test VPD với role Relative |
| `SYS` | `123` | SYSDBA | Quản trị hệ thống (chỉ dùng cho setup) |

---

## 🛠️ Cách 1: Oracle SQL Developer

### Bước 1: Download và cài đặt

1. Download từ: https://www.oracle.com/database/sqldeveloper/
2. Giải nén và chạy `sqldeveloper.exe`

### Bước 2: Tạo Connection

1. **Mở SQL Developer**
2. **Click vào biểu tượng "+" (New Connection)** hoặc `File → New → Database Connection`
3. **Điền thông tin:**

   ```
   Connection Name: GMS_ADMIN (hoặc tên bạn muốn)
   Username: GMS_ADMIN
   Password: Admin@2024#Secure
   Role: Default
   
   Connection Type: Basic
   Hostname: localhost
   Port: 1521
   Service name: ORCLPDB
   ```

4. **Test Connection:**
   - Click "Test" để kiểm tra
   - Nếu thành công, sẽ hiện "Status: Success"
   - Click "Save" để lưu connection
   - Click "Connect" để kết nối

### Bước 3: Query mẫu

Sau khi kết nối, mở SQL Worksheet và chạy:

```sql
-- Xem tất cả tables
SELECT table_name 
FROM all_tables 
WHERE owner = 'GMS_ADMIN'
ORDER BY table_name;

-- Xem students
SELECT * FROM gms_admin.STUDENTS;

-- Xem grades
SELECT * FROM gms_admin.GRADES;

-- Xem enrollments
SELECT * FROM gms_admin.ENROLLMENTS;
```

---

## 🛠️ Cách 2: DBeaver (Khuyến nghị cho Windows)

### Bước 1: Download và cài đặt

1. Download từ: https://dbeaver.io/download/
2. Cài đặt DBeaver Community Edition (miễn phí)

### Bước 2: Tạo Connection

1. **Mở DBeaver**
2. **Click "New Database Connection"** (biểu tượng ổ cắm) hoặc `Database → New Database Connection`
3. **Chọn Oracle** → Click "Next"
4. **Điền thông tin:**

   ```
   Host: localhost
   Port: 1521
   Database/Schema: ORCLPDB
   Username: GMS_ADMIN
   Password: Admin@2024#Secure
   ```

5. **Test Connection:**
   - Click "Test Connection"
   - Nếu thiếu driver, DBeaver sẽ tự động download
   - Click "Finish" để lưu

### Bước 3: Query mẫu

Mở SQL Editor và chạy:

```sql
-- Xem tất cả tables
SELECT table_name 
FROM all_tables 
WHERE owner = 'GMS_ADMIN'
ORDER BY table_name;

-- Xem students với thông tin chi tiết
SELECT 
    s.student_id,
    s.first_name || ' ' || s.last_name AS full_name,
    s.email,
    s.phone_number,
    c.class_name,
    f.faculty_name
FROM gms_admin.STUDENTS s
JOIN gms_admin.STUDENT_CLASSES c ON s.class_id = c.class_id
JOIN gms_admin.FACULTIES f ON c.faculty_id = f.faculty_id
ORDER BY s.student_id;

-- Xem grades với thông tin môn học
SELECT 
    g.grade_id,
    s.first_name || ' ' || s.last_name AS student_name,
    cs.course_code || ' - ' || cs.course_name AS course,
    g.grade_value,
    g.grade_letter,
    g.grade_date
FROM gms_admin.GRADES g
JOIN gms_admin.STUDENTS s ON g.student_id = s.student_id
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
ORDER BY g.grade_date DESC;
```

---

## 🛠️ Cách 3: Toad for Oracle (Nếu có license)

### Bước 1: Tạo Connection

1. **Mở Toad**
2. **File → New → Database Connection**
3. **Điền thông tin:**

   ```
   User/Schema: GMS_ADMIN
   Password: Admin@2024#Secure
   Connect As: Normal
   
   Database: ORCLPDB
   Host: localhost
   Port: 1521
   ```

4. **Click "Connect"**

---

## 🛠️ Cách 4: Oracle SQL Developer Web (Nếu có Oracle REST Data Services)

Nếu bạn có Oracle REST Data Services (ORDS) đã cài đặt:

1. Truy cập: `http://localhost:8080/ords/sql-developer`
2. Login với Oracle user credentials

---

## 🔐 Test VPD (Virtual Private Database) với các users khác nhau

### Quan trọng: VPD Context

Khi kết nối với các users như `GMS_STUDENT`, `GMS_LECTURER`, bạn cần **set VPD context** trước khi query để VPD policies hoạt động.

### Bước 1: Kết nối với GMS_STUDENT

**Trong DBeaver hoặc SQL Developer:**

1. Tạo connection mới:
   - Username: `GMS_STUDENT`
   - Password: `Student@2024`
   - Service: `ORCLPDB`

2. **Set VPD Context:**

```sql
-- Set context cho Student STU001
BEGIN
    gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');
END;
/

-- Kiểm tra context đã set chưa
SELECT 
    SYS_CONTEXT('gms_context', 'user_id') AS user_id,
    SYS_CONTEXT('gms_context', 'user_type') AS user_type,
    SYS_CONTEXT('gms_context', 'student_id') AS student_id,
    SYS_CONTEXT('gms_context', 'class_id') AS class_id
FROM DUAL;
```

3. **Query với VPD (chỉ thấy data của mình):**

```sql
-- Student chỉ thấy grades của mình
SELECT * FROM gms_admin.GRADES;

-- Student chỉ thấy enrollments của mình
SELECT * FROM gms_admin.ENROLLMENTS;

-- Student chỉ thấy thông tin của mình
SELECT * FROM gms_admin.STUDENTS;
```

### Bước 2: Kết nối với GMS_LECTURER

1. Tạo connection mới:
   - Username: `GMS_LECTURER`
   - Password: `Lecturer@2024`

2. **Set VPD Context:**

```sql
-- Set context cho Lecturer LEC001
BEGIN
    gms_admin.gms_security_pkg.set_user_context('LEC001', 'Lecturer');
END;
/

-- Kiểm tra context
SELECT 
    SYS_CONTEXT('gms_context', 'user_id') AS user_id,
    SYS_CONTEXT('gms_context', 'user_type') AS user_type,
    SYS_CONTEXT('gms_context', 'lecturer_id') AS lecturer_id
FROM DUAL;
```

3. **Query với VPD:**

```sql
-- Lecturer chỉ thấy students trong lớp mình dạy
SELECT * FROM gms_admin.STUDENTS;

-- Lecturer chỉ thấy grades của students mình dạy
SELECT * FROM gms_admin.GRADES;
```

---

## 📊 Query mẫu để Demo

### 1. Xem tất cả dữ liệu (với GMS_ADMIN)

```sql
-- Tổng quan hệ thống
SELECT 
    'Students' AS entity, COUNT(*) AS count FROM gms_admin.STUDENTS
UNION ALL
SELECT 'Lecturers', COUNT(*) FROM gms_admin.LECTURERS
UNION ALL
SELECT 'Grades', COUNT(*) FROM gms_admin.GRADES
UNION ALL
SELECT 'Enrollments', COUNT(*) FROM gms_admin.ENROLLMENTS
UNION ALL
SELECT 'Courses', COUNT(*) FROM gms_admin.COURSES;

-- Students với thông tin đầy đủ
SELECT 
    s.student_id,
    s.first_name || ' ' || s.last_name AS full_name,
    s.email,
    s.phone_number,
    c.class_name,
    f.faculty_name,
    s.student_status
FROM gms_admin.STUDENTS s
JOIN gms_admin.STUDENT_CLASSES c ON s.class_id = c.class_id
JOIN gms_admin.FACULTIES f ON c.faculty_id = f.faculty_id
ORDER BY s.student_id;

-- Grades với thông tin chi tiết
SELECT 
    g.grade_id,
    s.first_name || ' ' || s.last_name AS student_name,
    cs.course_code || ' - ' || cs.course_name AS course,
    g.grade_value,
    g.grade_letter,
    TO_CHAR(g.grade_date, 'DD/MM/YYYY') AS grade_date,
    l.first_name || ' ' || l.last_name AS lecturer_name
FROM gms_admin.GRADES g
JOIN gms_admin.STUDENTS s ON g.student_id = s.student_id
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN gms_admin.LECTURERS l ON cs.lecturer_id = l.lecturer_id
ORDER BY g.grade_date DESC;

-- GPA của từng student
SELECT 
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    ROUND(AVG(g.grade_value), 2) AS gpa,
    COUNT(g.grade_id) AS total_grades
FROM gms_admin.STUDENTS s
LEFT JOIN gms_admin.GRADES g ON s.student_id = g.student_id
GROUP BY s.student_id, s.first_name, s.last_name
ORDER BY gpa DESC NULLS LAST;
```

### 2. Test VPD với GMS_STUDENT

```sql
-- Set context
BEGIN
    gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');
END;
/

-- Student chỉ thấy grades của mình
SELECT 
    g.grade_id,
    cs.course_code || ' - ' || cs.course_name AS course,
    g.grade_value,
    g.grade_letter,
    TO_CHAR(g.grade_date, 'DD/MM/YYYY') AS grade_date
FROM gms_admin.GRADES g
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
ORDER BY g.grade_date DESC;

-- Student chỉ thấy enrollments của mình
SELECT 
    e.enrollment_id,
    cs.course_code || ' - ' || cs.course_name AS course,
    TO_CHAR(e.enrollment_date, 'DD/MM/YYYY') AS enrollment_date,
    e.enrollment_status
FROM gms_admin.ENROLLMENTS e
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
ORDER BY e.enrollment_date DESC;
```

### 3. Test VPD với GMS_LECTURER

```sql
-- Set context
BEGIN
    gms_admin.gms_security_pkg.set_user_context('LEC001', 'Lecturer');
END;
/

-- Lecturer chỉ thấy students trong lớp mình dạy
SELECT 
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    c.class_name,
    COUNT(g.grade_id) AS total_grades,
    ROUND(AVG(g.grade_value), 2) AS avg_grade
FROM gms_admin.STUDENTS s
JOIN gms_admin.STUDENT_CLASSES c ON s.class_id = c.class_id
LEFT JOIN gms_admin.GRADES g ON s.student_id = g.student_id
GROUP BY s.student_id, s.first_name, s.last_name, c.class_name
ORDER BY s.student_id;
```

---

## ⚠️ Lưu ý quan trọng

### 1. VPD Context

- **VPD chỉ hoạt động khi context được set**
- **Mỗi session cần set context riêng**
- **Context không tự động persist giữa các connections**

### 2. Schema Prefix

- **Luôn dùng schema prefix:** `gms_admin.TABLE_NAME`
- **Hoặc set default schema:** `ALTER SESSION SET CURRENT_SCHEMA = GMS_ADMIN;`

### 3. Permissions

- **GMS_ADMIN:** Có quyền cao nhất, thấy tất cả data
- **GMS_STUDENT, GMS_LECTURER, etc.:** Chỉ thấy data của mình (VPD)
- **Cần grant permissions trước khi test VPD:** Chạy `04-tests/00_grant_test_privileges.sql`

### 4. Connection String Format

- **Easy Connect:** `//localhost:1521/ORCLPDB` (khuyến nghị)
- **TNS:** Cần cấu hình `tnsnames.ora`
- **JDBC:** `jdbc:oracle:thin:@//localhost:1521/ORCLPDB`

---

## 🔧 Troubleshooting

### Lỗi: ORA-12154 TNS could not resolve

**Giải pháp:** Dùng Easy Connect format:
```
Host: localhost
Port: 1521
Service: ORCLPDB
```

### Lỗi: ORA-01017 invalid username/password

**Giải pháp:**
1. Kiểm tra password đúng chưa
2. Kiểm tra user đã được tạo chưa:
   ```sql
   SELECT username, account_status FROM dba_users WHERE username LIKE 'GMS_%';
   ```

### Lỗi: ORA-00942 table or view does not exist

**Giải pháp:**
1. Dùng schema prefix: `gms_admin.TABLE_NAME`
2. Hoặc set default schema:
   ```sql
   ALTER SESSION SET CURRENT_SCHEMA = GMS_ADMIN;
   ```

### VPD không hoạt động

**Giải pháp:**
1. Kiểm tra context đã set chưa:
   ```sql
   SELECT SYS_CONTEXT('gms_context', 'user_id') FROM DUAL;
   ```
2. Set context trước khi query:
   ```sql
   BEGIN
       gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');
   END;
   /
   ```
3. Kiểm tra policies đã enable chưa:
   ```sql
   SELECT policy_name, object_name, enable 
   FROM dba_policies 
   WHERE object_schema = 'GMS_ADMIN';
   ```

---

## 📚 Tài liệu tham khảo

- **Database Setup:** `README.md`
- **Query Samples:** `QUERY_SAMPLES.sql` - ⭐ File chứa các query mẫu để demo
- **VPD Testing:** `04-tests/RUN_ALL_TESTS.sql`
- **Grant Test Privileges:** `04-tests/00_grant_test_privileges.sql`
- **Main Guide:** `../HUONG_DAN.md`

---

## 📝 File Query Mẫu

File `QUERY_SAMPLES.sql` chứa các query mẫu:
- ✅ Queries với GMS_ADMIN (xem tất cả)
- ✅ Queries với GMS_STUDENT (VPD - chỉ thấy data của mình)
- ✅ Queries với GMS_LECTURER (VPD - chỉ thấy students mình dạy)
- ✅ Kiểm tra VPD context
- ✅ Kiểm tra audit (FGA)
- ✅ Thống kê và báo cáo

**Cách dùng:**
1. Mở file `QUERY_SAMPLES.sql` trong SQL Developer hoặc DBeaver
2. Copy query bạn muốn chạy
3. Paste vào SQL Editor và execute

---

**Last Updated:** 2025-01-XX

