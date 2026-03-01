package com.oceanview.filter;

import com.oceanview.model.User;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;


@WebFilter(urlPatterns = {"/admin/*", "/manager/*"})
public class RoleFilter implements Filter {
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {

    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        

        if (session == null || session.getAttribute("user") == null) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return;
        }
        
        User user = null;
        try {
            user = (User) session.getAttribute("user");
            if (user == null) {
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
                return;
            }
        } catch (ClassCastException e) {

            session.invalidate();
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return;
        }
        
        String userRole = user.getRole();
        if (userRole == null) {
            userRole = "staff";
        }
        
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        

        String path = requestURI;
        if (contextPath != null && !contextPath.isEmpty() && requestURI.startsWith(contextPath)) {
            path = requestURI.substring(contextPath.length());
        }
        

        if (path.equals("/manager/dashboard") || path.equals("/manager/dashboard/")) {
            httpResponse.sendRedirect(contextPath + "/dashboard");
            return;
        }
        

        if (path.startsWith("/manager/admin/")) {
            String adminPath = path.replace("/manager/admin/", "/admin/");
            httpResponse.sendRedirect(contextPath + adminPath);
            return;
        }
        

        if (path.contains("/admin/") && !path.equals("/admin/viewres") && !path.startsWith("/admin/viewres?")) {
            if (!"admin".equals(userRole)) {
                httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Admin privileges required");
                return;
            }
        }
        

        if (path.equals("/admin/viewres") || path.startsWith("/admin/viewres?")) {
            if (!"admin".equals(userRole) && !"manager".equals(userRole)) {
                httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Manager or Admin privileges required");
                return;
            }
        }
        

        if (path.contains("/manager/")) {
            if (!"manager".equals(userRole) && !"admin".equals(userRole)) {
                httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Manager or Admin privileges required");
                return;
            }
        }
        
        chain.doFilter(request, response);
    }
    
    @Override
    public void destroy() {

    }
}
