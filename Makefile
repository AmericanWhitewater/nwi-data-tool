PATH := node_modules/.bin:$(PATH)
include init.mk

default: db/all

all: nhdplus-v2 nhdplus-hr nhdplus-ak

nhdplus-ak: wbd/ak/19020401 wbd/ak/19020402 wbd/ak/19020501 wbd/ak/19020502 wbd/ak/19020503 wbd/ak/19020504 wbd/ak/19020505

nhdplus-hr: wbd/0101 wbd/0102 wbd/0103 wbd/0104 wbd/0105 wbd/0106 wbd/0107 wbd/0108 wbd/0109 wbd/0110 wbd/0202 wbd/0203 wbd/0204 wbd/0205 wbd/0206 wbd/0207 wbd/0208 wbd/0301 wbd/0302 wbd/0303 wbd/0304 wbd/0305 wbd/0306 wbd/0307 wbd/0310 wbd/0311 wbd/0313 wbd/0315 wbd/0316 wbd/0317 wbd/0415 wbd/0501 wbd/0502 wbd/0503 wbd/0504 wbd/0505 wbd/0506 wbd/0507 wbd/0508 wbd/0509 wbd/0510 wbd/0511 wbd/0512 wbd/0513 wbd/0514 wbd/0601 wbd/0602 wbd/0603 wbd/0604 wbd/0701 wbd/0702 wbd/0703 wbd/0704 wbd/0705 wbd/0706 wbd/0707 wbd/0708 wbd/0709 wbd/0710 wbd/0711 wbd/0712 wbd/0713 wbd/0714 wbd/0902 wbd/0903 wbd/1002 wbd/1003 wbd/1004 wbd/1007 wbd/1008 wbd/1009 wbd/1012 wbd/1015 wbd/1017 wbd/1018 wbd/1019 wbd/1021 wbd/1024 wbd/1027 wbd/1030 wbd/1101 wbd/1102 wbd/1105 wbd/1106 wbd/1107 wbd/1108 wbd/1109 wbd/1111 wbd/1113 wbd/1114 wbd/1201 wbd/1202 wbd/1203 wbd/1205 wbd/1206 wbd/1207 wbd/1209 wbd/1210 wbd/1211 wbd/1301 wbd/1302 wbd/1304 wbd/1306 wbd/1307 wbd/1401 wbd/1402 wbd/1403 wbd/1404 wbd/1405 wbd/1406 wbd/1407 wbd/1408 wbd/1501 wbd/1502 wbd/1503 wbd/1504 wbd/1505 wbd/1506 wbd/1601 wbd/1602 wbd/1603 wbd/1605 wbd/1701 wbd/1702 wbd/1703 wbd/1704 wbd/1705 wbd/1706 wbd/1707 wbd/1708 wbd/1709 wbd/1710 wbd/1711 wbd/1712 wbd/1801 wbd/1806 wbd/1808 wbd/1809

nhdplus-v2: wbd/04 wbd/0802 wbd/0804 wbd/1802 wbd/1803 wbd/1804 wbd/1805 wbd/1807 wbd/2001 wbd/2002 wbd/2007 wbd/2101

# these targets don't produce files; always run them
.PHONY: DATABASE_URL db db/postgis db/all db/nhdfcode db/nhdarea_% \
				db/nhdflowline_% db/nhdplusflowlinevaa_% db/nhdwaterbody_% db/wbdhu2 db/wbdhu4 db/wbdhu8 \
				db/reaches_% db/snapped_putins_% db/snapped_takeouts_%

DATABASE_URL:
	@test "${$@}" || (echo "$@ is undefined" && false)

db: DATABASE_URL
	@psql -c "SELECT 1" > /dev/null 2>&1 || \
	(createdb && psql -c "CREATE SCHEMA nhd" && psql -c "CREATE SCHEMA tmp" && psql -c "ALTER DATABASE ${PGDATABASE} SET search_path TO public,nhd,tmp")

db/postgis: db
	$(call create_extension)

# NHD water body polygons (rivers)

# shadow as nhdarea_04_real (so we can target it as an HU2)
db/nhdarea_04: data/NHDPlusGL/NHDPlus04/NHDSnapshot/Hydrography/NHDArea.shp db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)_real" > /dev/null 2>&1 || \
	(ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-nln $(relation)_real \
		-nlt CONVERT_TO_LINEAR \
		-f PGDump \
		-skipfailures \
		-where "fcode NOT IN (31800, 33600, 33601, 33603, 34300, 34305, 34306, 36400, 40300, 40307, 40308, 40309, 44500, 46003, 46007, 46100, 48400, 48500, 56800)" \
		/vsistdout/ \
		$< | pv | psql -v ON_ERROR_STOP=1 -qX && \
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
	  HU4=04 HU2=04_real envsubst < sql/nhdarea_hu4.sql | \
	  psql -v ON_ERROR_STOP=1 -qX1)

db/nhdarea_08: data/NHDPlusMS/NHDPlus08/NHDSnapshot/Hydrography/NHDArea.shp db/postgis
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

db/nhdarea_0802 \
db/nhdarea_0804: sql/nhdarea_hu4.sql db/nhdarea_08
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
	@psql -c "\d $(relation)_real" > /dev/null 2>&1 || \
	(ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-nln $(relation)_real \
		-nlt CONVERT_TO_LINEAR \
		-f PGDump \
		-skipfailures \
		-where "fcode NOT IN (33600, 33601, 33603, 42000, 42001, 42002, 42003, 42800, 42801, 42802, 42803, 42804, 42805, 42806, 42807, 42808, 42809, 42810, 42811, 42812, 42813, 42814, 42815, 42816, 46003, 46007)" \
		/vsistdout/ \
		$< | pv | psql -v ON_ERROR_STOP=1 -qX && \
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
	  HU4=04 HU2=04_real envsubst < sql/nhdflowline_hu4.sql | \
	  psql -v ON_ERROR_STOP=1 -qX1)

db/nhdflowline_08: data/NHDPlusMS/NHDPlus08/NHDSnapshot/Hydrography/NHDFlowline.shp db/postgis
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
		$< | pv | psql -v ON_ERROR_STOP=1 -qX

db/nhdflowline_0802 \
db/nhdflowline_0804: sql/nhdflowline_hu4.sql db/nhdflowline_08
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
		-where "fcode NOT IN (33600, 33601, 33603, 42000, 42001, 42002, 42003, 42800, 42801, 42802, 42803, 42804, 42805, 42806, 42807, 42808, 42809, 42810, 42811, 42812, 42813, 42814, 42815, 42816, 46007)" \
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
		-where "fcode NOT IN (33601, 33603, 42000, 42001, 42002, 42003, 42800, 42801, 42802, 42803, 42804, 42805, 42806, 42807, 42808, 42809, 42810, 42811, 42812, 42813, 42814, 42815, 42816, 46007)" \
		$< \
		nhdflowline | pv | psql -v ON_ERROR_STOP=1 -qX

# NHDPlus Value Added Attributes (for navigating the flow network, etc.)
db/nhdplusflowlinevaa_04: data/NHDPlusGL/NHDPlus04/NHDPlusAttributes/PlusFlowlineVAA.dbf db/postgis
	$(eval relation := $(notdir $@))
	@psql -c "\d $(relation)_real" > /dev/null 2>&1 || \
	(ogr2ogr \
		--config PG_USE_COPY YES \
		-nln $(relation)_real \
		-lco PRECISION=NO \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-f PGDump \
		/vsistdout/ \
		$< \
		plusflowlinevaa | pv | psql -v ON_ERROR_STOP=1 -qX && \
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
	  HU4=04 HU2=04_real envsubst < sql/nhdplusflowlinevaa_hu4.sql | \
	  psql -v ON_ERROR_STOP=1 -qX1)

db/nhdplusflowlinevaa_08: data/NHDPlusMS/NHDPlus08/NHDPlusAttributes/PlusFlowlineVAA.dbf db/postgis
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

db/nhdplusflowlinevaa_0802 \
db/nhdplusflowlinevaa_0804: sql/nhdplusflowlinevaa_hu4.sql db/nhdplusflowlinevaa_08
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
	@psql -c "\d $(relation)_real" > /dev/null 2>&1 || \
	(ogr2ogr \
		--config PG_USE_COPY YES \
		-dim XY \
		-lco GEOMETRY_NAME=geom \
		-lco POSTGIS_VERSION=2.2 \
		-lco SCHEMA=nhd \
		-lco CREATE_SCHEMA=OFF \
		-nln $(relation)_real \
		-nlt CONVERT_TO_LINEAR \
		-f PGDump \
		-skipfailures \
		-where "fcode NOT IN (36100, 37800, 39001, 39005, 39006, 39011, 39012, 43601, 43603, 43604, 43605, 43606, 43608, 43609, 43610, 43611, 43612, 43624, 43625, 43626, 46600, 46601, 46602, 49300)" \
		/vsistdout/ \
		$< | pv | psql -v ON_ERROR_STOP=1 -qX && \
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu4)" > /dev/null 2>&1 || \
	  HU4=04 HU2=04_real envsubst < sql/nhdwaterbody_hu4.sql | \
	  psql -v ON_ERROR_STOP=1 -qX1)

db/nhdwaterbody_08: data/NHDPlusMS/NHDPlus08/NHDSnapshot/Hydrography/NHDWaterbody.shp db/postgis
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

db/nhdwaterbody_0802 \
db/nhdwaterbody_0804: sql/nhdwaterbody_hu4.sql db/nhdwaterbody_08
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

# watershed boundaries for 2-digit hydrologic units
db/wbdhu2: data/WBD_National_GDB.zip db/postgis
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

db/reaches.04: sql/reaches_hu2.sql db/wbdhu2
	$(eval hu2 := 04)
	$(eval relation := $(notdir $(basename $@)))
	@psql -v ON_ERROR_STOP=1 -qXc "\d $(relation)_$(hu2)" > /dev/null 2>&1 || \
	  HU2=$(hu2) envsubst < $< | \
	  psql -v ON_ERROR_STOP=1 -qX1

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
										 db/nhdarea_% db/nhdwaterbody_% \
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

db/correct_putins.%: db/snapped_putins db/snapped_takeouts
	$(eval hu4 := $*)
	-HU4=$(hu4) psql -v ON_ERROR_STOP=1 -X1f sql/actions/correct_putins.sql

db/access: db/snapped_putins db/snapped_takeouts
	$(call create_relation)

db/descriptive_reach_segments: db/reach_segments
	$(call create_relation)

db/flowline: db/postgis
	$(call create_relation)

exports/access/access.shp: db/access
	mkdir -p $$(dirname $@)
	ogr2ogr $@ \
		-mapFieldType DateTime=String \
		"PG:${DATABASE_URL}" \
		-where "geom IS NOT NULL" \
		$(notdir $<)

exports/access.geojson: db/access
	mkdir -p $$(dirname $@)
	ogr2ogr $@ \
		-mapFieldType DateTime=String \
		"PG:${DATABASE_URL}" \
		-lco RFC7946=YES \
		-where "geom IS NOT NULL" \
		$(notdir $<)

exports/access.mbtiles: exports/access.geojson
	tippecanoe \
		-f \
		-o $@ \
		--use-attribute-for-id id \
		-l access \
		-n "Corrected access points" \
		-Z 5 \
		-z 13 \
		-r1 \
		$<

exports/access.%.geojson: db/access
	$(eval hu4 := $*)
	mkdir -p $$(dirname $@)
	ogr2ogr $@ \
		-mapFieldType DateTime=String \
		"PG:${DATABASE_URL}" \
		-lco RFC7946=YES \
		-where "huc4 = '$(hu4)' AND geom IS NOT NULL" \
		$(notdir $<)

exports/gages.geojson.gz:
	mkdir -p $$(dirname $@)
	ogr2ogr $@ \
		-f GeoJSONSeq \
		-mapFieldType DateTime=String,Time=String \
		"PG:${DATABASE_URL}" \
		-lco ID_FIELD=id \
		-select "source, id, name, update_frequency" \
		gages

exports/gages.mbtiles: exports/gages.geojson.gz
	tippecanoe \
		-f \
		-o $@ \
		-l gages \
		-n "Gage locations" \
		-Z 5 \
		-z 13 \
		-r1 \
		$<

exports/nhd.mbtiles: exports/nhdflowline.mbtiles exports/nhdpolygon.mbtiles
	mkdir -p $$(dirname $@)
	tile-join -n NHD -f -o $@ $^

.PRECIOUS: exports/nhdarea.geojson.gz

exports/nhdarea.geojson.gz:
	mkdir -p $$(dirname $@)
	ogr2ogr /vsistdout/ \
		-f GeoJSONSeq \
		-lco ID_FIELD=nhdplusid \
		-mapFieldType DateTime=String \
		"PG:${DATABASE_URL}" \
		nhdarea | pv -lcN $@ | pigz > $@

.PRECIOUS: exports/nhdflowline.geojson.gz

exports/nhdflowline.geojson.gz:
	mkdir -p $$(dirname $@)
	ogr2ogr /vsistdout/ \
		-f GeoJSONSeq \
		-lco ID_FIELD=nhdplusid \
		-mapFieldType DateTime=String \
		"PG:${DATABASE_URL}" \
		nhd.nhdflowline | pv -lcN $@ | pigz > $@ || rm -f $@

.PRECIOUS: exports/nhdflowline.mbtiles

exports/nhdflowline.mbtiles: exports/nhdflowline.geojson.gz
	tippecanoe \
		-f \
		-P \
		-o $@ \
		-l nhdflowline \
		-n "NHDFlowline" \
		-Z 12 \
		-z 12 \
		-d 13 \
		$<

.PRECIOUS: exports/nhdpolygon.geojson.gz

exports/nhdpolygon.geojson.gz:
	mkdir -p $$(dirname $@)
	ogr2ogr /vsistdout/ \
		-f GeoJSONSeq \
		-lco ID_FIELD=nhdplusid \
		-mapFieldType DateTime=String \
		"PG:${DATABASE_URL}" \
		nhd.nhdpolygon | pv -lcN $@ | pigz > $@ || rm -f $@

.PRECIOUS: exports/nhdarea.mbtiles

exports/nhdpolygon.mbtiles: exports/nhdpolygon.geojson.gz
	tippecanoe \
		-f \
		-P \
		-o $@ \
		-l nhdpolygon \
		-n "NHDArea + NHDWaterbody" \
		-Z 12 \
		-z 12 \
		-d 13 \
		$<
.PRECIOUS: exports/nhdwaterbody.geojson.gz

exports/rapids.geojson:
	mkdir -p $$(dirname $@)
	ogr2ogr $@ \
		-mapFieldType DateTime=String \
		"PG:${DATABASE_URL}" \
		-lco RFC7946=YES \
		-sql "SELECT isplayspot, iswaterfall, isputin, name, reachid AS reach_id, isaccess, isportage, approximate, distance, difficulty, ishazard, description, istakeout, rloc FROM rapids WHERE is_final AND NOT deleted AND rloc IS NOT NULL"

exports/rapids.mbtiles: exports/rapids.geojson
	tippecanoe \
		-f \
		-o $@ \
		--use-attribute-for-id rapidid \
		-l rapids \
		-n "Raw rapid data" \
		-Z 5 \
		-z 13 \
		-r1 \
		$<

exports/reach_segments.geojson: db/descriptive_reach_segments
	mkdir -p $$(dirname $@)
	ogr2ogr $@ \
		-mapFieldType DateTime=String \
		"PG:${DATABASE_URL}" \
		-lco RFC7946=YES \
		-sql "SELECT reach_id, river, section, NULLIF(altname, '') altname, abstract, huc4, replace(class::text, '(', ' (') \"class\", geom FROM descriptive_reach_segments WHERE geom IS NOT NULL"

exports/reach_segments.mbtiles: exports/reach_segments.geojson
	tippecanoe \
		-f \
		-o $@ \
		--use-attribute-for-id reach_id \
		-l reach_segments \
		-n "Generated reach segments" \
		-Z 5 \
		-z 13 \
		$<

exports/reach-segment-labels.geojson: db/descriptive_reach_segments
	mkdir -p $$(dirname $@)
	ogr2ogr $@ \
		-mapFieldType DateTime=String \
		"PG:${DATABASE_URL}" \
		-lco RFC7946=YES \
		-sql "SELECT reach_id, river, section, NULLIF(altname, '') altname, huc4, replace(class::text, '(', ' (') \"class\", ST_PointOnSurface(geom) geom FROM descriptive_reach_segments WHERE geom IS NOT NULL ORDER BY ST_Length(geom) DESC"

exports/reach-segment-labels.mbtiles: exports/reach-segment-labels.geojson
	tippecanoe \
		-f \
		-o $@ \
		--use-attribute-for-id reach_id \
		-l reach_segment-labels \
		-n "Reach segment centerpoints" \
		-Z 5 \
		-z 13 \
		-r1 \
		$<

exports/reach_segments/reach_segments.shp: db/descriptive_reach_segments
	mkdir -p $$(dirname $@)
	ogr2ogr $@ \
		-mapFieldType DateTime=String \
		"PG:${DATABASE_URL}" \
		-where "geom IS NOT NULL AND GeometryType(geom) != 'POINT'" \
		$(notdir $<)

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
	@$(MAKE) db/correct_putins.$(hu8)
	@$(MAKE) db/ak/reach_segments.$(hu8)
	@echo "Reaches for hydrologic unit $(hu8) processed."
	@mkdir -p $$(dirname $@)
	@touch $@

# process a specific 4-digit hydrologic unit
wbd/%: db/snapped_putins.% db/snapped_takeouts.%
	$(eval hu4 := $*)
	@$(MAKE) db/correct_putins.$(hu4)
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

.PRECIOUS: data/NHDPlusV21_MS_08_NHDPlusAttributes_09.7z

data/NHDPlusV21_MS_08_NHDPlusAttributes_09.7z:
	$(call download,http://www.horizon-systems.com/NHDPlusData/NHDPlusV21/Data/NHDPlusMS/NHDPlus08/NHDPlusV21_MS_08_NHDPlusAttributes_09.7z)

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

.PRECIOUS: data/NHDPlusV21_MS_08_NHDSnapshot_07.7z

data/NHDPlusV21_MS_08_NHDSnapshot_07.7z:
	$(call download,http://www.horizon-systems.com/NHDPlusData/NHDPlusV21/Data/NHDPlusMS/NHDPlus08/NHDPlusV21_MS_08_NHDSnapshot_07.7z)

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

data/NHDPlusMS/NHDPlus08/NHDPlusAttributes/PlusFlowlineVAA.dbf: data/NHDPlusV21_MS_08_NHDPlusAttributes_09.7z
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

data/NHDPlusMS/NHDPlus08/NHDSnapshot/Hydrography/NHDArea.shp \
data/NHDPlusMS/NHDPlus08/NHDSnapshot/Hydrography/NHDFlowline.shp \
data/NHDPlusMS/NHDPlus08/NHDSnapshot/Hydrography/NHDWaterbody.shp: data/NHDPlusV21_MS_08_NHDSnapshot_07.7z
	7z x -odata/ -y $<
	find data/NHDPlusMS/NHDPlus08/NHDSnapshot -exec touch {} \;

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
