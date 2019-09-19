INSERT INTO snapped_putins
WITH points AS (
  SELECT
    id reach_id,
    revision,
    ploc pt
  FROM reaches_${HU4} reaches
),
candidates AS (
  SELECT
    reach_id,
    nhdplusid::bigint,
    fdate,
    wbarea_permanent_identifier wbarea_id,
    ST_Transform(geom, 4326) geom
  FROM nhdflowline_${HU4} nhdflowline
  JOIN points ON ST_DWithin(
    geom::geography,
    ST_Transform(pt, ST_SRID(geom))::geography,
    2500)
  WHERE fcode NOT IN (33600, 33601, 33602, 46007)
    -- don't snap to these reaches
    AND reachcode NOT IN ('02070008000365')
),
candidate_lines as (
  SELECT
    reach_id,
    pt,
    (
      SELECT count(*)
      FROM candidates
      WHERE candidates.reach_id = points.reach_id
    ) candidates,
    (
      SELECT ROW(
        nhdplusid,
        fdate,
        wbarea_id,
        geom
      )::flowline line
      FROM candidates
      WHERE candidates.reach_id = points.reach_id
      ORDER BY ST_Distance(geom, pt)
      LIMIT 1
    )
  FROM points
),
waterbodies AS (
  SELECT
    permanent_identifier,
    geom
  FROM nhdarea_${HU4} nhdarea
  UNION ALL
  SELECT
    permanent_identifier,
    geom
  FROM nhdwaterbody_${HU4} nhdwaterbody
),
snapped AS (
  SELECT
    reach_id,
    (line).nhdplusid,
    (line).fdate,
    candidates,
    ST_ClosestPoint(
      coalesce(ST_Transform(ST_Boundary(geom), 4326), (line).line),
      pt) geom,
    ST_ClosestPoint((line).line, pt) flowline_point
  FROM candidate_lines
  LEFT JOIN waterbodies ON (line).wbarea_id = permanent_identifier
)
SELECT
  reach_id,
  revision,
  '${HU4}' huc4,
  nhdplusid,
  fdate,
  candidates,
  ST_Distance(geom::geography, pt::geography) distance,
  geom,
  flowline_point,
  pt original_point,
  ST_MakeLine(pt, geom) link
FROM snapped
JOIN points USING (reach_id)
ON CONFLICT (reach_id) DO UPDATE
SET
  revision = EXCLUDED.revision,
  huc4 = EXCLUDED.huc4,
  nhdplusid = EXCLUDED.nhdplusid,
  fdate = EXCLUDED.fdate,
  candidates = EXCLUDED.candidates,
  distance = EXCLUDED.distance,
  geom = EXCLUDED.geom,
  flowline_point = EXCLUDED.flowline_point,
  original_point = EXCLUDED.original_point,
  link = EXCLUDED.link;