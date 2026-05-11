# Data Dictionary — Global Superstore Dataset

> **Dataset:** Global Superstore (2011–2014)  
> **Total Records:** 51,290 order line items  
> **Total Fields:** 23 columns  
> **Source:** Superstore transactional database  
> **Grain:** One row = one order line item (one product within one order)

---

## Table: `superstore_raw`

| # | Column Name | Data Type | Sample Value | Description | Business Notes |
|---|---|---|---|---|---|
| 1 | Row ID | INTEGER | 1 | Unique row identifier | Surrogate key for each line item |
| 2 | Order ID | VARCHAR | CA-2014-152156 | Unique order identifier | One order may contain multiple rows (products) |
| 3 | Order Date | DATE | 2014-11-08 | Date the order was placed | Used for sales trend and cohort analysis |
| 4 | Ship Date | DATE | 2014-11-11 | Date the order was shipped | Used to calculate shipping lead time |
| 5 | Ship Mode | VARCHAR | Second Class | Shipping method selected | 4 modes: Same Day, First Class, Second Class, Standard Class |
| 6 | Customer ID | VARCHAR | CG-12520 | Unique customer identifier | Used for customer-level aggregation and repeat analysis |
| 7 | Customer Name | VARCHAR | Claire Gute | Customer full name | Display field only; use Customer ID for joins |
| 8 | Segment | VARCHAR | Consumer | Customer business segment | 3 segments: Consumer, Corporate, Home Office |
| 9 | City | VARCHAR | Henderson | Order delivery city | Granular geographic dimension |
| 10 | State | VARCHAR | Kentucky | Order delivery state/province | Mid-level geographic dimension |
| 11 | Country | VARCHAR | United States | Order delivery country | Used for international analysis |
| 12 | Region | VARCHAR | North America | Geographic region grouping | Used for regional performance dashboard |
| 13 | Market | VARCHAR | North America | Sales market classification | Aligns with regional sales teams |
| 14 | Product ID | VARCHAR | FUR-BO-10001798 | Unique product identifier | Format: [CAT]-[SUBCAT]-[ID] |
| 15 | Category | VARCHAR | Furniture | Product category | 3 categories: Technology, Furniture, Office Supplies |
| 16 | Sub-Category | VARCHAR | Bookcases | Product sub-category | 17 sub-categories across 3 categories |
| 17 | Product Name | VARCHAR | Bush Somerset Bookcase | Full product name | Use Product ID for joins; name for display |
| 18 | Sales | DECIMAL(10,2) | 261.96 | Order line revenue (after discount) | Sales = Unit Price × Quantity × (1 − Discount) |
| 19 | Quantity | INTEGER | 2 | Units ordered | Range: 1–14 |
| 20 | Discount | DECIMAL(4,2) | 0.00 | Discount rate applied | Range: 0.00–0.80 (0% to 80%) |
| 21 | Profit | DECIMAL(10,2) | 41.91 | Net profit for the line item | Can be negative (loss-making orders) |
| 22 | Shipping Cost | DECIMAL(10,2) | 13.69 | Shipping cost incurred | Not always passed to customer |
| 23 | Order Priority | VARCHAR | Medium | Internal order fulfillment priority | 4 levels: Critical, High, Medium, Low |

---

## Derived Fields (Created During Cleaning)

| Field | Formula | Purpose |
|---|---|---|
| `Profit Margin %` | `Profit / Sales × 100` | Profitability per line item |
| `Days to Ship` | `Ship Date − Order Date` | Logistics efficiency metric |
| `Order Year` | `YEAR(Order Date)` | Annual trend analysis |
| `Order Month` | `MONTH(Order Date)` | Seasonal analysis |
| `Order Quarter` | `QUARTER(Order Date)` | Quarterly performance |
| `Revenue per Unit` | `Sales / Quantity` | Effective unit price after discount |

---

## Category Taxonomy

```
Technology
├── Phones
├── Computers
├── Copiers
├── Machines
└── Accessories

Furniture
├── Chairs
├── Tables
├── Bookcases
├── Furnishings
└── Storage

Office Supplies
├── Paper
├── Binders
├── Art
├── Fasteners
├── Labels
├── Envelopes
├── Appliances
├── Storage
└── Supplies
```

---

## Data Quality Flags (Pre-Cleaning)

| Issue Type | Column(s) Affected | Estimated Impact | Action |
|---|---|---|---|
| Negative profits | Profit | ~18% of rows | Flag, do NOT remove — valid business data |
| Zero-sale orders | Sales | Rare | Investigate — may be returns |
| High discount outliers | Discount > 0.5 | ~8% of rows | Flag for discount policy analysis |
| Duplicate Order ID | Order ID | Possible | Deduplicate at order level for header-level analysis |
| Date format inconsistency | Order Date, Ship Date | Source-dependent | Standardize to YYYY-MM-DD |
| Ship Date before Order Date | Ship Date | Rare | Investigate — data entry error |

---

## Business Rules

1. **Revenue Recognition:** Revenue = Sales column (post-discount). Gross sales = Sales / (1 − Discount).
2. **Profit Definition:** Profit is net operating profit at the line-item level, inclusive of COGS and shipping. It is NOT gross profit.
3. **Customer Deduplication:** Customers are identified by Customer ID. Names may have minor variations.
4. **Order-Level vs Line-Level Analysis:** For basket analysis, aggregate at Order ID level. For product analysis, use Row ID level.
5. **Negative Profits:** Represent loss-making orders — typically due to heavy discounts or high shipping costs. These are critical for profitability analysis and must be retained.
