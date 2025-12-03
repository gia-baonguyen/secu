package edu.university.grademanagement.repository;

import edu.university.grademanagement.model.entity.Lecturer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface LecturerRepository extends JpaRepository<Lecturer, String> {
    Optional<Lecturer> findByLecturerId(String lecturerId);
}
