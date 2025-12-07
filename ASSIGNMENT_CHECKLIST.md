# CHECKLIST BÀI TẬP LỚN - ISS ASSIGNMENT CHECKLIST

> **Môn học**: Bảo mật Hệ thống Thông tin  
> **Học kỳ**: 1/ Năm học 2025-2026  
> **Đề tài**: Quản lý điểm trong trường đại học

---

## 📋 NỘI DUNG 1: MÔ TẢ QUY TRÌNH NGHIỆP VỤ (2đ)

### ✅ Đã hoàn thành:

- [x] **File**: `LOGIC_NGHIEP_VU_TONG_HOP.md`
  - Mô tả đầy đủ quy trình nghiệp vụ
  - Các chính sách bảo mật
  - Phân quyền người dùng
  - Flow hoạt động

### 📝 Cần bổ sung (nếu cần):

- [ ] Thêm sơ đồ luồng nghiệp vụ (flowchart)
- [ ] Thêm use cases chi tiết
- [ ] Thêm mô tả các trường hợp đặc biệt

---

## 📋 NỘI DUNG 2: CÀI ĐẶT CÁC CHÍNH SÁCH BẢO MẬT (5đ)

### 2.1 Tạo các bảng và insert dữ liệu (1đ) ✅

- [x] **File**: `01-schema/step2_create_tables.sql`
  - 14 bảng chính
  - 3 views
  - Constraints, indexes

- [x] **File**: `03-data/step6_sample_data.sql`
  - Dữ liệu mẫu đầy đủ
  - Sinh viên, giảng viên, điểm, etc.

### 2.2 Tạo các user và cấp quyền (0.5đ) ✅

- [x] **File**: `01-schema/step1_create_users.sql`
  - GMS_ADMIN (admin)
  - GMS_APP (backend application)
  - GMS_STUDENT, GMS_LECTURER, GMS_ACADEMIC, GMS_DEAN (testing)

- [x] **File**: `04-tests/00_grant_test_privileges.sql`
  - Cấp quyền SELECT, INSERT, UPDATE, DELETE
  - Cấp quyền EXECUTE trên security packages

### 2.3 Password Policies (0.5đ) ✅

- [x] **File**: `02-security/step3_password_profiles.sql`
  - 5 profiles: STUDENT, LECTURER, ACADEMIC, RELATIVE, SYSADMIN
  - Quy định về:
    - Password complexity
    - Password lifetime
    - Failed login attempts
    - Connect time, idle time
    - Sessions per user

### 2.4 Các chính sách bảo mật (3đ) ✅

#### VPD (Virtual Private Database) ✅

- [x] **File**: `02-security/step4_vpd_policies.sql`
  - 6 VPD policies:
    - `student_policy` - Row-level security cho STUDENTS
    - `grade_policy` - Row-level security cho GRADES
    - `lecturer_grade_policy` - Row-level security cho GRADES (lecturer update)
    - `relative_policy` - Row-level security cho RELATIVES
    - `department_policy` - Row-level security cho DEPARTMENTS
    - `faculty_policy` - Row-level security cho FACULTIES

- [x] **Implementation**:
  - Security context: `gms_context`
  - Security package: `gms_security_pkg`
  - Policy functions tự động filter data theo role

#### OLS (Oracle Label Security) ✅

- [x] **File**: `02-security/step7_ols_setup.sql`
  - Policy: `EXAM_SEC_POLICY`
  - Levels: PUB (Public), INT (Internal), CONF (Confidential)
  - Compartments: CS (Computer Science), EE (Electrical Engineering)
  - Labels: PUB, INT:CS, INT:EE, CONF:CS, CONF:EE
  - Áp dụng cho bảng: `EXAM_QUESTIONS`

- [x] **User Labels**:
  - Student: PUB
  - Lecturer: PUB, INT:CS (hoặc INT:EE tùy khoa)
  - Dean: PUB, INT:CS, CONF:CS (hoặc tương ứng với khoa)
  - Admin: Tất cả labels

#### FGA (Fine-Grained Auditing) ✅

- [x] **File**: `02-security/step5_audit_policies.sql`
  - 8 FGA policies:
    - Audit SELECT trên STUDENTS, GRADES, ENROLLMENTS
    - Audit INSERT, UPDATE, DELETE trên GRADES
    - Audit INSERT, UPDATE, DELETE trên STUDENTS
  - Audit log lưu vào: `AUDIT_LOG` table

---

## 📋 NỘI DUNG 3: HIỆN THỰC (2đ)

### ✅ Đã hoàn thành:

- [x] **Backend**: Spring Boot
  - REST API đầy đủ
  - JWT Authentication
  - VPD Context Integration
  - OLS Integration (Exam Questions)

- [x] **Frontend**: Flutter
  - Mobile app đầy đủ
  - Login/Logout
  - View/Update profile
  - View/Update grades (lecturer)
  - View exam questions (OLS)

### 📝 Cần kiểm tra:

- [ ] App chạy được trên thiết bị/emulator
- [ ] Tất cả chức năng hoạt động đúng
- [ ] VPD filter hoạt động đúng (mỗi user chỉ thấy data của mình)
- [ ] OLS filter hoạt động đúng (mỗi user chỉ thấy questions theo label)

---

## 📋 NỘI DUNG 4: BÁO CÁO (1đ)

### ✅ Đã có:

- [x] **Tài liệu tham khảo**: 
  - `LOGIC_NGHIEP_VU_TONG_HOP.md`
  - `ARCHITECTURE_DB_CONNECTION.md`
  - `DEMO_VPD_OLS_GUIDE.md`
  - `OLS_COMPLETE_SETUP_GUIDE.md`

- [x] **Scripts**:
  - `SETUP_ALL.sql` - Master setup script
  - `01-schema/step1_create_users.sql`
  - `01-schema/step2_create_tables.sql`
  - `02-security/step3_password_profiles.sql`
  - `02-security/step4_vpd_policies.sql`
  - `02-security/step5_audit_policies.sql`
  - `02-security/step7_ols_setup.sql`
  - `03-data/step6_sample_data.sql`

- [x] **Source code**:
  - Backend: `secu/backend/`
  - Frontend: `secu/flutter_app/`

### 📝 Cần bổ sung:

- [ ] **Bảng phân công nhiệm vụ**:
  - Ai làm phần nào?
  - Đánh giá đóng góp của từng thành viên

- [ ] **Link/đường dẫn**:
  - Link GitHub repository
  - Link demo video (nếu có)
  - Link tài liệu online (nếu có)

---

## 🎯 DEMO CHO BÁO CÁO

### Cách demo VPD và OLS:

#### 1. Demo VPD qua SQL*Plus (Khuyến nghị)

```sql
-- Terminal 1: Student
sqlplus GMS_STUDENT/Student@2024@//localhost:1521/ORCLPDB
EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');
SELECT COUNT(*) FROM gms_admin.STUDENTS;  -- Chỉ thấy 1
SELECT COUNT(*) FROM gms_admin.GRADES;    -- Chỉ thấy điểm của STU001

-- Terminal 2: Lecturer
sqlplus GMS_LECTURER/Lecturer@2024@//localhost:1521/ORCLPDB
EXEC gms_admin.gms_security_pkg.set_user_context('LEC001', 'Lecturer');
SELECT COUNT(*) FROM gms_admin.STUDENTS;  -- Thấy SV trong lớp dạy
SELECT COUNT(*) FROM gms_admin.GRADES;    -- Thấy điểm của các môn dạy

-- Terminal 3: Academic
sqlplus GMS_ACADEMIC/Academic@2024@//localhost:1521/ORCLPDB
EXEC gms_admin.gms_security_pkg.set_user_context('ACAD001', 'Academic_Affairs');
SELECT COUNT(*) FROM gms_admin.STUDENTS;  -- Thấy TẤT CẢ
SELECT COUNT(*) FROM gms_admin.GRADES;    -- Thấy TẤT CẢ
```

#### 2. Demo OLS qua SQL*Plus

```sql
-- Terminal 1: Lecturer
sqlplus GMS_LECTURER/Lecturer@2024@//localhost:1521/ORCLPDB
EXEC gms_admin.gms_security_pkg.set_user_context('LEC001', 'Lecturer');
SELECT question_id, LABEL_TO_CHAR(ols_label) AS label
FROM gms_admin.EXAM_QUESTIONS;
-- Kết quả: Chỉ thấy PUB và INT:CS

-- Terminal 2: Dean
sqlplus GMS_DEAN/Dean@2024@//localhost:1521/ORCLPDB
EXEC gms_admin.gms_security_pkg.set_user_context('FAC001', 'Dean');
SELECT question_id, LABEL_TO_CHAR(ols_label) AS label
FROM gms_admin.EXAM_QUESTIONS;
-- Kết quả: Thấy PUB, INT:CS, CONF:CS
```

#### 3. Demo qua API (Giống production)

```bash
# Login với student
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"nvhai","password":"password123"}'

# Query grades (chỉ thấy điểm của STU001)
curl -X GET http://localhost:8081/api/students/me/grades \
  -H "Authorization: Bearer <TOKEN>"

# Login với lecturer
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"nv.an","password":"password123"}'

# Query exam questions (chỉ thấy PUB và INT:CS)
curl -X GET http://localhost:8081/api/exam-questions \
  -H "Authorization: Bearer <TOKEN>"
```

### 📸 Screenshots cần có:

- [ ] Screenshot VPD: Student chỉ thấy 1 record
- [ ] Screenshot VPD: Lecturer thấy nhiều records hơn
- [ ] Screenshot VPD: Academic thấy tất cả
- [ ] Screenshot OLS: Lecturer chỉ thấy PUB và INT:CS
- [ ] Screenshot OLS: Dean thấy tất cả labels
- [ ] Screenshot API: Login và query với các users khác nhau
- [ ] Screenshot Flutter app: Các màn hình chính

---

## ✅ CHECKLIST TỔNG HỢP

### Database Setup:

- [x] Tạo users (`step1_create_users.sql`)
- [x] Tạo tables (`step2_create_tables.sql`)
- [x] Password profiles (`step3_password_profiles.sql`)
- [x] VPD policies (`step4_vpd_policies.sql`)
- [x] FGA policies (`step5_audit_policies.sql`)
- [x] Sample data (`step6_sample_data.sql`)
- [x] OLS setup (`step7_ols_setup.sql`)

### Security Features:

- [x] VPD (Row-level security) - 6 policies
- [x] OLS (Oracle Label Security) - 1 policy cho EXAM_QUESTIONS
- [x] FGA (Fine-Grained Auditing) - 8 policies
- [x] Password Profiles - 5 profiles

### Application:

- [x] Backend (Spring Boot)
- [x] Frontend (Flutter)
- [x] VPD integration
- [x] OLS integration

### Documentation:

- [x] Business logic (`LOGIC_NGHIEP_VU_TONG_HOP.md`)
- [x] Architecture (`ARCHITECTURE_DB_CONNECTION.md`)
- [x] Demo guide (`DEMO_VPD_OLS_GUIDE.md`)
- [x] OLS guide (`OLS_COMPLETE_SETUP_GUIDE.md`)
- [ ] Assignment report (cần viết)

---

## 📝 LƯU Ý QUAN TRỌNG

### Về Single DB User + VPD Context:

- ✅ **Backend dùng GMS_APP** (single user) - Đúng cho production
- ✅ **VPD context được set tự động** bởi `VpdContextInterceptor`
- ✅ **Demo qua SQL*Plus** dùng các Oracle users khác nhau (GMS_STUDENT, GMS_LECTURER, etc.)
- ✅ **Cả hai cách đều cho thấy VPD/OLS hoạt động đúng**

### Về Demo:

- ✅ **Có thể demo qua SQL*Plus** - Rõ ràng, dễ hiểu
- ✅ **Có thể demo qua API** - Giống production
- ✅ **Cả hai cách đều hợp lệ** cho báo cáo

---

## 🔗 TÀI LIỆU THAM KHẢO

- `DEMO_VPD_OLS_GUIDE.md` - Hướng dẫn demo chi tiết
- `04-tests/DEMO_VPD_OLS_COMPLETE.sql` - Script demo SQL
- `ARCHITECTURE_DB_CONNECTION.md` - Kiến trúc kết nối database
- `LOGIC_NGHIEP_VU_TONG_HOP.md` - Tổng hợp logic nghiệp vụ

---

**Tóm tắt**: Hệ thống đã đáp ứng đầy đủ yêu cầu assignment với:
- ✅ VPD (Row-level security)
- ✅ OLS (Oracle Label Security)
- ✅ FGA (Fine-Grained Auditing)
- ✅ Password Profiles
- ✅ Backend + Frontend đầy đủ

**Cần làm**: Viết báo cáo và demo cho giảng viên!

