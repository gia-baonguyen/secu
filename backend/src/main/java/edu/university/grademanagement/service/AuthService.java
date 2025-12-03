package edu.university.grademanagement.service;

import edu.university.grademanagement.security.JwtTokenProvider;
import edu.university.grademanagement.security.UserPrincipal;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

/**
 * Authentication Service
 * Handles user login, JWT generation, and VPD context setup
 */
@Service
public class AuthService {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Autowired
    private VpdContextService vpdContextService;

    /**
     * Authenticate user and return JWT token
     *
     * @param username Username or email
     * @param password Password (note: in Oracle auth, this might be validated differently)
     * @return JWT access token
     */
    public String login(String username, String password) {
        // For MVP: We're using Spring Security authentication
        // In production, you might validate against Oracle database user passwords

        // Authenticate user
        Authentication authentication = authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(username, password)
        );

        // Set authentication in security context
        SecurityContextHolder.getContext().setAuthentication(authentication);

        // Get user details
        UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();

        // Set VPD context for this user
        try {
            vpdContextService.setContext(
                userPrincipal.getUserId(),
                userPrincipal.getRole()
            );
        } catch (Exception e) {
            System.err.println("Warning: Failed to set VPD context during login: " + e.getMessage());
            // Continue anyway - VPD will apply default restrictions
        }

        // Generate JWT token
        String token = jwtTokenProvider.generateToken(authentication);

        return token;
    }

    /**
     * Generate refresh token
     */
    public String refreshToken(String username, String role) {
        return jwtTokenProvider.generateRefreshToken(username, role);
    }

    /**
     * Logout user (clear security context)
     */
    public void logout() {
        // Clear Spring Security context
        SecurityContextHolder.clearContext();

        // Clear VPD context
        vpdContextService.clearContext();
    }

    /**
     * Get current authenticated user
     */
    public UserPrincipal getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication != null && authentication.getPrincipal() instanceof UserPrincipal) {
            return (UserPrincipal) authentication.getPrincipal();
        }

        return null;
    }

    /**
     * Check if user is authenticated
     */
    public boolean isAuthenticated() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        return authentication != null && authentication.isAuthenticated()
            && authentication.getPrincipal() instanceof UserPrincipal;
    }
}
