package com.oceanview.dao;

import com.oceanview.model.User;
import com.oceanview.util.DatabaseConnection;
import com.oceanview.util.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;


public class UserDAO {
    

    public User authenticate(String username, String password) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT user_id, username, password, full_name, role, locked, login_attempts FROM users WHERE username = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                String userRole = rs.getString("role");
                boolean isLocked = rs.getBoolean("locked");
                
                // Check if account is locked (only for manager/staff, admin cannot be locked)
                if (isLocked && !"admin".equals(userRole)) {
                    return null; // Account is locked
                }
                
                String storedHash = rs.getString("password");
                if (PasswordUtil.verifyPassword(password, storedHash)) {
                    // Successful login - reset login attempts
                    int userId = rs.getInt("user_id");
                    resetLoginAttempts(userId);
                    
                    User user = new User();
                    user.setUserId(userId);
                    user.setUsername(rs.getString("username"));
                    user.setPassword(rs.getString("password"));
                    user.setFullName(rs.getString("full_name"));
                    user.setRole(userRole);
                    user.setLocked(false);
                    user.setLoginAttempts(0);
                    return user;
                } else {
                    // Failed login - increment attempts (only for manager/staff)
                    if (!"admin".equals(userRole)) {
                        int userId = rs.getInt("user_id");
                        incrementLoginAttempts(userId);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Error authenticating user: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return null;
    }
    

    private void incrementLoginAttempts(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            // First, get current attempts and role
            String selectSql = "SELECT login_attempts, role FROM users WHERE user_id = ?";
            pstmt = conn.prepareStatement(selectSql);
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                String role = rs.getString("role");
                // Admin accounts are never locked
                if ("admin".equals(role)) {
                    return; // Don't increment attempts for admin
                }
                
                int currentAttempts = rs.getInt("login_attempts");
                int newAttempts = currentAttempts + 1;
                
                // Update attempts and lock if >= 3 (only for non-admin)
                String updateSql = "UPDATE users SET login_attempts = ?, locked = ? WHERE user_id = ?";
                pstmt = conn.prepareStatement(updateSql);
                pstmt.setInt(1, newAttempts);
                pstmt.setBoolean(2, newAttempts >= 3);
                pstmt.setInt(3, userId);
                pstmt.executeUpdate();
            }
        } catch (SQLException e) {
            System.err.println("Error incrementing login attempts: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    

    private void resetLoginAttempts(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "UPDATE users SET login_attempts = 0, locked = FALSE WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Error resetting login attempts: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    

    public boolean unlockUser(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            // First check if user is admin - admin accounts should never be locked
            String checkSql = "SELECT role FROM users WHERE user_id = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                String role = rs.getString("role");
                if ("admin".equals(role)) {
                    // Admin accounts cannot be locked/unlocked
                    return false;
                }
            }
            
            // Unlock the account
            String sql = "UPDATE users SET locked = FALSE, login_attempts = 0 WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error unlocking user: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    

    public User getUserByUsername(String username) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT user_id, username, password, full_name, role, locked, login_attempts FROM users WHERE username = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setFullName(rs.getString("full_name"));
                String role = rs.getString("role");
                user.setRole(role);
                // Admin accounts are never locked, always show as unlocked
                boolean isLocked = rs.getBoolean("locked");
                if ("admin".equals(role)) {
                    user.setLocked(false);
                    user.setLoginAttempts(0);
                } else {
                    user.setLocked(isLocked);
                    user.setLoginAttempts(rs.getInt("login_attempts"));
                }
                return user;
            }
        } catch (SQLException e) {
            System.err.println("Error getting user: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return null;
    }
    

    public User getUserById(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT user_id, username, password, full_name, role, locked, login_attempts FROM users WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setFullName(rs.getString("full_name"));
                String role = rs.getString("role");
                user.setRole(role);
                // Admin accounts are never locked, always show as unlocked
                boolean isLocked = rs.getBoolean("locked");
                if ("admin".equals(role)) {
                    user.setLocked(false);
                    user.setLoginAttempts(0);
                } else {
                    user.setLocked(isLocked);
                    user.setLoginAttempts(rs.getInt("login_attempts"));
                }
                return user;
            }
        } catch (SQLException e) {
            System.err.println("Error getting user: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return null;
    }
    

    public java.util.List<User> getAllUsers() {
        java.util.List<User> users = new java.util.ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT user_id, username, password, full_name, role, locked, login_attempts, created_at FROM users ORDER BY created_at DESC";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setFullName(rs.getString("full_name"));
                String role = rs.getString("role");
                user.setRole(role);
                // Admin accounts are never locked, always show as unlocked
                boolean isLocked = rs.getBoolean("locked");
                if ("admin".equals(role)) {
                    user.setLocked(false);
                    user.setLoginAttempts(0);
                } else {
                    user.setLocked(isLocked);
                    user.setLoginAttempts(rs.getInt("login_attempts"));
                }
                users.add(user);
            }
        } catch (SQLException e) {
            System.err.println("Error getting all users: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return users;
    }
    

    public boolean addUser(User user) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "INSERT INTO users (username, password, full_name, role) VALUES (?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, user.getUsername());
            pstmt.setString(2, user.getPassword()); // Should already be hashed
            pstmt.setString(3, user.getFullName());
            pstmt.setString(4, user.getRole());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error adding user: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    

    public boolean updateUser(User user) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "UPDATE users SET username = ?, full_name = ?, role = ? WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, user.getUsername());
            pstmt.setString(2, user.getFullName());
            pstmt.setString(3, user.getRole());
            pstmt.setInt(4, user.getUserId());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error updating user: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    

    public boolean updateUserPassword(int userId, String hashedPassword) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "UPDATE users SET password = ? WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, hashedPassword);
            pstmt.setInt(2, userId);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error updating user password: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    

    public boolean deleteUser(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            // Check if user has created reservations
            String checkSql = "SELECT COUNT(*) as count FROM reservations WHERE created_by = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setInt(1, userId);
            java.sql.ResultSet rs = pstmt.executeQuery();
            
            if (rs.next() && rs.getInt("count") > 0) {
                // User has reservations, cannot delete
                return false;
            }
            
            // Delete user
            String sql = "DELETE FROM users WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error deleting user: " + e.getMessage());
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
