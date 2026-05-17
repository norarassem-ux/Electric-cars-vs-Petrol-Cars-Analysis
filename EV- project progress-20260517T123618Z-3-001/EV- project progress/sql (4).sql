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







