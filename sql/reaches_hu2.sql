CREATE TABLE tmp.reaches_${HU2} AS
  SELECT DISTINCT
    id,
    revision,
    river,
    section,
    altname,
    ploc,
    tloc
  FROM reaches
  JOIN wbdhu4 ON (
    -- WBD is in EPSG 4269; reaches is 4326
    -- put-in is within the watershed
    ST_Contains(geom, ST_Transform(ploc, ST_SRID(geom)))
    -- take-out is within the watershed
    OR ST_Contains(geom, ST_Transform(tloc, ST_SRID(geom))))
  WHERE huc4 LIKE '${HU2}%'
    -- current revision
    AND is_final
    AND status != 'd';