package edu.university.grademanagement.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/debug")
@CrossOrigin(origins = {"http://localhost:3000", "http://localhost:3001"})
public class DebugController {

    @Autowired
    private DataSource dataSource;

    @GetMapping("/grant-relatives-permissions")
    public ResponseEntity<Map<String, Object>> grantRelativesPermissions() {
        Map<String, Object> result = new HashMap<>();
        result.put("note", "This endpoint requires manual SQL execution");
        result.put("sql", "GRANT SELECT ON GMS_ADMIN.RELATIVES TO GMS_APP; GRANT SELECT ON GMS_ADMIN.STUDENT_RELATIVES TO GMS_APP;");
        result.put("status", "MANUAL_ACTION_REQUIRED");
        return ResponseEntity.ok(result);
    }

    @GetMapping("/check-relatives-access")
    public ResponseEntity<Map<String, Object>> checkRelativesAccess() {
        Map<String, Object> result = new HashMap<>();

        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement()) {

            // Check if GMS_APP can see RELATIVES table
            var rs = stmt.executeQuery("SELECT COUNT(*) as cnt FROM GMS_ADMIN.RELATIVES");
            if (rs.next()) {
                result.put("relatives_count", rs.getInt("cnt"));
                result.put("relatives_access", "SUCCESS");
            }

            // Check if GMS_APP can see STUDENT_RELATIVES table
            rs = stmt.executeQuery("SELECT COUNT(*) as cnt FROM GMS_ADMIN.STUDENT_RELATIVES");
            if (rs.next()) {
                result.put("student_relatives_count", rs.getInt("cnt"));
                result.put("student_relatives_access", "SUCCESS");
            }

            result.put("status", "SUCCESS");
            return ResponseEntity.ok(result);

        } catch (Exception e) {
            result.put("status", "ERROR");
            result.put("message", e.getMessage());
            result.put("error", e.getClass().getName());
            return ResponseEntity.status(500).body(result);
        }
    }
}
