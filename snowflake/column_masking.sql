-- Create the role
CREATE ROLE IF NOT EXISTS analyst_role;

-- Grant usage on database and schemas
GRANT USAGE ON DATABASE olist_db TO ROLE analyst_role;
GRANT USAGE ON SCHEMA olist_db.silver TO ROLE analyst_role;
GRANT USAGE ON SCHEMA olist_db.gold TO ROLE analyst_role;

-- Grant select on all silver tables
GRANT SELECT ON ALL TABLES IN SCHEMA olist_db.silver TO ROLE analyst_role;

-- Grant select on all gold views
GRANT SELECT ON ALL VIEWS IN SCHEMA olist_db.gold TO ROLE analyst_role;
GRANT SELECT ON TABLE olist_db.gold.dim_date TO ROLE analyst_role;

-- Grant warehouse usage
GRANT USAGE ON WAREHOUSE olist_wh TO ROLE analyst_role;

-- Assign role to your user
GRANT ROLE analyst_role TO USER SHEVKARINAYNA;



-- City masking policy — full mask
CREATE OR REPLACE MASKING POLICY olist_db.silver.mask_city
    AS (val VARCHAR) RETURNS VARCHAR ->
    CASE
        WHEN CURRENT_ROLE() = 'ACCOUNTADMIN' THEN val
        ELSE '***'
    END;

-- State masking policy — full mask
CREATE OR REPLACE MASKING POLICY olist_db.silver.mask_state
    AS (val VARCHAR) RETURNS VARCHAR ->
    CASE
        WHEN CURRENT_ROLE() = 'ACCOUNTADMIN' THEN val
        ELSE '***'
    END;

-- Zip code masking policy — partial mask (show first 3, mask last 2)
CREATE OR REPLACE MASKING POLICY olist_db.silver.mask_zip_code
    AS (val VARCHAR) RETURNS VARCHAR ->
    CASE
        WHEN CURRENT_ROLE() = 'ACCOUNTADMIN' THEN val
        ELSE LEFT(val, 3) || '**'
    END;


-- Mask customer_city
ALTER TABLE olist_db.silver.stg_customers
    MODIFY COLUMN customer_city
    SET MASKING POLICY olist_db.silver.mask_city;

-- Mask customer_state
ALTER TABLE olist_db.silver.stg_customers
    MODIFY COLUMN customer_state
    SET MASKING POLICY olist_db.silver.mask_state;

-- Mask zip_code_prefix
ALTER TABLE olist_db.silver.stg_customers
    MODIFY COLUMN zip_code_prefix
    SET MASKING POLICY olist_db.silver.mask_zip_code;

-- Mask seller_city
ALTER TABLE olist_db.silver.stg_sellers
    MODIFY COLUMN seller_city
    SET MASKING POLICY olist_db.silver.mask_city;

-- Mask seller_state
ALTER TABLE olist_db.silver.stg_sellers
    MODIFY COLUMN seller_state
    SET MASKING POLICY olist_db.silver.mask_state;

-- Mask zip_code_prefix
ALTER TABLE olist_db.silver.stg_sellers
    MODIFY COLUMN zip_code_prefix
    SET MASKING POLICY olist_db.silver.mask_zip_code;

-- As ACCOUNTADMIN — should see real data
USE ROLE ACCOUNTADMIN;
SELECT customer_id, customer_city, customer_state, zip_code_prefix
FROM olist_db.silver.stg_customers
LIMIT 5;

-- Switch to analyst_role — should see masked data
USE ROLE analyst_role;
SELECT customer_id, customer_city, customer_state, zip_code_prefix
FROM olist_db.silver.stg_customers
LIMIT 5;

-- Switch back
USE ROLE ACCOUNTADMIN;


UPDATE olist_db.silver.stg_category_translation
SET PRODUCT_CATEGORY_NAME_ENGLISH = 'health_beautyy'
WHERE PRODUCT_CATEGORY_NAME = 'beleza_saude';


USE SECONDARY ROLES NONE;
USE ROLE analyst_role;

SELECT customer_city, customer_state, zip_code_prefix
FROM olist_db.silver.stg_customers
LIMIT 5;

SELECT * FROM stg_sellers
LIMIT 5;