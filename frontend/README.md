# Frontend - Grade Management System

React frontend application for the University Grade Management System.

## 📋 Prerequisites

- **Node.js 18+ hoặc cao hơn** (hiện tại máy có Node 22.19.0 ✅)
- **npm 9+** (hiện tại máy có npm 11.5.2 ✅)

## 🔧 Technology Stack

- React 18.2.0
- Redux Toolkit (state management)
- Material-UI 5.14 (UI components)
- React Router v6 (routing)
- Axios (HTTP client)
- Formik + Yup (forms & validation)
- Chart.js & Recharts (data visualization)
- jsPDF (PDF generation)

## 📁 Project Structure

```
frontend/
├── package.json                    # Dependencies (39 packages)
├── public/                         # Static files
├── src/
│   ├── App.js                      # Main app with routing (205 lines)
│   ├── index.js                    # Entry point
│   ├── components/                 # Reusable components (empty)
│   ├── pages/                      # Page components (empty)
│   │   ├── student/               # Student pages
│   │   ├── lecturer/              # Lecturer pages
│   │   ├── academic/              # Academic Affairs pages
│   │   ├── dean/                  # Dean pages
│   │   ├── dept-head/             # Department Head pages
│   │   └── relative/              # Relative pages
│   ├── redux/                      # Redux store (empty)
│   │   ├── store.js
│   │   └── slices/
│   ├── services/                   # API services (empty)
│   │   └── api.js
│   └── utils/                      # Utilities (empty)
└── README.md                       # This file
```

## ⚙️ Configuration

Backend API trong `src/services/api.js` (cần tạo):

```javascript
const API_BASE_URL = 'http://localhost:8080/api';
```

## 🚀 Installation & Running

### Bước 1: Cài đặt dependencies

```bash
# Chuyển vào thư mục frontend
cd e:\Desktop\HCMUT\baomat\grade-management-system\frontend

# Cài đặt tất cả packages (39 packages)
npm install

# Hoặc dùng yarn
yarn install
```

**Thời gian ước tính:** 2-3 phút (tùy vào tốc độ mạng)

### Bước 2: Start development server

```bash
# Start React app
npm start

# Hoặc
yarn start
```

Application sẽ tự động mở browser tại: **http://localhost:3000**

### Bước 3: Build for production

```bash
# Build optimized production bundle
npm run build

# Output folder: build/
```

## 🎨 Available Routes

Routing đã được định nghĩa trong `App.js`:

| Role | Path | Component | Status |
|------|------|-----------|--------|
| **Student** | `/student/*` | StudentRoutes | ⚠️ Not implemented |
| **Lecturer** | `/lecturer/*` | LecturerRoutes | ⚠️ Not implemented |
| **Academic Affairs** | `/academic/*` | AcademicRoutes | ⚠️ Not implemented |
| **Dean** | `/dean/*` | DeanRoutes | ⚠️ Not implemented |
| **Department Head** | `/dept-head/*` | DeptHeadRoutes | ⚠️ Not implemented |
| **Relative** | `/relative/*` | RelativeRoutes | ⚠️ Not implemented |
| **Login** | `/login` | Login | ⚠️ Not implemented |
| **Home** | `/` | Home | ⚠️ Not implemented |

## 🔍 Testing

### Run tests

```bash
npm test
```

### Run tests with coverage

```bash
npm test -- --coverage
```

## 📦 Package Scripts

```json
{
  "start": "react-scripts start",       // Development server
  "build": "react-scripts build",       // Production build
  "test": "react-scripts test",         // Run tests
  "eject": "react-scripts eject"        // Eject from Create React App
}
```

## ⚠️ Troubleshooting

### Lỗi: npm ERR! code ENOENT
```bash
# Đảm bảo đang ở đúng thư mục frontend
cd e:\Desktop\HCMUT\baomat\grade-management-system\frontend

# Xóa node_modules và reinstall
rm -rf node_modules package-lock.json
npm install
```

### Lỗi: Port 3000 already in use
```bash
# Tìm và kill process đang dùng port 3000
# Windows:
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Hoặc đổi port khác
set PORT=3001 && npm start
```

### Lỗi: CORS when calling backend API
```bash
# Đảm bảo backend đã enable CORS cho localhost:3000
# Trong application.properties:
security.cors.allowed-origins=http://localhost:3000,http://localhost:3001
```

### Warning: React version mismatch
```bash
# Reinstall dependencies
npm install --legacy-peer-deps
```

## 📊 Current Implementation Status

| Component | Status | Notes |
|-----------|--------|-------|
| Dependencies | ✅ Complete | package.json with 39 packages |
| Routing | ✅ Complete | App.js with all role-based routes |
| Layout | ❌ Not Started | Header, Sidebar, Footer needed |
| Pages | ❌ Not Started | 40+ pages needed for 6 roles |
| Redux Store | ❌ Not Started | State management setup needed |
| API Services | ❌ Not Started | Axios instances and interceptors needed |
| Components | ❌ Not Started | Reusable UI components needed |
| Forms | ❌ Not Started | Formik + Yup forms needed |
| Charts | ❌ Not Started | Data visualization needed |
| Authentication | ❌ Not Started | Login, JWT handling needed |
| Tests | ❌ Not Started | Unit and integration tests needed |

## 🎯 Next Steps

Để hoàn thiện frontend, cần implement:

1. **Redux Store** - Setup store, slices (auth, student, lecturer, etc.)
2. **API Services** - Axios configuration, interceptors, endpoints
3. **Layout Components** - Header, Sidebar, Footer, PrivateRoute
4. **Authentication** - Login page, JWT token handling
5. **Student Pages** - Dashboard, Grades, Profile (10+ pages)
6. **Lecturer Pages** - Dashboard, Grade Input, Students (10+ pages)
7. **Academic Pages** - All students, All grades, Reports (10+ pages)
8. **Dean Pages** - Faculty statistics, Reports (5+ pages)
9. **DeptHead Pages** - Department statistics (5+ pages)
10. **Relative Pages** - Children's grades (3+ pages)
11. **Common Components** - Tables, Forms, Dialogs, Charts
12. **Tests** - Jest + React Testing Library

## 📝 Notes

- Frontend hiện tại chỉ có routing skeleton trong App.js
- Chưa có pages hay components nào
- Cần implement đầy đủ để có UI hoạt động
- Ước tính: 8000-12000 lines of code cần viết

## 🚀 Quick Start for Development

```bash
# 1. Install dependencies
npm install

# 2. Start development server
npm start

# 3. Open browser at http://localhost:3000

# 4. Make changes to App.js or create new components
# 5. Hot reload will update automatically
```

## 📞 Support

Xem hướng dẫn đầy đủ trong [HUONG_DAN.md](../HUONG_DAN.md)

## 🔗 Useful Links

- [React Documentation](https://react.dev/)
- [Material-UI](https://mui.com/)
- [Redux Toolkit](https://redux-toolkit.js.org/)
- [React Router](https://reactrouter.com/)
- [Axios](https://axios-http.com/)
