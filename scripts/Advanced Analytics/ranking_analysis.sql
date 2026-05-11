-- Ranking Analysis

-- Which 5 products generate the highest revenue?
SELECT TOP 5
	dp.product_name,
	SUM(fs.sales_amount) AS Revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp
ON fs.product_key = dp.product_key
GROUP BY dp.product_name
ORDER BY Revenue DESC;

-- Which 5 products didn't perform best in terms of revenue?
-- GROUP BY with TOP
SELECT TOP 5
	dp.product_name,
	SUM(fs.sales_amount) AS Revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp
ON fs.product_key = dp.product_key
GROUP BY dp.product_name
ORDER BY Revenue;
-- Above query using Window function
SELECT *
FROM
(
SELECT 
	dp.product_name,
	SUM(fs.sales_amount) AS Revenue,
	ROW_NUMBER() OVER (ORDER BY SUM(fs.sales_amount) DESC) AS rank_products
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp
ON fs.product_key = dp.product_key
GROUP BY dp.product_name)t
WHERE rank_products < 6;

-- 3 customers with the fewer orders placed
SELECT TOP 3
	dc.customer_key,
	dc.first_name,
	dc.last_name,
	COUNT(DISTINCT fs.order_number) AS total_orders
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
ON fs.customer_key= dc.customer_key
GROUP BY dc.customer_key, dc.first_name, dc.last_name
ORDER BY total_orders;
