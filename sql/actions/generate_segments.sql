INSERT INTO reach_segments
  WITH snapped_reaches AS (
    -- collect various reach-related columns together
    SELECT
      p.reach_id,
      p.nhdplusid putin_nhdplusid,
      t.nhdplusid takeout_nhdplusid,
      p.flowline_point putin_flowline_point,
      p.geom putin_geom,
      p.distance putin_distance,
      t.flowline_point takeout_flowline_point,
      t.geom takeout_geom,
      -- default to 40km
      COALESCE(NULLIF(r.length, 0) * 1609.34, 40000) length,
      r.ploc original_putin_geom,
      r.tloc original_takeout_geom
    FROM snapped_putins p
    JOIN snapped_takeouts t USING (reach_id)
    JOIN reaches r ON r.id = p.reach_id
    WHERE p.huc4 = '${HU4}'
      AND p.flowline_point IS NOT NULL
      AND t.flowline_point IS NOT NULL
      AND r.is_final
    ORDER BY reach_id
  ),
  candidates AS (
    -- generate a set of candidate lines, effectively clipped to nhdflowline
    -- segments (but may continue downstream if initially-snapped takeout
    -- locations aren't on the part of the flow network that's traversed)
    SELECT
      reach_id,
      (
        WITH RECURSIVE flowlines(downstream, geom, takeout, length) AS (
            SELECT
              dnhydroseq downstream,
              ST_Transform(geom, 4326) geom,
              -- put-in and take-out are on the same segment (642)
              putin_nhdplusid = takeout_nhdplusid takeout,
              ST_Length(ST_Transform(geom, 4326)::geography) length
            FROM nhdflowline_${HU4} nhdflowline
            JOIN nhdplusflowlinevaa_${HU4} nhdplusflowlinevaa USING (nhdplusid)
            WHERE nhdplusid = putin_nhdplusid
              -- put-in and take-out are the same point (642)
              AND NOT ST_Equals(putin_geom, takeout_geom)
          UNION ALL
            -- stop at the takeout
            SELECT
              dnhydroseq downstream,
              ST_Transform(nhdflowline.geom, 4326) geom,
              takeout OR nhdflowline.nhdplusid = takeout_nhdplusid takeout,
              length + ST_Length(ST_Transform(nhdflowline.geom, 4326)::geography) length
            FROM nhdflowline_${HU4} nhdflowline
            JOIN nhdplusflowlinevaa_${HU4} nhdplusflowlinevaa USING (nhdplusid)
            JOIN flowlines ON nhdplusflowlinevaa.hydroseq = flowlines.downstream
            WHERE
              -- if the takeout is on the network stop; if not, keep going until
              -- the distance threshold is reached
              NOT takeout
              -- don't treat coastline as part of the flow network
              AND nhdflowline.fcode NOT IN (56600)
              -- cap the distance
              AND length + ST_Length(ST_Transform(nhdflowline.geom, 4326)::geography) < snapped_reaches.length * 1.5
        )
        -- merge consecutive flowlines together
        SELECT
          ST_LineMerge(ST_Union(geom)) geom
        FROM flowlines
      )
    FROM snapped_reaches
  ),
  resnapped_takeouts AS (
    -- re-snap takeout locations to target lines, ensuring that they will be
    -- on the traversed flow network
    WITH flowline_points AS (
      -- identify points on the flow network
      SELECT
        reach_id,
        original_takeout_geom,
        geom candidate_geom,
        ST_ClosestPoint(candidates.geom, original_takeout_geom) takeout_flowline_point
      FROM candidates
      JOIN snapped_reaches USING (reach_id)
    ),
    targets AS (
      -- look up nhdflowline attributes based on the identified closest point
      SELECT
        -- return 1 target per reach, the one closest to the original geometry
        DISTINCT ON (reach_id)
        reach_id,
        wbarea_permanent_identifier wbarea_id,
        ST_Transform(geom, 4326) geom
      FROM nhdflowline_${HU4} nhdflowline
      JOIN flowline_points ON ST_DWithin(geom, ST_Transform(takeout_flowline_point, ST_SRID(geom)), 0.0001)
      WHERE ST_Distance(geom::geography, ST_Transform(original_takeout_geom, ST_SRID(geom))::geography) <= 2500
      ORDER BY reach_id, ST_Distance(geom, ST_Transform(original_takeout_geom, ST_SRID(geom))) ASC
    ),
    waterbodies AS (
      -- union nhdarea and nhdwaterbody
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
        original_takeout_geom,
        takeout_flowline_point,
        ST_ClosestPoint(
          -- find the closest point on an associated waterbody (if available,
          -- otherwise use the target flowline)
          coalesce(ST_Transform(ST_Boundary(waterbodies.geom), 4326), targets.geom),
          original_takeout_geom) takeout_geom
      FROM targets
      JOIN flowline_points USING (reach_id)
      LEFT JOIN waterbodies ON wbarea_id = permanent_identifier
    )
    SELECT
      reach_id,
      '${HU4}' huc4,
      -- measure the distance the the takeout was moved
      ST_Distance(takeout_geom::geography, original_takeout_geom::geography) takeout_distance,
      original_takeout_geom,
      takeout_flowline_point,
      takeout_geom
    FROM snapped
  ),
  locations AS (
    SELECT
      reach_id,
      candidates.geom,
      -- line_locate_point: 1st arg isn't a line
      -- 2727 produces a MultiLineString
      CASE
      WHEN GeometryType(candidates.geom) = 'LINESTRING' THEN
        ST_LineLocatePoint(
          candidates.geom,
          putin_flowline_point
        )
      ELSE 0.0
      END putin_loc,
      CASE
      WHEN GeometryType(candidates.geom) = 'LINESTRING' THEN
        ST_LineLocatePoint(
          candidates.geom,
          resnapped_takeouts.takeout_flowline_point
        )
      ELSE 1.0
      END takeout_loc,
      -- geometries other than LineStrings are questionable
      GeometryType(candidates.geom) != 'LINESTRING' review,
      CASE
      WHEN GeometryType(candidates.geom) != 'LINESTRING' THEN
        'Unexpected line type: ' || GeometryType(candidates.geom)
      ELSE null
      END review_reason
    FROM candidates
    JOIN snapped_reaches USING (reach_id)
    JOIN resnapped_takeouts USING (reach_id)
  ),
  segments AS (
    SELECT
      reach_id,
      ST_LineSubstring(
        geom,
        -- handle put-ins snapped downstream of take-outs
        -- on short reaches (single nhdplusid), this will produce good data
        -- on longer reaches, only the last segment will be used (10559 in 0107)
        least(putin_loc, takeout_loc),
        greatest(putin_loc, takeout_loc)
      ) geom,
      -- put-ins downstream of take-outs are questionable
      review OR putin_loc > takeout_loc review,
      COALESCE(CASE WHEN putin_loc > takeout_loc THEN 'Take-out is upstream' ELSE null END, review_reason) review_reason
    FROM locations
  )
  SELECT
    reach_id,
    review
      -- put-ins or take-outs not on the generated segment are questionable
      OR NOT ST_DWithin(segments.geom, putin_flowline_point, 0.0001)
      OR NOT ST_DWithin(segments.geom, resnapped_takeouts.takeout_flowline_point, 0.0001) review,
    COALESCE(
      CASE
      WHEN 
        NOT ST_DWithin(segments.geom, putin_flowline_point, 0.0001)
        OR NOT ST_DWithin(segments.geom, resnapped_takeouts.takeout_flowline_point, 0.0001) THEN 'Access points are not on generated segment'
      ELSE null END,
      review_reason) review_reason,
    segments.geom,
    snapped_reaches.putin_distance,
    snapped_reaches.original_putin_geom,
    snapped_reaches.putin_flowline_point,
    snapped_reaches.putin_geom,
    resnapped_takeouts.takeout_distance,
    snapped_reaches.original_takeout_geom,
    resnapped_takeouts.takeout_flowline_point,
    resnapped_takeouts.takeout_geom
  FROM segments
  JOIN snapped_reaches USING (reach_id)
  JOIN resnapped_takeouts USING (reach_id)
ON CONFLICT (reach_id) DO UPDATE
  SET
    review = EXCLUDED.review,
    review_reason = EXCLUDED.review_reason,
    geom = EXCLUDED.geom,
    putin_distance = EXCLUDED.putin_distance,
    original_putin_geom = EXCLUDED.original_putin_geom,
    putin_flowline_point = EXCLUDED.putin_flowline_point,
    putin_geom = EXCLUDED.putin_geom,
    takeout_distance = EXCLUDED.takeout_distance,
    original_takeout_geom = EXCLUDED.original_takeout_geom,
    takeout_flowline_point = EXCLUDED.takeout_flowline_point,
    takeout_geom = EXCLUDED.takeout_geom;
