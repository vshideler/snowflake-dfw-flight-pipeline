-- =============================================================
-- 02_stage.sql
-- Creates the Azure storage integration, file format, and
-- external stage pointing to the dfw-flight-data blob container
-- =============================================================

-- Storage integration (run once, requires ACCOUNTADMIN role)
CREATE STORAGE INTEGRATION DFW_AZURE_INTEGRATION
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'AZURE'
  ENABLED = TRUE
  AZURE_TENANT_ID = '<your-azure-tenant-id>'
  STORAGE_ALLOWED_LOCATIONS = ('azure://azurestorageaccount.blob.core.windows.net/dfw-flight-data/');

-- After creating the integration, run the following and grant
-- Snowflake's service principal access to the blob container in Azure:
-- DESC INTEGRATION DFW_AZURE_INTEGRATION;

-- File format for BTS CSV files
CREATE OR REPLACE FILE FORMAT DFW_FLIGHTS.RAW.DFW_CSV_FORMAT
  TYPE = 'CSV'
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1
  NULL_IF = ('', 'NA')
  EMPTY_FIELD_AS_NULL = TRUE
  TRIM_SPACE = TRUE;

-- External stage
CREATE OR REPLACE STAGE DFW_FLIGHTS.RAW.DFW_RAW_STAGE
  STORAGE_INTEGRATION = DFW_AZURE_INTEGRATION
  URL = 'azure://azurestorageaccount.blob.core.windows.net/dfw-flight-data/'
  FILE_FORMAT = DFW_FLIGHTS.RAW.DFW_CSV_FORMAT;
