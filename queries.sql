-- Table creation

CREATE TABLE sales_data(
    order_number INT,
    quantity_ordered INT,
    price_each DECIMAL(10, 2),
    orderlinenumber INT,
    sales DECIMAL(10, 2),
    order_date DATETIME,
    status VARCHAR(255),
    qtr_id INT,
    month_id INT,
    year_id INT,
    product_line VARCHAR(255),
    msrp INT,
    product_code VARCHAR(255),
    customer_name VARCHAR(255),
    phone_number VARCHAR(255), 
    addressline_1 VARCHAR(255),
    addressline_2 VARCHAR(255),
    city VARCHAR(255),
    state VARCHAR(255),
    postal_code INT,
    country VARCHAR(255),
    territory VARCHAR(255),
    contact_firstname VARCHAR(255),
    contact_lastname VARCHAR(255),
    deal_size VARCHAR(255)
);

-- Importing local .csv file into database

LOAD DATA LOCAL INFILE '/Users/seif/Data\ Analysis/RFM_Analysis/sales_data.csv'
INTO TABLE sales_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Import Validation

SHOW TABLES;

SELECT * FROM sales_data;

SELECT COUNT(*) FROM sales_data;


-- Checking unique values

SELECT DISTINCT status FROM sales_data; -- nice to plot
SELECT DISTINCT year_id FROM sales_data;
SELECT DISTINCT product_line FROM sales_data; -- nice to plot
SELECT DISTINCT country FROM sales_data; -- nice to plot
SELECT DISTINCT dealsize FROM sales_data; -- nice to plot
SELECT DISTINCT territory FROM sales_data; -- nice to plot


-- Analysis
-- Grouping sales by productline
SELECT product_line, SUM(sales) revenue
FROM sales_data
GROUP BY product_line
ORDER BY 2 desc;

-- Grouping sales by year_id
SELECT year_id, SUM(sales) revenue
FROM sales_data
GROUP BY year_id
ORDER BY 2 desc;

-- year_id 2005 seems to be very low, so the assumption would be is that they didn't operate
-- the entire year, so we will check to see if that is true
SELECT DISTINCT month_id FROM sales_data
WHERE year_id = 2005;


-- Grouping sales by dealsize
SELECT deal_size, SUM(sales) revenue
FROM sales_data
GROUP BY deal_size
ORDER BY 2 desc;


-- What was the best month in sales for a specific year?
-- and how much was the revenue earned that month?
SELECT month_id, SUM(sales) revenue, count(order_number) frequency FROM sales_data
WHERE year_id = 2003
GROUP BY month_id
ORDER BY 2 desc;


-- November seems to be the best month, which product did they sell most in November?
SELECT product_line, COUNT(product_line) product_count, SUM(sales) revenue FROM sales_data
WHERE year_id = 2004 AND month_id = 11
GROUP BY product_line
ORDER BY 3 desc;


-- RFM Analysis
SELECT
    customer_name,
    SUM(sales) monetary_value,
    AVG(sales) avg_monetary_value,
    COUNT(order_number) frequency,
    MAX(order_date) last_order_date,
    (SELECT MAX(order_date) FROM sales_data) max_order_date,
    DATEDIFF((SELECT MAX(order_date) FROM sales_data), MAX(order_date)) recency
FROM sales_data
GROUP BY customer_name;


-- Which products are often sold together?
SELECT product_code, COUNT(product_code) num
FROM sales_data
WHERE status = 'Shipped' OR status = 'Resolved'
GROUP BY product_code
ORDER BY 2 desc
LIMIT 200;