-- ============================================================
-- PROJECT 3: Market Basket Analysis
-- Dataset: Superstore Global Sales (51,290 orders)
-- Goal: Find which products are frequently bought together
-- ============================================================

-- Verify data: orders with multiple sub-categories
SELECT 
    order_id,
    COUNT(DISTINCT sub_category) AS num_subcategories,
    COUNT(DISTINCT category)     AS num_categories
FROM orders
GROUP BY order_id
HAVING num_subcategories > 1
ORDER BY num_subcategories DESC
LIMIT 10;

-- Item frequency (how often each sub-category appears)
SELECT 
    sub_category,
    COUNT(DISTINCT order_id)                       AS order_count,
    ROUND(COUNT(DISTINCT order_id) * 100.0 / 
          (SELECT COUNT(DISTINCT order_id) FROM orders), 2) AS support_pct
FROM orders
GROUP BY sub_category
ORDER BY order_count DESC;
