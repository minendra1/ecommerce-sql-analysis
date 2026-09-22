-- customer_analysis.sql
-- Purpose: Analyze customer behavior and spending
-- Run this AFTER cleaning.sql
--
-- Key distinction for interviews:
--   "Number of customers" = total unique customers
--   "Number of orders" = total orders placed
--   These are DIFFERENT. One customer can place many orders.
--   Always be clear about what you're counting.
--
-- Revenue formula:
--   line_revenue = quantity * unit_price * (1 - discount)

USE ecommerce_analysis;

-- Q1: How many total registered customers do we have?
-- Business purpose: Basic metric â€” size of customer base.
SELECT COUNT(*) AS total_customers FROM customers;

-- Q2: How many customers actually placed at least one order?
-- Business purpose: Not all registered users buy something.
--   The gap between registered and active customers shows
--   conversion effectiveness.
-- SQL concept: COUNT(DISTINCT) counts unique values only.
SELECT
    COUNT(DISTINCT o.customer_id) AS customers_who_ordered
FROM orders o;

-- Q3: Which customers NEVER placed an order?
-- Business purpose: These are potential customers who registered
--   but never converted. Marketing could target them.
-- SQL concept: LEFT JOIN + WHERE NULL is the standard pattern
--   to find rows in one table with NO match in another.
--   INNER JOIN would miss these â€” it only returns matches.
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.city,
    c.state,
    c.registration_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Q4: How many orders does each customer have?
-- Business purpose: Understanding purchase frequency helps
--   identify loyal vs one-time customers.
-- SQL concept: GROUP BY customer + COUNT(order_id)
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY total_orders DESC;

-- Q5: Top 10 customers by revenue
-- Business purpose: The Pareto principle â€” a small percentage
--   of customers often generate most of the revenue.
--   Identifying top customers helps prioritize VIP treatment.
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.city,
    c.state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY c.customer_id, customer_name, c.city, c.state
ORDER BY total_revenue DESC
LIMIT 10;

-- Q6: How many repeat customers are there?
-- Business purpose: Repeat customers are more valuable than
--   one-time buyers. They cost less to retain than acquiring new ones.
-- Definition: A "repeat customer" has placed MORE THAN 1 order.
-- SQL concept: Subquery â€” first count orders per customer,
--   then count how many have > 1 order.
SELECT
    COUNT(*) AS repeat_customers
FROM (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(order_id) > 1
) AS repeat_cust;

-- Q7: What percentage of customers are repeat customers?
-- Business purpose: Repeat rate is a key retention metric.
--   A high repeat rate means customers are satisfied.
-- Formula: (repeat customers / total customers who ordered) * 100
SELECT
    COUNT(DISTINCT o.customer_id) AS total_active_customers,
    (SELECT COUNT(*) FROM (
        SELECT customer_id
        FROM orders
        GROUP BY customer_id
        HAVING COUNT(order_id) > 1
    ) AS rc) AS repeat_customers,
    ROUND(
        (SELECT COUNT(*) FROM (
            SELECT customer_id
            FROM orders
            GROUP BY customer_id
            HAVING COUNT(order_id) > 1
        ) AS rc2) * 100.0 / COUNT(DISTINCT o.customer_id),
    2) AS repeat_rate_percent
FROM orders o;

-- Q8: Average revenue per customer
-- Business purpose: Customer lifetime value approximation.
--   Higher average = more valuable customer base.
SELECT
    ROUND(
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) /
        COUNT(DISTINCT o.customer_id),
    2) AS avg_revenue_per_customer
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed';

-- Q9: Revenue by STATE (regional analysis)
-- Business purpose: Identify which regions generate the most
--   revenue. Helps with marketing budget allocation and
--   logistics planning.
SELECT
    c.state,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY c.state
ORDER BY total_revenue DESC;

-- Q10: Revenue by CITY (top 10 cities)
-- Business purpose: More granular than state-level.
--   Shows which specific cities are profit centers.
SELECT
    c.city,
    c.state,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY c.city, c.state
ORDER BY total_revenue DESC
LIMIT 10;

-- Q11: Customer purchase frequency distribution
-- Business purpose: How many customers ordered once, twice,
--   three times, etc.? Shows the shape of customer loyalty.
-- SQL concept: This is a "frequency of frequencies" query.
--   First subquery: count orders per customer
--   Outer query: count customers per order frequency
SELECT
    order_count,
    COUNT(*) AS number_of_customers
FROM (
    SELECT
        customer_id,
        COUNT(order_id) AS order_count
    FROM orders
    GROUP BY customer_id
) AS customer_orders
GROUP BY order_count
ORDER BY order_count;
