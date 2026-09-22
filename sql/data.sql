-- data.sql
-- Purpose: Load data from CSV files into all tables
-- Run this AFTER tables.sql
--
-- PREREQUISITES:
--   1. CSV files must exist in the data/ folder
--   2. MySQL must be started with local_infile enabled:
--        mysql --local-infile=1 -u root -p
--   3. Or set it inside MySQL:
--        SET GLOBAL local_infile = 1;
--        Then reconnect with: mysql --local-infile=1 -u root -p
--
-- Dataset size:
--   30 categories, 25 products, 500 customers,
--   500 orders, 1000 order items
--
-- All CSV files are in the data/ folder of this project.

USE ecommerce_analysis;

-- IMPORTANT: Enable local file loading
SET GLOBAL local_infile = 1;

-- Load data in order of dependencies:
--   1. categories (no dependencies)
--   2. products (depends on categories)
--   3. customers (no dependencies)
--   4. orders (depends on customers)
--   5. order_items (depends on orders + products)

-- NOTE: Replace the file path below with YOUR full path to the data/ folder.
-- Example: 'C:/Users/gangw/Desktop/ecommerce-sql-analysis/data/categories.csv'
-- On Windows, use forward slashes (/) in the path, not backslashes (\).

-- 1. CATEGORIES
LOAD DATA LOCAL INFILE 'C:/Users/gangw/Desktop/ecommerce-sql-analysis/data/categories.csv'
INTO TABLE categories
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(category_id, category_name);

-- 2. PRODUCTS
LOAD DATA LOCAL INFILE 'C:/Users/gangw/Desktop/ecommerce-sql-analysis/data/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(product_id, product_name, category_id, price, cost);

-- 3. CUSTOMERS
LOAD DATA LOCAL INFILE 'C:/Users/gangw/Desktop/ecommerce-sql-analysis/data/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(customer_id, first_name, last_name, email, city, state, registration_date);

-- 4. ORDERS
LOAD DATA LOCAL INFILE 'C:/Users/gangw/Desktop/ecommerce-sql-analysis/data/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(order_id, customer_id, order_date, status);

-- 5. ORDER ITEMS
LOAD DATA LOCAL INFILE 'C:/Users/gangw/Desktop/ecommerce-sql-analysis/data/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(order_item_id, order_id, product_id, quantity, unit_price, discount);

-- VERIFY: Check row counts in every table
SELECT 'categories' AS table_name, COUNT(*) AS row_count FROM categories
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;
