-- =============================================================
-- 03_tables.sql
-- Creates the RAW, CLEAN, and FLAGGED tables
-- Source: BTS On-Time Reporting Carrier On-Time Performance
-- 110 columns matching the CSV export schema exactly
-- =============================================================

USE DATABASE DFW_FLIGHTS;
USE SCHEMA RAW;

-- RAW: landing table for Snowpipe ingestion
-- All 110 columns from the BTS CSV including trailing comma absorber
CREATE OR REPLACE TABLE FLIGHT_RAW (
    YEAR                            INT,
    QUARTER                         INT,
    MONTH                           INT,
    DAY_OF_MONTH                    INT,
    DAY_OF_WEEK                     INT,
    FLIGHT_DATE                     VARCHAR,
    REPORTING_AIRLINE               VARCHAR,
    DOT_ID_REPORTING_AIRLINE        INT,
    IATA_CODE_REPORTING_AIRLINE     VARCHAR,
    TAIL_NUMBER                     VARCHAR,
    FLIGHT_NUMBER_REPORTING_AIRLINE INT,
    ORIGIN_AIRPORT_ID               INT,
    ORIGIN_AIRPORT_SEQ_ID           INT,
    ORIGIN_CITY_MARKET_ID           INT,
    ORIGIN                          VARCHAR,
    ORIGIN_CITY_NAME                VARCHAR,
    ORIGIN_STATE                    VARCHAR,
    ORIGIN_STATE_FIPS               INT,
    ORIGIN_STATE_NAME               VARCHAR,
    ORIGIN_WAC                      INT,
    DEST_AIRPORT_ID                 INT,
    DEST_AIRPORT_SEQ_ID             INT,
    DEST_CITY_MARKET_ID             INT,
    DEST                            VARCHAR,
    DEST_CITY_NAME                  VARCHAR,
    DEST_STATE                      VARCHAR,
    DEST_STATE_FIPS                 INT,
    DEST_STATE_NAME                 VARCHAR,
    DEST_WAC                        INT,
    CRS_DEP_TIME                    INT,
    DEP_TIME                        FLOAT,
    DEP_DELAY                       FLOAT,
    DEP_DELAY_MINUTES               FLOAT,
    DEP_DEL15                       FLOAT,
    DEPARTURE_DELAY_GROUPS          FLOAT,
    DEP_TIME_BLK                    VARCHAR,
    TAXI_OUT                        FLOAT,
    WHEELS_OFF                      FLOAT,
    WHEELS_ON                       FLOAT,
    TAXI_IN                         FLOAT,
    CRS_ARR_TIME                    INT,
    ARR_TIME                        FLOAT,
    ARR_DELAY                       FLOAT,
    ARR_DELAY_MINUTES               FLOAT,
    ARR_DEL15                       FLOAT,
    ARRIVAL_DELAY_GROUPS            FLOAT,
    ARR_TIME_BLK                    VARCHAR,
    CANCELLED                       FLOAT,
    CANCELLATION_CODE               VARCHAR,
    DIVERTED                        FLOAT,
    CRS_ELAPSED_TIME                FLOAT,
    ACTUAL_ELAPSED_TIME             FLOAT,
    AIR_TIME                        FLOAT,
    FLIGHTS                         FLOAT,
    DISTANCE                        FLOAT,
    DISTANCE_GROUP                  INT,
    CARRIER_DELAY                   FLOAT,
    WEATHER_DELAY                   FLOAT,
    NAS_DELAY                       FLOAT,
    SECURITY_DELAY                  FLOAT,
    LATE_AIRCRAFT_DELAY             FLOAT,
    FIRST_DEP_TIME                  FLOAT,
    TOTAL_ADD_GTIME                 FLOAT,
    LONGEST_ADD_GTIME               FLOAT,
    DIV_AIRPORT_LANDINGS            INT,
    DIV_REACHED_DEST                FLOAT,
    DIV_ACTUAL_ELAPSED_TIME         FLOAT,
    DIV_ARR_DELAY                   FLOAT,
    DIV_DISTANCE                    FLOAT,
    DIV1_AIRPORT                    VARCHAR,
    DIV1_AIRPORT_ID                 INT,
    DIV1_AIRPORT_SEQ_ID             INT,
    DIV1_WHEELS_ON                  FLOAT,
    DIV1_TOTAL_GTIME                FLOAT,
    DIV1_LONGEST_GTIME              FLOAT,
    DIV1_WHEELS_OFF                 FLOAT,
    DIV1_TAIL_NUM                   VARCHAR,
    DIV2_AIRPORT                    VARCHAR,
    DIV2_AIRPORT_ID                 INT,
    DIV2_AIRPORT_SEQ_ID             INT,
    DIV2_WHEELS_ON                  FLOAT,
    DIV2_TOTAL_GTIME                FLOAT,
    DIV2_LONGEST_GTIME              FLOAT,
    DIV2_WHEELS_OFF                 FLOAT,
    DIV2_TAIL_NUM                   VARCHAR,
    DIV3_AIRPORT                    VARCHAR,
    DIV3_AIRPORT_ID                 INT,
    DIV3_AIRPORT_SEQ_ID             INT,
    DIV3_WHEELS_ON                  FLOAT,
    DIV3_TOTAL_GTIME                FLOAT,
    DIV3_LONGEST_GTIME              FLOAT,
    DIV3_WHEELS_OFF                 FLOAT,
    DIV3_TAIL_NUM                   VARCHAR,
    DIV4_AIRPORT                    VARCHAR,
    DIV4_AIRPORT_ID                 INT,
    DIV4_AIRPORT_SEQ_ID             INT,
    DIV4_WHEELS_ON                  FLOAT,
    DIV4_TOTAL_GTIME                FLOAT,
    DIV4_LONGEST_GTIME              FLOAT,
    DIV4_WHEELS_OFF                 FLOAT,
    DIV4_TAIL_NUM                   VARCHAR,
    DIV5_AIRPORT                    VARCHAR,
    DIV5_AIRPORT_ID                 INT,
    DIV5_AIRPORT_SEQ_ID             INT,
    DIV5_WHEELS_ON                  FLOAT,
    DIV5_TOTAL_GTIME                FLOAT,
    DIV5_LONGEST_GTIME              FLOAT,
    DIV5_WHEELS_OFF                 FLOAT,
    DIV5_TAIL_NUM                   VARCHAR,
    TRAILING_COMMA                  VARCHAR
);

-- CLEAN: validated records, identical structure to RAW minus TRAILING_COMMA
CREATE OR REPLACE TABLE CLEAN.FLIGHT_CLEAN AS
SELECT * EXCLUDE (TRAILING_COMMA)
FROM DFW_FLIGHTS.RAW.FLIGHT_RAW
WHERE 1 = 0;

-- FLAGGED: records that failed validation, includes rejection metadata
CREATE OR REPLACE TABLE FLAGGED.FLIGHT_FLAGGED AS
SELECT
    *,
    CAST(NULL AS VARCHAR) AS FLAG_REASON,
    CAST(NULL AS TIMESTAMP) AS FLAGGED_AT
FROM DFW_FLIGHTS.RAW.FLIGHT_RAW
WHERE 1 = 0;
