# NWI Data Tool

## Data Preparation

1. Obtain and load AW `reaches` table
2. Load [Watershed Boundary Dataset
   (WBD)](https://www.usgs.gov/core-science-systems/ngp/national-hydrography/watershed-boundary-dataset)
   4-digit hydrologic units

```bash
$ make db/wbdhu4
```

3. Pick a 4-digit hydrologic unit from [the WBD Subregions Map](https://www.usgs.gov/media/images/watershed-boundary-dataset-subregions-map), e.g. `1709` (the Willamette).
4. Create an HU4 `reaches` table by intersecting WBD with `reaches` to filter
   for access points in that HU4

```sql
CREATE TABLE reaches_1709 AS
  SELECT
    id,
    revision,
    river,
    section,
    altname,
    ploc,
    tloc
  FROM reaches
  JOIN wbdhu4 ON (
    -- WBD is in EPSG 4269; reaches is 4326
    -- put-in is within the watershed
    ST_Contains(geom, ST_Transform(ploc, ST_SRID(geom)))
    -- take-out is within the watershed
    OR ST_Contains(geom, ST_Transform(tloc, ST_SRID(geom))))
  WHERE huc4 = '1709'
    -- current revision
    AND is_final = true;
```

5. Import `nhdflowline` and `nhdplusflowlinevaa` for the selected 4-digit
   hydrologic unit.

```bash
$ make db/nhdflowline_1709 db/nhdplusflowlinevaa_1709
```

6. Import `nhdfcode` (if not already imported).

```bash
$ make db/nhdfcode
```