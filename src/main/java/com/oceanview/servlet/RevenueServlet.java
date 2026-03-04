package com.oceanview.servlet;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.text.ParseException;
import java.text.SimpleDateFormat;


@WebServlet("/manager/revenue")
public class RevenueServlet extends HttpServlet {
    
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
        if (!"admin".equals(userRole) && !"manager".equals(userRole)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }
        
        // Get date range parameters
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");
        String yearStr = request.getParameter("year");
        
        Date startDate = null;
        Date endDate = null;
        Integer year = null;
        
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        
        try {
            if (startDateStr != null && !startDateStr.trim().isEmpty()) {
                startDate = new Date(dateFormat.parse(startDateStr).getTime());
            }
            if (endDateStr != null && !endDateStr.trim().isEmpty()) {
                endDate = new Date(dateFormat.parse(endDateStr).getTime());
            }
            if (yearStr != null && !yearStr.trim().isEmpty()) {
                year = Integer.parseInt(yearStr);
            }
        } catch (ParseException | NumberFormatException e) {
            // Invalid date format, use defaults
        }
        
        // Get revenue statistics
        request.setAttribute("revenueStats", reservationDAO.getRevenueStatistics(startDate, endDate));
        request.setAttribute("revenueByRoomType", reservationDAO.getRevenueByRoomType(startDate, endDate));
        request.setAttribute("revenueByMonth", reservationDAO.getRevenueByMonth(year));
        request.setAttribute("startDate", startDateStr);
        request.setAttribute("endDate", endDateStr);
        request.setAttribute("year", yearStr);
        
        request.getRequestDispatcher("/manager/revenue.jsp").forward(request, response);
    }
}
