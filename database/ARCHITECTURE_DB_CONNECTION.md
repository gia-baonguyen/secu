# KIẾN TRÚC KẾT NỐI DATABASE - DATABASE CONNECTION ARCHITECTURE

> **Version**: 1.0  
> **Last Updated**: December 2024

---

## 📋 TỔNG QUAN / OVERVIEW

Hệ thống có **2 cách tiếp cận** cho database connection:

1. **Cách Production (Đúng)**: **Single DB User + VPD Context** ✅

   - Backend kết nối với **một user duy nhất** (GMS_APP)
   - Dùng **VPD context** để phân quyền theo role
   - Phù hợp cho ứng dụng thực tế

2. **Cách Testing (Thủ công)**: **Multi DB Users**
   - Mỗi role có một Oracle DB user riêng (GMS_STUDENT, GMS_LECTURER, etc.)
   - Chỉ dùng để test thủ công trong SQL\*Plus
   - Không dùng trong production

---

## 🔍 SO SÁNH CHI TIẾT / DETAILED COMPARISON

### Cách 1: Single DB User + VPD Context (Production) ✅

#### Cách hoạt động:

```
┌─────────────────────────────────────────────────────────┐
│              SPRING BOOT BACKEND                        │
│  ┌───────────────────────────────────────────────────┐  │
│  │  application.properties:                          │  │
│  │  spring.datasource.username=GMS_APP               │  │
│  │  spring.datasource.password=App@2024#Connect      │  │
│  └───────────────────────────────────────────────────┘  │
│                          │                               │
│                          ▼                               │
│  ┌───────────────────────────────────────────────────┐  │
│  │  VpdContextInterceptor (mỗi request):            │  │
│  │  - Lấy user_id, role từ JWT token                │  │
│  │  - Gọi: gms_security_pkg.set_user_context(...)   │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│              ORACLE DATABASE                             │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Connection Pool:                                │  │
│  │  - Tất cả connections dùng user: GMS_APP        │  │
│  │  - Mỗi connection có VPD context riêng           │  │
│  └───────────────────────────────────────────────────┘  │
│                          │                               │
│                          ▼                               │
│  ┌───────────────────────────────────────────────────┐  │
│  │  VPD Policies (tự động filter):                  │  │
│  │  - Đọc SYS_CONTEXT('gms_context', 'user_id')     │  │
│  │  - Đọc SYS_CONTEXT('gms_context', 'user_type')   │  │
│  │  - Áp dụng row-level security                    │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

#### Ưu điểm:

✅ **Connection Pooling hiệu quả**: Chỉ cần một connection pool cho một user  
✅ **Bảo mật tốt hơn**: Password chỉ lưu ở một nơi (application.properties)  
✅ **Dễ quản lý**: Không cần thay đổi connection khi user đổi role  
✅ **Phù hợp production**: Đây là best practice cho enterprise applications  
✅ **Audit rõ ràng**: Tất cả queries đều từ GMS_APP, nhưng VPD context cho biết user thực sự

#### Nhược điểm:

❌ Cần đảm bảo VPD context được set đúng cho mỗi request  
❌ Phức tạp hơn một chút trong setup ban đầu

---

### Cách 2: Multi DB Users (Testing Only) ⚠️

#### Cách hoạt động:

```
┌─────────────────────────────────────────────────────────┐
│              SQL*PLUS (Manual Testing)                  │
│  ┌───────────────────────────────────────────────────┐  │
│  │  sqlplus GMS_STUDENT/Student@2024@...             │  │
│  │  → Kết nối với user GMS_STUDENT                   │  │
│  │  → VPD tự động detect: user_type = 'Student'      │  │
│  └───────────────────────────────────────────────────┘  │
│                          │                               │
│  ┌───────────────────────────────────────────────────┐  │
│  │  sqlplus GMS_LECTURER/Lecturer@2024@...          │  │
│  │  → Kết nối với user GMS_LECTURER                 │  │
│  │  → VPD tự động detect: user_type = 'Lecturer'    │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│              ORACLE DATABASE                             │
│  ┌───────────────────────────────────────────────────┐  │
│  │  VPD Policies:                                    │  │
│  │  - Đọc SYS_USER (Oracle built-in)                │  │
│  │  - Map username → user_type                       │  │
│  │  - Áp dụng row-level security                    │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

#### Ưu điểm:

✅ **Đơn giản cho testing**: Mỗi role login với user riêng  
✅ **Dễ debug**: Có thể test thủ công từng role

#### Nhược điểm:

❌ **Không phù hợp production**: Cần quản lý nhiều passwords  
❌ **Connection pooling phức tạp**: Cần pool riêng cho mỗi user  
❌ **Không linh hoạt**: User không thể đổi role mà không đổi connection  
❌ **Bảo mật kém**: Nhiều passwords cần bảo vệ

---

## 🔧 CẤU HÌNH BACKEND / BACKEND CONFIGURATION

### File: `backend/src/main/resources/application.properties`

#### ❌ Cấu hình SAI (hiện tại):

```properties
# SAI: Dùng GMS_LECTURER - chỉ phù hợp cho testing
spring.datasource.username=GMS_LECTURER
spring.datasource.password=Lecturer@2024
```

#### ✅ Cấu hình ĐÚNG (nên dùng):

```properties
# ĐÚNG: Dùng GMS_APP - phù hợp cho production
spring.datasource.username=GMS_APP
spring.datasource.password=App@2024#Connect
```

---

## 🔐 VPD CONTEXT HOẠT ĐỘNG NHƯ THẾ NÀO?

### Flow khi user login:

1. **User login qua Flutter app**:

   ```
   POST /api/auth/login
   Body: { username: "nvhai", password: "password123" }
   ```

2. **Backend xác thực**:

   - Kiểm tra `SYSTEM_USERS` table
   - Tạo JWT token với `user_id` và `role`

3. **Mỗi request tiếp theo**:

   ```
   GET /api/students/me/grades
   Header: Authorization: Bearer <JWT_TOKEN>
   ```

4. **VpdContextInterceptor chạy**:

   ```java
   // Lấy user từ JWT token
   UserPrincipal user = (UserPrincipal) authentication.getPrincipal();

   // Set VPD context
   vpdContextService.setContext(
       user.getUserId(),  // "STU001"
       user.getRole()     // "STUDENT"
   );
   ```

5. **VPD Context được set trong Oracle**:

   ```sql
   BEGIN
       GMS_ADMIN.gms_security_pkg.set_user_context('STU001', 'Student');
   END;
   ```

6. **VPD Policies tự động filter**:
   ```sql
   -- Khi query: SELECT * FROM GRADES
   -- VPD policy function chạy:
   FUNCTION grade_policy(...) RETURN VARCHAR2 IS
       v_user_id := SYS_CONTEXT('gms_context', 'user_id');  -- "STU001"
       v_user_type := SYS_CONTEXT('gms_context', 'user_type'); -- "Student"
       -- Return predicate: "enrollment_id IN (SELECT ... WHERE student_id = 'STU001')"
   END;
   ```

---

## 📊 BẢNG SO SÁNH / COMPARISON TABLE

| Tiêu chí                | Single User + VPD              | Multi Users               |
| ----------------------- | ------------------------------ | ------------------------- |
| **Số lượng DB users**   | 1 (GMS_APP)                    | 7+ (mỗi role một user)    |
| **Connection pooling**  | ✅ Đơn giản (1 pool)           | ❌ Phức tạp (nhiều pools) |
| **Password management** | ✅ 1 password                  | ❌ 7+ passwords           |
| **Phù hợp production**  | ✅ Có                          | ❌ Không                  |
| **Phù hợp testing**     | ✅ Có (qua API)                | ✅ Có (qua SQL\*Plus)     |
| **Flexibility**         | ✅ User có thể đổi role        | ❌ Phải đổi connection    |
| **Audit trail**         | ✅ Rõ ràng (GMS_APP + context) | ⚠️ Phức tạp (nhiều users) |
| **Setup complexity**    | ⚠️ Trung bình                  | ✅ Đơn giản (cho testing) |

---

## 🎯 KHUYẾN NGHỊ / RECOMMENDATIONS

### ✅ Cho Production:

1. **Dùng GMS_APP** cho tất cả connections
2. **Đảm bảo VpdContextInterceptor** chạy trước mỗi request
3. **Test VPD policies** qua API endpoints, không test trực tiếp SQL

### ⚠️ Cho Testing:

1. **Có thể dùng multi-users** để test thủ công trong SQL\*Plus
2. **Nhưng production phải dùng single user + VPD context**

---

## 🔍 KIỂM TRA CẤU HÌNH / VERIFY CONFIGURATION

### 1. Kiểm tra application.properties:

```bash
cd secu/backend/src/main/resources
cat application.properties | grep datasource.username
# Phải là: spring.datasource.username=GMS_APP
```

### 2. Kiểm tra VPD Context Service:

```bash
# File: VpdContextService.java phải có:
# - setContext(String userId, String userRole)
# - Được gọi bởi VpdContextInterceptor
```

### 3. Test VPD hoạt động:

```bash
# Login và lấy token
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"nvhai","password":"password123"}'

# Dùng token để query grades
curl -X GET http://localhost:8081/api/students/me/grades \
  -H "Authorization: Bearer <TOKEN>"

# Nếu chỉ thấy grades của STU001 → VPD hoạt động đúng ✅
```

---

## 📝 TÓM TẮT / SUMMARY

| Câu hỏi                                                        | Trả lời                                                |
| -------------------------------------------------------------- | ------------------------------------------------------ |
| **Backend nên kết nối với user nào?**                          | `GMS_APP` (single user)                                |
| **Làm sao phân quyền theo role?**                              | Dùng VPD context (`gms_security_pkg.set_user_context`) |
| **Có cần nhiều DB users không?**                               | Không, chỉ cần GMS_APP cho production                  |
| **Các users khác (GMS_STUDENT, GMS_LECTURER) dùng để làm gì?** | Chỉ để test thủ công trong SQL\*Plus                   |
| **VPD context được set khi nào?**                              | Trước mỗi request, bởi `VpdContextInterceptor`         |

---

## 🔗 TÀI LIỆU LIÊN QUAN / RELATED DOCUMENTATION

- `LOGIC_NGHIEP_VU_TONG_HOP.md` - Tổng hợp logic nghiệp vụ
- `02-security/step4_vpd_policies.sql` - VPD policies implementation
- `backend/src/main/java/.../VpdContextService.java` - VPD context service
- `backend/src/main/java/.../VpdContextInterceptor.java` - VPD interceptor

---

**Kết luận**: Hệ thống đang dùng **cách đúng** (single user + VPD context), nhưng cần **sửa application.properties** để dùng `GMS_APP` thay vì `GMS_LECTURER`.
