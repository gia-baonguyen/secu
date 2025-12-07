# 🔐 VPD CONTEXT - Giải thích chi tiết

## ❓ VPD Context là gì?

**VPD Context** là một cơ chế của Oracle Database để lưu trữ thông tin về người dùng hiện tại trong session. Context này được dùng bởi **VPD (Virtual Private Database)** để quyết định user nào có thể xem dữ liệu nào.

### Ví dụ:

- User `STU001` (Student) đăng nhập → Context: `user_id=STU001, user_type=Student`
- VPD policy sẽ filter: `SELECT * FROM STUDENTS WHERE student_id = 'STU001'`
- Kết quả: User chỉ thấy thông tin của mình

---

## 🏗️ KIẾN TRÚC HỆ THỐNG

### Trong hệ thống của bạn:

```
┌─────────────────┐
│  Flutter App    │
│  (Frontend)     │
└────────┬────────┘
         │ HTTP Request (JWT Token)
         ↓
┌─────────────────┐
│  Spring Boot    │
│  (Backend)      │
│                 │
│  ┌───────────┐  │
│  │ VpdContext│  │ ← TỰ ĐỘNG set context
│  │Interceptor│  │   TRƯỚC MỖI REQUEST
│  └─────┬─────┘  │
│        │        │
│  ┌─────▼─────┐  │
│  │VpdContext│  │
│  │ Service  │  │
│  └─────┬─────┘  │
└────────┼────────┘
         │ EXEC gms_security_pkg.set_user_context('STU001', 'Student')
         ↓
┌─────────────────┐
│  Oracle DB      │
│  (VPD Context)  │
│                 │
│  Context:       │
│  - user_id      │
│  - user_type    │
│  - class_id     │
│  - faculty_id   │
└─────────────────┘
```

---

## ✅ BACKEND TỰ ĐỘNG SET CONTEXT

### 1. Khi user đăng nhập (Login)

**File:** `backend/.../AuthService.java`

```java
public String login(String username, String password) {
    // 1. Authenticate user
    Authentication authentication = authenticationManager.authenticate(...);

    // 2. Set VPD context TỰ ĐỘNG
    vpdContextService.setContext(
        userPrincipal.getUserId(),  // STU001
        userPrincipal.getRole()      // STUDENT
    );

    // 3. Generate JWT token
    return jwtTokenProvider.generateToken(authentication);
}
```

**Kết quả:** Context được set ngay khi login thành công.

---

### 2. Trước mỗi request (Interceptor)

**File:** `backend/.../VpdContextInterceptor.java`

```java
@Override
public boolean preHandle(HttpServletRequest request, ...) {
    // 1. Lấy user từ JWT token
    UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();

    // 2. Set VPD context TRƯỚC MỖI REQUEST
    vpdContextService.setContext(
        userPrincipal.getUserId(),
        userPrincipal.getRole()
    );

    return true; // Continue với request
}
```

**Kết quả:** Context được set lại trước mỗi API call, đảm bảo luôn đúng user.

---

### 3. VpdContextService thực hiện

**File:** `backend/.../VpdContextService.java`

```java
public void setContext(String userId, String userRole) throws Exception {
    // Get connection from pool
    try (Connection conn = dataSource.getConnection()) {
        // Call Oracle procedure
        String sql = "BEGIN GMS_ADMIN.gms_security_pkg.set_user_context(?, ?); END;";

        try (CallableStatement stmt = conn.prepareCall(sql)) {
            stmt.setString(1, userId);      // STU001
            stmt.setString(2, userType);    // Student
            stmt.execute();
        }
    }
}
```

**Kết quả:** Context được set trong Oracle database session.

---

## 🚫 TẠI SAO KHÔNG CẦN LOGON TRIGGER?

### Kiến trúc hiện tại:

1. **Single Database User:** Tất cả requests đều dùng user `GMS_APP` để connect
2. **Connection Pooling:** Mỗi request có thể dùng connection khác nhau
3. **Backend Set Context:** Backend tự động set context trước mỗi request

### Nếu dùng LOGON TRIGGER:

```sql
CREATE OR REPLACE TRIGGER trg_gms_logon
AFTER LOGON ON DATABASE
BEGIN
    -- Vấn đề: Không biết user nào đang login!
    -- Vì tất cả đều connect bằng GMS_APP
    gms_admin.gms_security_pkg.set_user_context(?, ?); -- ???
END;
```

**Vấn đề:**

- Trigger chạy khi Oracle user login (GMS_APP)
- Nhưng không biết app user nào (STU001, LEC001, etc.)
- Không thể set context đúng

---

## 📝 KHI NÀO CẦN SET CONTEXT THỦ CÔNG?

### Chỉ khi test trực tiếp bằng SQL\*Plus:

```sql
-- 1. Connect với Oracle user
sqlplus GMS_STUDENT/Student@2024@//localhost:1521/ORCLPDB

-- 2. Set context THỦ CÔNG (vì không có backend)
EXEC gms_admin.gms_security_pkg.set_user_context('STU001', 'Student');

-- 3. Query để test VPD
SELECT * FROM gms_admin.STUDENTS;  -- Chỉ thấy STU001
```

**Lý do:** Khi test trực tiếp, không có backend để set context tự động.

---

## 🔄 LUỒNG HOẠT ĐỘNG

### Khi user đăng nhập qua app:

```
1. User nhập username/password trong Flutter app
   ↓
2. Flutter gửi POST /api/auth/login
   ↓
3. Backend (AuthService.login):
   - Authenticate user
   - Set VPD context: set_user_context('STU001', 'Student')
   - Generate JWT token
   ↓
4. Flutter nhận JWT token, lưu vào storage
   ↓
5. Mỗi request sau đó:
   - Flutter gửi JWT token trong header
   - Backend (VpdContextInterceptor):
     - Decode JWT → lấy user_id, role
     - Set VPD context: set_user_context('STU001', 'Student')
   - Execute query → VPD filter tự động
```

---

## 🎯 TÓM TẮT

### ✅ Trong app (qua backend):

- **KHÔNG CẦN** set context thủ công
- Backend tự động set context:
  - Khi login
  - Trước mỗi request (Interceptor)
- User không cần làm gì cả

### ⚠️ Khi test trực tiếp (SQL\*Plus):

- **CẦN** set context thủ công
- Vì không có backend
- Chỉ để test/demo VPD

### ❌ Không cần LOGON TRIGGER:

- Vì tất cả đều connect bằng `GMS_APP`
- Backend đã handle việc set context
- Trigger không biết app user nào đang login

---

## 📚 Files liên quan

- `backend/.../VpdContextInterceptor.java` - Set context trước mỗi request
- `backend/.../VpdContextService.java` - Service để set context
- `backend/.../AuthService.java` - Set context khi login
- `database/02-security/step4_vpd_policies.sql` - VPD policies và context package

---

**Kết luận:** Trong hệ thống của bạn, **backend tự động set VPD context**, user không cần làm gì. Chỉ khi test trực tiếp bằng SQL\*Plus mới cần set context thủ công.

---

## 🤔 TẠI SAO DÙNG GMS_APP + VPD CONTEXT?

### Câu hỏi thường gặp:

> "Tại sao tất cả đều connect bằng `GMS_APP`, nhưng lại phải set context? Tại sao không connect trực tiếp bằng `GMS_STUDENT`, `GMS_LECTURER`, etc.?"

### Câu trả lời:

**Dùng `GMS_APP` + VPD Context** vì:

1. ✅ **Connection Pooling** - Hiệu quả hơn (10 connections phục vụ 1000+ users)
2. ✅ **Quản lý đơn giản** - Chỉ 1 user thay vì hàng nghìn
3. ✅ **Bảo mật tốt hơn** - Không lộ password database
4. ✅ **Linh hoạt** - Dễ thay đổi quyền mà không cần tạo user mới
5. ✅ **Phù hợp với ứng dụng web** - Stateless, không giữ connection lâu

**Nếu connect trực tiếp** sẽ gặp:

1. ❌ **Không thể dùng Connection Pooling** hiệu quả
2. ❌ **Phải quản lý hàng nghìn users** trong database
3. ❌ **Lộ password database** trong code/config
4. ❌ **Khó scale** khi có nhiều users

**Xem chi tiết:** `WHY_SINGLE_USER_VPD.md`
