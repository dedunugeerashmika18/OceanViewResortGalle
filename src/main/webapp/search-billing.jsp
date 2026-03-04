<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Billing - Ocean View Resort</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <%@ include file="includes/header.jsp" %>
    
    <div class="container">
        <div class="card">
            <h2>Calculate and Print Bill</h2>
            
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-error">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>
            
            <div class="search-box">
                <form action="billing" method="get">
                    <input type="text" name="reservationNumber" placeholder="Enter Reservation Number" required>
                    <button type="submit" class="btn btn-primary">Generate Bill</button>
                </form>
            </div>
            
            <div style="margin-top: 20px; padding: 15px; background-color: #90AB8B; border-radius: 5px; color: #3B4953;">
                <strong>Note:</strong> Enter the reservation number to calculate and print the bill for the guest.
            </div>
        </div>
    </div>
    
    <%@ include file="includes/footer.jsp" %>
</body>
</html>
