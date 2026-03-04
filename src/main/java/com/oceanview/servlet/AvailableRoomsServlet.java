package com.oceanview.servlet;

import com.oceanview.dao.RoomDAO;
import com.oceanview.model.Room;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.util.List;


@WebServlet("/available-rooms")
public class AvailableRoomsServlet extends HttpServlet {
    
    private RoomDAO roomDAO;
    
    @Override
    public void init() throws ServletException {
        roomDAO = new RoomDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
            return;
        }
        
        String roomTypeIdStr = request.getParameter("roomTypeId");
        String checkInDateStr = request.getParameter("checkInDate");
        String checkOutDateStr = request.getParameter("checkOutDate");
        String excludeReservationIdStr = request.getParameter("excludeReservationId");
        
        if (roomTypeIdStr == null || checkInDateStr == null || checkOutDateStr == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing required parameters");
            return;
        }
        
        try {
            int roomTypeId = Integer.parseInt(roomTypeIdStr);
            Date checkInDate = Date.valueOf(checkInDateStr);
            Date checkOutDate = Date.valueOf(checkOutDateStr);
            
            Integer excludeReservationId = null;
            if (excludeReservationIdStr != null && !excludeReservationIdStr.trim().isEmpty()) {
                excludeReservationId = Integer.parseInt(excludeReservationIdStr);
            }
            
            List<Room> availableRooms = roomDAO.getAvailableRooms(roomTypeId, checkInDate, checkOutDate, excludeReservationId);
            
            // Return JSON response
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();
            
            out.print("[");
            for (int i = 0; i < availableRooms.size(); i++) {
                Room room = availableRooms.get(i);
                out.print("{");
                out.print("\"roomId\":" + room.getRoomId() + ",");
                out.print("\"roomNumber\":\"" + escapeJson(room.getRoomNumber()) + "\"");
                out.print("}");
                if (i < availableRooms.size() - 1) {
                    out.print(",");
                }
            }
            out.print("]");
            out.flush();
            
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error fetching available rooms: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}
