DROP MATERIALIZED VIEW IF EXISTS nhdarea_1803;

-- materialized so that it can be indexed the same as the other tables
CREATE MATERIALIZED VIEW nhdarea_1803 AS
  SELECT
    *,
    comid nhdplusid,
    comid::text permanent_identifier
  FROM nhdarea_18;