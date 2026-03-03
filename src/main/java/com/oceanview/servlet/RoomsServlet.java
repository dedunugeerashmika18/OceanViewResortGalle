package com.oceanview.servlet;

import com.oceanview.dao.RoomDAO;
import com.oceanview.dao.ReservationDAO;
import com.oceanview.model.Room;
import com.oceanview.model.Reservation;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.HashMap;


@WebServlet("/rooms")
public class RoomsServlet extends HttpServlet {
    
    private RoomDAO roomDAO;
    private ReservationDAO reservationDAO;
    
    @Override
    public void init() throws ServletException {
        roomDAO = new RoomDAO();
        reservationDAO = new ReservationDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }
        
        // Update room availability based on check-out dates
        roomDAO.updateRoomAvailability();
        
        // Get all rooms
        List<Room> rooms = roomDAO.getAllRooms();
        
        // Get current reservations for occupied rooms
        Map<Integer, Reservation> roomReservations = new HashMap<>();
        List<Reservation> activeReservations = reservationDAO.getAllReservations();
        
        for (Reservation reservation : activeReservations) {
            if (reservation.getRoomId() > 0 && 
                reservation.getStatus() != null && 
                reservation.getStatus().equals("CONFIRMED")) {
                roomReservations.put(reservation.getRoomId(), reservation);
            }
        }
        
        request.setAttribute("rooms", rooms);
        request.setAttribute("roomReservations", roomReservations);
        request.getRequestDispatcher("/rooms.jsp").forward(request, response);
    }
}
