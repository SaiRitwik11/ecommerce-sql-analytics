-- ================================================
-- ECOMMERCE SALES ANALYSIS — SQL PROJECT
-- Analyst: Jannu Sai Ritwik
-- Course: TuteDude SQL — Module 17
-- Date: March 2026
-- Tables: Customers, Products, Orders, OrderDetails, Regions
-- ================================================

USE ecommerce_analysis;

-- ================================================
-- SECTION 1: GENERAL SALES INSIGHTS
-- ================================================
-- 1.1. What is the total revenue generated over the entire period? (Revenue = price * quantity)
-- Business Purpose: The most basic KPI of any business. How much money did we make in total?
-- ================================================

Select Round(sum( P.Price * OD.Quantity), 2) as Total_Revenue
from orderdetails as OD
Join products as P
on P.ProductID = OD.ProductID;

-- Result: Total revenue = $2757346.10


-- ================================================
-- 1.2. Revenue Excluding Returned Orders
-- Business Purpose: Net revenue after removing returns. More accurate picture of real earnings.
-- ================================================

Select Round(sum( P.Price * OD.Quantity), 2) as Revenue_excluding_returns
from orderdetails as OD
Join products as P
on P.ProductID = OD.ProductID
Join orders O 
on O.OrderID = OD.OrderID
where IsReturned = False;

-- Result: Revenue_excluding_returns = $2049059.34


-- ================================================
-- 1.3. Total Revenue per Year / Month
-- Business Purpose: Shows revenue trend over time — is the business growing?
-- ================================================

Select Year(O.OrderDate) as year, Month(O.OrderDate) as month,
	Round(sum( P.Price * OD.Quantity), 2) as Monthly_Revenue
from orderdetails as OD
Join products as P
on P.ProductID = OD.ProductID
Join orders O 
on O.OrderID = OD.OrderID
Group By year, month
Order by year, month;

-- Result:
-- year | month | Monthly_Revenue
-- 2023 | 4     | 39713.09
-- 2023 | 5     | 124524.86
-- 2023 | 6     | 117307.11
-- ... (Total 25 rows)


-- ================================================
-- 1.4. Revenue by Product / Category
-- Business Purpose: Identifies the top revenue-generating products within each category to understand specific item performance.
-- ================================================

Select ProductName, Category,
	Round(sum( P.Price * OD.Quantity), 2) as Revenue_by_Category
from orderdetails as OD
Join products as P
on P.ProductID = OD.ProductID
Group By ProductName, Category
Order by Category,ProductName;

-- Result:
-- ProductName | Category    | Revenue_by_Category
-- Bag H       | Accessories | 43824.08
-- Bag P       | Accessories | 30981.23
-- Bag T       | Accessories | 51060.67
-- ... (Total 91 rows)


-- ================================================
-- 1.5. What is the average order value (AOV) across all orders?
-- Business Purpose: AOV is one of the most tracked ecommerce KPIs. Higher AOV = more revenue per customer visit
-- ================================================

select Round(sum( P.Price * OD.Quantity) / Count(Distinct OD.OrderID), 2) as Average_Order_Value
from orderdetails as OD
Join products as P
on P.ProductID = OD.ProductID;

-- Result: Average_Order_Value = $3232.53


-- ================================================
-- 1.6. AOV per Year / Month
-- Business Purpose: Is average order value increasing over time? Shows if customers are spending more per visit.
-- ================================================

select Year(OrderDate) as year, Month(OrderDate) as month,
	Round(sum( P.Price * OD.Quantity) / Count(Distinct OD.OrderID), 2) as AOV_by_Year_and_Month
from orderdetails as OD
Join products as P on P.ProductID = OD.ProductID
Join orders as O on O.OrderID = OD.OrderID
Group by year, month
Order by year, month;

-- Result: 
-- year | month | AOV_by_Year_and_Month
-- 2023 | 4     | 2090.16
-- 2023 | 5     | 2964.88
-- 2023 | 6     | 2728.07
-- ... (Total 25 rows)


-- ================================================
-- 1.7. What is the average order size by region?
-- Business Purpose: Do customers in some regions buy more items per order than others?
-- ================================================

Select R.RegionName,
	Round(sum(OD.Quantity) / Count(Distinct O.OrderID), 2) as Average_order_size
from orders as O
Join customers as C on C.CustomerID = O.CustomerID
Join orderdetails as OD on OD.OrderID = O.OrderID
Join regions R on R.RegionID = C.RegionID
Group by R.RegionName
Order by Average_order_size desc;

-- Result: 
-- RegionName  | Average_order_size
-- Asia East   | 7.64	
-- Asia South  | 7.61
-- Europe West | 7.59
-- ... (Total 10 rows)


-- ================================================
-- SECTION 2: Customer Insights
-- ================================================
-- 2.1. Who are the top 10 customers by total revenue spent?
-- Business Purpose: Who are your most valuable customers? These need VIP treatment.
-- ================================================

select C.CustomerID, C.CustomerName, 
	Round(sum( P.Price * OD.Quantity), 2) as Total_Revenue_Spent
from customers as C
Join orders as O on O.CustomerID = C.CustomerID
Join orderdetails as OD on OD.OrderID = O.OrderID
Join products as P on P.ProductID = OD.ProductID
where O.IsReturned = False
Group by C.CustomerID, CustomerName
Order by Total_Revenue_Spent Desc
Limit 10;

-- Result:
-- CustomerID | CustomerName  		| Total_Revenue_Spent
-- 178        | Melanie Davis 		| 41882.31
-- 70         | Dawn Fowler 		| 33502.85
-- 136        | Katherine Coleman   | 32474.46
-- ... (Total 10 rows)


-- ================================================
-- 2.2. What is the repeat customer rate? [Repeat Customer Rate = (Customers with more than 1 order) / (Customers wtih atleast 1 order)]
-- Business Purpose: What percentage of customers order more than once? Higher = better loyalty.
-- ================================================

Select Round(Sum(Case when order_count > 1 then 1 else 0 End) * 100/ Count(CustomerID), 2) as Repeat_Customer_rate
from (
	Select CustomerID, Count( Distinct OrderID) as order_count
	from orders
	Group by CustomerID) as T;
    
-- Result: Repeat_Customer_rate = 95.98


-- ================================================
-- 2.3. What is the average time between two consecutive orders for the same customer Region-wise?
-- Business Purpose: How frequently do customers in each region reorder? Helps plan marketing campaigns.
-- ================================================

With Customer_orders as (
			select C.CustomerID, C.RegionID, O.OrderDate,
				lag(O.OrderDate) Over (Partition by C.CustomerID Order by O.OrderDate) as Previous_Date
			from customers as C
            Join orders as O on O.CustomerID = C.CustomerID)

Select R.RegionName,
	Round(avg(DateDiff(OrderDate, Previous_Date)), 2) as Avg_time_between_orders
from Customer_orders as CO
Join regions as R on R.RegionID = CO.RegionID
where Previous_Date is NOT NULL
Group by R.RegionName
Order by Avg_time_between_orders;

-- Result:
-- RegionName 		| Avg_time_between_orders
-- South America	|  85.56
-- Europe Central	|  92.12
-- Asia South		|  107.31
-- ... (Total 10 rows)

-- ================================================
-- 2.4. Customer Segmentation by Total Spend
-- Platinum: > 1500 | Gold: 1000-1500 | Silver: 500-999 | Bronze: < 500
-- Business Purpose: Group customers into VIP tiers based on spending so the marketing team can send targeted promotional emails.
-- ================================================

With Customer_spent as (
	select C.CustomerID, C.CustomerName,
		Round(sum( P.Price * OD.Quantity), 2) as Total_spent
	from customers as C
	Join orders as O on O.CustomerID = C.CustomerID
	Join orderdetails as OD on OD.OrderID = O.OrderID
	Join products as P on P.ProductID = OD.ProductID
	where O.IsReturned = False
	Group by C.CustomerID, C.CustomerName)
    
select *, 
	Case 
		when Total_spent > 1500 then "Platinum"
        when Total_spent >= 1000 then "Gold"
        when Total_spent >= 500 then "Silver"
        Else "Bronze"
	End as Customer_Segmentation
from Customer_Spent
Order by Total_spent desc;


-- Result:
-- CustomerID | CustomerName  | Total_spent | Customer_Segmentation
-- 178        | Melanie Davis | 41882.31    | Platinum
-- 70         | Dawn Fowler   | 33502.85    | Platinum
-- 136        | Katherine ... | 32474.46    | Platinum
-- ... (Total 192 rows)



-- ================================================
-- 2.5. What is the customer lifetime value (CLV)?
-- Business Purpose: What is each customer worth over their entire relationship with the business?
-- ================================================

Select C.CustomerID, C.CustomerName,
	Round(sum(OD.Quantity * P.Price), 2) as CLV
from orders as O
Join orderdetails as OD on OD.OrderID = O.OrderID
Join customers as C on C.CustomerID = O.CustomerID
Join products as P on P.ProductID = OD.ProductID
where O.IsReturned = False
Group by CustomerID, CustomerName
Order by CLV desc;

-- Result:
-- CustomerID | CustomerName      | CLV
-- 178        | Melanie Davis     | 41882.31
-- 70         | Dawn Fowler       | 33502.85
-- 136        | Katherine Coleman | 32474.46
-- ... (Total 192 rows)


-- ================================================
-- SECTION 3: Product & Order Insights
-- ================================================
-- 3.1. What are the top 10 most sold products (by quantity)?
-- Business Purpose: Identifies the most popular items by volume. This is crucial for inventory management and restocking.
-- ================================================

select P.ProductID, P.ProductName,
	sum(OD.Quantity) as Total_quantity
from products as P
Join orderdetails as OD
on OD.ProductID = P.ProductID
Group by P.ProductID, P.ProductName
Order by Total_quantity desc
Limit 10;

-- Result:
-- ProductID | ProductName      | Total_quantity
-- 64        | Smartphone M     | 100
-- 10        | Bag K      		| 93
-- 90        | Watch M			| 91
-- ... (Total 10 rows)


-- ================================================
-- 3.2. What are the top 10 most sold products (by revenue)?
-- Business Purpose: Identifies the highest-grossing products to determine where the company should focus its marketing budget.
-- ================================================

select P.ProductID, P.ProductName,
	Round(sum(OD.Quantity * P.Price), 2) as Revenue
from products as P
Join orderdetails as OD on OD.ProductID = P.ProductID
Join orders as O on O.OrderID = OD.OrderID
where O.IsReturned = False
Group by P.ProductID, P.ProductName
Order by Revenue desc
Limit 10;

-- Result:
-- ProductID | ProductName      | Revenue
-- 64        | Smartphone M     | 71330.56
-- 50        | Bag Y      		| 59264.41
-- 38        | Watch M			| 53895.60
-- ... (Total 10 rows)


-- ================================================
-- 3.3. Which products have the highest return rate?
-- Business Purpose: Which products get returned most? High returns = product quality issue or misleadinglisting.
-- ================================================

Select P.ProductID, P.ProductName,
	Round(sum(Case when O.IsReturned = 1 then OD.Quantity Else 0 End) / sum(OD.Quantity), 2) as Return_Rate
from Products as P
Join orderdetails as OD on OD.ProductID = P.ProductID
Join Orders as O on O.OrderID = OD.OrderID
Group by P.ProductID, P.ProductName
Order by Return_Rate desc
Limit 10;

-- Result:
-- ProductID | ProductName | Return_Rate
-- 74        | Laptop W    | 0.50
-- 52        | Shirt A     | 0.45
-- 47        | Watch V     | 0.44
-- ... (Total 10 rows)

-- ================================================
-- 3.4. Return Rate by Category
-- Business Purpose: Which categories have the worst return rates? Helps identify broad quality control issues.
-- ================================================

Select P.Category,
	Round(sum(Case when O.IsReturned = 1 then OD.Quantity Else 0 End) / sum(OD.Quantity), 2) as Return_Rate
from Products as P
Join orderdetails as OD on OD.ProductID = P.ProductID
Join Orders as O on O.OrderID = OD.OrderID
Group by P.Category
Order by Return_Rate desc;

-- Result:
-- Category    | Return_Rate
-- Footwear    | 0.28
-- Home        | 0.27
-- Clothing    | 0.26
-- ... (Total 6 rows)


-- ================================================
-- 3.5. What is the average price of products per region?
-- Business Purpose: Determine the average price point of items sold in each region to understand regional purchasing power and pricing strategy.
-- ================================================

Select R.RegionName, 
	Round(sum(P.Price * OD.Quantity) / sum(OD.Quantity), 2) as Average_price_by_region
from products as P
Join orderdetails as OD on OD.ProductID = P.ProductID
Join orders as O on O.OrderID = OD.OrderID
Join customers as C on C.CustomerID = O.CustomerID
Join regions as R on R.RegionID = C.RegionID
where O.IsReturned = False
Group by R.RegionName
Order by Average_price_by_region desc;

-- Result:
-- RegionName     | Average_price_by_region
-- Europe Central | 469.15
-- Africa North   | 467.96
-- Asia East      | 466.20
-- ... (Total 10 rows)


-- ================================================
-- 3.6. What is the sales trend for each product category?
-- Business Purpose: Track monthly sales trends by category to identify seasonal growth, decline, and overall revenue trajectory.
-- ================================================

Select P.Category, Year(O.OrderDate) as year, Month(O.OrderDate) as month,
	Round(sum(OD.Quantity * P.Price), 2) as sales
from products as P
Join orderdetails as OD on OD.ProductID = P.ProductID
Join orders as O on O.OrderID = OD.OrderID
where O.IsReturned = False
Group by P.Category, year, month
Order by P.Category, year, month;

-- Result:
-- Category    | year | month | sales
-- Accessories | 2023 | 4     | 6666.35
-- Accessories | 2023 | 5     | 9053.42
-- Accessories | 2023 | 6     | 10990.34
-- ... (Total 150 rows)


-- ================================================
-- SECTION 4: Temporal Trends
-- ================================================
-- 4.1. What are the monthly sales trends over the past year?
-- Business Purpose: Shows revenue growth/decline month by month. 
-- ================================================

Select Year(OrderDate) as year, Month(OrderDate) as month, 
	Round(sum( OD.Quantity * P.Price), 2) as Sales
from orders O
Join orderdetails as OD on OD.OrderID = O.OrderID
Join products as P on P.ProductID = OD.ProductID
where O.IsReturned = False
Group by year, month
Order by year, month;

-- Result:
-- year | month | Sales
-- 2023 | 4     | 34769.35
-- 2023 | 5     | 71052.03
-- 2023 | 6     | 79669.12
-- ... (Total 25 rows)


-- ================================================
-- 4.2. How does the average order value (AOV) change by month or week?
-- Business Purpose:  Track if customers are spending more or less per checkout over time. Helps evaluate the success of upselling and cross-selling strategies.
-- ================================================

Select Year(OrderDate) as year, Month(O.OrderDate) as month, 
	Round((sum(OD.Quantity * P.Price) / COUNT(DISTINCT O.OrderId)), 2) as AOV
from Orders as O
Join orderdetails as OD on OD.OrderID = O.OrderID
Join products as P on P.ProductID = OD.ProductID
where O.IsReturned = False
Group by year, month
Order by year, month;

-- Result:
-- year | month | AOV
-- 2023 | 4     | 2173.08
-- 2023 | 5     | 2537.57
-- 2023 | 6     | 2414.22
-- ... (Total 25 rows)


-- ================================================
-- SECTION 5: Regional Insights
-- ================================================
-- 5.1. Which regions have the highest order volume and which have the lowest?
-- Business Purpose: Identifies key geographic markets to optimize shipping logistics and target regional marketing efforts.
-- ================================================

Select R.RegionName,
	count(Distinct O.OrderID) as Order_Volume
from orders as O
Join customers as C on C.CustomerID = O.CustomerID
Join regions as R on R.RegionID = C.RegionID
WHERE O.IsReturned = False
Group by R.RegionName
Order by Order_Volume desc;

-- Result:
-- RegionName   | Order_Volume
-- Asia East    | 93
-- Oceania      | 80
-- Africa North | 74
-- ... (Total 10 rows)


-- ================================================
-- 5.2. What is the revenue per region and how does it compare across different regions?
-- Business Purpose: Identify which regions drive the most revenue to properly allocate global marketing budgets.
-- ================================================
Select R.RegionName,
	Round(sum(OD.Quantity * P.Price), 2) as Revenue,
    ROUND((SUM(OD.Quantity * P.Price) / SUM(SUM(OD.Quantity * P.Price)) OVER()) * 100, 2) AS Percent_of_Total_revenue
from orderdetails as OD
Join orders as O on OD.OrderID = O.OrderID
Join products as P on P.ProductID = OD.ProductID
Join customers as C on C.CustomerID = O.CustomerID
Join regions as R on R.RegionID = C.RegionID
WHERE O.IsReturned = False
Group by R.RegionName
Order by Revenue desc;

-- Result:
-- RegionName    | Revenue   | Percent_of_Total_revenue
-- Asia East     | 331933.70 | 16.20
-- Oceania       | 266612.71 | 13.01
-- Africa North  | 257376.62 | 12.56
-- ... (Total 10 rows)


-- ================================================
-- SECTION 6: Return & Refund Insights
-- ================================================
-- 6.1. What is the overall return rate by product category?
-- Business Purpose: Identify which product categories have the highest return rates and quantify the exact dollar amount of revenue lost to those returns.
-- ================================================

Select P.Category,
	Round(sum(case when O.IsReturned = 1 then OD.Quantity else 0 End) / sum(OD.Quantity), 2) as return_rate,
    Round(sum(case when O.IsReturned = 1 then (OD.Quantity *P.Price) else 0 End) , 2) as revenue_lost
from products as P
Join orderdetails as OD on OD.ProductID = P.ProductID
Join orders as O on O.OrderID = OD.OrderID
Group by P.Category
Order by return_rate desc;

-- Result:
-- Category    | return_rate | revenue_lost
-- Footwear    | 0.28        | 127675.23
-- Home        | 0.27        | 149381.85
-- Clothing    | 0.26        | 96591.32
-- ... (Total 6 rows)


-- ================================================
-- 6.2. What is the overall return rate by region?
-- Business Purpose: Pinpoint which geographic areas suffer the most returns to investigate potential regional issues (e.g., shipping damage, localized sizing differences) and assess the financial impact.
-- ================================================

Select R.RegionName,
	Round(sum(case when O.IsReturned = 1 then OD.Quantity else 0 End) / sum(OD.Quantity), 2) as return_rate_by_region,
    Round(sum(case when O.IsReturned = 1 then (OD.Quantity *P.Price) else 0 End) , 2) as revenue_lost_by_region
from products as P
Join orderdetails as OD on OD.ProductID = P.ProductID
Join orders as O on O.OrderID = OD.OrderID
Join customers as C on C.CustomerID = O.CustomerID
Join regions as R on R.RegionID = C.RegionID
Group by R.RegionName
Order by return_rate_by_region desc;

-- Result:
-- RegionName     | return_rate_by_region | revenue_lost_by_region
-- North America  | 0.32                  | 76188.15
-- South America  | 0.31                  | 84438.39
-- Europe Central | 0.29                  | 78391.85
-- ... (Total 10 rows)


-- ================================================
-- 6.3. Which customers are making frequent returns?
-- Business Purpose: Identify repeat offenders for returns to potentially flag their accounts, adjust shipping policies, or investigate fraudulent behavior.
-- ================================================

select C.CustomerID, C.CustomerName,
	count(O.OrderID) as return_count
from orders as O
Join customers as C on C.CustomerID = O.CustomerID
where O.IsReturned = True
Group by C.CustomerID, C.CustomerName
Order by return_count desc
Limit 10;

-- Result:
-- CustomerID | CustomerName   | ReturnCount
-- 131        | Nancy Shepherd | 5
-- 14         | Kelly Mcneil   | 4
-- 44         | Ann Cochran    | 4
-- ... (Total 10 rows)