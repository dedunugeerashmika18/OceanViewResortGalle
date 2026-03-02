package com.oceanview.dao;

import com.oceanview.model.RoomType;
import com.oceanview.util.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;


public class RoomTypeDAO {
    

    public List<RoomType> getAllRoomTypes() {
        List<RoomType> roomTypes = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT room_type_id, type_name, description, rate_per_night, max_occupancy, amenities FROM room_types ORDER BY rate_per_night";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                RoomType roomType = new RoomType();
                roomType.setRoomTypeId(rs.getInt("room_type_id"));
                roomType.setTypeName(rs.getString("type_name"));
                roomType.setDescription(rs.getString("description"));
                roomType.setRatePerNight(rs.getDouble("rate_per_night"));
                roomType.setMaxOccupancy(rs.getInt("max_occupancy"));
                roomType.setAmenities(rs.getString("amenities"));
                roomTypes.add(roomType);
            }
        } catch (SQLException e) {
            System.err.println("Error getting room types: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return roomTypes;
    }
    

    public RoomType getRoomTypeById(int roomTypeId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT room_type_id, type_name, description, rate_per_night, max_occupancy, amenities FROM room_types WHERE room_type_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, roomTypeId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                RoomType roomType = new RoomType();
                roomType.setRoomTypeId(rs.getInt("room_type_id"));
                roomType.setTypeName(rs.getString("type_name"));
                roomType.setDescription(rs.getString("description"));
                roomType.setRatePerNight(rs.getDouble("rate_per_night"));
                roomType.setMaxOccupancy(rs.getInt("max_occupancy"));
                roomType.setAmenities(rs.getString("amenities"));
                return roomType;
            }
        } catch (SQLException e) {
            System.err.println("Error getting room type: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return null;
    }
    

    public boolean addRoomType(RoomType roomType) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "INSERT INTO room_types (type_name, description, rate_per_night, max_occupancy, amenities) " +
                        "VALUES (?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, roomType.getTypeName());
            pstmt.setString(2, roomType.getDescription());
            pstmt.setDouble(3, roomType.getRatePerNight());
            pstmt.setInt(4, roomType.getMaxOccupancy());
            pstmt.setString(5, roomType.getAmenities());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error adding room type: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    

    public boolean updateRoomType(RoomType roomType) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "UPDATE room_types SET type_name = ?, description = ?, rate_per_night = ?, " +
                        "max_occupancy = ?, amenities = ? WHERE room_type_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, roomType.getTypeName());
            pstmt.setString(2, roomType.getDescription());
            pstmt.setDouble(3, roomType.getRatePerNight());
            pstmt.setInt(4, roomType.getMaxOccupancy());
            pstmt.setString(5, roomType.getAmenities());
            pstmt.setInt(6, roomType.getRoomTypeId());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error updating room type: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    

    public boolean updateRoomRate(int roomTypeId, double newRate) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "UPDATE room_types SET rate_per_night = ? WHERE room_type_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setDouble(1, newRate);
            pstmt.setInt(2, roomTypeId);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error updating room rate: " + e.getMessage());
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
