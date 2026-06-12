WITH items AS (
    SELECT
        order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_limit_date,
        price,
        freight_value,
        item_total_value
    FROM olist_db.silver.stg_order_items
)

SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,

    -- Date foreign key
    TO_NUMBER(TO_CHAR(shipping_limit_date::DATE, 'YYYYMMDD'))   AS shipping_date_id,

    -- Metrics
    price,
    freight_value,
    item_total_value
FROM items
WHERE order_id IS NOT NULL