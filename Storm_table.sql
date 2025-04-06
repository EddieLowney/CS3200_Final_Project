DROP DATABASE IF EXISTS storm;
CREATE DATABASE IF NOT EXISTS storm;
USE storm;
SHOW GRANTS FOR 'root'@'localhost';
-- Create the tables

DROP TABLE IF EXISTS events;
CREATE TABLE events (
	event_id int PRIMARY KEY,
    state VARCHAR(50),
	event_type VARCHAR(50),
    begin_date_time DATETIME,
    end_date_time DATETIME,
    cz_name VARCHAR(50),
    source VARCHAR(50),
    magnitude int,
    deaths_direct int,
    damage_property int,
    damage_crops int
);


DROP TABLE IF EXISTS fatalities;
CREATE TABLE fatalities (
    fatality_id int PRIMARY KEY,
    event_id int,
    fatality_location VARCHAR(255) NOT NULL,
    fatality_date DATETIME,
    fatality_type VARCHAR(50),
    fatality_age int,
    fatality_sex VARCHAR(50),
    CONSTRAINT fk_event FOREIGN KEY (event_id) REFERENCES events(event_id)
);

DROP TABLE IF EXISTS locations;
CREATE TABLE locations (
	yearmonth INT,
    episode_id INT,
    event_id INT,
    location_index INT,
    `range` DECIMAL(5,2),
    location VARCHAR(255),
    latitude DECIMAL(8,4),
    longitude DECIMAL(9,4),
    lat2 INT,
    lon2 INT,
    PRIMARY KEY (yearmonth, episode_id, event_id, location_index),
    CONSTRAINT fk_event_location FOREIGN KEY (event_id) REFERENCES events(event_id)
);

DROP TABLE IF EXISTS claims;
CREATE TABLE claims (
	county_id INT AUTO_INCREMENT PRIMARY KEY,
	county VARCHAR(255),
    total_paid_claims INT,
    total_claim_dollars_paid DECIMAL(12,2) 
);
    
-- Reading files into Details
LOAD DATA LOCAL INFILE '/Users/ameliadsouza/Downloads/StormEvents_details-ftp_v1.0_d2010_c20250401.csv'
INTO TABLE storm.events
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(event_id, state, event_type, begin_date_time, end_date_time, cz_name, 
 source, magnitude, deaths_direct, damage_property, damage_crops);

-- Reading files into locations
LOAD DATA LOCAL INFILE '/Users/ameliadsouza/Downloads/StormEvents_fatalities-ftp_v1.0_d2010_c20220425.csv'
INTO TABLE storm.fatalities
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(fatality_id, event_id, fatality_location, fatality_date, fatality_type, 
fatality_age, fatality_sex);

LOAD DATA LOCAL INFILE '/Users/ameliadsouza/Downloads/StormEvents_locations-ftp_v1.0_d2010_c20220425.csv'
INTO TABLE storm.locations
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(yearmonth, episode_id, event_id, location_index, `range`, location, latitude, longitude, lat2, lon2);

LOAD DATA LOCAL INFILE '/Users/ameliadsouza/Downloads/Cleaned_Claims_Numeric.csv'
INTO TABLE storm.claims
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(county, total_paid_claims, total_claim_dollars_paid);

SELECT * FROM fatalities;