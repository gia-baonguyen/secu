# 🤔 TẠI SAO DÙNG GMS_APP + VPD CONTEXT THAY VÌ CONNECT TRỰC TIẾP?

## ❓ Câu hỏi

> "Tại sao tất cả đều connect bằng `GMS_APP`, nhưng lại phải set context để phân biệt user? Tại sao không connect trực tiếp bằng `GMS_STUDENT`, `GMS_LECTURER`, etc.?"

---

## 🎯 CÂU TRẢ LỜI NGẮN GỌN

**Dùng `GMS_APP` + VPD Context** vì:

1. ✅ **Connection Pooling** - Hiệu quả hơn
2. ✅ **Quản lý đơn giản** - Chỉ 1 user thay vì hàng nghìn
3. ✅ **Bảo mật tốt hơn** - Không lộ password database
4. ✅ **Linh hoạt** - Dễ thay đổi quyền mà không cần tạo user mới
5. ✅ **Phù hợp với ứng dụng web** - Stateless, không giữ connection lâu

**Nếu connect trực tiếp** sẽ gặp:

1. ❌ **Không thể dùng Connection Pooling** hiệu quả
2. ❌ **Phải quản lý hàng nghìn users** trong database
3. ❌ **Lộ password database** trong code/config
4. ❌ **Khó scale** khi có nhiều users
5. ❌ **Không phù hợp** với kiến trúc web application

---

## 📊 SO SÁNH 2 CÁCH TIẾP CẬN

### Cách 1: Single User (GMS_APP) + VPD Context ✅ (Hiện tại)

```
┌─────────────────┐
│  Flutter App    │
│  User: nvhai    │
└────────┬────────┘
         │ POST /api/auth/login
         │ Body: {username: "nvhai", password: "password123"}
         ↓
┌─────────────────┐
│  Spring Boot    │
│  Backend        │
│                 │
│  1. Authenticate│ ← Kiểm tra trong SYSTEM_USERS
│     (username/  │   (password hash trong DB)
│      password)  │
│                 │
│  2. Set Context │ ← EXEC set_user_context('STU001', 'Student')
│     (VPD)       │
│                 │
│  3. Connect DB  │ ← Tất cả đều dùng GMS_APP
│     (GMS_APP)   │   Connection Pool: 10 connections
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  Oracle DB      │
│  User: GMS_APP  │ ← 1 user duy nhất
│  Context:        │
│  - user_id:     │
│    STU001       │
│  - user_type:   │
│    Student      │
│                 │
│  VPD Filter:    │ ← Tự động filter dựa trên context
│  WHERE student_ │
│  id = 'STU001'  │
└─────────────────┘
```

**Đặc điểm:**

- ✅ Tất cả requests đều connect bằng `GMS_APP`
- ✅ Backend set VPD context trước mỗi request
- ✅ VPD tự động filter dữ liệu dựa trên context
- ✅ Connection Pooling: 10 connections dùng chung

---

### Cách 2: Multiple Users (Connect trực tiếp) ❌ (Không dùng)

```
┌─────────────────┐
│  Flutter App    │
│  User: nvhai    │
└────────┬────────┘
         │ POST /api/auth/login
         │ Body: {username: "nvhai", password: "password123"}
         ↓
┌─────────────────┐
│  Spring Boot    │
│  Backend        │
│                 │
│  1. Authenticate│ ← Kiểm tra trong SYSTEM_USERS
│     (username/  │
│      password)  │
│                 │
│  2. Map to DB   │ ← Map: nvhai → GMS_STUDENT
│     User        │
│                 │
│  3. Connect DB  │ ← Mỗi user = 1 connection riêng
│     (GMS_STUDENT│   Không thể dùng Connection Pool!
│      /password) │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  Oracle DB      │
│  User: GMS_STUDENT│ ← Phải tạo user cho mỗi app user!
│                 │   (1000 students = 1000 DB users?)
│  VPD Filter:    │ ← VPD dựa trên Oracle user
│  WHERE student_ │   (không cần context)
│  id = USER      │
└─────────────────┘
```

**Đặc điểm:**

- ❌ Mỗi app user phải có 1 Oracle DB user tương ứng
- ❌ Phải lưu password database trong backend
- ❌ Không thể dùng Connection Pooling hiệu quả
- ❌ Phải tạo/quản lý hàng nghìn users

---

## 🔍 CHI TIẾT TỪNG VẤN ĐỀ

### 1. Connection Pooling

#### Với GMS_APP (Single User):

```java
// application.properties
spring.datasource.username=GMS_APP
spring.datasource.password=App@2024#Connect

// Connection Pool: 10 connections
// Tất cả requests dùng chung pool này
// Hiệu quả: 10 connections phục vụ 1000+ users
```

**Ưu điểm:**

- ✅ 10 connections phục vụ tất cả users
- ✅ Connection được reuse (tái sử dụng)
- ✅ Hiệu quả về tài nguyên

#### Với Multiple Users:

```java
// Vấn đề: Mỗi user cần connection riêng
// User 1: GMS_STUDENT_001 / password1
// User 2: GMS_STUDENT_002 / password2
// ...
// User 1000: GMS_STUDENT_1000 / password1000

// Không thể dùng Connection Pool!
// Phải tạo connection mới cho mỗi user
// 1000 users = 1000 connections = QUÁ TẢI!
```

**Nhược điểm:**

- ❌ Không thể dùng Connection Pooling
- ❌ Mỗi user = 1 connection riêng
- ❌ 1000 users = 1000 connections (quá tải database)

---

### 2. Quản lý Users

#### Với GMS_APP (Single User):

```sql
-- Chỉ cần 1 user trong database
CREATE USER GMS_APP IDENTIFIED BY "App@2024#Connect";

-- App users được lưu trong bảng SYSTEM_USERS
SELECT * FROM SYSTEM_USERS;
-- 1000+ records, nhưng chỉ là data, không phải DB users
```

**Ưu điểm:**

- ✅ Chỉ 1 Oracle DB user
- ✅ App users = records trong bảng (dễ quản lý)
- ✅ Không cần tạo/xóa DB users

#### Với Multiple Users:

```sql
-- Phải tạo user cho mỗi app user!
CREATE USER GMS_STUDENT_001 IDENTIFIED BY "password1";
CREATE USER GMS_STUDENT_002 IDENTIFIED BY "password2";
...
CREATE USER GMS_STUDENT_1000 IDENTIFIED BY "password1000";

-- 1000 students = 1000 DB users!
-- Quản lý cực kỳ phức tạp
```

**Nhược điểm:**

- ❌ Phải tạo user cho mỗi app user
- ❌ 1000 students = 1000 DB users
- ❌ Khó quản lý, khó scale

---

### 3. Bảo mật

#### Với GMS_APP (Single User):

```java
// application.properties
spring.datasource.username=GMS_APP
spring.datasource.password=App@2024#Connect  // 1 password duy nhất

// App users authenticate qua SYSTEM_USERS
// Password hash trong DB, không lộ password database
```

**Ưu điểm:**

- ✅ Chỉ 1 password database (dễ bảo vệ)
- ✅ App users authenticate qua bảng SYSTEM_USERS
- ✅ Password database không liên quan đến app users

#### Với Multiple Users:

```java
// Phải lưu password database cho mỗi user!
Map<String, String> dbPasswords = {
    "STU001": "GMS_STUDENT_001_password",
    "STU002": "GMS_STUDENT_002_password",
    ...
    "STU1000": "GMS_STUDENT_1000_password"
};

// Vấn đề: Lộ password database trong code/config
// Nếu bị hack → mất tất cả passwords
```

**Nhược điểm:**

- ❌ Phải lưu password database cho mỗi user
- ❌ Lộ password trong code/config
- ❌ Rủi ro bảo mật cao

---

### 4. VPD Context để làm gì?

**VPD Context** là cách Oracle phân biệt user khi tất cả đều connect bằng `GMS_APP`:

```sql
-- Tất cả đều connect bằng GMS_APP
-- Nhưng context khác nhau:

-- Request 1 (User: STU001)
EXEC set_user_context('STU001', 'Student');
SELECT * FROM STUDENTS;  -- VPD filter: WHERE student_id = 'STU001'

-- Request 2 (User: STU002)
EXEC set_user_context('STU002', 'Student');
SELECT * FROM STUDENTS;  -- VPD filter: WHERE student_id = 'STU002'

-- Request 3 (User: LEC001)
EXEC set_user_context('LEC001', 'Lecturer');
SELECT * FROM STUDENTS;  -- VPD filter: WHERE class_id IN (...)
```

**Context = "Giấy tờ tùy thân" của user trong session:**

- Mặc dù tất cả đều là "GMS_APP"
- Nhưng context cho biết "Bạn là ai" (STU001, LEC001, etc.)
- VPD dựa vào context để filter dữ liệu

---

## 🎯 KẾT LUẬN

### Tại sao dùng GMS_APP + VPD Context?

1. **Connection Pooling** - Hiệu quả, tiết kiệm tài nguyên
2. **Quản lý đơn giản** - Chỉ 1 DB user thay vì hàng nghìn
3. **Bảo mật tốt** - Không lộ password database
4. **Linh hoạt** - Dễ thay đổi quyền mà không cần tạo user mới
5. **Phù hợp web app** - Stateless, không giữ connection lâu

### VPD Context để làm gì?

**Context = Cách phân biệt user khi tất cả đều connect bằng GMS_APP:**

- Backend set context: "Bạn là STU001"
- VPD filter: "Chỉ cho STU001 xem data của STU001"
- Kết quả: Mỗi user chỉ thấy data của mình

### Tại sao không connect trực tiếp?

- ❌ Không thể dùng Connection Pooling
- ❌ Phải quản lý hàng nghìn DB users
- ❌ Lộ password database
- ❌ Khó scale
- ❌ Không phù hợp với web application

---

## 📚 Tóm tắt

| Tiêu chí               | GMS_APP + VPD Context ✅ | Multiple Users ❌        |
| ---------------------- | ------------------------ | ------------------------ |
| **Connection Pooling** | ✅ Có (10 connections)   | ❌ Không                 |
| **Số lượng DB Users**  | ✅ 1 user                | ❌ 1000+ users           |
| **Bảo mật**            | ✅ Tốt (1 password)      | ❌ Kém (nhiều passwords) |
| **Quản lý**            | ✅ Đơn giản              | ❌ Phức tạp              |
| **Scale**              | ✅ Dễ scale              | ❌ Khó scale             |
| **Phù hợp Web App**    | ✅ Có                    | ❌ Không                 |

**Kết luận:** Dùng `GMS_APP` + VPD Context là cách đúng và hiệu quả cho web application. Context là cách Oracle phân biệt user khi tất cả đều connect bằng cùng 1 user.
