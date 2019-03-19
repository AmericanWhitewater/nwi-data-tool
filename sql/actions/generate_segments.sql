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
      -- problematic reaches
      AND reach_id NOT IN (2727) -- HUC4 1709
    ORDER BY reach_id
  ),
  segments AS (
    SELECT
      reach_id,
      (
        WITH RECURSIVE flowlines(idx, nhdplusid, hydroseq, downstream, geom, takeout) AS (
            SELECT
              0 idx,
              nhdflowline.nhdplusid,
              nhdplusflowlinevaa.hydroseq,
              dnhydroseq downstream,
              ST_Transform(geom, 4326) geom,
              -- put-in and take-out are on the same segment (642)
              putin_nhdplusid = takeout_nhdplusid takeout
            FROM nhdflowline_${HU4} nhdflowline
            JOIN nhdplusflowlinevaa_${HU4} nhdplusflowlinevaa USING (nhdplusid)
            WHERE nhdplusid = putin_nhdplusid
              -- put-in and take-out are the same point (642)
              AND NOT ST_Equals(putin_geom, takeout_geom)
          UNION ALL
            -- stop at the takeout
            SELECT
              idx + 1 idx,
              nhdflowline.nhdplusid,
              nhdplusflowlinevaa.hydroseq,
              dnhydroseq downstream,
              ST_Transform(nhdflowline.geom, 4326) geom,
              -- ST_LineMerge(flowlines.geom, ST_Transform(nhdflowline.geom, 4326)) geom,
              takeout OR nhdflowline.nhdplusid = takeout_nhdplusid takeout
            FROM nhdflowline_${HU4} nhdflowline
            JOIN nhdplusflowlinevaa_${HU4} nhdplusflowlinevaa USING (nhdplusid)
            JOIN flowlines ON nhdplusflowlinevaa.hydroseq = flowlines.downstream
            WHERE NOT takeout
        ),
        -- merge consecutive flowlines together
        -- TODO accumulate in recursive stage of ^^
        merged AS (
          SELECT
            array_agg(nhdplusid) nhdplusids,
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
            geom,
            -- line_locate_point: 1st arg isn't a line
            -- 2727 produces a MultiLineString
            ST_LineLocatePoint(
              geom,
              putin_geom
            ) putin_loc,
            ST_LineLocatePoint(
              geom,
              takeout_geom
            ) takeout_loc
          FROM merged
        )
        SELECT
          ROW(
            nhdplusids,
            ST_LineSubstring(
              geom,
              -- handle put-ins snapped downstream of take-outs
              -- on short reaches (single nhdplusid), this will produce good
              -- data
              -- on longer reaches, only the last segment will be used (10559 in
              -- 0107)
              least(putin_loc, takeout_loc),
              greatest(putin_loc, takeout_loc)
            )
          )::segment segment
        FROM locations
      )
    FROM snapped_reaches
  )
  SELECT
    reach_id,
    (segment).nhdplusids,
    (segment).geom
  FROM segments
  WHERE GeometryType((segment).geom) = 'LINESTRING'
  ON CONFLICT (reach_id) DO UPDATE
  SET
    nhdplusids = EXCLUDED.nhdplusids,
    geom = EXCLUDED.geom;