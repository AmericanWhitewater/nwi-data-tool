PATH := node_modules/.bin:$(PATH)
include init.mk

default: db/all

# these targets don't produce files; always run them
.PHONY: DATABASE_URL db db/postgis db/all db/nhdfcode db/nhdarea_% \
				db/nhdflowline_% db/nhdplusflowlinevaa_% db/nhdwaterbody_% db/wbdhu4 \
				db/reaches_% db/snapped_putins_% db/snapped_takeouts_% wbd/%

DATABASE_URL:
	@test "${$@}" || (echo "$@ is undefined" && false)

db: DATABASE_URL
	@psql -c "SELECT 1" > /dev/null 2>&1 || \
	createdb

db/postgis: db
	$(call create_extension)

db/all: db/wbdhu4

# NHD water body polygons (rivers)
db/nhdarea_%: data/NHDPLUS_H_%_HU4_GDB.zip db/postgis
	@psql -c "\d $(subst db/,,$@)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-nln $(subst db/,,$@) \
		-f PGDump \
		/vsistdout/ \
		$< \
		nhdarea | pv | psql -v ON_ERROR_STOP=1 -qX

# NHD Feature Code (FCode) mappings; fetch it from the smallest available
# source
db/nhdfcode: data/NHDPLUS_H_0904_HU4_GDB.zip
	@psql -c "\d $(subst db/,,$@)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-f PGDump \
		/vsistdout/ \
		$< \
		nhdfcode | pv | psql -v ON_ERROR_STOP=1 -qX

# NHD flow network
db/nhdflowline_%: data/NHDPLUS_H_%_HU4_GDB.zip db/postgis
	@psql -c "\d $(subst db/,,$@)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-nln $(subst db/,,$@) \
		-f PGDump \
		/vsistdout/ \
		$< \
		nhdflowline | pv | psql -v ON_ERROR_STOP=1 -qX

# NHDPlus Value Added Attributes (for navigating the flow network, etc.)
db/nhdplusflowlinevaa_%: data/NHDPLUS_H_%_HU4_GDB.zip db/postgis
	@psql -c "\d $(subst db/,,$@)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-nln $(subst db/,,$@) \
		-f PGDump \
		/vsistdout/ \
		$< \
		nhdplusflowlinevaa | pv | psql -v ON_ERROR_STOP=1 -qX

# NHD water body polygons (lakes, etc.)
db/nhdwaterbody_%: data/NHDPLUS_H_%_HU4_GDB.zip db/postgis
	@psql -c "\d $(subst db/,,$@)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-nln $(subst db/,,$@) \
		-f PGDump \
		/vsistdout/ \
		$< \
		nhdwaterbody | pv | psql -v ON_ERROR_STOP=1 -qX

# watershed boundaries for 4-digit hydrologic units
db/wbdhu4: data/WBD_National_GDB.zip db/postgis
	@psql -c "\d $(subst db/,,$@)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-f PGDump \
		/vsistdout/ \
		$< \
		$(subst db/,,$@) 2> /dev/null | pv | psql -v ON_ERROR_STOP=1 -qX

# reaches for a particular 4-digit hydrologic unit
db/reaches_%: db/wbdhu4
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(subst db/,,$@)" > /dev/null 2>&1 || \
	  HU4=$(subst db/reaches_,,$@) envsubst < sql/reaches_hu4.sql | \
	  psql -v ON_ERROR_STOP=1 -qX1

# snapped put-ins for a particular 4-digit hydrologic unit
db/snapped_putins_%: db/flowline db/snapped_putins db/nhdarea_% \
										 db/nhdflowline_% db/nhdplusflowlinevaa_% \
									   db/nhdwaterbody_% db/reaches_% \
										 db/indexes/nhdarea_% db/indexes/nhdwaterbody_%
	HU4=$(subst db/snapped_putins_,,$@) envsubst < sql/actions/snap_putins.sql | \
	  psql -v ON_ERROR_STOP=1 -qX1

# snapped take-outs for a particular 4-digit hydrologic unit
db/snapped_takeouts_%: db/flowline db/snapped_takeouts db/nhdarea_% \
											 db/nhdflowline_% db/nhdplusflowlinevaa_% \
										   db/nhdwaterbody_% db/reaches_% db/snapped_putins_% \
										   db/indexes/nhdarea_% db/indexes/nhdwaterbody_%
	HU4=$(subst db/snapped_takeouts_,,$@) envsubst < sql/actions/snap_takeouts.sql | \
	  psql -v ON_ERROR_STOP=1 -qX1

db/indexes/nhdarea_%: db/nhdarea_%
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(subst db/,,$@)_permanent_identifier_idx" > /dev/null 2>&1 || \
		HU4=$(subst db/indexes/nhdarea_,,$@) envsubst < sql/nhdarea_hu4_permanent_identifier_idx.sql | \
		psql -v ON_ERROR_STOP=1 -qX1

db/indexes/nhdwaterbody_%: db/nhdwaterbody_%
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(subst db/,,$@)_permanent_identifier_idx" > /dev/null 2>&1 || \
		HU4=$(subst db/indexes/nhwaterbody_,,$@) envsubst < sql/nhdwaterbody_hu4_permanent_identifier_idx.sql | \
		psql -v ON_ERROR_STOP=1 -qX1

db/correct_putins: db/snapped_putins db/snapped_takeouts
	psql -v ON_ERROR_STOP=1 -X1f sql/actions/correct_putins.sql

# process a specific 4-digit hydrologic unit
wbd/%: db/snapped_putins_% db/snapped_takeouts_%
	@echo "Reaches for hydrologic unit $(subst wbd/,,$@) processed."
	@mkdir -p $$(dirname $@)
	@touch $@

### Datasets

# don't delete these; they're large enough that re-downloading them is annoying
.PRECIOUS: data/NHDPLUS_H_%_HU4_GDB.zip

data/NHDPLUS_H_%_HU4_GDB.zip:
	$(call download,https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/NHDPlus/HU4/HighResolution/GDB/$(subst data/,,$@))

.PRECIOUS: data/WBD_National_GDB.zip

data/WBD_National_GDB.zip:
	$(call download,https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/WBD/National/GDB/WBD_National_GDB.zip)