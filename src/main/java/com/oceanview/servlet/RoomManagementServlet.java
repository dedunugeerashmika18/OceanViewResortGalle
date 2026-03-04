package com.oceanview.servlet;

import com.oceanview.dao.RoomDAO;
import com.oceanview.dao.RoomTypeDAO;
import com.oceanview.model.Room;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;


@WebServlet("/admin/rooms")
public class RoomManagementServlet extends HttpServlet {
    
    private RoomDAO roomDAO;
    private RoomTypeDAO roomTypeDAO;
    
    @Override
    public void init() throws ServletException {
        roomDAO = new RoomDAO();
        roomTypeDAO = new RoomTypeDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        com.oceanview.model.User currentUser = (com.oceanview.model.User) session.getAttribute("user");
        if (!"admin".equals(currentUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("new".equals(action) || "edit".equals(action)) {
            // Show form for new or edit
            request.setAttribute("roomTypes", roomTypeDAO.getAllRoomTypes());
            if ("edit".equals(action)) {
                String roomIdStr = request.getParameter("id");
                if (roomIdStr != null) {
                    try {
                        int roomId = Integer.parseInt(roomIdStr);
                        Room room = roomDAO.getRoomById(roomId);
                        if (room != null) {
                            request.setAttribute("room", room);
                        }
                    } catch (NumberFormatException e) {
                        // Invalid room ID
                    }
                }
            }
            request.getRequestDispatcher("/admin/room-form.jsp").forward(request, response);
        } else {
            // List all rooms
            request.setAttribute("rooms", roomDAO.getAllRooms());
            request.setAttribute("roomTypes", roomTypeDAO.getAllRoomTypes());
            request.getRequestDispatcher("/admin/room-management.jsp").forward(request, response);
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
        
        com.oceanview.model.User currentUser = (com.oceanview.model.User) session.getAttribute("user");
        if (!"admin".equals(currentUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("delete".equals(action)) {
            String roomIdStr = request.getParameter("id");
            if (roomIdStr != null) {
                try {
                    int roomId = Integer.parseInt(roomIdStr);
                    boolean deleted = roomDAO.deleteRoom(roomId);
                    if (deleted) {
                        response.sendRedirect("rooms?success=deleted");
                    } else {
                        response.sendRedirect("rooms?error=delete_failed");
                    }
                } catch (NumberFormatException e) {
                    response.sendRedirect("rooms?error=invalid_id");
                }
            }
        } else {
            // Save or update room
            String roomIdStr = request.getParameter("roomId");
            String roomNumber = request.getParameter("roomNumber");
            String roomTypeIdStr = request.getParameter("roomTypeId");
            String status = request.getParameter("status");
            
            // Validation
            if (roomNumber == null || roomNumber.trim().isEmpty() ||
                roomTypeIdStr == null || roomTypeIdStr.trim().isEmpty() ||
                status == null || status.trim().isEmpty()) {
                response.sendRedirect("rooms?error=validation_failed");
                return;
            }
            
            try {
                int roomTypeId = Integer.parseInt(roomTypeIdStr);
                
                if (roomIdStr == null || roomIdStr.trim().isEmpty()) {
                    // Create new room
                    Room newRoom = new Room();
                    newRoom.setRoomNumber(roomNumber.trim());
                    newRoom.setRoomTypeId(roomTypeId);
                    newRoom.setStatus(status);
                    
                    boolean added = roomDAO.addRoom(newRoom);
                    if (added) {
                        response.sendRedirect("rooms?success=added");
                    } else {
                        response.sendRedirect("rooms?error=add_failed");
                    }
                } else {
                    // Update existing room
                    int roomId = Integer.parseInt(roomIdStr);
                    Room room = roomDAO.getRoomById(roomId);
                    if (room == null) {
                        response.sendRedirect("rooms?error=room_not_found");
                        return;
                    }
                    
                    room.setRoomNumber(roomNumber.trim());
                    room.setRoomTypeId(roomTypeId);
                    room.setStatus(status);
                    
                    boolean updated = roomDAO.updateRoom(room);
                    if (updated) {
                        response.sendRedirect("rooms?success=updated");
                    } else {
                        response.sendRedirect("rooms?error=update_failed");
                    }
                }
            } catch (NumberFormatException e) {
                response.sendRedirect("rooms?error=invalid_id");
            }
        }
    }
}
