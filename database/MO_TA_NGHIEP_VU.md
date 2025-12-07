# 📋 MÔ TẢ NGHIỆP VỤ - HỆ THỐNG QUẢN LÝ ĐIỂM TRƯỜNG ĐẠI HỌC

## 🎯 MỤC ĐÍCH HỆ THỐNG

Hệ thống quản lý điểm toàn diện cho trường đại học, hỗ trợ:

- Quản lý thông tin sinh viên, giảng viên, khóa học
- Quản lý điểm số với workflow phê duyệt
- Kiểm soát truy cập theo vai trò (Role-Based Access Control)
- Audit trail đầy đủ cho mọi thao tác
- Bảo mật đa lớp (VPD, FGA, Password Profiles)

---

## 🏛️ CẤU TRÚC TỔ CHỨC

### 1. Cấp độ tổ chức

```
UNIVERSITY
    └── FACULTIES (Khoa)
            └── DEPARTMENTS (Bộ môn)
                    └── CLASSES (Lớp)
                            └── STUDENTS (Sinh viên)
```

**Mối quan hệ:**

- **1 Khoa** có nhiều **Bộ môn**
- **1 Bộ môn** có nhiều **Lớp**
- **1 Lớp** có nhiều **Sinh viên**
- **1 Khoa** có 1 **Trưởng khoa** (Dean - là Lecturer)
- **1 Bộ môn** có 1 **Trưởng bộ môn** (Department Head - là Lecturer)
- **1 Lớp** có 1 **Giáo viên chủ nhiệm** (Homeroom Teacher - là Lecturer)

---

## 👥 CÁC THỰC THỂ CHÍNH

### 1. FACULTIES (Khoa)

**Mục đích:** Đại diện cho các khoa trong trường

**Thông tin:**

- `faculty_id`: Mã khoa (PK)
- `faculty_name`: Tên khoa
- `dean_id`: Trưởng khoa (FK → LECTURERS)
- `established_date`: Ngày thành lập
- `description`: Mô tả

**Ví dụ:**

- FAC001: Faculty of Computer Science and Engineering
- FAC002: Faculty of Electrical and Electronics Engineering
- FAC003: Faculty of Mechanical Engineering

---

### 2. DEPARTMENTS (Bộ môn)

**Mục đích:** Đại diện cho các bộ môn trong khoa

**Thông tin:**

- `department_id`: Mã bộ môn (PK)
- `department_name`: Tên bộ môn
- `faculty_id`: Thuộc khoa nào (FK → FACULTIES)
- `department_head_id`: Trưởng bộ môn (FK → LECTURERS)
- `established_date`: Ngày thành lập
- `description`: Mô tả

**Ví dụ:**

- DEPT001: Computer Science (thuộc FAC001)
- DEPT002: Software Engineering (thuộc FAC001)
- DEPT003: Electrical Engineering (thuộc FAC002)

---

### 3. CLASSES (Lớp)

**Mục đích:** Đại diện cho các lớp học trong khoa

**Thông tin:**

- `class_id`: Mã lớp (PK)
- `class_name`: Tên lớp (ví dụ: CS2021A)
- `faculty_id`: Thuộc khoa nào (FK → FACULTIES)
- `academic_year`: Năm học (ví dụ: 2021)
- `homeroom_teacher_id`: Giáo viên chủ nhiệm (FK → LECTURERS)
- `total_students`: Tổng số sinh viên

**Ví dụ:**

- CLS001: CS2021A (Khoa CS, năm 2021, GVCN: LEC001)
- CLS002: CS2021B (Khoa CS, năm 2021, GVCN: LEC002)

---

### 4. STUDENTS (Sinh viên)

**Mục đích:** Quản lý thông tin sinh viên

**Thông tin:**

- `student_id`: Mã sinh viên (PK, ví dụ: STU001)
- `first_name`, `last_name`: Họ và tên
- `date_of_birth`: Ngày sinh
- `gender`: Giới tính (Male, Female, Other)
- `hometown`: Quê quán
- `ethnicity`: Dân tộc
- `religion`: Tôn giáo
- `email`: Email (UNIQUE)
- `phone_number`: Số điện thoại
- `contact_address`: Địa chỉ liên lạc
- `class_id`: Thuộc lớp nào (FK → CLASSES)
- `enrollment_date`: Ngày nhập học
- `student_status`: Trạng thái (Active, Inactive, Graduated, Suspended)

**Quyền hạn:**

- ✅ Xem thông tin của mình
- ✅ Xem điểm của mình
- ✅ Cập nhật: `email`, `phone_number`, `contact_address` (chỉ trong record của mình)
- ❌ Không thể xem thông tin sinh viên khác
- ❌ Không thể sửa điểm

---

### 5. LECTURERS (Giảng viên)

**Mục đích:** Quản lý thông tin giảng viên

**Thông tin:**

- `lecturer_id`: Mã giảng viên (PK, ví dụ: LEC001)
- `first_name`, `last_name`: Họ và tên
- `date_of_birth`: Ngày sinh
- `gender`: Giới tính
- `hometown`: Quê quán
- `email`: Email (UNIQUE, NOT NULL)
- `phone_number`: Số điện thoại
- `contact_address`: Địa chỉ liên lạc
- `department_id`: Thuộc bộ môn nào (FK → DEPARTMENTS)
- `start_date`: Ngày bắt đầu làm việc
- `academic_degree`: Học vị (ví dụ: PhD)
- `specialization`: Chuyên ngành
- `lecturer_status`: Trạng thái (Active, Inactive, On Leave, Retired)

**Vai trò có thể đảm nhiệm:**

- Giảng viên dạy môn học
- Giáo viên chủ nhiệm lớp
- Trưởng bộ môn
- Trưởng khoa

**Quyền hạn:**

- ✅ Xem danh sách sinh viên trong lớp mình chủ nhiệm
- ✅ Xem điểm của sinh viên trong môn mình dạy
- ✅ Nhập/sửa điểm (trước deadline)
- ✅ Cập nhật: `email`, `phone_number`, `contact_address` (chỉ trong record của mình)

---

### 6. RELATIVES (Người thân)

**Mục đích:** Quản lý thông tin người thân của sinh viên

**Thông tin:**

- `relative_id`: Mã người thân (PK, ví dụ: REL001)
- `first_name`, `last_name`: Họ và tên
- `date_of_birth`: Ngày sinh
- `gender`: Giới tính
- `contact_address`: Địa chỉ liên lạc
- `phone_number`: Số điện thoại (NOT NULL)
- `occupation`: Nghề nghiệp
- `email`: Email

**Mối quan hệ:**

- Quan hệ với sinh viên qua bảng `STUDENT_RELATIVES`
- `relationship`: Mối quan hệ (Father, Mother, Guardian, Sibling, Other)
- `is_primary_contact`: Là người liên hệ chính (Y/N)

**Quyền hạn:**

- ✅ Xem thông tin của mình
- ✅ Xem điểm của con/người thân
- ✅ Cập nhật: `email`, `phone_number`, `contact_address` (chỉ trong record của mình)
- ❌ Không thể xem thông tin sinh viên khác

---

### 7. COURSES (Môn học)

**Mục đích:** Quản lý danh mục môn học

**Thông tin:**

- `course_id`: Mã môn học (PK, ví dụ: CS101)
- `course_name`: Tên môn học
- `credits`: Số tín chỉ (1-10)
- `department_id`: Thuộc bộ môn nào (FK → DEPARTMENTS)
- `course_type`: Loại môn (Mandatory, Elective, Specialized)
- `prerequisite_course_id`: Môn học tiên quyết (FK → COURSES, có thể NULL)
- `description`: Mô tả

**Ví dụ:**

- CS101: Introduction to Programming (3 credits, Mandatory)
- CS201: Data Structures (3 credits, Mandatory, prerequisite: CS101)

---

### 8. COURSE_SECTIONS (Lớp học phần)

**Mục đích:** Đại diện cho một lớp học phần cụ thể trong một học kỳ

**Thông tin:**

- `section_id`: Mã lớp học phần (PK, ví dụ: CS101-2021-FALL-001)
- `course_id`: Môn học nào (FK → COURSES)
- `lecturer_id`: Giảng viên dạy (FK → LECTURERS)
- `semester`: Học kỳ (ví dụ: Fall, Spring, Summer)
- `academic_year`: Năm học (ví dụ: 2021)
- `max_students`: Số sinh viên tối đa
- `enrolled_students`: Số sinh viên đã đăng ký
- `classroom`: Phòng học
- `schedule`: Lịch học
- `section_status`: Trạng thái (Open, Closed, Completed, Cancelled)

**Đặc điểm:**

- Một môn học có thể có nhiều lớp học phần trong cùng học kỳ
- Mỗi lớp học phần do 1 giảng viên phụ trách
- Sinh viên đăng ký vào lớp học phần cụ thể

---

### 9. ENROLLMENTS (Đăng ký học phần)

**Mục đích:** Quản lý việc đăng ký học phần của sinh viên

**Thông tin:**

- `enrollment_id`: Mã đăng ký (PK, auto-increment)
- `student_id`: Sinh viên nào (FK → STUDENTS)
- `section_id`: Lớp học phần nào (FK → COURSE_SECTIONS)
- `enrollment_date`: Ngày đăng ký
- `enrollment_status`: Trạng thái (Enrolled, Dropped, Completed, Failed)

**Ràng buộc:**

- Một sinh viên chỉ có thể đăng ký 1 lần cho 1 lớp học phần (UNIQUE constraint)
- Phải có enrollment trước khi có điểm (GRADES → ENROLLMENTS)

---

### 10. GRADES (Điểm số)

**Mục đích:** Quản lý điểm số của sinh viên

**Thông tin:**

- `grade_id`: Mã điểm (PK, auto-increment)
- `enrollment_id`: Thuộc đăng ký nào (FK → ENROLLMENTS, UNIQUE)
- `midterm_score`: Điểm giữa kỳ (0-10)
- `final_score`: Điểm cuối kỳ (0-10)
- `total_score`: Điểm tổng kết (0-10)
  - **Công thức:** `total_score = midterm_score * 0.4 + final_score * 0.6`
- `letter_grade`: Điểm chữ (A+, A, B+, B, C+, C, D, F)
  - **Quy đổi:**
    - A+: >= 9.0
    - A: >= 8.5
    - B+: >= 8.0
    - B: >= 7.0
    - C+: >= 6.5
    - C: >= 5.5
    - D: >= 5.0
    - F: < 5.0
- `grade_status`: Trạng thái điểm (Pending, Submitted, Approved, Modified)
- `submitted_by`: Người nộp điểm (FK → LECTURERS)
- `submitted_date`: Ngày nộp điểm
- `approved_by`: Người phê duyệt (FK → LECTURERS hoặc Academic Affairs)
- `approved_date`: Ngày phê duyệt
- `modified_by`: Người sửa điểm (nếu có)
- `modified_date`: Ngày sửa điểm
- `modification_reason`: Lý do sửa điểm

**Workflow quản lý điểm:**

```
1. Pending (Mặc định)
   ↓
2. Submitted (Giảng viên nộp điểm)
   ↓
3. Approved (Phòng ĐT phê duyệt)
   ↓
4. Modified (Nếu cần sửa, chỉ Phòng ĐT)
```

**Quy tắc nghiệp vụ:**

- Giảng viên chỉ có thể nhập/sửa điểm **trước deadline**
- Sau deadline, chỉ Phòng Đào tạo (Academic Affairs) mới có thể sửa
- Mỗi enrollment chỉ có 1 grade (UNIQUE constraint)

---

### 11. GRADE_SUBMISSION_DEADLINES (Hạn nộp điểm)

**Mục đích:** Quản lý hạn nộp điểm cho từng học kỳ

**Thông tin:**

- `deadline_id`: Mã deadline (PK, auto-increment)
- `semester`: Học kỳ (ví dụ: Fall, Spring)
- `academic_year`: Năm học (ví dụ: 2021)
- `submission_deadline`: Hạn nộp điểm (DATE)
- `is_active`: Còn hiệu lực (Y/N)
- `created_by`: Người tạo

**Quy tắc:**

- Mỗi học kỳ có 1 deadline (UNIQUE constraint)
- Giảng viên chỉ có thể nhập/sửa điểm trước deadline
- Sau deadline, chỉ Phòng Đào tạo mới có thể sửa

---

### 12. SYSTEM_USERS (Người dùng hệ thống)

**Mục đích:** Quản lý tài khoản đăng nhập

**Thông tin:**

- `user_id`: Mã người dùng (PK, ví dụ: USR001)
- `username`: Tên đăng nhập (UNIQUE, NOT NULL)
- `password_hash`: Mật khẩu đã hash (BCrypt)
- `user_type`: Loại người dùng (Student, Lecturer, Academic_Affairs, Dean, Department_Head, Relative, Admin)
- `reference_id`: Tham chiếu đến bảng tương ứng (STU001, LEC001, etc.)
- `is_active`: Tài khoản còn hoạt động (Y/N)
- `last_login`: Lần đăng nhập cuối
- `failed_login_attempts`: Số lần đăng nhập sai
- `account_locked`: Tài khoản bị khóa (Y/N)
- `password_change_date`: Ngày đổi mật khẩu
- `must_change_password`: Bắt buộc đổi mật khẩu (Y/N)

**Mapping:**

- `user_type = 'Student'` → `reference_id` trỏ đến `STUDENTS.student_id`
- `user_type = 'Lecturer'` → `reference_id` trỏ đến `LECTURERS.lecturer_id`
- `user_type = 'Relative'` → `reference_id` trỏ đến `RELATIVES.relative_id`
- `user_type = 'Admin'` → `reference_id = 'GMS_ADMIN'`

---

### 13. AUDIT_LOG (Nhật ký audit)

**Mục đích:** Ghi lại mọi thao tác trên database

**Thông tin:**

- `log_id`: Mã log (PK, auto-increment)
- `table_name`: Bảng bị thao tác
- `operation`: Thao tác (INSERT, UPDATE, DELETE, SELECT)
- `user_id`: Người thực hiện
- `username`: Tên người dùng
- `record_id`: ID của record bị thao tác
- `old_values`: Giá trị cũ (CLOB)
- `new_values`: Giá trị mới (CLOB)
- `operation_date`: Thời gian thao tác
- `ip_address`: Địa chỉ IP
- `session_id`: ID session

---

## 🔄 QUY TRÌNH NGHIỆP VỤ

### 1. Quy trình Quản lý Sinh viên

```
1. Tạo Khoa (FACULTIES)
   ↓
2. Tạo Bộ môn (DEPARTMENTS) trong Khoa
   ↓
3. Tạo Lớp (CLASSES) trong Khoa
   ↓
4. Thêm Sinh viên (STUDENTS) vào Lớp
   ↓
5. Thêm Người thân (RELATIVES) và liên kết (STUDENT_RELATIVES)
   ↓
6. Tạo tài khoản (SYSTEM_USERS) cho Sinh viên
```

**Quy tắc:**

- Sinh viên phải thuộc 1 lớp
- Lớp phải thuộc 1 khoa
- Sinh viên có thể có nhiều người thân
- Mỗi sinh viên có 1 tài khoản đăng nhập

---

### 2. Quy trình Quản lý Môn học

```
1. Tạo Môn học (COURSES) trong Bộ môn
   ↓
2. Tạo Lớp học phần (COURSE_SECTIONS) cho Môn học
   - Chỉ định Giảng viên
   - Chỉ định Học kỳ, Năm học
   - Thiết lập số lượng tối đa
   ↓
3. Sinh viên đăng ký (ENROLLMENTS)
   - Kiểm tra số lượng còn trống
   - Kiểm tra môn tiên quyết (nếu có)
   ↓
4. Giảng viên nhập điểm (GRADES)
   - Trước deadline
   - Tự động tính total_score và letter_grade
```

**Quy tắc:**

- Môn học phải thuộc 1 bộ môn
- Lớp học phần phải có 1 giảng viên
- Sinh viên phải đăng ký trước khi có điểm
- Mỗi enrollment chỉ có 1 grade

---

### 3. Quy trình Quản lý Điểm

#### 3.1. Nhập điểm (Giảng viên)

```
1. Giảng viên đăng nhập
   ↓
2. Xem danh sách sinh viên trong môn mình dạy
   ↓
3. Nhập điểm giữa kỳ và cuối kỳ
   ↓
4. Hệ thống tự động tính:
   - total_score = midterm * 0.4 + final * 0.6
   - letter_grade (A+, A, B+, B, C+, C, D, F)
   ↓
5. Submit điểm (grade_status = 'Submitted')
   ↓
6. Phòng Đào tạo phê duyệt (grade_status = 'Approved')
```

**Ràng buộc:**

- ✅ Chỉ có thể nhập/sửa **trước deadline**
- ✅ Chỉ có thể nhập điểm cho sinh viên trong môn mình dạy
- ✅ Sau deadline, không thể sửa (chỉ Phòng ĐT)

#### 3.2. Phê duyệt điểm (Phòng Đào tạo)

```
1. Phòng Đào tạo đăng nhập
   ↓
2. Xem danh sách điểm đã submit
   ↓
3. Phê duyệt điểm (grade_status = 'Approved')
   ↓
4. Điểm được công bố (sinh viên có thể xem)
```

**Quyền hạn:**

- ✅ Xem tất cả điểm
- ✅ Phê duyệt điểm
- ✅ Sửa điểm sau deadline (nếu cần)
- ✅ Phải ghi lý do khi sửa (modification_reason)

#### 3.3. Xem điểm (Sinh viên)

```
1. Sinh viên đăng nhập
   ↓
2. Xem điểm của mình
   - Chỉ thấy điểm đã Approved
   - Xem điểm giữa kỳ, cuối kỳ, tổng kết
   - Xem điểm chữ
   ↓
3. Xem GPA
   - GPA học kỳ
   - GPA tích lũy
```

**Quyền hạn:**

- ✅ Xem điểm của mình
- ✅ Xem GPA
- ❌ Không thể xem điểm của sinh viên khác
- ❌ Không thể sửa điểm

---

### 4. Quy trình Tính GPA

**Công thức:**

```
GPA = Σ(total_score × credits) / Σ(credits)
```

**Ví dụ:**

- CS101: total_score = 8.5, credits = 3
- CS201: total_score = 9.0, credits = 3
- GPA = (8.5 × 3 + 9.0 × 3) / (3 + 3) = 8.75

**View:** `V_STUDENT_GPA`

- Tính GPA theo học kỳ
- Tính GPA tích lũy

---

## 🔐 PHÂN QUYỀN THEO VAI TRÒ

### 1. STUDENT (Sinh viên)

**Quyền truy cập:**

- ✅ Xem thông tin của mình (STUDENTS)
- ✅ Xem điểm của mình (GRADES)
- ✅ Xem đăng ký của mình (ENROLLMENTS)
- ✅ Cập nhật: `email`, `phone_number`, `contact_address` (chỉ trong record của mình)
- ❌ Không thể xem thông tin sinh viên khác
- ❌ Không thể xem điểm của người khác
- ❌ Không thể sửa điểm

**VPD Policy:**

- `student_id = SYS_CONTEXT('gms_context', 'user_id')`

---

### 2. LECTURER (Giảng viên)

**Quyền truy cập:**

- ✅ Xem sinh viên trong lớp mình chủ nhiệm
- ✅ Xem điểm của sinh viên trong môn mình dạy
- ✅ Nhập/sửa điểm (trước deadline)
- ✅ Cập nhật: `email`, `phone_number`, `contact_address` (chỉ trong record của mình)
- ❌ Không thể xem điểm của môn không dạy
- ❌ Không thể sửa điểm sau deadline

**VPD Policy:**

- STUDENTS: `class_id IN (SELECT class_id FROM CLASSES WHERE homeroom_teacher_id = user_id)`
- GRADES: `enrollment_id IN (SELECT e.enrollment_id FROM ENROLLMENTS e JOIN COURSE_SECTIONS cs ON e.section_id = cs.section_id WHERE cs.lecturer_id = user_id)`

**Workflow nhập điểm:**

1. Kiểm tra deadline: `submission_deadline > SYSDATE`
2. Nhập điểm: `midterm_score`, `final_score`
3. Tự động tính: `total_score`, `letter_grade`
4. Submit: `grade_status = 'Submitted'`

---

### 3. DEAN (Trưởng khoa)

**Quyền truy cập:**

- ✅ Xem tất cả sinh viên trong khoa
- ✅ Xem tất cả điểm trong khoa
- ✅ Chỉ đọc (không thể sửa)
- ❌ Không thể xem dữ liệu khoa khác

**VPD Policy:**

- STUDENTS: `class_id IN (SELECT class_id FROM CLASSES WHERE faculty_id = user_faculty_id)`
- GRADES: `enrollment_id IN (SELECT e.enrollment_id FROM ENROLLMENTS e JOIN STUDENTS s ON e.student_id = s.student_id JOIN CLASSES c ON s.class_id = c.class_id WHERE c.faculty_id = user_faculty_id)`

---

### 4. DEPARTMENT_HEAD (Trưởng bộ môn)

**Quyền truy cập:**

- ✅ Xem điểm của môn học trong bộ môn
- ✅ Chỉ đọc (không thể sửa)
- ❌ Không thể xem dữ liệu bộ môn khác

**VPD Policy:**

- GRADES: `enrollment_id IN (SELECT e.enrollment_id FROM ENROLLMENTS e JOIN COURSE_SECTIONS cs ON e.section_id = cs.section_id JOIN COURSES c ON cs.course_id = c.course_id WHERE c.department_id = user_department_id)`

---

### 5. ACADEMIC_AFFAIRS (Phòng Đào tạo)

**Quyền truy cập:**

- ✅ Xem tất cả dữ liệu (STUDENTS, GRADES, ENROLLMENTS, etc.)
- ✅ Phê duyệt điểm
- ✅ Sửa điểm sau deadline
- ✅ Quản lý deadlines
- ✅ Toàn quyền trên hệ thống

**VPD Policy:**

- Tất cả: `1=1` (xem tất cả)

---

### 6. RELATIVE (Người thân)

**Quyền truy cập:**

- ✅ Xem thông tin của mình
- ✅ Xem điểm của con/người thân
- ✅ Cập nhật: `email`, `phone_number`, `contact_address` (chỉ trong record của mình)
- ❌ Không thể xem điểm của sinh viên khác

**VPD Policy:**

- RELATIVES: `relative_id = user_id`
- GRADES: `enrollment_id IN (SELECT e.enrollment_id FROM ENROLLMENTS e JOIN STUDENT_RELATIVES sr ON e.student_id = sr.student_id WHERE sr.relative_id = user_id)`

---

### 7. ADMIN (Quản trị viên)

**Quyền truy cập:**

- ✅ Xem tất cả dữ liệu
- ✅ Toàn quyền quản trị
- ✅ Bypass VPD (không bị filter)

**VPD Policy:**

- Bypass VPD (xem tất cả)

---

## 📊 QUY TẮC NGHIỆP VỤ

### 1. Quy tắc Đăng ký Học phần

- ✅ Sinh viên phải đăng ký trước khi có điểm
- ✅ Một sinh viên chỉ có thể đăng ký 1 lần cho 1 lớp học phần
- ✅ Phải kiểm tra số lượng còn trống (`enrolled_students < max_students`)
- ✅ Phải kiểm tra môn tiên quyết (nếu có)

---

### 2. Quy tắc Nhập Điểm

- ✅ Điểm giữa kỳ và cuối kỳ: 0-10
- ✅ Điểm tổng kết: Tự động tính (midterm × 0.4 + final × 0.6)
- ✅ Điểm chữ: Tự động quy đổi từ điểm tổng kết
- ✅ Chỉ có thể nhập/sửa **trước deadline**
- ✅ Sau deadline, chỉ Phòng Đào tạo mới có thể sửa
- ✅ Mỗi enrollment chỉ có 1 grade

---

### 3. Quy tắc Workflow Điểm

```
Pending → Submitted → Approved
              ↓
          Modified (nếu cần sửa)
```

**Chi tiết:**

1. **Pending:** Mặc định khi tạo grade
2. **Submitted:** Giảng viên nộp điểm
3. **Approved:** Phòng Đào tạo phê duyệt
4. **Modified:** Nếu cần sửa sau khi approved, phải ghi lý do

---

### 4. Quy tắc Deadline

- ✅ Mỗi học kỳ có 1 deadline
- ✅ Giảng viên chỉ có thể nhập/sửa trước deadline
- ✅ Sau deadline, hệ thống tự động chặn (VPD policy)
- ✅ Chỉ Phòng Đào tạo mới có thể sửa sau deadline

---

### 5. Quy tắc Cập nhật Thông tin

**Sinh viên:**

- ✅ Có thể cập nhật: `email`, `phone_number`, `contact_address`
- ❌ Không thể cập nhật: `student_id`, `first_name`, `last_name`, `class_id`, `enrollment_date`, `student_status`

**Giảng viên:**

- ✅ Có thể cập nhật: `email`, `phone_number`, `contact_address`
- ❌ Không thể cập nhật: `lecturer_id`, `first_name`, `last_name`, `department_id`, `start_date`

**Người thân:**

- ✅ Có thể cập nhật: `email`, `phone_number`, `contact_address`
- ❌ Không thể cập nhật: `relative_id`, `first_name`, `last_name`

**Bảo mật:**

- VPD đảm bảo users chỉ update record của mình (row-level)
- Column-level GRANT đảm bảo users chỉ update cột được phép

---

## 🔍 CÁC VIEW VÀ BÁO CÁO

### 1. V_STUDENT_GRADES

**Mục đích:** Xem điểm của sinh viên với thông tin đầy đủ

**Thông tin:**

- Student ID, Name
- Course ID, Name, Credits
- Semester, Academic Year
- Midterm Score, Final Score, Total Score
- Letter Grade, Grade Status

**Sử dụng:**

- Sinh viên xem điểm của mình
- Giảng viên xem điểm của sinh viên trong môn mình dạy
- Phòng Đào tạo xem tất cả điểm

---

### 2. V_STUDENT_GPA

**Mục đích:** Tính GPA của sinh viên

**Thông tin:**

- Student ID, Name
- Semester, Academic Year
- Semester GPA (GPA theo học kỳ)
- Cumulative GPA (GPA tích lũy)

**Công thức:**

```
GPA = Σ(total_score × credits) / Σ(credits)
```

**Điều kiện:**

- Chỉ tính điểm đã Approved (`grade_status = 'Approved'`)

---

### 3. V_AUDIT_TRAIL

**Mục đích:** Xem nhật ký audit

**Thông tin:**

- Timestamp
- Database User
- Object Schema, Object Name
- SQL Text
- Policy Name
- Statement Type

**Nguồn dữ liệu:**

- FGA audit trail (`dba_fga_audit_trail`) - Audit SELECT, UPDATE, DELETE (có SQL text)
- Audit log từ triggers (`AUDIT_LOG`) - Audit INSERT (có old/new values)

**Xem chi tiết:** `FGA_VS_TRIGGER_AUDIT.md` - So sánh 2 loại audit

---

## 🔒 BẢO MẬT

### 1. VPD (Virtual Private Database) - Row-level Security

**Mục đích:** Đảm bảo users chỉ thấy data của mình

**Policies:**

- `student_access_policy`: Filter STUDENTS
- `grade_select_policy`: Filter GRADES (SELECT)
- `grade_insert_policy`: Filter GRADES (INSERT)
- `grade_update_policy`: Filter GRADES (UPDATE)
- `grade_delete_policy`: Filter GRADES (DELETE)
- `relative_access_policy`: Filter RELATIVES
- `enrollment_access_policy`: Filter ENROLLMENTS

**Bypass:**

- GMS_ADMIN: Xem tất cả
- GMS_APP: Xem tất cả (application user)

---

### 2. Column-level Security

**Mục đích:** Đảm bảo users chỉ update cột được phép

**Grants:**

- GMS_STUDENT: `UPDATE (email, phone_number, contact_address) ON STUDENTS`
- GMS_LECTURER: `UPDATE (email, phone_number, contact_address) ON LECTURERS`
- GMS_RELATIVE: `UPDATE (email, phone_number, contact_address) ON RELATIVES`

**Kết hợp với VPD:**

- Row-level: Chỉ update record của mình
- Column-level: Chỉ update cột được phép

---

### 3. FGA (Fine-Grained Auditing)

**Mục đích:** Audit chi tiết các thao tác nhạy cảm

**Policies:**

- `fga_grade_select`: Audit SELECT trên GRADES
- `fga_grade_update`: Audit UPDATE trên GRADES
- `fga_grade_delete`: Audit DELETE trên GRADES
- `fga_student_info_access`: Audit SELECT trên STUDENTS
- `fga_student_modify`: Audit UPDATE trên STUDENTS
- `fga_enrollment_modify`: Audit UPDATE trên ENROLLMENTS
- `fga_system_user_modify`: Audit UPDATE trên SYSTEM_USERS
- `fga_deadline_modify`: Audit UPDATE trên GRADE_SUBMISSION_DEADLINES

**Audit Triggers:**

- `trg_audit_grade_insert`: Log INSERT vào GRADES
- `trg_audit_student_insert`: Log INSERT vào STUDENTS

---

### 4. Password Profiles

**Mục đích:** Enforce password policies

**Profiles:**

- `GMS_STUDENT_PROFILE`: Password lifetime 90 days
- `GMS_LECTURER_PROFILE`: Password lifetime 60 days
- `GMS_ADMIN_PROFILE`: Password lifetime 30 days
- `GMS_RELATIVE_PROFILE`: Password lifetime 120 days
- `GMS_SYSADMIN_PROFILE`: Password lifetime 30 days

**Yêu cầu:**

- Minimum 8 characters
- At least 1 digit
- At least 1 uppercase letter
- At least 1 lowercase letter
- At least 1 special character
- Cannot be same as username
- Must differ from old password by at least 3 characters

---

## 📈 LUỒNG DỮ LIỆU

### 1. Luồng Đăng ký Học phần

```
STUDENT → ENROLLMENTS → COURSE_SECTIONS → COURSES
```

**Chi tiết:**

1. Sinh viên chọn môn học (COURSES)
2. Chọn lớp học phần (COURSE_SECTIONS)
3. Đăng ký (ENROLLMENTS)
4. Hệ thống cập nhật `enrolled_students`

---

### 2. Luồng Nhập Điểm

```
LECTURER → GRADES → ENROLLMENTS → STUDENTS
```

**Chi tiết:**

1. Giảng viên xem danh sách sinh viên đã đăng ký
2. Nhập điểm giữa kỳ và cuối kỳ
3. Hệ thống tự động tính total_score và letter_grade
4. Submit điểm
5. Phòng Đào tạo phê duyệt
6. Sinh viên có thể xem điểm

---

### 3. Luồng Tính GPA

```
GRADES → ENROLLMENTS → COURSE_SECTIONS → COURSES → V_STUDENT_GPA
```

**Chi tiết:**

1. Lấy điểm đã Approved
2. Join với COURSES để lấy credits
3. Tính: `Σ(total_score × credits) / Σ(credits)`
4. Hiển thị trong view V_STUDENT_GPA

---

## 🎓 VÍ DỤ NGHIỆP VỤ

### Scenario 1: Sinh viên xem điểm

```
1. Sinh viên STU001 đăng nhập
   ↓
2. Hệ thống set VPD context: user_id=STU001, user_type=Student
   ↓
3. Query GRADES
   ↓
4. VPD filter: chỉ trả về grades của STU001
   ↓
5. Hiển thị điểm cho sinh viên
```

---

### Scenario 2: Giảng viên nhập điểm

```
1. Giảng viên LEC001 đăng nhập
   ↓
2. Hệ thống set VPD context: user_id=LEC001, user_type=Lecturer
   ↓
3. Xem danh sách sinh viên trong môn mình dạy
   ↓
4. Kiểm tra deadline: submission_deadline > SYSDATE?
   ↓
5. Nhập điểm: midterm_score=8.0, final_score=9.0
   ↓
6. Hệ thống tự động tính:
   - total_score = 8.0 × 0.4 + 9.0 × 0.6 = 8.6
   - letter_grade = 'A'
   ↓
7. Submit: grade_status = 'Submitted'
   ↓
8. Phòng Đào tạo phê duyệt: grade_status = 'Approved'
```

---

### Scenario 3: Phòng Đào tạo sửa điểm sau deadline

```
1. Phòng Đào tạo đăng nhập
   ↓
2. Xem danh sách điểm
   ↓
3. Chọn điểm cần sửa (sau deadline)
   ↓
4. Sửa điểm: final_score từ 9.0 → 9.5
   ↓
5. Hệ thống tự động tính lại:
   - total_score = 8.0 × 0.4 + 9.5 × 0.6 = 8.9
   - letter_grade = 'A+'
   ↓
6. Ghi lý do: modification_reason = 'Điều chỉnh theo phúc khảo'
   ↓
7. grade_status = 'Modified'
```

---

## 📋 TÓM TẮT

### Các thực thể chính:

1. **FACULTIES** - Khoa
2. **DEPARTMENTS** - Bộ môn
3. **CLASSES** - Lớp
4. **STUDENTS** - Sinh viên
5. **LECTURERS** - Giảng viên
6. **RELATIVES** - Người thân
7. **COURSES** - Môn học
8. **COURSE_SECTIONS** - Lớp học phần
9. **ENROLLMENTS** - Đăng ký học phần
10. **GRADES** - Điểm số
11. **GRADE_SUBMISSION_DEADLINES** - Hạn nộp điểm
12. **SYSTEM_USERS** - Người dùng hệ thống
13. **AUDIT_LOG** - Nhật ký audit

### Quy trình chính:

1. **Quản lý Sinh viên:** Tạo khoa → bộ môn → lớp → sinh viên
2. **Quản lý Môn học:** Tạo môn học → lớp học phần → đăng ký
3. **Quản lý Điểm:** Nhập điểm → Submit → Phê duyệt → Công bố
4. **Tính GPA:** Tự động tính từ điểm đã approved

### Phân quyền:

- **7 vai trò:** Student, Lecturer, Dean, Department_Head, Academic_Affairs, Relative, Admin
- **VPD:** Row-level security (chỉ thấy data của mình)
- **Column-level:** Chỉ update cột được phép
- **Audit:** Ghi lại mọi thao tác

---

**Last Updated:** 2025-01-XX
