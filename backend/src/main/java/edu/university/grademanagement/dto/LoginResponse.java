package edu.university.grademanagement.dto;

/**
 * Login Response DTO
 */
public class LoginResponse {

    private String accessToken;
    private String tokenType = "Bearer";
    private String userId;
    private String email;
    private String role;
    private Long expiresIn;

    public LoginResponse(String accessToken, String userId, String email, String role, Long expiresIn) {
        this.accessToken = accessToken;
        this.userId = userId;
        this.email = email;
        this.role = role;
        this.expiresIn = expiresIn;
    }

    // Getters and setters
    public String getAccessToken() {
        return accessToken;
    }

    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }

    public String getTokenType() {
        return tokenType;
    }

    public void setTokenType(String tokenType) {
        this.tokenType = tokenType;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public Long getExpiresIn() {
        return expiresIn;
    }

    public void setExpiresIn(Long expiresIn) {
        this.expiresIn = expiresIn;
    }
}
