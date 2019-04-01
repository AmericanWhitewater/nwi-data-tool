DROP TYPE IF EXISTS segment;

CREATE TYPE segment AS (
  nhdplusids bigint[],
  reachcodes text[],
  fdate timestamp with time zone,
  geom geometry,
  questionable boolean
);