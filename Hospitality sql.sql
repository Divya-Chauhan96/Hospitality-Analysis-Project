create database hospitality;
use hospitality;
select * from bookings;
drop table date;
select count(*) from bookings;

create table bookings(
booking_id text , property_id int , booking_date varchar (100) , check_in_date varchar(100), checkout_date varchar(100) , no_guests int , room_category varchar(100) , 
booking_platform varchar(100) , ratings_given float , booking_status varchar(100) , revenue_generated int , revenue_realized int );

SHOW VARIABLES LIKE 'secure_file_priv';
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 'ON';  

LOAD DATA INFILE "C:/Divya/D.A/PROJECT/Hospitality Project/Hospitality Data/fact_bookings.csv"
INTO TABLE bookings
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
booking_id, property_id, booking_date, check_in_date, checkout_date, @no_guests, room_category, booking_platform, @ratings_given, booking_status, @revenue_generated, @revenue_realized
)
SET 
  no_guests = NULLIF(@no_guests, ''),
  ratings_given = NULLIF(@ratings_given, ''),
  revenue_generated = NULLIF(@revenue_generated, ''),
  revenue_realized = NULLIF(@revenue_realized, '');
  
# TOTAL REVENUE 

SELECT SUM(REVENUE_REALIZED) AS TOTAL_REVENUE FROM BOOKINGS;
SELECT ROUND(SUM(REVENUE_REALIZED)/1000000,2) AS TOTAL_REVENUE_IN_MILLIONS FROM BOOKINGS;   # TO CONVERT IN MILLIONS 
SELECT CONCAT(ROUND(SUM(REVENUE_REALIZED)/1000000,2),' M') AS TOTAL_REVENUE_IN_MILLIONS FROM BOOKINGS;   # FOR DISPLAY UNIT 'M'
# TOTAL BOOKINGS 

SELECT COUNT(BOOKING_ID) AS TOTAL_BOOKINGS FROM BOOKINGS;
SELECT CONCAT(ROUND(COUNT(BOOKING_ID)/1000,2),' K') AS TOTAL_BOOKINGS FROM BOOKINGS;    # TO CONVERT IN THOUSANDS

# OCCUPANCY = SUCCESFUL BOOKINGS , OCCUPANCY_RATE = SUCCESFUL BOOKINGS / CAPACITY 

SELECT CONCAT((SUM( SUCCESSFUL_BOOKINGS)/SUM(CAPACITY))*100,' %') AS OCCUPANCY_RATE FROM AGGREGATED_BOOKINGS;

# CANCELLED BOOKINGS  

SELECT COUNT(*) AS CANCELLED_BOOKINGS FROM BOOKINGS 
WHERE BOOKING_STATUS = "cANCELLED";

# CANCELLATION  RATE [ USING SUBQUERY ] 

SELECT CONCAT((CANCELLED_BOOKINGS/TOTAL_BOOKINGS)*100,' %') AS CAMCELLATION_RATE FROM 
(sELECT COUNT(*) AS TOTAL_BOOKINGS FROM BOOKINGS) AS TOTAL_BOOKINGS ,
(SELECT COUNT(*) AS CANCELLED_BOOKINGS FROM BOOKINGS WHERE BOOKING_STATUS='CANCELLED')  AS CANCELLED_BOOKINGS;

# REVENUE LOSS 

SELECT CONCAT(ROUND((SUM(REVENUE_GENERATED) - SUM(REVENUE_REALIZED))/1000000,2),' M') AS REVENUE_LOSS FROM BOOKINGS;

-- ------------------------------------------------------- CREATE VIEW FOR KPI CARDS ------------------------------------------------------------------------------------

CREATE VIEW KPI_CARDS AS
SELECT CONCAT(ROUND((SELECT SUM(REVENUE_REALIZED) FROM BOOKINGS )/1000000,2),' M') AS TOTAL_REVENUE,
       CONCAT(ROUND(((SELECT SUM(REVENUE_GENERATED) FROM BOOKINGS)-(SELECT SUM(REVENUE_REALIZED) FROM BOOKINGS))/1000000,2),' M') AS REVENUE_LOSS,
       CONCAT(ROUND((SELECT COUNT(BOOKING_ID) FROM BOOKINGS)/1000,2),' K') AS TOTAL_BOOKINGS,
       CONCAT(ROUND(((SELECT SUM(SUCCESSFUL_BOOKINGS) FROM AGGREGATED_BOOKINGS )/(SELECT SUM(CAPACITY) FROM AGGREGATED_BOOKINGS ))*100,2) ," %" ) AS OCCUPANCY_RATE ,
      CONCAT(ROUND(((SELECT COUNT(*) FROM BOOKINGS WHERE BOOKING_STATUS='CANCELLED')/(SELECT COUNT(*) FROM BOOKINGS))*100 ,2),' %') AS CANCELLATION_RATE 
     ;
SELECT * FROM KPI_CARDS;

-- --------------------------------------------------WEEKDAY VS WEEKEND [TOTAL BOOKING & TOTAL REVENUE ]---------------------------------------------------------------------------------------------

SELECT D.DAY_TYPE , CONCAT(ROUND(COUNT(B.BOOKING_ID)/1000,4),' K') AS TOTAL_BOOKINGS ,
					CONCAT(ROUND(SUM(B.REVENUE_REALIZED)/1000000,4),' M') AS TOTAL_REVENUE FROM DATE D 
JOIN BOOKINGS B ON STR_TO_DATE(B.CHECK_IN_DATE, '%Y-%m-%D')= str_to_date(D.DATE , '%Y-%M-%D') # STR_TO_DATE[BECAUSE WHILE LOADING DATA WE CONVERTED DATE COLUMNS TO STRING]  
GROUP BY D.DAY_TYPE 
ORDER BY TOTAL_BOOKINGS DESC , TOTAL_REVENUE DESC ; 

-- -------------------------------------------------CITY & HOTEL [ TOTAL REVENUE & TOTAL BOOKINGS]-----------------------------------------------------------------------

SELECT H.CITY ,H.PROPERTY_NAME AS HOTEL ,CONCAT(ROUND(COUNT(B.BOOKING_ID)/1000,4),' K') AS TOTAL_BOOKINGS ,
CONCAT(ROUND( SUM(B.REVENUE_REALIZED)/1000000,4),' M') AS TOTAL_REVENUE  FROM HOTELS H 
JOIN BOOKINGS B ON B.PROPERTY_ID=H.PROPERTY_ID
GROUP BY CITY , PROPERTY_NAME 
ORDER BY CITY , PROPERTY_NAME ;

-- -------------------------------------------------CITY WISE REVENUE,REVENUE LOSS & BOOKINGS , CANCELLED BOOKINGS---------------------------------------------------------------------------------------

SELECT H.CITY AS CITY , CONCAT(ROUND(COUNT(B. BOOKING_ID)/1000,4),' K') AS BOOKINGS ,
                        SUM(CASE WHEN b.BOOKING_STATUS='Cancelled' then 1 else 0 end ) as CANCELLED_BOOKINGS , 
						CONCAT(ROUND(SUM(B.REVENUE_REALIZED)/1000000,4),' M') AS REVENUE ,
                        CONCAT(ROUND((SUM(B.REVENUE_GENERATED)-SUM(B.REVENUE_REALIZED))/1000000,4),' M') AS REVENUE_LOSS FROM HOTELS h 
JOIN BOOKINGS B ON B.PROPERTY_ID = H.PROPERTY_ID 
GROUP BY CITY
ORDER BY REVENUE DESC , BOOKINGS DESC;

-- ------------------------------------------------PROPERTY WISE REVENUE , REVENUE LOSS , BOOKINGS , CANCELLED BOOKINGS --------------------------------------------------

SELECT H.PROPERTY_NAME AS HOTEL , CONCAT(ROUND(COUNT(B. BOOKING_ID)/1000,4),' K') AS BOOKINGS ,
                        SUM(CASE WHEN b.BOOKING_STATUS='Cancelled' then 1 else 0 end ) as CANCELLED_BOOKINGS , 
						CONCAT(ROUND(SUM(B.REVENUE_REALIZED)/1000000,4),' M') AS REVENUE ,
                        CONCAT(ROUND((SUM(B.REVENUE_GENERATED)-SUM(B.REVENUE_REALIZED))/1000000,4),' M') AS REVENUE_LOSS FROM HOTELS h 
JOIN BOOKINGS B ON B.PROPERTY_ID = H.PROPERTY_ID 
GROUP BY HOTEL
ORDER BY REVENUE DESC , BOOKINGS DESC;

-- ----------------------------------------------------STORED PROCEDURE [ DATE FILTER ] -------------------------------------------------------------------------------

DELIMITER //
CREATE PROCEDURE DATE_FILTER(IN GIVEN_DATE DATE)
BEGIN
  IF EXISTS (
    SELECT 1 FROM BOOKINGS WHERE STR_TO_DATE(CHECK_IN_DATE,'%Y-%m-%D')=GIVEN_DATE
  ) THEN
    -- Run the actual filtered query
    SELECT 
      H.PROPERTY_NAME AS HOTEL,
      CONCAT(ROUND(COUNT(B.BOOKING_ID) / 1000, 4), ' K') AS BOOKINGS,
      SUM(CASE WHEN B.BOOKING_STATUS = 'Cancelled' THEN 1 ELSE 0 END) AS CANCELLED_BOOKINGS,
      CONCAT(ROUND(SUM(B.REVENUE_REALIZED) / 1000000, 4), ' M') AS REVENUE,
      CONCAT(ROUND((SUM(B.REVENUE_GENERATED) - SUM(B.REVENUE_REALIZED)) / 1000000, 4), ' M') AS REVENUE_LOSS
    FROM HOTELS H
    JOIN BOOKINGS B ON B.PROPERTY_ID = H.PROPERTY_ID
    WHERE STR_TO_DATE(B.CHECK_IN_DATE,'%Y-%m-%D')=GIVEN_DATE
    GROUP BY HOTEL
    ORDER BY REVENUE DESC, BOOKINGS DESC;
    
  ELSE
    -- Return default message row if no match
    SELECT 
      'No Match Found' AS HOTEL,
      '0 K' AS BOOKINGS,
      '0 K' AS CANCELLED_BOOKINGS,
      '0 M' AS REVENUE,
      '0 M' AS REVENUE_LOSS;
  END IF;
END //
DELIMITER ;

CALL DATE_FILTER ('2022-06-01') ;

-- -----------------------------------------------------------stored procedure [ booking_platform filter ]--------------------------------------------------------------

CREATE INDEX index_property_id_bookings ON BOOKINGS(PROPERTY_ID);
CREATE INDEX idx_property_id_hotels ON HOTELS(PROPERTY_ID);
CREATE INDEX idx_property_id_agg ON AGGREGATED_BOOKINGS(PROPERTY_ID);
create index index_city on hotels(city(50));
create index index_property_name on hotels(property_name(100));
create index index_booking_platform on bookings(booking_platform(100));
explain

delimiter //
create procedure City_filter (in given_city varchar(100))
begin
if exists ( select 1 from bookings b 
           join hotels h on b.property_id=h.property_id
           where h.city=given_city)
then
SELECT H.CITY AS CITY ,B.BOOKING_PLATFORM AS BOOKING_PLATFORM , H.PROPERTY_NAME AS HOTEL_NAME ,
       CONCAT(ROUND(SUM(B.REVENUE_REALIZED)/1000000,4),' M') AS REVENUE , 
       CONCAT(ROUND((SUM(B.REVENUE_GENERated)-sum(B.revenue_realized))/1000000,4),' M') AS REVENUE_LOSS ,
       CONCAT(ROUND(COUNT(B.BOOKING_ID)/1000,4),' K') AS BOOKINGS , 
       SUM(CASE WHEN B.BOOKING_STATUS='Cancelled' then 1 else 0  end ) as CANCELLED_BOOKINGS ,
       SUM(AB.CAPACITY) AS CAPACITY 
       FROM HOTELS h
JOIN BOOKINGS B ON B.PROPERTY_ID=H.PROPERTY_ID
JOIN AGGREGATED_BOOKINGS AB ON AB.PROPERTY_ID=B.PROPERTY_ID
where h.city=given_city
GROUP BY city , BOOKING_PLATFORM , HOTEL_NAME
ORDER BY REVENUE DESC, bOOKINGS DESC 
;
else 
select 'no match' as city , ' ' as booking_platform , ' ' as hotel_name, ' ' as revenue, ' ' as revenue_loss, ' ' as bookings , ' ' as cancelled_bookings ,' ' as capacity;
end if;
end //
delimiter ;

call city_filter('Delhi');
  




SELECT * FROM DATE ;
SELECT * FROM BOOKINGS;
SELECT * FROM hotels;


