DROP TABLE IF EXISTS NYC_TAXI_DB.STAGING.YELLOW_TRIPS;

CREATE TABLE NYC_TAXI_DB.STAGING.YELLOW_TRIPS AS

SELECT
    "VendorID" AS vendor_id,

    TO_TIMESTAMP_NTZ("tpep_pickup_datetime", 6) AS pickup_datetime,

    TO_TIMESTAMP_NTZ("tpep_dropoff_datetime", 6) AS dropoff_datetime,

    "trip_distance" AS trip_distance,

    "PULocationID" AS pickup_location_id,

    "DOLocationID" AS dropoff_location_id,

    "payment_type" AS payment_type,

    "fare_amount" AS fare_amount,

    "tip_amount" AS tip_amount,

    "total_amount" AS total_amount,

    DATEDIFF(
        'second',
        TO_TIMESTAMP_NTZ("tpep_pickup_datetime", 6),
        TO_TIMESTAMP_NTZ("tpep_dropoff_datetime", 6)
    ) AS trip_duration_seconds,

    CASE
        WHEN DATEDIFF(
            'second',
            TO_TIMESTAMP_NTZ("tpep_pickup_datetime", 6),
            TO_TIMESTAMP_NTZ("tpep_dropoff_datetime", 6)
        ) > 0
        AND "trip_distance" > 0
        THEN "trip_distance" /
             (
                 DATEDIFF(
                     'second',
                     TO_TIMESTAMP_NTZ("tpep_pickup_datetime", 6),
                     TO_TIMESTAMP_NTZ("tpep_dropoff_datetime", 6)
                 ) / 3600.0
             )
        ELSE NULL
    END AS speed_mph,

    DAYNAME(
        TO_TIMESTAMP_NTZ("tpep_pickup_datetime", 6)
    ) AS pickup_day_name,

    CASE
        WHEN DAYNAME(
            TO_TIMESTAMP_NTZ("tpep_pickup_datetime", 6)
        ) IN ('Sat', 'Sun')
        THEN TRUE
        ELSE FALSE
    END AS is_weekend,

    CASE
        WHEN EXTRACT(HOUR FROM TO_TIMESTAMP_NTZ("tpep_pickup_datetime", 6)) BETWEEN 0 AND 5
            THEN 'night'
        WHEN EXTRACT(HOUR FROM TO_TIMESTAMP_NTZ("tpep_pickup_datetime", 6)) BETWEEN 6 AND 11
            THEN 'morning'
        WHEN EXTRACT(HOUR FROM TO_TIMESTAMP_NTZ("tpep_pickup_datetime", 6)) BETWEEN 12 AND 17
            THEN 'afternoon'
        ELSE 'evening'
    END AS pickup_period

FROM NYC_TAXI_DB.RAW.YELLOW_TRIPS;


ALTER TABLE NYC_TAXI_DB.STAGING.YELLOW_TRIPS
ADD COLUMN distance_category VARCHAR;

UPDATE NYC_TAXI_DB.STAGING.YELLOW_TRIPS
SET distance_category =
    CASE
        WHEN trip_distance <= 0 THEN 'invalid'
        WHEN trip_distance < 1 THEN 'short'
        WHEN trip_distance < 5 THEN 'medium'
        WHEN trip_distance < 10 THEN 'long'
        ELSE 'very_long'
    END;
