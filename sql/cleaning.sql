-- ============================================
-- cleaning.sql
-- Purpose: Data quality checks before analysis
-- Run this AFTER data.sql
--
-- IMPORTANT: A Data Analyst should ALWAYS check data quality
-- before performing analysis. Bad data leads to wrong insights.
--
-- This file DETECTS problems but does NOT delete data.
-- The difference:
--   "Detecting" = finding and reporting issues
--   "Correcting" = fixing or removing bad data
-- Always detect first. Only correct after understanding the issue.
-- ============================================

USE ecommerce_analysis;

-- ===========================
-- CHECK 1: NULL values in critical columns
-- WHY: NULL values can cause incorrect calculations.
--       SUM() ignores NULLs, COUNT() skips them.
--       A NULL in unit_price would mean lost revenue data.
-- WHAT TO DO: If found, investigate the source of the NULL.
-- ===========================

-- Check for NULL values in customers
SELECT 'customers' AS table_name, 'first_name' AS column_name, COUNT(*) AS null_count
FROM customers WHERE first_name IS NULL
UNION ALL
SELECT 'customers', 'email', COUNT(*) FROM customers WHERE email IS NULL
UNION ALL
SELECT 'customers', 'city', COUNT(*) FROM customers WHERE city IS NULL
UNION ALL
SELECT 'customers', 'state', COUNT(*) FROM customers WHERE state IS NULL;

-- Check for NULL values in orders
SELECT 'orders' AS table_name, 'customer_id' AS column_name, COUNT(*) AS null_count
FROM orders WHERE customer_id IS NULL
UNION ALL
SELECT 'orders', 'order_date', COUNT(*) FROM orders WHERE order_date IS NULL
UNION ALL
SELECT 'orders', 'status', COUNT(*) FROM orders WHERE status IS NULL;

-- Check for NULL values in order_items
SELECT 'order_items' AS table_name, 'quantity' AS column_name, COUNT(*) AS null_count
FROM order_items WHERE quantity IS NULL
UNION ALL
SELECT 'order_items', 'unit_price', COUNT(*) FROM order_items WHERE unit_price IS NULL
UNION ALL
SELECT 'order_items', 'discount', COUNT(*) FROM order_items WHERE discount IS NULL;

-- ===========================
-- CHECK 2: Duplicate records
-- WHY: Duplicates inflate counts and revenue.
--       Two identical order_items would double-count revenue.
-- WHAT TO DO: If found, determine if the duplicate is a real
--       repeat purchase or a data entry error.
-- ===========================

-- Check for duplicate customer emails
SELECT email, COUNT(*) AS occurrences
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

-- Check for duplicate order items (same product in same order)
SELECT order_id, product_id, COUNT(*) AS occurrences
FROM order_items
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

-- ===========================
-- CHECK 3: Invalid quantities (should be >= 1)
-- WHY: A quantity of 0 or negative makes no business sense.
--       It would make revenue calculations wrong.
-- WHAT TO DO: If found, check if the order was a return
--       or a data entry mistake.
-- ===========================
SELECT order_item_id, order_id, product_id, quantity
FROM order_items
WHERE quantity <= 0;

-- ===========================
-- CHECK 4: Invalid prices (should be > 0)
-- WHY: A product with zero or negative price would mean
--       giving it away for free. This is almost always an error.
-- WHAT TO DO: If found, cross-check with the products table
--       and correct the unit_price.
-- ===========================
SELECT order_item_id, order_id, product_id, unit_price
FROM order_items
WHERE unit_price <= 0;

-- Also check the products table
SELECT product_id, product_name, price, cost
FROM products
WHERE price <= 0 OR cost <= 0;

-- ===========================
-- CHECK 5: Invalid discounts (should be between 0 and 1)
-- WHY: A discount of 1.0 = 100% (free item). Above 1.0 means
--       the company is PAYING the customer. Both are suspicious.
-- WHAT TO DO: If discount > 0.5 (50%), investigate.
--       If discount < 0, it's definitely an error.
-- ===========================
SELECT order_item_id, order_id, discount
FROM order_items
WHERE discount < 0 OR discount >= 1;

-- Flag unusually high discounts (above 50%)
SELECT order_item_id, order_id, discount
FROM order_items
WHERE discount > 0.50;

-- ===========================
-- CHECK 6: Invalid dates
-- WHY: Future dates or very old dates are likely errors.
--       Dates before the company existed or after today are wrong.
-- WHAT TO DO: If found, check the data source for timestamp issues.
-- ===========================

-- Orders with future dates
SELECT order_id, order_date
FROM orders
WHERE order_date > CURDATE();

-- Orders before the earliest customer registration
SELECT o.order_id, o.order_date, c.registration_date
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date < c.registration_date;

-- ===========================
-- CHECK 7: Invalid foreign key relationships
-- WHY: An order referencing a non-existent customer means
--       we can't do customer analysis for that order.
-- WHAT TO DO: If found, either find the correct reference
--       or flag the record for manual review.
-- ===========================

-- Orders with customer_ids that don't exist in customers table
SELECT o.order_id, o.customer_id
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Order items with product_ids that don't exist in products table
SELECT oi.order_item_id, oi.product_id
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Order items with order_ids that don't exist in orders table
SELECT oi.order_item_id, oi.order_id
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- ===========================
-- CHECK 8: Unexpected order statuses
-- WHY: We expect only 'Completed', 'Cancelled', 'Returned'.
--       Any other value (typos like 'Completd') would be missed
--       in our analysis.
-- WHAT TO DO: Standardize the values.
-- ===========================
SELECT status, COUNT(*) AS order_count
FROM orders
GROUP BY status
ORDER BY order_count DESC;

-- ===========================
-- CHECK 9: Customers who registered but never ordered
-- WHY: Not an error, but useful to know. These customers
--       might need a marketing campaign.
-- ===========================
SELECT c.customer_id, c.first_name, c.last_name, c.email
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- ===========================
-- CHECK 10: Cost exceeds price (negative margin products)
-- WHY: If cost > price, the company loses money on every sale.
--       Could be intentional (loss leader) or a data error.
-- WHAT TO DO: Verify with the business team.
-- ===========================
SELECT product_id, product_name, price, cost,
    ROUND(price - cost, 2) AS margin,
    ROUND((price - cost) / price * 100, 2) AS margin_percent
FROM products
WHERE cost >= price;

-- ===========================
-- SUMMARY: Overall data quality report
-- ===========================
SELECT
    (SELECT COUNT(*) FROM categories) AS total_categories,
    (SELECT COUNT(*) FROM products) AS total_products,
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(*) FROM orders) AS total_orders,
    (SELECT COUNT(*) FROM order_items) AS total_order_items;
