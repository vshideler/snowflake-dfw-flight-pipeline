-- =============================================================
-- 05_validate.sql
-- Stored procedure SP_VALIDATE_FLIGHTS
--
-- Profiles every record in RAW against 15 data quality rules
-- and routes records to one of two destinations:
--   CLEAN.FLIGHT_CLEAN  -- records that pass all checks
--   FLAGGED.FLIGHT_FLAGGED -- records that fail, with FLAG_REASON
--
-- The sum of CLEAN + FLAGGED will always equal RAW (zero discrepancy)
--
-- To run:
--   CALL DFW_FLIGHTS.RAW.SP_VALIDATE_FLIGHTS();
--
-- Quality rules enforced:
--   1.  FLIGHT_DATE is not null
--   2.  REPORTING_AIRLINE is not null
--   3.  ORIGIN is not null
--   4.  DEST is not null
--   5.  CRS_DEP_TIME is not null
--   6.  CRS_ARR_TIME is not null
--   7.  CRS_ELAPSED_TIME is not null
--   8.  DISTANCE is not null
--   9.  ORIGIN must be a valid 3-letter airport code
--   10. DEST must be a valid 3-letter airport code
--   11. CRS_ELAPSED_TIME must be positive for non-cancelled flights
--   12. ACTUAL_ELAPSED_TIME must be positive for non-cancelled flights
--   13. ACTUAL_ELAPSED_TIME cannot exceed 24 hours (1440 minutes)
--   14. DISTANCE must be positive
--   15. CRS_DEP_TIME must be in valid HHMM range (0-2359)
--   16. CRS_ARR_TIME must be in valid HHMM range (0-2359)
--   17. Flight cannot be both cancelled and diverted
--   18. CARRIER_DELAY cannot be negative
--   19. WEATHER_DELAY cannot be negative
--   20. NAS_DELAY cannot be negative
--   21. SECURITY_DELAY cannot be negative
--   22. LATE_AIRCRAFT_DELAY cannot be negative
--   23. YEAR must be within expected range (1987-2100)
--   24. MONTH must be in range (1-12)
--   25. DAY_OF_MONTH must be in range (1-31)
-- =============================================================

USE DATABASE DFW_FLIGHTS;
USE SCHEMA RAW;

CREATE OR REPLACE PROCEDURE DFW_FLIGHTS.RAW.SP_VALIDATE_FLIGHTS()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
BEGIN

  -- Clear previous validation results only
  -- RAW is never truncated; it is the system of record
  TRUNCATE TABLE DFW_FLIGHTS.CLEAN.FLIGHT_CLEAN;
  TRUNCATE TABLE DFW_FLIGHTS.FLAGGED.FLIGHT_FLAGGED;

  -- Route flagged records first
  INSERT INTO DFW_FLIGHTS.FLAGGED.FLIGHT_FLAGGED
  SELECT
    *,
    CASE
      WHEN FLIGHT_DATE IS NULL
        THEN 'NULL: FLIGHT_DATE'
      WHEN REPORTING_AIRLINE IS NULL
        THEN 'NULL: REPORTING_AIRLINE'
      WHEN ORIGIN IS NULL
        THEN 'NULL: ORIGIN'
      WHEN DEST IS NULL
        THEN 'NULL: DEST'
      WHEN CRS_DEP_TIME IS NULL
        THEN 'NULL: CRS_DEP_TIME'
      WHEN CRS_ARR_TIME IS NULL
        THEN 'NULL: CRS_ARR_TIME'
      WHEN CRS_ELAPSED_TIME IS NULL
        THEN 'NULL: CRS_ELAPSED_TIME'
      WHEN DISTANCE IS NULL
        THEN 'NULL: DISTANCE'
      WHEN LENGTH(ORIGIN) != 3 OR NOT RLIKE(ORIGIN, '[A-Z]{3}')
        THEN 'INVALID: ORIGIN airport code'
      WHEN LENGTH(DEST) != 3 OR NOT RLIKE(DEST, '[A-Z]{3}')
        THEN 'INVALID: DEST airport code'
      WHEN CANCELLED = 0 AND CRS_ELAPSED_TIME <= 0
        THEN 'INVALID: CRS_ELAPSED_TIME must be positive for non-cancelled flights'
      WHEN CANCELLED = 0 AND ACTUAL_ELAPSED_TIME IS NOT NULL AND ACTUAL_ELAPSED_TIME <= 0
        THEN 'INVALID: ACTUAL_ELAPSED_TIME must be positive for non-cancelled flights'
      WHEN ACTUAL_ELAPSED_TIME > 1440
        THEN 'INVALID: ACTUAL_ELAPSED_TIME exceeds 24 hours'
      WHEN DISTANCE <= 0
        THEN 'INVALID: DISTANCE must be positive'
      WHEN CRS_DEP_TIME < 0 OR CRS_DEP_TIME > 2359
        THEN 'INVALID: CRS_DEP_TIME out of range'
      WHEN CRS_ARR_TIME < 0 OR CRS_ARR_TIME > 2359
        THEN 'INVALID: CRS_ARR_TIME out of range'
      WHEN CANCELLED = 1 AND DIVERTED = 1
        THEN 'INVALID: flight cannot be both cancelled and diverted'
      WHEN CARRIER_DELAY IS NOT NULL AND CARRIER_DELAY < 0
        THEN 'INVALID: CARRIER_DELAY is negative'
      WHEN WEATHER_DELAY IS NOT NULL AND WEATHER_DELAY < 0
        THEN 'INVALID: WEATHER_DELAY is negative'
      WHEN NAS_DELAY IS NOT NULL AND NAS_DELAY < 0
        THEN 'INVALID: NAS_DELAY is negative'
      WHEN SECURITY_DELAY IS NOT NULL AND SECURITY_DELAY < 0
        THEN 'INVALID: SECURITY_DELAY is negative'
      WHEN LATE_AIRCRAFT_DELAY IS NOT NULL AND LATE_AIRCRAFT_DELAY < 0
        THEN 'INVALID: LATE_AIRCRAFT_DELAY is negative'
      WHEN YEAR < 1987 OR YEAR > 2100
        THEN 'INVALID: YEAR out of expected range'
      WHEN MONTH < 1 OR MONTH > 12
        THEN 'INVALID: MONTH out of range'
      WHEN DAY_OF_MONTH < 1 OR DAY_OF_MONTH > 31
        THEN 'INVALID: DAY_OF_MONTH out of range'
    END AS FLAG_REASON,
    CURRENT_TIMESTAMP() AS FLAGGED_AT
  FROM DFW_FLIGHTS.RAW.FLIGHT_RAW
  WHERE
    FLIGHT_DATE IS NULL OR
    REPORTING_AIRLINE IS NULL OR
    ORIGIN IS NULL OR
    DEST IS NULL OR
    CRS_DEP_TIME IS NULL OR
    CRS_ARR_TIME IS NULL OR
    CRS_ELAPSED_TIME IS NULL OR
    DISTANCE IS NULL OR
    NOT RLIKE(ORIGIN, '[A-Z]{3}') OR
    NOT RLIKE(DEST, '[A-Z]{3}') OR
    (CANCELLED = 0 AND CRS_ELAPSED_TIME <= 0) OR
    (CANCELLED = 0 AND ACTUAL_ELAPSED_TIME IS NOT NULL AND ACTUAL_ELAPSED_TIME <= 0) OR
    ACTUAL_ELAPSED_TIME > 1440 OR
    DISTANCE <= 0 OR
    CRS_DEP_TIME < 0 OR CRS_DEP_TIME > 2359 OR
    CRS_ARR_TIME < 0 OR CRS_ARR_TIME > 2359 OR
    (CANCELLED = 1 AND DIVERTED = 1) OR
    (CARRIER_DELAY IS NOT NULL AND CARRIER_DELAY < 0) OR
    (WEATHER_DELAY IS NOT NULL AND WEATHER_DELAY < 0) OR
    (NAS_DELAY IS NOT NULL AND NAS_DELAY < 0) OR
    (SECURITY_DELAY IS NOT NULL AND SECURITY_DELAY < 0) OR
    (LATE_AIRCRAFT_DELAY IS NOT NULL AND LATE_AIRCRAFT_DELAY < 0) OR
    YEAR < 1987 OR YEAR > 2100 OR
    MONTH < 1 OR MONTH > 12 OR
    DAY_OF_MONTH < 1 OR DAY_OF_MONTH > 31;

  -- Route clean records
  INSERT INTO DFW_FLIGHTS.CLEAN.FLIGHT_CLEAN
  SELECT * EXCLUDE (TRAILING_COMMA)
  FROM DFW_FLIGHTS.RAW.FLIGHT_RAW
  WHERE
    FLIGHT_DATE IS NOT NULL AND
    REPORTING_AIRLINE IS NOT NULL AND
    ORIGIN IS NOT NULL AND
    DEST IS NOT NULL AND
    CRS_DEP_TIME IS NOT NULL AND
    CRS_ARR_TIME IS NOT NULL AND
    CRS_ELAPSED_TIME IS NOT NULL AND
    DISTANCE IS NOT NULL AND
    RLIKE(ORIGIN, '[A-Z]{3}') AND
    RLIKE(DEST, '[A-Z]{3}') AND
    (CANCELLED = 1 OR CRS_ELAPSED_TIME > 0) AND
    (ACTUAL_ELAPSED_TIME IS NULL OR ACTUAL_ELAPSED_TIME > 0) AND
    (ACTUAL_ELAPSED_TIME IS NULL OR ACTUAL_ELAPSED_TIME <= 1440) AND
    DISTANCE > 0 AND
    CRS_DEP_TIME >= 0 AND CRS_DEP_TIME <= 2359 AND
    CRS_ARR_TIME >= 0 AND CRS_ARR_TIME <= 2359 AND
    NOT (CANCELLED = 1 AND DIVERTED = 1) AND
    (CARRIER_DELAY IS NULL OR CARRIER_DELAY >= 0) AND
    (WEATHER_DELAY IS NULL OR WEATHER_DELAY >= 0) AND
    (NAS_DELAY IS NULL OR NAS_DELAY >= 0) AND
    (SECURITY_DELAY IS NULL OR SECURITY_DELAY >= 0) AND
    (LATE_AIRCRAFT_DELAY IS NULL OR LATE_AIRCRAFT_DELAY >= 0) AND
    YEAR >= 1987 AND YEAR <= 2100 AND
    MONTH >= 1 AND MONTH <= 12 AND
    DAY_OF_MONTH >= 1 AND DAY_OF_MONTH <= 31;

  RETURN 'Validation complete. Clean: ' ||
    (SELECT COUNT(*) FROM DFW_FLIGHTS.CLEAN.FLIGHT_CLEAN) ||
    ' rows. Flagged: ' ||
    (SELECT COUNT(*) FROM DFW_FLIGHTS.FLAGGED.FLIGHT_FLAGGED) ||
    ' rows.';

END;
$$;
