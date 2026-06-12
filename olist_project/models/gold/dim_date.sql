{{ config(materialized='table') }}

WITH date_spine AS (
    SELECT
        DATEADD(day, SEQ4(), '2016-01-01'::DATE) AS date_day
    FROM TABLE(GENERATOR(ROWCOUNT => 1827))
)

SELECT
    TO_NUMBER(TO_CHAR(date_day, 'YYYYMMDD'))        AS date_id,
    date_day                                         AS full_date,
    YEAR(date_day)                                   AS year,
    QUARTER(date_day)                                AS quarter_number,
    'Q' || QUARTER(date_day)                         AS quarter_label,
    MONTH(date_day)                                  AS month_number,
    TO_CHAR(date_day, 'MMMM')                        AS month_name,
    TO_CHAR(date_day, 'MON')                         AS month_short,
    WEEKOFYEAR(date_day)                             AS week_of_year,
    DAYOFWEEK(date_day)                              AS day_of_week,
    TO_CHAR(date_day, 'DY')                          AS day_name_short,
    TO_CHAR(date_day, 'DDDD')                        AS day_of_year,
    CASE WHEN DAYOFWEEK(date_day) IN (0, 6)
         THEN TRUE ELSE FALSE END                    AS is_weekend,
    YEAR(date_day) || '-Q' || QUARTER(date_day)      AS year_quarter,
    TO_CHAR(date_day, 'YYYY-MM')                     AS year_month
FROM date_spine