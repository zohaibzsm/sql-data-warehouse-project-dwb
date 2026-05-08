
-- Truncating before Inserting to avoid duplicates
TRUNCATE TABLE silver.erp_cust_az12;
-- Preparing and Inserting data into silver.erp_cust_az12 table
-- Main Query starts here
INSERT INTO silver.erp_cust_az12 (
	cid,
	bdate,
	gen
)
SELECT 
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
		 ELSE cid
	END cid,
	CASE WHEN bdate > GETDATE() THEN NULL
		 ELSE bdate
	END bdate,
	CASE WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
		 WHEN UPPER(TRIM(gen)) IN ('M', 'FEMALE') THEN 'Female'
		 ELSE 'n/a'
	END gen
FROM bronze.erp_cust_az12;

-- Main Query ends

SELECT TOP 100 *
FROM silver.erp_cust_az12;

-- =========================================
-- Identifying issues in bronze layer
-- =========================================

-- checking and mapping the right key values
SELECT TOP 100 *
FROM bronze.erp_cust_az12;
SELECT TOP 100 *
FROM silver.crm_cust_info;
-- remove NAS from the cid due to no specification

-- Data Standardization and Consistency
SELECT DISTINCT gen
FROM silver.erp_cust_az12;

-- Check for Invalid Dates
SELECT bdate
FROM silver.erp_cust_az12
WHERE bdate < '1920-01-01' OR bdate > GETDATE();

-- rerun the above queries with in silver layer for Data Quality checks