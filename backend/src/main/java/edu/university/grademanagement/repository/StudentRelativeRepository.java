package edu.university.grademanagement.repository;

import edu.university.grademanagement.model.entity.StudentRelative;
import edu.university.grademanagement.model.entity.StudentRelativeId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository for StudentRelative entity
 * Handles database operations for student-relative relationships
 */
@Repository
public interface StudentRelativeRepository extends JpaRepository<StudentRelative, StudentRelativeId> {

    /**
     * Find all relatives for a student
     */
    @Query("SELECT sr FROM StudentRelative sr WHERE sr.id.studentId = :studentId")
    List<StudentRelative> findByStudentId(@Param("studentId") String studentId);

    /**
     * Find all students for a relative
     */
    @Query("SELECT sr FROM StudentRelative sr WHERE sr.id.relativeId = :relativeId")
    List<StudentRelative> findByRelativeId(@Param("relativeId") String relativeId);

    /**
     * Find primary contact for a student
     */
    @Query("SELECT sr FROM StudentRelative sr WHERE sr.id.studentId = :studentId AND sr.isPrimaryContact = 'Y'")
    List<StudentRelative> findPrimaryContactByStudentId(@Param("studentId") String studentId);

    /**
     * Check if relationship exists
     */
    @Query("SELECT COUNT(sr) > 0 FROM StudentRelative sr WHERE sr.id.studentId = :studentId AND sr.id.relativeId = :relativeId")
    boolean existsByStudentIdAndRelativeId(@Param("studentId") String studentId, @Param("relativeId") String relativeId);

    /**
     * Find by relationship type
     */
    @Query("SELECT sr FROM StudentRelative sr WHERE sr.id.studentId = :studentId AND sr.relationship = :relationship")
    List<StudentRelative> findByStudentIdAndRelationship(@Param("studentId") String studentId, @Param("relationship") String relationship);
}

