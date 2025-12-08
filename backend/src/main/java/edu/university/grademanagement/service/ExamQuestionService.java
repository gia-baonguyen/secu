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
import java.util.ArrayList;
import java.util.List;

/**
 * Service for ExamQuestion operations
 * Uses JdbcTemplate for OLS-specific queries (CHAR_TO_LABEL, LABEL_TO_CHAR)
 * 
 * NOTE: Since OLS context cannot be automatically set on pooled connections,
 * we manually filter data based on user's role using WHERE clauses.
 * 
 * Role-based access:
 * - STUDENT: Can only see PUB (PUBLIC) questions
 * - LECTURER: Can see PUB + INT:CS (Internal Computer Science)
 * - DEAN: Can see PUB + INT:CS + CONF:CS (Confidential Computer Science)
 * - ADMIN/ACADEMIC_AFFAIRS: Can see ALL questions
 */
@Service
public class ExamQuestionService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private static final String OLS_POLICY_NAME = "EXAM_SEC_POLICY";
    
    // OLS Label TAG values (numeric) - from step7_ols_setup.sql
    // PUB = 1000, INT:CS = 2100, INT:EE = 2200, CONF:CS = 3100
    private static final int LABEL_TAG_PUB = 1000;
    private static final int LABEL_TAG_INT_CS = 2100;
    private static final int LABEL_TAG_INT_EE = 2200;
    private static final int LABEL_TAG_CONF_CS = 3100;
    
    // Label string values for creating questions
    private static final String LABEL_PUB = "PUB";
    private static final String LABEL_INT_CS = "INT:CS";
    private static final String LABEL_INT_EE = "INT:EE";
    private static final String LABEL_CONF_CS = "CONF:CS";

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
     * Get allowed OLS label TAGS (numeric) based on user's role
     * This implements manual role-based filtering since OLS context
     * cannot be set properly on pooled connections
     * 
     * @return List of allowed label tag numbers for current user's role
     */
    private List<Integer> getAllowedLabelTagsForCurrentUser() {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            return List.of(); // No access if not authenticated
        }
        
        String role = currentUser.getAuthorities().stream()
                .findFirst()
                .map(a -> a.getAuthority().replace("ROLE_", ""))
                .orElse("STUDENT");
        
        List<Integer> allowedTags = new ArrayList<>();
        
        switch (role.toUpperCase()) {
            case "ADMIN":
            case "ACADEMIC_AFFAIRS":
                // Admin can see all labels
                allowedTags.add(LABEL_TAG_PUB);
                allowedTags.add(LABEL_TAG_INT_CS);
                allowedTags.add(LABEL_TAG_INT_EE);
                allowedTags.add(LABEL_TAG_CONF_CS);
                break;
            case "DEAN":
                // Dean can see PUB + INT:CS + CONF:CS
                allowedTags.add(LABEL_TAG_PUB);
                allowedTags.add(LABEL_TAG_INT_CS);
                allowedTags.add(LABEL_TAG_CONF_CS);
                break;
            case "LECTURER":
            case "DEPARTMENT_HEAD":
                // Lecturer can see PUB + INT:CS
                allowedTags.add(LABEL_TAG_PUB);
                allowedTags.add(LABEL_TAG_INT_CS);
                break;
            case "STUDENT":
            default:
                // Student can only see PUB
                allowedTags.add(LABEL_TAG_PUB);
                break;
        }
        
        return allowedTags;
    }
    
    /**
     * Get allowed label strings for current user (for validation when creating)
     */
    private List<String> getAllowedLabelsForCurrentUser() {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            return List.of();
        }
        
        String role = currentUser.getAuthorities().stream()
                .findFirst()
                .map(a -> a.getAuthority().replace("ROLE_", ""))
                .orElse("STUDENT");
        
        switch (role.toUpperCase()) {
            case "ADMIN":
            case "ACADEMIC_AFFAIRS":
                return List.of(LABEL_PUB, LABEL_INT_CS, LABEL_INT_EE, LABEL_CONF_CS);
            case "DEAN":
                return List.of(LABEL_PUB, LABEL_INT_CS, LABEL_CONF_CS);
            case "LECTURER":
            case "DEPARTMENT_HEAD":
                return List.of(LABEL_PUB, LABEL_INT_CS);
            default:
                return List.of(LABEL_PUB);
        }
    }
    
    /**
     * Build WHERE clause for OLS label filtering
     * Uses numeric ols_label values directly (no LABEL_TO_CHAR function)
     * 
     * @param existingWhere Whether there's already a WHERE clause
     * @return SQL clause for label filtering
     */
    private String buildLabelFilterClause(boolean existingWhere) {
        List<Integer> allowedTags = getAllowedLabelTagsForCurrentUser();
        
        if (allowedTags.isEmpty()) {
            // No access - return impossible condition
            return existingWhere ? " AND 1=0" : " WHERE 1=0";
        }
        
        // Check if user has full access (all labels)
        if (allowedTags.size() == 4) {
            return ""; // No filter needed for admin
        }
        
        // Build IN clause with allowed label tags (numeric)
        StringBuilder sb = new StringBuilder();
        sb.append(existingWhere ? " AND " : " WHERE ");
        sb.append("ols_label IN (");
        
        for (int i = 0; i < allowedTags.size(); i++) {
            if (i > 0) sb.append(", ");
            sb.append(allowedTags.get(i));
        }
        sb.append(")");
        
        return sb.toString();
    }

    /**
     * Get all exam questions with security labels
     * Manually filters based on user's role since OLS context cannot be set on pooled connections
     * Uses LABEL_TO_CHAR to compare labels
     */
    public List<ExamQuestion> getAllQuestions() {
        String labelFilter = buildLabelFilterClause(false);
        
        String sql = "SELECT question_id, subject_code, question_text, correct_answer, " +
                     "created_by, created_date, ols_label " +
                     "FROM GMS_ADMIN.EXAM_QUESTIONS" +
                     labelFilter +
                     " ORDER BY question_id";

        System.out.println("[OLS Filter] getAllQuestions SQL: " + sql);
        System.out.println("[OLS Filter] User role: " + getCurrentUserRole());
        System.out.println("[OLS Filter] Allowed label tags: " + getAllowedLabelTagsForCurrentUser());
        
        return jdbcTemplate.query(sql, examQuestionRowMapper);
    }
    
    /**
     * Get current user's role for logging
     */
    private String getCurrentUserRole() {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) return "ANONYMOUS";
        return currentUser.getAuthorities().stream()
                .findFirst()
                .map(a -> a.getAuthority().replace("ROLE_", ""))
                .orElse("UNKNOWN");
    }

    /**
     * Get exam question by ID with security label
     * Manually checks if user has permission to view this question based on role
     */
    public ExamQuestion getQuestionById(Long questionId) {
        String labelFilter = buildLabelFilterClause(true);
        
        String sql = "SELECT question_id, subject_code, question_text, correct_answer, " +
                     "created_by, created_date, ols_label " +
                     "FROM GMS_ADMIN.EXAM_QUESTIONS " +
                     "WHERE question_id = ?" + labelFilter;
        
        List<ExamQuestion> results = jdbcTemplate.query(sql, examQuestionRowMapper, questionId);
        
        if (results.isEmpty()) {
            throw new RuntimeException("Question not found or you don't have permission to view it: " + questionId);
        }
        
        return results.get(0);
    }

    /**
     * Get questions by subject code
     * Manually filters based on user's role
     */
    public List<ExamQuestion> getQuestionsBySubject(String subjectCode) {
        String labelFilter = buildLabelFilterClause(true);
        
        String sql = "SELECT question_id, subject_code, question_text, correct_answer, " +
                     "created_by, created_date, ols_label " +
                     "FROM GMS_ADMIN.EXAM_QUESTIONS " +
                     "WHERE subject_code = ?" + labelFilter +
                     " ORDER BY question_id";
        
        return jdbcTemplate.query(sql, examQuestionRowMapper, subjectCode);
    }

    /**
     * Search questions by keyword
     * Manually filters based on user's role
     */
    public List<ExamQuestion> searchQuestions(String keyword) {
        String labelFilter = buildLabelFilterClause(true);
        
        String sql = "SELECT question_id, subject_code, question_text, correct_answer, " +
                     "created_by, created_date, ols_label " +
                     "FROM GMS_ADMIN.EXAM_QUESTIONS " +
                     "WHERE LOWER(question_text) LIKE LOWER(?)" + labelFilter +
                     " ORDER BY question_id";
        
        return jdbcTemplate.query(sql, examQuestionRowMapper, "%" + keyword + "%");
    }

    /**
     * Create a new exam question with specified security label
     * Uses CHAR_TO_LABEL to convert label string to OLS label
     * Validates that user has permission to create with the specified label
     * 
     * @param question The question to create
     * @param labelString The security label (e.g., "PUB", "INT:CS", "CONF:CS")
     *                   If null, defaults to "PUB" (PUBLIC)
     */
    @Transactional
    public ExamQuestion createQuestion(ExamQuestion question, String labelString) {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }
        
        // Validate that user can create with this label
        List<String> allowedLabels = getAllowedLabelsForCurrentUser();
        String effectiveLabel = (labelString != null && !labelString.isEmpty()) ? labelString : LABEL_PUB;
        
        if (!allowedLabels.contains(effectiveLabel)) {
            throw new RuntimeException("You don't have permission to create questions with label: " + effectiveLabel + 
                    ". Allowed labels: " + allowedLabels);
        }

        String createdBy = currentUser.getUserId();
        LocalDateTime createdDate = LocalDateTime.now();

            // Insert with specific label using CHAR_TO_LABEL
        String sql = "INSERT INTO GMS_ADMIN.EXAM_QUESTIONS " +
                  "(subject_code, question_text, correct_answer, created_by, created_date, ols_label) " +
                  "VALUES (?, ?, ?, ?, ?, CHAR_TO_LABEL('" + OLS_POLICY_NAME + "', ?))";
        Object[] params = new Object[]{
                question.getSubjectCode(),
                question.getQuestionText(),
                question.getCorrectAnswer(),
                createdBy,
                java.sql.Timestamp.valueOf(createdDate),
            effectiveLabel
        };

        System.out.println("[OLS] Creating question with label: " + effectiveLabel + " by user: " + createdBy);
        jdbcTemplate.update(sql, params);

        // Get the created question (with generated ID and label)
        String labelFilter = buildLabelFilterClause(true);
        String selectSql = "SELECT question_id, subject_code, question_text, correct_answer, " +
                          "created_by, created_date, ols_label " +
                          "FROM GMS_ADMIN.EXAM_QUESTIONS " +
                          "WHERE created_by = ?" + labelFilter +
                          " ORDER BY question_id DESC FETCH FIRST 1 ROW ONLY";

        List<ExamQuestion> results = jdbcTemplate.query(selectSql, examQuestionRowMapper, createdBy);
        
        if (results.isEmpty()) {
            throw new RuntimeException("Failed to create question or you don't have permission");
        }
        
        return results.get(0);
    }

    /**
     * Update an existing exam question
     * Validates that user has permission to update based on question's label
     * Note: Cannot change the OLS label of an existing row (Oracle restriction)
     */
    @Transactional
    public ExamQuestion updateQuestion(Long questionId, ExamQuestion updatedQuestion) {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        // First check if the question exists and user has access (via getQuestionById which applies label filter)
        ExamQuestion existing = getQuestionById(questionId);
        if (existing == null) {
            throw new RuntimeException("Question not found: " + questionId);
        }

        // Update the question with label filter to ensure user has write access
        String labelFilter = buildLabelFilterClause(true);
        String sql = "UPDATE GMS_ADMIN.EXAM_QUESTIONS SET " +
                     "subject_code = ?, " +
                     "question_text = ?, " +
                     "correct_answer = ? " +
                     "WHERE question_id = ?" + labelFilter;

        int rowsAffected = jdbcTemplate.update(sql,
                updatedQuestion.getSubjectCode() != null ? updatedQuestion.getSubjectCode() : existing.getSubjectCode(),
                updatedQuestion.getQuestionText() != null ? updatedQuestion.getQuestionText() : existing.getQuestionText(),
                updatedQuestion.getCorrectAnswer() != null ? updatedQuestion.getCorrectAnswer() : existing.getCorrectAnswer(),
                questionId);

        if (rowsAffected == 0) {
            throw new RuntimeException("Failed to update question. You may not have write permission for this label.");
        }

        // Return the updated question
        return getQuestionById(questionId);
    }

    /**
     * Delete an exam question
     * Validates that user has permission to delete based on question's label
     */
    @Transactional
    public void deleteQuestion(Long questionId) {
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser == null) {
            throw new RuntimeException("User not authenticated");
        }

        // First check if the question exists and user has access (via getQuestionById which applies label filter)
        ExamQuestion existing = getQuestionById(questionId);
        if (existing == null) {
            throw new RuntimeException("Question not found: " + questionId);
        }

        // Delete with label filter to ensure user has delete access
        String labelFilter = buildLabelFilterClause(true);
        String sql = "DELETE FROM GMS_ADMIN.EXAM_QUESTIONS WHERE question_id = ?" + labelFilter;
        int rowsAffected = jdbcTemplate.update(sql, questionId);

        if (rowsAffected == 0) {
            throw new RuntimeException("Failed to delete question. You may not have delete permission for this label.");
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

