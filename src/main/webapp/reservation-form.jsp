<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.oceanview.model.RoomType" %>
<%@ page import="com.oceanview.model.Reservation" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= request.getAttribute("reservation") != null ? "Edit" : "New" %> Reservation - Ocean View Resort</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <%@ include file="includes/header.jsp" %>
    
    <div class="container">
        <div class="card">
            <h2><%= request.getAttribute("reservation") != null ? "Edit Reservation" : "Add New Reservation" %></h2>
            
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-error">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>
            
            <%
                Reservation reservation = (Reservation) request.getAttribute("reservation");
                List<RoomType> roomTypes = (List<RoomType>) request.getAttribute("roomTypes");
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                Integer currentRoomId = reservation != null ? reservation.getRoomId() : null;
                String reservationId = reservation != null ? String.valueOf(reservation.getReservationId()) : null;
            %>
            
            <form action="reservation" method="post" id="reservationForm">
                <% if (reservation != null) { %>
                    <input type="hidden" name="reservationId" value="<%= reservation.getReservationId() %>">
                    <input type="hidden" name="reservationNumber" value="<%= reservation.getReservationNumber() %>">
                <% } %>
                
                <input type="hidden" name="action" value="save">
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="guestName">Guest Name *</label>
                        <input type="text" id="guestName" name="guestName" 
                               value="<%= reservation != null ? reservation.getGuestName() : "" %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="contactNumber">Contact Number *</label>
                        <input type="text" id="contactNumber" name="contactNumber" 
                               value="<%= reservation != null ? reservation.getContactNumber() : "" %>" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="guestAddress">Guest Address *</label>
                    <textarea id="guestAddress" name="guestAddress" required><%= reservation != null ? reservation.getGuestAddress() : "" %></textarea>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="roomTypeId">Room Type *</label>
                        <select id="roomTypeId" name="roomTypeId" required onchange="updateRoomRate(); loadAvailableRooms();">
                            <option value="">Select Room Type</option>
                            <% if (roomTypes != null) {
                                for (RoomType rt : roomTypes) { %>
                                    <option value="<%= rt.getRoomTypeId() %>" 
                                            data-rate="<%= rt.getRatePerNight() %>"
                                            <%= reservation != null && reservation.getRoomTypeId() == rt.getRoomTypeId() ? "selected" : "" %>>
                                        <%= rt.getTypeName() %> - Rs. <%= String.format("%.2f", rt.getRatePerNight()) %>/night
                                    </option>
                                <% }
                            } %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="roomId">Room Number *</label>
                        <select id="roomId" name="roomId" required>
                            <option value="">Select Room Type and Dates First</option>
                        </select>
                        <small style="color: #5A7863; font-size: 0.85em; display: block; margin-top: 5px;">
                            Available rooms will appear after selecting room type and dates
                        </small>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="checkInDate">Check-in Date *</label>
                        <input type="date" id="checkInDate" name="checkInDate" 
                               value="<%= reservation != null ? dateFormat.format(reservation.getCheckInDate()) : "" %>" 
                               required onchange="calculateTotal(); loadAvailableRooms();">
                    </div>
                    
                    <div class="form-group">
                        <label for="checkOutDate">Check-out Date *</label>
                        <input type="date" id="checkOutDate" name="checkOutDate" 
                               value="<%= reservation != null ? dateFormat.format(reservation.getCheckOutDate()) : "" %>" 
                               required onchange="calculateTotal(); loadAvailableRooms();">
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Estimated Total Amount</label>
                    <div style="padding: 15px; background-color: #90AB8B; border-radius: 5px; font-size: 1.2em; font-weight: bold; color: #3B4953;" id="totalAmount">
                        Rs. 0.00
                    </div>
                </div>
                
                <div class="btn-group">
                    <button type="submit" class="btn btn-primary">Save Reservation</button>
                    <a href="dashboard" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
    
    <%@ include file="includes/footer.jsp" %>
    
    <script src="js/reservation.js"></script>
    <script>
        // Store current reservation data for room selection
        const currentRoomId = <%= currentRoomId != null ? currentRoomId : "null" %>;
        const reservationId = <%= reservationId != null ? "\"" + reservationId + "\"" : "null" %>;
        
        // Load available rooms when room type or dates change
        function loadAvailableRooms() {
            const roomTypeId = document.getElementById('roomTypeId').value;
            const checkInDate = document.getElementById('checkInDate').value;
            const checkOutDate = document.getElementById('checkOutDate').value;
            const roomSelect = document.getElementById('roomId');
            
            // Clear current options
            roomSelect.innerHTML = '<option value="">Loading...</option>';
            roomSelect.disabled = true;
            
            if (!roomTypeId || !checkInDate || !checkOutDate) {
                roomSelect.innerHTML = '<option value="">Select Room Type and Dates First</option>';
                return;
            }
            
            // Validate dates
            const checkIn = new Date(checkInDate);
            const checkOut = new Date(checkOutDate);
            if (checkOut <= checkIn) {
                roomSelect.innerHTML = '<option value="">Invalid dates</option>';
                return;
            }
            
            // Build URL with parameters
            let url = 'available-rooms?roomTypeId=' + encodeURIComponent(roomTypeId) +
                      '&checkInDate=' + encodeURIComponent(checkInDate) +
                      '&checkOutDate=' + encodeURIComponent(checkOutDate);
            
            if (reservationId) {
                url += '&excludeReservationId=' + encodeURIComponent(reservationId);
            }
            
            // Fetch available rooms
            fetch(url)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Failed to fetch available rooms');
                    }
                    return response.json();
                })
                .then(rooms => {
                    roomSelect.innerHTML = '';
                    
                    if (rooms.length === 0) {
                        roomSelect.innerHTML = '<option value="">No rooms available for selected dates</option>';
                        roomSelect.disabled = true;
                    } else {
                        rooms.forEach(room => {
                            const option = document.createElement('option');
                            option.value = room.roomId;
                            option.textContent = room.roomNumber;
                            if (currentRoomId && room.roomId === currentRoomId) {
                                option.selected = true;
                            }
                            roomSelect.appendChild(option);
                        });
                        roomSelect.disabled = false;
                    }
                })
                .catch(error => {
                    console.error('Error loading available rooms:', error);
                    roomSelect.innerHTML = '<option value="">Error loading rooms</option>';
                    roomSelect.disabled = true;
                });
        }
        
        // Load rooms on page load if editing
        document.addEventListener('DOMContentLoaded', function() {
            if (currentRoomId && reservationId) {
                // Wait a bit for form to be ready, then load rooms
                setTimeout(loadAvailableRooms, 100);
            }
        });
    </script>
</body>
</html>
