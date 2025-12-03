package edu.university.grademanagement.security;

import edu.university.grademanagement.model.entity.Student;
import edu.university.grademanagement.model.entity.SystemUser;
import edu.university.grademanagement.repository.StudentRepository;
import edu.university.grademanagement.repository.SystemUserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Optional;

/**
 * Custom UserDetailsService
 * Loads user credentials from SYSTEM_USERS table
 * Supports login by username or email
 */
@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private SystemUserRepository systemUserRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // First try to find by username in SYSTEM_USERS
        Optional<SystemUser> systemUser = systemUserRepository.findByUsername(username);

        // If not found by username, try to find by email in STUDENTS table
        if (!systemUser.isPresent()) {
            Optional<Student> studentByEmail = studentRepository.findByEmail(username);
            if (studentByEmail.isPresent()) {
                String studentId = getStudentId(studentByEmail.get());
                systemUser = systemUserRepository.findByReferenceId(studentId);
            }
        }

        if (!systemUser.isPresent()) {
            throw new UsernameNotFoundException("User not found with username/email: " + username);
        }

        SystemUser user = systemUser.get();

        // Check if user is active
        if (!user.isActive()) {
            throw new UsernameNotFoundException("User account is inactive: " + username);
        }

        return createUserPrincipal(user);
    }

    /**
     * Load user by ID (used after JWT validation)
     */
    public UserDetails loadUserById(String userId) throws UsernameNotFoundException {
        SystemUser systemUser = systemUserRepository.findByReferenceId(userId)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with id: " + userId));

        if (!systemUser.isActive()) {
            throw new UsernameNotFoundException("User account is inactive: " + userId);
        }

        return createUserPrincipal(systemUser);
    }

    /**
     * Create UserPrincipal from SystemUser entity
     * NOW LOADS ACTUAL PASSWORD HASH FROM DATABASE!
     */
    private UserPrincipal createUserPrincipal(SystemUser systemUser) {
        return new UserPrincipal(
                systemUser.getReferenceId(),      // userId (STU001, LEC001, etc.)
                systemUser.getUsername(),          // username
                systemUser.getUsername(),          // email (using username as email for now)
                systemUser.getPasswordHash(),      // ACTUAL password hash from SYSTEM_USERS!
                systemUser.getUserType().toUpperCase(),  // role (STUDENT, LECTURER, etc.)
                systemUser.isActive()              // active status
        );
    }

    // Helper method to safely access Student ID using reflection
    private String getStudentId(Student student) {
        try {
            java.lang.reflect.Field field = student.getClass().getDeclaredField("studentId");
            field.setAccessible(true);
            return (String) field.get(student);
        } catch (Exception e) {
            return null;
        }
    }
}
