WITH trips AS (

    SELECT *
    FROM {{ ref('stg_yellow_trips') }}

),

enriched AS (

    SELECT

        vendor_id,
        pickup_datetime,
        dropoff_datetime,
        trip_distance,
        pickup_location_id,
        dropoff_location_id,
        payment_type,
        fare_amount,
        tip_amount,
        total_amount,

        DATEDIFF(
            'second',
            pickup_datetime,
            dropoff_datetime
        ) AS trip_duration_seconds,

        CASE
            WHEN trip_distance > 0
             AND DATEDIFF(
                    'second',
                    pickup_datetime,
                    dropoff_datetime
                 ) > 0
            THEN
                trip_distance
                /
                (
                    DATEDIFF(
                        'second',
                        pickup_datetime,
                        dropoff_datetime
                    ) / 3600.0
                )
            ELSE NULL
        END AS speed_mph,

        DAYNAME(pickup_datetime) AS pickup_day_name,

        CASE
            WHEN DAYOFWEEKISO(pickup_datetime) IN (6, 7)
                THEN TRUE
            ELSE FALSE
        END AS is_weekend,

        CASE
            WHEN HOUR(pickup_datetime) < 6
                THEN 'night'
            WHEN HOUR(pickup_datetime) < 12
                THEN 'morning'
            WHEN HOUR(pickup_datetime) < 18
                THEN 'afternoon'
            ELSE 'evening'
        END AS pickup_period,

        CASE
            WHEN trip_distance <= 0
                THEN 'invalid'
            WHEN trip_distance < 1
                THEN 'short'
            WHEN trip_distance < 5
                THEN 'medium'
            WHEN trip_distance < 10
                THEN 'long'
            ELSE 'very_long'
        END AS distance_category

    FROM trips

)

SELECT *
FROM enriched
