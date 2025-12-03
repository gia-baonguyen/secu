-- =====================================================
-- VPD (VIRTUAL PRIVATE DATABASE) SETUP
-- Row-Level Security for Grade Management System
-- =====================================================
-- Demo: Students chỉ thấy điểm của mình
--       Lecturers thấy điểm students trong lớp mình dạy
--       Admin thấy tất cả
-- =====================================================

CONNECT sys/123@localhost:1521/ORCLPDB AS SYSDBA;

-- =====================================================
-- STEP 1: CREATE SECURITY PACKAGE
-- =====================================================
CREATE OR REPLACE PACKAGE GMS_ADMIN.gms_security_pkg AS
    -- Set user context (called when user logs in)
    PROCEDURE set_user_context(
        p_user_id VARCHAR2,
        p_user_type VARCHAR2
    );

    -- Clear user context
    PROCEDURE clear_user_context;

    -- Get current user info
    FUNCTION get_user_type RETURN VARCHAR2;
    FUNCTION get_user_id RETURN VARCHAR2;

    -- VPD Policy functions
    FUNCTION student_policy(
        p_schema VARCHAR2,
        p_object VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION grade_policy(
        p_schema VARCHAR2,
        p_object VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION enrollment_policy(
        p_schema VARCHAR2,
        p_object VARCHAR2
    ) RETURN VARCHAR2;
END gms_security_pkg;
/

CREATE OR REPLACE PACKAGE BODY GMS_ADMIN.gms_security_pkg AS

    -- =====================================================
    -- SET USER CONTEXT
    -- Called when user logs into application
    -- =====================================================
    PROCEDURE set_user_context(
        p_user_id VARCHAR2,
        p_user_type VARCHAR2
    ) IS
    BEGIN
        -- Set context attributes
        DBMS_SESSION.SET_CONTEXT('gms_context', 'user_id', p_user_id);
        DBMS_SESSION.SET_CONTEXT('gms_context', 'user_type', p_user_type);

        -- Log for debugging
        DBMS_OUTPUT.PUT_LINE('VPD Context set: user_id=' || p_user_id || ', user_type=' || p_user_type);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error setting context: ' || SQLERRM);
            RAISE;
    END set_user_context;

    -- =====================================================
    -- CLEAR USER CONTEXT
    -- =====================================================
    PROCEDURE clear_user_context IS
    BEGIN
        DBMS_SESSION.CLEAR_CONTEXT('gms_context');
    END clear_user_context;

    -- =====================================================
    -- GET CURRENT USER INFO
    -- =====================================================
    FUNCTION get_user_type RETURN VARCHAR2 IS
    BEGIN
        RETURN SYS_CONTEXT('gms_context', 'user_type');
    END get_user_type;

    FUNCTION get_user_id RETURN VARCHAR2 IS
    BEGIN
        RETURN SYS_CONTEXT('gms_context', 'user_id');
    END get_user_id;

    -- =====================================================
    -- STUDENT TABLE POLICY
    -- Students: See only their own record
    -- Lecturers: See students in their classes
    -- Admin: See all
    -- =====================================================
    FUNCTION student_policy(
        p_schema VARCHAR2,
        p_object VARCHAR2
    ) RETURN VARCHAR2 IS
        v_user_type VARCHAR2(50);
        v_user_id VARCHAR2(10);
        v_predicate VARCHAR2(2000);
    BEGIN
        v_user_type := SYS_CONTEXT('gms_context', 'user_type');
        v_user_id := SYS_CONTEXT('gms_context', 'user_id');

        -- No context set = no access
        IF v_user_type IS NULL THEN
            RETURN '1=0';
        END IF;

        -- Admin sees everything
        IF v_user_type = 'Admin' THEN
            RETURN '1=1';
        END IF;

        -- Student sees only their own data
        IF v_user_type = 'Student' THEN
            v_predicate := 'student_id = ''' || v_user_id || '''';
            RETURN v_predicate;
        END IF;

        -- Lecturer sees students in their classes
        IF v_user_type = 'Lecturer' THEN
            v_predicate := 'class_id IN (SELECT class_id FROM classes WHERE lecturer_id = ''' || v_user_id || ''')';
            RETURN v_predicate;
        END IF;

        -- Default: no access
        RETURN '1=0';
    END student_policy;

    -- =====================================================
    -- GRADE TABLE POLICY
    -- Similar logic to student policy
    -- =====================================================
    FUNCTION grade_policy(
        p_schema VARCHAR2,
        p_object VARCHAR2
    ) RETURN VARCHAR2 IS
        v_user_type VARCHAR2(50);
        v_user_id VARCHAR2(10);
        v_predicate VARCHAR2(2000);
    BEGIN
        v_user_type := SYS_CONTEXT('gms_context', 'user_type');
        v_user_id := SYS_CONTEXT('gms_context', 'user_id');

        IF v_user_type IS NULL THEN
            RETURN '1=0';
        END IF;

        IF v_user_type = 'Admin' THEN
            RETURN '1=1';
        END IF;

        -- Student sees only their own grades
        IF v_user_type = 'Student' THEN
            v_predicate := 'student_id = ''' || v_user_id || '''';
            RETURN v_predicate;
        END IF;

        -- Lecturer sees grades for courses they teach
        IF v_user_type = 'Lecturer' THEN
            v_predicate := 'course_id IN (SELECT course_id FROM courses WHERE lecturer_id = ''' || v_user_id || ''')';
            RETURN v_predicate;
        END IF;

        RETURN '1=0';
    END grade_policy;

    -- =====================================================
    -- ENROLLMENT TABLE POLICY
    -- =====================================================
    FUNCTION enrollment_policy(
        p_schema VARCHAR2,
        p_object VARCHAR2
    ) RETURN VARCHAR2 IS
        v_user_type VARCHAR2(50);
        v_user_id VARCHAR2(10);
        v_predicate VARCHAR2(2000);
    BEGIN
        v_user_type := SYS_CONTEXT('gms_context', 'user_type');
        v_user_id := SYS_CONTEXT('gms_context', 'user_id');

        IF v_user_type IS NULL THEN
            RETURN '1=0';
        END IF;

        IF v_user_type = 'Admin' THEN
            RETURN '1=1';
        END IF;

        IF v_user_type = 'Student' THEN
            v_predicate := 'student_id = ''' || v_user_id || '''';
            RETURN v_predicate;
        END IF;

        IF v_user_type = 'Lecturer' THEN
            v_predicate := 'course_id IN (SELECT course_id FROM courses WHERE lecturer_id = ''' || v_user_id || ''')';
            RETURN v_predicate;
        END IF;

        RETURN '1=0';
    END enrollment_policy;

END gms_security_pkg;
/

-- =====================================================
-- STEP 2: CREATE CONTEXT
-- =====================================================
CREATE OR REPLACE CONTEXT gms_context USING GMS_ADMIN.gms_security_pkg;

-- =====================================================
-- STEP 3: APPLY VPD POLICIES
-- =====================================================

-- Policy for STUDENTS table
BEGIN
    -- Drop if exists
    BEGIN
        DBMS_RLS.DROP_POLICY(
            object_schema => 'GMS_ADMIN',
            object_name => 'STUDENTS',
            policy_name => 'student_access_policy'
        );
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    -- Create policy
    DBMS_RLS.ADD_POLICY(
        object_schema => 'GMS_ADMIN',
        object_name => 'STUDENTS',
        policy_name => 'student_access_policy',
        function_schema => 'GMS_ADMIN',
        policy_function => 'gms_security_pkg.student_policy',
        statement_types => 'SELECT, INSERT, UPDATE, DELETE',
        enable => TRUE
    );
END;
/

-- Policy for GRADES table
BEGIN
    BEGIN
        DBMS_RLS.DROP_POLICY(
            object_schema => 'GMS_ADMIN',
            object_name => 'GRADES',
            policy_name => 'grade_access_policy'
        );
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    DBMS_RLS.ADD_POLICY(
        object_schema => 'GMS_ADMIN',
        object_name => 'GRADES',
        policy_name => 'grade_access_policy',
        function_schema => 'GMS_ADMIN',
        policy_function => 'gms_security_pkg.grade_policy',
        statement_types => 'SELECT, INSERT, UPDATE, DELETE',
        enable => TRUE
    );
END;
/

-- Policy for ENROLLMENTS table
BEGIN
    BEGIN
        DBMS_RLS.DROP_POLICY(
            object_schema => 'GMS_ADMIN',
            object_name => 'ENROLLMENTS',
            policy_name => 'enrollment_access_policy'
        );
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    DBMS_RLS.ADD_POLICY(
        object_schema => 'GMS_ADMIN',
        object_name => 'ENROLLMENTS',
        policy_name => 'enrollment_access_policy',
        function_schema => 'GMS_ADMIN',
        policy_function => 'gms_security_pkg.enrollment_policy',
        statement_types => 'SELECT, INSERT, UPDATE, DELETE',
        enable => TRUE
    );
END;
/

-- =====================================================
-- VERIFY VPD POLICIES
-- =====================================================
SELECT object_owner, object_name, policy_name, enable
FROM DBA_POLICIES
WHERE object_owner = 'GMS_ADMIN'
ORDER BY object_name, policy_name;

PROMPT =====================================================
PROMPT VPD Setup Complete!
PROMPT =====================================================
PROMPT Policies applied to: STUDENTS, GRADES, ENROLLMENTS
PROMPT Context: gms_context
PROMPT Package: gms_security_pkg
PROMPT =====================================================

EXIT;
