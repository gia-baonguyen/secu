# 📝 QUY TẮC INSERT ĐIỂM - GMS_ACADEMIC vs GMS_LECTURER

## ❓ Câu hỏi

> "GMS_ACADEMIC là thằng nào làm gì? Tại sao được insert điểm mà Lecturer cũng được insert?"

---

## 🎯 TRẢ LỜI NGẮN GỌN

### GMS_ACADEMIC (Academic Affairs - Phòng Đào tạo):

- ✅ **Có quyền INSERT, UPDATE, DELETE** trên GRADES
- ✅ **Toàn quyền** - Có thể insert/sửa điểm bất kỳ lúc nào
- ✅ **Phê duyệt điểm** sau khi giảng viên submit
- ✅ **Sửa điểm sau deadline** (nếu cần)

### GMS_LECTURER (Giảng viên):

- ❌ **KHÔNG có quyền INSERT** trên GRADES
- ✅ **Chỉ có quyền UPDATE** trên GRADES (điểm đã tồn tại)
- ✅ **Chỉ được update điểm của môn mình dạy**
- ✅ **Chỉ được update trước deadline**

**Kết luận:**

- **Lecturer KHÔNG được insert điểm** - Chỉ được update điểm đã có
- **Academic Affairs được insert điểm** - Toàn quyền

---

## 📊 SO SÁNH QUYỀN

### 1. GMS_ACADEMIC (Academic Affairs)

**Quyền trong database:**

```sql
-- Từ 00_grant_test_privileges.sql
GRANT SELECT, INSERT, UPDATE, DELETE ON gms_admin.GRADES TO GMS_ACADEMIC;
```

**VPD Policy:**

```sql
-- Từ step4_vpd_policies.sql
ELSIF v_user_type = 'Academic_Affairs' OR v_user_type = 'Admin' THEN
    -- Academic Affairs can see all grades
    v_predicate := '1=1';  -- Xem tất cả
```

**Quyền hạn:**

- ✅ **INSERT** - Có thể tạo điểm mới
- ✅ **UPDATE** - Có thể sửa điểm bất kỳ
- ✅ **DELETE** - Có thể xóa điểm
- ✅ **Xem tất cả** - Không bị VPD filter

**Vai trò nghiệp vụ:**

- Phòng Đào tạo - Quản lý toàn bộ hệ thống điểm
- Phê duyệt điểm sau khi giảng viên submit
- Sửa điểm sau deadline (nếu có lỗi)
- Tạo điểm mới (nếu cần)

---

### 2. GMS_LECTURER (Giảng viên)

**Quyền trong database:**

```sql
-- Từ 00_grant_test_privileges.sql
GRANT UPDATE ON gms_admin.GRADES TO GMS_LECTURER;
-- KHÔNG có GRANT INSERT!
```

**VPD Policy:**

```sql
-- Từ step4_vpd_policies.sql
ELSIF v_user_type = 'Lecturer' THEN
    -- Lecturers can see grades for courses they teach
    v_predicate := 'enrollment_id IN (SELECT e.enrollment_id FROM gms_admin.ENROLLMENTS e ' ||
                  'JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id ' ||
                  'WHERE cs.lecturer_id = ''' || v_user_id || ''')';
```

**Quyền hạn:**

- ❌ **INSERT** - KHÔNG có quyền tạo điểm mới
- ✅ **UPDATE** - Chỉ được update điểm đã tồn tại
- ❌ **DELETE** - KHÔNG có quyền xóa điểm
- ✅ **Xem điểm môn mình dạy** - Bị VPD filter

**Vai trò nghiệp vụ:**

- Giảng viên - Nhập điểm cho sinh viên trong môn mình dạy
- Chỉ được update điểm đã có (không tạo mới)
- Chỉ được update trước deadline
- Submit điểm để Phòng ĐT phê duyệt

---

## 🔄 QUY TRÌNH NGHIỆP VỤ THỰC TẾ

### Cách 1: Giảng viên nhập điểm (Thông thường)

```
1. Academic Affairs tạo record GRADES (INSERT)
   - Tạo record với grade_status = 'Pending'
   - enrollment_id, submitted_by = NULL
   ↓
2. Giảng viên update điểm (UPDATE)
   - Update: midterm_score, final_score
   - Update: total_score, letter_grade (tự động tính)
   - Update: grade_status = 'Submitted'
   - Update: submitted_by = 'LEC001'
   ↓
3. Academic Affairs phê duyệt (UPDATE)
   - Update: grade_status = 'Approved'
   - Update: approved_by = 'ACAD001'
```

**Lưu ý:** Trong thực tế, Academic Affairs thường tạo record GRADES trước, sau đó giảng viên update.

---

### Cách 2: Academic Affairs insert trực tiếp (Đặc biệt)

```
1. Academic Affairs insert điểm trực tiếp (INSERT)
   - INSERT INTO GRADES (enrollment_id, midterm_score, final_score, ...)
   - grade_status = 'Approved' (phê duyệt luôn)
   ↓
2. Điểm được công bố ngay
```

**Khi nào dùng:**

- Điểm đặc biệt (thi lại, phúc khảo)
- Sửa lỗi hệ thống
- Nhập điểm thủ công (nếu giảng viên không nhập được)

---

## 🔍 KIỂM TRA QUYỀN THỰC TẾ

### Kiểm tra quyền INSERT của GMS_LECTURER:

```sql
-- Connect với SYSDBA
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba

-- Kiểm tra quyền
SELECT
    grantee,
    table_name,
    privilege
FROM dba_tab_privs
WHERE grantee = 'GMS_LECTURER'
  AND owner = 'GMS_ADMIN'
  AND table_name = 'GRADES'
ORDER BY privilege;

-- Kết quả: Chỉ có UPDATE, KHÔNG có INSERT
```

### Kiểm tra quyền INSERT của GMS_ACADEMIC:

```sql
SELECT
    grantee,
    table_name,
    privilege
FROM dba_tab_privs
WHERE grantee = 'GMS_ACADEMIC'
  AND owner = 'GMS_ADMIN'
  AND table_name = 'GRADES'
ORDER BY privilege;

-- Kết quả: SELECT, INSERT, UPDATE, DELETE
```

---

## 🎯 TẠI SAO LECTURER KHÔNG ĐƯỢC INSERT?

### Lý do nghiệp vụ:

1. **Kiểm soát tốt hơn:**

   - Academic Affairs tạo record GRADES trước
   - Giảng viên chỉ update điểm vào record đã có
   - Đảm bảo mỗi enrollment chỉ có 1 grade

2. **Workflow rõ ràng:**

   - Academic Affairs quản lý danh sách điểm cần nhập
   - Giảng viên chỉ cần nhập điểm, không cần tạo record

3. **Bảo mật:**
   - Tránh giảng viên tạo điểm sai enrollment
   - Academic Affairs kiểm soát toàn bộ quá trình

---

## 📋 TÓM TẮT

| User             | INSERT   | UPDATE               | DELETE   | VPD Filter               |
| ---------------- | -------- | -------------------- | -------- | ------------------------ |
| **GMS_ACADEMIC** | ✅ Có    | ✅ Có                | ✅ Có    | ❌ Không (xem tất cả)    |
| **GMS_LECTURER** | ❌ Không | ✅ Có (môn mình dạy) | ❌ Không | ✅ Có (chỉ môn mình dạy) |

### Quy trình thực tế:

1. **Academic Affairs** tạo record GRADES (INSERT)
2. **Lecturer** update điểm vào record đó (UPDATE)
3. **Academic Affairs** phê duyệt (UPDATE status)

### Kết luận:

- ✅ **GMS_ACADEMIC** = Phòng Đào tạo - Toàn quyền, có thể INSERT
- ❌ **GMS_LECTURER** = Giảng viên - Chỉ UPDATE, KHÔNG được INSERT
- ✅ **Quy trình:** Academic Affairs tạo → Lecturer update → Academic Affairs phê duyệt

---

**Xem thêm:**

- `MO_TA_NGHIEP_VU.md` - Mô tả đầy đủ nghiệp vụ
- `step4_vpd_policies.sql` - VPD policies chi tiết
- `00_grant_test_privileges.sql` - Quyền của từng user
