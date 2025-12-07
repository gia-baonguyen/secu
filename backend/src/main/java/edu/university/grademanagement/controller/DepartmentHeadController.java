package edu.university.grademanagement.controller;

import edu.university.grademanagement.dto.ApiResponse;
import edu.university.grademanagement.model.entity.Course;
import edu.university.grademanagement.model.entity.Grade;
import edu.university.grademanagement.model.entity.Lecturer;
import edu.university.grademanagement.service.DepartmentHeadService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Department Head Controller
 * Handles endpoints for department head operations
 * Department Head can view all data within their department
 * All endpoints require DEPARTMENT_HEAD role
 */
@RestController
@RequestMapping("/department-head")
@CrossOrigin(origins = "${security.cors.allowed-origins}")
@PreAuthorize("hasRole('DEPARTMENT_HEAD')")
public class DepartmentHeadController {

    @Autowired
    private DepartmentHeadService departmentHeadService;

    /**
     * Get department information
     * GET /department-head/department
     */
    @GetMapping("/department")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getDepartmentInfo() {
        try {
            Map<String, Object> departmentInfo = departmentHeadService.getDepartmentInfo();
            return ResponseEntity.ok(ApiResponse.success(departmentInfo));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get department info: " + e.getMessage()));
        }
    }

    /**
     * Get all lecturers in the department
     * GET /department-head/lecturers
     */
    @GetMapping("/lecturers")
    public ResponseEntity<ApiResponse<List<Lecturer>>> getDepartmentLecturers() {
        try {
            List<Lecturer> lecturers = departmentHeadService.getDepartmentLecturers();
            return ResponseEntity.ok(ApiResponse.success(lecturers));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get lecturers: " + e.getMessage()));
        }
    }

    /**
     * Get a specific lecturer
     * GET /department-head/lecturers/{lecturerId}
     */
    @GetMapping("/lecturers/{lecturerId}")
    public ResponseEntity<ApiResponse<Lecturer>> getLecturer(@PathVariable String lecturerId) {
        try {
            Lecturer lecturer = departmentHeadService.getLecturer(lecturerId);
            return ResponseEntity.ok(ApiResponse.success(lecturer));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get lecturer: " + e.getMessage()));
        }
    }

    /**
     * Get all courses in the department
     * GET /department-head/courses
     */
    @GetMapping("/courses")
    public ResponseEntity<ApiResponse<List<Course>>> getDepartmentCourses() {
        try {
            List<Course> courses = departmentHeadService.getDepartmentCourses();
            return ResponseEntity.ok(ApiResponse.success(courses));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get courses: " + e.getMessage()));
        }
    }

    /**
     * Get all grades in the department
     * GET /department-head/grades
     */
    @GetMapping("/grades")
    public ResponseEntity<ApiResponse<List<Grade>>> getDepartmentGrades() {
        try {
            List<Grade> grades = departmentHeadService.getDepartmentGrades();
            return ResponseEntity.ok(ApiResponse.success(grades));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get grades: " + e.getMessage()));
        }
    }

    /**
     * Get students enrolled in department's courses
     * GET /department-head/students
     */
    @GetMapping("/students")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getDepartmentStudents() {
        try {
            List<Map<String, Object>> students = departmentHeadService.getDepartmentStudents();
            return ResponseEntity.ok(ApiResponse.success(students));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get students: " + e.getMessage()));
        }
    }

    /**
     * Get department statistics
     * GET /department-head/statistics
     */
    @GetMapping("/statistics")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getDepartmentStatistics() {
        try {
            Map<String, Object> stats = departmentHeadService.getDepartmentStatistics();
            return ResponseEntity.ok(ApiResponse.success(stats));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get statistics: " + e.getMessage()));
        }
    }
}

