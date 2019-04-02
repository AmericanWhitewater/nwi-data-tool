DROP MATERIALIZED VIEW IF EXISTS nhdplusflowlinevaa_${HU4};

CREATE MATERIALIZED VIEW nhdplusflowlinevaa_${HU4} AS
  SELECT *,
    comid nhdplusid
  FROM nhdplusflowlinevaa_${HU2}
  WHERE reachcode LIKE '${HU4}%';