package edu.university.grademanagement.model.entity;

import jakarta.persistence.*;

/**
 * SystemUser Entity
 * Maps to SYSTEM_USERS table
 * Stores authentication credentials for all user types
 */
@Entity
@Table(name = "SYSTEM_USERS", schema = "GMS_ADMIN")
public class SystemUser {

    @Id
    @Column(name = "user_id", length = 10)
    private String userId;

    @Column(name = "username", nullable = false, unique = true, length = 50)
    private String username;

    @Column(name = "password_hash", nullable = false, length = 255)
    private String passwordHash;

    @Column(name = "user_type", nullable = false, length = 20)
    private String userType;  // Student, Lecturer, Dean, etc.

    @Column(name = "reference_id", nullable = false, length = 10)
    private String referenceId;  // STU001, LEC001, etc.

    @Column(name = "is_active", length = 1)
    private String isActiveFlag;  // 'Y' or 'N'

    public SystemUser() {
    }

    public SystemUser(String userId, String username, String passwordHash, String userType, String referenceId, String isActiveFlag) {
        this.userId = userId;
        this.username = username;
        this.passwordHash = passwordHash;
        this.userType = userType;
        this.referenceId = referenceId;
        this.isActiveFlag = isActiveFlag;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getUserType() {
        return userType;
    }

    public void setUserType(String userType) {
        this.userType = userType;
    }

    public String getReferenceId() {
        return referenceId;
    }

    public void setReferenceId(String referenceId) {
        this.referenceId = referenceId;
    }

    public String getIsActiveFlag() {
        return isActiveFlag;
    }

    public void setIsActiveFlag(String isActiveFlag) {
        this.isActiveFlag = isActiveFlag;
    }

    /**
     * Check if user account is active
     */
    public boolean isActive() {
        return "Y".equals(isActiveFlag);
    }
}
