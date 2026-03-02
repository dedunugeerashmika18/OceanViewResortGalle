package com.oceanview.model;

import java.sql.Date;


public class Reservation {
    private int reservationId;
    private String reservationNumber;
    private String guestName;
    private String guestAddress;
    private String contactNumber;
    private int roomTypeId;
    private String roomTypeName;
    private int roomId;
    private String roomNumber;
    private Date checkInDate;
    private Date checkOutDate;
    private int numberOfNights;
    private double totalAmount;
    private String status;
    private boolean billPrinted;
    private int createdBy;
    private String createdByName;
    private String createdByRole;
    
    public Reservation() {
    }
    
    public Reservation(String reservationNumber, String guestName, String guestAddress,
                      String contactNumber, int roomTypeId, Date checkInDate, 
                      Date checkOutDate, int numberOfNights, double totalAmount) {
        this.reservationNumber = reservationNumber;
        this.guestName = guestName;
        this.guestAddress = guestAddress;
        this.contactNumber = contactNumber;
        this.roomTypeId = roomTypeId;
        this.checkInDate = checkInDate;
        this.checkOutDate = checkOutDate;
        this.numberOfNights = numberOfNights;
        this.totalAmount = totalAmount;
        this.status = "CONFIRMED";
    }
    
    // Getters and Setters
    public int getReservationId() {
        return reservationId;
    }
    
    public void setReservationId(int reservationId) {
        this.reservationId = reservationId;
    }
    
    public String getReservationNumber() {
        return reservationNumber;
    }
    
    public void setReservationNumber(String reservationNumber) {
        this.reservationNumber = reservationNumber;
    }
    
    public String getGuestName() {
        return guestName;
    }
    
    public void setGuestName(String guestName) {
        this.guestName = guestName;
    }
    
    public String getGuestAddress() {
        return guestAddress;
    }
    
    public void setGuestAddress(String guestAddress) {
        this.guestAddress = guestAddress;
    }
    
    public String getContactNumber() {
        return contactNumber;
    }
    
    public void setContactNumber(String contactNumber) {
        this.contactNumber = contactNumber;
    }
    
    public int getRoomTypeId() {
        return roomTypeId;
    }
    
    public void setRoomTypeId(int roomTypeId) {
        this.roomTypeId = roomTypeId;
    }
    
    public String getRoomTypeName() {
        return roomTypeName;
    }
    
    public void setRoomTypeName(String roomTypeName) {
        this.roomTypeName = roomTypeName;
    }
    
    public int getRoomId() {
        return roomId;
    }
    
    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }
    
    public String getRoomNumber() {
        return roomNumber;
    }
    
    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }
    
    public Date getCheckInDate() {
        return checkInDate;
    }
    
    public void setCheckInDate(Date checkInDate) {
        this.checkInDate = checkInDate;
    }
    
    public Date getCheckOutDate() {
        return checkOutDate;
    }
    
    public void setCheckOutDate(Date checkOutDate) {
        this.checkOutDate = checkOutDate;
    }
    
    public int getNumberOfNights() {
        return numberOfNights;
    }
    
    public void setNumberOfNights(int numberOfNights) {
        this.numberOfNights = numberOfNights;
    }
    
    public double getTotalAmount() {
        return totalAmount;
    }
    
    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public boolean isBillPrinted() {
        return billPrinted;
    }
    
    public void setBillPrinted(boolean billPrinted) {
        this.billPrinted = billPrinted;
    }
    
    public int getCreatedBy() {
        return createdBy;
    }
    
    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }
    
    public String getCreatedByName() {
        return createdByName;
    }
    
    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }
    
    public String getCreatedByRole() {
        return createdByRole;
    }
    
    public void setCreatedByRole(String createdByRole) {
        this.createdByRole = createdByRole;
    }
}
