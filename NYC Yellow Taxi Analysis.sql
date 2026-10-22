SELECT count(*) FROM fact_yellow_trip
SELECT count(*) FROM dim_payment_type
SELECT count(*) FROM dim_rate_code
SELECT count(*) FROM dim_store_and_fwd_flag
SELECT count(*) FROM dim_vendor
SELECT count(*) FROM dim_zone

-- ----------------------------------------------------------------------
-- SECTION 1 — BASIC BUSINESS KPIs
-- ----------------------------------------------------------------------
-- Q01. How many valid taxi trip records are in the final fact table?
SELECT COUNT(*) AS Total_Valid_Trips FROM fact_yellow_trip

-- Q02. What is the total recorded revenue, using expected_total as a fallback
--where total_amount is NULL?
SELECT ROUND(SUM(COALESCE(Total_Amount,Expected_Total))::numeric,2) AS Total_Recorded_Revenue 
FROM fact_yellow_trip

-- Q03. What is the average trip amount using total_amount with expected_total as the fallback?
SELECT ROUND(AVG(COALESCE(Total_Amount,Expected_Total))::numeric,2) AS Total_Trip_Amount
FROM fact_yellow_trip

-- Q04. What is the total fare amount?
SElECT ROUND(SUM(Fare_Amount)::numeric,2) AS Total_Fare_Amont FROM fact_yellow_trip

-- Q05. What is the average fare amount per trip?
SElECT ROUND(AVG(Fare_Amount)::numeric,2) AS Average_Fare_Amont FROM fact_yellow_trip

-- Q06. What is the total tip amount?
SELECT ROUND(SUM(Tip_Amount)::numeric,2) AS Total_Tip_Amount FROM fact_yellow_trip

-- Q07. What is the average tip amount per tipped/recorded-tip trip?
SELECT ROUND(AVG(Tip_Amount)::numeric,2) AS Average_Tip_Amount FROM fact_yellow_trip

-- Q08. What is the average trip duration in minutes?
SELECT ROUND(AVG(Trip_Duration_Min)::numeric,2) AS Average_Trip_Duration FROM fact_yellow_trip

-- Q09. What is the average trip distance in miles?
SELECT ROUND(AVG(Trip_Distance)::numeric,2) AS Average_Trip_Distance FROM fact_yellow_trip

-- Q10. What is each vendor's share of total trips?
SELECT v."VendorID", v."Vendor_Names", ROUND(COUNT(*)*100.0/(SELECT COUNT(*)
FROM fact_yellow_trip),2) AS Vendor_Share_P
FROM fact_yellow_trip AS f
LEFT JOIN dim_vendor AS V
ON f."VendorID"=v."VendorID"
GROUP BY 1,2
ORDER BY 3 DESC

-- ----------------------------------------------------------------------
-- SECTION 2 — DEMAND & TIME ANALYSIS
-- ----------------------------------------------------------------------
-- Q11. Which day of the week has the highest number of trips?
SELECT TRIM(TO_CHAR(Tpep_Pickup_Datetime,'Day')) AS Day_Name,COUNT(*) AS Total_Trips
FROM fact_yellow_trip
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

-- Q12. Which pickup hour has the highest number of trips?
SELECT TRIM(TO_CHAR(Tpep_Pickup_Datetime,'HH24')) AS Pickup_Hour,COUNT(*) AS Total_Trips
FROM fact_yellow_trip
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

SELECT EXTRACT(HOUR FROM Tpep_Pickup_Datetime) AS Pickup_Hour,COUNT(*)AS Total_Trips
FROM fact_yellow_trip
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

-- Q13. What is the trip volume for every pickup hour?
SELECT TRIM(TO_CHAR(Tpep_Pickup_Datetime,'HH24')) AS Pickup_Hour,COUNT(*) AS Total_Trips
FROM fact_yellow_trip
GROUP BY 1
ORDER BY 1

SELECT EXTRACT(HOUR FROM Tpep_Pickup_Datetime) AS Pickup_Hour,COUNT(*)AS Total_Trips
FROM fact_yellow_trip
GROUP BY 1
ORDER BY 1

-- Q14. What percentage of trips occur on weekends?

SELECT CASE WHEN TRIM(TO_CHAR(Tpep_Pickup_Datetime,'Day')) IN ('Saturday','Sunday') THEN 'Weekend'
            ELSE 'Weekdays'
		END AS Day_Of_Week,
		COUNT(*) AS Total_Trips,
		ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM fact_yellow_trip),2) AS Trips_Pct
FROM fact_yellow_trip
GROUP BY 1
		
SELECT CASE WHEN EXTRACT (ISODOW FROM Tpep_Pickup_Datetime) IN (6,7) THEN 'Weekend'
            ELSE 'Weekdays'
		END AS Day_Of_Week,
		COUNT(*) AS Total_Trips,
		ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM fact_yellow_trip),2) AS Trips_Pct
FROM fact_yellow_trip
GROUP BY 1

-- Q15. What percentage of trips occur during peak hours (07:00–09:59 and 16:00–18:59)?
SELECT 100*COUNT(*) FILTER(WHERE EXTRACT(HOUR FROM Tpep_Pickup_Datetime) BETWEEN 7 AND 9
OR EXTRACT (HOUR FROM Tpep_Pickup_Datetime) BETWEEN 16 AND 18)/COUNT(*) AS Peak_Hour_Pct
FROM fact_yellow_trip

-- Q16. Which calendar date has the highest number of trips?
SELECT Tpep_Pickup_Datetime::date AS Pickup_Date,COUNT(*) AS Total_Trips
FROM fact_yellow_trip
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

-- Q17. Which calendar date generates the highest total revenue?
SELECT Tpep_Pickup_Datetime::Date AS Pickup_Date,
ROUND(SUM(COALESCE(Total_Amount,Expected_Total))::Numeric,2) AS Total_Revenue
FROM fact_yellow_trip
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

-- Q18. What is the average trip duration by day of the week?
SELECT TRIM(TO_CHAR(Tpep_Pickup_Datetime,'Day')) AS Day_Of_Week,
ROUND(AVG(Trip_Duration_Min)::Numeric,2) AS Average_Trip_Duration
FROM fact_yellow_trip
GROUP BY 1, EXTRACT(ISODOW FROM Tpep_Pickup_Datetime)
ORDER BY EXTRACT(ISODOW FROM Tpep_Pickup_Datetime)

-- Q19. What is the average trip distance by pickup hour?
SELECT TO_CHAR(Tpep_Pickup_Datetime,'HH24') AS Pickup_Hour,
ROUND(AVG(Trip_Distance)::Numeric,2) AS Average_Trip_Distance
FROM fact_yellow_trip
GROUP BY 1
ORDER BY 1

-- Q20. Which pickup hour has the highest average revenue per trip?
SELECT TO_CHAR(Tpep_Pickup_Datetime,'HH24') AS Pickup_Hour,
ROUND(AVG(COALESCE(Total_Amount,Expected_Total))::Numeric,2) AS Average_Revenue
FROM fact_yellow_trip
GROUP BY 1
ORDER BY 2 desc
LIMIT 1

-- ----------------------------------------------------------------------
-- SECTION 3 — LOCATION & ROUTE ANALYSIS
-- ----------------------------------------------------------------------
-- Q21. Which pickup zone has the highest trip volume?
SELECT Z."Zone" AS Pick_Up_Zone,COUNT(*) AS Trip_Volume 
FROM fact_yellow_trip AS F
LEFT JOIN dim_zone AS Z ON Z."LocationID"=F."PULocationID"
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

-- Q22. Which drop-off zone has the highest trip volume?
SELECT Z."Zone" AS Drop_Off_Zone,COUNT(*) AS Trip_Volume 
FROM fact_yellow_trip AS F
LEFT JOIN dim_zone AS Z ON Z."LocationID"=F."DOLocationID"
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

-- Q23. Which pickup borough has the highest trip volume?
SELECT Z."Borough" AS Pick_Up_Borough,COUNT(*) AS Trip_Volume 
FROM fact_yellow_trip AS F
LEFT JOIN dim_zone AS Z ON Z."LocationID"=F."PULocationID"
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

-- Q24. Which drop-off borough has the highest trip volume?
SELECT Z."Borough" AS Drop_Off_Borough,COUNT(*) AS Trip_Volume 
FROM fact_yellow_trip AS F
LEFT JOIN dim_zone AS Z ON Z."LocationID"=F."DOLocationID"
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

-- Q25. What are the top 10 pickup zones by trip volume?
SELECT Z."Zone" AS Top10_Pick_Up_Zone,COUNT(*) AS Trip_Volume 
FROM fact_yellow_trip AS F
LEFT JOIN dim_zone AS Z ON Z."LocationID"=F."PULocationID"
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

-- Q26. What are the top 10 drop-off zones by trip volume?
SELECT Z."Zone" AS Top10_Drop_Off_Zone,COUNT(*) AS Trip_Volume 
FROM fact_yellow_trip AS F
LEFT JOIN dim_zone AS Z ON Z."LocationID"=F."DOLocationID"
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

-- Q27. What is the most frequent pickup-zone to drop-off-zone route?
SELECT PZ."Zone" AS PickUp_Zone,DZ."Zone" AS DropOff_Zone,COUNT(*) AS Trip_Volume 
FROM fact_yellow_trip AS F
LEFT JOIN dim_zone AS PZ ON PZ."LocationID" = F."PULocationID"
LEFT JOIN dim_zone AS DZ ON DZ."LocationID" = F."DOLocationID"
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1

-- Q28. What are the top 10 routes by trip volume?
SELECT PZ."Zone" AS PickUp_Zone,DZ."Zone" AS DropOff_Zone,COUNT(*) AS Trip_Volume 
FROM fact_yellow_trip AS F
LEFT JOIN dim_zone AS PZ ON PZ."LocationID" = F."PULocationID"
LEFT JOIN dim_zone AS DZ ON DZ."LocationID" = F."DOLocationID"
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10

-- Q29. Which pickup zone generates the highest total revenue?
SELECT PZ."Zone" AS PickUp_Zone,
ROUND(SUM(COALESCE(Total_Amount,Expected_Total)::Numeric),2) AS Total_Revenue
FROM fact_yellow_trip AS F
LEFT JOIN dim_zone AS PZ ON PZ."LocationID" = F."PULocationID"
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

-- Q30. Which pickup borough has the highest average trip amount?
SELECT PZ."Borough" AS PickUp_Borough,
ROUND(AVG(COALESCE(Total_Amount,Expected_Total)::Numeric),2) AS Average_Trip_Amount
FROM fact_yellow_trip AS F
LEFT JOIN dim_zone AS PZ ON PZ."LocationID" = F."PULocationID"
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

-- ----------------------------------------------------------------------
-- SECTION 4 — REVENUE, PAYMENT & AIRPORT ANALYSIS
-- ----------------------------------------------------------------------
-- Q31. What is total revenue by payment method?
SELECT PT."Payment_Method",ROUND(SUM(COALESCE(Total_Amount,Expected_Total))::Numeric,2) 
AS Total_Revenue FROM fact_yellow_trip AS F
LEFT JOIN dim_payment_type AS PT
ON PT.Payment_Type = F.Payment_Type
GROUP BY 1

-- Q32. What share of total trips does each payment method represent?
SELECT PT."Payment_Method",COUNT(*) AS Total_Trips
FROM fact_yellow_trip AS F
LEFT JOIN dim_payment_type AS PT
ON PT.Payment_Type = F.Payment_Type
GROUP BY 1

-- Q33. Which payment method has the highest average trip amount?
SELECT PT."Payment_Method",ROUND(AVG(COALESCE(Total_Amount,Expected_Total))::Numeric,2) 
AS Average_Trip_Amount
FROM fact_yellow_trip AS F
LEFT JOIN dim_payment_type AS PT
ON PT.Payment_Type = F.Payment_Type
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

-- Q34. Which payment method generates the highest total tips?
SELECT PT."Payment_Method",COUNT(*) AS Total_Trips
FROM fact_yellow_trip AS F
LEFT JOIN dim_payment_type AS PT
ON PT.Payment_Type = F.Payment_Type
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

-- Q35. What is the overall tip amount as a percentage of total revenue?
SELECT ROUND(SUM(Tip_Amount)::Numeric*100.0/SUM(COALESCE(Total_Amount,Expected_Total)::Numeric),2)
AS Overall_Tip_Amount_Pct_of_Total_Revenue
FROM fact_yellow_trip

-- Q36. What percentage of trips have a recorded tip greater than zero?
SELECT ROUND(100.0*COUNT(*) FILTER(WHERE Tip_Amount>0)/count(*),2) AS Tip_Pct_Greater_Than_Zero
FROM fact_yellow_trip

-- Q37. What percentage of trips have Airport_fee greater than zero?
SELECT ROUND(100.0*COUNT(*) FILTER(WHERE "Airport_fee">0)/count(*),2) 
AS Airport_Fee_Pct_Greater_Than_Zero
FROM fact_yellow_trip

-- Q38. Which rate code has the highest trip volume?
SELECT RC."Rate_Code",COUNT(*) AS Trip_Volume
FROM fact_yellow_trip AS F
LEFT JOIN dim_rate_code AS RC
ON RC."RatecodeID" =F."RatecodeID"
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

-- Q39. What share of trips are associated with airport rate codes (JFK and Newark)?
SELECT ROUND(100.0*(COUNT(*) FILTER(WHERE "RatecodeID" IN (2,3)))/Count(*),2)
AS Airport_Trips_Pct
FROM fact_yellow_trip

-- Q40. What is the total revenue generated by airport-fee trips versus non-airport-fee trips?
SELECT CASE WHEN "Airport_fee">0 THEN 'Airport_Trips'
            ELSE 'Non_Airport_Trips'
		END,
ROUND(SUM(COALESCE(Total_Amount,Expected_Total))::Numeric,2) AS Total_Revenue
FROM fact_yellow_trip
GROUP BY 1

-- ----------------------------------------------------------------------
-- SECTION 5 — TRIP BEHAVIOR & OPERATIONS
-- ----------------------------------------------------------------------
-- Q41. What is the average passenger count by payment method?
SELECT PT."Payment_Method", ROUND(AVG(F.Passenger_Count),2) AS Average_Passenger_Count
FROM fact_yellow_trip AS F
LEFT JOIN dim_payment_type AS PT
ON PT.Payment_Type = F.Payment_Type
GROUP BY 1

-- Q42. Which vendor has the highest average trip distance?
SELECT V."Vendor_Names", ROUND(AVG(Trip_Distance)::Numeric,2) AS Average_Trip_Distance
FROM fact_yellow_trip AS F
LEFT JOIN dim_vendor AS V
ON V."VendorID" = F."VendorID"
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

-- Q43. Which vendor has the highest average trip duration?
SELECT V."Vendor_Names", ROUND(AVG(Trip_Duration_Min)::Numeric,2) AS Average_Trip_Duration
FROM fact_yellow_trip AS F
LEFT JOIN dim_vendor AS V
ON V."VendorID" = F."VendorID"
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

-- Q44. What percentage of trips are store-and-forward trips?
SELECT ROUND(100.0*COUNT(*) FILTER(WHERE store_and_fwd_flag='Y')/COUNT(*),2)
AS Store_And_Fwd_Flag_Trips_Pct
FROM fact_yellow_trip

-- Q45. Which rate code has the highest average fare amount?
SELECT RC."Rate_Code",ROUND(AVG(Fare_Amount)::Numeric,2) AS Average_Fare_Amount
FROM fact_yellow_trip AS F
LEFT JOIN dim_rate_code AS RC
ON RC."RatecodeID" = F."RatecodeID"
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

-- ----------------------------------------------------------------------
-- SECTION 6 — ADVANCED ANALYTICS & MANAGEMENT QUESTIONS
-- ----------------------------------------------------------------------
-- Q46. What are the top 10 pickup zones by total revenue, along with their percentage contribution to total revenue?
SELECT PZ."Zone" AS Top10_Pickup_Zone,
ROUND(SUM(COALESCE(F.Total_Amount,F.Expected_Total))::Numeric,2) AS Total_Revenue,
ROUND(100.0*SUM(COALESCE(F.Total_Amount,F.Expected_Total))::Numeric/
(SELECT SUM(COALESCE(Total_Amount,Expected_Total)::Numeric) FROM fact_yellow_trip),2)
AS Revenue_Pct
FROM fact_yellow_trip AS F
LEFT JOIN dim_zone AS PZ
ON PZ."LocationID" = F."PULocationID"
GROUP BY 1
ORDER BY 2 DESC,3 DESC
LIMIT 10

-- Q47. For each pickup borough, what are total trips, total revenue, average trip amount, and revenue share?
SELECT PZ."Borough" AS Pickup_Borough, COUNT(*) AS Total_Trips,
ROUND(SUM(COALESCE(F.Total_Amount,F.Expected_Total))::Numeric,2) AS Total_Revenue,
ROUND(AVG(COALESCE(F.Total_Amount,F.Expected_Total))::Numeric,2) AS Average_Trip_Amount,
ROUND(100.0*SUM(COALESCE(F.Total_Amount,F.Expected_Total))::Numeric/
(SELECT SUM(COALESCE(Total_Amount,Expected_Total)::Numeric) FROM fact_yellow_trip),2)
AS Revenue_Share
FROM fact_yellow_trip AS F
LEFT JOIN dim_zone AS PZ
ON PZ."LocationID" = F."PULocationID"
GROUP BY 1

-- Q48. What are the top 10 routes by total revenue, and what is their average trip duration?
SELECT PZ."Zone" AS Pickup_Zone,DZ."Zone" AS Dropoff_Zone,
ROUND(SUM(COALESCE(F.Total_Amount,F.Expected_Total))::Numeric,2) AS Total_Revenue,
ROUND(AVG(Trip_Duration_Min)::Numeric,2) AS Average_Trip_Duration
FROM fact_yellow_trip AS F
LEFT JOIN dim_zone AS PZ
ON PZ."LocationID" = F."PULocationID"
LEFT JOIN dim_zone AS DZ
ON DZ."LocationID" = F."DOLocationID"
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10

-- Q49. For each pickup hour, calculate trips, total revenue, average trip amount, and revenue per kilometer.
SELECT TO_CHAR(Tpep_Pickup_Datetime,'HH24') AS Pickup_Hour,
COUNT(*) AS Total_Trips,
ROUND(SUM(COALESCE(Total_Amount,Expected_Total))::Numeric,2) AS Total_Revenue,
ROUND(AVG(COALESCE(Total_Amount,Expected_Total))::Numeric,2) AS Average_Trip_Amount,
ROUND(SUM(COALESCE(Total_Amount,Expected_Total))::Numeric/SUM(Trip_Distance_Km)::Numeric,2)
AS Revenue_Per_Km
FROM fact_yellow_trip
GROUP BY 1

-- Q50. Within each pickup borough, rank the top 3 pickup zones by trip volume using a window function.
SELECT * FROM (SELECT PZ."Borough" AS Pickup_Borough,PZ."Zone" AS Pickup_Zone, COUNT(*) AS Total_Trips,
RANK()OVER(PARTITION BY PZ."Borough" ORDER BY COUNT(*) DESC) AS Zone_Rank
FROM fact_yellow_trip AS F
LEFT JOIN dim_zone AS PZ
ON PZ."LocationID" = F."PULocationID"
GROUP BY 1,2) AS Ranked
WHERE Zone_Rank <=3
ORDER BY Pickup_Borough, Zone_Rank


