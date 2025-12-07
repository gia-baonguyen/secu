package edu.university.grademanagement.service;

import edu.university.grademanagement.model.entity.Course;
import edu.university.grademanagement.repository.CourseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Course Service
 * Business logic for course operations
 */
@Service
public class CourseService {

    @Autowired
    private CourseRepository courseRepository;

    /**
     * Get all courses
     */
    public List<Course> getAllCourses() {
        return courseRepository.findAll();
    }

    /**
     * Get course by ID
     */
    public Course getCourseById(String courseId) {
        return courseRepository.findByCourseId(courseId)
                .orElseThrow(() -> new RuntimeException("Course not found: " + courseId));
    }

    /**
     * Get courses by department
     */
    public List<Course> getCoursesByDepartment(String departmentId) {
        return courseRepository.findByDepartmentId(departmentId);
    }

    /**
     * Get courses by type
     */
    public List<Course> getCoursesByType(String courseType) {
        return courseRepository.findByCourseType(courseType);
    }

    /**
     * Get mandatory courses in a department
     */
    public List<Course> getMandatoryCourses(String departmentId) {
        return courseRepository.findMandatoryCoursesByDepartment(departmentId);
    }

    /**
     * Search courses by name
     */
    public List<Course> searchCourses(String keyword) {
        return courseRepository.searchByCourseName(keyword);
    }

    /**
     * Get courses that require a specific prerequisite
     */
    public List<Course> getCoursesWithPrerequisite(String prerequisiteCourseId) {
        return courseRepository.findByPrerequisiteCourseId(prerequisiteCourseId);
    }

    /**
     * Check if course exists
     */
    public boolean courseExists(String courseId) {
        return courseRepository.existsByCourseId(courseId);
    }

    /**
     * Create new course
     */
    public Course createCourse(Course course) {
        if (courseRepository.existsByCourseId(course.getCourseId())) {
            throw new RuntimeException("Course already exists: " + course.getCourseId());
        }
        return courseRepository.save(course);
    }

    /**
     * Update course
     */
    public Course updateCourse(String courseId, Course updatedCourse) {
        Course course = getCourseById(courseId);
        
        if (updatedCourse.getCourseName() != null) {
            course.setCourseName(updatedCourse.getCourseName());
        }
        if (updatedCourse.getCredits() != null) {
            course.setCredits(updatedCourse.getCredits());
        }
        if (updatedCourse.getCourseType() != null) {
            course.setCourseType(updatedCourse.getCourseType());
        }
        if (updatedCourse.getDescription() != null) {
            course.setDescription(updatedCourse.getDescription());
        }
        if (updatedCourse.getPrerequisiteCourseId() != null) {
            course.setPrerequisiteCourseId(updatedCourse.getPrerequisiteCourseId());
        }
        
        return courseRepository.save(course);
    }

    /**
     * Delete course
     */
    public void deleteCourse(String courseId) {
        Course course = getCourseById(courseId);
        courseRepository.delete(course);
    }
}

