USE DATABASE olist_db;
USE SCHEMA raw;
USE WAREHOUSE olist_wh;

CREATE PIPE raw.pipe_orders
    AUTO_INGEST = TRUE
    COMMENT = 'Snowpipe for orders table — triggered by S3 SQS events'
AS
COPY INTO raw.orders (
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    _source_file
)
FROM (
    SELECT $1, $2, $3, $4, $5, $6, $7, $8,
        METADATA$FILENAME
    FROM @raw.stg_orders
);


SHOW PIPES IN SCHEMA raw;

-- Check the source file column is populated
SELECT DISTINCT _source_file FROM raw.orders;


CREATE PIPE raw.pipe_order_items
    AUTO_INGEST = TRUE
    COMMENT = 'Snowpipe for order_items table'
AS
COPY INTO raw.order_items (
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value,
    _source_file
)
FROM (
    SELECT $1, $2, $3, $4, $5, $6, $7,
        METADATA$FILENAME
    FROM @raw.stg_order_items
);

CREATE PIPE raw.pipe_order_payments
    AUTO_INGEST = TRUE
    COMMENT = 'Snowpipe for order_payments table'
AS
COPY INTO raw.order_payments (
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value,
    _source_file
)
FROM (
    SELECT $1, $2, $3, $4, $5,
        METADATA$FILENAME
    FROM @raw.stg_order_payments
);

CREATE PIPE raw.pipe_order_reviews
    AUTO_INGEST = TRUE
    COMMENT = 'Snowpipe for order_reviews table'
AS
COPY INTO raw.order_reviews (
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp,
    _source_file
)
FROM (
    SELECT $1, $2, $3, $4, $5, $6, $7,
        METADATA$FILENAME
    FROM @raw.stg_order_reviews
);


SHOW PIPES IN SCHEMA raw;


SELECT COUNT(*) FROM orders;

SELECT COUNT(*) FROM order_items;

SELECT COUNT(*) FROM order_payments;

SELECT COUNT(*) FROM order_reviews;

SELECT column_name, data_type
FROM olist_db.information_schema.columns
WHERE table_schema = 'RAW'
ORDER BY table_name, ordinal_position;