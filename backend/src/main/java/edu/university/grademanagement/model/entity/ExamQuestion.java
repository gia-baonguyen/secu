package edu.university.grademanagement.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * ExamQuestion Entity
 * Represents exam questions protected by Oracle Label Security (OLS)
 * OLS automatically filters data based on user's label authorization
 */
@Entity
@Table(name = "EXAM_QUESTIONS", schema = "GMS_ADMIN")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ExamQuestion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "question_id")
    private Long questionId;

    @Column(name = "subject_code", length = 10)
    private String subjectCode;

    @Column(name = "question_text", length = 500)
    private String questionText;

    @Column(name = "correct_answer", length = 200)
    private String correctAnswer;

    @Column(name = "created_by", length = 50)
    private String createdBy;

    @Column(name = "created_date")
    private LocalDateTime createdDate;

    /**
     * OLS label column (read-only, managed by Oracle Label Security)
     * This is a numeric label that Oracle uses internally
     * insertable=false, updatable=false because OLS manages this
     */
    @Column(name = "ols_label", insertable = false, updatable = false)
    private Long olsLabel;

    /**
     * Transient field for security label string (e.g., "PUB", "INT:CS", "CONF:CS")
     * This is populated by the service layer using LABEL_TO_CHAR() function
     * Not persisted in database
     */
  
    @PrePersist
    protected void onCreate() {
        if (createdDate == null) {
            createdDate = LocalDateTime.now();
        }
    }

   
}

