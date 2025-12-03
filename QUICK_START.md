# Grade Management System - Quick Start Guide

## What is This?

A **simple demo application** that demonstrates Oracle Database security features for your university assignment:
- **VPD** (Virtual Private Database) - Row-level security
- **OLS** (Oracle Label Security) - Multi-level classification
- **Audit Trail** - Activity logging
- **Password Policy** - Security enforcement

This is NOT a production application - it's designed to be simple and clearly demonstrate database security policies working.

## Complete File Structure Created

```
grade-management-system/
├── database/
│   ├── SETUP_ALL.sql                    # ⭐ Master setup script - RUN THIS
│   ├── 01-schema/
│   │   └── create_tables.sql            # Database schema
│   ├── 02-security/
│   │   ├── 01_vpd_setup.sql            # ✅ VPD implementation
│   │   ├── 02_ols_setup.sql            # ✅ OLS implementation
│   │   ├── 03_audit_setup.sql          # ✅ Audit trail
│   │   └── 04_password_policy.sql      # ✅ Password policies
│   └── 03-data/
│       └── simple_test_data.sql         # Test data with users
│
├── backend/                              # Spring Boot backend (already exists)
│   └── src/main/java/.../service/
│       └── VpdContextService.java       # VPD context service (fixed)
│
└── demo/
    ├── index.html                        # ✅ Simple HTML test interface
    └── README.md                         # ✅ Detailed documentation
```

## Setup in 3 Steps

### Step 1: Database Setup (5 minutes)

Run the master script:

```bash
cd E:\Desktop\HCMUT\baomat\grade-management-system\database

sqlplus sys/123@localhost:1521/ORCLPDB as sysdba @SETUP_ALL.sql
```

This will:
1. Create all tables (STUDENTS, GRADES, COURSES, etc.)
2. Setup VPD policies and security package
3. Setup OLS with 3 security levels
4. Setup audit trail with triggers
5. Setup password policies
6. Load test data with users

**Note**: If OLS step fails (LBACSYS not installed), that's OK - VPD and Audit still work.

### Step 2: Start Backend (2 minutes)

```bash
cd E:\Desktop\HCMUT\baomat\grade-management-system\backend

mvn spring-boot:run
```

Wait for: `Started GradeManagementApplication on port 8081`

### Step 3: Open Demo Interface

Simply open in browser:
```
E:\Desktop\HCMUT\baomat\grade-management-system\demo\index.html
```

## Test Credentials

**Students** (can only see their own data):
- `nvhai` / `student123` → STU001
- `tthoa` / `student123` → STU002
- `lvminh` / `student123` → STU003

**Lecturers** (see only their courses):
- `ntmai` / `lecturer123` → LEC001 (teaches CRS001, CRS002)
- `tvnam` / `lecturer123` → LEC002 (teaches CRS003)

**Admin** (sees everything):
- `admin` / `admin123`

## Quick Test Scenarios

### Test 1: VPD Row-Level Security (3 minutes)

1. Login as `nvhai` (student)
2. Click "Load Students" → See ONLY STU001
3. Click "Load Grades" → See ONLY STU001's grades
4. Logout, login as `admin`
5. Click "Load Students" → See ALL students
6. Click "Load Grades" → See ALL grades

**Result**: VPD working! Students see only their data, admin sees all.

### Test 2: Audit Trail (2 minutes)

1. Login as any user
2. Load some data (students, grades)
3. Go to "Audit" tab → See logged activities
4. In SQL*Plus, run:
   ```sql
   SELECT * FROM GMS_ADMIN.v_recent_audit;
   ```
5. See all activities logged with username, timestamp, action

**Result**: Audit trail capturing all database operations!

### Test 3: OLS Classification (Advanced)

In SQL*Plus:
```sql
CONNECT GMS_ADMIN/Admin2024Secure@localhost:1521/ORCLPDB

-- Check OLS labels on grades
SELECT grade_id, student_id, score, grade,
       LABEL_TO_CHAR(security_label) as label
FROM GRADES;
```

**Result**: Grades have INTERNAL (200) label applied.

## Assignment Requirements Met

### Nội dung 2 (5đ): Cài đặt chính sách bảo mật

✅ **3+ Security Techniques Implemented:**

1. **VPD** (file: `02-security/01_vpd_setup.sql`)
   - Security package with context management
   - Policy functions for row-level security
   - Students see only their data, lecturers see their courses, admin sees all

2. **OLS** (file: `02-security/02_ols_setup.sql`)
   - 3 security levels: PUBLIC, INTERNAL, CONFIDENTIAL
   - Applied to GRADES table
   - Label-based access control

3. **Audit Trail** (file: `02-security/03_audit_setup.sql`)
   - AUDIT_LOG table
   - Database triggers for automatic logging
   - Fine-Grained Audit (FGA)
   - Standard Oracle auditing

4. **Bonus: Password Policy** (file: `02-security/04_password_policy.sql`)
   - Password complexity verification
   - Account lockout after 5 failed attempts
   - Password expiration (90 days)
   - BCrypt hashing in application

### Nội dung 3 (2đ): Hiện thực website demo

✅ **Simple HTML Demo** (file: `demo/index.html`)
- User login with authentication
- View students, courses, grades
- See VPD filtering in action
- View audit trail
- Clean, professional interface

## Verify Everything Works

### Check VPD:
```sql
SELECT * FROM dba_policies WHERE object_owner = 'GMS_ADMIN';
```

### Check OLS:
```sql
SELECT * FROM dba_sa_policies;
SELECT * FROM dba_sa_levels WHERE policy_name = 'GRADE_CLASSIFICATION_POLICY';
```

### Check Audit:
```sql
SELECT * FROM GMS_ADMIN.v_recent_audit;
SELECT * FROM GMS_ADMIN.v_audit_by_user;
```

### Check Test Data:
```sql
SELECT COUNT(*) as students FROM GMS_ADMIN.STUDENTS;
SELECT COUNT(*) as grades FROM GMS_ADMIN.GRADES;
SELECT COUNT(*) as users FROM GMS_ADMIN.SYSTEM_USERS;
```

## Troubleshooting

### Problem: Login fails
**Solution**: Check if backend is running on port 8081. Check browser console for errors.

### Problem: No data showing
**Solution**: VPD is working! Students see only their data. Try logging in as admin.

### Problem: OLS setup failed
**Solution**: OLS (LBACSYS) may not be installed. That's OK - VPD and Audit still demonstrate security.

## Key Files for Assignment Report

When writing your report, reference these files:

1. **VPD Implementation**: [02-security/01_vpd_setup.sql](database/02-security/01_vpd_setup.sql)
2. **OLS Implementation**: [02-security/02_ols_setup.sql](database/02-security/02_ols_setup.sql)
3. **Audit Trail**: [02-security/03_audit_setup.sql](database/02-security/03_audit_setup.sql)
4. **Demo Interface**: [demo/index.html](demo/index.html)
5. **Detailed Docs**: [demo/README.md](demo/README.md)

## What Makes This Demo Good for Your Assignment?

✅ **Simple but Complete**: Not over-engineered, focuses on security policies
✅ **Well-Documented**: Extensive comments in SQL scripts
✅ **Easy to Test**: Clear test scenarios with expected results
✅ **Meets Requirements**: 3+ security techniques + working demo
✅ **Professional**: Clean code, organized structure, proper naming

## Summary

You now have:
- ✅ Complete VPD implementation with row-level security
- ✅ OLS multi-level classification
- ✅ Comprehensive audit trail
- ✅ Password security policies
- ✅ Test data with realistic users
- ✅ Simple HTML demo interface
- ✅ Detailed documentation

**Total setup time**: ~10 minutes
**Total files created**: 7 SQL scripts + 1 HTML + 2 docs

For detailed testing instructions and verification queries, see [demo/README.md](demo/README.md)
