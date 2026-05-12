# 📊 Data Analyst Portfolio — Phung Trung Bac

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-336791?style=flat-square&logo=postgresql)
![Python](https://img.shields.io/badge/Python-3.10+-blue?style=flat-square&logo=python)
![PowerBI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C94C?style=flat-square&logo=powerbi)
![Excel](https://img.shields.io/badge/Excel-Dashboard-217346?style=flat-square&logo=microsoftexcel)

---

## 👋 About Me

Hi, I'm **Phung Trung Bac**, a Management Information Systems student at Ho Chi Minh City University of Technology (HUTECH), GPA 3.4/4.0.

I have hands-on experience analyzing operational datasets and building data-driven reports during my internship at **Algorithmics International LLC**. Proficient in **SQL, Python (pandas), Excel, and Power BI**, I'm seeking a Fresher Data Analyst role to transform raw business data into actionable insights that support strategic decision-making.

📍 Ho Chi Minh City, Vietnam &nbsp;|&nbsp; 📧 phungtrungbac.cv@gmail.com &nbsp;|&nbsp; 🔗 [LinkedIn](https://linkedin.com/in/phungtrungbac)

---

## 🛠️ Technical Skills

| Category | Tools & Technologies |
|---|---|
| **Data Analysis & Processing** | SQL (JOINs, Window Functions, CTEs, Subqueries), Python (pandas, numpy) |
| **Data Visualization** | Power BI (DAX, Power Query), Excel (Pivot Tables, Charts), matplotlib, seaborn |
| **Analytics Skills** | Data Cleaning, EDA, RFM Analysis, Cohort Analysis, Descriptive Statistics |

---

## 📁 Projects

| # | Project | Tools | Topic |
|---|---|---|---|
| 1 | [E-Commerce Sales Analysis](#1-e-commerce-sales-performance-analysis) | Python · SQL · Power BI | End-to-End Analytics |
| 2 | [Excel Sales Dashboard](#2-excel-sales-dashboard) | Excel | Business Performance |
| 3 | [Power BI HR Dashboard](#3-power-bi-hr-attrition-dashboard) | Power BI | People Analytics |
| 4 | [Power BI Sales Dashboard](#4-power-bi-sales-dashboard) | Power BI | Interactive Reporting |
| 5 | [Python Churn & EDA Analysis](#5-python-churn--eda-analysis) | Python | Behavioral Analytics |
| 6 | [SQL Customer Segmentation](#6-sql-customer-segmentation) | SQL | Customer Analytics |
| 7 | [SQL Market Basket Analysis](#7-sql-market-basket-analysis) | SQL | Product Affinity |

---

## Project Details

### 1. E-Commerce Sales Performance Analysis
📂 [`ecommerce-analytics`](./ecommerce-analytics)

**Business Question:** Why is revenue growing but profit margins remaining flat?

An end-to-end analytics project simulating a real corporate initiative at a global e-commerce company. Analyzed 51,290 transactions (FY2011–2014) to answer four strategic questions: why margins are being eroded, which customer segments are most valuable, where the business is losing money, and what actions leadership should prioritize.

**Key Findings:**
- Identified that discounts >30% destroyed ~$1.2M in profit over 4 years
- RFM segmentation revealed 15% of customers are "At Risk" with declining purchase frequency — $2M+ revenue at risk
- Top 20% of customers generate ~70% of total revenue (Pareto confirmed)
- Proposed discount cap policy estimated to recover $300–500K in annual profit

**🔧 Tools:** Python (pandas, matplotlib, seaborn) · SQL (PostgreSQL) · Power BI  
**💡 Skills:** EDA · RFM Analysis · Cohort Retention · Advanced SQL · DAX · Executive Reporting

---

### 2. Excel Sales Dashboard
📂 [`excel-sales-dashboard`](./excel-sales-dashboard)

**Business Question:** What is the overall business performance — and where are the key opportunities and risks?

An end-to-end Excel dashboard built from the Superstore dataset (51,290 orders), structured across 5 sheets: KPI overview ($12.64M revenue · $1.47M profit · 11.6% margin), monthly revenue trends, regional performance, and category/sub-category deep dives.

**Key Findings:**
- Central region leads at $2.8M — 22% of total revenue
- Tables sub-category is loss-making: −$64K profit on $757K in revenue
- Q4 (Nov–Dec) averages $1.6M/month — 3× the February low
- Technology leads on margin at 14% vs Furniture's 6.9%

**🔧 Tools:** Microsoft Excel (Pivot Tables, Charts, Lookup functions)  
**💡 Skills:** Dashboard Design · KPI Tracking · Business Insight · Data Reporting

---

### 3. Power BI HR Attrition Dashboard
📂 [`powerbi-hr-dashboard`](./powerbi-hr-dashboard)

**Business Question:** Why are employees leaving — and what can we do to stop it?

Analyzed employee attrition across departments, tenure, salary, overtime, and satisfaction scores to identify root causes and recommend targeted retention actions. Dataset: 1,470 employees · 28 features · overall attrition rate of 36.3%.

**Key Findings:**
- New hires (0–2 years): **46% attrition** — highest risk group, signaling onboarding failure
- Overtime employees: **47% vs 32%** non-OT — a 15 percentage point gap and the most actionable lever
- Low salary (<$3K/month): attrition rate of nearly **49%** — compensation gap is critical
- Sales department: **38.7%** — consistently above company average

**🔧 Tools:** Power BI (DAX, Power Query)  
**💡 Skills:** HR Analytics · DAX Measures · Conditional Formatting · Attrition Analysis

---

### 4. Power BI Sales Dashboard
📂 [`powerbi-sales-dashboard`](./powerbi-sales-dashboard)

**Business Question:** What is the overall business performance — viewed through a fully interactive reporting lens?

Rebuilt the Excel sales analysis in Power BI with DAX measures, slicers, and drill-through for a dynamic reporting experience. Includes a Date Table with Time Intelligence for YoY growth analysis.

**Core DAX Measures:** Total Sales · Total Profit · Profit Margin · Sales YoY % · Margin Color (conditional formatting by threshold)

**🔧 Tools:** Power BI (DAX, Power Query, Time Intelligence)  
**💡 Skills:** Interactive Dashboard · DAX · YoY Analysis · Data Modeling · Business Intelligence

---

### 5. Python Churn & EDA Analysis
📂 [`python-churn-analysis`](./python-churn-analysis)

**Business Question:** How do customers behave — and what patterns in the data drive revenue vs loss?

A full Python EDA uncovering behavioral patterns, seasonal trends, and discount-profit dynamics across 51,290 orders. Produced 12 analytical charts covering everything from high-level KPIs to segment-level deep dives.

**Key Findings:**
- Discounts above 20% push average profit negative: from −$8.5 (21–30%) to −$118.3 (>50%)
- Discount–profit correlation: **−0.22** — inverse relationship confirmed statistically
- Q4 revenue is consistently **2.8× Q1** across all 4 years — structural, not random
- Tables sub-category: −$64K profit on $757K revenue

**🔧 Tools:** Python (pandas, numpy, matplotlib, seaborn)  
**💡 Skills:** EDA · Statistical Analysis · Discount Impact Analysis · Behavioral Analytics

---

### 6. SQL Customer Segmentation
📂 [`sql-customer-segmentation`](./sql-customer-segmentation)

**Business Question:** Who are the high-value customers — and how do we keep them?

Segmented 4,873 customers by spending behavior using pure SQL, identified revenue concentration risk, and surfaced quantifiable upsell and retention opportunities.

**Key Findings:**
- **The 25/58 Rule:** 25% of customers (1,219) generate 58.3% of total revenue ($7.37M)
- Mid-Value segment: 2,436 customers just $1,758 away from High Value threshold — potential +$430K if 10% convert
- Discovered loss-making high spenders: Sean Miller spent $25K but generated −$1,981 profit due to excessive discounting

**🔧 Tools:** SQL (CTEs, Window Functions, CASE WHEN, Subqueries)  
**💡 Skills:** Customer Segmentation · Quartile Analysis · Advanced SQL · Revenue Analytics

---

### 7. SQL Market Basket Analysis
📂 [`sql-market-basket`](./sql-market-basket)

**Business Question:** Which products are frequently bought together — and how do we use that to drive cross-sell and bundle revenue?

Applied Market Basket Analysis using SQL self-joins to identify product affinity patterns across 25,035 orders. Ranked 136 product pairs by three metrics: Support, Confidence, and Lift.

**Key Findings:**
- **Copiers + Labels (Lift 1.17):** best bundle candidate — Copier buyers are 17% more likely to also buy Labels than random chance predicts
- **Tech + Office Supplies:** 5,050 co-purchase orders — the largest cross-category opportunity
- **Key lesson:** Binders + Storage (944 orders, Lift 0.97) — high volume does not equal true product affinity

**🔧 Tools:** SQL (Self-Join, CTEs, Window Functions, Aggregation)  
**💡 Skills:** Market Basket Analysis · Association Rules (Support, Confidence, Lift) · Advanced SQL

---

## 📬 Contact

Feel free to reach out if you have any questions about the projects or just want to connect!

📧 phungtrungbac.cv@gmail.com &nbsp;|&nbsp; 🔗 [linkedin.com/in/phungtrungbac](https://linkedin.com/in/phungtrungbac)

---

*⭐ If you find this portfolio helpful, feel free to leave a star!*
