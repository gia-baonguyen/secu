package edu.university.grademanagement.repository;

import edu.university.grademanagement.model.entity.Course;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository for Course entity
 * Handles database operations for course data
 */
@Repository
public interface CourseRepository extends JpaRepository<Course, String> {

    /**
     * Find course by course ID
     */
    Optional<Course> findByCourseId(String courseId);

    /**
     * Find all courses in a department
     */
    List<Course> findByDepartmentId(String departmentId);

    /**
     * Find courses by type
     */
    List<Course> findByCourseType(String courseType);

    /**
     * Find courses by department and type
     */
    List<Course> findByDepartmentIdAndCourseType(String departmentId, String courseType);

    /**
     * Find courses that have a specific prerequisite
     */
    List<Course> findByPrerequisiteCourseId(String prerequisiteCourseId);

    /**
     * Search courses by name
     */
    @Query("SELECT c FROM Course c WHERE UPPER(c.courseName) LIKE UPPER(CONCAT('%', :keyword, '%'))")
    List<Course> searchByCourseName(@Param("keyword") String keyword);

    /**
     * Find mandatory courses in a department
     */
    @Query("SELECT c FROM Course c WHERE c.departmentId = :departmentId AND c.courseType = 'Mandatory'")
    List<Course> findMandatoryCoursesByDepartment(@Param("departmentId") String departmentId);

    /**
     * Check if course exists
     */
    boolean existsByCourseId(String courseId);
}

