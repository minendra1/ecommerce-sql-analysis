-- ============================================
-- advanced_analysis.sql
-- Purpose: Advanced SQL analysis using CTEs, window functions,
--          subqueries, CASE statements, and date functions
-- Run this AFTER the basic analysis files
--
-- Advanced SQL concepts explained:
--
--   CTE (Common Table Expression):
--     A temporary named result set defined with WITH ... AS.
--     Makes complex queries readable by breaking them into steps.
--
--   Window Functions (OVER):
--     Perform calculations across a SET of rows related to the
--     current row, WITHOUT collapsing them like GROUP BY does.
--     You keep all rows but add a calculated column.
--
--   RANK(): Assigns ranks with gaps (1, 2, 2, 4)
--   DENSE_RANK(): Assigns ranks without gaps (1, 2, 2, 3)
--   ROW_NUMBER(): Assigns unique sequential numbers (1, 2, 3, 4)
--
--   LAG(column, n): Looks back n rows to get a previous value
--   LEAD(column, n): Looks ahead n rows to get a future value
--
--   PARTITION BY: Divides rows into groups for window functions
--     (similar to GROUP BY but doesn't collapse rows)
-- ============================================

USE ecommerce_analysis;

-- ===========================
-- Q1: Monthly revenue with month-over-month change (using LAG)
-- Business purpose: How is revenue changing month to month?
--   Positive change = growth, negative = decline.
-- Why LAG: We need to compare the current month's revenue with
--   the PREVIOUS month's revenue. LAG looks back one row.
-- Why CTE: First calculate monthly revenue, then apply LAG.
--   Doing it in one query would be messy.
-- ===========================
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS month,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT
    month,
    revenue,
    LAG(revenue, 1) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(revenue - LAG(revenue, 1) OVER (ORDER BY month), 2) AS revenue_change,
    ROUND(
        (revenue - LAG(revenue, 1) OVER (ORDER BY month)) /
        LAG(revenue, 1) OVER (ORDER BY month) * 100,
    2) AS change_percent
FROM monthly_revenue
ORDER BY month;

-- ===========================
-- Q2: Rank customers by total revenue (using RANK)
-- Business purpose: Identify the most valuable customers.
-- Why RANK instead of ORDER BY alone: RANK assigns an explicit
--   position number that we can filter on (e.g., top 10).
--   If two customers tie, they get the same rank.
-- ===========================
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.state,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS total_revenue
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id, customer_name, c.state
)
SELECT
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    customer_id,
    customer_name,
    state,
    total_orders,
    total_revenue
FROM customer_revenue
LIMIT 15;

-- ===========================
-- Q3: Rank products WITHIN each category (using DENSE_RANK + PARTITION BY)
-- Business purpose: Who's the #1 product in each category?
--   This is more useful than a global ranking because a cheap
--   category will never compete with an expensive one.
-- Why DENSE_RANK: No gaps in ranking (1, 2, 3 not 1, 2, 4).
-- Why PARTITION BY: Creates separate rankings per category.
-- ===========================
WITH product_sales AS (
    SELECT
        c.category_name,
        p.product_name,
        SUM(oi.quantity) AS units_sold,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue
    FROM products p
    JOIN categories c ON p.category_id = c.category_id
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY c.category_name, p.product_name
)
SELECT
    category_name,
    product_name,
    units_sold,
    revenue,
    DENSE_RANK() OVER (PARTITION BY category_name ORDER BY revenue DESC) AS rank_in_category
FROM product_sales
ORDER BY category_name, rank_in_category;

-- ===========================
-- Q4: Identify repeat customers (using subquery)
-- Business purpose: Repeat customers are the backbone of
--   a sustainable business. They cost less to retain than
--   acquiring new customers.
-- Definition: A repeat customer has placed MORE THAN 1 order.
-- ===========================
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.city,
    c.state,
    order_data.total_orders,
    order_data.first_order,
    order_data.last_order,
    DATEDIFF(order_data.last_order, order_data.first_order) AS days_as_customer
FROM customers c
JOIN (
    SELECT
        customer_id,
        COUNT(*) AS total_orders,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(*) > 1
) AS order_data ON c.customer_id = order_data.customer_id
ORDER BY order_data.total_orders DESC;

-- ===========================
-- Q5: Customer segmentation by spending (using CASE + CTE)
-- Business purpose: Segment customers into tiers for targeted
--   marketing. High-value customers get premium treatment,
--   low-value ones get re-engagement campaigns.
-- Why CASE: Creates conditional categories based on spending.
-- ===========================
WITH customer_spending AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS total_spending
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id, customer_name
)
SELECT
    CASE
        WHEN total_spending >= 50000 THEN 'High Value'
        WHEN total_spending >= 20000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_spending), 2) AS avg_spending,
    ROUND(SUM(total_spending), 2) AS total_segment_revenue
FROM customer_spending
GROUP BY customer_segment
ORDER BY total_segment_revenue DESC;

-- ===========================
-- Q6: Most recent order per customer (using ROW_NUMBER)
-- Business purpose: When did each customer last purchase?
--   Customers who haven't purchased recently may be at risk of churning.
-- Why ROW_NUMBER: Assigns 1 to the most recent order per customer.
--   We then filter to keep only row_number = 1.
-- Why not just MAX(order_date): Because we also want the order_id
--   and status of that specific latest order, not just the date.
-- ===========================
WITH ranked_orders AS (
    SELECT
        o.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        o.order_id,
        o.order_date,
        o.status,
        ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date DESC) AS rn
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
)
SELECT
    customer_id,
    customer_name,
    order_id AS last_order_id,
    order_date AS last_order_date,
    status AS last_order_status
FROM ranked_orders
WHERE rn = 1
ORDER BY last_order_date DESC
LIMIT 20;

-- ===========================
-- Q7: Running total of monthly revenue (using window SUM)
-- Business purpose: Shows cumulative revenue growth over time.
--   Useful for tracking progress toward annual targets.
-- Why window SUM: Regular SUM with GROUP BY gives monthly totals.
--   Window SUM with ROWS BETWEEN gives a running (cumulative) total.
-- ===========================
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS month,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT
    month,
    revenue,
    ROUND(SUM(revenue) OVER (ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2)
        AS cumulative_revenue
FROM monthly_revenue
ORDER BY month;

-- ===========================
-- Q8: Compare current month with NEXT month (using LEAD)
-- Business purpose: Forecast planning — if next month's revenue
--   is expected to drop, the company can prepare.
-- Why LEAD: Opposite of LAG. LEAD looks FORWARD one row.
-- ===========================
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS month,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT
    month,
    revenue AS current_month_revenue,
    LEAD(revenue, 1) OVER (ORDER BY month) AS next_month_revenue,
    ROUND(
        (LEAD(revenue, 1) OVER (ORDER BY month) - revenue) / revenue * 100,
    2) AS expected_change_percent
FROM monthly_revenue
ORDER BY month;

-- ===========================
-- Q9: 3-month moving average revenue (using window AVG)
-- Business purpose: Smooths out monthly fluctuations to reveal
--   the underlying trend. Widely used in business reporting.
-- Why window AVG with ROWS BETWEEN: Averages the current month
--   plus the two preceding months.
-- ===========================
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS month,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT
    month,
    revenue,
    ROUND(
        AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
    2) AS moving_avg_3_month
FROM monthly_revenue
ORDER BY month;

-- ===========================
-- Q10: Category contribution to total revenue (percentage)
-- Business purpose: Shows each category's share of overall revenue.
--   Helps identify which categories the business depends on most.
-- Why window SUM: We need the total revenue (across ALL categories)
--   alongside each category's revenue. A regular SUM with GROUP BY
--   can't give us both in one query without a subquery.
-- ===========================
WITH category_revenue AS (
    SELECT
        cat.category_name,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue
    FROM categories cat
    JOIN products p ON cat.category_id = p.category_id
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY cat.category_name
)
SELECT
    category_name,
    revenue,
    SUM(revenue) OVER () AS total_revenue,
    ROUND(revenue / SUM(revenue) OVER () * 100, 2) AS revenue_share_percent
FROM category_revenue
ORDER BY revenue DESC;

-- ===========================
-- Q11: KPI Dashboard — All key metrics in one query
-- Business purpose: A single query that returns all important
--   KPIs. This is what a CEO or manager would see at a glance.
-- ===========================
SELECT
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_completed_orders,
    COUNT(DISTINCT o.customer_id) AS total_active_customers,
    ROUND(
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) /
        COUNT(DISTINCT o.order_id),
    2) AS avg_order_value,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(SUM(oi.quantity * (oi.unit_price * (1 - oi.discount) - p.cost)), 2) AS total_profit,
    ROUND(
        SUM(oi.quantity * (oi.unit_price * (1 - oi.discount) - p.cost)) /
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) * 100,
    2) AS profit_margin_percent,
    ROUND(AVG(oi.discount) * 100, 2) AS avg_discount_percent
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'Completed';
