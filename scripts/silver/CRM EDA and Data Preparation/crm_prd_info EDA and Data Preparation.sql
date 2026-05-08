
-- Truncating before Inserting to avoid duplicates
TRUNCATE TABLE silver.crm_prd_info;
-- Preparing and Inserting data into silver.crm_prd_info table
-- Main Query starts here
INSERT INTO silver.crm_prd_info  (
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
)
SELECT 
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, 
	-- replacing bcz in erp table, categories contain underscores
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
	prd_nm,
	ISNULL(prd_cost, 0) prd_cost,
	CASE UPPER(TRIM(prd_line))
		 WHEN 'M' THEN 'Mountain'
		 WHEN 'R' THEN 'Road'
		 WHEN 'S' THEN 'other Sales'
		 WHEN 'T' THEN 'Touring'
		 ELSE 'n/a'
	END AS prd_line,
	CAST (prd_start_dt AS DATE) prd_start_dt,
	CAST (LEAD (prd_start_dt) 
		OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) prd_end_dt
FROM bronze.crm_prd_info;
-- Main Query ends

-- Rerun the Quality check queries from the bronze layer to
-- verify the quality of data in the silver layer.
SELECT * FROM silver.crm_prd_info;


-- =========================================
-- Identifying issues in bronze layer
-- =========================================
SELECT * FROM bronze.crm_prd_info;

-- Check for Nulls/Duplicates in Primary Key
-- Expectation: No Results
SELECT 
	prd_id,
	COUNT(*) 'Duplicates Primary Keys'
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;
-- Actual Result: No Results

-- Check for unwanted spaces in strings
-- Expectation: No Results
SELECT 
	prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);
-- Actual: No Results

-- Check for NULLS or Negative Numbers
-- Expectation: No Results
SELECT 
	prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;
-- Actual: contains NULLS only

-- Data Standardization and Consistency
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;
-- Map to complete values for both instead of abbreviations


-- Check for Invalid Date Orders
SELECT *
FROM bronze.crm_prd_info
WHERE prd_start_dt > prd_end_dt;
-- contains Invalid Dates
-- Fixing the Invalid Date Orders
SELECT
	prd_id,
	prd_key,
	prd_start_dt,
	LEAD (prd_start_dt) 
		OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 prd_end_dt_test,
	prd_end_dt
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509')


-- ===========================================================
-- Rerunning the Quality check queries from the bronze layer to
-- verify the quality of data in the silver layer.
-- ===========================================================

-- Check for Nulls/Duplicates in Primary Key
-- Expectation: No Results
SELECT 
	prd_id,
	COUNT(*) 'Duplicates Primary Keys'
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;
-- Actual Result: No Results

-- Check for unwanted spaces in strings
-- Expectation: No Results
SELECT 
	prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);
-- Actual: No Results

-- Check for NULLS or Negative Numbers
-- Expectation: No Results
SELECT 
	prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;
-- Actual: No Results

-- Data Standardization and Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;
-- Mapped correctly

-- Check for Invalid Date Orders
-- Expectation: No Results
SELECT *
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt;
-- Actual: No Results