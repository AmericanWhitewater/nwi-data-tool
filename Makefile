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
	$(eval relation := $(basename $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-nln $(relation) \
		-nlt CONVERT_TO_LINEAR \
		-f PGDump \
		-skipfailures \
		-where "fcode NOT IN (31800, 33600, 33601, 33603, 34300, 34305, 34306, 36400, 40300, 40307, 40308, 40309, 44500, 46003, 46007, 46100, 48400, 48500, 56800)" \
		/vsistdout/ \
		$< \
		nhdarea | pv | psql -v ON_ERROR_STOP=1 -qX

# NHD Feature Code (FCode) mappings; fetch it from the smallest available
# source
db/nhdfcode: data/NHDPLUS_H_0904_HU4_GDB.zip
	$(eval relation := $(basename $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-f PGDump \
		/vsistdout/ \
		$< \
		$(relation) | pv | psql -v ON_ERROR_STOP=1 -qX

# NHD flow network
db/nhdflowline_%: data/NHDPLUS_H_%_HU4_GDB.zip db/postgis
	$(eval relation := $(basename $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-nln $(relation) \
		-nlt CONVERT_TO_LINEAR \
		-f PGDump \
		/vsistdout/ \
		-skipfailures \
		-where "fcode NOT IN (33600, 33601, 33603, 42000, 42001, 42002, 42003, 42800, 42801, 42802, 42803, 42804, 42805, 42806, 42807, 42808, 42809, 42810, 42811, 42812, 42813, 42814, 42815, 42816, 46003, 46007)" \
		$< \
		nhdflowline | pv | psql -v ON_ERROR_STOP=1 -qX

# NHDPlus Value Added Attributes (for navigating the flow network, etc.)
db/nhdplusflowlinevaa_%: data/NHDPLUS_H_%_HU4_GDB.zip db/postgis
	$(eval relation := $(basename $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-nln $(relation) \
		-f PGDump \
		/vsistdout/ \
		$< \
		nhdplusflowlinevaa | pv | psql -v ON_ERROR_STOP=1 -qX

# NHD water body polygons (lakes, etc.)
db/nhdwaterbody_%: data/NHDPLUS_H_%_HU4_GDB.zip db/postgis
	$(eval relation := $(basename $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-nln $(relation) \
		-nlt CONVERT_TO_LINEAR \
		-f PGDump \
		-skipfailures \
		-where "fcode NOT IN (36100, 37800, 39001, 39005, 39006, 39011, 39012, 43601, 43603, 43604, 43605, 43606, 43608, 43609, 43610, 43611, 43612, 43624, 43625, 43626, 46600, 46601, 46602, 49300)" \
		/vsistdout/ \
		$< \
		nhdwaterbody | pv | psql -v ON_ERROR_STOP=1 -qX

# watershed boundaries for 4-digit hydrologic units
db/wbdhu4: data/WBD_National_GDB.zip db/postgis
	$(eval relation := $(basename $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-f PGDump \
		/vsistdout/ \
		$< \
		$(relation) 2> /dev/null | pv | psql -v ON_ERROR_STOP=1 -qX

# reaches for a particular 4-digit hydrologic unit
db/reaches.%: sql/reaches_hu4.sql db/wbdhu4
	$(eval hu4 := $*)
	$(eval relation := $(notdir $(basename $@)))
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
	  HU4=$(hu4) envsubst < $< | \
	  psql -v ON_ERROR_STOP=1 -qX1

# snapped put-ins for a particular 4-digit hydrologic unit
db/snapped_putins.%: sql/actions/snap_putins.sql \
										 db/flowline db/snapped_putins db/nhdarea_% \
										 db/nhdflowline_% db/nhdplusflowlinevaa_% \
									   db/nhdwaterbody_% db/reaches.% \
										 db/indexes/nhdarea_% db/indexes/nhdwaterbody_%
	$(eval hu4 := $*)
	HU4=$(hu4) envsubst < $< | \
	  psql -v ON_ERROR_STOP=1 -X1

# snapped take-outs for a particular 4-digit hydrologic unit
db/snapped_takeouts.%: sql/actions/snap_takeouts.sql \
											 db/flowline db/snapped_takeouts db/nhdarea_% \
											 db/nhdflowline_% db/nhdplusflowlinevaa_% \
										   db/nhdwaterbody_% db/reaches.% db/snapped_putins.% \
										   db/indexes/nhdarea_% db/indexes/nhdwaterbody_%
	$(eval hu4 := $*)
	HU4=$(hu4) envsubst < $< | \
	  psql -v ON_ERROR_STOP=1 -X1

db/reach_segments.%: sql/actions/generate_segments.sql db/segment db/reach_segments \
										 db/indexes/nhdflowline_% db/indexes/nhdplusflowlinevaa_% \
										 db/snapped_putins db/snapped_takeouts
	$(eval hu4 := $*)
	HU4=$(hu4) envsubst < $< | \
	  psql -v ON_ERROR_STOP=1 -X1

db/indexes/nhdarea_permanent_identifier_idx.%: sql/nhdarea_hu4_permanent_identifier_idx.sql db/nhdarea_%
	$(eval relation := $(notdir $(basename $@)))
	$(eval hu4 := $*)
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
		HU4=$(hu4) envsubst < $< | \
		psql -v ON_ERROR_STOP=1 -qX1

db/indexes/nhdarea_%: db/indexes/nhdarea_permanent_identifier_idx.%
	@true

db/indexes/nhdflowline_nhdplusid_idx.%: sql/nhdflowline_hu4_nhdplusid_idx.sql db/nhdflowline_%
	$(eval relation := $(notdir $(basename $@)))
	$(eval hu4 := $*)
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
		HU4=$(hu4) envsubst < $< | \
		psql -v ON_ERROR_STOP=1 -qX1

db/indexes/nhdflowline_%: db/indexes/nhdflowline_nhdplusid_idx.%
	@true

db/indexes/nhdplusflowlinevaa_hydroseq_idx.%: sql/nhdplusflowlinevaa_hu4_hydroseq_idx.sql db/nhdplusflowlinevaa_%
	$(eval relation := $(notdir $(basename $@)))
	$(eval hu4 := $*)
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
		HU4=$(hu4) envsubst < $< | \
		psql -v ON_ERROR_STOP=1 -qX1

db/indexes/nhdplusflowlinevaa_nhdplusid_idx.%: sql/nhdplusflowlinevaa_hu4_nhdplusid_idx.sql db/nhdplusflowlinevaa_%
	$(eval relation := $(notdir $(basename $@)))
	$(eval hu4 := $*)
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
		HU4=$(hu4) envsubst < $< | \
		psql -v ON_ERROR_STOP=1 -qX1

db/indexes/nhdplusflowlinevaa_%: db/indexes/nhdplusflowlinevaa_hydroseq_idx.% db/indexes/nhdplusflowlinevaa_nhdplusid_idx.%
	@true

db/indexes/nhdwaterbody_permanent_identifier_idx.%: sql/nhdwaterbody_hu4_permanent_identifier_idx.sql db/nhdwaterbody_%
	$(eval relation := $(notdir $(basename $@)))
	$(eval hu4 := $*)
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
		HU4=$(hu4) envsubst < $< | \
		psql -v ON_ERROR_STOP=1 -qX1

db/indexes/nhdwaterbody_%: db/indexes/nhdwaterbody_permanent_identifier_idx.%
	@true

db/correct_putins: db/snapped_putins db/snapped_takeouts
	-psql -v ON_ERROR_STOP=1 -X1f sql/actions/correct_putins.sql

db/flowline: db/postgis
	$(call create_relation)

# process a specific 4-digit hydrologic unit
wbd/%: db/snapped_putins.% db/snapped_takeouts.%
	$(eval hu4 := $*)
	@$(MAKE) db/correct_putins
	@$(MAKE) db/reach_segments.$(hu4)
	@echo "Reaches for hydrologic unit $(hu4) processed."
	@mkdir -p $$(dirname $@)
	@touch $@

### Datasets

# don't delete these; they're large enough that re-downloading them is annoying
.PRECIOUS: data/NHDPLUS_H_%_HU4_GDB.zip

data/NHDPLUS_H_%_HU4_GDB.zip:
	$(call download,https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/NHDPlus/HU4/HighResolution/GDB/$(notdir $@))

.PRECIOUS: data/WBD_National_GDB.zip

data/WBD_National_GDB.zip:
	$(call download,https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/WBD/National/GDB/WBD_National_GDB.zip)