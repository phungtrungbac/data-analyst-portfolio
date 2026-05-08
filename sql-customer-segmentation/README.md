# 🔍 Project 2 — Customer Segmentation Analysis (SQL)

![Dashboard Preview](images/dashboard_preview.png)

## 🎯 Business Question

> **Who are the high-value customers — and how do we keep them?**

This project uses SQL to segment 4,873 customers by spending behavior, identify revenue concentration risk, and surface actionable upsell/retention opportunities.

---

## 📁 Repository Structure

```
customer-segmentation-sql/
│
├── README.md
├── dashboard.png                        # Dashboard preview
│
├── sql/
│   ├── 01_create_orders_table.sql       # Schema definition
│   ├── 02_customer_aggregate.sql        # Customer-level metrics VIEW
│   ├── 03_segmentation.sql              # Segmentation logic (CASE WHEN)
│   ├── 04_segment_analysis.sql          # Business analysis queries
│   └── 05_insights_queries.sql          # Insight-backed queries
│
├── data/
│   ├── customer_segmentation.csv        # Full customer × segment output
│   └── segment_summary.csv             # Aggregated segment metrics
│
└── images/
    └── dashboard_preview.png
```

---

## ⚙️ Methodology

### Step 1 — Aggregate Customer Metrics
```sql
SELECT 
    customer_id,
    customer_name,
    segment                             AS customer_type,
    COUNT(DISTINCT order_id)            AS total_orders,
    ROUND(SUM(sales), 2)                AS total_spent,
    ROUND(SUM(profit), 2)               AS total_profit,
    ROUND(SUM(profit) / SUM(sales), 4)  AS profit_margin,
    ROUND(AVG(discount), 3)             AS avg_discount
FROM orders
GROUP BY customer_id, customer_name, segment;
```

### Step 2 — Segment by Spend (Quartile-based Thresholds)
```sql
CASE 
    WHEN total_spent >= 3763 THEN 'High Value'   -- Top 25%
    WHEN total_spent >= 728  THEN 'Mid Value'    -- Middle 50%
    ELSE                          'Low Value'    -- Bottom 25%
END AS value_segment
```

### Step 3 — Analyze Each Segment
```sql
SELECT 
    value_segment,
    COUNT(*)                        AS num_customers,
    ROUND(SUM(total_spent), 0)      AS total_revenue,
    ROUND(AVG(total_spent), 0)      AS avg_spend_per_customer,
    ROUND(AVG(total_orders), 1)     AS avg_orders,
    ROUND(
        SUM(total_spent) * 100.0 / 
        (SELECT SUM(total_spent) FROM customer_segments), 1
    )                               AS revenue_share_pct
FROM customer_segments
GROUP BY value_segment;
```

---

## 📊 Key Results

| Segment | Customers | % of Customers | Revenue | % of Revenue | Avg Spend | Avg Orders |
|---|---|---|---|---|---|---|
| **High Value** | 1,219 | 25% | $7.37M | **58.3%** | $6,047 | 7.8 |
| **Mid Value** | 2,436 | 50% | $4.88M | 38.6% | $2,005 | 5.4 |
| **Low Value** | 1,218 | 25% | $0.39M | 3.1% | $318 | 2.5 |

---

## 💡 Key Insights

### 🏆 The 25/58 Rule
Just **25% of customers (1,219)** generate **58.3% of total revenue ($7.37M)**. Classic Pareto concentration — these customers must be protected with loyalty programs.

### 📈 Mid-Value = Biggest Upsell Opportunity
2,436 customers average **$2,005 in spend** — only **$1,758 away** from the High Value threshold. A targeted campaign nudging even 10% of this group upward adds ~$430K in incremental revenue.

### ⚠️ Low-Value Discount Sensitivity
Low-value customers show the **highest average discount rates** yet the thinnest margins. Blanket discounting is eroding profitability without driving loyalty.

### 🚨 Negative-Profit High Spenders
Some High Value customers (e.g. Sean Miller: $25K spend, **−$1,981 profit**) are loss-making due to excessive discounts. High revenue ≠ high value without margin discipline.

---

## 📈 Recommended Actions

| Segment | Action | Expected Impact |
|---|---|---|
| High Value | VIP loyalty program · early access · dedicated support | Reduce churn, protect $7.37M |
| Mid Value | Targeted upsell emails · bundle offers · volume discounts | Convert 10% → +$430K revenue |
| Low Value | Reduce discount depth · promote self-service | Improve margin from 1% → 5%+ |
| Negative-profit | Audit discount approvals · flag for review | Recover $50K–$200K in leaked profit |

---

## 🛠️ How to Run

**Option A — SQLite (no setup needed)**
```bash
sqlite3 superstore.db < sql/01_create_orders_table.sql
# import your CSV, then:
sqlite3 superstore.db < sql/02_customer_aggregate.sql
sqlite3 superstore.db < sql/03_segmentation.sql
sqlite3 superstore.db < sql/04_segment_analysis.sql
```

**Option B — PostgreSQL / MySQL**  
The SQL is ANSI-compatible. Replace `CREATE VIEW` with `CREATE OR REPLACE VIEW` for PostgreSQL.

---

## 📦 Dataset

- **Source**: [Superstore Dataset — Kaggle](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)
- **Rows**: 51,290 orders · **4,873 unique customers**
- **Period**: FY 2011–2014

---

## 🔗 Portfolio

| # | Project | Tool | Topic |
|---|---|---|---|
| 1 | [Sales Dashboard](../superstore-dashboard) | Excel | Business Performance |
| 2 | **Customer Segmentation** ← you are here | SQL | Customer Analytics |

---

*If this was helpful, please ⭐ star the repo!*
