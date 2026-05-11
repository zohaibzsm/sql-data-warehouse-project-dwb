-- KPIs

-- Find Total Sales
SELECT SUM(sales_amount) AS total_sales,
	   CASE WHEN SUM(sales_amount) > 1000000 
			THEN SUM(sales_amount) / 1000000 
		END AS total_sales_in_millions
FROM gold.fact_sales;

-- How many items are sold
SELECT SUM(quantity) total_items
FROM gold.fact_sales;

-- Average Selling Price
SELECT AVG(price) AS avg_selling_price
FROM gold.fact_sales;

-- Total Number of Orders
SELECT COUNT(order_number) AS total_orders
FROM gold.fact_sales;
SELECT COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;
--SELECT COUNT(*) AS total_orders
--FROM gold.fact_sales;

-- Total Number of Products
SELECT COUNT(DISTINCT product_key) AS total_products
FROM gold.dim_products;
SELECT COUNT(DISTINCT product_name) AS total_products
FROM gold.dim_products;

-- Total Number of Customers
SELECT COUNT(DISTINCT customer_key) AS total_customers
FROM gold.dim_customers;

-- Total Number of Customers that has placed an order
SELECT COUNT(DISTINCT customer_key) total_customers
FROM gold.fact_sales;


-- Generating a report containing all key metrics of the business
SELECT 
	'Total Sales' AS measure_name, 
	SUM(sales_amount) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT 
		'Total Quantity' AS measure_name, 
		SUM(quantity) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT 
		'Average Selling Price' AS measure_name, 
		AVG(price) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT 
		'Total Nr. Orders' AS measure_name, 
		COUNT(DISTINCT order_number) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT 
		'Total Nr. Products' AS measure_name, 
		COUNT(DISTINCT product_key) AS measure_value
FROM gold.dim_products
UNION ALL
SELECT 
		'Total Nr. Customers' AS measure_name, 
		COUNT(DISTINCT customer_key) AS measure_value
FROM gold.dim_customers;