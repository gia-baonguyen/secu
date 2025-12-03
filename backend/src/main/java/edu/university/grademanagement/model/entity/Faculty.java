package edu.university.grademanagement.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "FACULTIES", schema = "GMS_ADMIN")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Faculty {

    @Id
    @Column(name = "faculty_id", length = 10)
    private String facultyId;

    @Column(name = "faculty_name", nullable = false, length = 100)
    private String facultyName;

    @Column(name = "dean_id", length = 10)
    private String deanId;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
