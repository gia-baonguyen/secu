package edu.university.grademanagement;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 * Simple database connection test
 */
public class DatabaseConnectionTest {
    
    public static void main(String[] args) {
        String url = "jdbc:oracle:thin:@//localhost:1521/ORCLPDB";
        String username = "GMS_APP";
        String password = "App@2024#Connect";
        
        System.out.println("========================================");
        System.out.println("Database Connection Test");
        System.out.println("========================================");
        System.out.println("URL: " + url);
        System.out.println("Username: " + username);
        System.out.println("========================================\n");
        
        try {
            // Load Oracle JDBC driver
            Class.forName("oracle.jdbc.OracleDriver");
            System.out.println("✓ Oracle JDBC Driver loaded");
            
            // Connect to database
            System.out.println("Connecting to database...");
            Connection conn = DriverManager.getConnection(url, username, password);
            System.out.println("✓ Connected successfully!");
            
            // Test query
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT 'Database connection successful!' as message FROM DUAL");
            
            if (rs.next()) {
                System.out.println("✓ Query test: " + rs.getString("message"));
            }
            
            // Check schema
            rs = stmt.executeQuery("SELECT COUNT(*) as table_count FROM all_tables WHERE owner = 'GMS_ADMIN'");
            if (rs.next()) {
                System.out.println("✓ Found " + rs.getInt("table_count") + " tables in GMS_ADMIN schema");
            }
            
            // Check sample data
            rs = stmt.executeQuery("SELECT COUNT(*) as student_count FROM gms_admin.STUDENTS");
            if (rs.next()) {
                System.out.println("✓ Found " + rs.getInt("student_count") + " students in database");
            }
            
            // Close connections
            rs.close();
            stmt.close();
            conn.close();
            
            System.out.println("\n========================================");
            System.out.println("✓ All tests passed!");
            System.out.println("Database connection is working correctly.");
            System.out.println("========================================");
            
        } catch (Exception e) {
            System.err.println("\n✗ Connection failed!");
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}

