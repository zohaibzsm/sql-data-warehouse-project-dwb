
-- Truncating before Inserting to avoid duplicates
TRUNCATE TABLE silver.crm_sales_details;
-- Preparing and Inserting data into silver.crm_sales_details table
-- Main Query starts here
INSERT INTO silver.crm_sales_details  (
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
)
SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
		 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END AS sls_order_dt,
	CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END AS sls_ship_dt,
	CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
		 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS sls_due_dt,
	CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR 
			  sls_sales != sls_quantity * ABS (sls_price)
		 THEN sls_quantity * ABS (sls_price)
		 ELSE sls_sales
	END sls_sales,
	sls_quantity,
	CASE WHEN sls_price IS NULL OR sls_price <= 0
		THEN sls_sales / NULLIF(sls_quantity, 0) 
			 -- If quantity is zero, make it NULL using NULLIF
		ELSE sls_price
	END sls_price
FROM bronze.crm_sales_details;

-- Main Query ends

SELECT TOP 100 *
FROM silver.crm_sales_details;


-- =========================================
-- Identifying issues in bronze layer
-- =========================================

-- Check for Foreign keys with prd and cust table
SELECT *
FROM bronze.crm_sales_details
--WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

-- Identifying Invalid dates
-- check for sls_order_dt, sls_ship_dt, sls_due_dt
SELECT 
	NULLIF(sls_due_dt, 0) sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 OR LEN(sls_due_dt) != 8
	OR sls_due_dt > 20500101 OR sls_due_dt < 19000101;

-- Check for Invalid Order Dates
SELECT 
	*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- Data Consistency Check: Between Sales, Quantity and Price
-- Sales = Quantity * Price
-- Values must not be NULLS, Zeros, or Negatives.
SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- rerun the above queries with in silver layer for Data Quality checks