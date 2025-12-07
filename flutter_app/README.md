# Grade Management System - Flutter App

Flutter demo application for Grade Management System backend.

## 📱 Features

- ✅ User Authentication (Login/Logout)
- ✅ View Student Profile
- ✅ View Grades
- ✅ View GPA
- ✅ Modern Material Design 3 UI
- ✅ State Management with Provider
- ✅ Local Storage with SharedPreferences

## 🚀 Getting Started

> **📌 Xem hướng dẫn đầy đủ:** `../START_HERE.md` - Hướng dẫn chạy từ database → backend → flutter

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Backend server running on `http://localhost:8081`
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Install Flutter dependencies:**

```bash
cd secu/flutter_app
flutter pub get
```

2. **Update API Base URL (QUAN TRỌNG):**

File `lib/services/api_service.dart` đã tự động detect platform:

```dart
static String get baseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8081/api'; // Android emulator
  } else {
    return 'http://localhost:8081/api'; // iOS/Web
  }
}
```

**Lưu ý:**
- **Android Emulator:** Tự động dùng `10.0.2.2` (không cần sửa)
- **iOS Simulator:** Tự động dùng `localhost` (không cần sửa)
- **Physical Device:** Cần sửa thành IP máy tính (ví dụ: `http://192.168.1.100:8081/api`)

3. **Run the app:**

```bash
flutter run
```

## 📱 Test Users

| Username | Password | Role |
|----------|----------|------|
| nvhai | password123 | STUDENT |
| nv.an | password123 | LECTURER |
| admin | password123 | ADMIN |

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── api_response.dart
│   ├── login_request.dart
│   ├── login_response.dart
│   ├── user.dart
│   ├── student.dart
│   ├── grade.dart
│   └── gpa_data.dart
├── services/                 # API & Auth services
│   ├── api_service.dart
│   └── auth_service.dart
└── screens/                  # UI screens
    ├── login_screen.dart
    ├── home_screen.dart
    ├── profile_screen.dart
    ├── grades_screen.dart
    └── gpa_screen.dart
```

## 🔧 Configuration

### Android Configuration

If connecting to localhost, add to `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

### iOS Configuration

If connecting to localhost, add to `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 📝 API Endpoints Used

- `POST /api/auth/login` - User login
- `GET /api/auth/profile` - Get user profile
- `GET /api/students/me` - Get student profile
- `GET /api/students/me/grades` - Get student grades
- `GET /api/students/me/gpa` - Get student GPA
- `POST /api/auth/logout` - User logout

## 🎨 UI Screenshots

- **Login Screen**: Clean login form with test user info
- **Home Screen**: Dashboard with quick actions
- **Grades Screen**: List of all grades with details
- **GPA Screen**: GPA display with statistics
- **Profile Screen**: User and student information

## 🐛 Troubleshooting

### Connection Error

- Ensure backend is running on `http://localhost:8081`
- Check firewall settings
- For Android emulator, use `10.0.2.2` instead of `localhost`
- For physical device, use your computer's IP address

### Build Errors

```bash
flutter clean
flutter pub get
flutter run
```

### API Errors

- Check backend logs
- Verify backend is accessible from device/emulator
- Check CORS settings in backend

## 📚 Dependencies

- `http` - HTTP client
- `provider` - State management
- `shared_preferences` - Local storage
- `json_annotation` - JSON serialization

## 🔐 Security Notes

- Tokens are stored in SharedPreferences (not encrypted)
- For production, use secure storage (flutter_secure_storage)
- Implement token refresh mechanism
- Add certificate pinning for HTTPS

## 📚 Tài liệu tham khảo

- **Hướng dẫn chạy hệ thống:** `../START_HERE.md` - Hướng dẫn chạy từ database → backend → flutter
- **Backend API:** `../backend/API_TEST.md`
- **Quick Start:** Xem `QUICK_START.md` để biết các bước nhanh

## 📄 License

This is a demo application for educational purposes.

