-- ============================================================
-- STEP 2: RFM-inspired segmentation using total spend
-- Thresholds derived from dataset quartiles:
--   High Value  : total_spent >= $3,763  (top 25%)
--   Mid Value   : $728 <= total_spent < $3,763 (middle 50%)
--   Low Value   : total_spent < $728  (bottom 25%)
-- ============================================================

CREATE VIEW customer_segments AS
SELECT
    customer_id,
    customer_name,
    customer_type,
    total_orders,
    total_spent,
    total_profit,
    profit_margin,
    avg_discount,
    CASE 
        WHEN total_spent >= 3763 THEN 'High Value'
        WHEN total_spent >= 728  THEN 'Mid Value'
        ELSE                          'Low Value'
    END AS value_segment
FROM customer_summary;

-- Preview distribution
SELECT value_segment, COUNT(*) AS num_customers
FROM customer_segments
GROUP BY value_segment
ORDER BY num_customers DESC;
