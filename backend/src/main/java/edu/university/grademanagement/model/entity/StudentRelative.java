package edu.university.grademanagement.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * StudentRelative Entity
 * Junction table linking students to their relatives
 */
@Entity
@Table(name = "STUDENT_RELATIVES", schema = "GMS_ADMIN")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class StudentRelative {

    @EmbeddedId
    private StudentRelativeId id;

    @Column(name = "relationship", nullable = false, length = 50)
    private String relationship;

    @Column(name = "is_primary_contact", length = 1)
    private String isPrimaryContact = "N";

    @Column(name = "created_date")
    private LocalDateTime createdDate;

    @PrePersist
    protected void onCreate() {
        createdDate = LocalDateTime.now();
        if (isPrimaryContact == null) {
            isPrimaryContact = "N";
        }
    }

    public boolean isPrimary() {
        return "Y".equals(isPrimaryContact);
    }

    public String getStudentId() {
        return id != null ? id.getStudentId() : null;
    }

    public String getRelativeId() {
        return id != null ? id.getRelativeId() : null;
    }
}

