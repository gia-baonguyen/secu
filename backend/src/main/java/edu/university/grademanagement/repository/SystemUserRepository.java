package edu.university.grademanagement.repository;

import edu.university.grademanagement.model.entity.SystemUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * SystemUser Repository
 * Access SYSTEM_USERS table for authentication
 */
@Repository
public interface SystemUserRepository extends JpaRepository<SystemUser, String> {

    /**
     * Find user by username
     */
    Optional<SystemUser> findByUsername(String username);

    /**
     * Find user by reference ID (STU001, LEC001, etc.)
     */
    Optional<SystemUser> findByReferenceId(String referenceId);

    /**
     * Find active user by username
     */
    @Query("SELECT u FROM SystemUser u WHERE u.username = :username AND u.isActiveFlag = 'Y'")
    Optional<SystemUser> findActiveUserByUsername(@Param("username") String username);

    /**
     * Check if username exists
     */
    boolean existsByUsername(String username);
}
