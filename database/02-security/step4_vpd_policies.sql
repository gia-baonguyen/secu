-- =============================================
-- UNIVERSITY GRADE MANAGEMENT SYSTEM
-- Virtual Private Database (VPD) Security Policies (FINAL FIXED VERSION)
-- Row-level security implementation
-- =============================================

ALTER SESSION SET CONTAINER = ORCLPDB;
ALTER SESSION SET CURRENT_SCHEMA = GMS_ADMIN;

-- =============================================
-- 1. CREATE SECURITY CONTEXT
-- =============================================
CREATE OR REPLACE CONTEXT gms_context USING gms_admin.gms_security_pkg;

-- =============================================
-- 2. SECURITY PACKAGE FOR VPD
-- =============================================
CREATE OR REPLACE PACKAGE gms_security_pkg AS
    -- Set user context
    PROCEDURE set_user_context(
        p_user_id VARCHAR2,
        p_user_type VARCHAR2
    );

    -- Clear user context
    PROCEDURE clear_user_context;

    -- Get current user type
    FUNCTION get_user_type RETURN VARCHAR2;

    -- Get current user id
    FUNCTION get_user_id RETURN VARCHAR2;

    -- Check if grade submission deadline has passed
    FUNCTION is_after_deadline(
        p_semester VARCHAR2,
        p_academic_year NUMBER
    ) RETURN BOOLEAN;

    -- Policy functions for different tables
    FUNCTION student_policy(
        p_schema VARCHAR2,
        p_object VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION grade_policy(
        p_schema VARCHAR2,
        p_object VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION relative_policy(
        p_schema VARCHAR2,
        p_object VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION lecturer_grade_policy(
        p_schema VARCHAR2,
        p_object VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION department_policy(
        p_schema VARCHAR2,
        p_object VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION faculty_policy(
        p_schema VARCHAR2,
        p_object VARCHAR2
    ) RETURN VARCHAR2;
END gms_security_pkg;
/

CREATE OR REPLACE PACKAGE BODY gms_security_pkg AS

    -- =============================================
    -- Set user context
    -- =============================================
    PROCEDURE set_user_context(
        p_user_id VARCHAR2,
        p_user_type VARCHAR2
    ) IS
        v_dept_id VARCHAR2(10);
        v_faculty_id VARCHAR2(10);
        v_class_id VARCHAR2(10);
    BEGIN
        -- Set basic context
        DBMS_SESSION.SET_CONTEXT('gms_context', 'user_id', p_user_id);
        DBMS_SESSION.SET_CONTEXT('gms_context', 'user_type', p_user_type);

        -- Set additional context based on user type
        IF p_user_type = 'Student' THEN
            -- Get student's class
            SELECT class_id INTO v_class_id
            FROM gms_admin.STUDENTS
            WHERE student_id = p_user_id;

            DBMS_SESSION.SET_CONTEXT('gms_context', 'class_id', v_class_id);

            -- Get student's faculty
            SELECT c.faculty_id INTO v_faculty_id
            FROM gms_admin.STUDENTS s
            JOIN gms_admin.CLASSES c ON s.class_id = c.class_id
            WHERE s.student_id = p_user_id;

            DBMS_SESSION.SET_CONTEXT('gms_context', 'faculty_id', v_faculty_id);

        ELSIF p_user_type = 'Lecturer' THEN
            -- Get lecturer's department
            SELECT department_id INTO v_dept_id
            FROM gms_admin.LECTURERS
            WHERE lecturer_id = p_user_id;

            DBMS_SESSION.SET_CONTEXT('gms_context', 'department_id', v_dept_id);

            -- Get lecturer's faculty
            SELECT d.faculty_id INTO v_faculty_id
            FROM gms_admin.LECTURERS l
            JOIN gms_admin.DEPARTMENTS d ON l.department_id = d.department_id
            WHERE l.lecturer_id = p_user_id;

            DBMS_SESSION.SET_CONTEXT('gms_context', 'faculty_id', v_faculty_id);

        ELSIF p_user_type = 'Department_Head' THEN
            -- Get department head's department
            SELECT department_id INTO v_dept_id
            FROM gms_admin.DEPARTMENTS
            WHERE department_head_id = p_user_id;

            DBMS_SESSION.SET_CONTEXT('gms_context', 'department_id', v_dept_id);

            -- Get faculty
            SELECT faculty_id INTO v_faculty_id
            FROM gms_admin.DEPARTMENTS
            WHERE department_head_id = p_user_id;

            DBMS_SESSION.SET_CONTEXT('gms_context', 'faculty_id', v_faculty_id);

        ELSIF p_user_type = 'Dean' THEN
            -- Get dean's faculty
            SELECT faculty_id INTO v_faculty_id
            FROM gms_admin.FACULTIES
            WHERE dean_id = p_user_id;

            DBMS_SESSION.SET_CONTEXT('gms_context', 'faculty_id', v_faculty_id);
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- User not found in respective table
            NULL;
        WHEN OTHERS THEN
            RAISE;
    END set_user_context;

    -- =============================================
    -- Clear user context
    -- =============================================
    PROCEDURE clear_user_context IS
    BEGIN
        DBMS_SESSION.CLEAR_CONTEXT('gms_context');
    END clear_user_context;

    -- =============================================
    -- Get current user type
    -- =============================================
    FUNCTION get_user_type RETURN VARCHAR2 IS
    BEGIN
        RETURN SYS_CONTEXT('gms_context', 'user_type');
    END get_user_type;

    -- =============================================
    -- Get current user id
    -- =============================================
    FUNCTION get_user_id RETURN VARCHAR2 IS
    BEGIN
        RETURN SYS_CONTEXT('gms_context', 'user_id');
    END get_user_id;

    -- =============================================
    -- Check if after grade submission deadline
    -- =============================================
    FUNCTION is_after_deadline(
        p_semester VARCHAR2,
        p_academic_year NUMBER
    ) RETURN BOOLEAN IS
        v_deadline DATE;
    BEGIN
        SELECT submission_deadline INTO v_deadline
        FROM gms_admin.GRADE_SUBMISSION_DEADLINES
        WHERE semester = p_semester
        AND academic_year = p_academic_year
        AND is_active = 'Y';

        RETURN SYSDATE > v_deadline;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- No deadline found, assume after deadline
            RETURN TRUE;
    END is_after_deadline;

    -- =============================================
    -- Student policy - Students can only see their own data
    -- =============================================
    FUNCTION student_policy(
        p_schema VARCHAR2,
        p_object VARCHAR2
    ) RETURN VARCHAR2 IS
        v_user_type VARCHAR2(50);
        v_user_id VARCHAR2(10);
        v_predicate VARCHAR2(4000);
        v_current_user VARCHAR2(128);
    BEGIN
        -- Bypass VPD for schema owner (GMS_ADMIN) and application user (GMS_APP)
        v_current_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
        IF v_current_user = 'GMS_ADMIN' OR v_current_user = 'GMS_APP' OR v_current_user = p_schema THEN
            RETURN '1=1';  -- Admin and App can see all students
        END IF;

        v_user_type := SYS_CONTEXT('gms_context', 'user_type');
        v_user_id := SYS_CONTEXT('gms_context', 'user_id');

        IF v_user_type = 'Student' THEN
            -- Students can only see their own record
            v_predicate := 'student_id = ''' || v_user_id || '''';
        ELSIF v_user_type = 'Academic_Affairs' OR v_user_type = 'Admin' THEN
            -- Academic Affairs can see all students
            v_predicate := '1=1';
        ELSIF v_user_type = 'Dean' THEN
            -- Deans can see students in their faculty
            v_predicate := 'class_id IN (SELECT class_id FROM gms_admin.CLASSES WHERE faculty_id = ''' ||
                          SYS_CONTEXT('gms_context', 'faculty_id') || ''')';
        ELSIF v_user_type = 'Lecturer' THEN
            -- Lecturers can see students:
            -- 1. In their homeroom class
            -- 2. Enrolled in courses they teach
            v_predicate := '(class_id IN (SELECT class_id FROM gms_admin.CLASSES WHERE homeroom_teacher_id = ''' || v_user_id || ''') ' ||
                          'OR student_id IN (SELECT e.student_id FROM gms_admin.ENROLLMENTS e ' ||
                          'JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id ' ||
                          'WHERE cs.lecturer_id = ''' || v_user_id || '''))';
        ELSE
            -- No access
            v_predicate := '1=0';
        END IF;

        RETURN v_predicate;
    END student_policy;

    -- =============================================
    -- Grade policy - Complex access rules based on role
    -- =============================================
    FUNCTION grade_policy(
        p_schema VARCHAR2,
        p_object VARCHAR2
    ) RETURN VARCHAR2 IS
        v_user_type VARCHAR2(50);
        v_user_id VARCHAR2(10);
        v_predicate VARCHAR2(4000);
        v_current_user VARCHAR2(128);
    BEGIN
        -- Bypass VPD for schema owner (GMS_ADMIN) and application user (GMS_APP)
        v_current_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
        IF v_current_user = 'GMS_ADMIN' OR v_current_user = 'GMS_APP' OR v_current_user = p_schema THEN
            RETURN '1=1';  -- Admin and App can see all grades
        END IF;

        v_user_type := SYS_CONTEXT('gms_context', 'user_type');
        v_user_id := SYS_CONTEXT('gms_context', 'user_id');

        IF v_user_type = 'Student' THEN
            -- Students can only see their own grades
            v_predicate := 'enrollment_id IN (SELECT enrollment_id FROM gms_admin.ENROLLMENTS WHERE student_id = ''' ||
                          v_user_id || ''')';

        ELSIF v_user_type = 'Relative' THEN
            -- Relatives can see their children grades
            v_predicate := 'enrollment_id IN (SELECT e.enrollment_id FROM gms_admin.ENROLLMENTS e ' ||
                          'JOIN gms_admin.STUDENT_RELATIVES sr ON e.student_id = sr.student_id ' ||
                          'WHERE sr.relative_id = ''' || v_user_id || ''')';

        ELSIF v_user_type = 'Lecturer' THEN
            -- Lecturers can see grades for:
            -- 1. Courses they teach
            -- 2. Students in their homeroom class
            v_predicate := '(enrollment_id IN (SELECT e.enrollment_id FROM gms_admin.ENROLLMENTS e ' ||
                          'JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id ' ||
                          'WHERE cs.lecturer_id = ''' || v_user_id || ''') ' ||
                          'OR enrollment_id IN (SELECT e.enrollment_id FROM gms_admin.ENROLLMENTS e ' ||
                          'JOIN gms_admin.STUDENTS s ON e.student_id = s.student_id ' ||
                          'JOIN gms_admin.CLASSES c ON s.class_id = c.class_id ' ||
                          'WHERE c.homeroom_teacher_id = ''' || v_user_id || '''))';

        ELSIF v_user_type = 'Department_Head' THEN
            -- Department heads can see grades for courses in their department
            v_predicate := 'enrollment_id IN (SELECT e.enrollment_id FROM gms_admin.ENROLLMENTS e ' ||
                          'JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id ' ||
                          'JOIN gms_admin.COURSES c ON cs.course_id = c.course_id ' ||
                          'WHERE c.department_id = ''' ||
                          SYS_CONTEXT('gms_context', 'department_id') || ''')';

        ELSIF v_user_type = 'Dean' THEN
            -- Deans can see grades for students in their faculty
            v_predicate := 'enrollment_id IN (SELECT e.enrollment_id FROM gms_admin.ENROLLMENTS e ' ||
                          'JOIN gms_admin.STUDENTS s ON e.student_id = s.student_id ' ||
                          'JOIN gms_admin.CLASSES cl ON s.class_id = cl.class_id ' ||
                          'WHERE cl.faculty_id = ''' ||
                          SYS_CONTEXT('gms_context', 'faculty_id') || ''')';

        ELSIF v_user_type = 'Academic_Affairs' OR v_user_type = 'Admin' THEN
            -- Academic Affairs can see all grades
            v_predicate := '1=1';

        ELSE
            -- No access
            v_predicate := '1=0';
        END IF;

        RETURN v_predicate;
    END grade_policy;

    -- =============================================
    -- Relative policy - Access to children information
    -- =============================================
    FUNCTION relative_policy(
        p_schema VARCHAR2,
        p_object VARCHAR2
    ) RETURN VARCHAR2 IS
        v_user_type VARCHAR2(50);
        v_user_id VARCHAR2(10);
        v_predicate VARCHAR2(4000);
        v_current_user VARCHAR2(128);
    BEGIN
        -- Bypass VPD for schema owner (GMS_ADMIN) and application user (GMS_APP)
        v_current_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
        IF v_current_user = 'GMS_ADMIN' OR v_current_user = 'GMS_APP' OR v_current_user = p_schema THEN
            RETURN '1=1';  -- Admin and App can see all relatives
        END IF;

        v_user_type := SYS_CONTEXT('gms_context', 'user_type');
        v_user_id := SYS_CONTEXT('gms_context', 'user_id');

        IF v_user_type = 'Relative' THEN
            -- Relatives can only see their own record
            v_predicate := 'relative_id = ''' || v_user_id || '''';
        ELSIF v_user_type = 'Academic_Affairs' OR v_user_type = 'Admin' THEN
            -- Academic Affairs can see all relatives
            v_predicate := '1=1';
        ELSE
            -- No access
            v_predicate := '1=0';
        END IF;

        RETURN v_predicate;
    END relative_policy;

    -- =============================================
    -- Lecturer grade editing policy
    -- =============================================
    FUNCTION lecturer_grade_policy(
        p_schema VARCHAR2,
        p_object VARCHAR2
    ) RETURN VARCHAR2 IS
        v_user_type VARCHAR2(50);
        v_user_id VARCHAR2(10);
        v_predicate VARCHAR2(4000);
        v_current_user VARCHAR2(128);
    BEGIN
        -- Bypass VPD for schema owner (GMS_ADMIN) and application user (GMS_APP)
        v_current_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
        IF v_current_user = 'GMS_ADMIN' OR v_current_user = 'GMS_APP' OR v_current_user = p_schema THEN
            RETURN '1=1';  -- Admin and App can edit all grades
        END IF;

        v_user_type := SYS_CONTEXT('gms_context', 'user_type');
        v_user_id := SYS_CONTEXT('gms_context', 'user_id');

        IF v_user_type = 'Lecturer' THEN
            -- Lecturers can only edit grades for current semester before deadline
            v_predicate := 'enrollment_id IN (SELECT e.enrollment_id FROM gms_admin.ENROLLMENTS e ' ||
                          'JOIN gms_admin.COURSE_SECTIONS cs ON e.section_id = cs.section_id ' ||
                          'WHERE cs.lecturer_id = ''' || v_user_id || ''' ' ||
                          'AND EXISTS (SELECT 1 FROM gms_admin.GRADE_SUBMISSION_DEADLINES gsd ' ||
                          'WHERE gsd.semester = cs.semester ' ||
                          'AND gsd.academic_year = cs.academic_year ' ||
                          'AND gsd.submission_deadline > SYSDATE ' ||
                          'AND gsd.is_active = ''Y''))';

        ELSIF v_user_type = 'Academic_Affairs' THEN
            -- Academic Affairs can edit all grades after deadline
            v_predicate := '1=1';
        ELSE
            -- No edit access
            v_predicate := '1=0';
        END IF;

        RETURN v_predicate;
    END lecturer_grade_policy;

    -- =============================================
    -- Department policy
    -- =============================================
    FUNCTION department_policy(
        p_schema VARCHAR2,
        p_object VARCHAR2
    ) RETURN VARCHAR2 IS
        v_user_type VARCHAR2(50);
        v_dept_id VARCHAR2(10);
        v_predicate VARCHAR2(4000);
    BEGIN
        v_user_type := SYS_CONTEXT('gms_context', 'user_type');
        v_dept_id := SYS_CONTEXT('gms_context', 'department_id');

        IF v_user_type = 'Department_Head' AND v_dept_id IS NOT NULL THEN
            v_predicate := 'department_id = ''' || v_dept_id || '''';
        ELSIF v_user_type IN ('Dean', 'Academic_Affairs', 'Admin') THEN
            v_predicate := '1=1';
        ELSE
            v_predicate := '1=0';
        END IF;

        RETURN v_predicate;
    END department_policy;

    -- =============================================
    -- Faculty policy
    -- =============================================
    FUNCTION faculty_policy(
        p_schema VARCHAR2,
        p_object VARCHAR2
    ) RETURN VARCHAR2 IS
        v_user_type VARCHAR2(50);
        v_faculty_id VARCHAR2(10);
        v_predicate VARCHAR2(4000);
    BEGIN
        v_user_type := SYS_CONTEXT('gms_context', 'user_type');
        v_faculty_id := SYS_CONTEXT('gms_context', 'faculty_id');

        IF v_user_type = 'Dean' AND v_faculty_id IS NOT NULL THEN
            v_predicate := 'faculty_id = ''' || v_faculty_id || '''';
        ELSIF v_user_type IN ('Academic_Affairs', 'Admin') THEN
            v_predicate := '1=1';
        ELSE
            v_predicate := '1=0';
        END IF;

        RETURN v_predicate;
    END faculty_policy;

END gms_security_pkg;
/

-- =============================================
-- 3. CREATE VPD POLICIES
-- =============================================

BEGIN
    -- Drop existing policies
    FOR policy IN (SELECT object_name, policy_name
                   FROM dba_policies
                   WHERE object_owner = 'GMS_ADMIN') LOOP
        DBMS_RLS.DROP_POLICY(
            object_schema => 'GMS_ADMIN',
            object_name => policy.object_name,
            policy_name => policy.policy_name
        );
    END LOOP;
END;
/

-- Policy for STUDENTS table
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema => 'GMS_ADMIN',
        object_name => 'STUDENTS',
        policy_name => 'student_access_policy',
        function_schema => 'GMS_ADMIN',
        policy_function => 'gms_security_pkg.student_policy',
        statement_types => 'SELECT',
        enable => TRUE
    );
END;
/

-- Policy for GRADES table (SELECT)
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema => 'GMS_ADMIN',
        object_name => 'GRADES',
        policy_name => 'grade_select_policy',
        function_schema => 'GMS_ADMIN',
        policy_function => 'gms_security_pkg.grade_policy',
        statement_types => 'SELECT',
        enable => TRUE
    );
END;
/

-- Policy for GRADES table (INSERT, UPDATE, DELETE)
-- FIX: Added update_check => TRUE for INSERT policy to prevent ORA-28104
-- Policy cho INSERT
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema => 'GMS_ADMIN',
        object_name => 'GRADES',
        policy_name => 'grade_insert_policy',
        function_schema => 'GMS_ADMIN',
        policy_function => 'gms_security_pkg.lecturer_grade_policy',
        statement_types => 'INSERT',
        update_check => TRUE, -- Quan trọng: Bắt buộc cho INSERT policy
        enable => TRUE
    );
END;
/

-- Policy cho UPDATE
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema => 'GMS_ADMIN',
        object_name => 'GRADES',
        policy_name => 'grade_update_policy',
        function_schema => 'GMS_ADMIN',
        policy_function => 'gms_security_pkg.lecturer_grade_policy',
        statement_types => 'UPDATE',
        enable => TRUE
    );
END;
/

-- Policy cho DELETE
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema => 'GMS_ADMIN',
        object_name => 'GRADES',
        policy_name => 'grade_delete_policy',
        function_schema => 'GMS_ADMIN',
        policy_function => 'gms_security_pkg.lecturer_grade_policy',
        statement_types => 'DELETE',
        enable => TRUE
    );
END;
/

-- Policy for RELATIVES table
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema => 'GMS_ADMIN',
        object_name => 'RELATIVES',
        policy_name => 'relative_access_policy',
        function_schema => 'GMS_ADMIN',
        policy_function => 'gms_security_pkg.relative_policy',
        statement_types => 'SELECT',
        enable => TRUE
    );
END;
/

-- Policy for STUDENT_RELATIVES table
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema => 'GMS_ADMIN',
        object_name => 'STUDENT_RELATIVES',
        policy_name => 'student_relative_policy',
        function_schema => 'GMS_ADMIN',
        policy_function => 'gms_security_pkg.relative_policy',
        statement_types => 'SELECT',
        enable => TRUE
    );
END;
/

-- =============================================
-- 4. GRANT EXECUTE PERMISSIONS
-- =============================================
GRANT EXECUTE ON gms_security_pkg TO PUBLIC;

-- Show created policies
SELECT object_owner, object_name, policy_name, enable
FROM dba_policies
WHERE object_owner = 'GMS_ADMIN'
ORDER BY object_name, policy_name;

COMMIT;

-- =============================================
-- NOTE: VPD CONTEXT SETUP
-- =============================================
-- VPD context is set by the backend application (Spring Boot) via:
-- 1. VpdContextInterceptor: Sets context before each HTTP request
-- 2. VpdContextService: Calls gms_security_pkg.set_user_context() 
--
-- LOGON TRIGGER is NOT needed because:
-- - All database connections go through backend (GMS_APP user)
-- - Backend sets context per-request based on authenticated user
-- - Context is session-specific and set before each query
--
-- If you need direct database access (bypassing backend), you would need
-- to manually call: gms_security_pkg.set_user_context(user_id, user_type)
-- =============================================

PROMPT ========================================
PROMPT VPD policies configured successfully!
PROMPT ========================================
PROMPT
PROMPT NOTE: VPD context is set by backend application
PROMPT No LOGON TRIGGER needed - backend handles context per request
PROMPT ========================================