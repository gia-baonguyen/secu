package edu.university.grademanagement.repository;

import edu.university.grademanagement.model.entity.Enrollment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository for Enrollment entity
 * Handles database operations for enrollment data
 * VPD policies will automatically filter results based on user role
 */
@Repository
public interface EnrollmentRepository extends JpaRepository<Enrollment, String> {

    /**
     * Find enrollment by enrollment ID
     */
    Optional<Enrollment> findByEnrollmentId(String enrollmentId);

    /**
     * Find enrollments by course section ID
     */
    @Query("SELECT e FROM Enrollment e WHERE e.sectionId = :sectionId")
    List<Enrollment> findBySectionId(@Param("sectionId") String sectionId);

    /**
     * Find all enrollments for a specific student
     * VPD will ensure students only see their own enrollments
     */
    @Query("SELECT e FROM Enrollment e WHERE e.studentId = :studentId")
    List<Enrollment> findByStudentId(@Param("studentId") String studentId);

    /**
     * Find all enrollments for a specific course section
     * Used by lecturers to see their class roster
     */
    @Query("SELECT e FROM Enrollment e WHERE e.sectionId = :sectionId")
    List<Enrollment> findByCourseSectionId(@Param("sectionId") String sectionId);

    /**
     * Check if student is enrolled in a specific course section
     */
    @Query("SELECT COUNT(e) > 0 FROM Enrollment e WHERE e.studentId = :studentId AND e.sectionId = :sectionId")
    boolean isStudentEnrolled(@Param("studentId") String studentId, @Param("sectionId") String sectionId);

    /**
     * Count enrollments in a course section (for capacity check)
     */
    @Query("SELECT COUNT(e) FROM Enrollment e WHERE e.sectionId = :sectionId")
    long countByCourseSectionId(@Param("sectionId") String sectionId);
}
