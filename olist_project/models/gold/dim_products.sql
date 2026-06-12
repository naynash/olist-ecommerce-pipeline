WITH products AS (
    SELECT
        product_id,
        product_category_name,
        product_name_length,
        product_description_length,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm
    FROM olist_db.silver.stg_products
),

translation AS (
    SELECT
        product_category_name,
        product_category_name_english
    FROM olist_db.silver.stg_category_translation
)

SELECT
    p.product_id,
    COALESCE(p.product_category_name, 'uncategorized')          AS product_category_name,
    COALESCE(t.product_category_name_english,
             p.product_category_name,
             'uncategorized')                                    AS product_category_name_english,
    p.product_name_length,
    p.product_description_length,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM products p
LEFT JOIN translation t
    ON p.product_category_name = t.product_category_name