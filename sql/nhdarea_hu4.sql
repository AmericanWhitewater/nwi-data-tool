DROP MATERIALIZED VIEW IF EXISTS nhd.nhdarea_${HU4};

-- materialized so that it can be indexed the same as the other tables
CREATE MATERIALIZED VIEW nhd.nhdarea_${HU4} AS
  SELECT
    *,
    comid nhdplusid,
    comid::text permanent_identifier
  FROM nhdarea_${HU2};