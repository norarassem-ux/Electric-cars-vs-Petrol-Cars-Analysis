-- Create a dim country
CREATE TABLE Dim_Country (
    country_id INT PRIMARY KEY IDENTITY(1,1),
    country_name VARCHAR(100),
    region VARCHAR(100));

INSERT INTO Dim_Country (country_name, region)
SELECT DISTINCT country, region
FROM raw_data;


-- Create a dim year
CREATE TABLE Dim_Year (
    year_id  INT PRIMARY KEY IDENTITY(1,1),
    year     INT);

INSERT INTO Dim_Year (year)
SELECT DISTINCT year
FROM raw_data
ORDER BY year;

select *
from Dim_Year

-- Create Dim_Vehicle
CREATE TABLE Dim_Vehicle (
    vehicle_id      INT PRIMARY KEY IDENTITY(1,1),
    vehicle_segment VARCHAR(50),
    powertrain_type VARCHAR(20));
 
INSERT INTO Dim_Vehicle (vehicle_segment, powertrain_type)
SELECT DISTINCT vehicle_segment, powertrain_type
FROM raw_data;




-- Create Fact_Vehicle_Sales
-- =============================================
CREATE TABLE Fact_Vehicle_Sales (
    country                       VARCHAR(100),
    country_id                    INT,
    region                        VARCHAR(100),
    year                          INT,
    year_id                       INT,
    vehicle_segment               VARCHAR(50),
    powertrain_type               VARCHAR(20),
    vehicle_id                    INT,
    ev_sales                      INT,
    petrol_car_sales              INT,
    diesel_car_sales              INT,
    total_vehicle_sales           INT,
    ev_market_share               DECIMAL(8,2),
    charging_stations             INT,
    fast_chargers_share           DECIMAL(8,2),
    avg_ev_range_km               INT,
    fuel_price_usd_per_liter      DECIMAL(8,3),
    electricity_price_usd_per_kwh DECIMAL(8,3),
    gdp_per_capita                DECIMAL(8,2),
    urban_population_percent      DECIMAL(8,2),
    co2_emissions_transport_mt    DECIMAL(8,1),
    ev_subsidy_usd                DECIMAL(8,2),
    emission_regulation_score     DECIMAL(8,3),
    ev_growth_rate_yoy            DECIMAL(8,2),
    is_ev_dominant                BIT,
 
    FOREIGN KEY (country_id) REFERENCES Dim_Country(country_id),
    FOREIGN KEY (year_id)    REFERENCES Dim_Year(year_id),
    FOREIGN KEY (vehicle_id) REFERENCES Dim_Vehicle(vehicle_id)
);
 
INSERT INTO Fact_Vehicle_Sales (
    country,
    country_id,
    region,
    year,
    year_id,
    vehicle_segment,
    powertrain_type,
    vehicle_id,
    ev_sales,
    petrol_car_sales,
    diesel_car_sales,
    total_vehicle_sales,
    ev_market_share,
    charging_stations,
    fast_chargers_share,
    avg_ev_range_km,
    fuel_price_usd_per_liter,
    electricity_price_usd_per_kwh,
    gdp_per_capita,
    urban_population_percent,
    co2_emissions_transport_mt,
    ev_subsidy_usd,
    emission_regulation_score,
    ev_growth_rate_yoy,
    is_ev_dominant)
SELECT
    r.country,
    dc.country_id,
    r.region,
    r.year,
    dy.year_id,
    r.vehicle_segment,
    r.powertrain_type,
    dv.vehicle_id,
    r.ev_sales,
    r.petrol_car_sales,
    r.diesel_car_sales,
    r.total_vehicle_sales,
    r.ev_market_share,
    r.charging_stations,
    r.fast_chargers_share,
    r.avg_ev_range_km,
    r.fuel_price_usd_per_liter,
    r.electricity_price_usd_per_kwh,
    r.gdp_per_capita,
    r.urban_population_percent,
    r.co2_emissions_transport_mt,
    r.ev_subsidy_usd,
    r.emission_regulation_score,
    r.ev_growth_rate_yoy,
    r.is_ev_dominant
FROM raw_data r
JOIN Dim_Country dc ON dc.country_name    = r.country
JOIN Dim_Year    dy ON dy.year            = r.year
JOIN Dim_Vehicle dv ON dv.vehicle_segment = r.vehicle_segment
                   AND dv.powertrain_type = r.powertrain_type;








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






 
  









