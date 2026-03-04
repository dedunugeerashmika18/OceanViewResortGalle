<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= request.getParameter("action") != null && request.getParameter("action").equals("edit") ? "Edit" : "Add" %> User - Ocean View Resort</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <%@ include file="../includes/header.jsp" %>
    
    <div class="container">
        <div class="card">
            <h2><%= request.getParameter("action") != null && request.getParameter("action").equals("edit") ? "Edit" : "Add New" %> User</h2>
            
            <%
                User editUser = (User) request.getAttribute("user");
                boolean isEdit = editUser != null;
            %>
            
            <form method="post" action="users" class="form">
                <% if (isEdit) { %>
                    <input type="hidden" name="userId" value="<%= editUser.getUserId() %>">
                <% } %>
                
                <div class="form-group">
                    <label for="username">Username *</label>
                    <input type="text" id="username" name="username" 
                           value="<%= isEdit ? editUser.getUsername() : "" %>" 
                           required>
                </div>
                
                <div class="form-group">
                    <label for="fullName">Full Name *</label>
                    <input type="text" id="fullName" name="fullName" 
                           value="<%= isEdit ? editUser.getFullName() : "" %>" 
                           required>
                </div>
                
                <div class="form-group">
                    <label for="role">Role *</label>
                    <select id="role" name="role" required>
                        <option value="">Select Role</option>
                        <option value="admin" <%= isEdit && "admin".equals(editUser.getRole()) ? "selected" : "" %>>Admin</option>
                        <option value="manager" <%= isEdit && "manager".equals(editUser.getRole()) ? "selected" : "" %>>Manager</option>
                        <option value="staff" <%= isEdit && "staff".equals(editUser.getRole()) ? "selected" : "" %>>Staff</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="password">Password <%= isEdit ? "(leave blank to keep current)" : "*" %></label>
                    <input type="password" id="password" name="password" 
                           <%= isEdit ? "" : "required" %>>
                </div>
                
                <div class="form-group">
                    <label for="confirmPassword">Confirm Password <%= isEdit ? "(leave blank to keep current)" : "*" %></label>
                    <input type="password" id="confirmPassword" name="confirmPassword" 
                           <%= isEdit ? "" : "required" %>>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Save</button>
                    <a href="users" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
    
    <%@ include file="../includes/footer.jsp" %>
    
    <script>
        // Validate password match
        document.querySelector('form').addEventListener('submit', function(e) {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            if (password && password !== confirmPassword) {
                e.preventDefault();
                alert('Passwords do not match!');
                return false;
            }
        });
    </script>
</body>
</html>
