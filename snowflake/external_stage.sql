USE DATABASE olist_db;
USE SCHEMA raw;
USE WAREHOUSE olist_wh;

-- Transactional stages (Snowpipe will use these)
CREATE STAGE raw.stg_orders
    STORAGE_INTEGRATION = olist_s3_integration
    URL = 's3://olist-de-project-ns/raw/orders/'
    FILE_FORMAT = (
        TYPE = 'CSV'
        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
        SKIP_HEADER = 1
        NULL_IF = ('', 'NULL', 'null')
        EMPTY_FIELD_AS_NULL = TRUE
    );

CREATE STAGE raw.stg_order_items
    STORAGE_INTEGRATION = olist_s3_integration
    URL = 's3://olist-de-project-ns/raw/order_items/'
    FILE_FORMAT = (
        TYPE = 'CSV'
        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
        SKIP_HEADER = 1
        NULL_IF = ('', 'NULL', 'null')
        EMPTY_FIELD_AS_NULL = TRUE
    );

CREATE STAGE raw.stg_order_payments
    STORAGE_INTEGRATION = olist_s3_integration
    URL = 's3://olist-de-project-ns/raw/order_payments/'
    FILE_FORMAT = (
        TYPE = 'CSV'
        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
        SKIP_HEADER = 1
        NULL_IF = ('', 'NULL', 'null')
        EMPTY_FIELD_AS_NULL = TRUE
    );

CREATE STAGE raw.stg_order_reviews
    STORAGE_INTEGRATION = olist_s3_integration
    URL = 's3://olist-de-project-ns/raw/order_reviews/'
    FILE_FORMAT = (
        TYPE = 'CSV'
        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
        SKIP_HEADER = 1
        NULL_IF = ('', 'NULL', 'null')
        EMPTY_FIELD_AS_NULL = TRUE
    );

-- Reference stages (one-time COPY INTO)
CREATE STAGE raw.stg_customers
    STORAGE_INTEGRATION = olist_s3_integration
    URL = 's3://olist-de-project-ns/raw/customers/'
    FILE_FORMAT = (
        TYPE = 'CSV'
        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
        SKIP_HEADER = 1
        NULL_IF = ('', 'NULL', 'null')
        EMPTY_FIELD_AS_NULL = TRUE
    );

CREATE STAGE raw.stg_sellers
    STORAGE_INTEGRATION = olist_s3_integration
    URL = 's3://olist-de-project-ns/raw/sellers/'
    FILE_FORMAT = (
        TYPE = 'CSV'
        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
        SKIP_HEADER = 1
        NULL_IF = ('', 'NULL', 'null')
        EMPTY_FIELD_AS_NULL = TRUE
    );

CREATE STAGE raw.stg_products
    STORAGE_INTEGRATION = olist_s3_integration
    URL = 's3://olist-de-project-ns/raw/products/'
    FILE_FORMAT = (
        TYPE = 'CSV'
        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
        SKIP_HEADER = 1
        NULL_IF = ('', 'NULL', 'null')
        EMPTY_FIELD_AS_NULL = TRUE
    );

CREATE STAGE raw.stg_geolocation
    STORAGE_INTEGRATION = olist_s3_integration
    URL = 's3://olist-de-project-ns/raw/geolocation/'
    FILE_FORMAT = (
        TYPE = 'CSV'
        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
        SKIP_HEADER = 1
        NULL_IF = ('', 'NULL', 'null')
        EMPTY_FIELD_AS_NULL = TRUE
    );

CREATE STAGE raw.stg_category_translation
    STORAGE_INTEGRATION = olist_s3_integration
    URL = 's3://olist-de-project-ns/raw/category_translation/'
    FILE_FORMAT = (
        TYPE = 'CSV'
        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
        SKIP_HEADER = 1
        NULL_IF = ('', 'NULL', 'null')
        EMPTY_FIELD_AS_NULL = TRUE
    );


LIST @raw.stg_customers;
LIST @raw.stg_sellers;
LIST @raw.stg_products;