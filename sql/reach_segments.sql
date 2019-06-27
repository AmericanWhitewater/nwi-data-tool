CREATE TABLE reach_segments (
  reach_id integer NOT NULL,
  revision integer NOT NULL,
  review boolean default false,
  review_reason text,
  geom geometry(Geometry, 4326),
  putin_distance double precision,
  original_putin_geom geometry(Point, 4326),
  putin_flowline_point geometry(Point, 4326),
  putin_geom geometry(Point, 4326),
  takeout_distance double precision,
  original_takeout_geom geometry(Point, 4326),
  takeout_flowline_point geometry(Point, 4326),
  takeout_geom geometry(Point, 4326),
  PRIMARY KEY(reach_id)
);

CREATE INDEX reach_segments_geom_gist ON reach_segments
USING gist (geom);