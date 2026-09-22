-- ============================================
-- tables.sql
-- Purpose: Create all tables for the ecommerce_analysis database
-- Run this AFTER database.sql
-- ============================================

USE ecommerce_analysis;

-- ===========================
-- Drop tables if they exist (in reverse order of dependencies)
-- This allows re-running the script safely
-- ===========================
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS categories;

-- ===========================
-- 1. CATEGORIES TABLE
-- Stores product categories (e.g., Electronics, Clothing)
-- One row = one category
-- ===========================
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,   -- Unique ID for each category
    category_name VARCHAR(50) NOT NULL UNIQUE      -- Category name (must be unique)
);

-- ===========================
-- 2. PRODUCTS TABLE
-- Stores all products the company sells
-- One row = one product
-- Each product belongs to exactly one category
-- ===========================
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,     -- Unique ID for each product
    product_name VARCHAR(100) NOT NULL,             -- Product name
    category_id INT NOT NULL,                       -- Which category this product belongs to
    price DECIMAL(10, 2) NOT NULL,                  -- Selling price (what customer pays)
    cost DECIMAL(10, 2) NOT NULL,                   -- Cost price (what company pays)
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- ===========================
-- 3. CUSTOMERS TABLE
-- Stores registered customers
-- One row = one customer
-- ===========================
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,    -- Unique ID for each customer
    first_name VARCHAR(50) NOT NULL,                -- Customer first name
    last_name VARCHAR(50) NOT NULL,                 -- Customer last name
    email VARCHAR(100) NOT NULL UNIQUE,             -- Email (must be unique)
    city VARCHAR(50) NOT NULL,                      -- City for regional analysis
    state VARCHAR(50) NOT NULL,                     -- State for regional analysis
    registration_date DATE NOT NULL                 -- When the customer signed up
);

-- ===========================
-- 4. ORDERS TABLE
-- Stores each purchase transaction
-- One row = one order placed by one customer
-- A customer can have many orders (one-to-many)
-- ===========================
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,       -- Unique ID for each order
    customer_id INT NOT NULL,                       -- Which customer placed this order
    order_date DATE NOT NULL,                       -- When the order was placed
    status VARCHAR(20) NOT NULL DEFAULT 'Completed', -- Order status: Completed, Cancelled, Returned
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- ===========================
-- 5. ORDER_ITEMS TABLE
-- Stores individual product lines within an order
-- One row = one product in one order (with quantity and discount)
-- One order can have many order_items (one-to-many)
-- One product can appear in many order_items (one-to-many)
-- This is where revenue is calculated from
-- ===========================
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,  -- Unique ID for each line item
    order_id INT NOT NULL,                          -- Which order this item belongs to
    product_id INT NOT NULL,                        -- Which product was purchased
    quantity INT NOT NULL,                           -- Number of units bought
    unit_price DECIMAL(10, 2) NOT NULL,             -- Price per unit at time of purchase
    discount DECIMAL(4, 2) NOT NULL DEFAULT 0.00,   -- Discount as decimal (0.10 = 10%)
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ===========================
-- VERIFY: Check that all tables were created
-- ===========================
SHOW TABLES;
