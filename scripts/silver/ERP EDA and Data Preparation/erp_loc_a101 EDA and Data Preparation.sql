
-- Truncating before Inserting to avoid duplicates
TRUNCATE TABLE silver.erp_loc_a101;
-- Preparing and Inserting data into silver.erp_loc_a101 table
-- Main Query starts here
INSERT INTO silver.erp_loc_a101 (
	cid,
	cntry
)
SELECT 
	REPLACE(cid, '-', '') cid,
	CASE WHEN UPPER(TRIM(cntry)) IN ('US', 'USA', 'UNITED STATES')
		 THEN 'United States'
		 WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
		 ELSE TRIM(cntry)
	END cntry
FROM bronze.erp_loc_a101;

-- Main Query ends

SELECT TOP 100 *
FROM silver.erp_loc_a101;

-- =========================================
-- Identifying issues in bronze layer
-- =========================================

-- checking and mapping the right key values
SELECT TOP 100 *
FROM bronze.erp_loc_a101;
SELECT TOP 100 *
FROM silver.crm_cust_info;
-- replace '-' with '' from the cid to match cid

-- Data Standardization and Consistency
SELECT DISTINCT cntry
FROM silver.erp_loc_a101;

-- rerun the above queries with in silver layer for Data Quality checks