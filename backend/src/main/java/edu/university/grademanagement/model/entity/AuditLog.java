package edu.university.grademanagement.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * AuditLog Entity
 * Represents audit trail entries for data changes
 */
@Entity
@Table(name = "AUDIT_LOG", schema = "GMS_ADMIN")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuditLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "log_id")
    private Long logId;

    @Column(name = "table_name", nullable = false, length = 30)
    private String tableName;

    @Column(name = "operation", nullable = false, length = 10)
    private String operation;

    @Column(name = "user_id", length = 10)
    private String userId;

    @Column(name = "username", length = 50)
    private String username;

    @Column(name = "record_id", length = 50)
    private String recordId;

    @Lob
    @Column(name = "old_values")
    private String oldValues;

    @Lob
    @Column(name = "new_values")
    private String newValues;

    @Column(name = "operation_date")
    private LocalDateTime operationDate;

    @Column(name = "ip_address", length = 50)
    private String ipAddress;

    @Column(name = "session_id", length = 100)
    private String sessionId;

    @PrePersist
    protected void onCreate() {
        if (operationDate == null) {
            operationDate = LocalDateTime.now();
        }
    }

    public boolean isInsert() {
        return "INSERT".equals(operation);
    }

    public boolean isUpdate() {
        return "UPDATE".equals(operation);
    }

    public boolean isDelete() {
        return "DELETE".equals(operation);
    }

    public boolean isSelect() {
        return "SELECT".equals(operation);
    }
}

