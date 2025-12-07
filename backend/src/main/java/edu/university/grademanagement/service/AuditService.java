package edu.university.grademanagement.service;

import edu.university.grademanagement.model.entity.AuditLog;
import edu.university.grademanagement.repository.AuditLogRepository;
import edu.university.grademanagement.security.UserPrincipal;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Audit Service
 * Business logic for audit logging operations
 */
@Service
public class AuditService {

    @Autowired
    private AuditLogRepository auditLogRepository;

    /**
     * Log an operation
     */
    public AuditLog logOperation(String tableName, String operation, String recordId, String oldValues, String newValues) {
        AuditLog auditLog = new AuditLog();
        auditLog.setTableName(tableName);
        auditLog.setOperation(operation);
        auditLog.setRecordId(recordId);
        auditLog.setOldValues(oldValues);
        auditLog.setNewValues(newValues);
        auditLog.setOperationDate(LocalDateTime.now());

        // Get current user
        UserPrincipal currentUser = getCurrentUser();
        if (currentUser != null) {
            auditLog.setUserId(currentUser.getUserId());
            auditLog.setUsername(currentUser.getUsername());
        }

        // Get IP address and session ID
        try {
            ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attrs != null) {
                HttpServletRequest request = attrs.getRequest();
                auditLog.setIpAddress(getClientIpAddress(request));
                auditLog.setSessionId(request.getSession(false) != null ? request.getSession().getId() : null);
            }
        } catch (Exception e) {
            // Ignore if request context not available
        }

        return auditLogRepository.save(auditLog);
    }

    /**
     * Log INSERT operation
     */
    public AuditLog logInsert(String tableName, String recordId, String newValues) {
        return logOperation(tableName, "INSERT", recordId, null, newValues);
    }

    /**
     * Log UPDATE operation
     */
    public AuditLog logUpdate(String tableName, String recordId, String oldValues, String newValues) {
        return logOperation(tableName, "UPDATE", recordId, oldValues, newValues);
    }

    /**
     * Log DELETE operation
     */
    public AuditLog logDelete(String tableName, String recordId, String oldValues) {
        return logOperation(tableName, "DELETE", recordId, oldValues, null);
    }

    /**
     * Log SELECT operation (for sensitive data access)
     */
    public AuditLog logSelect(String tableName, String recordId) {
        return logOperation(tableName, "SELECT", recordId, null, null);
    }

    /**
     * Get all audit logs
     */
    public List<AuditLog> getAllLogs() {
        return auditLogRepository.findRecentLogs();
    }

    /**
     * Get logs by table name
     */
    public List<AuditLog> getLogsByTable(String tableName) {
        return auditLogRepository.findByTableName(tableName);
    }

    /**
     * Get logs by user ID
     */
    public List<AuditLog> getLogsByUser(String userId) {
        return auditLogRepository.findByUserId(userId);
    }

    /**
     * Get logs by operation type
     */
    public List<AuditLog> getLogsByOperation(String operation) {
        return auditLogRepository.findByOperation(operation);
    }

    /**
     * Get logs between dates
     */
    public List<AuditLog> getLogsByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        return auditLogRepository.findByOperationDateBetween(startDate, endDate);
    }

    /**
     * Get logs for a specific record
     */
    public List<AuditLog> getLogsForRecord(String tableName, String recordId) {
        return auditLogRepository.findByTableNameAndRecordId(tableName, recordId);
    }

    /**
     * Get audit statistics by table
     */
    public Map<String, Long> getStatsByTable() {
        List<Object[]> results = auditLogRepository.countByTable();
        Map<String, Long> stats = new HashMap<>();
        for (Object[] result : results) {
            stats.put((String) result[0], (Long) result[1]);
        }
        return stats;
    }

    /**
     * Get audit statistics by user
     */
    public Map<String, Long> getStatsByUser(String userId) {
        List<Object[]> results = auditLogRepository.countOperationsByUser(userId);
        Map<String, Long> stats = new HashMap<>();
        for (Object[] result : results) {
            stats.put((String) result[0], (Long) result[1]);
        }
        return stats;
    }

    /**
     * Get current authenticated user
     */
    private UserPrincipal getCurrentUser() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof UserPrincipal) {
            return (UserPrincipal) authentication.getPrincipal();
        }
        return null;
    }

    /**
     * Get client IP address from request
     */
    private String getClientIpAddress(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty()) {
            return xRealIp;
        }
        return request.getRemoteAddr();
    }
}

