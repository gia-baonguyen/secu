package edu.university.grademanagement.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "COURSE_SECTIONS", schema = "GMS_ADMIN")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CourseSection {

    @Id
    @Column(name = "section_id", length = 10)
    private String sectionId;

    @Column(name = "course_id", length = 10)
    private String courseId;

    @Column(name = "lecturer_id", length = 10)
    private String lecturerId;

    @Column(name = "semester", length = 6)
    private String semester;

    @Column(name = "academic_year", length = 9)
    private String academicYear;

    @Column(name = "max_students")
    private Integer maxStudents;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
