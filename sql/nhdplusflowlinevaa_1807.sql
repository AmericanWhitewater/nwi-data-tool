DROP MATERIALIZED VIEW IF EXISTS nhdplusflowlinevaa_1807;

CREATE MATERIALIZED VIEW nhdplusflowlinevaa_1807 AS
  SELECT *,
    comid nhdplusid
  FROM nhdplusflowlinevaa_18
  WHERE reachcode LIKE '1807%';