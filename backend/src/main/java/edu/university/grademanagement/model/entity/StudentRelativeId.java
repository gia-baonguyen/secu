package edu.university.grademanagement.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

/**
 * Composite Primary Key for StudentRelative entity
 */
@Embeddable
@Data
@NoArgsConstructor
@AllArgsConstructor
public class StudentRelativeId implements Serializable {

    @Column(name = "student_id", length = 10)
    private String studentId;

    @Column(name = "relative_id", length = 10)
    private String relativeId;
}

