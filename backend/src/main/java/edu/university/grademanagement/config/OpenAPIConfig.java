package edu.university.grademanagement.config;

import java.util.List;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;

@Configuration
public class OpenAPIConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                // Thiết lập thông tin chung
                .info(new Info()
                        .title("Grade Management API")
                        .version("1.0.0")
                        .description("API Documentation for Grade Management System"))
                // Cấu hình Security Scheme (Bearer Token)
                .components(new Components()
                        .addSecuritySchemes("bearerAuth", new SecurityScheme()
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")))
                // Áp dụng cấu hình bảo mật cho toàn bộ API
                .security(List.of(new SecurityRequirement().addList("bearerAuth")));
    }
}