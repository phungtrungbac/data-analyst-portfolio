-- ============================================================
-- STEP 4: Category-level basket analysis
-- Broader view: which top-level categories go together?
-- ============================================================

WITH total AS (SELECT COUNT(DISTINCT order_id) AS n FROM orders)
SELECT 
    a.category                          AS category_1,
    b.category                          AS category_2,
    COUNT(DISTINCT a.order_id)          AS frequency,
    ROUND(COUNT(DISTINCT a.order_id) * 100.0 / t.n, 1) AS support_pct
FROM orders a
JOIN orders b
    ON  a.order_id = b.order_id
    AND a.category < b.category
CROSS JOIN total t
GROUP BY category_1, category_2
ORDER BY frequency DESC;

-- ============================================================
-- STEP 5: Bundle recommendations — top pairs per anchor product
-- Which sub-category should you bundle WITH Binders?
-- ============================================================

WITH total AS (SELECT COUNT(DISTINCT order_id) AS n FROM orders),
item_support AS (
    SELECT sub_category, COUNT(DISTINCT order_id) AS freq,
           COUNT(DISTINCT order_id)*1.0/(SELECT n FROM total) AS support
    FROM orders GROUP BY sub_category
),
pairs AS (
    SELECT a.sub_category AS p1, b.sub_category AS p2,
           COUNT(DISTINCT a.order_id) AS pair_freq
    FROM orders a JOIN orders b
        ON a.order_id = b.order_id AND a.sub_category < b.sub_category
    GROUP BY p1, p2
)
SELECT p.p1 AS anchor, p.p2 AS recommend_with,
       p.pair_freq AS frequency,
       ROUND(p.pair_freq*100.0/s1.freq, 1) AS confidence_pct,
       ROUND((p.pair_freq*1.0/t.n)/(s1.support*s2.support), 2) AS lift
FROM pairs p
JOIN item_support s1 ON s1.sub_category = p.p1
JOIN item_support s2 ON s2.sub_category = p.p2
CROSS JOIN total t
WHERE p.p1 = 'Binders'
ORDER BY lift DESC;
