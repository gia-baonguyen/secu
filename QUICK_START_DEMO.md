# ⚡ QUICK START - DEMO HỆ THỐNG

> Hướng dẫn nhanh để chạy và demo hệ thống trong 5 phút

---

## 🚀 3 BƯỚC CHẠY HỆ THỐNG

### Bước 1: Setup Database (1 lần duy nhất)

```powershell
cd D:\BaoMatHTTT\secu\database
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba "@RUN_ALL.sql"
```

**Thời gian:** ~5-10 phút  
**Kết quả:** Database đã setup đầy đủ với sample data

---

### Bước 2: Chạy Backend

```powershell
cd D:\BaoMatHTTT\secu\backend
mvn spring-boot:run
```

**Hoặc dùng batch file:**

```powershell
.\run_backend.bat
```

**Kiểm tra:** Mở browser → http://localhost:8081/api/swagger-ui.html

**Thời gian:** ~30 giây để start

---

### Bước 3: Chạy Flutter App

```powershell
cd D:\BaoMatHTTT\secu\flutter_app
flutter run
```

**Hoặc dùng VS Code:**

1. Mở VS Code trong `secu/flutter_app`
2. Chọn device (emulator hoặc physical device)
3. Nhấn `F5`

**Thời gian:** ~1-2 phút để build và chạy

---

## 🎯 DEMO NHANH

### Test Account

| Role             | Username | Password      |
| ---------------- | -------- | ------------- |
| Student          | STU001   | Student@2024  |
| Lecturer         | LEC001   | Lecturer@2024 |
| Dean             | DEAN001  | Dean@2024     |
| Academic Affairs | AA001    | Academic@2024 |

### Demo Flow

1. **Login** → Chọn role → Nhập username/password
2. **Xem Dashboard** → Mỗi role thấy data khác nhau (VPD filtering)
3. **Update Profile** → Student/Lecturer/Relative có thể update
4. **View Grades** → Mỗi role chỉ thấy grades được phép
5. **Exam Questions** → Test OLS (Student chỉ thấy PUB, Lecturer thấy PUB+INT, Dean thấy tất cả)

---

## ⚠️ TROUBLESHOOTING NHANH

### Database không kết nối được

```sql
-- Kiểm tra Oracle service
sqlplus sys/123@//localhost:1521/ORCLPDB as sysdba

-- Nếu lỗi → Start Oracle service
```

### Backend không start

```bash
# Kiểm tra port 8081
netstat -ano | findstr :8081

# Kill process nếu cần
taskkill /PID <PID> /F

# Hoặc đổi port trong application.properties
```

### Flutter không kết nối backend

```dart
// Kiểm tra baseUrl trong api_service.dart
// Android emulator: http://10.0.2.2:8081/api
// iOS simulator: http://localhost:8081/api
```

---

## 📚 TÀI LIỆU CHI TIẾT

- **Hướng dẫn đầy đủ:** `DEMO_GUIDE_COMPLETE.md`
- **Database setup:** `database/HUONG_DAN_CHAY_LAI.md`
- **Backend setup:** `backend/README.md`
- **Logic nghiệp vụ:** `LOGIC_NGHIEP_VU_TONG_HOP.md`

---

**Last Updated:** December 2024
