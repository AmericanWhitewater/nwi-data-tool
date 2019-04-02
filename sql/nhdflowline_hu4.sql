DROP MATERIALIZED VIEW IF EXISTS nhdflowline_${HU4};

CREATE MATERIALIZED VIEW nhdflowline_${HU4} AS
  SELECT
    *,
    -- shim something in in place of an nhdplusid
    comid nhdplusid,
    wbareacomi::text wbarea_permanent_identifier
  FROM nhdflowline_${HU2}
  WHERE reachcode LIKE '${HU4}%';