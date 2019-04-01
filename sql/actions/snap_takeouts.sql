INSERT INTO snapped_takeouts
WITH points AS (
  SELECT
    id reach_id,
    tloc pt,
    streamleve putin_stream_level,
    streamorde putin_stream_order
  FROM reaches_${HU4} reaches
  JOIN snapped_putins ON reaches.id = snapped_putins.reach_id
  JOIN nhdplusflowlinevaa_${HU4} nhdplusflowlinevaa USING (nhdplusid)
),
candidates AS (
  SELECT
    reach_id,
    nhdplusid::bigint,
    nhdflowline.fdate,
    wbarea_permanent_identifier wbarea_id,
    ST_Transform(geom, 4326) geom
  FROM nhdflowline_${HU4} nhdflowline
  JOIN points ON ST_DWithin(
    geom::geography,
    ST_Transform(pt, ST_SRID(geom))::geography,
    2500)
  JOIN nhdplusflowlinevaa_${HU4} nhdplusflowlinevaa USING (nhdplusid)
  WHERE nhdflowline.fcode NOT IN (33600, 33601, 33602, 46003, 46007)
    -- take-outs should not involve going upstream on a tributary (reach 3448)
    -- AND putin_stream_order <= streamorde
    AND putin_stream_level >= streamleve
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
      -- <#> is fast, but it's a bbox distance calculation
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
  huc4 = EXCLUDED.huc4,
  nhdplusid = EXCLUDED.nhdplusid,
  fdate = EXCLUDED.fdate,
  candidates = EXCLUDED.candidates,
  distance = EXCLUDED.distance,
  geom = EXCLUDED.geom,
  flowline_point = EXCLUDED.flowline_point,
  original_point = EXCLUDED.original_point,
  link = EXCLUDED.link;