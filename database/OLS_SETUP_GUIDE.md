# Oracle Label Security (OLS) Setup Guide

## 📋 Overview

Oracle Label Security (OLS) provides **Mandatory Access Control (MAC)** for fine-grained data classification and access control. This implementation secures the **Exam Question Bank** with multi-level security classification.

## 🎯 Use Case: Secure Exam Question Bank

The OLS policy protects sensitive exam questions and answer keys:

- **PUBLIC (PUB)**: General questions visible to all students
- **INTERNAL (INT:CS, INT:EE)**: Department-specific questions visible only to lecturers and deans
- **CONFIDENTIAL (CONF:CS)**: Answer keys visible only to deans

## 🔧 Prerequisites

### 1. Check OLS Installation

```sql
-- Connect as SYSDBA
sqlplus sys/YOUR_PASSWORD@//localhost:1521/ORCLPDB as sysdba

-- Check if OLS is installed
SELECT comp_id, comp_name, version, status
FROM dba_registry
WHERE comp_id = 'OLS';
```

### 2. Enable OLS (If Not Enabled)

```sql
-- Run as SYSDBA (only once)
EXEC LBACSYS.CONFIGURE_OLS;
EXEC LBACSYS.OLS_ENFORCEMENT.ENABLE_OLS;

-- Verify OLS is enabled
SELECT * FROM dba_registry WHERE comp_id = 'OLS';
```

**Note**: OLS is an optional Oracle feature. If not installed, you may need to install it separately or use Oracle Database Enterprise Edition.

## 📝 Setup Steps

### Option 1: Run as Part of SETUP_ALL.sql

Edit `SETUP_ALL.sql` and uncomment the OLS step:

```sql
-- In SETUP_ALL.sql, find STEP 7 and uncomment:
@@02-security/step7_ols_setup.sql
```

### Option 2: Run Standalone

```sql
-- Connect as SYSDBA
sqlplus sys/YOUR_PASSWORD@//localhost:1521/ORCLPDB as sysdba

-- Run the OLS setup script
@database/02-security/step7_ols_setup.sql
```

## 🏗️ Architecture

### Security Levels (Hierarchical)

```
Level 3000: CONFIDENTIAL (CONF)  ← Highest security
Level 2000: INTERNAL (INT)       ← Medium security
Level 1000: PUBLIC (PUB)         ← Lowest security
```

### Compartments (Departments)

- **CS**: Computer Science
- **EE**: Electrical Engineering

### Data Labels

| Label Tag | Label String | Description |
|-----------|--------------|-------------|
| 1000 | PUB | Public questions (all students) |
| 2100 | INT:CS | Internal CS questions (CS lecturers/deans) |
| 2200 | INT:EE | Internal EE questions (EE lecturers/deans) |
| 3100 | CONF:CS | Confidential CS answer keys (CS deans only) |

### User Authorizations

| User | Max Read | Max Write | Can See |
|------|----------|-----------|---------|
| GMS_STUDENT | PUB | - | Only PUB questions |
| GMS_LECTURER | INT:CS | INT:CS | PUB + INT:CS questions |
| GMS_DEAN | CONF:CS | CONF:CS | All CS labels (PUB, INT:CS, CONF:CS) |
| GMS_ADMIN | FULL | FULL | All labels (bypass OLS) |

## 🧪 Testing OLS

### Test 1: Student Access (PUB only)

```sql
-- Connect as GMS_STUDENT
sqlplus GMS_STUDENT/Student@2024@//localhost:1521/ORCLPDB

-- Query exam questions
SELECT question_id, subject_code, 
       SUBSTR(question_text, 1, 50) as question,
       LABEL_TO_CHAR(ols_label) as security_label
FROM gms_admin.EXAM_QUESTIONS;

-- Expected: Only 1 row with label "PUB"
```

### Test 2: Lecturer Access (PUB + INT:CS)

```sql
-- Connect as GMS_LECTURER
sqlplus GMS_LECTURER/Lecturer@2024@//localhost:1521/ORCLPDB

-- Query exam questions
SELECT question_id, subject_code, 
       SUBSTR(question_text, 1, 50) as question,
       LABEL_TO_CHAR(ols_label) as security_label
FROM gms_admin.EXAM_QUESTIONS;

-- Expected: 2 rows (PUB + INT:CS)
-- Should NOT see INT:EE or CONF:CS
```

### Test 3: Dean Access (All CS labels)

```sql
-- Connect as GMS_DEAN
sqlplus GMS_DEAN/Dean@2024@//localhost:1521/ORCLPDB

-- Query exam questions
SELECT question_id, subject_code, 
       SUBSTR(question_text, 1, 50) as question,
       LABEL_TO_CHAR(ols_label) as security_label
FROM gms_admin.EXAM_QUESTIONS;

-- Expected: 3 rows (PUB, INT:CS, CONF:CS)
-- Should NOT see INT:EE (different department)
```

### Test 4: Admin Access (All labels)

```sql
-- Connect as GMS_ADMIN
sqlplus GMS_ADMIN/Admin@2024@//localhost:1521/ORCLPDB

-- Query exam questions
SELECT question_id, subject_code, 
       SUBSTR(question_text, 1, 50) as question,
       LABEL_TO_CHAR(ols_label) as security_label
FROM gms_admin.EXAM_QUESTIONS;

-- Expected: All 4 rows (bypass OLS)
```

## 📊 Verification Queries

### Check OLS Policy Status

```sql
SELECT policy_name, status
FROM dba_sa_policies
WHERE policy_name = 'EXAM_SEC_POLICY';
```

### Check Security Levels

```sql
SELECT level_num, short_name, long_name
FROM dba_sa_levels
WHERE policy_name = 'EXAM_SEC_POLICY'
ORDER BY level_num;
```

### Check Compartments

```sql
SELECT comp_num, short_name, long_name
FROM dba_sa_compartments
WHERE policy_name = 'EXAM_SEC_POLICY'
ORDER BY comp_num;
```

### Check Data Labels

```sql
SELECT label_tag, label
FROM dba_sa_labels
WHERE policy_name = 'EXAM_SEC_POLICY'
ORDER BY label_tag;
```

### Check User Authorizations

```sql
SELECT user_name, max_read_label, max_write_label, min_write_label
FROM dba_sa_user_levels
WHERE policy_name = 'EXAM_SEC_POLICY'
ORDER BY user_name;
```

## 🔍 OLS vs VPD Comparison

| Feature | VPD | OLS |
|---------|-----|-----|
| **Type** | Discretionary Access Control (DAC) | Mandatory Access Control (MAC) |
| **Control** | Application-level (policy functions) | Database-level (labels) |
| **Flexibility** | Highly flexible (custom predicates) | Structured (levels/compartments) |
| **Use Case** | Row-level filtering by user context | Multi-level classification |
| **Performance** | Can be slower (function calls) | Faster (label comparisons) |
| **Complexity** | Medium (requires PL/SQL) | Low (declarative) |

## 🚨 Troubleshooting

### Error: OLS not enabled

```
ORA-12420: Label Security is not enabled
```

**Solution**: Enable OLS as SYSDBA:
```sql
EXEC LBACSYS.CONFIGURE_OLS;
EXEC LBACSYS.OLS_ENFORCEMENT.ENABLE_OLS;
```

### Error: Policy already exists

```
ORA-12410: Policy already exists
```

**Solution**: The script automatically drops existing policy. If error persists, manually drop:
```sql
BEGIN
    SA_SYSDBA.DROP_POLICY(policy_name => 'EXAM_SEC_POLICY', drop_column => TRUE);
END;
/
```

### Error: Insufficient privileges

```
ORA-12430: Insufficient privileges
```

**Solution**: Ensure GMS_ADMIN has LBAC_DBA role:
```sql
GRANT LBAC_DBA TO GMS_ADMIN;
```

### Users cannot see any data

**Check user authorization**:
```sql
SELECT user_name, max_read_label
FROM dba_sa_user_levels
WHERE policy_name = 'EXAM_SEC_POLICY'
AND user_name = 'GMS_STUDENT';
```

**Verify data labels**:
```sql
SELECT question_id, LABEL_TO_CHAR(ols_label) as label
FROM gms_admin.EXAM_QUESTIONS;
```

## 📚 References

- Oracle Label Security Administrator's Guide
- OLS Policy Components (Levels, Compartments, Groups)
- Label Functions: `CHAR_TO_LABEL()`, `LABEL_TO_CHAR()`
- Access Rules: Read dominance, Write dominance

## 🔗 Related Files

- **Setup Script**: `database/02-security/step7_ols_setup.sql`
- **Main Setup**: `database/SETUP_ALL.sql` (Step 7)
- **Test Scripts**: `database/04-tests/` (can add OLS tests)

---

**Last Updated**: 2025-01-XX
**Version**: 1.0

