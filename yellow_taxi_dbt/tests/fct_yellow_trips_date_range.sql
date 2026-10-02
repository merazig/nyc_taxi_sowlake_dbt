SELECT *
FROM {{ ref('fct_yellow_trips') }}
WHERE
    pickup_datetime < '2025-01-01'
    OR pickup_datetime >= '2026-01-01'
