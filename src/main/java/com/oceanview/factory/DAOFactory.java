package com.oceanview.factory;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.RoomDAO;
import com.oceanview.dao.RoomTypeDAO;
import com.oceanview.dao.UserDAO;


public class DAOFactory {
    

    private DAOFactory() {

    }
    

    public static UserDAO getUserDAO() {
        return new UserDAO();
    }
    

    public static ReservationDAO getReservationDAO() {
        return new ReservationDAO();
    }
    

    public static RoomDAO getRoomDAO() {
        return new RoomDAO();
    }
    

    public static RoomTypeDAO getRoomTypeDAO() {
        return new RoomTypeDAO();
    }
    

    public static Object getDAO(String daoType) {
        if (daoType == null) {
            throw new IllegalArgumentException("DAO type cannot be null");
        }
        
        switch (daoType.toLowerCase()) {
            case "user":
                return getUserDAO();
            case "reservation":
                return getReservationDAO();
            case "room":
                return getRoomDAO();
            case "roomtype":
            case "room_type":
                return getRoomTypeDAO();
            default:
                throw new IllegalArgumentException("Unknown DAO type: " + daoType);
        }
    }
}
