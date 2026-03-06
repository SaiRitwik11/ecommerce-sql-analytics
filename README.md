# Ecommerce Sales Analytics — SQL Project

## Overview
End-to-end SQL analysis on a 5-table ecommerce database answering 
25 business questions across 6 categories.

**Tools:** MySQL 8.0, MySQL Workbench  
**Skills:** Joins, CTEs, Window Functions (LAG, SUM OVER), 
CASE WHEN, Subqueries, Date Functions, Aggregations

---

## Key Findings
- **Total Revenue:** $2,757,346 gross | $2,049,059 net (after returns)
- **Revenue Lost to Returns:** ~$708K (25.7% of gross revenue)
- **Average Order Value:** $3,232
- **Repeat Customer Rate:** 95.98% — extremely high loyalty
- **Highest Revenue Region:** Asia East — $331,933 (16.2% of total)
- **Worst Return Region:** North America — 32% return rate
- **Worst Return Category:** Footwear — 28% return rate
- **Top Customer:** Melanie Davis — $41,882 lifetime value

---

## Business Questions Answered

### Section 1: General Sales Insights
- Total revenue generated (gross and net)
- Revenue by product and category
- Monthly revenue trends
- Average Order Value (overall and monthly)
- Average order size by region

### Section 2: Customer Insights
- Top 10 customers by revenue
- Repeat customer rate
- Average time between orders (region-wise) — LAG Window Function
- Customer segmentation: Platinum / Gold / Silver / Bronze
- Customer Lifetime Value (CLV)

### Section 3: Product & Order Insights
- Top 10 products by quantity sold
- Top 10 products by revenue
- Products with highest return rate
- Return rate by category
- Average product price by region
- Monthly sales trend per category

### Section 4: Temporal Trends
- Monthly sales trends
- AOV change by month

### Section 5: Regional Insights
- Regions ranked by order volume
- Revenue per region with % of total (Window Function)

### Section 6: Return & Refund Insights
- Return rate and revenue lost by category
- Return rate and revenue lost by region
- Customers with most frequent returns

---

## SQL Skills Demonstrated
| Skill | Queries |
|-------|---------|
| Multi-table JOINs (up to 5 tables) | Throughout |
| CTE (WITH clause) | 2.3, 2.4 |
| LAG() Window Function | 2.3 |
| SUM() OVER() — % of total | 5.2 |
| CASE WHEN | 2.4, 6.1, 6.2 |
| Subquery | 2.2 |
| DATEDIFF | 2.3 |

---

## Dataset
The data used in this project is a custom ecommerce dataset provided as a SQL script. It includes 5 tables: `Regions`, `Customers`, `Products`, `Orders`, and `OrderDetails` with pre-populated sample data.

---

## How to Run
1. Install MySQL 8.0 + MySQL Workbench.
2. Download the `ecommerce_data_setup.sql` file from this repository.
3. Open the file in MySQL Workbench and execute it. This will automatically create the `final_project_ecommerce` database and populate all 5 tables.
4. Open `ecommerce_analysis.sql` and run the queries section by section to view the analysis.

---
**Jannu Sai Ritwik** | Data Analyst  
[[Linkedin]](https://www.linkedin.com/in/jannu-sai-ritwik-339749201/) | Hyderabad
