-- ============================================================
-- FILE: sql/cleaning/01_data_cleaning.sql
-- PROJECT: E-Commerce Sales Performance Analysis
-- PURPOSE: Professional data cleaning workflow for Global Superstore
-- ANALYST: Analytics Team
-- DATE: 2024
-- ============================================================
-- BUSINESS CONTEXT:
-- Raw transactional data from the Superstore system contains
-- inconsistencies that could lead to incorrect KPI calculations.
-- This script documents and resolves all data quality issues
-- before analysis begins.
-- ============================================================

-- ============================================================
-- STEP 0: CREATE SCHEMA & LOAD RAW TABLE
-- ============================================================

CREATE SCHEMA IF NOT EXISTS superstore;

DROP TABLE IF EXISTS superstore.raw_orders;

CREATE TABLE superstore.raw_orders (
    row_id          INTEGER,
    order_id        VARCHAR(20),
    order_date      VARCHAR(20),   -- Raw: may have inconsistent formats
    ship_date       VARCHAR(20),   -- Raw: may have inconsistent formats
    ship_mode       VARCHAR(30),
    customer_id     VARCHAR(20),
    customer_name   VARCHAR(100),
    segment         VARCHAR(30),
    city            VARCHAR(100),
    state           VARCHAR(100),
    country         VARCHAR(100),
    region          VARCHAR(50),
    market          VARCHAR(50),
    product_id      VARCHAR(30),
    category        VARCHAR(50),
    sub_category    VARCHAR(50),
    product_name    VARCHAR(200),
    sales           DECIMAL(12,4),
    quantity        INTEGER,
    discount        DECIMAL(6,4),
    profit          DECIMAL(12,4),
    shipping_cost   DECIMAL(12,4),
    order_priority  VARCHAR(20)
);

-- Load data (adjust path to your environment)
-- \copy superstore.raw_orders FROM 'data/raw/superstore_raw.csv' CSV HEADER;

-- ============================================================
-- STEP 1: DATA PROFILING — UNDERSTAND BEFORE CLEANING
-- Business rationale: Never clean data you don't understand.
-- Profiling surfaces hidden quality issues that affect KPIs.
-- ============================================================

-- 1A. Row count — baseline
SELECT COUNT(*) AS total_rows FROM superstore.raw_orders;
-- Expected: ~51,290 rows

-- 1B. NULL audit — identify missing data
SELECT
    SUM(CASE WHEN order_id       IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN order_date     IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN customer_id    IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN sales          IS NULL THEN 1 ELSE 0 END) AS null_sales,
    SUM(CASE WHEN profit         IS NULL THEN 1 ELSE 0 END) AS null_profit,
    SUM(CASE WHEN discount       IS NULL THEN 1 ELSE 0 END) AS null_discount,
    SUM(CASE WHEN shipping_cost  IS NULL THEN 1 ELSE 0 END) AS null_shipping_cost,
    SUM(CASE WHEN category       IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN product_id     IS NULL THEN 1 ELSE 0 END) AS null_product_id
FROM superstore.raw_orders;

-- 1C. Value ranges — catch outliers and impossible values
SELECT
    MIN(sales)          AS min_sales,
    MAX(sales)          AS max_sales,
    AVG(sales)          AS avg_sales,
    MIN(profit)         AS min_profit,
    MAX(profit)         AS max_profit,
    AVG(profit)         AS avg_profit,
    MIN(discount)       AS min_discount,
    MAX(discount)       AS max_discount,
    MIN(quantity)       AS min_qty,
    MAX(quantity)       AS max_qty,
    MIN(shipping_cost)  AS min_ship,
    MAX(shipping_cost)  AS max_ship
FROM superstore.raw_orders;

-- 1D. Distinct value check — catch data entry anomalies
SELECT segment, COUNT(*) AS cnt FROM superstore.raw_orders GROUP BY segment ORDER BY cnt DESC;
SELECT category, COUNT(*) FROM superstore.raw_orders GROUP BY category ORDER BY 2 DESC;
SELECT ship_mode, COUNT(*) FROM superstore.raw_orders GROUP BY ship_mode ORDER BY 2 DESC;
SELECT order_priority, COUNT(*) FROM superstore.raw_orders GROUP BY order_priority ORDER BY 2 DESC;
SELECT market, COUNT(*) FROM superstore.raw_orders GROUP BY market ORDER BY 2 DESC;

-- ============================================================
-- STEP 2: DUPLICATE DETECTION
-- Business rationale: Duplicate rows inflate KPIs — a duplicate
-- order looks like double the revenue and can misguide strategy.
-- ============================================================

-- 2A. Full exact duplicates
SELECT
    order_id,
    product_id,
    order_date,
    customer_id,
    sales,
    quantity,
    COUNT(*) AS duplicate_count
FROM superstore.raw_orders
GROUP BY order_id, product_id, order_date, customer_id, sales, quantity
HAVING COUNT(*) > 1;

-- 2B. Same order, same product, different values — investigate
SELECT
    order_id,
    product_id,
    COUNT(*) AS line_count
FROM superstore.raw_orders
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;
-- Note: Multiple rows per order are expected (different products).
-- Flag only where order_id + product_id appears twice with identical quantity.

-- ============================================================
-- STEP 3: DATA VALIDITY CHECKS
-- Business rationale: Invalid data (negative sales, impossible dates)
-- silently corrupts aggregates if not caught before analysis.
-- ============================================================

-- 3A. Sales cannot be zero or negative (unless return/cancellation)
SELECT COUNT(*) AS invalid_sales
FROM superstore.raw_orders
WHERE sales <= 0;

-- 3B. Ship date must be >= Order date
SELECT COUNT(*) AS ship_before_order
FROM superstore.raw_orders
WHERE ship_date < order_date;

-- 3C. Discount must be between 0 and 1
SELECT COUNT(*) AS invalid_discount
FROM superstore.raw_orders
WHERE discount < 0 OR discount > 1;

-- 3D. Quantity must be positive
SELECT COUNT(*) AS invalid_quantity
FROM superstore.raw_orders
WHERE quantity <= 0;

-- 3E. Suspicious high-discount orders (discount >= 50%)
-- Business flag: These orders are almost always loss-making
SELECT
    order_id,
    product_name,
    category,
    sales,
    discount,
    profit,
    ROUND(profit / NULLIF(sales,0) * 100, 1) AS margin_pct
FROM superstore.raw_orders
WHERE discount >= 0.5
ORDER BY profit ASC
LIMIT 20;

-- ============================================================
-- STEP 4: STANDARDIZATION
-- Business rationale: Inconsistent formatting breaks grouping —
-- 'consumer' vs 'Consumer' appears as two different segments
-- in dashboards, causing incorrect KPI splits.
-- ============================================================

-- 4A. Trim whitespace and standardize casing
-- (Preview before applying to cleaned table)
SELECT DISTINCT
    TRIM(segment)      AS segment_clean,
    TRIM(category)     AS category_clean,
    TRIM(ship_mode)    AS ship_mode_clean,
    TRIM(order_priority) AS priority_clean
FROM superstore.raw_orders
ORDER BY 1;

-- ============================================================
-- STEP 5: CREATE CLEANED TABLE
-- Business rationale: Never overwrite raw data. Maintain the
-- audit trail — raw data is the source of truth.
-- ============================================================

DROP TABLE IF EXISTS superstore.cleaned_orders;

CREATE TABLE superstore.cleaned_orders AS
SELECT
    -- IDs & Dates
    row_id,
    TRIM(order_id)                          AS order_id,
    order_date::DATE                        AS order_date,
    ship_date::DATE                         AS ship_date,
    (ship_date::DATE - order_date::DATE)    AS days_to_ship,

    -- Customer
    TRIM(customer_id)                       AS customer_id,
    INITCAP(TRIM(customer_name))            AS customer_name,
    INITCAP(TRIM(segment))                  AS segment,

    -- Geography
    INITCAP(TRIM(city))                     AS city,
    INITCAP(TRIM(state))                    AS state,
    INITCAP(TRIM(country))                  AS country,
    UPPER(TRIM(region))                     AS region,
    UPPER(TRIM(market))                     AS market,

    -- Ship Mode & Priority
    TRIM(ship_mode)                         AS ship_mode,
    TRIM(order_priority)                    AS order_priority,

    -- Product
    TRIM(product_id)                        AS product_id,
    TRIM(category)                          AS category,
    TRIM(sub_category)                      AS sub_category,
    TRIM(product_name)                      AS product_name,

    -- Financials
    ROUND(sales::NUMERIC, 2)                AS sales,
    quantity,
    ROUND(discount::NUMERIC, 2)             AS discount,
    ROUND(profit::NUMERIC, 2)               AS profit,
    ROUND(shipping_cost::NUMERIC, 2)        AS shipping_cost,

    -- Derived Columns (added for analysis convenience)
    EXTRACT(YEAR FROM order_date::DATE)     AS order_year,
    EXTRACT(MONTH FROM order_date::DATE)    AS order_month,
    EXTRACT(QUARTER FROM order_date::DATE)  AS order_quarter,

    ROUND(
        profit::NUMERIC / NULLIF(sales::NUMERIC, 0) * 100,
    2)                                      AS profit_margin_pct,

    ROUND(sales::NUMERIC / NULLIF(quantity, 0), 2)
                                            AS revenue_per_unit,

    CASE
        WHEN discount = 0        THEN 'No Discount'
        WHEN discount <= 0.10    THEN 'Low (1-10%)'
        WHEN discount <= 0.30    THEN 'Medium (11-30%)'
        WHEN discount <= 0.50    THEN 'High (31-50%)'
        ELSE                          'Very High (>50%)'
    END                                     AS discount_band,

    -- Flag loss-making orders
    CASE WHEN profit < 0 THEN 1 ELSE 0 END AS is_loss_making

FROM superstore.raw_orders

WHERE
    -- Exclude invalid records
    sales > 0
    AND quantity > 0
    AND discount BETWEEN 0 AND 1
    AND ship_date >= order_date;

-- ============================================================
-- STEP 6: CLEANING VALIDATION — CONFIRM RESULTS
-- Business rationale: Validate that cleaning didn't accidentally
-- remove valid records or alter business-critical aggregates.
-- ============================================================

-- 6A. Row count validation
SELECT
    (SELECT COUNT(*) FROM superstore.raw_orders)     AS raw_rows,
    (SELECT COUNT(*) FROM superstore.cleaned_orders) AS cleaned_rows,
    (SELECT COUNT(*) FROM superstore.raw_orders) -
    (SELECT COUNT(*) FROM superstore.cleaned_orders) AS rows_removed;

-- 6B. Financial totals validation (should be close to raw)
SELECT
    ROUND(SUM(sales), 0)   AS total_revenue,
    ROUND(SUM(profit), 0)  AS total_profit,
    ROUND(AVG(profit_margin_pct), 2) AS avg_margin_pct
FROM superstore.cleaned_orders;

-- 6C. Derived column sanity check
SELECT
    COUNT(*) FILTER (WHERE profit_margin_pct IS NULL) AS null_margin,
    COUNT(*) FILTER (WHERE days_to_ship < 0)          AS negative_ship_days,
    COUNT(*) FILTER (WHERE is_loss_making = 1)        AS loss_making_orders
FROM superstore.cleaned_orders;

-- 6D. Year distribution — confirm 2011–2014 coverage
SELECT
    order_year,
    COUNT(*) AS orders,
    ROUND(SUM(sales), 0) AS revenue
FROM superstore.cleaned_orders
GROUP BY order_year
ORDER BY order_year;

-- ============================================================
-- CLEANING COMPLETE
-- Output: superstore.cleaned_orders (ready for analysis)
-- ============================================================
