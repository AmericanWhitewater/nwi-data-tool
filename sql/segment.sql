DROP TYPE IF EXISTS segment;

CREATE TYPE segment AS (
  nhdplusids bigint[],
  geom geometry,
  questionable boolean
);