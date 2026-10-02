SELECT
    COUNT(*) AS total_trips,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS avg_trip_amount,
    SUM(tip_amount) AS total_tips,
    AVG(tip_amount) AS avg_tip_amount,
    AVG(trip_distance) AS avg_distance_miles,
    AVG(trip_duration_seconds) / 60.0 AS avg_duration_minutes,
    AVG(speed_mph) AS avg_speed_mph

FROM {{ ref('fct_yellow_trips') }}
