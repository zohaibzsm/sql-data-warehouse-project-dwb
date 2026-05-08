
-- Truncating before Inserting to avoid duplicates
TRUNCATE TABLE silver.erp_px_cat_g1v2;
-- Preparing and Inserting data into silver.erp_px_cat_g1v2 table
-- Main Query starts here
INSERT INTO silver.erp_px_cat_g1v2 (
	id,
	cat,
	subcat,
	maintenance
)
SELECT 
	id,
	cat,
	subcat,
	maintenance
FROM bronze.erp_px_cat_g1v2;

-- Main Query ends

SELECT TOP 100 *
FROM silver.erp_px_cat_g1v2;

-- =========================================
-- Identifying issues in bronze layer
-- =========================================

-- checking and mapping the right key values
SELECT TOP 100 *
FROM bronze.erp_px_cat_g1v2
WHERE id NOT IN (SELECT cat_id FROM silver.crm_prd_info);

SELECT TOP 100 *
FROM silver.crm_prd_info
WHERE cat_id NOT IN (SELECT id FROM bronze.erp_px_cat_g1v2);
-- 

-- Check for unwanted spaces
-- check for all non-key columns
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE TRIM(cat) != cat OR TRIM(subcat) != subcat 
OR TRIM(maintenance) != maintenance;

-- Data Standardization and Consistency 
-- Check for all non-key columns
SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2;

-- rerun the above queries with in silver layer for Data Quality checks