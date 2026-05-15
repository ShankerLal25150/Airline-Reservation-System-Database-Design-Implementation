
CREATE TABLE Passengers (
    passenger_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    age INT CHECK (age > 0),
    password_hash VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Cities (
    city_id SERIAL PRIMARY KEY,
    city_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Seat_Classes (
    class_id SERIAL PRIMARY KEY,
    class_name VARCHAR(30) UNIQUE NOT NULL
);

INSERT INTO Seat_Classes(class_name)
VALUES
('Economy'),
('Business'),
('First Class');

CREATE TABLE Flights (
    flight_id SERIAL PRIMARY KEY,
    flight_number VARCHAR(20) UNIQUE NOT NULL,
    city_from_id INT NOT NULL REFERENCES Cities(city_id),
    city_to_id INT NOT NULL REFERENCES Cities(city_id),
    departure_timestamp TIMESTAMP NOT NULL,
    arrival_timestamp TIMESTAMP NOT NULL,
    CHECK (city_from_id <> city_to_id),
    CHECK (arrival_timestamp > departure_timestamp)
);

CREATE TABLE Seats (
    seat_id SERIAL PRIMARY KEY,
    flight_id INT NOT NULL REFERENCES Flights(flight_id) ON DELETE CASCADE,
    seat_name VARCHAR(10) NOT NULL,
    class_id INT NOT NULL REFERENCES Seat_Classes(class_id),
    seat_price DECIMAL(10,2) NOT NULL CHECK (seat_price > 0),
    is_reserved BOOLEAN DEFAULT FALSE,
    UNIQUE(flight_id, seat_name)
);

CREATE TABLE Bookings (
    booking_id SERIAL PRIMARY KEY,
    passenger_id INT NOT NULL REFERENCES Passengers(passenger_id) ON DELETE CASCADE,
    flight_id INT NOT NULL REFERENCES Flights(flight_id) ON DELETE CASCADE,
    seat_id INT NOT NULL REFERENCES Seats(seat_id) ON DELETE CASCADE,
    booking_status VARCHAR(20)
    CHECK (booking_status IN ('Pending', 'Confirmed', 'Cancelled')),
    booking_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(flight_id, seat_id)
);

CREATE TABLE Payments (
    payment_id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL REFERENCES Bookings(booking_id) ON DELETE CASCADE,
    payment_amount DECIMAL(10,2) NOT NULL CHECK (payment_amount > 0),
    payment_status VARCHAR(20)
    CHECK (payment_status IN ('Pending', 'Paid', 'Failed', 'Refunded')),
    payment_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Tickets (
    ticket_id SERIAL PRIMARY KEY,
    booking_id INT UNIQUE NOT NULL REFERENCES Bookings(booking_id) ON DELETE CASCADE,
    ticket_status VARCHAR(20)
    CHECK (ticket_status IN ('Active', 'Cancelled', 'Expired')),
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_flights_route
ON Flights(city_from_id, city_to_id);

CREATE INDEX idx_bookings_passenger
ON Bookings(passenger_id);

CREATE INDEX idx_seats_flight
ON Seats(flight_id);

CREATE INDEX idx_payments_booking
ON Payments(booking_id);

INSERT INTO Cities(city_name)
VALUES
('Dubai'),
('Lahore'),
('Karachi');

INSERT INTO Passengers(full_name, email, age, password_hash)
VALUES
('Ali Khan', 'ali@gmail.com', 22, 'hashed_password_1'),
('Hamza Ahmed', 'hamza@gmail.com', 25, 'hashed_password_2');

INSERT INTO Flights(
    flight_number,
    city_from_id,
    city_to_id,
    departure_timestamp,
    arrival_timestamp
)
VALUES
(
    'PK-212',
    1,
    2,
    '2026-06-01 14:30:00',
    '2026-06-01 18:00:00'
);

INSERT INTO Seats(
    flight_id,
    seat_name,
    class_id,
    seat_price
)
VALUES
(1, '1A', 1, 200.00),
(1, '1B', 1, 200.00),
(1, '2A', 2, 350.00),
(1, '3A', 3, 500.00);

CREATE OR REPLACE FUNCTION create_booking(
    p_passenger_id INT,
    p_flight_id INT,
    p_seat_id INT
)
RETURNS VOID AS $$
DECLARE
    seat_reserved BOOLEAN;
BEGIN

    SELECT is_reserved
    INTO seat_reserved
    FROM Seats
    WHERE seat_id = p_seat_id;

    IF seat_reserved = TRUE THEN
        RAISE EXCEPTION 'Seat already reserved';
    END IF;

    INSERT INTO Bookings(
        passenger_id,
        flight_id,
        seat_id,
        booking_status
    )
    VALUES(
        p_passenger_id,
        p_flight_id,
        p_seat_id,
        'Confirmed'
    );

    UPDATE Seats
    SET is_reserved = TRUE
    WHERE seat_id = p_seat_id;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION make_payment(
    p_booking_id INT,
    p_amount DECIMAL(10,2)
)
RETURNS VOID AS $$
BEGIN

    INSERT INTO Payments(
        booking_id,
        payment_amount,
        payment_status
    )
    VALUES(
        p_booking_id,
        p_amount,
        'Paid'
    );

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cancel_booking(
    p_booking_id INT
)
RETURNS VOID AS $$
DECLARE
    s_id INT;
BEGIN

    SELECT seat_id
    INTO s_id
    FROM Bookings
    WHERE booking_id = p_booking_id;

    UPDATE Bookings
    SET booking_status = 'Cancelled'
    WHERE booking_id = p_booking_id;

    UPDATE Seats
    SET is_reserved = FALSE
    WHERE seat_id = s_id;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW view_booking_details AS
SELECT

    b.booking_id,

    p.full_name,

    p.email,

    f.flight_number,

    cf.city_name AS departure_city,
    ct.city_name AS arrival_city,

    f.departure_timestamp,
    f.arrival_timestamp,

    s.seat_name,

    sc.class_name,

    s.seat_price,

    b.booking_status,

    pay.payment_status

FROM Bookings b

JOIN Passengers p
ON b.passenger_id = p.passenger_id

JOIN Flights f
ON b.flight_id = f.flight_id

JOIN Cities cf
ON f.city_from_id = cf.city_id

JOIN Cities ct
ON f.city_to_id = ct.city_id

JOIN Seats s
ON b.seat_id = s.seat_id

JOIN Seat_Classes sc
ON s.class_id = sc.class_id

LEFT JOIN Payments pay
ON b.booking_id = pay.booking_id;

SELECT * FROM view_booking_details;
