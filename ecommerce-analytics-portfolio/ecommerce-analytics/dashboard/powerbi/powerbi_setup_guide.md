# Power BI Dashboard Setup Guide
## E-Commerce Sales Performance Analysis — Global Superstore

---

## Overview

This guide covers the complete Power BI dashboard setup for the Global Superstore analytics project. The dashboard comprises **4 executive-ready pages** designed for leadership consumption.

---

## Step 1: Data Import

1. Open Power BI Desktop
2. **Get Data → Text/CSV**
3. Load: `data/cleaned/superstore_cleaned.csv`
4. In Power Query Editor, confirm these data types:
   - `Order Date` → Date
   - `Ship Date` → Date
   - `Sales` → Decimal Number
   - `Profit` → Decimal Number
   - `Discount` → Decimal Number
   - `Quantity` → Whole Number
   - `Shipping Cost` → Decimal Number
5. Click **Close & Apply**

---

## Step 2: Data Model

### Calculated Columns (Add in Data View)

```dax
// Profit Margin %
Profit Margin % = DIVIDE([Profit], [Sales], 0) * 100

// Days to Ship
Days to Ship = DATEDIFF([Order Date], [Ship Date], DAY)

// Discount Band
Discount Band = 
SWITCH(TRUE(),
    [Discount] = 0,              "No Discount",
    [Discount] <= 0.10,          "Low (1-10%)",
    [Discount] <= 0.30,          "Medium (11-30%)",
    [Discount] <= 0.50,          "High (31-50%)",
                                 "Very High (>50%)"
)

// Is Loss Making
Is Loss Making = IF([Profit] < 0, 1, 0)

// Year-Quarter Label
YQ Label = YEAR([Order Date]) & " Q" & QUARTER([Order Date])
```

---

## Step 3: DAX Measures

Create a **Measures Table** (blank table named "_Measures") and add all measures there.

### Core Financial Measures

```dax
// ─── REVENUE ───────────────────────────────
Total Revenue = SUM(superstore_cleaned[Sales])

Revenue LY = 
CALCULATE(
    [Total Revenue],
    SAMEPERIODLASTYEAR(superstore_cleaned[Order Date])
)

Revenue Growth % = 
DIVIDE(
    [Total Revenue] - [Revenue LY],
    [Revenue LY],
    BLANK()
)

// ─── PROFIT ────────────────────────────────
Total Profit = SUM(superstore_cleaned[Profit])

Profit Margin % = 
DIVIDE([Total Profit], [Total Revenue], 0) * 100

// ─── ORDERS ────────────────────────────────
Total Orders = DISTINCTCOUNT(superstore_cleaned[Order ID])

Avg Order Value = DIVIDE([Total Revenue], [Total Orders], 0)

// ─── CUSTOMERS ─────────────────────────────
Total Customers = DISTINCTCOUNT(superstore_cleaned[Customer ID])

Repeat Customers = 
CALCULATE(
    DISTINCTCOUNT(superstore_cleaned[Customer ID]),
    FILTER(
        VALUES(superstore_cleaned[Customer ID]),
        CALCULATE(DISTINCTCOUNT(superstore_cleaned[Order ID])) > 1
    )
)

Repeat Customer Rate % = 
DIVIDE([Repeat Customers], [Total Customers], 0) * 100

// ─── SHIPPING ──────────────────────────────
Total Shipping Cost = SUM(superstore_cleaned[Shipping Cost])

Shipping Cost % Revenue = 
DIVIDE([Total Shipping Cost], [Total Revenue], 0) * 100

// ─── UNITS ─────────────────────────────────
Total Units = SUM(superstore_cleaned[Quantity])
```

### KPI Card Measures (for formatting)

```dax
// Revenue formatted
Revenue Card = 
"$" & FORMAT([Total Revenue]/1000000, "#,##0.0") & "M"

// Profit formatted  
Profit Card = 
"$" & FORMAT([Total Profit]/1000000, "#,##0.00") & "M"

// Margin formatted
Margin Card = FORMAT([Profit Margin %], "#,##0.0") & "%"

// Growth indicator
Growth Indicator = 
IF([Revenue Growth %] > 0, "▲ " & FORMAT([Revenue Growth %]*100, "#,##0.0") & "%",
   IF([Revenue Growth %] < 0, "▼ " & FORMAT(ABS([Revenue Growth %]*100), "#,##0.0") & "%",
   "— 0.0%"))
```

### RFM Segment Measure (for Customer Page)

```dax
// RFM Snapshot Date
Snapshot Date = DATE(2014, 12, 31)

// Days Since Last Purchase
Recency Days = 
DATEDIFF(
    CALCULATE(MAX(superstore_cleaned[Order Date])),
    DATE(2014,12,31),
    DAY
)
```

---

## Step 4: Dashboard Pages

### PAGE 1 — Executive Overview

**Layout:** 3-column grid

**Top Row — KPI Cards (6 cards):**
| Card | Measure | Format |
|---|---|---|
| Total Revenue | Total Revenue | $#,##0.0M |
| Total Profit | Total Profit | $#,##0.0M |
| Profit Margin | Profit Margin % | #0.0% |
| Total Orders | Total Orders | #,##0 |
| Avg Order Value | Avg Order Value | $#,##0 |
| YoY Revenue Growth | Revenue Growth % | +#0.0% |

**Middle Row:**
- **Line Chart:** Monthly Revenue & Profit Trend (X: Order Date Month, Y: Revenue + Profit, Legend: Year)
- **Column Chart:** Annual Revenue vs Profit (X: Year, Y: Revenue, Profit — grouped columns)

**Bottom Row:**
- **Waterfall Chart:** Revenue decomposition by Category
- **Clustered Bar:** Revenue & Margin by Segment

**Filters/Slicers:** Year (Top right), Segment (Top right)

---

### PAGE 2 — Customer Analytics

**Top Row — KPI Cards:**
- Total Customers | Repeat Customer Rate | Avg Order Value by Segment

**Middle Left:** 
- **Treemap:** Customer Revenue by Segment (Consumer/Corporate/Home Office)
- Use color: Blue = Consumer, Teal = Corporate, Amber = Home Office

**Middle Right:**
- **Bar Chart:** Top 15 Customers by Revenue
- Show: Customer Name, Revenue, color by Segment

**Bottom Left:**
- **Donut Chart:** Customer mix by Segment (count and revenue)

**Bottom Right:**
- **Table:** RFM Segment Summary (import from `python/exports/rfm_segment_summary.csv`)
  - Columns: RFM Segment | Customers | Avg Revenue | Strategic Action
  - Apply conditional formatting: Champions = Blue, At Risk = Red

---

### PAGE 3 — Product Analytics

**Top Row — KPI Cards:**
- Top Category by Revenue | Top Sub-Category | Avg Margin % | Loss-Making Orders Count

**Middle Left:**
- **Clustered Bar:** Revenue & Profit by Category
- **Bar Chart:** Sub-Category Margin % ranking (sorted ascending)
  - Conditional formatting: Red if < 0%, Yellow if < 5%, Green if > 10%

**Middle Right:**
- **Scatter Chart:** Products — Revenue (X) vs Margin % (Y)
  - Size = Quantity, Color = Category
  - Reference line at Y=0 (zero margin)

**Bottom:**
- **Matrix:** Category × Year showing Revenue, Profit, and Margin %

**Slicer:** Category (top right)

---

### PAGE 4 — Regional Analytics

**Top Row — KPI Cards:**
- Top Market by Revenue | Top Market by Margin | Markets with Negative Profit

**Main Visual:**
- **Map (Filled/Bubble):** Revenue by Country
  - Use Country field for geography
  - Bubble size = Revenue, Color = Margin %
  - Color scale: Red (low margin) → Green (high margin)

**Bottom Left:**
- **Clustered Bar:** Revenue by Market (sorted descending)
- Secondary axis: Margin %

**Bottom Right:**
- **Stacked Bar:** Revenue by Market × Category mix

**Matrix:** Market | Revenue | Profit | Margin % | Ship Cost % | Strategic Flag

---

## Step 5: Formatting Guidelines

### Color Palette
```
Primary Blue   : #2563EB  (main data)
Teal           : #0D9488  (secondary)
Amber          : #F59E0B  (warning/highlight)
Red            : #EF4444  (negative/loss)
Background     : #F9FAFB  (page background)
Card Background: #FFFFFF
Border         : #E5E7EB
Dark Text      : #111827
Gray Text      : #6B7280
```

### Typography
- Page Title: Segoe UI Semibold, 18pt, Dark
- Section Headers: Segoe UI Semibold, 14pt, Dark
- KPI Values: Segoe UI Bold, 24–28pt, Brand Color
- KPI Labels: Segoe UI, 11pt, Gray
- Body/Table text: Segoe UI, 10pt

### Design Rules
1. **Never** use rainbow colors — use the 5-color palette only
2. **Always** label KPI cards with context ("vs Last Year")
3. **Avoid** 3D charts — they distort perception
4. **Include** a subtitle on every page explaining what the page shows
5. **Use** thin borders (1px, #E5E7EB) on all cards
6. **Align** all visuals to an 8-point grid

### Navigation
- Add page navigation buttons (top right of each page)
- Use consistent icon style: filled, white, blue background
- Include company logo placeholder (top left)

---

## Step 6: Publishing

1. **Save** as `dashboard/powerbi/superstore_dashboard.pbix`
2. **Export screenshots** of each page to `dashboard/screenshots/`
3. **Export PDF** version to `reports/executive-summary/`
4. If publishing to Power BI Service:
   - Workspace: Analytics Portfolio
   - Row-level security: Not required for portfolio
   - Schedule refresh: N/A (static CSV)

---

## DAX Best Practices Applied

- All measures use `DIVIDE()` instead of `/` to handle division by zero
- Context-aware measures using `CALCULATE()` with proper filter context
- Formatting measures separate from calculation measures
- Measures stored in dedicated `_Measures` table (not in data table)
- No circular dependencies between measures
