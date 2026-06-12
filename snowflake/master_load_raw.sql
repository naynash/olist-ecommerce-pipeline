USE DATABASE olist_db;
USE SCHEMA raw;
USE WAREHOUSE olist_wh;

COPY INTO raw.customers
    FROM @raw.stg_customers
    MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
    ON_ERROR = 'CONTINUE';

COPY INTO raw.sellers
    FROM @raw.stg_sellers
    MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
    ON_ERROR = 'CONTINUE';

COPY INTO raw.products
    FROM @raw.stg_products
    MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
    ON_ERROR = 'CONTINUE';

COPY INTO raw.geolocation
    FROM @raw.stg_geolocation
    MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
    ON_ERROR = 'CONTINUE';

COPY INTO raw.category_translation
    FROM @raw.stg_category_translation
    MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
    ON_ERROR = 'CONTINUE';

COPY INTO raw.sellers (
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state,
    _source_file
)
FROM (
    SELECT $1, $2, $3, $4,
        METADATA$FILENAME
    FROM @raw.stg_sellers
)
ON_ERROR = 'CONTINUE';

COPY INTO raw.products (
    product_id,
    product_category_name,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    _source_file
)
FROM (
    SELECT $1, $2, $3, $4, $5, $6, $7, $8, $9,
        METADATA$FILENAME
    FROM @raw.stg_products
)
ON_ERROR = 'CONTINUE';

COPY INTO raw.geolocation (
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state,
    _source_file
)
FROM (
    SELECT $1, $2, $3, $4, $5,
        METADATA$FILENAME
    FROM @raw.stg_geolocation
)
ON_ERROR = 'CONTINUE';


COPY INTO raw.customers (
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state,
    _source_file
)
FROM (
    SELECT
        $1, $2, $3, $4, $5,
        METADATA$FILENAME
    FROM @raw.stg_customers
)
ON_ERROR = 'CONTINUE';


SELECT $1, $2, $3, $4, $5, $6
FROM @raw.stg_sellers
LIMIT 3;

COPY INTO raw.category_translation (
    product_category_name,
    product_category_name_english,
    _source_file
)
FROM (
    SELECT $1, $2,
        METADATA$FILENAME
    FROM @raw.stg_category_translation
)
ON_ERROR = 'CONTINUE';


SELECT 'customers'            AS tbl, COUNT(*) AS "rows" FROM raw.customers
UNION ALL
SELECT 'sellers'              AS tbl, COUNT(*) AS "rows" FROM raw.sellers
UNION ALL
SELECT 'products'             AS tbl, COUNT(*) AS "rows" FROM raw.products
UNION ALL
SELECT 'geolocation'          AS tbl, COUNT(*) AS "rows" FROM raw.geolocation
UNION ALL
SELECT 'category_translation' AS tbl, COUNT(*) AS "rows" FROM raw.category_translation;

SELECT * FROM sellers
LIMIT 10;