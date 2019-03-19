# NWI Data Tool

## Setup

### MacOS

1. Install [`direnv`](https://direnv.net/), Node.js, GDAL, gettext (for
`envsubst`), and PostgreSQL with PostGIS:

```bash
$ brew bundle
```

2. Install Node.js dependencies:

```bash
$ npm install
```

3. Enable `direnv` (to set environment variables and to update `PATH`):

```bash
$ direnv allow
```

4. Copy `sample.env` to `.env` (and update it if necessary):

```bash
$ cp sample.env .env
```

## Data Preparation

1. Obtain and load AW `reaches` table
2. Load [Watershed Boundary Dataset
   (WBD)](https://www.usgs.gov/core-science-systems/ngp/national-hydrography/watershed-boundary-dataset)
   4-digit hydrologic units
3. Pick a 4-digit hydrologic unit from [the WBD Subregions Map](https://www.usgs.gov/media/images/watershed-boundary-dataset-subregions-map), e.g. `1709` (the Willamette).
4. Create an HU4 `reaches` table by intersecting WBD with `reaches` to filter
   for access points in that HU4
5. Download and import `nhdflowline` `nhdarea`, `nhdwaterbody`, and
   `nhdplusflowlinevaa` for the selected 4-digit hydrologic unit.
6. Import `nhdfcode` (if not already imported).
7. Create snapped reach put-ins (`snapped_putins`) with `nhdplusid`, `fdate`,
   number of candidate flowlines, point on closest flowline, point on
   associated polygon, original point, and link from original to snapped
   location.
8. Create snapped reach take-outs (`snapped_takeouts`) with `nhdplusid`,
   `fdate`, number of candidate flowlines, point on closest flowline, point
   on associated polygon, original point, and link from original to snapped
   location.
9. Adjust put-in locations for reaches immediately downstream from other
   reaches so that they match the upstream reach's take-out location.
   (Take-outs are snapped to downstream NHD segments using put-in
   information.)

Steps 2-8 can be executed for a given HU4 (e.g. `1709`) using:

```bash
$ make -j $(nproc) wbd/1709
```

Step 9 can be repeated as necessary:

```bash
$ make db/correct_putins
```

### TODO

* Report generation, e.g. # of points that didn't snap per watershed, distance
  breakdowns