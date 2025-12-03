package edu.university.grademanagement.repository;

import edu.university.grademanagement.model.entity.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repository for Student entity
 * Handles database operations for student data
 */
@Repository
public interface StudentRepository extends JpaRepository<Student, String> {

    /**
     * Find student by student ID
     */
    Optional<Student> findByStudentId(String studentId);

    /**
     * Find student by email
     */
    Optional<Student> findByEmail(String email);

    /**
     * Find all students in a specific class
     */
    @Query("SELECT s FROM Student s WHERE s.classId = :classId")
    java.util.List<Student> findByClassId(@Param("classId") String classId);

    /**
     * Check if student exists by email
     */
    boolean existsByEmail(String email);

    /**
     * Check if student exists by student ID
     */
    boolean existsByStudentId(String studentId);
}
