package com.oceanview.dao;

import com.oceanview.model.Reservation;
import com.oceanview.util.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;


public class ReservationDAO {
    

    private String generateReservationNumber() {
        return "OVR-" + System.currentTimeMillis();
    }
    

    public boolean addReservation(Reservation reservation) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Generate unique reservation number if not provided
            if (reservation.getReservationNumber() == null || reservation.getReservationNumber().isEmpty()) {
                reservation.setReservationNumber(generateReservationNumber());
            }
            
            String sql = "INSERT INTO reservations (reservation_number, guest_name, guest_address, " +
                        "contact_number, room_type_id, room_id, check_in_date, check_out_date, " +
                        "number_of_nights, total_amount, status, created_by) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, reservation.getReservationNumber());
            pstmt.setString(2, reservation.getGuestName());
            pstmt.setString(3, reservation.getGuestAddress());
            pstmt.setString(4, reservation.getContactNumber());
            pstmt.setInt(5, reservation.getRoomTypeId());
            if (reservation.getRoomId() > 0) {
                pstmt.setInt(6, reservation.getRoomId());
            } else {
                pstmt.setNull(6, java.sql.Types.INTEGER);
            }
            pstmt.setDate(7, reservation.getCheckInDate());
            pstmt.setDate(8, reservation.getCheckOutDate());
            pstmt.setInt(9, reservation.getNumberOfNights());
            pstmt.setDouble(10, reservation.getTotalAmount());
            pstmt.setString(11, reservation.getStatus());
            pstmt.setInt(12, reservation.getCreatedBy());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error adding reservation: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    

    public Reservation getReservationByNumber(String reservationNumber) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT r.*, rt.type_name, u.full_name as created_by_name, " +
                        "u.role as creator_role, rm.room_number " +
                        "FROM reservations r " +
                        "LEFT JOIN room_types rt ON r.room_type_id = rt.room_type_id " +
                        "LEFT JOIN users u ON r.created_by = u.user_id " +
                        "LEFT JOIN rooms rm ON r.room_id = rm.room_id " +
                        "WHERE r.reservation_number = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, reservationNumber);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Reservation reservation = mapResultSetToReservation(rs);
                // Ensure status is set correctly
                if (reservation.getStatus() == null || reservation.getStatus().isEmpty()) {
                    Date today = new Date(System.currentTimeMillis());
                    if (reservation.getCheckOutDate().before(today)) {
                        reservation.setStatus("COMPLETE");
                    } else {
                        reservation.setStatus("CONFIRMED");
                    }
                }
                return reservation;
            }
        } catch (SQLException e) {
            System.err.println("Error getting reservation: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return null;
    }
    

    public Reservation getReservationById(int reservationId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT r.*, rt.type_name, u.full_name as created_by_name, " +
                        "u.role as creator_role, rm.room_number " +
                        "FROM reservations r " +
                        "LEFT JOIN room_types rt ON r.room_type_id = rt.room_type_id " +
                        "LEFT JOIN users u ON r.created_by = u.user_id " +
                        "LEFT JOIN rooms rm ON r.room_id = rm.room_id " +
                        "WHERE r.reservation_id = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, reservationId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Reservation reservation = mapResultSetToReservation(rs);
                // Ensure status is set correctly
                if (reservation.getStatus() == null || reservation.getStatus().isEmpty()) {
                    Date today = new Date(System.currentTimeMillis());
                    if (reservation.getCheckOutDate().before(today)) {
                        reservation.setStatus("COMPLETE");
                    } else {
                        reservation.setStatus("CONFIRMED");
                    }
                }
                return reservation;
            }
        } catch (SQLException e) {
            System.err.println("Error getting reservation: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return null;
    }
    

    public void updateReservationStatuses() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            // Update reservations to COMPLETE if:
            // 1. Check-out date has passed (previous day or earlier), OR
            // 2. Check-out date is today AND current time is 8:00 AM or later
            String sql = "UPDATE reservations SET status = 'COMPLETE' " +
                        "WHERE status != 'COMPLETE' " +
                        "AND status != 'CANCELLED' " +
                        "AND (" +
                        "    check_out_date < CURDATE() OR " +
                        "    (check_out_date = CURDATE() AND CURTIME() >= '08:00:00')" +
                        ")";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.executeUpdate();
            pstmt.close();
            
            // Update reservations where check-out date hasn't passed or is today before 8:00 AM to CONFIRMED
            sql = "UPDATE reservations SET status = 'CONFIRMED' " +
                 "WHERE (status IS NULL OR status = '' OR status = 'confirmed') " +
                 "AND (" +
                 "    check_out_date > CURDATE() OR " +
                 "    (check_out_date = CURDATE() AND CURTIME() < '08:00:00')" +
                 ")";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.executeUpdate();
            
        } catch (SQLException e) {
            System.err.println("Error updating reservation statuses: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    

    public List<Reservation> getAllReservations() {
        // Update statuses before fetching
        updateReservationStatuses();
        
        List<Reservation> reservations = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT r.*, rt.type_name, u.full_name as created_by_name, " +
                        "u.role as creator_role, rm.room_number " +
                        "FROM reservations r " +
                        "LEFT JOIN room_types rt ON r.room_type_id = rt.room_type_id " +
                        "LEFT JOIN users u ON r.created_by = u.user_id " +
                        "LEFT JOIN rooms rm ON r.room_id = rm.room_id " +
                        "ORDER BY r.created_at DESC";
            
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Reservation reservation = mapResultSetToReservation(rs);
                // Ensure status is set correctly
                if (reservation.getStatus() == null || reservation.getStatus().isEmpty()) {
                    Date today = new Date(System.currentTimeMillis());
                    if (reservation.getCheckOutDate().before(today)) {
                        reservation.setStatus("COMPLETE");
                    } else {
                        reservation.setStatus("CONFIRMED");
                    }
                }
                reservations.add(reservation);
            }
        } catch (SQLException e) {
            System.err.println("Error getting reservations: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return reservations;
    }
    

    public List<Reservation> getReservationsByCreatorRole(String role) {
        // Update statuses before fetching
        updateReservationStatuses();
        
        List<Reservation> reservations = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT r.*, rt.type_name, u.full_name as created_by_name, " +
                        "rm.room_number, u.role as creator_role " +
                        "FROM reservations r " +
                        "LEFT JOIN room_types rt ON r.room_type_id = rt.room_type_id " +
                        "LEFT JOIN users u ON r.created_by = u.user_id " +
                        "LEFT JOIN rooms rm ON r.room_id = rm.room_id " +
                        "WHERE u.role = ? " +
                        "ORDER BY r.created_at DESC";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, role);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Reservation reservation = mapResultSetToReservation(rs);
                // Ensure status is set correctly
                if (reservation.getStatus() == null || reservation.getStatus().isEmpty()) {
                    Date today = new Date(System.currentTimeMillis());
                    if (reservation.getCheckOutDate().before(today)) {
                        reservation.setStatus("COMPLETE");
                    } else {
                        reservation.setStatus("CONFIRMED");
                    }
                }
                reservations.add(reservation);
            }
        } catch (SQLException e) {
            System.err.println("Error getting reservations by creator role: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return reservations;
    }
    

    public boolean updateReservation(Reservation reservation) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "UPDATE reservations SET guest_name = ?, guest_address = ?, " +
                        "contact_number = ?, room_type_id = ?, room_id = ?, check_in_date = ?, " +
                        "check_out_date = ?, number_of_nights = ?, total_amount = ?, " +
                        "status = ? WHERE reservation_id = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, reservation.getGuestName());
            pstmt.setString(2, reservation.getGuestAddress());
            pstmt.setString(3, reservation.getContactNumber());
            pstmt.setInt(4, reservation.getRoomTypeId());
            if (reservation.getRoomId() > 0) {
                pstmt.setInt(5, reservation.getRoomId());
            } else {
                pstmt.setNull(5, java.sql.Types.INTEGER);
            }
            pstmt.setDate(6, reservation.getCheckInDate());
            pstmt.setDate(7, reservation.getCheckOutDate());
            pstmt.setInt(8, reservation.getNumberOfNights());
            pstmt.setDouble(9, reservation.getTotalAmount());
            pstmt.setString(10, reservation.getStatus());
            pstmt.setInt(11, reservation.getReservationId());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error updating reservation: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    

    public boolean deleteReservation(int reservationId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // First, get the room_id before deleting
            String getRoomSql = "SELECT room_id FROM reservations WHERE reservation_id = ?";
            pstmt = conn.prepareStatement(getRoomSql);
            pstmt.setInt(1, reservationId);
            rs = pstmt.executeQuery();
            
            Integer roomId = null;
            if (rs.next()) {
                int roomIdValue = rs.getInt("room_id");
                if (!rs.wasNull()) {
                    roomId = roomIdValue;
                }
            }
            rs.close();
            pstmt.close();
            
            // Delete the reservation
            String sql = "DELETE FROM reservations WHERE reservation_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, reservationId);
            
            int rowsAffected = pstmt.executeUpdate();
            
            // Release the room if it was assigned
            if (rowsAffected > 0 && roomId != null) {
                pstmt.close();
                String updateRoomSql = "UPDATE rooms SET status = 'AVAILABLE' WHERE room_id = ?";
                pstmt = conn.prepareStatement(updateRoomSql);
                pstmt.setInt(1, roomId);
                pstmt.executeUpdate();
            }
            
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error deleting reservation: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }
    

    private Reservation mapResultSetToReservation(ResultSet rs) throws SQLException {
        Reservation reservation = new Reservation();
        reservation.setReservationId(rs.getInt("reservation_id"));
        reservation.setReservationNumber(rs.getString("reservation_number"));
        reservation.setGuestName(rs.getString("guest_name"));
        reservation.setGuestAddress(rs.getString("guest_address"));
        reservation.setContactNumber(rs.getString("contact_number"));
        reservation.setRoomTypeId(rs.getInt("room_type_id"));
        reservation.setRoomTypeName(rs.getString("type_name"));
        
        // Handle room_id (may be NULL)
        int roomId = rs.getInt("room_id");
        if (!rs.wasNull()) {
            reservation.setRoomId(roomId);
        }
        
        // Handle room_number (may be NULL)
        String roomNumber = rs.getString("room_number");
        if (roomNumber != null) {
            reservation.setRoomNumber(roomNumber);
        }
        
        reservation.setCheckInDate(rs.getDate("check_in_date"));
        reservation.setCheckOutDate(rs.getDate("check_out_date"));
        reservation.setNumberOfNights(rs.getInt("number_of_nights"));
        reservation.setTotalAmount(rs.getDouble("total_amount"));
        reservation.setStatus(rs.getString("status"));
        reservation.setBillPrinted(rs.getBoolean("bill_printed"));
        reservation.setCreatedBy(rs.getInt("created_by"));
        reservation.setCreatedByName(rs.getString("created_by_name"));
        // Handle creator_role (may be NULL)
        try {
            String creatorRole = rs.getString("creator_role");
            if (creatorRole != null) {
                reservation.setCreatedByRole(creatorRole);
            }
        } catch (SQLException e) {
            // Column may not exist in all queries, ignore
        }
        return reservation;
    }
    

    public boolean markBillAsPrinted(int reservationId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "UPDATE reservations SET bill_printed = TRUE WHERE reservation_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, reservationId);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error marking bill as printed: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    

    public boolean markBillAsPrinted(String reservationNumber) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "UPDATE reservations SET bill_printed = TRUE WHERE reservation_number = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, reservationNumber);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error marking bill as printed: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    

    public java.util.Map<String, Object> getRevenueStatistics(Date startDate, Date endDate) {
        java.util.Map<String, Object> stats = new java.util.HashMap<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT " +
                        "COUNT(*) as total_reservations, " +
                        "SUM(total_amount) as total_revenue, " +
                        "AVG(total_amount) as average_revenue, " +
                        "MIN(total_amount) as min_revenue, " +
                        "MAX(total_amount) as max_revenue, " +
                        "SUM(number_of_nights) as total_nights " +
                        "FROM reservations " +
                        "WHERE status != 'CANCELLED' AND bill_printed = TRUE";
            
            if (startDate != null) {
                sql += " AND check_in_date >= ?";
            }
            if (endDate != null) {
                sql += (startDate != null ? " AND" : "") + " check_out_date <= ?";
            }
            
            pstmt = conn.prepareStatement(sql);
            int paramIndex = 1;
            if (startDate != null) {
                pstmt.setDate(paramIndex++, startDate);
            }
            if (endDate != null) {
                pstmt.setDate(paramIndex, endDate);
            }
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                stats.put("totalReservations", rs.getLong("total_reservations"));
                stats.put("totalRevenue", rs.getDouble("total_revenue"));
                stats.put("averageRevenue", rs.getDouble("average_revenue"));
                stats.put("minRevenue", rs.getDouble("min_revenue"));
                stats.put("maxRevenue", rs.getDouble("max_revenue"));
                stats.put("totalNights", rs.getLong("total_nights"));
            }
        } catch (SQLException e) {
            System.err.println("Error getting revenue statistics: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return stats;
    }
    

    public java.util.List<java.util.Map<String, Object>> getRevenueByRoomType(Date startDate, Date endDate) {
        java.util.List<java.util.Map<String, Object>> revenueList = new java.util.ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT rt.type_name, " +
                        "COUNT(r.reservation_id) as reservation_count, " +
                        "SUM(r.total_amount) as total_revenue, " +
                        "AVG(r.total_amount) as average_revenue, " +
                        "SUM(r.number_of_nights) as total_nights " +
                        "FROM reservations r " +
                        "INNER JOIN room_types rt ON r.room_type_id = rt.room_type_id " +
                        "WHERE r.status != 'CANCELLED' AND r.bill_printed = TRUE";
            
            if (startDate != null) {
                sql += " AND r.check_in_date >= ?";
            }
            if (endDate != null) {
                sql += (startDate != null ? " AND" : "") + " r.check_out_date <= ?";
            }
            
            sql += " GROUP BY rt.room_type_id, rt.type_name ORDER BY total_revenue DESC";
            
            pstmt = conn.prepareStatement(sql);
            int paramIndex = 1;
            if (startDate != null) {
                pstmt.setDate(paramIndex++, startDate);
            }
            if (endDate != null) {
                pstmt.setDate(paramIndex, endDate);
            }
            
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                java.util.Map<String, Object> revenue = new java.util.HashMap<>();
                revenue.put("roomType", rs.getString("type_name"));
                revenue.put("reservationCount", rs.getLong("reservation_count"));
                revenue.put("totalRevenue", rs.getDouble("total_revenue"));
                revenue.put("averageRevenue", rs.getDouble("average_revenue"));
                revenue.put("totalNights", rs.getLong("total_nights"));
                revenueList.add(revenue);
            }
        } catch (SQLException e) {
            System.err.println("Error getting revenue by room type: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return revenueList;
    }
    

    public java.util.List<java.util.Map<String, Object>> getRevenueByMonth(Integer year) {
        java.util.List<java.util.Map<String, Object>> revenueList = new java.util.ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT " +
                        "YEAR(check_in_date) as year, " +
                        "MONTH(check_in_date) as month, " +
                        "DATE_FORMAT(check_in_date, '%Y-%m') as month_key, " +
                        "COUNT(*) as reservation_count, " +
                        "SUM(total_amount) as total_revenue " +
                        "FROM reservations " +
                        "WHERE status != 'CANCELLED' AND bill_printed = TRUE";
            
            if (year != null) {
                sql += " AND YEAR(check_in_date) = ?";
            }
            
            sql += " GROUP BY YEAR(check_in_date), MONTH(check_in_date) " +
                   "ORDER BY year DESC, month DESC";
            
            pstmt = conn.prepareStatement(sql);
            if (year != null) {
                pstmt.setInt(1, year);
            }
            
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                java.util.Map<String, Object> revenue = new java.util.HashMap<>();
                revenue.put("year", rs.getInt("year"));
                revenue.put("month", rs.getInt("month"));
                revenue.put("monthKey", rs.getString("month_key"));
                revenue.put("reservationCount", rs.getLong("reservation_count"));
                revenue.put("totalRevenue", rs.getDouble("total_revenue"));
                revenueList.add(revenue);
            }
        } catch (SQLException e) {
            System.err.println("Error getting revenue by month: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return revenueList;
    }
    

    public java.util.List<Reservation> getAllCustomerDetails() {
        return getAllReservations();
    }
    
    private void closeResources(Connection conn, PreparedStatement pstmt, ResultSet rs) {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) DatabaseConnection.closeConnection(conn);
        } catch (SQLException e) {
            System.err.println("Error closing resources: " + e.getMessage());
        }
    }
}
