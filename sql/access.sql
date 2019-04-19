CREATE VIEW access AS
  SELECT
    'putin-' || reach_id id,
    reach_id,
    river,
    section,
    huc4,
    putin_distance distance,
    putin_geom geom,
    'put-in' AS type,
    review,
    review_reason
  FROM reach_segments
  JOIN snapped_putins USING (reach_id)
  JOIN reaches ON id = reach_id
  WHERE is_final
UNION ALL
  SELECT
    'takeout-' || reach_id id,
    reach_id,
    river,
    section,
    huc4,
    takeout_distance distance,
    takeout_geom geom,
    'take-out' AS type,
    review,
    review_reason
  FROM reach_segments
  JOIN snapped_putins USING (reach_id)
  JOIN reaches ON id = reach_id
  WHERE is_final;