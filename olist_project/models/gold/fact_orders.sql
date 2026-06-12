WITH orders AS (
    SELECT
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date,
        hours_to_approval,
        actual_delivery_days,
        estimated_delivery_days,
        delivery_delta_days,
        is_on_time
    FROM olist_db.silver.stg_orders
)

SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,

    -- Date foreign keys for dim_date joins
    TO_NUMBER(TO_CHAR(order_purchase_timestamp::DATE, 'YYYYMMDD'))          AS purchase_date_id,
    TO_NUMBER(TO_CHAR(order_delivered_customer_date::DATE, 'YYYYMMDD'))     AS delivered_date_id,

    -- Metrics
    hours_to_approval,
    actual_delivery_days,
    estimated_delivery_days,
    delivery_delta_days,
    is_on_time
FROM orders
WHERE order_id IS NOT NULL
AND order_purchase_timestamp IS NOT NULL