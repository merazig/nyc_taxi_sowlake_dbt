SELECT *
FROM {{ ref('fct_yellow_trips') }}
WHERE
       fare_amount <= 0
    OR total_amount <= 0
    OR trip_distance > 1000
    OR (
        trip_distance > 0
        AND fare_amount / trip_distance > 10000
    )
