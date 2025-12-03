package edu.university.grademanagement.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

/**
 * Utility class to grant SELECT permissions on RELATIVES and STUDENT_RELATIVES tables to GMS_APP
 */
public class GrantRelativesPermissions {

    public static void main(String[] args) {
        String url = "jdbc:oracle:thin:@localhost:1521/orclpdb";
        String adminUser = "GMS_ADMIN";
        String adminPassword = "Admin@2024#Secure";

        try (Connection conn = DriverManager.getConnection(url, adminUser, adminPassword);
             Statement stmt = conn.createStatement()) {

            System.out.println("Connected to database as GMS_ADMIN");

            // Grant SELECT on RELATIVES
            stmt.execute("GRANT SELECT ON GMS_ADMIN.RELATIVES TO GMS_APP");
            System.out.println("✓ Granted SELECT on GMS_ADMIN.RELATIVES to GMS_APP");

            // Grant SELECT on STUDENT_RELATIVES
            stmt.execute("GRANT SELECT ON GMS_ADMIN.STUDENT_RELATIVES TO GMS_APP");
            System.out.println("✓ Granted SELECT on GMS_ADMIN.STUDENT_RELATIVES to GMS_APP");

            // Verify grants
            var rs = stmt.executeQuery(
                "SELECT grantee, table_name, privilege " +
                "FROM all_tab_privs " +
                "WHERE grantee = 'GMS_APP' " +
                "AND table_name IN ('RELATIVES', 'STUDENT_RELATIVES') " +
                "ORDER BY table_name"
            );

            System.out.println("\nVerifying grants:");
            while (rs.next()) {
                System.out.printf("  %s has %s on %s%n",
                    rs.getString("GRANTEE"),
                    rs.getString("PRIVILEGE"),
                    rs.getString("TABLE_NAME")
                );
            }

            conn.commit();
            System.out.println("\n✓ Permissions granted successfully!");

        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
