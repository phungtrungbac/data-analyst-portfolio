-- ============================================================
-- STEP 3: Analyze each segment's business contribution
-- ============================================================

-- 3A. Segment summary
SELECT 
    value_segment,
    COUNT(*)                              AS num_customers,
    ROUND(SUM(total_spent), 0)            AS total_revenue,
    ROUND(AVG(total_spent), 0)            AS avg_spend_per_customer,
    ROUND(AVG(total_orders), 1)           AS avg_orders,
    ROUND(AVG(profit_margin) * 100, 1)    AS avg_margin_pct,
    ROUND(
        SUM(total_spent) * 100.0 / 
        (SELECT SUM(total_spent) FROM customer_segments), 1
    )                                     AS revenue_share_pct
FROM customer_segments
GROUP BY value_segment
ORDER BY total_revenue DESC;

-- 3B. Segment × customer_type cross-analysis
SELECT 
    value_segment,
    customer_type,
    COUNT(*)                    AS customers,
    ROUND(SUM(total_spent), 0)  AS revenue
FROM customer_segments
GROUP BY value_segment, customer_type
ORDER BY value_segment, revenue DESC;

-- 3C. Top 10 most valuable customers
SELECT 
    customer_name,
    customer_type,
    value_segment,
    total_orders,
    ROUND(total_spent, 0)   AS total_spent,
    ROUND(total_profit, 0)  AS total_profit,
    ROUND(profit_margin * 100, 1) AS margin_pct
FROM customer_segments
WHERE value_segment = 'High Value'
ORDER BY total_spent DESC
LIMIT 10;

-- 3D. Customers with high revenue but NEGATIVE profit (risk flag)
SELECT 
    customer_name,
    customer_type,
    value_segment,
    ROUND(total_spent, 0)   AS total_spent,
    ROUND(total_profit, 0)  AS total_profit,
    ROUND(avg_discount * 100, 1) AS avg_discount_pct
FROM customer_segments
WHERE total_profit < 0
ORDER BY total_profit ASC
LIMIT 10;
