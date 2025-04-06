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
    event_id int PRIMARY KEY,
    fatality_location VARCHAR(255) NOT NULL,
    fatality_date DATETIME,
    fatality_type VARCHAR(50),
    fatality_age int,
    fatality_sex VARCHAR(50)
    );

-- Reading files into Details
LOAD DATA LOCAL INFILE '/Users/colinjohnson/Downloads/StormEvents_details-ftp_v1.0_d2020_c20240620.csv'
INTO TABLE storm.events
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(event_id, state, event_type, begin_date_time, end_date_time, cz_name, 
 source, magnitude, deaths_direct, damage_property, damage_crops);

-- Reading files into locations
LOAD DATA LOCAL INFILE '/Users/colinjohnson/Downloads/StormEvents_fatalities-ftp_v1.0_d2020_c20240620.csv'
INTO TABLE storm.fatalities
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(fatality_id, event_id, fatality_location, fatality_date, fatality_type, 
fatality_age, fatality_sex);


SELECT * FROM fatalities;