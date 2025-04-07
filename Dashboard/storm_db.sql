DROP DATABASE IF EXISTS storm;
CREATE DATABASE IF NOT EXISTS storm;
USE storm;
SHOW GRANTS FOR 'root'@'localhost';
SET GLOBAL local_infile = 1;
SET FOREIGN_KEY_CHECKS = 0;

-- First, ensure the events table has episode_id as part of its primary key or as a unique key
DROP TABLE IF EXISTS events;
CREATE TABLE events (
    event_id int,
    episode_id int,
    state VARCHAR(50),
    event_type VARCHAR(50),
    begin_date_time DATETIME,
    end_date_time DATETIME,
    cz_name VARCHAR(50),
    source VARCHAR(50),
    magnitude int,
    deaths_direct int,
    damage_property int,
    damage_crops int,
    PRIMARY KEY (event_id),  -- Keep event_id as primary key
    UNIQUE KEY (episode_id)  -- Add unique constraint for episode_id
);


CREATE TABLE fatalities (
    fatality_id INT PRIMARY KEY,
    event_id INT,
    fatality_location VARCHAR(255) NOT NULL,
    fatality_date DATETIME,
    fatality_type VARCHAR(50),
    fatality_age INT,
    fatality_sex VARCHAR(50),
    CONSTRAINT fk_event FOREIGN KEY (event_id) REFERENCES events(event_id)
);

-- Then modify the locations table to include the foreign key
DROP TABLE IF EXISTS locations;
CREATE TABLE locations (
	yearmonth INT,
    event_id INT,
    episode_id INT,
    location_index INT,
    `range` DECIMAL(5,2),
    location VARCHAR(255),
    latitude DECIMAL(8,4),
    longitude DECIMAL(9,4),
    lat2 INT,
    lon2 INT,
    county_name VARCHAR(255),
    PRIMARY KEY (yearmonth, episode_id, event_id, location_index),
    CONSTRAINT fk_event_location FOREIGN KEY (event_id) REFERENCES events(event_id),
    CONSTRAINT fk_episode FOREIGN KEY (episode_id) REFERENCES events(episode_id)
);


DROP TABLE IF EXISTS claims;
CREATE TABLE claims (
    county_id INT AUTO_INCREMENT PRIMARY KEY,
    county VARCHAR(255),
    total_paid_claims INT,
    total_claim_dollars_paid DECIMAL(12,2) 
);

-- Reading files into Details
LOAD DATA LOCAL INFILE '/Users/colinjohnson/Downloads/StormEvents_details-ftp_v1.0_d2010_c20170726.csv'
INTO TABLE events
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(
 @BEGIN_YEARMONTH, @BEGIN_DAY, @BEGIN_TIME, @END_YEARMONTH, @END_DAY, @END_TIME,
 episode_id, event_id, state, @STATE_FIPS, @YEAR, @MONTH_NAME, event_type,
 @CZ_TYPE, @CZ_FIPS, cz_name, @WFO, @begin_date_time_str, @CZ_TIMEZONE, @end_date_time_str,
 @INJURIES_DIRECT, @INJURIES_INDIRECT, deaths_direct, @DEATHS_INDIRECT,
 damage_property, damage_crops, source, magnitude,
 @MAGNITUDE_TYPE, @FLOOD_CAUSE, @CATEGORY, @TOR_F_SCALE, @TOR_LENGTH, @TOR_WIDTH,
 @TOR_OTHER_WFO, @TOR_OTHER_CZ_STATE, @TOR_OTHER_CZ_FIPS, @TOR_OTHER_CZ_NAME,
 @BEGIN_RANGE, @BEGIN_AZIMUTH, @BEGIN_LOCATION,
 @END_RANGE, @END_AZIMUTH, @END_LOCATION,
 @BEGIN_LAT, @BEGIN_LON, @END_LAT, @END_LON,
 @EPISODE_NARRATIVE, @EVENT_NARRATIVE, @DATA_SOURCE)
SET
begin_date_time = STR_TO_DATE(@begin_date_time_str, '%d-%b-%y %H:%i:%s'),
end_date_time   = STR_TO_DATE(@end_date_time_str, '%d-%b-%y %H:%i:%s');


LOAD DATA LOCAL INFILE '/Users/colinjohnson/Downloads/StormEvents_fatalities-ftp_v1.0_d2010_c20220425.csv'
INTO TABLE fatalities
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(@fat_yearmonth, @fat_day, @fat_time,
 fatality_id, event_id, fatality_type, @fatality_date_str,
 fatality_age, fatality_sex, fatality_location, @event_yearmonth)
SET
fatality_date = STR_TO_DATE(@fatality_date_str, '%m/%d/%Y %H:%i:%s');


LOAD DATA LOCAL INFILE '/Users/colinjohnson/Downloads/StormEvents_locations-ftp_v1.0_d2010_c20250401.csv'
INTO TABLE locations
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(yearmonth, episode_id, event_id, location_index, `range`, @azimuth, location, latitude, longitude, lat2, lon2, county_name);


LOAD DATA LOCAL INFILE '/Users/colinjohnson/Downloads/Cleaned_Claims_Numeric.csv'
INTO TABLE claims
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(county, total_paid_claims, total_claim_dollars_paid);

SET FOREIGN_KEY_CHECKS = 1;
