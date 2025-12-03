package edu.university.grademanagement.controller;

import edu.university.grademanagement.dto.ApiResponse;
import edu.university.grademanagement.model.entity.Grade;
import edu.university.grademanagement.model.entity.Student;
import edu.university.grademanagement.service.AdminService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Admin Controller
 * Handles admin-only endpoints for system-wide data access
 * All endpoints require ADMIN role
 */
@RestController
@RequestMapping("")
@CrossOrigin(origins = "${security.cors.allowed-origins}")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    @Autowired
    private AdminService adminService;

    /**
     * Get all students in the system
     * GET /students
     * Admin only
     */
    @GetMapping("/students")
    public ResponseEntity<ApiResponse<List<Student>>> getAllStudents() {
        try {
            List<Student> students = adminService.getAllStudents();
            return ResponseEntity.ok(ApiResponse.success(students));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get students: " + e.getMessage()));
        }
    }

    /**
     * Get specific student by ID
     * GET /students/{id}
     * Admin only
     */
    @GetMapping("/students/{studentId}")
    public ResponseEntity<ApiResponse<Student>> getStudentById(@PathVariable String studentId) {
        try {
            Student student = adminService.getStudentById(studentId);
            return ResponseEntity.ok(ApiResponse.success(student));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get student: " + e.getMessage()));
        }
    }

    /**
     * Get all grades in the system
     * GET /grades
     * Admin only
     */
    @GetMapping("/grades")
    public ResponseEntity<ApiResponse<List<Grade>>> getAllGrades() {
        try {
            List<Grade> grades = adminService.getAllGrades();
            return ResponseEntity.ok(ApiResponse.success(grades));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get grades: " + e.getMessage()));
        }
    }

    /**
     * Get grades for a specific student
     * GET /students/{studentId}/grades
     * Admin only
     */
    @GetMapping("/students/{studentId}/grades")
    public ResponseEntity<ApiResponse<List<Grade>>> getStudentGrades(@PathVariable String studentId) {
        try {
            List<Grade> grades = adminService.getGradesByStudentId(studentId);
            return ResponseEntity.ok(ApiResponse.success(grades));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get student grades: " + e.getMessage()));
        }
    }
}
