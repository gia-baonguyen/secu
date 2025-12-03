-- =====================================================
-- OLS (ORACLE LABEL SECURITY) SETUP
-- Multi-Level Security for Grade Management System
-- =====================================================
-- Demo: Grades có classification levels:
--   PUBLIC (1) - Public grades (đã công bố)
--   INTERNAL (2) - Internal use (chưa công bố chính thức)
--   CONFIDENTIAL (3) - Confidential (điểm draft, chưa final)
-- Students: Chỉ thấy PUBLIC grades
-- Lecturers: Thấy PUBLIC + INTERNAL
-- Admin: Thấy tất cả (PUBLIC + INTERNAL + CONFIDENTIAL)
-- =====================================================

CONNECT sys/123@localhost:1521/ORCLPDB AS SYSDBA;

-- =====================================================
-- STEP 1: ENABLE LBACSYS (Label-Based Access Control)
-- =====================================================
-- Note: OLS cần Oracle Enterprise Edition
-- Nếu không có EE, script này sẽ fail nhưng không ảnh hưởng VPD/Audit

-- Check if LBACSYS exists
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM dba_users
    WHERE username = 'LBACSYS';

    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('LBACSYS not found. OLS may not be installed.');
        DBMS_OUTPUT.PUT_LINE('To install OLS, run: @?/rdbms/admin/catols.sql');
    ELSE
        DBMS_OUTPUT.PUT_LINE('LBACSYS found. Proceeding with OLS setup...');
    END IF;
END;
/

-- =====================================================
-- STEP 2: CREATE OLS POLICY
-- =====================================================
BEGIN
    -- Drop policy if exists
    BEGIN
        SA_SYSDBA.DROP_POLICY(
            policy_name => 'GRADE_CLASSIFICATION_POLICY',
            drop_column => TRUE
        );
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -20603 THEN -- Policy not found
                RAISE;
            END IF;
    END;

    -- Create new policy
    SA_SYSDBA.CREATE_POLICY(
        policy_name => 'GRADE_CLASSIFICATION_POLICY',
        column_name => 'SECURITY_LABEL',
        default_options => 'NO_CONTROL'
    );

    DBMS_OUTPUT.PUT_LINE('OLS Policy created: GRADE_CLASSIFICATION_POLICY');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('OLS Error: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('OLS may not be available on this Oracle edition.');
        DBMS_OUTPUT.PUT_LINE('Continuing without OLS...');
END;
/

-- =====================================================
-- STEP 3: CREATE SECURITY LEVELS
-- =====================================================
BEGIN
    -- Level 1: PUBLIC (Lowest)
    SA_COMPONENTS.CREATE_LEVEL(
        policy_name => 'GRADE_CLASSIFICATION_POLICY',
        level_num => 100,
        short_name => 'PUB',
        long_name => 'PUBLIC'
    );

    -- Level 2: INTERNAL
    SA_COMPONENTS.CREATE_LEVEL(
        policy_name => 'GRADE_CLASSIFICATION_POLICY',
        level_num => 200,
        short_name => 'INT',
        long_name => 'INTERNAL'
    );

    -- Level 3: CONFIDENTIAL (Highest)
    SA_COMPONENTS.CREATE_LEVEL(
        policy_name => 'GRADE_CLASSIFICATION_POLICY',
        level_num => 300,
        short_name => 'CONF',
        long_name => 'CONFIDENTIAL'
    );

    DBMS_OUTPUT.PUT_LINE('Security levels created: PUBLIC, INTERNAL, CONFIDENTIAL');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error creating levels: ' || SQLERRM);
END;
/

-- =====================================================
-- STEP 4: CREATE DATA LABELS
-- =====================================================
BEGIN
    -- Create labels
    SA_LABEL_ADMIN.CREATE_LABEL(
        policy_name => 'GRADE_CLASSIFICATION_POLICY',
        label_tag => 1,
        label_value => 'PUB',
        data_label => TRUE
    );

    SA_LABEL_ADMIN.CREATE_LABEL(
        policy_name => 'GRADE_CLASSIFICATION_POLICY',
        label_tag => 2,
        label_value => 'INT',
        data_label => TRUE
    );

    SA_LABEL_ADMIN.CREATE_LABEL(
        policy_name => 'GRADE_CLASSIFICATION_POLICY',
        label_tag => 3,
        label_value => 'CONF',
        data_label => TRUE
    );

    DBMS_OUTPUT.PUT_LINE('Data labels created successfully');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error creating labels: ' || SQLERRM);
END;
/

-- =====================================================
-- STEP 5: APPLY POLICY TO GRADES TABLE
-- =====================================================
BEGIN
    SA_POLICY_ADMIN.APPLY_TABLE_POLICY(
        policy_name => 'GRADE_CLASSIFICATION_POLICY',
        schema_name => 'GMS_ADMIN',
        table_name => 'GRADES',
        table_options => 'READ_CONTROL, WRITE_CONTROL',
        label_function => NULL,
        predicate => NULL
    );

    DBMS_OUTPUT.PUT_LINE('OLS policy applied to GRADES table');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error applying policy: ' || SQLERRM);
END;
/

-- =====================================================
-- STEP 6: GRANT USER AUTHORIZATIONS
-- =====================================================
-- Students: Can read PUBLIC only
BEGIN
    SA_USER_ADMIN.SET_USER_LABELS(
        policy_name => 'GRADE_CLASSIFICATION_POLICY',
        user_name => 'GMS_APP',
        max_read_label => 'PUB',
        max_write_label => 'PUB',
        min_write_label => 'PUB',
        def_label => 'PUB',
        row_label => 'PUB'
    );

    DBMS_OUTPUT.PUT_LINE('User labels set for GMS_APP (Student level access)');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error setting user labels: ' || SQLERRM);
END;
/

-- Admin: Can read/write all levels
BEGIN
    SA_USER_ADMIN.SET_USER_LABELS(
        policy_name => 'GRADE_CLASSIFICATION_POLICY',
        user_name => 'GMS_ADMIN',
        max_read_label => 'CONF',
        max_write_label => 'CONF',
        min_write_label => 'PUB',
        def_label => 'INT',
        row_label => 'INT'
    );

    DBMS_OUTPUT.PUT_LINE('User labels set for GMS_ADMIN (Admin level access)');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error setting admin labels: ' || SQLERRM);
END;
/

-- =====================================================
-- STEP 7: ENABLE POLICY
-- =====================================================
BEGIN
    SA_POLICY_ADMIN.ENABLE_POLICY(
        policy_name => 'GRADE_CLASSIFICATION_POLICY'
    );

    DBMS_OUTPUT.PUT_LINE('OLS policy enabled');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error enabling policy: ' || SQLERRM);
END;
/

-- =====================================================
-- VERIFY OLS SETUP
-- =====================================================
PROMPT =====================================================
PROMPT Checking OLS Configuration...
PROMPT =====================================================

-- Check policy
SELECT policy_name, status
FROM dba_sa_policies
WHERE policy_name = 'GRADE_CLASSIFICATION_POLICY';

-- Check levels
SELECT policy_name, level_num, short_name, long_name
FROM dba_sa_levels
WHERE policy_name = 'GRADE_CLASSIFICATION_POLICY'
ORDER BY level_num;

-- Check labels
SELECT policy_name, label_tag, label
FROM dba_sa_labels
WHERE policy_name = 'GRADE_CLASSIFICATION_POLICY'
ORDER BY label_tag;

PROMPT =====================================================
PROMPT OLS Setup Complete (if Oracle Label Security available)!
PROMPT =====================================================
PROMPT Policy: GRADE_CLASSIFICATION_POLICY
PROMPT Levels: PUBLIC (100), INTERNAL (200), CONFIDENTIAL (300)
PROMPT Applied to: GRADES table
PROMPT =====================================================
PROMPT NOTE: If OLS errors occurred, VPD+Audit still work!
PROMPT       OLS requires Oracle Enterprise Edition
PROMPT =====================================================

EXIT;
