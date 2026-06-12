# Olist E-Commerce Analytics Pipeline

An end-to-end data engineering project built on the Brazilian Olist e-commerce dataset. The goal was to design a production-style pipeline from raw data ingestion all the way to a business dashboard, using tools you'd actually find in a real data stack.

## What This Project Does

Raw CSV files land in S3, trigger Snowpipe to auto-ingest into Snowflake, get processed incrementally through Streams and Tasks, transformed by dbt Core into a star schema, and finally visualized in Power BI via DirectQuery.

```
CSV Files → S3 → Snowpipe → Raw (Bronze) → Streams & Tasks → Silver → dbt Core → Gold → Power BI
```


## Tech Stack

| Layer | Tool |
|---|---|
| Cloud Storage | AWS S3 |
| Ingestion | Snowpipe (AUTO_INGEST) |
| Data Warehouse | Snowflake |
| Incremental Processing | Snowflake Streams & Tasks |
| Transformation | dbt Core |
| Security | Snowflake RBAC, Dynamic Data Masking |
| Visualization | Power BI (DirectQuery) |


## Architecture

The pipeline follows a **Medallion architecture** with three layers:

**Bronze (Raw)** — 9 tables ingesting directly from S3. Transactional tables (orders, order_items, payments, reviews) come in via Snowpipe. Reference tables (customers, sellers, products, geolocation, category translations) were loaded once via `COPY INTO`. Every table has `_source_file` and `_loaded_at` metadata columns for auditability.

**Silver** — Owned entirely by Snowflake Streams and Tasks, not dbt. Each RAW table has a Stream tracking new rows and a Task running MERGE operations on a schedule. Transactional tasks run every 5 minutes, reference tasks daily. Dynamic data masking is applied on sensitive fields like `customer_city` and `zip_code_prefix`.

**Gold** — Built with dbt Core. A star schema with 4 fact tables and 4 dimension tables, all as views so Power BI always reflects the latest data without needing a refresh.


## Gold Layer — Star Schema

**Facts**
- `fact_orders` — order lifecycle, delivery metrics, on-time flag
- `fact_order_items` — product-level line items, pricing, freight
- `fact_payments` — payment type, installments, value
- `fact_reviews` — review scores, sentiment, timestamps

**Dimensions**
- `dim_customers`
- `dim_sellers`
- `dim_products`
- `dim_date` — date spine from 2016 to 2020, materialized as a table


## Repository Structure

```
├── olist_project/          # dbt project
│   ├── models/
│   │   └── gold/           # 8 Gold layer models
│   ├── macros/             # Custom schema name macro
│   ├── tests/
│   └── dbt_project.yml
│
├── snowflake/              # All Snowflake setup scripts
│   ├── initial_setup.sql
│   ├── create_tables_raw.sql
│   ├── external_stage.sql
│   ├── create_pipe.sql
│   ├── streams.sql
│   ├── tasks.sql
│   ├── silver_layer.sql
│   ├── gold_layer.sql
│   ├── column_masking.sql
│   └── master_load_raw.sql
│
└── PowerBI_StarSchema.png
```


## Dashboard

The Power BI dashboard has 5 pages connected via DirectQuery to the Gold layer:

1. **Executive Overview** — top-level KPIs across the business
2. **Orders & Revenue** — trends, payment methods, top categories
3. **Delivery & Operations** — on-time rate, average delays by state
4. **Seller Performance** — top sellers, geographic distribution
5. **Customer Satisfaction** — review scores, correlation with delivery delays


## Dataset

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — 100K+ orders from 2016 to 2018, with information on products, sellers, customers, payments, and reviews.


## Notes

- `profiles.yml` is excluded from this repo — connection credentials should never be committed
- `storage_integration.sql` is excluded — it contains AWS account-specific ARNs and should not be shared publicly
- Large data files are excluded via `.gitignore`
- The `analyst_role` in Snowflake has SELECT-only access to Silver and Gold schemas