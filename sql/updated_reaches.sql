DROP TABLE IF EXISTS updated_reaches;

CREATE TABLE updated_reaches AS
  SELECT
    reach_id,
    revision,
    geom
  FROM reach_segments;