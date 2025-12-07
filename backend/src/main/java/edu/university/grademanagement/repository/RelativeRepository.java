package edu.university.grademanagement.repository;

import edu.university.grademanagement.model.entity.Relative;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository for Relative entity
 * Handles database operations for relative data
 */
@Repository
public interface RelativeRepository extends JpaRepository<Relative, String> {

    /**
     * Find relative by relative ID
     */
    Optional<Relative> findByRelativeId(String relativeId);

    /**
     * Find relative by phone number
     */
    Optional<Relative> findByPhoneNumber(String phoneNumber);

    /**
     * Find relative by email
     */
    Optional<Relative> findByEmail(String email);

    /**
     * Check if relative exists by phone number
     */
    boolean existsByPhoneNumber(String phoneNumber);

    /**
     * Check if relative exists by email
     */
    boolean existsByEmail(String email);

    /**
     * Find relatives by first name and last name
     */
    List<Relative> findByFirstNameAndLastName(String firstName, String lastName);
}

