package edu.university.grademanagement.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "ENROLLMENTS", schema = "GMS_ADMIN")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Enrollment {

    @Id
    @Column(name = "enrollment_id", length = 10)
    private String enrollmentId;

    @Column(name = "student_id", length = 10)
    private String studentId;

    @Column(name = "section_id", length = 10)
    private String sectionId;

    @Column(name = "enrollment_date")
    private LocalDateTime enrollmentDate;

    @Column(name = "enrollment_status", length = 20)
    private String status;

    @Column(name = "created_date")
    private LocalDateTime createdDate;

    @Column(name = "updated_date")
    private LocalDateTime updatedDate;
}
