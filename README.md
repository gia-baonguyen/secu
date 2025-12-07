# University Grade Management System

## System B: Quy trình quản lý điểm trong trường đại học

A comprehensive grade management system for universities featuring Oracle security policies.

**Tài liệu đầy đủ (Tiếng Việt):** [HUONG_DAN.md](HUONG_DAN.md)

---

## Quick Overview

### Security Features

- **VPD (Virtual Private Database)** - Row-level security (6 policies)
- **Password Profiles** - Security enforcement (5 profiles)
- **FGA (Fine-Grained Auditing)** - Activity logging (8 policies)
- **Audit Triggers** - Automatic tracking (2 triggers)

### User Roles (6 roles)

| Role             | Access             |
| ---------------- | ------------------ |
| Student          | Own grades only    |
| Lecturer         | Courses they teach |
| Academic Affairs | All data (admin)   |
| Dean             | Faculty-wide data  |
| Department Head  | Department data    |
| Relative         | Children's grades  |

---

## Quick Start (5 minutes)

### Prerequisites

- Oracle Database 19c
- SYSDBA privilege
- PDB: ORCLPDB

### Database Setup

```bash
cd D:\BaoMatHTTT\secu
sqlplus sys/YOUR_PASSWORD@//localhost:1521/ORCLPDB as sysdba

-- Run all scripts in order:
@database\01-schema\step1_create_users.sql
@database\01-schema\step2_create_tables.sql
@database\02-security\step3_password_profiles.sql
@database\02-security\step4_vpd_policies.sql
@database\02-security\step5_audit_policies.sql
@database\03-data\step6_sample_data.sql

-- Or use master script:
@database\SETUP_ALL.sql
```

### Test Accounts

| Username     | Password      | Role             |
| ------------ | ------------- | ---------------- |
| GMS_STUDENT  | Student@2024  | Student          |
| GMS_LECTURER | Lecturer@2024 | Lecturer         |
| GMS_ACADEMIC | Academic@2024 | Academic Affairs |
| GMS_RELATIVE | Relative@2024 | Relative         |

### Run Tests

```bash
@database\04-tests\02_comprehensive_tests.sql
-- Expected: 29/29 PASSED
```

---

## Project Structure

```
secu/
├── README.md              # This file (English summary)
├── HUONG_DAN.md          # Full guide (Vietnamese)
├── database/
│   ├── SETUP_ALL.sql     # Master setup script
│   ├── 01-schema/        # Step 1-2: Users & Tables
│   ├── 02-security/      # Step 3-5: Security Policies
│   ├── 03-data/          # Step 6: Sample Data
│   ├── 04-tests/         # Test Scripts
│   └── 05-backup-scripts/
├── backend/              # Spring Boot API
├── frontend/             # React UI
├── demo/                 # HTML demo
└── deployment/
```

---

## Documentation

| Document                                 | Description                            |
| ---------------------------------------- | -------------------------------------- |
| [HUONG_DAN.md](HUONG_DAN.md)             | Full Vietnamese guide with all details |
| [backend/README.md](backend/README.md)   | Backend setup                          |
| [frontend/README.md](frontend/README.md) | Frontend setup                         |
| [demo/README.md](demo/README.md)         | Demo interface                         |

---

## Test Results

- **29/29 tests PASSED (100%)**
- Database Schema: 4/4 ✓
- Data Integrity: 3/3 ✓
- Password Profiles: 2/2 ✓
- VPD Policies: 4/4 ✓
- FGA Policies: 3/3 ✓
- Business Logic: 5/5 ✓
- Security Context: 3/3 ✓
- Data Validation: 3/3 ✓
- Performance: 1/1 ✓
- System Health: 1/1 ✓

---

**Version:** 1.0.0  
**Status:** Database Complete (Backend/Frontend: Basic structure)  
**Course:** Information Systems Security - HCMUT
