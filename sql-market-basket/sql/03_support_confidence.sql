-- ============================================================
-- STEP 2: Calculate Support & Confidence
-- Support    = P(A and B) = pair_freq / total_orders
-- Confidence = P(B | A)   = pair_freq / freq_A
-- ============================================================

WITH total AS (
    SELECT COUNT(DISTINCT order_id) AS n FROM orders
),
item_freq AS (
    SELECT sub_category, COUNT(DISTINCT order_id) AS freq
    FROM orders
    GROUP BY sub_category
),
pairs AS (
    SELECT 
        a.sub_category                AS product_1,
        b.sub_category                AS product_2,
        COUNT(DISTINCT a.order_id)    AS pair_freq
    FROM orders a
    JOIN orders b
        ON  a.order_id     = b.order_id
        AND a.sub_category < b.sub_category
    GROUP BY product_1, product_2
)
SELECT 
    p.product_1,
    p.product_2,
    p.pair_freq                                          AS frequency,
    ROUND(p.pair_freq * 100.0 / t.n, 2)                 AS support_pct,
    ROUND(p.pair_freq * 100.0 / f1.freq, 1)             AS confidence_pct
FROM pairs p
JOIN item_freq f1 ON f1.sub_category = p.product_1
JOIN item_freq f2 ON f2.sub_category = p.product_2
CROSS JOIN total t
ORDER BY support_pct DESC
LIMIT 20;
