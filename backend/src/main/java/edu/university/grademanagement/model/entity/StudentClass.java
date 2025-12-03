package edu.university.grademanagement.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "STUDENT_CLASSES", schema = "GMS_ADMIN")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class StudentClass {

    @Id
    @Column(name = "class_id", length = 10)
    private String classId;

    @Column(name = "class_name", nullable = false, length = 50)
    private String className;

    @Column(name = "faculty_id", length = 10)
    private String facultyId;

    @Column(name = "advisor_id", length = 10)
    private String advisorId;

    @Column(name = "academic_year", length = 9)
    private String academicYear;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
