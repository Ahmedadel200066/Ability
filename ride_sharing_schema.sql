-- =====================================================
-- Ride-Sharing App Database Schema (PostgreSQL)
-- =====================================================

-- =======================================
-- Users Table
-- =======================================
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    user_type VARCHAR(10) CHECK (user_type IN ('rider','driver')) NOT NULL,
    email VARCHAR(100)
);

-- =======================================
-- Drivers Table
-- =======================================
CREATE TABLE drivers (
    driver_id SERIAL PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    vehicle_type VARCHAR(50),
    license_number VARCHAR(50) UNIQUE,
    current_status VARCHAR(10) CHECK (current_status IN ('online','offline')) DEFAULT 'offline',
    average_rating NUMERIC(3,2) DEFAULT 0.0,
    CONSTRAINT fk_driver_user FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- =======================================
-- Trips Table
-- =======================================
CREATE TABLE trips (
    trip_id SERIAL PRIMARY KEY,
    rider_id INT NOT NULL,
    driver_id INT NOT NULL,
    pickup_latitude NUMERIC(9,6) NOT NULL,
    pickup_longitude NUMERIC(9,6) NOT NULL,
    dropoff_latitude NUMERIC(9,6) NOT NULL,
    dropoff_longitude NUMERIC(9,6) NOT NULL,
    fare NUMERIC(10,2) NOT NULL,
    trip_status VARCHAR(10) CHECK (trip_status IN ('pending','ongoing','completed')) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rider FOREIGN KEY(rider_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_driver FOREIGN KEY(driver_id) REFERENCES drivers(driver_id) ON DELETE CASCADE
);

-- =======================================
-- Driver Locations Table (Real-time Tracking)
-- =======================================
-- This can be used together with Redis for caching live driver locations
CREATE TABLE driver_locations (
    driver_id INT PRIMARY KEY,
    latitude NUMERIC(9,6) NOT NULL,
    longitude NUMERIC(9,6) NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_location_driver FOREIGN KEY(driver_id) REFERENCES drivers(driver_id) ON DELETE CASCADE
);

-- =======================================
-- Indexes for Faster Queries
-- =======================================
CREATE INDEX idx_trips_rider_id ON trips(rider_id);
CREATE INDEX idx_trips_driver_id ON trips(driver_id);
CREATE INDEX idx_driver_locations_lat_lon ON driver_locations(latitude, longitude);