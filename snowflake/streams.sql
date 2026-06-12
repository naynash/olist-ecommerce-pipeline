-- Stream on RAW customers
CREATE OR REPLACE STREAM olist_db.raw.stream_raw_customers
    ON TABLE olist_db.raw.customers
    APPEND_ONLY = TRUE;

-- Stream on RAW sellers
CREATE OR REPLACE STREAM olist_db.raw.stream_raw_sellers
    ON TABLE olist_db.raw.sellers
    APPEND_ONLY = TRUE;

-- Stream on RAW products
CREATE OR REPLACE STREAM olist_db.raw.stream_raw_products
    ON TABLE olist_db.raw.products
    APPEND_ONLY = TRUE;

-- Stream on RAW geolocation
CREATE OR REPLACE STREAM olist_db.raw.stream_raw_geolocation
    ON TABLE olist_db.raw.geolocation
    APPEND_ONLY = TRUE;

-- Stream on RAW category_translation
CREATE OR REPLACE STREAM olist_db.raw.stream_raw_category_translation
    ON TABLE olist_db.raw.category_translation
    APPEND_ONLY = TRUE;

-- Stream on RAW orders
CREATE OR REPLACE STREAM olist_db.raw.stream_raw_orders
    ON TABLE olist_db.raw.orders
    APPEND_ONLY = TRUE;

-- Stream on RAW order_items
CREATE OR REPLACE STREAM olist_db.raw.stream_raw_order_items
    ON TABLE olist_db.raw.order_items
    APPEND_ONLY = TRUE;

-- Stream on RAW order_payments
CREATE OR REPLACE STREAM olist_db.raw.stream_raw_order_payments
    ON TABLE olist_db.raw.order_payments
    APPEND_ONLY = TRUE;

-- Stream on RAW order_reviews
CREATE OR REPLACE STREAM olist_db.raw.stream_raw_order_reviews
    ON TABLE olist_db.raw.order_reviews
    APPEND_ONLY = TRUE;

SHOW STREAMS IN DATABASE olist_db;