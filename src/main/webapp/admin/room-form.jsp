<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.oceanview.model.Room" %>
<%@ page import="com.oceanview.model.RoomType" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= request.getParameter("action") != null && request.getParameter("action").equals("edit") ? "Edit" : "Add" %> Room - Ocean View Resort</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <%@ include file="../includes/header.jsp" %>
    
    <div class="container">
        <div class="card">
            <h2><%= request.getParameter("action") != null && request.getParameter("action").equals("edit") ? "Edit" : "Add New" %> Room</h2>
            
            <%
                Room room = (Room) request.getAttribute("room");
                List<RoomType> roomTypes = (List<RoomType>) request.getAttribute("roomTypes");
                boolean isEdit = room != null;
            %>
            
            <form method="post" action="rooms" class="form">
                <% if (isEdit) { %>
                    <input type="hidden" name="roomId" value="<%= room.getRoomId() %>">
                <% } %>
                
                <div class="form-group">
                    <label for="roomNumber">Room Number *</label>
                    <input type="text" id="roomNumber" name="roomNumber" 
                           value="<%= isEdit ? room.getRoomNumber() : "" %>" 
                           required placeholder="e.g., STD-101">
                </div>
                
                <div class="form-group">
                    <label for="roomTypeId">Room Type *</label>
                    <select id="roomTypeId" name="roomTypeId" required>
                        <option value="">Select Room Type</option>
                        <% if (roomTypes != null) {
                            for (RoomType rt : roomTypes) {
                                boolean selected = isEdit && room.getRoomTypeId() == rt.getRoomTypeId();
                        %>
                            <option value="<%= rt.getRoomTypeId() %>" <%= selected ? "selected" : "" %>>
                                <%= rt.getTypeName() %> - Rs. <%= String.format("%.2f", rt.getRatePerNight()) %>/night
                            </option>
                        <% }
                            }
                        %>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="status">Status *</label>
                    <select id="status" name="status" required>
                        <option value="">Select Status</option>
                        <option value="AVAILABLE" <%= isEdit && "AVAILABLE".equals(room.getStatus()) ? "selected" : "" %>>Available</option>
                        <option value="OCCUPIED" <%= isEdit && "OCCUPIED".equals(room.getStatus()) ? "selected" : "" %>>Occupied</option>
                        <option value="MAINTENANCE" <%= isEdit && "MAINTENANCE".equals(room.getStatus()) ? "selected" : "" %>>Maintenance</option>
                    </select>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Save</button>
                    <a href="rooms" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
    
    <%@ include file="../includes/footer.jsp" %>
</body>
</html>
