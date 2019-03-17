DROP TYPE IF EXISTS flowline;
CREATE TYPE flowline AS (
  nhdplusid bigint,
  fdate timestamp with time zone,
  wbarea_id text,
  line geometry
);