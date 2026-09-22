-- sales_analysis.sql
-- Purpose: Overall sales and revenue analysis
-- Run this AFTER cleaning.sql
--
-- SQL concepts used in this file:
--   SELECT, WHERE, ORDER BY, GROUP BY, HAVING
--   COUNT, SUM, AVG, MIN, MAX
--   JOIN, ROUND, DATE_FORMAT
--
-- Revenue formula:
--   line_revenue = quantity * unit_price * (1 - discount)
--
-- IMPORTANT: We only count 'Completed' orders for revenue.
-- Cancelled and Returned orders should NOT count as revenue.

USE ecommerce_analysis;

-- Q1: What is the total revenue?
-- Business purpose: The most fundamental metric. Every stakeholder
--   wants to know "how much money did we make?"
-- Tables: orders (for status filter), order_items (for revenue)
SELECT
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS total_revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed';

-- Q2: How many orders were placed in total?
-- Business purpose: Understand order volume.
-- Note: We show ALL orders (including cancelled/returned)
--   and also completed orders separately.
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    SUM(CASE WHEN status = 'Returned' THEN 1 ELSE 0 END) AS returned_orders
FROM orders;

-- Q3: What is the average order value (AOV)?
-- Business purpose: AOV tells us how much a typical customer
--   spends per order. A higher AOV means more revenue per transaction.
-- Formula: Total Revenue / Number of Completed Orders
SELECT
    ROUND(
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) /
        COUNT(DISTINCT o.order_id),
    2) AS avg_order_value
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed';

-- Q4: How many total units were sold?
-- Business purpose: Units sold shows overall demand volume,
--   separate from revenue (a cheap product can sell many units
--   but generate less revenue than an expensive one).
SELECT
    SUM(oi.quantity) AS total_units_sold
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed';

-- Q5: What is the total estimated profit?
-- Business purpose: Revenue is not profit. A company can have
--   high revenue but low profit if costs are high.
-- Formula: SUM( quantity * (unit_price * (1-discount) - cost) )
SELECT
    ROUND(SUM(oi.quantity * (oi.unit_price * (1 - oi.discount) - p.cost)), 2)
        AS total_estimated_profit
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'Completed';

-- Q6: What is the monthly revenue trend?
-- Business purpose: Trends show if the business is growing,
--   declining, or seasonal. This is one of the most commonly
--   asked questions in Data Analyst interviews.
-- SQL concept: DATE_FORMAT extracts year-month from a date.
--   GROUP BY groups all orders in the same month together.
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS monthly_revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month;

-- Q7: What is the quarterly revenue?
-- Business purpose: Quarterly reports are standard in business.
--   Q4 (Oct-Dec) is often the strongest for e-commerce (festive season).
-- SQL concept: QUARTER() extracts the quarter (1-4) from a date.
SELECT
    YEAR(o.order_date) AS year,
    QUARTER(o.order_date) AS quarter,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS quarterly_revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY YEAR(o.order_date), QUARTER(o.order_date)
ORDER BY year, quarter;

-- Q8: What are the top 10 highest-value orders?
-- Business purpose: Identifying large orders helps find
--   potential VIP customers or bulk purchases.
SELECT
    o.order_id,
    o.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    o.order_date,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS order_value
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.status = 'Completed'
GROUP BY o.order_id, o.customer_id, customer_name, o.order_date
ORDER BY order_value DESC
LIMIT 10;

-- Q9: What is the average discount given?
-- Business purpose: High average discounts may indicate
--   over-reliance on promotions, which hurts margins.
SELECT
    ROUND(AVG(oi.discount) * 100, 2) AS avg_discount_percent,
    ROUND(MIN(oi.discount) * 100, 2) AS min_discount_percent,
    ROUND(MAX(oi.discount) * 100, 2) AS max_discount_percent
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed';

-- Q10: Revenue by order status
-- Business purpose: Understanding how much revenue is lost
--   to cancellations and returns.
SELECT
    o.status,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS total_value
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY o.status
ORDER BY total_value DESC;
