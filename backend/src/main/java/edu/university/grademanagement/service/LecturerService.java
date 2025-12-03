package edu.university.grademanagement.service;

import edu.university.grademanagement.model.entity.Grade;
import edu.university.grademanagement.model.entity.Lecturer;
import edu.university.grademanagement.model.entity.Student;
import edu.university.grademanagement.repository.GradeRepository;
import edu.university.grademanagement.repository.LecturerRepository;
import edu.university.grademanagement.repository.StudentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

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
        return gradeRepository.findAll();
    }

    /**
     * Get specific student
     * VPD will check if student is in lecturer's courses
     */
    public Student getStudentById(String studentId) {
        return studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found or not in your courses: " + studentId));
    }
}
