CREATE TABLE reach_segments (
  reach_id integer NOT NULL,
  nhdplusids bigint[],
  geom geometry(LineString, 4326),
  PRIMARY KEY(reach_id)
);

CREATE INDEX reach_segments_geom_gist ON reach_segments
USING gist (geom);