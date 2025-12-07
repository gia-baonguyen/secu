# 🔍 VPD HOẠT ĐỘNG NHƯ THẾ NÀO?

## ❓ Câu hỏi

> "Có trigger tự động khi SELECT không? Nếu query SQL bình thường mà không set context thì sao?"

---

## 🎯 CÂU TRẢ LỜI NGẮN GỌN

**VPD KHÔNG phải là trigger!** VPD là **policy function** được Oracle gọi tự động khi query.

**Nếu không set context:**

- ❌ VPD policy sẽ trả về `1=0` (không thấy gì)
- ❌ User không thể xem bất kỳ dữ liệu nào
- ❌ Đây là lý do tại sao backend PHẢI set context trước mỗi request

---

## 🔧 CƠ CHẾ VPD HOẠT ĐỘNG

### 1. VPD KHÔNG phải Trigger

**VPD = Virtual Private Database = Policy Function**

```sql
-- VPD Policy được tạo bằng DBMS_RLS.ADD_POLICY
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema => 'GMS_ADMIN',
        object_name => 'STUDENTS',
        policy_name => 'STUDENT_ACCESS_POLICY',
        function_schema => 'GMS_ADMIN',
        policy_function => 'gms_security_pkg.student_policy',  -- ← Policy function
        statement_types => 'SELECT, UPDATE, DELETE',
        enable => TRUE
    );
END;
/
```

**Cách hoạt động:**

1. User thực hiện query: `SELECT * FROM STUDENTS`
2. Oracle tự động gọi policy function: `gms_security_pkg.student_policy()`
3. Policy function trả về WHERE clause: `WHERE student_id = 'STU001'`
4. Oracle tự động thêm WHERE clause vào query
5. Kết quả: User chỉ thấy data được filter

---

### 2. Policy Function hoạt động như thế nào?

**File:** `step4_vpd_policies.sql`

```sql
FUNCTION student_policy(
    p_schema VARCHAR2,
    p_object VARCHAR2
) RETURN VARCHAR2 IS
    v_user_type VARCHAR2(50);
    v_user_id VARCHAR2(10);
    v_predicate VARCHAR2(4000);
BEGIN
    -- Lấy context
    v_user_type := SYS_CONTEXT('gms_context', 'user_type');
    v_user_id := SYS_CONTEXT('gms_context', 'user_id');

    -- Nếu không có context (NULL)
    IF v_user_type IS NULL OR v_user_id IS NULL THEN
        RETURN '1=0';  -- ← KHÔNG THẤY GÌ!
    END IF;

    -- Nếu có context
    IF v_user_type = 'Student' THEN
        v_predicate := 'student_id = ''' || v_user_id || '''';
        RETURN v_predicate;  -- ← WHERE student_id = 'STU001'
    END IF;

    -- Các trường hợp khác...
END;
```

**Quan trọng:** Nếu context là NULL → Trả về `1=0` (không thấy gì)

---

## 🧪 TEST: KHÔNG SET CONTEXT

### Test 1: Query mà không set context

```sql
-- Connect với GMS_STUDENT
sqlplus GMS_STUDENT/Student@2024@//localhost:1521/ORCLPDB

-- KHÔNG set context
-- EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');

-- Query STUDENTS
SELECT * FROM gms_admin.STUDENTS;

-- Kết quả: 0 rows
-- Vì: VPD policy trả về '1=0' (không có context)
```

**Giải thích:**

1. User query: `SELECT * FROM STUDENTS`
2. Oracle gọi: `gms_security_pkg.student_policy()`
3. Policy function check context: `SYS_CONTEXT('gms_context', 'user_id')` → NULL
4. Policy function trả về: `'1=0'`
5. Oracle thêm WHERE: `SELECT * FROM STUDENTS WHERE 1=0`
6. Kết quả: 0 rows (không thấy gì)

---

### Test 2: Query sau khi set context

```sql
-- Connect với GMS_STUDENT
sqlplus GMS_STUDENT/Student@2024@//localhost:1521/ORCLPDB

-- SET context
EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');

-- Query STUDENTS
SELECT * FROM gms_admin.STUDENTS;

-- Kết quả: 1 row (chỉ thấy STU001)
-- Vì: VPD policy trả về 'student_id = ''STU001'''
```

**Giải thích:**

1. User set context: `set_user_context('STU001', 'Student')`
2. Context được lưu: `user_id=STU001, user_type=Student`
3. User query: `SELECT * FROM STUDENTS`
4. Oracle gọi: `gms_security_pkg.student_policy()`
5. Policy function check context: `SYS_CONTEXT('gms_context', 'user_id')` → 'STU001'
6. Policy function trả về: `'student_id = ''STU001'''`
7. Oracle thêm WHERE: `SELECT * FROM STUDENTS WHERE student_id = 'STU001'`
8. Kết quả: 1 row (chỉ thấy STU001)

---

## 🔄 LUỒNG HOẠT ĐỘNG CHI TIẾT

### Khi user query (có set context):

```
1. User: SELECT * FROM STUDENTS
   ↓
2. Oracle: "Có VPD policy trên STUDENTS, gọi policy function"
   ↓
3. Policy Function: gms_security_pkg.student_policy()
   ↓
4. Policy Function: Lấy context
   SYS_CONTEXT('gms_context', 'user_id') → 'STU001'
   SYS_CONTEXT('gms_context', 'user_type') → 'Student'
   ↓
5. Policy Function: Tạo predicate
   RETURN 'student_id = ''STU001'''
   ↓
6. Oracle: Thêm WHERE clause vào query
   SELECT * FROM STUDENTS WHERE student_id = 'STU001'
   ↓
7. Kết quả: 1 row (chỉ thấy STU001)
```

---

### Khi user query (KHÔNG set context):

```
1. User: SELECT * FROM STUDENTS
   ↓
2. Oracle: "Có VPD policy trên STUDENTS, gọi policy function"
   ↓
3. Policy Function: gms_security_pkg.student_policy()
   ↓
4. Policy Function: Lấy context
   SYS_CONTEXT('gms_context', 'user_id') → NULL
   SYS_CONTEXT('gms_context', 'user_type') → NULL
   ↓
5. Policy Function: Không có context → Trả về '1=0'
   RETURN '1=0'
   ↓
6. Oracle: Thêm WHERE clause vào query
   SELECT * FROM STUDENTS WHERE 1=0
   ↓
7. Kết quả: 0 rows (KHÔNG THẤY GÌ)
```

---

## 🛡️ BẢO MẬT: TẠI SAO PHẢI SET CONTEXT?

### Nếu không set context:

```sql
-- User có thể connect, nhưng không thấy gì
sqlplus GMS_STUDENT/Student@2024@//localhost:1521/ORCLPDB

-- Không set context
SELECT * FROM gms_admin.STUDENTS;  -- 0 rows
SELECT * FROM gms_admin.GRADES;    -- 0 rows
SELECT * FROM gms_admin.ENROLLMENTS; -- 0 rows

-- Tất cả đều trả về 0 rows vì VPD policy trả về '1=0'
```

**Đây là cơ chế bảo mật:**

- ✅ User có thể connect (có quyền CONNECT)
- ❌ Nhưng không thể xem data (VPD chặn)
- ✅ Chỉ khi set context đúng → mới thấy data

---

## 🔍 XEM POLICY FUNCTION THỰC TẾ

### Code trong `step4_vpd_policies.sql`:

```sql
FUNCTION student_policy(
    p_schema VARCHAR2,
    p_object VARCHAR2
) RETURN VARCHAR2 IS
    v_user_type VARCHAR2(50);
    v_user_id VARCHAR2(10);
    v_predicate VARCHAR2(4000);
    v_current_user VARCHAR2(128);
BEGIN
    -- Bypass cho GMS_ADMIN và GMS_APP
    v_current_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
    IF v_current_user = 'GMS_ADMIN' OR v_current_user = 'GMS_APP' THEN
        RETURN '1=1';  -- Xem tất cả
    END IF;

    -- Lấy context
    v_user_type := SYS_CONTEXT('gms_context', 'user_type');
    v_user_id := SYS_CONTEXT('gms_context', 'user_id');

    -- NẾU KHÔNG CÓ CONTEXT → KHÔNG THẤY GÌ
    IF v_user_type IS NULL OR v_user_id IS NULL THEN
        RETURN '1=0';  -- ← ĐÂY LÀ LÝ DO PHẢI SET CONTEXT!
    END IF;

    -- Nếu có context
    IF v_user_type = 'Student' THEN
        v_predicate := 'student_id = ''' || v_user_id || '''';
        RETURN v_predicate;
    ELSIF v_user_type = 'Lecturer' THEN
        -- Logic cho Lecturer...
    ELSE
        RETURN '1=0';  -- Không có quyền
    END IF;
END;
```

**Quan trọng:** Dòng `IF v_user_type IS NULL THEN RETURN '1=0'` → Đây là lý do phải set context!

---

## 🧪 DEMO THỰC TẾ

### Test 1: Không set context

```sql
-- Connect
sqlplus GMS_STUDENT/Student@2024@//localhost:1521/ORCLPDB

-- Kiểm tra context (chưa set)
SELECT
    SYS_CONTEXT('gms_context', 'user_id') AS user_id,
    SYS_CONTEXT('gms_context', 'user_type') AS user_type
FROM dual;
-- Kết quả: NULL, NULL

-- Query STUDENTS (không set context)
SELECT COUNT(*) FROM gms_admin.STUDENTS;
-- Kết quả: 0
-- Vì: VPD policy trả về '1=0'

-- Query GRADES (không set context)
SELECT COUNT(*) FROM gms_admin.GRADES;
-- Kết quả: 0
-- Vì: VPD policy trả về '1=0'
```

---

### Test 2: Set context rồi query

```sql
-- Connect
sqlplus GMS_STUDENT/Student@2024@//localhost:1521/ORCLPDB

-- SET context
EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');

-- Kiểm tra context (đã set)
SELECT
    SYS_CONTEXT('gms_context', 'user_id') AS user_id,
    SYS_CONTEXT('gms_context', 'user_type') AS user_type
FROM dual;
-- Kết quả: STU001, Student

-- Query STUDENTS (đã set context)
SELECT COUNT(*) FROM gms_admin.STUDENTS;
-- Kết quả: 1
-- Vì: VPD policy trả về 'student_id = ''STU001'''

-- Query GRADES (đã set context)
SELECT COUNT(*) FROM gms_admin.GRADES;
-- Kết quả: 3 (3 điểm của STU001)
-- Vì: VPD policy trả về predicate phù hợp
```

---

## 🎯 TÓM TẮT

### VPD hoạt động như thế nào?

1. **KHÔNG phải trigger** - VPD là policy function được Oracle gọi tự động
2. **Tự động thêm WHERE clause** - Oracle tự động thêm predicate vào query
3. **Dựa vào context** - Policy function đọc context để quyết định predicate

### Nếu không set context?

- ❌ VPD policy trả về `'1=0'` → Không thấy gì
- ❌ User có thể connect nhưng không xem được data
- ✅ Đây là cơ chế bảo mật: Phải set context đúng mới thấy data

### Tại sao backend phải set context?

- ✅ Để user có thể xem data
- ✅ Để VPD filter đúng user
- ✅ Nếu không set → User không thấy gì (bảo mật)

---

## 📚 KẾT LUẬN

**VPD = Policy Function (KHÔNG phải trigger)**

- Oracle tự động gọi policy function khi query
- Policy function trả về WHERE clause
- Oracle tự động thêm WHERE clause vào query

**Nếu không set context:**

- Policy function trả về `'1=0'`
- Query trả về 0 rows
- User không thấy gì (bảo mật)

**Backend PHẢI set context:**

- Trước mỗi request
- Để user có thể xem data
- Để VPD filter đúng user

---

**Xem thêm:**

- `VPD_CONTEXT_EXPLAINED.md` - Giải thích về VPD context
- `WHY_SINGLE_USER_VPD.md` - Tại sao dùng GMS_APP + VPD
- `step4_vpd_policies.sql` - Code thực tế của VPD policies
