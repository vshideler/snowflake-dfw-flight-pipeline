-- =============================================================
-- 01_setup.sql
-- Creates the database, schemas, and virtual warehouse
-- =============================================================

CREATE DATABASE IF NOT EXISTS DFW_FLIGHTS;
USE DATABASE DFW_FLIGHTS;

CREATE SCHEMA IF NOT EXISTS RAW;
CREATE SCHEMA IF NOT EXISTS CLEAN;
CREATE SCHEMA IF NOT EXISTS FLAGGED;

CREATE WAREHOUSE IF NOT EXISTS DFW_WH
  WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

USE WAREHOUSE DFW_WH;
