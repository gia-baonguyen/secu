package edu.university.grademanagement.controller;

import edu.university.grademanagement.dto.ApiResponse;
import edu.university.grademanagement.dto.LoginRequest;
import edu.university.grademanagement.dto.LoginResponse;
import edu.university.grademanagement.security.UserPrincipal;
import edu.university.grademanagement.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Authentication Controller
 * Handles login, logout, and user profile endpoints
 */
@RestController
@RequestMapping("/auth")
@CrossOrigin(origins = "${security.cors.allowed-origins}")
public class AuthController {

    @Autowired
    private AuthService authService;

    @Value("${jwt.expiration}")
    private Long jwtExpiration;

    /**
     * Login endpoint
     * POST /auth/login
     */
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<LoginResponse>> login(@Valid @RequestBody LoginRequest loginRequest) {
        try {
            // Authenticate and get JWT token
            String token = authService.login(loginRequest.getUsername(), loginRequest.getPassword());

            // Get current user info
            UserPrincipal currentUser = authService.getCurrentUser();

            if (currentUser == null) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("Authentication failed"));
            }

            // Create response
            LoginResponse loginResponse = new LoginResponse(
                    token,
                    currentUser.getUserId(),
                    currentUser.getEmail(),
                    currentUser.getRole(),
                    jwtExpiration
            );

            return ResponseEntity.ok(ApiResponse.success("Login successful", loginResponse));

        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Login failed: " + e.getMessage()));
        }
    }

    /**
     * Get current user profile
     * GET /auth/profile
     */
    @GetMapping("/profile")
    public ResponseEntity<ApiResponse<UserPrincipal>> getProfile() {
        try {
            UserPrincipal currentUser = authService.getCurrentUser();

            if (currentUser == null) {
                return ResponseEntity.status(401)
                        .body(ApiResponse.error("Not authenticated"));
            }

            return ResponseEntity.ok(ApiResponse.success(currentUser));

        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to get profile: " + e.getMessage()));
        }
    }

    /**
     * Logout endpoint
     * POST /auth/logout
     */
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<String>> logout() {
        try {
            authService.logout();
            return ResponseEntity.ok(ApiResponse.success("Logout successful", null));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Logout failed: " + e.getMessage()));
        }
    }

    /**
     * Health check endpoint
     * GET /auth/health
     */
    @GetMapping("/health")
    public ResponseEntity<ApiResponse<String>> health() {
        return ResponseEntity.ok(ApiResponse.success("Auth service is running", "OK"));
    }
}
