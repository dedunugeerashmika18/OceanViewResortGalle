<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.oceanview.model.Reservation" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Details - Ocean View Resort</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .customer-card {
            background: #EBF4DD;
            border: 2px solid #90AB8B;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
        }
        .customer-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid #90AB8B;
        }
        .customer-name {
            font-size: 1.3em;
            font-weight: bold;
            color: #3B4953;
        }
        .customer-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
        }
        .detail-item {
            display: flex;
            flex-direction: column;
        }
        .detail-label {
            font-weight: 500;
            color: #5A7863;
            font-size: 0.9em;
            margin-bottom: 5px;
        }
        .detail-value {
            color: #3B4953;
        }
        .status-badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.85em;
            font-weight: 500;
        }
        .status-confirmed {
            background-color: #1976d2;
            color: white;
        }
        .status-complete {
            background-color: #388e3c;
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
        .customer-card.search-match {
            border: 3px solid #ffeb3b;
            box-shadow: 0 4px 12px rgba(255, 235, 59, 0.4);
        }
        .customer-card.no-match {
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
            <h2>Customer Details</h2>
            
            <%
                List<Reservation> customers = (List<Reservation>) request.getAttribute("customers");
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                
                if (customers != null && !customers.isEmpty()) {
            %>
                <!-- Search Section -->
                <div class="search-section">
                    <strong style="color: #3B4953; margin-bottom: 10px; display: block;">Search Customers:</strong>
                    <input type="text" 
                           id="customerSearchInput" 
                           placeholder="Search by name, reservation number, contact, room number, or room type..." 
                           class="search-input">
                </div>
                
                <p style="margin-bottom: 20px; color: #5A7863;">
                    Total Customers: <strong><%= customers.size() %></strong>
                </p>
                
                <div class="no-results" id="noResults">
                    <p>No customers found matching your search.</p>
                </div>
                
                <% for (Reservation customer : customers) { 
                    String statusClass = "status-" + (customer.getStatus() != null ? customer.getStatus().toLowerCase() : "confirmed");
                %>
                    <div class="customer-card"
                         data-customer-name="<%= customer.getGuestName() != null ? customer.getGuestName().toLowerCase() : "" %>"
                         data-reservation-number="<%= customer.getReservationNumber() != null ? customer.getReservationNumber().toLowerCase() : "" %>"
                         data-contact="<%= customer.getContactNumber() != null ? customer.getContactNumber().toLowerCase() : "" %>"
                         data-room-number="<%= customer.getRoomNumber() != null ? customer.getRoomNumber().toLowerCase() : "" %>"
                         data-room-type="<%= customer.getRoomTypeName() != null ? customer.getRoomTypeName().toLowerCase() : "" %>"
                         data-address="<%= customer.getGuestAddress() != null ? customer.getGuestAddress().toLowerCase() : "" %>">
                        <div class="customer-header">
                            <div class="customer-name"><%= customer.getGuestName() %></div>
                            <span class="status-badge <%= statusClass %>">
                                <%= customer.getStatus() != null ? customer.getStatus() : "CONFIRMED" %>
                            </span>
                        </div>
                        
                        <div class="customer-details">
                            <div class="detail-item">
                                <span class="detail-label">Reservation Number</span>
                                <span class="detail-value"><%= customer.getReservationNumber() %></span>
                            </div>
                            
                            <div class="detail-item">
                                <span class="detail-label">Contact Number</span>
                                <span class="detail-value"><%= customer.getContactNumber() %></span>
                            </div>
                            
                            <div class="detail-item">
                                <span class="detail-label">Address</span>
                                <span class="detail-value"><%= customer.getGuestAddress() %></span>
                            </div>
                            
                            <div class="detail-item">
                                <span class="detail-label">Room Type</span>
                                <span class="detail-value"><%= customer.getRoomTypeName() != null ? customer.getRoomTypeName() : "N/A" %></span>
                            </div>
                            
                            <div class="detail-item">
                                <span class="detail-label">Room Number</span>
                                <span class="detail-value"><%= customer.getRoomNumber() != null ? customer.getRoomNumber() : "N/A" %></span>
                            </div>
                            
                            <div class="detail-item">
                                <span class="detail-label">Check-in Date</span>
                                <span class="detail-value"><%= dateFormat.format(customer.getCheckInDate()) %></span>
                            </div>
                            
                            <div class="detail-item">
                                <span class="detail-label">Check-out Date</span>
                                <span class="detail-value"><%= dateFormat.format(customer.getCheckOutDate()) %></span>
                            </div>
                            
                            <div class="detail-item">
                                <span class="detail-label">Number of Nights</span>
                                <span class="detail-value"><%= customer.getNumberOfNights() %></span>
                            </div>
                            
                            <div class="detail-item">
                                <span class="detail-label">Total Amount</span>
                                <span class="detail-value">Rs. <%= String.format("%.2f", customer.getTotalAmount()) %></span>
                            </div>
                            
                            <div class="detail-item">
                                <span class="detail-label">Created By</span>
                                <span class="detail-value"><%= customer.getCreatedByName() != null ? customer.getCreatedByName() : "N/A" %></span>
                            </div>
                        </div>
                        
                        <div style="margin-top: 15px; text-align: right;">
                            <a href="../reservation?action=view&reservationNumber=<%= customer.getReservationNumber() %>" 
                               class="btn btn-secondary btn-small">View Full Details</a>
                        </div>
                    </div>
                <% } %>
            <% } else { %>
                <p style="text-align: center; color: #5A7863; padding: 20px;">No customer records found.</p>
            <% } %>
        </div>
    </div>
    
    <%@ include file="../includes/footer.jsp" %>
    
    <script>
        (function() {
            const searchInput = document.getElementById('customerSearchInput');
            const customerCards = document.querySelectorAll('.customer-card');
            const noResults = document.getElementById('noResults');
            
            if (!searchInput || customerCards.length === 0) {
                return;
            }
            
            // Store original content for highlighting
            const originalContent = new Map();
            customerCards.forEach(function(card) {
                const nameEl = card.querySelector('.customer-name');
                if (nameEl) {
                    originalContent.set(card, {
                        name: nameEl.textContent,
                        details: Array.from(card.querySelectorAll('.detail-value')).map(el => el.textContent)
                    });
                }
            });
            
            function performSearch() {
                const searchTerm = searchInput.value.trim().toLowerCase();
                let visibleCount = 0;
                
                customerCards.forEach(function(card) {
                    const name = card.getAttribute('data-customer-name') || '';
                    const reservationNumber = card.getAttribute('data-reservation-number') || '';
                    const contact = card.getAttribute('data-contact') || '';
                    const roomNumber = card.getAttribute('data-room-number') || '';
                    const roomType = card.getAttribute('data-room-type') || '';
                    const address = card.getAttribute('data-address') || '';
                    
                    // Check if any field matches
                    const matches = name.includes(searchTerm) ||
                                   reservationNumber.includes(searchTerm) ||
                                   contact.includes(searchTerm) ||
                                   roomNumber.includes(searchTerm) ||
                                   roomType.includes(searchTerm) ||
                                   address.includes(searchTerm);
                    
                    if (searchTerm === '' || matches) {
                        // Show card
                        card.style.display = 'block';
                        card.classList.remove('no-match');
                        
                        if (searchTerm !== '') {
                            // Highlight matching card
                            card.classList.add('search-match');
                            
                            // Highlight matching text in customer name
                            const nameEl = card.querySelector('.customer-name');
                            if (nameEl && name.includes(searchTerm)) {
                                const originalName = originalContent.get(card).name;
                                const index = originalName.toLowerCase().indexOf(searchTerm);
                                if (index !== -1) {
                                    const before = originalName.substring(0, index);
                                    const match = originalName.substring(index, index + searchTerm.length);
                                    const after = originalName.substring(index + searchTerm.length);
                                    nameEl.innerHTML = before + 
                                        '<mark class="search-highlight">' + match + '</mark>' + 
                                        after;
                                }
                            }
                        } else {
                            // Remove highlight when search is cleared
                            card.classList.remove('search-match');
                            
                            // Restore original content
                            const nameEl = card.querySelector('.customer-name');
                            if (nameEl && originalContent.has(card)) {
                                nameEl.textContent = originalContent.get(card).name;
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
                } else {
                    noResults.style.display = 'none';
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
