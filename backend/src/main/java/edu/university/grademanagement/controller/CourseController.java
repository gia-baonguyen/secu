package edu.university.grademanagement.controller;

import edu.university.grademanagement.dto.ApiResponse;
import edu.university.grademanagement.model.entity.Course;
import edu.university.grademanagement.service.CourseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Course Controller
 * Handles endpoints for course management
 * All authenticated users can view courses
 * Only ADMIN and ACADEMIC_AFFAIRS can modify courses
 */
@RestController
@RequestMapping("/courses")
@CrossOrigin(origins = "${security.cors.allowed-origins}")
public class CourseController {

    @Autowired
    private CourseService courseService;

    /**
     * Get all courses
     * GET /courses
     */
    @GetMapping
    @PreAuthorize("hasAnyRole('STUDENT', 'LECTURER', 'DEAN', 'DEPARTMENT_HEAD', 'ACADEMIC_AFFAIRS', 'ADMIN')")
    public ResponseEntity<ApiResponse<List<Course>>> getAllCourses() {
        try {
            List<Course> courses = courseService.getAllCourses();
            return ResponseEntity.ok(ApiResponse.success(courses));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get courses: " + e.getMessage()));
        }
    }

    /**
     * Get course by ID
     * GET /courses/{courseId}
     */
    @GetMapping("/{courseId}")
    @PreAuthorize("hasAnyRole('STUDENT', 'LECTURER', 'DEAN', 'DEPARTMENT_HEAD', 'ACADEMIC_AFFAIRS', 'ADMIN')")
    public ResponseEntity<ApiResponse<Course>> getCourseById(@PathVariable String courseId) {
        try {
            Course course = courseService.getCourseById(courseId);
            return ResponseEntity.ok(ApiResponse.success(course));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get course: " + e.getMessage()));
        }
    }

    /**
     * Get courses by department
     * GET /courses/department/{departmentId}
     */
    @GetMapping("/department/{departmentId}")
    @PreAuthorize("hasAnyRole('STUDENT', 'LECTURER', 'DEAN', 'DEPARTMENT_HEAD', 'ACADEMIC_AFFAIRS', 'ADMIN')")
    public ResponseEntity<ApiResponse<List<Course>>> getCoursesByDepartment(@PathVariable String departmentId) {
        try {
            List<Course> courses = courseService.getCoursesByDepartment(departmentId);
            return ResponseEntity.ok(ApiResponse.success(courses));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get courses: " + e.getMessage()));
        }
    }

    /**
     * Search courses by name
     * GET /courses/search?keyword={keyword}
     */
    @GetMapping("/search")
    @PreAuthorize("hasAnyRole('STUDENT', 'LECTURER', 'DEAN', 'DEPARTMENT_HEAD', 'ACADEMIC_AFFAIRS', 'ADMIN')")
    public ResponseEntity<ApiResponse<List<Course>>> searchCourses(@RequestParam String keyword) {
        try {
            List<Course> courses = courseService.searchCourses(keyword);
            return ResponseEntity.ok(ApiResponse.success(courses));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to search courses: " + e.getMessage()));
        }
    }

    /**
     * Create new course
     * POST /courses
     */
    @PostMapping
    @PreAuthorize("hasAnyRole('ACADEMIC_AFFAIRS', 'ADMIN')")
    public ResponseEntity<ApiResponse<Course>> createCourse(@RequestBody Course course) {
        try {
            Course createdCourse = courseService.createCourse(course);
            return ResponseEntity.ok(ApiResponse.success("Course created successfully", createdCourse));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to create course: " + e.getMessage()));
        }
    }

    /**
     * Update course
     * PUT /courses/{courseId}
     */
    @PutMapping("/{courseId}")
    @PreAuthorize("hasAnyRole('ACADEMIC_AFFAIRS', 'ADMIN')")
    public ResponseEntity<ApiResponse<Course>> updateCourse(
            @PathVariable String courseId,
            @RequestBody Course updatedCourse) {
        try {
            Course course = courseService.updateCourse(courseId, updatedCourse);
            return ResponseEntity.ok(ApiResponse.success("Course updated successfully", course));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to update course: " + e.getMessage()));
        }
    }

    /**
     * Delete course
     * DELETE /courses/{courseId}
     */
    @DeleteMapping("/{courseId}")
    @PreAuthorize("hasAnyRole('ACADEMIC_AFFAIRS', 'ADMIN')")
    public ResponseEntity<ApiResponse<Void>> deleteCourse(@PathVariable String courseId) {
        try {
            courseService.deleteCourse(courseId);
            return ResponseEntity.ok(ApiResponse.success("Deadline deleted successfully", null));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to delete course: " + e.getMessage()));
        }
    }
}

