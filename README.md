# Airline Reservation System

A relational database project built using PostgreSQL that simulates the core functionality of an airline reservation system. The project manages passengers, flights, seats, bookings, payments, and tickets while demonstrating database normalization, constraints, indexing, stored procedures, and SQL views.

---

# Features

* Passenger management
* Flight scheduling and route management
* Seat class management
* Seat reservation system
* Booking and cancellation workflow
* Payment tracking
* Ticket management
* SQL stored procedures using PL/pgSQL
* Optimized queries using indexes
* Reporting views for booking details

---

# Technologies Used

* PostgreSQL
* SQL
* PL/pgSQL

---

# Database Schema

The database contains the following tables:

| Table        | Description                             |
| ------------ | --------------------------------------- |
| Passengers   | Stores passenger information            |
| Cities       | Stores departure and destination cities |
| Seat_Classes | Stores seat categories                  |
| Flights      | Stores flight schedules and routes      |
| Seats        | Stores seat information for each flight |
| Bookings     | Stores reservation records              |
| Payments     | Stores payment transactions             |
| Tickets      | Stores generated tickets                |

---

# Entity Relationships

## One-to-Many

* One city can belong to multiple flights
* One passenger can create multiple bookings
* One flight can contain multiple seats
* One seat class can contain multiple seats

## One-to-One

* One booking generates one ticket

---

# Constraints Implemented

* Unique passenger emails
* Unique flight numbers
* Unique seat numbers per flight
* Positive payment amounts
* Valid booking statuses
* Valid payment statuses
* Valid ticket statuses
* Different departure and arrival cities
* Valid flight time constraints

---

# Indexes

Indexes were added to improve query performance:

* `idx_flights_route`
* `idx_bookings_passenger`
* `idx_seats_flight`
* `idx_payments_booking`

---

# Stored Procedures

## Create Booking

```sql
SELECT create_booking(passenger_id, flight_id, seat_id);
```

## Cancel Booking

```sql
SELECT cancel_booking(booking_id);
```

## Make Payment

```sql
SELECT make_payment(booking_id, amount);
```

---

# SQL View

## View Booking Details

```sql
SELECT * FROM view_booking_details;
```

This view displays:

* Passenger information
* Flight information
* Departure and arrival cities
* Seat details
* Seat class
* Booking status
* Payment status

---

# Setup Instructions

## 1. Install PostgreSQL

Download PostgreSQL:

[PostgreSQL](https://www.postgresql.org/download/?utm_source=chatgpt.com)

---

## 2. Create Database

```sql
CREATE DATABASE airline_reservation_system;
```

---

## 3. Connect to Database

```sql
\c airline_reservation_system
```

---

## 4. Run the SQL File

Execute the SQL script inside PostgreSQL or pgAdmin.

---

# Example Queries

## Create Booking

```sql
SELECT create_booking(1, 1, 1);
```

## Make Payment

```sql
SELECT make_payment(1, 200.00);
```

## View Booking Details

```sql
SELECT * FROM view_booking_details;
```

## Cancel Booking

```sql
SELECT cancel_booking(1);
```

---

# Sample Output

| Booking ID | Passenger | Flight | Seat | Class   | Payment Status |
| ---------- | --------- | ------ | ---- | ------- | -------------- |
| 1          | Ali Khan  | PK-212 | 1A   | Economy | Paid           |

---

# Learning Outcomes

This project demonstrates:

* Relational database design
* Database normalization
* Foreign key relationships
* SQL constraints
* Query optimization using indexes
* PL/pgSQL stored procedures
* SQL views
* Reservation workflow implementation

---

# Future Improvements

* Authentication system
* REST API integration
* Frontend interface
* Real-time seat locking
* Refund management
* Admin dashboard
* Docker deployment
* Cloud hosting


