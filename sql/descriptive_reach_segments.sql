CREATE VIEW descriptive_reach_segments AS
  SELECT
    reach_id,
    reach_segments.revision,
    river,
    section,
    altname,
    huc4,
    review,
    review_reason,
    class,
    abstract,
    reach_segments.geom
  FROM reach_segments
  JOIN snapped_putins USING (reach_id, revision)
  JOIN reaches ON id = reach_id and reaches.revision = reach_segments.revision;
