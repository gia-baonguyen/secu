package edu.university.grademanagement.service;

import edu.university.grademanagement.model.entity.Course;
import edu.university.grademanagement.model.entity.Grade;
import edu.university.grademanagement.model.entity.Lecturer;
import edu.university.grademanagement.security.UserPrincipal;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Department Head Service
 * Business logic for Department Head operations
 * Department Head can view all data within their department
 * VPD policies filter data to department scope
 */
@Service
public class DepartmentHeadService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * Get department information for current department head
     */
    public Map<String, Object> getDepartmentInfo() {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        String sql = "SELECT d.department_id, d.department_name, d.established_date, d.description, " +
                "l.first_name || ' ' || l.last_name AS head_name, " +
                "f.faculty_name " +
                "FROM GMS_ADMIN.DEPARTMENTS d " +
                "LEFT JOIN GMS_ADMIN.LECTURERS l ON d.department_head_id = l.lecturer_id " +
                "JOIN GMS_ADMIN.FACULTIES f ON d.faculty_id = f.faculty_id " +
                "WHERE d.department_head_id = ?";

        try {
            return jdbcTemplate.queryForMap(sql, currentUser.getUserId());
        } catch (Exception e) {
            throw new RuntimeException("Department not found for head: " + currentUser.getUserId());
        }
    }

    /**
     * Get all lecturers in the department
     */
    public List<Lecturer> getDepartmentLecturers() {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        // Get department ID for this head
        String departmentId = getDepartmentId();

        String sql = "SELECT * FROM GMS_ADMIN.LECTURERS WHERE department_id = ?";
        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            Lecturer lecturer = new Lecturer();
            lecturer.setLecturerId(rs.getString("lecturer_id"));
            lecturer.setFirstName(rs.getString("first_name"));
            lecturer.setLastName(rs.getString("last_name"));
            lecturer.setEmail(rs.getString("email"));
            lecturer.setPhoneNumber(rs.getString("phone_number"));
            lecturer.setDepartmentId(rs.getString("department_id"));
            lecturer.setAcademicDegree(rs.getString("academic_degree"));
            lecturer.setSpecialization(rs.getString("specialization"));
            lecturer.setLecturerStatus(rs.getString("lecturer_status"));
            return lecturer;
        }, departmentId);
    }

    /**
     * Get all courses managed by the department
     */
    public List<Course> getDepartmentCourses() {
        String departmentId = getDepartmentId();

        String sql = "SELECT * FROM GMS_ADMIN.COURSES WHERE department_id = ?";
        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            Course course = new Course();
            course.setCourseId(rs.getString("course_id"));
            course.setCourseName(rs.getString("course_name"));
            course.setCredits(rs.getInt("credits"));
            course.setDepartmentId(rs.getString("department_id"));
            course.setCourseType(rs.getString("course_type"));
            course.setDescription(rs.getString("description"));
            return course;
        }, departmentId);
    }

    /**
     * Get grades for all courses in the department
     * VPD filters to grades from department's courses
     */
    public List<Grade> getDepartmentGrades() {
        String departmentId = getDepartmentId();

        String sql = "SELECT g.* FROM GMS_ADMIN.GRADES g " +
                "JOIN GMS_ADMIN.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id " +
                "JOIN GMS_ADMIN.COURSE_SECTIONS cs ON e.section_id = cs.section_id " +
                "JOIN GMS_ADMIN.COURSES c ON cs.course_id = c.course_id " +
                "WHERE c.department_id = ?";

        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            Grade grade = new Grade();
            grade.setGradeId(rs.getLong("grade_id"));
            grade.setEnrollmentId(rs.getString("enrollment_id"));
            grade.setMidtermScore(rs.getBigDecimal("midterm_score"));
            grade.setFinalScore(rs.getBigDecimal("final_score"));
            grade.setTotalScore(rs.getBigDecimal("total_score"));
            grade.setLetterGrade(rs.getString("letter_grade"));
            grade.setGradeStatus(rs.getString("grade_status"));
            // Set course name
            String courseName = getCourseNameByEnrollmentId(grade.getEnrollmentId());
            grade.setCourseName(courseName);
            return grade;
        }, departmentId);
    }

    /**
     * Get students enrolled in department's courses
     */
    public List<Map<String, Object>> getDepartmentStudents() {
        String departmentId = getDepartmentId();

        String sql = "SELECT DISTINCT s.student_id, s.first_name, s.last_name, s.email, " +
                "s.class_id, s.student_status " +
                "FROM GMS_ADMIN.STUDENTS s " +
                "JOIN GMS_ADMIN.ENROLLMENTS e ON s.student_id = e.student_id " +
                "JOIN GMS_ADMIN.COURSE_SECTIONS cs ON e.section_id = cs.section_id " +
                "JOIN GMS_ADMIN.COURSES c ON cs.course_id = c.course_id " +
                "WHERE c.department_id = ? " +
                "ORDER BY s.student_id";

        return jdbcTemplate.queryForList(sql, departmentId);
    }

    /**
     * Get lecturer by ID (within department)
     */
    public Lecturer getLecturer(String lecturerId) {
        String departmentId = getDepartmentId();

        String sql = "SELECT * FROM GMS_ADMIN.LECTURERS WHERE lecturer_id = ? AND department_id = ?";
        List<Lecturer> lecturers = jdbcTemplate.query(sql, (rs, rowNum) -> {
            Lecturer lecturer = new Lecturer();
            lecturer.setLecturerId(rs.getString("lecturer_id"));
            lecturer.setFirstName(rs.getString("first_name"));
            lecturer.setLastName(rs.getString("last_name"));
            lecturer.setEmail(rs.getString("email"));
            lecturer.setDepartmentId(rs.getString("department_id"));
            return lecturer;
        }, lecturerId, departmentId);

        if (lecturers.isEmpty()) {
            throw new RuntimeException("Lecturer not found or not in your department: " + lecturerId);
        }
        return lecturers.get(0);
    }

    /**
     * Get department statistics
     */
    public Map<String, Object> getDepartmentStatistics() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalLecturers", getDepartmentLecturers().size());
        stats.put("totalCourses", getDepartmentCourses().size());
        stats.put("totalGrades", getDepartmentGrades().size());
        stats.put("totalStudents", getDepartmentStudents().size());
        return stats;
    }

    /**
     * Get department ID for current head
     */
    private String getDepartmentId() {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        String sql = "SELECT department_id FROM GMS_ADMIN.DEPARTMENTS WHERE department_head_id = ?";
        try {
            return jdbcTemplate.queryForObject(sql, String.class, currentUser.getUserId());
        } catch (Exception e) {
            throw new RuntimeException("Department not found for head: " + currentUser.getUserId());
        }
    }

    /**
     * Get course name by enrollment ID
     */
    private String getCourseNameByEnrollmentId(String enrollmentId) {
        try {
            String sql = "SELECT c.course_name " +
                    "FROM GMS_ADMIN.ENROLLMENTS e " +
                    "JOIN GMS_ADMIN.COURSE_SECTIONS cs ON e.section_id = cs.section_id " +
                    "JOIN GMS_ADMIN.COURSES c ON cs.course_id = c.course_id " +
                    "WHERE e.enrollment_id = ?";
            String courseName = jdbcTemplate.queryForObject(sql, String.class, enrollmentId);
            return courseName != null ? courseName : "Unknown Course";
        } catch (Exception e) {
            return "Unknown Course";
        }
    }

    /**
     * Get current authenticated user
     */
    private UserPrincipal getCurrentUser() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof UserPrincipal) {
            return (UserPrincipal) authentication.getPrincipal();
        }
        return null;
    }
}

