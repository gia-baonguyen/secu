# 🎯 Chạy Backend bằng VS Code Spring Boot Extension

## ✅ Yêu cầu Extensions

Cài đặt các extensions sau trong VS Code:

1. **Extension Pack for Java** (Microsoft)

   - Bao gồm: Language Support for Java, Debugger for Java, Test Runner for Java, Maven for Java, Project Manager for Java, Visual Studio IntelliCode

2. **Spring Boot Extension Pack** (VMware)
   - Bao gồm: Spring Boot Tools, Spring Boot Dashboard, Spring Initializr Java Support

**Cách cài:**

- Mở VS Code
- Nhấn `Ctrl+Shift+X` (Extensions)
- Tìm và cài "Extension Pack for Java" và "Spring Boot Extension Pack"

---

## 🚀 CÁCH CHẠY

### Cách 1: Dùng Spring Boot Dashboard (Khuyến nghị)

1. **Mở project trong VS Code:**

   ```bash
   # Mở thư mục backend
   code secu/backend
   ```

2. **Mở Spring Boot Dashboard:**

   - Nhấn `Ctrl+Shift+P` (Command Palette)
   - Gõ: `Spring Boot: Show Dashboard`
   - Hoặc click vào icon Spring Boot ở sidebar

3. **Chạy application:**
   - Trong Spring Boot Dashboard, bạn sẽ thấy `grade-management-system`
   - Click vào nút **▶️ Run** hoặc **▶️ Debug**
   - Hoặc right-click → "Start" / "Debug"

### Cách 2: Dùng Run/Debug Configuration

1. **Mở file `GradeManagementApplication.java`**

2. **Click vào nút "Run" hoặc "Debug"** ở trên class name

   - Hoặc nhấn `F5` (Debug) / `Ctrl+F5` (Run)

3. **Hoặc dùng Command Palette:**
   - `Ctrl+Shift+P` → "Java: Run Java"
   - Chọn `GradeManagementApplication`

### Cách 3: Dùng Launch Configuration

1. **Mở Run and Debug panel:**

   - Nhấn `Ctrl+Shift+D`
   - Hoặc click icon Debug ở sidebar

2. **Chọn configuration:**

   - "Spring Boot - GradeManagementApplication" (Run)
   - "Spring Boot - GradeManagementApplication (Debug)" (Debug)

3. **Nhấn F5 để chạy**

---

## 🔧 CẤU HÌNH

### Files đã tạo:

1. **`.vscode/settings.json`** - VS Code settings cho Java project
2. **`.vscode/launch.json`** - Debug configurations
3. **`.vscode/tasks.json`** - Build tasks (Maven commands)

### Kiểm tra Java Home:

Nếu gặp lỗi về Java, kiểm tra:

1. **Mở Command Palette:** `Ctrl+Shift+P`
2. **Gõ:** `Java: Configure Java Runtime`
3. **Chọn Java version:** Java 17 hoặc cao hơn

Hoặc thêm vào `settings.json`:

```json
{
  "java.jdt.ls.java.home": "C:\\Program Files\\Java\\jdk-17",
  "spring-boot.ls.java.home": "C:\\Program Files\\Java\\jdk-17"
}
```

---

## 📋 CHECKLIST

- [ ] VS Code đã cài
- [ ] Extension Pack for Java đã cài
- [ ] Spring Boot Extension Pack đã cài
- [ ] Java 17+ đã cài và được VS Code nhận diện
- [ ] Maven đã cài (để build dependencies)
- [ ] Database đang chạy
- [ ] Project đã được mở trong VS Code

---

## 🎯 CÁC BƯỚC CHẠY NHANH

### Bước 1: Mở project

```bash
cd secu/backend
code .
```

### Bước 2: Đợi VS Code load project

- VS Code sẽ tự động detect Maven project
- Đợi "Java Projects" load xong (có thể mất 1-2 phút lần đầu)

### Bước 3: Chạy application

- **Option A:** Spring Boot Dashboard → Click Run
- **Option B:** Mở `GradeManagementApplication.java` → Click Run button
- **Option C:** `Ctrl+Shift+D` → Chọn config → F5

### Bước 4: Kiểm tra

- Xem console output
- Test: `http://localhost:8081/api/test/db-connection`

---

## ⚠️ TROUBLESHOOTING

### Lỗi: Java extension không detect project

**Sửa:**

1. `Ctrl+Shift+P` → "Java: Clean Java Language Server Workspace"
2. Restart VS Code
3. Mở lại project

### Lỗi: Maven dependencies không download

**Sửa:**

1. `Ctrl+Shift+P` → "Java: Rebuild Projects"
2. Hoặc mở terminal: `mvn clean install`

### Lỗi: Spring Boot Dashboard không hiện project

**Sửa:**

1. Đảm bảo `pom.xml` ở root của workspace
2. `Ctrl+Shift+P` → "Spring Boot: Refresh Dashboard"
3. Restart VS Code

### Lỗi: Cannot find main class

**Sửa:**

1. Đảm bảo file `GradeManagementApplication.java` tồn tại
2. `Ctrl+Shift+P` → "Java: Rebuild Projects"
3. Kiểm tra `pom.xml` có đúng groupId/artifactId không

---

## 📝 NOTES

- **Port:** Application chạy trên port 8081 (theo `application.properties`)
- **Context Path:** `/api`
- **Main Class:** `edu.university.grademanagement.GradeManagementApplication`
- **Database:** Phải đảm bảo Oracle đang chạy trước khi start backend

---

## ✅ ƯU ĐIỂM DÙNG VS CODE EXTENSION

- ✅ Không cần nhớ Maven commands
- ✅ Debug dễ dàng (breakpoints, step through)
- ✅ Auto-complete và IntelliSense
- ✅ Spring Boot Dashboard quản lý nhiều projects
- ✅ Hot reload (với Spring Boot DevTools)
- ✅ Integrated terminal

---

_Happy coding! 🚀_
