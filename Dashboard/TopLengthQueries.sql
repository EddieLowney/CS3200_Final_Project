USE storm;
DROP PROCEDURE IF EXISTS Top50HurricanesByMagnitude;
DELIMITER //
CREATE PROCEDURE Top50HurricanesByMagnitude(
	IN number_of_storms INT
)
BEGIN
    SELECT 
        e.event_id,
        e.episode_id,
        e.state,
        e.event_type,
        e.magnitude,
        e.begin_date_time,
        e.end_date_time,
        e.cz_name,
        e.source,
        l_start.latitude AS start_latitude,
        l_start.longitude AS start_longitude,
        l_end.latitude AS end_latitude,
        l_end.longitude AS end_longitude,
        -- Haversine formula to calculate the distance in kilometers
        6371 * ACOS(
            SIN(RADIANS(l_start.latitude)) * SIN(RADIANS(l_end.latitude)) + 
            COS(RADIANS(l_start.latitude)) * COS(RADIANS(l_end.latitude)) * 
            COS(RADIANS(l_end.longitude) - RADIANS(l_start.longitude))
        ) AS distance_moved_km
    FROM events e
    JOIN locations l_start ON e.event_id = l_start.event_id AND l_start.location_index = (
        SELECT MIN(location_index) FROM locations WHERE event_id = e.event_id
    )
    JOIN locations l_end ON e.event_id = l_end.event_id AND l_end.location_index = (
        SELECT MAX(location_index) FROM locations WHERE event_id = e.event_id
    )

    ORDER BY distance_moved_km DESC
    LIMIT number_of_storms;
END //
DELIMITER ;

-- CALL Top50HurricanesByMagnitude(50);
