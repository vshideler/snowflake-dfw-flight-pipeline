-- =============================================================
-- 04_snowpipe.sql
-- Creates the notification integration and Snowpipe for
-- automated ingestion from the Azure Blob external stage
--
-- Prerequisites:
--   - 01_setup.sql
--   - 02_stage.sql
--   - 03_tables.sql
-- =============================================================

USE DATABASE DFW_FLIGHTS;
USE SCHEMA RAW;

CREATE OR REPLACE NOTIFICATION INTEGRATION DFW_EVENT_GRID
  ENABLED = TRUE
  TYPE = QUEUE
  NOTIFICATION_PROVIDER = AZURE_STORAGE_QUEUE
  AZURE_STORAGE_QUEUE_PRIMARY_URI = '<storage-queue-uri-here>'
  AZURE_TENANT_ID = '<azure-tenant-id-here>';

-- After creating the integration, run the following and authorize
-- Snowflake's service principal in Azure:
-- DESC INTEGRATION DFW_EVENT_GRID;

-- Snowpipe: auto-ingests new files landing in the external stage
CREATE OR REPLACE PIPE DFW_FLIGHTS.RAW.DFW_SNOWPIPE
  AUTO_INGEST = TRUE
  INTEGRATION = 'DFW_EVENT_GRID'
  AS
  COPY INTO DFW_FLIGHTS.RAW.FLIGHT_RAW
  FROM @DFW_FLIGHTS.RAW.DFW_RAW_STAGE
  FILE_FORMAT = (FORMAT_NAME = 'DFW_FLIGHTS.RAW.DFW_CSV_FORMAT');
