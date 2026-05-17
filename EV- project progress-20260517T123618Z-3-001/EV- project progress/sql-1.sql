select * from ev_vs_petrol_dataset
WHERE country IS NULL OR year IS NULL OR ev_sales IS NULl;
-- remove the space 
update ev_vs_petrol_dataset
SET country = TRIM(country), 
    region = TRIM(region), 
    vehicle_segment = TRIM(vehicle_segment);
    -- (TOTAL EV SALES - TOTAL ICE SALES - AVG EV RANGE - EV MARKET SHARE)
    select * from ev_vs_petrol_dataset;
 select SUM(ev_sales) AS Total_EV_Sales,
SUM(petrol_car_sales + diesel_car_sales) AS Total_ICE_Sales,
AVG(avg_ev_range_km) AS Avg_EV_Range,
(SUM(ev_sales) / SUM(total_vehicle_sales)) * 100 AS EV_Market_Share
FROM ev_vs_petrol_dataset;

select * from ev_vs_petrol_dataset;
-- Year vs CO2 Emissions ( same as pivot tables in our excel sheet )
SELECT year, AVG(co2_emissions_transport_mt) AS Average_of_co2_emissions
FROM ev_vs_petrol_dataset
GROUP BY year
ORDER BY year;

select * from ev_vs_petrol_dataset;
-- total sales by region ( pivot ) 
SELECT region, 
SUM(ev_sales) AS total_ev_sales
FROM ev_vs_petrol_dataset
GROUP BY region
ORDER BY total_ev_sales DESC;


