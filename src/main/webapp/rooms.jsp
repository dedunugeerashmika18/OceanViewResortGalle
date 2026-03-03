<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.oceanview.model.Room" %>
<%@ page import="com.oceanview.model.Reservation" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Room Details - Ocean View Resort</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .rooms-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        .room-card {
            background: #EBF4DD;
            border: 2px solid #90AB8B;
            border-radius: 8px;
            padding: 20px;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .room-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .room-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid #90AB8B;
        }
        .room-number {
            font-size: 1.5em;
            font-weight: bold;
            color: #3B4953;
        }
        .room-type {
            color: #5A7863;
            font-weight: 500;
            margin-top: 5px;
        }
        .room-status {
            padding: 5px 12px;
            border-radius: 5px;
            font-weight: 500;
            font-size: 0.9em;
        }
        .status-available {
            background-color: #90AB8B;
            color: #EBF4DD;
        }
        .status-occupied {
            background-color: #5A7863;
            color: #EBF4DD;
        }
        .status-maintenance {
            background-color: #d32f2f;
            color: #EBF4DD;
        }
        .room-details {
            margin-top: 15px;
        }
        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #90AB8B;
        }
        .detail-row:last-child {
            border-bottom: none;
        }
        .detail-label {
            font-weight: 500;
            color: #3B4953;
        }
        .detail-value {
            color: #5A7863;
        }
        .reservation-info {
            background-color: #90AB8B;
            color: #EBF4DD;
            padding: 10px;
            border-radius: 5px;
            margin-top: 10px;
            font-size: 0.9em;
        }
        .reservation-info strong {
            display: block;
            margin-bottom: 5px;
        }
        .filter-section {
            margin-bottom: 20px;
            padding: 15px;
            background-color: #EBF4DD;
            border-radius: 5px;
        }
        .filter-buttons {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        .filter-btn {
            padding: 8px 16px;
            border: 2px solid #90AB8B;
            background-color: white;
            color: #3B4953;
            border-radius: 5px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .filter-btn:hover {
            background-color: #90AB8B;
            color: #EBF4DD;
        }
        .filter-btn.active {
            background-color: #5A7863;
            color: #EBF4DD;
            border-color: #5A7863;
        }
        .no-rooms {
            text-align: center;
            padding: 40px;
            color: #5A7863;
            font-size: 1.1em;
        }
        .search-highlight {
            background-color: #ffeb3b;
            color: #3B4953;
            padding: 2px 4px;
            border-radius: 3px;
            font-weight: bold;
        }
        .room-card.search-match {
            border: 3px solid #ffeb3b;
            box-shadow: 0 4px 12px rgba(255, 235, 59, 0.4);
        }
        .no-results {
            text-align: center;
            padding: 40px;
            color: #5A7863;
            font-size: 1.1em;
            display: none;
        }
    </style>
</head>
<body>
    <%@ include file="includes/header.jsp" %>
    
    <div class="container">
        <div class="card">
            <h2>Room Details & Status</h2>
            
            <%
                List<Room> rooms = (List<Room>) request.getAttribute("rooms");
                Map<Integer, Reservation> roomReservations = (Map<Integer, Reservation>) request.getAttribute("roomReservations");
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            %>
            
            <% if (rooms != null && !rooms.isEmpty()) { %>
                <!-- Search Section -->
                <div class="filter-section" style="margin-bottom: 15px;">
                    <strong style="color: #3B4953; margin-bottom: 10px; display: block;">Search Rooms:</strong>
                    <input type="text" 
                           id="roomSearchInput" 
                           placeholder="Search by room number, type, status, or guest name..." 
                           style="width: 100%; padding: 10px; border: 2px solid #90AB8B; border-radius: 5px; font-size: 1em; box-sizing: border-box;"
                           onkeyup="searchRooms()">
                </div>
                
                <!-- Filter Section -->
                <div class="filter-section">
                    <strong style="color: #3B4953; margin-bottom: 10px; display: block;">Filter by Status:</strong>
                    <div class="filter-buttons">
                        <button class="filter-btn active" onclick="filterRooms('all')">All Rooms</button>
                        <button class="filter-btn" onclick="filterRooms('AVAILABLE')">Available</button>
                        <button class="filter-btn" onclick="filterRooms('OCCUPIED')">Occupied</button>
                        <button class="filter-btn" onclick="filterRooms('MAINTENANCE')">Maintenance</button>
                    </div>
                </div>
                
                <div class="no-results" id="noResults">
                    <p>No rooms found matching your search.</p>
                </div>
                
                <div class="rooms-grid" id="roomsGrid">
                    <% for (Room room : rooms) { 
                        Reservation reservation = roomReservations != null ? roomReservations.get(room.getRoomId()) : null;
                        String status = room.getStatus() != null ? room.getStatus() : "AVAILABLE";
                        String statusClass = "status-" + status.toLowerCase();
                    %>
                        <div class="room-card" 
                             data-status="<%= status %>"
                             data-room-number="<%= room.getRoomNumber() != null ? room.getRoomNumber().toLowerCase() : "" %>"
                             data-room-type="<%= room.getRoomTypeName() != null ? room.getRoomTypeName().toLowerCase() : "" %>"
                             data-room-id="<%= room.getRoomId() %>"
                             data-guest-name="<%= reservation != null ? reservation.getGuestName().toLowerCase() : "" %>">
                            <div class="room-header">
                                <div>
                                    <div class="room-number"><%= room.getRoomNumber() %></div>
                                    <div class="room-type"><%= room.getRoomTypeName() != null ? room.getRoomTypeName() : "N/A" %></div>
                                </div>
                                <span class="room-status <%= statusClass %>"><%= status %></span>
                            </div>
                            
                            <div class="room-details">
                                <div class="detail-row">
                                    <span class="detail-label">Room ID:</span>
                                    <span class="detail-value">#<%= room.getRoomId() %></span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Room Type ID:</span>
                                    <span class="detail-value">#<%= room.getRoomTypeId() %></span>
                                </div>
                                
                                <% if (reservation != null && status.equals("OCCUPIED")) { %>
                                    <div class="reservation-info">
                                        <strong>Current Reservation:</strong>
                                        <div>Guest: <%= reservation.getGuestName() %></div>
                                        <div>Reservation #: <%= reservation.getReservationNumber() %></div>
                                        <div>Check-in: <%= dateFormat.format(reservation.getCheckInDate()) %></div>
                                        <div>Check-out: <%= dateFormat.format(reservation.getCheckOutDate()) %></div>
                                        <div style="margin-top: 8px;">
                                            <a href="reservation?action=view&reservationNumber=<%= reservation.getReservationNumber() %>" 
                                               style="color: #EBF4DD; text-decoration: underline;">View Details</a>
                                        </div>
                                    </div>
                                <% } else if (status.equals("AVAILABLE")) { %>
                                    <div class="reservation-info" style="background-color: #90AB8B; opacity: 0.8;">
                                        <strong>Room is Available</strong>
                                        <div style="margin-top: 5px;">Ready for booking</div>
                                    </div>
                                <% } else if (status.equals("MAINTENANCE")) { %>
                                    <div class="reservation-info" style="background-color: #d32f2f;">
                                        <strong>Under Maintenance</strong>
                                        <div style="margin-top: 5px;">Not available for booking</div>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } else { %>
                <div class="no-rooms">
                    <p>No rooms found in the system.</p>
                </div>
            <% } %>
        </div>
    </div>
    
    <%@ include file="includes/footer.jsp" %>
    
    <script>
        function filterRooms(status) {
            const cards = document.querySelectorAll('.room-card');
            const buttons = document.querySelectorAll('.filter-btn');
            
            // Update active button
            buttons.forEach(btn => {
                btn.classList.remove('active');
                if (btn.textContent.trim() === (status === 'all' ? 'All Rooms' : 
                    status === 'AVAILABLE' ? 'Available' : 
                    status === 'OCCUPIED' ? 'Occupied' : 'Maintenance')) {
                    btn.classList.add('active');
                }
            });
            
            // Filter cards
            cards.forEach(card => {
                if (status === 'all') {
                    card.style.display = 'block';
                } else {
                    const cardStatus = card.getAttribute('data-status');
                    if (cardStatus === status) {
                        card.style.display = 'block';
                    } else {
                        card.style.display = 'none';
                    }
                }
            });
            
            // Re-apply search if there's a search term
            const searchInput = document.getElementById('roomSearchInput');
            if (searchInput && searchInput.value.trim() !== '') {
                searchRooms();
            }
        }
        
        function searchRooms() {
            const searchInput = document.getElementById('roomSearchInput');
            const cards = document.querySelectorAll('.room-card');
            const noResults = document.getElementById('noResults');
            const roomsGrid = document.getElementById('roomsGrid');
            
            if (!searchInput) return;
            
            const searchTerm = searchInput.value.trim().toLowerCase();
            let visibleCount = 0;
            
            cards.forEach(card => {
                const roomNumber = card.getAttribute('data-room-number') || '';
                const roomType = card.getAttribute('data-room-type') || '';
                const status = card.getAttribute('data-status') || '';
                const guestName = card.getAttribute('data-guest-name') || '';
                const roomId = card.getAttribute('data-room-id') || '';
                
                // Check if any field matches
                const matches = roomNumber.includes(searchTerm) ||
                               roomType.includes(searchTerm) ||
                               status.toLowerCase().includes(searchTerm) ||
                               guestName.includes(searchTerm) ||
                               roomId.includes(searchTerm);
                
                if (searchTerm === '' || matches) {
                    // Show card
                    card.style.display = 'block';
                    card.classList.remove('no-match');
                    
                    if (searchTerm !== '') {
                        // Highlight matching card
                        card.classList.add('search-match');
                        
                        // Store original content if not already stored
                        const roomNumberEl = card.querySelector('.room-number');
                        const roomTypeEl = card.querySelector('.room-type');
                        
                        if (!card.hasAttribute('data-original-number') && roomNumberEl) {
                            card.setAttribute('data-original-number', roomNumberEl.textContent);
                        }
                        if (!card.hasAttribute('data-original-type') && roomTypeEl) {
                            card.setAttribute('data-original-type', roomTypeEl.textContent);
                        }
                        
                        // Highlight matching text in room number
                        if (roomNumberEl && roomNumber.includes(searchTerm)) {
                            const originalText = card.getAttribute('data-original-number') || roomNumberEl.textContent;
                            const index = originalText.toLowerCase().indexOf(searchTerm);
                            if (index !== -1) {
                                const before = originalText.substring(0, index);
                                const match = originalText.substring(index, index + searchTerm.length);
                                const after = originalText.substring(index + searchTerm.length);
                                roomNumberEl.innerHTML = before + 
                                    '<mark class="search-highlight">' + match + '</mark>' + 
                                    after;
                            }
                        }
                        
                        // Highlight matching text in room type
                        if (roomTypeEl && roomType.includes(searchTerm)) {
                            const originalText = card.getAttribute('data-original-type') || roomTypeEl.textContent;
                            const index = originalText.toLowerCase().indexOf(searchTerm);
                            if (index !== -1) {
                                const before = originalText.substring(0, index);
                                const match = originalText.substring(index, index + searchTerm.length);
                                const after = originalText.substring(index + searchTerm.length);
                                roomTypeEl.innerHTML = before + 
                                    '<mark class="search-highlight">' + match + '</mark>' + 
                                    after;
                            }
                        }
                    } else {
                        // Remove highlight when search is cleared
                        card.classList.remove('search-match');
                        
                        // Restore original text - get from original HTML
                        const roomNumberEl = card.querySelector('.room-number');
                        const roomTypeEl = card.querySelector('.room-type');
                        
                        // Store original content on first load
                        if (!card.hasAttribute('data-original-number')) {
                            if (roomNumberEl) {
                                card.setAttribute('data-original-number', roomNumberEl.textContent);
                            }
                            if (roomTypeEl) {
                                card.setAttribute('data-original-type', roomTypeEl.textContent);
                            }
                        }
                        
                        // Restore original content
                        if (roomNumberEl && card.hasAttribute('data-original-number')) {
                            roomNumberEl.textContent = card.getAttribute('data-original-number');
                        }
                        if (roomTypeEl && card.hasAttribute('data-original-type')) {
                            roomTypeEl.textContent = card.getAttribute('data-original-type');
                        }
                    }
                    
                    visibleCount++;
                } else {
                    // Hide non-matching card
                    card.style.display = 'none';
                    card.classList.remove('search-match');
                    card.classList.add('no-match');
                }
            });
            
            // Show/hide no results message
            if (searchTerm !== '' && visibleCount === 0) {
                noResults.style.display = 'block';
                roomsGrid.style.display = 'none';
            } else {
                noResults.style.display = 'none';
                roomsGrid.style.display = 'grid';
            }
        }
        
        // Clear search when filter changes
        document.addEventListener('DOMContentLoaded', function() {
            const searchInput = document.getElementById('roomSearchInput');
            if (searchInput) {
                searchInput.addEventListener('input', searchRooms);
                searchInput.addEventListener('paste', function() {
                    setTimeout(searchRooms, 10);
                });
            }
        });
    </script>
</body>
</html>
