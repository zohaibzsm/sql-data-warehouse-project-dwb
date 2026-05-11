-- segment products into cost ranges and count how many products fall into
-- each segment
WITH product_segmentation AS
(
SELECT 
	product_key,
	product_name,
	cost,
	CASE WHEN cost < 100 THEN 'Below 100'
		 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
		 WHEN cost BETWEEN 501 AND 1000 THEN '500-1000'
		 ELSE 'Above 1000'
	END cost_range
FROM gold.dim_products
)
SELECT
	cost_range,
	COUNT(product_name) AS products_in_each_cat
FROM product_segmentation
GROUP BY cost_range
ORDER BY products_in_each_cat DESC;

/* Group customers into 3 segments based on theri spending behavior:
-- VIP: at least 12 months of history and spending more than 5k euro.
-- Regular: at least 12 months of history but spending 5k euro or less.
-- New: lifespan less than 12 months.
And find the total number of customers by each group. */
WITH customer_spending AS
(
SELECT
	c.customer_key,
	SUM(f.sales_amount) AS total_spending,
	MIN(order_date) AS first_order,
	MAX(order_date) AS last_order,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)
SELECT 
	customer_segment,
	COUNT(customer_key) AS total_customers
FROM
(
SELECT 
	customer_key,
	--total_spending,
	--lifespan,
	CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
		 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
		 ELSE 'New'
	END AS customer_segment
FROM customer_spending
)t
GROUP BY customer_segment
ORDER BY total_customers DESC
;