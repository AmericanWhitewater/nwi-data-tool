DROP MATERIALIZED VIEW IF EXISTS nhdwaterbody_1807;

-- materialized so that it can be indexed the same as the other tables
CREATE MATERIALIZED VIEW nhdwaterbody_1807 AS
  SELECT
    *,
    comid nhdplusid,
    comid::text permanent_identifier
  FROM nhdwaterbody_18
  WHERE reachcode LIKE '1807%';