package edu.university.grademanagement.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * GradeSubmissionDeadline Entity
 * Represents deadline for grade submission per semester
 */
@Entity
@Table(name = "GRADE_SUBMISSION_DEADLINES", schema = "GMS_ADMIN")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class GradeSubmissionDeadline {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "deadline_id")
    private Long deadlineId;

    @Column(name = "semester", nullable = false, length = 10)
    private String semester;

    @Column(name = "academic_year", nullable = false)
    private Integer academicYear;

    @Column(name = "submission_deadline", nullable = false)
    private LocalDate submissionDeadline;

    @Column(name = "is_active", length = 1)
    private String isActive = "Y";

    @Column(name = "created_by", length = 10)
    private String createdBy;

    @Column(name = "created_date")
    private LocalDateTime createdDate;

    @Column(name = "updated_date")
    private LocalDateTime updatedDate;

    @PrePersist
    protected void onCreate() {
        createdDate = LocalDateTime.now();
        updatedDate = LocalDateTime.now();
        if (isActive == null) {
            isActive = "Y";
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedDate = LocalDateTime.now();
    }

    public boolean isActiveDeadline() {
        return "Y".equals(isActive);
    }

    public boolean isPastDeadline() {
        return LocalDate.now().isAfter(submissionDeadline);
    }

    public boolean isBeforeDeadline() {
        return !isPastDeadline();
    }
}

