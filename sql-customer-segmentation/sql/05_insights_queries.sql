-- ============================================================
-- STEP 4: Business Insight Queries
-- Use these to back up the findings in your README
-- ============================================================

-- INSIGHT 1: High-value customers are few but drive most revenue
-- Result: 1,219 customers (25%) → $7.37M (58.3% of revenue)
SELECT 
    value_segment,
    COUNT(*) AS customers,
    ROUND(SUM(total_spent)/1000000.0, 2) AS revenue_M,
    ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM customer_segments), 1) AS pct_customers,
    ROUND(SUM(total_spent)*100.0/(SELECT SUM(total_spent) FROM customer_segments), 1) AS pct_revenue
FROM customer_segments
GROUP BY value_segment;

-- INSIGHT 2: Low-value customers show high discount sensitivity
-- Higher avg_discount correlates with lower profit margin
SELECT 
    value_segment,
    ROUND(AVG(avg_discount)*100, 1)  AS avg_discount_pct,
    ROUND(AVG(profit_margin)*100, 1) AS avg_margin_pct
FROM customer_segments
GROUP BY value_segment;

-- INSIGHT 3: Mid-value segment — biggest upsell opportunity
-- 2,436 customers averaging $2,005 spend — room to push to High Value
SELECT 
    customer_name, customer_type, total_orders, 
    ROUND(total_spent,0) AS total_spent,
    ROUND(3763 - total_spent, 0) AS gap_to_high_value
FROM customer_segments
WHERE value_segment = 'Mid Value'
ORDER BY total_spent DESC
LIMIT 15;
