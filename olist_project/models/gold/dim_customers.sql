WITH source AS (
    SELECT
        customer_id,
        customer_unique_id,
        zip_code_prefix,
        customer_city,
        customer_state
    FROM olist_db.silver.stg_customers
)

SELECT
    customer_id,
    customer_unique_id,
    zip_code_prefix,
    customer_city,
    customer_state
FROM source