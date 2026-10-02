DROP TABLE IF EXISTS NYC_TAXI_DB.FINAL.YELLOW_TRIPS;

CREATE TABLE NYC_TAXI_DB.FINAL.YELLOW_TRIPS AS
SELECT
    vendor_id,
    pickup_datetime,
    dropoff_datetime,
    trip_distance,
    distance_category,
    pickup_location_id,
    dropoff_location_id,
    payment_type,
    fare_amount,
    tip_amount,
    total_amount,
    trip_duration_seconds,
    speed_mph,
    pickup_day_name,
    is_weekend,
    pickup_period
FROM NYC_TAXI_DB.STAGING.YELLOW_TRIPS
WHERE fare_amount > 0
  AND total_amount > 0
  AND trip_distance <= 1000
  AND (
      pickup_datetime >= '2025-01-01'
        AND pickup_datetime < '2026-01-01'
  )
  AND (
      trip_distance = 0
      OR fare_amount / trip_distance <= 10000
  );

SELECT
    COUNT_IF(fare_amount <= 0) AS invalid_fare,
    COUNT_IF(total_amount <= 0) AS invalid_total,
    COUNT_IF(trip_distance > 1000) AS invalid_distance,
    COUNT_IF(
        trip_distance > 0
        AND fare_amount / trip_distance > 10000
    ) AS extreme_ratio
FROM NYC_TAXI_DB.FINAL.YELLOW_TRIPS;

SELECT COUNT(*) AS final_rows
FROM NYC_TAXI_DB.FINAL.YELLOW_TRIPS;
