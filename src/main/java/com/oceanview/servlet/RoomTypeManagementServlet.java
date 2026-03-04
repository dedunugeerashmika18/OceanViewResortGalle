package com.oceanview.servlet;

import com.oceanview.dao.RoomTypeDAO;
import com.oceanview.factory.DAOFactory;
import com.oceanview.model.RoomType;
import com.oceanview.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;


@WebServlet("/admin/room-types")
public class RoomTypeManagementServlet extends HttpServlet {
    
    private RoomTypeDAO roomTypeDAO;
    
    @Override
    public void init() throws ServletException {
        roomTypeDAO = DAOFactory.getRoomTypeDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        User currentUser = (User) session.getAttribute("user");
        if (!"admin".equals(currentUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("new".equals(action) || "edit".equals(action)) {
            // Show form for new or edit
            if ("edit".equals(action)) {
                String roomTypeIdStr = request.getParameter("id");
                if (roomTypeIdStr != null) {
                    try {
                        int roomTypeId = Integer.parseInt(roomTypeIdStr);
                        RoomType roomType = roomTypeDAO.getRoomTypeById(roomTypeId);
                        if (roomType != null) {
                            request.setAttribute("roomType", roomType);
                        }
                    } catch (NumberFormatException e) {
                        // Invalid room type ID
                    }
                }
            }
            request.getRequestDispatcher("/admin/room-type-form.jsp").forward(request, response);
        } else {
            // List all room types
            request.setAttribute("roomTypes", roomTypeDAO.getAllRoomTypes());
            request.getRequestDispatcher("/admin/room-types.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        User currentUser = (User) session.getAttribute("user");
        if (!"admin".equals(currentUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }
        
        // Add or update room type
        String roomTypeIdStr = request.getParameter("roomTypeId");
        String typeName = request.getParameter("typeName");
        String description = request.getParameter("description");
        String ratePerNightStr = request.getParameter("ratePerNight");
        String maxOccupancyStr = request.getParameter("maxOccupancy");
        String amenities = request.getParameter("amenities");
        
        // Validation
        if (typeName == null || typeName.trim().isEmpty() ||
            ratePerNightStr == null || ratePerNightStr.trim().isEmpty() ||
            maxOccupancyStr == null || maxOccupancyStr.trim().isEmpty()) {
            response.sendRedirect("room-types?error=validation_failed");
            return;
        }
        
        try {
            double ratePerNight = Double.parseDouble(ratePerNightStr);
            int maxOccupancy = Integer.parseInt(maxOccupancyStr);
            
            if (roomTypeIdStr == null || roomTypeIdStr.trim().isEmpty()) {
                // Create new room type
                RoomType newRoomType = new RoomType();
                newRoomType.setTypeName(typeName.trim());
                newRoomType.setDescription(description != null ? description.trim() : "");
                newRoomType.setRatePerNight(ratePerNight);
                newRoomType.setMaxOccupancy(maxOccupancy);
                newRoomType.setAmenities(amenities != null ? amenities.trim() : "");
                
                boolean added = roomTypeDAO.addRoomType(newRoomType);
                if (added) {
                    response.sendRedirect("room-types?success=added");
                } else {
                    response.sendRedirect("room-types?error=add_failed");
                }
            } else {
                // Update existing room type
                int roomTypeId = Integer.parseInt(roomTypeIdStr);
                RoomType roomType = roomTypeDAO.getRoomTypeById(roomTypeId);
                if (roomType == null) {
                    response.sendRedirect("room-types?error=room_type_not_found");
                    return;
                }
                
                roomType.setTypeName(typeName.trim());
                roomType.setDescription(description != null ? description.trim() : "");
                roomType.setRatePerNight(ratePerNight);
                roomType.setMaxOccupancy(maxOccupancy);
                roomType.setAmenities(amenities != null ? amenities.trim() : "");
                
                boolean updated = roomTypeDAO.updateRoomType(roomType);
                if (updated) {
                    response.sendRedirect("room-types?success=updated");
                } else {
                    response.sendRedirect("room-types?error=update_failed");
                }
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("room-types?error=invalid_input");
        }
    }
}
