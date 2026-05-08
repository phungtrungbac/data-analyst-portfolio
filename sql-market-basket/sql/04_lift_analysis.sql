-- ============================================================
-- STEP 3: Add LIFT — the most important metric
-- Lift = Support(A,B) / (Support(A) * Support(B))
-- Lift > 1.0 = truly non-random association (genuine affinity)
-- Lift = 1.0 = random co-occurrence
-- Lift < 1.0 = substitutes (buying one means less likely to buy other)
-- ============================================================

WITH total AS (
    SELECT COUNT(DISTINCT order_id) AS n FROM orders
),
item_support AS (
    SELECT 
        sub_category,
        COUNT(DISTINCT order_id) AS freq,
        COUNT(DISTINCT order_id) * 1.0 / (SELECT n FROM total) AS support
    FROM orders
    GROUP BY sub_category
),
pairs AS (
    SELECT 
        a.sub_category              AS product_1,
        b.sub_category              AS product_2,
        COUNT(DISTINCT a.order_id)  AS pair_freq
    FROM orders a
    JOIN orders b
        ON a.order_id = b.order_id AND a.sub_category < b.sub_category
    GROUP BY product_1, product_2
)
SELECT 
    p.product_1,
    p.product_2,
    p.pair_freq                                                          AS frequency,
    ROUND(p.pair_freq * 100.0 / t.n, 2)                                 AS support_pct,
    ROUND(p.pair_freq * 100.0 / s1.freq, 1)                             AS confidence_pct,
    ROUND((p.pair_freq * 1.0 / t.n) / (s1.support * s2.support), 2)    AS lift
FROM pairs p
JOIN item_support s1 ON s1.sub_category = p.product_1
JOIN item_support s2 ON s2.sub_category = p.product_2
CROSS JOIN total t
ORDER BY lift DESC
LIMIT 20;
