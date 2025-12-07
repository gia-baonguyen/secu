# 📊 PHÂN TÍCH GAP - SO SÁNH DOCUMENTATION VỚI SOURCE CODE

## ✅ ĐÃ IMPLEMENT ĐẦY ĐỦ

### Database Layer
- ✅ 14 Tables đã tạo đầy đủ
- ✅ 3 Views: V_STUDENT_GRADES, V_STUDENT_GPA, V_AUDIT_TRAIL
- ✅ VPD Policies (6 policies)
- ✅ FGA Policies (8 policies)
- ✅ Password Profiles (5 profiles)
- ✅ OLS Setup (optional - step7_ols_setup.sql)

### Backend - Entities (10/14)
- ✅ CourseSection
- ✅ Department
- ✅ Enrollment
- ✅ ExamQuestion (mới thêm)
- ✅ Faculty
- ✅ Grade
- ✅ Lecturer
- ✅ Student
- ✅ StudentClass
- ✅ SystemUser

### Backend - Controllers (7)
- ✅ AdminController
- ✅ AuthController
- ✅ DebugController
- ✅ ExamQuestionController (mới thêm)
- ✅ LecturerController
- ✅ StudentController
- ✅ TestController

### Backend - Services (6)
- ✅ AdminService
- ✅ AuthService
- ✅ ExamQuestionService (mới thêm)
- ✅ LecturerService
- ✅ StudentService
- ✅ VpdContextService

---

## ❌ CÒN THIẾU

### 1. Backend - Entities (Thiếu 5 entities)

#### ❌ Relative.java
**Table:** `RELATIVES`
**Location:** `model/entity/Relative.java`

**Fields cần có:**
```java
- relativeId (PK)
- firstName
- lastName
- dateOfBirth
- gender
- contactAddress
- phoneNumber
- occupation
- email
- createdDate
- updatedDate
```

#### ❌ StudentRelative.java
**Table:** `STUDENT_RELATIVES`
**Location:** `model/entity/StudentRelative.java`

**Fields cần có:**
```java
- studentId (PK, FK → STUDENTS)
- relativeId (PK, FK → RELATIVES)
- relationship (Father, Mother, Guardian, Sibling, Other)
- isPrimaryContact (Y/N)
- createdDate
```

#### ❌ Course.java
**Table:** `COURSES`
**Location:** `model/entity/Course.java`

**Fields cần có:**
```java
- courseId (PK)
- courseName
- credits (1-10)
- departmentId (FK → DEPARTMENTS)
- courseType (Mandatory, Elective, Specialized)
- prerequisiteCourseId (FK → COURSES, self-reference)
- description
- createdDate
- updatedDate
```

#### ❌ GradeSubmissionDeadline.java
**Table:** `GRADE_SUBMISSION_DEADLINES`
**Location:** `model/entity/GradeSubmissionDeadline.java`

**Fields cần có:**
```java
- deadlineId (PK, auto-increment)
- semester
- academicYear
- submissionDeadline
- isActive (Y/N)
- createdBy
- createdDate
- updatedDate
```

#### ❌ AuditLog.java
**Table:** `AUDIT_LOG`
**Location:** `model/entity/AuditLog.java`

**Fields cần có:**
```java
- logId (PK, auto-increment)
- tableName
- operation (INSERT, UPDATE, DELETE, SELECT)
- userId
- username
- recordId
- oldValues (CLOB)
- newValues (CLOB)
- operationDate
- ipAddress
- sessionId
```

---

### 2. Backend - Controllers (Thiếu 4 controllers)

#### ❌ DeanController.java
**Location:** `controller/DeanController.java`
**Role:** `DEAN`
**Endpoints cần có:**
- `GET /deans/me` - Get dean profile
- `GET /deans/me/faculty` - Get faculty info
- `GET /deans/me/students` - Get all students in faculty (VPD filters)
- `GET /deans/me/grades` - Get all grades in faculty (VPD filters)
- `GET /deans/me/departments` - Get departments in faculty

**VPD Behavior:**
- Chỉ thấy sinh viên, điểm, lớp trong khoa mình quản lý
- Có thể xem tất cả thông tin trong phạm vi khoa

#### ❌ DepartmentHeadController.java
**Location:** `controller/DepartmentHeadController.java`
**Role:** `DEPARTMENT_HEAD`
**Endpoints cần có:**
- `GET /department-heads/me` - Get department head profile
- `GET /department-heads/me/department` - Get department info
- `GET /department-heads/me/courses` - Get courses in department
- `GET /department-heads/me/grades` - Get grades for department courses (VPD filters)

**VPD Behavior:**
- Chỉ thấy điểm các môn thuộc bộ môn mình quản lý

#### ❌ AcademicAffairsController.java
**Location:** `controller/AcademicAffairsController.java`
**Role:** `ACADEMIC_AFFAIRS`
**Endpoints cần có:**
- `GET /academic-affairs/students` - Get all students (VPD: all)
- `GET /academic-affairs/grades` - Get all grades (VPD: all)
- `GET /academic-affairs/enrollments` - Get all enrollments
- `POST /academic-affairs/enrollments` - Create enrollment
- `PUT /academic-affairs/grades/{id}` - Update grade (bypass deadline)
- `PUT /academic-affairs/students/{id}` - Update student
- `GET /academic-affairs/deadlines` - Get all deadlines
- `POST /academic-affairs/deadlines` - Create deadline
- `PUT /academic-affairs/deadlines/{id}` - Update deadline

**VPD Behavior:**
- Thấy tất cả dữ liệu (VPD: 1=1)
- Có thể sửa điểm bất kỳ lúc nào (bypass deadline)

#### ❌ RelativeController.java
**Location:** `controller/RelativeController.java`
**Role:** `RELATIVE`
**Endpoints cần có:**
- `GET /relatives/me` - Get relative profile
- `GET /relatives/me/children` - Get related students (VPD filters)
- `GET /relatives/me/children/{studentId}/grades` - Get child's grades (VPD filters)
- `PUT /relatives/me` - Update profile (email, phone, address only)

**VPD Behavior:**
- Chỉ thấy sinh viên và điểm của con em mình (qua STUDENT_RELATIVES)

---

### 3. Backend - Services (Thiếu 7 services)

#### ❌ DeanService.java
**Methods:**
- `getMyProfile()` - Get dean profile
- `getMyFaculty()` - Get faculty info
- `getFacultyStudents()` - Get all students in faculty (VPD filters)
- `getFacultyGrades()` - Get all grades in faculty (VPD filters)
- `getFacultyDepartments()` - Get departments in faculty

#### ❌ DepartmentHeadService.java
**Methods:**
- `getMyProfile()` - Get department head profile
- `getMyDepartment()` - Get department info
- `getDepartmentCourses()` - Get courses in department
- `getDepartmentGrades()` - Get grades for department courses (VPD filters)

#### ❌ AcademicAffairsService.java
**Methods:**
- `getAllStudents()` - Get all students (VPD: all)
- `getAllGrades()` - Get all grades (VPD: all)
- `getAllEnrollments()` - Get all enrollments
- `createEnrollment(Enrollment)` - Create enrollment
- `updateGrade(Long, Grade)` - Update grade (bypass deadline)
- `updateStudent(String, Student)` - Update student
- `getAllDeadlines()` - Get all deadlines
- `createDeadline(GradeSubmissionDeadline)` - Create deadline
- `updateDeadline(Long, GradeSubmissionDeadline)` - Update deadline

#### ❌ RelativeService.java
**Methods:**
- `getMyProfile()` - Get relative profile
- `getMyChildren()` - Get related students (VPD filters)
- `getChildGrades(String studentId)` - Get child's grades (VPD filters)
- `updateProfile(Relative)` - Update profile (email, phone, address only)

#### ❌ CourseService.java
**Methods:**
- `getAllCourses()` - Get all courses
- `getCourseById(String courseId)` - Get course by ID
- `getCoursesByDepartment(String departmentId)` - Get courses by department
- `getPrerequisiteCourses(String courseId)` - Get prerequisite courses
- `createCourse(Course)` - Create course (Admin/Academic only)
- `updateCourse(String, Course)` - Update course (Admin/Academic only)

#### ❌ DeadlineService.java
**Methods:**
- `getAllDeadlines()` - Get all deadlines
- `getActiveDeadlines()` - Get active deadlines
- `getDeadlineBySemester(String semester, Integer year)` - Get deadline by semester/year
- `createDeadline(GradeSubmissionDeadline)` - Create deadline (Academic/Academic only)
- `updateDeadline(Long, GradeSubmissionDeadline)` - Update deadline
- `isAfterDeadline(String semester, Integer year)` - Check if current date is after deadline

#### ❌ AuditService.java
**Methods:**
- `getAuditLogs(String tableName, String operation, Date fromDate, Date toDate)` - Query audit logs
- `getUserAuditLogs(String userId, Date fromDate, Date toDate)` - Get audit logs for user
- `getFgaAuditTrail(String tableName, Date fromDate, Date toDate)` - Get FGA audit trail
- `getCustomAuditLog(String tableName, Date fromDate, Date toDate)` - Get custom audit log

---

### 4. Backend - Repositories (Thiếu 5 repositories)

#### ❌ RelativeRepository.java
**Extends:** `JpaRepository<Relative, String>`
**Methods:**
- `findByRelativeId(String relativeId)`
- `findByEmail(String email)`
- `findByPhoneNumber(String phoneNumber)`

#### ❌ StudentRelativeRepository.java
**Extends:** `JpaRepository<StudentRelative, StudentRelativeId>` (composite key)
**Methods:**
- `findByStudentId(String studentId)`
- `findByRelativeId(String relativeId)`
- `findByStudentIdAndRelativeId(String studentId, String relativeId)`

#### ❌ CourseRepository.java
**Extends:** `JpaRepository<Course, String>`
**Methods:**
- `findByCourseId(String courseId)`
- `findByDepartmentId(String departmentId)`
- `findByCourseType(String courseType)`
- `findByPrerequisiteCourseId(String prerequisiteCourseId)`

#### ❌ GradeSubmissionDeadlineRepository.java
**Extends:** `JpaRepository<GradeSubmissionDeadline, Long>`
**Methods:**
- `findBySemesterAndAcademicYear(String semester, Integer academicYear)`
- `findByIsActive(String isActive)`
- `findBySubmissionDeadlineAfter(LocalDateTime date)`

#### ❌ AuditLogRepository.java
**Extends:** `JpaRepository<AuditLog, Long>`
**Methods:**
- `findByTableName(String tableName)`
- `findByOperation(String operation)`
- `findByUserId(String userId)`
- `findByOperationDateBetween(LocalDateTime from, LocalDateTime to)`
- `findByTableNameAndOperation(String tableName, String operation)`

---

### 5. Flutter - Models (Thiếu 5 models)

#### ❌ relative.dart
**Fields:** Tương tự Relative.java

#### ❌ student_relative.dart
**Fields:** Tương tự StudentRelative.java

#### ❌ course.dart
**Fields:** Tương tự Course.java

#### ❌ grade_submission_deadline.dart
**Fields:** Tương tự GradeSubmissionDeadline.java

#### ❌ audit_log.dart
**Fields:** Tương tự AuditLog.java

---

### 6. Flutter - Screens (Thiếu nhiều screens)

#### ❌ Dean Screens
- `dean_home_screen.dart` - Dashboard cho Dean
- `dean_faculty_screen.dart` - Quản lý khoa
- `dean_students_screen.dart` - Xem sinh viên trong khoa
- `dean_grades_screen.dart` - Xem điểm trong khoa

#### ❌ Department Head Screens
- `department_head_home_screen.dart` - Dashboard
- `department_head_courses_screen.dart` - Quản lý môn học
- `department_head_grades_screen.dart` - Xem điểm các môn trong bộ môn

#### ❌ Academic Affairs Screens
- `academic_affairs_home_screen.dart` - Dashboard
- `academic_affairs_students_screen.dart` - Quản lý sinh viên
- `academic_affairs_grades_screen.dart` - Quản lý điểm
- `academic_affairs_enrollments_screen.dart` - Quản lý đăng ký
- `academic_affairs_deadlines_screen.dart` - Quản lý deadline

#### ❌ Relative Screens
- `relative_home_screen.dart` - Dashboard
- `relative_children_screen.dart` - Xem danh sách con em
- `relative_child_grades_screen.dart` - Xem điểm con em

#### ❌ Common Screens
- `courses_screen.dart` - Danh sách môn học (cho tất cả roles)
- `deadlines_screen.dart` - Xem deadline (cho Lecturer, Academic)
- `audit_log_screen.dart` - Xem audit log (cho Admin, Academic)

---

### 7. Flutter - API Service Methods (Thiếu nhiều methods)

#### ❌ Dean API Methods
- `getDeanProfile()`
- `getDeanFaculty()`
- `getDeanStudents()`
- `getDeanGrades()`

#### ❌ Department Head API Methods
- `getDepartmentHeadProfile()`
- `getDepartmentHeadDepartment()`
- `getDepartmentHeadCourses()`
- `getDepartmentHeadGrades()`

#### ❌ Academic Affairs API Methods
- `getAllStudents()`
- `getAllGrades()`
- `getAllEnrollments()`
- `createEnrollment()`
- `updateGrade()`
- `updateStudent()`
- `getAllDeadlines()`
- `createDeadline()`
- `updateDeadline()`

#### ❌ Relative API Methods
- `getRelativeProfile()`
- `getRelativeChildren()`
- `getChildGrades()`
- `updateRelativeProfile()`

#### ❌ Course API Methods
- `getAllCourses()`
- `getCourseById()`
- `getCoursesByDepartment()`
- `createCourse()`
- `updateCourse()`

#### ❌ Deadline API Methods
- `getAllDeadlines()`
- `getActiveDeadlines()`
- `getDeadlineBySemester()`
- `createDeadline()`
- `updateDeadline()`

#### ❌ Audit API Methods
- `getAuditLogs()`
- `getUserAuditLogs()`
- `getFgaAuditTrail()`

---

## 📋 TỔNG KẾT THEO ĐỘ ƯU TIÊN

### Priority 1: Core Entities (Cần cho VPD hoạt động đúng)
1. ❌ **Course.java** - Cần cho CourseSection, Enrollment
2. ❌ **GradeSubmissionDeadline.java** - Cần cho deadline check trong VPD
3. ❌ **Relative.java** - Cần cho Relative role
4. ❌ **StudentRelative.java** - Cần cho Relative VPD policy

### Priority 2: Role Controllers & Services
1. ❌ **DeanController + DeanService** - Role quan trọng
2. ❌ **AcademicAffairsController + AcademicAffairsService** - Role có quyền cao nhất
3. ❌ **DepartmentHeadController + DepartmentHeadService** - Role quản lý bộ môn
4. ❌ **RelativeController + RelativeService** - Role phụ huynh

### Priority 3: Supporting Features
1. ❌ **CourseService + CourseRepository** - Quản lý môn học
2. ❌ **DeadlineService + DeadlineRepository** - Quản lý deadline
3. ❌ **AuditService + AuditLogRepository** - Xem audit logs

### Priority 4: Flutter Implementation
- Sau khi backend hoàn chỉnh, implement Flutter screens và API methods

---

## 📊 BẢNG TỔNG HỢP

| Component | Database | Backend | Flutter | Status |
|-----------|----------|---------|---------|--------|
| **Tables (14)** | ✅ 14/14 | ❌ 10/14 | - | 71% |
| **Entities** | - | ❌ 10/14 | ❌ 5/14 | 71% |
| **Controllers** | - | ❌ 7/11 | - | 64% |
| **Services** | - | ❌ 6/13 | - | 46% |
| **Repositories** | - | ❌ 5/14 | - | 64% |
| **Flutter Models** | - | - | ❌ 5/14 | 36% |
| **Flutter Screens** | - | - | ❌ 1/15+ | <10% |
| **Flutter API Methods** | - | - | ❌ Partial | ~30% |

---

## 🎯 KẾT LUẬN

**Database:** ✅ **Hoàn chỉnh 100%** - Tất cả tables, views, policies đã có

**Backend:** ⚠️ **Thiếu ~40%** - Cần thêm:
- 5 Entities
- 4 Controllers
- 7 Services
- 5 Repositories

**Flutter:** ⚠️ **Thiếu ~70%** - Cần thêm:
- 5 Models
- 10+ Screens
- Nhiều API methods

**Khuyến nghị:** Implement theo thứ tự Priority 1 → 2 → 3 → 4 để đảm bảo hệ thống hoạt động đúng với VPD và các roles.

