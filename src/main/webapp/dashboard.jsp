<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.oceanview.model.Reservation" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Ocean View Resort</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <%@ include file="includes/header.jsp" %>
    
    <div class="container">
        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success" id="successMessage" style="margin-bottom: 20px;">
                <%= request.getAttribute("success") %>
            </div>
            <script>
                // Auto-hide success message after 5 seconds
                setTimeout(function() {
                    const successMsg = document.getElementById('successMessage');
                    if (successMsg) {
                        successMsg.style.transition = 'opacity 0.5s ease';
                        successMsg.style.opacity = '0';
                        setTimeout(function() {
                            successMsg.style.display = 'none';
                        }, 500);
                    }
                }, 5000);
            </script>
        <% } %>
        
        <div class="card">
            <h2>All Reservations</h2>
            
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-error">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>
            
            <%
                List<Reservation> reservations = (List<Reservation>) request.getAttribute("reservations");
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            %>
            
            <% if (reservations == null || reservations.isEmpty()) { %>
                <p style="text-align: center; color: #5A7863; padding: 20px;">No reservations found. <a href="reservation?action=new">Create a new reservation</a></p>
            <% } else { %>
                <!-- Search Box -->
                <div class="search-box" style="margin-bottom: 20px;">
                    <input type="text" id="searchInput" 
                           placeholder="Search by reservation number, guest name, contact, or room type..." 
                           style="width: 100%; padding: 12px; border: 2px solid #90AB8B; border-radius: 5px; font-size: 1em;">
                </div>
                
                <div class="table-container">
                    <table id="reservationsTable">
                        <thead>
                            <tr>
                                <th>Reservation #</th>
                                <th>Guest Name</th>
                                <th>Contact</th>
                                <th>Room Type</th>
                                <th>Room #</th>
                                <th>Check-in</th>
                                <th>Check-out</th>
                                <th>Nights</th>
                                <th>Total Amount</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="reservationsTableBody">
                            <% for (Reservation res : reservations) { %>
                                <tr class="reservation-row"
                                    data-reservation-number="<%= res.getReservationNumber().toLowerCase() %>"
                                    data-guest-name="<%= res.getGuestName().toLowerCase() %>"
                                    data-contact="<%= res.getContactNumber().toLowerCase() %>"
                                    data-room-type="<%= (res.getRoomTypeName() != null ? res.getRoomTypeName() : "N/A").toLowerCase() %>">
                                    <td class="searchable-cell"><strong><%= res.getReservationNumber() %></strong></td>
                                    <td class="searchable-cell"><%= res.getGuestName() %></td>
                                    <td class="searchable-cell"><%= res.getContactNumber() %></td>
                                    <td class="searchable-cell"><%= res.getRoomTypeName() != null ? res.getRoomTypeName() : "N/A" %></td>
                                    <td><%= res.getRoomNumber() != null ? res.getRoomNumber() : "N/A" %></td>
                                    <td><%= dateFormat.format(res.getCheckInDate()) %></td>
                                    <td><%= dateFormat.format(res.getCheckOutDate()) %></td>
                                    <td><%= res.getNumberOfNights() %></td>
                                    <td>Rs. <%= String.format("%.2f", res.getTotalAmount()) %></td>
                                    <td>
                                        <%
                                            String status = res.getStatus();
                                            if (status == null || status.isEmpty() || status.equals("null")) {
                                                java.util.Date today = new java.util.Date();
                                                if (res.getCheckOutDate().before(new java.sql.Date(today.getTime()))) {
                                                    status = "COMPLETE";
                                                } else {
                                                    status = "CONFIRMED";
                                                }
                                            }
                                            String statusClass = status.equals("COMPLETE") ? "complete" : "confirmed";
                                        %>
                                        <span class="status-badge <%= statusClass %>"><%= status %></span>
                                    </td>
                                    <td>
                                        <div class="btn-group">
                                            <a href="reservation?action=view&reservationNumber=<%= res.getReservationNumber() %>" class="btn btn-secondary" style="padding: 5px 10px; font-size: 0.85em;">View</a>
                                            <a href="reservation?action=edit&id=<%= res.getReservationId() %>&reservationNumber=<%= res.getReservationNumber() %>" class="btn btn-primary" style="padding: 5px 10px; font-size: 0.85em;">Edit</a>
                                            <a href="reservation?action=delete&id=<%= res.getReservationId() %>" class="btn btn-danger" style="padding: 5px 10px; font-size: 0.85em;" onclick="return confirm('Are you sure you want to delete this reservation?')">Delete</a>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>
    </div>
    
    <%@ include file="includes/footer.jsp" %>
    
    <script src="js/dashboard-search.js"></script>
</body>
</html>
