package edu.university.grademanagement.interceptor;

import edu.university.grademanagement.security.UserPrincipal;
import edu.university.grademanagement.service.VpdContextService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * VPD Context Interceptor
 * Automatically sets VPD context before each request
 * Runs after JWT authentication but before controller execution
 */
@Component
public class VpdContextInterceptor implements HandlerInterceptor {

    @Autowired
    private VpdContextService vpdContextService;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {

        // Get authenticated user from Spring Security context
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication != null && authentication.isAuthenticated()
                && authentication.getPrincipal() instanceof UserPrincipal) {

            UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();

            // Set VPD context with user info
            try {
                vpdContextService.setContext(
                    userPrincipal.getUserId(),
                    userPrincipal.getRole()
                );

                // Debug log
                String requestUri = request.getRequestURI();
                System.out.println(String.format(
                    "[VPD] Context set for %s %s: user=%s, role=%s",
                    request.getMethod(),
                    requestUri,
                    userPrincipal.getUserId(),
                    userPrincipal.getRole()
                ));

            } catch (Exception e) {
                System.err.println("[VPD] Failed to set context: " + e.getMessage());
                // Don't block request, let it continue
                // The VPD policies will apply default restrictions
            }
        } else {
            // No authenticated user - VPD will apply default (most restrictive) policy
            System.out.println("[VPD] No authenticated user, skipping context setup");
        }

        return true; // Continue with request
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response,
                                Object handler, Exception ex) throws Exception {
        // Optional: Clear context after request completes
        // Note: This might not be necessary as each request gets a new connection from pool
        // and context is session-specific in Oracle

        // vpdContextService.clearContext();
    }
}
