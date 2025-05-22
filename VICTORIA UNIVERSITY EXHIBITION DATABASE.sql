CREATE DATABASE IF NOT EXISTS victoria_university_exhibitions;
USE victoria_university_exhibitions;
use seatsavailable;

CREATE TABLE IF NOT EXISTS Bookings (
    SeatID VARCHAR(20) PRIMARY KEY,               
    GuestName VARCHAR(255) NOT NULL,
    BookingDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (SeatID) REFERENCES seatsavailable(SeatID) ON DELETE CASCADE
);

DELIMITER $$

CREATE FUNCTION book_next_available_seat(guest_name VARCHAR(255))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE seat_id VARCHAR(20);

    START TRANSACTION;

    SELECT SeatID INTO seat_id
    FROM seatsavailable
    WHERE Available = TRUE
    LIMIT 1
    FOR UPDATE;

    IF seat_id IS NULL THEN
        ROLLBACK;
        RETURN 'NO_AVAILABLE_SEAT';
    END IF;

    UPDATE seatsavailable SET Available = FALSE WHERE SeatID = seat_id;

    IF ROW_COUNT() = 0 THEN
        ROLLBACK;
        RETURN 'UPDATE_FAILED';
    END IF;

    INSERT INTO Bookings (SeatID, GuestName) VALUES (seat_id, guest_name);
    COMMIT;
    RETURN seat_id;
END$$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION get_seat_info(seat_number VARCHAR(10))
RETURNS JSON
DETERMINISTIC
BEGIN
    DECLARE seat_info JSON;

    SELECT JSON_OBJECT(
        'seatNumber', SeatNumber,
        'section', Section,
        'price', Price,
        'available', Available
    )
    INTO seat_info
    FROM seatsavailable
    WHERE SeatNumber = seat_number
    LIMIT 1;

    RETURN seat_info;
END$$

DELIMITER ;

