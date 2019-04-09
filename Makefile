PATH := node_modules/.bin:$(PATH)
include init.mk

default: db/all

# these targets don't produce files; always run them
.PHONY: DATABASE_URL db db/postgis db/all db/nhdfcode db/nhdarea_% \
				db/nhdflowline_% db/nhdplusflowlinevaa_% db/nhdwaterbody_% db/wbdhu4 \
				db/reaches_% db/snapped_putins_% db/snapped_takeouts_%

DATABASE_URL:
	@test "${$@}" || (echo "$@ is undefined" && false)

db: DATABASE_URL
	@psql -c "SELECT 1" > /dev/null 2>&1 || \
	(createdb && psql -c "CREATE SCHEMA nhd" && psql -c "ALTER DATABASE ${PGDATABASE} SET search_path TO public,nhd")

db/postgis: db
	$(call create_extension)

db/all: db/wbdhu4

# NHD water body polygons (rivers)
db/nhdarea_04: data/NHDPlusGL/NHDPlus04/NHDSnapshot/Hydrography/NHDArea.shp db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-nln $(relation) \
		-nlt CONVERT_TO_LINEAR \
		-f PGDump \
		-skipfailures \
		-where "fcode NOT IN (31800, 33600, 33601, 33603, 34300, 34305, 34306, 36400, 40300, 40307, 40308, 40309, 44500, 46003, 46007, 46100, 48400, 48500, 56800)" \
		/vsistdout/ \
		$< | pv | psql -v ON_ERROR_STOP=1 -qX

# 0415 is special; it partially exists in NHDPlus HR
db/nhdarea_0415 \
db/nhdarea_0401 \
db/nhdarea_0402 \
db/nhdarea_0403 \
db/nhdarea_0404 \
db/nhdarea_0405 \
db/nhdarea_0406 \
db/nhdarea_0407 \
db/nhdarea_0408 \
db/nhdarea_0409 \
db/nhdarea_0410 \
db/nhdarea_0411 \
db/nhdarea_0412 \
db/nhdarea_0413 \
db/nhdarea_0414 \
db/nhdarea_0416 \
db/nhdarea_0417 \
db/nhdarea_0418 \
db/nhdarea_0419 \
db/nhdarea_0420 \
db/nhdarea_0422 \
db/nhdarea_0426: sql/nhdarea_hu4.sql db/nhdarea_04
	$(eval relation := $(notdir $@))
	$(eval hu4 := $(subst nhdarea_,,$(notdir $@)))
	$(eval hu2 := $(shell cut -c 1-2 <<< $(hu4)))
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
	  HU4=$(hu4) HU2=$(hu2) envsubst < $< | \
	  psql -v ON_ERROR_STOP=1 -qX1

db/nhdarea_18: data/NHDPlusCA/NHDPlus18/NHDSnapshot/Hydrography/NHDArea.shp db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-nln $(relation) \
		-nlt CONVERT_TO_LINEAR \
		-f PGDump \
		-skipfailures \
		-where "fcode NOT IN (31800, 33600, 33601, 33603, 34300, 34305, 34306, 36400, 40300, 40307, 40308, 40309, 44500, 46003, 46007, 46100, 48400, 48500, 56800)" \
		/vsistdout/ \
		$< | pv | psql -v ON_ERROR_STOP=1 -qX

db/nhdarea_1802 \
db/nhdarea_1803 \
db/nhdarea_1804 \
db/nhdarea_1805: sql/nhdarea_hu4.sql db/nhdarea_18
	$(eval relation := $(notdir $@))
	$(eval hu4 := $(subst nhdarea_,,$(notdir $@)))
	$(eval hu2 := $(shell cut -c 1-2 <<< $(hu4)))
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
	  HU4=$(hu4) HU2=$(hu2) envsubst < $< | \
	  psql -v ON_ERROR_STOP=1 -qX1

db/nhdarea_20: data/NHDPlusHI/NHDPlus20/NHDSnapshot/Hydrography/NHDArea.shp db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-nln $(relation) \
		-nlt CONVERT_TO_LINEAR \
		-f PGDump \
		-skipfailures \
		-where "fcode NOT IN (31800, 33600, 33601, 33603, 34300, 34305, 34306, 36400, 40300, 40307, 40308, 40309, 44500, 46003, 46007, 46100, 48400, 48500, 56800)" \
		/vsistdout/ \
		$< | pv | psql -v ON_ERROR_STOP=1 -qX

db/nhdarea_2001 \
db/nhdarea_2002 \
db/nhdarea_2007: sql/nhdarea_hu4.sql db/nhdarea_20
	$(eval relation := $(notdir $@))
	$(eval hu4 := $(subst nhdarea_,,$(notdir $@)))
	$(eval hu2 := $(shell cut -c 1-2 <<< $(hu4)))
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
	  HU4=$(hu4) HU2=$(hu2) envsubst < $< | \
	  psql -v ON_ERROR_STOP=1 -qX1

db/nhdarea_21: data/NHDPlusCI/NHDPlus21/NHDSnapshot/Hydrography/NHDArea.shp db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-nln $(relation) \
		-nlt CONVERT_TO_LINEAR \
		-f PGDump \
		-skipfailures \
		-where "fcode NOT IN (31800, 33600, 33601, 33603, 34300, 34305, 34306, 36400, 40300, 40307, 40308, 40309, 44500, 46003, 46007, 46100, 48400, 48500, 56800)" \
		/vsistdout/ \
		$< | pv | psql -v ON_ERROR_STOP=1 -qX

db/nhdarea_2101: sql/nhdarea_hu4.sql db/nhdarea_21
	$(eval relation := $(notdir $@))
	$(eval hu4 := $(subst nhdarea_,,$(notdir $@)))
	$(eval hu2 := $(shell cut -c 1-2 <<< $(hu4)))
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
	  HU4=$(hu4) HU2=$(hu2) envsubst < $< | \
	  psql -v ON_ERROR_STOP=1 -qX1

db/nhdarea_%: data/NHDPLUS_H_%_HU4_GDB.zip db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
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
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-f PGDump \
		/vsistdout/ \
		$< \
		$(relation) | pv | psql -v ON_ERROR_STOP=1 -qX

# NHD flow network
db/nhdflowline_04: data/NHDPlusGL/NHDPlus04/NHDSnapshot/Hydrography/NHDFlowline.shp db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-nln $(relation) \
		-nlt CONVERT_TO_LINEAR \
		-f PGDump \
		-skipfailures \
		-where "fcode NOT IN (33600, 33601, 33603, 42000, 42001, 42002, 42003, 42800, 42801, 42802, 42803, 42804, 42805, 42806, 42807, 42808, 42809, 42810, 42811, 42812, 42813, 42814, 42815, 42816, 46003, 46007)" \
		/vsistdout/ \
		$< | pv | psql -v ON_ERROR_STOP=1 -qX

# 0415 is special; it partially exists in NHDPlus HR
db/nhdflowline_0415 \
db/nhdflowline_0401 \
db/nhdflowline_0402 \
db/nhdflowline_0403 \
db/nhdflowline_0404 \
db/nhdflowline_0405 \
db/nhdflowline_0406 \
db/nhdflowline_0407 \
db/nhdflowline_0408 \
db/nhdflowline_0409 \
db/nhdflowline_0410 \
db/nhdflowline_0411 \
db/nhdflowline_0412 \
db/nhdflowline_0413 \
db/nhdflowline_0414 \
db/nhdflowline_0416 \
db/nhdflowline_0417 \
db/nhdflowline_0418 \
db/nhdflowline_0419 \
db/nhdflowline_0420 \
db/nhdflowline_0422 \
db/nhdflowline_0426: sql/nhdflowline_hu4.sql db/nhdflowline_04
	$(eval relation := $(notdir $@))
	$(eval hu4 := $(subst nhdflowline_,,$(notdir $@)))
	$(eval hu2 := $(shell cut -c 1-2 <<< $(hu4)))
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
	  HU4=$(hu4) HU2=$(hu2) envsubst < $< | \
	  psql -v ON_ERROR_STOP=1 -qX1

db/nhdflowline_18: data/NHDPlusCA/NHDPlus18/NHDSnapshot/Hydrography/NHDFlowline.shp db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-nln $(relation) \
		-nlt CONVERT_TO_LINEAR \
		-f PGDump \
		/vsistdout/ \
		-skipfailures \
		-where "fcode NOT IN (33600, 33601, 33603, 42000, 42001, 42002, 42003, 42800, 42801, 42802, 42803, 42804, 42805, 42806, 42807, 42808, 42809, 42810, 42811, 42812, 42813, 42814, 42815, 42816, 46003, 46007)" \
		$< | pv | psql -v ON_ERROR_STOP=1 -qX

db/nhdflowline_1802 \
db/nhdflowline_1803 \
db/nhdflowline_1804 \
db/nhdflowline_1805: sql/nhdflowline_hu4.sql db/nhdflowline_18
	$(eval relation := $(notdir $@))
	$(eval hu4 := $(subst nhdflowline_,,$(notdir $@)))
	$(eval hu2 := $(shell cut -c 1-2 <<< $(hu4)))
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
	  HU4=$(hu4) HU2=$(hu2) envsubst < $< | \
	  psql -v ON_ERROR_STOP=1 -qX1

db/nhdflowline_20: data/NHDPlusHI/NHDPlus20/NHDSnapshot/Hydrography/NHDFlowline.shp db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-nln $(relation) \
		-nlt CONVERT_TO_LINEAR \
		-f PGDump \
		-skipfailures \
		-where "fcode NOT IN (33600, 33601, 33603, 42000, 42001, 42002, 42003, 42800, 42801, 42802, 42803, 42804, 42805, 42806, 42807, 42808, 42809, 42810, 42811, 42812, 42813, 42814, 42815, 42816, 46003, 46007)" \
		/vsistdout/ \
		$< | pv | psql -v ON_ERROR_STOP=1 -qX

db/nhdflowline_2001 \
db/nhdflowline_2002 \
db/nhdflowline_2007: sql/nhdflowline_hu4.sql db/nhdflowline_20
	$(eval relation := $(notdir $@))
	$(eval hu4 := $(subst nhdflowline_,,$(notdir $@)))
	$(eval hu2 := $(shell cut -c 1-2 <<< $(hu4)))
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
	  HU4=$(hu4) HU2=$(hu2) envsubst < $< | \
	  psql -v ON_ERROR_STOP=1 -qX1

db/nhdflowline_21: data/NHDPlusCI/NHDPlus21/NHDSnapshot/Hydrography/NHDFlowline.shp db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-nln $(relation) \
		-nlt CONVERT_TO_LINEAR \
		-f PGDump \
		-skipfailures \
		-where "fcode NOT IN (33600, 33601, 33603, 42000, 42001, 42002, 42003, 42800, 42801, 42802, 42803, 42804, 42805, 42806, 42807, 42808, 42809, 42810, 42811, 42812, 42813, 42814, 42815, 42816, 46003, 46007)" \
		/vsistdout/ \
		$< | pv | psql -v ON_ERROR_STOP=1 -qX

db/nhdflowline_2101: sql/nhdflowline_hu4.sql db/nhdflowline_21
	$(eval relation := $(notdir $@))
	$(eval hu4 := $(subst nhdflowline_,,$(notdir $@)))
	$(eval hu2 := $(shell cut -c 1-2 <<< $(hu4)))
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
	  HU4=$(hu4) HU2=$(hu2) envsubst < $< | \
	  psql -v ON_ERROR_STOP=1 -qX1

db/nhdflowline_%: data/NHDPLUS_H_%_HU4_GDB.zip db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-nln $(relation) \
		-nlt CONVERT_TO_LINEAR \
		-f PGDump \
		/vsistdout/ \
		-skipfailures \
		-where "fcode NOT IN (33600, 33601, 33603, 42000, 42001, 42002, 42003, 42800, 42801, 42802, 42803, 42804, 42805, 42806, 42807, 42808, 42809, 42810, 42811, 42812, 42813, 42814, 42815, 42816, 46007)" \
		$< \
		nhdflowline | pv | psql -v ON_ERROR_STOP=1 -qX

# NHDPlus Value Added Attributes (for navigating the flow network, etc.)
db/nhdplusflowlinevaa_04: data/NHDPlusGL/NHDPlus04/NHDPlusAttributes/PlusFlowlineVAA.dbf db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-nln $(relation) \
		-lco PRECISION=NO \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-f PGDump \
		/vsistdout/ \
		$< \
		plusflowlinevaa | pv | psql -v ON_ERROR_STOP=1 -qX

# 0415 is special; it partially exists in NHDPlus HR
db/nhdplusflowlinevaa_0415 \
db/nhdplusflowlinevaa_0401 \
db/nhdplusflowlinevaa_0402 \
db/nhdplusflowlinevaa_0403 \
db/nhdplusflowlinevaa_0404 \
db/nhdplusflowlinevaa_0405 \
db/nhdplusflowlinevaa_0406 \
db/nhdplusflowlinevaa_0407 \
db/nhdplusflowlinevaa_0408 \
db/nhdplusflowlinevaa_0409 \
db/nhdplusflowlinevaa_0410 \
db/nhdplusflowlinevaa_0411 \
db/nhdplusflowlinevaa_0412 \
db/nhdplusflowlinevaa_0413 \
db/nhdplusflowlinevaa_0414 \
db/nhdplusflowlinevaa_0416 \
db/nhdplusflowlinevaa_0417 \
db/nhdplusflowlinevaa_0418 \
db/nhdplusflowlinevaa_0419 \
db/nhdplusflowlinevaa_0420 \
db/nhdplusflowlinevaa_0422 \
db/nhdplusflowlinevaa_0426: sql/nhdplusflowlinevaa_hu4.sql db/nhdplusflowlinevaa_04
	$(eval relation := $(notdir $@))
	$(eval hu4 := $(subst nhdplusflowlinevaa_,,$(notdir $@)))
	$(eval hu2 := $(shell cut -c 1-2 <<< $(hu4)))
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
	  HU4=$(hu4) HU2=$(hu2) envsubst < $< | \
	  psql -v ON_ERROR_STOP=1 -qX1

db/nhdplusflowlinevaa_18: data/NHDPlusCA/NHDPlus18/NHDPlusAttributes/PlusFlowlineVAA.dbf db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-nln $(relation) \
		-lco PRECISION=NO \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-f PGDump \
		/vsistdout/ \
		$< \
		plusflowlinevaa | pv | psql -v ON_ERROR_STOP=1 -qX

db/nhdplusflowlinevaa_1802 \
db/nhdplusflowlinevaa_1803 \
db/nhdplusflowlinevaa_1804 \
db/nhdplusflowlinevaa_1805: sql/nhdplusflowlinevaa_hu4.sql db/nhdplusflowlinevaa_18
	$(eval relation := $(notdir $@))
	$(eval hu4 := $(subst nhdplusflowlinevaa_,,$(notdir $@)))
	$(eval hu2 := $(shell cut -c 1-2 <<< $(hu4)))
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
	  HU4=$(hu4) HU2=$(hu2) envsubst < $< | \
	  psql -v ON_ERROR_STOP=1 -qX1

db/nhdplusflowlinevaa_20: data/NHDPlusHI/NHDPlus20/NHDPlusAttributes/PlusFlowlineVAA.dbf db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-nln $(relation) \
		-lco PRECISION=NO \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-f PGDump \
		/vsistdout/ \
		$< \
		plusflowlinevaa | pv | psql -v ON_ERROR_STOP=1 -qX

db/nhdplusflowlinevaa_2001 \
db/nhdplusflowlinevaa_2002 \
db/nhdplusflowlinevaa_2007: sql/nhdplusflowlinevaa_hu4.sql db/nhdplusflowlinevaa_20
	$(eval relation := $(notdir $@))
	$(eval hu4 := $(subst nhdplusflowlinevaa_,,$(notdir $@)))
	$(eval hu2 := $(shell cut -c 1-2 <<< $(hu4)))
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
	  HU4=$(hu4) HU2=$(hu2) envsubst < $< | \
	  psql -v ON_ERROR_STOP=1 -qX1

db/nhdplusflowlinevaa_21: data/NHDPlusCI/NHDPlus21/NHDPlusAttributes/PlusFlowlineVAA.dbf db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-nln $(relation) \
		-lco PRECISION=NO \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-f PGDump \
		/vsistdout/ \
		$< \
		plusflowlinevaa | pv | psql -v ON_ERROR_STOP=1 -qX

db/nhdplusflowlinevaa_2101: sql/nhdplusflowlinevaa_hu4.sql db/nhdplusflowlinevaa_21
	$(eval relation := $(notdir $@))
	$(eval hu4 := $(subst nhdplusflowlinevaa_,,$(notdir $@)))
	$(eval hu2 := $(shell cut -c 1-2 <<< $(hu4)))
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
	  HU4=$(hu4) HU2=$(hu2) envsubst < $< | \
	  psql -v ON_ERROR_STOP=1 -qX1

db/nhdplusflowlinevaa_%: data/NHDPLUS_H_%_HU4_GDB.zip db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-nln $(relation) \
		-f PGDump \
		/vsistdout/ \
		$< \
		nhdplusflowlinevaa | pv | psql -v ON_ERROR_STOP=1 -qX

# NHD water body polygons (lakes, etc.)
db/nhdwaterbody_04: data/NHDPlusGL/NHDPlus04/NHDSnapshot/Hydrography/NHDWaterbody.shp db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-nln $(relation) \
		-nlt CONVERT_TO_LINEAR \
		-f PGDump \
		-skipfailures \
		-where "fcode NOT IN (36100, 37800, 39001, 39005, 39006, 39011, 39012, 43601, 43603, 43604, 43605, 43606, 43608, 43609, 43610, 43611, 43612, 43624, 43625, 43626, 46600, 46601, 46602, 49300)" \
		/vsistdout/ \
		$< | pv | psql -v ON_ERROR_STOP=1 -qX

# 0415 is special; it partially exists in NHDPlus HR
db/nhdwaterbody_0415 \
db/nhdwaterbody_0401 \
db/nhdwaterbody_0402 \
db/nhdwaterbody_0403 \
db/nhdwaterbody_0404 \
db/nhdwaterbody_0405 \
db/nhdwaterbody_0406 \
db/nhdwaterbody_0407 \
db/nhdwaterbody_0408 \
db/nhdwaterbody_0409 \
db/nhdwaterbody_0410 \
db/nhdwaterbody_0411 \
db/nhdwaterbody_0412 \
db/nhdwaterbody_0413 \
db/nhdwaterbody_0414 \
db/nhdwaterbody_0416 \
db/nhdwaterbody_0417 \
db/nhdwaterbody_0418 \
db/nhdwaterbody_0419 \
db/nhdwaterbody_0420 \
db/nhdwaterbody_0422 \
db/nhdwaterbody_0426: sql/nhdwaterbody_hu4.sql db/nhdwaterbody_04
	$(eval relation := $(notdir $@))
	$(eval hu4 := $(subst nhdwaterbody_,,$(notdir $@)))
	$(eval hu2 := $(shell cut -c 1-2 <<< $(hu4)))
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
	  HU4=$(hu4) HU2=$(hu2) envsubst < $< | \
	  psql -v ON_ERROR_STOP=1 -qX1

db/nhdwaterbody_18: data/NHDPlusCA/NHDPlus18/NHDSnapshot/Hydrography/NHDWaterbody.shp db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-nln $(relation) \
		-nlt CONVERT_TO_LINEAR \
		-f PGDump \
		/vsistdout/ \
		-skipfailures \
		-where "fcode NOT IN (36100, 37800, 39001, 39005, 39006, 39011, 39012, 43601, 43603, 43604, 43605, 43606, 43608, 43609, 43610, 43611, 43612, 43624, 43625, 43626, 46600, 46601, 46602, 49300)" \
		$< | pv | psql -v ON_ERROR_STOP=1 -qX

db/nhdwaterbody_1802 \
db/nhdwaterbody_1803 \
db/nhdwaterbody_1804 \
db/nhdwaterbody_1805: sql/nhdwaterbody_hu4.sql db/nhdwaterbody_18
	$(eval relation := $(notdir $@))
	$(eval hu4 := $(subst nhdwaterbody_,,$(notdir $@)))
	$(eval hu2 := $(shell cut -c 1-2 <<< $(hu4)))
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
	  HU4=$(hu4) HU2=$(hu2) envsubst < $< | \
	  psql -v ON_ERROR_STOP=1 -qX1

db/nhdwaterbody_20: data/NHDPlusHI/NHDPlus20/NHDSnapshot/Hydrography/NHDWaterbody.shp db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-nln $(relation) \
		-nlt PROMOTE_TO_MULTI \
		-f PGDump \
		-skipfailures \
		-where "fcode NOT IN (36100, 37800, 39001, 39005, 39006, 39011, 39012, 43601, 43603, 43604, 43605, 43606, 43608, 43609, 43610, 43611, 43612, 43624, 43625, 43626, 46600, 46601, 46602, 49300)" \
		/vsistdout/ \
		$< | pv | psql -v ON_ERROR_STOP=1 -qX

db/nhdwaterbody_2001 \
db/nhdwaterbody_2002 \
db/nhdwaterbody_2007: sql/nhdwaterbody_hu4.sql db/nhdwaterbody_20
	$(eval relation := $(notdir $@))
	$(eval hu4 := $(subst nhdwaterbody_,,$(notdir $@)))
	$(eval hu2 := $(shell cut -c 1-2 <<< $(hu4)))
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
	  HU4=$(hu4) HU2=$(hu2) envsubst < $< | \
	  psql -v ON_ERROR_STOP=1 -qX1

db/nhdwaterbody_21: data/NHDPlusCI/NHDPlus21/NHDSnapshot/Hydrography/NHDWaterbody.shp db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-nln $(relation) \
		-f PGDump \
		-skipfailures \
		-where "fcode NOT IN (36100, 37800, 39001, 39005, 39006, 39011, 39012, 43601, 43603, 43604, 43605, 43606, 43608, 43609, 43610, 43611, 43612, 43624, 43625, 43626, 46600, 46601, 46602, 49300)" \
		/vsistdout/ \
		$< | pv | psql -v ON_ERROR_STOP=1 -qX

db/nhdwaterbody_2101: sql/nhdwaterbody_hu4.sql db/nhdwaterbody_21
	$(eval relation := $(notdir $@))
	$(eval hu4 := $(subst nhdwaterbody_,,$(notdir $@)))
	$(eval hu2 := $(shell cut -c 1-2 <<< $(hu4)))
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
	  HU4=$(hu4) HU2=$(hu2) envsubst < $< | \
	  psql -v ON_ERROR_STOP=1 -qX1

db/nhdwaterbody_%: data/NHDPLUS_H_%_HU4_GDB.zip db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
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
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-f PGDump \
		/vsistdout/ \
		$< \
		$(relation) 2> /dev/null | pv | psql -v ON_ERROR_STOP=1 -qX

# watershed boundaries for 8-digit hydrologic units in Alaska
db/wbdhu8: data/WBD_National_GDB.zip db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)" > /dev/null 2>&1 || \
	ogr2ogr \
		--config PG_USE_COPY YES \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-where "huc8 LIKE '1902%'" \
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

db/ak/reaches.%: sql/reaches_hu8.sql db/wbdhu8
	$(eval hu8 := $*)
	$(eval relation := $(notdir $(basename $@)))
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu8)" > /dev/null 2>&1 || \
	  HU8=$(hu8) envsubst < $< | \
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

db/ak/snapped_putins.%: sql/actions/snap_putins.sql \
												db/flowline db/snapped_putins db/nhdarea_% \
												db/nhdflowline_% db/nhdplusflowlinevaa_% \
												db/nhdwaterbody_% db/ak/reaches.% \
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

db/ak/snapped_takeouts.%: sql/actions/snap_takeouts.sql \
													db/flowline db/snapped_takeouts db/nhdarea_% \
													db/nhdflowline_% db/nhdplusflowlinevaa_% \
													db/nhdwaterbody_% db/ak/reaches.% db/ak/snapped_putins.% \
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

db/ak/reach_segments.%: sql/actions/generate_segments.sql db/segment db/reach_segments \
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

db/access: db/snapped_putins db/snapped_takeouts
	$(call create_relation)

db/descriptive_reach_segments: db/reach_segments
	$(call create_relation)

db/flowline: db/postgis
	$(call create_relation)

exports/access.geojson: db/access
	mkdir -p $$(dirname $@)
	ogr2ogr $@ \
		-mapFieldType DateTime=String \
		"PG:${DATABASE_URL}" \
		-lco RFC7946=YES \
		-where "geom IS NOT NULL" \
		$(notdir $<)

exports/access.%.geojson: db/access
	$(eval hu4 := $*)
	mkdir -p $$(dirname $@)
	ogr2ogr $@ \
		-mapFieldType DateTime=String \
		"PG:${DATABASE_URL}" \
		-lco RFC7946=YES \
		-where "huc4 = '$(hu4)' AND geom IS NOT NULL" \
		$(notdir $<)

exports/gages.geojson:
	mkdir -p $$(dirname $@)
	ogr2ogr $@ \
		-mapFieldType DateTime=String,Time=String \
		"PG:${DATABASE_URL}" \
		-lco RFC7946=YES \
		-select "source, id, name, update_frequency" \
		gages

exports/rapids.geojson:
	mkdir -p $$(dirname $@)
	ogr2ogr $@ \
		-mapFieldType DateTime=String \
		"PG:${DATABASE_URL}" \
		-lco RFC7946=YES \
		-where "is_final = true" \
		rapids

exports/reach_segments.geojson: db/descriptive_reach_segments
	mkdir -p $$(dirname $@)
	ogr2ogr $@ \
		-mapFieldType DateTime=String \
		"PG:${DATABASE_URL}" \
		-lco RFC7946=YES \
		$(notdir $<)

exports/reach_segments.mbtiles: exports/reach_segments.geojson
	tippecanoe \
		-o $@ \
		--use-attribute-for-id reach_id \
		-l reach_segments \
		-n "Generated reach segments" \
		-Z 5 \
		-z 13 \
		$<

exports/reach_segments.%.geojson: db/descriptive_reach_segments
	$(eval hu4 := $*)
	mkdir -p $$(dirname $@)
	ogr2ogr $@ \
		-mapFieldType DateTime=String \
		"PG:${DATABASE_URL}" \
		-lco RFC7946=YES \
		-where "huc4 = '$(hu4)'" \
		$(notdir $<)

# process a specific 8-digit hydrologic unit (for Alaska)
wbd/ak/%: db/ak/snapped_putins.% db/ak/snapped_takeouts.%
	$(eval hu8 := $*)
	@$(MAKE) db/correct_putins
	@$(MAKE) db/ak/reach_segments.$(hu8)
	@echo "Reaches for hydrologic unit $(hu8) processed."
	@mkdir -p $$(dirname $@)
	@touch $@

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
.PRECIOUS: data/NHDPLUS_H_19020401_HU4_GDB.zip

# TODO filename is wrong
data/NHDPLUS_H_19020401_HU4_GDB.zip:
	$(call download,https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/NHDPlus/HU8/HighResolution/GDB/NHDPLUS_H_19020401_HU8_GDB.zip)

.PRECIOUS: data/NHDPLUS_H_19020402_HU4_GDB.zip

# TODO filename is wrong
data/NHDPLUS_H_19020402_HU4_GDB.zip:
	$(call download,https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/NHDPlus/HU8/HighResolution/GDB/NHDPLUS_H_19020402_HU8_GDB.zip)

.PRECIOUS: data/NHDPLUS_H_19020501_HU4_GDB.zip

# TODO filename is wrong
data/NHDPLUS_H_19020501_HU4_GDB.zip:
	$(call download,https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/NHDPlus/HU8/HighResolution/GDB/NHDPLUS_H_19020501_HU8_GDB.zip)

.PRECIOUS: data/NHDPLUS_H_19020502_HU4_GDB.zip

# TODO filename is wrong
data/NHDPLUS_H_19020502_HU4_GDB.zip:
	$(call download,https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/NHDPlus/HU8/HighResolution/GDB/NHDPLUS_H_19020502_HU8_GDB.zip)

.PRECIOUS: data/NHDPLUS_H_19020503_HU4_GDB.zip

# TODO filename is wrong
data/NHDPLUS_H_19020503_HU4_GDB.zip:
	$(call download,https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/NHDPlus/HU8/HighResolution/GDB/NHDPLUS_H_19020503_HU8_GDB.zip)

.PRECIOUS: data/NHDPLUS_H_19020504_HU4_GDB.zip

# TODO filename is wrong
data/NHDPLUS_H_19020504_HU4_GDB.zip:
	$(call download,https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/NHDPlus/HU8/HighResolution/GDB/NHDPLUS_H_19020504_HU8_GDB.zip)

.PRECIOUS: data/NHDPLUS_H_19020505_HU4_GDB.zip

# TODO filename is wrong
data/NHDPLUS_H_19020505_HU4_GDB.zip:
	$(call download,https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/NHDPlus/HU8/HighResolution/GDB/NHDPLUS_H_19020505_HU8_GDB.zip)

.PRECIOUS: data/NHDPLUS_H_%_HU4_GDB.zip

data/NHDPLUS_H_%_HU4_GDB.zip:
	$(call download,https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/NHDPlus/HU4/HighResolution/GDB/$(notdir $@))

.PRECIOUS: data/WBD_National_GDB.zip

data/WBD_National_GDB.zip:
	$(call download,https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/WBD/National/GDB/WBD_National_GDB.zip)

.PRECIOUS: data/NHDPlusV21_GL_04_NHDPlusAttributes_14.7z

data/NHDPlusV21_GL_04_NHDPlusAttributes_14.7z:
	$(call download,http://www.horizon-systems.com/NHDPlusData/NHDPlusV21/Data/NHDPlusGL/NHDPlusV21_GL_04_NHDPlusAttributes_14.7z)

.PRECIOUS: data/NHDPlusV21_CA_18_NHDPlusAttributes_08.7z

data/NHDPlusV21_CA_18_NHDPlusAttributes_08.7z:
	$(call download,http://www.horizon-systems.com/NHDPlusData/NHDPlusV21/Data/NHDPlusCA/NHDPlusV21_CA_18_NHDPlusAttributes_08.7z)

.PRECIOUS: data/NHDPlusV21_HI_20_NHDPlusAttributes_02.7z

data/NHDPlusV21_HI_20_NHDPlusAttributes_02.7z:
	$(call download,http://www.horizon-systems.com/NHDPlusData/NHDPlusV21/Data/NHDPlusHI/NHDPlusV21_HI_20_NHDPlusAttributes_02.7z)

.PRECIOUS: data/NHDPlusV21_CI_21_NHDPlusAttributes_02.7z

data/NHDPlusV21_CI_21_NHDPlusAttributes_02.7z:
	$(call download,http://www.horizon-systems.com/NHDPlusData/NHDPlusV21/Data/NHDPlusCI/NHDPlusV21_CI_21_NHDPlusAttributes_02.7z)

.PRECIOUS: data/NHDPlusV21_GL_04_NHDSnapshot_08.7z

data/NHDPlusV21_GL_04_NHDSnapshot_08.7z:
	$(call download,http://www.horizon-systems.com/NHDPlusData/NHDPlusV21/Data/NHDPlusGL/NHDPlusV21_GL_04_NHDSnapshot_08.7z)

.PRECIOUS: data/NHDPlusV21_CA_18_NHDSnapshot_05.7z

data/NHDPlusV21_CA_18_NHDSnapshot_05.7z:
	$(call download,http://www.horizon-systems.com/NHDPlusData/NHDPlusV21/Data/NHDPlusCA/NHDPlusV21_CA_18_NHDSnapshot_05.7z)

.PRECIOUS: data/NHDPlusV21_HI_20_NHDSnapshot_02.7z

data/NHDPlusV21_HI_20_NHDSnapshot_02.7z:
	$(call download,http://www.horizon-systems.com/NHDPlusData/NHDPlusV21/Data/NHDPlusHI/NHDPlusV21_HI_20_NHDSnapshot_02.7z)

.PRECIOUS: data/NHDPlusV21_CI_21_NHDSnapshot_02.7z

data/NHDPlusV21_CI_21_NHDSnapshot_02.7z:
	$(call download,http://www.horizon-systems.com/NHDPlusData/NHDPlusV21/Data/NHDPlusCI/NHDPlusV21_CI_21_NHDSnapshot_02.7z)

data/NHDPlusGL/NHDPlus04/NHDPlusAttributes/PlusFlowlineVAA.dbf: data/NHDPlusV21_GL_04_NHDPlusAttributes_14.7z
	7z x -odata/ -y $<
	@touch $@

data/NHDPlusCA/NHDPlus18/NHDPlusAttributes/PlusFlowlineVAA.dbf: data/NHDPlusV21_CA_18_NHDPlusAttributes_08.7z
	7z x -odata/ -y $<
	@touch $@

data/NHDPlusHI/NHDPlus20/NHDPlusAttributes/PlusFlowlineVAA.dbf: data/NHDPlusV21_HI_20_NHDPlusAttributes_02.7z
	7z x -odata/ -y $<
	@touch $@

data/NHDPlusCI/NHDPlus21/NHDPlusAttributes/PlusFlowlineVAA.dbf: data/NHDPlusV21_CI_21_NHDPlusAttributes_02.7z
	7z x -odata/ -y $<
	@touch $@

data/NHDPlusGL/NHDPlus04/NHDSnapshot/Hydrography/NHDArea.shp \
data/NHDPlusGL/NHDPlus04/NHDSnapshot/Hydrography/NHDFlowline.shp \
data/NHDPlusGL/NHDPlus04/NHDSnapshot/Hydrography/NHDWaterbody.shp: data/NHDPlusV21_GL_04_NHDSnapshot_08.7z
	7z x -odata/ -y $<
	find data/NHDPlusGL/NHDPlus04/NHDSnapshot -exec touch {} \;

data/NHDPlusCA/NHDPlus18/NHDSnapshot/Hydrography/NHDArea.shp \
data/NHDPlusCA/NHDPlus18/NHDSnapshot/Hydrography/NHDFlowline.shp \
data/NHDPlusCA/NHDPlus18/NHDSnapshot/Hydrography/NHDWaterbody.shp: data/NHDPlusV21_CA_18_NHDSnapshot_05.7z
	7z x -odata/ -y $<
	find data/NHDPlusCA/NHDPlus18/NHDSnapshot -exec touch {} \;

data/NHDPlusHI/NHDPlus20/NHDSnapshot/Hydrography/NHDArea.shp \
data/NHDPlusHI/NHDPlus20/NHDSnapshot/Hydrography/NHDFlowline.shp \
data/NHDPlusHI/NHDPlus20/NHDSnapshot/Hydrography/NHDWaterbody.shp: data/NHDPlusV21_HI_20_NHDSnapshot_02.7z
	7z x -odata/ -y $<
	find data/NHDPlusHI/NHDPlus20/NHDSnapshot -exec touch {} \;

data/NHDPlusCI/NHDPlus21/NHDSnapshot/Hydrography/NHDArea.shp \
data/NHDPlusCI/NHDPlus21/NHDSnapshot/Hydrography/NHDFlowline.shp \
data/NHDPlusCI/NHDPlus21/NHDSnapshot/Hydrography/NHDWaterbody.shp: data/NHDPlusV21_CI_21_NHDSnapshot_02.7z
	7z x -odata/ -y $<
	find data/NHDPlusCI/NHDPlus21/NHDSnapshot -exec touch {} \;