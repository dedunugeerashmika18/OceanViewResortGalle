package com.oceanview.servlet;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.model.User;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;


@WebServlet("/manager/revenue-pdf")
public class RevenuePdfServlet extends HttpServlet {
    
    private ReservationDAO reservationDAO;
    private static final DecimalFormat df = new DecimalFormat("#,##0.00");
    
    @Override
    public void init() throws ServletException {
        reservationDAO = new ReservationDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        User currentUser = (User) session.getAttribute("user");
        String userRole = currentUser.getRole();
        if (!"admin".equals(userRole) && !"manager".equals(userRole)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }
        
        // Get date range parameters
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");
        String yearStr = request.getParameter("year");
        
        Date startDate = null;
        Date endDate = null;
        Integer year = null;
        
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat displayDateFormat = new SimpleDateFormat("MMMM dd, yyyy");
        
        try {
            if (startDateStr != null && !startDateStr.trim().isEmpty()) {
                startDate = new Date(dateFormat.parse(startDateStr).getTime());
            }
            if (endDateStr != null && !endDateStr.trim().isEmpty()) {
                endDate = new Date(dateFormat.parse(endDateStr).getTime());
            }
            if (yearStr != null && !yearStr.trim().isEmpty()) {
                year = Integer.parseInt(yearStr);
            }
        } catch (ParseException | NumberFormatException e) {
            // Invalid date format, use defaults
        }
        
        // Get revenue data
        Map<String, Object> stats = reservationDAO.getRevenueStatistics(startDate, endDate);
        List<Map<String, Object>> revenueByRoomType = reservationDAO.getRevenueByRoomType(startDate, endDate);
        List<Map<String, Object>> revenueByMonth = reservationDAO.getRevenueByMonth(year);
        
        // Generate PDF
        try {
            Document document = new Document(PageSize.A4);
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", 
                "attachment; filename=\"Revenue_Report_" + 
                new SimpleDateFormat("yyyyMMdd_HHmmss").format(new java.util.Date()) + ".pdf\"");
            
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();
            
            // Title
            Font titleFont = new Font(Font.FontFamily.HELVETICA, 20, Font.BOLD, BaseColor.DARK_GRAY);
            Paragraph title = new Paragraph("Ocean View Resort - Galle", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            title.setSpacingAfter(5);
            document.add(title);
            
            Font subtitleFont = new Font(Font.FontFamily.HELVETICA, 16, Font.BOLD, new BaseColor(90, 120, 99));
            Paragraph subtitle = new Paragraph("Revenue Analysis Report", subtitleFont);
            subtitle.setAlignment(Element.ALIGN_CENTER);
            subtitle.setSpacingAfter(20);
            document.add(subtitle);
            
            // Date Range
            Font infoFont = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL, BaseColor.GRAY);
            Paragraph dateInfo = new Paragraph();
            if (startDate != null && endDate != null) {
                dateInfo.add(new Chunk("Period: " + displayDateFormat.format(startDate) + 
                    " to " + displayDateFormat.format(endDate), infoFont));
            } else if (year != null) {
                dateInfo.add(new Chunk("Year: " + year, infoFont));
            } else {
                dateInfo.add(new Chunk("Period: All Time", infoFont));
            }
            dateInfo.add(new Chunk("\nGenerated: " + displayDateFormat.format(new java.util.Date()), infoFont));
            dateInfo.setSpacingAfter(15);
            document.add(dateInfo);
            
            // Summary Statistics
            if (stats != null && !stats.isEmpty() && 
                (stats.get("totalReservations") != null && 
                 ((Number) stats.get("totalReservations")).intValue() > 0)) {
                Font sectionFont = new Font(Font.FontFamily.HELVETICA, 14, Font.BOLD, new BaseColor(90, 120, 99));
                Paragraph sectionTitle = new Paragraph("Summary Statistics", sectionFont);
                sectionTitle.setSpacingBefore(10);
                sectionTitle.setSpacingAfter(10);
                document.add(sectionTitle);
                
                PdfPTable statsTable = new PdfPTable(4);
                statsTable.setWidthPercentage(100);
                statsTable.setWidths(new float[]{1, 1, 1, 1});
                
                // Header
                Font headerFont = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD, BaseColor.WHITE);
                PdfPCell headerCell = new PdfPCell(new Phrase("Total Reservations", headerFont));
                headerCell.setBackgroundColor(new BaseColor(90, 120, 99));
                headerCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                headerCell.setPadding(8);
                statsTable.addCell(headerCell);
                
                headerCell = new PdfPCell(new Phrase("Total Revenue", headerFont));
                headerCell.setBackgroundColor(new BaseColor(90, 120, 99));
                headerCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                headerCell.setPadding(8);
                statsTable.addCell(headerCell);
                
                headerCell = new PdfPCell(new Phrase("Average Revenue", headerFont));
                headerCell.setBackgroundColor(new BaseColor(90, 120, 99));
                headerCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                headerCell.setPadding(8);
                statsTable.addCell(headerCell);
                
                headerCell = new PdfPCell(new Phrase("Total Nights", headerFont));
                headerCell.setBackgroundColor(new BaseColor(90, 120, 99));
                headerCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                headerCell.setPadding(8);
                statsTable.addCell(headerCell);
                
                // Data
                Font dataFont = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL, BaseColor.BLACK);
                PdfPCell dataCell = new PdfPCell(new Phrase(
                    stats.get("totalReservations") != null ? stats.get("totalReservations").toString() : "0", 
                    dataFont));
                dataCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                dataCell.setPadding(8);
                statsTable.addCell(dataCell);
                
                dataCell = new PdfPCell(new Phrase(
                    "Rs. " + (stats.get("totalRevenue") != null ? 
                        df.format(stats.get("totalRevenue")) : "0.00"), 
                    dataFont));
                dataCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                dataCell.setPadding(8);
                statsTable.addCell(dataCell);
                
                dataCell = new PdfPCell(new Phrase(
                    "Rs. " + (stats.get("averageRevenue") != null ? 
                        df.format(stats.get("averageRevenue")) : "0.00"), 
                    dataFont));
                dataCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                dataCell.setPadding(8);
                statsTable.addCell(dataCell);
                
                dataCell = new PdfPCell(new Phrase(
                    stats.get("totalNights") != null ? stats.get("totalNights").toString() : "0", 
                    dataFont));
                dataCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                dataCell.setPadding(8);
                statsTable.addCell(dataCell);
                
                document.add(statsTable);
                document.add(new Paragraph(" ")); // Spacing
            }
            
            // Revenue by Room Type
            if (revenueByRoomType != null && !revenueByRoomType.isEmpty() && revenueByRoomType.size() > 0) {
                Font sectionFont = new Font(Font.FontFamily.HELVETICA, 14, Font.BOLD, new BaseColor(90, 120, 99));
                Paragraph sectionTitle = new Paragraph("Revenue by Room Type", sectionFont);
                sectionTitle.setSpacingBefore(10);
                sectionTitle.setSpacingAfter(10);
                document.add(sectionTitle);
                
                PdfPTable roomTypeTable = new PdfPTable(5);
                roomTypeTable.setWidthPercentage(100);
                roomTypeTable.setWidths(new float[]{2f, 1f, 1.5f, 1.5f, 1f});
                
                // Header
                Font headerFont = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD, BaseColor.WHITE);
                String[] headers = {"Room Type", "Reservations", "Total Revenue", "Average Revenue", "Total Nights"};
                for (String header : headers) {
                    PdfPCell headerCell = new PdfPCell(new Phrase(header, headerFont));
                    headerCell.setBackgroundColor(new BaseColor(90, 120, 99));
                    headerCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                    headerCell.setPadding(8);
                    roomTypeTable.addCell(headerCell);
                }
                
                // Data rows
                Font dataFont = new Font(Font.FontFamily.HELVETICA, 9, Font.NORMAL, BaseColor.BLACK);
                for (Map<String, Object> revenue : revenueByRoomType) {
                    PdfPCell cell = new PdfPCell(new Phrase(
                        revenue.get("roomType") != null ? revenue.get("roomType").toString() : "", 
                        dataFont));
                    cell.setPadding(6);
                    roomTypeTable.addCell(cell);
                    
                    cell = new PdfPCell(new Phrase(
                        revenue.get("reservationCount") != null ? revenue.get("reservationCount").toString() : "0", 
                        dataFont));
                    cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                    cell.setPadding(6);
                    roomTypeTable.addCell(cell);
                    
                    cell = new PdfPCell(new Phrase(
                        "Rs. " + (revenue.get("totalRevenue") != null ? 
                            df.format(revenue.get("totalRevenue")) : "0.00"), 
                        dataFont));
                    cell.setHorizontalAlignment(Element.ALIGN_RIGHT);
                    cell.setPadding(6);
                    roomTypeTable.addCell(cell);
                    
                    cell = new PdfPCell(new Phrase(
                        "Rs. " + (revenue.get("averageRevenue") != null ? 
                            df.format(revenue.get("averageRevenue")) : "0.00"), 
                        dataFont));
                    cell.setHorizontalAlignment(Element.ALIGN_RIGHT);
                    cell.setPadding(6);
                    roomTypeTable.addCell(cell);
                    
                    cell = new PdfPCell(new Phrase(
                        revenue.get("totalNights") != null ? revenue.get("totalNights").toString() : "0", 
                        dataFont));
                    cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                    cell.setPadding(6);
                    roomTypeTable.addCell(cell);
                }
                
                document.add(roomTypeTable);
                document.add(new Paragraph(" ")); // Spacing
            }
            
            // Revenue by Month
            if (revenueByMonth != null && !revenueByMonth.isEmpty() && revenueByMonth.size() > 0) {
                Font sectionFont = new Font(Font.FontFamily.HELVETICA, 14, Font.BOLD, new BaseColor(90, 120, 99));
                Paragraph sectionTitle = new Paragraph("Revenue by Month", sectionFont);
                sectionTitle.setSpacingBefore(10);
                sectionTitle.setSpacingAfter(10);
                document.add(sectionTitle);
                
                PdfPTable monthTable = new PdfPTable(3);
                monthTable.setWidthPercentage(100);
                monthTable.setWidths(new float[]{2, 1, 2});
                
                // Header
                Font headerFont = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD, BaseColor.WHITE);
                String[] headers = {"Month", "Reservations", "Total Revenue"};
                for (String header : headers) {
                    PdfPCell headerCell = new PdfPCell(new Phrase(header, headerFont));
                    headerCell.setBackgroundColor(new BaseColor(90, 120, 99));
                    headerCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                    headerCell.setPadding(8);
                    monthTable.addCell(headerCell);
                }
                
                // Data rows
                Font dataFont = new Font(Font.FontFamily.HELVETICA, 9, Font.NORMAL, BaseColor.BLACK);
                String[] monthNames = {"", "January", "February", "March", "April", "May", "June", 
                                       "July", "August", "September", "October", "November", "December"};
                for (Map<String, Object> revenue : revenueByMonth) {
                    int month = (Integer) revenue.get("month");
                    String monthKey = monthNames[month] + " " + revenue.get("year");
                    
                    PdfPCell cell = new PdfPCell(new Phrase(monthKey, dataFont));
                    cell.setPadding(6);
                    monthTable.addCell(cell);
                    
                    cell = new PdfPCell(new Phrase(
                        revenue.get("reservationCount") != null ? revenue.get("reservationCount").toString() : "0", 
                        dataFont));
                    cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                    cell.setPadding(6);
                    monthTable.addCell(cell);
                    
                    cell = new PdfPCell(new Phrase(
                        "Rs. " + (revenue.get("totalRevenue") != null ? 
                            df.format(revenue.get("totalRevenue")) : "0.00"), 
                        dataFont));
                    cell.setHorizontalAlignment(Element.ALIGN_RIGHT);
                    cell.setPadding(6);
                    monthTable.addCell(cell);
                }
                
                document.add(monthTable);
            }
            
            // No data message
            if ((stats == null || stats.isEmpty() || 
                 stats.get("totalReservations") == null || 
                 ((Number) stats.get("totalReservations")).intValue() == 0) &&
                (revenueByRoomType == null || revenueByRoomType.isEmpty()) &&
                (revenueByMonth == null || revenueByMonth.isEmpty())) {
                Font noDataFont = new Font(Font.FontFamily.HELVETICA, 12, Font.ITALIC, BaseColor.GRAY);
                Paragraph noData = new Paragraph("No revenue data available for the selected period.", noDataFont);
                noData.setAlignment(Element.ALIGN_CENTER);
                noData.setSpacingBefore(20);
                document.add(noData);
            }
            
            // Footer
            document.add(new Paragraph(" "));
            Font footerFont = new Font(Font.FontFamily.HELVETICA, 8, Font.ITALIC, BaseColor.GRAY);
            Paragraph footer = new Paragraph(
                ".",
                footerFont);
            footer.setAlignment(Element.ALIGN_CENTER);
            document.add(footer);
            
            document.close();
            
        } catch (DocumentException e) {
            throw new ServletException("Error generating PDF", e);
        }
    }
}
