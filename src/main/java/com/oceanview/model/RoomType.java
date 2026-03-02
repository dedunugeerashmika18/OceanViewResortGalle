package com.oceanview.model;


public class RoomType {
    private int roomTypeId;
    private String typeName;
    private String description;
    private double ratePerNight;
    private int maxOccupancy;
    private String amenities;
    
    public RoomType() {
    }
    
    public RoomType(int roomTypeId, String typeName, String description, 
                   double ratePerNight, int maxOccupancy, String amenities) {
        this.roomTypeId = roomTypeId;
        this.typeName = typeName;
        this.description = description;
        this.ratePerNight = ratePerNight;
        this.maxOccupancy = maxOccupancy;
        this.amenities = amenities;
    }
    
    // Getters and Setters
    public int getRoomTypeId() {
        return roomTypeId;
    }
    
    public void setRoomTypeId(int roomTypeId) {
        this.roomTypeId = roomTypeId;
    }
    
    public String getTypeName() {
        return typeName;
    }
    
    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public double getRatePerNight() {
        return ratePerNight;
    }
    
    public void setRatePerNight(double ratePerNight) {
        this.ratePerNight = ratePerNight;
    }
    
    public int getMaxOccupancy() {
        return maxOccupancy;
    }
    
    public void setMaxOccupancy(int maxOccupancy) {
        this.maxOccupancy = maxOccupancy;
    }
    
    public String getAmenities() {
        return amenities;
    }
    
    public void setAmenities(String amenities) {
        this.amenities = amenities;
    }
}
