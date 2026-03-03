<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error - Ocean View Resort</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="container">
        <div class="card">
            <h2>Error Occurred</h2>
            <div class="alert alert-error">
                <p>An error has occurred while processing your request.</p>
                <% if (exception != null) { %>
                    <p><strong>Error Details:</strong> <%= exception.getMessage() %></p>
                <% } %>
            </div>
            <div class="btn-group">
                <a href="dashboard" class="btn btn-primary">Go to Dashboard</a>
                <a href="login" class="btn btn-secondary">Go to Login</a>
            </div>
        </div>
    </div>
</body>
</html