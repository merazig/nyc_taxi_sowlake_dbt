SELECT *
FROM {{ ref('int_yellow_trips_enriched') }}

WHERE pickup_datetime >= '2025-01-01'
  AND pickup_datetime < '2026-01-01'

  AND fare_amount > 0
  AND total_amount > 0
  AND trip_distance <= 1000
  AND (
      trip_distance = 0
      OR fare_amount / trip_distance <= 10000
  )
