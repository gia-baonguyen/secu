package edu.university.grademanagement.service;

import edu.university.grademanagement.model.entity.*;
import edu.university.grademanagement.repository.*;
import edu.university.grademanagement.security.UserPrincipal;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

/**
 * Relative Service
 * Business logic for relative (parent/guardian) operations
 * VPD policies ensure relatives only see their children's data
 */
@Service
public class RelativeService {

    @Autowired
    private RelativeRepository relativeRepository;

    @Autowired
    private StudentRelativeRepository studentRelativeRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private GradeRepository gradeRepository;

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * Get current relative's profile
     */
    public Relative getMyProfile() {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        return relativeRepository.findByRelativeId(currentUser.getUserId())
                .orElseThrow(() -> new RuntimeException("Relative not found"));
    }

    /**
     * Update relative profile
     */
    public Relative updateProfile(Relative updatedRelative) {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        Relative relative = relativeRepository.findByRelativeId(currentUser.getUserId())
                .orElseThrow(() -> new RuntimeException("Relative not found"));

        // Update allowed fields
        if (updatedRelative.getPhoneNumber() != null) {
            relative.setPhoneNumber(updatedRelative.getPhoneNumber());
        }
        if (updatedRelative.getEmail() != null) {
            relative.setEmail(updatedRelative.getEmail());
        }
        if (updatedRelative.getContactAddress() != null) {
            relative.setContactAddress(updatedRelative.getContactAddress());
        }

        return relativeRepository.save(relative);
    }

    /**
     * Get all children (students) linked to this relative
     */
    public List<Student> getMyChildren() {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        // Get all student-relative relationships for this relative
        List<StudentRelative> relationships = studentRelativeRepository.findByRelativeId(currentUser.getUserId());

        // Get student details for each relationship
        List<Student> children = new ArrayList<>();
        for (StudentRelative sr : relationships) {
            studentRepository.findByStudentId(sr.getStudentId())
                    .ifPresent(children::add);
        }

        return children;
    }

    /**
     * Get a specific child's information
     */
    public Student getChild(String studentId) {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        // Verify this student is linked to the relative
        if (!isMyChild(studentId)) {
            throw new RuntimeException("Access denied: Student is not linked to you");
        }

        return studentRepository.findByStudentId(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found"));
    }

    /**
     * Get grades for a specific child
     * VPD policy: Relatives can only see grades of their linked children
     */
    public List<Grade> getChildGrades(String studentId) {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        // Verify this student is linked to the relative
        if (!isMyChild(studentId)) {
            throw new RuntimeException("Access denied: Student is not linked to you");
        }

        // Get all enrollments for this student
        List<Enrollment> enrollments = enrollmentRepository.findByStudentId(studentId);

        // Get grades for each enrollment
        List<Grade> grades = new ArrayList<>();
        for (Enrollment enrollment : enrollments) {
            String enrollmentId = getFieldValue(enrollment, "enrollmentId");
            if (enrollmentId != null) {
                gradeRepository.findByEnrollmentId(enrollmentId).ifPresent(grade -> {
                    // Set course name
                    String courseName = getCourseNameByEnrollmentId(enrollmentId);
                    grade.setCourseName(courseName);
                    grades.add(grade);
                });
            }
        }

        return grades;
    }

    /**
     * Get relationship type with a specific child
     */
    public String getRelationship(String studentId) {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        StudentRelativeId id = new StudentRelativeId(studentId, currentUser.getUserId());
        return studentRelativeRepository.findById(id)
                .map(StudentRelative::getRelationship)
                .orElseThrow(() -> new RuntimeException("Relationship not found"));
    }

    /**
     * Check if a student is linked to the current relative
     */
    private boolean isMyChild(String studentId) {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            return false;
        }
        return studentRelativeRepository.existsByStudentIdAndRelativeId(studentId, currentUser.getUserId());
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

