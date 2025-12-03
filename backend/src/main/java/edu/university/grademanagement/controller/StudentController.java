package edu.university.grademanagement.controller;

import edu.university.grademanagement.dto.ApiResponse;
import edu.university.grademanagement.model.entity.Grade;
import edu.university.grademanagement.model.entity.Student;
import edu.university.grademanagement.service.StudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Student Controller
 * Handles student-specific endpoints
 * All endpoints require STUDENT role
 */
@RestController
@RequestMapping("/students")
@CrossOrigin(origins = "${security.cors.allowed-origins}")
@PreAuthorize("hasRole('STUDENT')")
public class StudentController {

    @Autowired
    private StudentService studentService;

    /**
     * Get my profile
     * GET /students/me
     */
    @GetMapping("/me")
    public ResponseEntity<ApiResponse<Student>> getMyProfile() {
        try {
            Student student = studentService.getMyProfile();
            return ResponseEntity.ok(ApiResponse.success(student));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get profile: " + e.getMessage()));
        }
    }

    /**
     * Get my grades
     * GET /students/me/grades
     */
    @GetMapping("/me/grades")
    public ResponseEntity<ApiResponse<List<Grade>>> getMyGrades() {
        try {
            List<Grade> grades = studentService.getMyGrades();
            return ResponseEntity.ok(ApiResponse.success(grades));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get grades: " + e.getMessage()));
        }
    }

    /**
     * Get my GPA
     * GET /students/me/gpa
     */
    @GetMapping("/me/gpa")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getMyGPA() {
        try {
            Map<String, Object> gpaData = studentService.calculateGPA();
            return ResponseEntity.ok(ApiResponse.success(gpaData));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to calculate GPA: " + e.getMessage()));
        }
    }

    /**
     * Update my profile
     * PUT /students/me
     */
    @PutMapping("/me")
    public ResponseEntity<ApiResponse<Student>> updateMyProfile(@RequestBody Student updatedStudent) {
        try {
            Student student = studentService.updateProfile(updatedStudent);
            return ResponseEntity.ok(ApiResponse.success("Profile updated successfully", student));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to update profile: " + e.getMessage()));
        }
    }
}
