
-- Truncating before Inserting to avoid duplicates
TRUNCATE TABLE silver.crm_cust_info;
-- Preparing and Inserting data into silver.crm_cust_info table
-- Main Query starts here
INSERT INTO silver.crm_cust_info  (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
)
SELECT 
	cst_id,
	cst_key,
	TRIM(cst_firstname) cst_firstname,
	TRIM(cst_lastname) cst_lastname,
	CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		 WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		 ELSE 'n/a'
	END cst_marital_status,
	CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		 WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		 ELSE 'n/a'
	END cst_gndr,
	cst_create_date
FROM
(
	SELECT 
		*,
		ROW_NUMBER () 
			OVER 
				(PARTITION BY cst_id ORDER BY cst_create_date DESC) flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL)t 
WHERE flag_last = 1;
-- Main Query ends

-- Rerun the Quality check queries from the bronze layer to
-- verify the quality of data in the silver layer.
SELECT * FROM silver.crm_cust_info;


-- =========================================
-- Identifying issues in bronze layer
-- =========================================

-- Check for NULLS/Duplicates in Primary Key
-- Expectation: No Results
SELECT 
	cst_id,
	COUNT(*) 'Duplicates Primary Keys'
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;
-- Actual: Contain Results/duplicates or NULLS

-- Check for unwanted spaces in strings
-- Expectation: No Results
SELECT 
	cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);
-- Actual: contains spaces
SELECT 
	cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);
-- Actual: contains spaces
SELECT 
	cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);
-- Actual: No Results

-- Data Standardization and Consistency
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;
SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info;
-- Map to complete values for both instead of abbreviations


-- ===========================================================
-- Rerunning the Quality check queries from the bronze layer to
-- verify the quality of data in the silver layer.
-- ===========================================================

-- Check for NULLS/Duplicates in Primary Key
-- Expectation: No Results
SELECT 
	cst_id,
	COUNT(*) 'Duplicates Primary Keys'
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;
-- Actual: No Results

-- Check for unwanted spaces in strings
-- Expectation: No Results
SELECT 
	cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);
-- Actual: No spaces
SELECT 
	cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);
-- Actual: No spaces
SELECT 
	cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);
-- Actual: No spaces

-- Data Standardization and Consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info
-- Mapped correctly