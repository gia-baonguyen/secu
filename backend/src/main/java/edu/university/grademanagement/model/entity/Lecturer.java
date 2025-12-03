package edu.university.grademanagement.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

/**
 * Lecturer Entity
 * Represents a lecturer/teacher in the university
 */
@Entity
@Table(name = "LECTURERS")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Lecturer {

    @Id
    @Column(name = "lecturer_id", length = 10)
    private String lecturerId;

    @Column(name = "first_name", nullable = false, length = 50)
    private String firstName;

    @Column(name = "last_name", nullable = false, length = 50)
    private String lastName;

    @Column(name = "date_of_birth", nullable = false)
    private LocalDate dateOfBirth;

    @Column(name = "gender", length = 10)
    private String gender;

    @Column(name = "hometown", length = 100)
    private String hometown;

    @Column(name = "email", nullable = false, unique = true, length = 100)
    private String email;

    @Column(name = "phone_number", length = 20)
    private String phoneNumber;

    @Column(name = "contact_address", length = 200)
    private String contactAddress;

    @Column(name = "department_id")
    private String departmentId;

    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;

    @Column(name = "academic_degree", length = 50)
    private String academicDegree;

    @Column(name = "specialization", length = 100)
    private String specialization;

    @Column(name = "lecturer_status", length = 20)
    private String lecturerStatus = "Active";

    @Column(name = "created_date")
    private LocalDateTime createdDate;

    @Column(name = "updated_date")
    private LocalDateTime updatedDate;

    @PrePersist
    protected void onCreate() {
        createdDate = LocalDateTime.now();
        updatedDate = LocalDateTime.now();
        if (lecturerStatus == null) {
            lecturerStatus = "Active";
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedDate = LocalDateTime.now();
    }

    public String getFullName() {
        return firstName + " " + lastName;
    }

    public boolean isActive() {
        return "Active".equals(lecturerStatus);
    }
}