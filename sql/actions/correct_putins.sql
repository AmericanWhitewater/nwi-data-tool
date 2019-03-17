-- use snapped take-out points when put-in was snapped to a different segment
-- take-outs are more likely to be correct, as they're probably downstream of
-- another put-in on the same reach
UPDATE snapped_putins p
SET
  nhdplusid = t.nhdplusid,
  fdate = t.fdate,
  candidates = t.candidates,
  distance = t.candidates,
  geom = t.geom,
  flowline_point = t.flowline_point,
  link = t.link
FROM snapped_takeouts t
-- find put-in / take-out points within 25m of one another
WHERE ST_DWithin(p.original_point::geography, t.original_point::geography, 25)
  -- and where the snapped points are NOT within 25m of one another
  AND NOT ST_DWithin(p.geom::geography, t.geom::geography, 25);