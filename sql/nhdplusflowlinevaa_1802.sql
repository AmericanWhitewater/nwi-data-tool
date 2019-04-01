DROP MATERIALIZED VIEW IF EXISTS nhdplusflowlinevaa_1802;

CREATE MATERIALIZED VIEW nhdplusflowlinevaa_1802 AS
  SELECT *,
    comid nhdplusid
  FROM nhdplusflowlinevaa_18
  WHERE reachcode LIKE '1802%';