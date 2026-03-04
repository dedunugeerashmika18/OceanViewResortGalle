package com.oceanview.servlet;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.model.Reservation;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;


@WebServlet("/billing")
public class BillingServlet extends HttpServlet {
    
    private ReservationDAO reservationDAO;
    
    @Override
    public void init() throws ServletException {
        reservationDAO = new ReservationDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Handle print bill action
        String reservationNumber = request.getParameter("reservationNumber");
        String action = request.getParameter("action");
        
        if ("print".equals(action) && reservationNumber != null && !reservationNumber.trim().isEmpty()) {
            // Mark bill as printed
            reservationDAO.markBillAsPrinted(reservationNumber);
            response.sendRedirect("billing?reservationNumber=" + reservationNumber);
        } else {
            doGet(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }
        
        String reservationNumber = request.getParameter("reservationNumber");
        
        if (reservationNumber != null && !reservationNumber.trim().isEmpty()) {
            Reservation reservation = reservationDAO.getReservationByNumber(reservationNumber);
            if (reservation != null) {
                request.setAttribute("reservation", reservation);
                request.getRequestDispatcher("/bill.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Reservation not found");
                request.getRequestDispatcher("/search-billing.jsp").forward(request, response);
            }
        } else {
            request.getRequestDispatcher("/search-billing.jsp").forward(request, response);
        }
    }
}
