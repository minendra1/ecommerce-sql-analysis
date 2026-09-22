-- ============================================
-- data.sql
-- Purpose: Populate the database with realistic sample data
-- Run this AFTER tables.sql
--
-- Dataset size:
--   8 categories
--   25 products
--   100 customers
--   ~500 orders
--   ~1000 order items
--
-- Categories, products, and customers are inserted explicitly.
-- Orders and order items are generated using a stored procedure
-- for efficiency. The procedure uses mathematical formulas (not
-- random numbers), so the data is DETERMINISTIC — running this
-- always produces the exact same dataset.
-- ============================================

USE ecommerce_analysis;

-- ===========================
-- CATEGORIES (8 rows)
-- ===========================
INSERT INTO categories (category_name) VALUES
('Electronics'),
('Clothing'),
('Books'),
('Home & Kitchen'),
('Sports & Fitness'),
('Beauty & Health'),
('Toys & Games'),
('Food & Beverages');

-- ===========================
-- PRODUCTS (25 rows)
-- Each product has a selling price and a cost price
-- Profit = price - cost
-- ===========================
INSERT INTO products (product_name, category_id, price, cost) VALUES
-- Electronics (category_id = 1)
('Wireless Headphones', 1, 2499.00, 1500.00),
('Smartphone Case', 1, 499.00, 200.00),
('USB-C Charger', 1, 799.00, 400.00),
('Bluetooth Speaker', 1, 3499.00, 2100.00),
-- Clothing (category_id = 2)
('Cotton T-Shirt', 2, 599.00, 250.00),
('Denim Jeans', 2, 1499.00, 700.00),
('Running Shoes', 2, 2999.00, 1800.00),
('Winter Jacket', 2, 3999.00, 2200.00),
-- Books (category_id = 3)
('Python Programming', 3, 499.00, 200.00),
('Data Science Handbook', 3, 699.00, 300.00),
('Business Strategy', 3, 399.00, 150.00),
-- Home & Kitchen (category_id = 4)
('Stainless Steel Bottle', 4, 699.00, 350.00),
('Non-stick Pan', 4, 1199.00, 600.00),
('Coffee Maker', 4, 4999.00, 3000.00),
-- Sports & Fitness (category_id = 5)
('Yoga Mat', 5, 899.00, 400.00),
('Resistance Bands', 5, 599.00, 250.00),
('Fitness Tracker', 5, 2499.00, 1400.00),
-- Beauty & Health (category_id = 6)
('Face Wash', 6, 349.00, 150.00),
('Sunscreen Lotion', 6, 499.00, 200.00),
('Hair Dryer', 6, 1599.00, 800.00),
-- Toys & Games (category_id = 7)
('Board Game', 7, 899.00, 400.00),
('Building Blocks', 7, 1299.00, 600.00),
('Puzzle Set', 7, 499.00, 200.00),
-- Food & Beverages (category_id = 8)
('Green Tea Pack', 8, 399.00, 180.00),
('Protein Bars Box', 8, 799.00, 400.00);

-- ===========================
-- CUSTOMERS (100 rows)
-- Spread across 12 Indian states/cities
-- Registration dates: Jan 2022 – Dec 2023
-- Customers 96-100 will have NO orders (for analysis)
-- ===========================
INSERT INTO customers (first_name, last_name, email, city, state, registration_date) VALUES
('Rahul', 'Sharma', 'rahul.sharma@email.com', 'Mumbai', 'Maharashtra', '2022-01-15'),
('Priya', 'Patel', 'priya.patel@email.com', 'Ahmedabad', 'Gujarat', '2022-01-20'),
('Amit', 'Singh', 'amit.singh@email.com', 'Delhi', 'Delhi', '2022-02-10'),
('Sneha', 'Gupta', 'sneha.gupta@email.com', 'Bangalore', 'Karnataka', '2022-02-14'),
('Vikram', 'Reddy', 'vikram.reddy@email.com', 'Hyderabad', 'Telangana', '2022-02-28'),
('Neha', 'Joshi', 'neha.joshi@email.com', 'Pune', 'Maharashtra', '2022-03-05'),
('Arjun', 'Kumar', 'arjun.kumar@email.com', 'Chennai', 'Tamil Nadu', '2022-03-12'),
('Pooja', 'Mehta', 'pooja.mehta@email.com', 'Mumbai', 'Maharashtra', '2022-03-18'),
('Rohan', 'Verma', 'rohan.verma@email.com', 'Jaipur', 'Rajasthan', '2022-03-25'),
('Divya', 'Nair', 'divya.nair@email.com', 'Kochi', 'Kerala', '2022-04-01'),
('Sanjay', 'Mishra', 'sanjay.mishra@email.com', 'Lucknow', 'Uttar Pradesh', '2022-04-10'),
('Anita', 'Rao', 'anita.rao@email.com', 'Bangalore', 'Karnataka', '2022-04-15'),
('Deepak', 'Chopra', 'deepak.chopra@email.com', 'Delhi', 'Delhi', '2022-04-20'),
('Kavita', 'Shah', 'kavita.shah@email.com', 'Surat', 'Gujarat', '2022-05-01'),
('Rajesh', 'Iyer', 'rajesh.iyer@email.com', 'Chennai', 'Tamil Nadu', '2022-05-08'),
('Ritu', 'Malhotra', 'ritu.malhotra@email.com', 'Chandigarh', 'Punjab', '2022-05-15'),
('Kiran', 'Desai', 'kiran.desai@email.com', 'Pune', 'Maharashtra', '2022-05-22'),
('Meera', 'Banerjee', 'meera.banerjee@email.com', 'Kolkata', 'West Bengal', '2022-06-01'),
('Manoj', 'Thakur', 'manoj.thakur@email.com', 'Bhopal', 'Madhya Pradesh', '2022-06-10'),
('Shruti', 'Kapoor', 'shruti.kapoor@email.com', 'Delhi', 'Delhi', '2022-06-15'),
('Nitin', 'Agarwal', 'nitin.agarwal@email.com', 'Noida', 'Uttar Pradesh', '2022-06-20'),
('Swati', 'Das', 'swati.das@email.com', 'Kolkata', 'West Bengal', '2022-06-25'),
('Sachin', 'Pandey', 'sachin.pandey@email.com', 'Lucknow', 'Uttar Pradesh', '2022-07-01'),
('Sunita', 'Chauhan', 'sunita.chauhan@email.com', 'Jaipur', 'Rajasthan', '2022-07-08'),
('Vikas', 'Saxena', 'vikas.saxena@email.com', 'Indore', 'Madhya Pradesh', '2022-07-15'),
('Rekha', 'Yadav', 'rekha.yadav@email.com', 'Patna', 'Bihar', '2022-07-22'),
('Ajay', 'Jain', 'ajay.jain@email.com', 'Mumbai', 'Maharashtra', '2022-07-28'),
('Komal', 'Tiwari', 'komal.tiwari@email.com', 'Bhopal', 'Madhya Pradesh', '2022-08-05'),
('Ravi', 'Kulkarni', 'ravi.kulkarni@email.com', 'Bangalore', 'Karnataka', '2022-08-10'),
('Anju', 'Pillai', 'anju.pillai@email.com', 'Hyderabad', 'Telangana', '2022-08-15'),
('Sunil', 'Patil', 'sunil.patil@email.com', 'Ahmedabad', 'Gujarat', '2022-08-20'),
('Nisha', 'Bhatia', 'nisha.bhatia@email.com', 'Delhi', 'Delhi', '2022-08-25'),
('Akash', 'Dubey', 'akash.dubey@email.com', 'Noida', 'Uttar Pradesh', '2022-09-01'),
('Pallavi', 'Gokhale', 'pallavi.gokhale@email.com', 'Pune', 'Maharashtra', '2022-09-05'),
('Pradeep', 'Menon', 'pradeep.menon@email.com', 'Mumbai', 'Maharashtra', '2022-09-10'),
('Suman', 'Nambiar', 'suman.nambiar@email.com', 'Kochi', 'Kerala', '2022-09-15'),
('Varun', 'Chadha', 'varun.chadha@email.com', 'Surat', 'Gujarat', '2022-09-20'),
('Bhavna', 'Trivedi', 'bhavna.trivedi@email.com', 'Lucknow', 'Uttar Pradesh', '2022-09-25'),
('Gaurav', 'Hegde', 'gaurav.hegde@email.com', 'Hyderabad', 'Telangana', '2022-10-01'),
('Ankita', 'Shetty', 'ankita.shetty@email.com', 'Pune', 'Maharashtra', '2022-10-05'),
('Harsh', 'Tandon', 'harsh.tandon@email.com', 'Delhi', 'Delhi', '2022-10-10'),
('Aisha', 'Qureshi', 'aisha.qureshi@email.com', 'Mumbai', 'Maharashtra', '2022-10-15'),
('Kunal', 'Bhatt', 'kunal.bhatt@email.com', 'Bangalore', 'Karnataka', '2022-10-20'),
('Tanya', 'Kaur', 'tanya.kaur@email.com', 'Chandigarh', 'Punjab', '2022-10-25'),
('Siddharth', 'Mukherjee', 'siddharth.mukherjee@email.com', 'Chennai', 'Tamil Nadu', '2022-11-01'),
('Rashi', 'Arora', 'rashi.arora@email.com', 'Noida', 'Uttar Pradesh', '2022-11-05'),
('Ankit', 'Bose', 'ankit.bose@email.com', 'Kolkata', 'West Bengal', '2022-11-10'),
('Ishita', 'Rathore', 'ishita.rathore@email.com', 'Jaipur', 'Rajasthan', '2022-11-15'),
('Naveen', 'Deshpande', 'naveen.deshpande@email.com', 'Delhi', 'Delhi', '2022-11-20'),
('Jyoti', 'Mohan', 'jyoti.mohan@email.com', 'Indore', 'Madhya Pradesh', '2022-11-25'),
('Abhishek', 'Sen', 'abhishek.sen@email.com', 'Kolkata', 'West Bengal', '2022-12-01'),
('Manisha', 'Tiwari', 'manisha.tiwari@email.com', 'Lucknow', 'Uttar Pradesh', '2022-12-05'),
('Tushar', 'Rajan', 'tushar.rajan@email.com', 'Jaipur', 'Rajasthan', '2022-12-10'),
('Shweta', 'Prasad', 'shweta.prasad@email.com', 'Patna', 'Bihar', '2022-12-15'),
('Mohit', 'Khandelwal', 'mohit.khandelwal@email.com', 'Mumbai', 'Maharashtra', '2022-12-20'),
('Sapna', 'Venkatesh', 'sapna.venkatesh@email.com', 'Bangalore', 'Karnataka', '2022-12-25'),
('Ashok', 'Modi', 'ashok.modi@email.com', 'Ahmedabad', 'Gujarat', '2023-01-01'),
('Geeta', 'Lal', 'geeta.lal@email.com', 'Delhi', 'Delhi', '2023-01-08'),
('Pankaj', 'Subramaniam', 'pankaj.subramaniam@email.com', 'Chennai', 'Tamil Nadu', '2023-01-15'),
('Archana', 'Pawar', 'archana.pawar@email.com', 'Pune', 'Maharashtra', '2023-01-22'),
('Yash', 'Dhawan', 'yash.dhawan@email.com', 'Mumbai', 'Maharashtra', '2023-02-01'),
('Aman', 'Naidu', 'aman.naidu@email.com', 'Hyderabad', 'Telangana', '2023-02-10'),
('Vivek', 'Warrier', 'vivek.warrier@email.com', 'Kochi', 'Kerala', '2023-02-18'),
('Ramesh', 'Gandhi', 'ramesh.gandhi@email.com', 'Surat', 'Gujarat', '2023-02-25'),
('Dev', 'Saxena', 'dev.saxena@email.com', 'Lucknow', 'Uttar Pradesh', '2023-03-05'),
('Tarun', 'Gowda', 'tarun.gowda@email.com', 'Bangalore', 'Karnataka', '2023-03-12'),
('Pranav', 'Kulkarni', 'pranav.kulkarni@email.com', 'Pune', 'Maharashtra', '2023-03-20'),
('Jay', 'Sinha', 'jay.sinha@email.com', 'Delhi', 'Delhi', '2023-03-28'),
('Suresh', 'Nayak', 'suresh.nayak@email.com', 'Mumbai', 'Maharashtra', '2023-04-05'),
('Anil', 'Khanna', 'anil.khanna@email.com', 'Ahmedabad', 'Gujarat', '2023-04-12'),
('Rohini', 'Dutta', 'rohini.dutta@email.com', 'Chandigarh', 'Punjab', '2023-04-20'),
('Preeti', 'Mani', 'preeti.mani@email.com', 'Chennai', 'Tamil Nadu', '2023-04-28'),
('Megha', 'Rastogi', 'megha.rastogi@email.com', 'Noida', 'Uttar Pradesh', '2023-05-05'),
('Rakesh', 'Roy', 'rakesh.roy@email.com', 'Kolkata', 'West Bengal', '2023-05-12'),
('Usha', 'Pandey', 'usha.pandey@email.com', 'Bhopal', 'Madhya Pradesh', '2023-05-20'),
('Dinesh', 'Kapoor', 'dinesh.kapoor@email.com', 'Delhi', 'Delhi', '2023-05-28'),
('Lata', 'Iyer', 'lata.iyer@email.com', 'Indore', 'Madhya Pradesh', '2023-06-05'),
('Hemant', 'Ghosh', 'hemant.ghosh@email.com', 'Kolkata', 'West Bengal', '2023-06-12'),
('Seema', 'Chauhan', 'seema.chauhan@email.com', 'Lucknow', 'Uttar Pradesh', '2023-06-20'),
('Vijay', 'Thakkar', 'vijay.thakkar@email.com', 'Jaipur', 'Rajasthan', '2023-06-28'),
('Radha', 'Mishra', 'radha.mishra@email.com', 'Patna', 'Bihar', '2023-07-05'),
('Mohan', 'Jain', 'mohan.jain@email.com', 'Mumbai', 'Maharashtra', '2023-07-12'),
('Alok', 'Saini', 'alok.saini@email.com', 'Bangalore', 'Karnataka', '2023-07-20'),
('Sonia', 'Bajaj', 'sonia.bajaj@email.com', 'Ahmedabad', 'Gujarat', '2023-07-28'),
('Girish', 'Rawat', 'girish.rawat@email.com', 'Delhi', 'Delhi', '2023-08-05'),
('Prema', 'Nair', 'prema.nair@email.com', 'Chennai', 'Tamil Nadu', '2023-08-12'),
('Neeraj', 'Patil', 'neeraj.patil@email.com', 'Pune', 'Maharashtra', '2023-08-20'),
('Rita', 'Bhargava', 'rita.bhargava@email.com', 'Mumbai', 'Maharashtra', '2023-08-28'),
('Sandip', 'Reddy', 'sandip.reddy@email.com', 'Hyderabad', 'Telangana', '2023-09-05'),
('Kamla', 'Menon', 'kamla.menon@email.com', 'Kochi', 'Kerala', '2023-09-12'),
('Deepa', 'Shah', 'deepa.shah@email.com', 'Surat', 'Gujarat', '2023-09-20'),
('Vinod', 'Tiwari', 'vinod.tiwari@email.com', 'Lucknow', 'Uttar Pradesh', '2023-09-28'),
('Aarti', 'Gowda', 'aarti.gowda@email.com', 'Bangalore', 'Karnataka', '2023-10-05'),
('Gopal', 'Marathe', 'gopal.marathe@email.com', 'Pune', 'Maharashtra', '2023-10-12'),
('Pushpa', 'Anand', 'pushpa.anand@email.com', 'Delhi', 'Delhi', '2023-10-20'),
-- Customers 96-100: These will have NO orders (for "never ordered" analysis)
('Trilok', 'Desai', 'trilok.desai@email.com', 'Mumbai', 'Maharashtra', '2023-11-01'),
('Uma', 'Rao', 'uma.rao@email.com', 'Ahmedabad', 'Gujarat', '2023-11-10'),
('Naresh', 'Malhotra', 'naresh.malhotra@email.com', 'Chandigarh', 'Punjab', '2023-11-18'),
('Hema', 'Krishnan', 'hema.krishnan@email.com', 'Chennai', 'Tamil Nadu', '2023-11-25'),
('Brijesh', 'Agarwal', 'brijesh.agarwal@email.com', 'Noida', 'Uttar Pradesh', '2023-12-05');

-- ============================================
-- ORDERS AND ORDER ITEMS
-- ============================================
-- We use a stored procedure to efficiently generate ~500 orders
-- and ~1000 order items with realistic patterns:
--
--   Customer frequency: Customers 1-5 get the most orders (top buyers),
--     frequency decreases with higher IDs, 96-100 get zero orders
--   Seasonal pattern: Oct-Dec 2023 has MORE orders (festive season)
--   Status: ~82% Completed, ~10% Cancelled, ~8% Returned
--   Products: 10 popular products appear more often than others
--   Discounts: Most items have 0% discount, some get 5-20%
--
-- NOTE: If DELIMITER causes issues in your MySQL client,
--       try running this file from the MySQL command line:
--       mysql -u root -p ecommerce_analysis < sql/data.sql
-- ============================================

DELIMITER //

CREATE PROCEDURE populate_orders()
BEGIN
    DECLARE v_i INT DEFAULT 1;
    DECLARE v_cid INT;
    DECLARE v_date DATE;
    DECLARE v_status VARCHAR(20);
    DECLARE v_oid INT;
    DECLARE v_pid1 INT;
    DECLARE v_pid2 INT;
    DECLARE v_price1 DECIMAL(10,2);
    DECLARE v_price2 DECIMAL(10,2);

    WHILE v_i <= 500 DO

        -- ===== CUSTOMER ASSIGNMENT =====
        -- Customers 1-5:   ~16 orders each (top buyers)
        -- Customers 6-15:  ~11 orders each (frequent)
        -- Customers 16-35: ~5 orders each  (moderate)
        -- Customers 36-60: ~4 orders each  (occasional)
        -- Customers 61-80: ~3 orders each  (rare)
        -- Customers 81-90: ~3 orders each  (rare)
        -- Customers 91-95: ~1 order each   (one-time buyers)
        -- Customers 96-100: 0 orders        (never purchased)

        SET v_cid = CASE
            WHEN v_i <= 80  THEN 1  + ((v_i - 1) % 5)
            WHEN v_i <= 190 THEN 6  + ((v_i - 81) % 10)
            WHEN v_i <= 300 THEN 16 + ((v_i - 191) % 20)
            WHEN v_i <= 400 THEN 36 + ((v_i - 301) % 25)
            WHEN v_i <= 465 THEN 61 + ((v_i - 401) % 20)
            WHEN v_i <= 495 THEN 81 + ((v_i - 466) % 10)
            ELSE                 91 + ((v_i - 496) % 5)
        END;

        -- ===== DATE ASSIGNMENT =====
        -- Orders 1-200:   Jan - Sep 2023 (normal period)
        -- Orders 201-330: Oct - Dec 2023 (festive season spike!)
        -- Orders 331-500: Jan - Jun 2024 (growth period)

        IF v_i <= 200 THEN
            SET v_date = DATE_ADD('2023-01-01',
                INTERVAL FLOOR((v_i - 1) * 272.0 / 199) DAY);
        ELSEIF v_i <= 330 THEN
            SET v_date = DATE_ADD('2023-10-01',
                INTERVAL FLOOR((v_i - 201) * 91.0 / 129) DAY);
        ELSE
            SET v_date = DATE_ADD('2024-01-01',
                INTERVAL FLOOR((v_i - 331) * 181.0 / 169) DAY);
        END IF;

        -- ===== ORDER STATUS =====
        -- ~82% Completed, ~10% Cancelled, ~8% Returned
        SET v_status = CASE
            WHEN v_i % 10 = 0 THEN 'Cancelled'
            WHEN v_i % 13 = 0 THEN 'Returned'
            ELSE 'Completed'
        END;

        INSERT INTO orders (customer_id, order_date, status)
        VALUES (v_cid, v_date, v_status);
        SET v_oid = LAST_INSERT_ID();

        -- ===== ORDER ITEMS (2 per order = ~1000 total) =====

        -- Item 1: Rotates through 10 popular products
        SET v_pid1 = CASE (v_i - 1) % 10
            WHEN 0 THEN 1   -- Wireless Headphones (Electronics)
            WHEN 1 THEN 5   -- Cotton T-Shirt (Clothing)
            WHEN 2 THEN 18  -- Face Wash (Beauty & Health)
            WHEN 3 THEN 7   -- Running Shoes (Clothing)
            WHEN 4 THEN 3   -- USB-C Charger (Electronics)
            WHEN 5 THEN 12  -- Stainless Steel Bottle (Home)
            WHEN 6 THEN 15  -- Yoga Mat (Sports)
            WHEN 7 THEN 24  -- Green Tea Pack (Food)
            WHEN 8 THEN 6   -- Denim Jeans (Clothing)
            WHEN 9 THEN 2   -- Smartphone Case (Electronics)
        END;

        -- Item 2: Rotates through ALL 25 products
        -- Uses coprime multiplier (7) to cycle evenly through all products
        SET v_pid2 = 1 + ((v_i * 7 + 3) % 25);
        -- Avoid duplicate product in the same order
        IF v_pid2 = v_pid1 THEN
            SET v_pid2 = 1 + (v_pid2 % 25);
        END IF;

        -- Look up prices from the products table
        SELECT price INTO v_price1 FROM products WHERE product_id = v_pid1;
        SELECT price INTO v_price2 FROM products WHERE product_id = v_pid2;

        -- Insert both items with varying quantities and discounts
        INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount) VALUES
        (v_oid, v_pid1,
            1 + ((v_i - 1) % 4),       -- Quantity cycles: 1, 2, 3, 4
            v_price1,
            CASE                         -- Discount for item 1
                WHEN v_i % 5 = 0  THEN 0.10
                WHEN v_i % 7 = 0  THEN 0.15
                WHEN v_i % 11 = 0 THEN 0.05
                ELSE 0.00
            END),
        (v_oid, v_pid2,
            1 + (v_i % 3),              -- Quantity cycles: 2, 3, 1
            v_price2,
            CASE                         -- Discount for item 2
                WHEN v_i % 4 = 0  THEN 0.10
                WHEN v_i % 9 = 0  THEN 0.20
                WHEN v_i % 14 = 0 THEN 0.05
                ELSE 0.00
            END);

        SET v_i = v_i + 1;
    END WHILE;
END //

DELIMITER ;

-- Run the procedure to generate orders and order items
CALL populate_orders();

-- Remove the procedure (it was only needed for data generation)
DROP PROCEDURE IF EXISTS populate_orders;

-- ===========================
-- VERIFY: Check row counts in every table
-- ===========================
SELECT 'categories' AS table_name, COUNT(*) AS row_count FROM categories
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;
