package com.oceanview.dao;

import com.oceanview.model.Room;
import com.oceanview.util.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;


public class RoomDAO {
    

    public List<Room> getAllRooms() {
        List<Room> rooms = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT r.room_id, r.room_number, r.room_type_id, r.status, rt.type_name " +
                        "FROM rooms r " +
                        "LEFT JOIN room_types rt ON r.room_type_id = rt.room_type_id " +
                        "ORDER BY r.room_type_id, r.room_number";
            
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Room room = new Room();
                room.setRoomId(rs.getInt("room_id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setRoomTypeId(rs.getInt("room_type_id"));
                room.setStatus(rs.getString("status"));
                room.setRoomTypeName(rs.getString("type_name"));
                rooms.add(room);
            }
        } catch (SQLException e) {
            System.err.println("Error getting rooms: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return rooms;
    }
    

    public List<Room> getAvailableRooms(int roomTypeId, Date checkInDate, Date checkOutDate, Integer excludeReservationId) {
        List<Room> availableRooms = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Find rooms that are not reserved during the requested date range
            // A room is NOT available if there's an overlapping reservation
            // Since rooms are ready by 8:00 AM on check-out date:
            // - If res.check_out_date = checkInDate, room IS available (ready by 8:00 AM)
            // - If res.check_in_date = checkOutDate, room IS available (no overlap)
            // So overlap exists when: res.check_in_date < checkOutDate AND res.check_out_date > checkInDate
            String sql = "SELECT DISTINCT r.room_id, r.room_number, r.room_type_id, r.status, rt.type_name " +
                        "FROM rooms r " +
                        "LEFT JOIN room_types rt ON r.room_type_id = rt.room_type_id " +
                        "WHERE r.room_type_id = ? " +
                        "AND r.status = 'AVAILABLE' " +
                        "AND r.room_id NOT IN (" +
                        "    SELECT DISTINCT res.room_id " +
                        "    FROM reservations res " +
                        "    WHERE res.room_id IS NOT NULL " +
                        "    AND res.status != 'CANCELLED' " +
                        "    AND res.status != 'COMPLETE' " +
                        "    AND res.check_in_date < ? " + // Reservation starts before requested check-out
                        "    AND res.check_out_date > ?"; // Reservation ends after requested check-in (room ready by 8:00 AM on check-out date)
            
            if (excludeReservationId != null) {
                sql += "    AND res.reservation_id != ?";
            }
            sql += ") ORDER BY r.room_number";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, roomTypeId);
            pstmt.setDate(2, checkOutDate); // res.check_in_date < checkOutDate
            pstmt.setDate(3, checkInDate);  // res.check_out_date > checkInDate
            
            if (excludeReservationId != null) {
                pstmt.setInt(4, excludeReservationId);
            }
            
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Room room = new Room();
                room.setRoomId(rs.getInt("room_id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setRoomTypeId(rs.getInt("room_type_id"));
                room.setStatus(rs.getString("status"));
                room.setRoomTypeName(rs.getString("type_name"));
                availableRooms.add(room);
            }
        } catch (SQLException e) {
            System.err.println("Error getting available rooms: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return availableRooms;
    }
    

    public Room getRoomById(int roomId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT r.room_id, r.room_number, r.room_type_id, r.status, rt.type_name " +
                        "FROM rooms r " +
                        "LEFT JOIN room_types rt ON r.room_type_id = rt.room_type_id " +
                        "WHERE r.room_id = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, roomId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Room room = new Room();
                room.setRoomId(rs.getInt("room_id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setRoomTypeId(rs.getInt("room_type_id"));
                room.setStatus(rs.getString("status"));
                room.setRoomTypeName(rs.getString("type_name"));
                return room;
            }
        } catch (SQLException e) {
            System.err.println("Error getting room: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return null;
    }
    

    public boolean updateRoomStatus(int roomId, String status) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "UPDATE rooms SET status = ? WHERE room_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, status);
            pstmt.setInt(2, roomId);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error updating room status: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    

    public void updateRoomAvailability() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Mark rooms as AVAILABLE if:
            // 1. Check-out date has passed (previous day or earlier), OR
            // 2. Check-out date is today AND current time is 8:00 AM or later
            String sql = "UPDATE rooms r " +
                        "INNER JOIN reservations res ON r.room_id = res.room_id " +
                        "SET r.status = 'AVAILABLE' " +
                        "WHERE r.status = 'OCCUPIED' " +
                        "AND (" +
                        "    res.check_out_date < CURDATE() OR " +
                        "    (res.check_out_date = CURDATE() AND CURTIME() >= '08:00:00')" +
                        ")";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.executeUpdate();
            
            // Mark rooms as OCCUPIED if they have active reservations
            // (check-in date has passed or is today, and check-out date is today after 8:00 AM or future)
            sql = "UPDATE rooms r " +
                  "INNER JOIN reservations res ON r.room_id = res.room_id " +
                  "SET r.status = 'OCCUPIED' " +
                  "WHERE r.status = 'AVAILABLE' " +
                  "AND res.status = 'CONFIRMED' " +
                  "AND res.check_in_date <= CURDATE() " +
                  "AND (" +
                  "    res.check_out_date > CURDATE() OR " +
                  "    (res.check_out_date = CURDATE() AND CURTIME() < '08:00:00')" +
                  ")";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.executeUpdate();
            
        } catch (SQLException e) {
            System.err.println("Error updating room availability: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    

    public boolean isRoomTypeAvailable(int roomTypeId, Date checkInDate, Date checkOutDate, Integer excludeReservationId) {
        List<Room> availableRooms = getAvailableRooms(roomTypeId, checkInDate, checkOutDate, excludeReservationId);
        return !availableRooms.isEmpty();
    }
    

    public boolean addRoom(Room room) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "INSERT INTO rooms (room_number, room_type_id, status) VALUES (?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, room.getRoomNumber());
            pstmt.setInt(2, room.getRoomTypeId());
            pstmt.setString(3, room.getStatus() != null ? room.getStatus() : "AVAILABLE");
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error adding room: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    

    public boolean updateRoom(Room room) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "UPDATE rooms SET room_number = ?, room_type_id = ?, status = ? WHERE room_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, room.getRoomNumber());
            pstmt.setInt(2, room.getRoomTypeId());
            pstmt.setString(3, room.getStatus());
            pstmt.setInt(4, room.getRoomId());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error updating room: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    

    public boolean deleteRoom(int roomId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            // Check if room has reservations
            String checkSql = "SELECT COUNT(*) as count FROM reservations WHERE room_id = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setInt(1, roomId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next() && rs.getInt("count") > 0) {
                // Room has reservations, cannot delete
                return false;
            }
            
            // Delete room
            String sql = "DELETE FROM rooms WHERE room_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, roomId);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error deleting room: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(conn, pstmt, null);
        }
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
