-- =====================================================================
-- TechNova Retail | Sales Analytics Dashboard
-- Business-question queries
-- Author: Sarthak Srivastava
-- Run against sales.db (see schema.sql for table structure)
-- =====================================================================

-- 1. Headline KPIs: total revenue, orders, average order value,
--    unique customers, return rate (excludes cancelled orders)
SELECT
    ROUND(SUM(Revenue), 2)                                              AS total_revenue,
    COUNT(DISTINCT OrderID)                                             AS total_orders,
    ROUND(SUM(Revenue) * 1.0 / COUNT(DISTINCT OrderID), 2)              AS avg_order_value,
    COUNT(DISTINCT CustomerID)                                          AS unique_customers,
    ROUND(100.0 * SUM(CASE WHEN OrderStatus = 'Returned' THEN 1 ELSE 0 END)
          / COUNT(*), 2)                                                AS return_rate_pct
FROM sales
WHERE OrderStatus != 'Cancelled';

-- 2. Revenue and order count by region, ranked highest to lowest
SELECT
    Region,
    ROUND(SUM(Revenue), 2)   AS revenue,
    COUNT(DISTINCT OrderID)  AS orders
FROM sales
WHERE OrderStatus != 'Cancelled'
GROUP BY Region
ORDER BY revenue DESC;

-- 3. Revenue by product category, with each category's share of total revenue
SELECT
    ProductCategory,
    ROUND(SUM(Revenue), 2) AS revenue,
    ROUND(100.0 * SUM(Revenue) /
        (SELECT SUM(Revenue) FROM sales WHERE OrderStatus != 'Cancelled'), 1) AS pct_of_total
FROM sales
WHERE OrderStatus != 'Cancelled'
GROUP BY ProductCategory
ORDER BY revenue DESC;

-- 4. Monthly revenue trend (for the trend line chart)
SELECT
    OrderMonth,
    ROUND(SUM(Revenue), 2) AS revenue
FROM sales
WHERE OrderStatus != 'Cancelled'
GROUP BY OrderMonth
ORDER BY OrderMonth;

-- 5. Top 10 products by revenue
SELECT
    ProductName,
    ROUND(SUM(Revenue), 2) AS revenue,
    SUM(Quantity)          AS units_sold
FROM sales
WHERE OrderStatus != 'Cancelled'
GROUP BY ProductName
ORDER BY revenue DESC
LIMIT 10;

-- 6. Top 5 sales reps by revenue generated
SELECT
    SalesRep,
    ROUND(SUM(Revenue), 2)  AS revenue,
    COUNT(DISTINCT OrderID) AS orders
FROM sales
WHERE OrderStatus != 'Cancelled'
GROUP BY SalesRep
ORDER BY revenue DESC
LIMIT 5;

-- 7. Year-over-year revenue and growth rate
SELECT
    OrderYear,
    ROUND(SUM(Revenue), 2) AS revenue
FROM sales
WHERE OrderStatus != 'Cancelled'
GROUP BY OrderYear
ORDER BY OrderYear;
-- (YoY % growth computed in the notebook with pandas .pct_change(),
--  since plain SQLite has no native LAG() window function pre-3.25
--  guarantee across environments)

-- 8. Revenue by payment method (customer behavior view)
SELECT
    PaymentMethod,
    ROUND(SUM(Revenue), 2)  AS revenue,
    COUNT(DISTINCT OrderID) AS orders
FROM sales
WHERE OrderStatus != 'Cancelled'
GROUP BY PaymentMethod
ORDER BY revenue DESC;

-- 9. Order status breakdown (fulfillment health check)
SELECT
    OrderStatus,
    COUNT(*)                                        AS order_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM sales), 1) AS pct_of_orders
FROM sales
GROUP BY OrderStatus
ORDER BY order_count DESC;

-- 10. Top 10 customers by lifetime revenue (for a CRM/loyalty follow-up)
SELECT
    CustomerID,
    CustomerName,
    ROUND(SUM(Revenue), 2)  AS lifetime_revenue,
    COUNT(DISTINCT OrderID) AS total_orders
FROM sales
WHERE OrderStatus != 'Cancelled'
GROUP BY CustomerID, CustomerName
ORDER BY lifetime_revenue DESC
LIMIT 10;
