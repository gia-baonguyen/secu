package edu.university.grademanagement.service;

import edu.university.grademanagement.model.entity.*;
import edu.university.grademanagement.repository.*;
import edu.university.grademanagement.security.UserPrincipal;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Academic Affairs Service
 * Business logic for Academic Affairs operations
 * Academic Affairs has full access to all data
 * Can modify grades after deadline
 * VPD policies grant full access
 */
@Service
public class AcademicAffairsService {

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private LecturerRepository lecturerRepository;

    @Autowired
    private GradeRepository gradeRepository;

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    @Autowired
    private AuditService auditService;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * Get all students in the system
     */
    public List<Student> getAllStudents() {
        return studentRepository.findAll();
    }

    /**
     * Get student by ID
     */
    public Student getStudent(String studentId) {
        return studentRepository.findByStudentId(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found: " + studentId));
    }

    /**
     * Get all lecturers in the system
     */
    public List<Lecturer> getAllLecturers() {
        return lecturerRepository.findAll();
    }

    /**
     * Get lecturer by ID
     */
    public Lecturer getLecturer(String lecturerId) {
        return lecturerRepository.findById(lecturerId)
                .orElseThrow(() -> new RuntimeException("Lecturer not found: " + lecturerId));
    }

    /**
     * Get all grades in the system
     */
    public List<Grade> getAllGrades() {
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
     * Get grade by ID
     */
    public Grade getGrade(Long gradeId) {
        Grade grade = gradeRepository.findById(gradeId)
                .orElseThrow(() -> new RuntimeException("Grade not found: " + gradeId));
        
        if (grade.getEnrollmentId() != null) {
            String courseName = getCourseNameByEnrollmentId(grade.getEnrollmentId());
            grade.setCourseName(courseName);
        }
        return grade;
    }

    /**
     * Get grades for a specific student
     */
    public List<Grade> getStudentGrades(String studentId) {
        // Verify student exists
        getStudent(studentId);

        List<Enrollment> enrollments = enrollmentRepository.findByStudentId(studentId);
        
        return enrollments.stream()
                .map(e -> getFieldValue(e, "enrollmentId"))
                .filter(enrollmentId -> enrollmentId != null)
                .map(enrollmentId -> {
                    var gradeOpt = gradeRepository.findByEnrollmentId((String) enrollmentId);
                    if (gradeOpt.isPresent()) {
                        Grade grade = gradeOpt.get();
                        String courseName = getCourseNameByEnrollmentId((String) enrollmentId);
                        grade.setCourseName(courseName);
                        return grade;
                    }
                    return null;
                })
                .filter(grade -> grade != null)
                .toList();
    }

    /**
     * Update grade
     * Academic Affairs can modify any grade after deadline
     */
    @Transactional
    public Grade updateGrade(Long gradeId, Grade updatedGrade) {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        Grade grade = getGrade(gradeId);

        // Store old values for audit
        String oldValues = String.format("midterm=%s, final=%s, total=%s, letter=%s",
                grade.getMidtermScore(), grade.getFinalScore(), grade.getTotalScore(), grade.getLetterGrade());

        // Update fields
        if (updatedGrade.getMidtermScore() != null) {
            grade.setMidtermScore(updatedGrade.getMidtermScore());
        }
        if (updatedGrade.getFinalScore() != null) {
            grade.setFinalScore(updatedGrade.getFinalScore());
        }

        // Recalculate total score and letter grade
        grade.calculateTotalScore();
        grade.calculateLetterGrade();

        // Update modification info
        grade.setGradeStatus("Modified");
        grade.setModifiedBy(currentUser.getUserId());
        grade.setModifiedDate(LocalDateTime.now());

        if (updatedGrade.getModificationReason() != null) {
            grade.setModificationReason(updatedGrade.getModificationReason());
        }

        Grade savedGrade = gradeRepository.save(grade);

        // Store new values for audit
        String newValues = String.format("midterm=%s, final=%s, total=%s, letter=%s",
                savedGrade.getMidtermScore(), savedGrade.getFinalScore(), savedGrade.getTotalScore(), savedGrade.getLetterGrade());

        // Log audit
        auditService.logUpdate("GRADES", String.valueOf(gradeId), oldValues, newValues);

        return savedGrade;
    }

    /**
     * Approve grade
     */
    @Transactional
    public Grade approveGrade(Long gradeId) {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        Grade grade = getGrade(gradeId);

        grade.setGradeStatus("Approved");
        grade.setApprovedBy(currentUser.getUserId());
        grade.setApprovedDate(LocalDateTime.now());

        Grade savedGrade = gradeRepository.save(grade);

        // Log audit
        auditService.logUpdate("GRADES", String.valueOf(gradeId), "status=Submitted", "status=Approved");

        return savedGrade;
    }

    /**
     * Get all faculties
     */
    public List<Map<String, Object>> getAllFaculties() {
        String sql = "SELECT f.faculty_id, f.faculty_name, " +
                "l.first_name || ' ' || l.last_name AS dean_name, " +
                "(SELECT COUNT(*) FROM GMS_ADMIN.DEPARTMENTS d WHERE d.faculty_id = f.faculty_id) AS department_count " +
                "FROM GMS_ADMIN.FACULTIES f " +
                "LEFT JOIN GMS_ADMIN.LECTURERS l ON f.dean_id = l.lecturer_id " +
                "ORDER BY f.faculty_name";
        return jdbcTemplate.queryForList(sql);
    }

    /**
     * Get all departments
     */
    public List<Map<String, Object>> getAllDepartments() {
        String sql = "SELECT d.department_id, d.department_name, f.faculty_name, " +
                "l.first_name || ' ' || l.last_name AS head_name " +
                "FROM GMS_ADMIN.DEPARTMENTS d " +
                "JOIN GMS_ADMIN.FACULTIES f ON d.faculty_id = f.faculty_id " +
                "LEFT JOIN GMS_ADMIN.LECTURERS l ON d.department_head_id = l.lecturer_id " +
                "ORDER BY f.faculty_name, d.department_name";
        return jdbcTemplate.queryForList(sql);
    }

    /**
     * Get system statistics
     */
    public Map<String, Object> getSystemStatistics() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalStudents", getAllStudents().size());
        stats.put("totalLecturers", getAllLecturers().size());
        stats.put("totalGrades", getAllGrades().size());
        stats.put("totalFaculties", getAllFaculties().size());
        stats.put("totalDepartments", getAllDepartments().size());
        return stats;
    }

    /**
     * Get grade statistics
     */
    public Map<String, Object> getGradeStatistics() {
        Map<String, Object> stats = new HashMap<>();
        
        String sql = "SELECT grade_status, COUNT(*) as count FROM GMS_ADMIN.GRADES GROUP BY grade_status";
        List<Map<String, Object>> statusCounts = jdbcTemplate.queryForList(sql);
        stats.put("byStatus", statusCounts);

        sql = "SELECT " +
                "ROUND(AVG(total_score), 2) as avg_score, " +
                "MIN(total_score) as min_score, " +
                "MAX(total_score) as max_score " +
                "FROM GMS_ADMIN.GRADES WHERE total_score IS NOT NULL";
        Map<String, Object> scoreStats = jdbcTemplate.queryForMap(sql);
        stats.put("scores", scoreStats);

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

    /**
     * Helper method to get field value using reflection
     */
    @SuppressWarnings("unchecked")
    private <T> T getFieldValue(Object obj, String fieldName) {
        try {
            java.lang.reflect.Field field = obj.getClass().getDeclaredField(fieldName);
            field.setAccessible(true);
            return (T) field.get(obj);
        } catch (Exception e) {
            return null;
        }
    }
}

