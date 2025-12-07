package edu.university.grademanagement.controller;

import edu.university.grademanagement.dto.ApiResponse;
import edu.university.grademanagement.model.entity.Grade;
import edu.university.grademanagement.model.entity.Lecturer;
import edu.university.grademanagement.model.entity.Student;
import edu.university.grademanagement.service.DeanService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Dean Controller
 * Handles endpoints for dean operations
 * Dean can view all data within their faculty
 * All endpoints require DEAN role
 */
@RestController
@RequestMapping("/dean")
@CrossOrigin(origins = "${security.cors.allowed-origins}")
@PreAuthorize("hasRole('DEAN')")
public class DeanController {

    @Autowired
    private DeanService deanService;

    /**
     * Get faculty information
     * GET /dean/faculty
     */
    @GetMapping("/faculty")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getFacultyInfo() {
        try {
            Map<String, Object> facultyInfo = deanService.getFacultyInfo();
            return ResponseEntity.ok(ApiResponse.success(facultyInfo));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get faculty info: " + e.getMessage()));
        }
    }

    /**
     * Get all students in the faculty
     * GET /dean/students
     */
    @GetMapping("/students")
    public ResponseEntity<ApiResponse<List<Student>>> getFacultyStudents() {
        try {
            List<Student> students = deanService.getFacultyStudents();
            return ResponseEntity.ok(ApiResponse.success(students));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get students: " + e.getMessage()));
        }
    }

    /**
     * Get a specific student
     * GET /dean/students/{studentId}
     */
    @GetMapping("/students/{studentId}")
    public ResponseEntity<ApiResponse<Student>> getStudent(@PathVariable String studentId) {
        try {
            Student student = deanService.getStudent(studentId);
            return ResponseEntity.ok(ApiResponse.success(student));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get student: " + e.getMessage()));
        }
    }

    /**
     * Get grades for a specific student
     * GET /dean/students/{studentId}/grades
     */
    @GetMapping("/students/{studentId}/grades")
    public ResponseEntity<ApiResponse<List<Grade>>> getStudentGrades(@PathVariable String studentId) {
        try {
            List<Grade> grades = deanService.getStudentGrades(studentId);
            return ResponseEntity.ok(ApiResponse.success(grades));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get student grades: " + e.getMessage()));
        }
    }

    /**
     * Get all lecturers in the faculty
     * GET /dean/lecturers
     */
    @GetMapping("/lecturers")
    public ResponseEntity<ApiResponse<List<Lecturer>>> getFacultyLecturers() {
        try {
            List<Lecturer> lecturers = deanService.getFacultyLecturers();
            return ResponseEntity.ok(ApiResponse.success(lecturers));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get lecturers: " + e.getMessage()));
        }
    }

    /**
     * Get a specific lecturer
     * GET /dean/lecturers/{lecturerId}
     */
    @GetMapping("/lecturers/{lecturerId}")
    public ResponseEntity<ApiResponse<Lecturer>> getLecturer(@PathVariable String lecturerId) {
        try {
            Lecturer lecturer = deanService.getLecturer(lecturerId);
            return ResponseEntity.ok(ApiResponse.success(lecturer));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get lecturer: " + e.getMessage()));
        }
    }

    /**
     * Get all grades in the faculty
     * GET /dean/grades
     */
    @GetMapping("/grades")
    public ResponseEntity<ApiResponse<List<Grade>>> getFacultyGrades() {
        try {
            List<Grade> grades = deanService.getFacultyGrades();
            return ResponseEntity.ok(ApiResponse.success(grades));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get grades: " + e.getMessage()));
        }
    }

    /**
     * Get departments in the faculty
     * GET /dean/departments
     */
    @GetMapping("/departments")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getDepartments() {
        try {
            List<Map<String, Object>> departments = deanService.getDepartments();
            return ResponseEntity.ok(ApiResponse.success(departments));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get departments: " + e.getMessage()));
        }
    }

    /**
     * Get faculty statistics
     * GET /dean/statistics
     */
    @GetMapping("/statistics")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getFacultyStatistics() {
        try {
            Map<String, Object> stats = deanService.getFacultyStatistics();
            return ResponseEntity.ok(ApiResponse.success(stats));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get statistics: " + e.getMessage()));
        }
    }
}

