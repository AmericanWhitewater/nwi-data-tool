DROP MATERIALIZED VIEW IF EXISTS nhdwaterbody_1805;

-- materialized so that it can be indexed the same as the other tables
CREATE MATERIALIZED VIEW nhdwaterbody_1805 AS
  SELECT
    *,
    comid nhdplusid,
    comid::text permanent_identifier
  FROM nhdwaterbody_18
  WHERE reachcode LIKE '1805%';