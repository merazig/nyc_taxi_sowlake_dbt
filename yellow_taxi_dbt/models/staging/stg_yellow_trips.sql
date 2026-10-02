WITH source AS (

    SELECT *
    FROM {{ source('raw', 'yellow_trips') }}

),

renamed AS (

    SELECT
        "VendorID" AS vendor_id,

        TO_TIMESTAMP_NTZ(
            "tpep_pickup_datetime",
            6
        ) AS pickup_datetime,

        TO_TIMESTAMP_NTZ(
            "tpep_dropoff_datetime",
            6
        ) AS dropoff_datetime,

        "trip_distance" AS trip_distance,

        "PULocationID" AS pickup_location_id,

        "DOLocationID" AS dropoff_location_id,

        "payment_type" AS payment_type,

        "fare_amount" AS fare_amount,

        "tip_amount" AS tip_amount,

        "total_amount" AS total_amount

    FROM source

)

SELECT *
FROM renamed
