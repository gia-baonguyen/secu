# 📚 HƯỚNG DẪN SETUP OLS - HOÀN CHỈNH

## 🎯 TỔNG QUAN

**Oracle Label Security (OLS)** là tính năng bảo mật **độc lập hoàn toàn** với VPD, FGA, Password Profiles. OLS được sử dụng để bảo vệ **Ngân hàng câu hỏi thi** với phân loại bảo mật đa cấp độ.

**Tính năng:**

- ✅ Mandatory Access Control (MAC)
- ✅ Multi-level security classification
- ✅ Độc lập với các tính năng bảo mật khác
- ✅ Chỉ áp dụng cho bảng `EXAM_QUESTIONS` (bảng mới)

---

## 📋 NGHIỆP VỤ: BẢO VỆ NGÂN HÀNG CÂU HỎI THI

### Mục đích:

Quản lý và bảo vệ câu hỏi thi theo **mức độ bảo mật** và **phạm vi truy cập**:

- **Câu hỏi công khai (PUB)**: Tất cả sinh viên có thể xem
- **Câu hỏi nội bộ khoa (INT:CS/EE)**: Chỉ giảng viên và trưởng khoa của khoa đó mới thấy
- **Đáp án thi mật (CONF:CS)**: Chỉ trưởng khoa mới thấy

### Bảng dữ liệu: `EXAM_QUESTIONS`

| Cột              | Mô tả                                              |
| ---------------- | -------------------------------------------------- |
| `question_id`    | Mã câu hỏi (PK, auto-increment)                    |
| `subject_code`   | Mã môn học (ví dụ: CS101, EE201)                   |
| `question_text`  | Nội dung câu hỏi                                   |
| `correct_answer` | Đáp án đúng                                        |
| `created_by`     | Người tạo (LEC001, DEAN001, etc.)                  |
| `created_date`   | Ngày tạo                                           |
| `ols_label`      | **Nhãn bảo mật OLS** (số) - Oracle tự động quản lý |

---

## 🔐 PHÂN LOẠI BẢO MẬT

### 1. **Levels (Cấp độ bảo mật)** - Thứ bậc

| Level    | Số   | Tên          | Mô tả                              |
| -------- | ---- | ------------ | ---------------------------------- |
| **PUB**  | 1000 | PUBLIC       | Công khai - Tất cả sinh viên       |
| **INT**  | 2000 | INTERNAL     | Nội bộ - Giảng viên và trưởng khoa |
| **CONF** | 3000 | CONFIDENTIAL | Mật - Chỉ trưởng khoa              |

**Quy tắc:** Level càng cao → Bảo mật càng cao → Ít người thấy hơn

### 2. **Compartments (Khoa/Phòng ban)** - Phạm vi

| Compartment | Số  | Tên                    | Mô tả                    |
| ----------- | --- | ---------------------- | ------------------------ |
| **CS**      | 100 | COMPUTER SCIENCE       | Khoa Công nghệ Thông tin |
| **EE**      | 200 | ELECTRICAL ENGINEERING | Khoa Điện - Điện tử      |

**Quy tắc:** Mỗi khoa có dữ liệu riêng, không thể xem dữ liệu của khoa khác

### 3. **Labels (Nhãn dữ liệu)** - Kết hợp Level + Compartment

| Label       | Level | Compartment | Mô tả                    |
| ----------- | ----- | ----------- | ------------------------ |
| **PUB**     | 1000  | -           | Công khai (tất cả khoa)  |
| **INT:CS**  | 2000  | CS          | Nội bộ khoa CS           |
| **INT:EE**  | 2000  | EE          | Nội bộ khoa EE           |
| **CONF:CS** | 3000  | CS          | Mật khoa CS (đáp án thi) |

**Ví dụ:**

- Câu hỏi có label `INT:CS` → Chỉ giảng viên và trưởng khoa CS thấy
- Câu hỏi có label `INT:EE` → Giảng viên khoa CS **KHÔNG** thấy (khác khoa)
- Câu hỏi có label `CONF:CS` → Chỉ trưởng khoa CS thấy (level cao nhất)

---

## 👥 QUYỀN TRUY CẬP THEO VAI TRÒ

| User             | Max Read | Max Write | Có thể thấy                                       |
| ---------------- | -------- | --------- | ------------------------------------------------- |
| **GMS_STUDENT**  | PUB      | -         | Chỉ PUB (câu hỏi công khai)                       |
| **GMS_LECTURER** | INT:CS   | INT:CS    | PUB + INT:CS (câu hỏi công khai + nội bộ khoa CS) |
| **GMS_DEAN**     | CONF:CS  | CONF:CS   | PUB + INT:CS + CONF:CS (tất cả label của khoa CS) |
| **GMS_ADMIN**    | FULL     | FULL      | Tất cả labels (bypass OLS)                        |

---

## 🚀 HƯỚNG DẪN SETUP

### Prerequisites

1. **Oracle Database 19c+ Enterprise Edition** với OLS option
2. **Quyền SYSDBA** để configure và enable OLS
3. **OLS đã được cài đặt** (check trong `dba_registry`)

### Bước 1: Kiểm tra OLS Installation

```sql
-- Connect as SYSDBA
sqlplus sys/password@localhost:1521/ORCLPDB as sysdba

-- Check if OLS is installed
SELECT comp_id, comp_name, version, status
FROM dba_registry
WHERE comp_id = 'OLS';
```

**Kết quả mong đợi:**

```
COMP_ID  COMP_NAME              VERSION         STATUS
-------- ---------------------- --------------- --------
OLS      Oracle Label Security  19.0.0.0.0      VALID
```

**Nếu không có kết quả:**

- OLS chưa được cài đặt
- Cần cài OLS option (Oracle Enterprise Edition)

### Bước 2: Configure và Enable OLS

**Quan trọng:** OLS cần được **CONFIGURE** trước khi **ENABLE**

```sql
-- Step 1: Configure OLS (chạy một lần)
EXEC LBACSYS.CONFIGURE_OLS;

-- Step 2: Enable OLS
EXEC LBACSYS.OLS_ENFORCEMENT.ENABLE_OLS;
```

**Lỗi nếu chạy sai thứ tự:**

```
ORA-12459: Oracle Label Security not configured
```

→ Cần chạy `CONFIGURE_OLS` trước

**Lỗi nếu đã configure/enable:**

- `ORA-12459` khi configure lại → Không sao, đã configure rồi
- `ORA-12420` khi enable lại → Không sao, đã enable rồi

### Bước 3: Chạy Setup Script

**Option 1: Chạy riêng (Khuyến nghị)**

```sql
-- Connect as SYSDBA
sqlplus sys/password@localhost:1521/ORCLPDB as sysdba

-- Run OLS setup script
@database/02-security/step7_ols_setup.sql
```

**Option 2: Chạy cùng SETUP_ALL.sql**

Trong `SETUP_ALL.sql`, uncomment Step 7:

```sql
@@02-security/step7_ols_setup.sql
```

**Script sẽ tự động:**

1. ✅ Configure OLS (nếu chưa configure)
2. ✅ Enable OLS (nếu chưa enable)
3. ✅ Grant LBAC_DBA role cho GMS_ADMIN
4. ✅ Grant EXECUTE trên OLS packages
5. ✅ Tạo bảng EXAM_QUESTIONS
6. ✅ Tạo OLS policy `EXAM_SEC_POLICY`
7. ✅ Tạo levels (PUB, INT, CONF)
8. ✅ Tạo compartments (CS, EE)
9. ✅ Tạo labels (PUB, INT:CS, INT:EE, CONF:CS)
10. ✅ Apply policy lên bảng EXAM_QUESTIONS
11. ✅ Authorize users (GMS_STUDENT, GMS_LECTURER, GMS_DEAN, GMS_ADMIN)
12. ✅ Insert sample data

---

## 🔐 LBAC_DBA ROLE - GIẢI THÍCH

### LBAC_DBA là gì?

**LBAC_DBA** = **Label-Based Access Control Database Administrator**

- ✅ **Role hệ thống** của Oracle (được tạo sẵn khi cài OLS)
- ✅ **Quyền quản trị OLS** (tạo, sửa, xóa policies)
- ✅ **Không phải** role tùy chỉnh (không cần tạo)

### Tại sao cần grant LBAC_DBA cho GMS_ADMIN?

**Lý do:**

- ✅ `GMS_ADMIN` cần **quản lý OLS policies** cho schema của mình
- ✅ Không có role này → **KHÔNG thể** tạo/sửa/xóa OLS policies
- ✅ Cần để chạy các lệnh OLS như:
  - `SA_SYSDBA.CREATE_POLICY`
  - `SA_COMPONENTS.CREATE_LEVEL`
  - `SA_LABEL_ADMIN.CREATE_LABEL`
  - `SA_POLICY_ADMIN.APPLY_TABLE_POLICY`
  - `SA_USER_ADMIN.SET_USER_LABELS`

**Code trong script:**

```sql
-- Grant LBAC_DBA role to GMS_ADMIN
GRANT LBAC_DBA TO GMS_ADMIN;

-- Grant execute privileges on OLS packages
GRANT EXECUTE ON sa_sysdba TO GMS_ADMIN;
GRANT EXECUTE ON sa_components TO GMS_ADMIN;
GRANT EXECUTE ON sa_label_admin TO GMS_ADMIN;
GRANT EXECUTE ON sa_policy_admin TO GMS_ADMIN;
GRANT EXECUTE ON sa_user_admin TO GMS_ADMIN;
GRANT EXECUTE ON sa_session TO GMS_ADMIN;
```

---

## 🔄 QUY TRÌNH NGHIỆP VỤ

### 1. Tạo câu hỏi công khai (Sinh viên thấy)

```sql
INSERT INTO EXAM_QUESTIONS (
    subject_code,
    question_text,
    correct_answer,
    created_by,
    ols_label
)
VALUES (
    'CS101',
    'What is 1+1?',
    '2',
    'LEC001',
    CHAR_TO_LABEL('EXAM_SEC_POLICY', 'PUB')
);
```

**Kết quả:** ✅ Sinh viên, giảng viên, trưởng khoa đều thấy

### 2. Tạo câu hỏi nội bộ khoa (Chỉ GV và Trưởng khoa thấy)

```sql
INSERT INTO EXAM_QUESTIONS (
    subject_code,
    question_text,
    correct_answer,
    created_by,
    ols_label
)
VALUES (
    'CS102',
    'Explain QuickSort algorithm?',
    'O(nlogn)',
    'LEC001',
    CHAR_TO_LABEL('EXAM_SEC_POLICY', 'INT:CS')
);
```

**Kết quả:**

- ❌ Sinh viên **KHÔNG** thấy
- ✅ Giảng viên khoa CS thấy
- ✅ Trưởng khoa CS thấy
- ❌ Giảng viên khoa EE **KHÔNG** thấy (khác khoa)

### 3. Tạo đáp án thi mật (Chỉ Trưởng khoa thấy)

```sql
INSERT INTO EXAM_QUESTIONS (
    subject_code,
    question_text,
    correct_answer,
    created_by,
    ols_label
)
VALUES (
    'CS101',
    'FINAL EXAM ANSWER KEY 2025',
    'Option A, C, D...',
    'DEAN001',
    CHAR_TO_LABEL('EXAM_SEC_POLICY', 'CONF:CS')
);
```

**Kết quả:**

- ❌ Sinh viên **KHÔNG** thấy
- ❌ Giảng viên **KHÔNG** thấy (level quá cao)
- ✅ Chỉ Trưởng khoa CS thấy

---

## 🔍 CƠ CHẾ HOẠT ĐỘNG

### 1. OLS tự động filter dữ liệu

Khi user query `EXAM_QUESTIONS`, Oracle tự động:

1. Lấy label của user (từ authorization)
2. So sánh với label của từng row
3. Chỉ trả về rows mà user có quyền đọc

**Ví dụ:**

```sql
-- User: GMS_LECTURER (max_read_label = INT:CS)
SELECT * FROM EXAM_QUESTIONS;

-- Oracle tự động filter:
-- ✅ PUB (1000) ≤ INT:CS (2100) → Thấy
-- ✅ INT:CS (2100) ≤ INT:CS (2100) → Thấy
-- ❌ INT:EE (2200) - Khác compartment → KHÔNG thấy
-- ❌ CONF:CS (3100) > INT:CS (2100) → KHÔNG thấy
```

### 2. LABEL_DEFAULT đảm bảo mọi row đều có label

**Trong script:**

```sql
SA_POLICY_ADMIN.APPLY_TABLE_POLICY (
    policy_name    => 'EXAM_SEC_POLICY',
    schema_name    => 'GMS_ADMIN',
    table_name     => 'EXAM_QUESTIONS',
    table_options  => 'READ_CONTROL, WRITE_CONTROL, LABEL_DEFAULT'  -- ← Quan trọng
);
```

**`LABEL_DEFAULT`** có nghĩa:

- ✅ Khi INSERT mà không chỉ định label → Oracle tự động gán label mặc định
- ✅ Label mặc định = `def_label` của user (từ authorization)
- ✅ Đảm bảo **KHÔNG có row nào có label NULL**

**Ví dụ:**

```sql
-- User: GMS_LECTURER (def_label = INT:CS)
INSERT INTO EXAM_QUESTIONS (subject_code, question_text, correct_answer, created_by)
VALUES ('CS101', 'Question?', 'Answer', 'LEC001');
-- Không chỉ định ols_label

-- Kết quả:
-- ✅ Oracle tự động gán: ols_label = INT:CS (từ def_label của user)
-- ✅ Row KHÔNG có label NULL
```

### 3. Hành vi khi bảng không có nhãn dữ liệu

**Trường hợp 1: Bảng KHÔNG có OLS Policy**

- ✅ User đọc được (OLS không áp dụng)
- ✅ Quyền truy cập theo VPD/GRANT
- ✅ Ví dụ: Bảng `STUDENTS`, `GRADES` (không có OLS)

**Trường hợp 2: Bảng CÓ OLS Policy nhưng row không có label (NULL)**

- ❌ User **KHÔNG đọc được** (OLS filter rows NULL)
- ✅ Chỉ rows có label hợp lệ mới được trả về
- ⚠️ **Không nên** để row có label NULL (dùng LABEL_DEFAULT để tránh)

---

## 🧪 TESTING OLS

### Test 1: Student Access (PUB only)

```sql
-- Connect as GMS_STUDENT
sqlplus GMS_STUDENT/Student@2024@//localhost:1521/ORCLPDB

-- Query exam questions
SELECT question_id, subject_code,
       SUBSTR(question_text, 1, 50) as question,
       LABEL_TO_CHAR(ols_label) as security_label
FROM gms_admin.EXAM_QUESTIONS;

-- Expected: Only rows with label "PUB"
```

### Test 2: Lecturer Access (PUB + INT:CS)

```sql
-- Connect as GMS_LECTURER
sqlplus GMS_LECTURER/Lecturer@2024@//localhost:1521/ORCLPDB

-- Query exam questions
SELECT question_id, subject_code,
       SUBSTR(question_text, 1, 50) as question,
       LABEL_TO_CHAR(ols_label) as security_label
FROM gms_admin.EXAM_QUESTIONS;

-- Expected: Rows with labels PUB + INT:CS
-- Should NOT see INT:EE or CONF:CS
```

### Test 3: Dean Access (All CS labels)

```sql
-- Connect as GMS_DEAN
sqlplus GMS_DEAN/Dean@2024@//localhost:1521/ORCLPDB

-- Query exam questions
SELECT question_id, subject_code,
       SUBSTR(question_text, 1, 50) as question,
       LABEL_TO_CHAR(ols_label) as security_label
FROM gms_admin.EXAM_QUESTIONS;

-- Expected: Rows with labels PUB, INT:CS, CONF:CS
-- Should NOT see INT:EE (different department)
```

### Test 4: Admin Access (All labels - bypass OLS)

```sql
-- Connect as GMS_ADMIN
sqlplus GMS_ADMIN/Admin@2024@//localhost:1521/ORCLPDB

-- Query exam questions
SELECT question_id, subject_code,
       SUBSTR(question_text, 1, 50) as question,
       LABEL_TO_CHAR(ols_label) as security_label
FROM gms_admin.EXAM_QUESTIONS;

-- Expected: All rows (bypass OLS)
```

---

## 📊 VERIFICATION QUERIES

### Check OLS Policy Status

```sql
SELECT policy_name, status
FROM dba_sa_policies
WHERE policy_name = 'EXAM_SEC_POLICY';
```

### Check Security Levels

```sql
SELECT level_num, short_name, long_name
FROM dba_sa_levels
WHERE policy_name = 'EXAM_SEC_POLICY'
ORDER BY level_num;
```

### Check Compartments

```sql
SELECT comp_num, short_name, long_name
FROM dba_sa_compartments
WHERE policy_name = 'EXAM_SEC_POLICY'
ORDER BY comp_num;
```

### Check Data Labels

```sql
SELECT label_tag, label
FROM dba_sa_labels
WHERE policy_name = 'EXAM_SEC_POLICY'
ORDER BY label_tag;
```

### Check User Authorizations

```sql
SELECT user_name, max_read_label, max_write_label
FROM dba_sa_user_levels
WHERE policy_name = 'EXAM_SEC_POLICY'
ORDER BY user_name;
```

### Check Sample Data

```sql
-- As GMS_ADMIN (should see all)
SELECT question_id, subject_code,
       SUBSTR(question_text, 1, 30) as question_preview,
       LABEL_TO_CHAR(ols_label) as security_label
FROM gms_admin.EXAM_QUESTIONS
ORDER BY question_id;
```

---

## 🚨 TROUBLESHOOTING

### Error: OLS not configured

```
ORA-12459: Oracle Label Security not configured
```

**Solution:**

```sql
-- Run as SYSDBA
EXEC LBACSYS.CONFIGURE_OLS;
EXEC LBACSYS.OLS_ENFORCEMENT.ENABLE_OLS;
```

**Lưu ý:** Phải CONFIGURE trước, ENABLE sau

### Error: OLS not enabled

```
ORA-12458: Oracle Label Security not enabled
```

**Solution:**

```sql
-- Run as SYSDBA
EXEC LBACSYS.OLS_ENFORCEMENT.ENABLE_OLS;
```

**Lưu ý:** Phải CONFIGURE trước

### Error: Policy already exists

```
ORA-12410: Policy already exists
```

**Solution:** Script tự động drop policy cũ. Nếu vẫn lỗi, drop thủ công:

```sql
BEGIN
    SA_SYSDBA.DROP_POLICY(policy_name => 'EXAM_SEC_POLICY', drop_column => TRUE);
END;
/
```

### Error: Insufficient privileges

```
ORA-12430: Insufficient privileges
```

**Solution:** Đảm bảo GMS_ADMIN có LBAC_DBA role:

```sql
GRANT LBAC_DBA TO GMS_ADMIN;
```

### Error: PROMPT trong PL/SQL Block

```
PLS-00103: Encountered the symbol "EXISTING" when expecting one of the following
```

**Solution:** Script đã được sửa, dùng `DBMS_OUTPUT.PUT_LINE()` thay vì `PROMPT` trong PL/SQL

### Error: Bind variable

```
SP2-0552: Bind variable "EE" not declared
```

**Solution:** Script đã được sửa, dùng `DBMS_OUTPUT.PUT_LINE()` thay vì `PROMPT` trong PL/SQL

### Users cannot see any data

**Check user authorization:**

```sql
SELECT user_name, max_read_label
FROM dba_sa_user_levels
WHERE policy_name = 'EXAM_SEC_POLICY'
AND user_name = 'GMS_STUDENT';
```

**Verify data labels:**

```sql
SELECT question_id, LABEL_TO_CHAR(ols_label) as label
FROM gms_admin.EXAM_QUESTIONS;
```

---

## 🆚 SO SÁNH OLS VỚI CÁC TÍNH NĂNG KHÁC

### OLS vs VPD

| Tiêu chí         | **OLS**                        | **VPD**                              |
| ---------------- | ------------------------------ | ------------------------------------ |
| **Loại**         | Mandatory Access Control (MAC) | Discretionary Access Control (DAC)   |
| **Cơ chế**       | Label-based (nhãn)             | Policy function (hàm)                |
| **Phạm vi**      | Chỉ bảng `EXAM_QUESTIONS`      | Tất cả bảng (STUDENTS, GRADES, etc.) |
| **Độ linh hoạt** | Cấu trúc (levels/compartments) | Rất linh hoạt (custom predicates)    |
| **Performance**  | Nhanh hơn (so sánh label)      | Chậm hơn (gọi function)              |
| **Phụ thuộc**    | **Độc lập hoàn toàn**          | Phụ thuộc VPD context                |

### OLS vs FGA

| Tiêu chí      | **OLS**                             | **FGA**                             |
| ------------- | ----------------------------------- | ----------------------------------- |
| **Mục đích**  | Kiểm soát truy cập (access control) | Audit (ghi log)                     |
| **Cơ chế**    | Filter dữ liệu tự động              | Ghi log khi truy cập                |
| **Phạm vi**   | Chỉ bảng `EXAM_QUESTIONS`           | Nhiều bảng (STUDENTS, GRADES, etc.) |
| **Phụ thuộc** | **Độc lập hoàn toàn**               | Độc lập với OLS                     |

### OLS vs Password Profiles

| Tiêu chí      | **OLS**                    | **Password Profiles** |
| ------------- | -------------------------- | --------------------- |
| **Mục đích**  | Kiểm soát truy cập dữ liệu | Quản lý mật khẩu user |
| **Phạm vi**   | Dữ liệu (rows)             | User accounts         |
| **Phụ thuộc** | **Độc lập hoàn toàn**      | Độc lập với OLS       |

---

## ✅ XÁC NHẬN: OLS ĐỘC LẬP HOÀN TOÀN

### 1. OLS không phụ thuộc VPD

- ✅ OLS hoạt động **độc lập** với VPD
- ✅ OLS không cần VPD context
- ✅ OLS không sử dụng `gms_security_pkg`
- ✅ OLS không sử dụng `SYS_CONTEXT('gms_context', ...)`

**Chứng minh:**

- VPD áp dụng cho: `STUDENTS`, `GRADES`, `ENROLLMENTS`, etc.
- OLS chỉ áp dụng cho: `EXAM_QUESTIONS` (bảng mới, không có VPD)

### 2. OLS không phụ thuộc FGA

- ✅ OLS hoạt động **độc lập** với FGA
- ✅ OLS không cần FGA policies
- ✅ FGA có thể audit `EXAM_QUESTIONS` nhưng không ảnh hưởng OLS

### 3. OLS không phụ thuộc Password Profiles

- ✅ OLS hoạt động **độc lập** với Password Profiles
- ✅ Password Profiles quản lý user accounts
- ✅ OLS quản lý data access

### 4. OLS có thể chạy riêng

- ✅ Có thể chạy `step7_ols_setup.sql` **mà không cần** chạy các step trước
- ✅ Có thể bỏ qua OLS (không chạy step7) mà hệ thống vẫn hoạt động bình thường
- ✅ OLS là **tùy chọn** (optional feature)

---

## 📝 TÓM TẮT

### Mục đích:

Bảo vệ **Ngân hàng câu hỏi thi** với phân loại bảo mật đa cấp độ theo:

- **Level**: PUB → INT → CONF (cấp độ bảo mật)
- **Compartment**: CS, EE (phạm vi khoa)

### Quyền truy cập:

- **Sinh viên**: Chỉ thấy câu hỏi công khai (PUB)
- **Giảng viên**: Thấy câu hỏi công khai + nội bộ khoa mình (PUB + INT:CS)
- **Trưởng khoa**: Thấy tất cả câu hỏi của khoa mình, kể cả đáp án mật (PUB + INT:CS + CONF:CS)
- **Admin**: Thấy tất cả (bypass OLS)

### Tính độc lập:

- ✅ **Hoàn toàn độc lập** với VPD, FGA, Password Profiles
- ✅ Chỉ áp dụng cho bảng `EXAM_QUESTIONS` (bảng mới)
- ✅ Không ảnh hưởng đến hệ thống hiện tại
- ✅ Có thể bật/tắt mà không ảnh hưởng các tính năng khác

---

## 🔗 FILES LIÊN QUAN

- **Setup script**: `02-security/step7_ols_setup.sql`
- **Main setup**: `SETUP_ALL.sql` (Step 7 - optional)
- **Test scripts**: `04-tests/` (có thể thêm OLS tests)

---

## 🎯 KẾT LUẬN

**OLS là một tính năng bảo mật bổ sung, độc lập hoàn toàn với các tính năng bảo mật khác (VPD, FGA, Password Profiles). OLS được sử dụng để bảo vệ Ngân hàng câu hỏi thi với phân loại bảo mật đa cấp độ, không ảnh hưởng đến hệ thống quản lý điểm hiện tại.**

