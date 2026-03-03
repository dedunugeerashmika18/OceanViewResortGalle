package com.oceanview.servlet;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.RoomDAO;
import com.oceanview.factory.DAOFactory;
import com.oceanview.model.Reservation;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLDecoder;
import java.util.List;


@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    
    private ReservationDAO reservationDAO;
    private RoomDAO roomDAO;
    
    @Override
    public void init() throws ServletException {
        // Using Factory Pattern to create DAO instances
        reservationDAO = DAOFactory.getReservationDAO();
        roomDAO = DAOFactory.getRoomDAO();
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
        
        // Check for success message from URL parameter
        String successMessage = request.getParameter("success");
        if (successMessage != null && !successMessage.trim().isEmpty()) {
            request.setAttribute("success", URLDecoder.decode(successMessage, "UTF-8"));
        }
        
        List<Reservation> reservations = reservationDAO.getAllReservations();
        request.setAttribute("reservations", reservations);
        request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
    }
}
