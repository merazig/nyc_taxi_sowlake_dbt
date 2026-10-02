-- ============================================================
-- ANALYSIS - GLOBAL KPIs 2025
-- ============================================================

SELECT
    COUNT(*) AS total_trips,

    ROUND(SUM(total_amount), 2) AS total_revenue,

    ROUND(AVG(total_amount), 2) AS avg_total_amount,

    ROUND(AVG(fare_amount), 2) AS avg_fare_amount,

    ROUND(SUM(tip_amount), 2) AS total_tips,

    ROUND(AVG(tip_amount), 2) AS avg_tip_amount,

    ROUND(SUM(trip_distance), 2) AS total_distance_miles,

    ROUND(AVG(trip_distance), 2) AS avg_distance_miles,

    ROUND(AVG(trip_duration_seconds) / 60, 2)
        AS avg_duration_minutes,

    ROUND(AVG(speed_mph), 2)
        AS avg_speed_mph

FROM NYC_TAXI_DB.FINAL.YELLOW_TRIPS;

SELECT
    DATE_TRUNC('month', pickup_datetime) AS month,

    COUNT(*) AS total_trips,

    ROUND(SUM(total_amount), 2) AS total_revenue,

    ROUND(AVG(total_amount), 2) AS avg_total_amount,

    ROUND(SUM(tip_amount), 2) AS total_tips,

    ROUND(AVG(trip_distance), 2) AS avg_distance_miles,

    ROUND(AVG(trip_duration_seconds) / 60, 2)
        AS avg_duration_minutes

FROM NYC_TAXI_DB.FINAL.YELLOW_TRIPS

GROUP BY 1
ORDER BY 1;

SELECT
    CASE
        WHEN is_weekend THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,

    COUNT(*) AS total_trips,

    ROUND(SUM(total_amount), 2) AS total_revenue,

    ROUND(AVG(total_amount), 2) AS avg_total_amount,

    ROUND(SUM(tip_amount), 2) AS total_tips,

    ROUND(AVG(tip_amount), 2) AS avg_tip_amount,

    ROUND(AVG(trip_distance), 2) AS avg_distance_miles,

    ROUND(AVG(trip_duration_seconds) / 60, 2)
        AS avg_duration_minutes,

    ROUND(AVG(speed_mph), 2) AS avg_speed_mph

FROM NYC_TAXI_DB.FINAL.YELLOW_TRIPS

GROUP BY 1
ORDER BY 1;

SELECT
    pickup_period,

    COUNT(*) AS total_trips,

    ROUND(SUM(total_amount), 2) AS total_revenue,

    ROUND(AVG(total_amount), 2) AS avg_total_amount,

    ROUND(SUM(tip_amount), 2) AS total_tips,

    ROUND(AVG(tip_amount), 2) AS avg_tip_amount,

    ROUND(AVG(trip_distance), 2) AS avg_distance_miles,

    ROUND(AVG(trip_duration_seconds) / 60, 2)
        AS avg_duration_minutes,

    ROUND(AVG(speed_mph), 2) AS avg_speed_mph

FROM NYC_TAXI_DB.FINAL.YELLOW_TRIPS

GROUP BY pickup_period

ORDER BY
    CASE pickup_period
        WHEN 'night' THEN 1
        WHEN 'morning' THEN 2
        WHEN 'day' THEN 3
        WHEN 'evening_rush' THEN 4
        WHEN 'evening' THEN 5
    END;

SELECT
    distance_category,

    COUNT(*) AS total_trips,

    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS trip_share_pct,

    ROUND(SUM(total_amount), 2) AS total_revenue,

    ROUND(AVG(total_amount), 2) AS avg_total_amount,

    ROUND(AVG(trip_distance), 2) AS avg_distance_miles,

    ROUND(AVG(trip_duration_seconds) / 60, 2)
        AS avg_duration_minutes,

    ROUND(AVG(speed_mph), 2) AS avg_speed_mph

FROM NYC_TAXI_DB.FINAL.YELLOW_TRIPS

GROUP BY distance_category

ORDER BY
    CASE distance_category
        WHEN 'invalid' THEN 1
        WHEN 'short' THEN 2
        WHEN 'medium' THEN 3
        WHEN 'long' THEN 4
        WHEN 'very_long' THEN 5
    END;

SELECT
    payment_type,

    COUNT(*) AS total_trips,

    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS trip_share_pct,

    ROUND(SUM(total_amount), 2) AS total_revenue,

    ROUND(AVG(total_amount), 2) AS avg_total_amount,

    ROUND(SUM(tip_amount), 2) AS total_tips,

    ROUND(AVG(tip_amount), 2) AS avg_tip_amount

FROM NYC_TAXI_DB.FINAL.YELLOW_TRIPS

GROUP BY payment_type

ORDER BY total_trips DESC;

SELECT
    pickup_location_id,

    COUNT(*) AS total_trips,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS trip_share_pct,

    ROUND(SUM(total_amount), 2) AS total_revenue,

    ROUND(AVG(total_amount), 2) AS avg_total_amount,

    ROUND(AVG(trip_distance), 2) AS avg_distance_miles

FROM NYC_TAXI_DB.FINAL.YELLOW_TRIPS

GROUP BY pickup_location_id

ORDER BY total_trips DESC

LIMIT 15;

SELECT
    dropoff_location_id,

    COUNT(*) AS total_trips,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS trip_share_pct,

    ROUND(SUM(total_amount), 2) AS total_revenue,

    ROUND(AVG(total_amount), 2) AS avg_total_amount,

    ROUND(AVG(trip_distance), 2) AS avg_distance_miles

FROM NYC_TAXI_DB.FINAL.YELLOW_TRIPS

GROUP BY dropoff_location_id

ORDER BY total_trips DESC

LIMIT 15;

SELECT
    pickup_location_id,
    dropoff_location_id,

    COUNT(*) AS total_trips,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS trip_share_pct,

    ROUND(SUM(total_amount), 2) AS total_revenue,

    ROUND(AVG(total_amount), 2) AS avg_total_amount,

    ROUND(AVG(trip_distance), 2) AS avg_distance_miles,

    ROUND(AVG(trip_duration_seconds) / 60, 2)
        AS avg_duration_minutes

FROM NYC_TAXI_DB.FINAL.YELLOW_TRIPS

GROUP BY
    pickup_location_id,
    dropoff_location_id

ORDER BY total_trips DESC

LIMIT 15;

SELECT
    DATE_TRUNC('month', pickup_datetime) AS month,
    COUNT(*) AS total_trips
FROM NYC_TAXI_DB.FINAL.YELLOW_TRIPS
GROUP BY 1
ORDER BY 1;

