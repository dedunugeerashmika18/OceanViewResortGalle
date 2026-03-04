<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.RoomType" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Room Type - Ocean View Resort</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <%@ include file="../includes/header.jsp" %>
    
    <div class="container">
        <div class="card">
            <h2><%= request.getParameter("action") != null && request.getParameter("action").equals("edit") ? "Edit" : "Add New" %> Room Type</h2>
            
            <%
                RoomType roomType = (RoomType) request.getAttribute("roomType");
                boolean isEdit = roomType != null;
            %>
            
            <form method="post" action="room-types" class="form">
                <% if (isEdit) { %>
                    <input type="hidden" name="roomTypeId" value="<%= roomType.getRoomTypeId() %>">
                <% } %>
                    
                <div class="form-group">
                    <label for="typeName">Type Name *</label>
                    <input type="text" id="typeName" name="typeName" 
                           value="<%= isEdit ? roomType.getTypeName() : "" %>" 
                           required placeholder="e.g., Standard Room">
                </div>
                
                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea id="description" name="description" rows="3" placeholder="Brief description of the room type"><%= isEdit && roomType.getDescription() != null ? roomType.getDescription() : "" %></textarea>
                </div>
                
                <div class="form-group">
                    <label for="ratePerNight">Rate per Night (Rs.) *</label>
                    <input type="number" id="ratePerNight" name="ratePerNight" 
                           value="<%= isEdit ? String.format("%.2f", roomType.getRatePerNight()) : "" %>" 
                           step="0.01" min="0" required placeholder="5000.00">
                    <small style="color: #5A7863;">Enter the rate per night in Sri Lankan Rupees</small>
                </div>
                
                <div class="form-group">
                    <label for="maxOccupancy">Max Occupancy *</label>
                    <input type="number" id="maxOccupancy" name="maxOccupancy" 
                           value="<%= isEdit ? roomType.getMaxOccupancy() : "" %>" 
                           min="1" required placeholder="2">
                    <small style="color: #5A7863;">Maximum number of guests allowed</small>
                </div>
                
                <div class="form-group">
                    <label for="amenities">Amenities</label>
                    <textarea id="amenities" name="amenities" rows="2" placeholder="WiFi, TV, AC, Ocean View"><%= isEdit && roomType.getAmenities() != null ? roomType.getAmenities() : "" %></textarea>
                    <small style="color: #5A7863;">Separate amenities with commas (e.g., WiFi, TV, AC, Ocean View)</small>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary"><%= isEdit ? "Update" : "Add" %> Room Type</button>
                    <a href="room-types" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
    
    <%@ include file="../includes/footer.jsp" %>
</body>
</html>
