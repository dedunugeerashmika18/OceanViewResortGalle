package com.oceanview.servlet;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.model.Reservation;
import com.oceanview.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;


@WebServlet("/admin/viewres")
public class ViewReservationsServlet extends HttpServlet {
    
    private ReservationDAO reservationDAO;
    
    @Override
    public void init() throws ServletException {
        reservationDAO = new ReservationDAO();
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
        String userRole = currentUser.getRole();
        
        // Admin and Manager can access this page
        if (!"admin".equals(userRole) && !"manager".equals(userRole)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }
        
        // Get filter parameter
        String filterRole = request.getParameter("role");
        
        List<Reservation> reservations = null;
        String filterLabel = "All Reservations";
        
        if (filterRole != null && !filterRole.trim().isEmpty()) {
            if ("admin".equals(filterRole) || "manager".equals(filterRole) || "staff".equals(filterRole)) {
                reservations = reservationDAO.getReservationsByCreatorRole(filterRole);
                filterLabel = "Reservations by " + filterRole.substring(0, 1).toUpperCase() + filterRole.substring(1) + "s";
            } else {
                // Invalid role, show all
                reservations = reservationDAO.getAllReservations();
            }
        } else {
            // No filter, show all
            reservations = reservationDAO.getAllReservations();
        }
        
        request.setAttribute("reservations", reservations);
        request.setAttribute("filterRole", filterRole);
        request.setAttribute("filterLabel", filterLabel);
        
        request.getRequestDispatcher("/admin/viewres.jsp").forward(request, response);
    }
}
