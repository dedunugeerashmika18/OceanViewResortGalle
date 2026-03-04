

// Calculate total amount when dates or room type change
function calculateTotal() {
    const checkInDate = document.getElementById('checkInDate').value;
    const checkOutDate = document.getElementById('checkOutDate').value;
    const roomTypeSelect = document.getElementById('roomTypeId');
    const totalAmountDiv = document.getElementById('totalAmount');
    
    if (!checkInDate || !checkOutDate || !roomTypeSelect.value) {
        totalAmountDiv.textContent = 'Rs. 0.00';
        return;
    }
    
    const checkIn = new Date(checkInDate);
    const checkOut = new Date(checkOutDate);
    
    // Validate dates
    if (checkOut <= checkIn) {
        totalAmountDiv.textContent = 'Invalid dates';
        totalAmountDiv.style.color = '#d32f2f';
        return;
    }
    
    // Calculate number of nights
    const diffTime = checkOut - checkIn;
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    
    if (diffDays <= 0) {
        totalAmountDiv.textContent = 'Invalid dates';
        totalAmountDiv.style.color = '#d32f2f';
        return;
    }
    
    // Get room rate
    const selectedOption = roomTypeSelect.options[roomTypeSelect.selectedIndex];
    const ratePerNight = parseFloat(selectedOption.getAttribute('data-rate'));
    
    if (isNaN(ratePerNight)) {
        totalAmountDiv.textContent = 'Rs. 0.00';
        return;
    }
    
    // Calculate total
    const totalAmount = diffDays * ratePerNight;
    totalAmountDiv.textContent = 'Rs. ' + totalAmount.toFixed(2);
    totalAmountDiv.style.color = '#3B4953';
}

// Update room rate display
function updateRoomRate() {
    calculateTotal();
}

// Form validation
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('reservationForm');
    
    if (form) {
        form.addEventListener('submit', function(e) {
            const checkInDate = document.getElementById('checkInDate').value;
            const checkOutDate = document.getElementById('checkOutDate').value;
            
            if (checkInDate && checkOutDate) {
                const checkIn = new Date(checkInDate);
                const checkOut = new Date(checkOutDate);
                
                if (checkOut <= checkIn) {
                    e.preventDefault();
                    alert('Check-out date must be after check-in date');
                    return false;
                }
            }
        });
        
        // Initialize calculation on page load
        calculateTotal();
    }
});

// Set minimum date to today for date inputs
document.addEventListener('DOMContentLoaded', function() {
    const today = new Date().toISOString().split('T')[0];
    const checkInInput = document.getElementById('checkInDate');
    const checkOutInput = document.getElementById('checkOutDate');
    
    if (checkInInput && !checkInInput.value) {
        checkInInput.setAttribute('min', today);
    }
    
    if (checkOutInput && !checkOutInput.value) {
        checkOutInput.setAttribute('min', today);
    }
    
    // Update check-out minimum when check-in changes
    if (checkInInput) {
        checkInInput.addEventListener('change', function() {
            if (checkOutInput && this.value) {
                const checkInDate = new Date(this.value);
                checkInDate.setDate(checkInDate.getDate() + 1);
                checkOutInput.setAttribute('min', checkInDate.toISOString().split('T')[0]);
            }
        });
    }
});
