DROP TYPE IF EXISTS segment;

CREATE TYPE segment AS (
  nhdplusids bigint[],
  -- geom geometry(LineString, 4326)
  geom geometry
);