INSERT INTO reach_segments
  WITH snapped_reaches AS (
    SELECT
      p.reach_id,
      p.nhdplusid putin_nhdplusid,
      t.nhdplusid takeout_nhdplusid,
      p.flowline_point putin_geom,
      t.flowline_point takeout_geom
    FROM snapped_putins p
    JOIN snapped_takeouts t USING (reach_id)
    WHERE p.huc4 = '${HU4}'
      AND p.flowline_point IS NOT NULL
      AND t.flowline_point IS NOT NULL
    ORDER BY reach_id
  ),
  segments AS (
    SELECT
      reach_id,
      (
        WITH RECURSIVE flowlines(idx, nhdplusid, reachcode, hydroseq, downstream, fdate, geom, takeout) AS (
            SELECT
              0 idx,
              nhdflowline.nhdplusid,
              nhdflowline.reachcode,
              nhdplusflowlinevaa.hydroseq,
              dnhydroseq downstream,
              nhdflowline.fdate,
              ST_Transform(geom, 4326) geom,
              -- put-in and take-out are on the same segment (642)
              putin_nhdplusid = takeout_nhdplusid takeout
            FROM nhdflowline_${HU4} nhdflowline
            JOIN nhdplusflowlinevaa_${HU4} nhdplusflowlinevaa USING (nhdplusid)
            WHERE nhdplusid = putin_nhdplusid
              AND fcode NOT IN (56600) -- coastline
              -- put-in and take-out are the same point (642)
              AND NOT ST_Equals(putin_geom, takeout_geom)
          UNION ALL
            -- stop at the takeout
            SELECT
              idx + 1 idx,
              nhdflowline.nhdplusid,
              nhdflowline.reachcode,
              nhdplusflowlinevaa.hydroseq,
              dnhydroseq downstream,
              nhdflowline.fdate,
              ST_Transform(nhdflowline.geom, 4326) geom,
              takeout OR nhdflowline.nhdplusid = takeout_nhdplusid takeout
            FROM nhdflowline_${HU4} nhdflowline
            JOIN nhdplusflowlinevaa_${HU4} nhdplusflowlinevaa USING (nhdplusid)
            JOIN flowlines ON nhdplusflowlinevaa.hydroseq = flowlines.downstream
            WHERE NOT takeout
              AND fcode NOT IN (56600) -- coastline
        ),
        -- merge consecutive flowlines together
        merged AS (
          SELECT
            array_agg(nhdplusid) nhdplusids,
            array_agg(distinct reachcode) reachcodes,
            max(fdate) fdate,
            ST_LineMerge(ST_Union(geom)) geom
          FROM flowlines
        -- ),
        -- -- if merged flowlines are a MultiLineString, they didn't stitch
        -- -- together properly, so dump them
        -- -- this addresses the error in 2727 [1709], which may be the result
        -- -- of bad NHD topology
        -- dumped AS (
        --   SELECT
        --     nhdplusids,
        --     ST_Dump(geom) dump
        --   FROM merged
        -- ),
        -- -- then reverse them
        -- reversed AS (
        --   SELECT *
        --   FROM dumped
        --   ORDER BY (dump).path DESC
        -- ),
        -- -- and join them again
        -- joined AS (
        --   SELECT
        --     nhdplusids,
        --     ST_MakeLine((dump).geom) geom
        --   FROM reversed
        --   GROUP BY nhdplusids
        ),
        locations AS (
          SELECT
            nhdplusids,
            reachcodes,
            fdate,
            geom,
            -- line_locate_point: 1st arg isn't a line
            -- 2727 produces a MultiLineString
            CASE
            WHEN GeometryType(geom) = 'LINESTRING' THEN
              ST_LineLocatePoint(
                geom,
                putin_geom
              )
            ELSE 0.0
            END putin_loc,
            CASE
            WHEN GeometryType(geom) = 'LINESTRING' THEN
              ST_LineLocatePoint(
                geom,
                takeout_geom
              )
            ELSE 1.0
            END takeout_loc,
            -- geometries other than LineStrings are questionable
            GeometryType(geom) != 'LINESTRING' questionable
          FROM merged
        )
        SELECT
          ROW(
            nhdplusids,
            reachcodes,
            fdate,
            ST_LineSubstring(
              geom,
              -- handle put-ins snapped downstream of take-outs
              -- on short reaches (single nhdplusid), this will produce good
              -- data
              -- on longer reaches, only the last segment will be used (10559 in
              -- 0107)
              least(putin_loc, takeout_loc),
              greatest(putin_loc, takeout_loc)
            ),
            -- put-ins downstream of take-outs are questionable
            questionable OR putin_loc > takeout_loc
          )::segment segment
        FROM locations
      )
    FROM snapped_reaches
  )
  SELECT
    reach_id,
    (segment).nhdplusids,
    (segment).reachcodes,
    (segment).fdate,
    (segment).questionable
      -- put-ins or take-outs not on the generated segment are questionable
      OR NOT ST_DWithin((segment).geom::geography, putin_geom::geography, 1)
      OR NOT ST_DWithin((segment).geom::geography, takeout_geom::geography, 1),
    (segment).geom
  FROM segments
  JOIN snapped_reaches USING (reach_id)
  ON CONFLICT (reach_id) DO UPDATE
  SET
    nhdplusids = EXCLUDED.nhdplusids,
    reachcodes = EXCLUDED.reachcodes,
    fdate = EXCLUDED.fdate,
    questionable = EXCLUDED.questionable,
    geom = EXCLUDED.geom;