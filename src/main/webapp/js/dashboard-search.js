
(function() {
    const searchInput = document.getElementById('searchInput');
    const tableBody = document.getElementById('reservationsTableBody');
    
    if (!searchInput || !tableBody) {
        return; // Exit if elements don't exist
    }
    
    // Store original cell content for restoration
    const rows = tableBody.querySelectorAll('.reservation-row');
    const originalContent = new Map();
    
    rows.forEach(function(row) {
        const cells = row.querySelectorAll('.searchable-cell');
        const cellContent = [];
        cells.forEach(function(cell) {
            cellContent.push(cell.innerHTML);
        });
        originalContent.set(row, cellContent);
    });
    
    // Search function
    function performSearch() {
        const searchTerm = searchInput.value.trim().toLowerCase();
        let visibleCount = 0;
        
        rows.forEach(function(row, rowIndex) {
            const reservationNumber = row.getAttribute('data-reservation-number') || '';
            const guestName = row.getAttribute('data-guest-name') || '';
            const contact = row.getAttribute('data-contact') || '';
            const roomType = row.getAttribute('data-room-type') || '';
            
            // Check if any field matches
            const matches = reservationNumber.includes(searchTerm) ||
                           guestName.includes(searchTerm) ||
                           contact.includes(searchTerm) ||
                           roomType.includes(searchTerm);
            
            if (searchTerm === '' || matches) {
                // Show row
                row.style.display = '';
                row.classList.remove('no-match');
                
                if (searchTerm !== '') {
                    // Highlight matching row
                    row.classList.add('search-match');
                    
                    // Highlight matching text in cells
                    const cells = row.querySelectorAll('.searchable-cell');
                    const originalCells = originalContent.get(row);
                    
                    cells.forEach(function(cell, cellIndex) {
                        if (originalCells && originalCells[cellIndex]) {
                            const cellText = originalCells[cellIndex];
                            const cellTextLower = cellText.toLowerCase();
                            
                            if (cellTextLower.includes(searchTerm)) {
                                // Simple text replacement without regex
                                const startIndex = cellTextLower.indexOf(searchTerm);
                                const endIndex = startIndex + searchTerm.length;
                                const beforeMatch = cellText.substring(0, startIndex);
                                const matchText = cellText.substring(startIndex, endIndex);
                                const afterMatch = cellText.substring(endIndex);
                                
                                cell.innerHTML = beforeMatch + 
                                    '<mark class="search-highlight">' + matchText + '</mark>' + 
                                    afterMatch;
                            } else {
                                cell.innerHTML = originalCells[cellIndex];
                            }
                        }
                    });
                } else {
                    // Remove highlight when search is cleared
                    row.classList.remove('search-match');
                    
                    // Restore original content
                    const cells = row.querySelectorAll('.searchable-cell');
                    const originalCells = originalContent.get(row);
                    
                    if (originalCells) {
                        cells.forEach(function(cell, cellIndex) {
                            cell.innerHTML = originalCells[cellIndex];
                        });
                    }
                }
                
                visibleCount++;
            } else {
                // Hide non-matching row
                row.style.display = 'none';
                row.classList.remove('search-match');
                row.classList.add('no-match');
                
                // Restore original content
                const cells = row.querySelectorAll('.searchable-cell');
                const originalCells = originalContent.get(row);
                
                if (originalCells) {
                    cells.forEach(function(cell, cellIndex) {
                        cell.innerHTML = originalCells[cellIndex];
                    });
                }
            }
        });
    }
    
    // Add event listener for real-time search
    searchInput.addEventListener('input', performSearch);
    
    // Also handle paste events
    searchInput.addEventListener('paste', function() {
        setTimeout(performSearch, 10);
    });
})();
