package edu.university.grademanagement.service;

import edu.university.grademanagement.model.entity.Enrollment;
import edu.university.grademanagement.model.entity.Grade;
import edu.university.grademanagement.model.entity.Lecturer;
import edu.university.grademanagement.model.entity.Student;
import edu.university.grademanagement.repository.EnrollmentRepository;
import edu.university.grademanagement.repository.GradeRepository;
import edu.university.grademanagement.repository.LecturerRepository;
import edu.university.grademanagement.repository.StudentRepository;
import edu.university.grademanagement.security.UserPrincipal;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Service for Lecturer operations
 * All data access is filtered by VPD policies
 */
@Service
public class LecturerService {

    @Autowired
    private LecturerRepository lecturerRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private GradeRepository gradeRepository;

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * Get lecturer by ID
     * VPD will filter based on logged-in lecturer
     */
    public Lecturer getLecturerById(String lecturerId) {
        return lecturerRepository.findById(lecturerId)
                .orElseThrow(() -> new RuntimeException("Lecturer not found: " + lecturerId));
    }

    /**
     * Get all students
     * VPD will filter to show only students in lecturer's courses
     */
    public List<Student> getMyStudents() {
        return studentRepository.findAll();
    }

    /**
     * Get all grades
     * VPD will filter to show only grades for lecturer's courses
     */
    public List<Grade> getMyGrades() {
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
     * Get specific student
     * VPD will check if student is in lecturer's courses
     */
    public Student getStudentById(String studentId) {
        return studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found or not in your courses: " + studentId));
    }

    /**
     * Get grades for a specific student
     * VPD will filter to show only grades for lecturer's courses
     */
    public List<Grade> getStudentGrades(String studentId) {
        // Verify student exists and is in lecturer's courses
        getStudentById(studentId);

        // Get all enrollments for this student
        List<Enrollment> enrollments = enrollmentRepository.findByStudentId(studentId);

        // Get grades for each enrollment and set course name
        // VPD will ensure only grades for lecturer's courses are returned
        return enrollments.stream()
                .map(enrollment -> {
                    try {
                        java.lang.reflect.Field field = Enrollment.class.getDeclaredField("enrollmentId");
                        field.setAccessible(true);
                        return (String) field.get(enrollment);
                    } catch (Exception e) {
                        return null;
                    }
                })
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
     * Update lecturer profile
     * Lecturers can only update specific fields (email, phoneNumber, contactAddress)
     */
    public Lecturer updateProfile(Lecturer updatedLecturer) {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        Lecturer lecturer = lecturerRepository.findById(currentUser.getUserId())
                .orElseThrow(() -> new RuntimeException("Lecturer not found"));

        // Lecturers can only update specific fields
        updateField(lecturer, updatedLecturer, "email");
        updateField(lecturer, updatedLecturer, "phoneNumber");
        updateField(lecturer, updatedLecturer, "contactAddress");

        return lecturerRepository.save(lecturer);
    }

    /**
     * Update grade
     * Lecturers can only update grades for their courses and before deadline
     * VPD will ensure only authorized grades can be updated
     */
    public Grade updateGrade(Long gradeId, Grade updatedGrade) {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        // Get existing grade
        Grade grade = gradeRepository.findById(gradeId)
                .orElseThrow(() -> new RuntimeException("Grade not found"));

        // VPD will ensure lecturer can only update grades for their courses
        // Update allowed fields
        if (updatedGrade.getMidtermScore() != null) {
            grade.setMidtermScore(updatedGrade.getMidtermScore());
        }
        if (updatedGrade.getFinalScore() != null) {
            grade.setFinalScore(updatedGrade.getFinalScore());
        }

        // Recalculate total score and letter grade
        grade.calculateTotalScore();
        grade.calculateLetterGrade();

        // Update status and submitted info
        grade.setGradeStatus("Submitted");
        grade.setSubmittedBy(currentUser.getUserId());
        grade.setSubmittedDate(LocalDateTime.now());

        return gradeRepository.save(grade);
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
    private void updateField(Lecturer target, Lecturer source, String fieldName) {
        try {
            java.lang.reflect.Field field = Lecturer.class.getDeclaredField(fieldName);
            field.setAccessible(true);
            Object value = field.get(source);
            if (value != null) {
                field.set(target, value);
            }
        } catch (Exception e) {
            // Field doesn't exist or can't be updated
        }
    }
}
