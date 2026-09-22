# Interview Preparation — E-Commerce SQL Analysis Project

This guide contains 25 interview questions specifically about this project, with ready-to-use answers.

---

## A. Basic Project Questions

### 1. Tell me about your project.
**Answer:** I built a SQL-based data analysis project that analyzes e-commerce sales data. I designed a relational database with 5 tables — categories, products, customers, orders, and order_items — loaded it with realistic sample data of about 100 customers and 500 orders, performed data quality checks, and wrote over 40 SQL queries to answer business questions about revenue, customer behavior, product performance, and trends. The key deliverables are business insights like which customers are most valuable, which products are most profitable, and how revenue trends over time.

### 2. Why did you choose this project?
**Answer:** E-commerce is one of the most common domains in data analytics. Almost every company has sales data and needs to understand revenue, customers, and products. I wanted a project that demonstrates practical SQL skills — not just basic SELECT statements, but joins, aggregations, window functions, and CTEs — on a realistic business problem. It's small enough that I understand every query, but complex enough to show a range of analytical skills.

### 3. What is the business problem?
**Answer:** The e-commerce company wants to understand its business performance across multiple dimensions: How much revenue are we making? Which products and categories drive sales? Who are our most valuable customers? Are customers coming back? How is revenue trending? The goal is to use SQL to turn raw transaction data into actionable business insights.

### 4. Explain your database schema.
**Answer:** There are 5 tables. `categories` stores product categories like Electronics and Clothing. `products` stores each product with its selling price and cost price — having both lets me calculate profit, not just revenue. `customers` stores customer info including city and state for regional analysis. `orders` stores each transaction with a date and status (Completed, Cancelled, or Returned). `order_items` is the most important table — it stores each product line within an order, with quantity, the unit price at time of purchase, and any discount applied. This is where revenue is actually calculated from.

### 5. Why did you separate `orders` and `order_items` into two tables?
**Answer:** Because one order can contain multiple products. If I put products directly in the orders table, I'd have to repeat the order date, customer ID, and status for every product in that order — that's data redundancy. Instead, `orders` stores order-level information (who, when, status) with one row per order, and `order_items` stores product-level information (what, how many, at what price) with one row per product per order. This is database normalization — it eliminates redundancy and makes the data easier to maintain.

---

## B. SQL Concept Questions

### 6. Why did you use JOIN in your queries? What types of JOIN did you use?
**Answer:** I used JOINs because the data I need is spread across multiple tables. For example, to calculate revenue by customer, I need the customer name from `customers`, the order status from `orders`, and the price/quantity from `order_items`. I used INNER JOIN when I only want matching records (e.g., orders that have items), and LEFT JOIN when I want to include non-matching records (e.g., finding customers who never ordered — those customers have no matching rows in the orders table, so INNER JOIN would exclude them).

### 7. Explain WHERE vs HAVING.
**Answer:** `WHERE` filters individual rows BEFORE grouping. `HAVING` filters grouped results AFTER aggregation. For example, `WHERE status = 'Completed'` removes cancelled orders row by row before any calculation. But if I want to find products with revenue greater than ₹50,000, I need to first GROUP BY product, calculate SUM(revenue), and THEN filter — that's what `HAVING` does. You can't use HAVING without GROUP BY.

### 8. Explain INNER JOIN vs LEFT JOIN.
**Answer:** INNER JOIN returns only rows that have a match in BOTH tables. LEFT JOIN returns ALL rows from the left table, plus matching rows from the right table — if there's no match, the right side shows NULL. I used LEFT JOIN specifically to find customers who never ordered: I LEFT JOINed customers with orders, then filtered WHERE order_id IS NULL. An INNER JOIN would have silently excluded those customers.

### 9. Why did you use a CTE (Common Table Expression)?
**Answer:** CTEs make complex queries readable. For example, to calculate month-over-month revenue change, I first need monthly totals, then I need to compare each month with the previous one using LAG. If I tried to do this in one nested query, it would be hard to read and debug. With a CTE, I calculate monthly totals in the WITH clause (giving it a name like `monthly_revenue`), then use that named result in the main query. It's like creating a temporary, named intermediate step.

### 10. Why use a window function instead of GROUP BY?
**Answer:** GROUP BY collapses rows — if I GROUP BY month, I get one row per month. Window functions perform calculations across related rows WITHOUT collapsing them. For example, RANK() OVER (ORDER BY revenue DESC) adds a rank column to every row while keeping all the original rows visible. I used window functions for rankings, running totals, month-over-month comparisons, and moving averages — all cases where I need a calculated column alongside the original detail.

### 11. Explain RANK vs DENSE_RANK vs ROW_NUMBER.
**Answer:** If three products have revenues of 100, 90, 90, 80:
- `ROW_NUMBER` gives: 1, 2, 3, 4 — every row gets a unique number, ties are broken arbitrarily.
- `RANK` gives: 1, 2, 2, 4 — ties get the same rank, but the next rank SKIPS (no rank 3).
- `DENSE_RANK` gives: 1, 2, 2, 3 — ties get the same rank, and the next rank does NOT skip.

I used RANK for customer revenue ranking (gaps are fine when reporting "top 10"), DENSE_RANK for product rankings within categories (I wanted consecutive ranks), and ROW_NUMBER to find the most recent order per customer (I only needed exactly one row per customer).

### 12. Why did you use LAG? How does it work?
**Answer:** LAG lets me access the value from a PREVIOUS row. I used it to calculate month-over-month revenue change. LAG(revenue, 1) OVER (ORDER BY month) returns the revenue from one month ago. Then I compute the difference: current_revenue - previous_revenue. Without LAG, I'd need a self-join on the monthly data where month = month - 1, which is more complex and harder to read.

### 13. How did you calculate revenue?
**Answer:** Revenue per line item = quantity × unit_price × (1 - discount). Total revenue is the SUM of all line items from COMPLETED orders only. I specifically used `unit_price` from `order_items`, not `price` from `products`, because the order item records the actual price the customer paid at that time. Prices can change; the historical price in order_items is more accurate.

### 14. How did you calculate profit?
**Answer:** Estimated profit per line item = quantity × (unit_price × (1 - discount) - cost). The first part is what the customer paid after discount. I subtract the product's cost to get the margin per unit, then multiply by quantity. I join `order_items` with `products` to get the cost, and I only count completed orders.

---

## C. Data Quality Questions

### 15. How did you check for duplicates?
**Answer:** I checked for duplicate customer emails using GROUP BY email HAVING COUNT > 1. I also checked for duplicate product entries within the same order using GROUP BY order_id, product_id HAVING COUNT > 1. Duplicates are dangerous because they inflate counts and revenue calculations.

### 16. How did you handle NULL values?
**Answer:** I checked for NULLs in critical columns like unit_price, quantity, customer_id, and order_date. NULLs are problematic because aggregate functions like SUM ignore them silently — you'd get incorrect totals without any error. My tables use NOT NULL constraints to prevent this at the database level, but I still verify as a best practice because real-world data often has quality issues.

### 17. What's the difference between detecting and correcting bad data?
**Answer:** Detecting means finding the problem — running a query that returns rows with issues. Correcting means fixing or removing the data. I always detect first because blindly deleting data is risky. Some "bad" data might have a valid business explanation. For example, a discount of 50% looks unusual but might be a legitimate flash sale. I'd investigate the context before deciding to correct it.

---

## D. Analytical Questions

### 18. How did you identify repeat customers?
**Answer:** I grouped orders by customer_id, counted the number of orders per customer, and filtered for customers with COUNT > 1. A repeat customer is simply someone who has placed more than one order. I also calculated the repeat customer rate: repeat customers divided by total customers who ordered, times 100.

### 19. How did you calculate customer-level revenue?
**Answer:** I joined customers → orders → order_items, filtered for completed orders, grouped by customer_id, and used SUM(quantity × unit_price × (1 - discount)). This gives total revenue per customer. The key is using COUNT(DISTINCT order_id) for order counts and SUM for revenue — mixing these up is a common mistake.

### 20. How did you calculate month-over-month revenue growth?
**Answer:** I used a CTE to first calculate monthly revenue totals. Then I applied LAG(revenue, 1) OVER (ORDER BY month) to get the previous month's revenue. The growth percentage is (current - previous) / previous × 100. The first month shows NULL for previous revenue because there's no month before it.

### 21. How did you segment customers?
**Answer:** I used a CASE statement inside a CTE. First, I calculated total spending per customer. Then I categorized them: High Value (≥ ₹50,000), Medium Value (≥ ₹20,000), Low Value (below ₹20,000). I then counted customers and total revenue per segment. This shows whether revenue is concentrated in a few big spenders or spread across many small ones.

---

## E. Business Insight Questions

### 22. What was your most important finding?
**Answer:** The seasonal pattern — October through December 2023 showed a clear spike in both order volume and revenue compared to other months. This aligns with the festive/holiday season and suggests the company should prepare for increased demand during Q4: stock up on inventory, increase customer support capacity, and plan targeted promotions. Also, a small group of top customers generates a disproportionate share of revenue, which means retaining those customers should be a business priority.

### 23. What would you analyze next if you had more time?
**Answer:** I'd want to analyze customer churn — identifying customers who haven't ordered in the last 3-6 months and might be at risk of leaving. I'd also look at product affinity — which products are frequently bought together in the same order. And with more time, I'd create a cohort analysis to track how customer spending evolves over time based on when they first purchased.

### 24. Why should we only count 'Completed' orders for revenue?
**Answer:** Cancelled orders never generated actual revenue — the customer didn't pay. Returned orders mean the money was refunded. Including them would overstate the company's actual earnings. In my analysis, I always filter WHERE status = 'Completed' for revenue calculations, but I do report the counts of cancelled and returned orders separately because the cancellation and return rates are important operational metrics.

### 25. Why did you use `unit_price` from order_items instead of `price` from products?
**Answer:** Because `products.price` is the CURRENT price, and `order_items.unit_price` is what the customer ACTUALLY paid at the time of purchase. Prices change over time — products go on sale, prices get updated. If I used the current product price for historical orders, the revenue calculation would be inaccurate. The `unit_price` in order_items is a snapshot of the price at the moment of the transaction.

---

## Quick Reference Card

| Concept | When To Use | Example in This Project |
|---------|-------------|------------------------|
| INNER JOIN | Need data from both tables, only matching rows | Revenue by customer |
| LEFT JOIN | Need ALL rows from left table, even without matches | Customers who never ordered |
| GROUP BY | Aggregate data by a dimension | Revenue by month, by product |
| HAVING | Filter on aggregated results | Products with revenue > X |
| CTE | Break complex query into named steps | Monthly revenue → then LAG |
| Subquery | Intermediate result used in another query | Count of repeat customers |
| RANK | Assign rank with gaps on ties | Top customers by revenue |
| DENSE_RANK | Assign rank without gaps | Best product per category |
| ROW_NUMBER | Unique sequential number | Most recent order per customer |
| LAG | Look back at previous row | Month-over-month change |
| LEAD | Look ahead at next row | Compare with next month |
| PARTITION BY | Separate groups for window functions | Rank within each category |
| CASE | Conditional logic in SQL | Customer spending segments |
| Window SUM | Running total without collapsing rows | Cumulative revenue |
