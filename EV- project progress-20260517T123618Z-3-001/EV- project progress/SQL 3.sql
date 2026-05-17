use  project;
create table dim_country ( countryid Int auto_increment primary key,
country varchar(50) null,
region varchar(50) null);

create table dim_date ( yearID int auto_increment primary key,
 year int null);

create table dim_vehicle ( vehicleID INT auto_increment primary key,
vehicle_segment varchar(50) null,
powertrain_type varchar(50)  null);

create table dim_snapshot ( snapshotID int auto_increment primary key, 
countryID int, 
yearID int, 
gdp_per_capita int null, 
urban_population_pct int null, 
co2_emission_mt int null,
fuel_price_usd_per_liter int null,
electricity_price_usd_per_kwh int null,
avg_ev_range_km int null,
ev_subsidy_usd int null,
emission_regulation_score int null,
charging_stations int null,
fast_chargers_share_pct int null,
FOREIGN KEY (countryID) REFERENCES dim_country(countryID),
FOREIGN KEY (yearID) REFERENCES dim_date(yearID));


create table fact_sales ( factID INT auto_increment primary key, 
countryid INT,
yearID INT,
vehicleID INT,
snapshotID INT, 
ev_sales int null,
petrol_sales int null,
diesel_sales int null,
total_vehicle_sales int null,
ev_market_share decimal(12,2),
ev_growth_rate_yoy decimal(12,2),
is_ev_dominant int,
foreign key (countryid) references dim_country(countryid),
foreign key (yearID) references dim_date(yearID),
foreign key (vehicleID) references dim_vehicle(vehicleID),
foreign key (snapshotID) references dim_snapshot(snapshotID));


insert into dim_country ( country, region )
select distinct country, region 
from raw_data; 

insert into dim_country ( country, region )
select distinct country, region 
from raw_data;

insert into dim_date ( year)
select distinct year
from raw_data;

insert into dim_vehicle (vehicle_segment, powertrain_type)
select distinct vehicle_segment, powertrain_type
from raw_data;

INSERT INTO dim_snapshot (
    countryID,
    yearID,
    gdp_per_capita,
    urban_population,
    co2_emission_mt,
    fuel_price_usd_per_liter,
    electricity_price_usd_per_kwh,
    avg_ev_range_km,
    ev_subsidy_usd,
    emission_regulation_score,
    charging_stations,
    fast_chargers_share_pct
)
SELECT 
    dc.countryID,
    dd.yearID,
    MAX(r.gdp_per_capita),
    MAX(r.urban_population_percent),
    MAX(r.co2_emissions_transport_mt),
    MAX(r.fuel_price_usd_per_liter),
    MAX(r.electricity_price_usd_per_kwh),
    MAX(r.avg_ev_range_km),
    MAX(r.ev_subsidy_usd),
    MAX(r.emission_regulation_score),
    MAX(r.charging_stations),
    MAX(r.fast_chargers_share)
FROM raw_data r
JOIN dim_country dc ON dc.country = r.country
JOIN dim_date dd ON dd.year = r.year
GROUP BY dc.countryID, dd.yearID;

INSERT INTO fact_sales (
    countryID,
    yearID,
    vehicleID,
    snapshotID,
    ev_sales,
    petrol_sales,
    diesel_sales,
    total_vehicle_sales,
    ev_market_share,
    ev_growth_rate_yoy,
    is_ev_dominant
)
SELECT
    dc.countryID,
    dd.yearID,
    dv.vehicleID,
    ds.snapshotID,
    r.ev_sales,
    r.petrol_car_sales,
    r.diesel_car_sales,
    r.total_vehicle_sales,
    r.ev_market_share,
    r.ev_growth_rate_yoy,
    r.is_ev_dominant
FROM raw_data r
JOIN dim_country  dc ON dc.country = r.country
JOIN dim_date     dd ON dd.year  = r.year
JOIN dim_vehicle  dv ON dv.vehicle_segment = r.vehicle_segment
AND dv.powertrain_type  = r.powertrain_type
JOIN dim_snapshot ds ON ds.countryID = dc.countryID
and ds.yearID  = dd.yearID;



-- sales over years (up or down? up)
SELECT 
    d.year AS Sales_Year,
    SUM(f.ev_sales) AS Total_EV_Sales,
    AVG(f.ev_market_share) AS Avg_Market_Share,
    SUM(f.total_vehicle_sales) AS Total_Market_Volume
FROM fact_sales f
JOIN dim_date d ON f.yearID = d.yearID
GROUP BY d.year
ORDER BY d.year;

-- CO2 emission goes up or down with the growth of EV sales? you will recognize that when
-- sales went up (a lot ) in 2018 the co2 emissions started to be less.
SELECT 
    d.year AS Year,
    SUM(f.ev_sales) AS Global_EV_Sales,
    SUM(s.co2_emission_mt) AS Total_CO2_Emissions
FROM fact_sales f
JOIN dim_date d ON f.yearID = d.yearID
JOIN dim_snapshot s ON f.snapshotID = s.snapshotID
GROUP BY d.year
ORDER BY d.year;

-- which segment has more EV ? MASS market 
SELECT 
    v.vehicle_segment,
    SUM(f.ev_sales) AS Total_EV_Sales,
    ROUND(AVG(f.ev_market_share), 2) AS Avg_Market_Share_Pct
FROM fact_sales f
JOIN dim_vehicle v ON f.vehicleID = v.vehicleID
GROUP BY v.vehicle_segment
ORDER BY Total_EV_Sales DESC;

-- then which cont has more AVG EV SALES? europe
SELECT 
    c.region, 
    SUM(f.ev_sales) AS Total_EV_Sales,
    ROUND(AVG(f.ev_market_share), 2) AS Global_Market_Share_Avg
FROM fact_sales f
JOIN dim_country c ON f.countryID = c.countryID
GROUP BY c.region
ORDER BY global_market_share_avg DESC;

-- which country has more ev sales? norway >> sweden >> netherlands
SELECT 
    c.country,
    c.region,
    SUM(f.ev_sales) AS Total_EV_Sales,
    ROUND(AVG(f.ev_market_share), 2) AS Avg_Market_Share_Pct
FROM fact_sales f
JOIN dim_country c ON f.countryID = c.countryID
GROUP BY c.country, c.region
ORDER BY avg_market_share_pct DESC
LIMIT 10;

-- more rich more ev? it can be but not a must and USA is the significant 
SELECT 
    c.country,
    ROUND(AVG(s.gdp_per_capita), 0) AS Avg_Income,
    ROUND(AVG(f.ev_market_share), 2) AS Avg_EV_Share_Pct
FROM fact_sales f
JOIN dim_country c ON f.countryID = c.countryID
JOIN dim_snapshot s ON f.snapshotID = s.snapshotID
GROUP BY c.country
ORDER BY Avg_Income DESC; 

-- then regulation or the susbidy affects more to have more ev ? regulation usa and norway 
SELECT 
    c.country,
    AVG(s.emission_regulation_score) AS Policy_Strength, 
    AVG(s.ev_subsidy_usd) AS Gov_Financial_Support,     
    ROUND(AVG(f.ev_market_share), 2) AS Avg_EV_Share_Pct
FROM fact_sales f
JOIN dim_country c ON f.countryID = c.countryID
JOIN dim_snapshot s ON f.snapshotID = s.snapshotID
GROUP BY c.country
ORDER BY Policy_Strength DESC; 

-- charging stations and Infrastructure can push people to get ev car?
-- it can affect as shown in south USA the stations are few so the evs are few, but still in europe is not the core reason.
 
SELECT 
    c.region, 
    c.country,
    SUM(s.charging_stations) AS Total_Stations,
    AVG(s.fast_chargers_share_pct) AS Fast_Charging_Ratio,
    ROUND(AVG(f.ev_market_share), 2) AS Avg_EV_Share_Pct
FROM fact_sales f
JOIN dim_country c ON f.countryID = c.countryID
JOIN dim_snapshot s ON f.snapshotID = s.snapshotID
GROUP BY c.region, c.country
ORDER BY Total_Stations DESC;


ALTER TABLE dim_snapshot 
MODIFY COLUMN fuel_price_usd_per_liter DECIMAL(12, 2),
MODIFY COLUMN electricity_price_usd_per_kwh DECIMAL(12, 2);

-- price of petrol and electricity can affect or not? yes
SELECT 
    c.country,
    c.region,
    SUM(f.ev_sales) AS Total_EV_Sales,
    ROUND(AVG(f.ev_market_share), 2) AS Avg_Market_Share_Pct,
    ROUND(AVG(s.fuel_price_usd_per_liter), 3) AS Avg_Fuel_Price_USD,
    ROUND(AVG(s.electricity_price_usd_per_kwh), 3) AS Avg_Elec_Price_USD,
    ROUND(AVG(s.fuel_price_usd_per_liter) / AVG(s.electricity_price_usd_per_kwh), 2) AS Price_Ratio
FROM fact_sales f
JOIN dim_country c ON f.countryID = c.countryID
JOIN dim_snapshot s ON f.snapshotID = s.snapshotID
GROUP BY c.country, c.region
ORDER BY Avg_Fuel_Price_USD DESC;

 


