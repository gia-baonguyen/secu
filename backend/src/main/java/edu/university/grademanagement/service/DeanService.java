package edu.university.grademanagement.service;

import edu.university.grademanagement.model.entity.*;
import edu.university.grademanagement.repository.*;
import edu.university.grademanagement.security.UserPrincipal;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Dean Service
 * Business logic for Dean operations
 * Dean can view all data within their faculty
 * VPD policies filter data to faculty scope
 */
@Service
public class DeanService {

    @Autowired
    private LecturerRepository lecturerRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private GradeRepository gradeRepository;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * Get faculty information for current dean
     */
    public Map<String, Object> getFacultyInfo() {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        String sql = "SELECT f.faculty_id, f.faculty_name, f.established_date, f.description, " +
                "l.first_name || ' ' || l.last_name AS dean_name " +
                "FROM GMS_ADMIN.FACULTIES f " +
                "LEFT JOIN GMS_ADMIN.LECTURERS l ON f.dean_id = l.lecturer_id " +
                "WHERE f.dean_id = ?";

        try {
            return jdbcTemplate.queryForMap(sql, currentUser.getUserId());
        } catch (Exception e) {
            throw new RuntimeException("Faculty not found for dean: " + currentUser.getUserId());
        }
    }

    /**
     * Get all students in the faculty
     * VPD filters to students in faculty's classes
     */
    public List<Student> getFacultyStudents() {
        // VPD policy will automatically filter to faculty scope
        return studentRepository.findAll();
    }

    /**
     * Get all lecturers in the faculty
     * VPD filters to lecturers in faculty's departments
     */
    public List<Lecturer> getFacultyLecturers() {
        // VPD policy will automatically filter to faculty scope
        return lecturerRepository.findAll();
    }

    /**
     * Get all grades in the faculty
     * VPD filters to grades from faculty's courses
     */
    public List<Grade> getFacultyGrades() {
        List<Grade> grades = gradeRepository.findAll();
        // Set course name for each grade
        grades.forEach(grade -> {
            if (grade.getEnrollmentId() != null) {
                String courseName = getCourseNameByEnrollmentId(grade.getEnrollmentId());
                grade.setCourseName(courseName);
            }
        });
        return grades;
    }

    /**
     * Get student by ID (within faculty)
     */
    public Student getStudent(String studentId) {
        return studentRepository.findByStudentId(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found or not in your faculty: " + studentId));
    }

    /**
     * Get lecturer by ID (within faculty)
     */
    public Lecturer getLecturer(String lecturerId) {
        return lecturerRepository.findById(lecturerId)
                .orElseThrow(() -> new RuntimeException("Lecturer not found or not in your faculty: " + lecturerId));
    }

    /**
     * Get grades for a specific student (within faculty)
     */
    public List<Grade> getStudentGrades(String studentId) {
        // Verify student is in faculty (VPD will handle this)
        getStudent(studentId);

        String sql = "SELECT g.* FROM GMS_ADMIN.GRADES g " +
                "JOIN GMS_ADMIN.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id " +
                "WHERE e.student_id = ?";

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
        }, studentId);
    }

    /**
     * Get departments in the faculty
     */
    public List<Map<String, Object>> getDepartments() {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        String sql = "SELECT d.department_id, d.department_name, d.established_date, " +
                "l.first_name || ' ' || l.last_name AS head_name, " +
                "(SELECT COUNT(*) FROM GMS_ADMIN.LECTURERS l2 WHERE l2.department_id = d.department_id) AS lecturer_count " +
                "FROM GMS_ADMIN.DEPARTMENTS d " +
                "LEFT JOIN GMS_ADMIN.LECTURERS l ON d.department_head_id = l.lecturer_id " +
                "JOIN GMS_ADMIN.FACULTIES f ON d.faculty_id = f.faculty_id " +
                "WHERE f.dean_id = ? " +
                "ORDER BY d.department_name";

        return jdbcTemplate.queryForList(sql, currentUser.getUserId());
    }

    /**
     * Get faculty statistics
     */
    public Map<String, Object> getFacultyStatistics() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalStudents", getFacultyStudents().size());
        stats.put("totalLecturers", getFacultyLecturers().size());
        stats.put("totalGrades", getFacultyGrades().size());
        stats.put("departments", getDepartments().size());
        return stats;
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

