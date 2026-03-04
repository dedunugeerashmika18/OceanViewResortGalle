<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.oceanview.model.RoomType" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Room Type Management - Ocean View Resort</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .rate-display {
            font-weight: bold;
            color: #5A7863;
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
                <h2>Room Type Management</h2>
                <a href="room-types?action=new" class="btn btn-primary">Add New Room Type</a>
            </div>
            
            <%
                String success = request.getParameter("success");
                String error = request.getParameter("error");
                if (success != null) {
            %>
                <div class="alert alert-success">
                    <% if ("added".equals(success)) { %>
                        Room type added successfully!
                    <% } else if ("updated".equals(success)) { %>
                        Room type updated successfully!
                    <% } %>
                </div>
            <% } %>
            
            <% if (error != null) { %>
                <div class="alert alert-error">
                    <% if ("validation_failed".equals(error)) { %>
                        Validation failed. Please check all fields.
                    <% } else if ("add_failed".equals(error)) { %>
                        Failed to add room type. Please try again.
                    <% } else if ("update_failed".equals(error)) { %>
                        Failed to update room type. Please try again.
                    <% } else if ("invalid_input".equals(error)) { %>
                        Invalid input. Please check your values.
                    <% } else { %>
                        An error occurred. Please try again.
                    <% } %>
                </div>
            <% } %>
            
            <%
                List<RoomType> roomTypes = (List<RoomType>) request.getAttribute("roomTypes");
                if (roomTypes != null && !roomTypes.isEmpty()) {
            %>
                <!-- Search Section -->
                <div class="search-section">
                    <strong style="color: #3B4953; margin-bottom: 10px; display: block;">Search Room Types:</strong>
                    <input type="text" 
                           id="roomTypeSearchInput" 
                           placeholder="Search by ID, type name, description, rate, occupancy, or amenities..." 
                           class="search-input">
                </div>
                
                <div class="no-results" id="noResults">
                    <p>No room types found matching your search.</p>
                </div>
                
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Type Name</th>
                            <th>Description</th>
                            <th>Rate per Night</th>
                            <th>Max Occupancy</th>
                            <th>Amenities</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="roomTypesTableBody">
                        <% for (RoomType roomType : roomTypes) { 
                            String description = roomType.getDescription() != null ? roomType.getDescription() : "N/A";
                            String amenities = roomType.getAmenities() != null ? roomType.getAmenities() : "N/A";
                        %>
                            <tr class="room-type-row"
                                data-room-type-id="<%= roomType.getRoomTypeId() %>"
                                data-type-name="<%= roomType.getTypeName().toLowerCase() %>"
                                data-description="<%= description.toLowerCase() %>"
                                data-rate="<%= String.format("%.2f", roomType.getRatePerNight()) %>"
                                data-max-occupancy="<%= roomType.getMaxOccupancy() %>"
                                data-amenities="<%= amenities.toLowerCase() %>">
                                <td><%= roomType.getRoomTypeId() %></td>
                                <td class="searchable-cell"><strong><%= roomType.getTypeName() %></strong></td>
                                <td class="searchable-cell"><%= description %></td>
                                <td class="searchable-cell rate-display">Rs. <%= String.format("%.2f", roomType.getRatePerNight()) %></td>
                                <td class="searchable-cell"><%= roomType.getMaxOccupancy() %></td>
                                <td class="searchable-cell"><%= amenities %></td>
                                <td>
                                    <a href="room-types?action=edit&id=<%= roomType.getRoomTypeId() %>" class="btn btn-secondary btn-small">Edit</a>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <p>No room types found.</p>
            <% } %>
        </div>
    </div>
    
    <%@ include file="../includes/footer.jsp" %>
    
    <script>
        (function() {
            const searchInput = document.getElementById('roomTypeSearchInput');
            const tableBody = document.getElementById('roomTypesTableBody');
            const noResults = document.getElementById('noResults');
            
            if (!searchInput || !tableBody) {
                return;
            }
            
            const rows = tableBody.querySelectorAll('.room-type-row');
            
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
                    const roomTypeId = row.getAttribute('data-room-type-id') || '';
                    const typeName = row.getAttribute('data-type-name') || '';
                    const description = row.getAttribute('data-description') || '';
                    const rate = row.getAttribute('data-rate') || '';
                    const maxOccupancy = row.getAttribute('data-max-occupancy') || '';
                    const amenities = row.getAttribute('data-amenities') || '';
                    
                    // Check if any field matches
                    const matches = roomTypeId.includes(searchTerm) ||
                                   typeName.includes(searchTerm) ||
                                   description.includes(searchTerm) ||
                                   rate.includes(searchTerm) ||
                                   maxOccupancy.includes(searchTerm) ||
                                   amenities.includes(searchTerm);
                    
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
                                    // Remove HTML tags for searching
                                    const tempDiv = document.createElement('div');
                                    tempDiv.innerHTML = cellText;
                                    const cellTextPlain = tempDiv.textContent || tempDiv.innerText || '';
                                    const cellTextLower = cellTextPlain.toLowerCase();
                                    
                                    if (cellTextLower.includes(searchTerm)) {
                                        // Simple text replacement without regex
                                        const startIndex = cellTextLower.indexOf(searchTerm);
                                        const endIndex = startIndex + searchTerm.length;
                                        const beforeMatch = cellTextPlain.substring(0, startIndex);
                                        const matchText = cellTextPlain.substring(startIndex, endIndex);
                                        const afterMatch = cellTextPlain.substring(endIndex);
                                        
                                        // Preserve HTML structure if it exists (like <strong> tags)
                                        const hasStrong = cellText.includes('<strong>');
                                        if (hasStrong && cellIndex === 0) {
                                            // For type name with <strong> tag
                                            const strongMatch = cellText.match(/<strong>(.*?)<\/strong>/);
                                            if (strongMatch) {
                                                const strongContent = strongMatch[1];
                                                const strongContentLower = strongContent.toLowerCase();
                                                if (strongContentLower.includes(searchTerm)) {
                                                    const strongStart = strongContentLower.indexOf(searchTerm);
                                                    const strongEnd = strongStart + searchTerm.length;
                                                    const beforeStrong = strongContent.substring(0, strongStart);
                                                    const matchStrong = strongContent.substring(strongStart, strongEnd);
                                                    const afterStrong = strongContent.substring(strongEnd);
                                                    cell.innerHTML = '<strong>' + beforeStrong + 
                                                        '<mark class="search-highlight">' + matchStrong + '</mark>' + 
                                                        afterStrong + '</strong>';
                                                } else {
                                                    cell.innerHTML = originalCells[cellIndex];
                                                }
                                            }
                                        } else {
                                            cell.innerHTML = beforeMatch + 
                                                '<mark class="search-highlight">' + matchText + '</mark>' + 
                                                afterMatch;
                                        }
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
