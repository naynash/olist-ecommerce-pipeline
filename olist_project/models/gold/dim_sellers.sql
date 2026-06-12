WITH source AS (
    SELECT
        seller_id,
        zip_code_prefix,
        seller_city,
        seller_state
    FROM olist_db.silver.stg_sellers
)

SELECT
    seller_id,
    zip_code_prefix,
    seller_city,
    seller_state
FROM source