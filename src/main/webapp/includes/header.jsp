<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%
    String fullName = (String) session.getAttribute("fullName");
    if (fullName == null) fullName = "User";
    User user = (User) session.getAttribute("user");
    String userRole = (user != null && user.getRole() != null) ? user.getRole() : "staff";
%>
<div class="header">
    <div class="header-content">
        <div class="resort-name">
            <h1>Ocean View Resort</h1>
            <div class="resort-location">Galle</div>
        </div>
        <div class="user-info">
            <span>Welcome, <strong><%= fullName %></strong> 
            <span style="font-size: 0.85em; color: #EBF4DD; margin-left: 10px;">
                (<%= userRole.toUpperCase() %>)
            </span></span>
            <a href="<%= request.getContextPath() %>/logout" class="btn btn-secondary" style="padding: 8px 15px; font-size: 0.9em;">Logout</a>
        </div>
    </div>
</div>

<div class="nav">
    <div class="nav-content">
        <a href="<%= request.getContextPath() %>/dashboard" class="<%= request.getRequestURI().contains("dashboard") ? "active" : "" %>">Dashboard</a>
        <a href="<%= request.getContextPath() %>/reservation?action=new" class="<%= request.getRequestURI().contains("reservation") && !request.getRequestURI().contains("reservation-details") ? "active" : "" %>">New Reservation</a>
        <a href="<%= request.getContextPath() %>/reservation?action=view" class="<%= request.getRequestURI().contains("reservation-details") ? "active" : "" %>">View Reservation</a>
        <a href="<%= request.getContextPath() %>/rooms" class="<%= request.getRequestURI().contains("rooms") && !request.getRequestURI().contains("admin") ? "active" : "" %>">Rooms</a>
        <a href="<%= request.getContextPath() %>/billing" class="<%= request.getRequestURI().contains("billing") ? "active" : "" %>">Billing</a>
        
        <% if ("admin".equals(userRole) || "manager".equals(userRole)) { %>
            <a href="<%= request.getContextPath() %>/manager/revenue" class="<%= request.getRequestURI().contains("revenue") ? "active" : "" %>">Revenue</a>
            <a href="<%= request.getContextPath() %>/admin/viewres" class="<%= request.getRequestURI().contains("/admin/viewres") ? "active" : "" %>">View Reservations</a>
        <% } %>
        
        <% if ("admin".equals(userRole)) { %>
            <a href="<%= request.getContextPath() %>/admin/users" class="<%= request.getRequestURI().contains("/admin/users") ? "active" : "" %>">Users</a>
            <a href="<%= request.getContextPath() %>/admin/rooms" class="<%= request.getRequestURI().contains("/admin/rooms") ? "active" : "" %>">Manage Rooms</a>
            <a href="<%= request.getContextPath() %>/admin/room-types" class="<%= request.getRequestURI().contains("/admin/room-types") ? "active" : "" %>">Room Rates</a>
            <a href="<%= request.getContextPath() %>/admin/customers" class="<%= request.getRequestURI().contains("/admin/customers") ? "active" : "" %>">Customers</a>
        <% } %>
        
        <% if ("staff".equals(userRole)) { %>
            <a href="<%= request.getContextPath() %>/help" class="<%= request.getRequestURI().contains("help") ? "active" : "" %>">Help</a>
        <% } %>
    </div>
</div>
