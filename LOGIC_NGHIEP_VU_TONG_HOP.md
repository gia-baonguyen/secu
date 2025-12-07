# TỔNG HỢP LOGIC NGHIỆP VỤ - HỆ THỐNG QUẢN LÝ ĐIỂM ĐẠI HỌC
# BUSINESS LOGIC DOCUMENTATION - UNIVERSITY GRADE MANAGEMENT SYSTEM

> **Version**: 1.0
> **Database**: Oracle 19c+
> **Last Updated**: December 2024

---

## MỤC LỤC / TABLE OF CONTENTS

1. [Tổng quan hệ thống / System Overview](#1-tổng-quan-hệ-thống--system-overview)
2. [Cấu trúc Database / Database Structure](#2-cấu-trúc-database--database-structure)
3. [Phân quyền người dùng / User Authorization](#3-phân-quyền-người-dùng--user-authorization)
4. [Bảo mật cấp hàng - VPD / Row-Level Security](#4-bảo-mật-cấp-hàng---vpd--row-level-security)
5. [Bảo mật cấp cột / Column-Level Security](#5-bảo-mật-cấp-cột--column-level-security)
6. [Chính sách mật khẩu / Password Policies](#6-chính-sách-mật-khẩu--password-policies)
7. [Audit & Logging](#7-audit--logging)
8. [Oracle Label Security (OLS)](#8-oracle-label-security-ols)
9. [Quy tắc nghiệp vụ / Business Rules](#9-quy-tắc-nghiệp-vụ--business-rules)
10. [Flow hoạt động / Operation Flow](#10-flow-hoạt-động--operation-flow)
11. [Files và thứ tự chạy / Setup Files](#11-files-và-thứ-tự-chạy--setup-files)
12. [Test Cases](#12-test-cases)

---

## 1. TỔNG QUAN HỆ THỐNG / SYSTEM OVERVIEW

### 1.1 Mô tả / Description

**Grade Management System (GMS)** là hệ thống quản lý điểm đại học với các tính năng:

- Quản lý thông tin sinh viên, giảng viên, khoa, bộ môn
- Quản lý đăng ký học phần và nhập điểm
- Phân quyền truy cập dựa trên vai trò (Role-Based Access Control)
- Bảo mật đa lớp: VPD, Column-Level, Password Policies, FGA, OLS

### 1.2 Kiến trúc tổng thể / Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        APPLICATION LAYER                         │
│                    (Spring Boot Backend)                         │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DATABASE LAYER (Oracle 19c)                 │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                    SECURITY LAYERS                          ││
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌────────┐││
│  │  │   VPD   │ │ Column  │ │Password │ │   FGA   │ │  OLS   │││
│  │  │ Policy  │ │Security │ │ Profile │ │ Audit   │ │(Option)│││
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └────────┘││
│  └─────────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                    DATA LAYER                               ││
│  │         14 Tables + 3 Views + Constraints                   ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

### 1.3 Thống kê / Statistics

| Component | Count | Description |
|-----------|-------|-------------|
| Oracle Users | 8 | Database accounts |
| Tables | 14 | Core data tables |
| Views | 3 | V_STUDENT_GRADES, V_STUDENT_GPA, V_AUDIT_TRAIL |
| VPD Policies | 6 | Row-level security policies |
| FGA Policies | 8 | Fine-grained audit policies |
| Password Profiles | 5 | Security profiles |
| User Types | 7 | Application roles |

---

## 2. CẤU TRÚC DATABASE / DATABASE STRUCTURE

### 2.1 Danh sách Tables / Table List

#### Nhóm 1: Cấu trúc tổ chức / Organizational Structure

| Table | Mô tả / Description | Primary Key | Foreign Keys |
|-------|---------------------|-------------|--------------|
| **FACULTIES** | Khoa / Faculty | faculty_id | dean_id → LECTURERS |
| **DEPARTMENTS** | Bộ môn / Department | department_id | faculty_id → FACULTIES, department_head_id → LECTURERS |
| **CLASSES** | Lớp học / Class | class_id | faculty_id → FACULTIES, homeroom_teacher_id → LECTURERS |

#### Nhóm 2: Nhân sự / Personnel

| Table | Mô tả / Description | Primary Key | Foreign Keys |
|-------|---------------------|-------------|--------------|
| **LECTURERS** | Giảng viên / Lecturer | lecturer_id | department_id → DEPARTMENTS |
| **STUDENTS** | Sinh viên / Student | student_id | class_id → CLASSES |
| **RELATIVES** | Người thân / Relative | relative_id | - |
| **STUDENT_RELATIVES** | Liên kết SV-Người thân | (student_id, relative_id) | student_id → STUDENTS, relative_id → RELATIVES |

#### Nhóm 3: Học vụ / Academic

| Table | Mô tả / Description | Primary Key | Foreign Keys |
|-------|---------------------|-------------|--------------|
| **COURSES** | Môn học / Course | course_id | department_id → DEPARTMENTS, prerequisite_course_id → COURSES |
| **COURSE_SECTIONS** | Lớp học phần / Course Section | section_id | course_id → COURSES, lecturer_id → LECTURERS |
| **ENROLLMENTS** | Đăng ký học / Enrollment | enrollment_id | student_id → STUDENTS, section_id → COURSE_SECTIONS |
| **GRADES** | Điểm / Grade | grade_id | enrollment_id → ENROLLMENTS |
| **GRADE_SUBMISSION_DEADLINES** | Deadline nhập điểm | deadline_id | - |

#### Nhóm 4: Hệ thống / System

| Table | Mô tả / Description | Primary Key | Foreign Keys |
|-------|---------------------|-------------|--------------|
| **SYSTEM_USERS** | Tài khoản hệ thống / System Account | user_id | reference_id → (STUDENTS/LECTURERS/RELATIVES) |
| **AUDIT_LOG** | Nhật ký audit / Audit Log | log_id | - |

### 2.2 Sơ đồ quan hệ / Entity Relationship Diagram

```
                            ┌──────────────┐
                            │  FACULTIES   │
                            │──────────────│
                            │ faculty_id   │◄─────────────────────┐
                            │ faculty_name │                      │
                            │ dean_id ─────┼──────────────┐       │
                            └──────────────┘              │       │
                                   │                      │       │
                    ┌──────────────┼──────────────┐       │       │
                    ▼                              ▼       │       │
            ┌──────────────┐              ┌──────────────┐│       │
            │ DEPARTMENTS  │              │   CLASSES    ││       │
            │──────────────│              │──────────────││       │
            │department_id │              │ class_id     ││       │
            │faculty_id────┼──────────────│ faculty_id ──┼┼───────┘
            │dept_head_id──┼─────┐        │homeroom_id ──┼┼───┐
            └──────────────┘     │        └──────────────┘│   │
                    │            │               │        │   │
                    ▼            │               ▼        │   │
            ┌──────────────┐     │        ┌──────────────┐│   │
            │   COURSES    │     │        │   STUDENTS   ││   │
            │──────────────│     │        │──────────────││   │
            │ course_id    │     │        │ student_id   ││   │
            │department_id─┼─────┘        │ class_id ────┼┘   │
            └──────────────┘              └──────────────┘    │
                    │                            │            │
                    ▼                            │            │
            ┌──────────────┐                     │            │
            │COURSE_SECTIONS                     │            │
            │──────────────│                     │            │
            │ section_id   │                     │            │
            │ course_id ───┼─────────────────────┼────────────┤
            │ lecturer_id ─┼─────────────────────┼────────────┤
            └──────────────┘                     │            │
                    │                            │            │
                    ▼                            ▼            │
            ┌──────────────────────────────────────┐          │
            │           ENROLLMENTS                │          │
            │──────────────────────────────────────│          │
            │ enrollment_id                        │          │
            │ student_id ──────────────────────────┼──────────┘
            │ section_id ──────────────────────────┤
            └──────────────────────────────────────┘
                    │
                    ▼
            ┌──────────────┐
            │    GRADES    │
            │──────────────│
            │ grade_id     │
            │enrollment_id │
            │midterm_score │
            │ final_score  │
            │ total_score  │
            └──────────────┘

            ┌──────────────┐         ┌──────────────┐
            │  LECTURERS   │◄────────│ (Multiple    │
            │──────────────│         │  References) │
            │ lecturer_id  │         │              │
            │department_id │         │- dean_id     │
            │ first_name   │         │- dept_head_id│
            │ last_name    │         │- homeroom_id │
            │ email        │         │- lecturer_id │
            └──────────────┘         └──────────────┘

    ┌──────────────┐     ┌────────────────────┐     ┌──────────────┐
    │   STUDENTS   │◄────│ STUDENT_RELATIVES  │────►│  RELATIVES   │
    │──────────────│     │────────────────────│     │──────────────│
    │ student_id   │     │ student_id         │     │ relative_id  │
    │              │     │ relative_id        │     │              │
    │              │     │ relationship       │     │              │
    └──────────────┘     └────────────────────┘     └──────────────┘
```

### 2.3 Chi tiết các cột quan trọng / Important Columns

#### STUDENTS Table
```sql
CREATE TABLE STUDENTS (
    student_id VARCHAR2(10) PRIMARY KEY,           -- MSSV
    first_name VARCHAR2(50) NOT NULL,              -- Tên
    last_name VARCHAR2(50) NOT NULL,               -- Họ
    date_of_birth DATE NOT NULL,                   -- Ngày sinh
    gender VARCHAR2(10) CHECK (gender IN ('Male', 'Female', 'Other')),
    hometown VARCHAR2(100),                        -- Quê quán
    ethnicity VARCHAR2(50),                        -- Dân tộc
    religion VARCHAR2(50),                         -- Tôn giáo
    email VARCHAR2(100) UNIQUE,                    -- Email (unique)
    phone_number VARCHAR2(20),                     -- SĐT
    contact_address VARCHAR2(200),                 -- Địa chỉ liên hệ
    class_id VARCHAR2(10) NOT NULL,                -- Mã lớp
    enrollment_date DATE DEFAULT SYSDATE,          -- Ngày nhập học
    student_status VARCHAR2(20) DEFAULT 'Active'   -- Trạng thái
        CHECK (student_status IN ('Active', 'Inactive', 'Graduated', 'Suspended'))
);
```

#### GRADES Table
```sql
CREATE TABLE GRADES (
    grade_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    enrollment_id NUMBER NOT NULL UNIQUE,          -- 1 enrollment = 1 grade
    midterm_score NUMBER(4,2) CHECK (midterm_score >= 0 AND midterm_score <= 10),
    final_score NUMBER(4,2) CHECK (final_score >= 0 AND final_score <= 10),
    total_score NUMBER(4,2) CHECK (total_score >= 0 AND total_score <= 10),
    letter_grade VARCHAR2(2),                      -- A, B+, B, C+, C, D+, D, F
    grade_status VARCHAR2(20) DEFAULT 'Pending'    -- Pending → Submitted → Approved
        CHECK (grade_status IN ('Pending', 'Submitted', 'Approved', 'Modified')),
    submitted_by VARCHAR2(10),                     -- Giảng viên nhập
    submitted_date DATE,
    approved_by VARCHAR2(10),                      -- Người duyệt
    approved_date DATE,
    modified_by VARCHAR2(10),                      -- Người sửa (nếu có)
    modified_date DATE,
    modification_reason VARCHAR2(500)              -- Lý do sửa
);
```

---

## 3. PHÂN QUYỀN NGƯỜI DÙNG / USER AUTHORIZATION

### 3.1 Oracle Database Users

| User | Password | Profile | Purpose |
|------|----------|---------|---------|
| **GMS_ADMIN** | Admin@2024#Secure | GMS_SYSADMIN_PROFILE | Schema owner, DBA |
| **GMS_APP** | App@2024#Connect | DEFAULT | Backend connection |
| **GMS_STUDENT** | Student@2024 | GMS_STUDENT_PROFILE | Student role testing |
| **GMS_LECTURER** | Lecturer@2024 | GMS_LECTURER_PROFILE | Lecturer role testing |
| **GMS_ACADEMIC** | Academic@2024 | GMS_ADMIN_PROFILE | Academic Affairs |
| **GMS_DEAN** | Dean@2024 | GMS_ADMIN_PROFILE | Dean role |
| **GMS_DEPT_HEAD** | DeptHead@2024 | GMS_ADMIN_PROFILE | Department Head |
| **GMS_RELATIVE** | Relative@2024 | GMS_RELATIVE_PROFILE | Parent/Relative |

### 3.2 Application User Types (SYSTEM_USERS.user_type)

| User Type | Mô tả / Description | Mapping |
|-----------|---------------------|---------|
| `Student` | Sinh viên | reference_id → STUDENTS.student_id |
| `Lecturer` | Giảng viên | reference_id → LECTURERS.lecturer_id |
| `Academic_Affairs` | Phòng đào tạo | - |
| `Dean` | Trưởng khoa | reference_id → LECTURERS.lecturer_id |
| `Department_Head` | Trưởng bộ môn | reference_id → LECTURERS.lecturer_id |
| `Relative` | Phụ huynh | reference_id → RELATIVES.relative_id |
| `Admin` | Quản trị viên | - |

### 3.3 Ma trận quyền truy cập chi tiết / Access Matrix

#### READ Permissions (SELECT)

| Table | Student | Lecturer | Dean | Dept_Head | Academic | Relative | Admin |
|-------|---------|----------|------|-----------|----------|----------|-------|
| STUDENTS | Own | Homeroom + Teaching | Faculty | - | All | Child | All |
| GRADES | Own | Homeroom + Teaching | Faculty | Dept courses | All | Child | All |
| ENROLLMENTS | Own | Teaching | Faculty | Dept | All | Child | All |
| COURSES | All | All | All | Dept | All | - | All |
| COURSE_SECTIONS | All | All | All | Dept | All | - | All |
| LECTURERS | - | Own | Faculty | Dept | All | - | All |
| RELATIVES | - | - | - | - | All | Own | All |
| FACULTIES | - | - | Own | - | All | - | All |
| DEPARTMENTS | - | - | Faculty | Own | All | - | All |

#### WRITE Permissions (INSERT/UPDATE/DELETE)

| Table | Operation | Student | Lecturer | Academic | Admin |
|-------|-----------|---------|----------|----------|-------|
| STUDENTS | UPDATE | email, phone, address | - | All | All |
| LECTURERS | UPDATE | - | email, phone, address | All | All |
| RELATIVES | UPDATE | - | - | All | All |
| GRADES | INSERT/UPDATE | - | Teaching (before deadline) | All | All |
| GRADES | DELETE | - | - | All | All |
| ENROLLMENTS | INSERT | - | - | All | All |

---

## 4. BẢO MẬT CẤP HÀNG - VPD / ROW-LEVEL SECURITY

### 4.1 Nguyên lý hoạt động / How VPD Works

```
┌─────────────────────────────────────────────────────────────────┐
│                    VPD FLOW DIAGRAM                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. User Login                                                   │
│     └──► Backend calls: set_user_context('STU001', 'Student')   │
│                                                                  │
│  2. Context Stored                                               │
│     └──► gms_context namespace:                                  │
│          ├── user_id = 'STU001'                                  │
│          ├── user_type = 'Student'                               │
│          ├── class_id = 'CS2024A'                                │
│          └── faculty_id = 'FAC001'                               │
│                                                                  │
│  3. Query Execution                                              │
│     └──► SELECT * FROM STUDENTS                                  │
│                                                                  │
│  4. VPD Policy Applied                                           │
│     └──► student_policy() returns:                               │
│          "student_id = 'STU001'"                                 │
│                                                                  │
│  5. Final Query                                                  │
│     └──► SELECT * FROM STUDENTS WHERE student_id = 'STU001'     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Context và Package / Context and Package

#### Context Creation
```sql
-- Tạo context namespace
CREATE OR REPLACE CONTEXT gms_context USING gms_admin.gms_security_pkg;
```

#### Security Package
```sql
CREATE OR REPLACE PACKAGE gms_security_pkg AS
    -- Set user context (called by backend on login)
    PROCEDURE set_user_context(p_user_id VARCHAR2, p_user_type VARCHAR2);

    -- Clear context (called on logout)
    PROCEDURE clear_user_context;

    -- Get context values
    FUNCTION get_user_id RETURN VARCHAR2;
    FUNCTION get_user_type RETURN VARCHAR2;

    -- Check deadline
    FUNCTION is_after_deadline(p_semester VARCHAR2, p_academic_year NUMBER) RETURN BOOLEAN;

    -- VPD Policy Functions
    FUNCTION student_policy(schema_name VARCHAR2, table_name VARCHAR2) RETURN VARCHAR2;
    FUNCTION grade_policy(schema_name VARCHAR2, table_name VARCHAR2) RETURN VARCHAR2;
    FUNCTION lecturer_grade_policy(schema_name VARCHAR2, table_name VARCHAR2) RETURN VARCHAR2;
    FUNCTION relative_policy(schema_name VARCHAR2, table_name VARCHAR2) RETURN VARCHAR2;
    FUNCTION department_policy(schema_name VARCHAR2, table_name VARCHAR2) RETURN VARCHAR2;
    FUNCTION faculty_policy(schema_name VARCHAR2, table_name VARCHAR2) RETURN VARCHAR2;
END gms_security_pkg;
```

### 4.3 Chi tiết từng VPD Policy / Policy Details

#### Policy 1: STUDENTS (SELECT)

| User Type | Predicate | Giải thích |
|-----------|-----------|------------|
| Student | `student_id = '{user_id}'` | Chỉ xem bản ghi của mình |
| Lecturer | `(class_id IN (...homeroom...) OR student_id IN (...teaching...))` | Xem SV lớp chủ nhiệm + SV môn dạy |
| Dean | `class_id IN (SELECT class_id FROM CLASSES WHERE faculty_id = '{faculty_id}')` | Xem SV trong khoa |
| Academic_Affairs | `1=1` | Xem tất cả |
| Admin | `1=1` | Xem tất cả |
| Others | `1=0` | Không xem được |

**SQL Implementation:**
```sql
FUNCTION student_policy(schema_name VARCHAR2, table_name VARCHAR2) RETURN VARCHAR2 IS
    v_user_id VARCHAR2(10) := SYS_CONTEXT('gms_context', 'user_id');
    v_user_type VARCHAR2(20) := SYS_CONTEXT('gms_context', 'user_type');
    v_predicate VARCHAR2(4000);
BEGIN
    -- Bypass for GMS_ADMIN and GMS_APP
    IF SYS_CONTEXT('USERENV', 'SESSION_USER') IN ('GMS_ADMIN', 'GMS_APP') THEN
        RETURN '1=1';
    END IF;

    IF v_user_type = 'Student' THEN
        v_predicate := 'student_id = ''' || v_user_id || '''';

    ELSIF v_user_type = 'Lecturer' THEN
        -- Sinh viên lớp chủ nhiệm + sinh viên môn dạy
        v_predicate := '(class_id IN (SELECT class_id FROM gms_admin.CLASSES ' ||
                      'WHERE homeroom_teacher_id = ''' || v_user_id || ''') ' ||
                      'OR student_id IN (SELECT e.student_id FROM gms_admin.ENROLLMENTS e ' ||
                      'JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id ' ||
                      'WHERE cs.lecturer_id = ''' || v_user_id || '''))';

    ELSIF v_user_type = 'Dean' THEN
        v_predicate := 'class_id IN (SELECT class_id FROM gms_admin.CLASSES ' ||
                      'WHERE faculty_id = ''' || SYS_CONTEXT('gms_context', 'faculty_id') || ''')';

    ELSIF v_user_type IN ('Academic_Affairs', 'Admin') THEN
        v_predicate := '1=1';

    ELSE
        v_predicate := '1=0';
    END IF;

    RETURN v_predicate;
END student_policy;
```

#### Policy 2: GRADES (SELECT)

| User Type | Predicate | Giải thích |
|-----------|-----------|------------|
| Student | `enrollment_id IN (SELECT ... WHERE student_id = '{user_id}')` | Điểm của mình |
| Relative | `enrollment_id IN (SELECT ... JOIN STUDENT_RELATIVES ... WHERE relative_id = '{user_id}')` | Điểm con em |
| Lecturer | `(enrollment_id IN (...teaching...) OR enrollment_id IN (...homeroom...))` | Điểm môn dạy + lớp chủ nhiệm |
| Department_Head | `enrollment_id IN (SELECT ... WHERE course.department_id = '{dept_id}')` | Điểm các môn trong bộ môn |
| Dean | `enrollment_id IN (SELECT ... WHERE class.faculty_id = '{faculty_id}')` | Điểm SV trong khoa |
| Academic_Affairs | `1=1` | Tất cả |

**SQL Implementation:**
```sql
FUNCTION grade_policy(schema_name VARCHAR2, table_name VARCHAR2) RETURN VARCHAR2 IS
    v_user_id VARCHAR2(10) := SYS_CONTEXT('gms_context', 'user_id');
    v_user_type VARCHAR2(20) := SYS_CONTEXT('gms_context', 'user_type');
    v_predicate VARCHAR2(4000);
BEGIN
    IF SYS_CONTEXT('USERENV', 'SESSION_USER') IN ('GMS_ADMIN', 'GMS_APP') THEN
        RETURN '1=1';
    END IF;

    IF v_user_type = 'Student' THEN
        v_predicate := 'enrollment_id IN (SELECT enrollment_id FROM gms_admin.ENROLLMENTS ' ||
                      'WHERE student_id = ''' || v_user_id || ''')';

    ELSIF v_user_type = 'Relative' THEN
        v_predicate := 'enrollment_id IN (SELECT e.enrollment_id FROM gms_admin.ENROLLMENTS e ' ||
                      'JOIN gms_admin.STUDENT_RELATIVES sr ON e.student_id = sr.student_id ' ||
                      'WHERE sr.relative_id = ''' || v_user_id || ''')';

    ELSIF v_user_type = 'Lecturer' THEN
        -- Điểm môn mình dạy + điểm SV lớp chủ nhiệm
        v_predicate := '(enrollment_id IN (SELECT e.enrollment_id FROM gms_admin.ENROLLMENTS e ' ||
                      'JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id ' ||
                      'WHERE cs.lecturer_id = ''' || v_user_id || ''') ' ||
                      'OR enrollment_id IN (SELECT e.enrollment_id FROM gms_admin.ENROLLMENTS e ' ||
                      'JOIN gms_admin.STUDENTS s ON e.student_id = s.student_id ' ||
                      'JOIN gms_admin.CLASSES c ON s.class_id = c.class_id ' ||
                      'WHERE c.homeroom_teacher_id = ''' || v_user_id || '''))';

    ELSIF v_user_type = 'Department_Head' THEN
        v_predicate := 'enrollment_id IN (SELECT e.enrollment_id FROM gms_admin.ENROLLMENTS e ' ||
                      'JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id ' ||
                      'JOIN gms_admin.COURSES c ON cs.course_id = c.course_id ' ||
                      'WHERE c.department_id = ''' || SYS_CONTEXT('gms_context', 'department_id') || ''')';

    ELSIF v_user_type = 'Dean' THEN
        v_predicate := 'enrollment_id IN (SELECT e.enrollment_id FROM gms_admin.ENROLLMENTS e ' ||
                      'JOIN gms_admin.STUDENTS s ON e.student_id = s.student_id ' ||
                      'JOIN gms_admin.CLASSES cl ON s.class_id = cl.class_id ' ||
                      'WHERE cl.faculty_id = ''' || SYS_CONTEXT('gms_context', 'faculty_id') || ''')';

    ELSIF v_user_type IN ('Academic_Affairs', 'Admin') THEN
        v_predicate := '1=1';

    ELSE
        v_predicate := '1=0';
    END IF;

    RETURN v_predicate;
END grade_policy;
```

#### Policy 3: GRADES (INSERT/UPDATE/DELETE)

| User Type | Điều kiện | Giải thích |
|-----------|-----------|------------|
| Lecturer | Chỉ môn mình dạy + TRƯỚC deadline | Giảng viên nhập điểm môn mình dạy, chỉ khi chưa qua deadline |
| Academic_Affairs | Tất cả | Phòng đào tạo có thể sửa bất kỳ lúc nào |

**SQL Implementation:**
```sql
FUNCTION lecturer_grade_policy(schema_name VARCHAR2, table_name VARCHAR2) RETURN VARCHAR2 IS
    v_user_id VARCHAR2(10) := SYS_CONTEXT('gms_context', 'user_id');
    v_user_type VARCHAR2(20) := SYS_CONTEXT('gms_context', 'user_type');
    v_predicate VARCHAR2(4000);
BEGIN
    IF SYS_CONTEXT('USERENV', 'SESSION_USER') IN ('GMS_ADMIN', 'GMS_APP') THEN
        RETURN '1=1';
    END IF;

    IF v_user_type = 'Lecturer' THEN
        -- Chỉ được sửa điểm môn mình dạy VÀ trước deadline
        v_predicate := 'enrollment_id IN (SELECT e.enrollment_id FROM gms_admin.ENROLLMENTS e ' ||
                      'JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id ' ||
                      'WHERE cs.lecturer_id = ''' || v_user_id || ''' ' ||
                      'AND EXISTS (SELECT 1 FROM gms_admin.GRADE_SUBMISSION_DEADLINES d ' ||
                      'WHERE d.semester = cs.semester AND d.academic_year = cs.academic_year ' ||
                      'AND d.submission_deadline > SYSDATE))';

    ELSIF v_user_type IN ('Academic_Affairs', 'Admin') THEN
        v_predicate := '1=1';

    ELSE
        v_predicate := '1=0';
    END IF;

    RETURN v_predicate;
END lecturer_grade_policy;
```

### 4.4 Đăng ký VPD Policies / Policy Registration

```sql
-- STUDENTS table (SELECT)
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'GMS_ADMIN',
        object_name     => 'STUDENTS',
        policy_name     => 'STUDENT_ACCESS_POLICY',
        function_schema => 'GMS_ADMIN',
        policy_function => 'gms_security_pkg.student_policy',
        statement_types => 'SELECT'
    );
END;
/

-- GRADES table (SELECT)
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'GMS_ADMIN',
        object_name     => 'GRADES',
        policy_name     => 'GRADE_SELECT_POLICY',
        function_schema => 'GMS_ADMIN',
        policy_function => 'gms_security_pkg.grade_policy',
        statement_types => 'SELECT'
    );
END;
/

-- GRADES table (INSERT/UPDATE/DELETE)
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'GMS_ADMIN',
        object_name     => 'GRADES',
        policy_name     => 'GRADE_MODIFY_POLICY',
        function_schema => 'GMS_ADMIN',
        policy_function => 'gms_security_pkg.lecturer_grade_policy',
        statement_types => 'INSERT, UPDATE, DELETE'
    );
END;
/
```

---

## 5. BẢO MẬT CẤP CỘT / COLUMN-LEVEL SECURITY

### 5.1 Nguyên lý / Principle

Column-level security giới hạn cột nào user có thể UPDATE, kết hợp với VPD để giới hạn row.

```
┌─────────────────────────────────────────────────────────────────┐
│                   COLUMN-LEVEL SECURITY                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STUDENTS Table:                                                 │
│  ┌──────────────┬──────────────┬──────────────┬───────────────┐ │
│  │ student_id   │ first_name   │ email        │ phone_number  │ │
│  │ (NO UPDATE)  │ (NO UPDATE)  │ (CAN UPDATE) │ (CAN UPDATE)  │ │
│  └──────────────┴──────────────┴──────────────┴───────────────┘ │
│                                                                  │
│  + VPD Policy: WHERE student_id = '{current_user_id}'           │
│                                                                  │
│  = User can only UPDATE their own email, phone, address         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Quyền UPDATE hạn chế / Restricted UPDATE Permissions

| User | Table | Allowed Columns | Restricted Columns |
|------|-------|-----------------|-------------------|
| GMS_STUDENT | STUDENTS | email, phone_number, contact_address | student_id, first_name, last_name, class_id, enrollment_date, student_status, etc. |
| GMS_LECTURER | LECTURERS | email, phone_number, contact_address | lecturer_id, department_id, academic_degree, start_date, etc. |
| GMS_RELATIVE | RELATIVES | email, phone_number, contact_address | relative_id, first_name, last_name, etc. |

### 5.3 SQL Implementation

```sql
-- Students: Chỉ được UPDATE email, phone, address
GRANT UPDATE (email, phone_number, contact_address)
ON gms_admin.STUDENTS TO GMS_STUDENT;

-- Lecturers: Chỉ được UPDATE email, phone, address
GRANT UPDATE (email, phone_number, contact_address)
ON gms_admin.LECTURERS TO GMS_LECTURER;

-- Relatives: Chỉ được UPDATE email, phone, address
GRANT UPDATE (email, phone_number, contact_address)
ON gms_admin.RELATIVES TO GMS_RELATIVE;
```

### 5.4 Ví dụ / Examples

```sql
-- ✅ ALLOWED: Student updates their own email
-- (Column allowed + VPD allows own row)
UPDATE gms_admin.STUDENTS
SET email = 'newemail@student.edu'
WHERE student_id = 'STU001';
-- Result: 1 row updated

-- ❌ BLOCKED: Student tries to change first_name
-- (Column not allowed)
UPDATE gms_admin.STUDENTS
SET first_name = 'NewName'
WHERE student_id = 'STU001';
-- Result: ORA-01031: insufficient privileges

-- ❌ BLOCKED: Student tries to update another student's email
-- (VPD blocks access to other rows)
UPDATE gms_admin.STUDENTS
SET email = 'hack@evil.com'
WHERE student_id = 'STU002';
-- Result: 0 rows updated (VPD filtered out the row)
```

---

## 6. CHÍNH SÁCH MẬT KHẨU / PASSWORD POLICIES

### 6.1 Tổng quan Profiles / Profile Overview

| Profile | Đối tượng / Target | Password Life | Lock Time | Failed Logins |
|---------|-------------------|---------------|-----------|---------------|
| GMS_STUDENT_PROFILE | Sinh viên | 90 ngày | 29 phút | 5 lần |
| GMS_LECTURER_PROFILE | Giảng viên | 60 ngày | 58 phút | 3 lần |
| GMS_ADMIN_PROFILE | Dean, Dept Head, Academic | 30 ngày | 115 phút | 3 lần |
| GMS_RELATIVE_PROFILE | Phụ huynh | 120 ngày | 14 phút | 5 lần |
| GMS_SYSADMIN_PROFILE | GMS_ADMIN | 30 ngày | 230 phút | 2 lần |

### 6.2 Chi tiết từng Profile / Profile Details

#### GMS_STUDENT_PROFILE
```sql
CREATE PROFILE GMS_STUDENT_PROFILE LIMIT
    -- Password policies
    PASSWORD_LIFE_TIME 90              -- Đổi mật khẩu sau 90 ngày
    PASSWORD_GRACE_TIME 7              -- 7 ngày cảnh báo trước khi hết hạn
    PASSWORD_REUSE_MAX 5               -- Không dùng lại 5 mật khẩu gần nhất
    PASSWORD_REUSE_TIME 365            -- Hoặc sau 365 ngày
    PASSWORD_VERIFY_FUNCTION gms_password_verify  -- Kiểm tra độ mạnh

    -- Login policies
    FAILED_LOGIN_ATTEMPTS 5            -- Khóa sau 5 lần sai
    PASSWORD_LOCK_TIME 0.02            -- Khóa 29 phút (0.02 ngày)

    -- Session policies
    SESSIONS_PER_USER 20               -- Tối đa 20 sessions
    IDLE_TIME 240;                     -- Timeout sau 4 giờ idle
```

#### GMS_SYSADMIN_PROFILE (Nghiêm ngặt nhất / Most Strict)
```sql
CREATE PROFILE GMS_SYSADMIN_PROFILE LIMIT
    PASSWORD_LIFE_TIME 30              -- Đổi mỗi 30 ngày
    PASSWORD_GRACE_TIME 1              -- Chỉ 1 ngày cảnh báo
    PASSWORD_REUSE_MAX 24              -- Không dùng lại 24 mật khẩu
    PASSWORD_REUSE_TIME 730            -- Hoặc sau 2 năm
    FAILED_LOGIN_ATTEMPTS 2            -- Khóa sau 2 lần sai
    PASSWORD_LOCK_TIME 0.16            -- Khóa 230 phút
    SESSIONS_PER_USER UNLIMITED
    IDLE_TIME UNLIMITED;
```

### 6.3 Password Verification Function

```sql
CREATE OR REPLACE FUNCTION gms_password_verify(
    username     VARCHAR2,
    password     VARCHAR2,
    old_password VARCHAR2
) RETURN BOOLEAN IS
    n BOOLEAN;
    m INTEGER;
    differ INTEGER;
    isdigit BOOLEAN;
    isupper BOOLEAN;
    islower BOOLEAN;
    isspecial BOOLEAN;
    digitarray VARCHAR2(20);
    upperarray VARCHAR2(26);
    lowerarray VARCHAR2(26);
    specialarray VARCHAR2(30);
BEGIN
    digitarray := '0123456789';
    upperarray := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    lowerarray := 'abcdefghijklmnopqrstuvwxyz';
    specialarray := '!@#$%^&*()_+-=[]{}|;:,.<>?';

    -- Rule 1: Tối thiểu 8 ký tự / Minimum 8 characters
    IF LENGTH(password) < 8 THEN
        raise_application_error(-20001, 'Password must be at least 8 characters');
    END IF;

    -- Rule 2: Không trùng username / Cannot match username
    IF UPPER(password) = UPPER(username) THEN
        raise_application_error(-20002, 'Password cannot be the same as username');
    END IF;

    -- Rule 3: Phải có ít nhất 1 số / At least 1 digit
    isdigit := FALSE;
    FOR i IN 1..10 LOOP
        IF INSTR(password, SUBSTR(digitarray, i, 1)) > 0 THEN
            isdigit := TRUE;
        END IF;
    END LOOP;
    IF NOT isdigit THEN
        raise_application_error(-20003, 'Password must contain at least one digit');
    END IF;

    -- Rule 4: Phải có ít nhất 1 chữ hoa / At least 1 uppercase
    isupper := FALSE;
    FOR i IN 1..26 LOOP
        IF INSTR(password, SUBSTR(upperarray, i, 1)) > 0 THEN
            isupper := TRUE;
        END IF;
    END LOOP;
    IF NOT isupper THEN
        raise_application_error(-20004, 'Password must contain at least one uppercase letter');
    END IF;

    -- Rule 5: Phải có ít nhất 1 chữ thường / At least 1 lowercase
    islower := FALSE;
    FOR i IN 1..26 LOOP
        IF INSTR(password, SUBSTR(lowerarray, i, 1)) > 0 THEN
            islower := TRUE;
        END IF;
    END LOOP;
    IF NOT islower THEN
        raise_application_error(-20005, 'Password must contain at least one lowercase letter');
    END IF;

    -- Rule 6: Phải có ít nhất 1 ký tự đặc biệt / At least 1 special character
    isspecial := FALSE;
    FOR i IN 1..LENGTH(specialarray) LOOP
        IF INSTR(password, SUBSTR(specialarray, i, 1)) > 0 THEN
            isspecial := TRUE;
        END IF;
    END LOOP;
    IF NOT isspecial THEN
        raise_application_error(-20006, 'Password must contain at least one special character');
    END IF;

    -- Rule 7: Khác mật khẩu cũ ít nhất 3 ký tự / Differ from old password by 3+ chars
    IF old_password IS NOT NULL THEN
        differ := 0;
        FOR i IN 1..LENGTH(password) LOOP
            IF SUBSTR(password, i, 1) != SUBSTR(old_password, i, 1) THEN
                differ := differ + 1;
            END IF;
        END LOOP;
        IF differ < 3 THEN
            raise_application_error(-20007, 'Password must differ from old password by at least 3 characters');
        END IF;
    END IF;

    RETURN TRUE;
END;
```

### 6.4 Yêu cầu mật khẩu / Password Requirements Summary

| Requirement | Description |
|-------------|-------------|
| Độ dài tối thiểu | 8 ký tự |
| Chữ hoa | Ít nhất 1 ký tự (A-Z) |
| Chữ thường | Ít nhất 1 ký tự (a-z) |
| Chữ số | Ít nhất 1 số (0-9) |
| Ký tự đặc biệt | Ít nhất 1 (!@#$%^&*...) |
| Không trùng username | Mật khẩu ≠ tên đăng nhập |
| Khác mật khẩu cũ | Khác ít nhất 3 ký tự |

---

## 7. AUDIT & LOGGING

### 7.1 Fine-Grained Auditing (FGA) Policies

| Policy Name | Table | Statement | Columns Audited | Purpose |
|-------------|-------|-----------|-----------------|---------|
| fga_grade_select | GRADES | SELECT | midterm_score, final_score, total_score | Theo dõi ai xem điểm |
| fga_grade_update | GRADES | UPDATE | midterm_score, final_score, total_score, letter_grade | Theo dõi sửa điểm |
| fga_grade_delete | GRADES | DELETE | - | Theo dõi xóa điểm |
| fga_student_info_access | STUDENTS | SELECT | email, phone_number, contact_address | Theo dõi xem thông tin nhạy cảm |
| fga_student_modify | STUDENTS | UPDATE, DELETE | - | Theo dõi sửa/xóa SV |
| fga_enrollment_modify | ENROLLMENTS | UPDATE, DELETE | - | Theo dõi thay đổi đăng ký |
| fga_system_user_modify | SYSTEM_USERS | UPDATE, DELETE | - | Theo dõi thay đổi tài khoản |
| fga_deadline_modify | GRADE_SUBMISSION_DEADLINES | UPDATE, DELETE | - | Theo dõi thay đổi deadline |

### 7.2 FGA Implementation

```sql
-- Audit xem điểm
BEGIN
    DBMS_FGA.ADD_POLICY(
        object_schema   => 'GMS_ADMIN',
        object_name     => 'GRADES',
        policy_name     => 'FGA_GRADE_SELECT',
        audit_column    => 'MIDTERM_SCORE, FINAL_SCORE, TOTAL_SCORE',
        statement_types => 'SELECT'
    );
END;
/

-- Audit sửa điểm với handler
BEGIN
    DBMS_FGA.ADD_POLICY(
        object_schema   => 'GMS_ADMIN',
        object_name     => 'GRADES',
        policy_name     => 'FGA_GRADE_UPDATE',
        audit_column    => 'MIDTERM_SCORE, FINAL_SCORE, TOTAL_SCORE, LETTER_GRADE',
        statement_types => 'UPDATE',
        handler_schema  => 'GMS_ADMIN',
        handler_module  => 'AUDIT_GRADE_HANDLER'
    );
END;
/
```

### 7.3 Custom Audit Handler

```sql
CREATE OR REPLACE PROCEDURE audit_grade_handler(
    object_schema VARCHAR2,
    object_name VARCHAR2,
    policy_name VARCHAR2
) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO AUDIT_LOG (
        table_name,
        operation,
        user_id,
        username,
        record_id,
        operation_date,
        ip_address,
        session_id
    ) VALUES (
        object_name,
        'UPDATE',
        SYS_CONTEXT('gms_context', 'user_id'),
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        NULL,  -- record_id captured by trigger
        SYSDATE,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYS_CONTEXT('USERENV', 'SESSIONID')
    );
    COMMIT;
END;
```

### 7.4 Audit Triggers

```sql
-- Trigger ghi log khi INSERT điểm
CREATE OR REPLACE TRIGGER trg_audit_grade_insert
AFTER INSERT ON GRADES
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO AUDIT_LOG (
        table_name,
        operation,
        user_id,
        username,
        record_id,
        new_values,
        operation_date,
        ip_address,
        session_id
    ) VALUES (
        'GRADES',
        'INSERT',
        SYS_CONTEXT('gms_context', 'user_id'),
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        :NEW.grade_id,
        'enrollment_id=' || :NEW.enrollment_id ||
        ', midterm=' || :NEW.midterm_score ||
        ', final=' || :NEW.final_score,
        SYSDATE,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYS_CONTEXT('USERENV', 'SESSIONID')
    );
    COMMIT;
END;
/
```

### 7.5 Audit Trail View

```sql
CREATE OR REPLACE VIEW V_AUDIT_TRAIL AS
-- FGA audit trail
SELECT
    'FGA' as audit_type,
    timestamp as operation_date,
    db_user as username,
    object_schema,
    object_name as table_name,
    statement_type as operation,
    sql_text,
    NULL as old_values,
    NULL as new_values
FROM dba_fga_audit_trail
WHERE object_schema = 'GMS_ADMIN'
UNION ALL
-- Custom audit log
SELECT
    'CUSTOM' as audit_type,
    operation_date,
    username,
    'GMS_ADMIN' as object_schema,
    table_name,
    operation,
    NULL as sql_text,
    old_values,
    new_values
FROM gms_admin.AUDIT_LOG
ORDER BY operation_date DESC;
```

### 7.6 Truy vấn Audit / Audit Queries

```sql
-- Xem ai đã truy cập điểm trong 24h qua
SELECT timestamp, db_user, sql_text
FROM dba_fga_audit_trail
WHERE object_name = 'GRADES'
AND statement_type = 'SELECT'
AND timestamp > SYSDATE - 1
ORDER BY timestamp DESC;

-- Xem ai đã sửa điểm
SELECT * FROM gms_admin.AUDIT_LOG
WHERE table_name = 'GRADES'
AND operation = 'UPDATE'
ORDER BY operation_date DESC;

-- Tổng hợp audit theo user
SELECT username, operation, COUNT(*) as operation_count
FROM gms_admin.V_AUDIT_TRAIL
WHERE operation_date > SYSDATE - 7
GROUP BY username, operation
ORDER BY operation_count DESC;
```

---

## 8. ORACLE LABEL SECURITY (OLS)

### 8.1 Tổng quan / Overview

OLS được sử dụng cho **ngân hàng đề thi** (EXAM_QUESTIONS table) - một use case điển hình cần phân cấp bảo mật theo độ nhạy cảm của dữ liệu.

```
┌─────────────────────────────────────────────────────────────────┐
│                    OLS HIERARCHY                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Level 3000: CONFIDENTIAL (Mật - Đáp án thi)                   │
│       │                                                          │
│       ▼                                                          │
│   Level 2000: INTERNAL (Nội bộ - Câu hỏi)                       │
│       │                                                          │
│       ▼                                                          │
│   Level 1000: PUBLIC (Công khai - Câu hỏi mẫu)                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 8.2 Components

#### Levels (Cấp độ bảo mật)
| Level Number | Short Name | Long Name | Mô tả |
|--------------|------------|-----------|-------|
| 1000 | PUB | PUBLIC | Câu hỏi mẫu, ai cũng xem được |
| 2000 | INT | INTERNAL | Câu hỏi nội bộ, chỉ giảng viên |
| 3000 | CONF | CONFIDENTIAL | Đáp án thi, chỉ trưởng khoa |

#### Compartments (Khoa)
| Comp Number | Short Name | Long Name |
|-------------|------------|-----------|
| 100 | CS | COMPUTER SCIENCE |
| 200 | EE | ELECTRICAL ENGINEERING |

#### Labels (Nhãn dữ liệu)
| Label Tag | Label | Mô tả |
|-----------|-------|-------|
| 1000 | PUB | Công khai |
| 2100 | INT:CS | Nội bộ khoa CS |
| 2200 | INT:EE | Nội bộ khoa EE |
| 3100 | CONF:CS | Mật khoa CS |

### 8.3 User Authorization

| User | max_read_label | max_write_label | Xem được |
|------|----------------|-----------------|----------|
| GMS_STUDENT | PUB | - | Chỉ câu hỏi PUBLIC |
| GMS_LECTURER | INT:CS | INT:CS | PUBLIC + INTERNAL của CS |
| GMS_DEAN | CONF:CS | CONF:CS | Tất cả của CS (kể cả đáp án) |
| GMS_ADMIN | FULL | FULL | Bypass hoàn toàn |

### 8.4 OLS Implementation

```sql
-- 1. Create Policy
BEGIN
    SA_SYSDBA.CREATE_POLICY(
        policy_name      => 'EXAM_SEC_POLICY',
        column_name      => 'OLS_LABEL',
        default_options  => 'READ_CONTROL, WRITE_CONTROL, LABEL_DEFAULT'
    );
END;
/

-- 2. Create Levels
BEGIN
    SA_COMPONENTS.CREATE_LEVEL('EXAM_SEC_POLICY', 1000, 'PUB', 'PUBLIC');
    SA_COMPONENTS.CREATE_LEVEL('EXAM_SEC_POLICY', 2000, 'INT', 'INTERNAL');
    SA_COMPONENTS.CREATE_LEVEL('EXAM_SEC_POLICY', 3000, 'CONF', 'CONFIDENTIAL');
END;
/

-- 3. Create Compartments
BEGIN
    SA_COMPONENTS.CREATE_COMPARTMENT('EXAM_SEC_POLICY', 100, 'CS', 'COMPUTER SCIENCE');
    SA_COMPONENTS.CREATE_COMPARTMENT('EXAM_SEC_POLICY', 200, 'EE', 'ELECTRICAL ENGINEERING');
END;
/

-- 4. Create Labels
BEGIN
    SA_LABEL_ADMIN.CREATE_LABEL('EXAM_SEC_POLICY', 1000, 'PUB', TRUE);
    SA_LABEL_ADMIN.CREATE_LABEL('EXAM_SEC_POLICY', 2100, 'INT:CS', TRUE);
    SA_LABEL_ADMIN.CREATE_LABEL('EXAM_SEC_POLICY', 2200, 'INT:EE', TRUE);
    SA_LABEL_ADMIN.CREATE_LABEL('EXAM_SEC_POLICY', 3100, 'CONF:CS', TRUE);
END;
/

-- 5. Apply to Table
BEGIN
    SA_POLICY_ADMIN.APPLY_TABLE_POLICY(
        policy_name    => 'EXAM_SEC_POLICY',
        schema_name    => 'GMS_ADMIN',
        table_name     => 'EXAM_QUESTIONS',
        table_options  => 'READ_CONTROL, WRITE_CONTROL, LABEL_DEFAULT'
    );
END;
/

-- 6. Authorize Users
BEGIN
    -- Student: Chỉ đọc PUBLIC
    SA_USER_ADMIN.SET_USER_LABELS(
        policy_name    => 'EXAM_SEC_POLICY',
        user_name      => 'GMS_STUDENT',
        max_read_label => 'PUB'
    );

    -- Lecturer: Đọc/Ghi INTERNAL CS
    SA_USER_ADMIN.SET_USER_LABELS(
        policy_name     => 'EXAM_SEC_POLICY',
        user_name       => 'GMS_LECTURER',
        max_read_label  => 'INT:CS',
        max_write_label => 'INT:CS',
        min_write_label => 'PUB',
        def_label       => 'INT:CS',
        row_label       => 'INT:CS'
    );

    -- Dean: Đọc/Ghi CONFIDENTIAL CS
    SA_USER_ADMIN.SET_USER_LABELS(
        policy_name     => 'EXAM_SEC_POLICY',
        user_name       => 'GMS_DEAN',
        max_read_label  => 'CONF:CS',
        max_write_label => 'CONF:CS',
        min_write_label => 'PUB',
        def_label       => 'CONF:CS',
        row_label       => 'CONF:CS'
    );
END;
/
```

### 8.5 Sample Data với Labels

```sql
-- Câu hỏi công khai (Ai cũng thấy)
INSERT INTO EXAM_QUESTIONS (subject_code, question_text, correct_answer, created_by, ols_label)
VALUES ('CS101', 'What is 1+1?', '2', 'SYSTEM', CHAR_TO_LABEL('EXAM_SEC_POLICY', 'PUB'));

-- Câu hỏi nội bộ khoa CS (Chỉ GV và Dean CS thấy)
INSERT INTO EXAM_QUESTIONS (subject_code, question_text, correct_answer, created_by, ols_label)
VALUES ('CS102', 'Explain QuickSort algorithm', 'O(nlogn)', 'LEC001', CHAR_TO_LABEL('EXAM_SEC_POLICY', 'INT:CS'));

-- Đáp án thi MẬT khoa CS (Chỉ Dean CS thấy)
INSERT INTO EXAM_QUESTIONS (subject_code, question_text, correct_answer, created_by, ols_label)
VALUES ('CS101', 'FINAL EXAM ANSWER KEY 2025', 'A, C, D...', 'DEAN001', CHAR_TO_LABEL('EXAM_SEC_POLICY', 'CONF:CS'));
```

---

## 9. QUY TẮC NGHIỆP VỤ / BUSINESS RULES

### 9.1 Quản lý điểm / Grade Management

#### Rule 1: Giảng viên chỉ nhập điểm môn mình dạy
```
IF lecturer_id = current_user_id
   AND course_section.lecturer_id = lecturer_id
THEN ALLOW grade entry
ELSE DENY
```

#### Rule 2: Giảng viên chỉ nhập điểm TRƯỚC deadline
```
IF current_date < grade_submission_deadline.submission_deadline
THEN ALLOW grade entry/update by lecturer
ELSE DENY (only Academic Affairs can modify)
```

#### Rule 3: Mỗi enrollment chỉ có 1 bản ghi điểm
```sql
-- Enforced by UNIQUE constraint
CONSTRAINT uk_enrollment_grade UNIQUE (enrollment_id)
```

#### Rule 4: Điểm phải trong khoảng 0-10
```sql
CHECK (midterm_score >= 0 AND midterm_score <= 10)
CHECK (final_score >= 0 AND final_score <= 10)
CHECK (total_score >= 0 AND total_score <= 10)
```

### 9.2 Giảng viên đa vai trò / Lecturer Multi-Role

Một giảng viên có thể đồng thời giữ nhiều vai trò:

```
┌────────────────────────────────────────────────────────────────┐
│                    LECTURER ROLES                               │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│   LEC001 (Nguyễn Văn A)                                        │
│   ├── Giảng viên dạy môn CS101, CS102                          │
│   │   └── COURSE_SECTIONS.lecturer_id = 'LEC001'               │
│   │                                                             │
│   ├── GVCN lớp CS2024A                                         │
│   │   └── CLASSES.homeroom_teacher_id = 'LEC001'               │
│   │                                                             │
│   ├── Trưởng bộ môn CNPM                                       │
│   │   └── DEPARTMENTS.department_head_id = 'LEC001'            │
│   │                                                             │
│   └── Trưởng khoa CNTT (nếu có)                                │
│       └── FACULTIES.dean_id = 'LEC001'                         │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

**Quyền tổng hợp:**
- Xem sinh viên: Lớp chủ nhiệm + Sinh viên các môn dạy
- Xem điểm: Điểm lớp chủ nhiệm + Điểm các môn dạy
- Sửa điểm: Chỉ các môn dạy (trước deadline)

### 9.3 Quan hệ sinh viên - phụ huynh / Student-Relative Relationship

```sql
-- Nhiều-nhiều relationship
CREATE TABLE STUDENT_RELATIVES (
    student_id VARCHAR2(10) NOT NULL,
    relative_id VARCHAR2(10) NOT NULL,
    relationship VARCHAR2(50) NOT NULL
        CHECK (relationship IN ('Father', 'Mother', 'Guardian', 'Sibling', 'Other')),
    is_primary_contact VARCHAR2(1) DEFAULT 'N'
        CHECK (is_primary_contact IN ('Y', 'N')),
    PRIMARY KEY (student_id, relative_id)
);
```

**Ví dụ:**
| student_id | relative_id | relationship | is_primary_contact |
|------------|-------------|--------------|-------------------|
| STU001 | REL001 | Father | Y |
| STU001 | REL002 | Mother | N |
| STU002 | REL001 | Father | Y |

→ REL001 (Cha) có thể xem điểm của cả STU001 và STU002

### 9.4 Check Constraints Summary

| Table | Constraint | Rule |
|-------|------------|------|
| STUDENTS | gender | IN ('Male', 'Female', 'Other') |
| STUDENTS | student_status | IN ('Active', 'Inactive', 'Graduated', 'Suspended') |
| LECTURERS | lecturer_status | IN ('Active', 'Inactive', 'On Leave', 'Retired') |
| COURSES | credits | > 0 AND <= 10 |
| COURSES | course_type | IN ('Mandatory', 'Elective', 'Specialized') |
| GRADES | midterm/final/total_score | >= 0 AND <= 10 |
| GRADES | grade_status | IN ('Pending', 'Submitted', 'Approved', 'Modified') |
| ENROLLMENTS | enrollment_status | IN ('Enrolled', 'Dropped', 'Completed', 'Failed') |
| COURSE_SECTIONS | section_status | IN ('Open', 'Closed', 'Completed', 'Cancelled') |

---

## 10. FLOW HOẠT ĐỘNG / OPERATION FLOW

### 10.1 Authentication & Authorization Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    LOGIN & ACCESS FLOW                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. USER LOGIN                                                   │
│     ├── Frontend: Username/Password                              │
│     └── Backend: Validate credentials from SYSTEM_USERS          │
│                                                                  │
│  2. GET USER INFO                                                │
│     SELECT user_id, user_type, reference_id                     │
│     FROM SYSTEM_USERS                                            │
│     WHERE username = ? AND password_hash = ?                     │
│                                                                  │
│  3. CONNECT TO DATABASE                                          │
│     └── Backend connects as GMS_APP user                         │
│                                                                  │
│  4. SET VPD CONTEXT                                              │
│     EXEC gms_admin.gms_security_pkg.set_user_context(            │
│         p_user_id   => 'STU001',                                 │
│         p_user_type => 'Student'                                 │
│     );                                                           │
│                                                                  │
│  5. EXECUTE QUERIES                                              │
│     SELECT * FROM gms_admin.STUDENTS;                            │
│     -- VPD automatically adds: WHERE student_id = 'STU001'       │
│                                                                  │
│  6. RETURN FILTERED DATA                                         │
│     └── Only allowed rows returned                               │
│                                                                  │
│  7. AUDIT LOGGED                                                 │
│     └── FGA records access in dba_fga_audit_trail                │
│                                                                  │
│  8. LOGOUT                                                       │
│     EXEC gms_admin.gms_security_pkg.clear_user_context();        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 10.2 Grade Entry Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    GRADE ENTRY FLOW                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. LECTURER LOGS IN                                             │
│     set_user_context('LEC001', 'Lecturer')                       │
│                                                                  │
│  2. VIEW STUDENTS IN COURSE                                      │
│     SELECT s.*, e.enrollment_id                                  │
│     FROM STUDENTS s                                              │
│     JOIN ENROLLMENTS e ON s.student_id = e.student_id            │
│     JOIN COURSE_SECTIONS cs ON e.section_id = cs.section_id      │
│     WHERE cs.lecturer_id = 'LEC001';                             │
│     -- VPD filters automatically                                 │
│                                                                  │
│  3. CHECK DEADLINE                                               │
│     SELECT submission_deadline                                   │
│     FROM GRADE_SUBMISSION_DEADLINES                              │
│     WHERE semester = 'HK1' AND academic_year = 2024;             │
│                                                                  │
│  4. ENTER GRADE (Before Deadline)                                │
│     INSERT INTO GRADES (enrollment_id, midterm_score, ...)       │
│     VALUES (1, 8.5, ...);                                        │
│     -- VPD allows if: lecturer teaches this section AND          │
│     --                current_date < deadline                    │
│                                                                  │
│  5. AUDIT LOGGED                                                 │
│     ├── FGA: INSERT recorded                                     │
│     └── Trigger: trg_audit_grade_insert fires                    │
│                                                                  │
│  6. AFTER DEADLINE                                               │
│     -- Lecturer cannot modify                                    │
│     -- Only Academic_Affairs can update                          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 10.3 Backend Integration (Spring Boot)

```java
// GradeService.java
@Service
public class GradeService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public void setUserContext(String userId, String userType) {
        jdbcTemplate.execute(
            "BEGIN gms_admin.gms_security_pkg.set_user_context('"
            + userId + "', '" + userType + "'); END;"
        );
    }

    public void clearUserContext() {
        jdbcTemplate.execute(
            "BEGIN gms_admin.gms_security_pkg.clear_user_context(); END;"
        );
    }

    public List<Grade> getGrades() {
        // VPD will automatically filter based on context
        return jdbcTemplate.query(
            "SELECT * FROM gms_admin.GRADES",
            new GradeRowMapper()
        );
    }
}
```

---

## 11. FILES VÀ THỨ TỰ CHẠY / SETUP FILES

### 11.1 Danh sách Files / File List

| Order | File | Description | Run As |
|-------|------|-------------|--------|
| 1 | `01-schema/step1_create_users.sql` | Tạo 8 Oracle users | SYSDBA |
| 2 | `01-schema/step2_create_tables.sql` | Tạo 14 tables, views, indexes | GMS_ADMIN |
| 3 | `02-security/step3_password_profiles.sql` | Tạo 5 password profiles | SYSDBA |
| 4 | `02-security/step4_vpd_policies.sql` | Cấu hình VPD | GMS_ADMIN |
| 5 | `02-security/step5_audit_policies.sql` | Cấu hình FGA | GMS_ADMIN |
| 6 | `03-data/step6_sample_data.sql` | Thêm dữ liệu mẫu | GMS_ADMIN |
| 7 | `02-security/step7_ols_setup.sql` | (Tùy chọn) Cấu hình OLS | LBACSYS |

### 11.2 Master Setup Script

```sql
-- SETUP_ALL.sql
-- Run as SYSDBA

-- Connect to PDB
ALTER SESSION SET CONTAINER = ORCLPDB;

-- Step 1: Create Users
@01-schema/step1_create_users.sql

-- Step 2: Create Tables (as GMS_ADMIN)
CONNECT GMS_ADMIN/Admin@2024#Secure@ORCLPDB
@01-schema/step2_create_tables.sql

-- Step 3: Password Profiles (as SYSDBA)
CONNECT / AS SYSDBA
ALTER SESSION SET CONTAINER = ORCLPDB;
@02-security/step3_password_profiles.sql

-- Step 4: VPD Policies
CONNECT GMS_ADMIN/Admin@2024#Secure@ORCLPDB
@02-security/step4_vpd_policies.sql

-- Step 5: Audit Policies
@02-security/step5_audit_policies.sql

-- Step 6: Sample Data
@03-data/step6_sample_data.sql

-- Step 7: OLS (Optional)
-- @02-security/step7_ols_setup.sql

PROMPT ========================================
PROMPT Setup completed successfully!
PROMPT ========================================
```

### 11.3 Maintenance Scripts

| Script | Purpose |
|--------|---------|
| `scripts/CHECK_MAPPING.sql` | Kiểm tra user mapping |
| `scripts/CHECK_USER_ACCOUNTS.sql` | Kiểm tra tài khoản và quyền |
| `scripts/DEMO_USER_ACCESS.sql` | Demo truy cập theo role |
| `scripts/MAINTENANCE_SCRIPTS.sql` | Sửa lỗi và cập nhật |

---

## 12. TEST CASES

### 12.1 Student Test Cases

```sql
-- ========================================
-- STUDENT TEST CASES
-- User: STU001, Type: Student
-- ========================================

-- Setup context
EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');

-- ----------------------------------------
-- TC-S01: Xem thông tin cá nhân
-- Expected: Chỉ 1 row (bản ghi của STU001)
-- ----------------------------------------
SELECT student_id, first_name, last_name, email
FROM gms_admin.STUDENTS;
-- Result: 1 row (STU001)

-- ----------------------------------------
-- TC-S02: Xem điểm của mình
-- Expected: Chỉ điểm của STU001
-- ----------------------------------------
SELECT g.*, e.student_id
FROM gms_admin.GRADES g
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id;
-- Result: Chỉ grades cho enrollments của STU001

-- ----------------------------------------
-- TC-S03: Không thể xem sinh viên khác
-- Expected: 0 rows
-- ----------------------------------------
SELECT * FROM gms_admin.STUDENTS
WHERE student_id = 'STU002';
-- Result: 0 rows (VPD filtered)

-- ----------------------------------------
-- TC-S04: Cập nhật email thành công
-- Expected: 1 row updated
-- ----------------------------------------
UPDATE gms_admin.STUDENTS
SET email = 'new.email@student.edu'
WHERE student_id = 'STU001';
-- Result: 1 row updated

-- ----------------------------------------
-- TC-S05: Không thể cập nhật first_name
-- Expected: ORA-01031 insufficient privileges
-- ----------------------------------------
UPDATE gms_admin.STUDENTS
SET first_name = 'HackedName'
WHERE student_id = 'STU001';
-- Result: ORA-01031: insufficient privileges

-- ----------------------------------------
-- TC-S06: Không thể xóa bản ghi
-- Expected: Error
-- ----------------------------------------
DELETE FROM gms_admin.STUDENTS WHERE student_id = 'STU001';
-- Result: ORA-01031 or 0 rows deleted

-- Cleanup
EXEC gms_admin.gms_security_pkg.clear_user_context();
```

### 12.2 Lecturer Test Cases

```sql
-- ========================================
-- LECTURER TEST CASES
-- User: LEC001, Type: Lecturer
-- Teaches: CS101-HK1, Homeroom: CS2024A
-- ========================================

EXEC gms_admin.gms_security_pkg.set_user_context('LEC001', 'Lecturer');

-- ----------------------------------------
-- TC-L01: Xem sinh viên lớp chủ nhiệm
-- Expected: Tất cả SV lớp CS2024A
-- ----------------------------------------
SELECT * FROM gms_admin.STUDENTS
WHERE class_id = 'CS2024A';
-- Result: Sinh viên lớp CS2024A (nếu LEC001 là homeroom teacher)

-- ----------------------------------------
-- TC-L02: Xem sinh viên môn mình dạy
-- Expected: SV đăng ký môn LEC001 dạy
-- ----------------------------------------
SELECT DISTINCT s.student_id, s.first_name, s.last_name
FROM gms_admin.STUDENTS s
JOIN gms_admin.ENROLLMENTS e ON s.student_id = e.student_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
WHERE cs.lecturer_id = 'LEC001';
-- Result: Sinh viên đăng ký các section của LEC001

-- ----------------------------------------
-- TC-L03: Xem tất cả sinh viên được phép
-- Expected: SV homeroom + SV môn dạy
-- ----------------------------------------
SELECT COUNT(*) FROM gms_admin.STUDENTS;
-- Result: Count of accessible students

-- ----------------------------------------
-- TC-L04: Xem điểm môn mình dạy
-- Expected: Điểm các môn LEC001 dạy + lớp chủ nhiệm
-- ----------------------------------------
SELECT g.*, cs.section_id
FROM gms_admin.GRADES g
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id;
-- Result: Grades for sections taught by LEC001 + homeroom students

-- ----------------------------------------
-- TC-L05: Nhập điểm môn mình dạy (Trước deadline)
-- Expected: Success
-- ----------------------------------------
-- First check deadline
SELECT submission_deadline
FROM gms_admin.GRADE_SUBMISSION_DEADLINES
WHERE semester = 'HK1' AND academic_year = 2024;

-- Insert grade (assuming enrollment_id 1 is for LEC001's section)
INSERT INTO gms_admin.GRADES (enrollment_id, midterm_score, grade_status)
VALUES (1, 8.5, 'Pending');
-- Result: 1 row inserted (if before deadline)

-- ----------------------------------------
-- TC-L06: Cập nhật điểm môn mình dạy
-- Expected: Success (before deadline)
-- ----------------------------------------
UPDATE gms_admin.GRADES
SET midterm_score = 9.0, grade_status = 'Submitted'
WHERE enrollment_id = 1;
-- Result: 1 row updated

-- ----------------------------------------
-- TC-L07: Không thể nhập điểm môn người khác dạy
-- Expected: 0 rows affected
-- ----------------------------------------
-- Assuming enrollment_id 999 belongs to another lecturer's section
INSERT INTO gms_admin.GRADES (enrollment_id, midterm_score)
VALUES (999, 10);
-- Result: 0 rows inserted (VPD filtered)

-- ----------------------------------------
-- TC-L08: Không thể xem sinh viên khoa khác
-- Expected: 0 rows
-- ----------------------------------------
SELECT * FROM gms_admin.STUDENTS
WHERE class_id IN (
    SELECT class_id FROM gms_admin.CLASSES
    WHERE faculty_id != 'FAC001'
);
-- Result: 0 rows (if LEC001 only teaches in FAC001)

EXEC gms_admin.gms_security_pkg.clear_user_context();
```

### 12.3 Dean Test Cases

```sql
-- ========================================
-- DEAN TEST CASES
-- User: DEAN001, Type: Dean
-- Faculty: FAC001 (Computer Science)
-- ========================================

EXEC gms_admin.gms_security_pkg.set_user_context('DEAN001', 'Dean');

-- ----------------------------------------
-- TC-D01: Xem tất cả sinh viên trong khoa
-- Expected: Tất cả SV thuộc FAC001
-- ----------------------------------------
SELECT COUNT(*) as total_students
FROM gms_admin.STUDENTS s
JOIN gms_admin.CLASSES c ON s.class_id = c.class_id
WHERE c.faculty_id = 'FAC001';
-- Compare with:
SELECT COUNT(*) FROM gms_admin.STUDENTS;
-- Should be equal

-- ----------------------------------------
-- TC-D02: Xem điểm tất cả SV trong khoa
-- Expected: Điểm tất cả SV trong FAC001
-- ----------------------------------------
SELECT COUNT(*) FROM gms_admin.GRADES;
-- Result: All grades for students in faculty

-- ----------------------------------------
-- TC-D03: Không thể xem SV khoa khác
-- Expected: 0 rows
-- ----------------------------------------
SELECT s.*
FROM gms_admin.STUDENTS s
JOIN gms_admin.CLASSES c ON s.class_id = c.class_id
WHERE c.faculty_id = 'FAC002';  -- Different faculty
-- Result: 0 rows

-- ----------------------------------------
-- TC-D04: Xem thông tin khoa mình quản lý
-- Expected: Chỉ FAC001
-- ----------------------------------------
SELECT * FROM gms_admin.FACULTIES;
-- Result: 1 row (FAC001 only)

EXEC gms_admin.gms_security_pkg.clear_user_context();
```

### 12.4 Academic Affairs Test Cases

```sql
-- ========================================
-- ACADEMIC AFFAIRS TEST CASES
-- User: AA001, Type: Academic_Affairs
-- ========================================

EXEC gms_admin.gms_security_pkg.set_user_context('AA001', 'Academic_Affairs');

-- ----------------------------------------
-- TC-A01: Xem tất cả sinh viên
-- Expected: Tất cả sinh viên trong hệ thống
-- ----------------------------------------
SELECT COUNT(*) as total FROM gms_admin.STUDENTS;
-- Compare with actual count in database

-- ----------------------------------------
-- TC-A02: Xem tất cả điểm
-- Expected: Tất cả điểm trong hệ thống
-- ----------------------------------------
SELECT COUNT(*) as total FROM gms_admin.GRADES;

-- ----------------------------------------
-- TC-A03: Sửa điểm bất kỳ lúc nào
-- Expected: Success (bypass deadline)
-- ----------------------------------------
UPDATE gms_admin.GRADES
SET final_score = 9.0,
    grade_status = 'Modified',
    modified_by = 'AA001',
    modified_date = SYSDATE,
    modification_reason = 'Score correction'
WHERE grade_id = 1;
-- Result: 1 row updated (even after deadline)

-- ----------------------------------------
-- TC-A04: Thêm sinh viên mới
-- Expected: Success
-- ----------------------------------------
INSERT INTO gms_admin.STUDENTS (
    student_id, first_name, last_name, date_of_birth,
    email, class_id
) VALUES (
    'STU999', 'Test', 'Student', DATE '2000-01-01',
    'test@student.edu', 'CS2024A'
);
-- Result: 1 row inserted

-- Cleanup test data
DELETE FROM gms_admin.STUDENTS WHERE student_id = 'STU999';

EXEC gms_admin.gms_security_pkg.clear_user_context();
```

### 12.5 Relative Test Cases

```sql
-- ========================================
-- RELATIVE TEST CASES
-- User: REL001, Type: Relative
-- Related to: STU001 (Father)
-- ========================================

EXEC gms_admin.gms_security_pkg.set_user_context('REL001', 'Relative');

-- ----------------------------------------
-- TC-R01: Xem thông tin con em
-- Expected: Chỉ SV liên kết với REL001
-- ----------------------------------------
SELECT s.student_id, s.first_name, s.last_name
FROM gms_admin.STUDENTS s
JOIN gms_admin.STUDENT_RELATIVES sr ON s.student_id = sr.student_id
WHERE sr.relative_id = 'REL001';
-- Note: VPD should show same result as:
SELECT * FROM gms_admin.STUDENTS;

-- ----------------------------------------
-- TC-R02: Xem điểm con em
-- Expected: Chỉ điểm của con em
-- ----------------------------------------
SELECT g.*, e.student_id
FROM gms_admin.GRADES g
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id;
-- Result: Only grades for related students

-- ----------------------------------------
-- TC-R03: Không thể xem SV không liên quan
-- Expected: 0 rows
-- ----------------------------------------
SELECT * FROM gms_admin.STUDENTS
WHERE student_id NOT IN (
    SELECT student_id FROM gms_admin.STUDENT_RELATIVES
    WHERE relative_id = 'REL001'
);
-- Result: 0 rows

-- ----------------------------------------
-- TC-R04: Không thể sửa điểm
-- Expected: Error
-- ----------------------------------------
UPDATE gms_admin.GRADES SET midterm_score = 10 WHERE grade_id = 1;
-- Result: ORA-01031 or 0 rows updated

-- ----------------------------------------
-- TC-R05: Cập nhật thông tin liên hệ của mình
-- Expected: Success
-- ----------------------------------------
UPDATE gms_admin.RELATIVES
SET phone_number = '0901234567'
WHERE relative_id = 'REL001';
-- Result: 1 row updated

EXEC gms_admin.gms_security_pkg.clear_user_context();
```

### 12.6 Department Head Test Cases

```sql
-- ========================================
-- DEPARTMENT HEAD TEST CASES
-- User: DH001, Type: Department_Head
-- Department: DEPT01 (Software Engineering)
-- ========================================

EXEC gms_admin.gms_security_pkg.set_user_context('DH001', 'Department_Head');

-- ----------------------------------------
-- TC-DH01: Xem điểm các môn trong bộ môn
-- Expected: Điểm môn thuộc DEPT01
-- ----------------------------------------
SELECT g.*, c.course_name, c.department_id
FROM gms_admin.GRADES g
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN gms_admin.COURSES c ON cs.course_id = c.course_id
WHERE c.department_id = 'DEPT01';
-- Compare with:
SELECT COUNT(*) FROM gms_admin.GRADES;

-- ----------------------------------------
-- TC-DH02: Xem thông tin bộ môn mình quản lý
-- Expected: Chỉ DEPT01
-- ----------------------------------------
SELECT * FROM gms_admin.DEPARTMENTS;
-- Result: 1 row (DEPT01)

-- ----------------------------------------
-- TC-DH03: Không thể xem điểm bộ môn khác
-- Expected: 0 rows
-- ----------------------------------------
SELECT g.*
FROM gms_admin.GRADES g
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN gms_admin.COURSES c ON cs.course_id = c.course_id
WHERE c.department_id != 'DEPT01';
-- Result: 0 rows (VPD filtered)

EXEC gms_admin.gms_security_pkg.clear_user_context();
```

### 12.7 Admin Test Cases

```sql
-- ========================================
-- ADMIN TEST CASES
-- User: GMS_ADMIN (Schema Owner)
-- ========================================

-- Note: GMS_ADMIN bypasses all VPD policies

-- ----------------------------------------
-- TC-ADM01: Xem tất cả data không bị filter
-- ----------------------------------------
SELECT COUNT(*) as students FROM gms_admin.STUDENTS;
SELECT COUNT(*) as grades FROM gms_admin.GRADES;
SELECT COUNT(*) as enrollments FROM gms_admin.ENROLLMENTS;
-- Result: Full counts, no filtering

-- ----------------------------------------
-- TC-ADM02: Có thể thực hiện mọi thao tác
-- ----------------------------------------
-- INSERT, UPDATE, DELETE all work without restrictions
```

### 12.8 Password Policy Test Cases

```sql
-- ========================================
-- PASSWORD POLICY TEST CASES
-- ========================================

-- ----------------------------------------
-- TC-PWD01: Mật khẩu yếu bị reject
-- Expected: Error
-- ----------------------------------------
ALTER USER GMS_STUDENT IDENTIFIED BY "weak";
-- Result: ORA-28003: password verification failed

-- ----------------------------------------
-- TC-PWD02: Mật khẩu không có số bị reject
-- ----------------------------------------
ALTER USER GMS_STUDENT IDENTIFIED BY "NoNumbers!";
-- Result: ORA-28003: Password must contain at least one digit

-- ----------------------------------------
-- TC-PWD03: Mật khẩu hợp lệ được chấp nhận
-- ----------------------------------------
ALTER USER GMS_STUDENT IDENTIFIED BY "ValidPass123!";
-- Result: User altered

-- ----------------------------------------
-- TC-PWD04: Khóa tài khoản sau n lần sai
-- ----------------------------------------
-- Try login with wrong password 5 times for STUDENT profile
-- Result: Account locked after 5 failed attempts
```

### 12.9 Audit Test Cases

```sql
-- ========================================
-- AUDIT TEST CASES
-- ========================================

-- ----------------------------------------
-- TC-AUD01: Kiểm tra FGA ghi log SELECT
-- ----------------------------------------
-- As student, select grades
EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');
SELECT * FROM gms_admin.GRADES;

-- Check FGA log
SELECT timestamp, db_user, sql_text
FROM dba_fga_audit_trail
WHERE object_name = 'GRADES'
AND statement_type = 'SELECT'
ORDER BY timestamp DESC
FETCH FIRST 5 ROWS ONLY;

-- ----------------------------------------
-- TC-AUD02: Kiểm tra custom audit trigger
-- ----------------------------------------
EXEC gms_admin.gms_security_pkg.set_user_context('LEC001', 'Lecturer');

INSERT INTO gms_admin.GRADES (enrollment_id, midterm_score)
VALUES (1, 8.5);

-- Check custom audit log
SELECT * FROM gms_admin.AUDIT_LOG
WHERE table_name = 'GRADES'
ORDER BY operation_date DESC
FETCH FIRST 5 ROWS ONLY;
```

---

## PHỤ LỤC / APPENDIX

### A. Troubleshooting Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| ORA-28113: policy predicate has error | VPD policy syntax error | Check policy function, test predicate manually |
| ORA-01031: insufficient privileges | Missing grants | Grant required privileges to user |
| No rows returned | VPD filtering all rows | Check context is set correctly |
| Account locked | Too many failed logins | ALTER USER ... ACCOUNT UNLOCK |
| Password rejected | Does not meet requirements | Use password with uppercase, lowercase, digit, special char |

### B. Quick Reference SQL

```sql
-- Check current context
SELECT
    SYS_CONTEXT('gms_context', 'user_id') as user_id,
    SYS_CONTEXT('gms_context', 'user_type') as user_type,
    SYS_CONTEXT('USERENV', 'SESSION_USER') as session_user
FROM DUAL;

-- Check VPD policies
SELECT policy_name, object_name, function, sel, ins, upd, del
FROM dba_policies
WHERE object_owner = 'GMS_ADMIN';

-- Check password profile
SELECT profile, resource_name, limit
FROM dba_profiles
WHERE profile LIKE 'GMS%'
ORDER BY profile, resource_name;

-- Check FGA policies
SELECT policy_name, object_schema, object_name, statement_types
FROM dba_audit_policies
WHERE object_schema = 'GMS_ADMIN';
```

### C. Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Dec 2024 | Initial documentation |

---

**Document End**
