<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.Reservation" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bill - Ocean View Resort</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <%@ include file="includes/header.jsp" %>
    
    <div class="container">
        <%
            Reservation reservation = (Reservation) request.getAttribute("reservation");
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat dateTimeFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            java.util.Date now = new java.util.Date();
        %>
        
        <% if (reservation != null) { %>
            <div class="bill-container">
                <!-- 80mm thermal-printer receipt layout -->
                <div class="receipt">
                    <div class="r-center">
                        <div class="r-title">OCEAN VIEW RESORT</div>
                        <div class="r-subtitle">Galle, Sri Lanka</div>
                        <div class="r-subtitle">Tel: +94 1122445588</div>
                    </div>

                    <div class="r-divider"></div>
                    <div class="r-center r-section-title">BILL RECEIPT</div>

                    <div class="r-row">
                        <div class="label">Reservation:</div>
                        <div class="value"><strong><%= reservation.getReservationNumber() %></strong></div>
                    </div>
                    <div class="r-row">
                        <div class="label">Date:</div>
                        <div class="value"><%= dateTimeFormat.format(now) %></div>
                    </div>

                    <div class="r-divider"></div>
                    <div class="r-section-title">Guest Information</div>
                    <div class="r-row"><div class="label">Name:</div><div class="value"><%= reservation.getGuestName() %></div></div>
                    <div class="r-row"><div class="label">Contact:</div><div class="value"><%= reservation.getContactNumber() %></div></div>
                    <div class="r-row"><div class="label">Address:</div><div class="value"><%= reservation.getGuestAddress() %></div></div>

                    <div class="r-divider"></div>
                    <div class="r-section-title">Reservation Details</div>
                    <div class="r-row"><div class="label">Room Type:</div><div class="value"><%= reservation.getRoomTypeName() != null ? reservation.getRoomTypeName() : "N/A" %></div></div>
                    <div class="r-row"><div class="label">Room Number:</div><div class="value"><%= reservation.getRoomNumber() != null ? reservation.getRoomNumber() : "N/A" %></div></div>
                    <div class="r-row"><div class="label">Check-in:</div><div class="value"><%= dateFormat.format(reservation.getCheckInDate()) %></div></div>
                    <div class="r-row"><div class="label">Check-out:</div><div class="value"><%= dateFormat.format(reservation.getCheckOutDate()) %></div></div>
                    <div class="r-row"><div class="label">Nights:</div><div class="value"><%= reservation.getNumberOfNights() %></div></div>

                    <div class="r-divider"></div>
                    <div class="r-row">
                        <div class="label">Subtotal:</div>
                        <div class="value">Rs. <%= String.format("%.2f", reservation.getTotalAmount()) %></div>
                    </div>
                    <div class="r-row r-total">
                        <div class="label">TOTAL AMOUNT:</div>
                        <div class="value">Rs. <%= String.format("%.2f", reservation.getTotalAmount()) %></div>
                    </div>

                    <div class="r-divider"></div>
                    <div class="r-center r-footnote">
                        <div>Thank you for choosing</div>
                        <div>Ocean View Resort!</div>
                        <div style="margin-top: 6px;">Have a pleasant stay!</div>
                    </div>
                </div>
                
                <div class="btn-group" style="margin-top: 30px; justify-content: center;">
                    <button onclick="printBill()" class="btn btn-primary">Print Bill</button>
                    <a href="dashboard" class="btn btn-secondary">Back to Dashboard</a>
                </div>
                
                <script>
                    function printBill() {
                        // Mark bill as printed via AJAX call
                        var reservationNumber = '<%= reservation.getReservationNumber() %>';
                        var xhr = new XMLHttpRequest();
                        xhr.open('POST', 'billing', true);
                        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
                        xhr.onreadystatechange = function() {
                            if (xhr.readyState === 4 && xhr.status === 200) {
                                // Bill marked as printed, now open print dialog
                                window.print();
                            }
                        };
                        xhr.send('action=print&reservationNumber=' + encodeURIComponent(reservationNumber));
                    }
                </script>
            </div>
        <% } else { %>
            <div class="card">
                <div class="alert alert-error">
                    Reservation not found.
                </div>
                <a href="billing" class="btn btn-primary">Search Again</a>
            </div>
        <% } %>
    </div>
    
    <%@ include file="includes/footer.jsp" %>
</body>
</html>
