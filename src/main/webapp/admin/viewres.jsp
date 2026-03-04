<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.oceanview.model.Reservation" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Reservations - Ocean View Resort</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .filter-tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }
        .filter-tab {
            padding: 10px 20px;
            background-color: #EBF4DD;
            border: 2px solid #90AB8B;
            border-radius: 5px;
            text-decoration: none;
            color: #3B4953;
            font-weight: 500;
            transition: all 0.3s;
        }
        .filter-tab:hover {
            background-color: #90AB8B;
            color: #EBF4DD;
        }
        .filter-tab.active {
            background-color: #5A7863;
            color: #EBF4DD;
            border-color: #5A7863;
        }
        .creator-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 0.85em;
            font-weight: 600;
            text-transform: uppercase;
        }
        .creator-badge.admin {
            background-color: #d32f2f;
            color: white;
        }
        .creator-badge.manager {
            background-color: #1976d2;
            color: white;
        }
        .creator-badge.staff {
            background-color: #388e3c;
            color: white;
        }
        .search-box {
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <%@ include file="../includes/header.jsp" %>
    
    <div class="container">
        <div class="card">
            <h2>View Reservations by Creator</h2>
            
            <%
                String filterRole = (String) request.getAttribute("filterRole");
                String filterLabel = (String) request.getAttribute("filterLabel");
                if (filterLabel == null) filterLabel = "All Reservations";
            %>
            
            <!-- Filter Tabs -->
            <div class="filter-tabs">
                <a href="<%= request.getContextPath() %>/admin/viewres" 
                   class="filter-tab <%= filterRole == null || filterRole.isEmpty() ? "active" : "" %>">
                    All Reservations
                </a>
                <a href="<%= request.getContextPath() %>/admin/viewres?role=admin" 
                   class="filter-tab <%= "admin".equals(filterRole) ? "active" : "" %>">
                    By Admins
                </a>
                <a href="<%= request.getContextPath() %>/admin/viewres?role=manager" 
                   class="filter-tab <%= "manager".equals(filterRole) ? "active" : "" %>">
                    By Managers
                </a>
                <a href="<%= request.getContextPath() %>/admin/viewres?role=staff" 
                   class="filter-tab <%= "staff".equals(filterRole) ? "active" : "" %>">
                    By Staff
                </a>
            </div>
            
            <%
                List<Reservation> reservations = (List<Reservation>) request.getAttribute("reservations");
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            %>
            
            <% if (reservations == null || reservations.isEmpty()) { %>
                <p style="text-align: center; color: #5A7863; padding: 20px;">
                    No reservations found for the selected filter.
                </p>
            <% } else { %>
                <p style="margin-bottom: 15px; color: #3B4953; font-weight: 500;">
                    Showing: <strong><%= filterLabel %></strong> (<%= reservations.size() %> reservation<%= reservations.size() != 1 ? "s" : "" %>)
                </p>
                
                <!-- Search Box -->
                <div class="search-box">
                    <input type="text" id="searchInput" 
                           placeholder="Search by reservation number, guest name, contact, room type, or creator..." 
                           style="width: 100%; padding: 12px; border: 2px solid #90AB8B; border-radius: 5px; font-size: 1em;">
                </div>
                
                <div class="table-container">
                    <table class="data-table">
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
                                <th>Created By</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="reservationsTableBody">
                            <% for (Reservation res : reservations) { 
                                String creatorName = res.getCreatedByName() != null ? res.getCreatedByName() : "Unknown";
                                String creatorRole = res.getCreatedByRole() != null ? res.getCreatedByRole().toLowerCase() : "staff";
                                String creatorRoleClass = creatorRole;
                            %>
                                <tr class="reservation-row"
                                    data-reservation-number="<%= res.getReservationNumber().toLowerCase() %>"
                                    data-guest-name="<%= res.getGuestName().toLowerCase() %>"
                                    data-contact="<%= res.getContactNumber().toLowerCase() %>"
                                    data-room-type="<%= (res.getRoomTypeName() != null ? res.getRoomTypeName() : "N/A").toLowerCase() %>"
                                    data-created-by="<%= creatorName.toLowerCase() %>">
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
                                        <span class="creator-badge <%= creatorRoleClass %>">
                                            <%= creatorName %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="status-badge <%= "COMPLETE".equals(res.getStatus()) ? "complete" : "confirmed" %>">
                                            <%= res.getStatus() != null ? res.getStatus() : "CONFIRMED" %>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="btn-group">
                                            <a href="<%= request.getContextPath() %>/reservation?action=view&reservationNumber=<%= res.getReservationNumber() %>" 
                                               class="btn btn-secondary" style="padding: 5px 10px; font-size: 0.85em;">View</a>
                                            <%-- Admin and Manager can edit/delete --%>
                                            <a href="<%= request.getContextPath() %>/reservation?action=edit&id=<%= res.getReservationId() %>&reservationNumber=<%= res.getReservationNumber() %>" 
                                               class="btn btn-primary" style="padding: 5px 10px; font-size: 0.85em;">Edit</a>
                                            <a href="<%= request.getContextPath() %>/reservation?action=delete&id=<%= res.getReservationId() %>" 
                                               class="btn btn-danger" style="padding: 5px 10px; font-size: 0.85em;" 
                                               onclick="return confirm('Are you sure you want to delete this reservation?')">Delete</a>
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
    
    <%@ include file="../includes/footer.jsp" %>
    
    <script>
        // Client-side search functionality
        document.addEventListener('DOMContentLoaded', function() {
            const searchInput = document.getElementById('searchInput');
            const tableBody = document.getElementById('reservationsTableBody');
            
            if (searchInput && tableBody) {
                searchInput.addEventListener('input', function() {
                    const searchTerm = this.value.toLowerCase().trim();
                    const rows = tableBody.getElementsByTagName('tr');
                    
                    for (let i = 0; i < rows.length; i++) {
                        const row = rows[i];
                        const reservationNumber = row.getAttribute('data-reservation-number') || '';
                        const guestName = row.getAttribute('data-guest-name') || '';
                        const contact = row.getAttribute('data-contact') || '';
                        const roomType = row.getAttribute('data-room-type') || '';
                        const createdBy = row.getAttribute('data-created-by') || '';
                        
                        const searchableText = reservationNumber + ' ' + guestName + ' ' + contact + ' ' + roomType + ' ' + createdBy;
                        
                        if (searchableText.includes(searchTerm)) {
                            row.style.display = '';
                        } else {
                            row.style.display = 'none';
                        }
                    }
                });
            }
        });
    </script>
</body>
</html>
