package com.oceanview.servlet;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.RoomDAO;
import com.oceanview.dao.RoomTypeDAO;
import com.oceanview.factory.DAOFactory;
import com.oceanview.model.Reservation;
import com.oceanview.model.Room;
import com.oceanview.model.RoomType;
import com.oceanview.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.util.List;


@WebServlet("/reservation")
public class ReservationServlet extends HttpServlet {
    
    private ReservationDAO reservationDAO;
    private RoomTypeDAO roomTypeDAO;
    private RoomDAO roomDAO;
    
    @Override
    public void init() throws ServletException {
        // Using Factory Pattern to create DAO instances
        reservationDAO = DAOFactory.getReservationDAO();
        roomTypeDAO = DAOFactory.getRoomTypeDAO();
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
        
        User user = (User) session.getAttribute("user");
        String action = request.getParameter("action");
        
        if (action == null || action.equals("new")) {
            // Show new reservation form
            List<RoomType> roomTypes = roomTypeDAO.getAllRoomTypes();
            request.setAttribute("roomTypes", roomTypes);
            request.getRequestDispatcher("/reservation-form.jsp").forward(request, response);
        } else if (action.equals("view")) {
            // View reservation details
            String reservationNumber = request.getParameter("reservationNumber");
            if (reservationNumber != null && !reservationNumber.trim().isEmpty()) {
                Reservation reservation = reservationDAO.getReservationByNumber(reservationNumber);
                if (reservation != null) {
                    request.setAttribute("reservation", reservation);
                    request.getRequestDispatcher("/reservation-details.jsp").forward(request, response);
                } else {
                    request.setAttribute("error", "Reservation not found");
                    request.getRequestDispatcher("/search-reservation.jsp").forward(request, response);
                }
            } else {
                request.getRequestDispatcher("/search-reservation.jsp").forward(request, response);
            }
        } else if (action.equals("edit")) {
            // Edit reservation - All authenticated users can edit
            String reservationId = request.getParameter("id");
            if (reservationId != null) {
                try {
                    int id = Integer.parseInt(reservationId);
                    Reservation reservation = reservationDAO.getReservationById(id);
                    if (reservation != null) {
                        List<RoomType> roomTypes = roomTypeDAO.getAllRoomTypes();
                        request.setAttribute("reservation", reservation);
                        request.setAttribute("roomTypes", roomTypes);
                        request.getRequestDispatcher("/reservation-form.jsp").forward(request, response);
                    } else {
                        response.sendRedirect("dashboard");
                    }
                } catch (NumberFormatException e) {
                    response.sendRedirect("dashboard");
                }
            } else {
                response.sendRedirect("dashboard");
            }
        } else if (action.equals("delete")) {
            // Delete reservation - All authenticated users can delete
            String reservationId = request.getParameter("id");
            if (reservationId != null) {
                try {
                    int id = Integer.parseInt(reservationId);
                    if (reservationDAO.deleteReservation(id)) {
                        request.setAttribute("success", "Reservation deleted successfully");
                    } else {
                        request.setAttribute("error", "Failed to delete reservation");
                    }
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "Invalid reservation ID");
                }
            }
            response.sendRedirect("dashboard");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        String action = request.getParameter("action");
        
        if (action == null || action.equals("save")) {
            // Save new or update existing reservation
            String reservationId = request.getParameter("reservationId");
            String guestName = request.getParameter("guestName");
            String guestAddress = request.getParameter("guestAddress");
            String contactNumber = request.getParameter("contactNumber");
            String roomTypeIdStr = request.getParameter("roomTypeId");
            String roomIdStr = request.getParameter("roomId");
            String checkInDateStr = request.getParameter("checkInDate");
            String checkOutDateStr = request.getParameter("checkOutDate");
            
            // Validate input
            if (guestName == null || guestAddress == null || contactNumber == null ||
                roomTypeIdStr == null || roomIdStr == null || checkInDateStr == null || checkOutDateStr == null ||
                guestName.trim().isEmpty() || guestAddress.trim().isEmpty() ||
                contactNumber.trim().isEmpty() || roomIdStr.trim().isEmpty()) {
                request.setAttribute("error", "All fields are required");
                List<RoomType> roomTypes = roomTypeDAO.getAllRoomTypes();
                request.setAttribute("roomTypes", roomTypes);
                request.getRequestDispatcher("/reservation-form.jsp").forward(request, response);
                return;
            }
            
            try {
                int roomTypeId = Integer.parseInt(roomTypeIdStr);
                Date checkInDate = Date.valueOf(checkInDateStr);
                Date checkOutDate = Date.valueOf(checkOutDateStr);
                
                if (checkOutDate.before(checkInDate) || checkOutDate.equals(checkInDate)) {
                    request.setAttribute("error", "Check-out date must be after check-in date");
                    List<RoomType> roomTypes = roomTypeDAO.getAllRoomTypes();
                    request.setAttribute("roomTypes", roomTypes);
                    request.getRequestDispatcher("/reservation-form.jsp").forward(request, response);
                    return;
                }
                
                // Calculate number of nights
                long diffInMillies = checkOutDate.getTime() - checkInDate.getTime();
                int numberOfNights = (int) (diffInMillies / (1000 * 60 * 60 * 24));
                
                // Get room rate and calculate total
                RoomType roomType = roomTypeDAO.getRoomTypeById(roomTypeId);
                if (roomType == null) {
                    request.setAttribute("error", "Invalid room type");
                    List<RoomType> roomTypes = roomTypeDAO.getAllRoomTypes();
                    request.setAttribute("roomTypes", roomTypes);
                    request.getRequestDispatcher("/reservation-form.jsp").forward(request, response);
                    return;
                }
                
                double totalAmount = numberOfNights * roomType.getRatePerNight();
                
                // Determine status based on check-out date
                java.util.Date today = new java.util.Date();
                String status = checkOutDate.before(new java.sql.Date(today.getTime())) ? "COMPLETE" : "CONFIRMED";
                
                // Get selected room ID
                int selectedRoomId = Integer.parseInt(roomIdStr);
                
                // Verify the selected room is available
                Integer excludeReservationId = null;
                if (reservationId != null && !reservationId.trim().isEmpty()) {
                    excludeReservationId = Integer.parseInt(reservationId);
                }
                
                List<Room> availableRooms = roomDAO.getAvailableRooms(roomTypeId, checkInDate, checkOutDate, excludeReservationId);
                
                // Check if selected room is in the available rooms list
                boolean roomAvailable = false;
                Room selectedRoom = null;
                for (Room room : availableRooms) {
                    if (room.getRoomId() == selectedRoomId) {
                        roomAvailable = true;
                        selectedRoom = room;
                        break;
                    }
                }
                
                if (!roomAvailable) {
                    request.setAttribute("error", "The selected room is no longer available for the selected dates. Please choose a different room.");
                    List<RoomType> roomTypes = roomTypeDAO.getAllRoomTypes();
                    request.setAttribute("roomTypes", roomTypes);
                    if (reservationId != null && !reservationId.trim().isEmpty()) {
                        Reservation existingReservation = reservationDAO.getReservationById(Integer.parseInt(reservationId));
                        request.setAttribute("reservation", existingReservation);
                    }
                    request.getRequestDispatcher("/reservation-form.jsp").forward(request, response);
                    return;
                }
                
                Reservation reservation = new Reservation();
                reservation.setGuestName(guestName.trim());
                reservation.setGuestAddress(guestAddress.trim());
                reservation.setContactNumber(contactNumber.trim());
                reservation.setRoomTypeId(roomTypeId);
                reservation.setRoomId(selectedRoomId);
                reservation.setCheckInDate(checkInDate);
                reservation.setCheckOutDate(checkOutDate);
                reservation.setNumberOfNights(numberOfNights);
                reservation.setTotalAmount(totalAmount);
                reservation.setStatus(status);
                reservation.setCreatedBy(user.getUserId());
                
                boolean success;
                if (reservationId != null && !reservationId.trim().isEmpty()) {
                    // Update existing reservation - release old room and assign new one
                    Reservation oldReservation = reservationDAO.getReservationById(Integer.parseInt(reservationId));
                    if (oldReservation != null && oldReservation.getRoomId() > 0) {
                        // Release old room if different from new room
                        if (oldReservation.getRoomId() != selectedRoomId) {
                            roomDAO.updateRoomStatus(oldReservation.getRoomId(), "AVAILABLE");
                        }
                    }
                    
                    reservation.setReservationId(Integer.parseInt(reservationId));
                    reservation.setReservationNumber(request.getParameter("reservationNumber"));
                    success = reservationDAO.updateReservation(reservation);
                } else {
                    // Add new reservation
                    success = reservationDAO.addReservation(reservation);
                }
                
                // Mark room as OCCUPIED if reservation is successful
                if (success && status.equals("CONFIRMED")) {
                    roomDAO.updateRoomStatus(selectedRoomId, "OCCUPIED");
                }
                
                if (success) {
                    String message = reservationId != null && !reservationId.trim().isEmpty() 
                        ? "Reservation updated successfully!" 
                        : "Reservation created successfully!";
                    response.sendRedirect("dashboard?success=" + java.net.URLEncoder.encode(message, "UTF-8"));
                } else {
                    request.setAttribute("error", "Failed to save reservation");
                    List<RoomType> roomTypes = roomTypeDAO.getAllRoomTypes();
                    request.setAttribute("roomTypes", roomTypes);
                    request.getRequestDispatcher("/reservation-form.jsp").forward(request, response);
                }
                
            } catch (Exception e) {
                request.setAttribute("error", "Invalid input: " + e.getMessage());
                List<RoomType> roomTypes = roomTypeDAO.getAllRoomTypes();
                request.setAttribute("roomTypes", roomTypes);
                request.getRequestDispatcher("/reservation-form.jsp").forward(request, response);
            }
        }
    }
}
