# Excel Sales Dashboard

## Overview
This project analyzes sales performance using the Global Superstore dataset to identify revenue sources, underperforming regions, and product categories with high sales but low profit.

## Business Question
- Where does the revenue come from?
- Which region is underperforming?
- Which products sell well but generate low profit?

## Data Preparation
- Reviewed the dataset structure and checked data quality.
- Converted `Order Date` to Date format.
- Converted `Sales` and `Profit` to numeric format.
- Created `Month` using `TEXT([Order Date], "mmm")`.
- Created `Year` using `YEAR([Order Date])`.
- Checked for negative values in `Sales` and `Profit`.

## Analysis
- Built a monthly sales trend pivot table.
- Built a sales by region pivot table.
- Built a sales and profit by category pivot table.
- Designed a dashboard with KPI cards and pivot charts.
- Compared sales and profit to identify margin issues.

## Insight
- Technology is likely to drive the highest revenue and profit.
- The South region is expected to be the weakest-performing area.
- Furniture may show high sales but comparatively low profit.
- Sales may show clear seasonality across months.

## Action
- Review pricing and discount strategy for low-profit categories.
- Investigate weak regions and improve local sales execution.
- Use seasonal patterns to plan marketing and inventory.
- Focus on profitable categories to maximize margin.

## Files
- `dashboard.xlsx`
- `dashboard.png`
- `data/sales_data.xlsx`
- `images/dashboard_preview.png`

## Tools
- Microsoft Excel
