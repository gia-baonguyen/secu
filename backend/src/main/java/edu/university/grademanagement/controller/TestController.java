package edu.university.grademanagement.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/test")
public class TestController {

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private DataSource dataSource;

    @GetMapping("/hash/{password}")
    public String generateHash(@PathVariable String password) {
        String hash = passwordEncoder.encode(password);
        return "Password: " + password + "\nHash: " + hash + "\nLength: " + hash.length();
    }

    @GetMapping("/verify")
    public String verifyPassword(@RequestParam String password, @RequestParam String hash) {
        boolean matches = passwordEncoder.matches(password, hash);
        return "Password: " + password + "\nHash: " + hash + "\nMatches: " + matches;
    }

    @GetMapping("/db-connection")
    public Map<String, Object> testDatabaseConnection() {
        Map<String, Object> result = new HashMap<>();
        
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement()) {
            
            result.put("status", "SUCCESS");
            result.put("message", "Database connection successful!");
            
            // Test query
            ResultSet rs = stmt.executeQuery("SELECT 'Database connected!' as message FROM DUAL");
            if (rs.next()) {
                result.put("query_test", rs.getString("message"));
            }
            
            // Check tables count
            rs = stmt.executeQuery("SELECT COUNT(*) as table_count FROM all_tables WHERE owner = 'GMS_ADMIN'");
            if (rs.next()) {
                result.put("tables_count", rs.getInt("table_count"));
            }
            
            // Check students count
            rs = stmt.executeQuery("SELECT COUNT(*) as student_count FROM gms_admin.STUDENTS");
            if (rs.next()) {
                result.put("students_count", rs.getInt("student_count"));
            }
            
            // Check grades count
            rs = stmt.executeQuery("SELECT COUNT(*) as grade_count FROM gms_admin.GRADES");
            if (rs.next()) {
                result.put("grades_count", rs.getInt("grade_count"));
            }
            
            // Get database info
            rs = stmt.executeQuery("SELECT SYS_CONTEXT('USERENV', 'DB_NAME') as db_name, SYS_CONTEXT('USERENV', 'SESSION_USER') as current_user FROM DUAL");
            if (rs.next()) {
                result.put("database_name", rs.getString("db_name"));
                result.put("current_user", rs.getString("current_user"));
            }
            
        } catch (Exception e) {
            result.put("status", "ERROR");
            result.put("message", "Database connection failed!");
            result.put("error", e.getMessage());
            result.put("error_type", e.getClass().getName());
        }
        
        return result;
    }
}
