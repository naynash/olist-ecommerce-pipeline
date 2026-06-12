-- Master Data
-- 1. Customers
CREATE OR REPLACE TABLE olist_db.silver.stg_customers (
    customer_id                 VARCHAR,
    customer_unique_id          VARCHAR,
    zip_code_prefix             VARCHAR,
    customer_city               VARCHAR,
    customer_state              VARCHAR,
    _source_file                VARCHAR,
    _loaded_at                  TIMESTAMP_NTZ
);

-- 2. Sellers
CREATE OR REPLACE TABLE olist_db.silver.stg_sellers (
    seller_id                   VARCHAR,
    zip_code_prefix             VARCHAR,
    seller_city                 VARCHAR,
    seller_state                VARCHAR,
    _source_file                VARCHAR,
    _loaded_at                  TIMESTAMP_NTZ
);

-- 3. Products
CREATE OR REPLACE TABLE olist_db.silver.stg_products (
    product_id                  VARCHAR,
    product_category_name       VARCHAR,
    product_name_length         INT,
    product_description_length  INT,
    product_photos_qty          INT,
    product_weight_g            FLOAT,
    product_length_cm           FLOAT,
    product_height_cm           FLOAT,
    product_width_cm            FLOAT,
    _source_file                VARCHAR,
    _loaded_at                  TIMESTAMP_NTZ
);

-- 4. Geolocation
CREATE OR REPLACE TABLE olist_db.silver.stg_geolocation (
    zip_code_prefix             VARCHAR,
    latitude                    FLOAT,
    longitude                   FLOAT,
    city                        VARCHAR,
    state                       VARCHAR,
    _source_file                VARCHAR,
    _loaded_at                  TIMESTAMP_NTZ
);

-- 5. Category Translation
CREATE OR REPLACE TABLE olist_db.silver.stg_category_translation (
    product_category_name           VARCHAR,
    product_category_name_english   VARCHAR,
    _source_file                    VARCHAR,
    _loaded_at                      TIMESTAMP_NTZ
);

-- Transactional data
-- 6. Orders
CREATE OR REPLACE TABLE olist_db.silver.stg_orders (
    order_id                        VARCHAR,
    customer_id                     VARCHAR,
    order_status                    VARCHAR,
    order_purchase_timestamp        TIMESTAMP_NTZ,
    order_approved_at               TIMESTAMP_NTZ,
    order_delivered_carrier_date    TIMESTAMP_NTZ,
    order_delivered_customer_date   TIMESTAMP_NTZ,
    order_estimated_delivery_date   TIMESTAMP_NTZ,
    hours_to_approval               INT,
    actual_delivery_days            INT,
    estimated_delivery_days         INT,
    delivery_delta_days             INT,
    is_on_time                      BOOLEAN,
    _source_file                    VARCHAR,
    _loaded_at                      TIMESTAMP_NTZ
);

-- 7. Order Items
CREATE OR REPLACE TABLE olist_db.silver.stg_order_items (
    order_id                        VARCHAR,
    order_item_id                   INT,
    product_id                      VARCHAR,
    seller_id                       VARCHAR,
    shipping_limit_date             TIMESTAMP_NTZ,
    price                           FLOAT,
    freight_value                   FLOAT,
    item_total_value                FLOAT,
    _source_file                    VARCHAR,
    _loaded_at                      TIMESTAMP_NTZ
);

-- 8. Order Payments
CREATE OR REPLACE TABLE olist_db.silver.stg_order_payments (
    order_id                        VARCHAR,
    payment_sequential              INT,
    payment_type                    VARCHAR,
    payment_installments            INT,
    payment_value                   FLOAT,
    _source_file                    VARCHAR,
    _loaded_at                      TIMESTAMP_NTZ
);

-- 9. Order Reviews
CREATE OR REPLACE TABLE olist_db.silver.stg_order_reviews (
    review_id                       VARCHAR,
    order_id                        VARCHAR,
    review_score                    INT,
    review_comment_title            VARCHAR,
    review_comment_message          VARCHAR,
    review_creation_date            TIMESTAMP_NTZ,
    review_answer_timestamp         TIMESTAMP_NTZ,
    review_sentiment                VARCHAR,
    _source_file                    VARCHAR,
    _loaded_at                      TIMESTAMP_NTZ
);


-- Master data load - one-time insert into select
-- 1. Customers
INSERT INTO olist_db.silver.stg_customers
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix                        AS zip_code_prefix,
    INITCAP(TRIM(customer_city))                    AS customer_city,
    UPPER(TRIM(customer_state))                     AS customer_state,
    _source_file,
    _loaded_at
FROM olist_db.raw.customers
WHERE customer_id IS NOT NULL;

-- 2. Sellers
INSERT INTO olist_db.silver.stg_sellers
SELECT
    seller_id,
    seller_zip_code_prefix                          AS zip_code_prefix,
    INITCAP(TRIM(seller_city))                      AS seller_city,
    UPPER(TRIM(seller_state))                       AS seller_state,
    _source_file,
    _loaded_at
FROM olist_db.raw.sellers
WHERE seller_id IS NOT NULL;

-- 3. Products
INSERT INTO olist_db.silver.stg_products
SELECT
    product_id,
    LOWER(TRIM(product_category_name))              AS product_category_name,
    TRY_CAST(product_name_lenght AS INT)            AS product_name_length,
    TRY_CAST(product_description_lenght AS INT)     AS product_description_length,
    TRY_CAST(product_photos_qty AS INT)             AS product_photos_qty,
    TRY_CAST(product_weight_g AS FLOAT)             AS product_weight_g,
    TRY_CAST(product_length_cm AS FLOAT)            AS product_length_cm,
    TRY_CAST(product_height_cm AS FLOAT)            AS product_height_cm,
    TRY_CAST(product_width_cm AS FLOAT)             AS product_width_cm,
    _source_file,
    _loaded_at
FROM olist_db.raw.products
WHERE product_id IS NOT NULL;

-- 4. Geolocation
INSERT INTO olist_db.silver.stg_geolocation
SELECT
    geolocation_zip_code_prefix                     AS zip_code_prefix,
    TRY_CAST(geolocation_lat AS FLOAT)              AS latitude,
    TRY_CAST(geolocation_lng AS FLOAT)              AS longitude,
    INITCAP(TRIM(geolocation_city))                 AS city,
    UPPER(TRIM(geolocation_state))                  AS state,
    _source_file,
    _loaded_at
FROM olist_db.raw.geolocation
WHERE geolocation_zip_code_prefix IS NOT NULL;

-- 5. Category Translation
INSERT INTO olist_db.silver.stg_category_translation
SELECT
    LOWER(TRIM(product_category_name))              AS product_category_name,
    LOWER(TRIM(product_category_name_english))      AS product_category_name_english,
    _source_file,
    _loaded_at
FROM olist_db.raw.category_translation
WHERE product_category_name IS NOT NULL;

-- Transactional Tables — Initial Load from RAW
-- 6. Orders
INSERT INTO olist_db.silver.stg_orders
SELECT
    order_id,
    customer_id,
    LOWER(TRIM(order_status))                                           AS order_status,
    TRY_CAST(order_purchase_timestamp AS TIMESTAMP_NTZ)                AS order_purchase_timestamp,
    TRY_CAST(order_approved_at AS TIMESTAMP_NTZ)                       AS order_approved_at,
    TRY_CAST(order_delivered_carrier_date AS TIMESTAMP_NTZ)            AS order_delivered_carrier_date,
    TRY_CAST(order_delivered_customer_date AS TIMESTAMP_NTZ)           AS order_delivered_customer_date,
    TRY_CAST(order_estimated_delivery_date AS TIMESTAMP_NTZ)           AS order_estimated_delivery_date,
    DATEDIFF('hour',
        TRY_CAST(order_purchase_timestamp AS TIMESTAMP_NTZ),
        TRY_CAST(order_approved_at AS TIMESTAMP_NTZ))                  AS hours_to_approval,
    DATEDIFF('day',
        TRY_CAST(order_purchase_timestamp AS TIMESTAMP_NTZ),
        TRY_CAST(order_delivered_customer_date AS TIMESTAMP_NTZ))      AS actual_delivery_days,
    DATEDIFF('day',
        TRY_CAST(order_purchase_timestamp AS TIMESTAMP_NTZ),
        TRY_CAST(order_estimated_delivery_date AS TIMESTAMP_NTZ))      AS estimated_delivery_days,
    DATEDIFF('day',
        TRY_CAST(order_delivered_customer_date AS TIMESTAMP_NTZ),
        TRY_CAST(order_estimated_delivery_date AS TIMESTAMP_NTZ))      AS delivery_delta_days,
    CASE
        WHEN TRY_CAST(order_delivered_customer_date AS TIMESTAMP_NTZ)
             <= TRY_CAST(order_estimated_delivery_date AS TIMESTAMP_NTZ)
        THEN TRUE ELSE FALSE
    END                                                                 AS is_on_time,
    _source_file,
    _loaded_at
FROM olist_db.raw.orders
WHERE order_id IS NOT NULL;

-- 7. Order Items
INSERT INTO olist_db.silver.stg_order_items
SELECT
    order_id,
    TRY_CAST(order_item_id AS INT)                  AS order_item_id,
    product_id,
    seller_id,
    TRY_CAST(shipping_limit_date AS TIMESTAMP_NTZ)  AS shipping_limit_date,
    TRY_CAST(price AS FLOAT)                        AS price,
    TRY_CAST(freight_value AS FLOAT)                AS freight_value,
    TRY_CAST(price AS FLOAT)
        + TRY_CAST(freight_value AS FLOAT)          AS item_total_value,
    _source_file,
    _loaded_at
FROM olist_db.raw.order_items
WHERE order_id IS NOT NULL
  AND order_item_id IS NOT NULL;

-- 8. Order Payments
INSERT INTO olist_db.silver.stg_order_payments
SELECT
    order_id,
    TRY_CAST(payment_sequential AS INT)             AS payment_sequential,
    LOWER(TRIM(payment_type))                       AS payment_type,
    TRY_CAST(payment_installments AS INT)           AS payment_installments,
    TRY_CAST(payment_value AS FLOAT)                AS payment_value,
    _source_file,
    _loaded_at
FROM olist_db.raw.order_payments
WHERE order_id IS NOT NULL;

-- 9. Order Reviews
INSERT INTO olist_db.silver.stg_order_reviews
SELECT
    review_id,
    order_id,
    TRY_CAST(review_score AS INT)                           AS review_score,
    NULLIF(TRIM(review_comment_title), '')                  AS review_comment_title,
    NULLIF(TRIM(review_comment_message), '')                AS review_comment_message,
    TRY_CAST(review_creation_date AS TIMESTAMP_NTZ)        AS review_creation_date,
    TRY_CAST(review_answer_timestamp AS TIMESTAMP_NTZ)     AS review_answer_timestamp,
    CASE
        WHEN TRY_CAST(review_score AS INT) >= 4 THEN 'positive'
        WHEN TRY_CAST(review_score AS INT) = 3  THEN 'neutral'
        WHEN TRY_CAST(review_score AS INT) <= 2 THEN 'negative'
        ELSE NULL
    END                                                     AS review_sentiment,
    _source_file,
    _loaded_at
FROM olist_db.raw.order_reviews
WHERE review_id IS NOT NULL
  AND order_id IS NOT NULL;

SELECT 'stg_customers'          AS table_name, COUNT(*) AS row_count FROM olist_db.silver.stg_customers
UNION ALL
SELECT 'stg_sellers',           COUNT(*) FROM olist_db.silver.stg_sellers
UNION ALL
SELECT 'stg_products',          COUNT(*) FROM olist_db.silver.stg_products
UNION ALL
SELECT 'stg_geolocation',       COUNT(*) FROM olist_db.silver.stg_geolocation
UNION ALL
SELECT 'stg_category_translation', COUNT(*) FROM olist_db.silver.stg_category_translation
UNION ALL
SELECT 'stg_orders',            COUNT(*) FROM olist_db.silver.stg_orders
UNION ALL
SELECT 'stg_order_items',       COUNT(*) FROM olist_db.silver.stg_order_items
UNION ALL
SELECT 'stg_order_payments',    COUNT(*) FROM olist_db.silver.stg_order_payments
UNION ALL
SELECT 'stg_order_reviews',     COUNT(*) FROM olist_db.silver.stg_order_reviews
ORDER BY table_name;

INSERT INTO olist_db.silver.stg_category_translation
(product_category_name, product_category_name_english, _source_file, _loaded_at)
VALUES
('portateis_cozinha_e_preparadores_de_alimentos', 'portable_kitchen_food_preparers', 'manual_insert', CURRENT_TIMESTAMP()),
('pc_gamer', 'pc_gamer', 'manual_insert', CURRENT_TIMESTAMP());

SELECT 
    query_id,
    query_text,
    start_time
FROM TABLE(information_schema.query_history())
WHERE query_text ILIKE '%portateis_cozinha%'
ORDER BY start_time DESC
LIMIT 5;

SELECT * FROM olist_db.silver.stg_category_translation LIMIT 1;

-- Verify the state before the insert
SELECT COUNT(*) 
FROM olist_db.silver.stg_category_translation
BEFORE (STATEMENT => '01c4f599-0001-fa23-001c-f77700039c8a');

CREATE OR REPLACE TABLE olist_db.silver.stg_category_translation
AS
SELECT * FROM olist_db.silver.stg_category_translation
BEFORE (STATEMENT => '01c4f599-0001-fa23-001c-f77700039c8a');

SELECT COUNT(*) FROM olist_db.silver.stg_orders;

SELECT COUNT(*) FROM olist_db.raw.orders;

SELECT COUNT(*) FROM olist_db.gold.fact_orders;


SELECT * FROM olist_db.raw.orders
WHERE ORDER_ID NOT IN (SELECT ORDER_ID FROM olist_db.gold.fact_orders);


SELECT * FROM olist_db.gold.fact_orders
LIMIT 1;

SELECT order_id, order_purchase_timestamp 
FROM olist_db.silver.stg_orders
WHERE order_id IN (
    'e5fa5a7210941f7d56d0208e4e071d35',
    '2e7a8482f6fb09756ca50c10d7bfc047',
    '809a282bbd5dbcabb6f2f724fca862ec',
    'bfbd0f9bdef84302105ad712db648a6c'
);

SELECT 
    order_id,
    order_purchase_timestamp,
    typeof(order_purchase_timestamp) as data_type
FROM olist_db.raw.orders
WHERE order_id IN (
    'e5fa5a7210941f7d56d0208e4e071d35',
    '2e7a8482f6fb09756ca50c10d7bfc047',
    '809a282bbd5dbcabb6f2f724fca862ec',
    'bfbd0f9bdef84302105ad712db648a6c'
);

SELECT 
    order_id,
    order_purchase_timestamp,
    _source_file
FROM olist_db.raw.orders
WHERE order_id IN (
    'e5fa5a7210941f7d56d0208e4e071d35',
    '2e7a8482f6fb09756ca50c10d7bfc047',
    '809a282bbd5dbcabb6f2f724fca862ec',
    'bfbd0f9bdef84302105ad712db648a6c'
);


SELECT COUNT(*) 
FROM olist_db.silver.stg_orders s
JOIN olist_db.raw.orders r ON s.order_id = r.order_id
WHERE r._source_file LIKE '%q3%'
AND s.order_purchase_timestamp IS NULL;

SELECT COUNT(*) 
FROM olist_db.silver.stg_orders s
JOIN olist_db.raw.orders r ON s.order_id = r.order_id
WHERE r._source_file LIKE '%q3%';
