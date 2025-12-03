package edu.university.grademanagement;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * Main Spring Boot Application for University Grade Management System
 * System B: Quy trình quản lý điểm trong trường đại học
 */
@SpringBootApplication
@EnableScheduling
@EnableAsync
@ConfigurationPropertiesScan
public class GradeManagementApplication {

    public static void main(String[] args) {
        SpringApplication.run(GradeManagementApplication.class, args);
        System.out.println("""
            =====================================================
            University Grade Management System Started
            System B: Quy trình quản lý điểm trong trường đại học
            Access API Documentation: http://localhost:8080/api/swagger-ui.html
            =====================================================
            """);
    }
}