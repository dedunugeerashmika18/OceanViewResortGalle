<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.Reservation" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reservation Details - Ocean View Resort</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <%@ include file="includes/header.jsp" %>
    
    <div class="container">
        <%
            Reservation reservation = (Reservation) request.getAttribute("reservation");
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        %>
        
        <% if (reservation != null) { %>
            <div class="card">
                <h2>Reservation Details</h2>
                
                <table>
                    <tr>
                        <th style="width: 200px;">Reservation Number</th>
                        <td><strong><%= reservation.getReservationNumber() %></strong></td>
                    </tr>
                    <tr>
                        <th>Guest Name</th>
                        <td><%= reservation.getGuestName() %></td>
                    </tr>
                    <tr>
                        <th>Contact Number</th>
                        <td><%= reservation.getContactNumber() %></td>
                    </tr>
                    <tr>
                        <th>Guest Address</th>
                        <td><%= reservation.getGuestAddress() %></td>
                    </tr>
                    <tr>
                        <th>Room Type</th>
                        <td><%= reservation.getRoomTypeName() != null ? reservation.getRoomTypeName() : "N/A" %></td>
                    </tr>
                    <tr>
                        <th>Room Number</th>
                        <td><%= reservation.getRoomNumber() != null ? reservation.getRoomNumber() : "N/A" %></td>
                    </tr>
                    <tr>
                        <th>Check-in Date</th>
                        <td><%= dateFormat.format(reservation.getCheckInDate()) %></td>
                    </tr>
                    <tr>
                        <th>Check-out Date</th>
                        <td><%= dateFormat.format(reservation.getCheckOutDate()) %></td>
                    </tr>
                    <tr>
                        <th>Number of Nights</th>
                        <td><%= reservation.getNumberOfNights() %> night(s)</td>
                    </tr>
                    <tr>
                        <th>Total Amount</th>
                        <td><strong style="font-size: 1.2em; color: #5A7863;">Rs. <%= String.format("%.2f", reservation.getTotalAmount()) %></strong></td>
                    </tr>
                    <tr>
                        <th>Status</th>
                        <td>
                            <%
                                String status = reservation.getStatus();
                                if (status == null || status.isEmpty() || status.equals("null")) {
                                    java.util.Date today = new java.util.Date();
                                    if (reservation.getCheckOutDate().before(new java.sql.Date(today.getTime()))) {
                                        status = "COMPLETE";
                                    } else {
                                        status = "CONFIRMED";
                                    }
                                }
                                String statusColor = status.equals("COMPLETE") ? "#5A7863" : "#90AB8B";
                                String statusTextColor = status.equals("COMPLETE") ? "#EBF4DD" : "#3B4953";
                            %>
                            <span style="padding: 5px 15px; border-radius: 3px; background-color: <%= statusColor %>; color: <%= statusTextColor %>; font-weight: 500;"><%= status %></span>
                        </td>
                    </tr>
                    <% if (reservation.getCreatedByName() != null) { %>
                    <tr>
                        <th>Created By</th>
                        <td><%= reservation.getCreatedByName() %></td>
                    </tr>
                    <% } %>
                </table>
                
                <div class="btn-group" style="margin-top: 20px;">
                    <a href="reservation?action=edit&id=<%= reservation.getReservationId() %>&reservationNumber=<%= reservation.getReservationNumber() %>" class="btn btn-primary">Edit Reservation</a>
                    <a href="billing?reservationNumber=<%= reservation.getReservationNumber() %>" class="btn btn-success">View Bill</a>
                    <a href="dashboard" class="btn btn-secondary">Back to Dashboard</a>
                </div>
            </div>
        <% } else { %>
            <div class="card">
                <div class="alert alert-error">
                    Reservation not found.
                </div>
                <a href="reservation?action=view" class="btn btn-primary">Search Again</a>
            </div>
        <% } %>
    </div>
    
    <%@ include file="includes/footer.jsp" %>
</body>
</html>
