package edu.university.grademanagement.repository;

import edu.university.grademanagement.model.entity.Grade;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository for Grade entity
 * Handles database operations for grade data
 * VPD policies will automatically filter results based on user role
 */
@Repository
public interface GradeRepository extends JpaRepository<Grade, Long> {

    /**
     * Find grade by enrollment ID
     * VPD will ensure only authorized grades are returned
     */
    Optional<Grade> findByEnrollmentId(String enrollmentId);

    /**
     * Find all grades for a specific enrollment
     * Useful when checking grade history
     */
    @Query("SELECT g FROM Grade g WHERE g.enrollmentId = :enrollmentId ORDER BY g.createdDate DESC")
    List<Grade> findAllByEnrollmentId(@Param("enrollmentId") String enrollmentId);

    /**
     * Find grades by status
     * Used by lecturers to see pending grades, by academic affairs to see submitted grades
     */
    @Query("SELECT g FROM Grade g WHERE g.gradeStatus = :status")
    List<Grade> findByGradeStatus(@Param("status") String status);

    /**
     * Find grades submitted by a specific lecturer
     */
    @Query("SELECT g FROM Grade g WHERE g.submittedBy = :lecturerId")
    List<Grade> findBySubmittedBy(@Param("lecturerId") String lecturerId);

    /**
     * Count grades by status for statistics
     */
    @Query("SELECT COUNT(g) FROM Grade g WHERE g.gradeStatus = :status")
    long countByGradeStatus(@Param("status") String status);
}
