DROP MATERIALIZED VIEW IF EXISTS nhdplusflowlinevaa_1805;

CREATE MATERIALIZED VIEW nhdplusflowlinevaa_1805 AS
  SELECT *,
    comid nhdplusid
  FROM nhdplusflowlinevaa_18
  WHERE reachcode LIKE '1805%';