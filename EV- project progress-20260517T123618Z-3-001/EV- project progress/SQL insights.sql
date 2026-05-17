
use Ev_car

--a)   Sales insights

--Total EV sales per year
--sales over years from 2010 to 2025
SELECT year, 
SUM(ev_sales) AS total_ev_sales
FROM Fact_Vehicle_Sales
GROUP BY year
ORDER BY year;
 
 
--Total EV sales per region
-- APAC region leading EV Sales
SELECT region, 
SUM(ev_sales) AS total_ev_sales
FROM Fact_Vehicle_Sales
GROUP BY region
ORDER BY total_ev_sales DESC;
 
--Top 10 countries by EV sales
--china has the most EV sales by far from any country
SELECT TOP 10 country, 
SUM(ev_sales) AS total_ev_sales
FROM Fact_Vehicle_Sales
GROUP BY country
ORDER BY total_ev_sales DESC;

--EV sales vs Petrol sales per year
--over years the EV spread 
SELECT
    year,
    SUM(ev_sales) AS total_ev_sales,
    SUM(petrol_car_sales) AS total_petrol_sales,
    SUM(diesel_car_sales) AS total_diesel_sales
FROM Fact_Vehicle_Sales
GROUP BY year
ORDER BY year;



--b) Market_Share insights


 
--Average EV market share per country
--Norway leading the country that has avg_market share over other countries

SELECT country, 
AVG(ev_market_share) AS avg_ev_share
FROM Fact_Vehicle_Sales
GROUP BY country
ORDER BY avg_ev_share DESC;


--EV market share per region over years

SELECT
    region,
    year,
    AVG(ev_market_share) AS avg_ev_share_pct
FROM Fact_Vehicle_Sales
GROUP BY region, year
ORDER BY region, year;



--EV market share per vehicle segment
-- Premium segment leads EV cars over mass market
SELECT
    vehicle_segment,
    powertrain_type,
    AVG(ev_market_share) AS avg_ev_share_pct,
    SUM(ev_sales)  AS total_ev_sales
FROM Fact_Vehicle_Sales
GROUP BY vehicle_segment, powertrain_type
ORDER BY vehicle_segment, powertrain_type;



-- c) Infrastructure Affect on EV cars Sales

 
--Charging stations growth per year
SELECT
    year,
    SUM(charging_stations) AS total_charging_stations,
    AVG(fast_chargers_share) AS avg_fast_charger_pct,
    SUM(ev_sales) AS total_ev_sales
FROM Fact_Vehicle_Sales
GROUP BY year
ORDER BY year;
 
 
--Top 10 countries with most charging stations in 2025
SELECT TOP 10
    country,
    SUM(charging_stations) AS total_chargers,
    ROUND(AVG(fast_chargers_share), 2) AS avg_fast_charger_pct
FROM Fact_Vehicle_Sales
WHERE year = 2025
GROUP BY country
ORDER BY total_chargers DESC;
 
 
-- Average EV range improvement per year
-- The driving range of EV cars has imporved  between 2010 and 2025.
SELECT
    year,
    ROUND(AVG(avg_ev_range_km), 0) AS avg_range_km
FROM Fact_Vehicle_Sales
GROUP BY year
ORDER BY year;


-- d) Factors that affect EV Spread ( we need frist to calculate the correlation between factors and market_share)
 
 --fuel price vs EV cars Spread(corrolation)
 SELECT
    (AVG(fuel_price_usd_per_liter * ev_market_share)
    - AVG(fuel_price_usd_per_liter) * AVG(ev_market_share))
    /
    (STDEV(fuel_price_usd_per_liter) * STDEV(ev_market_share))
    AS correlation
FROM Fact_Vehicle_Sales;

--fuel price vs EV cars Spread(correlation= 0.55)
--more fuel price lead people to shift to EV cars (strong relation)

SELECT
    country,
    AVG(fuel_price_usd_per_liter) AS avg_fuel_price,
    AVG(ev_market_share)AS avg_ev_share_pct
FROM Fact_Vehicle_Sales
GROUP BY country
ORDER BY avg_fuel_price DESC;
 
 
--emission regulations (correlation)
SELECT
    (AVG(emission_regulation_score * ev_market_share)
    - AVG(emission_regulation_score) * AVG(ev_market_share))
    /
    (STDEV(emission_regulation_score) * STDEV(ev_market_share))
    AS correlation_regulation_vs_ev_share
FROM Fact_Vehicle_Sales;



--emission regulations factor (correlation = 0.586)
-- more regulation leads people to shift to EV cars(strong relation)
SELECT
    country,
    AVG(emission_regulation_score) AS avg_regulation_score,
    AVG(ev_market_share) AS avg_ev_share_pct
FROM Fact_Vehicle_Sales
GROUP BY country
ORDER BY avg_regulation_score DESC;
 
 --GDP (correlation)
 SELECT
    (AVG(gdp_per_capita * ev_market_share)
    - AVG(gdp_per_capita) * AVG(ev_market_share))
    /
    (STDEV(gdp_per_capita) * STDEV(ev_market_share))
    AS correlation_gdp_vs_ev_share
FROM Fact_Vehicle_Sales;




--GDP factor (correlation = 0.41)
-- more GDP more EV car sales (meduim relation)
SELECT
    country,
    AVG(gdp_per_capita) AS avg_gdp,
    AVG(ev_market_share) AS avg_ev_share_pct
FROM Fact_Vehicle_Sales
GROUP BY country
ORDER BY avg_gdp DESC;
 
 --EV subsidy correlation
 SELECT
    (AVG(ev_subsidy_usd * ev_market_share)
    - AVG(ev_subsidy_usd) * AVG(ev_market_share))
    /
    (STDEV(ev_subsidy_usd) * STDEV(ev_market_share))
    AS correlation_subsidy_vs_ev_share
FROM Fact_Vehicle_Sales;

--EV subsidy affect  on Ev Spread (Correlation=-0.05)
-- no relation betwenn High subsidy countries and  EV spread (no relation)
SELECT
    country,
    AVG(ev_subsidy_usd)  AS avg_subsidy_usd,
    AVG(ev_market_share) AS avg_ev_share_pct
FROM Fact_Vehicle_Sales
GROUP BY country





-- e) co2 emission insights

--CO2 emissions vs EV cars over years
SELECT
    year,
    SUM(ev_sales) AS total_ev_sales,
    AVG(ev_market_share) AS avg_ev_share_pct,
    AVG(co2_emissions_transport_mt) AS avg_co2_mt
FROM Fact_Vehicle_Sales
GROUP BY year
ORDER BY year;


--top 10  CO2 emission countries in 2025
-- USA, China, India still top emitters despite EV growth
SELECT TOP 10
    country,
    region,
    AVG(co2_emissions_transport_mt) AS avg_co2_mt,
    AVG(ev_market_share) AS avg_ev_share_pct
FROM Fact_Vehicle_Sales
WHERE year = 2025
GROUP BY country, region
ORDER BY avg_co2_mt DESC;



-- f) EV growth rate insights
 
--growth rate in 2025
-- India, Brazil, Indonesia are at the top of countries that have high growth rate in 2025
SELECT
    country,
    region,
    AVG(ev_growth_rate_yoy) AS avg_growth_rate_pct
FROM Fact_Vehicle_Sales
WHERE year = 2025
GROUP BY country, region
ORDER BY avg_growth_rate_pct DESC;
 
 
--average EV growth rate per region over years
-- South America  region is in the last in growth rate over years
SELECT
    region,
    year,
    AVG(ev_growth_rate_yoy) AS avg_growth_rate_pct
FROM Fact_Vehicle_Sales
GROUP BY region, year
ORDER BY region, year;



-- g) EV cars dominant over ICE insight
 
--countries where EV over ICE
-- Only Norway, Sweden, China (premium) and Netherlands in 2025
SELECT
    country,
    region,
    year,
    vehicle_segment,
    ev_sales,
    petrol_car_sales,
    diesel_car_sales,
    petrol_car_sales + diesel_car_sales  AS total_ice_sales,
    ev_market_share
FROM Fact_Vehicle_Sales
WHERE is_ev_dominant = 1
ORDER BY year, country;






 
  









