CREATE VIEW nhd.nhdpolygon AS
    SELECT nhdplusid, geom, fdate, gnis_name, null AS reachcode, fcode, visibilityfilter from nhdarea
  UNION ALL
    SELECT nhdplusid, geom, fdate, gnis_name, reachcode, fcode, visibilityfilter from nhdwaterbody;