-- ============================================
-- product_analysis.sql
-- Purpose: Analyze product and category performance
-- Run this AFTER cleaning.sql
--
-- Key distinction:
--   Revenue = what the customer pays = quantity * unit_price * (1 - discount)
--   Profit  = what the company keeps = revenue - (quantity * cost)
--   A product can have high revenue but low profit if the cost is high.
-- ============================================

USE ecommerce_analysis;

-- ===========================
-- Q1: Units sold by product (top 10 best sellers)
-- Business purpose: Which products have the highest demand?
--   High units ≠ high revenue (a cheap product can sell more units).
-- ===========================
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    SUM(oi.quantity) AS total_units_sold
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
WHERE o.status = 'Completed'
GROUP BY p.product_id, p.product_name, c.category_name
ORDER BY total_units_sold DESC
LIMIT 10;

-- ===========================
-- Q2: Revenue by product (top 10)
-- Business purpose: Which products generate the most money?
--   This is different from units sold — an expensive product
--   selling fewer units can still generate more revenue.
-- ===========================
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS total_revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
WHERE o.status = 'Completed'
GROUP BY p.product_id, p.product_name, c.category_name
ORDER BY total_revenue DESC
LIMIT 10;

-- ===========================
-- Q3: Profit by product (top 10 most profitable)
-- Business purpose: Revenue minus cost = profit.
--   A product might generate high revenue but low profit
--   if the cost is also high.
-- Formula: profit = quantity * (unit_price * (1-discount) - cost)
-- ===========================
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.price,
    p.cost,
    ROUND(p.price - p.cost, 2) AS unit_margin,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS total_revenue,
    ROUND(SUM(oi.quantity * (oi.unit_price * (1 - oi.discount) - p.cost)), 2) AS total_profit,
    ROUND(
        SUM(oi.quantity * (oi.unit_price * (1 - oi.discount) - p.cost)) /
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) * 100,
    2) AS profit_margin_percent
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
WHERE o.status = 'Completed'
GROUP BY p.product_id, p.product_name, c.category_name, p.price, p.cost
ORDER BY total_profit DESC
LIMIT 10;

-- ===========================
-- Q4: Lowest-selling products (bottom 5 by units)
-- Business purpose: Identify underperforming products.
--   These may need better marketing, repricing, or discontinuation.
-- ===========================
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS total_revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
WHERE o.status = 'Completed'
GROUP BY p.product_id, p.product_name, c.category_name
ORDER BY total_units_sold ASC
LIMIT 5;

-- ===========================
-- Q5: Products that have NEVER been sold
-- Business purpose: Dead inventory. These products are taking
--   up catalog space and storage but generating no revenue.
-- SQL concept: LEFT JOIN + WHERE NULL finds products with
--   no matching order_items.
-- ===========================
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.price
FROM products p
JOIN categories c ON p.category_id = c.category_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL;

-- ===========================
-- Q6: Revenue by category
-- Business purpose: Which product CATEGORIES drive the business?
--   Helps with inventory planning and strategic focus.
-- ===========================
SELECT
    c.category_id,
    c.category_name,
    COUNT(DISTINCT p.product_id) AS product_count,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS total_revenue
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY c.category_id, c.category_name
ORDER BY total_revenue DESC;

-- ===========================
-- Q7: Profit by category
-- Business purpose: A category might have high revenue
--   but thin margins. This shows where profit really comes from.
-- ===========================
SELECT
    c.category_name,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS total_revenue,
    ROUND(SUM(oi.quantity * (oi.unit_price * (1 - oi.discount) - p.cost)), 2) AS total_profit,
    ROUND(
        SUM(oi.quantity * (oi.unit_price * (1 - oi.discount) - p.cost)) /
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) * 100,
    2) AS profit_margin_percent
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY c.category_name
ORDER BY total_profit DESC;

-- ===========================
-- Q8: Products with high revenue but LOW profit margin
-- Business purpose: These products sell well but aren't very
--   profitable. The company might want to renegotiate supplier
--   costs or adjust pricing.
-- SQL concept: HAVING filters on aggregated values (after GROUP BY).
--   WHERE filters individual rows, HAVING filters grouped results.
-- ===========================
SELECT
    p.product_name,
    c.category_name,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS total_revenue,
    ROUND(SUM(oi.quantity * (oi.unit_price * (1 - oi.discount) - p.cost)), 2) AS total_profit,
    ROUND(
        SUM(oi.quantity * (oi.unit_price * (1 - oi.discount) - p.cost)) /
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) * 100,
    2) AS profit_margin_percent
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY p.product_name, c.category_name
HAVING profit_margin_percent < 50
ORDER BY total_revenue DESC;

-- ===========================
-- Q9: Average selling price vs. list price by category
-- Business purpose: Shows the impact of discounts on actual
--   selling price. A big gap means heavy discounting.
-- ===========================
SELECT
    c.category_name,
    ROUND(AVG(p.price), 2) AS avg_list_price,
    ROUND(AVG(oi.unit_price * (1 - oi.discount)), 2) AS avg_actual_price,
    ROUND(AVG(oi.discount) * 100, 2) AS avg_discount_percent
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY c.category_name
ORDER BY avg_discount_percent DESC;

-- ===========================
-- Q10: Number of products per category
-- Business purpose: Shows catalog distribution.
--   Helps identify if some categories are under-represented.
-- ===========================
SELECT
    c.category_name,
    COUNT(p.product_id) AS product_count
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_name
ORDER BY product_count DESC;
