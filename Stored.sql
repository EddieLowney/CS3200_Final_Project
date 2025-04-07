use storm;
DELIMITER /

CREATE PROCEDURE GetStormSummaryForStateYear(
    IN input_state VARCHAR(50),
    IN input_year INT
)
BEGIN
    -- Return the summary for a given state and year
    SELECT 
        e.state,
        COUNT(DISTINCT e.event_id) AS total_events,
        SUM(e.deaths_direct) AS total_deaths,
        SUM(e.damage_property) AS total_property_damage,
        SUM(e.damage_crops) AS total_crop_damage,
        COUNT(DISTINCT f.fatality_id) AS total_fatalities,
        COUNT(DISTINCT l.county_name) AS counties_affected
    FROM events e
    LEFT JOIN fatalities f ON e.event_id = f.event_id
    LEFT JOIN locations l ON e.event_id = l.event_id
    WHERE e.state = input_state
      AND YEAR(e.begin_date_time) = input_year
    GROUP BY e.state;
END/

DELIMITER ;

CALL GetStormSummaryForStateYear('TEXAS', 2010);

