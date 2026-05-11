-- Magnitude
-- Measures by Categories

-- Total Customers by Countries
SELECT 
	country, -- first dimension
	COUNT(customer_key) AS total_customers -- then measure
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- Total Customers by Gender
SELECT 
	gender, -- first dimension
	COUNT(customer_key) AS total_customers -- then measure
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Total Products by Category
SELECT 
	category, -- first dimension
	COUNT(product_key) AS total_products -- then measure
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- Average Costs in each Category
SELECT 
	category, -- first dimension
	AVG(cost) AS avg_cost -- then measure
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC;

-- Total Revenue for each Category
SELECT 
	dp.category AS category,
	SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp 
ON fs.product_key = dp.product_key
GROUP BY category
ORDER BY total_revenue DESC;

-- Total Revenue for each Customer
SELECT 
	dc.first_name + ' ' + dc.last_name AS customer,
	SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc 
ON fs.customer_key= dc.customer_key
GROUP BY dc.first_name + ' ' + dc.last_name
ORDER BY total_revenue DESC;

-- Distribution of sold items across Countries
SELECT 
	dc.country AS country,
	SUM(fs.quantity) AS total_items
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc 
ON fs.customer_key= dc.customer_key
GROUP BY dc.country
ORDER BY total_items DESC;