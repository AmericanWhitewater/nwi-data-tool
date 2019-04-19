DROP MATERIALIZED VIEW IF EXISTS nhd.nhdplusflowlinevaa_${HU4};

CREATE MATERIALIZED VIEW nhd.nhdplusflowlinevaa_${HU4} AS
  SELECT *,
    comid nhdplusid
  FROM nhdplusflowlinevaa_${HU2}
  WHERE reachcode LIKE '${HU4}%';