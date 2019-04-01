DROP MATERIALIZED VIEW IF EXISTS nhdplusflowlinevaa_1803;

CREATE MATERIALIZED VIEW nhdplusflowlinevaa_1803 AS
  SELECT *,
    comid nhdplusid
  FROM nhdplusflowlinevaa_18
  WHERE reachcode LIKE '1803%';