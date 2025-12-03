package edu.university.grademanagement.service;

import edu.university.grademanagement.model.entity.Enrollment;
import edu.university.grademanagement.model.entity.Grade;
import edu.university.grademanagement.model.entity.Student;
import edu.university.grademanagement.repository.EnrollmentRepository;
import edu.university.grademanagement.repository.GradeRepository;
import edu.university.grademanagement.repository.StudentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

/**
 * Admin Service
 * Business logic for admin operations
 * Admins have full access to all data (bypasses VPD policies or has admin predicate)
 */
@Service
public class AdminService {

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private GradeRepository gradeRepository;

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    /**
     * Get all students (Admin only)
     * Returns list of all students in the system
     */
    public List<Student> getAllStudents() {
        return studentRepository.findAll();
    }

    /**
     * Get specific student by ID (Admin only)
     */
    public Student getStudentById(String studentId) {
        return studentRepository.findByStudentId(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found: " + studentId));
    }

    /**
     * Get all grades (Admin only)
     * Returns list of all grades in the system
     */
    public List<Grade> getAllGrades() {
        return gradeRepository.findAll();
    }

    /**
     * Get grades for specific student (Admin only)
     * Grades are linked through enrollments
     */
    public List<Grade> getGradesByStudentId(String studentId) {
        // Verify student exists
        studentRepository.findByStudentId(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found: " + studentId));

        // Get all enrollments for this student
        List<Enrollment> enrollments = enrollmentRepository.findByStudentId(studentId);

        // Get grades for each enrollment
        List<Grade> grades = new ArrayList<>();
        for (Enrollment enroll : enrollments) {
            // Use reflection to get enrollmentId field
            try {
                java.lang.reflect.Field field = Enrollment.class.getDeclaredField("enrollmentId");
                field.setAccessible(true);
                String enrollmentId = (String) field.get(enroll);
                if (enrollmentId != null) {
                    gradeRepository.findByEnrollmentId(enrollmentId)
                            .ifPresent(grades::add);
                }
            } catch (Exception e) {
                // Skip this enrollment if can't access field
            }
        }

        return grades;
    }
}
