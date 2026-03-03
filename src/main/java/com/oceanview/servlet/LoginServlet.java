package com.oceanview.servlet;

import com.oceanview.dao.UserDAO;
import com.oceanview.factory.DAOFactory;
import com.oceanview.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;


@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    
    private UserDAO userDAO;
    
    @Override
    public void init() throws ServletException {
        // Using Factory Pattern to create DAO instance
        userDAO = DAOFactory.getUserDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Redirect to login page if not logged in
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            response.sendRedirect("dashboard");
        } else {
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "Username and password are required");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        
        // Check if account is locked before authentication
        User existingUser = userDAO.getUserByUsername(username);
        if (existingUser != null && existingUser.isLocked() && !"admin".equals(existingUser.getRole())) {
            request.setAttribute("error", "Account is locked due to multiple failed login attempts. Please contact administrator.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        
        User user = userDAO.authenticate(username, password);
        
        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setAttribute("username", user.getUsername());
            session.setAttribute("fullName", user.getFullName());
            response.sendRedirect("dashboard");
        } else {
            // Check if account was just locked
            User checkUser = userDAO.getUserByUsername(username);
            if (checkUser != null && checkUser.isLocked() && !"admin".equals(checkUser.getRole())) {
                request.setAttribute("error", "Account has been locked due to multiple failed login attempts. Please contact administrator.");
            } else {
                request.setAttribute("error", "Invalid username or password");
            }
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}
