WITH reviews AS (
    SELECT
        review_id,
        order_id,
        review_score,
        review_comment_title,
        review_comment_message,
        review_creation_date,
        review_answer_timestamp,
        review_sentiment
    FROM olist_db.silver.stg_order_reviews
)

SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp,
    review_sentiment,

    -- Date foreign key
    TO_NUMBER(TO_CHAR(review_creation_date::DATE, 'YYYYMMDD'))  AS review_date_id
FROM reviews
WHERE review_id IS NOT NULL