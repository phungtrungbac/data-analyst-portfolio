-- ============================================================
-- STEP 1: Aggregate customer-level metrics
-- Purpose: Build a summary per customer for segmentation
-- ============================================================

CREATE VIEW customer_summary AS
SELECT 
    customer_id,
    customer_name,
    segment                             AS customer_type,
    COUNT(DISTINCT order_id)            AS total_orders,
    ROUND(SUM(sales), 2)                AS total_spent,
    ROUND(SUM(profit), 2)               AS total_profit,
    ROUND(SUM(profit) / SUM(sales), 4)  AS profit_margin,
    ROUND(AVG(discount), 3)             AS avg_discount,
    MIN(order_date)                     AS first_order,
    MAX(order_date)                     AS last_order
FROM orders
GROUP BY customer_id, customer_name, segment;

-- Preview
SELECT * FROM customer_summary
ORDER BY total_spent DESC
LIMIT 10;
