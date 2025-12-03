# Grade Management System - Security Demo

## Overview

This is a simplified demo application demonstrating **Oracle Database Security features** for a university assignment. The focus is on database security policies rather than a production-ready application.

## Security Features Implemented

### 1. VPD (Virtual Private Database) - Row-Level Security
- **Location**: `database/02-security/01_vpd_setup.sql`
- **Purpose**: Dynamically restrict data access based on user context
- **Implementation**:
  - Security package: `gms_security_pkg`
  - Application context: `gms_context`
  - Policy functions applied to STUDENTS, GRADES, ENROLLMENTS tables
  - Students see only their own records
  - Lecturers see only their course-related records
  - Admins see all records

### 2. OLS (Oracle Label Security) - Multi-Level Classification
- **Location**: `database/02-security/02_ols_setup.sql`
- **Purpose**: Implement multi-level security classification for sensitive data
- **Implementation**:
  - Policy: `GRADE_CLASSIFICATION_POLICY`
  - Security levels:
    - PUBLIC (100): General information
    - INTERNAL (200): Grade records
    - CONFIDENTIAL (300): Special cases
  - Applied to GRADES table with READ_CONTROL and WRITE_CONTROL

### 3. Audit Trail - Activity Logging
- **Location**: `database/02-security/03_audit_setup.sql`
- **Purpose**: Track all database activities for security monitoring
- **Implementation**:
  - Custom AUDIT_LOG table
  - Triggers on GRADES and STUDENTS tables
  - Fine-Grained Audit (FGA) for unauthorized SELECT attempts
  - Standard Oracle auditing for sessions and failed logins
  - Audit views for reporting

### 4. Password Security Policy
- **Location**: `database/02-security/04_password_policy.sql`
- **Purpose**: Enforce strong password requirements
- **Implementation**:
  - Password verification function (complexity rules)
  - Password profiles with expiration and lockout
  - Account status tracking
  - Failed login attempt monitoring
  - BCrypt password hashing in application

## Project Structure

```
grade-management-system/
├── backend/                        # Spring Boot backend
│   └── src/main/java/
│       └── edu/university/grademanagement/
│           ├── config/            # Security, JWT, CORS config
│           ├── controller/        # REST API endpoints
│           ├── model/            # Entity classes
│           ├── repository/       # JPA repositories
│           └── service/          # Business logic, VPD context
│
├── database/
│   ├── 01-schema/                # Database schema
│   │   └── create_tables.sql
│   ├── 02-security/              # Security policies
│   │   ├── 01_vpd_setup.sql     # VPD implementation
│   │   ├── 02_ols_setup.sql     # OLS implementation
│   │   ├── 03_audit_setup.sql   # Audit trail
│   │   └── 04_password_policy.sql # Password policies
│   └── 03-data/                  # Test data
│       └── simple_test_data.sql
│
└── demo/                          # Simple HTML demo interface
    ├── index.html                 # Test interface
    └── README.md                  # This file
```

## Setup Instructions

### Prerequisites
- Oracle Database 19c (with PDB: ORCLPDB)
- Java 17+
- Maven 3.6+
- Modern web browser

### Step 1: Database Setup

Run the SQL scripts in order as SYS user:

```bash
# 1. Create schema and tables
sqlplus sys/password@localhost:1521/ORCLPDB as sysdba @database/01-schema/create_tables.sql

# 2. Setup VPD (Virtual Private Database)
sqlplus sys/password@localhost:1521/ORCLPDB as sysdba @database/02-security/01_vpd_setup.sql

# 3. Setup OLS (Oracle Label Security)
sqlplus sys/password@localhost:1521/ORCLPDB as sysdba @database/02-security/02_ols_setup.sql

# 4. Setup Audit Trail
sqlplus sys/password@localhost:1521/ORCLPDB as sysdba @database/02-security/03_audit_setup.sql

# 5. Setup Password Policy
sqlplus sys/password@localhost:1521/ORCLPDB as sysdba @database/02-security/04_password_policy.sql

# 6. Load test data
sqlplus sys/password@localhost:1521/ORCLPDB as sysdba @database/03-data/simple_test_data.sql
```

### Step 2: Backend Setup

```bash
cd backend

# Build the project
mvn clean install

# Run the Spring Boot application
mvn spring-boot:run
```

The backend will start on `http://localhost:8081`

### Step 3: Open Demo Interface

Simply open `demo/index.html` in your web browser. No web server needed (uses pure HTML/CSS/JavaScript).

## Testing the Security Features

### Test Credentials

**Students:**
- Username: `nvhai` | Password: `student123` | Reference: STU001
- Username: `tthoa` | Password: `student123` | Reference: STU002
- Username: `lvminh` | Password: `student123` | Reference: STU003

**Lecturers:**
- Username: `ntmai` | Password: `lecturer123` | Reference: LEC001
- Username: `tvnam` | Password: `lecturer123` | Reference: LEC002

**Admin:**
- Username: `admin` | Password: `admin123`

### Test Scenarios

#### 1. Test VPD (Row-Level Security)

**Scenario A: Student Access**
1. Login as `nvhai` (password: `student123`)
2. Go to "Students" tab → Click "Load Students"
3. **Expected**: Only see STU001 (own record)
4. Go to "Grades" tab → Click "Load Grades"
5. **Expected**: Only see grades for STU001

**Scenario B: Lecturer Access**
1. Login as `ntmai` (password: `lecturer123`)
2. Go to "Grades" tab → Click "Load Grades"
3. **Expected**: See grades only for courses LEC001 teaches (CRS001, CRS002)

**Scenario C: Admin Access**
1. Login as `admin` (password: `admin123`)
2. Go to any tab and load data
3. **Expected**: See all records (no VPD restrictions)

#### 2. Test OLS (Oracle Label Security)

OLS is applied at database level on the GRADES table:
- All grade records have INTERNAL (200) label
- Access control is managed by user clearance levels
- Students with PUBLIC clearance can only see their own grades (VPD+OLS combined)

**To verify OLS in SQL*Plus:**
```sql
CONNECT GMS_ADMIN/Admin2024Secure@localhost:1521/ORCLPDB

-- Check OLS labels on grades
SELECT grade_id, student_id, score, grade,
       LABEL_TO_CHAR(security_label) as label
FROM GMS_ADMIN.GRADES;
```

#### 3. Test Audit Trail

**Scenario: View Audit Logs**
1. Login as any user and perform some operations (load students, grades, etc.)
2. Go to "Audit" tab → Click "Load Audit Trail"
3. **Expected**: See logged activities

**To verify audit logs in SQL*Plus:**
```sql
CONNECT GMS_ADMIN/Admin2024Secure@localhost:1521/ORCLPDB

-- View recent audit activities
SELECT * FROM GMS_ADMIN.v_recent_audit;

-- View audit summary by user
SELECT * FROM GMS_ADMIN.v_audit_by_user;

-- View failed access attempts
SELECT * FROM GMS_ADMIN.v_failed_access;

-- View all audit records
SELECT audit_timestamp, username, user_type,
       action_type, table_name, success
FROM GMS_ADMIN.AUDIT_LOG
ORDER BY audit_timestamp DESC;
```

#### 4. Test Password Policy

**Scenario A: Failed Login Lockout**
1. Attempt to login with wrong password 5 times
2. **Expected**: Account locked after 5 failed attempts
3. Check account status:
```sql
SELECT * FROM GMS_ADMIN.USER_ACCOUNT_STATUS WHERE username = 'nvhai';
```
4. Unlock account:
```sql
EXEC GMS_ADMIN.unlock_user_account('nvhai');
```

**Scenario B: Password Expiration**
```sql
-- Check password expiry dates
SELECT * FROM GMS_ADMIN.v_user_security_status;

-- Set password to expire (for testing)
UPDATE GMS_ADMIN.USER_ACCOUNT_STATUS
SET password_expiry_date = SYSDATE - 1
WHERE username = 'nvhai';
```

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login
  ```json
  {
    "username": "nvhai",
    "password": "student123"
  }
  ```

### Data Access (Requires JWT token in Authorization header)
- `GET /api/students` - Get students (VPD filtered)
- `GET /api/courses` - Get courses
- `GET /api/grades` - Get grades (VPD + OLS filtered)
- `GET /api/enrollments` - Get enrollments

## Verification Queries

### Check VPD Policies
```sql
SELECT object_owner, object_name, policy_name,
       policy_function, enable
FROM dba_policies
WHERE object_owner = 'GMS_ADMIN';
```

### Check OLS Configuration
```sql
-- Check OLS policies
SELECT policy_name, column_name
FROM dba_sa_policies;

-- Check security levels
SELECT policy_name, level_num, short_name, long_name
FROM dba_sa_levels
WHERE policy_name = 'GRADE_CLASSIFICATION_POLICY';

-- Check user authorizations
SELECT policy_name, user_name, max_level, min_level
FROM dba_sa_user_levels;
```

### Check Audit Configuration
```sql
-- Check audit triggers
SELECT trigger_name, table_name, status
FROM dba_triggers
WHERE owner = 'GMS_ADMIN'
AND trigger_name LIKE 'TRG_AUDIT%';

-- Check FGA policies
SELECT object_schema, object_name, policy_name, enabled
FROM dba_audit_policies
WHERE object_schema = 'GMS_ADMIN';
```

### Check Password Profiles
```sql
-- Check password profiles
SELECT profile, resource_name, limit
FROM dba_profiles
WHERE profile IN ('GMS_PASSWORD_PROFILE', 'GMS_DEV_PROFILE')
ORDER BY profile, resource_name;

-- Check user profiles
SELECT username, profile, account_status
FROM dba_users
WHERE username IN ('GMS_ADMIN', 'GMS_APP');
```

## Database Schema Overview

### Main Tables
- **STUDENTS** - Student information (VPD protected)
- **LECTURERS** - Lecturer information
- **COURSES** - Course information
- **ENROLLMENTS** - Student course enrollments (VPD protected)
- **GRADES** - Student grades (VPD + OLS protected)
- **SYSTEM_USERS** - Application user accounts (BCrypt passwords)

### Security Tables
- **AUDIT_LOG** - Comprehensive audit trail
- **USER_ACCOUNT_STATUS** - Password policy tracking

### Views
- **v_recent_audit** - Recent audit activities (last 7 days)
- **v_audit_by_user** - Audit summary by user
- **v_failed_access** - Failed access attempts
- **v_user_security_status** - User account security status

## Assignment Requirements Met

### Nội dung 2: Cài đặt chính sách bảo mật (5đ)

✅ **VPD (Virtual Private Database)** - Row-level security
- Complete security package with context management
- Policy functions for STUDENTS, GRADES, ENROLLMENTS
- Role-based access control (Student, Lecturer, Admin)

✅ **OLS (Oracle Label Security)** - Multi-level classification
- 3 security levels (PUBLIC, INTERNAL, CONFIDENTIAL)
- Applied to GRADES table
- Read and write control

✅ **Audit Trail** - Activity logging
- Custom audit table with comprehensive tracking
- Database triggers for automatic logging
- Fine-Grained Audit (FGA) for unauthorized access
- Standard Oracle auditing for sessions

✅ **Password Policy** - Security enforcement
- Password complexity verification
- Account lockout after failed attempts
- Password expiration policies
- BCrypt hashing

### Nội dung 3: Hiện thực website demo (2đ)

✅ Simple HTML interface demonstrating:
- User authentication
- VPD row-level security in action
- Data access control by role
- Audit logging visibility

## Troubleshooting

### Backend won't start
- Check Oracle database is running
- Verify connection string in `application.properties`
- Ensure port 8081 is not in use

### Login fails
- Verify user exists: `SELECT * FROM GMS_ADMIN.SYSTEM_USERS WHERE username = 'nvhai';`
- Check password hash is correct
- Ensure account is not locked: `SELECT * FROM GMS_ADMIN.USER_ACCOUNT_STATUS;`

### VPD not working
- Verify context is set:
  ```sql
  SELECT SYS_CONTEXT('gms_context', 'user_id'),
         SYS_CONTEXT('gms_context', 'user_type')
  FROM dual;
  ```
- Check VPD policies enabled:
  ```sql
  SELECT * FROM dba_policies WHERE object_owner = 'GMS_ADMIN';
  ```

### OLS not working
- Check if LBACSYS is installed:
  ```sql
  SELECT * FROM dba_registry WHERE comp_id = 'OLS';
  ```
- Verify policy is applied:
  ```sql
  SELECT * FROM dba_sa_table_policies WHERE schema_name = 'GMS_ADMIN';
  ```

## Notes

- This is a **demo application** for educational purposes
- Focuses on demonstrating database security features
- Not intended for production use
- Passwords are intentionally simple for testing
- Security policies are configured for demonstration clarity

## Contact

For questions about this security demo implementation, refer to the source SQL scripts which contain detailed comments explaining each security feature.
