package com.oceanview.servlet;

import com.oceanview.dao.UserDAO;
import com.oceanview.model.User;
import com.oceanview.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;


@WebServlet("/admin/users")
public class UserManagementServlet extends HttpServlet {
    
    private UserDAO userDAO;
    
    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        User currentUser = (User) session.getAttribute("user");
        if (!"admin".equals(currentUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("new".equals(action) || "edit".equals(action)) {
            // Show form for new or edit
            if ("edit".equals(action)) {
                String userIdStr = request.getParameter("id");
                if (userIdStr != null) {
                    try {
                        int userId = Integer.parseInt(userIdStr);
                        User user = userDAO.getUserById(userId);
                        if (user != null) {
                            request.setAttribute("user", user);
                        }
                    } catch (NumberFormatException e) {
                        // Invalid user ID
                    }
                }
            }
            request.getRequestDispatcher("/admin/user-form.jsp").forward(request, response);
        } else {
            // List all users
            request.setAttribute("users", userDAO.getAllUsers());
            request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        User currentUser = (User) session.getAttribute("user");
        if (!"admin".equals(currentUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("unlock".equals(action)) {
            // Unlock user account
            String userIdStr = request.getParameter("id");
            if (userIdStr != null) {
                try {
                    int userId = Integer.parseInt(userIdStr);
                    // Prevent unlocking own account (though it shouldn't be locked)
                    if (userId == currentUser.getUserId()) {
                        response.sendRedirect("users?error=cannot_unlock_self");
                        return;
                    }
                    // Check if trying to unlock admin account
                    User targetUser = userDAO.getUserById(userId);
                    if (targetUser != null && "admin".equals(targetUser.getRole())) {
                        response.sendRedirect("users?error=cannot_unlock_admin");
                        return;
                    }
                    boolean unlocked = userDAO.unlockUser(userId);
                    if (unlocked) {
                        response.sendRedirect("users?success=unlocked");
                    } else {
                        response.sendRedirect("users?error=unlock_failed");
                    }
                } catch (NumberFormatException e) {
                    response.sendRedirect("users?error=invalid_id");
                }
            }
        } else if ("delete".equals(action)) {
            String userIdStr = request.getParameter("id");
            if (userIdStr != null) {
                try {
                    int userId = Integer.parseInt(userIdStr);
                    // Prevent deleting own account
                    if (userId == currentUser.getUserId()) {
                        response.sendRedirect("users?error=cannot_delete_self");
                        return;
                    }
                    boolean deleted = userDAO.deleteUser(userId);
                    if (deleted) {
                        response.sendRedirect("users?success=deleted");
                    } else {
                        response.sendRedirect("users?error=delete_failed");
                    }
                } catch (NumberFormatException e) {
                    response.sendRedirect("users?error=invalid_id");
                }
            }
        } else {
            // Save or update user
            String userIdStr = request.getParameter("userId");
            String username = request.getParameter("username");
            String fullName = request.getParameter("fullName");
            String role = request.getParameter("role");
            String password = request.getParameter("password");
            String confirmPassword = request.getParameter("confirmPassword");
            
            // Validation
            if (username == null || username.trim().isEmpty() ||
                fullName == null || fullName.trim().isEmpty() ||
                role == null || role.trim().isEmpty()) {
                response.sendRedirect("users?error=validation_failed");
                return;
            }
            
            // Check if username already exists (for new users or if username changed)
            User existingUser = userDAO.getUserByUsername(username);
            if (existingUser != null) {
                if (userIdStr == null || existingUser.getUserId() != Integer.parseInt(userIdStr)) {
                    response.sendRedirect("users?error=username_exists");
                    return;
                }
            }
            
            if (userIdStr == null || userIdStr.trim().isEmpty()) {
                // Create new user
                if (password == null || password.trim().isEmpty() || 
                    !password.equals(confirmPassword)) {
                    response.sendRedirect("users?error=password_mismatch");
                    return;
                }
                
                User newUser = new User();
                newUser.setUsername(username.trim());
                newUser.setFullName(fullName.trim());
                newUser.setRole(role.trim());
                newUser.setPassword(PasswordUtil.hashPassword(password));
                
                boolean added = userDAO.addUser(newUser);
                if (added) {
                    response.sendRedirect("users?success=added");
                } else {
                    response.sendRedirect("users?error=add_failed");
                }
            } else {
                // Update existing user
                try {
                    int userId = Integer.parseInt(userIdStr);
                    User user = userDAO.getUserById(userId);
                    if (user == null) {
                        response.sendRedirect("users?error=user_not_found");
                        return;
                    }
                    
                    user.setUsername(username.trim());
                    user.setFullName(fullName.trim());
                    user.setRole(role.trim());
                    
                    boolean updated = userDAO.updateUser(user);
                    
                    // Update password if provided
                    if (password != null && !password.trim().isEmpty()) {
                        if (!password.equals(confirmPassword)) {
                            response.sendRedirect("users?error=password_mismatch");
                            return;
                        }
                        userDAO.updateUserPassword(userId, PasswordUtil.hashPassword(password));
                    }
                    
                    if (updated) {
                        response.sendRedirect("users?success=updated");
                    } else {
                        response.sendRedirect("users?error=update_failed");
                    }
                } catch (NumberFormatException e) {
                    response.sendRedirect("users?error=invalid_id");
                }
            }
        }
    }
}
