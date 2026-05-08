-- ============================================================
-- STEP 1: Self-join to find all product pair combinations
-- The condition a.sub_category < b.sub_category avoids
-- counting both (A,B) and (B,A) as separate pairs
-- ============================================================

SELECT 
    a.sub_category                  AS product_1,
    b.sub_category                  AS product_2,
    COUNT(DISTINCT a.order_id)      AS frequency
FROM orders a
JOIN orders b
    ON  a.order_id     = b.order_id          -- same order
    AND a.sub_category < b.sub_category      -- avoid duplicates & self-pairs
GROUP BY product_1, product_2
ORDER BY frequency DESC
LIMIT 10;
