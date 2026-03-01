
CREATE DATABASE IF NOT EXISTS Oceanview_Resort_Galle;
USE Oceanview_Resort_Galle;


CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) DEFAULT 'staff',
    locked BOOLEAN DEFAULT FALSE,
    login_attempts INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS room_types (
    room_type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL,
    description TEXT,
    rate_per_night DECIMAL(10, 2) NOT NULL,
    max_occupancy INT NOT NULL,
    amenities TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(20) UNIQUE NOT NULL,
    room_type_id INT NOT NULL,
    status VARCHAR(20) DEFAULT 'AVAILABLE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (room_type_id) REFERENCES room_types(room_type_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_number VARCHAR(20) UNIQUE NOT NULL,
    guest_name VARCHAR(100) NOT NULL,
    guest_address TEXT NOT NULL,
    contact_number VARCHAR(20) NOT NULL,
    room_type_id INT NOT NULL,
    room_id INT,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    number_of_nights INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'CONFIRMED',
    bill_printed BOOLEAN DEFAULT FALSE,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (room_type_id) REFERENCES room_types(room_type_id),
    FOREIGN KEY (room_id) REFERENCES rooms(room_id),
    FOREIGN KEY (created_by) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


INSERT INTO users (username, password, full_name, role) 
VALUES ('admin', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'System Administrator', 'admin');


INSERT INTO users (username, password, full_name, role) 
VALUES ('manager', '866485796cfa8d7c0cf7111640205b83076433547577511d81f8030ae99ecea5', 'Resort Manager', 'manager');


INSERT INTO users (username, password, full_name, role) 
VALUES ('staff', '10176e7b7b24d317acfcf8d2064cfd2f24e154f7b5a96603077d5ef813d6a6b6', 'Staff Member', 'staff');


UPDATE reservations SET status = 'COMPLETE' WHERE check_out_date < CURDATE();

UPDATE reservations SET status = 'CONFIRMED' WHERE check_out_date >= CURDATE() AND (status IS NULL OR status = '' OR status = 'confirmed');


INSERT INTO room_types (type_name, description, rate_per_night, max_occupancy, amenities) VALUES
('Standard Room', 'Comfortable room with ocean view, basic amenities', 5000.00, 2, 'WiFi, TV, AC, Ocean View'),
('Deluxe Room', 'Spacious room with premium ocean view, upgraded amenities', 8000.00, 3, 'WiFi, TV, AC, Mini Bar, Ocean View, Balcony'),
('Suite', 'Luxurious suite with panoramic ocean view, premium amenities', 12000.00, 4, 'WiFi, TV, AC, Mini Bar, Ocean View, Balcony, Living Area, Jacuzzi'),
('Family Room', 'Large room perfect for families, partial ocean view', 10000.00, 5, 'WiFi, TV, AC, Ocean View, Extra Beds');


INSERT INTO rooms (room_number, room_type_id, status) VALUES
('STD-101', 1, 'AVAILABLE'),
('STD-102', 1, 'AVAILABLE'),
('STD-103', 1, 'AVAILABLE'),
('STD-104', 1, 'AVAILABLE'),
('STD-105', 1, 'AVAILABLE');


INSERT INTO rooms (room_number, room_type_id, status) VALUES
('DLX-201', 2, 'AVAILABLE'),
('DLX-202', 2, 'AVAILABLE'),
('DLX-203', 2, 'AVAILABLE'),
('DLX-204', 2, 'AVAILABLE'),
('DLX-205', 2, 'AVAILABLE');


INSERT INTO rooms (room_number, room_type_id, status) VALUES
('SUITE-301', 3, 'AVAILABLE'),
('SUITE-302', 3, 'AVAILABLE'),
('SUITE-303', 3, 'AVAILABLE'),
('SUITE-304', 3, 'AVAILABLE'),
('SUITE-305', 3, 'AVAILABLE');


INSERT INTO rooms (room_number, room_type_id, status) VALUES
('FAM-401', 4, 'AVAILABLE'),
('FAM-402', 4, 'AVAILABLE'),
('FAM-403', 4, 'AVAILABLE'),
('FAM-404', 4, 'AVAILABLE'),
('FAM-405', 4, 'AVAILABLE');


