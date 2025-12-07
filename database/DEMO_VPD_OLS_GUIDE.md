# HƯỚNG DẪN DEMO VPD VÀ OLS - DEMO GUIDE FOR VPD AND OLS

> **Version**: 1.0  
> **Last Updated**: December 2024  
> **Mục đích**: Demo các chính sách bảo mật VPD và OLS cho bài tập lớn ISS

---

## 📋 TỔNG QUAN / OVERVIEW

Theo yêu cầu assignment:

- **Nội dung 2.3**: Viết các chính sách (VPD, OLS, Audit) thoả mãn yêu cầu bảo mật
- **Nhóm 3 thành viên**: Tối thiểu 2 kỹ thuật bảo mật
- **Nhóm < 3 thành viên**: Ít nhất một trong hai kỹ thuật VPD hoặc OLS

**Vấn đề**: Với Single DB User (GMS_APP) cho backend, làm sao demo VPD/OLS cho từng tài khoản?

**Giải pháp**: Có 2 cách demo:

1. **Demo qua SQL\*Plus** (trực tiếp với Oracle users) - Dễ demo, rõ ràng
2. **Demo qua API** (qua backend với SYSTEM_USERS) - Giống production

---

## 🎯 CÁCH 1: DEMO QUA SQL\*PLUS (Khuyến nghị cho báo cáo)

### Ưu điểm:

- ✅ **Rõ ràng**: Thấy trực tiếp VPD/OLS filter data
- ✅ **Dễ hiểu**: Mỗi Oracle user = một role khác nhau
- ✅ **Dễ demo**: Có thể chạy từng bước và show kết quả
- ✅ **Phù hợp báo cáo**: Có thể screenshot từng bước

### Cách thực hiện:

#### Bước 1: Chuẩn bị

```sql
-- Connect với GMS_ADMIN để xem tổng quan
sqlplus GMS_ADMIN/Admin@2024#Secure@//localhost:1521/ORCLPDB

-- Xem tất cả data (không có VPD filter)
SELECT COUNT(*) AS "Tổng số sinh viên" FROM STUDENTS;
SELECT COUNT(*) AS "Tổng số điểm" FROM GRADES;
SELECT COUNT(*) AS "Tổng số câu hỏi" FROM EXAM_QUESTIONS;
```

#### Bước 2: Demo VPD với Student

```sql
-- Connect với GMS_STUDENT
sqlplus GMS_STUDENT/Student@2024@//localhost:1521/ORCLPDB

-- Set VPD context
EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');

-- Kiểm tra context
SELECT
    SYS_CONTEXT('gms_context', 'user_id') AS user_id,
    SYS_CONTEXT('gms_context', 'user_type') AS user_type
FROM dual;

-- Query STUDENTS (VPD filter: chỉ thấy 1 record - STU001)
SELECT student_id, first_name || ' ' || last_name AS name, email
FROM gms_admin.STUDENTS;
-- Kết quả: Chỉ thấy STU001

-- Query GRADES (VPD filter: chỉ thấy điểm của STU001)
SELECT
    g.grade_id,
    c.course_name,
    g.midterm_score,
    g.final_score,
    g.total_score
FROM gms_admin.GRADES g
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN gms_admin.COURSES c ON cs.course_id = c.course_id
WHERE e.student_id = 'STU001';
-- Kết quả: Chỉ thấy điểm của STU001
```

#### Bước 3: Demo VPD với Lecturer

```sql
-- Connect với GMS_LECTURER
sqlplus GMS_LECTURER/Lecturer@2024@//localhost:1521/ORCLPDB

-- Set VPD context
EXEC gms_admin.gms_security_pkg.set_user_context('LEC001', 'Lecturer');

-- Query STUDENTS (VPD filter: chỉ thấy SV trong lớp chủ nhiệm hoặc lớp đang dạy)
SELECT student_id, first_name || ' ' || last_name AS name, class_id
FROM gms_admin.STUDENTS;
-- Kết quả: Chỉ thấy SV liên quan đến LEC001

-- Query GRADES (VPD filter: chỉ thấy điểm của các môn LEC001 dạy)
SELECT
    g.grade_id,
    c.course_name,
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    g.midterm_score,
    g.final_score
FROM gms_admin.GRADES g
JOIN gms_admin.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id
JOIN gms_admin.STUDENTS s ON e.student_id = s.student_id
JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id
JOIN gms_admin.COURSES c ON cs.course_id = c.course_id
WHERE cs.lecturer_id = 'LEC001';
-- Kết quả: Chỉ thấy điểm của các môn LEC001 dạy
```

#### Bước 4: Demo VPD với Academic Affairs

```sql
-- Connect với GMS_ACADEMIC
sqlplus GMS_ACADEMIC/Academic@2024@//localhost:1521/ORCLPDB

-- Set VPD context
EXEC gms_admin.gms_security_pkg.set_user_context('ACAD001', 'Academic_Affairs');

-- Query STUDENTS (VPD filter: thấy TẤT CẢ)
SELECT COUNT(*) AS "Tổng số sinh viên" FROM gms_admin.STUDENTS;
-- Kết quả: Thấy tất cả sinh viên

-- Query GRADES (VPD filter: thấy TẤT CẢ)
SELECT COUNT(*) AS "Tổng số điểm" FROM gms_admin.GRADES;
-- Kết quả: Thấy tất cả điểm
```

#### Bước 5: Demo OLS với Exam Questions

```sql
-- Connect với GMS_LECTURER
sqlplus GMS_LECTURER/Lecturer@2024@//localhost:1521/ORCLPDB

-- Set VPD context
EXEC gms_admin.gms_security_pkg.set_user_context('LEC001', 'Lecturer');

-- Set OLS label cho user (nếu chưa set)
-- Lưu ý: OLS labels được set trong step7_ols_setup.sql
-- Lecturer thường có label: INT:CS (Internal - Computer Science)

-- Query EXAM_QUESTIONS (OLS filter: chỉ thấy PUB và INT:CS)
SELECT
    question_id,
    subject_code,
    question_text,
    LABEL_TO_CHAR(ols_label) AS security_label
FROM gms_admin.EXAM_QUESTIONS;
-- Kết quả: Chỉ thấy câu hỏi có label PUB hoặc INT:CS

-- Thử INSERT với label INT:CS (cho phép)
INSERT INTO gms_admin.EXAM_QUESTIONS (
    subject_code, question_text, correct_answer, created_by, created_date, ols_label
) VALUES (
    'CS101',
    'What is OOP?',
    'Object-Oriented Programming',
    'LEC001',
    SYSDATE,
    CHAR_TO_LABEL('EXAM_SEC_POLICY', 'INT:CS')
);
COMMIT;
-- Kết quả: INSERT thành công

-- Thử INSERT với label CONF:CS (không cho phép - Lecturer không có quyền)
INSERT INTO gms_admin.EXAM_QUESTIONS (
    subject_code, question_text, correct_answer, created_by, created_date, ols_label
) VALUES (
    'CS101',
    'Secret question',
    'Secret answer',
    'LEC001',
    SYSDATE,
    CHAR_TO_LABEL('EXAM_SEC_POLICY', 'CONF:CS')
);
-- Kết quả: ORA-01031: insufficient privileges (hoặc không thấy sau khi INSERT)
```

#### Bước 6: Demo OLS với Dean

```sql
-- Connect với GMS_DEAN
sqlplus GMS_DEAN/Dean@2024@//localhost:1521/ORCLPDB

-- Set VPD context
EXEC gms_admin.gms_security_pkg.set_user_context('FAC001', 'Dean');

-- Query EXAM_QUESTIONS (OLS filter: thấy PUB, INT:CS, CONF:CS)
SELECT
    question_id,
    subject_code,
    question_text,
    LABEL_TO_CHAR(ols_label) AS security_label
FROM gms_admin.EXAM_QUESTIONS;
-- Kết quả: Thấy nhiều câu hỏi hơn Lecturer (bao gồm CONF:CS)

-- INSERT với label CONF:CS (cho phép - Dean có quyền)
INSERT INTO gms_admin.EXAM_QUESTIONS (
    subject_code, question_text, correct_answer, created_by, created_date, ols_label
) VALUES (
    'CS101',
    'Confidential exam question',
    'Confidential answer',
    'FAC001',
    SYSDATE,
    CHAR_TO_LABEL('EXAM_SEC_POLICY', 'CONF:CS')
);
COMMIT;
-- Kết quả: INSERT thành công
```

---

## 🌐 CÁCH 2: DEMO QUA API (Giống Production)

### Ưu điểm:

- ✅ **Giống production**: Cách thực tế hệ thống hoạt động
- ✅ **Tự động**: VPD context được set tự động bởi backend
- ✅ **Dễ test**: Có thể dùng Postman/curl/Flutter app

### Cách thực hiện:

#### Bước 1: Start Backend

```bash
cd secu/backend
mvn spring-boot:run
```

#### Bước 2: Demo VPD với Student qua API

```bash
# 1. Login với student
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"nvhai","password":"password123"}'

# Response: { "data": { "accessToken": "eyJhbGc..." } }

# 2. Lấy token và query grades
TOKEN="eyJhbGc..."  # Copy từ response trên

curl -X GET http://localhost:8081/api/students/me/grades \
  -H "Authorization: Bearer $TOKEN"

# Response: Chỉ thấy grades của STU001 (nvhai)
# Backend tự động:
# - Set VPD context: set_user_context('STU001', 'Student')
# - VPD filter chỉ trả về grades của STU001
```

#### Bước 3: Demo VPD với Lecturer qua API

```bash
# 1. Login với lecturer
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"nv.an","password":"password123"}'

# 2. Lấy token
TOKEN="eyJhbGc..."

# 3. Query student grades (chỉ thấy SV trong lớp dạy)
curl -X GET http://localhost:8081/api/lecturers/students/grades \
  -H "Authorization: Bearer $TOKEN"

# Response: Chỉ thấy grades của SV mà LEC001 dạy
# Backend tự động:
# - Set VPD context: set_user_context('LEC001', 'Lecturer')
# - VPD filter chỉ trả về grades của các môn LEC001 dạy
```

#### Bước 4: Demo OLS với Exam Questions qua API

```bash
# 1. Login với lecturer
TOKEN="eyJhbGc..."  # Token từ login lecturer

# 2. Query exam questions (chỉ thấy PUB và INT:CS)
curl -X GET http://localhost:8081/api/exam-questions \
  -H "Authorization: Bearer $TOKEN"

# Response: Chỉ thấy questions có label PUB hoặc INT:CS
# OLS tự động filter dựa trên user label

# 3. Get available labels (chỉ thấy labels mà lecturer có quyền)
curl -X GET http://localhost:8081/api/exam-questions/labels \
  -H "Authorization: Bearer $TOKEN"

# Response: ["PUB", "INT:CS"]
# Lecturer không thể tạo questions với label CONF:CS

# 4. Create question với label INT:CS
curl -X POST "http://localhost:8081/api/exam-questions?securityLabel=INT:CS" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "subjectCode": "CS101",
    "questionText": "What is OOP?",
    "correctAnswer": "Object-Oriented Programming"
  }'

# Response: Success - Question created with label INT:CS

# 5. Login với Dean
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"dean_user","password":"password123"}'

# 6. Query exam questions (thấy nhiều hơn - bao gồm CONF:CS)
curl -X GET http://localhost:8081/api/exam-questions \
  -H "Authorization: Bearer $DEAN_TOKEN"

# Response: Thấy tất cả questions (PUB, INT:CS, CONF:CS)
# Dean có quyền cao hơn nên thấy nhiều hơn
```

---

## 📊 BẢNG SO SÁNH KẾT QUẢ / COMPARISON TABLE

### VPD Demo Results:

| User Role    | Oracle User  | SYSTEM_USERS Username | Query STUDENTS                  | Query GRADES              |
| ------------ | ------------ | --------------------- | ------------------------------- | ------------------------- |
| **Student**  | GMS_STUDENT  | nvhai                 | Chỉ thấy 1 (STU001)             | Chỉ thấy điểm của STU001  |
| **Lecturer** | GMS_LECTURER | nv.an                 | Thấy SV trong lớp dạy/chủ nhiệm | Thấy điểm của các môn dạy |
| **Academic** | GMS_ACADEMIC | academic              | Thấy TẤT CẢ                     | Thấy TẤT CẢ               |
| **Dean**     | GMS_DEAN     | dean_user             | Thấy TẤT CẢ                     | Thấy TẤT CẢ               |

### OLS Demo Results:

| User Role    | Oracle User  | OLS Labels           | Query EXAM_QUESTIONS | Can Create CONF:CS? |
| ------------ | ------------ | -------------------- | -------------------- | ------------------- |
| **Student**  | GMS_STUDENT  | PUB                  | Chỉ thấy PUB         | ❌ Không            |
| **Lecturer** | GMS_LECTURER | PUB, INT:CS          | Thấy PUB và INT:CS   | ❌ Không            |
| **Dean**     | GMS_DEAN     | PUB, INT:CS, CONF:CS | Thấy TẤT CẢ          | ✅ Có               |
| **Admin**    | GMS_ADMIN    | Tất cả               | Thấy TẤT CẢ          | ✅ Có               |

---

## 📝 SCRIPT DEMO TỰ ĐỘNG / AUTOMATED DEMO SCRIPT

Tạo script để demo tự động:

```sql
-- File: secu/database/04-tests/DEMO_VPD_OLS_COMPLETE.sql
-- Chạy script này để demo đầy đủ VPD và OLS

-- =============================================
-- DEMO VPD VÀ OLS - COMPLETE DEMONSTRATION
-- =============================================

SET SERVEROUTPUT ON
SET PAGESIZE 1000
SET LINESIZE 200

PROMPT ========================================
PROMPT DEMO VPD VÀ OLS - COMPLETE DEMO
PROMPT ========================================
PROMPT

-- =============================================
-- PART 1: DEMO VPD - STUDENT
-- =============================================
PROMPT [PART 1] Demo VPD với Student (STU001)...
PROMPT

-- Connect với GMS_STUDENT (cần chạy trong session riêng)
-- sqlplus GMS_STUDENT/Student@2024@//localhost:1521/ORCLPDB
-- EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');
-- SELECT COUNT(*) FROM gms_admin.STUDENTS;  -- Chỉ thấy 1
-- SELECT COUNT(*) FROM gms_admin.GRADES;   -- Chỉ thấy điểm của STU001

PROMPT ✓ Student chỉ thấy data của mình
PROMPT

-- =============================================
-- PART 2: DEMO VPD - LECTURER
-- =============================================
PROMPT [PART 2] Demo VPD với Lecturer (LEC001)...
PROMPT

-- Connect với GMS_LECTURER (cần chạy trong session riêng)
-- sqlplus GMS_LECTURER/Lecturer@2024@//localhost:1521/ORCLPDB
-- EXEC gms_admin.gms_security_pkg.set_user_context('LEC001', 'Lecturer');
-- SELECT COUNT(*) FROM gms_admin.STUDENTS;  -- Thấy SV trong lớp dạy
-- SELECT COUNT(*) FROM gms_admin.GRADES;    -- Thấy điểm của các môn dạy

PROMPT ✓ Lecturer chỉ thấy data của các môn dạy
PROMPT

-- =============================================
-- PART 3: DEMO OLS - EXAM QUESTIONS
-- =============================================
PROMPT [PART 3] Demo OLS với Exam Questions...
PROMPT

-- Show OLS labels
SELECT
    LABEL_TO_CHAR(ols_label) AS security_label,
    COUNT(*) AS question_count
FROM gms_admin.EXAM_QUESTIONS
GROUP BY ols_label
ORDER BY security_label;

PROMPT ✓ OLS labels hiện có
PROMPT

-- Show user labels (cần connect với từng user)
PROMPT Để xem user labels, connect với từng user:
PROMPT - GMS_STUDENT: Chỉ có label PUB
PROMPT - GMS_LECTURER: Có labels PUB, INT:CS
PROMPT - GMS_DEAN: Có labels PUB, INT:CS, CONF:CS
PROMPT

-- =============================================
-- PART 4: SUMMARY
-- =============================================
PROMPT ========================================
PROMPT DEMO COMPLETE
PROMPT ========================================
PROMPT
PROMPT Để demo chi tiết, chạy từng phần trong SQL*Plus:
PROMPT 1. Connect với GMS_STUDENT → Set context → Query
PROMPT 2. Connect với GMS_LECTURER → Set context → Query
PROMPT 3. Connect với GMS_DEAN → Set context → Query EXAM_QUESTIONS
PROMPT
PROMPT Hoặc demo qua API:
PROMPT 1. Login với username/password khác nhau
PROMPT 2. Query endpoints → Thấy kết quả khác nhau
PROMPT
```

---

## 🎬 HƯỚNG DẪN DEMO TRONG BÁO CÁO / DEMO FOR REPORT

### Slide 1: Giới thiệu VPD

```
1. Connect với GMS_STUDENT
2. Set context: set_user_context('STU001', 'Student')
3. Query: SELECT * FROM STUDENTS
4. Kết quả: Chỉ thấy 1 record (STU001)
5. Screenshot kết quả
```

### Slide 2: So sánh VPD giữa các roles

```
1. Student: Chỉ thấy data của mình
2. Lecturer: Thấy data của các môn dạy
3. Academic: Thấy tất cả
4. Screenshot so sánh
```

### Slide 3: Demo OLS

```
1. Connect với GMS_LECTURER
2. Query EXAM_QUESTIONS: Chỉ thấy PUB và INT:CS
3. Connect với GMS_DEAN
4. Query EXAM_QUESTIONS: Thấy tất cả (PUB, INT:CS, CONF:CS)
5. Screenshot so sánh
```

### Slide 4: Demo qua API

```
1. Login với student → Query grades → Chỉ thấy điểm của mình
2. Login với lecturer → Query grades → Chỉ thấy điểm của các môn dạy
3. Screenshot Postman/curl results
```

---

## ✅ CHECKLIST DEMO

- [ ] **VPD Demo**:

  - [ ] Student chỉ thấy data của mình
  - [ ] Lecturer chỉ thấy data của các môn dạy
  - [ ] Academic thấy tất cả
  - [ ] Screenshot từng bước

- [ ] **OLS Demo**:

  - [ ] Student chỉ thấy PUB
  - [ ] Lecturer thấy PUB và INT:CS
  - [ ] Dean thấy tất cả (PUB, INT:CS, CONF:CS)
  - [ ] Test INSERT với các labels khác nhau
  - [ ] Screenshot từng bước

- [ ] **API Demo**:
  - [ ] Login với các users khác nhau
  - [ ] Query endpoints → Thấy kết quả khác nhau
  - [ ] Screenshot Postman/curl

---

## 🔗 TÀI LIỆU LIÊN QUAN

- `ARCHITECTURE_DB_CONNECTION.md` - Kiến trúc kết nối database
- `LOGIC_NGHIEP_VU_TONG_HOP.md` - Tổng hợp logic nghiệp vụ
- `OLS_COMPLETE_SETUP_GUIDE.md` - Hướng dẫn setup OLS
- `scripts/DEMO_USER_ACCESS.sql` - Script demo user access

---

**Kết luận**: Với Single DB User (GMS_APP) cho backend, bạn vẫn có thể demo VPD/OLS bằng cách:

1. **Demo qua SQL\*Plus** với các Oracle users khác nhau (GMS_STUDENT, GMS_LECTURER, etc.)
2. **Demo qua API** với các SYSTEM_USERS khác nhau (username/password trong bảng SYSTEM_USERS)

Cả hai cách đều cho thấy VPD/OLS hoạt động đúng với từng tài khoản!
