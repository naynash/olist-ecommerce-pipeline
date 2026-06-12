-- Step 1: Create warehouse
CREATE WAREHOUSE olist_wh
  WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  COMMENT = 'Main warehouse for olist project';

-- Step 2: Create database
CREATE DATABASE olist_db;

-- Step 3: Create schemas (one per layer)
CREATE SCHEMA olist_db.raw;
CREATE SCHEMA olist_db.silver;
CREATE SCHEMA olist_db.gold;

-- Step 4: Use the warehouse and database
USE WAREHOUSE olist_wh;
USE DATABASE olist_dbi


