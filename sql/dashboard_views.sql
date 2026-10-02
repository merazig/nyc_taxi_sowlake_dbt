CREATE OR REPLACE VIEW NYC_TAXI_DB.FINAL.VW_DASHBOARD_KPI AS

SELECT
    COUNT(*) AS total_trips,

    ROUND(SUM(total_amount), 2) AS total_revenue,

    ROUND(AVG(total_amount), 2) AS avg_trip_amount,

    ROUND(SUM(tip_amount), 2) AS total_tips,

    ROUND(AVG(tip_amount), 2) AS avg_tip_amount,

    ROUND(AVG(trip_distance), 2) AS avg_distance_miles,

    ROUND(AVG(trip_duration_seconds) / 60, 2)
        AS avg_duration_minutes,

    ROUND(AVG(speed_mph), 2) AS avg_speed_mph

FROM NYC_TAXI_DB.FINAL.YELLOW_TRIPS;

SELECT *
FROM NYC_TAXI_DB.FINAL.VW_DASHBOARD_KPI;

CREATE OR REPLACE VIEW NYC_TAXI_DB.FINAL.VW_MONTHLY_KPI AS

SELECT
    DATE_TRUNC('month', pickup_datetime) AS month,

    COUNT(*) AS total_trips,

    ROUND(SUM(total_amount), 2) AS total_revenue,

    ROUND(AVG(total_amount), 2) AS avg_trip_amount,

    ROUND(SUM(tip_amount), 2) AS total_tips,

    ROUND(AVG(trip_distance), 2) AS avg_distance_miles,

    ROUND(AVG(trip_duration_seconds) / 60, 2)
        AS avg_duration_minutes,

    ROUND(AVG(speed_mph), 2) AS avg_speed_mph

FROM NYC_TAXI_DB.FINAL.YELLOW_TRIPS

GROUP BY 1
ORDER BY 1;

SELECT *
FROM NYC_TAXI_DB.FINAL.VW_MONTHLY_KPI
ORDER BY month;

CREATE OR REPLACE VIEW NYC_TAXI_DB.FINAL.VW_DAY_TYPE_KPI AS

SELECT
    CASE
        WHEN is_weekend THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,

    COUNT(*) AS total_trips,

    ROUND(SUM(total_amount), 2) AS total_revenue,

    ROUND(AVG(total_amount), 2) AS avg_trip_amount,

    ROUND(SUM(tip_amount), 2) AS total_tips,

    ROUND(AVG(tip_amount), 2) AS avg_tip_amount,

    ROUND(AVG(trip_distance), 2) AS avg_distance_miles,

    ROUND(AVG(trip_duration_seconds) / 60, 2)
        AS avg_duration_minutes,

    ROUND(AVG(speed_mph), 2) AS avg_speed_mph

FROM NYC_TAXI_DB.FINAL.YELLOW_TRIPS

GROUP BY 1;

