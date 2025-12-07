package edu.university.grademanagement.repository;

import edu.university.grademanagement.model.entity.ExamQuestion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository for ExamQuestion entity
 * OLS (Oracle Label Security) automatically filters results based on user's label authorization
 * - STUDENT: Only sees PUB labels
 * - LECTURER: Sees PUB + INT:CS labels
 * - DEAN: Sees PUB + INT:CS + CONF:CS labels
 * - ADMIN: Sees all labels (bypass OLS)
 */
@Repository
public interface ExamQuestionRepository extends JpaRepository<ExamQuestion, Long> {

    /**
     * Find questions by subject code
     * OLS will automatically filter based on user's authorization
     */
    List<ExamQuestion> findBySubjectCode(String subjectCode);

    /**
     * Find questions created by a specific user
     * OLS will automatically filter bFased on user's authorization
     */
    List<ExamQuestion> findByCreatedBy(String createdBy);

    /**
     * Search questions by text (case-insensitive)
     * OLS will automatically filter based on user's authorization
     */
    @Query("SELECT e FROM ExamQuestion e WHERE LOWER(e.questionText) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<ExamQuestion> searchByQuestionText(@Param("keyword") String keyword);

    /**
     * Count questions by subject code
     * OLS will automatically filter based on user's authorization
     */
    long countBySubjectCode(String subjectCode);
}

