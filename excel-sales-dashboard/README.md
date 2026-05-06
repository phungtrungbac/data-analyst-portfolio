# Excel Sales Dashboard

## Overview
This project analyzes sales performance using Microsoft Excel to identify revenue sources, weak regions, and products with high sales but low profitability. The dashboard was built to turn raw transaction data into a clear business story.

## Business Question
- Where does the revenue come from?
- Which region is underperforming?
- Which products sell well but generate low profit?

## Data Preparation
- Checked the dataset size and basic data quality.
- Converted Order Date to Date format.
- Converted Sales and Profit to numeric format.
- Created `Month` using `TEXT([Order Date], "mmm")`.
- Created `Year` using `YEAR([Order Date])`.
- Verified whether Sales and Profit contain negative values.

## Analysis
- Built Pivot Table 1 for monthly sales trend.
- Built Pivot Table 2 for sales by region.
- Built Pivot Table 3 for sales and profit by category.
- Designed a dashboard with KPI cards and pivot charts.
- Compared sales volume against profitability to identify performance gaps.

## Insight
- One or more categories may show high sales but low profit, indicating margin pressure.
- One region may contribute less sales than the others and should be reviewed.
- Monthly sales may show seasonality, with some months consistently stronger than others.

## Action
- Review pricing, discount, and cost structure for low-profit high-sales categories.
- Investigate weak regions and improve local sales execution.
- Use seasonal patterns for campaign timing and inventory planning.

## Files
- `dashboard.xlsx` - Excel dashboard file.
- `dashboard.png` - dashboard preview image.
- `data/sales_data.xlsx` - source data, if included.

## Tools
- Microsoft Excel
