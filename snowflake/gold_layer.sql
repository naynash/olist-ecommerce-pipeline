-- Verify dim_date has correct structure
SELECT
    date_id,
    full_date,
    year,
    quarter_label,
    month_name,
    is_weekend,
    year_quarter
FROM olist_db.gold.dim_date
WHERE full_date IN ('2016-01-01', '2018-06-15', '2020-12-31');

-- Verify dim_products has English category names
SELECT
    product_id,
    product_category_name,
    product_category_name_english,
    product_weight_g
FROM olist_db.gold.dim_products
LIMIT 5;

-- Verify fact_orders has date_id keys
SELECT
    order_id,
    order_status,
    order_purchase_timestamp,
    purchase_date_id,
    actual_delivery_days,
    is_on_time
FROM olist_db.gold.fact_orders
LIMIT 5;