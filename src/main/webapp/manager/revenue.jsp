<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Revenue Analysis - Ocean View Resort</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: #EBF4DD;
            border: 2px solid #90AB8B;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
        }
        .stat-value {
            font-size: 2em;
            font-weight: bold;
            color: #5A7863;
            margin: 10px 0;
        }
        .stat-label {
            color: #3B4953;
            font-size: 0.9em;
        }
        .filter-section {
            background: #EBF4DD;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        .filter-row {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            align-items: end;
        }
        .filter-group {
            flex: 1;
            min-width: 150px;
        }
        .filter-group:last-child {
            display: flex;
            gap: 10px;
            align-items: flex-end;
            flex-wrap: wrap;
            flex: 0 0 auto;
        }
        .filter-group label {
            display: block;
            margin-bottom: 8px;
            color: #3B4953;
            font-weight: 500;
            font-size: 0.95em;
        }
        .filter-group .btn {
            white-space: nowrap;
        }
        .filter-group .form-control {
            width: 100%;
            padding: 10px 12px;
            border: 2px solid #90AB8B;
            border-radius: 5px;
            font-size: 1em;
            background-color: #fff;
            color: #3B4953;
            transition: border-color 0.3s;
            box-sizing: border-box;
        }
        .filter-group .form-control:focus {
            outline: none;
            border-color: #5A7863;
            box-shadow: 0 0 0 3px rgba(90, 120, 99, 0.1);
        }
        .filter-group input[type="date"] {
            position: relative;
        }
        .filter-group input[type="date"]::-webkit-calendar-picker-indicator {
            cursor: pointer;
            opacity: 0.7;
            padding: 5px;
        }
        .filter-group input[type="date"]::-webkit-calendar-picker-indicator:hover {
            opacity: 1;
        }
        .filter-group input[type="number"] {
            -moz-appearance: textfield;
        }
        .filter-group input[type="number"]::-webkit-outer-spin-button,
        .filter-group input[type="number"]::-webkit-inner-spin-button {
            -webkit-appearance: none;
            margin: 0;
        }
        .charts-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
            gap: 30px;
            margin-top: 30px;
        }
        .chart-card {
            background: #EBF4DD;
            border: 2px solid #90AB8B;
            border-radius: 8px;
            padding: 20px;
        }
        .chart-card h3 {
            color: #3B4953;
            margin-bottom: 20px;
            text-align: center;
            font-size: 1.3em;
        }
        .chart-wrapper {
            position: relative;
            height: 400px;
            width: 100%;
        }
        .chart-toggle {
            display: flex;
            gap: 10px;
            justify-content: center;
            margin-bottom: 15px;
        }
        .chart-toggle button {
            padding: 8px 15px;
            border: 2px solid #90AB8B;
            background: #EBF4DD;
            color: #3B4953;
            border-radius: 5px;
            cursor: pointer;
            font-size: 0.9em;
            transition: all 0.3s;
        }
        .chart-toggle button:hover {
            background: #90AB8B;
            color: #EBF4DD;
        }
        .chart-toggle button.active {
            background: #5A7863;
            color: #EBF4DD;
            border-color: #5A7863;
        }
    </style>
    <!-- Chart.js Library -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
</head>
<body>
    <%@ include file="../includes/header.jsp" %>
    
    <div class="container">
        <div class="card">
            <h2>Revenue Analysis</h2>
            
            <!-- Filter Section -->
            <div class="filter-section">
                <form method="get" action="revenue" class="filter-row" id="filterForm">
                    <div class="filter-group">
                        <label for="startDate">Start Date</label>
                        <input type="date" id="startDate" name="startDate" 
                               value="<%= request.getAttribute("startDate") != null ? request.getAttribute("startDate") : "" %>"
                               class="form-control">
                    </div>
                    <div class="filter-group">
                        <label for="endDate">End Date</label>
                        <input type="date" id="endDate" name="endDate" 
                               value="<%= request.getAttribute("endDate") != null ? request.getAttribute("endDate") : "" %>"
                               class="form-control">
                    </div>
                    <div class="filter-group">
                        <label for="year">Year</label>
                        <input type="number" id="year" name="year" 
                               value="<%= request.getAttribute("year") != null ? request.getAttribute("year") : "" %>"
                               placeholder="e.g., 2026" min="2020" max="2099"
                               class="form-control">
                    </div>
                    <div class="filter-group">
                        <label>&nbsp;</label>
                        <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                            <button type="submit" class="btn btn-primary">Filter</button>
                            <a href="revenue" class="btn btn-secondary">Clear</a>
                            <button type="button" class="btn btn-success" onclick="downloadPDF()">
                                📥 Download PDF
                            </button>
                        </div>
                    </div>
                </form>
            </div>
            
            <%
                Map<String, Object> stats = (Map<String, Object>) request.getAttribute("revenueStats");
                DecimalFormat df = new DecimalFormat("#,##0.00");
            %>
            
            <!-- Statistics Cards -->
            <% if (stats != null && !stats.isEmpty()) { %>
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-label">Total Reservations</div>
                        <div class="stat-value"><%= stats.get("totalReservations") != null ? stats.get("totalReservations") : 0 %></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-label">Total Revenue</div>
                        <div class="stat-value">Rs. <%= stats.get("totalRevenue") != null ? df.format(stats.get("totalRevenue")) : "0.00" %></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-label">Average Revenue</div>
                        <div class="stat-value">Rs. <%= stats.get("averageRevenue") != null ? df.format(stats.get("averageRevenue")) : "0.00" %></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-label">Total Nights</div>
                        <div class="stat-value"><%= stats.get("totalNights") != null ? stats.get("totalNights") : 0 %></div>
                    </div>
                </div>
            <% } %>
            
            <!-- Charts Section -->
            <%
                List<Map<String, Object>> revenueByRoomType = (List<Map<String, Object>>) request.getAttribute("revenueByRoomType");
                List<Map<String, Object>> revenueByMonth = (List<Map<String, Object>>) request.getAttribute("revenueByMonth");
                
                if ((revenueByRoomType != null && !revenueByRoomType.isEmpty()) || 
                    (revenueByMonth != null && !revenueByMonth.isEmpty())) {
            %>
                <div class="charts-container">
                    <!-- Revenue by Room Type Chart -->
                    <% if (revenueByRoomType != null && !revenueByRoomType.isEmpty()) { %>
                        <div class="chart-card">
                            <h3>Revenue by Room Type</h3>
                            <div class="chart-toggle">
                                <button onclick="switchRoomTypeChart('bar')" class="active" id="roomTypeBarBtn">Bar Chart</button>
                                <button onclick="switchRoomTypeChart('pie')" id="roomTypePieBtn">Pie Chart</button>
                            </div>
                            <div class="chart-wrapper">
                                <canvas id="roomTypeChart"></canvas>
                            </div>
                        </div>
                    <% } %>
                    
                    <!-- Revenue by Month Chart -->
                    <% if (revenueByMonth != null && !revenueByMonth.isEmpty()) { %>
                        <div class="chart-card">
                            <h3>Revenue by Month</h3>
                            <div class="chart-toggle">
                                <button onclick="switchMonthChart('line')" class="active" id="monthLineBtn">Line Chart</button>
                                <button onclick="switchMonthChart('bar')" id="monthBarBtn">Bar Chart</button>
                            </div>
                            <div class="chart-wrapper">
                                <canvas id="monthChart"></canvas>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>
            
            <!-- Revenue by Room Type Table -->
            <%
                if (revenueByRoomType != null && !revenueByRoomType.isEmpty()) {
            %>
                <h3 style="margin-top: 30px; margin-bottom: 15px;">Revenue by Room Type - Details</h3>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Room Type</th>
                            <th>Reservations</th>
                            <th>Total Revenue</th>
                            <th>Average Revenue</th>
                            <th>Total Nights</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> revenue : revenueByRoomType) { %>
                            <tr>
                                <td><strong><%= revenue.get("roomType") %></strong></td>
                                <td><%= revenue.get("reservationCount") %></td>
                                <td>Rs. <%= df.format(revenue.get("totalRevenue")) %></td>
                                <td>Rs. <%= df.format(revenue.get("averageRevenue")) %></td>
                                <td><%= revenue.get("totalNights") %></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
            
            <!-- Revenue by Month Table -->
            <%
                if (revenueByMonth != null && !revenueByMonth.isEmpty()) {
            %>
                <h3 style="margin-top: 30px; margin-bottom: 15px;">Revenue by Month - Details</h3>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Month</th>
                            <th>Reservations</th>
                            <th>Total Revenue</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> revenue : revenueByMonth) { 
                            String monthKey = (String) revenue.get("monthKey");
                            int month = (Integer) revenue.get("month");
                            String[] monthNames = {"", "January", "February", "March", "April", "May", "June", 
                                                   "July", "August", "September", "October", "November", "December"};
                        %>
                            <tr>
                                <td><strong><%= monthNames[month] %> <%= revenue.get("year") %></strong></td>
                                <td><%= revenue.get("reservationCount") %></td>
                                <td>Rs. <%= df.format(revenue.get("totalRevenue")) %></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
    </div>
    
    <%@ include file="../includes/footer.jsp" %>
    
    <script>
        function downloadPDF() {
            // Get current filter values
            const form = document.getElementById('filterForm');
            const formData = new FormData(form);
            const params = new URLSearchParams();
            
            // Add filter parameters
            if (formData.get('startDate')) {
                params.append('startDate', formData.get('startDate'));
            }
            if (formData.get('endDate')) {
                params.append('endDate', formData.get('endDate'));
            }
            if (formData.get('year')) {
                params.append('year', formData.get('year'));
            }
            
            // Open PDF download
            window.location.href = '<%= request.getContextPath() %>/manager/revenue-pdf?' + params.toString();
        }
        
        // Chart data from server
        const revenueByRoomTypeData = [];
        <% if (revenueByRoomType != null && !revenueByRoomType.isEmpty()) { %>
            <% for (Map<String, Object> revenue : revenueByRoomType) { 
                String roomType = (String) revenue.get("roomType");
                roomType = roomType != null ? roomType.replace("'", "\\'") : "";
            %>
                revenueByRoomTypeData.push({
                    roomType: '<%= roomType %>',
                    totalRevenue: <%= revenue.get("totalRevenue") != null ? revenue.get("totalRevenue") : 0 %>,
                    reservationCount: <%= revenue.get("reservationCount") != null ? revenue.get("reservationCount") : 0 %>
                });
            <% } %>
        <% } %>
        
        const revenueByMonthData = [];
        <% if (revenueByMonth != null && !revenueByMonth.isEmpty()) { 
            String[] monthNames = {"", "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                                   "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
            for (Map<String, Object> revenue : revenueByMonth) {
                int month = (Integer) revenue.get("month");
                int year = (Integer) revenue.get("year");
        %>
            revenueByMonthData.push({
                label: '<%= monthNames[month] %> <%= year %>',
                revenue: <%= revenue.get("totalRevenue") != null ? revenue.get("totalRevenue") : 0 %>,
                reservations: <%= revenue.get("reservationCount") != null ? revenue.get("reservationCount") : 0 %>
            });
        <% } } %>
        
        // Chart instances
        let roomTypeChart = null;
        let monthChart = null;
        let currentRoomTypeChartType = 'bar';
        let currentMonthChartType = 'line';
        
        // Color palette matching the resort theme
        const chartColors = {
            primary: '#5A7863',
            secondary: '#90AB8B',
            accent: '#EBF4DD',
            dark: '#3B4953',
            colors: ['#5A7863', '#90AB8B', '#3B4953', '#388e3c', '#1976d2', '#d32f2f', '#f57c00', '#7b1fa2']
        };
        
        // Initialize charts when page loads
        document.addEventListener('DOMContentLoaded', function() {
            if (revenueByRoomTypeData.length > 0) {
                createRoomTypeChart('bar');
            }
            if (revenueByMonthData.length > 0) {
                createMonthChart('line');
            }
        });
        
        // Room Type Chart Functions
        function createRoomTypeChart(type) {
            const ctx = document.getElementById('roomTypeChart');
            if (!ctx) return;
            
            if (roomTypeChart) {
                roomTypeChart.destroy();
            }
            
            const labels = revenueByRoomTypeData.map(d => d.roomType);
            const revenues = revenueByRoomTypeData.map(d => d.totalRevenue);
            
            if (type === 'pie') {
                roomTypeChart = new Chart(ctx, {
                    type: 'pie',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Revenue (Rs.)',
                            data: revenues,
                            backgroundColor: chartColors.colors,
                            borderColor: chartColors.dark,
                            borderWidth: 2
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: true,
                        plugins: {
                            legend: {
                                position: 'bottom',
                                labels: {
                                    padding: 15,
                                    font: {
                                        size: 12
                                    }
                                }
                            },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        return context.label + ': Rs. ' + context.parsed.toLocaleString('en-US', {
                                            minimumFractionDigits: 2,
                                            maximumFractionDigits: 2
                                        });
                                    }
                                }
                            }
                        }
                    }
                });
            } else {
                roomTypeChart = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Total Revenue (Rs.)',
                            data: revenues,
                            backgroundColor: chartColors.primary,
                            borderColor: chartColors.dark,
                            borderWidth: 2
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: true,
                        scales: {
                            y: {
                                beginAtZero: true,
                                ticks: {
                                    callback: function(value) {
                                        return 'Rs. ' + value.toLocaleString('en-US');
                                    }
                                }
                            }
                        },
                        plugins: {
                            legend: {
                                display: false
                            },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        return 'Revenue: Rs. ' + context.parsed.y.toLocaleString('en-US', {
                                            minimumFractionDigits: 2,
                                            maximumFractionDigits: 2
                                        });
                                    }
                                }
                            }
                        }
                    }
                });
            }
        }
        
        function switchRoomTypeChart(type) {
            currentRoomTypeChartType = type;
            createRoomTypeChart(type);
            
            // Update button states
            document.getElementById('roomTypeBarBtn').classList.toggle('active', type === 'bar');
            document.getElementById('roomTypePieBtn').classList.toggle('active', type === 'pie');
        }
        
        // Month Chart Functions
        function createMonthChart(type) {
            const ctx = document.getElementById('monthChart');
            if (!ctx) return;
            
            if (monthChart) {
                monthChart.destroy();
            }
            
            const labels = revenueByMonthData.map(d => d.label);
            const revenues = revenueByMonthData.map(d => d.revenue);
            
            if (type === 'line') {
                monthChart = new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Revenue (Rs.)',
                            data: revenues,
                            borderColor: chartColors.primary,
                            backgroundColor: chartColors.accent,
                            borderWidth: 3,
                            fill: true,
                            tension: 0.4,
                            pointBackgroundColor: chartColors.primary,
                            pointBorderColor: chartColors.dark,
                            pointRadius: 5,
                            pointHoverRadius: 7
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: true,
                        scales: {
                            y: {
                                beginAtZero: true,
                                ticks: {
                                    callback: function(value) {
                                        return 'Rs. ' + value.toLocaleString('en-US');
                                    }
                                }
                            }
                        },
                        plugins: {
                            legend: {
                                display: true,
                                position: 'top'
                            },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        return 'Revenue: Rs. ' + context.parsed.y.toLocaleString('en-US', {
                                            minimumFractionDigits: 2,
                                            maximumFractionDigits: 2
                                        });
                                    }
                                }
                            }
                        }
                    }
                });
            } else {
                monthChart = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Revenue (Rs.)',
                            data: revenues,
                            backgroundColor: chartColors.secondary,
                            borderColor: chartColors.dark,
                            borderWidth: 2
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: true,
                        scales: {
                            y: {
                                beginAtZero: true,
                                ticks: {
                                    callback: function(value) {
                                        return 'Rs. ' + value.toLocaleString('en-US');
                                    }
                                }
                            }
                        },
                        plugins: {
                            legend: {
                                display: true,
                                position: 'top'
                            },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        return 'Revenue: Rs. ' + context.parsed.y.toLocaleString('en-US', {
                                            minimumFractionDigits: 2,
                                            maximumFractionDigits: 2
                                        });
                                    }
                                }
                            }
                        }
                    }
                });
            }
        }
        
        function switchMonthChart(type) {
            currentMonthChartType = type;
            createMonthChart(type);
            
            // Update button states
            document.getElementById('monthLineBtn').classList.toggle('active', type === 'line');
            document.getElementById('monthBarBtn').classList.toggle('active', type === 'bar');
        }
    </script>
</body>
</html>
