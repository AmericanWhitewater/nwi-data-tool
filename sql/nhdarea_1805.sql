DROP MATERIALIZED VIEW IF EXISTS nhdarea_1805;

-- materialized so that it can be indexed the same as the other tables
CREATE MATERIALIZED VIEW nhdarea_1805 AS
  SELECT
    *,
    comid nhdplusid,
    comid::text permanent_identifier
  FROM nhdarea_18;