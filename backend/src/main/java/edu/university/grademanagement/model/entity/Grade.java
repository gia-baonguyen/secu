package edu.university.grademanagement.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Grade Entity
 * Represents student grades for a course
 */
@Entity
@Table(name = "GRADES")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Grade {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "grade_id")
    private Long gradeId;

    @Column(name = "enrollment_id")
    private String enrollmentId;

    @Column(name = "midterm_score", precision = 4, scale = 2)
    private BigDecimal midtermScore;

    @Column(name = "final_score", precision = 4, scale = 2)
    private BigDecimal finalScore;

    @Column(name = "total_score", precision = 4, scale = 2)
    private BigDecimal totalScore;

    @Column(name = "letter_grade", length = 2)
    private String letterGrade;

    @Column(name = "grade_status", length = 20)
    private String gradeStatus = "Pending";

    @Column(name = "submitted_by", length = 10)
    private String submittedBy;

    @Column(name = "submitted_date")
    private LocalDateTime submittedDate;

    @Column(name = "approved_by", length = 10)
    private String approvedBy;

    @Column(name = "approved_date")
    private LocalDateTime approvedDate;

    @Column(name = "modified_by", length = 10)
    private String modifiedBy;

    @Column(name = "modified_date")
    private LocalDateTime modifiedDate;

    @Column(name = "modification_reason", length = 500)
    private String modificationReason;

    @Column(name = "created_date")
    private LocalDateTime createdDate;

    @Column(name = "updated_date")
    private LocalDateTime updatedDate;

    @PrePersist
    protected void onCreate() {
        createdDate = LocalDateTime.now();
        updatedDate = LocalDateTime.now();
        if (gradeStatus == null) {
            gradeStatus = "Pending";
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedDate = LocalDateTime.now();
        calculateTotalScore();
        calculateLetterGrade();
    }

    /**
     * Calculate total score based on midterm and final scores
     * Weighted average: Midterm 40%, Final 60%
     */
    public void calculateTotalScore() {
        if (midtermScore != null && finalScore != null) {
            BigDecimal midtermWeight = new BigDecimal("0.4");
            BigDecimal finalWeight = new BigDecimal("0.6");

            BigDecimal weightedMidterm = midtermScore.multiply(midtermWeight);
            BigDecimal weightedFinal = finalScore.multiply(finalWeight);

            totalScore = weightedMidterm.add(weightedFinal).setScale(2, BigDecimal.ROUND_HALF_UP);
        }
    }

    /**
     * Calculate letter grade based on total score
     */
    public void calculateLetterGrade() {
        if (totalScore == null) {
            letterGrade = null;
            return;
        }

        double score = totalScore.doubleValue();

        if (score >= 9.0) {
            letterGrade = "A+";
        } else if (score >= 8.5) {
            letterGrade = "A";
        } else if (score >= 8.0) {
            letterGrade = "B+";
        } else if (score >= 7.0) {
            letterGrade = "B";
        } else if (score >= 6.5) {
            letterGrade = "C+";
        } else if (score >= 5.5) {
            letterGrade = "C";
        } else if (score >= 5.0) {
            letterGrade = "D";
        } else {
            letterGrade = "F";
        }
    }

    public boolean isPending() {
        return "Pending".equals(gradeStatus);
    }

    public boolean isSubmitted() {
        return "Submitted".equals(gradeStatus);
    }

    public boolean isApproved() {
        return "Approved".equals(gradeStatus);
    }

    public boolean isModified() {
        return "Modified".equals(gradeStatus);
    }

    public boolean isPassed() {
        return totalScore != null && totalScore.doubleValue() >= 5.0;
    }
}