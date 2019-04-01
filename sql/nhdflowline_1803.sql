DROP MATERIALIZED VIEW IF EXISTS nhdflowline_1803;

CREATE MATERIALIZED VIEW nhdflowline_1803 AS
  SELECT
    *,
    -- shim something in in place of an nhdplusid
    comid nhdplusid,
    wbareacomi::text wbarea_permanent_identifier
  FROM nhdflowline_18
  WHERE reachcode LIKE '1803%';