package edu.university.grademanagement.controller;

import edu.university.grademanagement.dto.ApiResponse;
import edu.university.grademanagement.model.entity.Grade;
import edu.university.grademanagement.model.entity.Relative;
import edu.university.grademanagement.model.entity.Student;
import edu.university.grademanagement.service.RelativeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Relative Controller
 * Handles endpoints for relatives (parents/guardians)
 * All endpoints require RELATIVE role
 */
@RestController
@RequestMapping("/relatives")
@CrossOrigin(origins = "${security.cors.allowed-origins}")
@PreAuthorize("hasRole('RELATIVE')")
public class RelativeController {

    @Autowired
    private RelativeService relativeService;

    /**
     * Get my profile
     * GET /relatives/me
     */
    @GetMapping("/me")
    public ResponseEntity<ApiResponse<Relative>> getMyProfile() {
        try {
            Relative relative = relativeService.getMyProfile();
            return ResponseEntity.ok(ApiResponse.success(relative));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get profile: " + e.getMessage()));
        }
    }

    /**
     * Update my profile
     * PUT /relatives/me
     */
    @PutMapping("/me")
    public ResponseEntity<ApiResponse<Relative>> updateProfile(@RequestBody Relative updatedRelative) {
        try {
            Relative relative = relativeService.updateProfile(updatedRelative);
            return ResponseEntity.ok(ApiResponse.success("Profile updated successfully", relative));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to update profile: " + e.getMessage()));
        }
    }

    /**
     * Get my children (linked students)
     * GET /relatives/children
     */
    @GetMapping("/children")
    public ResponseEntity<ApiResponse<List<Student>>> getMyChildren() {
        try {
            List<Student> children = relativeService.getMyChildren();
            return ResponseEntity.ok(ApiResponse.success(children));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get children: " + e.getMessage()));
        }
    }

    /**
     * Get a specific child's information
     * GET /relatives/children/{studentId}
     */
    @GetMapping("/children/{studentId}")
    public ResponseEntity<ApiResponse<Student>> getChild(@PathVariable String studentId) {
        try {
            Student child = relativeService.getChild(studentId);
            return ResponseEntity.ok(ApiResponse.success(child));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get child: " + e.getMessage()));
        }
    }

    /**
     * Get grades for a specific child
     * GET /relatives/children/{studentId}/grades
     */
    @GetMapping("/children/{studentId}/grades")
    public ResponseEntity<ApiResponse<List<Grade>>> getChildGrades(@PathVariable String studentId) {
        try {
            List<Grade> grades = relativeService.getChildGrades(studentId);
            return ResponseEntity.ok(ApiResponse.success(grades));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get child grades: " + e.getMessage()));
        }
    }

    /**
     * Get relationship with a specific child
     * GET /relatives/children/{studentId}/relationship
     */
    @GetMapping("/children/{studentId}/relationship")
    public ResponseEntity<ApiResponse<String>> getRelationship(@PathVariable String studentId) {
        try {
            String relationship = relativeService.getRelationship(studentId);
            return ResponseEntity.ok(ApiResponse.success(relationship));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get relationship: " + e.getMessage()));
        }
    }
}

