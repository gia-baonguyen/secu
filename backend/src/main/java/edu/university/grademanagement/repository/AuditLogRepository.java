package edu.university.grademanagement.repository;

import edu.university.grademanagement.model.entity.AuditLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Repository for AuditLog entity
 * Handles database operations for audit log entries
 */
@Repository
public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {

    /**
     * Find logs by table name
     */
    List<AuditLog> findByTableName(String tableName);

    /**
     * Find logs by user ID
     */
    List<AuditLog> findByUserId(String userId);

    /**
     * Find logs by operation type
     */
    List<AuditLog> findByOperation(String operation);

    /**
     * Find logs between dates
     */
    @Query("SELECT a FROM AuditLog a WHERE a.operationDate BETWEEN :startDate AND :endDate ORDER BY a.operationDate DESC")
    List<AuditLog> findByOperationDateBetween(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    /**
     * Find logs by table and operation
     */
    List<AuditLog> findByTableNameAndOperation(String tableName, String operation);

    /**
     * Find logs by user ID and table
     */
    List<AuditLog> findByUserIdAndTableName(String userId, String tableName);

    /**
     * Find logs for a specific record
     */
    List<AuditLog> findByTableNameAndRecordId(String tableName, String recordId);

    /**
     * Find recent logs (ordered by date desc)
     */
    @Query("SELECT a FROM AuditLog a ORDER BY a.operationDate DESC")
    List<AuditLog> findRecentLogs();

    /**
     * Find logs by username
     */
    List<AuditLog> findByUsername(String username);

    /**
     * Count operations by type for a user
     */
    @Query("SELECT a.operation, COUNT(a) FROM AuditLog a WHERE a.userId = :userId GROUP BY a.operation")
    List<Object[]> countOperationsByUser(@Param("userId") String userId);

    /**
     * Count operations by table
     */
    @Query("SELECT a.tableName, COUNT(a) FROM AuditLog a GROUP BY a.tableName ORDER BY COUNT(a) DESC")
    List<Object[]> countByTable();
}

