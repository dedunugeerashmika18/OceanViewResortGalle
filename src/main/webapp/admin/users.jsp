<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.oceanview.model.User" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - Ocean View Resort</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .action-buttons {
            display: flex;
            gap: 10px;
        }
        .btn-small {
            padding: 5px 10px;
            font-size: 0.85em;
        }
        .role-badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.85em;
            font-weight: 500;
        }
        .role-admin {
            background-color: #d32f2f;
            color: white;
        }
        .role-manager {
            background-color: #1976d2;
            color: white;
        }
        .role-staff {
            background-color: #388e3c;
            color: white;
        }
        .status-badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.85em;
            font-weight: 500;
        }
        .status-locked {
            background-color: #d32f2f;
            color: white;
        }
        .status-active {
            background-color: #388e3c;
            color: white;
        }
    </style>
</head>
<body>
    <%@ include file="../includes/header.jsp" %>
    
    <div class="container">
        <div class="card">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h2>User Management</h2>
                <a href="users?action=new" class="btn btn-primary">Add New User</a>
            </div>
            
            <%
                String success = request.getParameter("success");
                String error = request.getParameter("error");
                if (success != null) {
            %>
                <div class="alert alert-success">
                    <% if ("added".equals(success)) { %>
                        User added successfully!
                    <% } else if ("updated".equals(success)) { %>
                        User updated successfully!
                    <% } else if ("deleted".equals(success)) { %>
                        User deleted successfully!
                    <% } else if ("unlocked".equals(success)) { %>
                        User account unlocked successfully!
                    <% } %>
                </div>
            <% } %>
            
            <% if (error != null) { %>
                <div class="alert alert-error">
                    <% if ("delete_failed".equals(error)) { %>
                        Failed to delete user. User may have reservations.
                    <% } else if ("cannot_delete_self".equals(error)) { %>
                        You cannot delete your own account.
                    <% } else if ("username_exists".equals(error)) { %>
                        Username already exists.
                    <% } else if ("validation_failed".equals(error)) { %>
                        Validation failed. Please check all fields.
                    <% } else if ("unlock_failed".equals(error)) { %>
                        Failed to unlock user account. Please try again.
                    <% } else if ("cannot_unlock_self".equals(error)) { %>
                        You cannot unlock your own account.
                    <% } else if ("cannot_unlock_admin".equals(error)) { %>
                        Admin accounts cannot be locked or unlocked.
                    <% } else { %>
                        An error occurred. Please try again.
                    <% } %>
                </div>
            <% } %>
            
            <%
                List<User> users = (List<User>) request.getAttribute("users");
                if (users != null && !users.isEmpty()) {
            %>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Username</th>
                            <th>Full Name</th>
                            <th>Role</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (User userItem : users) { 
                            String roleClass = "role-" + (userItem.getRole() != null ? userItem.getRole().toLowerCase() : "staff");
                            // Admin accounts are never locked, always show as ACTIVE
                            boolean isAdmin = "admin".equals(userItem.getRole());
                            boolean isLocked = !isAdmin && userItem.isLocked();
                            String statusClass = isLocked ? "status-locked" : "status-active";
                            String statusText = isLocked ? "LOCKED" : "ACTIVE";
                        %>
                            <tr>
                                <td><%= userItem.getUserId() %></td>
                                <td><%= userItem.getUsername() %></td>
                                <td><%= userItem.getFullName() %></td>
                                <td>
                                    <span class="role-badge <%= roleClass %>">
                                        <%= userItem.getRole() != null ? userItem.getRole().toUpperCase() : "STAFF" %>
                                    </span>
                                </td>
                                <td>
                                    <span class="status-badge <%= statusClass %>">
                                        <%= statusText %>
                                    </span>
                                    <% if (isLocked && !isAdmin) { %>
                                        <br><small style="color: #d32f2f;">Attempts: <%= userItem.getLoginAttempts() %></small>
                                    <% } %>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <a href="users?action=edit&id=<%= userItem.getUserId() %>" class="btn btn-secondary btn-small">Edit</a>
                                        <% if (isLocked && !isAdmin) { %>
                                            <form method="post" action="users" style="display: inline;">
                                                <input type="hidden" name="action" value="unlock">
                                                <input type="hidden" name="id" value="<%= userItem.getUserId() %>">
                                                <button type="submit" class="btn btn-primary btn-small">Unlock</button>
                                            </form>
                                        <% } %>
                                        <form method="post" action="users" style="display: inline;" onsubmit="return confirm('Are you sure you want to delete this user?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="<%= userItem.getUserId() %>">
                                            <button type="submit" class="btn btn-danger btn-small">Delete</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <p>No users found.</p>
            <% } %>
        </div>
    </div>
    
    <%@ include file="../includes/footer.jsp" %>
</body>
</html>
