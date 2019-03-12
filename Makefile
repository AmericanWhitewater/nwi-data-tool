PATH := node_modules/.bin:$(PATH)
include init.mk

default: db/all

# these targets don't produce files; always run them
.PHONY: DATABASE_URL db db/postgis db/all db/nhdfcode db/nhdflowline_% db/nhdplusflowlinevaa_%

DATABASE_URL:
  @test "${$@}" || (echo "$@ is undefined" && false)

db: DATABASE_URL
  @psql -c "SELECT 1" > /dev/null 2>&1 || \
  createdb

db/postgis: db
  $(call create_extension)

db/all: db/wbdhu4

# NHD Feature Code (FCode) mappings; fetch it from the smallest available
# source
db/nhdfcode: data/NHDPLUS_H_0904_HU4_GDB.zip
  ogr2ogr \
    --config PG_USE_COPY YES \
    -f PGDump \
    /vsistdout/ \
    $< \
    nhdfcode | psql -v ON_ERROR_STOP=1 -qX

# NHD flow network
db/nhdflowline_%: data/NHDPLUS_H_%_HU4_GDB.zip db/postgis
  ogr2ogr \
    --config PG_USE_COPY YES \
    -dim XY \
    -lco GEOMETRY_NAME=geom \
    -lco POSTGIS_VERSION=2.2 \
    -nln $(subst db/,,$@) \
    -f PGDump \
    /vsistdout/ \
    $< \
    nhdflowline | psql -v ON_ERROR_STOP=1 -qX

# NHDPlus Value Added Attributes (for navigating the flow network, etc.)
db/nhdplusflowlinevaa_%: data/NHDPLUS_H_%_HU4_GDB.zip db/postgis
  ogr2ogr \
    --config PG_USE_COPY YES \
    -dim XY \
    -lco GEOMETRY_NAME=geom \
    -lco POSTGIS_VERSION=2.2 \
    -nln $(subst db/,,$@) \
    -f PGDump \
    /vsistdout/ \
    $< \
    nhdplusflowlinevaa | psql -v ON_ERROR_STOP=1 -qX

# watershed boundaries for 4-digit hydrologic units
db/wbdhu4: data/WBD_National_GDB.zip db/postgis
  ogr2ogr \
    --config PG_USE_COPY YES \
    -lco GEOMETRY_NAME=geom \
    -lco POSTGIS_VERSION=2.2 \
    -f PGDump \
    /vsistdout/ \
    $< \
    $(subst db/,,$@) 2> /dev/null | psql -v ON_ERROR_STOP=1 -qX

### Datasets

# don't delete these; they're large enough that re-downloading them is annoying
.PRECIOUS: data/NHDPLUS_H_%_HU4_GDB.zip

data/NHDPLUS_H_%_HU4_GDB.zip:
  $(call download,https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/NHDPlus/HU4/HighResolution/GDB/$(subst data/,,$@))

.PRECIOUS: data/WBD_National_GDB.zip

data/WBD_National_GDB.zip:
  $(call download,https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/WBD/National/GDB/WBD_National_GDB.zip)