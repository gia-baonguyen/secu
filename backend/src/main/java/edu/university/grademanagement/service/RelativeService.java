package edu.university.grademanagement.service;

import edu.university.grademanagement.model.entity.*;
import edu.university.grademanagement.repository.*;
import edu.university.grademanagement.security.UserPrincipal;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Relative Service
 * Business logic for relative (parent/guardian) operations
 * 
 * SECURITY POLICY:
 * - Relatives can ONLY view GRADES of their linked children
 * - Relatives CANNOT see student personal info (first_name, last_name, etc.)
 * - This is column-level security implemented at application layer
 *   (VPD only provides row-level security)
 */
@Service
public class RelativeService {

    @Autowired
    private RelativeRepository relativeRepository;

    @Autowired
    private StudentRelativeRepository studentRelativeRepository;

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
     * 
     * SECURITY POLICY:
     * - VPD blocks Relative from accessing STUDENTS table
     * - So we query ONLY from STUDENT_RELATIVES table (which Relative has access)
     * - Returns only student_id, NO personal info (first_name, last_name, etc.)
     */
    public List<Student> getMyChildren() {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        // Query ONLY from STUDENT_RELATIVES table (VPD allows this)
        // DO NOT query from STUDENTS table (VPD blocks this for Relative)
        String sql = "SELECT sr.student_id, sr.relationship " +
                     "FROM GMS_ADMIN.STUDENT_RELATIVES sr " +
                     "WHERE sr.relative_id = ?";
        
        List<Student> children = jdbcTemplate.query(sql, (rs, rowNum) -> {
            Student student = new Student();
            student.setStudentId(rs.getString("student_id"));
            // All other fields are hidden for privacy
            student.setFirstName("***");
            student.setLastName("***");
            student.setClassId(null);  // Cannot access STUDENTS table
            student.setStudentStatus("ACTIVE");  // Default
            return student;
        }, currentUser.getUserId());

        return children;
    }

    /**
     * Get a specific child's information
     * 
     * SECURITY: VPD blocks access to STUDENTS table
     * Returns ONLY student_id from STUDENT_RELATIVES
     */
    public Student getChild(String studentId) {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        // Verify this student is linked to the relative using STUDENT_RELATIVES
        String sql = "SELECT sr.student_id, sr.relationship " +
                     "FROM GMS_ADMIN.STUDENT_RELATIVES sr " +
                     "WHERE sr.student_id = ? AND sr.relative_id = ?";
        
        List<Student> results = jdbcTemplate.query(sql, (rs, rowNum) -> {
            Student student = new Student();
            student.setStudentId(rs.getString("student_id"));
            student.setFirstName("***");
            student.setLastName("***");
            student.setStudentStatus("ACTIVE");
            return student;
        }, studentId, currentUser.getUserId());

        if (results.isEmpty()) {
            throw new RuntimeException("Access denied: Student is not linked to you");
        }
        
        return results.get(0);
    }

    /**
     * Get grades for a specific child
     * 
     * SECURITY: VPD allows Relative to see GRADES of their children
     * Query directly from GRADES table with join to verify relationship
     */
    public List<Grade> getChildGrades(String studentId) {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        // Verify this student is linked to the relative first
        if (!isMyChild(studentId)) {
            throw new RuntimeException("Access denied: Student is not linked to you");
        }

        // Query GRADES directly with course info
        // VPD policy on GRADES allows Relative to see grades of their children
        String sql = "SELECT g.grade_id, g.enrollment_id, g.midterm_score, g.final_score, " +
                     "g.total_score, g.letter_grade, g.grade_status, " +
                     "c.course_name, c.course_id " +
                     "FROM GMS_ADMIN.GRADES g " +
                     "JOIN GMS_ADMIN.ENROLLMENTS e ON g.enrollment_id = e.enrollment_id " +
                     "JOIN GMS_ADMIN.COURSE_SECTIONS cs ON e.section_id = cs.section_id " +
                     "JOIN GMS_ADMIN.COURSES c ON cs.course_id = c.course_id " +
                     "WHERE e.student_id = ?";

        List<Grade> grades = jdbcTemplate.query(sql, (rs, rowNum) -> {
            Grade grade = new Grade();
            grade.setGradeId(rs.getLong("grade_id"));
            grade.setEnrollmentId(rs.getString("enrollment_id"));
            grade.setMidtermScore(rs.getBigDecimal("midterm_score"));
            grade.setFinalScore(rs.getBigDecimal("final_score"));
            grade.setTotalScore(rs.getBigDecimal("total_score"));
            grade.setLetterGrade(rs.getString("letter_grade"));
            grade.setGradeStatus(rs.getString("grade_status"));
            grade.setCourseName(rs.getString("course_name"));
            return grade;
        }, studentId);

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
     * Uses direct SQL to STUDENT_RELATIVES table (VPD allows this)
     */
    private boolean isMyChild(String studentId) {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            return false;
        }
        
        String sql = "SELECT COUNT(*) FROM GMS_ADMIN.STUDENT_RELATIVES " +
                     "WHERE student_id = ? AND relative_id = ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, studentId, currentUser.getUserId());
        return count != null && count > 0;
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

