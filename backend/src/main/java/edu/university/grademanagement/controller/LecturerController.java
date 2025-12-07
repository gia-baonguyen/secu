package edu.university.grademanagement.controller;

import edu.university.grademanagement.dto.ApiResponse;
import edu.university.grademanagement.model.entity.Grade;
import edu.university.grademanagement.model.entity.Lecturer;
import edu.university.grademanagement.model.entity.Student;
import edu.university.grademanagement.security.UserPrincipal;
import edu.university.grademanagement.service.LecturerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controller for Lecturer operations
 * All endpoints require LECTURER role
 * VPD policies automatically filter data based on lecturer's courses
 */
@RestController
@RequestMapping("/lecturers")
@CrossOrigin(origins = "${security.cors.allowed-origins}")
@PreAuthorize("hasRole('LECTURER')")
public class LecturerController {

    @Autowired
    private LecturerService lecturerService;

    /**
     * Get current lecturer's profile
     * GET /api/lecturers/me
     */
    @GetMapping("/me")
    public ResponseEntity<ApiResponse<Lecturer>> getMyProfile(
            @AuthenticationPrincipal UserPrincipal userPrincipal) {
        try {
            String lecturerId = userPrincipal.getUserId();
            Lecturer lecturer = lecturerService.getLecturerById(lecturerId);
            return ResponseEntity.ok(ApiResponse.success(lecturer));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get lecturer profile: " + e.getMessage()));
        }
    }

    /**
     * Get students in lecturer's courses
     * GET /api/lecturers/me/students
     * VPD filters to show only students enrolled in this lecturer's courses
     */
    @GetMapping("/me/students")
    public ResponseEntity<ApiResponse<List<Student>>> getMyStudents() {
        try {
            List<Student> students = lecturerService.getMyStudents();
            return ResponseEntity.ok(ApiResponse.success(students));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get students: " + e.getMessage()));
        }
    }

    /**
     * Get all grades for lecturer's courses
     * GET /api/lecturers/me/grades
     * VPD filters to show only grades for this lecturer's courses
     */
    @GetMapping("/me/grades")
    public ResponseEntity<ApiResponse<List<Grade>>> getMyGrades() {
        try {
            List<Grade> grades = lecturerService.getMyGrades();
            return ResponseEntity.ok(ApiResponse.success(grades));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get grades: " + e.getMessage()));
        }
    }

    /**
     * Get specific student details
     * GET /api/lecturers/me/students/{studentId}
     * VPD checks if student is in lecturer's courses
     */
    @GetMapping("/me/students/{studentId}")
    public ResponseEntity<ApiResponse<Student>> getStudent(@PathVariable String studentId) {
        try {
            Student student = lecturerService.getStudentById(studentId);
            return ResponseEntity.ok(ApiResponse.success(student));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get student: " + e.getMessage()));
        }
    }

    /**
     * Get grades for a specific student
     * GET /api/lecturers/me/students/{studentId}/grades
     * VPD filters to show only grades for lecturer's courses
     */
    @GetMapping("/me/students/{studentId}/grades")
    public ResponseEntity<ApiResponse<List<Grade>>> getStudentGrades(@PathVariable String studentId) {
        try {
            List<Grade> grades = lecturerService.getStudentGrades(studentId);
            return ResponseEntity.ok(ApiResponse.success(grades));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get student grades: " + e.getMessage()));
        }
    }

    /**
     * Update lecturer profile
     * PUT /api/lecturers/me
     * Lecturers can only update email, phoneNumber, contactAddress
     */
    @PutMapping("/me")
    public ResponseEntity<ApiResponse<Lecturer>> updateMyProfile(@RequestBody Lecturer updatedLecturer) {
        try {
            Lecturer lecturer = lecturerService.updateProfile(updatedLecturer);
            return ResponseEntity.ok(ApiResponse.success("Profile updated successfully", lecturer));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to update profile: " + e.getMessage()));
        }
    }

    /**
     * Update grade
     * PUT /api/lecturers/me/grades/{gradeId}
     * Lecturers can only update grades for their courses and before deadline
     */
    @PutMapping("/me/grades/{gradeId}")
    public ResponseEntity<ApiResponse<Grade>> updateGrade(
            @PathVariable Long gradeId,
            @RequestBody Grade updatedGrade) {
        try {
            Grade grade = lecturerService.updateGrade(gradeId, updatedGrade);
            return ResponseEntity.ok(ApiResponse.success("Grade updated successfully", grade));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to update grade: " + e.getMessage()));
        }
    }
}
