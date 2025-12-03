package edu.university.grademanagement.config;

import edu.university.grademanagement.interceptor.VpdContextInterceptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Web MVC Configuration
 * Registers interceptors for request handling
 */
@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Autowired
    private VpdContextInterceptor vpdContextInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        // Register VPD context interceptor
        registry.addInterceptor(vpdContextInterceptor)
                .addPathPatterns("/**") // Apply to all paths
                .excludePathPatterns(
                    "/auth/**",           // Exclude authentication endpoints
                    "/api-docs/**",       // Exclude API documentation
                    "/swagger-ui/**",     // Exclude Swagger UI
                    "/actuator/**",       // Exclude actuator endpoints
                    "/error"              // Exclude error endpoint
                );
    }
}
