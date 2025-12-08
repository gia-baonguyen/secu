package edu.university.grademanagement.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.sql.CallableStatement;
import java.sql.Connection;

/**
 * VPD Context Service
 * Sets Oracle VPD context for row-level security
 * Calls: gms_security_pkg.set_context(p_user_id, p_user_role)
 */
@Service
public class VpdContextService {

    @Autowired
    private DataSource dataSource;

    @Value("${vpd.context.enabled:true}")
    private boolean vpdEnabled;

    @Value("${vpd.context.package:gms_security_pkg}")
    private String vpdPackage;

    @Value("${vpd.context.name:gms_context}")
    private String vpdContextName;

    /**
     * Set VPD context for current session
     * 
     * NOTE: Oracle VPD context is session-specific. This method sets context in a connection
     * from the pool. The context will persist for that session/connection.
     * 
     * IMPORTANT: This is called by VpdContextInterceptor BEFORE each request, ensuring
     * context is set before any queries execute. With connection pooling, each request
     * may use a different connection, but context is set fresh for each request.
     *
     * @param userId User ID (e.g., STU001, LEC001)
     * @param userRole User role (e.g., STUDENT, LECTURER)
     * @throws Exception if context setting fails
     */
    public void setContext(String userId, String userRole) throws Exception {
        if (!vpdEnabled) {
            System.out.println("VPD context disabled, skipping set_context");
            return;
        }

        // Convert Spring Security role format (ADMIN, STUDENT, LECTURER) to VPD format (Admin, Student, Lecturer)
        String userType = convertRoleToUserType(userRole);

        // Get connection from pool and set context
        // Context is session-specific, so it will persist for this connection
        try (Connection conn = dataSource.getConnection()) {
            // Call Oracle procedure: GMS_ADMIN.gms_security_pkg.set_user_context(?, ?)
            String sql = String.format("BEGIN GMS_ADMIN.%s.set_user_context(?, ?); END;", vpdPackage);

            try (CallableStatement stmt = conn.prepareCall(sql)) {
                stmt.setString(1, userId);
                stmt.setString(2, userType);
                stmt.execute();

                System.out.println(String.format(
                    "VPD context set: user_id=%s, user_type=%s", userId, userType
                ));
            }
        } catch (Exception e) {
            System.err.println("Failed to set VPD context: " + e.getMessage());
            throw e;
        }
    }
    
    /**
     * Set VPD context using provided connection (for use within transactions)
     * This ensures context is set in the exact connection that will be used for queries
     *
     * @param conn Database connection (must be from current transaction)
     * @param userId User ID (e.g., STU001, LEC001)
     * @param userRole User role (e.g., STUDENT, LECTURER)
     * @throws Exception if context setting fails
     */
    public void setContext(Connection conn, String userId, String userRole) throws Exception {
        if (!vpdEnabled) {
            return;
        }

        String userType = convertRoleToUserType(userRole);
        String sql = String.format("BEGIN GMS_ADMIN.%s.set_user_context(?, ?); END;", vpdPackage);

        try (CallableStatement stmt = conn.prepareCall(sql)) {
            stmt.setString(1, userId);
            stmt.setString(2, userType);
            stmt.execute();
        } catch (Exception e) {
            System.err.println("Failed to set VPD context: " + e.getMessage());
            throw e;
        }
    }

    /**
     * Convert Spring Security role format to VPD user_type format
     * ADMIN -> Admin, STUDENT -> Student, LECTURER -> Lecturer
     * ACADEMIC_AFFAIRS -> Academic_Affairs, DEPARTMENT_HEAD -> Department_Head
     */
    private String convertRoleToUserType(String role) {
        if (role == null || role.isEmpty()) {
            return role;
        }

        // Handle compound roles with underscore (ACADEMIC_AFFAIRS, DEPARTMENT_HEAD)
        if (role.contains("_")) {
            String[] parts = role.split("_");
            StringBuilder result = new StringBuilder();
            for (int i = 0; i < parts.length; i++) {
                if (i > 0) result.append("_");
                // Capitalize first letter, lowercase rest
                result.append(parts[i].substring(0, 1).toUpperCase())
                      .append(parts[i].substring(1).toLowerCase());
            }
            return result.toString();
        }

        // Simple role: first letter uppercase, rest lowercase
        return role.substring(0, 1).toUpperCase() + role.substring(1).toLowerCase();
    }

    /**
     * Clear VPD context
     */
    public void clearContext() {
        if (!vpdEnabled) {
            return;
        }

        try (Connection conn = dataSource.getConnection()) {
            String sql = String.format("BEGIN GMS_ADMIN.%s.clear_user_context(); END;", vpdPackage);

            try (CallableStatement stmt = conn.prepareCall(sql)) {
                stmt.execute();
                System.out.println("VPD context cleared");
            }
        } catch (Exception e) {
            System.err.println("Failed to clear VPD context: " + e.getMessage());
        }
    }

    /**
     * Get current context values (for debugging)
     */
    public String getCurrentContext() {
        if (!vpdEnabled) {
            return "VPD disabled";
        }

        try (Connection conn = dataSource.getConnection();
             CallableStatement stmt = conn.prepareCall(
                 "BEGIN ? := SYS_CONTEXT(?, 'user_id'); ? := SYS_CONTEXT(?, 'user_type'); END;"
             )) {

            stmt.registerOutParameter(1, java.sql.Types.VARCHAR);
            stmt.setString(2, vpdContextName);
            stmt.registerOutParameter(3, java.sql.Types.VARCHAR);
            stmt.setString(4, vpdContextName);
            stmt.execute();

            String userId = stmt.getString(1);
            String userType = stmt.getString(3);

            return String.format("user_id=%s, user_type=%s", userId, userType);
        } catch (Exception e) {
            return "Error: " + e.getMessage();
        }
    }

    /**
     * Check if VPD is enabled
     */
    public boolean isVpdEnabled() {
        return vpdEnabled;
    }
}