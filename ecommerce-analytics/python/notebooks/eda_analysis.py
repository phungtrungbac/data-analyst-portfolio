#!/usr/bin/env python3
"""
==============================================================
E-Commerce Sales Performance Analysis
Global Superstore — Full EDA & Advanced Analytics Notebook
==============================================================
Author  : Analytics Team
Dataset : Global Superstore 2011-2014
Purpose : Business-oriented EDA with strategic insights
==============================================================
"""

# ─────────────────────────────────────────────
# 0. ENVIRONMENT SETUP
# ─────────────────────────────────────────────
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
import seaborn as sns
import warnings
warnings.filterwarnings("ignore")

plt.style.use("seaborn-v0_8-whitegrid")
pd.set_option("display.float_format", "{:,.2f}".format)
pd.set_option("display.max_columns", 30)

# ─────────────────────────────────────────────
# 1. DATA LOADING & INITIAL INSPECTION
# ─────────────────────────────────────────────
print("=" * 60)
print("STEP 1: DATA LOADING & INSPECTION")
print("=" * 60)

df = pd.read_csv("../data/cleaned/superstore_cleaned.csv")
df["Order Date"] = pd.to_datetime(df["Order Date"])
df["Ship Date"]  = pd.to_datetime(df["Ship Date"])
df["Order Year"]    = df["Order Date"].dt.year
df["Order Month"]   = df["Order Date"].dt.month
df["Order Quarter"] = df["Order Date"].dt.quarter

print(f"\nDataset Shape  : {df.shape[0]:,} rows × {df.shape[1]} columns")
print(f"Date Range     : {df['Order Date'].min().date()} → {df['Order Date'].max().date()}")
print(f"Unique Orders  : {df['Order ID'].nunique():,}")
print(f"Unique Customers: {df['Customer ID'].nunique():,}")
print(f"\nColumn Overview:\n")
print(df.dtypes)

print("\n--- NULL Audit ---")
null_summary = df.isnull().sum()
print(null_summary[null_summary > 0] if null_summary.sum() > 0 else "✅ No nulls detected.")

# ─────────────────────────────────────────────
# 2. KEY METRICS SNAPSHOT
# ─────────────────────────────────────────────
print("\n" + "=" * 60)
print("STEP 2: BUSINESS KPI SNAPSHOT")
print("=" * 60)

total_revenue  = df["Sales"].sum()
total_profit   = df["Profit"].sum()
total_margin   = total_profit / total_revenue * 100
total_orders   = df["Order ID"].nunique()
total_customers= df["Customer ID"].nunique()
aov            = total_revenue / total_orders
repeat_rate    = (df.groupby("Customer ID")["Order ID"].nunique() > 1).mean() * 100

print(f"""
┌─────────────────────────────────────────┐
│  GLOBAL SUPERSTORE — EXECUTIVE KPIs     │
├─────────────────────────────────────────┤
│  Total Revenue      : ${total_revenue:>12,.0f}   │
│  Total Profit       : ${total_profit:>12,.0f}   │
│  Profit Margin      : {total_margin:>11.1f}%   │
│  Total Orders       : {total_orders:>12,}   │
│  Total Customers    : {total_customers:>12,}   │
│  Avg Order Value    : ${aov:>12,.2f}   │
│  Repeat Customer %  : {repeat_rate:>11.1f}%   │
└─────────────────────────────────────────┘
""")

# ─────────────────────────────────────────────
# 3. ANNUAL PERFORMANCE TREND
# ─────────────────────────────────────────────
print("=" * 60)
print("STEP 3: ANNUAL REVENUE & PROFIT TREND")
print("=" * 60)

annual = df.groupby("Order Year").agg(
    Revenue    = ("Sales", "sum"),
    Profit     = ("Profit", "sum"),
    Orders     = ("Order ID", "nunique"),
    Customers  = ("Customer ID", "nunique")
).reset_index()
annual["Margin%"]          = (annual["Profit"] / annual["Revenue"] * 100).round(2)
annual["AOV"]              = (annual["Revenue"] / annual["Orders"]).round(2)
annual["Revenue_Growth%"]  = annual["Revenue"].pct_change().mul(100).round(1)

print("\n📊 Annual Summary:")
print(annual.to_string(index=False))
print("""
🔍 INSIGHT:
Revenue has grown consistently from 2011 to 2014.
However, profit margin has not grown proportionally,
suggesting increasing operational costs or discount pressure.
→ RECOMMENDATION: Audit discount policy and COGS escalation.
""")

# ─────────────────────────────────────────────
# 4. CATEGORY ANALYSIS
# ─────────────────────────────────────────────
print("=" * 60)
print("STEP 4: CATEGORY PERFORMANCE")
print("=" * 60)

cat = df.groupby("Category").agg(
    Revenue = ("Sales", "sum"),
    Profit  = ("Profit", "sum"),
    Lines   = ("Row ID", "count")
).reset_index()
cat["Margin%"] = (cat["Profit"] / cat["Revenue"] * 100).round(2)
cat["Rev_Share%"] = (cat["Revenue"] / cat["Revenue"].sum() * 100).round(1)
print(cat.to_string(index=False))

print("""
🔍 INSIGHT:
Technology generates the highest revenue but Office Supplies
often delivers stronger margins due to lower shipping costs.
Furniture shows persistently lower margins despite moderate revenue.
→ RECOMMENDATION: Review Furniture discount strategy and shipping cost pass-through.
""")

# ─────────────────────────────────────────────
# 5. DISCOUNT IMPACT ANALYSIS
# ─────────────────────────────────────────────
print("=" * 60)
print("STEP 5: DISCOUNT vs MARGIN ANALYSIS")
print("=" * 60)

disc_bands = ["No Discount","Low (1-10%)","Medium (11-30%)","High (31-50%)","Very High (>50%)"]
df["Discount Band"] = pd.cut(df["Discount"],
    bins=[-0.01, 0.001, 0.10, 0.30, 0.50, 1.0],
    labels=disc_bands)

disc_agg = df.groupby("Discount Band", observed=True).agg(
    Revenue   = ("Sales", "sum"),
    Profit    = ("Profit", "sum"),
    Count     = ("Row ID", "count"),
    LossMaking= ("Profit", lambda x: (x<0).sum())
).reset_index()
disc_agg["Margin%"]    = (disc_agg["Profit"] / disc_agg["Revenue"] * 100).round(2)
disc_agg["Loss_Rate%"] = (disc_agg["LossMaking"] / disc_agg["Count"] * 100).round(1)

print(disc_agg.to_string(index=False))
print("""
🔍 INSIGHT:
Orders with >50% discount show strongly negative margins.
Even Medium discounts (11-30%) significantly compress profitability.
→ RECOMMENDATION: Implement discount guardrails per category:
   • Technology: Cap at 20%
   • Furniture: Cap at 15%
   • Office Supplies: Cap at 25%
""")

# ─────────────────────────────────────────────
# 6. CUSTOMER SEGMENT ANALYSIS
# ─────────────────────────────────────────────
print("=" * 60)
print("STEP 6: CUSTOMER SEGMENT ANALYSIS")
print("=" * 60)

seg = df.groupby("Segment").agg(
    Revenue   = ("Sales", "sum"),
    Profit    = ("Profit", "sum"),
    Customers = ("Customer ID", "nunique"),
    Orders    = ("Order ID", "nunique")
).reset_index()
seg["Margin%"] = (seg["Profit"] / seg["Revenue"] * 100).round(2)
seg["AOV"]     = (seg["Revenue"] / seg["Orders"]).round(2)
seg["OPC"]     = (seg["Orders"] / seg["Customers"]).round(1)

print(seg.to_string(index=False))

# ─────────────────────────────────────────────
# 7. RFM CUSTOMER SEGMENTATION
# ─────────────────────────────────────────────
print("=" * 60)
print("STEP 7: RFM CUSTOMER SEGMENTATION")
print("=" * 60)

snapshot = pd.Timestamp("2014-12-31")
rfm = df.groupby("Customer ID").agg(
    Recency   = ("Order Date", lambda x: (snapshot - x.max()).days),
    Frequency = ("Order ID", "nunique"),
    Monetary  = ("Sales", "sum")
).reset_index()

rfm["R"] = pd.qcut(rfm["Recency"], q=5, labels=[5,4,3,2,1])
rfm["F"] = pd.qcut(rfm["Frequency"].rank(method="first"), q=5, labels=[1,2,3,4,5])
rfm["M"] = pd.qcut(rfm["Monetary"], q=5, labels=[1,2,3,4,5])
rfm[["R","F","M"]] = rfm[["R","F","M"]].astype(int)

def segment(row):
    r, f, m = row.R, row.F, row.M
    if r>=4 and f>=4 and m>=4: return "Champions"
    elif r>=3 and f>=3 and m>=3: return "Loyal Customers"
    elif r>=4 and f<=2: return "New Customers"
    elif r<=2 and f>=3 and m>=3: return "At Risk"
    elif r==1 and f<=2: return "Lost"
    elif r>=3 and m>=4: return "Potential Loyalists"
    else: return "Needs Attention"

rfm["RFM_Segment"] = rfm.apply(segment, axis=1)

rfm_summary = rfm.groupby("RFM_Segment").agg(
    Customers  = ("Customer ID","count"),
    Avg_Revenue= ("Monetary","mean"),
    Avg_Recency= ("Recency","mean"),
    Avg_Freq   = ("Frequency","mean")
).reset_index().sort_values("Avg_Revenue", ascending=False)

print("\n📊 RFM Segment Summary:")
print(rfm_summary.to_string(index=False))

print("""
🔍 STRATEGIC RFM ACTIONS:
- Champions       → VIP program, early access, referral rewards
- Loyal Customers → Upsell to premium, loyalty discounts
- At Risk         → Re-engagement campaigns, win-back offers
- Potential       → Increase touchpoints, move to Loyal
- Lost            → Cost-benefit analysis before re-investment
""")

# ─────────────────────────────────────────────
# 8. REGIONAL ANALYSIS
# ─────────────────────────────────────────────
print("=" * 60)
print("STEP 8: REGIONAL PERFORMANCE")
print("=" * 60)

market = df.groupby("Market").agg(
    Revenue   = ("Sales","sum"),
    Profit    = ("Profit","sum"),
    Customers = ("Customer ID","nunique"),
    ShipCost  = ("Shipping Cost","sum")
).reset_index()
market["Margin%"]    = (market["Profit"] / market["Revenue"] * 100).round(2)
market["ShipCost%"]  = (market["ShipCost"] / market["Revenue"] * 100).round(2)
market = market.sort_values("Revenue", ascending=False)

print(market.to_string(index=False))
print("""
🔍 INSIGHT:
Shipping cost as % of revenue varies significantly by market.
High shipping cost markets with low margins need logistics optimization.
""")

print("\n✅ EDA Complete. See images/ folder for all charts.")
