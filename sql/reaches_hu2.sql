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
  JOIN wbdhu2 ON (
    -- WBD is in EPSG 4269; reaches is 4326
    -- put-in is within the watershed
    ST_Contains(wbdhu2.geom, ST_Transform(ploc, ST_SRID(wbdhu2.geom)))
    -- take-out is within the watershed
    OR ST_Contains(wbdhu2.geom, ST_Transform(tloc, ST_SRID(wbdhu2.geom))))
  WHERE huc2 = '${HU2}'
    -- current revision
    AND is_final
    AND status != 'd';