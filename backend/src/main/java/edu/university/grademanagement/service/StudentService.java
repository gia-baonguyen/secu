package edu.university.grademanagement.service;

import edu.university.grademanagement.model.entity.Enrollment;
import edu.university.grademanagement.model.entity.Grade;
import edu.university.grademanagement.model.entity.Student;
import edu.university.grademanagement.repository.EnrollmentRepository;
import edu.university.grademanagement.repository.GradeRepository;
import edu.university.grademanagement.repository.StudentRepository;
import edu.university.grademanagement.security.UserPrincipal;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Student Service
 * Business logic for student operations
 * VPD policies ensure students only see their own data
 */
@Service
public class StudentService {

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    @Autowired
    private GradeRepository gradeRepository;

    @Autowired
    private VpdContextService vpdContextService;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * Get current student's profile
     * VPD policy: Students can only see their own record
     */
    public Student getMyProfile() {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        return studentRepository.findByStudentId(currentUser.getUserId())
                .orElseThrow(() -> new RuntimeException("Student not found"));
    }

    /**
     * Update student profile
     * VPD policy: Students can only update their own record (specific fields)
     */
    public Student updateProfile(Student updatedStudent) {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        Student student = studentRepository.findByStudentId(currentUser.getUserId())
                .orElseThrow(() -> new RuntimeException("Student not found"));

        // Students can only update specific fields (not ID, class, status, etc.)
        // Update allowed fields using reflection
        updateField(student, updatedStudent, "email");
        updateField(student, updatedStudent, "phoneNumber");
        updateField(student, updatedStudent, "contactAddress");

        return studentRepository.save(student);
    }

    /**
     * Get all enrollments for current student
     * VPD policy: Students only see their own enrollments
     */
    public List<Enrollment> getMyEnrollments() {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        return enrollmentRepository.findByStudentId(currentUser.getUserId());
    }

    /**
     * Get all grades for current student
     * VPD policy: Students only see their own grades
     */
    public List<Grade> getMyGrades() {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        // Get all enrollments
        List<Enrollment> enrollments = enrollmentRepository.findByStudentId(currentUser.getUserId());

        // Get grades for each enrollment and set course name
        // Note: This could be optimized with a custom query
        return enrollments.stream()
                .map(e -> this.<String>getFieldValue(e, "enrollmentId"))
                .filter(enrollmentId -> enrollmentId != null)
                .map(enrollmentId -> {
                    var gradeOpt = gradeRepository.findByEnrollmentId(enrollmentId);
                    if (gradeOpt.isPresent()) {
                        Grade grade = gradeOpt.get();
                        // Get course name from enrollment -> section -> course
                        String courseName = getCourseNameByEnrollmentId(enrollmentId);
                        grade.setCourseName(courseName);
                        return grade;
                    }
                    return null;
                })
                .filter(grade -> grade != null)
                .toList();
    }

    /**
     * Get course name by enrollment ID
     * Query: Enrollment -> CourseSection -> Course
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
     * Calculate GPA for current student
     * Formula: Sum(grade * credits) / Sum(credits)
     */
    public Map<String, Object> calculateGPA() {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        List<Grade> grades = getMyGrades();

        if (grades.isEmpty()) {
            Map<String, Object> result = new HashMap<>();
            result.put("gpa", 0.0);
            result.put("totalCredits", 0);
            result.put("coursesCompleted", 0);
            result.put("message", "No grades available");
            return result;
        }

        // Calculate GPA (simplified - assumes all courses have equal weight)
        // In production, you'd fetch course credits from COURSE_SECTIONS table
        BigDecimal totalScore = BigDecimal.ZERO;
        int courseCount = 0;

        for (Grade grade : grades) {
            BigDecimal totalScoreValue = getFieldValue(grade, "totalScore");
            if (totalScoreValue != null && totalScoreValue.compareTo(BigDecimal.ZERO) > 0) {
                totalScore = totalScore.add(totalScoreValue);
                courseCount++;
            }
        }

        double gpa = 0.0;
        if (courseCount > 0) {
            gpa = totalScore.divide(BigDecimal.valueOf(courseCount), 2, RoundingMode.HALF_UP).doubleValue();
        }

        Map<String, Object> result = new HashMap<>();
        result.put("gpa", gpa);
        result.put("totalCredits", courseCount * 3); // Assuming 3 credits per course
        result.put("coursesCompleted", courseCount);
        result.put("grades", grades);

        return result;
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
     * Helper method to update field using reflection
     */
    private void updateField(Student target, Student source, String fieldName) {
        try {
            java.lang.reflect.Field field = Student.class.getDeclaredField(fieldName);
            field.setAccessible(true);
            Object value = field.get(source);
            if (value != null) {
                field.set(target, value);
            }
        } catch (Exception e) {
            // Field doesn't exist or can't be updated
        }
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
