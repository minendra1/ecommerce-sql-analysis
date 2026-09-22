-- cleaning.sql
-- Purpose: Data quality checks before analysis
-- Run this AFTER data.sql
-- Note: This file detects problems but does not delete data.

USE ecommerce_analysis;

-- Check 1: NULL values in critical columns
-- Detects if important data is missing (e.g., NULL prices or customer info)

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


-- Check 2: Duplicate records
-- Detects repeated customer emails or duplicated products in the same order

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


-- Check 3: Invalid quantities
-- Quantities should be 1 or more. Zero or negative quantities are invalid.
SELECT order_item_id, order_id, product_id, quantity
FROM order_items
WHERE quantity <= 0;


-- Check 4: Invalid prices
-- Prices and costs should be greater than 0.
SELECT order_item_id, order_id, product_id, unit_price
FROM order_items
WHERE unit_price <= 0;

-- Also check the products table
SELECT product_id, product_name, price, cost
FROM products
WHERE price <= 0 OR cost <= 0;


-- Check 5: Invalid discounts
-- Discounts should be between 0 (0%) and 1 (100%).
SELECT order_item_id, order_id, discount
FROM order_items
WHERE discount < 0 OR discount >= 1;

-- Flag unusually high discounts (above 50%)
SELECT order_item_id, order_id, discount
FROM order_items
WHERE discount > 0.50;


-- Check 6: Invalid dates
-- Order dates should not be in the future or before customer registration.

-- Orders with future dates
SELECT order_id, order_date
FROM orders
WHERE order_date > CURDATE();

-- Orders before the earliest customer registration
SELECT o.order_id, o.order_date, c.registration_date
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date < c.registration_date;


-- Check 7: Invalid foreign key relationships
-- Identifies orders missing a customer or items missing a product.

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


-- Check 8: Unexpected order statuses
-- Ensures we only have 'Completed', 'Cancelled', or 'Returned'.
SELECT status, COUNT(*) AS order_count
FROM orders
GROUP BY status
ORDER BY order_count DESC;


-- Check 9: Customers without orders
-- Useful to find customers who registered but haven't bought anything.
SELECT c.customer_id, c.first_name, c.last_name, c.email
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- Check 10: Negative margin products
-- Identifies products where the cost is higher than the selling price.
SELECT product_id, product_name, price, cost,
    ROUND(price - cost, 2) AS margin,
    ROUND((price - cost) / price * 100, 2) AS margin_percent
FROM products
WHERE cost >= price;


-- Overall Data Summary
-- Displays the total row count for all tables.
SELECT
    (SELECT COUNT(*) FROM categories) AS total_categories,
    (SELECT COUNT(*) FROM products) AS total_products,
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(*) FROM orders) AS total_orders,
    (SELECT COUNT(*) FROM order_items) AS total_order_items;
