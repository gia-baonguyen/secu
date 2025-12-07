package edu.university.grademanagement.controller;

import edu.university.grademanagement.dto.ApiResponse;
import edu.university.grademanagement.model.entity.AuditLog;
import edu.university.grademanagement.model.entity.Grade;
import edu.university.grademanagement.model.entity.Lecturer;
import edu.university.grademanagement.model.entity.Student;
import edu.university.grademanagement.service.AcademicAffairsService;
import edu.university.grademanagement.service.AuditService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Academic Affairs Controller
 * Handles endpoints for academic affairs operations
 * Academic Affairs has full access to all data
 * Can modify grades after deadline
 * All endpoints require ACADEMIC_AFFAIRS role
 */
@RestController
@RequestMapping("/academic")
@CrossOrigin(origins = "${security.cors.allowed-origins}")
@PreAuthorize("hasRole('ACADEMIC_AFFAIRS')")
public class AcademicAffairsController {

    @Autowired
    private AcademicAffairsService academicAffairsService;

    @Autowired
    private AuditService auditService;

    /**
     * Get all students
     * GET /academic/students
     */
    @GetMapping("/students")
    public ResponseEntity<ApiResponse<List<Student>>> getAllStudents() {
        try {
            List<Student> students = academicAffairsService.getAllStudents();
            return ResponseEntity.ok(ApiResponse.success(students));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get students: " + e.getMessage()));
        }
    }

    /**
     * Get a specific student
     * GET /academic/students/{studentId}
     */
    @GetMapping("/students/{studentId}")
    public ResponseEntity<ApiResponse<Student>> getStudent(@PathVariable String studentId) {
        try {
            Student student = academicAffairsService.getStudent(studentId);
            return ResponseEntity.ok(ApiResponse.success(student));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get student: " + e.getMessage()));
        }
    }

    /**
     * Get grades for a specific student
     * GET /academic/students/{studentId}/grades
     */
    @GetMapping("/students/{studentId}/grades")
    public ResponseEntity<ApiResponse<List<Grade>>> getStudentGrades(@PathVariable String studentId) {
        try {
            List<Grade> grades = academicAffairsService.getStudentGrades(studentId);
            return ResponseEntity.ok(ApiResponse.success(grades));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get student grades: " + e.getMessage()));
        }
    }

    /**
     * Get all lecturers
     * GET /academic/lecturers
     */
    @GetMapping("/lecturers")
    public ResponseEntity<ApiResponse<List<Lecturer>>> getAllLecturers() {
        try {
            List<Lecturer> lecturers = academicAffairsService.getAllLecturers();
            return ResponseEntity.ok(ApiResponse.success(lecturers));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get lecturers: " + e.getMessage()));
        }
    }

    /**
     * Get a specific lecturer
     * GET /academic/lecturers/{lecturerId}
     */
    @GetMapping("/lecturers/{lecturerId}")
    public ResponseEntity<ApiResponse<Lecturer>> getLecturer(@PathVariable String lecturerId) {
        try {
            Lecturer lecturer = academicAffairsService.getLecturer(lecturerId);
            return ResponseEntity.ok(ApiResponse.success(lecturer));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get lecturer: " + e.getMessage()));
        }
    }

    /**
     * Get all grades
     * GET /academic/grades
     */
    @GetMapping("/grades")
    public ResponseEntity<ApiResponse<List<Grade>>> getAllGrades() {
        try {
            List<Grade> grades = academicAffairsService.getAllGrades();
            return ResponseEntity.ok(ApiResponse.success(grades));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get grades: " + e.getMessage()));
        }
    }

    /**
     * Get a specific grade
     * GET /academic/grades/{gradeId}
     */
    @GetMapping("/grades/{gradeId}")
    public ResponseEntity<ApiResponse<Grade>> getGrade(@PathVariable Long gradeId) {
        try {
            Grade grade = academicAffairsService.getGrade(gradeId);
            return ResponseEntity.ok(ApiResponse.success(grade));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get grade: " + e.getMessage()));
        }
    }

    /**
     * Update a grade
     * PUT /academic/grades/{gradeId}
     */
    @PutMapping("/grades/{gradeId}")
    public ResponseEntity<ApiResponse<Grade>> updateGrade(
            @PathVariable Long gradeId,
            @RequestBody Grade updatedGrade) {
        try {
            Grade grade = academicAffairsService.updateGrade(gradeId, updatedGrade);
            return ResponseEntity.ok(ApiResponse.success("Grade updated successfully", grade));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to update grade: " + e.getMessage()));
        }
    }

    /**
     * Approve a grade
     * POST /academic/grades/{gradeId}/approve
     */
    @PostMapping("/grades/{gradeId}/approve")
    public ResponseEntity<ApiResponse<Grade>> approveGrade(@PathVariable Long gradeId) {
        try {
            Grade grade = academicAffairsService.approveGrade(gradeId);
            return ResponseEntity.ok(ApiResponse.success("Grade approved successfully", grade));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to approve grade: " + e.getMessage()));
        }
    }

    /**
     * Get all faculties
     * GET /academic/faculties
     */
    @GetMapping("/faculties")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getAllFaculties() {
        try {
            List<Map<String, Object>> faculties = academicAffairsService.getAllFaculties();
            return ResponseEntity.ok(ApiResponse.success(faculties));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get faculties: " + e.getMessage()));
        }
    }

    /**
     * Get all departments
     * GET /academic/departments
     */
    @GetMapping("/departments")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getAllDepartments() {
        try {
            List<Map<String, Object>> departments = academicAffairsService.getAllDepartments();
            return ResponseEntity.ok(ApiResponse.success(departments));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get departments: " + e.getMessage()));
        }
    }

    /**
     * Get system statistics
     * GET /academic/statistics
     */
    @GetMapping("/statistics")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getSystemStatistics() {
        try {
            Map<String, Object> stats = academicAffairsService.getSystemStatistics();
            return ResponseEntity.ok(ApiResponse.success(stats));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get statistics: " + e.getMessage()));
        }
    }

    /**
     * Get grade statistics
     * GET /academic/statistics/grades
     */
    @GetMapping("/statistics/grades")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getGradeStatistics() {
        try {
            Map<String, Object> stats = academicAffairsService.getGradeStatistics();
            return ResponseEntity.ok(ApiResponse.success(stats));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get grade statistics: " + e.getMessage()));
        }
    }

    /**
     * Get audit logs
     * GET /academic/audit-logs
     */
    @GetMapping("/audit-logs")
    public ResponseEntity<ApiResponse<List<AuditLog>>> getAuditLogs() {
        try {
            List<AuditLog> logs = auditService.getAllLogs();
            return ResponseEntity.ok(ApiResponse.success(logs));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get audit logs: " + e.getMessage()));
        }
    }

    /**
     * Get audit logs by table
     * GET /academic/audit-logs/table/{tableName}
     */
    @GetMapping("/audit-logs/table/{tableName}")
    public ResponseEntity<ApiResponse<List<AuditLog>>> getAuditLogsByTable(@PathVariable String tableName) {
        try {
            List<AuditLog> logs = auditService.getLogsByTable(tableName);
            return ResponseEntity.ok(ApiResponse.success(logs));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get audit logs: " + e.getMessage()));
        }
    }

    /**
     * Get audit logs by user
     * GET /academic/audit-logs/user/{userId}
     */
    @GetMapping("/audit-logs/user/{userId}")
    public ResponseEntity<ApiResponse<List<AuditLog>>> getAuditLogsByUser(@PathVariable String userId) {
        try {
            List<AuditLog> logs = auditService.getLogsByUser(userId);
            return ResponseEntity.ok(ApiResponse.success(logs));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get audit logs: " + e.getMessage()));
        }
    }

    /**
     * Get audit statistics
     * GET /academic/audit-logs/statistics
     */
    @GetMapping("/audit-logs/statistics")
    public ResponseEntity<ApiResponse<Map<String, Long>>> getAuditStatistics() {
        try {
            Map<String, Long> stats = auditService.getStatsByTable();
            return ResponseEntity.ok(ApiResponse.success(stats));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get audit statistics: " + e.getMessage()));
        }
    }
}

