package edu.university.grademanagement.controller;

import edu.university.grademanagement.dto.ApiResponse;
import edu.university.grademanagement.model.entity.ExamQuestion;
import edu.university.grademanagement.service.ExamQuestionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Controller for ExamQuestion operations
 * OLS (Oracle Label Security) automatically filters data based on user's authorization:
 * - STUDENT: Only sees PUB (public questions)
 * - LECTURER: Sees PUB + INT:CS (public + internal CS questions)
 * - DEAN: Sees PUB + INT:CS + CONF:CS (all CS labels including confidential)
 * - ADMIN: Sees all labels (bypass OLS)
 */
@RestController
@RequestMapping("/exam-questions")
@CrossOrigin(origins = "${security.cors.allowed-origins}")
public class ExamQuestionController {

    @Autowired
    private ExamQuestionService examQuestionService;

    /**
     * Get all exam questions
     * GET /api/exam-questions
     * All roles can access - OLS automatically filters results
     */
    @GetMapping
    @PreAuthorize("hasAnyRole('STUDENT', 'LECTURER', 'DEAN', 'ADMIN')")
    public ResponseEntity<ApiResponse<List<ExamQuestion>>> getAllQuestions() {
        try {
            List<ExamQuestion> questions = examQuestionService.getAllQuestions();
            return ResponseEntity.ok(ApiResponse.success(questions));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get questions: " + e.getMessage()));
        }
    }

    /**
     * Get exam question by ID
     * GET /api/exam-questions/{id}
     * All roles can access - OLS checks permission
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('STUDENT', 'LECTURER', 'DEAN', 'ADMIN')")
    public ResponseEntity<ApiResponse<ExamQuestion>> getQuestionById(@PathVariable Long id) {
        try {
            ExamQuestion question = examQuestionService.getQuestionById(id);
            return ResponseEntity.ok(ApiResponse.success(question));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get question: " + e.getMessage()));
        }
    }

    /**
     * Get questions by subject code
     * GET /api/exam-questions/subject/{subjectCode}
     * All roles can access - OLS automatically filters results
     */
    @GetMapping("/subject/{subjectCode}")
    @PreAuthorize("hasAnyRole('STUDENT', 'LECTURER', 'DEAN', 'ADMIN')")
    public ResponseEntity<ApiResponse<List<ExamQuestion>>> getQuestionsBySubject(
            @PathVariable String subjectCode) {
        try {
            List<ExamQuestion> questions = examQuestionService.getQuestionsBySubject(subjectCode);
            return ResponseEntity.ok(ApiResponse.success(questions));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get questions: " + e.getMessage()));
        }
    }

    /**
     * Search questions by keyword
     * GET /api/exam-questions/search?keyword=xxx
     * All roles can access - OLS automatically filters results
     */
    @GetMapping("/search")
    @PreAuthorize("hasAnyRole('STUDENT', 'LECTURER', 'DEAN', 'ADMIN')")
    public ResponseEntity<ApiResponse<List<ExamQuestion>>> searchQuestions(
            @RequestParam String keyword) {
        try {
            List<ExamQuestion> questions = examQuestionService.searchQuestions(keyword);
            return ResponseEntity.ok(ApiResponse.success(questions));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to search questions: " + e.getMessage()));
        }
    }

    /**
     * Get available security labels for current user
     * GET /api/exam-questions/labels
     * Returns labels that current user can use when creating questions
     */
    @GetMapping("/labels")
    @PreAuthorize("hasAnyRole('LECTURER', 'DEAN', 'ADMIN')")
    public ResponseEntity<ApiResponse<List<String>>> getAvailableLabels() {
        try {
            List<String> labels = examQuestionService.getAvailableLabels();
            return ResponseEntity.ok(ApiResponse.success(labels));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get labels: " + e.getMessage()));
        }
    }

    /**
     * Create a new exam question
     * POST /api/exam-questions
     * Body: { "subjectCode": "CS101", "questionText": "...", "correctAnswer": "...", "securityLabel": "PUB" }
     * Only LECTURER, DEAN, ADMIN can create
     * - LECTURER can create with PUB or INT:CS labels
     * - DEAN can create with PUB, INT:CS, or CONF:CS labels
     * - ADMIN can create with any label
     */
    @PostMapping
    @PreAuthorize("hasAnyRole('LECTURER', 'DEAN', 'ADMIN')")
    public ResponseEntity<ApiResponse<ExamQuestion>> createQuestion(
            @RequestBody Map<String, Object> requestBody) {
        try {
            ExamQuestion question = new ExamQuestion();
            question.setSubjectCode((String) requestBody.get("subjectCode"));
            question.setQuestionText((String) requestBody.get("questionText"));
            question.setCorrectAnswer((String) requestBody.get("correctAnswer"));
            
            String securityLabel = (String) requestBody.get("securityLabel");
            
            ExamQuestion created = examQuestionService.createQuestion(question, securityLabel);
            return ResponseEntity.ok(ApiResponse.success("Question created successfully", created));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to create question: " + e.getMessage()));
        }
    }

    /**
     * Update an exam question
     * PUT /api/exam-questions/{id}
     * Body: { "subjectCode": "CS101", "questionText": "...", "correctAnswer": "..." }
     * Only LECTURER, DEAN, ADMIN can update
     * OLS checks if user has write permission for the question's label
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('LECTURER', 'DEAN', 'ADMIN')")
    public ResponseEntity<ApiResponse<ExamQuestion>> updateQuestion(
            @PathVariable Long id,
            @RequestBody ExamQuestion updatedQuestion) {
        try {
            ExamQuestion updated = examQuestionService.updateQuestion(id, updatedQuestion);
            return ResponseEntity.ok(ApiResponse.success("Question updated successfully", updated));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to update question: " + e.getMessage()));
        }
    }

    /**
     * Delete an exam question
     * DELETE /api/exam-questions/{id}
     * Only DEAN and ADMIN can delete
     * OLS checks if user has permission to delete the question's label
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('DEAN', 'ADMIN')")
    public ResponseEntity<ApiResponse<Void>> deleteQuestion(@PathVariable Long id) {
        try {
            examQuestionService.deleteQuestion(id);
            return ResponseEntity.ok(ApiResponse.success("Question deleted successfully", null));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to delete question: " + e.getMessage()));
        }
    }
}

