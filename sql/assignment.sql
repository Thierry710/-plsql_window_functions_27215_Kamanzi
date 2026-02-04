-- ========================================
-- INSY 8311: SQL JOINs & Window Functions
-- Student: Kamanzi Thierry
-- DBMS: PostgreSQL
-- ========================================


-- ===============================
-- DROP TABLES (RESET)
-- ===============================

DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;


-- ===============================
-- CREATE TABLES
-- ===============================

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100),
    region VARCHAR(50)
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price NUMERIC(10,2)
);

CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    customer_id INT,
    product_id INT,
    sale_date DATE,
    quantity INT,
    total_amount NUMERIC(10,2),

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


-- ===============================
-- INSERT DATA
-- ===============================

INSERT INTO customers (customer_name, region) VALUES
('John', 'East'),
('Mary', 'West'),
('Paul', 'North'),
('Alice', 'South'),
('David', 'East'),
('Grace', 'West');

INSERT INTO products (product_name, category, price) VALUES
('Laptop', 'Electronics', 800),
('Phone', 'Electronics', 500),
('Tablet', 'Electronics', 300),
('Printer', 'Office', 200),
('Camera', 'Media', 600);

INSERT INTO sales (customer_id, product_id, sale_date, quantity, total_amount) VALUES
(1,1,'2025-01-10',1,800),
(2,2,'2025-01-15',2,1000),
(3,3,'2025-02-05',1,300),
(1,2,'2025-02-20',1,500),
(4,4,'2025-03-01',1,200),
(5,1,'2025-03-10',2,1600),
(2,5,'2025-04-05',1,600),
(3,1,'2025-04-20',1,800),
(6,3,'2025-05-01',2,600);


-- ===============================
-- PART A: SQL JOINS
-- ===============================


-- 1. INNER JOIN
SELECT c.customer_name, p.product_name, s.total_amount
FROM sales s
INNER JOIN customers c
ON s.customer_id = c.customer_id
INNER JOIN products p
ON s.product_id = p.product_id;


-- 2. LEFT JOIN
SELECT c.customer_name
FROM customers c
LEFT JOIN sales s
ON c.customer_id = s.customer_id
WHERE s.sale_id IS NULL;


-- 3. RIGHT JOIN
SELECT p.product_name
FROM sales s
RIGHT JOIN products p
ON s.product_id = p.product_id
WHERE s.sale_id IS NULL;


-- 4. FULL JOIN
SELECT c.customer_name, p.product_name
FROM customers c
FULL JOIN products p
ON c.customer_id = p.product_id;


-- 5. SELF JOIN
SELECT a.customer_name AS customer1,
       b.customer_name AS customer2,
       a.region
FROM customers a
JOIN customers b
ON a.region = b.region
AND a.customer_id <> b.customer_id;



-- ===============================
-- PART B: WINDOW FUNCTIONS
-- ===============================


-- 6. RANK: Top Products Per Region
SELECT region,
       product_name,
       total_sales,
       RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) AS rank_in_region
FROM (
    SELECT c.region,
           p.product_name,
           SUM(s.total_amount) AS total_sales
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    JOIN products p ON s.product_id = p.product_id
    GROUP BY c.region, p.product_name
) t;


-- 7. SUM OVER: Running Total
SELECT sale_date,
       total_amount,
       SUM(total_amount) OVER (
           ORDER BY sale_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_total
FROM sales;


-- 8. LAG: Month-to-Month Growth
SELECT sale_date,
       total_amount,
       total_amount - LAG(total_amount)
       OVER (ORDER BY sale_date) AS growth
FROM sales;


-- 9. NTILE: Customer Segmentation
SELECT customer_id,
       SUM(total_amount) AS total_spent,
       NTILE(4) OVER (ORDER BY SUM(total_amount)) AS quartile
FROM sales
GROUP BY customer_id;


-- ===============================
-- END OF FILE
-- ===============================
