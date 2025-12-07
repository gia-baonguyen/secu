package edu.university.grademanagement.controller;

import edu.university.grademanagement.dto.ApiResponse;
import edu.university.grademanagement.model.entity.GradeSubmissionDeadline;
import edu.university.grademanagement.service.DeadlineService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

/**
 * Deadline Controller
 * Handles endpoints for grade submission deadline management
 * All authenticated users can view deadlines
 * Only ACADEMIC_AFFAIRS and ADMIN can modify deadlines
 */
@RestController
@RequestMapping("/deadlines")
@CrossOrigin(origins = "${security.cors.allowed-origins}")
public class DeadlineController {

    @Autowired
    private DeadlineService deadlineService;

    /**
     * Get all deadlines
     * GET /deadlines
     */
    @GetMapping
    @PreAuthorize("hasAnyRole('LECTURER', 'DEAN', 'DEPARTMENT_HEAD', 'ACADEMIC_AFFAIRS', 'ADMIN')")
    public ResponseEntity<ApiResponse<List<GradeSubmissionDeadline>>> getAllDeadlines() {
        try {
            List<GradeSubmissionDeadline> deadlines = deadlineService.getAllDeadlines();
            return ResponseEntity.ok(ApiResponse.success(deadlines));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get deadlines: " + e.getMessage()));
        }
    }

    /**
     * Get current active deadline
     * GET /deadlines/current
     */
    @GetMapping("/current")
    @PreAuthorize("hasAnyRole('LECTURER', 'DEAN', 'DEPARTMENT_HEAD', 'ACADEMIC_AFFAIRS', 'ADMIN')")
    public ResponseEntity<ApiResponse<GradeSubmissionDeadline>> getCurrentDeadline() {
        try {
            var deadline = deadlineService.getCurrentDeadline();
            if (deadline.isPresent()) {
                return ResponseEntity.ok(ApiResponse.success(deadline.get()));
            } else {
                return ResponseEntity.ok(ApiResponse.error("No active deadline found"));
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get current deadline: " + e.getMessage()));
        }
    }

    /**
     * Get deadline by semester and year
     * GET /deadlines/semester/{semester}/year/{year}
     */
    @GetMapping("/semester/{semester}/year/{year}")
    @PreAuthorize("hasAnyRole('LECTURER', 'DEAN', 'DEPARTMENT_HEAD', 'ACADEMIC_AFFAIRS', 'ADMIN')")
    public ResponseEntity<ApiResponse<GradeSubmissionDeadline>> getDeadline(
            @PathVariable String semester,
            @PathVariable Integer year) {
        try {
            var deadline = deadlineService.getDeadline(semester, year);
            if (deadline.isPresent()) {
                return ResponseEntity.ok(ApiResponse.success(deadline.get()));
            } else {
                return ResponseEntity.ok(ApiResponse.error("Deadline not found"));
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get deadline: " + e.getMessage()));
        }
    }

    /**
     * Check if deadline has passed
     * GET /deadlines/check?semester={semester}&year={year}
     */
    @GetMapping("/check")
    @PreAuthorize("hasAnyRole('LECTURER', 'DEAN', 'DEPARTMENT_HEAD', 'ACADEMIC_AFFAIRS', 'ADMIN')")
    public ResponseEntity<ApiResponse<Boolean>> isAfterDeadline(
            @RequestParam String semester,
            @RequestParam Integer academicYear) {
        try {
            boolean isAfter = deadlineService.isAfterDeadline(semester, academicYear);
            return ResponseEntity.ok(ApiResponse.success(isAfter));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to check deadline: " + e.getMessage()));
        }
    }

    /**
     * Create new deadline
     * POST /deadlines
     */
    @PostMapping
    @PreAuthorize("hasAnyRole('ACADEMIC_AFFAIRS', 'ADMIN')")
    public ResponseEntity<ApiResponse<GradeSubmissionDeadline>> createDeadline(
            @RequestBody GradeSubmissionDeadline deadline) {
        try {
            GradeSubmissionDeadline createdDeadline = deadlineService.createDeadline(deadline);
            return ResponseEntity.ok(ApiResponse.success("Deadline created successfully", createdDeadline));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to create deadline: " + e.getMessage()));
        }
    }

    /**
     * Update deadline
     * PUT /deadlines/{deadlineId}
     */
    @PutMapping("/{deadlineId}")
    @PreAuthorize("hasAnyRole('ACADEMIC_AFFAIRS', 'ADMIN')")
    public ResponseEntity<ApiResponse<GradeSubmissionDeadline>> updateDeadline(
            @PathVariable Long deadlineId,
            @RequestBody GradeSubmissionDeadline updatedDeadline) {
        try {
            GradeSubmissionDeadline deadline = deadlineService.updateDeadline(deadlineId, updatedDeadline);
            return ResponseEntity.ok(ApiResponse.success("Deadline updated successfully", deadline));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to update deadline: " + e.getMessage()));
        }
    }

    /**
     * Deactivate deadline
     * POST /deadlines/{deadlineId}/deactivate
     */
    @PostMapping("/{deadlineId}/deactivate")
    @PreAuthorize("hasAnyRole('ACADEMIC_AFFAIRS', 'ADMIN')")
    public ResponseEntity<ApiResponse<GradeSubmissionDeadline>> deactivateDeadline(@PathVariable Long deadlineId) {
        try {
            GradeSubmissionDeadline deadline = deadlineService.deactivateDeadline(deadlineId);
            return ResponseEntity.ok(ApiResponse.success("Deadline deactivated successfully", deadline));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to deactivate deadline: " + e.getMessage()));
        }
    }

    /**
     * Delete deadline
     * DELETE /deadlines/{deadlineId}
     */
    @DeleteMapping("/{deadlineId}")
    @PreAuthorize("hasAnyRole('ACADEMIC_AFFAIRS', 'ADMIN')")
    public ResponseEntity<ApiResponse<Void>> deleteDeadline(@PathVariable Long deadlineId) {
        try {
            deadlineService.deleteDeadline(deadlineId);
            return ResponseEntity.ok(ApiResponse.success("Deadline deleted successfully", null));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to delete deadline: " + e.getMessage()));
        }
    }
}

