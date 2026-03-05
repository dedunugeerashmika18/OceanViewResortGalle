<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Help & Guidelines - Ocean View Resort</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .help-section {
            margin-bottom: 25px;
            padding: 20px;
            background-color: #F5F5F5;
            border-left: 4px solid #90AB8B;
            border-radius: 5px;
        }
        .help-section h3 {
            color: #5A7863;
            margin-top: 0;
            margin-bottom: 15px;
            font-size: 1.3em;
        }
        .help-section ul {
            margin: 10px 0;
            padding-left: 25px;
        }
        .help-section ul li {
            margin-bottom: 8px;
            line-height: 1.6;
        }
        .help-section ul ul {
            margin-top: 8px;
            margin-bottom: 8px;
        }
        .help-section strong {
            color: #3B4953;
        }
        .help-note {
            background-color: #FFF3CD;
            border-left: 4px solid #FFC107;
            padding: 15px;
            margin: 15px 0;
            border-radius: 5px;
        }
        .help-warning {
            background-color: #F8D7DA;
            border-left: 4px solid #DC3545;
            padding: 15px;
            margin: 15px 0;
            border-radius: 5px;
        }
        .help-success {
            background-color: #D4EDDA;
            border-left: 4px solid #28A745;
            padding: 15px;
            margin: 15px 0;
            border-radius: 5px;
        }
        .help-toc {
            background-color: #EBF4DD;
            padding: 20px;
            border-radius: 5px;
            margin-bottom: 30px;
        }
        .help-toc h3 {
            color: #5A7863;
            margin-top: 0;
        }
        .help-toc ul {
            columns: 2;
            column-gap: 30px;
            list-style-type: none;
            padding-left: 0;
        }
        .help-toc ul li {
            margin-bottom: 8px;
        }
        .help-toc ul li a {
            color: #3B4953;
            text-decoration: none;
        }
        .help-toc ul li a:hover {
            color: #5A7863;
            text-decoration: underline;
        }
        @media (max-width: 768px) {
            .help-toc ul {
                columns: 1;
            }
        }
    </style>
</head>
<body>
    <%@ include file="includes/header.jsp" %>
    
    <div class="container">
        <div class="card">
            <h2 style="color: #5A7863; margin-bottom: 20px;">📚 Help & Guidelines - Staff Manual</h2>
            
            <!-- Table of Contents -->
            <div class="help-toc">
                <h3>Quick Navigation</h3>
                <ul>
                    <li><a href="#login">1. Login System</a></li>
                    <li><a href="#create-reservation">2. Creating Reservations</a></li>
                    <li><a href="#view-reservations">3. Viewing Reservations</a></li>
                    <li><a href="#edit-reservations">4. Editing Reservations</a></li>
                    <li><a href="#delete-reservations">5. Deleting Reservations</a></li>
                    <li><a href="#search">6. Search Functionality</a></li>
                    <li><a href="#billing">7. Billing & Printing</a></li>
                    <li><a href="#rooms">8. Viewing Rooms</a></li>
                    <li><a href="#room-types">9. Room Types & Rates</a></li>
                    <li><a href="#security">10. Security & Logout</a></li>
                    <li><a href="#troubleshooting">11. Troubleshooting</a></li>
                    <li><a href="#best-practices">12. Best Practices</a></li>
                </ul>
            </div>
            
            <div class="help-section" id="login">
                <h3>1. 🔐 Login System</h3>
                <ul>
                    <li>Use your assigned username and password to log in to the system.</li>
                    <li><strong>Default Admin Credentials:</strong>
                        <ul>
                            <li>Username: <code>admin</code></li>
                            <li>Password: <code>admin123</code></li>
                        </ul>
                    </li>
                    <li>Always log out when you finish your work session.</li>
                    <li>Never share your login credentials with others.</li>
                    <li>Your account will be locked after 3 failed login attempts (Admin accounts are exempt).</li>
                </ul>
                <div class="help-warning">
                    <strong>⚠️ Security Warning:</strong> Never share your password. If you suspect unauthorized access, contact the administrator immediately.
                </div>
            </div>
            
            <div class="help-section" id="create-reservation">
                <h3>2. ➕ Creating a New Reservation</h3>
                <ul>
                    <li>Click on <strong>"New Reservation"</strong> from the navigation menu or dashboard.</li>
                    <li>Fill in all required fields:
                        <ul>
                            <li><strong>Guest Name:</strong> Full name of the guest (required)</li>
                            <li><strong>Contact Number:</strong> Phone number of the guest (required)</li>
                            <li><strong>Guest Address:</strong> Complete address of the guest (required)</li>
                            <li><strong>Room Type:</strong> Select from available room types (required)</li>
                            <li><strong>Check-in Date:</strong> Date when guest will arrive (required)</li>
                            <li><strong>Check-out Date:</strong> Date when guest will depart (required)</li>
                        </ul>
                    </li>
                    <li>The system will automatically:
                        <ul>
                            <li>Generate a unique reservation number (format: RES-YYYYMMDD-XXX)</li>
                            <li>Calculate the number of nights</li>
                            <li>Calculate the total amount based on room rate × number of nights</li>
                            <li>Check room availability for selected dates</li>
                        </ul>
                    </li>
                    <li>Click <strong>"Save Reservation"</strong> to complete the booking.</li>
                    <li>You will be redirected to the dashboard with a success message.</li>
                </ul>
                <div class="help-note">
                    <strong>💡 Tip:</strong> The system prevents double-booking. If a room is not available for your selected dates, choose different dates or another room type.
                </div>
            </div>
            
            <div class="help-section" id="view-reservations">
                <h3>3. 👁️ Viewing Reservations</h3>
                <ul>
                    <li><strong>Dashboard:</strong> View all reservations in a table format with the following information:
                        <ul>
                            <li>Reservation Number</li>
                            <li>Guest Name</li>
                            <li>Contact Number</li>
                            <li>Room Type</li>
                            <li>Room Number (if assigned)</li>
                            <li>Check-in & Check-out Dates</li>
                            <li>Number of Nights</li>
                            <li>Total Amount</li>
                            <li>Status</li>
                        </ul>
                    </li>
                    <li><strong>View Details:</strong> Click "View" next to any reservation to see complete information.</li>
                    <li><strong>Search:</strong> Use the search box on the dashboard to filter reservations by:
                        <ul>
                            <li>Reservation number</li>
                            <li>Guest name</li>
                            <li>Contact number</li>
                            <li>Room type</li>
                        </ul>
                    </li>
                    <li>From the dashboard, you can view, edit, or delete any reservation.</li>
                </ul>
            </div>
            
            <div class="help-section" id="edit-reservations">
                <h3>4. ✏️ Editing Reservations</h3>
                <ul>
                    <li>From the dashboard, click <strong>"Edit"</strong> next to the reservation you want to modify.</li>
                    <li>Update the necessary information in the form.</li>
                    <li>The system will automatically recalculate:
                        <ul>
                            <li>Number of nights (if dates change)</li>
                            <li>Total amount (if dates or room type change)</li>
                        </ul>
                    </li>
                    <li>Click <strong>"Save Reservation"</strong> to update.</li>
                    <li>You will see a success message confirming the update.</li>
                </ul>
                <div class="help-note">
                    <strong>💡 Note:</strong> You can edit reservations at any time. Changes to dates or room type will automatically update the total amount.
                </div>
            </div>
            
            <div class="help-section" id="delete-reservations">
                <h3>5. 🗑️ Deleting Reservations</h3>
                <ul>
                    <li>From the dashboard, click <strong>"Delete"</strong> next to the reservation you want to remove.</li>
                    <li>Confirm the deletion when prompted.</li>
                    <li>The reservation will be permanently removed from the system.</li>
                </ul>
                <div class="help-warning">
                    <strong>⚠️ Warning:</strong> Deleted reservations cannot be recovered. Make sure you want to delete before confirming.
                </div>
            </div>
            
            <div class="help-section" id="search">
                <h3>6. 🔍 Search Functionality</h3>
                <ul>
                    <li>The dashboard includes a powerful search feature at the top of the reservations table.</li>
                    <li>Type any search term to filter reservations in real-time.</li>
                    <li>Search works across multiple fields:
                        <ul>
                            <li>Reservation number</li>
                            <li>Guest name</li>
                            <li>Contact number</li>
                            <li>Room type</li>
                        </ul>
                    </li>
                    <li>Matching text will be highlighted in yellow.</li>
                    <li>Non-matching reservations will be hidden automatically.</li>
                    <li>Clear the search box to show all reservations again.</li>
                </ul>
                <div class="help-success">
                    <strong>✅ Pro Tip:</strong> Use search to quickly find reservations without scrolling through long lists.
                </div>
            </div>
            
            <div class="help-section" id="billing">
                <h3>7. 💰 Billing & Printing</h3>
                <ul>
                    <li>Click <strong>"Billing"</strong> from the navigation menu.</li>
                    <li>Enter the reservation number in the search box.</li>
                    <li>Click <strong>"Search"</strong> to find the reservation.</li>
                    <li>The bill will display:
                        <ul>
                            <li>Reservation number</li>
                            <li>Guest information (name, address, contact)</li>
                            <li>Room type and room number</li>
                            <li>Check-in and check-out dates</li>
                            <li>Number of nights</li>
                            <li>Rate per night</li>
                            <li>Total amount</li>
                            <li>Bill printed status</li>
                        </ul>
                    </li>
                    <li>Click <strong>"Print Bill"</strong> to print the bill (80mm thermal printer format).</li>
                    <li>The system will automatically mark the bill as printed.</li>
                </ul>
                <div class="help-note">
                    <strong>💡 Note:</strong> Bills can only be printed once. The system tracks which bills have been printed.
                </div>
            </div>
            
            <div class="help-section" id="rooms">
                <h3>8. 🏨 Viewing Rooms</h3>
                <ul>
                    <li>Click <strong>"Rooms"</strong> from the navigation menu to view all rooms.</li>
                    <li>The rooms page displays:
                        <ul>
                            <li>Room number</li>
                            <li>Room type</li>
                            <li>Current status (AVAILABLE, OCCUPIED, MAINTENANCE)</li>
                            <li>Current reservations (if any)</li>
                        </ul>
                    </li>
                    <li>Room status is automatically updated:
                        <ul>
                            <li>Rooms become AVAILABLE at 8:00 AM on check-out date</li>
                            <li>Rooms are marked OCCUPIED when reservations are created</li>
                        </ul>
                    </li>
                    <li>Use the search feature to filter rooms by room number or type.</li>
                </ul>
            </div>
            
            <div class="help-section" id="room-types">
                <h3>9. 🏠 Room Types & Rates</h3>
                <ul>
                    <li><strong>Standard Room:</strong> Rs. 5,000 per night
                        <ul>
                            <li>Basic amenities: WiFi, TV, AC</li>
                            <li>Ocean view</li>
                            <li>Max occupancy: 2 guests</li>
                        </ul>
                    </li>
                    <li><strong>Deluxe Room:</strong> Rs. 8,000 per night
                        <ul>
                            <li>Premium amenities: WiFi, TV, AC, Mini Bar</li>
                            <li>Ocean view with balcony</li>
                            <li>Max occupancy: 3 guests</li>
                        </ul>
                    </li>
                    <li><strong>Suite:</strong> Rs. 12,000 per night
                        <ul>
                            <li>Luxury amenities: WiFi, TV, AC, Mini Bar, Jacuzzi</li>
                            <li>Panoramic ocean view with balcony</li>
                            <li>Living area included</li>
                            <li>Max occupancy: 4 guests</li>
                        </ul>
                    </li>
                    <li><strong>Family Room:</strong> Rs. 10,000 per night
                        <ul>
                            <li>Family-friendly amenities: WiFi, TV, AC</li>
                            <li>Partial ocean view</li>
                            <li>Extra beds available</li>
                            <li>Max occupancy: 5 guests</li>
                        </ul>
                    </li>
                </ul>
            </div>
            
            <div class="help-section" id="security">
                <h3>10. 🔒 Security & Logout</h3>
                <ul>
                    <li>Always click the <strong>"Logout"</strong> button in the header to safely exit the system.</li>
                    <li>This will:
                        <ul>
                            <li>End your session</li>
                            <li>Clear session data</li>
                            <li>Protect your account from unauthorized access</li>
                        </ul>
                    </li>
                    <li>Never close the browser without logging out.</li>
                    <li>If you're inactive for a long time, your session may expire automatically.</li>
                    <li>If you see an "Access Denied" message, you may not have permission for that feature.</li>
                </ul>
                <div class="help-warning">
                    <strong>⚠️ Important:</strong> Always log out from shared computers or public terminals.
                </div>
            </div>
            
            <div class="help-section" id="troubleshooting">
                <h3>11. 🔧 Troubleshooting</h3>
                <ul>
                    <li><strong>Cannot log in:</strong>
                        <ul>
                            <li>Verify your username and password are correct</li>
                            <li>Check if your account is locked (contact administrator)</li>
                            <li>Ensure Caps Lock is not enabled</li>
                        </ul>
                    </li>
                    <li><strong>Reservation cannot be saved:</strong>
                        <ul>
                            <li>Check that all required fields are filled</li>
                            <li>Ensure check-out date is after check-in date</li>
                            <li>Verify room is available for selected dates</li>
                            <li>Check that dates are not in the past</li>
                        </ul>
                    </li>
                    <li><strong>Cannot find reservation:</strong>
                        <ul>
                            <li>Use the search function on the dashboard</li>
                            <li>Check if you're searching with the correct reservation number</li>
                            <li>Verify the reservation exists in the system</li>
                        </ul>
                    </li>
                    <li><strong>Bill cannot be printed:</strong>
                        <ul>
                            <li>Ensure printer is connected and powered on</li>
                            <li>Check printer settings (80mm thermal)</li>
                            <li>Verify reservation number is correct</li>
                        </ul>
                    </li>
                    <li>If you encounter any other errors, contact the system administrator.</li>
                </ul>
            </div>
            
            <div class="help-section" id="best-practices">
                <h3>12. ✅ Best Practices</h3>
                <ul>
                    <li><strong>Data Accuracy:</strong>
                        <ul>
                            <li>Always verify guest information before saving a reservation</li>
                            <li>Double-check contact numbers for accuracy</li>
                            <li>Confirm dates with guests before booking</li>
                        </ul>
                    </li>
                    <li><strong>Booking Management:</strong>
                        <ul>
                            <li>Double-check dates to avoid booking conflicts</li>
                            <li>Keep reservation numbers handy for quick reference</li>
                            <li>Update reservation status if there are any changes</li>
                        </ul>
                    </li>
                    <li><strong>Billing:</strong>
                        <ul>
                            <li>Print bills only when requested by guests</li>
                            <li>Verify bill amounts before printing</li>
                            <li>Keep printed bills for records</li>
                        </ul>
                    </li>
                    <li><strong>System Usage:</strong>
                        <ul>
                            <li>Use search functionality to find reservations quickly</li>
                            <li>Log out when finished with your work</li>
                            <li>Report any system issues to the administrator</li>
                        </ul>
                    </li>
                </ul>
            </div>
            
            <div class="help-success" style="margin-top: 30px;">
                <h3 style="margin-bottom: 10px; color: #28A745;">📞 Need More Help?</h3>
                <p>If you have any questions or need assistance, please contact:</p>
                <ul style="margin-top: 10px;">
                    <li><strong>System Administrator:</strong> Available during business hours</li>
                    <li><strong>Resort Management:</strong> Tel: +94 1122445588</li>
                    <li><strong>Email Support:</strong> support@oceanviewresort.lk</li>
                </ul>
                <p style="margin-top: 15px;"><strong>Office Hours:</strong> Monday - Saturday, 8:00 AM - 6:00 PM</p>
            </div>
        </div>
    </div>
    
    <%@ include file="includes/footer.jsp" %>
</body>
</html>
