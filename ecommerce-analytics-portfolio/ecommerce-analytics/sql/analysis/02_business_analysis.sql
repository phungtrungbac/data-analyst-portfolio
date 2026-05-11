-- ============================================================
-- FILE: sql/analysis/02_sales_analysis.sql
-- PROJECT: E-Commerce Sales Performance Analysis
-- PURPOSE: Sales, Customer, Product & Regional SQL Analysis
-- ANALYST: Analytics Team
-- ============================================================
-- All queries run on: superstore.cleaned_orders
-- All monetary values in USD unless specified
-- ============================================================


-- ============================================================
-- SECTION A: SALES PERFORMANCE ANALYSIS
-- ============================================================

-- ─────────────────────────────────────────────
-- A1. Annual Revenue & Profit Trend
-- BUSINESS PURPOSE: Confirms whether the business is growing
-- sustainably or chasing revenue at the expense of margin.
-- KEY STAKEHOLDER: CEO, CFO
-- ─────────────────────────────────────────────
SELECT
    order_year,
    COUNT(DISTINCT order_id)                        AS total_orders,
    ROUND(SUM(sales), 0)                            AS total_revenue,
    ROUND(SUM(profit), 0)                           AS total_profit,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value,
    ROUND(AVG(profit_margin_pct), 2)                AS avg_margin_pct,
    ROUND(
        (SUM(sales) - LAG(SUM(sales)) OVER (ORDER BY order_year))
        / NULLIF(LAG(SUM(sales)) OVER (ORDER BY order_year), 0) * 100,
    1)                                              AS revenue_growth_pct
FROM superstore.cleaned_orders
GROUP BY order_year
ORDER BY order_year;

-- ─────────────────────────────────────────────
-- A2. Monthly Revenue Trend (All Years)
-- BUSINESS PURPOSE: Identify seasonal demand patterns to
-- optimize inventory, promotions, and staffing.
-- KEY STAKEHOLDER: Sales Director, Marketing Team
-- ─────────────────────────────────────────────
SELECT
    order_year,
    order_month,
    TO_CHAR(DATE_TRUNC('month', order_date), 'Mon-YYYY') AS month_label,
    COUNT(DISTINCT order_id)                              AS orders,
    ROUND(SUM(sales), 0)                                  AS revenue,
    ROUND(SUM(profit), 0)                                 AS profit,
    ROUND(AVG(profit_margin_pct), 2)                      AS margin_pct
FROM superstore.cleaned_orders
GROUP BY order_year, order_month, DATE_TRUNC('month', order_date)
ORDER BY order_year, order_month;

-- ─────────────────────────────────────────────
-- A3. Quarterly Performance with QoQ Growth
-- BUSINESS PURPOSE: Quarterly reporting for leadership meetings.
-- KEY STAKEHOLDER: CEO, Board
-- ─────────────────────────────────────────────
WITH quarterly AS (
    SELECT
        order_year,
        order_quarter,
        CONCAT('Q', order_quarter::TEXT, '-', order_year::TEXT) AS quarter_label,
        ROUND(SUM(sales), 0)  AS revenue,
        ROUND(SUM(profit), 0) AS profit
    FROM superstore.cleaned_orders
    GROUP BY order_year, order_quarter
)
SELECT
    quarter_label,
    revenue,
    profit,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY order_year, order_quarter))
        / NULLIF(LAG(revenue) OVER (ORDER BY order_year, order_quarter), 0) * 100,
    1) AS qoq_revenue_growth_pct,
    ROUND(profit::NUMERIC / NULLIF(revenue, 0) * 100, 2) AS margin_pct
FROM quarterly
ORDER BY order_year, order_quarter;

-- ─────────────────────────────────────────────
-- A4. Seasonal Analysis — Revenue by Month (Across Years)
-- BUSINESS PURPOSE: Identifies recurring high and low months
-- for promotional calendar planning.
-- ─────────────────────────────────────────────
SELECT
    order_month,
    TO_CHAR(TO_DATE(order_month::TEXT, 'MM'), 'Month') AS month_name,
    ROUND(AVG(monthly_revenue), 0)  AS avg_monthly_revenue,
    ROUND(SUM(annual_revenue) / SUM(annual_revenue) OVER () * 100, 1) AS revenue_share_pct
FROM (
    SELECT
        order_month,
        order_year,
        SUM(sales) AS monthly_revenue,
        SUM(SUM(sales)) OVER (PARTITION BY order_year) AS annual_revenue
    FROM superstore.cleaned_orders
    GROUP BY order_month, order_year
) sub
GROUP BY order_month
ORDER BY order_month;

-- ─────────────────────────────────────────────
-- A5. Ship Mode Revenue & Cost Analysis
-- BUSINESS PURPOSE: Are premium shipping modes justifying cost?
-- ─────────────────────────────────────────────
SELECT
    ship_mode,
    COUNT(DISTINCT order_id)                                         AS total_orders,
    ROUND(SUM(sales), 0)                                             AS total_revenue,
    ROUND(SUM(shipping_cost), 0)                                     AS total_ship_cost,
    ROUND(SUM(shipping_cost) / NULLIF(SUM(sales), 0) * 100, 2)      AS ship_cost_as_pct_revenue,
    ROUND(AVG(days_to_ship), 1)                                      AS avg_days_to_ship,
    ROUND(AVG(profit_margin_pct), 2)                                 AS avg_margin_pct
FROM superstore.cleaned_orders
GROUP BY ship_mode
ORDER BY total_revenue DESC;


-- ============================================================
-- SECTION B: CUSTOMER ANALYTICS
-- ============================================================

-- ─────────────────────────────────────────────
-- B1. Customer Segment Performance
-- BUSINESS PURPOSE: Which segment drives the most value?
-- Informs whether to invest in B2B or B2C growth.
-- KEY STAKEHOLDER: Sales Director, Marketing Team
-- ─────────────────────────────────────────────
SELECT
    segment,
    COUNT(DISTINCT customer_id)                                      AS unique_customers,
    COUNT(DISTINCT order_id)                                         AS total_orders,
    ROUND(SUM(sales), 0)                                             AS total_revenue,
    ROUND(SUM(profit), 0)                                            AS total_profit,
    ROUND(AVG(profit_margin_pct), 2)                                 AS avg_margin_pct,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2)                  AS avg_order_value,
    ROUND(COUNT(DISTINCT order_id)::NUMERIC / COUNT(DISTINCT customer_id), 1) AS orders_per_customer
FROM superstore.cleaned_orders
GROUP BY segment
ORDER BY total_revenue DESC;

-- ─────────────────────────────────────────────
-- B2. Top 20 Customers by Revenue & Profit
-- BUSINESS PURPOSE: Identify VIP accounts for retention programs.
-- KEY STAKEHOLDER: Sales Director
-- ─────────────────────────────────────────────
WITH customer_metrics AS (
    SELECT
        customer_id,
        customer_name,
        segment,
        COUNT(DISTINCT order_id)        AS total_orders,
        ROUND(SUM(sales), 0)            AS total_revenue,
        ROUND(SUM(profit), 0)           AS total_profit,
        ROUND(AVG(profit_margin_pct), 2)AS avg_margin_pct,
        MIN(order_date)                 AS first_order,
        MAX(order_date)                 AS last_order
    FROM superstore.cleaned_orders
    GROUP BY customer_id, customer_name, segment
)
SELECT
    customer_id,
    customer_name,
    segment,
    total_orders,
    total_revenue,
    total_profit,
    avg_margin_pct,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    RANK() OVER (ORDER BY total_profit DESC)  AS profit_rank,
    first_order,
    last_order
FROM customer_metrics
ORDER BY total_revenue DESC
LIMIT 20;

-- ─────────────────────────────────────────────
-- B3. Repeat Purchase Analysis
-- BUSINESS PURPOSE: Repeat buyers are 5x cheaper to serve
-- than new customers. This identifies loyalty rate.
-- KEY STAKEHOLDER: Marketing Team
-- ─────────────────────────────────────────────
WITH customer_order_count AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM superstore.cleaned_orders
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time Buyer'
        WHEN order_count BETWEEN 2 AND 3 THEN 'Occasional (2-3)'
        WHEN order_count BETWEEN 4 AND 6 THEN 'Regular (4-6)'
        ELSE 'Loyal (7+)'
    END                               AS buyer_type,
    COUNT(*)                          AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct_of_customers
FROM customer_order_count
GROUP BY
    CASE
        WHEN order_count = 1 THEN 'One-time Buyer'
        WHEN order_count BETWEEN 2 AND 3 THEN 'Occasional (2-3)'
        WHEN order_count BETWEEN 4 AND 6 THEN 'Regular (4-6)'
        ELSE 'Loyal (7+)'
    END
ORDER BY customer_count DESC;

-- ─────────────────────────────────────────────
-- B4. Customer Revenue Concentration (Pareto Analysis)
-- BUSINESS PURPOSE: Confirms whether top 20% of customers
-- generate 80% of revenue — informs retention priority.
-- ─────────────────────────────────────────────
WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(sales) AS revenue
    FROM superstore.cleaned_orders
    GROUP BY customer_id
),
ranked AS (
    SELECT
        customer_id,
        revenue,
        NTILE(5) OVER (ORDER BY revenue DESC) AS quintile
    FROM customer_revenue
)
SELECT
    quintile,
    COUNT(*) AS customers,
    ROUND(SUM(revenue), 0) AS total_revenue,
    ROUND(SUM(revenue) / SUM(SUM(revenue)) OVER () * 100, 1) AS revenue_share_pct
FROM ranked
GROUP BY quintile
ORDER BY quintile;


-- ============================================================
-- SECTION C: PRODUCT & CATEGORY ANALYSIS
-- ============================================================

-- ─────────────────────────────────────────────
-- C1. Revenue & Profit by Category
-- BUSINESS PURPOSE: Core portfolio mix analysis.
-- KEY STAKEHOLDER: Product Team, CEO
-- ─────────────────────────────────────────────
SELECT
    category,
    COUNT(DISTINCT product_id)                                          AS unique_products,
    COUNT(*)                                                            AS line_items,
    ROUND(SUM(sales), 0)                                                AS total_revenue,
    ROUND(SUM(profit), 0)                                               AS total_profit,
    ROUND(SUM(sales) / SUM(SUM(sales)) OVER () * 100, 1)               AS revenue_share_pct,
    ROUND(SUM(profit) / SUM(SUM(profit)) OVER () * 100, 1)             AS profit_share_pct,
    ROUND(AVG(profit_margin_pct), 2)                                    AS avg_margin_pct,
    ROUND(AVG(discount) * 100, 1)                                       AS avg_discount_pct
FROM superstore.cleaned_orders
GROUP BY category
ORDER BY total_revenue DESC;

-- ─────────────────────────────────────────────
-- C2. Sub-Category Profitability Ranking
-- BUSINESS PURPOSE: Identifies which product lines need
-- pricing, discount, or cost intervention.
-- KEY STAKEHOLDER: Product Team
-- ─────────────────────────────────────────────
SELECT
    category,
    sub_category,
    ROUND(SUM(sales), 0)                 AS revenue,
    ROUND(SUM(profit), 0)                AS profit,
    ROUND(AVG(profit_margin_pct), 2)     AS avg_margin_pct,
    ROUND(AVG(discount) * 100, 1)        AS avg_discount_pct,
    COUNT(*)                             AS order_lines,
    RANK() OVER (ORDER BY AVG(profit_margin_pct) DESC) AS margin_rank
FROM superstore.cleaned_orders
GROUP BY category, sub_category
ORDER BY avg_margin_pct DESC;

-- ─────────────────────────────────────────────
-- C3. Top 15 Products by Revenue
-- BUSINESS PURPOSE: Core SKU performance.
-- ─────────────────────────────────────────────
SELECT
    product_id,
    product_name,
    category,
    sub_category,
    ROUND(SUM(sales), 0)             AS total_revenue,
    ROUND(SUM(profit), 0)            AS total_profit,
    ROUND(AVG(profit_margin_pct), 2) AS avg_margin_pct,
    SUM(quantity)                    AS units_sold,
    COUNT(DISTINCT order_id)         AS times_ordered
FROM superstore.cleaned_orders
GROUP BY product_id, product_name, category, sub_category
ORDER BY total_revenue DESC
LIMIT 15;

-- ─────────────────────────────────────────────
-- C4. Loss-Making Products (Revenue High, Profit Negative)
-- BUSINESS PURPOSE: Products that generate revenue illusion
-- while quietly destroying margin.
-- KEY STAKEHOLDER: Product Team, CFO
-- ─────────────────────────────────────────────
SELECT
    product_name,
    category,
    sub_category,
    ROUND(SUM(sales), 0)         AS total_revenue,
    ROUND(SUM(profit), 0)        AS total_profit,
    ROUND(AVG(discount)*100, 1)  AS avg_discount_pct,
    COUNT(*)                     AS order_lines,
    SUM(is_loss_making)          AS loss_orders
FROM superstore.cleaned_orders
GROUP BY product_name, category, sub_category
HAVING SUM(profit) < 0
ORDER BY total_profit ASC
LIMIT 15;

-- ─────────────────────────────────────────────
-- C5. Discount vs Margin Analysis
-- BUSINESS PURPOSE: Quantifies the business cost of
-- excessive discounting. Grounds discount policy decisions.
-- KEY STAKEHOLDER: Sales Director, CFO
-- ─────────────────────────────────────────────
SELECT
    discount_band,
    COUNT(*)                                    AS order_lines,
    ROUND(SUM(sales), 0)                        AS total_revenue,
    ROUND(SUM(profit), 0)                       AS total_profit,
    ROUND(AVG(profit_margin_pct), 2)            AS avg_margin_pct,
    SUM(is_loss_making)                         AS loss_making_orders,
    ROUND(SUM(is_loss_making)*100.0/COUNT(*),1) AS loss_rate_pct
FROM superstore.cleaned_orders
GROUP BY discount_band
ORDER BY
    CASE discount_band
        WHEN 'No Discount'       THEN 1
        WHEN 'Low (1-10%)'       THEN 2
        WHEN 'Medium (11-30%)'   THEN 3
        WHEN 'High (31-50%)'     THEN 4
        WHEN 'Very High (>50%)'  THEN 5
    END;


-- ============================================================
-- SECTION D: REGIONAL ANALYSIS
-- ============================================================

-- ─────────────────────────────────────────────
-- D1. Market/Region Performance Overview
-- BUSINESS PURPOSE: Identify which global markets are
-- delivering strong profitable growth vs underperforming.
-- KEY STAKEHOLDER: CEO, Sales Director
-- ─────────────────────────────────────────────
SELECT
    market,
    COUNT(DISTINCT customer_id)                                        AS unique_customers,
    COUNT(DISTINCT order_id)                                           AS total_orders,
    ROUND(SUM(sales), 0)                                               AS total_revenue,
    ROUND(SUM(profit), 0)                                              AS total_profit,
    ROUND(SUM(sales) / SUM(SUM(sales)) OVER () * 100, 1)              AS revenue_share_pct,
    ROUND(AVG(profit_margin_pct), 2)                                   AS avg_margin_pct,
    ROUND(SUM(shipping_cost), 0)                                       AS total_ship_cost,
    ROUND(SUM(shipping_cost) / NULLIF(SUM(sales), 0) * 100, 2)        AS ship_cost_pct_revenue
FROM superstore.cleaned_orders
GROUP BY market
ORDER BY total_revenue DESC;

-- ─────────────────────────────────────────────
-- D2. Country-Level Deep Dive (Top 15)
-- BUSINESS PURPOSE: Country granularity for operational decisions.
-- ─────────────────────────────────────────────
SELECT
    country,
    market,
    COUNT(DISTINCT customer_id) AS customers,
    ROUND(SUM(sales), 0)        AS revenue,
    ROUND(SUM(profit), 0)       AS profit,
    ROUND(AVG(profit_margin_pct), 2) AS margin_pct,
    RANK() OVER (ORDER BY SUM(sales) DESC) AS revenue_rank
FROM superstore.cleaned_orders
GROUP BY country, market
ORDER BY revenue DESC
LIMIT 15;

-- ─────────────────────────────────────────────
-- D3. Underperforming Markets — Revenue vs Margin Mismatch
-- BUSINESS PURPOSE: Catches regions that look good on revenue
-- reports but are quietly unprofitable.
-- ─────────────────────────────────────────────
WITH market_stats AS (
    SELECT
        market,
        ROUND(SUM(sales), 0)              AS revenue,
        ROUND(AVG(profit_margin_pct), 2)  AS margin_pct
    FROM superstore.cleaned_orders
    GROUP BY market
)
SELECT
    market,
    revenue,
    margin_pct,
    CASE
        WHEN revenue > (SELECT AVG(revenue) FROM market_stats)
         AND margin_pct < (SELECT AVG(margin_pct) FROM market_stats)
        THEN '⚠ High Revenue, Low Margin — Investigate'
        WHEN revenue < (SELECT AVG(revenue) FROM market_stats)
         AND margin_pct > (SELECT AVG(margin_pct) FROM market_stats)
        THEN '📈 Low Revenue, High Margin — Growth Opportunity'
        WHEN revenue > (SELECT AVG(revenue) FROM market_stats)
         AND margin_pct > (SELECT AVG(margin_pct) FROM market_stats)
        THEN '✅ Star Market — Invest & Protect'
        ELSE '❌ Low Revenue, Low Margin — Restructure'
    END AS strategic_classification
FROM market_stats
ORDER BY revenue DESC;


-- ============================================================
-- SECTION E: RFM CUSTOMER SEGMENTATION
-- ============================================================
-- BUSINESS PURPOSE: Segment customers by Recency, Frequency,
-- and Monetary value to drive targeted marketing actions.
-- KEY STAKEHOLDER: Marketing Team, Sales Director
-- ============================================================

WITH rfm_base AS (
    SELECT
        customer_id,
        customer_name,
        segment,
        MAX(order_date)                                              AS last_order_date,
        -- Recency: days since last purchase from the dataset's max date
        ('2014-12-31'::DATE - MAX(order_date))                       AS recency_days,
        COUNT(DISTINCT order_id)                                     AS frequency,
        ROUND(SUM(sales), 2)                                         AS monetary
    FROM superstore.cleaned_orders
    GROUP BY customer_id, customer_name, segment
),
rfm_scores AS (
    SELECT
        customer_id,
        customer_name,
        segment,
        last_order_date,
        recency_days,
        frequency,
        monetary,
        -- Score 5 = Best, 1 = Worst
        NTILE(5) OVER (ORDER BY recency_days ASC)  AS r_score,  -- Lower recency = better
        NTILE(5) OVER (ORDER BY frequency DESC)    AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC)     AS m_score
    FROM rfm_base
),
rfm_segments AS (
    SELECT
        *,
        CONCAT(r_score::TEXT, f_score::TEXT, m_score::TEXT) AS rfm_code,
        ROUND((r_score + f_score + m_score)::NUMERIC / 3, 1) AS rfm_avg_score,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4
                THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3
                THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score <= 2
                THEN 'New Customers'
            WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3
                THEN 'At Risk'
            WHEN r_score = 1 AND f_score <= 2
                THEN 'Lost'
            WHEN r_score >= 3 AND m_score >= 4
                THEN 'Potential Loyalists'
            ELSE 'Needs Attention'
        END AS rfm_segment
    FROM rfm_scores
)
SELECT
    rfm_segment,
    COUNT(*)                             AS customer_count,
    ROUND(AVG(recency_days), 0)          AS avg_recency_days,
    ROUND(AVG(frequency), 1)             AS avg_frequency,
    ROUND(AVG(monetary), 0)              AS avg_monetary,
    ROUND(SUM(monetary), 0)              AS total_revenue,
    ROUND(SUM(monetary) / SUM(SUM(monetary)) OVER () * 100, 1) AS revenue_share_pct
FROM rfm_segments
GROUP BY rfm_segment
ORDER BY total_revenue DESC;


-- ============================================================
-- SECTION F: PRODUCT BASKET ANALYSIS (Association)
-- ============================================================
-- BUSINESS PURPOSE: Which products are frequently ordered
-- together? Enables bundling and cross-sell strategies.
-- KEY STAKEHOLDER: Product Team, Marketing Team
-- ============================================================

WITH order_products AS (
    SELECT DISTINCT
        order_id,
        sub_category
    FROM superstore.cleaned_orders
),
product_pairs AS (
    SELECT
        a.sub_category AS product_a,
        b.sub_category AS product_b,
        COUNT(DISTINCT a.order_id) AS co_occurrence
    FROM order_products a
    JOIN order_products b
        ON a.order_id = b.order_id
        AND a.sub_category < b.sub_category  -- avoid duplicates
    GROUP BY a.sub_category, b.sub_category
)
SELECT
    product_a,
    product_b,
    co_occurrence,
    RANK() OVER (ORDER BY co_occurrence DESC) AS pair_rank
FROM product_pairs
ORDER BY co_occurrence DESC
LIMIT 20;

-- ============================================================
-- END OF ANALYSIS SCRIPT
-- ============================================================
