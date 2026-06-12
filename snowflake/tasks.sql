-- Task for customers
CREATE OR REPLACE TASK olist_db.raw.task_merge_customers
    WAREHOUSE = olist_wh
    SCHEDULE = '1440 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('olist_db.raw.stream_raw_customers')
AS
MERGE INTO olist_db.silver.stg_customers AS target
USING (
    SELECT
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix                        AS zip_code_prefix,
        INITCAP(TRIM(customer_city))                    AS customer_city,
        UPPER(TRIM(customer_state))                     AS customer_state,
        _source_file,
        _loaded_at
    FROM olist_db.raw.stream_raw_customers
    WHERE customer_id IS NOT NULL
) AS source
ON target.customer_id = source.customer_id
WHEN MATCHED THEN UPDATE SET
    target.customer_unique_id   = source.customer_unique_id,
    target.zip_code_prefix      = source.zip_code_prefix,
    target.customer_city        = source.customer_city,
    target.customer_state       = source.customer_state,
    target._source_file         = source._source_file,
    target._loaded_at           = source._loaded_at
WHEN NOT MATCHED THEN INSERT (
    customer_id, customer_unique_id, zip_code_prefix,
    customer_city, customer_state,
    _source_file, _loaded_at
) VALUES (
    source.customer_id, source.customer_unique_id, source.zip_code_prefix,
    source.customer_city, source.customer_state,
    source._source_file, source._loaded_at
);

-- Task for sellers
CREATE OR REPLACE TASK olist_db.raw.task_merge_sellers
    WAREHOUSE = olist_wh
    SCHEDULE = '1440 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('olist_db.raw.stream_raw_sellers')
AS
MERGE INTO olist_db.silver.stg_sellers AS target
USING (
    SELECT
        seller_id,
        seller_zip_code_prefix                          AS zip_code_prefix,
        INITCAP(TRIM(seller_city))                      AS seller_city,
        UPPER(TRIM(seller_state))                       AS seller_state,
        _source_file,
        _loaded_at
    FROM olist_db.raw.stream_raw_sellers
    WHERE seller_id IS NOT NULL
) AS source
ON target.seller_id = source.seller_id
WHEN MATCHED THEN UPDATE SET
    target.zip_code_prefix  = source.zip_code_prefix,
    target.seller_city      = source.seller_city,
    target.seller_state     = source.seller_state,
    target._source_file     = source._source_file,
    target._loaded_at       = source._loaded_at
WHEN NOT MATCHED THEN INSERT (
    seller_id, zip_code_prefix, seller_city,
    seller_state, _source_file, _loaded_at
) VALUES (
    source.seller_id, source.zip_code_prefix, source.seller_city,
    source.seller_state, source._source_file, source._loaded_at
);

-- Task for products
CREATE OR REPLACE TASK olist_db.raw.task_merge_products
    WAREHOUSE = olist_wh
    SCHEDULE = '1440 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('olist_db.raw.stream_raw_products')
AS
MERGE INTO olist_db.silver.stg_products AS target
USING (
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
    FROM olist_db.raw.stream_raw_products
    WHERE product_id IS NOT NULL
) AS source
ON target.product_id = source.product_id
WHEN MATCHED THEN UPDATE SET
    target.product_category_name        = source.product_category_name,
    target.product_name_length          = source.product_name_length,
    target.product_description_length   = source.product_description_length,
    target.product_photos_qty           = source.product_photos_qty,
    target.product_weight_g             = source.product_weight_g,
    target.product_length_cm            = source.product_length_cm,
    target.product_height_cm            = source.product_height_cm,
    target.product_width_cm             = source.product_width_cm,
    target._source_file                 = source._source_file,
    target._loaded_at                   = source._loaded_at
WHEN NOT MATCHED THEN INSERT (
    product_id, product_category_name,
    product_name_length, product_description_length,
    product_photos_qty, product_weight_g,
    product_length_cm, product_height_cm, product_width_cm,
    _source_file, _loaded_at
) VALUES (
    source.product_id, source.product_category_name,
    source.product_name_length, source.product_description_length,
    source.product_photos_qty, source.product_weight_g,
    source.product_length_cm, source.product_height_cm, source.product_width_cm,
    source._source_file, source._loaded_at
);

-- Task for geolocation
CREATE OR REPLACE TASK olist_db.raw.task_merge_geolocation
    WAREHOUSE = olist_wh
    SCHEDULE = '1440 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('olist_db.raw.stream_raw_geolocation')
AS
MERGE INTO olist_db.silver.stg_geolocation AS target
USING (
    SELECT
        geolocation_zip_code_prefix                     AS zip_code_prefix,
        TRY_CAST(geolocation_lat AS FLOAT)              AS latitude,
        TRY_CAST(geolocation_lng AS FLOAT)              AS longitude,
        INITCAP(TRIM(geolocation_city))                 AS city,
        UPPER(TRIM(geolocation_state))                  AS state,
        _source_file,
        _loaded_at
    FROM olist_db.raw.stream_raw_geolocation
    WHERE geolocation_zip_code_prefix IS NOT NULL
) AS source
ON target.zip_code_prefix = source.zip_code_prefix
AND target.latitude = source.latitude
AND target.longitude = source.longitude
WHEN MATCHED THEN UPDATE SET
    target.city         = source.city,
    target.state        = source.state,
    target._source_file = source._source_file,
    target._loaded_at   = source._loaded_at
WHEN NOT MATCHED THEN INSERT (
    zip_code_prefix, latitude, longitude,
    city, state, _source_file, _loaded_at
) VALUES (
    source.zip_code_prefix, source.latitude, source.longitude,
    source.city, source.state, source._source_file, source._loaded_at
);

-- Task for category_translation
CREATE OR REPLACE TASK olist_db.raw.task_merge_category_translation
    WAREHOUSE = olist_wh
    SCHEDULE = '1440 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('olist_db.raw.stream_raw_category_translation')
AS
MERGE INTO olist_db.silver.stg_category_translation AS target
USING (
    SELECT
        LOWER(TRIM(product_category_name))              AS product_category_name,
        LOWER(TRIM(product_category_name_english))      AS product_category_name_english,
        _source_file,
        _loaded_at
    FROM olist_db.raw.stream_raw_category_translation
    WHERE product_category_name IS NOT NULL
) AS source
ON target.product_category_name = source.product_category_name
WHEN MATCHED THEN UPDATE SET
    target.product_category_name_english    = source.product_category_name_english,
    target._source_file                     = source._source_file,
    target._loaded_at                       = source._loaded_at
WHEN NOT MATCHED THEN INSERT (
    product_category_name, product_category_name_english,
    _source_file, _loaded_at
) VALUES (
    source.product_category_name, source.product_category_name_english,
    source._source_file, source._loaded_at
);

-- Task for orders
CREATE OR REPLACE TASK olist_db.raw.task_merge_orders
    WAREHOUSE = olist_wh
    SCHEDULE = '5 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('olist_db.raw.stream_raw_orders')
AS
MERGE INTO olist_db.silver.stg_orders AS target
USING (
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
    FROM olist_db.raw.stream_raw_orders
    WHERE order_id IS NOT NULL
) AS source
ON target.order_id = source.order_id
WHEN MATCHED THEN UPDATE SET
    target.order_status                     = source.order_status,
    target.order_approved_at                = source.order_approved_at,
    target.order_delivered_carrier_date     = source.order_delivered_carrier_date,
    target.order_delivered_customer_date    = source.order_delivered_customer_date,
    target.order_estimated_delivery_date    = source.order_estimated_delivery_date,
    target.hours_to_approval                = source.hours_to_approval,
    target.actual_delivery_days             = source.actual_delivery_days,
    target.estimated_delivery_days          = source.estimated_delivery_days,
    target.delivery_delta_days              = source.delivery_delta_days,
    target.is_on_time                       = source.is_on_time,
    target._source_file                     = source._source_file,
    target._loaded_at                       = source._loaded_at
WHEN NOT MATCHED THEN INSERT (
    order_id, customer_id, order_status,
    order_purchase_timestamp, order_approved_at,
    order_delivered_carrier_date, order_delivered_customer_date,
    order_estimated_delivery_date, hours_to_approval,
    actual_delivery_days, estimated_delivery_days,
    delivery_delta_days, is_on_time,
    _source_file, _loaded_at
) VALUES (
    source.order_id, source.customer_id, source.order_status,
    source.order_purchase_timestamp, source.order_approved_at,
    source.order_delivered_carrier_date, source.order_delivered_customer_date,
    source.order_estimated_delivery_date, source.hours_to_approval,
    source.actual_delivery_days, source.estimated_delivery_days,
    source.delivery_delta_days, source.is_on_time,
    source._source_file, source._loaded_at
);

-- Task for order_items
CREATE OR REPLACE TASK olist_db.raw.task_merge_order_items
    WAREHOUSE = olist_wh
    SCHEDULE = '5 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('olist_db.raw.stream_raw_order_items')
AS
MERGE INTO olist_db.silver.stg_order_items AS target
USING (
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
    FROM olist_db.raw.stream_raw_order_items
    WHERE order_id IS NOT NULL
      AND order_item_id IS NOT NULL
) AS source
ON target.order_id = source.order_id
AND target.order_item_id = source.order_item_id
WHEN MATCHED THEN UPDATE SET
    target.product_id           = source.product_id,
    target.seller_id            = source.seller_id,
    target.shipping_limit_date  = source.shipping_limit_date,
    target.price                = source.price,
    target.freight_value        = source.freight_value,
    target.item_total_value     = source.item_total_value,
    target._source_file         = source._source_file,
    target._loaded_at           = source._loaded_at
WHEN NOT MATCHED THEN INSERT (
    order_id, order_item_id, product_id, seller_id,
    shipping_limit_date, price, freight_value, item_total_value,
    _source_file, _loaded_at
) VALUES (
    source.order_id, source.order_item_id, source.product_id, source.seller_id,
    source.shipping_limit_date, source.price, source.freight_value, source.item_total_value,
    source._source_file, source._loaded_at
);

-- Task for order_payments
CREATE OR REPLACE TASK olist_db.raw.task_merge_order_payments
    WAREHOUSE = olist_wh
    SCHEDULE = '5 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('olist_db.raw.stream_raw_order_payments')
AS
MERGE INTO olist_db.silver.stg_order_payments AS target
USING (
    SELECT
        order_id,
        TRY_CAST(payment_sequential AS INT)             AS payment_sequential,
        LOWER(TRIM(payment_type))                       AS payment_type,
        TRY_CAST(payment_installments AS INT)           AS payment_installments,
        TRY_CAST(payment_value AS FLOAT)                AS payment_value,
        _source_file,
        _loaded_at
    FROM olist_db.raw.stream_raw_order_payments
    WHERE order_id IS NOT NULL
) AS source
ON target.order_id = source.order_id
AND target.payment_sequential = source.payment_sequential
WHEN MATCHED THEN UPDATE SET
    target.payment_type         = source.payment_type,
    target.payment_installments = source.payment_installments,
    target.payment_value        = source.payment_value,
    target._source_file         = source._source_file,
    target._loaded_at           = source._loaded_at
WHEN NOT MATCHED THEN INSERT (
    order_id, payment_sequential, payment_type,
    payment_installments, payment_value,
    _source_file, _loaded_at
) VALUES (
    source.order_id, source.payment_sequential, source.payment_type,
    source.payment_installments, source.payment_value,
    source._source_file, source._loaded_at
);

-- Task for order_reviews
CREATE OR REPLACE TASK olist_db.raw.task_merge_order_reviews
    WAREHOUSE = olist_wh
    SCHEDULE = '5 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('olist_db.raw.stream_raw_order_reviews')
AS
MERGE INTO olist_db.silver.stg_order_reviews AS target
USING (
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
    FROM olist_db.raw.stream_raw_order_reviews
    WHERE review_id IS NOT NULL
      AND order_id IS NOT NULL
) AS source
ON target.review_id = source.review_id
WHEN MATCHED THEN UPDATE SET
    target.order_id                 = source.order_id,
    target.review_score             = source.review_score,
    target.review_comment_title     = source.review_comment_title,
    target.review_comment_message   = source.review_comment_message,
    target.review_creation_date     = source.review_creation_date,
    target.review_answer_timestamp  = source.review_answer_timestamp,
    target.review_sentiment         = source.review_sentiment,
    target._source_file             = source._source_file,
    target._loaded_at               = source._loaded_at
WHEN NOT MATCHED THEN INSERT (
    review_id, order_id, review_score,
    review_comment_title, review_comment_message,
    review_creation_date, review_answer_timestamp,
    review_sentiment, _source_file, _loaded_at
) VALUES (
    source.review_id, source.order_id, source.review_score,
    source.review_comment_title, source.review_comment_message,
    source.review_creation_date, source.review_answer_timestamp,
    source.review_sentiment, source._source_file, source._loaded_at
);


ALTER TASK olist_db.raw.task_merge_orders RESUME;
ALTER TASK olist_db.raw.task_merge_order_items RESUME;
ALTER TASK olist_db.raw.task_merge_order_payments RESUME;
ALTER TASK olist_db.raw.task_merge_order_reviews RESUME;
ALTER TASK olist_db.raw.TASK_MERGE_CATEGORY_TRANSLATION RESUME;
ALTER TASK olist_db.raw.TASK_MERGE_CUSTOMERS RESUME;
ALTER TASK olist_db.raw.TASK_MERGE_GEOLOCATION RESUME;
ALTER TASK olist_db.raw.TASK_MERGE_PRODUCTS RESUME;
ALTER TASK olist_db.raw.TASK_MERGE_SELLERS RESUME;

SHOW TASKS IN DATABASE olist_db;