# 🏨 Hospitality Analytics Dashboard

This project focuses on analyzing hotel booking data to derive meaningful business insights using **Excel** and **Power BI**. It evaluates trends across different time periods, room classes, and booking platforms to help hospitality businesses improve revenue, optimize operations, and reduce cancellations.

## 📊 Project Overview

- **Project Duration:** June 2025 – Present  
- **Tools Used:** Excel, Power BI (SQL and Tableau in progress)  
- **Dataset:** 5 relational tables — `room`, `hotel`, `date`, `bookings`, `aggregated_bookings`  
- **Data Size:** Large-scale dataset simulating real-world hotel chain operations

## 🎯 Business Objectives

1. Analyze total and cancelled bookings
2. Measure and compare occupancy rates
3. Understand revenue trends over time and across segments
4. Segment performance by room class and location
5. Evaluate booking patterns by platform and day type
6. Derive actionable insights to reduce losses and boost profitability

## 📌 Key KPIs Tracked

- ✅ Total Revenue  
- ✅ Total Bookings  
- ✅ Occupancy Rate  
- ✅ Cancellation Rate  
- ✅ Revenue Loss  
- ✅ Class-wise Revenue & Occupancy  
- ✅ Revenue by Hotel and State  
- ✅ Weekday vs Weekend Trends  
- ✅ Booking Status (Cancelled, Checked Out, No Show)  
- ✅ Utilization Capacity  
- ✅ Weekly Trends (Revenue, Bookings, Occupancy)

## 📈 Dashboard Sections

1. **📋 Summary Dashboard**  
   - High-level KPIs: Revenue, Bookings, Occupancy, and Cancellation
   - Booking success and revenue loss overview

2. **📆 Time-Based Analysis**  
   - Weekly trends on key metrics  
   - Monthly booking patterns  
   - Weekday vs Weekend comparison

3. **🏨 Property-Wise Analysis**  
   - Revenue and booking breakdown by city and hotel  
   - Filterable views based on hotel or region

4. **💺 Room Class Analysis**  
   - Revenue and occupancy by class (Elite, Premium, etc.)  
   - Booking trends across business and luxury categories

5. **🌐 Booking Platform Analysis**  
   - Revenue, cancellations, and ratings by platform (e.g., MakeMyTrip, Tripster)  
   - Platform-wise revenue loss insight

## 🔍 Insights Discovered

- **Highest Revenue Source:** Luxury category, especially in Premium & Elite rooms  
- **Major Loss Area:** Bookings made via “Others” platforms show the highest revenue loss  
- **Occupancy Leader:** Elite room class shows the highest occupancy among all segments  
- **Platform Insights:** Direct Online and MakeMyTrip platforms yield high revenue but also carry moderate cancellation rates  
- **Time Trends:** Weekdays consistently outperform weekends in both bookings and revenue

## 🛠️ Ongoing Enhancements

- [ ] Integrating SQL for relational queries and performance  
- [ ] Building Tableau dashboard for advanced visualization  
- [ ] Automating KPI generation using DAX and SQL views

## 📁 Folder Structure (Recommended)

```
Hospitality-Analytics/
│
├── 📊 Dashboards/
│   ├── Summary.png
│   ├── Time_Based_Analysis.png
│   ├── Room_Class_Analysis.png
│   ├── Property_Wise_Analysis.png
│   └── Booking_Platform_Analysis.png
│
├── 📂 Dataset/
│   ├── room.csv
│   ├── hotel.csv
│   ├── date.csv
│   ├── bookings.csv
│   └── aggregated_bookings.csv
│
├── 📂 Documentation/
│   └── Hospitality_Dashboard_README.md
```

## 📌 How to Use

1. Explore Power BI dashboard pages for interactive analysis  
2. Use filters (date, city, booking platform, room class) to drill down into specific segments  
3. Compare trends across weeks or categories for strategy optimization
