package edu.university.grademanagement.service;

import edu.university.grademanagement.model.entity.ExamQuestion;
import edu.university.grademanagement.security.UserPrincipal;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Service for ExamQuestion operations
 * Uses JdbcTemplate for OLS-specific queries (CHAR_TO_LABEL, LABEL_TO_CHAR)
 * OLS automatically filters data based on user's label authorization
 */
@Service
public class ExamQuestionService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private static final String OLS_POLICY_NAME = "EXAM_SEC_POLICY";

    /**
     * RowMapper for ExamQuestion with security label
     */
    private final RowMapper<ExamQuestion> examQuestionRowMapper = new RowMapper<ExamQuestion>() {
        @Override
        public ExamQuestion mapRow(ResultSet rs, int rowNum) throws SQLException {
            ExamQuestion question = new ExamQuestion();
            question.setQuestionId(rs.getLong("question_id"));
            question.setSubjectCode(rs.getString("subject_code"));
            question.setQuestionText(rs.getString("question_text"));
            question.setCorrectAnswer(rs.getString("correct_answer"));
            question.setCreatedBy(rs.getString("created_by"));
            
            java.sql.Timestamp timestamp = rs.getTimestamp("created_date");
            if (timestamp != null) {
                question.setCreatedDate(timestamp.toLocalDateTime());
            }
            
            question.setOlsLabel(rs.getLong("ols_label"));
            return question;
        }
    };

    /**
     * Get all exam questions with security labels
     * OLS automatically filters based on user's authorization
     * Uses LABEL_TO_CHAR to get human-readable label string
     */
    public List<ExamQuestion> getAllQuestions() {
        // LABEL_TO_CHAR converts OLS label to human-readable string (e.g., "PUB", "INT:CS")
        // Syntax: LABEL_TO_CHAR(policy_name, label) or LABEL_TO_CHAR(label) if single policy
        String sql = "SELECT question_id, subject_code, question_text, correct_answer, " +
                     "created_by, created_date, ols_label " +
                     "FROM GMS_ADMIN.EXAM_QUESTIONS " +
                     "ORDER BY question_id";

     
        
        return jdbcTemplate.query(sql, examQuestionRowMapper);
    }

    /**
     * Get exam question by ID with security label
     * OLS checks if user has permission to view this question
     */
    public ExamQuestion getQuestionById(Long questionId) {
        String sql = "SELECT question_id, subject_code, question_text, correct_answer, " +
                     "created_by, created_date, ols_label " +
                     "FROM GMS_ADMIN.EXAM_QUESTIONS " +
                     "WHERE question_id = ?";
        
        List<ExamQuestion> results = jdbcTemplate.query(sql, examQuestionRowMapper, questionId);
        
        if (results.isEmpty()) {
            throw new RuntimeException("Question not found or you don't have permission to view it: " + questionId);
        }
        
        return results.get(0);
    }

    /**
     * Get questions by subject code
     * OLS automatically filters based on user's authorization
     */
    public List<ExamQuestion> getQuestionsBySubject(String subjectCode) {
        String sql = "SELECT question_id, subject_code, question_text, correct_answer, " +
                     "created_by, created_date, ols_label " +
                     "FROM GMS_ADMIN.EXAM_QUESTIONS " +
                     "WHERE subject_code = ? " +
                     "ORDER BY question_id";
        
        return jdbcTemplate.query(sql, examQuestionRowMapper, subjectCode);
    }

    /**
     * Search questions by keyword
     * OLS automatically filters based on user's authorization
     */
    public List<ExamQuestion> searchQuestions(String keyword) {
        String sql = "SELECT question_id, subject_code, question_text, correct_answer, " +
                     "created_by, created_date, ols_label " +
                     "FROM GMS_ADMIN.EXAM_QUESTIONS " +
                     "WHERE LOWER(question_text) LIKE LOWER(?) " +
                     "ORDER BY question_id";
        
        return jdbcTemplate.query(sql, examQuestionRowMapper, "%" + keyword + "%");
    }

    /**
     * Create a new exam question with specified security label
     * Uses CHAR_TO_LABEL to convert label string to OLS label
     * OLS checks if user has permission to write with this label
     * 
     * @param question The question to create
     * @param labelString The security label (e.g., "PUB", "INT:CS", "CONF:CS")
     *                   If null, OLS will use user's default label (LABEL_DEFAULT)
     */
    @Transactional
    public ExamQuestion createQuestion(ExamQuestion question, String labelString) {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        String createdBy = currentUser.getUserId();
        LocalDateTime createdDate = LocalDateTime.now();

        String sql;
        Object[] params;

        if (labelString != null && !labelString.isEmpty()) {
            // Insert with specific label using CHAR_TO_LABEL
            sql = "INSERT INTO GMS_ADMIN.EXAM_QUESTIONS " +
                  "(subject_code, question_text, correct_answer, created_by, created_date, ols_label) " +
                  "VALUES (?, ?, ?, ?, ?, CHAR_TO_LABEL('" + OLS_POLICY_NAME + "', ?))";
            params = new Object[]{
                question.getSubjectCode(),
                question.getQuestionText(),
                question.getCorrectAnswer(),
                createdBy,
                java.sql.Timestamp.valueOf(createdDate),
                labelString
            };
        } else {
            // Insert without label - OLS will use LABEL_DEFAULT (user's default label)
            sql = "INSERT INTO GMS_ADMIN.EXAM_QUESTIONS " +
                  "(subject_code, question_text, correct_answer, created_by, created_date) " +
                  "VALUES (?, ?, ?, ?, ?)";
            params = new Object[]{
                question.getSubjectCode(),
                question.getQuestionText(),
                question.getCorrectAnswer(),
                createdBy,
                java.sql.Timestamp.valueOf(createdDate)
            };
        }

        jdbcTemplate.update(sql, params);

        // Get the created question (with generated ID and label)
        String selectSql = "SELECT question_id, subject_code, question_text, correct_answer, " +
                          "created_by, created_date, ols_label " +
                          "FROM GMS_ADMIN.EXAM_QUESTIONS " +
                          "WHERE created_by = ? " +
                          "ORDER BY question_id DESC FETCH FIRST 1 ROW ONLY";

        List<ExamQuestion> results = jdbcTemplate.query(selectSql, examQuestionRowMapper, createdBy);
        
        if (results.isEmpty()) {
            throw new RuntimeException("Failed to create question or you don't have permission");
        }
        
        return results.get(0);
    }

    /**
     * Update an existing exam question
     * OLS checks if user has permission to write to this question's label
     * Note: Cannot change the OLS label of an existing row (Oracle restriction)
     */
    @Transactional
    public ExamQuestion updateQuestion(Long questionId, ExamQuestion updatedQuestion) {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        // First check if the question exists and user has access
        ExamQuestion existing = getQuestionById(questionId);
        if (existing == null) {
            throw new RuntimeException("Question not found: " + questionId);
        }

        // Update the question (OLS will check write permission)
        String sql = "UPDATE GMS_ADMIN.EXAM_QUESTIONS SET " +
                     "subject_code = ?, " +
                     "question_text = ?, " +
                     "correct_answer = ? " +
                     "WHERE question_id = ?";

        int rowsAffected = jdbcTemplate.update(sql,
                updatedQuestion.getSubjectCode() != null ? updatedQuestion.getSubjectCode() : existing.getSubjectCode(),
                updatedQuestion.getQuestionText() != null ? updatedQuestion.getQuestionText() : existing.getQuestionText(),
                updatedQuestion.getCorrectAnswer() != null ? updatedQuestion.getCorrectAnswer() : existing.getCorrectAnswer(),
                questionId);

        if (rowsAffected == 0) {
            throw new RuntimeException("Failed to update question. You may not have write permission.");
        }

        // Return the updated question
        return getQuestionById(questionId);
    }

    /**
     * Delete an exam question
     * OLS checks if user has permission to delete this question's label
     */
    @Transactional
    public void deleteQuestion(Long questionId) {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        // First check if the question exists and user has access
        ExamQuestion existing = getQuestionById(questionId);
        if (existing == null) {
            throw new RuntimeException("Question not found: " + questionId);
        }

        String sql = "DELETE FROM GMS_ADMIN.EXAM_QUESTIONS WHERE question_id = ?";
        int rowsAffected = jdbcTemplate.update(sql, questionId);

        if (rowsAffected == 0) {
            throw new RuntimeException("Failed to delete question. You may not have delete permission.");
        }
    }

    /**
     * Get available security labels for current user
     * Based on user's OLS authorization
     */
    public List<String> getAvailableLabels() {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        // Get user's role to determine available labels
        String role = currentUser.getAuthorities().stream()
                .findFirst()
                .map(a -> a.getAuthority().replace("ROLE_", ""))
                .orElse("STUDENT");

        // Return available labels based on role
        switch (role) {
            case "ADMIN":
                return List.of("PUB", "INT:CS", "INT:EE", "CONF:CS");
            case "DEAN":
                return List.of("PUB", "INT:CS", "CONF:CS");
            case "LECTURER":
                return List.of("PUB", "INT:CS");
            default:
                return List.of(); // Students cannot create questions
        }
    }

    /**
     * Get current authenticated user
     */
    private UserPrincipal getCurrentUser() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof UserPrincipal) {
            return (UserPrincipal) authentication.getPrincipal();
        }
        return null;
    }
}

