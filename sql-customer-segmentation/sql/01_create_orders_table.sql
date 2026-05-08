-- ============================================================
-- PROJECT 2: Customer Segmentation Analysis
-- Dataset: Superstore Global Sales (51,290 orders · 4,873 customers)
-- Author: [Your Name]
-- ============================================================

-- Step 0: Create base table (if importing from CSV)
CREATE TABLE IF NOT EXISTS orders (
    row_id        INTEGER,
    order_id      TEXT,
    order_date    DATE,
    ship_date     DATE,
    ship_mode     TEXT,
    customer_id   TEXT,
    customer_name TEXT,
    segment       TEXT,
    country       TEXT,
    city          TEXT,
    state         TEXT,
    region        TEXT,
    product_id    TEXT,
    category      TEXT,
    sub_category  TEXT,
    product_name  TEXT,
    sales         REAL,
    quantity      INTEGER,
    discount      REAL,
    profit        REAL
);
