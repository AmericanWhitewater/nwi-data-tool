DROP MATERIALIZED VIEW IF EXISTS nhdplusflowlinevaa_1804;

CREATE MATERIALIZED VIEW nhdplusflowlinevaa_1804 AS
  SELECT *,
    comid nhdplusid
  FROM nhdplusflowlinevaa_18
  WHERE reachcode LIKE '1804%';