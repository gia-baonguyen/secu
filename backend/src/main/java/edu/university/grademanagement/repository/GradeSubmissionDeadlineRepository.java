package edu.university.grademanagement.repository;

import edu.university.grademanagement.model.entity.GradeSubmissionDeadline;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * Repository for GradeSubmissionDeadline entity
 * Handles database operations for grade submission deadlines
 */
@Repository
public interface GradeSubmissionDeadlineRepository extends JpaRepository<GradeSubmissionDeadline, Long> {

    /**
     * Find deadline by semester and academic year
     */
    Optional<GradeSubmissionDeadline> findBySemesterAndAcademicYear(String semester, Integer academicYear);

    /**
     * Find all active deadlines
     */
    List<GradeSubmissionDeadline> findByIsActive(String isActive);

    /**
     * Find current active deadline
     */
    @Query("SELECT d FROM GradeSubmissionDeadline d WHERE d.isActive = 'Y' ORDER BY d.academicYear DESC, d.semester DESC")
    List<GradeSubmissionDeadline> findActiveDeadlines();

    /**
     * Find upcoming deadlines
     */
    @Query("SELECT d FROM GradeSubmissionDeadline d WHERE d.submissionDeadline >= :today AND d.isActive = 'Y' ORDER BY d.submissionDeadline ASC")
    List<GradeSubmissionDeadline> findUpcomingDeadlines(@Param("today") LocalDate today);

    /**
     * Find past deadlines
     */
    @Query("SELECT d FROM GradeSubmissionDeadline d WHERE d.submissionDeadline < :today ORDER BY d.submissionDeadline DESC")
    List<GradeSubmissionDeadline> findPastDeadlines(@Param("today") LocalDate today);

    /**
     * Check if deadline is past for a specific semester and year
     */
    @Query("SELECT CASE WHEN d.submissionDeadline < :today THEN true ELSE false END FROM GradeSubmissionDeadline d WHERE d.semester = :semester AND d.academicYear = :academicYear")
    Boolean isDeadlinePast(@Param("semester") String semester, @Param("academicYear") Integer academicYear, @Param("today") LocalDate today);

    /**
     * Find deadlines by academic year
     */
    List<GradeSubmissionDeadline> findByAcademicYear(Integer academicYear);
}

