DROP PROCEDURE IF EXISTS GetAverageLossesByMagnitude;
DELIMITER //

CREATE PROCEDURE GetAverageLossesByMagnitude()
BEGIN
    DECLARE storm_magnitude INT;
    DECLARE avg_property_loss DECIMAL(10, 2);
    DECLARE avg_crop_loss DECIMAL(10, 2);
    DECLARE avg_total_loss DECIMAL(10, 2);
    DECLARE row_found TINYINT DEFAULT TRUE;

    -- Cursor to loop through distinct magnitudes
    DECLARE magnitude_cursor CURSOR FOR
        SELECT DISTINCT magnitude
        FROM events
        WHERE magnitude IS NOT NULL;

    -- Handler for end of cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET row_found = FALSE;

    -- Open the cursor
    OPEN magnitude_cursor;

    -- Initial fetch
    FETCH magnitude_cursor INTO storm_magnitude;

    -- WHILE loop version
    WHILE row_found DO

        -- Calculate average property loss
        SELECT AVG(damage_property) INTO avg_property_loss
        FROM events
        WHERE magnitude = storm_magnitude AND damage_property IS NOT NULL;

        -- Calculate average crop loss
        SELECT AVG(damage_crops) INTO avg_crop_loss
        FROM events
        WHERE magnitude = storm_magnitude AND damage_crops IS NOT NULL;

        -- Average total loss (simplified as average of both values)
        SET avg_total_loss = (avg_property_loss + avg_crop_loss) / 2;

        -- Insert into result table
        INSERT INTO avg_losses_by_magnitude (magnitude, average_property_loss, average_crop_loss, average_total_loss)
        VALUES (storm_magnitude, avg_property_loss, avg_crop_loss, avg_total_loss);

        -- Fetch next row
        FETCH magnitude_cursor INTO storm_magnitude;

    END WHILE;

    CLOSE magnitude_cursor;
END //

DELIMITER ;

CALL GetAverageLossesByMagnitude();
SELECT * FROM avg_losses_by_magnitude;
