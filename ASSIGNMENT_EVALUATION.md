# ĐÁNH GIÁ BÀI TẬP LỚN - So sánh với Yêu cầu

**Môn học:** Bảo mật Hệ thống Thông tin  
**Học kỳ:** 1/ Năm học 2025-2026  
**Ngày đánh giá:** 2025-01-XX

---

## 📋 TỔNG QUAN YÊU CẦU

| Nội dung       | Điểm    | Yêu cầu                                             |
| -------------- | ------- | --------------------------------------------------- |
| **Nội dung 1** | 2đ      | Mô tả quy trình nghiệp vụ và các chính sách bảo mật |
| **Nội dung 2** | 5đ      | Cài đặt các chính sách bảo mật trong Oracle         |
| **Nội dung 3** | 2đ      | Hiện thực website/mobile app demo                   |
| **Nội dung 4** | 1đ      | Báo cáo (tài liệu, script, source code, phân công)  |
| **TỔNG**       | **10đ** |                                                     |

---

## ✅ NỘI DUNG 1: MÔ TẢ QUY TRÌNH NGHIỆP VỤ (2đ)

### Yêu cầu:

- Mô tả quy trình nghiệp vụ của hệ thống
- Mô tả các chính sách bảo mật

### Hệ thống hiện tại:

| Tiêu chí                      | Trạng thái | Ghi chú                                                       |
| ----------------------------- | ---------- | ------------------------------------------------------------- |
| **Mô tả quy trình nghiệp vụ** | ✅ CÓ      | File `HUONG_DAN.md` có mô tả đầy đủ quy trình quản lý điểm    |
| **Mô tả chính sách bảo mật**  | ✅ CÓ      | Các file documentation mô tả VPD, OLS, FGA, Password Profiles |
| **Tài liệu tham khảo**        | ✅ CÓ      | Nhiều file .md với hướng dẫn chi tiết                         |

### Files liên quan:

- ✅ `HUONG_DAN.md` - Hướng dẫn đầy đủ (1152+ dòng)
- ✅ `database/README.md` - Mô tả database và security
- ✅ `database/VPD_CONTEXT_EXPLANATION.md` - Giải thích VPD
- ✅ `database/OLS_SETUP_GUIDE.md` - Hướng dẫn OLS
- ✅ `database/COLUMN_LEVEL_SECURITY.md` - Column-level security

### ⚠️ Cần bổ sung:

- [ ] **Báo cáo chính thức** (file PDF/Word) tóm tắt quy trình nghiệp vụ
- [ ] **Sơ đồ quy trình** (flowchart/diagram) minh họa workflow
- [ ] **Bảng so sánh** các chính sách bảo mật (VPD vs OLS vs FGA)

### Đánh giá: **1.5/2đ** ⚠️

- ✅ Có tài liệu đầy đủ nhưng chưa có báo cáo chính thức
- ✅ Mô tả chi tiết nhưng thiếu sơ đồ trực quan

---

## ✅ NỘI DUNG 2: CÀI ĐẶT CHÍNH SÁCH BẢO MẬT (5đ)

### 2.1 Tạo bảng và insert dữ liệu (1đ)

| Tiêu chí           | Trạng thái    | Chi tiết                                  |
| ------------------ | ------------- | ----------------------------------------- |
| **Tạo bảng**       | ✅ HOÀN THÀNH | 15 tables trong `step2_create_tables.sql` |
| **Insert dữ liệu** | ✅ HOÀN THÀNH | 60+ records trong `step6_sample_data.sql` |
| **Quan hệ bảng**   | ✅ HOÀN THÀNH | Foreign keys, constraints đầy đủ          |
| **Data integrity** | ✅ HOÀN THÀNH | Primary keys, unique constraints          |

**Đánh giá: 1/1đ** ✅

### 2.2 Tạo users và cấp quyền (0.5đ)

| Tiêu chí                | Trạng thái    | Chi tiết                               |
| ----------------------- | ------------- | -------------------------------------- |
| **Tạo users**           | ✅ HOÀN THÀNH | 8 users trong `step1_create_users.sql` |
| **Cấp quyền kết nối**   | ✅ HOÀN THÀNH | CONNECT, RESOURCE, CREATE SESSION      |
| **Cấp quyền đối tượng** | ✅ HOÀN THÀNH | SELECT, INSERT, UPDATE trên các bảng   |
| **Column-level quyền**  | ✅ HOÀN THÀNH | UPDATE trên specific columns           |

**Đánh giá: 0.5/0.5đ** ✅

### 2.3 Password Profiles (0.5đ)

| Tiêu chí                | Trạng thái    | Chi tiết                                   |
| ----------------------- | ------------- | ------------------------------------------ |
| **Thiết kế profiles**   | ✅ HOÀN THÀNH | 5 profiles với mức bảo mật khác nhau       |
| **Password complexity** | ✅ HOÀN THÀNH | Custom function `gms_password_verify`      |
| **Password history**    | ✅ HOÀN THÀNH | PASSWORD_REUSE_MAX, PASSWORD_REUSE_TIME    |
| **Account locking**     | ✅ HOÀN THÀNH | FAILED_LOGIN_ATTEMPTS, PASSWORD_LOCK_TIME  |
| **Session limits**      | ✅ HOÀN THÀNH | SESSIONS_PER_USER, IDLE_TIME, CONNECT_TIME |

**Files:**

- ✅ `step3_password_profiles.sql` - 5 profiles
- ✅ Custom password verification function

**Đánh giá: 0.5/0.5đ** ✅

### 2.4 Chính sách bảo mật VPD, OLS, Audit (3đ)

#### Yêu cầu:

- **Nhóm 3 thành viên:** Tối thiểu **2 kỹ thuật** bảo mật
- **Nhóm < 3 thành viên:** Ít nhất **1 trong 2** (VPD hoặc OLS)

#### Hệ thống hiện tại:

| Kỹ thuật                           | Trạng thái    | Chi tiết                                | Điểm |
| ---------------------------------- | ------------- | --------------------------------------- | ---- |
| **VPD (Virtual Private Database)** | ✅ HOÀN THÀNH | 7 policies cho row-level security       | 1.5đ |
| **OLS (Oracle Label Security)**    | ✅ HOÀN THÀNH | 1 policy cho multi-level classification | 1.0đ |
| **FGA (Fine-Grained Auditing)**    | ✅ HOÀN THÀNH | 8 policies + 2 triggers                 | 0.5đ |

**Chi tiết VPD:**

- ✅ 7 VPD policies trên các bảng: STUDENTS, GRADES, ENROLLMENTS, LECTURERS, RELATIVES, DEPARTMENTS, FACULTIES
- ✅ Security package `gms_security_pkg` với context management
- ✅ Row-level filtering theo user role và ID
- ✅ Deadline enforcement cho grade submission

**Chi tiết OLS:**

- ✅ Policy `EXAM_SEC_POLICY` trên bảng EXAM_QUESTIONS
- ✅ 3 security levels: PUB (1000), INT (2000), CONF (3000)
- ✅ 2 compartments: CS, EE
- ✅ 4 data labels: PUB, INT:CS, INT:EE, CONF:CS
- ✅ User authorization cho 4 roles: STUDENT, LECTURER, DEAN, ADMIN

**Chi tiết FGA:**

- ✅ 8 FGA policies trên sensitive columns
- ✅ 2 audit triggers cho INSERT/UPDATE/DELETE
- ✅ Custom audit table `AUDIT_LOG`
- ✅ Audit view `V_AUDIT_TRAIL` kết hợp FGA và triggers

**Files:**

- ✅ `step4_vpd_policies.sql` - VPD implementation
- ✅ `step7_ols_setup.sql` - OLS implementation
- ✅ `step5_audit_policies.sql` - FGA + Triggers

**Đánh giá: 3/3đ** ✅

- ✅ **Vượt yêu cầu:** Có cả 3 kỹ thuật (VPD + OLS + FGA)
- ✅ **Nhóm 3 thành viên:** Đạt yêu cầu tối thiểu 2 kỹ thuật
- ✅ **Nhóm < 3 thành viên:** Đạt yêu cầu (có VPD và OLS)

### Tổng Nội dung 2: **5/5đ** ✅

---

## ✅ NỘI DUNG 3: HIỆN THỰC (2đ)

### Yêu cầu:

- Xây dựng website/mobile app demo có dữ liệu đầy đủ

### Hệ thống hiện tại:

| Component          | Trạng thái    | Chi tiết                           |
| ------------------ | ------------- | ---------------------------------- |
| **Backend API**    | ✅ HOÀN THÀNH | Spring Boot với JWT authentication |
| **Frontend Web**   | ⚠️ CƠ BẢN     | React app (cấu trúc cơ bản)        |
| **Mobile App**     | ✅ HOÀN THÀNH | Flutter app với đầy đủ screens     |
| **Dữ liệu đầy đủ** | ✅ HOÀN THÀNH | 60+ records trong database         |

**Backend Features:**

- ✅ Authentication (Login/Logout)
- ✅ Student endpoints (profile, grades, GPA)
- ✅ Lecturer endpoints (students, grades)
- ✅ Admin endpoints (all students, all grades)
- ✅ VPD context integration
- ✅ JWT token-based security

**Mobile App Features:**

- ✅ Login screen
- ✅ Home screen với role-based navigation
- ✅ Profile screen
- ✅ Grades screen
- ✅ GPA screen
- ✅ Lecturer screens (students, grades)
- ✅ Admin screens (all students, all grades)
- ✅ Role-based UI (Student, Lecturer, Admin)

**Frontend Web:**

- ⚠️ Cấu trúc cơ bản, chưa có UI đầy đủ

**Đánh giá: 1.8/2đ** ⚠️

- ✅ Backend đầy đủ
- ✅ Mobile app đầy đủ
- ⚠️ Frontend web còn cơ bản (có thể bổ sung)

---

## ⚠️ NỘI DUNG 4: BÁO CÁO (1đ)

### Yêu cầu:

1. Tài liệu/số liệu/đường dẫn tham khảo
2. Link/script tạo CSDL và chính sách bảo mật
3. Link source code
4. Bảng phân công nhiệm vụ và đánh giá

### Hệ thống hiện tại:

| Tiêu chí               | Trạng thái | Chi tiết                                           |
| ---------------------- | ---------- | -------------------------------------------------- |
| **Tài liệu tham khảo** | ✅ CÓ      | Nhiều file .md với hướng dẫn                       |
| **Script CSDL**        | ✅ CÓ      | `SETUP_ALL.sql` và các step scripts                |
| **Script bảo mật**     | ✅ CÓ      | VPD, OLS, FGA, Password Profiles                   |
| **Source code**        | ✅ CÓ      | Backend (Java), Frontend (React), Mobile (Flutter) |
| **Bảng phân công**     | ❌ THIẾU   | Chưa có file phân công nhiệm vụ                    |

**Files có sẵn:**

- ✅ `HUONG_DAN.md` - Hướng dẫn đầy đủ
- ✅ `database/SETUP_ALL.sql` - Master script
- ✅ `database/02-security/*.sql` - Security scripts
- ✅ `backend/` - Source code Java
- ✅ `frontend/` - Source code React
- ✅ `flutter_app/` - Source code Flutter

**Cần bổ sung:**

- [ ] **File phân công nhiệm vụ** (bảng Excel/Word/PDF)
- [ ] **Đánh giá đóng góp** của từng thành viên
- [ ] **Link GitHub/Repository** (nếu có)

**Đánh giá: 0.7/1đ** ⚠️

- ✅ Có đầy đủ tài liệu, script, source code
- ❌ Thiếu bảng phân công nhiệm vụ

---

## 📊 TỔNG KẾT ĐÁNH GIÁ

| Nội dung       | Điểm tối đa | Điểm đạt được | Tỷ lệ   |
| -------------- | ----------- | ------------- | ------- |
| **Nội dung 1** | 2đ          | 1.5đ          | 75%     |
| **Nội dung 2** | 5đ          | 5.0đ          | 100%    |
| **Nội dung 3** | 2đ          | 1.8đ          | 90%     |
| **Nội dung 4** | 1đ          | 0.7đ          | 70%     |
| **TỔNG**       | **10đ**     | **9.0đ**      | **90%** |

---

## 🎯 ĐIỂM MẠNH

1. ✅ **Database hoàn chỉnh:** 15 tables, 60+ records, đầy đủ relationships
2. ✅ **Security policies vượt yêu cầu:** Có cả VPD, OLS, FGA (3 kỹ thuật)
3. ✅ **Password profiles chi tiết:** 5 profiles với custom verification
4. ✅ **Backend đầy đủ:** Spring Boot với JWT, VPD integration
5. ✅ **Mobile app hoàn chỉnh:** Flutter với role-based UI
6. ✅ **Documentation tốt:** Nhiều file hướng dẫn chi tiết
7. ✅ **Test scripts:** Có test suite để verify

---

## ⚠️ CẦN BỔ SUNG ĐỂ ĐẠT ĐIỂM TỐI ĐA

### 1. Nội dung 1 (0.5đ còn thiếu):

- [ ] Tạo **báo cáo chính thức** (PDF/Word) tóm tắt quy trình nghiệp vụ
- [ ] Thêm **sơ đồ quy trình** (flowchart) minh họa workflow
- [ ] Tạo **bảng so sánh** các chính sách bảo mật

### 2. Nội dung 3 (0.2đ còn thiếu):

- [ ] Hoàn thiện **Frontend Web** (React UI đầy đủ)
- [ ] Hoặc tập trung vào Mobile app (đã đầy đủ)

### 3. Nội dung 4 (0.3đ còn thiếu):

- [ ] Tạo **bảng phân công nhiệm vụ** (Excel/Word/PDF)
- [ ] Thêm **đánh giá đóng góp** của từng thành viên
- [ ] Cung cấp **link repository** (GitHub/GitLab)

---

## 📝 KHUYẾN NGHỊ

### Để đạt điểm tối đa (10/10đ):

1. **Tạo báo cáo chính thức:**

   - File PDF/Word tóm tắt quy trình nghiệp vụ
   - Sơ đồ flowchart minh họa
   - Bảng so sánh VPD vs OLS vs FGA

2. **Bổ sung bảng phân công:**

   - Tạo file Excel/Word với bảng phân công nhiệm vụ
   - Đánh giá % đóng góp của từng thành viên

3. **Hoàn thiện Frontend (tùy chọn):**
   - Nếu có thời gian, hoàn thiện React UI
   - Hoặc tập trung vào Mobile app (đã đầy đủ)

### Để đạt điểm cao (9.5/10đ):

- Chỉ cần bổ sung:
  1. Bảng phân công nhiệm vụ (0.3đ)
  2. Báo cáo chính thức ngắn gọn (0.2đ)

---

## ✅ KẾT LUẬN

**Hệ thống hiện tại đã đạt: 9.0/10đ (90%)**

- ✅ **Database:** Hoàn chỉnh và vượt yêu cầu
- ✅ **Security:** Có đủ 3 kỹ thuật (VPD + OLS + FGA)
- ✅ **Backend:** Đầy đủ và hoạt động tốt
- ✅ **Mobile App:** Hoàn chỉnh với role-based UI
- ⚠️ **Báo cáo:** Cần bổ sung bảng phân công và báo cáo chính thức

**Để đạt điểm tối đa, cần bổ sung thêm:**

1. Bảng phân công nhiệm vụ (0.3đ)
2. Báo cáo chính thức (0.2đ)
3. Hoàn thiện Frontend Web (0.2đ) - tùy chọn

---

**Last Updated:** 2025-01-XX  
**Version:** 1.0
