<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.oceanview.model.Room" %>
<%@ page import="com.oceanview.model.RoomType" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Room Management - Ocean View Resort</title>
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
        .status-badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.85em;
            font-weight: 500;
        }
        .status-available {
            background-color: #388e3c;
            color: white;
        }
        .status-occupied {
            background-color: #1976d2;
            color: white;
        }
        .status-maintenance {
            background-color: #d32f2f;
            color: white;
        }
        .search-section {
            margin-bottom: 20px;
            padding: 15px;
            background-color: #EBF4DD;
            border-radius: 5px;
        }
        .search-input {
            width: 100%;
            padding: 10px;
            border: 2px solid #90AB8B;
            border-radius: 5px;
            font-size: 1em;
            box-sizing: border-box;
        }
        .search-highlight {
            background-color: #ffeb3b;
            color: #3B4953;
            padding: 2px 4px;
            border-radius: 3px;
            font-weight: bold;
        }
        .data-table tbody tr.search-match {
            background-color: #fff9c4;
        }
        .data-table tbody tr.no-match {
            display: none;
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
    <%@ include file="../includes/header.jsp" %>
    
    <div class="container">
        <div class="card">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h2>Room Management</h2>
                <a href="rooms?action=new" class="btn btn-primary">Add New Room</a>
            </div>
            
            <%
                String success = request.getParameter("success");
                String error = request.getParameter("error");
                if (success != null) {
            %>
                <div class="alert alert-success">
                    <% if ("added".equals(success)) { %>
                        Room added successfully!
                    <% } else if ("updated".equals(success)) { %>
                        Room updated successfully!
                    <% } else if ("deleted".equals(success)) { %>
                        Room deleted successfully!
                    <% } %>
                </div>
            <% } %>
            
            <% if (error != null) { %>
                <div class="alert alert-error">
                    <% if ("delete_failed".equals(error)) { %>
                        Failed to delete room. Room may have reservations.
                    <% } else if ("validation_failed".equals(error)) { %>
                        Validation failed. Please check all fields.
                    <% } else { %>
                        An error occurred. Please try again.
                    <% } %>
                </div>
            <% } %>
            
            <%
                List<Room> rooms = (List<Room>) request.getAttribute("rooms");
                List<RoomType> roomTypes = (List<RoomType>) request.getAttribute("roomTypes");
                if (rooms != null && !rooms.isEmpty()) {
            %>
                <!-- Search Section -->
                <div class="search-section">
                    <strong style="color: #3B4953; margin-bottom: 10px; display: block;">Search Rooms:</strong>
                    <input type="text" 
                           id="roomSearchInput" 
                           placeholder="Search by room ID, room number, room type, or status..." 
                           class="search-input">
                </div>
                
                <div class="no-results" id="noResults">
                    <p>No rooms found matching your search.</p>
                </div>
                
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Room ID</th>
                            <th>Room Number</th>
                            <th>Room Type</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="roomsTableBody">
                        <% for (Room room : rooms) { 
                            String statusClass = "status-" + (room.getStatus() != null ? room.getStatus().toLowerCase() : "available");
                            String roomTypeName = room.getRoomTypeName();
                            if (roomTypeName == null && roomTypes != null) {
                                for (RoomType rt : roomTypes) {
                                    if (rt.getRoomTypeId() == room.getRoomTypeId()) {
                                        roomTypeName = rt.getTypeName();
                                        break;
                                    }
                                }
                            }
                            String finalRoomTypeName = roomTypeName != null ? roomTypeName : "N/A";
                        %>
                            <tr class="room-row"
                                data-room-id="<%= room.getRoomId() %>"
                                data-room-number="<%= room.getRoomNumber() != null ? room.getRoomNumber().toLowerCase() : "" %>"
                                data-room-type="<%= finalRoomTypeName.toLowerCase() %>"
                                data-status="<%= room.getStatus() != null ? room.getStatus().toLowerCase() : "available" %>">
                                <td><%= room.getRoomId() %></td>
                                <td class="searchable-cell"><%= room.getRoomNumber() %></td>
                                <td class="searchable-cell"><%= finalRoomTypeName %></td>
                                <td>
                                    <span class="status-badge <%= statusClass %>">
                                        <%= room.getStatus() != null ? room.getStatus() : "AVAILABLE" %>
                                    </span>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <a href="rooms?action=edit&id=<%= room.getRoomId() %>" class="btn btn-secondary btn-small">Edit</a>
                                        <form method="post" action="rooms" style="display: inline;" onsubmit="return confirm('Are you sure you want to delete this room?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="<%= room.getRoomId() %>">
                                            <button type="submit" class="btn btn-danger btn-small">Delete</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <p>No rooms found.</p>
            <% } %>
        </div>
    </div>
    
    <%@ include file="../includes/footer.jsp" %>
    
    <script>
        (function() {
            const searchInput = document.getElementById('roomSearchInput');
            const tableBody = document.getElementById('roomsTableBody');
            const noResults = document.getElementById('noResults');
            
            if (!searchInput || !tableBody) {
                return;
            }
            
            const rows = tableBody.querySelectorAll('.room-row');
            
            // Store original content for restoration
            const originalContent = new Map();
            rows.forEach(function(row) {
                const cells = row.querySelectorAll('.searchable-cell');
                const cellContent = [];
                cells.forEach(function(cell) {
                    cellContent.push(cell.innerHTML);
                });
                originalContent.set(row, cellContent);
            });
            
            function performSearch() {
                const searchTerm = searchInput.value.trim().toLowerCase();
                let visibleCount = 0;
                
                rows.forEach(function(row) {
                    const roomId = row.getAttribute('data-room-id') || '';
                    const roomNumber = row.getAttribute('data-room-number') || '';
                    const roomType = row.getAttribute('data-room-type') || '';
                    const status = row.getAttribute('data-status') || '';
                    
                    // Check if any field matches
                    const matches = roomId.includes(searchTerm) ||
                                   roomNumber.includes(searchTerm) ||
                                   roomType.includes(searchTerm) ||
                                   status.includes(searchTerm);
                    
                    if (searchTerm === '' || matches) {
                        // Show row
                        row.style.display = '';
                        row.classList.remove('no-match');
                        
                        if (searchTerm !== '') {
                            // Highlight matching row
                            row.classList.add('search-match');
                            
                            // Highlight matching text in cells
                            const cells = row.querySelectorAll('.searchable-cell');
                            const originalCells = originalContent.get(row);
                            
                            cells.forEach(function(cell, cellIndex) {
                                if (originalCells && originalCells[cellIndex]) {
                                    const cellText = originalCells[cellIndex];
                                    const cellTextLower = cellText.toLowerCase();
                                    
                                    if (cellTextLower.includes(searchTerm)) {
                                        // Simple text replacement without regex
                                        const startIndex = cellTextLower.indexOf(searchTerm);
                                        const endIndex = startIndex + searchTerm.length;
                                        const beforeMatch = cellText.substring(0, startIndex);
                                        const matchText = cellText.substring(startIndex, endIndex);
                                        const afterMatch = cellText.substring(endIndex);
                                        
                                        cell.innerHTML = beforeMatch + 
                                            '<mark class="search-highlight">' + matchText + '</mark>' + 
                                            afterMatch;
                                    } else {
                                        cell.innerHTML = originalCells[cellIndex];
                                    }
                                }
                            });
                        } else {
                            // Remove highlight when search is cleared
                            row.classList.remove('search-match');
                            
                            // Restore original content
                            const cells = row.querySelectorAll('.searchable-cell');
                            const originalCells = originalContent.get(row);
                            
                            if (originalCells) {
                                cells.forEach(function(cell, cellIndex) {
                                    cell.innerHTML = originalCells[cellIndex];
                                });
                            }
                        }
                        
                        visibleCount++;
                    } else {
                        // Hide non-matching row
                        row.style.display = 'none';
                        row.classList.remove('search-match');
                        row.classList.add('no-match');
                        
                        // Restore original content
                        const cells = row.querySelectorAll('.searchable-cell');
                        const originalCells = originalContent.get(row);
                        
                        if (originalCells) {
                            cells.forEach(function(cell, cellIndex) {
                                cell.innerHTML = originalCells[cellIndex];
                            });
                        }
                    }
                });
                
                // Show/hide no results message
                if (searchTerm !== '' && visibleCount === 0) {
                    noResults.style.display = 'block';
                    tableBody.style.display = 'none';
                } else {
                    noResults.style.display = 'none';
                    tableBody.style.display = '';
                }
            }
            
            // Add event listeners
            searchInput.addEventListener('input', performSearch);
            searchInput.addEventListener('paste', function() {
                setTimeout(performSearch, 10);
            });
        })();
    </script>
</body>
</html>
