package edu.university.grademanagement.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Course Entity
 * Represents a course in the university
 */
@Entity
@Table(name = "COURSES", schema = "GMS_ADMIN")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Course {

    @Id
    @Column(name = "course_id", length = 10)
    private String courseId;

    @Column(name = "course_name", nullable = false, length = 100)
    private String courseName;

    @Column(name = "credits", nullable = false)
    private Integer credits;

    @Column(name = "department_id", nullable = false, length = 10)
    private String departmentId;

    @Column(name = "course_type", length = 20)
    private String courseType;

    @Column(name = "prerequisite_course_id", length = 10)
    private String prerequisiteCourseId;

    @Column(name = "description", length = 500)
    private String description;

    @Column(name = "created_date")
    private LocalDateTime createdDate;

    @Column(name = "updated_date")
    private LocalDateTime updatedDate;

    @PrePersist
    protected void onCreate() {
        createdDate = LocalDateTime.now();
        updatedDate = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedDate = LocalDateTime.now();
    }

    public boolean isMandatory() {
        return "Mandatory".equals(courseType);
    }

    public boolean isElective() {
        return "Elective".equals(courseType);
    }

    public boolean hasPrerequisite() {
        return prerequisiteCourseId != null && !prerequisiteCourseId.isEmpty();
    }
}

