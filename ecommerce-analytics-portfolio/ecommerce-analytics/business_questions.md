# Business Questions — E-Commerce Sales Performance Analysis

> **Project Scope:** Global Superstore | FY2011–FY2014  
> **Prepared by:** Analytics Team  
> **Audience:** CEO, Sales Director, Marketing Team, Product Team

---

## Business Context

Global Superstore operates as a multinational e-commerce retailer selling Technology, Furniture, and Office Supplies across multiple global markets. Despite strong revenue growth, leadership suspects profitability is not scaling proportionally — indicating structural issues in product mix, customer targeting, and regional strategy.

This analytics initiative is designed to surface the root causes and provide actionable, data-backed recommendations.

---

## Stakeholder Map

| Stakeholder | Primary Concern | Key Metric |
|---|---|---|
| CEO | Sustainable profitable growth | Revenue, Net Profit Margin, YoY Growth |
| Sales Director | Revenue performance & regional efficiency | Sales by Region, AOV, Conversion |
| Marketing Team | Customer acquisition & retention ROI | Customer LTV, Churn Risk, Segment Mix |
| Product Team | Portfolio optimization & margin health | Margin by Category, Return Rate, Bundle Opportunity |

---

## Strategic Business Questions

### 1. Sales Performance
- What is the overall revenue and profit trend across FY2011–FY2014?
- Is revenue growth translating into profit growth?
- Which quarters show the strongest/weakest performance?
- Are there seasonal demand patterns that should inform inventory strategy?
- Which ship modes drive the most revenue and cost?

### 2. Customer Analytics
- Who are our highest-value customers by revenue and profit contribution?
- What percentage of revenue comes from repeat buyers?
- Which customer segments (Consumer, Corporate, Home Office) are most profitable?
- Which customers show early signs of churn?
- What is the average order value per segment, and how has it trended?

### 3. Product & Category Analytics
- Which product categories generate the most revenue? Are they also the most profitable?
- Which sub-categories have persistently low or negative margins?
- Do heavy discounts correlate with low profitability?
- Which products should be bundled to increase basket size?
- Which categories deserve increased marketing investment?

### 4. Regional & Market Analytics
- Which global markets (North America, Europe, Asia Pacific, etc.) perform best?
- Which regions have strong revenue but weak margins?
- Are there markets where we are systematically underperforming?
- What is the logistics cost profile by region, and how does it impact margin?

### 5. Strategic Decisions for Leadership
- Where should we allocate growth investment (products, regions, segments)?
- Which customer segments should be the focus of retention programs?
- Which low-margin products require pricing or discount policy review?
- What is the recommended discount guardrail by category?

---

## Hypotheses to Test

| # | Hypothesis | Expected Finding |
|---|---|---|
| H1 | Furniture has the lowest profit margins due to high shipping costs | Confirmed/Rejected via SQL margin analysis |
| H2 | High discounts (>40%) destroy margin regardless of category | Confirmed/Rejected via discount-profit correlation |
| H3 | Corporate segment has higher AOV than Consumer | Confirmed/Rejected via segment analysis |
| H4 | Q4 drives disproportionate revenue due to holiday effect | Confirmed/Rejected via seasonal analysis |
| H5 | Top 20% customers generate 80% of profit (Pareto principle) | Confirmed/Rejected via RFM analysis |

---

## Analytical Workplan

| Phase | Deliverable | Owner |
|---|---|---|
| 1 | Data Quality Assessment | Analyst |
| 2 | SQL Business Analysis | Analyst |
| 3 | Python EDA & Advanced Analytics | Analyst |
| 4 | RFM Customer Segmentation | Analyst |
| 5 | Power BI Executive Dashboard | Analyst |
| 6 | Business Recommendations Report | Analyst + Stakeholders |
| 7 | Executive Summary Presentation | Analyst |
