DROP MATERIALIZED VIEW IF EXISTS nhdwaterbody_${HU4};

-- materialized so that it can be indexed the same as the other tables
CREATE MATERIALIZED VIEW nhdwaterbody_${HU4} AS
  SELECT
    *,
    comid nhdplusid,
    comid::text permanent_identifier
  FROM nhdwaterbody_${HU2}
  WHERE reachcode LIKE '${HU4}%';